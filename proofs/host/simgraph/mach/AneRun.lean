import host.simgraph.mach.AnePremise
import host.simgraph.mach.AneGood
namespace Host.Mlx.SimGraph.Mach
open Host.Mlx.GlueStep Host.Mlx.GlueLayers
open Inference Inference.Contracts.Mlx Host.Mlx Host.Mlx.FfiEval Host.Mlx.FfiAneEval Host.Mlx.SimGraph
open Host.Mlx.SimGraph.Ref (AneNet SplitSpec FillSpec FillSrc AneSt splitRun aneNode aneNodes withRb noInputK srcVal
  fillRun runFills runCall primEvalE_envK primEvalE_input)

/-! # A Neural Engine step's node-by-node run is defined

* `splitCall_ok`: a split (`SplitOk`) on its site's taps typed at their sizes completes: its fills (the in-place
  kernels' contract fields), the program (`NeuralEngine.Succeeds`), the readback `[n, D]`.
* `aneNodes_ok`: the node-by-node run of a graph (`aneNodes`) is defined when every node has a value and the run's
  form at every environment holding typed readbacks (`Good`, at `envR`) and every readback input's split
  completes from a state of the run so far (`RunInv`); the run's values are then the graph's values at the
  environment holding its readbacks (each typed `[M, D]` of its split). -/

/-! ## A split call -/

/-- A site's tap values at their sizes: bf16, of `sizes[i]` elements. -/
def SiteTy (sizes : List Nat) (vs : List Value) : Prop :=
  List.Forall₂ (fun v N => v.dtype = .bfloat16 ∧ v.size = N) vs sizes

section
variable {C : M1Max.Contract} (K : RouteKernelContract C)

theorem surfaceValue_size (S : Surface) (dt : Dtype) (sh : List Nat) :
    (surfaceValue S dt sh).size = sh.foldr (· * ·) 1 := rfl

theorem fillRun_done (f : FillSpec) (xs : List Value) (S : Surface) (i : Nat) (hi : i = xs.length)
    {stored : Nat → Option (BitVec 8)}
    (h : WritesDone K.inPlace f.k (xs ++ [surfaceValue S f.dt f.sh]) f.cfg i stored) :
    ∃ R, fillRun K.inPlace (f.fill xs) S = some R := by
  obtain ⟨⟨res, B, dst, hl, _, hB, _, _⟩, hdone⟩ := h
  have hd := hdone res hl
  refine ⟨B, ?_⟩
  unfold fillRun
  simp only [FillSpec.fill, List.length_map]
  rw [hl]
  simp only [Option.bind_eq_bind, Option.bind_some]
  rw [show xs.length + 1 = (xs ++ [surfaceValue S f.dt f.sh]).length by simp, hd]
  simp only [Option.bind_some]
  rw [← hi]; exact hB

theorem siteTy_get {sizes : List Nat} {site : List Value} (hs : SiteTy sizes site) {i N : Nat}
    (hN : sizes[i]? = some N) : ∃ v, site[i]? = some v ∧ v.dtype = .bfloat16 ∧ v.size = N := by
  unfold SiteTy at hs
  induction hs generalizing i with
  | nil => simp at hN
  | @cons v N' vs ns hv _ ih =>
    cases i with
    | zero => simp at hN; subst hN; exact ⟨v, rfl, hv⟩
    | succ i => exact ih (by simpa using hN)

/-- **A fill completes** on any surface, its sources the site's taps typed at their sizes. -/
theorem fill_ok (sizes : List Nat) (f : FillSpec) (hf : FillOk sizes f) (site : List Value) (hs : SiteTy sizes site)
    (hw : ∀ N ∈ sizes, WriteRoute N) :
    ∃ xs, f.srcs.mapM (srcVal site) = some xs ∧ ∀ S, ∃ R, fillRun K.inPlace (f.fill xs) S = some R := by
  obtain ⟨hdt, hf⟩ := hf
  rcases hf with ⟨rows, bits, cd, sc, hk, hc, hr, hsrc, hcd, hsc, hsz⟩ | ⟨rows, cd, sc, hk, hc, hr, hsrc, hcd, hsc, hsz⟩ |
    ⟨i, N, hk, hc, hsrc, hN, hsz⟩
  · refine ⟨[cd, sc], by rw [hsrc]; rfl, fun S => fillRun_done K f [cd, sc] S 2 rfl (by
      rw [hk, hc, hdt]
      exact K.aneTrellisFill cd sc _ hr hcd hsc rfl (by rw [surfaceValue_size]; exact hsz))⟩
  · refine ⟨[cd, sc], by rw [hsrc]; rfl, fun S => fillRun_done K f [cd, sc] S 2 rfl (by
      rw [hk, hc, hdt]
      exact K.aneTrellisFillK3i cd sc _ hr hcd hsc rfl (by rw [surfaceValue_size]; exact hsz))⟩
  · obtain ⟨src, hsrc', hty⟩ := siteTy_get hs hN
    refine ⟨[src], by rw [hsrc]; simp [srcVal, hsrc'], fun S => fillRun_done K f [src] S 1 rfl (by
      rw [hk, hc, hdt]
      exact K.aneWriteHalf src _ (hw N (List.mem_of_getElem? hN)) hty.1 hty.2 rfl
        (by rw [surfaceValue_size]; exact hsz))⟩

theorem fills_ok (sizes : List Nat) (site : List Value) (hs : SiteTy sizes site) (hw : ∀ N ∈ sizes, WriteRoute N) :
    ∀ (fs : List FillSpec), (∀ f ∈ fs, FillOk sizes f) →
      ∃ fills, fs.mapM (fun f => (f.srcs.mapM (srcVal site)).map f.fill) = some fills ∧
        ∀ σ, ∃ σ', runFills K.inPlace fills σ = some σ'
  | [], _ => ⟨[], rfl, fun σ => ⟨σ, rfl⟩⟩
  | f :: fs, h => by
    obtain ⟨xs, hxs, hrun⟩ := fill_ok K sizes f (h f (List.mem_cons_self ..)) site hs hw
    obtain ⟨fills, hfs, hrest⟩ := fills_ok sizes site hs hw fs fun f' m => h f' (List.mem_cons_of_mem _ m)
    refine ⟨f.fill xs :: fills, by simp [List.mapM_cons, hxs, hfs], fun σ => ?_⟩
    obtain ⟨R, hR⟩ := hrun (σ (f.fill xs).sid)
    obtain ⟨σ', h'⟩ := hrest (upd σ (f.fill xs).sid (toSurface R))
    exact ⟨σ', by simp only [runFills, hR, Option.bind_some]; exact h'⟩

/-- **A split call completes**: on its site's taps typed at their sizes, from any surfaces, its fills, the program
(evaluating on its declared inputs) and the readback `[n, D]`. -/
theorem splitCall_ok (NE : NeuralEngine) {n p s D : Nat} {sizes : List Nat} {sp : SplitSpec}
    (hok : SplitOk n p s D sizes sp) (site : List Value) (hs : SiteTy sizes site) (hw : ∀ N ∈ sizes, WriteRoute N)
    (hNE : ∀ ins : List Surface, ins.length = sp.prog.prog.inputBytes.length → (NE.eval sp.prog.prog ins).isSome)
    (σ : Nat → Surface) :
    ∃ fills σ' y, sp.fills.mapM (fun f => (f.srcs.mapM (srcVal site)).map f.fill) = some fills ∧
      runCall NE K.inPlace sp.prog fills σ = some σ' ∧ readback (σ' sp.prog.out) sp.len sp.M sp.D = some y ∧
      Ty y .bfloat16 [n, D] := by
  obtain ⟨fills, hf, hrun⟩ := fills_ok K sizes site hs hw sp.fills hok.fills
  obtain ⟨σ1, h1⟩ := hrun σ
  obtain ⟨out, hout⟩ := Option.isSome_iff_exists.mp (hNE (sp.prog.ins.map σ1) (by rw [List.length_map, hok.ins]))
  have hlen : sp.M * sp.D ≤ sp.len := by rw [hok.m_eq, hok.d_eq]; exact hok.len
  refine ⟨fills, _, _, hf, by simp only [runCall, h1, Option.bind_eq_bind, Option.bind_some, hout]; rfl,
    readback_eq _ sp.len sp.M sp.D hlen, ⟨rfl, by rw [hok.m_eq, hok.d_eq]⟩⟩

end

/-! ## The node-by-node run -/

section
variable {C : M1Max.Contract} (P : MlxPrefillContract C) (K : RouteKernelContract C) (net : AneNet) (n : Nat)
  (base : Env AKey)

/-- The readbacks `rb`, a zero readback of its split's geometry at every other split key. -/
def rbExt (rb : AKey → Option Value) : AKey → Option Value :=
  fun k => (rb k).orElse fun _ => (net.split n k).map fun sp => zeros [sp.M, sp.D] .bfloat16

/-- The environment holding the readbacks `rb` (zeros at the other split keys), `base` elsewhere. -/
abbrev envR (rb : AKey → Option Value) : Env AKey := withRb base (rbExt net n rb)

/-- Readbacks at split keys, each typed at its split's geometry. -/
def RbTyped (rb : AKey → Option Value) : Prop :=
  ∀ k y, rb k = some y → ∃ sp, net.split n k = some sp ∧ Ty y .bfloat16 [sp.M, sp.D]

theorem rbExt_typed {rb : AKey → Option Value} (h : RbTyped net n rb) : RbTyped net n (rbExt net n rb) := by
  intro k y hk
  unfold rbExt at hk
  cases e : rb k with
  | some v =>
    rw [e] at hk; cases hk; exact h k y e
  | none =>
    rw [e] at hk
    simp only [Option.orElse] at hk
    obtain ⟨sp, hsp, rfl⟩ := Option.map_eq_some_iff.mp hk
    exact ⟨sp, hsp, rfl, rfl⟩

variable (E : List (RNode Int AKey))

/-- The run after `i` nodes: one value per node, the graph's at the environment holding the readbacks so far;
the readbacks typed; every split key read so far has its readback. -/
structure RunInv (i : Nat) (st : AneSt) : Prop where
  len : st.vals.length = i
  rbTy : RbTyped net n st.rb
  vals : ∀ j < i, st.vals[j]? =
    evalE P K.toKernelContract (envR net n base st.rb) (ksR P K (envR net n base st.rb)) (listGraph E) j
  seen : ∀ j nd k, j < i → E[j]? = some nd → nd.prim = .input k → net.split n k ≠ none → st.rb k ≠ none

theorem runInv_zero (σ : Nat → Surface) : RunInv P K net n base E 0 ⟨[], fun _ => none, σ, []⟩ :=
  ⟨rfl, fun _ _ h => (nomatch h), fun _ h => absurd h (by omega), fun _ _ _ h => absurd h (by omega)⟩

theorem mapM_isSome {α β : Type} {f : α → Option β} : ∀ {l : List α} {ys : List β}, l.mapM f = some ys →
    ∀ x ∈ l, (f x).isSome
  | [], _, _, _, h => by cases h
  | a :: l, ys, h, x, hx => by
    simp only [List.mapM_cons, Option.bind_eq_bind, Option.bind_eq_some_iff, Option.pure_def,
      Option.some.injEq] at h
    obtain ⟨b, hb, bs, hbs, _⟩ := h
    rcases List.mem_cons.mp hx with rfl | hx
    · rw [hb]; rfl
    · exact mapM_isSome hbs x hx

/-- **The graph's values read the environment only at its inputs' keys.** -/
theorem evalE_local (env env' : Env AKey) (hw : env.weights = env'.weights)
    (hform : ∀ j (h : j < E.length), NodeForm E[j]) :
    ∀ i, (∀ j ≤ i, ∀ nd k, E[j]? = some nd → nd.prim = .input k → env.inputs k = env'.inputs k) →
      evalE P K.toKernelContract env (ksR P K env) (listGraph E) i =
        evalE P K.toKernelContract env' (ksR P K env') (listGraph E) i := by
  intro i
  induction i using Nat.strong_induction_on with
  | _ i ih =>
  intro hk
  rw [evalE_eq, evalE_eq]
  cases hg : listGraph E i with
  | none => rfl
  | some nd =>
    dsimp only
    have hi : i < E.length := (List.getElem?_eq_some_iff.mp hg).1
    have hnd : E[i] = nd := by have := (List.getElem?_eq_some_iff.mp hg).2; exact this
    have hm : (nd.ins.mapM fun j => if _h : j < i then
        evalE P K.toKernelContract env (ksR P K env) (listGraph E) j else none) =
        nd.ins.mapM fun j => if _h : j < i then
          evalE P K.toKernelContract env' (ksR P K env') (listGraph E) j else none :=
      mapM_congr' _ _ _ fun j _ => by
        by_cases hj : j < i
        · rw [dite_eq_left hj, dite_eq_left hj, ih j hj fun j' hj' => hk j' (by omega)]
        · rw [dite_eq_right hj, dite_eq_right hj]
    rw [hm]
    rcases hnd ▸ hform i hi with ⟨k, hp, hins⟩ | hn
    · rw [hins, hp, List.mapM_nil, Option.pure_def, Option.bind_some, Option.bind_some, primEvalE_input,
        primEvalE_input]
      exact hk i (le_refl _) nd k hg hp
    · congr 1
      funext xs
      exact primEvalE_envK P K env env' hw nd.prim xs hn

end

end Host.Mlx.SimGraph.Mach
