import host.ts.Heap
import Lean.Elab.Tactic.Omega

namespace Host.Ts.Trie
variable {α : Type}

@[simp] theorem get_nil (n : Nat) : (nil : Trie α).get n = none := rfl

theorem pick_apply {β γ : Type} (d : Nat) (a b c e : β → γ) (x : β) :
    pick d a b c e x = pick d (a x) (b x) (c x) (e x) := by
  unfold pick brec
  cases Nat.blt d 2 <;> cases Nat.beq d 0 <;> cases Nat.beq d 2 <;> rfl

@[simp] theorem pick_self {β : Type} (d : Nat) (a : β) : pick d a a a a = a := by
  unfold pick brec
  cases Nat.blt d 2 <;> cases Nat.beq d 0 <;> cases Nat.beq d 2 <;> rfl

theorem get_node (v : Option α) (a b c e : Trie α) (n : Nat) :
    (node v a b c e).get n =
      if n = 0 then v else (pick (n % 4) a b c e).get (n / 4) := by
  by_cases hn : n = 0
  · subst n; rfl
  · have hb : Nat.beq n 0 = false := by
      cases h : Nat.beq n 0
      · rfl
      · exact False.elim (hn (Nat.eq_of_beq_eq_true h))
    simp only [get, hb, brec, ite_eq_right hn]
    unfold pick brec
    cases Nat.blt (n % 4) 2 <;> cases Nat.beq (n % 4) 0 <;> cases Nat.beq (n % 4) 2 <;> rfl

theorem setF_nil (f n : Nat) (x : α) :
    setF (f + 1) nil n x =
      if n = 0 then node (some x) nil nil nil nil
      else put (n % 4) none nil nil nil nil (setF f nil (n / 4) x) := by
  by_cases hn : n = 0
  · subst n; rfl
  · have hb : Nat.beq n 0 = false := by
      cases h : Nat.beq n 0
      · rfl
      · exact False.elim (hn (Nat.eq_of_beq_eq_true h))
    simp only [setF, hb, brec, ite_eq_right hn]
    rfl

theorem setF_node (f n : Nat) (v : Option α) (a b c e : Trie α) (x : α) :
    setF (f + 1) (node v a b c e) n x =
      if n = 0 then node (some x) a b c e
      else put (n % 4) v a b c e (setF f (pick (n % 4) a b c e) (n / 4) x) := by
  by_cases hn : n = 0
  · subst n; rfl
  · have hb : Nat.beq n 0 = false := by
      cases h : Nat.beq n 0
      · rfl
      · exact False.elim (hn (Nat.eq_of_beq_eq_true h))
    simp only [setF, hb, brec, ite_eq_right hn]
    rfl

theorem get_put (d : Nat) (hd : d < 4) (v : Option α) (a b c e x : Trie α) (m : Nat) :
    (put d v a b c e x).get m =
      if m = 0 then v else
      if m % 4 = d then x.get (m / 4) else (pick (m % 4) a b c e).get (m / 4) := by
  have hm : m % 4 < 4 := Nat.mod_lt _ (by decide)
  have hd' : d = 0 ∨ d = 1 ∨ d = 2 ∨ d = 3 := by omega
  have hm' : m % 4 = 0 ∨ m % 4 = 1 ∨ m % 4 = 2 ∨ m % 4 = 3 := by omega
  rcases hd' with rfl | rfl | rfl | rfl <;>
    rcases hm' with hm' | hm' | hm' | hm' <;>
    simp [put, pick, brec, get_node, hm', Nat.blt, Nat.beq, Nat.ble]

/-- The recursive writer must have fuel left when it reaches address zero. -/
def Fits : Nat → Nat → Prop
  | 0, _ => False
  | f + 1, n => n = 0 ∨ Fits f (n / 4)

theorem get_setF (f : Nat) (t : Trie α) (n : Nat) (x : α) (hf : Fits f n) (m : Nat) :
    (setF f t n x).get m = if m = n then some x else t.get m := by
  induction f generalizing t n m with
  | zero => exact False.elim hf
  | succ f ih =>
    by_cases hn : n = 0
    · subst n
      by_cases hm : m = 0 <;> cases t <;> simp [setF_nil, setF_node, get_node, get_nil, hm]
    · have hdiv : Fits f (n / 4) := hf.resolve_left hn
      have hn' : 0 ≠ n := by omega
      cases t with
      | nil =>
        rw [setF_nil, ite_eq_right hn, get_put _ (Nat.mod_lt _ (by decide))]
        rw [ih _ _ hdiv]
        by_cases hm : m = 0
        · subst m; simp [hn']
        · by_cases hd : m % 4 = n % 4
          · by_cases hq : m / 4 = n / 4
            · have hmn : m = n := by omega
              simp [hmn, hn]
            · have hmn : m ≠ n := by omega
              simp [hm, hd, hq, hmn]
          · have hmn : m ≠ n := by omega
            simp [hm, hd, hmn]
      | node v a b c e =>
        rw [setF_node, ite_eq_right hn, get_put _ (Nat.mod_lt _ (by decide))]
        rw [ih _ _ hdiv]
        by_cases hm : m = 0
        · subst m; simp [hn', get_node]
        · by_cases hd : m % 4 = n % 4
          · by_cases hq : m / 4 = n / 4
            · have hmn : m = n := by omega
              simp [hmn, hn]
            · have hmn : m ≠ n := by omega
              simp [hm, hd, hq, hmn, get_node]
          · have hmn : m ≠ n := by omega
            simp [hm, hd, hmn, get_node]

theorem fits_of_lt (f n : Nat) (h : n < 4 ^ f) : Fits (f + 1) n := by
  induction f generalizing n with
  | zero => left; simpa using h
  | succ f ih =>
    right
    apply ih
    have h' : n < 4 ^ f * 4 := by simpa [Nat.pow_succ] using h
    omega

/-- Fuel 32 covers addresses below 4^31; one step writes the terminal zero. -/
theorem get_set (t : Trie α) (n : Nat) (x : α) (hn : n < 4 ^ 31) (m : Nat) :
    (t.set n x).get m = if m = n then some x else t.get m :=
  get_setF 32 t n x (fits_of_lt 31 n hn) m

theorem get_set_self (t : Trie α) (n : Nat) (x : α) (hn : n < 4 ^ 31) :
    (t.set n x).get n = some x := by simp [get_set t n x hn]

theorem get_set_ne (t : Trie α) (n : Nat) (x : α) (hn : n < 4 ^ 31) (m : Nat) (hm : m ≠ n) :
    (t.set n x).get m = t.get m := by simp [get_set t n x hn, hm]

end Host.Ts.Trie

namespace Host.Ts.PTrie
variable {α : Type}

@[simp] theorem orNil_some {β : Type} (t : Trie β) : orNil (some t) = t := rfl
@[simp] theorem orNil_none {β : Type} : orNil (none : Option (Trie β)) = .nil := rfl

theorem get_eq (t : PTrie α) (n : Nat) :
    t.get n = (orNil ((orNil (t.root.get (n / 4096))).get ((n / 64) % 64))).get (n % 64) := by
  unfold get
  cases hg : t.root.get (n / 4096) with
  | none => rfl
  | some g =>
    dsimp only [orNil]
    cases hp : g.get ((n / 64) % 64) <;> rfl

/-- Paged writes preserve every other lookup. The bound applies only to the
group index; both inner indices are below 64. In particular it covers all
64-bit addresses. -/
theorem get_set (t : PTrie α) (n : Nat) (x : α) (hn : n / 4096 < 4 ^ 31) (m : Nat) :
    (t.set n x).get m = if m = n then some x else t.get m := by
  have hp : (n / 64) % 64 < 4 ^ 31 := by have := Nat.mod_lt (n / 64) (by decide : 0 < 64); omega
  have he : n % 64 < 4 ^ 31 := by have := Nat.mod_lt n (by decide : 0 < 64); omega
  rw [get_eq]
  dsimp only [set]
  change (orNil ((orNil ((t.root.set (n / 4096)
    ((orNil (t.root.get (n / 4096))).set ((n / 64) % 64)
      ((orNil ((orNil (t.root.get (n / 4096))).get ((n / 64) % 64))).set (n % 64) x))).get
    (m / 4096))).get ((m / 64) % 64))).get (m % 64) = _
  rw [Trie.get_set _ _ _ hn]
  by_cases hg : m / 4096 = n / 4096
  · simp only [ite_eq_left hg, orNil_some]
    rw [Trie.get_set _ _ _ hp]
    by_cases hpage : (m / 64) % 64 = (n / 64) % 64
    · simp only [ite_eq_left hpage, orNil_some]
      rw [Trie.get_set _ _ _ he]
      by_cases heq : m % 64 = n % 64
      · have hmn : m = n := by omega
        simp [heq, hmn]
      · have hmn : m ≠ n := by omega
        simp only [ite_eq_right heq, ite_eq_right hmn]
        rw [get_eq, hg, hpage]
    · have hmn : m ≠ n := by omega
      simp only [ite_eq_right hpage, ite_eq_right hmn]
      rw [get_eq, hg]
  · have hmn : m ≠ n := by omega
    simp only [ite_eq_right hg, ite_eq_right hmn]
    exact (get_eq t m).symm

/-- The paged representation covers the complete unsigned 64-bit address range. -/
theorem get_set_u64 (t : PTrie α) (n : Nat) (x : α) (hn : n < 2 ^ 64) (m : Nat) :
    (t.set n x).get m = if m = n then some x else t.get m :=
  get_set t n x (by omega) m

theorem get_set_self (t : PTrie α) (n : Nat) (x : α) (hn : n / 4096 < 4 ^ 31) :
    (t.set n x).get n = some x := by simp [get_set t n x hn]

theorem get_set_ne (t : PTrie α) (n : Nat) (x : α) (hn : n / 4096 < 4 ^ 31) (m : Nat) (hm : m ≠ n) :
    (t.set n x).get m = t.get m := by simp [get_set t n x hn, hm]

end Host.Ts.PTrie
