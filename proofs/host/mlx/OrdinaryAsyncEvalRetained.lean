import host.mlx.OrdinaryAsyncEvalStates
import host.mlx.NativeEvalFrontend

set_option Elab.async false
set_option maxRecDepth 1000000
set_option maxHeartbeats 1000000

namespace Host.Load.Run.Full.Ordinary.AsyncEvalRetained
open Host.Ts Host.Ts.Owned Host.Mlx.Ffi
noncomputable def input : St LSt := P.RestStream.micro0.micro612.s1
noncomputable def output : St LSt := P.RestStream.micro0.micro612.s2
host_retained_eval Host.Load.ffi, input using P.RestStream.micro0.micro612.S1
  to output using P.RestStream.micro0.micro612.S2 as Source61299

theorem source_prefix : runS P.F 99 P.RestStream.micro0.s612 P.RestStream.micro0.S612 =
    some (input,P.RestStream.micro0.micro612.S1) := by host_kernel_rfl

theorem original_async_mode : Source61299.mode = EvalHost.Mode.asyncVector := rfl

theorem no_native_or_heap_write : output.ffi = input.ffi ∧ output.heap = input.heap ∧ output.next = input.next := ⟨rfl,rfl,rfl⟩

run_cmd Lean.Elab.Command.liftTermElabM do
  let info ← Lean.getConstInfo ``Source61299.retained_transport
  Lean.Meta.forallTelescopeReducing info.type fun binders _ => do
    let mut names : Array Lean.Name := #[]
    for binder in binders do names := names.push (← Lean.Meta.getFVarLocalDecl binder).userName
    for forbidden in [`targetValid,`targetVector,`targetNode,`targetRun,`post] do
      if names.contains forbidden then throwError "eval: future target premise remained"

/-- error: host_retained_eval: expected source call -/
#guard_msgs in
host_retained_eval Host.Load.ffi, output using P.RestStream.micro0.micro612.S2
  to output using P.RestStream.micro0.micro612.S2 as RejectReturn

/-- error: host_retained_eval: source handle is absent -/
#guard_msgs in
host_retained_eval Host.Load.ffi,
  {input with ctl := .call (.obj Source61299.address) Source61299.sourceThis [.big (Int.ofNat input.ffi.mlx.next)]}
  using P.RestStream.micro0.micro612.S1 to output using P.RestStream.micro0.micro612.S2 as RejectAbsent

/-- error: (kernel) declaration type mismatch -/
#guard_msgs (error, substring := true) in
run_cmd do
  let saved ← Lean.getEnv
  try
    Host.Ts.Owned.Parametric.Driver.emit "host_retained_eval Host.Load.ffi, input using P.RestStream.micro0.micro612.S1 to input using P.RestStream.micro0.micro612.S1 as RejectEndpoint"
  finally Lean.setEnv saved
end Host.Load.Run.Full.Ordinary.AsyncEvalRetained
