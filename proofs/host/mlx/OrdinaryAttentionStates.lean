import host.load.Micro
import host.ts.renameOrdinary.micro.streamed128.H3
import host.ts.RenameRouteDriver

set_option Elab.async false
set_option maxRecDepth 1000000
set_option maxHeartbeats 0

namespace Host.Load.Run.Full
host_micro_stream P.RestStream.micro0 510, 1
run_cmd do
  for i in [:13] do
    Host.Ts.Owned.Parametric.Driver.emit s!"host_stream_state P.RestStream.micro0.micro510 {i}"
end Host.Load.Run.Full
