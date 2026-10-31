import host.sim.compose.a4b.GraphColdOutputRange0
import host.sim.compose.a4b.GraphColdOutputRange1
import host.sim.compose.a4b.GraphColdOutputRange2
import host.sim.compose.a4b.GraphColdOutputRange3
import host.sim.compose.a4b.GraphColdEndpointReturn2
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
set_option Elab.async false
namespace Host.Ts.Sim.Compose.ColdGraph
open _root_.Host.Ts _root_.Host.Ts.Sim _root_.Host.Load _root_.Host.Load.Extract
open _root_.Host.Load.Run.Full _root_.Host.Mlx _root_.Host.Mlx.FfiEval _root_.Host.Mlx.SimGraph
open _root_.Host.Mlx.SimGraph.Iter


private theorem slice_eq_get {α : Type} (A B : List α) (lo width k : Nat)
    (he : (A.drop lo).take width = (B.drop lo).take width)
    (hl : lo ≤ k) (hh : k < lo + width) : A[k]? = B[k]? := by
  have hw : k - lo < width := by omega
  have h := congrArg (fun xs : List α => xs[k-lo]?) he
  simpa only [List.getElem?_take_of_lt hw, List.getElem?_drop, Nat.add_sub_of_le hl] using h

theorem outputs_check : choice.outputs = fullExpected.2.2.map (certifiedCachePair choice.cert) := by
  apply List.ext_getElem?
  intro k
  by_cases hk : k < 64
  · by_cases h0 : k < 16
    · exact slice_eq_get _ _ 0 16 k outputs_slice0 (by omega) (by omega)
    · by_cases h1 : k < 32
      · exact slice_eq_get _ _ 16 16 k outputs_slice1 (by omega) (by omega)
      · by_cases h2 : k < 48
        · exact slice_eq_get _ _ 32 16 k outputs_slice2 (by omega) (by omega)
        · exact slice_eq_get _ _ 48 16 k outputs_slice3 (by omega) (by omega)
  · rw [List.getElem?_eq_none (by rw [output_count]; omega),
      List.getElem?_eq_none (by rw [List.length_map, full_all_cache_pairs]; omega)]
end Host.Ts.Sim.Compose.ColdGraph
