import host.sim.compose.a4b.PLD1Na
import host.sim.template.a4pre_d1_body.D4
set_option Elab.async false
namespace Host.Load.Run.Tpl
open Host.Ts Host.Ts.Sim Host.Ts.Sim.Template Host.Ts.Sim.Full Host.Ts.Sim.Compose Host.Route
set_option maxRecDepth 1000000
set_option maxHeartbeats 0

kernel_rfl PLD1.getP : PRE_pl_entry.s0.heap.get 2665 = some (.obj (Template.objOf PRE_pl_entry.s0 2665))
kernel_rfl PLD1.kindP : (Template.objOf PRE_pl_entry.s0 2665).kind = .array []
kernel_rfl PLD1.imgP : D1Body.s155.heap.get 2665 = some (.obj { PLWalkD1.R.data.map.obj (Template.objOf PRE_pl_entry.s0 2665) with kind := .array ([] ++ arrOf D1Body.s155 2665) })
kernel_rfl PLD1.emptyP : arrOf D1Body.s155 2665 = []
noncomputable def PLD1.ndAt (a : Nat) : Bool := [D1Frames.chunk, D1Frames.buffer, D1Frames.view].all fun b => !Nat.beq (PLWalkD1.R.data.a a) b
tpl_all_blocks PLD1.ND from PLEntryV : PLD1.ndAt
kernel_rfl PLD1.ndFramed : PRE_pl_entry.frames.all PLD1.ndAt = true

end Host.Load.Run.Tpl
