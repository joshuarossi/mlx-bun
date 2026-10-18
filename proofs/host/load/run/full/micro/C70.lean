import host.load.Micro
import host.load.run.full.H2
set_option Elab.async false
set_option interpreter.prefer_native true
set_option maxHeartbeats 0
set_option maxRecDepth 1000000
namespace Host.Load.Run.Full
host_micro_chunk P 70, 100
end Host.Load.Run.Full
