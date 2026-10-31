import host.simgraph.LoadRel
import host.sim.native.gen.Rel
namespace Host.Mlx.SimGraph
open Host.Ts Host.Ts.Sim Host.Mlx Host.Mlx.FfiEval
open Host.Mlx.Ffi (Node)

/-! # Exact graph correspondence for the general native relation

`G.MR` keeps kernel objects, node shapes, inputs and order, but permits arbitrary
target bytes at shape-only host-data nodes. Exact graph embeddings therefore
use a source domain that excludes those nodes. -/

/-- The general native relation keeps every route kernel object. -/
theorem kernels_of_GMR {P : LoadP} {NB : Nat} {M : Map} {n : Nat} {x y : NSt}
    (hr : G.MR P NB M n x y) (Ks : KernelSources) :
    ∀ k name, kernelName? Ks x k = some name → kernelName? Ks y (M.handle k) = some name := by
  intro k name hk
  unfold kernelName? at hk ⊢
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

/-- Exact native images on full bands require excluding present shape-only nodes. -/
theorem nativeImage_of_GMR {P : LoadP} {NB : Nat} {M : Map} {n : Nat} {x y : NSt}
    (hr : G.MR P NB M n x y) (D : Nat → Bool)
    (hD : ∀ i, D i = true → Full P i)
    (hExact : ∀ i nd, D i = true → x.nodes.get i = some nd → G.shapeOnly nd = false) :
    NativeImage M.node (loadImg M) D x y where
  nodes := by
    intro i nd hi hn
    obtain ⟨nd', h1, hs, hd, _, hf⟩ := hr.nodes i nd hn
    obtain ⟨hprim, hins⟩ := hf (hD i hi)
    have hp := G.PrimR.exact hprim (hExact i nd hi hn)
    rw [h1, nodeI_map]
    obtain ⟨p', ins', sh', dt'⟩ := nd'
    simp only at hp hins hs hd
    subst hp hins hs hd
    rfl
  order := by
    intro i j hi hp hj
    exact hr.norder i hp (hD i hi) j hj

/-- The template domain restricted to exact source primitives. Absent source nodes
pass this extra test; present shape-only host data never do. -/
def exactTplDom (NL N0 : Nat) (fixed : List Int) (x : Ffi.St) (i : Nat) : Bool :=
  tplDom NL N0 fixed x i && match x.nodes.get i with
    | some nd => !G.shapeOnly nd
    | none => true

theorem exactTplDom_tplDom {NL N0 : Nat} {fixed : List Int} {x : Ffi.St} {i : Nat}
    (h : exactTplDom NL N0 fixed x i = true) : tplDom NL N0 fixed x i = true := by
  simp only [exactTplDom, Bool.and_eq_true] at h
  exact h.1

theorem exactTplDom_band {NL N0 : Nat} {fixed : List Int} {x : Ffi.St} {i : Nat}
    (h : exactTplDom NL N0 fixed x i = true) : i < NL ∨ N0 ≤ i :=
  tplDom_band (exactTplDom_tplDom h)

theorem exactTplDom_args {NL N0 : Nat} {fixed : List Int} {x : Ffi.St} {i : Nat} {nd : Node}
    (h : exactTplDom NL N0 fixed x i = true) (hn : x.nodes.get i = some nd) :
    PrimArgs (fun a => okArg fixed a = true) nd.prim :=
  tplDom_args (exactTplDom_tplDom h) hn

theorem exactTplDom_exact {NL N0 : Nat} {fixed : List Int} {x : Ffi.St} {i : Nat} {nd : Node}
    (h : exactTplDom NL N0 fixed x i = true) (hn : x.nodes.get i = some nd) :
    G.shapeOnly nd = false := by
  simp only [exactTplDom, hn, Bool.and_eq_true, Bool.not_eq_true'] at h
  exact h.2

theorem exactTplDom_none {NL N0 : Nat} {fixed : List Int} {x : Ffi.St} {i : Nat}
    (hn : x.nodes.get i = none) :
    exactTplDom NL N0 fixed x i = (decide (i < NL) || decide (N0 ≤ i)) := by
  simp [exactTplDom, tplDom, hn]

theorem exactTplDom_full {P : LoadP} {NL N0 : Nat} {fixed : List Int} {x : Ffi.St} {i : Nat}
    (hNL : NL ≤ P.NL) (hN0 : P.N0 ≤ N0) (h : exactTplDom NL N0 fixed x i = true) : Full P i := by
  rcases exactTplDom_band h with hi | hi
  · exact .inl (Nat.lt_of_lt_of_le hi hNL)
  · exact .inr (Nat.le_trans hN0 hi)

theorem nativeImage_of_GMR_exactTplDom {P : LoadP} {NB NL N0 : Nat} {M : Map} {n : Nat} {x y : NSt}
    (hr : G.MR P NB M n x y) (fixed : List Int) (hNL : NL ≤ P.NL) (hN0 : P.N0 ≤ N0) :
    NativeImage M.node (loadImg M) (exactTplDom NL N0 fixed x) x y :=
  nativeImage_of_GMR hr _ (fun _ hi => exactTplDom_full hNL hN0 hi)
    (fun _ _ hi hn => exactTplDom_exact hi hn)

/-- The existing numerical and argument agreement gives an embedding under
`G.MR` on any full, exact source domain. -/
theorem embeds_of_GRun (S : SSrv) (p : Nat) (Ks : KernelSources)
    {P : LoadP} {NB : Nat} {M : Map} {n : Nat} {x y : NSt} (hr : G.MR P NB M n x y)
    (time : Nat) (D : Nat → Bool) (ρ : Nat → F64) (hρ : ρ p = F64.ofNat time) (hn : time + 1 < 2 ^ 31)
    (νt : NumV → Option F64) (hlitt : ∀ f, νt (.lit f) = some f)
    (hnum : ∀ i e, nth? S.tab i = some e → νt (M.nv (.ref i)) = some (e.eval ρ))
    (A : Arg → Prop) (hα : ∀ a v, A a → Ffi.argNat a = some v → Ffi.argNat (M.arg a) = some v)
    (hargs : ∀ i nd, D i = true → x.nodes.get i = some nd → PrimArgs A nd.prim)
    (hD : ∀ i, D i = true → Full P i)
    (hExact : ∀ i nd, D i = true → x.nodes.get i = some nd → G.shapeOnly nd = false) :
    Embeds M.node M.handle
      (mapG (SDim.eval time) (restrictTo D (symGraph (clsOf S p) Ks x)))
      (ffiGraph (concrete νt) Ks y) :=
  embeds_of_run S p Ks x y time D ρ hρ hn νt M.nv M.big M.arg M.handle M.node
    (nv_lit M) hlitt hnum A hα hargs (kernels_of_GMR hr Ks) (nativeImage_of_GMR hr D hD hExact)

end Host.Mlx.SimGraph
