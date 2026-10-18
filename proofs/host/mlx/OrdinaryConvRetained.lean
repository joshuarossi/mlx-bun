import host.mlx.OrdinaryConvCut
import host.mlx.NativeConvFrontend

set_option Elab.async false
set_option maxRecDepth 1000000
set_option maxHeartbeats 1000000

namespace Host.Load.Run.Full.Ordinary.ConvRetained
open Host.Ts Host.Mlx.Ffi Host.Mlx.Ffi.Annotated

host_retained_conv1d Host.Load.ffi, ConvCall.input using P.RestStream.micro0.micro18.S56
  to ConvCall.output using P.RestStream.micro0.micro18.S57 as Source1856

theorem source_prefix : runS P.F 56 P.RestStream.micro0.s18 P.RestStream.micro0.S18 =
    some (ConvCall.input,P.RestStream.micro0.micro18.S56) := by host_kernel_rfl

theorem source_geometry : Source1856.inputSizes = [1,4,10240] ∧ Source1856.weightSizes = [10240,4,1] ∧
    Source1856.outputSizes = [1,1,10240] := ⟨rfl,rfl,rfl⟩

run_cmd Lean.Elab.Command.liftTermElabM do
  let info ← Lean.getConstInfo ``Source1856.retained_transport
  Lean.Meta.forallTelescopeReducing info.type fun binders _ => do
    let mut names : Array Lean.Name := #[]
    for binder in binders do
      names := names.push (← Lean.Meta.getFVarLocalDecl binder).userName
    for required in [`closedInput,`closedWeight,`strideSchema,`paddingSchema,`dilationSchema,`groupsSchema] do
      unless names.contains required do throwError "convolution: missing current closed-note schema"
    for forbidden in [`inputSchema,`weightSchema,`targetGeometry,`targetShape,`targetRun] do
      if names.contains forbidden then throwError "convolution: future target geometry premise remained"

/-- error: host_retained_conv1d: expected source call -/
#guard_msgs in
host_retained_conv1d Host.Load.ffi, ConvCall.output using P.RestStream.micro0.micro18.S57
  to ConvCall.output using P.RestStream.micro0.micro18.S57 as RejectReturn

noncomputable def badRank : St LSt :=
  ConvCall.input.setFfi {ConvCall.input.ffi with mlx :=
    {ConvCall.native with nodes := ConvCall.native.nodes.set 22587 {ConvCall.inputNode with shape := [.lit 1,.lit 1,.lit 4,.lit 10240]}}}

/-- error: host_retained_conv1d: expected rank-three literal inputs -/
#guard_msgs in
host_retained_conv1d Host.Load.ffi, badRank using P.RestStream.micro0.micro18.S56
  to ConvCall.output using P.RestStream.micro0.micro18.S57 as RejectRank

/-- error: (kernel) declaration type mismatch -/
#guard_msgs (error, substring := true) in
run_cmd do
  let saved ← Lean.getEnv
  try
    Host.Ts.Owned.Parametric.Driver.emit "host_retained_conv1d Host.Load.ffi, ConvCall.input using P.RestStream.micro0.micro18.S56 to ConvCall.input using P.RestStream.micro0.micro18.S56 as RejectEndpoint"
  finally Lean.setEnv saved

end Host.Load.Run.Full.Ordinary.ConvRetained
