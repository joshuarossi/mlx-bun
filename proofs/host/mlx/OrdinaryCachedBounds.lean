import host.mlx.OrdinaryCachedAnnotations
import host.ts.StoreEntries

set_option Elab.async false
set_option maxRecDepth 1000000
set_option maxHeartbeats 0

namespace Host.Load.Run.Full.Ordinary.CachedCall
open Host.Ts Host.Mlx.Ffi

theorem source_items_check : source.items.checkBound source.nnext = true := by host_kernel_rfl
theorem source_objs_check : source.objs.checkBound source.next = true := by host_kernel_rfl
theorem source_arrs_check : source.arrs.checkBound source.next = true := by host_kernel_rfl

theorem source_items_bound : ∀ i item, source.items.get i = some item → i < source.nnext :=
  PTrie.bound_of_check _ _ source_items_check

theorem source_objects_bound : ∀ h obj, source.objs.get h = some obj → h < source.next :=
  PTrie.bound_of_check _ _ source_objs_check

theorem source_arrays_bound : ∀ h i, source.arrs.get h = some i → h < source.next :=
  PTrie.bound_of_check _ _ source_arrs_check

end Host.Load.Run.Full.Ordinary.CachedCall
