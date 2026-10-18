import host.load.run.full.RecurrenceIndependence
import host.load.run.full.FirstReadbackFacts
set_option Elab.async false

namespace Host.Load.Run.Full
open Host.Load.Extract Host.Load.Program Host.Mlx Host.Mlx.FfiEval Host.Ts
open Inference.Models.Qwen

variable {C : Inference.Contracts.Mlx.M1Max.Contract} (M : MlxContract C) (K : KernelContract C)
    (env : Env InKey) (leaves : Leaves code env.weights) (typed : TypedCheckpoint env.weights)
    (parameters : TokenSequenceRanges.Parameters (firstPipeline M K env [] leaves typed))

/-- The recurrence is fixed using the checkpoint-only model before assigning
any native read symbol. Variable zero is the source token budget. -/
noncomputable def recurrenceValuation (maxTokens : Nat) : Nat → F64
  | 0 => F64.ofNat maxTokens
  | time + 1 => if h : time + 1 ≤ 262144 then
      F64.ofNat ((firstContext M K env [] leaves typed parameters).run promptToken (time+1) h).token.val
    else F64.ofNat 0

noncomputable def firstRecurrenceTable (maxTokens : Nat) : List F64 :=
  P.S2974.tab.map (SymE.eval (recurrenceValuation M K env leaves typed parameters maxTokens))

include parameters in
theorem parameters_for_table (table : List F64) :
    TokenSequenceRanges.Parameters (firstPipeline M K env table leaves typed) := by
  rw [firstPipeline_table_eq M K env table [] leaves typed]
  exact parameters

/-- At the actual first source cut, the memoized read denotes the token
computed by the recurrence. No independently supplied token oracle is used.
Reachability and branch-answer validity remain separate execution obligations. -/
theorem first_readback_from_recurrence (maxTokens : Nat) :
    let table := firstRecurrenceTable M K env leaves typed parameters maxTokens
    let G := ffiGraph (concrete (CSrv.val ⟨table⟩)) SourceKernels.sources P.s2974.ffi.mlx
    let token := ((firstContext M K env [] leaves typed parameters).run promptToken 1 (by decide)).token.val
    TokenRead M K env (CSrv.val ⟨table⟩) G 17776 (.ref 1) token := by
  dsimp only
  let table := firstRecurrenceTable M K env leaves typed parameters maxTokens
  let hp := parameters_for_table M K env leaves typed parameters table
  obtain ⟨_, hr, _, _, _, _⟩ := first_decoded_state M K env table leaves typed hp
  have he := recurrence_token_table_eq M K env table [] leaves typed hp parameters 1 (by decide)
  rw [he] at hr
  refine ⟨hr, ?_⟩
  have hv := val_inst (ρ := recurrenceValuation M K env leaves typed parameters maxTokens)
    (S := P.S2974) (C := ⟨table⟩) rfl (.ref 1)
  rw [hv, first_read_expression]
  rfl

theorem first_memo_values (maxTokens : Nat) :
    let table := firstRecurrenceTable M K env leaves typed parameters maxTokens
    let G := ffiGraph (concrete (CSrv.val ⟨table⟩)) SourceKernels.sources P.s2974.ffi.mlx
    ReadbackValues M K env (CSrv.val ⟨table⟩) G P.s2974.ffi.mlx.items := by
  dsimp only
  rw [first_read_memo]
  apply ReadbackValues.set M K env _ _ (ReadbackValues.empty M K env _ _) 17776 (.ref 1)
    ((firstContext M K env [] leaves typed parameters).run promptToken 1 (by decide)).token.val
    (by decide)
  · have h := ((firstContext M K env [] leaves typed parameters).run promptToken 1 (by decide)).token.isLt
    omega
  · exact first_readback_from_recurrence M K env leaves typed parameters maxTokens

end Host.Load.Run.Full
