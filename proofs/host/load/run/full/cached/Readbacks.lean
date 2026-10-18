import host.load.run.full.cached.Result
import host.load.run.full.cached.Observations
import host.load.run.full.RecurrenceReadbacks
namespace Host.Load.Run.Full.Cached
open Host.Load.Extract Host.Load.Program Host.Mlx Host.Mlx.GlueStep Host.Mlx.FfiEval Host.Ts
open Inference.Models.Qwen
set_option Elab.async false
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
variable {C : Inference.Contracts.Mlx.M1Max.Contract} (M : MlxContract C) (K : KernelContract C)
    (env : FfiEval.Env InKey) (leaves : Leaves code env.weights) (typed : TypedCheckpoint env.weights)
    (parameters : TokenSequenceRanges.Parameters (firstPipeline M K env [] leaves typed))

noncomputable def finalRecurrenceTable (maxTokens : Nat) : List F64 :=
  P.S3575.tab.map (SymE.eval (recurrenceValuation M K env leaves typed parameters maxTokens))

/-- The mathematical pipeline is fixed before assigning native symbols.
Each symbol then denotes its already-computed recurrence token. -/
theorem terminal_token_read (maxTokens : Nat) (i : Fin 5) (cs : List Cache) (node : Nat)
    (result : ForwardResult M K env (finalRecurrenceTable M K env leaves typed parameters maxTokens)
      leaves typed (parameters_for_table M K env leaves typed parameters _) (i.val+1) (by omega) cs node) :
    let table := finalRecurrenceTable M K env leaves typed parameters maxTokens
    TokenRead M K env (CSrv.val ⟨table⟩) (terminalGraph table) node (.ref (i.val+1))
      ((firstContext M K env [] leaves typed parameters).run promptToken (i.val+1) (by omega)).token.val := by
  dsimp only
  let table := finalRecurrenceTable M K env leaves typed parameters maxTokens
  let hp := parameters_for_table M K env leaves typed parameters table
  obtain ⟨hs,hr,hh,hc⟩ := result
  have he := recurrence_token_table_eq M K env table [] leaves typed hp parameters (i.val+1) (by omega)
  rw [he] at hr
  refine ⟨hr,?_⟩
  have mem : i.val+1 ∈ [1,2,3,4,5] := by fin_cases i <;> decide
  rw [val_inst (ρ := recurrenceValuation M K env leaves typed parameters maxTokens)
    (S := P.S3575) (C := ⟨table⟩) rfl (.ref (i.val+1)),final_read_expression _ mem]
  simp only [Option.map_some,SymE.eval,recurrenceValuation,dite_eq_left (show i.val+1 ≤ 262144 by omega)]

end Host.Load.Run.Full.Cached
