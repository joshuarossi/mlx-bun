// Release chooser contexts before checking, then bisect only if still necessary.
import { readFileSync, writeFileSync } from "node:fs";
import { basename, dirname, join } from "node:path";

const [path] = process.argv.slice(2);
if (!path?.startsWith("proofs/host/sim/template/") || !path.endsWith(".lean"))
  throw Error("usage: bun refineMicro.ts proofs/host/sim/template/.../Micro*.lean");
const text = readFileSync(path, "utf8");
const old = text.match(/^sim_flat_boot_(candidate|finish) (\S+) (\S+) (\S+) from (\S+), (\S+) steps (\d+)(?: ending (\S+), (\S+))?$/m);
const phased = text.match(/^sim_flat_boot_check (\S+) (\S+) (\S+) from (\S+), (\S+) steps (\d+)$/m);
const match = old ?? (phased ? [phased[0], "candidate", ...phased.slice(1)] : null);
if (!match) throw Error("expected one generated flat candidate or finish");
const [, kind, p, f, ok, s, c, fuel, endS, endC] = match;
const n = Number(fuel);
const bounded = /^sim_bounded_boot_choose /m.test(text);
const phaseImport = "import host.sim.template.BoundedFlat\n";
const choose = (p: string, s: string, c: string, n: number) =>
  `sim_bounded_boot_choose ${p} ${f} from ${s}, ${c} steps ${n}\n` +
  `sim_flat_boot_check ${p} ${f} ${ok} from ${s}, ${c} steps ${n}`;
if (kind === "candidate" && !bounded) {
  const updated = old ? text.replace(old[0], choose(p!, s!, c!, n)) :
    text.replace("sim_flat_boot_choose ", "sim_bounded_boot_choose ");
  writeFileSync(path, (text.includes(phaseImport) ? "" : phaseImport) + updated);
  console.log(`${path}: bounded chooser caches, ${n} steps and original names preserved`);
  process.exit(0);
}
if (n < 2 || kind === "finish" && (!endS || !endC)) throw Error("link cannot be bisected");
const left = Math.floor(n / 2), right = n - left;
const file = basename(path, ".lean"), dir = dirname(path);
const mod = (file: string) => join(dir, file).replace(/^proofs\//, "").replaceAll("/", ".");
const imports = [...new Set([...text.matchAll(/^import (\S+)$/gm)].map(m => m[1]!).concat("host.sim.template.BoundedFlat"))];
const head = (imports: string[]) => imports.map(i => `import ${i}\n`).join("") +
  "set_option Elab.async false\nset_option maxRecDepth 1000000\nset_option maxHeartbeats 0\n" +
  "namespace Host.Load.Run.Tpl\nopen Host.Ts Host.Ts.Sim\n";
const put = (name: string, value: string) => writeFileSync(join(dir, name + ".lean"), value + "\nend Host.Load.Run.Tpl\n");
const a = `${p}_left`, b = `${p}_right`;
const retained = [...text.matchAll(/^kernel_rfl .*$/gm)].map(m => m[0]).join("\n");
put(file + "a", head(imports) + retained + "\n" + choose(a, s!, c!, left));
put(file + "b", head([mod(file + "a")]) + (kind === "finish" ?
  `sim_flat_boot_finish ${b} ${f} ${ok} from ${a}.s1, ${a}.S1 steps ${right} ending ${endS}, ${endC}` :
  choose(b, `${a}.s1`, `${a}.S1`, right)));
put(file, head([mod(file + "b")]) +
  `noncomputable def ${p}.s1 := ${b}.s1\nnoncomputable def ${p}.S1 : SSrv := ${b}.S1\n` +
  `theorem ${p}.checked : runOk ${f} ${ok} ${n} ${s} ${c} = some (${p}.s1, ${p}.S1) :=\n` +
  `  runOk_trans ${f} ${ok} ${left} ${right} ${s} ${a}.s1 ${b}.s1 ${c} ${a}.S1 ${b}.S1 ${a}.checked ${b}.checked`);
console.log(`${path}: split ${n} into ${left} + ${right}, original names preserved`);
