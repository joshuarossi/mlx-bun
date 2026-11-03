import host.sim.compose.a4b.FillPost
import host.sim.compose.a4b.pl.X4L7Selector.All
import host.sim.compose.a4b.pl.X4L7Call.All
import host.sim.compose.a4b.pl.X4L7Common.All
import host.sim.template.a4pre_plx4_L7_selector.Origin
import host.sim.template.a4pre_plx4_L7_call.Origin
import host.sim.template.a4pre_plx4_L7_common.Origin
set_option Elab.async false
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
set_option autoImplicit false
namespace Host.Ts.Sim.Compose.FillPost
open Host.Ts Host.Ts.Sim Host.Ts.Sim.Full Host.Ts.Sim.Prefill Host.Ts.Sim.Template Host.Ts.Sim.Compose.Post
open Host.Load.Run.Tpl

/-! # x4 L7's POST stretch

The class from its head's end to its common's, at the final step's chunk. -/

noncomputable def classX4L7 (NB T : Nat) (tk : Nat → Nat) (π : List Nat) (cap nI : Nat) (hcap : cap ≤ 4096 + 1593835520) :
    ClassPre NB T tk π cap nI where
  fr := [2834123]
  sH := PRE_plx4_L7_head.s1
  SH := PRE_plx4_L7_head.S1
  sC := PRE_plx4_L7_common.s1
  SC := PRE_plx4_L7_common.S1
  n := PL.X4L7Selector.N + PL.X4L7Call.N + PL.X4L7Common.N
  run Tr hT :=
    (((PL.X4L7Selector.all NB T tk cap nI π hcap (fun _ h => PRE_plx4_L7_selector.good h.rowValue) Tr hT).convL
        (idxConv PRE_plx4_L7_selector.s0_eq PRE_plx4_L7_selector.s0_tab)).trans
      ((PL.X4L7Call.all NB T tk cap nI π hcap (fun _ _ => by rw [PRE_plx4_L7_call.empty_oracle]; intro _ hq; cases hq) Tr hT).convL
        (idxConv PRE_plx4_L7_call.s0_eq PRE_plx4_L7_call.s0_tab))).trans
    ((PL.X4L7Common.all NB T tk cap nI π hcap (fun _ h => PRE_plx4_L7_common.good h.rowValue) Tr hT).convL
      (idxConv PRE_plx4_L7_common.s0_eq PRE_plx4_L7_common.s0_tab))

end Host.Ts.Sim.Compose.FillPost
