import host.sim.template.Chain
import host.sim.template.FullWorld
set_option Elab.async false
namespace Host.Load.Run.Tpl
open Host.Ts

private def nativeDecodeLoad : Host.Load.LSt :=
  ⟨Host.Mlx.Ffi.init [] [] [] [], Host.Load.HostSt.init [] [] [] 0 [] []⟩

private def nativeDecodeCtor : St Host.Load.Layers.full.S :=
  ⟨.nil, 40, .ret (.bool true), [],
    ⟨[], Host.Load.Layers.start ⟨nativeDecodeLoad, Host.Mlx.FfiAne.St.empty⟩, [], []⟩⟩

private def nativeDecodeApplied : St Host.Load.Layers.full.S :=
  (fun p : St Host.Load.Layers.full.S × Unit => p.1) (nativeDecodeCtor, ())

private def nativeDecodeSrv : SSrv :=
  ⟨[.var 0, .var 1, .var 2, .var 3, .var 4, .var 5, .var 6, .var 7, .var 8], []⟩

set_option maxRecDepth 1000000 in
set_option maxHeartbeats 0 in
set_option interpreter.prefer_native true in
tpl_chain NativeDecodeCtor from nativeDecodeCtor, nativeDecodeSrv : "{\"stop\":\"steps:1\",\"frames\":[],\"lens\":[]}" (world := full)

set_option maxRecDepth 1000000 in
set_option maxHeartbeats 0 in
set_option interpreter.prefer_native true in
tpl_chain NativeDecodeApplied from nativeDecodeApplied, nativeDecodeSrv : "{\"stop\":\"steps:1\",\"frames\":[],\"lens\":[]}" (world := full)

host_stream_state NativeDecodeCtor 0
host_stream_state NativeDecodeCtor 1
host_stream_state NativeDecodeApplied 0
host_stream_state NativeDecodeApplied 1

kernel_rfl NativeDecodeApplied.start_exact : NativeDecodeApplied.s0 = nativeDecodeApplied
kernel_rfl NativeDecodeCtor.checked :
  runS Host.Load.Layers.full 1 nativeDecodeCtor nativeDecodeSrv = some (NativeDecodeCtor.s1, NativeDecodeCtor.S1)
kernel_rfl NativeDecodeApplied.checked :
  runS Host.Load.Layers.full 1 nativeDecodeApplied nativeDecodeSrv = some (NativeDecodeApplied.s1, NativeDecodeApplied.S1)

end Host.Load.Run.Tpl
