// Continue a checked 32-step seed with full-world native candidates and exact runOk links.
// This writes proof sources only; the caller builds each link before choosing the next one.
// Usage: bun genNativeMicro.ts <dir> <source> <family> <fuel> <seed-plan.json> [from=2]
import { readFileSync, writeFileSync } from "node:fs";
import { join } from "node:path";

const [dirArg, sourceArg, familyArg, fuelArg, planArg, fromArg = "2"] = process.argv.slice(2);
if (!dirArg || !sourceArg || !familyArg || !fuelArg || !planArg)
  throw new Error("usage: genNativeMicro.ts <dir> <source> <family> <fuel> <seed-plan.json> [from=2]");
if (!/^[A-Za-z0-9_]+(?:\/[A-Za-z0-9_]+)*$/.test(dirArg) ||
    !/^[A-Za-z_][A-Za-z0-9_.]*$/.test(sourceArg) || !/^[A-Za-z_][A-Za-z0-9_]*$/.test(familyArg))
  throw new Error("invalid generated directory or Lean name");
const fuel = Number(fuelArg), from = Number(fromArg), width = 32;
if (!Number.isSafeInteger(fuel) || fuel <= width || !Number.isSafeInteger(from) ||
    from < 1 || from >= Math.ceil(fuel / width))
  throw new Error("expected fuel > 32 and an existing seed before the requested first link");
const parsed: unknown = JSON.parse(readFileSync(planArg, "utf8"));
if (!parsed || typeof parsed !== "object" || Array.isArray(parsed)) throw new Error("expected a plan object");
const plan = parsed as Record<string, unknown>;
const nat = (v: unknown): v is number => typeof v === "number" && Number.isSafeInteger(v) && v >= 0;
const pairs = (v: unknown, second: (x: unknown) => boolean): boolean =>
  Array.isArray(v) && v.every(p => Array.isArray(p) && p.length === 2 && nat(p[0]) && second(p[1]));
if (!Array.isArray(plan.frames) || !plan.frames.every(nat) || !pairs(plan.wide, x => typeof x === "string") ||
    !pairs(plan.lens, nat) || !pairs(plan.baseVals, nat) || !pairs(plan.vars, x => typeof x === "string") ||
    plan.accept !== "jsjxs" || !nat(plan.D0))
  throw new Error("expected explicit frames/wide/lens/baseVals/vars, jsjxs acceptance, and a natural D0");
const dir = dirArg, source = sourceArg, family = familyArg;
const target = join(import.meta.dir, dir);
const mod = (f: string) => `host.sim.template.${dir.replaceAll("/", ".")}.${f}`;
const head = (imports: string[]) => imports.map(i => `import ${i}\n`).join("") +
  "set_option Elab.async false\nset_option maxRecDepth 1000000\nset_option maxHeartbeats 0\n" +
  "namespace Host.Load.Run.Tpl\n";
const put = (f: string, text: string) => writeFileSync(join(target, f + ".lean"), text + "\nend Host.Load.Run.Tpl\n");
for (let j = from; j < Math.ceil(fuel / width); j++) {
  const before = width * j, count = Math.min(width, fuel - before), after = before + count;
  const prev = `${family}${before}`, name = `${family}${after}`;
  const candidatePlan: Record<string, unknown> = {
    stop: `steps:${count}`, stages: [], compact: false, isolate: false, bridges: [],
    frames: plan.frames, wide: plan.wide, lens: plan.lens, baseVals: plan.baseVals,
    vars: plan.vars, accept: plan.accept, D0: plan.D0,
  };
  if (plan.loadP !== undefined) candidatePlan.loadP = plan.loadP;
  const leanPlan = JSON.stringify(JSON.stringify(candidatePlan));
  put(`Link${j}States`, head([mod(j === 1 ? "Check32" : `Link${j - 1}`)]) +
    `\nnoncomputable def ${name}.chooserSrv : Host.Ts.SSrv := ⟨${prev}.S1.tab, []⟩\n` +
    `kernel_rfl ${name}.chooser_tab : ${name}.chooserSrv.tab = ${prev}.originalS1.tab\n\n` +
    "set_option interpreter.prefer_native true in\n" +
    `tpl_chain ${name} from ${prev}.s1, ${name}.chooserSrv : ${leanPlan} («world» := full)\n`);
  put(`Link${j}`, head([mod(`Link${j}States`)]) + "open Host.Ts Host.Ts.Sim\n" +
    `host_stream_state ${name} 0\nhost_stream_state ${name} 1\n\n` +
    `noncomputable def ${name}.originalS1 : SSrv :=\n` +
    `  ⟨${name}.S1.tab, ${prev}.originalS1.oracle.drop ${name}.O.length⟩\n\n` +
    `kernel_rfl ${name}.start_exact : ${name}.s0 = ${prev}.s1\n` +
    `kernel_rfl ${name}.tab_exact : ${name}.S0.tab = ${prev}.originalS1.tab\n` +
    `kernel_rfl ${name}.oracle_prefix : ${prev}.originalS1.oracle.take ${name}.O.length = ${name}.O\n\n` +
    `kernel_rfl ${name}.checked :\n` +
    `  runOk ${source}.F ${source}.okB0 ${count} ${prev}.s1 ${prev}.originalS1 =\n` +
    `    some (${name}.s1, ${name}.originalS1)\n\n` +
    `theorem ${name}.prefix_checked :\n` +
    `    runOk ${source}.F ${source}.okB0 ${after} ${source}.s0 ${source}.S0 =\n` +
    `      some (${name}.s1, ${name}.originalS1) :=\n` +
    `  runOk_trans ${source}.F ${source}.okB0 ${before} ${count}\n` +
    `    ${source}.s0 ${prev}.s1 ${name}.s1\n` +
    `    ${source}.S0 ${prev}.originalS1 ${name}.originalS1\n` +
    `    ${prev}.${j === 1 ? "checked" : "prefix_checked"} ${name}.checked\n`);
}
console.log(`generated native links ${from}–${Math.ceil(fuel / width) - 1}; exact source/oracle retained, final prefix ${fuel}`);
