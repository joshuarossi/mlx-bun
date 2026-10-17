import host.mlx.GlueLayers
namespace Host.Mlx.GlueStep
open Inference Inference.Contracts.Mlx Inference.Kernels Inference.Layers
open Inference.Models.Qwen WrittenLayers GlueLayers
open FloatLib FloatLib.Floats FloatLib.Floats.Formats.BinaryInterchange
set_option maxRecDepth 10000
variable {C : M1Max.Contract} (M : MlxContract C) (K : KernelContract C)

/-! ## Embedding: three take_axis then dequantize -/

structure EmbeddingLoaded (l : QuantizedEmbedding.Layer) (words scales biases : Value) : Prop where
  words : words.dtype = .uint32 ∧ words.shape = [248320, 640] ∧
    ∀ t j, words.elems (t.val*640+j.val) = (l.words t j).toNat
  scales : scales.dtype = .bfloat16 ∧ scales.shape = [248320, 80] ∧ ∀ t g, bf (scales.elems (t.val*80+g.val)) = l.scales t g
  biases : biases.dtype = .bfloat16 ∧ biases.shape = [248320, 80] ∧ ∀ t g, bf (biases.elems (t.val*80+g.val)) = l.biases t g
  contracted : l.contracted = M.dequantizeContracted

-- quantized-embedding.ts QuantizedEmbedding.encode(ids [1,1] uint32).
def tokenIds (token : Nat) : Value := ⟨.uint32, [1,1], fun _ => token⟩

def embedTrace (words scales biases : Value) (token : Nat) : Option Value := do
  let rows ← takeAxis0 words (tokenIds token)
  let s ← takeAxis0 scales (tokenIds token)
  let b ← takeAxis0 biases (tokenIds token)
  dequantizeRow M rows s b

-- Value.byte of a uint32 word is QuantizedEmbedding.bytes' shifted byte.
theorem byte_shift (w : BitVec 32) (k : Nat) : BitVec.ofNat 8 (w.toNat / 256^k) = (w >>> (8*k)).setWidth 8 := by
  apply BitVec.eq_of_toNat_eq
  rw [BitVec.toNat_setWidth, BitVec.toNat_ushiftRight, Nat.shiftRight_eq_div_pow, BitVec.toNat_ofNat,
    show (256:Nat)^k = 2^(8*k) by rw [pow_mul]; norm_num]

theorem take_rows (v : Value) (rows cols : Nat) (hs : v.shape = [rows, cols])
    (token : Nat) :
    takeAxis0 v (tokenIds token) = some ⟨v.dtype, [1,1,cols], fun i =>
      if token < rows then v.elems (token*cols + i%cols) else 0⟩ := by
  unfold takeAxis0 takeRows
  simp only [tokenIds, hs, ↓reduceIte]
  rfl

theorem embed (l : QuantizedEmbedding.Layer) (words scales biases : Value) (hl : EmbeddingLoaded M l words scales biases)
    (token : Fin 248320) :
    ∃ x, embedTrace M words scales biases token.val = some x ∧ Row x 5120 (l.forward token) := by
  have ht := token.isLt
  have e1 := take_rows words 248320 640 hl.words.2.1 token.val
  have e2 := take_rows scales 248320 80 hl.scales.2.1 token.val
  have e3 := take_rows biases 248320 80 hl.biases.2.1 token.val
  have cond : (⟨words.dtype, [1,1,640], fun i => if token.val < 248320 then words.elems (token.val*640 + i%640) else 0⟩ : Value).dtype = .uint32 ∧
      (⟨words.dtype, [1,1,640], fun i => if token.val < 248320 then words.elems (token.val*640 + i%640) else 0⟩ : Value).shape = [1,1,640] ∧
      (⟨scales.dtype, [1,1,80], fun i => if token.val < 248320 then scales.elems (token.val*80 + i%80) else 0⟩ : Value).shape = [1,1,80] ∧
      (⟨biases.dtype, [1,1,80], fun i => if token.val < 248320 then biases.elems (token.val*80 + i%80) else 0⟩ : Value).shape = [1,1,80] :=
    ⟨hl.words.1, rfl, rfl, rfl⟩
  refine ⟨⟨.bfloat16, [1,1,5120], ?elems⟩, ?eq, ?row⟩
  case eq =>
    unfold embedTrace
    rw [e1]; dsimp only [bind, Option.bind]
    rw [e2]; dsimp only [bind, Option.bind]
    rw [e3]; dsimp only [bind, Option.bind]
    unfold dequantizeRow
    rw [if_pos cond]
  case row =>
    refine Row.mk rfl rfl fun j => ?_
    dsimp only
    rw [dif_pos j.isLt, bf_word, ← hl.contracted]
    unfold QuantizedEmbedding.Layer.forward
    congr 1
    · funext b
      have hb := b.isLt
      unfold Value.byte QuantizedEmbedding.bytes
      dsimp only
      rw [if_pos ht, Nat.mod_eq_of_lt (show b.val/4 < 640 by omega)]
      have := hl.words.2.2 token ⟨b.val/4, by omega⟩
      dsimp only at this
      rw [this, byte_shift]
      rfl
    · funext g
      rw [if_pos ht, Nat.mod_eq_of_lt g.isLt]
      exact hl.scales.2.2 token g
    · funext g
      rw [if_pos ht, Nat.mod_eq_of_lt g.isLt]
      exact hl.biases.2.2 token g

/-! ## The layer chain -/

inductive StageWeights where
  | delta (w : DeltaWeights)
  | attention (w : AttentionWeights)

-- Each layer's cache handles: SSMCache (conv, recurrent) or KVCache (keys, values).
inductive Handles where
  | delta (conv rec : Option Value)
  | attention (keys values : Option Value)

noncomputable def stageTrace (n : Nat) : StageWeights → Handles → Value → Option (Value × Handles)
  | .delta w, .delta conv rec, x =>
    (deltaLayerTrace M K w conv rec x).map fun r => (r.1, .delta (some r.2.1) (some r.2.2))
  | .attention w, .attention kb vb, x =>
    (attentionLayerTrace M K w kb vb n x).map fun r => (r.1, .attention (some r.2.1) (some r.2.2))
  | _, _, _ => none

-- Qwen38TrellisM1Max #run: scope.accept(i, layers[i].forward(hidden, state[i], "decode")).
noncomputable def chainTrace (n : Nat) : List StageWeights → List Handles → Value → Option (Value × List Handles)
  | [], [], x => some (x, [])
  | s :: ss, h :: hs, x => do
    let r ← stageTrace M K n s h x
    let t ← chainTrace n ss hs r.1
    pure (t.1, r.2 :: t.2)
  | _, _, _ => none

def StageLoaded : DecodeStage.Stage → StageWeights → Prop
  | .delta l, .delta w => DeltaLoaded M K l w
  | .attention l, .attention w => AttentionLoaded M K l w
  | _, _ => False

def ChainLoaded : List DecodeStage.Stage → List StageWeights → Prop
  | [], [] => True
  | s :: ss, w :: ws => StageLoaded M K s w ∧ ChainLoaded ss ws
  | _, _ => False

def StageHolds : (s : DecodeStage.Stage) → Handles → DecodeStage.Cache s n → Prop
  | .delta _, .delta conv rec, c => HistoryHolds conv c.history ∧ StateHolds rec c.recurrent
  | .attention _, .attention kb vb, c => GlueKv.State kb n c.keys ∧ GlueKv.State vb n c.values
  | _, _, _ => False

def ChainHolds : (stages : List DecodeStage.Stage) → List Handles → DecodeChain.Caches stages n → Prop
  | [], [], _ => True
  | s :: ss, h :: hs, c => StageHolds s h c.1 ∧ ChainHolds ss hs c.2
  | _, _, _ => False

def DecayOk : DecodeStage.Stage → (Fin 5120 → BF) → Prop
  | .delta l, x => ∀ h, Model.isFinite (Delta.Decay.biased (l.mixer.a.forward (l.inputNorm.forward x) h) (l.mixer.dtBias h)) = true
  | .attention _, _ => True

-- computeG's reviewed host source needs a finite bf16 a + dt_bias at every
-- Delta layer of the step (model-level range premise).
def DecayFinite : (stages : List DecodeStage.Stage) → DecodeChain.Caches stages n → (Fin 5120 → BF) →
    Kernels.Attention.RopeAngles.Inputs → Prop
  | [], _, _, _ => True
  | s :: ss, c, x, a =>
    DecayOk s x ∧
    DecayFinite ss c.2 (DecodeStage.forward s c.1 x a) a

theorem stage (s : DecodeStage.Stage) (w : StageWeights) (hl : StageLoaded M K s w) (c : DecodeStage.Cache s n)
    (h : Handles) (hh : StageHolds s h c) (xv : Value) (x : Fin 5120 → BF) (hx : Row xv 5120 x)
    (policy : M.logAddExp = Delta.MlxLogAddExpSource.legacyPolicy)
    (finite : DecayOk s x) :
    ∃ y h', stageTrace M K n w h xv = some (y, h') ∧
      Row y 5120 (DecodeStage.forward s c x (RopeInputConstruction.inputs n)) ∧
      StageHolds s h' (DecodeStage.cacheAfter s c x (RopeInputConstruction.inputs n)) := by
  cases s with
  | delta l =>
    cases w with
    | attention _ => exact hl.elim
    | delta w =>
      cases h with
      | attention _ _ => exact hh.elim
      | delta conv rec =>
        obtain ⟨out, tail, st, e, tout, ht, hs⟩ := delta_layer M K l w hl c conv rec hh.1 hh.2 xv x hx policy finite
        exact ⟨out, .delta (some tail) (some st), by simp only [stageTrace, e, Option.map_some], tout, ⟨ht, hs⟩⟩
  | attention l =>
    cases w with
    | delta _ => exact hl.elim
    | attention w =>
      cases h with
      | delta _ _ => exact hh.elim
      | attention kb vb =>
        obtain ⟨out, kb', vb', e, tout, hk, hv⟩ := attention_layer M K l w hl c kb vb hh.1 hh.2 xv x hx
        exact ⟨out, .attention (some kb') (some vb'), by simp only [stageTrace, e, Option.map_some], tout, ⟨hk, hv⟩⟩

theorem chain (stages : List DecodeStage.Stage) (ws : List StageWeights) (hl : ChainLoaded M K stages ws)
    (c : DecodeChain.Caches stages n) (hs : List Handles) (hh : ChainHolds stages hs c)
    (xv : Value) (x : Fin 5120 → BF) (hx : Row xv 5120 x)
    (policy : M.logAddExp = Delta.MlxLogAddExpSource.legacyPolicy)
    (finite : DecayFinite stages c x (RopeInputConstruction.inputs n)) :
    ∃ y hs', chainTrace M K n ws hs xv = some (y, hs') ∧
      Row y 5120 (DecodeChain.run stages c x (RopeInputConstruction.inputs n)).1 ∧
      ChainHolds stages hs' (DecodeChain.run stages c x (RopeInputConstruction.inputs n)).2 := by
  induction stages generalizing ws hs xv x with
  | nil =>
    cases ws with
    | cons _ _ => exact hl.elim
    | nil =>
      cases hs with
      | cons _ _ => exact hh.elim
      | nil => exact ⟨xv, [], rfl, hx, trivial⟩
  | cons s rest ih =>
    cases ws with
    | nil => exact hl.elim
    | cons w ws =>
      cases hs with
      | nil => exact hh.elim
      | cons h hs =>
        obtain ⟨y, h', e1, ty, hy⟩ := stage M K s w hl.1 c.1 h hh.1 xv x hx policy finite.1
        obtain ⟨z, hs', e2, tz, hz⟩ := ih ws hl.2 c.2 hs hh.2 y _ ty finite.2
        refine ⟨z, h' :: hs', ?_, tz, hy, hz⟩
        simp only [chainTrace, e1, Option.bind_eq_bind, Option.bind_some, e2]
        rfl

/-! ## The decode step -/

structure PipelineWeights where
  embedWords : Value
  embedScales : Value
  embedBiases : Value
  delta : Fin 48 → DeltaWeights
  attention : Fin 16 → AttentionWeights
  finalNorm : Value
  head : Linear

-- Qwen38TrellisM1Max #one: (Qkv, Z, Out) projector of each Delta layer, in
-- layer order; A and B and every attention projection are Plain.
def oneDelta (i : Fin 48) : Projector × Projector × Projector :=
  match i.val with
  | 0 => (.plain, .plain, .plain) -- d0
  | 1 => (.affineRow, .affineRow, .plain) -- d1
  | 2 => (.affineRow, .affineRow, .plain) -- d2
  | 3 => (.affineRow, .plain, .plain) -- d4
  | 4 => (.affineRow, .plain, .plain) -- d5
  | 5 => (.affineRow, .affineRow, .affineRow) -- d6
  | 6 => (.affineRow, .affineRow, .affineRow) -- d8
  | 7 => (.affineRow, .affineRow, .affineRow) -- d9
  | 8 => (.affineRow, .affineRow, .affineRow) -- d10
  | 9 => (.affineRow, .affineRow, .affineRow) -- d12
  | 10 => (.affineRow, .affineRow, .affineRow) -- d13
  | 11 => (.affineRow, .affineRow, .affineRow) -- d14
  | 12 => (.affineRow, .affineRow, .affineRow) -- d16
  | 13 => (.affineRow, .affineRow, .affineRow) -- d17
  | 14 => (.affineRow, .affineRow, .affineRow) -- d18
  | 15 => (.affineRow, .affineRow, .affineRow) -- d20
  | 16 => (.affineRow, .affineRow, .affineRow) -- d21
  | 17 => (.affineRow, .affineRow, .affineRow) -- d22
  | 18 => (.affineRow, .affineRow, .affineRow) -- d24
  | 19 => (.affineRow, .plain, .affineRow) -- d25
  | 20 => (.affineRow, .affineRow, .affineRow) -- d26
  | 21 => (.affineRow, .affineRow, .affineRow) -- d28
  | 22 => (.affineRow, .affineRow, .affineRow) -- d29
  | 23 => (.affineRow, .affineRow, .affineRow) -- d30
  | 24 => (.affineRow, .affineRow, .affineRow) -- d32
  | 25 => (.affineRow, .affineRow, .affineRow) -- d33
  | 26 => (.affineRow, .affineRow, .affineRow) -- d34
  | 27 => (.affineRow, .affineRow, .affineRow) -- d36
  | 28 => (.affineRow, .affineRow, .affineRow) -- d37
  | 29 => (.affineRow, .affineRow, .affineRow) -- d38
  | 30 => (.affineRow, .affineRow, .affineRow) -- d40
  | 31 => (.affineRow, .affineRow, .affineRow) -- d41
  | 32 => (.affineRow, .affineRow, .affineRow) -- d42
  | 33 => (.affineRow, .affineRow, .affineRow) -- d44
  | 34 => (.affineRow, .affineRow, .affineRow) -- d45
  | 35 => (.affineRow, .affineRow, .affineRow) -- d46
  | 36 => (.affineRow, .affineRow, .affineRow) -- d48
  | 37 => (.affineRow, .affineRow, .affineRow) -- d49
  | 38 => (.affineRow, .affineRow, .affineRow) -- d50
  | 39 => (.affineRow, .affineRow, .affineRow) -- d52
  | 40 => (.affineRow, .plain, .affineRow) -- d53
  | 41 => (.plain, .plain, .plain) -- d54
  | 42 => (.plain, .plain, .plain) -- d56
  | 43 => (.plain, .plain, .plain) -- d57
  | 44 => (.plain, .affineRow, .affineRow) -- d58
  | 45 => (.plain, .plain, .affineRow) -- d60
  | 46 => (.plain, .plain, .plain) -- d61
  | 47 => (.plain, .plain, .affineRow) -- d62
  | _ => (.plain, .plain, .plain)

-- `Loaded p`: the loaded weight handles' values encode the pipeline's
-- parameters, the graph binds the #one projectors, and every model
-- platform is the one MLX or our kernel runs.
structure PipelineLoaded (p : TokenInference.Pipeline) (w : PipelineWeights) : Prop where
  embedding : EmbeddingLoaded M p.embedding w.embedWords w.embedScales w.embedBiases
  delta : ∀ i, DeltaLoaded M K (p.graph.delta i) (w.delta i)
  attention : ∀ i, AttentionLoaded M K (p.graph.attention i) (w.attention i)
  finalNorm : GlueAttention.Vector w.finalNorm 5120 p.graph.finalNorm.weight
  finalPlatform : p.graph.finalNorm.platform = M.hiddenNorm
  head : Loaded M K .plain w.head p.graph.output
  deltaProjectors : ∀ i, ((w.delta i).qkvKind, (w.delta i).zKind, (w.delta i).outKind) = oneDelta i
  attentionProjectors : ∀ i, (w.attention i).qKind = .plain ∧ (w.attention i).kKind = .plain ∧
    (w.attention i).vKind = .plain ∧ (w.attention i).oKind = .plain

-- The #one layer list (d0 d1 d2 a3 ...), the order of Graph.stages.
def stageWeights (w : PipelineWeights) : List StageWeights := [
  .delta (w.delta 0), .delta (w.delta 1), .delta (w.delta 2), .attention (w.attention 0), .delta (w.delta 3), 
  .delta (w.delta 4), .delta (w.delta 5), .attention (w.attention 1), .delta (w.delta 6), .delta (w.delta 7), 
  .delta (w.delta 8), .attention (w.attention 2), .delta (w.delta 9), .delta (w.delta 10), .delta (w.delta 11), 
  .attention (w.attention 3), .delta (w.delta 12), .delta (w.delta 13), .delta (w.delta 14), .attention 
  (w.attention 4), .delta (w.delta 15), .delta (w.delta 16), .delta (w.delta 17), .attention (w.attention 5), 
  .delta (w.delta 18), .delta (w.delta 19), .delta (w.delta 20), .attention (w.attention 6), .delta (w.delta 
  21), .delta (w.delta 22), .delta (w.delta 23), .attention (w.attention 7), .delta (w.delta 24), .delta 
  (w.delta 25), .delta (w.delta 26), .attention (w.attention 8), .delta (w.delta 27), .delta (w.delta 28), 
  .delta (w.delta 29), .attention (w.attention 9), .delta (w.delta 30), .delta (w.delta 31), .delta (w.delta 
  32), .attention (w.attention 10), .delta (w.delta 33), .delta (w.delta 34), .delta (w.delta 35), .attention 
  (w.attention 11), .delta (w.delta 36), .delta (w.delta 37), .delta (w.delta 38), .attention (w.attention 12), 
  .delta (w.delta 39), .delta (w.delta 40), .delta (w.delta 41), .attention (w.attention 13), .delta (w.delta 
  42), .delta (w.delta 43), .delta (w.delta 44), .attention (w.attention 14), .delta (w.delta 45), .delta 
  (w.delta 46), .delta (w.delta 47), .attention (w.attention 15)]

theorem stages_loaded (p : TokenInference.Pipeline) (w : PipelineWeights) (hl : PipelineLoaded M K p w) :
    ChainLoaded M K p.graph.stages (stageWeights w) := by
  have hd := hl.delta
  have ha := hl.attention
  exact ⟨
    hd 0, hd 1, hd 2, ha 0, hd 3, hd 4, hd 5, ha 1, hd 6, hd 7, hd 8, ha 2, hd 9, hd 10, hd 11, ha 3, hd 12, hd 
    13, hd 14, ha 4, hd 15, hd 16, hd 17, ha 5, hd 18, hd 19, hd 20, ha 6, hd 21, hd 22, hd 23, ha 7, hd 24, hd 
    25, hd 26, ha 8, hd 27, hd 28, hd 29, ha 9, hd 30, hd 31, hd 32, ha 10, hd 33, hd 34, hd 35, ha 11, hd 36, hd 
    37, hd 38, ha 12, hd 39, hd 40, hd 41, ha 13, hd 42, hd 43, hd 44, ha 14, hd 45, hd 46, hd 47, ha 15
, trivial⟩

-- SubmittedGraphForwardScope(embed.encode(ids)), #run over #one, finalNorm,
-- the Plain lm_head, step.ts sampleDevice: reshape [1, V], normalizedArgmax,
-- itemUint32. Evaluation scopes and command-buffer submission have no
-- value effect.
noncomputable def stepTrace (w : PipelineWeights) (n token : Nat) (hs : List Handles) : Option (Nat × List Handles) := do
  let x ← embedTrace M w.embedWords w.embedScales w.embedBiases token
  let (y, hs') ← chainTrace M K n (stageWeights w) hs x
  let h ← rmsNorm M.hiddenNorm y w.finalNorm (f32 0x358637bd)
  let logits ← GlueLayers.project M K .plain w.head h
  let l ← reshape logits [1, 248320]
  let [r] ← KernelClosure.eval K .normalizedArgmax [l] | none
  let t ← itemUint32 r
  pure (t, hs')

theorem step (p : TokenInference.Pipeline) (w : PipelineWeights) (hl : PipelineLoaded M K p w)
    (c : p.graph.Cache n) (hs : List Handles) (hh : ChainHolds p.graph.stages hs c) (token : Fin 248320)
    (policy : M.logAddExp = Delta.MlxLogAddExpSource.legacyPolicy)
    (finite : DecayFinite p.graph.stages c (p.embedding.forward token) (RopeInputConstruction.inputs n))
    (primitive : Sampling.LogSumExpRanges.Primitives K.sampling)
    (bound : ∀ i, Model.isFinite ((p.run c token (RopeInputConstruction.inputs n)).1 i) = true ∧
      |Model.toReal ((p.run c token (RopeInputConstruction.inputs n)).1 i)| ≤ (2:ℝ)^(23:Nat)) :
    ∃ hs', stepTrace M K w n token.val hs =
        some (Sampling.GreedySampling.sample K.sampling (p.run c token (RopeInputConstruction.inputs n)).1, hs') ∧
      ChainHolds p.graph.stages hs' (p.run c token (RopeInputConstruction.inputs n)).2 := by
  obtain ⟨x, e1, tx⟩ := embed M p.embedding w.embedWords w.embedScales w.embedBiases hl.embedding token
  obtain ⟨hidden, hs', e2, th, hh'⟩ := chain M K p.graph.stages (stageWeights w) (stages_loaded M K p w hl) c hs hh
    x _ tx policy finite
  obtain ⟨h, e3, tn⟩ := GlueAttention.hidden_norm M p.graph.finalNorm hl.finalPlatform hidden w.finalNorm _ th hl.finalNorm
  obtain ⟨logits, e4, tl⟩ := plain_row M K w.head p.graph.output hl.head h _ tn
  have e5 := reshape_some logits [1, 248320] (by rw [tl.2.1]; rfl)
  have fl : Flat { logits with shape := [1, 248320] } [1, 248320] (p.run c token (RopeInputConstruction.inputs n)).1 :=
    ⟨tl.1, rfl, fun j => by exact Row.elems tl j⟩
  obtain ⟨r, e6, rd, rs, re⟩ := GlueKernels.normalized_argmax K _ _ fl primitive bound
  have e7 : itemUint32 r = some (r.elems 0) := by
    unfold itemUint32; rw [if_pos ⟨rd, by rw [Value.size_eq, rs]; rfl⟩]
  refine ⟨hs', ?_, hh'⟩
  unfold stepTrace
  rw [e1]; dsimp only [bind, Option.bind]
  rw [e2]; dsimp only [bind, Option.bind]
  rw [GlueAttention.eps_word, e3]; dsimp only [bind, Option.bind]
  rw [e4]; dsimp only [bind, Option.bind]
  rw [e5]; dsimp only [bind, Option.bind]
  rw [e6]; dsimp only [bind, Option.bind]
  rw [e7, re]; rfl

end Host.Mlx.GlueStep
