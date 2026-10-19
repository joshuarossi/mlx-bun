import host.load.RuntimeCompiledArgumentEntryPrefix
import host.ts.RenameKernelRfl
import host.mlx.NativeSymbol
import host.mlx.NativeArrayFreeHost
set_option Elab.async false
set_option maxRecDepth 1000000
set_option maxHeartbeats 1000000
namespace Host.Load.Run.Full.Ordinary.CompiledArgumentEntry
open Host.Ts

/-- Source 2056 is the actual call `mlx_array_free(25732)`. Source 2057 is only
the resulting interpreter state. Generic native-free transport stays with the
parent. -/
noncomputable def At2056.s0 := From2050.s6
noncomputable def At2056.S0 := From2050.S6
noncomputable def At2057.s0 := finishStatus At2056.s0
  (Host.Load.Owned.freeArray At2056.s0.ffi 25732) chars!"mlx_array_free" [.big (Int.ofNat 25732)]
noncomputable def At2057.S0 := At2056.S0

theorem source2056_step :
    interpS (step P.F At2056.s0).run At2056.S0 = some (At2057.s0, At2057.S0) := by
  host_kernel_rfl

end Host.Load.Run.Full.Ordinary.CompiledArgumentEntry
