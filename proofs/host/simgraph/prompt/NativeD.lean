import host.simgraph.prompt.Normalize
namespace Host.Mlx.SimGraph
open Host.Mlx Host.Mlx.FfiEval Host.Ts
open Host.Mlx.Ffi (Dim Prim Node Cfg dimOf)

/-! # Template native states at any dimension type

`symNums`, `agree_run` and `embeds_of_image` (Native.lean) read a template
state's dimensions as `SDim` and evaluate them at one offset. Here the same
at any dimension type `δ` with literals `lit` and an evaluation `ev`
(`ev (lit i) = i`); the decode versions are the instances
`δ = SDim`, `ev = SDim.eval n` (`symNums_eq`, `clsSound_eq`).

* `embeds_of_imageD`: an iteration state containing the template's nodes on
  `D` carries the template graph read through `cls`, evaluated by `ev`;
* `embeds_of_runP`: with `δ = PDim` and the classifier `clsOfP S B` of the
  template's table at a valuation `ν` in the box `B` (`Classify.embeds_of_run`
  for several symbolic parameters). -/

/-- The template's reading: dimensions through `cls`, f32 words and host
bytes only when literal. -/
def symNumsD {δ : Type} (cls : NumV → Option δ) (lit : Int → δ) : Nums δ :=
  ⟨cls, fun x => (litVal x).map fun f => F64.f32Bits (F64.toF32 f), lit, symByte⟩

theorem symNums_eq (cls : NumV → Option SDim) : symNums cls = symNumsD cls SDim.lit := rfl

/-- The template graph read through `cls`. -/
def symGraphD {δ κ : Type} (cls : NumV → Option δ) (lit : Int → δ) (Ks : KernelSources) (s : Ffi.St) :
    Nat → Option (RNode δ κ) :=
  ffiGraph (symNumsD cls lit) Ks s

theorem symGraph_eq (cls : NumV → Option SDim) (Ks : KernelSources) (s : Ffi.St) :
    symGraph cls Ks s = symGraphD cls SDim.lit Ks s := rfl

/-- `agree_run` at dimension type `δ`. -/
theorem agree_runD {δ : Type} (cls : NumV → Option δ) (lit : Int → δ) (ev : δ → Int) (hlit : ∀ i, ev (lit i) = i)
    (νs νt : NumV → Option F64) (μ : NumV → NumV) (β : Int → Int) (α : Arg → Arg) (η : Nat → Nat)
    (hlitμ : ∀ f, μ (.lit f) = .lit f) (hlitt : ∀ f, νt (.lit f) = some f)
    (hν : ∀ x f, νs x = some f → νt (μ x) = some f) (hcls : ClsSoundD cls νs ev)
    (A : Arg → Prop) (hα : ∀ a v, A a → Ffi.argNat a = some v → Ffi.argNat (α a) = some v)
    (kn kn' : Nat → Option (List Char)) (hk : ∀ k name, kn k = some name → kn' (η k) = some name) :
    Agree (symNumsD cls lit) (concrete νt) ev (numImg μ β α η) kn kn' A where
  d := by
    intro d y hd
    cases d with
    | lit i =>
      cases hd
      show some i = some (ev (lit i))
      rw [hlit]
    | sym x =>
      show (concrete νt).d (dimOf (μ x)) = some _
      rw [concrete_dimOf νt hlitt]
      obtain ⟨f, hf, hy⟩ := Option.bind_eq_some_iff.mp (hcls x y hd)
      show (νt (μ x)).bind F64.toInt? = _
      rw [hν x f hf]; exact hy
  dim := by
    intro x y hx
    obtain ⟨f, hf, hy⟩ := Option.bind_eq_some_iff.mp (hcls x y hx)
    show (νt (μ x)).bind F64.toInt? = _
    rw [hν x f hf]; exact hy
  word := by
    intro x w hw
    cases x with
    | lit f =>
      simp only [symNumsD, litVal, Option.map_some, Option.some.injEq] at hw
      subst hw
      show (νt (μ (.lit f))).map _ = _
      rw [hlitμ, hlitt]
      rfl
    | ref _ => simp [symNumsD, litVal] at hw
  byte := by
    intro b v hb
    match b, hb with
    | .lit _, hb => exact hb
    | .part k (.num x) i, hb =>
      cases x with
      | lit f =>
        show concreteByte νt (.part k (.num (μ (.lit f))) i) = some v
        rw [hlitμ]
        simp only [symNumsD, symByte, concreteByte, concreteCell, litVal, Option.bind_eq_bind] at hb ⊢
        rw [hlitt]
        exact hb
      | ref _ => simp [symNumsD, symByte, concreteByte, concreteCell, litVal] at hb
  arg := hα
  kernel := hk

/-- **Template to iteration**, at dimension type `δ` (`embeds_of_image`). -/
theorem embeds_of_imageD {δ κ : Type} (cls : NumV → Option δ) (lit : Int → δ) (ev : δ → Int)
    (hlit : ∀ i, ev (lit i) = i) (Ks : KernelSources) (s t : Ffi.St) (D : Nat → Bool)
    (νs νt : NumV → Option F64) (μ : NumV → NumV) (β : Int → Int) (α : Arg → Arg) (η σ : Nat → Nat)
    (hlitμ : ∀ f, μ (.lit f) = .lit f) (hlitt : ∀ f, νt (.lit f) = some f)
    (hν : ∀ x f, νs x = some f → νt (μ x) = some f) (hcls : ClsSoundD cls νs ev)
    (A : Arg → Prop) (hα : ∀ a v, A a → Ffi.argNat a = some v → Ffi.argNat (α a) = some v)
    (hargs : ∀ i nd, D i = true → s.nodes.get i = some nd → PrimArgs A nd.prim)
    (hk : ∀ k name, kernelName? Ks s k = some name → kernelName? Ks t (η k) = some name)
    (himg : NativeImage σ (numImg μ β α η) D s t) :
    Embeds (κ := κ) σ η (mapG ev (restrictTo D (symGraphD cls lit Ks s))) (ffiGraph (concrete νt) Ks t) where
  node := by
    intro i r hr
    obtain ⟨r0, h0, rfl⟩ := Option.map_eq_some_iff.mp hr
    have hb : D i = true := by
      cases hd : D i
      · simp [restrictTo, hd] at h0
      · rfl
    simp only [restrictTo, hb, ↓reduceIte] at h0
    obtain ⟨nd, hnd, hres⟩ := Option.bind_eq_some_iff.mp h0
    have h2 := resolveNode_img (agree_runD cls lit ev hlit νs νt μ β α η hlitμ hlitt hν hcls A hα _ _ hk) σ nd r0
      (hargs i nd hb hnd) hres
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
    simp only [mapG, restrictTo, hb, ↓reduceIte, symGraphD, ffiGraph, Option.isSome_map] at hi
    cases hs : s.nodes.get i with
    | none => rw [hs] at hi; cases hi
    | some _ => rfl

/-- **The template run carries every iteration in the box.** Template state `s`
of a symbolic run with table `S`, read with `clsOfP S B`; iteration state `t`
of the concrete run, the template positions at the iteration's valuation
`ρ x = ofInt (ν x)` with `ν` in the box; the iteration map correct on the table
(`hnum`, the simulation's `NumOK`). -/
theorem embeds_of_runP {κ : Type} (S : SSrv) (B : Box) (Ks : KernelSources) (s t : Ffi.St) (D : Nat → Bool)
    (ν : Nat → Int) (ρ : Nat → F64) (hB : InBox B ν)
    (hρ : ∀ x l h, B.get x = some (l, h) → ρ x = F64.ofInt (ν x))
    (νt : NumV → Option F64) (μ : NumV → NumV) (β : Int → Int) (α : Arg → Arg) (η σ : Nat → Nat)
    (hlitμ : ∀ f, μ (.lit f) = .lit f) (hlitt : ∀ f, νt (.lit f) = some f)
    (hnum : ∀ i e, nth? S.tab i = some e → νt (μ (.ref i)) = some (e.eval ρ))
    (A : Arg → Prop) (hα : ∀ a v, A a → Ffi.argNat a = some v → Ffi.argNat (α a) = some v)
    (hargs : ∀ i nd, D i = true → s.nodes.get i = some nd → PrimArgs A nd.prim)
    (hk : ∀ k name, kernelName? Ks s k = some name → kernelName? Ks t (η k) = some name)
    (himg : NativeImage σ (numImg μ β α η) D s t) :
    Embeds (κ := κ) σ η (mapG (PDim.eval ν) (restrictTo D (symGraphD (clsOfP S B) PDim.lit Ks s)))
      (ffiGraph (concrete νt) Ks t) :=
  embeds_of_imageD (clsOfP S B) PDim.lit (PDim.eval ν) (fun _ => rfl) Ks s t D (νsOf S ρ) νt μ β α η σ hlitμ hlitt
    (numbers_agree S ρ μ νt hlitμ hlitt hnum) (clsOfP_sound S B ν ρ hB hρ) A hα hargs hk himg

end Host.Mlx.SimGraph
