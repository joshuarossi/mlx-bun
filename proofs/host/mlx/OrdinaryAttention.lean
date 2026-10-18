import host.mlx.OrdinaryAttentionStates
import host.mlx.NativeAttentionFrontend

set_option Elab.async false
set_option maxRecDepth 1000000
set_option maxHeartbeats 1000000

namespace Host.Load.Run.Full.Ordinary.Attention
open Host.Ts Host.Mlx.Ffi Host.Mlx.Ffi.NativeRoles

host_retained_attention Host.Load.ffi, P.RestStream.micro0.micro510.s11 using P.RestStream.micro0.micro510.S11
  to P.RestStream.micro0.micro510.s12 using P.RestStream.micro0.micro510.S12 as Source51011

theorem source_prefix : runS P.F 11 P.RestStream.micro0.s510 P.RestStream.micro0.S510 =
    some (P.RestStream.micro0.micro510.s11,P.RestStream.micro0.micro510.S11) := by host_kernel_rfl

theorem source_geometry : Source51011.qn.shape = ([1,24,1,256] : List Int).map Dim.lit ∧
    Source51011.kn.shape = ([1,4,4,256] : List Int).map Dim.lit ∧
    Source51011.vn.shape = ([1,4,4,256] : List Int).map Dim.lit := ⟨rfl,rfl,rfl⟩

theorem source_producer_ids : Source51011.q = 22670 ∧ Source51011.k = 22674 ∧ Source51011.v = 22675 := ⟨rfl,rfl,rfl⟩

theorem source_mask : Source51011.mask = [] := rfl

theorem source_output_node : Source51011.output.ffi.mlx.nodes.get Source51011.input.ffi.mlx.nnext =
    some (attentionNode Source51011.q Source51011.k Source51011.v (AttentionHost.scaleValue Source51011.scale)
      Source51011.mask Source51011.qn Source51011.kn Source51011.vn) := by host_kernel_rfl

theorem source_counters : Source51011.output.ffi.mlx.next = Source51011.input.ffi.mlx.next+1 ∧
    Source51011.output.ffi.mlx.nnext = Source51011.input.ffi.mlx.nnext+1 := ⟨rfl,rfl⟩

/-- error: host_retained_attention: expected source call -/
#guard_msgs in
host_retained_attention Host.Load.ffi, Source51011.output using P.RestStream.micro0.micro510.S12
  to Source51011.output using P.RestStream.micro0.micro510.S12 as RejectReturn

/-- error: (kernel) declaration type mismatch -/
#guard_msgs (error, substring := true) in
run_cmd do
  let saved ← Lean.getEnv
  try
    Host.Ts.Owned.Parametric.Driver.emit "host_retained_attention Host.Load.ffi, Source51011.input using P.RestStream.micro0.micro510.S11 to Source51011.input using P.RestStream.micro0.micro510.S11 as RejectWrongEndpoint"
  finally Lean.setEnv saved

end Host.Load.Run.Full.Ordinary.Attention
