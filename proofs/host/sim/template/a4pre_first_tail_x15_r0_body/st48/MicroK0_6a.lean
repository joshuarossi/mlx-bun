import host.sim.template.a4pre_first_tail_x15_r0_body.st48.MicroK0_6ab
set_option Elab.async false
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
namespace Host.Load.Run.Tpl
open Host.Ts Host.Ts.Sim
noncomputable def PRE_first_tail_x15_r0_body.st48.microK0_6_left.s1 := PRE_first_tail_x15_r0_body.st48.microK0_6_left_right.s1
noncomputable def PRE_first_tail_x15_r0_body.st48.microK0_6_left.S1 : SSrv := PRE_first_tail_x15_r0_body.st48.microK0_6_left_right.S1
theorem PRE_first_tail_x15_r0_body.st48.microK0_6_left.checked : runOk PRE_first_tail_x15_r0_body.st48.F PRE_first_tail_x15_r0_body.st48.okL 256 PRE_first_tail_x15_r0_body.st48.microK0_5.s1 PRE_first_tail_x15_r0_body.st48.microK0_5.S1 = some (PRE_first_tail_x15_r0_body.st48.microK0_6_left.s1, PRE_first_tail_x15_r0_body.st48.microK0_6_left.S1) :=
  runOk_trans PRE_first_tail_x15_r0_body.st48.F PRE_first_tail_x15_r0_body.st48.okL 128 128 PRE_first_tail_x15_r0_body.st48.microK0_5.s1 PRE_first_tail_x15_r0_body.st48.microK0_6_left_left.s1 PRE_first_tail_x15_r0_body.st48.microK0_6_left_right.s1 PRE_first_tail_x15_r0_body.st48.microK0_5.S1 PRE_first_tail_x15_r0_body.st48.microK0_6_left_left.S1 PRE_first_tail_x15_r0_body.st48.microK0_6_left_right.S1 PRE_first_tail_x15_r0_body.st48.microK0_6_left_left.checked PRE_first_tail_x15_r0_body.st48.microK0_6_left_right.checked
end Host.Load.Run.Tpl
