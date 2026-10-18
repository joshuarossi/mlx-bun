import host.mlx.NativeProducerSupport
import host.mlx.NativeAnnotations

set_option Elab.async false
set_option maxRecDepth 1000000
set_option maxHeartbeats 0

namespace Host.Mlx.Ffi.NativeRoles
open Host.Ts Host.Ts.Owned

def resourceImage (f : Nat → Nat) (P : Nat → Prop) (j : Nat) : Prop :=
  ∃ i, P i ∧ j = f i

theorem resourceImage_support (f : Nat → Nat) {N : Nat → Prop} :
    ∀ xs, listSupport N xs → listSupport (resourceImage f N) (xs.map f)
  | [], _ => True.intro
  | i::is, h => ⟨⟨i,h.1,rfl⟩,resourceImage_support f is h.2⟩

theorem TraceSupport.target {R : Ren} {N : Nat → Prop} {t t' : Trace}
    (related : TraceR R t t') (support : TraceSupport N t) :
    TraceSupport (resourceImage R.node N) t' := by
  constructor
  · rw [related.ins]; exact resourceImage_support R.node t.ins support.inputs
  · rw [related.outs]; exact resourceImage_support R.node t.outs support.outputs
  · rw [related.order]; exact resourceImage_support R.node t.order support.order

private theorem traces_target {R : Ren} {N : Nat → Prop} {ts ts' : List Trace}
    (related : ListR (TraceR R) ts ts') (support : listSupport (TraceSupport N) ts) :
    listSupport (TraceSupport (resourceImage R.node N)) ts' := by
  induction related with
  | nil => trivial
  | cons head rest ih => exact ⟨TraceSupport.target head support.1,ih support.2⟩

theorem ObjectSupport.target {NR : NumV → NumV → Prop} {R : Ren} {N : Nat → Prop} {o o' : Obj}
    (related : ObjectR NR R o o') (support : ObjectSupport N o) :
    ObjectSupport (resourceImage R.node N) o' := by
  cases related with
  | vec nodes => exact resourceImage_support R.node nodes support
  | clo closure =>
    cases closure with
    | empty => trivial
    | fn callback payload => trivial
    | compiled callback shapeless payload traces => exact traces_target traces support
  | _ => trivial

private theorem option_source {α β : Type} {rel : α → β → Prop} {source : Option α} {value : β}
    (related : OptionR rel source (some value)) : ∃ original, source = some original ∧ rel original value := by
  cases related with
  | some related => exact ⟨_,rfl,related⟩

theorem annotated_inputs {ν₀ ν : Nat → F64} {C₀ C : CSrv} {R : Ren}
    {roles : Nat → Annotated.GraphNode} {boundary : Nat → Prop} {i : Nat} {n₀ n : Node}
    (h : Annotated.NodeRel roles ν₀ ν C₀ C R boundary i n₀ n) (known : (roles i).graph ≠ none) :
    n.ins = n₀.ins.map R.node := by
  cases graph : (roles i).graph with
  | none => exact False.elim (known graph)
  | some pair =>
    obtain ⟨primitive,inputs⟩ := pair
    have source := (h.source.graph primitive inputs graph).2
    have target := (h.target.graph primitive inputs graph).2
    have same : n₀.ins = inputs := by
      simpa only [Owned.Annotated.identity,List.map_id_fun,id_eq] using source
    rw [same]
    exact target

/-- Native producer closure transfers through the existing resource relation.
The target support is the image of source support; no target graph/vector or
trace-support premise is needed. Known edges follow from the indexed node
annotation, even when the weaker relation also permits a boundary node. -/
theorem ProducerSupport.target {NR : NumV → NumV → Prop} {R : Ren}
    {NodeRel : Nat → Node → Node → Prop} {ObjRel : Nat → Obj → Obj → Prop}
    {roots H N : Nat → Prop} {tail : List NumV} {s s' : St}
    (support : ProducerSupport roots H N s)
    (h : Live NR R NodeRel ObjRel H N tail s s')
    (edges : ∀ i n n', NodeRel i n n' → ¬ roots i → n'.ins = n.ins.map R.node)
    (objects : ∀ i x y, ObjRel i x y → ObjectR NR R x y) :
    ProducerSupport (resourceImage R.node (fun i => N i ∧ roots i)) (resourceImage R.handle H) (resourceImage R.node N) s' := by
  constructor
  · intro j obj held read
    rcases held with ⟨i,hi,rfl⟩
    have related := h.objs i hi
    change OptionR (ObjRel i) (s.obj? i) (s'.obj? (R.handle i)) at related
    rw [read] at related
    obtain ⟨original,source,related⟩ := option_source related
    exact ObjectSupport.target (objects i original obj related) (support.objects i original hi source)
  · intro j node held read full
    rcases held with ⟨i,hi,rfl⟩
    have related := h.nodes i hi
    rw [read] at related
    obtain ⟨original,source,related⟩ := option_source related
    have sourceFull : ¬ roots i := fun root => full ⟨i,⟨hi,root⟩,rfl⟩
    rw [edges i original node related sourceFull]
    exact resourceImage_support R.node original.ins (support.nodes i original hi source sourceFull)

theorem ProducerSupport.target_annotated {ν₀ ν : Nat → F64} {C₀ C : CSrv} {R : Ren}
    {roles : Nat → Annotated.GraphNode} {boundary : Nat → Prop} {ObjRel : Nat → Obj → Obj → Prop}
    {roots H N : Nat → Prop} {tail : List NumV} {s s' : St}
    (support : ProducerSupport roots H N s)
    (h : Live (Parametric.NumberRoles ν₀ ν C₀ C) R (Annotated.NodeRel roles ν₀ ν C₀ C R boundary)
      ObjRel H N tail s s')
    (objects : ∀ i x y, ObjRel i x y → ObjectR (Parametric.NumberRoles ν₀ ν C₀ C) R x y)
    (covered : ∀ i, (roles i).graph = none → roots i) :
    ProducerSupport (resourceImage R.node (fun i => N i ∧ roots i)) (resourceImage R.handle H) (resourceImage R.node N) s' := by
  apply support.target h _ objects
  intro i source target related full
  exact annotated_inputs related (fun noGraph => full (covered i noGraph))

end Host.Mlx.Ffi.NativeRoles
