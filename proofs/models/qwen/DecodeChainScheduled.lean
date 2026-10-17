import models.qwen.DecodeStageScheduled
import models.qwen.DecodeChain

namespace Inference.Models.Qwen.DecodeChainScheduled
open DecodeStage DecodeChain Kernels.Attention
open FloatLib FloatLib.Floats FloatLib.Floats.Formats.BinaryInterchange
set_option maxRecDepth 10000

-- The tail is indexed by the output actually produced by the scheduled
-- predecessor. There is no caller-supplied intermediate-input equality.
def Execution : (stages : List Stage) → Caches stages n → Row BF → RopeAngles.Inputs → Type
  | [], _, _, _ => PUnit
  | s::rest, c, x, a =>
    (first : DecodeStageScheduled.Execution s c.1 x a) ×
      Execution rest c.2 (DecodeStageScheduled.forward s c.1 x a first) a

def Execution.canonical : (stages : List Stage) → (c : Caches stages n) → (x : Row BF) →
    (a : RopeAngles.Inputs) → Execution stages c x a
  | [], _, _, _ => ⟨⟩
  | s::rest, c, x, a =>
    let first := DecodeStageScheduled.Execution.canonical s c.1 x a
    ⟨first, Execution.canonical rest c.2 (DecodeStageScheduled.forward s c.1 x a first) a⟩

def run : (stages : List Stage) → (c : Caches stages n) → (x : Row BF) → (a : RopeAngles.Inputs) →
    Execution stages c x a → Row BF × Caches stages (n+1)
  | [], _, x, _, _ => (x, ⟨⟩)
  | s::rest, c, x, a, execution =>
    let tail := run rest c.2 (DecodeStageScheduled.forward s c.1 x a execution.1) a execution.2
    (tail.1, (cacheAfter s c.1 x a, tail.2))

-- Equality includes every returned cache slot, not only the final row.
theorem run_eq (stages : List Stage) (c : Caches stages n) (x : Row BF) (a : RopeAngles.Inputs)
    (execution : Execution stages c x a) : run stages c x a execution=DecodeChain.run stages c x a := by
  induction stages generalizing x with
  | nil => rfl
  | cons s rest ih =>
    have tail := ih c.2 (DecodeStageScheduled.forward s c.1 x a execution.1) execution.2
    simp only [run, tail, DecodeStageScheduled.forward_eq, DecodeChain.run]

theorem run_correct (stages : List Stage) (c : Caches stages n) (ct ce : ReferenceCaches stages n)
    (x : Row BF) (t e : Row ℝ) (a : RopeAngles.Inputs) (aim ae : RopeAngles.Target)
    (execution : Execution stages c x a)
    (hi : ∀ i, |Model.toReal (x i)-t i| ≤ e i) (hif : ∀ i, Model.isFinite (x i)=true)
    (hc : CacheErrors stages c ct ce) (hcf : CachesFinite stages c)
    (hf : Ranges stages c x a) (ha : RopeAngles.InputError a aim ae) (hb : 0 ≤ aim.base)
    (capacity : Capacities stages c ct ce x t e a aim ae hf) :
    (∀ i, |Model.toReal ((run stages c x a execution).1 i)-(targetRun stages ct t aim).1 i| ≤
      (budgetRun stages c ct ce x t e a aim ae hf).1 i) ∧
    CacheErrors stages (run stages c x a execution).2 (targetRun stages ct t aim).2 (budgetRun stages c ct ce x t e a aim ae hf).2 ∧
    (∀ i, Model.isFinite ((run stages c x a execution).1 i)=true) ∧ CachesFinite stages (run stages c x a execution).2 := by
  rw [run_eq]
  exact DecodeChain.run_correct stages c ct ce x t e a aim ae hi hif hc hcf hf ha hb capacity

end Inference.Models.Qwen.DecodeChainScheduled
