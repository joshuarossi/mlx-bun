import host.route.cert.Seg
import host.simgraph.prompt.ChooseRoute
import host.sim.compose.a4b.GraphColdCert
import host.sim.template.a4pre_pl_common.Run
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

def boxH : Box := [(9, 1, 1), (10, 1, 1), (11, 1, 1), (16, 256, 256)]

/-- The constant valuation of the box. -/
def nuH (j : Nat) : Int := if j = 16 then 256 else 1

/-- A number's value at the box's valuation. -/
def clsH (S : SSrv) (x : NumV) : Option PDim := (clsOfX S boxH x).map fun d => PDim.lit (d.eval nuH)

noncomputable def nativeH : Ffi.St := mlxOf PRE_pl_common.s4.ffi

noncomputable def GsH : Nat → Option (RNode PDim InKey) :=
  restrictTo (exactTplDom 15235 15235 [5554869888] nativeH)
    (symGraphD (clsH PRE_pl_common.S4) PDim.lit SourceKernels.sources nativeH)

/-- The expected graph, built natively. -/
def EcnH : List (RNode PDim InKey) :=
  (stepGraph Expected.stages Expected.head 0).1.map (Host.Mlx.SimGraph.mapN PDim.lit)

end Host.Route.Cert.One
