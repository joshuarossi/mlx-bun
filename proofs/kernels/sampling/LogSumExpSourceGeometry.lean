import kernels.sampling.LogSumExpSourceSyntax
import kernels.sampling.LogSumExpMemory
namespace Inference.Kernels.Sampling.LogSumExpSourceGeometry
open Contracts.Mlx
open FloatLib.Floats.Formats.BinaryInterchange
set_option maxRecDepth 10000

def iterations (axis reads threads : Nat) : Nat := (axis+reads*threads-1)/(reads*threads)
def offset (r lid : Nat) : Nat := r*1024*4+lid*4

theorem selected_iterations : iterations 248320 4 1024=61 := by decide

theorem address (iteration : Fin 61) (thread : Fin 1024) (read : Fin 4) :
    offset iteration.val thread.val+read.val=LogSumExpLayout.offset iteration thread read := by
  simp [offset,LogSumExpLayout.offset,Nat.mul_assoc]

theorem full_branch (iteration : Fin 61) (thread : Fin 1024) :
    offset iteration.val thread.val+4≤248320 ↔ iteration.val<60 ∨ thread.val<640 := by
  unfold offset
  omega

theorem signed_bounds (iteration : Fin 61) (thread : Fin 1024) (read : Fin 4) :
    offset iteration.val thread.val+read.val+4<2^31 := by
  rw [address]
  exact LogSumExpLayout.signed_address_safe iteration thread read

-- r is nonnegative int32; multiplication with uint lsize promotes it to
-- uint32 before the final assignment back to int32. Every intermediate is
-- representable, so all unsigned wraps and the signed cast are inactive.
def unsignedOffset (r lid : Nat) : Nat :=
  (((r%2^32*1024)%2^32*4)%2^32+(lid%2^32*4)%2^32)%2^32

theorem unsigned_no_wrap (iteration : Fin 61) (thread : Fin 1024) :
    unsignedOffset iteration.val thread.val=offset iteration.val thread.val := by
  have r : iteration.val<2^32 := by have := iteration.isLt; omega
  have lid : thread.val<2^32 := by have := thread.isLt; omega
  have product : iteration.val*1024<2^32 := by have := iteration.isLt; omega
  have block : iteration.val*1024*4<2^32 := by have := iteration.isLt; omega
  have lane : thread.val*4<2^32 := by have := thread.isLt; omega
  have total : iteration.val*1024*4+thread.val*4<2^32 := by
    have := iteration.isLt;have := thread.isLt;omega
  simp only [unsignedOffset,Nat.mod_eq_of_lt r,Nat.mod_eq_of_lt lid,Nat.mod_eq_of_lt product,
    Nat.mod_eq_of_lt block,Nat.mod_eq_of_lt lane,Nat.mod_eq_of_lt total,offset]

-- The conditional is evaluated before the BF16 load. Both native branches
-- retain their original bounds: a full block load, or a per-cell tail test.
def load (memory : ByteMemory.Bytes) (base : Nat) (iteration : Fin 61) (thread : Fin 1024) (read : Fin 4) : Float32 :=
  let begin := offset iteration.val thread.val
  if begin+4≤248320 then
    BFloat16.widen (Model.ofBits (HalfMemory.load memory (base+2*(begin+read.val))))
  else if begin+read.val<248320 then
    BFloat16.widen (Model.ofBits (HalfMemory.load memory (base+2*(begin+read.val))))
  else LogSumExpExponentRanges.negativeInfinity

theorem load_capture (memory : ByteMemory.Bytes) (base : Nat) (iteration : Fin 61) (thread : Fin 1024) (read : Fin 4) :
    load memory base iteration thread read=LogSumExpMemory.capture memory base iteration thread read := by
  unfold load LogSumExpMemory.capture
  dsimp only
  rw [←address]
  by_cases whole : offset iteration.val thread.val+4≤248320
  · rw [if_pos whole,if_pos (show offset iteration.val thread.val+read.val<248320 from by have := read.isLt; omega)]
  · rw [if_neg whole]

theorem load_source {logits : Fin 248320→ArrayStorage.BF} (source : ArrayStorage.BFBuffer logits)
    (iteration : Fin 61) (thread : Fin 1024) (read : Fin 4) :
    load source.bytes source.base iteration thread read=
      LogSumExpLoopRanges.values (fun i=>BFloat16.widen (logits i)) iteration thread read := by
  rw [load_capture]
  exact LogSumExpMemory.capture_source source iteration thread read

theorem padded_no_load (memory : ByteMemory.Bytes) (base : Nat) (thread : Fin 1024) (tail : 640≤thread.val)
    (read : Fin 4) : load memory base ⟨60,by decide⟩ thread read=LogSumExpExponentRanges.negativeInfinity := by
  rw [load_capture]
  have invalid : ¬LogSumExpLayout.offset ⟨60,by decide⟩ thread read<248320 := by
    intro inside
    rcases (LogSumExpLayout.read_in_bounds ⟨60,by decide⟩ thread read).mp inside with h|h
    · change 60<60 at h
      omega
    · omega
  unfold LogSumExpMemory.capture
  rw [if_neg invalid]
theorem loaded_address_bounds {logits : Fin 248320→ArrayStorage.BF} (source : ArrayStorage.BFBuffer logits)
    (iteration : Fin 61) (thread : Fin 1024) (read : Fin 4)
    (loaded : offset iteration.val thread.val+read.val<248320) :
    source.base+2*(offset iteration.val thread.val+read.val)+2≤2^64 ∧
      (source.base+2*(offset iteration.val thread.val+read.val))%2=0 := by
  have := source.bounded
  have := source.aligned
  constructor <;> omega
end Inference.Kernels.Sampling.LogSumExpSourceGeometry
