import host.mlx.OrdinarySliceCut
import host.mlx.NativeFixedSliceFrontend

set_option Elab.async false
set_option maxRecDepth 1000000
set_option maxHeartbeats 1000000

namespace Host.Load.Run.Full.Ordinary.FixedSlice
open Host.Ts Host.Mlx.Ffi Host.Mlx.Ffi.NativeRoles

host_retained_fixedSlice Host.Load.ffi, SliceCall.input using P.RestStream.micro0.micro10.S86
  to SliceCall.output using P.RestStream.micro0.micro10.S87 as Source1086

theorem source_prefix : runS P.F 86 P.RestStream.micro0.s10 P.RestStream.micro0.S10 =
    some (P.RestStream.micro0.micro10.s86,P.RestStream.micro0.micro10.S86) := by host_kernel_rfl

theorem source_producer : Source1086.producer = 22587 := rfl

theorem source_dimensions : Source1086.inputSizes = [1,4,10240] ∧ Source1086.first = [0,1,0] ∧
    Source1086.last = [1,4,10240] := ⟨rfl,rfl,rfl⟩

theorem source_branch : Source1086.kind = SliceResult.fresh := rfl

/-- error: host_retained_fixedSlice: expected three dimensions -/
#guard_msgs in
host_retained_fixedSlice Host.Load.ffi,
  {Source1086.input with ctl := .call (.obj 4713) (.obj 4817) [.ptr (.js 3126780) 0,.big 29372,
    .ptr (.js 3126752) 0,.big 4,.ptr (.js 3126754) 0,.big 3,.ptr (.js 3126768) 0,.big 3,.big 2]}
  using P.RestStream.micro0.micro10.S86 to Source1086.output using P.RestStream.micro0.micro10.S87 as RejectRank

/-- error: host_retained_fixedSlice: expected source call -/
#guard_msgs in
host_retained_fixedSlice Host.Load.ffi, Source1086.output using P.RestStream.micro0.micro10.S87
  to Source1086.output using P.RestStream.micro0.micro10.S87 as RejectReturn

/-- error: (kernel) declaration type mismatch -/
#guard_msgs (error, substring := true) in
run_cmd do
  let saved ← Lean.getEnv
  try
    Host.Ts.Owned.Parametric.Driver.emit "host_retained_fixedSlice Host.Load.ffi, Source1086.input using P.RestStream.micro0.micro10.S86 to Source1086.input using P.RestStream.micro0.micro10.S86 as RejectWrongEndpoint"
  finally Lean.setEnv saved

end Host.Load.Run.Full.Ordinary.FixedSlice
