import host.load.run.full.Run
import host.load.run.full.Load
import host.load.run.full.FirstStep
import host.load.run.full.WeightsEquality
import host.load.ProgramEquality
import host.load.OraclePrefix

namespace Host.Load.Run.Full
open Host.Ts Host.Load.Extract Host.Load.Program Host.Mlx Host.Mlx.FfiEval
open Inference.Models.Qwen
set_option Elab.async false
set_option maxRecDepth 1000000

/-- The checked source heap and native graph at the completed load boundary. -/
structure InitializationAt (s : St LSt) : Prop where
  extracted : Extract.loaded s (entryEnv P.s0) = some parameterChoice
  graph : s.ffi.mlx = parameterChoice.graph
  ready : Decode.loadDone (entryEnv P.s0) s = true

theorem source_initialized : InitializationAt P.s2818 :=
  ⟨parameters.matches, graph_matches, loaded_marker⟩

theorem source_load_answers : P.S0.oracle = [] ++ P.S2818.oracle := by rfl

/-- A checked prefix can be concretized with only its consumed answers.
The unread tail of the discovery oracle imposes no condition on the run. -/
theorem source_prefix_boot (ρ : Nat → F64) (C : CSrv)
    {n : Nat} {s : St LSt} {S : SSrv} {front : List Ans}
    (execution : runS P.F n P.s0 P.S0 = some (s, S))
    (answers : P.S0.oracle = front ++ S.oracle)
    (table : C.tab = P.S0.tab.map (SymE.eval ρ)) (good : Good ρ front) :
    ∃ C', ((bootL Route.cx Decode.world 2000).bind fun start => runC Host.Load.ffi n start C) =
      some (s, C') ∧ C'.tab = S.tab.map (SymE.eval ρ) := by
  obtain ⟨C', reached, tab⟩ := OraclePrefix.concrete_prefix P.F ρ C execution answers table good
  refine ⟨C', ?_, tab⟩
  change (P.boot.bind fun start => runC P.F n start C) = _
  rw [P.boot_eq]
  exact reached

/-- Loading and making all caches consumes no symbolic branch answers.
In particular, initialization is independent of the budget and future tokens. -/
theorem source_initialization (ρ : Nat → F64) (C : CSrv)
    (table : C.tab = P.S0.tab.map (SymE.eval ρ)) :
    ∃ C', ((bootL Route.cx Decode.world 2000).bind fun start => runC Host.Load.ffi 28172201 start C) =
      some (P.s2818, C') ∧ C'.tab = P.S2818.tab.map (SymE.eval ρ) ∧
      InitializationAt P.s2818 := by
  obtain ⟨C', reached, tab⟩ := source_prefix_boot ρ C P.prefixRun2818 source_load_answers table
    (by intro q hq; cases hq)
  exact ⟨C', reached, tab, source_initialized⟩

/-- The cache bindings come from the reached heap projection. Absent tensors
and zero offsets are established here rather than supplied as premises. -/
theorem InitializationAt.empty_caches {s : St LSt} (h : InitializationAt s) :
    ∃ l, Extract.loaded s (entryEnv P.s0) = some l ∧ l.cache = initialCache ∧
      l.cache.map Cache.offset = List.replicate 64 0 ∧
      ∀ value : TensorValues, l.cache.mapM (cacheHandle value) = some initialHandles :=
  ⟨parameterChoice, h.extracted, cache_initial, cache_offsets_zero, handles_initial⟩

def initialFfiGraph (table : List F64) : Nat → Option (RNode Int InKey) :=
  ffiGraph (concrete (CSrv.val ⟨table⟩)) SourceKernels.sources parameterChoice.graph

theorem initial_graph_source (table : List F64) :
    ffiGraph (concrete (CSrv.val ⟨table⟩)) SourceKernels.sources P.s2818.ffi.mlx =
      initialFfiGraph table := by
  rw [graph_matches]
  rfl

theorem initial_graph_certificate (table : List F64) :
    Matches (initialFfiGraph table) (code.map Program.Node.erase) code.cert = true :=
  code.matches table SourceKernels.sources

variable {C : Inference.Contracts.Mlx.M1Max.Contract} (M : MlxContract C) (K : KernelContract C)
    (env : FfiEval.Env InKey)

noncomputable def initialValues (table : List F64) : TensorValues :=
  headerValues (contents M K env (initialFfiGraph table))

noncomputable def initialPipeline (table : List F64)
    (leaves : Leaves code env.weights) (typed : TypedCheckpoint env.weights) :=
  loadedPipeline M K env (initialFfiGraph table) leaves typed (initial_graph_certificate table)

/-- Every parameter value is evaluated from named checkpoint leaves and the
checked load transforms. No derived-node tensor contents are assumed. -/
theorem initial_parameter_values (table : List F64) (leaves : Leaves code env.weights)
    (t : Tensor) (ht : t ∈ parameterTensors parameterChoice) :
    evalR M K env (initialFfiGraph table) t.node = some (initialValues M K env table t) :=
  parameter_evaluated M K env (initialFfiGraph table) leaves (initial_graph_certificate table) t ht

theorem initial_pipeline_loaded (table : List F64)
    (leaves : Leaves code env.weights) (typed : TypedCheckpoint env.weights) :
    GlueStep.PipelineLoaded M K (initialPipeline M K env table leaves typed)
      (weights (initialValues M K env table)) :=
  loadedPipeline_loaded M K env (initialFfiGraph table) leaves typed (initial_graph_certificate table)

theorem initial_cache_chain (table : List F64)
    (leaves : Leaves code env.weights) (typed : TypedCheckpoint env.weights) :
    GlueStep.ChainHolds (initialPipeline M K env table leaves typed).graph.stages initialHandles
      (InitialState.caches (initialPipeline M K env table leaves typed).graph.stages) :=
  initialChainHolds _

/-- The first decode uses the same checkpoint-derived weights that were
constructed at the actual load boundary, for every numeric-server table. -/
theorem initial_weights_first (table table' : List F64) :
    weights (initialValues M K env table) = weights (firstValues M K env table') := by
  apply weights_congr
  intro t ht
  have he := covered_value_eq M K env (initialFfiGraph table) (firstFfiGraph table')
    code code.cert t (initial_graph_certificate table)
    (first_load_matches table' SourceKernels.sources) ht
  simp only [initialValues, firstValues, headerValues, contents, he]

private theorem reified_pipeline_eq (w w' : GlueStep.PipelineWeights)
    (shape : Reify.PayloadShape w) (shape' : Reify.PayloadShape w') (hw : w = w') :
    Reify.pipeline M K w shape = Reify.pipeline M K w' shape' := by
  cases hw
  rfl

theorem initial_pipeline_first (table table' : List F64)
    (leaves : Leaves code env.weights) (typed : TypedCheckpoint env.weights) :
    initialPipeline M K env table leaves typed = firstPipeline M K env table' leaves typed :=
  reified_pipeline_eq M K _ _
    (shapes_from_checkpoint M K env (initialFfiGraph table) leaves typed (initial_graph_certificate table))
    (shapes_from_checkpoint M K env (firstFfiGraph table') leaves typed
      (first_load_matches table' SourceKernels.sources))
    (initial_weights_first M K env table table')

end Host.Load.Run.Full
