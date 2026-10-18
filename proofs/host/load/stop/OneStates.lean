import host.load.StopCommand
import host.load.run.full.H92
set_option Elab.async false
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
set_option interpreter.prefer_native true
namespace Host.Load.Run.Full
host_stop_fragment OneToken : P.s2973, P.S2973, Host.Load.Stop.oneTokenValuation, 20000, 500, 0
end Host.Load.Run.Full
