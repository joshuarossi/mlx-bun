import host.simgraph.mach.AneRun
namespace Host.Mlx.SimGraph.Mach
open Host.Mlx.GlueStep Host.Mlx.GlueLayers
open Inference Inference.Contracts.Mlx Host.Mlx Host.Mlx.FfiEval Host.Mlx.FfiAneEval Host.Mlx.SimGraph
open Host.Mlx.SimGraph.Ref (AneNet SplitSpec AneSt splitRun aneNode aneNodes withRb noInputK primEvalE_envK
  primEvalE_input)

/-! # A Neural Engine step's node-by-node run is defined: the induction

`aneNode_ok`: from a state of the run after `i` nodes (`RunInv`), node `i` runs (an operation on the values so
far, an input's readback or `base`'s value, or a split at its readback input) and the run is at `i + 1`;
`aneNodes_ok`: the whole graph runs. The premises: every node has a value and the run's form at every environment
holding typed readbacks (`Good`), and every readback input's split completes from a state of the run so far. -/

section
variable {C : M1Max.Contract} (P : MlxPrefillContract C) (K : RouteKernelContract C) (NE : NeuralEngine)
  (IP : InPlace) (net : AneNet) (n : Nat) (base : Env AKey) (tapsN : List (List (List Nat)))
  (E : List (RNode Int AKey))

theorem aneNode_op (nd : RNode Int AKey) (st : AneSt) (hn : noInputK nd.prim = true) :
    aneNode P K NE IP net n base tapsN nd st = (nd.ins.mapM (st.vals[·]?)).bind fun xs =>
      (primEvalE P K.toKernelContract base (ksR P K base) nd.prim xs).map fun v => { st with vals := st.vals ++ [v] } := by
  unfold aneNode
  split
  · rename_i k hp
    rw [hp] at hn; simp [noInputK] at hn
  · rw [ite_eq_left hn]

theorem aneNode_inp (nd : RNode Int AKey) (st : AneSt) (k : AKey) (hp : nd.prim = .input k) (hins : nd.ins = []) :
    aneNode P K NE IP net n base tapsN nd st =
      match st.rb k, net.split n k with
      | some y, _ => some { st with vals := st.vals ++ [y] }
      | none, some sp => splitRun NE IP tapsN k sp st
      | none, none => (base.inputs k).map fun v => { st with vals := st.vals ++ [v] } := by
  unfold aneNode
  rw [hp]
  dsimp only
  rw [ite_eq_left hins]
  rfl

/-- The premise on a readback input's split: from a state of the run after `i` nodes in which its key has no
readback, it completes with a readback typed at its geometry. -/
def SplitsRun : Prop :=
  ∀ i nd k sp st, E[i]? = some nd → nd.prim = .input k → net.split n k = some sp → RunInv P K net n base E i st →
    st.rb k = none → ∃ y st', splitRun NE IP tapsN k sp st = some st' ∧ st'.vals = st.vals ++ [y] ∧
      st'.rb = (fun k' => if k' = k then some y else st.rb k') ∧ Ty y .bfloat16 [sp.M, sp.D]

/-- Every node has a value and the run's form at every environment holding typed readbacks. -/
def GoodAll : Prop :=
  ∀ rb, RbTyped net n rb → Good P K.toKernelContract (envR net n base rb) (ksR P K (envR net n base rb)) E

theorem evalE_input_at (env : Env AKey) {i : Nat} (hi : i < E.length) {k : AKey} (hp : E[i].prim = .input k)
    (hins : E[i].ins = []) : evalE P K.toKernelContract env (ksR P K env) (listGraph E) i = env.inputs k := by
  rw [evalE_eq, show listGraph E i = some E[i] from List.getElem?_eq_getElem hi]
  dsimp only
  rw [hins, hp, List.mapM_nil, Option.pure_def, Option.bind_some, primEvalE_input]

theorem withRb_inputs (rb : AKey → Option Value) (k : AKey) :
    (withRb base rb).inputs k = (rb k).orElse fun _ => base.inputs k := rfl

/-- A new value after `i` values keeps the earlier ones. -/
theorem vals_snoc {vals : List Value} {i : Nat} (hl : vals.length = i) (v : Value) (j : Nat) (hj : j < i) :
    (vals ++ [v])[j]? = vals[j]? := List.getElem?_append_left (by omega)

theorem vals_last {vals : List Value} {i : Nat} (hl : vals.length = i) (v : Value) : (vals ++ [v])[i]? = some v := by
  subst hl; simp

/-- A node whose value at the run's environment is `v` and whose input keys (if any) are read: the run at `i + 1`. -/
theorem runInv_snoc {i : Nat} {st : AneSt} (h : RunInv P K net n base E i st) (v : Value)
    (hv : evalE P K.toKernelContract (envR net n base st.rb) (ksR P K (envR net n base st.rb)) (listGraph E) i = some v)
    (hseen : ∀ nd k, E[i]? = some nd → nd.prim = .input k → net.split n k ≠ none → st.rb k ≠ none) :
    RunInv P K net n base E (i + 1) { st with vals := st.vals ++ [v] } := by
  refine ⟨by simp [h.len], h.rbTy, fun j hj => ?_, fun j nd k hj hjn hk hs => ?_⟩
  · show (st.vals ++ [v])[j]? = evalE P K.toKernelContract (envR net n base st.rb) (ksR P K (envR net n base st.rb))
      (listGraph E) j
    by_cases hji : j < i
    · rw [vals_snoc h.len v j hji]; exact h.vals j hji
    · rw [show j = i by omega, vals_last h.len, hv]
  · by_cases hji : j < i
    · exact h.seen j nd k hji hjn hk hs
    · exact hseen nd k (by rw [show i = j by omega]; exact hjn) hk hs

theorem inp_seen {i : Nat} {k : AKey} {nd : RNode Int AKey} (hi : E[i]? = some nd) (hp : nd.prim = .input k)
    {P' : AKey → Prop} (h : P' k) : ∀ nd' k', E[i]? = some nd' → nd'.prim = .input k' → P' k' := by
  intro nd' k' h1 h2
  rw [hi] at h1; cases h1
  rw [hp] at h2; cases h2
  exact h

include P K NE IP tapsN in
/-- **One node of the run.** -/
theorem aneNode_ok (hgood : GoodAll P K net n base E) (hsplit : SplitsRun P K NE IP net n base tapsN E) (i : Nat)
    (hi : i < E.length) (st : AneSt) (h : RunInv P K net n base E i st) :
    ∃ st', aneNode P K NE IP net n base tapsN E[i] st = some st' ∧ RunInv P K net n base E (i + 1) st' := by
  obtain ⟨⟨v, hv⟩, hform⟩ := hgood st.rb h.rbTy i hi
  have hEi : E[i]? = some E[i] := List.getElem?_eq_getElem hi
  rcases hform with ⟨k, hp, hins⟩ | hn
  · rw [aneNode_inp P K NE IP net n base tapsN E[i] st k hp hins]
    have hev := evalE_input_at P K E (envR net n base st.rb) hi hp hins
    rw [withRb_inputs] at hev
    cases hr : st.rb k with
    | some y =>
      have hy : evalE P K.toKernelContract (envR net n base st.rb) (ksR P K (envR net n base st.rb)) (listGraph E) i =
          some y := by rw [hev]; simp [rbExt, hr]
      exact ⟨_, rfl, runInv_snoc P K net n base E h y hy
        (inp_seen E hEi hp (P' := fun k => net.split n k ≠ none → st.rb k ≠ none) fun _ => by simp [hr])⟩
    | none =>
      cases hs : net.split n k with
      | some sp =>
        dsimp only
        obtain ⟨y, st', e, hvals, hrb, hy⟩ := hsplit i E[i] k sp st hEi hp hs h hr
        rw [e]
        have hrbk : st'.rb k = some y := by rw [hrb]; simp
        have hext : ∀ k', k' ≠ k → rbExt net n st'.rb k' = rbExt net n st.rb k' := by
          intro k' hk'; simp [rbExt, hrb, hk']
        have hloc : ∀ j < i, evalE P K.toKernelContract (envR net n base st.rb) (ksR P K (envR net n base st.rb))
            (listGraph E) j = evalE P K.toKernelContract (envR net n base st'.rb)
              (ksR P K (envR net n base st'.rb)) (listGraph E) j := by
          intro j hj
          refine evalE_local P K E (envR net n base st.rb) (envR net n base st'.rb) rfl
            (fun j hj' => (hgood st.rb h.rbTy j hj').2) j fun j' hj' nd k' hjn hk' => ?_
          by_cases e' : k' = k
          · rw [e'] at hk'
            exact absurd hr (h.seen j' nd k (by omega) hjn hk' (by rw [hs]; simp))
          · rw [withRb_inputs, withRb_inputs, hext k' e']
        refine ⟨st', rfl, ⟨by simp [hvals, h.len], fun k' y' hk' => ?_, fun j hj => ?_,
          fun j nd k' hj hjn hk' hsp => ?_⟩⟩
        · rw [hrb] at hk'
          by_cases e' : k' = k
          · rw [e'] at hk' ⊢; simp at hk'; subst hk'; exact ⟨sp, hs, hy⟩
          · simp [e'] at hk'; exact h.rbTy k' y' hk'
        · rw [hvals]
          by_cases hji : j < i
          · rw [vals_snoc h.len y j hji, h.vals j hji, hloc j hji]
          · rw [show j = i by omega, vals_last h.len, evalE_input_at P K E _ hi hp hins, withRb_inputs]
            simp [rbExt, hrbk]
        · rw [hrb]
          by_cases e' : k' = k
          · simp [e']
          · simp only [e', ↓reduceIte]
            by_cases hji : j < i
            · exact h.seen j nd k' hji hjn hk' hsp
            · have e : j = i := by omega
              subst e
              rw [hEi] at hjn; cases hjn
              rw [hp] at hk'; cases hk'
              exact absurd rfl e'
      | none =>
        dsimp only
        have hb : base.inputs k = some v := by
          rw [← hv, hev]; simp [rbExt, hr, hs]
        rw [hb, Option.map_some]
        exact ⟨_, rfl, runInv_snoc P K net n base E h v hv
          (inp_seen E hEi hp (P' := fun k => net.split n k ≠ none → st.rb k ≠ none) fun h' => absurd hs h')⟩
  · rw [aneNode_op P K NE IP net n base tapsN E[i] st hn]
    have hv' := hv
    rw [evalE_eq, show listGraph E i = some E[i] from hEi] at hv'
    dsimp only at hv'
    obtain ⟨xs, hxs, hpe⟩ := Option.bind_eq_some_iff.mp hv'
    have hlt : ∀ j ∈ E[i].ins, j < i := by
      intro j hj
      have := mapM_isSome hxs j hj
      by_contra hc
      rw [dite_eq_right hc] at this
      simp at this
    have hm : (E[i].ins.mapM fun j => st.vals[j]?) = some xs := by
      rw [← hxs]
      refine mapM_congr' _ _ _ fun j hj => ?_
      rw [dite_eq_left (hlt j hj), h.vals j (hlt j hj)]
    rw [hm, Option.bind_some, primEvalE_envK P K base (envR net n base st.rb) rfl _ xs hn, hpe, Option.map_some]
    refine ⟨_, rfl, runInv_snoc P K net n base E h v hv fun nd k hjn hk _ => ?_⟩
    rw [hEi] at hjn; cases hjn
    rw [hk] at hn; simp [noInputK] at hn

include P K NE IP tapsN in
theorem aneNodes_from (hgood : GoodAll P K net n base E) (hsplit : SplitsRun P K NE IP net n base tapsN E) :
    ∀ m i (st : AneSt), i + m = E.length → RunInv P K net n base E i st →
      ∃ stF, aneNodes P K NE IP net n base tapsN (E.drop i) st = some stF ∧ RunInv P K net n base E E.length stF
  | 0, i, st, hm, h => ⟨st, by rw [List.drop_eq_nil_of_le (by omega)]; rfl, by rw [← hm]; exact h⟩
  | m + 1, i, st, hm, h => by
    obtain ⟨st1, e1, h1⟩ := aneNode_ok P K NE IP net n base tapsN E hgood hsplit i (by omega) st h
    obtain ⟨stF, e2, h2⟩ := aneNodes_from hgood hsplit m (i + 1) st1 (by omega) h1
    refine ⟨stF, ?_, h2⟩
    rw [List.drop_eq_getElem_cons (by omega), aneNodes, e1, Option.bind_some]
    exact e2

include P K NE IP tapsN in
/-- **The node-by-node run of the graph is defined**, from no readback at any surfaces; its values are the graph's
at the environment holding its readbacks, each typed at its split's geometry. -/
theorem aneNodes_ok (hgood : GoodAll P K net n base E) (hsplit : SplitsRun P K NE IP net n base tapsN E)
    (σ : Nat → Surface) :
    ∃ stF, aneNodes P K NE IP net n base tapsN E ⟨[], fun _ => none, σ, []⟩ = some stF ∧
      RunInv P K net n base E E.length stF := by
  obtain ⟨stF, e, h⟩ := aneNodes_from P K NE IP net n base tapsN E hgood hsplit E.length 0 _ (by omega)
    (runInv_zero P K net n base E σ)
  exact ⟨stF, by simpa using e, h⟩

end

end Host.Mlx.SimGraph.Mach
