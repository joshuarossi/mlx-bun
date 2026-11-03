import host.sim.compose.a4b.fd_x4_L7.NewDataFacts
set_option Elab.async false
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
namespace Host.Ts.Sim.Compose.FDX4L7.ND.Values
open Host.Ts Host.Ts.Sim Host.Ts.Sim.Full Host.Ts.Sim.Template Host.Load.Run.Tpl
kernel_rfl pre_next : (mlxOf PRE_fd_x4_L7_r0.s16.ffi).next = 22174
kernel_rfl pre_nnext : (mlxOf PRE_fd_x4_L7_r0.s16.ffi).nnext = 19265
kernel_rfl post_next : (mlxOf PRE_fd_x4_L7_r0.s17.ffi).next = 22175
kernel_rfl post_nnext : (mlxOf PRE_fd_x4_L7_r0.s17.ffi).nnext = 19266
kernel_rfl shape : Host.Mlx.Ffi.dimsArg (nthD (.big 0) ND.ndArgs 0) (nthD (.big 0) ND.ndArgs 1) =
  some [.lit 1, .lit 1]
kernel_rfl dtype : Host.Mlx.Ffi.argNat (nthD (.big 0) ND.ndArgs 2) = some 7
kernel_rfl ndCount : ND.ndArgs.length = 3
kernel_rfl args : ND.ndArgs = [(nthD (.big 0) ND.ndArgs 0), (nthD (.big 0) ND.ndArgs 1), (nthD (.big 0) ND.ndArgs 2)]
end Host.Ts.Sim.Compose.FDX4L7.ND.Values
