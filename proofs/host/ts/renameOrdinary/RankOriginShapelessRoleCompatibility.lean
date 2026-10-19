import host.ts.renameOrdinary.RankOriginCapturedShapelessSeed
import host.ts.renameOrdinary.RankOriginCapturedKernelSeed
import host.mlx.OrdinaryShapelessPlan
import host.mlx.NativeIdentitySeed
import host.ts.RenameKernelRfl
import host.ts.RenameRouteDriver

set_option Elab.async false
set_option maxRecDepth 1000000
set_option maxHeartbeats 0

namespace Host.Load.Run.Full.Ordinary.RankOrigin.ShapelessRoleCompatibility
open Host.Mlx.Ffi Host.Mlx.Ffi.Annotated Host.Mlx.Ffi.Annotated.Initial

/-- Initialized producers carried into the shapeless replay. Kernel capture is
applied before shapeless capture, and neither import uses `NativeFacts`. -/
noncomputable def seedRoles : Nat → GraphNode :=
  CapturedShapelessSeed.enrich
    (CapturedKernelSeed.enrich
      (Geometry.entryRoles (Initial.nodeRoles input.ffi.mlx)))

noncomputable def initializedNode (i : Nat) : Node :=
  (input.ffi.mlx.nodes.get i).getD ⟨.zeros, [], [], 0⟩

theorem tensor_batch :
    ShapelessCall.tensor (closedShape [1, 1]) = closedShape [1, 1, 48] := by
  simp only [ShapelessCall.tensor, ShapelessCall.width, closedShape]
  rw [← List.map_append]
  rfl

private theorem literal_closed (shape : List Int) (dtype : Nat) (n : Node)
    (hs : n.shape = shape.map Dim.lit) (hd : n.dtype = dtype) :
    literalNode n = ⟨closedShape shape, dtype, none⟩ := by
  simp only [literalNode, hs, hd, closedShape, List.map_map, literalDimension, Function.comp_def]

private theorem seed_literal (i : Nat) (shape : List Int) (dtype : Nat)
    (notShapeless : ¬ CapturedShapelessSeed.selected i)
    (notKernel : ¬ CapturedKernelSeed.selected i) (notHidden : i ≠ 22582)
    (read : input.ffi.mlx.nodes.get i = some (initializedNode i))
    (hs : (initializedNode i).shape = shape.map Dim.lit) (hd : (initializedNode i).dtype = dtype) :
    seedRoles i = ⟨closedShape shape, dtype, none⟩ := by
  unfold seedRoles
  rw [CapturedShapelessSeed.other _ i notShapeless, CapturedKernelSeed.other _ i notKernel]
  have entry : Geometry.entryRoles (nodeRoles input.ffi.mlx) i = nodeRoles input.ffi.mlx i := by
    simp only [Geometry.entryRoles, ite_eq_right notHidden]
  rw [entry, nodeRoles, read]
  exact literal_closed shape dtype (initializedNode i) hs hd

private theorem seed_producer (i : Nat) (chosen : CapturedShapelessSeed.selected i) :
    seedRoles i = CapturedShapelessSeed.role i := by
  unfold seedRoles
  simp only [CapturedShapelessSeed.enrich, ite_eq_left chosen]

theorem source_1330_shape : (initializedNode 1330).shape = [.lit 48] := by host_kernel_rfl
theorem source_1330_dtype : (initializedNode 1330).dtype = 12 := by host_kernel_rfl
theorem source_1331_shape : (initializedNode 1331).shape = [.lit 48] := by host_kernel_rfl
theorem source_1331_dtype : (initializedNode 1331).dtype = 12 := by host_kernel_rfl
theorem source_15262_shape : (initializedNode 15262).shape = [.lit 48] := by host_kernel_rfl
theorem source_15262_dtype : (initializedNode 15262).dtype = 12 := by host_kernel_rfl
theorem source_15264_shape : (initializedNode 15264).shape = [.lit 48] := by host_kernel_rfl
theorem source_15264_dtype : (initializedNode 15264).dtype = 12 := by host_kernel_rfl
theorem source_15263_shape : (initializedNode 15263).shape = [.lit 1, .lit 1, .lit 48] := by host_kernel_rfl
theorem source_15263_dtype : (initializedNode 15263).dtype = 12 := by host_kernel_rfl
theorem source_22586_shape : (initializedNode 22586).shape = [.lit 1, .lit 1, .lit 48] := by host_kernel_rfl
theorem source_22586_dtype : (initializedNode 22586).dtype = 12 := by host_kernel_rfl

private theorem read_initialized (i : Nat)
    (id : i = 1330 ∨ i = 1331 ∨ i = 15262 ∨ i = 15263 ∨ i = 15264 ∨ i = 22586) :
    input.ffi.mlx.nodes.get i = some (initializedNode i) := by
  rcases id with rfl | rfl | rfl | rfl | rfl | rfl <;> host_kernel_rfl

private theorem seed_1330 : seedRoles 1330 = ⟨closedShape [48], 12, none⟩ :=
  seed_literal 1330 [48] 12 (by decide) (by decide) (by decide)
    (read_initialized 1330 (by decide)) (by rw [source_1330_shape]; rfl) source_1330_dtype

private theorem seed_1331 : seedRoles 1331 = ⟨closedShape [48], 12, none⟩ :=
  seed_literal 1331 [48] 12 (by decide) (by decide) (by decide)
    (read_initialized 1331 (by decide)) (by rw [source_1331_shape]; rfl) source_1331_dtype

private theorem seed_15262 : seedRoles 15262 = ⟨closedShape [48], 12, none⟩ :=
  seed_literal 15262 [48] 12 (by decide) (by decide) (by decide)
    (read_initialized 15262 (by decide)) (by rw [source_15262_shape]; rfl) source_15262_dtype

private theorem seed_15264 : seedRoles 15264 = ⟨closedShape [48], 12, none⟩ :=
  seed_literal 15264 [48] 12 (by decide) (by decide) (by decide)
    (read_initialized 15264 (by decide)) (by rw [source_15264_shape]; rfl) source_15264_dtype

private theorem seed_15263 : seedRoles 15263 = ⟨closedShape [1, 1, 48], 12, none⟩ :=
  seed_literal 15263 [1, 1, 48] 12 (by decide) (by decide) (by decide)
    (read_initialized 15263 (by decide)) (by rw [source_15263_shape]; rfl) source_15263_dtype

private theorem seed_22586 : seedRoles 22586 = ⟨closedShape [1, 1, 48], 12, none⟩ :=
  seed_literal 22586 [1, 1, 48] 12 (by decide) (by decide) (by decide)
    (read_initialized 22586 (by decide)) (by rw [source_22586_shape]; rfl) source_22586_dtype

private theorem preserved_flat (i : Nat) (seed : seedRoles i = ⟨closedShape [48], 12, none⟩)
    (reduced : ShapelessCall.roles seedRoles (closedShape [1, 1]) i = ⟨closedShape [48], 12, none⟩) :
    ShapelessCall.roles seedRoles (closedShape [1, 1]) i = seedRoles i := by
  rw [reduced, seed]

private theorem preserved_batch (i : Nat) (seed : seedRoles i = ⟨closedShape [1, 1, 48], 12, none⟩)
    (reduced : ShapelessCall.roles seedRoles (closedShape [1, 1]) i = ⟨closedShape [1, 1, 48], 12, none⟩) :
    ShapelessCall.roles seedRoles (closedShape [1, 1]) i = seedRoles i := by
  rw [reduced, seed]

private theorem flat_1330 : ShapelessCall.roles seedRoles (closedShape [1, 1]) 1330 = ⟨closedShape [48], 12, none⟩ := by
  host_kernel_rfl

private theorem flat_1331 : ShapelessCall.roles seedRoles (closedShape [1, 1]) 1331 = ⟨closedShape [48], 12, none⟩ := by
  host_kernel_rfl

private theorem flat_15262 : ShapelessCall.roles seedRoles (closedShape [1, 1]) 15262 = ⟨closedShape [48], 12, none⟩ := by
  host_kernel_rfl

private theorem flat_15264 : ShapelessCall.roles seedRoles (closedShape [1, 1]) 15264 = ⟨closedShape [48], 12, none⟩ := by
  host_kernel_rfl

private theorem batch_15263 : ShapelessCall.roles seedRoles (closedShape [1, 1]) 15263 = ⟨closedShape [1, 1, 48], 12, none⟩ := by
  host_kernel_rfl

private theorem batch_22586 : ShapelessCall.roles seedRoles (closedShape [1, 1]) 22586 = ⟨closedShape [1, 1, 48], 12, none⟩ := by
  host_kernel_rfl

private theorem preserved_1330 : ShapelessCall.roles seedRoles (closedShape [1, 1]) 1330 = seedRoles 1330 :=
  preserved_flat 1330 seed_1330 flat_1330

private theorem preserved_1331 : ShapelessCall.roles seedRoles (closedShape [1, 1]) 1331 = seedRoles 1331 :=
  preserved_flat 1331 seed_1331 flat_1331

private theorem preserved_15262 : ShapelessCall.roles seedRoles (closedShape [1, 1]) 15262 = seedRoles 15262 :=
  preserved_flat 15262 seed_15262 flat_15262

private theorem preserved_15264 : ShapelessCall.roles seedRoles (closedShape [1, 1]) 15264 = seedRoles 15264 :=
  preserved_flat 15264 seed_15264 flat_15264

private theorem preserved_15263 : ShapelessCall.roles seedRoles (closedShape [1, 1]) 15263 = seedRoles 15263 :=
  preserved_batch 15263 seed_15263 batch_15263

private theorem preserved_22586 : ShapelessCall.roles seedRoles (closedShape [1, 1]) 22586 = seedRoles 22586 :=
  preserved_batch 22586 seed_22586 batch_22586

private theorem producer_agrees (i : Nat) (chosen : CapturedShapelessSeed.selected i)
    (reduced : ShapelessCall.roles seedRoles (closedShape [1, 1]) i = CapturedShapelessSeed.role i) :
    ShapelessCall.roles seedRoles (closedShape [1, 1]) i = seedRoles i := by
  rw [reduced, seed_producer i chosen]

private theorem reduced_15265 : ShapelessCall.roles seedRoles (closedShape [1, 1]) 15265 = CapturedShapelessSeed.role 15265 := by
  host_kernel_rfl

private theorem reduced_15266 : ShapelessCall.roles seedRoles (closedShape [1, 1]) 15266 = CapturedShapelessSeed.role 15266 := by
  host_kernel_rfl

private theorem reduced_15267 : ShapelessCall.roles seedRoles (closedShape [1, 1]) 15267 = CapturedShapelessSeed.role 15267 := by
  host_kernel_rfl

private theorem reduced_15268 : ShapelessCall.roles seedRoles (closedShape [1, 1]) 15268 = CapturedShapelessSeed.role 15268 := by
  host_kernel_rfl

private theorem reduced_15269 : ShapelessCall.roles seedRoles (closedShape [1, 1]) 15269 = CapturedShapelessSeed.role 15269 := by
  host_kernel_rfl

private theorem reduced_15270 : ShapelessCall.roles seedRoles (closedShape [1, 1]) 15270 = CapturedShapelessSeed.role 15270 := by
  host_kernel_rfl

private theorem reduced_15271 : ShapelessCall.roles seedRoles (closedShape [1, 1]) 15271 = CapturedShapelessSeed.role 15271 := by
  host_kernel_rfl

private theorem reduced_15272 : ShapelessCall.roles seedRoles (closedShape [1, 1]) 15272 = CapturedShapelessSeed.role 15272 := by
  host_kernel_rfl

/-- The scalar leaf keeps its initialized `.data` producer; the replay does not erase it. -/
theorem scalar_data : (seedRoles 15269).graph =
    some (.data [CapturedShapelessSeed.zeroPart, CapturedShapelessSeed.zeroPart], []) := by
  rw [seed_producer 15269 (by decide)]
  rfl

private theorem below_replay (i n : Nat) (bound : i < 22587) (atLeast : 22587 ≤ n) : i ≠ n :=
  Nat.ne_of_lt (Nat.lt_of_lt_of_le bound atLeast)

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

private theorem preserved_other (i : Nat) (bound : i < 22587)
    (h1330 : i ≠ 1330) (h1331 : i ≠ 1331) (h15262 : i ≠ 15262) (h15264 : i ≠ 15264)
    (h22586 : i ≠ 22586) (h15263 : i ≠ 15263) (h15265 : i ≠ 15265) (h15266 : i ≠ 15266)
    (h15267 : i ≠ 15267) (h15268 : i ≠ 15268) (h15269 : i ≠ 15269) (h15270 : i ≠ 15270)
    (h15271 : i ≠ 15271) (h15272 : i ≠ 15272) :
    ShapelessCall.roles seedRoles (closedShape [1, 1]) i = seedRoles i := by
  have h22595 := below_replay i 22595 bound (by decide)
  have h22596 := below_replay i 22596 bound (by decide)
  have h22597 := below_replay i 22597 bound (by decide)
  have h22598 := below_replay i 22598 bound (by decide)
  have h22599 := below_replay i 22599 bound (by decide)
  have h22600 := below_replay i 22600 bound (by decide)
  have h22601 := below_replay i 22601 bound (by decide)
  rw [roles_default seedRoles (closedShape [1, 1]) i h22586 h15263 h15268 h15270 h15271 h15272
    h22598 h22599 h22600 h22601]
  exact fixed_default seedRoles i h1330 h1331 h15262 h15264 h22586 h15263 h15265 h22595 h15266
    h22596 h15267 h22597 h15268 h22598 h15269 h15270 h22599 h15271 h22600 h15272 h22601

theorem preserved (i : Nat) (bound : i < 22587) :
    ShapelessCall.roles seedRoles (closedShape [1, 1]) i = seedRoles i := by
  by_cases h1330 : i = 1330
  · subst h1330; exact preserved_1330
  by_cases h1331 : i = 1331
  · subst h1331; exact preserved_1331
  by_cases h15262 : i = 15262
  · subst h15262; exact preserved_15262
  by_cases h15264 : i = 15264
  · subst h15264; exact preserved_15264
  by_cases h22586 : i = 22586
  · subst h22586; exact preserved_22586
  by_cases h15263 : i = 15263
  · subst h15263; exact preserved_15263
  by_cases h15265 : i = 15265
  · subst h15265; exact producer_agrees 15265 (by decide) reduced_15265
  by_cases h15266 : i = 15266
  · subst h15266; exact producer_agrees 15266 (by decide) reduced_15266
  by_cases h15267 : i = 15267
  · subst h15267; exact producer_agrees 15267 (by decide) reduced_15267
  by_cases h15268 : i = 15268
  · subst h15268; exact producer_agrees 15268 (by decide) reduced_15268
  by_cases h15269 : i = 15269
  · subst h15269; exact producer_agrees 15269 (by decide) reduced_15269
  by_cases h15270 : i = 15270
  · subst h15270; exact producer_agrees 15270 (by decide) reduced_15270
  by_cases h15271 : i = 15271
  · subst h15271; exact producer_agrees 15271 (by decide) reduced_15271
  by_cases h15272 : i = 15272
  · subst h15272; exact producer_agrees 15272 (by decide) reduced_15272
  · exact preserved_other i bound h1330 h1331 h15262 h15264 h22586 h15263 h15265 h15266 h15267
      h15268 h15269 h15270 h15271 h15272

theorem erased_boundary (i : Nat) (erased : (seedRoles i).graph = none) : ShapelessCall.boundary i := by
  intro member
  simp only [ShapelessCall.trace, Shapeless.trace, List.mem_cons, List.mem_nil_iff, or_false] at member
  rcases member with rfl | rfl | rfl | rfl | rfl | rfl | rfl | rfl
  all_goals
    rw [seed_producer _ (by decide)] at erased
    exact CapturedShapelessSeed.graph_present _ (by decide) erased

theorem native_below (i : Nat) (supported : ShapelessCall.N0 i) : i < 22587 := by
  simp only [ShapelessCall.N0, List.mem_cons, List.mem_nil_iff, or_false] at supported
  rcases supported with rfl | rfl | rfl | rfl | rfl | rfl | rfl | rfl | rfl | rfl | rfl | rfl | rfl | rfl
  all_goals decide +kernel

open Lean Elab Command in
run_cmd do
  for claim in [
      "theorem changed_captured_producer : (seedRoles 15269).graph = none := by host_kernel_rfl",
      "theorem changed_input_shape : (seedRoles 1330).shape = closedShape [1, 1, 48] := by host_kernel_rfl"] do
    let saved : Lean.Elab.Command.State ← get
    let count := saved.messages.toList.length
    let mut rejected := false
    try Host.Ts.Owned.Parametric.Driver.emit claim
    catch exception =>
      rejected := ((← exception.toMessageData.toString).splitOn "(kernel) declaration type mismatch").length > 1
    for message in (← get).messages.toList.drop count do
      if ((← message.data.toString).splitOn "(kernel) declaration type mismatch").length > 1 then rejected := true
    set saved
    unless rejected do throwError "shapeless role compatibility negative did not reach its intended kernel rejection: {claim}"

end Host.Load.Run.Full.Ordinary.RankOrigin.ShapelessRoleCompatibility
