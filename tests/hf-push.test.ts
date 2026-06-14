// Native HF push-to-hub, exercised end-to-end against a LOCAL MOCK that
// implements the Hub upload contract (create / preupload / lfs-batch /
// S3-PUT / verify / commit). NOTHING here touches huggingface.co — a real
// push would publish under the user's account, so it is untested by design.
//
// What we assert:
//   - create-repo called with the right body + Bearer auth
//   - a *.safetensors file is classified LFS → routed through preupload,
//     the LFS batch API, an S3-style PUT, and the verify step
//   - small files are NOT uploaded as LFS — they're inlined in the commit
//     NDJSON as base64 `file` entries
//   - the commit NDJSON has the header + correct file/lfsFile entries
//   - uploadFolder returns {ok:true, url}
//   - token store round-trips in a tmp HOME, with 0600 perms + env/cache
//     fallbacks

import { afterAll, beforeAll, beforeEach, describe, expect, test } from "bun:test";
import { mkdtempSync, mkdirSync, rmSync, writeFileSync, statSync, readFileSync } from "node:fs";
import { tmpdir } from "node:os";
import { join } from "node:path";

import {
  uploadFolder,
  createRepo,
  saveHfToken,
  getHfToken,
  hasHfToken,
} from "../src/hf-push";

// ---------------------------------------------------------------------------
// Mock Hub server
// ---------------------------------------------------------------------------

interface Captured {
  createBody: any;
  createAuth: string | null;
  preuploadBody: any;
  preuploadAuth: string | null;
  lfsBatchBody: any;
  lfsBatchAuth: string | null;
  s3Puts: { oid: string; body: Uint8Array }[];
  verifies: { oid: string; size: number }[];
  commitBody: string | null;
  commitAuth: string | null;
}

function freshCapture(): Captured {
  return {
    createBody: null,
    createAuth: null,
    preuploadBody: null,
    preuploadAuth: null,
    lfsBatchBody: null,
    lfsBatchAuth: null,
    s3Puts: [],
    verifies: [],
    commitBody: null,
    commitAuth: null,
  };
}

let cap = freshCapture();
let lfsAlreadyExists = false; // toggle to simulate an upstream-present blob

const server = Bun.serve({
  port: 0,
  async fetch(req) {
    const url = new URL(req.url);
    const p = url.pathname;
    const auth = req.headers.get("authorization");

    // 1. create repo
    if (p === "/api/repos/create" && req.method === "POST") {
      cap.createBody = await req.json();
      cap.createAuth = auth;
      const { type, name, organization } = cap.createBody;
      const repo = organization ? `${organization}/${name}` : name;
      const pfx = type === "dataset" ? "datasets/" : "";
      return Response.json({ url: `${url.origin}/${pfx}${repo}` });
    }

    // 2. preupload — classify by suffix (mirror HF's gitattributes)
    let m = p.match(/^\/api\/(models|datasets)\/(.+)\/preupload\/(.+)$/);
    if (m && req.method === "POST") {
      cap.preuploadBody = await req.json();
      cap.preuploadAuth = auth;
      const files = (cap.preuploadBody.files ?? []).map((f: any) => ({
        path: f.path,
        // mirror HF's default gitattributes LFS suffixes (the subset we test)
        uploadMode: /\.(safetensors|bin|gguf|parquet)$/i.test(f.path) ? "lfs" : "regular",
        shouldIgnore: false,
        oid: null,
      }));
      return Response.json({ files });
    }

    // 3a. LFS batch
    if (p.endsWith(".git/info/lfs/objects/batch") && req.method === "POST") {
      cap.lfsBatchBody = await req.json();
      cap.lfsBatchAuth = auth;
      const objects = (cap.lfsBatchBody.objects ?? []).map((o: any) => {
        if (lfsAlreadyExists) {
          return { oid: o.oid, size: o.size, actions: null };
        }
        return {
          oid: o.oid,
          size: o.size,
          actions: {
            upload: { href: `${url.origin}/s3-put/${o.oid}`, header: { "x-test": "1" } },
            verify: { href: `${url.origin}/lfs-verify` },
          },
        };
      });
      return Response.json({ objects }, {
        headers: { "content-type": "application/vnd.git-lfs+json" },
      });
    }

    // 3b. S3-style PUT
    m = p.match(/^\/s3-put\/(.+)$/);
    if (m && req.method === "PUT") {
      const body = new Uint8Array(await req.arrayBuffer());
      cap.s3Puts.push({ oid: m[1]!, body });
      return new Response(null, { status: 200 });
    }

    // 3c. verify
    if (p === "/lfs-verify" && req.method === "POST") {
      const v = (await req.json()) as { oid: string; size: number };
      cap.verifies.push(v);
      return new Response(null, { status: 200 });
    }

    // 4. commit (NDJSON)
    m = p.match(/^\/api\/(models|datasets)\/(.+)\/commit\/(.+)$/);
    if (m && req.method === "POST") {
      cap.commitBody = await req.text();
      cap.commitAuth = auth;
      return Response.json({
        commitOid: "deadbeefcafe0000000000000000000000000000",
        commitUrl: `${url.origin}/commit/abc`,
      });
    }

    return new Response("not found: " + p, { status: 404 });
  },
});

const base = `http://localhost:${server.port}`;
afterAll(() => server.stop(true));

beforeEach(() => {
  cap = freshCapture();
  lfsAlreadyExists = false;
});

// ---------------------------------------------------------------------------
// uploadFolder protocol
// ---------------------------------------------------------------------------

function makeModelDir(): string {
  const dir = mkdtempSync(join(tmpdir(), "mlx-bun-hfpush-"));
  // a "large" binary classified LFS by suffix
  const weights = new Uint8Array(4096);
  for (let i = 0; i < weights.length; i++) weights[i] = (i * 13 + 5) & 0xff;
  writeFileSync(join(dir, "model.safetensors"), weights);
  // small text files inlined in the commit
  writeFileSync(join(dir, "config.json"), JSON.stringify({ model_type: "test" }));
  writeFileSync(join(dir, "README.md"), "# Test model\n");
  // a nested file to exercise path joining
  mkdirSync(join(dir, "tokenizer"), { recursive: true });
  writeFileSync(join(dir, "tokenizer", "tokenizer.json"), '{"a":1}');
  return dir;
}

describe("uploadFolder (mock Hub)", () => {
  test("classifies LFS vs regular, runs full protocol, returns {ok,url}", async () => {
    const dir = makeModelDir();
    const weights = new Uint8Array(await Bun.file(join(dir, "model.safetensors")).arrayBuffer());
    const expectedOid = new Bun.CryptoHasher("sha256").update(weights).digest("hex");

    const progress: { file: string; sent: number; total: number }[] = [];
    const res = await uploadFolder(dir, "me/test-model", {
      repoType: "model",
      private: true,
      token: "hf_secret",
      baseUrl: base,
      commitMessage: "first push",
      onProgress: (file, sent, total) => progress.push({ file, sent, total }),
    });

    // return value
    expect(res.ok).toBe(true);
    expect(res.url).toBe(`${base}/me/test-model`);
    expect(res.commitOid).toBe("deadbeefcafe0000000000000000000000000000");

    // 1. create repo: right body + auth
    expect(cap.createAuth).toBe("Bearer hf_secret");
    expect(cap.createBody).toMatchObject({
      type: "model",
      name: "test-model",
      organization: "me",
      private: true,
    });

    // 2. preupload: all files presented, authed
    expect(cap.preuploadAuth).toBe("Bearer hf_secret");
    const ppPaths = (cap.preuploadBody.files as any[]).map((f) => f.path).sort();
    expect(ppPaths).toEqual(
      ["README.md", "config.json", "model.safetensors", "tokenizer/tokenizer.json"].sort(),
    );
    // samples are base64-encoded
    for (const f of cap.preuploadBody.files) {
      expect(typeof f.sample).toBe("string");
      expect(typeof f.size).toBe("number");
    }

    // 3. LFS: only the safetensors went through batch + PUT + verify
    expect(cap.lfsBatchAuth).toBe("Bearer hf_secret");
    expect(cap.lfsBatchBody).toMatchObject({ operation: "upload", hash_algo: "sha256" });
    expect(cap.lfsBatchBody.objects).toEqual([{ oid: expectedOid, size: weights.length }]);
    expect(cap.s3Puts.length).toBe(1);
    expect(cap.s3Puts[0]!.oid).toBe(expectedOid);
    expect(cap.s3Puts[0]!.body).toEqual(weights); // exact bytes uploaded
    expect(cap.verifies).toEqual([{ oid: expectedOid, size: weights.length }]);

    // 4. commit NDJSON: header + 1 lfsFile + 3 regular files inlined
    expect(cap.commitAuth).toBe("Bearer hf_secret");
    const lines = cap.commitBody!.trim().split("\n").map((l) => JSON.parse(l));
    expect(lines[0]).toEqual({ key: "header", value: { summary: "first push", description: "" } });

    const lfsEntries = lines.filter((l) => l.key === "lfsFile");
    expect(lfsEntries).toEqual([
      { key: "lfsFile", value: { path: "model.safetensors", algo: "sha256", oid: expectedOid, size: weights.length } },
    ]);

    const fileEntries = lines.filter((l) => l.key === "file");
    const filePaths = fileEntries.map((e) => e.value.path).sort();
    expect(filePaths).toEqual(["README.md", "config.json", "tokenizer/tokenizer.json"]);
    // small file content is base64 of the real bytes
    const cfg = fileEntries.find((e) => e.value.path === "config.json")!;
    expect(cfg.value.encoding).toBe("base64");
    expect(Buffer.from(cfg.value.content, "base64").toString("utf8")).toBe(
      JSON.stringify({ model_type: "test" }),
    );
    // safetensors must NOT be inlined as a regular file
    expect(filePaths).not.toContain("model.safetensors");

    // progress fired for every file
    const seen = new Set(progress.map((p) => p.file));
    expect(seen).toEqual(
      new Set(["model.safetensors", "config.json", "README.md", "tokenizer/tokenizer.json"]),
    );

    rmSync(dir, { recursive: true, force: true });
  });

  test("dataset repo uses the datasets/ URL prefix throughout", async () => {
    const dir = mkdtempSync(join(tmpdir(), "mlx-bun-hfds-"));
    writeFileSync(join(dir, "train.jsonl"), '{"text":"hi"}\n');
    // a parquet file is LFS by suffix even though it's tiny
    writeFileSync(join(dir, "data.parquet"), new Uint8Array(64));

    let sawDatasetCommit = false;
    let sawDatasetLfsBatch = false;
    const origFetch = globalThis.fetch;
    globalThis.fetch = (async (input: any, init?: any) => {
      const u = typeof input === "string" ? input : input.url;
      if (u.includes("/api/datasets/") && u.includes("/commit/")) sawDatasetCommit = true;
      if (u.includes("/datasets/") && u.endsWith(".git/info/lfs/objects/batch")) sawDatasetLfsBatch = true;
      return origFetch(input, init);
    }) as typeof fetch;

    try {
      const res = await uploadFolder(dir, "me/my-dataset", {
        repoType: "dataset",
        token: "hf_secret",
        baseUrl: base,
      });
      expect(res.ok).toBe(true);
      expect(res.url).toBe(`${base}/datasets/me/my-dataset`);
      expect(cap.createBody.type).toBe("dataset");
      expect(sawDatasetCommit).toBe(true);
      expect(sawDatasetLfsBatch).toBe(true);
    } finally {
      globalThis.fetch = origFetch;
      rmSync(dir, { recursive: true, force: true });
    }
  });

  test("skips the PUT when the LFS blob already exists upstream", async () => {
    lfsAlreadyExists = true;
    const dir = makeModelDir();
    const res = await uploadFolder(dir, "me/test-model", {
      token: "hf_secret",
      baseUrl: base,
    });
    expect(res.ok).toBe(true);
    expect(cap.s3Puts.length).toBe(0); // no upload action → no PUT
    // but the commit still references the lfsFile so the file lands in the repo
    const lines = cap.commitBody!.trim().split("\n").map((l) => JSON.parse(l));
    expect(lines.some((l) => l.key === "lfsFile" && l.value.path === "model.safetensors")).toBe(true);
    rmSync(dir, { recursive: true, force: true });
  });

  test("allowPatterns filters which files are uploaded", async () => {
    const dir = makeModelDir();
    await uploadFolder(dir, "me/test-model", {
      token: "hf_secret",
      baseUrl: base,
      allowPatterns: ["config.json"],
    });
    const ppPaths = (cap.preuploadBody.files as any[]).map((f) => f.path);
    expect(ppPaths).toEqual(["config.json"]);
    expect(cap.s3Puts.length).toBe(0);
    rmSync(dir, { recursive: true, force: true });
  });

  test("surfaces a clear error on 401", async () => {
    const dir = mkdtempSync(join(tmpdir(), "mlx-bun-hf401-"));
    writeFileSync(join(dir, "config.json"), "{}");
    const origFetch = globalThis.fetch;
    globalThis.fetch = (async () =>
      new Response("Invalid credentials", { status: 401 })) as unknown as typeof fetch;
    try {
      await expect(
        uploadFolder(dir, "me/test-model", { token: "bad", baseUrl: base }),
      ).rejects.toThrow(/401.*unauthorized/i);
    } finally {
      globalThis.fetch = origFetch;
      rmSync(dir, { recursive: true, force: true });
    }
  });

  test("createRepo treats 409 already-exists as success", async () => {
    const origFetch = globalThis.fetch;
    globalThis.fetch = (async () =>
      new Response("You already created this repo", { status: 409 })) as unknown as typeof fetch;
    try {
      const r = await createRepo("me/dupe", { token: "hf_secret", baseUrl: base });
      expect(r.url).toBe(`${base}/me/dupe`);
    } finally {
      globalThis.fetch = origFetch;
    }
  });
});

// ---------------------------------------------------------------------------
// Token store (tmp HOME)
// ---------------------------------------------------------------------------

describe("HF token store", () => {
  let tmpHome: string;
  let realHome: string | undefined;
  let realHfToken: string | undefined;

  beforeAll(() => {
    realHome = process.env.HOME;
    realHfToken = process.env.HF_TOKEN;
  });
  beforeEach(() => {
    tmpHome = mkdtempSync(join(tmpdir(), "mlx-bun-home-"));
    process.env.HOME = tmpHome;
    delete process.env.HF_TOKEN;
  });
  afterAll(() => {
    if (realHome !== undefined) process.env.HOME = realHome;
    if (realHfToken !== undefined) process.env.HF_TOKEN = realHfToken;
    else delete process.env.HF_TOKEN;
  });

  test("save/get round-trips with 0600 perms", () => {
    expect(getHfToken()).toBeNull();
    expect(hasHfToken()).toBe(false);
    saveHfToken("hf_writetoken_123");
    expect(getHfToken()).toBe("hf_writetoken_123");
    expect(hasHfToken()).toBe(true);

    const path = join(tmpHome, ".mlx-bun", "hf.json");
    const mode = statSync(path).mode & 0o777;
    expect(mode).toBe(0o600);
    // stored as JSON, not raw
    const parsed = JSON.parse(readFileSync(path, "utf8"));
    expect(parsed.token).toBe("hf_writetoken_123");
    expect(typeof parsed.savedAt).toBe("string");
  });

  test("trims whitespace and rejects empty", () => {
    saveHfToken("  hf_padded  ");
    expect(getHfToken()).toBe("hf_padded");
    expect(() => saveHfToken("   ")).toThrow();
  });

  test("falls back to HF_TOKEN env when no stored token", () => {
    expect(getHfToken()).toBeNull();
    process.env.HF_TOKEN = "hf_from_env";
    expect(getHfToken()).toBe("hf_from_env");
  });

  test("stored token wins over the env fallback", () => {
    saveHfToken("hf_stored");
    process.env.HF_TOKEN = "hf_from_env";
    expect(getHfToken()).toBe("hf_stored");
  });

  test("falls back to ~/.cache/huggingface/token", () => {
    mkdirSync(join(tmpHome, ".cache", "huggingface"), { recursive: true });
    writeFileSync(join(tmpHome, ".cache", "huggingface", "token"), "hf_from_cache\n");
    expect(getHfToken()).toBe("hf_from_cache");
  });
});
