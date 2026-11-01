import host.sim.compose.a4b.PF8Na
set_option Elab.async false
namespace Host.Load.Run.Tpl
open Host.Ts Host.Ts.Sim Host.Ts.Sim.Template Host.Ts.Sim.Full Host.Ts.Sim.Compose Host.Route
set_option maxRecDepth 1000000
set_option maxHeartbeats 0

kernel_rfl PF8.nhandles_2 : ((((handlesOfA PF8.x0).drop 2000).drop 2000).take 2000).all (handleOK PFW8.R.data.map PF8.P0.lo PF8.x0 PF8.x1) = true

end Host.Load.Run.Tpl
