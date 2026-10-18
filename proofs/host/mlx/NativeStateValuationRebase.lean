import host.ts.RenameStateValuationRebase
import host.mlx.NativeValuationRebase

set_option Elab.async false

namespace Host.Mlx.Ffi.Annotated
open Host.Ts Host.Ts.Owned Host.Ts.Owned.Parametric NativeRoles

/-- Strong indexed native correspondence, with the caller's host relation
retained alongside it. This works for the load world's native projection as
well as for a plain native state. -/
def StateNativeRelation {S : Type} (native : S → Ffi.St) (host : Ren → S → S → Prop)
    (ν₀ ν : Nat → F64) (C₀ C : CSrv) (roles : Nat → GraphNode) (objects : Nat → Object)
    (boundary H N : Nat → Prop) (tail : List NumV) (R : Ren) (source target : S) : Prop :=
  Live (NumberRoles ν₀ ν C₀ C) R (NodeRel roles ν₀ ν C₀ C R boundary)
    (ObjectRel objects ν₀ ν C₀ C R) H N tail (native source) (native target) ∧
  host R source target

/-- Rebase the full current TS/native state, retained roles, and producer
policy together. The fixed occurrence data is substituted pointwise; source
and target heaps, numeric servers, resource maps, native counters, and callback
resource identities are unchanged. Source/target producer closure is derived
from these current facts rather than supplied as a new postcondition. -/
theorem substitute_current {S : Type} {native : S → Ffi.St} {host : Ren → S → S → Prop}
    {notes : Owned.Annotated.RetainedNotes} {ν₀ ν : Nat → F64} {C₀ C : CSrv} {R : Ren}
    {roles : Nat → GraphNode} {objects : Nat → Object} {boundary roots H N : Nat → Prop}
    {tail : List NumV} {live framed : Nat → Prop} {before after : List Val}
    {old old' : List Event} {source target : Host.Ts.St S} (θ : Nat → SymE)
    (current : Parametric.StateR (NumberRoles (Owned.Annotated.nextValuation θ ν₀)
      (Owned.Annotated.nextValuation θ ν) C₀ C)
      (StateNativeRelation native host (Owned.Annotated.nextValuation θ ν₀)
        (Owned.Annotated.nextValuation θ ν) C₀ C roles objects boundary H N tail)
      R live framed before after old old' source target)
    (inventory : Owned.Annotated.RetainedInventory notes
      (Owned.Annotated.nextValuation θ ν₀) (Owned.Annotated.nextValuation θ ν)
      C₀ C R live source target)
    (policy : ProducerAnnotations roots H N roles objects) :
    Parametric.StateR (NumberRoles ν₀ ν C₀ C)
      (StateNativeRelation native host ν₀ ν C₀ C (fun i => (roles i).subst θ)
        (fun i => (objects i).subst θ) boundary H N tail)
      R live framed before after old old' source target ∧
    Owned.Annotated.RetainedInventory (notes.subst θ) ν₀ ν C₀ C R live source target ∧
    ProducerAnnotations roots H N (fun i => (roles i).subst θ) (fun i => (objects i).subst θ) ∧
    ProducerSupport roots H N (native source.ffi) ∧
    ProducerSupport (resourceImage R.node (fun i => N i ∧ roots i))
      (resourceImage R.handle H) (resourceImage R.node N) (native target.ffi) := by
  obtain ⟨nativeRebased,policyRebased,sourceSupport,targetSupport⟩ :=
    policy.subst_current θ current.native.1
  have stateRebased := current.substitute_valuation
    (GR := StateNativeRelation native host ν₀ ν C₀ C (fun i => (roles i).subst θ)
      (fun i => (objects i).subst θ) boundary H N tail) θ
    (fun held => And.intro nativeRebased held.2)
  exact ⟨stateRebased,inventory.subst θ,policyRebased,sourceSupport,targetSupport⟩

end Host.Mlx.Ffi.Annotated
