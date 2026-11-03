import host.sim.compose.a4b.FillPost
import host.sim.compose.a4b.pl.VSelector.All
import host.sim.compose.a4b.pl.VCall.All
import host.sim.compose.a4b.pl.VCommon.All
import host.sim.template.a4pre_plvw_selector.Origin
import host.sim.template.a4pre_plvw_call.Origin
import host.sim.template.a4pre_plvw_common.Origin
set_option Elab.async false
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
set_option autoImplicit false
namespace Host.Ts.Sim.Compose.FillPost
open Host.Ts Host.Ts.Sim Host.Ts.Sim.Full Host.Ts.Sim.Prefill Host.Ts.Sim.Template Host.Ts.Sim.Compose.Post
open Host.Load.Run.Tpl

/-! # VW's POST stretch

The wide rows' class from its head's end to its common's, at the final step's chunk. -/

noncomputable def classVW (NB T : Nat) (tk : Nat → Nat) (π : List Nat) (cap nI : Nat) (hcap : cap ≤ 4096 + 1593835520) :
    ClassPre NB T tk π cap nI where
  fr := [2823901]
  sH := PRE_plvw_head.s1
  SH := PRE_plvw_head.S1
  sC := PRE_plvw_common.s1
  SC := PRE_plvw_common.S1
  n := PL.VSelector.N + PL.VCall.N + PL.VCommon.N
  run Tr hT :=
    (((PL.VSelector.all NB T tk cap nI π hcap (fun _ h => PRE_plvw_selector.good h.rowValue) Tr hT).convL
        (idxConv PRE_plvw_selector.s0_eq PRE_plvw_selector.s0_tab)).trans
      ((PL.VCall.all NB T tk cap nI π hcap (fun _ _ => by rw [PRE_plvw_call.empty_oracle]; intro _ hq; cases hq) Tr hT).convL
        (idxConv PRE_plvw_call.s0_eq PRE_plvw_call.s0_tab))).trans
    ((PL.VCommon.all NB T tk cap nI π hcap (fun _ h => PRE_plvw_common.good h.rowValue) Tr hT).convL
      (idxConv PRE_plvw_common.s0_eq PRE_plvw_common.s0_tab))

end Host.Ts.Sim.Compose.FillPost
