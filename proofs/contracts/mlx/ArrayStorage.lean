import contracts.mlx.FloatMemory
import contracts.mlx.HalfMemory
import contracts.mlx.BFloat16

namespace Inference.Contracts.Mlx.ArrayStorage
open FloatLib FloatLib.Floats FloatLib.Floats.Formats.BinaryInterchange
abbrev BF := Model FloatFormat.bfloat16
def bits (value : BF) : BitVec 16 := value.bits

def bfWords (values : Fin n → BF) (word : Nat) : BitVec 16 := if h : word<n then bits (values ⟨word, h⟩) else 0
def floatWords (values : Fin n → Float32) (word : Nat) : Float32 := if h : word<n then values ⟨word, h⟩ else 0

structure BFBuffer (values : Fin n → BF) where
  bytes : HalfMemory.Bytes
  base : Nat
  aligned : base%2=0
  bounded : base+2*n ≤ 2^64
  attached : ∀ i, HalfMemory.load bytes (base+2*i.val)=bits (values i)

structure FloatBuffer (values : Fin n → Float32) where
  bytes : ByteMemory.Bytes
  base : Nat
  aligned : base%4=0
  bounded : base+4*n ≤ 2^64
  attached : ∀ i, FloatMemory.load bytes (base+4*i.val)=values i

def BFBuffer.canonical (values : Fin n → BF) (bounded : 2*n ≤ 2^64) : BFBuffer values where
  bytes := HalfMemory.encode (bfWords values)
  base := 0
  aligned := by decide
  bounded := by omega
  attached := by
    intro i
    rw [Nat.zero_add, HalfMemory.load_encode _ _ (by omega), show 2*i.val/2=i.val by omega]
    simp only [bfWords, i.isLt, ↓reduceDIte]

def FloatBuffer.canonical (values : Fin n → Float32) (bounded : 4*n ≤ 2^64) : FloatBuffer values where
  bytes := FloatMemory.encode (floatWords values)
  base := 0
  aligned := by decide
  bounded := by omega
  attached := by
    intro i
    rw [Nat.zero_add, FloatMemory.load_view _ _ (by omega), FloatMemory.view_encode, show 4*i.val/4=i.val by omega]
    simp only [floatWords, i.isLt, ↓reduceDIte]

def BFBuffer.read {values : Fin n → BF} (buffer : BFBuffer values) (i : Fin n) : BF :=
  Model.ofBits (HalfMemory.load buffer.bytes (buffer.base+2*i.val))
def FloatBuffer.read {values : Fin n → Float32} (buffer : FloatBuffer values) (i : Fin n) : Float32 :=
  FloatMemory.load buffer.bytes (buffer.base+4*i.val)

theorem BFBuffer.read_correct {values : Fin n → BF} (buffer : BFBuffer values) (i : Fin n) : buffer.read i=values i :=
  congrArg (fun word : BitVec 16 => (Model.ofBits word : BF)) (buffer.attached i)

theorem FloatBuffer.read_correct {values : Fin n → Float32} (buffer : FloatBuffer values) (i : Fin n) : buffer.read i=values i := buffer.attached i

theorem BFBuffer.bounds {values : Fin n → BF} (buffer : BFBuffer values) (i : Fin n) :
    (buffer.base+2*i.val)%2=0 ∧ buffer.base+2*i.val+2 ≤ 2^64 := by
  have := buffer.aligned; have := buffer.bounded; have := i.isLt
  omega

theorem FloatBuffer.bounds {values : Fin n → Float32} (buffer : FloatBuffer values) (i : Fin n) :
    (buffer.base+4*i.val)%4=0 ∧ buffer.base+4*i.val+4 ≤ 2^64 := by
  have := buffer.aligned; have := buffer.bounded; have := i.isLt
  omega

end Inference.Contracts.Mlx.ArrayStorage
