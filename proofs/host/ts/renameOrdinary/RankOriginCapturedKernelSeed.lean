import host.ts.renameOrdinary.RankOriginGeometrySeed
import host.mlx.OrdinaryCachedAnnotations

set_option Elab.async false
set_option maxRecDepth 1000000
set_option maxHeartbeats 1000000
namespace Host.Load.Run.Full.Ordinary.RankOrigin.CapturedKernelSeed
open Host.Ts Host.Ts.Owned Host.Ts.Owned.Parametric Host.Ts.Owned.Annotated
open Host.Mlx.Ffi Host.Mlx.Ffi.Annotated

def selected (i : Nat) : Prop := i = 15255 ∨ i = 15256 ∨ i = 15257
instance (i : Nat) : Decidable (selected i) := inferInstanceAs (Decidable (i = 15255 ∨ i = 15256 ∨ i = 15257))
noncomputable def role (i : Nat) : GraphNode := CachedCall.baseRoles (fun _ => ⟨[],0,none⟩) i
noncomputable def enrich (base : Nat → GraphNode) (i : Nat) : GraphNode :=
  if selected i then role i else base i
noncomputable def sourceNode (i : Nat) : Node :=
  (input.ffi.mlx.nodes.get i).getD ⟨.zeros,[],[],0⟩

theorem source_lookup (i : Nat) (chosen : selected i) :
    input.ffi.mlx.nodes.get i = some (sourceNode i) := by
  rcases chosen with rfl | rfl | rfl <;> host_kernel_rfl

theorem other (base : Nat → GraphNode) (i : Nat) (outside : ¬ selected i) : enrich base i = base i :=
  ite_eq_right outside

/-- These three captured kernel producers already exist in the initialized
graph. Their exact primitive, configuration, input IDs and output geometry are
checked at that reached source, before the later compiled replay uses them. -/
theorem source_annotation (ν : Nat → F64) (C : CSrv) (i : Nat) (n : Node)
    (chosen : selected i) (read : input.ffi.mlx.nodes.get i = some n) :
    (role i).Holds ν C identity n := by
  have same : n = sourceNode i := Option.some.inj (read.symm.trans (source_lookup i chosen))
  subst n
  rcases chosen with rfl | rfl | rfl
  · exact CachedCall.kernel_node_holds ν C [1,1,16,128] 0 _
      (by dsimp [listSupport]; decide +kernel) (by host_kernel_rfl) (by host_kernel_rfl)
      (by host_kernel_rfl) (by host_kernel_rfl)
  · exact CachedCall.kernel_node_holds ν C [1,1,16,128] 1 _
      (by dsimp [listSupport]; decide +kernel) (by host_kernel_rfl) (by host_kernel_rfl)
      (by host_kernel_rfl) (by host_kernel_rfl)
  · exact CachedCall.kernel_node_holds ν C [1,1,48,128] 2 _
      (by dsimp [listSupport]; decide +kernel) (by host_kernel_rfl) (by host_kernel_rfl)
      (by host_kernel_rfl) (by host_kernel_rfl)

theorem graph_inputs (i : Nat) (chosen : selected i) (primitive : Primitive) (inputs : List Nat)
    (graph : (role i).graph = some (primitive,inputs)) : inputs = [15252,15253,15254] := by
  rcases chosen with rfl | rfl | rfl
  all_goals
    have same := congrArg Prod.snd (Option.some.inj graph)
    exact same.symm

theorem graph_present (i : Nat) (chosen : selected i) : (role i).graph ≠ none := by
  rcases chosen with rfl | rfl | rfl <;> intro impossible <;> cases impossible

open Lean Elab Command in
run_cmd do
  for claim in [
      "theorem wrong_kernel_output : (sourceNode 15255).prim = .kernel 18182 CachedCall.capturedConfig 1 := by host_kernel_rfl",
      "theorem erased_kernel : (role 15255).graph = none := by host_kernel_rfl"] do
    let saved : Lean.Elab.Command.State ← get
    let count := saved.messages.toList.length
    let mut rejected := false
    try Host.Ts.Owned.Parametric.Driver.emit claim
    catch exception =>
      rejected := ((← exception.toMessageData.toString).splitOn "(kernel) declaration type mismatch").length > 1
    for message in (← get).messages.toList.drop count do
      if ((← message.data.toString).splitOn "(kernel) declaration type mismatch").length > 1 then rejected := true
    set saved
    unless rejected do throwError "captured-kernel negative did not reach its intended kernel rejection: {claim}"

end Host.Load.Run.Full.Ordinary.RankOrigin.CapturedKernelSeed
