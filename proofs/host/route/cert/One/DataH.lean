import host.route.cert.Seg
import host.simgraph.prompt.ChooseRoute
import host.route.cert.One.Choice
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
set_option Elab.async false
set_option autoImplicit false
namespace Host.Route.Cert.One
open Host.Ts Host.Ts.Sim Host.Mlx Host.Mlx.FfiEval Host.Mlx.SimGraph Host.Load.Run.Tpl Host.Load.Run.Full
open Host.Ts.Sim.Full (mlxOf)

/-! # The one-token prompt's sampled cut: what its certificate reads

The first decode step's head and sampler, literal in their dimensions, on the template at the sampled cut: every number at this
prompt's constant valuation. -/

noncomputable def nativeH : Ffi.St := mlxOf PRE_pl_common.s1.ffi

noncomputable def GsH : Nat → Option (RNode PDim InKey) :=
  restrictTo (exactTplDom 15235 15235 [5554869888] nativeH)
    (symGraphD (clsH PRE_pl_common.S1) PDim.lit SourceKernels.sources nativeH)

end Host.Route.Cert.One
