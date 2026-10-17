import kernels.delta.DeltaBetaSource
namespace Inference.Kernels.Delta.DeltaBetaMemory
open Contracts.Mlx
open GateDevice (Heads)
variable {aLog a dtBias b : Heads} {p : Inputs.Platform}
variable {input : GateMemory.Input aLog a dtBias b} {decay : GateMemory.DecayExecution input p}

theorem source_execution (gates : GateMemory.Execution decay) :
    DeltaBetaSource.execute p (decay.after.storage.projectionB.base/2) gates.beta.base gates.beta.trace.schedule
      decay.after.storage.projectionB.bytes=some gates.beta.buffer.bytes := by
  rw [DeltaBetaSource.source_execution]
  change some (ElementwiseMemory.execute _ _ _)=some (ElementwiseMemory.execute _ _ _)
  rw [gates.beta.shared]

theorem cell_execution (gates : GateMemory.Execution decay) (head : Fin 48) :
    Attention.MlxOutputGateSource.parsedSigmoid (DeltaBetaSource.platform p)
      (decay.after.storage.projectionB.read head)=some (gates.beta.buffer.read head) := by
  rw [Attention.MlxOutputGateSource.parsed_sigmoid_value,ArrayStorage.BFBuffer.read_correct,
    ArrayStorage.BFBuffer.read_correct]
  rfl

theorem current_store (gates : GateMemory.Execution decay) (memory : ByteMemory.Bytes) (head : Fin 48) :
    DeltaBetaSource.sourceStore p memory (decay.after.storage.projectionB.base/2) gates.beta.base head=
      some (ElementwiseMemory.store (UnaryMemory.kernel decay.after.storage.projectionB
        (Trellis.GateUpSplitTail.sigmoidValue p.expAbs) gates.beta.base) memory head) :=
  DeltaBetaSource.parsed_store _ _ _ _ _

-- Donation or separate allocation is already enforced by the original unary
-- trace's independence proof; the parsed schedule is applied to that same heap.
theorem independent (gates : GateMemory.Execution decay) :
    ElementwiseMemory.Independent (UnaryMemory.kernel decay.after.storage.projectionB
      (Trellis.GateUpSplitTail.sigmoidValue p.expAbs) gates.beta.base) := gates.beta.independent
theorem readback_error (gates : GateMemory.Execution decay) (head : Fin 48)
    (finite : FloatLib.Floats.Formats.BinaryInterchange.Model.isFinite (b head)=true)
    (valid : Gates.BetaValid p.expAbs (b head)) (ideal inputError : ℝ)
    (bound : |FloatLib.Floats.Formats.BinaryInterchange.Model.toReal (b head)-ideal| ≤ inputError) :
    |FloatLib.Floats.Formats.BinaryInterchange.Model.toReal (gates.beta.buffer.read head)-Trellis.GateUpTail.sigmoid ideal| ≤
      Gates.betaBudget p.expAbs p.expAbsError (b head)+inputError/4 := by
  rw [ArrayStorage.BFBuffer.read_correct]
  exact Gates.beta_total_error p.expAbs p.expAbsError p.exponential _ finite valid ideal inputError bound
end Inference.Kernels.Delta.DeltaBetaMemory
