import host.mlx.OrdinaryRopeStates
import host.mlx.NativeRopeFrontend

set_option Elab.async false
set_option maxRecDepth 1000000
set_option maxHeartbeats 1000000

namespace Host.Load.Run.Full.Ordinary.RopeRetained
open Host.Ts Host.Mlx.Ffi Host.Mlx.Ffi.Annotated
noncomputable def input : St LSt := P.RestStream.micro0.micro472.s1
noncomputable def output : St LSt := P.RestStream.micro0.micro472.s2

host_retained_rope Host.Load.ffi, input using P.RestStream.micro0.micro472.S1
  to output using P.RestStream.micro0.micro472.S2 as Source47295

theorem source_prefix : runS P.F 95 P.RestStream.micro0.s472 P.RestStream.micro0.S472 =
    some (input,P.RestStream.micro0.micro472.S1) := by host_kernel_rfl

theorem source_parameters : Source47295.dims = 64 ∧ Source47295.offsetValue = F64.ofInt 3 := ⟨rfl,rfl⟩

theorem source_counters : output.ffi.mlx.next = input.ffi.mlx.next+1 ∧
    output.ffi.mlx.nnext = input.ffi.mlx.nnext+1 := ⟨rfl,rfl⟩

run_cmd Lean.Elab.Command.liftTermElabM do
  let info ← Lean.getConstInfo ``Source47295.retained_transport
  Lean.Meta.forallTelescopeReducing info.type fun binders _ => do
    let mut names : Array Lean.Name := #[]
    for binder in binders do names := names.push (← Lean.Meta.getFVarLocalDecl binder).userName
    unless names.contains `offset do throwError "RoPE: current offset expression missing"
    for forbidden in [`closedOffset,`sourceOffset,`targetOffset,`targetValue,`targetRun,`D,`D₀] do
      if names.contains forbidden then throwError "RoPE: frozen offset/future target/server premise remained"

/-- error: host_retained_rope: expected source call -/
#guard_msgs in
host_retained_rope Host.Load.ffi, output using P.RestStream.micro0.micro472.S2
  to output using P.RestStream.micro0.micro472.S2 as RejectReturn

/-- error: host_retained_rope: expected literal offset occurrence -/
#guard_msgs in
host_retained_rope Host.Load.ffi,
  {input with ctl := .call (.obj Source47295.address) Source47295.sourceThis (Host.Load.Run.Full.Ordinary.RopeHost.rawArgs Source47295.out Source47295.handle Source47295.stream Source47295.dimValue Source47295.traditional Source47295.base Source47295.scale (.ref 0))}
  using P.RestStream.micro0.micro472.S1 to output using P.RestStream.micro0.micro472.S2 as RejectReference

noncomputable def badRank : St LSt := input.setFfi
  {input.ffi with mlx := {input.ffi.mlx with nodes := input.ffi.mlx.nodes.set Source47295.producer {Source47295.node with shape := [.lit 1,.lit 256]}}}

/-- error: host_retained_rope: expected input rank at least three -/
#guard_msgs in
host_retained_rope Host.Load.ffi, badRank using P.RestStream.micro0.micro472.S1
  to output using P.RestStream.micro0.micro472.S2 as RejectRank

/-- error: (kernel) declaration type mismatch -/
#guard_msgs (error, substring := true) in
run_cmd do
  let saved ← Lean.getEnv
  try
    Host.Ts.Owned.Parametric.Driver.emit "host_retained_rope Host.Load.ffi, input using P.RestStream.micro0.micro472.S1 to input using P.RestStream.micro0.micro472.S1 as RejectEndpoint"
  finally Lean.setEnv saved
end Host.Load.Run.Full.Ordinary.RopeRetained
