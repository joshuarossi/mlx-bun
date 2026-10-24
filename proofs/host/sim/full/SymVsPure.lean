import host.sim.full.SymDims
namespace Host.Ts.Sim
open Host.Mlx.Ffi (Dim dimOf)

/-! # Template requests the target answers without a request

Where the target's dimensions are literals, its products and tests are literal computations while
the template's are server requests. `numBin_vs_pure`, `dMul_vs_pure`, `dProd_vs_pure` and
`dLt_vs_pure`: the template's request against the target's literal result, the template's new
reference mapped to that literal (as `numTest_vs_pure` for tests). `dProd_simVF`: `dProd_simV`
whose postcondition also has the target's product literal where the target's dimensions are. -/

section
variable {ν : Nat → F64}

theorem growL_pushL {M : Map} {S : SSrv} {C : CSrv} (hs : Srv M ν S C) (e : SymE) (x : NumV)
    (hx : C.val x = some (e.eval ν)) :
    GrowL M ν S C (M.setNum S.tab.length x) { S with tab := S.tab ++ [e] } C := by
  refine ⟨⟨M.setNum_ext _ _, ⟨?_, hs.good⟩, by simp⟩, CSrv.Le.refl C⟩
  intro i e' he
  rcases nth?_append_eq S.tab e i e' he with ⟨hi, hi'⟩ | ⟨rfl, rfl⟩
  · rw [(M.setNum_ext S.tab.length x).num i hi]
    exact hs.num i e' hi'
  · rw [M.setNum_self]
    exact hx

theorem numBin_vs_pure {M : Map} {S : SSrv} {C : CSrv} (hs : Srv M ν S C) (op : NBin) (a b : NumV) {va vb : F64}
    (ha : C.val (M.nv a) = some va) (hb : C.val (M.nv b) = some vb) :
    MSim (fun M' S' C' r r' => r' = M'.nv r ∧ r' = .lit (F64.bin op va vb) ∧ GrowL M ν S C M' S' C' ∧
      SN (· < S'.tab.length) r) S C (numBin op a b) (Host.Ts.M.pure (.lit (F64.bin op va vb))) := by
  intro γ δ Q k k' hk
  have req : ∀ (K : Nat → Free γ), (∀ i, K i = k (.ref i)) →
      FSim Q S C (.bin op a b K) (k' (.lit (F64.bin op va vb))) := by
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
        rw [ha] at ca; rw [hb] at cb
        simp only [Option.some.injEq] at ca cb
        subst ca cb
        have hg := growL_pushL hs (.bin op ea eb) (.lit (F64.bin op (ea.eval ν) (eb.eval ν))) rfl
        exact hk _ _ _ (.ref S.tab.length) _ ⟨(M.setNum_self _ _).symm, rfl, hg,
          by show S.tab.length < (S.tab ++ [_]).length; simp⟩ r S' hu
  cases a with
  | lit x =>
    cases b with
    | lit y =>
      simp only [Map.nv, CSrv.val, Option.some.injEq] at ha hb
      subst ha hb
      exact hk M S C _ _ ⟨rfl, rfl, GrowL.refl hs, trivial⟩
    | ref j => exact req _ (fun _ => rfl)
  | ref i =>
    cases b with
    | lit y => exact req _ (fun _ => rfl)
    | ref j => exact req _ (fun _ => rfl)

/-- The postcondition of a dimension result of value `k` against the target's literal. -/
def DPostL (M : Map) (ν : Nat → F64) (S : SSrv) (C : CSrv) (k : Nat) : Map → SSrv → CSrv → Dim → Dim → Prop :=
  fun M' S' C' r r' => DPost M ν S C k M' S' C' r r' ∧ r' = .lit (k : Int)

section
variable {M : Map} {S : SSrv} {C : CSrv} (hs : Srv M ν S C)
include hs

theorem dMul_vs_pure {a b : Dim} {ka kb : Nat} (ha : DV M C a ka) (hb : DV M C b kb)
    (hk : ka * kb < 2 ^ 53) (hka : ka < 2 ^ 53) (hkb : kb < 2 ^ 53) :
    MSim (DPostL M ν S C (ka * kb)) S C (Host.Mlx.Ffi.dMul a b) (Host.Ts.M.pure (.lit ((ka * kb : Nat) : Int))) := by
  by_cases hl : ∃ i j, a = .lit i ∧ b = .lit j
  · obtain ⟨i, j, rfl, rfl⟩ := hl
    obtain rfl := DV.lit_eq ha
    obtain rfl := DV.lit_eq hb
    have e : ((ka : Int) * (kb : Int)) = ((ka * kb : Nat) : Int) := by simp
    show MSim _ S C (Host.Ts.M.pure (Dim.lit ((ka : Int) * (kb : Int)))) _
    rw [e]
    exact MSim.pure ⟨⟨rfl, .inl rfl, trivial, GrowL.refl hs⟩, rfl⟩
  · have e1 : Host.Mlx.Ffi.dMul a b = Host.Ts.M.bind (numBin .mul a.num b.num) fun q => Host.Ts.M.pure (dimOf q) := by
      cases a <;> cases b <;> first | rfl | exact absurd ⟨_, _, rfl, rfl⟩ hl
    have hf := bin_mul_ofNat ka kb hka hkb hk
    have e2 : (Host.Ts.M.pure (.lit ((ka * kb : Nat) : Int)) : Host.Ts.M Dim) =
        Host.Ts.M.bind (Host.Ts.M.pure (NumV.lit (F64.bin .mul (F64.ofNat ka) (F64.ofNat kb)))) fun q =>
          Host.Ts.M.pure (dimOf q) := by
      show _ = Host.Ts.M.pure (dimOf (.lit (F64.bin .mul (F64.ofNat ka) (F64.ofNat kb))))
      rw [hf, dimOf_ofNat _ hk]
    rw [e1, e2]
    refine MSim.bind (numBin_vs_pure hs .mul a.num b.num ha.num hb.num) fun M' S' C' q q' h => ?_
    obtain ⟨hq, hq', hg, hsq⟩ := h
    refine MSim.pure (M := M') ⟨⟨by rw [hq, Map.dim_dimOf], DV.ofVal ?_ hk, SD.dimOf hsq, hg⟩, ?_⟩
    · rw [← hq, hq', hf]; rfl
    · rw [hq', hf, dimOf_ofNat _ hk]

end

/-- **A product against the target's literal product.** -/
theorem dProd_vs_pure : ∀ {M : Map} {S : SSrv} {C : CSrv} {ds : List Dim} {ks : List Nat}, Srv M ν S C →
    DVSs M C S ds ks → (∀ k ∈ ks, k < 2 ^ 53) → ProdB ks →
    MSim (DPostL M ν S C (natProd ks)) S C (Host.Mlx.Ffi.dProd ds) (Host.Ts.M.pure (.lit (natProd ks : Int)))
  | M, S, C, [], [], hs, _, _, _ => MSim.pure ⟨⟨rfl, .inl rfl, trivial, GrowL.refl hs⟩, rfl⟩
  | M, S, C, d :: ds, k :: ks, hs, ⟨hd, hds⟩, hb, hp => by
    have hk : k < 2 ^ 53 := hb k List.mem_cons_self
    have hbs : ∀ k ∈ ks, k < 2 ^ 53 := fun k' h => hb k' (List.mem_cons_of_mem _ h)
    have hp0 : k * natProd ks < 2 ^ 53 := hp 0
    have hp1 : natProd ks < 2 ^ 53 := hp 1
    show MSim _ S C (Host.Ts.M.bind (Host.Mlx.Ffi.dProd ds) fun p => Host.Mlx.Ffi.dMul d p)
      (Host.Ts.M.bind (Host.Ts.M.pure (Dim.lit (natProd ks : Int))) fun _ =>
        Host.Ts.M.pure (Dim.lit ((k * natProd ks : Nat) : Int)))
    refine MSim.bind (dProd_vs_pure hs hds hbs hp.tail) fun M' S' C' p p' h => ?_
    obtain ⟨⟨-, hpv, hps, hg⟩, -⟩ := h
    obtain ⟨hd', -⟩ := DVS.lift hd hg
    exact MSim.mono (dMul_vs_pure hg.grow.srv hd'.1 hpv hp0 hk hp1) fun M'' S'' C'' r r' h =>
      ⟨⟨h.1.1, h.1.2.1, h.1.2.2.1, hg.trans h.1.2.2.2⟩, h.2⟩

/-- The target's product of literal dimensions. -/
theorem dProd_lits : ∀ {M : Map} {S : SSrv} {C : CSrv} {ds : List Dim} {ks : List Nat},
    DVSs M C S ds ks → (∀ k ∈ ks, k < 2 ^ 53) → (M.dims ds).all Host.Ts.Sim.dimLit = true →
    Host.Mlx.Ffi.dProd (M.dims ds) = Host.Ts.M.pure (.lit (natProd ks : Int))
  | _, _, _, [], [], _, _, _ => rfl
  | M, S, C, d :: ds, k :: ks, ⟨hd, hds⟩, hb, hl => by
    simp only [Map.dims, List.map_cons, List.all_cons, Bool.and_eq_true] at hl
    have ih := dProd_lits hds (fun k' h => hb k' (List.mem_cons_of_mem _ h)) hl.2
    have hk : k < 2 ^ 53 := hb k List.mem_cons_self
    have hdl : M.dim d = .lit (k : Int) := by
      rcases hd.1.dim hk with e | ⟨j, e, -⟩
      · exact e
      · have := hl.1; rw [e] at this; cases this
    show Host.Ts.M.bind (Host.Mlx.Ffi.dProd (M.dims ds)) (fun p => Host.Mlx.Ffi.dMul (M.dim d) p) = _
    rw [ih, hdl]
    show Host.Ts.M.pure (Dim.lit ((k : Int) * (natProd ks : Int))) = _
    simp [natProd]

/-- **Products whose target is literal where its dimensions are.** -/
theorem dProd_simVF {M : Map} {S : SSrv} {C : CSrv} {ds : List Dim} {ks : List Nat} (hs : Srv M ν S C)
    (hds : DVSs M C S ds ks) (hb : ∀ k ∈ ks, k < 2 ^ 53) (hp : ProdB ks) :
    MSim (fun M' S' C' r r' => DPost M ν S C (natProd ks) M' S' C' r r' ∧
      ((M.dims ds).all Host.Ts.Sim.dimLit = true → r' = .lit (natProd ks : Int))) S C
      (Host.Mlx.Ffi.dProd ds) (Host.Mlx.Ffi.dProd (M.dims ds)) := by
  by_cases hl : (M.dims ds).all Host.Ts.Sim.dimLit = true
  · rw [dProd_lits hds hb hl]
    exact MSim.mono (dProd_vs_pure hs hds hb hp) fun _ _ _ _ _ h => ⟨h.1, fun _ => h.2⟩
  · exact MSim.mono (dProd_simV hs hds hb hp) fun _ _ _ _ _ h => ⟨h, fun h' => absurd h' hl⟩

/-- **A positivity test against the target's literal test.** -/
theorem dLt_vs_pure {M : Map} {S : SSrv} {C : CSrv} (hs : Srv M ν S C) {p : Dim} {kp : Nat} (hp : DV M C p kp)
    (hk : kp < 2 ^ 53) :
    MSim (BPost M ν S C (decide (0 < kp))) S C (Host.Mlx.Ffi.dLt (.lit 0) p) (Host.Ts.M.pure (decide (0 < kp))) := by
  cases p with
  | lit i =>
    obtain rfl := DV.lit_eq hp
    have e : decide ((0 : Int) < (kp : Int)) = decide (0 < kp) := by simp
    show MSim _ S C (Host.Ts.M.pure (decide ((0 : Int) < (kp : Int))) : Host.Ts.M Bool) _
    rw [e]
    exact MSim.pure ⟨rfl, rfl, GrowL.refl hs⟩
  | sym x =>
    show MSim _ S C (numTest .lt (Dim.lit 0).num x) _
    refine MSim.mono (numTest_vs_pure hs .lt (Dim.lit 0).num x (decide (0 < kp)) fun va vb h1 h2 => ?_)
      fun M' S' C' r r' h => ⟨h.1, ?_, h.2.1⟩
    · have h2' := hp.num
      simp only [Dim.num] at h2'
      rw [h2'] at h2
      simp only [Map.nv, CSrv.val, Dim.num, Option.some.injEq] at h1 h2
      subst h1 h2
      rw [show F64.ofInt 0 = F64.ofNat 0 from rfl]
      exact test_lt_ofNat 0 kp (by omega) hk
    · have h2' := hp.num
      simp only [Dim.num] at h2'
      rw [h.2.2 _ _ rfl h2']
      rw [show F64.ofInt 0 = F64.ofNat 0 from rfl]
      exact test_lt_ofNat 0 kp (by omega) hk

end

end Host.Ts.Sim
