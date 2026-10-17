import kernels.delta.SiluHeads128Syntax
import layers.DeltaHeadsMemory

namespace Inference.Kernels.Delta.SiluHeads128Activation
open Contracts.Mlx SiluHeads128Syntax
open FloatLib.Floats.Formats.BinaryInterchange
set_option maxRecDepth 2000
attribute [local irreducible] parseHeader parseActivation

structure Registers (α β : Type) where
  values : Fin 4 → α
  sum : β

def visit {α β : Type} (value : Fin 4 → α) (project : α → β → β)
    (state : Registers α β) (i : Fin 4) : Registers α β :=
  let next := value i
  ⟨Function.update state.values i next,project next state.sum⟩

-- Private entries may initially contain anything. Each is assigned exactly
-- once, and its new value is squared before advancing to the next entry.
theorem four_visits {α β : Type} (value : Fin 4 → α) (project : α → β → β)
    (state : Registers α β) :
    ((List.finRange 4).foldl (visit value project) state).values=value ∧
    ((List.finRange 4).foldl (visit value project) state).sum=
      (List.finRange 4).foldl (fun sum i => project (value i) sum) state.sum := by
  have indices : List.finRange 4=[0,1,2,3] := by decide +kernel
  rw [indices]
  constructor
  · funext i
    fin_cases i <;> simp [List.foldl,visit,Function.update]
  · simp [List.foldl,visit,Function.update]

def activate (expAbs : ArrayStorage.BF → ArrayStorage.BF) (value : ArrayStorage.BF) : ArrayStorage.BF :=
  let y := BFloat16Arithmetic.div BFloat16Arithmetic.one
    (BFloat16Arithmetic.add BFloat16Arithmetic.one (expAbs value))
  let sigmoid := if Trellis.GateUpSplitTail.negative value then y else
    BFloat16Arithmetic.sub BFloat16Arithmetic.one y
  BFloat16Arithmetic.mul value sigmoid

theorem activation_eq (p : SiluRmsHeads.Platform) (value : ArrayStorage.BF) :
    activate p.expAbs value=SiluRmsHeads.activate p value := rfl

def loaded (data : Nat → ArrayStorage.BF) (lane : Fin 32) (i : Fin 4) : ArrayStorage.BF :=
  let col := lane.val*4+i.val
  if col<128 then data col else Trellis.GateUpSplitTail.zero

theorem loaded_eq (data : Nat → ArrayStorage.BF) (lane : Fin 32) (i : Fin 4) :
    loaded data lane i=data (Gated.laneIndex lane i).val := by
  have bound := (Gated.laneIndex lane i).isLt
  simp only [loaded,Gated.laneIndex] at bound ⊢
  rw [if_pos bound]

def square (contracted : Bool) (value : ArrayStorage.BF) (sum : Float32) : Float32 :=
  let activated := BFloat16.widen value
  if contracted then FlushToZero.fma activated activated sum
  else FlushToZero.add sum (FlushToZero.mul activated activated)

def lane (p : SiluRmsHeads.Platform) (data : Nat → ArrayStorage.BF) (thread : Fin 32)
    (initial : Fin 4 → ArrayStorage.BF) : Registers ArrayStorage.BF Float32 :=
  (List.finRange 4).foldl (visit (fun i => activate p.expAbs (loaded data thread i))
    (square p.contracted)) ⟨initial,0⟩

theorem lane_values (p : SiluRmsHeads.Platform) (data : Nat → ArrayStorage.BF) (thread : Fin 32)
    (initial : Fin 4 → ArrayStorage.BF) :
    (lane p data thread initial).values=(fun i => SiluRmsHeads.activate p (data (Gated.laneIndex thread i).val)) := by
  rw [lane,(four_visits _ _ _).1]
  funext i
  rw [loaded_eq,activation_eq]

theorem lane_sum (p : SiluRmsHeads.Platform) (data : Nat → ArrayStorage.BF) (thread : Fin 32)
    (initial : Fin 4 → ArrayStorage.BF) :
    (lane p data thread initial).sum=(List.finRange 4).foldl
      (fun sum i => SquaredSum.arithmeticStep p.contracted
        (SiluRmsHeads.activated p (fun j : Fin 128 => data j.val)) sum (Gated.laneIndex thread i)) 0 := by
  rw [lane,(four_visits _ _ _).2]
  simp only [loaded_eq,activation_eq,square,SquaredSum.arithmeticStep,SiluRmsHeads.activated]

def source (p : SiluRmsHeads.Platform) (data : Nat → ArrayStorage.BF) (thread : Fin 32)
    (initial : Fin 4 → ArrayStorage.BF) : Option (Registers ArrayStorage.BF Float32) := do
  let _ ←parseHeader headerSource
  let _ ←parseActivation activationSource
  pure (lane p data thread initial)

theorem source_execution (p : SiluRmsHeads.Platform) (data : Nat → ArrayStorage.BF) (thread : Fin 32)
    (initial : Fin 4 → ArrayStorage.BF) :
    source p data thread initial=some (lane p data thread initial) := by
  unfold source
  rw [parsed_header,parsed_activation]
  rfl

theorem reduce_sum (p : SiluRmsHeads.Platform) (data : Nat → ArrayStorage.BF)
    (initial : Fin 32 → Fin 4 → ArrayStorage.BF) :
    p.reduce (fun thread => (lane p data thread (initial thread)).sum)=
      SiluRmsHeads.sourceSum p.reduce p.contracted (SiluRmsHeads.activated p (fun i : Fin 128 => data i.val)) := by
  unfold SiluRmsHeads.sourceSum
  apply congrArg p.reduce
  funext thread
  exact lane_sum p data thread (initial thread)

end Inference.Kernels.Delta.SiluHeads128Activation
