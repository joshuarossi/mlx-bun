// Write the checked modules of a flat POST stretch (`tpl_chain` with no stage cuts): boundaries, one run per glue chunk,
// the source link, the size and length bridges' facts and the oracle check. Everything is checked at PostOk.ok.
// usage: bun genPostFlat.ts <dir under template/> <Name> <start state> <start server> <start module> [--spread <chunk>:<steps before it>:<token refs at the chunk, comma-separated>[:<the forwarded array's refs>]] [--fast]
// --fast: a row: checked at `PostOk.okR` (its convolutions small at the row count), each glue chunk at the fast table (`runOkS` at `PostOk.okRN`).
import { readFileSync, writeFileSync } from "node:fs";
import { join } from "node:path";
const argv = process.argv.slice(2);
let spread: { chunk: number; pre: number; tokens: number[]; forwarded: number[] } | undefined;
{ const i = argv.indexOf("--spread"); if (i >= 0) { const [chunk, pre, tok, fwd] = argv[i + 1]!.split(":"); spread = { chunk: Number(chunk), pre: Number(pre), tokens: tok!.split(",").filter(Boolean).map(Number), forwarded: (fwd ?? "").split(",").filter(Boolean).map(Number) }; argv.splice(i, 2); } }
const noGood = argv.includes("--no-good"); if (noGood) argv.splice(argv.indexOf("--no-good"), 1);
const fast = argv.includes("--fast"); if (fast) argv.splice(argv.indexOf("--fast"), 1);
const [dir, name, start, startSrv, startMod] = argv;
if (!dir || !name || !start || !startSrv || !startMod) throw Error("usage: genPostFlat.ts dir Name startState startServer startModule [--spread chunk:pre:tokens] [--no-good]");
const stream = join(process.env.HOST_STREAM_DIR ?? "", `Host.Load.Run.Tpl.${name}`);
const seg = JSON.parse(readFileSync(join(stream, "seg.json"), "utf8"));
const T1 = Number(seg.T1), bridges: any[] = seg.bridges ?? [];
const root = join(import.meta.dir, dir), mod = (f: string) => `host.sim.template.${dir.replaceAll("/", ".")}.${f}`;
const head = (imports: string[], open = "Host.Ts Host.Ts.Sim") => [...new Set(imports)].map(i => `import ${i}\n`).join("") +
  `set_option Elab.async false\nset_option maxRecDepth 1000000\nset_option maxHeartbeats 0\nnamespace Host.Load.Run.Tpl\nopen ${open}\n\n`;
const put = (file: string, text: string) => writeFileSync(join(root, file + ".lean"), text + "\nend Host.Load.Run.Tpl\n");
const OK = fast ? "host.sim.template.PostOkFast" : "host.sim.template.PostOk", ok = fast ? "PostOk.okR" : "PostOk.ok";
const s = (i: number) => `${name}.s${i}`, S = (i: number) => `${name}.S${i}`;
// boundary pages of 32 states, each importing the last
const page = (i: number) => mod(`H${Math.floor(i / 32)}`);
for (let j = 0; j <= Math.floor(T1 / 32); j++) put(`H${j}`, head([j === 0 ? mod("States") : mod(`H${j - 1}`)], "Host.Ts") +
  Array.from({ length: T1 + 1 }, (_, i) => i).filter(i => Math.floor(i / 32) === j).map(i => `host_stream_state ${name} ${i}\n`).join(""));
// chunks entered or left by a bridge are the bridge's facts, not glue runs
const bridgeChunks = new Map<number, any>();
for (const b of bridges) { bridgeChunks.set(b.ia - 1, b); bridgeChunks.set(b.ia, b); }
const glue = Array.from({ length: T1 }, (_, i) => i).filter(i => !bridgeChunks.has(i));
const fuel = (k: number) => `((nth? ${name}.ks ${k}).getD 0)`;
for (const k of glue) {
  if (spread?.chunk === k) continue;
  if (fast) { put(`K${k}`, head([page(k + 1), "host.sim.template.PostOkFast", "host.sim.template.BootEq", "host.sim.Chunk"]) +
    `boot_rfl ${name}.run${k}F from ${s(k)} to ${s(k + 1)} :\n` +
    `  runOkS ${name}.F PostOk.okRN ${fuel(k)} ${s(k)} ${S(k)} =\n` +
    `    some (${s(k + 1)}, ${S(k + 1)})\n\n` +
    `theorem ${name}.run${k} :\n` +
    `  runOk ${name}.F ${ok} ${fuel(k)} ${s(k)} ${S(k)} =\n` +
    `    some (${s(k + 1)}, ${S(k + 1)}) :=\n` +
    `  (runOkS_eq ${name}.F PostOk.okRN_ok _ _ _).symm.trans ${name}.run${k}F`); continue; }
  put(`K${k}`, head([page(k + 1), OK, "host.sim.template.BootEq", "host.sim.Chunk"]) +
    `boot_rfl ${name}.run${k} from ${s(k)} to ${s(k + 1)} :\n` +
    `  runOk ${name}.F ${ok} ${fuel(k)} ${s(k)} ${S(k)} =\n` +
    `    some (${s(k + 1)}, ${S(k + 1)})`);
}
// A chunk holding the array literal's spread of the framed prompt: the run to it, the spread's own steps (`Disp.step_id_spread`,
// `step_spread_close`: a target-side frame, no `runOk`), and the run after it at the acceptance framing the new array.
// Two chooser chains give every state literal, so `boot_rfl` never replays the bridge: to the spread, then its 4 steps one by one.
if (spread) {
  const k = spread.chunk, tail = `${name}Tail`, st = `${name}Spread`, p = name;
  const plan = JSON.parse(readFileSync(join(root, "plan.json"), "utf8"));
  const lit = (o: any) => JSON.stringify(JSON.stringify(o));
  const chain = (c: string, from: string, fromSrv: string, o: any) =>
    `bridge_empty ${c}.input from ${from}\nserver_literal ${c}.inputSrv := (\u27E8${fromSrv}.tab, []\u27E9 : SSrv)\nset_option interpreter.prefer_native true in\n` +
    `tpl_chain ${c} from ${c}.input, ${c}.inputSrv : ${lit({ ...plan, startTokens: spread!.tokens, bridges: [], ...o })} (\u00ABworld\u00BB := Host.Load.Run.Tpl.PRE_first_tail_x15_r0.nativeWorld)\n`;
  put("TailStates", head([page(k), "host.sim.template.ReturnLiteral"], "Host.Ts") + chain(tail, s(k), S(k), { stop: `steps:${spread.pre}`, cap: spread.pre }));
  put("TailData", head([mod("TailStates")], "Host.Ts") + `host_stream_state ${tail} 0\nhost_stream_state ${tail} 1\n`);
  put("SpreadStates", head([mod("TailData"), "host.sim.template.ReturnLiteral"], "Host.Ts") + chain(st, `${tail}.s1`, `${tail}.S1`, { stop: "steps:4", cap: 4, chunk: 1 }));
  put("SpreadData", head([mod("SpreadStates"), "host.sim.template.PostOk"], "Host.Ts Host.Ts.Sim Host.Ts.Sim.Full Host.Ts.Sim.Template") +
    [0, 1, 2, 3, 4].map(i => `host_stream_state ${st} ${i}\n`).join("") + "\n" +
    `noncomputable def ${p}.spPre := ${st}.s0\nnoncomputable def ${p}.spPreSrv := ${st}.S0\n` +
    `noncomputable def ${p}.spOpen := ${st}.s1\nnoncomputable def ${p}.spOpenSrv := ${st}.S1\n` +
    `noncomputable def ${p}.spId := ${st}.s2\nnoncomputable def ${p}.spIdSrv := ${st}.S2\n` +
    `noncomputable def ${p}.spClose := ${st}.s3\nnoncomputable def ${p}.spCloseSrv := ${st}.S3\n` +
    `noncomputable def ${p}.spAfter := ${st}.s4\nnoncomputable def ${p}.spAfterSrv := ${st}.S4\n` +
    `noncomputable def ${p}.cacheArray := ${p}.spClose.next\n`);
  const facts = ["host.sim.template.BootEq", "host.sim.Chunk", "host.load.boot.World"];
  const op = "Host.Ts Host.Ts.Sim Host.Ts.Sim.Full Host.Ts.Sim.Template";
  const stepFact = (n: string, a: string, A: string, b: string, B: string) =>
    `boot_rfl ${p}.${n} from ${a} to ${b} : interpS (step ${name}.F ${a}).run ${A} = some (${b}, ${B})\n`;
  put("Tail", head([mod("SpreadData"), OK, ...facts], op) +
    `kernel_rfl ${p}.tailStart : ${tail}.s0 = ${s(k)}\n` +
    `kernel_rfl ${p}.spreadStart : ${st}.s0 = ${tail}.s1\n` +
    `kernel_rfl ${p}.tailSrv : ${st}.S0 = ${tail}.S1\n` +
    `boot_rfl ${p}.checkedTail from ${s(k)} to ${tail}.s1 :\n  runOk ${name}.F ${ok} ${spread.pre} ${s(k)} ${S(k)} =\n    some (${tail}.s1, ${tail}.S1)\n` +
    `kernel_rfl ${p}.acceptedSpPre :\n  ${ok} ${p}.spPre ${p}.spPreSrv = true\n`);
  put("TailSteps", head([mod("SpreadData"), ...facts], op) +
    stepFact("spInto", `${p}.spPre`, `${p}.spPreSrv`, `${p}.spOpen`, `${p}.spOpenSrv`) +
    stepFact("spOpenStep", `${p}.spOpen`, `${p}.spOpenSrv`, `${p}.spId`, `${p}.spIdSrv`) +
    stepFact("spIdStep", `${p}.spId`, `${p}.spIdSrv`, `${p}.spClose`, `${p}.spCloseSrv`) +
    stepFact("spCloseStep", `${p}.spClose`, `${p}.spCloseSrv`, `${p}.spAfter`, `${p}.spAfterSrv`) +
    `noncomputable def ${p}.spEnv : Env := match ${p}.spOpen.stack with\n  | .l (.spread _ _ env) :: _ => env\n  | _ => []\n` +
    `noncomputable def ${p}.spFs := ${p}.spOpen.stack.drop 1\n` +
    `noncomputable def ${p}.spExpr : Expr := match ${p}.spOpen.stack with\n  | .l (.spread _ (.spread e :: _) _) :: _ => e\n  | _ => .id []\n` +
    `noncomputable def ${p}.spName : Name := match ${p}.spId.ctl with\n  | .ev (.id n) _ => n\n  | _ => []\n` +
    `noncomputable def ${p}.spCell : Nat := (lookupEnv ${p}.spName ${p}.spEnv).getD 0\n` +
    `noncomputable def ${p}.fwdObj : Obj :=\n  (${p}.spClose.obj? 2673435).getD \u27E8.ordinary, .null, [], [], true\u27E9\n\n` +
    `kernel_rfl ${p}.spCtl : ${p}.spOpen.ctl = .ret (.obj 2665)\n` +
    `kernel_rfl ${p}.spStack : ${p}.spOpen.stack =\n  .l (.spread [] [.spread ${p}.spExpr] ${p}.spEnv) :: ${p}.spFs\n` +
    `kernel_rfl ${p}.spIdCtl : ${p}.spId.ctl = .ev (.id ${p}.spName) ${p}.spEnv\n` +
    `kernel_rfl ${p}.spLookup : lookupEnv ${p}.spName ${p}.spEnv = some ${p}.spCell\n` +
    `kernel_rfl ${p}.spCellVal : ${p}.spId.cell? ${p}.spCell = some (some (.obj 2673435))\n` +
    `kernel_rfl ${p}.spCloseCtl : ${p}.spClose.ctl = .ret (.obj 2673435)\n` +
    `kernel_rfl ${p}.spCloseStack : ${p}.spClose.stack =\n  .l (.spread [] [] ${p}.spEnv) :: ${p}.spFs\n` +
    `kernel_rfl ${p}.spFwd : ${p}.spClose.obj? 2673435 = some ${p}.fwdObj\n` +
    `kernel_rfl ${p}.spFwdKind : ${p}.fwdObj.kind = .array [${spread.forwarded.map(r => `.num (.ref ${r})`).join(", ")}]\n` +
    `kernel_rfl ${p}.spCellNoW : wideP ${p}.spCell = none\n` +
    `kernel_rfl ${p}.spNewNoW : wideP ${p}.cacheArray = none\n` +
    `kernel_rfl ${p}.spNewNoPrompt : Nat.beq 2665 ${p}.cacheArray = false\n` +
    `kernel_rfl ${p}.spNewNoFwd : Nat.beq 2673435 ${p}.cacheArray = false\n` +
    `kernel_rfl ${p}.spRoom : Nat.blt (${p}.spClose.next + margin) Host.Ts.Sim.bound = true\n` +
    `kernel_rfl ${p}.spNoOracle : ${p}.spCloseSrv.oracle = []\n` +
    `kernel_rfl ${p}.spPreNoOracle : ${p}.spPreSrv.oracle = []\n` +
    `kernel_rfl ${p}.spAfterNoOracle : ${p}.spAfterSrv.oracle = []\n` +
    `theorem ${p}.spInactive : (bridgeOf ${p}.spOpen.ffi).active = false := Host.Load.Boot.replay_active _\n` +
    `kernel_rfl ${p}.spBridge : bridgeOf ${p}.spAfter.ffi = bridgeOf ${p}.spOpen.ffi\n`);
  put("TailRest", head([mod("SpreadData"), "host.sim.template.BootEq", "host.sim.Chunk"], op) +
    `noncomputable def ${p}.restFuel : Nat := ${fuel(k)} - ${spread.pre} - 4\n` +
    `boot_rfl ${p}.checkedRest from ${p}.spAfter to ${s(k + 1)} :\n  runOk ${name}.F (PostOk.okF [2673435, ${p}.cacheArray]) ${p}.restFuel ${p}.spAfter ${p}.spAfterSrv =\n    some (${s(k + 1)}, ${S(k + 1)})\n` +
    `kernel_rfl ${p}.acceptedRest :\n  PostOk.okF [2673435, ${p}.cacheArray] ${p}.spAfter ${p}.spAfterSrv = true\n`);
}
put("Origin", head([mod("H0"), startMod, "host.sim.full.Rel"]) +
  `kernel_rfl ${name}.s0_eq : ${s(0)} = ${start}\n` +
  `kernel_rfl ${name}.s0_tab : ${S(0)}.tab = ${startSrv}.tab\n` +
  `kernel_rfl ${name}.ffi_exact : ${name}.F = Host.Ts.Sim.Full.FF`);
for (const [j, b] of bridges.entries()) {
  const ia = Number(b.ia), p = `${name}.b${j}`;
  if (b.kind === "size") {
    put(`Size${j}`, head([page(ia + 1), mod("Origin"), "host.sim.template.a4pre_d1_body.SizeAt", "host.sim.template.BootEq", "host.load.boot.World"], "Host.Ts Host.Ts.Sim Host.Ts.Sim.Full Host.Ts.Sim.Template") +
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
    put(`Len${j}`, head([page(ia + 1), mod("Origin"), "host.sim.compose.PrefillLen", "host.sim.template.BootEq", "host.load.boot.World"], "Host.Ts Host.Ts.Sim Host.Ts.Sim.Full Host.Ts.Sim.Template") +
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
const groups = boundaries.map(i => `kernel_rfl ${name}.accepted${i} : ${ok} ${s(i)} ${S(i)} = true\n`);
if (groups.length <= 64) put("Accept", head([page(T1), OK]) + groups.join(""));
else for (let j = 0; j * 50 < groups.length; j++) put(`Accept${j}`, head([page(boundaries[Math.min(groups.length - 1, (j + 1) * 50 - 1)]!), OK]) + groups.slice(j * 50, (j + 1) * 50).join(""));
if (!noGood) put("Good", head([mod("H0"), "host.sim.template.a4pre_pl_head.Good"]) +
  `kernel_rfl ${name}.good_checked :\n  (fun ν : Nat → F64 => PRE_pl_head.singletonGoodB ν ${S(0)}.oracle) = fun _ => true\n\n` +
  `theorem ${name}.good {ν : Nat → F64} (hν : ν 10 = F64.ofNat 1) : Good ν ${S(0)}.oracle :=\n` +
  `  PRE_pl_head.singletonGoodB_sound hν (congrFun ${name}.good_checked ν)\n`);
console.log(`${dir}: T1 ${T1}, glue chunks ${glue.join(",")}, bridges ${bridges.map(b => `${b.kind}@${b.ia}`).join(",") || "none"}`);
