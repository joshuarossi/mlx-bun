import kernels.attention.MlxSdpaVectorDispatch

namespace Inference.Kernels.Attention.MlxSdpaScoreSource
open Contracts.Mlx State
open Copy.ScalarCopySyntax (Tokens decimal)
open Normalization.MlxRmsLoopSyntax (acceptAll word)
open FloatLib FloatLib.Floats FloatLib.Floats.Formats.BinaryInterchange
set_option maxRecDepth 10000
set_option maxHeartbeats 1000000

def lex : Nat → List Char → Option Tokens
  | 0,_ => none
  | _+1,[] => some []
  | fuel+1,c::rest =>
    if [' ','\n','\t','\r'].contains c then lex fuel rest
    else if word c then do pure (String.ofList (c::rest.takeWhile word)::(←lex fuel (rest.dropWhile word)))
    else if ['(',')','[',']','{','}',';','=','+','*','<','>','-',':',','].contains c then do
      pure (String.singleton c::(←lex fuel rest)) else none

structure Dot where
  initial : Nat
  first : Nat
  deriving DecidableEq, Repr

def parse (source : String) : Option Dot := do
  let ts ←lex (source.length+1) source.toList
  let rest ←acceptAll ["U","score","="] ts
  let (initial,rest) ←Normalization.MlxRmsLoopSyntax.natural rest
  let rest ←acceptAll [";","for","(","int","j","="] rest
  let (first,rest) ←Normalization.MlxRmsLoopSyntax.natural rest
  let rest ←acceptAll [";","j","<","qk_per_thread",";","j","+","+",")","{",
    "score","+","=","q","[","j","]","*","k","[","j","]",";","}",
    "score","=","simd_sum","(","score",")",";"] rest
  if rest=[] then some ⟨initial,first⟩ else none

def sourceBody : String := r#"U score = 0;
      for (int j = 0; j < qk_per_thread; j++) {
        score += q[j] * k[j];
      }
      score = simd_sum(score);"#
theorem parsed : parse sourceBody=some ⟨0,0⟩ := by decide +kernel

def thread (group lane : Fin 32) : Fin 1024 :=
  ⟨group.val*32+lane.val,by have := group.isLt; have := lane.isLt; omega⟩

theorem thread_lane (group lane : Fin 32) : SdpaQueryMemory.lane (thread group lane)=lane := by
  apply Fin.ext
  dsimp [SdpaQueryMemory.lane,thread]
  have := lane.isLt
  omega

-- The source BF16 key load is taken from the current allocation, while query
-- operands come from registers captured before any stores to their own head.
def keyValue (memory : ByteMemory.Bytes) (base capacity : Nat) (head : Fin 24)
    (group lane : Fin 32) (iteration : Nat) (item : Fin 8) : Float32 :=
  BFloat16.widen (Model.ofBits (HalfMemory.load memory
    (base+2*MlxSdpaVectorMemory.keyAddress capacity head group lane iteration item)))

def laneValue (dot : Dot) (contracted : Bool) (registers : SdpaQueryMemory.Registers)
    (keys : Fin 8 → Float32) : Float32 :=
  ((List.finRange 8).drop dot.first).foldl (fun acc item =>
    ArithmeticFold.maddFloat contracted (FlushToZero.mul SdpaScore.scale (BFloat16.widen (Model.ofBits (registers item))))
      (keys item) acc) (if dot.initial=0 then 0 else Float32.ofInt dot.initial)

def source (contracted : Bool) (reduce : (Fin 32 → Float32) → Float32)
    (registers : Fin 32 → SdpaQueryMemory.Registers) (memory : ByteMemory.Bytes) (base capacity : Nat)
    (head : Fin 24) (group : Fin 32) (iteration : Nat) : Option Float32 := do
  let dot ←parse sourceBody
  pure (reduce (fun lane => laneValue dot contracted (registers lane)
    (keyValue memory base capacity head group lane iteration)))

theorem key_value {steps : Nat} {cache : Kv.Cache Kv.BF steps} (storage : KvRegions.Storage cache)
    (head : Fin 24) (group lane : Fin 32) (iteration : Fin (SdpaLayout.count steps group)) (item : Fin 8) :
    keyValue storage.memory storage.layout.keyBase (KvAllocation.capacity steps) head group lane iteration.val item=
      BFloat16.widen (cache.keys (SdpaScore.kvHead head) (SdpaLayout.key steps group iteration) (SdpaScore.index lane item)) := by
  unfold keyValue
  rw [MlxSdpaVectorMemory.key_address,SdpaAddresses.kv_address]
  exact congrArg (fun word : BitVec 16 => BFloat16.widen (Model.ofBits word))
    (storage.keys (SdpaScore.kvHead head) (SdpaLayout.key steps group iteration) (SdpaScore.index lane item))

-- No expected score or intermediate lane result is a premise. Only actual
-- captured-register evidence and the existing protected-current-cache proof
-- are consumed. The SIMD primitive and compiler FMA choice remain parameters.
theorem current_score {steps : Nat} {query : Fin 24 → Fin 256 → ArrayStorage.BF}
    {cache : Kv.Cache Kv.BF steps} {input : SdpaMemory.Input query cache}
    {p : SdpaVector.Platform} {architecture : Char}
    (execution : SdpaOnePassDonation.Execution input p architecture)
    {after : SdpaQueryMemory.Machine} {events : List (ReadBeforeOverwrite.Event 24 1024)}
    (run : ReadBeforeOverwrite.Executes (SdpaQueryMemory.layout execution.base) (SdpaQueryMemory.read execution.base)
      (ReadBeforeOverwrite.initial input.cache.memory) events after)
    (head : Fin 24) (group : Fin 32) (iteration : Fin (SdpaLayout.count steps group))
    (registers : Fin 32 → SdpaQueryMemory.Registers)
    (captured : ∀ lane, after.registers head (thread group lane)=some (registers lane)) :
    source p.scoreContracted p.merge.reduce registers after.memory input.cache.layout.keyBase
      (KvAllocation.capacity steps) head group iteration.val=
      some (SdpaVector.scores p (query head) (cache.keys (SdpaScore.kvHead head)) (SdpaLayout.key steps group iteration)) := by
  unfold source
  rw [parsed]
  change some (p.merge.reduce (fun lane => laneValue ⟨0,0⟩ p.scoreContracted (registers lane)
    (keyValue after.memory input.cache.layout.keyBase (KvAllocation.capacity steps) head group lane iteration.val)))=_
  unfold SdpaVector.scores SdpaScore.source
  apply congrArg some
  apply congrArg p.merge.reduce
  funext lane
  unfold laneValue
  simp only [List.drop_zero,↓reduceIte]
  have keys (item : Fin 8) : keyValue after.memory input.cache.layout.keyBase (KvAllocation.capacity steps) head group lane iteration.val item=
      BFloat16.widen (cache.keys (SdpaScore.kvHead head) (SdpaLayout.key steps group iteration) (SdpaScore.index lane item)) :=
    key_value (execution.intermediateCache run) head group lane iteration item
  have q : ∀ item, registers lane item=ArrayStorage.bits (query head (SdpaScore.index lane item)) := by
    intro item
    have same := execution.intermediate_capture run head (thread group lane) (registers lane) (captured lane) item
    rw [thread_lane] at same
    exact same
  have funcs : (fun acc item => ArithmeticFold.maddFloat p.scoreContracted
      (FlushToZero.mul SdpaScore.scale (BFloat16.widen (Model.ofBits (registers lane item))))
      (keyValue after.memory input.cache.layout.keyBase (KvAllocation.capacity steps) head group lane iteration.val item) acc)=
      (fun acc item => ArithmeticFold.maddFloat p.scoreContracted
        (FlushToZero.mul SdpaScore.scale (BFloat16.widen (query head (SdpaScore.index lane item))))
        (BFloat16.widen (cache.keys (SdpaScore.kvHead head) (SdpaLayout.key steps group iteration) (SdpaScore.index lane item))) acc) := by
    funext acc item
    rw [q item,keys item]
    rfl
  rw [funcs]

end Inference.Kernels.Attention.MlxSdpaScoreSource
