import host.load.run.full.H0
import host.load.Micro
set_option Elab.async false
namespace Host.Load.Run.Full
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
set_option interpreter.prefer_native true
host_chunk P 16
host_chunk P 17
host_chunk P 18
host_micro_chunk P 19, 100
end Host.Load.Run.Full
