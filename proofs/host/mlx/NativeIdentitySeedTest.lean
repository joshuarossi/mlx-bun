import host.mlx.NativeIdentitySeed
import host.ts.RenameRuntimeSourceCut

set_option Elab.async false
namespace Host.Mlx.Ffi.Annotated.Initial.Test
open Host.Ts

theorem literal_shape : ([Dim.lit 1,Dim.lit 4,Dim.lit 256]).all checkDimension = true := by
  host_kernel_rfl

theorem symbolic_shape_rejected : checkDimension (.sym (.ref 0)) = false := rfl

theorem inexact_integer_rejected : checkDimension (.lit 9007199254740993) = false := by
  host_kernel_rfl

end Host.Mlx.Ffi.Annotated.Initial.Test
