// Edge-texture figure: break-rate (fraction of K=20 seeds that broke) across the
// four transition zooms. Reveals the edges are heterogeneous — the gate cliffs are
// SOFT probabilistic ramps (declining break-rate), the L_W low wall is a HARD γ=0
// threshold, the L_W high wall is barely there. Writes docs/investigations/hlg-figs/edges.svg.
//   bun scripts/hlg-edge-viz.ts

import { writeFileSync } from "node:fs";
const FIGDIR = `${process.cwd()}/docs/investigations/hlg-figs`;

type Panel = { title: string; verdict: string; vcol: string; xs: number[]; xlab: string; brk: number[]; mean: number[]; note?: string };
const PANELS: Panel[] = [
  { title: "target_gap ramp", verdict: "soft · probabilistic", vcol: "#d97706", xlab: "target_gap", xs: [7, 7.5, 8, 8.5, 9, 9.5, 10, 10.5, 11], brk: [100, 100, 100, 85, 70, 50, 10, 10, 15], mean: [24, 22, 20, 14, 7, 6, 0, 0, 0] },
  { title: "W channel-close (A=100)", verdict: "soft · steeper", vcol: "#d97706", xlab: "window W", xs: [6, 6.5, 7, 7.25, 7.5, 7.75, 8, 8.5, 9], brk: [90, 90, 50, 35, 20, 20, 10, 0, 0], mean: [16, 9, 6, 5, 5, 1, 0, 0, 0] },
  { title: "L_W low wall (γ→0)", verdict: "HARD · at γ=0", vcol: "#dc2626", xlab: "γ", xs: [0.0, 0.03, 0.05, 0.07, 0.09, 0.12, 0.15, 0.19, 0.27, 0.36], brk: [0, 0, 0, 0, 0, 0, 0, 0, 0, 0], mean: [0, 0, 0, 0, 0, 0, 0, 0, 0, 0], note: "every point γ≥0 is clean — the wall is the sign flip at γ<0, a deterministic discontinuity just off the left edge" },
  { title: "L_W high wall (γ→2.4)", verdict: "barely a wall", vcol: "#16a34a", xlab: "γ", xs: [2.11, 2.17, 2.24, 2.33, 2.39, 2.46], brk: [0, 5, 5, 10, 10, 15], mean: [0, 0, 0, 0, 0, 0], note: "only 3/20 break even at γ=2.46 — the coarse 'REJECT' was a 1-of-2-seed artifact" },
];

const PW = 430, PH = 250, ML = 46, MR = 16, MT = 46, MB = 46;
function panel(p: Panel, ox: number, oy: number): string {
  const xmin = Math.min(...p.xs), xmax = Math.max(...p.xs);
  const tx = (x: number): number => ox + ML + (xmax === xmin ? 0.5 : (x - xmin) / (xmax - xmin)) * (PW - ML - MR);
  const ty = (b: number): number => oy + MT + (1 - b / 100) * (PH - MT - MB);
  let s = `<text x="${ox + ML}" y="${oy + 22}" font-size="14" font-weight="700" fill="var(--text-primary,#1f2937)">${p.title}</text>`;
  s += `<text x="${ox + PW - MR}" y="${oy + 22}" text-anchor="end" font-size="11.5" font-weight="700" fill="${p.vcol}">${p.verdict}</text>`;
  for (let b = 0; b <= 100; b += 25) { s += `<line x1="${ox + ML}" y1="${ty(b)}" x2="${ox + PW - MR}" y2="${ty(b)}" stroke="var(--grid,#eef2f7)"/><text x="${ox + ML - 6}" y="${ty(b) + 3}" text-anchor="end" font-size="9" fill="var(--text-tertiary,#9ca3af)">${b}%</text>`; }
  // mean-junk faint bars
  const bw = (PW - ML - MR) / p.xs.length * 0.5;
  for (let i = 0; i < p.xs.length; i++) { const h = (p.mean[i]! / 100) * (PH - MT - MB); s += `<rect x="${tx(p.xs[i]!) - bw / 2}" y="${ty(0) - h}" width="${bw}" height="${h}" fill="var(--text-tertiary,#9ca3af)" opacity="0.28" rx="1"/>`; }
  // break-rate line
  const path = p.xs.map((x, i) => `${i ? "L" : "M"}${tx(x).toFixed(1)} ${ty(p.brk[i]!).toFixed(1)}`).join(" ");
  s += `<path d="${path}" fill="none" stroke="${p.vcol}" stroke-width="2.5"/>`;
  for (let i = 0; i < p.xs.length; i++) s += `<circle cx="${tx(p.xs[i]!)}" cy="${ty(p.brk[i]!)}" r="3" fill="${p.vcol}"/>`;
  for (let i = 0; i < p.xs.length; i += Math.ceil(p.xs.length / 6)) s += `<text x="${tx(p.xs[i]!)}" y="${oy + PH - MB + 15}" text-anchor="middle" font-size="9" fill="var(--text-secondary,#6b7280)">${p.xs[i]}</text>`;
  s += `<text x="${ox + (ML + PW - MR) / 2}" y="${oy + PH - MB + 31}" text-anchor="middle" font-size="10.5" fill="var(--text-secondary,#6b7280)">${p.xlab} →</text>`;
  if (p.note) s += `<text x="${ox + ML}" y="${oy + MT - 8}" font-size="9.5" fill="var(--text-tertiary,#9ca3af)">${wrap(p.note, 64).map((l, i) => `<tspan x="${ox + ML}" dy="${i ? 11 : 0}">${l}</tspan>`).join("")}</text>`;
  return s;
}
function wrap(t: string, n: number): string[] { const w = t.split(" "), out: string[] = []; let cur = ""; for (const x of w) { if ((cur + " " + x).trim().length > n) { out.push(cur.trim()); cur = x; } else cur += " " + x; } if (cur.trim()) out.push(cur.trim()); return out; }

const W = 2 * PW, H = 2 * PH + 36;
let svg = `<svg viewBox="0 0 ${W} ${H}" xmlns="http://www.w3.org/2000/svg" role="img" aria-labelledby="t d" font-family="ui-sans-serif,system-ui,sans-serif">`;
svg += `<title id="t">HLG edge texture</title><desc id="d">Break-rate across the four transition zooms at K=20: the gate cliffs are soft probabilistic ramps, the L_W low wall is a hard threshold at gamma 0, the high wall is barely there.</desc>`;
svg += `<text x="${W / 2}" y="26" text-anchor="middle" font-size="17" font-weight="700" fill="var(--text-primary,#1f2937)">Edge texture (K=20) — break-rate, not magnitude, is what slides</text>`;
svg += panel(PANELS[0]!, 0, 36); svg += panel(PANELS[1]!, PW, 36);
svg += panel(PANELS[2]!, 0, 36 + PH); svg += panel(PANELS[3]!, PW, 36 + PH);
svg += `<text x="${ML}" y="${H - 6}" font-size="10.5" fill="var(--text-tertiary,#9ca3af)">line = % of 20 seeds that broke · faint bars = mean junk% · the cliffs are statistical edges (some seeds wander into junk), not hard thresholds</text>`;
svg += `</svg>`;
writeFileSync(`${FIGDIR}/edges.svg`, svg);
console.log("wrote edges.svg");
