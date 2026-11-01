import host.sim.compose.a4b.PLTNa
import host.sim.template.a4pre_pl_common.H0
set_option Elab.async false
namespace Host.Load.Run.Tpl
open Host.Ts Host.Ts.Sim Host.Ts.Sim.Template Host.Ts.Sim.Full Host.Ts.Sim.Compose Host.Route
set_option maxRecDepth 1000000
set_option maxHeartbeats 0

kernel_rfl PLT.getP : PRE_pl_tail.s0.heap.get 2665 = some (.obj (Template.objOf PRE_pl_tail.s0 2665))
kernel_rfl PLT.kindP : (Template.objOf PRE_pl_tail.s0 2665).kind = .array []
kernel_rfl PLT.imgP : PRE_pl_common.s4.heap.get 2665 = some (.obj { PLTail.R.data.map.obj (Template.objOf PRE_pl_tail.s0 2665) with kind := .array ([] ++ arrOf PRE_pl_common.s4 2665) })
kernel_rfl PLT.emptyP : arrOf PRE_pl_common.s4 2665 = []
noncomputable def PLT.ndAt (a : Nat) : Bool := [ ].all fun b => !Nat.beq (PLTail.R.data.a a) b
tpl_all_blocks PLT.ND from PLTEV : PLT.ndAt
kernel_rfl PLT.ndFramed : PRE_pl_tail.frames.all PLT.ndAt = true

end Host.Load.Run.Tpl
