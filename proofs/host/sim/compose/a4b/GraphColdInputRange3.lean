import host.sim.compose.a4b.GraphColdInputBase
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
set_option Elab.async false
namespace Host.Ts.Sim.Compose.ColdGraph
open _root_.Host.Ts _root_.Host.Ts.Sim _root_.Host.Load _root_.Host.Load.Extract
open _root_.Host.Load.Run.Full _root_.Host.Mlx _root_.Host.Mlx.FfiEval _root_.Host.Mlx.SimGraph
open _root_.Host.Mlx.SimGraph.Iter

kernel_rfl inputs_part24 : InputsOkAt 15235 ((choice.inputs.drop 1536).take 64) cacheInputs tokenNode = true
kernel_rfl inputs_part25 : InputsOkAt 15235 ((choice.inputs.drop 1600).take 64) cacheInputs tokenNode = true
kernel_rfl inputs_part26 : InputsOkAt 15235 ((choice.inputs.drop 1664).take 64) cacheInputs tokenNode = true
kernel_rfl inputs_part27 : InputsOkAt 15235 ((choice.inputs.drop 1728).take 64) cacheInputs tokenNode = true
kernel_rfl inputs_part28 : InputsOkAt 15235 ((choice.inputs.drop 1792).take 64) cacheInputs tokenNode = true
kernel_rfl inputs_tail29 : InputsOkAt 15235 (choice.inputs.drop 1856) cacheInputs tokenNode = true
end Host.Ts.Sim.Compose.ColdGraph
