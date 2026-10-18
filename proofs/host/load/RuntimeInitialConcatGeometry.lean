import host.ts.renameOrdinary.RankOriginInitializedVector
import host.mlx.OrdinaryConcatInventoryFrontend
import host.mlx.ClosedGeometry

set_option Elab.async false
set_option maxRecDepth 1000000
set_option maxHeartbeats 1000000
namespace Host.Load.Run.Full.Ordinary.RankOrigin.InitialConcat
open Host.Ts Host.Ts.Owned Host.Mlx.Ffi Host.Mlx.Ffi.Annotated

theorem first_shape : (ObjectSeed.roles ConcatInventoryCases.Source336.x).shape = closedShape [1,3,10240] := by
  host_kernel_rfl
theorem second_shape : (ObjectSeed.roles ConcatInventoryCases.Source336.y).shape = closedShape [1,1,10240] := by
  host_kernel_rfl
theorem source_axis : ConcatInventoryCases.Source336.axis = 1 := by host_kernel_rfl

/-- Geometry of the actual initialized convolution history and input row.
This is an entry specialization; no varying cache-position claim is made. -/
theorem geometry (ν : Nat → F64) :
    ConcatGeometry ν (ObjectSeed.roles ConcatInventoryCases.Source336.x).shape
      (ObjectSeed.roles ConcatInventoryCases.Source336.y).shape (closedShape [1,4,10240]) ConcatInventoryCases.Source336.axis := by
  rw [first_shape,second_shape,source_axis]
  refine ⟨[1,3,10240],[1,1,10240],?_,?_,rfl,rfl,?_⟩
  · host_kernel_rfl
  · host_kernel_rfl
  · exact .cons _ _ rfl (by change F64.toInt? (F64.ofInt 1) = some 1; decide +kernel)
      (.cons _ _ rfl (by change F64.toInt? (F64.ofInt 4) = some 4; decide +kernel)
        (.cons _ _ rfl (by change F64.toInt? (F64.ofInt 10240) = some 10240; decide +kernel) .nil))

end Host.Load.Run.Full.Ordinary.RankOrigin.InitialConcat
