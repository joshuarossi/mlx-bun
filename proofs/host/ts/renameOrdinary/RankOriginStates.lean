import host.load.Micro
import host.ts.renameOrdinary.Frames
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
set_option Elab.async false
namespace Host.Load.Run.Full
host_micro_stream P 3275, 10000 chunks ([9942] ++ List.replicate 58 1)
end Host.Load.Run.Full
