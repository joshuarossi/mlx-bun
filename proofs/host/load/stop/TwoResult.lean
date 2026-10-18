import host.load.stop.TwoSteps
import host.load.Compose
set_option Elab.async false
set_option maxRecDepth 1000000
namespace Host.Load.Run.Full
open Host.Ts Host.Load

host_chain_run_staged TwoToken

theorem TwoToken.execution :
    runS Host.Load.ffi 1430 P.s3123 TwoToken.srv = some (TwoToken.s3, TwoToken.S3) := TwoToken.run

kernel_rfl TwoToken.completed :
    Stop.summary TwoToken.s3 TwoToken.S3 (entryEnv P.s0) =
      some ⟨[.var 1, .var 2], .lit (F64.ofNat 2), .lit (F64.ofNat 2),
        [.lit (F64.ofNat 1), .lit (F64.ofNat 4), .lit (F64.ofNat 256), .lit (F64.ofNat 256)],
        .lit (F64.ofNat 2), .lit (F64.ofNat 2), true⟩

theorem TwoToken.normal_halt : ∃ v, TwoToken.s3.ctl = .halt (.normal v) := by
  exact ⟨_, rfl⟩

kernel_rfl TwoToken.nodes_preserved : TwoToken.s3.ffi.mlx.nodes = P.s3123.ffi.mlx.nodes

kernel_rfl TwoToken.model_preserved :
    bindingOf TwoToken.s3 (entryEnv P.s0) chars!"model" =
      bindingOf P.s3123 (entryEnv P.s0) chars!"model"

kernel_rfl TwoToken.cache_root_preserved :
    bindingOf TwoToken.s3 (entryEnv P.s0) chars!"cache" =
      bindingOf P.s3123 (entryEnv P.s0) chars!"cache"

end Host.Load.Run.Full
