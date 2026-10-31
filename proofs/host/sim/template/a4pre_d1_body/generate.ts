// Write checks of the original full-world stream, parameterized by incoming token bytes.
import { readFileSync, writeFileSync } from "node:fs";
import { join } from "node:path";

const metaPath = process.argv[2];
if (!metaPath) throw new Error("usage: bun generate.ts <D1Body/seg.json>");
const m: unknown = JSON.parse(readFileSync(metaPath, "utf8"));
if (!m || typeof m !== "object" || Array.isArray(m)) throw new Error("expected metadata object");
const meta = m as Record<string, unknown>;
const steps = meta.steps, last = meta.T1;
if (meta.world !== "full" || meta.stop !== "ret" || !Number.isSafeInteger(steps) ||
    typeof steps !== "number" || steps < 1 || !Number.isSafeInteger(last) ||
    typeof last !== "number" || last !== Math.ceil(steps / 10000) ||
    !Array.isArray(meta.bridges) || meta.bridges.length !== 0 ||
    JSON.stringify(meta.loadP) !== JSON.stringify([18151, 131072, 1099511627776, 15235, 15235]))
  throw new Error("expected the complete unisolated original cold body with unchanged band");
const dir = import.meta.dir;
const mod = (f: string) => `host.sim.template.a4pre_d1_body.${f}`;
const header = (...imports: string[]) => imports.map(i => `import ${i}\n`).join("") +
  "set_option Elab.async false\nset_option maxRecDepth 1000000\nset_option maxHeartbeats 0\n" +
  "namespace Host.Load.Run.Tpl\nopen Host.Ts Host.Ts.Sim\n";
const put = (f: string, s: string) => writeFileSync(join(dir, f + ".lean"), s + "\nend Host.Load.Run.Tpl\n");
const sizes = Array.from({ length: last }, (_, i) => Math.min(10000, steps - 10000 * i));
for (let j = 0; j <= Math.floor(last / 32); j++) {
  let s = header(mod(j === 0 ? "States" : `D${j - 1}`));
  for (let i = 32 * j; i <= last && i < 32 * (j + 1); i++) s += `host_stream_state D1Body ${i}\n`;
  put(`D${j}`, s);
}
for (let i = 0; i < last; i++) {
  const fuel = sizes[i]!;
  put(`C${i}`, header(mod(`D${Math.floor((i + 1) / 32)}`), "host.sim.Chunk") +
    `\nkernel_rfl D1Body.fuel${i} : nth? D1Body.ks ${i} = some ${fuel}\n` +
    `kernel_rfl D1Body.checked${i} :\n` +
    `  (fun bs : List Byte => runOk D1Body.F (D1Frames.typedOk bs) ${fuel} D1Body.s${i} D1Body.S${i}) =\n` +
    `    fun _ => some (D1Body.s${i + 1}, D1Body.S${i + 1})\n\n` +
    `theorem D1Body.k${i} (bs : List Byte) :\n` +
    `    runOk D1Body.F (D1Frames.typedOk bs) ${fuel} D1Body.s${i} D1Body.S${i} =\n` +
    `      some (D1Body.s${i + 1}, D1Body.S${i + 1}) := congrFun D1Body.checked${i} bs\n`);
}
let proof = "D1Body.k0 bs", fuel = sizes[0]!;
for (let i = 1; i < last; i++) {
  proof = `runOk_trans D1Body.F (D1Frames.typedOk bs) ${fuel} ${sizes[i]} ` +
    `D1Body.s0 D1Body.s${i} D1Body.s${i + 1} D1Body.S0 D1Body.S${i} D1Body.S${i + 1} (${proof}) (D1Body.k${i} bs)`;
  fuel += sizes[i]!;
}
put("Run", header(...sizes.map((_, i) => mod(`C${i}`))) +
  `\nkernel_rfl D1Body.steps_exact : D1Body.steps = ${steps}\n` +
  `kernel_rfl D1Body.chunks_exact : D1Body.ks = [${sizes.join(", ")}]\n\n` +
  `theorem D1Body.checked (bs : List Byte) :\n` +
  `    runOk D1Body.F (D1Frames.typedOk bs) ${steps} D1Body.s0 D1Body.S0 =\n` +
  `      some (D1Body.s${last}, D1Body.S${last}) :=\n  ${proof}\n`);
console.log({ steps, last, chunks: sizes.length });
