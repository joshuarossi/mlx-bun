// The fine-tune wizard's markup, its loss chart and its own rules. The vocabulary (page, cards, fields, the step rail,
// notices, progress, stats, the log) is the kit's BASE_CSS, which index.ts puts ahead of STYLE in the shadow root;
// colours and sizes come from the tokens. The ids are the controller's, the chat assistant's spotlight target
// (`f-model`) and the tests'; the step rail (`f-steps`) is what `railStep` reads for the element's `currentStep()`.
import { esc, num } from "@mlx-bun/web-kit";

export const STEPS = ["Base", "Dataset", "Hyperparameters", "Train", "Done"] as const;
export const BASE = 0, DATASET = 1, CONFIGURE = 2, RUN = 3, DONE = 4;

/** The step rail. Each step carries the kit's `.step` (with `.current`/`.done`) and the `.s` (with `.cur`) that
 * `railStep` reads to tell a host where the wizard is. */
export function stepsHtml(names: readonly string[], current: number, failed = false): string {
  return names.map((name, index) => {
    const state = index === current ? " current cur" + (failed ? " failed" : "") : index < current ? " done" : "";
    return `<li class="step s${state}"${index === current ? ' aria-current="step"' : ""}><span class="n">${index + 1}</span>${esc(name)}</li>`;
  }).join("");
}

/** Where the wizard is, as a host describes the page: the current step of a rail `stepsHtml` drew (its index, the
 * number of steps and its name), or null before the rail is drawn. */
export interface WizardStep { index: number; count: number; label: string }
export function railStep(rail: HTMLElement): WizardStep | null {
  const steps = [...rail.querySelectorAll(".s")];
  if (!steps.length) return null;
  const index = Math.max(0, steps.findIndex((step) => step.classList.contains("cur")));
  const current = steps[index]!;
  const text = (current.textContent || "").trim();
  return { index, count: steps.length, label: current.querySelector(".n") ? text.replace(/^\d+/, "").trim() : text };
}

export type Method = "sft" | "dpo" | "orpo";
export const METHOD_HINT: Readonly<Record<Method, string>> = {
  sft: "Supervised fine-tuning: rows are messages, or a prompt and a completion.",
  dpo: "Direct preference optimization: rows are a prompt with a chosen and a rejected answer.",
  orpo: "Odds ratio preference optimization, without a reference model: rows are a prompt with a chosen and a rejected answer.",
};

export const failureHtml = (title: string, error: string): string => `<div class="notice bad" role="alert"><div><b>${esc(title)}</b> ${esc(error)}</div></div>`;

/** The answer of `POST /api/finetune/inspect-dataset` as a notice. */
export function datasetHtml(answer: { ok?: boolean; error?: string; n_train?: unknown; n_valid?: unknown; format?: unknown }): string {
  if (!answer.ok) return failureHtml("Could not read this dataset.", answer.error || "The server gave no reason.");
  const valid = Number(answer.n_valid) > 0 ? ` and <b>${esc(num(Number(answer.n_valid)))}</b> validation rows` : "";
  const format = answer.format ? ` in the <b>${esc(answer.format)}</b> format` : "";
  return `<div class="notice ok"><div><b>${esc(num(Number(answer.n_train)))}</b> training rows${valid}${format}.</div></div>`;
}

/** A merge or export answer as a notice: what was written, and where. */
export function writtenHtml(title: string, path: string, stats?: unknown): string {
  const facts = stats && typeof stats === "object"
    ? Object.entries(stats as Record<string, unknown>).map(([key, value]) => `${key} ${String(value)}`).join(" · ")
    : stats ? String(stats) : "";
  return `<div class="notice ok"><div><b>${esc(title)}</b><span class="path">${esc(path)}</span>${facts ? `<span class="facts">${esc(facts)}</span>` : ""}</div></div>`;
}

export interface LossPoint { step: number; loss: number | null }

/** The loss chart's SVG content: gridlines, then the validation and training curves with a soft fill under each. The
 * view box is 600×200 stretched to the chart's width, so strokes do not scale. Empty until a finite loss arrives. */
export function chartSvg(train: readonly LossPoint[], valid: readonly LossPoint[]): string {
  const width = 600, height = 200, padX = 8, padY = 12;
  const all = [...train, ...valid];
  const losses = all.map(point => point.loss).filter((loss): loss is number => loss != null && Number.isFinite(loss));
  if (!losses.length) return "";
  let min = Math.min(...losses), max = Math.max(...losses);
  if (min === max) { min -= 0.5; max += 0.5; }
  const range = max - min || 1;
  const lastStep = Math.max(...all.map(point => point.step || 0), 1);
  const x = (step: number) => (padX + (step / lastStep) * (width - 2 * padX)).toFixed(1);
  const y = (loss: number) => (padY + (1 - (loss - min) / range) * (height - 2 * padY)).toFixed(1);
  const series = (points: readonly LossPoint[], name: "train" | "val") => {
    if (!points.length) return "";
    const line = points.map((point, index) => (index ? "L" : "M") + x(point.step) + " " + y(point.loss ?? 0)).join(" ");
    const area = `${line} L${x(points[points.length - 1]!.step)} ${height - padY} L${x(points[0]!.step)} ${height - padY} Z`;
    return `<path class="area" d="${area}" fill="url(#f-fill-${name})"/><path class="line ${name}" d="${line}" vector-effect="non-scaling-stroke"/>`;
  };
  const fill = (name: "train" | "val") => `<linearGradient id="f-fill-${name}" x1="0" y1="0" x2="0" y2="1"><stop offset="0" class="stop ${name}"/><stop offset="1" class="stop ${name} fade"/></linearGradient>`;
  let grid = "";
  for (let i = 1; i < 4; i++) {
    const at = (padY + (i / 4) * (height - 2 * padY)).toFixed(1);
    grid += `<line class="rule" x1="0" y1="${at}" x2="${width}" y2="${at}" vector-effect="non-scaling-stroke"/>`;
  }
  return `<defs>${fill("train")}${fill("val")}</defs>${grid}${series(valid, "val")}${series(train, "train")}`;
}

const FOLDER_ICON = '<svg viewBox="0 0 16 16" fill="none" stroke="currentColor" stroke-width="1.4" stroke-linejoin="round" aria-hidden="true"><path d="M1.75 4.5v7.25c0 .55.45 1 1 1h10.5c.55 0 1-.45 1-1V6c0-.55-.45-1-1-1H8.1L6.6 3.5H2.75c-.55 0-1 .45-1 1z"/></svg>';

const numberField = (id: string, label: string, attributes: string, hint = "") =>
  `<div class="field"><label for="${id}">${label}</label><input class="input num" type="number" id="${id}" ${attributes}>${hint ? `<p class="hint">${hint}</p>` : ""}</div>`;
const scheduleField = (id: string) =>
  `<div class="field"><label for="${id}">Learning rate schedule</label><select class="select" id="${id}"><option value="cosine">Cosine (recommended)</option><option value="constant">Constant</option></select></div>`;

export const MARKUP = `
<header class="page-head">
  <div>
    <h1 class="page-title">Fine-tune a model</h1>
    <p class="page-lead">Train a LoRA adapter on a local model with SFT, DPO or ORPO, and watch the loss as it trains.</p>
  </div>
</header>
<p id="panel-message" class="notice" role="status"></p>
<ol class="steps" id="f-steps" aria-label="Fine-tune steps"></ol>

<section class="card" data-fstep="0" aria-labelledby="f-title-0">
  <h2 class="card-title" id="f-title-0">Base model</h2>
  <p class="card-note">The model the adapter trains on: a local model directory or a Hugging Face repository id. Quantized models work.</p>
  <div class="field">
    <label for="f-model">Model directory or repository id</label>
    <div class="drop" id="f-drop">
      <input class="input" type="text" id="f-model" data-spotlight="finetune-base" placeholder="mlx-community/Qwen3-8B-4bit" autocomplete="off" spellcheck="false">
    </div>
    <input type="file" id="f-folder" webkitdirectory directory hidden>
    <p class="hint">Or choose a model folder, or drop one on the field: the server finds it on disk by the folder's name, and nothing is uploaded.</p>
  </div>
  <div class="result" id="f-base-out" aria-live="polite"></div>
  <div class="row">
    <button type="button" class="btn" id="f-browse">${FOLDER_ICON}Choose folder…</button>
    <span class="spacer"></span>
    <button type="button" class="btn primary" id="f-next0">Continue</button>
  </div>
</section>

<section class="card" data-fstep="1" hidden aria-labelledby="f-title-1">
  <h2 class="card-title" id="f-title-1">Dataset</h2>
  <p class="card-note">A directory with <code>train.jsonl</code> and, optionally, <code>valid.jsonl</code>. Rows are <code>{"text"}</code>, <code>{"prompt", "completion"}</code> or <code>{"messages"}</code>; DPO and ORPO read <code>{"prompt", "chosen", "rejected"}</code>.</p>
  <div class="field">
    <label for="f-data">Dataset directory</label>
    <div class="row inline">
      <input class="input" type="text" id="f-data" placeholder="/path/to/dataset" autocomplete="off" spellcheck="false">
      <button type="button" class="btn" id="f-inspect">Inspect</button>
    </div>
  </div>
  <div class="result" id="f-inspect-out" aria-live="polite"></div>
  <div class="row">
    <button type="button" class="btn" data-fback>Back</button>
    <button type="button" class="btn primary" id="f-next1" disabled>Continue</button>
  </div>
</section>

<section class="card" data-fstep="2" hidden aria-labelledby="f-title-2">
  <h2 class="card-title" id="f-title-2">Hyperparameters</h2>
  <p class="card-note">The defaults suit a first run. The learning rate and rank follow the objective until you change them.</p>
  <div class="field">
    <label id="f-method-label">Training objective</label>
    <div class="seg" id="f-method" role="group" aria-labelledby="f-method-label">
      <button type="button" data-v="sft" class="on" aria-pressed="true">SFT</button>
      <button type="button" data-v="dpo" aria-pressed="false">DPO</button>
      <button type="button" data-v="orpo" aria-pressed="false">ORPO</button>
    </div>
    <p class="hint" id="f-method-hint">${METHOD_HINT.sft}</p>
  </div>
  <div class="extra" id="f-dpo-extra" hidden>
    <div class="notice warn"><div><b>DPO needs a lower learning rate.</b> The default is 5e-5, about 4× lower than SFT, with warmup; a higher rate blows out the reward margin. Check that each row's chosen and rejected answers both complete its prompt.</div></div>
    <div class="grid cols-2">
      ${numberField("f-beta", "Beta (KL strength)", 'value="0.1" step="0.01" min="0.01" max="1"')}
      ${scheduleField("f-sched")}
    </div>
  </div>
  <div class="extra" id="f-orpo-extra" hidden>
    <div class="notice warn"><div><b>ORPO is reference-free.</b> One loss (SFT plus an odds-ratio term) and no reference model, so half the forward passes of DPO. The default learning rate is 1e-5, lower than DPO's because the loss carries a full SFT term; λ weights only the odds-ratio term.</div></div>
    <div class="grid cols-2">
      ${numberField("f-orpo-lambda", "λ (odds-ratio weight)", 'value="0.1" step="0.05" min="0.01" max="2"')}
      ${scheduleField("f-orpo-sched")}
    </div>
    <div class="field">
      <label id="f-orpo-scope-label">SFT scope</label>
      <div class="seg" id="f-orpo-scope" role="group" aria-labelledby="f-orpo-scope-label">
        <button type="button" data-v="full" class="on" aria-pressed="true">Full sequence</button>
        <button type="button" data-v="response" aria-pressed="false">Response only</button>
      </div>
      <p class="hint">Full sequence is the paper's and TRL's chosen-answer loss; response only scores the answer, as before July 2026.</p>
    </div>
  </div>
  <div class="grid cols-3">
    ${numberField("f-rank", "Rank", 'value="8" min="1" max="128"')}
    ${numberField("f-scale", "Scale", 'value="20" step="0.5" min="0"', "Alpha is rank × scale.")}
    ${numberField("f-dropout", "Dropout", 'value="0" step="0.01" min="0" max="0.5"')}
    <div class="field"><label for="f-modules">Target modules</label><input class="input" type="text" id="f-modules" value="q_proj,v_proj" autocomplete="off" spellcheck="false"><p class="hint">Comma-separated projection names.</p></div>
    ${numberField("f-layers", "Layers", 'value="16" min="-1"', "−1 trains every layer.")}
    ${numberField("f-iters", "Iterations", 'value="500" min="10"')}
    ${numberField("f-batch", "Batch size", 'value="1" min="1" max="16"')}
    ${numberField("f-lr", "Learning rate", 'value="0.0002" step="0.00001" min="0"')}
    ${numberField("f-seq", "Max sequence length", 'value="1024" min="128"')}
  </div>
  <div class="result" id="f-submit-out" aria-live="polite"></div>
  <div class="row">
    <button type="button" class="btn" data-fback>Back</button>
    <button type="button" class="btn primary" id="f-submit">Start training</button>
  </div>
</section>

<section class="card" data-fstep="3" hidden aria-labelledby="f-title-3">
  <h2 class="card-title" id="f-title-3">Training</h2>
  <p class="card-note">The job runs on the server. Leaving this page does not stop it, and coming back picks it up again.</p>
  <div class="progress" role="progressbar" aria-labelledby="f-title-3" aria-valuemin="0" aria-valuemax="100" aria-valuenow="0"><i id="f-bar"></i></div>
  <div class="progress-meta"><span id="f-msg">Starting…</span><span id="f-pct">0%</span></div>
  <p class="reconnect" id="f-reconnect" role="status" hidden>Reconnecting to the job…</p>
  <div class="notice bad fail" id="f-fail" role="alert" hidden>
    <div><b>Training failed.</b> <span id="f-fail-msg"></span></div>
    <span class="actions"><button type="button" class="btn sm" id="f-retry">Try again</button></span>
  </div>
  <figure class="chart">
    <figcaption class="chart-legend">
      <span class="key"><i class="swatch train"></i>Training loss</span>
      <span class="key" id="f-leg-val" hidden><i class="swatch val"></i>Validation loss</span>
    </figcaption>
    <div class="chart-wrap">
      <svg id="f-chart" viewBox="0 0 600 200" preserveAspectRatio="none" role="img" aria-label="Loss by training step"></svg>
      <p class="chart-empty" id="f-chart-empty">Waiting for the first metric…</p>
    </div>
  </figure>
  <div class="grid cols-4 chart-stats">
    <div class="stat"><b id="f-step">—</b><span>Step</span></div>
    <div class="stat"><b id="f-loss">—</b><span>Training loss</span></div>
    <div class="stat"><b id="f-curlr">—</b><span>Learning rate</span></div>
    <div class="stat"><b id="f-curtps">—</b><span>Tokens per second</span></div>
  </div>
  <pre class="log" id="f-log" aria-label="Job log"></pre>
</section>

<section class="card" data-fstep="4" hidden aria-labelledby="f-title-4">
  <h2 class="card-title" id="f-title-4">Adapter trained</h2>
  <p class="card-note">Mount it from the Models page to use it in chat, or merge, export or publish it here.</p>
  <p class="label" id="f-out-label">Adapter path</p>
  <pre class="log out" id="f-out" aria-labelledby="f-out-label"></pre>
  <div class="grid cols-3 follow">
    <div class="card quiet">
      <h3 class="card-title">Merge adapters</h3>
      <p class="card-note">Combine two adapters into a new one in your adapters directory.</p>
      <div class="field"><label for="f-merge-a">Adapter A</label><input class="input" type="text" id="f-merge-a" placeholder="/path/to/adapter" autocomplete="off" spellcheck="false"></div>
      <div class="field"><label for="f-merge-b">Adapter B</label><input class="input" type="text" id="f-merge-b" placeholder="/path/to/other-adapter" autocomplete="off" spellcheck="false"></div>
      <div class="result" id="f-merge-out" aria-live="polite"></div>
      <div class="row"><button type="button" class="btn sm" id="f-merge-go">Merge</button></div>
    </div>
    <div class="card quiet">
      <h3 class="card-title">Export</h3>
      <p class="card-note">Write a manifest that pairs the base model with this adapter, in a new directory under your exports.</p>
      <div class="field"><label for="f-exp-base">Base model</label><input class="input" type="text" id="f-exp-base" placeholder="/path/to/base" autocomplete="off" spellcheck="false"></div>
      <div class="field"><label for="f-exp-adapter">Adapter path</label><input class="input" type="text" id="f-exp-adapter" placeholder="/path/to/adapter" autocomplete="off" spellcheck="false"></div>
      <div class="result" id="f-exp-out" aria-live="polite"></div>
      <div class="row"><button type="button" class="btn sm" id="f-exp-go">Export</button></div>
    </div>
    <div class="card quiet">
      <h3 class="card-title">Push to Hugging Face</h3>
      <p class="card-note">Publish the adapter to a repository on the Hub.</p>
      <div class="row"><button type="button" class="btn sm" id="f-push">Push to Hugging Face</button></div>
      <div id="f-push-panel"></div>
    </div>
  </div>
  <div class="row actions"><button type="button" class="btn" id="f-again">Train another adapter</button></div>
</section>`;

/** The panel's own rules, after the kit's. The page is the panel's scroll column (the shell does not frame it). The chart
 * keeps the code surface in both themes: training loss in the state colour for success, validation in the accent. */
export const STYLE = String.raw`
:host{display:block;height:100%;overflow-y:auto;overflow-x:hidden;color:var(--ink)}
[hidden]{display:none!important}
.page{max-width:960px}
.steps{list-style:none;padding:0}
.field>.seg{align-self:flex-start;max-width:100%}
.step.failed{color:var(--bad)}
.step.failed .n{background:var(--bad-soft);border-color:transparent;color:var(--bad)}
.card>.card-note{margin:4px 0 18px;max-width:72ch}
.card .row{margin-top:4px}
.card .row.actions{margin-top:20px}
.row.inline{flex-wrap:nowrap;margin-top:0}
.row.inline .input{flex:1 1 auto;min-width:0}
.result:not(:empty){margin:0 0 14px}
.drop{border-radius:var(--radius-md)}
.drop.over{outline:2px dashed var(--accent);outline-offset:3px}
.extra>.notice{margin-bottom:16px}
.grid>.field{margin-bottom:6px}
.extra>.grid,.card>.grid.cols-3{margin-bottom:14px}
#panel-message{margin-bottom:16px}
#panel-message:empty{display:none}
.reconnect{display:flex;align-items:center;gap:8px;margin-top:10px;font-size:var(--text-sm);color:var(--dim)}
.reconnect::before{content:"";width:7px;height:7px;border-radius:50%;background:var(--warn);animation:f-pulse 1.2s var(--ease) infinite alternate}
@keyframes f-pulse{from{opacity:1}to{opacity:.3}}
.fail{margin-top:14px}
.chart{margin-top:18px}
.chart-legend{display:flex;gap:16px;flex-wrap:wrap;font-size:var(--text-sm);color:var(--dim);margin-bottom:8px}
.chart-legend .key{display:inline-flex;align-items:center;gap:7px}
.swatch{display:inline-block;width:14px;height:3px;border-radius:2px}
.swatch.train{background:var(--ok)}
.swatch.val{background:var(--accent)}
.chart-wrap{position:relative;background:var(--code-bg);border:1px solid var(--code-line);border-radius:var(--radius-md);padding:12px}
#f-chart{display:block;width:100%;height:200px;overflow:visible}
.chart-empty{position:absolute;inset:0;display:flex;align-items:center;justify-content:center;margin:0;color:var(--dimmer);font-size:var(--text-sm)}
#f-chart:not(:empty)+.chart-empty{display:none}
.rule{stroke:var(--code-line);stroke-width:1}
.line{fill:none;stroke-width:2;stroke-linejoin:round;stroke-linecap:round}
.line.train{stroke:var(--ok)}
.line.val{stroke:var(--accent)}
.area{opacity:.18}
.stop.train{stop-color:var(--ok)}
.stop.val{stop-color:var(--accent)}
.stop.fade{stop-opacity:0}
.grid.chart-stats{margin-top:14px;grid-template-columns:repeat(auto-fit,minmax(120px,1fr))}
.chart-stats .stat b{font-size:var(--text-xl)}
.log{margin-top:16px}
.label{font-size:var(--text-sm);font-weight:600;margin:0 0 6px}
.log.out{margin-top:0;max-height:none;font-size:var(--text-sm)}
.follow{margin-top:18px}
.follow .card{display:flex;flex-direction:column}
.follow .card-title{font-size:var(--text-md)}
.follow .card>.card-note{margin-bottom:12px}
.follow .field{margin-bottom:12px}
.follow .result:not(:empty){margin-bottom:10px}
.follow .row{margin-top:auto}
.notice .path{display:block;margin-top:2px;font:var(--text-sm)/1.45 var(--mono);overflow-wrap:anywhere}
.notice .facts{display:block;color:var(--dim);font-size:var(--text-sm);margin-top:4px}
.pushpanel:not(:empty){margin-top:14px}
@media (prefers-reduced-motion:reduce){.reconnect::before{animation:none}}
`;
