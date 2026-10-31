import host.sim.compose.a4b.GraphClearMachine
import host.sim.compose.a4b.GraphClearEnd
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
set_option Elab.async false
set_option autoImplicit false

namespace Host.Ts.Sim.Compose.DECGraph.Clear
open _root_.Host.Ts _root_.Host.Ts.Sim _root_.Host.Ts.Sim.Prefill
open _root_.Host.Ts.Sim.Full _root_.Host.Ts.Sim.Template
open _root_.Host.Load _root_.Host.Load.Extract _root_.Host.Load.Program _root_.Host.Load.Run.Full
open _root_.Host.Mlx _root_.Host.Mlx.GlueStep _root_.Host.Mlx.FfiEval _root_.Host.Mlx.SimGraph
open _root_.Host.Mlx.SimGraph.Iter
open _root_.Host.Mlx.SimGraph.Mach (MRef MRefDecodes)
open _root_.Host.Ts.Sim.Lin.Cls
open Inference Inference.Contracts.Mlx Inference.Models.Qwen

theorem clear_interior {L i : Nat} (h : DecKind.Holds .clear L i) :
    L + i + 2 < capL (L + i + 1) := by
  unfold DecKind.Holds at h
  unfold capL
  omega

theorem start_eq : Host.Load.Run.Tpl.DEC_clear.s0 = DEC.s0 :=
  Host.Load.Run.Tpl.DEC_clear.s0_tok.trans DEC.source.symm

kernel_rfl start_tab_eq : Host.Load.Run.Tpl.DEC_clear.S0.tab = DEC.tab0
kernel_rfl start_PE_eq : Host.Load.Run.Tpl.DEC_clear.PE = DEC.Pw

/-- Start facts transported from the checked common live-token entry. -/
theorem closedStartGM (b0 : Host.Mlx.FfiAne.St) (NB : Nat) :
    StartGM (fullProjFb b0 NB) Host.Load.Run.Prompt.addrPrompt
      Host.Load.Run.Tpl.DEC_clear.PE Host.Load.Run.Tpl.DEC_clear.s0
      Host.Load.Run.Tpl.DEC_clear.S0.tab DEC.inputs := by
  rw [start_eq, start_tab_eq, start_PE_eq]
  exact DEC.startGM b0 NB

variable {C : M1Max.Contract} (M : MlxContract C) (K : KernelContract C) (env : FfiEval.Env InKey)

/-- Every iteration selected for this actual clear chain satisfies its graph branch and bounds. -/
theorem caseTpl_selected (b0 : Host.Mlx.FfiAne.St) (NB L T i : Nat) (tk : Nat → Nat)
    (hNB : 15235 ≤ NB) (hctx : L + T ≤ 262144) (hs : DecSel T L tk .clear i) :
    CaseTplAtM M K env (fullProjFb b0 NB) Host.Load.Run.Prompt.addrPrompt DEC.inputs L
      Host.Load.Run.Tpl.DEC_clear.s11.ffi Host.Load.Run.Tpl.DEC_clear.S1D.tab
      (certAt choice.cert Tpl.Ordinary.tokenNode) choice.outputs i NB := by
  exact caseTpl M K env b0 NB L i hNB (by have := hs.1.2.1; omega)
    (clear_interior hs.1.2.2)

/-- The unchanged machine-reference loop invariant is preserved by the actual clear end. -/
theorem loopG (leaves : Leaves code env.weights) (typed : TypedCheckpoint env.weights)
    (R : MRef) (L : Nat)
    (hdec : MRefDecodes M K (fun table => weights (firstValues M K env table)) R L)
    (b0 : Host.Mlx.FfiAne.St) (NB T i : Nat) (ρ : Nat → F64) (tk : Nat → Nat) (toks : List NumV)
    (q : List Val) (g : GhostP) (hNB : 15235 ≤ NB) (hctx : L + T ≤ 262144)
    (hs : DecSel T L tk .clear i)
    (htk : ∀ table j, j ≤ i + 2 → ∃ cache, R table (L + j) = some (tk (j + 1), cache))
    (htkb : ∀ j, j ≤ i + 2 → tk (j + 1) < 2 ^ 31) :
    LoopGStepGW (liftG (fullWorldFb b0 NB) (GxM M K env DEC.inputs R L)) wideP
      (framesP Host.Load.Run.Tpl.DEC_clear.s0 q) ((Host.Load.Run.Tpl.DEC_clear.iterEnd NB).toFb b0) g
      (valL ρ T tk L) toks i :=
  loopG_ofAtM M K env (fullProjFb b0 NB) (closedStartGM b0 NB) g (endGM b0 NB) rfl rfl htk htkb
    (caseFwdAtM_of_tpl M K env (fullProjFb b0 NB) leaves typed hdec
      (weightShapes_first M K env leaves typed) (by omega)
      (caseTpl_selected M K env b0 NB L T i tk hNB hctx hs))

end Host.Ts.Sim.Compose.DECGraph.Clear
