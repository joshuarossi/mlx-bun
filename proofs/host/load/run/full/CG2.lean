import host.load.run.full.H0
import host.load.Micro
set_option Elab.async false
namespace Host.Load.Run.Full
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
set_option interpreter.prefer_native true
host_micro_chunk P 8, 500 refine 5500, 6000, 10
host_chunk P 9
host_chunk P 10
host_chunk P 11
end Host.Load.Run.Full
