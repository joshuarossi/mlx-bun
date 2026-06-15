// Builds the K=20 deep-dive figures and writes them into the report figure dir.
//   k20-grids.svg  — the two fine 2-D coherence surfaces (junk% heatmaps):
//                    tg×s_m (cliff slides with the coupling hub) and W×A (edge slides with A).
//   k20-peaks.svg  — the two settled diversity sweeps vs the K=20 default (0.633):
//                    L_W (uniformly BELOW default — the K=6 "peak" was noise) and
//                    A (clean monotone — the free lever; only loosest A beats default).
//   bun scripts/hlg-k20-viz.ts

import { writeFileSync } from "node:fs";

const FIGDIR = `${process.cwd()}/docs/investigations/hlg-figs`;
const REF = 0.633; // K=20 default-recipe diversity (e4b)

// ---- grids (junk %) ----
type Heat = { title: string; sub: string; ylab: string; xlab: string; ys: string[]; xs: string[]; cells: number[][] };
const TG_SM: Heat = {
  title: "target_gap ramp × s_m", sub: "the cliff slides with the coupling hub",
  ylab: "s_m", xlab: "target_gap", ys: ["0.2", "0.7", "2", "4"], xs: ["7", "8", "9", "10", "11", "12"],
  cells: [[0, 0, 0, 0, 0, 0], [24, 20, 7, 0, 0, 0], [25, 25, 27, 23, 15, 10], [25, 25, 25, 24, 24, 20]],
};
const W_A: Heat = {
  title: "W sharp edge × A", sub: "the channel-close slides with A (≈4 at low A, ≈8 at A=100)",
  ylab: "A", xlab: "window (W)", ys: ["1", "10", "100"], xs: ["3", "4", "5", "6", "7", "8", "9", "10"],
  cells: [[6, 6, 0, 0, 0, 0, 0, 0], [6, 5, 0, 0, 0, 0, 0, 0], [25, 25, 26, 16, 6, 0, 0, 0]],
};
function heat(h: Heat, ox: number, oy: number, cell: number): string {
  const w = h.xs.length * cell, gh = h.ys.length * cell;
  let s = `<text x="${ox + w / 2}" y="${oy - 26}" text-anchor="middle" font-size="13.5" font-weight="700" fill="var(--text-primary,#1f2937)">${h.title}</text>`;
  s += `<text x="${ox + w / 2}" y="${oy - 10}" text-anchor="middle" font-size="10.5" fill="var(--text-secondary,#6b7280)">${h.sub}</text>`;
  for (let i = 0; i < h.ys.length; i++) for (let j = 0; j < h.xs.length; j++) {
    const v = h.cells[i]![j]!, x = ox + j * cell, y = oy + i * cell;
    const coh = v < 1;
    const op = coh ? 0.16 : Math.max(0.18, Math.min(0.92, v / 30));
    const col = coh ? "var(--positive,#16a34a)" : "#dc2626";
    s += `<rect x="${x}" y="${y}" width="${cell - 2}" height="${cell - 2}" rx="3" fill="${col}" fill-opacity="${op.toFixed(2)}" stroke="${col}" stroke-opacity="0.28"/>`;
    s += `<text x="${x + (cell - 2) / 2}" y="${y + (cell - 2) / 2 + 4}" text-anchor="middle" font-size="10.5" font-weight="${coh ? 400 : 600}" fill="${op > 0.5 ? "#fff" : "var(--text-primary,#1f2937)"}">${coh ? "·" : v}</text>`;
  }
  for (let j = 0; j < h.xs.length; j++) s += `<text x="${ox + j * cell + (cell - 2) / 2}" y="${oy + gh + 13}" text-anchor="middle" font-size="10" fill="var(--text-secondary,#6b7280)">${h.xs[j]}</text>`;
  for (let i = 0; i < h.ys.length; i++) s += `<text x="${ox - 7}" y="${oy + i * cell + (cell - 2) / 2 + 4}" text-anchor="end" font-size="10" fill="var(--text-secondary,#6b7280)">${h.ys[i]}</text>`;
  s += `<text x="${ox + w / 2}" y="${oy + gh + 30}" text-anchor="middle" font-size="10.5" fill="var(--text-tertiary,#9ca3af)">${h.xlab} →</text>`;
  s += `<text x="${ox - 30}" y="${oy + gh / 2}" text-anchor="middle" font-size="10.5" fill="var(--text-tertiary,#9ca3af)" transform="rotate(-90 ${ox - 30} ${oy + gh / 2})">${h.ylab} →</text>`;
  return s;
}
{
  const W = 900, H = 360;
  let s = `<svg viewBox="0 0 ${W} ${H}" xmlns="http://www.w3.org/2000/svg" role="img" aria-labelledby="t d" font-family="ui-sans-serif,system-ui,sans-serif">`;
  s += `<title id="t">K=20 coherence surfaces</title><desc id="d">Two fine 2-D coherence grids at K=20. The target_gap cliff slides monotonically with s_m; the W edge slides with A. Cells show mean junk percent; dot = coherent.</desc>`;
  s += `<text x="${W / 2}" y="26" text-anchor="middle" font-size="16" font-weight="700" fill="var(--text-primary,#1f2937)">Coherence is a tilted surface, not a fixed wall (K=20)</text>`;
  s += `<text x="${W / 2}" y="45" text-anchor="middle" font-size="11" fill="var(--text-secondary,#6b7280)">cell = mean canary junk% over 20 seeds · green dot = coherent · red = junk, darker = worse</text>`;
  s += heat(TG_SM, 95, 95, 40);
  s += heat(W_A, 545, 95, 38);
  s += `</svg>`;
  writeFileSync(`${FIGDIR}/k20-grids.svg`, s);
}

// ---- peaks (diversity) ----
type Curve = { gx: [number, number]; gy: [number, number]; xlog: boolean; pts: [number, number][]; xt: { v: number; l: string }[]; title: string; sub: string; xlab: string; col: string };
const LW: Curve = {
  gx: [0.72, 1.30], gy: [0.38, 0.68], xlog: false, col: "#2563eb",
  pts: [[0.78, 0.421], [0.85, 0.418], [0.92, 0.412], [0.99, 0.432], [1.06, 0.439], [1.13, 0.446], [1.20, 0.443], [1.27, 0.441]],
  xt: [{ v: 0.78, l: "0.8" }, { v: 1.0, l: "1.0" }, { v: 1.2, l: "1.2" }], title: "L_W around the supposed peak", sub: "K=20: uniformly BELOW default — the K=6 peak was noise", xlab: "OOTF γ",
};
const AG: Curve = {
  gx: [-2.1, 0.0], gy: [0.28, 0.68], xlog: true, col: "#16a34a",
  pts: [[0.01, 0.663], [0.05, 0.536], [0.1, 0.493], [0.2, 0.448], [0.35, 0.437], [0.7, 0.314]],
  xt: [{ v: 0.01, l: "0.01" }, { v: 0.05, l: "0.05" }, { v: 0.1, l: "0.1" }, { v: 0.35, l: "0.35" }, { v: 0.7, l: "0.7" }], title: "A diversity gradient", sub: "clean monotone — the free lever; only loosest A beats default", xlab: "A (shoulder)",
};
function curvePanel(c: Curve, ox: number, pw: number, oy: number, ph: number): string {
  const PL = ox + 42, PR = ox + pw - 14, PB = oy + ph - 42, PTp = oy + 34;
  const tx = (x: number): number => { const v = c.xlog ? Math.log10(x) : x; return PL + ((v - c.gx[0]) / (c.gx[1] - c.gx[0])) * (PR - PL); };
  const ty = (y: number): number => PB - ((y - c.gy[0]) / (c.gy[1] - c.gy[0])) * (PB - PTp);
  let s = `<text x="${(PL + PR) / 2}" y="${oy + 8}" text-anchor="middle" font-size="13.5" font-weight="700" fill="var(--text-primary,#1f2937)">${c.title}</text>`;
  s += `<text x="${(PL + PR) / 2}" y="${oy + 24}" text-anchor="middle" font-size="10.5" fill="${c.col}">${c.sub}</text>`;
  for (let g = 0.3; g <= 0.68; g += 0.1) {
    s += `<line x1="${PL}" y1="${ty(g)}" x2="${PR}" y2="${ty(g)}" stroke="var(--border,#e5e7eb)" stroke-opacity="0.6"/>`;
    s += `<text x="${PL - 6}" y="${ty(g) + 4}" text-anchor="end" font-size="9.5" fill="var(--text-tertiary,#9ca3af)">${g.toFixed(2)}</text>`;
  }
  // default reference
  s += `<line x1="${PL}" y1="${ty(REF)}" x2="${PR}" y2="${ty(REF)}" stroke="var(--text-tertiary,#9ca3af)" stroke-width="1.3" stroke-dasharray="6 4"/>`;
  s += `<text x="${PR}" y="${ty(REF) - 5}" text-anchor="end" font-size="9.5" fill="var(--text-tertiary,#9ca3af)">default ${REF}</text>`;
  for (const t of c.xt) { s += `<line x1="${tx(t.v)}" y1="${PB}" x2="${tx(t.v)}" y2="${PB + 4}" stroke="var(--text-tertiary,#9ca3af)"/><text x="${tx(t.v)}" y="${PB + 16}" text-anchor="middle" font-size="9.5" fill="var(--text-secondary,#6b7280)">${t.l}</text>`; }
  s += `<text x="${(PL + PR) / 2}" y="${PB + 33}" text-anchor="middle" font-size="10.5" fill="var(--text-secondary,#6b7280)">${c.xlab} →</text>`;
  const path = c.pts.map((p, i) => `${i ? "L" : "M"}${tx(p[0]).toFixed(1)} ${ty(p[1]).toFixed(1)}`).join(" ");
  s += `<path d="${path}" fill="none" stroke="${c.col}" stroke-width="2.5"/>`;
  for (const p of c.pts) { const beats = p[1] > REF; s += `<circle cx="${tx(p[0])}" cy="${ty(p[1])}" r="${beats ? 5 : 3.5}" fill="${c.col}" ${beats ? 'stroke="#16a34a" stroke-width="2"' : ""}/>`; }
  return s;
}
{
  const W = 900, H = 300;
  let s = `<svg viewBox="0 0 ${W} ${H}" xmlns="http://www.w3.org/2000/svg" role="img" aria-labelledby="t2 d2" font-family="ui-sans-serif,system-ui,sans-serif">`;
  s += `<title id="t2">K=20 diversity sweeps</title><desc id="d2">At K=20, L_W diversity sits uniformly below the default; the A gradient is a clean monotone that only beats default at the loosest A.</desc>`;
  s += `<text x="${W / 2}" y="24" text-anchor="middle" font-size="16" font-weight="700" fill="var(--text-primary,#1f2937)">Settled diversity at K=20 — one claim dies, one confirms</text>`;
  s += curvePanel(LW, 0, W / 2, 40, H - 40);
  s += curvePanel(AG, W / 2, W / 2, 40, H - 40);
  s += `</svg>`;
  writeFileSync(`${FIGDIR}/k20-peaks.svg`, s);
}
console.log("wrote k20-grids.svg + k20-peaks.svg");
