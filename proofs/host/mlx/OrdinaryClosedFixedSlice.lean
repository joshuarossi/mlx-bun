import host.mlx.OrdinaryFixedSlice
import host.mlx.NativeClosedFixedSliceFrontend
import host.mlx.NativeClosedShapeTest

set_option Elab.async false
set_option maxRecDepth 1000000
set_option maxHeartbeats 1000000

namespace Host.Load.Run.Full.Ordinary.ClosedFixedSlice
open Host.Ts Host.Mlx.Ffi Host.Mlx.Ffi.Annotated

host_retained_closedFixedSlice Host.Load.ffi, SliceCall.input using P.RestStream.micro0.micro10.S86
  to SliceCall.output using P.RestStream.micro0.micro10.S87 as Source1086

theorem source_geometry : Source1086.Normalized.inputSizes = [1,4,10240] ∧
    Source1086.Normalized.first = [0,1,0] ∧ Source1086.Normalized.last = [1,4,10240] := ⟨rfl,rfl,rfl⟩

theorem source_prefix : runS P.F 86 P.RestStream.micro0.s10 P.RestStream.micro0.S10 =
    some (P.RestStream.micro0.micro10.s86,P.RestStream.micro0.micro10.S86) := FixedSlice.source_prefix

/-- Closed arithmetic remains a supported current annotation representation. -/
theorem sum_history_schema : closedLiteralShape ClosedShapeTest.historyShape = true :=
  ClosedShapeTest.history_closed

run_cmd Lean.Elab.Command.liftTermElabM do
  let info ← Lean.getConstInfo ``Source1086.retained_transport
  Lean.Meta.forallTelescopeReducing info.type fun binders _ => do
    let mut names : Array Lean.Name := #[]
    for binder in binders do
      names := names.push (← Lean.Meta.getFVarLocalDecl binder).userName
    for required in [`closedShape,`closedStart,`closedStop,`closedStride] do
      unless names.contains required do throwError "closed fixed slice: missing current closed-note schema"
    for forbidden in [`inputSchema,`sourceValues,`targetValues] do
      if names.contains forbidden then throwError "closed fixed slice: normalized/future geometry premise remained"

/-- error: host_retained_fixedSlice: expected three dimensions -/
#guard_msgs in
host_retained_closedFixedSlice Host.Load.ffi,
  {SliceCall.input with ctl := .call (.obj 4713) (.obj 4817) [.ptr (.js 3126780) 0,.big 29372,
    .ptr (.js 3126752) 0,.big 4,.ptr (.js 3126754) 0,.big 3,.ptr (.js 3126768) 0,.big 3,.big 2]}
  using P.RestStream.micro0.micro10.S86 to SliceCall.output using P.RestStream.micro0.micro10.S87 as RejectRank

/-- error: (kernel) declaration type mismatch -/
#guard_msgs (error, substring := true) in
run_cmd do
  let saved ← Lean.getEnv
  try
    Host.Ts.Owned.Parametric.Driver.emit "host_retained_closedFixedSlice Host.Load.ffi, SliceCall.input using P.RestStream.micro0.micro10.S86 to SliceCall.input using P.RestStream.micro0.micro10.S86 as RejectWrongEndpoint"
  finally Lean.setEnv saved

end Host.Load.Run.Full.Ordinary.ClosedFixedSlice
