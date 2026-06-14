// Native Hugging Face push-to-hub — no Python, no huggingface_hub.
//
// Uploads a local directory (a quantized model dir, a LoRA adapter dir, or
// a dataset dir) to the Hub by speaking the same HTTP protocol the official
// client uses:
//
//   1. POST {base}/api/repos/create          — create the repo (exist_ok)
//   2. POST {base}/api/{models|datasets}/<repo>/preupload/<rev>
//                                             — learn which files are LFS
//   3. POST {base}/<prefix><repo>.git/info/lfs/objects/batch
//      + PUT to the returned S3 href         — upload LFS blobs
//      (+ optional POST to a `verify` href)
//   4. POST {base}/api/{models|datasets}/<repo>/commit/<rev>
//                                             — NDJSON commit (header +
//                                               regular `file` + `lfsFile`)
//
// This is the UX contract the optiq Lab routes expect ({repo_id, private}
// → create repo, upload folder, return {ok, url}) minus the Fernet
// password-derived token store: we keep a single plain write token at
// ~/.mlx-bun/hf.json (mode 0600). See the module note on saveHfToken.

import {
  mkdirSync,
  readFileSync,
  writeFileSync,
  chmodSync,
  statSync,
  readdirSync,
  existsSync,
} from "node:fs";
import { join, relative, sep } from "node:path";
import { homedir } from "node:os";

/** Home dir, honoring $HOME at call time (node:os homedir() caches the
 *  password-DB value at startup and ignores runtime $HOME changes on
 *  macOS). Matches src/download.ts, which reads process.env.HOME. */
function home(): string {
  return process.env.HOME || homedir();
}

const DEFAULT_BASE = "https://huggingface.co";

// HF's default .gitattributes promotes these to LFS regardless of size, plus
// anything over the size threshold. Mirrors huggingface_hub's defaults.
const LFS_SUFFIXES = [
  ".safetensors",
  ".bin",
  ".gguf",
  ".pt",
  ".pth",
  ".ckpt",
  ".onnx",
  ".npz",
  ".npy",
  ".h5",
  ".tflite",
  ".msgpack",
  ".arrow",
  ".parquet",
  ".pickle",
  ".pkl",
  ".model",
  ".tar",
  ".tar.gz",
  ".tgz",
  ".zip",
  ".gz",
  ".7z",
  ".bz2",
  ".xz",
  ".zst",
  ".mp3",
  ".wav",
  ".flac",
  ".ogg",
  ".mp4",
  ".webm",
  ".tif",
  ".tiff",
  ".png",
  ".jpg",
  ".jpeg",
  ".webp",
];
const LFS_SIZE_THRESHOLD = 10 * 1024 * 1024; // ~10 MB

export type RepoType = "model" | "dataset";

export interface HfTokenFile {
  token: string;
  savedAt: string;
}

export interface UploadOptions {
  repoType?: RepoType;
  private?: boolean;
  token?: string | null;
  commitMessage?: string;
  /** Optional glob-free prefix/substring allowlist; if set, only files whose
   *  repo path includes one of these substrings are uploaded. */
  allowPatterns?: string[];
  /** Override the Hub base URL — tests point this at a local mock. */
  baseUrl?: string;
  /** Per-file progress: (repoPath, bytesSent, bytesTotal). */
  onProgress?: (file: string, sent: number, total: number) => void;
}

export interface UploadResult {
  ok: true;
  url: string;
  commitOid?: string;
}

// ---------------------------------------------------------------------------
// Token storage
// ---------------------------------------------------------------------------

function tokenPath(): string {
  return join(home(), ".mlx-bun", "hf.json");
}

/**
 * Persist a plain HF write token to ~/.mlx-bun/hf.json (mode 0600).
 *
 * NOTE — simplification vs optiq's encrypted store: optiq encrypts the
 * token at rest with a Fernet key derived from the Lab password (so a
 * stolen DB is useless without the password). We store the token in
 * plaintext, protected only by file permissions. The threat model for
 * mlx-bun is a single local user on their own machine; if you need
 * encryption-at-rest, prefer the env var / shared HF cache fallbacks.
 */
export function saveHfToken(token: string): void {
  const t = (token ?? "").trim();
  if (!t) throw new Error("saveHfToken: token is empty");
  const dir = join(home(), ".mlx-bun");
  mkdirSync(dir, { recursive: true });
  const path = tokenPath();
  const body: HfTokenFile = { token: t, savedAt: new Date().toISOString() };
  writeFileSync(path, JSON.stringify(body, null, 2) + "\n", { mode: 0o600 });
  // writeFileSync mode is masked by umask on create; force it.
  chmodSync(path, 0o600);
}

/**
 * Resolve an HF token, in priority order:
 *   1. the token we stored (~/.mlx-bun/hf.json)
 *   2. $HF_TOKEN
 *   3. the standard huggingface_hub cache token (~/.cache/huggingface/token)
 * Returns null if none is found.
 */
export function getHfToken(): string | null {
  try {
    const raw = readFileSync(tokenPath(), "utf8");
    const parsed = JSON.parse(raw) as Partial<HfTokenFile>;
    if (parsed.token && parsed.token.trim()) return parsed.token.trim();
  } catch {
    // fall through to env / cache
  }
  if (process.env.HF_TOKEN && process.env.HF_TOKEN.trim()) {
    return process.env.HF_TOKEN.trim();
  }
  try {
    const cache = join(home(), ".cache", "huggingface", "token");
    const t = readFileSync(cache, "utf8").trim();
    if (t) return t;
  } catch {
    // none available
  }
  return null;
}

/** True if a token is resolvable from any source (for settings UI). */
export function hasHfToken(): boolean {
  return getHfToken() !== null;
}

// ---------------------------------------------------------------------------
// HTTP helpers
// ---------------------------------------------------------------------------

function authHeaders(token: string | null | undefined): Record<string, string> {
  return token ? { authorization: `Bearer ${token}` } : {};
}

/** Turn a transport-level HTTP failure into a clear, actionable error. */
async function httpError(action: string, res: Response): Promise<Error> {
  let detail = "";
  try {
    detail = (await res.text()).slice(0, 300);
  } catch {
    /* ignore */
  }
  const hints: Record<number, string> = {
    401: "unauthorized — your HF token is missing, invalid, or expired (need a *write* token)",
    403: "forbidden — the token lacks write access to this repo/org, or the repo is gated",
    404: "not found — check the repo id and that you can write to that namespace",
  };
  const hint = hints[res.status];
  return new Error(
    `${action} failed (HTTP ${res.status}${hint ? `: ${hint}` : ""})` +
      (detail ? `: ${detail}` : ""),
  );
}

// ---------------------------------------------------------------------------
// Repo type → URL prefix
// ---------------------------------------------------------------------------

/** API path segment: models live at /api/models/..., datasets at
 *  /api/datasets/...  (spaces would be /api/spaces/, unused here). */
function apiPrefix(repoType: RepoType): string {
  return repoType === "dataset" ? "datasets" : "models";
}

/** git/LFS URL prefix: models have no prefix, datasets are under datasets/. */
function gitPrefix(repoType: RepoType): string {
  return repoType === "dataset" ? "datasets/" : "";
}

// ---------------------------------------------------------------------------
// 1. Create repo
// ---------------------------------------------------------------------------

export interface CreateRepoOptions {
  repoType?: RepoType;
  private?: boolean;
  token?: string | null;
  baseUrl?: string;
}

/**
 * Create a Hub repo. Idempotent: an "already exists / 409" response is
 * treated as success so callers can always create-then-push.
 */
export async function createRepo(
  repoId: string,
  opts: CreateRepoOptions = {},
): Promise<{ url: string }> {
  const base = opts.baseUrl ?? DEFAULT_BASE;
  const repoType = opts.repoType ?? "model";
  const token = opts.token === undefined ? getHfToken() : opts.token;

  // repoId may be "org/name" or just "name" (lands under the token's user).
  const slash = repoId.indexOf("/");
  const organization = slash >= 0 ? repoId.slice(0, slash) : undefined;
  const name = slash >= 0 ? repoId.slice(slash + 1) : repoId;

  const body: Record<string, unknown> = {
    type: repoType,
    name,
    private: opts.private ?? false,
  };
  if (organization) body.organization = organization;

  const res = await fetch(`${base}/api/repos/create`, {
    method: "POST",
    headers: { "content-type": "application/json", ...authHeaders(token) },
    body: JSON.stringify(body),
  });

  if (res.ok) {
    let json: { url?: string } = {};
    try {
      json = (await res.json()) as { url?: string };
    } catch {
      /* some servers return empty body */
    }
    return { url: json.url ?? `${base}/${repoType === "dataset" ? "datasets/" : ""}${repoId}` };
  }
  // Already-exists is fine (HF returns 409 with a message we can detect).
  if (res.status === 409) {
    return { url: `${base}/${repoType === "dataset" ? "datasets/" : ""}${repoId}` };
  }
  throw await httpError("create repo", res);
}

// ---------------------------------------------------------------------------
// File walking + LFS classification
// ---------------------------------------------------------------------------

interface LocalFile {
  /** absolute path on disk */
  abs: string;
  /** forward-slash repo-relative path */
  repoPath: string;
  size: number;
}

function walkDir(dir: string): LocalFile[] {
  const out: LocalFile[] = [];
  const recurse = (cur: string) => {
    for (const entry of readdirSync(cur, { withFileTypes: true })) {
      // Skip VCS / hidden cruft that would never belong in a push.
      if (entry.name === ".git" || entry.name === ".cache") continue;
      const abs = join(cur, entry.name);
      if (entry.isDirectory()) {
        recurse(abs);
      } else if (entry.isFile()) {
        const st = statSync(abs);
        out.push({
          abs,
          repoPath: relative(dir, abs).split(sep).join("/"),
          size: st.size,
        });
      }
    }
  };
  recurse(dir);
  return out;
}

function isLfs(file: LocalFile): boolean {
  const lower = file.repoPath.toLowerCase();
  if (LFS_SUFFIXES.some((s) => lower.endsWith(s))) return true;
  return file.size >= LFS_SIZE_THRESHOLD;
}

function sha256Hex(bytes: Uint8Array): string {
  return new Bun.CryptoHasher("sha256").update(bytes).digest("hex");
}

// ---------------------------------------------------------------------------
// 2. Preupload
// ---------------------------------------------------------------------------

interface PreuploadEntry {
  path: string;
  uploadMode: "lfs" | "regular";
  shouldIgnore?: boolean;
  oid?: string | null;
}

async function preupload(
  base: string,
  repoId: string,
  repoType: RepoType,
  revision: string,
  files: { file: LocalFile; sample: Uint8Array }[],
  token: string | null,
): Promise<Map<string, PreuploadEntry>> {
  const url = `${base}/api/${apiPrefix(repoType)}/${repoId}/preupload/${encodeURIComponent(revision)}`;
  const res = await fetch(url, {
    method: "POST",
    headers: { "content-type": "application/json", ...authHeaders(token) },
    body: JSON.stringify({
      files: files.map(({ file, sample }) => ({
        path: file.repoPath,
        sample: Buffer.from(sample).toString("base64"),
        size: file.size,
      })),
    }),
  });
  if (!res.ok) throw await httpError("preupload", res);
  const json = (await res.json()) as { files?: PreuploadEntry[] };
  const map = new Map<string, PreuploadEntry>();
  for (const e of json.files ?? []) map.set(e.path, e);
  return map;
}

// ---------------------------------------------------------------------------
// 3. LFS upload (batch → PUT → optional verify)
// ---------------------------------------------------------------------------

interface LfsAction {
  href: string;
  header?: Record<string, string>;
}
interface LfsObject {
  oid: string;
  size: number;
  actions?: { upload?: LfsAction; verify?: LfsAction } | null;
  error?: { code: number; message: string };
}

async function uploadLfsFiles(
  base: string,
  repoId: string,
  repoType: RepoType,
  revision: string,
  items: { file: LocalFile; oid: string; bytes: Uint8Array }[],
  token: string | null,
  onProgress?: UploadOptions["onProgress"],
): Promise<void> {
  if (items.length === 0) return;

  const batchUrl = `${base}/${gitPrefix(repoType)}${repoId}.git/info/lfs/objects/batch`;
  const batchRes = await fetch(batchUrl, {
    method: "POST",
    headers: {
      accept: "application/vnd.git-lfs+json",
      "content-type": "application/vnd.git-lfs+json",
      ...authHeaders(token),
    },
    body: JSON.stringify({
      operation: "upload",
      transfers: ["basic"], // we implement the simple single-PUT transfer
      hash_algo: "sha256",
      ref: { name: revision },
      objects: items.map((i) => ({ oid: i.oid, size: i.file.size })),
    }),
  });
  if (!batchRes.ok) throw await httpError("LFS batch", batchRes);
  const batch = (await batchRes.json()) as { objects?: LfsObject[] };

  const byOid = new Map(items.map((i) => [i.oid, i]));
  for (const obj of batch.objects ?? []) {
    if (obj.error) {
      throw new Error(`LFS batch error for ${obj.oid}: ${obj.error.message} (code ${obj.error.code})`);
    }
    const item = byOid.get(obj.oid);
    if (!item) continue;

    // No upload action = the blob already exists upstream; skip the PUT.
    const upload = obj.actions?.upload;
    if (!upload) {
      onProgress?.(item.file.repoPath, item.file.size, item.file.size);
      continue;
    }

    const putRes = await fetch(upload.href, {
      method: "PUT",
      headers: { ...(upload.header ?? {}) },
      body: item.bytes,
    });
    if (!putRes.ok) throw await httpError(`LFS upload of ${item.file.repoPath}`, putRes);
    onProgress?.(item.file.repoPath, item.file.size, item.file.size);

    // Optional verify step (S3 transfers often request it).
    const verify = obj.actions?.verify;
    if (verify) {
      const vRes = await fetch(verify.href, {
        method: "POST",
        headers: {
          "content-type": "application/vnd.git-lfs+json",
          ...(verify.header ?? {}),
          ...authHeaders(token),
        },
        body: JSON.stringify({ oid: obj.oid, size: item.file.size }),
      });
      if (!vRes.ok) throw await httpError(`LFS verify of ${item.file.repoPath}`, vRes);
    }
  }
}

// ---------------------------------------------------------------------------
// 4. Commit (NDJSON)
// ---------------------------------------------------------------------------

async function commit(
  base: string,
  repoId: string,
  repoType: RepoType,
  revision: string,
  message: string,
  regularFiles: { file: LocalFile; bytes: Uint8Array }[],
  lfsFiles: { file: LocalFile; oid: string }[],
  token: string | null,
): Promise<{ commitOid?: string; commitUrl?: string }> {
  const lines: string[] = [];
  lines.push(
    JSON.stringify({
      key: "header",
      value: { summary: message, description: "" },
    }),
  );
  for (const { file, bytes } of regularFiles) {
    lines.push(
      JSON.stringify({
        key: "file",
        value: {
          path: file.repoPath,
          encoding: "base64",
          content: Buffer.from(bytes).toString("base64"),
        },
      }),
    );
  }
  for (const { file, oid } of lfsFiles) {
    lines.push(
      JSON.stringify({
        key: "lfsFile",
        value: {
          path: file.repoPath,
          algo: "sha256",
          oid,
          size: file.size,
        },
      }),
    );
  }
  const ndjson = lines.join("\n") + "\n";

  const url = `${base}/api/${apiPrefix(repoType)}/${repoId}/commit/${encodeURIComponent(revision)}`;
  const res = await fetch(url, {
    method: "POST",
    headers: {
      "content-type": "application/x-ndjson",
      ...authHeaders(token),
    },
    body: ndjson,
  });
  if (!res.ok) throw await httpError("commit", res);
  let json: { commitOid?: string; commitUrl?: string } = {};
  try {
    json = (await res.json()) as { commitOid?: string; commitUrl?: string };
  } catch {
    /* empty body is acceptable */
  }
  return json;
}

// ---------------------------------------------------------------------------
// Public: uploadFolder
// ---------------------------------------------------------------------------

/**
 * Upload a local directory to the Hub as a model or dataset repo.
 *
 * Walks `dir`, classifies each file as LFS (large or a binary suffix per
 * HF's default gitattributes) vs regular, runs preupload to confirm the
 * server's verdict, uploads LFS blobs via the LFS batch + PUT flow, then
 * posts a single NDJSON commit (regular files inlined as base64, LFS files
 * referenced by oid/size). Creates the repo first (idempotent).
 */
export async function uploadFolder(
  dir: string,
  repoId: string,
  opts: UploadOptions = {},
): Promise<UploadResult> {
  const base = opts.baseUrl ?? DEFAULT_BASE;
  const repoType = opts.repoType ?? "model";
  const revision = "main";
  const token = opts.token === undefined ? getHfToken() : opts.token;
  const message = opts.commitMessage ?? "Upload with mlx-bun";

  if (!existsSync(dir) || !statSync(dir).isDirectory()) {
    throw new Error(`uploadFolder: not a directory: ${dir}`);
  }

  // Discover + filter files.
  let files = walkDir(dir);
  if (opts.allowPatterns && opts.allowPatterns.length > 0) {
    const pats = opts.allowPatterns;
    files = files.filter((f) => pats.some((p) => f.repoPath.includes(p)));
  }
  if (files.length === 0) {
    throw new Error(`uploadFolder: no files to upload in ${dir}`);
  }

  // Create the repo (idempotent) before any upload.
  await createRepo(repoId, {
    repoType,
    private: opts.private,
    token,
    baseUrl: base,
  });

  // Read bytes + compute the LFS sha256 oids; build the preupload samples
  // (first 512 bytes, what huggingface_hub sends).
  const loaded = await Promise.all(
    files.map(async (file) => {
      const bytes = new Uint8Array(await Bun.file(file.abs).arrayBuffer());
      return {
        file,
        bytes,
        oid: sha256Hex(bytes),
        sample: bytes.subarray(0, 512),
      };
    }),
  );

  // Local LFS guess feeds the preupload request's sample/size; the server's
  // verdict is authoritative.
  const verdict = await preupload(
    base,
    repoId,
    repoType,
    revision,
    loaded.map((l) => ({ file: l.file, sample: l.sample })),
    token,
  );

  const regularFiles: { file: LocalFile; bytes: Uint8Array }[] = [];
  const lfsToUpload: { file: LocalFile; oid: string; bytes: Uint8Array }[] = [];
  const lfsForCommit: { file: LocalFile; oid: string }[] = [];

  for (const l of loaded) {
    const v = verdict.get(l.file.repoPath);
    if (v?.shouldIgnore) continue; // server says don't track this file
    // Prefer the server's verdict; fall back to our local heuristic.
    const mode = v?.uploadMode ?? (isLfs(l.file) ? "lfs" : "regular");
    if (mode === "lfs") {
      lfsToUpload.push({ file: l.file, oid: l.oid, bytes: l.bytes });
      lfsForCommit.push({ file: l.file, oid: l.oid });
    } else {
      regularFiles.push({ file: l.file, bytes: l.bytes });
    }
  }

  await uploadLfsFiles(
    base,
    repoId,
    repoType,
    revision,
    lfsToUpload,
    token,
    opts.onProgress,
  );

  // Report progress for inlined regular files too.
  for (const { file } of regularFiles) {
    opts.onProgress?.(file.repoPath, file.size, file.size);
  }

  const result = await commit(
    base,
    repoId,
    repoType,
    revision,
    message,
    regularFiles,
    lfsForCommit,
    token,
  );

  const url = `${base}/${repoType === "dataset" ? "datasets/" : ""}${repoId}`;
  return { ok: true, url, commitOid: result.commitOid };
}
