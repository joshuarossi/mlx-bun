import host.route.cert.Fin.D1X0.Choose
import host.route.cert.Seg
import host.simgraph.prompt.ChooseRoute
import host.sim.template.a4pre_first_tail_x0_r0_suffix.m.B0
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
set_option Elab.async false
set_option autoImplicit false
namespace Host.Route.Cert.Fin.D1X0
open Host.Ts Host.Ts.Sim Host.Mlx Host.Mlx.FfiEval Host.Mlx.SimGraph Host.Load Host.Load.Extract Host.Load.Run.Tpl
open Host.Route.Cert.Fin
open Host.Ts.Sim.Full (mlxOf)

/-! # The D1X0 class's first forward: what its certificate reads -/

noncomputable def native : Ffi.St := mlxOf PRE_first_tail_x0_r0_suffix.s0.ffi
noncomputable abbrev Gs := gsV native PRE_first_tail_x0_r0_suffix.inputSrv box vars (-2)
def insT : InKey → Option Nat := inputsOf choice.inputs

end Host.Route.Cert.Fin.D1X0
