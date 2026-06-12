// Resumable HF downloads with checksum verification (Phase 5).
//
// The Python downloader failure modes this replaces (PLAN "Context /
// lore"): Xet stalls (we speak plain HTTPS resolve/CDN), no resume on
// flaky links (we Range-resume partial blobs), and silent corruption
// (every blob is verified — sha256 for LFS files against the API's
// oid, git-blob sha1 for small files against blobId).
//
// Writes the exact huggingface_hub cache layout so the registry and
// loaders find the result with zero changes:
//   <hub>/models--{org}--{name}/blobs/<sha>            (verified bytes)
//   <hub>/models--{org}--{name}/snapshots/<commit>/<file> → ../../blobs/<sha>
//   <hub>/models--{org}--{name}/refs/<revision>        (commit sha)
//
// Files download sequentially (decode is bandwidth-bound, the network
// rarely is; resumability matters more than parallelism here).

import { mkdirSync, existsSync, statSync, createWriteStream, renameSync, rmSync, symlinkSync, readFileSync } from "node:fs";
import { dirname, join } from "node:path";
import { DEFAULT_HUB } from "./registry";

const ENDPOINT = "https://huggingface.co";

export interface RepoFile {
  rfilename: string;
  size: number;
  /** git blob sha1 (non-LFS identity, and the blob filename for non-LFS). */
  blobId: string;
  /** LFS sha256 + size; present for large files. oid is the blob filename. */
  lfs?: { oid: string; size: number };
}

export interface RepoListing {
  /** Commit sha the revision resolves to (snapshot dir name). */
  sha: string;
  files: RepoFile[];
}

export interface DownloadOptions {
  revision?: string;
  cacheDir?: string;
  endpoint?: string;
  token?: string | null;
  onProgress?: (file: string, received: number, total: number) => void;
}

/** HF auth: explicit > env > the file `hf auth login` writes. */
export function hfToken(): string | null {
  if (process.env.HF_TOKEN) return process.env.HF_TOKEN;
  try {
    return readFileSync(`${process.env.HOME}/.cache/huggingface/token`, "utf8").trim() || null;
  } catch {
    return null;
  }
}

/** git blob identity: sha1("blob <size>\0" + content) — what blobId is. */
export function gitBlobSha1(bytes: Uint8Array): string {
  const hasher = new Bun.CryptoHasher("sha1");
  hasher.update(`blob ${bytes.length}\0`);
  hasher.update(bytes);
  return hasher.digest("hex");
}

export async function listRepoFiles(
  repoId: string, opts: DownloadOptions = {},
): Promise<RepoListing> {
  const endpoint = opts.endpoint ?? ENDPOINT;
  const revision = opts.revision ?? "main";
  const token = opts.token === undefined ? hfToken() : opts.token;
  const url = `${endpoint}/api/models/${repoId}/revision/${encodeURIComponent(revision)}?blobs=true`;
  const res = await fetch(url, {
    headers: token ? { authorization: `Bearer ${token}` } : {},
  });
  if (!res.ok)
    throw new Error(`HF API ${res.status} for ${repoId}@${revision}: ${(await res.text()).slice(0, 200)}`);
  const body = (await res.json()) as {
    sha: string;
    siblings: { rfilename: string; size?: number; blobId?: string; lfs?: { oid: string; size: number } }[];
  };
  return {
    sha: body.sha,
    files: body.siblings.map((s) => ({
      rfilename: s.rfilename,
      size: s.lfs?.size ?? s.size ?? 0,
      blobId: s.blobId ?? "",
      lfs: s.lfs,
    })),
  };
}

/** Follow redirects manually so the Authorization header is DROPPED at
 *  the CDN hop — presigned S3/CloudFront URLs reject requests that
 *  carry it (the classic hub-client footgun). Range survives. */
async function fetchBlob(
  url: string, token: string | null, rangeStart: number,
): Promise<Response> {
  const range: Record<string, string> = {};
  if (rangeStart > 0) range["range"] = `bytes=${rangeStart}-`;
  const authed: Record<string, string> = { ...range };
  if (token) authed["authorization"] = `Bearer ${token}`;
  let res = await fetch(url, { redirect: "manual", headers: authed });
  let hops = 0;
  while (res.status >= 300 && res.status < 400 && hops < 5) {
    const loc = res.headers.get("location");
    if (!loc) break;
    // no auth past the redirect — presigned URLs reject it
    res = await fetch(new URL(loc, url).href, { redirect: "manual", headers: range });
    hops++;
  }
  return res;
}

export async function downloadOne(
  url: string, token: string | null, blobPath: string,
  expected: { size: number; sha256?: string; sha1?: string; name: string },
  onProgress?: DownloadOptions["onProgress"],
): Promise<void> {
  const partPath = `${blobPath}.incomplete`;
  let offset = existsSync(partPath) ? statSync(partPath).size : 0;
  if (offset > expected.size) {
    rmSync(partPath); // stale junk; start over
    offset = 0;
  }

  // Streaming verification — resume re-hashes the existing prefix so the
  // final digest always covers every byte on disk.
  const sha256 = new Bun.CryptoHasher("sha256");
  const sha1 = new Bun.CryptoHasher("sha1");
  sha1.update(`blob ${expected.size}\0`);
  if (offset > 0) {
    const existing = await Bun.file(partPath).arrayBuffer();
    sha256.update(existing);
    sha1.update(existing);
  }

  if (offset < expected.size) {
    const res = await fetchBlob(url, token, offset);
    if (res.status === 200 && offset > 0) {
      // server ignored Range — start the file (and hashes) over
      rmSync(partPath);
      return downloadOne(url, token, blobPath, expected, onProgress);
    }
    if (res.status !== 200 && res.status !== 206)
      throw new Error(`download failed (${res.status}) for ${expected.name}`);
    const out = createWriteStream(partPath, { flags: offset > 0 ? "a" : "w" });
    try {
      for await (const chunk of res.body as ReadableStream<Uint8Array>) {
        sha256.update(chunk);
        sha1.update(chunk);
        await new Promise<void>((resolve, reject) =>
          out.write(chunk, (e) => (e ? reject(e) : resolve())),
        );
        offset += chunk.length;
        onProgress?.(expected.name, offset, expected.size);
      }
    } finally {
      await new Promise<void>((resolve) => out.end(() => resolve()));
    }
  }

  if (expected.size === 0 && !existsSync(partPath)) await Bun.write(partPath, "");
  if (offset !== expected.size) {
    throw new Error(
      `short download for ${expected.name}: ${offset} of ${expected.size} bytes ` +
      `(.incomplete kept — rerun to resume)`,
    );
  }
  const digestOk = expected.sha256
    ? sha256.digest("hex") === expected.sha256
    : expected.sha1
      ? sha1.digest("hex") === expected.sha1
      : true;
  if (!digestOk) {
    rmSync(partPath); // corrupt — never resume from it
    throw new Error(`checksum mismatch for ${expected.name} — partial removed, rerun to retry`);
  }
  renameSync(partPath, blobPath);
}

/** Download (or complete) a model snapshot. Returns the snapshot path.
 *  Idempotent: verified blobs are never re-fetched; partial blobs
 *  resume with a Range request. */
/** Process-global download tracker — the status page's /downloads
 *  endpoint reads this. Only downloads performed by THIS process are
 *  visible (a `mlx-bun get` in another terminal is not). */
export interface DownloadStatus {
  repoId: string;
  state: "active" | "done" | "error";
  currentFile: string | null;
  receivedBytes: number;
  totalBytes: number;
  filesDone: number;
  filesTotal: number;
  /** Rolling-window transfer rate (server-measured, ~5 s window). */
  bytesPerSec: number;
  startedAt: number;
  finishedAt: number | null;
  error?: string;
}
const downloadLog: DownloadStatus[] = [];
export function downloadsSnapshot(): DownloadStatus[] {
  return downloadLog.slice(-5);
}

export async function downloadModel(
  repoId: string, opts: DownloadOptions = {},
): Promise<string> {
  const endpoint = opts.endpoint ?? ENDPOINT;
  const revision = opts.revision ?? "main";
  const token = opts.token === undefined ? hfToken() : opts.token;
  const hub = opts.cacheDir ?? DEFAULT_HUB;

  const listing = await listRepoFiles(repoId, { ...opts, token });
  const repoDir = join(hub, `models--${repoId.replaceAll("/", "--")}`);
  const blobsDir = join(repoDir, "blobs");
  const snapDir = join(repoDir, "snapshots", listing.sha);
  mkdirSync(blobsDir, { recursive: true });
  mkdirSync(join(repoDir, "refs"), { recursive: true });

  const status: DownloadStatus = {
    repoId, state: "active", currentFile: null,
    receivedBytes: 0, totalBytes: listing.files.reduce((a, f) => a + f.size, 0),
    filesDone: 0, filesTotal: listing.files.length,
    bytesPerSec: 0, startedAt: Date.now(), finishedAt: null,
  };
  downloadLog.push(status);
  let doneBytes = 0;
  // Rolling ~5 s window of (time, receivedBytes) samples for the rate.
  const samples: Array<[number, number]> = [];
  const sampleRate = (bytes: number) => {
    const now = performance.now();
    samples.push([now, bytes]);
    while (samples.length > 2 && now - samples[0]![0] > 5000) samples.shift();
    const [t0, b0] = samples[0]!;
    status.bytesPerSec = now > t0 ? ((bytes - b0) / (now - t0)) * 1000 : 0;
  };

  try {
    for (const f of listing.files) {
      const blobId = f.lfs?.oid ?? f.blobId;
      if (!blobId) throw new Error(`no blob id for ${f.rfilename} (API response missing ?blobs=true data)`);
      const blobPath = join(blobsDir, blobId);

      if (!existsSync(blobPath) || statSync(blobPath).size !== f.size) {
        const url = `${endpoint}/${repoId}/resolve/${listing.sha}/${f.rfilename}`;
        status.currentFile = f.rfilename;
        await downloadOne(url, token, blobPath, {
          size: f.size, name: f.rfilename,
          ...(f.lfs ? { sha256: f.lfs.oid } : { sha1: f.blobId }),
        }, (file, received, total) => {
          status.receivedBytes = doneBytes + received;
          sampleRate(status.receivedBytes);
          opts.onProgress?.(file, received, total);
        });
      }
      doneBytes += f.size;
      status.receivedBytes = doneBytes;
      status.filesDone++;
      status.currentFile = null;

      const linkPath = join(snapDir, f.rfilename);
      mkdirSync(dirname(linkPath), { recursive: true });
      if (!existsSync(linkPath)) {
        // relative target, depth-aware for nested rfilenames
        const depth = f.rfilename.split("/").length - 1;
        symlinkSync(join("../".repeat(depth + 2), "blobs", blobId), linkPath);
      }
    }
    status.state = "done";
    status.bytesPerSec = 0;
    status.finishedAt = Date.now();
  } catch (e) {
    status.state = "error";
    status.bytesPerSec = 0;
    status.error = e instanceof Error ? e.message : String(e);
    status.finishedAt = Date.now();
    throw e;
  }

  await Bun.write(join(repoDir, "refs", revision), listing.sha);
  return snapDir;
}
