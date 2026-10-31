// Recheck each normal glue stretch with parameterized typed-buffer acceptance.
import { readFileSync, writeFileSync } from "node:fs";
import { join } from "node:path";

const [dir, name] = process.argv.slice(2);
if (!dir || !name || !/^[\w/]+$/.test(dir) || !/^[\w.]+$/.test(name))
  throw Error("usage: genTypedRoot.ts <chain-dir> <Lean namespace>");
const root = join(import.meta.dir, dir), mod = (s: string) => `host.sim.template.${dir.replaceAll("/", ".")}.${s}`;
const ranges = [...readFileSync(join(root, "Run.lean"), "utf8").matchAll(/^sim_chain_range \S+ \S+ (\d+) (\d+) (\w+)$/gm)]
  .map(m => ({ a: Number(m[1]), b: Number(m[2]), run: m[3]! }));
if (!ranges.length) throw Error("no checked glue ranges found");
const head = (imports: string[]) => [...new Set(imports)].map(i => `import ${i}\n`).join("") +
  "set_option Elab.async false\nset_option maxRecDepth 1000000\nset_option maxHeartbeats 0\n" +
  "namespace Host.Load.Run.Tpl\nopen Host.Ts Host.Ts.Sim Host.Ts.Sim.Template\n\n";
const put = (file: string, text: string) => writeFileSync(join(root, file + ".lean"), text + "\nend Host.Load.Run.Tpl\n");
put("TypedOk", head(["host.sim.compose.a4b.VWFramesDefs"]) +
  `noncomputable def ${name}.bodyOkB (bytes : List Byte) (rows : Nat) : St Host.Load.Layers.full.S → SSrv → Bool :=\n` +
  "  Host.Ts.Sim.Compose.VWFrames.bodyOk bytes rows\n");
const fuel = (k: number) => `((nth? ${name}.ks ${k}).getD 0)`;
const indices = [...new Set(ranges.flatMap(r => Array.from({ length: r.b - r.a }, (_, i) => i + r.a)))];
for (const k of indices) put(`TypedK${k}`, head([mod(`H${Math.floor((k + 1) / 32)}`), mod("TypedOk"), "host.sim.template.BootEq", "host.sim.Chunk"]) +
  `boot_rfl ${name}.bodyK${k} from ${name}.s${k} to ${name}.s${k + 1} :\n` +
  `  (fun (bytes : List Byte) (rows : Nat) => runOk ${name}.F (${name}.bodyOkB bytes rows) ${fuel(k)} ${name}.s${k} ${name}.S${k}) =\n` +
  `    fun _ _ => some (${name}.s${k + 1}, ${name}.S${k + 1})`);
for (const [j, r] of ranges.entries()) {
  const applied = (k: number) => `(congrFun (congrFun ${name}.bodyK${k} bytes) rows)`;
  let proof = r.a < r.b ? applied(r.a) : "rfl", sum = r.a < r.b ? fuel(r.a) : "0";
  for (let k = r.a + 1; k < r.b; k++) {
    proof = `runOk_trans ${name}.F (${name}.bodyOkB bytes rows) ${sum} ${fuel(k)} ` +
      `${name}.s${r.a} ${name}.s${k} ${name}.s${k + 1} ${name}.S${r.a} ${name}.S${k} ${name}.S${k + 1} (${proof}) ${applied(k)}`;
    sum = `(${sum} + ${fuel(k)})`;
  }
  put(`TypedSeg${j}`, head(["host.sim.Chunk", mod(`H${Math.floor(r.b / 32)}`), mod("TypedOk"),
    ...Array.from({ length: r.b - r.a }, (_, i) => mod(`TypedK${r.a + i}`))]) +
    `theorem ${name}.body${r.run[0]!.toUpperCase() + r.run.slice(1)} (bytes : List Byte) (rows : Nat) :\n` +
    `    runOk ${name}.F (${name}.bodyOkB bytes rows) ${sum} ${name}.s${r.a} ${name}.S${r.a} = some (${name}.s${r.b}, ${name}.S${r.b}) :=\n  ${proof}`);
}
writeFileSync(join(root, "TypedRun.lean"), ranges.map((_, i) => `import ${mod(`TypedSeg${i}`)}\n`).join(""));
console.log(`${dir}: emitted ${indices.length} parameterized normal chunks and ${ranges.length} glue stretches`);
