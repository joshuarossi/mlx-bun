// Static SVG preview for docs/investigations/curve-runs/curve-terrain.json.
// The interactive terrain is docs/investigations/curve-terrain.html; this SVG is
// a lightweight thread/report preview that does not need a browser runtime.

import { readFileSync, writeFileSync } from "node:fs";

type Cell = {
  midY: number;
  shoulderY: number;
  valid: boolean;
  canaryJunk?: number;
  openJunk?: number;
  diversity?: number;
  score?: number;
};

const src = `${process.cwd()}/docs/investigations/curve-runs/curve-terrain.json`;
const out = `${process.cwd()}/docs/investigations/curve-runs/curve-terrain.svg`;
const data = JSON.parse(readFileSync(src, "utf8")) as {
  model: string;
  n: number;
  seed: number;
  axes: { midY: number[]; shoulderY: number[] };
  default: { diversity: number; recipe?: { temperature: number; topP: number; topK: number } };
  cells: Cell[];
};

const cells = data.cells.filter((c) => c.valid && c.score !== undefined) as Required<Cell>[];
const minScore = Math.min(...cells.map((c) => c.score));
const maxScore = Math.max(...cells.map((c) => c.score));
const lx = (v: number) => Math.log(v);
const norm = (v: number, a: number, b: number) => (v - a) / ((b - a) || 1);
const xMin = lx(Math.min(...data.axes.midY)), xMax = lx(Math.max(...data.axes.midY));
const yMin = lx(Math.min(...data.axes.shoulderY)), yMax = lx(Math.max(...data.axes.shoulderY));

function project(c: Required<Cell>): { x: number; y: number; z: number; t: number; junk: number } {
  const x = norm(lx(c.midY), xMin, xMax);
  const y = norm(lx(c.shoulderY), yMin, yMax);
  const t = norm(c.score, minScore, maxScore);
  const z = t;
  const px = 130 + (x - y) * 230;
  const py = 340 + (x + y) * 82 - z * 165;
  return { x: px, y: py, z, t, junk: Math.max(c.canaryJunk, c.openJunk) };
}

function color(t: number, junk: number): string {
  if (junk > 0.01) return "#dc2626";
  const a = [37, 99, 235], b = [8, 145, 178];
  const v = a.map((n, i) => Math.round(n + (b[i]! - n) * t));
  return `rgb(${v[0]},${v[1]},${v[2]})`;
}

const byKey = new Map(cells.map((c) => [`${c.midY}/${c.shoulderY}`, c]));
let svg = `<svg viewBox="0 0 980 560" xmlns="http://www.w3.org/2000/svg" role="img" aria-labelledby="t d" font-family="ui-sans-serif,system-ui,sans-serif">
<title id="t">Curve terrain map</title>
<desc id="d">First-pass terrain of custom log-prob curves. X is mid y at one percent, Y is shoulder y at nine percent, Z is rough diversity delta after junk penalty.</desc>
<rect width="980" height="560" fill="#f7f9fc"/>
<text x="38" y="42" font-size="22" font-weight="700" fill="#172033">Curve Terrain Map</text>
<text x="38" y="65" font-size="12.5" fill="#667085">${data.model} · N=${data.n} · seed=${data.seed} · default diversity ${data.default.diversity.toFixed(3)} · score = diversity delta minus junk penalty</text>
<g transform="translate(250 50)">`;

for (const sy of data.axes.shoulderY) {
  let d = "";
  for (const mx of data.axes.midY) {
    const c = byKey.get(`${mx}/${sy}`);
    if (!c) continue;
    const p = project(c as Required<Cell>);
    d += `${d ? "L" : "M"}${p.x.toFixed(1)} ${p.y.toFixed(1)} `;
  }
  svg += `<path d="${d}" fill="none" stroke="#cbd5e1" stroke-width="1"/>`;
}
for (const mx of data.axes.midY) {
  let d = "";
  for (const sy of data.axes.shoulderY) {
    const c = byKey.get(`${mx}/${sy}`);
    if (!c) continue;
    const p = project(c as Required<Cell>);
    d += `${d ? "L" : "M"}${p.x.toFixed(1)} ${p.y.toFixed(1)} `;
  }
  svg += `<path d="${d}" fill="none" stroke="#cbd5e1" stroke-width="1"/>`;
}

for (const c of [...cells].sort((a, b) => project(a).y - project(b).y)) {
  const p = project(c);
  svg += `<circle cx="${p.x.toFixed(1)}" cy="${p.y.toFixed(1)}" r="${(5 + p.t * 4).toFixed(1)}" fill="${color(p.t, p.junk)}" stroke="white" stroke-width="2">
  <title>mid=${c.midY}, shoulder=${c.shoulderY}, diversity=${c.diversity.toFixed(3)}, score=${c.score.toFixed(3)}, junk=${(p.junk * 100).toFixed(1)}%</title></circle>`;
}

const best = [...cells].sort((a, b) => b.score - a.score).slice(0, 5);
svg += `</g>
<g transform="translate(38 420)">
<text x="0" y="0" font-size="14" font-weight="700" fill="#172033">Highest first-pass cells</text>`;
best.forEach((c, i) => {
  svg += `<text x="0" y="${24 + i * 22}" font-size="12.5" fill="#344054">${i + 1}. mid ${c.midY}, shoulder ${c.shoulderY} · diversity ${c.diversity.toFixed(3)} · score ${c.score.toFixed(3)} · junk ${(Math.max(c.canaryJunk, c.openJunk) * 100).toFixed(1)}%</text>`;
});
svg += `</g>
<g transform="translate(742 420)">
<rect x="0" y="-18" width="170" height="12" fill="url(#grad)"/>
<defs><linearGradient id="grad"><stop offset="0" stop-color="#2563eb"/><stop offset="1" stop-color="#0891b2"/></linearGradient></defs>
<text x="0" y="10" font-size="11.5" fill="#667085">low score</text>
<text x="112" y="10" font-size="11.5" fill="#667085">high score</text>
<text x="0" y="34" font-size="11.5" fill="#667085">red points would indicate junk penalty</text>
</g>
<text x="526" y="528" text-anchor="middle" font-size="12" fill="#667085">x: mid y@1% · y: shoulder y@9% · z: rough terrain score</text>
</svg>`;

writeFileSync(out, svg);
console.log(out);
