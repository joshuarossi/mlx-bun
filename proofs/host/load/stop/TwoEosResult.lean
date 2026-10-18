import host.load.stop.TwoEosSteps
import host.load.Compose
set_option Elab.async false
set_option maxRecDepth 1000000
namespace Host.Load.Run.Full
open Host.Ts Host.Load

host_chain_run_staged TwoEos

theorem TwoEos.execution :
    runS Host.Load.ffi 1254 P.s3123 TwoEos.srv = some (TwoEos.s3, TwoEos.S3) := TwoEos.run

kernel_rfl TwoEos.completed :
    Stop.summary TwoEos.s3 TwoEos.S3 (entryEnv P.s0) =
      some ⟨[.var 1], .lit (F64.ofNat 2), .lit (F64.ofNat 2),
        [.lit (F64.ofNat 1), .lit (F64.ofNat 4), .lit (F64.ofNat 256), .lit (F64.ofNat 256)],
        .lit (F64.ofNat 2), .lit (F64.ofNat 1), true⟩

theorem TwoEos.normal_halt : ∃ v, TwoEos.s3.ctl = .halt (.normal v) := by
  exact ⟨_, rfl⟩

kernel_rfl TwoEos.nodes_preserved : TwoEos.s3.ffi.mlx.nodes = P.s3123.ffi.mlx.nodes

kernel_rfl TwoEos.model_preserved :
    bindingOf TwoEos.s3 (entryEnv P.s0) chars!"model" =
      bindingOf P.s3123 (entryEnv P.s0) chars!"model"

kernel_rfl TwoEos.cache_root_preserved :
    bindingOf TwoEos.s3 (entryEnv P.s0) chars!"cache" =
      bindingOf P.s3123 (entryEnv P.s0) chars!"cache"

end Host.Load.Run.Full
