import host.route.cert.Fin.VW.Choose
import host.route.cert.Seg
import host.simgraph.prompt.ChooseRoute
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
set_option Elab.async false
set_option autoImplicit false
namespace Host.Route.Cert.Fin.VW
open Host.Ts Host.Ts.Sim Host.Mlx Host.Mlx.FfiEval Host.Mlx.SimGraph Host.Load.Run.Tpl
open Host.Ts.Sim.Full (mlxOf)

/-! # The VW class's final forward: what its certificate reads -/

noncomputable def native : Ffi.St := mlxOf PRE_fd_vw_r0_body.s900.ffi
noncomputable abbrev Gs := gsV native PRE_fd_vw_r0_body.S900 box vars (-1)
def insT : InKey → Option Nat := inputsOf choice.inputs

end Host.Route.Cert.Fin.VW
