import host.sim.template.a4pre_first_tail_x15_r0_body.BoundaryData
import host.sim.template.BoundaryCheck
set_option Elab.async false
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
namespace Host.Load.Run.Tpl
open Host.Ts Host.Ts.Sim Host.Ts.Sim.Template
kernel_rfl PRE_first_tail_x15_r0_body.endTab10 : ((PRE_first_tail_x15_r0_body.S1843.tab.drop 2560).take 256).map (·.subst PRE_first_tail_x15_r0_body.dtheta) = (PRE_first_tail_x15_r0_body.endSrv.tab.drop 2560).take 256
end Host.Load.Run.Tpl
