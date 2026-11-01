// Write the checked modules of a flat forward chain (`tpl_chain`, no stage cuts, size bridges only) over `FlatFwd`:
// boundaries, each ordinary chunk at the fast table, each stretch and size bridge's facts, the pieces and the run
// `<Name>.fullRun : CutStep (cut … s0 S0) (cut … s<T1> S<T1>) <steps>`, given the book's `FlatFwd.Laws`.
// usage: bun genFlatFwd.ts <dir under template/> <Name> <chunk> <buffer> <view> <box module>
//   <box module> defines `<Name>.ps`, `<Name>.V` and `<Name>.lin : Lin.goodLin <Name>.ps <Name>.V <Name>.O = true`.
import { readFileSync, writeFileSync } from "node:fs";
import { join } from "node:path";
const [dir, name, chunk, buffer, view, boxMod] = process.argv.slice(2);
if (!dir || !name || !chunk || !buffer || !view || !boxMod) throw Error("usage: genFlatFwd.ts dir Name chunk buffer view boxModule");
const stream = join(process.env.HOST_STREAM_DIR ?? "", `Host.Load.Run.Tpl.${name}`);
const seg = JSON.parse(readFileSync(join(stream, "seg.json"), "utf8"));
const plan = JSON.parse(readFileSync(join(import.meta.dir, dir, "plan.json"), "utf8"));
const T1 = Number(seg.T1), steps = Number(seg.steps), bridges: any[] = seg.bridges ?? [], chunkSteps = Number(plan.chunk);
if (seg.stop !== "ret" || !chunkSteps || bridges.some(b => b.kind !== "size")) throw Error("expected a flat forward to its return, size bridges only");
// the chunks: ordinary stretches cut every `chunk` steps; a size bridge's step into the call and its 3 steps
const sizes: number[] = [];
const ordinary = (n: number) => { while (n > 0) { const k = Math.min(n, chunkSteps); sizes.push(k); n -= k; } };
let consumed = 0;
for (const b of bridges) {
  ordinary(b.nA - consumed);
  if (sizes.length !== b.ia - 1) throw Error(`boundary mismatch at the size bridge ${b.ia}: ${sizes.length}`);
  sizes.push(1, 3); consumed = b.nA + 4;
}
ordinary(steps - consumed);
if (sizes.length !== T1 || sizes.reduce((a, b) => a + b, 0) !== steps) throw Error(`incomplete partition: ${sizes.length} chunks, T1 ${T1}`);
const root = join(import.meta.dir, dir), mod = (f: string) => `host.sim.template.${dir.replaceAll("/", ".")}.${f}`;
const head = (imports: string[]) => [...new Set(imports)].map(i => `import ${i}\n`).join("") +
  "set_option Elab.async false\nset_option maxRecDepth 1000000\nset_option maxHeartbeats 0\nnamespace Host.Load.Run.Tpl\n" +
  "open Host.Ts Host.Ts.Sim Host.Ts.Sim.Full Host.Ts.Sim.Template Host.Ts.Sim.Prefill\n\n";
const put = (file: string, text: string) => writeFileSync(join(root, file + ".lean"), text + "\nend Host.Load.Run.Tpl\n");
const s = (i: number) => `${name}.s${i}`, S = (i: number) => `${name}.S${i}`, F = `${name}.F`, fr = `${name}.fr`;
const page = (i: number) => mod(`H${Math.floor(i / 32)}`);
for (let j = 0; j <= Math.floor(T1 / 32); j++) put(`H${j}`, head([j === 0 ? mod("States") : mod(`H${j - 1}`)]) +
  Array.from({ length: T1 + 1 }, (_, i) => i).filter(i => Math.floor(i / 32) === j).map(i => `host_stream_state ${name} ${i}\n`).join(""));
put("Frames", head(["host.sim.template.FlatFwd", boxMod]) +
  `def ${fr} : FlatFwd.Fr := ⟨${chunk}, ${buffer}, ${view}, rfl, rfl⟩\n`);
const frames = mod("Frames");
const special = new Set(bridges.flatMap(b => [b.ia - 1, b.ia]));
for (let i = 0; i < sizes.length; i++) {
  if (special.has(i)) continue;
  put(`K${i}`, head([page(i + 1), frames, "host.sim.template.BootEq", "host.sim.Chunk"]) +
    `boot_rfl ${name}.check${i} from ${s(i)} to ${s(i + 1)} :\n` +
    `  (fun bs : List Byte => runOkS ${F} (${fr}.typedOkN bs) ${sizes[i]} ${s(i)} ${S(i)}) =\n` +
    `    fun _ => some (${s(i + 1)}, ${S(i + 1)})\n\n` +
    `theorem ${name}.k${i} (bs : List Byte) :\n` +
    `    runOk ${F} (${fr}.typedOk bs) ${sizes[i]} ${s(i)} ${S(i)} = some (${s(i + 1)}, ${S(i + 1)}) :=\n` +
    `  (runOkS_eq ${F} (${fr}.typedOkN_ok bs) _ _ _).symm.trans (congrFun ${name}.check${i} bs)`);
}
const lazy = (n: string, a: number, b: number, t: string) => `boot_rfl ${n} from ${s(a)} to ${s(b)} : ${t}\n`;
const accepted = (n: string, i: number) => lazy(n, i, i, `(fun bs : List Byte => ${fr}.typedOk bs ${s(i)} ${S(i)}) = fun _ => true`);
const oracle = (n: string, i: number) => `theorem ${n} : Lin.goodLin ${name}.ps ${name}.V ${S(i)}.oracle = true :=\n  FlatFwd.goodLin_drop ${name}.lin _\n`;
const table20 = (n: string, i: number) => `kernel_rfl ${n}Check : decide (20 ≤ ${S(i)}.tab.length) = true\ntheorem ${n} : 20 ≤ ${S(i)}.tab.length := of_decide_eq_true ${n}Check\n`;
const inactive = (n: string, i: number) => `theorem ${n} : (bridgeOf ${s(i)}.ffi).active = false := Host.Load.Boot.replay_active _\n`;
const params = `{NB T : Nat} {tk : Nat → Nat} {bytes : List Byte} {Book : SegInst FF → Prop} {M0 : Map} {y0 : Host.Mlx.Ffi.St}\n    (L : FlatFwd.Laws ${fr} bytes ${name}.ps ${name}.V Book)`;
const cut = (i: number) => `(FlatFwd.cut ${fr} NB T tk bytes Book M0 y0 ${s(i)} ${S(i)})`;
type Piece = { from: number; to: number; fuel: number };
const pieces: Piece[] = [];
for (let k = 0; k <= bridges.length; k++) {
  const b = bridges[k], from = k === 0 ? 0 : bridges[k - 1].ia + 1, to = b ? b.ia - 1 : T1;
  const fuel = sizes.slice(from, to).reduce((a, x) => a + x, 0);
  let proof = from < to ? `${name}.k${from} bs` : "rfl", n = from < to ? sizes[from]! : 0;
  for (let i = from + 1; i < to; i++) {
    proof = `runOk_trans ${F} (${fr}.typedOk bs) ${n} ${sizes[i]} ${s(from)} ${s(i)} ${s(i + 1)} ${S(from)} ${S(i)} ${S(i + 1)} (${proof}) (${name}.k${i} bs)`;
    n += sizes[i]!;
  }
  put(`Seg${k}`, head([...Array.from({ length: to - from }, (_, j) => mod(`K${from + j}`)), page(b ? b.ia + 1 : T1), frames,
      "host.sim.template.BootEq", "host.sim.Chunk", "host.load.boot.World", "host.sim.template.a4pre_d1_body.SizeAt"]) +
    `theorem ${name}.seg${k} (bs : List Byte) :\n    runOk ${F} (${fr}.typedOk bs) ${fuel} ${s(from)} ${S(from)} = some (${s(to)}, ${S(to)}) := ${proof}\n\n` +
    accepted(`${name}.accepted${k}`, from) + oracle(`${name}.oracle${k}`, from) + table20(`${name}.table${k}`, from) + inactive(`${name}.inactive${k}`, from));
  if (b) {
    const ia = b.ia, p = `${name}.b${k}`;
    put(`Size${k}`, head([mod(`Seg${k}`)]) +
      `noncomputable def ${p}.tys : List Val :=\n  match Disp.sizeParts ${s(ia)} with\n  | some (_, _, _, _, _, tys, _) => tys\n  | none => []\n\n` +
      `noncomputable def ${p}.args : List Val :=\n  match Disp.sizeParts ${s(ia)} with\n  | some (_, _, _, _, _, _, args) => args\n  | none => []\n\n` +
      `kernel_rfl ${p}.parts : Disp.sizeParts ${s(ia)} =\n  some (${b.fsym}, ${b.ta}, ${b.nf}, chars!"${b.name}", chars!"${b.rt}", ${p}.tys, ${p}.args)\n` +
      `kernel_rfl ${p}.args_ok : Disp.sizeArgsOk ${s(ia)} = true\n` +
      `kernel_rfl ${p}.sym : Host.Mlx.Ffi.symOf chars!"${b.name}" = some .arraySize\n` +
      `kernel_rfl ${p}.mlx : Host.Load.isMlx chars!"${b.name}" = true\n` +
      `kernel_rfl ${p}.pay : nameEq chars!"${b.name}" Host.Mlx.FfiAne.payloadName = false\n\n` +
      `noncomputable def ${p}.decoded :=\n  interpS (decodeArgs ${F} ${s(ia)} ${p}.tys ${p}.args).run ${S(ia)}\n` +
      `noncomputable def ${p}.as : List Arg :=\n  match ${p}.decoded with | some (some xs, _) => xs | _ => []\n` +
      `noncomputable def ${p}.server : SSrv :=\n  match ${p}.decoded with | some (_, S) => S | none => ${S(ia)}\n\n` +
      lazy(`${p}.decode`, ia, ia, `\n  interpS (decodeArgs ${F} ${s(ia)} ${p}.tys ${p}.args).run ${S(ia)} =\n    some (some ${p}.as, ${p}.server)`) +
      lazy(`${p}.pre`, ia, ia, `\n  sizePreB loopVB ${p}.server ${s(ia)}.ffi ${p}.as = true`) +
      lazy(`${p}.step`, ia - 1, ia, `\n  interpS (step ${F} ${s(ia - 1)}).run ${S(ia - 1)} = some (${s(ia)}, ${S(ia)})`) +
      lazy(`${p}.runS`, ia, ia + 1, `\n  interpS (Disp.sizeS ${F} ${s(ia)}).run ${S(ia)} = some (${s(ia + 1)}, ${S(ia + 1)})`) +
      accepted(`${p}.acceptedP`, ia - 1) +
      lazy(`${p}.haltP`, ia - 1, ia - 1, `isHalt ${s(ia - 1)}.ctl = false`) +
      lazy(`${p}.top`, ia, ia, `Host.Ts.Sim.Compose.noRetBlock ${s(ia)} = true`) +
      oracle(`${p}.oracle`, ia) + table20(`${p}.table`, ia) + inactive(`${p}.inactive`, ia) +
      `kernel_rfl ${p}.bridgeInto : bridgeOf ${s(ia)}.ffi = bridgeOf ${s(from)}.ffi\n` +
      `kernel_rfl ${p}.bridgeOut : bridgeOf ${s(ia + 1)}.ffi = bridgeOf ${s(ia)}.ffi\n`);
    put(`Piece${k}`, head([mod(`Size${k}`), "host.sim.template.a4pre_d1_body.SizeAt"]) +
      `theorem ${name}.piece${k} ${params} :\n    CutStep ${cut(from)} ${cut(ia + 1)} ${fuel + 4} :=\n` +
      `  (FlatFwd.toCall L ${name}.accepted${k} ${name}.seg${k} ${p}.acceptedP ${p}.haltP ${p}.step ${p}.top\n` +
      `    ${name}.oracle${k} ${name}.inactive${k} ${p}.bridgeInto ${name}.table${k}).trans\n` +
      `  (FlatFwd.size L ${p}.parts ${p}.args_ok ${p}.sym ${p}.mlx ${p}.pay (by decide) ${p}.decode ${p}.pre ${p}.runS\n` +
      `    ${p}.oracle ${p}.inactive ${p}.bridgeOut ${p}.table)\n`);
    pieces.push({ from, to: ia + 1, fuel: fuel + 4 });
  } else {
    put(`Piece${k}`, head([mod(`Seg${k}`)]) +
      `kernel_rfl ${name}.finalBridge : bridgeOf ${s(to)}.ffi = bridgeOf ${s(from)}.ffi\n` +
      lazy(`${name}.finalTop`, to, to, `Host.Ts.Sim.Compose.noRetBlock ${s(to)} = true`) +
      `\ntheorem ${name}.piece${k} ${params} :\n    CutStep ${cut(from)} ${cut(to)} ${fuel} :=\n` +
      `  FlatFwd.finish L ${name}.accepted${k} ${name}.seg${k} ${name}.finalTop\n` +
      `    ${name}.oracle${k} ${name}.inactive${k} ${name}.finalBridge ${name}.table${k}\n`);
    pieces.push({ from, to, fuel });
  }
}
const chain = (ns: string[]) => ns.slice(1).reduce((p, n) => `(${p}).trans ${n}`, ns[0]!);
const groups: Piece[] = [];
for (let a = 0, n = 0; a < pieces.length; a += 16, n++) {
  const ps = pieces.slice(a, a + 16), g = { from: ps[0]!.from, to: ps.at(-1)!.to, fuel: ps.reduce((x, p) => x + p.fuel, 0) };
  put(`Group${n}`, head(ps.map((_, j) => mod(`Piece${a + j}`))) +
    `theorem ${name}.group${n} ${params} :\n    CutStep ${cut(g.from)} ${cut(g.to)} ${g.fuel} :=\n` +
    `  ${chain(ps.map((_, j) => `${name}.piece${a + j} L`))}\n`);
  groups.push(g);
}
if (groups.at(-1)!.to !== T1 || groups.reduce((x, g) => x + g.fuel, 0) !== steps) throw Error("incomplete run");
put("Run", head(groups.map((_, n) => mod(`Group${n}`))) +
  `theorem ${name}.fullRun ${params} :\n    CutStep ${cut(0)} ${cut(T1)} ${steps} :=\n` +
  `  ${chain(groups.map((_, n) => `${name}.group${n} L`))}\n`);
console.log(`${dir}: T1 ${T1}, ${steps} steps, ${sizes.length - special.size} chunks, ${bridges.length} size bridges, ${pieces.length} pieces, ${groups.length} groups`);
