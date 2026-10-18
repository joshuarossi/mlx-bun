import host.ts.RenameLoopVariableNamespace
import host.ts.renameOrdinary.RankOriginCacheRoles
import host.mlx.NativeStateValuationRebase

set_option Elab.async false
namespace Host.Load.Run.Full.Ordinary.RankOrigin.CacheEntry
open Host.Ts Host.Ts.Owned Host.Ts.Owned.Parametric Host.Ts.Owned.Annotated
open Host.Mlx.Ffi.Annotated Host.Mlx.Ffi.NativeRoles

theorem selected_roles_substitute (θ : Nat → SymE) (base : Nat → GraphNode)
    (selected : ∀ producer ∈ producers, base producer = literalCapacityRole) :
    ∀ producer ∈ producers, (base producer).subst θ = literalCapacityRole := by
  intro producer member
  rw [selected producer member]
  rfl

/-- Embed all existing oracle meanings before adding independent loop roles.
The entire reached state, all inventories, current numeric references and
native resource/counter relations are retained. Future source certificates
use the substituted server, as justified by runS_substitute. -/
theorem embed_context {S : Type} {native : S → Host.Mlx.Ffi.St} {host : Ren → S → S → Prop}
    {notes : RetainedNotes} {ν₀ ν : Nat → F64} {C₀ C : CSrv} {R : Ren}
    {base : Nat → GraphNode} {objects : Nat → Object} {boundary roots H N : Nat → Prop}
    {tail : List NumV} {live framed : Nat → Prop} {before after : List Val}
    {old old' : List Event} {source target : St S} {server : SSrv}
    (loop₀ loop : Nat → F64)
    (current : Parametric.StateR (NumberRoles ν₀ ν C₀ C)
      (StateNativeRelation native host ν₀ ν C₀ C base objects boundary H N tail)
      R live framed before after old old' source target)
    (inventory : RetainedInventory notes ν₀ ν C₀ C R live source target)
    (policy : ProducerAnnotations roots H N base objects) (inst : Inst ν₀ server C₀) :
    Parametric.StateR (NumberRoles (LoopVariables.valuation ν₀ loop₀) (LoopVariables.valuation ν loop) C₀ C)
      (StateNativeRelation native host (LoopVariables.valuation ν₀ loop₀) (LoopVariables.valuation ν loop) C₀ C
        (fun i => (base i).subst LoopVariables.oracleVariables)
        (fun i => (objects i).subst LoopVariables.oracleVariables) boundary H N tail)
      R live framed before after old old' source target ∧
    RetainedInventory (notes.subst LoopVariables.oracleVariables)
      (LoopVariables.valuation ν₀ loop₀) (LoopVariables.valuation ν loop) C₀ C R live source target ∧
    ProducerAnnotations roots H N (fun i => (base i).subst LoopVariables.oracleVariables)
      (fun i => (objects i).subst LoopVariables.oracleVariables) ∧
    ProducerSupport roots H N (native source.ffi) ∧
    ProducerSupport (resourceImage R.node (fun i => N i ∧ roots i))
      (resourceImage R.handle H) (resourceImage R.node N) (native target.ffi) ∧
    Inst (LoopVariables.valuation ν₀ loop₀) (server.substitute LoopVariables.oracleVariables) C₀ := by
  have sourceProjection := LoopVariables.oracle_projection ν₀ loop₀
  have targetProjection := LoopVariables.oracle_projection ν loop
  have current' : Parametric.StateR
      (NumberRoles (nextValuation LoopVariables.oracleVariables (LoopVariables.valuation ν₀ loop₀))
        (nextValuation LoopVariables.oracleVariables (LoopVariables.valuation ν loop)) C₀ C)
      (StateNativeRelation native host
        (nextValuation LoopVariables.oracleVariables (LoopVariables.valuation ν₀ loop₀))
        (nextValuation LoopVariables.oracleVariables (LoopVariables.valuation ν loop)) C₀ C
        base objects boundary H N tail) R live framed before after old old' source target := by
    simpa only [sourceProjection,targetProjection] using current
  have inventory' : RetainedInventory notes
      (nextValuation LoopVariables.oracleVariables (LoopVariables.valuation ν₀ loop₀))
      (nextValuation LoopVariables.oracleVariables (LoopVariables.valuation ν loop)) C₀ C R live source target := by
    simpa only [sourceProjection,targetProjection] using inventory
  obtain ⟨state,retained,newPolicy,leftSupport,rightSupport⟩ :=
    substitute_current LoopVariables.oracleVariables current' inventory' policy
  exact ⟨state,retained,newPolicy,leftSupport,rightSupport,LoopVariables.instantiate loop₀ inst⟩

/-- The cache-capacity role is installed only after its namespace is fixed.
Every other reached state/native/inventory field is kept unchanged. -/
theorem annotate_context {S : Type} {native : S → Host.Mlx.Ffi.St} {host : Ren → S → S → Prop}
    {notes : RetainedNotes} {ν₀ ν : Nat → F64} {C₀ C : CSrv} {R : Ren}
    {base : Nat → GraphNode} {objects : Nat → Object} {boundary roots H N : Nat → Prop}
    {tail : List NumV} {live framed : Nat → Prop} {before after : List Val}
    {old old' : List Event} {source target : St S} (capacityMeaning : SymE)
    (selected : ∀ producer ∈ producers, base producer = literalCapacityRole)
    (current : Parametric.StateR (NumberRoles ν₀ ν C₀ C)
      (StateNativeRelation native host ν₀ ν C₀ C base objects boundary H N tail)
      R live framed before after old old' source target)
    (inventory : RetainedInventory notes ν₀ ν C₀ C R live source target)
    (policy : ProducerAnnotations roots H N base objects)
    (sourceCapacity : capacityMeaning.eval ν₀ = F64.ofInt 256)
    (targetCapacity : capacityMeaning.eval ν = F64.ofInt 256) :
    Parametric.StateR (NumberRoles ν₀ ν C₀ C)
      (StateNativeRelation native host ν₀ ν C₀ C (cacheRoles capacityMeaning base) objects boundary H N tail)
      R live framed before after old old' source target ∧
    RetainedInventory notes ν₀ ν C₀ C R live source target ∧
    ProducerAnnotations roots H N (cacheRoles capacityMeaning base) objects ∧
    ProducerSupport roots H N (native source.ffi) ∧
    ProducerSupport (resourceImage R.node (fun i => N i ∧ roots i))
      (resourceImage R.handle H) (resourceImage R.node N) (native target.ffi) := by
  have nativePost := annotate_live capacityMeaning selected current.native.1 sourceCapacity targetCapacity
  have newState : Parametric.StateR (NumberRoles ν₀ ν C₀ C)
      (StateNativeRelation native host ν₀ ν C₀ C (cacheRoles capacityMeaning base) objects boundary H N tail)
      R live framed before after old old' source target :=
    {current with native := ⟨nativePost,current.native.2⟩}
  have newPolicy := annotate_policy capacityMeaning selected policy
  exact ⟨newState,inventory,newPolicy,newPolicy.source nativePost,newPolicy.target nativePost⟩

end Host.Load.Run.Full.Ordinary.RankOrigin.CacheEntry
