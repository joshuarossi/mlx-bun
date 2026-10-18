import host.load.run.full.cached.All
import host.load.run.full.cached.Readbacks
namespace Host.Load.Run.Full.Cached
open Host.Load.Extract Host.Load.Program Host.Mlx Host.Mlx.GlueStep Host.Mlx.FfiEval Host.Ts
open Inference.Models.Qwen
set_option Elab.async false
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
variable {C : Inference.Contracts.Mlx.M1Max.Contract} (M : MlxContract C) (K : KernelContract C)
    (env : FfiEval.Env InKey) (leaves : Leaves code env.weights) (typed : TypedCheckpoint env.weights)
    (parameters : TokenSequenceRanges.Parameters (firstPipeline M K env [] leaves typed))

/-- Every native memo entry in the completed actual source route has the
value computed by that same checkpoint recurrence. -/
theorem terminal_memo_values (maxTokens : Nat) :
    let table := finalRecurrenceTable M K env leaves typed parameters maxTokens
    ReadbackValues M K env (CSrv.val ⟨table⟩) (terminalGraph table) P.s3575.ffi.mlx.items := by
  dsimp only
  let table := finalRecurrenceTable M K env leaves typed parameters maxTokens
  let hp := parameters_for_table M K env leaves typed parameters table
  obtain ⟨one,two,three,four,five⟩ := terminal_all_five M K env table leaves typed hp
  let tok (i : Fin 5) := ((firstContext M K env [] leaves typed parameters).run promptToken (i.val+1) (by omega)).token.val
  have bound (i : Fin 5) : tok i < 2^31 := by
    have small := ((firstContext M K env [] leaves typed parameters).run promptToken (i.val+1) (by omega)).token.isLt
    dsimp only [tok]
    omega
  have initial := ReadbackValues.empty M K env (CSrv.val ⟨table⟩) (terminalGraph table)
  have a := ReadbackValues.set M K env (CSrv.val ⟨table⟩) (terminalGraph table) initial 17776 (.ref 1) (tok 0)
    (by decide) (bound 0) (terminal_token_read M K env leaves typed parameters maxTokens 0 firstChoice.cache 17776 one)
  have b := ReadbackValues.set M K env (CSrv.val ⟨table⟩) (terminalGraph table) a 20157 (.ref 2) (tok 1)
    (by decide) (bound 1) (terminal_token_read M K env leaves typed parameters maxTokens 1 after2.cache 20157 two)
  have c := ReadbackValues.set M K env (CSrv.val ⟨table⟩) (terminalGraph table) b 22538 (.ref 3) (tok 2)
    (by decide) (bound 2) (terminal_token_read M K env leaves typed parameters maxTokens 2 after3.cache 22538 three)
  have d := ReadbackValues.set M K env (CSrv.val ⟨table⟩) (terminalGraph table) c 24919 (.ref 4) (tok 3)
    (by decide) (bound 3) (terminal_token_read M K env leaves typed parameters maxTokens 3 after4.cache 24919 four)
  have e := ReadbackValues.set M K env (CSrv.val ⟨table⟩) (terminalGraph table) d 27300 (.ref 5) (tok 4)
    (by decide) (bound 4) (terminal_token_read M K env leaves typed parameters maxTokens 4 after5.cache 27300 five)
  rw [final_read_memo]
  exact e
end Host.Load.Run.Full.Cached
