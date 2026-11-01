import host.route.cert.VW8.Data
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
set_option Elab.async false
set_option autoImplicit false
namespace Host.Route.Cert.VW8
open Host.Ts Host.Ts.Sim Host.Mlx Host.Mlx.FfiEval Host.Mlx.SimGraph Host.Load.Run.Tpl
open Host.Mlx.SimGraph.Tpl.Fam

/-! # The x8 forward's certificate: its small facts -/

kernel_rfl kinds_ok : choice.kind.all (fun e => (native.objs.get e.1).isSome) = true
kernel_rfl outs_ok : VW83.cacheNodes.all (fun q => Nat.blt q.1 choice.cert.length && Nat.blt q.2 choice.cert.length &&
  Nat.blt (certAt choice.cert q.1) native.nnext && Nat.blt (certAt choice.cert q.2) native.nnext) = true
kernel_rfl outs_len : VW83.cacheNodes.length = 64
kernel_rfl graph_len : VW83.graph.length = 5018
kernel_rfl cert_len : choice.cert.length = 5018

end Host.Route.Cert.VW8
