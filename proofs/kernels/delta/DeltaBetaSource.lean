import kernels.attention.MlxOutputGateHostSelection
import kernels.delta.GateMemory
namespace Inference.Kernels.Delta.DeltaBetaSource
open Contracts.Mlx
open Attention
open GateDevice (Heads)
open FloatLib.Floats.Formats.BinaryInterchange

def platform (p : Inputs.Platform) : OutputGate.Platform := ⟨p.expAbs,p.expAbsError,p.exponential⟩
def descriptor (base : Nat) : MlxOutputGateHostSelection.Descriptor := ⟨base,48,true,true,false⟩

theorem host_selected (base : Nat) :
    MlxOutputGateHostSelection.unaryRoute (descriptor base)=.scalar ∧
      MlxOutputGateHostSelection.threadGrid 48 (MlxOutputGateUnaryLoop.hostWidth 2 48)=48 := by
  constructor <;> rfl

theorem visits (thread : Fin 48) :
    MlxOutputGateUnaryLoop.visits .vector 48 (MlxOutputGateUnaryLoop.hostWidth 2 48) thread.val=[thread.val] := by
  simp [MlxOutputGateUnaryLoop.visits,MlxOutputGateUnaryLoop.hostWidth]

-- The scalar operator and unary traversal are the same pinned native source
-- as attention's sigmoid, specialized here to the actual 48 BF16 gate cells.
def sourceStore (p : Inputs.Platform) (memory : ByteMemory.Bytes) (sourceBase outputBase : Nat)
    (thread : Fin 48) : Option HalfMemory.Store := do
  let code ←MlxOutputGateUnaryLoop.parse MlxOutputGateUnaryLoop.sourceBody
  match MlxOutputGateUnaryLoop.visits code 48 (MlxOutputGateUnaryLoop.hostWidth 2 48) thread.val with
  | [index] => MlxOutputGateUnaryLoop.store (platform p) memory sourceBase outputBase index
  | _ => none

theorem parsed_store {b : Heads} (source : ArrayStorage.BFBuffer b) (p : Inputs.Platform)
    (memory : ByteMemory.Bytes) (base : Nat) (thread : Fin 48) :
    sourceStore p memory (source.base/2) base thread=
      some (ElementwiseMemory.store (UnaryMemory.kernel source (Trellis.GateUpSplitTail.sigmoidValue p.expAbs) base)
        memory thread) := by
  unfold sourceStore
  rw [MlxOutputGateUnaryLoop.parsed]
  simp only [Bind.bind,Option.bind_some]
  rw [visits]
  change MlxOutputGateUnaryLoop.store (platform p) memory (source.base/2) base thread.val=_
  unfold MlxOutputGateUnaryLoop.store
  rw [MlxOutputGateSource.parsed_sigmoid_value]
  rfl

def execute (p : Inputs.Platform) (sourceBase outputBase : Nat) :
    List (Fin 48)→ByteMemory.Bytes→Option ByteMemory.Bytes
  | [],memory => some memory
  | thread::rest,memory => do
    let store ←sourceStore p memory sourceBase outputBase thread
    execute p sourceBase outputBase rest (HalfMemory.store memory (2*store.word) store.value)

theorem source_execution {b : Heads} (source : ArrayStorage.BFBuffer b) (p : Inputs.Platform)
    (base : Nat) (schedule : List (Fin 48)) (memory : ByteMemory.Bytes) :
    execute p (source.base/2) base schedule memory=
      some (ElementwiseMemory.execute (UnaryMemory.kernel source (Trellis.GateUpSplitTail.sigmoidValue p.expAbs) base)
        schedule memory) := by
  induction schedule generalizing memory with
  | nil => rfl
  | cons thread rest ih =>
    rw [execute,parsed_store]
    change execute p (source.base/2) base rest _=_
    exact ih _
end Inference.Kernels.Delta.DeltaBetaSource
