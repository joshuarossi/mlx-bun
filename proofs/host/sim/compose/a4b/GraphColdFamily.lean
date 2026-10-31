import host.sim.compose.a4b.GraphColdNormalized
import host.sim.compose.a4b.GraphColdJoin
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
set_option Elab.async false
namespace Host.Ts.Sim.Compose.ColdGraph
open _root_.Host.Mlx _root_.Host.Mlx.FfiEval _root_.Host.Mlx.SimGraph
open _root_.Host.Load.Run.Full.Expected
theorem hidden_original : run (hiddenG id 0 (0 : Int) (1 : Int) stages) [] =
    ((normalized.1, cacheNodes), normalized.2) := by
  have hc := suffix0
  simp only [List.drop_zero] at hc
  exact hiddenG_join id 0 (0 : Int) (1 : Int) stages embedded.1 fragment63.1.1 cacheNodes
    normalized.1 [] embedded.2 fragment63.2 normalized.2 embedded.eq_original.symm hc normalized_eq.symm

theorem expected_family : expected = familyGraph hiddenFamily.ops id 0 1 stages := by
  have hnat := hiddenG_natural PDim.lit id 0 (0 : Int) (1 : Int) stages []
  simp only [List.map_nil] at hnat
  rw [hidden_original, normalized_prefix] at hnat
  have h := congrArg (fun r : (Nat × List (Nat × Nat)) × List (RNode PDim InKey) => (r.2,r.1)) hnat
  exact h.symm.trans (hidden_familyGraph id stages).symm

end Host.Ts.Sim.Compose.ColdGraph
