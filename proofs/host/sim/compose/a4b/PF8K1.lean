import host.sim.compose.a4b.PF8Na
import host.sim.template.a4pre_first_tail_x8_r0_suffix.m.B3
import host.load.boot.World
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
tpl_all_blocks PF8.ND from PF15EV : PF8.ndAt
kernel_rfl PF8.ndFramed : PF15EV.frames.all PF8.ndAt = true
kernel_rfl PF8.memoFix : PFW8.R.data.a 4910 = 4910
kernel_rfl PF8.memoGet0 : PRE_pf_vw.s0.heap.get 4910 = some (.obj (Template.objOf PRE_pf_vw.s0 4910))
kernel_rfl PF8.memoGet1 : PRE_first_tail_x8_r0_suffix.s8.heap.get 4910 = some (.obj (Template.objOf PRE_first_tail_x8_r0_suffix.s8 4910))
noncomputable def PF8.memoEs : List (Val × Val) := match (Template.objOf PRE_first_tail_x8_r0_suffix.s8 4910).kind with | .map es => es | _ => []
kernel_rfl PF8.memoKind : (Template.objOf PRE_first_tail_x8_r0_suffix.s8 4910).kind = .map PF8.memoEs
kernel_rfl PF8.memoImg : PFW8.R.data.map.obj (Template.objOf PRE_pf_vw.s0 4910) = { Template.objOf PRE_first_tail_x8_r0_suffix.s8 4910 with kind := .map (StringIndex.dropCodes [causalKey] PF8.memoEs) }
kernel_rfl PF8.ghostFix1824 : PFW8.R.data.a 1824 = 1824
kernel_rfl PF8.ghostChk1824 : Pf.ghostChkB (PRE_pf_vw.s0.heap.get 1824) (PRE_first_tail_x8_r0_suffix.s8.heap.get 1824) = true
kernel_rfl PF8.ghostFix1834 : PFW8.R.data.a 1834 = 1834
kernel_rfl PF8.ghostChk1834 : Pf.ghostChkB (PRE_pf_vw.s0.heap.get 1834) (PRE_first_tail_x8_r0_suffix.s8.heap.get 1834) = true
kernel_rfl PF8.ghostFix1852 : PFW8.R.data.a 1852 = 1852
kernel_rfl PF8.ghostChk1852 : Pf.ghostChkB (PRE_pf_vw.s0.heap.get 1852) (PRE_first_tail_x8_r0_suffix.s8.heap.get 1852) = true
kernel_rfl PF8.ghostFix1993 : PFW8.R.data.a 1993 = 1993
kernel_rfl PF8.ghostChk1993 : Pf.ghostChkB (PRE_pf_vw.s0.heap.get 1993) (PRE_first_tail_x8_r0_suffix.s8.heap.get 1993) = true
kernel_rfl PF8.ghostFix2001 : PFW8.R.data.a 2001 = 2001
kernel_rfl PF8.ghostChk2001 : Pf.ghostChkB (PRE_pf_vw.s0.heap.get 2001) (PRE_first_tail_x8_r0_suffix.s8.heap.get 2001) = true

end Host.Load.Run.Tpl
