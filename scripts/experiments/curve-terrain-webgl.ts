// Build a native WebGL terrain viewer from curve-runs/curve-terrain.json.
//
// This does not call the model. It turns the existing terrain run into a
// browser artifact with a real WebGL mesh, orbit controls, point picking, and a
// side panel for samples.

import { readFileSync, writeFileSync } from "node:fs";

const jsonPath = `${process.cwd()}/docs/investigations/curve-runs/curve-terrain.json`;
const htmlPath = `${process.cwd()}/docs/investigations/curve-terrain.html`;
const data = JSON.parse(readFileSync(jsonPath, "utf8"));

const html = `<!doctype html>
<html lang="en"><head><meta charset="utf-8">
<meta name="viewport" content="width=device-width,initial-scale=1">
<title>Curve Terrain Map</title>
<style>
:root{--bg:#f7f9fc;--ink:#172033;--muted:#667085;--panel:#fff;--line:#d8e0eb;--blue:#2563eb;--cyan:#0891b2;--bad:#dc2626;--good:#16a34a}
*{box-sizing:border-box}
body{margin:0;background:var(--bg);color:var(--ink);font:13px/1.5 -apple-system,BlinkMacSystemFont,"Segoe UI",ui-sans-serif,system-ui,sans-serif}
.wrap{max-width:1280px;margin:0 auto;padding:22px 22px 44px}
h1{font-size:21px;margin:0 0 4px}.sub{color:var(--muted);margin:0 0 18px}
.grid{display:grid;grid-template-columns:minmax(640px,1.15fr) minmax(340px,.85fr);gap:16px}
.panel{background:var(--panel);border:1px solid var(--line);border-radius:10px;padding:14px;box-shadow:0 10px 28px -26px rgba(15,23,42,.35)}
#gl{width:100%;height:650px;display:block;border-radius:8px;background:#f8fafc;cursor:grab}
#gl:active{cursor:grabbing}.row{display:flex;gap:14px;flex-wrap:wrap;margin-top:10px;color:var(--muted)}.row b{color:var(--ink)}
button{border:1px solid var(--line);background:#fff;border-radius:8px;padding:6px 10px;font:600 12px inherit;cursor:pointer;color:var(--ink)}
table{width:100%;border-collapse:collapse;font-size:12px}td,th{border-bottom:1px solid var(--line);padding:6px;text-align:right}th:first-child,td:first-child{text-align:left}
.pill{display:inline-block;padding:2px 7px;border-radius:999px;background:#eef5ff;color:#1d4ed8;font-weight:700;font-size:11px}.bad{color:var(--bad);font-weight:700}.good{color:var(--good);font-weight:700}
pre{white-space:pre-wrap;background:#f3f6fa;border:1px solid var(--line);border-radius:8px;padding:10px;max-height:300px;overflow:auto}
.hint{font-size:12px;color:var(--muted);margin-top:8px}
@media(max-width:980px){.grid{grid-template-columns:1fr}#gl{height:500px}}
</style></head><body><div class="wrap">
<h1>Curve Terrain Map</h1>
<p class="sub">Native WebGL terrain from the first custom-curve sweep. Drag to orbit, wheel to zoom, click a point to inspect samples.</p>
<div class="grid">
  <div class="panel">
    <canvas id="gl"></canvas>
    <div class="row" id="legend"></div>
    <div class="hint">Axes: x = mid y@1%, y = shoulder y@9%, z = diversity delta vs default minus junk penalty.</div>
  </div>
  <div class="panel">
    <div id="summary"></div>
    <h3>Selected Cell</h3>
    <div id="cell">Click a point on the terrain.</div>
    <h3>Cells</h3>
    <div id="rows"></div>
  </div>
</div>
</div>
<script>
const DATA=${JSON.stringify(data)};
const canvas=document.getElementById("gl");
const gl=canvas.getContext("webgl",{antialias:true,alpha:false});
if(!gl) throw new Error("WebGL unavailable");

const cells=DATA.cells.filter(c=>c.valid&&Number.isFinite(c.score));
const xs=DATA.axes.midY, ys=DATA.axes.shoulderY;
const minScore=Math.min(...cells.map(c=>c.score)), maxScore=Math.max(...cells.map(c=>c.score));
const maxJunk=Math.max(...cells.map(c=>Math.max(c.openJunk||0,c.canaryJunk||0)),0.0001);
const key=(x,y)=>x+"/"+y;
const byKey=new Map(cells.map(c=>[key(c.midY,c.shoulderY),c]));
let selected=[...cells].sort((a,b)=>b.score-a.score)[0]||null;
let yaw=-0.72,pitch=0.72,dist=7.2,drag=null;
let projection=[], pointScreen=[];

function shader(type,src){const s=gl.createShader(type);gl.shaderSource(s,src);gl.compileShader(s);if(!gl.getShaderParameter(s,gl.COMPILE_STATUS))throw new Error(gl.getShaderInfoLog(s));return s}
function program(vs,fs){const p=gl.createProgram();gl.attachShader(p,shader(gl.VERTEX_SHADER,vs));gl.attachShader(p,shader(gl.FRAGMENT_SHADER,fs));gl.linkProgram(p);if(!gl.getProgramParameter(p,gl.LINK_STATUS))throw new Error(gl.getProgramInfoLog(p));return p}
const meshProg=program(
"attribute vec3 aPos; attribute vec3 aCol; uniform mat4 uMvp; varying vec3 vCol; void main(){vCol=aCol; gl_Position=uMvp*vec4(aPos,1.0);}",
"precision mediump float; varying vec3 vCol; void main(){gl_FragColor=vec4(vCol,0.74);}");
const pointProg=program(
"attribute vec3 aPos; attribute vec3 aCol; attribute float aSize; uniform mat4 uMvp; varying vec3 vCol; void main(){vCol=aCol; gl_PointSize=aSize; gl_Position=uMvp*vec4(aPos,1.0);}",
"precision mediump float; varying vec3 vCol; void main(){vec2 d=gl_PointCoord-vec2(.5); if(dot(d,d)>.25) discard; gl_FragColor=vec4(vCol,1.0);}");
const lineProg=program(
"attribute vec3 aPos; uniform mat4 uMvp; void main(){gl_Position=uMvp*vec4(aPos,1.0);}",
"precision mediump float; uniform vec3 uColor; void main(){gl_FragColor=vec4(uColor,1.0);}");

function norm(v,a,b){return (v-a)/(b-a||1)}
function mix(a,b,t){return a+(b-a)*t}
function colorFor(c){const junk=Math.max(c.openJunk||0,c.canaryJunk||0); if(junk>.01)return [0.86,0.15,0.15]; const t=norm(c.score,minScore,maxScore); return [mix(.15,.03,t),mix(.39,.57,t),mix(.92,.70,t)]}
function posFor(c){const x=norm(Math.log(c.midY),Math.log(Math.min(...xs)),Math.log(Math.max(...xs)))*2-1; const y=norm(Math.log(c.shoulderY),Math.log(Math.min(...ys)),Math.log(Math.max(...ys)))*2-1; const z=(norm(c.score,minScore,maxScore)-.5)*1.25; return [x*2.2,y*2.2,z]}
function matMul(a,b){const o=new Float32Array(16);for(let c=0;c<4;c++)for(let r=0;r<4;r++)o[c*4+r]=a[r]*b[c*4]+a[4+r]*b[c*4+1]+a[8+r]*b[c*4+2]+a[12+r]*b[c*4+3];return o}
function perspective(fovy,aspect,near,far){const f=1/Math.tan(fovy/2),nf=1/(near-far);return new Float32Array([f/aspect,0,0,0,0,f,0,0,0,0,(far+near)*nf,-1,0,0,2*far*near*nf,0])}
function lookAt(eye,center,up){let zx=eye[0]-center[0],zy=eye[1]-center[1],zz=eye[2]-center[2];let zn=1/Math.hypot(zx,zy,zz);zx*=zn;zy*=zn;zz*=zn;let xx=up[1]*zz-up[2]*zy,xy=up[2]*zx-up[0]*zz,xz=up[0]*zy-up[1]*zx;let xn=1/Math.hypot(xx,xy,xz);xx*=xn;xy*=xn;xz*=xn;let yx=zy*xz-zz*xy,yy=zz*xx-zx*xz,yz=zx*xy-zy*xx;return new Float32Array([xx,yx,zx,0,xy,yy,zy,0,xz,yz,zz,0,-(xx*eye[0]+xy*eye[1]+xz*eye[2]),-(yx*eye[0]+yy*eye[1]+yz*eye[2]),-(zx*eye[0]+zy*eye[1]+zz*eye[2]),1])}
function transform(m,p){const x=p[0],y=p[1],z=p[2],w=m[3]*x+m[7]*y+m[11]*z+m[15];return [(m[0]*x+m[4]*y+m[8]*z+m[12])/w,(m[1]*x+m[5]*y+m[9]*z+m[13])/w,(m[2]*x+m[6]*y+m[10]*z+m[14])/w]}
function buffer(data){const b=gl.createBuffer();gl.bindBuffer(gl.ARRAY_BUFFER,b);gl.bufferData(gl.ARRAY_BUFFER,new Float32Array(data),gl.STATIC_DRAW);return b}
function indexBuffer(data){const b=gl.createBuffer();gl.bindBuffer(gl.ELEMENT_ARRAY_BUFFER,b);gl.bufferData(gl.ELEMENT_ARRAY_BUFFER,new Uint16Array(data),gl.STATIC_DRAW);return b}

const pointPos=[],pointCol=[],pointSize=[],linePos=[],meshPos=[],meshCol=[],meshIdx=[];
for(const c of cells){pointPos.push(...posFor(c)); pointCol.push(...colorFor(c)); pointSize.push(10);}
for(const sy of ys){for(let i=0;i+1<xs.length;i++){const a=byKey.get(key(xs[i],sy)),b=byKey.get(key(xs[i+1],sy)); if(a&&b)linePos.push(...posFor(a),...posFor(b));}}
for(const mx of xs){for(let i=0;i+1<ys.length;i++){const a=byKey.get(key(mx,ys[i])),b=byKey.get(key(mx,ys[i+1])); if(a&&b)linePos.push(...posFor(a),...posFor(b));}}
const meshCellIndex=new Map();
for(const c of cells){meshCellIndex.set(key(c.midY,c.shoulderY),meshPos.length/3);meshPos.push(...posFor(c));meshCol.push(...colorFor(c));}
for(let yi=0;yi+1<ys.length;yi++)for(let xi=0;xi+1<xs.length;xi++){const a=meshCellIndex.get(key(xs[xi],ys[yi])),b=meshCellIndex.get(key(xs[xi+1],ys[yi])),c=meshCellIndex.get(key(xs[xi+1],ys[yi+1])),d=meshCellIndex.get(key(xs[xi],ys[yi+1])); if([a,b,c,d].every(v=>v!==undefined))meshIdx.push(a,b,c,a,c,d);}
const bufs={pointPos:buffer(pointPos),pointCol:buffer(pointCol),pointSize:buffer(pointSize),linePos:buffer(linePos),meshPos:buffer(meshPos),meshCol:buffer(meshCol),meshIdx:indexBuffer(meshIdx)};

function attrib(prog,name,b,size){const loc=gl.getAttribLocation(prog,name);gl.bindBuffer(gl.ARRAY_BUFFER,b);gl.enableVertexAttribArray(loc);gl.vertexAttribPointer(loc,size,gl.FLOAT,false,0,0)}
function resize(){const dpr=Math.min(devicePixelRatio||1,2);const w=Math.floor(canvas.clientWidth*dpr),h=Math.floor(canvas.clientHeight*dpr);if(canvas.width!==w||canvas.height!==h){canvas.width=w;canvas.height=h;gl.viewport(0,0,w,h)}}
function mvp(){const eye=[Math.cos(yaw)*Math.cos(pitch)*dist,Math.sin(yaw)*Math.cos(pitch)*dist,Math.sin(pitch)*dist];return matMul(perspective(Math.PI/4,canvas.width/canvas.height,.1,100),lookAt(eye,[0,0,0],[0,0,1]))}
function render(){
 resize(); gl.clearColor(.972,.98,.992,1); gl.clear(gl.COLOR_BUFFER_BIT|gl.DEPTH_BUFFER_BIT); gl.enable(gl.DEPTH_TEST); gl.enable(gl.BLEND); gl.blendFunc(gl.SRC_ALPHA,gl.ONE_MINUS_SRC_ALPHA);
 const M=mvp(); projection=cells.map((c,i)=>{const q=transform(M,posFor(c));return {cell:c,x:(q[0]*.5+.5)*canvas.width,y:(.5-q[1]*.5)*canvas.height,z:q[2]}}); pointScreen=projection;
 gl.useProgram(meshProg); gl.uniformMatrix4fv(gl.getUniformLocation(meshProg,"uMvp"),false,M); attrib(meshProg,"aPos",bufs.meshPos,3); attrib(meshProg,"aCol",bufs.meshCol,3); gl.bindBuffer(gl.ELEMENT_ARRAY_BUFFER,bufs.meshIdx); gl.drawElements(gl.TRIANGLES,meshIdx.length,gl.UNSIGNED_SHORT,0);
 gl.useProgram(lineProg); gl.uniformMatrix4fv(gl.getUniformLocation(lineProg,"uMvp"),false,M); gl.uniform3f(gl.getUniformLocation(lineProg,"uColor"),.42,.48,.58); attrib(lineProg,"aPos",bufs.linePos,3); gl.drawArrays(gl.LINES,0,linePos.length/3);
 gl.useProgram(pointProg); gl.uniformMatrix4fv(gl.getUniformLocation(pointProg,"uMvp"),false,M); attrib(pointProg,"aPos",bufs.pointPos,3); attrib(pointProg,"aCol",bufs.pointCol,3); attrib(pointProg,"aSize",bufs.pointSize,1); gl.drawArrays(gl.POINTS,0,cells.length);
 requestAnimationFrame(render);
}
function show(c){selected=c;document.getElementById("cell").innerHTML=\`<p><b>mid y@1%</b> \${c.midY}<br><b>shoulder y@9%</b> \${c.shoulderY}<br><b>score</b> \${c.score.toFixed(3)}<br><b>diversity</b> \${c.diversity.toFixed(3)} · <b>distinct2</b> \${c.distinct2.toFixed(3)}<br><b>canary junk</b> \${(c.canaryJunk*100).toFixed(1)}% · <b>open junk</b> \${(c.openJunk*100).toFixed(1)}%</p><pre>\${Object.entries(c.samples||{}).map(([p,ss])=>p+"\\n"+ss.map((s,i)=>(i+1)+". "+s).join("\\n")).join("\\n\\n")}</pre>\`;}
function renderUi(){document.getElementById("legend").innerHTML=\`<span><b>Default diversity</b> \${DATA.default.diversity.toFixed(3)}</span><span><b>Score range</b> \${minScore.toFixed(3)} .. \${maxScore.toFixed(3)}</span><span><span class="pill">WebGL</span> mesh + picked samples</span>\`;document.getElementById("summary").innerHTML=\`<p><b>Server:</b> \${DATA.baseUrl}<br><b>Model:</b> \${DATA.model}<br><b>N:</b> \${DATA.n}, <b>seed:</b> \${DATA.seed}</p><p><b>Default recipe:</b> T=\${DATA.default.recipe.temperature} top-p=\${DATA.default.recipe.topP} top-k=\${DATA.default.recipe.topK}</p>\`;const sorted=[...cells].sort((a,b)=>b.score-a.score);document.getElementById("rows").innerHTML='<table><tr><th>cell</th><th>score</th><th>div</th><th>junk</th></tr>'+sorted.map(c=>\`<tr><td>mid \${c.midY}, shoulder \${c.shoulderY}</td><td>\${c.score.toFixed(3)}</td><td>\${c.diversity.toFixed(3)}</td><td>\${(Math.max(c.openJunk,c.canaryJunk)*100).toFixed(1)}%</td></tr>\`).join('')+'</table>'; if(selected)show(selected);}
canvas.addEventListener("pointerdown",e=>{drag={x:e.clientX,y:e.clientY,yaw,pitch,moved:false};canvas.setPointerCapture(e.pointerId)});
canvas.addEventListener("pointermove",e=>{if(!drag)return;const dx=e.clientX-drag.x,dy=e.clientY-drag.y;if(Math.abs(dx)+Math.abs(dy)>3)drag.moved=true;yaw=drag.yaw+dx*.008;pitch=Math.max(.15,Math.min(1.35,drag.pitch+dy*.006));});
canvas.addEventListener("pointerup",e=>{if(drag&&!drag.moved){const r=canvas.getBoundingClientRect(),x=(e.clientX-r.left)*canvas.width/r.width,y=(e.clientY-r.top)*canvas.height/r.height;let best=null,bd=1e9;for(const p of pointScreen){const d=(p.x-x)**2+(p.y-y)**2;if(d<bd){bd=d;best=p.cell}}if(best&&bd<500)show(best)}drag=null});
canvas.addEventListener("wheel",e=>{e.preventDefault();dist=Math.max(3.2,Math.min(14,dist*Math.exp(e.deltaY*.001)))},{passive:false});
renderUi(); render();
</script></body></html>`;

writeFileSync(htmlPath, html);
console.log(htmlPath);
