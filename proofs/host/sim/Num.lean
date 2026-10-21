import host.sim.Free
namespace Host.Ts.Sim

/-! # Numbers through the servers

The interpreter's numeric primitives under the map: a source request whose
target operands are literals is computed by the target directly; otherwise
both sides request. Either way the result's image has the entry's value. -/

section
variable {ν : Nat → F64}

private theorem srv_push {M : Map} {S : SSrv} {C C1 : CSrv} (hs : Srv M ν S C) (hle : CSrv.Le C C1)
    (e : SymE) (x : NumV) (hx : C1.val x = some (e.eval ν)) :
    Srv (M.setNum S.tab.length x) ν { S with tab := S.tab ++ [e] } C1 := by
  refine ⟨?_, hs.good⟩
  intro i e' he
  rcases nth?_append_eq S.tab e i e' he with ⟨hi, hi'⟩ | ⟨rfl, rfl⟩
  · rw [(M.setNum_ext S.tab.length x).num i hi]
    exact hle.val (hs.num i e' hi')
  · rw [M.setNum_self]
    exact hx

/-- A fresh concrete entry holds the pushed value. -/
private theorem push_val (C : CSrv) (x : F64) : (⟨C.tab ++ [x]⟩ : CSrv).val (.ref C.tab.length) = some x :=
  nth?_length_append C.tab x

private theorem grow_push {M : Map} {S : SSrv} {C C1 : CSrv} (hs : Srv M ν S C) (hle : CSrv.Le C C1)
    (e : SymE) (x : NumV) (hx : C1.val x = some (e.eval ν)) :
    Grow M ν S C (M.setNum S.tab.length x) { S with tab := S.tab ++ [e] } C1 :=
  ⟨M.setNum_ext _ _, srv_push hs hle e x hx, by simp⟩

private theorem numBin_req {δ : Type} (op : NBin) (x y : NumV) (k' : NumV → Free δ)
    (h : ∀ u v, x = .lit u → y = .lit v → False) :
    (numBin op x y) δ k' = .bin op x y fun j => k' (.ref j) := by
  cases x with
  | lit u =>
    cases y with
    | lit v => exact (h u v rfl rfl).elim
    | ref _ => rfl
  | ref _ => cases y <;> rfl

theorem numBin_sim {M : Map} {S : SSrv} {C : CSrv} (hs : Srv M ν S C) (op : NBin) (a b : NumV) :
    MSim (fun M' S' C' r r' => r' = M'.nv r ∧ Grow M ν S C M' S' C') S C
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
          have hg := grow_push hs (CSrv.Le.refl C) (.bin op ea eb) (.lit (F64.bin op (ea.eval ν) (eb.eval ν))) rfl
          obtain ⟨M', b', C', hv, hq⟩ := hk _ _ _ (.ref S.tab.length) (.lit (F64.bin op (ea.eval ν) (eb.eval ν)))
            ⟨(M.setNum_self _ _).symm, hg⟩ r S' hu
          refine ⟨M', b', C', ?_, hq⟩
          rw [hu', hv']
          exact hv
        · have hnot : ∀ u v, M.nv a = .lit u → M.nv b = .lit v → False := fun u v h1 h2 => lits ⟨u, v, h1, h2⟩
          have hg := grow_push hs (C1 := ⟨C.tab ++ [F64.bin op (ea.eval ν) (eb.eval ν)]⟩) ⟨_, rfl⟩
            (.bin op ea eb) (.ref C.tab.length) (push_val C _)
          obtain ⟨M', b', C', hv, hq⟩ := hk _ _ _ (.ref S.tab.length) (.ref C.tab.length)
            ⟨(M.setNum_self _ _).symm, hg⟩ r S' hu
          refine ⟨M', b', C', ?_, hq⟩
          rw [numBin_req op _ _ k' hnot, interpC_bin, ca, cb]
          exact hv
  cases a with
  | lit x =>
    cases b with
    | lit y => exact hk M S C _ _ ⟨rfl, Grow.refl hs⟩
    | ref j => exact req _ (fun _ => rfl)
  | ref i =>
    cases b with
    | lit y => exact req _ (fun _ => rfl)
    | ref j => exact req _ (fun _ => rfl)

private theorem numUn_req {δ : Type} (op : NUn) (x : NumV) (k' : NumV → Free δ)
    (h : ∀ u, x = .lit u → False) :
    (numUn op x) δ k' = .un op x fun j => k' (.ref j) := by
  cases x with
  | lit u => exact (h u rfl).elim
  | ref _ => rfl

theorem numUn_sim {M : Map} {S : SSrv} {C : CSrv} (hs : Srv M ν S C) (op : NUn) (a : NumV) :
    MSim (fun M' S' C' r r' => r' = M'.nv r ∧ Grow M ν S C M' S' C') S C (numUn op a) (numUn op (M.nv a)) := by
  intro γ δ Q k k' hk
  have req : ∀ (K : Nat → Free γ), (∀ i, K i = k (.ref i)) →
      FSim Q S C (.un op a K) ((numUn op (M.nv a)) δ k') := by
    intro K hK r S' hu
    rw [interpS_un] at hu
    cases hva : S.val a with
    | none => rw [hva] at hu; cases hu
    | some ea =>
      rw [hva] at hu
      simp only at hu
      rw [hK] at hu
      have ca := hs.num.val hva
      by_cases lit : ∃ u, M.nv a = .lit u
      · obtain ⟨u, hu'⟩ := lit
        rw [hu'] at ca
        simp only [CSrv.val, Option.some.injEq] at ca
        subst ca
        have hg := grow_push hs (CSrv.Le.refl C) (.un op ea) (.lit (F64.un op (ea.eval ν))) rfl
        obtain ⟨M', b', C', hv, hq⟩ := hk _ _ _ (.ref S.tab.length) (.lit (F64.un op (ea.eval ν)))
          ⟨(M.setNum_self _ _).symm, hg⟩ r S' hu
        refine ⟨M', b', C', ?_, hq⟩
        rw [hu']
        exact hv
      · have hnot : ∀ u, M.nv a = .lit u → False := fun u h1 => lit ⟨u, h1⟩
        have hg := grow_push hs (C1 := ⟨C.tab ++ [F64.un op (ea.eval ν)]⟩) ⟨_, rfl⟩
          (.un op ea) (.ref C.tab.length) (push_val C _)
        obtain ⟨M', b', C', hv, hq⟩ := hk _ _ _ (.ref S.tab.length) (.ref C.tab.length)
          ⟨(M.setNum_self _ _).symm, hg⟩ r S' hu
        refine ⟨M', b', C', ?_, hq⟩
        rw [numUn_req op _ k' hnot, interpC_un, ca]
        exact hv
  cases a with
  | lit x => exact hk M S C _ _ ⟨rfl, Grow.refl hs⟩
  | ref i => exact req _ (fun _ => rfl)

/-- A correct oracle answers a test with the binary64 result and keeps the table. -/
theorem SSrv.answer_good {S S1 : SSrv} {op : NTest} {x y : SymE} {r : Bool}
    (hg : Good ν S.oracle) (h : S.answer op x y = some (r, S1)) :
    F64.test op (x.eval ν) (y.eval ν) = r ∧ Good ν S1.oracle ∧ S1.tab = S.tab := by
  unfold SSrv.answer at h
  cases ho : S.oracle with
  | nil => simp [ho] at h
  | cons q o =>
    simp only [ho] at h
    cases hd : decide (q.op = op ∧ q.a = x ∧ q.b = y) <;>
      simp only [hd, Bool.cond_true, Bool.cond_false, Option.some.injEq, Prod.mk.injEq, reduceCtorEq] at h
    obtain ⟨rfl, rfl⟩ := h
    obtain ⟨rfl, rfl, rfl⟩ := of_decide_eq_true hd
    rw [ho] at hg
    exact ⟨hg q (List.mem_cons_self ..), fun q' hq' => hg q' (List.mem_cons_of_mem _ hq'), rfl⟩

private theorem numTest_req {δ : Type} (op : NTest) (x y : NumV) (k' : Bool → Free δ)
    (h : ∀ u v, x = .lit u → y = .lit v → False) :
    (numTest op x y) δ k' = .test op x y k' := by
  cases x with
  | lit u =>
    cases y with
    | lit v => exact (h u v rfl rfl).elim
    | ref _ => rfl
  | ref _ => cases y <;> rfl

theorem numTest_sim {M : Map} {S : SSrv} {C : CSrv} (hs : Srv M ν S C) (op : NTest) (a b : NumV) :
    MSim (fun M' S' C' r r' => r' = r ∧ Grow M ν S C M' S' C') S C (numTest op a b) (numTest op (M.nv a) (M.nv b)) := by
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
          have hg : Grow M ν S C M S1 C := ⟨Ext.refl _ _, hs1, by rw [htab]; exact Nat.le_refl _⟩
          have ca := hs.num.val hva
          have cb := hs.num.val hvb
          obtain ⟨M', b', C', hv, hq⟩ := hk M S1 C t t ⟨rfl, hg⟩ r S' hu
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
            rw [numTest_req op _ _ k' hnot, interpC_test, ca, cb]
            simp only
            rw [ht]
            exact hv
  cases a with
  | lit x =>
    cases b with
    | lit y => exact hk M S C _ _ ⟨rfl, Grow.refl hs⟩
    | ref j => exact req
  | ref i =>
    cases b with
    | lit y => exact req
    | ref j => exact req

theorem numConc_sim {M : Map} {S : SSrv} {C : CSrv} (hs : Srv M ν S C) (a : NumV) :
    MSim (fun M' S' C' r r' => r' = r ∧ Grow M ν S C M' S' C') S C (numConc a) (numConc (M.nv a)) := by
  intro γ δ Q k k' hk
  cases a with
  | lit x => exact hk M S C _ _ ⟨rfl, Grow.refl hs⟩
  | ref i =>
    intro r S' hu
    change interpS (.conc (.ref i) k) S = _ at hu
    rw [interpS_conc] at hu
    cases hva : S.val (.ref i) with
    | none => rw [hva] at hu; cases hu
    | some e =>
      rw [hva] at hu
      cases e with
      | lit x =>
        simp only at hu
        have ca := hs.num.val hva
        obtain ⟨M', b', C', hv, hq⟩ := hk M S C x x ⟨rfl, Grow.refl hs⟩ r S' hu
        refine ⟨M', b', C', ?_, hq⟩
        cases hn : M.nv (.ref i) with
        | lit u =>
          rw [hn] at ca
          simp only [CSrv.val, SymE.eval, Option.some.injEq] at ca
          subst ca
          exact hv
        | ref j =>
          rw [hn] at ca
          show interpC (.conc (.ref j) k') C = _
          rw [interpC_conc, ca]
          exact hv
      | var _ => cases hu
      | bin _ _ _ => cases hu
      | un _ _ => cases hu

end
end Host.Ts.Sim
