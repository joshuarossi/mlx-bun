import host.simgraph.GenLoadRel
namespace Host.Mlx.SimGraph
open Host.Ts Host.Mlx.FfiEval

/-! # Classifying the abstracted dimensions of a decode template

A decode template can hold some dims as variables, each with one value at every run: its conv-output dims and trace dims. `pin q` is
variable `q`'s value.

* `clsConv S p pin`: `clsOf S p`, entries closed under the pins read as their values (an iteration leaves such a dim as `int32((v + 1) - 1)`).
* `pinByte`, `pinGraph`: the template's graph, its host bytes read the same way.
* `clsConv_sound`, `embeds_of_runC`, `embeds_of_GRunC`: `clsOf_sound`, `embeds_of_run`, `embeds_of_GRun`, at a valuation giving those variables
  their values. -/

/-- Every variable of the entry is pinned. -/
def pinClosed (pin : Nat → Option Nat) : SymE → Bool
  | .lit _ => true
  | .var q => (pin q).isSome
  | .bin _ a b => pinClosed pin a && pinClosed pin b
  | .un _ a => pinClosed pin a

/-- The pins as a valuation. -/
def pinAt (pin : Nat → Option Nat) : Nat → F64 := fun q =>
  match pin q with
  | some k => F64.ofNat k
  | none => F64.ofNat 0

/-- An entry closed under the pins has their value at any valuation with them. -/
theorem pinClosed_eval {pin : Nat → Option Nat} {ρ : Nat → F64} (hpin : ∀ q k, pin q = some k → ρ q = F64.ofNat k) :
    ∀ e : SymE, pinClosed pin e = true → e.eval ρ = e.eval (pinAt pin)
  | .lit _, _ => rfl
  | .var q, h => by
    cases hq : pin q with
    | none => simp [pinClosed, hq] at h
    | some k => simp only [SymE.eval, pinAt, hq, hpin q k hq]
  | .bin op a b, h => by
    simp only [pinClosed, Bool.and_eq_true] at h
    simp only [SymE.eval, pinClosed_eval hpin a h.1, pinClosed_eval hpin b h.2]
  | .un op a, h => by
    simp only [SymE.eval, pinClosed_eval hpin a h]

/-- `entryDim`, entries closed under the pins read as their values. -/
def entryDimC (p : Nat) (pin : Nat → Option Nat) (e : SymE) : Option SDim :=
  match entryDim p e with
  | some d => some d
  | none => bif pinClosed pin e then (F64.toInt? (e.eval (pinAt pin))).map SDim.lit else none

/-- The template's classifier with its pinned variables. -/
def clsConv (S : SSrv) (p : Nat) (pin : Nat → Option Nat) : NumV → Option SDim
  | .lit f => (F64.toInt? f).map SDim.lit
  | .ref i => (nth? S.tab i).bind (entryDimC p pin)

theorem entryDimC_sound (ρ : Nat → F64) (p n : Nat) (pin : Nat → Option Nat) (hρ : ρ p = F64.ofNat n) (hn : n + 1 < 2 ^ 31)
    (hpin : ∀ q k, pin q = some k → ρ q = F64.ofNat k) (e : SymE) (d : SDim) (h : entryDimC p pin e = some d) :
    F64.toInt? (e.eval ρ) = some (SDim.eval n d) := by
  unfold entryDimC at h
  cases hd : entryDim p e with
  | some d' =>
    rw [hd] at h
    obtain rfl := Option.some.inj h
    exact entryDim_sound ρ p n hρ hn e _ hd
  | none =>
    rw [hd] at h
    cases hc : pinClosed pin e with
    | false =>
      dsimp only at h
      rw [hc] at h
      cases h
    | true =>
      dsimp only at h
      rw [hc, cond_true] at h
      obtain ⟨i, hi, rfl⟩ := Option.map_eq_some_iff.mp h
      rw [pinClosed_eval hpin e hc]
      exact hi

/-- **The classifier is sound** at every offset the valuation gives position `p`, the pinned variables their values. -/
theorem clsConv_sound (S : SSrv) (p : Nat) (pin : Nat → Option Nat) (ρ : Nat → F64) (n : Nat) (hρ : ρ p = F64.ofNat n)
    (hn : n + 1 < 2 ^ 31) (hpin : ∀ q k, pin q = some k → ρ q = F64.ofNat k) :
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

/-- A number's value where it is closed under the pins. -/
def pinNum (S : SSrv) (pin : Nat → Option Nat) : NumV → Option F64
  | .lit f => some f
  | .ref i => (nth? S.tab i).bind fun e => bif pinClosed pin e then some (e.eval (pinAt pin)) else none

/-- Numeric cells read through the pins, bigint cells refused. -/
def pinByte (S : SSrv) (pin : Nat → Option Nat) : Byte → Option Nat
  | .lit b => some b
  | .part k (.num x) i => concreteByte (pinNum S pin) (.part k (.num x) i)
  | .part _ (.big _) _ => none

/-- The template's reading with its pins: dimensions through `clsConv`, host bytes through `pinByte`. -/
def pinNums (S : SSrv) (p : Nat) (pin : Nat → Option Nat) : Nums SDim :=
  { symNums (clsConv S p pin) with byte := pinByte S pin }

/-- The template graph with its pins. -/
def pinGraph (S : SSrv) (p : Nat) (pin : Nat → Option Nat) (Ks : KernelSources) (s : Ffi.St) : Nat → Option (RNode SDim InKey) :=
  ffiGraph (pinNums S p pin) Ks s

theorem pinNum_sound (S : SSrv) {pin : Nat → Option Nat} {ρ : Nat → F64} (hpin : ∀ q k, pin q = some k → ρ q = F64.ofNat k) (x : NumV) (f : F64)
    (hf : pinNum S pin x = some f) : νsOf S ρ x = some f := by
  cases x with
  | lit g => exact hf
  | ref i =>
    obtain ⟨e, he, hc⟩ := Option.bind_eq_some_iff.mp hf
    cases hcl : pinClosed pin e with
    | false => rw [hcl] at hc; cases hc
    | true =>
      rw [hcl, cond_true] at hc
      obtain rfl := Option.some.inj hc
      show (nth? S.tab i).map (SymE.eval ρ) = _
      rw [he, Option.map_some, pinClosed_eval hpin e hcl]

/-- **The template's reading with its pins agrees with the iteration's concrete one.** -/
theorem pin_agree (S : SSrv) (p : Nat) (pin : Nat → Option Nat) (ρ : Nat → F64) (n : Nat) (hρ : ρ p = F64.ofNat n) (hn : n + 1 < 2 ^ 31)
    (hpin : ∀ q k, pin q = some k → ρ q = F64.ofNat k)
    (νt : NumV → Option F64) (μ : NumV → NumV) (β : Int → Int) (α : Arg → Arg) (η : Nat → Nat)
    (hlitμ : ∀ f, μ (.lit f) = .lit f) (hlitt : ∀ f, νt (.lit f) = some f)
    (hν : ∀ x f, νsOf S ρ x = some f → νt (μ x) = some f)
    (A : Arg → Prop) (hα : ∀ a v, A a → Ffi.argNat a = some v → Ffi.argNat (α a) = some v)
    (kn kn' : Nat → Option (List Char)) (hk : ∀ k name, kn k = some name → kn' (η k) = some name) :
    Agree (pinNums S p pin) (concrete νt) (SDim.eval n) (numImg μ β α η) kn kn' A := by
  have base := agree_run (clsConv S p pin) (νsOf S ρ) νt n μ β α η hlitμ hlitt hν (clsConv_sound S p pin ρ n hρ hn hpin) A hα kn kn' hk
  refine ⟨base.d, base.dim, base.word, ?_, hα, hk⟩
  intro b v hb
  cases b with
  | lit m => exact hb
  | part k c i =>
    cases c with
    | big m => simp [pinNums, pinByte] at hb
    | num x =>
      change concreteByte (pinNum S pin) (.part k (.num x) i) = some v at hb
      change concreteByte νt (.part k (.num (μ x)) i) = some v
      cases hv : pinNum S pin x with
      | none => simp [concreteByte, concreteCell, hv] at hb
      | some f =>
        have ht := hν x f (pinNum_sound S hpin x f hv)
        simpa only [concreteByte, concreteCell, ht, hv, Option.map_some] using
          (show concreteByte (pinNum S pin) (.part k (.num x) i) = some v from hb)

/-- **`embeds_of_run` over the pinned variables.** -/
theorem embeds_of_runC (S : SSrv) (p : Nat) (pin : Nat → Option Nat) (Ks : KernelSources) (s t : Ffi.St) (n : Nat) (D : Nat → Bool)
    (ρ : Nat → F64) (hρ : ρ p = F64.ofNat n) (hn : n + 1 < 2 ^ 31) (hpin : ∀ q k, pin q = some k → ρ q = F64.ofNat k)
    (νt : NumV → Option F64) (μ : NumV → NumV) (β : Int → Int) (α : Arg → Arg) (η σ : Nat → Nat)
    (hlitμ : ∀ f, μ (.lit f) = .lit f) (hlitt : ∀ f, νt (.lit f) = some f)
    (hnum : ∀ i e, nth? S.tab i = some e → νt (μ (.ref i)) = some (e.eval ρ))
    (A : Arg → Prop) (hα : ∀ a v, A a → Ffi.argNat a = some v → Ffi.argNat (α a) = some v)
    (hargs : ∀ i nd, D i = true → s.nodes.get i = some nd → PrimArgs A nd.prim)
    (hk : ∀ k name, kernelName? Ks s k = some name → kernelName? Ks t (η k) = some name)
    (himg : NativeImage σ (numImg μ β α η) D s t) :
    Embeds σ η (mapG (SDim.eval n) (restrictTo D (pinGraph S p pin Ks s))) (ffiGraph (concrete νt) Ks t) where
  node := by
    intro i r hr
    obtain ⟨r0, h0, rfl⟩ := Option.map_eq_some_iff.mp hr
    have hb : D i = true := by
      cases hd : D i
      · simp [restrictTo, hd] at h0
      · rfl
    simp only [restrictTo, hb, ↓reduceIte] at h0
    obtain ⟨nd, hnd, hres⟩ := Option.bind_eq_some_iff.mp h0
    have h2 := resolveNode_img (pin_agree S p pin ρ n hρ hn hpin νt μ β α η hlitμ hlitt
      (numbers_agree S ρ μ νt hlitμ hlitt hnum) A hα _ _ hk) σ nd r0 (hargs i nd hb hnd) hres
    show (t.nodes.get (σ i)).bind _ = _
    rw [himg.nodes i nd hb hnd, Option.bind_some]
    exact h2
  order := by
    intro i j hi hj
    have hb : D i = true := by
      cases hd : D i
      · simp [mapG, restrictTo, hd] at hi
      · rfl
    apply himg.order i j hb _ hj
    simp only [mapG, restrictTo, hb, ↓reduceIte, pinGraph, ffiGraph, Option.isSome_map] at hi
    cases hs : s.nodes.get i with
    | none => rw [hs] at hi; cases hi
    | some _ => rfl

/-- **`embeds_of_GRun` over the pinned variables.** -/
theorem embeds_of_GRunC (S : SSrv) (p : Nat) (pin : Nat → Option Nat) (Ks : KernelSources)
    {P : Sim.LoadP} {NB : Nat} {M : Sim.Map} {n : Nat} {x y : Sim.NSt} (hr : Sim.G.MR P NB M n x y)
    (time : Nat) (D : Nat → Bool) (ρ : Nat → F64) (hρ : ρ p = F64.ofNat time) (hn : time + 1 < 2 ^ 31)
    (hpin : ∀ q k, pin q = some k → ρ q = F64.ofNat k)
    (νt : NumV → Option F64) (hlitt : ∀ f, νt (.lit f) = some f)
    (hnum : ∀ i e, nth? S.tab i = some e → νt (M.nv (.ref i)) = some (e.eval ρ))
    (A : Arg → Prop) (hα : ∀ a v, A a → Ffi.argNat a = some v → Ffi.argNat (M.arg a) = some v)
    (hargs : ∀ i nd, D i = true → x.nodes.get i = some nd → PrimArgs A nd.prim)
    (hD : ∀ i, D i = true → Sim.Full P i)
    (hExact : ∀ i nd, D i = true → x.nodes.get i = some nd → Sim.G.shapeOnly nd = false) :
    Embeds M.node M.handle
      (mapG (SDim.eval time) (restrictTo D (pinGraph S p pin Ks x)))
      (ffiGraph (concrete νt) Ks y) :=
  embeds_of_runC S p pin Ks x y time D ρ hρ hn hpin νt M.nv M.big M.arg M.handle M.node
    (nv_lit M) hlitt hnum A hα hargs (kernels_of_GMR hr Ks) (nativeImage_of_GMR hr D hD hExact)

end Host.Mlx.SimGraph
