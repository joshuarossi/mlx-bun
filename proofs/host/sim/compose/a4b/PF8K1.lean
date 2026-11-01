import host.sim.compose.a4b.PF8Na
import host.sim.template.a4pre_first_tail_x8_r0_suffix.m.B0
set_option Elab.async false
namespace Host.Load.Run.Tpl
open Host.Ts Host.Ts.Sim Host.Ts.Sim.Template Host.Ts.Sim.Full Host.Ts.Sim.Compose Host.Route
set_option maxRecDepth 1000000
set_option maxHeartbeats 0

kernel_rfl PF8.getP : PRE_pf_vw.s0.heap.get 2665 = some (.obj (Template.objOf PRE_pf_vw.s0 2665))
kernel_rfl PF8.kindP : (Template.objOf PRE_pf_vw.s0 2665).kind = .array []
kernel_rfl PF8.imgP : PRE_first_tail_x8_r0_suffix.s8.heap.get 2665 = some (.obj { PFW8.R.data.map.obj (Template.objOf PRE_pf_vw.s0 2665) with kind := .array ([] ++ arrOf PRE_first_tail_x8_r0_suffix.s8 2665) })
kernel_rfl PF8.emptyP : arrOf PRE_first_tail_x8_r0_suffix.s8 2665 = []
noncomputable def PF8.ndAt (a : Nat) : Bool := [2673467, 2673472, 2673473].all fun b => !Nat.beq (PFW8.R.data.a a) b
tpl_all_blocks PF8.ND from PFVEV : PF8.ndAt
kernel_rfl PF8.ndFramed : PRE_pf_vw.frames.all PF8.ndAt = true

end Host.Load.Run.Tpl
