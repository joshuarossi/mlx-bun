import host.sim.compose.a4b.GraphColdInputBase
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
set_option Elab.async false
namespace Host.Ts.Sim.Compose.ColdGraph
open _root_.Host.Ts _root_.Host.Ts.Sim _root_.Host.Load _root_.Host.Load.Extract
open _root_.Host.Load.Run.Full _root_.Host.Mlx _root_.Host.Mlx.FfiEval _root_.Host.Mlx.SimGraph
open _root_.Host.Mlx.SimGraph.Iter

kernel_rfl token_input : insT .tokenIds = some tokenNode
kernel_rfl token_shape_only : (endLoad.ffi.mlx.nodes.get tokenNode).map G.shapeOnly = some true
kernel_rfl token_excluded : exactTplDom NL N0 fixedBigs endLoad.ffi.mlx tokenNode = false
kernel_rfl end_control : endLoad.ctl = .call (.obj 2671709) .undef [.obj 2827805, .obj 2672295, .null]
theorem start_native_proj : startLoad.ffi.mlx = Host.Ts.Sim.Full.mlxOf Host.Load.Run.Tpl.D1Body.s0.ffi := rfl
theorem end_native_proj : endLoad.ffi.mlx = Host.Ts.Sim.Full.mlxOf Host.Load.Run.Tpl.D1Post.s4.ffi := rfl
kernel_rfl start_native_count : startLoad.ffi.mlx.nnext = 15236
kernel_rfl end_native_count : endLoad.ffi.mlx.nnext = 17778
end Host.Ts.Sim.Compose.ColdGraph
