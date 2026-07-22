import { afterAll, beforeEach, describe, expect, test } from "bun:test";
import {
  mkdirSync,
  mkdtempSync,
  rmSync,
  symlinkSync,
  unlinkSync,
  writeFileSync,
} from "node:fs";
import { dirname, join, relative } from "node:path";
import { tmpdir } from "node:os";
import { verifyArtifact } from "../scripts/verify-colibri-g0-artifact";

const REPO = "test/colibri-artifact";
const REVISION = "0123456789abcdef0123456789abcdef01234567";
const OTHER_REVISION = "1123456789abcdef0123456789abcdef01234567";
const config = new TextEncoder().encode('{"model_type":"test"}\n');
const weights = new Uint8Array(64 * 1024);
for (let i = 0; i < weights.length; i++) weights[i] = (i * 17 + 3) & 0xff;
const weightsSha = new Bun.CryptoHasher("sha256").update(weights).digest("hex");

type Sibling = {
  rfilename: string;
  size: number;
  blobId: string;
  lfs?: { sha256?: string; oid?: string; size: number };
};

let apiRevision = REVISION;
let siblings: Sibling[] = [];
const roots: string[] = [];

const server = Bun.serve({
  port: 0,
  fetch(req) {
    const url = new URL(req.url);
    if (url.pathname === `/api/models/${REPO}/revision/${REVISION}`) {
      return Response.json({ sha: apiRevision, siblings });
    }
    return new Response("not found", { status: 404 });
  },
});

const endpoint = `http://localhost:${server.port}`;

function resetListing(): void {
  apiRevision = REVISION;
  siblings = [
    { rfilename: "config.json", size: config.length, blobId: "a".repeat(40) },
    {
      rfilename: "weights/model.safetensors",
      size: weights.length,
      blobId: "b".repeat(40),
      lfs: { sha256: weightsSha, size: weights.length },
    },
  ];
}

function makeSnapshot(): { root: string; snapshot: string; configPath: string; weightsPath: string } {
  const root = mkdtempSync(join(tmpdir(), "mlx-bun-g0-artifact-"));
  roots.push(root);
  const repoDir = join(root, "models--test--colibri-artifact");
  const blobs = join(repoDir, "blobs");
  const snapshot = join(repoDir, "snapshots", REVISION);
  mkdirSync(blobs, { recursive: true });
  mkdirSync(join(snapshot, "weights"), { recursive: true });

  const configBlob = join(blobs, "config-blob");
  const weightsBlob = join(blobs, "weights-blob");
  writeFileSync(configBlob, config);
  writeFileSync(weightsBlob, weights);
  const configPath = join(snapshot, "config.json");
  const weightsPath = join(snapshot, "weights", "model.safetensors");
  symlinkSync(relative(dirname(configPath), configBlob), configPath);
  symlinkSync(relative(dirname(weightsPath), weightsBlob), weightsPath);
  return { root, snapshot, configPath, weightsPath };
}

function options(snapshot: string) {
  return { repo: REPO, revision: REVISION, snapshot, endpoint, token: null } as const;
}

function v1Evidence(): Record<string, unknown> {
  return {
    schema_version: 1,
    repo: REPO,
    revision: REVISION,
    resolved_revision: REVISION,
    snapshot_label: "old evidence",
    files_verified: 1,
    bytes_verified: weights.length,
    all_match: true,
    files: [{ path: "weights/model.safetensors", bytes: weights.length, sha256: weightsSha }],
  };
}

beforeEach(resetListing);
afterAll(() => {
  server.stop(true);
  for (const root of roots) rmSync(root, { recursive: true, force: true });
});

describe("Colibri G0 artifact verifier", () => {
  test("fresh mode hashes LFS payloads and emits deterministic schema-v2 evidence", async () => {
    const { snapshot } = makeSnapshot();
    const first = await verifyArtifact({ ...options(snapshot), mode: "hash", snapshotLabel: "test snapshot" });
    const second = await verifyArtifact({ ...options(snapshot), mode: "hash", snapshotLabel: "test snapshot" });

    expect(second).toEqual(first);
    expect(first.schema_version).toBe(2);
    expect(first.requested_revision).toBe(REVISION);
    expect(first.resolved_revision).toBe(REVISION);
    expect(first.authoritative_metadata).toEqual({
      source: "huggingface_model_api_exact_revision",
      request: `${endpoint}/api/models/${REPO}/revision/${REVISION}?blobs=true`,
      repository_files: 2,
      lfs_files: 1,
    });
    expect(first.checker.identity).toBe("mlx-bun-colibri-g0-artifact-verifier/v1");
    expect(first.checker.source_sha256).toMatch(/^[0-9a-f]{64}$/);
    expect(first.checker.hashes_payloads).toBe(true);
    expect(first.files).toEqual([{
      path: "weights/model.safetensors",
      bytes: weights.length,
      expected_sha256: weightsSha,
      computed_sha256: weightsSha,
      match: true,
      computed_evidence: "fresh_payload_hash",
    }]);
    expect(first.all_match).toBe(true);
  });

  test("upgrades prior computed evidence without rereading changed payload bytes", async () => {
    const { root, snapshot, weightsPath } = makeSnapshot();
    const priorPath = join(root, "artifact-v1.json");
    writeFileSync(priorPath, `${JSON.stringify(v1Evidence())}\n`);

    // A same-size mutation would fail fresh hashing. Prior mode deliberately
    // validates metadata/topology and reuses the explicitly labelled digest.
    const changed = weights.slice();
    changed[0] = changed[0]! ^ 0xff;
    writeFileSync(weightsPath, changed);

    const report = await verifyArtifact({
      ...options(snapshot),
      mode: "prior-evidence",
      priorEvidence: priorPath,
    });
    expect(report.verification_mode).toBe("prior_computed_evidence");
    expect(report.checker.hashes_payloads).toBe(false);
    expect(report.checker.prior_evidence?.schema_version).toBe(1);
    expect(report.checker.prior_evidence?.sha256).toMatch(/^[0-9a-f]{64}$/);
    expect(report.files[0]?.computed_evidence).toBe("prior_computed_evidence");

    await expect(verifyArtifact({ ...options(snapshot), mode: "hash" }))
      .rejects.toThrow(/SHA-256 mismatch/);
  });

  test("fails closed on prior digest mismatch or an incomplete prior file set", async () => {
    const { root, snapshot } = makeSnapshot();
    const priorPath = join(root, "bad-prior.json");
    const bad = v1Evidence();
    (bad.files as Array<Record<string, unknown>>)[0]!.sha256 = "0".repeat(64);
    writeFileSync(priorPath, JSON.stringify(bad));
    await expect(verifyArtifact({
      ...options(snapshot), mode: "prior-evidence", priorEvidence: priorPath,
    })).rejects.toThrow(/SHA-256 mismatch/);

    bad.files = [];
    bad.files_verified = 0;
    bad.bytes_verified = 0;
    writeFileSync(priorPath, JSON.stringify(bad));
    await expect(verifyArtifact({
      ...options(snapshot), mode: "prior-evidence", priorEvidence: priorPath,
    })).rejects.toThrow(/file set/);
  });

  test("fails closed when the exact-revision API resolves to a different commit", async () => {
    const { snapshot } = makeSnapshot();
    apiRevision = OTHER_REVISION;
    await expect(verifyArtifact(options(snapshot))).rejects.toThrow(/unexpected/);
  });

  test("fails closed on missing or malformed authoritative LFS digests", async () => {
    const { snapshot } = makeSnapshot();
    siblings[1]!.lfs = { size: weights.length };
    await expect(verifyArtifact(options(snapshot))).rejects.toThrow(/invalid LFS sha256/);
    siblings[1]!.lfs = { sha256: "not-a-digest", size: weights.length };
    await expect(verifyArtifact(options(snapshot))).rejects.toThrow(/invalid LFS sha256/);
    delete siblings[1]!.lfs;
    await expect(verifyArtifact(options(snapshot))).rejects.toThrow(/LFS sha256 is missing/);
  });

  test("rejects traversal paths and duplicate API entries before hashing", async () => {
    const { snapshot } = makeSnapshot();
    siblings.push({ rfilename: "../escape", size: 1, blobId: "c".repeat(40) });
    await expect(verifyArtifact(options(snapshot))).rejects.toThrow(/unsafe repository path/);

    resetListing();
    siblings.push({ ...siblings[0]! });
    await expect(verifyArtifact(options(snapshot))).rejects.toThrow(/duplicate repository path/);
  });

  test("allows canonical relative HF blob links but rejects escaping symlinks", async () => {
    const { root, snapshot, weightsPath } = makeSnapshot();
    expect((await verifyArtifact(options(snapshot))).all_match).toBe(true);

    const outside = join(root, "outside.bin");
    writeFileSync(outside, weights);
    unlinkSync(weightsPath);
    symlinkSync(relative(dirname(weightsPath), outside), weightsPath);
    await expect(verifyArtifact(options(snapshot))).rejects.toThrow(/escapes repository blobs/);
  });

  test("rejects a snapshot whose path is not pinned to the requested revision", async () => {
    const { snapshot } = makeSnapshot();
    const wrong = join(dirname(snapshot), OTHER_REVISION);
    mkdirSync(wrong);
    await expect(verifyArtifact(options(wrong))).rejects.toThrow(/must end in snapshots/);
  });

  test("rejects a cache snapshot belonging to a different repo", async () => {
    const { snapshot } = makeSnapshot();
    await expect(verifyArtifact({ ...options(snapshot), repo: "other/repo" }))
      .rejects.toThrow(/does not match/);
  });
});
