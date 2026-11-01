import host.simgraph.GenLoadRel
namespace Host.Mlx.SimGraph
open Host.Ts Host.Mlx.FfiEval

/-! # Classifying the abstracted dimensions of a decode template

A decode template can hold some dims as variables, each with one value at every run: its conv-output dims and trace dims. `pin q` is
variable `q`'s value.

* `clsConv S p pin`: `clsOf S p`, those variables read as their literals.
* `clsConv_sound`, `embeds_of_runC`, `embeds_of_GRunC`: `clsOf_sound`, `embeds_of_run`, `embeds_of_GRun`, at a valuation giving those variables
  their values. -/

/-- `entryDim`, the pinned variables read as their values. -/
def entryDimC (p : Nat) (pin : Nat → Option Nat) (e : SymE) : Option SDim :=
  match entryDim p e with
  | some d => some d
  | none =>
    match e with
    | .var q => (pin q).map fun k : Nat => SDim.lit (Int.ofNat k)
    | _ => none

/-- The template's classifier with its pinned variables. -/
def clsConv (S : SSrv) (p : Nat) (pin : Nat → Option Nat) : NumV → Option SDim
  | .lit f => (F64.toInt? f).map SDim.lit
  | .ref i => (nth? S.tab i).bind (entryDimC p pin)

theorem entryDimC_sound (ρ : Nat → F64) (p n : Nat) (pin : Nat → Option Nat) (hρ : ρ p = F64.ofNat n) (hn : n + 1 < 2 ^ 31)
    (hpin : ∀ q k, pin q = some k → k < 2 ^ 31 ∧ ρ q = F64.ofNat k) (e : SymE) (d : SDim) (h : entryDimC p pin e = some d) :
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
      obtain ⟨k, hk, hde⟩ := Option.map_eq_some_iff.mp h
      subst hde
      obtain ⟨hb, hv⟩ := hpin q k hk
      simp only [SymE.eval, hv]
      rw [F64.toInt_ofNat32 k hb]
      rfl
    | _ => cases h

/-- **The classifier is sound** at every offset the valuation gives position `p`, the pinned variables their values. -/
theorem clsConv_sound (S : SSrv) (p : Nat) (pin : Nat → Option Nat) (ρ : Nat → F64) (n : Nat) (hρ : ρ p = F64.ofNat n)
    (hn : n + 1 < 2 ^ 31) (hpin : ∀ q k, pin q = some k → k < 2 ^ 31 ∧ ρ q = F64.ofNat k) :
    ClsSound (clsConv S p pin) (νsOf S ρ) n := by
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
    exact entryDimC_sound ρ p n pin hρ hn hpin e d hd

/-- **`embeds_of_run` over the pinned variables.** -/
theorem embeds_of_runC (S : SSrv) (p : Nat) (pin : Nat → Option Nat) (Ks : KernelSources) (s t : Ffi.St) (n : Nat) (D : Nat → Bool)
    (ρ : Nat → F64) (hρ : ρ p = F64.ofNat n) (hn : n + 1 < 2 ^ 31) (hpin : ∀ q k, pin q = some k → k < 2 ^ 31 ∧ ρ q = F64.ofNat k)
    (νt : NumV → Option F64) (μ : NumV → NumV) (β : Int → Int) (α : Arg → Arg) (η σ : Nat → Nat)
    (hlitμ : ∀ f, μ (.lit f) = .lit f) (hlitt : ∀ f, νt (.lit f) = some f)
    (hnum : ∀ i e, nth? S.tab i = some e → νt (μ (.ref i)) = some (e.eval ρ))
    (A : Arg → Prop) (hα : ∀ a v, A a → Ffi.argNat a = some v → Ffi.argNat (α a) = some v)
    (hargs : ∀ i nd, D i = true → s.nodes.get i = some nd → PrimArgs A nd.prim)
    (hk : ∀ k name, kernelName? Ks s k = some name → kernelName? Ks t (η k) = some name)
    (himg : NativeImage σ (numImg μ β α η) D s t) :
    Embeds σ η (mapG (SDim.eval n) (restrictTo D (symGraph (clsConv S p pin) Ks s))) (ffiGraph (concrete νt) Ks t) :=
  embeds_of_image (clsConv S p pin) Ks s t n D (νsOf S ρ) νt μ β α η σ hlitμ hlitt
    (numbers_agree S ρ μ νt hlitμ hlitt hnum) (clsConv_sound S p pin ρ n hρ hn hpin) A hα hargs hk himg

/-- **`embeds_of_GRun` over the pinned variables.** -/
theorem embeds_of_GRunC (S : SSrv) (p : Nat) (pin : Nat → Option Nat) (Ks : KernelSources)
    {P : Sim.LoadP} {NB : Nat} {M : Sim.Map} {n : Nat} {x y : Sim.NSt} (hr : Sim.G.MR P NB M n x y)
    (time : Nat) (D : Nat → Bool) (ρ : Nat → F64) (hρ : ρ p = F64.ofNat time) (hn : time + 1 < 2 ^ 31)
    (hpin : ∀ q k, pin q = some k → k < 2 ^ 31 ∧ ρ q = F64.ofNat k)
    (νt : NumV → Option F64) (hlitt : ∀ f, νt (.lit f) = some f)
    (hnum : ∀ i e, nth? S.tab i = some e → νt (M.nv (.ref i)) = some (e.eval ρ))
    (A : Arg → Prop) (hα : ∀ a v, A a → Ffi.argNat a = some v → Ffi.argNat (M.arg a) = some v)
    (hargs : ∀ i nd, D i = true → x.nodes.get i = some nd → PrimArgs A nd.prim)
    (hD : ∀ i, D i = true → Sim.Full P i)
    (hExact : ∀ i nd, D i = true → x.nodes.get i = some nd → Sim.G.shapeOnly nd = false) :
    Embeds M.node M.handle
      (mapG (SDim.eval time) (restrictTo D (symGraph (clsConv S p pin) Ks x)))
      (ffiGraph (concrete νt) Ks y) :=
  embeds_of_runC S p pin Ks x y time D ρ hρ hn hpin νt M.nv M.big M.arg M.handle M.node
    (nv_lit M) hlitt hnum A hα hargs (kernels_of_GMR hr Ks) (nativeImage_of_GMR hr D hD hExact)

end Host.Mlx.SimGraph
