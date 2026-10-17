import contracts.mlx.Memory
import kernels.trellis.CodebookLoad

namespace Inference.Kernels.Trellis.CodebookInitialization
open Contracts.Mlx Contracts.Mlx.M1Max

def entry (base threads thread iteration : Nat) : Memory.Store :=
  { word := base/4 + (thread+threads*iteration)
    value := CodebookLoad.codeValue (BitVec.ofNat 32 (thread+threads*iteration)) }

-- One iteration for each store of each thread's strided source loop. The
-- concrete down/gate-up launches use respectively 256 and 1024 threads.
def stores (base threads : Nat) : List Memory.Store :=
  (List.range threads).flatMap fun thread =>
    (List.range (4096/threads)).map fun iteration => entry base threads thread iteration

theorem address_injective (base threads t₁ t₂ i₁ i₂ : Nat)
    (ht : threads=256 ∨ threads=1024) (h₁ : t₁<threads) (h₂ : t₂<threads)
    (he : (entry base threads t₁ i₁).word = (entry base threads t₂ i₂).word) :
    t₁=t₂ ∧ i₁=i₂ := by
  simp only [entry] at he
  rcases ht with rfl | rfl <;> omega

theorem bounded (base threads : Nat) (ht : threads=256 ∨ threads=1024)
    (s : Memory.Store) (hs : s ∈ stores base threads) :
    base/4 ≤ s.word ∧ s.word < base/4+4096 := by
  obtain ⟨thread, hthread, hs⟩ := List.mem_flatMap.mp hs
  obtain ⟨iteration, hiteration, rfl⟩ := List.mem_map.mp hs
  have hthread := List.mem_range.mp hthread
  have hiteration := List.mem_range.mp hiteration
  simp only [entry]
  rcases ht with rfl | rfl <;> omega

theorem covers (base threads i : Nat) (ht : threads=256 ∨ threads=1024) (hi : i<4096) :
    ∃ s ∈ stores base threads, s.word=base/4+i := by
  have ⟨hthread, hiteration, he⟩ := CodebookLoad.initialization_owners i threads hi ht
  refine ⟨entry base threads (i%threads) (i/threads), ?_, ?_⟩
  · apply List.mem_flatMap.mpr
    refine ⟨i%threads, List.mem_range.mpr hthread, ?_⟩
    exact List.mem_map.mpr ⟨i/threads, List.mem_range.mpr hiteration, rfl⟩
  · simp only [entry, he]

theorem correct_value (base threads i : Nat) (s : Memory.Store)
    (hs : s ∈ stores base threads) (he : s.word=base/4+i) :
    s.value=CodebookLoad.codeValue (BitVec.ofNat 32 i) := by
  obtain ⟨thread, _, hs⟩ := List.mem_flatMap.mp hs
  obtain ⟨iteration, _, rfl⟩ := List.mem_map.mp hs
  simp only [entry] at he ⊢
  rw [show thread+threads*iteration=i by omega]

-- Holds for any interleaving of the threads' stores. The barrier's platform
-- obligation is to expose these completed writes before the table is read.
theorem initialized (before : WordMemory) (base threads : Nat)
    (ht : threads=256 ∨ threads=1024) (schedule : List Memory.Store)
    (order : schedule.Perm (stores base threads)) :
    CodebookLoad.Initialized (Memory.execute schedule before) base := by
  intro i hi
  exact Memory.written_value_permuted (stores base threads) schedule order before (base/4+i)
    (CodebookLoad.codeValue (BitVec.ofNat 32 i))
    (fun s hs he => correct_value base threads i s hs he) (covers base threads i ht hi)

theorem frame (before : WordMemory) (base threads word : Nat)
    (ht : threads=256 ∨ threads=1024) (schedule : List Memory.Store)
    (order : schedule.Perm (stores base threads))
    (outside : word<base/4 ∨ base/4+4096≤word) :
    Memory.execute schedule before word = before word := by
  apply Memory.frame
  intro s hs
  have hb := bounded base threads ht s (order.mem_iff.mp hs)
  omega

end Inference.Kernels.Trellis.CodebookInitialization
