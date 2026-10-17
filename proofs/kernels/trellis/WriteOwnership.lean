import contracts.mlx.WriteOwnership
import kernels.trellis.GateUpBarrier
import kernels.trellis.DownBarrier

namespace Inference.Kernels.Trellis.WriteOwnership
open Contracts.Mlx

theorem codebook (base threads : Nat) (supported : threads=256 ∨ threads=1024) :
    Contracts.Mlx.WriteOwnership.Separated Memory.Store.word (CodebookBarrier.programs base threads) := by
  unfold CodebookBarrier.programs
  apply Contracts.Mlx.WriteOwnership.owned (List.range threads) List.nodup_range _ _
    (fun word => (word-base/4)%threads)
  intro thread ht store hs
  obtain ⟨iteration, hi, rfl⟩ := List.mem_map.mp hs
  have threadBound := List.mem_range.mp ht
  simp only [CodebookInitialization.entry]
  rcases supported with rfl | rfl <;> omega

private def scratchOwner (base word : Nat) : Nat × Nat :=
  let j := word-base/4
  (j/512, (j%512)/256*16+(255-j%256)/16)

theorem down (base : Nat) (values : Nat → Nat → Nat → Float32) :
    Contracts.Mlx.WriteOwnership.Separated Memory.Store.word (DownBarrier.programs base values) := by
  have owned := Contracts.Mlx.WriteOwnership.owned ((List.range 8).product (List.range 32))
    ((show (List.range 8).Nodup from List.nodup_range).product (show (List.range 32).Nodup from List.nodup_range))
    (fun pair => (List.range 16).map (DownMemory.entry base values pair.1 pair.2)) Memory.Store.word (scratchOwner base) (by
      intro pair hp store hs
      obtain ⟨sg, lane⟩ := pair
      obtain ⟨hsg, hlane⟩ := List.mem_product.mp hp
      obtain ⟨index, hi, rfl⟩ := List.mem_map.mp hs
      have inverse := DownCodebook.scratch_inverse sg lane index
        (List.mem_range.mp hsg) (List.mem_range.mp hlane) (List.mem_range.mp hi)
      simpa only [scratchOwner, DownMemory.entry, Nat.add_sub_cancel_left] using Prod.ext inverse.1 inverse.2.1)
  simpa only [DownBarrier.programs, List.product, List.map_flatMap, List.map_map, Function.comp_def] using owned

private def gateOwner (tableBase inputBase word : Nat) : Nat :=
  if tableBase/4 ≤ word ∧ word<tableBase/4+4096 then (word-tableBase/4)%1024 else (word-inputBase/4)/4

private theorem gate_code_owner (tableBase inputBase thread iteration : Nat) (ht : thread<1024) (hi : iteration<4) :
    gateOwner tableBase inputBase (GateUpBarrier.codeEntry tableBase thread iteration).word=thread := by
  have inside : tableBase/4 ≤ (GateUpBarrier.codeEntry tableBase thread iteration).word ∧
      (GateUpBarrier.codeEntry tableBase thread iteration).word<tableBase/4+4096 := by
    simp only [GateUpBarrier.codeEntry, CodebookInitialization.entry]
    omega
  unfold gateOwner
  rw [ite_eq_left inside]
  simp only [GateUpBarrier.codeEntry, CodebookInitialization.entry]
  omega

private theorem gate_input_owner (tableBase inputBase thread word : Nat) (input : Nat → BitVec 16)
    (separate : GateUpBarrier.Separate tableBase inputBase) (ht : thread<640) (hw : word<4) :
    gateOwner tableBase inputBase (GateUpBarrier.inputEntry inputBase input thread word).word=thread := by
  have bounds := GateUpBarrier.input_bounds inputBase input thread word ht hw
  have outside : ¬(tableBase/4 ≤ (GateUpBarrier.inputEntry inputBase input thread word).word ∧
      (GateUpBarrier.inputEntry inputBase input thread word).word<tableBase/4+4096) := by
    unfold GateUpBarrier.Separate at separate
    omega
  unfold gateOwner
  rw [ite_eq_right outside]
  simp only [GateUpBarrier.inputEntry]
  omega

-- Each table word and each staged input word has one source thread. This
-- excludes conflicting writes even when the values would happen to agree.
theorem gateUp (tableBase inputBase : Nat) (input : Nat → BitVec 16)
    (separate : GateUpBarrier.Separate tableBase inputBase) :
    Contracts.Mlx.WriteOwnership.Separated MemoryCells.Store.word (GateUpBarrier.programs tableBase inputBase input) := by
  unfold GateUpBarrier.programs
  apply Contracts.Mlx.WriteOwnership.owned (List.range 1024) List.nodup_range _ _ (gateOwner tableBase inputBase)
  intro thread ht store hs
  rcases List.mem_append.mp hs with code | data
  · obtain ⟨iteration, hi, rfl⟩ := List.mem_map.mp code
    exact gate_code_owner tableBase inputBase thread iteration (List.mem_range.mp ht) (List.mem_range.mp hi)
  · by_cases active : thread<640
    · rw [ite_eq_left active] at data
      obtain ⟨word, hw, rfl⟩ := List.mem_map.mp data
      exact gate_input_owner tableBase inputBase thread word input separate active (List.mem_range.mp hw)
    · simp only [active, ite_false, List.not_mem_nil] at data

end Inference.Kernels.Trellis.WriteOwnership
