import kernels.quantization.MlxQmv

namespace Inference.Kernels.Quantization.MlxQmvHostSource

-- Reviewed translation of pinned quantized.cpp, not a C++ frontend proof.
-- Native descriptors, architecture reporting and wrapped kernel installation
-- remain explicit boundaries. Specialization: affine, transposed, M=B=1,
-- four-bit, group-size 64, no global scale, and positive integral dimensions.
def batchLimit (generation : Nat) (size : Char) (k n : Nat) : Nat :=
  if generation≥17 ∧ size != 'd' then
    if k≤2048 ∧ n≤2048 then 33 else if k≤4096 ∧ n≤4096 then 25 else 13
  else if generation≥15 ∧ size != 'd' then
    if k≤2048 ∧ n≤2048 then 13 else if k≤4096 ∧ n≤4096 then 15 else 13
  else if generation≥13 then
    if size=='d' then
      if k≤2048 ∧ n≤2048 then 32 else if k≤4096 ∧ n≤4096 then 18 else 12
    else if k≤2048 ∧ n≤2048 then 14 else if k≤4096 ∧ n≤4096 then 10 else 6
  else if size=='d' then
    if k≤2048 ∧ n≤2048 then 32 else if k≤4096 ∧ n≤4096 then 18 else 12
  else if k≤2048 ∧ n≤2048 then 18 else if k≤4096 ∧ n≤4096 then 12 else 10

theorem batch_limit_gt_one (generation : Nat) (size : Char) (k n : Nat) :
    1 < batchLimit generation size k n := by
  unfold batchLimit
  split <;> repeat' first | split | omega

structure Launch where
  gridX : Nat
  gridY : Nat
  gridZ : Nat
  groupX : Nat
  groupY : Nat
  groupZ : Nat
  deriving DecidableEq, Repr

-- Dispatch predicates follow eval_gpu, dispatch_qmv, then qmv in that order.
def selected (generation : Nat) (size : Char) (k n : Nat) : Bool :=
  decide (1 < batchLimit generation size k n) &&
  !(k==128 || k==64) && !(1≥2) && n%8==0 && k%512==0

def launch (n : Nat) : Launch := ⟨1,(n+7)/8,1,32,2,1⟩

theorem selected_blocks (generation : Nat) (size : Char) (steps blocks : Nat) :
    selected generation size (steps*512) (blocks*8)=true := by
  have limit := batch_limit_gt_one generation size (steps*512) (blocks*8)
  simp [selected,limit]
  omega

theorem launch_blocks (blocks : Nat) : launch (blocks*8)=⟨1,blocks,1,32,2,1⟩ := by
  have quotient : (blocks*8+7)/8=blocks := by omega
  simp [launch,quotient]

def group (block : Fin blocks) (simd : Fin 2) : Fin (blocks*2) :=
  ⟨block.val*2+simd.val,by have := block.isLt; have := simd.isLt; omega⟩

theorem complete_group (i : Fin (blocks*2)) :
    ∃ block : Fin blocks, ∃ simd : Fin 2, group block simd=i := by
  refine ⟨⟨i.val/2,by have := i.isLt; omega⟩,⟨i.val%2,by omega⟩,?_⟩
  apply Fin.ext
  dsimp [group]
  omega

theorem unique_group (a b : Fin blocks) (s t : Fin 2) (same : group a s=group b t) :
    a=b ∧ s=t := by
  have equal := congrArg Fin.val same
  have := s.isLt; have := t.isLt
  dsimp [group] at equal
  constructor <;> apply Fin.ext <;> omega

theorem complete_rows (i : Fin (blocks*8)) :
    ∃ block : Fin blocks, ∃ simd : Fin 2, ∃ row : Fin 4,
      (group block simd).val*4+row.val=i.val := by
  obtain ⟨block,simd,row,equal⟩ := MlxQmv.output_owner i
  refine ⟨block,simd,row,?_⟩
  have value := congrArg Fin.val equal
  dsimp [group,MlxQmv.outputIndex] at *
  omega

theorem delta48_selected (generation : Nat) (size : Char) :
    selected generation size 5120 48=true ∧ launch 48=⟨1,6,1,32,2,1⟩ := by
  exact ⟨selected_blocks generation size 10 6,by decide⟩

end Inference.Kernels.Quantization.MlxQmvHostSource
