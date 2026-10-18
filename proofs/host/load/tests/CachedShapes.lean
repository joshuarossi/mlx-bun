import host.load.CachedShapes
namespace Host.Load.CachedShapes.Tests
open Host.Mlx Host.Mlx.FfiEval
private def graph : Nat → Option (RNode Int InKey)
  | 2 => some ⟨.zeros [1,4,256,256] 12, []⟩
  | 3 => some ⟨.zeros [1,4,1,256] 12, []⟩
  | 4 => some ⟨.sliceUpdate [0,0,1,0] [1,4,2,256] [1,1,1,1], [2,3]⟩
  | 5 => some ⟨.sliceUpdate [] [] [], [5,3]⟩
  | _ => none
theorem updated_capacity_checked : check graph .bfloat16 [1,4,256,256] 2 4 = true := rfl
theorem wrong_capacity_rejected : check graph .bfloat16 [1,4,257,256] 2 4 = false := rfl
theorem cyclic_base_rejected : check graph .bfloat16 [1,4,256,256] 3 5 = false := rfl
end Host.Load.CachedShapes.Tests
