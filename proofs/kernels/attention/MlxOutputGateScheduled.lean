import kernels.attention.MlxOutputGateBinaryLoop

namespace Inference.Kernels.Attention.MlxOutputGateScheduled
open Contracts.Mlx
set_option maxRecDepth 10000

-- These executions retain the admitted native thread order. The selected
-- source guards prove each width-one thread performs one current-heap cell.
def unaryThread (p : OutputGate.Platform) (inputBase outputBase : Nat) (thread : Fin 6144)
    (memory : ByteMemory.Bytes) : Option ByteMemory.Bytes := do
  let code ←MlxOutputGateUnaryLoop.parse MlxOutputGateUnaryLoop.sourceBody
  let stores ←(MlxOutputGateUnaryLoop.visits code 6144 (MlxOutputGateUnaryLoop.hostWidth 2 6144) thread.val).mapM
    (MlxOutputGateUnaryLoop.store p memory inputBase outputBase)
  pure (HalfMemory.execute stores memory)

def binaryThread (sourceBase activationBase outputBase : Nat) (thread : Fin 6144)
    (memory : ByteMemory.Bytes) : Option ByteMemory.Bytes := do
  let code ←MlxOutputGateBinaryLoop.parse MlxOutputGateBinaryLoop.sourceBody
  let stores ←(MlxOutputGateBinaryLoop.visits code 6144 (MlxOutputGateUnaryLoop.hostWidth 2 6144) thread.val).mapM
    (MlxOutputGateBinaryLoop.store memory sourceBase activationBase outputBase)
  pure (HalfMemory.execute stores memory)

def unaryRun (p : OutputGate.Platform) (inputBase outputBase : Nat) : List (Fin 6144) → ByteMemory.Bytes → Option ByteMemory.Bytes
  | [],memory => some memory
  | thread::rest,memory => do unaryRun p inputBase outputBase rest (←unaryThread p inputBase outputBase thread memory)

def binaryRun (sourceBase activationBase outputBase : Nat) : List (Fin 6144) → ByteMemory.Bytes → Option ByteMemory.Bytes
  | [],memory => some memory
  | thread::rest,memory => do binaryRun sourceBase activationBase outputBase rest (←binaryThread sourceBase activationBase outputBase thread memory)

variable {x gate : OutputGateDevice.Heads} {input : OutputGateMemory.Input x gate} {p : OutputGate.Platform}

theorem unary_thread (inputBase outputBase : Nat)
    (layout : ∀ head, (input.storage.gate head).base=2*(inputBase+head.val*256))
    (thread : Fin 6144) (memory : ByteMemory.Bytes) :
    unaryThread p inputBase outputBase thread memory=
      some (HalfMemory.store memory (2*(OutputGateMemory.sigmoidKernel input p outputBase).destination thread)
        (ElementwiseMemory.result (OutputGateMemory.sigmoidKernel input p outputBase) memory thread)) := by
  unfold unaryThread
  rw [MlxOutputGateUnaryLoop.parsed]
  change (do
    let stores ←(MlxOutputGateUnaryLoop.visits .vector 6144 (MlxOutputGateUnaryLoop.hostWidth 2 6144) thread.val).mapM
      (MlxOutputGateUnaryLoop.store p memory inputBase outputBase)
    pure (HalfMemory.execute stores memory) : Option ByteMemory.Bytes)=_
  rw [MlxOutputGateUnaryLoop.selected_visits]
  simp only [List.mapM_cons,List.mapM_nil,MlxOutputGateUnaryLoop.store_current input p inputBase outputBase layout]
  rfl

theorem binary_thread (activation : OutputGateMemory.Activation input p) (sourceBase outputBase : Nat)
    (layout : ∀ head, (input.storage.source head).base=2*(sourceBase+head.val*256))
    (thread : Fin 6144) (memory : ByteMemory.Bytes) :
    binaryThread sourceBase activation.base outputBase thread memory=
      some (HalfMemory.store memory (2*(OutputGateMemory.multiplyKernel activation outputBase).destination thread)
        (ElementwiseMemory.result (OutputGateMemory.multiplyKernel activation outputBase) memory thread)) := by
  unfold binaryThread
  rw [MlxOutputGateBinaryLoop.parsed]
  change (do
    let stores ←(MlxOutputGateBinaryLoop.visits .vectors 6144 (MlxOutputGateUnaryLoop.hostWidth 2 6144) thread.val).mapM
      (MlxOutputGateBinaryLoop.store memory sourceBase activation.base outputBase)
    pure (HalfMemory.execute stores memory) : Option ByteMemory.Bytes)=_
  rw [MlxOutputGateBinaryLoop.selected_visits]
  simp only [List.mapM_cons,List.mapM_nil,MlxOutputGateBinaryLoop.store_current activation sourceBase outputBase layout]
  rfl

theorem unary_run (inputBase outputBase : Nat)
    (layout : ∀ head, (input.storage.gate head).base=2*(inputBase+head.val*256))
    (schedule : List (Fin 6144)) (memory : ByteMemory.Bytes) :
    unaryRun p inputBase outputBase schedule memory=
      some (ElementwiseMemory.execute (OutputGateMemory.sigmoidKernel input p outputBase) schedule memory) := by
  induction schedule generalizing memory with
  | nil => rfl
  | cons thread rest ih =>
    simp only [unaryRun,unary_thread inputBase outputBase layout,ElementwiseMemory.execute]
    exact ih _

theorem binary_run (activation : OutputGateMemory.Activation input p) (sourceBase outputBase : Nat)
    (layout : ∀ head, (input.storage.source head).base=2*(sourceBase+head.val*256))
    (schedule : List (Fin 6144)) (memory : ByteMemory.Bytes) :
    binaryRun sourceBase activation.base outputBase schedule memory=
      some (ElementwiseMemory.execute (OutputGateMemory.multiplyKernel activation outputBase) schedule memory) := by
  induction schedule generalizing memory with
  | nil => rfl
  | cons thread rest ih =>
    simp only [binaryRun,binary_thread activation sourceBase outputBase layout,ElementwiseMemory.execute]
    exact ih _

theorem checked (execution : OutputGateMemory.Execution input p) (gateBase sourceBase : Nat)
    (gateLayout : ∀ head, (input.storage.gate head).base=2*(gateBase+head.val*256))
    (sourceLayout : ∀ head, (input.storage.source head).base=2*(sourceBase+head.val*256)) :
    ∃ intermediate,
      unaryRun p gateBase execution.activation.base execution.activation.trace.schedule input.memory=some intermediate ∧
      binaryRun sourceBase execution.activation.base execution.base execution.trace.schedule intermediate=some execution.buffer.bytes := by
  refine ⟨execution.activation.trace.memory,?_,?_⟩
  · rw [unary_run gateBase execution.activation.base gateLayout]
    apply congrArg some
    unfold ElementwiseMemory.Trace.memory
    rw [execution.activation.initial]
  · rw [binary_run execution.activation sourceBase execution.base sourceLayout]
    apply congrArg some
    change _=execution.trace.memory
    unfold ElementwiseMemory.Trace.memory
    rw [execution.initial]
    rfl

end Inference.Kernels.Attention.MlxOutputGateScheduled
