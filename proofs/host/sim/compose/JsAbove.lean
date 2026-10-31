import host.sim.conv.CompactJs
import host.sim.BigFreeP
namespace Host.Ts.Sim.Compose
open Host.Ts Host.Ts.Sim Host.Ts.Sim.Conv

/-- A bigint that is a JS pointer at or above `n`. -/
def jsAboveB (n : Nat) (i : Int) : Bool :=
  match jsPtrOf i with
  | some (b, _) => Nat.ble n b
  | none => false

theorem jsAboveB_mono {n n' : Nat} (hn : n ≤ n') {i : Int} (h : jsAboveB n' i = true) : jsAboveB n i = true := by
  unfold jsAboveB at h ⊢
  cases hp : jsPtrOf i with
  | none => simp [hp] at h
  | some p =>
    obtain ⟨b, off⟩ := p
    simp only [hp] at h ⊢
    exact Nat.ble_eq_true_of_le (Nat.le_trans hn (Nat.le_of_ble_eq_true h))

/-- A compaction moves only addresses at or above the call's counter, so any JS pointer it
breaks lies there. -/
theorem jsShiftBad_above {n0 n1 nS : Nat} {pl : List Nat} {nr : List NumV} {D : Template.RData} {i : Int}
    (h : jsShiftBadB (Map.compact n0 n1 nS pl nr D.big D.region D.nodeF) i = true) : jsAboveB n0 i = true := by
  cases hp : jsPtrOf i with
  | none => simp only [jsShiftBadB, hp] at h; cases h
  | some p =>
    obtain ⟨b, off⟩ := p
    obtain ⟨he, hb, _⟩ := jsPtrOf_some hp
    simp only [jsAboveB, hp]
    apply Nat.ble_eq_true_of_le
    refine Nat.le_of_not_lt fun hn => ?_
    have ha : (Map.compact n0 n1 nS pl nr D.big D.region D.nodeF).a b = b :=
      Map.compact_lt (by omega)
    have hi : (Map.compact n0 n1 nS pl nr D.big D.region D.nodeF).big i = i :=
      rdata_big_js D i (by rw [hp]; exact Option.some_ne_none _)
    unfold jsShiftBadB at h
    simp only [hp] at h
    rw [ha, hi, he] at h
    simp only [decide_true, Nat.blt_eq.mpr hb, Bool.and_self, Bool.not_true] at h
    cases h

variable {S : Type}

/-- No heap entry of `s` holds a JS pointer at or above `n`. -/
def JsHeapAbove (n : Nat) (s : St S) : Prop :=
  ∀ a o, s.heap.get a = some o → NoBig.hobj (fun i => jsAboveB n i = true) o

theorem JsHeapAbove.step {n n' : Nat} {s s' : St S} {l : List Nat} (h : JsHeapAbove n s) (hn : n ≤ n')
    (hch : ∀ a, a ∉ l → s'.heap.get a = s.heap.get a)
    (hck : l.all (noBigAtP (jsAboveB n') s') = true) : JsHeapAbove n' s' := by
  intro a o ho
  by_cases ha : a ∈ l
  · have hc := List.all_eq_true.mp hck a ha
    unfold noBigAtP at hc
    rw [ho] at hc
    exact noBigHobjP_sound (fun _ hi => hi) hc
  · exact NoBig.hobj_mono (fun _ hi => jsAboveB_mono hn hi) (h a o ((hch a ha).symm.trans ho))

/-- The heap's freedom and the checked roots give any bigint freedom below the check's predicate. -/
theorem noBigSt_of_above {n : Nat} {s : St S} {I : Int → Prop} (h : JsHeapAbove n s)
    (hroots : noBigRootsP (jsAboveB n) s.trace s = true) (hp : ∀ i, I i → jsAboveB n i = true) :
    NoBigSt I s.trace s := by
  have hs := hroots
  simp only [noBigRootsP, Bool.and_eq_true, List.all_eq_true] at hs
  exact ⟨fun a o ho => NoBig.hobj_mono hp (h a o ho), noBigCtlP_sound hp hs.1.1.1.1,
    fun f hf => noBigFrameP_sound hp (hs.1.1.1.2 f hf),
    fun j hj => noBigJobP_sound hp (hs.1.1.2 j hj), noBigStoresP_sound hp hs.1.2,
    fun e he => noBigEventP_sound hp (hs.2 e he)⟩

end Host.Ts.Sim.Compose
