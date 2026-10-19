import host.ts.renameOrdinary.RankOriginInitializedCacheConvolution
import host.mlx.OrdinaryCachedRetained

set_option Elab.async false
set_option maxRecDepth 1000000
set_option maxHeartbeats 1000000
namespace Host.Load.Run.Full.Ordinary.RankOrigin.CachedReplayRoles
open Host.Ts Host.Ts.Owned Host.Ts.Owned.Parametric Host.Ts.Owned.Annotated
open Host.Mlx.Ffi Host.Mlx.Ffi.Annotated Host.Mlx.Ffi.NativeRoles

noncomputable def roles := CachedCall.roles (CachedCall.coupledRoles InitializedCacheConvolution.roles)
def support (i : Nat) : Prop := CachedCall.N0 i ∨ InitializedCacheConvolution.nodes i

theorem initialized_bound (i : Nat) (held : InitializedCacheConvolution.nodes i) : i < 22591 := by
  change i = 22590 ∨ i = 22589 ∨ i = 22588 ∨ i = 22587 ∨ i < 22587 at held
  omega

theorem captured_supported (i : Nat) (held : CachedCall.N0 i) : InitializedCacheConvolution.nodes i := by
  change i ∈ [22590,10,11,15252,15253,15254,15255,15256,15257] at held
  change i = 22590 ∨ i = 22589 ∨ i = 22588 ∨ i = 22587 ∨ i < 22587
  simp only [List.mem_cons,List.not_mem_nil,or_false] at held
  omega

theorem support_iff (i : Nat) : support i ↔ InitializedCacheConvolution.nodes i :=
  ⟨fun held => held.elim (captured_supported i) id,Or.inr⟩

theorem placeholder_15252 :
    {InitializedCacheConvolution.roles 22590 with graph := none} = InitializedCacheConvolution.roles 15252 := by host_kernel_rfl
theorem placeholder_15253 :
    {InitializedCacheConvolution.roles 10 with graph := none} = InitializedCacheConvolution.roles 15253 := by host_kernel_rfl
theorem placeholder_15254 :
    {InitializedCacheConvolution.roles 11 with graph := none} = InitializedCacheConvolution.roles 15254 := by host_kernel_rfl

theorem coupled_roles (i : Nat) :
    CachedCall.coupledRoles InitializedCacheConvolution.roles i = InitializedCacheConvolution.roles i := by
  by_cases first : i = 15252
  · subst i; exact placeholder_15252
  by_cases second : i = 15253
  · subst i; exact placeholder_15253
  by_cases third : i = 15254
  · subst i; exact placeholder_15254
  simp only [CachedCall.coupledRoles,ite_eq_right first,ite_eq_right second,ite_eq_right third]

theorem live_roles (i : Nat) (held : InitializedCacheConvolution.nodes i) :
    roles i = InitializedCacheConvolution.roles i := by
  have bound := initialized_bound i held
  unfold roles CachedCall.roles
  split
  · omega
  · omega
  · omega
  · exact coupled_roles i

theorem roles_except_new (i : Nat) (first : i ≠ 22591) (second : i ≠ 22592) (third : i ≠ 22593) :
    roles i = InitializedCacheConvolution.roles i := by
  unfold roles CachedCall.roles
  split
  · contradiction
  · contradiction
  · contradiction
  · exact coupled_roles i

theorem replay_graph_present (i : Nat) (fresh : i = 22591 ∨ i = 22592 ∨ i = 22593) :
    (roles i).graph ≠ none := by
  rcases fresh with rfl | rfl | rfl <;> intro impossible <;> cases impossible

theorem captured_present (i : Nat) (held : CapturedKernelSeed.selected i) :
    (InitializedCacheConvolution.roles i).graph ≠ none := by
  rcases held with rfl | rfl | rfl <;> intro impossible <;> cases impossible

/-- The replay's stricter boundary follows from already retained producer
annotations. The three captured kernel nodes cannot be treated as opaque. -/
theorem boundary (i : Nat) (absent : (InitializedCacheConvolution.roles i).graph = none) : CachedCall.boundary i := by
  change i ∉ [15255,15256,15257]
  intro chosen
  simp only [List.mem_cons,List.not_mem_nil,or_false] at chosen
  exact captured_present i chosen absent

/-- Retagging uses the producer facts retained since initialization. It does
not ask for a target replay, a target trace match, or new target node facts. -/
theorem native_retag {ν₀ ν : Nat → F64} {C₀ C : CSrv} {R : Ren}
    {objects : Nat → Object} {H : Nat → Prop} {tail : List NumV} {source target : Host.Mlx.Ffi.St}
    (native : Live (NumberRoles ν₀ ν C₀ C) R
      (NodeRel InitializedCacheConvolution.roles ν₀ ν C₀ C R NativeSeed.boundary)
      (ObjectRel objects ν₀ ν C₀ C R) H InitializedCacheConvolution.nodes tail source target) :
    Live (NumberRoles ν₀ ν C₀ C) R (NodeRel roles ν₀ ν C₀ C R CachedCall.boundary)
      (ObjectRel objects ν₀ ν C₀ C R) H support tail source target := by
  have indexed := native.restrictSupport (fun i held => (support_iff i).mp held)
    (fun h i held read => Or.inr (native.arrLive h i held read))
  refine {indexed with nodes := ?_}
  intro i held
  apply (indexed.nodes i held).mono
  intro sourceNode targetNode paired
  have same := live_roles i ((support_iff i).mp held)
  exact ⟨same.symm ▸ paired.source,same.symm ▸ paired.target,fun absent => boundary i (same ▸ absent)⟩

theorem state_retag {ν₀ ν : Nat → F64} {C₀ C : CSrv} {R : Ren}
    {objects : Nat → Object} {H : Nat → Prop} {tail : List NumV}
    {host : HostSt → HostSt → Prop} {live framed : Nat → Prop}
    {before after : List Val} {old old' : List Event} {source target : St LSt}
    (state : Parametric.StateR (NumberRoles ν₀ ν C₀ C)
      (VectorHost.NativeRelation ν₀ ν C₀ C InitializedCacheConvolution.roles NativeSeed.boundary
        objects H InitializedCacheConvolution.nodes tail host)
      R live framed before after old old' source target) :
    Parametric.StateR (NumberRoles ν₀ ν C₀ C)
      (CachedStrongHost.NativeRelation ν₀ ν C₀ C InitializedCacheConvolution.roles
        objects H support tail host)
      R live framed before after old old' source target :=
  {state with native := ⟨state.native.1,native_retag state.native.2⟩}

theorem policy_retag {roots H : Nat → Prop} {objects : Nat → Object}
    (policy : ProducerAnnotations roots H InitializedCacheConvolution.nodes InitializedCacheConvolution.roles objects) :
    ProducerAnnotations roots H support roles objects := by
  have indexed := policy.reindex (fun i => (support_iff i).symm)
  refine ⟨indexed.objects,?_,?_⟩
  · intro i absent
    have first : i ≠ 22591 := fun equal => replay_graph_present i (Or.inl equal) absent
    have second : i ≠ 22592 := fun equal => replay_graph_present i (Or.inr (Or.inl equal)) absent
    have third : i ≠ 22593 := fun equal => replay_graph_present i (Or.inr (Or.inr equal)) absent
    rw [roles_except_new i first second third] at absent
    exact policy.roots i absent
  · intro i held primitive inputs graph
    rw [live_roles i ((support_iff i).mp held)] at graph
    exact indexed.nodes i held primitive inputs graph

end Host.Load.Run.Full.Ordinary.RankOrigin.CachedReplayRoles
