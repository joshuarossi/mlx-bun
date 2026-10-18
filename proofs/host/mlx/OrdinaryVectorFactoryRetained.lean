import host.mlx.OrdinaryVectorFactoryCut
import host.mlx.NativeVectorFactoryFrontend

set_option Elab.async false
set_option maxRecDepth 1000000
set_option maxHeartbeats 1000000

namespace Host.Load.Run.Full.Ordinary.VectorFactoryRetained
open Host.Ts Host.Ts.Owned.Parametric
noncomputable def input : St LSt := VectorFactoryCall.input
noncomputable def output : St LSt := VectorFactoryCall.output
host_retained_vectorNew Host.Load.ffi, input using P.RestStream.micro0.micro23.S50
  to output using P.RestStream.micro0.micro23.S51 as Source2350

theorem fresh_empty_vector : output.ffi.mlx.obj? input.ffi.mlx.next = some (.vec []) := by host_kernel_rfl
theorem source_counters : output.ffi.mlx.next = input.ffi.mlx.next+1 ∧
    output.ffi.mlx.nnext = input.ffi.mlx.nnext := ⟨rfl,rfl⟩

/-- error: host_retained_vectorNew: expected source call -/
#guard_msgs in
host_retained_vectorNew Host.Load.ffi, output using P.RestStream.micro0.micro23.S51
  to output using P.RestStream.micro0.micro23.S51 as RejectReturn

/-- error: (kernel) declaration type mismatch -/
#guard_msgs (error, substring := true) in
run_cmd do
  let saved ← Lean.getEnv
  try
    Host.Ts.Owned.Parametric.Driver.emit "host_retained_vectorNew Host.Load.ffi, input using P.RestStream.micro0.micro23.S50 to input using P.RestStream.micro0.micro23.S50 as RejectEndpoint"
  finally Lean.setEnv saved
end Host.Load.Run.Full.Ordinary.VectorFactoryRetained
