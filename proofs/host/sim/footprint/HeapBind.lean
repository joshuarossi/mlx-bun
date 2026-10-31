import host.sim.footprint.HeapBindBasic

namespace Host.Ts.Sim.HeapFoot
open Host.Ts Host.Ts.Sim Conv StmtSim Disp
open Host.Mlx.Ffi.FullKeep (AllX)

/-- An identifier step may write a lexical cell in `A`, in addition to allocating errors. -/
structure CellEffect {S : Type} (s u : St S) (A : Nat → Prop) : Prop where
  grows : s.next ≤ u.next
  old : ∀ a, Present u a → Present s a ∨ A a ∨ s.next ≤ a
  kept : ∀ a, a < s.next → ¬ A a → u.heap.get a = s.heap.get a

theorem Fresh.cellEffect {S : Type} {s u : St S} (h : Fresh s u) (A : Nat → Prop) :
    CellEffect s u A where
  grows := h.grows
  old a ha := (h.old a ha).imp_right Or.inr
  kept a ha _ := h.kept a ha

theorem cellWrite_effect {S : Type} (s : St S) {A : Nat → Prop} {c : Nat}
    (hc : A c) (v result : Val) : CellEffect s ((s.setCell c v).ret result) A where
  grows := Nat.le_refl _
  old a ha := by
    rcases Host.Mlx.Ffi.FullKeep.isSome_set_inv s.heap c (.cell (some v)) a ha with hp | hp
    · exact .inl hp
    · exact .inr (.inl (hp ▸ hc))
  kept a _ ha := PTrie.get_set_ne' _ _ _ _ (by intro he; exact ha (he ▸ hc))

theorem fresh_cellEffect {F : Ffi} {s : St F.S} {m : Host.Ts.M (St F.S)}
    (h : AllX (Fresh s) m) (A : Nat → Prop) : AllX (fun u => CellEffect s u A) m :=
  ⟨fun S u S' hu => (h.1 S u S' hu).cellEffect A,
   fun C u C' hu => (h.2 C u C' hu).cellEffect A⟩

/-- This follows the actual identifier helper, including unbound, uninitialized and
dangling-cell branches. It does not require the two servers to choose matching branches. -/
theorem bindId_effect (F : Ffi) (s : St F.S) (n : Name) (v : Val) (env : Env)
    (mode : BindMode) (kind : DeclKind) (A : Nat → Prop)
    (he : ∀ c, lookupEnv n env = some c → A c) :
    AllX (fun u => CellEffect s u A) (bindStep F s (.id n) v env mode kind) := by
  cases mode with
  | init =>
    simp only [bindStep]
    cases hl : lookupEnv n env with
    | none => exact allX_fail _ _
    | some c => exact AllX.pure (cellWrite_effect s (he c hl) _ _)
  | assign =>
    change AllX _ (writeVar F s n env v)
    unfold writeVar
    cases hl : lookupEnv n env with
    | none => exact fresh_cellEffect (refErr_fresh _ _) A
    | some c =>
      simp only
      cases hw : s.cell? c with
      | none => exact allX_fail _ _
      | some w =>
        cases w with
        | none => exact fresh_cellEffect (refErr_fresh _ _) A
        | some w => exact AllX.pure (cellWrite_effect s (he c hl) _ _)

/-- Source writes are to present cells; target writes are to images of those same
present source cells. The remaining writes are fresh error allocations. -/
theorem CellEffect.foot {S : Type} {M : Map} {s t u w : St S}
    (hs : CellEffect s u (Present s))
    (ht : CellEffect t w (fun a => ∃ b, Present s b ∧ M.a b = a)) :
    HeapStepFoot M s t u w where
  grows := hs.grows
  old a ha := by
    rcases hs.old a ha with hp | hp | hp
    · exact .inl hp
    · exact .inl hp
    · exact .inr hp
  kept a ha hn := ht.kept a ha (by rintro ⟨b, hb, he⟩; exact hn b hb he)

section
variable {F : Ffi} {FR : Map → Nat → F.S → F.S → Prop} {W : Nat → Option WFrame}
  {stk : List Frame} {M : Map} {ν : Nat → F64} {K : Ctx}
  {s t s1 t1 : St F.S} {S S1 : SSrv} {C C1 : CSrv}
  {p : Pat} {v : Val} {env : Env} {mode : BindMode} {kind : DeclKind}

/-- The operational footprint needs only the binding environment's existing support.
Property reads may use either server, but this step schedules any accessor or iterator call. -/
theorem bindStep_foot (he : Supp.env (Present s) S.tab.length env)
    (hsrun : interpS (bindStep F s p v env mode kind).run S = some (s1, S1))
    (htrun : interpC (bindStep F t p (M.val v) (M.env env) mode kind).run C = some (t1, C1)) :
    HeapStepFoot M s t s1 t1 := by
  by_cases hi : ∃ n, p = .id n
  · obtain ⟨n, rfl⟩ := hi
    have hs : ∀ c, lookupEnv n env = some c → Present s c := fun _ hl => env_lookup_supp he hl
    have ht : ∀ c, lookupEnv n (M.env env) = some c → ∃ b, Present s b ∧ M.a b = c := by
      intro c hc
      cases hl : lookupEnv n env with
      | none => rw [lookupEnv_img_none hl] at hc; cases hc
      | some b =>
        rw [lookupEnv_img_some hl] at hc
        cases hc
        exact ⟨b, hs b hl, rfl⟩
    exact CellEffect.foot
      ((bindId_effect F s n v env mode kind (Present s) hs).1 S s1 S1 hsrun)
      ((bindId_effect F t n (M.val v) (M.env env) mode kind _ ht).2 C t1 C1 htrun)
  · have hp : ∀ n, p ≠ .id n := fun n hn => hi ⟨n, hn⟩
    exact Fresh.foot ((bindStep_nonId_fresh F s p v env mode kind hp).1 S s1 S1 hsrun)
      ((bindStep_nonId_fresh F t p (M.val v) (M.env env) mode kind hp).2 C t1 C1 htrun)

/-- Every binding case accepted by the unchanged `okBind` has the actual heap footprint.
Acceptance is retained at this interface; the operational proof needs no stronger conditions. -/
theorem step_bind_all_foot {P : JSP F}
    (h : RelXB F FR W stk M ν K s S t C) (hc : s.ctl = .bind p v env mode kind)
    (_hok : okBind P s S.tab.length p v env mode = true)
    (hsrun : interpS (step F s).run S = some (s1, S1))
    (htrun : interpC (step F t).run C = some (t1, C1)) : HeapStepFoot M s t s1 t1 := by
  have hr := RelXB.rel h (by intro v hv; rw [hc] at hv; cases hv)
  obtain ⟨es, et, _, he⟩ := bindTop hr hc
  rw [es] at hsrun
  rw [et] at htrun
  exact bindStep_foot he hsrun htrun

end
end Host.Ts.Sim.HeapFoot
