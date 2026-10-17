import kernels.normalization.MlxRmsHostSelection
import kernels.RmsHeadsMemory

namespace Inference.Kernels.Normalization.MlxRmsHeadHostSelection
open Contracts.Mlx MlxRmsHostSelection
set_option maxRecDepth 10000

-- Native metadata attachment stays explicit. These are the contiguous rows
-- and unit weight stride used by the selected Q/K head normalization path.
def metadata (heads width : Nat) (donatable : Bool) : Metadata :=
  ⟨width,heads*width,4,true,1,width,heads,donatable,1,1⟩

theorem head256_launch (heads : Nat) (rowsBound : heads<2^31) (kernel : KernelLimit)
    (capacity : 64≤kernel.threads) (donatable : Bool) :
    select (metadata heads 256 donatable) kernel=some
      ⟨256,heads,false,1,64,heads*64,if donatable then .donated else .fresh⟩ := by
  change heads<2147483648 at rowsBound
  cases donatable <;> simp [select,metadata,noCopy,allocation,loopedLimit,reads,simdWidth,rowsBound,capacity]

theorem head128_launch (heads : Nat) (rowsBound : heads<2^31) (kernel : KernelLimit)
    (capacity : 32≤kernel.threads) (donatable : Bool) :
    select (metadata heads 128 donatable) kernel=some
      ⟨128,heads,false,1,32,heads*32,if donatable then .donated else .fresh⟩ := by
  change heads<2147483648 at rowsBound
  cases donatable <;> simp [select,metadata,noCopy,allocation,loopedLimit,reads,simdWidth,rowsBound,capacity]

theorem selected_query (kernel : KernelLimit) (capacity : 64≤kernel.threads) :
    select (metadata 24 256 true) kernel=some ⟨256,24,false,1,64,1536,.donated⟩ :=
  head256_launch 24 (by decide) kernel capacity true

theorem selected_key (kernel : KernelLimit) (capacity : 64≤kernel.threads) :
    select (metadata 4 256 true) kernel=some ⟨256,4,false,1,64,256,.donated⟩ :=
  head256_launch 4 (by decide) kernel capacity true

theorem full_block (thread : Fin 64) : thread.val*4+4≤256 := by have := thread.isLt; omega

theorem unsigned_full_block (thread : Fin 64) :
    ((thread.val*4)%2^32+4)%2^32≤256 := by
  have small : thread.val*4<4294967296 := by have := thread.isLt; omega
  have sum : thread.val*4+4<4294967296 := by have := thread.isLt; omega
  simp only [show 2^32=4294967296 by rfl,Nat.mod_eq_of_lt small,Nat.mod_eq_of_lt sum]
  exact full_block thread

-- No tail element is executed for the selected 256-wide/64-thread pipeline.
-- Signed int i advances from 0 through 3, then stops at 4 without overflow.
theorem inner_counter (i : Fin 4) : (i.val:Int)+1≤4 ∧ (i.val:Int)+1<2^31 := by
  have := i.isLt
  omega

end Inference.Kernels.Normalization.MlxRmsHeadHostSelection
