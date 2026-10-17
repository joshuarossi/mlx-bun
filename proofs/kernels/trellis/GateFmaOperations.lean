import kernels.trellis.GatePointerPipeline
import kernels.trellis.GateUpFlushToZero
namespace Inference.Kernels.Trellis.GateFmaOperations
open Contracts.Mlx GateAccumulateSource
set_option maxRecDepth 10000

-- The parsed Metal intrinsic's scalar lowering is explicit. This addition
-- keeps the frozen standard interpretation and adds an FTZ interpretation
-- without identifying their results or changing the four assignment order.
abbrev Fma := Float32 → Float32 → Float32 → Float32

def assign (fma : Fma) (statement : Assignment) (environment : Environment) : Option Environment := do
  let weight ←environment statement.weight
  let input ←environment statement.input
  let accumulator ←environment statement.accumulator
  let value:=fma weight input accumulator
  pure (fun name => if name=statement.target then some value else environment name)

def execute (fma : Fma) : List Assignment → Environment → Option Environment
  | [],environment => some environment
  | first::rest,environment => (assign fma first environment).bind (execute fma rest)

def run (fma : Fma) (j : Nat) (environment : Environment) : Option Environment :=
  (parse source).bind (fun actual => (test j actual.condition).bind (fun odd =>
    execute fma (if odd then actual.yes else actual.no) environment))

def step (fma : Fma) (j : Nat) (gateWeight upWeight input : Float32) (acc : Dual) : Option Dual :=
  (run fma j (environment gateWeight upWeight input acc)).bind observe

def accumulate (fma : Fma) (j : Nat) (weight input : Float32)
    (acc : GateUpExecution.Accumulators) : GateUpExecution.Accumulators :=
  if j%2=1 then (acc.1,fma weight input acc.2) else (fma weight input acc.1,acc.2)

theorem step_correct (fma : Fma) (j : Nat) (bound : j<32)
    (gateWeight upWeight input : Float32) (acc : Dual) :
    step fma j gateWeight upWeight input acc=some
      (accumulate fma j gateWeight input acc.1,accumulate fma j upWeight input acc.2) := by
  rw [step,run,parsed,Option.bind_some,test_selected ⟨j,bound⟩,Option.bind_some]
  by_cases odd : j%2=1 <;>
    simp [odd,code,execute,assign,environment,observe,accumulate]

theorem standard_step (j : Nat) (bound : j<32) (gateWeight upWeight input : Float32) (acc : Dual) :
    step Float32.fma j gateWeight upWeight input acc=GateAccumulateSource.step j gateWeight upWeight input acc := by
  rw [step_correct _ j bound,GateAccumulateSource.step_correct j bound]
  rfl

theorem flushing_step (j : Nat) (bound : j<32) (gateWeight upWeight input : Float32) (acc : Dual) :
    step FlushToZero.fma j gateWeight upWeight input acc=some
      (GateUpFlushToZero.accumulate j gateWeight input acc.1,
        GateUpFlushToZero.accumulate j upWeight input acc.2) := by
  rw [step_correct _ j bound]
  rfl

end Inference.Kernels.Trellis.GateFmaOperations
