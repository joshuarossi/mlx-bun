import type {
  Glm52AtlasAnalysis,
  Glm52AtlasValidation,
} from "../../src/model/glm52-atlas";

export interface Glm52AtlasHtmlInput {
  readonly title: string;
  readonly analysis: Glm52AtlasAnalysis;
  readonly validation: Glm52AtlasValidation;
  readonly provenance: {
    readonly model: string;
    readonly probeSource: string;
    readonly probeSourceCommit: string;
    readonly generatedAt: string;
  };
}

function escaped(value: string): string {
  return value.replaceAll("&", "&amp;")
    .replaceAll("<", "&lt;")
    .replaceAll(">", "&gt;")
    .replaceAll('"', "&quot;");
}

function scriptJson(value: unknown): string {
  return JSON.stringify(value)
    .replaceAll("<", "\\u003c")
    .replaceAll("\u2028", "\\u2028")
    .replaceAll("\u2029", "\\u2029");
}

/** Self-contained, canvas-based Atlas viewer suitable for a run artifact. */
export function renderGlm52AtlasHtml(input: Glm52AtlasHtmlInput): string {
  const { analysis, validation, provenance } = input;
  const categoryIndex = new Map(
    analysis.categories.map((category, index) => [category, index]),
  );
  const experts = analysis.experts.map((expert) => [
    expert.layer,
    expert.expert,
    expert.specialization,
    categoryIndex.get(expert.topTopic),
    expert.total,
    expert.reliability.firedRuns,
    expert.reliability.totalRuns,
    analysis.categories.map((category) => expert.affinity[category] ?? 0),
  ]);
  const payload = scriptJson({
    categories: analysis.categories,
    experts,
    strongThreshold: analysis.method.strongThreshold,
  });
  const accuracy = (validation.accuracy * 100).toFixed(1);
  const chance = (validation.chance * 100).toFixed(1);
  const strongRate = (analysis.summary.strongSpecialistRate * 100).toFixed(1);
  return `<!doctype html>
<html lang="en">
<head>
<meta charset="utf-8">
<meta name="viewport" content="width=device-width,initial-scale=1">
<title>${escaped(input.title)}</title>
<style>
:root{color-scheme:dark;--bg:#070b0d;--panel:#0b1114;--line:#223038;--text:#e7eef2;--muted:#8b9aa3;--accent:#55d6ad}
*{box-sizing:border-box}body{margin:0;background:var(--bg);color:var(--text);font:14px/1.45 ui-monospace,SFMono-Regular,Menlo,Consolas,monospace}
main{min-height:100vh;display:grid;grid-template-rows:auto minmax(560px,1fr) auto;gap:14px;padding:22px}
header{display:flex;align-items:flex-end;justify-content:space-between;gap:24px;flex-wrap:wrap}
h1{font-size:18px;letter-spacing:.12em;text-transform:uppercase;margin:0 0 4px}.sub{color:var(--muted)}
.metrics{display:flex;gap:22px;flex-wrap:wrap}.metric b{display:block;font-size:18px;color:var(--text)}.metric span{font-size:11px;color:var(--muted);text-transform:uppercase;letter-spacing:.08em}
#atlas-wrap{position:relative;min-height:560px;border:1px solid var(--line);background:radial-gradient(circle at 50% 50%,#10191d 0,#080d0f 48%,#06090b 78%);overflow:hidden}
canvas{width:100%;height:100%;display:block;cursor:crosshair}.legend{position:absolute;left:18px;top:16px;display:flex;gap:8px 14px;flex-wrap:wrap;max-width:min(760px,75%);pointer-events:none}
.legend span{color:var(--muted);font-size:11px;white-space:nowrap}.legend i{display:inline-block;width:8px;height:8px;border-radius:50%;margin-right:6px}
#tip{position:fixed;z-index:3;display:none;max-width:310px;padding:10px 12px;border:1px solid var(--line);background:#10171beF;box-shadow:0 12px 30px #0008;pointer-events:none}
#tip strong{color:var(--accent)}#tip .aff{margin-top:5px;color:var(--muted);font-size:11px}
footer{display:flex;justify-content:space-between;gap:18px;flex-wrap:wrap;color:var(--muted);font-size:11px;border-top:1px solid var(--line);padding-top:12px}
.sr{position:absolute;width:1px;height:1px;padding:0;margin:-1px;overflow:hidden;clip:rect(0,0,0,0);white-space:nowrap;border:0}
@media(max-width:700px){main{padding:12px;grid-template-rows:auto minmax(480px,1fr) auto}.metrics{gap:12px}.metric b{font-size:15px}#atlas-wrap{min-height:480px}.legend{max-width:90%}}
</style>
</head>
<body>
<main>
<header>
  <div><h1>${escaped(input.title)}</h1><div class="sub">position = measured topic affinity · radius/opacity = specialization · hover for evidence</div></div>
  <div class="metrics">
    <div class="metric"><b>${analysis.summary.expertsKept.toLocaleString()}</b><span>replicated experts</span></div>
    <div class="metric"><b>${analysis.summary.strongSpecialists.toLocaleString()} (${strongRate}%)</b><span>strong specialists</span></div>
    <div class="metric"><b>${validation.hits}/${validation.trials} (${accuracy}%)</b><span>held-out accuracy · chance ${chance}%</span></div>
  </div>
</header>
<section id="atlas-wrap" aria-label="Expert topic-affinity atlas">
  <div class="legend" id="legend"></div>
  <canvas id="atlas"></canvas>
  <p class="sr">${analysis.summary.expertsKept.toLocaleString()} replicated experts across ${analysis.categories.length} topics. Leave-one-prompt-out accuracy is ${accuracy} percent.</p>
</section>
<div id="tip" role="tooltip"></div>
<footer>
  <span>normalization: mean per-run selection share · replication ≥${analysis.method.minRuns} prompts · min ${analysis.method.minCount} selections · strong ≥${analysis.method.strongThreshold.toFixed(2)}</span>
  <span>model: ${escaped(provenance.model)} · probes: ${escaped(provenance.probeSource)} @ ${escaped(provenance.probeSourceCommit.slice(0, 12))} · ${escaped(provenance.generatedAt)}</span>
</footer>
</main>
<script>
const DATA=${payload};
const COLORS=["#63a8ff","#f07178","#e7a15a","#b392f0","#55d6ad","#d46bb3","#ffd166","#7ed6df","#9aa8ff","#b7c4ca","#f78c6c","#82aaff"];
const canvas=document.getElementById("atlas"),wrap=document.getElementById("atlas-wrap"),tip=document.getElementById("tip"),legend=document.getElementById("legend");
const ctx=canvas.getContext("2d");let points=[],raf=0;
DATA.categories.forEach((name,i)=>{const s=document.createElement("span"),dot=document.createElement("i");dot.style.background=COLORS[i%COLORS.length];s.append(dot,document.createTextNode(name));legend.appendChild(s)});
function hash(layer,expert){let h=((layer+1)*2654435761^(expert+11)*1597334677)>>>0;h^=h>>>16;return h>>>0}
function layout(){
  const dpr=Math.min(devicePixelRatio||1,2),w=wrap.clientWidth,h=wrap.clientHeight;canvas.width=Math.round(w*dpr);canvas.height=Math.round(h*dpr);ctx.setTransform(dpr,0,0,dpr,0,0);ctx.clearRect(0,0,w,h);
  const cx=w/2,cy=h/2+16,R=Math.max(120,Math.min(w,h)*.39),anchors=DATA.categories.map((_,i)=>{const a=-Math.PI/2+2*Math.PI*i/DATA.categories.length;return [Math.cos(a),Math.sin(a)]});
  ctx.strokeStyle="#26343b";ctx.lineWidth=1;[.33,.66,1].forEach(q=>{ctx.beginPath();ctx.arc(cx,cy,R*q,0,Math.PI*2);ctx.stroke()});
  anchors.forEach((a,i)=>{const x=cx+a[0]*R*1.09,y=cy+a[1]*R*1.09;ctx.fillStyle=COLORS[i%COLORS.length];ctx.font="600 12px ui-monospace,SFMono-Regular,Menlo,monospace";ctx.textAlign=a[0]<-.2?"right":a[0]>.2?"left":"center";ctx.textBaseline=a[1]<-.2?"bottom":a[1]>.2?"top":"middle";ctx.fillText(DATA.categories[i],x,y)});
  points=DATA.experts.map(e=>{let vx=0,vy=0;e[7].forEach((p,i)=>{vx+=p*anchors[i][0];vy+=p*anchors[i][1]});const n=hash(e[0],e[1]),j=(1-e[2])*.055*R,ja=(n%6283)/1000,jr=(((n>>>12)%1000)/1000)*j;return{e,x:cx+vx*R*.93+Math.cos(ja)*jr,y:cy+vy*R*.93+Math.sin(ja)*jr}});
  points.slice().sort((a,b)=>a.e[2]-b.e[2]).forEach(p=>{const spec=p.e[2],strong=spec>=DATA.strongThreshold,r=strong?1.8+2.4*spec:.55+1.1*spec;ctx.globalAlpha=strong?.55+.4*spec:.10+.30*spec;ctx.fillStyle=COLORS[p.e[3]%COLORS.length];ctx.beginPath();ctx.arc(p.x,p.y,r,0,Math.PI*2);ctx.fill()});ctx.globalAlpha=1;
}
function move(ev){cancelAnimationFrame(raf);raf=requestAnimationFrame(()=>{const rect=canvas.getBoundingClientRect(),x=ev.clientX-rect.left,y=ev.clientY-rect.top;let best=null,d2=144;for(const p of points){const dx=p.x-x,dy=p.y-y,v=dx*dx+dy*dy;if(v<d2){best=p;d2=v}}if(!best){tip.style.display="none";return}const e=best.e,aff=e[7].map((p,i)=>[DATA.categories[i],p]).sort((a,b)=>b[1]-a[1]).slice(0,3).map(v=>v[0]+" "+Math.round(v[1]*100)+"%").join(" · ");tip.innerHTML="<strong>layer "+e[0]+" · expert "+e[1]+"</strong><br>"+(e[2]>=DATA.strongThreshold?"specialist: "+DATA.categories[e[3]]:"generalist")+" · spec "+e[2].toFixed(3)+"<br>"+e[4].toLocaleString()+" selections · replication "+e[5]+"/"+e[6]+"<div class='aff'>"+aff+"</div>";tip.style.display="block";tip.style.left=Math.min(ev.clientX+14,innerWidth-330)+"px";tip.style.top=Math.min(ev.clientY+14,innerHeight-120)+"px"})}
canvas.addEventListener("pointermove",move);canvas.addEventListener("pointerleave",()=>tip.style.display="none");new ResizeObserver(layout).observe(wrap);layout();
</script>
</body>
</html>
`;
}
