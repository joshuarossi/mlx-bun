import host.sim.native.NumV
import host.sim.native.Infer
import host.sim.LoopArith
namespace Host.Ts.Sim
open Host.Mlx.Ffi (Dim Prim Node Cfg Clo Trace Pending dimOf)

/-! # Dimensions with values

`DV M C d k`: dimension `d` of the source denotes the natural `k` at the target:
a literal `k`, or a number reference whose image the target server evaluates to
`F64.ofNat k`. Below `2 ^ 53` the target's dimension `M.dim d` is then a literal
`k` or a reference to `F64.ofNat k`, either way the integer the source's server
expression denotes, so the native integer fast path and the server arithmetic
agree (`dAdd_simV` …). -/

def DV (M : Map) (C : CSrv) (d : Dim) (k : Nat) : Prop :=
  d = .lit (k : Int) ∨ ∃ j, d = .sym (.ref j) ∧ C.val (M.num j) = some (F64.ofNat k)

theorem ofInt_natCast (k : Nat) : F64.ofInt (k : Int) = F64.ofNat k := rfl

theorem dimOf_ofNat (k : Nat) (hk : k < 2 ^ 53) : dimOf (.lit (F64.ofNat k)) = .lit (k : Int) := by
  simp only [dimOf, F64.toInt_ofNat53 k hk]

theorem ofNat_inj53 {a b : Nat} (ha : a < 2 ^ 53) (hb : b < 2 ^ 53) (h : F64.ofNat a = F64.ofNat b) : a = b := by
  have h1 := F64.toInt_ofNat53 a ha
  rw [h, F64.toInt_ofNat53 b hb] at h1
  simp only [Option.some.injEq, Int.natCast_inj] at h1
  exact h1.symm

section
variable {M : Map} {C : CSrv} {d : Dim} {k : Nat}

theorem DV.lit_eq {i : Int} (h : DV M C (.lit i) k) : i = k := by
  rcases h with h | ⟨j, h, -⟩
  · exact Dim.lit.inj h
  · cases h

theorem DV.num (h : DV M C d k) : C.val (M.nv d.num) = some (F64.ofNat k) := by
  rcases h with rfl | ⟨j, rfl, hj⟩
  · rfl
  · exact hj

/-- The target's dimension. -/
theorem DV.dim (h : DV M C d k) (hk : k < 2 ^ 53) :
    M.dim d = .lit (k : Int) ∨ ∃ j', M.dim d = .sym (.ref j') ∧ C.val (.ref j') = some (F64.ofNat k) := by
  rcases h with rfl | ⟨j, rfl, hj⟩
  · exact .inl rfl
  · show dimOf (M.num j) = _ ∨ ∃ j', dimOf (M.num j) = _ ∧ _
    cases e : M.num j with
    | lit f =>
      rw [e] at hj
      simp only [CSrv.val, Option.some.injEq] at hj
      subst hj
      exact .inl (dimOf_ofNat k hk)
    | ref j' => exact .inr ⟨j', rfl, by rw [e] at hj; exact hj⟩

theorem DV.canon (h : DV M C d k) (hk : k < 2 ^ 53) : (M.dim d).num = M.nv d.num := by
  rcases h with rfl | ⟨j, rfl, hj⟩
  · rfl
  · show (dimOf (M.num j)).num = M.num j
    cases e : M.num j with
    | lit f =>
      rw [e] at hj
      simp only [CSrv.val, Option.some.injEq] at hj
      subst hj
      rw [dimOf_ofNat k hk]; rfl
    | ref j' => rfl

theorem DV.dimCanon (h : DV M C d k) (hk : k < 2 ^ 53) : DimCanon M d := h.canon hk

theorem DV.mono {M' : Map} {C' : CSrv} {n : Nat} (h : DV M C d k) (he : Ext M M' n) (hs : SD (· < n) d)
    (hle : CSrv.Le C C') : DV M' C' d k := by
  rcases h with rfl | ⟨j, rfl, hj⟩
  · exact .inl rfl
  · exact .inr ⟨j, rfl, by rw [he.num j hs]; exact hle.val hj⟩

theorem DV.growL {ν : Nat → F64} {S S' : SSrv} {M' : Map} {C' : CSrv} (h : DV M C d k)
    (hg : GrowL M ν S C M' S' C') (hs : SD (· < S.tab.length) d) : DV M' C' d k :=
  h.mono hg.grow.ext hs hg.le

theorem DV.det {k' : Nat} (h : DV M C d k) (h' : DV M C d k') (hk : k < 2 ^ 53) (hk' : k' < 2 ^ 53) : k = k' := by
  have e1 := h.num
  have e2 := h'.num
  rw [e1] at e2
  exact ofNat_inj53 hk hk' (Option.some.inj e2)

theorem DV.target_eq {d' : Dim} {k' : Nat} (h : DV M C d k) (h' : DV M C d' k') (hk : k < 2 ^ 53)
    (hk' : k' < 2 ^ 53) (he : M.dim d = M.dim d') : k = k' := by
  rcases h.dim hk with e1 | ⟨j, e1, v1⟩ <;> rcases h'.dim hk' with e2 | ⟨j', e2, v2⟩
  · rw [e1, e2] at he; simp only [Dim.lit.injEq, Int.natCast_inj] at he; exact he
  · rw [e1, e2] at he; cases he
  · rw [e1, e2] at he; cases he
  · rw [e1, e2] at he
    simp only [Dim.sym.injEq, NumV.ref.injEq] at he
    subst he
    rw [v1] at v2
    exact ofNat_inj53 hk hk' (Option.some.inj v2)

theorem DV.ofVal {r : NumV} (h : C.val (M.nv r) = some (F64.ofNat k)) (hk : k < 2 ^ 53) : DV M C (dimOf r) k := by
  cases r with
  | lit f =>
    simp only [Map.nv, CSrv.val, Option.some.injEq] at h
    subst h
    rw [dimOf_ofNat k hk]; exact .inl rfl
  | ref j => exact .inr ⟨j, rfl, h⟩
end

theorem SD.dimOf {R : Nat → Prop} {r : NumV} (h : SN R r) : SD R (dimOf r) := by
  cases r with
  | lit f =>
    show SD R (match F64.toInt? f with | some i => .lit i | none => .sym (.lit f))
    cases F64.toInt? f <;> trivial
  | ref j => exact h

/-! ## Dimension operations -/

section
variable {ν : Nat → F64} {M : Map} {S : SSrv} {C : CSrv} (hs : Srv M ν S C)
include hs

/-- The postcondition of a dimension result of value `k`. -/
def DPost (M : Map) (ν : Nat → F64) (S : SSrv) (C : CSrv) (k : Nat) : Map → SSrv → CSrv → Dim → Dim → Prop :=
  fun M' S' C' r r' => r' = M'.dim r ∧ DV M' C' r k ∧ SD (· < S'.tab.length) r ∧ GrowL M ν S C M' S' C'

/-- The postcondition of a test of value `b`. -/
def BPost (M : Map) (ν : Nat → F64) (S : SSrv) (C : CSrv) (b : Bool) : Map → SSrv → CSrv → Bool → Bool → Prop :=
  fun M' S' C' r r' => r' = r ∧ r = b ∧ GrowL M ν S C M' S' C'

omit hs in
private theorem bothLit_or {a b : Dim} :
    (∃ i j, a = .lit i ∧ b = .lit j) ∨ ¬ (∃ i j, a = .lit i ∧ b = .lit j) := Classical.em _

omit hs in
theorem dArith_tgt {ka kb : Nat} {a b : Dim} (ha : DV M C a ka) (hb : DV M C b kb) (hka : ka < 2 ^ 53)
    (hkb : kb < 2 ^ 53) (op : NBin) (fi : Int → Int → Int) (r : Nat) (hr : r < 2 ^ 53)
    (hf : fi ka kb = (r : Int)) (hF : F64.bin op (F64.ofNat ka) (F64.ofNat kb) = F64.ofNat r)
    (D : Dim → Dim → Host.Ts.M Dim)
    (hDl : ∀ i j, D (.lit i) (.lit j) = Host.Ts.M.pure (.lit (fi i j)))
    (hDn : ∀ x y, ¬ (∃ i j, x = .lit i ∧ y = .lit j) → D x y = Host.Ts.M.bind (numBin op x.num y.num) fun q => Host.Ts.M.pure (dimOf q)) :
    D (M.dim a) (M.dim b) = Host.Ts.M.bind (numBin op (M.nv a.num) (M.nv b.num)) fun q => Host.Ts.M.pure (dimOf q) := by
  rcases bothLit_or (a := M.dim a) (b := M.dim b) with ⟨i, j, e1, e2⟩ | hn
  · rcases ha.dim hka with ea | ⟨j1, ea, _⟩ <;> rcases hb.dim hkb with eb | ⟨j2, eb, _⟩
    · rw [e1] at ea; rw [e2] at eb
      simp only [Dim.lit.injEq] at ea eb
      subst ea eb
      rw [e1, e2, hDl, ← ha.canon hka, ← hb.canon hkb, e1, e2]
      show Host.Ts.M.pure _ = Host.Ts.M.pure (dimOf (.lit (F64.bin op (F64.ofInt ka) (F64.ofInt kb))))
      rw [ofInt_natCast, ofInt_natCast, hF, dimOf_ofNat r hr, hf]
    · rw [e2] at eb; cases eb
    · rw [e1] at ea; cases ea
    · rw [e1] at ea; cases ea
  · rw [hDn _ _ hn, ha.canon hka, hb.canon hkb]

theorem dAdd_simV {a b : Dim} {ka kb : Nat} (ha : DV M C a ka) (hb : DV M C b kb) (hsa : SD (· < S.tab.length) a)
    (hsb : SD (· < S.tab.length) b) (hk : ka + kb < 2 ^ 53) :
    MSim (DPost M ν S C (ka + kb)) S C (Host.Mlx.Ffi.dAdd a b) (Host.Mlx.Ffi.dAdd (M.dim a) (M.dim b)) := by
  have hka : ka < 2 ^ 53 := by omega
  have hkb : kb < 2 ^ 53 := by omega
  rcases bothLit_or (a := a) (b := b) with ⟨i, j, rfl, rfl⟩ | hn
  · obtain rfl := DV.lit_eq ha
    obtain rfl := DV.lit_eq hb
    exact MSim.pure ⟨rfl, .inl (by simp), trivial, GrowL.refl hs⟩
  · have e1 : Host.Mlx.Ffi.dAdd a b = Host.Ts.M.bind (numBin .add a.num b.num) fun q => Host.Ts.M.pure (dimOf q) := by
      cases a <;> cases b <;> first | rfl | exact absurd ⟨_, _, rfl, rfl⟩ hn
    have e2 := dArith_tgt ha hb hka hkb .add (· + ·) (ka + kb) hk (by simp) (bin_add_ofNat ka kb hk)
      Host.Mlx.Ffi.dAdd (fun _ _ => rfl) (fun x y hxy => by
        cases x <;> cases y <;> first | rfl | exact absurd ⟨_, _, rfl, rfl⟩ hxy)
    rw [e1, e2]
    refine MSim.bind (numBin_simV hs .add a.num b.num) fun M' S' C' q q' ⟨hq, hg, hsq, hv⟩ => MSim.pure (M := M') ?_
    refine ⟨by rw [hq, Map.dim_dimOf], DV.ofVal ?_ hk, SD.dimOf hsq, hg⟩
    rw [← hq, hv _ _ ha.num hb.num, bin_add_ofNat ka kb hk]

theorem dSub_simV {a b : Dim} {ka kb : Nat} (ha : DV M C a ka) (hb : DV M C b kb) (hsa : SD (· < S.tab.length) a)
    (hsb : SD (· < S.tab.length) b) (hka : ka < 2 ^ 53) (hle : kb ≤ ka) :
    MSim (DPost M ν S C (ka - kb)) S C (Host.Mlx.Ffi.dSub a b) (Host.Mlx.Ffi.dSub (M.dim a) (M.dim b)) := by
  have hkb : kb < 2 ^ 53 := by omega
  have hr : ka - kb < 2 ^ 53 := by omega
  rcases bothLit_or (a := a) (b := b) with ⟨i, j, rfl, rfl⟩ | hn
  · obtain rfl := DV.lit_eq ha
    obtain rfl := DV.lit_eq hb
    exact MSim.pure ⟨rfl, .inl (by simp only [Dim.lit.injEq]; omega), trivial, GrowL.refl hs⟩
  · have e1 : Host.Mlx.Ffi.dSub a b = Host.Ts.M.bind (numBin .sub a.num b.num) fun q => Host.Ts.M.pure (dimOf q) := by
      cases a <;> cases b <;> first | rfl | exact absurd ⟨_, _, rfl, rfl⟩ hn
    have e2 := dArith_tgt ha hb hka hkb .sub (· - ·) (ka - kb) hr (by omega) (bin_sub_ofNat ka kb hka hle)
      Host.Mlx.Ffi.dSub (fun _ _ => rfl) (fun x y hxy => by
        cases x <;> cases y <;> first | rfl | exact absurd ⟨_, _, rfl, rfl⟩ hxy)
    rw [e1, e2]
    refine MSim.bind (numBin_simV hs .sub a.num b.num) fun M' S' C' q q' ⟨hq, hg, hsq, hv⟩ => MSim.pure (M := M') ?_
    refine ⟨by rw [hq, Map.dim_dimOf], DV.ofVal ?_ hr, SD.dimOf hsq, hg⟩
    rw [← hq, hv _ _ ha.num hb.num, bin_sub_ofNat ka kb hka hle]

theorem dLt_simV {a b : Dim} {ka kb : Nat} (ha : DV M C a ka) (hb : DV M C b kb) (hka : ka < 2 ^ 53)
    (hkb : kb < 2 ^ 53) :
    MSim (BPost M ν S C (decide (ka < kb))) S C (Host.Mlx.Ffi.dLt a b) (Host.Mlx.Ffi.dLt (M.dim a) (M.dim b)) := by
  rcases bothLit_or (a := a) (b := b) with ⟨i, j, rfl, rfl⟩ | hn
  · obtain rfl := DV.lit_eq ha
    obtain rfl := DV.lit_eq hb
    exact MSim.pure ⟨rfl, by simp, GrowL.refl hs⟩
  · have e1 : Host.Mlx.Ffi.dLt a b = numTest .lt a.num b.num := by
      cases a <;> cases b <;> first | rfl | exact absurd ⟨_, _, rfl, rfl⟩ hn
    have e2 : Host.Mlx.Ffi.dLt (M.dim a) (M.dim b) = numTest .lt (M.nv a.num) (M.nv b.num) := by
      rcases bothLit_or (a := M.dim a) (b := M.dim b) with ⟨i, j, e3, e4⟩ | hn'
      · rcases ha.dim hka with ea | ⟨_, ea, _⟩ <;> rcases hb.dim hkb with eb | ⟨_, eb, _⟩
        · rw [e3] at ea; rw [e4] at eb
          simp only [Dim.lit.injEq] at ea eb
          subst ea eb
          rw [e3, e4, ← ha.canon hka, ← hb.canon hkb, e3, e4]
          show Host.Ts.M.pure _ = Host.Ts.M.pure (F64.test .lt (F64.ofInt ka) (F64.ofInt kb))
          rw [ofInt_natCast, ofInt_natCast, test_lt_ofNat ka kb hka hkb]; simp
        all_goals (rw [e3] at ea; rw [e4] at eb; simp at ea eb)
      · rw [← ha.canon hka, ← hb.canon hkb]
        cases e3 : M.dim a <;> cases e4 : M.dim b <;> first | rfl | (rw [e3, e4] at hn'; exact absurd ⟨_, _, rfl, rfl⟩ hn')
    rw [e1, e2]
    refine MSim.mono (numTest_simV hs .lt a.num b.num) fun M' S' C' r r' ⟨h1, h2, h3⟩ => ⟨h1, ?_, h2⟩
    rw [h3 _ _ ha.num hb.num, test_lt_ofNat ka kb hka hkb]

omit hs in
theorem dEq_self (x : Dim) : Host.Mlx.Ffi.dEq x x = Host.Ts.M.pure true := by
  cases x with
  | lit i => show Host.Ts.M.pure (decide (i = i)) = _; simp
  | sym v => show (bif decide (Dim.sym v = Dim.sym v) then _ else _) = _; simp

theorem dEq_simV {a b : Dim} {ka kb : Nat} (ha : DV M C a ka) (hb : DV M C b kb) (hka : ka < 2 ^ 53)
    (hkb : kb < 2 ^ 53) :
    MSim (BPost M ν S C (decide (ka = kb))) S C (Host.Mlx.Ffi.dEq a b) (Host.Mlx.Ffi.dEq (M.dim a) (M.dim b)) := by
  rcases bothLit_or (a := a) (b := b) with ⟨i, j, rfl, rfl⟩ | hn
  · obtain rfl := DV.lit_eq ha
    obtain rfl := DV.lit_eq hb
    exact MSim.pure ⟨rfl, by simp; constructor <;> intro h <;> omega, GrowL.refl hs⟩
  · by_cases hab : a = b
    · subst hab
      rw [dEq_self, dEq_self]
      exact MSim.pure ⟨rfl, by simp [ha.det hb hka hkb], GrowL.refl hs⟩
    · have e1 : Host.Mlx.Ffi.dEq a b = numTest .eq a.num b.num := by
        have : Host.Mlx.Ffi.dEq a b = bif decide (a = b) then Host.Ts.M.pure true else numTest .eq a.num b.num := by
          cases a <;> cases b <;> first | rfl | exact absurd ⟨_, _, rfl, rfl⟩ hn
        rw [this, decide_eq_false hab]; rfl
      rw [e1]
      have post : ∀ M' S' C' r r', (r' = r ∧ GrowL M ν S C M' S' C' ∧
          ∀ va vb, C.val (M.nv a.num) = some va → C.val (M.nv b.num) = some vb → r = F64.test .eq va vb) →
          BPost M ν S C (decide (ka = kb)) M' S' C' r r' := fun M' S' C' r r' ⟨h1, h2, h3⟩ =>
        ⟨h1, by rw [h3 _ _ ha.num hb.num, test_eq_ofNat ka kb hka hkb], h2⟩
      rcases bothLit_or (a := M.dim a) (b := M.dim b) with ⟨i, j, e3, e4⟩ | hn'
      · have e2 : Host.Mlx.Ffi.dEq (M.dim a) (M.dim b) = numTest .eq (M.nv a.num) (M.nv b.num) := by
          rcases ha.dim hka with ea | ⟨_, ea, _⟩ <;> rcases hb.dim hkb with eb | ⟨_, eb, _⟩
          · rw [e3] at ea; rw [e4] at eb
            simp only [Dim.lit.injEq] at ea eb
            subst ea eb
            rw [e3, e4, ← ha.canon hka, ← hb.canon hkb, e3, e4]
            show Host.Ts.M.pure _ = Host.Ts.M.pure (F64.test .eq (F64.ofInt ka) (F64.ofInt kb))
            rw [ofInt_natCast, ofInt_natCast, test_eq_ofNat ka kb hka hkb]; congr 1; exact decide_eq_decide.mpr ⟨fun h => by omega, fun h => by omega⟩
          all_goals (rw [e3] at ea; rw [e4] at eb; simp at ea eb)
        rw [e2]
        exact MSim.mono (numTest_simV hs .eq a.num b.num) post
      · by_cases hab' : M.dim a = M.dim b
        · have e2 : Host.Mlx.Ffi.dEq (M.dim a) (M.dim b) = Host.Ts.M.pure true := by rw [hab', dEq_self]
          rw [e2]
          have hk := ha.target_eq hb hka hkb hab'
          refine MSim.mono (numTest_vs_pure hs .eq a.num b.num true fun va vb h1 h2 => ?_) post
          rw [ha.num] at h1; rw [hb.num] at h2
          simp only [Option.some.injEq] at h1 h2
          subst h1 h2
          rw [test_eq_ofNat ka kb hka hkb, hk]; simp
        · have e2 : Host.Mlx.Ffi.dEq (M.dim a) (M.dim b) = numTest .eq (M.nv a.num) (M.nv b.num) := by
            have : Host.Mlx.Ffi.dEq (M.dim a) (M.dim b) =
                bif decide (M.dim a = M.dim b) then Host.Ts.M.pure true else numTest .eq (M.dim a).num (M.dim b).num := by
              cases e3 : M.dim a <;> cases e4 : M.dim b <;>
                first | rfl | (rw [e3, e4] at hn'; exact absurd ⟨_, _, rfl, rfl⟩ hn')
            rw [this, decide_eq_false hab', ha.canon hka, hb.canon hkb]; rfl
          rw [e2]
          exact MSim.mono (numTest_simV hs .eq a.num b.num) post

theorem dMin_simV {a b : Dim} {ka kb : Nat} (ha : DV M C a ka) (hb : DV M C b kb) (hsa : SD (· < S.tab.length) a)
    (hsb : SD (· < S.tab.length) b) (hka : ka < 2 ^ 53) (hkb : kb < 2 ^ 53) :
    MSim (DPost M ν S C (if ka < kb then ka else kb)) S C (Host.Mlx.Ffi.dMin a b) (Host.Mlx.Ffi.dMin (M.dim a) (M.dim b)) := by
  unfold Host.Mlx.Ffi.dMin
  refine MSim.bind (dLt_simV hs ha hb hka hkb) fun M' S' C' l l' ⟨h1, h2, hg⟩ => MSim.pure (M := M') ?_
  subst h1 h2
  have hsa' : SD (· < S'.tab.length) a := SD.mono (fun i hi => Nat.lt_of_lt_of_le hi hg.grow.len) hsa
  have hsb' : SD (· < S'.tab.length) b := SD.mono (fun i hi => Nat.lt_of_lt_of_le hi hg.grow.len) hsb
  have ea : M'.dim a = M.dim a := by rcases ha with rfl | ⟨j, rfl, _⟩; rfl; simp only [Map.dim, Map.nv, hg.grow.ext.num j hsa]
  have eb : M'.dim b = M.dim b := by rcases hb with rfl | ⟨j, rfl, _⟩; rfl; simp only [Map.dim, Map.nv, hg.grow.ext.num j hsb]
  by_cases hlt : ka < kb
  · simp only [decide_eq_true hlt, Bool.cond_true, if_pos hlt]
    exact ⟨ea.symm, ha.growL hg hsa, hsa', hg⟩
  · simp only [decide_eq_false hlt, Bool.cond_false, if_neg hlt]
    exact ⟨eb.symm, hb.growL hg hsb, hsb', hg⟩

theorem dMax_simV {a b : Dim} {ka kb : Nat} (ha : DV M C a ka) (hb : DV M C b kb) (hsa : SD (· < S.tab.length) a)
    (hsb : SD (· < S.tab.length) b) (hka : ka < 2 ^ 53) (hkb : kb < 2 ^ 53) :
    MSim (DPost M ν S C (if ka < kb then kb else ka)) S C (Host.Mlx.Ffi.dMax a b) (Host.Mlx.Ffi.dMax (M.dim a) (M.dim b)) := by
  unfold Host.Mlx.Ffi.dMax
  refine MSim.bind (dLt_simV hs ha hb hka hkb) fun M' S' C' l l' ⟨h1, h2, hg⟩ => MSim.pure (M := M') ?_
  subst h1 h2
  have hsa' : SD (· < S'.tab.length) a := SD.mono (fun i hi => Nat.lt_of_lt_of_le hi hg.grow.len) hsa
  have hsb' : SD (· < S'.tab.length) b := SD.mono (fun i hi => Nat.lt_of_lt_of_le hi hg.grow.len) hsb
  have ea : M'.dim a = M.dim a := by rcases ha with rfl | ⟨j, rfl, _⟩; rfl; simp only [Map.dim, Map.nv, hg.grow.ext.num j hsa]
  have eb : M'.dim b = M.dim b := by rcases hb with rfl | ⟨j, rfl, _⟩; rfl; simp only [Map.dim, Map.nv, hg.grow.ext.num j hsb]
  by_cases hlt : ka < kb
  · simp only [decide_eq_true hlt, Bool.cond_true, if_pos hlt]
    exact ⟨eb.symm, hb.growL hg hsb, hsb', hg⟩
  · simp only [decide_eq_false hlt, Bool.cond_false, if_neg hlt]
    exact ⟨ea.symm, ha.growL hg hsa, hsa', hg⟩
end

end Host.Ts.Sim
