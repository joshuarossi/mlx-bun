import host.mlx.NativeSupportRebase
import host.mlx.NativeObjectAnnotations

set_option Elab.async false
set_option maxRecDepth 1000000
set_option maxHeartbeats 0

namespace Host.Mlx.Ffi.Annotated
open Host.Ts Host.Ts.Owned Host.Ts.Owned.Parametric

def Trace.Supported (N : Nat → Prop) (r : Trace) : Prop :=
  NativeRoles.TraceSupport N ⟨r.ins,r.outs,r.order⟩

def Object.Supported (N : Nat → Prop) : Object → Prop
  | .vec nodes => listSupport N nodes
  | .closure (.compiled _ _ _ traces) => listSupport (Trace.Supported N) traces
  | _ => True

/-- A pure policy on the fixed annotations. No runtime lookup or target
execution appears here; its graph IDs are chosen before either interpretation. -/
structure ProducerAnnotations (roots H N : Nat → Prop) (nodes : Nat → GraphNode) (objects : Nat → Object) : Prop where
  objects : ∀ i, H i → (objects i).Supported N
  roots : ∀ i, (nodes i).graph = none → roots i
  nodes : ∀ i, N i → ∀ primitive inputs, (nodes i).graph = some (primitive,inputs) → listSupport N inputs

theorem Trace.Holds.source_support {N : Nat → Prop} {r : Trace} {t : Ffi.Trace}
    (h : r.Holds Owned.Annotated.identity t) (held : r.Supported N) : NativeRoles.TraceSupport N t := by
  have inputs : t.ins = r.ins := by simpa only [Owned.Annotated.identity,List.map_id_fun,id_eq] using h.ins
  have outputs : t.outs = r.outs := by simpa only [Owned.Annotated.identity,List.map_id_fun,id_eq] using h.outs
  have order : t.order = r.order := by simpa only [Owned.Annotated.identity,List.map_id_fun,id_eq] using h.order
  exact ⟨by rw [inputs]; exact held.inputs,by rw [outputs]; exact held.outputs,by rw [order]; exact held.order⟩

private theorem traces_source {N : Nat → Prop} {rs : List Trace} {ts : List Ffi.Trace}
    (related : ListR (Trace.Holds Owned.Annotated.identity) rs ts) (held : listSupport (Trace.Supported N) rs) :
    listSupport (NativeRoles.TraceSupport N) ts := by
  induction related with
  | nil => trivial
  | cons head rest ih => exact ⟨head.source_support held.1,ih held.2⟩

theorem Object.Holds.source_support {ν : Nat → F64} {C : CSrv} {N : Nat → Prop} {r : Object} {o : Obj}
    (h : r.Holds ν C Owned.Annotated.identity o) (held : r.Supported N) : NativeRoles.ObjectSupport N o := by
  cases h with
  | vec nodes => simpa only [Object.Supported,NativeRoles.ObjectSupport,Owned.Annotated.identity,List.map_id_fun,id_eq] using held
  | closure closure =>
    cases closure with
    | empty => trivial
    | fn callback payload => trivial
    | compiled callback shapeless payload traces => exact traces_source traces held
  | _ => trivial

/-- Numeric substitution never changes a native vector or a captured trace's
producer IDs. This policy survives the loop's numeric valuation update. -/
theorem Object.supported_subst (θ : Nat → SymE) (N : Nat → Prop) (r : Object) :
    (r.subst θ).Supported N ↔ r.Supported N := by
  cases r with
  | closure closure => cases closure <;> rfl
  | _ => rfl

theorem ProducerAnnotations.subst {roots H N : Nat → Prop} {nodes : Nat → GraphNode} {objects : Nat → Object}
    (policy : ProducerAnnotations roots H N nodes objects) (θ : Nat → SymE) :
    ProducerAnnotations roots H N (fun i => (nodes i).subst θ) (fun i => (objects i).subst θ) := by
  constructor
  · intro i held
    exact (Object.supported_subst θ N (objects i)).mpr (policy.objects i held)
  · intro i noGraph
    cases graph : (nodes i).graph with
    | none => exact policy.roots i graph
    | some pair => simp only [GraphNode.subst,graph,Option.map_some] at noGraph; cases noGraph
  · intro i held primitive inputs graph'
    cases graph : (nodes i).graph with
    | none => simp only [GraphNode.subst,graph,Option.map_none] at graph'; cases graph'
    | some pair =>
      obtain ⟨p,ins⟩ := pair
      simp only [GraphNode.subst,graph,Option.map_some] at graph'
      cases graph'
      exact policy.nodes i held p inputs graph

private theorem option_target {α β : Type} {rel : α → β → Prop} {source : α} {target : Option β}
    (related : NativeRoles.OptionR rel (some source) target) : ∃ value, target = some value ∧ rel source value := by
  cases related with
  | some related => exact ⟨_,rfl,related⟩

/-- The source producer invariant follows from the same indexed native
annotations used by the relational execution, together with a pure policy. -/
theorem ProducerAnnotations.source {ν₀ ν : Nat → F64} {C₀ C : CSrv} {R : Ren}
    {roles : Nat → GraphNode} {objects : Nat → Object} {boundary roots H N : Nat → Prop}
    {tail : List NumV} {s s' : Ffi.St}
    (policy : ProducerAnnotations roots H N roles objects)
    (h : NativeRoles.Live (NumberRoles ν₀ ν C₀ C) R (NodeRel roles ν₀ ν C₀ C R boundary)
      (ObjectRel objects ν₀ ν C₀ C R) H N tail s s') : NativeRoles.ProducerSupport roots H N s := by
  constructor
  · intro i obj held read
    have related := h.objs i held
    change NativeRoles.OptionR (ObjectRel objects ν₀ ν C₀ C R i) (s.obj? i) (s'.obj? (R.handle i)) at related
    rw [read] at related
    obtain ⟨target,_,related⟩ := option_target related
    exact related.source.source_support (policy.objects i held)
  · intro i node held read full
    have related := h.nodes i held
    rw [read] at related
    obtain ⟨target,_,related⟩ := option_target related
    cases graph : (roles i).graph with
    | none => exact False.elim (full (policy.roots i graph))
    | some pair =>
      obtain ⟨primitive,inputs⟩ := pair
      have actual := (related.source.graph primitive inputs graph).2
      have exactInputs : node.ins = inputs := by
        simpa only [Owned.Annotated.identity,List.map_id_fun,id_eq] using actual
      rw [exactInputs]
      exact policy.nodes i held primitive inputs graph

theorem ProducerAnnotations.target {ν₀ ν : Nat → F64} {C₀ C : CSrv} {R : Ren}
    {roles : Nat → GraphNode} {objects : Nat → Object} {boundary roots H N : Nat → Prop}
    {tail : List NumV} {s s' : Ffi.St}
    (policy : ProducerAnnotations roots H N roles objects)
    (h : NativeRoles.Live (NumberRoles ν₀ ν C₀ C) R (NodeRel roles ν₀ ν C₀ C R boundary)
      (ObjectRel objects ν₀ ν C₀ C R) H N tail s s') :
    NativeRoles.ProducerSupport (NativeRoles.resourceImage R.node (fun i => N i ∧ roots i))
      (NativeRoles.resourceImage R.handle H) (NativeRoles.resourceImage R.node N) s' :=
  (policy.source h).target_annotated h (fun _ _ _ p => p.base) policy.roots

end Host.Mlx.Ffi.Annotated
