import host.sim.template.a4pre_first_tail_x15_r0_suffix.BoundaryData
import host.sim.template.BoundaryCheck
set_option Elab.async false
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
namespace Host.Load.Run.Tpl
open Host.Ts Host.Ts.Sim Host.Ts.Sim.Template
kernel_rfl PRE_first_tail_x15_r0_suffix.endTab17 : ((PRE_first_tail_x15_r0_suffix.S8.tab.drop 4352).take 256).map (·.subst PRE_first_tail_x15_r0_suffix.dtheta) = (PRE_first_tail_x15_r0_suffix.endSrv.tab.drop 4352).take 256
end Host.Load.Run.Tpl
