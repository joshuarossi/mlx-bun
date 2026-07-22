// Downloader integration (fast tier, no network): a local Bun.serve
// mock implements the HF api/resolve/CDN contract — including the parts
// that bite in production: 302 to a presigned CDN URL that REJECTS
// Authorization headers, Range resume, and checksum verification.

import { afterAll, beforeEach, describe, expect, test } from "bun:test";
import { mkdtempSync, rmSync, writeFileSync, existsSync, readlinkSync, statSync } from "node:fs";
import { tmpdir } from "node:os";
import { join } from "node:path";
import { downloadModel, gitBlobSha1, isSafeRepoFilename } from "../src/download";

const REPO = "test/tiny-model";
const COMMIT = "0123456789abcdef0123456789abcdef01234567";

// two files: a "small" non-LFS json (git sha1 identity) and a "large"
// LFS binary (sha256 identity)
const small = new TextEncoder().encode(JSON.stringify({ model_type: "test" }));
const big = new Uint8Array(256 * 1024);
for (let i = 0; i < big.length; i++) big[i] = (i * 31 + 7) & 0xff;
const bigSha256 = new Bun.CryptoHasher("sha256").update(big).digest("hex");
const smallSha1 = gitBlobSha1(small);

const cdnRequests: { file: string; range: string | null; auth: string | null }[] = [];
let apiAuth: string | null = null;
let corruptBig = false;
let lfsDigestMode: "sha256" | "oid" | "missing" | "malformed" = "sha256";

const server = Bun.serve({
  port: 0,
  async fetch(req) {
    const url = new URL(req.url);
    if (url.pathname === `/api/models/${REPO}/revision/main`) {
      apiAuth = req.headers.get("authorization");
      const lfs = lfsDigestMode === "sha256"
        ? { sha256: bigSha256, size: big.length }
        : lfsDigestMode === "oid"
          ? { oid: bigSha256, size: big.length }
          : lfsDigestMode === "malformed"
            ? { sha256: "not-a-sha256", size: big.length }
            : { size: big.length };
      return Response.json({
        sha: COMMIT,
        siblings: [
          { rfilename: "config.json", size: small.length, blobId: smallSha1 },
          {
            rfilename: "weights/model.bin", size: big.length,
            blobId: "aaaa000000000000000000000000000000000000",
            // Hugging Face's current ?blobs=true schema names this digest
            // `sha256` (not `oid`). Keep the mock faithful so a field-name
            // drift cannot silently bypass content verification again.
            lfs,
          },
        ],
      });
    }
    const resolve = url.pathname.match(new RegExp(`^/${REPO}/resolve/${COMMIT}/(.+)$`));
    if (resolve) {
      // presigned-style redirect: the CDN leg must arrive WITHOUT auth
      return new Response(null, {
        status: 302,
        headers: { location: `/cdn/${resolve[1]}?signature=fake` },
      });
    }
    const cdn = url.pathname.match(/^\/cdn\/(.+)$/);
    if (cdn) {
      const file = cdn[1]!;
      cdnRequests.push({
        file,
        range: req.headers.get("range"),
        auth: req.headers.get("authorization"),
      });
      if (req.headers.get("authorization"))
        return new Response("presigned URL rejects Authorization", { status: 400 });
      let bytes: Uint8Array = file === "config.json" ? small : big;
      if (file === "weights/model.bin" && corruptBig) {
        bytes = bytes.slice();
        bytes[100] = bytes[100]! ^ 0xff;
      }
      const range = req.headers.get("range")?.match(/^bytes=(\d+)-$/);
      if (range) {
        const start = Number(range[1]);
        return new Response(bytes.slice(start), {
          status: 206,
          headers: { "content-range": `bytes ${start}-${bytes.length - 1}/${bytes.length}` },
        });
      }
      return new Response(bytes);
    }
    return new Response("not found", { status: 404 });
  },
});
afterAll(() => server.stop(true));

const endpoint = `http://localhost:${server.port}`;
let hub: string;
beforeEach(() => {
  hub = mkdtempSync(join(tmpdir(), "mlx-bun-dl-"));
  cdnRequests.length = 0;
  corruptBig = false;
  lfsDigestMode = "sha256";
});

const repoDir = () => join(hub, "models--test--tiny-model");

describe("downloader", () => {
  test("fresh download: hub layout, checksums, auth handling", async () => {
    const snap = await downloadModel(REPO, {
      endpoint, cacheDir: hub, token: "hf_secret",
    });
    expect(snap).toBe(join(repoDir(), "snapshots", COMMIT));

    // api leg authenticated, CDN leg not (presigned URLs reject it)
    expect(apiAuth).toBe("Bearer hf_secret");
    for (const r of cdnRequests) expect(r.auth).toBeNull();

    // content through the snapshot symlinks
    expect(await Bun.file(join(snap, "config.json")).text()).toBe(new TextDecoder().decode(small));
    expect(new Uint8Array(await Bun.file(join(snap, "weights/model.bin")).arrayBuffer())).toEqual(big);

    // blob naming: sha256 for LFS, git sha1 for small files; relative,
    // depth-aware symlinks; refs/main records the commit
    expect(existsSync(join(repoDir(), "blobs", bigSha256))).toBe(true);
    expect(existsSync(join(repoDir(), "blobs", smallSha1))).toBe(true);
    expect(readlinkSync(join(snap, "config.json"))).toBe(`../../blobs/${smallSha1}`);
    expect(readlinkSync(join(snap, "weights/model.bin"))).toBe(`../../../blobs/${bigSha256}`);
    expect(await Bun.file(join(repoDir(), "refs", "main")).text()).toBe(COMMIT);
  });

  test("resume: partial blob continues with a Range request", async () => {
    const blobsDir = join(repoDir(), "blobs");
    const half = big.length / 2;
    // pre-seed the first half as an interrupted download
    const { mkdirSync } = await import("node:fs");
    mkdirSync(blobsDir, { recursive: true });
    writeFileSync(join(blobsDir, `${bigSha256}.incomplete`), big.slice(0, half));

    const snap = await downloadModel(REPO, { endpoint, cacheDir: hub, token: null });
    const bigReq = cdnRequests.find((r) => r.file === "weights/model.bin");
    expect(bigReq?.range).toBe(`bytes=${half}-`);
    // resumed file still passes full-content sha256 verification
    expect(new Uint8Array(await Bun.file(join(snap, "weights/model.bin")).arrayBuffer())).toEqual(big);
    expect(statSync(join(blobsDir, bigSha256)).size).toBe(big.length);
  });

  test("checksum mismatch: throws and removes the partial", async () => {
    corruptBig = true;
    await expect(downloadModel(REPO, { endpoint, cacheDir: hub, token: null }))
      .rejects.toThrow(/checksum mismatch/);
    expect(existsSync(join(repoDir(), "blobs", bigSha256))).toBe(false);
    expect(existsSync(join(repoDir(), "blobs", `${bigSha256}.incomplete`))).toBe(false);

    // ...and a rerun with good bytes recovers cleanly
    corruptBig = false;
    const snap = await downloadModel(REPO, { endpoint, cacheDir: hub, token: null });
    expect(new Uint8Array(await Bun.file(join(snap, "weights/model.bin")).arrayBuffer())).toEqual(big);
  });

  test("idempotent: verified blobs are never re-fetched", async () => {
    await downloadModel(REPO, { endpoint, cacheDir: hub, token: null });
    const before = cdnRequests.length;
    await downloadModel(REPO, { endpoint, cacheDir: hub, token: null });
    expect(cdnRequests.length).toBe(before);
  });

  test("normalizes the legacy lfs.oid spelling to the SHA-256 identity", async () => {
    lfsDigestMode = "oid";
    const snap = await downloadModel(REPO, { endpoint, cacheDir: hub, token: null });
    expect(existsSync(join(repoDir(), "blobs", bigSha256))).toBe(true);
    expect(readlinkSync(join(snap, "weights/model.bin"))).toBe(`../../../blobs/${bigSha256}`);
  });

  test("rejects missing or malformed LFS digests before downloading", async () => {
    for (const mode of ["missing", "malformed"] as const) {
      lfsDigestMode = mode;
      await expect(downloadModel(REPO, { endpoint, cacheDir: hub, token: null }))
        .rejects.toThrow(/invalid LFS sha256/);
    }
    expect(cdnRequests).toHaveLength(0);
  });

  afterAll(() => rmSync(hub, { recursive: true, force: true }));
});

/* ────────────────────────────────────────────────────────────────────
   isSafeRepoFilename (review finding, src/hub-rest.ts / src/download.ts):
   a repo's `rfilename` is the remote HF API's own data, untrusted for a
   repo the caller doesn't control — an attacker-owned repo can return
   any string there, and it was flowing straight into
   join(snapDir, rfilename) + symlinkSync with zero validation. Reachable
   over HTTP via POST /api/hub/download (src/hub-rest.ts), which forwards
   any caller-supplied repo string with no allowlist.
   ──────────────────────────────────────────────────────────────────── */
describe("isSafeRepoFilename", () => {
  test("accepts ordinary flat and nested filenames", () => {
    expect(isSafeRepoFilename("config.json")).toBe(true);
    expect(isSafeRepoFilename("weights/model.safetensors")).toBe(true);
    expect(isSafeRepoFilename("a/b/c/d.bin")).toBe(true);
  });

  test("rejects any path-traversal segment", () => {
    expect(isSafeRepoFilename("../../../../../../etc/passwd")).toBe(false);
    expect(isSafeRepoFilename("../../home/x/.ssh/authorized_keys")).toBe(false);
    expect(isSafeRepoFilename("weights/../../escape.bin")).toBe(false);
    expect(isSafeRepoFilename("..")).toBe(false);
  });

  test("rejects an absolute path", () => {
    expect(isSafeRepoFilename("/etc/passwd")).toBe(false);
  });

  test("rejects empty string, empty segments, and embedded NUL", () => {
    expect(isSafeRepoFilename("")).toBe(false);
    expect(isSafeRepoFilename("a//b")).toBe(false);
    expect(isSafeRepoFilename("a/\0/b")).toBe(false);
  });
});

describe("downloadModel: refuses a repo listing with a path-traversal rfilename", () => {
  const evilRepo = "test/evil-model";
  const evilServer = Bun.serve({
    port: 0,
    async fetch(req) {
      const url = new URL(req.url);
      if (url.pathname === `/api/models/${evilRepo}/revision/main`) {
        return Response.json({
          sha: COMMIT,
          siblings: [
            { rfilename: "config.json", size: small.length, blobId: smallSha1 },
            // Malicious sibling: escapes the snapshot dir once join()'d.
            { rfilename: "../../../../../../tmp/mlx-bun-pwned", size: small.length, blobId: smallSha1 },
          ],
        });
      }
      return new Response("not found", { status: 404 });
    },
  });
  afterAll(() => evilServer.stop(true));
  const evilEndpoint = `http://localhost:${evilServer.port}`;

  test("throws before writing anything, and never creates a symlink outside the hub dir", async () => {
    const evilHub = mkdtempSync(join(tmpdir(), "mlx-bun-dl-evil-"));
    try {
      await expect(downloadModel(evilRepo, { endpoint: evilEndpoint, cacheDir: evilHub, token: null }))
        .rejects.toThrow(/unsafe file path/);
      expect(existsSync("/tmp/mlx-bun-pwned")).toBe(false);
    } finally {
      rmSync(evilHub, { recursive: true, force: true });
      rmSync("/tmp/mlx-bun-pwned", { force: true }); // best-effort cleanup if the bug regresses
    }
  });
});
