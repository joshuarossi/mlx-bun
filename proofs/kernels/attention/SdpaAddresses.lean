import contracts.mlx.SdpaDispatch
import kernels.attention.SdpaScore
import kernels.attention.SdpaLayout
import state.Kv

namespace Inference.Kernels.Attention.SdpaAddresses
open Contracts.Mlx

-- Pinned sdpa_vector.h pointer arithmetic at batch=1, QH=24, KVH=4,
-- query length=1, D=V=256. KV head stride retains the allocated capacity,
-- which may exceed the active key count. These are logical BF16 cells;
-- binding buffers and Metal pointer semantics remains an execution contract.
def queryOffset (transposed : Bool) (head : Fin 24) : Nat :=
  if transposed then 24*0+head.val else head.val*1+0
def queryAddress (transposed : Bool) (head : Fin 24) (lane : Fin 32) (item : Fin 8) : Nat :=
  queryOffset transposed head*256 + lane.val*8 + item.val
def outputAddress (head : Fin 24) (group : Fin 32) (item : Fin 8) : Nat :=
  (head.val*1+0)*256 + group.val*8 + item.val
def kvAddress (capacity : Nat) (head : Fin 24) (group lane : Fin 32) (iteration : Nat) (item : Fin 8) : Nat :=
  (head.val/6)*(capacity*256) + group.val*256 + lane.val*8 + iteration*(32*256) + item.val

theorem head_agreement (head : Fin 24) : SdpaDispatch.kvHead head = SdpaScore.kvHead head := rfl
theorem query_offset (transposed : Bool) (head : Fin 24) : queryOffset transposed head = head.val := by
  cases transposed <;> simp [queryOffset]
theorem query_address (transposed : Bool) (head : Fin 24) (lane : Fin 32) (item : Fin 8) :
    queryAddress transposed head lane item = head.val*256+(SdpaScore.index lane item).val := by
  rw [queryAddress, query_offset]
  simp only [SdpaScore.index]
  omega
theorem output_address (head : Fin 24) (group : Fin 32) (item : Fin 8) :
    outputAddress head group item = head.val*256+(SdpaLayout.coordinate group item).val := by
  simp only [outputAddress, SdpaLayout.coordinate]
  omega
theorem kv_address (capacity : Nat) (head : Fin 24) (group lane : Fin 32) (iteration : Nat) (item : Fin 8) :
    kvAddress capacity head group lane iteration item =
      State.Kv.address capacity (SdpaScore.kvHead head) (group.val+32*iteration) (SdpaScore.index lane item) := by
  simp only [kvAddress, State.Kv.address, SdpaScore.kvHead, SdpaScore.index]
  ring

theorem query_in_bounds (transposed : Bool) (head : Fin 24) (lane : Fin 32) (item : Fin 8) :
    queryAddress transposed head lane item < 24*256 := by
  rw [query_address]
  have := head.isLt
  have := (SdpaScore.index lane item).isLt
  omega
theorem output_in_bounds (head : Fin 24) (group : Fin 32) (item : Fin 8) :
    outputAddress head group item < 24*256 := by
  rw [output_address]
  have := head.isLt
  have := (SdpaLayout.coordinate group item).isLt
  omega
theorem kv_in_bounds (capacity steps : Nat) (active : steps ≤ capacity)
    (head : Fin 24) (group lane : Fin 32) (iteration : Fin (SdpaLayout.count steps group)) (item : Fin 8) :
    kvAddress capacity head group lane iteration.val item < 4*capacity*256 := by
  rw [kv_address]
  exact State.Kv.address_bounds capacity _ _ _ ((SdpaLayout.key steps group iteration).isLt.trans_le active)

-- Every dereferenced source key address is exactly the cache address at
-- the strided loop key used in the numerical proof. No padding is read.
theorem read_cache (capacity steps : Nat) (memory : Nat → α)
    (cache : Fin 4 → Fin steps → Fin 256 → α)
    (attached : ∀ h t i, memory (State.Kv.address capacity h t.val i) = cache h t i)
    (head : Fin 24) (group lane : Fin 32) (iteration : Fin (SdpaLayout.count steps group)) (item : Fin 8) :
    memory (kvAddress capacity head group lane iteration.val item) =
      cache (SdpaScore.kvHead head) (SdpaLayout.key steps group iteration) (SdpaScore.index lane item) := by
  rw [kv_address]
  exact attached (SdpaScore.kvHead head) (SdpaLayout.key steps group iteration) (SdpaScore.index lane item)

theorem read_query (transposed : Bool) (memory : Nat → α) (query : Fin 24 → Fin 256 → α)
    (attached : ∀ h i, memory (h.val*256+i.val) = query h i)
    (head : Fin 24) (lane : Fin 32) (item : Fin 8) :
    memory (queryAddress transposed head lane item) = query head (SdpaScore.index lane item) := by
  rw [query_address]
  exact attached _ _

theorem read_appended (capacity n : Nat) (room : n < capacity) (before : Nat → α)
    (old : Fin 4 → Fin n → Fin 256 → α) (next : Fin 4 → Fin 256 → α)
    (attached : ∀ h t i, before (State.Kv.address capacity h t.val i) = old h t i)
    (schedule : List Nat) (order : schedule.Perm (State.Kv.writeIndices capacity n))
    (head : Fin 24) (group lane : Fin 32) (iteration : Fin (SdpaLayout.count (n+1) group)) (item : Fin 8) :
    State.Kv.stored capacity n next before schedule (kvAddress capacity head group lane iteration.val item) =
      State.Kv.appendRows (fun t => old (SdpaScore.kvHead head) t (SdpaScore.index lane item))
        (next (SdpaScore.kvHead head) (SdpaScore.index lane item)) (SdpaLayout.key (n+1) group iteration) := by
  rw [kv_address]
  have stored := State.Kv.stored_read capacity n room next before schedule order (SdpaScore.kvHead head)
    (SdpaLayout.key (n+1) group iteration) (SdpaScore.index lane item)
  simpa only [attached, SdpaLayout.key_stride] using stored

theorem output_unique (h h' : Fin 24) (g g' : Fin 32) (i i' : Fin 8)
    (same : outputAddress h g i = outputAddress h' g' i') : h = h' ∧ g = g' ∧ i = i' := by
  have := g.isLt
  have := g'.isLt
  have := i.isLt
  have := i'.isLt
  simp only [outputAddress] at same
  exact ⟨Fin.ext (by omega), Fin.ext (by omega), Fin.ext (by omega)⟩

theorem output_coverage (head : Fin 24) (coordinate : Fin 256) :
    ∃ group : Fin 32, ∃ item : Fin 8, outputAddress head group item = head.val*256+coordinate.val := by
  refine ⟨⟨coordinate.val/8, by have := coordinate.isLt; omega⟩, ⟨coordinate.val%8, by omega⟩, ?_⟩
  simp only [outputAddress]
  omega

-- Signed int loop counters/strides and uint grid arithmetic cannot wrap
-- for this supported context. Native byte allocations are separate.
theorem integer_capacity (steps : Nat) (supported : steps ≤ 262144) (group : Fin 32)
    (iteration : Fin (SdpaLayout.count steps group)) :
    (SdpaLayout.key steps group iteration).val+32 < 2^31 ∧ 32*256 < (2^31 : Nat) := by
  have := (SdpaLayout.key steps group iteration).isLt
  constructor <;> omega

end Inference.Kernels.Attention.SdpaAddresses
