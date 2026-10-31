import host.sim.template.a4pre_setup_early_r0.Start
import host.sim.template.FullOk
import host.sim.template.a4pre_setup_early_r0.OkB
import host.sim.template.a4pre_setup_native32.Origin
import host.sim.compose.Glue
import host.sim.template.a4pre_setup_early_r0.Bridge
import host.sim.lin.Table

set_option Elab.async false
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
namespace Host.Ts.Sim.Compose.SetupEarly
open Host.Ts Host.Ts.Sim Host.Ts.Sim.Full Host.Ts.Sim.Template
open Host.Ts.Sim.Lin Host.Ts.Sim.Lin.Cls Host.Load.Run.Tpl

kernel_rfl oracle0 : goodLin setup_early.r0.ps (varsOf setup_early.r0.V [(9, .L)])
  PRE_setup_early_r0.S0.oracle = true
kernel_rfl oracle3 : goodLin setup_early.r0.ps (varsOf setup_early.r0.V [(9, .L)])
  PRE_setup_early_r0.S3.oracle = true
kernel_rfl accepted0Literal : PRE_setup_early_r0.okB0 PRENative32.s0 PRE_setup_early_r0.S0 = true
theorem accepted0 : PRE_setup_early_r0.okB0 PRE_setup_early_r0.s0 PRE_setup_early_r0.S0 = true := by
  rw [← PRENative32.start_exact]
  exact accepted0Literal
kernel_rfl unhalted1 : isHalt PRE_setup_early_r0.s1.ctl = false
kernel_rfl top2 : noRetBlock PRE_setup_early_r0.s2 = true
kernel_rfl accepted3 : PRE_setup_early_r0.okB0 PRE_setup_early_r0.s3 PRE_setup_early_r0.S3 = true
kernel_rfl unhalted3 : isHalt PRE_setup_early_r0.s3.ctl = false
kernel_rfl top4 : noRetBlock PRE_setup_early_r0.s4 = true
kernel_rfl lengthStack : PRE_setup_early_r0.s2.stack =
  .e (.member kLength false) :: PRE_setup_early_r0.s2.stack.tail
kernel_rfl promptEmpty : arrOf PRE_setup_early_r0.s2 2665 = []
kernel_rfl bridge4 : bridgeOf PRE_setup_early_r0.s4.ffi = bridgeOf PRE_setup_early_r0.s0.ffi


end Host.Ts.Sim.Compose.SetupEarly
