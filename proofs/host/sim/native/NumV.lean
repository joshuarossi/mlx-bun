import host.sim.native.Image
import host.sim.Num
namespace Host.Ts.Sim

/-! # Number requests with values

`numBin_simV` and `numTest_simV` are `numBin_sim`/`numTest_sim` with the
target server's growth (`CSrv.Le`) and the values of the results; the
target's concrete numbers may be literals or references (both handled by
`NumOK`). `numTest_vs_pure`: a source request answered by a target literal
computation of the same value. `TRuns`: a target computation that runs on
its own (used where the source gives up first). -/

section
variable {ν : Nat → F64}

/-- Server growth that also keeps the target table's prefix. -/
structure GrowL (M : Map) (ν : Nat → F64) (S : SSrv) (C : CSrv) (M' : Map) (S' : SSrv) (C' : CSrv) : Prop where
  grow : Grow M ν S C M' S' C'
  le : CSrv.Le C C'

theorem GrowL.refl {M : Map} {S : SSrv} {C : CSrv} (h : Srv M ν S C) : GrowL M ν S C M S C :=
  ⟨Grow.refl h, CSrv.Le.refl C⟩

theorem GrowL.trans {M M' M'' : Map} {S S' S'' : SSrv} {C C' C'' : CSrv}
    (h : GrowL M ν S C M' S' C') (h' : GrowL M' ν S' C' M'' S'' C'') : GrowL M ν S C M'' S'' C'' :=
  ⟨h.grow.trans h'.grow, h.le.trans h'.le⟩

private theorem srv_pushV {M : Map} {S : SSrv} {C C1 : CSrv} (hs : Srv M ν S C) (hle : CSrv.Le C C1)
    (e : SymE) (x : NumV) (hx : C1.val x = some (e.eval ν)) :
    Srv (M.setNum S.tab.length x) ν { S with tab := S.tab ++ [e] } C1 := by
  refine ⟨?_, hs.good⟩
  intro i e' he
  rcases nth?_append_eq S.tab e i e' he with ⟨hi, hi'⟩ | ⟨rfl, rfl⟩
  · rw [(M.setNum_ext S.tab.length x).num i hi]
    exact hle.val (hs.num i e' hi')
  · rw [M.setNum_self]
    exact hx

private theorem push_valV (C : CSrv) (x : F64) : (⟨C.tab ++ [x]⟩ : CSrv).val (.ref C.tab.length) = some x :=
  nth?_length_append C.tab x

private theorem growL_push {M : Map} {S : SSrv} {C C1 : CSrv} (hs : Srv M ν S C) (hle : CSrv.Le C C1)
    (e : SymE) (x : NumV) (hx : C1.val x = some (e.eval ν)) :
    GrowL M ν S C (M.setNum S.tab.length x) { S with tab := S.tab ++ [e] } C1 :=
  ⟨⟨M.setNum_ext _ _, srv_pushV hs hle e x hx, by simp⟩, hle⟩

/-- Values of numbers under the map. -/
theorem srv_val {M : Map} {S : SSrv} {C : CSrv} (hs : Srv M ν S C) {a : NumV} {e : SymE}
    (h : S.val a = some e) : C.val (M.nv a) = some (e.eval ν) := hs.num.val h

theorem numBin_simV {M : Map} {S : SSrv} {C : CSrv} (hs : Srv M ν S C) (op : NBin) (a b : NumV) :
    MSim (fun M' S' C' r r' => r' = M'.nv r ∧ GrowL M ν S C M' S' C' ∧ SN (· < S'.tab.length) r ∧
      ∀ va vb, C.val (M.nv a) = some va → C.val (M.nv b) = some vb → C'.val r' = some (F64.bin op va vb)) S C
      (numBin op a b) (numBin op (M.nv a) (M.nv b)) := by
  intro γ δ Q k k' hk
  have req : ∀ (K : Nat → Free γ), (∀ i, K i = k (.ref i)) →
      FSim Q S C (.bin op a b K) ((numBin op (M.nv a) (M.nv b)) δ k') := by
    intro K hK r S' hu
    rw [interpS_bin] at hu
    cases hva : S.val a with
    | none => rw [hva] at hu; cases hu
    | some ea =>
      cases hvb : S.val b with
      | none => rw [hva, hvb] at hu; cases hu
      | some eb =>
        rw [hva, hvb] at hu
        simp only at hu
        rw [hK] at hu
        have ca := hs.num.val hva
        have cb := hs.num.val hvb
        by_cases lits : ∃ u v, M.nv a = .lit u ∧ M.nv b = .lit v
        · obtain ⟨u, v, hu', hv'⟩ := lits
          rw [hu'] at ca; rw [hv'] at cb
          simp only [CSrv.val, Option.some.injEq] at ca cb
          subst ca cb
          have hg := growL_push hs (CSrv.Le.refl C) (.bin op ea eb) (.lit (F64.bin op (ea.eval ν) (eb.eval ν))) rfl
          obtain ⟨M', b', C', hv, hq⟩ := hk _ _ _ (.ref S.tab.length) (.lit (F64.bin op (ea.eval ν) (eb.eval ν)))
            ⟨(M.setNum_self _ _).symm, hg, by show S.tab.length < (S.tab ++ [_]).length; simp,
              fun va vb h1 h2 => by
                rw [hu'] at h1; rw [hv'] at h2
                simp only [CSrv.val, Option.some.injEq] at h1 h2
                subst h1 h2; rfl⟩ r S' hu
          refine ⟨M', b', C', ?_, hq⟩
          rw [hu', hv']
          exact hv
        · have hnot : ∀ u v, M.nv a = .lit u → M.nv b = .lit v → False := fun u v h1 h2 => lits ⟨u, v, h1, h2⟩
          have hg := growL_push hs (C1 := ⟨C.tab ++ [F64.bin op (ea.eval ν) (eb.eval ν)]⟩) ⟨_, rfl⟩
            (.bin op ea eb) (.ref C.tab.length) (push_valV C _)
          obtain ⟨M', b', C', hv, hq⟩ := hk _ _ _ (.ref S.tab.length) (.ref C.tab.length)
            ⟨(M.setNum_self _ _).symm, hg, by show S.tab.length < (S.tab ++ [_]).length; simp,
              fun va vb h1 h2 => by
                rw [ca] at h1; rw [cb] at h2
                simp only [Option.some.injEq] at h1 h2
                subst h1 h2; exact push_valV C _⟩ r S' hu
          refine ⟨M', b', C', ?_, hq⟩
          have e : (numBin op (M.nv a) (M.nv b)) δ k' = .bin op (M.nv a) (M.nv b) fun j => k' (.ref j) := by
            cases ha : M.nv a with
            | lit u =>
              cases hb : M.nv b with
              | lit v => exact (hnot u v ha hb).elim
              | ref _ => rfl
            | ref _ => cases M.nv b <;> rfl
          rw [e, interpC_bin, ca, cb]
          exact hv
  cases a with
  | lit x =>
    cases b with
    | lit y =>
      exact hk M S C _ _ ⟨rfl, GrowL.refl hs, trivial, fun va vb h1 h2 => by
        simp only [Map.nv, CSrv.val, Option.some.injEq] at h1 h2; subst h1 h2; rfl⟩
    | ref j => exact req _ (fun _ => rfl)
  | ref i =>
    cases b with
    | lit y => exact req _ (fun _ => rfl)
    | ref j => exact req _ (fun _ => rfl)

theorem numTest_simV {M : Map} {S : SSrv} {C : CSrv} (hs : Srv M ν S C) (op : NTest) (a b : NumV) :
    MSim (fun M' S' C' r r' => r' = r ∧ GrowL M ν S C M' S' C' ∧
      ∀ va vb, C.val (M.nv a) = some va → C.val (M.nv b) = some vb → r = F64.test op va vb) S C
      (numTest op a b) (numTest op (M.nv a) (M.nv b)) := by
  intro γ δ Q k k' hk
  have req : FSim Q S C (.test op a b k) ((numTest op (M.nv a) (M.nv b)) δ k') := by
    intro r S' hu
    rw [interpS_test] at hu
    cases hva : S.val a with
    | none => rw [hva] at hu; cases hu
    | some ea =>
      cases hvb : S.val b with
      | none => rw [hva, hvb] at hu; cases hu
      | some eb =>
        rw [hva, hvb] at hu
        simp only at hu
        cases hans : S.answer op ea eb with
        | none => rw [hans] at hu; cases hu
        | some p =>
          obtain ⟨t, S1⟩ := p
          rw [hans] at hu
          simp only at hu
          obtain ⟨ht, hg1, htab⟩ := SSrv.answer_good hs.good hans
          have hs1 : Srv M ν S1 C := ⟨fun i e he => hs.num i e (by rw [← htab]; exact he), hg1⟩
          have hg : GrowL M ν S C M S1 C := ⟨⟨Ext.refl _ _, hs1, by rw [htab]; exact Nat.le_refl _⟩, CSrv.Le.refl C⟩
          have ca := hs.num.val hva
          have cb := hs.num.val hvb
          obtain ⟨M', b', C', hv, hq⟩ := hk M S1 C t t ⟨rfl, hg, fun va vb h1 h2 => by
            rw [ca] at h1; rw [cb] at h2
            simp only [Option.some.injEq] at h1 h2
            subst h1 h2; exact ht.symm⟩ r S' hu
          refine ⟨M', b', C', ?_, hq⟩
          by_cases lits : ∃ u v, M.nv a = .lit u ∧ M.nv b = .lit v
          · obtain ⟨u, v, hu', hv'⟩ := lits
            rw [hu'] at ca; rw [hv'] at cb
            simp only [CSrv.val, Option.some.injEq] at ca cb
            subst ca cb
            rw [hu', hv']
            show interpC (k' (F64.test op (ea.eval ν) (eb.eval ν))) C = _
            rw [ht]
            exact hv
          · have hnot : ∀ u v, M.nv a = .lit u → M.nv b = .lit v → False := fun u v h1 h2 => lits ⟨u, v, h1, h2⟩
            have e : (numTest op (M.nv a) (M.nv b)) δ k' = .test op (M.nv a) (M.nv b) k' := by
              cases ha : M.nv a with
              | lit u =>
                cases hb : M.nv b with
                | lit v => exact (hnot u v ha hb).elim
                | ref _ => rfl
              | ref _ => cases M.nv b <;> rfl
            rw [e, interpC_test, ca, cb]
            simp only
            rw [ht]
            exact hv
  cases a with
  | lit x =>
    cases b with
    | lit y =>
      exact hk M S C _ _ ⟨rfl, GrowL.refl hs, fun va vb h1 h2 => by
        simp only [Map.nv, CSrv.val, Option.some.injEq] at h1 h2; subst h1 h2; rfl⟩
    | ref j => exact req
  | ref i =>
    cases b with
    | lit y => exact req
    | ref j => exact req

/-- A source request whose answer the target knows already. -/
theorem numTest_vs_pure {M : Map} {S : SSrv} {C : CSrv} (hs : Srv M ν S C) (op : NTest) (a b : NumV) (r0 : Bool)
    (h : ∀ va vb, C.val (M.nv a) = some va → C.val (M.nv b) = some vb → F64.test op va vb = r0) :
    MSim (fun M' S' C' r r' => r' = r ∧ GrowL M ν S C M' S' C' ∧
      ∀ va vb, C.val (M.nv a) = some va → C.val (M.nv b) = some vb → r = F64.test op va vb) S C
      (numTest op a b) (Host.Ts.M.pure r0) := by
  intro γ δ Q k k' hk
  have req : FSim Q S C (.test op a b k) (k' r0) := by
    intro r S' hu
    rw [interpS_test] at hu
    cases hva : S.val a with
    | none => rw [hva] at hu; cases hu
    | some ea =>
      cases hvb : S.val b with
      | none => rw [hva, hvb] at hu; cases hu
      | some eb =>
        rw [hva, hvb] at hu
        simp only at hu
        cases hans : S.answer op ea eb with
        | none => rw [hans] at hu; cases hu
        | some p =>
          obtain ⟨t, S1⟩ := p
          rw [hans] at hu
          simp only at hu
          obtain ⟨ht, hg1, htab⟩ := SSrv.answer_good hs.good hans
          have hs1 : Srv M ν S1 C := ⟨fun i e he => hs.num i e (by rw [← htab]; exact he), hg1⟩
          have hg : GrowL M ν S C M S1 C := ⟨⟨Ext.refl _ _, hs1, by rw [htab]; exact Nat.le_refl _⟩, CSrv.Le.refl C⟩
          have ca := hs.num.val hva
          have cb := hs.num.val hvb
          have htr : t = r0 := by rw [← ht]; exact h _ _ ca cb
          subst htr
          exact hk M S1 C t t ⟨rfl, hg, fun va vb h1 h2 => by
            rw [ca] at h1; rw [cb] at h2
            simp only [Option.some.injEq] at h1 h2
            subst h1 h2; exact ht.symm⟩ r S' hu
  cases a with
  | lit x =>
    cases b with
    | lit y =>
      have e := h x y rfl rfl
      show FSim Q S C (k (F64.test op x y)) (k' r0)
      rw [← e]
      exact hk M S C _ _ ⟨rfl, GrowL.refl hs, fun va vb h1 h2 => by
        simp only [Map.nv, CSrv.val, Option.some.injEq] at h1 h2; subst h1 h2; rfl⟩
    | ref j => exact req
  | ref i =>
    cases b with
    | lit y => exact req
    | ref j => exact req

/-! ## Target computations that run on their own -/

def TRuns {α : Type} (m : Host.Ts.M α) (C : CSrv) : Prop :=
  ∃ b C', CSrv.Le C C' ∧ ∀ δ (k : α → Free δ), interpC (m δ k) C = interpC (k b) C'

theorem TRuns.pure {α : Type} (a : α) (C : CSrv) : TRuns (Host.Ts.M.pure a) C :=
  ⟨a, C, CSrv.Le.refl C, fun _ _ => rfl⟩

theorem TRuns.bind {α β : Type} {m : Host.Ts.M α} {f : α → Host.Ts.M β} {C : CSrv} (hm : TRuns m C)
    (hf : ∀ a C', CSrv.Le C C' → TRuns (f a) C') : TRuns (Host.Ts.M.bind m f) C := by
  obtain ⟨b, C1, h1, e1⟩ := hm
  obtain ⟨b2, C2, h2, e2⟩ := hf b C1 h1
  exact ⟨b2, C2, h1.trans h2, fun δ k => by
    show interpC (m δ fun x => f x δ k) C = _
    rw [e1]; exact e2 δ k⟩

theorem TRuns.cond {α : Type} (c : Bool) {m1 m2 : Host.Ts.M α} {C : CSrv} (h1 : TRuns m1 C) (h2 : TRuns m2 C) :
    TRuns (bif c then m1 else m2) C := by cases c <;> assumption

theorem TRuns.numTest {C : CSrv} (op : NTest) {a b : NumV} {va vb : F64} (ha : C.val a = some va)
    (hb : C.val b = some vb) : TRuns (Host.Ts.numTest op a b) C := by
  cases a with
  | lit x =>
    cases b with
    | lit y => exact TRuns.pure _ C
    | ref j => exact ⟨F64.test op va vb, C, CSrv.Le.refl C, fun δ k => by
        show interpC (.test op (.lit x) (.ref j) k) C = _
        rw [interpC_test, ha, hb]⟩
  | ref i =>
    exact ⟨F64.test op va vb, C, CSrv.Le.refl C, fun δ k => by
      have e : (Host.Ts.numTest op (.ref i) b) δ k = .test op (.ref i) b k := by cases b <;> rfl
      rw [e, interpC_test, ha, hb]⟩

/-- The source gives up; the target runs on. -/
theorem msim_none {α β : Type} {M : Map} {S : SSrv} {C : CSrv} (hs : Srv M ν S C) {m' : Host.Ts.M β}
    (ht : TRuns m' C) :
    MSim (fun M' S' C' (r : Option α) (_ : β) => r = none ∧ GrowL M ν S C M' S' C') S C
      (Host.Ts.M.pure none) m' := by
  intro γ δ Q k k' hk
  obtain ⟨b, C', hle, e⟩ := ht
  have hs' : Srv M ν S C' := ⟨NumOK.mono hs.num (Ext.refl _ _) hle, hs.good⟩
  intro r S2 hu
  obtain ⟨M2, b2, C2, hc, hq⟩ := hk M S C' none b ⟨rfl, ⟨⟨Ext.refl _ _, hs', Nat.le_refl _⟩, hle⟩⟩ r S2 hu
  exact ⟨M2, b2, C2, by rw [e]; exact hc, hq⟩
end

end Host.Ts.Sim
