import host.sim.conv.Merge
namespace Host.Ts.Sim.Conv
open Host.Ts Host.Ts.Sim

/-! # Fresh table variables for a stage's results

At a merge the stage's numbers past the call's table become new caller entries `es` (`merge`,
`cut_merge`): fresh template variables `ws` (`resTab ws`), bound by `resVal ν ws f` to the values
`f j` of the stage's entries (`resF`: the `j`-th entry past the template's start table, at the
call's isolated valuation). The valuation binds only `ws`:

* `resVal_off`, `eval_resVal`, `good_resVal`: off `ws` it is the caller's, so every expression
  and oracle answer avoiding `ws` keeps its value (`hνS` of `merge` for the caller's table);
* `res_hes`: the new entries evaluate to the stage's (`hes` of `merge`);
* `valuation_resVal`: a substitution `θ` none of whose images reads `ws` (except at `a`, set by
  `upd`) gives the same next-iteration valuation (the restart's `Shift.valuation θ`; the explicit
  substitutions `thetaOf l` map unlisted variables to themselves, so `l` must list the fresh
  variables with images avoiding them, or the caller must not restart through them). -/

/-- Valuations agreeing off `V` give the same value to an expression mentioning no variable of `V`. -/
theorem SymE.eval_congr {ν ν' : Nat → F64} {V : Nat → Prop} (hν : ∀ v, ¬ V v → ν' v = ν v) :
    ∀ e : SymE, (∀ w, V w → e.noVar w = true) → e.eval ν' = e.eval ν
  | .lit _, _ => rfl
  | .var i, h => by
    show ν' i = ν i
    refine hν i fun hv => ?_
    have := h i hv
    simp [SymE.noVar] at this
  | .bin op a b, h => by
    show F64.bin op (a.eval ν') (b.eval ν') = F64.bin op (a.eval ν) (b.eval ν)
    rw [SymE.eval_congr hν a fun w hw => by have := h w hw; simp only [SymE.noVar, Bool.and_eq_true] at this; exact this.1,
      SymE.eval_congr hν b fun w hw => by have := h w hw; simp only [SymE.noVar, Bool.and_eq_true] at this; exact this.2]
  | .un op a, h => by
    show F64.un op (a.eval ν') = F64.un op (a.eval ν)
    rw [SymE.eval_congr hν a fun w hw => by have := h w hw; simpa [SymE.noVar] using this]

/-- The first position of `v` in `ws`. -/
def idx? (v : Nat) : List Nat → Option Nat
  | [] => none
  | w :: ws => bif Nat.beq w v then some 0 else (idx? v ws).map (· + 1)

theorem idx?_none {v : Nat} : ∀ {ws : List Nat}, v ∉ ws → idx? v ws = none
  | [], _ => rfl
  | w :: ws, h => by
    have hw : Nat.beq w v = false := by
      cases hb : Nat.beq w v
      · rfl
      · exact absurd (by rw [Nat.eq_of_beq_eq_true hb]; exact List.mem_cons_self) h
    simp only [idx?, hw, Bool.cond_false, idx?_none (fun hm => h (List.mem_cons_of_mem _ hm)), Option.map_none]

theorem idx?_nth : ∀ {ws : List Nat} {j w : Nat}, ws.Nodup → nth? ws j = some w → idx? w ws = some j
  | [], _, _, _, h => by cases h
  | w' :: ws, 0, w, _, h => by
    cases h
    simp [idx?]
  | w' :: ws, j + 1, w, hnd, h => by
    have hm : w ∈ ws := nth?_mem_some (xs := ws) h
    have hne : Nat.beq w' w = false := by
      cases hb : Nat.beq w' w
      · rfl
      · rw [Nat.eq_of_beq_eq_true hb] at hnd
        exact absurd hm (List.nodup_cons.1 hnd).1
    simp only [idx?, hne, Bool.cond_false, idx?_nth (List.nodup_cons.1 hnd).2 h, Option.map_some]

/-- The valuation binding the fresh variables `ws` to `f 0, f 1, …`. -/
def resVal (ν : Nat → F64) (ws : List Nat) (f : Nat → F64) : Nat → F64 :=
  fun v => match idx? v ws with
    | some j => f j
    | none => ν v

/-- The fresh variables as table entries. -/
def resTab (ws : List Nat) : List SymE := ws.map SymE.var

/-- The values of the stage's entries past its start table `n0`, at the isolated valuation. -/
def resF (θ : Nat → SymE) (S2 : List SymE) (n0 : Nat) (ν : Nat → F64) (j : Nat) : F64 :=
  ((nth? S2 (n0 + j)).getD (.lit (F64.zero false))).eval (Shift.valuation θ ν)

section
variable {ν : Nat → F64} {ws : List Nat} {f : Nat → F64}

theorem resVal_off {v : Nat} (hv : v ∉ ws) : resVal ν ws f v = ν v := by
  simp only [resVal, idx?_none hv]

theorem resVal_at (hnd : ws.Nodup) {j w : Nat} (hj : nth? ws j = some w) : resVal ν ws f w = f j := by
  simp only [resVal, idx?_nth hnd hj]

/-- Expressions avoiding the fresh variables keep their values. -/
theorem eval_resVal {e : SymE} (he : ∀ w ∈ ws, e.noVar w = true) : e.eval (resVal ν ws f) = e.eval ν :=
  SymE.eval_congr (V := (· ∈ ws)) (fun _ hv => resVal_off hv) e he

theorem good_resVal {o : List Ans} (hg : Good ν o) (ho : ∀ q ∈ o, ∀ w ∈ ws, q.noVar w = true) :
    Good (resVal ν ws f) o := by
  intro q hq
  have h1 : ∀ w ∈ ws, q.a.noVar w = true := fun w hw => by
    have := ho q hq w hw; simp only [Ans.noVar, Bool.and_eq_true] at this; exact this.1
  have h2 : ∀ w ∈ ws, q.b.noVar w = true := fun w hw => by
    have := ho q hq w hw; simp only [Ans.noVar, Bool.and_eq_true] at this; exact this.2
  rw [eval_resVal h1, eval_resVal h2]
  exact hg q hq

/-- **The next-iteration valuation is untouched**: when no image of `θ` reads a fresh variable
other than `a`, setting `a` gives the same `Shift.valuation θ` from the merged valuation as from the
caller's. -/
theorem valuation_resVal (θ : Nat → SymE) (a : Nat) (x : F64)
    (hθ : ∀ j, ∀ w ∈ ws, w ≠ a → (θ j).noVar w = true) :
    Shift.valuation θ (upd (resVal ν ws f) a x) = Shift.valuation θ (upd ν a x) := by
  funext j
  refine SymE.eval_congr (V := fun w => w ∈ ws ∧ w ≠ a) (fun v hv => ?_) (θ j) fun w hw => hθ j w hw.1 hw.2
  by_cases hva : v = a
  · subst hva; rw [upd_self, upd_self]
  · rw [upd_other _ _ hva, upd_other _ _ hva]
    exact resVal_off fun hm => hv ⟨hm, hva⟩

end

/-- **The merge's valuation facts for fresh result variables**: with distinct `ws`, one per stage
entry past its start table, avoiding the caller's table, the merge's `hνS` and `hes` hold for
`resTab ws` at `resVal ν ws (resF θ S2 n0 ν)`. -/
theorem res_hνS {tab : List SymE} {ws : List Nat} (hfresh : ∀ e ∈ tab, ∀ w ∈ ws, e.noVar w = true)
    (θ : Nat → SymE) (S2 : List SymE) (n0 : Nat) (ν : Nat → F64) :
    ∀ e ∈ tab, e.eval (resVal ν ws (resF θ S2 n0 ν)) = e.eval ν :=
  fun e he => eval_resVal (hfresh e he)

theorem res_hes {ws : List Nat} (hnd : ws.Nodup) {S2 : List SymE} {n0 : Nat}
    (hlen : ws.length = S2.length - n0) (θ : Nat → SymE) (ν : Nat → F64) :
    ∀ j e, nth? (resTab ws) j = some e → ∃ e2, nth? S2 (n0 + j) = some e2 ∧
      e.eval (resVal ν ws (resF θ S2 n0 ν)) = e2.eval (Shift.valuation θ ν) := by
  intro j e he
  have hnth : ∀ (l : List Nat) (k : Nat) (e : SymE), nth? (l.map SymE.var) k = some e →
      ∃ w, nth? l k = some w ∧ e = .var w := by
    intro l
    induction l with
    | nil => intro k e h; cases h
    | cons w l ih =>
      intro k e h
      cases k with
      | zero => cases h; exact ⟨w, rfl, rfl⟩
      | succ k => exact ih k e h
  obtain ⟨w, hw, rfl⟩ := hnth ws j e he
  have hj : j < ws.length := nth?_lt _ _ _ hw
  obtain ⟨e2, he2⟩ : ∃ e2, nth? S2 (n0 + j) = some e2 := by
    have hlt : n0 + j < S2.length := by omega
    have : ∀ (l : List SymE) (k : Nat), k < l.length → ∃ x, nth? l k = some x := by
      intro l
      induction l with
      | nil => intro k hk; cases hk
      | cons x l ih =>
        intro k hk
        cases k with
        | zero => exact ⟨x, rfl⟩
        | succ k => exact ih k (by simp at hk; omega)
    exact this S2 _ hlt
  refine ⟨e2, he2, ?_⟩
  show resVal ν ws (resF θ S2 n0 ν) w = _
  rw [resVal_at hnd hw]
  simp only [resF, he2, Option.getD_some]

theorem resTab_length (ws : List Nat) : (resTab ws).length = ws.length := List.length_map _

end Host.Ts.Sim.Conv
