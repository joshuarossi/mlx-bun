import kernels.delta.ComputeGHostSource
import kernels.delta.GateMemory
namespace Inference.Kernels.Delta.ComputeGHostMemory
open Contracts.Mlx
open GateDevice (Heads)
open FloatLib.Floats.Formats.BinaryInterchange
variable {aLog a dtBias b : Heads} {p : Inputs.Platform}
variable {input : GateMemory.Input aLog a dtBias b}

def source (input : GateMemory.Input aLog a dtBias b) (head : Fin 48) :=
  ComputeGHostSource.execute p.decay.policy p.decay
    (input.storage.logarithm.read head) (input.storage.projectionA.read head) (input.storage.bias.read head)

theorem source_execution (input : GateMemory.Input aLog a dtBias b) (head : Fin 48)
    (finite : Decay.Finite p.decay (BFloat16.widen (aLog head)) (a head) (dtBias head)) :
    source (p:=p) input head=some (.fp (GateDevice.producedDecay p input.storage head)) := by
  unfold source
  rw [ArrayStorage.BFBuffer.read_correct,ArrayStorage.BFBuffer.read_correct,ArrayStorage.BFBuffer.read_correct]
  rw [ComputeGHostSource.execution p.decay _ _ _ finite.softFinite.input]
  rw [GateDevice.produced_decay]

-- All three source operands are loaded from one current heap. The compiler
-- still must realize the parsed typed graph; no generated fused Metal schedule
-- is inferred from this host-level source relation.
theorem current_execution (decay : GateMemory.DecayExecution input p)
    (stores : List ByteMemory.Store) (inside : MemoryRegions.Inside32 decay.base 192 stores) (head : Fin 48)
    (finite : Decay.Finite p.decay (BFloat16.widen (aLog head)) (a head) (dtBias head)) :
    source (p:=p) (decay.during stores inside) head=
      some (.fp (GateDevice.producedDecay p input.storage head)) := by
  rw [source_execution _ head finite,decay.partial_produced stores inside head]

theorem completed_readback (decay : GateMemory.DecayExecution input p) (head : Fin 48)
    (finite : Decay.Finite p.decay (BFloat16.widen (aLog head)) (a head) (dtBias head)) :
    source (p:=p) input head=some (.fp (decay.stores.buffer.read head)) := by
  rw [ArrayStorage.FloatBuffer.read_correct]
  exact source_execution input head finite
theorem gates_readback (decay : GateMemory.DecayExecution input p) (gates : GateMemory.Execution decay)
    (head : Fin 48) (finite : Decay.Finite p.decay (BFloat16.widen (aLog head)) (a head) (dtBias head)) :
    source (p:=p) input head=some (.fp (gates.decayBuffer.read head)) := by
  rw [ArrayStorage.FloatBuffer.read_correct]
  exact source_execution input head finite

theorem readback_error (decay : GateMemory.DecayExecution input p) (head : Fin 48)
    (finite : Decay.Finite p.decay (BFloat16.widen (aLog head)) (a head) (dtBias head)) :
    |Contracts.Mlx.Numerics.real (decay.stores.buffer.read head)-
      Gates.decay (Contracts.Mlx.Numerics.real (BFloat16.widen (aLog head)))
        (Model.toReal (a head)+Model.toReal (dtBias head))| ≤
      Decay.budget p.decay (BFloat16.widen (aLog head)) (a head) (dtBias head) := by
  rw [ArrayStorage.FloatBuffer.read_correct,GateDevice.produced_decay]
  exact Decay.value_error p.decay _ _ _ finite
end Inference.Kernels.Delta.ComputeGHostMemory
