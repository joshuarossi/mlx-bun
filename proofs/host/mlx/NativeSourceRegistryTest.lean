import host.mlx.NativeSourcePlugins

set_option Elab.async false

/- Imported registrations survive .olean boundaries and preserve candidate
order. A repeated identical registration does not duplicate a candidate. -/
host_register_native_source "mlx_closure_apply" => "host_retained_cached"

open Lean Elab Command Meta Host.Ts Host.Ts.Owned.Annotated.Driver in
run_cmd liftTermElabM do
  let cached ← registeredNativeSourceCommands (toExpr chars!"mlx_closure_apply")
  unless cached == #["host_retained_cached","host_retained_shapeless"] do
    throwError "native source registry lost imported candidates or duplicated a registration"
  let append ← registeredNativeSourceCommands (toExpr chars!"mlx_slice_update")
  unless append == #["host_retained_kvAppend"] do throwError "native source registry selected the wrong append command"
  let view ← registeredNativeSourceCommands (toExpr chars!"mlx_slice")
  unless view == #["host_retained_kvView","host_retained_closedFixedSlice","host_retained_fixedSlice"] do throwError "native source registry selected the wrong view commands"
  let disposal ← registeredNativeSourceCommands (toExpr chars!"mlx_array_free")
  unless disposal == #["host_retained_arrayFree"] do throwError "native source registry selected the wrong array disposal command"
  let attention ← registeredNativeSourceCommands (toExpr chars!"mlx_fast_scaled_dot_product_attention")
  unless attention == #["host_retained_attention"] do throwError "native source registry selected the wrong attention command"
  let configInt ← registeredNativeSourceCommands (toExpr chars!"mlx_fast_metal_kernel_config_add_template_arg_int")
  unless configInt == #["host_retained_configInt"] do throwError "native source registry selected the wrong configuration setter command"
  let configNew ← registeredNativeSourceCommands (toExpr chars!"mlx_fast_metal_kernel_config_new")
  unless configNew == #["host_retained_configNew"] do throwError "native source registry selected the wrong configuration constructor command"
  let configFree ← registeredNativeSourceCommands (toExpr chars!"mlx_fast_metal_kernel_config_free")
  unless configFree == #["host_retained_configFree"] do throwError "native source registry selected the wrong configuration disposal command"
  let output ← registeredNativeSourceCommands (toExpr chars!"mlx_fast_metal_kernel_config_add_output_arg")
  unless output == #["host_retained_configOutput"] do throwError "native source registry selected the wrong output declaration command"
  let dtype ← registeredNativeSourceCommands (toExpr chars!"mlx_fast_metal_kernel_config_add_template_arg_dtype")
  unless dtype == #["host_retained_configDtype"] do throwError "native source registry selected the wrong dtype declaration command"
  for symbol in [chars!"mlx_fast_metal_kernel_config_set_grid",chars!"mlx_fast_metal_kernel_config_set_thread_group"] do
    let commands ← registeredNativeSourceCommands (toExpr symbol)
    unless commands == #["host_retained_configTriplet"] do throwError "native source registry selected the wrong grid/group command"
  let metal ← registeredNativeSourceCommands (toExpr chars!"mlx_fast_metal_kernel_apply")
  unless metal == #["host_retained_metal"] do throwError "native source registry selected the wrong Metal application command"
  let dynamicSlice ← registeredNativeSourceCommands (toExpr chars!"mlx_slice_dynamic")
  unless dynamicSlice == #["host_retained_sliceDynamic"] do throwError "native source registry selected the wrong dynamic slice command"
  let sigmoid ← registeredNativeSourceCommands (toExpr chars!"mlx_sigmoid")
  unless sigmoid == #["host_retained_unary"] do throwError "native source registry selected the wrong unary command"
  let conv ← registeredNativeSourceCommands (toExpr chars!"mlx_conv1d")
  unless conv == #["host_retained_conv1d"] do throwError "native source registry selected the wrong convolution command"
  for symbol in [chars!"mlx_add",chars!"mlx_multiply"] do
    let commands ← registeredNativeSourceCommands (toExpr symbol)
    unless commands == #["host_retained_binary"] do throwError "native source registry selected the wrong binary command"
  let newData ← registeredNativeSourceCommands (toExpr chars!"mlx_array_new_data")
  unless newData == #["host_retained_arrayNewData"] do throwError "native source registry selected the wrong data constructor command"
  let reshape ← registeredNativeSourceCommands (toExpr chars!"mlx_reshape")
  unless reshape == #["host_retained_reshape"] do throwError "native source registry selected the wrong reshape command"
  let rope ← registeredNativeSourceCommands (toExpr chars!"mlx_fast_rope")
  unless rope == #["host_retained_rope"] do throwError "native source registry selected the wrong rope command"
  for (symbol,command) in [(chars!"mlx_vector_array_new","host_retained_vectorNew"),
      (chars!"mlx_vector_array_size","host_retained_vectorSize"),(chars!"mlx_vector_array_get","host_retained_vectorGet")] do
    let commands ← registeredNativeSourceCommands (toExpr symbol)
    unless commands == #[command] do throwError "native source registry selected the wrong vector command"
  let transpose ← registeredNativeSourceCommands (toExpr chars!"mlx_transpose_axes")
  unless transpose == #["host_retained_transpose"] do throwError "native source registry selected the wrong transpose command"
  let quantized ← registeredNativeSourceCommands (toExpr chars!"mlx_quantized_matmul")
  unless quantized == #["host_retained_quantized"] do throwError "native source registry selected the wrong quantized command"
  let rms ← registeredNativeSourceCommands (toExpr chars!"mlx_fast_rms_norm")
  unless rms == #["host_retained_rms"] do throwError "native source registry selected the wrong RMS command"
  for symbol in [chars!"mlx_async_eval",chars!"mlx_array_eval",chars!"mlx_eval"] do
    let commands ← registeredNativeSourceCommands (toExpr symbol)
    unless commands == #["host_retained_eval"] do throwError "native source registry selected the wrong evaluation command"
  let arrayDtype ← registeredNativeSourceCommands (toExpr chars!"mlx_array_dtype")
  unless arrayDtype == #["host_retained_dtype"] do throwError "native source registry selected the wrong array dtype command"
  let arraySize ← registeredNativeSourceCommands (toExpr chars!"mlx_array_size")
  unless arraySize == #["host_retained_size"] do throwError "native source registry selected the wrong array size command"
  let unknown ← registeredNativeSourceCommands (toExpr chars!"unregistered_operation")
  unless unknown.isEmpty do throwError "native source registry accepted an unknown symbol"

/-- error: native source registry: empty symbol -/
#guard_msgs in
host_register_native_source "" => "host_retained_cached"

/-- error: native source registry: empty command -/
#guard_msgs in
host_register_native_source "unused" => ""
