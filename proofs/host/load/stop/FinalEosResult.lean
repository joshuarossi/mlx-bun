import host.load.stop.FinalEosSteps
import host.load.Compose
set_option Elab.async false
set_option maxRecDepth 1000000
namespace Host.Load.Run.Full
open Host.Ts Host.Load

host_chain_run_staged FinalEos

theorem FinalEos.execution :
    runS Host.Load.ffi 1134 P.s3573 FinalEos.srv = some (FinalEos.s3, FinalEos.S3) := FinalEos.run

kernel_rfl FinalEos.completed :
    Stop.summary FinalEos.s3 FinalEos.S3 (entryEnv P.s0) =
      some ⟨[.var 1, .var 2, .var 3, .var 4], .lit (F64.ofNat 5), .lit (F64.ofNat 5),
        [.lit (F64.ofNat 1), .lit (F64.ofNat 4), .lit (F64.ofNat 256), .lit (F64.ofNat 256)],
        .lit (F64.ofNat 5), .lit (F64.ofNat 4), true⟩

theorem FinalEos.normal_halt : ∃ v, FinalEos.s3.ctl = .halt (.normal v) := by
  exact ⟨_, rfl⟩

kernel_rfl FinalEos.nodes_preserved : FinalEos.s3.ffi.mlx.nodes = P.s3573.ffi.mlx.nodes

kernel_rfl FinalEos.model_preserved :
    bindingOf FinalEos.s3 (entryEnv P.s0) chars!"model" =
      bindingOf P.s3573 (entryEnv P.s0) chars!"model"

kernel_rfl FinalEos.cache_root_preserved :
    bindingOf FinalEos.s3 (entryEnv P.s0) chars!"cache" =
      bindingOf P.s3573 (entryEnv P.s0) chars!"cache"

end Host.Load.Run.Full
