import host.load.CachedGrowthShapes
namespace Host.Load.CachedGrowthShapes.Tests
open Host.Mlx Host.Mlx.FfiEval
private def graph : Nat → Option (RNode Int InKey)
  | 0 => some ⟨.zeros [1,4,256,256] 12, []⟩
  | 1 => some ⟨.zeros [1,4,1,256] 12, []⟩
  | 2 => some ⟨.zeros [1,4,256,256] 12, []⟩
  | 3 => some ⟨.concat 2, [0,2]⟩
  | 4 => some ⟨.sliceUpdate [0,0,256,0] [1,4,257,256] [1,1,1,1], [3,1]⟩
  | 5 => some ⟨.concat 2, [5,2]⟩
  | _ => none
theorem growth_then_update_checked : check graph .bfloat16 512 3 4 = true := rfl
theorem wrong_capacity_rejected : check graph .bfloat16 256 3 4 = false := rfl
theorem cyclic_growth_rejected : check graph .bfloat16 512 5 5 = false := rfl
end Host.Load.CachedGrowthShapes.Tests
