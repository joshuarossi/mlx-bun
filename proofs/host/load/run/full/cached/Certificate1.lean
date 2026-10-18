import host.load.run.full.cached.FinalGraph
import host.load.run.full.FirstCertificate
namespace Host.Load.Run.Full.Cached
open Host.Mlx Host.Mlx.FfiEval Host.Load.Extract Host.Ts
set_option Elab.async false
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
ffi_check_family certificate1 : List F64, terminalGraph, Expected.graph,
  firstCarriers, firstInputs choosing Expected.graph
theorem carriers1_before_next_forward : firstCarriers.all (fun i => decide (i < 17777)) = true := rfl
end Host.Load.Run.Full.Cached
