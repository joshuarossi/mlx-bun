import kernels.copy.GatherFrontSyntax
import state.TokenStorage
namespace Inference.Kernels.Copy.GatherFrontSource
open Contracts.Mlx
set_option maxRecDepth 2000

-- Both uint32 and nonnegative int32 token buffers select the same row.
-- Negative signed IDs are outside the selected embedding input contract.
def offsetIndex (unsigned : Bool) (index : BitVec 32) (size : Nat) : Nat :=
  if unsigned then index.toNat else
    (if index.toInt < 0 then index.toInt+(size:Int) else index.toInt).toNat

theorem positive_index (unsigned : Bool) (index : BitVec 32) (size : Nat)
    (bound : index.toNat < 2^31) : offsetIndex unsigned index size=index.toNat := by
  have signed := BitVec.toInt_eq_toNat_of_lt (x := index) (by omega)
  have nonnegative : ¬ (index.toNat : Int) < 0 := by omega
  cases unsigned <;> simp [offsetIndex,signed,nonnegative]

-- The loop advances i and s_idx together and tests both conditions before
-- evaluating the source load. Native casts and pointer addition are justified
-- by the selected integer and buffer bounds in the memory bridge.
def loop {α β : Type} (n stride srcIndex outIndex : Nat) (load : Nat → α) (store : Nat → α → β) :
    Nat → Nat → Nat → List β
  | 0,_,_ => []
  | fuel+1,i,s => if i<n ∧ s<stride then
      store (outIndex+s) (load (srcIndex+s))::loop n stride srcIndex outIndex load store fuel (i+1) (s+1)
    else []

def execute {α β : Type} (unsigned : Bool) (n stride size : Nat) (memory : ByteMemory.Bytes)
    (indexBase thread row : Nat) (load : Nat → α) (store : Nat → α → β) : Option (List β) := do
  let _ ←GatherFrontSyntax.parseBody GatherFrontSyntax.bodySource
  let _ ←GatherFrontSyntax.parseIndex GatherFrontSyntax.indexSource
  let idx := offsetIndex unsigned (ByteMemory.load32 memory (indexBase+4*row)) size
  pure (loop n stride (stride*idx) (stride*row) load store n 0 (n*thread))

attribute [local irreducible] GatherFrontSyntax.parseBody GatherFrontSyntax.parseIndex

theorem execution {α β : Type} (unsigned : Bool) (n stride size : Nat) (memory : ByteMemory.Bytes)
    (indexBase thread row : Nat) (load : Nat → α) (store : Nat → α → β) :
    execute unsigned n stride size memory indexBase thread row load store=
      some (loop n stride (stride*offsetIndex unsigned (ByteMemory.load32 memory (indexBase+4*row)) size)
        (stride*row) load store n 0 (n*thread)) := by
  rw [execute,GatherFrontSyntax.parsed_body,GatherFrontSyntax.parsed_index]
  rfl

variable {token : Fin 248320}

theorem buffer_index (unsigned : Bool) (buffer : State.TokenStorage.Buffer token) :
    offsetIndex unsigned (ByteMemory.load32 buffer.bytes buffer.base) 248320=token.val := by
  rw [positive_index unsigned _ _ buffer.int32_index]
  exact buffer.read_correct

theorem packed_thread {α β : Type} (unsigned : Bool) (buffer : State.TokenStorage.Buffer token)
    (thread : Fin 640) (load : Nat → α) (store : Nat → α → β) :
    execute unsigned 1 640 248320 buffer.bytes buffer.base thread.val 0 load store=
      some [store thread.val (load (token.val*640+thread.val))] := by
  rw [execution]
  simp only [Nat.mul_zero,Nat.add_zero,buffer_index]
  have bound := thread.isLt
  simp only [loop,Nat.zero_lt_succ,Nat.one_mul,true_and,bound,ite_true,Nat.zero_add]
  rw [Nat.mul_comm 640 token.val]

theorem parameter_thread {α β : Type} (unsigned : Bool) (buffer : State.TokenStorage.Buffer token)
    (thread : Fin 40) (load : Nat → α) (store : Nat → α → β) :
    execute unsigned 2 80 248320 buffer.bytes buffer.base thread.val 0 load store=
      some [store (2*thread.val) (load (token.val*80+2*thread.val)),
        store (2*thread.val+1) (load (token.val*80+(2*thread.val+1)))] := by
  rw [execution]
  simp only [Nat.mul_zero,Nat.add_zero,buffer_index]
  have first : 2*thread.val<80 := by have := thread.isLt; omega
  have second : 2*thread.val+1<80 := by have := thread.isLt; omega
  simp only [loop,show 0<2 from by decide,show 1<2 from by decide,true_and,first,second,ite_true,Nat.zero_add]
  rw [Nat.mul_comm 80 token.val]

theorem packed_integer_bounds (buffer : State.TokenStorage.Buffer token) (thread : Fin 640) :
    640*buffer.read+thread.val<2^31 ∧ thread.val<2^31 := by
  rw [buffer.read_correct]
  have := token.isLt
  have := thread.isLt
  omega

theorem parameter_integer_bounds (buffer : State.TokenStorage.Buffer token) (thread : Fin 40) (i : Fin 2) :
    80*buffer.read+(2*thread.val+i.val)<2^31 ∧ 2*thread.val+i.val<80 := by
  rw [buffer.read_correct]
  have := token.isLt
  have := thread.isLt
  have := i.isLt
  omega

end Inference.Kernels.Copy.GatherFrontSource
