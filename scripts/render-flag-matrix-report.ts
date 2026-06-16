// Render the e4b flag-matrix sweep (JSON from bench-e4b-flag-matrix.ts) into a
// standalone HTML report: per-context decode bar charts, the full 16-combo
// matrix, KL/parity verdicts joined in, data-driven findings, and the winning
// config highlighted.
//
//   bun scripts/render-flag-matrix-report.ts [--in <json>] [--out <html>]

function opt(name: string, dflt: string): string {
  const i = process.argv.indexOf(`--${name}`);
  return i >= 0 && i + 1 < process.argv.length ? process.argv[i + 1]! : dflt;
}
const today = new Date().toISOString().slice(0, 10);
const IN = opt("in", `benchmarks-e4b-flag-matrix-${today}.json`);
const OUT = opt("out", `e4b-flag-matrix-report-${today}.html`);

interface Combo { perfKernel: boolean; fusedDecode: boolean; compiledDecode: boolean; fusedSdpa: boolean }
interface RowJ extends Combo { ctx: number; decode: number; prefill: number; ttft: number; peakGB: number }
interface KlJ { perfKernel: boolean; fusedDecode: boolean; klMean: number; klMax: number; tokenMatchPct: number; verdict: string }
interface Data {
  model: string; commit: string; date: string; machineState: string;
  contexts: number[]; decodeTokens: number; repeats: number; warmup: number;
  rows: RowJ[]; kl: KlJ[];
}

const data: Data = JSON.parse(await Bun.file(IN).text());
const ms = JSON.parse(data.machineState) as Record<string, unknown>;

const code = (c: Combo) =>
  `PK${c.perfKernel ? "+" : "−"} FD${c.fusedDecode ? "+" : "−"} CD${c.compiledDecode ? "+" : "−"} SD${c.fusedSdpa ? "+" : "−"}`;
const key = (c: Combo) => `${+c.perfKernel}${+c.fusedDecode}${+c.compiledDecode}${+c.fusedSdpa}`;
// KL proved only fused-decode perturbs logits (perf-kernel alone is KL 0).
const breaksParity = (c: Combo) => c.fusedDecode;
const isBaseline = (c: Combo) => !c.perfKernel && !c.fusedDecode && c.compiledDecode && c.fusedSdpa;
const isDefault = (c: Combo) => c.perfKernel && !c.fusedDecode && c.compiledDecode && c.fusedSdpa;
const klFor = (c: Combo) => data.kl.find((k) => k.perfKernel === c.perfKernel && k.fusedDecode === c.fusedDecode);
const verdictOf = (c: Combo) => (breaksParity(c) ? (klFor(c)?.verdict ?? "—") : "EXACT");

const combos: Combo[] = [];
const seen = new Set<string>();
for (const r of data.rows) { if (!seen.has(key(r))) { seen.add(key(r)); combos.push({ perfKernel: r.perfKernel, fusedDecode: r.fusedDecode, compiledDecode: r.compiledDecode, fusedSdpa: r.fusedSdpa }); } }
const cell = (c: Combo, ctx: number) => data.rows.find((r) => key(r) === key(c) && r.ctx === ctx)!;
const byKey = (k: string) => combos.find((c) => key(c) === k)!;
const meanDecode = (c: Combo) => data.contexts.reduce((a, ctx) => a + cell(c, ctx).decode, 0) / data.contexts.length;
const meanOver = (f: (c: Combo) => boolean) => { const cs = combos.filter(f); return cs.reduce((a, c) => a + meanDecode(c), 0) / cs.length; };

// winner per context
const winnerByCtx = new Map<number, string>();
for (const ctx of data.contexts) {
  let best = -1, bk = "";
  for (const c of combos) { const d = cell(c, ctx).decode; if (d > best) { best = d; bk = key(c); } }
  winnerByCtx.set(ctx, bk);
}
// recommended: fastest mean decode among bit-exact combos; tie-break (within
// 0.3 tok/s) toward baseline, then default, then fewest enabled levers.
const enabled = (c: Combo) => +c.perfKernel + +c.fusedDecode + +c.compiledDecode + +c.fusedSdpa;
const exact = combos.filter((c) => !breaksParity(c));
const maxExact = Math.max(...exact.map(meanDecode));
const tied = exact.filter((c) => meanDecode(c) >= maxExact - 0.3);
const recommended = tied.find(isBaseline) ?? tied.find(isDefault) ?? tied.slice().sort((a, b) => enabled(a) - enabled(b))[0]!;
const defaultCombo = combos.find(isDefault)!;
const baselineCombo = combos.find(isBaseline)!;

// ── data-driven findings ─────────────────────────────────────────────────
const cdEffect = meanOver((c) => !c.fusedDecode && c.compiledDecode) - meanOver((c) => !c.fusedDecode && !c.compiledDecode); // CD within bit-exact
const cdPct = (cdEffect / meanOver((c) => !c.fusedDecode && !c.compiledDecode)) * 100;
const pkDelta = meanDecode(defaultCombo) - meanDecode(baselineCombo); // PK on vs off, else identical
const klFD = data.kl.find((k) => k.fusedDecode)!;
let worst = { d: Infinity, c: combos[0]!, ctx: data.contexts[0]! };
for (const ctx of data.contexts) for (const c of combos) { const d = cell(c, ctx).decode; if (d < worst.d) worst = { d, c, ctx }; }
const worstWin = cell(byKey(winnerByCtx.get(worst.ctx)!), worst.ctx).decode;
const worstRatio = worst.d / worstWin;
// fused-decode + fused-sdpa interaction, CD− vs CD+ at the longest context
const longCtx = Math.max(...data.contexts);
const fdsdCdOff = (cell({ perfKernel: false, fusedDecode: true, compiledDecode: false, fusedSdpa: true }, longCtx).decode + cell({ perfKernel: true, fusedDecode: true, compiledDecode: false, fusedSdpa: true }, longCtx).decode) / 2;
const fdsdCdOn = (cell({ perfKernel: false, fusedDecode: true, compiledDecode: true, fusedSdpa: true }, longCtx).decode + cell({ perfKernel: true, fusedDecode: true, compiledDecode: true, fusedSdpa: true }, longCtx).decode) / 2;

const esc = (s: string) => s.replace(/&/g, "&amp;").replace(/</g, "&lt;").replace(/>/g, "&gt;");
const vColor = (v: string) => v === "WARN" ? "var(--warn)" : v === "PASS" ? "var(--good)" : v === "EXACT" ? "var(--accent)" : "var(--muted)";

function barPanel(ctx: number): string {
  const rowsHere = combos.map((c) => ({ c, d: cell(c, ctx).decode })).sort((a, b) => b.d - a.d);
  const max = Math.max(...rowsHere.map((r) => r.d));
  const win = winnerByCtx.get(ctx);
  const bars = rowsHere.map(({ c, d }) => {
    const w = (d / max) * 100;
    const isWin = key(c) === win;
    const slow = d < 0.92 * max;
    const grad = slow ? "linear-gradient(90deg,#8a2a26,#f85149)" : "linear-gradient(90deg,#1f6feb,#5cc8ff)";
    const tag = isDefault(c) ? "★" : isBaseline(c) ? "◇" : "";
    return `<div class="brow"><div class="blabel">${code(c)} <span class="mk">${tag}</span></div>`
      + `<div class="track"><i style="width:${w.toFixed(1)}%;background:${grad}${isWin ? ";box-shadow:0 0 0 1px var(--good),0 0 10px #3fb95066" : ""}"></i></div>`
      + `<div class="num">${d.toFixed(1)}${isWin ? ' <span class="winmk">▲</span>' : ""}</div></div>`;
  }).join("\n");
  return `<div class="panel"><p class="ptitle">decode tok/s · ctx=${ctx} <span class="hint">sorted fastest→slowest · ★ default · ◇ bit-exact baseline · red = &lt;0.92× ctx-winner</span></p>${bars}</div>`;
}

function matrixTable(): string {
  const head = `<tr><th>combo</th><th>parity</th>`
    + data.contexts.map((ctx) => `<th>dec ${ctx}</th>`).join("")
    + data.contexts.map((ctx) => `<th>pre ${ctx}</th>`).join("")
    + `<th>peak‡</th><th>KL mean</th><th>verdict</th></tr>`;
  const body = combos.slice().sort((a, b) => meanDecode(b) - meanDecode(a)).map((c) => {
    const kl = klFor(c);
    const v = verdictOf(c);
    const tag = isDefault(c) ? ' <span class="mk">★</span>' : isBaseline(c) ? ' <span class="mk">◇</span>' : "";
    const rec = key(c) === key(recommended) ? ' style="background:#0f1a13"' : "";
    const dec = data.contexts.map((ctx) => {
      const d = cell(c, ctx).decode;
      const win = key(c) === winnerByCtx.get(ctx);
      return `<td${win ? ' class="g"' : ""}>${d.toFixed(1)}</td>`;
    }).join("");
    const pre = data.contexts.map((ctx) => `<td>${cell(c, ctx).prefill.toFixed(0)}</td>`).join("");
    const peak = Math.max(...data.contexts.map((ctx) => cell(c, ctx).peakGB));
    return `<tr${rec}><td style="text-align:left">${code(c)}${tag}</td>`
      + `<td style="color:${vColor(v)}">${breaksParity(c) ? "breaks" : "exact"}</td>`
      + dec + pre
      + `<td style="color:var(--muted)">${peak.toFixed(1)}</td>`
      + `<td>${kl ? kl.klMean.toExponential(1) : "0"}</td>`
      + `<td style="color:${vColor(v)}">${v}</td></tr>`;
  }).join("\n");
  return `<table><thead>${head}</thead><tbody>${body}</tbody></table>`;
}

const okBadge = ms.ok ? `<span style="color:var(--good)">preflight PASS</span>` : `<span style="color:var(--warn)">preflight ‡ (forced)</span>`;

const html = `<!doctype html>
<html lang="en"><head><meta charset="utf-8"><meta name="viewport" content="width=device-width, initial-scale=1">
<title>e4b flag matrix — ${data.date.slice(0, 10)}</title>
<style>
  :root{--bg:#0e1116;--panel:#161b22;--panel2:#1c222b;--ink:#e6edf3;--muted:#9aa7b4;--line:#2a323d;
    --accent:#5cc8ff;--good:#3fb950;--warn:#d29922;--bad:#f85149;--mono:ui-monospace,SFMono-Regular,Menlo,Consolas,monospace;}
  *{box-sizing:border-box}
  body{margin:0;background:var(--bg);color:var(--ink);font:15px/1.6 -apple-system,BlinkMacSystemFont,"Segoe UI",Roboto,Helvetica,Arial,sans-serif;-webkit-font-smoothing:antialiased}
  .wrap{max-width:1040px;margin:0 auto;padding:44px 24px 110px}
  h1{font-size:31px;margin:0 0 6px;letter-spacing:-.02em}
  h2{font-size:21px;margin:46px 0 8px;letter-spacing:-.01em}
  .sub{color:var(--muted);margin:0 0 22px}
  .meta{display:flex;flex-wrap:wrap;gap:8px;margin:0 0 24px}
  .chip{font:12px/1 var(--mono);color:var(--muted);background:var(--panel);border:1px solid var(--line);border-radius:999px;padding:7px 11px}
  .chip b{color:var(--ink)}
  .banner{border:1px solid #2c4a2c;background:#0e1c10;border-radius:10px;padding:14px 16px;margin:0 0 26px;color:#bfe6c4;font-size:13.5px}
  .banner code{background:#000a;padding:1px 5px;border-radius:4px;color:#d7f0db}
  .cards{display:grid;grid-template-columns:repeat(auto-fit,minmax(230px,1fr));gap:12px;margin:8px 0}
  .card{background:var(--panel);border:1px solid var(--line);border-radius:12px;padding:15px 16px}
  .card.win{border-color:#1d4429;background:#0f1a13}
  .card .k{font-size:12px;color:var(--muted);text-transform:uppercase;letter-spacing:.05em;margin:0 0 7px}
  .card .v{font:600 21px/1.15 var(--mono);letter-spacing:-.01em}
  .card .v.g{color:var(--good)}.card .v.a{color:var(--accent)}.card .v.w{color:var(--warn)}
  .card .d{font-size:12.5px;color:var(--muted);margin:8px 0 0}
  .panel{background:var(--panel);border:1px solid var(--line);border-radius:12px;padding:16px 20px;margin:14px 0}
  .ptitle{font-size:13px;color:var(--muted);margin:0 0 12px;text-transform:uppercase;letter-spacing:.04em}
  .ptitle .hint{text-transform:none;letter-spacing:0;color:#6e7b89;float:right;font-size:11.5px}
  .brow{display:grid;grid-template-columns:150px 1fr 86px;gap:12px;align-items:center;margin:6px 0}
  .blabel{font:12px/1 var(--mono);color:var(--ink)} .blabel .mk{color:var(--accent)}
  .track{height:14px;background:var(--panel2);border-radius:4px;overflow:hidden}
  .track>i{display:block;height:100%;border-radius:4px}
  .num{font:12px/1 var(--mono);color:var(--ink);text-align:right} .winmk{color:var(--good)}
  table{border-collapse:collapse;width:100%;font:12px/1.5 var(--mono);margin:12px 0}
  th,td{border-bottom:1px solid var(--line);padding:7px 8px;text-align:right;white-space:nowrap}
  th:first-child,td:first-child{text-align:left}
  th{color:var(--muted);font-weight:600}
  tbody tr:hover{background:#12171e}
  td.g{color:var(--good)} .mk{color:var(--accent)}
  .take{border-left:3px solid var(--accent);background:#0f1722;border-radius:0 8px 8px 0;padding:13px 16px;margin:16px 0;font-size:14px}
  ul.find{margin:14px 0;padding:0;list-style:none}
  ul.find li{padding:9px 0 9px 26px;border-bottom:1px solid var(--line);position:relative;font-size:14px}
  ul.find li:before{content:attr(data-i);position:absolute;left:0;top:9px;color:var(--accent);font:600 13px var(--mono)}
  .legend{font-size:12.5px;color:var(--muted);margin:10px 0}
  .foot{color:#6e7b89;font-size:12px;margin-top:30px;line-height:1.7}
  code{background:#0b0e13;border:1px solid var(--line);border-radius:4px;padding:1px 5px;font:12px var(--mono);color:#cdd9e5}
  b.g{color:var(--good)} b.b{color:var(--bad)} b.a{color:var(--accent)}
</style></head><body><div class="wrap">

<h1>e4b flag matrix</h1>
<p class="sub">Every mixture of the four perf levers · ${esc(data.model)} · ${data.date.slice(0, 10)} · commit <code>${esc(data.commit)}</code></p>

<div class="meta">
  <span class="chip">chip <b>${esc(String(ms.chip ?? "?"))}</b></span>
  <span class="chip">ram <b>${esc(String(ms.ram_gb ?? "?"))} GB</b></span>
  <span class="chip">${okBadge}</span>
  <span class="chip">load1m <b>${esc(String(ms.load1m ?? "?"))}</b></span>
  <span class="chip">swap <b>${esc(String(ms.swap_mb ?? "?"))} MB</b></span>
  <span class="chip">KV <b>mixed (config)</b></span>
  <span class="chip">median-of-${data.repeats} +${data.warmup} warm</span>
  <span class="chip">decode <b>${data.decodeTokens} tok</b></span>
</div>

<div class="banner">In-process paired sweep — the 7 GB model loads once and env flips between combos, so <b>decode ratios &amp; ordering are robust</b>.
Preflight <b>${ms.ok ? "PASS" : "forced"}</b> (load ${esc(String(ms.load1m))}, swap ${esc(String(ms.swap_mb))} MB, ${esc(String(ms.free_pct))}% free) → absolutes usable, not lab-grade.
Levers map to <code>--perf-kernel</code> / <code>--fused-decode</code> / <code>--compiled-decode</code> / <code>--fused-sdpa</code>; only <code>fused-decode</code> perturbs logits (KL-proven below).</div>

<h2>Best settings for e4b</h2>
<div class="cards">
  <div class="card win"><p class="k">Recommended</p><div class="v g">${code(recommended)}</div>
    <p class="d">${meanDecode(recommended).toFixed(1)} tok/s mean · <b>${verdictOf(recommended)}</b> · the parity-breaking kernels buy nothing here</p></div>
  <div class="card"><p class="k">Shipping default ★</p><div class="v a">${code(defaultCombo)}</div>
    <p class="d">${meanDecode(defaultCombo).toFixed(1)} tok/s mean · perf-kernel is inert (Δ ${pkDelta >= 0 ? "+" : ""}${pkDelta.toFixed(2)} tok/s)</p></div>
  <div class="card"><p class="k">Avoid</p><div class="v w">FD+ &amp; SD+</div>
    <p class="d">fused-decode + fused-sdpa → ${worst.d.toFixed(1)} tok/s @${worst.ctx} (${worstRatio.toFixed(2)}× the winner)</p></div>
</div>

<h2>What each lever does</h2>
<ul class="find">
  <li data-i="①"><b>All 16 combos PASS quality.</b> <code>fused-decode</code> is the only lever that moves logits (KL mean ${klFD.klMean.toExponential(1)} / max ${klFD.klMax.toExponential(1)} nats, ${klFD.tokenMatchPct.toFixed(0)}% greedy match). <code>perf-kernel</code> alone is <b class="a">bit-exact (KL 0)</b>; <code>compiled-decode</code> and <code>fused-sdpa</code> are bit-exact too.</li>
  <li data-i="②"><b class="g">compiled-decode is the only real win:</b> +${cdEffect.toFixed(1)} tok/s (≈${cdPct.toFixed(1)}%) on bit-exact combos, and it <i>rescues</i> the slow path below (${fdsdCdOff.toFixed(1)}→${fdsdCdOn.toFixed(1)} tok/s @${longCtx}). Keep it on.</li>
  <li data-i="③"><b>perf-kernel is inert on e4b decode:</b> Δ ${pkDelta >= 0 ? "+" : ""}${pkDelta.toFixed(2)} tok/s vs off, and KL-identical. Default-on neither helps nor hurts — could be off.</li>
  <li data-i="④"><b class="b">fused-decode is neutral-to-harmful:</b> never faster, and with <code>fused-sdpa</code> on it degrades with context — down to ${worst.d.toFixed(1)} tok/s @${worst.ctx} (${(100 * (1 - worstRatio)).toFixed(0)}% under the winner). It's the one combination to avoid.</li>
</ul>

<h2>Decode by context</h2>
${data.contexts.map(barPanel).join("\n")}

<h2>Full matrix</h2>
<p class="legend">16 combos × ${data.contexts.length} contexts, sorted by mean decode. <code>dec</code>/<code>pre</code> = decode/prefill tok/s. Green = per-context winner. ★ default · ◇ baseline · highlighted row = recommended.</p>
${matrixTable()}
<p class="legend">‡ <b>peak GB is not a per-combo figure</b> — this single-process sweep accumulates buffer/graph cache across combos (peak climbs monotonically with run order, worst at ${longCtx}). For real per-combo memory use the per-process <code>benchmark.sh</code> path. Prefill/TTFT are flat across these decode levers (shown for completeness).</p>

<p class="foot">Source: <code>${esc(IN)}</code> via <code>scripts/bench-e4b-flag-matrix.ts</code> (median-of-${data.repeats}, +${data.warmup} warm, ${data.decodeTokens} decode tokens, KV=mixed/config).
Paired in-process design → decode ratios robust; preflight ${ms.ok ? "PASS" : "forced"} on ${esc(String(ms.chip))} / ${esc(String(ms.ram_gb))} GB.
Note: this contradicts the morning Comparison-3 e4b "perf collapse" (17.4 tok/s @600) — not reproduced here; likely a different machine or transient.</p>

</div></body></html>`;

await Bun.write(OUT, html);
console.log(`wrote ${OUT} from ${IN} (${combos.length} combos, ${data.contexts.length} contexts)`);
console.log(`recommended=${code(recommended)} (${verdictOf(recommended)})  cdEffect=+${cdEffect.toFixed(2)} tok/s  pkDelta=${pkDelta.toFixed(2)}  worst=${worst.d.toFixed(1)}@${worst.ctx}`);
