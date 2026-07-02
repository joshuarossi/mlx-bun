// Model registry: bun:sqlite index over the HF cache. Answers questions
// like "vision-capable models under 10 GB" without shell archaeology.
//
// scan() walks ~/.cache/huggingface/hub/models--*/snapshots/*, reading
// only config.json + the safetensors index header (never tensor bytes).

import { Database } from "bun:sqlite";
import {
  closeSync, existsSync, lstatSync, openSync, readdirSync, readFileSync,
  readlinkSync, readSync, rmSync, statSync,
} from "node:fs";
import { join } from "node:path";
import { isDrafterModelType } from "./model/support";

export interface ModelRecord {
  path: string;
  repoId: string;
  modelType: string;
  paramCount: number | null;
  /** Language-model weight bytes (model-*.safetensors, sidecar excluded). */
  sizeBytes: number;
  /** optiq_vision.safetensors bytes (bf16 sidecar; loads only for vision). */
  sidecarBytes: number;
  /** Bytes of `.experts.` tensors (MoE; 0 for dense models). Per-token
   *  decode only reads top_k/num_experts of these. */
  expertsBytes: number;
  quantBits: number | null;
  quantGroupSize: number | null;
  quantMode: string | null;
  hasVisionSidecar: boolean;
  /** config.json's vision_config.model_type when it names a vision tower
   *  (e.g. "gemma4_vision" — SigLIP, needs the bf16 sidecar — or
   *  "gemma4_unified_vision" — encoder-free). null for text-only models
   *  AND for configs whose nested vision_config is not a vision tower
   *  (Qwen3.5 nests a copy of its own text config there). */
  visionConfigType: string | null;
  hasKvConfig: boolean;
  hasToolTemplate: boolean;
  numLayers: number | null;
  hiddenSize: number | null;
  vocabSize: number | null;
  /** SPDX-ish license id from the model card's README frontmatter
   *  (e.g. "gemma" — custom terms — vs "apache-2.0"); null if absent.
   *  Surfaces license obligations per model in `ls`/`fit` output. */
  license: string | null;
  scannedAt: number;
}

const SCHEMA = `
CREATE TABLE IF NOT EXISTS models (
  path TEXT PRIMARY KEY,
  repo_id TEXT NOT NULL,
  model_type TEXT NOT NULL,
  param_count INTEGER,
  size_bytes INTEGER NOT NULL,
  sidecar_bytes INTEGER NOT NULL DEFAULT 0,
  experts_bytes INTEGER NOT NULL DEFAULT 0,
  quant_bits INTEGER,
  quant_group_size INTEGER,
  quant_mode TEXT,
  has_vision_sidecar INTEGER NOT NULL,
  vision_config_type TEXT,
  has_kv_config INTEGER NOT NULL,
  has_tool_template INTEGER NOT NULL,
  num_layers INTEGER,
  hidden_size INTEGER,
  vocab_size INTEGER,
  license TEXT,
  scanned_at INTEGER NOT NULL
);
`;

/** HF hub cache root, honoring the standard env overrides the same way
 *  huggingface_hub (and our server.ts) do: HF_HUB_CACHE > HF_HOME/hub >
 *  ~/.cache/huggingface/hub. */
export const DEFAULT_HUB =
  process.env.HF_HUB_CACHE ??
  (process.env.HF_HOME
    ? join(process.env.HF_HOME, "hub")
    : `${process.env.HOME}/.cache/huggingface/hub`);
export const DEFAULT_DB = `${process.env.HOME}/.cache/mlx-bun/registry.sqlite`;

export class Registry {
  readonly db: Database;

  constructor(dbPath: string = DEFAULT_DB) {
    if (dbPath !== ":memory:") {
      const dir = dbPath.slice(0, dbPath.lastIndexOf("/"));
      try { require("node:fs").mkdirSync(dir, { recursive: true }); } catch {}
    }
    this.db = new Database(dbPath);
    this.db.exec(SCHEMA);
    // The registry is a derived cache — on schema drift, rebuild from scratch.
    const cols = (this.db.query("PRAGMA table_info(models)").all() as { name: string }[])
      .map((c) => c.name);
    if (
      !cols.includes("sidecar_bytes") ||
      !cols.includes("experts_bytes") ||
      !cols.includes("license") ||
      !cols.includes("vision_config_type")
    ) {
      this.db.exec("DROP TABLE models");
      this.db.exec(SCHEMA);
    }
  }

  async scan(hubDir: string = DEFAULT_HUB): Promise<number> {
    if (!existsSync(hubDir)) return 0;
    // The cache is the source of truth and we only ever INSERT, so reap rows
    // whose snapshot dir was deleted (else they linger as phantom matches).
    const prune = this.db.prepare("DELETE FROM models WHERE path = $path");
    for (const r of this.db.query("SELECT path FROM models").all() as { path: string }[])
      if (!existsSync(r.path)) prune.run({ $path: r.path });
    let count = 0;
    const upsert = this.db.prepare(`
      INSERT OR REPLACE INTO models VALUES
      ($path, $repo, $type, $params, $size, $sidecar, $experts, $bits, $gs, $mode,
       $vision, $vtype, $kv, $tools, $layers, $hidden, $vocab, $license, $at)
    `);
    for (const entry of readdirSync(hubDir)) {
      if (!entry.startsWith("models--")) continue;
      const repoId = entry.slice("models--".length).replaceAll("--", "/");
      const snapsDir = join(hubDir, entry, "snapshots");
      if (!existsSync(snapsDir)) continue;
      for (const snap of readdirSync(snapsDir)) {
        const dir = join(snapsDir, snap);
        const rec = await scanSnapshot(dir, repoId);
        if (!rec) continue;
        upsert.run({
          $path: rec.path, $repo: rec.repoId, $type: rec.modelType,
          $params: rec.paramCount, $size: rec.sizeBytes,
          $sidecar: rec.sidecarBytes, $experts: rec.expertsBytes,
          $bits: rec.quantBits, $gs: rec.quantGroupSize, $mode: rec.quantMode,
          $vision: rec.hasVisionSidecar ? 1 : 0,
          $vtype: rec.visionConfigType,
          $kv: rec.hasKvConfig ? 1 : 0,
          $tools: rec.hasToolTemplate ? 1 : 0,
          $layers: rec.numLayers, $hidden: rec.hiddenSize, $vocab: rec.vocabSize,
          $license: rec.license, $at: rec.scannedAt,
        });
        count++;
      }
    }
    return count;
  }

  list(filter: { vision?: boolean; maxBytes?: number; query?: string } = {}): ModelRecord[] {
    const clauses: string[] = [];
    const params: Record<string, unknown> = {};
    if (filter.vision !== undefined) {
      // Vision-capable = SigLIP sidecar present OR the encoder-free unified
      // tower declared in config.json (12B ships no sidecar upstream anymore).
      // COALESCE: NULL vision_config_type must read as "no", not SQL-NULL
      // (a bare NULL LIKE poisons the NOT branch of the filter).
      const cap = "(has_vision_sidecar = 1 OR COALESCE(vision_config_type,'') LIKE '%unified_vision')";
      clauses.push(filter.vision ? cap : `NOT ${cap}`);
    }
    if (filter.maxBytes !== undefined) {
      clauses.push("size_bytes <= $max");
      params.$max = filter.maxBytes;
    }
    if (filter.query) {
      clauses.push("(repo_id LIKE $q OR model_type LIKE $q)");
      params.$q = `%${filter.query}%`;
    }
    const where = clauses.length ? `WHERE ${clauses.join(" AND ")}` : "";
    const rows = this.db
      .query(`SELECT * FROM models ${where} ORDER BY size_bytes ASC`)
      .all(params as never) as Record<string, unknown>[];
    // Self-heal: never surface a row whose snapshot dir was deleted out from
    // under us (scan() reaps these from the DB; this keeps reads correct even
    // before the next scan).
    return rows.map(rowToRecord).filter((r) => existsSync(r.path));
  }

  /** list(), collapsed to ONE record per repo: the canonical snapshot
   *  (refs/main, else most recently scanned). Upstream pushes create a new
   *  snapshots/<commit> dir per revision and the old ones are never deleted,
   *  so raw list() shows a row per revision — this is the user-facing view
   *  (`ls`, /v1/models, /library). Order follows list() (size ascending). */
  listCanonical(filter: Parameters<Registry["list"]>[0] = {}): ModelRecord[] {
    const byRepo = new Map<string, ModelRecord[]>();
    const order: string[] = [];
    for (const m of this.list(filter)) {
      if (!byRepo.has(m.repoId)) {
        byRepo.set(m.repoId, []);
        order.push(m.repoId);
      }
      byRepo.get(m.repoId)!.push(m);
    }
    return order.map((repo) => pickCanonicalRevision(byRepo.get(repo)!));
  }

  /** Resolve a fuzzy query to exactly one model (error listing candidates otherwise).
   *  Speculative-decoding drafters are companion artifacts, never selectable on
   *  their own, so they never count as candidates here. */
  resolve(query: string): ModelRecord {
    const matches = this.list({ query }).filter((m) => !isDrafterModelType(m.modelType));
    if (matches.length === 0) throw new Error(`no model matching "${query}" — run \`mlx-bun scan\``);
    // The HF cache can hold several revisions of one repo (snapshots/<hash>
    // dirs), each a registry row. Resolving a repo name must not be "ambiguous"
    // just because a stale revision lingers — collapse same-repo matches to the
    // canonical snapshot. Genuinely different repos stay ambiguous.
    const repos = [...new Set(matches.map((m) => m.repoId))];
    if (repos.length === 1) return pickCanonicalRevision(matches);
    throw new Error(`"${query}" is ambiguous:\n` + repos.map((r) => `  ${r}`).join("\n"));
  }

  close(): void {
    this.db.close();
  }
}

/** True when the model can answer vision requests: it either ships the bf16
 *  SigLIP sidecar (gemma4_vision: e2b/e4b/26B/31B) or declares the
 *  encoder-free unified tower in config.json (gemma4_unified_vision: 12B). */
export function visionCapable(m: Pick<ModelRecord, "hasVisionSidecar" | "visionConfigType">): boolean {
  return m.hasVisionSidecar || (m.visionConfigType?.endsWith("unified_vision") ?? false);
}

/** Of several cached revisions of ONE repo, pick the canonical snapshot: the
 *  revision refs/main points at, else the most recently scanned (stable
 *  tie-break on path). Paths are `<hub>/models--<repo>/snapshots/<hash>`. */
export function pickCanonicalRevision(matches: ModelRecord[]): ModelRecord {
  if (matches.length === 1) return matches[0]!;
  const root = matches[0]!.path.split("/snapshots/")[0]!;
  try {
    const head = readFileSync(join(root, "refs", "main"), "utf8").trim();
    const onMain = matches.find((m) => m.path.includes(`/snapshots/${head}`));
    if (onMain) return onMain;
  } catch {
    /* no refs/main — fall through to recency */
  }
  return [...matches].sort(
    (a, b) => b.scannedAt - a.scannedAt || (a.path < b.path ? -1 : 1),
  )[0]!;
}

function rowToRecord(r: Record<string, unknown>): ModelRecord {
  return {
    path: r.path as string,
    repoId: r.repo_id as string,
    modelType: r.model_type as string,
    paramCount: r.param_count as number | null,
    sizeBytes: r.size_bytes as number,
    sidecarBytes: r.sidecar_bytes as number,
    expertsBytes: r.experts_bytes as number,
    quantBits: r.quant_bits as number | null,
    quantGroupSize: r.quant_group_size as number | null,
    quantMode: r.quant_mode as string | null,
    hasVisionSidecar: !!r.has_vision_sidecar,
    visionConfigType: (r.vision_config_type as string | null) ?? null,
    hasKvConfig: !!r.has_kv_config,
    hasToolTemplate: !!r.has_tool_template,
    numLayers: r.num_layers as number | null,
    hiddenSize: r.hidden_size as number | null,
    vocabSize: r.vocab_size as number | null,
    license: r.license as string | null,
    scannedAt: r.scanned_at as number,
  };
}

/** License id from the model card's README.md YAML frontmatter
 *  (`license:`; `license_name:` wins when license is "other"). */
function readmeLicense(dir: string): string | null {
  const p = join(dir, "README.md");
  if (!existsSync(p)) return null;
  try {
    const head = readFileSync(p, "utf8").slice(0, 4096);
    if (!head.startsWith("---")) return null;
    const end = head.indexOf("\n---", 3);
    const fm = end === -1 ? head : head.slice(0, end);
    const strip = (s: string) => s.trim().replace(/^['"]|['"]$/g, "");
    const lic = strip(/^license:\s*(.+)$/m.exec(fm)?.[1] ?? "");
    const name = /^license_name:\s*(.+)$/m.exec(fm)?.[1];
    if (lic === "other" && name) return strip(name);
    return lic || null;
  } catch {
    return null;
  }
}

/** Sum the byte sizes of `.experts.` tensors from a safetensors header
 *  (header JSON only — never touches tensor data). */
function expertTensorBytes(path: string): number {
  const fd = openSync(path, "r");
  try {
    const lenBuf = Buffer.alloc(8);
    readSync(fd, lenBuf, 0, 8, 0);
    const headerLen = Number(lenBuf.readBigUInt64LE(0));
    if (headerLen <= 0 || headerLen > 256 * 2 ** 20) return 0;
    const headerBuf = Buffer.alloc(headerLen);
    readSync(fd, headerBuf, 0, headerLen, 8);
    const header = JSON.parse(headerBuf.toString("utf8")) as Record<
      string, { data_offsets?: [number, number] }
    >;
    let bytes = 0;
    for (const [name, entry] of Object.entries(header)) {
      if (!name.includes(".experts.") || !entry.data_offsets) continue;
      bytes += entry.data_offsets[1] - entry.data_offsets[0];
    }
    return bytes;
  } finally {
    closeSync(fd);
  }
}

// ---------------------------------------------------------------------------
// gc: reclaim superseded snapshots + dead blobs.
//
// The HF cache layout keeps one snapshots/<commit> dir per downloaded
// revision and NEVER deletes old ones — every upstream push a `get` follows
// strands the previous snapshot (and any blobs only it references). gc keeps
// the snapshots refs/* point at, deletes the rest, then deletes blobs no
// surviving snapshot symlink targets.

export interface GcSkippedSnapshot {
  path: string;
  /** Files this snapshot has that NO kept snapshot has (relative names).
   *  Deleting it would delete the only copy — needs an explicit --force. */
  extraFiles: string[];
}

export interface GcRepoPlan {
  repoId: string;
  repoDir: string;
  /** Snapshots referenced by refs/* — never deleted. */
  keepSnapshots: string[];
  /** Unreferenced snapshots safe to delete (file set ⊆ kept snapshots'). */
  pruneSnapshots: string[];
  /** Unreferenced snapshots with files the kept set lacks — skipped unless
   *  force (their blobs count as live). */
  skippedSnapshots: GcSkippedSnapshot[];
  /** blobs/ entries no surviving snapshot links to. */
  deadBlobs: string[];
  reclaimBytes: number;
}

/** Relative paths of all files/symlinks under a snapshot dir. */
function snapshotFiles(snapDir: string): string[] {
  const out: string[] = [];
  const walk = (dir: string, prefix: string) => {
    for (const name of readdirSync(dir)) {
      const p = join(dir, name);
      const st = lstatSync(p);
      if (st.isDirectory()) walk(p, `${prefix}${name}/`);
      else out.push(`${prefix}${name}`);
    }
  };
  try { walk(snapDir, ""); } catch {}
  return out;
}

/** Blob basenames a snapshot's symlinks resolve to (within this repo). */
function snapshotBlobTargets(snapDir: string): Set<string> {
  const targets = new Set<string>();
  for (const rel of snapshotFiles(snapDir)) {
    const p = join(snapDir, rel);
    try {
      const t = readlinkSync(p); // throws for regular files — those aren't blobs
      const base = t.split("/").pop();
      if (base && t.includes("blobs")) targets.add(base);
    } catch {}
  }
  return targets;
}

/** Plan gc for one models--* repo dir. Conservative by construction:
 *  - no refs/ (or refs pointing at missing snapshots) → nothing is pruned;
 *  - an unreferenced snapshot carrying files the kept set lacks is only
 *    prunable under `force` (the live example: a stale snapshot whose
 *    optiq_vision.safetensors the canonical revision dropped);
 *  - blobs are dead only when NO surviving snapshot (kept or skipped)
 *    links to them. `.incomplete`/`.lock` resume artifacts are never touched. */
export function planRepoGc(repoDir: string, opts: { force?: boolean } = {}): GcRepoPlan {
  const entry = repoDir.split("/").pop() ?? "";
  const repoId = entry.slice("models--".length).replaceAll("--", "/");
  const plan: GcRepoPlan = {
    repoId, repoDir,
    keepSnapshots: [], pruneSnapshots: [], skippedSnapshots: [],
    deadBlobs: [], reclaimBytes: 0,
  };
  const snapsDir = join(repoDir, "snapshots");
  const refsDir = join(repoDir, "refs");
  if (!existsSync(snapsDir)) return plan;

  const refCommits = new Set<string>();
  if (existsSync(refsDir)) {
    for (const r of readdirSync(refsDir)) {
      try { refCommits.add(readFileSync(join(refsDir, r), "utf8").trim()); } catch {}
    }
  }

  const candidates: string[] = [];
  for (const snap of readdirSync(snapsDir)) {
    const p = join(snapsDir, snap);
    if (!lstatSync(p).isDirectory()) continue;
    (refCommits.has(snap) ? plan.keepSnapshots : candidates).push(p);
  }
  // No ref resolves to an existing snapshot → we cannot tell what's live.
  if (plan.keepSnapshots.length === 0) return plan;

  const keptFiles = new Set<string>();
  for (const k of plan.keepSnapshots) for (const f of snapshotFiles(k)) keptFiles.add(f);
  for (const c of candidates) {
    const extra = snapshotFiles(c).filter((f) => !keptFiles.has(f));
    if (extra.length > 0 && !opts.force) plan.skippedSnapshots.push({ path: c, extraFiles: extra });
    else plan.pruneSnapshots.push(c);
  }

  const live = new Set<string>();
  for (const s of [...plan.keepSnapshots, ...plan.skippedSnapshots.map((x) => x.path)])
    for (const b of snapshotBlobTargets(s)) live.add(b);
  const blobsDir = join(repoDir, "blobs");
  if (existsSync(blobsDir)) {
    for (const b of readdirSync(blobsDir)) {
      if (b.endsWith(".incomplete") || b.endsWith(".lock")) continue;
      if (live.has(b)) continue;
      const p = join(blobsDir, b);
      plan.deadBlobs.push(p);
      try { plan.reclaimBytes += lstatSync(p).size; } catch {}
    }
  }
  return plan;
}

export function planGc(hubDir: string = DEFAULT_HUB, opts: { force?: boolean } = {}): GcRepoPlan[] {
  if (!existsSync(hubDir)) return [];
  const plans: GcRepoPlan[] = [];
  for (const entry of readdirSync(hubDir)) {
    if (!entry.startsWith("models--")) continue;
    plans.push(planRepoGc(join(hubDir, entry), opts));
  }
  return plans;
}

/** Execute a plan: snapshot dirs first, then dead blobs. Returns totals. */
export function executeGc(plans: GcRepoPlan[]): {
  snapshots: number; blobs: number; reclaimedBytes: number;
} {
  let snapshots = 0, blobs = 0, reclaimedBytes = 0;
  for (const p of plans) {
    for (const s of p.pruneSnapshots) {
      rmSync(s, { recursive: true, force: true });
      snapshots++;
    }
    for (const b of p.deadBlobs) {
      try {
        const size = lstatSync(b).size;
        rmSync(b, { force: true });
        blobs++;
        reclaimedBytes += size;
      } catch {}
    }
  }
  return { snapshots, blobs, reclaimedBytes };
}

/** vision_config.model_type, but only when it actually names a vision tower
 *  (`*_vision`). Some text-only configs nest a serialized copy of themselves
 *  under vision_config (Qwen3.5 puts model_type "qwen3_5" there) — presence
 *  of the key alone is NOT a vision signal. */
function visionConfigTypeOf(config: Record<string, any>): string | null {
  const vt = (config.vision_config as Record<string, any> | undefined)?.model_type;
  return typeof vt === "string" && vt.endsWith("_vision") ? vt : null;
}

async function scanSnapshot(dir: string, repoId: string): Promise<ModelRecord | null> {
  const configPath = join(dir, "config.json");
  if (!existsSync(configPath)) return null;

  // size: sum of model safetensors (resolved through HF's blob symlinks).
  // The vision sidecar is its own line item — it loads only for vision
  // requests and must never be folded into language-weight fit math.
  let sizeBytes = 0;
  let sidecarBytes = 0;
  let expertsBytes = 0;
  let hasWeights = false;
  for (const f of readdirSync(dir)) {
    if (!f.endsWith(".safetensors")) continue;
    hasWeights = true;
    let bytes = 0;
    try { bytes = statSync(join(dir, f)).size; } catch {}
    if (f === "optiq_vision.safetensors") {
      sidecarBytes += bytes;
    } else {
      sizeBytes += bytes;
      try { expertsBytes += expertTensorBytes(join(dir, f)); } catch {}
    }
  }
  if (!hasWeights) return null;

  let config: Record<string, any>;
  try {
    config = (await Bun.file(configPath).json()) as Record<string, any>;
  } catch {
    return null;
  }
  const text = (config.text_config ?? config) as Record<string, any>;
  const quant = (config.quantization ?? config.quantization_config) as
    | Record<string, any> | undefined;

  let paramCount: number | null = null;
  const idxPath = join(dir, "model.safetensors.index.json");
  if (existsSync(idxPath)) {
    try {
      const idx = (await Bun.file(idxPath).json()) as any;
      paramCount = idx.metadata?.total_parameters ?? null;
    } catch {}
  }

  let hasToolTemplate = false;
  for (const tf of ["chat_template.jinja", "tokenizer_config.json"]) {
    const p = join(dir, tf);
    if (existsSync(p)) {
      try {
        const body = await Bun.file(p).text();
        if (body.includes("tool_call")) { hasToolTemplate = true; break; }
      } catch {}
    }
  }

  return {
    path: dir,
    repoId,
    modelType: (config.model_type as string) ?? "unknown",
    paramCount,
    sidecarBytes,
    expertsBytes,
    sizeBytes,
    quantBits: quant?.bits ?? null,
    quantGroupSize: quant?.group_size ?? null,
    quantMode: quant?.mode ?? (quant ? "affine" : null),
    hasVisionSidecar: existsSync(join(dir, "optiq_vision.safetensors")),
    visionConfigType: visionConfigTypeOf(config),
    hasKvConfig: existsSync(join(dir, "kv_config.json")),
    hasToolTemplate,
    numLayers: text.num_hidden_layers ?? null,
    hiddenSize: text.hidden_size ?? null,
    vocabSize: text.vocab_size ?? null,
    license: readmeLicense(dir),
    scannedAt: Date.now(),
  };
}
