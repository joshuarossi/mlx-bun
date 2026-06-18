// Plots the fine cliff resolution: mean canary junk% vs the knob, one line per
// model, two panels (target_gap cliff, W lower edge @ A=100). Reveals the two
// cliff SHAPES the coarse maps hid — target_gap is a graded ramp (position shifts
// by vocab), W@highA is a sharp edge at ~7.5 (position model-invariant). Emits SVG.

type Series = { model: string; color: string; tg: number[]; w: number[] };
// mean junk % (K=5), runs runY/runZ/runAA.
const TG_X = [7, 8, 9, 10, 11, 12, 13];
const W_X = [3, 4, 5, 6, 7, 8, 9, 10];
const SERIES: Series[] = [
  { model: "e4b", color: "#2563eb", tg: [28, 31, 17, 1, 1, 0, 0], w: [24, 25, 20, 28, 16, 0, 0, 0] },
  { model: "12B", color: "#d97706", tg: [24, 17, 4, 1, 0, 0, 0], w: [26, 26, 24, 18, 13, 0, 0, 0] },
  { model: "CPM5", color: "#0891b2", tg: [9, 1, 1, 2, 0, 0, 0], w: [11, 11, 9, 4, 2, 0, 0, 0] },
];

const W = 920, H = 450, PT = 78, PB = 70;
const YMAX = 34;
function panel(ox: number, pw: number, xs: number[], get: (s: Series) => number[], title: string, sub: string, xlab: string): string {
  const PL = ox + 44, PR = ox + pw - 16, plotW = PR - PL, plotH = H - PT - PB;
  const px = (i: number): number => PL + (xs.length === 1 ? plotW / 2 : (i / (xs.length - 1)) * plotW);
  const py = (j: number): number => PT + (1 - Math.min(j, YMAX) / YMAX) * plotH;
  let s = `<text x="${(PL + PR) / 2}" y="${PT - 36}" text-anchor="middle" font-size="14" font-weight="700" fill="var(--text-primary,#1f2937)">${title}</text>`;
  s += `<text x="${(PL + PR) / 2}" y="${PT - 20}" text-anchor="middle" font-size="10.5" fill="var(--text-secondary,#6b7280)">${sub}</text>`;
  // y grid
  for (let j = 0; j <= 30; j += 10) {
    s += `<line x1="${PL}" y1="${py(j)}" x2="${PR}" y2="${py(j)}" stroke="var(--border,#e5e7eb)" stroke-opacity="0.6"/>`;
    s += `<text x="${PL - 8}" y="${py(j) + 4}" text-anchor="end" font-size="10" fill="var(--text-tertiary,#9ca3af)">${j}%</text>`;
  }
  // coherence threshold (1%)
  s += `<line x1="${PL}" y1="${py(1)}" x2="${PR}" y2="${py(1)}" stroke="var(--positive,#16a34a)" stroke-width="1.2" stroke-dasharray="5 3" stroke-opacity="0.8"/>`;
  s += `<text x="${PR}" y="${py(1) - 4}" text-anchor="end" font-size="9.5" fill="var(--positive,#16a34a)">coherent &lt;1%</text>`;
  // x ticks
  for (let i = 0; i < xs.length; i++) {
    s += `<line x1="${px(i)}" y1="${H - PB}" x2="${px(i)}" y2="${H - PB + 4}" stroke="var(--text-tertiary,#9ca3af)"/>`;
    s += `<text x="${px(i)}" y="${H - PB + 17}" text-anchor="middle" font-size="10" fill="var(--text-secondary,#6b7280)">${xs[i]}</text>`;
  }
  s += `<text x="${(PL + PR) / 2}" y="${H - PB + 36}" text-anchor="middle" font-size="11" fill="var(--text-secondary,#6b7280)">${xlab}</text>`;
  // series
  for (const ser of SERIES) {
    const ys = get(ser);
    const path = ys.map((j, i) => `${i ? "L" : "M"}${px(i).toFixed(1)} ${py(j).toFixed(1)}`).join(" ");
    s += `<path d="${path}" fill="none" stroke="${ser.color}" stroke-width="2.5" stroke-opacity="0.9"/>`;
    for (let i = 0; i < ys.length; i++) s += `<circle cx="${px(i)}" cy="${py(ys[i]!)}" r="3" fill="${ser.color}"/>`;
  }
  return s;
}

let svg = `<svg viewBox="0 0 ${W} ${H}" xmlns="http://www.w3.org/2000/svg" role="img" aria-labelledby="t d" font-family="ui-sans-serif,system-ui,sans-serif">`;
svg += `<title id="t">HLG cliff resolution — two shapes</title><desc id="d">Fine junk% gradient through the target_gap cliff (a graded ramp, position shifts by vocab) and the W lower edge at high A (a sharp model-invariant edge near 7.5), three models.</desc>`;
svg += `<text x="${W / 2}" y="30" text-anchor="middle" font-size="16.5" font-weight="700" fill="var(--text-primary,#1f2937)">Fine cliff resolution — the coarse grid jumped over two different shapes</text>`;
svg += `<text x="${W / 2}" y="49" text-anchor="middle" font-size="11.5" fill="var(--text-secondary,#6b7280)">unit steps · mean canary junk% (K=5 seeds) · the transition the 8/12 and 5/10 jumps hid</text>`;
svg += panel(0, W / 2, TG_X, (s) => s.tg, "target_gap cliff — a graded ramp", "base (A=0.35, s_m=0.7, W=6) · position shifts by vocab", "target_gap  →");
svg += panel(W / 2, W / 2, W_X, (s) => s.w, "W edge @ A=100 — a sharp cliff", "channel closes abruptly 7→8 in all three", "window (W)  →");
// legend
let lx = W / 2 - 150;
for (const ser of SERIES) {
  svg += `<line x1="${lx}" y1="${H - 14}" x2="${lx + 20}" y2="${H - 14}" stroke="${ser.color}" stroke-width="2.5"/><circle cx="${lx + 10}" cy="${H - 14}" r="3" fill="${ser.color}"/>`;
  svg += `<text x="${lx + 26}" y="${H - 10}" font-size="11" fill="var(--text-secondary,#6b7280)">${ser.model}</text>`;
  lx += 100;
}
svg += `</svg>`;
console.log(svg);
