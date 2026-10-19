import host.ts.renameOrdinary.RankOriginGeometrySeed
import host.ts.RenameKernelRfl
import host.ts.RenameAnnotations
import host.mlx.NativeAnnotations
import host.mlx.ClosedGeometry

set_option Elab.async false
set_option maxRecDepth 1000000
set_option maxHeartbeats 0

namespace Host.Load.Run.Full.Ordinary.RankOrigin.CapturedShapelessSeed
open Host.Ts Host.Ts.Owned Host.Ts.Owned.Parametric Host.Ts.Owned.Annotated
open Host.Mlx.Ffi Host.Mlx.Ffi.Annotated

def selected (i : Nat) : Prop :=
  i = 15265 ∨ i = 15266 ∨ i = 15267 ∨ i = 15268 ∨ i = 15269 ∨ i = 15270 ∨ i = 15271 ∨ i = 15272

instance (i : Nat) : Decidable (selected i) := inferInstanceAs
  (Decidable (i = 15265 ∨ i = 15266 ∨ i = 15267 ∨ i = 15268 ∨ i = 15269 ∨ i = 15270 ∨ i = 15271 ∨ i = 15272))

/-- Two zero `u8` parts are the initialized float16 scalar carried into `logaddexp`. -/
def zeroPart : Annotated.Byte := .part .u8 (.literal (.lit (F64.zero false))) 0

def role (i : Nat) : GraphNode :=
  match i with
  | 15265 => ⟨closedShape [48], 10, some (.astype 10, [15262])⟩
  | 15266 => ⟨closedShape [48], 10, some (.unary chars!"exp", [15265])⟩
  | 15267 => ⟨closedShape [48], 10, some (.unary chars!"negative", [15266])⟩
  | 15268 => ⟨closedShape [1, 1, 48], 12, some (.binary chars!"add", [15263, 15264])⟩
  | 15269 => ⟨closedShape [], 12, some (.data [zeroPart, zeroPart], [])⟩
  | 15270 => ⟨closedShape [1, 1, 48], 12, some (.binary chars!"logaddexp", [15268, 15269])⟩
  | 15271 => ⟨closedShape [1, 1, 48], 10, some (.binary chars!"multiply", [15267, 15270])⟩
  | 15272 => ⟨closedShape [1, 1, 48], 10, some (.unary chars!"exp", [15271])⟩
  | _ => ⟨[], 0, none⟩

def enrich (base : Nat → GraphNode) (i : Nat) : GraphNode :=
  if selected i then role i else base i

noncomputable def sourceNode (i : Nat) : Node :=
  (input.ffi.mlx.nodes.get i).getD ⟨.zeros, [], [], 0⟩

theorem source_lookup (i : Nat) (chosen : selected i) :
    input.ffi.mlx.nodes.get i = some (sourceNode i) := by
  rcases chosen with rfl | rfl | rfl | rfl | rfl | rfl | rfl | rfl <;> host_kernel_rfl

theorem other (base : Nat → GraphNode) (i : Nat) (outside : ¬ selected i) : enrich base i = base i :=
  ite_eq_right outside

theorem zero_part_holds (ν : Nat → F64) (C : CSrv) :
    zeroPart.Holds ν C identity (.part .u8 (.num (.lit (F64.zero false))) 0) :=
  .part .u8 (.literal (.lit (F64.zero false))) 0 (.num (.lit (F64.zero false)))
    (.literal (.lit (F64.zero false)) (F64.zero false) rfl)

theorem scalar_bytes_hold (ν : Nat → F64) (C : CSrv) :
    ListR (Byte.Holds ν C identity) [zeroPart, zeroPart]
      [.part .u8 (.num (.lit (F64.zero false))) 0, .part .u8 (.num (.lit (F64.zero false))) 0] :=
  .cons (zero_part_holds ν C) (.cons (zero_part_holds ν C) .nil)

private theorem producer_holds (ν : Nat → F64) (C : CSrv) (shape : List Int) (dtype : Nat)
    (ann : Primitive) (inputs : List Nat) (n : Node)
    (exact : listSupport (fun i => F64.toInt? (F64.ofInt i) = some i) shape)
    (hs : n.shape = shape.map Dim.lit) (hd : n.dtype = dtype)
    (hp : ann.Holds ν C identity n.prim) (hi : n.ins = inputs) :
    GraphNode.Holds ν C identity ⟨closedShape shape, dtype, some (ann, inputs)⟩ n := by
  refine ⟨?_, hd, ?_⟩
  · rw [hs]
    exact closedShape_holds ν C shape exact
  · intro p ins graph
    cases Option.some.inj graph
    refine ⟨hp, ?_⟩
    simpa only [identity, List.map_id_fun, id_eq] using hi

/-- The eight captured shapeless producers are already present at the initialized
source. Shape, dtype, primitive and input IDs are read from that graph. -/
theorem source_annotation (ν : Nat → F64) (C : CSrv) (i : Nat) (n : Node)
    (chosen : selected i) (read : input.ffi.mlx.nodes.get i = some n) :
    (role i).Holds ν C identity n := by
  have same : n = sourceNode i := Option.some.inj (read.symm.trans (source_lookup i chosen))
  subst n
  rcases chosen with rfl | rfl | rfl | rfl | rfl | rfl | rfl | rfl
  · exact producer_holds ν C [48] 10 (.astype 10) [15262] _
      (by dsimp [listSupport]; decide +kernel) (by host_kernel_rfl) (by host_kernel_rfl)
      (by rw [show (sourceNode 15265).prim = .astype 10 by host_kernel_rfl]; exact .astype 10)
      (by host_kernel_rfl)
  · exact producer_holds ν C [48] 10 (.unary chars!"exp") [15265] _
      (by dsimp [listSupport]; decide +kernel) (by host_kernel_rfl) (by host_kernel_rfl)
      (by rw [show (sourceNode 15266).prim = .unary chars!"exp" by host_kernel_rfl]; exact .unary _)
      (by host_kernel_rfl)
  · exact producer_holds ν C [48] 10 (.unary chars!"negative") [15266] _
      (by dsimp [listSupport]; decide +kernel) (by host_kernel_rfl) (by host_kernel_rfl)
      (by rw [show (sourceNode 15267).prim = .unary chars!"negative" by host_kernel_rfl]; exact .unary _)
      (by host_kernel_rfl)
  · exact producer_holds ν C [1, 1, 48] 12 (.binary chars!"add") [15263, 15264] _
      (by dsimp [listSupport]; decide +kernel) (by host_kernel_rfl) (by host_kernel_rfl)
      (by rw [show (sourceNode 15268).prim = .binary chars!"add" by host_kernel_rfl]; exact .binary _)
      (by host_kernel_rfl)
  · exact producer_holds ν C [] 12 (.data [zeroPart, zeroPart]) [] _
      (by dsimp [listSupport]) (by host_kernel_rfl) (by host_kernel_rfl)
      (by rw [show (sourceNode 15269).prim = .data
          [.part .u8 (.num (.lit (F64.zero false))) 0, .part .u8 (.num (.lit (F64.zero false))) 0]
          by host_kernel_rfl]; exact .data (scalar_bytes_hold ν C))
      (by host_kernel_rfl)
  · exact producer_holds ν C [1, 1, 48] 12 (.binary chars!"logaddexp") [15268, 15269] _
      (by dsimp [listSupport]; decide +kernel) (by host_kernel_rfl) (by host_kernel_rfl)
      (by rw [show (sourceNode 15270).prim = .binary chars!"logaddexp" by host_kernel_rfl]; exact .binary _)
      (by host_kernel_rfl)
  · exact producer_holds ν C [1, 1, 48] 10 (.binary chars!"multiply") [15267, 15270] _
      (by dsimp [listSupport]; decide +kernel) (by host_kernel_rfl) (by host_kernel_rfl)
      (by rw [show (sourceNode 15271).prim = .binary chars!"multiply" by host_kernel_rfl]; exact .binary _)
      (by host_kernel_rfl)
  · exact producer_holds ν C [1, 1, 48] 10 (.unary chars!"exp") [15271] _
      (by dsimp [listSupport]; decide +kernel) (by host_kernel_rfl) (by host_kernel_rfl)
      (by rw [show (sourceNode 15272).prim = .unary chars!"exp" by host_kernel_rfl]; exact .unary _)
      (by host_kernel_rfl)

theorem graph_present (i : Nat) (chosen : selected i) : (role i).graph ≠ none := by
  rcases chosen with rfl | rfl | rfl | rfl | rfl | rfl | rfl | rfl <;> intro impossible <;> cases impossible

theorem input_support (i : Nat) (chosen : selected i) (primitive : Primitive) (inputs : List Nat)
    (graph : (role i).graph = some (primitive, inputs)) :
    listSupport (fun a => a < 22587) inputs := by
  rcases chosen with rfl | rfl | rfl | rfl | rfl | rfl | rfl | rfl
  all_goals
    have inputsEq := congrArg Prod.snd (Option.some.inj graph)
    subst inputsEq
    dsimp [listSupport]
    try decide +kernel

open Lean Elab Command in
run_cmd do
  for claim in [
      "theorem wrong_shapeless_operator : (sourceNode 15266).prim = .unary chars!\"negative\" := by host_kernel_rfl",
      "theorem wrong_shapeless_input : (sourceNode 15265).ins = [15264] := by host_kernel_rfl",
      "theorem wrong_scalar_leaf : (sourceNode 15269).prim = .zeros := by host_kernel_rfl",
      "theorem erased_shapeless_graph : (role 15269).graph = none := by host_kernel_rfl"] do
    let saved : Lean.Elab.Command.State ← get
    let count := saved.messages.toList.length
    let mut rejected := false
    try Host.Ts.Owned.Parametric.Driver.emit claim
    catch exception =>
      rejected := ((← exception.toMessageData.toString).splitOn "(kernel) declaration type mismatch").length > 1
    for message in (← get).messages.toList.drop count do
      if ((← message.data.toString).splitOn "(kernel) declaration type mismatch").length > 1 then rejected := true
    set saved
    unless rejected do throwError "captured shapeless negative did not reach its intended kernel rejection: {claim}"

end Host.Load.Run.Full.Ordinary.RankOrigin.CapturedShapelessSeed
