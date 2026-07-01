// Server-driven terrain mapper for the HLG Curve Designer.
//
// This is intentionally a first-pass cartography tool, not a verdict machine:
// it sweeps a small 2-D family of monotone log-prob curves through the already
// running /generate endpoint, scores cheap coherence/diversity metrics, and
// writes a self-contained HTML terrain viewer.
//
//   bun scripts/curve-terrain.ts [--base http://localhost:8080] [--n 2]

import { mkdirSync, writeFileSync } from "node:fs";

function opt(name: string, dflt: string): string {
  const i = process.argv.indexOf(`--${name}`);
  return i >= 0 && i + 1 < process.argv.length ? process.argv[i + 1]! : dflt;
}

const BASE_URL = opt("base", "http://localhost:8080").replace(/\/$/, "");
const N = Math.max(1, Math.min(5, Number(opt("n", "2")) || 2));
const SEED = Number(opt("seed", "7300")) || 7300;
const MAX_TOKENS = Math.max(12, Math.min(90, Number(opt("max-tokens", "48")) || 48));

const CANARY = "In one sentence, what causes the seasons on Earth?";
const OPEN = [
  "Write the first sentence of a short story about a lighthouse keeper who discovers something strange in the fog.",
  "Complete this thought in a vivid, original way: 'The strangest thing about human memory is'",
];

// Axes: keep endpoints and the 0.1% tail fixed. Move the 1% "mids" point and
// the 9% "upper/head shoulder" point. Invalid cells are skipped if y is not
// monotone. This deliberately explores the region the hand-drawn tool makes
// tactile: lift/flatten the plausible band without directly lifting the tail.
const MID_Y = [0.5, 1, 2, 4, 8];
const SHOULDER_Y = [6, 10, 16, 28, 50];

type Curve = {
  space: "logprob";
  points: { x_pct: number; y_pct: number }[];
  monotonic: true;
};

type Sample = { text: string; junk?: boolean };
type GenResponse = {
  mode: string;
  recipe?: { temperature: number; topP: number; topK: number };
  seed: number;
  samples: Sample[];
};

type Cell = {
  midY: number;
  shoulderY: number;
  valid: boolean;
  curve?: Curve;
  canaryJunk?: number;
  openJunk?: number;
  diversity?: number;
  distinct2?: number;
  meanLen?: number;
  score?: number;
  samples?: Record<string, string[]>;
  error?: string;
};

function curve(midY: number, shoulderY: number): Curve | null {
  if (midY <= 0.1 * 1.03 || shoulderY <= midY * 1.03 || shoulderY >= 100 * 0.97) return null;
  return {
    space: "logprob",
    points: [
      { x_pct: 0.0001, y_pct: 0.0001 },
      { x_pct: 0.1, y_pct: 0.1 },
      { x_pct: 1, y_pct: midY },
      { x_pct: 9, y_pct: shoulderY },
      { x_pct: 100, y_pct: 100 },
    ],
    monotonic: true,
  };
}

async function postGenerate(body: unknown): Promise<GenResponse> {
  const r = await fetch(`${BASE_URL}/generate`, {
    method: "POST",
    headers: { "content-type": "application/json" },
    body: JSON.stringify(body),
  });
  const j = await r.json() as GenResponse & { error?: string };
  if (!r.ok) throw new Error(j.error || `HTTP ${r.status}`);
  return j;
}

function letters(s: string): string[] {
  return s.match(/\p{L}/gu) ?? [];
}

function junkRatio(s: string): number {
  const l = letters(s);
  if (!l.length) return 0;
  return l.filter((c) => !/\p{Script=Latin}/u.test(c)).length / l.length;
}

function words(s: string): string[] {
  return s.toLowerCase().match(/[a-z0-9']+/g) ?? [];
}

function divergentTokens(samples: string[]): string[][] {
  const toks = samples.map(words);
  if (toks.length < 2) return toks;
  const minLen = Math.min(...toks.map((t) => t.length));
  let p = 0;
  while (p < minLen && toks.every((t) => t[p] === toks[0]![p])) p++;
  return toks.map((t) => t.slice(p));
}

function countGrams(toks: string[], n: number): Map<string, number> {
  const m = new Map<string, number>();
  for (let i = 0; i + n <= toks.length; i++) {
    const k = toks.slice(i, i + n).join(" ");
    m.set(k, (m.get(k) ?? 0) + 1);
  }
  return m;
}

function bleu4(cand: string[], refs: string[][]): number {
  if (!cand.length) return 0;
  let logSum = 0;
  for (let n = 1; n <= 4; n++) {
    const cg = countGrams(cand, n);
    const refMax = new Map<string, number>();
    for (const r of refs)
      for (const [k, v] of countGrams(r, n))
        refMax.set(k, Math.max(refMax.get(k) ?? 0, v));
    let clipped = 0, total = 0;
    for (const [k, v] of cg) {
      clipped += Math.min(v, refMax.get(k) ?? 0);
      total += v;
    }
    logSum += 0.25 * Math.log((clipped + 1e-9) / (total + 1e-9));
  }
  const closest = refs
    .map((r) => r.length)
    .reduce((a, b) => (Math.abs(b - cand.length) < Math.abs(a - cand.length) ? b : a), cand.length);
  const bp = cand.length > closest ? 1 : Math.exp(1 - closest / Math.max(cand.length, 1));
  return bp * Math.exp(logSum);
}

function selfBleu(toks: string[][]): number {
  if (toks.length < 2) return 1;
  let s = 0;
  for (let i = 0; i < toks.length; i++) s += bleu4(toks[i]!, toks.filter((_, j) => j !== i));
  return s / toks.length;
}

function distinct2(toks: string[][]): number {
  const seen = new Set<string>();
  let total = 0;
  for (const t of toks) {
    for (let i = 0; i + 1 < t.length; i++) {
      seen.add(`${t[i]} ${t[i + 1]}`);
      total++;
    }
  }
  return total ? seen.size / total : 0;
}

function metric(samplesByPrompt: Record<string, string[]>): Omit<Cell, "midY" | "shoulderY" | "valid"> {
  let diversity = 0, d2 = 0, junk = 0, len = 0, groups = 0;
  for (const samples of Object.values(samplesByPrompt)) {
    const toks = divergentTokens(samples);
    diversity += 1 - selfBleu(toks);
    d2 += distinct2(toks);
    junk += samples.reduce((a, s) => a + junkRatio(s), 0) / samples.length;
    len += samples.reduce((a, s) => a + words(s).length, 0) / samples.length;
    groups++;
  }
  return {
    diversity: groups ? diversity / groups : 0,
    distinct2: groups ? d2 / groups : 0,
    openJunk: groups ? junk / groups : 0,
    meanLen: groups ? len / groups : 0,
  };
}

function terrainScore(cell: Cell, ref: { diversity: number; openJunk: number }): number | undefined {
  if (cell.diversity === undefined || cell.openJunk === undefined || cell.canaryJunk === undefined) return undefined;
  const junkPenalty = Math.max(cell.openJunk, cell.canaryJunk) * 8;
  // Positive means "more lexical spread than default, after a harsh junk penalty".
  return cell.diversity - ref.diversity - junkPenalty;
}

async function measureDefault(): Promise<{ response: GenResponse; diversity: number; openJunk: number; samples: Record<string, string[]> }> {
  const samples: Record<string, string[]> = {};
  let first: GenResponse | null = null;
  for (let pi = 0; pi < OPEN.length; pi++) {
    const r = await postGenerate({ prompt: OPEN[pi], default: true, n: N, max_tokens: MAX_TOKENS, seed: SEED + pi * 100 });
    first ??= r;
    samples[OPEN[pi]!] = r.samples.map((s) => s.text);
  }
  const m = metric(samples);
  return { response: first!, diversity: m.diversity ?? 0, openJunk: m.openJunk ?? 0, samples };
}

function htmlArtifact(data: unknown): string {
  return `<!doctype html>
<html lang="en"><head><meta charset="utf-8">
<meta name="viewport" content="width=device-width,initial-scale=1">
<title>Curve Terrain Map</title>
<style>
:root{--bg:#f7f9fc;--ink:#172033;--muted:#667085;--panel:#fff;--line:#d8e0eb;--blue:#2563eb;--cyan:#0891b2;--bad:#dc2626;--good:#16a34a}
body{margin:0;background:var(--bg);color:var(--ink);font:13px/1.5 -apple-system,BlinkMacSystemFont,"Segoe UI",ui-sans-serif,system-ui,sans-serif}
.wrap{max-width:1260px;margin:0 auto;padding:22px 22px 44px}
h1{font-size:21px;margin:0 0 4px}.sub{color:var(--muted);margin:0 0 18px}
.grid{display:grid;grid-template-columns:minmax(620px,1.1fr) minmax(340px,.9fr);gap:16px}.panel{background:var(--panel);border:1px solid var(--line);border-radius:10px;padding:14px;box-shadow:0 10px 28px -26px rgba(15,23,42,.35)}
canvas{width:100%;height:620px;display:block;border-radius:8px;background:linear-gradient(#fff,#f5f8fc);cursor:grab}.row{display:flex;gap:14px;flex-wrap:wrap;margin-top:10px;color:var(--muted)}.row b{color:var(--ink)}
table{width:100%;border-collapse:collapse;font-size:12px}td,th{border-bottom:1px solid var(--line);padding:6px;text-align:right}th:first-child,td:first-child{text-align:left}
.pill{display:inline-block;padding:2px 7px;border-radius:999px;background:#eef5ff;color:#1d4ed8;font-weight:700;font-size:11px}.bad{color:var(--bad);font-weight:700}.good{color:var(--good);font-weight:700}
pre{white-space:pre-wrap;background:#f3f6fa;border:1px solid var(--line);border-radius:8px;padding:10px;max-height:260px;overflow:auto}
@media(max-width:980px){.grid{grid-template-columns:1fr}canvas{height:480px}}
</style></head><body><div class="wrap">
<h1>Curve Terrain Map</h1>
<p class="sub">First-pass cartography of a two-point monotone curve family. Drag the canvas to rotate; click a point to inspect samples.</p>
<div class="grid">
  <div class="panel"><canvas id="terrain" width="980" height="680"></canvas><div class="row" id="legend"></div></div>
  <div class="panel">
    <div id="summary"></div>
    <h3>Selected Cell</h3>
    <div id="cell">Click a point on the terrain.</div>
    <h3>Rows</h3>
    <div id="rows"></div>
  </div>
</div>
</div><script>
const DATA=${JSON.stringify(data)};
const canvas=document.getElementById('terrain'),ctx=canvas.getContext('2d');
let yaw=-0.75,pitch=0.72,drag=null,selected=null;
const cells=DATA.cells.filter(c=>c.valid&&c.score!==undefined);
const xs=DATA.axes.midY,ys=DATA.axes.shoulderY;
const minScore=Math.min(...cells.map(c=>c.score)),maxScore=Math.max(...cells.map(c=>c.score));
function norm(v,a,b){return (v-a)/(b-a||1)}
function color(t,j){ if(j>.01)return '#dc2626'; const r=Math.round(37+(8-37)*t),g=Math.round(99+(145-99)*t),b=Math.round(235+(178-235)*t); return \`rgb(\${r},\${g},\${b})\`; }
function project(x,y,z){ const sx=(x-.5)*6, sy=(y-.5)*6, sz=z*4; const cy=Math.cos(yaw),syw=Math.sin(yaw),cp=Math.cos(pitch),sp=Math.sin(pitch); let X=sx*cy-sy*syw, Y=sx*syw+sy*cy, Z=sz; let Y2=Y*cp-Z*sp, Z2=Y*sp+Z*cp; const scale=72/(1+Z2*.04); return {x:canvas.width/2+X*scale,y:canvas.height/2+90+Y2*scale,scale}; }
function draw(){
 ctx.clearRect(0,0,canvas.width,canvas.height);
 ctx.font='12px system-ui'; ctx.fillStyle='#667085'; ctx.fillText('x: y@1% (mid lift)   y: y@9% (shoulder/head)   z: diversity delta vs default minus junk penalty',24,28);
 const pts=[];
 for(const c of cells){ const x=norm(Math.log(c.midY),Math.log(Math.min(...xs)),Math.log(Math.max(...xs))); const y=norm(Math.log(c.shoulderY),Math.log(Math.min(...ys)),Math.log(Math.max(...ys))); const z=norm(c.score,minScore,maxScore)-.5; const p=project(x,y,z); pts.push({c,p}); }
 pts.sort((a,b)=>a.p.scale-b.p.scale);
 ctx.strokeStyle='rgba(102,112,133,.18)'; ctx.lineWidth=1;
 for(const y of ys){ ctx.beginPath(); let first=true; for(const x of xs){ const c=cells.find(q=>q.midY===x&&q.shoulderY===y); if(!c)continue; const p=pts.find(q=>q.c===c).p; if(first){ctx.moveTo(p.x,p.y);first=false}else ctx.lineTo(p.x,p.y);} ctx.stroke(); }
 for(const x of xs){ ctx.beginPath(); let first=true; for(const y of ys){ const c=cells.find(q=>q.midY===x&&q.shoulderY===y); if(!c)continue; const p=pts.find(q=>q.c===c).p; if(first){ctx.moveTo(p.x,p.y);first=false}else ctx.lineTo(p.x,p.y);} ctx.stroke(); }
 for(const {c,p} of pts){ const t=norm(c.score,minScore,maxScore); ctx.beginPath(); ctx.fillStyle=color(t,Math.max(c.canaryJunk||0,c.openJunk||0)); ctx.arc(p.x,p.y,selected===c?8:5.5,0,Math.PI*2); ctx.fill(); ctx.strokeStyle=selected===c?'#172033':'#fff'; ctx.lineWidth=selected===c?2:1.5; ctx.stroke(); c._screen=p; }
}
function render(){
 document.getElementById('legend').innerHTML=\`<span><b>Default diversity</b> \${DATA.default.diversity.toFixed(3)}</span><span><b>Best score</b> \${maxScore.toFixed(3)}</span><span><b>Worst score</b> \${minScore.toFixed(3)}</span><span><span class="pill">blue/cyan</span> higher terrain score</span><span class="bad">red = junk penalty</span>\`;
 document.getElementById('summary').innerHTML=\`<p><b>Server:</b> \${DATA.baseUrl}<br><b>N:</b> \${DATA.n}, <b>seed:</b> \${DATA.seed}, <b>max tokens:</b> \${DATA.maxTokens}</p><p><b>Default recipe:</b> T=\${DATA.default.recipe.temperature} top-p=\${DATA.default.recipe.topP} top-k=\${DATA.default.recipe.topK}</p>\`;
 const sorted=[...cells].sort((a,b)=>b.score-a.score);
 document.getElementById('rows').innerHTML='<table><tr><th>cell</th><th>score</th><th>div</th><th>junk</th></tr>'+sorted.map(c=>\`<tr><td>mid \${c.midY}, shoulder \${c.shoulderY}</td><td>\${c.score.toFixed(3)}</td><td>\${c.diversity.toFixed(3)}</td><td>\${(Math.max(c.openJunk,c.canaryJunk)*100).toFixed(1)}%</td></tr>\`).join('')+'</table>';
 draw();
}
function show(c){selected=c; const samples=c.samples||{}; document.getElementById('cell').innerHTML=\`<p><b>mid y@1%</b> \${c.midY}<br><b>shoulder y@9%</b> \${c.shoulderY}<br><b>score</b> \${c.score.toFixed(3)}<br><b>diversity</b> \${c.diversity.toFixed(3)} · <b>distinct2</b> \${c.distinct2.toFixed(3)}<br><b>canary junk</b> \${(c.canaryJunk*100).toFixed(1)}% · <b>open junk</b> \${(c.openJunk*100).toFixed(1)}%</p><pre>\${Object.entries(samples).map(([p,ss])=>p+'\\n'+ss.map((s,i)=>(i+1)+'. '+s).join('\\n')).join('\\n\\n')}</pre>\`; draw(); }
canvas.addEventListener('pointerdown',e=>{drag={x:e.clientX,y:e.clientY,yaw,pitch,moved:false}});
canvas.addEventListener('pointermove',e=>{if(!drag)return; const dx=e.clientX-drag.x,dy=e.clientY-drag.y; if(Math.abs(dx)+Math.abs(dy)>3)drag.moved=true; yaw=drag.yaw+dx*.008; pitch=Math.max(.15,Math.min(1.25,drag.pitch+dy*.006)); draw();});
canvas.addEventListener('pointerup',e=>{ if(drag&&!drag.moved){ const r=canvas.getBoundingClientRect(),x=(e.clientX-r.left)*canvas.width/r.width,y=(e.clientY-r.top)*canvas.height/r.height; let best=null,bd=1e9; for(const c of cells){const p=c._screen;if(!p)continue;const d=(p.x-x)**2+(p.y-y)**2;if(d<bd){bd=d;best=c}} if(best&&bd<400)show(best); } drag=null; });
render(); if(cells.length)show([...cells].sort((a,b)=>b.score-a.score)[0]);
</script></body></html>`;
}

async function main(): Promise<void> {
  console.log(`# Curve terrain — ${BASE_URL}, N=${N}, seed=${SEED}, maxTokens=${MAX_TOKENS}`);
  const v1 = await fetch(`${BASE_URL}/v1`).then((r) => r.json() as Promise<{ model?: string }>);
  console.log(`# model: ${v1.model ?? "unknown"}`);

  const def = await measureDefault();
  console.log(`# default: diversity ${def.diversity.toFixed(3)} junk ${(def.openJunk * 100).toFixed(1)}% recipe ${JSON.stringify(def.response.recipe)}`);

  const cells: Cell[] = [];
  for (const shoulderY of SHOULDER_Y) {
    for (const midY of MID_Y) {
      const c = curve(midY, shoulderY);
      const cell: Cell = { midY, shoulderY, valid: !!c, curve: c ?? undefined };
      cells.push(cell);
      if (!c) {
        console.log(`skip mid=${midY} shoulder=${shoulderY} (non-monotone)`);
        continue;
      }
      try {
        const can = await postGenerate({ prompt: CANARY, curve: c, n: 1, max_tokens: 28, seed: SEED + 17 });
        cell.canaryJunk = junkRatio(can.samples[0]?.text ?? "");
        const samples: Record<string, string[]> = {};
        for (let pi = 0; pi < OPEN.length; pi++) {
          const r = await postGenerate({ prompt: OPEN[pi], curve: c, n: N, max_tokens: MAX_TOKENS, seed: SEED + pi * 100 });
          samples[OPEN[pi]!] = r.samples.map((s) => s.text);
        }
        Object.assign(cell, metric(samples));
        cell.samples = samples;
        cell.score = terrainScore(cell, def);
        console.log(`cell mid=${String(midY).padStart(4)} shoulder=${String(shoulderY).padStart(4)} div=${cell.diversity?.toFixed(3)} junk=${(Math.max(cell.openJunk ?? 0, cell.canaryJunk ?? 0) * 100).toFixed(1)}% score=${cell.score?.toFixed(3)}`);
      } catch (e) {
        cell.error = (e as Error).message;
        console.log(`cell mid=${midY} shoulder=${shoulderY} ERROR ${cell.error}`);
      }
    }
  }

  const outDir = `${process.cwd()}/docs/investigations/curve-runs`;
  mkdirSync(outDir, { recursive: true });
  const data = {
    kind: "curve-terrain-v1",
    createdAt: new Date().toISOString(),
    baseUrl: BASE_URL,
    model: v1.model ?? null,
    n: N,
    seed: SEED,
    maxTokens: MAX_TOKENS,
    axes: { midY: MID_Y, shoulderY: SHOULDER_Y },
    default: { diversity: def.diversity, openJunk: def.openJunk, recipe: def.response.recipe, samples: def.samples },
    cells,
  };
  const jsonPath = `${outDir}/curve-terrain.json`;
  const htmlPath = `${process.cwd()}/docs/investigations/curve-terrain.html`;
  writeFileSync(jsonPath, JSON.stringify(data, null, 2));
  writeFileSync(htmlPath, htmlArtifact(data));
  console.log(`# wrote ${jsonPath}`);
  console.log(`# wrote ${htmlPath}`);
}

await main();
