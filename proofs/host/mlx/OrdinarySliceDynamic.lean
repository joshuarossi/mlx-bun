import host.mlx.OrdinarySliceDynamicStates
import host.mlx.NativeSliceDynamicFrontend

set_option Elab.async false
set_option maxRecDepth 1000000
set_option maxHeartbeats 1000000

namespace Host.Load.Run.Full.Ordinary.DynamicSlice
open Host.Ts Host.Mlx.Ffi Host.Mlx.Ffi.Annotated

noncomputable def input : St LSt := P.RestStream.micro0.micro15.s1
noncomputable def output : St LSt := P.RestStream.micro0.micro15.s2

host_retained_sliceDynamic Host.Load.ffi, input using P.RestStream.micro0.micro15.S1
  to output using P.RestStream.micro0.micro15.S2 as Source1549

theorem source_prefix : runS P.F 49 P.RestStream.micro0.s15 P.RestStream.micro0.S15 =
    some (input,P.RestStream.micro0.micro15.S1) := by host_kernel_rfl

theorem source_handle : Source1549.handle = 29373 ∧ Source1549.start = 18170 := ⟨rfl,rfl⟩

theorem source_geometry : Source1549.axes = [0] ∧ Source1549.sizes = [1,3,10240] ∧
    Source1549.node.shape = ([1,3,10240] : List Int).map Dim.lit ∧ Source1549.startNode.shape = [] ∧
    Source1549.startNode.dtype = 7 := ⟨rfl,rfl,rfl,rfl,rfl⟩

theorem source_counters : output.ffi.mlx.next = input.ffi.mlx.next+1 ∧
    output.ffi.mlx.nnext = input.ffi.mlx.nnext+1 := ⟨rfl,rfl⟩

run_cmd Lean.Elab.Command.liftTermElabM do
  let info ← Lean.getConstInfo ``Source1549.retained_transport
  Lean.Meta.forallTelescopeReducing info.type fun binders _ => do
    let mut names : Array Lean.Name := #[]
    for binder in binders do
      names := names.push (← Lean.Meta.getFVarLocalDecl binder).userName
    for required in [`closedAxes,`closedSizes] do
      unless names.contains required do throwError "dynamic slice: missing current closed-note schema"
    for forbidden in [`targetSizes,`targetValues,`targetRank,`targetRun] do
      if names.contains forbidden then throwError "dynamic slice: future target premise remained"

/-- error: host_retained_sliceDynamic: expected source call -/
#guard_msgs in
host_retained_sliceDynamic Host.Load.ffi, output using P.RestStream.micro0.micro15.S2
  to output using P.RestStream.micro0.micro15.S2 as RejectReturn

/-- error: host_retained_sliceDynamic: expected size count matching input rank -/
#guard_msgs in
host_retained_sliceDynamic Host.Load.ffi,
  {input with ctl := .call (.obj 4793) (.obj 4817) [.ptr (.js 3126833) 0,.big 29373,.big 18170,
    .ptr (.js 3126819) 0,.big 1,.ptr (.js 3126821) 0,.big 4,.big 2]}
  using P.RestStream.micro0.micro15.S1 to output using P.RestStream.micro0.micro15.S2 as RejectRank

/-- error: (kernel) declaration type mismatch -/
#guard_msgs (error, substring := true) in
run_cmd do
  let saved ← Lean.getEnv
  try
    Host.Ts.Owned.Parametric.Driver.emit "host_retained_sliceDynamic Host.Load.ffi, input using P.RestStream.micro0.micro15.S1 to input using P.RestStream.micro0.micro15.S1 as RejectEndpoint"
  finally Lean.setEnv saved

end Host.Load.Run.Full.Ordinary.DynamicSlice
