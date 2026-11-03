import host.route.cert.Head.X4L9.Choose
import host.route.cert.Seg
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
set_option Elab.async false
set_option autoImplicit false
namespace Host.Route.Cert.Head.X4L9
open Host.Ts Host.Ts.Sim Host.Mlx Host.Mlx.FfiEval Host.Mlx.SimGraph Host.Load Host.Load.Extract Host.Load.Run.Tpl
open Host.Route.Cert.Fin
open Host.Ts.Sim.Full (mlxOf)

/-! # The X4L9 class's sampled cut: what its certificate reads -/

noncomputable def nativeH : Ffi.St := mlxOf PRE_plx4_L9_common.s1.ffi
noncomputable abbrev GsH := gsV nativeH PRE_plx4_L9_common.S1 boxH varsH (-1)

end Host.Route.Cert.Head.X4L9
