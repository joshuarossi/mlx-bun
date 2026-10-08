export const HTML = `<div class="wrap narrow lit" id="s-finetune"><div class="eyebrow">Workflow · fine-tune</div>
      <h1 class="title">Fine-tune <span class="grad g-green">a LoRA.</span></h1>
      <p class="lead">Train a low-rank adapter on top of any local model — SFT or DPO — and watch the loss curve land
      live. Hot-swappable onto the quantized base, <strong>no full reload.</strong></p>

      <div class="steps" id="f-steps"></div>

      <!-- step 1: base -->
      <div class="card" data-fstep="0">
        <h2 style="font-size:24px;margin-bottom:4px">Base model</h2>
        <p class="lead" style="margin:6px 0 22px;font-size:14.5px">The model you're adapting. Point at a local model directory or snapshot path.</p>
        <div class="field">
          <label>Model directory / path</label>
          <div id="f-drop">
            <input type="text" id="f-model" data-spotlight="finetune-base" placeholder="/abs/path/to/model  or  mlx-community/Qwen3-8B-4bit" autocomplete="off">
          </div>
          <input type="file" id="f-folder" webkitdirectory directory style="display:none">
          <div class="hint">An OptiQ quant or any supported local model works — type a path/repo id, or <strong>choose / drop a folder</strong> below.</div>
        </div>
        <div class="btnrow">
          <button class="btn ghost" id="f-browse">Choose folder…</button>
          <button class="btn primary" id="f-next0">Continue</button>
        </div>
      </div>

      <!-- step 2: dataset -->
      <div class="card" data-fstep="1" style="display:none">
        <h2 style="font-size:24px;margin-bottom:4px">Dataset</h2>
        <p class="lead" style="margin:6px 0 22px;font-size:14.5px">A directory with <code>train.jsonl</code> (and optionally <code>valid.jsonl</code>).
          Standard shapes accepted: <code>{"text":…}</code>, <code>{"prompt":…,"completion":…}</code>, <code>{"messages":[…]}</code>.</p>
        <div class="field">
          <label>Dataset directory</label>
          <input type="text" id="f-data" placeholder="/abs/path/to/dataset" autocomplete="off">
        </div>
        <div class="btnrow"><button class="btn ghost" id="f-inspect">Inspect</button></div>
        <div id="f-inspect-out"></div>
        <div class="btnrow">
          <button class="btn ghost" data-fback>Back</button>
          <button class="btn primary" id="f-next1" disabled>Continue</button>
        </div>
      </div>

      <!-- step 3: hyperparameters -->
      <div class="card" data-fstep="2" style="display:none">
        <h2 style="font-size:24px;margin-bottom:16px">Hyperparameters</h2>
        <div class="field">
          <label>Training objective</label>
          <div class="seg" id="f-method">
            <button data-v="sft" class="on">SFT</button>
            <button data-v="dpo">DPO</button>
            <button data-v="orpo">ORPO</button>
          </div>
          <div class="hint" id="f-method-hint">Supervised fine-tuning — data is messages or prompt+completion.</div>
        </div>

        <div id="f-dpo-extra" style="display:none">
          <div class="flash warn" style="margin-bottom:18px">
            <strong>DPO needs a lower learning rate.</strong> Default 5e-5 (~4× lower than SFT) with warmup. Too high and the preference loss blows out the reward margin. Confirm <em>chosen</em>/<em>rejected</em> are both valid completions of the same prompt.
          </div>
          <div class="hpgrid" style="margin-bottom:18px">
            <div class="field"><label>DPO beta (KL strength)</label><input type="number" id="f-beta" value="0.1" step="0.01" min="0.01" max="1"></div>
            <div class="field"><label>LR schedule</label>
              <select id="f-sched"><option value="cosine">cosine (recommended)</option><option value="constant">constant</option></select></div>
          </div>
        </div>

        <div id="f-orpo-extra" style="display:none">
          <div class="flash warn" style="margin-bottom:18px">
            <strong>ORPO is reference-free.</strong> One monolithic loss (SFT + odds-ratio), no reference model — half the forwards of DPO. Default LR 1e-5 (lower than DPO: the loss carries a full SFT term). λ weights only the odds-ratio term. Data is {prompt, chosen, rejected}.
          </div>
          <div class="hpgrid" style="margin-bottom:18px">
            <div class="field"><label>ORPO λ (odds-ratio weight)</label><input type="number" id="f-orpo-lambda" value="0.1" step="0.05" min="0.01" max="2"></div>
            <div class="field"><label>LR schedule</label>
              <select id="f-orpo-sched"><option value="cosine">cosine (recommended)</option><option value="constant">constant</option></select></div>
          </div>
          <div class="field" style="margin-bottom:18px">
            <label>SFT scope</label>
            <div class="seg" id="f-orpo-scope">
              <button data-v="full" class="on">full</button>
              <button data-v="response">response</button>
            </div>
            <div class="hint">full = paper/TRL chosen-NLL over the whole sequence; response = pre-2026-07 response-only.</div>
          </div>
        </div>

        <div class="hpgrid">
          <div class="field"><label>Rank</label><input type="number" id="f-rank" value="8" min="1" max="128"></div>
          <div class="field"><label>Scale (alpha = rank × scale)</label><input type="number" id="f-scale" value="20" step="0.5" min="0"></div>
          <div class="field"><label>Dropout</label><input type="number" id="f-dropout" value="0" step="0.01" min="0" max="0.5"></div>
          <div class="field"><label>Target modules</label><input type="text" id="f-modules" value="q_proj,v_proj"></div>
          <div class="field"><label>num_layers (-1 = all)</label><input type="number" id="f-layers" value="16" min="-1"></div>
          <div class="field"><label>iters</label><input type="number" id="f-iters" value="500" min="10"></div>
          <div class="field"><label>batch_size</label><input type="number" id="f-batch" value="1" min="1" max="16"></div>
          <div class="field"><label>learning rate</label><input type="number" id="f-lr" value="0.0002" step="0.00001" min="0"></div>
          <div class="field"><label>max_seq_length</label><input type="number" id="f-seq" value="1024" min="128"></div>
        </div>
        <div class="btnrow">
          <button class="btn ghost" data-fback>Back</button>
          <button class="btn primary" id="f-submit">Start training</button>
        </div>
      </div>

      <!-- step 4: train -->
      <div class="card" data-fstep="3" style="display:none">
        <h2 style="font-size:24px;margin-bottom:16px">Training</h2>
        <div class="progressbar green"><i id="f-bar"></i></div>
        <div class="progmeta"><span id="f-msg">Starting…</span><span id="f-pct">0%</span></div>

        <div class="chartcard">
          <div class="chart-legend">
            <span class="lg"><span class="sw" style="background:var(--green)"></span>train loss</span>
            <span class="lg" id="f-leg-val" style="display:none"><span class="sw" style="background:var(--blue)"></span>val loss</span>
          </div>
          <div class="chart-wrap">
            <svg id="f-chart" viewBox="0 0 600 200" preserveAspectRatio="none" style="width:100%;height:200px;display:block">
              <text x="300" y="104" text-anchor="middle" fill="var(--dimmer)" font-size="13" id="f-chart-empty">waiting for the first metric…</text>
            </svg>
          </div>
          <div class="chart-stats">
            <div class="cs"><b>step</b><span class="num" id="f-step">—</span></div>
            <div class="cs"><b>train loss</b><span class="num grad g-green" id="f-loss">—</span></div>
            <div class="cs"><b>learning rate</b><span class="num" id="f-curlr">—</span></div>
            <div class="cs"><b>tok/s</b><span class="num" id="f-curtps">—</span></div>
          </div>
        </div>
        <div class="logbox" id="f-log"></div>
      </div>

      <!-- step 5: done -->
      <div class="card" data-fstep="4" style="display:none">
        <h2 style="font-size:24px;margin-bottom:6px"><span class="grad g-green">Done.</span></h2>
        <p class="lead" style="margin:6px 0 18px;font-size:14.5px">Adapter trained and saved.</p>
        <div class="field"><label>Adapter path</label>
          <pre class="logbox" id="f-out" style="max-height:none;margin-top:0"></pre></div>
        <div class="grid g4" style="margin-top:8px">
          <div class="card"><h3>Merge into base</h3><div class="cap">Fold two adapters together (or an adapter into a base adapter) into the weights for a standalone model.</div>
            <div class="field" style="margin-top:14px;margin-bottom:10px"><label>Adapter A</label><input type="text" id="f-merge-a" placeholder="/abs/path/to/adapter" autocomplete="off"></div>
            <div class="field" style="margin-bottom:10px"><label>Adapter B</label><input type="text" id="f-merge-b" placeholder="/abs/path/to/other-adapter" autocomplete="off"></div>
            <div class="btnrow" style="margin-top:0"><button class="btn ghost sm" id="f-merge-go">Merge</button></div>
            <div id="f-merge-out"></div>
          </div>
          <div class="card"><h3>Export model dir</h3><div class="cap">Bundle base + adapter into one drop-in directory.</div>
            <div class="field" style="margin-top:14px;margin-bottom:10px"><label>Base model</label><input type="text" id="f-exp-base" placeholder="/abs/path/to/base" autocomplete="off"></div>
            <div class="field" style="margin-bottom:10px"><label>Adapter path</label><input type="text" id="f-exp-adapter" placeholder="/abs/path/to/adapter" autocomplete="off"></div>
            <div class="btnrow" style="margin-top:0"><button class="btn ghost sm" id="f-exp-go">Export</button></div>
            <div id="f-exp-out"></div>
          </div>
          <div class="card"><h3>Push to HF</h3><div class="cap">Publish the trained adapter to a Hugging Face repo.</div>
            <div class="btnrow" style="margin-top:14px"><button class="btn ghost sm" id="f-push">Push to HF</button></div>
            <div id="f-push-panel"></div>
          </div>
        </div>
        <div class="btnrow"><button class="btn ghost" id="f-again">Train another</button></div>
      </div>
<p id="panel-message" role="status"></p></div>`;
export const STYLE = `:host{display:block;height:100%;overflow-y:auto;color:var(--ink,CanvasText)}.wrap{max-width:860px;margin:0 auto;padding:46px 28px 120px}@media(max-width:760px){.wrap{padding:34px 18px 100px}}*{box-sizing:border-box}h1,h2,h3,p,pre{margin:0}button,input,textarea,select{font-family:inherit}
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
