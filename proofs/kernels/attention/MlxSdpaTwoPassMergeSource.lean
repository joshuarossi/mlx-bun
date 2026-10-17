import kernels.attention.MlxSdpaTwoPassMergeMemory

namespace Inference.Kernels.Attention.MlxSdpaTwoPassMergeSource
open Contracts.Mlx State MlxSdpaTwoPassMergeSyntax MlxSdpaTwoPassMergeMemory
open FloatLib FloatLib.Floats FloatLib.Floats.Formats.BinaryInterchange
set_option maxRecDepth 10000
set_option maxHeartbeats 1000000
variable {steps blocks : Nat} {query : Fin 24 → Fin 256 → ArrayStorage.BF}
  {cache : Kv.Cache Kv.BF steps} {input : SdpaMemory.Input query cache} {p : SdpaVector.Platform}

def maximum (_ : Maximum) (execution : SdpaTwoPassShared.Execution input p blocks) (head : Fin 24) : Float32 :=
  p.simdMaximum (fun lane => (List.finRange (blocks/32)).foldl
    (fun acc iteration => p.maximum acc (maxValue execution head lane iteration.val)) SdpaVector.initialShift)

def denominator (_ : Denominator) (contracted : Bool) (execution : SdpaTwoPassShared.Execution input p blocks)
    (head : Fin 24) (shift : Float32) : Float32 :=
  p.merge.reduce (fun lane => (List.finRange (blocks/32)).foldl (fun acc iteration =>
    ArithmeticFold.maddFloat contracted (p.merge.scalar.exp (Arithmetic.sub (maxValue execution head lane iteration.val) shift))
      (sumValue execution head lane iteration.val) acc) 0)

def numerator (_ : Numerator) (contracted : Bool) (execution : SdpaTwoPassShared.Execution input p blocks)
    (head : Fin 24) (shift : Float32) (group lane : Fin 32) (item : Fin 8) : Float32 :=
  (List.finRange (blocks/32)).foldl (fun acc iteration => ArithmeticFold.maddFloat contracted
    (p.merge.scalar.exp (Arithmetic.sub (maxValue execution head group iteration.val) shift))
    (partialValue execution head group lane iteration.val item) acc) 0

theorem maximum_current (execution : SdpaTwoPassShared.Execution input p blocks) (complete : blocks%32=0) (head : Fin 24) :
    maximum .chunks execution head=SdpaTwoPassMaximum.common p (fun block => (execution.first.readState head block 0).shift) := by
  unfold maximum SdpaTwoPassMaximum.common SdpaTwoPassMaximum.lane SdpaTwoPassMaximum.foldMaximum
  apply congrArg p.simdMaximum
  funext lane
  simp_rw [max_current execution complete]
  rw [←SdpaTwoPassExecution.source_keys complete lane]
  exact fold_chunks complete lane (fun acc block => p.maximum acc (execution.first.readState head block 0).shift) _

theorem maximum_projected (execution : SdpaTwoPassShared.Execution input p blocks) (complete : blocks%32=0) (head : Fin 24) :
    maximum .chunks execution head=SdpaTwoPassMaximum.common p (fun block => (execution.first.trace.readState head block 0).shift) := by
  rw [maximum_current execution complete]
  simp only [execution.first.readState_projected]

theorem denominator_current (execution : SdpaTwoPassShared.Execution input p blocks) (complete : blocks%32=0)
    (contracted : Bool) (head : Fin 24) (shift : Float32) :
    denominator .chunks contracted execution head shift=
      SdpaTwoPassExecution.sourceComponent p.merge contracted complete (fun block => execution.first.readState head block 0) shift false := by
  unfold denominator SdpaTwoPassExecution.sourceComponent
  apply congrArg p.merge.reduce
  funext lane
  simp_rw [max_current execution complete,sum_current execution complete]
  exact fold_chunks complete lane (fun acc block => ArithmeticFold.maddFloat contracted
    (p.merge.scalar.exp (Arithmetic.sub (execution.first.readState head block 0).shift shift))
    (execution.first.readState head block 0).denominator acc) 0

theorem numerator_current (execution : SdpaTwoPassShared.Execution input p blocks) (complete : blocks%32=0)
    (contracted : Bool) (head : Fin 24) (shift : Float32) (group lane : Fin 32) (item : Fin 8) :
    numerator .chunks contracted execution head shift group lane item=
      (SdpaTwoPassExecution.sourceKeys complete group).foldl (fun acc block =>
        ArithmeticFold.maddFloat contracted (SdpaUpdate.exponential p.merge.scalar (execution.first.readState head block 0).shift shift)
          (execution.first.readState head block (SdpaLayout.coordinate lane item)).numerator acc) 0 := by
  unfold numerator
  simp_rw [max_current execution complete,partial_current execution complete]
  exact fold_chunks complete group (fun acc block => ArithmeticFold.maddFloat contracted
    (SdpaUpdate.exponential p.merge.scalar (execution.first.readState head block 0).shift shift)
    (execution.first.readState head block (SdpaLayout.coordinate lane item)).numerator acc) 0

theorem numerator_lanes (execution : SdpaTwoPassShared.Execution input p blocks) (complete : blocks%32=0)
    (contracted : Bool) (head : Fin 24) (item : Fin 8) :
    (fun group lane => numerator .chunks contracted execution head (maximum .chunks execution head) group lane item)=
      SdpaTwoPassScratch.numeratorLanes p contracted complete input.storage.queryValues input.storage.keys.read
        input.storage.values.read execution.first.trace head item := by
  funext group lane
  rw [numerator_current execution complete,maximum_projected execution complete]
  simp only [execution.first.readState_projected]
  unfold SdpaTwoPassScratch.numeratorLanes
  rfl

def source (contracted : Bool) (execution : SdpaTwoPassShared.Execution input p blocks) (head : Fin 24)
    (group lane : Fin 32) (item : Fin 8) : Option SdpaUpdate.State := do
  let ps ←parsePointers sourcePointers
  if ps=pointers then
    let _ ←parseInitial sourceInitial
    let maxAst ←parseMaximum sourceMaximum
    let denAst ←parseDenominator sourceDenominator
    let numAst ←parseNumerator sourceNumerator
    let shift := maximum maxAst execution head
    pure ⟨shift,denominator denAst contracted execution head shift,numerator numAst contracted execution head shift group lane item⟩
  else none

theorem parsed_source (contracted : Bool) (execution : SdpaTwoPassShared.Execution input p blocks) (head : Fin 24)
    (group lane : Fin 32) (item : Fin 8) :
    source contracted execution head group lane item=some ⟨maximum .chunks execution head,
      denominator .chunks contracted execution head (maximum .chunks execution head),
      numerator .chunks contracted execution head (maximum .chunks execution head) group lane item⟩ := by
  simp [source,parsed_pointers,parsed_initial,parsed_maximum,parsed_denominator,parsed_numerator]

end Inference.Kernels.Attention.MlxSdpaTwoPassMergeSource
