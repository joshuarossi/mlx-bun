// Write the state and chunk modules of a template case stream.
// usage: bun proofs/host/sim/template/gen.ts <case-dir> <Name> <T1> [<ok> <ok-module> [<ia> <aN>]]
//   <case-dir>: e.g. ordinary; <Name>: the stream (e.g. ORDINARY); <T1>: its last boundary.
// H<j>.lean loads boundaries 32j … 32j+31 (`host_stream_state`). With an acceptance function
// `<ok>` (defined in `<ok-module>`), K<j>.lean checks chunks 4j … 4j+3 as checked runs
// (`sim_chunk`, `runOk`) and Run.lean composes them (`sim_chain_run`, `<Name>.okRun`).
// A final case split at the epilogue spread (boundary <ia>, new array <aN>) gets
// OkB.lean (`<Name>.okB`, framing <aN>), chunks before <ia> - 1 checked with <ok>, chunks <ia> - 1
// and <ia> as plain steps into and out of the spread's state (`<Name>.stepA`, `<Name>.stepB`), the
// rest with `<Name>.okB`; Run.lean composes `<Name>.runA` (chunks 0 … ia-2) and `<Name>.runB`
// (ia+1 … T1-1).
import { mkdirSync, writeFileSync } from "node:fs";
import { join } from "node:path";

const [dir, name, last, ok, okModule, iaArg, aNArg] = process.argv.slice(2);
if (!dir || !name || !last) throw new Error("usage: gen.ts <case-dir> <Name> <T1> [<ok> <ok-module> [<ia> <aN>]]");
const n = Number(last);
if (!Number.isSafeInteger(n) || n < 1) throw new Error("T1 must be a positive integer");
const split = iaArg !== undefined;
const ia = Number(iaArg);
if (split && (!ok || !okModule || !aNArg || !Number.isSafeInteger(ia) || ia < 2 || ia + 1 >= n)) {
  throw new Error("split: need <ok> <ok-module> <ia> <aN> with 2 ≤ ia and ia + 1 < T1");
}
const root = join(import.meta.dir, dir);
mkdirSync(root, { recursive: true });
const mod = (file: string) => `host.sim.template.${dir}.${file}`;
const header = (...imps: string[]) =>
  `${imps.map(i => `import ${i}\n`).join("")}set_option Elab.async false\nnamespace Host.Load.Run.Tpl\nset_option maxRecDepth 1000000\nset_option maxHeartbeats 0\n`;
const per = 32;
const hCount = Math.floor(n / per) + 1;
for (let j = 0; j < hCount; j++) {
  const lines = [header(j === 0 ? mod("States") : mod(`H${j - 1}`))];
  for (let i = j * per; i < Math.min((j + 1) * per, n + 1); i++) lines.push(`host_stream_state ${name} ${i}\n`);
  lines.push("end Host.Load.Run.Tpl\n");
  writeFileSync(join(root, `H${j}.lean`), lines.join(""));
}
if (split) {
  writeFileSync(join(root, "OkB.lean"), [
    `import ${okModule}\n`, "namespace Host.Load.Run.Tpl\nopen Host.Ts Host.Ts.Sim\n\n",
    `/-- The acceptance function of \`${name}\` after the epilogue spread: \`ok\` with the spread's\n`,
    `new array \`${aNArg}\` (\`${name}.aN\`) framed as well. -/\n`,
    `noncomputable def ${name}.okB : St Host.Load.ffi.S → SSrv → Bool := Disp.okJS (loadJSP [2673447, 12502, ${aNArg}])\n\n`,
    "end Host.Load.Run.Tpl\n"].join(""));
}
const cPer = 4;
const cCount = Math.ceil(n / cPer);
for (let j = 0; j < cCount; j++) {
  const lastChunk = Math.min((j + 1) * cPer, n) - 1;
  const states = mod(`H${Math.floor((lastChunk + 1) / per)}`);
  if (ok && okModule) {
    const k = [header(states, split ? mod("OkB") : okModule, "host.sim.Chunk"), "open Host.Ts Host.Ts.Sim\n"];
    for (let i = j * cPer; i <= lastChunk; i++) {
      if (!split || i < ia - 1) k.push(`sim_chunk ${name} ${ok} ${i}\n`);
      else if (i <= ia) {
        k.push(`kernel_rfl ${name}.step${i === ia ? "B" : "A"} : interpS (step ${name}.F ${name}.s${i}).run ${name}.S${i} = some (${name}.s${i + 1}, ${name}.S${i + 1})\n`);
      } else k.push(`sim_chunk ${name} ${name}.okB ${i}\n`);
    }
    k.push("end Host.Load.Run.Tpl\n");
    writeFileSync(join(root, `K${j}.lean`), k.join(""));
  }
}
if (ok && okModule) {
  const imps = Array.from({ length: cCount }, (_, j) => mod(`K${j}`));
  const body = split
    ? [`sim_chain_range ${name} ${ok} 0 ${ia - 1} runA\n`, `sim_chain_range ${name} ${name}.okB ${ia + 1} ${n} runB\n`]
    : [`sim_chain_run ${name} ${ok}\n`];
  writeFileSync(join(root, "Run.lean"),
    [header(...imps, ...(split ? ["host.sim.template.ChainRange"] : [])), "open Host.Ts.Sim Host.Ts.Sim.Template\n", ...body,
      "end Host.Load.Run.Tpl\n"].join(""));
}
console.log(`${name}: ${hCount} state modules, ${cCount} chunk modules, chunks 0..${n - 1}${ok ? `, checked runs with ${ok}` : ""}${split ? `, split at ${ia} (aN = ${aNArg})` : ""}`);
