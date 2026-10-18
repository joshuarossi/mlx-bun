import host.mlx.OrdinaryVectorGetCut
import host.mlx.NativeVectorGetFrontend

set_option Elab.async false
set_option maxRecDepth 1000000
set_option maxHeartbeats 1000000

namespace Host.Load.Run.Full.Ordinary.VectorGetRetained
open Host.Ts Host.Ts.Owned.Parametric Host.Mlx.Ffi
noncomputable def input : St LSt := VectorGetCall.input
noncomputable def output : St LSt := VectorGetCall.output
host_retained_vectorGet Host.Load.ffi, input using P.RestStream.micro0.micro25.S7
  to output using P.RestStream.micro0.micro25.S8 as Source2507

theorem selected_existing_node : Source2507.node = 22591 ∧
    output.ffi.mlx.nodeId? input.ffi.mlx.next = some Source2507.node := ⟨by host_kernel_rfl,by host_kernel_rfl⟩

theorem source_counters : output.ffi.mlx.next = input.ffi.mlx.next+1 ∧
    output.ffi.mlx.nnext = input.ffi.mlx.nnext := ⟨rfl,rfl⟩

run_cmd Lean.Elab.Command.liftTermElabM do
  let info ← Lean.getConstInfo ``Source2507.retained_transport
  Lean.Meta.forallTelescopeReducing info.type fun binders _ => do
    let mut names : Array Lean.Name := #[]
    for binder in binders do names := names.push (← Lean.Meta.getFVarLocalDecl binder).userName
    unless names.contains `indexSchema do throwError "vector get: current exact integer schema missing"
    for forbidden in [`nodeLive,`targetVector,`targetIndex,`targetRun] do
      if names.contains forbidden then throwError "vector get: future node/read premise remained"

/-- error: host_retained_vectorGet: expected source call -/
#guard_msgs in
host_retained_vectorGet Host.Load.ffi, output using P.RestStream.micro0.micro25.S8
  to output using P.RestStream.micro0.micro25.S8 as RejectReturn

/-- error: host_retained_vectorGet: source vector index is absent -/
#guard_msgs in
host_retained_vectorGet Host.Load.ffi,
  {input with ctl := .call (.obj Source2507.address) Source2507.sourceThis [.ptr (.js Source2507.out) 0,.big (Int.ofNat Source2507.handle),.big (Int.ofNat 3)]}
  using P.RestStream.micro0.micro25.S7 to output using P.RestStream.micro0.micro25.S8 as RejectIndex

/-- error: (kernel) declaration type mismatch -/
#guard_msgs (error, substring := true) in
run_cmd do
  let saved ← Lean.getEnv
  try
    Host.Ts.Owned.Parametric.Driver.emit "host_retained_vectorGet Host.Load.ffi, input using P.RestStream.micro0.micro25.S7 to input using P.RestStream.micro0.micro25.S7 as RejectEndpoint"
  finally Lean.setEnv saved
end Host.Load.Run.Full.Ordinary.VectorGetRetained
