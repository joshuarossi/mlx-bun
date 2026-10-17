import models.qwen.AttentionHeads
import state.Kv
import kernels.attention.SdpaDispatched
import kernels.attention.OutputGate

namespace Inference.Models.Qwen.Attention
open Contracts.Mlx Contracts.Mlx.Numerics
open FloatLib FloatLib.Floats FloatLib.Floats.Formats.BinaryInterchange
open Kernels.Attention
abbrev BF := BFloat16Arithmetic.Value
abbrev Cache := State.Kv.Cache

-- Each route carries its proved arithmetic obligations, including input
-- finiteness derived by the layer range theorem.
abbrev ReadRange := @SdpaDispatched.Finite

structure Layer where
  projections : AttentionHeads.Projections
  preparation : AttentionHeads.Preparation
  attention : SdpaVector.Platform
  gate : OutputGate.Platform
  output : Layers.AffineVerifyLinear.Projection 12 5120
  architectureSuffix : Char
  mergeContracted : Bool

def Layer.heads (l : Layer) (x : Fin 5120 → BF) (angle : RopeAngles.Inputs) : AttentionHeads.Heads BF :=
  l.preparation.forward (l.projections.forward x) angle
noncomputable def Layer.targetHeads (l : Layer) (x : Fin 5120 → ℝ) (angle : RopeAngles.Target) : AttentionHeads.Heads ℝ :=
  l.preparation.target (l.projections.target x) angle
noncomputable def Layer.headBudgets (l : Layer) (x : Fin 5120 → BF) (target error : Fin 5120 → ℝ)
    (angle : RopeAngles.Inputs) (angleTarget angleError : RopeAngles.Target) : AttentionHeads.Heads ℝ :=
  l.preparation.budget (l.projections.forward x) (l.projections.target target) (l.projections.budget x target error)
    angle angleTarget angleError

def Layer.cacheAfter (l : Layer) (x : Fin 5120 → BF) (angle : RopeAngles.Inputs) (cache : Cache BF n) : Cache BF (n+1) :=
  State.Kv.append cache (l.heads x angle).key (l.heads x angle).value
noncomputable def Layer.targetCacheAfter (l : Layer) (x : Fin 5120 → ℝ) (angle : RopeAngles.Target) (cache : Cache ℝ n) : Cache ℝ (n+1) :=
  State.Kv.append cache (l.targetHeads x angle).key (l.targetHeads x angle).value
noncomputable def Layer.cacheBudgets (l : Layer) (x : Fin 5120 → BF) (target error : Fin 5120 → ℝ)
    (angle : RopeAngles.Inputs) (angleTarget angleError : RopeAngles.Target) (cacheError : Cache ℝ n) : Cache ℝ (n+1) :=
  State.Kv.append cacheError (l.headBudgets x target error angle angleTarget angleError).key
    (l.headBudgets x target error angle angleTarget angleError).value

def Layer.read (l : Layer) (x : Fin 5120 → BF) (angle : RopeAngles.Inputs) (cache : Cache BF n) (h : Fin 24) : Fin 256 → BF :=
  SdpaDispatched.forward l.attention l.mergeContracted l.architectureSuffix ((l.heads x angle).query h)
    ((l.cacheAfter x angle cache).keys (SdpaScore.kvHead h)) ((l.cacheAfter x angle cache).values (SdpaScore.kvHead h))
noncomputable def Layer.targetRead (l : Layer) (x : Fin 5120 → ℝ) (angle : RopeAngles.Target) (cache : Cache ℝ n) (h : Fin 24) : Fin 256 → ℝ :=
  SdpaVector.target ((l.targetHeads x angle).query h)
    ((l.targetCacheAfter x angle cache).keys (SdpaScore.kvHead h)) ((l.targetCacheAfter x angle cache).values (SdpaScore.kvHead h))
noncomputable def Layer.readBudgets (l : Layer) (x : Fin 5120 → BF) (target error : Fin 5120 → ℝ)
    (angle : RopeAngles.Inputs) (angleTarget angleError : RopeAngles.Target)
    (cache : Cache BF n) (cacheTarget cacheError : Cache ℝ n) (h : Fin 24) : Fin 256 → ℝ :=
  SdpaDispatched.budget l.attention l.mergeContracted l.architectureSuffix ((l.heads x angle).query h)
    ((l.cacheAfter x angle cache).keys (SdpaScore.kvHead h)) ((l.cacheAfter x angle cache).values (SdpaScore.kvHead h))
    ((l.targetHeads target angleTarget).query h) ((l.headBudgets x target error angle angleTarget angleError).query h)
    ((l.targetCacheAfter target angleTarget cacheTarget).keys (SdpaScore.kvHead h))
    ((l.targetCacheAfter target angleTarget cacheTarget).values (SdpaScore.kvHead h))
    ((l.cacheBudgets x target error angle angleTarget angleError cacheError).keys (SdpaScore.kvHead h))
    ((l.cacheBudgets x target error angle angleTarget angleError cacheError).values (SdpaScore.kvHead h))

def Layer.gated (l : Layer) (x : Fin 5120 → BF) (angle : RopeAngles.Inputs) (cache : Cache BF n) (h : Fin 24) (i : Fin 256) : BF :=
  OutputGate.forward l.gate (l.read x angle cache h i) ((l.heads x angle).gate h i)
noncomputable def Layer.targetGated (l : Layer) (x : Fin 5120 → ℝ) (angle : RopeAngles.Target) (cache : Cache ℝ n) (h : Fin 24) (i : Fin 256) : ℝ :=
  OutputGate.target (l.targetRead x angle cache h i) ((l.targetHeads x angle).gate h i)
noncomputable def Layer.gatedBudgets (l : Layer) (x : Fin 5120 → BF) (target error : Fin 5120 → ℝ)
    (angle : RopeAngles.Inputs) (angleTarget angleError : RopeAngles.Target)
    (cache : Cache BF n) (cacheTarget cacheError : Cache ℝ n) (h : Fin 24) (i : Fin 256) : ℝ :=
  OutputGate.budget l.gate (l.read x angle cache h i) ((l.heads x angle).gate h i)
    (l.targetRead target angleTarget cacheTarget h i) (l.readBudgets x target error angle angleTarget angleError cache cacheTarget cacheError h i)
    ((l.headBudgets x target error angle angleTarget angleError).gate h i)

def headIndex (i : Fin 6144) : Fin 24 := ⟨i.val/256, by have := i.isLt; omega⟩
def coordinate (i : Fin 6144) : Fin 256 := ⟨i.val%256, Nat.mod_lt _ (by decide)⟩
def flatIndex (h : Fin 24) (i : Fin 256) : Fin 6144 := ⟨h.val*256+i.val, by have := h.isLt; have := i.isLt; omega⟩
theorem flatten_inverse (h : Fin 24) (i : Fin 256) : headIndex (flatIndex h i) = h ∧ coordinate (flatIndex h i) = i := by
  constructor <;> apply Fin.ext <;> dsimp [headIndex, coordinate, flatIndex] <;> have := i.isLt <;> omega
theorem unflatten_inverse (i : Fin 6144) : flatIndex (headIndex i) (coordinate i) = i := by
  apply Fin.ext
  dsimp [flatIndex, headIndex, coordinate]
  omega

def Layer.merged (l : Layer) (x : Fin 5120 → BF) (angle : RopeAngles.Inputs) (cache : Cache BF n) (i : Fin 6144) : BF :=
  l.gated x angle cache (headIndex i) (coordinate i)
noncomputable def Layer.targetMerged (l : Layer) (x : Fin 5120 → ℝ) (angle : RopeAngles.Target) (cache : Cache ℝ n) (i : Fin 6144) : ℝ :=
  l.targetGated x angle cache (headIndex i) (coordinate i)
noncomputable def Layer.mergedBudgets (l : Layer) (x : Fin 5120 → BF) (target error : Fin 5120 → ℝ)
    (angle : RopeAngles.Inputs) (angleTarget angleError : RopeAngles.Target)
    (cache : Cache BF n) (cacheTarget cacheError : Cache ℝ n) (i : Fin 6144) : ℝ :=
  l.gatedBudgets x target error angle angleTarget angleError cache cacheTarget cacheError (headIndex i) (coordinate i)

def Layer.forward (l : Layer) (x : Fin 5120 → BF) (angle : RopeAngles.Inputs) (cache : Cache BF n) : Fin 5120 → BF :=
  l.output.forward (l.merged x angle cache)
noncomputable def Layer.target (l : Layer) (x : Fin 5120 → ℝ) (angle : RopeAngles.Target) (cache : Cache ℝ n) : Fin 5120 → ℝ :=
  l.output.target (l.targetMerged x angle cache)
noncomputable def Layer.budget (l : Layer) (x : Fin 5120 → BF) (target error : Fin 5120 → ℝ)
    (angle : RopeAngles.Inputs) (angleTarget angleError : RopeAngles.Target)
    (cache : Cache BF n) (cacheTarget cacheError : Cache ℝ n) : Fin 5120 → ℝ :=
  l.output.budget (l.merged x angle cache) (l.targetMerged target angleTarget cacheTarget)
    (l.mergedBudgets x target error angle angleTarget angleError cache cacheTarget cacheError)

structure Layer.Finite (l : Layer) (x : Fin 5120 → BF) (angle : RopeAngles.Inputs) (cache : Cache BF n) : Prop where
  projections : l.projections.Finite x
  preparation : l.preparation.Finite (l.projections.forward x) angle
  readRange : ∀ h, ReadRange l.attention l.mergeContracted l.architectureSuffix ((l.heads x angle).query h)
    ((l.cacheAfter x angle cache).keys (SdpaScore.kvHead h)) ((l.cacheAfter x angle cache).values (SdpaScore.kvHead h))
  gateValid : ∀ h i, OutputGate.Valid l.gate ((l.heads x angle).gate h i)
  gateProduct : ∀ h i, OutputGate.ProductFinite l.gate (l.read x angle cache h i) ((l.heads x angle).gate h i)
  output : l.output.Finite (l.merged x angle cache)

theorem Layer.heads_error (l : Layer) (x : Fin 5120 → BF) (target error : Fin 5120 → ℝ)
    (angle : RopeAngles.Inputs) (angleTarget angleError : RopeAngles.Target) (cache : Cache BF n)
    (hi : ∀ i, |Model.toReal (x i) - target i| ≤ error i) (hf : l.Finite x angle cache)
    (ha : RopeAngles.InputError angle angleTarget angleError) (hb : 0 ≤ angleTarget.base) :
    AttentionHeads.Error (l.heads x angle) (l.targetHeads target angleTarget) (l.headBudgets x target error angle angleTarget angleError) :=
  AttentionHeads.projected_preparation_error l.projections l.preparation x target error angle angleTarget angleError
    hi hf.projections hf.preparation ha hb

theorem Layer.heads_finite (l : Layer) (x : Fin 5120 → BF) (angle : RopeAngles.Inputs) (cache : Cache BF n)
    (hf : l.Finite x angle cache) : AttentionHeads.Finite (l.heads x angle) :=
  l.preparation.forward_finite _ angle (l.projections.forward_finite x hf.projections) hf.preparation

theorem Layer.cache_error (l : Layer) (x : Fin 5120 → BF) (target error : Fin 5120 → ℝ)
    (angle : RopeAngles.Inputs) (angleTarget angleError : RopeAngles.Target)
    (cache : Cache BF n) (cacheTarget cacheError : Cache ℝ n)
    (hi : ∀ i, |Model.toReal (x i) - target i| ≤ error i) (hc : State.Kv.Error cache cacheTarget cacheError)
    (hf : l.Finite x angle cache) (ha : RopeAngles.InputError angle angleTarget angleError) (hb : 0 ≤ angleTarget.base) :
    State.Kv.Error (l.cacheAfter x angle cache) (l.targetCacheAfter target angleTarget cacheTarget)
      (l.cacheBudgets x target error angle angleTarget angleError cacheError) := by
  have hh := l.heads_error x target error angle angleTarget angleError cache hi hf ha hb
  exact State.Kv.append_error cache cacheTarget cacheError _ _ _ _ _ _ hc hh.key hh.value

theorem Layer.cache_finite (l : Layer) (x : Fin 5120 → BF) (angle : RopeAngles.Inputs) (cache : Cache BF n)
    (hc : State.Kv.Finite cache) (hf : l.Finite x angle cache) : State.Kv.Finite (l.cacheAfter x angle cache) := by
  have hh := l.heads_finite x angle cache hf
  exact State.Kv.append_finite cache _ _ hc hh.key hh.value

theorem Layer.read_finite_contract (l : Layer) (x : Fin 5120 → BF) (angle : RopeAngles.Inputs) (cache : Cache BF n)
    (_hc : State.Kv.Finite cache) (hf : l.Finite x angle cache) (h : Fin 24) :
    SdpaDispatched.Finite l.attention l.mergeContracted l.architectureSuffix ((l.heads x angle).query h)
      ((l.cacheAfter x angle cache).keys (SdpaScore.kvHead h)) ((l.cacheAfter x angle cache).values (SdpaScore.kvHead h)) := by
  exact hf.readRange h

theorem Layer.read_error (l : Layer) (x : Fin 5120 → BF) (target error : Fin 5120 → ℝ)
    (angle : RopeAngles.Inputs) (angleTarget angleError : RopeAngles.Target)
    (cache : Cache BF n) (cacheTarget cacheError : Cache ℝ n)
    (hi : ∀ i, |Model.toReal (x i) - target i| ≤ error i) (hc : State.Kv.Error cache cacheTarget cacheError)
    (hcf : State.Kv.Finite cache) (hf : l.Finite x angle cache)
    (ha : RopeAngles.InputError angle angleTarget angleError) (hb : 0 ≤ angleTarget.base) (h : Fin 24) (i : Fin 256) :
    |Model.toReal (l.read x angle cache h i) - l.targetRead target angleTarget cacheTarget h i| ≤
      l.readBudgets x target error angle angleTarget angleError cache cacheTarget cacheError h i := by
  have hh := l.heads_error x target error angle angleTarget angleError cache hi hf ha hb
  have hk := l.cache_error x target error angle angleTarget angleError cache cacheTarget cacheError hi hc hf ha hb
  exact SdpaDispatched.forward_error l.attention l.mergeContracted l.architectureSuffix _ _ _ _ _ _ _ _ _
    ⟨hh.query h, hk.keys (SdpaScore.kvHead h), hk.values (SdpaScore.kvHead h)⟩
    (l.read_finite_contract x angle cache hcf hf h) (Nat.succ_pos n) i

theorem Layer.read_finite (l : Layer) (x : Fin 5120 → BF) (angle : RopeAngles.Inputs) (cache : Cache BF n)
    (hc : State.Kv.Finite cache) (hf : l.Finite x angle cache) (h : Fin 24) (i : Fin 256) :
    Model.isFinite (l.read x angle cache h i) = true :=
  SdpaDispatched.forward_finite l.attention l.mergeContracted l.architectureSuffix _ _ _ (l.read_finite_contract x angle cache hc hf h) i

theorem Layer.gated_error (l : Layer) (x : Fin 5120 → BF) (target error : Fin 5120 → ℝ)
    (angle : RopeAngles.Inputs) (angleTarget angleError : RopeAngles.Target)
    (cache : Cache BF n) (cacheTarget cacheError : Cache ℝ n)
    (hi : ∀ i, |Model.toReal (x i) - target i| ≤ error i) (hc : State.Kv.Error cache cacheTarget cacheError)
    (hcf : State.Kv.Finite cache) (hf : l.Finite x angle cache)
    (ha : RopeAngles.InputError angle angleTarget angleError) (hb : 0 ≤ angleTarget.base) (h : Fin 24) (i : Fin 256) :
    |Model.toReal (l.gated x angle cache h i) - l.targetGated target angleTarget cacheTarget h i| ≤
      l.gatedBudgets x target error angle angleTarget angleError cache cacheTarget cacheError h i := by
  have hh := l.heads_error x target error angle angleTarget angleError cache hi hf ha hb
  exact OutputGate.forward_error l.gate _ _ _ _ _ _ (l.read_finite x angle cache hcf hf h i)
    (l.heads_finite x angle cache hf |>.gate h i) (hf.gateValid h i) (hf.gateProduct h i)
    (l.read_error x target error angle angleTarget angleError cache cacheTarget cacheError hi hc hcf hf ha hb h i) (hh.gate h i)

-- Complete Qwen3Attention decode arithmetic, including the appended cache,
-- grouped-query routing, output sigmoid/multiply and affine output projection.
-- The one-token, plain-cache route selects the proved one-/two-pass reader
-- using the pinned native dispatch predicates and default block counts.
theorem Layer.forward_error (l : Layer) (x : Fin 5120 → BF) (target error : Fin 5120 → ℝ)
    (angle : RopeAngles.Inputs) (angleTarget angleError : RopeAngles.Target)
    (cache : Cache BF n) (cacheTarget cacheError : Cache ℝ n)
    (hi : ∀ i, |Model.toReal (x i) - target i| ≤ error i) (hc : State.Kv.Error cache cacheTarget cacheError)
    (hcf : State.Kv.Finite cache) (hf : l.Finite x angle cache)
    (ha : RopeAngles.InputError angle angleTarget angleError) (hb : 0 ≤ angleTarget.base) (i : Fin 5120) :
    |Model.toReal (l.forward x angle cache i) - l.target target angleTarget cacheTarget i| ≤
      l.budget x target error angle angleTarget angleError cache cacheTarget cacheError i := by
  apply l.output.forward_error _ _ _ _ hf.output i
  intro j
  exact l.gated_error x target error angle angleTarget angleError cache cacheTarget cacheError hi hc hcf hf ha hb (headIndex j) (coordinate j)

theorem Layer.forward_finite (l : Layer) (x : Fin 5120 → BF) (angle : RopeAngles.Inputs) (cache : Cache BF n)
    (hf : l.Finite x angle cache) (i : Fin 5120) : Model.isFinite (l.forward x angle cache i) = true :=
  l.output.forward_finite _ hf.output i

end Inference.Models.Qwen.Attention
