import kernels.attention.SdpaTwoPassStorage
import kernels.attention.SdpaAddresses

namespace Inference.Kernels.Attention.SdpaTwoPassExecution
open Contracts.Mlx Contracts.Mlx.Numerics SdpaTwoPassLayout
open FloatLib FloatLib.Floats FloatLib.Floats.Formats.BinaryInterchange

-- First pass: tid.x is the KV head, tidtg.y selects one of its six
-- query heads, and tid.z is the initial key in a block-strided loop.
def firstKvAddress (capacity blocks : Nat) (kv : Fin 4) (block : Fin blocks)
    (lane : Fin 32) (iteration : Nat) (offset : Fin 8) : Nat :=
  kv.val*(capacity*256)+block.val*256+lane.val*8+iteration*(blocks*256)+offset.val

theorem first_kv_address (capacity blocks : Nat) (kv : Fin 4) (block : Fin blocks)
    (lane : Fin 32) (iteration : Nat) (offset : Fin 8) :
    firstKvAddress capacity blocks kv block lane iteration offset =
      State.Kv.address capacity kv (block.val+blocks*iteration) (SdpaScore.index lane offset) := by
  simp only [firstKvAddress, State.Kv.address, SdpaScore.index]
  ring

theorem first_kv_in_bounds (capacity steps blocks : Nat) (active : steps ≤ capacity)
    (kv : Fin 4) (block : Fin blocks) (lane : Fin 32)
    (iteration : Fin (count steps blocks block)) (offset : Fin 8) :
    firstKvAddress capacity blocks kv block lane iteration.val offset < 4*capacity*256 := by
  rw [first_kv_address]
  exact State.Kv.address_bounds capacity kv _ _ ((key steps blocks block iteration).isLt.trans_le active)

theorem first_read_cache (capacity steps blocks : Nat) (memory : Nat → α)
    (cache : Fin 4 → Fin steps → Fin 256 → α)
    (attached : ∀ h t i, memory (State.Kv.address capacity h t.val i) = cache h t i)
    (kv : Fin 4) (block : Fin blocks) (lane : Fin 32)
    (iteration : Fin (count steps blocks block)) (offset : Fin 8) :
    memory (firstKvAddress capacity blocks kv block lane iteration.val offset) =
      cache kv (key steps blocks block iteration) (SdpaScore.index lane offset) := by
  rw [first_kv_address]
  exact attached kv (key steps blocks block iteration) (SdpaScore.index lane offset)

theorem first_read_appended (capacity n blocks : Nat) (room : n < capacity) (before : Nat → α)
    (old : Fin 4 → Fin n → Fin 256 → α) (next : Fin 4 → Fin 256 → α)
    (attached : ∀ h t i, before (State.Kv.address capacity h t.val i) = old h t i)
    (schedule : List Nat) (order : schedule.Perm (State.Kv.writeIndices capacity n))
    (kv : Fin 4) (block : Fin blocks) (lane : Fin 32)
    (iteration : Fin (count (n+1) blocks block)) (offset : Fin 8) :
    State.Kv.stored capacity n next before schedule (firstKvAddress capacity blocks kv block lane iteration.val offset) =
      State.Kv.appendRows (fun t => old kv t (SdpaScore.index lane offset)) (next kv (SdpaScore.index lane offset))
        (key (n+1) blocks block iteration) := by
  rw [first_kv_address]
  have stored := State.Kv.stored_read capacity n room next before schedule order kv
    (key (n+1) blocks block iteration) (SdpaScore.index lane offset)
  simpa only [attached, key] using stored

theorem first_query_head (kv : Fin 4) (gqa : Fin 6) (transposed : Bool)
    (lane : Fin 32) (offset : Fin 8) :
    SdpaAddresses.queryAddress transposed (queryHead kv gqa) lane offset =
      (kv.val*6+gqa.val)*256+(SdpaScore.index lane offset).val :=
  SdpaAddresses.query_address transposed (queryHead kv gqa) lane offset

theorem first_partial_address (kv : Fin 4) (gqa : Fin 6) (block : Fin blocks)
    (lane : Fin 32) (offset : Fin 8) :
    (kv.val*6+gqa.val)*blocks*256+block.val*256+lane.val*8+offset.val =
      partialAddress blocks (queryHead kv gqa) block (SdpaLayout.coordinate lane offset) := by
  simp only [partialAddress, summaryAddress, queryHead, SdpaLayout.coordinate]
  ring

theorem first_integer_capacity (steps blocks : Nat) (supported : steps ≤ 262144) (blockBound : blocks ≤ 1024)
    (block : Fin blocks) (iteration : Fin (count steps blocks block)) :
    (key steps blocks block iteration).val+blocks < 2^31 ∧ blocks*256 < (2^31 : Nat) := by
  have := (key steps blocks block iteration).isLt
  constructor <;> omega

-- Ordinary second-pass source loop: b = 0, ..., blocks/32-1.
-- The host default block counts are divisible by 32. Without that fact
-- the native floor-divided loop would not cover the abstract strided list.
def blockIndex (complete : blocks%32 = 0) (thread : Fin 32) (iteration : Fin (blocks/32)) : Fin blocks :=
  ⟨thread.val+32*iteration.val, by have := thread.isLt; have := iteration.isLt; omega⟩
def sourceKeys (complete : blocks%32 = 0) (thread : Fin 32) : List (Fin blocks) :=
  List.ofFn (blockIndex complete thread)

theorem source_keys (complete : blocks%32 = 0) (thread : Fin 32) :
    sourceKeys complete thread = SdpaLayout.keys blocks thread := by
  apply List.ext_getElem
  · simp only [sourceKeys, SdpaLayout.keys, List.length_ofFn, SdpaTwoPassMaximum.lane_count blocks complete thread]
  · intro j hj hk
    simp only [sourceKeys, SdpaLayout.keys, List.getElem_ofFn]
    apply Fin.ext
    rfl

theorem summary_address (complete : blocks%32 = 0) (head : Fin 24) (thread : Fin 32)
    (iteration : Fin (blocks/32)) :
    head.val*blocks+thread.val+32*iteration.val = summaryAddress blocks head (blockIndex complete thread iteration) := by
  simp only [summaryAddress, blockIndex]
  omega

theorem partial_address (complete : blocks%32 = 0) (head : Fin 24) (group lane : Fin 32)
    (iteration : Fin (blocks/32)) (offset : Fin 8) :
    head.val*blocks*256+group.val*256+lane.val*8+iteration.val*(32*256)+offset.val =
      partialAddress blocks head (blockIndex complete group iteration) (SdpaLayout.coordinate lane offset) := by
  simp only [partialAddress, summaryAddress, blockIndex, SdpaLayout.coordinate]
  ring

def sourceComponent (p : SdpaMerge.Platform) (contracted : Bool) (complete : blocks%32 = 0)
    (states : Fin blocks → SdpaUpdate.State) (shift : Float32) (numerator : Bool) : Float32 :=
  p.reduce (fun thread => (sourceKeys complete thread).foldl (fun acc block =>
    ArithmeticFold.maddFloat contracted (SdpaUpdate.exponential p.scalar (states block).shift shift)
      (SdpaMerge.component (states block) numerator) acc) 0)

theorem component_execution (p : SdpaMerge.Platform) (contracted : Bool) (complete : blocks%32 = 0)
    (states : Fin blocks → SdpaUpdate.State) (shift : Float32) (numerator : Bool) :
    sourceComponent p contracted complete states shift numerator =
      SdpaTwoPassMerge.source p contracted states shift numerator := by
  unfold sourceComponent SdpaTwoPassMerge.source
  simp only [source_keys]

-- One output coordinate after the source's shared-memory transpose.
-- Every group accumulates its strided blocks; then the reader group owns
-- the coordinate previously owned by the writer lane.
def numeratorLanes (p : SdpaVector.Platform) (contracted : Bool) (complete : blocks%32 = 0)
    (query : Fin 256 → SdpaVector.BF) (keys values : Fin steps → Fin 256 → SdpaVector.BF)
    (offset : Fin 8) (group lane : Fin 32) : Float32 :=
  (sourceKeys complete group).foldl (fun acc block => ArithmeticFold.maddFloat contracted
    (SdpaUpdate.exponential p.merge.scalar
      (SdpaTwoPassVector.partials p query keys values 0 block).shift (SdpaTwoPassVector.commonShift p blocks query keys values))
    (SdpaTwoPassVector.partials p query keys values (SdpaLayout.coordinate lane offset) block).numerator acc) 0

theorem numerator_execution (p : SdpaVector.Platform) (contracted : Bool) (complete : blocks%32 = 0)
    (query : Fin 256 → SdpaVector.BF) (keys values : Fin steps → Fin 256 → SdpaVector.BF)
    (offset : Fin 8) (before : Nat → Float32) (schedule : List Nat)
    (writes : schedule.Perm (List.range 1024)) (group : Fin 32) :
    SdpaTwoPassStorage.secondScratch (numeratorLanes p contracted complete query keys values offset)
      before schedule group p.merge.reduce =
      (SdpaTwoPassVector.merged p contracted blocks query keys values (SdpaLayout.coordinate group offset)).numerator := by
  rw [SdpaTwoPassStorage.second_scratch_read _ before schedule writes]
  unfold SdpaTwoPassVector.merged SdpaTwoPassMerge.forward SdpaTwoPassMerge.source
  apply congrArg p.merge.reduce
  funext lane
  unfold numeratorLanes
  rw [source_keys]
  apply congrArg (fun f => (SdpaLayout.keys blocks lane).foldl f 0)
  funext acc block
  rw [(SdpaTwoPassFirstPass.shared p query keys values 0 (SdpaLayout.coordinate group offset) block).1]
  rfl

theorem division_branch (denominator : Float32) (lower : 1 ≤ real denominator) :
    real denominator ≠ 0 := by linarith

end Inference.Kernels.Attention.SdpaTwoPassExecution
