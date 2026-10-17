import kernels.attention.MlxSdpaScoreSource

namespace Inference.Kernels.Attention.MlxSdpaUpdateSource
open Contracts.Mlx State MlxSdpaScoreSource
open Normalization.MlxRmsLoopSyntax (acceptAll natural)
open FloatLib FloatLib.Floats FloatLib.Floats.Formats.BinaryInterchange
set_option maxRecDepth 10000
set_option maxHeartbeats 1000000

structure Update where
  first : Nat
  deriving DecidableEq, Repr

def parse (source : String) : Option Update := do
  let ts ←lex (source.length+1) source.toList
  let rest ←acceptAll ["U","new_max","=","max","(","max_score",",","score",")",";",
    "U","factor","=","fast",":",":","exp","(","max_score","-","new_max",")",";",
    "U","exp_score","=","fast",":",":","exp","(","score","-","new_max",")",";",
    "max_score","=","new_max",";",
    "sum_exp_score","=","sum_exp_score","*","factor","+","exp_score",";",
    "for","(","int","j","="] ts
  let (first,rest) ←natural rest
  let rest ←acceptAll [";","j","<","v_per_thread",";","j","+","+",")","{",
    "o","[","j","]","=","o","[","j","]","*","factor","+","exp_score","*","values","[","j","]",";","}"] rest
  if rest=[] then some ⟨first⟩ else none

def sourceBody : String := r#"U new_max = max(max_score, score);
      U factor = fast::exp(max_score - new_max);
      U exp_score = fast::exp(score - new_max);

      max_score = new_max;
      sum_exp_score = sum_exp_score * factor + exp_score;

      for (int j = 0; j < v_per_thread; j++) {
        o[j] = o[j] * factor + exp_score * values[j];
      }"#
theorem parsed : parse sourceBody=some ⟨0⟩ := by decide +kernel

-- The scalar description is one coordinate of the parsed eight-register
-- loop. The shared max/denominator are computed from the OLD max value.
def evaluate (ast : Update) (p : SdpaUpdate.Platform) (choose : Float32 → Float32 → Float32)
    (state : SdpaUpdate.State) (score value : Float32) (item : Fin 8) : SdpaUpdate.State :=
  let newMax := choose state.shift score
  let factor := p.exp (Arithmetic.sub state.shift newMax)
  let expScore := p.exp (Arithmetic.sub score newMax)
  let denominator := if p.sumContracted then FlushToZero.fma state.denominator factor expScore
    else FlushToZero.add (FlushToZero.mul state.denominator factor) expScore
  let numerator := if item.val<ast.first then state.numerator else
    match p.numeratorContracted with
    | .separate => FlushToZero.add (FlushToZero.mul state.numerator factor) (FlushToZero.mul expScore value)
    | .first => FlushToZero.fma state.numerator factor (FlushToZero.mul expScore value)
    | .second => FlushToZero.fma expScore value (FlushToZero.mul state.numerator factor)
  ⟨newMax,denominator,numerator⟩

theorem evaluate_eq (p : SdpaUpdate.Platform) (choose : Float32 → Float32 → Float32)
    (state : SdpaUpdate.State) (score value : Float32) (item : Fin 8) :
    evaluate ⟨0⟩ p choose state score value item=
      SdpaUpdate.step p state score value (choose state.shift score) := by
  simp only [evaluate,Nat.not_lt_zero,ite_false]
  rfl

def value (memory : ByteMemory.Bytes) (base capacity : Nat) (head : Fin 24)
    (group lane : Fin 32) (iteration : Nat) (item : Fin 8) : Float32 :=
  BFloat16.widen (Model.ofBits (HalfMemory.load memory
    (base+2*MlxSdpaVectorMemory.valueAddress capacity head group lane iteration item)))

theorem value_current {steps : Nat} {cache : Kv.Cache Kv.BF steps} (storage : KvRegions.Storage cache)
    (head : Fin 24) (group lane : Fin 32) (iteration : Fin (SdpaLayout.count steps group)) (item : Fin 8) :
    value storage.memory storage.layout.valueBase (KvAllocation.capacity steps) head group lane iteration.val item=
      BFloat16.widen (cache.values (SdpaScore.kvHead head) (SdpaLayout.key steps group iteration) (SdpaScore.index lane item)) := by
  unfold value
  rw [MlxSdpaVectorMemory.value_address,SdpaAddresses.kv_address]
  exact congrArg (fun word : BitVec 16 => BFloat16.widen (Model.ofBits word))
    (storage.values (SdpaScore.kvHead head) (SdpaLayout.key steps group iteration) (SdpaScore.index lane item))

def source (p : SdpaVector.Platform) (registers : Fin 32 → SdpaQueryMemory.Registers)
    (memory : ByteMemory.Bytes) (keyBase valueBase capacity : Nat) (head : Fin 24) (group lane : Fin 32)
    (iteration : Nat) (item : Fin 8) (state : SdpaUpdate.State) : Option SdpaUpdate.State := do
  let score ←MlxSdpaScoreSource.source p.scoreContracted p.merge.reduce registers memory keyBase capacity head group iteration
  let ast ←parse sourceBody
  pure (evaluate ast p.merge.scalar p.maximum state score (value memory valueBase capacity head group lane iteration item) item)

theorem current_update {steps : Nat} {query : Fin 24 → Fin 256 → ArrayStorage.BF}
    {cache : Kv.Cache Kv.BF steps} {input : SdpaMemory.Input query cache}
    {p : SdpaVector.Platform} {architecture : Char}
    (execution : SdpaOnePassDonation.Execution input p architecture)
    {after : SdpaQueryMemory.Machine} {events : List (ReadBeforeOverwrite.Event 24 1024)}
    (run : ReadBeforeOverwrite.Executes (SdpaQueryMemory.layout execution.base) (SdpaQueryMemory.read execution.base)
      (ReadBeforeOverwrite.initial input.cache.memory) events after)
    (head : Fin 24) (group lane : Fin 32) (iteration : Fin (SdpaLayout.count steps group))
    (registers : Fin 32 → SdpaQueryMemory.Registers)
    (captured : ∀ lane, after.registers head (thread group lane)=some (registers lane))
    (item : Fin 8) (state : SdpaUpdate.State) :
    source p registers after.memory input.cache.layout.keyBase input.cache.layout.valueBase
      (KvAllocation.capacity steps) head group lane iteration.val item state=
      some (SdpaLoop.next p.merge.scalar p.maximum
        (SdpaVector.scores p (query head) (cache.keys (SdpaScore.kvHead head)))
        (SdpaVector.valuesAt (cache.values (SdpaScore.kvHead head)) (SdpaScore.index lane item))
        (SdpaLayout.key steps group iteration) state) := by
  unfold source
  rw [MlxSdpaScoreSource.current_score execution run head group iteration registers captured,parsed]
  change some (evaluate ⟨0⟩ p.merge.scalar p.maximum state _ _ item)=_
  rw [evaluate_eq]
  have values : value after.memory input.cache.layout.valueBase (KvAllocation.capacity steps)
      head group lane iteration.val item=
      BFloat16.widen (cache.values (SdpaScore.kvHead head) (SdpaLayout.key steps group iteration) (SdpaScore.index lane item)) :=
    value_current (execution.intermediateCache run) head group lane iteration item
  rw [values]
  rfl

end Inference.Kernels.Attention.MlxSdpaUpdateSource
