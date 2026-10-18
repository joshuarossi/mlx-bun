import host.load.stop.OneEosSteps
import host.load.Compose
set_option Elab.async false
set_option maxRecDepth 1000000
namespace Host.Load.Run.Full
open Host.Ts Host.Load

host_chain_run_staged OneEos

theorem OneEos.execution :
    runS Host.Load.ffi 2952 P.s2973 OneEos.srv = some (OneEos.s6, OneEos.S6) := OneEos.run

theorem OneEos.completed :
    Stop.summary OneEos.s6 OneEos.S6 (entryEnv P.s0) =
      some ⟨[], .lit (F64.ofNat 1), .lit (F64.ofNat 1),
        [.lit (F64.ofNat 1), .lit (F64.ofNat 4), .lit (F64.ofNat 256), .lit (F64.ofNat 256)],
        .lit (F64.ofNat 1), .lit (F64.ofNat 0), true⟩ := by rfl

theorem OneEos.normal_halt : ∃ v, OneEos.s6.ctl = .halt (.normal v) := by
  exact ⟨_, rfl⟩

theorem OneEos.first_graph : OneEos.s6.ffi.mlx.nodes = P.s2974.ffi.mlx.nodes := by rfl

theorem OneEos.model_preserved :
    bindingOf OneEos.s6 (entryEnv P.s0) chars!"model" =
      bindingOf P.s2973 (entryEnv P.s0) chars!"model" := by rfl

theorem OneEos.cache_root_preserved :
    bindingOf OneEos.s6 (entryEnv P.s0) chars!"cache" =
      bindingOf P.s2973 (entryEnv P.s0) chars!"cache" := by rfl

end Host.Load.Run.Full
