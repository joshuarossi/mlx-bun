import models.qwen.DeltaNet
import layers.AffineDevice
import kernels.delta.GatedInputs

namespace Inference.Models.Qwen.DeltaAffine
open Contracts.Mlx Layers Kernels.Delta
abbrev BF := ArrayStorage.BF
set_option maxRecDepth 10000

structure Weights (layer : DeltaNet.Layer) where
  qkv : AffineDevice.Storage layer.qkv
  z : AffineDevice.Storage layer.z
  a : AffineDevice.Storage layer.a
  b : AffineDevice.Storage layer.b
  out : AffineDevice.Storage layer.out

def Weights.canonical (layer : DeltaNet.Layer) : Weights layer :=
  ⟨AffineDevice.Storage.canonical _ (by decide) (by decide) (by decide),
    AffineDevice.Storage.canonical _ (by decide) (by decide) (by decide),
    AffineDevice.Storage.canonical _ (by decide) (by decide) (by decide),
    AffineDevice.Storage.canonical _ (by decide) (by decide) (by decide),
    AffineDevice.Storage.canonical _ (by decide) (by decide) (by decide)⟩

structure Inputs (layer : DeltaNet.Layer) (input : Fin 5120 → BF) where
  source : ArrayStorage.BFBuffer input
  qkv : AffineDevice.Execution (groups := 2560) layer.qkv input
  z : AffineDevice.Execution (groups := 1536) layer.z input
  a : AffineDevice.Execution (groups := 12) layer.a input
  b : AffineDevice.Execution (groups := 12) layer.b input
  qkvInput : qkv.inputStorage=source
  zInput : z.inputStorage=source
  aInput : a.inputStorage=source
  bInput : b.inputStorage=source

def Inputs.fromStorage (layer : DeltaNet.Layer) (input : Fin 5120 → BF)
    (source : ArrayStorage.BFBuffer input) (weights : Weights layer) : Inputs layer input :=
  ⟨source, AffineDevice.Execution.fromStorage _ _ weights.qkv source (by decide),
    AffineDevice.Execution.fromStorage _ _ weights.z source (by decide),
    AffineDevice.Execution.fromStorage _ _ weights.a source (by decide),
    AffineDevice.Execution.fromStorage _ _ weights.b source (by decide),
    AffineDevice.Execution.input_fromStorage _ _ _, AffineDevice.Execution.input_fromStorage _ _ _,
    AffineDevice.Execution.input_fromStorage _ _ _, AffineDevice.Execution.input_fromStorage _ _ _⟩

variable {layer : DeltaNet.Layer} {input : Fin 5120 → BF}

def Inputs.gateBuffer (inputs : Inputs layer input) :
    ArrayStorage.BFBuffer (GatedInputs.flatten (DeltaNet.zHead layer (fun _ => input) 0)) where
  bytes := inputs.z.forwardBuffer.bytes
  base := inputs.z.forwardBuffer.base
  aligned := inputs.z.forwardBuffer.aligned
  bounded := inputs.z.forwardBuffer.bounded
  attached := by
    intro i
    have same : GatedInputs.flatten (DeltaNet.zHead layer (fun _ => input) 0) i=layer.z.forward input i := by
      change layer.z.forward input (DeltaNet.channel (DeltaNet.headOf i) (DeltaNet.valueOf i))=_
      rw [DeltaNet.reshape_roundtrip]
    rw [same]
    exact inputs.z.forwardBuffer.attached i

theorem Inputs.gate_bytes (inputs : Inputs layer input) :
    inputs.gateBuffer.bytes=inputs.z.outputBuffer.bytes := rfl

theorem Inputs.shared_input (inputs : Inputs layer input) :
    inputs.qkv.inputStorage.bytes=inputs.source.bytes ∧
    inputs.z.inputStorage.bytes=inputs.source.bytes ∧
    inputs.a.inputStorage.bytes=inputs.source.bytes ∧
    inputs.b.inputStorage.bytes=inputs.source.bytes :=
  ⟨congrArg ArrayStorage.BFBuffer.bytes inputs.qkvInput,
    congrArg ArrayStorage.BFBuffer.bytes inputs.zInput,
    congrArg ArrayStorage.BFBuffer.bytes inputs.aInput,
    congrArg ArrayStorage.BFBuffer.bytes inputs.bInput⟩

-- Every row count is a multiple of the native eight-row threadgroup.
theorem launch_dimensions : 10240=4*(2*1280) ∧ 6144=4*(2*768) ∧
    48=4*(2*6) ∧ 5120=4*(2*640) ∧ 10*512=5120 ∧ 12*512=6144 := by decide

end Inference.Models.Qwen.DeltaAffine
