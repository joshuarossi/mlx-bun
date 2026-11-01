import host.sim.compose.a4b.PLD1Full
import host.sim.compose.a4b.PLEntryFresh
import host.sim.template.a4pre_d1_body.D4
set_option Elab.async false
namespace Host.Load.Run.Tpl
open Host.Ts Host.Ts.Sim Host.Ts.Sim.Template Host.Ts.Sim.Full Host.Ts.Sim.Compose Host.Route
set_option maxRecDepth 1000000
set_option maxHeartbeats 0

kernel_rfl PLD1.getP : PRE_pl_entry.s0.heap.get 2665 = some (.obj (Template.objOf PRE_pl_entry.s0 2665))
kernel_rfl PLD1.kindP : (Template.objOf PRE_pl_entry.s0 2665).kind = .array []
kernel_rfl PLD1.imgP : D1Body.s155.heap.get 2665 = some (.obj { PLWalkD1.R.data.map.obj (Template.objOf PRE_pl_entry.s0 2665) with kind := .array ([] ++ arrOf D1Body.s155 2665) })
kernel_rfl PLD1.getC : PRE_pl_entry.s0.heap.get D1Frames.chunk = some (.obj (Template.objOf PRE_pl_entry.s0 D1Frames.chunk))
kernel_rfl PLD1.kindC : (Template.objOf PRE_pl_entry.s0 D1Frames.chunk).kind = .array []
kernel_rfl PLD1.imgC : D1Body.s155.heap.get D1Frames.chunk = some (.obj { PLWalkD1.R.data.map.obj (Template.objOf PRE_pl_entry.s0 D1Frames.chunk) with kind := .array ([] ++ arrOf D1Body.s155 D1Frames.chunk) })
kernel_rfl PLD1.getB : (PRE_pl_entry.s0.heap.get D1Frames.buffer).isSome = true
kernel_rfl PLD1.imgB : D1Body.s155.heap.get D1Frames.buffer = (PRE_pl_entry.s0.heap.get D1Frames.buffer).map PLWalkD1.R.data.map.hobj
kernel_rfl PLD1.getV : (PRE_pl_entry.s0.heap.get D1Frames.view).isSome = true
kernel_rfl PLD1.imgV : D1Body.s155.heap.get D1Frames.view = (PRE_pl_entry.s0.heap.get D1Frames.view).map PLWalkD1.R.data.map.hobj
kernel_rfl PLD1.framesEmpty : [2665, D1Frames.chunk, D1Frames.buffer, D1Frames.view].all (fun a => (arrOf D1Body.s155 a).isEmpty) = true

end Host.Load.Run.Tpl
