import host.ts.RenameNativeSourceRegistry
import host.mlx.NativeCachedFrontend
import host.mlx.NativeShapelessFrontend
import host.mlx.NativeKvAppendFrontend
import host.mlx.NativeKvViewFrontend
import host.mlx.NativeArrayFreeFrontend
import host.mlx.NativeAttentionFrontend
import host.mlx.NativeConfigIntFrontend
import host.mlx.NativeConfigFactoryFrontend
import host.mlx.NativeConfigFreeFrontend
import host.mlx.NativeFixedSliceFrontend
import host.mlx.NativeConfigOutputFrontend
import host.mlx.NativeConfigDtypeFrontend
import host.mlx.NativeClosedFixedSliceFrontend
import host.mlx.NativeConfigTripletFrontend
import host.mlx.NativeMetalFrontend
import host.mlx.NativeSliceDynamicFrontend
import host.mlx.NativeUnaryFrontend
import host.mlx.NativeConvFrontend
import host.mlx.NativeBinaryFrontend
import host.mlx.NativeDataFrontend
import host.mlx.NativeReshapeFrontend
import host.mlx.NativeRopeFrontend
import host.mlx.NativeVectorFactoryFrontend
import host.mlx.NativeVectorSizeFrontend
import host.mlx.NativeVectorGetFrontend
import host.mlx.NativeTransposeFrontend
import host.mlx.NativeQuantizedFrontend
import host.mlx.NativeRmsFrontend
import host.mlx.NativeEvalFrontend
import host.mlx.NativeDtypeFrontend
import host.mlx.NativeSizeFrontend

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
host_register_native_source "mlx_fast_metal_kernel_config_add_template_arg_int" => "host_retained_configInt"
host_register_native_source "mlx_fast_metal_kernel_config_new" => "host_retained_configNew"
host_register_native_source "mlx_fast_metal_kernel_config_free" => "host_retained_configFree"
host_register_native_source "mlx_slice" => "host_retained_closedFixedSlice"
host_register_native_source "mlx_slice" => "host_retained_fixedSlice"
host_register_native_source "mlx_fast_metal_kernel_config_add_output_arg" => "host_retained_configOutput"
host_register_native_source "mlx_fast_metal_kernel_config_add_template_arg_dtype" => "host_retained_configDtype"
host_register_native_source "mlx_fast_metal_kernel_config_set_grid" => "host_retained_configTriplet"
host_register_native_source "mlx_fast_metal_kernel_config_set_thread_group" => "host_retained_configTriplet"
host_register_native_source "mlx_fast_metal_kernel_apply" => "host_retained_metal"
host_register_native_source "mlx_slice_dynamic" => "host_retained_sliceDynamic"
host_register_native_source "mlx_sigmoid" => "host_retained_unary"
host_register_native_source "mlx_conv1d" => "host_retained_conv1d"
host_register_native_source "mlx_add" => "host_retained_binary"
host_register_native_source "mlx_multiply" => "host_retained_binary"
host_register_native_source "mlx_array_new_data" => "host_retained_arrayNewData"
host_register_native_source "mlx_reshape" => "host_retained_reshape"
host_register_native_source "mlx_fast_rope" => "host_retained_rope"
host_register_native_source "mlx_vector_array_new" => "host_retained_vectorNew"
host_register_native_source "mlx_vector_array_size" => "host_retained_vectorSize"
host_register_native_source "mlx_vector_array_get" => "host_retained_vectorGet"
host_register_native_source "mlx_transpose_axes" => "host_retained_transpose"
host_register_native_source "mlx_quantized_matmul" => "host_retained_quantized"
host_register_native_source "mlx_fast_rms_norm" => "host_retained_rms"
host_register_native_source "mlx_async_eval" => "host_retained_eval"
host_register_native_source "mlx_array_eval" => "host_retained_eval"
host_register_native_source "mlx_eval" => "host_retained_eval"
host_register_native_source "mlx_array_dtype" => "host_retained_dtype"
host_register_native_source "mlx_array_size" => "host_retained_size"
