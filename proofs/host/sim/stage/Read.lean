import host.sim.stage.Spec
import host.sim.LinGood
namespace Host.Ts.Sim.Stage
open Host.Ts

/-! # Reading a stage template's return state

Helpers a stage contract uses to state and check what a call returned and left alone: a
returned number as a natural number through the server (`natAt`, `natAt_ref`, `toIndex_ie`),
an instantiated table entry (`nth_inst`), and the isolated frame of a template class
(`framed_of`: the return heap is the call heap with only fresh entries added, `setAll`,
`freshOf`; jobs, stores and trace unchanged; the native state the call's). -/

/-- A number value's natural number through the server (an integer in `[0, 2^53)`). -/
def natAt (C : CSrv) : Val → Option Nat
  | .num x => (C.val x).bind F64.toIndex?
  | _ => none

theorem toIndex_ie (n : Nat) (h : n < 2 ^ 53) : F64.toIndex? (Lin.ie n) = some n := by
  by_cases h0 : n = 0
  · subst h0; rfl
  · have e : Lin.ie (n : Int) = F64.fin false n 0 := by
      rw [Lin.ie_ne (by omega)]
      congr 1 <;> simp
    rw [e]
    show (bif Nat.blt (n * 2 ^ 0) (2 ^ 53) then some (n * 2 ^ 0) else none) = some n
    rw [Nat.pow_zero, Nat.mul_one, Nat.blt_eq.mpr h]
    rfl

theorem natAt_ref {C : CSrv} {i n : Nat} (h : nth? C.tab i = some (Lin.ie n)) (hn : n < 2 ^ 53) :
    natAt C (.num (.ref i)) = some n := by
  simp only [natAt, CSrv.val, h, Option.bind_some]
  exact toIndex_ie n hn

/-- An entry of an instantiated table. -/
theorem nth_inst {tab : List SymE} {i : Nat} {e : SymE} (h : nth? tab i = some e) (ρ : Nat → F64) :
    nth? (tab.map (SymE.eval ρ)) i = some (e.eval ρ) := by
  rw [nth?_map, h]; rfl

theorem one_ie : F64.fin false 1 0 = Lin.ie 1 := by decide

theorem ie_cast {a : Int} {n : Nat} (h : a = n) : Lin.ie a = Lin.ie n := by rw [h]

/-! ## The isolated heap frame -/

def setAll {α : Type} (h : PTrie α) : List (Nat × α) → PTrie α
  | [] => h
  | (a, v) :: es => setAll (h.set a v) es

/-- The entries of `h` at `[lo, hi)`. -/
def freshOf {α : Type} (h : PTrie α) (lo hi : Nat) : List (Nat × α) :=
  (List.range' lo (hi - lo)).filterMap fun a => (h.get a).map (a, ·)

theorem setAll_get {α : Type} : ∀ (h : PTrie α) (es : List (Nat × α)) (a : Nat),
    (∀ e ∈ es, e.1 ≠ a ∧ e.1 / 4096 < 4 ^ 31) → (setAll h es).get a = h.get a
  | _, [], _, _ => rfl
  | h, (b, v) :: es, a, hes => by
    simp only [setAll]
    rw [setAll_get (h.set b v) es a (fun e he => hes e (List.mem_cons_of_mem _ he))]
    exact PTrie.get_set_ne h b v (hes (b, v) (List.mem_cons_self ..)).2 a (fun e => (hes (b, v) (List.mem_cons_self ..)).1 e.symm)

theorem mem_freshOf {α : Type} {h : PTrie α} {lo hi : Nat} {e : Nat × α} (he : e ∈ freshOf h lo hi) :
    lo ≤ e.1 ∧ e.1 < hi := by
  simp only [freshOf, List.mem_filterMap, List.mem_range'] at he
  obtain ⟨a, ⟨i, hi', rfl⟩, hx⟩ := he
  simp only [Nat.one_mul] at hx ⊢
  cases hg : h.get (lo + i) with
  | none => rw [hg] at hx; cases hx
  | some v => rw [hg] at hx; cases hx; simp; omega

/-- The frame of a class: the return state is the call state with only fresh entries added and
the same jobs, stores and trace; the native state is the call's. -/
theorem framed_of (F : Ffi) {s1 s3 : St Unit} {m1 m3 : Nat} (x : F.S)
    (hheap : s3.heap = setAll s1.heap (freshOf s3.heap s1.next s3.next)) (hnext : Nat.ble s1.next s3.next = true)
    (hsmall : Nat.blt s3.next 1048576 = true)
    (hj : s3.aux.jobs = s1.aux.jobs) (hs : s3.aux.stores = s1.aux.stores) (ht : s3.aux.trace = s1.aux.trace) :
    Framed (F := F) (fun _ => False) Eq (tpl s1 m1 x []) (tpl s3 m3 x []) where
  next := Nat.le_of_ble_eq_true hnext
  heap a ha _ := by
    simp only [tpl_heap, tpl_next] at ha ⊢
    rw [hheap]
    refine setAll_get _ _ a fun e he => ?_
    have := mem_freshOf he
    have h4 : s3.next < 1048576 := Nat.blt_eq.mp hsmall
    refine ⟨by omega, ?_⟩
    have : e.1 / 4096 < 256 := by omega
    exact Nat.lt_of_lt_of_le this (by decide)
  jobs := hj
  stores := hs
  trace := ⟨[], ht⟩
  ffi := rfl

end Host.Ts.Sim.Stage
