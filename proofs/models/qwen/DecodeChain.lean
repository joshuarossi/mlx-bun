import models.qwen.DecodeStage

namespace Inference.Models.Qwen.DecodeChain
open DecodeStage
open FloatLib FloatLib.Floats FloatLib.Floats.Formats.BinaryInterchange
open Kernels.Attention

def Caches : List Stage → Nat → Type
  | [], _ => PUnit
  | s::rest, n => Cache s n × Caches rest n
def ReferenceCaches : List Stage → Nat → Type
  | [], _ => PUnit
  | s::rest, n => ReferenceCache s n × ReferenceCaches rest n
def CacheErrors : (stages : List Stage) → Caches stages n → ReferenceCaches stages n → ReferenceCaches stages n → Prop
  | [], _, _, _ => True
  | s::rest, c, t, e => CacheError s c.1 t.1 e.1 ∧ CacheErrors rest c.2 t.2 e.2
def CachesFinite : (stages : List Stage) → Caches stages n → Prop
  | [], _ => True
  | s::rest, c => CacheFinite s c.1 ∧ CachesFinite rest c.2

def run : (stages : List Stage) → Caches stages n → Row BF → RopeAngles.Inputs → Row BF × Caches stages (n+1)
  | [], _, x, _ => (x, ⟨⟩)
  | s::rest, c, x, a =>
    let tail := run rest c.2 (forward s c.1 x a) a
    (tail.1, (cacheAfter s c.1 x a, tail.2))
noncomputable def targetRun : (stages : List Stage) → ReferenceCaches stages n → Row ℝ → RopeAngles.Target → Row ℝ × ReferenceCaches stages (n+1)
  | [], _, x, _ => (x, ⟨⟩)
  | s::rest, c, x, a =>
    let tail := targetRun rest c.2 (target s c.1 x a) a
    (tail.1, (targetCacheAfter s c.1 x a, tail.2))

-- Each next layer's ranges refer to the actual output of its predecessor.
-- No layer-accuracy premise appears in this recursively composed obligation.
def Ranges : (stages : List Stage) → Caches stages n → Row BF → RopeAngles.Inputs → Type
  | [], _, _, _ => PUnit
  | s::rest, c, x, a => Finite s c.1 x a × Ranges rest c.2 (forward s c.1 x a) a

noncomputable def budgetRun : (stages : List Stage) → (c : Caches stages n) →
    ReferenceCaches stages n → ReferenceCaches stages n → (x : Row BF) → Row ℝ → Row ℝ →
    (a : RopeAngles.Inputs) → RopeAngles.Target → RopeAngles.Target → Ranges stages c x a → Row ℝ × ReferenceCaches stages (n+1)
  | [], _, _, _, _, _, e, _, _, _, _ => (e, ⟨⟩)
  | s::rest, c, ct, ce, x, t, e, a, aim, ae, hf =>
    let tail := budgetRun rest c.2 ct.2 ce.2 (forward s c.1 x a) (target s ct.1 t aim)
      (budget s c.1 ct.1 ce.1 x t e a aim ae hf.1) a aim ae hf.2
    (tail.1, (cacheBudget s c.1 ct.1 ce.1 x t e a aim ae, tail.2))

def Capacities : (stages : List Stage) → (c : Caches stages n) →
    ReferenceCaches stages n → ReferenceCaches stages n → (x : Row BF) → Row ℝ → Row ℝ →
    (a : RopeAngles.Inputs) → RopeAngles.Target → RopeAngles.Target → Ranges stages c x a → Prop
  | [], _, _, _, _, _, _, _, _, _, _ => True
  | s::rest, c, ct, ce, x, t, e, a, aim, ae, hf =>
    Capacity s c.1 ct.1 ce.1 x t e a aim ae hf.1 ∧
      Capacities rest c.2 ct.2 ce.2 (forward s c.1 x a) (target s ct.1 t aim)
        (budget s c.1 ct.1 ce.1 x t e a aim ae hf.1) a aim ae hf.2

-- Both the final hidden state and every returned cache slot are related to
-- their real-valued mathematical execution. Error budgets are constructed by
-- the kernel/layer proofs; the inductive step does not assume exact arithmetic.
theorem run_correct (stages : List Stage) (c : Caches stages n) (ct ce : ReferenceCaches stages n)
    (x : Row BF) (t e : Row ℝ) (a : RopeAngles.Inputs) (aim ae : RopeAngles.Target)
    (hi : ∀ i, |Model.toReal (x i) - t i| ≤ e i) (hif : ∀ i, Model.isFinite (x i) = true)
    (hc : CacheErrors stages c ct ce) (hcf : CachesFinite stages c)
    (hf : Ranges stages c x a) (ha : RopeAngles.InputError a aim ae) (hb : 0 ≤ aim.base)
    (capacity : Capacities stages c ct ce x t e a aim ae hf) :
    (∀ i, |Model.toReal ((run stages c x a).1 i) - (targetRun stages ct t aim).1 i| ≤
      (budgetRun stages c ct ce x t e a aim ae hf).1 i) ∧
    CacheErrors stages (run stages c x a).2 (targetRun stages ct t aim).2 (budgetRun stages c ct ce x t e a aim ae hf).2 ∧
    (∀ i, Model.isFinite ((run stages c x a).1 i) = true) ∧ CachesFinite stages (run stages c x a).2 := by
  induction stages generalizing x t e with
  | nil => exact ⟨hi, trivial, hif, trivial⟩
  | cons s rest ih =>
    have hs := DecodeStage.forward_error s c.1 ct.1 ce.1 x t e a aim ae hi hc.1 hcf.1 hf.1 ha hb capacity.1
    have hsf := DecodeStage.forward_finite s c.1 ct.1 ce.1 x t e a aim ae hi hc.1 hcf.1 hf.1 ha hb capacity.1
    have ht := ih c.2 ct.2 ce.2 (forward s c.1 x a) (target s ct.1 t aim)
      (budget s c.1 ct.1 ce.1 x t e a aim ae hf.1) hs hsf hc.2 hcf.2 hf.2 capacity.2
    exact ⟨ht.1, ⟨DecodeStage.cache_error s c.1 ct.1 ce.1 x t e a aim ae hi hc.1 hf.1 ha hb, ht.2.1⟩,
      ht.2.2.1, ⟨DecodeStage.cache_finite s c.1 x a hcf.1 hf.1, ht.2.2.2⟩⟩

end Inference.Models.Qwen.DecodeChain
