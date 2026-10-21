import host.sim.native.DimV
namespace Host.Ts.Sim
open Host.Mlx.Ffi (Dim Prim Node Cfg Clo Trace Pending dimOf)

/-! # Shapes with values

Shape computations over dimensions with values (`DVS`: a value relation and
closedness in the source server). `allEq`, `sliceAxis` (unit stride),
`sliceShape`, `broadcast` and two-input `concatShape` run in lockstep on the
source and on the target's imaged dimensions. `broadcast` compares dimensions
with the literal `1` syntactically: a source reference of value `1` whose
target image is the literal `1` makes the source give up while the target runs
on (`TRunsP`, `msim_noneP`). -/

theorem bind_pure_l {α β : Type} (a : α) (f : α → Host.Ts.M β) :
    Host.Ts.M.bind (Host.Ts.M.pure a) f = f a := rfl

/-! ## Target computations that run on their own, with a result property -/

def TRunsP {α : Type} (m : Host.Ts.M α) (C : CSrv) (Q : CSrv → α → Prop) : Prop :=
  ∃ b C', Q C' b ∧ CSrv.Le C C' ∧ ∀ δ (k : α → Free δ), interpC (m δ k) C = interpC (k b) C'

theorem TRuns.toP {α : Type} {m : Host.Ts.M α} {C : CSrv} (h : TRuns m C) : TRunsP m C fun _ _ => True :=
  let ⟨b, C', hle, e⟩ := h; ⟨b, C', trivial, hle, e⟩

theorem TRunsP.pure {α : Type} {Q : CSrv → α → Prop} (a : α) (C : CSrv) (h : Q C a) :
    TRunsP (Host.Ts.M.pure a) C Q :=
  ⟨a, C, h, CSrv.Le.refl C, fun _ _ => rfl⟩

theorem TRunsP.bind {α β : Type} {m : Host.Ts.M α} {f : α → Host.Ts.M β} {C : CSrv} {Q : CSrv → α → Prop}
    {R : CSrv → β → Prop} (hm : TRunsP m C Q) (hf : ∀ a C', CSrv.Le C C' → Q C' a → TRunsP (f a) C' R) :
    TRunsP (Host.Ts.M.bind m f) C R := by
  obtain ⟨b, C1, hq, h1, e1⟩ := hm
  obtain ⟨b2, C2, hr, h2, e2⟩ := hf b C1 h1 hq
  exact ⟨b2, C2, hr, h1.trans h2, fun δ k => by
    show interpC (m δ fun x => f x δ k) C = _
    rw [e1]; exact e2 δ k⟩

theorem TRunsP.mono {α : Type} {m : Host.Ts.M α} {C : CSrv} {Q Q' : CSrv → α → Prop} (h : TRunsP m C Q)
    (hq : ∀ C' a, Q C' a → Q' C' a) : TRunsP m C Q' :=
  let ⟨b, C', h1, h2, e⟩ := h; ⟨b, C', hq _ _ h1, h2, e⟩

/-- The source gives up; the target runs on to a result with a property. -/
theorem msim_noneP {ν : Nat → F64} {α β : Type} {M : Map} {S : SSrv} {C : CSrv} (hs : Srv M ν S C)
    {m' : Host.Ts.M β} {Q : CSrv → β → Prop} (ht : TRunsP m' C Q) :
    MSim (fun M' S' C' (r : Option α) r' => r = none ∧ GrowL M ν S C M' S' C' ∧ Q C' r') S C
      (Host.Ts.M.pure none) m' := by
  intro γ δ R k k' hk
  obtain ⟨b, C', hq, hle, e⟩ := ht
  have hs' : Srv M ν S C' := ⟨NumOK.mono hs.num (Ext.refl _ _) hle, hs.good⟩
  intro r S2 hu
  obtain ⟨M2, b2, C2, hc, hq'⟩ :=
    hk M S C' none b ⟨rfl, ⟨⟨Ext.refl _ _, hs', Nat.le_refl _⟩, hle⟩, hq⟩ r S2 hu
  exact ⟨M2, b2, C2, by rw [e]; exact hc, hq'⟩

/-! ## Target dimensions with values -/

/-- A target dimension whose number has a value. -/
def TV (C : CSrv) (d : Dim) : Prop := ∃ v, C.val d.num = some v

theorem TV.mono {C C' : CSrv} {d : Dim} (h : TV C d) (hle : CSrv.Le C C') : TV C' d :=
  let ⟨v, hv⟩ := h; ⟨v, hle.val hv⟩

theorem TV.lit (C : CSrv) (i : Int) : TV C (.lit i) := ⟨_, rfl⟩

theorem tv_dEq {C : CSrv} {a b : Dim} (ha : TV C a) (hb : TV C b) : TRuns (Host.Mlx.Ffi.dEq a b) C := by
  obtain ⟨va, ha⟩ := ha
  obtain ⟨vb, hb⟩ := hb
  cases a <;> cases b
  · exact TRuns.pure _ C
  all_goals (unfold Host.Mlx.Ffi.dEq; exact TRuns.cond _ (TRuns.pure _ C) (TRuns.numTest .eq ha hb))

theorem tv_allEq : ∀ (xs ys : List Dim) (C : CSrv), (∀ d ∈ xs, TV C d) → (∀ d ∈ ys, TV C d) →
    TRuns (Host.Mlx.Ffi.allEq xs ys) C
  | [], [], C, _, _ => TRuns.pure _ C
  | [], _ :: _, C, _, _ => TRuns.pure _ C
  | _ :: _, [], C, _, _ => TRuns.pure _ C
  | x :: xs, y :: ys, C, hx, hy => by
    show TRuns (Host.Ts.M.bind (Host.Mlx.Ffi.dEq x y) fun e =>
      bif e then Host.Mlx.Ffi.allEq xs ys else Host.Ts.M.pure false) C
    refine TRuns.bind (tv_dEq (hx x (by simp)) (hy y (by simp))) fun e C' hle => ?_
    exact TRuns.cond _ (tv_allEq xs ys C' (fun d hd => (hx d (by simp [hd])).mono hle)
      (fun d hd => (hy d (by simp [hd])).mono hle)) (TRuns.pure _ C')

/-- Target lists of dimensions with values. -/
def TVs (C : CSrv) (l : List Dim) : Prop := ∀ d ∈ l, TV C d

theorem TVs.mono {C C' : CSrv} {l : List Dim} (h : TVs C l) (hle : CSrv.Le C C') : TVs C' l :=
  fun d hd => (h d hd).mono hle

theorem tv_go : ∀ (xs ys : List Dim) (C : CSrv), TVs C xs → TVs C ys →
    TRunsP (Host.Mlx.Ffi.broadcast.go xs ys) C (fun C' r => ∀ l, r = some l → TVs C' l)
  | [], ys, C, _, hy => TRunsP.pure _ C fun l hl => by
      simp only [Option.some.injEq] at hl; subst hl; exact fun d hd => hy d (List.mem_reverse.mp hd)
  | x :: xs, [], C, hx, _ => TRunsP.pure _ C fun l hl => by
      simp only [Option.some.injEq] at hl; subst hl; exact fun d hd => hx d (List.mem_reverse.mp hd)
  | x :: xs, y :: ys, C, hx, hy => by
    have hx0 : TV C x := hx x (by simp)
    have hy0 : TV C y := hy y (by simp)
    have hxs : TVs C xs := fun d hd => hx d (by simp [hd])
    have hys : TVs C ys := fun d hd => hy d (by simp [hd])
    have hrec : ∀ (z : Dim) (C' : CSrv), CSrv.Le C C' → TV C' z →
        TRunsP (Host.Ts.M.bind (Host.Mlx.Ffi.broadcast.go xs ys) fun r =>
          Host.Ts.M.pure (r.map (· ++ [z]))) C' (fun C' r => ∀ l, r = some l → TVs C' l) := by
      intro z C' hle hz
      refine TRunsP.bind (tv_go xs ys C' (hxs.mono hle) (hys.mono hle)) fun r C2 hle2 hq => ?_
      refine TRunsP.pure _ C2 fun l hl => ?_
      cases r with
      | none => cases hl
      | some l0 =>
        simp only [Option.map_some, Option.some.injEq] at hl
        subst hl
        intro d hd
        rcases List.mem_append.mp hd with hd | hd
        · exact hq l0 rfl d hd
        · simp only [List.mem_singleton] at hd; subst hd; exact hz.mono hle2
    show TRunsP (Host.Ts.M.bind (Host.Mlx.Ffi.dEq x y) fun e =>
      bif e then Host.Ts.M.bind (Host.Mlx.Ffi.broadcast.go xs ys) (fun r => Host.Ts.M.pure (r.map (· ++ [x])))
      else bif decide (x = .lit 1) then
        Host.Ts.M.bind (Host.Mlx.Ffi.broadcast.go xs ys) (fun r => Host.Ts.M.pure (r.map (· ++ [y])))
      else bif decide (y = .lit 1) then
        Host.Ts.M.bind (Host.Mlx.Ffi.broadcast.go xs ys) (fun r => Host.Ts.M.pure (r.map (· ++ [x])))
      else Host.Ts.M.pure none) C _
    refine TRunsP.bind (tv_dEq hx0 hy0).toP fun e C' hle _ => ?_
    cases e
    · simp only [Bool.cond_false]
      cases decide (x = .lit 1)
      · cases decide (y = .lit 1)
        · exact TRunsP.pure _ C' fun l hl => by cases hl
        · exact hrec x C' hle (hx0.mono hle)
      · exact hrec y C' hle (hy0.mono hle)
    · exact hrec x C' hle (hx0.mono hle)

/-! ## Source dimensions with values -/

section
variable {ν : Nat → F64}

/-- A source dimension of value `k`, closed in the source server. -/
def DVS (M : Map) (C : CSrv) (S : SSrv) (d : Dim) (k : Nat) : Prop := DV M C d k ∧ SD (· < S.tab.length) d

theorem DVS.lift {M M' : Map} {S S' : SSrv} {C C' : CSrv} {d : Dim} {k : Nat} (h : DVS M C S d k)
    (hg : GrowL M ν S C M' S' C') : DVS M' C' S' d k ∧ M'.dim d = M.dim d := by
  refine ⟨⟨h.1.growL hg h.2, SD.mono (fun i hi => Nat.lt_of_lt_of_le hi hg.grow.len) h.2⟩, ?_⟩
  obtain ⟨h1, h2⟩ := h
  rcases h1 with rfl | ⟨j, rfl, _⟩
  · rfl
  · simp only [Map.dim, Map.nv, hg.grow.ext.num j h2]

theorem DVS.tv {M : Map} {S : SSrv} {C : CSrv} {d : Dim} {k : Nat} (h : DVS M C S d k) (hk : k < 2 ^ 53) :
    TV C (M.dim d) :=
  ⟨_, by rw [h.1.canon hk]; exact h.1.num⟩

theorem DVS.lit (M : Map) (C : CSrv) (S : SSrv) (k : Nat) : DVS M C S (.lit (k : Int)) k := ⟨.inl rfl, trivial⟩

/-- Lists of dimensions with values. -/
def DVSs (M : Map) (C : CSrv) (S : SSrv) : List Dim → List Nat → Prop
  | [], [] => True
  | d :: ds, k :: ks => DVS M C S d k ∧ DVSs M C S ds ks
  | _, _ => False

/-- Values below `2 ^ 31`. -/
def Bd (ks : List Nat) : Prop := ∀ k ∈ ks, k < 2 ^ 31

theorem Bd.cons {k : Nat} {ks : List Nat} : Bd (k :: ks) ↔ k < 2 ^ 31 ∧ Bd ks := by
  simp [Bd]

theorem DVSs.lift {M M' : Map} {S S' : SSrv} {C C' : CSrv} (hg : GrowL M ν S C M' S' C') :
    ∀ {ds : List Dim} {ks : List Nat}, DVSs M C S ds ks → DVSs M' C' S' ds ks ∧ M'.dims ds = M.dims ds
  | [], [], _ => ⟨trivial, rfl⟩
  | d :: ds, k :: ks, h => by
    obtain ⟨h1, h2⟩ := h
    obtain ⟨a1, b1⟩ := h1.lift hg
    obtain ⟨a2, b2⟩ := DVSs.lift hg h2
    refine ⟨⟨a1, a2⟩, ?_⟩
    show M'.dim d :: M'.dims ds = M.dim d :: M.dims ds
    rw [b1, b2]
  | [], _ :: _, h => h.elim
  | _ :: _, [], h => h.elim

theorem DVSs.length {M : Map} {S : SSrv} {C : CSrv} :
    ∀ {ds : List Dim} {ks : List Nat}, DVSs M C S ds ks → ds.length = ks.length
  | [], [], _ => rfl
  | _ :: _, _ :: _, h => by simp only [List.length_cons, DVSs.length h.2]
  | [], _ :: _, h => h.elim
  | _ :: _, [], h => h.elim

theorem DVSs.append {M : Map} {S : SSrv} {C : CSrv} :
    ∀ {a : List Dim} {ka : List Nat} {b : List Dim} {kb : List Nat}, DVSs M C S a ka → DVSs M C S b kb →
      DVSs M C S (a ++ b) (ka ++ kb)
  | [], [], _, _, _, hb => hb
  | _ :: _, _ :: _, _, _, ha, hb => ⟨ha.1, DVSs.append ha.2 hb⟩
  | [], _ :: _, _, _, ha, _ => ha.elim
  | _ :: _, [], _, _, ha, _ => ha.elim

theorem DVSs.reverse {M : Map} {S : SSrv} {C : CSrv} :
    ∀ {a : List Dim} {ka : List Nat}, DVSs M C S a ka → DVSs M C S a.reverse ka.reverse
  | [], [], _ => trivial
  | _ :: _, _ :: _, h => by
    simp only [List.reverse_cons]
    exact DVSs.append (DVSs.reverse h.2) ⟨h.1, trivial⟩
  | [], _ :: _, h => h.elim
  | _ :: _, [], h => h.elim

theorem DVSs.tvs {M : Map} {S : SSrv} {C : CSrv} :
    ∀ {a : List Dim} {ka : List Nat}, DVSs M C S a ka → Bd ka → TVs C (M.dims a)
  | [], [], _, _ => fun _ hd => by cases hd
  | d :: _, k :: _, h, hb => by
    intro e he
    rcases List.mem_cons.mp he with rfl | he
    · exact DVS.tv h.1 (by have := hb k (by simp); omega)
    · exact DVSs.tvs h.2 (fun k hk => hb k (by simp [hk])) e he
  | [], _ :: _, h, _ => h.elim
  | _ :: _, [], h, _ => h.elim

theorem DVSs.canon {M : Map} {S : SSrv} {C : CSrv} :
    ∀ {a : List Dim} {ka : List Nat}, DVSs M C S a ka → (∀ k ∈ ka, k < 2 ^ 53) → ∀ d ∈ a, DimCanon M d
  | [], [], _, _ => fun _ hd => by cases hd
  | d :: _, k :: _, h, hb => by
    intro e he
    rcases List.mem_cons.mp he with rfl | he
    · exact DV.dimCanon h.1.1 (hb k (by simp))
    · exact DVSs.canon h.2 (fun k hk => hb k (by simp [hk])) e he
  | [], _ :: _, h, _ => h.elim
  | _ :: _, [], h, _ => h.elim

theorem DVSs.sds {M : Map} {S : SSrv} {C : CSrv} :
    ∀ {a : List Dim} {ka : List Nat}, DVSs M C S a ka → SDs (· < S.tab.length) a
  | [], [], _ => fun _ hd => by cases hd
  | d :: _, _ :: _, h => by
    intro e he
    rcases List.mem_cons.mp he with rfl | he
    · exact h.1.2
    · exact DVSs.sds h.2 e he
  | [], _ :: _, h => h.elim
  | _ :: _, [], h => h.elim

theorem Bd.append {a b : List Nat} (ha : Bd a) (hb : Bd b) : Bd (a ++ b) := by
  intro k hk; rcases List.mem_append.mp hk with h | h; exact ha k h; exact hb k h

theorem Bd.reverse {a : List Nat} (ha : Bd a) : Bd a.reverse := fun k hk => ha k (List.mem_reverse.mp hk)

theorem Bd.lt53 {a : List Nat} (ha : Bd a) : ∀ k ∈ a, k < 2 ^ 53 := fun k hk => by have := ha k hk; omega

/-! ## `allEq` -/

theorem allEq_simV : ∀ {M : Map} {S : SSrv} {C : CSrv} {xs ys : List Dim} {kxs kys : List Nat},
    Srv M ν S C → DVSs M C S xs kxs → DVSs M C S ys kys → Bd kxs → Bd kys →
    MSim (BPost M ν S C (decide (kxs = kys))) S C (Host.Mlx.Ffi.allEq xs ys)
      (Host.Mlx.Ffi.allEq (M.dims xs) (M.dims ys))
  | _, _, _, [], [], [], [], hs, _, _, _, _ => MSim.pure ⟨rfl, rfl, GrowL.refl hs⟩
  | _, _, _, [], _ :: _, [], _ :: _, hs, _, _, _, _ => MSim.pure ⟨rfl, by simp, GrowL.refl hs⟩
  | _, _, _, _ :: _, [], _ :: _, [], hs, _, _, _, _ => MSim.pure ⟨rfl, by simp, GrowL.refl hs⟩
  | M, S, C, x :: xs, y :: ys, kx :: kxs, ky :: kys, hs, hx, hy, bx, by_ => by
    obtain ⟨hx, hxs⟩ := hx
    obtain ⟨hy, hys⟩ := hy
    rw [Bd.cons] at bx by_
    show MSim _ S C (Host.Ts.M.bind (Host.Mlx.Ffi.dEq x y) fun e =>
        bif e then Host.Mlx.Ffi.allEq xs ys else Host.Ts.M.pure false)
      (Host.Ts.M.bind (Host.Mlx.Ffi.dEq (M.dim x) (M.dim y)) fun e =>
        bif e then Host.Mlx.Ffi.allEq (M.dims xs) (M.dims ys) else Host.Ts.M.pure false)
    refine MSim.bind (dEq_simV hs hx.1 hy.1 (by omega) (by omega)) fun M1 S1 C1 e e' h => ?_
    obtain ⟨h1, h2, hg⟩ := h
    subst h1 h2
    by_cases hk : kx = ky
    · simp only [decide_eq_true hk, Bool.cond_true]
      obtain ⟨hxs', exs⟩ := DVSs.lift hg hxs
      obtain ⟨hys', eys⟩ := DVSs.lift hg hys
      rw [← exs, ← eys]
      refine MSim.mono (allEq_simV hg.grow.srv hxs' hys' bx.2 by_.2) fun M2 S2 C2 r r' h => ?_
      obtain ⟨h1, h2, hg2⟩ := h
      refine ⟨h1, ?_, hg.trans hg2⟩
      rw [h2]; subst hk; simp
    · simp only [decide_eq_false hk, Bool.cond_false]
      exact MSim.pure ⟨rfl, by simp [hk], hg⟩
  | _, _, _, [], [], _ :: _, _, _, hx, _, _, _ => hx.elim
  | _, _, _, [], [], [], _ :: _, _, _, hy, _, _ => hy.elim
  | _, _, _, _ :: _, _, [], _, _, hx, _, _, _ => hx.elim
  | _, _, _, [], _ :: _, _, [], _, _, hy, _, _ => hy.elim
  | _, _, _, [], _ :: _, _ :: _, _, _, hx, _, _, _ => hx.elim
  | _, _, _, _ :: _, [], _, _ :: _, _, _, hy, _, _ => hy.elim
  | _, _, _, _ :: _, _ :: _, _ :: _, [], _, _, hy, _, _ => hy.elim


/-! ## One axis of a unit-stride slice -/

theorem DPost.ex {M M' : Map} {S S' : SSrv} {C C' : CSrv} {k : Nat} {r r' : Dim}
    (h : DPost M ν S C k M' S' C' r r') : r' = M'.dim r ∧ DVS M' C' S' r k ∧ GrowL M ν S C M' S' C' :=
  ⟨h.1, ⟨h.2.1, h.2.2.1⟩, h.2.2.2⟩

/-- The postcondition of a dimension result below `2 ^ 31`. -/
def DPostB (M : Map) (ν : Nat → F64) (S : SSrv) (C : CSrv) : Map → SSrv → CSrv → Option Dim → Option Dim → Prop :=
  fun M' S' C' r r' => GrowL M ν S C M' S' C' ∧
    ∃ d k, r = some d ∧ r' = some (M'.dim d) ∧ DVS M' C' S' d k ∧ k < 2 ^ 31

theorem sliceAxis_simV {M : Map} {S : SSrv} {C : CSrv} {n s e : Dim} {kn ks ke : Nat} (hs : Srv M ν S C)
    (hn : DVS M C S n kn) (hsd : DVS M C S s ks) (he : DVS M C S e ke) (bn : kn < 2 ^ 31) (bs : ks < 2 ^ 31)
    (be : ke < 2 ^ 31) :
    MSim (DPostB M ν S C) S C (Host.Mlx.Ffi.sliceAxis n s e (.lit 1))
      (Host.Mlx.Ffi.sliceAxis (M.dim n) (M.dim s) (M.dim e) (.lit 1)) := by
  unfold Host.Mlx.Ffi.sliceAxis
  refine MSim.bind (dLt_simV hs hsd.1 (.inl rfl : DV M C (.lit 0) 0) (by omega) (by omega))
    fun M1 S1 C1 l l' h => ?_
  obtain ⟨h1, h2, g1⟩ := h
  subst h1 h2
  simp only [show decide (ks < 0) = false from by simp, Bool.cond_false, bind_pure_l]
  obtain ⟨hn, en⟩ := hn.lift g1
  obtain ⟨hsd, es⟩ := hsd.lift g1
  obtain ⟨he, ee⟩ := he.lift g1
  rw [← en, ← es, ← ee]
  have hs1 := g1.grow.srv
  refine MSim.bind (dLt_simV hs1 he.1 (.inl rfl : DV M1 C1 (.lit 0) 0) (by omega) (by omega))
    fun M2 S2 C2 l l' h => ?_
  obtain ⟨h1, h2, g2⟩ := h
  subst h1 h2
  simp only [show decide (ke < 0) = false from by simp, Bool.cond_false, bind_pure_l]
  obtain ⟨hn, en⟩ := hn.lift g2
  obtain ⟨hsd, es⟩ := hsd.lift g2
  obtain ⟨he, ee⟩ := he.lift g2
  rw [← en, ← es, ← ee]
  have hs2 := g2.grow.srv
  refine MSim.bind (dMin_simV hs2 hsd.1 hn.1 hsd.2 hn.2 (by omega) (by omega)) fun M3 S3 C3 st0 st0' h => ?_
  obtain ⟨rfl, hst0, g3⟩ := DPost.ex h
  have b3 : (if ks < kn then ks else kn) < 2 ^ 31 := by split <;> omega
  generalize (if ks < kn then ks else kn) = k3 at hst0 b3
  obtain ⟨hn, en⟩ := hn.lift g3
  obtain ⟨he, ee⟩ := he.lift g3
  rw [← en, ← ee]
  have hs3 := g3.grow.srv
  refine MSim.bind (dMax_simV hs3 (a := .lit 0) (ka := 0) (.inl rfl) hst0.1 trivial hst0.2 (by omega) (by omega))
    fun M4 S4 C4 st st' h => ?_
  obtain ⟨rfl, hst, g4⟩ := DPost.ex h
  have b4 : (if 0 < k3 then k3 else 0) < 2 ^ 31 := by split <;> omega
  generalize (if 0 < k3 then k3 else 0) = k4 at hst b4
  obtain ⟨hn, en⟩ := hn.lift g4
  obtain ⟨he, ee⟩ := he.lift g4
  rw [← en, ← ee]
  have hs4 := g4.grow.srv
  refine MSim.bind (dMin_simV hs4 he.1 hn.1 he.2 hn.2 (by omega) (by omega)) fun M5 S5 C5 ed0 ed0' h => ?_
  obtain ⟨rfl, hed0, g5⟩ := DPost.ex h
  have b5 : (if ke < kn then ke else kn) < 2 ^ 31 := by split <;> omega
  generalize (if ke < kn then ke else kn) = k5 at hed0 b5
  obtain ⟨hst, est⟩ := hst.lift g5
  rw [← est]
  have hs5 := g5.grow.srv
  refine MSim.bind (dMax_simV hs5 (a := .lit 0) (ka := 0) (.inl rfl) hed0.1 trivial hed0.2 (by omega) (by omega))
    fun M6 S6 C6 ed ed' h => ?_
  obtain ⟨rfl, hed, g6⟩ := DPost.ex h
  have b6 : (if 0 < k5 then k5 else 0) < 2 ^ 31 := by split <;> omega
  generalize (if 0 < k5 then k5 else 0) = k6 at hed b6
  obtain ⟨hst, est⟩ := hst.lift g6
  rw [← est]
  have hs6 := g6.grow.srv
  refine MSim.bind (dLt_simV hs6 hed.1 hst.1 (by omega) (by omega)) fun M7 S7 C7 l l' h => ?_
  obtain ⟨h1, h2, g7⟩ := h
  subst h1 h2
  obtain ⟨hst, est⟩ := hst.lift g7
  obtain ⟨hed, eed⟩ := hed.lift g7
  rw [← est, ← eed]
  have hs7 := g7.grow.srv
  have G := g1.trans (g2.trans (g3.trans (g4.trans (g5.trans (g6.trans g7)))))
  by_cases hlt : k6 < k4
  · simp only [decide_eq_true hlt, Bool.cond_true]
    refine MSim.bind (dSub_simV hs7 hst.1 hst.1 hst.2 hst.2 (by omega) (Nat.le_refl _))
      fun M8 S8 C8 r r' h => MSim.pure (M := M8) ?_
    obtain ⟨rfl, hr8, g8⟩ := DPost.ex h
    exact ⟨G.trans g8, r, _, rfl, rfl, hr8, by omega⟩
  · simp only [decide_eq_false hlt, Bool.cond_false]
    refine MSim.bind (dSub_simV hs7 hed.1 hst.1 hed.2 hst.2 (by omega) (by omega))
      fun M8 S8 C8 r r' h => MSim.pure (M := M8) ?_
    obtain ⟨rfl, hr8, g8⟩ := DPost.ex h
    exact ⟨G.trans g8, r, _, rfl, rfl, hr8, by omega⟩

/-! ## Unit-stride slice shapes -/

/-- The postcondition of a shape result: both give up, or both return related shapes. -/
def SPost (M : Map) (ν : Nat → F64) (S : SSrv) (C : CSrv) :
    Map → SSrv → CSrv → Option (List Dim) → Option (List Dim) → Prop :=
  fun M' S' C' r r' => GrowL M ν S C M' S' C' ∧ ((r = none ∧ r' = none) ∨
    ∃ ds kds, r = some ds ∧ r' = some (M'.dims ds) ∧ DVSs M' C' S' ds kds ∧ Bd kds)

theorem sliceShape_simV {ks : List Dim} (hk : ∀ k ∈ ks, k = .lit 1) : ∀ {M : Map} {S : SSrv} {C : CSrv}
    {ns ss es : List Dim} {kns kss kes : List Nat}, Srv M ν S C → DVSs M C S ns kns → DVSs M C S ss kss →
    DVSs M C S es kes → Bd kns → Bd kss → Bd kes →
    MSim (SPost M ν S C) S C (Host.Mlx.Ffi.sliceShape ns ss es ks)
      (Host.Mlx.Ffi.sliceShape (M.dims ns) (M.dims ss) (M.dims es) ks) := by
  induction ks with
  | nil =>
    intro M S C ns ss es kns kss kes hs _ _ _ _ _ _
    cases ns <;> cases ss <;> cases es <;>
      first
      | exact MSim.pure ⟨GrowL.refl hs, .inl ⟨rfl, rfl⟩⟩
      | exact MSim.pure ⟨GrowL.refl hs, .inr ⟨[], [], rfl, rfl, trivial, fun _ h => by cases h⟩⟩
  | cons k ks ih =>
    intro M S C ns ss es kns kss kes hs hn hss hes bn bs be
    have hk1 : k = .lit 1 := hk k (by simp)
    have hks : ∀ k ∈ ks, k = .lit 1 := fun k' h => hk k' (by simp [h])
    subst hk1
    cases ns with
    | nil => cases ss <;> cases es <;> exact MSim.pure ⟨GrowL.refl hs, .inl ⟨rfl, rfl⟩⟩
    | cons n ns =>
      cases ss with
      | nil => cases es <;> exact MSim.pure ⟨GrowL.refl hs, .inl ⟨rfl, rfl⟩⟩
      | cons s ss =>
        cases es with
        | nil => exact MSim.pure ⟨GrowL.refl hs, .inl ⟨rfl, rfl⟩⟩
        | cons e es =>
          cases kns with
          | nil => exact hn.elim
          | cons kn kns =>
          cases kss with
          | nil => exact hss.elim
          | cons ks0 kss =>
          cases kes with
          | nil => exact hes.elim
          | cons ke kes =>
          rw [Bd.cons] at bn bs be
          obtain ⟨hn0, hn⟩ := hn
          obtain ⟨hs0, hss⟩ := hss
          obtain ⟨he0, hes⟩ := hes
          show MSim _ S C (Host.Ts.M.bind (Host.Mlx.Ffi.sliceAxis n s e (.lit 1)) fun
              | some d => Host.Ts.M.bind (Host.Mlx.Ffi.sliceShape ns ss es ks) fun r =>
                Host.Ts.M.pure (r.map (d :: ·))
              | none => Host.Ts.M.pure none)
            (Host.Ts.M.bind (Host.Mlx.Ffi.sliceAxis (M.dim n) (M.dim s) (M.dim e) (.lit 1)) fun
              | some d => Host.Ts.M.bind (Host.Mlx.Ffi.sliceShape (M.dims ns) (M.dims ss) (M.dims es) ks) fun r =>
                Host.Ts.M.pure (r.map (d :: ·))
              | none => Host.Ts.M.pure none)
          refine MSim.bind (sliceAxis_simV hs hn0 hs0 he0 bn.1 bs.1 be.1) fun M1 S1 C1 r r' h => ?_
          obtain ⟨g1, d, kd, rfl, rfl, hd, bd⟩ := h
          obtain ⟨hn1, en⟩ := DVSs.lift g1 hn
          obtain ⟨hs1, es'⟩ := DVSs.lift g1 hss
          obtain ⟨he1, ee⟩ := DVSs.lift g1 hes
          show MSim _ S1 C1 (Host.Ts.M.bind (Host.Mlx.Ffi.sliceShape ns ss es ks) fun r =>
                Host.Ts.M.pure (r.map (d :: ·)))
            (Host.Ts.M.bind (Host.Mlx.Ffi.sliceShape (M.dims ns) (M.dims ss) (M.dims es) ks) fun r =>
                Host.Ts.M.pure (r.map (M1.dim d :: ·)))
          rw [← en, ← es', ← ee]
          refine MSim.bind (ih hks g1.grow.srv hn1 hs1 he1 bn.2 bs.2 be.2) fun M2 S2 C2 r r' h => MSim.pure (M := M2) ?_
          obtain ⟨g2, h⟩ := h
          obtain ⟨hd2, ed⟩ := hd.lift g2
          refine ⟨g1.trans g2, ?_⟩
          rcases h with ⟨rfl, rfl⟩ | ⟨ds, kds, rfl, rfl, hds, bds⟩
          · exact .inl ⟨rfl, rfl⟩
          · refine .inr ⟨d :: ds, kd :: kds, rfl, ?_, ⟨hd2, hds⟩, Bd.cons.mpr ⟨bd, bds⟩⟩
            show some (M1.dim d :: M2.dims ds) = some (M2.dim d :: M2.dims ds)
            rw [ed]

/-! ## Broadcasting -/

/-- The postcondition of a broadcast: the source gives up (the target's dimensions keep
values), or both return related shapes. -/
def BcPost (M : Map) (ν : Nat → F64) (S : SSrv) (C : CSrv) :
    Map → SSrv → CSrv → Option (List Dim) → Option (List Dim) → Prop :=
  fun M' S' C' r r' => GrowL M ν S C M' S' C' ∧ ((r = none ∧ ∀ l, r' = some l → TVs C' l) ∨
    ∃ ds kds, r = some ds ∧ r' = some (M'.dims ds) ∧ DVSs M' C' S' ds kds ∧ Bd kds)

theorem tv_goApp {C : CSrv} {xs ys : List Dim} (hx : TVs C xs) (hy : TVs C ys) {z : Dim} (hz : TV C z) :
    TRunsP (Host.Ts.M.bind (Host.Mlx.Ffi.broadcast.go xs ys) fun r => Host.Ts.M.pure (r.map (· ++ [z]))) C
      (fun C' r => ∀ l, r = some l → TVs C' l) := by
  refine TRunsP.bind (tv_go xs ys C hx hy) fun r C2 hle2 hq => ?_
  refine TRunsP.pure _ C2 fun l hl => ?_
  cases r with
  | none => cases hl
  | some l0 =>
    simp only [Option.map_some, Option.some.injEq] at hl
    subst hl
    intro d hd
    rcases List.mem_append.mp hd with hd | hd
    · exact hq l0 rfl d hd
    · simp only [List.mem_singleton] at hd; subst hd; exact hz.mono hle2

theorem go_simV : ∀ {M : Map} {S : SSrv} {C : CSrv} {xs ys : List Dim} {kxs kys : List Nat},
    Srv M ν S C → DVSs M C S xs kxs → DVSs M C S ys kys → Bd kxs → Bd kys →
    MSim (BcPost M ν S C) S C (Host.Mlx.Ffi.broadcast.go xs ys)
      (Host.Mlx.Ffi.broadcast.go (M.dims xs) (M.dims ys))
  | M, S, C, [], ys, [], kys, hs, _, hy, _, by_ =>
    MSim.pure ⟨GrowL.refl hs, .inr ⟨ys.reverse, kys.reverse, rfl, by simp [Map.dims, List.map_reverse],
      DVSs.reverse hy, Bd.reverse by_⟩⟩
  | M, S, C, x :: xs, [], kxs, [], hs, hx, _, bx, _ =>
    MSim.pure ⟨GrowL.refl hs, .inr ⟨(x :: xs).reverse, kxs.reverse, rfl,
      by simp only [Map.dims, List.map_reverse]; rfl, DVSs.reverse hx, Bd.reverse bx⟩⟩
  | M, S, C, x :: xs, y :: ys, kx :: kxs, ky :: kys, hs, hx, hy, bx, by_ => by
    obtain ⟨hx0, hxs⟩ := hx
    obtain ⟨hy0, hys⟩ := hy
    rw [Bd.cons] at bx by_
    show MSim _ S C (Host.Ts.M.bind (Host.Mlx.Ffi.dEq x y) fun e =>
        bif e then Host.Ts.M.bind (Host.Mlx.Ffi.broadcast.go xs ys) (fun r => Host.Ts.M.pure (r.map (· ++ [x])))
        else bif decide (x = .lit 1) then
          Host.Ts.M.bind (Host.Mlx.Ffi.broadcast.go xs ys) (fun r => Host.Ts.M.pure (r.map (· ++ [y])))
        else bif decide (y = .lit 1) then
          Host.Ts.M.bind (Host.Mlx.Ffi.broadcast.go xs ys) (fun r => Host.Ts.M.pure (r.map (· ++ [x])))
        else Host.Ts.M.pure none)
      (Host.Ts.M.bind (Host.Mlx.Ffi.dEq (M.dim x) (M.dim y)) fun e =>
        bif e then Host.Ts.M.bind (Host.Mlx.Ffi.broadcast.go (M.dims xs) (M.dims ys))
          (fun r => Host.Ts.M.pure (r.map (· ++ [M.dim x])))
        else bif decide (M.dim x = .lit 1) then
          Host.Ts.M.bind (Host.Mlx.Ffi.broadcast.go (M.dims xs) (M.dims ys))
            (fun r => Host.Ts.M.pure (r.map (· ++ [M.dim y])))
        else bif decide (M.dim y = .lit 1) then
          Host.Ts.M.bind (Host.Mlx.Ffi.broadcast.go (M.dims xs) (M.dims ys))
            (fun r => Host.Ts.M.pure (r.map (· ++ [M.dim x])))
        else Host.Ts.M.pure none)
    refine MSim.bind (dEq_simV hs hx0.1 hy0.1 (by omega) (by omega)) fun M1 S1 C1 e e' h => ?_
    obtain ⟨h1, h2, g1⟩ := h
    subst h1 h2
    obtain ⟨hx1, ex⟩ := hx0.lift g1
    obtain ⟨hy1, ey⟩ := hy0.lift g1
    obtain ⟨hxs1, exs⟩ := DVSs.lift g1 hxs
    obtain ⟨hys1, eys⟩ := DVSs.lift g1 hys
    rw [← ex, ← ey, ← exs, ← eys]
    have hs1 := g1.grow.srv
    have hrec : ∀ (z : Dim) (kz : Nat), DVS M1 C1 S1 z kz → kz < 2 ^ 31 →
        MSim (BcPost M ν S C) S1 C1
          (Host.Ts.M.bind (Host.Mlx.Ffi.broadcast.go xs ys) fun r => Host.Ts.M.pure (r.map (· ++ [z])))
          (Host.Ts.M.bind (Host.Mlx.Ffi.broadcast.go (M1.dims xs) (M1.dims ys)) fun r =>
            Host.Ts.M.pure (r.map (· ++ [M1.dim z]))) := by
      intro z kz hz bz
      refine MSim.bind (go_simV hs1 hxs1 hys1 bx.2 by_.2) fun M2 S2 C2 r r' h => MSim.pure (M := M2) ?_
      obtain ⟨g2, h⟩ := h
      obtain ⟨hz2, ez⟩ := hz.lift g2
      refine ⟨g1.trans g2, ?_⟩
      rcases h with ⟨rfl, ht⟩ | ⟨ds, kds, rfl, rfl, hds, bds⟩
      · refine .inl ⟨rfl, fun l hl => ?_⟩
        cases r' with
        | none => cases hl
        | some l0 =>
          simp only [Option.map_some, Option.some.injEq] at hl
          subst hl
          intro d hd
          rcases List.mem_append.mp hd with hd | hd
          · exact ht l0 rfl d hd
          · simp only [List.mem_singleton] at hd; subst hd; rw [← ez]; exact DVS.tv hz2 (by omega)
      · refine .inr ⟨ds ++ [z], kds ++ [kz], rfl, ?_, DVSs.append hds ⟨hz2, trivial⟩,
          Bd.append bds (by simp [Bd]; omega)⟩
        simp only [Option.map_some, Map.dims, List.map_append, List.map_cons, List.map_nil, ez]
    have hxv : TVs C1 (M1.dims xs) := DVSs.tvs hxs1 bx.2
    have hyv : TVs C1 (M1.dims ys) := DVSs.tvs hys1 by_.2
    by_cases hk : kx = ky
    · simp only [decide_eq_true hk, Bool.cond_true]
      exact hrec x kx hx1 bx.1
    · simp only [decide_eq_false hk, Bool.cond_false]
      by_cases hx1l : x = .lit 1
      · subst hx1l
        simp only [Map.dim_lit, decide_eq_true (rfl : (Dim.lit 1 : Dim) = .lit 1), Bool.cond_true]
        exact hrec y ky hy1 by_.1
      · simp only [decide_eq_false hx1l, Bool.cond_false]
        by_cases hx1r : M1.dim x = .lit 1
        · have hkx : kx = 1 := by
            rcases hx1.1.dim (by omega) with e1 | ⟨_, e1, _⟩ <;> rw [hx1r] at e1
            · simp only [Dim.lit.injEq] at e1; omega
            · cases e1
          have hy1l : y ≠ .lit 1 := by
            intro e; subst e; have := DV.lit_eq hy1.1; omega
          simp only [decide_eq_true hx1r, Bool.cond_true, decide_eq_false hy1l, Bool.cond_false]
          exact MSim.mono (msim_noneP hs1 (tv_goApp hxv hyv (DVS.tv hy1 (by omega))))
            fun M2 S2 C2 r r' h => ⟨g1.trans h.2.1, .inl ⟨h.1, h.2.2⟩⟩
        · simp only [decide_eq_false hx1r, Bool.cond_false]
          by_cases hy1l : y = .lit 1
          · subst hy1l
            simp only [Map.dim_lit, decide_eq_true (rfl : (Dim.lit 1 : Dim) = .lit 1), Bool.cond_true]
            exact hrec x kx hx1 bx.1
          · simp only [decide_eq_false hy1l, Bool.cond_false]
            by_cases hy1r : M1.dim y = .lit 1
            · simp only [decide_eq_true hy1r, Bool.cond_true]
              exact MSim.mono (msim_noneP hs1 (tv_goApp hxv hyv (DVS.tv hx1 (by omega))))
                fun M2 S2 C2 r r' h => ⟨g1.trans h.2.1, .inl ⟨h.1, h.2.2⟩⟩
            · simp only [decide_eq_false hy1r, Bool.cond_false]
              exact MSim.pure ⟨g1, .inl ⟨rfl, fun l hl => by cases hl⟩⟩
  | _, _, _, [], _, _ :: _, _, _, hx, _, _, _ => hx.elim
  | _, _, _, _ :: _, _, [], _, _, hx, _, _, _ => hx.elim
  | _, _, _, _ :: _, [], _, _ :: _, _, _, hy, _, _ => hy.elim
  | _, _, _, _ :: _, _ :: _, _ :: _, [], _, _, hy, _, _ => hy.elim

theorem broadcast_simV {M : Map} {S : SSrv} {C : CSrv} {a b : List Dim} {ka kb : List Nat} (hs : Srv M ν S C)
    (ha : DVSs M C S a ka) (hb : DVSs M C S b kb) (ba : Bd ka) (bb : Bd kb) :
    MSim (BcPost M ν S C) S C (Host.Mlx.Ffi.broadcast a b) (Host.Mlx.Ffi.broadcast (M.dims a) (M.dims b)) := by
  unfold Host.Mlx.Ffi.broadcast
  have e1 : (M.dims a).reverse = M.dims a.reverse := by simp [Map.dims, List.map_reverse]
  have e2 : (M.dims b).reverse = M.dims b.reverse := by simp [Map.dims, List.map_reverse]
  rw [e1, e2]
  exact MSim.bind (go_simV hs (DVSs.reverse ha) (DVSs.reverse hb) (Bd.reverse ba) (Bd.reverse bb))
    fun M' S' C' r r' h => MSim.pure h

end

end Host.Ts.Sim
