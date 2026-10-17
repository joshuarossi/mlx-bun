import kernels.quantization.AffineInput4Syntax
import kernels.quantization.AffineTile
import contracts.mlx.ArrayStorage
import kernels.quantization.AffineDot4Source
namespace Inference.Kernels.Quantization.AffineInput4Source
open Contracts.Mlx Contracts.Mlx.Numerics
open FloatLib FloatLib.Floats FloatLib.Floats.Formats.BinaryInterchange
open AffineInput4Syntax
set_option maxRecDepth 10000
set_option maxHeartbeats 1000000
attribute [local irreducible] AffineInput4Syntax.parse

def visits : Nat → Nat → Nat → Nat → Option (List Nat)
  | 0,current,bound,_ => if current<bound then none else some []
  | fuel+1,current,bound,stride => if current<bound then do
      pure (current::(←visits fuel (current+stride) bound stride)) else some []
def sourceVisits : Option (List Nat) := do
  let program ←parse sourceLoop
  visits 4 program.start program.bound program.stride
theorem source_visits : sourceVisits=some [0,4,8,12] := by
  simp only [sourceVisits,parsed_loop]
  decide +kernel

def read (bytes : HalfMemory.Bytes) (base index : Nat) : AffineInput.BF :=
  Model.ofBits (HalfMemory.load bytes (base+2*index))
def eval (bytes : HalfMemory.Bytes) (base iteration : Nat) : Expr → AffineInput.BF
  | .load offset => read bytes base (iteration+offset)
  | .add left right => BFloat16Arithmetic.add (eval bytes base iteration left) (eval bytes base iteration right)
def groupValues (bytes : HalfMemory.Bytes) (base : Nat) (program : Program) (indices : List Nat) : List Float32 :=
  indices.map (fun i => BFloat16.widen (eval bytes base i program.group))
def sum (bytes : HalfMemory.Bytes) (base : Nat) (program : Program) (indices : List Nat) (initial : Float32 := 0) : Float32 :=
  (groupValues bytes base program indices).foldl FlushToZero.add initial

def prepared (divide : Float32 → Float32 → Float32) (bytes : HalfMemory.Bytes) (base iteration : Nat)
    (assignment : Assignment) : Float32 :=
  let value := BFloat16.widen (read bytes base (iteration+assignment.source))
  if assignment.divisor=1 then value else divide value (Float32.ofInt assignment.divisor)
def stores (divide : Float32 → Float32 → Float32) (bytes : HalfMemory.Bytes) (base : Nat)
    (program : Program) (indices : List Nat) : List (MemoryCells.Store Float32) :=
  indices.flatMap (fun i => program.writes.map (fun a => ⟨i+a.target,prepared divide bytes base i a⟩))

-- Explicit BF16 addition at each group node models the selected software
-- lowering; promotion into sum occurs only after all three BF16 additions.
def execute (divide : Float32 → Float32 → Float32) (bytes : HalfMemory.Bytes) (base : Nat)
    (privateCells : Nat → Float32) : Option (Float32 × (Nat → Float32)) := do
  let initial ←parseInitializer sourceInitializer
  let program ←parse sourceLoop
  let indices ←visits 4 program.start program.bound program.stride
  let _ ←parseReturn sourceReturn
  pure (sum bytes base program indices (Float32.ofInt initial),MemoryCells.execute (stores divide bytes base program indices) privateCells)

theorem read_current {x : Fin 16 → AffineInput.BF} (buffer : ArrayStorage.BFBuffer x) (i : Fin 16) :
    read buffer.bytes buffer.base i.val=x i := buffer.read_correct i

theorem group_eq {x : Fin 16 → AffineInput.BF} (buffer : ArrayStorage.BFBuffer x) (i : Fin 4) :
    eval buffer.bytes buffer.base (4*i.val) body.group=AffineInput.evaluate x (AffineInput.groups4 i) := by
  have each (j : Fin 4) : read buffer.bytes buffer.base (4*i.val+j.val)=x (AffineInput.index4 i j) := by
    simpa only [AffineInput.index4,Nat.mul_comm] using read_current buffer (AffineInput.index4 i j)
  exact congrArg₂ BFloat16Arithmetic.add
    (congrArg₂ BFloat16Arithmetic.add (congrArg₂ BFloat16Arithmetic.add (each 0) (each 1)) (each 2)) (each 3)

-- A finite input cell is addressed by its source group and source offset.
theorem prepared_eq (p : AffineTile.Platform) {x : Fin 16 → AffineInput.BF}
    (buffer : ArrayStorage.BFBuffer x) (i j : Fin 4) :
    prepared p.divide buffer.bytes buffer.base (4*i.val)
      ⟨j.val,j.val,2^(4*j.val)⟩=AffineTile.prepared4 p x i j := by
  have same : read buffer.bytes buffer.base (4*i.val+j.val)=x (AffineInput.index4 i j) := by
    simpa only [AffineInput.index4,Nat.mul_comm] using read_current buffer (AffineInput.index4 i j)
  simp only [prepared]
  rw [same]
  fin_cases j <;> simp [AffineTile.prepared4,AffineTile.shift4,AffineInput.prepare,AffineInput.divisor,AffineInput.index4]

theorem sum_eq {x : Fin 16 → AffineInput.BF} (buffer : ArrayStorage.BFBuffer x) :
    sum buffer.bytes buffer.base body [0,4,8,12]=AffineInput.summed x AffineInput.groups4 := by
  have a := group_eq buffer 0
  have b := group_eq buffer 1
  have c := group_eq buffer 2
  have d := group_eq buffer 3
  simp only [Fin.val_zero,Fin.val_one] at a b c d
  change eval _ _ 0 _=_ at a
  change eval _ _ 4 _=_ at b
  change eval _ _ 8 _=_ at c
  change eval _ _ 12 _=_ at d
  simp [sum,groupValues,a,b,c,d,AffineInput.summed,AffineInput.sumGroups,List.finRange_succ]

-- All sixteen writes originate from actual current-buffer reads and parsed
-- assignments. This cell theorem supplies the dot source's prepared premise.
theorem private_cells (p : AffineTile.Platform) {x : Fin 16 → AffineInput.BF}
    (buffer : ArrayStorage.BFBuffer x) (before : Nat → Float32) (i j : Fin 4) :
    MemoryCells.execute (stores p.divide buffer.bytes buffer.base body [0,4,8,12]) before
      (4*i.val+j.val)=AffineTile.prepared4 p x i j := by
  have each := prepared_eq p buffer i j
  fin_cases i <;> fin_cases j <;>
    simpa [stores,body,MemoryCells.execute,MemoryCells.write] using each

theorem execution (p : AffineTile.Platform) {x : Fin 16 → AffineInput.BF}
    (buffer : ArrayStorage.BFBuffer x) (before : Nat → Float32) :
    ∃ cells, execute p.divide buffer.bytes buffer.base before=some (AffineInput.summed x AffineInput.groups4,cells) ∧
      ∀ i j, cells (4*i.val+j.val)=AffineTile.prepared4 p x i j := by
  refine ⟨_,?_,private_cells p buffer before⟩
  simp only [execute,parsed_initializer,parsed_loop,parsed_return]
  change some (sum buffer.bytes buffer.base body [0,4,8,12],_)=_
  rw [sum_eq buffer]
  rfl

end Inference.Kernels.Quantization.AffineInput4Source
