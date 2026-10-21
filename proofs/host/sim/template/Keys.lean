import host.ts.StoreLaws
import Lean.Elab.Tactic.Omega

/-! # Enumerating a paged store

`PTrie.keys t` lists the addresses `t` holds (each once, in trie order). Every
present address is listed (`PTrie.mem_keys`), so a property of all entries
follows from a check over the explicit list the kernel computes. -/

namespace Host.Ts.Sim.Template
open Host.Ts

/-- Entries of a trie whose root has key `base`; a child digit `d` adds `mul * d`. -/
def entriesK {α : Type} : Trie α → Nat → Nat → List (Nat × α)
  | .nil, _, _ => []
  | .node v a b c e, base, mul =>
    (match v with | some x => [(base, x)] | none => []) ++ entriesK a base (mul * 4) ++
      entriesK b (base + mul) (mul * 4) ++ entriesK c (base + mul * 2) (mul * 4) ++ entriesK e (base + mul * 3) (mul * 4)

private theorem pick_cases {β : Type} (n : Nat) (a b c e : β) :
    (n % 4 = 0 ∧ Trie.pick (n % 4) a b c e = a) ∨ (n % 4 = 1 ∧ Trie.pick (n % 4) a b c e = b) ∨
      (n % 4 = 2 ∧ Trie.pick (n % 4) a b c e = c) ∨ (n % 4 = 3 ∧ Trie.pick (n % 4) a b c e = e) := by
  have h : n % 4 = 0 ∨ n % 4 = 1 ∨ n % 4 = 2 ∨ n % 4 = 3 := by omega
  rcases h with h | h | h | h <;> rw [h]
  · exact Or.inl ⟨rfl, rfl⟩
  · exact Or.inr (Or.inl ⟨rfl, rfl⟩)
  · exact Or.inr (Or.inr (Or.inl ⟨rfl, rfl⟩))
  · exact Or.inr (Or.inr (Or.inr ⟨rfl, rfl⟩))

private theorem key_split (base mul n d : Nat) (hd : n % 4 = d) :
    base + mul * d + mul * 4 * (n / 4) = base + mul * n := by
  have h := Nat.mod_add_div n 4
  rw [hd] at h
  conv => rhs; rw [← h]
  rw [Nat.mul_add, Nat.mul_assoc, Nat.add_assoc]

theorem mem_entriesK {α : Type} : ∀ (t : Trie α) (n base mul : Nat) (x : α),
    t.get n = some x → (base + mul * n, x) ∈ entriesK t base mul
  | .nil, n, _, _, x, h => by simp at h
  | .node v a b c e, n, base, mul, x, h => by
    rw [Trie.get_node] at h
    by_cases hn : n = 0
    · subst hn
      simp only [ite_true] at h
      subst h
      simp [entriesK]
    · simp only [hn, ite_false] at h
      simp only [entriesK, List.mem_append]
      rcases pick_cases n a b c e with ⟨hd, hp⟩ | ⟨hd, hp⟩ | ⟨hd, hp⟩ | ⟨hd, hp⟩ <;> rw [hp] at h
      · have := mem_entriesK a (n / 4) base (mul * 4) x h
        rw [show base + mul * 4 * (n / 4) = base + mul * n by
          have := key_split base mul n 0 hd; simpa using this] at this
        exact Or.inl (Or.inl (Or.inl (Or.inr this)))
      · have := mem_entriesK b (n / 4) (base + mul) (mul * 4) x h
        rw [show base + mul + mul * 4 * (n / 4) = base + mul * n by
          have := key_split base mul n 1 hd; simpa using this] at this
        exact Or.inl (Or.inl (Or.inr this))
      · have := mem_entriesK c (n / 4) (base + mul * 2) (mul * 4) x h
        rw [key_split base mul n 2 hd] at this
        exact Or.inl (Or.inr this)
      · have := mem_entriesK e (n / 4) (base + mul * 3) (mul * 4) x h
        rw [key_split base mul n 3 hd] at this
        exact Or.inr this

/-- The addresses a paged store holds. -/
def PTrie.keys {α : Type} (t : PTrie α) : List Nat :=
  (entriesK t.root 0 1).flatMap fun (gi, g) =>
    (entriesK g 0 1).flatMap fun (pi, p) => (entriesK p 0 1).map fun (ei, _) => gi * 4096 + pi * 64 + ei

theorem PTrie.mem_keys {α : Type} (t : PTrie α) (n : Nat) (x : α) (h : t.get n = some x) : n ∈ PTrie.keys t := by
  rw [Host.Ts.PTrie.get_eq] at h
  cases hg : t.root.get (n / 4096) with
  | none => simp [hg, Host.Ts.PTrie.orNil_none] at h
  | some g =>
    simp only [hg, Host.Ts.PTrie.orNil_some] at h
    cases hp : g.get ((n / 64) % 64) with
    | none => simp [hp, Host.Ts.PTrie.orNil_none] at h
    | some p =>
      simp only [hp, Host.Ts.PTrie.orNil_some] at h
      have hg' := mem_entriesK t.root (n / 4096) 0 1 g hg
      have hp' := mem_entriesK g ((n / 64) % 64) 0 1 p hp
      have he' := mem_entriesK p (n % 64) 0 1 x h
      simp only [Nat.zero_add, Nat.one_mul] at hg' hp' he'
      simp only [PTrie.keys, List.mem_flatMap, List.mem_map]
      refine ⟨(n / 4096, g), hg', (n / 64 % 64, p), hp', (n % 64, x), he', ?_⟩
      omega

end Host.Ts.Sim.Template

namespace Host.Ts.Sim.Template
open Host.Ts

/-! ## Groups: the keys of one 4096-address group, and the occupied groups -/

def PTrie.groups {α : Type} (t : PTrie α) : List Nat := (entriesK t.root 0 1).map Prod.fst

def PTrie.groupKeys {α : Type} (t : PTrie α) (gi : Nat) : List Nat :=
  match t.root.get gi with
  | some g => (entriesK g 0 1).flatMap fun (pi, p) => (entriesK p 0 1).map fun (ei, _) => gi * 4096 + pi * 64 + ei
  | none => []

theorem PTrie.mem_groups {α : Type} (t : PTrie α) (n : Nat) (x : α) (h : t.get n = some x) :
    n / 4096 ∈ PTrie.groups t := by
  rw [Host.Ts.PTrie.get_eq] at h
  cases hg : t.root.get (n / 4096) with
  | none => simp [hg, Host.Ts.PTrie.orNil_none] at h
  | some g =>
    have hg' := mem_entriesK t.root (n / 4096) 0 1 g hg
    simp only [Nat.zero_add, Nat.one_mul] at hg'
    simp only [PTrie.groups, List.mem_map]
    exact ⟨_, hg', rfl⟩

theorem PTrie.mem_groupKeys {α : Type} (t : PTrie α) (n : Nat) (x : α) (h : t.get n = some x) :
    n ∈ PTrie.groupKeys t (n / 4096) := by
  rw [Host.Ts.PTrie.get_eq] at h
  cases hg : t.root.get (n / 4096) with
  | none => simp [hg, Host.Ts.PTrie.orNil_none] at h
  | some g =>
    simp only [hg, Host.Ts.PTrie.orNil_some] at h
    cases hp : g.get ((n / 64) % 64) with
    | none => simp [hp, Host.Ts.PTrie.orNil_none] at h
    | some p =>
      simp only [hp, Host.Ts.PTrie.orNil_some] at h
      have hp' := mem_entriesK g ((n / 64) % 64) 0 1 p hp
      have he' := mem_entriesK p (n % 64) 0 1 x h
      simp only [Nat.zero_add, Nat.one_mul] at hp' he'
      simp only [PTrie.groupKeys, hg, List.mem_flatMap, List.mem_map]
      refine ⟨(n / 64 % 64, p), hp', (n % 64, x), he', ?_⟩
      omega

/-- Explicit group blocks `gks` cover the unframed present addresses of `t`. -/
theorem PTrie.cover {α : Type} {t : PTrie α} {fr : List Nat} {gks : List (Nat × List Nat)}
    (hg : (PTrie.groups t == gks.map Prod.fst) = true)
    (hc : ∀ q ∈ gks, ((PTrie.groupKeys t q.1).filter (fun a => !fr.contains a) == q.2) = true) :
    ∀ a x, t.get a = some x → a ∉ fr → ∃ q ∈ gks, a ∈ q.2 := by
  intro a x ha hf
  have h1 := PTrie.mem_groups t a x ha
  rw [beq_iff_eq.mp hg, List.mem_map] at h1
  obtain ⟨q, hq, hq1⟩ := h1
  refine ⟨q, hq, ?_⟩
  have h2 := beq_iff_eq.mp (hc q hq)
  rw [← h2, List.mem_filter, hq1]
  exact ⟨PTrie.mem_groupKeys t a x ha, by simp [hf]⟩

theorem forall_mem_append' {α : Type} {R : α → Prop} {l1 l2 : List α} (h1 : ∀ x ∈ l1, R x)
    (h2 : ∀ x ∈ l2, R x) : ∀ x ∈ l1 ++ l2, R x := by
  intro x hx
  rcases List.mem_append.mp hx with h | h
  · exact h1 x h
  · exact h2 x h

theorem forall_mem_nil' {α : Type} (R : α → Prop) : ∀ x ∈ ([] : List α), R x := fun _ h => by cases h

end Host.Ts.Sim.Template
