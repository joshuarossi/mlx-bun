import kernels.attention.MlxSdpaUpdateSource

namespace Inference.Kernels.Attention.MlxSdpaFreshMemory
open Contracts.Mlx State
open FloatLib FloatLib.Floats FloatLib.Floats.Formats.BinaryInterchange
set_option maxRecDepth 10000
set_option maxHeartbeats 1000000

variable {steps : Nat} {query : Fin 24 → Fin 256 → ArrayStorage.BF} {cache : Kv.Cache Kv.BF steps}
  {input : SdpaMemory.Input query cache} {p : SdpaVector.Platform} {contracted : Bool} {arch : Char}
  (execution : SdpaOutputMemory.Execution input p contracted arch)
  (stores : List HalfMemory.Store)
  (inside : MemoryRegions.Inside16 execution.kernel.output.base 12288 stores)

def memory : ByteMemory.Bytes := HalfMemory.execute stores input.cache.memory

def currentCache : KvRegions.Storage cache :=
  input.cache.reframe (memory (input:=input) stores)
    (MemoryRegions.execute16_other stores input.cache.memory inside execution.keysSeparate)
    (MemoryRegions.execute16_other stores input.cache.memory inside execution.valuesSeparate)

def currentQuery (head : Fin 24) : ArrayStorage.BFBuffer (query head) :=
  ArrayFrame.bf (input.query head) (memory (input:=input) stores) (by
    intro offset bound
    exact (MemoryRegions.execute16_other stores input.cache.memory inside (execution.queriesSeparate head) offset bound).trans
      (congrFun (input.shared head) ((input.query head).base+offset)).symm)

def currentInput : SdpaMemory.Input query cache where
  cache := currentCache execution stores inside
  query := currentQuery execution stores inside
  shared := fun _ => rfl

def registers (queryBase : Nat) (head : Fin 24) (lane : Fin 32) : SdpaQueryMemory.Registers :=
  SdpaQueryMemory.read queryBase (memory (input:=input) stores) head (MlxSdpaScoreSource.thread 0 lane)

include execution inside

theorem register_value (queryBase : Nat)
    (heads : ∀ head, (input.query head).base=(SdpaQueryMemory.layout queryBase).base head)
    (head : Fin 24) (lane : Fin 32) (item : Fin 8) :
    registers (input:=input) stores queryBase head lane item=ArrayStorage.bits (query head (SdpaScore.index lane item)) := by
  have currentHeads : ∀ head, ((currentInput execution stores inside).query head).base=
      (SdpaQueryMemory.layout queryBase).base head := heads
  have loaded := SdpaQueryMemory.input_read (currentInput execution stores inside) queryBase currentHeads
    head (MlxSdpaScoreSource.thread 0 lane) item
  rw [MlxSdpaScoreSource.thread_lane] at loaded
  exact loaded

theorem query_load (queryBase : Nat)
    (heads : ∀ head, (input.query head).base=(SdpaQueryMemory.layout queryBase).base head)
    (head : Fin 24) (lane : Fin 32) (item : Fin 8) :
    MlxSdpaVectorMemory.querySource (memory (input:=input) stores) queryBase false head lane item SdpaScore.scale=
      some (FlushToZero.mul SdpaScore.scale (BFloat16.widen (query head (SdpaScore.index lane item)))) := by
  have parsed := MlxSdpaVectorMemory.query_current (memory (input:=input) stores) queryBase false
    head (MlxSdpaScoreSource.thread 0 lane) item
  rw [MlxSdpaScoreSource.thread_lane] at parsed
  change _=some (FlushToZero.mul SdpaScore.scale (BFloat16.widen
    (Model.ofBits (registers (input:=input) stores queryBase head lane item)))) at parsed
  rw [register_value execution stores inside queryBase heads] at parsed
  exact parsed

theorem score (queryBase : Nat)
    (heads : ∀ head, (input.query head).base=(SdpaQueryMemory.layout queryBase).base head)
    (head : Fin 24) (group : Fin 32) (iteration : Fin (SdpaLayout.count steps group)) :
    MlxSdpaScoreSource.source p.scoreContracted p.merge.reduce
      (registers (input:=input) stores queryBase head) (memory (input:=input) stores)
      input.cache.layout.keyBase (KvAllocation.capacity steps) head group iteration.val=
      some (SdpaVector.scores p (query head) (cache.keys (SdpaScore.kvHead head)) (SdpaLayout.key steps group iteration)) := by
  unfold MlxSdpaScoreSource.source
  rw [MlxSdpaScoreSource.parsed]
  change some (p.merge.reduce (fun lane => MlxSdpaScoreSource.laneValue ⟨0,0⟩ p.scoreContracted
    (registers (input:=input) stores queryBase head lane)
    (MlxSdpaScoreSource.keyValue (memory (input:=input) stores) input.cache.layout.keyBase
      (KvAllocation.capacity steps) head group lane iteration.val)))=_
  unfold SdpaVector.scores SdpaScore.source
  apply congrArg some
  apply congrArg p.merge.reduce
  funext lane
  unfold MlxSdpaScoreSource.laneValue
  simp only [List.drop_zero,↓reduceIte]
  have keys (item : Fin 8) :
      MlxSdpaScoreSource.keyValue (memory (input:=input) stores) input.cache.layout.keyBase
        (KvAllocation.capacity steps) head group lane iteration.val item=
        BFloat16.widen (cache.keys (SdpaScore.kvHead head) (SdpaLayout.key steps group iteration) (SdpaScore.index lane item)) :=
    MlxSdpaScoreSource.key_value (currentCache execution stores inside) head group lane iteration item
  have same : (fun acc item => ArithmeticFold.maddFloat p.scoreContracted
      (FlushToZero.mul SdpaScore.scale (BFloat16.widen (Model.ofBits (registers (input:=input) stores queryBase head lane item))))
      (MlxSdpaScoreSource.keyValue (memory (input:=input) stores) input.cache.layout.keyBase
        (KvAllocation.capacity steps) head group lane iteration.val item) acc)=
      (fun acc item => ArithmeticFold.maddFloat p.scoreContracted
        (FlushToZero.mul SdpaScore.scale (BFloat16.widen (query head (SdpaScore.index lane item))))
        (BFloat16.widen (cache.keys (SdpaScore.kvHead head) (SdpaLayout.key steps group iteration) (SdpaScore.index lane item))) acc) := by
    funext acc item
    rw [register_value execution stores inside queryBase heads,keys item]
    rfl
  rw [same]

theorem update (queryBase : Nat)
    (heads : ∀ head, (input.query head).base=(SdpaQueryMemory.layout queryBase).base head)
    (head : Fin 24) (group lane : Fin 32) (iteration : Fin (SdpaLayout.count steps group))
    (item : Fin 8) (state : SdpaUpdate.State) :
    MlxSdpaUpdateSource.source p (registers (input:=input) stores queryBase head) (memory (input:=input) stores)
      input.cache.layout.keyBase input.cache.layout.valueBase (KvAllocation.capacity steps)
      head group lane iteration.val item state=
      some (SdpaLoop.next p.merge.scalar p.maximum
        (SdpaVector.scores p (query head) (cache.keys (SdpaScore.kvHead head)))
        (SdpaVector.valuesAt (cache.values (SdpaScore.kvHead head)) (SdpaScore.index lane item))
        (SdpaLayout.key steps group iteration) state) := by
  unfold MlxSdpaUpdateSource.source
  rw [score execution stores inside queryBase heads,MlxSdpaUpdateSource.parsed]
  change some (MlxSdpaUpdateSource.evaluate ⟨0⟩ p.merge.scalar p.maximum state _ _ item)=_
  rw [MlxSdpaUpdateSource.evaluate_eq]
  have values : MlxSdpaUpdateSource.value (memory (input:=input) stores) input.cache.layout.valueBase
      (KvAllocation.capacity steps) head group lane iteration.val item=
      BFloat16.widen (cache.values (SdpaScore.kvHead head) (SdpaLayout.key steps group iteration) (SdpaScore.index lane item)) :=
    MlxSdpaUpdateSource.value_current (currentCache execution stores inside) head group lane iteration item
  rw [values]
  rfl

end Inference.Kernels.Attention.MlxSdpaFreshMemory
