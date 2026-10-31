import host.sim.State
import host.sim.Upd
namespace Host.Route
open Host.Ts Host.Ts.Sim

/-! Entry conversions preserve the loaded state. -/

/-- The first prefill quantity is fresh after the nine external-input variables. -/
def rowVal (ν : Nat → F64) (L : Nat) (i : Nat) : F64 :=
  if i = 9 then F64.ofNat L else ν i

theorem rowVal_reserved (ν : Nat → F64) (L i : Nat) (hi : i < 9) : rowVal ν L i = ν i := by
  simp only [rowVal, ite_eq_right (show i ≠ 9 by omega)]

theorem rowVal_at (ν : Nat → F64) (L : Nat) : rowVal ν L 9 = F64.ofNat L := rfl

/-- The new prompt-length quantity stays in the existing natural-value bound. -/
theorem rowVal_bounded (ν : Nat → F64) (L B : Nat)
    (hν : ∀ i, ∃ k ≤ B, ν i = F64.ofNat k) (hL : L ≤ B) :
    ∀ i, ∃ k ≤ B, rowVal ν L i = F64.ofNat k := by
  intro i
  by_cases hi : i = 9
  · subst i
    exact ⟨L, hL, rowVal_at ν L⟩
  · obtain ⟨k, hk, he⟩ := hν i
    exact ⟨k, hk, by simpa only [rowVal, ite_eq_right hi] using he⟩

/-- A table of reserved variables permits a new valuation that agrees on those variables. -/
theorem revaluePrefix {F : Ffi} {FR : Map → Nat → F.S → F.S → Prop}
    {W : Nat → Option WFrame} {stk : List Frame} {M : Map} {ν ν' : Nat → F64} {K : Ctx}
    {s t : St F.S} {C : CSrv} {n : Nat}
    (h : RelB F FR W stk M ν K s ⟨(List.range n).map SymE.var, []⟩ t C)
    (hv : ∀ i, i < n → ν' i = ν i) :
    RelB F FR W stk M ν' K s ⟨(List.range n).map SymE.var, []⟩ t C := by
  refine { h with srv := ⟨?_, ?_⟩ }
  · intro i e he
    have hm : e ∈ (List.range n).map SymE.var := nth?_mem_some he
    obtain ⟨j, hj, rfl⟩ := List.mem_map.mp hm
    change C.val (M.num i) = some (ν' j)
    rw [hv j (List.mem_range.mp hj)]
    exact h.srv.num i (.var j) he
  · intro q hq
    cases hq

/-- Assign the prompt length to fresh variable 9 while keeping every loaded value. -/
theorem revalueRow {F : Ffi} {FR : Map → Nat → F.S → F.S → Prop}
    {W : Nat → Option WFrame} {stk : List Frame} {M : Map} {ν : Nat → F64} {K : Ctx}
    {s t : St F.S} {C : CSrv}
    (h : RelB F FR W stk M ν K s ⟨(List.range 9).map SymE.var, []⟩ t C) (L : Nat) :
    RelB F FR W stk M (rowVal ν L) K s ⟨(List.range 9).map SymE.var, []⟩ t C :=
  revaluePrefix h (fun i hi => rowVal_reserved ν L i hi)

/-- Activate an empty memo's declared wide frame from its exact heap correspondence. -/
theorem frameMemoEmpty {F : Ffi} {FR : Map → Nat → F.S → F.S → Prop}
    {W : Nat → Option WFrame} {stk : List Frame} {M : Map} {ν : Nat → F64} {K : Ctx}
    {s t : St F.S} {S : SSrv} {C : CSrv} {a : Nat} {o : Obj}
    (h : RelB F FR W stk M ν K s S t C) (hfr : K.fr a = none)
    (hW : W a = some (.memo [])) (ho : s.heap.get a = some (.obj o)) (hk : o.kind = .map []) :
    RelB F FR W stk M ν
      { K with fr := fun b => if b = a then some ([], []) else K.fr b } s S t C := by
  refine { h with heap := ?_, framedPresent := ?_ }
  · intro b x hx
    by_cases hb : b = a
    · subst b
      rw [ho] at hx
      cases hx
      have ht := h.get ho hfr
      have hm : (M.obj o).kind = .map [] := by
        change M.kind o.kind = .map []
        rw [hk]
        rfl
      simp only [SlotW, hW]
      rw [ht]
      refine ⟨[], [], hk, ?_, ?_, ?_⟩
      · change M.obj o = { M.obj o with kind := .map [] }
        rw [← hm]
      · intro c v hv
        cases hv
      · intro c hc hn
        rfl
    · simpa only [SlotW, SlotOK, ite_eq_right hb] using h.heap b x hx
  · intro b p hp
    by_cases hb : b = a
    · subst b
      exact Present.of_get ho
    · exact h.framedPresent b p (by simpa only [ite_eq_right hb] using hp)

end Host.Route
