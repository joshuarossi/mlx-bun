// Plots the L_W (OOTF γ) sweep as a diversity-vs-γ curve, one line per model.
// Shows the coherent band, the two walls (γ<0 inversion, γ≳2.4 over-sharpen), the
// default-diversity reference, and the interior diversity peak near γ≈1. Emits SVG.
export {};

type Pt = { lw: number; g: number; div: number | null; rej?: boolean };
type Series = { model: string; color: string; ref: number; pts: Pt[] };

const SERIES: Series[] = [
  { model: "e4b", color: "#2563eb", ref: 0.70, pts: [
    { lw: 1, g: -0.06, div: null, rej: true }, { lw: 3, g: 0.14, div: 0.67 }, { lw: 10, g: 0.36, div: 0.69 },
    { lw: 30, g: 0.56, div: 0.68 }, { lw: 100, g: 0.78, div: 0.69 }, { lw: 300, g: 0.98, div: 0.76 },
    { lw: 1000, g: 1.20, div: 0.72 }, { lw: 3000, g: 1.40, div: 0.59 }, { lw: 10000, g: 1.62, div: 0.61 },
    { lw: 30000, g: 1.82, div: 0.61 }, { lw: 100000, g: 2.04, div: 0.57 }, { lw: 1000000, g: 2.46, div: null, rej: true },
  ] },
  { model: "12B", color: "#d97706", ref: 0.72, pts: [
    { lw: 1, g: -0.06, div: null, rej: true }, { lw: 3, g: 0.14, div: 0.53 }, { lw: 10, g: 0.36, div: 0.51 },
    { lw: 30, g: 0.56, div: 0.51 }, { lw: 100, g: 0.78, div: 0.51 }, { lw: 300, g: 0.98, div: 0.56 },
    { lw: 1000, g: 1.20, div: 0.54 }, { lw: 3000, g: 1.40, div: 0.54 }, { lw: 10000, g: 1.62, div: 0.55 },
    { lw: 30000, g: 1.82, div: 0.55 }, { lw: 100000, g: 2.04, div: 0.55 }, { lw: 1000000, g: 2.46, div: null, rej: true },
  ] },
  { model: "CPM5", color: "#0891b2", ref: 0.68, pts: [
    { lw: 1, g: -0.06, div: null, rej: true }, { lw: 3, g: 0.14, div: 0.64 }, { lw: 10, g: 0.36, div: 0.59 },
    { lw: 30, g: 0.56, div: 0.61 }, { lw: 100, g: 0.78, div: 0.57 }, { lw: 300, g: 0.98, div: 0.57 },
    { lw: 1000, g: 1.20, div: 0.56 }, { lw: 3000, g: 1.40, div: 0.55 }, { lw: 10000, g: 1.62, div: 0.58 },
    { lw: 30000, g: 1.82, div: 0.56 }, { lw: 100000, g: 2.04, div: 0.53 }, { lw: 1000000, g: 2.46, div: 0.56 },
  ] },
];
const REF_BAND: [number, number] = [0.68, 0.72];   // span of the three default recipes
const COHERENT_G: [number, number] = [0.14, 2.04]; // Gemma coherent γ band (CPM5 extends to 2.46)

// plot geometry
const W = 800, H = 480, PL = 70, PR = 30, PT = 70, PB = 84;
const GX: [number, number] = [-0.25, 2.6], GY: [number, number] = [0.48, 0.80];
const px = (g: number): number => PL + ((g - GX[0]) / (GX[1] - GX[0])) * (W - PL - PR);
const py = (d: number): number => PT + (1 - (d - GY[0]) / (GY[1] - GY[0])) * (H - PT - PB);

let s = `<svg viewBox="0 0 ${W} ${H}" xmlns="http://www.w3.org/2000/svg" role="img" aria-labelledby="t d" font-family="ui-sans-serif,system-ui,sans-serif">`;
s += `<title id="t">L_W (OOTF γ) — diversity curve</title><desc id="d">Diversity vs OOTF gamma for the L_W knob; coherent band shaded, walls at gamma below 0 and above ~2.4, interior diversity peak near gamma 1.</desc>`;
s += `<text x="${W / 2}" y="28" text-anchor="middle" font-size="16" font-weight="700" fill="var(--text-primary,#1f2937)">L_W across 3 models — a coherence-robust curvature knob; diversity response differs</text>`;
s += `<text x="${W / 2}" y="46" text-anchor="middle" font-size="11.5" fill="var(--text-secondary,#6b7280)">x = OOTF γ (= 1.2 + 0.42·log₁₀(L_W/1000)) · y = diversity (1−self-BLEU) · 3 models · coherent across ~5 decades, walls only at the extremes</text>`;

// coherent band (Gemma)
s += `<rect x="${px(COHERENT_G[0])}" y="${PT}" width="${px(COHERENT_G[1]) - px(COHERENT_G[0])}" height="${H - PT - PB}" fill="var(--positive,#16a34a)" fill-opacity="0.06"/>`;
s += `<text x="${(px(COHERENT_G[0]) + px(COHERENT_G[1])) / 2}" y="${PT + 14}" text-anchor="middle" font-size="10.5" fill="var(--positive,#16a34a)" font-weight="600">coherent band  (L_W 3 … 100k+)</text>`;
// walls
s += `<line x1="${px(0)}" y1="${PT}" x2="${px(0)}" y2="${H - PB}" stroke="#ef4444" stroke-width="1.5" stroke-dasharray="4 3" stroke-opacity="0.7"/>`;
s += `<text x="${px(0) - 4}" y="${H - PB - 6}" text-anchor="end" font-size="10" fill="#b91c1c">γ&lt;0 inverts → wall (all)</text>`;
s += `<line x1="${px(2.4)}" y1="${PT}" x2="${px(2.4)}" y2="${H - PB}" stroke="#ef4444" stroke-width="1.5" stroke-dasharray="4 3" stroke-opacity="0.7"/>`;
s += `<text x="${px(2.4) - 5}" y="${PT + 28}" text-anchor="end" font-size="10" fill="#b91c1c">over-sharpen wall (Gemmas only)</text>`;

// y gridlines + labels
for (let d = 0.50; d <= 0.80 + 1e-9; d += 0.05) {
  s += `<line x1="${PL}" y1="${py(d)}" x2="${W - PR}" y2="${py(d)}" stroke="var(--border,#e5e7eb)" stroke-opacity="0.6"/>`;
  s += `<text x="${PL - 8}" y="${py(d) + 4}" text-anchor="end" font-size="10" fill="var(--text-tertiary,#9ca3af)">${d.toFixed(2)}</text>`;
}
// x ticks (γ) + L_W reference labels
const xticks: { g: number; lw: string }[] = [{ g: 0, lw: "100" }, { g: 0.5, lw: "21" }, { g: 1.0, lw: "334" }, { g: 1.2, lw: "1k" }, { g: 1.5, lw: "5k" }, { g: 2.0, lw: "80k" }, { g: 2.5, lw: "1.4M" }];
for (const t of xticks) {
  s += `<line x1="${px(t.g)}" y1="${H - PB}" x2="${px(t.g)}" y2="${H - PB + 5}" stroke="var(--text-tertiary,#9ca3af)"/>`;
  s += `<text x="${px(t.g)}" y="${H - PB + 18}" text-anchor="middle" font-size="10" fill="var(--text-secondary,#6b7280)">${t.g.toFixed(1)}</text>`;
  s += `<text x="${px(t.g)}" y="${H - PB + 31}" text-anchor="middle" font-size="8.5" fill="var(--text-tertiary,#9ca3af)">L_W ${t.lw}</text>`;
}
s += `<text x="${(PL + W - PR) / 2}" y="${H - 14}" text-anchor="middle" font-size="11" fill="var(--text-secondary,#6b7280)">OOTF γ  →  sharper</text>`;
s += `<text x="18" y="${(PT + H - PB) / 2}" text-anchor="middle" font-size="11" fill="var(--text-secondary,#6b7280)" transform="rotate(-90 18 ${(PT + H - PB) / 2})">diversity →</text>`;

// default-recipe band (the three models' defaults span 0.68–0.72)
s += `<rect x="${PL}" y="${py(REF_BAND[1])}" width="${W - PR - PL}" height="${py(REF_BAND[0]) - py(REF_BAND[1])}" fill="var(--text-tertiary,#9ca3af)" fill-opacity="0.13"/>`;
for (const r of REF_BAND) s += `<line x1="${PL}" y1="${py(r)}" x2="${W - PR}" y2="${py(r)}" stroke="var(--text-tertiary,#9ca3af)" stroke-width="1" stroke-dasharray="6 4" stroke-opacity="0.7"/>`;
s += `<text x="${W - PR - 4}" y="${py(REF_BAND[1]) - 5}" text-anchor="end" font-size="10" fill="var(--text-tertiary,#9ca3af)">default recipes (0.68–0.72)</text>`;

// series
for (const ser of SERIES) {
  const acc = ser.pts.filter((p) => p.div !== null);
  const path = acc.map((p, i) => `${i ? "L" : "M"}${px(p.g).toFixed(1)} ${py(p.div!).toFixed(1)}`).join(" ");
  s += `<path d="${path}" fill="none" stroke="${ser.color}" stroke-width="2.5"/>`;
  for (const p of acc) s += `<circle cx="${px(p.g)}" cy="${py(p.div!)}" r="3.5" fill="${ser.color}"/>`;
  for (const p of ser.pts.filter((p) => p.rej)) s += `<text x="${px(p.g)}" y="${py(GY[0]) - 4}" text-anchor="middle" font-size="13" fill="#b91c1c" font-weight="700">✗</text>`;
}
// NB: traces are the coarse K=6 sweep — they show the coherence structure (walls, robustness)
// and the qualitative shape; the absolute diversity values are settled at K=20 in the report's §9.
// legend (top, centered — clear of the plot)
let lx = W / 2 - 105;
for (const ser of SERIES) {
  s += `<line x1="${lx}" y1="61" x2="${lx + 20}" y2="61" stroke="${ser.color}" stroke-width="2.5"/><circle cx="${lx + 10}" cy="61" r="3.5" fill="${ser.color}"/>`;
  s += `<text x="${lx + 26}" y="65" font-size="11" fill="var(--text-secondary,#6b7280)">${ser.model}</text>`;
  lx += 70;
}
s += `</svg>`;
console.log(s);
