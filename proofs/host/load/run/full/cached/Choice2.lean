import host.load.Native
import host.load.Choice
import host.load.run.full.H97
set_option Elab.async false
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
set_option interpreter.prefer_native true
namespace Host.Load.Run.Full.Cached
open Host.Ts Host.Load.Extract
load_state_summary after2 : P.s3123, entryEnv P.s0
load_summary_checked loaded2 : P.s3123, entryEnv P.s0 using after2
kernel_rfl graph2_nodes_source : P.s3123.ffi.mlx.nodes = after2.graph.nodes
end Host.Load.Run.Full.Cached
