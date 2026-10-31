import host.sim.compose.PreCall

namespace Host.Ts.Sim.Compose
open Host.Ts Host.Ts.Sim Host.Ts.Sim.Prefill Host.Ts.Sim.Full
open Host.Ts.Sim.Lin Host.Ts.Sim.Lin.Cls

/-- Quantities returned by a site without compaction remain available under its
fresh result variables. -/
theorem post_mergeP {ν : Nat → F64} {i : Cls.Inst} {m : List (Nat × Q)}
    {ws : List Nat} {qs : List Q} {f : Nat → F64}
    (hVB : VBOkF loopVB ν) (hm : MapOk ν i m)
    (hnd : ws.Nodup) (hlen : qs.length = ws.length)
    (hfresh : ∀ p ∈ m, p.1 ∉ ws)
    (hres : ∀ j w q, nth? ws j = some w → nth? qs j = some q →
      f j = F64.ofNat (i.get q))
    (hbound : ∀ j w q, nth? ws j = some w → nth? qs j = some q →
      i.get q ≤ loopVB w) :
    VBOkF loopVB (Conv.resVal ν ws f) ∧
      MapOk (Conv.resVal ν ws f) i (m ++ ws.zip qs) := by
  constructor
  · intro v
    by_cases hv : v ∈ ws
    · obtain ⟨j, hj⟩ := Conv.nth?_of_mem hv
      obtain ⟨q, hq⟩ := Conv.nth?_some_of_lt (show j < qs.length by
        rw [hlen]; exact nth?_lt _ _ _ hj)
      exact ⟨i.get q, hbound j v q hj hq,
        (Conv.resVal_at hnd hj).trans (hres j v q hj hq)⟩
    · rw [Conv.resVal_off hv]
      exact hVB v
  · apply Conv.mapOk_iff'.2
    intro p hp
    rcases List.mem_append.mp hp with hp | hp
    · rw [Conv.resVal_off (hfresh p hp)]
      exact Conv.mapOk_iff'.1 hm p hp
    · obtain ⟨j, hj⟩ := Conv.nth?_of_mem hp
      obtain ⟨hw, hq⟩ := Conv.nth?_zip_some ws hj
      exact (Conv.resVal_at hnd hw).trans (hres j p.1 p.2 hw hq)

end Host.Ts.Sim.Compose
