import host.load.Native
import host.load.Choice
import host.load.run.full.H106
set_option Elab.async false
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
set_option interpreter.prefer_native true
namespace Host.Load.Run.Full.Cached
open Host.Ts Host.Load.Extract
load_state_summary after4 : P.s3422, entryEnv P.s0
load_summary_checked loaded4 : P.s3422, entryEnv P.s0 using after4
kernel_rfl graph4_nodes_source : P.s3422.ffi.mlx.nodes = after4.graph.nodes
end Host.Load.Run.Full.Cached
