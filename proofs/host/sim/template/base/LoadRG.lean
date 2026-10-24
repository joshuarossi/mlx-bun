import host.sim.template.base.LoadR
import host.sim.native.gen.Rel
namespace Host.Load.Run.Tpl
open Host.Ts Host.Ts.Sim

/-! The base relation of the decode template (`Base.loadR`, prompt length 1) as an instance of
the general native relation (`Host.Ts.Sim.G.LoadR`): the whole pre-loop band keeps its ids. -/

theorem Base.loadRG (τ : List NumV) :
    G.LoadR { loadP0 with rest := τ } loadP0.NL Base.M Base.S0.tab.length Base.s0.ffi (Base.Y τ) :=
  (Base.loadR τ).toG

end Host.Load.Run.Tpl
