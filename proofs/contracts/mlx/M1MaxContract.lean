import contracts.mlx.M1Max
import contracts.mlx.Division
import contracts.mlx.FlushedReduction
import contracts.mlx.RsqrtEpsilonBounds
import contracts.mlx.BFloat16Arithmetic
import contracts.mlx.BFloat16
import contracts.mlx.FloatMemory
import contracts.mlx.Maximum

namespace Inference.Contracts.Mlx.M1Max
open Numerics
open FloatLib FloatLib.Floats FloatLib.Floats.Formats.BinaryInterchange

/- The machine boundary of the native proof: what each AIR operation does on
   this target. Scope: Apple M1 Max (applegpu_g13s), macOS 27.0.1 (26A434),
   AGXMetalG13X/AGXCompilerCore 360.34.5, AIR produced by metalfe-32023.921.6
   (mlx.metallib built from MLX v0.32.2 by packages/mlx/scripts/build-native.sh) and metalfe-32023.921.5 (runtime compiler), with
   air.compile.denorms_disable and air.compile.fast_math_disable. Compiler
   conformance (MSL source to AIR, AIR to AGX code) is part of this boundary:
   each source operation means the operation named here.

   Every clause is operation-level and independent of any kernel, model,
   checkpoint or table. proofs/contracts/mlx/probe-m1max-contract.ts checks
   each clause on this machine (exhaustively for unary f32 clauses). This
   structure is a premise of the native theorem, not a declared axiom. -/
-- air.simd_max.f32 is one fixed tree of `if left<right then right else left`
-- on flushed comparisons, returning the unflushed word. Only the in-order
-- leaf sequence 0..31 is observable; every such tree gives the same word.
structure MaximumTree (reduce : (Fin 32 → Float32) → Float32) where
  tree : Reduction.Tree 32
  coverage : (Reduction.leaves tree).Perm (List.finRange 32)
  execution : ∀ input, (∀ i, (input i).isFinite=true) → reduce input=Maximum.tree input tree

structure Contract where
  -- Basic binary32 arithmetic, defined by the flushed nearest-even models
  -- (multiply, divide and fma flush tiny exact results before rounding).
  -- Kernel models compute with these definitions directly.
  fadd : Float32 → Float32 → Float32
  fmul : Float32 → Float32 → Float32
  fma : Float32 → Float32 → Float32 → Float32
  fadd_model : ∀ x y, x.isFinite=true → y.isFinite=true → fadd x y=FlushToZero.add x y
  fmul_model : ∀ x y, x.isFinite=true → y.isFinite=true → fmul x y=FlushToZero.mul x y
  fma_model : ∀ x y z, x.isFinite=true → y.isFinite=true → z.isFinite=true → fma x y z=FlushToZero.fma x y z
  -- `fdiv` without fast-math flags, correctly rounded with flushing on the
  -- divisor domain the kernels reach.
  fdiv : Float32 → Float32 → Float32
  fdiv_model : ∀ x y, x.isFinite=true → y.isFinite=true → Division.DivisorDomain y → fdiv x y=FlushToZero.div x y
  -- air.rsqrt.f32 on positive normal inputs.
  rsqrt : Float32 → Float32
  rsqrt_normal : RsqrtEpsilonBounds.NormalEnvelope rsqrt (17/16)
  -- air.exp.f32 (precise) and air.fast_exp.f32.
  exp : Float32 → Float32
  fastExp : Float32 → Float32
  exp_nonpositive : ∀ x, x.isFinite=true → real x≤0 → (exp x).isFinite=true ∧ 0≤real (exp x) ∧ real (exp x)≤1
  exp_zero : ∀ x, x.isFinite=true → real x=0 → real (exp x)=1
  exp_nonnegative : ∀ x, x.isFinite=true → (exp x).isFinite=true → 0≤real (exp x)
  exp_small : ∀ x, x.isFinite=true → |real x|≤8 → (exp x).isFinite=true ∧ real (exp x)≤(2:ℝ)^(12:Nat)
  exp_overflow : ∀ x, x.isFinite=true → (exp x).isFinite=true ∨ exp x=Float32.inf
  fastExp_nonpositive : ∀ x, x.isFinite=true → real x≤0 → (fastExp x).isFinite=true ∧ 0≤real (fastExp x) ∧ real (fastExp x)≤1
  fastExp_zero : ∀ x, x.isFinite=true → real x=0 → real (fastExp x)=1
  fastExp_negInf : (fastExp (Float32.ofBits 0xff800000)).isFinite=true ∧ real (fastExp (Float32.ofBits 0xff800000))=0
  fastExp_nonnegative : ∀ x, x.isFinite=true → (fastExp x).isFinite=true → 0≤real (fastExp x)
  fastExp_overflow : ∀ x, x.isFinite=true → (fastExp x).isFinite=true ∨ fastExp x=Float32.inf
  -- air.exp2.f32 (precise).
  exp2 : Float32 → Float32
  exp2_nonpositive : ∀ x, x.isFinite=true → real x≤0 → (exp2 x).isFinite=true ∧ 0≤real (exp2 x) ∧ real (exp2 x)≤1
  -- air.log.f32 (precise) and air.fast_log.f32.
  log : Float32 → Float32
  fastLog : Float32 → Float32
  log_bounded : ∀ x, x.isFinite=true → 1≤real x → real x≤(2:ℝ)^(18:Nat) → (log x).isFinite=true ∧ |real (log x)|≤32
  fastLog_unit : ∀ x, x.isFinite=true → 1≤real x → real x≤2 → (fastLog x).isFinite=true ∧ 0≤real (fastLog x) ∧ real (fastLog x)≤1
  -- air.fast_sin.f32 and air.fast_cos.f32 on the reached angle domain.
  fastSin : Float32 → Float32
  fastCos : Float32 → Float32
  fastSin_bounded : ∀ x, x.isFinite=true → |real x|≤(2:ℝ)^(18:Nat) → (fastSin x).isFinite=true ∧ |real (fastSin x)|≤2
  fastCos_bounded : ∀ x, x.isFinite=true → |real x|≤(2:ℝ)^(18:Nat) → (fastCos x).isFinite=true ∧ |real (fastCos x)|≤2
  -- air.fmax.f32 / air.fast_fmax.f32 and air.simd_max.f32 on finite inputs.
  fmax : Float32 → Float32 → Float32
  fmax_value : ∀ x y, x.isFinite=true → y.isFinite=true → fmax x y=if Maximum.less y x then x else y
  simdMax : (Fin 32 → Float32) → Float32
  simdMax_tree : MaximumTree simdMax
  -- air.fabs.f32 and air.fast_fabs.f32 clear the sign of finite inputs.
  fabs : Float32 → Float32
  fastFabs : Float32 → Float32
  fabs_value : ∀ x, x.isFinite=true → (fabs x).isFinite=true ∧ real (fabs x)=|real x|
  fastFabs_value : ∀ x, x.isFinite=true → (fastFabs x).isFinite=true ∧ real (fastFabs x)=|real x|
  -- air.simd_sum.f32: one fixed binary tree of flushed nearest-even adds.
  -- A NaN lane gives the default NaN on both (FlushedReduction.nan_witness).
  simdSum : (Fin 32 → Float32) → Float32
  simdSum_tree : FlushedReduction.SimdContract simdSum
  -- Threadgroup float load: the low two address bits are ignored.
  threadgroupLoad : ThreadgroupLoad
  threadgroupLoad_contract : LoadContract threadgroupLoad
  -- Device float4 load at a 16-aligned address reads four scalar words.
  vectorLoad : ByteMemory.Bytes → Nat → Fin 4 → Float32
  vectorLoad_components : ∀ bytes address, address%16=0 → address+16≤2^64 →
    ∀ component, vectorLoad bytes address component=FloatMemory.load bytes (address+4*component.val)
  -- bfloat arithmetic, flushed like binary32, and the conversions: widening
  -- is exact; narrowing rounds to nearest even and keeps subnormals.
  bfadd : BFloat16Arithmetic.Value → BFloat16Arithmetic.Value → BFloat16Arithmetic.Value
  bfsub : BFloat16Arithmetic.Value → BFloat16Arithmetic.Value → BFloat16Arithmetic.Value
  bfmul : BFloat16Arithmetic.Value → BFloat16Arithmetic.Value → BFloat16Arithmetic.Value
  bfdiv : BFloat16Arithmetic.Value → BFloat16Arithmetic.Value → BFloat16Arithmetic.Value
  bfadd_model : ∀ x y, Model.isFinite x=true → Model.isFinite y=true → bfadd x y=BFloat16Arithmetic.add x y
  bfsub_model : ∀ x y, Model.isFinite x=true → Model.isFinite y=true → bfsub x y=BFloat16Arithmetic.sub x y
  bfmul_model : ∀ x y, Model.isFinite x=true → Model.isFinite y=true → bfmul x y=BFloat16Arithmetic.mul x y
  -- Flushed 0/0 returns 0x7fff on the hardware; the kernels never divide by zero.
  bfdiv_model : ∀ x y, Model.isFinite x=true → Model.isFinite y=true → Model.toReal (BFloat16Arithmetic.flush y)≠0 →
    bfdiv x y=BFloat16Arithmetic.div x y
  narrow : Float32 → BFloat16Arithmetic.Value
  widen : BFloat16Arithmetic.Value → Float32
  narrow_model : ∀ x, x.isFinite=true → narrow x=BFloat16.narrow x
  widen_model : ∀ x, Model.isFinite x=true → widen x=BFloat16.widen x

/- Device facts of the compute pipelines on this target. `maxThreads name` and
   `executionWidth name` are the maxTotalThreadsPerThreadgroup and
   threadExecutionWidth of the pipeline created for the Metal function `name`.
   The host proofs take these limits as premises: MLX sizes rms_looped and
   looped logsumexp threadgroups and the KV-row 2-D general copy from
   maxTotalThreadsPerThreadgroup, and the SIMD reductions assume 32 lanes.
   The probe reads them from the pipelines MLX creates (metal-tracer.m). -/
structure Pipelines where
  maxThreads : String → Nat
  executionWidth : String → Nat
  rmsLooped : maxThreads "rms_loopedbfloat16"=1024
  logSumExpLooped : maxThreads "looped_logsumexp_bfloat16"=1024
  generalCopy2D : maxThreads "gg2_copybfloat16bfloat16"=1024
  simdWidth : ∀ name, executionWidth name=32

end Inference.Contracts.Mlx.M1Max
