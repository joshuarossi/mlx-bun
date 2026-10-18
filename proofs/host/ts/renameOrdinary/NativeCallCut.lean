import host.ts.RenameRouteDriver
import host.ts.renameOrdinary.NativeCallCutStates
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
set_option Elab.async false
namespace Host.Load.Run.Full.Ordinary.NativeCall
open Host.Ts
noncomputable def input : St P.F.S := P.RestStream.micro0.micro23.s82
noncomputable def output : St P.F.S := P.RestStream.micro0.micro23.s83
noncomputable def native : Host.Mlx.Ffi.St := (show Host.Load.LSt from input.ffi).mlx
noncomputable def outputBytes : List Byte := match (input.obj? 3126924).map Obj.kind with
  | some (.buf bytes) => bytes
  | _ => []
end Host.Load.Run.Full.Ordinary.NativeCall
namespace Host.Load.Run.Full
host_transport_object P.RestStream.micro0.micro23 82 4782 as Ordinary.NativeCall.calleeObject
end Host.Load.Run.Full
namespace Host.Load.Run.Full.Ordinary.NativeCall
open Host.Ts
noncomputable def calleeCaps : List Val := match calleeObject.kind with
  | .fn (.native (.ffi .symbol) caps) => caps
  | _ => []
theorem actual_control : input.ctl = .call (.obj 4782) (.obj 4817)
    [.ptr (.js 3126924) 0,.big (Int.ofNat 1354),.big (Int.ofNat 29376)] := by host_kernel_rfl
theorem actual_callee : (input.obj? 4782).map Obj.kind =
    some (.fn (.native (.ffi .symbol) calleeCaps)) := by host_kernel_rfl
theorem actual_symbol : calleeCaps.head? = some (.str chars!"mlx_closure_apply") := by host_kernel_rfl
theorem actual_output_buffer : (input.obj? 3126924).map Obj.kind = some (.buf outputBytes) := by host_kernel_rfl
theorem actual_output_bytes : outputBytes.length = 8 := by host_kernel_rfl
end Host.Load.Run.Full.Ordinary.NativeCall
