// Generates an SVG comparing the cross-pair COHERENCE maps across 3 models
// (e4b, 12B = Gemma/262k vocab; CPM5 = Llama/~73k vocab). Each plane is a 4×4
// clean/broke grid per model, grouped into "replicates across models" (the
// sharpness cluster) vs "vocab-dependent" (the window axis). Emits raw SVG.
export {};

type Plane = { name: string; xs: string[]; ys: string[]; xlab: string; ylab: string };
const PLANES: Record<string, Plane> = {
  smtg: { name: "s_m × target_gap", xs: ["8", "12", "20", "50"], ys: ["0.2", "0.7", "2", "4"], xlab: "tg →", ylab: "s_m →" },
  atg: { name: "A × target_gap", xs: ["8", "12", "20", "50"], ys: ["0.5", "5", "30", "100"], xlab: "tg →", ylab: "A →" },
  smw: { name: "s_m × W", xs: ["3", "5", "10", "30"], ys: ["0.2", "0.7", "2", "4"], xlab: "W →", ylab: "s_m →" },
  aw: { name: "A × W", xs: ["3", "5", "10", "30"], ys: ["0.5", "5", "30", "100"], xlab: "W →", ylab: "A →" },
};
// 1 = coherent, 0 = canary broke. rows top→bottom, cols left→right.
const D: Record<string, Record<string, number[][]>> = {
  e4b: {
    smtg: [[1, 1, 1, 1], [0, 1, 1, 1], [0, 0, 1, 1], [0, 0, 1, 1]],
    atg: [[0, 1, 1, 1], [0, 0, 1, 1], [0, 1, 1, 1], [0, 0, 1, 1]],
    smw: [[0, 1, 1, 1], [0, 1, 1, 1], [0, 0, 1, 1], [0, 0, 1, 1]],
    aw: [[0, 1, 1, 1], [0, 1, 1, 1], [0, 1, 1, 1], [0, 0, 1, 1]],
  },
  "12B": {
    smtg: [[1, 1, 1, 1], [0, 1, 1, 1], [0, 0, 1, 1], [0, 0, 1, 1]],
    atg: [[0, 1, 1, 1], [0, 1, 1, 1], [0, 1, 1, 1], [0, 0, 1, 1]],
    smw: [[0, 1, 1, 1], [0, 1, 1, 1], [0, 0, 1, 1], [0, 0, 1, 1]],
    aw: [[0, 1, 1, 1], [0, 1, 1, 1], [0, 0, 1, 1], [0, 0, 1, 0]],
  },
  CPM5: {
    smtg: [[1, 1, 1, 1], [1, 1, 1, 1], [0, 0, 1, 1], [0, 0, 1, 1]],
    atg: [[0, 1, 1, 1], [0, 1, 1, 1], [0, 1, 1, 1], [0, 0, 1, 1]],
    smw: [[1, 1, 1, 1], [1, 1, 1, 1], [1, 1, 1, 1], [1, 1, 1, 1]],
    aw: [[1, 1, 1, 1], [1, 1, 1, 1], [0, 1, 1, 0], [0, 0, 1, 0]],
  },
};
const MODELS = ["e4b", "12B", "CPM5"];
const MODEL_SUB: Record<string, string> = { e4b: "Gemma · 262k", "12B": "Gemma · 262k", CPM5: "Llama · ~73k" };
const BANDS = [
  { title: "Replicates across all 3 — the sharpness cluster", planes: ["smtg", "atg"], color: "var(--positive,#16a34a)" },
  { title: "Vocab-dependent — the window axis (Gemmas agree, CPM5 diverges)", planes: ["smw", "aw"], color: "var(--accent,#2563eb)" },
];

const CS = 19; // cell size
function grid(p: Plane, m: number[][], ox: number, oy: number): string {
  let s = "";
  for (let i = 0; i < 4; i++)
    for (let j = 0; j < 4; j++) {
      const ok = m[i]![j]! === 1;
      const x = ox + j * CS, y = oy + i * CS;
      s += `<rect x="${x}" y="${y}" width="${CS - 1.5}" height="${CS - 1.5}" rx="2" fill="${ok ? "var(--positive,#16a34a)" : "#ef4444"}" fill-opacity="${ok ? 0.22 : 0.34}" stroke="${ok ? "var(--positive,#16a34a)" : "#ef4444"}" stroke-opacity="0.4"/>`;
      if (!ok) s += `<text x="${x + (CS - 1.5) / 2}" y="${y + (CS - 1.5) / 2 + 3.5}" text-anchor="middle" font-size="10" fill="#b91c1c">✗</text>`;
    }
  // axis labels
  s += `<text x="${ox - 6}" y="${oy + 2 * CS}" text-anchor="middle" font-size="9" fill="var(--text-tertiary,#9ca3af)" transform="rotate(-90 ${ox - 6} ${oy + 2 * CS})">${p.ylab}</text>`;
  s += `<text x="${ox + 2 * CS}" y="${oy + 4 * CS + 11}" text-anchor="middle" font-size="9" fill="var(--text-tertiary,#9ca3af)">${p.xlab}</text>`;
  return s;
}

const W = 960, H = 658;
let svg = `<svg viewBox="0 0 ${W} ${H}" xmlns="http://www.w3.org/2000/svg" role="img" aria-labelledby="t d" font-family="ui-sans-serif,system-ui,sans-serif">`;
svg += `<title id="t">HLG coherence geometry across three models</title><desc id="d">Cross-pair coherence grids for e4b, 12B and CPM5. The sharpness cluster (s_m×tg, A×tg) replicates across all three; the window axis (s_m×W, A×W) tracks vocab size — the two Gemmas agree, CPM5 diverges.</desc>`;
svg += `<text x="${W / 2}" y="26" text-anchor="middle" font-size="17" font-weight="700" fill="var(--text-primary,#1f2937)">Does the geometry generalize? Cross-pair coherence across 3 models</text>`;
svg += `<text x="${W / 2}" y="46" text-anchor="middle" font-size="12" fill="var(--text-secondary,#6b7280)">green = coherent · red ✗ = canary broke · each grid is 4×4 over the break-spanning ranges</text>`;

const colX = [250, 480, 710];
// model column headers
for (let k = 0; k < MODELS.length; k++) {
  svg += `<text x="${colX[k]! + 38}" y="78" text-anchor="middle" font-size="13" font-weight="700" fill="var(--text-primary,#1f2937)">${MODELS[k]}</text>`;
  svg += `<text x="${colX[k]! + 38}" y="93" text-anchor="middle" font-size="9.5" fill="var(--text-tertiary,#9ca3af)">${MODEL_SUB[MODELS[k]!]}</text>`;
}

let y = 108;
for (const band of BANDS) {
  const bandH = band.planes.length * 118 + 8;
  svg += `<rect x="14" y="${y}" width="${W - 28}" height="${bandH}" rx="8" fill="${band.color}" fill-opacity="0.05" stroke="${band.color}" stroke-opacity="0.35"/>`;
  svg += `<text x="26" y="${y + 16}" font-size="12" font-weight="700" fill="${band.color}">${band.title}</text>`;
  let py = y + 30;
  for (const pk of band.planes) {
    const p = PLANES[pk]!;
    svg += `<text x="150" y="${py + 42}" text-anchor="end" font-size="12.5" font-weight="600" fill="var(--text-primary,#1f2937)">${p.name}</text>`;
    for (let k = 0; k < MODELS.length; k++) svg += grid(p, D[MODELS[k]!]![pk]!, colX[k]! + 12, py + 8);
    py += 118;
  }
  y += bandH + 14;
}
// legend
svg += `<g transform="translate(26,${H - 14})">`;
svg += `<rect x="0" y="-11" width="14" height="14" rx="2" fill="var(--positive,#16a34a)" fill-opacity="0.22" stroke="var(--positive,#16a34a)" stroke-opacity="0.4"/><text x="20" y="0" font-size="11" fill="var(--text-secondary,#6b7280)">coherent</text>`;
svg += `<rect x="100" y="-11" width="14" height="14" rx="2" fill="#ef4444" fill-opacity="0.34" stroke="#ef4444" stroke-opacity="0.4"/><text x="120" y="0" font-size="11" fill="var(--text-secondary,#6b7280)">canary broke</text>`;
svg += `<text x="240" y="0" font-size="11" font-style="italic" fill="var(--text-tertiary,#9ca3af)">Same red pattern across columns = the curve, not the model.</text>`;
svg += `</g></svg>`;
console.log(svg);
