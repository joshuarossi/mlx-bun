import { readFileSync, writeFileSync } from "node:fs";
import { join } from "node:path";
import { kindFacts, type Bridge } from "../bridgeFacts.ts";

const metaPath = process.argv[2];
if (!metaPath) throw new Error("usage: bun generateSized.ts <D1BodySized/seg.json>");
const m = JSON.parse(readFileSync(metaPath, "utf8")) as {
  world: string; stop: string; steps: number; T1: number; bridges: Bridge[]; loadP: number[];
};
if (m.world !== "full" || m.stop !== "ret" || !Number.isSafeInteger(m.steps) || m.steps !== 1541184 ||
    !Number.isSafeInteger(m.T1) || !Array.isArray(m.bridges) || !m.bridges.length ||
    m.bridges.some(b => b.kind !== "size" || !Number.isSafeInteger(b.ia) || !Number.isSafeInteger(b.nA)) ||
    JSON.stringify(m.loadP) !== JSON.stringify([18151, 131072, 1099511627776, 15235, 15235]))
  throw new Error("expected the unchanged full-body path partitioned only at actual size calls");
const sizes: number[] = [];
let consumed = 0;
function ordinary(n: number) {
  if (!Number.isSafeInteger(n) || n < 0) throw new Error("invalid ordinary range");
  while (n > 0) { const k = Math.min(n, 10000); sizes.push(k); n -= k; }
}
for (const b of m.bridges) {
  ordinary(b.nA - consumed);
  if (sizes.length !== b.ia - 1) throw new Error("boundary mismatch at size bridge");
  sizes.push(1, 3); consumed = b.nA + 4;
}
ordinary(m.steps - consumed);
if (sizes.length !== m.T1 || sizes.reduce((a, b) => a + b, 0) !== m.steps) throw new Error("incomplete partition");
const dir = import.meta.dir;
const mod = (f: string) => `host.sim.template.a4pre_d1_body.${f}`;
const head = (...imports: string[]) => imports.map(i => `import ${i}\n`).join("") +
  "set_option Elab.async false\nset_option maxRecDepth 1000000\nset_option maxHeartbeats 0\n" +
  "namespace Host.Load.Run.Tpl\nopen Host.Ts Host.Ts.Sim Host.Ts.Sim.Template Host.Ts.Sim.Lin Host.Ts.Sim.Lin.Cls\n";
const put = (f: string, text: string) => writeFileSync(join(dir, f + ".lean"), text + "\nend Host.Load.Run.Tpl\n");
for (let j = 0; j <= Math.floor(m.T1 / 32); j++) {
  let text = head(mod(j === 0 ? "SizedStates" : `SD${j - 1}`));
  for (let i = 32 * j; i < 32 * (j + 1) && i <= m.T1; i++) text += `host_stream_state D1BodySized ${i}\n`;
  put(`SD${j}`, text);
}
const special = new Set(m.bridges.flatMap(b => [b.ia - 1, b.ia]));
for (let i = 0; i < sizes.length; i++) {
  if (special.has(i)) continue;
  const fuel = sizes[i]!;
  put(`SN${i}`, head(mod(`SD${Math.floor((i + 1) / 32)}`), "host.sim.Chunk") +
    `\nkernel_rfl D1BodySized.fuel${i} : nth? D1BodySized.ks ${i} = some ${fuel}\n` +
    `kernel_rfl D1BodySized.checked${i} :\n` +
    `  (fun bs : List Byte => runOk D1BodySized.F (D1Frames.typedOk bs) ${fuel} D1BodySized.s${i} D1BodySized.S${i}) =\n` +
    `    fun _ => some (D1BodySized.s${i + 1}, D1BodySized.S${i + 1})\n\n` +
    `theorem D1BodySized.k${i} (bs : List Byte) :\n` +
    `    runOk D1BodySized.F (D1Frames.typedOk bs) ${fuel} D1BodySized.s${i} D1BodySized.S${i} =\n` +
    `      some (D1BodySized.s${i + 1}, D1BodySized.S${i + 1}) := congrFun D1BodySized.checked${i} bs\n`);
}
const segments: { from: number; to: number; fuel: number; next?: number }[] = [];
for (let k = 0; k <= m.bridges.length; k++) {
  const from = k === 0 ? 0 : m.bridges[k - 1]!.ia + 1;
  const to = k === m.bridges.length ? m.T1 : m.bridges[k]!.ia - 1;
  const fuel = sizes.slice(from, to).reduce((a, b) => a + b, 0);
  segments.push({ from, to, fuel, ...(k < m.bridges.length ? { next: m.bridges[k]!.ia + 1 } : {}) });
  const imports = Array.from({ length: to - from }, (_, j) => mod(`SN${from + j}`));
  imports.push(mod(`SD${Math.floor((k < m.bridges.length ? m.bridges[k]!.ia + 1 : m.T1) / 32)}`), mod("SizeLift"));
  let text = head(...imports);
  let proof = from < to ? `D1BodySized.k${from} bs` : "rfl";
  let n = from < to ? sizes[from]! : 0;
  for (let i = from + 1; i < to; i++) {
    proof = `runOk_trans D1BodySized.F (D1Frames.typedOk bs) ${n} ${sizes[i]} ` +
      `D1BodySized.s${from} D1BodySized.s${i} D1BodySized.s${i + 1} ` +
      `D1BodySized.S${from} D1BodySized.S${i} D1BodySized.S${i + 1} (${proof}) (D1BodySized.k${i} bs)`;
    n += sizes[i]!;
  }
  text += `\ntheorem D1BodySized.segment${k} (bs : List Byte) :\n` +
    `    runOk D1BodySized.F (D1Frames.typedOk bs) ${fuel} D1BodySized.s${from} D1BodySized.S${from} =\n` +
    `      some (D1BodySized.s${to}, D1BodySized.S${to}) := ${proof}\n\n` +
    `kernel_rfl D1BodySized.accepted${k} : (fun bs : List Byte =>\n` +
    `  D1Frames.typedOk bs D1BodySized.s${from} D1BodySized.S${from}) = fun _ => true\n` +
    `kernel_rfl D1BodySized.oracle${k} : goodEnum final_cold.r0.ps\n` +
    `  (varsOf final_cold.r0.V [(9, .L)]) D1BodySized.S${from}.oracle = true\n`;
  if (k < m.bridges.length) {
    const b = m.bridges[k]!, idx = k + 1;
    text += `kernel_rfl D1BodySized.fuelA${idx} : nth? D1BodySized.ks ${b.ia - 1} = some 1\n` +
      `kernel_rfl D1BodySized.fuelB${idx} : nth? D1BodySized.ks ${b.ia} = some 3\n` +
      `kernel_rfl D1BodySized.stepA${idx} : interpS (step D1BodySized.F D1BodySized.s${b.ia - 1}).run D1BodySized.S${b.ia - 1} =\n` +
      `  some (D1BodySized.s${b.ia}, D1BodySized.S${b.ia})\n` +
      `kernel_rfl D1BodySized.patchB${idx} : interpS (Disp.sizeS D1BodySized.F D1BodySized.s${b.ia}).run D1BodySized.S${b.ia} =\n` +
      `  some (D1BodySized.s${b.ia + 1}, D1BodySized.S${b.ia + 1})\n` +
      `kernel_rfl D1BodySized.acceptedP${idx} : (fun bs : List Byte => D1Frames.typedOk bs\n` +
      `  D1BodySized.s${b.ia - 1} D1BodySized.S${b.ia - 1}) = fun _ => true\n` +
      `kernel_rfl D1BodySized.haltP${idx} : isHalt D1BodySized.s${b.ia - 1}.ctl = false\n` +
      `kernel_rfl D1BodySized.topA${idx} : Host.Ts.Sim.Compose.noRetBlock D1BodySized.s${b.ia} = true\n` +
      `kernel_rfl D1BodySized.inactive${idx} : (Host.Ts.Sim.Full.bridgeOf D1BodySized.s${b.ia}.ffi).active = false\n`;
    text += kindFacts("D1BodySized", b, idx, [2665, 2673479, 2673484, 2673485]);
  }
  put(`SB${k}`, text);
}
writeFileSync(join(dir, "sized-pieces.json"), JSON.stringify({ steps: m.steps, last: m.T1, sizes, bridges: m.bridges, segments }, null, 2));
console.log({ steps: m.steps, last: m.T1, bridges: m.bridges.length, ordinaryChunks: sizes.length - special.size });
