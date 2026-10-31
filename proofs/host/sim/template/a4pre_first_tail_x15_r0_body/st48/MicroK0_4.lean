import host.sim.template.a4pre_first_tail_x15_r0_body.st48.MicroK0_4b
set_option Elab.async false
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
namespace Host.Load.Run.Tpl
open Host.Ts Host.Ts.Sim
noncomputable def PRE_first_tail_x15_r0_body.st48.microK0_4.s1 := PRE_first_tail_x15_r0_body.st48.microK0_4_right.s1
noncomputable def PRE_first_tail_x15_r0_body.st48.microK0_4.S1 : SSrv := PRE_first_tail_x15_r0_body.st48.microK0_4_right.S1
theorem PRE_first_tail_x15_r0_body.st48.microK0_4.checked : runOk PRE_first_tail_x15_r0_body.st48.F PRE_first_tail_x15_r0_body.st48.okL 512 PRE_first_tail_x15_r0_body.st48.microK0_3.s1 PRE_first_tail_x15_r0_body.st48.microK0_3.S1 = some (PRE_first_tail_x15_r0_body.st48.microK0_4.s1, PRE_first_tail_x15_r0_body.st48.microK0_4.S1) :=
  runOk_trans PRE_first_tail_x15_r0_body.st48.F PRE_first_tail_x15_r0_body.st48.okL 256 256 PRE_first_tail_x15_r0_body.st48.microK0_3.s1 PRE_first_tail_x15_r0_body.st48.microK0_4_left.s1 PRE_first_tail_x15_r0_body.st48.microK0_4_right.s1 PRE_first_tail_x15_r0_body.st48.microK0_3.S1 PRE_first_tail_x15_r0_body.st48.microK0_4_left.S1 PRE_first_tail_x15_r0_body.st48.microK0_4_right.S1 PRE_first_tail_x15_r0_body.st48.microK0_4_left.checked PRE_first_tail_x15_r0_body.st48.microK0_4_right.checked
end Host.Load.Run.Tpl
