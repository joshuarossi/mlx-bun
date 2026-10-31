import contracts.mlx.M1MaxContract
import contracts.mlx.Negation

namespace Host.Route.Sat
open Inference.Contracts.Mlx Inference.Contracts.Mlx.M1Max Numerics
open FloatLib FloatLib.Floats FloatLib.Floats.Formats.BinaryInterchange

/-! # A model of the machine contract

`M1Max.Contract` at a mathematical machine: arithmetic, conversions and the SIMD reductions are their flushed models
(so their model clauses hold by definition); the transcendental operations and `rsqrt` are constants inside the
contract's bounds (`rsqrt` 0, `exp`/`exp2` 1, `fastExp` 1 and 0 at -inf, `log`/`fastLog`/`fastSin`/`fastCos` 0). It is
not the hardware: it only shows the clauses are consistent. -/

theorem finite_zero : (0 : Float32).isFinite = true := by decide +kernel
theorem finite_one : (1 : Float32).isFinite = true := by decide +kernel

theorem real_zero : real (0 : Float32) = 0 := by
  rw [real_unpack]
  exact Model.unpackedToReal_zero _

theorem negInf_not_finite : (Float32.ofBits 0xff800000).isFinite = false := by decide +kernel

open Classical in
/-- `fastExp`: 0 at -inf (`fastExp_negInf`), else 1. -/
noncomputable def fastExpModel (x : Float32) : Float32 := if x = Float32.ofBits 0xff800000 then 0 else 1

theorem fastExpModel_finite (x : Float32) : (fastExpModel x).isFinite = true := by
  unfold fastExpModel; split
  · exact finite_zero
  · exact finite_one

theorem fastExpModel_range (x : Float32) : 0 ≤ real (fastExpModel x) ∧ real (fastExpModel x) ≤ 1 := by
  unfold fastExpModel; split
  · rw [real_zero]; norm_num
  · rw [real_one]; norm_num

theorem fastExpModel_finite_arg {x : Float32} (hx : x.isFinite = true) : fastExpModel x = 1 := by
  unfold fastExpModel
  refine ite_eq_right fun h => ?_
  rw [h, negInf_not_finite] at hx
  cases hx

open Classical in
/-- `fabs`: `x` or `-x`. -/
noncomputable def fabsModel (x : Float32) : Float32 := if 0 ≤ real x then x else -x

theorem fabsModel_value (x : Float32) (hx : x.isFinite = true) :
    (fabsModel x).isFinite = true ∧ real (fabsModel x) = |real x| := by
  unfold fabsModel; split
  · rename_i h
    exact ⟨hx, (abs_of_nonneg h).symm⟩
  · rename_i h
    refine ⟨Negation.finite_neg x hx, ?_⟩
    rw [Negation.real_neg x hx, abs_of_neg (lt_of_not_ge h)]

/-- **A model of the machine contract.** -/
noncomputable def machineModel : M1Max.Contract where
  fadd := FlushToZero.add
  fmul := FlushToZero.mul
  fma := FlushToZero.fma
  fadd_model _ _ _ _ := rfl
  fmul_model _ _ _ _ := rfl
  fma_model _ _ _ _ _ _ := rfl
  fdiv := FlushToZero.div
  fdiv_model _ _ _ _ _ := rfl
  fdiv_unit_model _ _ _ _ _ _ := rfl
  rsqrt := fun _ => 0
  rsqrt_normal := ⟨fun _ _ _ => finite_zero, fun x _ _ => by
    rw [real_zero, abs_zero, zero_mul]; norm_num⟩
  exp := fun _ => 1
  fastExp := fastExpModel
  exp_nonpositive _ _ _ := ⟨finite_one, by rw [real_one]; norm_num, by rw [real_one]⟩
  exp_zero _ _ _ := real_one
  exp_nonnegative _ _ _ := by rw [real_one]; norm_num
  exp_small _ _ _ := ⟨finite_one, by rw [real_one]; norm_num⟩
  exp_overflow _ _ := Or.inl finite_one
  fastExp_nonpositive x _ _ := ⟨fastExpModel_finite x, fastExpModel_range x⟩
  fastExp_zero _ hx _ := by rw [fastExpModel_finite_arg hx, real_one]
  fastExp_negInf := by
    have h : fastExpModel (Float32.ofBits 0xff800000) = 0 := ite_eq_left rfl
    rw [h]
    exact ⟨finite_zero, real_zero⟩
  fastExp_nonnegative x _ _ := (fastExpModel_range x).1
  fastExp_overflow x _ := Or.inl (fastExpModel_finite x)
  exp2 := fun _ => 1
  exp2_nonpositive _ _ _ := ⟨finite_one, by rw [real_one]; norm_num, by rw [real_one]⟩
  log := fun _ => 0
  fastLog := fun _ => 0
  log_bounded _ _ _ _ := ⟨finite_zero, by rw [real_zero, abs_zero]; norm_num⟩
  fastLog_unit _ _ _ _ := ⟨finite_zero, by rw [real_zero], by rw [real_zero]; norm_num⟩
  fastSin := fun _ => 0
  fastCos := fun _ => 0
  fastSin_bounded _ _ _ := ⟨finite_zero, by rw [real_zero, abs_zero]; norm_num⟩
  fastCos_bounded _ _ _ := ⟨finite_zero, by rw [real_zero, abs_zero]; norm_num⟩
  fmax := fun x y => if Maximum.less y x then x else y
  fmax_value _ _ _ _ := rfl
  simdMax := fun input => Maximum.tree input Reduction.orderedTree
  simdMax_tree := ⟨Reduction.orderedTree, Reduction.ordered_coverage, fun _ _ => rfl⟩
  fabs := fabsModel
  fastFabs := fabsModel
  fabs_value := fabsModel_value
  fastFabs_value := fabsModel_value
  simdSum := fun input => FlushedReduction.evaluate input Reduction.orderedTree
  simdSum_tree := FlushedReduction.orderedContract
  threadgroupLoad := alignedLoad
  threadgroupLoad_contract := alignedLoad_contract
  vectorLoad := fun bytes address component => FloatMemory.load bytes (address + 4 * component.val)
  vectorLoad_components _ _ _ _ _ := rfl
  bfadd := BFloat16Arithmetic.add
  bfsub := BFloat16Arithmetic.sub
  bfmul := BFloat16Arithmetic.mul
  bfdiv := BFloat16Arithmetic.div
  bfadd_model _ _ _ _ := rfl
  bfsub_model _ _ _ _ := rfl
  bfmul_model _ _ _ _ := rfl
  bfdiv_model _ _ _ _ _ := rfl
  narrow := BFloat16.narrow
  widen := BFloat16.widen
  narrow_model _ _ := rfl
  widen_model _ _ := rfl
  fdiv_one_model _ _ _ := rfl
  fadd_posInf _ _ := rfl
  fdiv_posInf _ _ := rfl
  narrow_posInf := rfl
  bfadd_posInf _ _ := rfl
  bfdiv_posInf _ _ := rfl
  narrowHalf := fun _ => Model.posOne _
  simdMma := fun _ _ c => c
  simdMmaHalfA := fun _ _ c => c
  simdMmaHalfB := fun _ _ c => c

end Host.Route.Sat
