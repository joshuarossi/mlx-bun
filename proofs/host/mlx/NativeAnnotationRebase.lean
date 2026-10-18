import host.mlx.NativeAnnotations

set_option Elab.async false

namespace Host.Mlx.Ffi.Annotated
open Host.Ts Host.Ts.Owned
open Host.Ts.Owned.Parametric

private theorem list_mono {α β : Type} {p q : α → β → Prop} {xs : List α} {ys : List β}
    (h : ListR p xs ys) (f : ∀ x y, p x y → q x y) : ListR q xs ys := by
  induction h with
  | nil => exact .nil
  | cons h _ ih => exact .cons (f _ _ h) ih

section TableExtension
variable {ν : Nat → F64} {C D : CSrv} {R : Ren} (he : TableExtends C D)
include he

theorem Number.Holds.mono {r : Number} {n : NumV} (h : r.Holds ν C n) : r.Holds ν D n := by
  cases h with
  | any e n h => exact .any e n (h.mono he)
  | literal e x h => exact .literal e x (h.mono he)
  | reference e i h => exact .reference e i (h.mono he)

theorem Dimension.Holds.mono {r : Dimension} {d : Dim} (h : r.Holds ν C d) : r.Holds ν D d := by
  cases h with
  | literal e i h hi => exact .literal e i (h.mono he) hi
  | symbolic h => exact .symbolic (h.mono he)

theorem Shape.Holds.mono {r : Shape} {s : List Dim} (h : Shape.Holds ν C r s) : Shape.Holds ν D r s := by
  induction h with
  | nil => exact .nil
  | cons h _ ih => exact .cons (h.mono he) ih

theorem Config.Holds.mono {r : Config} {c : Cfg} (h : r.Holds ν C c) : r.Holds ν D c := by
  refine ⟨?_,?_,?_,?_,h.dtypes,h.init.mono (fun _ _ hn => hn.mono he)⟩
  · exact list_mono h.output (fun _ _ h => ⟨h.1.mono he,h.2⟩)
  · exact list_mono h.grid (fun _ _ h => h.mono he)
  · exact list_mono h.group (fun _ _ h => h.mono he)
  · exact list_mono h.ints (fun _ _ h => ⟨h.1,h.2.mono he⟩)

theorem Primitive.Holds.mono {r : Primitive} {p : Prim} (h : r.Holds ν C R p) : r.Holds ν D R p := by
  induction h with
  | data h =>
    apply Holds.data
    induction h with
    | nil => exact .nil
    | cons h _ ih => exact .cons (h.mono he) ih
  | load f k => exact .load f k
  | tracer i => exact .tracer i
  | zeros => exact .zeros
  | arange a b c => exact .arange (a.mono he) (b.mono he) (c.mono he)
  | reshape h => exact .reshape (h.mono he)
  | transpose axes => exact .transpose axes
  | slice a b c => exact .slice (a.mono he) (b.mono he) (c.mono he)
  | sliceUpdate a b c => exact .sliceUpdate (a.mono he) (b.mono he) (c.mono he)
  | sliceDynamic axes h => exact .sliceDynamic axes (h.mono he)
  | concat axis => exact .concat axis
  | unary op => exact .unary op
  | binary op => exact .binary op
  | astype dt => exact .astype dt
  | contiguous => exact .contiguous
  | rmsNorm h => exact .rmsNorm (h.mono he)
  | rope dims tr base scale offset => exact .rope dims tr (base.mono he) (scale.mono he) (offset.mono he)
  | sdpa mask h => exact .sdpa mask (h.mono he)
  | qmm tr group bits mode => exact .qmm tr group bits mode
  | dequantize group bits mode dt => exact .dequantize group bits mode dt
  | take axis => exact .take axis
  | conv1d stride pad dil groups => exact .conv1d stride pad dil groups
  | logsumexp axis keep => exact .logsumexp axis keep
  | kernel handle output h => exact .kernel handle output (h.mono he)
  | replayed closure _ ih => exact .replayed closure ih

theorem GraphNode.Holds.mono {r : GraphNode} {n : Node} (h : r.Holds ν C R n) : r.Holds ν D R n :=
  ⟨h.shape.mono he,h.dtype,fun p ins hp => ⟨(h.graph p ins hp).1.mono he,(h.graph p ins hp).2⟩⟩
end TableExtension

theorem NodeRel.mono {roles : Nat → GraphNode} {ν₀ ν : Nat → F64} {C₀ C D₀ D : CSrv} {R : Ren}
    {boundary : Nat → Prop} {i : Nat} {n₀ n : Node}
    (h : NodeRel roles ν₀ ν C₀ C R boundary i n₀ n) (he₀ : TableExtends C₀ D₀) (he : TableExtends C D) :
    NodeRel roles ν₀ ν D₀ D R boundary i n₀ n := ⟨h.source.mono he₀,h.target.mono he,h.cut⟩

def Number.subst (θ : Nat → SymE) : Number → Number
  | .any e => .any (e.subst θ)
  | .literal e => .literal (e.subst θ)
  | .reference e => .reference (e.subst θ)

def Dimension.subst (θ : Nat → SymE) : Dimension → Dimension
  | .literal e => .literal (e.subst θ)
  | .symbolic r => .symbolic (r.subst θ)

def Shape.subst (θ : Nat → SymE) (s : Shape) : Shape := s.map (Dimension.subst θ)

def Config.subst (θ : Nat → SymE) (r : Config) : Config :=
  { outs := r.outs.map fun (s,d) => (Shape.subst θ s,d)
    grid := r.grid.map (Number.subst θ)
    group := r.group.map (Number.subst θ)
    ints := r.ints.map fun (k,n) => (k,n.subst θ)
    dtypes := r.dtypes
    init := r.init.map (Number.subst θ) }

private theorem denote_subst {ν : Nat → F64} {C : CSrv} (θ : Nat → SymE) (e : SymE) (n : NumV) :
    NumDenote ν C (e.subst θ) n ↔ NumDenote (Owned.Annotated.nextValuation θ ν) C e n := by
  simp only [NumDenote,SymE.eval_subst]
  rfl

private theorem int_subst {ν : Nat → F64} (θ : Nat → SymE) (e : SymE) (i : Int) :
    F64.toInt? ((e.subst θ).eval ν) = some i ↔
      F64.toInt? (e.eval (Owned.Annotated.nextValuation θ ν)) = some i := by
  simp only [SymE.eval_subst]
  rfl

theorem Number.holds_subst {ν : Nat → F64} {C : CSrv} (θ : Nat → SymE) (r : Number) (n : NumV) :
    (r.subst θ).Holds ν C n ↔ r.Holds (Owned.Annotated.nextValuation θ ν) C n := by
  cases r <;> simp only [Number.subst]
  all_goals constructor <;> intro h <;> cases h <;> constructor
  all_goals first
    | exact (denote_subst θ _ _).mp (by assumption)
    | exact (denote_subst θ _ _).mpr (by assumption)

theorem Dimension.holds_subst {ν : Nat → F64} {C : CSrv} (θ : Nat → SymE) (r : Dimension) (d : Dim) :
    (r.subst θ).Holds ν C d ↔ r.Holds (Owned.Annotated.nextValuation θ ν) C d := by
  cases r <;> simp only [Dimension.subst]
  all_goals constructor <;> intro h <;> cases h <;> constructor
  all_goals first
    | exact (denote_subst θ _ _).mp (by assumption)
    | exact (denote_subst θ _ _).mpr (by assumption)
    | exact (int_subst θ _ _).mp (by assumption)
    | exact (int_subst θ _ _).mpr (by assumption)
    | exact (Number.holds_subst θ _ _).mp (by assumption)
    | exact (Number.holds_subst θ _ _).mpr (by assumption)

theorem list_map_holds {α β γ : Type} (f : α → β) (p : β → γ → Prop) (q : α → γ → Prop)
    (law : ∀ a v, p (f a) v ↔ q a v) (roles : List α) (values : List γ) :
    ListR p (roles.map f) values ↔ ListR q roles values := by
  induction roles generalizing values with
  | nil => cases values <;> constructor <;> intro h <;> cases h <;> exact .nil
  | cons r rest ih =>
    constructor
    · intro h; cases h with
      | cons h hs => exact .cons ((law _ _).mp h) ((ih _).mp hs)
    · intro h; cases h with
      | cons h hs => exact .cons ((law _ _).mpr h) ((ih _).mpr hs)

theorem Shape.holds_subst {ν : Nat → F64} {C : CSrv} (θ : Nat → SymE) (r : Shape) (s : List Dim) :
    Shape.Holds ν C (Shape.subst θ r) s ↔ Shape.Holds (Owned.Annotated.nextValuation θ ν) C r s :=
  list_map_holds _ _ _ (Dimension.holds_subst θ) r s

theorem option_map_holds {α β γ : Type} (f : α → β) (p : β → γ → Prop) (q : α → γ → Prop)
    (law : ∀ a v, p (f a) v ↔ q a v) (role : Option α) (value : Option γ) :
    NativeRoles.OptionR p (role.map f) value ↔ NativeRoles.OptionR q role value := by
  cases role <;> constructor <;> intro h <;> cases h
  · exact .none
  · exact .none
  · exact .some ((law _ _).mp (by assumption))
  · exact .some ((law _ _).mpr (by assumption))

theorem Config.holds_subst {ν : Nat → F64} {C : CSrv} (θ : Nat → SymE) (r : Config) (c : Cfg) :
    (r.subst θ).Holds ν C c ↔ r.Holds (Owned.Annotated.nextValuation θ ν) C c := by
  have ho := list_map_holds (fun (a : Shape × Nat) => (Shape.subst θ a.1,a.2))
    (fun a b : List _ × Nat => Shape.Holds ν C a.1 b.1 ∧ b.2 = a.2)
    (fun a b => Shape.Holds (Owned.Annotated.nextValuation θ ν) C a.1 b.1 ∧ b.2 = a.2)
    (fun a b => and_congr (Shape.holds_subst θ a.1 b.1) Iff.rfl) r.outs c.outs
  have hg := list_map_holds (Number.subst θ) (Number.Holds ν C)
    (Number.Holds (Owned.Annotated.nextValuation θ ν) C) (Number.holds_subst θ) r.grid c.grid
  have ht := list_map_holds (Number.subst θ) (Number.Holds ν C)
    (Number.Holds (Owned.Annotated.nextValuation θ ν) C) (Number.holds_subst θ) r.group c.group
  have hi := list_map_holds (fun (a : List Char × Number) => (a.1,a.2.subst θ))
    (fun a b => b.1 = a.1 ∧ Number.Holds ν C a.2 b.2)
    (fun a b => b.1 = a.1 ∧ Number.Holds (Owned.Annotated.nextValuation θ ν) C a.2 b.2)
    (fun a b => and_congr Iff.rfl (Number.holds_subst θ a.2 b.2)) r.ints c.ints
  have hn := option_map_holds (Number.subst θ) (Number.Holds ν C)
    (Number.Holds (Owned.Annotated.nextValuation θ ν) C) (Number.holds_subst θ) r.init c.init
  constructor
  · intro h; exact ⟨ho.mp h.output,hg.mp h.grid,ht.mp h.group,hi.mp h.ints,h.dtypes,hn.mp h.init⟩
  · intro h; exact ⟨ho.mpr h.output,hg.mpr h.grid,ht.mpr h.group,hi.mpr h.ints,h.dtypes,hn.mpr h.init⟩

def Primitive.subst (θ : Nat → SymE) : Primitive → Primitive
  | .data bytes => .data (bytes.map (Owned.Annotated.Byte.subst θ))
  | .arange a b c => .arange (a.subst θ) (b.subst θ) (c.subst θ)
  | .reshape s => .reshape (Shape.subst θ s)
  | .slice a b c => .slice (Shape.subst θ a) (Shape.subst θ b) (Shape.subst θ c)
  | .sliceUpdate a b c => .sliceUpdate (Shape.subst θ a) (Shape.subst θ b) (Shape.subst θ c)
  | .sliceDynamic axes s => .sliceDynamic axes (Shape.subst θ s)
  | .rmsNorm e => .rmsNorm (e.subst θ)
  | .rope dims tr base scale offset => .rope dims tr (base.subst θ) (scale.subst θ) (offset.subst θ)
  | .sdpa scale mask => .sdpa (scale.subst θ) mask
  | .kernel k c out => .kernel k (c.subst θ) out
  | .replayed cls p => .replayed cls (p.subst θ)
  | p => p

theorem Primitive.holds_subst {ν : Nat → F64} {C : CSrv} {R : Ren}
    (θ : Nat → SymE) (r : Primitive) (p : Prim) :
    (r.subst θ).Holds ν C R p ↔ r.Holds (Owned.Annotated.nextValuation θ ν) C R p := by
  induction r generalizing p <;> simp only [Primitive.subst]
  case replayed cls r ih =>
    constructor <;> intro h <;> cases h <;> constructor
    · exact (ih _).mp (by assumption)
    · exact (ih _).mpr (by assumption)
  case data bytes =>
    have hb := list_map_holds (Owned.Annotated.Byte.subst θ) (Owned.Annotated.Byte.Holds ν C R)
      (Owned.Annotated.Byte.Holds (Owned.Annotated.nextValuation θ ν) C R)
      (Owned.Annotated.Byte.holds_subst θ) bytes
    constructor <;> intro h <;> cases h <;> constructor
    · exact (hb _).mp (by assumption)
    · exact (hb _).mpr (by assumption)
  all_goals constructor <;> intro h <;> cases h <;> constructor
  all_goals first
    | exact (Number.holds_subst θ _ _).mp (by assumption)
    | exact (Number.holds_subst θ _ _).mpr (by assumption)
    | exact (Shape.holds_subst θ _ _).mp (by assumption)
    | exact (Shape.holds_subst θ _ _).mpr (by assumption)
    | exact (Config.holds_subst θ _ _).mp (by assumption)
    | exact (Config.holds_subst θ _ _).mpr (by assumption)
    | exact (Owned.Annotated.Tree.holds_subst θ _ _).mp (by assumption)
    | exact (Owned.Annotated.Tree.holds_subst θ _ _).mpr (by assumption)

def GraphNode.subst (θ : Nat → SymE) (r : GraphNode) : GraphNode :=
  { shape := Shape.subst θ r.shape, dtype := r.dtype,
    graph := r.graph.map fun (p,ins) => (p.subst θ,ins) }

theorem GraphNode.holds_subst {ν : Nat → F64} {C : CSrv} {R : Ren}
    (θ : Nat → SymE) (r : GraphNode) (n : Node) :
    (r.subst θ).Holds ν C R n ↔ r.Holds (Owned.Annotated.nextValuation θ ν) C R n := by
  constructor
  · intro h
    refine ⟨(Shape.holds_subst θ _ _).mp h.shape,h.dtype,?_⟩
    intro p ins hp
    have hm : (r.subst θ).graph = some (p.subst θ,ins) := by simp only [GraphNode.subst,hp,Option.map_some]
    have hg := h.graph _ _ hm
    exact ⟨(Primitive.holds_subst θ _ _).mp hg.1,hg.2⟩
  · intro h
    refine ⟨(Shape.holds_subst θ _ _).mpr h.shape,h.dtype,?_⟩
    intro p ins hp
    cases hg : r.graph with
    | none => simp only [GraphNode.subst,hg,Option.map_none] at hp; cases hp
    | some pair =>
      obtain ⟨p₀,ins₀⟩ := pair
      simp only [GraphNode.subst,hg,Option.map_some,Option.some.injEq,Prod.mk.injEq] at hp
      obtain ⟨rfl,rfl⟩ := hp
      have hh := h.graph _ _ hg
      exact ⟨(Primitive.holds_subst θ _ _).mpr hh.1,hh.2⟩

end Host.Mlx.Ffi.Annotated
