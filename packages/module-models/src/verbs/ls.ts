import type { CliInvocation, ModelCatalog } from "@mlx-bun/app-core";
import { flag, gb, option, printer } from "./shared";

function parseSize(text: string): number {
  const match = /^(\d+(?:\.\d+)?)\s*(GB|MB|G|M)?$/i.exec(text.trim());
  if (!match) throw new Error(`bad size: ${text}`);
  return Number(match[1]) * (/^m/i.test(match[2] ?? "G") ? 2 ** 20 : 2 ** 30);
}

/** `ls`: the downloaded models, one canonical revision per repo unless every snapshot is asked for. */
export async function runLs(invocation: CliInvocation, catalog: Pick<ModelCatalog, "list">): Promise<number> {
  const print = printer(invocation), { terminal } = invocation, { style } = terminal;
  const maxSize = option(invocation, "max-size"), allRevisions = flag(invocation, "all-revisions");
  const query = invocation.positionals[0];
  // One row per repo by default: the HF cache keeps a snapshots/<commit> dir per downloaded revision, and re-getting
  // after an upstream push strands the old one; those are duplicates, not separate models. --all-revisions shows the
  // per-snapshot truth (canonical marked *).
  const models = await catalog.list({ companions: true, revisions: allRevisions ? "snapshots" : "canonical",
    ...(flag(invocation, "vision") ? { vision: true } : {}), ...(maxSize ? { maxBytes: parseSize(maxSize) } : {}), ...(query !== undefined ? { query } : {}) });
  if (models.length === 0) { print("no models match (try `mlx-bun scan`)"); return 0; }
  const capabilities = (model: (typeof models)[number]) => {
    const tier = model.details?.supportTier ?? null;
    return [tier ? `supported (${tier})` : `unsupported (${model.modelType})`, model.details?.vision ? "vision" : null,
      model.details?.tools ? "tools" : null, model.details?.kvQuant ? "kv-quant" : null].filter(Boolean).join(" · ");
  };
  terminal.heading("library");
  print();
  terminal.table([
    { header: "model", paint: cell => style.bold(cell) },
    ...(allRevisions ? [{ header: "revision" }] : []),
    { header: "size", align: "right" as const },
    { header: "params", align: "right" as const },
    { header: "quant" },
    { header: "license", paint: cell => style.dim(cell) },
    { header: "capabilities", paint: cell => style.dim(cell) },
  ], models.map(model => [
    model.id,
    ...(allRevisions ? [`${(model.details?.revision ?? "").slice(0, 12)}${model.details?.canonical ? " *" : ""}`] : []),
    gb(model.bytes),
    model.details?.parameters ? `${(model.details.parameters / 1e9).toFixed(1)}B` : "?",
    model.details?.quantBits ? `${model.details.quantBits}-bit g${model.details.quantGroupSize}` : "full",
    model.details?.license ?? "?",
    capabilities(model),
  ]));
  print();
  print(allRevisions
    ? style.dim(`  ${models.length} snapshot(s) · * = canonical (refs/main) · superseded snapshots: \`mlx-bun gc\``)
    : style.dim(`  ${models.length} model(s) · mlx-bun fit <query> for a memory assessment`));
  return 0;
}
