// Model registry: bun:sqlite index over the HF cache. Answers questions
// like "vision-capable models under 10 GB" without shell archaeology.
//
// scan() walks ~/.cache/huggingface/hub/models--*/snapshots/*, reading
// only config.json + the safetensors index header (never tensor bytes).

import { Database } from "bun:sqlite";
import {
  closeSync, existsSync, openSync, readdirSync, readFileSync, readSync, statSync,
} from "node:fs";
import { join } from "node:path";

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
  has_kv_config INTEGER NOT NULL,
  has_tool_template INTEGER NOT NULL,
  num_layers INTEGER,
  hidden_size INTEGER,
  vocab_size INTEGER,
  license TEXT,
  scanned_at INTEGER NOT NULL
);
`;

export const DEFAULT_HUB = `${process.env.HOME}/.cache/huggingface/hub`;
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
      !cols.includes("license")
    ) {
      this.db.exec("DROP TABLE models");
      this.db.exec(SCHEMA);
    }
  }

  async scan(hubDir: string = DEFAULT_HUB): Promise<number> {
    if (!existsSync(hubDir)) return 0;
    let count = 0;
    const upsert = this.db.prepare(`
      INSERT OR REPLACE INTO models VALUES
      ($path, $repo, $type, $params, $size, $sidecar, $experts, $bits, $gs, $mode,
       $vision, $kv, $tools, $layers, $hidden, $vocab, $license, $at)
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
      clauses.push("has_vision_sidecar = $vision");
      params.$vision = filter.vision ? 1 : 0;
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
    return rows.map(rowToRecord);
  }

  /** Resolve a fuzzy query to exactly one model (error listing candidates otherwise). */
  resolve(query: string): ModelRecord {
    const matches = this.list({ query });
    if (matches.length === 1) return matches[0]!;
    if (matches.length === 0) throw new Error(`no model matching "${query}" — run \`mlx-bun scan\``);
    throw new Error(
      `"${query}" is ambiguous:\n` + matches.map((m) => `  ${m.repoId}`).join("\n"),
    );
  }

  close(): void {
    this.db.close();
  }
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
    hasKvConfig: existsSync(join(dir, "kv_config.json")),
    hasToolTemplate,
    numLayers: text.num_hidden_layers ?? null,
    hiddenSize: text.hidden_size ?? null,
    vocabSize: text.vocab_size ?? null,
    license: readmeLicense(dir),
    scannedAt: Date.now(),
  };
}
