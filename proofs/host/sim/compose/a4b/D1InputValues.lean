import host.sim.compose.a4b.D1NewDataFacts
set_option Elab.async false
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
namespace Host.Ts.Sim.Compose.D1Split.ND.Values
open Host.Ts Host.Ts.Sim Host.Ts.Sim.Full Host.Ts.Sim.Template Host.Load.Run.Tpl
kernel_rfl pre_next : (mlxOf D1StageSplit.s15.ffi).next = 18155
kernel_rfl pre_nnext : (mlxOf D1StageSplit.s15.ffi).nnext = 15235
kernel_rfl post_next : (mlxOf D1StageSplit.s16.ffi).next = 18156
kernel_rfl post_nnext : (mlxOf D1StageSplit.s16.ffi).nnext = 15236
kernel_rfl shape : Host.Mlx.Ffi.dimsArg (nthD (.big 0) ND.ndArgs 0) (nthD (.big 0) ND.ndArgs 1) =
  some [.lit 1, .sym (.ref 18)]
kernel_rfl dtype : Host.Mlx.Ffi.argNat (nthD (.big 0) ND.ndArgs 2) = some 7
kernel_rfl ref18 : nth? ND.ndSrv.tab 18 = some (.un .int32 (.var 9))
kernel_rfl ndCount : ND.ndArgs.length = 3
kernel_rfl args : ND.ndArgs = [(nthD (.big 0) ND.ndArgs 0), (nthD (.big 0) ND.ndArgs 1), (nthD (.big 0) ND.ndArgs 2)]
end Host.Ts.Sim.Compose.D1Split.ND.Values
