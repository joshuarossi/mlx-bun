#!/usr/bin/env bun
// Produce deterministic, fail-closed integrity evidence for an exact
// Hugging Face model revision.  The report intentionally covers LFS payloads:
// the exact-revision HF API publishes their authoritative SHA-256 and size.
//
// Two modes are supported:
//   hash            stream every LFS payload and compute SHA-256 now
//   prior-evidence  validate/relabel an existing digest report without reading
//                   model payload bytes (useful after an expensive cold hash)

import {
  createReadStream,
  existsSync,
  lstatSync,
  mkdirSync,
  readFileSync,
  readlinkSync,
  realpathSync,
  renameSync,
  rmSync,
  statSync,
} from "node:fs";
import { basename, dirname, isAbsolute, join, relative, resolve, sep } from "node:path";
import { fileURLToPath } from "node:url";
import { hfToken, isSafeRepoFilename, listRepoFiles, type RepoFile } from "../src/download";

const SOURCE = "scripts/verify-colibri-g0-artifact.ts";
const IDENTITY = "mlx-bun-colibri-g0-artifact-verifier/v1";
const COMMIT_RE = /^[0-9a-f]{40}$/;
const SHA256_RE = /^[0-9a-f]{64}$/;
const REPO_RE = /^[A-Za-z0-9._-]+\/[A-Za-z0-9._-]+$/;

export type ArtifactVerificationMode = "hash" | "prior-evidence";

export interface ArtifactVerifierOptions {
  repo: string;
  revision: string;
  snapshot: string;
  mode?: ArtifactVerificationMode;
  priorEvidence?: string;
  snapshotLabel?: string;
  endpoint?: string;
  token?: string | null;
}

export interface ArtifactEvidenceFile {
  path: string;
  bytes: number;
  expected_sha256: string;
  computed_sha256: string;
  match: true;
  computed_evidence: "fresh_payload_hash" | "prior_computed_evidence";
}

export interface ArtifactEvidenceV2 {
  schema_version: 2;
  evidence_kind: "hf_lfs_artifact_integrity";
  repo: string;
  requested_revision: string;
  resolved_revision: string;
  snapshot_revision: string;
  snapshot_label: string;
  verification_mode: "fresh_payload_hash" | "prior_computed_evidence";
  checker: {
    identity: string;
    source: string;
    source_sha256: string;
    command: string[];
    hashes_payloads: boolean;
    prior_evidence: null | {
      path: string;
      schema_version: 1 | 2;
      sha256: string;
    };
  };
  authoritative_metadata: {
    source: "huggingface_model_api_exact_revision";
    request: string;
    repository_files: number;
    lfs_files: number;
  };
  files_verified: number;
  bytes_verified: number;
  all_match: true;
  files: ArtifactEvidenceFile[];
}

function fail(message: string): never {
  throw new Error(`artifact verification failed: ${message}`);
}

function normalizeRevision(value: string, label: string): string {
  const normalized = value.toLowerCase();
  if (!COMMIT_RE.test(normalized)) fail(`${label} must be an exact 40-hex commit, got ${JSON.stringify(value)}`);
  return normalized;
}

function normalizeSha256(value: unknown, label: string): string {
  if (typeof value !== "string" || !SHA256_RE.test(value)) fail(`${label} is missing or malformed`);
  return value.toLowerCase();
}

function isWithin(parent: string, child: string): boolean {
  const rel = relative(parent, child);
  return rel === "" || (!rel.startsWith(`..${sep}`) && rel !== ".." && !isAbsolute(rel));
}

function validateSnapshotRoot(snapshotInput: string, revision: string, repo: string): {
  snapshot: string;
  repoDir: string;
  blobsDir: string;
} {
  const snapshot = resolve(snapshotInput);
  if (!existsSync(snapshot)) fail(`snapshot does not exist: ${snapshot}`);
  const rootStat = lstatSync(snapshot);
  if (rootStat.isSymbolicLink()) fail(`snapshot directory must not be a symlink: ${snapshot}`);
  if (!rootStat.isDirectory()) fail(`snapshot is not a directory: ${snapshot}`);
  if (basename(snapshot).toLowerCase() !== revision || basename(dirname(snapshot)) !== "snapshots") {
    fail(`snapshot path must end in snapshots/${revision}`);
  }
  const repoDir = dirname(dirname(snapshot));
  const expectedRepoDir = `models--${repo.replaceAll("/", "--")}`;
  if (basename(repoDir) !== expectedRepoDir) {
    fail(`snapshot cache repo ${JSON.stringify(basename(repoDir))} does not match ${repo}`);
  }
  const blobsDir = join(repoDir, "blobs");
  if (!existsSync(blobsDir) || !statSync(blobsDir).isDirectory()) fail(`snapshot cache has no blobs directory: ${blobsDir}`);
  return { snapshot, repoDir, blobsDir };
}

/** Validate every path component before following the final HF cache symlink.
 * HF cache files are normally relative symlinks into the repository's blobs/
 * directory, so rejecting every symlink would reject the canonical layout.
 * Instead, reject symlinked parents, absolute targets, and targets escaping the
 * exact repository's blobs directory. */
function validateLocalFile(
  snapshot: string,
  blobsDir: string,
  file: RepoFile,
): { path: string; size: number } {
  if (!isSafeRepoFilename(file.rfilename)) fail(`unsafe repository path ${JSON.stringify(file.rfilename)}`);
  const localPath = resolve(snapshot, file.rfilename);
  if (!isWithin(snapshot, localPath)) fail(`repository path escapes snapshot: ${JSON.stringify(file.rfilename)}`);

  let cursor = snapshot;
  const segments = file.rfilename.split("/");
  for (const segment of segments.slice(0, -1)) {
    cursor = join(cursor, segment);
    if (!existsSync(cursor)) fail(`missing parent directory for ${file.rfilename}`);
    const st = lstatSync(cursor);
    if (st.isSymbolicLink()) fail(`symlinked parent directory for ${file.rfilename}`);
    if (!st.isDirectory()) fail(`non-directory parent for ${file.rfilename}`);
  }

  if (!existsSync(localPath)) fail(`snapshot is missing ${file.rfilename}`);
  const lst = lstatSync(localPath);
  if (lst.isSymbolicLink()) {
    const target = readlinkSync(localPath);
    if (isAbsolute(target)) fail(`absolute symlink target for ${file.rfilename}`);
    const lexicalTarget = resolve(dirname(localPath), target);
    if (!isWithin(resolve(blobsDir), lexicalTarget)) fail(`symlink for ${file.rfilename} escapes repository blobs`);
    const realTarget = realpathSync(localPath);
    const realBlobs = realpathSync(blobsDir);
    if (!isWithin(realBlobs, realTarget)) fail(`resolved symlink for ${file.rfilename} escapes repository blobs`);
  } else if (!lst.isFile()) {
    fail(`snapshot entry is not a regular file or safe HF blob symlink: ${file.rfilename}`);
  } else {
    const realLocal = realpathSync(localPath);
    const realSnapshot = realpathSync(snapshot);
    if (!isWithin(realSnapshot, realLocal)) fail(`regular file escapes snapshot: ${file.rfilename}`);
  }

  const size = statSync(localPath).size;
  if (!Number.isSafeInteger(file.size) || file.size < 0) fail(`invalid authoritative size for ${file.rfilename}`);
  if (size !== file.size) fail(`size mismatch for ${file.rfilename}: expected ${file.size}, found ${size}`);
  return { path: localPath, size };
}

async function hashFile(path: string): Promise<string> {
  const hasher = new Bun.CryptoHasher("sha256");
  for await (const chunk of createReadStream(path, { highWaterMark: 8 * 2 ** 20 })) {
    hasher.update(chunk as Buffer);
  }
  return hasher.digest("hex");
}

function sha256Bytes(bytes: Uint8Array): string {
  return new Bun.CryptoHasher("sha256").update(bytes).digest("hex");
}

interface PriorDigest {
  path: string;
  bytes: number;
  computed: string;
}

function loadPriorEvidence(
  path: string,
  repo: string,
  revision: string,
): { schema: 1 | 2; sha256: string; digests: Map<string, PriorDigest> } {
  const bytes = readFileSync(path);
  let raw: Record<string, unknown>;
  try {
    raw = JSON.parse(bytes.toString("utf8")) as Record<string, unknown>;
  } catch {
    fail(`prior evidence is not valid JSON: ${path}`);
  }
  const schema = raw.schema_version;
  if (schema !== 1 && schema !== 2) fail(`unsupported prior evidence schema: ${String(schema)}`);
  if (raw.repo !== repo) fail(`prior evidence repo does not match ${repo}`);
  const priorRequested = schema === 1 ? raw.revision : raw.requested_revision;
  const priorResolved = raw.resolved_revision;
  if (priorRequested !== revision || priorResolved !== revision) fail(`prior evidence revision does not match ${revision}`);
  if (raw.all_match !== true) fail("prior evidence is not an all-match result");
  if (!Array.isArray(raw.files)) fail("prior evidence files are missing");

  const digests = new Map<string, PriorDigest>();
  for (const item of raw.files) {
    if (!item || typeof item !== "object") fail("malformed prior evidence file entry");
    const record = item as Record<string, unknown>;
    const filePath = record.path;
    if (typeof filePath !== "string" || !isSafeRepoFilename(filePath)) fail("unsafe or missing path in prior evidence");
    if (digests.has(filePath)) fail(`duplicate path in prior evidence: ${filePath}`);
    const size = record.bytes;
    if (typeof size !== "number" || !Number.isSafeInteger(size) || size < 0) fail(`invalid prior size for ${filePath}`);
    const computed = normalizeSha256(schema === 1 ? record.sha256 : record.computed_sha256, `prior digest for ${filePath}`);
    if (schema === 2) {
      const expected = normalizeSha256(record.expected_sha256, `prior expected digest for ${filePath}`);
      if (expected !== computed || record.match !== true) fail(`prior evidence contains a mismatch for ${filePath}`);
    }
    digests.set(filePath, { path: filePath, bytes: size, computed });
  }
  if (raw.files_verified !== digests.size) fail("prior evidence files_verified is inconsistent");
  const bytesVerified = [...digests.values()].reduce((sum, file) => sum + file.bytes, 0);
  if (raw.bytes_verified !== bytesVerified) fail("prior evidence bytes_verified is inconsistent");
  return { schema, sha256: sha256Bytes(bytes), digests };
}

function checkerCommand(options: Required<Pick<ArtifactVerifierOptions, "repo" | "revision" | "snapshot">> & ArtifactVerifierOptions): string[] {
  const mode = options.mode ?? "hash";
  const command = [
    "bun", SOURCE,
    "--repo", options.repo,
    "--revision", options.revision,
    "--snapshot", options.snapshot,
    "--mode", mode,
  ];
  if (options.priorEvidence) command.push("--prior-evidence", options.priorEvidence);
  if (options.snapshotLabel) command.push("--snapshot-label", options.snapshotLabel);
  if (options.endpoint && options.endpoint !== "https://huggingface.co") command.push("--endpoint", options.endpoint);
  return command;
}

export async function verifyArtifact(options: ArtifactVerifierOptions): Promise<ArtifactEvidenceV2> {
  if (!REPO_RE.test(options.repo)) fail(`invalid repository id ${JSON.stringify(options.repo)}`);
  const revision = normalizeRevision(options.revision, "--revision");
  const mode = options.mode ?? "hash";
  if (mode !== "hash" && mode !== "prior-evidence") fail(`invalid mode ${JSON.stringify(mode)}`);
  if (mode === "prior-evidence" && !options.priorEvidence) fail("--prior-evidence is required in prior-evidence mode");
  if (mode === "hash" && options.priorEvidence) fail("--prior-evidence is only valid in prior-evidence mode");

  const endpoint = (options.endpoint ?? "https://huggingface.co").replace(/\/$/, "");
  const { snapshot, blobsDir } = validateSnapshotRoot(options.snapshot, revision, options.repo);
  const listing = await listRepoFiles(options.repo, {
    revision,
    endpoint,
    token: options.token === undefined ? hfToken() : options.token,
  });
  const resolvedRevision = normalizeRevision(listing.sha, "HF API resolved revision");
  if (resolvedRevision !== revision) fail(`HF API resolved ${revision} to unexpected ${resolvedRevision}`);

  const names = new Set<string>();
  for (const file of listing.files) {
    if (!isSafeRepoFilename(file.rfilename)) fail(`unsafe repository path ${JSON.stringify(file.rfilename)}`);
    if (names.has(file.rfilename)) fail(`duplicate repository path ${file.rfilename}`);
    names.add(file.rfilename);
    // The API cannot authoritatively prove payload content without an LFS
    // SHA-256. Refuse likely model payloads if their lfs object disappears
    // entirely due to API/schema drift; otherwise fresh mode could silently
    // omit exactly the files this report exists to verify.
    const likelyLfsPayload = file.size >= 10 * 2 ** 20
      || /\.(?:safetensors|bin|gguf|pt|pth|onnx)$/i.test(file.rfilename);
    if (likelyLfsPayload && !file.lfs) {
      fail(`authoritative LFS sha256 is missing for likely payload ${file.rfilename}`);
    }
    validateLocalFile(snapshot, blobsDir, file);
  }

  const lfsFiles = listing.files
    .filter((file) => file.lfs !== undefined)
    .sort((a, b) => a.rfilename.localeCompare(b.rfilename));
  if (lfsFiles.length === 0) fail("exact-revision API listing has no LFS payload metadata");

  let prior: ReturnType<typeof loadPriorEvidence> | null = null;
  if (mode === "prior-evidence") prior = loadPriorEvidence(options.priorEvidence!, options.repo, revision);
  if (prior && prior.digests.size !== lfsFiles.length) {
    fail(`prior evidence file set has ${prior.digests.size} files; exact-revision API has ${lfsFiles.length} LFS files`);
  }

  const files: ArtifactEvidenceFile[] = [];
  for (const file of lfsFiles) {
    const expected = normalizeSha256(file.lfs?.sha256, `authoritative LFS digest for ${file.rfilename}`);
    if (file.lfs!.size !== file.size) fail(`inconsistent authoritative LFS size for ${file.rfilename}`);
    const computed = prior
      ? (() => {
          const priorFile = prior!.digests.get(file.rfilename);
          if (!priorFile) fail(`prior evidence is missing ${file.rfilename}`);
          if (priorFile.bytes !== file.size) fail(`prior evidence size mismatch for ${file.rfilename}`);
          return priorFile.computed;
        })()
      : await hashFile(join(snapshot, file.rfilename));
    if (computed !== expected) fail(`SHA-256 mismatch for ${file.rfilename}: expected ${expected}, computed ${computed}`);
    files.push({
      path: file.rfilename,
      bytes: file.size,
      expected_sha256: expected,
      computed_sha256: computed,
      match: true,
      computed_evidence: prior ? "prior_computed_evidence" : "fresh_payload_hash",
    });
  }

  if (prior) {
    for (const priorPath of prior.digests.keys()) {
      if (!names.has(priorPath) || !lfsFiles.some((file) => file.rfilename === priorPath)) {
        fail(`prior evidence has unexpected non-LFS path ${priorPath}`);
      }
    }
  }

  const canonicalOptions = { ...options, revision, snapshot, mode };
  return {
    schema_version: 2,
    evidence_kind: "hf_lfs_artifact_integrity",
    repo: options.repo,
    requested_revision: revision,
    resolved_revision: revision,
    snapshot_revision: revision,
    snapshot_label: options.snapshotLabel ?? "HF cache exact revision",
    verification_mode: prior ? "prior_computed_evidence" : "fresh_payload_hash",
    checker: {
      identity: IDENTITY,
      source: SOURCE,
      source_sha256: sha256Bytes(readFileSync(fileURLToPath(import.meta.url))),
      command: checkerCommand(canonicalOptions),
      hashes_payloads: !prior,
      prior_evidence: prior ? {
        path: options.priorEvidence!,
        schema_version: prior.schema,
        sha256: prior.sha256,
      } : null,
    },
    authoritative_metadata: {
      source: "huggingface_model_api_exact_revision",
      request: `${endpoint}/api/models/${options.repo}/revision/${revision}?blobs=true`,
      repository_files: listing.files.length,
      lfs_files: lfsFiles.length,
    },
    files_verified: files.length,
    bytes_verified: files.reduce((sum, file) => sum + file.bytes, 0),
    all_match: true,
    files,
  };
}

function parseArgs(argv: string[]): ArtifactVerifierOptions & { out?: string } {
  const values = new Map<string, string>();
  const valid = new Set([
    "--repo", "--revision", "--snapshot", "--mode", "--prior-evidence",
    "--snapshot-label", "--endpoint", "--out",
  ]);
  for (let i = 0; i < argv.length; i += 2) {
    const flag = argv[i];
    const value = argv[i + 1];
    if (!flag || !valid.has(flag) || value === undefined || value.startsWith("--")) fail(`invalid arguments near ${flag ?? "<end>"}`);
    if (values.has(flag)) fail(`duplicate argument ${flag}`);
    values.set(flag, value);
  }
  for (const required of ["--repo", "--revision", "--snapshot"]) {
    if (!values.has(required)) fail(`missing required argument ${required}`);
  }
  return {
    repo: values.get("--repo")!,
    revision: values.get("--revision")!,
    snapshot: values.get("--snapshot")!,
    mode: (values.get("--mode") ?? "hash") as ArtifactVerificationMode,
    priorEvidence: values.get("--prior-evidence"),
    snapshotLabel: values.get("--snapshot-label"),
    endpoint: values.get("--endpoint"),
    out: values.get("--out"),
  };
}

export async function main(argv = process.argv.slice(2)): Promise<void> {
  const options = parseArgs(argv);
  const report = await verifyArtifact(options);
  const json = `${JSON.stringify(report, null, 2)}\n`;
  if (!options.out) {
    process.stdout.write(json);
    return;
  }
  const out = resolve(options.out);
  mkdirSync(dirname(out), { recursive: true });
  const temp = `${out}.tmp-${process.pid}`;
  try {
    await Bun.write(temp, json);
    renameSync(temp, out);
  } finally {
    rmSync(temp, { force: true });
  }
}

if (import.meta.main) {
  main().catch((error) => {
    console.error(error instanceof Error ? error.message : String(error));
    process.exitCode = 1;
  });
}
