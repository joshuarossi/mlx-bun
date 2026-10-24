import host.simgraph.prompt.PromptBuild
import host.simgraph.prompt.NativeD
namespace Host.Mlx.SimGraph
open Host.Mlx Host.Mlx.FfiEval Host.Ts
open Host.Mlx.Ffi (Dim Prim Node)

/-! # Dimension-valued data and the prompt ids

A multi-row step builds small int32 data nodes whose cells are dimensions:
`gated_delta_step`'s `Tin = new Int32Array([T])` with `T = n`. In the template
run the cell is a symbolic number, so its bytes do not resolve
(`symByte`); the expected graph takes such a node as the input
`PKey.cells p j vals shape`, whose value at a valuation `ν` is the int32 array
of the dimensions `vals` (`promptInputs`, `cellsValue`). The prompt ids are
the input `PKey.promptIds`; their value is the host-side bridge's fact that the
node B-newdata creates encodes `π[o, o+n)`.

* `cells_eval`: a concrete data node holding the int32 encoding of numbers
  that read as integers `vs` evaluates to `cellsValue vs`;
* `cells_carrier`: in an iteration state containing the template's nodes
  (`NativeImage`), the image of a template data node whose cells the
  classifier reads as `ds` holds `cellsValue (ds.map ev)` — the
  `InputsHeld` premise for a `cells` input whose `vals` are `ds`. -/

/-- The little-endian bytes of an int32 cell. -/
def i32Bytes (v : Int) : List Nat := leBytes 4 (F64.modNat v (2 ^ 32))

def cellsBytes (vs : List Int) : List Nat := vs.flatMap i32Bytes

/-- An int32 data node with cells `vs`, shape `sh`. -/
def cellsValue (vs sh : List Int) : Option Value := dataValue (cellsBytes vs) sh Ffi.dtInt32

/-- The inputs of a multi-row step at valuation `ν`: the decode step's (`base`),
the prompt ids (the bridge's value `ids`), and the dimension-valued data. -/
def promptInputs (base : InKey → Option Value) (ids : Value) (ν : Nat → Int) : PKey → Option Value
  | .base k => base k
  | .promptIds => some ids
  | .cells _ _ vals shape => cellsValue (vals.map (PDim.eval ν)) (shape.map (PDim.eval ν))
  | .iota _ _ count => cellsValue ((List.range (PDim.eval ν count).toNat).map Int.ofNat) [PDim.eval ν count]

/-- The host bytes of an `Int32Array` whose cells are the numbers `xs`. -/
def cellsHostBytes (xs : List NumV) : List Byte :=
  xs.flatMap fun x => [.part .i32 (.num x) 0, .part .i32 (.num x) 1, .part .i32 (.num x) 2, .part .i32 (.num x) 3]

theorem truncInt_of_toInt {f : F64} {v : Int} (h : F64.toInt? f = some v) : F64.truncInt f = some v := by
  cases f with
  | zero s => cases h; rfl
  | fin s m e =>
    cases e with
    | ofNat k => cases h; rfl
    | negSucc _ => cases h
  | nan => cases h
  | inf _ => cases h

theorem cell_bytes (νt : NumV → Option F64) (x : NumV) (v : Int) (hx : (νt x).bind F64.toInt? = some v) :
    [Byte.part .i32 (.num x) 0, .part .i32 (.num x) 1, .part .i32 (.num x) 2, .part .i32 (.num x) 3].mapM
      (concrete νt).byte = some (i32Bytes v) := by
  obtain ⟨f, hf, hv⟩ := Option.bind_eq_some_iff.mp hx
  have hu : F64.toUint32 f = F64.modNat v (2 ^ 32) := by simp only [F64.toUint32, truncInt_of_toInt hv]
  simp only [concrete, List.mapM_cons, List.mapM_nil, concreteByte, concreteCell, hf, Option.map_some,
    Option.bind_eq_bind, Option.bind_some, encodeCell, hu]
  rfl

theorem cells_bytes (νt : NumV → Option F64) :
    ∀ (xs : List NumV) (vs : List Int), List.Forall₂ (fun x v => (νt x).bind F64.toInt? = some v) xs vs →
      (cellsHostBytes xs).mapM (concrete νt).byte = some (cellsBytes vs)
  | [], [], .nil => rfl
  | x :: xs, v :: vs, .cons hx hxs => by
    have h1 := cell_bytes νt x v hx
    have h2 := cells_bytes νt xs vs hxs
    rw [cellsHostBytes, List.flatMap_cons, List.mapM_append, h1]
    rw [cellsHostBytes] at h2
    rw [h2]
    rfl

section
variable {C : Inference.Contracts.Mlx.M1Max.Contract} (M : MlxContract C) (K : KernelContract C) {κ : Type}
  [DecidableEq κ] (env : Env κ)

/-- **A concrete int32 data node evaluates to its cells.** -/
theorem cells_eval (νt : NumV → Option F64) (Ks : KernelSources) (t : Ffi.St) (j : Nat) (xs : List NumV)
    (shape : List Dim) (vs sh : List Int)
    (hnode : t.nodes.get j = some ⟨.data (cellsHostBytes xs), [], shape, Ffi.dtInt32⟩)
    (hxs : List.Forall₂ (fun x v => (νt x).bind F64.toInt? = some v) xs vs)
    (hsh : shape.mapM (concrete νt).d = some sh) :
    evalR M K env (ffiGraph (concrete νt) Ks t) j = cellsValue vs sh := by
  have hg : ffiGraph (κ := κ) (concrete νt) Ks t j = some ⟨.data (cellsBytes vs) sh Ffi.dtInt32, []⟩ := by
    simp only [ffiGraph, hnode, Option.bind_some, resolveNode, resolvePrim, Option.bind_eq_bind,
      cells_bytes νt xs vs hxs, hsh, Option.bind_some, Option.pure_def, Option.map_some]
  rw [evalR_eq, hg, cgLeaves_none _ _ _ hg rfl]
  rfl

/-- The classifier's cells read at the iteration. -/
theorem cells_read {δ : Type} (cls : NumV → Option δ) (ev : δ → Int) (νs νt : NumV → Option F64) (μ : NumV → NumV)
    (hν : ∀ x f, νs x = some f → νt (μ x) = some f) (hcls : ClsSoundD cls νs ev) :
    ∀ (xs : List NumV) (ds : List δ), xs.mapM cls = some ds →
      List.Forall₂ (fun x v => (νt x).bind F64.toInt? = some v) (xs.map μ) (ds.map ev)
  | [], ds, h => by
    simp only [List.mapM_nil, Option.pure_def, Option.some.injEq] at h
    subst h; exact .nil
  | x :: xs, ds, h => by
    rw [List.mapM_cons] at h
    obtain ⟨d, hd, h⟩ := Option.bind_eq_some_iff.mp h
    obtain ⟨ds', hds', h⟩ := Option.bind_eq_some_iff.mp h
    simp only [Option.pure_def, Option.some.injEq] at h
    subst h
    refine .cons ?_ (cells_read cls ev νs νt μ hν hcls xs ds' hds')
    obtain ⟨f, hf, hv⟩ := Option.bind_eq_some_iff.mp (hcls x d hd)
    show (νt (μ x)).bind F64.toInt? = some (ev d)
    rw [hν x f hf]; exact hv

theorem byteI_cells (μ : NumV → NumV) (β : Int → Int) (xs : List NumV) :
    (cellsHostBytes xs).map (byteI μ β) = cellsHostBytes (xs.map μ) := by
  induction xs with
  | nil => rfl
  | cons x xs ih =>
    simp only [cellsHostBytes, List.flatMap_cons, List.map_append, List.map_cons, List.map_nil, List.map_cons] at ih ⊢
    rw [ih]; rfl

/-- **The template's dimension-valued data in an iteration.** A template data node
`i` in the domain whose cells the classifier reads as `ds` and whose shape as
`dsh` has, in an iteration state containing the template's nodes, its image
holding `cellsValue (ds.map ev) (dsh.map ev)`. -/
theorem cells_carrier {δ : Type} (cls : NumV → Option δ) (lit : Int → δ) (ev : δ → Int) (hlit : ∀ i, ev (lit i) = i)
    (Ks : KernelSources) (s t : Ffi.St) (D : Nat → Bool)
    (νs νt : NumV → Option F64) (μ : NumV → NumV) (β : Int → Int) (α : Arg → Arg) (η σ : Nat → Nat)
    (hlitμ : ∀ f, μ (.lit f) = .lit f) (hlitt : ∀ f, νt (.lit f) = some f)
    (hν : ∀ x f, νs x = some f → νt (μ x) = some f) (hcls : ClsSoundD cls νs ev)
    (himg : NativeImage σ (numImg μ β α η) D s t)
    (i : Nat) (hD : D i = true) (xs : List NumV) (shape : List Dim)
    (hnode : s.nodes.get i = some ⟨.data (cellsHostBytes xs), [], shape, Ffi.dtInt32⟩)
    (ds dsh : List δ) (hds : xs.mapM cls = some ds) (hsh : shape.mapM (symNumsD cls lit).d = some dsh) :
    evalR M K env (ffiGraph (concrete νt) Ks t) (σ i) = cellsValue (ds.map ev) (dsh.map ev) := by
  have ha := agree_runD cls lit ev hlit νs νt μ β α η hlitμ hlitt hν hcls (fun _ => False) (fun _ _ h _ => h.elim)
    (fun _ => none) (fun _ => none) (fun _ _ h => by cases h)
  have hn := himg.nodes i _ hD hnode
  simp only [nodeI, primI, numImg, byteI_cells, List.map_nil] at hn
  exact cells_eval M K env νt Ks t (σ i) (xs.map μ) (shape.map (dimI μ)) _ _ hn
    (cells_read cls ev νs νt μ hν hcls xs ds hds)
    (mapM_img _ _ (dimI μ) ev ha.d shape dsh hsh)

end

end Host.Mlx.SimGraph
