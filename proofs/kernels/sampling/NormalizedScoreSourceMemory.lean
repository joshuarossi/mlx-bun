import kernels.sampling.NormalizedScoreSourceSyntax
import kernels.sampling.NormalizedArgmaxMemory

namespace Inference.Kernels.Sampling.NormalizedScoreSourceMemory
open Contracts.Mlx NormalizedScoreSourceSyntax ArgmaxPairs
open FloatLib FloatLib.Floats FloatLib.Floats.Formats.BinaryInterchange
set_option maxRecDepth 10000

inductive Value where
  | uint : BitVec 32 → Value
  | bf : ArrayStorage.BF → Value
  | floating : Float32 → Value
  | boolean : Bool → Value
abbrev Env := String → Option Value

def set (env : Env) (name : String) (value : Value) : Env := fun other => if other=name then some value else env other

def evaluate (source normalizer : Nat) (memory : ByteMemory.Bytes) (env : Env) : Expr → Option Value
  | .variable name => env name
  | .index name expression => do
    match ←evaluate source normalizer memory env expression with
    | .uint index =>
      if name="logits" then pure (.bf (Model.ofBits (HalfMemory.load memory (source+2*index.toNat))))
      else if name="lse" then pure (.bf (Model.ofBits (HalfMemory.load memory (normalizer+2*index.toNat))))
      else none
    | _ => none
  | .add a b => do
    match ←evaluate source normalizer memory env a,←evaluate source normalizer memory env b with
    | .uint x,.uint y => pure (.uint (x+y)) | _,_ => none
  | .multiply a b => do
    match ←evaluate source normalizer memory env a,←evaluate source normalizer memory env b with
    | .uint x,.uint y => pure (.uint (x*y)) | _,_ => none
  | .subtract a b => do
    match ←evaluate source normalizer memory env a,←evaluate source normalizer memory env b with
    | .bf x,.bf y => pure (.bf (BFloat16Arithmetic.sub x y)) | _,_ => none
  | .call name expression => do
    match name,←evaluate source normalizer memory env expression with
    | "T",.bf x => pure (.bf x)
    | "float",.bf x => pure (.floating (BFloat16.widen x))
    | "isnan",.floating x => pure (.boolean (Model.isNaN (Numerics.model x)))
    | _,_ => none
  | .negativeInfinity => some (.floating LogSumExpExponentRanges.negativeInfinity)
  | .conditional test yes no => do
    match ←evaluate source normalizer memory env test with
    | .boolean condition => if condition then evaluate source normalizer memory env yes else evaluate source normalizer memory env no
    | _ => none

def execute (source normalizer : Nat) (memory : ByteMemory.Bytes) (env : Env) : Stmt → Option Env
  | .floatDeclaration name expression => do
    match ←evaluate source normalizer memory env expression with
    | .floating value => pure (set env name (.floating value)) | _ => none
  | .assign name expression => do
    let value ←evaluate source normalizer memory env expression
    pure (set env name value)

def environment (index : Nat) : Env := fun name =>
  if name="row" then some (.uint 0) else if name="V" then some (.uint 248320)
  else if name="i" then some (.uint (BitVec.ofNat 32 index)) else none

def run (source normalizer index : Nat) (memory : ByteMemory.Bytes) : Option Float32 := do
  let first ←parseFirst sourceBody
  let env ←execute source normalizer memory (environment index) first
  let clean ←parseClean cleanBody
  let env ←execute source normalizer memory env clean
  match ←env "value" with
  | .floating value => some value | _ => none

def raw (source normalizer index : Nat) (memory : ByteMemory.Bytes) : Float32 :=
  NormalizedScores.value (Model.ofBits (HalfMemory.load memory (source+2*index)))
    (Model.ofBits (HalfMemory.load memory normalizer))

def sanitize (value : Float32) : Float32 :=
  if Model.isNaN (Numerics.model value) then LogSumExpExponentRanges.negativeInfinity else value

-- Native bfloat subtraction and bfloat/float casts are the existing explicit
-- primitive correspondence boundary. The parsed arithmetic retains both casts
-- and the bfloat subtraction; it never substitutes raw-logit argmax.
attribute [local irreducible] BFloat16Arithmetic.sub BFloat16.widen

theorem execution (source normalizer index : Nat) (small : index<2^32) (memory : ByteMemory.Bytes) :
    run source normalizer index memory=some (sanitize (raw source normalizer index memory)) := by
  change index<4294967296 at small
  unfold run
  rw [parsed_source,parsed_clean]
  simp [execute,evaluate,environment,set,sourceExpr,cleanExpr,raw,sanitize,
    NormalizedScores.value,NormalizedScores.stored,BitVec.toNat_ofNat,Nat.mod_eq_of_lt small]
  split <;> simp_all [set]

-- Finiteness is proved from the original bounds; it discharges the source
-- isnan branch without assuming a sanitized result or silently excluding NaNs.
theorem sanitize_finite (value : Float32) (finite : value.isFinite=true) : sanitize value=value := by
  have hf : Model.isFinite (Numerics.model value)=true := by rw [Numerics.finite_model]; exact finite
  simp only [sanitize,Model.isNaN_eq_false_of_isFinite_eq_true _ hf,Bool.false_eq_true,ite_false]

theorem raw_buffers {logits : Fin 248320 → ArrayStorage.BF} {normalizer : ArrayStorage.BF}
    (input : ArrayStorage.BFBuffer logits) (scalar : ArrayStorage.BFBuffer (fun _ : Fin 1 => normalizer))
    (memory : ByteMemory.Bytes) (inputShared : input.bytes=memory) (scalarShared : scalar.bytes=memory)
    (index : Fin 248320) : raw input.base scalar.base index.val memory=NormalizedScores.value (logits index) normalizer := by
  have logit := input.read_correct index
  have value := scalar.read_correct 0
  change (Model.ofBits (HalfMemory.load input.bytes (input.base+2*index.val)) : ArrayStorage.BF)=logits index at logit
  change (Model.ofBits (HalfMemory.load scalar.bytes scalar.base) : ArrayStorage.BF)=normalizer at value
  rw [inputShared] at logit
  rw [scalarShared] at value
  unfold raw
  rw [logit,value]

theorem run_buffers {logits : Fin 248320 → ArrayStorage.BF} {normalizer : ArrayStorage.BF}
    (input : ArrayStorage.BFBuffer logits) (scalar : ArrayStorage.BFBuffer (fun _ : Fin 1 => normalizer))
    (memory : ByteMemory.Bytes) (inputShared : input.bytes=memory) (scalarShared : scalar.bytes=memory)
    (bound : ∀ i, Model.isFinite (logits i)=true ∧ |Model.toReal (logits i)|≤(2:ℝ)^(23:Nat))
    (scalarBound : Model.isFinite normalizer=true ∧ |Model.toReal normalizer|≤(2:ℝ)^(24:Nat)) (index : Fin 248320) :
    run input.base scalar.base index.val memory=some (NormalizedScores.value (logits index) normalizer) := by
  rw [execution _ _ _ (by have := index.isLt; omega),raw_buffers input scalar memory inputShared scalarShared index]
  rw [sanitize_finite _ (NormalizedScores.ranges _ _ (bound index) scalarBound).1]

variable {logits : Fin 248320 → ArrayStorage.BF} {platform : LogSumExpRanges.Platform}
  {source : ArrayStorage.BFBuffer logits} (lse : LogSumExpMemory.Execution platform source)

def candidate (index : Fin 248320) : Option Candidate :=
  (run source.base lse.destination index.val lse.memory).map (fun value => ⟨some value,index.val⟩)

theorem raw_eq (index : Fin 248320) : raw source.base lse.destination index.val lse.memory=
    NormalizedScores.value (logits index) (LogSumExpRanges.value platform logits) := by
  have logit := lse.logitsAfter.read_correct index
  have scalar := lse.buffer.read_correct 0
  change (Model.ofBits (HalfMemory.load lse.memory (source.base+2*index.val)) : ArrayStorage.BF)=logits index at logit
  change (Model.ofBits (HalfMemory.load lse.memory lse.destination) : ArrayStorage.BF)=LogSumExpRanges.value platform logits at scalar
  unfold raw
  rw [logit,scalar]

theorem candidate_eq (primitive : LogSumExpRanges.Primitives platform)
    (bound : ∀ i, Model.isFinite (logits i)=true ∧ |Model.toReal (logits i)|≤(2:ℝ)^(23:Nat)) (index : Fin 248320) :
    candidate lse index=some (NormalizedArgmaxMemory.candidates lse index) := by
  have finite := (NormalizedScores.ranges (logits index) (LogSumExpRanges.value platform logits) (bound index)
    (LogSumExpRanges.bf16_ranges platform primitive logits bound).2).1
  unfold candidate
  rw [execution _ _ _ (by have := index.isLt; omega),raw_eq lse index,sanitize_finite _ finite]
  rw [NormalizedArgmaxMemory.candidates_eq]
  rfl

-- Other lanes may already have written partial results. Read the same current
-- heap supplied by the existing frame proof, rather than swapping in an encoded
-- or initial source image while claiming source execution.
theorem during_candidate (selection : NormalizedArgmaxMemory.Execution lse)
    (stores : List ByteMemory.Store) (subset : ∀ store∈stores, store∈selection.partials.schedule)
    (primitive : LogSumExpRanges.Primitives platform)
    (bound : ∀ i, Model.isFinite (logits i)=true ∧ |Model.toReal (logits i)|≤(2:ℝ)^(23:Nat)) (index : Fin 248320) :
    (run source.base lse.destination index.val (ByteMemory.execute stores selection.partials.before)).map
      (fun value => (⟨some value,index.val⟩ : Candidate))=some (NormalizedArgmaxMemory.candidates lse index) := by
  have read := run_buffers (selection.logitsDuring stores subset) (selection.lseDuring stores subset)
    (ByteMemory.execute stores selection.partials.before) rfl rfl bound
    (LogSumExpRanges.bf16_ranges platform primitive logits bound).2 index
  change run source.base lse.destination index.val (ByteMemory.execute stores selection.partials.before)=
    some (NormalizedScores.value (logits index) (LogSumExpRanges.value platform logits)) at read
  rw [read,NormalizedArgmaxMemory.candidates_eq]
  rfl

def laneValues (tile : Fin 243) (thread : Fin 128) : Option (List Candidate) :=
  (NormalizedArgmaxLayout.partialOffsets tile thread).attach.mapM (fun index =>
    candidate lse ⟨index.val,NormalizedArgmaxLayout.visited_in_bounds tile thread index.val index.property⟩)

private theorem mapM_some {α β : Type} (items : List α) (f : α → Option β) (g : α → β)
    (same : ∀ item∈items, f item=some (g item)) : items.mapM f=some (items.map g) := by
  induction items with
  | nil => rfl
  | cons item rest ih =>
    simp only [List.mapM_cons,same item (by simp),List.map_cons]
    rw [ih (fun value member => same value (by simp [member]))]
    rfl

theorem lane_values_eq (primitive : LogSumExpRanges.Primitives platform)
    (bound : ∀ i, Model.isFinite (logits i)=true ∧ |Model.toReal (logits i)|≤(2:ℝ)^(23:Nat))
    (tile : Fin 243) (thread : Fin 128) :
    laneValues lse tile thread=some (NormalizedArgmaxExecution.partialValues (NormalizedArgmaxMemory.candidates lse) tile thread) := by
  unfold laneValues NormalizedArgmaxExecution.partialValues
  apply mapM_some
  intro index _member
  exact candidate_eq lse primitive bound _

theorem lane_scan_eq (primitive : LogSumExpRanges.Primitives platform)
    (bound : ∀ i, Model.isFinite (logits i)=true ∧ |Model.toReal (logits i)|≤(2:ℝ)^(23:Nat))
    (tile : Fin 243) (thread : Fin 128) :
    (laneValues lse tile thread).map (fun values => scan values sentinel)=
      some (NormalizedArgmaxExecution.partialLane (NormalizedArgmaxMemory.candidates lse) tile thread) := by
  rw [lane_values_eq lse primitive bound tile thread]
  rfl

end Inference.Kernels.Sampling.NormalizedScoreSourceMemory
