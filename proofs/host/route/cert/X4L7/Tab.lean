import host.route.cert.X4L7.Data
import host.sim.template.a4pre_first_tail_x4_L7_r0_suffix.m.B3
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
set_option Elab.async false
set_option autoImplicit false
namespace Host.Route.Cert.X4L7
open Host.Ts Host.Ts.Sim Host.Mlx Host.Mlx.FfiEval Host.Mlx.SimGraph Host.Load.Run.Tpl
open Host.Mlx.SimGraph.Tpl.Fam

kernel_rfl input_tab : PRE_first_tail_x4_L7_r0_suffix.inputSrv.tab = PRE_first_tail_x4_L7_r0_body.endSrv.tab

theorem tab_eq : PRE_first_tail_x4_L7_r0_suffix.inputSrv.tab = PRE_first_tail_x4_L7_r0_suffix.S0.tab :=
  input_tab.trans PRE_first_tail_x4_L7_r0_suffix.s0_tab.symm

end Host.Route.Cert.X4L7
