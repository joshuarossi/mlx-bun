import kernels.delta.SiluHeads128Output

namespace Inference.Kernels.Delta.SiluHeads128Geometry
open Contracts.Mlx
open Layers

def channel (head : Fin 80) : Nat :=
  if head.val<2*16 then head.val*128 else 2*16*128+(head.val-2*16)*128

theorem channel_eq (head : Fin 80) : channel head=head.val*128 := by
  unfold channel
  split <;> omega

theorem query_route (head : Fin 16) :
    (DeltaHeads.qHead head).val<32 ∧ (DeltaHeads.qHead head).val<16 ∧
    (DeltaHeads.qHead head).val%16=head.val := by
  have := head.isLt
  dsimp [DeltaHeads.qHead]
  omega

theorem key_route (head : Fin 16) :
    (DeltaHeads.kHead head).val<32 ∧ ¬(DeltaHeads.kHead head).val<16 ∧
    (DeltaHeads.kHead head).val%16=head.val := by
  have := head.isLt
  dsimp [DeltaHeads.kHead]
  omega

theorem value_route (head : Fin 48) :
    ¬(DeltaHeads.vHead head).val<32 ∧ (DeltaHeads.vHead head).val-32=head.val := by
  have := head.isLt
  dsimp [DeltaHeads.vHead]
  omega

theorem all_heads (head : Fin 80) :
    (∃ q : Fin 16,head=DeltaHeads.qHead q) ∨
    (∃ k : Fin 16,head=DeltaHeads.kHead k) ∨
    (∃ v : Fin 48,head=DeltaHeads.vHead v) := by
  have := head.isLt
  by_cases query : head.val<16
  · exact Or.inl ⟨⟨head.val,query⟩,rfl⟩
  · by_cases key : head.val<32
    · refine Or.inr (Or.inl ⟨⟨head.val-16,by omega⟩,?_⟩)
      apply Fin.ext
      dsimp [DeltaHeads.kHead]
      omega
    · refine Or.inr (Or.inr ⟨⟨head.val-32,by omega⟩,?_⟩)
      apply Fin.ext
      dsimp [DeltaHeads.vHead]
      omega

def head {heads : Nat} (thread : Fin (heads*32)) : Fin heads :=
  ⟨thread.val/32,by have := thread.isLt;omega⟩
def lane {heads : Nat} (thread : Fin (heads*32)) : Fin 32 := ⟨thread.val%32,by omega⟩

theorem thread_index {heads : Nat} (thread : Fin (heads*32)) (i : Fin 4) :
    (head thread).val*128+(Gated.laneIndex (lane thread) i).val=thread.val*4+i.val := by
  dsimp [head,lane,Gated.laneIndex]
  omega

theorem physical_threads : 16*32+16*32+48*32=2560 := by decide

variable {values : Fin 10240 → ArrayStorage.BF} {qScale kScale : Fin 128 → ArrayStorage.BF}

def current (input : DeltaHeadsMemory.Input values qScale kScale) (head : Fin 80) (col : Nat) : ArrayStorage.BF :=
  FloatLib.Floats.Formats.BinaryInterchange.Model.ofBits
    (HalfMemory.load input.storage.input.bytes (input.storage.input.base+2*(channel head+col)))

theorem current_read (input : DeltaHeadsMemory.Input values qScale kScale) (head : Fin 80) (col : Fin 128) :
    current input head col.val=input.storage.input.read (DeltaHeads.channel head col) := by
  unfold current
  rw [channel_eq]
  rfl

theorem current_bounds (input : DeltaHeadsMemory.Input values qScale kScale) (head : Fin 80) (col : Fin 128) :
    (input.storage.input.base+2*(channel head+col.val))%2=0 ∧
    input.storage.input.base+2*(channel head+col.val)+2≤2^64 := by
  rw [channel_eq]
  exact input.storage.input.bounds (DeltaHeads.channel head col)

end Inference.Kernels.Delta.SiluHeads128Geometry
