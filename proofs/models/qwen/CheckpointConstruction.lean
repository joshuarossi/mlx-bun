import models.qwen.Qwen38TrellisM1MaxInference

namespace Inference.Models.Qwen.CheckpointConstruction
open Contracts.Mlx Layers.AffineVerifyLinear Qwen38TrellisM1Max
open CheckpointNormalizationBinding (deltaLayer attentionLayer inputIndex postIndex)
open CheckpointAffineDictionaryData

-- Pure source-model assembly. The template supplies packed codes, kernel
-- choices, platform operations and scratch descriptions; certified data
-- supplies numerical parameters. This does not mutate native MLX objects.
def projection (p : Projection steps rows) (encoded : CheckpointAffineDictionary.Encoding steps rows) : Projection steps rows :=
  match p with
  | .bits3 p => .bits3 (CheckpointAffineDictionary.specialize3 p encoded)
  | .bits4 p => .bits4 (CheckpointAffineDictionary.specialize4 p encoded)

theorem projection_attached (p : Projection steps rows) (encoded : CheckpointAffineDictionary.Encoding steps rows) :
    CheckpointAffineDictionary.Attached (projection p encoded) encoded := by
  cases p with
  | bits3 p => exact CheckpointAffineDictionary.specialize3_attached p encoded
  | bits4 p => exact CheckpointAffineDictionary.specialize4_attached p encoded

theorem projection_eq_self (p : Projection steps rows) (encoded : CheckpointAffineDictionary.Encoding steps rows)
    (binding : CheckpointAffineDictionary.Attached p encoded) : projection p encoded = p := by
  cases p with
  | bits3 p =>
    apply congrArg Projection.bits3
    apply congrArg (Projection3.mk p.platform)
    funext row
    have scales : (p.weights row).scale = projectionScales encoded.scales row := funext (binding.scales row)
    have biases : (p.weights row).bias = projectionBiases encoded.biases row := funext (binding.biases row)
    change { p.weights row with scale := projectionScales encoded.scales row, bias := projectionBiases encoded.biases row } = p.weights row
    rw [← scales, ← biases]
  | bits4 p =>
    apply congrArg Projection.bits4
    apply congrArg (Projection4.mk p.platform)
    funext row
    have scales : (p.weights row).scale = projectionScales encoded.scales row := funext (binding.scales row)
    have biases : (p.weights row).bias = projectionBiases encoded.biases row := funext (binding.biases row)
    change { p.weights row with scale := projectionScales encoded.scales row, bias := projectionBiases encoded.biases row } = p.weights row
    rw [← scales, ← biases]

def norm (template : Blocks.Norm) (index : Fin 129) : Blocks.Norm :=
  { template with weight := CheckpointNormalizationData.mainNorm index }
def mlp (template : WrittenLayers.GateDown) (layer : Fin 64) : WrittenLayers.GateDown :=
  { template with
    gate := { template.gate with scale := CheckpointTrellisData.gate layer }
    up := { template.up with scale := CheckpointTrellisData.up layer }
    down := { template.down with scale := CheckpointTrellisData.down layer } }

theorem norm_eq_self (template : Blocks.Norm) (index : Fin 129)
    (binding : template.weight = CheckpointNormalizationData.mainNorm index) : norm template index = template := by
  unfold norm
  rw [← binding]

theorem mlp_eq_self (template : WrittenLayers.GateDown) (layer : Fin 64)
    (gate : template.gate.scale = CheckpointTrellisData.gate layer)
    (up : template.up.scale = CheckpointTrellisData.up layer)
    (down : template.down.scale = CheckpointTrellisData.down layer) : mlp template layer = template := by
  unfold mlp
  rw [← gate, ← up, ← down]

def delta (template : ResidualDelta.Layer) (encoded : CheckpointDictionaryBinding.Encoding) (layer : Fin 48) : ResidualDelta.Layer where
  inputNorm := norm template.inputNorm (inputIndex (deltaLayer layer))
  mixer := { template.mixer with
    qkv := projection template.mixer.qkv (encoded.deltaQkv layer)
    z := projection template.mixer.z (encoded.deltaZ layer)
    a := projection template.mixer.a (encoded.deltaA layer)
    b := projection template.mixer.b (encoded.deltaB layer)
    out := projection template.mixer.out (encoded.deltaOutput layer)
    convolutionWeight := CheckpointConvolutionData.weight layer
    aLog := CheckpointDeltaData.aLog layer
    dtBias := CheckpointDeltaData.dtBias layer
    normWeight := CheckpointDeltaData.gatedNorm layer
    headParams := ⟨HeadScaleConstruction.query, HeadScaleConstruction.key, Float32.ofInt 128, Blocks.eps⟩ }
  suffix := ⟨norm template.suffix.norm (postIndex (deltaLayer layer)), mlp template.suffix.mlp (deltaLayer layer)⟩
  epsilon := rfl

def attention (template : ResidualAttention.Layer) (encoded : CheckpointDictionaryBinding.Encoding) (layer : Fin 16) : ResidualAttention.Layer where
  inputNorm := norm template.inputNorm (inputIndex (attentionLayer layer))
  mixer := { template.mixer with
    projections := ⟨projection template.mixer.projections.q (encoded.attentionQ layer),
      projection template.mixer.projections.k (encoded.attentionK layer),
      projection template.mixer.projections.v (encoded.attentionV layer)⟩
    output := projection template.mixer.output (encoded.attentionOutput layer)
    preparation := { template.mixer.preparation with
      qNorm := { template.mixer.preparation.qNorm with weight := CheckpointNormalizationData.query layer }
      kNorm := { template.mixer.preparation.kNorm with weight := CheckpointNormalizationData.key layer } } }
  suffix := ⟨norm template.suffix.norm (postIndex (attentionLayer layer)), mlp template.suffix.mlp (attentionLayer layer)⟩

def pipeline (template : TokenInference.Pipeline) (encoded : CheckpointDictionaryBinding.Encoding) : TokenInference.Pipeline where
  embedding := { template.embedding with
    scales := embeddingScales encoded.embedding.scales
    biases := embeddingBiases encoded.embedding.biases }
  graph := {
    delta := fun layer => delta (template.graph.delta layer) encoded layer
    attention := fun layer => attention (template.graph.attention layer) encoded layer
    finalNorm := norm template.graph.finalNorm ⟨128, by decide⟩
    output := projection template.graph.output encoded.output }

theorem attached (template : TokenInference.Pipeline) (encoded : CheckpointDictionaryBinding.Encoding) :
    CheckpointDictionaryBinding.Bindings (pipeline template encoded) encoded := {
  toConvolution := {
    toMlp := {
      toSequence := {
        toBindings := {
          deltaInput := fun _ => rfl
          deltaPost := fun _ => rfl
          attentionInput := fun _ => rfl
          attentionPost := fun _ => rfl
          query := fun _ => rfl
          key := fun _ => rfl
          finalNorm := rfl }
        headWidth := fun _ => rfl
        headEps := fun _ => rfl
        headQuery := fun _ => rfl
        headKey := fun _ => rfl
        aLog := fun _ => rfl
        dtBias := fun _ => rfl
        gatedNorm := fun _ => rfl }
      deltaGate := fun _ => rfl
      deltaUp := fun _ => rfl
      deltaDown := fun _ => rfl
      attentionGate := fun _ => rfl
      attentionUp := fun _ => rfl
      attentionDown := fun _ => rfl }
    convolution := fun _ => rfl }
  embedding := ⟨rfl, rfl⟩
  deltaQkv := fun layer => projection_attached (template.graph.delta layer).mixer.qkv (encoded.deltaQkv layer)
  deltaZ := fun layer => projection_attached (template.graph.delta layer).mixer.z (encoded.deltaZ layer)
  deltaA := fun layer => projection_attached (template.graph.delta layer).mixer.a (encoded.deltaA layer)
  deltaB := fun layer => projection_attached (template.graph.delta layer).mixer.b (encoded.deltaB layer)
  deltaOutput := fun layer => projection_attached (template.graph.delta layer).mixer.out (encoded.deltaOutput layer)
  attentionQ := fun layer => projection_attached (template.graph.attention layer).mixer.projections.q (encoded.attentionQ layer)
  attentionK := fun layer => projection_attached (template.graph.attention layer).mixer.projections.k (encoded.attentionK layer)
  attentionV := fun layer => projection_attached (template.graph.attention layer).mixer.projections.v (encoded.attentionV layer)
  attentionOutput := fun layer => projection_attached (template.graph.attention layer).mixer.output (encoded.attentionOutput layer)
  output := projection_attached template.graph.output encoded.output }

theorem parameters (template : TokenInference.Pipeline) (encoded : CheckpointDictionaryBinding.Encoding) :
    TokenSequenceRanges.Parameters (pipeline template encoded) :=
  CheckpointDictionaryBinding.pipeline_parameters (pipeline template encoded) encoded (attached template encoded)

-- Construction is a fixed point on a source model whose exact data
-- attachments already hold; it does not silently choose a different model.
theorem pipeline_eq_self (p : TokenInference.Pipeline) (encoded : CheckpointDictionaryBinding.Encoding)
    (binding : CheckpointDictionaryBinding.Bindings p encoded) : pipeline p encoded = p := by
  have deltaInput i := norm_eq_self (p.graph.delta i).inputNorm _ (binding.deltaInput i)
  have deltaPost i := norm_eq_self (p.graph.delta i).suffix.norm _ (binding.deltaPost i)
  have attentionInput i := norm_eq_self (p.graph.attention i).inputNorm _ (binding.attentionInput i)
  have attentionPost i := norm_eq_self (p.graph.attention i).suffix.norm _ (binding.attentionPost i)
  have deltaMlp i := mlp_eq_self (p.graph.delta i).suffix.mlp _
    (binding.deltaGate i) (binding.deltaUp i) (binding.deltaDown i)
  have attentionMlp i := mlp_eq_self (p.graph.attention i).suffix.mlp _
    (binding.attentionGate i) (binding.attentionUp i) (binding.attentionDown i)
  have dqkv i := projection_eq_self (p.graph.delta i).mixer.qkv _ (binding.deltaQkv i)
  have dz i := projection_eq_self (p.graph.delta i).mixer.z _ (binding.deltaZ i)
  have da i := projection_eq_self (p.graph.delta i).mixer.a _ (binding.deltaA i)
  have db i := projection_eq_self (p.graph.delta i).mixer.b _ (binding.deltaB i)
  have dout i := projection_eq_self (p.graph.delta i).mixer.out _ (binding.deltaOutput i)
  have aq i := projection_eq_self (p.graph.attention i).mixer.projections.q _ (binding.attentionQ i)
  have ak i := projection_eq_self (p.graph.attention i).mixer.projections.k _ (binding.attentionK i)
  have av i := projection_eq_self (p.graph.attention i).mixer.projections.v _ (binding.attentionV i)
  have aout i := projection_eq_self (p.graph.attention i).mixer.output _ (binding.attentionOutput i)
  have head i : (⟨HeadScaleConstruction.query, HeadScaleConstruction.key, Float32.ofInt 128, Blocks.eps⟩ : State.Ssm.Parameters) =
      (p.graph.delta i).mixer.headParams := by
    rw [← binding.headQuery i, ← binding.headKey i, ← binding.headWidth i, ← binding.headEps i]
  have headMixer i : { (p.graph.delta i).mixer with
      headParams := ⟨HeadScaleConstruction.query, HeadScaleConstruction.key, Float32.ofInt 128, Blocks.eps⟩ } =
      (p.graph.delta i).mixer := by rw [head i]
  have query i : { (p.graph.attention i).mixer.preparation.qNorm with weight := CheckpointNormalizationData.query i } =
      (p.graph.attention i).mixer.preparation.qNorm := by rw [← binding.query i]
  have key i : { (p.graph.attention i).mixer.preparation.kNorm with weight := CheckpointNormalizationData.key i } =
      (p.graph.attention i).mixer.preparation.kNorm := by rw [← binding.key i]
  simp only [pipeline, delta, attention, deltaInput, deltaPost, attentionInput, attentionPost, deltaMlp, attentionMlp,
    dqkv, dz, da, db, dout, aq, ak, av, aout, headMixer, query, key,
    ← binding.convolution, ← binding.aLog, ← binding.dtBias, ← binding.gatedNorm,
    norm_eq_self _ _ binding.finalNorm, projection_eq_self _ _ binding.output,
    ← binding.embedding.scales, ← binding.embedding.biases]

noncomputable def run (template : TokenInference.Pipeline) (encoded : CheckpointDictionaryBinding.Encoding)
    (primitive : Qwen38TrellisM1MaxSequenceRanges.Primitives (pipeline template encoded).graph)
    (sampling : Kernels.Sampling.LogSumExpRanges.Platform)
    (samplingPrimitive : Kernels.Sampling.LogSumExpRanges.Primitives sampling)
    (token : Fin 248320) (steps : Nat) (supported : steps ≤ 262144) :
    TokenAutoregressive.State (pipeline template encoded) steps :=
  Qwen38TrellisM1MaxInference.run (pipeline template encoded) encoded (attached template encoded)
    primitive sampling samplingPrimitive token steps supported

end Inference.Models.Qwen.CheckpointConstruction
