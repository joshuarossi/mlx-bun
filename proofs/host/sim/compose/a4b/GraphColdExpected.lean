import host.sim.compose.a4b.GraphColdFamilyCore
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
set_option Elab.async false
namespace Host.Ts.Sim.Compose.ColdGraph
open _root_.Host.Mlx _root_.Host.Mlx.FfiEval _root_.Host.Mlx.SimGraph

def expectedInt : List (RNode Int InKey) := Host.Load.Run.Full.Expected.graph.take 4010
def expected : List (RNode PDim InKey) × Nat × List (Nat × Nat) :=
  (expectedInt.map (Host.Mlx.SimGraph.mapN PDim.lit), 4009, Host.Load.Run.Full.Expected.cacheOutputs)

kernel_rfl hidden_length : expected.1.length = 4010
kernel_rfl hidden_output : expected.2.1 = 4009
kernel_rfl all_cache_pairs : expected.2.2 = Host.Load.Run.Full.Expected.cacheOutputs
kernel_rfl all_layers : stages.length = 64
kernel_rfl full_suffix_length : (Host.Load.Run.Full.Expected.graph.drop 4010).length = 10

theorem full_graph_split : Host.Load.Run.Full.Expected.graph =
    expectedInt ++ Host.Load.Run.Full.Expected.graph.drop 4010 := by
  exact (List.take_append_drop 4010 Host.Load.Run.Full.Expected.graph).symm
end Host.Ts.Sim.Compose.ColdGraph
