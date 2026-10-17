import kernels.normalization.GatedRms128Syntax
import kernels.GatedRmsNormMemory

namespace Inference.Kernels.Normalization.GatedRms128FirstSource
open Contracts.Mlx GatedRms128Syntax
open Delta.GatedInputs
set_option maxRecDepth 2000
attribute [local irreducible] parseInitial parseFirst parseMulti parseInverse

def outerVisits : List Nat := List.range ((128+127)/128)
theorem outer_visits : outerVisits=[0] := by decide +kernel

def columns (lane : Fin 32) : List Nat :=
  outerVisits.flatMap (fun r => (List.finRange 4).map (fun i => r*128+lane.val*4+i.val))

theorem columns_eq (lane : Fin 32) :
    columns lane=(List.finRange 4).map (fun i => (Delta.Gated.laneIndex lane i).val) := by
  rw [columns,outer_visits]
  simp only [List.flatMap_cons,List.flatMap_nil,List.append_nil,Nat.zero_mul,Nat.zero_add,Delta.Gated.laneIndex]

def step (contracted : Bool) (data : Nat → Float32) (acc : Float32) (col : Nat) : Float32 :=
  let value := if col<128 then data col else 0
  if contracted then FlushToZero.fma value value acc else FlushToZero.add acc (FlushToZero.mul value value)

def laneValue (contracted : Bool) (data : Nat → Float32) (lane : Fin 32) : Float32 :=
  (columns lane).foldl (step contracted data) 0

theorem step_cell (contracted : Bool) (data : Nat → Float32) (acc : Float32) (col : Fin 128) :
    step contracted data acc col.val=SquaredSum.arithmeticStep contracted (fun i : Fin 128 => data i.val) acc col := by
  simp only [step,col.isLt,ite_true,SquaredSum.arithmeticStep]

theorem lane_value (contracted : Bool) (data : Nat → Float32) (lane : Fin 32) :
    laneValue contracted data lane=(List.finRange 4).foldl
      (fun acc i => SquaredSum.arithmeticStep contracted (fun j : Fin 128 => data j.val) acc (Delta.Gated.laneIndex lane i)) 0 := by
  rw [laneValue,columns_eq,List.foldl_map]
  simp only [step_cell]

def sum (p : GatedRmsNorm.Platform) (data : Nat → Float32) : Float32 := p.reduce (laneValue p.contracted data)

theorem sum_eq (p : GatedRmsNorm.Platform) (data : Nat → Float32) :
    sum p data=Delta.SiluRmsHeads.sourceSum p.reduce p.contracted (fun i : Fin 128 => data i.val) := by
  unfold sum Delta.SiluRmsHeads.sourceSum
  apply congrArg p.reduce
  funext lane
  exact lane_value p.contracted data lane

def source (p : GatedRmsNorm.Platform) (data : Nat → Float32) : Option Float32 := do
  let _ ←parseInitial initialSource
  let _ ←parseFirst firstSource
  let _ ←parseMulti multiSource
  -- The parsed shared-scratch branch is inactive at THREADS=32.
  if 32>32 then none else pure (sum p data)

theorem source_execution (p : GatedRmsNorm.Platform) (data : Nat → Float32) :
    source p data=some (Delta.SiluRmsHeads.sourceSum p.reduce p.contracted (fun i : Fin 128 => data i.val)) := by
  unfold source
  rw [parsed_initial,parsed_first,parsed_multi]
  change some (sum p data)=_
  rw [sum_eq]

variable {x gate : GatedRmsNormDevice.Rows} {weights : Fin 128 → ArrayStorage.BF}
  {input : GatedRmsNormMemory.Input x gate weights}

def current (input : GatedRmsNormMemory.Input x gate weights) (head : Fin 48) (col : Nat) : Float32 :=
  BFloat16.widen (FloatLib.Floats.Formats.BinaryInterchange.Model.ofBits
    (HalfMemory.load input.storage.input.bytes (input.storage.input.base+2*(head.val*128+col))))

theorem current_read (input : GatedRmsNormMemory.Input x gate weights) (head : Fin 48) (col : Fin 128) :
    current input head col.val=BFloat16.widen (input.storage.input.read (index head col)) := rfl

theorem current_source (p : GatedRmsNorm.Platform) (input : GatedRmsNormMemory.Input x gate weights) (head : Fin 48) :
    source p (current input head)=some (Delta.SiluRmsHeads.sourceSum p.reduce p.contracted
      (fun i => BFloat16.widen (input.storage.input.read (index head i)))) :=
  source_execution p (current input head)

theorem current_bounds (input : GatedRmsNormMemory.Input x gate weights) (head : Fin 48) (col : Fin 128) :
    (input.storage.input.base+2*(head.val*128+col.val))%2=0 ∧
      input.storage.input.base+2*(head.val*128+col.val)+2≤2^64 :=
  input.storage.input.bounds (index head col)

theorem current_prefix (p : GatedRmsNorm.Platform) (execution : GatedRmsNormMemory.Execution input p width eps)
    (stores : List HalfMemory.Store) (inside : MemoryRegions.Inside16 execution.base 12288 stores) (head : Fin 48) :
    source p (current (execution.during stores inside) head)=some
      (Delta.SiluRmsHeads.sourceSum p.reduce p.contracted (GatedRmsNorm.input (x head))) := by
  rw [current_source]
  apply congrArg (fun data : Fin 128 → Float32 => some (Delta.SiluRmsHeads.sourceSum p.reduce p.contracted data))
  funext i
  exact congrArg BFloat16.widen
    (((execution.during stores inside).storage.input.read_correct (index head i)).trans (flatten_index x head i))

end Inference.Kernels.Normalization.GatedRms128FirstSource
