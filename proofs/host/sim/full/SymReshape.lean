import host.sim.full.SymConv
import host.sim.full.SymVsPure
import host.sim.native.Lawful
namespace Host.Ts.Sim.G
open Host.Mlx.Ffi (Dim Prim Node Out dimOf)
open Host.Mlx.Ffi.SymShape (callSym symShapeCall opOutSym inferSym cancelDims eraseDim isSym reshapeRest
  reshapeCancel)

/-! # Reshapes with `-1` over symbolic dimensions

The model's `mlx_reshape` with `-1` infers the dimension only from literal products; over a
symbolic product it is stuck and the symbolic-shape layer completes it (`SymShape.inferSym`: the
given dimensions are cut from the input's leading ones where they are equal, by `allEq`, otherwise
cancelled as a multiset; the inferred dimension is the product of the rest). For the forward's
reshapes the input shape is dimensions equal to the given ones followed by literal ones (`[B, L, H, D]`
to `[B, L, -1]`, the two `L` possibly different numbers of equal value). `sim_reshapeNeg`: the
layer's completed call (`callSym`) of the template simulates the target's, whichever of the model's
and the layer's inference each side reaches: both the model's (`rsLit`: literal products), both the
layer's (`reshape_L1`: the same answer to `allEq` on both sides), or the template the layer's and
the target the model's (`reshape_L2`, the template's requests against the target's literal results).
Where the template's leading dimensions differ in value its reshape gives no output; the target's
still runs (`TRuns`). -/

/-- The given dimensions of a reshape with `-1`. -/
abbrev givenOf (new : List Dim) : List Dim := new.filter (· ≠ .lit (-1))

/-- The output shape, `-1` replaced by `v`. -/
def fillNeg (v : Dim) (new : List Dim) : List Dim := new.map fun x => bif decide (x = .lit (-1)) then v else x

theorem dims_lits (M : Map) : ∀ {ds : List Dim}, ds.all dimLit = true → M.dims ds = ds
  | [], _ => rfl
  | d :: ds, h => by
    simp only [List.all_cons, Bool.and_eq_true] at h
    cases d with
    | lit i => show Dim.lit i :: M.dims ds = _; rw [dims_lits M h.2]
    | sym _ => cases h.1

theorem natProd_append : ∀ (a b : List Nat), natProd (a ++ b) = natProd a * natProd b
  | [], b => by simp [natProd]
  | k :: a, b => by
    show k * natProd (a ++ b) = (k * natProd a) * natProd b
    rw [natProd_append a b, Nat.mul_assoc]

theorem DVSs.split {M : Map} {S : SSrv} {C : CSrv} :
    ∀ {a b : List Dim} {ks : List Nat}, DVSs M C S (a ++ b) ks →
      ∃ ka kb, ks = ka ++ kb ∧ DVSs M C S a ka ∧ DVSs M C S b kb
  | [], _, ks, h => ⟨[], ks, rfl, trivial, h⟩
  | _ :: a, b, [], h => h.elim
  | _ :: a, b, k :: ks, h => by
    obtain ⟨ka, kb, rfl, h1, h2⟩ := DVSs.split (a := a) (b := b) h.2
    exact ⟨k :: ka, kb, rfl, ⟨h.1, h1⟩, h2⟩

theorem DVSs.mem {M : Map} {S : SSrv} {C : CSrv} :
    ∀ {ds : List Dim} {ks : List Nat}, DVSs M C S ds ks → Bd ks → ∀ x ∈ ds, ∃ k, DVS M C S x k ∧ k < 2 ^ 31
  | [], [], _, _ => fun _ hx => by cases hx
  | d :: _, k :: _, h, hb => by
    intro x hx
    rcases List.mem_cons.mp hx with rfl | hx
    · exact ⟨k, h.1, hb k List.mem_cons_self⟩
    · exact DVSs.mem h.2 (fun k' hk => hb k' (List.mem_cons_of_mem _ hk)) x hx
  | [], _ :: _, h, _ => h.elim
  | _ :: _, [], h, _ => h.elim

theorem dim_ne_neg {M : Map} {C : CSrv} {d : Dim} {k : Nat} (h : DV M C d k) (hk : k < 2 ^ 53) :
    M.dim d ≠ .lit (-1) := by
  rcases h.dim hk with e | ⟨j, e, -⟩ <;> rw [e]
  · simp only [ne_eq, Dim.lit.injEq]; omega
  · simp

/-- Filters of a reshape's dimensions under the map. -/
theorem filter_neg_map (M : Map) : ∀ {new : List Dim}, (∀ x ∈ new, x ≠ .lit (-1) → M.dim x ≠ .lit (-1)) →
    (M.dims new).filter (· = .lit (-1)) = new.filter (· = .lit (-1)) ∧
      (M.dims new).filter (· ≠ .lit (-1)) = M.dims (new.filter (· ≠ .lit (-1)))
  | [], _ => ⟨rfl, rfl⟩
  | x :: xs, h => by
    obtain ⟨ih1, ih2⟩ := filter_neg_map M (new := xs) fun y hy => h y (List.mem_cons_of_mem _ hy)
    by_cases hx : x = .lit (-1)
    · subst hx
      have e : M.dim (.lit (-1)) = .lit (-1) := rfl
      simp only [Map.dims, decide_not] at ih1 ih2 ⊢
      simp [e, ih1, ih2]
    · have hm := h x List.mem_cons_self hx
      simp only [Map.dims, decide_not] at ih1 ih2 ⊢
      simp [hx, hm, ih1, ih2]

theorem dims_fillNeg {M M' : Map} {v : Int} : ∀ {new : List Dim},
    (∀ x ∈ new, x ≠ .lit (-1) → M.dim x ≠ .lit (-1) ∧ M'.dim x = M.dim x) →
    fillNeg (.lit v) (M.dims new) = M'.dims (fillNeg (.lit v) new)
  | [], _ => rfl
  | x :: xs, h => by
    have ih := dims_fillNeg (v := v) (new := xs) fun y hy => h y (List.mem_cons_of_mem _ hy)
    simp only [fillNeg, Map.dims, List.map_cons] at ih ⊢
    rw [ih]
    congr 1
    by_cases hx : x = .lit (-1)
    · subst hx; rfl
    · obtain ⟨h1, h2⟩ := h x List.mem_cons_self hx
      simp only [h1, hx, decide_false, Bool.cond_false, h2]

theorem mem_fillNeg {v e : Dim} {new : List Dim} (h : e ∈ fillNeg v new) :
    e = v ∨ (e ∈ new ∧ e ≠ .lit (-1)) := by
  obtain ⟨x, hx, rfl⟩ := List.mem_map.mp h
  by_cases e1 : x = .lit (-1)
  · left; simp [e1]
  · right; simp only [e1, decide_false, Bool.cond_false]; exact ⟨hx, e1⟩

/-! ## The layer's inference -/

theorem inferSym_reshapeG {new old : List Dim} {d : Nat} (hg : (old ++ new).any isSym = true)
    (hc : len (new.filter (· = .lit (-1))) = 1) :
    inferSym (.reshape new) [(old, d)] =
      Host.Ts.M.bind (Host.Mlx.Ffi.allEq (old.take (new.filter (· ≠ .lit (-1))).length)
          (new.filter (· ≠ .lit (-1)))) fun pre =>
        bif pre then reshapeRest new (new.filter (· ≠ .lit (-1))) (old.drop (new.filter (· ≠ .lit (-1))).length) d
        else reshapeCancel new (new.filter (· ≠ .lit (-1))) old d := by
  rw [Host.Mlx.Ffi.SymShape.inferSym_reshape_eq, hg, hc]
  rfl

theorem reshapeRest_eq (new given rest : List Dim) (d : Nat) :
    reshapeRest new given rest d =
      Host.Ts.M.bind (Host.Mlx.Ffi.dProd given) fun p =>
        Host.Ts.M.bind (Host.Mlx.Ffi.dLt (.lit 0) p) fun pos =>
          bif pos then Host.Ts.M.bind (Host.Mlx.Ffi.dProd rest) fun q =>
            Host.Ts.M.pure (some (Out.node (fillNeg q new) d))
          else Host.Ts.M.pure none := rfl

theorem reshapeCancel_none {new given old : List Dim} {d : Nat} (h : cancelDims old given = none) :
    reshapeCancel new given old d = Host.Ts.M.pure none := by
  simp only [Host.Mlx.Ffi.SymShape.reshapeCancel, h]

theorem inferSym_reshape_lit {new old : List Dim} {d : Nat} (hg : (old ++ new).any isSym = false) :
    inferSym (.reshape new) [(old, d)] = Host.Ts.M.pure none := by
  unfold inferSym
  dsimp only
  rw [hg]
  rfl

/-- The multiset cancellation keeps elements of the input. -/
theorem eraseDim_sub {d : Dim} : ∀ {xs ys : List Dim}, eraseDim d xs = some ys → ∀ y ∈ ys, y ∈ xs
  | [], _, h => by cases h
  | x :: xs, ys, h => by
    unfold eraseDim at h
    cases e : decide (x = d)
    · rw [e, Bool.cond_false] at h
      cases h' : eraseDim d xs with
      | none => rw [h'] at h; cases h
      | some zs =>
        rw [h', Option.map_some, Option.some.injEq] at h
        subst h
        intro y hy
        rcases List.mem_cons.mp hy with rfl | hy
        · exact List.mem_cons_self
        · exact List.mem_cons_of_mem _ (eraseDim_sub h' y hy)
    · rw [e, Bool.cond_true, Option.some.injEq] at h
      subst h
      exact fun y hy => List.mem_cons_of_mem _ hy

theorem cancelDims_sub : ∀ {xs ds ys : List Dim}, cancelDims xs ds = some ys → ∀ y ∈ ys, y ∈ xs
  | xs, [], ys, h => by cases h; exact fun _ hy => hy
  | xs, d :: ds, ys, h => by
    unfold cancelDims at h
    cases h' : eraseDim d xs with
    | none => rw [h'] at h; cases h
    | some zs =>
      rw [h', Option.bind_some] at h
      exact fun y hy => eraseDim_sub h' y (cancelDims_sub h y hy)


theorem reshapeCancel_l (nw gv old : List Dim) (d : Nat) : BufSim.Lawful (reshapeCancel nw gv old d) := by
  unfold Host.Mlx.Ffi.SymShape.reshapeCancel
  split
  · exact BufSim.Lawful.bind (NativeLawful.dProd_l _) fun _ => BufSim.Lawful.bind (NativeLawful.dLt_l _ _) fun _ =>
      BufSim.Lawful.cond _ (BufSim.Lawful.bind (NativeLawful.dProd_l _) fun _ => BufSim.Lawful.pure _)
        (BufSim.Lawful.pure _)
  · exact BufSim.Lawful.pure _

/-! ## Target computations that run

Where the template's reshape gives no output the target's still has to run; its numbers have
values (`Valued`), so its requests are answered. -/

/-- A number of the target with a value. -/
abbrev Valued (C : CSrv) (x : NumV) : Prop := (C.val x).isSome = true

theorem Valued.le {C C' : CSrv} (h : CSrv.Le C C') {x : NumV} (hx : Valued C x) : Valued C' x := by
  obtain ⟨v, hv⟩ := Option.isSome_iff_exists.mp hx
  show (C'.val x).isSome = true
  rw [CSrv.Le.val h hv]; rfl

/-- A target computation that runs from `C`, its result satisfying `Q`. -/
def TRuns {β : Type} (Q : β → CSrv → Prop) (m : Host.Ts.M β) (C : CSrv) : Prop :=
  ∃ b C', interpC m.run C = some (b, C') ∧ CSrv.Le C C' ∧ Q b C'

theorem TRuns.pure {β : Type} {Q : β → CSrv → Prop} {b : β} {C : CSrv} (h : Q b C) :
    TRuns Q (Host.Ts.M.pure b) C := ⟨b, C, rfl, CSrv.Le.refl C, h⟩

theorem TRuns.bind {α β : Type} {P : α → CSrv → Prop} {Q : β → CSrv → Prop} {m : Host.Ts.M α}
    {f : α → Host.Ts.M β} {C : CSrv} (hl : BufSim.Lawful m) (hm : TRuns P m C)
    (hf : ∀ a C1, CSrv.Le C C1 → P a C1 → TRuns Q (f a) C1) : TRuns Q (Host.Ts.M.bind m f) C := by
  obtain ⟨a, C1, h1, hle1, hp⟩ := hm
  obtain ⟨b, C2, h2, hle2, hq⟩ := hf a C1 hle1 hp
  refine ⟨b, C2, ?_, hle1.trans hle2, hq⟩
  show interpC (m _ fun a => (f a).run) C = _
  rw [hl.2, h1, Option.bind_some]
  exact h2

theorem numBin_runs (op : NBin) {C : CSrv} {a b : NumV} (ha : Valued C a) (hb : Valued C b) :
    TRuns (fun q C' => Valued C' q) (numBin op a b) C := by
  obtain ⟨va, hva⟩ := Option.isSome_iff_exists.mp ha
  obtain ⟨vb, hvb⟩ := Option.isSome_iff_exists.mp hb
  by_cases hl : ∃ x y, a = .lit x ∧ b = .lit y
  · obtain ⟨x, y, rfl, rfl⟩ := hl
    exact TRuns.pure rfl
  · have e : (numBin op a b).run = Free.bin op a b fun i => Free.pure (.ref i) := by
      cases a <;> cases b <;> first | rfl | exact absurd ⟨_, _, rfl, rfl⟩ hl
    refine ⟨.ref C.tab.length, ⟨C.tab ++ [F64.bin op va vb]⟩, ?_, ⟨_, rfl⟩, ?_⟩
    · rw [e, interpC_bin, hva, hvb]; rfl
    · show (nth? (C.tab ++ [F64.bin op va vb]) C.tab.length).isSome = true
      rw [nth?_append_length]; rfl

theorem numTest_runs (op : NTest) {C : CSrv} {a b : NumV} (ha : Valued C a) (hb : Valued C b) :
    TRuns (fun _ _ => True) (numTest op a b) C := by
  obtain ⟨va, hva⟩ := Option.isSome_iff_exists.mp ha
  obtain ⟨vb, hvb⟩ := Option.isSome_iff_exists.mp hb
  by_cases hl : ∃ x y, a = .lit x ∧ b = .lit y
  · obtain ⟨x, y, rfl, rfl⟩ := hl
    exact TRuns.pure trivial
  · have e : (numTest op a b).run = Free.test op a b Free.pure := by
      cases a <;> cases b <;> first | rfl | exact absurd ⟨_, _, rfl, rfl⟩ hl
    refine ⟨F64.test op va vb, C, ?_, CSrv.Le.refl C, trivial⟩
    rw [e, interpC_test, hva, hvb]; rfl

theorem valued_dimOf {C : CSrv} {r : NumV} (h : Valued C r) : Valued C (dimOf r).num := by
  cases r with
  | ref i => exact h
  | lit f =>
    unfold dimOf; dsimp only
    cases F64.toInt? f <;> rfl

theorem dMul_runs {C : CSrv} {a b : Dim} (ha : Valued C a.num) (hb : Valued C b.num) :
    TRuns (fun q C' => Valued C' q.num) (Host.Mlx.Ffi.dMul a b) C := by
  by_cases hl : ∃ i j, a = .lit i ∧ b = .lit j
  · obtain ⟨i, j, rfl, rfl⟩ := hl
    exact TRuns.pure rfl
  · have e : Host.Mlx.Ffi.dMul a b = Host.Ts.M.bind (numBin .mul a.num b.num) fun r => Host.Ts.M.pure (dimOf r) := by
      cases a <;> cases b <;> first | rfl | exact absurd ⟨_, _, rfl, rfl⟩ hl
    rw [e]
    exact TRuns.bind (NativeLawful.numBin_lawful _ _ _) (numBin_runs .mul ha hb)
      fun r C1 _ hr => TRuns.pure (valued_dimOf hr)

theorem dProd_runs : ∀ {C : CSrv} {ds : List Dim}, (∀ x ∈ ds, Valued C x.num) →
    TRuns (fun q C' => Valued C' q.num) (Host.Mlx.Ffi.dProd ds) C
  | _, [], _ => TRuns.pure rfl
  | C, x :: xs, h => by
    show TRuns _ (Host.Ts.M.bind (Host.Mlx.Ffi.dProd xs) fun p => Host.Mlx.Ffi.dMul x p) C
    exact TRuns.bind (NativeLawful.dProd_l _) (dProd_runs fun z hz => h z (List.mem_cons_of_mem _ hz))
      fun p C1 hle hp => dMul_runs (Valued.le hle (h x List.mem_cons_self)) hp

theorem dLt_runs {C : CSrv} {a b : Dim} (ha : Valued C a.num) (hb : Valued C b.num) :
    TRuns (fun _ _ => True) (Host.Mlx.Ffi.dLt a b) C := by
  by_cases hl : ∃ i j, a = .lit i ∧ b = .lit j
  · obtain ⟨i, j, rfl, rfl⟩ := hl
    exact TRuns.pure trivial
  · have e : Host.Mlx.Ffi.dLt a b = numTest .lt a.num b.num := by
      cases a <;> cases b <;> first | rfl | exact absurd ⟨_, _, rfl, rfl⟩ hl
    rw [e]
    exact numTest_runs .lt ha hb

theorem reshapeRest_runs {C : CSrv} {nw gv rs : List Dim} {d : Nat} (hg : ∀ x ∈ gv, Valued C x.num)
    (hr : ∀ x ∈ rs, Valued C x.num) : TRuns (fun _ _ => True) (reshapeRest nw gv rs d) C := by
  rw [reshapeRest_eq]
  refine TRuns.bind (NativeLawful.dProd_l _) (dProd_runs hg) fun p C1 hle1 hp => ?_
  refine TRuns.bind (NativeLawful.dLt_l _ _) (dLt_runs (b := p) rfl hp) fun pos C2 hle2 _ => ?_
  cases pos
  · exact TRuns.pure trivial
  · show TRuns _ (Host.Ts.M.bind (Host.Mlx.Ffi.dProd rs) fun q => Host.Ts.M.pure (some (Out.node (fillNeg q nw) d))) C2
    exact TRuns.bind (NativeLawful.dProd_l _) (dProd_runs fun x hx => Valued.le (hle1.trans hle2) (hr x hx))
      fun _ _ _ _ => TRuns.pure trivial

theorem reshapeCancel_runs {C : CSrv} {nw gv old : List Dim} {d : Nat} (hg : ∀ x ∈ gv, Valued C x.num)
    (ho : ∀ x ∈ old, Valued C x.num) : TRuns (fun _ _ => True) (reshapeCancel nw gv old d) C := by
  unfold Host.Mlx.Ffi.SymShape.reshapeCancel
  split
  · rename_i rest hc
    exact reshapeRest_runs hg fun x hx => ho x (cancelDims_sub hc x hx)
  · exact TRuns.pure trivial

/-- A template without output against a target computation that runs. -/
theorem msim_pure_runs {α β : Type} {P : Map → SSrv → CSrv → α → β → Prop} {M : Map} {S : SSrv} {C : CSrv}
    {a : α} {m' : Host.Ts.M β} {Q : β → CSrv → Prop} (hl : BufSim.Lawful m') (hr : TRuns Q m' C)
    (hp : ∀ b C', CSrv.Le C C' → P M S C' a b) : MSim P S C (Host.Ts.M.pure a) m' := by
  obtain ⟨b, C', hb, hle, -⟩ := hr
  intro γ δ Q' k k' hk r S' hu
  obtain ⟨M2, b2, C2, h2, hq⟩ := hk M S C' a b (hp b C' hle) r S' hu
  refine ⟨M2, b2, C2, ?_, hq⟩
  rw [hl.2, hb, Option.bind_some]
  exact h2

theorem Srv.leC {M : Map} {ν : Nat → F64} {S : SSrv} {C C' : CSrv} (hs : Srv M ν S C) (hle : CSrv.Le C C') :
    Srv M ν S C' :=
  ⟨fun i e he => CSrv.Le.val hle (hs.num i e he), hs.good⟩

theorem GrowL.leC {M : Map} {ν : Nat → F64} {S : SSrv} {C C' : CSrv} (hs : Srv M ν S C) (hle : CSrv.Le C C') :
    GrowL M ν S C M S C' :=
  ⟨⟨Ext.refl _ _, Srv.leC hs hle, Nat.le_refl _⟩, hle⟩

theorem DVSs.det {M : Map} {S : SSrv} {C : CSrv} : ∀ {ds : List Dim} {ks ks' : List Nat},
    DVSs M C S ds ks → DVSs M C S ds ks' → Bd ks → Bd ks' → ks = ks'
  | [], [], [], _, _, _, _ => rfl
  | _ :: _, _ :: _, _ :: _, h, h', hb, hb' => by
    rw [Bd.cons] at hb hb'
    rw [h.1.1.det h'.1.1 (by omega) (by omega), DVSs.det h.2 h'.2 hb.2 hb'.2]
  | [], _ :: _, _, h, _, _, _ => h.elim
  | [], [], _ :: _, _, h', _, _ => h'.elim
  | _ :: _, [], _, h, _, _, _ => h.elim
  | _ :: _, _ :: _, [], _, h', _, _ => h'.elim

theorem DVSs.valued {M : Map} {S : SSrv} {C : CSrv} : ∀ {ds : List Dim} {ks : List Nat},
    DVSs M C S ds ks → Bd ks → ∀ x ∈ M.dims ds, Valued C x.num
  | [], [], _, _ => fun _ hx => by cases hx
  | d :: _, k :: _, h, hb => by
    rw [Bd.cons] at hb
    intro x hx
    rcases List.mem_cons.mp hx with rfl | hx
    · show (C.val (M.dim d).num).isSome = true
      rw [h.1.1.canon (by omega), h.1.1.num]; rfl
    · exact DVSs.valued h.2 hb.2 x hx
  | [], _ :: _, h, _ => h.elim
  | _ :: _, [], h, _ => h.elim

section
variable {ν : Nat → F64} {M : Map} {S : SSrv} {C : CSrv} (hs : Srv M ν S C)
include hs

omit hs in
theorem given_ne_neg {new : List Dim} {kg : List Nat} (hgv : DVSs M C S (givenOf new) kg) (hb : Bd kg) :
    ∀ x ∈ new, x ≠ .lit (-1) → M.dim x ≠ .lit (-1) := fun x hx hn => by
  obtain ⟨k, hk, hk31⟩ := DVSs.mem hgv hb x (List.mem_filter.mpr ⟨hx, by simp [hn]⟩)
  exact dim_ne_neg hk.1 (by omega)

omit hs in
/-- The layer's output against its image. -/
theorem reshape_out {M' : Map} {S' : SSrv} {C' : CSrv} {new : List Dim} {kg : List Nat} {v : Int} {d : Nat}
    (g : GrowL M ν S C M' S' C') (hgv : DVSs M C S (givenOf new) kg) (hb : Bd kg) :
    OutR M' S'.tab.length (some (Out.node (fillNeg (.lit v) new) d))
      (some (Out.node (fillNeg (.lit v) (M.dims new)) d)) := by
  have hgv' := (DVSs.lift g hgv).1
  have hne : ∀ x ∈ new, x ≠ .lit (-1) → M.dim x ≠ .lit (-1) ∧ M'.dim x = M.dim x := by
    intro x hx hn
    obtain ⟨k, hk, hk31⟩ := DVSs.mem hgv hb x (List.mem_filter.mpr ⟨hx, by simp [hn]⟩)
    exact ⟨dim_ne_neg hk.1 (by omega), (DVS.lift hk g).2⟩
  refine ⟨by rw [dims_fillNeg hne], ?_, ?_⟩
  · intro e he
    rcases mem_fillNeg he with rfl | ⟨hx, hn⟩
    · trivial
    · exact DVSs.sds hgv' e (List.mem_filter.mpr ⟨hx, by simp [hn]⟩)
  · intro e he
    rcases mem_fillNeg he with rfl | ⟨hx, hn⟩
    · rfl
    · exact DVSs.canon hgv' hb.lt53 e (List.mem_filter.mpr ⟨hx, by simp [hn]⟩)

/-- An equality test against the target's literal test. -/
theorem dEq_vs_pure {a b : Dim} {ka kb : Nat} (ha : DV M C a ka) (hb : DV M C b kb) (hka : ka < 2 ^ 53)
    (hkb : kb < 2 ^ 53) :
    MSim (BPost M ν S C (decide (ka = kb))) S C (Host.Mlx.Ffi.dEq a b) (Host.Ts.M.pure (decide (ka = kb))) := by
  by_cases hab : a = b
  · subst hab
    obtain rfl := ha.det hb hka hkb
    rw [Host.Mlx.Ffi.SymShape.dEq_refl]
    exact MSim.pure ⟨by simp, by simp, GrowL.refl hs⟩
  · by_cases hl : ∃ i j, a = .lit i ∧ b = .lit j
    · obtain ⟨i, j, rfl, rfl⟩ := hl
      obtain rfl := DV.lit_eq ha
      obtain rfl := DV.lit_eq hb
      have e : decide ((ka : Int) = (kb : Int)) = decide (ka = kb) :=
        decide_eq_decide.mpr ⟨fun h => by omega, fun h => by omega⟩
      show MSim _ S C (Host.Ts.M.pure (decide ((ka : Int) = (kb : Int)))) _
      rw [e]
      exact MSim.pure ⟨rfl, rfl, GrowL.refl hs⟩
    · have e1 : Host.Mlx.Ffi.dEq a b = numTest .eq a.num b.num := by
        have : Host.Mlx.Ffi.dEq a b = bif decide (a = b) then Host.Ts.M.pure true else numTest .eq a.num b.num := by
          cases a <;> cases b <;> first | rfl | exact absurd ⟨_, _, rfl, rfl⟩ hl
        rw [this, decide_eq_false hab]; rfl
      rw [e1]
      refine MSim.mono (numTest_vs_pure hs .eq a.num b.num (decide (ka = kb)) fun va vb h1 h2 => ?_)
        fun M' S' C' r r' h => ⟨h.1, ?_, h.2.1⟩
      · rw [ha.num] at h1; rw [hb.num] at h2
        simp only [Option.some.injEq] at h1 h2
        subst h1 h2
        exact test_eq_ofNat ka kb hka hkb
      · rw [h.2.2 _ _ ha.num hb.num]; exact test_eq_ofNat ka kb hka hkb

/-- The layer's output after the cut, both sides through the layer. -/
theorem reshapeRest_L1 {new rest : List Dim} {d : Nat} {kg : List Nat} {R : Nat}
    (hR : Host.Mlx.Ffi.dProd rest = Host.Ts.M.pure (.lit (R : Int)))
    (hgv : DVSs M C S (givenOf new) kg) (hb : Bd kg) (hp : ProdB kg) :
    MSim (IPost M ν S C) S C (reshapeRest new (givenOf new) rest d)
      (reshapeRest (M.dims new) (M.dims (givenOf new)) rest d) := by
  rw [reshapeRest_eq, reshapeRest_eq]
  refine MSim.bind (dProd_simV hs hgv hb.lt53 hp) fun M1 S1 C1 p p' h1 => ?_
  obtain ⟨e1, hv1, hs1, g1⟩ := h1
  subst e1
  refine MSim.bind (dLt_simV g1.grow.srv (a := .lit 0) (ka := 0) (.inl rfl) hv1 (by omega) (hp 0))
    fun M2 S2 C2 pos pos' h2 => ?_
  obtain ⟨e2, -, g2⟩ := h2
  rw [e2]
  cases pos
  · exact MSim.pure ⟨g1.trans g2, trivial⟩
  · show MSim _ S2 C2 (Host.Ts.M.bind (Host.Mlx.Ffi.dProd rest) _) (Host.Ts.M.bind (Host.Mlx.Ffi.dProd rest) _)
    rw [hR]
    exact MSim.pure ⟨g1.trans g2, reshape_out (g1.trans g2) hgv hb⟩

/-- The layer's output after the cut against the target's literal result. -/
theorem reshapeRest_L2 {new rest : List Dim} {d : Nat} {kg : List Nat} {R : Nat} {r0 : Option Out}
    (hR : Host.Mlx.Ffi.dProd rest = Host.Ts.M.pure (.lit (R : Int)))
    (hgv : DVSs M C S (givenOf new) kg) (hb : Bd kg) (hp : ProdB kg)
    (h0 : 0 < natProd kg → r0 = some (Out.node (fillNeg (.lit (R : Int)) (M.dims new)) d)) :
    MSim (IPost M ν S C) S C (reshapeRest new (givenOf new) rest d) (Host.Ts.M.pure r0) := by
  rw [reshapeRest_eq]
  show MSim _ S C _ (Host.Ts.M.bind (Host.Ts.M.pure (Dim.lit (natProd kg : Int))) fun _ =>
    Host.Ts.M.bind (Host.Ts.M.pure (decide (0 < natProd kg))) fun _ => Host.Ts.M.pure r0)
  refine MSim.bind (dProd_vs_pure hs hgv hb.lt53 hp) fun M1 S1 C1 p p' h1 => ?_
  obtain ⟨⟨-, hv1, hs1, g1⟩, -⟩ := h1
  refine MSim.bind (dLt_vs_pure g1.grow.srv hv1 (hp 0)) fun M2 S2 C2 pos pos' h2 => ?_
  obtain ⟨-, e3, g2⟩ := h2
  cases pos
  · exact MSim.pure ⟨g1.trans g2, trivial⟩
  · have hpos : 0 < natProd kg := of_decide_eq_true e3.symm
    rw [h0 hpos]
    show MSim _ S2 C2 (Host.Ts.M.bind (Host.Mlx.Ffi.dProd rest) _) _
    rw [hR]
    exact MSim.pure ⟨g1.trans g2, reshape_out (g1.trans g2) hgv hb⟩

end

section
variable {ν : Nat → F64}

/-- An `allEq` against the target's literal test. -/
theorem allEq_vs_pure : ∀ {M : Map} {S : SSrv} {C : CSrv} {xs ys : List Dim} {kxs kys : List Nat},
    Srv M ν S C → DVSs M C S xs kxs → DVSs M C S ys kys → Bd kxs → Bd kys →
    MSim (BPost M ν S C (decide (kxs = kys))) S C (Host.Mlx.Ffi.allEq xs ys) (Host.Ts.M.pure (decide (kxs = kys)))
  | _, _, _, [], [], [], [], hs, _, _, _, _ => MSim.pure ⟨rfl, rfl, GrowL.refl hs⟩
  | _, _, _, [], _ :: _, [], _ :: _, hs, _, _, _, _ => MSim.pure ⟨rfl, by simp, GrowL.refl hs⟩
  | _, _, _, _ :: _, [], _ :: _, [], hs, _, _, _, _ => MSim.pure ⟨rfl, by simp, GrowL.refl hs⟩
  | M, S, C, x :: xs, y :: ys, kx :: kxs, ky :: kys, hs, hx, hy, bx, by_ => by
    obtain ⟨hx, hxs⟩ := hx
    obtain ⟨hy, hys⟩ := hy
    rw [Bd.cons] at bx by_
    have e : (Host.Ts.M.pure (decide (kx :: kxs = ky :: kys)) : Host.Ts.M Bool) =
        Host.Ts.M.bind (Host.Ts.M.pure (decide (kx = ky))) fun e =>
          bif e then Host.Ts.M.pure (decide (kxs = kys)) else Host.Ts.M.pure false := by
      show _ = (bif decide (kx = ky) then Host.Ts.M.pure (decide (kxs = kys)) else Host.Ts.M.pure false :
        Host.Ts.M Bool)
      by_cases h : kx = ky
      · subst h; simp
      · simp [h]
    rw [e]
    show MSim _ S C (Host.Ts.M.bind (Host.Mlx.Ffi.dEq x y) fun e =>
        bif e then Host.Mlx.Ffi.allEq xs ys else Host.Ts.M.pure false) _
    refine MSim.bind (dEq_vs_pure hs hx.1 hy.1 (by omega) (by omega)) fun M1 S1 C1 e e' h => ?_
    obtain ⟨h1, h2, hg⟩ := h
    subst h1 h2
    by_cases hk : kx = ky
    · simp only [decide_eq_true hk, Bool.cond_true]
      obtain ⟨hxs', -⟩ := DVSs.lift hg hxs
      obtain ⟨hys', -⟩ := DVSs.lift hg hys
      refine MSim.mono (allEq_vs_pure hg.grow.srv hxs' hys' bx.2 by_.2) fun M2 S2 C2 r r' h => ?_
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

end

section
variable {ν : Nat → F64} {M : Map} {S : SSrv} {C : CSrv} (hs : Srv M ν S C)
include hs

/-- **Both sides through the layer**: the cut where the leading dimensions equal the given ones,
otherwise no output on the template (`hcase`: a syntactic prefix, or no multiset cancellation). -/
theorem reshape_L1 {new old : List Dim} {d : Nat} {kg kg' : List Nat} {R : Nat}
    (hg : (old ++ new).any isSym = true) (hg' : (M.dims old ++ M.dims new).any isSym = true)
    (hc : new.filter (· = .lit (-1)) = [.lit (-1)]) (hsdn : SDs (· < S.tab.length) new)
    (hrest : (old.drop (givenOf new).length).all dimLit = true)
    (hR : Host.Mlx.Ffi.dProd (old.drop (givenOf new).length) = Host.Ts.M.pure (.lit (R : Int)))
    (hgv : DVSs M C S (givenOf new) kg) (hb : Bd kg) (hp : ProdB kg)
    (hgo : DVSs M C S (old.take (givenOf new).length) kg') (hb' : Bd kg')
    (hov : ∀ x ∈ M.dims old, Valued C x.num)
    (hcase : old.take (givenOf new).length = givenOf new ∨ cancelDims old (givenOf new) = none) :
    MSim (IPost M ν S C) S C (inferSym (.reshape new) [(old, d)])
      (inferSym (M.prim (.reshape new)) ([(old, d)].map M.shp)) := by
  obtain ⟨f1, f2⟩ := filter_neg_map M (given_ne_neg hgv hb)
  have hc1 : len (new.filter (· = .lit (-1))) = 1 := by rw [hc]; rfl
  show MSim _ S C _ (inferSym (.reshape (M.dims new)) [(M.dims old, d)])
  rw [inferSym_reshapeG hg hc1, inferSym_reshapeG hg' (by rw [f1]; exact hc1), f2]
  have et : (M.dims old).take (M.dims (givenOf new)).length = M.dims (old.take (givenOf new).length) := by
    simp only [Map.dims, List.length_map, List.map_take]
  have ed : (M.dims old).drop (M.dims (givenOf new)).length = old.drop (givenOf new).length := by
    simp only [Map.dims, List.length_map, ← List.map_drop]
    exact dims_lits M hrest
  rw [et, ed]
  refine MSim.bind (allEq_simV hs hgo hgv hb' hb) fun M1 S1 C1 pre pre' h => ?_
  obtain ⟨h1, h2, g1⟩ := h
  subst h1 h2
  have edn : M1.dims new = M.dims new := (NAgree.ofExt g1.grow.ext).dims hsdn
  obtain ⟨hgv1, edg⟩ := DVSs.lift g1 hgv
  by_cases hk : kg' = kg
  · simp only [decide_eq_true hk, Bool.cond_true]
    have := reshapeRest_L1 g1.grow.srv (d := d) hR hgv1 hb hp
    rw [edn, edg] at this
    exact MSim.mono this fun M2 S2 C2 r r' h => ⟨g1.trans h.1, h.2⟩
  · simp only [decide_eq_false hk, Bool.cond_false]
    rcases hcase with he | hn
    · exact absurd (DVSs.det (he ▸ hgo) hgv hb' hb) hk
    · rw [reshapeCancel_none hn]
      have hgval : ∀ x ∈ M.dims (givenOf new), Valued C1 x.num := fun x hx =>
        Valued.le g1.le (DVSs.valued hgv hb x hx)
      refine msim_pure_runs (M := M1) (reshapeCancel_l _ _ _ _)
        (reshapeCancel_runs hgval fun x hx => Valued.le g1.le (hov x hx)) fun b C' hle => ?_
      exact ⟨g1.trans (GrowL.leC g1.grow.srv hle), trivial⟩

/-- **The template through the layer, the target's literal result.** -/
theorem reshape_L2 {new old : List Dim} {d : Nat} {kg kg' : List Nat} {R : Nat} {r0 : Option Out}
    (hg : (old ++ new).any isSym = true) (hc : new.filter (· = .lit (-1)) = [.lit (-1)])
    (hsdn : SDs (· < S.tab.length) new)
    (hR : Host.Mlx.Ffi.dProd (old.drop (givenOf new).length) = Host.Ts.M.pure (.lit (R : Int)))
    (hgv : DVSs M C S (givenOf new) kg) (hb : Bd kg) (hp : ProdB kg)
    (hgo : DVSs M C S (old.take (givenOf new).length) kg') (hb' : Bd kg')
    (hcase : old.take (givenOf new).length = givenOf new ∨ cancelDims old (givenOf new) = none)
    (h0 : 0 < natProd kg → kg' = kg → r0 = some (Out.node (fillNeg (.lit (R : Int)) (M.dims new)) d)) :
    MSim (IPost M ν S C) S C (inferSym (.reshape new) [(old, d)]) (Host.Ts.M.pure r0) := by
  have hc1 : len (new.filter (· = .lit (-1))) = 1 := by rw [hc]; rfl
  rw [inferSym_reshapeG hg hc1]
  show MSim _ S C _ (Host.Ts.M.bind (Host.Ts.M.pure (decide (kg' = kg))) fun _ => Host.Ts.M.pure r0)
  refine MSim.bind (allEq_vs_pure hs hgo hgv hb' hb) fun M1 S1 C1 pre pre' h => ?_
  obtain ⟨h1, h2, g1⟩ := h
  subst h1 h2
  by_cases hk : kg' = kg
  · simp only [decide_eq_true hk, Bool.cond_true]
    have edn : M1.dims new = M.dims new := (NAgree.ofExt g1.grow.ext).dims hsdn
    obtain ⟨hgv1, -⟩ := DVSs.lift g1 hgv
    refine MSim.mono (reshapeRest_L2 g1.grow.srv hR hgv1 hb hp fun hq => by rw [edn]; exact h0 hq hk)
      fun M2 S2 C2 r r' h => ⟨g1.trans h.1, h.2⟩
  · simp only [decide_eq_false hk, Bool.cond_false]
    rcases hcase with he | hn
    · exact absurd (DVSs.det (he ▸ hgo) hgv hb' hb) hk
    · rw [reshapeCancel_none hn]
      exact MSim.pure ⟨g1, trivial⟩

end

/-! ## Continuations -/

/-- `opOut`'s continuation after inference. -/
def opK (s : NSt) (b off sl : Nat) (p : Prim) (ins : List Nat) : Option Out → Host.Mlx.Ffi.R
  | some (.node shape dt) =>
    let (n, s) := s.addNode ⟨p, ins, shape, dt⟩
    let (h, s) := s.setArr sl n
    Host.Mlx.Ffi.okW s Host.Mlx.Ffi.status0 [Host.Mlx.Ffi.u64Write b off h]
  | some (.same i) => match nth? ins i with
    | some n => let (h, s) := s.setArr sl n; Host.Mlx.Ffi.okW s Host.Mlx.Ffi.status0 [Host.Mlx.Ffi.u64Write b off h]
    | none => Host.Mlx.Ffi.stuck
  | none => Host.Mlx.Ffi.stuck

/-- `opOutSym`'s continuation after inference. -/
def opKS (s : NSt) (b off sl : Nat) (p : Prim) (ins : List Nat) : Option Out → Host.Mlx.Ffi.R
  | some (.node shape dt) =>
    let (n, s) := s.addNode ⟨p, ins, shape, dt⟩
    let (h, s) := s.setArr sl n
    Host.Mlx.Ffi.okW s Host.Mlx.Ffi.status0 [Host.Mlx.Ffi.u64Write b off h]
  | _ => Host.Mlx.Ffi.stuck

/-- `callSym`'s continuation after the model's call. -/
def symK2 (s : NSt) (name : Name) (args : List Arg) :
    Option (NSt × Ret × List (Nat × Nat × List Byte)) → Host.Mlx.Ffi.R
  | some r => Host.Ts.M.pure (some r)
  | none => symShapeCall s name args

theorem mbind_assoc {α β γ : Type} (m : Host.Ts.M α) (f : α → Host.Ts.M β) (g : β → Host.Ts.M γ) :
    Host.Ts.M.bind (Host.Ts.M.bind m f) g = Host.Ts.M.bind m fun a => Host.Ts.M.bind (f a) g := rfl

theorem mbind_pure {α β : Type} (a : α) (f : α → Host.Ts.M β) : Host.Ts.M.bind (Host.Ts.M.pure a) f = f a := rfl

theorem callSym_eqK (s : NSt) (name : Name) (args : List Arg) :
    callSym s name args = Host.Ts.M.bind (Host.Mlx.Ffi.call s name args) (symK2 s name args) := by
  unfold callSym
  congr 1

theorem opOut_eqK {s : NSt} {o : Arg} {p : Prim} {ins : List Nat} {sh : List (List Dim × Nat)} {b off sl : Nat}
    (h1 : Host.Mlx.Ffi.slotOf o = some (b, off, sl)) (h2 : Host.Mlx.Ffi.shapesOf s ins = some sh) :
    Host.Mlx.Ffi.opOut s o p ins = Host.Ts.M.bind (Host.Mlx.Ffi.infer p sh) (opK s b off sl p ins) := by
  unfold Host.Mlx.Ffi.opOut
  rw [h1, h2]
  dsimp only
  congr 1

theorem opOutSym_eqK {s : NSt} {o : Arg} {p : Prim} {ins : List Nat} {sh : List (List Dim × Nat)} {b off sl : Nat}
    (h1 : Host.Mlx.Ffi.slotOf o = some (b, off, sl)) (h2 : Host.Mlx.Ffi.shapesOf s ins = some sh) :
    opOutSym s o p ins = Host.Ts.M.bind (inferSym p sh) (opKS s b off sl p ins) := by
  unfold opOutSym
  rw [h1, h2]
  dsimp only
  congr 1

/-- The continuation of the model's reshape through the layer. -/
def CK (s : NSt) (b off sl : Nat) (p : Prim) (ins : List Nat) (name : Name) (args : List Arg) (d : Nat) :
    Option (List Dim) → Host.Mlx.Ffi.R :=
  fun r => Host.Ts.M.bind (opK s b off sl p ins (r.map (Out.node · d))) (symK2 s name args)

theorem opK_none (s : NSt) (b off sl : Nat) (p : Prim) (ins : List Nat) :
    opK s b off sl p ins none = Host.Mlx.Ffi.stuck := rfl

theorem bind_stuck {β : Type} (f : Option (NSt × Ret × List (Nat × Nat × List Byte)) → Host.Ts.M β) :
    Host.Ts.M.bind (Host.Mlx.Ffi.stuck : Host.Mlx.Ffi.R) f = f none := rfl

theorem symK2_none (s : NSt) (name : Name) (args : List Arg) : symK2 s name args none = symShapeCall s name args :=
  rfl

theorem CK_none (s : NSt) (b off sl : Nat) (p : Prim) (ins : List Nat) (name : Name) (args : List Arg) (d : Nat) :
    CK s b off sl p ins name args d none = symShapeCall s name args := by
  unfold CK
  rw [Option.map_none, opK_none, bind_stuck, symK2_none]

theorem CK_some (s : NSt) (b off sl : Nat) (p : Prim) (ins : List Nat) (name : Name) (args : List Arg) (d : Nat)
    (shape : List Dim) :
    CK s b off sl p ins name args d (some shape) = opK s b off sl p ins (some (.node shape d)) := by
  unfold CK
  rw [Option.map_some]
  rfl

section
variable {P : LoadP} {NB : Nat} {M : Map} {ν : Nat → F64} {S : SSrv} {C : CSrv} {x y : NSt}
  (hr : MR P NB M S.tab.length x y)
include hr

/-- After the layer's inference at both sides. -/
theorem sim_outSS {b off sl : Nat} {p : Prim} {ins : List Nat} (hsl : sl = 0 ∨ PH x sl)
    (hE : x.next + 1 ≤ P.E) (hNE : x.nnext + 1 ≤ P.NE) (hp : SP (· < S.tab.length) p)
    {T T' : Host.Ts.M (Option Out)} (hinf : MSim (IPost M ν S C) S C T T') :
    MSim (MPost P NB M ν S C) S C (Host.Ts.M.bind T (opKS x b off sl p ins))
      (Host.Ts.M.bind T' (opKS y (M.a b) off (M.handle sl) (M.prim p) (ins.map M.node))) := by
  refine MSim.bind hinf fun M1 S1 C1 r r' h => ?_
  obtain ⟨g1, hout⟩ := h
  have hs1 := g1.grow.srv
  have hr1 : MR P NB M1 S1.tab.length x y := hr.grow g1.grow
  have ea : M1.a = M.a := g1.grow.ext.a
  have en : M1.node = M.node := g1.grow.ext.node
  have eh : M1.handle sl = M.handle sl := by simp only [Map.handle, g1.grow.ext.big]
  have ep : M1.prim p = M.prim p := (NAgree.ofExt g1.grow.ext).prim hp
  have hp1 : SP (· < S1.tab.length) p := SP.mono (fun i hi => Nat.lt_of_lt_of_le hi g1.grow.len) hp
  refine MSim.mono (P := MPost P NB M1 ν S1 C1) ?_ fun M' S' C' r r' h => ⟨g1.grow.trans h.1, h.2⟩
  rcases r with _ | ⟨shape, dt⟩ | i
  · refine msim_stuck hs1 _ ?_
    rcases r' with _ | ⟨_ | _⟩ <;> exact ⟨_, fun _ _ => rfl⟩
  · rcases r' with _ | o'
    · exact hout.elim
    · obtain ⟨rfl, hsd, hc⟩ := hout
      rw [← ep, ← en, ← eh, ← ea]
      exact sim_nodeS hs1 hr1 hsl (fun _ => hE) hNE p ins shape dt hp1 hsd hc
  · refine msim_stuck hs1 _ ?_
    rcases r' with _ | ⟨_ | _⟩ <;> exact ⟨_, fun _ _ => rfl⟩

/-- After the layer's inference at the template and the model's at the target. -/
theorem sim_outSO {b off sl : Nat} {p : Prim} {ins : List Nat} (hsl : sl = 0 ∨ PH x sl)
    (hE : x.next + 1 ≤ P.E) (hNE : x.nnext + 1 ≤ P.NE) (hp : SP (· < S.tab.length) p)
    {T T' : Host.Ts.M (Option Out)} (hinf : MSim (IPost M ν S C) S C T T') :
    MSim (MPost P NB M ν S C) S C (Host.Ts.M.bind T (opKS x b off sl p ins))
      (Host.Ts.M.bind T' (opK y (M.a b) off (M.handle sl) (M.prim p) (ins.map M.node))) := by
  refine MSim.bind hinf fun M1 S1 C1 r r' h => ?_
  obtain ⟨g1, hout⟩ := h
  have hs1 := g1.grow.srv
  have hr1 : MR P NB M1 S1.tab.length x y := hr.grow g1.grow
  have ea : M1.a = M.a := g1.grow.ext.a
  have en : M1.node = M.node := g1.grow.ext.node
  have eh : M1.handle sl = M.handle sl := by simp only [Map.handle, g1.grow.ext.big]
  have ep : M1.prim p = M.prim p := (NAgree.ofExt g1.grow.ext).prim hp
  have hp1 : SP (· < S1.tab.length) p := SP.mono (fun i hi => Nat.lt_of_lt_of_le hi g1.grow.len) hp
  refine MSim.mono (P := MPost P NB M1 ν S1 C1) ?_ fun M' S' C' r r' h => ⟨g1.grow.trans h.1, h.2⟩
  rcases r with _ | ⟨shape, dt⟩ | i
  · refine msim_stuck hs1 _ ?_
    rcases r' with _ | ⟨_ | _⟩
    · exact ⟨_, fun _ _ => rfl⟩
    · exact ⟨_, fun _ _ => rfl⟩
    · rename_i i
      show ∃ q, ∀ γ k, (match nth? (List.map M.node ins) i with
        | some n => let (h, s) := y.setArr (M.handle sl) n
          Host.Mlx.Ffi.okW s Host.Mlx.Ffi.status0 [Host.Mlx.Ffi.u64Write (M.a b) off h]
        | none => Host.Mlx.Ffi.stuck : Host.Mlx.Ffi.R) γ k = k q
      cases nth? (List.map M.node ins) i
      · exact ⟨_, fun _ _ => rfl⟩
      · exact ⟨_, fun _ _ => rfl⟩
  · rcases r' with _ | o'
    · exact hout.elim
    · obtain ⟨rfl, hsd, hc⟩ := hout
      rw [← ep, ← en, ← eh, ← ea]
      exact sim_nodeS hs1 hr1 hsl (fun _ => hE) hNE p ins shape dt hp1 hsd hc
  · refine msim_stuck hs1 _ ?_
    rcases r' with _ | ⟨_ | _⟩
    · exact ⟨_, fun _ _ => rfl⟩
    · exact ⟨_, fun _ _ => rfl⟩
    · rename_i i
      show ∃ q, ∀ γ k, (match nth? (List.map M.node ins) i with
        | some n => let (h, s) := y.setArr (M.handle sl) n
          Host.Mlx.Ffi.okW s Host.Mlx.Ffi.status0 [Host.Mlx.Ffi.u64Write (M.a b) off h]
        | none => Host.Mlx.Ffi.stuck : Host.Mlx.Ffi.R) γ k = k q
      cases nth? (List.map M.node ins) i
      · exact ⟨_, fun _ _ => rfl⟩
      · exact ⟨_, fun _ _ => rfl⟩

end

/-! ## The model's reshape -/

/-- The model's reshape with `-1` after its two products. -/
def rsLit (new : List Dim) (total p : Dim) : Host.Ts.M (Option (List Dim)) :=
  match total, p with
  | .lit t, .lit q => bif decide (q ≠ 0 ∧ t % q = 0) then Host.Ts.M.pure (some (fillNeg (.lit (t / q)) new))
    else Host.Ts.M.pure none
  | _, _ => Host.Ts.M.pure none

theorem infer_reshape_bind {new old : List Dim} {d : Nat} {β : Type} (hc : new.filter (· = .lit (-1)) = [.lit (-1)])
    (K : Option Out → Host.Ts.M β) :
    Host.Ts.M.bind (Host.Mlx.Ffi.infer (.reshape new) [(old, d)]) K =
      Host.Ts.M.bind (Host.Mlx.Ffi.dProd old) fun total =>
        Host.Ts.M.bind (Host.Mlx.Ffi.dProd (new.filter (· ≠ .lit (-1)))) fun p =>
          Host.Ts.M.bind (rsLit new total p) fun r => K (r.map (Out.node · d)) := by
  show Host.Ts.M.bind (Host.Ts.M.bind (Host.Mlx.Ffi.reshapeShape old new) fun r =>
    Host.Ts.M.pure (r.map (Out.node · d))) K = _
  unfold Host.Mlx.Ffi.reshapeShape
  rw [hc]
  rfl

theorem rsLit_pos (new : List Dim) {t q : Int} (hq : q ≠ 0) (ht : t % q = 0) :
    rsLit new (.lit t) (.lit q) = Host.Ts.M.pure (some (fillNeg (.lit (t / q)) new)) := by
  unfold rsLit
  dsimp only
  rw [decide_eq_true ⟨hq, ht⟩]
  rfl

theorem rsLit_zero (new : List Dim) (t : Int) : rsLit new (.lit t) (.lit 0) = Host.Ts.M.pure none := by
  unfold rsLit
  dsimp only
  rw [decide_eq_false (by simp)]
  rfl

theorem rsLit_not (new : List Dim) {t q : Int} (h : ¬ (q ≠ 0 ∧ t % q = 0)) :
    rsLit new (.lit t) (.lit q) = Host.Ts.M.pure none := by
  unfold rsLit
  dsimp only
  rw [decide_eq_false h]
  rfl

theorem rsLit_none (new : List Dim) {total p : Dim} (h : ¬ ∃ t q, total = .lit t ∧ p = .lit q) :
    rsLit new total p = Host.Ts.M.pure none := by
  cases total <;> cases p <;> first | rfl | exact absurd ⟨_, _, rfl, rfl⟩ h

theorem reshape_decode (s : NSt) {name : Name} (hsym : Host.Mlx.Ffi.symOf name = some .reshape)
    {o a sh n e : Arg} {ins : List Nat} {new : List Dim} (h1 : Host.Mlx.Ffi.arrIns s [a] = some ins)
    (h2 : Host.Mlx.Ffi.dimsArg sh n = some new) :
    Host.Mlx.Ffi.call s name [o, a, sh, n, e] = Host.Mlx.Ffi.opOut s o (.reshape new) ins ∧
      symShapeCall s name [o, a, sh, n, e] = opOutSym s o (.reshape new) ins := by
  constructor
  · unfold Host.Mlx.Ffi.call; rw [hsym]; simp only [h1, h2]
  · unfold symShapeCall; rw [hsym]; simp only [h1, h2]

/-! ## The call -/

theorem lits_of_noSym : ∀ {ds : List Dim}, (∀ z ∈ ds, isSym z = false) → ds.all dimLit = true
  | [], _ => rfl
  | z :: zs, h => by
    simp only [List.all_cons, Bool.and_eq_true]
    refine ⟨?_, lits_of_noSym fun z' hz => h z' (List.mem_cons_of_mem _ hz)⟩
    have := h z List.mem_cons_self
    cases z
    · rfl
    · cases this

section
variable {P : LoadP} {NB : Nat} {M : Map} {ν : Nat → F64} {S : SSrv} {C : CSrv} {x y : NSt} {name : Name}
  (hs : Srv M ν S C) (hr : MR P NB M S.tab.length x y)
include hs hr

/-- **A reshape with `-1` over symbolic dimensions**: the layer's completed calls simulate. The
input's leading dimensions are the given ones syntactically, or they do not cancel as a multiset
(`hcase`); the rest is literal. -/
theorem sim_reshapeNeg (hsym : Host.Mlx.Ffi.symOf name = some .reshape) {o a sh nA e : Arg} {ins : List Nat}
    {new old : List Dim} {d : Nat}
    (ha : hdOk x a = true) (hd : dimsOk P sh nA = true) (ho : slotOk P x o = true) (hE : x.next + 1 ≤ P.E)
    (hNE : x.nnext + 1 ≤ P.NE) (h1 : Host.Mlx.Ffi.arrIns x [a] = some ins)
    (h2 : Host.Mlx.Ffi.dimsArg sh nA = some new) (hsh : Host.Mlx.Ffi.shapesOf x ins = some [(old, d)])
    (hc : new.filter (· = .lit (-1)) = [.lit (-1)]) (hg : (old ++ new).any isSym = true)
    (hcase : old.take (givenOf new).length = givenOf new ∨ cancelDims old (givenOf new) = none)
    (hrest : (old.drop (givenOf new).length).all dimLit = true)
    (vo : old.all dimOkV = true) (vg : (givenOf new).all dimOkV = true)
    (po : prodBnd old < 2 ^ 53) (pg : prodBnd (givenOf new) < 2 ^ 53)
    (hsm : ∀ j ∈ shRefs x ins, RefSmall ν S j) (hsg : ∀ j ∈ dimsArgRefs sh nA, RefSmall ν S j) :
    MSim (MPost P NB M ν S C) S C (callSym x name [o, a, sh, nA, e])
      (callSym y name ([o, a, sh, nA, e].map M.arg)) := by
  -- the values
  obtain ⟨ko, hko, bko⟩ := dvss_sh hs hr hsh List.mem_cons_self vo hsm
  have pko := hko.prodB bko po
  have hko' : DVSs M C S (old.take (givenOf new).length ++ old.drop (givenOf new).length) ko := by
    rw [List.take_append_drop]; exact hko
  obtain ⟨kg', kr, rfl, hkg', hkr⟩ := DVSs.split hko'
  have bkg' : Bd kg' := fun k hk => bko k (List.mem_append_left _ hk)
  have bkr : Bd kr := fun k hk => bko k (List.mem_append_right _ hk)
  obtain ⟨kg, hkg, bkg⟩ := dvss_of hs vg fun j hj => hsg j (by
    unfold dimsArgRefs; rw [h2]
    obtain ⟨z, hz, hjz⟩ := List.mem_flatMap.mp hj
    exact List.mem_flatMap.mpr ⟨z, (List.mem_filter.mp hz).1, hjz⟩)
  have pkg : ProdB kg := hkg.prodB bkg pg
  have hR : Host.Mlx.Ffi.dProd (old.drop (givenOf new).length) = Host.Ts.M.pure (.lit (natProd kr : Int)) := by
    have := dProd_lits (M := M) hkr bkr.lt53 (by rw [dims_lits M hrest]; exact hrest)
    rwa [dims_lits M hrest] at this
  have ht53 : natProd (kg' ++ kr) < 2 ^ 53 := pko 0
  have hq53 : natProd kg < 2 ^ 53 := pkg 0
  have hdiv : kg' = kg → natProd (kg' ++ kr) = natProd kg * natProd kr := fun e => by
    rw [e]; exact natProd_append kg kr
  -- a literal division of the two products exists only where the cut's values agree or fail
  have hnot : ¬ ((natProd kg : Int) ≠ 0 ∧ (natProd (kg' ++ kr) : Int) % (natProd kg : Int) = 0) →
      natProd kg = 0 ∨ kg' ≠ kg := fun hn => by
    by_cases hq : natProd kg = 0
    · exact .inl hq
    · refine .inr fun he => hn ⟨by exact_mod_cast hq, ?_⟩
      rw [hdiv he]; push_cast; exact Int.mul_emod_right _ _
  -- decoding
  have t1 := hr.arrIns_some (as := [a]) (by simp [ha]) h1
  have t2 := hr.dimsArg_map hd h2
  simp only [List.map_cons, List.map_nil] at t1 ⊢
  obtain ⟨b, off, sl, s1, s2, hsl⟩ := hr.slot_map ho
  have hsy : Host.Mlx.Ffi.shapesOf y (ins.map M.node) = some [(M.dims old, d)] := hr.shapesOf_map hsh
  obtain ⟨cx, dxs⟩ := reshape_decode x hsym (o := o) (e := e) h1 h2
  obtain ⟨cy, dys⟩ := reshape_decode y hsym (o := M.arg o) (e := M.arg e) t1 t2
  have hne := given_ne_neg hkg bkg
  obtain ⟨f1, f2⟩ := filter_neg_map M hne
  have lx : symShapeCall x name [o, a, sh, nA, e] =
      Host.Ts.M.bind (inferSym (.reshape new) [(old, d)]) (opKS x b off sl (.reshape new) ins) := by
    rw [dxs, opOutSym_eqK s1 hsh]
  have ly : symShapeCall y name [M.arg o, M.arg a, M.arg sh, M.arg nA, M.arg e] =
      Host.Ts.M.bind (inferSym (.reshape (M.dims new)) [(M.dims old, d)])
        (opKS y (M.a b) off (M.handle sl) (.reshape (M.dims new)) (ins.map M.node)) := by
    rw [dys, opOutSym_eqK s2 hsy]
  -- the programs: two products, then the model's or the layer's reshape
  rw [callSym_eqK, cx, opOut_eqK s1 hsh, mbind_assoc, infer_reshape_bind hc,
    callSym_eqK, cy, opOut_eqK s2 hsy, mbind_assoc, infer_reshape_bind (by rw [f1]; exact hc), f2]
  show MSim _ S C
    (Host.Ts.M.bind (Host.Mlx.Ffi.dProd old) fun total =>
      Host.Ts.M.bind (Host.Mlx.Ffi.dProd (givenOf new)) fun pp =>
        Host.Ts.M.bind (rsLit new total pp) (CK x b off sl (.reshape new) ins name [o, a, sh, nA, e] d))
    (Host.Ts.M.bind (Host.Mlx.Ffi.dProd (M.dims old)) fun total =>
      Host.Ts.M.bind (Host.Mlx.Ffi.dProd (M.dims (givenOf new))) fun pp =>
        Host.Ts.M.bind (rsLit (M.dims new) total pp)
          (CK y (M.a b) off (M.handle sl) (.reshape (M.dims new)) (ins.map M.node) name
            [M.arg o, M.arg a, M.arg sh, M.arg nA, M.arg e] d))
  refine MSim.bind (dProd_simVF hs hko bko.lt53 pko) fun M1 S1 C1 total total' h1 => ?_
  obtain ⟨⟨e1, hv1, hs1, g1⟩, hl1⟩ := h1
  obtain ⟨hkg1, em1⟩ := DVSs.lift g1 hkg
  rw [← em1]
  refine MSim.bind (dProd_simVF g1.grow.srv hkg1 bkg.lt53 pkg) fun M2 S2 C2 pp pp' h2 => ?_
  obtain ⟨⟨e2, hv2, hs2, g2⟩, hl2⟩ := h2
  subst e1 e2
  -- at the end of the products
  have g12 := g1.trans g2
  have hs2' := g2.grow.srv
  have hr2 : MR P NB M2 S2.tab.length x y := hr.grow g12.grow
  have ea : M2.a = M.a := g12.grow.ext.a
  have en : M2.node = M.node := g12.grow.ext.node
  have eh : M2.handle sl = M.handle sl := by simp only [Map.handle, g12.grow.ext.big]
  have hsdn : SDs (· < S.tab.length) new := fun z hz => by
    by_cases hzn : z = .lit (-1)
    · subst hzn; trivial
    · exact hkg.sds z (List.mem_filter.mpr ⟨hz, by simp [hzn]⟩)
  have hsdo : SDs (· < S.tab.length) old := fun z hz => (hr.shapesOf_props hsh _ List.mem_cons_self).1 z hz
  have ednew : M2.dims new = M.dims new := (NAgree.ofExt g12.grow.ext).dims hsdn
  have edold : M2.dims old = M.dims old := (NAgree.ofExt g12.grow.ext).dims hsdo
  have hkg2 := (DVSs.lift g12 hkg).1
  have hkg'2 := (DVSs.lift g12 hkg').1
  have hp2 : SP (· < S2.tab.length) (Prim.reshape new) :=
    SDs.mono (fun i hi => Nat.lt_of_lt_of_le hi g12.grow.len) hsdn
  have hov : ∀ z ∈ M2.dims old, Valued C2 z.num := by
    rw [edold]
    intro z hz
    exact Valued.le g12.le (DVSs.valued hko bko z hz)
  have ep : M2.prim (Prim.reshape new) = Prim.reshape (M.dims new) := by
    show Prim.reshape (M2.dims new) = _; rw [ednew]
  have SS : ∀ {T T' : Host.Ts.M (Option Out)}, MSim (IPost M2 ν S2 C2) S2 C2 T T' →
      MSim (MPost P NB M2 ν S2 C2) S2 C2 (Host.Ts.M.bind T (opKS x b off sl (.reshape new) ins))
        (Host.Ts.M.bind T' (opKS y (M.a b) off (M.handle sl) (.reshape (M.dims new)) (ins.map M.node))) := by
    intro T T' hinf
    have := sim_outSS hr2 (ν := ν) (C := C2) (b := b) (off := off) (ins := ins) hsl hE hNE hp2 hinf
    rw [ea, eh, en, ep] at this
    exact this
  have SO : ∀ {T T' : Host.Ts.M (Option Out)}, MSim (IPost M2 ν S2 C2) S2 C2 T T' →
      MSim (MPost P NB M2 ν S2 C2) S2 C2 (Host.Ts.M.bind T (opKS x b off sl (.reshape new) ins))
        (Host.Ts.M.bind T' (opK y (M.a b) off (M.handle sl) (.reshape (M.dims new)) (ins.map M.node))) := by
    intro T T' hinf
    have := sim_outSO hr2 (ν := ν) (C := C2) (b := b) (off := off) (ins := ins) hsl hE hNE hp2 hinf
    rw [ea, eh, en, ep] at this
    exact this
  refine MSim.mono (P := MPost P NB M2 ν S2 C2) ?_ fun M' S' C' r r' h => ⟨g12.grow.trans h.1, h.2⟩
  -- both through the layer
  have BL : ((M.dims old ++ M.dims new).any isSym = true ∨ natProd kg = 0 ∨ kg' ≠ kg) →
      MSim (MPost P NB M2 ν S2 C2) S2 C2 (CK x b off sl (.reshape new) ins name [o, a, sh, nA, e] d none)
        (CK y (M.a b) off (M.handle sl) (.reshape (M.dims new)) (ins.map M.node) name
          [M.arg o, M.arg a, M.arg sh, M.arg nA, M.arg e] d none) := by
    intro hor
    rw [CK_none, CK_none, lx, ly]
    refine SS ?_
    by_cases hg' : (M.dims old ++ M.dims new).any isSym = true
    · have := reshape_L1 hs2' (d := d) hg (by rw [edold, ednew]; exact hg') hc hp2 hrest hR hkg2 bkg pkg
        hkg'2 bkg' hov hcase
      rw [show M2.prim (Prim.reshape new) = Prim.reshape (M.dims new) from ep] at this
      exact (by simpa only [List.map_cons, List.map_nil, Map.shp, edold] using this)
    · rw [inferSym_reshape_lit (new := M.dims new) (old := M.dims old) (d := d) (Bool.eq_false_iff.mpr hg')]
      exact reshape_L2 hs2' hg hc hp2 hR hkg2 bkg pkg hkg'2 bkg' hcase fun h he =>
        ((hor.resolve_left hg').elim (fun h0 => absurd h0 (by omega)) (fun h0 => absurd he h0))
  -- the template through the layer, the target through the model
  have SN : (natProd kg : Int) ≠ 0 → (natProd (kg' ++ kr) : Int) % (natProd kg : Int) = 0 →
      MSim (MPost P NB M2 ν S2 C2) S2 C2 (CK x b off sl (.reshape new) ins name [o, a, sh, nA, e] d none)
        (CK y (M.a b) off (M.handle sl) (.reshape (M.dims new)) (ins.map M.node) name
          [M.arg o, M.arg a, M.arg sh, M.arg nA, M.arg e] d
          (some (fillNeg (.lit ((natProd (kg' ++ kr) : Int) / (natProd kg : Int))) (M.dims new)))) := by
    intro hq _
    rw [CK_none, lx, CK_some]
    show MSim _ S2 C2 _ (Host.Ts.M.bind (Host.Ts.M.pure (some (Out.node (fillNeg
      (.lit ((natProd (kg' ++ kr) : Int) / (natProd kg : Int))) (M.dims new)) d)))
      (opK y (M.a b) off (M.handle sl) (.reshape (M.dims new)) (ins.map M.node)))
    refine SO (reshape_L2 hs2' hg hc hp2 hR hkg2 bkg pkg hkg'2 bkg' hcase fun _ he => ?_)
    have e : ((natProd (kg' ++ kr) : Nat) : Int) / ((natProd kg : Nat) : Int) = ((natProd kr : Nat) : Int) := by
      rw [hdiv he]; push_cast; exact Int.mul_ediv_cancel_left _ hq
    rw [e, ednew]
  by_cases hsl2 : ∃ t0 q0, total = .lit t0 ∧ pp = .lit q0
  · -- both through the model (the template's products literal)
    obtain ⟨t0, q0, rfl, rfl⟩ := hsl2
    obtain rfl := DV.lit_eq hv1
    obtain rfl := DV.lit_eq hv2
    show MSim _ S2 C2 (Host.Ts.M.bind (rsLit new (.lit _) (.lit _)) _)
      (Host.Ts.M.bind (rsLit (M.dims new) (.lit _) (.lit _)) _)
    by_cases hok : (natProd kg : Int) ≠ 0 ∧ (natProd (kg' ++ kr) : Int) % (natProd kg : Int) = 0
    · rw [rsLit_pos _ hok.1 hok.2, rsLit_pos _ hok.1 hok.2]
      show MSim _ S2 C2 (CK x b off sl (.reshape new) ins name [o, a, sh, nA, e] d (some _))
        (CK y (M.a b) off (M.handle sl) (.reshape (M.dims new)) (ins.map M.node) name
          [M.arg o, M.arg a, M.arg sh, M.arg nA, M.arg e] d (some _))
      rw [CK_some, CK_some]
      obtain ⟨heq, hsd, hcan⟩ := reshape_out (v := (natProd (kg' ++ kr) : Int) / (natProd kg : Int)) (d := d) g12 hkg bkg
      have hnode := sim_nodeS hs2' hr2 (b := b) (off := off) hsl (fun _ => hE) hNE (.reshape new) ins _ d hp2 hsd hcan
      rw [ea, eh, en, ep, ← (Out.node.inj heq).1] at hnode
      exact hnode
    · rw [rsLit_not _ hok, rsLit_not _ hok, mbind_pure, mbind_pure]
      exact BL (.inr (hnot hok))
  · rw [rsLit_none new hsl2]
    by_cases htl : ∃ t1 q1, M1.dim total = .lit t1 ∧ M2.dim pp = .lit q1
    · -- the template through the layer, the target through the model
      obtain ⟨t1, q1, et, eq⟩ := htl
      have et' : t1 = ((natProd (kg' ++ kr) : Nat) : Int) := by
        rcases hv1.dim ht53 with e | ⟨j, e, -⟩ <;> rw [e] at et
        · exact (Dim.lit.inj et).symm
        · cases et
      have eq' : q1 = ((natProd kg : Nat) : Int) := by
        rcases hv2.dim hq53 with e | ⟨j, e, -⟩ <;> rw [e] at eq
        · exact (Dim.lit.inj eq).symm
        · cases eq
      rw [et, eq, et', eq']
      by_cases hok : (natProd kg : Int) ≠ 0 ∧ (natProd (kg' ++ kr) : Int) % (natProd kg : Int) = 0
      · rw [rsLit_pos _ hok.1 hok.2, mbind_pure, mbind_pure]
        exact SN hok.1 hok.2
      · rw [rsLit_not _ hok, mbind_pure, mbind_pure]
        exact BL (.inr (hnot hok))
    · -- both through the layer
      rw [rsLit_none (M.dims new) htl, mbind_pure, mbind_pure]
      refine BL (.inl ?_)
      match hgv : (M.dims old ++ M.dims new).any isSym with
      | true => rfl
      | false =>
        exfalso
        apply htl
        have hns : ∀ z ∈ M.dims old ++ M.dims new, isSym z = false := fun z hz => by
          cases h : isSym z
          · rfl
          · rw [List.any_eq_true.mpr ⟨z, hz, h⟩] at hgv; cases hgv
        have lo : (M.dims old).all dimLit = true := lits_of_noSym fun z hz => hns z (List.mem_append_left _ hz)
        have lg : (M1.dims (givenOf new)).all dimLit = true := by
          rw [em1]
          refine lits_of_noSym fun z hz => hns z (List.mem_append_right _ ?_)
          obtain ⟨z', hz', rfl⟩ := List.mem_map.mp hz
          exact List.mem_map.mpr ⟨z', (List.mem_filter.mp hz').1, rfl⟩
        exact ⟨_, _, hl1 lo, hl2 lg⟩

end

end Host.Ts.Sim.G
