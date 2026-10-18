import host.mlx.OrdinaryCachedCall
import host.ts.renameOrdinary.NativeCallCut

set_option Elab.async false
set_option maxRecDepth 1000000
set_option maxHeartbeats 0

namespace Host.Load.Run.Full.Ordinary.CachedCall
open Host.Ts Host.Mlx.Ffi

theorem native_at_cut : NativeCall.native = source := by rfl
theorem bytes_at_cut : NativeCall.outputBytes = actualBytes := by rfl

theorem native_at_next_cut : s3.setObj 29377 (.vec [22591,22592,22593]) = NativeCall.output.ffi.mlx := by
  host_kernel_rfl

/-- The original native dispatcher at the actual source-call boundary produces
exactly the native state in the next authoritative machine snapshot. -/
theorem native_call_at_cut :
    Host.Mlx.Ffi.call NativeCall.native chars!"mlx_closure_apply"
        [.jsPtr 3126924 0 NativeCall.outputBytes,.big 1354,.big 29376] =
      okW NativeCall.output.ffi.mlx status0 [u64Write 3126924 0 29377] := by
  change Host.Mlx.Ffi.call source chars!"mlx_closure_apply" [outArg,.big 1354,.big 29376] = _
  rw [source_cached_call,native_at_next_cut]

theorem initial_support : ∀ i, N0 i → i < source.nnext := by
  rw [source_counter]
  intro i hi
  simp [N0] at hi
  rcases hi with rfl | rfl | rfl | rfl | rfl | rfl | rfl | rfl | rfl <;> decide +kernel

end Host.Load.Run.Full.Ordinary.CachedCall
