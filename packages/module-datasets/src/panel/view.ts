export const HTML = `<div id="s-dataset"><div class="eyebrow">Workflow · dataset</div>
      <h1 class="title">Build <span class="grad g-pink">a dataset.</span></h1>
      <p class="lead">Turn pairs, docs, code, and seeds into clean JSONL the fine-tune workflow can consume.
      Some templates run entirely offline; <strong>LLM-driven ones use the local model on this server.</strong></p>

      <div class="steps" id="d-steps"></div>

      <!-- step 1: pick template -->
      <div data-dstep="0">
        <div id="d-templates" class="grid" style="grid-template-columns:repeat(auto-fill,minmax(300px,1fr));margin-top:6px"></div>
      </div>

      <!-- step 2: fill form -->
      <div class="card" data-dstep="1" style="display:none;max-width:860px">
        <h2 style="font-size:24px;margin-bottom:4px" id="d-form-title">—</h2>
        <p class="lead" style="margin:6px 0 22px;font-size:14.5px" id="d-form-desc"></p>
        <div id="d-form"></div>
        <div class="btnrow">
          <button class="btn ghost" data-dback>Back</button>
          <button class="btn primary" id="d-submit">Generate</button>
        </div>
      </div>

      <!-- step 3: run -->
      <div class="card" data-dstep="2" style="display:none;max-width:860px">
        <h2 style="font-size:24px;margin-bottom:16px">Generating</h2>
        <div class="progressbar"><i id="d-bar"></i></div>
        <div class="progmeta"><span id="d-msg">Starting…</span><span id="d-pct">0%</span></div>
        <div class="logbox" id="d-log"></div>
      </div>

      <!-- step 4: done -->
      <div class="card" data-dstep="3" style="display:none;max-width:860px">
        <h2 style="font-size:24px;margin-bottom:6px"><span class="grad g-green">Done.</span></h2>
        <div class="grid g4" style="margin:6px 0 18px">
          <div class="card"><h3>Train rows</h3><div class="stat num grad g-green" id="d-ntrain">—</div></div>
          <div class="card"><h3>Valid rows</h3><div class="stat num grad g-blue" id="d-nvalid">—</div></div>
        </div>
        <div class="field"><label>Output directory</label>
          <pre class="logbox" id="d-out" style="max-height:none;margin-top:0"></pre></div>
        <div class="flash ok">Point Fine-tune → Dataset at this directory to train on it.</div>
        <div class="grid g4" style="margin-top:14px">
          <div class="card"><h3>Push to HF (dataset repo)</h3><div class="cap">Publish this JSONL dataset to a Hugging Face dataset repo.</div>
            <div class="btnrow" style="margin-top:14px"><button class="btn ghost sm" id="d-push">Push to HF</button></div>
            <div id="d-push-panel"></div>
          </div>
        </div>
        <div class="btnrow"><button class="btn ghost" id="d-again">Build another</button></div>
      </div>
<p id="panel-message" role="status"></p></div>`;
export const STYLE = `:host{display:block;color:var(--ink,CanvasText)}*{box-sizing:border-box}h1,h2,h3,p,pre{margin:0}button,input,textarea,select{font-family:inherit}
  /* ─── shared typographic bits ─── */
  .eyebrow{font-size:12.5px;font-weight:600;letter-spacing:.22em;text-transform:uppercase;color:var(--dim);margin-bottom:14px}
  h1.title{font-size:clamp(38px,5.4vw,68px);font-weight:700;letter-spacing:-.032em;line-height:1.02}
  .lead{font-size:clamp(15px,1.4vw,19px);line-height:1.55;color:var(--dim);max-width:66ch;margin-top:18px}
  .lead strong{color:var(--ink);font-weight:600}
  h2{font-size:clamp(26px,3.6vw,46px);font-weight:700;letter-spacing:-.026em;line-height:1.06}
  h2 .soft{color:var(--dimmer)}
  h3.kicker{font-size:12.5px;font-weight:600;letter-spacing:.14em;text-transform:uppercase;color:var(--dim);margin-bottom:14px}


  /* ─── cards ─── */
  .grid{display:grid;gap:14px}
  .g4{grid-template-columns:repeat(auto-fit,minmax(240px,1fr))}
  .card{background:var(--card);border:1px solid var(--hairline);border-radius:20px;
    padding:24px 26px;transition:background .3s var(--ease),border-color .3s var(--ease)}
  .card:hover{background:var(--card-hover)}
  .card h3{font-size:12.5px;font-weight:600;letter-spacing:.14em;text-transform:uppercase;color:var(--dim);margin-bottom:14px}
  .stat{font-size:clamp(28px,3.2vw,42px);font-weight:700;letter-spacing:-.025em;line-height:1.05}
  .stat small{font-size:.42em;font-weight:600;color:var(--dim);letter-spacing:0;margin-left:6px}
  .card .cap{margin-top:8px;font-size:13.5px;color:var(--dim);line-height:1.5}
  .kv{display:flex;justify-content:space-between;gap:10px;padding:5px 0;font-size:14.5px;border-bottom:1px solid var(--hairline-soft)}
  .kv:last-child{border-bottom:none}
  .kv b{font-weight:500;color:var(--dim)}
  .kv span{font-weight:600}
  .meter{height:5px;border-radius:3px;background:rgba(255,255,255,.09);margin-top:16px;overflow:hidden}
  .meter i{display:block;height:100%;border-radius:3px;width:0%;
    background:linear-gradient(90deg,var(--cyan),var(--blue));transition:width .8s var(--ease)}
  .meter.warm i{background:linear-gradient(90deg,var(--orange),var(--pink))}
  .meter.green i{background:linear-gradient(90deg,#a8ff9e,var(--green))}


  /* ─── forms (used by all three wizards) ─── */
  .field{margin-bottom:18px}
  .field>label{display:block;font-size:13px;font-weight:600;color:var(--ink);margin-bottom:8px;letter-spacing:-.01em}
  .field .hint{font-size:12.5px;color:var(--dim);margin-top:7px;line-height:1.5}
  input[type=text],input[type=number],input[type=password],textarea,select{
    width:100%;background:var(--card);border:1px solid var(--hairline);border-radius:12px;
    color:var(--ink);font:14.5px/1.5 inherit;padding:11px 14px;outline:none;
    transition:border-color .22s var(--ease),background .22s var(--ease)}
  input::placeholder,textarea::placeholder{color:var(--dimmer)}
  input:focus,textarea:focus,select:focus{border-color:rgba(10,132,255,.55);background:var(--card-hover)}
  textarea{resize:vertical;min-height:96px;font-family:var(--mono);font-size:13px}
  select{appearance:none;-webkit-appearance:none;cursor:pointer;
    background-image:url("data:image/svg+xml;charset=US-ASCII,%3Csvg xmlns='http://www.w3.org/2000/svg' width='12' height='8' viewBox='0 0 12 8'%3E%3Cpath fill='%2386868b' d='M1 1l5 5 5-5'/%3E%3C/svg%3E");
    background-repeat:no-repeat;background-position:right 14px center;padding-right:34px}
  .hpgrid{display:grid;grid-template-columns:1fr 1fr;gap:14px}
  .hpgrid .field{margin-bottom:0}
  input[type=range]{width:100%;accent-color:var(--blue);background:transparent;cursor:pointer;height:24px}

  /* segmented control */
  .seg{display:inline-flex;background:var(--card);border:1px solid var(--hairline);border-radius:12px;padding:3px;gap:3px}
  .seg button{appearance:none;background:none;border:none;cursor:pointer;color:var(--dim);
    font:600 13.5px/1 inherit;padding:9px 18px;border-radius:9px;transition:all .22s var(--ease)}
  .seg button.on{background:rgba(255,255,255,.12);color:var(--ink)}
  .seg button:hover:not(.on){color:var(--ink)}

  /* buttons */
  .btn{appearance:none;border:none;cursor:pointer;font:600 14px/1 inherit;border-radius:13px;
    padding:0 22px;height:46px;display:inline-flex;align-items:center;justify-content:center;gap:8px;
    transition:filter .2s,opacity .2s,background .22s var(--ease)}
  .btn.primary{background:linear-gradient(120deg,var(--blue),var(--purple));color:#fff}
  .btn.primary:hover{filter:brightness(1.13)}
  .btn.ghost{background:var(--card);border:1px solid var(--hairline);color:var(--ink)}
  .btn.ghost:hover{background:var(--card-hover)}
  .btn:disabled{filter:grayscale(.7) brightness(.55);cursor:default;opacity:.7}
  .btn.sm{height:38px;padding:0 16px;font-size:13px;border-radius:11px}
  .btnrow{display:flex;gap:10px;margin-top:24px;flex-wrap:wrap;align-items:center}

  /* flash / status banners */
  .flash{border-radius:14px;padding:13px 16px;font-size:14px;line-height:1.5;border:1px solid;margin-top:14px}
  .flash.ok{background:rgba(48,209,88,.10);border-color:rgba(48,209,88,.35);color:#b8f5c4}
  .flash.warn{background:rgba(255,159,10,.10);border-color:rgba(255,159,10,.35);color:#ffe0a8}
  .flash.err{background:rgba(255,69,58,.10);border-color:rgba(255,69,58,.35);color:#ffb8b3}
  .flash code{background:rgba(0,0,0,.3)}
  .flash strong{color:var(--ink)}

  .soon{display:inline-flex;align-items:center;gap:6px;font-size:11px;font-weight:600;letter-spacing:.06em;
    text-transform:uppercase;color:var(--dimmer);border:1px solid var(--hairline-soft);border-radius:999px;padding:3px 10px}

  /* step indicator */
  .steps{display:flex;flex-wrap:wrap;gap:6px;margin:6px 0 30px;font:600 12px var(--mono);
    text-transform:uppercase;letter-spacing:.05em;color:var(--dimmer)}
  .steps .s{display:inline-flex;align-items:center;gap:8px}
  .steps .s .n{display:inline-flex;align-items:center;justify-content:center;width:22px;height:22px;border-radius:50%;
    border:1px solid var(--hairline);font-size:11px;color:var(--dim);transition:all .3s var(--ease)}
  .steps .s.done .n{background:rgba(255,255,255,.10);color:var(--ink);border-color:transparent}
  .steps .s.cur .n{background:linear-gradient(120deg,var(--blue),var(--purple));color:#fff;border-color:transparent}
  .steps .s.cur{color:var(--ink)}
  .steps .s.done{color:var(--dim)}
  .steps .arrow{color:var(--dimmer);margin:0 2px}

  /* progress + log shared by every job stream */
  .progressbar{height:8px;background:rgba(255,255,255,.09);border-radius:5px;overflow:hidden}
  .progressbar i{display:block;height:100%;width:0%;border-radius:5px;
    background:linear-gradient(90deg,var(--cyan),var(--blue));transition:width .5s var(--ease)}
  .progressbar.green i{background:linear-gradient(90deg,#a8ff9e,var(--green))}
  .progmeta{display:flex;justify-content:space-between;font-size:12.5px;color:var(--dim);margin-top:8px}
  .logbox{margin-top:18px;background:var(--code-bg-soft);border:1px solid var(--hairline-soft);border-radius:14px;
    padding:14px 16px;max-height:340px;overflow-y:auto;font:11.5px/1.55 var(--mono);color:rgba(245,245,247,.7);white-space:pre-wrap;word-break:break-word}
  .logbox:empty::before{content:"waiting for output…";color:var(--dimmer)}

  /* shimmer skeletons */
  .shimmer{background:linear-gradient(100deg,rgba(255,255,255,.04) 30%,rgba(255,255,255,.10) 50%,rgba(255,255,255,.04) 70%);
    background-size:200% 100%;animation:sh 1.4s ease-in-out infinite;border-radius:8px;color:transparent!important}
  @keyframes sh{0%{background-position:200% 0}100%{background-position:-200% 0}}


  /* loss chart */
  .chartcard{margin-top:20px}
  /* the chart's SVG gridlines are hardcoded white-on-dark (drawChart()), so
     the wrap keeps the always-dark code-panel surface for contrast rather
     than following the chat theme — same rationale as .bubble pre above. */
  .chart-wrap{position:relative;background:var(--code-bg-soft);border:1px solid var(--hairline-soft);border-radius:14px;padding:14px;margin-top:6px}
  .chart-legend{display:flex;gap:18px;font-size:12px;color:var(--dim);margin-bottom:8px}
  .chart-legend .lg{display:inline-flex;align-items:center;gap:7px}
  .chart-legend .sw{width:14px;height:3px;border-radius:2px}
  .chart-stats{display:flex;gap:22px;flex-wrap:wrap;margin-top:12px;font-size:13px}
  .chart-stats .cs b{display:block;font-size:11px;font-weight:600;letter-spacing:.1em;text-transform:uppercase;color:var(--dim);margin-bottom:3px}
  .chart-stats .cs span{font-size:20px;font-weight:700;letter-spacing:-.02em}

.pushpanel{margin-top:18px;padding:18px;border:1px solid var(--hairline);border-radius:14px}.pushpanel .field{margin-bottom:12px}.chk{display:flex;gap:9px;align-items:center}.chk input{width:auto}
  /* gradient text helpers (lifted from status/chat pages) */
  .grad{background-clip:text;-webkit-background-clip:text;color:transparent}
  .g-hero{background-image:linear-gradient(96deg,var(--orange) 0%,var(--pink) 30%,var(--purple) 62%,var(--blue) 100%)}
  .g-blue{background-image:linear-gradient(94deg,var(--cyan),var(--blue) 55%,var(--indigo))}
  .g-green{background-image:linear-gradient(94deg,#a8ff9e,var(--green) 45%,var(--cyan))}
  .g-pink{background-image:linear-gradient(94deg,var(--orange),var(--pink) 55%,var(--purple))}
  .g-purple{background-image:linear-gradient(94deg,var(--purple),var(--indigo) 55%,var(--blue))}


code{font-size:.86em;background:rgba(127,127,127,.16);padding:2px 8px;border-radius:6px}`;
