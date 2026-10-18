import host.load.stop.EosSteps
import host.load.Compose
set_option Elab.async false
set_option maxRecDepth 1000000
namespace Host.Load.Run.Full
open Host.Ts Host.Load

host_chain_run_staged EosToken

/-- EOS is consumed at the ordinary readback cut, retaining the already
computed lookahead caches. Source entry reachability is a separate invariant. -/
theorem EosToken.execution :
    runS Host.Load.ffi 825 P.s3272 EosToken.srv =
      some (EosToken.s2, EosToken.S2) := EosToken.run

theorem EosToken.completed :
    Stop.summary EosToken.s2 EosToken.S2 (entryEnv P.s0) =
      some ⟨[.var 1], .lit (F64.ofNat 2), .lit (F64.ofNat 3),
        [.lit (F64.ofNat 1), .lit (F64.ofNat 4), .lit (F64.ofNat 256), .lit (F64.ofNat 256)],
        .lit (F64.ofNat 3), .lit (F64.ofNat 1), true⟩ := by rfl

theorem EosToken.normal_halt : ∃ v, EosToken.s2.ctl = .halt (.normal v) := by
  exact ⟨_, rfl⟩

theorem EosToken.nodes_preserved : EosToken.s2.ffi.mlx.nodes = P.s3272.ffi.mlx.nodes := by rfl

theorem EosToken.model_preserved :
    bindingOf EosToken.s2 (entryEnv P.s0) chars!"model" =
      bindingOf P.s3272 (entryEnv P.s0) chars!"model" := by rfl

theorem EosToken.cache_root_preserved :
    bindingOf EosToken.s2 (entryEnv P.s0) chars!"cache" =
      bindingOf P.s3272 (entryEnv P.s0) chars!"cache" := by rfl

end Host.Load.Run.Full
