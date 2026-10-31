import host.sim.template.Chain
import host.sim.template.FullWorld
set_option Elab.async false
namespace Host.Load.Run.Tpl
open Host.Ts

private def decodeLoad : Host.Load.LSt :=
  ⟨Host.Mlx.Ffi.init [] [] [] [], Host.Load.HostSt.init [] [] [] 0 [] []⟩

private def decodeCtor : St Host.Load.Layers.full.S :=
  ⟨.nil, 40, .ret (.bool true), [],
    ⟨[], Host.Load.Layers.start ⟨decodeLoad, Host.Mlx.FfiAne.St.empty⟩, [], []⟩⟩

private def decodeApplied : St Host.Load.Layers.full.S :=
  (fun p : St Host.Load.Layers.full.S × Unit => p.1) (decodeCtor, ())

private def decodeSrv : SSrv := ⟨[], []⟩
private def decodeTabSrv : SSrv :=
  ⟨[.var 0, .var 1, .var 2, .var 3, .var 4, .var 5, .var 6, .var 7, .var 8], []⟩

kernel_rfl DecodeTab.server_exact : decodeTabSrv = ⟨Host.Load.Decode.tab, []⟩

set_option maxRecDepth 1000000 in
set_option maxHeartbeats 0 in
set_option interpreter.prefer_native false in
tpl_chain DecodeCtor from decodeCtor, decodeSrv : "{\"stop\":\"steps:1\",\"frames\":[]}" (world := full)

set_option maxRecDepth 1000000 in
set_option maxHeartbeats 0 in
set_option interpreter.prefer_native false in
tpl_chain DecodeApplied from decodeApplied, decodeSrv : "{\"stop\":\"steps:1\",\"frames\":[]}" (world := full)

set_option maxRecDepth 1000000 in
set_option maxHeartbeats 0 in
set_option interpreter.prefer_native false in
tpl_chain DecodeTab from decodeApplied, decodeTabSrv : "{\"stop\":\"steps:1\",\"frames\":[]}" (world := full)

host_stream_state DecodeCtor 0
host_stream_state DecodeCtor 1
host_stream_state DecodeApplied 0
host_stream_state DecodeApplied 1
host_stream_state DecodeTab 0
host_stream_state DecodeTab 1

kernel_rfl DecodeCtor.checked :
  runS Host.Load.Layers.full 1 decodeCtor decodeSrv = some (DecodeCtor.s1, DecodeCtor.S1)
kernel_rfl DecodeApplied.checked :
  runS Host.Load.Layers.full 1 decodeApplied decodeSrv = some (DecodeApplied.s1, DecodeApplied.S1)
kernel_rfl DecodeTab.checked :
  runS Host.Load.Layers.full 1 decodeApplied ⟨Host.Load.Decode.tab, []⟩ = some (DecodeTab.s1, DecodeTab.S1)

end Host.Load.Run.Tpl
