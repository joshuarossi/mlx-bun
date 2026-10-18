import host.ts.RenameInitialArrayHandles
import host.ts.RenameRuntimeSourceCut

set_option Elab.async false
namespace Host.Ts.Owned.Annotated.InitialArrayHandles.Test
open Parametric

def arrayObject : Obj := ⟨.ordinary,.obj 4854,[],[((4852,chars!"handle"),.data (.big (.ofNat 7)) true false)],true⟩
def emptyNative : Host.Mlx.Ffi.St := Host.Mlx.Ffi.init [] [] [] []
def arrayNative : Host.Mlx.Ffi.St :=
  {emptyNative with arrs := PTrie.set .nil 7 11, nodes := PTrie.set .nil 11 ⟨.zeros,[],[],12⟩}

theorem array_selected : objectHandle arrayNative 4854 4852 chars!"handle" arrayObject = some (7,11) := by host_kernel_rfl
theorem bigint_without_array_rejected : objectHandle emptyNative 4854 4852 chars!"handle" arrayObject = none := by host_kernel_rfl
theorem stream_without_array_rejected : objectHandle {emptyNative with objs := PTrie.set .nil 7 .stream}
    4854 4852 chars!"handle" arrayObject = none := by host_kernel_rfl
theorem freed_array_rejected : objectHandle {emptyNative with arrs := PTrie.set .nil 7 0}
    4854 4852 chars!"handle" arrayObject = none := by host_kernel_rfl
theorem wrong_brand_rejected : objectHandle arrayNative 4854 4853 chars!"handle" arrayObject = none := by host_kernel_rfl
theorem wrong_prototype_rejected : objectHandle arrayNative 4853 4852 chars!"handle" arrayObject = none := by host_kernel_rfl

end Host.Ts.Owned.Annotated.InitialArrayHandles.Test
