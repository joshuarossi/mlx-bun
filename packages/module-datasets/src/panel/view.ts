// The dataset wizard's markup and its own rules. The vocabulary (page, cards, fields, the step rail, notices, progress,
// stats, the log, the empty state) is the kit's BASE_CSS, which index.ts puts ahead of STYLE in the shadow root; colours
// and sizes come from the tokens. The ids are the controller's, the chat assistant's (`d-steps`) and the tests'.
import { esc } from "@mlx-bun/web-kit";

export const STEPS = ["Template", "Inputs", "Generate", "Done"] as const;
export const TEMPLATE = 0, INPUTS = 1, RUN = 2, DONE = 3;

/** A template's input as `GET /api/dataset/templates` describes it. */
export interface DatasetField {
  name: string;
  label?: string;
  type?: "textarea" | "number" | "text";
  hint?: string;
  default?: unknown;
  required?: boolean;
}
export interface DatasetTemplate {
  id: string;
  label?: string;
  description?: string;
  needs_llm?: boolean;
  output_format?: string;
  fields?: DatasetField[];
}

/** The step rail. Each step carries the kit's `.step` (with `.current`/`.done`) and the `.s` (with `.cur`) the chat
 * assistant reads to tell where the wizard is. */
export function stepsHtml(names: readonly string[], current: number, failed = false): string {
  return names.map((name, index) => {
    const state = index === current ? " current cur" + (failed ? " failed" : "") : index < current ? " done" : "";
    return `<li class="step s${state}"${index === current ? ' aria-current="step"' : ""}><span class="n">${index + 1}</span>${esc(name)}</li>`;
  }).join("");
}

export const failureHtml = (title: string, error: string): string => `<div class="notice bad" role="alert"><div><b>${esc(title)}</b> ${esc(error)}</div></div>`;

/** Placeholder tiles while the templates load. */
export const TEMPLATES_LOADING = Array.from({ length: 4 }, () =>
  '<div class="tpl loading" aria-hidden="true"><span class="skeleton" style="width:55%"></span><span class="skeleton" style="width:92%"></span><span class="skeleton" style="width:70%"></span></div>').join("");

export const TEMPLATES_EMPTY = '<div class="empty"><h3>No dataset templates</h3><p>The server answered with no templates, so there is nothing to build from. Check that the server is running this version of mlx-bun, then reload.</p>' +
  '<div class="actions"><button type="button" class="btn sm" data-reload>Reload</button></div></div>';

export const templatesFailedHtml = (error: string): string =>
  `<div class="notice bad" role="alert"><div><b>Could not load the templates.</b> ${esc(error)}</div><span class="actions"><button type="button" class="btn sm" data-reload>Try again</button></span></div>`;

/** The template grid: offline templates first, then the ones that write rows with the served model. */
export function templatesHtml(templates: readonly DatasetTemplate[]): string {
  return [...templates].sort((a, b) => Number(!!a.needs_llm) - Number(!!b.needs_llm)).map((template) =>
    `<button type="button" class="tpl" data-tid="${esc(template.id)}">` +
      `<span class="tpl-name">${esc(template.label || template.id)}</span>` +
      '<span class="tpl-tags">' +
        (template.needs_llm ? '<span class="tag accent">Uses the served model</span>' : '<span class="tag">Offline</span>') +
        (template.output_format ? `<span class="tag mono">${esc(template.output_format)}</span>` : "") +
      "</span>" +
      `<span class="tpl-desc">${esc(template.description || "")}</span>` +
    "</button>").join("");
}

/** A template's inputs, typed as declared: a text area, a number or a line of text, each with its default. A field's
 * hint stays visible under it; a text area also shows it as its placeholder, where multi-line examples read best. */
export function fieldsHtml(fields: readonly DatasetField[]): string {
  return fields.map((field, index) => {
    const id = `d-field-${index}`;
    const placeholder = field.hint && field.type === "textarea" ? ` placeholder="${esc(field.hint)}"` : "";
    const value = field.default != null ? field.default : "";
    const control = field.type === "textarea"
      ? `<textarea class="textarea mono" id="${id}" data-fld="${esc(field.name)}" rows="6"${placeholder}>${esc(value)}</textarea>`
      : `<input class="input${field.type === "number" ? " num" : ""}" type="${field.type === "number" ? "number" : "text"}" id="${id}" data-fld="${esc(field.name)}" value="${esc(value)}"${placeholder} autocomplete="off">`;
    return `<div class="field"><label for="${id}">${esc(field.label || field.name)}${field.required ? ' <span class="req">Required</span>' : ""}</label>${control}` +
      (field.hint ? `<p class="hint">${esc(field.hint)}</p>` : "") + "</div>";
  }).join("");
}

export const MARKUP = `
<header class="page-head">
  <div>
    <h1 class="page-title">Build a dataset</h1>
    <p class="page-lead">Turn pairs, documents, code or seed prompts into JSONL for fine-tuning.</p>
  </div>
</header>
<p id="panel-message" class="notice" role="status"></p>
<ol class="steps" id="d-steps" aria-label="Dataset steps"></ol>

<section class="card" data-dstep="0" aria-labelledby="d-title-0">
  <h2 class="card-title" id="d-title-0">Choose a template</h2>
  <p class="card-note">Offline templates only reshape what you give them. Templates that use the served model write new rows with the model this server runs.</p>
  <div class="grid cols-2" id="d-templates" aria-live="polite"></div>
</section>

<section class="card" data-dstep="1" hidden aria-labelledby="d-form-title">
  <h2 class="card-title" id="d-form-title">—</h2>
  <p class="card-note" id="d-form-desc"></p>
  <p class="notice model-note" id="d-model-note" hidden></p>
  <div id="d-form"></div>
  <div class="result" id="d-submit-out" aria-live="polite"></div>
  <div class="row">
    <button type="button" class="btn" data-dback>Back</button>
    <button type="button" class="btn primary" id="d-submit">Generate</button>
  </div>
</section>

<section class="card" data-dstep="2" hidden aria-labelledby="d-title-2">
  <h2 class="card-title" id="d-title-2">Generating</h2>
  <p class="card-note">The job runs on the server. Leaving this page does not stop it, and coming back picks it up again.</p>
  <div class="progress" role="progressbar" aria-labelledby="d-title-2" aria-valuemin="0" aria-valuemax="100" aria-valuenow="0"><i id="d-bar"></i></div>
  <div class="progress-meta"><span id="d-msg">Starting…</span><span id="d-pct">0%</span></div>
  <p class="reconnect" id="d-reconnect" role="status" hidden>Reconnecting to the job…</p>
  <div class="notice bad fail" id="d-fail" role="alert" hidden>
    <div><b>Generation failed.</b> <span id="d-fail-msg"></span></div>
    <span class="actions"><button type="button" class="btn sm" id="d-retry">Try again</button></span>
  </div>
  <pre class="log" id="d-log" aria-label="Job log"></pre>
</section>

<section class="card" data-dstep="3" hidden aria-labelledby="d-title-3">
  <h2 class="card-title" id="d-title-3">Dataset ready</h2>
  <p class="card-note">Point the fine-tune wizard's Dataset step at this directory to train on it.</p>
  <div class="counts">
    <div class="stat"><b class="num" id="d-ntrain">—</b><span>Training rows</span></div>
    <div class="stat"><b class="num" id="d-nvalid">—</b><span>Validation rows</span></div>
  </div>
  <p class="label" id="d-out-label">Output directory</p>
  <pre class="log out" id="d-out" aria-labelledby="d-out-label"></pre>
  <div class="grid follow">
    <div class="card quiet">
      <h3 class="card-title">Push to Hugging Face</h3>
      <p class="card-note">Publish the JSONL files to a dataset repository on the Hub.</p>
      <div class="row"><button type="button" class="btn sm" id="d-push">Push to Hugging Face</button></div>
      <div id="d-push-panel"></div>
    </div>
  </div>
  <div class="row actions"><button type="button" class="btn" id="d-again">Build another dataset</button></div>
</section>`;

/** The panel's own rules, after the kit's. The page is the panel's scroll column (the shell does not frame it). */
export const STYLE = String.raw`
:host{display:block;height:100%;overflow-y:auto;overflow-x:hidden;color:var(--ink)}
[hidden]{display:none!important}
.page{max-width:960px}
.steps{list-style:none;padding:0}
.step.failed{color:var(--bad)}
.step.failed .n{background:var(--bad-soft);border-color:transparent;color:var(--bad)}
.card>.card-note{margin:4px 0 18px;max-width:72ch}
.card .row{margin-top:4px}
.card .row.actions{margin-top:20px}
.result:not(:empty){margin:0 0 14px}
#panel-message{margin-bottom:16px}
#panel-message:empty{display:none}
#d-templates>.empty,#d-templates>.notice{grid-column:1/-1}
.tpl{appearance:none;display:flex;flex-direction:column;align-items:stretch;gap:8px;min-width:0;text-align:left;cursor:pointer;
  background:var(--surface);border:1px solid var(--line);border-radius:var(--radius-md);padding:14px 16px;color:var(--ink);font:inherit;
  transition:border-color var(--fast) var(--ease),background var(--fast) var(--ease)}
.tpl:hover{border-color:var(--line-strong);background:var(--raised)}
.tpl.loading{cursor:default;min-height:104px}
.tpl.loading:hover{border-color:var(--line);background:var(--surface)}
.tpl-tags{display:flex;align-items:center;gap:6px;flex-wrap:wrap}
.tpl-name{font-size:var(--text-md);font-weight:600;letter-spacing:-.005em}
.tpl-desc{color:var(--dim);font-size:var(--text-sm);line-height:1.5}
.model-note{margin:-4px 0 18px;font-size:var(--text-sm);color:var(--dim)}
.field>label .req{font-weight:500;color:var(--dimmer);margin-left:6px}
.reconnect{display:flex;align-items:center;gap:8px;margin-top:10px;font-size:var(--text-sm);color:var(--dim)}
.reconnect::before{content:"";width:7px;height:7px;border-radius:50%;background:var(--warn);animation:d-pulse 1.2s var(--ease) infinite alternate}
@keyframes d-pulse{from{opacity:1}to{opacity:.3}}
.fail{margin-top:14px}
.log{margin-top:16px}
.counts{display:flex;flex-wrap:wrap;gap:12px 48px;margin:0 0 18px}
.label{font-size:var(--text-sm);font-weight:600;margin:0 0 6px}
.log.out{margin-top:0;max-height:none;font-size:var(--text-sm)}
.follow{margin-top:18px}
.follow .card-title{font-size:var(--text-md)}
.follow .card>.card-note{margin-bottom:12px}
.pushpanel:not(:empty){margin-top:14px}
@media (prefers-reduced-motion:reduce){.reconnect::before{animation:none}.tpl{transition:none}}
`;
