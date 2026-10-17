import kernels.attention.MlxOutputGateSyntax
import kernels.trellis.GateTailSource
import kernels.attention.OutputGateMemory

namespace Inference.Kernels.Attention.MlxOutputGateSource
open Contracts.Mlx MlxOutputGateSyntax Trellis
open GateTailSource (Value Environment)
open FloatLib FloatLib.Floats FloatLib.Floats.Formats.BinaryInterchange
set_option maxRecDepth 10000
abbrev BF := ArrayStorage.BF

-- The selected BF16 overloads reuse the existing explicit exp(abs) primitive
-- and BF16 operator interpretation. Native compiler/overload attachment stays
-- a boundary; no computed output is an interpreter premise.
def initial (x : BF) : Environment := fun name => if name="x" then some (.bf16 x) else none

def sigmoidCell (code : MlxOutputGateSyntax.Sigmoid) (p : OutputGate.Platform) (x : BF) : Option BF := do
  let y ←GateTailSource.evaluate GateTailSource.standard id p.expAbs (initial x) code.temporary
  let state : Environment := fun name => if name="y" then some y else initial x name
  GateTailSource.toT (←GateTailSource.evaluate GateTailSource.standard id p.expAbs state code.result)

def multiplyCell (code : GateTailSyntax.Expr) (x y : BF) : Option BF := do
  GateTailSource.toT (←GateTailSource.evaluate GateTailSource.standard id id
    (fun name => if name="x" then some (.bf16 x) else if name="y" then some (.bf16 y) else none) code)

theorem sigmoid_value (p : OutputGate.Platform) (x : BF) :
    sigmoidCell sigmoid p x=some (OutputGate.sigmoid p x) := by
  by_cases negative : GateUpSplitTail.negative x
  · simp [sigmoidCell,sigmoid,GateTailSource.evaluate,initial,GateTailSource.binary,GateTailSource.toT,
      OutputGate.sigmoid,GateUpSplitTail.sigmoidValue,GateUpSplitTail.sigY,GateUpSplitTail.denominator,negative]
  · simp [sigmoidCell,sigmoid,GateTailSource.evaluate,initial,GateTailSource.binary,GateTailSource.toT,
      OutputGate.sigmoid,GateUpSplitTail.sigmoidValue,GateUpSplitTail.sigY,GateUpSplitTail.denominator,negative]

theorem multiply_value (x y : BF) :
    multiplyCell multiply x y=some (BFloat16Arithmetic.mul x y) := rfl

def parsedSigmoid (p : OutputGate.Platform) (x : BF) : Option BF := do
  let code ←parseSigmoid sourceSigmoid
  sigmoidCell code p x

def parsedMultiply (x y : BF) : Option BF := do
  let code ←parseMultiply sourceMultiply
  multiplyCell code x y

theorem parsed_sigmoid_value (p : OutputGate.Platform) (x : BF) :
    parsedSigmoid p x=some (OutputGate.sigmoid p x) := by
  unfold parsedSigmoid
  rw [parsed_sigmoid]
  exact sigmoid_value p x

theorem parsed_multiply_value (x y : BF) :
    parsedMultiply x y=some (BFloat16Arithmetic.mul x y) := by
  unfold parsedMultiply
  rw [parsed_multiply]
  exact multiply_value x y

theorem current_sigmoid {x gate : OutputGateDevice.Heads} (input : OutputGateMemory.Input x gate)
    (p : OutputGate.Platform) (i : Fin 6144) :
    parsedSigmoid p (Model.ofBits (HalfMemory.load input.memory (2*input.gateAddress i)))=
      some (OutputGate.sigmoid p (gate (OutputGateDevice.headOf i) (OutputGateDevice.coordinate i))) := by
  rw [input.gate_load]
  exact parsed_sigmoid_value p _

end Inference.Kernels.Attention.MlxOutputGateSource
