import models.qwen.Blocks
import layers.AffineVerifyLinear
import kernels.attention.RopeAngles

namespace Inference.Models.Qwen.AttentionHeads
open Contracts.Mlx Contracts.Mlx.Numerics
open FloatLib FloatLib.Floats FloatLib.Floats.Formats.BinaryInterchange
open Layers.AffineVerifyLinear
abbrev BF := BFloat16Arithmetic.Value

-- Qwen's q_proj interleaves query and output-gate halves within each head.
-- The KV projections have four heads; the query/gate projection has 24.
structure Heads (α : Type) where
  query : Fin 24 → Fin 256 → α
  key : Fin 4 → Fin 256 → α
  value : Fin 4 → Fin 256 → α
  gate : Fin 24 → Fin 256 → α

def queryIndex (head : Fin 24) (i : Fin 256) : Fin 12288 :=
  ⟨head.val*512+i.val, by have := head.isLt; have := i.isLt; omega⟩
def gateIndex (head : Fin 24) (i : Fin 256) : Fin 12288 :=
  ⟨head.val*512+256+i.val, by have := head.isLt; have := i.isLt; omega⟩
def kvIndex (head : Fin 4) (i : Fin 256) : Fin 1024 :=
  ⟨head.val*256+i.val, by have := head.isLt; have := i.isLt; omega⟩

theorem query_gate_disjoint (a b : Fin 24) (i j : Fin 256) : queryIndex a i ≠ gateIndex b j := by
  intro he
  have h := congrArg Fin.val he
  have := i.isLt
  have := j.isLt
  dsimp [queryIndex, gateIndex] at h
  omega

theorem query_inverse (head : Fin 24) (i : Fin 256) :
    (queryIndex head i).val/512 = head.val ∧ (queryIndex head i).val%512 = i.val := by
  have := i.isLt
  dsimp [queryIndex]
  omega

theorem gate_inverse (head : Fin 24) (i : Fin 256) :
    (gateIndex head i).val/512 = head.val ∧ (gateIndex head i).val%512 = 256+i.val := by
  have := i.isLt
  dsimp [gateIndex]
  omega

theorem kv_inverse (head : Fin 4) (i : Fin 256) :
    (kvIndex head i).val/256 = head.val ∧ (kvIndex head i).val%256 = i.val := by
  have := i.isLt
  dsimp [kvIndex]
  omega

structure Projections where
  q : Projection 10 12288
  k : Projection 10 1024
  v : Projection 10 1024

def Projections.forward (p : Projections) (x : Fin 5120 → BF) : Heads BF where
  query head i := p.q.forward x (queryIndex head i)
  gate head i := p.q.forward x (gateIndex head i)
  key head i := p.k.forward x (kvIndex head i)
  value head i := p.v.forward x (kvIndex head i)

noncomputable def Projections.target (p : Projections) (x : Fin 5120 → ℝ) : Heads ℝ where
  query head i := p.q.target x (queryIndex head i)
  gate head i := p.q.target x (gateIndex head i)
  key head i := p.k.target x (kvIndex head i)
  value head i := p.v.target x (kvIndex head i)

noncomputable def Projections.budget (p : Projections) (x : Fin 5120 → BF) (target error : Fin 5120 → ℝ) : Heads ℝ where
  query head i := p.q.budget x target error (queryIndex head i)
  gate head i := p.q.budget x target error (gateIndex head i)
  key head i := p.k.budget x target error (kvIndex head i)
  value head i := p.v.budget x target error (kvIndex head i)

structure Projections.Finite (p : Projections) (x : Fin 5120 → BF) : Prop where
  q : p.q.Finite x
  k : p.k.Finite x
  v : p.v.Finite x

structure Error (x : Heads BF) (target error : Heads ℝ) : Prop where
  query : ∀ h i, |Model.toReal (x.query h i) - target.query h i| ≤ error.query h i
  key : ∀ h i, |Model.toReal (x.key h i) - target.key h i| ≤ error.key h i
  value : ∀ h i, |Model.toReal (x.value h i) - target.value h i| ≤ error.value h i
  gate : ∀ h i, |Model.toReal (x.gate h i) - target.gate h i| ≤ error.gate h i
structure Finite (x : Heads BF) : Prop where
  query : ∀ h i, Model.isFinite (x.query h i) = true
  key : ∀ h i, Model.isFinite (x.key h i) = true
  value : ∀ h i, Model.isFinite (x.value h i) = true
  gate : ∀ h i, Model.isFinite (x.gate h i) = true

theorem Projections.forward_error (p : Projections) (x : Fin 5120 → BF) (target error : Fin 5120 → ℝ)
    (hi : ∀ i, |Model.toReal (x i) - target i| ≤ error i) (hf : p.Finite x) :
    Error (p.forward x) (p.target target) (p.budget x target error) where
  query h i := p.q.forward_error x target error hi hf.q (queryIndex h i)
  key h i := p.k.forward_error x target error hi hf.k (kvIndex h i)
  value h i := p.v.forward_error x target error hi hf.v (kvIndex h i)
  gate h i := p.q.forward_error x target error hi hf.q (gateIndex h i)

theorem Projections.forward_finite (p : Projections) (x : Fin 5120 → BF) (hf : p.Finite x) : AttentionHeads.Finite (p.forward x) where
  query h i := p.q.forward_finite x hf.q (queryIndex h i)
  key h i := p.k.forward_finite x hf.k (kvIndex h i)
  value h i := p.v.forward_finite x hf.v (kvIndex h i)
  gate h i := p.q.forward_finite x hf.q (gateIndex h i)

-- Per-head RMS normalization uses 256 coordinates and the loaded q_norm or
-- k_norm weight directly. It precedes the partial RoPE operation.
def width : Float32 := Float32.ofBits 0x43800000

theorem width_value : real width = 256 := by
  rw [real_unpack]
  change Model.unpackedToReal (.finite .positive 8388608 (-15) (by decide)) = 256
  rw [Model.unpackedToReal_finite]
  norm_num [Model.modelSignBit, FloatLib.Floats.Formats.Flocq.bpow]
  change 8388608 * ((2 : ℝ)^15)⁻¹ = 256
  norm_num

theorem width_finite : width.isFinite = true := by decide +kernel

structure Norm where
  platform : RmsNorm.Platform
  weight : Fin 256 → BF
  scratch : M1Max.WordMemory
  base : Nat

def Norm.forward (n : Norm) (x : Fin 256 → BF) : Fin 256 → BF :=
  Layers.Normalization.value n.platform (fun i => BFloat16.widen (x i)) n.weight false width Blocks.eps n.scratch n.base
noncomputable def Norm.target (n : Norm) (x : Fin 256 → ℝ) : Fin 256 → ℝ :=
  Contracts.Mlx.Normalization.rmsNorm x (fun i => Model.toReal (n.weight i)) Blocks.idealEps
noncomputable def Norm.budget (n : Norm) (x : Fin 256 → BF) (target error : Fin 256 → ℝ) : Fin 256 → ℝ :=
  Layers.Normalization.errorBudget n.platform (fun i => BFloat16.widen (x i)) n.weight false width Blocks.eps
    Blocks.idealEps Blocks.epsError target error

def Norm.Finite (n : Norm) (x : Fin 256 → BF) : Prop :=
  NormalizationExecution.Finite n.platform.divide (fun i => BFloat16.widen (x i)) n.weight
    (RmsNorm.expression n.platform 256) width Blocks.eps n.platform.rsqrt

theorem Norm.forward_finite (n : Norm) (x : Fin 256 → BF) (hf : n.Finite x) (i : Fin 256) :
    Model.isFinite (n.forward x i) = true :=
  Layers.Normalization.value_finite n.platform (fun j => BFloat16.widen (x j)) n.weight false width Blocks.eps hf n.scratch n.base i

theorem Norm.forward_error (n : Norm) (x : Fin 256 → BF) (target error : Fin 256 → ℝ)
    (hi : ∀ i, |Model.toReal (x i) - target i| ≤ error i) (hx : ∀ i, Model.isFinite (x i) = true)
    (hw : ∀ i, Model.isFinite (n.weight i) = true) (hf : n.Finite x) (i : Fin 256) :
    |Model.toReal (n.forward x i) - n.target target i| ≤ n.budget x target error i := by
  apply Layers.Normalization.value_error n.platform (fun j => BFloat16.widen (x j)) n.weight false width Blocks.eps
    Blocks.idealEps Blocks.epsError (by norm_num [Blocks.idealEps]) Blocks.eps_accuracy target error _ hw _ hf n.scratch n.base i
  · intro j
    rw [BFloat16.widen_real _ (hx j)]
    exact hi j
  · intro j
    simp [Layers.Normalization.PreparationFinite]

open Kernels.Attention

-- Only the arithmetic ranges still to be discharged by the caller are listed
-- here. The first/second inputs and theta are finite by the preceding proofs.
structure RotationRange (p : Rope.Platform) (x : Rope.Inputs) : Prop where
  domain : p.domain x.theta
  sine : (p.sin x.theta).isFinite = true
  cosine : (p.cos x.theta).isFinite = true
  product : (FlushToZero.flush (BFloat16.widen x.second) * FlushToZero.flush (p.sin x.theta)).isFinite = true
  arithmetic : ∀ second, Arithmetic.Finite (Rope.bind p x) (Rope.expression p second)
  cast : ∀ second, Model.isFinite (Rope.value p x second) = true

theorem RotationRange.finite (p : Rope.Platform) (x : Rope.Inputs) (hr : RotationRange p x)
    (h1 : Model.isFinite x.first = true) (h2 : Model.isFinite x.second = true)
    (ht : x.theta.isFinite = true) : Rope.Finite p x :=
  ⟨⟨h1, h2, ht, hr.domain, hr.sine, hr.cosine, hr.product⟩, hr.arithmetic, hr.cast⟩

structure Preparation where
  qNorm : Norm
  kNorm : Norm
  angles : RopeAngles.Platform
  rotation : Rope.Platform

def Preparation.normalized (p : Preparation) (x : Heads BF) : Heads BF where
  query h := p.qNorm.forward (x.query h)
  key h := p.kNorm.forward (x.key h)
  value := x.value
  gate := x.gate
noncomputable def Preparation.normalizedTarget (p : Preparation) (x : Heads ℝ) : Heads ℝ where
  query h := p.qNorm.target (x.query h)
  key h := p.kNorm.target (x.key h)
  value := x.value
  gate := x.gate
noncomputable def Preparation.normalizedBudget (p : Preparation) (x : Heads BF) (target error : Heads ℝ) : Heads ℝ where
  query h := p.qNorm.budget (x.query h) (target.query h) (error.query h)
  key h := p.kNorm.budget (x.key h) (target.key h) (error.key h)
  value := error.value
  gate := error.gate

def Preparation.forward (p : Preparation) (x : Heads BF) (angle : RopeAngles.Inputs) : Heads BF where
  query h := Rope.head p.rotation (p.normalized x |>.query h) (RopeAngles.value p.angles angle)
  key h := Rope.head p.rotation (p.normalized x |>.key h) (RopeAngles.value p.angles angle)
  value := x.value
  gate := x.gate
noncomputable def Preparation.target (p : Preparation) (x : Heads ℝ) (angle : RopeAngles.Target) : Heads ℝ where
  query h := Rope.headTarget (p.normalizedTarget x |>.query h) (RopeAngles.targetValue angle)
  key h := Rope.headTarget (p.normalizedTarget x |>.key h) (RopeAngles.targetValue angle)
  value := x.value
  gate := x.gate
noncomputable def Preparation.budget (p : Preparation) (x : Heads BF) (target error : Heads ℝ)
    (angle : RopeAngles.Inputs) (angleTarget angleError : RopeAngles.Target) : Heads ℝ where
  query h := Rope.headBudget p.rotation (p.normalized x |>.query h) (RopeAngles.value p.angles angle)
    (p.normalizedTarget target |>.query h) (p.normalizedBudget x target error |>.query h)
    (RopeAngles.targetValue angleTarget) (RopeAngles.budget p.angles angle angleTarget angleError)
  key h := Rope.headBudget p.rotation (p.normalized x |>.key h) (RopeAngles.value p.angles angle)
    (p.normalizedTarget target |>.key h) (p.normalizedBudget x target error |>.key h)
    (RopeAngles.targetValue angleTarget) (RopeAngles.budget p.angles angle angleTarget angleError)
  value := error.value
  gate := error.gate

structure Preparation.Finite (p : Preparation) (x : Heads BF) (angle : RopeAngles.Inputs) : Prop where
  qWeight : ∀ i, Model.isFinite (p.qNorm.weight i) = true
  kWeight : ∀ i, Model.isFinite (p.kNorm.weight i) = true
  qNorm : ∀ h, p.qNorm.Finite (x.query h)
  kNorm : ∀ h, p.kNorm.Finite (x.key h)
  angleRange : ∀ i, RopeAngles.Finite p.angles angle i
  qRotation : ∀ h i, RotationRange p.rotation
    (Rope.headInputs (p.normalized x |>.query h) (RopeAngles.value p.angles angle) i)
  kRotation : ∀ h i, RotationRange p.rotation
    (Rope.headInputs (p.normalized x |>.key h) (RopeAngles.value p.angles angle) i)

theorem Preparation.normalized_finite (p : Preparation) (x : Heads BF) (angle : RopeAngles.Inputs)
    (hx : AttentionHeads.Finite x) (hf : p.Finite x angle) : AttentionHeads.Finite (p.normalized x) where
  query h i := p.qNorm.forward_finite _ (hf.qNorm h) i
  key h i := p.kNorm.forward_finite _ (hf.kNorm h) i
  value := hx.value
  gate := hx.gate

theorem Preparation.normalized_error (p : Preparation) (x : Heads BF) (target error : Heads ℝ)
    (angle : RopeAngles.Inputs) (hi : Error x target error) (hx : AttentionHeads.Finite x)
    (hf : p.Finite x angle) : Error (p.normalized x) (p.normalizedTarget target) (p.normalizedBudget x target error) where
  query h i := p.qNorm.forward_error _ _ _ (hi.query h) (hx.query h) hf.qWeight (hf.qNorm h) i
  key h i := p.kNorm.forward_error _ _ _ (hi.key h) (hx.key h) hf.kWeight (hf.kNorm h) i
  value := hi.value
  gate := hi.gate

theorem Preparation.query_rotation_finite (p : Preparation) (x : Heads BF) (angle : RopeAngles.Inputs)
    (hx : AttentionHeads.Finite x) (hf : p.Finite x angle) (h : Fin 24) (i : Fin 32) :
    Rope.Finite p.rotation (Rope.headInputs (p.normalized x |>.query h) (RopeAngles.value p.angles angle) i) := by
  have hn := p.normalized_finite x angle hx hf
  exact (hf.qRotation h i).finite _ _ (hn.query h _) (hn.query h _)
    (RopeAngles.value_finite _ _ i (hf.angleRange i))

theorem Preparation.key_rotation_finite (p : Preparation) (x : Heads BF) (angle : RopeAngles.Inputs)
    (hx : AttentionHeads.Finite x) (hf : p.Finite x angle) (h : Fin 4) (i : Fin 32) :
    Rope.Finite p.rotation (Rope.headInputs (p.normalized x |>.key h) (RopeAngles.value p.angles angle) i) := by
  have hn := p.normalized_finite x angle hx hf
  exact (hf.kRotation h i).finite _ _ (hn.key h _) (hn.key h _)
    (RopeAngles.value_finite _ _ i (hf.angleRange i))

theorem Preparation.forward_finite (p : Preparation) (x : Heads BF) (angle : RopeAngles.Inputs)
    (hx : AttentionHeads.Finite x) (hf : p.Finite x angle) : AttentionHeads.Finite (p.forward x angle) where
  query h i := Rope.head_finite _ _ _ (p.normalized_finite x angle hx hf |>.query h)
    (p.query_rotation_finite x angle hx hf h) i
  key h i := Rope.head_finite _ _ _ (p.normalized_finite x angle hx hf |>.key h)
    (p.key_rotation_finite x angle hx hf h) i
  value := hx.value
  gate := hx.gate

theorem Preparation.forward_error (p : Preparation) (x : Heads BF) (target error : Heads ℝ)
    (angle : RopeAngles.Inputs) (angleTarget angleError : RopeAngles.Target)
    (hi : Error x target error) (hx : AttentionHeads.Finite x) (hf : p.Finite x angle)
    (ha : RopeAngles.InputError angle angleTarget angleError) (hb : 0 ≤ angleTarget.base) :
    Error (p.forward x angle) (p.target target angleTarget) (p.budget x target error angle angleTarget angleError) where
  query h i := Rope.head_error _ _ _ _ _ _ _
    (p.normalized_error x target error angle hi hx hf |>.query h)
    (fun j => RopeAngles.value_error p.angles angle angleTarget angleError j (hf.angleRange j) ha hb)
    (p.query_rotation_finite x angle hx hf h) i
  key h i := Rope.head_error _ _ _ _ _ _ _
    (p.normalized_error x target error angle hi hx hf |>.key h)
    (fun j => RopeAngles.value_error p.angles angle angleTarget angleError j (hf.angleRange j) ha hb)
    (p.key_rotation_finite x angle hx hf h) i
  value := hi.value
  gate := hi.gate

-- Projection -> q/k normalization -> partial rotation, retaining V and the
-- unactivated output gate. No head-level accuracy is supplied as an assumption.
theorem projected_preparation_error (p : Projections) (prep : Preparation)
    (x : Fin 5120 → BF) (target error : Fin 5120 → ℝ)
    (angle : RopeAngles.Inputs) (angleTarget angleError : RopeAngles.Target)
    (hi : ∀ i, |Model.toReal (x i) - target i| ≤ error i) (hp : p.Finite x)
    (hf : prep.Finite (p.forward x) angle)
    (ha : RopeAngles.InputError angle angleTarget angleError) (hb : 0 ≤ angleTarget.base) :
    Error (prep.forward (p.forward x) angle) (prep.target (p.target target) angleTarget)
      (prep.budget (p.forward x) (p.target target) (p.budget x target error) angle angleTarget angleError) :=
  prep.forward_error _ _ _ angle angleTarget angleError (p.forward_error x target error hi hp)
    (p.forward_finite x hp) hf ha hb

end Inference.Models.Qwen.AttentionHeads
