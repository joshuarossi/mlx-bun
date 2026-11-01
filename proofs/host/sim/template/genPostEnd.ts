// Write a T = 1 POST tail's halting facts: oracle check (Good), Endpoint, Support. Literal values come from a native read of the
// halting state; every one is a kernel check.
// usage: bun genPostEnd.ts <dir> <Name> <end index> eos|plain <heap next> <stats addr> <cache tokens addr>
import { writeFileSync } from "node:fs";
import { join } from "node:path";
const [dir, name, endText, kind, heapText, statsText, cacheText] = process.argv.slice(2);
if (!dir || !name || !endText || (kind !== "eos" && kind !== "plain") || !heapText || !statsText || !cacheText) throw Error("usage: genPostEnd.ts dir Name end eos|plain heap stats cacheTokens");
const e = Number(endText), p = name, s = `${p}.s${e}`, S = `${p}.S${e}`;
const root = join(import.meta.dir, dir), mod = (f: string) => `host.sim.template.${dir.replaceAll("/", ".")}.${f}`;
const head = (imports: string[], open = "Host.Ts Host.Ts.Sim Host.Ts.Sim.Full") => imports.map(i => `import ${i}\n`).join("") +
  `set_option Elab.async false\nset_option maxRecDepth 1000000\nset_option maxHeartbeats 0\nnamespace Host.Load.Run.Tpl\nopen ${open}\n\n`;
const put = (file: string, text: string) => writeFileSync(join(root, file + ".lean"), text + "\nend Host.Load.Run.Tpl\n");
const eos = kind === "eos";
put("Good", head([mod("H0"), "host.sim.LoopArith"], "Host.Ts Host.Ts.Sim") +
  `def ${p}.oracleTail : List Ans :=\n  [⟨.lt, .lit (F64.ofNat 1), .var 0, false⟩,\n   ⟨.lt, .lit (F64.ofNat 1), .var 0, false⟩,\n   ⟨.eq, .lit (F64.ofNat 248044), .var 1, ${eos}⟩]\n\n` +
  `kernel_rfl ${p}.oracle_initial : ${p}.S0.oracle = ${p}.oracleTail\n\n` +
  (eos
    ? `theorem ${p}.good {ν : Nat → F64} (_h10 : ν 10 = F64.ofNat 1)\n    (h0 : ν 0 = F64.ofNat 1) (h1 : ν 1 = F64.ofNat 248044) : Good ν ${p}.S0.oracle := by\n  rw [${p}.oracle_initial]\n  have ht : F64.test .lt (F64.ofNat 1) (ν 0) = false := by rw [h0]; decide +kernel\n  have he : F64.test .eq (F64.ofNat 248044) (ν 1) = true := by rw [h1]; decide +kernel\n`
    : `theorem ${p}.good {ν : Nat → F64} {t : Nat} (ht31 : t < 2 ^ 31) (hne : t ≠ 248044) (_h10 : ν 10 = F64.ofNat 1)\n    (h0 : ν 0 = F64.ofNat 1) (h1 : ν 1 = F64.ofNat t) : Good ν ${p}.S0.oracle := by\n  rw [${p}.oracle_initial]\n  have ht : F64.test .lt (F64.ofNat 1) (ν 0) = false := by rw [h0]; decide +kernel\n  have he : F64.test .eq (F64.ofNat 248044) (ν 1) = false := by\n    rw [h1, test_eq_ofNat 248044 t (by decide) (by omega)]\n    exact decide_eq_false (Ne.symm hne)\n`) +
  `  intro q hq\n  simp only [${p}.oracleTail, List.mem_cons, List.not_mem_nil, or_false] at hq\n  rcases hq with rfl | rfl | rfl\n  · exact ht\n  · exact ht\n  · exact he\n`);
put("Endpoint", head([mod("H0"), "host.sim.world.Route"], "Host.Ts Host.Ts.Sim Host.Ts.Sim.Full Host.Ts.Sim.Template") +
  `kernel_rfl ${p}.halt : ${s}.ctl = .halt (.normal .undef)\nkernel_rfl ${p}.haltB : isHalt ${s}.ctl = true\nkernel_rfl ${p}.stackCount : ${s}.stack.length = 0\n` +
  `kernel_rfl ${p}.nodeCounter : (mlxOf ${s}.ffi).nnext = 17777\nkernel_rfl ${p}.handleCounter : (mlxOf ${s}.ffi).next = 22018\n` +
  `kernel_rfl ${p}.heapCounter : ${s}.next = ${heapText}\nkernel_rfl ${p}.tableCount : ${S}.tab.length = 3415\n` +
  `kernel_rfl ${p}.remainingTokens : (mlxOf ${s}.ffi).tokens = [.ref 2]\nkernel_rfl ${p}.firstRead : (mlxOf ${s}.ffi).items.get 17776 = some (.ref 1)\n` +
  `kernel_rfl ${p}.emission : arrOf ${s} 12504 = ${eos ? "[]" : "[.num (.ref 1)]"}\nkernel_rfl ${p}.emissionCell : ${s}.cell? 2590 = some (some (.obj 12504))\n` +
  `kernel_rfl ${p}.tokenVar : nth? ${S}.tab 1 = some (.var 1)\nkernel_rfl ${p}.generationCell : ${s}.cell? 2589 = some (some (.obj 2673245))\n\n` +
  (eos
    ? `noncomputable def ${p}.statsAddr : Nat :=\n  match ownW ${s} (.obj 2673245) chars!"stats" with\n  | some (.obj w) => w\n  | _ => 0\n\nkernel_rfl ${p}.statsAddr_exact : ${p}.statsAddr = ${statsText}\nkernel_rfl ${p}.stats_actual : ownW ${s} (.obj 2673245) chars!"stats" =\n  some (.obj ${p}.statsAddr)\nkernel_rfl ${p}.stopFinish : ownW ${s} (.obj ${p}.statsAddr) chars!"finishReason" =\n  some (.str chars!"stop")\nkernel_rfl ${p}.generated : ownW ${s} (.obj ${p}.statsAddr) chars!"generatedTokens" =\n  some (natV 1)\nkernel_rfl ${p}.cacheTokens : ownW ${s} (.obj ${p}.statsAddr) chars!"cacheTokens" =\n  some (.obj ${cacheText})\n`
    : `noncomputable def ${p}.stats : Val :=\n  (ownW ${s} (.obj 2673245) chars!"stats").getD .undef\n\nkernel_rfl ${p}.stats_actual : ownW ${s} (.obj 2673245) chars!"stats" = some ${p}.stats\nkernel_rfl ${p}.budgetFinish : ownW ${s} ${p}.stats chars!"finishReason" = none\nkernel_rfl ${p}.generated : ownW ${s} ${p}.stats chars!"generatedTokens" = some (natV 1)\nkernel_rfl ${p}.cacheTokens : ownW ${s} ${p}.stats chars!"cacheTokens" = some (.obj ${cacheText})\n`));
put("Support", head([mod("Endpoint")]) +
  `kernel_rfl ${p}.cacheCell : ${s}.cell? 2586 = some (some (.obj 2672295))\n` +
  `kernel_rfl ${p}.sampledHandleFreed : (mlxOf ${s}.ffi).arrs.get 22016 = some 0\nkernel_rfl ${p}.hiddenHandleFreed : (mlxOf ${s}.ffi).arrs.get 21985 = some 0\n` +
  `kernel_rfl ${p}.hiddenNodeCollected : ((mlxOf ${s}.ffi).nodes.get 17763).isSome = false\nkernel_rfl ${p}.sampledNodePresent : ((mlxOf ${s}.ffi).nodes.get 17776).isSome = true\n`);
console.log(`${dir}: Good, Endpoint, Support (${kind})`);
