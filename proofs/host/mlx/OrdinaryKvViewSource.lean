import host.mlx.OrdinaryKvViewStates
import host.ts.RenameKernelRfl

set_option Elab.async false
set_option maxRecDepth 1000000
set_option maxHeartbeats 0

namespace Host.Load.Run.Full.Ordinary.KvViewSource
open Host.Ts

noncomputable def input : St LSt := P.RestStream.micro0.micro500.s36
noncomputable def initialServer : SSrv := P.RestStream.micro0.micro500.S36
noncomputable def output : St LSt := P.RestStream.micro0.micro500.s37
noncomputable def nextServer : SSrv := P.RestStream.micro0.micro500.S37

theorem source_prefix : runS P.F 36 P.RestStream.micro0.s500 P.RestStream.micro0.S500 =
    some (input,initialServer) := by host_kernel_rfl

theorem source_next : runS P.F 1 input initialServer = some (output,nextServer) := by host_kernel_rfl

theorem source_control : input.ctl = .call (.obj 4713) (.obj 4817)
    [.ptr (.js 3131616) 0,.big 29492,.ptr (.js 3131587) 0,.big 4,
      .ptr (.js 3131589) 0,.big 4,.ptr (.js 3131604) 0,.big 4,.big 2] := by host_kernel_rfl

end Host.Load.Run.Full.Ordinary.KvViewSource
