import host.ts.RenameNativeSourceRegistry
import host.mlx.NativeCachedFrontend
import host.mlx.NativeShapelessFrontend
import host.mlx.NativeKvAppendFrontend
import host.mlx.NativeKvViewFrontend
import host.mlx.NativeArrayFreeFrontend
import host.mlx.NativeAttentionFrontend

set_option Elab.async false

/- Optional route frontends. The cached-call commands remain specializations
of their checked source cuts; registering their shared symbol does not widen
those theorems. A dispatcher must try candidates with rollback on failure. -/
host_register_native_source "mlx_closure_apply" => "host_retained_cached"
host_register_native_source "mlx_closure_apply" => "host_retained_shapeless"
host_register_native_source "mlx_slice_update" => "host_retained_kvAppend"
host_register_native_source "mlx_slice" => "host_retained_kvView"
host_register_native_source "mlx_array_free" => "host_retained_arrayFree"
host_register_native_source "mlx_fast_scaled_dot_product_attention" => "host_retained_attention"
