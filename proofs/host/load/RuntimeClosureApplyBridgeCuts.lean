import host.ts.renameOrdinary.NativeCallCutStates
import host.ts.RenameRuntimeDerivedCuts
import host.ts.RenameKernelRfl
import host.mlx.OrdinaryVectorInputHost

set_option Elab.async false
set_option maxRecDepth 1000000
set_option maxHeartbeats 0

namespace Host.Load.Run.Full.Ordinary.ClosureApplyBridge

-- Host steps 2300–2324. Anchor s23 is source 2300. Cuts stop before a native MLX symbol.
namespace Prefix2300
host_derive_source_cuts P.F, P.RestStream.micro0.micro23.s0 using P.RestStream.micro0.micro23.S0 steps 25 as Cut
end Prefix2300

-- Host steps 2325–2335, ending on the actual mlx_vector_array_new_data call.
namespace Prefix2325
host_derive_source_cuts P.F, Prefix2300.Cut.s25 using Prefix2300.Cut.S25 steps 11 as Cut
end Prefix2325

-- Host steps 2337–2349, from after vector-data allocation to the empty mlx_vector_array_new call.
namespace ToVectorNew
host_derive_source_cuts P.F, P.RestStream.micro0.micro23.s37 using P.RestStream.micro0.micro23.S37 steps 13 as Cut
end ToVectorNew

-- Host steps 2351–2375, immediately after the empty output vector is allocated.
namespace AfterVectorNew
host_derive_source_cuts P.F, P.RestStream.micro0.micro23.s51 using P.RestStream.micro0.micro23.S51 steps 25 as Cut
end AfterVectorNew

-- Host steps 2376–2381, ending on the actual mlx_closure_apply input.
namespace ToClosureCall
host_derive_source_cuts P.F, AfterVectorNew.Cut.s25 using AfterVectorNew.Cut.S25 steps 6 as Cut
end ToClosureCall

theorem prefix_reaches_data_call : Prefix2325.Cut.s11 = P.RestStream.micro0.micro23.s36 := by
  host_kernel_rfl
theorem prefix_data_call_input : Prefix2325.Cut.s11 = VectorInputCall.input := by
  host_kernel_rfl
theorem vector_new_input : ToVectorNew.Cut.s13 = P.RestStream.micro0.micro23.s50 := by
  host_kernel_rfl
theorem closure_call_input : ToClosureCall.Cut.s6 = P.RestStream.micro0.micro23.s82 := by
  host_kernel_rfl

end Host.Load.Run.Full.Ordinary.ClosureApplyBridge
