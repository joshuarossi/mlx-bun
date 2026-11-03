import host.sim.compose.a4b.PLT4L9Na
set_option Elab.async false
namespace Host.Load.Run.Tpl
open Host.Ts Host.Ts.Sim Host.Ts.Sim.Template Host.Ts.Sim.Full Host.Ts.Sim.Compose Host.Route
set_option maxRecDepth 1000000
set_option maxHeartbeats 0

kernel_rfl PLT4L9.nhandles_11 : (((((((((((((handlesOfA PLT4L9.x0).drop 2000).drop 2000).drop 2000).drop 2000).drop 2000).drop 2000).drop 2000).drop 2000).drop 2000).drop 2000).drop 2000).take 2000).all (handleOK PLTW4L9.R.data.map PLT4L9.P0.lo PLT4L9.x0 PLT4L9.x1) = true

end Host.Load.Run.Tpl
