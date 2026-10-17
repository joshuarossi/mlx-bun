import models.qwen.DecodeChainScheduled
import models.qwen.Qwen38TrellisM1MaxMagnitude

namespace Inference.Models.Qwen.Qwen38TrellisM1MaxScheduled
open DecodeStage Kernels.Attention Qwen38TrellisM1Max
open FloatLib FloatLib.Floats FloatLib.Floats.Formats.BinaryInterchange
set_option maxRecDepth 10000

abbrev Execution (g : Graph) (c : g.Cache n) (x : Row BF) (a : RopeAngles.Inputs) :=
  DecodeChainScheduled.Execution g.stages c x a

def run (g : Graph) (c : g.Cache n) (x : Row BF) (a : RopeAngles.Inputs)
    (execution : Execution g c x a) : (Fin 248320 → BF) × g.Cache (n+1) :=
  let chain := DecodeChainScheduled.run g.stages c x a execution
  (g.output.forward (g.finalNorm.forward chain.1), chain.2)

theorem run_eq (g : Graph) (c : g.Cache n) (x : Row BF) (a : RopeAngles.Inputs)
    (execution : Execution g c x a) :
    run g c x a execution=(g.forward c x a, (DecodeChain.run g.stages c x a).2) := by
  unfold run
  rw [DecodeChainScheduled.run_eq]
  rfl

theorem forward_error (g : Graph) (c : g.Cache n) (ct ce : g.ReferenceCache n)
    (x : Row BF) (t e : Row ℝ) (a : RopeAngles.Inputs) (aim ae : RopeAngles.Target)
    (execution : Execution g c x a)
    (hi : ∀ i, |Model.toReal (x i)-t i| ≤ e i) (hif : ∀ i, Model.isFinite (x i)=true)
    (hc : DecodeChain.CacheErrors g.stages c ct ce) (hcf : DecodeChain.CachesFinite g.stages c)
    (hf : g.Ranges c x a) (ha : RopeAngles.InputError a aim ae) (hb : 0 ≤ aim.base)
    (capacity : DecodeChain.Capacities g.stages c ct ce x t e a aim ae hf.chain) (i : Fin 248320) :
    |Model.toReal ((run g c x a execution).1 i)-g.target ct t aim i| ≤ g.budget c ct ce x t e a aim ae hf i := by
  rw [run_eq]
  exact g.forward_error c ct ce x t e a aim ae hi hif hc hcf hf ha hb capacity i

theorem output_bound (g : Graph) (parameters : Qwen38TrellisM1MaxSequenceRanges.Parameters g)
    (primitive : Qwen38TrellisM1MaxSequenceRanges.Primitives g)
    (c : g.Cache time) (hc : DecodeChainSequenceRanges.CachesBound g.stages c)
    (x : Row BF) (hx : ResidualMlpRanges.InputBound 0 x) (a : RopeAngles.Inputs)
    (ha : RopeAnglesRanges.InputsBound a) (supported : time+1 ≤ 262144) (execution : Execution g c x a) :
    ∀ i, Model.isFinite ((run g c x a execution).1 i)=true ∧
      |Model.toReal ((run g c x a execution).1 i)| ≤ (2 : ℝ)^18 := by
  rw [run_eq]
  exact Qwen38TrellisM1MaxMagnitude.graph_output g parameters primitive c hc x hx a ha supported

end Inference.Models.Qwen.Qwen38TrellisM1MaxScheduled
