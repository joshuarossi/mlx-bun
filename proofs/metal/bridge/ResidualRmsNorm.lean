import metal.bridge.GatedRmsNorm
import metal.kernels.ResidualRmsNorm
import kernels.ResidualRmsNorm
import kernels.normalization.ResidualRmsLoopControl
import models.qwen.Blocks

namespace Metal.Bridge.ResidualRmsNorm
open Metal Metal.Core Inference.Contracts.Mlx Inference.Contracts.Mlx.Numerics
open FloatLib FloatLib.Floats FloatLib.Floats.Formats.BinaryInterchange

variable (C : M1Max.Contract)
set_option maxRecDepth 20000

/-- One `acc += v * v` of the core at its contraction choice. -/
def mstep (fuse : Bool) (acc v : Float32) : Float32 := if fuse then C.fma v v acc else C.fadd acc (C.fmul v v)

/-- The core's accumulation over a column list, with `v` the value of each column. -/
def mfold {n : Nat} (fuse : Bool) (v : Fin n → Float32) (cols : List (Fin n)) (acc : Float32) : Float32 :=
  cols.foldl (fun a i => mstep C fuse a (v i)) acc

/-- Thread `t`'s `acc` is the core's accumulation over the model's column schedule `threadColumns`
(`ResidualRmsLoopControl.threadColumns_two`: iterations 0 and 1 of the strided loop). -/
theorem accR_fold (fuse : Bool) (X U : ByteMemory.Bytes) (t : Nat) (ht : t < 1024) :
    Kernels.ResidualRmsNorm.accR C fuse X U t 8 =
      mfold C fuse (fun i => C.widen (Kernels.ResidualRmsNorm.resv C X U i.val))
        (NormalizationSchedule.threadColumns Inference.Kernels.Normalization.ResidualRmsLoopControl.count
          (⟨t, ht⟩ : Fin 1024)) Kernels.ResidualRmsNorm.zero := by
  have h2 : NormalizationSchedule.threadColumns Inference.Kernels.Normalization.ResidualRmsLoopControl.count
      (⟨t, ht⟩ : Fin 1024) =
      Inference.Kernels.Normalization.ResidualRmsLoopControl.visits 0 ⟨t, ht⟩ ++
        Inference.Kernels.Normalization.ResidualRmsLoopControl.visits 1 ⟨t, ht⟩ :=
    Inference.Kernels.Normalization.ResidualRmsLoopControl.threadColumns_two ⟨t, ht⟩
  have four : List.finRange 4 = ([0, 1, 2, 3] : List (Fin 4)) := by decide
  rw [h2]
  unfold Inference.Kernels.Normalization.ResidualRmsLoopControl.visits
  rw [four]
  have cnt : Inference.Kernels.Normalization.ResidualRmsLoopControl.count = 5120 := rfl
  by_cases hs : t < 256
  · have l0 : t * 4 < Inference.Kernels.Normalization.ResidualRmsLoopControl.count := by rw [cnt]; omega
    have l1 : t * 4 + 1 < Inference.Kernels.Normalization.ResidualRmsLoopControl.count := by rw [cnt]; omega
    have l2 : t * 4 + 2 < Inference.Kernels.Normalization.ResidualRmsLoopControl.count := by rw [cnt]; omega
    have l3 : t * 4 + 3 < Inference.Kernels.Normalization.ResidualRmsLoopControl.count := by rw [cnt]; omega
    have l4 : 4096 + t * 4 < Inference.Kernels.Normalization.ResidualRmsLoopControl.count := by rw [cnt]; omega
    have l5 : 4096 + t * 4 + 1 < Inference.Kernels.Normalization.ResidualRmsLoopControl.count := by rw [cnt]; omega
    have l6 : 4096 + t * 4 + 2 < Inference.Kernels.Normalization.ResidualRmsLoopControl.count := by rw [cnt]; omega
    have l7 : 4096 + t * 4 + 3 < Inference.Kernels.Normalization.ResidualRmsLoopControl.count := by rw [cnt]; omega
    cases fuse <;> simp [NormalizationSchedule.columnIndex, NormalizationSchedule.address, mfold, mstep,
      Kernels.ResidualRmsNorm.accR, List.foldl_cons, List.foldl_nil, Kernels.ResidualRmsNorm.colOf,
      l0, l1, l2, l3, l4, l5, l6, l7, show t * 4 < 5120 by omega, show t * 4 + 1 < 5120 by omega,
      show t * 4 + 2 < 5120 by omega, show t * 4 + 3 < 5120 by omega, show 4096 + t * 4 < 5120 by omega,
      show 4096 + t * 4 + 1 < 5120 by omega, show 4096 + t * 4 + 2 < 5120 by omega, show 4096 + t * 4 + 3 < 5120 by omega]
  · have l0 : t * 4 < Inference.Kernels.Normalization.ResidualRmsLoopControl.count := by rw [cnt]; omega
    have l1 : t * 4 + 1 < Inference.Kernels.Normalization.ResidualRmsLoopControl.count := by rw [cnt]; omega
    have l2 : t * 4 + 2 < Inference.Kernels.Normalization.ResidualRmsLoopControl.count := by rw [cnt]; omega
    have l3 : t * 4 + 3 < Inference.Kernels.Normalization.ResidualRmsLoopControl.count := by rw [cnt]; omega
    have l4 : ¬ 4096 + t * 4 < Inference.Kernels.Normalization.ResidualRmsLoopControl.count := by rw [cnt]; omega
    have l5 : ¬ 4096 + t * 4 + 1 < Inference.Kernels.Normalization.ResidualRmsLoopControl.count := by rw [cnt]; omega
    have l6 : ¬ 4096 + t * 4 + 2 < Inference.Kernels.Normalization.ResidualRmsLoopControl.count := by rw [cnt]; omega
    have l7 : ¬ 4096 + t * 4 + 3 < Inference.Kernels.Normalization.ResidualRmsLoopControl.count := by rw [cnt]; omega
    cases fuse <;> simp [NormalizationSchedule.columnIndex, NormalizationSchedule.address, mfold, mstep,
      Kernels.ResidualRmsNorm.accR, List.foldl_cons, List.foldl_nil, Kernels.ResidualRmsNorm.colOf,
      l0, l1, l2, l3, l4, l5, l6, l7, show t * 4 < 5120 by omega, show t * 4 + 1 < 5120 by omega,
      show t * 4 + 2 < 5120 by omega, show t * 4 + 3 < 5120 by omega, show ¬ 4096 + t * 4 < 5120 by omega,
      show ¬ 4096 + t * 4 + 1 < 5120 by omega, show ¬ 4096 + t * 4 + 2 < 5120 by omega,
      show ¬ 4096 + t * 4 + 3 < 5120 by omega]

theorem finite_of_accumulate {n : Nat} {c : Bool} {input : Fin n → Float32} :
    ∀ (cols : List (Fin n)) (e : SquaredSum.Expr n), SquaredSum.Finite input (SquaredSum.accumulate c cols e) →
      SquaredSum.Finite input e
  | [], _, h => h
  | i :: rest, e, h => finite_of_step (finite_of_accumulate rest (SquaredSum.step c e i) h)

/-- The core's fold over a column list whose values are the model's inputs is the model's accumulation, when
the model's expression is finite. -/
theorem mfold_eq {n : Nat} (c : Bool) (input v : Fin n → Float32) :
    ∀ (cols : List (Fin n)) (e : SquaredSum.Expr n) (acc : Float32), (∀ i ∈ cols, v i = input i) →
      acc = SquaredSum.evaluate input e → SquaredSum.Finite input (SquaredSum.accumulate c cols e) →
      mfold C c v cols acc = SquaredSum.evaluate input (SquaredSum.accumulate c cols e)
  | [], _, _, _, ha, _ => ha
  | i :: rest, e, acc, hv, ha, hf => by
    have hf' : SquaredSum.Finite input (SquaredSum.step c e i) := finite_of_accumulate rest _ hf
    exact mfold_eq c input v rest (SquaredSum.step c e i) (mstep C c acc (v i))
      (fun j hj => hv j (List.mem_cons_of_mem _ hj)) (step_eq C c input e i (v i) acc (hv i List.mem_cons_self) ha hf') hf

/-- The machine's 32-wide RMS platform at contraction choice `c` (`KernelContract.residual`). -/
noncomputable abbrev P (c : Bool) : RmsNorm.Platform := C.rmsPlatform 32 (by decide) (by decide) c

theorem w_eq : Val.ofF32Bits 0x45A00000 = Inference.Models.Qwen.Blocks.width := by decide
theorem eps_eq : Val.ofF32Bits 0x358637BD = Inference.Models.Qwen.Blocks.eps := by decide

section Rows
variable (c : Bool) (X U W : ByteMemory.Bytes) (x u w : Fin 5120 → BF)

/-- The model's normalization input: the widened bf16 residual. -/
abbrev input : Fin 5120 → Float32 := Inference.Kernels.ResidualRmsNorm.residualInput x u

theorem input_finite (hf : SquaredSum.Finite (input x u) (RmsNorm.expression (P C c) 5120)) (i : Fin 5120) :
    (input x u i).isFinite = true :=
  finite_of_mem _ _ hf i ((RmsNorm.coverage (P C c) 5120).mem_iff.mpr (List.mem_finRange i))

/-- Each thread's expression is finite when the row's is. -/
theorem thread_finite (hf : SquaredSum.Finite (input x u) (RmsNorm.expression (P C c) 5120)) (g l : Fin 32) :
    SquaredSum.Finite (input x u) (NormalizationSchedule.threadExpr c 5120 (NormalizationReduction.laneIndex g l)) := by
  have hf0 : SquaredSum.Finite (input x u) (SquaredSum.reduceTree (NormalizationReduction.scratchExpr c 32 5120
      C.simdSum_tree.tree) C.simdSum_tree.tree) := hf
  have hg := finite_of_leaf (input x u) (NormalizationReduction.scratchExpr c 32 5120 C.simdSum_tree.tree)
    C.simdSum_tree.tree hf0 g (C.simdSum_tree.coverage.mem_iff.mpr (List.mem_finRange g))
  unfold NormalizationReduction.scratchExpr at hg
  rw [dite_eq_left g.isLt] at hg
  have hg1 : SquaredSum.Finite (input x u) (SquaredSum.reduceTree
      (fun lane => NormalizationSchedule.threadExpr c 5120 (NormalizationReduction.laneIndex (⟨g.val, g.isLt⟩ : Fin 32) lane))
      C.simdSum_tree.tree) := hg
  exact finite_of_leaf (input x u)
    (fun lane => NormalizationSchedule.threadExpr c 5120 (NormalizationReduction.laneIndex (⟨g.val, g.isLt⟩ : Fin 32) lane))
    C.simdSum_tree.tree hg1 l (C.simdSum_tree.coverage.mem_iff.mpr (List.mem_finRange l))

variable (hres : ∀ i : Fin 5120, Kernels.ResidualRmsNorm.resv C X U i.val = Inference.Kernels.ResidualRmsNorm.residual (x i) (u i))
include hres

/-- Thread `32 g + l`'s `acc` is its model expression's value. -/
theorem accR_eq (hf : SquaredSum.Finite (input x u) (RmsNorm.expression (P C c) 5120)) (g l : Fin 32) :
    Kernels.ResidualRmsNorm.accR C c X U (32 * g.val + l.val) 8 =
      SquaredSum.evaluate (input x u) (NormalizationSchedule.threadExpr c 5120 (NormalizationReduction.laneIndex g l)) := by
  have ht : 32 * g.val + l.val < 1024 := by omega
  have hl : (⟨32 * g.val + l.val, ht⟩ : Fin 1024) = NormalizationReduction.laneIndex g l := by
    apply Fin.ext; simp only [NormalizationReduction.laneIndex]; ring
  rw [accR_fold C c X U _ ht, hl]
  have htf : SquaredSum.Finite (input x u) (SquaredSum.accumulate c
      (NormalizationSchedule.threadColumns 5120 (NormalizationReduction.laneIndex g l)) .zero) := thread_finite C c x u hf g l
  have hv : ∀ i ∈ NormalizationSchedule.threadColumns 5120 (NormalizationReduction.laneIndex g l),
      C.widen (Kernels.ResidualRmsNorm.resv C X U i.val) = input x u i := by
    intro i _
    have hi := input_finite C c x u hf i
    rw [hres i, C.widen_model _ (General.finite_of_widen _ hi)]
    rfl
  exact mfold_eq C c (input x u) (fun i => C.widen (Kernels.ResidualRmsNorm.resv C X U i.val))
    (NormalizationSchedule.threadColumns 5120 (NormalizationReduction.laneIndex g l)) .zero _ hv
    Metal.Bridge.GatedRmsNorm.zero_eq htf

/-- The row's two-level `simd_sum` is the model's squared sum. -/
theorem total_eq (hf : SquaredSum.Finite (input x u) (RmsNorm.expression (P C c) 5120)) :
    Kernels.ResidualRmsNorm.total C c X U = SquaredSum.evaluate (input x u) (RmsNorm.expression (P C c) 5120) := by
  change _ = SquaredSum.evaluate (input x u) (NormalizationReduction.expression c 32 5120 C.simdSum_tree.tree
    C.simdSum_tree.tree)
  rw [← NormalizationReduction.sourceSum_correct C.simdSum C.simdSum_tree c (input x u) (fun _ => 0) 0 32]
  unfold Kernels.ResidualRmsNorm.total NormalizationReduction.sourceSum
  congr 1
  funext g
  rw [NormalizationReduction.shared_read _ _ _ _ _ (List.Perm.refl _) (List.Perm.refl _),
    dite_eq_left g.isLt]
  unfold Kernels.ResidualRmsNorm.simdS NormalizationReduction.groupSum
  congr 1
  funext l
  rw [NormalizationReduction.threadSum_correct, accR_eq C c X U x u hres hf g l]

/-- `inv[0] = rsqrt(acc / float(D) + eps)` is the model's inverse, for every scratch the model names. -/
theorem invR_eq (hn : Inference.Kernels.ResidualRmsNorm.NormFinite (P C c) x u w Inference.Models.Qwen.Blocks.width
      Inference.Models.Qwen.Blocks.eps) (scratch : M1Max.WordMemory) (base : Nat) :
    Kernels.ResidualRmsNorm.invR C c X U =
      RmsNorm.inverse (P C c) (input x u) Inference.Models.Qwen.Blocks.width Inference.Models.Qwen.Blocks.eps scratch base := by
  have hf : NormalizationExecution.Finite C.fdiv (input x u) w (RmsNorm.expression (P C c) 5120)
      Inference.Models.Qwen.Blocks.width Inference.Models.Qwen.Blocks.eps C.rsqrt := hn
  rw [RmsNorm.inverse_correct]
  unfold Kernels.ResidualRmsNorm.invR NormalizationExecution.normalizer NormalizationExecution.denominator
    NormalizationExecution.mean NormalizationExecution.sum
  rw [total_eq C c X U x u hres hf.hSum, w_eq, eps_eq]
  have hm : (C.fdiv (SquaredSum.evaluate (input x u) (RmsNorm.expression (P C c) 5120))
      Inference.Models.Qwen.Blocks.width).isFinite = true := hf.hMean
  rw [C.fadd_model _ _ hm hf.hEps]
  rfl

/-- `normalized[e] = weight[e] * T(float(residual[e]) * inv[0])` is the model's normalized coordinate. -/
theorem normR_eq (hW : ∀ i : Fin 5120, bfAt W i.val = w i)
    (hn : Inference.Kernels.ResidualRmsNorm.NormFinite (P C c) x u w Inference.Models.Qwen.Blocks.width
      Inference.Models.Qwen.Blocks.eps) (scratch : M1Max.WordMemory) (base : Nat) (i : Fin 5120) :
    Kernels.ResidualRmsNorm.normR C c X U W i.val =
      Inference.Kernels.ResidualRmsNorm.normalized (P C c) x u w Inference.Models.Qwen.Blocks.width
        Inference.Models.Qwen.Blocks.eps scratch base i := by
  have hf : NormalizationExecution.Finite C.fdiv (input x u) w (RmsNorm.expression (P C c) 5120)
      Inference.Models.Qwen.Blocks.width Inference.Models.Qwen.Blocks.eps C.rsqrt := hn
  have hi := input_finite C c x u hf.hSum i
  unfold Kernels.ResidualRmsNorm.normR Inference.Kernels.ResidualRmsNorm.normalized RmsNorm.value
  rw [invR_eq C c X U x u w hres hn scratch base, RmsNorm.inverse_correct, hres i, hW i,
    C.widen_model _ (General.finite_of_widen _ hi)]
  change C.bfmul (w i) (C.narrow (C.fmul (input x u i) _)) = _
  have hN : (NormalizationExecution.normalizer (P C c).divide (input x u) (RmsNorm.expression (P C c) 5120)
      Inference.Models.Qwen.Blocks.width Inference.Models.Qwen.Blocks.eps (P C c).rsqrt).isFinite = true := hf.hNormalizer
  rw [C.fmul_model _ _ hi hN]
  have hm : (FlushToZero.mul (input x u i) (NormalizationExecution.normalizer (P C c).divide (input x u)
      (RmsNorm.expression (P C c) 5120) Inference.Models.Qwen.Blocks.width Inference.Models.Qwen.Blocks.eps
      (P C c).rsqrt)).isFinite = true := FlushToZero.mul_finite _ _ (hf.hNormalized i)
  rw [C.narrow_model _ hm]
  have hb : Model.isFinite (BFloat16.narrow (FlushToZero.mul (input x u i) (NormalizationExecution.normalizer
      (P C c).divide (input x u) (RmsNorm.expression (P C c) 5120) Inference.Models.Qwen.Blocks.width
      Inference.Models.Qwen.Blocks.eps (P C c).rsqrt))) = true := hf.hNarrow i
  rw [C.bfmul_model _ _ (hf.hWeight i) hb]

end Rows

/-- The machine's `value = T(float(x) + float(update))`: InstCombine narrows it to one bf16 addition
(`C.bfadd`, i.e. `BFloat16Arithmetic.add`: flushed operands, one rounding to bf16, flushed result), where the
model rounds twice (`BFloat16.narrow (FlushToZero.add (widen x) (widen update))`). The two agree on finite
operands (innocuous double rounding: binary32 has 24 ≥ 2·8 + 2 bits, and both formats flush below 2^-126);
this is that IEEE fact, stated for the operands `AddFinite` admits. It mentions no machine operation and the
library does not prove it. -/
def SingleRounding : Prop :=
  ∀ x update : BF, Inference.Kernels.ResidualRmsNorm.AddFinite x update →
    BFloat16Arithmetic.add x update = Inference.Kernels.ResidualRmsNorm.residual x update

theorem resv_eq (X U : ByteMemory.Bytes) (x u : Fin 5120 → BF)
    (hX : ∀ i : Fin 5120, bfAt X i.val = x i) (hU : ∀ i : Fin 5120, bfAt U i.val = u i)
    (hA : ∀ i, Inference.Kernels.ResidualRmsNorm.AddFinite (x i) (u i)) (hs : SingleRounding) (i : Fin 5120) :
    Kernels.ResidualRmsNorm.resv C X U i.val = Inference.Kernels.ResidualRmsNorm.residual (x i) (u i) := by
  unfold Kernels.ResidualRmsNorm.resv
  rw [hX i, hU i, C.bfadd_model _ _ (hA i).input (hA i).updateFinite]
  exact hs _ _ (hA i)

/-- A bf16 [1, 1, 5120] output whose element `e` is `f e`, read as the host's array. -/
theorem bytes_flat (B : ByteMemory.Bytes) (g : Nat → BF) (f : Fin 5120 → BF) (hg : ∀ i : Fin 5120, g i.val = f i)
    (hB : ∀ b, b < 10240 → B b = (wordBytes 2 (Val.bf16Bits (g (b / 2)))).getD (b % 2) 0) :
    Host.Mlx.Flat (Host.Mlx.halfArray B 0 [1,1,5120]) [1,1,5120] f := by
  refine ⟨rfl, rfl, fun j => ?_⟩
  rw [halfArray_read]
  apply bfAt_of
  intro k hk
  have hj := j.isLt
  rw [hB _ (by omega), show (2 * j.val + k) / 2 = j.val by omega, show (2 * j.val + k) % 2 = k by omega, hg]

section Outputs
variable {X U W : ByteMemory.Bytes} {x u w : Fin 5120 → BF}

/-- **Byte bridges.** The machine spec's `residual` buffer is the model's `residual`, and its `normalized`
buffer, with the compiler's site-1 choice the model's flag, is the model's `normalized` (for every scratch
the model names), read as the host's bf16 arrays in the `Row` form `GlueKernels.residual_rms_norm` concludes. -/
theorem expected_rows (fuse : Nat → Bool) (contracted : Bool) (hc : fuse 1 = contracted)
    (hX : ∀ i : Fin 5120, bfAt X i.val = x i) (hU : ∀ i : Fin 5120, bfAt U i.val = u i)
    (hW : ∀ i : Fin 5120, bfAt W i.val = w i)
    (hA : ∀ i, Inference.Kernels.ResidualRmsNorm.AddFinite (x i) (u i)) (hs : SingleRounding)
    (hn : Inference.Kernels.ResidualRmsNorm.NormFinite (P C contracted) x u w Inference.Models.Qwen.Blocks.width
      Inference.Models.Qwen.Blocks.eps) :
    Host.Mlx.Row (Host.Mlx.halfArray (Kernels.ResidualRmsNorm.expectedResidual C X U) 0 [1,1,5120]) 5120
        (fun i => Inference.Kernels.ResidualRmsNorm.residual (x i) (u i)) ∧
      ∀ scratch base, Host.Mlx.Row (Host.Mlx.halfArray (Kernels.ResidualRmsNorm.expectedNormalized C fuse X U W) 0
        [1,1,5120]) 5120 (Inference.Kernels.ResidualRmsNorm.normalized (P C contracted) x u w
          Inference.Models.Qwen.Blocks.width Inference.Models.Qwen.Blocks.eps scratch base) := by
  have hres := resv_eq C X U x u hX hU hA hs
  refine ⟨(bytes_flat _ _ _ hres fun b hb => by
    unfold Kernels.ResidualRmsNorm.expectedResidual; rw [ite_eq_left hb]).row, fun scratch base => ?_⟩
  subst hc
  exact (bytes_flat _ _ _ (normR_eq C (fuse 1) X U W x u w hres hW hn scratch base) fun b hb => by
    unfold Kernels.ResidualRmsNorm.expectedNormalized; rw [ite_eq_left hb]).row

end Outputs

/-- **End to end.** MLX's launch on the row-major storage of the `Row`/`Vector` inputs of
`GlueKernels.residual_rms_norm` returns buffers that, as the host's bf16 arrays, are the model's
`residual` and `normalized (C.rmsPlatform 32 _ _ contracted)`, when the compiler's site-1 choice is the
model's flag and the bf16 addition is the model's double-rounded one (`SingleRounding`). -/
theorem gpu_value (G : Gpu C) (hmax : 1024 ≤ G.maxThreads Metal.Elab.Tests.residualRmsNormText)
    (xv uv wv : Host.Mlx.Value) (left right weight : Fin 5120 → BF)
    (hxv : Host.Mlx.Row xv 5120 left) (huv : Host.Mlx.Row uv 5120 right) (hwv : Host.Mlx.GlueAttention.Vector wv 5120 weight)
    (ax au aw : Nat) (hax : 2 ∣ ax) (hau : 2 ∣ au) (haw : 2 ∣ aw)
    (contracted : Bool) (hc : G.fusion Metal.Elab.Tests.residualRmsNormText 1 = contracted)
    (hA : ∀ i, Inference.Kernels.ResidualRmsNorm.AddFinite (left i) (right i))
    (hs : SingleRounding)
    (hn : Inference.Kernels.ResidualRmsNorm.NormFinite (P C contracted) left right weight Inference.Models.Qwen.Blocks.width
      Inference.Models.Qwen.Blocks.eps) :
    ∃ h n, G.execute Metal.Elab.Tests.residualRmsNormText (1024, 1, 1) (1024, 1, 1)
        [⟨.device, 10240, ax, xv.storageByte⟩, ⟨.device, 10240, au, uv.storageByte⟩, ⟨.device, 10240, aw, wv.storageByte⟩]
        [10240, 10240] = some [h, n] ∧
      Host.Mlx.Row (Host.Mlx.halfArray h 0 [1,1,5120]) 5120 (fun i => Inference.Kernels.ResidualRmsNorm.residual (left i) (right i)) ∧
      ∀ scratch base, Host.Mlx.Row (Host.Mlx.halfArray n 0 [1,1,5120]) 5120
        (Inference.Kernels.ResidualRmsNorm.normalized (P C contracted) left right weight Inference.Models.Qwen.Blocks.width
          Inference.Models.Qwen.Blocks.eps scratch base) := by
  refine ⟨_, _, Kernels.ResidualRmsNorm.gpu_output C G hmax _ _ _ ax au aw hax hau haw, ?_⟩
  exact expected_rows C _ contracted hc (fun i => by rw [bfAt_storage _ hxv.1]; exact Host.Mlx.Row.elems hxv i)
    (fun i => by rw [bfAt_storage _ huv.1]; exact Host.Mlx.Row.elems huv i)
    (fun i => by rw [bfAt_storage _ hwv.1]; exact hwv.2.2 i) hA hs hn

end Metal.Bridge.ResidualRmsNorm
