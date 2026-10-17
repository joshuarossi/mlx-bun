import contracts.mlx.ThreadgroupWrites
import kernels.trellis.CodebookInitialization

namespace Inference.Kernels.Trellis.CodebookBarrier
open Contracts.Mlx Contracts.Mlx.M1Max

def programs (base threads : Nat) : List (List Memory.Store) :=
  (List.range threads).map fun thread =>
    (List.range (4096/threads)).map fun iteration => CodebookInitialization.entry base threads thread iteration

theorem loop_test (threads thread iteration : Nat) (ht : threads=256 ∨ threads=1024) (lane : thread<threads) :
    thread+threads*iteration<4096 ↔ iteration<4096/threads := by
  rcases ht with rfl | rfl <;> omega

theorem flatten_programs (base threads : Nat) : (programs base threads).flatten = CodebookInitialization.stores base threads := by
  simp [programs, CodebookInitialization.stores, List.flatMap]

theorem initialized (before : WordMemory) (base threads : Nat) (ht : threads=256 ∨ threads=1024)
    (schedule : List Memory.Store) (remaining : List (List Memory.Store))
    (execution : ThreadgroupWrites.Executes (programs base threads) schedule remaining)
    (barrier : ThreadgroupWrites.AtBarrier remaining) :
    CodebookLoad.Initialized (Memory.execute schedule before) base := by
  have order := ThreadgroupWrites.completed_schedule execution barrier
  rw [flatten_programs] at order
  exact CodebookInitialization.initialized before base threads ht schedule order

theorem frame (before : WordMemory) (base threads word : Nat) (ht : threads=256 ∨ threads=1024)
    (schedule : List Memory.Store) (remaining : List (List Memory.Store))
    (execution : ThreadgroupWrites.Executes (programs base threads) schedule remaining)
    (barrier : ThreadgroupWrites.AtBarrier remaining)
    (outside : word<base/4 ∨ base/4+4096≤word) : Memory.execute schedule before word=before word := by
  have order := ThreadgroupWrites.completed_schedule execution barrier
  rw [flatten_programs] at order
  exact CodebookInitialization.frame before base threads word ht schedule order outside

end Inference.Kernels.Trellis.CodebookBarrier
