import kernels.quantization.AffineInput3Syntax
import kernels.quantization.AffineInput4Source
namespace Inference.Kernels.Quantization.AffineInput3Source
open Contracts.Mlx Contracts.Mlx.Numerics
open FloatLib FloatLib.Floats FloatLib.Floats.Formats.BinaryInterchange
open AffineInput4Syntax (Assignment Expr Program parseInitializer parseReturn sourceInitializer sourceReturn parsed_initializer parsed_return)
open AffineInput3Syntax
open AffineInput4Source (read eval prepared stores sum)
set_option maxRecDepth 10000
set_option maxHeartbeats 1000000
attribute [local irreducible] AffineInput3Syntax.parse

def sourceVisits : Option (List Nat) := do
  let program ←parse sourceLoop
  AffineInput4Source.visits 2 program.start program.bound program.stride
theorem source_visits : sourceVisits=some [0,8] := by
  simp only [sourceVisits,parsed_loop]
  decide +kernel

def execute (divide : Float32 → Float32 → Float32) (bytes : HalfMemory.Bytes) (base : Nat)
    (privateCells : Nat → Float32) : Option (Float32 × (Nat → Float32)) := do
  let initial ←parseInitializer sourceInitializer
  let selected ←parseBranch branchSource
  let _ ←if selected=3 then some () else none
  let program ←parse sourceLoop
  let indices ←AffineInput4Source.visits 2 program.start program.bound program.stride
  let _ ←parseReturn sourceReturn
  pure (sum bytes base program indices (Float32.ofInt initial),MemoryCells.execute (stores divide bytes base program indices) privateCells)

theorem group_eq {x : Fin 16 → AffineInput.BF} (buffer : ArrayStorage.BFBuffer x) (i : Fin 2) :
    eval buffer.bytes buffer.base (8*i.val) body.group=AffineInput.evaluate x (AffineInput.groups3 i) := by
  have each (j : Fin 8) : read buffer.bytes buffer.base (8*i.val+j.val)=x (AffineInput.index8 i j) := by
    simpa only [AffineInput.index8,Nat.mul_comm] using AffineInput4Source.read_current buffer (AffineInput.index8 i j)
  exact congrArg₂ BFloat16Arithmetic.add (congrArg₂ BFloat16Arithmetic.add
    (congrArg₂ BFloat16Arithmetic.add (congrArg₂ BFloat16Arithmetic.add
      (congrArg₂ BFloat16Arithmetic.add (congrArg₂ BFloat16Arithmetic.add
        (congrArg₂ BFloat16Arithmetic.add (each 0) (each 1)) (each 2)) (each 3)) (each 4)) (each 5)) (each 6)) (each 7)

theorem prepared_eq (p : AffineTile.Platform) {x : Fin 16 → AffineInput.BF}
    (buffer : ArrayStorage.BFBuffer x) (i : Fin 2) (j : Fin 8) :
    prepared p.divide buffer.bytes buffer.base (8*i.val)
      ⟨j.val,j.val,2^(AffineDot.inputShift3 j)⟩=AffineTile.prepared3 p x i j := by
  have same : read buffer.bytes buffer.base (8*i.val+j.val)=x (AffineInput.index8 i j) := by
    simpa only [AffineInput.index8,Nat.mul_comm] using AffineInput4Source.read_current buffer (AffineInput.index8 i j)
  simp only [prepared]
  rw [same]
  fin_cases j <;> simp [AffineTile.prepared3,AffineTile.shift3,AffineDot.inputShift3,AffineInput.prepare,AffineInput.divisor,AffineInput.index8]

theorem sum_eq {x : Fin 16 → AffineInput.BF} (buffer : ArrayStorage.BFBuffer x) :
    sum buffer.bytes buffer.base body [0,8]=AffineInput.summed x AffineInput.groups3 := by
  have a := group_eq buffer 0
  have b := group_eq buffer 1
  change eval _ _ 0 _=_ at a
  change eval _ _ 8 _=_ at b
  simp [sum,AffineInput4Source.groupValues,a,b,AffineInput.summed,AffineInput.sumGroups,List.finRange_succ]

theorem private_cells (p : AffineTile.Platform) {x : Fin 16 → AffineInput.BF}
    (buffer : ArrayStorage.BFBuffer x) (before : Nat → Float32) (i : Fin 2) (j : Fin 8) :
    MemoryCells.execute (stores p.divide buffer.bytes buffer.base body [0,8]) before
      (8*i.val+j.val)=AffineTile.prepared3 p x i j := by
  have each := prepared_eq p buffer i j
  fin_cases i <;> fin_cases j <;>
    simpa [stores,body,MemoryCells.execute,MemoryCells.write,AffineDot.inputShift3] using each

theorem execution (p : AffineTile.Platform) {x : Fin 16 → AffineInput.BF}
    (buffer : ArrayStorage.BFBuffer x) (before : Nat → Float32) :
    ∃ cells, execute p.divide buffer.bytes buffer.base before=some (AffineInput.summed x AffineInput.groups3,cells) ∧
      ∀ i j, cells (8*i.val+j.val)=AffineTile.prepared3 p x i j := by
  refine ⟨_,?_,private_cells p buffer before⟩
  simp only [execute,parsed_initializer,parsed_branch,parsed_loop,parsed_return]
  change some (sum buffer.bytes buffer.base body [0,8],_)=_
  rw [sum_eq buffer]
  rfl
end Inference.Kernels.Quantization.AffineInput3Source
