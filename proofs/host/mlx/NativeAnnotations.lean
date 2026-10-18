import host.mlx.ObjectRoles
import host.ts.RenameAnnotationResources

set_option Elab.async false

namespace Host.Mlx.Ffi.Annotated
open Host.Ts Host.Ts.Owned
open Host.Ts.Owned.Parametric

/-- A fixed expression and representation for a numeric occurrence. -/
inductive Number where
  | any (meaning : SymE)
  | literal (meaning : SymE)
  | reference (meaning : SymE)

inductive Number.Holds (ν : Nat → F64) (C : CSrv) : Number → NumV → Prop where
  | any (e : SymE) (n : NumV) : NumDenote ν C e n → Holds ν C (.any e) n
  | literal (e : SymE) (x : F64) : NumDenote ν C e (.lit x) → Holds ν C (.literal e) (.lit x)
  | reference (e : SymE) (i : Nat) : NumDenote ν C e (.ref i) → Holds ν C (.reference e) (.ref i)

theorem Number.paired {ν₀ ν : Nat → F64} {C₀ C : CSrv} {r : Number} {n₀ n : NumV}
    (h₀ : r.Holds ν₀ C₀ n₀) (h : r.Holds ν C n) : NumberRoles ν₀ ν C₀ C n₀ n := by
  cases h₀ <;> cases h <;> exact ⟨_,⟨by assumption,by assumption⟩⟩

/-- Literal dimensions retain their exact integer, not merely its rounded F64
image. Symbolic dimensions retain the symbolic constructor. -/
inductive Dimension where
  | literal (meaning : SymE)
  | symbolic (number : Number)

inductive Dimension.Holds (ν : Nat → F64) (C : CSrv) : Dimension → Dim → Prop where
  | literal (e : SymE) (i : Int) : NumDenote ν C e (.lit (F64.ofInt i)) →
      F64.toInt? (e.eval ν) = some i → Holds ν C (.literal e) (.lit i)
  | symbolic {r : Number} {n : NumV} : r.Holds ν C n → Holds ν C (.symbolic r) (.sym n)

theorem Dimension.paired {ν₀ ν : Nat → F64} {C₀ C : CSrv} {r : Dimension} {d₀ d : Dim}
    (h₀ : r.Holds ν₀ C₀ d₀) (h : r.Holds ν C d) : NumberRoles ν₀ ν C₀ C d₀.num d.num := by
  cases h₀ <;> cases h
  · exact ⟨_,⟨by assumption,by assumption⟩⟩
  · exact Number.paired (by assumption) (by assumption)

/-- Pair two interpretations of the same ordered occurrence list. -/
theorem pairedList {α β γ : Type}
    {p : α → β → Prop} {q : α → γ → Prop} {r : β → γ → Prop}
    {roles : List α} {xs : List β} {ys : List γ}
    (hx : ListR p roles xs) (hy : ListR q roles ys)
    (pair : ∀ a x y, p a x → q a y → r x y) : ListR r xs ys := by
  induction hx generalizing ys with
  | nil => cases hy; exact .nil
  | cons h hs ih => cases hy with
    | cons h' hs' => exact .cons (pair _ _ _ h h') (ih hs')

theorem pairedOption {α β γ : Type}
    {p : α → β → Prop} {q : α → γ → Prop} {r : β → γ → Prop}
    {role : Option α} {x : Option β} {y : Option γ}
    (hx : NativeRoles.OptionR p role x) (hy : NativeRoles.OptionR q role y)
    (pair : ∀ a x y, p a x → q a y → r x y) : NativeRoles.OptionR r x y := by
  cases hx <;> cases hy
  · exact .none
  · exact .some (pair _ _ _ (by assumption) (by assumption))

abbrev Shape := List Dimension
abbrev Shape.Holds (ν : Nat → F64) (C : CSrv) := ListR (Dimension.Holds ν C)

theorem Shape.paired {ν₀ ν : Nat → F64} {C₀ C : CSrv} {r : Shape} {s₀ s : List Dim}
    (h₀ : Shape.Holds ν₀ C₀ r s₀) (h : Shape.Holds ν C r s) :
    Ffi.Parametric.ShapeR (NumberRoles ν₀ ν C₀ C) s₀ s :=
  pairedList h₀ h (fun _ _ _ => Dimension.paired)

structure Config where
  outs : List (Shape × Nat)
  grid : List Number
  group : List Number
  ints : List (List Char × Number)
  dtypes : List (List Char × Nat)
  init : Option Number

structure Config.Holds (ν : Nat → F64) (C : CSrv) (r : Config) (c : Cfg) : Prop where
  output : ListR (fun a b => Shape.Holds ν C a.1 b.1 ∧ b.2 = a.2) r.outs c.outs
  grid : ListR (Number.Holds ν C) r.grid c.grid
  group : ListR (Number.Holds ν C) r.group c.group
  ints : ListR (fun a b => b.1 = a.1 ∧ Number.Holds ν C a.2 b.2) r.ints c.ints
  dtypes : c.dtypes = r.dtypes
  init : NativeRoles.OptionR (Number.Holds ν C) r.init c.init

theorem Config.paired {ν₀ ν : Nat → F64} {C₀ C : CSrv} {r : Config} {c₀ c : Cfg}
    (h₀ : r.Holds ν₀ C₀ c₀) (h : r.Holds ν C c) :
    NativeRoles.CfgR (NumberRoles ν₀ ν C₀ C) c₀ c := by
  refine ⟨pairedList h₀.output h.output ?_, pairedList h₀.grid h.grid ?_,
    pairedList h₀.group h.group ?_, pairedList h₀.ints h.ints ?_, h.dtypes.trans h₀.dtypes.symm, ?_⟩
  · intro _ _ _ a b; exact ⟨Shape.paired a.1 b.1, b.2.trans a.2.symm⟩
  · intro _ _ _; exact Number.paired
  · intro _ _ _; exact Number.paired
  · intro _ _ _ a b; exact ⟨b.1.trans a.1.symm, Number.paired a.2 b.2⟩
  · exact pairedOption h₀.init h.init (fun _ _ _ => Number.paired)

/-- Native graph syntax with fixed roles for every variable field. Kernel and
compiled-closure identifiers are resources, independently of numeric values. -/
inductive Primitive : Type 1 where
  | data (bytes : List Owned.Annotated.Byte)
  | load (file key : List Char)
  | tracer (i : Nat)
  | zeros
  | arange (start stop step : Number)
  | reshape (shape : Shape)
  | transpose (axes : List Nat)
  | slice (start stop step : Shape)
  | sliceUpdate (start stop step : Shape)
  | sliceDynamic (axes : List Nat) (sizes : Shape)
  | concat (axis : Nat)
  | unary (op : List Char)
  | binary (op : List Char)
  | astype (dtype : Nat)
  | contiguous
  | rmsNorm (epsilon : Number)
  | rope (dims : Nat) (traditional : Bool) (base : Owned.Annotated.Tree) (scale offset : Number)
  | sdpa (scale : Number) (mask : List Char)
  | qmm (transpose : Bool) (group bits : Nat) (mode : List Char)
  | dequantize (group bits : Nat) (mode : List Char) (dtype : Option Nat)
  | take (axis : Nat)
  | conv1d (stride pad dilation groups : Nat)
  | logsumexp (axis : Nat) (keep : Bool)
  | kernel (handle : Nat) (config : Config) (output : Nat)
  | replayed (closure : Nat) (primitive : Primitive)

inductive Primitive.Holds (ν : Nat → F64) (C : CSrv) (R : Ren) : Primitive → Prim → Prop where
  | data {roles : List Owned.Annotated.Byte} {bs : List Host.Ts.Byte} :
      ListR (Owned.Annotated.Byte.Holds ν C R) roles bs → Holds ν C R (.data roles) (.data bs)
  | load (file key : List Char) : Holds ν C R (.load file key) (.load file key)
  | tracer (i : Nat) : Holds ν C R (.tracer i) (.tracer i)
  | zeros : Holds ν C R .zeros .zeros
  | arange {a b c : Number} {x y z : NumV} : a.Holds ν C x → b.Holds ν C y → c.Holds ν C z →
      Holds ν C R (.arange a b c) (.arange x y z)
  | reshape {r : Shape} {s : List Dim} : Shape.Holds ν C r s → Holds ν C R (.reshape r) (.reshape s)
  | transpose (axes : List Nat) : Holds ν C R (.transpose axes) (.transpose axes)
  | slice {a b c : Shape} {x y z : List Dim} :
      Shape.Holds ν C a x → Shape.Holds ν C b y → Shape.Holds ν C c z →
      Holds ν C R (.slice a b c) (.slice x y z)
  | sliceUpdate {a b c : Shape} {x y z : List Dim} :
      Shape.Holds ν C a x → Shape.Holds ν C b y → Shape.Holds ν C c z →
      Holds ν C R (.sliceUpdate a b c) (.sliceUpdate x y z)
  | sliceDynamic (axes : List Nat) {r : Shape} {s : List Dim} : Shape.Holds ν C r s →
      Holds ν C R (.sliceDynamic axes r) (.sliceDynamic axes s)
  | concat (axis : Nat) : Holds ν C R (.concat axis) (.concat axis)
  | unary (op : List Char) : Holds ν C R (.unary op) (.unary op)
  | binary (op : List Char) : Holds ν C R (.binary op) (.binary op)
  | astype (dt : Nat) : Holds ν C R (.astype dt) (.astype dt)
  | contiguous : Holds ν C R .contiguous .contiguous
  | rmsNorm {r : Number} {n : NumV} : r.Holds ν C n → Holds ν C R (.rmsNorm r) (.rmsNorm n)
  | rope (dims : Nat) (traditional : Bool) {base : Owned.Annotated.Tree} {arg : Arg}
      {scale offset : Number} {s o : NumV} :
      base.Holds ν C R (Owned.Parametric.arg arg) → scale.Holds ν C s → offset.Holds ν C o →
      Holds ν C R (.rope dims traditional base scale offset) (.rope dims traditional arg s o)
  | sdpa (mask : List Char) {r : Number} {s : NumV} : r.Holds ν C s →
      Holds ν C R (.sdpa r mask) (.sdpa s mask)
  | qmm (tr : Bool) (group bits : Nat) (mode : List Char) :
      Holds ν C R (.qmm tr group bits mode) (.qmm tr group bits mode)
  | dequantize (group bits : Nat) (mode : List Char) (dt : Option Nat) :
      Holds ν C R (.dequantize group bits mode dt) (.dequantize group bits mode dt)
  | take (axis : Nat) : Holds ν C R (.take axis) (.take axis)
  | conv1d (stride pad dil groups : Nat) :
      Holds ν C R (.conv1d stride pad dil groups) (.conv1d stride pad dil groups)
  | logsumexp (axis : Nat) (keep : Bool) : Holds ν C R (.logsumexp axis keep) (.logsumexp axis keep)
  | kernel (handle output : Nat) {r : Config} {c : Cfg} : r.Holds ν C c →
      Holds ν C R (.kernel handle r output) (.kernel (R.handle handle) c output)
  | replayed (closure : Nat) {r : Primitive} {p : Prim} : r.Holds ν C R p →
      Holds ν C R (.replayed closure r) (.replayed (R.handle closure) p)

theorem Primitive.paired {ν₀ ν : Nat → F64} {C₀ C : CSrv} {R : Ren}
    {r : Primitive} {p₀ p : Prim}
    (h₀ : r.Holds ν₀ C₀ Owned.Annotated.identity p₀) (h : r.Holds ν C R p) :
    NativeRoles.PrimR (NumberRoles ν₀ ν C₀ C) R p₀ p := by
  induction h₀ generalizing p with
  | data h₀ => cases h with
    | data h => exact .data (pairedList h₀ h (fun _ _ _ => Owned.Annotated.Byte.paired))
  | load f k => cases h; exact .load f k
  | tracer i => cases h; exact .tracer i
  | zeros => cases h; exact .zeros
  | arange a b c => cases h with
    | arange x y z => exact .arange (Number.paired a x) (Number.paired b y) (Number.paired c z)
  | reshape h₀ => cases h with
    | reshape h => exact .reshape (Shape.paired h₀ h)
  | transpose axes => cases h; exact .transpose axes
  | slice a b c => cases h with
    | slice x y z => exact .slice (Shape.paired a x) (Shape.paired b y) (Shape.paired c z)
  | sliceUpdate a b c => cases h with
    | sliceUpdate x y z => exact .sliceUpdate (Shape.paired a x) (Shape.paired b y) (Shape.paired c z)
  | sliceDynamic axes h₀ => cases h with
    | sliceDynamic _ h => exact .sliceDynamic axes (Shape.paired h₀ h)
  | concat axis => cases h; exact .concat axis
  | unary op => cases h; exact .unary op
  | binary op => cases h; exact .binary op
  | astype dt => cases h; exact .astype dt
  | contiguous => cases h; exact .contiguous
  | rmsNorm h₀ => cases h with
    | rmsNorm h => exact .rmsNorm (Number.paired h₀ h)
  | rope dims tr base scale offset => cases h with
    | rope _ _ base' scale' offset' =>
      exact .rope dims tr
        (Owned.Annotated.Tree.paired base base') (Number.paired scale scale') (Number.paired offset offset')
  | sdpa mask h₀ => cases h with
    | sdpa _ h => exact .sdpa mask (Number.paired h₀ h)
  | qmm tr group bits mode => cases h; exact .qmm tr group bits mode
  | dequantize group bits mode dt => cases h; exact .dequantize group bits mode dt
  | take axis => cases h; exact .take axis
  | conv1d stride pad dil groups => cases h; exact .conv1d stride pad dil groups
  | logsumexp axis keep => cases h; exact .logsumexp axis keep
  | kernel handle output h₀ => cases h with
    | kernel _ _ h => exact .kernel handle output (Config.paired h₀ h)
  | replayed closure _ ih => cases h with
    | replayed _ h => exact .replayed closure (ih h)

structure GraphNode : Type 1 where
  shape : Shape
  dtype : Nat
  graph : Option (Primitive × List Nat)

/-- Cache boundary nodes have a fixed shape annotation; newly produced nodes
also retain their primitive and input identities. -/
structure GraphNode.Holds (ν : Nat → F64) (C : CSrv) (R : Ren) (r : GraphNode) (n : Node) : Prop where
  shape : Shape.Holds ν C r.shape n.shape
  dtype : n.dtype = r.dtype
  graph : ∀ p ins, r.graph = some (p,ins) → p.Holds ν C R n.prim ∧ n.ins = ins.map R.node

theorem GraphNode.paired {ν₀ ν : Nat → F64} {C₀ C : CSrv} {R : Ren}
    {boundary : Nat → Prop} {i : Nat} {r : GraphNode} {n₀ n : Node}
    (cut : r.graph = none → boundary i)
    (h₀ : r.Holds ν₀ C₀ Owned.Annotated.identity n₀) (h : r.Holds ν C R n) :
    NativeRoles.NodeR (NumberRoles ν₀ ν C₀ C) R
      (NativeRoles.PrimR (NumberRoles ν₀ ν C₀ C) R) boundary i n₀ n := by
  refine ⟨Shape.paired h₀.shape h.shape, h.dtype.trans h₀.dtype.symm, ?_⟩
  cases hg : r.graph with
  | none => exact .inl (cut hg)
  | some pair =>
    obtain ⟨p,ins⟩ := pair
    have a := h₀.graph p ins hg
    have b := h.graph p ins hg
    refine .inr ⟨Primitive.paired a.1 b.1, ?_⟩
    have ai : n₀.ins = ins := by
      simpa only [Owned.Annotated.identity, List.map_id_fun, id_eq] using a.2
    exact b.2.trans (congrArg (List.map R.node) ai).symm

/-- The indexed annotations are chosen once, before either interpretation. -/
structure NodeRel (roles : Nat → GraphNode) (ν₀ ν : Nat → F64) (C₀ C : CSrv) (R : Ren)
    (boundary : Nat → Prop) (i : Nat) (n₀ n : Node) : Prop where
  source : (roles i).Holds ν₀ C₀ Owned.Annotated.identity n₀
  target : (roles i).Holds ν C R n
  cut : (roles i).graph = none → boundary i

theorem NodeRel.base {roles : Nat → GraphNode} {ν₀ ν : Nat → F64} {C₀ C : CSrv} {R : Ren}
    {boundary : Nat → Prop} {i : Nat} {n₀ n : Node}
    (h : NodeRel roles ν₀ ν C₀ C R boundary i n₀ n) :
    NativeRoles.NodeR (NumberRoles ν₀ ν C₀ C) R
      (NativeRoles.PrimR (NumberRoles ν₀ ν C₀ C) R) boundary i n₀ n :=
  GraphNode.paired h.cut h.source h.target

end Host.Mlx.Ffi.Annotated
