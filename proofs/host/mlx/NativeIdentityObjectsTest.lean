import host.mlx.NativeIdentityObjects
namespace Host.Mlx.Ffi.Annotated.Initial
open Host.Ts
theorem reject_symbolic_callback : checkObjectPayload (.num (.ref 0)) = false := rfl
theorem reject_unclassified_bigint : checkObjectPayload (.big 29363) = false := rfl
theorem reject_future_trace_node : checkObjectTrace 10 ⟨[1],[10],[1]⟩ = false := by decide +kernel
theorem typed_callback_region : checkObjectPayload (.extPtr 281474976715599 0) = true := rfl
end Host.Mlx.Ffi.Annotated.Initial
