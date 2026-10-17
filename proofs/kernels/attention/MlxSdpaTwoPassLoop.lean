import kernels.attention.MlxSdpaVectorDispatch

namespace Inference.Kernels.Attention.MlxSdpaTwoPassLoop
open Contracts.Mlx
open Normalization.MlxRmsLoopSyntax (acceptAll tokenize)
set_option maxRecDepth 10000

inductive Control where | blocks deriving DecidableEq, Repr

def parse (source : String) : Option Control := do
  let ts ←tokenize source
  let rest ←acceptAll ["for","(","int","i","=","block_idx",";","i","<","N",";","i","+=","blocks",")","{","CELL",";","}"] ts
  if rest=[] then some .blocks else none

def sourceBody : String := r#"for (int i = block_idx; i < N; i += blocks) { CELL; }"#
theorem parsed : parse sourceBody=some .blocks := by decide +kernel

inductive Runs (stride bound : Nat) : Nat → List Nat → Prop where
  | done (start : Nat) (exit : bound≤start) : Runs stride bound start []
  | next (start : Nat) (inside : start<bound) : Runs stride bound (start+stride) rest → Runs stride bound start (start::rest)

theorem run_count (stride bound start count : Nat)
    (inside : ∀ i<count, start+stride*i<bound) (exit : bound≤start+stride*count) :
    Runs stride bound start (List.ofFn (fun i : Fin count => start+stride*i.val)) := by
  induction count generalizing start with
  | zero => simpa using Runs.done start exit
  | succ count ih =>
    rw [List.ofFn_succ]
    simp only [Fin.val_zero,Nat.mul_zero,Nat.add_zero,Fin.val_succ]
    have step := ih (start+stride) (by
      intro i hi
      have h := inside (i+1) (by omega)
      simpa only [Nat.mul_add,Nat.mul_one,Nat.add_assoc,Nat.add_left_comm,Nat.add_comm] using h) (by
      simp only [Nat.mul_add,Nat.mul_one] at exit
      omega)
    have same : (fun i : Fin count => start+stride*(i.val+1))=(fun i : Fin count => start+stride+stride*i.val) := by
      funext i
      simp [Nat.mul_add,Nat.add_assoc,Nat.add_left_comm,Nat.add_comm]
    rw [same]
    exact .next start (by have := inside 0 (by omega); simpa using this) step

theorem selected_visits (steps blocks : Nat) (block : Fin blocks) :
    Runs blocks steps block.val ((SdpaTwoPassLayout.keys steps blocks block).map Fin.val) := by
  have same : (SdpaTwoPassLayout.keys steps blocks block).map Fin.val=
      List.ofFn (fun i : Fin (SdpaTwoPassLayout.count steps blocks block) => block.val+blocks*i.val) := by
    rw [SdpaTwoPassLayout.keys,List.map_ofFn]
    rfl
  rw [same]
  apply run_count
  · intro i inside
    exact SdpaTwoPassLayout.key_bound steps blocks block ⟨i,inside⟩
  · exact SdpaTwoPassLayout.first_outside steps blocks block

theorem signed_counter (steps blocks : Nat) (supported : steps≤262144) (blockBound : blocks≤1024)
    (block : Fin blocks) : block.val+blocks*SdpaTwoPassLayout.count steps blocks block<2^31 := by
  have h := Nat.div_mul_le_self (steps+blocks-1-block.val) blocks
  change SdpaTwoPassLayout.count steps blocks block*blocks≤steps+blocks-1-block.val at h
  have eq := SdpaTwoPassLayout.numerator steps blocks block
  nlinarith

end Inference.Kernels.Attention.MlxSdpaTwoPassLoop
