import host.simgraph.GenLoadRel
namespace Host.Mlx.SimGraph
open Host.Ts Host.Mlx.FfiEval

/-! # Classifying the conv dimensions of an abstract decode template

A decode template can abstract its conv-output dims: positions `lo … hi`, all `3` at every run, each a table entry `var q`.

* `clsConv S p lo hi`: `clsOf S p`, those positions read as the literal `3`.
* `clsConv_sound`, `embeds_of_runC`, `embeds_of_GRunC`: `clsOf_sound`, `embeds_of_run`, `embeds_of_GRun`, the valuation giving
  those positions `3`. -/

/-- `entryDim`, the conv positions read as `3`. -/
def entryDimC (p lo hi : Nat) (e : SymE) : Option SDim :=
  match entryDim p e with
  | some d => some d
  | none =>
    match e with
    | .var q => if lo ≤ q ∧ q ≤ hi then some (.lit 3) else none
    | _ => none

/-- The template's classifier with its conv positions. -/
def clsConv (S : SSrv) (p lo hi : Nat) : NumV → Option SDim
  | .lit f => (F64.toInt? f).map SDim.lit
  | .ref i => (nth? S.tab i).bind (entryDimC p lo hi)

theorem entryDimC_sound (ρ : Nat → F64) (p lo hi n : Nat) (hρ : ρ p = F64.ofNat n) (hn : n + 1 < 2 ^ 31)
    (h3 : ∀ q, lo ≤ q → q ≤ hi → ρ q = F64.ofNat 3) (e : SymE) (d : SDim) (h : entryDimC p lo hi e = some d) :
    F64.toInt? (e.eval ρ) = some (SDim.eval n d) := by
  unfold entryDimC at h
  cases hd : entryDim p e with
  | some d' =>
    rw [hd] at h
    obtain rfl := Option.some.inj h
    exact entryDim_sound ρ p n hρ hn e _ hd
  | none =>
    rw [hd] at h
    cases e with
    | var q =>
      dsimp only at h
      split at h
      · rename_i hq
        obtain rfl := Option.some.inj h
        simp only [SymE.eval, h3 q hq.1 hq.2]
        rw [F64.toInt_ofNat32 3 (by omega)]
        rfl
      · cases h
    | _ => cases h

/-- **The classifier is sound** at every offset the valuation gives position `p`, the conv positions `3`. -/
theorem clsConv_sound (S : SSrv) (p lo hi : Nat) (ρ : Nat → F64) (n : Nat) (hρ : ρ p = F64.ofNat n) (hn : n + 1 < 2 ^ 31)
    (h3 : ∀ q, lo ≤ q → q ≤ hi → ρ q = F64.ofNat 3) : ClsSound (clsConv S p lo hi) (νsOf S ρ) n := by
  intro x d hx
  cases x with
  | lit f =>
    obtain ⟨i, hi', rfl⟩ := Option.map_eq_some_iff.mp hx
    show (some f).bind F64.toInt? = some i
    exact hi'
  | ref i =>
    obtain ⟨e, he, hd⟩ := Option.bind_eq_some_iff.mp hx
    show ((nth? S.tab i).map (SymE.eval ρ)).bind F64.toInt? = _
    rw [he]
    exact entryDimC_sound ρ p lo hi n hρ hn h3 e d hd

/-- **`embeds_of_run` over the conv positions.** -/
theorem embeds_of_runC (S : SSrv) (p lo hi : Nat) (Ks : KernelSources) (s t : Ffi.St) (n : Nat) (D : Nat → Bool)
    (ρ : Nat → F64) (hρ : ρ p = F64.ofNat n) (hn : n + 1 < 2 ^ 31) (h3 : ∀ q, lo ≤ q → q ≤ hi → ρ q = F64.ofNat 3)
    (νt : NumV → Option F64) (μ : NumV → NumV) (β : Int → Int) (α : Arg → Arg) (η σ : Nat → Nat)
    (hlitμ : ∀ f, μ (.lit f) = .lit f) (hlitt : ∀ f, νt (.lit f) = some f)
    (hnum : ∀ i e, nth? S.tab i = some e → νt (μ (.ref i)) = some (e.eval ρ))
    (A : Arg → Prop) (hα : ∀ a v, A a → Ffi.argNat a = some v → Ffi.argNat (α a) = some v)
    (hargs : ∀ i nd, D i = true → s.nodes.get i = some nd → PrimArgs A nd.prim)
    (hk : ∀ k name, kernelName? Ks s k = some name → kernelName? Ks t (η k) = some name)
    (himg : NativeImage σ (numImg μ β α η) D s t) :
    Embeds σ η (mapG (SDim.eval n) (restrictTo D (symGraph (clsConv S p lo hi) Ks s))) (ffiGraph (concrete νt) Ks t) :=
  embeds_of_image (clsConv S p lo hi) Ks s t n D (νsOf S ρ) νt μ β α η σ hlitμ hlitt
    (numbers_agree S ρ μ νt hlitμ hlitt hnum) (clsConv_sound S p lo hi ρ n hρ hn h3) A hα hargs hk himg

/-- **`embeds_of_GRun` over the conv positions.** -/
theorem embeds_of_GRunC (S : SSrv) (p lo hi : Nat) (Ks : KernelSources)
    {P : Sim.LoadP} {NB : Nat} {M : Sim.Map} {n : Nat} {x y : Sim.NSt} (hr : Sim.G.MR P NB M n x y)
    (time : Nat) (D : Nat → Bool) (ρ : Nat → F64) (hρ : ρ p = F64.ofNat time) (hn : time + 1 < 2 ^ 31)
    (h3 : ∀ q, lo ≤ q → q ≤ hi → ρ q = F64.ofNat 3)
    (νt : NumV → Option F64) (hlitt : ∀ f, νt (.lit f) = some f)
    (hnum : ∀ i e, nth? S.tab i = some e → νt (M.nv (.ref i)) = some (e.eval ρ))
    (A : Arg → Prop) (hα : ∀ a v, A a → Ffi.argNat a = some v → Ffi.argNat (M.arg a) = some v)
    (hargs : ∀ i nd, D i = true → x.nodes.get i = some nd → PrimArgs A nd.prim)
    (hD : ∀ i, D i = true → Sim.Full P i)
    (hExact : ∀ i nd, D i = true → x.nodes.get i = some nd → Sim.G.shapeOnly nd = false) :
    Embeds M.node M.handle
      (mapG (SDim.eval time) (restrictTo D (symGraph (clsConv S p lo hi) Ks x)))
      (ffiGraph (concrete νt) Ks y) :=
  embeds_of_runC S p lo hi Ks x y time D ρ hρ hn h3 νt M.nv M.big M.arg M.handle M.node
    (nv_lit M) hlitt hnum A hα hargs (kernels_of_GMR hr Ks) (nativeImage_of_GMR hr D hD hExact)

end Host.Mlx.SimGraph
