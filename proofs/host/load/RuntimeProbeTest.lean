import host.ts.renameOrdinary.HostCuts
import host.load.RuntimeProbe
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
set_option Elab.async false
namespace Host.Load.Run.Full.Ordinary.SourceProbeTest

/-- info: Retained source probe: all 100 selected frontend instances checked; initial annotation premises remain to be discharged -/
#guard_msgs in
host_source_probe P.F, P.RestStream.micro0.micro0 from 0 probe_steps 100

end Host.Load.Run.Full.Ordinary.SourceProbeTest
