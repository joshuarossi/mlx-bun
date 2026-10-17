import models.qwen.ResidualMlpScheduled
import models.qwen.DecodeStage

namespace Inference.Models.Qwen.DecodeStageScheduled
open DecodeStage Kernels.Attention
open FloatLib FloatLib.Floats FloatLib.Floats.Formats.BinaryInterchange
set_option maxRecDepth 10000

-- Each trace is indexed by the actual mixer result consumed by its MLP.
-- The mixer retains its existing translated semantics and contracts.
def Execution : (s : Stage) → Cache s n → Row BF → RopeAngles.Inputs → Type
  | .delta l, c, x, _ => ResidualMlpScheduled.Execution l.suffix x (l.mixed c (fun _ => x) 0)
  | .attention l, c, x, a => ResidualMlpScheduled.Execution l.suffix x (l.mixed x a c)

def Execution.canonical : (s : Stage) → (c : Cache s n) → (x : Row BF) →
    (a : RopeAngles.Inputs) → Execution s c x a
  | .delta l, c, x, _ => ResidualMlpScheduled.Execution.canonical l.suffix x (l.mixed c (fun _ => x) 0)
  | .attention l, c, x, a => ResidualMlpScheduled.Execution.canonical l.suffix x (l.mixed x a c)

def forward : (s : Stage) → (c : Cache s n) → (x : Row BF) → (a : RopeAngles.Inputs) →
    Execution s c x a → Row BF
  | .delta l, c, x, _, execution => ResidualMlpScheduled.forward l.suffix x (l.mixed c (fun _ => x) 0) execution
  | .attention l, c, x, a, execution => ResidualMlpScheduled.forward l.suffix x (l.mixed x a c) execution

theorem forward_eq (s : Stage) (c : Cache s n) (x : Row BF) (a : RopeAngles.Inputs)
    (execution : Execution s c x a) : forward s c x a execution=DecodeStage.forward s c x a := by
  cases s with
  | delta l => exact ResidualMlpScheduled.forward_eq l.suffix x (l.mixed c (fun _ => x) 0) execution
  | attention l => exact ResidualMlpScheduled.forward_eq l.suffix x (l.mixed x a c) execution

theorem forward_error (s : Stage) (c : Cache s n) (ct ce : ReferenceCache s n)
    (x : Row BF) (t e : Row ℝ) (a : RopeAngles.Inputs) (aim ae : RopeAngles.Target)
    (execution : Execution s c x a)
    (hi : ∀ i, |Model.toReal (x i)-t i| ≤ e i) (hc : CacheError s c ct ce) (hcf : CacheFinite s c)
    (hf : Finite s c x a) (ha : RopeAngles.InputError a aim ae) (hb : 0 ≤ aim.base)
    (capacity : Capacity s c ct ce x t e a aim ae hf) (i : Fin 5120) :
    |Model.toReal (forward s c x a execution i)-target s ct t aim i| ≤ budget s c ct ce x t e a aim ae hf i := by
  rw [forward_eq]
  exact DecodeStage.forward_error s c ct ce x t e a aim ae hi hc hcf hf ha hb capacity i

end Inference.Models.Qwen.DecodeStageScheduled
