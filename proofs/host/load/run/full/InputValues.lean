import host.load.run.full.Initial
import host.load.InputValues
namespace Host.Load.Run.Full
open Host.Load.Extract Host.Mlx Host.Mlx.GlueStep Host.Mlx.FfiEval
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
set_option Elab.async false

theorem empty_input_caches : EmptyCacheInputs parameterChoice := by
  intro p s h
  have hp : p < 64 := by
    have hp := (List.getElem?_eq_some_iff.mp h).choose
    exact hp
  exact ⟨_, cache_at_zero ⟨p, hp⟩, rfl, rfl⟩

macro "full_initial_inputs" key:ident : tactic => `(tactic|
  cases ($key) with
  | lin j l =>
    rcases j with _ | j
    · cases l <;> rfl
    rcases j with _ | j
    · cases l <;> rfl
    rcases j with _ | j
    · cases l <;> rfl
    rcases j with _ | j
    · cases l <;> rfl
    rcases j with _ | j
    · cases l <;> rfl
    cases l <;> rfl
  | mlp m => cases m <;> rfl
  | cache c =>
    rcases c with _ | c
    · rfl
    rcases c with _ | c <;> rfl
  | _ => rfl
)

private theorem stage0_input_values (value : TensorValues) (key : SKey) :
    stepInputs (weights value) 0 initialHandles (.stage 0 key) =
      (parameterInput parameterChoice (.stage 0 key)).map value := by full_initial_inputs key

private theorem stage1_input_values (value : TensorValues) (key : SKey) :
    stepInputs (weights value) 0 initialHandles (.stage 1 key) =
      (parameterInput parameterChoice (.stage 1 key)).map value := by full_initial_inputs key

private theorem stage2_input_values (value : TensorValues) (key : SKey) :
    stepInputs (weights value) 0 initialHandles (.stage 2 key) =
      (parameterInput parameterChoice (.stage 2 key)).map value := by full_initial_inputs key

private theorem stage3_input_values (value : TensorValues) (key : SKey) :
    stepInputs (weights value) 0 initialHandles (.stage 3 key) =
      (parameterInput parameterChoice (.stage 3 key)).map value := by full_initial_inputs key

private theorem stage4_input_values (value : TensorValues) (key : SKey) :
    stepInputs (weights value) 0 initialHandles (.stage 4 key) =
      (parameterInput parameterChoice (.stage 4 key)).map value := by full_initial_inputs key

private theorem stage5_input_values (value : TensorValues) (key : SKey) :
    stepInputs (weights value) 0 initialHandles (.stage 5 key) =
      (parameterInput parameterChoice (.stage 5 key)).map value := by full_initial_inputs key

private theorem stage6_input_values (value : TensorValues) (key : SKey) :
    stepInputs (weights value) 0 initialHandles (.stage 6 key) =
      (parameterInput parameterChoice (.stage 6 key)).map value := by full_initial_inputs key

private theorem stage7_input_values (value : TensorValues) (key : SKey) :
    stepInputs (weights value) 0 initialHandles (.stage 7 key) =
      (parameterInput parameterChoice (.stage 7 key)).map value := by full_initial_inputs key

private theorem stage8_input_values (value : TensorValues) (key : SKey) :
    stepInputs (weights value) 0 initialHandles (.stage 8 key) =
      (parameterInput parameterChoice (.stage 8 key)).map value := by full_initial_inputs key

private theorem stage9_input_values (value : TensorValues) (key : SKey) :
    stepInputs (weights value) 0 initialHandles (.stage 9 key) =
      (parameterInput parameterChoice (.stage 9 key)).map value := by full_initial_inputs key

private theorem stage10_input_values (value : TensorValues) (key : SKey) :
    stepInputs (weights value) 0 initialHandles (.stage 10 key) =
      (parameterInput parameterChoice (.stage 10 key)).map value := by full_initial_inputs key

private theorem stage11_input_values (value : TensorValues) (key : SKey) :
    stepInputs (weights value) 0 initialHandles (.stage 11 key) =
      (parameterInput parameterChoice (.stage 11 key)).map value := by full_initial_inputs key

private theorem stage12_input_values (value : TensorValues) (key : SKey) :
    stepInputs (weights value) 0 initialHandles (.stage 12 key) =
      (parameterInput parameterChoice (.stage 12 key)).map value := by full_initial_inputs key

private theorem stage13_input_values (value : TensorValues) (key : SKey) :
    stepInputs (weights value) 0 initialHandles (.stage 13 key) =
      (parameterInput parameterChoice (.stage 13 key)).map value := by full_initial_inputs key

private theorem stage14_input_values (value : TensorValues) (key : SKey) :
    stepInputs (weights value) 0 initialHandles (.stage 14 key) =
      (parameterInput parameterChoice (.stage 14 key)).map value := by full_initial_inputs key

private theorem stage15_input_values (value : TensorValues) (key : SKey) :
    stepInputs (weights value) 0 initialHandles (.stage 15 key) =
      (parameterInput parameterChoice (.stage 15 key)).map value := by full_initial_inputs key

private theorem stage16_input_values (value : TensorValues) (key : SKey) :
    stepInputs (weights value) 0 initialHandles (.stage 16 key) =
      (parameterInput parameterChoice (.stage 16 key)).map value := by full_initial_inputs key

private theorem stage17_input_values (value : TensorValues) (key : SKey) :
    stepInputs (weights value) 0 initialHandles (.stage 17 key) =
      (parameterInput parameterChoice (.stage 17 key)).map value := by full_initial_inputs key

private theorem stage18_input_values (value : TensorValues) (key : SKey) :
    stepInputs (weights value) 0 initialHandles (.stage 18 key) =
      (parameterInput parameterChoice (.stage 18 key)).map value := by full_initial_inputs key

private theorem stage19_input_values (value : TensorValues) (key : SKey) :
    stepInputs (weights value) 0 initialHandles (.stage 19 key) =
      (parameterInput parameterChoice (.stage 19 key)).map value := by full_initial_inputs key

private theorem stage20_input_values (value : TensorValues) (key : SKey) :
    stepInputs (weights value) 0 initialHandles (.stage 20 key) =
      (parameterInput parameterChoice (.stage 20 key)).map value := by full_initial_inputs key

private theorem stage21_input_values (value : TensorValues) (key : SKey) :
    stepInputs (weights value) 0 initialHandles (.stage 21 key) =
      (parameterInput parameterChoice (.stage 21 key)).map value := by full_initial_inputs key

private theorem stage22_input_values (value : TensorValues) (key : SKey) :
    stepInputs (weights value) 0 initialHandles (.stage 22 key) =
      (parameterInput parameterChoice (.stage 22 key)).map value := by full_initial_inputs key

private theorem stage23_input_values (value : TensorValues) (key : SKey) :
    stepInputs (weights value) 0 initialHandles (.stage 23 key) =
      (parameterInput parameterChoice (.stage 23 key)).map value := by full_initial_inputs key

private theorem stage24_input_values (value : TensorValues) (key : SKey) :
    stepInputs (weights value) 0 initialHandles (.stage 24 key) =
      (parameterInput parameterChoice (.stage 24 key)).map value := by full_initial_inputs key

private theorem stage25_input_values (value : TensorValues) (key : SKey) :
    stepInputs (weights value) 0 initialHandles (.stage 25 key) =
      (parameterInput parameterChoice (.stage 25 key)).map value := by full_initial_inputs key

private theorem stage26_input_values (value : TensorValues) (key : SKey) :
    stepInputs (weights value) 0 initialHandles (.stage 26 key) =
      (parameterInput parameterChoice (.stage 26 key)).map value := by full_initial_inputs key

private theorem stage27_input_values (value : TensorValues) (key : SKey) :
    stepInputs (weights value) 0 initialHandles (.stage 27 key) =
      (parameterInput parameterChoice (.stage 27 key)).map value := by full_initial_inputs key

private theorem stage28_input_values (value : TensorValues) (key : SKey) :
    stepInputs (weights value) 0 initialHandles (.stage 28 key) =
      (parameterInput parameterChoice (.stage 28 key)).map value := by full_initial_inputs key

private theorem stage29_input_values (value : TensorValues) (key : SKey) :
    stepInputs (weights value) 0 initialHandles (.stage 29 key) =
      (parameterInput parameterChoice (.stage 29 key)).map value := by full_initial_inputs key

private theorem stage30_input_values (value : TensorValues) (key : SKey) :
    stepInputs (weights value) 0 initialHandles (.stage 30 key) =
      (parameterInput parameterChoice (.stage 30 key)).map value := by full_initial_inputs key

private theorem stage31_input_values (value : TensorValues) (key : SKey) :
    stepInputs (weights value) 0 initialHandles (.stage 31 key) =
      (parameterInput parameterChoice (.stage 31 key)).map value := by full_initial_inputs key

private theorem stage32_input_values (value : TensorValues) (key : SKey) :
    stepInputs (weights value) 0 initialHandles (.stage 32 key) =
      (parameterInput parameterChoice (.stage 32 key)).map value := by full_initial_inputs key

private theorem stage33_input_values (value : TensorValues) (key : SKey) :
    stepInputs (weights value) 0 initialHandles (.stage 33 key) =
      (parameterInput parameterChoice (.stage 33 key)).map value := by full_initial_inputs key

private theorem stage34_input_values (value : TensorValues) (key : SKey) :
    stepInputs (weights value) 0 initialHandles (.stage 34 key) =
      (parameterInput parameterChoice (.stage 34 key)).map value := by full_initial_inputs key

private theorem stage35_input_values (value : TensorValues) (key : SKey) :
    stepInputs (weights value) 0 initialHandles (.stage 35 key) =
      (parameterInput parameterChoice (.stage 35 key)).map value := by full_initial_inputs key

private theorem stage36_input_values (value : TensorValues) (key : SKey) :
    stepInputs (weights value) 0 initialHandles (.stage 36 key) =
      (parameterInput parameterChoice (.stage 36 key)).map value := by full_initial_inputs key

private theorem stage37_input_values (value : TensorValues) (key : SKey) :
    stepInputs (weights value) 0 initialHandles (.stage 37 key) =
      (parameterInput parameterChoice (.stage 37 key)).map value := by full_initial_inputs key

private theorem stage38_input_values (value : TensorValues) (key : SKey) :
    stepInputs (weights value) 0 initialHandles (.stage 38 key) =
      (parameterInput parameterChoice (.stage 38 key)).map value := by full_initial_inputs key

private theorem stage39_input_values (value : TensorValues) (key : SKey) :
    stepInputs (weights value) 0 initialHandles (.stage 39 key) =
      (parameterInput parameterChoice (.stage 39 key)).map value := by full_initial_inputs key

private theorem stage40_input_values (value : TensorValues) (key : SKey) :
    stepInputs (weights value) 0 initialHandles (.stage 40 key) =
      (parameterInput parameterChoice (.stage 40 key)).map value := by full_initial_inputs key

private theorem stage41_input_values (value : TensorValues) (key : SKey) :
    stepInputs (weights value) 0 initialHandles (.stage 41 key) =
      (parameterInput parameterChoice (.stage 41 key)).map value := by full_initial_inputs key

private theorem stage42_input_values (value : TensorValues) (key : SKey) :
    stepInputs (weights value) 0 initialHandles (.stage 42 key) =
      (parameterInput parameterChoice (.stage 42 key)).map value := by full_initial_inputs key

private theorem stage43_input_values (value : TensorValues) (key : SKey) :
    stepInputs (weights value) 0 initialHandles (.stage 43 key) =
      (parameterInput parameterChoice (.stage 43 key)).map value := by full_initial_inputs key

private theorem stage44_input_values (value : TensorValues) (key : SKey) :
    stepInputs (weights value) 0 initialHandles (.stage 44 key) =
      (parameterInput parameterChoice (.stage 44 key)).map value := by full_initial_inputs key

private theorem stage45_input_values (value : TensorValues) (key : SKey) :
    stepInputs (weights value) 0 initialHandles (.stage 45 key) =
      (parameterInput parameterChoice (.stage 45 key)).map value := by full_initial_inputs key

private theorem stage46_input_values (value : TensorValues) (key : SKey) :
    stepInputs (weights value) 0 initialHandles (.stage 46 key) =
      (parameterInput parameterChoice (.stage 46 key)).map value := by full_initial_inputs key

private theorem stage47_input_values (value : TensorValues) (key : SKey) :
    stepInputs (weights value) 0 initialHandles (.stage 47 key) =
      (parameterInput parameterChoice (.stage 47 key)).map value := by full_initial_inputs key

private theorem stage48_input_values (value : TensorValues) (key : SKey) :
    stepInputs (weights value) 0 initialHandles (.stage 48 key) =
      (parameterInput parameterChoice (.stage 48 key)).map value := by full_initial_inputs key

private theorem stage49_input_values (value : TensorValues) (key : SKey) :
    stepInputs (weights value) 0 initialHandles (.stage 49 key) =
      (parameterInput parameterChoice (.stage 49 key)).map value := by full_initial_inputs key

private theorem stage50_input_values (value : TensorValues) (key : SKey) :
    stepInputs (weights value) 0 initialHandles (.stage 50 key) =
      (parameterInput parameterChoice (.stage 50 key)).map value := by full_initial_inputs key

private theorem stage51_input_values (value : TensorValues) (key : SKey) :
    stepInputs (weights value) 0 initialHandles (.stage 51 key) =
      (parameterInput parameterChoice (.stage 51 key)).map value := by full_initial_inputs key

private theorem stage52_input_values (value : TensorValues) (key : SKey) :
    stepInputs (weights value) 0 initialHandles (.stage 52 key) =
      (parameterInput parameterChoice (.stage 52 key)).map value := by full_initial_inputs key

private theorem stage53_input_values (value : TensorValues) (key : SKey) :
    stepInputs (weights value) 0 initialHandles (.stage 53 key) =
      (parameterInput parameterChoice (.stage 53 key)).map value := by full_initial_inputs key

private theorem stage54_input_values (value : TensorValues) (key : SKey) :
    stepInputs (weights value) 0 initialHandles (.stage 54 key) =
      (parameterInput parameterChoice (.stage 54 key)).map value := by full_initial_inputs key

private theorem stage55_input_values (value : TensorValues) (key : SKey) :
    stepInputs (weights value) 0 initialHandles (.stage 55 key) =
      (parameterInput parameterChoice (.stage 55 key)).map value := by full_initial_inputs key

private theorem stage56_input_values (value : TensorValues) (key : SKey) :
    stepInputs (weights value) 0 initialHandles (.stage 56 key) =
      (parameterInput parameterChoice (.stage 56 key)).map value := by full_initial_inputs key

private theorem stage57_input_values (value : TensorValues) (key : SKey) :
    stepInputs (weights value) 0 initialHandles (.stage 57 key) =
      (parameterInput parameterChoice (.stage 57 key)).map value := by full_initial_inputs key

private theorem stage58_input_values (value : TensorValues) (key : SKey) :
    stepInputs (weights value) 0 initialHandles (.stage 58 key) =
      (parameterInput parameterChoice (.stage 58 key)).map value := by full_initial_inputs key

private theorem stage59_input_values (value : TensorValues) (key : SKey) :
    stepInputs (weights value) 0 initialHandles (.stage 59 key) =
      (parameterInput parameterChoice (.stage 59 key)).map value := by full_initial_inputs key

private theorem stage60_input_values (value : TensorValues) (key : SKey) :
    stepInputs (weights value) 0 initialHandles (.stage 60 key) =
      (parameterInput parameterChoice (.stage 60 key)).map value := by full_initial_inputs key

private theorem stage61_input_values (value : TensorValues) (key : SKey) :
    stepInputs (weights value) 0 initialHandles (.stage 61 key) =
      (parameterInput parameterChoice (.stage 61 key)).map value := by full_initial_inputs key

private theorem stage62_input_values (value : TensorValues) (key : SKey) :
    stepInputs (weights value) 0 initialHandles (.stage 62 key) =
      (parameterInput parameterChoice (.stage 62 key)).map value := by full_initial_inputs key

private theorem stage63_input_values (value : TensorValues) (key : SKey) :
    stepInputs (weights value) 0 initialHandles (.stage 63 key) =
      (parameterInput parameterChoice (.stage 63 key)).map value := by full_initial_inputs key

theorem stage_input_values (value : TensorValues) (p : Fin 64) (key : SKey) :
    stepInputs (weights value) 0 initialHandles (.stage p.val key) =
      (parameterInput parameterChoice (.stage p.val key)).map value := by
  fin_cases p
  · exact stage0_input_values value key
  · exact stage1_input_values value key
  · exact stage2_input_values value key
  · exact stage3_input_values value key
  · exact stage4_input_values value key
  · exact stage5_input_values value key
  · exact stage6_input_values value key
  · exact stage7_input_values value key
  · exact stage8_input_values value key
  · exact stage9_input_values value key
  · exact stage10_input_values value key
  · exact stage11_input_values value key
  · exact stage12_input_values value key
  · exact stage13_input_values value key
  · exact stage14_input_values value key
  · exact stage15_input_values value key
  · exact stage16_input_values value key
  · exact stage17_input_values value key
  · exact stage18_input_values value key
  · exact stage19_input_values value key
  · exact stage20_input_values value key
  · exact stage21_input_values value key
  · exact stage22_input_values value key
  · exact stage23_input_values value key
  · exact stage24_input_values value key
  · exact stage25_input_values value key
  · exact stage26_input_values value key
  · exact stage27_input_values value key
  · exact stage28_input_values value key
  · exact stage29_input_values value key
  · exact stage30_input_values value key
  · exact stage31_input_values value key
  · exact stage32_input_values value key
  · exact stage33_input_values value key
  · exact stage34_input_values value key
  · exact stage35_input_values value key
  · exact stage36_input_values value key
  · exact stage37_input_values value key
  · exact stage38_input_values value key
  · exact stage39_input_values value key
  · exact stage40_input_values value key
  · exact stage41_input_values value key
  · exact stage42_input_values value key
  · exact stage43_input_values value key
  · exact stage44_input_values value key
  · exact stage45_input_values value key
  · exact stage46_input_values value key
  · exact stage47_input_values value key
  · exact stage48_input_values value key
  · exact stage49_input_values value key
  · exact stage50_input_values value key
  · exact stage51_input_values value key
  · exact stage52_input_values value key
  · exact stage53_input_values value key
  · exact stage54_input_values value key
  · exact stage55_input_values value key
  · exact stage56_input_values value key
  · exact stage57_input_values value key
  · exact stage58_input_values value key
  · exact stage59_input_values value key
  · exact stage60_input_values value key
  · exact stage61_input_values value key
  · exact stage62_input_values value key
  · exact stage63_input_values value key

/-- The expected first-step inputs select exactly the values of the loaded
parameter objects. The initial cache contributes no prior tensor inputs. -/
theorem initial_input_values (value : TensorValues) (ids : Value) (key : InKey)
    (hk : key ≠ .tokenIds) :
    stepInputsWithIds (weights value) ids initialHandles key =
      (parameterInput parameterChoice key).map value := by
  cases key with
  | tokenIds => contradiction
  | embedWords | embedScales | embedBiases | finalNorm => rfl
  | head k => cases k <;> rfl
  | stage p k =>
    by_cases hp : p < 64
    · exact stage_input_values value ⟨p, hp⟩ k
    · have hm : parameterChoice.model.stages[p]? = none :=
        List.getElem?_eq_none (by change 64 ≤ p; omega)
      have hs : (stageWeights (weights value))[p]? = none :=
        List.getElem?_eq_none (by simpa [stageWeights] using Nat.le_of_not_gt hp)
      simp [stepInputsWithIds, stepInputs, parameterInput, hm, hs]

end Host.Load.Run.Full
