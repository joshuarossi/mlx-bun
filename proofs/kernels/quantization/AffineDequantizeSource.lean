import kernels.quantization.AffineDequantizeSyntax
import kernels.quantization.AffineDequantize
import contracts.mlx.HalfArrayWrites

namespace Inference.Kernels.Quantization.AffineDequantizeSource
open Contracts.Mlx
open FloatLib FloatLib.Floats FloatLib.Floats.Formats.BinaryInterchange
set_option maxRecDepth 10000

def packFactor (bits width : Nat) : Nat :=
  if bits=3 ∨ bits=5 then 8 else if bits=6 then 4 else width/bits
def bytesPerPack (bits width : Nat) : Nat :=
  if bits &&& (bits-1)=0 then width/8 else if bits=5 then 5 else 3

theorem selected_constants : packFactor 4 8=2 ∧ bytesPerPack 4 8=1 := by decide

def masked (byte : BitVec 8) (i : Fin 2) : BitVec 8 :=
  (((byte.setWidth 32) >>> (4*i.val)) &&& (15 : BitVec 32)).setWidth 8

set_option maxHeartbeats 0 in
theorem masked_correct : ∀ byte : BitVec 8, ∀ i : Fin 2,
    (masked byte i).toNat=(AffineDequantize.code byte i).val := by decide +kernel

def fieldCode (byte : BitVec 8) (i : Fin 2) : Fin 16 :=
  ⟨(masked byte i).toNat,by rw [masked_correct]; exact (AffineDequantize.code byte i).isLt⟩

theorem fieldCode_eq (byte : BitVec 8) (i : Fin 2) : fieldCode byte i=AffineDequantize.code byte i :=
  Fin.ext (masked_correct byte i)

-- The contraction flag is an explicit compiler profile, as in the original
-- numerical contract; source parsing does not establish native compilation.
def arithmetic (contracted : Bool) (scale bias : AffineDequantize.BF) (byte : BitVec 8) (i : Fin 2) : AffineDequantize.BF :=
  let d := AffineDequantize.field (fieldCode byte i)
  if contracted then BFloat16Fma.value scale d bias
  else BFloat16Arithmetic.add (BFloat16Arithmetic.mul scale d) bias

theorem arithmetic_eq (contracted : Bool) (scale bias : AffineDequantize.BF) (byte : BitVec 8) (i : Fin 2) :
    arithmetic contracted scale bias byte i=AffineDequantize.value contracted scale bias (AffineDequantize.code byte i) := by
  unfold arithmetic
  rw [fieldCode_eq]
  rfl

def loop {α β : Type} (output : Nat) (value : Fin 2 → α) (store : Nat → α → β) : Nat → Nat → List β
  | 0,_ => []
  | fuel+1,i => if h : i<2 then store (output+i) (value ⟨i,h⟩)::loop output value store fuel (i+1) else []

theorem loop_two {α β : Type} (output : Nat) (value : Fin 2 → α) (store : Nat → α → β) :
    loop output value store 2 0=[store output (value 0),store (output+1) (value 1)] := by
  simp only [loop,show 0<2 from by decide,show 1<2 from by decide,↓reduceDIte,Nat.add_zero]
  rfl

def outputValue (contracted : Bool) (packed scales biases : Nat) (memory : ByteMemory.Bytes)
    (offset : Nat) (i : Fin 2) : AffineDequantize.BF :=
  arithmetic contracted
    (Model.ofBits (HalfMemory.load memory (scales+2*((offset*2)/64))))
    (Model.ofBits (HalfMemory.load memory (biases+2*((offset*2)/64))))
    (memory (packed+offset)) i

def execute (contracted : Bool) (packed scales biases output : Nat) (memory : ByteMemory.Bytes)
    (gridX x y : Nat) : Option (List HalfMemory.Store) := do
  let _ ←AffineDequantizeSyntax.parseBody AffineDequantizeSyntax.bodyTokens
  let _ ←AffineDequantizeSyntax.parsePack AffineDequantizeSyntax.packTokens
  let _ ←AffineDequantizeSyntax.parseBytes AffineDequantizeSyntax.bytesTokens
  let offset := x+gridX*y
  let pack := packFactor 4 8
  pure (loop (offset*pack) (fun i => ArrayStorage.bits (outputValue contracted packed scales biases memory offset i))
    (fun index value => (⟨output/2+index,value⟩ : HalfMemory.Store)) pack 0)

attribute [local irreducible] AffineDequantizeSyntax.parseBody AffineDequantizeSyntax.parsePack
  AffineDequantizeSyntax.parseBytes outputValue

theorem execution (contracted : Bool) (packed scales biases output : Nat) (memory : ByteMemory.Bytes)
    (gridX x y : Nat) :
    execute contracted packed scales biases output memory gridX x y=
      some [⟨output/2+(x+gridX*y)*2,ArrayStorage.bits (outputValue contracted packed scales biases memory (x+gridX*y) 0)⟩,
        ⟨output/2+((x+gridX*y)*2+1),ArrayStorage.bits (outputValue contracted packed scales biases memory (x+gridX*y) 1)⟩] := by
  rw [execute,AffineDequantizeSyntax.parsed_body,AffineDequantizeSyntax.parsed_pack,AffineDequantizeSyntax.parsed_bytes]
  change some (loop _ _ _ (packFactor 4 8) 0)=_
  rw [selected_constants.1,loop_two]

def coordinate (thread : Fin 2560) (i : Fin 2) : Fin 5120 :=
  ⟨thread.val*2+i.val,by have := thread.isLt; have := i.isLt; omega⟩

theorem coordinates (thread : Fin 2560) (i : Fin 2) :
    (AffineDequantize.byteIndex (coordinate thread i)).val=thread.val ∧
    AffineDequantize.byteCoordinate (coordinate thread i)=i ∧
    (AffineDequantize.groupIndex (coordinate thread i)).val=(thread.val*2)/64 := by
  have := i.isLt
  constructor
  · dsimp [AffineDequantize.byteIndex,coordinate]; omega
  constructor
  · apply Fin.ext; dsimp [AffineDequantize.byteCoordinate,coordinate]; omega
  · dsimp [AffineDequantize.groupIndex,coordinate]; omega

theorem grid_bounds (thread : Fin 2560) (i : Fin 2) :
    thread.val<2^64 ∧ thread.val*2+i.val<5120 ∧ (thread.val*2)/64<80 := by
  have := thread.isLt
  have := i.isLt
  omega

end Inference.Kernels.Quantization.AffineDequantizeSource
