import kernels.attention.MlxSdpaVectorSyntax
import kernels.attention.SdpaLayout

namespace Inference.Kernels.Attention.MlxSdpaVectorLoop
open Contracts.Mlx MlxSdpaVectorSyntax
open Normalization.MlxRmsLoopSyntax (acceptAll tokenize)
set_option maxRecDepth 10000

inductive Control where | strided deriving DecidableEq, Repr

def parseLoop (source : String) : Option Control := do
  let tokens ←tokenize source
  let rest ←acceptAll ["for","(","int","i","=","simd_gid",";","i","<","N",";","i","+=","BN",")","{","CELL",";","}"] tokens
  if rest=[] then some .strided else none

def sourceLoop : String := r#"for (int i = simd_gid; i < N; i += BN) { CELL; }"#
theorem parsed_loop : parseLoop sourceLoop=some .strided := by decide +kernel

def parseAdvances (source : String) : Option (List Pointer) := do
  let tokens ←MlxRopeSingleSyntax.tokenize source
  let (k,rest) ←pointer tokens
  let (v,rest) ←pointer rest
  if rest=[] then some [k,v] else none

def sourceAdvances : String := r#"keys += inner_k_stride;
    values += inner_v_stride;"#
def advances : List Pointer := [⟨"keys",.var "inner_k_stride"⟩,⟨"values",.var "inner_v_stride"⟩]
theorem parsed_advances : parseAdvances sourceAdvances=some advances := by decide +kernel

-- Selected constants BN=BD=32 and D=V=256. The signed int counter is
-- nonnegative and cannot overflow at supported lengths; no padding is read.
inductive Runs (bound : Nat) : Nat → List Nat → Prop where
  | done (start : Nat) (exit : bound≤start) : Runs bound start []
  | next (start : Nat) (inside : start<bound) : Runs bound (start+32) rest → Runs bound start (start::rest)

theorem run_count (bound start count : Nat)
    (inside : ∀ i<count, start+32*i<bound) (exit : bound≤start+32*count) :
    Runs bound start (List.ofFn (fun i : Fin count => start+32*i.val)) := by
  induction count generalizing start with
  | zero => simpa using Runs.done start exit
  | succ count ih =>
    rw [List.ofFn_succ]
    simp only [Fin.val_zero,Nat.mul_zero,Nat.add_zero,Fin.val_succ]
    have step := ih (start+32) (by intro i hi; have := inside (i+1) (by omega); omega) (by omega)
    have same : (fun i : Fin count => start+32*(i.val+1))=(fun i : Fin count => start+32+32*i.val) := by funext i; omega
    rw [same]
    exact .next start (by have := inside 0 (by omega); omega) step

theorem selected_visits (steps : Nat) (group : Fin 32) :
    Runs steps group.val ((SdpaLayout.keys steps group).map Fin.val) := by
  have same : (SdpaLayout.keys steps group).map Fin.val=
      List.ofFn (fun i : Fin (SdpaLayout.count steps group) => group.val+32*i.val) := by
    rw [SdpaLayout.keys,List.map_ofFn]
    rfl
  rw [same]
  apply run_count
  · intro i inside
    exact (SdpaLayout.key steps group ⟨i,inside⟩).isLt
  · exact SdpaLayout.first_outside steps group

theorem signed_counter (steps : Nat) (supported : steps≤262144) (group : Fin 32) :
    group.val+32*SdpaLayout.count steps group<2^31 := by
  have := group.isLt
  unfold SdpaLayout.count
  omega

end Inference.Kernels.Attention.MlxSdpaVectorLoop
