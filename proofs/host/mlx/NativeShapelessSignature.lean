import host.mlx.NativeAnnotationPolicy
import host.mlx.NativeTraceFits

set_option Elab.async false
set_option maxRecDepth 1000000
set_option maxHeartbeats 0

namespace Host.Mlx.Ffi.Annotated
open Host.Ts Host.Ts.Owned Host.Ts.Owned.Parametric NativeRoles

private theorem pure_false_ne_true : (M.pure false : M Bool) ≠ M.pure true := by
  intro equal
  have impossible := congrArg M.run equal
  cases impossible

/-- A checked shapeless match at the source determines a fixed rank/dtype
signature. Dimension values and their literal/symbolic representations can
vary at the target; no target metadata or future dimension premise is used. -/
theorem TraceSignature.of_shapeless_source {ν : Nat → F64} {C : CSrv}
    {captured inputs : Metadata} {a b : List (List Dim × Nat)}
    (left : Metadata.Holds ν C captured a) (right : Metadata.Holds ν C inputs b)
    (fits : traceFits.go true a b = M.pure true) : TraceSignature true captured inputs := by
  induction left generalizing inputs b with
  | nil =>
    cases right with
    | nil => exact .nil true
    | cons => exact False.elim (pure_false_ne_true fits)
  | @cons role actual rest actualRest head tail ih =>
    cases right with
    | nil => exact False.elim (pure_false_ne_true fits)
    | @cons input inputActual inputRest inputActualRest inputHead inputTail =>
      rcases role with ⟨shape,dtype⟩
      rcases actual with ⟨actualShape,actualDtype⟩
      rcases input with ⟨inputShape,inputDtype⟩
      rcases inputActual with ⟨inputActualShape,inputActualDtype⟩
      rcases head with ⟨shapeHolds,dtypeEq⟩
      rcases inputHead with ⟨inputShapeHolds,inputDtypeEq⟩
      dsimp only at dtypeEq inputDtypeEq
      cases guard : (!(Nat.beq actualDtype inputActualDtype) || !(Nat.beq (len actualShape) (len inputActualShape))) with
      | true =>
        simp only [traceFits.go,guard,Bool.cond_true] at fits
        exact False.elim (pure_false_ne_true fits)
      | false =>
        have equal : actualDtype = inputActualDtype ∧ len actualShape = len inputActualShape := by
          simpa using guard
        have sameDtype : dtype = inputDtype := dtypeEq.symm.trans (equal.1.trans inputDtypeEq)
        rw [←sameDtype]
        apply TraceSignature.rank shape inputShape dtype
          (shapeHolds.len_eq.trans (equal.2.trans inputShapeHolds.len_eq.symm))
        apply ih inputTail
        simpa only [traceFits.go,guard,Bool.cond_false,Bool.cond_true] using fits

end Host.Mlx.Ffi.Annotated

namespace Host.Mlx.Ffi.NativeRoles.Live
open Host.Ts Host.Ts.Owned Host.Ts.Owned.Parametric Host.Mlx.Ffi.Annotated

/-- Current indexed native annotations lift the original source shapeless
match to the signature that controls both executions' trace selection. -/
theorem shapeless_signature {ν₀ ν : Nat → F64} {C₀ C : CSrv} {R : Ren}
    {roles : Nat → GraphNode} {boundary : Nat → Prop} {objects : Nat → Object}
    {H N : Nat → Prop} {tail : List NumV} {source target : St}
    (h : Live (NumberRoles ν₀ ν C₀ C) R (NodeRel roles ν₀ ν C₀ C R boundary)
      (ObjectRel objects ν₀ ν C₀ C R) H N tail source target)
    (captured inputs : List Nat) (capturedMeta inputMeta : List (List Dim × Nat))
    (capturedLive : listSupport N captured) (inputsLive : listSupport N inputs)
    (capturedRead : Ffi.shapesOf source captured = some capturedMeta) (inputsRead : Ffi.shapesOf source inputs = some inputMeta)
    (fits : traceFits.go true capturedMeta inputMeta = M.pure true) :
    TraceSignature true (inputRoles roles captured) (inputRoles roles inputs) := by
  have weak := h.mono (fun _ _ held => held) (fun _ _ _ held => held) (fun _ _ _ held => held.base)
  obtain ⟨_,_,sourceCaptured,_⟩ := shapesOf_roles weak captured capturedMeta capturedLive capturedRead
  obtain ⟨_,_,sourceInputs,_⟩ := shapesOf_roles weak inputs inputMeta inputsLive inputsRead
  exact TraceSignature.of_shapeless_source sourceCaptured sourceInputs fits

end Host.Mlx.Ffi.NativeRoles.Live

namespace Host.Mlx.Ffi.Annotated
open Host.Ts Host.Ts.Owned Host.Ts.Owned.Parametric NativeRoles

/-- The reached producer policy supplies every closure-captured and vector
input dependency. Combined with the actual source match it derives the
shapeless selection contract, retaining the existing occurrence meanings. -/
theorem ProducerAnnotations.shapeless_signature {ν₀ ν : Nat → F64} {C₀ C : CSrv} {R : Ren}
    {roles : Nat → GraphNode} {objects : Nat → Object} {boundary roots H N : Nat → Prop}
    {tail : List NumV} {source target : Ffi.St}
    (policy : ProducerAnnotations roots H N roles objects)
    (h : Live (NumberRoles ν₀ ν C₀ C) R (NodeRel roles ν₀ ν C₀ C R boundary)
      (ObjectRel objects ν₀ ν C₀ C R) H N tail source target)
    (closure callback vector : Nat) (payload : Arg) (trace : Ffi.Trace) (inputs : List Nat)
    (closureLive : H closure) (vectorLive : H vector)
    (closureRead : source.obj? closure = some (.clo (.compiled callback payload true [trace])))
    (vectorRead : source.obj? vector = some (.vec inputs))
    (capturedMeta inputMeta : List (List Dim × Nat))
    (capturedRead : Ffi.shapesOf source trace.ins = some capturedMeta) (inputsRead : Ffi.shapesOf source inputs = some inputMeta)
    (fits : traceFits.go true capturedMeta inputMeta = M.pure true) :
    TraceSignature true (inputRoles roles trace.ins) (inputRoles roles inputs) := by
  have held := policy.source h
  exact h.shapeless_signature trace.ins inputs capturedMeta inputMeta
    (held.single_trace closure callback payload true trace closureLive closureRead).inputs
    (held.vector vector inputs vectorLive vectorRead) capturedRead inputsRead fits

end Host.Mlx.Ffi.Annotated
