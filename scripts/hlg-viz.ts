// Generates an SVG heatmap of the HLG diversity terrain from the measured grids.
// Two planes side by side; cell colour = diversity (self-BLEU), ✗ = canary broke.
// Emits raw SVG to stdout (CSS-variable themed) for the visualize widget.

type Cell = number | null; // null = canary broke (✗)
interface Grid { title: string; xLabel: string; yLabel: string; cols: string[]; rows: string[]; cells: Cell[][] }

// e4b, measured (runP / runQ). rows top→bottom, cols left→right.
const AxSm: Grid = {
  title: "A × s_m", xLabel: "A (shoulder)  → tighter", yLabel: "s_m →",
  cols: ["0.01", "0.05", "0.2", "1", "5"], rows: ["0.05", "0.2", "0.7", "1.5", "3"],
  cells: [
    [0.81, 0.83, 0.86, 0.82, 0.56],
    [0.85, 0.73, 0.86, 0.76, 0.58],
    [0.80, 0.74, 0.81, 0.72, 0.67],
    [0.79, 0.71, 0.74, 0.66, null],
    [0.78, null, null, null, null],
  ],
};
const TgW: Grid = {
  title: "target_gap × W", xLabel: "target_gap  → sharper", yLabel: "W →",
  cols: ["10", "13", "16", "25", "50"], rows: ["4", "5", "6", "10", "20"],
  cells: [
    [null, null, null, 0.78, 0.57],
    [null, null, 0.75, 0.78, 0.57],
    [null, 0.81, 0.71, 0.71, 0.50],
    [0.75, 0.78, 0.74, 0.73, 0.57],
    [0.88, 0.58, 0.63, 0.60, 0.58],
  ],
};
const REF = 0.799; // default diversity contour

const CELL = 50, GAP = 2;
function heatmap(g: Grid, ox: number, oy: number): string {
  let s = `<text x="${ox + (g.cols.length * CELL) / 2}" y="${oy - 30}" text-anchor="middle" font-size="15" font-weight="700" fill="var(--text-primary,#1f2937)">${g.title}</text>`;
  s += `<text x="${ox + (g.cols.length * CELL) / 2}" y="${oy - 12}" text-anchor="middle" font-size="11" fill="var(--text-secondary,#6b7280)">${g.xLabel}</text>`;
  s += `<text x="${ox - 26}" y="${oy + (g.rows.length * CELL) / 2}" text-anchor="middle" font-size="11" fill="var(--text-secondary,#6b7280)" transform="rotate(-90 ${ox - 26} ${oy + (g.rows.length * CELL) / 2})">${g.yLabel}</text>`;
  for (let j = 0; j < g.cols.length; j++)
    s += `<text x="${ox + j * CELL + CELL / 2}" y="${oy + g.rows.length * CELL + 16}" text-anchor="middle" font-size="11" fill="var(--text-secondary,#6b7280)">${g.cols[j]}</text>`;
  for (let i = 0; i < g.rows.length; i++)
    s += `<text x="${ox - 8}" y="${oy + i * CELL + CELL / 2 + 4}" text-anchor="end" font-size="11" fill="var(--text-secondary,#6b7280)">${g.rows[i]}</text>`;
  for (let i = 0; i < g.rows.length; i++) {
    for (let j = 0; j < g.cols.length; j++) {
      const v = g.cells[i]![j]!;
      const x = ox + j * CELL, y = oy + i * CELL, w = CELL - GAP;
      if (v === null) {
        s += `<rect x="${x}" y="${y}" width="${w}" height="${w}" rx="4" fill="var(--bg-tertiary,#e5e7eb)" stroke="var(--border,#d1d5db)"/>`;
        s += `<text x="${x + w / 2}" y="${y + w / 2 + 5}" text-anchor="middle" font-size="15" fill="var(--text-tertiary,#9ca3af)">✗</text>`;
      } else {
        const op = Math.max(0.07, Math.min(0.95, (v - 0.5) / 0.4));
        const beats = v > REF;
        s += `<rect x="${x}" y="${y}" width="${w}" height="${w}" rx="4" fill="var(--accent,#2563eb)" fill-opacity="${op.toFixed(2)}" ${beats ? 'stroke="var(--positive,#16a34a)" stroke-width="2"' : 'stroke="var(--border,#e5e7eb)"'}/>`;
        s += `<text x="${x + w / 2}" y="${y + w / 2 + 4}" text-anchor="middle" font-size="11" font-weight="${beats ? 700 : 400}" fill="${op > 0.55 ? "#fff" : "var(--text-primary,#1f2937)"}">${v.toFixed(2)}</text>`;
      }
    }
  }
  return s;
}

const W = 900, H = 470;
let svg = `<svg viewBox="0 0 ${W} ${H}" xmlns="http://www.w3.org/2000/svg" role="img" aria-labelledby="ht htd" font-family="ui-sans-serif,system-ui,sans-serif">`;
svg += `<title id="ht">HLG diversity terrain — two planes</title><desc id="htd">Heatmaps of self-BLEU diversity across the A×s_m and target_gap×W planes; darker = more diverse; ✗ = incoherent; green outline = above the default contour.</desc>`;
svg += `<text x="${W / 2}" y="28" text-anchor="middle" font-size="17" font-weight="700" fill="var(--text-primary,#1f2937)">HLG diversity terrain (e4b) — coherent basin + diversity (self-BLEU)</text>`;
svg += heatmap(AxSm, 110, 90);
svg += heatmap(TgW, 600, 90);
// legend
svg += `<g transform="translate(110,${H - 28})">`;
svg += `<rect x="0" y="-10" width="16" height="16" rx="3" fill="var(--bg-tertiary,#e5e7eb)" stroke="var(--border,#d1d5db)"/><text x="22" y="3" font-size="11" fill="var(--text-secondary,#6b7280)">✗ incoherent (canary broke)</text>`;
svg += `<rect x="200" y="-10" width="16" height="16" rx="3" fill="var(--accent,#2563eb)" fill-opacity="0.3"/><rect x="218" y="-10" width="16" height="16" rx="3" fill="var(--accent,#2563eb)" fill-opacity="0.85"/><text x="240" y="3" font-size="11" fill="var(--text-secondary,#6b7280)">diversity: light → dark = more diverse</text>`;
svg += `<rect x="540" y="-10" width="16" height="16" rx="3" fill="none" stroke="var(--positive,#16a34a)" stroke-width="2"/><text x="562" y="3" font-size="11" fill="var(--text-secondary,#6b7280)">above default contour (${REF})</text>`;
svg += `</g></svg>`;
console.log(svg);
