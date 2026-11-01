import host.route.cert.Row.R2.Choose
import host.sim.template.a4pre_pl_r2.H0
import host.sim.template.a4pre_pl_r2.H27
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
set_option Elab.async false
set_option autoImplicit false
namespace Host.Route.Cert.Row.R2
open Host.Ts Host.Ts.Sim Host.Mlx Host.Mlx.FfiEval Host.Mlx.SimGraph Host.Load.Run.Tpl
open Host.Ts.Sim.Full (mlxOf)

/-! # POST row `r2`: what its certificate reads -/

noncomputable def native : Ffi.St := mlxOf PRE_pl_r2.s890.ffi
noncomputable abbrev Gs := rowGs native PRE_pl_r2.S890 ((1 : Nat) : Int)
def insT : InKey → Option Nat := inputsOf choice.inputs

end Host.Route.Cert.Row.R2
