// Downloader integration (fast tier, no network): a local Bun.serve
// mock implements the HF api/resolve/CDN contract — including the parts
// that bite in production: 302 to a presigned CDN URL that REJECTS
// Authorization headers, Range resume, and checksum verification.

import { afterAll, beforeEach, describe, expect, test } from "bun:test";
import { mkdtempSync, rmSync, writeFileSync, existsSync, readlinkSync, statSync } from "node:fs";
import { tmpdir } from "node:os";
import { join } from "node:path";
import { downloadModel, gitBlobSha1 } from "../src/download";

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

const server = Bun.serve({
  port: 0,
  async fetch(req) {
    const url = new URL(req.url);
    if (url.pathname === `/api/models/${REPO}/revision/main`) {
      apiAuth = req.headers.get("authorization");
      return Response.json({
        sha: COMMIT,
        siblings: [
          { rfilename: "config.json", size: small.length, blobId: smallSha1 },
          {
            rfilename: "weights/model.bin", size: big.length,
            blobId: "aaaa000000000000000000000000000000000000",
            lfs: { oid: bigSha256, size: big.length },
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

  afterAll(() => rmSync(hub, { recursive: true, force: true }));
});
