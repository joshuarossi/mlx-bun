import host.sim.compose.a4b.PF4L7Na
set_option Elab.async false
namespace Host.Load.Run.Tpl
open Host.Ts Host.Ts.Sim Host.Ts.Sim.Template Host.Ts.Sim.Full Host.Ts.Sim.Compose Host.Route
set_option maxRecDepth 1000000
set_option maxHeartbeats 0

kernel_rfl PF4L7.nhandles_0 : ((handlesOfA PF4L7.x0).take 2000).all (handleOK PFW4L7.R.data.map PF4L7.P0.lo PF4L7.x0 PF4L7.x1) = true

end Host.Load.Run.Tpl
