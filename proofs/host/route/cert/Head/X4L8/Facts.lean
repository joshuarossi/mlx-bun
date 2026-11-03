import host.route.cert.Head.X4L8.Data
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
set_option Elab.async false
set_option autoImplicit false
namespace Host.Route.Cert.Head.X4L8
open Host.Ts Host.Ts.Sim Host.Mlx Host.Mlx.FfiEval Host.Mlx.SimGraph Host.Load Host.Load.Extract Host.Load.Run.Tpl
open Host.Route.Cert.Fin

/-! # The X4L8 class's sampled cut: its small facts -/

kernel_rfl cert_len : Nat.ble Tpl.Ordinary.graph.length choiceH.cert.length = true
kernel_rfl tok_below : Nat.blt (certAt choiceH.cert Tpl.Ordinary.tokenNode) nativeH.nnext = true
kernel_rfl outs_below : Tpl.Ordinary.cacheOutputs.all (fun q =>
  Nat.blt (certAt choiceH.cert q.1) nativeH.nnext && Nat.blt (certAt choiceH.cert q.2) nativeH.nnext) = true

end Host.Route.Cert.Head.X4L8
