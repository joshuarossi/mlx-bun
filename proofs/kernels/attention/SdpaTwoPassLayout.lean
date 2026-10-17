import kernels.attention.SdpaLayout
import kernels.attention.SdpaScore
import contracts.mlx.SdpaTwoPassDispatch

namespace Inference.Kernels.Attention.SdpaTwoPassLayout

-- First pass: block b reads b, b+blocks, ... below the active key length.
-- Unlike the one-pass layout, the host-selected block count is variable.
def count (steps blocks : Nat) (block : Fin blocks) : Nat := (steps+blocks-1-block.val)/blocks

theorem numerator (steps blocks : Nat) (block : Fin blocks) :
    (steps+blocks-1-block.val)+block.val+1 = steps+blocks := by have := block.isLt; omega

theorem key_bound (steps blocks : Nat) (block : Fin blocks) (ordinal : Fin (count steps blocks block)) :
    block.val+blocks*ordinal.val < steps := by
  have positive : 0 < blocks := Nat.zero_lt_of_lt block.isLt
  have h := (Nat.le_div_iff_mul_le positive).mp ordinal.isLt
  have eq := numerator steps blocks block
  nlinarith

def key (steps blocks : Nat) (block : Fin blocks) (ordinal : Fin (count steps blocks block)) : Fin steps :=
  ⟨block.val+blocks*ordinal.val, key_bound steps blocks block ordinal⟩
def keys (steps blocks : Nat) (block : Fin blocks) : List (Fin steps) := List.ofFn (key steps blocks block)
def allKeys (steps blocks : Nat) : List (Fin steps) := (List.finRange blocks).flatMap (keys steps blocks)

theorem key_owner (steps blocks : Nat) (block : Fin blocks) (ordinal : Fin (count steps blocks block)) :
    (key steps blocks block ordinal).val % blocks = block.val ∧
      (key steps blocks block ordinal).val / blocks = ordinal.val := by
  have positive : 0 < blocks := Nat.zero_lt_of_lt block.isLt
  constructor
  · simp [key, Nat.add_mod, Nat.mod_eq_of_lt block.isLt]
  · change (block.val+blocks*ordinal.val)/blocks = ordinal.val
    rw [Nat.add_mul_div_left _ _ positive, Nat.div_eq_of_lt block.isLt, Nat.zero_add]

theorem first_outside (steps blocks : Nat) (block : Fin blocks) :
    steps ≤ block.val+blocks*count steps blocks block := by
  have positive : 0 < blocks := Nat.zero_lt_of_lt block.isLt
  have h := (Nat.div_lt_iff_lt_mul positive).mp (Nat.lt_succ_self (count steps blocks block))
  have eq := numerator steps blocks block
  nlinarith

theorem keys_mem (steps blocks : Nat) (block : Fin blocks) (i : Fin steps) :
    i ∈ keys steps blocks block ↔ i.val % blocks = block.val := by
  unfold keys
  rw [List.mem_ofFn]
  constructor
  · rintro ⟨j, rfl⟩
    exact (key_owner steps blocks block j).1
  · intro hi
    have positive : 0 < blocks := Nat.zero_lt_of_lt block.isLt
    have decompose := Nat.mod_add_div i.val blocks
    rw [hi] at decompose
    have eq := numerator steps blocks block
    have hj : i.val/blocks < count steps blocks block := by
      apply (Nat.le_div_iff_mul_le positive).mpr
      have := i.isLt
      nlinarith
    refine ⟨⟨i.val/blocks, hj⟩, ?_⟩
    apply Fin.ext
    exact decompose

theorem keys_nodup (steps blocks : Nat) (block : Fin blocks) : (keys steps blocks block).Nodup := by
  apply List.nodup_ofFn_ofInjective
  intro i j h
  apply Fin.ext
  have hi := (key_owner steps blocks block i).2
  have hj := (key_owner steps blocks block j).2
  rw [h] at hi
  exact hi.symm.trans hj

theorem keys_disjoint (steps blocks : Nat) (a b : Fin blocks) (different : a ≠ b) :
    (keys steps blocks a).Disjoint (keys steps blocks b) := by
  apply List.disjoint_left.mpr
  intro i ha hb
  exact different (Fin.ext (((keys_mem steps blocks a i).mp ha).symm.trans ((keys_mem steps blocks b i).mp hb)))

theorem coverage (steps blocks : Nat) (positive : 0 < blocks) :
    (allKeys steps blocks).Perm (List.finRange steps) := by
  have nodup : (allKeys steps blocks).Nodup := by
    apply List.nodup_flatMap.mpr
    exact ⟨fun b _ => keys_nodup steps blocks b,
      (List.nodup_finRange blocks).imp (fun {_ _} h => keys_disjoint steps blocks _ _ h)⟩
  apply (List.perm_ext_iff_of_nodup nodup (List.nodup_finRange steps)).mpr
  intro i
  refine ⟨fun _ => List.mem_finRange i, fun _ => ?_⟩
  apply List.mem_flatMap.mpr
  refine ⟨⟨i.val%blocks, Nat.mod_lt _ positive⟩, List.mem_finRange _, ?_⟩
  exact (keys_mem steps blocks _ i).mpr rfl

theorem length (steps blocks : Nat) (block : Fin blocks) :
    (keys steps blocks block).length = count steps blocks block := by simp only [keys, List.length_ofFn]

theorem count_bound (steps blocks : Nat) (supported : steps ≤ 262144) (minimum : 32 ≤ blocks) (block : Fin blocks) :
    count steps blocks block ≤ 8192 := by
  apply Nat.le_of_lt_succ
  apply (Nat.div_lt_iff_lt_mul (by omega : 0 < blocks)).mpr
  have eq := numerator steps blocks block
  nlinarith

-- Both passes use [query-head, block, coordinate] for BF16 partials and
-- [query-head, block] for float sums/maxima. Only writes are claimed unique;
-- source K/V reads are intentionally shared by six query heads.
def queryHead (kv : Fin 4) (gqa : Fin 6) : Fin 24 :=
  ⟨kv.val*6+gqa.val, by have := kv.isLt; have := gqa.isLt; omega⟩
theorem queryHead_inverse (kv : Fin 4) (gqa : Fin 6) :
    SdpaScore.kvHead (queryHead kv gqa) = kv ∧ (queryHead kv gqa).val%6 = gqa.val := by
  have := gqa.isLt
  constructor
  · apply Fin.ext
    dsimp [SdpaScore.kvHead, queryHead]
    omega
  · dsimp [queryHead]
    omega

def summaryAddress (blocks : Nat) (head : Fin 24) (block : Fin blocks) : Nat := head.val*blocks+block.val
def partialAddress (blocks : Nat) (head : Fin 24) (block : Fin blocks) (i : Fin 256) : Nat :=
  summaryAddress blocks head block*256+i.val

theorem summary_bounds (blocks : Nat) (head : Fin 24) (block : Fin blocks) : summaryAddress blocks head block < 24*blocks := by
  have := head.isLt
  have := block.isLt
  unfold summaryAddress
  nlinarith
theorem partial_bounds (blocks : Nat) (head : Fin 24) (block : Fin blocks) (i : Fin 256) :
    partialAddress blocks head block i < 24*blocks*256 := by
  have := summary_bounds blocks head block
  have := i.isLt
  unfold partialAddress
  omega

theorem summary_inverse (blocks : Nat) (head : Fin 24) (block : Fin blocks) :
    summaryAddress blocks head block / blocks = head.val ∧ summaryAddress blocks head block % blocks = block.val := by
  have positive : 0 < blocks := Nat.zero_lt_of_lt block.isLt
  constructor
  · change (head.val*blocks+block.val)/blocks = head.val
    rw [Nat.add_comm, Nat.mul_comm head.val blocks, Nat.add_mul_div_left _ _ positive,
      Nat.div_eq_of_lt block.isLt, Nat.zero_add]
  · simp [summaryAddress, Nat.mod_eq_of_lt block.isLt]

theorem partial_unique (blocks : Nat) (h h' : Fin 24) (b b' : Fin blocks) (i i' : Fin 256)
    (same : partialAddress blocks h b i = partialAddress blocks h' b' i') : h = h' ∧ b = b' ∧ i = i' := by
  have a := i.isLt
  have a' := i'.isLt
  have summaries : summaryAddress blocks h b = summaryAddress blocks h' b' := by
    unfold partialAddress at same
    omega
  have first := summary_inverse blocks h b
  have second := summary_inverse blocks h' b'
  rw [summaries] at first
  refine ⟨Fin.ext (first.1.symm.trans second.1), Fin.ext (first.2.symm.trans second.2), Fin.ext ?_⟩
  unfold partialAddress at same
  omega

end Inference.Kernels.Attention.SdpaTwoPassLayout
