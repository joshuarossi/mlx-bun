import { readFileSync, writeFileSync } from "node:fs";
import { join } from "node:path";
type Part = { from: number; to: number; fuel: number; next?: number };
type Size = { ia: number; ta: number };
const data = JSON.parse(readFileSync(join(import.meta.dir, "sized-pieces.json"), "utf8")) as {
  steps: number; last: number; bridges: Size[]; segments: Part[];
};
if (data.steps !== 1541184 || data.last !== 635 || data.bridges.length !== 182 || data.segments.length !== 183)
  throw new Error("expected the checked full body partition");
const mod = (f: string) => `host.sim.template.a4pre_d1_body.${f}`;
const head = (...imps: string[]) => imps.map(i => `import ${i}\n`).join("") +
  "set_option Elab.async false\nset_option maxRecDepth 1000000\nset_option maxHeartbeats 0\n" +
  "namespace Host.Load.Run.Tpl\nopen Host.Ts Host.Ts.Sim Host.Ts.Sim.Full Host.Ts.Sim.Template Host.Ts.Sim.Prefill\n" +
  "open Host.Ts.Sim.Lin Host.Ts.Sim.Lin.Cls\n";
const put = (f: string, s: string) => writeFileSync(join(import.meta.dir, f + ".lean"), s + "\nend Host.Load.Run.Tpl\n");
const params = "{NB T : Nat} {tk : Nat → Nat} {π : List Nat} {K0 : Host.Ts.Sim.Ctx} {M0 : Map} {y0 : Host.Mlx.Ffi.St}";
const cut = (i: number) => `D1BodyAdvance.cut NB T tk π K0 M0 y0 D1BodySized.s${i} D1BodySized.S${i}`;
for (const [k, seg] of data.segments.entries()) {
  if (![seg.from, seg.to, seg.fuel].every(x => Number.isSafeInteger(x) && x >= 0)) throw new Error("invalid segment");
  let q = head(mod(`SB${k}`));
  q += `kernel_rfl D1BodySized.fromInactive${k} : (bridgeOf D1BodySized.s${seg.from}.ffi).active = false\n`;
  q += `kernel_rfl D1BodySized.fromTable20Check${k} : decide (20 ≤ D1BodySized.S${seg.from}.tab.length) = true\n`;
  q += `theorem D1BodySized.fromTable20_${k} : 20 ≤ D1BodySized.S${seg.from}.tab.length := of_decide_eq_true D1BodySized.fromTable20Check${k}\n`;
  const b = data.bridges[k];
  if (b) {
    if (![b.ia, b.ta].every(Number.isSafeInteger) || seg.to !== b.ia - 1 || seg.next !== b.ia + 1) throw new Error("bad size cut");
    q += `kernel_rfl D1BodySized.bridgeInto${k} : bridgeOf D1BodySized.s${b.ia}.ffi = bridgeOf D1BodySized.s${seg.from}.ffi\n`;
    q += `kernel_rfl D1BodySized.bridgeOut${k} : bridgeOf D1BodySized.s${b.ia + 1}.ffi = bridgeOf D1BodySized.s${b.ia}.ffi\n`;
    q += `kernel_rfl D1BodySized.sizeTable20Check${k} : decide (20 ≤ D1BodySized.S${b.ia}.tab.length) = true\n`;
    q += `theorem D1BodySized.sizeTable20_${k} : 20 ≤ D1BodySized.S${b.ia}.tab.length := of_decide_eq_true D1BodySized.sizeTable20Check${k}\n`;
    q += `kernel_rfl D1BodySized.sizeOracle${k} : goodEnum final_cold.r0.ps (varsOf final_cold.r0.V [(9, .L)]) D1BodySized.S${b.ia}.oracle = true\n`;
    put(`SQ${k}`, q);
    const idx = k + 1;
    put(`SP${k}`, head(mod(`SQ${k}`), mod("SizeAdvance")) +
      `\ntheorem D1BodySized.piece${k} ${params} :\n` +
      `    CutStep (${cut(seg.from)}) (${cut(b.ia + 1)}) ${seg.fuel + 4} := by\n` +
      `  have h1 := D1BodyAdvance.toCall (NB := NB) (T := T) (tk := tk) (π := π) (K0 := K0) (M0 := M0) (y0 := y0)\n` +
      `    D1BodySized.accepted${k} D1BodySized.segment${k} D1BodySized.acceptedP${idx}\n` +
      `    D1BodySized.haltP${idx} D1BodySized.stepA${idx} D1BodySized.topA${idx}\n` +
      `    D1BodySized.oracle${k} D1BodySized.fromInactive${k} D1BodySized.bridgeInto${k} D1BodySized.fromTable20_${k}\n` +
      `  have h2 := D1BodyAdvance.size (NB := NB) (T := T) (tk := tk) (π := π) (K0 := K0) (M0 := M0) (y0 := y0)\n` +
      `    D1BodySized.sizeA${idx} D1BodySized.sizeArgsA${idx} D1BodySized.sizeSymA${idx}\n` +
      `    D1BodySized.sizeMlxA${idx} D1BodySized.sizePayA${idx} (by decide)\n` +
      `    D1BodySized.sizeDecA${idx} D1BodySized.sizePreA${idx} D1BodySized.patchB${idx}\n` +
      `    D1BodySized.sizeOracle${k} D1BodySized.inactive${idx} D1BodySized.bridgeOut${k} D1BodySized.sizeTable20_${k}\n` +
      "  exact h1.trans h2\n");
  } else {
    q += `kernel_rfl D1BodySized.finalBridge : bridgeOf D1BodySized.s${seg.to}.ffi = bridgeOf D1BodySized.s${seg.from}.ffi\n`;
    q += `kernel_rfl D1BodySized.finalTop : Host.Ts.Sim.Compose.noRetBlock D1BodySized.s${seg.to} = true\n`;
    put(`SQ${k}`, q);
    put(`SP${k}`, head(mod(`SQ${k}`), mod("SizeAdvance")) +
      `\ntheorem D1BodySized.piece${k} ${params} :\n` +
      `    CutStep (${cut(seg.from)}) (${cut(seg.to)}) ${seg.fuel} :=\n` +
      `  D1BodyAdvance.finish D1BodySized.accepted${k} D1BodySized.segment${k}\n` +
      `    D1BodySized.finalTop D1BodySized.oracle${k} D1BodySized.fromInactive${k}\n` +
      `    D1BodySized.finalBridge D1BodySized.fromTable20_${k}\n`);
  }
}
console.log({ pieces: data.segments.length });
