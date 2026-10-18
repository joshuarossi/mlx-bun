import host.mlx.NativeAnnotationPolicy
import host.mlx.NativeTraceFits

set_option Elab.async false
set_option maxRecDepth 1000000
set_option maxHeartbeats 0

namespace Host.Mlx.Ffi.Annotated
open Host.Ts Host.Ts.Owned Host.Ts.Owned.Parametric NativeRoles

/-- Re-express each existing numeric witness by the same substitution. Numeric
reference identities and the independent concrete tables are unchanged. -/
theorem numberRoles_subst {ν₀ ν : Nat → F64} {C₀ C : CSrv} (θ : Nat → SymE)
    {a₀ a : NumV} (h : NumberRoles (Owned.Annotated.nextValuation θ ν₀)
      (Owned.Annotated.nextValuation θ ν) C₀ C a₀ a) : NumberRoles ν₀ ν C₀ C a₀ a := by
  obtain ⟨meaning,left,right⟩ := h
  refine ⟨meaning.subst θ,?_,?_⟩
  · change C₀.val a₀ = some (meaning.eval (fun i => (θ i).eval ν₀)) at left
    simpa only [NumDenote,SymE.eval_subst] using left
  · change C.val a = some (meaning.eval (fun i => (θ i).eval ν)) at right
    simpa only [NumDenote,SymE.eval_subst] using right

theorem NodeRel.subst {roles : Nat → GraphNode} {ν₀ ν : Nat → F64} {C₀ C : CSrv} {R : Ren}
    {boundary : Nat → Prop} {i : Nat} {n₀ n : Node} (θ : Nat → SymE)
    (h : NodeRel roles (Owned.Annotated.nextValuation θ ν₀) (Owned.Annotated.nextValuation θ ν)
      C₀ C R boundary i n₀ n) :
    NodeRel (fun i => (roles i).subst θ) ν₀ ν C₀ C R boundary i n₀ n := by
  refine ⟨(GraphNode.holds_subst θ _ _).mpr h.source,(GraphNode.holds_subst θ _ _).mpr h.target,?_⟩
  intro absent
  cases graph : (roles i).graph with
  | none => exact h.cut graph
  | some pair => simp only [GraphNode.subst,graph,Option.map_some] at absent; cases absent

theorem ObjectRel.subst {roles : Nat → Object} {ν₀ ν : Nat → F64} {C₀ C : CSrv} {R : Ren}
    {i : Nat} {o₀ o : Obj} (θ : Nat → SymE)
    (h : ObjectRel roles (Owned.Annotated.nextValuation θ ν₀) (Owned.Annotated.nextValuation θ ν)
      C₀ C R i o₀ o) : ObjectRel (fun i => (roles i).subst θ) ν₀ ν C₀ C R i o₀ o :=
  ⟨(Object.holds_subst θ _ _).mpr h.source,(Object.holds_subst θ _ _).mpr h.target⟩

end Host.Mlx.Ffi.Annotated

namespace Host.Mlx.Ffi.NativeRoles.Live
open Host.Ts Host.Ts.Owned Host.Ts.Owned.Parametric Host.Mlx.Ffi.Annotated

/-- Numeric loop rebasing preserves the complete current native invariant.
Fixed graph/configuration/callback occurrence annotations are substituted
pointwise; no native lookup, allocation, or future target field is assumed. -/
theorem subst_annotations {ν₀ ν : Nat → F64} {C₀ C : CSrv} {R : Ren}
    {roles : Nat → GraphNode} {objects : Nat → Object} {boundary H N : Nat → Prop}
    {tail : List NumV} {source target : St} (θ : Nat → SymE)
    (h : Live (NumberRoles (Owned.Annotated.nextValuation θ ν₀) (Owned.Annotated.nextValuation θ ν) C₀ C) R
      (NodeRel roles (Owned.Annotated.nextValuation θ ν₀) (Owned.Annotated.nextValuation θ ν) C₀ C R boundary)
      (ObjectRel objects (Owned.Annotated.nextValuation θ ν₀) (Owned.Annotated.nextValuation θ ν) C₀ C R)
      H N tail source target) :
    Live (NumberRoles ν₀ ν C₀ C) R (NodeRel (fun i => (roles i).subst θ) ν₀ ν C₀ C R boundary)
      (ObjectRel (fun i => (objects i).subst θ) ν₀ ν C₀ C R) H N tail source target :=
  h.mono (fun _ _ held => numberRoles_subst θ held)
    (fun _ _ _ held => held.subst θ) (fun _ _ _ held => held.subst θ)

end Host.Mlx.Ffi.NativeRoles.Live

namespace Host.Mlx.Ffi.Annotated
open Host.Ts Host.Ts.Owned Host.Ts.Owned.Parametric NativeRoles

/-- The reached pure producer policy and the strong native invariant rebase
together. Their source and target producer-closure conclusions follow from
these current facts, without a post-rebase support or geometry premise. -/
theorem ProducerAnnotations.subst_current {ν₀ ν : Nat → F64} {C₀ C : CSrv} {R : Ren}
    {roles : Nat → GraphNode} {objects : Nat → Object} {boundary roots H N : Nat → Prop}
    {tail : List NumV} {source target : Ffi.St} (θ : Nat → SymE)
    (policy : ProducerAnnotations roots H N roles objects)
    (h : Live (NumberRoles (Owned.Annotated.nextValuation θ ν₀) (Owned.Annotated.nextValuation θ ν) C₀ C) R
      (NodeRel roles (Owned.Annotated.nextValuation θ ν₀) (Owned.Annotated.nextValuation θ ν) C₀ C R boundary)
      (ObjectRel objects (Owned.Annotated.nextValuation θ ν₀) (Owned.Annotated.nextValuation θ ν) C₀ C R)
      H N tail source target) :
    Live (NumberRoles ν₀ ν C₀ C) R (NodeRel (fun i => (roles i).subst θ) ν₀ ν C₀ C R boundary)
      (ObjectRel (fun i => (objects i).subst θ) ν₀ ν C₀ C R) H N tail source target ∧
    ProducerAnnotations roots H N (fun i => (roles i).subst θ) (fun i => (objects i).subst θ) ∧
    ProducerSupport roots H N source ∧
    ProducerSupport (resourceImage R.node (fun i => N i ∧ roots i))
      (resourceImage R.handle H) (resourceImage R.node N) target := by
  have native := h.subst_annotations θ
  have rebased := policy.subst θ
  exact ⟨native,rebased,rebased.source native,rebased.target native⟩

end Host.Mlx.Ffi.Annotated
