import host.sim.compose.a4b.GraphOrdMachine
import host.sim.compose.a4b.GraphOrdEnd
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
set_option Elab.async false
set_option autoImplicit false

namespace Host.Ts.Sim.Compose.DECGraph.Ord
open _root_.Host.Ts _root_.Host.Ts.Sim _root_.Host.Ts.Sim.Prefill
open _root_.Host.Ts.Sim.Full _root_.Host.Ts.Sim.Template
open _root_.Host.Load _root_.Host.Load.Extract _root_.Host.Load.Program _root_.Host.Load.Run.Full
open _root_.Host.Mlx _root_.Host.Mlx.GlueStep _root_.Host.Mlx.FfiEval _root_.Host.Mlx.SimGraph
open _root_.Host.Mlx.SimGraph.Iter
open _root_.Host.Mlx.SimGraph.Mach (MRef MRefDecodes)
open _root_.Host.Ts.Sim.Lin.Cls
open Inference Inference.Contracts.Mlx Inference.Models.Qwen

theorem ordinary_interior {L i : Nat} (h : DecKind.Holds .ord L i) :
    L + i + 2 < capL (L + i + 1) := by
  unfold DecKind.Holds at h
  unfold capL
  omega

variable {C : M1Max.Contract} (M : MlxContract C) (K : KernelContract C) (env : FfiEval.Env InKey)

/-- Every iteration selected for this actual ordinary chain satisfies its graph branch and bounds. -/
theorem caseTpl_selected (b0 : Host.Mlx.FfiAne.St) (NB L T i : Nat) (tk : Nat → Nat)
    (hNB : 15235 ≤ NB) (hctx : L + T ≤ 262144) (hs : DecSel T L tk .ord i) :
    CaseTplAtM M K env (fullProjFb b0 NB) Host.Load.Run.Prompt.addrPrompt DEC.inputs L
      Host.Load.Run.Tpl.DEC_ord.s11.ffi Host.Load.Run.Tpl.DEC_ord.S1D.tab
      (certAt choice.cert Tpl.Ordinary.tokenNode) choice.outputs i NB := by
  exact caseTpl M K env b0 NB L i hNB (by have := hs.1.2.1; omega)
    (ordinary_interior hs.1.2.2)

/-- The unchanged machine-reference loop invariant is preserved by the actual ordinary end. -/
theorem loopG (leaves : Leaves code env.weights) (typed : TypedCheckpoint env.weights)
    (R : MRef) (L : Nat)
    (hdec : MRefDecodes M K (fun table => weights (firstValues M K env table)) R L)
    (b0 : Host.Mlx.FfiAne.St) (NB T i : Nat) (ρ : Nat → F64) (tk : Nat → Nat) (toks : List NumV)
    (q : List Val) (g : GhostP) (hNB : 15235 ≤ NB) (hctx : L + T ≤ 262144)
    (hs : DecSel T L tk .ord i)
    (htk : ∀ table j, j ≤ i + 2 → ∃ cache, R table (L + j) = some (tk (j + 1), cache))
    (htkb : ∀ j, j ≤ i + 2 → tk (j + 1) < 2 ^ 31) :
    LoopGStepGW (liftG (fullWorldFb b0 NB) (GxM M K env DEC.inputs R L)) wideP
      (framesP DEC.s0 q) ((Host.Load.Run.Tpl.DEC_ord.iterEnd NB).toFb b0) g
      (valL ρ T tk L) toks i :=
  loopG_ofAtM M K env (fullProjFb b0 NB) (DEC.startGM b0 NB) g (endGM b0 NB) rfl rfl htk htkb
    (caseFwdAtM_of_tpl M K env (fullProjFb b0 NB) leaves typed hdec
      (weightShapes_first M K env leaves typed) (by omega)
      (caseTpl_selected M K env b0 NB L T i tk hNB hctx hs))

end Host.Ts.Sim.Compose.DECGraph.Ord
