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
  let unknown ← registeredNativeSourceCommands (toExpr chars!"unregistered_operation")
  unless unknown.isEmpty do throwError "native source registry accepted an unknown symbol"

/-- error: native source registry: empty symbol -/
#guard_msgs in
host_register_native_source "" => "host_retained_cached"

/-- error: native source registry: empty command -/
#guard_msgs in
host_register_native_source "unused" => ""
