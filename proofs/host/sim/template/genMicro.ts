// Split one existing generated sim_chunk proof into bounded, kernel-checked links.
// Usage: bun genMicro.ts <case-dir> <Name> <chunk> <fuel> <ok-name> [width=32]
// The last link uses the existing endpoint; the aggregate retains the original k<chunk> type.
import { existsSync, readFileSync, readdirSync, writeFileSync } from "node:fs";
import { join } from "node:path";

const argv = process.argv.slice(2);
const bounded = argv.includes("--bounded");
if (bounded) argv.splice(argv.indexOf("--bounded"), 1);
const phased = bounded || argv.includes("--phased");
if (argv.includes("--phased")) argv.splice(argv.indexOf("--phased"), 1);
const flat = phased || argv.includes("--flat");
if (argv.includes("--flat")) argv.splice(argv.indexOf("--flat"), 1);
const boot = argv.includes("--boot");
if (boot) argv.splice(argv.indexOf("--boot"), 1);
const bridge = argv.includes("--bridge");
if (bridge) argv.splice(argv.indexOf("--bridge"), 1);
const [dirArg, nameArg, chunkArg, fuelArg, okArg, widthArg = "32"] = argv;
if (!dirArg || !nameArg || chunkArg === undefined || fuelArg === undefined || !okArg)
  throw new Error("usage: genMicro.ts <case-dir> <Name> <chunk> <fuel> <ok-name> [width=32]");
if (!/^[A-Za-z0-9_]+(?:\/[A-Za-z0-9_]+)*$/.test(dirArg) ||
    !/^[A-Za-z_][A-Za-z0-9_.]*$/.test(nameArg) || !/^[A-Za-z_][A-Za-z0-9_.]*$/.test(okArg))
  throw new Error("invalid generated directory or Lean name");
const dir = dirArg, name = nameArg, ok = okArg;
const chunk = Number(chunkArg), fuel = Number(fuelArg), width = Number(widthArg);
if (!Number.isSafeInteger(chunk) || chunk < 0 || !Number.isSafeInteger(fuel) || fuel < 1 ||
    !Number.isSafeInteger(width) || width < 1 || width > (flat ? 512 : 64))
  throw new Error("expected nonnegative chunk, positive fuel, and bounded width");
const here = import.meta.dir, target = join(here, dir);
const okModule = existsSync(join(target, "OkB.lean")) ? "OkB" : "Ok";
const mod = (file: string) => `host.sim.template.${dir.replaceAll("/", ".")}.${file}`;
const summary = `MicroK${chunk}`, original = `sim_chunk ${name} ${ok} ${chunk}`;
const owners = readdirSync(target).filter(f => /^K\d+(?:_\d+)?\.lean$/.test(f)).flatMap(file => {
  const text = readFileSync(join(target, file), "utf8");
  const line = text.split("\n").find(l => l === original || l.startsWith(`boot_rfl ${name}.k${chunk} from `));
  return line || text.split("\n").includes(`import ${mod(summary)}`)
    ? [{ file, text, line }] : [];
});
if (owners.length !== 1) throw new Error(`expected one owner of ${original}, found ${owners.length}`);
const owner = owners[0];
if (!owner) throw new Error("missing chunk owner");
const head = (imports: string[]) => imports.map(i => `import ${i}\n`).join("") +
  "set_option Elab.async false\nset_option maxRecDepth 1000000\nset_option maxHeartbeats 0\n" +
  "namespace Host.Load.Run.Tpl\nopen Host.Ts Host.Ts.Sim\n\n";
const put = (file: string, text: string) => writeFileSync(join(target, file + ".lean"), text + "\nend Host.Load.Run.Tpl\n");
const count = Math.ceil(fuel / width), sizes = Array.from({ length: count }, (_, j) => Math.min(width, fuel - j * width));
const prefix = (j: number) => `${name}.microK${chunk}_${j}`;
const state = (j: number) => j < 0 ? `${name}.s${chunk}` : `${prefix(j)}.s1`;
const server = (j: number) => j < 0 ? `${name}.S${chunk}` : `${prefix(j)}.S1`;
for (let j = 0; j < count; j++) {
  const imports = j === 0 ? [mod(`H${Math.floor(chunk / 32)}`), mod(okModule), bounded ? "host.sim.template.BoundedFlat" : phased ? "host.sim.template.FlatPhases" : flat ? "host.sim.template.FlatMicro" : "host.sim.template.MicroCandidate"]
    : [mod(`${summary}_${j - 1}`)];
  const ending = j === count - 1 ? ` ending ${name}.s${chunk + 1}, ${name}.S${chunk + 1}` : "";
  const command = flat ? j === count - 1 ? "sim_flat_boot_finish" : "sim_flat_boot_candidate"
    : boot ? j === count - 1 ? "sim_micro_boot_finish" : "sim_micro_boot_candidate"
    : j === count - 1 ? "sim_micro_finish" : bridge ? "sim_micro_bridge_candidate" : "sim_micro_candidate";
  const call = phased && j !== count - 1 ?
    `${bounded ? "sim_bounded_boot_choose" : "sim_flat_boot_choose"} ${prefix(j)} ${name}.F from ${state(j - 1)}, ${server(j - 1)} steps ${sizes[j]}\n` +
    `sim_flat_boot_check ${prefix(j)} ${name}.F ${ok} from ${state(j - 1)}, ${server(j - 1)} steps ${sizes[j]}\n` :
    `${command} ${prefix(j)} ${name}.F ${ok} from ${state(j - 1)}, ${server(j - 1)} steps ${sizes[j]}${ending}\n`;
  put(`${summary}_${j}`, head(imports) +
    (j === 0 ? `kernel_rfl ${name}.microFuel${chunk} : nth? ${name}.ks ${chunk} = some ${fuel}\n\n` : "") +
    call);
}
let proof = `${prefix(0)}.checked`, consumed = sizes[0];
if (consumed === undefined) throw new Error("empty split");
for (let j = 1; j < count; j++) {
  const k = sizes[j];
  if (k === undefined) throw new Error(`missing split ${j}`);
  proof = `runOk_trans ${name}.F ${ok} ${consumed} ${k} ${state(-1)} ${state(j - 1)} ${state(j)} ` +
    `${server(-1)} ${server(j - 1)} ${server(j)} (${proof}) ${prefix(j)}.checked`;
  consumed += k;
}
put(summary, head([mod(`${summary}_${count - 1}`)]) +
  `theorem ${name}.k${chunk} : runOk ${name}.F ${ok} ${fuel} ${state(-1)} ${server(-1)} =\n` +
  `    some (${name}.s${chunk + 1}, ${name}.S${chunk + 1}) :=\n  ${proof}\n`);
if (owner.line)
  writeFileSync(join(target, owner.file), `import ${mod(summary)}\n` +
    owner.text.split("\n").filter(line => line !== owner.line).join("\n"));
console.log(`${name}: chunk ${chunk}, ${fuel} steps: generated ${count} bounded links; final link uses existing endpoint`);
