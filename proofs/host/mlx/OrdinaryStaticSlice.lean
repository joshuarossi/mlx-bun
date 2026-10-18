import host.mlx.OrdinaryStaticSliceStates
import host.mlx.NativeClosedFixedSliceFrontend
import host.mlx.NativeKvViewFrontend

set_option Elab.async false
set_option maxRecDepth 1000000
set_option maxHeartbeats 1000000

namespace Host.Load.Run.Full.Ordinary.StaticSlice
open Host.Ts Host.Mlx.Ffi Host.Mlx.Ffi.Annotated

noncomputable def input : St LSt := P.RestStream.micro0.micro420.s1
noncomputable def output : St LSt := P.RestStream.micro0.micro420.s2

host_retained_closedFixedSlice Host.Load.ffi, input using P.RestStream.micro0.micro420.S1
  to output using P.RestStream.micro0.micro420.S2 as Source42072

theorem source_rank : Source42072.Normalized.rank = 4 := rfl

theorem source_geometry : Source42072.Normalized.inputSizes = [1,1,24,512] ∧
    Source42072.Normalized.first = [0,0,0,0] ∧ Source42072.Normalized.last = [1,1,24,256] := ⟨rfl,rfl,rfl⟩

theorem source_prefix : runS P.F 72 P.RestStream.micro0.s420 P.RestStream.micro0.S420 =
    some (input,P.RestStream.micro0.micro420.S1) := by host_kernel_rfl

/-- error: host_retained_kvView: expected cache prefix geometry -/
#guard_msgs in
host_retained_kvView Host.Load.ffi, input using P.RestStream.micro0.micro420.S1
  to output using P.RestStream.micro0.micro420.S2 as RejectKvPrefix

/-- error: host_retained_fixedSlice: expected input rank matching dimension count -/
#guard_msgs in
host_retained_closedFixedSlice Host.Load.ffi,
  {input with ctl := .call (.obj 4713) (.obj 4817) [.ptr (.js 3130797) 0,.big 29477,.ptr (.js 3130768) 0,.big 3,
    .ptr (.js 3130770) 0,.big 3,.ptr (.js 3130785) 0,.big 3,.big 2]}
  using P.RestStream.micro0.micro420.S1 to output using P.RestStream.micro0.micro420.S2 as RejectRank

/-- error: (kernel) declaration type mismatch -/
#guard_msgs (error, substring := true) in
run_cmd do
  let saved ← Lean.getEnv
  try
    Host.Ts.Owned.Parametric.Driver.emit "host_retained_closedFixedSlice Host.Load.ffi, input using P.RestStream.micro0.micro420.S1 to input using P.RestStream.micro0.micro420.S1 as RejectEndpoint"
  finally Lean.setEnv saved

end Host.Load.Run.Full.Ordinary.StaticSlice
