import host.mlx.OrdinaryVectorResultStates
import host.ts.RenameRuntimeDerivedCuts
import host.ts.RenameKernelRfl
import host.ts.RenameLoopVariableNamespace

set_option Elab.async false
set_option maxRecDepth 1000000
set_option maxHeartbeats 0

namespace Host.Load.Run.Full.Ordinary.CachedArrayEntry
open Host.Ts Host.Ts.Owned Host.Ts.Owned.Annotated

/- Source 2447–2456. The entry server is the namespaced numeric server. -/
namespace From2447
host_derive_source_cuts P.F, P.RestStream.micro0.micro24.s47
  using (numberServer ((P.RestStream.micro0.micro24.S47).substitute LoopVariables.oracleVariables))
  steps 10 as Cut
end From2447

/- Source 2457–2466. -/
namespace From2457
host_derive_source_cuts P.F, From2447.Cut.s10 using From2447.Cut.S10 steps 10 as Cut
end From2457

/- Source 2467–2476. -/
namespace From2467
host_derive_source_cuts P.F, From2457.Cut.s10 using From2457.Cut.S10 steps 10 as Cut
end From2467

/- Source 2477–2486, landing on the `mlx_array_new` state without calling it. -/
namespace From2477
host_derive_source_cuts P.F, From2467.Cut.s10 using From2467.Cut.S10 steps 10 as Cut
end From2477

theorem cut_2457 : From2447.Cut.s10 = P.RestStream.micro0.micro24.s57 := by
  host_kernel_rfl
theorem cut_2467 : From2457.Cut.s10 = P.RestStream.micro0.micro24.s67 := by
  host_kernel_rfl
theorem cut_2477 : From2467.Cut.s10 = P.RestStream.micro0.micro24.s77 := by
  host_kernel_rfl
theorem cut_2487 : From2477.Cut.s10 = P.RestStream.micro0.micro24.s87 := by
  host_kernel_rfl

end Host.Load.Run.Full.Ordinary.CachedArrayEntry
