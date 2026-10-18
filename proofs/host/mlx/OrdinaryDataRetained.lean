import host.mlx.OrdinaryDataStates
import host.mlx.NativeDataFrontend

set_option Elab.async false
set_option maxRecDepth 1000000
set_option maxHeartbeats 1000000

namespace Host.Load.Run.Full.Ordinary.DataRetained
open Host.Ts Host.Mlx.Ffi Host.Mlx.Ffi.Annotated
noncomputable def input : St LSt := P.RestStream.micro0.micro43.s1
noncomputable def output : St LSt := P.RestStream.micro0.micro43.s2

host_retained_arrayNewData Host.Load.ffi, input using P.RestStream.micro0.micro43.S1
  to output using P.RestStream.micro0.micro43.S2 as Source4318

theorem source_prefix : runS P.F 18 P.RestStream.micro0.s43 P.RestStream.micro0.S43 =
    some (input,P.RestStream.micro0.micro43.S1) := by host_kernel_rfl

theorem source_geometry : Source4318.shape = [1] ∧ Source4318.dtype = 7 := ⟨rfl,rfl⟩

theorem source_counters : output.ffi.mlx.next = input.ffi.mlx.next+1 ∧
    output.ffi.mlx.nnext = input.ffi.mlx.nnext+1 := ⟨rfl,rfl⟩

run_cmd Lean.Elab.Command.liftTermElabM do
  let info ← Lean.getConstInfo ``Source4318.retained_transport
  Lean.Meta.forallTelescopeReducing info.type fun binders _ => do
    let mut names : Array Lean.Name := #[]
    for binder in binders do names := names.push (← Lean.Meta.getFVarLocalDecl binder).userName
    for required in [`payload,`selectedData,`closedShape,`countSchema,`dtypeSchema] do
      unless names.contains required do throwError "array data: current annotation premise missing"
    for forbidden in [`targetBytes,`targetPayload,`sourceBytes,`targetShape,`targetRun] do
      if names.contains forbidden then throwError "array data: independent payload/target premise remained"

/-- error: host_retained_arrayNewData: expected source call -/
#guard_msgs in
host_retained_arrayNewData Host.Load.ffi, output using P.RestStream.micro0.micro43.S2
  to output using P.RestStream.micro0.micro43.S2 as RejectReturn

/-- error: host_retained_arrayNewData: expected zero pointer offset -/
#guard_msgs in
host_retained_arrayNewData Host.Load.ffi,
  {input with ctl := .call (.obj 4631) (.obj 4817) [.ptr (.js 3127113) 8,.ptr (.js 3127123) 0,.num one,.num (.lit (F64.ofInt 7))]}
  using P.RestStream.micro0.micro43.S1 to output using P.RestStream.micro0.micro43.S2 as RejectOffset

/-- error: (kernel) declaration type mismatch -/
#guard_msgs (error, substring := true) in
run_cmd do
  let saved ← Lean.getEnv
  try
    Host.Ts.Owned.Parametric.Driver.emit "host_retained_arrayNewData Host.Load.ffi, input using P.RestStream.micro0.micro43.S1 to input using P.RestStream.micro0.micro43.S1 as RejectEndpoint"
  finally Lean.setEnv saved
end Host.Load.Run.Full.Ordinary.DataRetained
