import host.load.run.full.LoadProgram
import host.load.ParameterSummary
import host.load.Reify
namespace Host.Load.Run.Full
open Host.Load.Extract Host.Load.Reify Host.Load.Program Host.Mlx Host.Mlx.FfiEval
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
set_option Elab.async false
set_option interpreter.prefer_native true
load_parameters weights : parameterChoice

theorem selected (value : TensorValues) : SourceSelections (weights value) := by
  constructor
  · intro i; fin_cases i <;> repeat constructor
  · intro i; fin_cases i <;> repeat constructor

macro "load_shape_step" : tactic => `(tactic| first
  | exact rfl
  | exact Or.inl rfl
  | exact Or.inr (Or.inl rfl)
  | exact Or.inr (Or.inr rfl)
  | exact Or.inl ⟨rfl, rfl, rfl⟩
  | exact Or.inr ⟨rfl, rfl⟩
  | assumption
  | constructor)

private theorem shapes (contents : Nat → Nat → Nat)
    (bounded : ∀ (t : Fin 248320) (j : Fin 640), contents 1 (t.val*640+j.val) < 2^32) :
    PayloadShape (weights (headerValues contents)) := by
  constructor
  · constructor
    · repeat' load_shape_step
    · exact bounded
    · repeat' load_shape_step
    · repeat' load_shape_step
  · intro i; fin_cases i <;> repeat' load_shape_step
  · intro i; fin_cases i <;> repeat' load_shape_step
  · repeat' load_shape_step
  · repeat' load_shape_step

noncomputable def embedFile : List Char := match code.node0.op with | .load file _ => file | _ => []
noncomputable def embedKey : List Char := match code.node0.op with | .load _ key => key | _ => []

theorem embedding_leaf : code[0]? = some ⟨.load embedFile embedKey, [], [248320,640], 3⟩ := by rfl

theorem embedding_carrier : certAt code.cert 0 = 1 := by rfl

variable {C : Inference.Contracts.Mlx.M1Max.Contract} (M : MlxContract C) (K : KernelContract C)
    (env : Env InKey) (G : Nat → Option (RNode Int InKey))

theorem parameter_evaluated (leaves : Leaves code env.weights)
    (matched : Matches G (code.map Program.Node.erase) code.cert = true) (t : Tensor)
    (ht : t ∈ parameterTensors parameterChoice) :
    evalR M K env G t.node = some (headerValues (contents M K env G) t) :=
  Program.parameter_value M K env G code code.cert (parameterTensors parameterChoice)
    code.valid leaves matched code.covers ht

/-- All dtype/shape/source choices come from the checked loaded metadata.
The only word bound comes from the actual embedding checkpoint leaf. -/
theorem shapes_from_checkpoint (leaves : Leaves code env.weights) (typed : TypedCheckpoint env.weights)
    (matched : Matches G (code.map Program.Node.erase) code.cert = true) :
    PayloadShape (weights (headerValues (contents M K env G))) := by
  apply shapes
  intro t j
  obtain ⟨v, hw, hd, hs⟩ := leaves 0 _ embedFile embedKey embedding_leaf rfl
  have hdt : v.dtype = .uint32 := by
    cases h : v.dtype <;> simp_all [Header, Dtype.code]
  have hi : t.val * 640 + j.val < v.size := by
    have ht := t.isLt
    have hj := j.isLt
    simp only [Value.size, hs, List.foldr_cons, List.foldr_nil, Nat.mul_one]
    omega
  have hb := load_contents_bounded M K env G code code.cert matched embedding_leaf hw typed hi
  simpa only [embedding_carrier, hdt, Dtype.bytes, Nat.reduceMul] using hb

noncomputable def loadedPipeline (leaves : Leaves code env.weights) (typed : TypedCheckpoint env.weights)
    (matched : Matches G (code.map Program.Node.erase) code.cert = true) :=
  Reify.pipeline M K (weights (headerValues (contents M K env G))) (shapes_from_checkpoint M K env G leaves typed matched)

theorem loadedPipeline_loaded (leaves : Leaves code env.weights) (typed : TypedCheckpoint env.weights)
    (matched : Matches G (code.map Program.Node.erase) code.cert = true) :
    Host.Mlx.GlueStep.PipelineLoaded M K (loadedPipeline M K env G leaves typed matched)
      (weights (headerValues (contents M K env G))) :=
  Reify.pipeline_loaded M K _ (shapes_from_checkpoint M K env G leaves typed matched) (selected _)

end Host.Load.Run.Full
