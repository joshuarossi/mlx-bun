import kernels.normalization.MlxRmsHeadRegisters
import kernels.normalization.MlxRmsPointerSource

namespace Inference.Kernels.Normalization.MlxRmsHeadPointers
open Contracts.Mlx MlxRmsPointerSource
set_option maxRecDepth 10000

-- The row index is a real native gid here, not a reset row-zero pointer.
-- uint multiplication by N_READS and the size_t row product retain their
-- respective 32/64-bit widths. Bounds derive from the attached head buffers.
theorem row_offset (gid : Nat) (smallGid : gid<2^32) (thread : Fin 64) :
    evaluate gid 256 thread.val 1 rowExpr=
      some (.wide (BitVec.ofNat 64 (gid*256+thread.val*4))) := by
  have smallThread : thread.val<4294967296 := by have := thread.isLt; omega
  have product : thread.val*4<4294967296 := by have := thread.isLt; omega
  have row64 : gid*256<18446744073709551616 := by change gid<4294967296 at smallGid; omega
  change gid<4294967296 at smallGid
  simp [evaluate,rowExpr,arithmetic,Unsigned.nat,BitVec.toNat_ofNat,
    Nat.mod_eq_of_lt smallGid,Nat.mod_eq_of_lt smallThread,Nat.mod_eq_of_lt product,
    Nat.mod_eq_of_lt row64]

theorem source_address (base gid : Nat) (smallGid : gid<2^32) (thread : Fin 64)
    (room : base+2*(gid*256+thread.val*4)<2^64) :
    execute sourceX "x" base gid 256 thread.val 1=some (base+2*(gid*256+thread.val*4)) := by
  have index64 : gid*256+thread.val*4<18446744073709551616 := by
    change gid<4294967296 at smallGid; have := thread.isLt; omega
  change base+2*(gid*256+thread.val*4)<18446744073709551616 at room
  simp [execute,parsed_x,row_offset gid smallGid thread,Unsigned.nat,BitVec.toNat_ofNat,
    Nat.mod_eq_of_lt index64,Nat.mod_eq_of_lt room]

theorem output_address (base gid : Nat) (smallGid : gid<2^32) (thread : Fin 64)
    (room : base+2*(gid*256+thread.val*4)<2^64) :
    execute sourceOut "out" base gid 256 thread.val 1=some (base+2*(gid*256+thread.val*4)) := by
  have index64 : gid*256+thread.val*4<18446744073709551616 := by
    change gid<4294967296 at smallGid; have := thread.isLt; omega
  change base+2*(gid*256+thread.val*4)<18446744073709551616 at room
  simp [execute,parsed_out,row_offset gid smallGid thread,Unsigned.nat,BitVec.toNat_ofNat,
    Nat.mod_eq_of_lt index64,Nat.mod_eq_of_lt room]

variable {heads base : Nat} {values : Fin heads → Fin 256 → ArrayStorage.BF} {weight : Fin 256 → ArrayStorage.BF}

theorem input_room (input : RmsHeadsMemory.Input values weight base) (head : Fin heads) (thread : Fin 64) :
    base+2*(head.val*256+thread.val*4)<2^64 := by
  have row := (input.source.rows head).bounded
  rw [input.source.addresses head] at row
  have := thread.isLt
  dsimp only [RmsHeadReads.layout] at row
  omega

theorem weight_room (input : RmsHeadsMemory.Input values weight base) (thread : Fin 64) :
    input.weight.base+2*(thread.val*4)<2^64 := by have := input.weight.bounded; have := thread.isLt; omega

theorem selected_pointers (input : RmsHeadsMemory.Input values weight base) (headBound : heads≤2^32)
    (head : Fin heads) (thread : Fin 64) :
    execute sourceX "x" base head.val 256 thread.val 1=some (base+2*(head.val*256+thread.val*4)) ∧
    execute sourceW "w" input.weight.base head.val 256 thread.val 1=some (input.weight.base+2*(thread.val*4)) ∧
    execute sourceOut "out" base head.val 256 thread.val 1=some (base+2*(head.val*256+thread.val*4)) := by
  have gid : head.val<2^32 := lt_of_lt_of_le head.isLt headBound
  have small : thread.val*4<2^32 := by have := thread.isLt; omega
  exact ⟨source_address base head.val gid thread (input_room input head thread),
    w_address input.weight.base 256 thread.val small (weight_room input thread),
    output_address base head.val gid thread (input_room input head thread)⟩

end Inference.Kernels.Normalization.MlxRmsHeadPointers
