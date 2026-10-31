import host.sim.compose.a4b.GraphColdInputBase
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
set_option Elab.async false
namespace Host.Ts.Sim.Compose.ColdGraph
open _root_.Host.Ts _root_.Host.Ts.Sim _root_.Host.Load _root_.Host.Load.Extract
open _root_.Host.Load.Run.Full _root_.Host.Mlx _root_.Host.Mlx.FfiEval _root_.Host.Mlx.SimGraph
open _root_.Host.Mlx.SimGraph.Iter

kernel_rfl inputs_part16 : InputsOkAt 15235 ((choice.inputs.drop 1024).take 64) cacheInputs tokenNode = true
kernel_rfl inputs_part17 : InputsOkAt 15235 ((choice.inputs.drop 1088).take 64) cacheInputs tokenNode = true
kernel_rfl inputs_part18 : InputsOkAt 15235 ((choice.inputs.drop 1152).take 64) cacheInputs tokenNode = true
kernel_rfl inputs_part19 : InputsOkAt 15235 ((choice.inputs.drop 1216).take 64) cacheInputs tokenNode = true
kernel_rfl inputs_part20 : InputsOkAt 15235 ((choice.inputs.drop 1280).take 64) cacheInputs tokenNode = true
kernel_rfl inputs_part21 : InputsOkAt 15235 ((choice.inputs.drop 1344).take 64) cacheInputs tokenNode = true
kernel_rfl inputs_part22 : InputsOkAt 15235 ((choice.inputs.drop 1408).take 64) cacheInputs tokenNode = true
kernel_rfl inputs_part23 : InputsOkAt 15235 ((choice.inputs.drop 1472).take 64) cacheInputs tokenNode = true
end Host.Ts.Sim.Compose.ColdGraph
