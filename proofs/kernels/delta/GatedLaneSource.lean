import kernels.delta.GatedStepSyntax
import kernels.delta.Gated

namespace Inference.Kernels.Delta.GatedLaneSource
open Contracts.Mlx
open FloatLib FloatLib.Floats FloatLib.Floats.Formats.BinaryInterchange
set_option maxRecDepth 2000
set_option maxHeartbeats 1000000

structure Bank where
  state : Fin 4 → Float32
  sum : Float32

def visit (update : Fin 4 → Float32 → Float32) (project : Fin 4 → Float32 → Float32 → Float32)
    (bank : Bank) (offset : Fin 4) : Bank :=
  let value := update offset (bank.state offset)
  ⟨Function.update bank.state offset value,project offset value bank.sum⟩

-- Every register is updated once before its contribution enters the fold.
-- This is an ordered state mutation fact, without floating-point algebra.
theorem four_visits (update : Fin 4 → Float32 → Float32)
    (project : Fin 4 → Float32 → Float32 → Float32) (bank : Bank) :
    ((List.finRange 4).foldl (visit update project) bank).state=(fun i => update i (bank.state i)) ∧
    ((List.finRange 4).foldl (visit update project) bank).sum=
      (List.finRange 4).foldl (fun sum i => project i (update i (bank.state i)) sum) bank.sum := by
  have indices : List.finRange 4=[0,1,2,3] := by decide +kernel
  rw [indices]
  constructor
  · funext i
    fin_cases i <;> simp [List.foldl,visit,Function.update]
  · simp [List.foldl,visit,Function.update]

def predictionVisit (flags : Gated.Contraction) (key : Fin 4 → Float32) (decay : Float32) : Bank → Fin 4 → Bank :=
  visit (fun _ state => FlushToZero.mul state decay)
    (fun i state sum => ArithmeticFold.maddFloat flags.prediction state (key i) sum)

def correctionVisit (flags : Gated.Contraction) (key query : Fin 4 → Float32) (delta : Float32) : Bank → Fin 4 → Bank :=
  visit (fun i state => ArithmeticFold.maddFloat flags.update (key i) delta state)
    (fun i state sum => ArithmeticFold.maddFloat flags.output state (query i) sum)

def prediction (loop : GatedStepSyntax.Loop) (flags : Gated.Contraction)
    (state key : Fin 4 → Float32) (decay : Float32) : Bank :=
  ((List.finRange 4).drop loop.first).foldl (predictionVisit flags key decay) ⟨state,0⟩

def correction (loop : GatedStepSyntax.Loop) (flags : Gated.Contraction)
    (state key query : Fin 4 → Float32) (delta : Float32) : Bank :=
  ((List.finRange 4).drop loop.first).foldl (correctionVisit flags key query delta) ⟨state,0⟩

theorem prediction_state (flags : Gated.Contraction) (state key : Fin 4 → Float32) (decay : Float32) :
    (prediction ⟨0⟩ flags state key decay).state=(fun i => FlushToZero.mul (state i) decay) := by
  unfold prediction predictionVisit
  rw [List.drop_zero]
  exact (four_visits _ _ _).1

theorem prediction_sum (flags : Gated.Contraction) (state key : Fin 4 → Float32) (decay : Float32) :
    (prediction ⟨0⟩ flags state key decay).sum=(List.finRange 4).foldl
      (fun sum i => ArithmeticFold.maddFloat flags.prediction (FlushToZero.mul (state i) decay) (key i) sum) 0 := by
  unfold prediction predictionVisit
  rw [List.drop_zero]
  exact (four_visits _ _ _).2

theorem correction_state (flags : Gated.Contraction) (state key query : Fin 4 → Float32) (delta : Float32) :
    (correction ⟨0⟩ flags state key query delta).state=
      (fun i => ArithmeticFold.maddFloat flags.update (key i) delta (state i)) := by
  unfold correction correctionVisit
  rw [List.drop_zero]
  exact (four_visits _ _ _).1

theorem correction_sum (flags : Gated.Contraction) (state key query : Fin 4 → Float32) (delta : Float32) :
    (correction ⟨0⟩ flags state key query delta).sum=(List.finRange 4).foldl
      (fun sum i => ArithmeticFold.maddFloat flags.output
        (ArithmeticFold.maddFloat flags.update (key i) delta (state i)) (query i) sum) 0 := by
  unfold correction correctionVisit
  rw [List.drop_zero]
  exact (four_visits _ _ _).2

end Inference.Kernels.Delta.GatedLaneSource
