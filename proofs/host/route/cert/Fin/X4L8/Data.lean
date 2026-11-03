import host.route.cert.Fin.X4L8.Choose
import host.route.cert.Seg
import host.simgraph.prompt.ChooseRoute
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
set_option Elab.async false
set_option autoImplicit false
namespace Host.Route.Cert.Fin.X4L8
open Host.Ts Host.Ts.Sim Host.Mlx Host.Mlx.FfiEval Host.Mlx.SimGraph Host.Load Host.Load.Extract Host.Load.Run.Tpl
open Host.Route.Cert.Fin
open Host.Ts.Sim.Full (mlxOf)

/-! # The X4L8 class's final forward: what its certificate reads -/

noncomputable def native : Ffi.St := mlxOf PRE_fd_x4_L8_r0_body.s451.ffi
noncomputable abbrev Gs := gsV native PRE_fd_x4_L8_r0_body.S451 box vars (-1)
def insT : InKey → Option Nat := inputsOf choice.inputs

end Host.Route.Cert.Fin.X4L8
