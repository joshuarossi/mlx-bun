import host.simgraph.prompt.ChooseRoute
namespace Host.Mlx.SimGraph
open Host.Ts Host.Ts.Sim Host.Mlx Host.Mlx.FfiEval
open Host.Mlx.Ffi (Prim Node)

/-! # A forward's end state embeds in the route's graph

`embeds_of_runR`: `embeds_of_runP` at the route's kernel table and the exact-quotient classifier: a template state read on
`routeDom` carries the target's route-resolved graph at every valuation in the box. `routeKernels_of_GMR`,
`nativeImage_of_routeDom`: the native relation gives its premises. -/

/-- The general native relation keeps the route's kernel objects. -/
theorem routeKernels_of_GMR {P : LoadP} {NB : Nat} {M : Map} {n : Nat} {x y : NSt}
    (hr : G.MR P NB M n x y) (Ks : KernelSources) :
    ∀ k name, routeKernelName? Ks x k = some name → routeKernelName? Ks y (M.handle k) = some name := by
  intro k name hk
  unfold routeKernelName? at hk ⊢
  cases ho : x.objs.get k with
  | none => simp [Ffi.St.obj?, ho] at hk
  | some o =>
    have hpres : PH x k := .inr (by simp [ho])
    have hy := hr.objs k hpres
    rw [ho] at hy
    simp only [Ffi.St.obj?, ho] at hk
    cases o with
    | kernel nm src hdr a b =>
      simp only [Ffi.St.obj?, hy, Option.map_some, Map.nobj]
      exact hk
    | _ => simp at hk

theorem routeDom_exact {NL N0 : Nat} {fixed : List Int} {x : Ffi.St} {i : Nat} (h : routeDom NL N0 fixed x i = true) :
    exactTplDom NL N0 fixed x i = true := by
  simp only [routeDom, Bool.and_eq_true] at h
  exact h.1

theorem routeDom_arange {NL N0 : Nat} {fixed : List Int} {x : Ffi.St} {i : Nat} {nd : Node}
    (h : routeDom NL N0 fixed x i = true) (hn : x.nodes.get i = some nd) : notArange nd.prim = true := by
  simp only [routeDom, hn, Bool.and_eq_true] at h
  exact h.2

/-- The native image on the certificate's domain. -/
theorem nativeImage_of_routeDom {P : LoadP} {NB NL N0 : Nat} {M : Map} {n : Nat} {x y : NSt}
    (hr : G.MR P NB M n x y) (fixed : List Int) (hNL : NL ≤ P.NL) (hN0 : P.N0 ≤ N0)
    (hDown : ∀ i nd, routeDom NL N0 fixed x i = true → x.nodes.get i = some nd → ∀ j ∈ nd.ins, j < i) :
    NativeImage M.node (loadImg M) (routeDom NL N0 fixed x) x y :=
  nativeImage_of_GMR hr _ (fun _ hi => exactTplDom_full hNL hN0 (routeDom_exact hi))
    (fun _ _ hi hn => exactTplDom_exact (routeDom_exact hi) hn) hDown

theorem underReplay_primI (I : SynImg) : ∀ p : Prim, notArange p = true → ∀ a b c, underReplay (primI I p) ≠ .arange a b c
  | .arange _ _ _, h, _, _, _ => by simp [notArange] at h
  | .replayed _ p, h, a, b, c => underReplay_primI I p h a b c
  | .data _, _, _, _, _ | .load _ _, _, _, _, _ | .tracer _, _, _, _, _ | .zeros, _, _, _, _ | .reshape _, _, _, _, _
  | .transpose _, _, _, _, _ | .slice _ _ _, _, _, _, _ | .sliceUpdate _ _ _, _, _, _, _ | .sliceDynamic _ _, _, _, _, _
  | .concat _, _, _, _, _ | .unary _, _, _, _, _ | .binary _, _, _, _, _ | .astype _, _, _, _, _ | .contiguous, _, _, _, _
  | .rmsNorm _, _, _, _, _ | .rope _ _ _ _ _, _, _, _, _ | .sdpa _ _, _, _, _, _ | .qmm _ _ _ _, _, _, _, _
  | .dequantize _ _ _ _, _, _, _, _ | .take _, _, _, _, _ | .conv1d _ _ _ _, _, _, _, _ | .logsumexp _ _, _, _, _, _
  | .kernel _ _ _, _, _, _, _ => by simp [primI, underReplay]

/-- **The template run carries the target's route graph at every valuation in the box.** -/
theorem embeds_of_runR {κ : Type} (S : SSrv) (B : Box) (Ks : KernelSources) (s t : Ffi.St) (D : Nat → Bool)
    (ν : Nat → Int) (ρ : Nat → F64) (hB : InBox B ν)
    (hρ : ∀ x l h, B.get x = some (l, h) → ρ x = F64.ofInt (ν x))
    (νt : NumV → Option F64) (μ : NumV → NumV) (β : Int → Int) (α : Arg → Arg) (η σ : Nat → Nat)
    (hlitμ : ∀ f, μ (.lit f) = .lit f) (hlitt : ∀ f, νt (.lit f) = some f)
    (hnum : ∀ i e, nth? S.tab i = some e → νt (μ (.ref i)) = some (e.eval ρ))
    (A : Arg → Prop) (hα : ∀ a v, A a → Ffi.argNat a = some v → Ffi.argNat (α a) = some v)
    (hargs : ∀ i nd, D i = true → s.nodes.get i = some nd → PrimArgs A nd.prim)
    (hna : ∀ i nd, D i = true → s.nodes.get i = some nd → notArange nd.prim = true)
    (hk : ∀ k name, routeKernelName? Ks s k = some name → routeKernelName? Ks t (η k) = some name)
    (himg : NativeImage σ (numImg μ β α η) D s t) :
    Embeds (κ := κ) σ η (mapG (PDim.eval ν) (restrictTo D (symGraphR (clsOfX S B) PDim.lit Ks s)))
      (ffiGraphR (concrete νt) Ks t) where
  node := by
    intro i r hr
    obtain ⟨r0, h0, rfl⟩ := Option.map_eq_some_iff.mp hr
    have hb : D i = true := by
      cases hd : D i
      · simp [restrictTo, hd] at h0
      · rfl
    simp only [restrictTo, hb, ↓reduceIte] at h0
    obtain ⟨nd, hnd, hres⟩ := Option.bind_eq_some_iff.mp h0
    have h2 := resolveNode_img (agree_runD (clsOfX S B) PDim.lit (PDim.eval ν) (fun _ => rfl) (νsOf S ρ) νt μ β α η hlitμ hlitt
      (numbers_agree S ρ μ νt hlitμ hlitt hnum) (clsOfX_sound S B ν ρ hB hρ) A hα _ _ hk) σ nd r0
      (hargs i nd hb hnd) hres
    show (t.nodes.get (σ i)).bind _ = _
    rw [himg.nodes i nd hb hnd, Option.bind_some]
    unfold resolveNodeP
    have hP : resolvePrimP (κ := κ) (concrete νt) (routeKernelName? Ks t) (nodeI σ (numImg μ β α η) nd).shape
        (nodeI σ (numImg μ β α η) nd).dtype (nodeI σ (numImg μ β α η) nd).prim =
        resolvePrim (concrete νt) (routeKernelName? Ks t) (nodeI σ (numImg μ β α η) nd).shape
          (nodeI σ (numImg μ β α η) nd).dtype (nodeI σ (numImg μ β α η) nd).prim :=
      resolvePrimP_eq _ _ _ _ _ (underReplay_primI _ nd.prim (hna i nd hb hnd))
    rw [hP]
    exact h2
  order i r hr j hj := by
    obtain ⟨r0, h0, rfl⟩ := Option.map_eq_some_iff.mp hr
    have hb : D i = true := by
      cases hd : D i
      · simp [restrictTo, hd] at h0
      · rfl
    simp only [restrictTo, hb, ↓reduceIte] at h0
    obtain ⟨nd, hnd, hres⟩ := Option.bind_eq_some_iff.mp h0
    obtain ⟨_, _, rfl⟩ := Option.map_eq_some_iff.mp hres
    exact himg.order i nd hb hnd j hj

end Host.Mlx.SimGraph
