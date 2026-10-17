import models.qwen.DecodeChain

namespace Inference.Models.Qwen.Qwen38TrellisM1Max
open Contracts.Mlx
open FloatLib FloatLib.Floats FloatLib.Floats.Formats.BinaryInterchange
open Kernels.Attention DecodeStage

-- The one-row graph has 48 Delta layers and 16 full-attention layers in this
-- written order. Parameters are the loaded, specialized layers; binding them
-- to the checkpoint bytes remains a separate source/artifact obligation.
structure Graph where
  delta : Fin 48 → ResidualDelta.Layer
  attention : Fin 16 → ResidualAttention.Layer
  finalNorm : Blocks.Norm
  output : Layers.AffineVerifyLinear.Projection 10 248320

def Graph.stages (g : Graph) : List Stage := [
  .delta (g.delta 0), .delta (g.delta 1), .delta (g.delta 2), .attention (g.attention 0),
  .delta (g.delta 3), .delta (g.delta 4), .delta (g.delta 5), .attention (g.attention 1),
  .delta (g.delta 6), .delta (g.delta 7), .delta (g.delta 8), .attention (g.attention 2),
  .delta (g.delta 9), .delta (g.delta 10), .delta (g.delta 11), .attention (g.attention 3),
  .delta (g.delta 12), .delta (g.delta 13), .delta (g.delta 14), .attention (g.attention 4),
  .delta (g.delta 15), .delta (g.delta 16), .delta (g.delta 17), .attention (g.attention 5),
  .delta (g.delta 18), .delta (g.delta 19), .delta (g.delta 20), .attention (g.attention 6),
  .delta (g.delta 21), .delta (g.delta 22), .delta (g.delta 23), .attention (g.attention 7),
  .delta (g.delta 24), .delta (g.delta 25), .delta (g.delta 26), .attention (g.attention 8),
  .delta (g.delta 27), .delta (g.delta 28), .delta (g.delta 29), .attention (g.attention 9),
  .delta (g.delta 30), .delta (g.delta 31), .delta (g.delta 32), .attention (g.attention 10),
  .delta (g.delta 33), .delta (g.delta 34), .delta (g.delta 35), .attention (g.attention 11),
  .delta (g.delta 36), .delta (g.delta 37), .delta (g.delta 38), .attention (g.attention 12),
  .delta (g.delta 39), .delta (g.delta 40), .delta (g.delta 41), .attention (g.attention 13),
  .delta (g.delta 42), .delta (g.delta 43), .delta (g.delta 44), .attention (g.attention 14),
  .delta (g.delta 45), .delta (g.delta 46), .delta (g.delta 47), .attention (g.attention 15)]

theorem Graph.layer_count (g : Graph) : g.stages.length = 64 := rfl

def isAttention : Stage → Bool
  | .delta _ => false
  | .attention _ => true
theorem Graph.attention_count (g : Graph) : (g.stages.filter isAttention).length = 16 := rfl
theorem Graph.delta_count (g : Graph) : (g.stages.filter (fun s => !isAttention s)).length = 48 := rfl

abbrev Graph.Cache (g : Graph) (n : Nat) := DecodeChain.Caches g.stages n
abbrev Graph.ReferenceCache (g : Graph) (n : Nat) := DecodeChain.ReferenceCaches g.stages n

def Graph.hidden (g : Graph) (c : g.Cache n) (x : Row BF) (a : RopeAngles.Inputs) : Row BF :=
  (DecodeChain.run g.stages c x a).1
noncomputable def Graph.targetHidden (g : Graph) (c : g.ReferenceCache n) (x : Row ℝ) (a : RopeAngles.Target) : Row ℝ :=
  (DecodeChain.targetRun g.stages c x a).1
def Graph.normalized (g : Graph) (c : g.Cache n) (x : Row BF) (a : RopeAngles.Inputs) : Row BF :=
  g.finalNorm.forward (g.hidden c x a)
noncomputable def Graph.targetNormalized (g : Graph) (c : g.ReferenceCache n) (x : Row ℝ) (a : RopeAngles.Target) : Row ℝ :=
  g.finalNorm.target (g.targetHidden c x a)
def Graph.forward (g : Graph) (c : g.Cache n) (x : Row BF) (a : RopeAngles.Inputs) : Fin 248320 → BF :=
  g.output.forward (g.normalized c x a)
noncomputable def Graph.target (g : Graph) (c : g.ReferenceCache n) (x : Row ℝ) (a : RopeAngles.Target) : Fin 248320 → ℝ :=
  g.output.target (g.targetNormalized c x a)

structure Graph.Ranges (g : Graph) (c : g.Cache n) (x : Row BF) (a : RopeAngles.Inputs) where
  chain : DecodeChain.Ranges g.stages c x a
  finalWeight : ∀ i, Model.isFinite (g.finalNorm.weight i) = true
  finalNorm : g.finalNorm.Finite (g.hidden c x a)
  output : g.output.Finite (g.normalized c x a)

noncomputable def Graph.hiddenBudget (g : Graph) (c : g.Cache n) (ct ce : g.ReferenceCache n)
    (x : Row BF) (t e : Row ℝ) (a : RopeAngles.Inputs) (aim ae : RopeAngles.Target) (hf : g.Ranges c x a) : Row ℝ :=
  (DecodeChain.budgetRun g.stages c ct ce x t e a aim ae hf.chain).1
noncomputable def Graph.normalizedBudget (g : Graph) (c : g.Cache n) (ct ce : g.ReferenceCache n)
    (x : Row BF) (t e : Row ℝ) (a : RopeAngles.Inputs) (aim ae : RopeAngles.Target) (hf : g.Ranges c x a) : Row ℝ :=
  g.finalNorm.errorBudget (g.hidden c x a) (g.targetHidden ct t aim) (g.hiddenBudget c ct ce x t e a aim ae hf)
noncomputable def Graph.budget (g : Graph) (c : g.Cache n) (ct ce : g.ReferenceCache n)
    (x : Row BF) (t e : Row ℝ) (a : RopeAngles.Inputs) (aim ae : RopeAngles.Target) (hf : g.Ranges c x a) : Fin 248320 → ℝ :=
  g.output.budget (g.normalized c x a) (g.targetNormalized ct t aim) (g.normalizedBudget c ct ce x t e a aim ae hf)

theorem Graph.forward_error (g : Graph) (c : g.Cache n) (ct ce : g.ReferenceCache n)
    (x : Row BF) (t e : Row ℝ) (a : RopeAngles.Inputs) (aim ae : RopeAngles.Target)
    (hi : ∀ i, |Model.toReal (x i) - t i| ≤ e i) (hif : ∀ i, Model.isFinite (x i) = true)
    (hc : DecodeChain.CacheErrors g.stages c ct ce) (hcf : DecodeChain.CachesFinite g.stages c)
    (hf : g.Ranges c x a) (ha : RopeAngles.InputError a aim ae) (hb : 0 ≤ aim.base)
    (capacity : DecodeChain.Capacities g.stages c ct ce x t e a aim ae hf.chain) (i : Fin 248320) :
    |Model.toReal (g.forward c x a i) - g.target ct t aim i| ≤ g.budget c ct ce x t e a aim ae hf i := by
  have h := DecodeChain.run_correct g.stages c ct ce x t e a aim ae hi hif hc hcf hf.chain ha hb capacity
  apply g.output.forward_error _ _ _ _ hf.output i
  intro j
  exact g.finalNorm.forward_error (g.hidden c x a) (g.targetHidden ct t aim) (g.hiddenBudget c ct ce x t e a aim ae hf)
    h.1 h.2.2.1 hf.finalWeight hf.finalNorm j

theorem Graph.forward_finite (g : Graph) (c : g.Cache n) (x : Row BF) (a : RopeAngles.Inputs)
    (hf : g.Ranges c x a) (i : Fin 248320) : Model.isFinite (g.forward c x a i) = true :=
  g.output.forward_finite _ hf.output i

-- Every cache is returned with the error bound from the input actually seen
-- by its layer. This supplies the invariant needed for the next decode step.
theorem Graph.cache_error (g : Graph) (c : g.Cache n) (ct ce : g.ReferenceCache n)
    (x : Row BF) (t e : Row ℝ) (a : RopeAngles.Inputs) (aim ae : RopeAngles.Target)
    (hi : ∀ i, |Model.toReal (x i) - t i| ≤ e i) (hif : ∀ i, Model.isFinite (x i) = true)
    (hc : DecodeChain.CacheErrors g.stages c ct ce) (hcf : DecodeChain.CachesFinite g.stages c)
    (hf : g.Ranges c x a) (ha : RopeAngles.InputError a aim ae) (hb : 0 ≤ aim.base)
    (capacity : DecodeChain.Capacities g.stages c ct ce x t e a aim ae hf.chain) :
    DecodeChain.CacheErrors g.stages (DecodeChain.run g.stages c x a).2 (DecodeChain.targetRun g.stages ct t aim).2
      (DecodeChain.budgetRun g.stages c ct ce x t e a aim ae hf.chain).2 ∧
    DecodeChain.CachesFinite g.stages (DecodeChain.run g.stages c x a).2 := by
  have h := DecodeChain.run_correct g.stages c ct ce x t e a aim ae hi hif hc hcf hf.chain ha hb capacity
  exact ⟨h.2.1, h.2.2.2⟩

end Inference.Models.Qwen.Qwen38TrellisM1Max
