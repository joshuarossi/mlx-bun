import models.qwen.AttentionHeads
import layers.AffineDevice

namespace Inference.Models.Qwen.AttentionAffine
open Contracts.Mlx Layers
abbrev BF := ArrayStorage.BF
set_option maxRecDepth 10000

structure Weights (p : AttentionHeads.Projections) where
  q : AffineDevice.Storage p.q
  k : AffineDevice.Storage p.k
  v : AffineDevice.Storage p.v

def Weights.canonical (p : AttentionHeads.Projections) : Weights p :=
  ⟨AffineDevice.Storage.canonical _ (by decide) (by decide) (by decide),
    AffineDevice.Storage.canonical _ (by decide) (by decide) (by decide),
    AffineDevice.Storage.canonical _ (by decide) (by decide) (by decide)⟩

structure Execution (p : AttentionHeads.Projections) (input : Fin 5120 → BF) where
  source : ArrayStorage.BFBuffer input
  q : AffineDevice.Execution (groups := 3072) p.q input
  k : AffineDevice.Execution (groups := 256) p.k input
  v : AffineDevice.Execution (groups := 256) p.v input
  queryInput : q.inputStorage=source
  keyInput : k.inputStorage=source
  valueInput : v.inputStorage=source

def Execution.fromStorage (p : AttentionHeads.Projections) (input : Fin 5120 → BF)
    (source : ArrayStorage.BFBuffer input) (weights : Weights p) : Execution p input :=
  ⟨source, AffineDevice.Execution.fromStorage _ _ weights.q source (by decide),
    AffineDevice.Execution.fromStorage _ _ weights.k source (by decide),
    AffineDevice.Execution.fromStorage _ _ weights.v source (by decide),
    AffineDevice.Execution.input_fromStorage _ _ _, AffineDevice.Execution.input_fromStorage _ _ _,
    AffineDevice.Execution.input_fromStorage _ _ _⟩

variable {p : AttentionHeads.Projections} {input : Fin 5120 → BF}

def Execution.query (execution : Execution p input) (head : Fin 24) :
    ArrayStorage.BFBuffer ((p.forward input).query head) :=
  ArrayViews.slice execution.q.forwardBuffer (head.val*512) 256 (by have := head.isLt; omega)

def Execution.gate (execution : Execution p input) (head : Fin 24) :
    ArrayStorage.BFBuffer ((p.forward input).gate head) :=
  ArrayViews.slice execution.q.forwardBuffer (head.val*512+256) 256 (by have := head.isLt; omega)

def Execution.key (execution : Execution p input) (head : Fin 4) :
    ArrayStorage.BFBuffer ((p.forward input).key head) :=
  ArrayViews.slice execution.k.forwardBuffer (head.val*256) 256 (by have := head.isLt; omega)

def Execution.value (execution : Execution p input) (head : Fin 4) :
    ArrayStorage.BFBuffer ((p.forward input).value head) :=
  ArrayViews.slice execution.v.forwardBuffer (head.val*256) 256 (by have := head.isLt; omega)

theorem Execution.query_bytes (execution : Execution p input) (head : Fin 24) :
    (execution.query head).bytes=execution.q.outputBuffer.bytes := rfl
theorem Execution.gate_bytes (execution : Execution p input) (head : Fin 24) :
    (execution.gate head).bytes=execution.q.outputBuffer.bytes := rfl
theorem Execution.key_bytes (execution : Execution p input) (head : Fin 4) :
    (execution.key head).bytes=execution.k.outputBuffer.bytes := rfl
theorem Execution.value_bytes (execution : Execution p input) (head : Fin 4) :
    (execution.value head).bytes=execution.v.outputBuffer.bytes := rfl

theorem Execution.query_address (execution : Execution p input) (head : Fin 24) (i : Fin 256) :
    (execution.query head).base+2*i.val=execution.q.outputBuffer.base+2*(AttentionHeads.queryIndex head i).val := by
  dsimp [Execution.query, ArrayViews.slice, AffineDevice.Execution.forwardBuffer, AttentionHeads.queryIndex]
  omega

theorem Execution.gate_address (execution : Execution p input) (head : Fin 24) (i : Fin 256) :
    (execution.gate head).base+2*i.val=execution.q.outputBuffer.base+2*(AttentionHeads.gateIndex head i).val := by
  dsimp [Execution.gate, ArrayViews.slice, AffineDevice.Execution.forwardBuffer, AttentionHeads.gateIndex]
  omega

theorem launch_dimensions : 12288=4*(2*1536) ∧ 1024=4*(2*128) := by decide

end Inference.Models.Qwen.AttentionAffine
