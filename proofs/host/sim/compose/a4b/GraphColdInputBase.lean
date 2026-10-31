import host.sim.compose.a4b.GraphColdCert
import host.simgraph.iter.InputsPrefix
import host.load.run.full.InputValues
import host.load.CacheCarriersCommand
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
set_option Elab.async false
namespace Host.Ts.Sim.Compose.ColdGraph
open _root_.Host.Ts _root_.Host.Ts.Sim _root_.Host.Load _root_.Host.Load.Extract
open _root_.Host.Load.Run.Full _root_.Host.Mlx _root_.Host.Mlx.FfiEval _root_.Host.Mlx.SimGraph
open _root_.Host.Mlx.SimGraph.Iter

def cacheInputs : List (Option Nat × Option Nat) := List.replicate 64 (none, none)
def returnHandle : Nat := 22016
noncomputable def feedHandle : Nat := ((tensor endLoad (.obj 2827805)).map Tensor.handle).getD 0
end Host.Ts.Sim.Compose.ColdGraph
