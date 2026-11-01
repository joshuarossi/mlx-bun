import host.load.boot.World
import host.sim.compose.a4b.PLTVNa
import host.sim.template.a4pre_plvw_common.H0
set_option Elab.async false
namespace Host.Load.Run.Tpl
open Host.Ts Host.Ts.Sim Host.Ts.Sim.Template Host.Ts.Sim.Full Host.Ts.Sim.Compose Host.Route
set_option maxRecDepth 1000000
set_option maxHeartbeats 0

kernel_rfl PLTV.getP : PRE_pl_tail.s0.heap.get 2665 = some (.obj (Template.objOf PRE_pl_tail.s0 2665))
kernel_rfl PLTV.kindP : (Template.objOf PRE_pl_tail.s0 2665).kind = .array []
kernel_rfl PLTV.imgP : PRE_plvw_common.s4.heap.get 2665 = some (.obj { PLTailVW.R.data.map.obj (Template.objOf PRE_pl_tail.s0 2665) with kind := .array ([] ++ arrOf PRE_plvw_common.s4 2665) })
kernel_rfl PLTV.emptyP : arrOf PRE_plvw_common.s4 2665 = []
noncomputable def PLTV.ndAt (a : Nat) : Bool := [ ].all fun b => !Nat.beq (PLTailVW.R.data.a a) b
tpl_all_blocks PLTV.ND from PLTEV : PLTV.ndAt
kernel_rfl PLTV.ndFramed : PRE_pl_tail.frames.all PLTV.ndAt = true

end Host.Load.Run.Tpl
