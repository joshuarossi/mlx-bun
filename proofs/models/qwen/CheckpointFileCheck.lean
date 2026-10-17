import models.qwen.CheckpointFile
import models.qwen.CheckpointNormalizationData
import models.qwen.CheckpointDeltaData
import models.qwen.CheckpointConvolutionData
import models.qwen.CheckpointTrellisData
import models.qwen.CheckpointAffineDictionaryData

namespace Inference.Models.Qwen.CheckpointFileCheck
open Contracts.Mlx CheckpointFile
open FloatLib FloatLib.Floats FloatLib.Floats.Formats.BinaryInterchange
abbrev BF := BFloat16Arithmetic.Value

-- Lean replacement for the checkpoint-*.ts attachment scripts: `check` reads
-- the literal tensors from safetensors bytes and compares them with the
-- proof-facing literal definitions. Only the ranged reads stay trusted
-- (`Faithful`); parsing and comparison are inside the soundness theorem.
def bf (b : ByteArray) (i : Nat) : BF := Model.ofBits (BitVec.ofNat 16 (word b i))
def f16 (b : ByteArray) (i : Nat) : Float16.Value := Model.ofBits (BitVec.ofNat 16 (word b i))

def layer (l : Nat) (suffix : String) : String := "model.language_model.layers." ++ toString l ++ "." ++ suffix
/-- Delta layers 0,1,2,4,5,6,8,... in literal-row order. -/
def delta (j : Nat) : Nat := j + j/3

/-- Named tensor in the checkpoint with this dtype, shape and a 2-byte-word payload. -/
def Stored (index : ByteArray) (disk : String → ByteArray) (name dtype : String) (shape : List Nat)
    (bytes : ByteArray) : Prop :=
  ∃ shard e, weightMap index name = some shard ∧ tensor (disk shard) name = some (e, bytes) ∧
    e.dtype = dtype ∧ e.shape = shape ∧ bytes.size = 2 * shape.prod

def mainNormNames : List String :=
  (List.range 64).flatMap (fun l => [layer l "input_layernorm.weight", layer l "post_attention_layernorm.weight"]) ++
    ["model.language_model.norm.weight"]

def projection (pre : String) (shape : List Nat) : List (String × List Nat × List BF) :=
  [(pre ++ ".scales", shape, CheckpointAffineDictionaryData.projectionScalesDictionary),
   (pre ++ ".biases", shape, CheckpointAffineDictionaryData.projectionBiasesDictionary)]

/-- The 612 affine scale/bias tensors whose alphabets the dictionaries certify. -/
def affineTensors : List (String × List Nat × List BF) :=
  [("model.language_model.embed_tokens.scales", [248320, 80], CheckpointAffineDictionaryData.embeddingScalesDictionary),
   ("model.language_model.embed_tokens.biases", [248320, 80], CheckpointAffineDictionaryData.embeddingBiasesDictionary)] ++
  projection "lm_head" [248320, 80] ++
  (List.range 64).flatMap fun l =>
    if l % 4 = 3 then
      projection (layer l "self_attn.q_proj") [12288, 80] ++ projection (layer l "self_attn.k_proj") [1024, 80] ++
      projection (layer l "self_attn.v_proj") [1024, 80] ++ projection (layer l "self_attn.o_proj") [5120, 96]
    else
      projection (layer l "linear_attn.in_proj_qkv") [10240, 80] ++ projection (layer l "linear_attn.in_proj_z") [6144, 80] ++
      projection (layer l "linear_attn.in_proj_a") [48, 80] ++ projection (layer l "linear_attn.in_proj_b") [48, 80] ++
      projection (layer l "linear_attn.out_proj") [5120, 96]

structure Accepted (index : ByteArray) (disk : String → ByteArray) : Prop where
  mainNorm : ∀ name ∈ mainNormNames, ∃ b, Stored index disk name "BF16" [5120] b ∧
    ∀ i : Fin 5120, bf b i = CheckpointRanges.zeroCap
  query : ∀ k : Fin 16, ∃ b, Stored index disk (layer (4*k.val+3) "self_attn.q_norm.weight") "BF16" [256] b ∧
    ∀ i : Fin 256, bf b i = CheckpointNormalizationData.rawHead CheckpointNormalizationData.queryIndices k i
  key : ∀ k : Fin 16, ∃ b, Stored index disk (layer (4*k.val+3) "self_attn.k_norm.weight") "BF16" [256] b ∧
    ∀ i : Fin 256, bf b i = CheckpointNormalizationData.rawHead CheckpointNormalizationData.keyIndices k i
  aLog : ∀ j : Fin 48, ∃ b, Stored index disk (layer (delta j) "linear_attn.A_log") "BF16" [48] b ∧
    ∀ i : Fin 48, bf b i = CheckpointDeltaData.aLog j i
  dtBias : ∀ j : Fin 48, ∃ b, Stored index disk (layer (delta j) "linear_attn.dt_bias") "BF16" [48] b ∧
    ∀ i : Fin 48, bf b i = CheckpointDeltaData.dtBias j i
  gatedNorm : ∀ j : Fin 48, ∃ b, Stored index disk (layer (delta j) "linear_attn.norm.weight") "BF16" [128] b ∧
    ∀ i : Fin 128, bf b i = CheckpointDeltaData.gatedNorm j i
  convolution : ∀ j : Fin 48, ∃ b, Stored index disk (layer (delta j) "linear_attn.conv1d.weight") "BF16" [10240, 1, 4] b ∧
    ∀ (c : Fin 10240) (t : Fin 4), bf b (4*c.val+t.val) = CheckpointConvolutionData.weight j c t
  gate : ∀ l : Fin 64, ∃ b, Stored index disk (layer l "mlp.gate_proj.scales") "F16" [17408] b ∧
    ∀ r : Fin 17408, f16 b r = CheckpointTrellisData.raw CheckpointTrellisData.gateDictionary
      CheckpointTrellisData.gateDictionary_positive CheckpointTrellisData.gateChunks l r
  up : ∀ l : Fin 64, ∃ b, Stored index disk (layer l "mlp.up_proj.scales") "F16" [17408] b ∧
    ∀ r : Fin 17408, f16 b r = CheckpointTrellisData.raw CheckpointTrellisData.upDictionary
      CheckpointTrellisData.upDictionary_positive CheckpointTrellisData.upChunks l r
  down : ∀ l : Fin 64, ∃ b, Stored index disk (layer l "mlp.down_proj.scales") "F16" [17408] b ∧
    ∀ r : Fin 17408, f16 b r = CheckpointTrellisData.raw CheckpointTrellisData.downDictionary
      CheckpointTrellisData.downDictionary_positive CheckpointTrellisData.downChunks l r
  affine : ∀ t ∈ affineTensors, ∃ b, Stored index disk t.1 "BF16" t.2.1 b ∧ ∀ i < t.2.1.prod, bf b i ∈ t.2.2

/-- Index bytes and ranged views of the shards, as produced by the runner. -/
structure Files where
  index : ByteArray
  shards : List (String × View)

def Faithful (files : Files) (disk : String → ByteArray) : Prop :=
  ∀ s v, (s, v) ∈ files.shards → v.Faithful (disk s)

structure Prepared where
  map : List (String × Json)
  shards : List (String × View × Option (List (String × Json)))

def prepare (files : Files) : Option Prepared :=
  match parse files.index with
  | some (.obj kvs) =>
    match lookup1 "weight_map" kvs with
    | some (.obj m) => some ⟨m, files.shards.map fun sv => (sv.1, sv.2, header sv.2.head)⟩
    | _ => none
  | _ => none

def find (p : Prepared) (name : String) : Option (Entry × ByteArray) :=
  match lookup1 name p.map with
  | some (.str s) =>
    match p.shards.find? (·.1 == s) with
    | some (_, v, some kvs) => v.tensorWith kvs name
    | _ => none
  | _ => none

def tensorCheck (p : Prepared) (name dtype : String) (shape : List Nat) (ok : ByteArray → Bool) : Bool :=
  match find p name with
  | some (e, b) => decide (e.dtype = dtype ∧ e.shape = shape ∧ b.size = 2 * shape.prod) && ok b
  | none => false

def finAll (n : Nat) (p : Fin n → Bool) : Bool := (List.finRange n).all p
def exact (n : Nat) (f : Fin n → BF) (b : ByteArray) : Bool := finAll n fun i => decide (bf b i = f i)
/-- Packed-dictionary comparison over arrays; `packed_read` equates it with `PackedDictionary.read`. -/
def packed (decode : ByteArray → Nat → Model fmt) (dictionary : Array (Model fmt)) (base : Nat) (row : Array Nat)
    (count : Nat) (fallback : Model fmt) (b : ByteArray) : Bool :=
  finAll count fun i => decide (decode b i = dictionary[(row[i.val/32]?.getD 0) / base^(i.val%32) % base]?.getD fallback)
def alphabet (d : List BF) : ByteArray := table (d.map (·.bits.toNat))

def check (files : Files) : Bool :=
  match prepare files with
  | some p =>
    mainNormNames.all (fun name => tensorCheck p name "BF16" [5120] (exact 5120 fun _ => CheckpointRanges.zeroCap)) &&
    finAll 16 (fun k => tensorCheck p (layer (4*k.val+3) "self_attn.q_norm.weight") "BF16" [256]
      (exact 256 (CheckpointNormalizationData.rawHead CheckpointNormalizationData.queryIndices k))) &&
    finAll 16 (fun k => tensorCheck p (layer (4*k.val+3) "self_attn.k_norm.weight") "BF16" [256]
      (exact 256 (CheckpointNormalizationData.rawHead CheckpointNormalizationData.keyIndices k))) &&
    finAll 48 (fun j => tensorCheck p (layer (delta j) "linear_attn.A_log") "BF16" [48] (exact 48 (CheckpointDeltaData.aLog j))) &&
    finAll 48 (fun j => tensorCheck p (layer (delta j) "linear_attn.dt_bias") "BF16" [48] (exact 48 (CheckpointDeltaData.dtBias j))) &&
    finAll 48 (fun j => tensorCheck p (layer (delta j) "linear_attn.norm.weight") "BF16" [128]
      (exact 128 (CheckpointDeltaData.gatedNorm j))) &&
    finAll 48 (fun j => tensorCheck p (layer (delta j) "linear_attn.conv1d.weight") "BF16" [10240, 1, 4]
      (packed bf CheckpointConvolutionData.dictionary.toArray CheckpointConvolutionData.dictionary.length
        (CheckpointConvolutionData.chunks[j.val]?.getD []).toArray 40960 CheckpointRanges.zeroCap)) &&
    finAll 64 (fun l => tensorCheck p (layer l "mlp.gate_proj.scales") "F16" [17408]
      (packed f16 CheckpointTrellisData.gateDictionary.toArray CheckpointTrellisData.gateDictionary.length
        (CheckpointTrellisData.gateChunks[l.val]?.getD []).toArray 17408 (Model.ofBits 0))) &&
    finAll 64 (fun l => tensorCheck p (layer l "mlp.up_proj.scales") "F16" [17408]
      (packed f16 CheckpointTrellisData.upDictionary.toArray CheckpointTrellisData.upDictionary.length
        (CheckpointTrellisData.upChunks[l.val]?.getD []).toArray 17408 (Model.ofBits 0))) &&
    finAll 64 (fun l => tensorCheck p (layer l "mlp.down_proj.scales") "F16" [17408]
      (packed f16 CheckpointTrellisData.downDictionary.toArray CheckpointTrellisData.downDictionary.length
        (CheckpointTrellisData.downChunks[l.val]?.getD []).toArray 17408 (Model.ofBits 0))) &&
    affineTensors.all (fun t => tensorCheck p t.1 "BF16" t.2.1 fun b => allWords (alphabet t.2.2) b t.2.1.prod)
  | none => false

/-- Every tensor name `check` reads; the runner loads exactly these ranges. -/
def required : List String :=
  mainNormNames ++
  (List.range 16).flatMap (fun k => [layer (4*k+3) "self_attn.q_norm.weight", layer (4*k+3) "self_attn.k_norm.weight"]) ++
  (List.range 48).flatMap (fun j => ["linear_attn.A_log", "linear_attn.dt_bias", "linear_attn.norm.weight",
    "linear_attn.conv1d.weight"].map (layer (delta j))) ++
  (List.range 64).flatMap (fun l => ["mlp.gate_proj.scales", "mlp.up_proj.scales", "mlp.down_proj.scales"].map (layer l)) ++
  affineTensors.map (·.1)

theorem finAll_sound {n : Nat} {p : Fin n → Bool} (h : finAll n p = true) (i : Fin n) : p i = true :=
  List.all_eq_true.mp h i (List.mem_finRange i)

theorem exact_sound {n : Nat} {f : Fin n → BF} {b : ByteArray} (h : exact n f b = true) (i : Fin n) : bf b i = f i :=
  of_decide_eq_true (finAll_sound h i)

theorem packed_sound {decode : ByteArray → Nat → Model fmt} (dictionary : List (Model fmt))
    (positive : 0 < dictionary.length) (row : List Nat) {count : Nat} {fallback : Model fmt} {b : ByteArray}
    (h : packed decode dictionary.toArray dictionary.length row.toArray count fallback b = true) (i : Fin count) :
    decode b i = PackedDictionary.read dictionary positive (row[i.val/32]?.getD 0) (i.val%32) := by
  have hi := of_decide_eq_true (finAll_sound h i)
  have hlt : (row[i.val/32]?.getD 0) / dictionary.length^(i.val%32) % dictionary.length < dictionary.length :=
    Nat.mod_lt _ positive
  simp only [List.getElem?_toArray, List.getElem?_eq_getElem hlt, Option.getD_some] at hi
  exact hi

theorem alphabet_sound (d : List BF) (b : ByteArray) (n : Nat) (h : allWords (alphabet d) b n = true) :
    ∀ i < n, bf b i ∈ d := by
  intro i hi
  obtain ⟨x, hx, hw⟩ := List.mem_map.mp (table_mem _ _ (allWords_sound _ b n h i hi))
  have hb : bf b i = x := by
    unfold bf
    rw [← hw]
    cases x with
    | mk bits =>
      congr 1
      apply BitVec.eq_of_toNat_eq
      simp only [BitVec.toNat_ofNat]
      exact Nat.mod_eq_of_lt bits.isLt
  exact hb ▸ hx

theorem find_sound (files : Files) (disk : String → ByteArray) (faithful : Faithful files disk) {p : Prepared}
    (hp : prepare files = some p) {name : String} {t : Entry × ByteArray} (hf : find p name = some t) :
    ∃ shard, weightMap files.index name = some shard ∧ tensor (disk shard) name = some t := by
  unfold prepare at hp
  split at hp
  · next kvs hparse =>
    split at hp
    · next m hm =>
      cases hp
      unfold find at hf
      split at hf
      · next s hs =>
        split at hf
        · next s' v kvs' hfind =>
          have hmem := List.mem_of_find?_eq_some hfind
          have hname := List.find?_some hfind
          simp only [beq_iff_eq] at hname
          obtain ⟨sv, hsv, heq⟩ := List.mem_map.mp hmem
          simp only [Prod.mk.injEq] at heq
          obtain ⟨h1, h2, h3⟩ := heq
          refine ⟨s, ?_, ?_⟩
          · unfold weightMap
            rw [hparse]
            simp only [hm, hs]
          · have hv : v.Faithful (disk s) := by
              rw [← hname, ← h1, ← h2]
              exact faithful sv.1 sv.2 hsv
            exact tensorWith_sound v (disk s) hv (h2 ▸ h3) hf
        · exact absurd hf (by simp)
      · exact absurd hf (by simp)
    · exact absurd hp (by simp)
  · exact absurd hp (by simp)

theorem tensorCheck_sound (files : Files) (disk : String → ByteArray) (faithful : Faithful files disk) {p : Prepared}
    (hp : prepare files = some p) {name dtype : String} {shape : List Nat} {ok : ByteArray → Bool}
    (h : tensorCheck p name dtype shape ok = true) :
    ∃ b, Stored files.index disk name dtype shape b ∧ ok b = true := by
  unfold tensorCheck at h
  split at h
  · next e b hf =>
    simp only [Bool.and_eq_true, decide_eq_true_eq] at h
    obtain ⟨shard, hw, ht⟩ := find_sound files disk faithful hp hf
    exact ⟨b, ⟨shard, e, hw, ht, h.1.1, h.1.2.1, h.1.2.2⟩, h.2⟩
  · exact absurd h (by simp)

theorem check_sound (files : Files) (disk : String → ByteArray) (faithful : Faithful files disk)
    (h : check files = true) : Accepted files.index disk := by
  unfold check at h
  split at h
  · next p hp =>
    simp only [Bool.and_eq_true] at h
    obtain ⟨⟨⟨⟨⟨⟨⟨⟨⟨⟨hmain, hq⟩, hk⟩, ha⟩, hd⟩, hn⟩, hc⟩, hg⟩, hu⟩, hdn⟩, haff⟩ := h
    have family := fun {name dtype shape ok} (h : tensorCheck p name dtype shape ok = true) =>
      tensorCheck_sound files disk faithful hp h
    refine ⟨?_, ?_, ?_, ?_, ?_, ?_, ?_, ?_, ?_, ?_, ?_⟩
    · intro name hname
      obtain ⟨b, hs, hb⟩ := family (List.all_eq_true.mp hmain name hname)
      exact ⟨b, hs, exact_sound hb⟩
    · intro k
      obtain ⟨b, hs, hb⟩ := family (finAll_sound hq k)
      exact ⟨b, hs, exact_sound hb⟩
    · intro k
      obtain ⟨b, hs, hb⟩ := family (finAll_sound hk k)
      exact ⟨b, hs, exact_sound hb⟩
    · intro j
      obtain ⟨b, hs, hb⟩ := family (finAll_sound ha j)
      exact ⟨b, hs, exact_sound hb⟩
    · intro j
      obtain ⟨b, hs, hb⟩ := family (finAll_sound hd j)
      exact ⟨b, hs, exact_sound hb⟩
    · intro j
      obtain ⟨b, hs, hb⟩ := family (finAll_sound hn j)
      exact ⟨b, hs, exact_sound hb⟩
    · intro j
      obtain ⟨b, hs, hb⟩ := family (finAll_sound hc j)
      refine ⟨b, hs, fun c t => ?_⟩
      have hct : 4*c.val+t.val < 40960 := by omega
      exact packed_sound CheckpointConvolutionData.dictionary CheckpointConvolutionData.dictionary_positive _ hb ⟨_, hct⟩
    · intro l
      obtain ⟨b, hs, hb⟩ := family (finAll_sound hg l)
      exact ⟨b, hs, packed_sound CheckpointTrellisData.gateDictionary CheckpointTrellisData.gateDictionary_positive _ hb⟩
    · intro l
      obtain ⟨b, hs, hb⟩ := family (finAll_sound hu l)
      exact ⟨b, hs, packed_sound CheckpointTrellisData.upDictionary CheckpointTrellisData.upDictionary_positive _ hb⟩
    · intro l
      obtain ⟨b, hs, hb⟩ := family (finAll_sound hdn l)
      exact ⟨b, hs, packed_sound CheckpointTrellisData.downDictionary CheckpointTrellisData.downDictionary_positive _ hb⟩
    · intro t ht
      obtain ⟨b, hs, hb⟩ := family (List.all_eq_true.mp haff t ht)
      exact ⟨b, hs, alphabet_sound t.2.2 b t.2.1.prod hb⟩
  · exact absurd h (by simp)

end Inference.Models.Qwen.CheckpointFileCheck
