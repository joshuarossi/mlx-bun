import host.mlx.OrdinaryArrayFreeStates
import host.ts.RenameRuntimeDerivedCuts
set_option Elab.async false
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
namespace Host.Load.Run.Full.Ordinary.PostConcatCleanup

/- Source 1979 is the checked fine state immediately after `mlx_array_free(29372)`.
The 77 transitions stop at source 2056, before `mlx_array_free(25732)`. -/
host_derive_source_cuts P.F, P.RestStream.micro0.micro19.s79 using P.RestStream.micro0.micro19.S79 steps 25 as From1979
host_derive_source_cuts P.F, From1979.s25 using From1979.S25 steps 25 as From2004
host_derive_source_cuts P.F, From2004.s25 using From2004.S25 steps 25 as From2029
host_derive_source_cuts P.F, From2029.s25 using From2029.S25 steps 2 as From2054

open Lean Elab Command Meta in
run_cmd liftTermElabM do
  let pre ← getCurrNamespace
  for i in List.range 78 do
    let part := i / 25
    let offset := i - part * 25
    let base := 1979 + part * 25
    for tag in ["s", "S"] do
      let source := pre ++ Name.mkSimple s!"From{base}" ++ Name.mkSimple s!"{tag}{offset}"
      Host.Ts.Owned.Parametric.Driver.addData (pre ++ `Region ++ Name.mkSimple s!"{tag}{i}") (mkConst source)

theorem anchor1979 : Region.s0 = P.RestStream.micro0.micro19.s79 := by host_kernel_rfl
theorem anchorServer1979 : Region.S0 = P.RestStream.micro0.micro19.S79 := by host_kernel_rfl

host_transport_object Region 77 4633 as EndCallee

theorem endpoint_control : Region.s77.ctl = .call (.obj 4633) (.obj 4817) [.big (Int.ofNat 25732)] := by
  host_kernel_rfl
theorem endpoint_symbol :
    (match EndCallee.kind with
      | .fn (.native (.ffi .symbol) (.str name :: _)) => name
      | _ => []) = chars!"mlx_array_free" := by host_kernel_rfl
theorem native_unchanged : Region.s77.ffi = Region.s0.ffi := by host_kernel_rfl
theorem dispose_entry : Region.s41.ctl = .call (.obj 4882) (.obj 2978923) [] := by host_kernel_rfl
theorem disposed_value : Region.s55.ctl = .ret (.bool true) := by host_kernel_rfl
theorem unregister_entry : Region.s66.ctl = .call (.obj 186) (.obj 4851) [.obj 2978925] := by host_kernel_rfl
theorem handle_ready : Region.s76.ctl = .ret (.big (Int.ofNat 25732)) := by host_kernel_rfl

end Host.Load.Run.Full.Ordinary.PostConcatCleanup
