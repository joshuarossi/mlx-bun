import host.sim.Map
namespace Host.Ts.Sim

/-! # Simulation of request trees

The source (template) iteration runs under a symbolic server `S`; the target
iteration under a concrete server `C`. Every source number reference `ref i`
has the image `M.num i`, whose concrete value is the source entry evaluated
at the target iteration's valuation `ν`. A source request may correspond to
a target literal computation: the target computes directly when both of its
operands are literals. The map then grows by the new entry's image (`Ext`).
Oracle answers of the source are correct at `ν` (`Good`), so source tests
and target tests agree. -/

def NumOK (M : Map) (ν : Nat → F64) (S : SSrv) (C : CSrv) : Prop :=
  ∀ i e, nth? S.tab i = some e → C.val (M.num i) = some (e.eval ν)

structure Srv (M : Map) (ν : Nat → F64) (S : SSrv) (C : CSrv) : Prop where
  num : NumOK M ν S C
  good : Good ν S.oracle

/-- `M'` keeps the names of `M` and the images of the first `n` number references. -/
structure Ext (M M' : Map) (n : Nat) : Prop where
  a : M'.a = M.a
  big : M'.big = M.big
  region : M'.region = M.region
  node : M'.node = M.node
  num : ∀ i, i < n → M'.num i = M.num i

theorem Ext.refl (M : Map) (n : Nat) : Ext M M n := ⟨rfl, rfl, rfl, rfl, fun _ _ => rfl⟩

theorem Ext.trans {M M' M'' : Map} {n n' : Nat} (h : Ext M M' n) (h' : Ext M' M'' n') (hn : n ≤ n') :
    Ext M M'' n :=
  ⟨h'.a.trans h.a, h'.big.trans h.big, h'.region.trans h.region, h'.node.trans h.node,
    fun i hi => (h'.num i (Nat.lt_of_lt_of_le hi hn)).trans (h.num i hi)⟩

theorem Ext.mono {M M' : Map} {n n' : Nat} (h : Ext M M' n') (hn : n ≤ n') : Ext M M' n :=
  ⟨h.a, h.big, h.region, h.node, fun i hi => h.num i (Nat.lt_of_lt_of_le hi hn)⟩

/-- The map with the image of reference `n` set to `x`. -/
def Map.setNum (M : Map) (n : Nat) (x : NumV) : Map :=
  { M with num := fun i => bif Nat.beq i n then x else M.num i }

theorem Map.setNum_ext (M : Map) (n : Nat) (x : NumV) : Ext M (M.setNum n x) n :=
  ⟨rfl, rfl, rfl, rfl, fun i hi => by
    show (bif Nat.beq i n then x else M.num i) = M.num i
    cases h : Nat.beq i n
    · rfl
    · exact absurd (Nat.eq_of_beq_eq_true h) (Nat.ne_of_lt hi)⟩

theorem Map.setNum_self (M : Map) (n : Nat) (x : NumV) : (M.setNum n x).num n = x := by
  simp [Map.setNum]

/-! ## Server facts -/

theorem nth?_append_lt {α : Type} : ∀ (xs ys : List α) (i : Nat), i < xs.length → nth? (xs ++ ys) i = nth? xs i
  | [], _, _, h => absurd h (Nat.not_lt_zero _)
  | _ :: _, _, 0, _ => rfl
  | _ :: xs, ys, i + 1, h => nth?_append_lt xs ys i (Nat.lt_of_succ_lt_succ h)

theorem nth?_lt {α : Type} : ∀ (xs : List α) (i : Nat) (a : α), nth? xs i = some a → i < xs.length
  | [], _, _, h => by cases h
  | _ :: _, 0, _, _ => Nat.zero_lt_succ _
  | _ :: xs, i + 1, a, h => Nat.succ_lt_succ (nth?_lt xs i a h)

theorem nth?_length_append {α : Type} : ∀ (xs : List α) (a : α), nth? (xs ++ [a]) xs.length = some a
  | [], _ => rfl
  | _ :: xs, a => nth?_length_append xs a

theorem nth?_append_eq {α : Type} (xs : List α) (a : α) (i : Nat) (e : α) (h : nth? (xs ++ [a]) i = some e) :
    (i < xs.length ∧ nth? xs i = some e) ∨ (i = xs.length ∧ e = a) := by
  rcases Nat.lt_or_ge i xs.length with hi | hi
  · exact .inl ⟨hi, (nth?_append_lt xs [a] i hi).symm.trans h⟩
  · have hl := nth?_lt _ _ _ h
    simp only [List.length_append, List.length_cons, List.length_nil] at hl
    have hi' : i = xs.length := by omega
    subst hi'
    rw [nth?_length_append] at h
    exact .inr ⟨rfl, (Option.some.inj h).symm⟩

/-- A concrete table only grows. -/
def CSrv.Le (C C' : CSrv) : Prop := ∃ ys, C'.tab = C.tab ++ ys

theorem CSrv.Le.refl (C : CSrv) : CSrv.Le C C := ⟨[], (List.append_nil _).symm⟩

theorem CSrv.Le.trans {C C' C'' : CSrv} (h : CSrv.Le C C') (h' : CSrv.Le C' C'') : CSrv.Le C C'' := by
  obtain ⟨ys, hy⟩ := h
  obtain ⟨zs, hz⟩ := h'
  exact ⟨ys ++ zs, by rw [hz, hy, List.append_assoc]⟩

theorem CSrv.Le.val {C C' : CSrv} (h : CSrv.Le C C') {x : NumV} {v : F64} (hv : C.val x = some v) :
    C'.val x = some v := by
  obtain ⟨ys, hy⟩ := h
  cases x with
  | lit _ => exact hv
  | ref i =>
    change nth? C'.tab i = some v
    change nth? C.tab i = some v at hv
    rw [hy, nth?_append_lt _ _ _ (nth?_lt _ _ _ hv)]
    exact hv

theorem interpC_le {α : Type} : ∀ (v : Free α) (C : CSrv) (b : α) (C' : CSrv),
    interpC v C = some (b, C') → CSrv.Le C C' := by
  intro v
  induction v with
  | pure a =>
    intro C b C' h
    simp only [interpC_pure, Option.some.injEq, Prod.mk.injEq] at h
    obtain ⟨_, rfl⟩ := h
    exact CSrv.Le.refl _
  | fail m => intro C b C' h; simp [interpC_fail] at h
  | bin op x y k ih =>
    intro C b C' h
    rw [interpC_bin] at h
    split at h
    · exact CSrv.Le.trans ⟨_, rfl⟩ (ih _ _ _ _ h)
    · cases h
  | un op x k ih =>
    intro C b C' h
    rw [interpC_un] at h
    split at h
    · exact CSrv.Le.trans ⟨_, rfl⟩ (ih _ _ _ _ h)
    · cases h
  | test op x y k ih =>
    intro C b C' h
    rw [interpC_test] at h
    split at h
    · exact ih _ _ _ _ h
    · cases h
  | conc x k ih =>
    intro C b C' h
    rw [interpC_conc] at h
    split at h
    · exact ih _ _ _ _ h
    · cases h

theorem SSrv.answer_tab {S S1 : SSrv} {op : NTest} {x y : SymE} {r : Bool}
    (h : S.answer op x y = some (r, S1)) : S1.tab = S.tab := by
  unfold SSrv.answer at h
  cases ho : S.oracle with
  | nil => simp [ho] at h
  | cons q o =>
    simp only [ho] at h
    cases hd : decide (q.op = op ∧ q.a = x ∧ q.b = y) <;>
      simp only [hd, cond_true, cond_false, Option.some.injEq, Prod.mk.injEq, reduceCtorEq] at h
    obtain ⟨_, rfl⟩ := h
    rfl

/-- A symbolic table only grows. -/
theorem interpS_len {α : Type} : ∀ (u : Free α) (S : SSrv) (a : α) (S' : SSrv),
    interpS u S = some (a, S') → S.tab.length ≤ S'.tab.length := by
  intro u
  induction u with
  | pure a =>
    intro S b S' h
    simp only [interpS_pure, Option.some.injEq, Prod.mk.injEq] at h
    obtain ⟨_, rfl⟩ := h
    exact Nat.le_refl _
  | fail m => intro S b S' h; simp [interpS_fail] at h
  | bin op x y k ih =>
    intro S b S' h
    rw [interpS_bin] at h
    split at h
    · have := ih _ _ _ _ h
      simp only [List.length_append, List.length_cons, List.length_nil] at this
      omega
    · cases h
  | un op x k ih =>
    intro S b S' h
    rw [interpS_un] at h
    split at h
    · have := ih _ _ _ _ h
      simp only [List.length_append, List.length_cons, List.length_nil] at this
      omega
    · cases h
  | test op x y k ih =>
    intro S b S' h
    rw [interpS_test] at h
    split at h
    · split at h
      · rename_i r S1 hans
        rw [← SSrv.answer_tab hans]
        exact ih _ _ _ _ h
      · cases h
    · cases h
  | conc x k ih =>
    intro S b S' h
    rw [interpS_conc] at h
    split at h
    · exact ih _ _ _ _ h
    · cases h

/-- Source values of numbers have target images of the same concrete value. -/
theorem NumOK.val {M : Map} {ν : Nat → F64} {S : SSrv} {C : CSrv} (h : NumOK M ν S C)
    {x : NumV} {e : SymE} (hx : S.val x = some e) : C.val (M.nv x) = some (e.eval ν) := by
  cases x with
  | lit v =>
    simp only [SSrv.val, Option.some.injEq] at hx
    subst hx
    rfl
  | ref i => exact h i e hx

theorem NumOK.mono {M M' : Map} {ν : Nat → F64} {S : SSrv} {C C' : CSrv} (h : NumOK M ν S C)
    (hm : Ext M M' S.tab.length) (hc : CSrv.Le C C') : NumOK M' ν S C' := by
  intro i e he
  rw [hm.num i (nth?_lt _ _ _ he)]
  exact hc.val (h i e he)

/-! ## Simulation of trees and of machine computations -/

/-- At given servers: whenever the source tree runs, the target tree runs to a
result related to it. The relation sees the final servers and chooses the map. -/
def FSim {α β : Type} (P : Map → SSrv → CSrv → α → β → Prop) (S : SSrv) (C : CSrv) (u : Free α) (v : Free β) : Prop :=
  ∀ a S', interpS u S = some (a, S') → ∃ M' b C', interpC v C = some (b, C') ∧ P M' S' C' a b

/-- Machine computations in continuation-passing form: related continuations
give related trees. -/
def MSim {α β : Type} (P : Map → SSrv → CSrv → α → β → Prop) (S : SSrv) (C : CSrv)
    (m : Host.Ts.M α) (m' : Host.Ts.M β) : Prop :=
  ∀ (γ δ : Type) (Q : Map → SSrv → CSrv → γ → δ → Prop) (k : α → Free γ) (k' : β → Free δ),
    (∀ M' S' C' a b, P M' S' C' a b → FSim Q S' C' (k a) (k' b)) → FSim Q S C (m γ k) (m' δ k')

section
variable {α β : Type} {P : Map → SSrv → CSrv → α → β → Prop} {S : SSrv} {C : CSrv}

theorem FSim.pure {M : Map} {a : α} {b : β} (h : P M S C a b) : FSim P S C (.pure a) (.pure b) := by
  intro a' S' hu
  simp only [interpS_pure, Option.some.injEq, Prod.mk.injEq] at hu
  obtain ⟨rfl, rfl⟩ := hu
  exact ⟨M, b, C, rfl, h⟩

theorem FSim.fail (m : String) (v : Free β) : FSim P S C (Free.fail (α := α) m) v := by
  intro a S' hu
  simp [interpS_fail] at hu

theorem FSim.mono {P' : Map → SSrv → CSrv → α → β → Prop} {u : Free α} {v : Free β}
    (h : FSim P S C u v) (hp : ∀ M' S' C' a b, P M' S' C' a b → P' M' S' C' a b) : FSim P' S C u v := by
  intro a S' hu
  obtain ⟨M', b, C', hv, hab⟩ := h a S' hu
  exact ⟨M', b, C', hv, hp _ _ _ _ _ hab⟩

theorem MSim.pure {M : Map} {a : α} {b : β} (h : P M S C a b) : MSim P S C (Host.Ts.M.pure a) (Host.Ts.M.pure b) :=
  fun _ _ _ _ _ hk => hk M S C a b h

theorem MSim.fail (msg : String) (m' : Host.Ts.M β) : MSim P S C (Host.Ts.M.fail (α := α) msg) m' :=
  fun _ _ _ _ _ _ => FSim.fail msg _

theorem MSim.mono {P' : Map → SSrv → CSrv → α → β → Prop} {m : Host.Ts.M α} {m' : Host.Ts.M β}
    (h : MSim P S C m m') (hp : ∀ M' S' C' a b, P M' S' C' a b → P' M' S' C' a b) : MSim P' S C m m' :=
  fun γ δ Q k k' hk => h γ δ Q k k' (fun M' S' C' a b hab => hk M' S' C' a b (hp _ _ _ _ _ hab))

/-- A simulation of a machine computation yields a simulation of its run. -/
theorem MSim.run {m : Host.Ts.M α} {m' : Host.Ts.M β} (h : MSim P S C m m') : FSim P S C m.run m'.run :=
  h α β P .pure .pure (fun _ _ _ _ _ hp => FSim.pure hp)
end

theorem MSim.bind {α β α' β' : Type} {P : Map → SSrv → CSrv → α → β → Prop} {Q : Map → SSrv → CSrv → α' → β' → Prop}
    {S : SSrv} {C : CSrv} {m : Host.Ts.M α} {m' : Host.Ts.M β} {f : α → Host.Ts.M α'} {f' : β → Host.Ts.M β'}
    (hm : MSim P S C m m') (hf : ∀ M' S' C' a b, P M' S' C' a b → MSim Q S' C' (f a) (f' b)) :
    MSim Q S C (Host.Ts.M.bind m f) (Host.Ts.M.bind m' f') :=
  fun γ δ R k k' hk => hm γ δ R (fun a => f a γ k) (fun b => f' b δ k')
    (fun M' S' C' a b hp => hf M' S' C' a b hp γ δ R k k' hk)

/-- The servers grow from `(S, C)` to `(S', C')` and the map extends, keeping the
number correspondence. -/
structure Grow (M : Map) (ν : Nat → F64) (S : SSrv) (C : CSrv) (M' : Map) (S' : SSrv) (C' : CSrv) : Prop where
  ext : Ext M M' S.tab.length
  srv : Srv M' ν S' C'
  len : S.tab.length ≤ S'.tab.length

theorem Grow.refl {M : Map} {ν : Nat → F64} {S : SSrv} {C : CSrv} (h : Srv M ν S C) : Grow M ν S C M S C :=
  ⟨Ext.refl _ _, h, Nat.le_refl _⟩

theorem Grow.trans {M M' M'' : Map} {ν : Nat → F64} {S S' S'' : SSrv} {C C' C'' : CSrv}
    (h : Grow M ν S C M' S' C') (h' : Grow M' ν S' C' M'' S'' C'') : Grow M ν S C M'' S'' C'' :=
  ⟨h.ext.trans h'.ext h.len, h'.srv, Nat.le_trans h.len h'.len⟩

end Host.Ts.Sim
