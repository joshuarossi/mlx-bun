import kernels.trellis.CodebookInitialization
import kernels.trellis.DownExecution

namespace Inference.Kernels.Trellis.DownMemory
open Contracts.Mlx Contracts.Mlx.M1Max DownCodebook DownExecution

def entry (base : Nat) (values : Nat → Nat → Nat → Float32) (sg lane i : Nat) : Memory.Store :=
  { word := base/4 + scratch sg lane i, value := values sg lane i }

def stores (base : Nat) (values : Nat → Nat → Nat → Float32) : List Memory.Store :=
  (List.range 8).flatMap fun sg =>
    (List.range 32).flatMap fun lane =>
      (List.range 16).map fun i => entry base values sg lane i

theorem address_injective (base : Nat) (values : Nat → Nat → Nat → Float32)
    (sg₁ sg₂ lane₁ lane₂ i₁ i₂ : Nat)
    (hs₁ : sg₁<8) (hs₂ : sg₂<8) (hl₁ : lane₁<32) (hl₂ : lane₂<32) (hi₁ : i₁<16) (hi₂ : i₂<16)
    (he : (entry base values sg₁ lane₁ i₁).word = (entry base values sg₂ lane₂ i₂).word) :
    sg₁=sg₂ ∧ lane₁=lane₂ ∧ i₁=i₂ := by
  have h : scratch sg₁ lane₁ i₁ = scratch sg₂ lane₂ i₂ := by simp only [entry] at he; omega
  have a := scratch_inverse sg₁ lane₁ i₁ hs₁ hl₁ hi₁
  have b := scratch_inverse sg₂ lane₂ i₂ hs₂ hl₂ hi₂
  rw [h] at a
  exact ⟨a.1.symm.trans b.1, a.2.1.symm.trans b.2.1, a.2.2.symm.trans b.2.2⟩

theorem covers (base : Nat) (values : Nat → Nat → Nat → Float32) (j : Nat) (hj : j<4096) :
    ∃ s ∈ stores base values, s.word=base/4+j := by
  refine ⟨entry base values (j/512) ((j%512)/256*16+(255-j%256)/16) ((255-j%256)%16), ?_, ?_⟩
  · apply List.mem_flatMap.mpr
    refine ⟨j/512, List.mem_range.mpr (by omega), ?_⟩
    apply List.mem_flatMap.mpr
    refine ⟨(j%512)/256*16+(255-j%256)/16, List.mem_range.mpr (by omega), ?_⟩
    exact List.mem_map.mpr ⟨(255-j%256)%16, List.mem_range.mpr (by omega), rfl⟩
  · simp only [entry, scratch_coverage j hj]

theorem correct_value (base : Nat) (values : Nat → Nat → Nat → Float32) (j : Nat)
    (s : Memory.Store) (hs : s ∈ stores base values) (he : s.word=base/4+j) :
    s.value = scratchMemory values j := by
  obtain ⟨sg, hsg, hs⟩ := List.mem_flatMap.mp hs
  obtain ⟨lane, hlane, hs⟩ := List.mem_flatMap.mp hs
  obtain ⟨i, hi, rfl⟩ := List.mem_map.mp hs
  have hsg := List.mem_range.mp hsg
  have hlane := List.mem_range.mp hlane
  have hi := List.mem_range.mp hi
  have he : scratch sg lane i = j := by simp only [entry] at he; omega
  change values sg lane i = _
  rw [← he, scratch_store values sg lane i hsg hlane hi]

theorem scratch_written (before : WordMemory) (base : Nat) (values : Nat → Nat → Nat → Float32)
    (schedule : List Memory.Store) (order : schedule.Perm (stores base values)) (j : Nat) (hj : j<4096) :
    Memory.execute schedule before (base/4+j) = scratchMemory values j := by
  exact Memory.written_value_permuted (stores base values) schedule order before (base/4+j)
    (scratchMemory values j) (fun s hs he => correct_value base values j s hs he) (covers base values j hj)

def threadgroup (load : ThreadgroupLoad) (before : WordMemory) (base : Nat)
    (words : PackedMatrix) (k : Nat) (scale input : Nat → Float32) (ty c : Nat) : Float32 :=
  let table := Memory.execute (CodebookInitialization.stores base 256) before
  let values := laneSum load table base words k scale input ty
  let scratch := Memory.execute (stores base values) table
  firstStage (fun j => scratch (base/4+j)) c

-- Sequential phases are separated by the source's two scratch barriers. Each
-- phase's stores have unique addresses; scratch_written and initialized also
-- hold for arbitrary permutations within a phase.
theorem threadgroup_correct (load : ThreadgroupLoad) (hardware : LoadContract load)
    (before : WordMemory) (base : Nat) (ha : base%4=0) (hn : base+16384 ≤ 2^64)
    (words : PackedMatrix) (k : Nat) (hk : k=2 ∨ k=3 ∨ k=4)
    (scale input : Nat → Float32) (ty c : Nat) (hc : c<1024) :
    threadgroup load before base words k scale input ty c =
      partialSum words k scale input (ty%32) (column ty c) := by
  let table := Memory.execute (CodebookInitialization.stores base 256) before
  let values := laneSum load table base words k scale input ty
  have initialized := CodebookInitialization.initialized before base 256 (Or.inl rfl)
    (CodebookInitialization.stores base 256) (List.Perm.refl _)
  have h : firstStage (fun j => Memory.execute (stores base values) table (base/4+j)) c =
      firstStage (scratchMemory values) c := by
    unfold firstStage
    apply scalarRows_congr
    intro s _hs hs acc
    dsimp only
    rw [scratch_written table base values (stores base values) (List.Perm.refl _) _ (by omega)]
  exact h.trans (firstStage_correct load hardware table base ha hn initialized words k hk scale input ty c hc)

def output (load : ThreadgroupLoad) (before : Nat → WordMemory) (base : Nat)
    (words : PackedMatrix) (k : Nat) (scale input : Nat → Float32)
    (reduce : SimdReduction) (cast : Float32 → Float32) (col : Nat) : Float32 :=
  cast (reduce (fun y => threadgroup load (before (32*(col/1024)+y.val)) base words k scale input
    (32*(col/1024)+y.val) (col%1024)))

theorem output_correct (load : ThreadgroupLoad) (hardware : LoadContract load)
    (before : Nat → WordMemory) (base : Nat) (ha : base%4=0) (hn : base+16384 ≤ 2^64)
    (words : PackedMatrix) (k : Nat) (hk : k=2 ∨ k=3 ∨ k=4)
    (scale input : Nat → Float32) (reduce : SimdReduction) (cast : Float32 → Float32)
    (col : Nat) (hc : col<5120) :
    output load before base words k scale input reduce cast col =
      fold reduce cast (partialSum words k scale input) col := by
  unfold output fold
  apply congrArg cast
  apply congrArg reduce
  funext y
  rw [threadgroup_correct load hardware _ base ha hn words k hk scale input _ _ (by omega)]
  obtain ⟨_, _, hy, hc⟩ := partial_coverage y.val col y.isLt hc
  rw [hy, hc]

end Inference.Kernels.Trellis.DownMemory
