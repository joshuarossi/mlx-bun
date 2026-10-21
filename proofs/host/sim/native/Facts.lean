import host.sim.native.Call
namespace Host.Ts.Sim

/-! # Map facts the JavaScript dispatcher needs (`NativeFacts`, dispatch/Base.lean)

For the load world's native predicates `loadIsHandle` (present handles) and
`loadIsRegion` (shape and string regions of present handles, host regions below
`cbBase`), the native relation gives the facts of `NativeFacts`. Host regions
are fixed below `cbBase` only: a `JSCallback` region `cbBase + a` follows `M.a`. -/

def loadIsHandle (x : Host.Load.LSt) (i : Int) : Bool := decide (0 ≤ i) && isPH x.mlx i.toNat

def loadIsRegion (x : Host.Load.LSt) (r : Nat) : Bool :=
  ((r % 4 == 0 || r % 4 == 1) && isPH x.mlx (r / 4)) || (r % 4 == 3 && decide (r < cbBase))

section
variable {P : LoadP} {M : Map} {n : Nat} {x y : Host.Load.LSt} (hr : LoadR P M n x y)
include hr

theorem LoadR.zero_fact (i : Int) : (M.big i == 0) = (i == 0) := hr.mlx.zero i

omit hr in
private theorem handle_of {i : Int} (h : loadIsHandle x i = true) :
    ∃ k, i = Int.ofNat k ∧ PH x.mlx k := by
  simp only [loadIsHandle, Bool.and_eq_true, decide_eq_true_eq, isPH_iff] at h
  exact ⟨i.toNat, by rw [Int.ofNat_eq_natCast, Int.toNat_of_nonneg h.1], h.2⟩

theorem LoadR.inj_fact (i j : Int) (hi : loadIsHandle x i = true)
    (hj : (j < 0 ∨ (0 ≤ j ∧ j < (P.lo : Int))) ∨ loadIsHandle x j = true) (he : M.big i = M.big j) : i = j := by
  obtain ⟨a, rfl, ha⟩ := handle_of hi
  have mr := hr.mlx
  rcases hj with hj | hj
  · have hjl : j < P.lo := by omega
    exact mr.big_inj_fixed ha hjl he
  · obtain ⟨b, rfl, hb⟩ := handle_of hj
    rw [mr.big_inj ha hb he]

theorem LoadR.range_fact (i : Int) (hi : loadIsHandle x i = true) : 0 ≤ M.big i ∧ M.big i < 2 ^ 63 := by
  obtain ⟨a, rfl, ha⟩ := handle_of hi
  have := hr.mlx.big_range ha
  exact ⟨this.1, this.2.1⟩

theorem LoadR.host_fact (r : Nat) (h3 : r % 4 = 3) (hlt : r < cbBase) : M.region r = r := by
  have e : r = 4 * (r / 4) + 3 := by omega
  rw [e]
  exact hr.hostReg _ (by unfold cbBase at hlt; omega)

theorem LoadR.cb_fact (f : Nat) (hf : cbBase ≤ f) : M.region f = cbBase + M.a (f - cbBase) := by
  have e : f = cbBase + (f - cbBase) := by omega
  conv => lhs; rw [e]
  exact hr.cbr _

theorem LoadR.region_fact (r r' : Nat) (hr1 : loadIsRegion x r = true) (hr2 : loadIsRegion x r' = true)
    (he : M.region r = M.region r') : r = r' := by
  have mr := hr.mlx
  have hcb : cbBase = 2 ^ 48 := rfl
  -- the image of a region
  have img : ∀ s, loadIsRegion x s = true →
      ((s % 4 = 0 ∨ s % 4 = 1) ∧ PH x.mlx (s / 4) ∧ M.region s = 4 * M.handle (s / 4) + s % 4) ∨
        (s % 4 = 3 ∧ s < cbBase ∧ M.region s = s) := by
    intro s hs
    simp only [loadIsRegion, Bool.or_eq_true, Bool.and_eq_true, beq_iff_eq, decide_eq_true_eq, isPH_iff] at hs
    rcases hs with ⟨h01, hp⟩ | ⟨h3, hl⟩
    · left
      refine ⟨h01, hp, ?_⟩
      rcases h01 with h0 | h1
      · have e : s = 4 * (s / 4) := by omega
        rw [h0]; conv => lhs; rw [e]
        rw [(mr.present _ hp).2.1]; omega
      · have e : s = 4 * (s / 4) + 1 := by omega
        rw [h1]; conv => lhs; rw [e]
        exact (mr.present _ hp).2.2
    · exact .inr ⟨h3, hl, hr.host_fact s h3 hl⟩
  rcases img r hr1 with ⟨h01, hp, e1⟩ | ⟨h3, hl, e1⟩ <;>
    rcases img r' hr2 with ⟨h01', hp', e2⟩ | ⟨h3', hl', e2⟩
  · rw [e1, e2] at he
    have hm : r % 4 = r' % 4 := by omega
    have hh : M.handle (r / 4) = M.handle (r' / 4) := by omega
    have := mr.hinj _ _ hp hp' hh
    omega
  · rw [e1, e2] at he
    omega
  · rw [e1, e2] at he
    omega
  · rw [e1, e2] at he; exact he
end

end Host.Ts.Sim
