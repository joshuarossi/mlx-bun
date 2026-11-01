// Recheck a stage over a parameterized acceptance, retaining its checked states.
import { readFileSync, writeFileSync } from "node:fs";
import { join } from "node:path";

const [dir, name, acceptance = "Host.Ts.Sim.Compose.VWFrames.bodyOk"] = process.argv.slice(2);
if (!dir || !name || !/^[\w/]+$/.test(dir) || !/^[\w.]+$/.test(name) || !/^[\w.]+$/.test(acceptance))
  throw Error("usage: genTypedStage.ts <stage-dir> <Lean namespace> [acceptance(bytes,rows)]");
const root = join(import.meta.dir, dir);
const stream = process.env.HOST_STREAM_DIR;
if (!stream) throw Error("HOST_STREAM_DIR is required");
const meta = JSON.parse(readFileSync(join(stream, `Host.Load.Run.Tpl.${name}`, "stage.json"), "utf8"));
const seg = JSON.parse(readFileSync(join(stream, `Host.Load.Run.Tpl.${name}`, "seg.json"), "utf8"));
const end = Number(seg.T1) - 1, total = Number(meta.steps) - 1;
if (!Number.isSafeInteger(end) || end < 1 || !Number.isSafeInteger(total)) throw Error("unsupported stage boundaries");
const mod = (file: string) => `host.sim.template.${dir.replaceAll("/", ".")}.${file}`;
const head = (imports: string[]) => imports.map(i => `import ${i}\n`).join("") +
  "set_option Elab.async false\nset_option maxRecDepth 1000000\nset_option maxHeartbeats 0\n" +
  "namespace Host.Load.Run.Tpl\nopen Host.Ts Host.Ts.Sim Host.Ts.Sim.Template\n\n";
const put = (file: string, text: string) => writeFileSync(join(root, file + ".lean"), text + "\nend Host.Load.Run.Tpl\n");
const localOk = `${name}.bodyOkL`;
put("TypedOk", head([mod(`H${Math.floor(end / 32)}`), "host.sim.compose.a4b.VWFramesDefs", "host.sim.template.FullOk", "host.sim.template.FastOk"]) +
  `noncomputable def ${localOk} (bytes : List Byte) (rows : Nat) : St ${name}.F.S → SSrv → Bool :=\n` +
  `  okLocal (${acceptance} bytes rows)\n\n` +
  // the fast table's acceptance (`${acceptance}N`): what the chunks are checked at
  `noncomputable def ${localOk}N (bytes : List Byte) (rows : Nat) : St ${name}.F.S → FSrv → Bool :=\n` +
  `  okLocalN (${acceptance}N bytes rows)\n\n` +
  `theorem ${localOk}N_ok (bytes : List Byte) (rows : Nat) (s : St ${name}.F.S) (c : FSrv) (h : c.Wf) :\n` +
  `    ${localOk}N bytes rows s c = ${localOk} bytes rows s c.toS :=\n` +
  `  okLocalN_ok (${acceptance}N_ok bytes rows) s c h\n\n` +
  [0, end].map((i, j) => `kernel_rfl ${name}.bodyAccepted${j} :\n` +
    `  (fun (bytes : List Byte) (rows : Nat) => ${localOk} bytes rows ${name}.s${i} ${name}.S${i}) = fun _ _ => true\n`).join("\n"));
for (let i = 0; i < end; i++) {
  put(`TypedK${i}`, head([mod("TypedOk"), mod(`H${Math.floor((i + 1) / 32)}`), "host.sim.template.BootEq", "host.sim.Chunk"]) +
    // checked at the fast table (`runOkS`); the statement is `runOk`'s
    `boot_rfl ${name}.bodyK${i}F from ${name}.s${i} to ${name}.s${i + 1} :\n` +
    `  (fun (bytes : List Byte) (rows : Nat) => runOkS ${name}.F (${localOk}N bytes rows)\n` +
    `    ((nth? ${name}.ks ${i}).getD 0) ${name}.s${i} ${name}.S${i}) = fun _ _ => some (${name}.s${i + 1}, ${name}.S${i + 1})\n` +
    `theorem ${name}.bodyK${i} :\n` +
    `  (fun (bytes : List Byte) (rows : Nat) => runOk ${name}.F (${localOk} bytes rows)\n` +
    `    ((nth? ${name}.ks ${i}).getD 0) ${name}.s${i} ${name}.S${i}) = fun _ _ => some (${name}.s${i + 1}, ${name}.S${i + 1}) :=\n` +
    `  runOk_fun_of_runOkS ${localOk}N_ok ${name}.bodyK${i}F`);
}
const applied = (k: number) => `(congrFun (congrFun ${name}.bodyK${k} bytes) rows)`;
let proof = applied(0), consumed = `((nth? ${name}.ks 0).getD 0)`;
for (let i = 1; i < end; i++) {
  const fuel = `((nth? ${name}.ks ${i}).getD 0)`;
  proof = `runOk_trans ${name}.F (${localOk} bytes rows) ${consumed} ${fuel} ${name}.s0 ${name}.s${i} ${name}.s${i + 1} ` +
    `${name}.S0 ${name}.S${i} ${name}.S${i + 1} (${proof}) ${applied(i)}`;
  consumed = `(${consumed} + ${fuel})`;
}
put("TypedLast", head([mod(`H${Math.floor((end + 1) / 32)}`), "host.sim.template.BootEq", "host.sim.StageRel"]) +
  `boot_rfl ${name}.bodyLast from ${name}.s${end} to ${name}.s${end + 1} :\n` +
  `  interpS (step ${name}.F ${name}.s${end}).run ${name}.S${end} = some (${name}.s${end + 1}, ${name}.S${end + 1})\n` +
  `kernel_rfl ${name}.bodyHalt : isHalt ${name}.s${end}.ctl = false\n` +
  `kernel_rfl ${name}.bodyTopCheck : noBlockTop ${name}.s${end + 1}.stack = true\n`);
put("TypedTpl", head([mod("TypedLast"), ...Array.from({ length: end }, (_, i) => mod(`TypedK${i}`))]) +
  `theorem ${name}.bodyRun (bytes : List Byte) (rows : Nat) :\n` +
  `    runOk ${name}.F (${localOk} bytes rows) ${total} ${name}.s0 ${name}.S0 = some (${name}.s${end}, ${name}.S${end}) :=\n  ${proof}\n\n` +
  `theorem ${name}.bodyLocal (bytes : List Byte) (rows : Nat) : ∀ s S, ${localOk} bytes rows s S = true → Disp.localB s = true := okLocal_localB\n\n` +
  `noncomputable def ${name}.bodyTpl (bytes : List Byte) (rows : Nat) : Host.Ts.Sim.Stage.StageTpl ${name}.F (${localOk} bytes rows) where\n` +
  `  s0 := ${name}.s0\n  S0 := ${name}.S0\n  s1 := ${name}.s${end}\n  S1 := ${name}.S${end}\n` +
  `  s2 := ${name}.s${end + 1}\n  S2 := ${name}.S${end + 1}\n  n := ${total}\n` +
  `  ok0 := congrFun (congrFun ${name}.bodyAccepted0 bytes) rows\n  run := ${name}.bodyRun bytes rows\n` +
  `  ok1 := congrFun (congrFun ${name}.bodyAccepted1 bytes) rows\n  halt := ${name}.bodyHalt\n` +
  `  last := ${name}.bodyLast\n  top := noBlockTop_sound ${name}.bodyTopCheck`);
console.log(`${dir}: emitted parameterized acceptance and ${end} checked run fragments, ${total} steps`);
