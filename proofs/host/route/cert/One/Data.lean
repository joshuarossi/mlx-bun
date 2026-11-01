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
open Host.Ts.Sim.Compose.ColdGraph (fullExpected)

/-! # The one-token prompt's sampled cut: what its certificate reads

The first decode step's graph, literal in its dimensions: every number of the template at this prompt's constant
valuation. -/

def box : Box := [(9, 1, 1), (10, 1, 1), (11, 1, 1), (16, 256, 256)]

/-- The constant valuation of the box. -/
def nu (j : Nat) : Int := if j = 16 then 256 else 1

/-- A number's value at the box's valuation. -/
def cls (S : SSrv) (x : NumV) : Option PDim := (clsOfX S box x).map fun d => PDim.lit (d.eval nu)

noncomputable def native : Ffi.St := mlxOf PRE_pl_common.s4.ffi

noncomputable def Gs : Nat → Option (RNode PDim InKey) :=
  restrictTo (exactTplDom 15235 15235 [5554869888] native)
    (symGraphD (cls PRE_pl_common.S4) PDim.lit SourceKernels.sources native)

/-- The expected graph, built natively. -/
def Ecn : List (RNode PDim InKey) :=
  (stepGraph Expected.stages Expected.head 0).1.map (Host.Mlx.SimGraph.mapN PDim.lit)

end Host.Route.Cert.One
