import kernels.attention.MlxSdpaFreshMemory
import kernels.attention.MlxSdpaPartialSource

namespace Inference.Kernels.Attention.MlxSdpaFreshPartialSource
open Contracts.Mlx State
set_option maxRecDepth 2000
set_option maxHeartbeats 1000000
attribute [local irreducible] MlxSdpaUpdateSource.source SdpaLoop.next SdpaVector.partials

variable {steps : Nat} {query : Fin 24 → Fin 256 → ArrayStorage.BF} {cache : Kv.Cache Kv.BF steps}
  {input : SdpaMemory.Input query cache} {p : SdpaVector.Platform} {contracted : Bool} {arch : Char}
  (execution : SdpaOutputMemory.Execution input p contracted arch)
  (stores : List HalfMemory.Store)
  (inside : MemoryRegions.Inside16 execution.kernel.output.base 12288 stores)
  (queryBase : Nat)
  (heads : ∀ head, (input.query head).base=(SdpaQueryMemory.layout queryBase).base head)
  (head : Fin 24) (group lane : Fin 32) (item : Fin 8)

def step (iteration : Fin (SdpaLayout.count steps group)) (state : SdpaUpdate.State) : Option SdpaUpdate.State :=
  MlxSdpaUpdateSource.source p (MlxSdpaFreshMemory.registers (input:=input) stores queryBase head)
    (MlxSdpaFreshMemory.memory (input:=input) stores) input.cache.layout.keyBase input.cache.layout.valueBase
    (KvAllocation.capacity steps) head group lane iteration.val item state

include execution inside heads in
theorem fold (indices : List (Fin (SdpaLayout.count steps group))) (initial : SdpaUpdate.State) :
    indices.foldlM (fun state iteration => step (input:=input) (p:=p) stores queryBase head group lane item iteration state) initial=
      some (SdpaLoop.run p.merge.scalar p.maximum
        (SdpaVector.scores p (query head) (cache.keys (SdpaScore.kvHead head)))
        (SdpaVector.valuesAt (cache.values (SdpaScore.kvHead head)) (SdpaScore.index lane item))
        (indices.map (SdpaLayout.key steps group)) initial) := by
  induction indices generalizing initial with
  | nil => rfl
  | cons iteration rest ih =>
    have first : step (input:=input) (p:=p) stores queryBase head group lane item iteration initial=
        some (SdpaLoop.next p.merge.scalar p.maximum
          (SdpaVector.scores p (query head) (cache.keys (SdpaScore.kvHead head)))
          (SdpaVector.valuesAt (cache.values (SdpaScore.kvHead head)) (SdpaScore.index lane item))
          (SdpaLayout.key steps group iteration) initial) :=
      MlxSdpaFreshMemory.update execution stores inside queryBase heads head group lane iteration item initial
    rw [List.foldlM_cons,first]
    exact ih _

def source : Option SdpaUpdate.State := do
  let initial ←MlxSdpaPartialSource.parseInitial MlxSdpaPartialSource.sourceInitial
  if MlxSdpaVectorLoop.parseLoop MlxSdpaVectorLoop.sourceLoop≠some .strided ∨
      MlxSdpaVectorLoop.parseAdvances MlxSdpaVectorLoop.sourceAdvances≠some MlxSdpaVectorLoop.advances then none
  else
    (List.finRange (SdpaLayout.count steps group)).foldlM
      (fun state iteration => step (input:=input) (p:=p) stores queryBase head group lane item iteration state)
      (MlxSdpaPartialSource.initial initial)

include execution inside heads in
theorem complete : source (input:=input) (p:=p) stores queryBase head group lane item=
    some (SdpaVector.partials p (query head) (cache.keys (SdpaScore.kvHead head))
      (cache.values (SdpaScore.kvHead head)) (SdpaScore.index lane item) group) := by
  unfold source
  rw [MlxSdpaPartialSource.parsed_initial,MlxSdpaVectorLoop.parsed_loop,MlxSdpaVectorLoop.parsed_advances]
  change (List.finRange (SdpaLayout.count steps group)).foldlM _ (MlxSdpaPartialSource.initial .empty)=_
  rw [fold execution stores inside queryBase heads head group lane item]
  have schedule : (List.finRange (SdpaLayout.count steps group)).map (SdpaLayout.key steps group)=SdpaLayout.keys steps group := by
    change (List.ofFn id).map (SdpaLayout.key steps group)=_
    rw [List.map_ofFn]
    rfl
  rw [schedule]
  unfold SdpaVector.partials
  rfl

-- Source loop visits exactly the active keys and exits without signed
-- overflow. Empty SIMD partitions issue no key/value load.
theorem control (supported : steps≤262144) :
    MlxSdpaVectorLoop.Runs steps group.val ((SdpaLayout.keys steps group).map Fin.val) ∧
      group.val+32*SdpaLayout.count steps group<2^31 :=
  ⟨MlxSdpaVectorLoop.selected_visits steps group,MlxSdpaVectorLoop.signed_counter steps supported group⟩

end Inference.Kernels.Attention.MlxSdpaFreshPartialSource
