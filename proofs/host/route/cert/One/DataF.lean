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

/-! # The one-token prompt's final forward: what its certificate reads

The first decode step's graph, literal in its dimensions, up to the normalized hidden state, on the template at the forward's
return: every number at this prompt's constant valuation. -/

noncomputable def nativeF : Ffi.St := mlxOf D1Body.s155.ffi

noncomputable def GsF : Nat → Option (RNode PDim InKey) :=
  restrictTo (exactTplDom 15235 15235 [5554869888] nativeF)
    (ffiGraph (Host.Ts.Sim.Compose.ColdGraph.coldNums D1Body.S155) SourceKernels.sources nativeF)

end Host.Route.Cert.One
