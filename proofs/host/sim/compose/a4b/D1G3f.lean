import host.sim.compose.PostGlue
import host.sim.compose.a4b.PostEntry
import host.sim.compose.CallLink
import host.sim.template.a4pre_post_head.S0Eq
import host.sim.template.a4pre_post_head.Run
import host.sim.template.a4pre_post_head.Good
import host.sim.template.a4pre_post_selector.States
import host.sim.template.a4pre_post_call.Facts
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
set_option Elab.async false
namespace Host.Ts.Sim.Compose.D1First
open Host.Ts Host.Ts.Sim Host.Ts.Sim.Full Host.Ts.Sim.Prefill Host.Ts.Sim.Template Host.Route
open Host.Ts.Sim.Lin Host.Ts.Sim.Lin.Cls Host.Load.Run.Tpl

theorem postStartEq : (PRE_post_head.s0 : St FF.S) = D1Body.s155 := by
  have hf : fullSetTokens D1Body.s155.ffi [.ref 1, .ref 2] = D1Body.s155.ffi :=
    (congrArg (fullSetTokens D1Body.s155.ffi) PRE_post_head.old_tokens.symm).trans
      (SetupCommon.fullSetTokens_self D1Body.s155.ffi)
  have h : (PRE_post_head.s0 : St FF.S) = D1Body.s155.setFfi
      (fullSetTokens D1Body.s155.ffi [.ref 1, .ref 2]) := PRE_post_head.s0_tok
  exact h.trans ((congrArg (fun z : FF.S => (D1Body.s155 : St FF.S).setFfi z) hf).trans rfl)

kernel_rfl postBridge : bridgeOf PRE_post_head.s1.ffi = bridgeOf PRE_post_head.s0.ffi
kernel_rfl postTop : noRetBlock PRE_post_head.s1 = true

noncomputable def g3f_first (NB T : Nat) (tk : Nat → Nat) (cap : Nat) (hcap : 4096 ≤ cap)
    (hcap2 : cap ≤ 4096 + 1593835520) :
    GluePiece FF [final_cold.r0] (fun _ => returnedSavedCut NB T tk)
      (fun i => Post.cut NB T tk cap i.L PRE_post_head.s1 PRE_post_head.S1) where
  m := []
  n := 809
  O := []
  chk _ _ := rfl
  ok r hr i hi _ := by
    obtain rfl := List.mem_singleton.mp hr
    have hL : i.L = 1 := by
      obtain ⟨_, x, hx, hq⟩ := hi
      simp only [final_cold.r0, InBox, QOk, Inst.get, Lin.Aff.eval, dot] at hx hq
      omega
    have hi0 : (bridgeOf PRE_post_head.s0.ffi).active = false := by
      have h1 : (bridgeOf PRE_post_head.s1.ffi).active = false := by
        rw [← PRE_post_selector.s0_eq]
        exact PRE_post_call.selector_inactive
      exact (congrArg (fun b : Host.Mlx.FfiAne.St => b.active) postBridge.symm).trans h1
    have hstep : CutStep (Post.cut NB T tk cap 1 PRE_post_head.s0 PRE_post_head.S0)
        (Post.cut NB T tk cap 1 PRE_post_head.s1 PRE_post_head.S1) 809 :=
      Post.cut_step fun _ _ => Post.glue (by omega)
        (fun bs => congrFun PRE_post_head.typedAccepted0 bs) PRE_post_head.typedRun postTop
        (fun _ hν => PRE_post_head.good hν) hi0 postBridge
    have hconv : CutConv (returnedSavedCut NB T tk)
        (Post.cut NB T tk cap 1 PRE_post_head.s0 PRE_post_head.S0) := by
      refine (toPostEntry NB T tk postStartEq PRE_post_head.s0_tab
        (fun e he => List.all_eq_true.mp PRE_post_head.fresh10 e he)).trans ?_
      rintro x ⟨π, hπ, γ, hr, hb⟩ hB
      exact ⟨x, rfl, rfl, ⟨π, hπ, γ, hr, hb.mono hcap⟩, hB⟩
    show CutStep (returnedSavedCut NB T tk) (Post.cut NB T tk cap i.L PRE_post_head.s1 PRE_post_head.S1) 809
    rw [hL]
    exact hstep.convL hconv

end Host.Ts.Sim.Compose.D1First
