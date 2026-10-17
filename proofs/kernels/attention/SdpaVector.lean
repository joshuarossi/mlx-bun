import kernels.attention.SdpaScore
import kernels.attention.SdpaLayout
import kernels.attention.SdpaMerge

namespace Inference.Kernels.Attention.SdpaVector
open Contracts.Mlx Contracts.Mlx.Numerics SdpaUpdate
open FloatLib FloatLib.Floats FloatLib.Floats.Formats.BinaryInterchange
abbrev BF := BFloat16Arithmetic.Value

-- One query, one 256-wide head, nonempty BF16 K/V cache, no mask or sinks:
-- the one-pass sdpa_vector kernel. Host dispatch and native buffers remain
-- separate from this numerical/source-layout composition.
structure Platform where
  merge : SdpaMerge.Platform
  normalization : SdpaNormalize.Platform
  scoreContracted : Bool
  maximum : Float32 → Float32 → Float32
  simdMaximum : (Fin 32 → Float32) → Float32

def initialShift : Float32 := Float32.ofBits 0xff7fffff

theorem initial_finite : initialShift.isFinite = true := by decide +kernel

def scores (p : Platform) (query : Fin 256 → BF) (keys : Fin steps → Fin 256 → BF) (time : Fin steps) : Float32 :=
  SdpaScore.source p.scoreContracted p.merge.reduce query (keys time)
def valuesAt (values : Fin steps → Fin 256 → BF) (coordinate : Fin 256) (time : Fin steps) : Float32 :=
  BFloat16.widen (values time coordinate)

def partials (p : Platform) (query : Fin 256 → BF) (keys values : Fin steps → Fin 256 → BF)
    (coordinate : Fin 256) (group : Fin 32) : State :=
  SdpaLoop.run p.merge.scalar p.maximum (scores p query keys) (valuesAt values coordinate)
    (SdpaLayout.keys steps group) (SdpaLoop.initial initialShift)

-- Source maximum and denominator are shared by all 256 output coordinates.
-- This proof shows that the per-coordinate description preserves that fact.
theorem run_shared (p : SdpaUpdate.Platform) (choose : Float32 → Float32 → Float32)
    (score a b : α → Float32) (indices : List α) (sa sb : State)
    (hs : sa.shift = sb.shift) (hd : sa.denominator = sb.denominator) :
    (SdpaLoop.run p choose score a indices sa).shift = (SdpaLoop.run p choose score b indices sb).shift ∧
    (SdpaLoop.run p choose score a indices sa).denominator = (SdpaLoop.run p choose score b indices sb).denominator := by
  induction indices generalizing sa sb with
  | nil => exact ⟨hs, hd⟩
  | cons i rest ih =>
    apply ih
    · simp only [SdpaLoop.next, step, hs]
    · simp only [SdpaLoop.next, step, hs, hd]

theorem partials_shared (p : Platform) (query : Fin 256 → BF) (keys values : Fin steps → Fin 256 → BF)
    (a b : Fin 256) (group : Fin 32) :
    (partials p query keys values a group).shift = (partials p query keys values b group).shift ∧
    (partials p query keys values a group).denominator = (partials p query keys values b group).denominator :=
  run_shared p.merge.scalar p.maximum _ _ _ _ _ _ rfl rfl

def commonShift (p : Platform) (query : Fin 256 → BF) (keys values : Fin steps → Fin 256 → BF) : Float32 :=
  p.simdMaximum (fun group => (partials p query keys values 0 group).shift)
def merged (p : Platform) (query : Fin 256 → BF) (keys values : Fin steps → Fin 256 → BF) (coordinate : Fin 256) : State :=
  SdpaMerge.forward p.merge (partials p query keys values coordinate) (commonShift p query keys values)
def forward (p : Platform) (query : Fin 256 → BF) (keys values : Fin steps → Fin 256 → BF) (coordinate : Fin 256) : BF :=
  SdpaNormalize.value p.normalization (merged p query keys values coordinate)

noncomputable def targetScores (query : Fin 256 → ℝ) (keys : Fin steps → Fin 256 → ℝ) (time : Fin steps) : ℝ :=
  SdpaScore.target query (keys time)
noncomputable def scoreBudgets (p : Platform) (query : Fin 256 → BF) (keys : Fin steps → Fin 256 → BF)
    (targetQuery errorQuery : Fin 256 → ℝ) (targetKeys errorKeys : Fin steps → Fin 256 → ℝ) (time : Fin steps) : ℝ :=
  SdpaScore.budget p.scoreContracted p.merge.reduction.tree query (keys time) targetQuery (targetKeys time) errorQuery (errorKeys time)
noncomputable def target (query : Fin 256 → ℝ) (keys values : Fin steps → Fin 256 → ℝ) (coordinate : Fin 256) : ℝ :=
  OnlineSoftmax.softmaxWeighted (targetScores query keys) (fun time => values time coordinate) (List.finRange steps)

noncomputable def partialTargets (p : Platform) (query : Fin 256 → BF) (keys values : Fin steps → Fin 256 → BF)
    (targetQuery : Fin 256 → ℝ) (targetKeys targetValues : Fin steps → Fin 256 → ℝ) (coordinate : Fin 256) (group : Fin 32) : OnlineSoftmax.Summary :=
  OnlineSoftmax.reference (targetScores targetQuery targetKeys) (fun time => targetValues time coordinate)
    (SdpaLayout.keys steps group) (real (partials p query keys values coordinate group).shift)

noncomputable def partialBudgets (p : Platform) (query : Fin 256 → BF) (keys values : Fin steps → Fin 256 → BF)
    (targetQuery errorQuery : Fin 256 → ℝ) (targetKeys targetValues errorKeys errorValues : Fin steps → Fin 256 → ℝ)
    (coordinate : Fin 256) (group : Fin 32) : Error :=
  SdpaLoop.errorRun p.merge.scalar p.maximum (scores p query keys) (valuesAt values coordinate)
    (targetScores targetQuery targetKeys) (fun time => targetValues time coordinate)
    (scoreBudgets p query keys targetQuery errorQuery targetKeys errorKeys) (fun time => errorValues time coordinate)
    [] (SdpaLayout.keys steps group) (SdpaLoop.initial initialShift) ⟨0, 0⟩

noncomputable def budget (p : Platform) (query : Fin 256 → BF) (keys values : Fin steps → Fin 256 → BF)
    (targetQuery errorQuery : Fin 256 → ℝ) (targetKeys targetValues errorKeys errorValues : Fin steps → Fin 256 → ℝ)
    (coordinate : Fin 256) : ℝ :=
  SdpaNormalize.budget p.normalization (merged p query keys values coordinate)
    (OnlineSoftmax.reference (targetScores targetQuery targetKeys) (fun time => targetValues time coordinate) (List.finRange steps)
      (real (commonShift p query keys values)))
    (SdpaMerge.budget p.merge (partials p query keys values coordinate) (commonShift p query keys values)
      (partialTargets p query keys values targetQuery targetKeys targetValues coordinate)
      (partialBudgets p query keys values targetQuery errorQuery targetKeys targetValues errorKeys errorValues coordinate))

structure Finite (p : Platform) (query : Fin 256 → BF) (keys values : Fin steps → Fin 256 → BF) : Prop where
  queryFinite : ∀ i, Model.isFinite (query i) = true
  keysFinite : ∀ t i, Model.isFinite (keys t i) = true
  valuesFinite : ∀ t i, Model.isFinite (values t i) = true
  scoresFinite : ∀ t, Arithmetic.Finite (SdpaScore.bind query (keys t)) (SdpaScore.expression p.scoreContracted p.merge.reduction.tree)
  loops : ∀ coordinate group, SdpaLoop.Finite p.merge.scalar p.maximum (scores p query keys) (valuesAt values coordinate)
    (SdpaLayout.keys steps group) (SdpaLoop.initial initialShift)
  merge : ∀ coordinate, SdpaMerge.Finite p.merge (partials p query keys values coordinate) (commonShift p query keys values)
  normalization : ∀ coordinate, SdpaNormalize.Finite p.normalization (merged p query keys values coordinate)

structure InputError (query : Fin 256 → BF) (keys values : Fin steps → Fin 256 → BF)
    (targetQuery errorQuery : Fin 256 → ℝ) (targetKeys targetValues errorKeys errorValues : Fin steps → Fin 256 → ℝ) : Prop where
  query : ∀ i, |Model.toReal (query i) - targetQuery i| ≤ errorQuery i
  keys : ∀ t i, |Model.toReal (keys t i) - targetKeys t i| ≤ errorKeys t i
  values : ∀ t i, |Model.toReal (values t i) - targetValues t i| ≤ errorValues t i

theorem partials_error (p : Platform) (query : Fin 256 → BF) (keys values : Fin steps → Fin 256 → BF)
    (targetQuery errorQuery : Fin 256 → ℝ) (targetKeys targetValues errorKeys errorValues : Fin steps → Fin 256 → ℝ)
    (he : InputError query keys values targetQuery errorQuery targetKeys targetValues errorKeys errorValues)
    (hf : Finite p query keys values) (coordinate : Fin 256) (group : Fin 32) :
    StateError (partials p query keys values coordinate group)
      (partialTargets p query keys values targetQuery targetKeys targetValues coordinate group)
      (partialBudgets p query keys values targetQuery errorQuery targetKeys targetValues errorKeys errorValues coordinate group) := by
  apply SdpaLoop.initialized_run_error p.merge.scalar p.maximum (scores p query keys) (valuesAt values coordinate)
    (targetScores targetQuery targetKeys) (fun time => targetValues time coordinate)
    (scoreBudgets p query keys targetQuery errorQuery targetKeys errorKeys) (fun time => errorValues time coordinate)
    _ _ (SdpaLayout.keys steps group) initialShift (hf.loops coordinate group)
  · intro t
    exact SdpaScore.source_error p.scoreContracted p.merge.reduce p.merge.reduction query (keys t)
      targetQuery (targetKeys t) errorQuery (errorKeys t) he.query (he.keys t) hf.queryFinite (hf.keysFinite t) (hf.scoresFinite t)
  · intro t
    rw [valuesAt, BFloat16.widen_real _ (hf.valuesFinite t coordinate)]
    exact he.values t coordinate

theorem forward_error (p : Platform) (query : Fin 256 → BF) (keys values : Fin steps → Fin 256 → BF)
    (targetQuery errorQuery : Fin 256 → ℝ) (targetKeys targetValues errorKeys errorValues : Fin steps → Fin 256 → ℝ)
    (he : InputError query keys values targetQuery errorQuery targetKeys targetValues errorKeys errorValues)
    (hf : Finite p query keys values) (hn : 0 < steps) (coordinate : Fin 256) :
    |Model.toReal (forward p query keys values coordinate) - target targetQuery targetKeys targetValues coordinate| ≤
      budget p query keys values targetQuery errorQuery targetKeys targetValues errorKeys errorValues coordinate := by
  have h := SdpaMerge.normalized_error p.merge p.normalization (partials p query keys values coordinate) (commonShift p query keys values)
    (targetScores targetQuery targetKeys) (fun time => targetValues time coordinate) (SdpaLayout.keys steps)
    (partialBudgets p query keys values targetQuery errorQuery targetKeys targetValues errorKeys errorValues coordinate)
    (partials_error p query keys values targetQuery errorQuery targetKeys targetValues errorKeys errorValues he hf coordinate)
    (hf.merge coordinate) (hf.normalization coordinate) (SdpaLayout.nonempty steps hn)
  have href := OnlineSoftmax.reference_permutation (targetScores targetQuery targetKeys) (fun time => targetValues time coordinate)
    _ _ (SdpaLayout.coverage steps) (real (commonShift p query keys values))
  have ht := congrArg OnlineSoftmax.normalized href
  simp only [OnlineSoftmax.normalized_reference] at ht
  dsimp only [SdpaLayout.allKeys] at href ht
  rw [ht, href] at h
  exact h

theorem forward_finite (p : Platform) (query : Fin 256 → BF) (keys values : Fin steps → Fin 256 → BF)
    (hf : Finite p query keys values) (coordinate : Fin 256) : Model.isFinite (forward p query keys values coordinate) = true :=
  (hf.normalization coordinate).cast

-- The post-barrier scratch read is the source's transposed matrix access,
-- not an assumed connection to the numerator reduction above.
def storedNumerator (p : Platform) (query : Fin 256 → BF) (keys values : Fin steps → Fin 256 → BF)
    (group : Fin 32) (offset : Fin 8) (before : Nat → Float32) (schedule : List Nat) : Float32 :=
  let scratch := SdpaLayout.stored
    (fun writerGroup writerLane => (partials p query keys values (SdpaLayout.coordinate writerLane offset) writerGroup).numerator)
    before schedule
  p.merge.reduce (fun lane => FlushToZero.mul (scratch (group.val*32+lane.val))
    (exponential p.merge.scalar (partials p query keys values 0 lane).shift (commonShift p query keys values)))

theorem stored_numerator_execution (p : Platform) (query : Fin 256 → BF) (keys values : Fin steps → Fin 256 → BF)
    (group : Fin 32) (offset : Fin 8) (before : Nat → Float32) (schedule : List Nat)
    (hs : schedule.Perm (List.range 1024)) :
    storedNumerator p query keys values group offset before schedule =
      (merged p query keys values (SdpaLayout.coordinate group offset)).numerator := by
  unfold storedNumerator merged SdpaMerge.forward SdpaMerge.source SdpaMerge.component
  simp only [ite_true]
  apply congrArg p.merge.reduce
  funext lane
  rw [SdpaLayout.scratch_read _ before schedule hs group lane]
  rw [(partials_shared p query keys values 0 (SdpaLayout.coordinate group offset) lane).1]

def storedDenominator (p : Platform) (query : Fin 256 → BF) (keys values : Fin steps → Fin 256 → BF)
    (before : Nat → Float32) (schedule : List Nat) : Float32 :=
  let sums := Memory.writeCells (fun i => (partials p query keys values 0 ⟨i%32, by omega⟩).denominator) schedule before
  p.merge.reduce (fun lane => FlushToZero.mul (sums lane.val)
    (exponential p.merge.scalar (partials p query keys values 0 lane).shift (commonShift p query keys values)))

theorem stored_denominator_execution (p : Platform) (query : Fin 256 → BF) (keys values : Fin steps → Fin 256 → BF)
    (coordinate : Fin 256) (before : Nat → Float32) (schedule : List Nat)
    (hs : schedule.Perm (List.range 32)) :
    storedDenominator p query keys values before schedule = (merged p query keys values coordinate).denominator := by
  unfold storedDenominator merged SdpaMerge.forward SdpaMerge.source SdpaMerge.component
  simp only [Bool.false_eq_true, ite_false]
  apply congrArg p.merge.reduce
  funext lane
  rw [Memory.writeCells_read, ite_eq_left (hs.mem_iff.mpr (List.mem_range.mpr lane.isLt))]
  simp only [Nat.mod_eq_of_lt lane.isLt]
  rw [(partials_shared p query keys values 0 coordinate lane).1, (partials_shared p query keys values 0 coordinate lane).2]

end Inference.Kernels.Attention.SdpaVector
