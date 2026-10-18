import host.load.run.full.cached.MemoValues
import host.load.run.full.cached.FinalCache
import host.load.run.full.Concrete
import host.load.run.full.SourceInitialization
namespace Host.Load.Run.Full
open Host.Load.Extract Host.Load.Program Host.Mlx Host.Mlx.GlueStep Host.Mlx.FfiEval Host.Ts Cached
open Inference.Models.Qwen
set_option Elab.async false
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
variable {C : Inference.Contracts.Mlx.M1Max.Contract} (M : MlxContract C) (K : KernelContract C)
    (env : FfiEval.Env InKey) (leaves : Leaves code env.weights) (typed : TypedCheckpoint env.weights)
    (parameters : TokenSequenceRanges.Parameters (firstPipeline M K env [] leaves typed))

noncomputable def computedFive : List F64 := List.ofFn fun i : Fin 5 =>
  F64.ofNat ((firstContext M K env [] leaves typed parameters).run promptToken (i.val+1) (by omega)).token.val

/-- The complete checked 206-file source route loads the actual checkpoint,
creates all 64 caches, emits the five mathematical recurrence tokens and halts.
The token oracle is derived from the fixed checkpoint recurrence; the only
branch premise selects this non-EOS five-token route. Cache values at all
five forward boundaries and every memoized read are derived from the graph
certificates, checkpoint payloads and numerical platform contracts. -/
theorem source_five
    (notEos : ∀ i : Fin 5, F64.test .eq (.fin false 248044 0)
      (F64.ofNat ((firstContext M K env [] leaves typed parameters).run promptToken (i.val+1) (by omega)).token.val) = false)
    (n : Nat) (enough : 35698253 ≤ n) :
    let ρ := recurrenceValuation M K env leaves typed parameters 5
    let table := finalRecurrenceTable M K env leaves typed parameters 5
    let hp := parameters_for_table M K env leaves typed parameters table
    ∃ server,
      ((bootL Route.cx Decode.world 2000).bind fun start =>
        runC Host.Load.ffi n start ⟨P.S0.tab.map (SymE.eval ρ)⟩) = some (P.s3575,server) ∧
      server.tab = table ∧
      emittedNumbers P.s3575 (entryEnv P.s0) server = some (computedFive M K env leaves typed parameters) ∧
      firstPipeline M K env table leaves typed = initialPipeline M K env [] leaves typed ∧
      ForwardResult M K env table leaves typed hp 1 (by decide) firstChoice.cache 17776 ∧
      ForwardResult M K env table leaves typed hp 2 (by decide) after2.cache 20157 ∧
      ForwardResult M K env table leaves typed hp 3 (by decide) after3.cache 22538 ∧
      ForwardResult M K env table leaves typed hp 4 (by decide) after4.cache 24919 ∧
      ForwardResult M K env table leaves typed hp 5 (by decide) after5.cache 27300 ∧
      ReadbackValues M K env (CSrv.val server) (terminalGraph table) P.s3575.ffi.mlx.items ∧
      ((bindingOf P.s3575 (entryEnv P.s0) chars!"cache").bind (Extract.elements P.s3575)).bind
        (List.mapM (Extract.cache P.s3575)) = some after5.cache ∧
      Extract.loaded P.s3573 (entryEnv P.s0) = some after5 ∧ after5.model = parameterChoice.model ∧
      ∃ v, P.s3575.ctl = .halt (.normal v) := by
  dsimp only
  let ρ := recurrenceValuation M K env leaves typed parameters 5
  let table := finalRecurrenceTable M K env leaves typed parameters 5
  let hp := parameters_for_table M K env leaves typed parameters table
  have branches : ∀ i ∈ [1,2,3,4,5], F64.test .eq (.fin false 248044 0) (ρ i) = false := by
    intro i hi
    simp at hi
    rcases hi with rfl | rfl | rfl | rfl | rfl
    · exact notEos (0 : Fin 5)
    · exact notEos (1 : Fin 5)
    · exact notEos (2 : Fin 5)
    · exact notEos (3 : Fin 5)
    · exact notEos (4 : Fin 5)
  obtain ⟨server,execution,inst⟩ := P.concrete_boot ρ ⟨P.S0.tab.map (SymE.eval ρ)⟩ rfl (by rfl) branches n enough
  have tab : server.tab = table := inst.1
  have same : server = ⟨table⟩ := by
    cases server with
    | mk vals => exact congrArg CSrv.mk tab
  subst server
  obtain ⟨one,two,three,four,five⟩ := terminal_all_five M K env table leaves typed hp
  refine ⟨⟨table⟩,execution,rfl,?_,(initial_pipeline_first M K env [] table leaves typed).symm,
    one,two,three,four,five,terminal_memo_values M K env leaves typed parameters 5,
    final_cache_snapshot,loaded5.matches,model5_preserved,BudgetEnd.normal_halt⟩
  exact final_emitted_numbers ρ ⟨table⟩ rfl
end Host.Load.Run.Full
