// The quantize wizard's markup and its own rules. The vocabulary (page, cards, fields, the step rail, notices, progress,
// the log) is the kit's BASE_CSS, which index.ts puts ahead of STYLE in the shadow root; colours and sizes come from the
// tokens. The ids are the controller's, the chat assistant's (`q-steps`, `q-model`) and the tests'.
import { esc, num } from "@mlx-bun/web-kit";

export const STEPS = ["Source", "Configure", "Run", "Done"] as const;
export const SOURCE = 0, CONFIGURE = 1, RUN = 2, DONE = 3;

/** The step rail. Each step carries the kit's `.step` (with `.current`/`.done`) and the `.s` (with `.cur`) the chat
 * assistant reads to tell where the wizard is. */
export function stepsHtml(names: readonly string[], current: number, failed = false): string {
  return names.map((name, index) => {
    const state = index === current ? " current cur" + (failed ? " failed" : "") : index < current ? " done" : "";
    return `<li class="step s${state}"${index === current ? ' aria-current="step"' : ""}><span class="n">${index + 1}</span>${esc(name)}</li>`;
  }).join("");
}

export const BITS_HINT: Readonly<Record<string, string>> = {
  "4": "About 4× smaller than bf16. The usual choice for local serving.",
  "8": "About 2× smaller than bf16, with the highest fidelity.",
};

/** The answer of `POST /api/quantize/inspect` as a notice. */
export function inspectionHtml(answer: { ok?: boolean; error?: string; arch?: unknown; model_id?: unknown; size_gb?: unknown; support?: unknown }, id: string): string {
  if (!answer.ok) return `<div class="notice bad" role="alert"><div><b>Could not inspect this model.</b> ${esc(answer.error || "The server gave no reason.")}</div></div>`;
  const name = esc(answer.arch || answer.model_id || id);
  const size = Number(answer.size_gb) > 0 ? ` It is ${esc(num(Number(answer.size_gb), 1))} GB on disk.` : "";
  return answer.support === true
    ? `<div class="notice ok"><div><b>${name}</b> can be quantized.${size}</div></div>`
    : `<div class="notice bad"><div><b>${name}</b> cannot be quantized: its config has no text layers to quantize.${size}</div></div>`;
}

export const failureHtml = (title: string, error: string): string => `<div class="notice bad" role="alert"><div><b>${esc(title)}</b> ${esc(error)}</div></div>`;

const FOLDER_ICON = '<svg viewBox="0 0 16 16" fill="none" stroke="currentColor" stroke-width="1.4" stroke-linejoin="round" aria-hidden="true"><path d="M1.75 4.5v7.25c0 .55.45 1 1 1h10.5c.55 0 1-.45 1-1V6c0-.55-.45-1-1-1H8.1L6.6 3.5H2.75c-.55 0-1 .45-1 1z"/></svg>';

export const MARKUP = `
<header class="page-head">
  <div>
    <h1 class="page-title">Quantize a model</h1>
    <p class="page-lead">Write a 4- or 8-bit copy of a model that loads faster and takes less memory.</p>
  </div>
</header>
<p id="panel-message" class="notice" role="status"></p>
<ol class="steps" id="q-steps" aria-label="Quantize steps"></ol>

<section class="card" data-qstep="0" aria-labelledby="q-title-0">
  <h2 class="card-title" id="q-title-0">Source model</h2>
  <p class="card-note">A Hugging Face repository id or the path of a model on this machine. Inspect it to confirm it can be quantized.</p>
  <div class="field">
    <label for="q-model">Model id or path</label>
    <div class="drop" id="q-drop">
      <input class="input" type="text" id="q-model" data-spotlight="quantize-source" placeholder="mlx-community/Qwen3-8B-bf16" autocomplete="off" spellcheck="false">
    </div>
    <input type="file" id="q-folder" webkitdirectory directory hidden>
    <p class="hint">Or choose a model folder, or drop one on the field: the server finds it on disk by the folder's name, and nothing is uploaded.</p>
  </div>
  <div class="result" id="q-inspect-out" aria-live="polite"></div>
  <div class="row">
    <button type="button" class="btn" id="q-browse">${FOLDER_ICON}Choose folder…</button>
    <button type="button" class="btn" id="q-inspect">Inspect</button>
    <span class="spacer"></span>
    <button type="button" class="btn primary" id="q-continue" hidden>Continue</button>
  </div>
</section>

<section class="card" data-qstep="1" hidden aria-labelledby="q-title-1">
  <h2 class="card-title" id="q-title-1">Configure</h2>
  <p class="card-note">Fewer bits give a smaller, faster model at some cost in quality. 4-bit with a group size of 64 is the usual choice.</p>
  <div class="field">
    <label id="q-bits-label">Precision</label>
    <div class="seg" id="q-bits" role="group" aria-labelledby="q-bits-label">
      <button type="button" data-v="4" class="on" aria-pressed="true">4-bit</button>
      <button type="button" data-v="8" aria-pressed="false">8-bit</button>
    </div>
    <p class="hint" id="q-bits-hint">${BITS_HINT["4"]}</p>
  </div>
  <div class="field">
    <label id="q-gs-label">Group size</label>
    <div class="seg" id="q-gs" role="group" aria-labelledby="q-gs-label">
      <button type="button" data-v="64" class="on" aria-pressed="true">64</button>
      <button type="button" data-v="32" aria-pressed="false">32</button>
    </div>
    <p class="hint">How many weights share one scale. 64 is standard; 32 is a little larger and a little more faithful.</p>
  </div>
  <div class="field">
    <label id="q-mode-label">Bit allocation</label>
    <div class="seg" id="q-mode" role="group" aria-labelledby="q-mode-label">
      <button type="button" data-v="uniform" class="on" aria-pressed="true">Uniform</button>
      <button type="button" data-v="mixed" aria-pressed="false">Mixed precision</button>
    </div>
    <p class="hint">Uniform gives every layer the precision above. Mixed measures each layer's sensitivity and gives each layer 4 or 8 bits to reach a target average.</p>
  </div>
  <div class="field" id="q-bpw-field" hidden>
    <label for="q-bpw">Target bits per weight <span class="value num" id="q-bpw-val">5.0</span></label>
    <input type="range" id="q-bpw" min="3" max="8" step="0.5" value="5">
    <p class="hint">The sensitivity sweep adds 2 to 5 minutes. Lower is smaller; higher is closer to bf16.</p>
  </div>
  <div class="result" id="q-submit-out" aria-live="polite"></div>
  <div class="row">
    <button type="button" class="btn" data-qback>Back</button>
    <button type="button" class="btn primary" id="q-submit">Start quantizing</button>
  </div>
</section>

<section class="card" data-qstep="2" hidden aria-labelledby="q-title-2">
  <h2 class="card-title" id="q-title-2">Quantizing</h2>
  <p class="card-note">The job runs on the server. Leaving this page does not stop it, and coming back picks it up again.</p>
  <div class="progress" role="progressbar" aria-labelledby="q-title-2" aria-valuemin="0" aria-valuemax="100" aria-valuenow="0"><i id="q-bar"></i></div>
  <div class="progress-meta"><span id="q-msg">Starting…</span><span id="q-pct">0%</span></div>
  <p class="reconnect" id="q-reconnect" role="status" hidden>Reconnecting to the job…</p>
  <div class="notice bad fail" id="q-fail" role="alert" hidden>
    <div><b>Quantization failed.</b> <span id="q-fail-msg"></span></div>
    <span class="actions"><button type="button" class="btn sm" id="q-retry">Try again</button></span>
  </div>
  <pre class="log" id="q-log" aria-label="Job log"></pre>
</section>

<section class="card" data-qstep="3" hidden aria-labelledby="q-title-3">
  <h2 class="card-title" id="q-title-3">Quantized model ready</h2>
  <p class="card-note">It is in your models directory and registered, so you can serve it from the Models page.</p>
  <p class="label" id="q-out-label">Output directory</p>
  <pre class="log out" id="q-out" aria-labelledby="q-out-label"></pre>
  <div class="grid follow">
    <div class="card quiet">
      <h3 class="card-title">Push to Hugging Face</h3>
      <p class="card-note">Publish the quantized model to a repository on the Hub.</p>
      <div class="row"><button type="button" class="btn sm" id="q-push">Push to Hugging Face</button></div>
      <div id="q-push-panel"></div>
    </div>
  </div>
  <div class="row actions"><button type="button" class="btn" id="q-again">Quantize another model</button></div>
</section>`;

/** The panel's own rules, after the kit's. The page is the panel's scroll column (the shell does not frame it). */
export const STYLE = String.raw`
:host{display:block;height:100%;overflow-y:auto;overflow-x:hidden;color:var(--ink)}
[hidden]{display:none!important}
.page{max-width:880px}
.steps{list-style:none;padding:0}
.field>.seg{align-self:flex-start;max-width:100%}
.step.failed{color:var(--bad)}
.step.failed .n{background:var(--bad-soft);border-color:transparent;color:var(--bad)}
.card>.card-note{margin:4px 0 18px;max-width:68ch}
.card .row{margin-top:4px}
.card .row.actions{margin-top:20px}
.result:not(:empty){margin:0 0 14px}
.drop{border-radius:var(--radius-md)}
.drop.over{outline:2px dashed var(--accent);outline-offset:3px}
.field>label .value{color:var(--dim);font-weight:500;margin-left:6px}
#panel-message{margin-bottom:16px}
#panel-message:empty{display:none}
.reconnect{display:flex;align-items:center;gap:8px;margin-top:10px;font-size:var(--text-sm);color:var(--dim)}
.reconnect::before{content:"";width:7px;height:7px;border-radius:50%;background:var(--warn);animation:q-pulse 1.2s var(--ease) infinite alternate}
@keyframes q-pulse{from{opacity:1}to{opacity:.3}}
.fail{margin-top:14px}
.log{margin-top:16px}
.label{font-size:var(--text-sm);font-weight:600;margin:0 0 6px}
.log.out{margin-top:0;max-height:none;font-size:var(--text-sm)}
.follow{margin-top:18px}
.follow .card-title{font-size:var(--text-md)}
.follow .card>.card-note{margin-bottom:12px}
.pushpanel:not(:empty){margin-top:14px}
@media (prefers-reduced-motion:reduce){.reconnect::before{animation:none}}
`;
