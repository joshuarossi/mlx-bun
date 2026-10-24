import host.sim.conv.Merge
import host.sim.stage.Mlx
namespace Host.Ts.Sim.Conv
open Host.Ts Host.Ts.Sim Host.Ts.Sim.Stage

/-! # The merged state as a definition

`mergeSt σ τ rs wr s s2 x` is the caller's state after a stage call: the call heap with the
template's written and fresh entries `wr` pushed by `τ` at `σ`'s addresses (`setAll`), the counter
past the template's allocations, the template's return control, stack (above the caller frames
`rs`), jobs and stores pushed by `τ`, the template's new events pushed in front of the call's, and
the merged native state `x`. `mergeSt_mer`: it satisfies `Mer` when `σ` is injective on `wr`, `wr`
has no duplicates and its images are in the stores' range. The generator emits only the
definition's arguments; no kernel check of the merged state is needed. -/

/-- The merged heap. -/
def mergeHeap (σ τ : Map) (wr : List Nat) (h : PTrie HObj) (h2 : PTrie HObj) : PTrie HObj :=
  setAll h (wr.filterMap fun b => (h2.get b).map fun o => (σ.a b, τ.hobj o))

/-- **The merged state.** -/
def mergeSt {S : Type} (σ τ : Map) (rs : List Frame) (wr : List Nat) (s s2 s0 : St S) (x : S) : St S :=
  ⟨mergeHeap σ τ wr s.heap s2.heap, s.next + (s2.next - s0.next), τ.ctl s2.ctl, s2.stack.map τ.frame ++ rs,
    ⟨s2.jobs.map τ.job, x, (s2.trace.take (s2.trace.length - s0.trace.length)).map τ.event ++ s.trace,
      τ.stores s2.stores⟩⟩

section
variable {S : Type} {σ τ : Map} {wr : List Nat} {h h2 : PTrie HObj}

private theorem fst_mem {a : Nat} {o : HObj}
    (hm : (a, o) ∈ wr.filterMap fun b => (h2.get b).map fun o => (σ.a b, τ.hobj o)) : ∃ b ∈ wr, σ.a b = a := by
  obtain ⟨b, hb, he⟩ := List.mem_filterMap.1 hm
  cases hg : h2.get b with
  | none => rw [hg] at he; cases he
  | some o' => rw [hg] at he; cases he; exact ⟨b, hb, rfl⟩

theorem mergeHeap_kept (hbd : ∀ b ∈ wr, σ.a b / 4096 < 4 ^ 31) {a : Nat} (ha : ∀ b ∈ wr, σ.a b ≠ a) :
    (mergeHeap σ τ wr h h2).get a = h.get a := by
  refine setAll_get _ _ a fun e he => ?_
  obtain ⟨a', o⟩ := e
  obtain ⟨b, hb, rfl⟩ := fst_mem he
  exact ⟨ha b hb, hbd b hb⟩

theorem mergeHeap_ovr (hbd : ∀ b ∈ wr, σ.a b / 4096 < 4 ^ 31) (hnd : wr.Nodup)
    (hinj : ∀ b c, b ∈ wr → c ∈ wr → σ.a b = σ.a c → b = c) {b : Nat} (hb : b ∈ wr) {o : HObj}
    (hg : h2.get b = some o) : (mergeHeap σ τ wr h h2).get (σ.a b) = some (τ.hobj o) := by
  have hkeys : ((wr.filterMap fun b => (h2.get b).map fun o => (σ.a b, τ.hobj o)).map (·.1)).Nodup := by
    have e : (wr.filterMap fun b => (h2.get b).map fun o => (σ.a b, τ.hobj o)).map (·.1) =
        (wr.filter fun b => (h2.get b).isSome).map σ.a := by
      clear hb hnd hinj hbd hg
      induction wr with
      | nil => rfl
      | cons c l ih =>
        cases hc : h2.get c with
        | none => simp [hc, ih]
        | some o => simp [hc, ih]
    rw [e]
    exact (List.Nodup.filter _ hnd).map_on fun x hx y hy hxy =>
      hinj x y (List.mem_of_mem_filter hx) (List.mem_of_mem_filter hy) hxy
  have hm : (σ.a b, τ.hobj o) ∈ wr.filterMap fun b => (h2.get b).map fun o => (σ.a b, τ.hobj o) :=
    List.mem_filterMap.2 ⟨b, hb, by rw [hg]; rfl⟩
  exact setAll_get_mem _ _ _ _ hkeys hm fun e he => by
    obtain ⟨a', o'⟩ := e
    obtain ⟨c, hc, rfl⟩ := fst_mem he
    exact hbd c hc

end

/-- **The merged state satisfies `Mer`.** -/
theorem mergeSt_mer {S : Type} {σ τ : Map} {rs : List Frame} {wr : List Nat} {s s2 s0 : St S} {x : S}
    (hbd : ∀ b ∈ wr, σ.a b / 4096 < 4 ^ 31) (hnd : wr.Nodup)
    (hinj : ∀ b c, b ∈ wr → c ∈ wr → σ.a b = σ.a c → b = c) (hwrP : ∀ b ∈ wr, Present s2 b)
    (htr : ∃ fr, s2.trace = fr ++ s0.trace) :
    Mer σ τ rs wr s0 s s2 (mergeSt σ τ rs wr s s2 s0 x) where
  ovr b hb := by
    obtain ⟨o, hg⟩ := Present.get (hwrP b hb)
    show (mergeHeap σ τ wr s.heap s2.heap).get (σ.a b) = _
    rw [mergeHeap_ovr hbd hnd hinj hb hg, hg]; rfl
  kept a ha := mergeHeap_kept hbd ha
  next := rfl
  ctl := rfl
  stack := rfl
  jobs := rfl
  stores := rfl
  trace := by
    obtain ⟨fr, hfr⟩ := htr
    refine ⟨fr, hfr, ?_⟩
    show (s2.trace.take (s2.trace.length - s0.trace.length)).map τ.event ++ s.trace = _
    rw [hfr]
    simp

end Host.Ts.Sim.Conv
