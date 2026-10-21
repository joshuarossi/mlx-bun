import host.simgraph.iter.Inputs
import host.simgraph.Choose

set_option maxRecDepth 1000000
namespace Host.Mlx.SimGraph.Iter
open Host.Load Host.Load.Extract Host.Load.Run.Full Host.Mlx Host.Mlx.FfiEval Host.Ts

/-! # The iteration's inputs at the images of the template's carriers

The inputs built from the template's carriers (`loadedAt σ ps`, `tensorAt (σ t)`) name
the token and cache inputs at their images under `σ` and the model inputs at the run's
parameter nodes. `inputs_at` turns a kernel check of a template's input table
(`InputsOk`: every input is the carrier of the identity build, and model inputs are
pre-loop nodes) into `forward_iter`'s `hin` premise for any `LoadR` map. -/

/-- Inputs named at the iteration's images: the token and the caches. -/
def movingKey : InKey → Bool
  | .tokenIds => true
  | .stage _ (.cache _) => true
  | _ => false

theorem stageNode_cache_free (st : Stage) (c c' : Cache) (k : SKey) (hk : ∀ n, k ≠ .cache n) :
    stageNode st c k = stageNode st c' k := by
  cases k with
  | cache n => exact absurd rfl (hk n)
  | _ => rfl

theorem inputNode_at (σ : Nat → Nat) (ps : List (Option Nat × Option Nat)) (t : Nat) (key : InKey) :
    inputNode (loadedAt σ ps) (tensorAt (σ t)) key =
      (inputNode (loadedAt (fun j => j) ps) (tensorAt t) key).map
        (fun j => if movingKey key then σ j else j) := by
  cases key with
  | tokenIds => rfl
  | embedWords | embedScales | embedBiases | finalNorm =>
    simp [inputNode, movingKey, loadedAt, Function.comp_def]
  | head l => simp [inputNode, movingKey, loadedAt]
  | stage p k =>
    simp only [inputNode, loadedAt, cachesAt, List.getElem?_map]
    cases hs : parameterChoice.model.stages[p]? with
    | none => rfl
    | some st =>
      cases hq : ps[p]? with
      | none => rfl
      | some q =>
        show stageNode st (cacheAt σ q) k =
          (stageNode st (cacheAt (fun j => j) q) k).map (fun j => if movingKey (.stage p k) then σ j else j)
        by_cases hk : ∃ n, k = .cache n
        · obtain ⟨n, rfl⟩ := hk
          match n with
          | 0 => simp [stageNode, cacheAt, movingKey, tensorAt, Option.map_map, Function.comp_def]
          | 1 => simp [stageNode, cacheAt, movingKey, tensorAt, Option.map_map, Function.comp_def]
          | n + 2 => simp [stageNode, movingKey]
        · have hk' : ∀ n, k ≠ .cache n := fun n h => hk ⟨n, h⟩
          have hm : movingKey (.stage p k) = false := by
            cases k with
            | cache n => exact absurd rfl (hk' n)
            | _ => rfl
          rw [stageNode_cache_free st (cacheAt σ q) (cacheAt (fun j => j) q) k hk', hm]
          simp

/-- A template's input table is carried by the identity build of the template's start
inputs `ps` (token at `tok`), and its model inputs are pre-loop nodes. -/
def InputsOk (inputs : List (InKey × Nat)) (ps : List (Option Nat × Option Nat)) (tok : Nat) : Bool :=
  inputs.all fun (key, j) =>
    decide (inputNode (loadedAt (fun j => j) ps) (tensorAt tok) key = some j) && (movingKey key || decide (j < 20000))

theorem inputsOf_mem {l : List (InKey × Nat)} {k : InKey} {j : Nat} (h : inputsOf l k = some j) : (k, j) ∈ l := by
  unfold inputsOf at h
  obtain ⟨p, hp, rfl⟩ := Option.map_eq_some_iff.mp h
  have hm := List.mem_of_find?_eq_some hp
  have hk := List.find?_some hp
  simp only [beq_iff_eq] at hk
  rw [← hk]
  exact hm

/-- **`forward_iter`'s input premise** at any map fixing the pre-loop nodes. -/
theorem inputs_at (inputs : List (InKey × Nat)) (ps : List (Option Nat × Option Nat)) (tok : Nat)
    (hok : InputsOk inputs ps tok = true) (σ : Nat → Nat) (hfix : ∀ j, j < 20000 → σ j = j) :
    ∀ key j, inputsOf inputs key = some j → inputNode (loadedAt σ ps) (tensorAt (σ tok)) key = some (σ j) := by
  intro key j hj
  have hc := List.all_eq_true.mp hok _ (inputsOf_mem hj)
  simp only [Bool.and_eq_true, decide_eq_true_eq, Bool.or_eq_true] at hc
  obtain ⟨hn, hm⟩ := hc
  rw [inputNode_at, hn]
  cases h : movingKey key with
  | true => simp
  | false =>
    simp only [h, Bool.false_eq_true, false_or] at hm
    simp [hfix j hm]

/-- Every node of the node pairs `ps` is present in `x`. -/
def PresentB (x : Ffi.St) (ps : List (Option Nat × Option Nat)) : Bool :=
  ps.all fun p => (p.1.all fun j => (x.nodes.get j).isSome) && (p.2.all fun j => (x.nodes.get j).isSome)

theorem present_of_B (x : Ffi.St) (ps : List (Option Nat × Option Nat)) (h : PresentB x ps = true) :
    ∀ p ∈ ps, ∀ j, (p.1 = some j ∨ p.2 = some j) → (x.nodes.get j).isSome = true := by
  intro p hp j hj
  have hc := List.all_eq_true.mp h p hp
  simp only [Bool.and_eq_true] at hc
  rcases hj with hj | hj
  · rw [hj] at hc; simpa using hc.1
  · rw [hj] at hc; simpa using hc.2

end Host.Mlx.SimGraph.Iter
