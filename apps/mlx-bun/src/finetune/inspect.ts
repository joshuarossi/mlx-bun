import { probeFormat } from "@mlx-bun/training/dataset";

/** Inspect a dataset directory before submit: counts + detected format. */
export async function inspectDataset(dataDir: string): Promise<{
  ok: boolean;
  n_train: number;
  n_valid: number;
  format: string;
  error?: string;
}> {
  try {
    const trainPath = `${dataDir}/train.jsonl`;
    if (!(await Bun.file(trainPath).exists()))
      return { ok: false, n_train: 0, n_valid: 0, format: "unknown", error: `${trainPath} not found` };
    const nTrain = await countAndProbe(trainPath);
    const validPath = `${dataDir}/valid.jsonl`;
    const nValid = (await Bun.file(validPath).exists()) ? await countAndProbe(validPath) : { n: 0, fmt: "" };
    return {
      ok: true,
      n_train: nTrain.n,
      n_valid: nValid.n,
      format: nTrain.fmt,
    };
  } catch (e) {
    return {
      ok: false, n_train: 0, n_valid: 0, format: "unknown",
      error: e instanceof Error ? e.message : String(e),
    };
  }
}

async function countAndProbe(path: string): Promise<{ n: number; fmt: string }> {
  const text = await Bun.file(path).text();
  const lines = text.split("\n").map((l) => l.trim()).filter(Boolean);
  let fmt = "unknown";
  if (lines.length > 0) fmt = probeFormat(JSON.parse(lines[0]!) as Record<string, unknown>);
  return { n: lines.length, fmt };
}

