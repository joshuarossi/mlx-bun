import host.mlx.OrdinaryVectorSizeCut
import host.mlx.NativeVectorSizeFrontend

set_option Elab.async false
set_option maxRecDepth 1000000
set_option maxHeartbeats 1000000

namespace Host.Load.Run.Full.Ordinary.VectorSizeRetained
open Host.Ts
noncomputable def input : St LSt := VectorSizeCall.input
noncomputable def output : St LSt := VectorSizeCall.output
host_retained_vectorSize Host.Load.ffi, input using P.RestStream.micro0.micro24.S28
  to output using P.RestStream.micro0.micro24.S29 as Source2428

theorem source_return : output.ctl = .ret (.big (Int.ofNat 3)) := by host_kernel_rfl
theorem unchanged : output.ffi = input.ffi ∧ output.heap = input.heap := ⟨rfl,rfl⟩

/-- error: host_retained_vectorSize: expected source call -/
#guard_msgs in
host_retained_vectorSize Host.Load.ffi, output using P.RestStream.micro0.micro24.S29
  to output using P.RestStream.micro0.micro24.S29 as RejectReturn

/-- error: (kernel) declaration type mismatch -/
#guard_msgs (error, substring := true) in
run_cmd do
  let saved ← Lean.getEnv
  try
    Host.Ts.Owned.Parametric.Driver.emit "host_retained_vectorSize Host.Load.ffi, input using P.RestStream.micro0.micro24.S28 to input using P.RestStream.micro0.micro24.S28 as RejectEndpoint"
  finally Lean.setEnv saved
end Host.Load.Run.Full.Ordinary.VectorSizeRetained
