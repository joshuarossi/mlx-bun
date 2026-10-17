import kernels.attention.MlxSdpaVectorMemory
import kernels.attention.MlxSdpaVectorLoop
import kernels.attention.SdpaOnePassDonation

namespace Inference.Kernels.Attention.MlxSdpaVectorDispatch
open Contracts.Mlx

-- The source guard binds the pinned host conditional to this existing
-- dispatch contract. Architecture suffix remains a native device property.
theorem short (steps : Nat) (positive : 0<steps) (bound : steps<1024) (architecture : Char) :
    SdpaDispatch.route (SdpaDispatch.qwen steps) architecture=.onePass :=
  SdpaDispatch.qwen_short steps positive bound architecture

theorem large_transition (architecture : Char) (large : architecture='d' ∨ architecture='s') :
    SdpaDispatch.route (SdpaDispatch.qwen 1023) architecture=.onePass ∧
    SdpaDispatch.route (SdpaDispatch.qwen 1024) architecture=.twoPass :=
  ⟨short 1023 (by decide) (by decide) architecture,SdpaDispatch.qwen_large_device 1024 (by decide) architecture large⟩

theorem other_transition (architecture : Char) (other : architecture≠'d' ∧ architecture≠'s') :
    SdpaDispatch.route (SdpaDispatch.qwen 4095) architecture=.onePass ∧
    SdpaDispatch.route (SdpaDispatch.qwen 4096) architecture=.twoPass :=
  ⟨SdpaDispatch.qwen_small_device 4095 (by decide) (by decide) architecture other,
    SdpaDispatch.qwen_long 4096 (by decide) architecture⟩

-- Every actual dereference is in the active logical cache, whose physical
-- head stride retains capacity. SIMD groups with no key issue no cache load.
theorem key_range (capacity steps : Nat) (room : steps≤capacity) (supported : capacity≤262144)
    (head : Fin 24) (group lane : Fin 32) (iteration : Fin (SdpaLayout.count steps group)) (item : Fin 8) :
    MlxSdpaVectorMemory.keyAddress capacity head group lane iteration.val item<2^31 := by
  rw [MlxSdpaVectorMemory.key_address]
  have inside := SdpaAddresses.kv_in_bounds capacity steps room head group lane iteration item
  omega

theorem query_range (transposed : Bool) (head : Fin 24) (lane : Fin 32) (item : Fin 8) :
    MlxSdpaVectorMemory.queryAddress transposed head lane item<6144 := by
  rw [MlxSdpaVectorMemory.query_address]
  exact SdpaAddresses.query_in_bounds transposed head lane item

-- Exact key loads from an arbitrary prefix of the DONATED query/output
-- execution. Protected cache bytes are supplied by the existing ownership
-- proof, rather than assuming the query/output heap has not changed.
theorem key_intermediate {steps : Nat} {query : Fin 24 → Fin 256 → ArrayStorage.BF}
    {cache : State.Kv.Cache State.Kv.BF steps} {input : SdpaMemory.Input query cache}
    {p : SdpaVector.Platform} {architecture : Char}
    (execution : SdpaOnePassDonation.Execution input p architecture)
    {after : SdpaQueryMemory.Machine} {events : List (ReadBeforeOverwrite.Event 24 1024)}
    (run : ReadBeforeOverwrite.Executes (SdpaQueryMemory.layout execution.base) (SdpaQueryMemory.read execution.base)
      (ReadBeforeOverwrite.initial input.cache.memory) events after)
    (head : Fin 24) (group lane : Fin 32) (iteration : Fin (SdpaLayout.count steps group)) (item : Fin 8) :
    MlxSdpaVectorMemory.keySource after.memory input.cache.layout.keyBase (State.KvAllocation.capacity steps)
      head group lane iteration.val item=
      some (BFloat16.widen (cache.keys (SdpaScore.kvHead head) (SdpaLayout.key steps group iteration) (SdpaScore.index lane item))) :=
  MlxSdpaVectorMemory.key_storage (execution.intermediateCache run) head group lane iteration item

theorem key_device_address {steps : Nat} {cache : State.Kv.Cache State.Kv.BF steps}
    (storage : State.KvRegions.Storage cache) (head : Fin 24) (group lane : Fin 32)
    (iteration : Fin (SdpaLayout.count steps group)) (item : Fin 8) :
    storage.layout.keyBase+2*MlxSdpaVectorMemory.keyAddress (State.KvAllocation.capacity steps)
      head group lane iteration.val item+2≤2^64 := by
  rw [MlxSdpaVectorMemory.key_address,SdpaAddresses.kv_address]
  have inside := State.KvRegions.active_bounds (SdpaScore.kvHead head)
    (SdpaLayout.key steps group iteration) (SdpaScore.index lane item)
  rw [SdpaLayout.key_stride] at inside
  have bounded := storage.layout.keyBound
  omega

theorem key_pointer_advance (capacity : Nat) (head : Fin 24) (group lane : Fin 32)
    (iteration : Nat) (item : Fin 8) :
    MlxSdpaVectorMemory.keyAddress capacity head group lane (iteration+1) item=
      MlxSdpaVectorMemory.keyAddress capacity head group lane iteration item+8192 := by
  unfold MlxSdpaVectorMemory.keyAddress
  omega

end Inference.Kernels.Attention.MlxSdpaVectorDispatch
