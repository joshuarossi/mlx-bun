import host.sim.compose.GraphData
import host.sim.full.BridgeFrame

namespace Host.Ts.Sim.Compose
open Host.Ts.Sim Host.Ts.Sim.Full Host.Mlx.SimGraph

/-- **The pinned decode world's graph projection**: the load-world part of a full-world state, the relation's
general part (`FullRB.load`). -/
def fullProjFb (b0 : Host.Mlx.FfiAne.St) (NB : Nat) : GraphProj (fullWorldFb b0 NB) where
  toLoad x := Host.Load.Layers.toLoad x
  mlx _ := rfl
  lp P r := { P with rest := r }
  NB _ := NB
  load h := h.load
  rest _ _ := rfl

end Host.Ts.Sim.Compose
