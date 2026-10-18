import host.mlx.OrdinaryKvAppendStates
import host.mlx.NativeKvAppendFrontend

set_option Elab.async false
set_option maxRecDepth 1000000
set_option maxHeartbeats 0

namespace Host.Load.Run.Full.Ordinary.KvAppend
open Host.Ts Host.Mlx.Ffi Host.Ts.Owned Host.Ts.Owned.Annotated

/- The first attention key-cache append in the authoritative ordinary body. -/
host_retained_kvAppend Host.Load.ffi, P.RestStream.micro0.micro489.s4 using P.RestStream.micro0.micro489.S4
  to P.RestStream.micro0.micro489.s5 using P.RestStream.micro0.micro489.S5 as Source48904

theorem source_prefix : runS P.F 4 P.RestStream.micro0.s489 P.RestStream.micro0.S489 =
    some (P.RestStream.micro0.micro489.s4,P.RestStream.micro0.micro489.S4) := by host_kernel_rfl

theorem source_geometry : Source48904.node.shape = ([1,4,256,256] : List Int).map Dim.lit ∧
    Source48904.updateNode.shape = ([1,4,1,256] : List Int).map Dim.lit := ⟨rfl,rfl⟩

theorem source_producer_ids : Source48904.producer = 20291 ∧ Source48904.updateProducer = 22671 := ⟨rfl,rfl⟩

theorem source_counters : Source48904.input.ffi.mlx.next = 29492 ∧ Source48904.input.ffi.mlx.nnext = 22672 := ⟨rfl,rfl⟩

theorem source_start : (Source48904.input.obj? 3131480).map Obj.kind =
    some (.buf (shapeBytes (([0,0,3,0] : List Int).map Dim.lit))) := rfl

theorem source_stop : (Source48904.input.obj? 3131482).map Obj.kind =
    some (.buf (shapeBytes (([1,4,4,256] : List Int).map Dim.lit))) := rfl

theorem source_stride : (Source48904.input.obj? 3131497).map Obj.kind =
    some (.buf (shapeBytes (([1,1,1,1] : List Int).map Dim.lit))) := rfl

/-- error: host_retained_kvAppend: expected source call -/
#guard_msgs in
host_retained_kvAppend Host.Load.ffi, Source48904.output using P.RestStream.micro0.micro489.S5
  to Source48904.output using P.RestStream.micro0.micro489.S5 as RejectReturn

/-- error: host_retained_kvAppend: expected four dimensions -/
#guard_msgs in
host_retained_kvAppend Host.Load.ffi,
  {Source48904.input with ctl := .call (.obj 4714) (.obj 4817) [.ptr (.js 3131509) 0,.big 25850,.big 29491,.ptr (.js 3131480) 0,.big 3,.ptr (.js 3131482) 0,.big 4,.ptr (.js 3131497) 0,.big 4,.big 2]}
  using P.RestStream.micro0.micro489.S4 to Source48904.output using P.RestStream.micro0.micro489.S5 as RejectRank

/-- error: (kernel) declaration type mismatch -/
#guard_msgs (error, substring := true) in
run_cmd do
  let saved ← Lean.getEnv
  try
    Host.Ts.Owned.Parametric.Driver.emit "host_retained_kvAppend Host.Load.ffi, Source48904.input using P.RestStream.micro0.micro489.S4 to Source48904.input using P.RestStream.micro0.micro489.S4 as RejectWrongEndpoint"
  finally Lean.setEnv saved

end Host.Load.Run.Full.Ordinary.KvAppend
