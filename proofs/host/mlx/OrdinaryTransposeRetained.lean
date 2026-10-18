import host.mlx.OrdinaryTransposeStates
import host.mlx.NativeTransposeFrontend

set_option Elab.async false
set_option maxRecDepth 1000000
set_option maxHeartbeats 1000000

namespace Host.Load.Run.Full.Ordinary.TransposeRetained
open Host.Ts Host.Ts.Owned Host.Ts.Owned.Parametric Host.Mlx.Ffi Host.Mlx.Ffi.Annotated
noncomputable def input : St LSt := P.RestStream.micro0.micro454.s1
noncomputable def output : St LSt := P.RestStream.micro0.micro454.s2
host_retained_transpose Host.Load.ffi, input using P.RestStream.micro0.micro454.S1
  to output using P.RestStream.micro0.micro454.S2 as Source45409

theorem source_prefix : runS P.F 9 P.RestStream.micro0.s454 P.RestStream.micro0.S454 =
    some (input,P.RestStream.micro0.micro454.S1) := by host_kernel_rfl

theorem source_counters : output.ffi.mlx.next = input.ffi.mlx.next+1 ∧
    output.ffi.mlx.nnext = input.ffi.mlx.nnext+1 := ⟨rfl,rfl⟩

run_cmd Lean.Elab.Command.liftTermElabM do
  let info ← Lean.getConstInfo ``Source45409.retained_transport
  Lean.Meta.forallTelescopeReducing info.type fun binders _ => do
    let mut names : Array Lean.Name := #[]
    for binder in binders do names := names.push (← Lean.Meta.getFVarLocalDecl binder).userName
    for forbidden in [`inputSchema,`targetShape,`targetDimensions,`targetPermutation,`targetRun] do
      if names.contains forbidden then throwError "transpose: frozen input or future target premise remained"

/-- error: host_retained_transpose: expected source call -/
#guard_msgs in
host_retained_transpose Host.Load.ffi, output using P.RestStream.micro0.micro454.S2
  to output using P.RestStream.micro0.micro454.S2 as RejectReturn

noncomputable def badRank : St LSt := input.setFfi
  {input.ffi with mlx := {input.ffi.mlx with nodes := input.ffi.mlx.nodes.set Source45409.producer {Source45409.node with shape := []}}}

/-- error: host_retained_transpose: expected axis count matching input rank -/
#guard_msgs in
host_retained_transpose Host.Load.ffi, badRank using P.RestStream.micro0.micro454.S1
  to output using P.RestStream.micro0.micro454.S2 as RejectRank

/-- error: (kernel) declaration type mismatch -/
#guard_msgs (error, substring := true) in
run_cmd do
  let saved ← Lean.getEnv
  try
    Host.Ts.Owned.Parametric.Driver.emit "host_retained_transpose Host.Load.ffi, input using P.RestStream.micro0.micro454.S1 to input using P.RestStream.micro0.micro454.S1 as RejectEndpoint"
  finally Lean.setEnv saved
end Host.Load.Run.Full.Ordinary.TransposeRetained
