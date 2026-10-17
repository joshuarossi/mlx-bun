import host.mlx.GlueAttention
import models.qwen.HeadScaleConstruction
import FloatLib.Floats.Formats.BinaryInterchange.Arithmetic.Proof

namespace Host.Mlx.GlueRoute
open Inference Inference.Models.Qwen Inference.Kernels Inference.Contracts.Mlx Inference.Layers.AffineVerifyLinear
open FloatLib FloatLib.Floats FloatLib.Floats.Formats.BinaryInterchange

variable {C : M1Max.Contract} (M : MlxContract C)

/-! ## Gap 5: compiled closures

closureApply evaluates the closure's fused semantics. For compute_g that is
ComputeGHostSource (the parsed compute_g body with bf16 × f32 → f32 and the
compiled LogAddExp policy); under the legacy policy it is Decay.value. -/

def F32Row (v : Value) (n : Nat) (f : Fin n → Float32) : Prop :=
  v.dtype = .float32 ∧ v.shape = [1,1,n] ∧ ∀ i : Fin n, f32 (v.elems i.val) = f i

theorem computeG_closure (aLog a dt : Value) (al av dv : Fin 48 → BF)
    (hl : GlueAttention.Vector aLog 48 al) (ha : Row a 48 av) (hd : GlueAttention.Vector dt 48 dv)
    (policy : M.logAddExp = Delta.MlxLogAddExpSource.legacyPolicy)
    (finite : ∀ h, Model.isFinite (Delta.Decay.biased (av h) (dv h)) = true) :
    ∃ g, closureApply M .computeG [aLog, a, dt] = some [g] ∧
      F32Row g 48 (fun h => Delta.Decay.value M.decay (BFloat16.widen (al h)) (av h) (dv h)) := by
  have op : closureApply M .computeG [aLog, a, dt] = some [computeGValue M aLog a dt] := by
    simp only [closureApply, Closure.eval]
    rw [ite_eq_left ⟨hl.1, ha.1, hd.1, ha.2.1⟩]
  refine ⟨_, op, rfl, rfl, fun h => ?_⟩
  · unfold computeGValue
    dsimp only
    rw [hl.2.2 h, Row.elems ha h, hd.2.2 h, policy, Delta.ComputeGHostSource.execution _ _ _ _ (finite h)]
    exact f32_word _

/-! ## Gap 6: projection route and LoRA

Each projection runs our affine_row kernel (Projection3/4.forward) or MLX
qmv (Projection4.plainForward, via quantizedMatmul). qmv is issued only for
4-bit weights. Either way the value is Projection.forward. -/

inductive Kernel where
  | affineRow | qmv

def Issued : Kernel → Projection steps rows → Prop
  | .affineRow, _ => True
  | .qmv, .bits4 _ => True
  | .qmv, .bits3 _ => False

def executed : Kernel → Projection steps rows → (Fin (steps * 512) → BF) → Fin rows → BF
  | .affineRow, .bits3 p => p.forward
  | .affineRow, .bits4 p => p.forward
  | .qmv, .bits3 p => p.forward
  | .qmv, .bits4 p => p.plainForward

theorem executed_eq (k : Kernel) (p : Projection steps rows) (x : Fin (steps * 512) → BF) (h : Issued k p) :
    executed k p x = p.forward x := by
  cases k <;> cases p
  · rfl
  · rfl
  · exact h.elim
  · exact Projection4.plain_eq _ x

-- layers/lora.ts:89 LoraDelta.forward adds deltas only under this guard;
-- otherwise it returns its argument handle and issues no FFI call.
-- LoraOperation (lora.ts:131) selects `plain` iff no target has an active id.
def loraApplies (active : List String) (adapters : Nat) : Bool := !active.isEmpty && 0 < adapters
def loraOperationAdapted (active : List String) (targets : List (List String)) : Bool :=
  targets.any fun ids => active.any (ids.contains ·)

-- The interpreter must show `loraState.active = []` at every decode forward
-- (LoraState.#active starts [] and the route never assigns it).
theorem lora_identity (adapters : Nat) : loraApplies [] adapters = false := rfl
theorem lora_plain (targets : List (List String)) : loraOperationAdapted [] targets = false := by
  simp [loraOperationAdapted]

/-! ## Gap 7: folded Q/K scales

ops.filledBf16(v, 128) builds bytes [lo, hi] of bf16Bytes(v) per element
(ops.ts:52-78); mlx_array_new_data reads each little-endian word. The words
are HeadScaleConstruction's, so the vectors are its query/key constants. -/

def arrayNewData (bytes : Nat → Nat) (shape : List Nat) : Value :=
  ⟨.bfloat16, shape, fun i => bytes (2*i) + 256 * bytes (2*i+1)⟩

def filledBytes (word : BitVec 16) (b : Nat) : Nat := if b % 2 = 0 then word.toNat % 256 else word.toNat / 256

theorem filled_vector (value : HeadScaleConstruction.Double) :
    GlueAttention.Vector (arrayNewData (filledBytes (HeadScaleConstruction.hostWord value)) [128]) 128
      (HeadScaleConstruction.filled value) := by
  refine ⟨rfl, rfl, fun i => ?_⟩
  rw [HeadScaleConstruction.filled_value]
  unfold arrayNewData filledBytes bf
  dsimp only
  rw [ite_eq_left (by omega), ite_eq_right (by omega), Nat.mod_add_div (HeadScaleConstruction.hostWord value).toNat 256]
  congr 1
  rw [BitVec.ofNat_toNat]
  exact BitVec.setWidth_eq _

-- MLX's reference multiplies the unweighted rms_norm (weight 1) by the
-- scalar; the folded weight is applied first in the same kernel. For finite
-- operands BF16 multiplication commutes, so operand order cannot differ.
theorem mul_comm_finite (x y : BF) (hx : Model.isFinite x = true) (hy : Model.isFinite y = true) :
    BFloat16Arithmetic.mul x y = BFloat16Arithmetic.mul y x := by
  unfold BFloat16Arithmetic.mul
  congr 1
  have fx := BFloat16Arithmetic.finite_flush x hx
  have fy := BFloat16Arithmetic.finite_flush y hy
  rw [Model.Proof.mul_eq_spec, Model.Proof.mul_eq_spec]
  obtain ⟨dx, hdx⟩ := Model.exists_toDyadic?_of_isFinite fx
  obtain ⟨dy, hdy⟩ := Model.exists_toDyadic?_of_isFinite fy
  unfold Model.Spec.mul
  rw [hdx, hdy]
  simp only [Bool.xor_comm, Bool.or_comm, Nat.mul_comm, Int.add_comm]

/-! ## Gap 9: dtype promotion

mlx/dtype.cpp promote_types on the route's pairs, and the declared output
dtypes of the closures and kernels (gated.ts launchRecurrence: y InT, state
StT). -/

def promote : Dtype → Dtype → Option Dtype
  | .bfloat16, .bfloat16 => some .bfloat16
  | .float32, .float32 => some .float32
  | .bfloat16, .float32 => some .float32
  | .float32, .bfloat16 => some .float32
  | _, _ => none

theorem computeG_promotion : promote .bfloat16 .float32 = some .float32 := rfl

theorem computeG_dtype (aLog a dt g : Value) (h : closureApply M .computeG [aLog, a, dt] = some [g]) :
    g.dtype = .float32 := by
  simp only [closureApply, Closure.eval] at h
  by_cases c : aLog.dtype = .bfloat16 ∧ a.dtype = .bfloat16 ∧ dt.dtype = .bfloat16 ∧ a.shape = [1, 1, 48]
  · rw [ite_eq_left c] at h; cases h; rfl
  · rw [ite_eq_right c] at h; cases h

-- gated_delta_step output dtypes: y takes q's dtype (InT), state_out the
-- state's (StT).
def gatedOutputs (q state : Dtype) : Dtype × Dtype := (q, state)
theorem gated_dtypes : gatedOutputs .bfloat16 .float32 = (.bfloat16, .float32) := rfl

end Host.Mlx.GlueRoute
