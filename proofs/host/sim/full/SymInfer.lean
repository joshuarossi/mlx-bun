import host.sim.full.SymDims
namespace Host.Ts.Sim
open Host.Mlx.Ffi (Dim Prim Node Out dimOf)

/-! # Shape inference over symbolic shapes, for the forward's operations

`host.sim.native.InferV` simulates the inference of the decode route's symbolic operations
(slices, slice updates, two-input concatenation, attention). These are the forward's other
operations over symbolic shapes:

* request-free rules (`infer_*_simS`): elementwise unary operations, `astype`, `contiguous`,
  normalization (with a literal weight and last dimension), rope, transposition, `take`, dynamic
  slices, `logsumexp`, and quantized matmul (with literal weights and inner dimension): the
  output's dimensions are the inputs' (or the primitive's), so the target's inference over the
  images returns the image (`infer_pure_simV`);
* broadcasting binary operations (`infer_binary_simV`, through `broadcast_simV`);
* reshapes without `-1` (`infer_reshape_simV`, through `dProd_simV` and `dEq_simV`).

The inputs' dimensions are closed and canonical (`ShOk`, which the native relation gives for
present nodes); dimensions with requests need values (`DVSs`). -/

section
variable {ν : Nat → F64}

/-- Input shapes closed below `n` with canonical images. -/
def ShOk (M : Map) (n : Nat) (sh : List (List Dim × Nat)) : Prop :=
  ∀ p ∈ sh, SDs (· < n) p.1 ∧ ∀ d ∈ p.1, DimCanon M d

/-- An inference result under the map. -/
def outMap (M : Map) : Out → Out
  | .node s d => .node (M.dims s) d
  | .same i => .same i

/-- **Request-free inference.** -/
theorem infer_pure_simV {M : Map} {S : SSrv} {C : CSrv} (hs : Srv M ν S C) {o : Option Out}
    {m m' : Host.Ts.M (Option Out)} (h1 : m = Host.Ts.M.pure o) (h2 : m' = Host.Ts.M.pure (o.map (outMap M)))
    (hcl : ∀ s d, o = some (.node s d) → SDs (· < S.tab.length) s ∧ ∀ e ∈ s, DimCanon M e) :
    MSim (IPost M ν S C) S C m m' := by
  subst h1 h2
  refine MSim.pure ⟨GrowL.refl hs, ?_⟩
  rcases o with _ | ⟨s, d⟩ | i
  · trivial
  · exact ⟨rfl, hcl s d rfl⟩
  · rfl

theorem cond_pure {α : Type} (c : Bool) (a b : α) :
    (bif c then Host.Ts.M.pure a else Host.Ts.M.pure b) = Host.Ts.M.pure (bif c then a else b) := by
  cases c <;> rfl

theorem dims_take (M : Map) (s : List Dim) (k : Nat) : M.dims (s.take k) = (M.dims s).take k := by
  simp [Map.dims, List.map_take]

theorem dims_drop (M : Map) (s : List Dim) (k : Nat) : M.dims (s.drop k) = (M.dims s).drop k := by
  simp [Map.dims, List.map_drop]

theorem dims_append (M : Map) (a b : List Dim) : M.dims (a ++ b) = M.dims a ++ M.dims b := by
  simp [Map.dims]

variable {M : Map} {S : SSrv} {C : CSrv} (hs : Srv M ν S C)
include hs

theorem infer_unary_simS {op : List Char} {s : List Dim} {d : Nat} (h : ShOk M S.tab.length [(s, d)]) :
    MSim (IPost M ν S C) S C (Host.Mlx.Ffi.infer (.unary op) [(s, d)])
      (Host.Mlx.Ffi.infer (M.prim (.unary op)) ([(s, d)].map M.shp)) :=
  infer_pure_simV hs rfl rfl fun s' d' e => by cases e; exact h _ List.mem_cons_self

theorem infer_astype_simS {dt : Nat} {s : List Dim} {d : Nat} (h : ShOk M S.tab.length [(s, d)]) :
    MSim (IPost M ν S C) S C (Host.Mlx.Ffi.infer (.astype dt) [(s, d)])
      (Host.Mlx.Ffi.infer (M.prim (.astype dt)) ([(s, d)].map M.shp)) :=
  infer_pure_simV hs rfl rfl fun s' d' e => by cases e; exact h _ List.mem_cons_self

theorem infer_contiguous_simS {s : List Dim} {d : Nat} (h : ShOk M S.tab.length [(s, d)]) :
    MSim (IPost M ν S C) S C (Host.Mlx.Ffi.infer .contiguous [(s, d)])
      (Host.Mlx.Ffi.infer (M.prim .contiguous) ([(s, d)].map M.shp)) :=
  infer_pure_simV hs rfl rfl fun s' d' e => by cases e; exact h _ List.mem_cons_self

theorem infer_rms1_simS {eps : NumV} {s : List Dim} {d : Nat} (h : ShOk M S.tab.length [(s, d)]) :
    MSim (IPost M ν S C) S C (Host.Mlx.Ffi.infer (.rmsNorm eps) [(s, d)])
      (Host.Mlx.Ffi.infer (M.prim (.rmsNorm eps)) ([(s, d)].map M.shp)) := by
  refine infer_pure_simV hs (o := bif Host.Mlx.Ffi.isFloat d then some (.node s d) else none)
    (cond_pure _ _ _) ?_ fun s' d' e => ?_
  · show (bif Host.Mlx.Ffi.isFloat d then _ else _) = _
    rw [cond_pure]; cases Host.Mlx.Ffi.isFloat d <;> rfl
  · cases hf : Host.Mlx.Ffi.isFloat d <;> rw [hf] at e <;> cases e
    exact h _ List.mem_cons_self

theorem infer_rope_simS {dims : Nat} {tr : Bool} {base : Arg} {scale off : NumV} {s : List Dim} {d : Nat}
    (h : ShOk M S.tab.length [(s, d)]) :
    MSim (IPost M ν S C) S C (Host.Mlx.Ffi.infer (.rope dims tr base scale off) [(s, d)])
      (Host.Mlx.Ffi.infer (M.prim (.rope dims tr base scale off)) ([(s, d)].map M.shp)) := by
  refine infer_pure_simV hs (o := bif Nat.ble 3 (len s) then some (.node s d) else none)
    (cond_pure _ _ _) ?_ fun s' d' e => ?_
  · show (bif Nat.ble 3 (len (M.dims s)) then _ else _) = _
    rw [len_dims, cond_pure]; cases Nat.ble 3 (len s) <;> rfl
  · cases hf : Nat.ble 3 (len s) <;> rw [hf] at e <;> cases e
    exact h _ List.mem_cons_self

omit hs in
theorem mem_map_nthD {s : List Dim} {axes : List Nat} {e : Dim} (he : e ∈ axes.map (nthD (.lit 0) s)) :
    e ∈ s ∨ e = .lit 0 := by
  obtain ⟨a, -, rfl⟩ := List.mem_map.mp he
  exact mem_nthD

theorem infer_transpose_simS {axes : List Nat} {s : List Dim} {d : Nat} (h : ShOk M S.tab.length [(s, d)]) :
    MSim (IPost M ν S C) S C (Host.Mlx.Ffi.infer (.transpose axes) [(s, d)])
      (Host.Mlx.Ffi.infer (M.prim (.transpose axes)) ([(s, d)].map M.shp)) := by
  have hc := h _ List.mem_cons_self
  refine infer_pure_simV hs (o := bif Nat.beq (len axes) (len s) && (List.range (len s)).all
      (fun a => axes.any (Nat.beq a)) then some (.node (axes.map (nthD (.lit 0) s)) d) else none)
    (cond_pure _ _ _) ?_ fun s' d' e => ?_
  · show (bif Nat.beq (len axes) (len (M.dims s)) && (List.range (len (M.dims s))).all
      (fun a => axes.any (Nat.beq a)) then _ else _) = _
    rw [len_dims, cond_pure]
    cases Nat.beq (len axes) (len s) && (List.range (len s)).all (fun a => axes.any (Nat.beq a))
    · rfl
    · show Host.Ts.M.pure (some (Out.node (axes.map (nthD (.lit 0) (M.dims s))) d)) = _
      rw [show axes.map (nthD (.lit 0) (M.dims s)) = M.dims (axes.map (nthD (.lit 0) s)) by
        simp only [Map.dims, List.map_map]; exact List.map_congr_left fun a _ => nthD_dims M s a]
      rfl
  · cases hf : (Nat.beq (len axes) (len s) && (List.range (len s)).all (fun a => axes.any (Nat.beq a))) <;>
      rw [hf] at e <;> cases e
    refine ⟨fun e he => ?_, fun e he => ?_⟩
    · rcases mem_map_nthD he with h' | rfl
      · exact hc.1 e h'
      · trivial
    · rcases mem_map_nthD he with h' | rfl
      · exact hc.2 e h'
      · rfl

theorem infer_take_simS {axis : Nat} {a i : List Dim} {d di : Nat} (h : ShOk M S.tab.length [(a, d), (i, di)]) :
    MSim (IPost M ν S C) S C (Host.Mlx.Ffi.infer (.take axis) [(a, d), (i, di)])
      (Host.Mlx.Ffi.infer (M.prim (.take axis)) ([(a, d), (i, di)].map M.shp)) := by
  have ha := h _ List.mem_cons_self
  have hi := h _ (List.mem_cons_of_mem _ List.mem_cons_self)
  refine infer_pure_simV hs (o := bif Nat.blt axis (len a) && Host.Mlx.Ffi.isInteger di then
      some (.node (a.take axis ++ i ++ a.drop (axis + 1)) d) else none) (cond_pure _ _ _) ?_ fun s' d' e => ?_
  · show (bif Nat.blt axis (len (M.dims a)) && Host.Mlx.Ffi.isInteger di then
      Host.Ts.M.pure (some (Out.node ((M.dims a).take axis ++ M.dims i ++ (M.dims a).drop (axis + 1)) d))
      else Host.Ts.M.pure none) = _
    rw [len_dims, cond_pure, ← dims_take, ← dims_drop, ← dims_append, ← dims_append]
    cases Nat.blt axis (len a) && Host.Mlx.Ffi.isInteger di <;> rfl
  · cases hf : (Nat.blt axis (len a) && Host.Mlx.Ffi.isInteger di) <;> rw [hf] at e <;> cases e
    refine ⟨fun e he => ?_, fun e he => ?_⟩ <;>
    · simp only [List.mem_append] at he
      rcases he with (he | he) | he
      · first | exact ha.1 e (List.mem_of_mem_take he) | exact ha.2 e (List.mem_of_mem_take he)
      · first | exact hi.1 e he | exact hi.2 e he
      · first | exact ha.1 e (List.mem_of_mem_drop he) | exact ha.2 e (List.mem_of_mem_drop he)

theorem infer_sliceDynamic_simS {axes : List Nat} {sizes : List Dim} {s st : List Dim} {d sd : Nat}
    (hz : SDs (· < S.tab.length) sizes) (hzc : ∀ e ∈ sizes, DimCanon M e) :
    MSim (IPost M ν S C) S C (Host.Mlx.Ffi.infer (.sliceDynamic axes sizes) [(s, d), (st, sd)])
      (Host.Mlx.Ffi.infer (M.prim (.sliceDynamic axes sizes)) ([(s, d), (st, sd)].map M.shp)) := by
  refine infer_pure_simV hs (o := bif Nat.beq (len sizes) (len s) && Host.Mlx.Ffi.isInteger sd &&
      Nat.ble (len st) 1 && axes.all (Nat.blt · (len s)) then some (.node sizes d) else none)
    (cond_pure _ _ _) ?_ fun s' d' e => ?_
  · show (bif Nat.beq (len (M.dims sizes)) (len (M.dims s)) && Host.Mlx.Ffi.isInteger sd &&
      Nat.ble (len (M.dims st)) 1 && axes.all (Nat.blt · (len (M.dims s))) then
      Host.Ts.M.pure (some (Out.node (M.dims sizes) d)) else Host.Ts.M.pure none) = _
    rw [len_dims, len_dims, len_dims, cond_pure]
    cases Nat.beq (len sizes) (len s) && Host.Mlx.Ffi.isInteger sd && Nat.ble (len st) 1 &&
      axes.all (Nat.blt · (len s)) <;> rfl
  · cases hf : (Nat.beq (len sizes) (len s) && Host.Mlx.Ffi.isInteger sd && Nat.ble (len st) 1 &&
      axes.all (Nat.blt · (len s))) <;> rw [hf] at e <;> cases e
    exact ⟨hz, hzc⟩

theorem infer_logsumexp_simS {axis : Nat} {keep : Bool} {s : List Dim} {d : Nat} (h : ShOk M S.tab.length [(s, d)]) :
    MSim (IPost M ν S C) S C (Host.Mlx.Ffi.infer (.logsumexp axis keep) [(s, d)])
      (Host.Mlx.Ffi.infer (M.prim (.logsumexp axis keep)) ([(s, d)].map M.shp)) := by
  have hc := h _ List.mem_cons_self
  refine infer_pure_simV hs (o := bif Nat.blt axis (len s) then some (.node (bif keep then
      Host.Mlx.Ffi.setAt s axis (.lit 1) else s.take axis ++ s.drop (axis + 1)) (Host.Mlx.Ffi.atLeastFloat d))
      else none) (cond_pure _ _ _) ?_ fun s' d' e => ?_
  · show (bif Nat.blt axis (len (M.dims s)) then Host.Ts.M.pure (some (Out.node (bif keep then
      Host.Mlx.Ffi.setAt (M.dims s) axis (.lit 1) else (M.dims s).take axis ++ (M.dims s).drop (axis + 1))
      (Host.Mlx.Ffi.atLeastFloat d))) else Host.Ts.M.pure none) = _
    rw [len_dims, cond_pure]
    cases Nat.blt axis (len s)
    · rfl
    · cases keep
      · show Host.Ts.M.pure (some (Out.node ((M.dims s).take axis ++ (M.dims s).drop (axis + 1)) _)) = _
        rw [← dims_take, ← dims_drop, ← dims_append]; rfl
      · show Host.Ts.M.pure (some (Out.node (Host.Mlx.Ffi.setAt (M.dims s) axis (.lit 1)) _)) = _
        rw [setAt_dims_lit]; rfl
  · cases hf : Nat.blt axis (len s) <;> rw [hf] at e <;> cases e
    cases keep
    · refine ⟨fun e he => ?_, fun e he => ?_⟩ <;>
      · rcases List.mem_append.mp he with he | he
        · first | exact hc.1 e (List.mem_of_mem_take he) | exact hc.2 e (List.mem_of_mem_take he)
        · first | exact hc.1 e (List.mem_of_mem_drop he) | exact hc.2 e (List.mem_of_mem_drop he)
    · refine ⟨fun e he => ?_, fun e he => ?_⟩
      · rcases mem_setAt he with h' | rfl
        · exact hc.1 e h'
        · trivial
      · rcases mem_setAt he with h' | rfl
        · exact hc.2 e h'
        · rfl

end

end Host.Ts.Sim
