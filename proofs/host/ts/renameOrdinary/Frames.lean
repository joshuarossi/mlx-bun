import host.ts.RenamePrefix
import host.load.run.full.H106
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
set_option Elab.async false
namespace Host.Load.Run.Full

host_read_tail P 3272, 3422 keep 1
host_prefix_frames P 3272, 3422 arrays [2673447, 12502]

end Host.Load.Run.Full
