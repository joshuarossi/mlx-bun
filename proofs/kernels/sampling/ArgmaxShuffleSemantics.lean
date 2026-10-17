import kernels.sampling.ArgmaxShuffleSyntax
import kernels.sampling.ArgmaxReductionDevice

namespace Inference.Kernels.Sampling.ArgmaxShuffleSemantics
open Contracts.Mlx ArgmaxShuffleSyntax ArgmaxPairs NormalizedArgmaxLayout
open Contracts.Mlx.Numerics
open FloatLib FloatLib.Floats FloatLib.Floats.Formats.BinaryInterchange
set_option maxRecDepth 20000

-- Restricted typed expression semantics: none denotes the exact -infinity
-- sentinel. Some floats require the existing finite contract; NaNs are not
-- silently ordered or coerced into finite values by this refinement.
inductive Value where
  | score : Option Float32 → Value
  | uint : Nat → Value
  | boolean : Bool → Value
abbrev Env := String → Option Value

def greater : Option Float32 → Option Float32 → Bool
  | none,none => false | some _,none => true | none,some _ => false
  | some x,some y => decide (Model.compare (model x) (model y)=some .gt)
def equalScore : Option Float32 → Option Float32 → Bool
  | none,none => true | some _,none => false | none,some _ => false
  | some x,some y => decide (Model.compare (model x) (model y)=some .eq)

def evaluate (env : Env) : Expr → Option Value
  | .variable name => env name
  | .gt a b => do
      match ←evaluate env a,←evaluate env b with
      | .score x,.score y => pure (.boolean (greater x y)) | _,_ => none
  | .eq a b => do
      match ←evaluate env a,←evaluate env b with
      | .score x,.score y => pure (.boolean (equalScore x y)) | _,_ => none
  | .lt a b => do
      match ←evaluate env a,←evaluate env b with
      | .uint x,.uint y => pure (.boolean (decide (x<y))) | _,_ => none
  | .land a b => do
      match ←evaluate env a,←evaluate env b with
      | .boolean x,.boolean y => pure (.boolean (x && y)) | _,_ => none
  | .lor a b => do
      match ←evaluate env a,←evaluate env b with
      | .boolean x,.boolean y => pure (.boolean (x || y)) | _,_ => none

def environment (x y : Candidate) : Env := fun name =>
  if name="x" then some (.score x.score) else if name="y" then some (.score y.score)
  else if name="xi" then some (.uint x.index) else if name="yi" then some (.uint y.index) else none

theorem comparator (x y : Candidate) :
    evaluate (environment x y) betterExpr=some (.boolean (better x y)) := by
  cases hx : x.score <;> cases hy : y.score <;>
    simp [evaluate,environment,betterExpr,greater,equalScore,better,hx,hy]

def selected (expr : Expr) (other current : Candidate) : Candidate :=
  match evaluate (environment other current) expr with
  | some (.boolean true) => other | _ => current

theorem selected_eq (other current : Candidate) : selected betterExpr other current=choose other current := by
  unfold selected
  rw [comparator]
  cases h : better other current <;> simp [choose,h]

-- The source reads every other lane from the pre-step SIMD image. Out-of-
-- range shuffle values are never observed because of the left guard.
def round (expr : Expr) (distance : Nat) (input : Fin n → Candidate) : Fin n → Candidate := fun lane =>
  if h : lane.val+distance<n then selected expr (input ⟨lane.val+distance,h⟩) (input lane) else input lane

theorem round_finite (input : Fin n → Candidate) (finite : ∀ i, Finite (input i)) (distance : Nat) :
    ∀ i, Finite (round betterExpr distance input i) := by
  intro i
  unfold round
  split
  · rw [selected_eq]
    exact choose_finite _ _ (finite _) (finite _)
  · exact finite _

theorem round_tree (input : Fin n → Candidate) (lanes : Fin n → Reduction.Tree n)
    (current : Fin n → Candidate) (finite : ∀ i, Finite (current i))
    (original : ∀ i, Finite (input i))
    (same : ∀ i, semantic (current i)=semantic (tree input (lanes i))) (distance : Nat) :
    ∀ i, semantic (round betterExpr distance current i)=semantic (tree input (shuffle distance lanes i)) := by
  intro i
  unfold round shuffle
  split
  · rw [selected_eq,choose_semantic _ _ (finite _) (finite _),same,same,tree,
      choose_semantic _ _ (tree_finite _ _ original) (tree_finite _ _ original)]
    exact Argmax.choose_comm _ _
  · exact same i

def rounds (expr : Expr) (distances : List Nat) (input : Fin n → Candidate) : Fin n → Candidate :=
  distances.foldl (fun current distance => round expr distance current) input

theorem rounds_tree (distances : List Nat) (input : Fin n → Candidate)
    (lanes : Fin n → Reduction.Tree n) (current : Fin n → Candidate)
    (finite : ∀ i, Finite (current i)) (original : ∀ i, Finite (input i))
    (same : ∀ i, semantic (current i)=semantic (tree input (lanes i))) :
    ∀ i, semantic (rounds betterExpr distances current i)=semantic
      (tree input ((distances.foldl (fun trees distance => shuffle distance trees) lanes) i)) := by
  induction distances generalizing current lanes with
  | nil => exact same
  | cons distance rest ih =>
    exact ih (shuffle distance lanes) (round betterExpr distance current)
      (round_finite current finite distance) (round_tree input lanes current finite original same distance)

def distances : Nat → BitVec 32 → Nat → List Nat
  | 0,_,_ => []
  | fuel+1,current,shift => if current=0 then [] else current.toNat::distances fuel (current >>> shift) shift

def runLoop (expr : Expr) (loop : Loop) (input : Fin loop.bound → Candidate) : Fin loop.bound → Candidate :=
  rounds expr (distances 32 (BitVec.ofNat 32 loop.start) loop.shift) input

theorem simd_distances : distances 32 (BitVec.ofNat 32 16) 1=[16,8,4,2,1] := by decide +kernel
theorem merge_distances : distances 32 (BitVec.ofNat 32 2) 1=[2,1] := by decide +kernel

theorem simd_guard_no_overflow (lane : Fin 32) (distance : Nat)
    (member : distance∈distances 32 (BitVec.ofNat 32 16) 1) : lane.val+distance<2^32 := by
  rw [simd_distances] at member
  simp only [List.mem_cons,List.not_mem_nil,or_false] at member
  rcases member with rfl|rfl|rfl|rfl|rfl <;> have := lane.isLt <;> omega

theorem merge_guard_no_overflow (lane : Fin 4) (distance : Nat)
    (member : distance∈distances 32 (BitVec.ofNat 32 2) 1) : lane.val+distance<2^32 := by
  rw [merge_distances] at member
  simp only [List.mem_cons,List.not_mem_nil,or_false] at member
  rcases member with rfl|rfl <;> have := lane.isLt <;> omega

theorem simd_semantic (input : Fin 32 → Candidate) (finite : ∀ i, Finite (input i)) :
    semantic (runLoop betterExpr ⟨16,1,32⟩ input 0)=semantic (tree input simdTree) := by
  unfold runLoop
  rw [simd_distances]
  exact rounds_tree _ input Reduction.Tree.leaf input finite finite (fun _ => rfl) 0

theorem merge_semantic (input : Fin 4 → Candidate) (finite : ∀ i, Finite (input i)) :
    semantic (runLoop betterExpr ⟨2,1,4⟩ input 0)=semantic (tree input mergeTree) := by
  unfold runLoop
  rw [merge_distances]
  exact rounds_tree _ input Reduction.Tree.leaf input finite finite (fun _ => rfl) 0

-- The shared parsed phase returns the same uint ID as the existing device
-- reduction spec, including signed-zero ties. No candidate-result equality
-- or selected winner is assumed; semantic equality proves the index.
theorem simd_index (input : Fin 128 → Candidate) (finite : ∀ i, Finite (input i)) (group : Fin 4) :
    (runLoop betterExpr ⟨16,1,32⟩ (fun lane => input (ArgmaxReductionDevice.thread group lane)) 0).index=
      (ArgmaxReductionDevice.simd input group).index :=
  congrArg Argmax.Candidate.index (simd_semantic _ (fun _lane => finite _))

theorem merge_index (input : Fin 4 → Candidate) (finite : ∀ i, Finite (input i)) :
    (runLoop betterExpr ⟨2,1,4⟩ input 0).index=(tree input mergeTree).index :=
  congrArg Argmax.Candidate.index (merge_semantic input finite)

def parsedRun (source : String) (input : Fin n → Candidate) (lane : Fin n) : Option Candidate := do
  let expr ← parseBetter betterBody
  let loop ← parseLoop source
  if h : loop.bound=n then
    some (runLoop expr loop (fun i => input ⟨i.val,by omega⟩) ⟨lane.val,by omega⟩)
  else none

theorem parsed_simd_index (input : Fin 128 → Candidate) (finite : ∀ i, Finite (input i)) (group : Fin 4) :
    (parsedRun simdLoop (fun lane => input (ArgmaxReductionDevice.thread group lane)) 0).map Candidate.index=
      some (ArgmaxReductionDevice.simd input group).index := by
  unfold parsedRun
  rw [parsed_better,parsed_simd]
  change some (runLoop betterExpr ⟨16,1,32⟩ (fun lane => input (ArgmaxReductionDevice.thread group lane)) 0).index=_
  exact congrArg some (simd_index input finite group)

theorem parsed_merge_index (input : Fin 4 → Candidate) (finite : ∀ i, Finite (input i)) :
    (parsedRun mergeLoop input 0).map Candidate.index=some (tree input mergeTree).index := by
  unfold parsedRun
  rw [parsed_better,parsed_merge]
  change some (runLoop betterExpr ⟨2,1,4⟩ input 0).index=_
  exact congrArg some (merge_index input finite)

theorem simd_dominates (input : Fin 32 → Candidate) (finite : ∀ i, Finite (input i)) (i : Fin 32) :
    Argmax.Dominates (semantic (runLoop betterExpr ⟨16,1,32⟩ input 0)) (semantic (input i)) := by
  rw [simd_semantic input finite]
  exact tree_correct input simdTree finite simd_coverage i

theorem merge_dominates (input : Fin 4 → Candidate) (finite : ∀ i, Finite (input i)) (i : Fin 4) :
    Argmax.Dominates (semantic (runLoop betterExpr ⟨2,1,4⟩ input 0)) (semantic (input i)) := by
  rw [merge_semantic input finite]
  exact tree_correct input mergeTree finite merge_coverage i

theorem merge_lowest_tie (input : Fin 4 → Candidate) (finite : ∀ i, Finite (input i)) (i : Fin 4)
    (tied : (semantic (runLoop betterExpr ⟨2,1,4⟩ input 0)).score=(semantic (input i)).score) :
    (runLoop betterExpr ⟨2,1,4⟩ input 0).index≤(input i).index :=
  (merge_dominates input finite i).2 tied

theorem parsed_scratch_merge (input : Fin 128 → Candidate)
    (trace : ArgmaxReductionDevice.Trace input) (valid : ∀ i, ArgmaxStorage.Valid (input i)) :
    (parsedRun mergeLoop trace.scratch.read 0).map Candidate.index=some trace.output.index := by
  apply parsed_merge_index
  intro group
  rw [trace.scratch.read_correct (ArgmaxReductionDevice.group_valid input valid)]
  exact (ArgmaxReductionDevice.group_valid input valid group).1

end Inference.Kernels.Sampling.ArgmaxShuffleSemantics
