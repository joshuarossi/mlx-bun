import models.qwen.DeltaParsedRecurrence
import kernels.normalization.GatedRms128HostSelection

namespace Inference.Models.Qwen.DeltaParsedGatedNormalization
open Contracts.Mlx Kernels Kernels.Delta Kernels.Normalization
open FloatLib.Floats.Formats.BinaryInterchange
set_option maxRecDepth 2000

variable {reduce : (Fin 32 → Float32) → Float32} {flags : Gated.Contraction}
  {initial : GatedDevice.State} {values : GatedInputs.Values}
  {recurrence : GatedShared.Execution reduce flags initial values}
  {gate : GatedRmsNormDevice.Rows} {weight : Fin 128 → ArrayStorage.BF}
  {input : DeltaTailMemory.Input recurrence gate weight}
  {p : GatedRmsNorm.Platform} {width eps : Float32}
  {projection : Layers.AffineVerifyLinear.Projection 12 5120}

-- These are scalar/descriptor attachment facts: the kernel width is fixed by
-- the selected head dimension, and EPS carries the host's float32 bitcast.
-- Neither fact assumes a computed output or an intermediate tensor.
theorem source_execution (tail : DeltaTailMemory.Execution input p width eps projection)
    (epsilon : BitVec 32) (widthSame : width=GatedRms128TailSource.width)
    (epsSame : eps=FloatMemory.decode epsilon)
    (stores : List HalfMemory.Store) (inside : MemoryRegions.Inside16 tail.normalization.base 12288 stores) :
    ∃ writes, GatedRms128OutputSource.programs p (tail.normalization.during stores inside)
      epsilon tail.normalization.base=some writes ∧
      ThreadgroupWrites.Executes writes tail.normalization.stores.schedule tail.normalization.stores.remaining ∧
      ThreadgroupWrites.AtBarrier tail.normalization.stores.remaining := by
  subst width
  subst eps
  exact GatedRms128OutputSource.source_execution p epsilon tail.normalization stores inside

theorem affine_input_heap (tail : DeltaTailMemory.Execution input p width eps projection) :
    tail.affine.source.bytes=tail.normalization.stores.memory := by
  rw [tail.linked]
  rfl

theorem affine_input_read (tail : DeltaTailMemory.Execution input p width eps projection)
    (head : Fin 48) (col : Fin 128) :
    tail.affine.source.read (GatedInputs.index head col)=
      GatedRmsNorm.value p (recurrence.output head) (gate head) weight width eps col := by
  rw [tail.linked,ArrayStorage.BFBuffer.read_correct,GatedInputs.flatten_index,tail.normalization.output_eq]

theorem recurrence_heap (tail : DeltaTailMemory.Execution input p width eps projection) :
    input.normalization.storage.input.bytes=recurrence.stores.memory ∧
      tail.afterState.bytes=tail.buffer.bytes := ⟨rfl,tail.state_output_shared⟩

theorem affine_input_error (tail : DeltaTailMemory.Execution input p width eps projection)
    (head : Fin 48) (idealEps epsError : ℝ) (positive : 0 < idealEps)
    (epsBound : |Numerics.real eps-idealEps|≤epsError)
    (normFinite : GatedRmsNorm.NormFinite p (recurrence.output head) weight width eps)
    (inputFinite : ∀ j, Model.isFinite (recurrence.output head j)=true)
    (target error targetGate gateError : Fin 128 → ℝ)
    (inputBound : ∀ j, |Model.toReal (recurrence.output head j)-target j|≤error j)
    (gateFinite : ∀ j, Model.isFinite (gate head j)=true)
    (gateBound : ∀ j, |Model.toReal (gate head j)-targetGate j|≤gateError j)
    (col : Fin 128)
    (tailFinite : GatedRmsNorm.TailFinite p (BFloat16.widen (gate head col))
      (BFloat16.widen (GatedRmsNorm.normalized p (recurrence.output head) weight width eps col))) :
    |Model.toReal (tail.affine.source.read (GatedInputs.index head col))-
      Trellis.GateUpTail.swiglu (targetGate col)
        (Normalization.rmsNorm target (fun j => Model.toReal (weight j)) idealEps col)|≤
      GatedRmsNorm.tailBudget p (BFloat16.widen (gate head col))
        (BFloat16.widen (GatedRmsNorm.normalized p (recurrence.output head) weight width eps col))+
      gateError col*(1+|targetGate col|/4)*
        |Model.toReal (GatedRmsNorm.normalized p (recurrence.output head) weight width eps col)|+
      |targetGate col| * GatedRmsNorm.propagatedNormBudget p (recurrence.output head) weight
        width eps idealEps epsError target error col := by
  rw [affine_input_read]
  exact GatedRmsNorm.value_error p _ _ _ width eps idealEps epsError positive epsBound
    normFinite inputFinite target error targetGate gateError inputBound gateFinite gateBound col tailFinite

end Inference.Models.Qwen.DeltaParsedGatedNormalization
