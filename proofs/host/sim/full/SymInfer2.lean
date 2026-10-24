import host.sim.full.SymInfer
namespace Host.Ts.Sim
open Host.Mlx.Ffi (Dim Prim Node Out dimOf)

/-! # Shape inference over symbolic shapes: checks, broadcasts and reshapes

* normalization with a weight (`infer_rms2_simS`) and quantized matmul (`infer_qmm_simS`): the
  checked dimensions (the last input dimension, the weights' dimensions, scales and biases) are
  literal, so both sides decide the checks alike and keep the other dimensions;
* broadcasting binary operations (`infer_binary_simV`);
* reshapes without `-1` (`infer_reshape_simV`): the products of the old and new dimensions are
  compared by value. -/

section
variable {ν : Nat → F64}

theorem PureP.eq {α : Type} {m : Host.Ts.M α} {Q : α → Prop} (h : PureP m Q) : ∃ a, Q a ∧ m = Host.Ts.M.pure a := by
  obtain ⟨a, ha, e⟩ := h
  exact ⟨a, ha, by funext γ k; exact e γ k⟩

theorem dEq_lit (a b : Int) : Host.Mlx.Ffi.dEq (.lit a) (.lit b) = Host.Ts.M.pure (decide (a = b)) := rfl

theorem dimLit_eq {d : Dim} (h : dimLit d = true) : ∃ i, d = .lit i := by
  cases d with
  | lit i => exact ⟨i, rfl⟩
  | sym _ => cases h

variable {M : Map} {S : SSrv} {C : CSrv} (hs : Srv M ν S C)
include hs

/-- Normalization with a literal weight `[n]` over a literal last dimension. -/
theorem infer_rms2_simS {eps : NumV} {s : List Dim} {d dw : Nat} {n l : Int}
    (hl : nthD (.lit 0) s (len s - 1) = .lit l) (h : ShOk M S.tab.length [(s, d)]) :
    MSim (IPost M ν S C) S C (Host.Mlx.Ffi.infer (.rmsNorm eps) [(s, d), ([.lit n], dw)])
      (Host.Mlx.Ffi.infer (M.prim (.rmsNorm eps)) ([(s, d), ([.lit n], dw)].map M.shp)) := by
  have hc := h _ List.mem_cons_self
  have hl' : nthD (.lit 0) (M.dims s) (len (M.dims s) - 1) = .lit l := by rw [len_dims, nthD_dims, hl]; rfl
  refine infer_pure_simV hs (o := bif decide (n = l) && Host.Mlx.Ffi.isFloat (Host.Mlx.Ffi.promote d dw) then
      some (.node s (Host.Mlx.Ffi.promote d dw)) else none) ?_ ?_ fun s' d' e => ?_
  · show Host.Ts.M.bind (Host.Mlx.Ffi.dEq (.lit n) (nthD (.lit 0) s (len s - 1))) _ = _
    rw [hl, dEq_lit]
    show (bif decide (n = l) && _ then _ else _) = _
    rw [cond_pure]
  · show Host.Ts.M.bind (Host.Mlx.Ffi.dEq (.lit n) (nthD (.lit 0) (M.dims s) (len (M.dims s) - 1))) _ = _
    rw [hl', dEq_lit]
    show (bif decide (n = l) && _ then _ else _) = _
    rw [cond_pure]
    cases decide (n = l) && Host.Mlx.Ffi.isFloat (Host.Mlx.Ffi.promote d dw) <;> rfl
  · cases hf : (decide (n = l) && Host.Mlx.Ffi.isFloat (Host.Mlx.Ffi.promote d dw)) <;> rw [hf] at e <;> cases e
    exact hc

/-- Quantized matmul with literal weights, scales and biases over a literal inner dimension. -/
theorem infer_qmm_simS {tr : Bool} {g b : Nat} {mode : List Char} {x w sc bi : List Dim} {dx dw dsc dbi : Nat}
    {xl : Int} (hx : nthD (.lit 0) x (len x - 1) = .lit xl) (hw : Lits w) (hsc : Lits sc) (hbi : Lits bi)
    (h : ShOk M S.tab.length [(x, dx)]) :
    MSim (IPost M ν S C) S C (Host.Mlx.Ffi.infer (.qmm tr g b mode) [(x, dx), (w, dw), (sc, dsc), (bi, dbi)])
      (Host.Mlx.Ffi.infer (M.prim (.qmm tr g b mode)) ([(x, dx), (w, dw), (sc, dsc), (bi, dbi)].map M.shp)) := by
  have hc := h _ List.mem_cons_self
  have hx' : nthD (.lit 0) (M.dims x) (len (M.dims x) - 1) = .lit xl := by rw [len_dims, nthD_dims, hx]; rfl
  obtain ⟨sb, -, esb⟩ := (allEq_pure sc bi hsc hbi).eq
  obtain ⟨wl, ewl⟩ := dimLit_eq (nthD_lit hw (len w - 1))
  obtain ⟨w2, ew2⟩ := dimLit_eq (nthD_lit hw (len w - 2))
  have e0 : [(x, dx), (w, dw), (sc, dsc), (bi, dbi)].map M.shp = [(M.dims x, dx), (w, dw), (sc, dsc), (bi, dbi)] := by
    simp only [List.map_cons, List.map_nil, Map.shp, dims_lit M hw, dims_lit M hsc, dims_lit M hbi]
  rw [e0]
  let c0 := !(nameEq mode chars!"affine") || !(Nat.beq dw Host.Mlx.Ffi.dtUint32) || Nat.beq b 0
  let inner : Int := bif tr then wl * 32 / b else w2
  let outer : Int := bif tr then w2 else wl * 32 / b
  let dt := Host.Mlx.Ffi.promote dx (Host.Mlx.Ffi.promote dsc dbi)
  let cc := decide (xl = inner) && sb && Nat.ble 2 (len w) && Host.Mlx.Ffi.isFloat dt
  refine infer_pure_simV hs (o := bif c0 then none else bif cc then
      some (.node (Host.Mlx.Ffi.setAt x (len x - 1) (.lit outer)) dt) else none) ?_ ?_ fun s' d' e => ?_
  · show (bif c0 then Host.Ts.M.pure none else _) = _
    cases hc0 : c0
    · show (match nthD (.lit 0) w (len w - 1), nthD (.lit 0) w (len w - 2) with
        | .lit wl, .lit w2 => _ | _, _ => _) = _
      rw [ewl, ew2]
      show Host.Ts.M.bind (Host.Mlx.Ffi.dEq (nthD (.lit 0) x (len x - 1)) (.lit inner)) _ = _
      rw [hx, dEq_lit]
      show Host.Ts.M.bind (Host.Mlx.Ffi.allEq sc bi) _ = _
      rw [esb]
      show (bif cc then _ else _) = _
      rw [cond_pure]; rfl
    · rfl
  · show (bif c0 then Host.Ts.M.pure none else _) = _
    cases hc0 : c0
    · show (match nthD (.lit 0) w (len w - 1), nthD (.lit 0) w (len w - 2) with
        | .lit wl, .lit w2 => _ | _, _ => _) = _
      rw [ewl, ew2]
      show Host.Ts.M.bind (Host.Mlx.Ffi.dEq (nthD (.lit 0) (M.dims x) (len (M.dims x) - 1)) (.lit inner)) _ = _
      rw [hx', dEq_lit]
      show Host.Ts.M.bind (Host.Mlx.Ffi.allEq sc bi) _ = _
      rw [esb]
      show (bif cc then Host.Ts.M.pure (some (Out.node (Host.Mlx.Ffi.setAt (M.dims x) (len (M.dims x) - 1)
        (.lit outer)) dt)) else Host.Ts.M.pure none) = _
      rw [len_dims, setAt_dims_lit, cond_pure]
      cases cc <;> rfl
    · rfl
  · cases hc0 : c0 <;> rw [hc0] at e
    · cases hcc : cc <;> rw [hcc] at e <;> cases e
      refine ⟨fun e he => ?_, fun e he => ?_⟩
      · rcases mem_setAt he with h' | rfl
        · exact hc.1 e h'
        · trivial
      · rcases mem_setAt he with h' | rfl
        · exact hc.2 e h'
        · rfl
    · cases e

/-- **Broadcasting binary operations.** -/
theorem infer_binary_simV {op : List Char} {a b : List Dim} {da db : Nat} {ka kb : List Nat}
    (ha : DVSs M C S a ka) (hb : DVSs M C S b kb) (ba : Bd ka) (bb : Bd kb) :
    MSim (IPost M ν S C) S C (Host.Mlx.Ffi.infer (.binary op) [(a, da), (b, db)])
      (Host.Mlx.Ffi.infer (M.prim (.binary op)) ([(a, da), (b, db)].map M.shp)) := by
  show MSim _ S C (Host.Ts.M.bind (Host.Mlx.Ffi.broadcast a b) _) (Host.Ts.M.bind (Host.Mlx.Ffi.broadcast (M.dims a) (M.dims b)) _)
  refine MSim.bind (broadcast_simV hs ha hb ba bb) fun M' S' C' r r' ⟨hg, h⟩ => MSim.pure ⟨hg, ?_⟩
  rcases h with ⟨rfl, -⟩ | ⟨ds, kds, rfl, rfl, hds, bds⟩
  · trivial
  · exact ⟨rfl, hds.sds, hds.canon bds.lt53⟩

omit hs in
/-- A list of dimensions with values has no `-1` image. -/
theorem DVSs.no_neg {M : Map} {S : SSrv} {C : CSrv} :
    ∀ {ds : List Dim} {ks : List Nat}, DVSs M C S ds ks → (∀ k ∈ ks, k < 2 ^ 53) →
      (M.dims ds).filter (· = .lit (-1)) = [] ∧ ds.filter (· = .lit (-1)) = []
  | [], [], _, _ => ⟨rfl, rfl⟩
  | d :: ds, k :: ks, ⟨hd, hds⟩, hb => by
    obtain ⟨ih1, ih2⟩ := DVSs.no_neg hds fun k' h => hb k' (List.mem_cons_of_mem _ h)
    have hk : k < 2 ^ 53 := hb k List.mem_cons_self
    have n1 : decide (M.dim d = .lit (-1)) = false := by
      rcases hd.1.dim hk with e | ⟨j, e, -⟩ <;> rw [e]
      · simp only [Dim.lit.injEq, decide_eq_false_iff_not]; omega
      · simp
    have n2 : decide (d = .lit (-1)) = false := by
      rcases hd.1 with rfl | ⟨j, rfl, -⟩
      · simp only [Dim.lit.injEq, decide_eq_false_iff_not]; omega
      · simp
    simp only [Map.dims, List.map_cons, List.filter_cons, n1, n2] at ih1 ⊢
    exact ⟨ih1, by simpa [Map.dims] using ih2⟩

/-- **Reshapes without `-1`.** -/
theorem infer_reshape_simV {new old : List Dim} {d : Nat} {kn ko : List Nat}
    (hn : DVSs M C S new kn) (ho : DVSs M C S old ko) (bn : ∀ k ∈ kn, k < 2 ^ 53) (bo : ∀ k ∈ ko, k < 2 ^ 53)
    (pn : ProdB kn) (po : ProdB ko) :
    MSim (IPost M ν S C) S C (Host.Mlx.Ffi.infer (.reshape new) [(old, d)])
      (Host.Mlx.Ffi.infer (M.prim (.reshape new)) ([(old, d)].map M.shp)) := by
  obtain ⟨f1, f2⟩ := DVSs.no_neg hn bn
  show MSim _ S C (Host.Ts.M.bind (Host.Mlx.Ffi.reshapeShape old new) _)
    (Host.Ts.M.bind (Host.Mlx.Ffi.reshapeShape (M.dims old) (M.dims new)) _)
  unfold Host.Mlx.Ffi.reshapeShape
  rw [f1, f2]
  dsimp only
  let RP : Map → SSrv → CSrv → Option (List Dim) → Option (List Dim) → Prop := fun M' S' C' r r' =>
    GrowL M ν S C M' S' C' ∧ (r = none ∨ (r = some new ∧ r' = some (M'.dims new) ∧ DVSs M' C' S' new kn))
  refine MSim.bind (P := RP) (MSim.bind (dProd_simV hs ho bo po) fun M1 S1 C1 t t' ⟨ht, htv, hts, hg1⟩ => ?_)
    fun M' S' C' r r' h => MSim.pure (M := M') ?_
  · obtain ⟨hn1, hm1⟩ := DVSs.lift hg1 hn
    rw [← hm1]
    refine MSim.bind (dProd_simV hg1.grow.srv hn1 bn pn) fun M2 S2 C2 p p' ⟨hp, hpv, hps, hg2⟩ => ?_
    have ht2 := htv.growL hg2 hts
    have htm : M2.dim t = M1.dim t := (DVS.lift ⟨htv, hts⟩ hg2).2
    rw [hp, ht, ← htm]
    refine MSim.bind (dEq_simV hg2.grow.srv hpv ht2 (pn 0) (po 0)) fun M3 S3 C3 e e' ⟨he, _, hg3⟩ => ?_
    rw [he]
    obtain ⟨hn2, hm2⟩ := DVSs.lift hg2 hn1
    obtain ⟨hn3, hm3⟩ := DVSs.lift hg3 hn2
    refine MSim.pure (M := M3) ⟨hg1.trans (hg2.trans hg3), ?_⟩
    cases e
    · exact .inl rfl
    · refine .inr ⟨rfl, ?_, hn3⟩
      show some (M1.dims new) = some (M3.dims new)
      rw [hm3, hm2]
  · obtain ⟨hg, hr⟩ := h
    refine ⟨hg, ?_⟩
    rcases hr with rfl | ⟨rfl, rfl, hn'⟩
    · trivial
    · exact ⟨rfl, hn'.sds, hn'.canon bn⟩

end

end Host.Ts.Sim
