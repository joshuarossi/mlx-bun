import host.sim.template.a4pre_d1_prompt_identity.Dispatch
import host.sim.template.a4pre_d1_prompt_identity.Facts
import host.sim.compose.a4b.SetupD1CleanReads
set_option Elab.async false
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
namespace Host.Ts.Sim.Compose.SetupD1PromptIdentity
open Host.Ts Host.Ts.Sim Host.Ts.Sim.Full Host.Ts.Sim.Prefill
open Host.Ts.Sim.Template Host.Load.Run.Prompt Host.Load.Run.Tpl Host.Route

/-- The original checked segments, with one additional context field. -/
theorem ldCut_forward_prompt {NB T : Nat} {tk : Nat → Nat} {fw : List Val}
    (hctx : 1 + T ≤ 262144) :
    CutStep (loadedCut NB T tk 1 fw) (forwardPromptCut NB T tk fw) 3011 :=
  ((ldCut_next_values hctx (by decide) (by decide)).trans toForwardValuesInput).cast rfl rfl rfl

/-- Construct the fixed caller input on the same witness as saved cells and frames.
The separate clean producer supplies only target/server facts through run determinism. -/
theorem producer (input : Fin 248320) {T : Nat} {tk : Nat → Nat} (hctx : 1 + T ≤ 262144)
    (hload : (ldCut 15235 setupP wideP (ldStT [] []) T tk 1).Inv
      (ldStT [natV input.val] (machReads T tk)) (routeServer T tk)) :
    ∃ x : SegInst FF,
      runC FF 3011 (ldStT [natV input.val] (machReads T tk)) (routeServer T tk) = some (x.t, x.C) ∧
      (SetupD1SavedCells.forwardSavedInputCut 15235 T tk).R x D1Call.s1 ⟨D1Call.S1.tab, []⟩ ∧
      (SetupD1SavedCells.forwardSavedInputCut 15235 T tk).B x ∧
      SetupD1Input.InputAt [input.val] (x.M.node 15235) x.t x.C ∧
      PromptAt [natV input.val] x ∧
      Host.Mlx.Ffi.NGrow (mlxOf (ldStT [natV input.val] (machReads T tk)).ffi) (mlxOf x.t.ffi) ∧
      CSrv.Le (routeServer T tk) x.C ∧
      (mlxOf (ldStT [natV input.val] (machReads T tk)).ffi).tokens.length = (mlxOf x.t.ffi).tokens.length ∧
      (mlxOf x.t.ffi).items = .nil := by
  obtain ⟨t', C', hrun, x, ht, hc, hr, hb, hp⟩ :=
    ldCut_forward_prompt hctx _ _ (concrete_loaded_initial [natV input.val] hload)
  have runP : runC FF 3011 (ldStT [natV input.val] (machReads T tk)) (routeServer T tk) =
      some (x.t, x.C) := by
    rw [ht, hc]
    exact hrun
  obtain ⟨xC, runC', _, _, hg, hle, hqueue, hitems⟩ :=
    SetupD1CleanReads.producer [input.val] hctx hload
  have target : (x.t, x.C) = (xC.t, xC.C) := Option.some.inj (runP.symm.trans runC')
  have sameT : x.t = xC.t := congrArg Prod.fst target
  have sameC : x.C = xC.C := congrArg Prod.snd target
  refine ⟨x, runP, hr, hb, inputAt input hr hp, hp, ?_, ?_, ?_, ?_⟩
  · rw [sameT]
    exact hg
  · rw [sameC]
    exact hle
  · rw [sameT]
    exact hqueue
  · rw [sameT]
    exact hitems

end Host.Ts.Sim.Compose.SetupD1PromptIdentity
