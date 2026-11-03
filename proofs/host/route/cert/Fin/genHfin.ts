// bun genHfin.ts <Tag> <fd chain> <end> <tok> <L> <fd namespace> <fd module dir> <box json [[j, value], ...]>
// A literal-row class's `hfin`: its final forward's return (`<fd namespace>.returnCut`) to `memFin`, from `hfinV` and its certificate.
import { dirname, join } from "path";
const [Tag, fd, end, tok, Ls, ns, mod, boxJ] = process.argv.slice(2);
if (!Tag || !fd || !end || !tok || !Ls || !ns || !mod || !boxJ) throw new Error("usage");
const L = Number(Ls);
const box: [number, number][] = JSON.parse(boxJ);
const root = dirname(dirname(import.meta.path));
const T = `PRE_${fd}`;
const field: Record<number, string> = { 9: "promptValue", 10: "rowValue", 11: "offsetValue", 12: "rowOne", 16: "capValue" };
const cases = (body: (j: number, v: number) => string, ind = "    ") => box.map(([j, v]) => `${ind}by_cases h${j} : j = ${j}
${ind}· subst h${j}
${body(j, v).split("\n").map(l => ind + l.slice(4)).join("\n")}`).join("\n") + `\n${ind}simp [${box.map(([j]) => `Ne.symm h${j}`).join(", ")}] at hg\n`;
const s = `import host.route.cert.Fin.${Tag}.Cert
import host.sim.compose.a4b.${mod}.Forward
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
set_option autoImplicit false
namespace Host.Route.Cert.Fin.${Tag}
open Host.Load Host.Load.Extract Host.Load.Program Host.Load.Run.Full Host.Load.Run.Tpl
open Host.Mlx Host.Mlx.GlueStep Host.Mlx.FfiEval Host.Mlx.SimGraph Host.Ts
open Inference Inference.Contracts.Mlx Inference.Models.Qwen
open Host.Ts.Sim (SegInst)
open Host.Ts.Sim.Full (FF mlxOf)
open Host.Route.PrefGraph Host.Route.Cert.Fin
open Host.Ts.Sim.Compose (NTrack)

/-! # The ${Tag} class's final forward, at its return -/

${box.map(([j, v]) => `theorem nu${j} : nuV vars ${L} ${j} = ${v} := by decide`).join("\n")}

theorem inBox : InBox box (nuV vars ${L}) := by
  intro j l h hg
  unfold Box.get box at hg
${cases((j) => `      simp at hg
      rw [nu${j}, ← hg.1, ← hg.2]
      exact ⟨Int.le_refl _, Int.le_refl _⟩`, "  ")}
theorem lastRows_eq {π : List Nat} (h : 1 ≤ π.length) : Host.Ts.Sim.Compose.${ns}.lastRows π = [π.getD (π.length - 1) 0] := by
  obtain ⟨ρ, b, rfl⟩ : ∃ ρ b, π = ρ ++ [b] := by
    rcases List.eq_nil_or_concat π with e | ⟨ρ, b, e⟩
    · subst e; simp at h
    · exact ⟨ρ, b, by rw [e, List.concat_eq_append]⟩
  simp [Host.Ts.Sim.Compose.${ns}.lastRows]

variable {C : M1Max.Contract} (P : MlxPrefillContract C) (KR : RouteKernelContract C) (NE : NeuralEngine)
  (net : Host.Mlx.SimGraph.Ref.AneNet) (env : FfiEval.Env InKey) {π : List Nat}

/-- **The ${Tag} class's final forward**: its return holds the reference's step through the forward. -/
theorem hfin (leaves : Leaves code env.weights) (typed : TypedCheckpoint env.weights)
    (hpre : ∀ tab, ∃ s, Host.Mlx.SimGraph.Ref.prefillAt P KR NE KR.inPlace net env π tab = some s ∧
      List.Forall₂ (Host.Mlx.SimGraph.Mach.StagePre (π.length - 1))
        (stageWeights (weights (firstValues P.toMlxContract KR.toKernelContract env tab))) s.hs)
    (hL : π.length = ${L})
    (Cr : Nat → List (Option Nat × Option Nat)) (hCr : Cr π.length = finCert.ps) (Kept : Nat → List (Nat × Nat))
    (hKept : ∀ q ∈ Kept π.length, q.1 < finCert.cert.length ∧ certAt finCert.cert q.1 = q.2) (Kn : Nat → Nat) (hKn : Kn π.length = 4010)
    {NB T : Nat} {tk : Nat → Nat} {cap H N : Nat} (hNB : 15235 ≤ NB) {x y : SegInst FF}
    (hy : (Host.Ts.Sim.Compose.${ns}.returnCut NB T tk π cap H N).R y ${T}.s${end} ⟨${T}.S${end}.tab, []⟩)
    (htr : NTrack x y) (L : Nat)
    (hm : memExit P KR NE net env π Cr L x) : memFin P KR NE net env π Kept Kn L y := by
  obtain ⟨K0, hr, hb, hip, -⟩ := hy
  obtain ⟨Pm, hP, r0⟩ := hr.ffi.1
  have hmr : Host.Ts.Sim.G.MR Pm NB y.M ${T}.S${end}.tab.length native (mlxOf y.t.ffi) := r0.load.mlx
  have hband : Pm.NL = Pm.N0 := by rcases hP with rfl | ⟨k, -, -, rfl⟩ <;> rfl
  have hE : (Pm.E : Int) ≤ 5554869888 := by
    rcases hP with rfl | ⟨k, -, -, rfl⟩ <;> exact (by decide : ((131072 : Nat) : Int) ≤ 5554869888)
  have hrope := hmr.bigFixHi 5554869888 hE (by decide)
  have hlast := lastRows_eq (π := π) (by omega)
  have hmem : π.getD (π.length - 1) 0 ∈ π := by
    rw [List.getD_eq_getElem?_getD, List.getElem?_eq_getElem (by omega : π.length - 1 < π.length), Option.getD_some]
    exact List.getElem_mem _
  refine hfinV P KR NE net env leaves typed hpre finCert finCert_below hNB (by omega) (by omega) (hL ▸ inBox) Cr hCr Kept hKept
    Kn hKn hmr hband hrope ?_ (fun tab hC i e h => hC.val (hr.srv.num i e h)) ?_ (by have := hb.vocab _ hmem; omega)
    htr.server htr.map htr.nodes htr.tokens L hm
  · intro j l h hg
    rw [hL]
    unfold Box.get box at hg
${cases((j) => `      rw [nu${j}, hb.${field[j]}, hL]
      rfl`)}
  · intro tab hC
    have h := (hip.grow (Host.Mlx.Ffi.NGrow.refl _) hC).2
    rw [hlast] at h
    show HostInt32 _ _ (y.M.node ${tok}) _ _
    simpa using h

end Host.Route.Cert.Fin.${Tag}
`;
await Bun.write(join(root, "Fin", Tag, "Hfin.lean"), s);
const ck = join(root, "../../../check.ts");
let c = await Bun.file(ck).text();
const f = `host/route/cert/Fin/${Tag}/Hfin.lean`;
if (!c.includes(`"${f}"`)) c = c.replace(`  "host/route/PostTail.lean",\n`, `  "host/route/PostTail.lean",\n  "${f}",\n`);
await Bun.write(ck, c);
console.log(f);
