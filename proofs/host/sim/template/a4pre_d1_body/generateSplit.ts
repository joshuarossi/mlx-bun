import { copyFileSync, existsSync, mkdirSync, readFileSync, writeFileSync } from "node:fs";
import { join } from "node:path";

const out = process.argv[2], index = Number(process.argv[3]);
if (!out || !Number.isSafeInteger(index) || index < 0) throw new Error("usage: generateSplit.ts <DEVOUT> <rejected chunk>");
const dir = import.meta.dir, base = "host/sim/template/a4pre_d1_body/";
const manifest = JSON.parse(readFileSync(join(out, "imports.json"), "utf8")) as { modules: { file: string }[] };
const originalFile = base + `SN${index}.lean`;
if (manifest.modules.some(r => r.file === originalFile)) throw new Error("cannot refactor accepted chunk");
const repair = process.argv[4] === "--repair-first-choice";
const archivedOriginal = join(out, "draft-sources", `before-bounded-split-${index}`, `SN${index}.lean`);
const original = readFileSync(repair ? archivedOriginal : join(dir, `SN${index}.lean`), "utf8");
const fuel = Number(original.match(/runOk D1BodySized.F \(D1BodyTrace.checkedOk bs\) (\d+)/)?.[1]);
const data = original.match(/^import (host\.sim\.template\.a4pre_d1_body\.SD\d+)$/m)?.[1];
if (!data || fuel !== 10000) throw new Error("unexpected original input or predicate");
const history = readFileSync(join(out, "builds.jsonl"), "utf8").trim().split("\n").map(s => JSON.parse(s)) as { file: string; code: number; log: string }[];
if (!history.some(r => r.file === originalFile && r.code !== 0 && /memory_exception|OWN_RESOURCE_REJECTION/.test(readFileSync(r.log, "utf8"))))
  throw new Error("bounded split requires recorded resource rejection");
const pre = `D1BodySplit${index}`, stem = `Split${index}`;
const header = "set_option Elab.async false\nset_option maxRecDepth 1000000\nset_option maxHeartbeats 0\nnamespace Host.Load.Run.Tpl\n";
const end = "\nend Host.Load.Run.Tpl\n";
const sizes = [3333, 3333, 3334];
const options = { stop: "steps:3333", stuckStop: false, cap: 4981, stages: [], compact: false, isolate: false,
  frames: [2665, 2673479, 2673484, 2673485], wide: [[4910, ".memo []"]], lens: [[2665, 9], [2673479, 9]],
  baseVals: [[9, 1]], vars: [[9, "L"]], bridges: [], accept: "jsjxs", D0: 4096,
  loadP: [18151, 131072, 1099511627776, 15235, 15235] };
const sources = new Map<string, string>();
sources.set(stem + "States", `import ${data}\n${header}\nnoncomputable def ${pre}.chooserSrv : Host.Ts.SSrv := ⟨D1BodySized.S${index}.tab, []⟩\n\nset_option interpreter.prefer_native true in\ntpl_chain ${pre} from D1BodySized.s${index}, ${pre}.chooserSrv : ${JSON.stringify(JSON.stringify(options))} («world» := full)\n${end}`);
sources.set(stem + "Data", `import host.sim.template.a4pre_d1_body.${stem}States\n${header}open Host.Ts\n\nhost_stream_state ${pre} 0\nhost_stream_state ${pre} 1\nhost_stream_state ${pre} 2\n\n` +
  `noncomputable def ${pre}.originalS1 : SSrv := ⟨${pre}.S1.tab, D1BodySized.S${index}.oracle.drop ${pre}.O.length⟩\n\n` +
  `kernel_rfl ${pre}.start_exact : ${pre}.s0 = D1BodySized.s${index}\n` +
  `kernel_rfl ${pre}.start_tab : ${pre}.S0.tab = D1BodySized.S${index}.tab\n` +
  `kernel_rfl ${pre}.oracle_prefix : ${pre}.O = D1BodySized.S${index}.oracle.take ${pre}.O.length\n${end}`);
sources.set(stem + "States2", `import host.sim.template.a4pre_d1_body.${stem}Data\n${header}\nnoncomputable def ${pre}Second.chooserSrv : Host.Ts.SSrv := ⟨${pre}.S1.tab, []⟩\n\nset_option interpreter.prefer_native true in\ntpl_chain ${pre}Second from ${pre}.s1, ${pre}Second.chooserSrv : ${JSON.stringify(JSON.stringify(options))} («world» := full)\n${end}`);
sources.set(stem + "Data2", `import host.sim.template.a4pre_d1_body.${stem}States2\n${header}open Host.Ts\n\nhost_stream_state ${pre}Second 0\nhost_stream_state ${pre}Second 1\n\n` +
  `noncomputable def ${pre}.s2 := ${pre}Second.s1\n` +
  `noncomputable def ${pre}.originalS2 : SSrv := ⟨${pre}Second.S1.tab, D1BodySized.S${index}.oracle.drop (${pre}.O.length + ${pre}Second.O.length)⟩\n\n` +
  `kernel_rfl ${pre}Second.start_exact : ${pre}Second.s0 = ${pre}.s1\n` +
  `kernel_rfl ${pre}Second.start_tab : ${pre}Second.S0.tab = ${pre}.S1.tab\n` +
  `kernel_rfl ${pre}Second.oracle_prefix : ${pre}Second.O = ${pre}.originalS1.oracle.take ${pre}Second.O.length\n${end}`);
const states = [`D1BodySized.s${index}`, `${pre}.s1`, `${pre}.s2`, `D1BodySized.s${index + 1}`];
const servers = [`D1BodySized.S${index}`, `${pre}.originalS1`, `${pre}.originalS2`, `D1BodySized.S${index + 1}`];
for (let i = 0; i < 3; i++) sources.set(stem + "ABC"[i],
  `import host.sim.template.a4pre_d1_body.${stem}Data${i === 0 ? "" : "2"}\nimport host.sim.template.a4pre_d1_body.TraceStep\n${header}open Host.Ts Host.Ts.Sim\n\n` +
  `kernel_rfl ${pre}.part${i} :\n  (fun bs : List Byte => runOk D1BodySized.F (D1BodyTrace.checkedOk bs) ${sizes[i]} ${states[i]} ${servers[i]}) =\n    fun _ => some (${states[i + 1]}, ${servers[i + 1]})\n\n` +
  `theorem ${pre}.run${i} (bs : List Byte) :\n    runOk D1BodySized.F (D1BodyTrace.checkedOk bs) ${sizes[i]} ${states[i]} ${servers[i]} =\n      some (${states[i + 1]}, ${servers[i + 1]}) := congrFun ${pre}.part${i} bs\n${end}`);
sources.set(`SN${index}`, [0, 1, 2].map(i => `import host.sim.template.a4pre_d1_body.${stem}${"ABC"[i]}`).join("\n") + `\n${header}open Host.Ts Host.Ts.Sim\n\n` +
  `kernel_rfl D1BodySized.fuel${index} : nth? D1BodySized.ks ${index} = some 10000\n\n` +
  `theorem D1BodySized.checked${index} :\n  (fun bs : List Byte => runOk D1BodySized.F (D1BodyTrace.checkedOk bs) 10000 D1BodySized.s${index} D1BodySized.S${index}) =\n    fun _ => some (D1BodySized.s${index + 1}, D1BodySized.S${index + 1}) := by\n  funext bs\n` +
  `  exact runOk_trans D1BodySized.F (D1BodyTrace.checkedOk bs) 3333 6667 ${states[0]} ${states[1]} ${states[3]} ${servers[0]} ${servers[1]} ${servers[3]} (${pre}.run0 bs)\n` +
  `    (runOk_trans D1BodySized.F (D1BodyTrace.checkedOk bs) 3333 3334 ${states[1]} ${states[2]} ${states[3]} ${servers[1]} ${servers[2]} ${servers[3]} (${pre}.run1 bs) (${pre}.run2 bs))\n\n` +
  `theorem D1BodySized.k${index} (bs : List Byte) :\n    runOk D1BodySized.F (D1BodyTrace.checkedOk bs) 10000 D1BodySized.s${index} D1BodySized.S${index} =\n      some (D1BodySized.s${index + 1}, D1BodySized.S${index + 1}) := congrFun D1BodySized.checked${index} bs\n${end}`);
sources.set(stem + "Data", sources.get(stem + "Data")!.replace(`host_stream_state ${pre} 2\n`, ""));
const receipt = join(out, `split${index}-source-rework-r${repair ? 2 : 1}.json`);
if (existsSync(receipt)) throw new Error("split source receipt is frozen");
const archive = join(out, "draft-sources", repair ? `before-bounded-split-repair-${index}` : `before-bounded-split-${index}`);
mkdirSync(archive, { recursive: true });
copyFileSync(join(dir, `SN${index}.lean`), join(archive, `SN${index}.lean`));
const H = (s: string) => new Bun.CryptoHasher("sha256").update(s).digest("hex");
for (const [name, source] of sources) {
  if (manifest.modules.some(r => r.file === base + name + ".lean")) throw new Error("accepted split source");
  if (name !== `SN${index}` && existsSync(join(dir, name + ".lean"))) {
    if (!repair) throw new Error("existing split source");
    copyFileSync(join(dir, name + ".lean"), join(archive, name + ".lean"));
  }
  writeFileSync(join(dir, name + ".lean"), source);
}
writeFileSync(receipt, JSON.stringify({ at: new Date().toISOString(), originalFile,
  reason: "Resource-rejected exact original runOk fact, factored into bounded same-segment checks with original oracle suffixes.",
  originalSourceSha256: H(original), originalFuel: fuel, fuelParts: sizes, endpointChanges: 0, predicateChanges: 0,
  files: [...sources].map(([name, source]) => ({ file: base + name + ".lean", sourceSha256: H(source) })) }, null, 2));
console.log({ index, originalFuel: fuel, fuelParts: sizes, sources: sources.size });
