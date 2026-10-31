import host.sim.compose.RouteSteps
import host.sim.compose.Loop
import host.sim.compose.Mach
import host.sim.compose.FullGraph
import host.route.Final
set_option maxRecDepth 1000000
open Host.Load Host.Load.Extract Host.Load.Program Host.Load.Run.Full
open Host.Mlx Host.Mlx.GlueStep Host.Mlx.FfiEval Host.Mlx.SimGraph Host.Ts
open Host.Mlx.SimGraph.Iter (TplInputs)
open Host.Mlx.SimGraph.Mach (refPrompt refPrompt_decodes)
open Inference Inference.Contracts.Mlx Inference.Models.Qwen
open Host.Ts.Sim.Prefill
open Host.Ts.Sim.Full (FF fullWorldXD fullWorldFb fullWorldFb_end mlxOf)
open Host.Route (decCutFb machGx goalM goalC machVal machReads)
open Host.Ts.Sim.Lin.Cls (routeI RouteKind DecKind)
open Host.Ts.Sim (Addr WFrame LoopFramesA LoopBase LoopStartW HaltSegW valL)
namespace Host.Ts.Sim.Compose

/-! Shared graph certificates for the route assembly. -/

variable {C : M1Max.Contract}

section
variable (P : MlxPrefillContract C) (KR : RouteKernelContract C) (NE : NeuralEngine)
  (net : Host.Mlx.SimGraph.Ref.AneNet) (env : FfiEval.Env InKey) (π : List Nat)

/-- **A final chain's graph certificate with the program's caches** (A2's `lgstepC_ofM` with the chain's
`FinalCacheW`): the goal `goalC` at `T`. -/
theorem lastGC_ofM {b0 : Host.Mlx.FfiAne.St} {NB : Nat} {A : Addr} {W : Nat → Option WFrame} {Pd : LoadP}
    {Fr : LoopFramesA A} {s0 : St FF.S} {tab0 : List SymE} {fixA : List Nat} {Itpl : TplInputs} {ρ : Nat → F64}
    {T : Nat} {tk : Nat → Nat} {toks : List NumV} {xs : List Val} {je : Host.Ts.Env}
    (st : StartGM (fullProjFb b0 NB) A Pd s0 tab0 Itpl)
    {hs : HaltSegW (fullWorldFb b0 NB) A W Pd (toks.drop (T - 1)) s0 ((fullWorldFb b0 NB).finalStartW s0 tab0.length)
      (tab0 ++ [.var A.nxt]) xs}
    (lg : LastGM Itpl hs) (hc : FinalCacheW (fullProjFb b0 NB) fixA Itpl je hs) (hAk : A.kvar = 14) (hAn : A.nxt = 17)
    (hT : 2 ≤ T)
    (htk : ∀ tab j, j ≤ T - 1 → ∃ hs, refPrompt P KR NE KR.inPlace net env π tab (π.length + j) = some (tk (j + 1), hs))
    (htkb : ∀ j, j ≤ T - 1 → tk (j + 1) < 2 ^ 31) :
    LastGStepW (Wd := fullWorldFb b0 NB) A (machGx P KR NE net env π NB Itpl) Pd W Fr fixA hs (valL ρ T tk π.length) tk
      (goalC P KR NE net env π NB T je) :=
  (lgstepC_ofM P.toMlxContract KR.toKernelContract env (fullProjFb b0 NB) hs (refPrompt P KR NE KR.inPlace net env π)
    π.length (valL ρ T tk π.length) tk Itpl je htk htkb (by rw [hAk]; rfl) (by rw [hAn]; rfl) hT st.ne st.sread
    st.sfed st.pread st.pfed lg.fA lg.fB lg.pfA lg.pfB st.s0tok lg.sFtok lg.v79 lg.v17 hc).toW (fullProjFb b0 NB)

end

theorem machReads_length (T : Nat) (tk : Nat → Nat) : (machReads T tk).length = T - 2 := by
  simp [machReads]

end Host.Ts.Sim.Compose
