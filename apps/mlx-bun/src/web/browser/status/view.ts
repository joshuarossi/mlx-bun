// The status page's markup: what this server is doing now (the served model, memory, caches, downloads), the library
// as the fit model judges it for this Mac, and the fit at the maximum context across Apple silicon. The ids are the
// controller's targets; the classes are the kit's vocabulary, so the page sits in the shell's frame like a panel.
export const STATUS_MARKUP = `
<div class="shell-panel-scroll"><div class="shell-panel" id="status-page">
  <div class="page-head">
    <div>
      <h2 class="shell-panel-title" style="margin:0">Status</h2>
      <p class="page-lead">What this server is doing right now, and what fits on this Mac.</p>
    </div>
    <div class="muted num" style="font-size:var(--text-sm)">updated <span id="st-updated">never</span></div>
  </div>

  <section class="section">
    <h3 class="section-title">Serving</h3>
    <div class="card" style="margin-bottom:12px">
      <div class="row between">
        <div style="min-width:0"><div class="st-model mono" id="st-model-id">—</div><div class="muted num" id="st-model-meta" style="font-size:var(--text-sm);margin-top:4px">—</div></div>
        <span class="tag" id="st-uptime-tag">up <span id="st-uptime">—</span></span>
      </div>
    </div>
    <div class="grid cols-3">
      <div class="card stat"><b><span id="st-tps">—</span><small>tok/s</small></b><span id="st-tps-cap">predicted decode speed from weights and bandwidth</span></div>
      <div class="card stat"><b><span id="st-safe-ctx">—</span><small>tokens</small></b><span>largest safe context, solved from KV growth and prefill</span></div>
      <div class="card">
        <div class="section-title" style="margin-bottom:4px">Memory</div>
        <div class="kv"><b>weights</b><span id="st-weights">—</span></div>
        <div class="kv"><b>usable</b><span id="st-usable">—</span></div>
        <div class="kv"><b>budget</b><span id="st-budget">—</span></div>
        <div class="meter warn"><i id="st-mem-bar"></i></div>
      </div>
      <div class="card">
        <div class="section-title" style="margin-bottom:4px">Prompt cache</div>
        <div class="kv"><b>hit rate</b><span id="st-pc-hits">—</span></div>
        <div class="kv"><b>entries</b><span id="st-pc-entries">—</span></div>
        <div class="kv"><b>size</b><span id="st-pc-bytes">—</span></div>
        <div class="meter"><i id="st-pc-bar"></i></div>
      </div>
      <div class="card">
        <div class="section-title" style="margin-bottom:4px">Response store</div>
        <div class="kv"><b>entries</b><span id="st-rs-entries">—</span></div>
        <div class="kv"><b>size</b><span id="st-rs-bytes">—</span></div>
        <div class="kv"><b>kept for</b><span id="st-rs-ttl">—</span></div>
        <div class="meter"><i id="st-rs-bar"></i></div>
      </div>
      <div class="card">
        <div class="section-title" style="margin-bottom:4px">KV quantization</div>
        <div class="kv"><b>mode</b><span id="st-kv-mode">—</span></div>
        <div id="st-kv-layers"></div>
      </div>
      <div class="card" id="st-expert-card" style="display:none">
        <div class="section-title" style="margin-bottom:4px">Expert tiers, last turn</div>
        <div class="kv"><b>main cache hit</b><span id="st-expert-main-hit">—</span></div>
        <div class="kv"><b>main SSD read</b><span id="st-expert-main-read">—</span></div>
        <div class="kv"><b>MTP cache hit</b><span id="st-expert-mtp-hit">—</span></div>
        <div class="kv"><b>MTP SSD read</b><span id="st-expert-mtp-read">—</span></div>
        <div class="card-note" id="st-expert-residency" style="margin-top:8px">waiting for the first completed turn</div>
      </div>
    </div>
    <div class="card" id="st-dl-card" style="display:none;margin-top:12px">
      <div class="section-title" style="margin-bottom:4px">Downloads</div>
      <div id="st-dl-list"></div>
    </div>
  </section>

  <section class="section">
    <h3 class="section-title">Library</h3>
    <p class="card-note" style="margin-bottom:10px">Everything in the local cache, each judged by the fit solver for this machine.</p>
    <div class="card table-wrap" style="padding:8px 4px">
      <table class="table">
        <thead><tr><th>Model</th><th class="num">Size</th><th>Status</th><th class="num">Max context</th><th class="num">Decode</th></tr></thead>
        <tbody id="st-lib-body"><tr><td colspan="5" class="muted">Waiting for the server…</td></tr></tbody>
      </table>
    </div>
  </section>

  <section class="section">
    <h3 class="section-title">Will it fit</h3>
    <p class="card-note" style="margin-bottom:10px">Weights, KV growth and the prefill transient against wired memory: the same assessment that gates every request.</p>
    <div class="grid cols-2" style="margin-bottom:12px">
      <div class="card">
        <div class="section-title" style="margin-bottom:4px">This machine</div>
        <div class="kv"><b>memory</b><span id="st-m-ram">—</span></div>
        <div class="kv"><b>bandwidth</b><span id="st-m-bw">—</span></div>
        <div class="kv"><b>verdict</b><span id="st-m-fits">—</span></div>
      </div>
      <div class="card">
        <div class="section-title" style="margin-bottom:4px">At the maximum context, <span class="num" id="st-fit-ctx">—</span> tokens</div>
        <div class="kv" data-plan-fit style="display:none"><b>artifact on disk</b><span id="st-f-artifact">—</span></div>
        <div class="kv"><b id="st-f-weights-label">weights</b><span id="st-f-weights">—</span></div>
        <div id="st-f-streamed"></div>
        <div class="kv"><b>KV cache</b><span id="st-f-kv">—</span></div>
        <div class="kv"><b id="st-f-transient-label">transient</b><span id="st-f-transient">—</span></div>
        <div class="kv"><b>total of usable</b><span id="st-f-total">—</span></div>
        <div class="meter"><i id="st-fit-bar"></i></div>
      </div>
    </div>
    <div class="card table-wrap" style="padding:8px 4px">
      <table class="table">
        <thead><tr><th>Apple silicon, this model at <span class="num" id="st-sku-ctx">32,768</span> tokens</th><th class="num">Memory</th><th>Fits</th><th class="num">Max context</th><th class="num">Decode</th></tr></thead>
        <tbody id="st-sku-body"><tr><td colspan="5" class="muted">Waiting for the server…</td></tr></tbody>
      </table>
    </div>
  </section>
</div></div>`;

export const STATUS_CSS = String.raw`
#s-status .st-model{font-size:var(--text-lg);font-weight:600;letter-spacing:-.01em;overflow:hidden;text-overflow:ellipsis;white-space:nowrap}
#s-status tr.you td{background:var(--accent-soft)}
#s-status td.fit-yes{color:var(--ok);font-weight:600}
#s-status td.fit-no{color:var(--dimmer)}
#s-status .dl-row{padding:10px 0;border-top:1px solid var(--line)}
#s-status .dl-row:first-child{border-top:0;padding-top:0}
`;
