import host.ts.Run
namespace Host.Ts.Sim
open Host.Ts

/-! # Updating one template variable -/

/-- `e` does not mention the template variable `j`. -/
def _root_.Host.Ts.SymE.noVar (j : Nat) : SymE → Bool
  | .lit _ => true
  | .var i => !(Nat.beq i j)
  | .bin _ a b => a.noVar j && b.noVar j
  | .un _ a => a.noVar j

/-- `ν` with variable `j` set to `x`. -/
def upd (ν : Nat → F64) (j : Nat) (x : F64) : Nat → F64 := fun i => bif Nat.beq i j then x else ν i

theorem upd_self (ν : Nat → F64) (j : Nat) (x : F64) : upd ν j x j = x := by simp [upd]

theorem upd_other (ν : Nat → F64) {i j : Nat} (x : F64) (h : i ≠ j) : upd ν j x i = ν i := by
  have : Nat.beq i j = false := by
    cases hb : Nat.beq i j
    · rfl
    · exact absurd (Nat.eq_of_beq_eq_true hb) h
  simp [upd, this]

theorem _root_.Host.Ts.SymE.eval_upd (ν : Nat → F64) (j : Nat) (x : F64) :
    ∀ e : SymE, e.noVar j = true → e.eval (upd ν j x) = e.eval ν
  | .lit _, _ => rfl
  | .var i, h => by
    simp only [SymE.noVar, Bool.not_eq_true'] at h
    have : i ≠ j := fun e => by subst e; simp at h
    simp only [SymE.eval]
    exact upd_other ν x this
  | .bin op a b, h => by
    simp only [SymE.noVar, Bool.and_eq_true] at h
    simp only [SymE.eval, SymE.eval_upd ν j x a h.1, SymE.eval_upd ν j x b h.2]
  | .un op a, h => by
    simp only [SymE.noVar] at h
    simp only [SymE.eval, SymE.eval_upd ν j x a h]

theorem nth?_mem_some {α : Type} : ∀ {xs : List α} {i : Nat} {x : α}, nth? xs i = some x → x ∈ xs
  | [], _, _, h => by cases h
  | y :: ys, 0, x, h => by cases h; exact List.mem_cons_self
  | y :: ys, i + 1, x, h => List.mem_cons_of_mem _ (nth?_mem_some (xs := ys) (i := i) h)

/-- Neither side of any oracle answer mentions `j`. -/
def _root_.Host.Ts.Ans.noVar (j : Nat) (q : Ans) : Bool := q.a.noVar j && q.b.noVar j

theorem good_upd {ν : Nat → F64} {j : Nat} {x : F64} {o : List Ans} (hg : Good ν o)
    (ho : ∀ q ∈ o, q.noVar j = true) : Good (upd ν j x) o := by
  intro q hq
  have h := ho q hq
  simp only [Ans.noVar, Bool.and_eq_true] at h
  rw [SymE.eval_upd ν j x q.a h.1, SymE.eval_upd ν j x q.b h.2]
  exact hg q hq

end Host.Ts.Sim
