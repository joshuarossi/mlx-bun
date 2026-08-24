// Reduce prompt-to-response JSONL traces into the additive medians used by the
// side-by-side waterfall. Raw traces remain the source of truth.

export {};

type Arm = "mlx-bun" | "mlx-bun-serial" | "mlx-lm";
type CacheState = "miss" | "full" | "partial";

interface TraceEvent {
  phase: string;
  startMs: number;
  durationMs: number;
}

interface Sample {
  model: string;
  modelLabel: string;
  arm: Arm;
  cacheState: CacheState;
  targetTokens: number;
  promptTokens: number;
  maxTokens: number;
  run: number;
  clientTtftMs: number;
  trace: {
    events: TraceEvent[];
  };
}

interface StageSample {
  ingress: number | null;
  prompt: number;
  queue: number;
  cache: number;
  batch: number;
  chunks: number;
  kv: number;
  prefillGaps: number;
  token0: number;
  response: number;
  otherServer: number;
  client: number;
}

const args = process.argv.slice(2);
if (args.length < 3) {
  throw new Error(
    "usage: bun scripts/summarize-p2r-waterfall.ts PRODUCT.jsonl ATTRIBUTION.jsonl OUTPUT.json",
  );
}

const [productPath, attributionPath, outputPath] = args as [string, string, string];

const median = (values: number[]): number => {
  const xs = [...values].sort((a, b) => a - b);
  const mid = xs.length >> 1;
  return xs.length % 2 ? xs[mid]! : (xs[mid - 1]! + xs[mid]!) / 2;
};

const round = (value: number): number => Math.round(value * 1000) / 1000;

function events(sample: Sample, phase: string): TraceEvent[] {
  return sample.trace.events.filter((event) => event.phase === phase);
}

function duration(sample: Sample, phase: string): number {
  return events(sample, phase).reduce((sum, event) => sum + event.durationMs, 0);
}

function firstStart(sample: Sample, phase: string): number | null {
  return events(sample, phase)[0]?.startMs ?? null;
}

function firstResponseStart(sample: Sample): number {
  return firstStart(sample, "response.first_write")
    ?? firstStart(sample, "response.final_write")
    ?? sample.clientTtftMs;
}

function additiveStages(sample: Sample): StageSample {
  const ingressEvents = events(sample, "request.body_parse");
  const ingress = ingressEvents.length
    ? ingressEvents.reduce((sum, event) => sum + event.durationMs, 0)
    : null;
  const prompt = duration(sample, "request.prompt_prepare");
  const queue = duration(sample, "completion.placement")
    + duration(sample, "engine.admission_wait");
  const cache = duration(sample, "cache.lookup_restore");
  const batch = duration(sample, "prefill.batch_setup");
  const chunks = duration(sample, "prefill.chunk");
  const kv = duration(sample, "prefill.kv_maintenance");
  const prefill = duration(sample, "prefill.total");
  const prefillGaps = Math.max(0, prefill - batch - chunks - kv);
  const token0 = duration(sample, "token_zero.total");
  const responseAt = firstResponseStart(sample);
  const tokenEvent = events(sample, "token_zero.total")[0];
  const tokenEnd = tokenEvent ? tokenEvent.startMs + tokenEvent.durationMs : responseAt;
  const response = Math.max(0, responseAt - tokenEnd);
  const knownServer = (ingress ?? 0) + prompt + queue + cache + prefill + token0 + response;
  const otherServer = Math.max(0, responseAt - knownServer);
  const client = Math.max(0, sample.clientTtftMs - responseAt);
  return {
    ingress,
    prompt,
    queue,
    cache,
    batch,
    chunks,
    kv,
    prefillGaps,
    token0,
    response,
    otherServer,
    client,
  };
}

async function readJsonl(path: string): Promise<Sample[]> {
  const text = await Bun.file(path).text();
  return text.trim().split("\n").filter(Boolean).map((line) => JSON.parse(line) as Sample);
}

const inputs = [
  { mode: "product", samples: await readJsonl(productPath) },
  { mode: "attribution", samples: await readJsonl(attributionPath) },
];

const groups = new Map<string, { mode: string; samples: Sample[] }>();
for (const input of inputs) {
  for (const sample of input.samples) {
    // Decode-64 observations share the `miss` cache label but are not TTFT
    // waterfall repetitions. Keep only the one-token prefill attribution rows.
    if (sample.maxTokens !== 1) continue;
    const key = [
      input.mode,
      sample.model,
      sample.arm,
      sample.cacheState,
      sample.targetTokens,
    ].join("\t");
    const group = groups.get(key) ?? { mode: input.mode, samples: [] };
    group.samples.push(sample);
    groups.set(key, group);
  }
}

const rows = [...groups.values()].map(({ mode, samples }) => {
  const first = samples[0]!;
  const stageSamples = samples.map(additiveStages);
  const stageKeys = Object.keys(stageSamples[0]!) as (keyof StageSample)[];
  const stages = Object.fromEntries(stageKeys.map((key) => {
    const values = stageSamples
      .map((sample) => sample[key])
      .filter((value): value is number => value !== null);
    return [key, values.length ? round(median(values)) : null];
  }));
  const totals = samples.map((sample) => sample.clientTtftMs);
  const chunks = samples.map((sample) => events(sample, "prefill.chunk").map((event) => event.durationMs));
  const maxChunks = Math.max(...chunks.map((values) => values.length));
  const chunkMedians = Array.from({ length: maxChunks }, (_, index) => {
    const values = chunks.map((row) => row[index]).filter((value): value is number => value !== undefined);
    return round(median(values));
  });
  return {
    mode,
    model: first.model,
    label: first.modelLabel,
    arm: first.arm,
    cache: first.cacheState,
    target: first.targetTokens,
    measured: Math.round(median(samples.map((sample) => sample.promptTokens))),
    n: samples.length,
    total: round(median(totals)),
    min: round(Math.min(...totals)),
    max: round(Math.max(...totals)),
    stages,
    chunks: chunkMedians,
  };
}).sort((a, b) =>
  a.mode.localeCompare(b.mode)
  || a.model.localeCompare(b.model)
  || a.cache.localeCompare(b.cache)
  || a.target - b.target
  || a.arm.localeCompare(b.arm)
);

await Bun.write(outputPath, JSON.stringify({
  generatedAt: new Date().toISOString(),
  productPath,
  attributionPath,
  rows,
}, null, 2) + "\n");

console.log(`${rows.length} grouped rows -> ${outputPath}`);
