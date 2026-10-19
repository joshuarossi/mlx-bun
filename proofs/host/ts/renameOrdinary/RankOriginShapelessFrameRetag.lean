import host.ts.renameOrdinary.RankOriginShapelessRoleCompatibility
import host.mlx.OrdinaryVectorHost
import host.mlx.NativeAnnotationPolicy
import host.ts.RenameKernelRfl
import host.ts.RenameRouteDriver

set_option Elab.async false
set_option maxRecDepth 1000000
set_option maxHeartbeats 0

namespace Host.Load.Run.Full.Ordinary.RankOrigin.ShapelessFrameRetag
open Host.Ts Host.Ts.Owned Host.Ts.Owned.Parametric Host.Ts.Owned.Annotated
open Host.Mlx.Ffi Host.Mlx.Ffi.Annotated Host.Mlx.Ffi.NativeRoles

/-- Inputs, placeholders, and captured producers whose current annotations have
to agree with the initialized seed before the shapeless replay. The seven fresh
replay nodes begin at 22595 and are not in this list. -/
def selectedInputs : List Nat :=
  [1330, 1331, 15262, 15263, 15264, 22586, 15265, 15266, 15267, 15268, 15269, 15270, 15271, 15272]

private theorem roles_default (base : Nat → GraphNode) (leading : Shape) (i : Nat)
    (h22586 : i ≠ 22586) (h15263 : i ≠ 15263) (h15268 : i ≠ 15268) (h15270 : i ≠ 15270)
    (h15271 : i ≠ 15271) (h15272 : i ≠ 15272) (h22598 : i ≠ 22598) (h22599 : i ≠ 22599)
    (h22600 : i ≠ 22600) (h22601 : i ≠ 22601) :
    ShapelessCall.roles base leading i = ShapelessCall.fixedRoles base i := by
  simp only [ShapelessCall.roles]

private theorem fixed_default (base : Nat → GraphNode) (i : Nat)
    (h1330 : i ≠ 1330) (h1331 : i ≠ 1331) (h15262 : i ≠ 15262) (h15264 : i ≠ 15264)
    (h22586 : i ≠ 22586) (h15263 : i ≠ 15263) (h15265 : i ≠ 15265) (h22595 : i ≠ 22595)
    (h15266 : i ≠ 15266) (h22596 : i ≠ 22596) (h15267 : i ≠ 15267) (h22597 : i ≠ 22597)
    (h15268 : i ≠ 15268) (h22598 : i ≠ 22598) (h15269 : i ≠ 15269) (h15270 : i ≠ 15270)
    (h22599 : i ≠ 22599) (h15271 : i ≠ 15271) (h22600 : i ≠ 22600) (h15272 : i ≠ 15272)
    (h22601 : i ≠ 22601) :
    ShapelessCall.fixedRoles base i = base i := by
  simp only [ShapelessCall.fixedRoles]

private theorem unchanged (base : Nat → GraphNode) (i : Nat)
    (h1330 : i ≠ 1330) (h1331 : i ≠ 1331) (h15262 : i ≠ 15262) (h15264 : i ≠ 15264)
    (h22586 : i ≠ 22586) (h15263 : i ≠ 15263) (h15265 : i ≠ 15265) (h22595 : i ≠ 22595)
    (h15266 : i ≠ 15266) (h22596 : i ≠ 22596) (h15267 : i ≠ 15267) (h22597 : i ≠ 22597)
    (h15268 : i ≠ 15268) (h22598 : i ≠ 22598) (h15269 : i ≠ 15269) (h15270 : i ≠ 15270)
    (h22599 : i ≠ 22599) (h15271 : i ≠ 15271) (h22600 : i ≠ 22600) (h15272 : i ≠ 15272)
    (h22601 : i ≠ 22601) :
    ShapelessCall.roles base (closedShape [1, 1]) i = base i := by
  rw [roles_default base (closedShape [1, 1]) i h22586 h15263 h15268 h15270 h15271 h15272
    h22598 h22599 h22600 h22601]
  exact fixed_default base i h1330 h1331 h15262 h15264 h22586 h15263 h15265 h22595 h15266
    h22596 h15267 h22597 h15268 h22598 h15269 h15270 h22599 h15271 h22600 h15272 h22601

private theorem outside_id (i n : Nat) (outside : i ∉ selectedInputs) (here : n ∈ selectedInputs) :
    i ≠ n := by
  intro equal
  exact outside (equal.symm ▸ here)

private theorem before_fresh (i n : Nat) (bound : i < 22595) (atLeast : 22595 ≤ n) : i ≠ n :=
  Nat.ne_of_lt (Nat.lt_of_lt_of_le bound atLeast)

/-- An index outside the fourteen selected ids keeps whatever role it already has.
This includes the nodes already produced at 22587..22594. -/
theorem preserved_unlisted (base : Nat → GraphNode) (i : Nat) (bound : i < 22595)
    (outside : i ∉ selectedInputs) :
    ShapelessCall.roles base (closedShape [1, 1]) i = base i := by
  exact unchanged base i
    (outside_id i 1330 outside (by decide))
    (outside_id i 1331 outside (by decide))
    (outside_id i 15262 outside (by decide))
    (outside_id i 15264 outside (by decide))
    (outside_id i 22586 outside (by decide))
    (outside_id i 15263 outside (by decide))
    (outside_id i 15265 outside (by decide))
    (before_fresh i 22595 bound (by decide))
    (outside_id i 15266 outside (by decide))
    (before_fresh i 22596 bound (by decide))
    (outside_id i 15267 outside (by decide))
    (before_fresh i 22597 bound (by decide))
    (outside_id i 15268 outside (by decide))
    (before_fresh i 22598 bound (by decide))
    (outside_id i 15269 outside (by decide))
    (outside_id i 15270 outside (by decide))
    (before_fresh i 22599 bound (by decide))
    (outside_id i 15271 outside (by decide))
    (before_fresh i 22600 bound (by decide))
    (outside_id i 15272 outside (by decide))
    (before_fresh i 22601 bound (by decide))

theorem selected_below (i : Nat) (member : i ∈ selectedInputs) : i < 22587 := by
  simp only [selectedInputs, List.mem_cons, List.mem_nil_iff, or_false] at member
  rcases member with rfl | rfl | rfl | rfl | rfl | rfl | rfl | rfl | rfl | rfl | rfl | rfl | rfl | rfl
  all_goals decide

theorem preserved_produced (base : Nat → GraphNode) (i : Nat) (lower : 22587 ≤ i) (bound : i < 22595) :
    ShapelessCall.roles base (closedShape [1, 1]) i = base i := by
  have outside : i ∉ selectedInputs := by
    intro member
    exact Nat.lt_irrefl i (Nat.lt_of_lt_of_le (selected_below i member) lower)
  exact preserved_unlisted base i bound outside

private theorem from_seed (base : Nat → GraphNode)
    (agrees : ∀ i, i ∈ selectedInputs → base i = ShapelessRoleCompatibility.seedRoles i)
    (i : Nat) (member : i ∈ selectedInputs) (bound : i < 22587)
    (reduced : ShapelessCall.roles base (closedShape [1, 1]) i =
      ShapelessCall.roles ShapelessRoleCompatibility.seedRoles (closedShape [1, 1]) i) :
    ShapelessCall.roles base (closedShape [1, 1]) i = base i := by
  rw [reduced, ShapelessRoleCompatibility.preserved i bound]
  exact (agrees i member).symm

private theorem scalar_reduced (base : Nat → GraphNode) :
    ShapelessCall.roles base (closedShape [1, 1]) 15269 =
      {base 15269 with shape := [], dtype := 12} := by
  host_kernel_rfl

private theorem scalar_idempotent :
    {ShapelessRoleCompatibility.seedRoles 15269 with shape := [], dtype := 12} =
      ShapelessRoleCompatibility.seedRoles 15269 := by
  rw [← scalar_reduced ShapelessRoleCompatibility.seedRoles]
  exact ShapelessRoleCompatibility.preserved 15269 (by decide)

private theorem at_scalar (base : Nat → GraphNode)
    (agrees : ∀ i, i ∈ selectedInputs → base i = ShapelessRoleCompatibility.seedRoles i) :
    ShapelessCall.roles base (closedShape [1, 1]) 15269 = base 15269 := by
  rw [scalar_reduced base, agrees 15269 (by decide)]
  exact scalar_idempotent

private theorem selected_role (base : Nat → GraphNode)
    (agrees : ∀ i, i ∈ selectedInputs → base i = ShapelessRoleCompatibility.seedRoles i)
    (i : Nat) (member : i ∈ selectedInputs) :
    ShapelessCall.roles base (closedShape [1, 1]) i = base i := by
  simp only [selectedInputs, List.mem_cons, List.mem_nil_iff, or_false] at member
  rcases member with rfl | rfl | rfl | rfl | rfl | rfl | rfl | rfl | rfl | rfl | rfl | rfl | rfl | rfl
  · exact from_seed base agrees 1330 (by decide) (by decide) (by host_kernel_rfl)
  · exact from_seed base agrees 1331 (by decide) (by decide) (by host_kernel_rfl)
  · exact from_seed base agrees 15262 (by decide) (by decide) (by host_kernel_rfl)
  · exact from_seed base agrees 15263 (by decide) (by decide) (by host_kernel_rfl)
  · exact from_seed base agrees 15264 (by decide) (by decide) (by host_kernel_rfl)
  · exact from_seed base agrees 22586 (by decide) (by decide) (by host_kernel_rfl)
  · exact from_seed base agrees 15265 (by decide) (by decide) (by host_kernel_rfl)
  · exact from_seed base agrees 15266 (by decide) (by decide) (by host_kernel_rfl)
  · exact from_seed base agrees 15267 (by decide) (by decide) (by host_kernel_rfl)
  · exact from_seed base agrees 15268 (by decide) (by decide) (by host_kernel_rfl)
  · exact at_scalar base agrees
  · exact from_seed base agrees 15270 (by decide) (by decide) (by host_kernel_rfl)
  · exact from_seed base agrees 15271 (by decide) (by decide) (by host_kernel_rfl)
  · exact from_seed base agrees 15272 (by decide) (by decide) (by host_kernel_rfl)

/-- Current role data, on the fourteen selected ids, is unchanged by the leading
batch shape for every node below the first fresh replay id. -/
theorem preserved (base : Nat → GraphNode)
    (agrees : ∀ i, i ∈ selectedInputs → base i = ShapelessRoleCompatibility.seedRoles i)
    (i : Nat) (bound : i < 22595) :
    ShapelessCall.roles base (closedShape [1, 1]) i = base i := by
  by_cases membership : i ∈ selectedInputs
  · exact selected_role base agrees i membership
  · exact preserved_unlisted base i bound membership

/-- A missing graph is a shapeless boundary node. The eight captured producers
are the trace order, and agreement keeps each of their graphs. -/
theorem erased_boundary (base : Nat → GraphNode)
    (agrees : ∀ i, i ∈ selectedInputs → base i = ShapelessRoleCompatibility.seedRoles i)
    (i : Nat) (erased : (base i).graph = none) : ShapelessCall.boundary i := by
  intro member
  simp only [ShapelessCall.trace, Shapeless.trace, List.mem_cons, List.mem_nil_iff, or_false] at member
  rcases member with rfl | rfl | rfl | rfl | rfl | rfl | rfl | rfl
  all_goals
    rw [agrees _ (by decide)] at erased
    exact (ShapelessRoleCompatibility.erased_boundary _ erased) (by decide)

/-- The scalar leaf keeps its captured `.data` producer under the replay role map. -/
theorem scalar_data (base : Nat → GraphNode)
    (agrees : ∀ i, i ∈ selectedInputs → base i = ShapelessRoleCompatibility.seedRoles i) :
    (ShapelessCall.roles base (closedShape [1, 1]) 15269).graph =
      some (.data [CapturedShapelessSeed.zeroPart, CapturedShapelessSeed.zeroPart], []) := by
  rw [preserved base agrees 15269 (by decide), agrees 15269 (by decide)]
  exact ShapelessRoleCompatibility.scalar_data

private theorem fresh_22595 (base : Nat → GraphNode) :
    (ShapelessCall.roles base (closedShape [1, 1]) 22595).graph =
      some (.replayed 18194 (.astype 10), [1330]) := by
  host_kernel_rfl

private theorem fresh_22596 (base : Nat → GraphNode) :
    (ShapelessCall.roles base (closedShape [1, 1]) 22596).graph =
      some (.replayed 18194 (.unary chars!"exp"), [22595]) := by
  host_kernel_rfl

private theorem fresh_22597 (base : Nat → GraphNode) :
    (ShapelessCall.roles base (closedShape [1, 1]) 22597).graph =
      some (.replayed 18194 (.unary chars!"negative"), [22596]) := by
  host_kernel_rfl

private theorem fresh_22598 (base : Nat → GraphNode) :
    (ShapelessCall.roles base (closedShape [1, 1]) 22598).graph =
      some (.replayed 18194 (.binary chars!"add"), [22586, 1331]) := by
  host_kernel_rfl

private theorem fresh_22599 (base : Nat → GraphNode) :
    (ShapelessCall.roles base (closedShape [1, 1]) 22599).graph =
      some (.replayed 18194 (.binary chars!"logaddexp"), [22598, 15269]) := by
  host_kernel_rfl

private theorem fresh_22600 (base : Nat → GraphNode) :
    (ShapelessCall.roles base (closedShape [1, 1]) 22600).graph =
      some (.replayed 18194 (.binary chars!"multiply"), [22597, 22599]) := by
  host_kernel_rfl

private theorem fresh_22601 (base : Nat → GraphNode) :
    (ShapelessCall.roles base (closedShape [1, 1]) 22601).graph =
      some (.replayed 18194 (.unary chars!"exp"), [22600]) := by
  host_kernel_rfl

theorem fresh_graph (base : Nat → GraphNode) (i : Nat)
    (fresh : i = 22595 ∨ i = 22596 ∨ i = 22597 ∨ i = 22598 ∨ i = 22599 ∨ i = 22600 ∨ i = 22601) :
    (ShapelessCall.roles base (closedShape [1, 1]) i).graph ≠ none := by
  rcases fresh with rfl | rfl | rfl | rfl | rfl | rfl | rfl
  · rw [fresh_22595 base]; intro erased; cases erased
  · rw [fresh_22596 base]; intro erased; cases erased
  · rw [fresh_22597 base]; intro erased; cases erased
  · rw [fresh_22598 base]; intro erased; cases erased
  · rw [fresh_22599 base]; intro erased; cases erased
  · rw [fresh_22600 base]; intro erased; cases erased
  · rw [fresh_22601 base]; intro erased; cases erased

private theorem deny_fresh (i : Nat)
    (notFresh : ¬ (i = 22595 ∨ i = 22596 ∨ i = 22597 ∨ i = 22598 ∨ i = 22599 ∨ i = 22600 ∨ i = 22601)) :
    i ≠ 22595 ∧ i ≠ 22596 ∧ i ≠ 22597 ∧ i ≠ 22598 ∧ i ≠ 22599 ∧ i ≠ 22600 ∧ i ≠ 22601 := by
  refine ⟨?_, ?_, ?_, ?_, ?_, ?_, ?_⟩
  · intro equal; exact notFresh (Or.inl equal)
  · intro equal; exact notFresh (Or.inr (Or.inl equal))
  · intro equal; exact notFresh (Or.inr (Or.inr (Or.inl equal)))
  · intro equal; exact notFresh (Or.inr (Or.inr (Or.inr (Or.inl equal))))
  · intro equal; exact notFresh (Or.inr (Or.inr (Or.inr (Or.inr (Or.inl equal)))))
  · intro equal; exact notFresh (Or.inr (Or.inr (Or.inr (Or.inr (Or.inr (Or.inl equal))))))
  · intro equal; exact notFresh (Or.inr (Or.inr (Or.inr (Or.inr (Or.inr (Or.inr equal))))))

private theorem roles_not_fresh (base : Nat → GraphNode)
    (agrees : ∀ i, i ∈ selectedInputs → base i = ShapelessRoleCompatibility.seedRoles i)
    (i : Nat)
    (notFresh : ¬ (i = 22595 ∨ i = 22596 ∨ i = 22597 ∨ i = 22598 ∨ i = 22599 ∨ i = 22600 ∨ i = 22601)) :
    ShapelessCall.roles base (closedShape [1, 1]) i = base i := by
  by_cases membership : i ∈ selectedInputs
  · exact selected_role base agrees i membership
  · obtain ⟨n22595, n22596, n22597, n22598, n22599, n22600, n22601⟩ := deny_fresh i notFresh
    exact unchanged base i
      (outside_id i 1330 membership (by decide))
      (outside_id i 1331 membership (by decide))
      (outside_id i 15262 membership (by decide))
      (outside_id i 15264 membership (by decide))
      (outside_id i 22586 membership (by decide))
      (outside_id i 15263 membership (by decide))
      (outside_id i 15265 membership (by decide))
      n22595
      (outside_id i 15266 membership (by decide))
      n22596
      (outside_id i 15267 membership (by decide))
      n22597
      (outside_id i 15268 membership (by decide))
      n22598
      (outside_id i 15269 membership (by decide))
      (outside_id i 15270 membership (by decide))
      n22599
      (outside_id i 15271 membership (by decide))
      n22600
      (outside_id i 15272 membership (by decide))
      n22601

theorem fresh_not_supported (N : Nat → Prop) (below : ∀ i, N i → i < 22595)
    (covered : ∀ i, ShapelessCall.N0 i → N i) (i : Nat)
    (fresh : i = 22595 ∨ i = 22596 ∨ i = 22597 ∨ i = 22598 ∨ i = 22599 ∨ i = 22600 ∨ i = 22601) :
    ¬ (ShapelessCall.N0 i ∨ N i) := by
  intro held
  have low : i < 22595 := below i (held.elim (covered i) id)
  rcases fresh with rfl | rfl | rfl | rfl | rfl | rfl | rfl
  all_goals exact absurd low (by decide)

/-- Retag the current strong relation onto the shapeless role map. `agrees` is
current role data. The `True` boundary is the relation being retagged; no target
replay, target trace, or future policy is assumed. -/
theorem native_retag (base : Nat → GraphNode)
    (agrees : ∀ i, i ∈ selectedInputs → base i = ShapelessRoleCompatibility.seedRoles i)
    {ν₀ ν : Nat → F64} {C₀ C : CSrv} {R : Ren}
    {objects : Nat → Object} {H N : Nat → Prop} {tail : List NumV}
    {source target : Host.Mlx.Ffi.St}
    (below : ∀ i, N i → i < 22595) (covered : ∀ i, ShapelessCall.N0 i → N i)
    (native : Live (NumberRoles ν₀ ν C₀ C) R
      (NodeRel base ν₀ ν C₀ C R (fun _ => True))
      (ObjectRel objects ν₀ ν C₀ C R) H N tail source target) :
    Live (NumberRoles ν₀ ν C₀ C) R
      (NodeRel (ShapelessCall.roles base (closedShape [1, 1])) ν₀ ν C₀ C R ShapelessCall.boundary)
      (ObjectRel objects ν₀ ν C₀ C R) H (fun i => ShapelessCall.N0 i ∨ N i) tail source target := by
  have indexed := native.restrictSupport
    (fun i held => held.elim (covered i) id)
    (fun handle index held read => Or.inr (native.arrLive handle index held read))
  refine {indexed with nodes := ?_}
  intro i held
  have supported : N i := held.elim (covered i) id
  have same := preserved base agrees i (below i supported)
  exact (indexed.nodes i held).mono (fun _ _ paired =>
    ⟨same.symm ▸ paired.source, same.symm ▸ paired.target,
      fun absent => erased_boundary base agrees i (same ▸ absent)⟩)

theorem state_retag (base : Nat → GraphNode)
    (agrees : ∀ i, i ∈ selectedInputs → base i = ShapelessRoleCompatibility.seedRoles i)
    {ν₀ ν : Nat → F64} {C₀ C : CSrv} {R : Ren}
    {objects : Nat → Object} {H N : Nat → Prop} {tail : List NumV}
    {host : HostSt → HostSt → Prop} {live framed : Nat → Prop}
    {before after : List Val} {old old' : List Event} {source target : St LSt}
    (below : ∀ i, N i → i < 22595) (covered : ∀ i, ShapelessCall.N0 i → N i)
    (state : StateR (NumberRoles ν₀ ν C₀ C)
      (VectorHost.NativeRelation ν₀ ν C₀ C base (fun _ => True) objects H N tail host)
      R live framed before after old old' source target) :
    StateR (NumberRoles ν₀ ν C₀ C)
      (VectorHost.NativeRelation ν₀ ν C₀ C (ShapelessCall.roles base (closedShape [1, 1]))
        ShapelessCall.boundary objects H (fun i => ShapelessCall.N0 i ∨ N i) tail host)
      R live framed before after old old' source target :=
  {state with native := ⟨state.native.1, native_retag base agrees below covered state.native.2⟩}

/-- Roots stay checked for every id, including ids outside `N`. The seven fresh
graphs are present, so a missing graph still falls through to the current role. -/
theorem policy_retag (base : Nat → GraphNode)
    (agrees : ∀ i, i ∈ selectedInputs → base i = ShapelessRoleCompatibility.seedRoles i)
    {roots H N : Nat → Prop} {objects : Nat → Object}
    (below : ∀ i, N i → i < 22595) (covered : ∀ i, ShapelessCall.N0 i → N i)
    (policy : ProducerAnnotations roots H N base objects) :
    ProducerAnnotations roots H (fun i => ShapelessCall.N0 i ∨ N i)
      (ShapelessCall.roles base (closedShape [1, 1])) objects := by
  have indexed := policy.reindex (fun i =>
    ⟨fun held => Or.inr held, fun held => held.elim (covered i) id⟩)
  refine {indexed with roots := ?_, nodes := ?_}
  · intro i absent
    by_cases fresh : i = 22595 ∨ i = 22596 ∨ i = 22597 ∨ i = 22598 ∨ i = 22599 ∨ i = 22600 ∨ i = 22601
    · exact absurd absent (fresh_graph base i fresh)
    · exact indexed.roots i ((roles_not_fresh base agrees i fresh) ▸ absent)
  · intro i held primitive inputs graph
    have supported : N i := held.elim (covered i) id
    have same := preserved base agrees i (below i supported)
    exact indexed.nodes i held primitive inputs (same ▸ graph)

theorem source_first_node : ShapelessCall.s0.nnext = 22595 := by
  host_kernel_rfl

theorem source_input_ids :
    ShapelessCall.source.obj? 29382 = some (.vec [1330, 22586, 1331]) := by
  host_kernel_rfl

noncomputable def sourcePayload : Arg :=
  match ShapelessCall.source.obj? 18194 with
  | some (.clo (.compiled _ payload _ _)) => payload
  | _ => .null

theorem source_closure_ids : ShapelessCall.source.obj? 18194 =
    some (.clo (.compiled 281474976715599 sourcePayload true
      [⟨[15262, 15263, 15264], [15272], [15265, 15266, 15267, 15268, 15269, 15270, 15271, 15272]⟩])) := by
  host_kernel_rfl

open Lean Elab Command in
run_cmd do
  for claim in [
      "theorem changed_first_fresh : ShapelessCall.s0.nnext = 22594 := by host_kernel_rfl",
      "theorem changed_captured_scalar : (ShapelessRoleCompatibility.seedRoles 15269).graph = none := by host_kernel_rfl"] do
    let saved : Lean.Elab.Command.State ← get
    let count := saved.messages.toList.length
    let mut rejected := false
    try Host.Ts.Owned.Parametric.Driver.emit claim
    catch exception =>
      rejected := ((← exception.toMessageData.toString).splitOn "(kernel) declaration type mismatch").length > 1
    for message in (← get).messages.toList.drop count do
      if ((← message.data.toString).splitOn "(kernel) declaration type mismatch").length > 1 then rejected := true
    set saved
    unless rejected do throwError "shapeless frame retag negative did not reach its intended kernel rejection: {claim}"

end Host.Load.Run.Full.Ordinary.RankOrigin.ShapelessFrameRetag
