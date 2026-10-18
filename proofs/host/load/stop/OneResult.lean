import host.load.stop.OneSteps
import host.load.Compose

set_option Elab.async false
set_option maxRecDepth 1000000
namespace Host.Load.Run.Full
open Host.Ts Host.Load

host_chain_run_staged OneToken

/-- The real generator's budget-one branch, from the first sampler result.
The branch answers are explicit oracle inputs; entry reachability is separate. -/
theorem OneToken.execution :
    runS Host.Load.ffi 3144 P.s2973 OneToken.srv =
      some (OneToken.s7, OneToken.S7) := OneToken.run

theorem OneToken.completed :
    Stop.summary OneToken.s7 OneToken.S7 (entryEnv P.s0) =
      some ⟨[.var 1], .lit (F64.ofNat 1), .lit (F64.ofNat 1),
        [.lit (F64.ofNat 1), .lit (F64.ofNat 4), .lit (F64.ofNat 256), .lit (F64.ofNat 256)],
        .lit (F64.ofNat 1), .lit (F64.ofNat 1), true⟩ := by rfl

theorem OneToken.normal_halt : ∃ v, OneToken.s7.ctl = .halt (.normal v) := by
  exact ⟨_, rfl⟩

theorem OneToken.final_sampler_nodes :
    OneToken.s7.ffi.mlx.nnext = P.s2973.ffi.mlx.nnext + 6 := by rfl

theorem OneToken.first_graph :
    OneToken.s7.ffi.mlx.nodes = P.s2974.ffi.mlx.nodes := by rfl

theorem OneToken.model_preserved :
    bindingOf OneToken.s7 (entryEnv P.s0) chars!"model" =
      bindingOf P.s2973 (entryEnv P.s0) chars!"model" := by rfl

theorem OneToken.cache_root_preserved :
    bindingOf OneToken.s7 (entryEnv P.s0) chars!"cache" =
      bindingOf P.s2973 (entryEnv P.s0) chars!"cache" := by rfl

end Host.Load.Run.Full
