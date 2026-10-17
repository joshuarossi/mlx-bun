import models.qwen.DeltaParameterMemory
import layers.AffineNativeParsedSource4
namespace Inference.Models.Qwen.Delta48NativeParsedAffine4
open Contracts.Mlx Layers Kernels.Delta
open FloatLib.Floats.Formats.BinaryInterchange
set_option maxRecDepth 10000

-- The model chooses each projection's bit width at construction. This bridge
-- specializes the actual carried executions to four-bit A/B; it supplies no
-- new weight values, completed scratch or expected register/result premise.
def fourExecution {spec : AffineVerifyLinear.Projection 10 48} {input : Fin 5120→ArrayStorage.BF}
    (run : AffineMemory.Execution (groups:=12) spec input) (p : AffineVerifyLinear.Projection4 10 48)
    (same : spec=.bits4 p) : AffineMemory.Execution4 (groups:=12) p input := by
  cases same
  exact run

theorem four_source {spec : AffineVerifyLinear.Projection 10 48} {input : Fin 5120→ArrayStorage.BF}
    (run : AffineMemory.Execution (groups:=12) spec input) (p : AffineVerifyLinear.Projection4 10 48)
    (same : spec=.bits4 p) :
    (fourExecution run p same).kernel.source=run.source := by
  cases same
  rfl

variable {layer : DeltaNet.Layer} {input : Fin 5120→ArrayStorage.BF}
  (phase : DeltaAffineMemory.Execution layer input)
  (a b : AffineVerifyLinear.Projection4 10 48) (ha : layer.a=.bits4 a) (hb : layer.b=.bits4 b)

def aExecution : AffineMemory.Execution4 (groups:=12) a input := fourExecution phase.a a ha
def bExecution : AffineMemory.Execution4 (groups:=12) b input := fourExecution phase.b b hb

theorem a_current_input : (aExecution phase a ha).kernel.source=AffineMemoryFrames.sourceAfter phase.z :=
  (four_source phase.a a ha).trans phase.aInput

theorem b_current_input : (bExecution phase b hb).kernel.source=AffineMemoryFrames.sourceAfter phase.a :=
  (four_source phase.b b hb).trans phase.bInput

theorem a_source (generation : Nat) (size : Char) (before : Nat→Float32) (finite : a.Finite input) :
    AffineNativeParsedSource4.Certificate (blocks:=6) (aExecution phase a ha) generation size before :=
  AffineNativeParsedSource4.checked (blocks:=6) (aExecution phase a ha) generation size before
    (by decide) (by decide) finite

theorem b_source (generation : Nat) (size : Char) (before : Nat→Float32) (finite : b.Finite input) :
    AffineNativeParsedSource4.Certificate (blocks:=6) (bExecution phase b hb) generation size before :=
  AffineNativeParsedSource4.checked (blocks:=6) (bExecution phase b hb) generation size before
    (by decide) (by decide) finite

variable (parameters : DeltaParameterMemory.Storage layer phase.memory)

-- A's bytes survive B's stores. The exact same final heap is attached to both
-- gate inputs, so the native projection result reaches its actual consumer.
theorem gate_shared :
    (DeltaParameterMemory.gateInput phase parameters).storage.projectionA.bytes=phase.memory ∧
    (DeltaParameterMemory.gateInput phase parameters).storage.projectionB.bytes=phase.memory := ⟨rfl,rfl⟩

theorem a_gate_read (generation : Nat) (size : Char) (before : Nat→Float32)
    (finite : a.Finite input) (head : Fin 48) :
    (DeltaParameterMemory.gateInput phase parameters).storage.projectionA.read head=
      AffineNativeParsedSource4.value (blocks:=6) (aExecution phase a ha) head := by
  calc
    _ = layer.a.forward input head := ArrayStorage.BFBuffer.read_correct _ head
    _ = a.forward input head := congrArg (fun spec : AffineVerifyLinear.Projection 10 48=>spec.forward input head) ha
    _ = _ := ((a_source phase a ha generation size before finite).readback head).symm

theorem b_gate_read (generation : Nat) (size : Char) (before : Nat→Float32)
    (finite : b.Finite input) (head : Fin 48) :
    (DeltaParameterMemory.gateInput phase parameters).storage.projectionB.read head=
      AffineNativeParsedSource4.value (blocks:=6) (bExecution phase b hb) head := by
  calc
    _ = layer.b.forward input head := ArrayStorage.BFBuffer.read_correct _ head
    _ = b.forward input head := congrArg (fun spec : AffineVerifyLinear.Projection 10 48=>spec.forward input head) hb
    _ = _ := ((b_source phase b hb generation size before finite).readback head).symm

include ha in
theorem a_gate_error (generation : Nat) (size : Char) (before : Nat→Float32)
    (finite : a.Finite input) (target error : Fin 5120→ℝ)
    (inputBound : ∀ i,|Model.toReal (input i)-target i|≤error i) (head : Fin 48) :
    |Model.toReal ((DeltaParameterMemory.gateInput phase parameters).storage.projectionA.read head)-a.target target head|≤
      a.budget input target error head := by
  rw [a_gate_read phase a ha parameters generation size before finite]
  exact AffineNativeParsedSource4.readback_error (blocks:=6) (aExecution phase a ha) generation size before
    (a_source phase a ha generation size before finite) target error inputBound finite head

include hb in
theorem b_gate_error (generation : Nat) (size : Char) (before : Nat→Float32)
    (finite : b.Finite input) (target error : Fin 5120→ℝ)
    (inputBound : ∀ i,|Model.toReal (input i)-target i|≤error i) (head : Fin 48) :
    |Model.toReal ((DeltaParameterMemory.gateInput phase parameters).storage.projectionB.read head)-b.target target head|≤
      b.budget input target error head := by
  rw [b_gate_read phase b hb parameters generation size before finite]
  exact AffineNativeParsedSource4.readback_error (blocks:=6) (bExecution phase b hb) generation size before
    (b_source phase b hb generation size before finite) target error inputBound finite head

-- These equalities bind the gate arithmetic to the source-derived projection
-- values rather than requiring either decay or beta as an expected result.
theorem decay_input (generation : Nat) (size : Char) (before : Nat→Float32)
    (finite : a.Finite input) (platform : Inputs.Platform) (head : Fin 48) :
    GateDevice.producedDecay platform (DeltaParameterMemory.gateInput phase parameters).storage head=
      Decay.value platform.decay (BFloat16.widen (layer.aLog head))
        (AffineNativeParsedSource4.value (blocks:=6) (aExecution phase a ha) head) (layer.dtBias head) := by
  rw [GateDevice.produced_decay]
  have same := (a_gate_read phase a ha parameters generation size before finite head).symm
  rw [ArrayStorage.BFBuffer.read_correct] at same
  rw [same]

theorem beta_input (generation : Nat) (size : Char) (before : Nat→Float32)
    (finite : b.Finite input) (platform : Inputs.Platform) (head : Fin 48) :
    GateDevice.producedBeta platform (DeltaParameterMemory.gateInput phase parameters).storage head=
      Kernels.Trellis.GateUpSplitTail.sigmoidValue platform.expAbs
        (AffineNativeParsedSource4.value (blocks:=6) (bExecution phase b hb) head) := by
  rw [GateDevice.produced_beta]
  have same := (b_gate_read phase b hb parameters generation size before finite head).symm
  rw [ArrayStorage.BFBuffer.read_correct] at same
  rw [same]

theorem decay_output (generation : Nat) (size : Char) (before : Nat→Float32)
    (finite : a.Finite input) (platform : Inputs.Platform)
    (decay : GateMemory.DecayExecution (DeltaParameterMemory.gateInput phase parameters) platform)
    (execution : GateMemory.Execution decay) (head : Fin 48) :
    execution.decayBuffer.read head=Decay.value platform.decay (BFloat16.widen (layer.aLog head))
      (AffineNativeParsedSource4.value (blocks:=6) (aExecution phase a ha) head) (layer.dtBias head) := by
  rw [ArrayStorage.FloatBuffer.read_correct]
  exact decay_input phase a ha parameters generation size before finite platform head

theorem beta_output (generation : Nat) (size : Char) (before : Nat→Float32)
    (finite : b.Finite input) (platform : Inputs.Platform)
    (decay : GateMemory.DecayExecution (DeltaParameterMemory.gateInput phase parameters) platform)
    (execution : GateMemory.Execution decay) (head : Fin 48) :
    execution.betaBuffer.read head=Kernels.Trellis.GateUpSplitTail.sigmoidValue platform.expAbs
      (AffineNativeParsedSource4.value (blocks:=6) (bExecution phase b hb) head) := by
  rw [execution.beta_eq]
  have same := (b_gate_read phase b hb parameters generation size before finite head).symm
  rw [ArrayStorage.BFBuffer.read_correct] at same
  rw [same]

end Inference.Models.Qwen.Delta48NativeParsedAffine4
