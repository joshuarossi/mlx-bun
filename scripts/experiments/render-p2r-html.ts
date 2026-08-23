// Render a self-contained prompt-to-response report from bench-prompt-response JSONL.
//
// Usage:
//   bun scripts/experiments/render-p2r-html.ts INPUT.jsonl OUTPUT.html [VALIDATION.jsonl]

// The JSONL remains the source of truth. This file deliberately embeds only
// grouped measurements and raw TTFT points, not full request traces.

export {};

type Arm = "mlx-bun" | "mlx-bun-serial" | "mlx-lm";
type CacheState = "miss" | "full" | "partial";

interface TraceEvent {
  phase: string;
  startMs: number;
  durationMs: number;
  attributes?: Record<string, string | number | boolean | null>;
}

interface Sample {
  timestamp: string;
  model: string;
  modelLabel: string;
  arm: Arm;
  cacheState: CacheState;
  targetTokens: number;
  promptTokens: number;
  completionTokens: number;
  maxTokens: number;
  run: number;
  clientTtftMs: number;
  clientTotalMs: number;
  trace: { events: TraceEvent[] };
}

interface Stages {
  ingress: number;
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

const [inputPath, outputPath, validationPath] = process.argv.slice(2);
if (!inputPath || !outputPath) {
  throw new Error("usage: bun scripts/experiments/render-p2r-html.ts INPUT.jsonl OUTPUT.html [VALIDATION.jsonl]");
}

const raw = await Bun.file(inputPath).text();
const samples = raw.trim().split("\n").filter(Boolean).map((line) => JSON.parse(line) as Sample);
if (!samples.length) throw new Error(`no samples in ${inputPath}`);

const esc = (value: string): string => value
  .replaceAll("&", "&amp;").replaceAll("<", "&lt;").replaceAll(">", "&gt;")
  .replaceAll('"', "&quot;").replaceAll("'", "&#39;");
const round = (value: number): number => Math.round(value * 1000) / 1000;
const sorted = (values: number[]): number[] => [...values].sort((a, b) => a - b);
const quantile = (values: number[], p: number): number => {
  const xs = sorted(values);
  if (!xs.length) return 0;
  const at = (xs.length - 1) * p;
  const lo = Math.floor(at);
  const hi = Math.ceil(at);
  return xs[lo]! + (xs[hi]! - xs[lo]!) * (at - lo);
};
const median = (values: number[]): number => quantile(values, 0.5);
const events = (sample: Sample, phase: string): TraceEvent[] =>
  sample.trace.events.filter((event) => event.phase === phase);
const duration = (sample: Sample, phase: string): number =>
  events(sample, phase).reduce((sum, event) => sum + event.durationMs, 0);
const firstStart = (sample: Sample, phase: string): number | null =>
  events(sample, phase)[0]?.startMs ?? null;
const firstResponseStart = (sample: Sample): number =>
  firstStart(sample, "response.first_write")
  ?? firstStart(sample, "response.final_write")
  ?? sample.clientTtftMs;

function additiveStages(sample: Sample): Stages {
  const ingress = duration(sample, "request.body_parse");
  const prompt = duration(sample, "request.prompt_prepare");
  const queue = duration(sample, "completion.placement") + duration(sample, "engine.admission_wait");
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
  const knownServer = ingress + prompt + queue + cache + prefill + token0 + response;
  const otherServer = Math.max(0, responseAt - knownServer);
  const client = Math.max(0, sample.clientTtftMs - responseAt);
  return { ingress, prompt, queue, cache, batch, chunks, kv, prefillGaps, token0, response, otherServer, client };
}

const prefillSamples = samples.filter((sample) => sample.maxTokens === 1);
const groups = new Map<string, Sample[]>();
for (const sample of prefillSamples) {
  const key = [sample.model, sample.arm, sample.cacheState, sample.targetTokens].join("\t");
  const group = groups.get(key) ?? [];
  group.push(sample);
  groups.set(key, group);
}

const phaseKeys = ["ingress", "prompt", "queue", "cache", "batch", "chunks", "kv", "prefillGaps", "token0", "response", "otherServer", "client"] as const;
function summarizePrefillGroup(group: Sample[]) {
  const first = group[0]!;
  const totals = group.map((sample) => sample.clientTtftMs);
  const stageRows = group.map(additiveStages);
  const stages = Object.fromEntries(phaseKeys.map((key) => [key, round(median(stageRows.map((row) => row[key])))]));
  const cached = group.map((sample) => Number(events(sample, "prefill.total")[0]?.attributes?.cachedTokens ?? 0));
  const prefill = group.map((sample) => duration(sample, "prefill.total"));
  const token0 = group.map((sample) => duration(sample, "token_zero.total"));
  return {
    model: first.model,
    label: first.modelLabel,
    arm: first.arm,
    cache: first.cacheState,
    target: first.targetTokens,
    measured: round(median(group.map((sample) => sample.promptTokens))),
    cached: round(median(cached)),
    n: group.length,
    median: round(median(totals)),
    q1: round(quantile(totals, 0.25)),
    q3: round(quantile(totals, 0.75)),
    min: round(Math.min(...totals)),
    max: round(Math.max(...totals)),
    points: totals.map(round),
    prefill: round(median(prefill)),
    token0: round(median(token0)),
    prefillTps: round(median(group.map((sample) => {
      const wall = duration(sample, "prefill.total");
      const cachedTokens = Number(events(sample, "prefill.total")[0]?.attributes?.cachedTokens ?? 0);
      return wall > 0 ? (sample.promptTokens - cachedTokens) / wall * 1000 : 0;
    }))),
    stages,
  };
}

const rows = [...groups.values()].map(summarizePrefillGroup)
  .sort((a, b) => a.model.localeCompare(b.model) || a.target - b.target || a.cache.localeCompare(b.cache) || a.arm.localeCompare(b.arm));

let validationRows: ReturnType<typeof summarizePrefillGroup>[] = [];
if (validationPath) {
  const validationRaw = await Bun.file(validationPath).text();
  const validationSamples = validationRaw.trim().split("\n").filter(Boolean)
    .map((line) => JSON.parse(line) as Sample)
    .filter((sample) => sample.maxTokens === 1);
  const validationGroups = new Map<string, Sample[]>();
  for (const sample of validationSamples) {
    const key = [sample.model, sample.arm, sample.cacheState, sample.targetTokens].join("\t");
    const group = validationGroups.get(key) ?? [];
    group.push(sample);
    validationGroups.set(key, group);
  }
  validationRows = [...validationGroups.values()].map(summarizePrefillGroup)
    .sort((a, b) => a.model.localeCompare(b.model) || a.target - b.target || a.cache.localeCompare(b.cache) || a.arm.localeCompare(b.arm));
}

const decodeGroups = new Map<string, Sample[]>();
for (const sample of samples.filter((sample) => sample.maxTokens > 1)) {
  const key = [sample.model, sample.arm, sample.targetTokens].join("\t");
  const group = decodeGroups.get(key) ?? [];
  group.push(sample);
  decodeGroups.set(key, group);
}
const decodeRows = [...decodeGroups.values()].map((group) => {
  const first = group[0]!;
  const postFirst = group.map((sample) => Math.max(0, sample.clientTotalMs - sample.clientTtftMs));
  return {
    model: first.model,
    label: first.modelLabel,
    arm: first.arm,
    target: first.targetTokens,
    measured: round(median(group.map((sample) => sample.promptTokens))),
    completionTokens: round(median(group.map((sample) => sample.completionTokens))),
    n: group.length,
    ttft: round(median(group.map((sample) => sample.clientTtftMs)),),
    total: round(median(group.map((sample) => sample.clientTotalMs))),
    postFirst: round(median(postFirst)),
    tps: round(median(group.map((sample) => {
      const ms = sample.clientTotalMs - sample.clientTtftMs;
      return ms > 0 ? Math.max(0, sample.completionTokens - 1) / ms * 1000 : 0;
    }))),
  };
}).sort((a, b) => a.model.localeCompare(b.model) || a.target - b.target || a.arm.localeCompare(b.arm));

const models = [...new Map(samples.map((sample) => [sample.model, sample.modelLabel])).entries()]
  .map(([id, label]) => ({ id, label }));
const contexts = [...new Set(samples.map((sample) => sample.targetTokens))].sort((a, b) => a - b);
const generatedAt = new Date().toISOString();
const commit = Bun.spawnSync(["git", "rev-parse", "--short", "HEAD"]).stdout.toString().trim();
const payload = JSON.stringify({
  rows,
  validationRows,
  decodeRows,
  models,
  contexts,
  generatedAt,
  commit,
  totalSamples: samples.length,
  validationSamples: validationRows.reduce((sum, row) => sum + row.n, 0),
});

const html = `<!doctype html>
<html lang="en">
<head>
<meta charset="utf-8">
<meta name="viewport" content="width=device-width,initial-scale=1">
<title>mlx-bun prompt-to-response performance</title>
<style>
:root{color-scheme:light dark;--bg:#f5f2ea;--ink:#171714;--muted:#6a675e;--panel:#fffdf8;--line:#d9d4c9;--bun:#126e82;--serial:#d47b22;--lm:#6554a5;--good:#247a43;--bad:#b33b31;--warn:#a86612;--phase1:#256d85;--phase2:#4b8fa7;--phase3:#78aeb9;--phase4:#c69542;--phase5:#d9b873;--phase6:#7866aa;--phase7:#9b8ac2;--phase8:#9a7060;--shadow:0 16px 42px rgba(48,43,32,.09)}
@media(prefers-color-scheme:dark){:root{--bg:#111310;--ink:#eff1e9;--muted:#a9aca2;--panel:#191c18;--line:#353a32;--bun:#54b8ca;--serial:#efa65d;--lm:#ac9bea;--good:#67c981;--bad:#ef786d;--warn:#e1a34c;--phase1:#397f98;--phase2:#5e9fb4;--phase3:#80b7c0;--phase4:#c39245;--phase5:#e0bd76;--phase6:#8170b2;--phase7:#a18dca;--phase8:#ae7d69;--shadow:0 18px 48px rgba(0,0,0,.25)}}
*{box-sizing:border-box}body{margin:0;background:var(--bg);color:var(--ink);font-family:ui-sans-serif,-apple-system,BlinkMacSystemFont,"Segoe UI",sans-serif;font-size:15px;line-height:1.45}main{max-width:1500px;margin:auto;padding:40px 28px 72px}h1,h2,h3{font-weight:600;letter-spacing:-.025em}h1{font-size:clamp(30px,4vw,54px);line-height:1.02;margin:0 0 14px;max-width:850px}h2{font-size:25px;margin:52px 0 10px}h3{font-size:18px;margin:28px 0 8px}.lede{max-width:850px;color:var(--muted);font-size:17px}.meta{display:flex;gap:12px;flex-wrap:wrap;margin-top:18px;color:var(--muted);font-size:13px}.pill{border:1px solid var(--line);border-radius:99px;padding:5px 10px}.grid{display:grid;grid-template-columns:repeat(3,minmax(0,1fr));gap:14px;margin:26px 0}.card{background:var(--panel);border:1px solid var(--line);border-radius:15px;padding:18px;box-shadow:var(--shadow)}.card .label{color:var(--muted);font-size:12px;text-transform:uppercase;letter-spacing:.08em}.card .value{font-size:28px;font-weight:650;letter-spacing:-.03em;margin:5px 0 3px}.card .note{color:var(--muted);font-size:13px}.good{color:var(--good)}.bad{color:var(--bad)}.warn{color:var(--warn)}.controls{display:flex;gap:12px;flex-wrap:wrap;align-items:end;margin:18px 0}.controls label{display:grid;gap:5px;color:var(--muted);font-size:12px}select{font:inherit;color:var(--ink);background:var(--panel);border:1px solid var(--line);border-radius:9px;padding:8px 34px 8px 10px}.chart{background:var(--panel);border:1px solid var(--line);border-radius:15px;padding:16px;box-shadow:var(--shadow)}svg{display:block;width:100%;height:auto}.axis{stroke:var(--line);stroke-width:1}.tick{fill:var(--muted);font-size:11px}.axis-title{fill:var(--ink);font-size:12px}.series-bun{stroke:var(--bun);fill:var(--bun)}.series-serial{stroke:var(--serial);fill:var(--serial)}.series-lm{stroke:var(--lm);fill:var(--lm)}.legend{display:flex;gap:18px;flex-wrap:wrap;margin:8px 0 4px;font-size:13px}.legend span::before{content:"";display:inline-block;width:9px;height:9px;border-radius:50%;margin-right:6px;background:var(--c)}.table-wrap{overflow:auto;border:1px solid var(--line);border-radius:13px;background:var(--panel)}table{width:100%;border-collapse:collapse;font-size:13px;font-variant-numeric:tabular-nums}th,td{padding:9px 11px;border-bottom:1px solid var(--line);text-align:right;white-space:nowrap}th{position:sticky;top:0;background:var(--panel);z-index:1;color:var(--muted);font-size:11px;text-transform:uppercase;letter-spacing:.045em}th:first-child,td:first-child,th:nth-child(2),td:nth-child(2){text-align:left}tr:last-child td{border-bottom:0}.focus td{background:color-mix(in srgb,var(--bun) 7%,transparent)}.waterfall{display:grid;gap:16px;margin:18px 0}.wf-row{display:grid;grid-template-columns:145px 1fr 100px;gap:12px;align-items:center}.wf-name{font-weight:600}.wf-track{display:flex;height:34px;background:color-mix(in srgb,var(--muted) 11%,transparent);overflow:hidden;border-radius:6px}.wf-seg{height:100%;min-width:0;position:relative}.wf-seg:hover{filter:brightness(1.12)}.wf-total{text-align:right;font-variant-numeric:tabular-nums}.phase-legend{display:flex;gap:8px 15px;flex-wrap:wrap;color:var(--muted);font-size:12px}.phase-legend span::before{content:"";display:inline-block;width:8px;height:8px;margin-right:5px;background:var(--c)}.callout{border-left:4px solid var(--bun);padding:8px 14px;margin:18px 0;color:var(--muted);max-width:950px}.details{margin-top:18px;color:var(--muted)}details{border-top:1px solid var(--line);padding:13px 0}summary{cursor:pointer;color:var(--ink);font-weight:600}.small{font-size:12px;color:var(--muted)}code{font-family:ui-monospace,SFMono-Regular,Menlo,monospace}footer{margin-top:52px;padding-top:18px;border-top:1px solid var(--line);color:var(--muted);font-size:12px}@media(max-width:760px){main{padding:24px 14px 48px}.grid{grid-template-columns:1fr}.wf-row{grid-template-columns:100px 1fr}.wf-total{grid-column:2}.chart{padding:8px}th,td{padding:8px}}
</style>
</head>
<body><main>
<header><h1>Where prompt-to-response time goes</h1><p class="lede">A side-by-side measurement of mlx-bun continuous scheduling, mlx-bun serial scheduling, and mlx-lm. Every cell starts a fresh warmed process and uses real streamed HTTP requests.</p><div class="meta"><span class="pill" id="generated"></span><span class="pill" id="commit"></span><span class="pill" id="sample-count"></span></div></header>
<section><h2>Answer first</h2><div class="grid" id="summary-cards"></div><p class="callout" id="verdict"></p></section>
<section id="validation-section" hidden><h2>Focused validation of the noisy cell</h2><p class="lede">The full matrix caught a slow window at e4b 16K. A five-repeat alternating-arm follow-up tests that cell without replacing the original observation.</p><div class="table-wrap"><table id="validation-table"><thead><tr><th>Run</th><th>Stack</th><th>n</th><th>Median TTFT</th><th>IQR</th><th>vs mlx-lm</th><th>Raw points</th></tr></thead><tbody></tbody></table></div></section>
<section><h2>Qwen 3.8 focus</h2><p class="lede">The standard 4/8-bit winner and the 13 GB compact artifact, with cold-prefill TTFT and the first generated token separated.</p><div class="table-wrap"><table id="qwen-table"><thead><tr><th>Model</th><th>Context</th><th>Stack</th><th>TTFT median</th><th>IQR</th><th>vs mlx-lm</th><th>Prefill</th><th>Token 0</th><th>Prefill tok/s</th></tr></thead><tbody></tbody></table></div></section>
<section><h2>Cold-prefill scaling</h2><div class="controls"><label>Model<select id="scale-model"></select></label></div><div class="legend"><span style="--c:var(--bun)">mlx-bun</span><span style="--c:var(--serial)">mlx-bun serial</span><span style="--c:var(--lm)">mlx-lm</span></div><div class="chart"><svg id="scale-chart" viewBox="0 0 1100 430" role="img" aria-label="Cold-prefill prompt-to-response time by context"></svg></div></section>
<section><h2>Prompt-to-response waterfall</h2><p class="lede">The bars are additive medians from request ingress through the first streamed byte. Prefill is split into setup, chunk compute, KV work, and unassigned gaps.</p><div class="controls"><label>Model<select id="wf-model"></select></label><label>Context<select id="wf-context"></select></label><label>Cache state<select id="wf-cache"><option value="miss">cold miss</option><option value="partial">partial reuse</option><option value="full">full reuse / token zero</option></select></label></div><div class="phase-legend" id="phase-legend"></div><div class="waterfall" id="waterfall"></div><div class="table-wrap"><table id="phase-table"><thead><tr><th>Stack</th><th>Ingress</th><th>Prompt</th><th>Queue</th><th>Cache</th><th>Batch</th><th>Chunks</th><th>KV</th><th>Prefill gaps</th><th>Token 0</th><th>Response</th><th>Other</th><th>Client</th><th>Measured TTFT</th></tr></thead><tbody></tbody></table></div></section>
<section><h2>Decode after the first token</h2><p class="lede">Each row requests 64 output tokens. Steady decode excludes TTFT and uses the remaining 63 token intervals.</p><div class="table-wrap"><table id="decode-table"><thead><tr><th>Model</th><th>Context</th><th>Stack</th><th>TTFT</th><th>Total</th><th>Post-first decode</th><th>Steady tok/s</th></tr></thead><tbody></tbody></table></div></section>
<section><h2>Full metric matrix</h2><div class="controls"><label>Model<select id="table-model"><option value="all">all models</option></select></label><label>Cache state<select id="table-cache"><option value="all">all states</option><option value="miss">cold miss</option><option value="partial">partial reuse</option><option value="full">full reuse</option></select></label></div><div class="table-wrap"><table id="full-table"><thead><tr><th>Model</th><th>Cache</th><th>Context</th><th>Stack</th><th>n</th><th>Median TTFT</th><th>Min</th><th>Q1</th><th>Q3</th><th>Max</th><th>IQR / median</th><th>vs mlx-lm</th><th>Prefill tok/s</th></tr></thead><tbody></tbody></table></div></section>
<section class="details"><h2>How to read this</h2><details open><summary>Measurement contract</summary><p>Short contexts have seven repetitions; 4K and 16K contexts have three. Arm order rotates each repetition. Each scenario owns a fresh process, followed by model warmup. Prompt-token counts must match across stacks. Medians are the headline; min, quartiles, max, and raw points expose machine noise.</p></details><details><summary>Cache states</summary><p><code>miss</code> measures the full prompt. <code>partial</code> restores a shared prefix and computes the suffix. <code>full</code> restores the prompt and mostly isolates token zero plus request overhead. Cache reuse is part of the attribution experiment, not an explanation for cold-prefill performance.</p></details><details><summary>Waterfall caveats</summary><p>mlx-lm parses the body before its wrapped request handler, so that small ingress span is unavailable. Container spans and child spans overlap; this report never adds a container twice. Separate medians for phases may differ slightly from the median total.</p></details><details><summary>Noise rule</summary><p>The report calls a comparison tied when the median difference is within 2%. A cell is marked noisy when its interquartile range exceeds 5% of its median. Long-context runs are expensive, so the report shows all three observations rather than pretending their median is exact.</p></details></section>
<footer>Source: <code>${esc(inputPath)}</code>${validationPath ? `; validation: <code>${esc(validationPath)}</code>` : ""}. Generated ${esc(generatedAt)} from commit <code>${esc(commit)}</code>.</footer>
</main>
<script>
const DATA=${payload};
const arms=["mlx-bun","mlx-bun-serial","mlx-lm"];
const armLabel={"mlx-bun":"mlx-bun","mlx-bun-serial":"bun serial","mlx-lm":"mlx-lm"};
const armClass={"mlx-bun":"bun","mlx-bun-serial":"serial","mlx-lm":"lm"};
const phaseDefs=[
 ["ingress","Ingress","var(--phase8)"],["prompt","Prompt prep","var(--phase3)"],["queue","Queue","var(--phase7)"],["cache","Cache","var(--phase6)"],
 ["batch","Batch setup","var(--phase5)"],["chunks","Prefill chunks","var(--phase1)"],["kv","KV work","var(--phase2)"],["prefillGaps","Prefill gaps","var(--phase4)"],
 ["token0","Token 0","var(--phase6)"],["response","Response write","var(--phase3)"],["otherServer","Other server","var(--phase8)"],["client","Client remainder","var(--phase7)"]
];
const fmt=ms=>ms>=1000?(ms/1000).toFixed(ms>=10000?2:3)+" s":ms.toFixed(ms>=100?1:2)+" ms";
const pct=n=>(n>=0?"+":"")+n.toFixed(1)+"%";
const get=(model,arm,cache,target)=>DATA.rows.find(r=>r.model===model&&r.arm===arm&&r.cache===cache&&r.target===target);
const validated=(row)=>DATA.validationRows.find(r=>r.model===row.model&&r.arm===row.arm&&r.cache===row.cache&&r.target===row.target)||row;
const delta=(row)=>{const base=get(row.model,"mlx-lm",row.cache,row.target);return base?(base.median-row.median)/base.median*100:null};
const validatedDelta=(row)=>{const value=validated(row);const base=validated(get(row.model,"mlx-lm",row.cache,row.target));return (base.median-value.median)/base.median*100};
const deltaHtml=(row)=>{if(row.arm==="mlx-lm")return "baseline";const d=delta(row);const cls=Math.abs(d)<=2?"warn":d>0?"good":"bad";return '<span class="'+cls+'">'+pct(d)+'</span>'};
const option=(value,label)=>'<option value="'+value+'">'+label+'</option>';
const q=(s)=>document.querySelector(s);
DATA.models.forEach(m=>{[q("#scale-model"),q("#wf-model"),q("#table-model")].forEach(el=>el.insertAdjacentHTML("beforeend",option(m.id,m.label)))});
q("#scale-model").value=DATA.models.find(m=>m.id==="qwen27b")?.id||DATA.models[0].id;
q("#wf-model").value=q("#scale-model").value;q("#table-model").value="all";
q("#generated").textContent=new Date(DATA.generatedAt).toLocaleString();q("#commit").textContent="commit "+DATA.commit;
q("#sample-count").textContent=DATA.totalSamples.toLocaleString()+" requests"+(DATA.validationSamples?" + "+DATA.validationSamples+" validation":"");
function renderSummary(){
 const cold=DATA.rows.filter(r=>r.cache==="miss"&&r.arm==="mlx-bun");const ds=cold.map(validatedDelta);const win=ds.filter(d=>d>2).length,tie=ds.filter(d=>Math.abs(d)<=2).length,loss=ds.filter(d=>d< -2).length;
 const qrows=cold.filter(r=>r.model.startsWith("qwen"));const qToken=qrows.map(r=>{const lm=get(r.model,"mlx-lm","miss",r.target);return lm?(lm.token0-r.token0)/lm.token0*100:0});
 const long=qrows.filter(r=>r.target===16384);const longD=long.map(delta);
 q("#summary-cards").innerHTML='<div class="card"><div class="label">Cold-prefill cells</div><div class="value">'+win+' faster · '+tie+' tied</div><div class="note">'+loss+' slower outside the ±2% tie band, '+cold.length+' comparisons total</div></div><div class="card"><div class="label">Qwen token zero</div><div class="value good">'+Math.min(...qToken).toFixed(0)+'–'+Math.max(...qToken).toFixed(0)+'% less time</div><div class="note">Continuous mlx-bun versus mlx-lm across measured contexts</div></div><div class="card"><div class="label">Qwen at 16K</div><div class="value '+(longD.every(d=>Math.abs(d)<=2)?"warn":"")+'">'+(longD.map(d=>pct(d)).join(" · ")||"pending")+'</div><div class="note">Standard winner, then compact artifact. Positive means mlx-bun is faster.</div></div>';
 const allNoLoss=loss===0;q("#verdict").innerHTML=allNoLoss?'Across this matrix, continuous mlx-bun never loses a cold-prefill cell by more than 2%. The short-context advantage comes mostly from lower supporting work and token-zero time; the long-context rows converge as model compute dominates.':'The pure-win claim needs qualification: '+loss+' cold-prefill cell'+(loss===1?'':'s')+' is slower by more than 2%. Check its spread before treating it as a regression.';
}
function renderValidation(){if(!DATA.validationRows.length)return;q("#validation-section").hidden=false;const original=DATA.rows.filter(r=>r.model==="e4b"&&r.target===16384&&r.cache==="miss"&&r.arm!=="mlx-bun-serial");const focused=DATA.validationRows.filter(r=>r.model==="e4b"&&r.target===16384&&r.cache==="miss");const make=(label,rs)=>rs.map(r=>{const lm=rs.find(x=>x.arm==="mlx-lm");const d=lm?(lm.median-r.median)/lm.median*100:0;return '<tr><td>'+label+'</td><td>'+armLabel[r.arm]+'</td><td>'+r.n+'</td><td>'+fmt(r.median)+'</td><td>'+fmt(r.q1)+'–'+fmt(r.q3)+'</td><td>'+(r.arm==="mlx-lm"?'baseline':'<span class="'+(Math.abs(d)<=2?'warn':d>0?'good':'bad')+'">'+pct(d)+'</span>')+'</td><td>'+r.points.map(fmt).join(', ')+'</td></tr>'}).join("");q("#validation-table tbody").innerHTML=make("Full matrix",original)+make("Focused follow-up",focused)}
function renderQwen(){const body=q("#qwen-table tbody");body.innerHTML="";for(const model of DATA.models.filter(m=>m.id.startsWith("qwen"))){for(const target of DATA.contexts){for(const arm of arms){const r=get(model.id,arm,"miss",target);if(!r)continue;body.insertAdjacentHTML("beforeend",'<tr class="'+(arm==="mlx-bun"?"focus":"")+'"><td>'+model.label+'</td><td>'+r.measured.toLocaleString()+' tok</td><td>'+armLabel[arm]+'</td><td>'+fmt(r.median)+'</td><td>'+fmt(r.q1)+'–'+fmt(r.q3)+'</td><td>'+deltaHtml(r)+'</td><td>'+fmt(r.prefill)+'</td><td>'+fmt(r.token0)+'</td><td>'+r.prefillTps.toFixed(1)+'</td></tr>')}}}}
function renderScale(){
 const model=q("#scale-model").value,rs=DATA.rows.filter(r=>r.model===model&&r.cache==="miss");const svg=q("#scale-chart");const W=1100,H=430,L=82,R=28,T=24,B=58;const xs=[...new Set(rs.map(r=>r.measured))].sort((a,b)=>a-b);const xMin=Math.log10(Math.min(...xs)),xMax=Math.log10(Math.max(...xs));const yMax=Math.max(...rs.map(r=>r.median))*1.08;const x=v=>L+(Math.log10(v)-xMin)/(xMax-xMin)*(W-L-R);const y=v=>T+(1-v/yMax)*(H-T-B);let out='<line class="axis" x1="'+L+'" y1="'+(H-B)+'" x2="'+(W-R)+'" y2="'+(H-B)+'"/><line class="axis" x1="'+L+'" y1="'+T+'" x2="'+L+'" y2="'+(H-B)+'"/>';
 for(let i=0;i<=5;i++){const v=yMax*i/5,yy=y(v);out+='<line class="axis" opacity=".45" x1="'+L+'" y1="'+yy+'" x2="'+(W-R)+'" y2="'+yy+'"/><text class="tick" x="'+(L-10)+'" y="'+(yy+4)+'" text-anchor="end">'+fmt(v)+'</text>'}xs.forEach(v=>out+='<text class="tick" x="'+x(v)+'" y="'+(H-B+22)+'" text-anchor="middle">'+v.toLocaleString()+'</text>');
 for(const arm of arms){const ar=rs.filter(r=>r.arm===arm).sort((a,b)=>a.measured-b.measured);if(!ar.length)continue;out+='<polyline class="series-'+armClass[arm]+'" points="'+ar.map(r=>x(r.measured)+','+y(r.median)).join(" ")+'" fill="none" stroke-width="2.5"/>';for(const r of ar)out+='<circle class="series-'+armClass[arm]+'" cx="'+x(r.measured)+'" cy="'+y(r.median)+'" r="5"><title>'+armLabel[arm]+' · '+r.measured+' tok · '+fmt(r.median)+' · n='+r.n+'</title></circle>'}
 out+='<text class="axis-title" x="'+((L+W-R)/2)+'" y="'+(H-10)+'" text-anchor="middle">Measured prompt tokens, log scale</text><text class="axis-title" transform="translate(18 '+((T+H-B)/2)+') rotate(-90)" text-anchor="middle">Client TTFT</text>';svg.innerHTML=out;
}
function syncContexts(){const model=q("#wf-model").value;const values=[...new Set(DATA.rows.filter(r=>r.model===model).map(r=>r.target))].sort((a,b)=>a-b);const current=Number(q("#wf-context").value);q("#wf-context").innerHTML=values.map(v=>option(v,v.toLocaleString()+" nominal tokens")).join("");q("#wf-context").value=values.includes(current)?String(current):String(values.includes(1024)?1024:values[0]);renderWaterfall()}
function renderWaterfall(){const model=q("#wf-model").value,target=Number(q("#wf-context").value),cache=q("#wf-cache").value;const rs=arms.map(a=>get(model,a,cache,target)).filter(Boolean);if(!rs.length)return;const max=Math.max(...rs.map(r=>r.median));q("#phase-legend").innerHTML=phaseDefs.map(([,label,color])=>'<span style="--c:'+color+'">'+label+'</span>').join("");q("#waterfall").innerHTML=rs.map(r=>{const segs=phaseDefs.map(([key,label,color])=>{const value=r.stages[key];return value>0?'<div class="wf-seg" style="width:'+(value/max*100)+'%;background:'+color+'" title="'+label+': '+fmt(value)+'"></div>':""}).join("");return '<div class="wf-row"><div class="wf-name">'+armLabel[r.arm]+'</div><div class="wf-track">'+segs+'</div><div class="wf-total">'+fmt(r.median)+'</div></div>'}).join("");q("#phase-table tbody").innerHTML=rs.map(r=>'<tr><td>'+armLabel[r.arm]+'</td>'+phaseDefs.map(([key])=>'<td>'+fmt(r.stages[key])+'</td>').join("")+'<td>'+fmt(r.median)+'</td></tr>').join("")}
function renderDecode(){q("#decode-table tbody").innerHTML=DATA.decodeRows.map(r=>'<tr class="'+(r.arm==="mlx-bun"&&r.model.startsWith("qwen")?"focus":"")+'"><td>'+r.label+'</td><td>'+r.measured.toLocaleString()+' tok</td><td>'+armLabel[r.arm]+'</td><td>'+fmt(r.ttft)+'</td><td>'+fmt(r.total)+'</td><td>'+fmt(r.postFirst)+'</td><td>'+r.tps.toFixed(1)+'</td></tr>').join("")}
function renderFull(){const model=q("#table-model").value,cache=q("#table-cache").value;const rs=DATA.rows.filter(r=>(model==="all"||r.model===model)&&(cache==="all"||r.cache===cache));q("#full-table tbody").innerHTML=rs.map(r=>{const noise=(r.q3-r.q1)/r.median*100;return '<tr class="'+(r.arm==="mlx-bun"&&r.model.startsWith("qwen")?"focus":"")+'"><td>'+r.label+'</td><td>'+r.cache+'</td><td>'+r.measured.toLocaleString()+'</td><td>'+armLabel[r.arm]+'</td><td>'+r.n+'</td><td>'+fmt(r.median)+'</td><td>'+fmt(r.min)+'</td><td>'+fmt(r.q1)+'</td><td>'+fmt(r.q3)+'</td><td>'+fmt(r.max)+'</td><td class="'+(noise>5?"warn":"")+'" title="raw: '+r.points.map(fmt).join(", ")+'">'+noise.toFixed(1)+'%</td><td>'+deltaHtml(r)+'</td><td>'+r.prefillTps.toFixed(1)+'</td></tr>'}).join("")}
q("#scale-model").addEventListener("change",renderScale);q("#wf-model").addEventListener("change",syncContexts);q("#wf-context").addEventListener("change",renderWaterfall);q("#wf-cache").addEventListener("change",renderWaterfall);q("#table-model").addEventListener("change",renderFull);q("#table-cache").addEventListener("change",renderFull);
renderSummary();renderValidation();renderQwen();renderScale();syncContexts();renderDecode();renderFull();
</script></body></html>`;

await Bun.write(outputPath, html);
console.log(`${samples.length} samples, ${rows.length} TTFT groups -> ${outputPath}`);
