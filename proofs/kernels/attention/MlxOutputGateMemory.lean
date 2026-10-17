import kernels.attention.MlxOutputGateSource

namespace Inference.Kernels.Attention.MlxOutputGateMemory
open Contracts.Mlx MlxOutputGateSyntax MlxOutputGateSource
set_option maxRecDepth 10000

-- Failed interpretations remain distinguishable at the parsed scalar layer.
-- For the accepted AST, the following total kernel never uses getD's default.
def sigmoidKernel {x gate : OutputGateDevice.Heads} (code : Sigmoid)
    (input : OutputGateMemory.Input x gate) (p : OutputGate.Platform) (base : Nat) : ElementwiseMemory.Kernel 6144 1 where
  source i _ := input.gateAddress i
  destination i := base+i.val
  evaluate words := ArrayStorage.bits ((sigmoidCell code p (FloatLib.Floats.Formats.BinaryInterchange.Model.ofBits (words 0))).getD
    (Trellis.GateUpSplitTail.zero))

def parsedSigmoidKernel {x gate : OutputGateDevice.Heads}
    (input : OutputGateMemory.Input x gate) (p : OutputGate.Platform) (base : Nat) : Option (ElementwiseMemory.Kernel 6144 1) := do
  let code ←parseSigmoid sourceSigmoid
  pure (sigmoidKernel code input p base)

theorem sigmoid_kernel {x gate : OutputGateDevice.Heads}
    (input : OutputGateMemory.Input x gate) (p : OutputGate.Platform) (base : Nat) :
    parsedSigmoidKernel input p base=some (OutputGateMemory.sigmoidKernel input p base) := by
  unfold parsedSigmoidKernel
  rw [parsed_sigmoid]
  change some (sigmoidKernel sigmoid input p base)=_
  apply congrArg some
  unfold sigmoidKernel OutputGateMemory.sigmoidKernel
  congr 1
  funext words
  rw [sigmoid_value]
  rfl

def multiplyKernel {x gate : OutputGateDevice.Heads} {input : OutputGateMemory.Input x gate} {p : OutputGate.Platform}
    (code : Trellis.GateTailSyntax.Expr) (activation : OutputGateMemory.Activation input p) (base : Nat) : ElementwiseMemory.Kernel 6144 2 where
  source i operand := if operand.val=0 then input.sourceAddress i else activation.base+i.val
  destination i := base+i.val
  evaluate words := ArrayStorage.bits ((multiplyCell code
    (FloatLib.Floats.Formats.BinaryInterchange.Model.ofBits (words 0))
    (FloatLib.Floats.Formats.BinaryInterchange.Model.ofBits (words 1))).getD
    (Trellis.GateUpSplitTail.zero))

def parsedMultiplyKernel {x gate : OutputGateDevice.Heads} {input : OutputGateMemory.Input x gate} {p : OutputGate.Platform}
    (activation : OutputGateMemory.Activation input p) (base : Nat) : Option (ElementwiseMemory.Kernel 6144 2) := do
  let code ←parseMultiply sourceMultiply
  pure (multiplyKernel code activation base)

theorem multiply_kernel {x gate : OutputGateDevice.Heads} {input : OutputGateMemory.Input x gate} {p : OutputGate.Platform}
    (activation : OutputGateMemory.Activation input p) (base : Nat) :
    parsedMultiplyKernel activation base=some (OutputGateMemory.multiplyKernel activation base) := by
  unfold parsedMultiplyKernel
  rw [parsed_multiply]
  rfl

theorem checked {x gate : OutputGateDevice.Heads} {input : OutputGateMemory.Input x gate} {p : OutputGate.Platform}
    (execution : OutputGateMemory.Execution input p) :
    ∃ unary binary,
      parsedSigmoidKernel input p execution.activation.base=some unary ∧
      parsedMultiplyKernel execution.activation execution.base=some binary ∧
      execution.buffer.bytes=ElementwiseMemory.execute binary execution.trace.schedule
        (ElementwiseMemory.execute unary execution.activation.trace.schedule input.memory) := by
  refine ⟨_,_,sigmoid_kernel _ _ _,multiply_kernel _ _,?_⟩
  change execution.trace.memory=_
  unfold ElementwiseMemory.Trace.memory
  rw [execution.initial]
  unfold ElementwiseMemory.Trace.memory
  rw [execution.activation.initial]

end Inference.Kernels.Attention.MlxOutputGateMemory
