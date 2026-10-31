import host.sim.compose.a4b.GraphColdInputBase
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
set_option Elab.async false
namespace Host.Ts.Sim.Compose.ColdGraph
open _root_.Host.Ts _root_.Host.Ts.Sim _root_.Host.Load _root_.Host.Load.Extract
open _root_.Host.Load.Run.Full _root_.Host.Mlx _root_.Host.Mlx.FfiEval _root_.Host.Mlx.SimGraph
open _root_.Host.Mlx.SimGraph.Iter

kernel_rfl inputs_part0 : InputsOkAt 15235 ((choice.inputs.drop 0).take 64) cacheInputs tokenNode = true
kernel_rfl inputs_part1 : InputsOkAt 15235 ((choice.inputs.drop 64).take 64) cacheInputs tokenNode = true
kernel_rfl inputs_part2 : InputsOkAt 15235 ((choice.inputs.drop 128).take 64) cacheInputs tokenNode = true
kernel_rfl inputs_part3 : InputsOkAt 15235 ((choice.inputs.drop 192).take 64) cacheInputs tokenNode = true
kernel_rfl inputs_part4 : InputsOkAt 15235 ((choice.inputs.drop 256).take 64) cacheInputs tokenNode = true
kernel_rfl inputs_part5 : InputsOkAt 15235 ((choice.inputs.drop 320).take 64) cacheInputs tokenNode = true
kernel_rfl inputs_part6 : InputsOkAt 15235 ((choice.inputs.drop 384).take 64) cacheInputs tokenNode = true
kernel_rfl inputs_part7 : InputsOkAt 15235 ((choice.inputs.drop 448).take 64) cacheInputs tokenNode = true
end Host.Ts.Sim.Compose.ColdGraph
