import host.sim.compose.a4b.GraphColdInputBase
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
set_option Elab.async false
namespace Host.Ts.Sim.Compose.ColdGraph
open _root_.Host.Ts _root_.Host.Ts.Sim _root_.Host.Load _root_.Host.Load.Extract
open _root_.Host.Load.Run.Full _root_.Host.Mlx _root_.Host.Mlx.FfiEval _root_.Host.Mlx.SimGraph
open _root_.Host.Mlx.SimGraph.Iter

/- The source disposes the hidden tensor after logits; its graph node remains. -/
kernel_rfl actual_hidden_preserved : endLoad.ffi.mlx.nodes.get 17763 =
  (Host.Ts.Sim.Full.mlxOf Host.Load.Run.Tpl.D1Body.s155.ffi).nodes.get 17763
end Host.Ts.Sim.Compose.ColdGraph
