import kernels.delta.GatedLaneSource

namespace Inference.Kernels.Delta.GatedStepSource
open Contracts.Mlx GatedStepSyntax
set_option maxRecDepth 2000
set_option maxHeartbeats 1000000
attribute [local irreducible] parsePrediction parseDelta parseCorrection
  GatedLaneSource.prediction GatedLaneSource.correction

def state (input : Nat → Float32) (lane : Fin 32) (i : Fin 4) : Float32 := input (Gated.laneIndex lane i).val
def key (input : Nat → Float32) (lane : Fin 32) (i : Fin 4) : Float32 := input (128+(Gated.laneIndex lane i).val)
def query (input : Nat → Float32) (lane : Fin 32) (i : Fin 4) : Float32 := input (256+(Gated.laneIndex lane i).val)

def predicted (loop : Loop) (input : Nat → Float32) (flags : Gated.Contraction) (lane : Fin 32) : GatedLaneSource.Bank :=
  GatedLaneSource.prediction loop flags (state input lane) (key input lane) (input 385)

def prediction (loop : Loop) (input : Nat → Float32) (flags : Gated.Contraction)
    (reduce : (Fin 32 → Float32) → Float32) : Float32 := reduce (fun lane => (predicted loop input flags lane).sum)

def difference : Delta → (Nat → Float32) → Float32 → Float32
  | .differenceTimesBeta,input,prediction => FlushToZero.mul (Arithmetic.sub (input 384) prediction) (input 386)

def corrected (first second : Loop) (delta : Delta) (input : Nat → Float32) (flags : Gated.Contraction)
    (reduce : (Fin 32 → Float32) → Float32) (lane : Fin 32) : GatedLaneSource.Bank :=
  GatedLaneSource.correction second flags (predicted first input flags lane).state (key input lane) (query input lane)
    (difference delta input (prediction first input flags reduce))

@[ext] structure Result where
  state : Fin 32 → Fin 4 → Float32
  output : Float32

def evaluate (first second : Loop) (delta : Delta) (input : Nat → Float32) (flags : Gated.Contraction)
    (reduce : (Fin 32 → Float32) → Float32) : Result where
  state := fun lane => (corrected first second delta input flags reduce lane).state
  output := reduce (fun lane => (corrected first second delta input flags reduce lane).sum)

def source (input : Nat → Float32) (flags : Gated.Contraction)
    (reduce : (Fin 32 → Float32) → Float32) : Option Result := do
  let first ←parsePrediction predictionSource
  let delta ←parseDelta deltaSource
  let second ←parseCorrection correctionSource
  pure (evaluate first second delta input flags reduce)

theorem prediction_eq (input : Nat → Float32) (flags : Gated.Contraction)
    (reduce : (Fin 32 → Float32) → Float32) : prediction ⟨0⟩ input flags reduce=Gated.sourcePrediction input reduce flags := by
  unfold prediction predicted
  simp only [GatedLaneSource.prediction_sum]
  rfl

theorem corrected_state (input : Nat → Float32) (flags : Gated.Contraction)
    (reduce : (Fin 32 → Float32) → Float32) (lane : Fin 32) (i : Fin 4) :
    (corrected ⟨0⟩ ⟨0⟩ .differenceTimesBeta input flags reduce lane).state i=
      Gated.sourceState input reduce flags (Gated.laneIndex lane i) := by
  unfold corrected
  rw [GatedLaneSource.correction_state,prediction_eq]
  unfold predicted
  rw [GatedLaneSource.prediction_state]
  rfl

theorem corrected_sum (input : Nat → Float32) (flags : Gated.Contraction)
    (reduce : (Fin 32 → Float32) → Float32) (lane : Fin 32) :
    (corrected ⟨0⟩ ⟨0⟩ .differenceTimesBeta input flags reduce lane).sum=
      (List.finRange 4).foldl (fun sum i => ArithmeticFold.maddFloat flags.output
        (Gated.sourceState input reduce flags (Gated.laneIndex lane i))
        (input (256+(Gated.laneIndex lane i).val)) sum) 0 := by
  unfold corrected
  rw [GatedLaneSource.correction_sum,prediction_eq]
  unfold predicted
  rw [GatedLaneSource.prediction_state]
  rfl

theorem source_execution (input : Nat → Float32) (flags : Gated.Contraction)
    (reduce : (Fin 32 → Float32) → Float32) :
    source input flags reduce=some ⟨
      fun lane i => Gated.sourceState input reduce flags (Gated.laneIndex lane i),
      Gated.sourceOutput input reduce flags⟩ := by
  unfold source
  rw [parsed_prediction,parsed_delta,parsed_correction]
  change some (evaluate ⟨0⟩ ⟨0⟩ .differenceTimesBeta input flags reduce)=_
  apply congrArg some
  apply Result.ext
  · funext lane i
    exact corrected_state input flags reduce lane i
  · change reduce (fun lane => (corrected ⟨0⟩ ⟨0⟩ .differenceTimesBeta input flags reduce lane).sum)=_
    simp only [corrected_sum]
    rfl

end Inference.Kernels.Delta.GatedStepSource
