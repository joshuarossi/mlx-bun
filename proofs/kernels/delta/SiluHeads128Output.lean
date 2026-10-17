import kernels.delta.SiluHeads128Activation

namespace Inference.Kernels.Delta.SiluHeads128Output
open Contracts.Mlx SiluHeads128Syntax SiluHeads128Activation
set_option maxRecDepth 2000
attribute [local irreducible] parseHeader parseActivation parseOutput

def width : Float32 := 128
-- Selected binary32 spelling of the source's 1e-6f literal. Native literal
-- decoding, scalar primitives, and contraction retain their platform boundary.
def epsilon : Float32 := Float32.ofBits 0x358637bd

def headProgram (p : SiluRmsHeads.Platform) (data : Nat → ArrayStorage.BF)
    (initial : Fin 32 → Fin 4 → ArrayStorage.BF) :
    Option (Fin 32 → Registers ArrayStorage.BF Float32) := do
  let _ ←parseHeader headerSource
  let _ ←parseActivation activationSource
  pure (fun thread => lane p data thread (initial thread))

theorem head_program (p : SiluRmsHeads.Platform) (data : Nat → ArrayStorage.BF)
    (initial : Fin 32 → Fin 4 → ArrayStorage.BF) :
    headProgram p data initial=some (fun thread => lane p data thread (initial thread)) := by
  unfold headProgram
  rw [parsed_header,parsed_activation]
  rfl

def normalized (p : SiluRmsHeads.Platform) (data : Nat → ArrayStorage.BF)
    (scale : Fin 128 → ArrayStorage.BF) (thread : Fin 32)
    (initial : Fin 32 → Fin 4 → ArrayStorage.BF) : Option (Fin 4 → ArrayStorage.BF) := do
  let banks ←headProgram p data initial
  let _ ←parseOutput outputSource
  let sum := p.reduce (fun lane => (banks lane).sum)
  let inv := p.rsqrt (FlushToZero.add (p.divide sum width) epsilon)
  pure (fun i =>
    let value := BFloat16.narrow (FlushToZero.mul (BFloat16.widen ((banks thread).values i)) inv)
    BFloat16Arithmetic.mul (scale (Gated.laneIndex thread i)) value)

theorem normalized_eq (p : SiluRmsHeads.Platform) (data : Nat → ArrayStorage.BF)
    (scale : Fin 128 → ArrayStorage.BF) (thread : Fin 32)
    (initial : Fin 32 → Fin 4 → ArrayStorage.BF) :
    normalized p data scale thread initial=some (fun i => SiluRmsHeads.sourceNormalized p
      (fun j : Fin 128 => data j.val) scale width epsilon (Gated.laneIndex thread i)) := by
  unfold normalized
  rw [head_program,parsed_output]
  change some _=some _
  rw [reduce_sum,lane_values]
  rfl

-- The V branch keeps the assigned private values and never evaluates the
-- normalization's SIMD reduction, division, or reciprocal square root.
def value (p : SiluRmsHeads.Platform) (data : Nat → ArrayStorage.BF) (thread : Fin 32)
    (initial : Fin 32 → Fin 4 → ArrayStorage.BF) : Option (Fin 4 → ArrayStorage.BF) := do
  let banks ←headProgram p data initial
  let _ ←parseOutput outputSource
  pure (banks thread).values

theorem value_eq (p : SiluRmsHeads.Platform) (data : Nat → ArrayStorage.BF) (thread : Fin 32)
    (initial : Fin 32 → Fin 4 → ArrayStorage.BF) :
    value p data thread initial=some (fun i => SiluRmsHeads.activate p (data (Gated.laneIndex thread i).val)) := by
  unfold value
  rw [head_program,parsed_output]
  exact congrArg some (lane_values p data thread (initial thread))

end Inference.Kernels.Delta.SiluHeads128Output
