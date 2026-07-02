// Download lockfile + gated-repo hint (fast tier — localhost mock, no HF).
//
// The lock kills the foreground-`get` vs background-auto-download race:
// two writers appending to one .incomplete corrupts the blob. O_EXCL
// arbitration, pid liveness + ~1 h staleness stealing.

import { afterAll, describe, expect, test } from "bun:test";
import {
  existsSync, mkdirSync, mkdtempSync, rmSync, utimesSync, writeFileSync,
} from "node:fs";
import { tmpdir } from "node:os";
import { join } from "node:path";
import { downloadOne, listRepoFiles } from "../src/download";

const dirs: string[] = [];
afterAll(() => { for (const d of dirs) rmSync(d, { recursive: true, force: true }); });

function tmp(): string {
  const d = mkdtempSync(join(tmpdir(), "mlx-bun-lock-"));
  dirs.push(d);
  return d;
}

const payload = new TextEncoder().encode("hello blob");
const payloadSha256 = new Bun.CryptoHasher("sha256").update(payload).digest("hex");

const server = Bun.serve({
  port: 0,
  fetch(req) {
    const url = new URL(req.url);
    if (url.pathname === "/blob") return new Response(payload);
    if (url.pathname === "/api/models/gated/repo/revision/main")
      return new Response("Access to model gated/repo is restricted", { status: 401 });
    return new Response("not found", { status: 404 });
  },
});
afterAll(() => server.stop(true));
const blobUrl = `http://localhost:${server.port}/blob`;

describe("download lockfile", () => {
  test("live lock: fails fast with a friendly message, touches nothing", async () => {
    const dir = tmp();
    const blobPath = join(dir, "blob-a");
    // held by THIS process (alive) with a fresh mtime → genuinely in progress
    writeFileSync(`${blobPath}.lock`, `${process.pid}\n${new Date().toISOString()}\n`);
    // unreachable URL proves we never get to the network
    await expect(
      downloadOne("http://127.0.0.1:1/never", null, blobPath, { size: payload.length, name: "blob-a" }),
    ).rejects.toThrow(/another download of blob-a is in progress \(pid \d+\)/);
    expect(existsSync(`${blobPath}.lock`)).toBe(true); // not ours to remove
    expect(existsSync(blobPath)).toBe(false);
  });

  test("dead-pid lock is stolen and the download proceeds", async () => {
    const dir = tmp();
    const blobPath = join(dir, "blob-b");
    // pid that can't exist (macOS PID_MAX is ~99998), fresh mtime
    writeFileSync(`${blobPath}.lock`, `99999999\n${new Date().toISOString()}\n`);
    await downloadOne(blobUrl, null, blobPath, {
      size: payload.length, sha256: payloadSha256, name: "blob-b",
    });
    expect(await Bun.file(blobPath).text()).toBe("hello blob");
    expect(existsSync(`${blobPath}.lock`)).toBe(false); // released
  });

  test("stale-by-age lock (>1 h) is stolen even if the pid is alive", async () => {
    const dir = tmp();
    const blobPath = join(dir, "blob-c");
    writeFileSync(`${blobPath}.lock`, `${process.pid}\n`);
    const old = (Date.now() - 2 * 60 * 60 * 1000) / 1000; // 2 h ago
    utimesSync(`${blobPath}.lock`, old, old);
    await downloadOne(blobUrl, null, blobPath, {
      size: payload.length, sha256: payloadSha256, name: "blob-c",
    });
    expect(await Bun.file(blobPath).text()).toBe("hello blob");
    expect(existsSync(`${blobPath}.lock`)).toBe(false);
  });

  test("lock is released on failure too", async () => {
    const dir = tmp();
    const blobPath = join(dir, "blob-d");
    mkdirSync(dir, { recursive: true });
    await expect(
      downloadOne("http://127.0.0.1:1/never", null, blobPath, { size: 4, name: "blob-d" }),
    ).rejects.toThrow(); // network failure
    expect(existsSync(`${blobPath}.lock`)).toBe(false); // finally released
  });
});

describe("gated-repo hint", () => {
  test("401 from the API appends the hf auth login hint", async () => {
    await expect(
      listRepoFiles("gated/repo", { endpoint: `http://localhost:${server.port}`, token: null }),
    ).rejects.toThrow(/gated repo\? run `hf auth login` or set HF_TOKEN/);
  });
});
