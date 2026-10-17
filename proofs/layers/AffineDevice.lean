import layers.AffineVerifyLinear
import kernels.quantization.AffineStorage

namespace Inference.Layers.AffineDevice
open Contracts.Mlx Kernels.Quantization AffineVerifyLinear
open FloatLib FloatLib.Floats FloatLib.Floats.Formats.BinaryInterchange
set_option maxRecDepth 10000
abbrev BF := ArrayStorage.BF

structure Storage3 (p : Projection3 steps rows) where
  buffers : AffineLoads.Buffers
  geometry : MlxQmvDevice.Geometry .three buffers steps rows
  attached : ∀ row, AffineLoads.weights3 buffers row=p.weights row

structure Storage4 (p : Projection4 steps rows) where
  buffers : AffineLoads.Buffers
  geometry : MlxQmvDevice.Geometry .four buffers steps rows
  attached : ∀ row, AffineLoads.weights4 buffers row=p.weights row

def Storage3.canonical (p : Projection3 steps rows) (bound : 2*(rows*(steps*8)) ≤ 2^64)
    (packed : rows*(steps*64*3) ≤ 2^64) : Storage3 p :=
  ⟨AffineStorage.canonical3 p.weights bound, AffineStorage.geometry3 p.weights bound packed,
    AffineStorage.weights3_eq p.weights bound⟩

def Storage4.canonical (p : Projection4 steps rows) (bound : 2*(rows*(steps*8)) ≤ 2^64)
    (packed : rows*(steps*64*4) ≤ 2^64) : Storage4 p :=
  ⟨AffineStorage.canonical4 p.weights bound, AffineStorage.geometry4 p.weights bound packed,
    AffineStorage.weights4_eq p.weights bound⟩

def Storage (p : Projection steps rows) : Type :=
  match p with | .bits3 p => Storage3 p | .bits4 p => Storage4 p

def Storage.canonical (p : Projection steps rows) (bound : 2*(rows*(steps*8)) ≤ 2^64)
    (packed3 : rows*(steps*64*3) ≤ 2^64) (packed4 : rows*(steps*64*4) ≤ 2^64) : Storage p :=
  match p with
  | .bits3 p => Storage3.canonical p bound packed3
  | .bits4 p => Storage4.canonical p bound packed4

structure Execution3 (p : Projection3 steps (4*groups)) (input : Fin (steps*512) → BF) where
  weights : Storage3 p
  kernel : MlxQmvDevice.Execution .three p.platform input weights.buffers groups

structure Execution4 (p : Projection4 steps (4*groups)) (input : Fin (steps*512) → BF) where
  weights : Storage4 p
  kernel : MlxQmvDevice.Execution .four p.platform input weights.buffers groups

def Execution (p : Projection steps (4*groups)) (input : Fin (steps*512) → BF) : Type :=
  match p with | .bits3 p => Execution3 p input | .bits4 p => Execution4 p input

def Execution.fromStorage (p : Projection steps (4*groups)) (input : Fin (steps*512) → BF)
    (weights : Storage p) (source : ArrayStorage.BFBuffer input) (bound : 2*(4*groups) ≤ 2^64) : Execution p input :=
  match p with
  | .bits3 p => ⟨weights, MlxQmvDevice.Execution.fromStorage .three p.platform input weights.buffers groups weights.geometry source bound⟩
  | .bits4 p => ⟨weights, MlxQmvDevice.Execution.fromStorage .four p.platform input weights.buffers groups weights.geometry source bound⟩

variable {steps groups : Nat} {p : Projection steps (4*groups)} {input : Fin (steps*512) → BF}

def Execution.inputStorage (execution : Execution p input) : ArrayStorage.BFBuffer input :=
  match p with | .bits3 _ => execution.kernel.inputStorage | .bits4 _ => execution.kernel.inputStorage

def Execution.output (execution : Execution p input) : Fin (4*groups) → BF :=
  match p with | .bits3 _ => execution.kernel.output | .bits4 _ => execution.kernel.output

def Execution.outputBuffer (execution : Execution p input) : ArrayStorage.BFBuffer execution.output :=
  match p with | .bits3 _ => execution.kernel.outputBuffer | .bits4 _ => execution.kernel.outputBuffer

theorem Execution.output_eq (execution : Execution p input) : execution.output=p.forward input := by
  cases p with
  | bits3 p =>
    funext row
    change execution.kernel.output row=p.forward input row
    rw [execution.kernel.output3, execution.weights.attached]
    rfl
  | bits4 p =>
    funext row
    change execution.kernel.output row=p.forward input row
    rw [execution.kernel.output4, execution.weights.attached]
    rfl

-- Re-index the proposition attached to these same bytes; no new store occurs.
def Execution.forwardBuffer (execution : Execution p input) : ArrayStorage.BFBuffer (p.forward input) where
  bytes := execution.outputBuffer.bytes
  base := execution.outputBuffer.base
  aligned := execution.outputBuffer.aligned
  bounded := execution.outputBuffer.bounded
  attached := by
    intro row
    rw [← execution.output_eq]
    exact execution.outputBuffer.attached row

theorem Execution.forward_bytes (execution : Execution p input) :
    execution.forwardBuffer.bytes=execution.outputBuffer.bytes := rfl

theorem Execution.input_fromStorage (weights : Storage p) (source : ArrayStorage.BFBuffer input)
    (bound : 2*(4*groups) ≤ 2^64) :
    (Execution.fromStorage p input weights source bound).inputStorage=source := by cases p <;> rfl

theorem Execution.output_error (execution : Execution p input) (target error : Fin (steps*512) → ℝ)
    (hi : ∀ i, |Model.toReal (input i)-target i| ≤ error i) (hf : p.Finite input) (row : Fin (4*groups)) :
    |Model.toReal (execution.output row)-p.target target row| ≤ p.budget input target error row := by
  rw [execution.output_eq]
  exact p.forward_error input target error hi hf row

theorem Execution.output_finite (execution : Execution p input) (hf : p.Finite input) (row : Fin (4*groups)) :
    Model.isFinite (execution.output row)=true := by
  rw [execution.output_eq]
  exact p.forward_finite input hf row

end Inference.Layers.AffineDevice
