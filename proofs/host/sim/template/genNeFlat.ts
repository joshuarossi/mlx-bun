// Write the checked modules of a flat Neural Engine forward body (`tpl_chain` with no stage cuts, the bridge literal).
// usage: bun genNeFlat.ts <dir under template/> <Name> [--group <chunks per K module>] [--ok <module> <term>] [--only-chunks a-b]
// The acceptance is parameterized (`<term> bytes rows`); states never hold the `Boot.replay` thunk, so every check is a
// plain kernel evaluation of literal states (no `boot_rfl`).
import { readFileSync, writeFileSync } from "node:fs";
import { join } from "node:path";
import { syncRowMetadata } from "./syncRowMeta";

const argv = process.argv.slice(2);
const take = (f: string, k = 1) => {
  const i = argv.indexOf(f);
  if (i < 0) return undefined;
  const v = argv.slice(i + 1, i + 1 + k);
  argv.splice(i, k + 1);
  return v;
};
const group = Number(take("--group")?.[0] ?? 4);
const okArg = take("--ok", 2) ?? ["host.sim.compose.a4b.VWFrames", "Host.Ts.Sim.Compose.VWFrames.bodyOk"];
const only = take("--only-chunks")?.[0]?.split("-").map(Number);
const [dir, name] = argv;
if (!dir || !name) throw Error("usage: genNeFlat.ts dir Name [--group n] [--ok module term] [--only-chunks a-b]");
const streams = process.env.HOST_STREAM_DIR ?? join(import.meta.dir, "../../../.host-stream");
const pre = `Host.Load.Run.Tpl.${name}`;
syncRowMetadata(streams, pre);
const seg = JSON.parse(readFileSync(join(streams, pre, "seg.json"), "utf8"));
const T1 = Number(seg.T1), bridges: any[] = seg.bridges ?? [];
const root = join(import.meta.dir, dir), mod = (f: string) => `host.sim.template.${dir.replaceAll("/", ".")}.${f}`;
const per = 32;
const H = (i: number) => mod(`H${Math.floor(i / per)}`);
const head = (imports: string[], open = "Host.Ts Host.Ts.Sim") => [...new Set(imports)].map(i => `import ${i}\n`).join("") +
  `set_option Elab.async false\nset_option maxRecDepth 1000000\nset_option maxHeartbeats 0\nnamespace Host.Load.Run.Tpl\nopen ${open}\n\n`;
const put = (file: string, text: string) => writeFileSync(join(root, file + ".lean"), text + "\nend Host.Load.Run.Tpl\n");
const s = (i: number) => `${name}.s${i}`, S = (i: number) => `${name}.S${i}`;
const fuel = (k: number) => `((nth? ${name}.ks ${k}).getD 0)`;

put("Rebind", `import ${mod("States")}\nimport host.sim.template.StreamRows\nimport host.sim.template.StreamTokens\n` +
  `set_option Elab.async false\nnamespace Host.Load.Run.Tpl\n` +
  `tpl_stream_keep_lookahead ${name} through ${T1}\ntpl_stream_bind_rows ${name} through ${T1}\n`);
for (let j = 0; j <= Math.floor(T1 / per); j++) {
  const lines = [head([j === 0 ? mod("Rebind") : mod(`H${j - 1}`)], "Host.Ts")];
  for (let i = j * per; i < Math.min((j + 1) * per, T1 + 1); i++) lines.push(`host_stream_state ${name} ${i}\n`);
  put(`H${j}`, lines.join(""));
}
put("TypedOk", head([okArg[0]!], "Host.Ts Host.Ts.Sim Host.Ts.Sim.Template") +
  `noncomputable def ${name}.bodyOkB (bytes : List Byte) (rows : Nat) : St Host.Load.Layers.full.S → SSrv → Bool :=\n  ${okArg[1]} bytes rows\n`);

// a chunk entered or left by a size bridge is the bridge's facts, not glue
const bridgeChunks = new Set<number>();
for (const b of bridges) { bridgeChunks.add(b.ia - 1); bridgeChunks.add(b.ia); }
const glue = Array.from({ length: T1 }, (_, i) => i).filter(i => !bridgeChunks.has(i));
const stretches: number[][] = [];
for (const k of glue) {
  const last = stretches[stretches.length - 1];
  if (last && last[last.length - 1] === k - 1 && last.length < group) last.push(k);
  else stretches.push([k]);
}
const emitted: string[] = [];
for (const [j, ks] of stretches.entries()) {
  if (only && (ks[0]! < only[0]! || ks[ks.length - 1]! > only[1]!)) continue;
  const lines = ks.map(k => `kernel_rfl ${name}.bodyK${k} :\n` +
    `  (fun (bytes : List Byte) (rows : Nat) => runOk ${name}.F (${name}.bodyOkB bytes rows) ${fuel(k)} ${s(k)} ${S(k)}) =\n` +
    `    fun _ _ => some (${s(k + 1)}, ${S(k + 1)})\n`);
  put(`K${j}`, head([H(ks[ks.length - 1]! + 1), mod("TypedOk"), "host.sim.Chunk"], "Host.Ts Host.Ts.Sim Host.Ts.Sim.Template") + lines.join(""));
  emitted.push(`K${j}`);
}
console.log(`${dir}: T1 ${T1}, ${seg.steps} steps, ${bridges.length} bridges, ${glue.length} glue chunks in ${stretches.length} K modules; emitted ${emitted.length}`);
