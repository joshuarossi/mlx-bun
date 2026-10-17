import kernels.attention.MlxSdpaFreshPartialSource
import kernels.attention.MlxSdpaOutputSource

namespace Inference.Kernels.Attention.MlxSdpaFreshOutputSource
open Contracts.Mlx State
set_option maxRecDepth 10000
set_option maxHeartbeats 1000000

variable {steps : Nat} {query : Fin 24 → Fin 256 → ArrayStorage.BF} {cache : Kv.Cache Kv.BF steps}
  {input : SdpaMemory.Input query cache} {p : SdpaVector.Platform} {contracted : Bool} {arch : Char}
  (execution : SdpaOutputMemory.Execution input p contracted arch)
  (selected : ¬SdpaDispatched.twoPass arch steps)

def loadedCache (input : SdpaMemory.Input query cache) : Kv.Cache Kv.BF steps where
  keys := input.storage.keys.read
  values := input.storage.values.read

def source : Option (List (List HalfMemory.Store)) :=
  MlxSdpaOutputSource.source (cache:=loadedCache input) execution.kernel.output.base (execution.kernel.first selected)

theorem produced : SdpaOnePassDonation.produced (cache:=loadedCache input) (execution.kernel.first selected)=
    SdpaDispatchedDevice.produced p contracted arch input.storage.queryValues
      input.storage.keys.read input.storage.values.read execution.kernel.first execution.kernel.second := by
  funext head coordinate
  unfold SdpaDispatchedDevice.produced
  rw [dif_neg selected]
  rfl

theorem source_programs
    (finite : ∀ head, SdpaVector.Finite p (query head)
      (cache.keys (SdpaScore.kvHead head)) (cache.values (SdpaScore.kvHead head))) :
    source execution selected=some (SdpaOutput.programs execution.kernel.output.base
      (SdpaDispatchedDevice.produced p contracted arch input.storage.queryValues
        input.storage.keys.read input.storage.values.read execution.kernel.first execution.kernel.second)) := by
  have loaded : ∀ head, SdpaVector.Finite p (input.storage.queryValues head)
      ((loadedCache input).keys (SdpaScore.kvHead head)) ((loadedCache input).values (SdpaScore.kvHead head)) := by
    simpa only [loadedCache,SdpaLoads.Storage.query_eq,SdpaLoads.HistoryBuffer.read_eq] using finite
  have run := MlxSdpaOutputSource.source_programs (cache:=loadedCache input)
    (execution.kernel.first selected) loaded execution.kernel.output.base
  rw [produced execution selected] at run
  exact run

theorem checked
    (finite : ∀ head, SdpaVector.Finite p (query head)
      (cache.keys (SdpaScore.kvHead head)) (cache.values (SdpaScore.kvHead head))) :
    ∃ programs, source execution selected=some programs ∧
      ThreadgroupWrites.Executes programs execution.kernel.output.schedule execution.kernel.output.remaining ∧
      ThreadgroupWrites.AtBarrier execution.kernel.output.remaining ∧
      HalfMemory.execute execution.kernel.output.schedule input.cache.memory=execution.kernel.output.memory := by
  refine ⟨_,source_programs execution selected finite,execution.kernel.output.execution,execution.kernel.output.completed,?_⟩
  rw [←execution.initial]
  rfl

variable (stores : List HalfMemory.Store)
  (inside : MemoryRegions.Inside16 execution.kernel.output.base 12288 stores)
  (queryBase : Nat)
  (heads : ∀ head, (input.query head).base=(SdpaQueryMemory.layout queryBase).base head)

include inside heads

theorem summary_provenance (head : Fin 24) (group : Fin 32) :
    ∃ finish, MlxSdpaFreshPartialSource.source (input:=input) (p:=p) stores queryBase head group 0 0=some finish ∧
      (execution.kernel.first selected head).summaries.read true group=finish.shift ∧
      (execution.kernel.first selected head).summaries.read false group=finish.denominator := by
  refine ⟨_,MlxSdpaFreshPartialSource.complete execution stores inside queryBase heads head group 0 0,?_⟩
  constructor <;> rw [SdpaSummaryBytes.Trace.read_correct] <;>
    simp only [SdpaSummaryBytes.selected,SdpaLoads.Storage.query_eq,SdpaLoads.HistoryBuffer.read_eq] <;> rfl

theorem transpose_provenance (head : Fin 24) (readerGroup readerLane : Fin 32) (offset : Fin 8) :
    ∃ finish, MlxSdpaFreshPartialSource.source (input:=input) (p:=p) stores queryBase
        head readerLane readerGroup offset=some finish ∧
      ((execution.kernel.first selected head).scratch offset).register readerGroup readerLane=finish.numerator := by
  refine ⟨_,MlxSdpaFreshPartialSource.complete execution stores inside queryBase heads head readerLane readerGroup offset,?_⟩
  rw [SdpaTransposeBytes.Trace.register_correct]
  unfold SdpaOnePassScratch.numeratorLanes
  rw [SdpaLoads.Storage.query_eq,SdpaLoads.HistoryBuffer.read_eq,SdpaLoads.HistoryBuffer.read_eq]
  rfl

-- The completed source output and its scratch operands are joined to one
-- existing fresh-output execution. Every protected prefix reads original
-- query/cache bytes; no independent expected score or partial is supplied.
omit inside heads in
theorem lifecycle (queryBase : Nat)
    (heads : ∀ head, (input.query head).base=(SdpaQueryMemory.layout queryBase).base head)
    (supported : steps≤262144)
    (finite : ∀ head, SdpaVector.Finite p (query head)
      (cache.keys (SdpaScore.kvHead head)) (cache.values (SdpaScore.kvHead head))) :
    (∃ programs, source execution selected=some programs ∧
      ThreadgroupWrites.Executes programs execution.kernel.output.schedule execution.kernel.output.remaining ∧
      ThreadgroupWrites.AtBarrier execution.kernel.output.remaining ∧
      HalfMemory.execute execution.kernel.output.schedule input.cache.memory=execution.kernel.output.memory) ∧
    (∀ stores : List HalfMemory.Store, MemoryRegions.Inside16 execution.kernel.output.base 12288 stores →
      ∀ head group, ∃ finish,
        MlxSdpaFreshPartialSource.source (input:=input) (p:=p) stores queryBase head group 0 0=some finish ∧
        (execution.kernel.first selected head).summaries.read true group=finish.shift ∧
        (execution.kernel.first selected head).summaries.read false group=finish.denominator) ∧
    (∀ stores : List HalfMemory.Store, MemoryRegions.Inside16 execution.kernel.output.base 12288 stores →
      ∀ head readerGroup readerLane offset, ∃ finish,
        MlxSdpaFreshPartialSource.source (input:=input) (p:=p) stores queryBase head readerLane readerGroup offset=some finish ∧
        ((execution.kernel.first selected head).scratch offset).register readerGroup readerLane=finish.numerator) ∧
    (∀ group : Fin 32, MlxSdpaVectorLoop.Runs steps group.val ((SdpaLayout.keys steps group).map Fin.val) ∧
      group.val+32*SdpaLayout.count steps group<2^31) := by
  refine ⟨checked execution selected finite,?_,?_,?_⟩
  · intro stores inside head group
    exact summary_provenance execution selected stores inside queryBase heads head group
  · intro stores inside head readerGroup readerLane offset
    exact transpose_provenance execution selected stores inside queryBase heads head readerGroup readerLane offset
  · intro group
    exact MlxSdpaFreshPartialSource.control group supported

end Inference.Kernels.Attention.MlxSdpaFreshOutputSource
