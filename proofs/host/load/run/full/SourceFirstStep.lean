import host.load.run.full.SourceInitialization
import host.load.run.full.RecurrenceReadbacks
import host.load.stop.EntryData

namespace Host.Load.Run.Full
open Host.Load.Extract Host.Load.Program Host.Mlx Host.Mlx.GlueStep Host.Mlx.FfiEval Host.Ts
open Inference.Models.Qwen
set_option Elab.async false
set_option maxRecDepth 1000000

def emittedValues (s : St LSt) (entry : Host.Ts.Env) : Option (List Val) :=
  (bindingOf s entry chars!"emitted").bind (Extract.elements s)

def emittedNumbers (s : St LSt) (entry : Host.Ts.Env) (server : CSrv) : Option (List F64) :=
  (emittedValues s entry).bind fun vs => vs.mapM fun v => match v with
    | .num n => server.val n
    | _ => none

theorem source_first_emitted_values :
    emittedValues P.s2974 (entryEnv P.s0) = some [.num (.ref 1)] := by rfl

theorem source_first_emitted_numbers (ρ : Nat → F64) (server : CSrv)
    (table : server.tab = P.S2974.tab.map (SymE.eval ρ)) :
    emittedNumbers P.s2974 (entryEnv P.s0) server = some [ρ 1] := by
  unfold emittedNumbers
  rw [source_first_emitted_values]
  change (server.val (.ref 1)).bind (fun v => some [v]) = some [ρ 1]
  rw [val_inst table (.ref 1), first_read_expression]
  rfl

variable {C : Inference.Contracts.Mlx.M1Max.Contract} (M : MlxContract C) (K : KernelContract C)
    (env : FfiEval.Env InKey) (leaves : Leaves code env.weights) (typed : TypedCheckpoint env.weights)
    (parameters : TokenSequenceRanges.Parameters (firstPipeline M K env [] leaves typed))

/-- The reached first yield has the graph-computed recurrence token and all
64 computed caches. The model is fixed from checkpoint leaves before the
numeric readback valuation is chosen. The two branch conditions select the
actual early-yield route; they are tests on the computed token and budget. -/
theorem source_first_step (maxTokens : Nat)
    (budget : F64.test .lt (.fin false 1 0) (F64.ofNat maxTokens) = true)
    (notEos : F64.test .eq (.fin false 248044 0)
      (F64.ofNat ((firstContext M K env [] leaves typed parameters).run promptToken 1 (by decide)).token.val) = false) :
    let ρ := recurrenceValuation M K env leaves typed parameters maxTokens
    let table := firstRecurrenceTable M K env leaves typed parameters maxTokens
    let hp := parameters_for_table M K env leaves typed parameters table
    let after := (firstContext M K env table leaves typed hp).run promptToken 1 (by decide)
    ∃ C' hs',
      ((bootL Route.cx Decode.world 2000).bind fun start =>
        runC Host.Load.ffi 29727013 start ⟨P.S0.tab.map (SymE.eval ρ)⟩) = some (P.s2974, C') ∧
      C'.tab = table ∧
      emittedNumbers P.s2974 (entryEnv P.s0) C' = some
        [F64.ofNat ((firstContext M K env [] leaves typed parameters).run promptToken 1 (by decide)).token.val] ∧
      firstPipeline M K env table leaves typed = initialPipeline M K env [] leaves typed ∧
      TokenRead M K env (CSrv.val C')
        (ffiGraph (concrete (CSrv.val C')) SourceKernels.sources P.s2974.ffi.mlx) 17776 (.ref 1)
        ((firstContext M K env [] leaves typed parameters).run promptToken 1 (by decide)).token.val ∧
      ChainHolds (firstPipeline M K env table leaves typed).graph.stages hs' after.cache ∧
      CacheValues M K env
        (ffiGraph (concrete (CSrv.val C')) SourceKernels.sources P.s2974.ffi.mlx) firstChoice.cache hs' ∧
      ReadbackValues M K env (CSrv.val C')
        (ffiGraph (concrete (CSrv.val C')) SourceKernels.sources P.s2974.ffi.mlx) P.s2974.ffi.mlx.items ∧
      Extract.loaded P.s2974 (entryEnv P.s0) = some firstChoice ∧
      firstChoice.model = parameterChoice.model := by
  dsimp only
  let ρ := recurrenceValuation M K env leaves typed parameters maxTokens
  let table := firstRecurrenceTable M K env leaves typed parameters maxTokens
  let hp := parameters_for_table M K env leaves typed parameters table
  have good : Good ρ StopEntry.firstYieldAnswers := by
    apply StopEntry.first_yield_good
    · change F64.test .lt (.fin false 1 0) (F64.ofNat maxTokens) = true
      exact budget
    · change F64.test .eq (.fin false 248044 0)
        (F64.ofNat ((firstContext M K env [] leaves typed parameters).run promptToken 1 (by decide)).token.val) = false
      exact notEos
  obtain ⟨C', reached, tab⟩ := source_prefix_boot ρ ⟨P.S0.tab.map (SymE.eval ρ)⟩
    P.prefixRun2974 StopEntry.first_yield_oracle rfl good
  have server : C' = ⟨table⟩ := by
    cases C' with
    | mk vals => exact congrArg CSrv.mk tab
  subst C'
  obtain ⟨hs', _, chain, cache⟩ := first_source_cache_values M K env table leaves typed hp
  refine ⟨⟨table⟩, hs', reached, rfl, ?_, (initial_pipeline_first M K env [] table leaves typed).symm,
    first_readback_from_recurrence M K env leaves typed parameters maxTokens, chain, cache,
    first_memo_values M K env leaves typed parameters maxTokens, firstParameters.matches,
    first_parameters_preserved⟩
  exact source_first_emitted_numbers ρ ⟨table⟩ rfl

end Host.Load.Run.Full
