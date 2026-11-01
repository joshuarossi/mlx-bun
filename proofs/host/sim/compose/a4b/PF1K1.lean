import host.sim.compose.a4b.PF1Na
import host.sim.template.a4pre_first_tail_x1_r0_suffix.m.B0
import host.load.boot.World
set_option Elab.async false
namespace Host.Load.Run.Tpl
open Host.Ts Host.Ts.Sim Host.Ts.Sim.Template Host.Ts.Sim.Full Host.Ts.Sim.Compose Host.Route
set_option maxRecDepth 1000000
set_option maxHeartbeats 0

kernel_rfl PF1.getP : PRE_pf_vw.s0.heap.get 2665 = some (.obj (Template.objOf PRE_pf_vw.s0 2665))
kernel_rfl PF1.kindP : (Template.objOf PRE_pf_vw.s0 2665).kind = .array []
kernel_rfl PF1.imgP : PRE_first_tail_x1_r0_suffix.s8.heap.get 2665 = some (.obj { PFW1.R.data.map.obj (Template.objOf PRE_pf_vw.s0 2665) with kind := .array ([] ++ arrOf PRE_first_tail_x1_r0_suffix.s8 2665) })
kernel_rfl PF1.emptyP : arrOf PRE_first_tail_x1_r0_suffix.s8 2665 = []
noncomputable def PF1.ndAt (a : Nat) : Bool := [2673467, 2673472, 2673473].all fun b => !Nat.beq (PFW1.R.data.a a) b
tpl_all_blocks PF1.ND from PF15EV : PF1.ndAt
kernel_rfl PF1.ndFramed : PRE_pf_vw.frames.all PF1.ndAt = true

end Host.Load.Run.Tpl
