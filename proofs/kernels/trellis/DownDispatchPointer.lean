import kernels.trellis.DownDispatchSource
namespace Inference.Kernels.Trellis.DownDispatchPointer
open Contracts.Mlx
set_option maxRecDepth 10000

def prepare (k ty sg lane r u : Nat) : Option DownPointerSemantics.Value :=
  (DownDispatchSource.dispatch k ty sg lane).bind (fun point =>
    DownPointerSource.prepare k point.2.1.toNat point.2.2.toNat r u true)

theorem prepared (k ty sg lane r u : Nat) (valid : k=2 ∨ k=3 ∨ k=4)
    (tyBound : ty<160) (sgBound : sg<8) (laneBound : lane<32) (rowOffset : r+u<136) :
    prepare k ty sg lane r u=some (.pointer
      (DownPointerSource.base k ((2*(ty/32)+sg/4)*2+lane/16)
        ((ty%32+32*(sg%4))*136+r+u))) := by
  have splitBound : ty%32+32*(sg%4)<128 := by omega
  have blockBound : (2*(ty/32)+sg/4)*2+lane/16<20 := by omega
  have rowBound : (ty%32+32*(sg%4))*136+r+u<17408 := by omega
  have blockSmall : (2*(ty/32)+sg/4)*2+lane/16<2^32 := by omega
  have startSmall : (ty%32+32*(sg%4))*136<2^32 := by omega
  simp only [prepare,DownDispatchSource.dispatch_selected k ty sg lane valid tyBound sgBound laneBound,
    Option.bind_some,BitVec.toNat_ofNat,Nat.mod_eq_of_lt blockSmall,Nat.mod_eq_of_lt startSmall]
  exact DownPointerSource.prepared_pair k _ _ r u valid blockBound rowBound

def read (input : PackedArrayDownMaterialization.Input k) (ty sg lane r u word : Nat) : Option (BitVec 32) :=
  (prepare k ty sg lane r u).bind (fun value => match value with
    | .pointer offset => some (ByteMemory.load32 input.storage.code.bytes (input.storage.code.base+4*(offset.toNat+word)))
    | _ => none)

theorem current_word (input : PackedArrayDownMaterialization.Input k) (ty sg lane r u word : Nat)
    (tyBound : ty<160) (sgBound : sg<8) (laneBound : lane<32) (rowOffset : r+u<136) (wordBound : word<8*k) :
    read input ty sg lane r u word=some
      (input.matrix ((ty%32+32*(sg%4))*136+r+u) ((2*(ty/32)+sg/4)*2+lane/16) word) := by
  rw [read,prepared k ty sg lane r u input.valid tyBound sgBound laneBound rowOffset,Option.bind_some]
  have splitBound : ty%32+32*(sg%4)<128 := by omega
  exact congrArg some (DownPointerSource.current_word input _ _ word (by omega) (by omega) wordBound)
end Inference.Kernels.Trellis.DownDispatchPointer
