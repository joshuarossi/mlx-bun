import host.sim.compose.a4b.GraphColdInputBase
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
set_option Elab.async false
namespace Host.Ts.Sim.Compose.ColdGraph
open _root_.Host.Ts _root_.Host.Ts.Sim _root_.Host.Load _root_.Host.Load.Extract
open _root_.Host.Load.Run.Full _root_.Host.Mlx _root_.Host.Mlx.FfiEval _root_.Host.Mlx.SimGraph
open _root_.Host.Mlx.SimGraph.Iter

kernel_rfl inputs_part8 : InputsOkAt 15235 ((choice.inputs.drop 512).take 64) cacheInputs tokenNode = true
kernel_rfl inputs_part9 : InputsOkAt 15235 ((choice.inputs.drop 576).take 64) cacheInputs tokenNode = true
kernel_rfl inputs_part10 : InputsOkAt 15235 ((choice.inputs.drop 640).take 64) cacheInputs tokenNode = true
kernel_rfl inputs_part11 : InputsOkAt 15235 ((choice.inputs.drop 704).take 64) cacheInputs tokenNode = true
kernel_rfl inputs_part12 : InputsOkAt 15235 ((choice.inputs.drop 768).take 64) cacheInputs tokenNode = true
kernel_rfl inputs_part13 : InputsOkAt 15235 ((choice.inputs.drop 832).take 64) cacheInputs tokenNode = true
kernel_rfl inputs_part14 : InputsOkAt 15235 ((choice.inputs.drop 896).take 64) cacheInputs tokenNode = true
kernel_rfl inputs_part15 : InputsOkAt 15235 ((choice.inputs.drop 960).take 64) cacheInputs tokenNode = true
end Host.Ts.Sim.Compose.ColdGraph
