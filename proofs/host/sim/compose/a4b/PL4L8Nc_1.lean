import host.sim.compose.a4b.PL4L8Na
set_option Elab.async false
namespace Host.Load.Run.Tpl
open Host.Ts Host.Ts.Sim Host.Ts.Sim.Template Host.Ts.Sim.Full Host.Ts.Sim.Compose Host.Route
set_option maxRecDepth 1000000
set_option maxHeartbeats 0

kernel_rfl PL4L8.nhandles_0 : ((handlesOfA PL4L8.x0).take 2000).all (handleOK PLW4L8.R.data.map PL4L8.P0.lo PL4L8.x0 PL4L8.x1) = true

end Host.Load.Run.Tpl
