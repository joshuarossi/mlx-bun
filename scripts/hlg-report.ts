// Builds a standalone HTML report of the HLG-sampling investigation, embedding the
// generated SVG figures inline. Regenerable: re-run after adding figures/findings.
//   bun scripts/hlg-report.ts   →   docs/investigations/hlg-report.html

import { readFileSync, writeFileSync, existsSync } from "node:fs";

const FIGDIR = `${process.cwd()}/docs/investigations/hlg-figs`;
function fig(name: string): string {
  const p = `${FIGDIR}/${name}`;
  return existsSync(p) ? readFileSync(p, "utf8").trim() : `<div class="pending">figure <code>${name}</code> not generated yet</div>`;
}
const CSS = `
:root{
  --text-primary:#1f2937; --text-secondary:#475569; --text-tertiary:#94a3b8;
  --bg:#fbfcfe; --bg-card:#ffffff; --bg-tertiary:#eef2f7; --border:#e2e8f0;
  --accent:#2563eb; --positive:#16a34a; --warn:#d97706; --cyan:#0891b2; --danger:#dc2626;
}
*{box-sizing:border-box}
body{margin:0;background:var(--bg);color:var(--text-primary);
  font-family:-apple-system,BlinkMacSystemFont,"Segoe UI",ui-sans-serif,system-ui,sans-serif;
  line-height:1.62;font-size:16px;-webkit-font-smoothing:antialiased}
.wrap{max-width:920px;margin:0 auto;padding:56px 28px 120px}
header.hero{border-bottom:2px solid var(--border);padding-bottom:28px;margin-bottom:8px}
.kicker{font-size:12.5px;letter-spacing:.14em;text-transform:uppercase;color:var(--accent);font-weight:700}
h1{font-size:34px;line-height:1.18;margin:.32em 0 .18em;letter-spacing:-.02em}
.sub{color:var(--text-secondary);font-size:17px;max-width:680px}
.meta{margin-top:14px;font-size:13px;color:var(--text-tertiary)}
.thesis{background:linear-gradient(180deg,#f1f6ff,#fbfcfe);border:1px solid #dbe7ff;border-left:4px solid var(--accent);
  border-radius:12px;padding:18px 22px;margin:26px 0 8px;font-size:16.5px}
.thesis b{color:var(--accent)}
h2{font-size:24px;margin:54px 0 4px;letter-spacing:-.01em;padding-top:8px}
h2 .n{color:var(--text-tertiary);font-weight:600;font-size:18px;margin-right:10px}
h3{font-size:17px;margin:30px 0 6px;color:var(--text-primary)}
p{margin:12px 0}
.lead{font-size:17px;color:var(--text-secondary)}
code{background:var(--bg-tertiary);border-radius:5px;padding:.08em .38em;font-size:.87em;
  font-family:ui-monospace,SFMono-Regular,Menlo,monospace;color:#0f172a}
strong{font-weight:650}
figure{margin:26px 0;background:var(--bg-card);border:1px solid var(--border);border-radius:14px;
  padding:18px 18px 10px;box-shadow:0 1px 2px rgba(15,23,42,.04),0 8px 24px -16px rgba(15,23,42,.18)}
figure svg{width:100%;height:auto;display:block}
figcaption{font-size:13px;color:var(--text-tertiary);margin-top:10px;padding-top:10px;border-top:1px solid var(--border)}
figcaption b{color:var(--text-secondary)}
table{border-collapse:collapse;width:100%;margin:20px 0;font-size:14.5px}
th,td{text-align:left;padding:9px 12px;border-bottom:1px solid var(--border);vertical-align:top}
thead th{background:var(--bg-tertiary);font-size:12.5px;letter-spacing:.02em;color:var(--text-secondary);border-bottom:2px solid var(--border)}
tbody tr:hover{background:#f8fafc}
.tag{display:inline-block;font-size:11.5px;font-weight:700;padding:2px 9px;border-radius:999px;line-height:1.5}
.tag.cluster{background:#fef3c7;color:#92400e}
.tag.free{background:#dcfce7;color:#166534}
.tag.curve{background:#dbeafe;color:#1e40af}
.callout{border:1px solid var(--border);border-left:4px solid var(--text-tertiary);background:var(--bg-card);
  border-radius:10px;padding:14px 18px;margin:20px 0;font-size:15px}
.callout.terrain{border-left-color:var(--positive);background:#f6fdf9}
.callout.rock{border-left-color:var(--danger);background:#fef6f6}
.callout h4{margin:0 0 6px;font-size:13px;text-transform:uppercase;letter-spacing:.08em;color:var(--text-secondary)}
.pending{background:var(--bg-tertiary);border:1px dashed var(--border);border-radius:10px;padding:30px;text-align:center;color:var(--text-tertiary)}
ul.clean{margin:12px 0;padding-left:22px}
ul.clean li{margin:7px 0}
.foot{margin-top:70px;padding-top:22px;border-top:1px solid var(--border);font-size:13px;color:var(--text-tertiary)}
.runidx{columns:2;column-gap:30px;font-size:13px;color:var(--text-secondary)}
.runidx div{break-inside:avoid;margin:3px 0}
.runidx code{font-size:12px}
@media(max-width:680px){.runidx{columns:1}h1{font-size:27px}.wrap{padding:34px 18px 80px}}
`;

const NOW = "June 2026"; // stamped manually (Date.now unavailable in workflow scripts; fine here but kept stable)

const html = `<!doctype html><html lang="en"><head><meta charset="utf-8">
<meta name="viewport" content="width=device-width,initial-scale=1">
<title>HLG Sampling — Investigation Report</title><style>${CSS}</style></head>
<body><div class="wrap">

<header class="hero">
  <div class="kicker">mlx-bun · sampling investigation</div>
  <h1>Transplanting Hybrid Log-Gamma onto LLM logit sampling</h1>
  <p class="sub">Mapping a piecewise HDR transfer function as a replacement sampler — what each control does, where the coherent region is walled, and whether the geometry is a property of the curve or of the model.</p>
  <div class="meta">Reference model gemma-4-e4b · cross-checked on gemma-4-12B and MiniCPM5-1B · ${NOW}</div>
</header>

<div class="thesis">
  Temperature is <b>one global slope</b> on the logits. It couples two things you might want to do separately:
  tamp down the over-confident top token, and lift the long tail. HLG (ITU-R BT.2100) is a <b>piecewise</b> curve —
  a toe in the shadows, a power region in the mids, a log shoulder in the highlights, plus a system gamma. The bet:
  transplant that shape onto logit sampling to <b>decouple</b> those moves — and get several controls where temperature gave one.
</div>

<h2><span class="n">1</span>The idea</h2>
<p class="lead">A sampler's logits look, abstractly, like a tone curve: a bright "highlight" (the dominant token), a band of
"midtone" plausible alternatives, and a dark "shadow" tail of unlikely tokens. Temperature scales that whole curve by a
single exponent — raise it and you simultaneously dim the highlight <em>and</em> raise the shadows; you cannot do one without the other.</p>
<p>HLG splits the curve into regions with independent behavior: a gamma/√ <strong>toe</strong>, a power <strong>mid</strong>, a logarithmic
<strong>shoulder</strong>, and a separate system <strong>OOTF gamma</strong> (γ = 1.2 + 0.42·log₁₀(L_W/1000)). Transplanted onto sampling, those
become: roll off the over-confident top (<code>shoulder</code> / <code>A</code>), sharpen the interesting middle (<code>s_m</code>), gate the
junk tail (<code>window</code> / <code>target_gap</code>), and bend the global curvature (<code>L_W</code>). It is a <strong>replacement</strong> sampler —
flag-gated (<code>--hlg-sampling</code>, default off), post-inference, model-agnostic — that stands in for temperature + top-p + top-k entirely.</p>

<h3>Two cross-domain adaptations</h3>
<p>The literal HDR curve does not work out of the box, because LM logits are not images:</p>
<ul class="clean">
  <li><strong>Windowed anchor.</strong> A logit distribution is a spike-plus-tail, not an image histogram. Min-max normalization
  collapses every real candidate into the shoulder. Fix: anchor the input window <code>W</code> nats below the top token, so the
  candidates land across the curve instead of piling up at the top.</li>
  <li><strong>Inverted toe.</strong> HLG's toe <em>lifts</em> shadows (it describes how a display renders near-black). A sampler wants the
  opposite — to <em>crush</em> the tail. So the toe is inverted from lift to suppress.</li>
  <li><strong>Decoupled <code>out_scale</code>.</strong> The output scale auto-derives to pin the top→reference-token gap to <code>target_gap</code>,
  so changing the window doesn't silently change the sharpness.</li>
</ul>

<h2><span class="n">2</span>How we measured</h2>
<p>Every configuration is compared against the model's <strong>own recommended recipe</strong> (its <code>generation_config.json</code>,
run unchanged) — the only thing that varies is the sampling method. Two metrics, two stages:</p>
<ul class="clean">
  <li><strong>Coherence</strong> — a factual "canary" prompt (the sharpest spike-to-tail; it breaks last) scored by <em>junk ratio</em>,
  the fraction of non-Latin-script letters, which is the word-salad signature. Cheap, so it screens the whole grid first.</li>
  <li><strong>Diversity</strong> — measured <em>only on coherent survivors</em> (so garbage can't win): <em>1−self-BLEU</em> on the divergent
  region (shared prefix stripped), backed by distinct-2 and an LM-embedding cosine. The factual prompt stays the coherence canary.</li>
</ul>
<div class="callout">
  <h4>Stance</h4>
  This is a <strong>map, not a verdict.</strong> Each run is a coordinate held loosely — we don't give up at the first rock or
  declare victory at the first tree. Small-sample diversity is noisy (self-BLEU swings ~±0.08 at K=6), so effect sizes near that
  scale are reported as terrain, not findings, and the decisive sweeps are re-run at K=20.
</div>

<h2><span class="n">3</span>The five knobs</h2>
<p class="lead">HLG exposes five controls where temperature gave one. They are <em>not</em> five copies of the same lever — they
play different roles, which is the whole point of the transplant.</p>
<table>
  <thead><tr><th>Knob</th><th>What it does</th><th>Role on the coherence wall</th><th>Diversity</th></tr></thead>
  <tbody>
    <tr><td><code>target_gap</code></td><td>overall sharpness anchor (top→ref gap)</td><td><span class="tag cluster">gate cluster</span> graded cliff, vocab-shifted</td><td>sharpness lever</td></tr>
    <tr><td><code>W</code> (window)</td><td>candidate gate, nats below the top</td><td><span class="tag cluster">gate cluster</span> sharp edge at high A</td><td>candidate gate</td></tr>
    <tr><td><code>s_m</code></td><td>mid-region slope (sharpen the middle)</td><td><span class="tag cluster">gate cluster</span> the coupling hub</td><td>coupled lever</td></tr>
    <tr><td><code>A</code> (shoulder)</td><td>highlight roll-off / top-token confidence</td><td><span class="tag free">orthogonal</span> doesn't move the floor</td><td>the <b>free</b> lever</td></tr>
    <tr><td><code>L_W</code></td><td>OOTF curvature (γ of the whole curve)</td><td><span class="tag curve">outside cluster</span> robust; walls at γ extremes</td><td>non-monotone, model-specific</td></tr>
  </tbody>
</table>

<h2><span class="n">4</span>The coherent basin</h2>
<p>Sweeping the knobs two at a time produces a coherent <strong>basin</strong> walled by cliffs, with a diversity gradient inside it.
The left panel is the <code>A × s_m</code> plane; the right is <code>target_gap × W</code>. Darker = more diverse; ✗ = the canary broke;
green-outlined cells beat the default's diversity.</p>
${figFigure("terrain.svg", "<b>Diversity terrain (e4b).</b> The basin is walled by coupled diagonal cliffs — knobs trade off against each other at the edge. Diversity is a noisy plateau that rises toward the loose corner of the basin, hovering around the default level.")}

<h2><span class="n">5</span>The wall's geometry</h2>
<p>Resolving every pairwise coherence boundary (two within-pair, four cross-pair) shows the wall is <strong>not</strong> a stack of
independent thresholds. It is a single coupled surface — with one knob standing outside it.</p>
<ul class="clean">
  <li><strong><code>A</code> is orthogonal to the wall.</strong> Crank it across four orders of magnitude and the gate cliffs barely move.
  Mechanism: the coherence floor is a <em>tail</em> phenomenon, and <code>A</code> only reshapes the <em>top</em> — it adds no tail mass, so it's free on coherence.</li>
  <li><strong><code>s_m</code> is the coupling hub.</strong> It trades off against both gates: a loose mid demands a tighter gate. At low <code>s_m</code>
  the cliff can vanish entirely; at high <code>s_m</code> it needs more gating to stay coherent.</li>
  <li><strong>The wall = a coupled <code>tg</code>/<code>W</code>/<code>s_m</code> cluster.</strong> Those three share one "tail-mass budget"; <code>A</code> sits outside it;
  <code>L_W</code> (below) sits outside it too. So the two diversity levers split by their relation to the wall — <code>A</code> is <em>free</em>, <code>s_m</code> is <em>coupled</em>.</li>
</ul>

<h2><span class="n">6</span>Does the geometry generalize?</h2>
<p>The whole map above is one model. Re-running the cross-pair coherence boundary on <strong>12B</strong> (dense Gemma, same ~262k vocab)
and <strong>CPM5</strong> (MiniCPM5-1B, Llama family, ~73k vocab) sorts the structure into what belongs to the <em>curve</em> versus the <em>vocab</em>.</p>
${figFigure("cross.svg", "<b>Cross-pair coherence across three models.</b> The sharpness cluster (top band) replicates everywhere; the window axis (bottom band) tracks vocab size — the two Gemmas agree, CPM5 diverges.")}
<table>
  <thead><tr><th>Cross-pair</th><th>e4b (Gemma 262k)</th><th>12B (Gemma 262k)</th><th>CPM5 (Llama ~73k)</th><th>Generalizes?</th></tr></thead>
  <tbody>
    <tr><td><code>s_m × target_gap</code></td><td>diagonal — low s_m tolerates low tg</td><td>same diagonal</td><td>same diagonal (shifted threshold)</td><td><b style="color:var(--positive)">yes</b></td></tr>
    <tr><td><code>A × target_gap</code></td><td>gate cliff A-independent</td><td>same</td><td>same</td><td><b style="color:var(--positive)">yes</b></td></tr>
    <tr><td><code>s_m × W</code></td><td>s_m≥2 breaks at W=5</td><td>same</td><td>fully clean (decoupled)</td><td><b style="color:var(--danger)">vocab</b></td></tr>
    <tr><td><code>A × W</code></td><td>W cliff A-independent</td><td>similar</td><td>high-A / wide-W break</td><td><b style="color:var(--danger)">vocab</b></td></tr>
  </tbody>
</table>
<div class="callout terrain">
  <h4>Result (terrain)</h4>
  The <strong>sharpness coupling — <code>s_m ↔ target_gap</code> coupled, <code>A</code> orthogonal — replicates across all three models and both
  architectures.</strong> That's a property of the HLG curve, not the model. The <strong>window axis is vocab-sensitive</strong>: the two
  same-vocab Gemmas behave identically, only CPM5 (less tail to inflate) diverges. 12B was the control, and it tracked e4b, not CPM5.
</div>

<h2><span class="n">7</span>L_W — the curvature knob</h2>
<p>The <code>out_scale</code> derivation pins the top→reference anchor to <code>target_gap</code>, so <code>L_W</code> doesn't move the anchor — it bends
the <strong>curvature</strong> of the mid/tail. Swept across six orders of magnitude (γ from −0.06 to 2.46):</p>
${figFigure("lw-curve.svg", "<b>L_W diversity curve, three models.</b> Coherence is robust across ~5 decades; the knob walls only at the extremes (γ<0 inverts the ranking; γ≳2.4 over-sharpens — Gemma-only). The coherence structure here is solid; the diversity <em>traces are the coarse K=6 sweep</em> and are revised downward at K=20 — see §9.")}
<ul class="clean">
  <li><strong>Not a gate.</strong> Coherent across <code>L_W ∈ [3, 10⁵]</code> — five decades — versus the gates' tight unit-scale breaks. It
  walls only at the <em>extremes</em>: low (γ&lt;0 inverts the token ranking → junk; universal) and high (γ≳2.4 over-sharpens → junk; Gemma-only, CPM5's smaller vocab passes).</li>
  <li><strong>Diversity: a retracted win.</strong> At K=6, e4b's curve looked like an interior peak that <em>beat</em> its default. At K=20
  (§9) that evaporates — every <code>L_W</code> setting sits well below the default. The honest read: <strong>L_W's diversity is uniformly below the
  recommended recipe</strong>; the apparent e4b win was small-sample noise. <code>L_W</code>'s real character is its coherence robustness, not a diversity gain.</li>
</ul>

<h2><span class="n">8</span>Resolving the cliffs</h2>
<p>The coarse maps stepped <em>over</em> the steepest features. Stepping <code>target_gap</code> and <code>W</code> at unit resolution (with the
junk% gradient, not just pass/fail) reveals two qualitatively different cliff <em>shapes</em>.</p>
${figFigure("cliff.svg", "<b>Fine cliff resolution.</b> target_gap is a graded ramp whose position slides with vocab; W at high A is a sharp edge that closes at 7→8 in every model. Two different shapes the coarse 8/12 and 5/10 jumps had hidden.")}
<ul class="clean">
  <li><strong><code>target_gap</code> is a graded ramp</strong>, not a step — a 2–3-step slope. Its <em>position</em> shifts by vocab (CPM5 coherent earliest, e4b latest).</li>
  <li><strong><code>W</code> at high <code>A</code> is a sharp edge</strong> — a high plateau then an abrupt close at W=8 in all three models. The <em>edge position is model-invariant</em>; only the plateau height varies by vocab.</li>
</ul>
<div class="callout rock">
  <h4>A disconfirmed prediction (logged, not buried)</h4>
  We expected 12B's <code>target_gap</code> cliff to be the <em>steepest</em>. It is not — e4b's is at least as steep. 12B's genuine
  "sensitivity" is in <em>diversity</em> (the L_W suppression), a different axis. The prior was a rock; it's recorded as a data point and we moved on.
</div>

<h2><span class="n">9</span>K=20 deep-dive — settling the noise</h2>
<p>Four experiments re-run at K=20, where the noisy diversity metric finally settles. Two mixed variables to resolve how
the cliffs bend; two re-measured the diversity claims that sat within K=6 noise.</p>

<h3>The cliffs are tilted surfaces, not fixed walls</h3>
${figFigure("k20-grids.svg", "<b>Fine 2-D coherence at K=20.</b> Left: the target_gap cliff slides monotonically with s_m — at s_m=0.2 there is no cliff at all; raise s_m and the tg needed for coherence climbs out of frame. Right: the W edge slides with A — it closes at W≈4–5 for low A but not until W≈8 at A=100, so the earlier 'invariant 7→8 edge' was specific to A=100.")}
<p>The "coupling hub" isn't a metaphor: <code>s_m</code> literally translates the <code>target_gap</code> cliff edge, and <code>A</code>
translates the <code>W</code> edge. The base-config slices resolved in §8 were single rows through these tilted surfaces.</p>

<h3>One diversity claim dies, one confirms</h3>
${figFigure("k20-peaks.svg", "<b>Settled diversity at K=20 (e4b default = 0.633).</b> Left: every L_W setting sits ~0.19 below default — the K=6 '0.76 beats default' was small-sample noise. Right: the A gradient is a clean monotone, and only the loosest A (0.01, ringed) clears the default line.")}
<div class="callout rock">
  <h4>K=6 → K=20: a claim retracted</h4>
  At K=6, e4b's <code>L_W</code> curve appeared to peak <em>above</em> its default (0.76 vs 0.70). At K=20 it does not — the default
  is 0.633 and every <code>L_W</code> point sits at 0.42–0.45. The peak was noise. This brings e4b in line with what K=6 already
  showed for 12B and CPM5 (both below their defaults): across the board, <strong>HLG's curvature knob does not beat the recommended recipe on diversity.</strong>
</div>
<div class="callout terrain">
  <h4>What K=20 confirms</h4>
  <code>A</code> is the genuine <strong>free diversity lever</strong>: diversity falls cleanly and monotonically as <code>A</code> tightens
  (0.66 → 0.31 across A 0.01→0.7), and the <em>one</em> place HLG clears a model's default at all is the loosest <code>A</code> (+0.03 at A=0.01).
  Modest, but real and reproducible. <span style="color:var(--text-tertiary)">(The A sweep was cut at A=0.7 when the batch was stopped; the monotone trend and the diversity ceiling are captured.)</span>
</div>

<h3>The texture of the edges</h3>
<p>Zooming sub-unit into the transitions (K=20, tracking break-<em>rate</em> and max, not just the mean) shows the "cliffs" are not
all the same kind of thing.</p>
${figFigure("edges.svg", "<b>Edge texture (K=20).</b> Break-rate across the four transition zooms. The gate cliffs are soft probabilistic ramps (a declining fraction of seeds break, while the ones that do break hard); the L_W low wall is a hard deterministic threshold at γ=0 (the ranking sign-flip); the high wall is barely a wall (3/20 even at γ=2.46).")}
<ul class="clean">
  <li><strong>The gate cliffs (<code>tg</code>, <code>W</code>) are <em>statistical</em> edges.</strong> Per seed it's bimodal — clean or hard-break (max stays
  43–88% mid-ramp) — so the smooth "ramp" is really the declining <em>fraction</em> of seeds that wander into junk, not a softening failure.</li>
  <li><strong>The <code>L_W</code> low wall is a <em>hard</em> threshold at γ=0</strong> — a sign flip of the ranking, deterministic. Every sampled γ≥0 is clean.</li>
  <li><strong>The <code>L_W</code> high wall is barely there</strong> — the coarse "REJECT" was a small-sample artifact.</li>
</ul>
<div class="callout">
  <h4>Play with it</h4>
  Two interactive companions: <strong><a href="hlg-explorer.html">hlg-explorer.html</a></strong> — drag the sliders and watch the
  transfer curve and the token distribution reshape live (a faithful port of the shaper; its top-1/entropy readout <em>predicts</em>
  coherence — a config whose HLG top-1 collapses below raw will salad). And <strong><a href="hlg-ab.html">hlg-ab.html</a></strong> —
  the same prompts sampled by the default recipe vs HLG-base vs HLG-loose-A, side by side, so the diversity differences are readable as text.
</div>

<h2><span class="n">10</span>Where it stands</h2>
<p class="lead">A map, held loosely. The durable structural results:</p>
<ul class="clean">
  <li>The coherence wall is a <strong>coupled <code>tg</code>/<code>W</code>/<code>s_m</code> cluster</strong>; <strong><code>A</code> is an orthogonal, free diversity lever</strong>;
  <strong><code>L_W</code> is a coherence-robust curvature knob</strong> outside the cluster.</li>
  <li>The <strong>sharpness coupling is invariant</strong> across models and architectures; the <strong>window axis is vocab-sensitive</strong>.</li>
  <li>Cliffs come in <strong>two shapes</strong>: <code>target_gap</code> a vocab-shifted ramp, <code>W</code>@highA a model-invariant sharp edge.</li>
  <li>Diversity wins are <strong>marginal</strong>, and K=20 trimmed them further: the only place HLG clears a model's default is the
  loosest <code>A</code> (+0.03), and <code>L_W</code> shaping sits below default everywhere. The value here is the <em>geometry</em>, not a diversity gain.</li>
  <li>The curve <strong>shape is secondary to the final sharpness</strong> (<code>out_scale</code>, set by <code>target_gap</code>). A heavily
  reshaped curve with <code>target_gap≈4</code> flattens the distribution (HLG top-1 25% vs raw 50%, entropy <em>up</em>) and salads on every seed —
  so the distribution's top-1/entropy, not the curve's looks, is the coherence oracle. The interactive explorer makes this checkable before you ever run the model.</li>
</ul>
<p>Open threads: a blind external-judge read of the actual text (the one instrument not yet collected); the <code>A</code> diversity
gradient on 12B/CPM5 at K=20 (only e4b is settled); finishing the cut A sweep (≥1.5) and re-measuring 12B/CPM5's <code>L_W</code> diversity at K=20.</p>

<div class="foot">
  <p><strong>Run index.</strong> Logs preserved under <code>docs/investigations/hlg-runs/</code>; full write-up in
  <code>docs/investigations/hlg-sampling-investigation.md</code>. Generators: <code>hlg-map</code>, <code>hlg-cross</code>, <code>hlg-lw</code>,
  <code>hlg-cliff</code>, <code>hlg-grid2</code>, <code>hlg-peak</code> (+ the <code>*-viz</code> figure builders).</p>
  <div class="runidx">
    <div><code>run0–O</code> — pivots, passes 1–4 (e4b)</div>
    <div><code>runP/Q/R</code> — A×s_m, tg×W grids, blind</div>
    <div><code>runS</code> — cross-pair coherence (e4b)</div>
    <div><code>runT/U</code> — cross-pair on CPM5 / 12B</div>
    <div><code>runV/W/X</code> — L_W sweep on e4b / 12B / CPM5</div>
    <div><code>runY/Z/AA</code> — cliff resolution, 3 models</div>
    <div><code>runAB/AC</code> — K=20 grids / peaks (e4b)</div>
  </div>
</div>

</div></body></html>`;

function figFigure(name: string, caption: string): string {
  return `<figure>${fig(name)}<figcaption>${caption}</figcaption></figure>`;
}

const outPath = `${process.cwd()}/docs/investigations/hlg-report.html`;
writeFileSync(outPath, html);
console.log(`wrote ${outPath} (${(html.length / 1024).toFixed(0)} KB)`);
