import kernels.normalization.GatedRms128FirstSource

namespace Inference.Kernels.Normalization.GatedRms128TailSource
open Contracts.Mlx GatedRms128Syntax
open Delta.GatedInputs
set_option maxRecDepth 2000
attribute [local irreducible] parseInverse parseOutput GatedRms128FirstSource.source

-- float(D) is exactly 128 in this specialization. EPS is reinterpreted from
-- its uint32 template bits, not numerically converted to a floating value.
def width : Float32 := 128
def inverse (p : GatedRmsNorm.Platform) (data : Nat → Float32) (epsilon : BitVec 32) : Option Float32 := do
  let sum ←GatedRms128FirstSource.source p data
  let _ ←parseInverse inverseSource
  if 32>32 then none else pure (p.rsqrt (FlushToZero.add (p.divide sum width) (FloatMemory.decode epsilon)))

theorem inverse_eq (p : GatedRmsNorm.Platform) (data : Nat → Float32) (epsilon : BitVec 32) :
    inverse p data epsilon=some (p.rsqrt (FlushToZero.add
      (p.divide (Delta.SiluRmsHeads.sourceSum p.reduce p.contracted (fun i : Fin 128 => data i.val)) width)
      (FloatMemory.decode epsilon))) := by
  unfold inverse
  rw [GatedRms128FirstSource.source_execution,parsed_inverse]
  rfl

def scalar (p : GatedRmsNorm.Platform) (x weight gate : ArrayStorage.BF) (inv : Float32) : ArrayStorage.BF :=
  let normalized := BFloat16Arithmetic.mul weight (BFloat16.narrow (FlushToZero.mul (BFloat16.widen x) inv))
  let g := BFloat16.widen gate
  let y := FlushToZero.div 1 (FlushToZero.add 1 (p.expAbs g))
  let sigmoid := if StableSigmoid.negative g then y else Arithmetic.sub 1 y
  BFloat16.narrow (FlushToZero.mul (FlushToZero.mul g sigmoid) (BFloat16.widen normalized))

theorem scalar_eq (p : GatedRmsNorm.Platform) (x weight gate : ArrayStorage.BF) (inv : Float32) :
    scalar p x weight gate inv=GatedRmsNorm.tail p (BFloat16.widen gate)
      (BFloat16.widen (BFloat16Arithmetic.mul weight (BFloat16.narrow (FlushToZero.mul (BFloat16.widen x) inv)))) := rfl

variable {x gate : GatedRmsNormDevice.Rows} {weights : Fin 128 → ArrayStorage.BF}
  {input : GatedRmsNormMemory.Input x gate weights}

def output (p : GatedRmsNorm.Platform) (input : GatedRmsNormMemory.Input x gate weights)
    (epsilon : BitVec 32) (head : Fin 48) (col : Fin 128) : Option ArrayStorage.BF := do
  let inv ←inverse p (GatedRms128FirstSource.current input head) epsilon
  let _ ←parseOutput outputSource
  pure (scalar p (input.storage.input.read (index head col)) (input.storage.weight.read col)
    (input.storage.gate.read (index head col)) inv)

theorem output_eq (p : GatedRmsNorm.Platform) (input : GatedRmsNormMemory.Input x gate weights)
    (epsilon : BitVec 32) (head : Fin 48) (col : Fin 128) :
    output p input epsilon head col=some (GatedRmsNormDevice.produced p width (FloatMemory.decode epsilon) input.storage head col) := by
  unfold output
  rw [inverse_eq,parsed_output]
  change some (scalar p _ _ _ _)=_
  rw [scalar_eq]
  unfold GatedRmsNormDevice.produced GatedRmsNorm.sourceNormalized GatedRmsNorm.input
  rfl

theorem output_prefix (p : GatedRmsNorm.Platform) (epsilon : BitVec 32)
    (execution : GatedRmsNormMemory.Execution input p width (FloatMemory.decode epsilon))
    (stores : List HalfMemory.Store) (inside : MemoryRegions.Inside16 execution.base 12288 stores)
    (head : Fin 48) (col : Fin 128) :
    output p (execution.during stores inside) epsilon head col=
      some (GatedRmsNormDevice.produced p width (FloatMemory.decode epsilon) input.storage head col) := by
  rw [output_eq,execution.partial_produced stores inside]

end Inference.Kernels.Normalization.GatedRms128TailSource
