import host.sim.compose.a4b.GraphColdExpected
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
set_option Elab.async false
namespace Host.Ts.Sim.Compose.ColdGraph
open _root_.Host.Mlx _root_.Host.Mlx.FfiEval _root_.Host.Mlx.SimGraph

def fullFamily : RowFamily InKey :=
  d1Family id Host.Load.Run.Full.Expected.head (PDim.lit 0) (PDim.lit 1)

def fullExpected : List (RNode PDim InKey) × Nat × List (Nat × Nat) :=
  (Host.Load.Run.Full.Expected.graph.map (Host.Mlx.SimGraph.mapN PDim.lit),
    Host.Load.Run.Full.Expected.tokenNode, Host.Load.Run.Full.Expected.cacheOutputs)

theorem stepGraph_to_family (ss : List StageLayout) (head : LinLayout) :
    ((stepGraph ss head 0).1.map (Host.Mlx.SimGraph.mapN PDim.lit), (stepGraph ss head 0).2) =
      familyGraph (d1Family id head (PDim.lit 0) (PDim.lit 1)).ops id 0 1 ss := by
  have hnat := stepG_natural PDim.lit 0 id (0 : Int) (1 : Int) id ss head []
  simp only [List.map_nil] at hnat
  unfold familyGraph
  rw [show (d1Family id head (PDim.lit 0) (PDim.lit 1)).ops =
    d1Ops id head (PDim.lit 0) (PDim.lit 1) from rfl, forwardP_d1]
  exact (congrArg (fun r : (Nat × List (Nat × Nat)) × List (RNode PDim InKey) => (r.2,r.1)) hnat).symm

theorem full_expected_family : fullExpected = familyGraph fullFamily.ops id 0 1 stages := by
  have base := congrArg (fun r : List (RNode Int InKey) × Nat × List (Nat × Nat) =>
    (r.1.map (Host.Mlx.SimGraph.mapN PDim.lit), r.2)) Host.Load.Run.Full.Expected.graph_original
  exact base.symm.trans (stepGraph_to_family stages Host.Load.Run.Full.Expected.head)

kernel_rfl full_length : fullExpected.1.length = 4020
kernel_rfl full_output : fullExpected.2.1 = 4019
kernel_rfl full_all_cache_pairs : fullExpected.2.2.length = 64
end Host.Ts.Sim.Compose.ColdGraph
