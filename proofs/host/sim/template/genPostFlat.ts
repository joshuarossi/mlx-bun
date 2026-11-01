// Write the checked modules of a flat POST stretch (`tpl_chain` with no stage cuts): boundaries, one run per glue chunk,
// the source link, the size and length bridges' facts and the oracle check. Everything is checked at PostHeadSmall.ok.
// usage: bun genPostFlat.ts <dir under template/> <Name> <start state> <start server> <start module> [--spread <chunk>:<steps before it>]
import { readFileSync, writeFileSync } from "node:fs";
import { join } from "node:path";
const argv = process.argv.slice(2);
let spread: { chunk: number; pre: number } | undefined;
{ const i = argv.indexOf("--spread"); if (i >= 0) { const [chunk, pre] = argv[i + 1]!.split(":").map(Number); spread = { chunk: chunk!, pre: pre! }; argv.splice(i, 2); } }
const [dir, name, start, startSrv, startMod] = argv;
if (!dir || !name || !start || !startSrv || !startMod) throw Error("usage: genPostFlat.ts dir Name startState startServer startModule [--spread chunk:pre]");
const stream = join(process.env.HOST_STREAM_DIR ?? "", `Host.Load.Run.Tpl.${name}`);
const seg = JSON.parse(readFileSync(join(stream, "seg.json"), "utf8"));
const T1 = Number(seg.T1), bridges: any[] = seg.bridges ?? [];
const root = join(import.meta.dir, dir), mod = (f: string) => `host.sim.template.${dir.replaceAll("/", ".")}.${f}`;
const head = (imports: string[], open = "Host.Ts Host.Ts.Sim") => [...new Set(imports)].map(i => `import ${i}\n`).join("") +
  `set_option Elab.async false\nset_option maxRecDepth 1000000\nset_option maxHeartbeats 0\nnamespace Host.Load.Run.Tpl\nopen ${open}\n\n`;
const put = (file: string, text: string) => writeFileSync(join(root, file + ".lean"), text + "\nend Host.Load.Run.Tpl\n");
const OK = "host.sim.template.a4pre_post_head.Small", ok = "PostHeadSmall.ok";
const s = (i: number) => `${name}.s${i}`, S = (i: number) => `${name}.S${i}`;
put("H0", head([mod("States")], "Host.Ts") + Array.from({ length: T1 + 1 }, (_, i) => `host_stream_state ${name} ${i}\n`).join(""));
// chunks entered or left by a bridge are the bridge's facts, not glue runs
const bridgeChunks = new Map<number, any>();
for (const b of bridges) { bridgeChunks.set(b.ia - 1, b); bridgeChunks.set(b.ia, b); }
const glue = Array.from({ length: T1 }, (_, i) => i).filter(i => !bridgeChunks.has(i));
const fuel = (k: number) => `((nth? ${name}.ks ${k}).getD 0)`;
for (const k of glue) {
  if (spread?.chunk === k) continue;
  put(`K${k}`, head([mod("H0"), OK, "host.sim.template.BootEq", "host.sim.Chunk"]) +
    `boot_rfl ${name}.run${k} from ${s(k)} to ${s(k + 1)} :\n` +
    `  (fun bytes : List Byte => runOk ${name}.F (${ok} bytes) ${fuel(k)} ${s(k)} ${S(k)}) =\n` +
    `    fun _ => some (${s(k + 1)}, ${S(k + 1)})`);
}
// A chunk holding the array literal's spread of the framed prompt: the run to it, the spread's own steps (`Disp.step_id_spread`,
// `step_spread_close`: a target-side frame, no `runOk`), and the run after it at the acceptance framing the new array.
if (spread) {
  const k = spread.chunk, tail = `${name}Tail`, p = name;
  const plan = JSON.parse(readFileSync(join(root, "plan.json"), "utf8"));
  const sub = JSON.stringify(JSON.stringify({ ...plan, stop: `steps:${spread.pre}`, cap: spread.pre, bridges: [] }));
  put("TailStates", head([mod("H0"), "host.sim.template.ReturnLiteral"], "Host.Ts") +
    `bridge_empty ${tail}.input from ${s(k)}\nserver_literal ${tail}.inputSrv := (⟨${S(k)}.tab, []⟩ : SSrv)\nset_option interpreter.prefer_native true in\n` +
    `tpl_chain ${tail} from ${tail}.input, ${tail}.inputSrv : ${sub} («world» := Host.Load.Run.Tpl.PRE_first_tail_x15_r0.nativeWorld)\n`);
  const step = (a: string, A: string) => `(interpS (step FF ${a}).run ${A}).getD (${a}, ${A})`;
  put("TailData", head([mod("TailStates"), "host.sim.template.a4pre_pl_tail.SimOk", "host.load.boot.World"], "Host.Ts Host.Ts.Sim Host.Ts.Sim.Full Host.Ts.Sim.Template") +
    `host_stream_state ${tail} 0\nhost_stream_state ${tail} 1\n\n` +
    `noncomputable def ${p}.spPre := ${tail}.s1\nnoncomputable def ${p}.spPreSrv := ${tail}.S1\n` +
    `noncomputable def ${p}.spOpen := ${p}.spPre.ret (.obj 2665)\n` +
    `noncomputable def ${p}.spIdPair : St FF.S × SSrv :=\n  ${step(`${p}.spOpen`, `${p}.spPreSrv`)}\n` +
    `noncomputable def ${p}.spId := ${p}.spIdPair.1\nnoncomputable def ${p}.spIdSrv := ${p}.spIdPair.2\n` +
    `noncomputable def ${p}.spClosePair : St FF.S × SSrv :=\n  ${step(`${p}.spId`, `${p}.spIdSrv`)}\n` +
    `noncomputable def ${p}.spClose := ${p}.spClosePair.1\nnoncomputable def ${p}.spCloseSrv := ${p}.spClosePair.2\n` +
    `noncomputable def ${p}.spAfterPair : St FF.S × SSrv :=\n  ${step(`${p}.spClose`, `${p}.spCloseSrv`)}\n` +
    `noncomputable def ${p}.spAfter := ${p}.spAfterPair.1\nnoncomputable def ${p}.spAfterSrv := ${p}.spAfterPair.2\n` +
    `noncomputable def ${p}.cacheArray := ${p}.spClose.next\n`);
  const rest = `host.sim.template.BootEq`;
  put("Tail", head([mod("TailData"), OK, rest, "host.sim.Chunk"], "Host.Ts Host.Ts.Sim Host.Ts.Sim.Full Host.Ts.Sim.Template") +
    `boot_rfl ${p}.tailStart from ${tail}.s0 to ${s(k)} : ${tail}.s0 = ${s(k)}\n` +
    `boot_rfl ${p}.checkedTail from ${s(k)} to ${p}.spPre :\n  (fun bytes : List Byte => runOk ${name}.F (${ok} bytes) ${spread.pre} ${s(k)} ${S(k)}) =\n    fun _ => some (${p}.spPre, ${p}.spPreSrv)\n` +
    `kernel_rfl ${p}.spPreNoOracle : ${p}.spPreSrv.oracle = []\n`);
  put("TailRest", head([mod("TailData"), rest, "host.sim.Chunk"], "Host.Ts Host.Ts.Sim Host.Ts.Sim.Full Host.Ts.Sim.Template") +
    `noncomputable def ${p}.restFuel : Nat := ${fuel(k)} - ${spread.pre} - 4\n` +
    `kernel_rfl ${p}.checkedRest :\n  (fun bytes : List Byte => runOk ${name}.F (PostHeadSim.ok bytes [2673435, ${p}.cacheArray]) ${p}.restFuel ${p}.spAfter ${p}.spAfterSrv) =\n    fun _ => some (${s(k + 1)}, ${S(k + 1)})\n` +
    `kernel_rfl ${p}.acceptedRest :\n  (fun bytes : List Byte => PostHeadSim.ok bytes [2673435, ${p}.cacheArray] ${p}.spAfter ${p}.spAfterSrv) = fun _ => true\n`);
}
put("Origin", head([mod("H0"), startMod, "host.sim.full.Rel"]) +
  `kernel_rfl ${name}.s0_eq : ${s(0)} = ${start}\n` +
  `kernel_rfl ${name}.s0_tab : ${S(0)}.tab = ${startSrv}.tab\n` +
  `kernel_rfl ${name}.ffi_exact : ${name}.F = Host.Ts.Sim.Full.FF`);
for (const [j, b] of bridges.entries()) {
  const ia = Number(b.ia), p = `${name}.b${j}`;
  if (b.kind === "size") {
    put(`Size${j}`, head([mod("Origin"), "host.sim.template.a4pre_d1_body.SizeAt", "host.sim.template.BootEq", "host.load.boot.World"], "Host.Ts Host.Ts.Sim Host.Ts.Sim.Full Host.Ts.Sim.Template") +
      `noncomputable def ${p}.tys : List Val :=\n  match Disp.sizeParts ${s(ia)} with\n  | some (_, _, _, _, _, tys, _) => tys\n  | none => []\n\n` +
      `noncomputable def ${p}.args : List Val :=\n  match Disp.sizeParts ${s(ia)} with\n  | some (_, _, _, _, _, _, args) => args\n  | none => []\n\n` +
      `kernel_rfl ${p}.parts : Disp.sizeParts ${s(ia)} =\n  some (${b.fsym}, ${b.ta}, ${b.nf}, chars!"${b.name}", chars!"${b.rt}", ${p}.tys, ${p}.args)\n` +
      `kernel_rfl ${p}.args_ok : Disp.sizeArgsOk ${s(ia)} = true\n` +
      `kernel_rfl ${p}.sym : Host.Mlx.Ffi.symOf chars!"${b.name}" = some .arraySize\n` +
      `kernel_rfl ${p}.mlx : Host.Load.isMlx chars!"${b.name}" = true\n` +
      `kernel_rfl ${p}.pay : nameEq chars!"${b.name}" Host.Mlx.FfiAne.payloadName = false\n\n` +
      `noncomputable def ${p}.decoded :=\n  interpS (decodeArgs ${name}.F ${s(ia)} ${p}.tys ${p}.args).run ${S(ia)}\n` +
      `noncomputable def ${p}.as : List Arg :=\n  match ${p}.decoded with | some (some xs, _) => xs | _ => []\n` +
      `noncomputable def ${p}.server : SSrv :=\n  match ${p}.decoded with | some (_, S) => S | none => ${S(ia)}\n\n` +
      `boot_rfl ${p}.decode from ${s(ia)} to ${s(ia)} :\n  interpS (decodeArgs ${name}.F ${s(ia)} ${p}.tys ${p}.args).run ${S(ia)} =\n    some (some ${p}.as, ${p}.server)\n` +
      `boot_rfl ${p}.pre from ${s(ia)} to ${s(ia)} :\n  sizePreB loopVB ${p}.server ${s(ia)}.ffi ${p}.as = true\n` +
      `theorem ${p}.inactive : (bridgeOf ${s(ia)}.ffi).active = false := Host.Load.Boot.replay_active _\n` +
      `kernel_rfl ${p}.bridge : bridgeOf ${s(ia + 1)}.ffi = bridgeOf ${s(ia)}.ffi\n` +
      `boot_rfl ${p}.step from ${s(ia - 1)} to ${s(ia)} :\n  interpS (step ${name}.F ${s(ia - 1)}).run ${S(ia - 1)} = some (${s(ia)}, ${S(ia)})\n` +
      `boot_rfl ${p}.runS from ${s(ia)} to ${s(ia + 1)} :\n  interpS (Disp.sizeS ${name}.F ${s(ia)}).run ${S(ia)} = some (${s(ia + 1)}, ${S(ia + 1)})\n` +
      `kernel_rfl ${p}.top : Host.Ts.Sim.Compose.noRetBlock ${s(ia)} = true\n`);
  } else if (b.kind === "len") {
    put(`Len${j}`, head([mod("Origin"), "host.sim.compose.PrefillLen", "host.sim.template.BootEq", "host.load.boot.World"], "Host.Ts Host.Ts.Sim Host.Ts.Sim.Full Host.Ts.Sim.Template") +
      `noncomputable def ${p}.obj : Obj := (${s(ia)}.obj? ${b.arr}).getD ⟨.ordinary, .null, [], [], true⟩\n` +
      `noncomputable def ${p}.fs := ${s(ia)}.stack.drop 1\n\n` +
      `kernel_rfl ${p}.ctl : ${s(ia)}.ctl = .ret (.obj ${b.arr})\n` +
      `kernel_rfl ${p}.stack : ${s(ia)}.stack = .e (.member kLength false) :: ${p}.fs\n` +
      `kernel_rfl ${p}.objGet : ${s(ia)}.obj? ${b.arr} = some ${p}.obj\n` +
      `kernel_rfl ${p}.kind : ${p}.obj.kind = .array []\n` +
      `boot_rfl ${p}.patch from ${s(ia)} to ${s(ia + 1)} : Bridge.lenPatch ${s(ia)} ${S(ia)} (${b.entry}) = (${s(ia + 1)}, ${S(ia + 1)})\n` +
      `boot_rfl ${p}.enter from ${s(ia - 1)} to ${s(ia)} : interpS (step ${name}.F ${s(ia - 1)}).run ${S(ia - 1)} = some (${s(ia)}, ${S(ia)})\n` +
      `kernel_rfl ${p}.live : isHalt ${s(ia - 1)}.ctl = false\n` +
      `kernel_rfl ${p}.top : Host.Ts.Sim.Compose.noRetBlock ${s(ia)} = true\n` +
      `theorem ${p}.inactive : (bridgeOf ${s(ia)}.ffi).active = false := Host.Load.Boot.replay_active _\n` +
      `kernel_rfl ${p}.bridge : bridgeOf ${s(ia + 1)}.ffi = bridgeOf ${s(ia)}.ffi\n`);
  } else throw Error(`bridge ${b.kind}: not generated here`);
}
const boundaries = [0, ...glue.filter(k => spread?.chunk !== k).flatMap(k => [k, k + 1])].filter((v, i, a) => a.indexOf(v) === i);
const groups = boundaries.map(i => `kernel_rfl ${name}.accepted${i} :\n  (fun bytes : List Byte => ${ok} bytes ${s(i)} ${S(i)}) = fun _ => true\n`);
put("Accept", head([mod("H0"), OK]) + groups.join(""));
put("Good", head([mod("H0"), "host.sim.template.a4pre_pl_head.Good"]) +
  `kernel_rfl ${name}.good_checked :\n  (fun ν : Nat → F64 => PRE_pl_head.singletonGoodB ν ${S(0)}.oracle) = fun _ => true\n\n` +
  `theorem ${name}.good {ν : Nat → F64} (hν : ν 10 = F64.ofNat 1) : Good ν ${S(0)}.oracle :=\n` +
  `  PRE_pl_head.singletonGoodB_sound hν (congrFun ${name}.good_checked ν)\n`);
console.log(`${dir}: T1 ${T1}, glue chunks ${glue.join(",")}, bridges ${bridges.map(b => `${b.kind}@${b.ia}`).join(",") || "none"}`);
