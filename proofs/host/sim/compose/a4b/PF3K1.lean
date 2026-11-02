import host.sim.compose.a4b.PF3Na
import host.sim.template.a4pre_first_tail_x3_r0_suffix.m.B0
import host.load.boot.World
set_option Elab.async false
namespace Host.Load.Run.Tpl
open Host.Ts Host.Ts.Sim Host.Ts.Sim.Template Host.Ts.Sim.Full Host.Ts.Sim.Compose Host.Route
set_option maxRecDepth 1000000
set_option maxHeartbeats 0

kernel_rfl PF3.getP : PRE_pf_vw.s0.heap.get 2665 = some (.obj (Template.objOf PRE_pf_vw.s0 2665))
kernel_rfl PF3.kindP : (Template.objOf PRE_pf_vw.s0 2665).kind = .array []
kernel_rfl PF3.imgP : PRE_first_tail_x3_r0_suffix.s8.heap.get 2665 = some (.obj { PFW3.R.data.map.obj (Template.objOf PRE_pf_vw.s0 2665) with kind := .array ([] ++ arrOf PRE_first_tail_x3_r0_suffix.s8 2665) })
kernel_rfl PF3.emptyP : arrOf PRE_first_tail_x3_r0_suffix.s8 2665 = []
noncomputable def PF3.ndAt (a : Nat) : Bool := [2673467, 2673472, 2673473].all fun b => !Nat.beq (PFW3.R.data.a a) b
tpl_all_blocks PF3.ND from PF15EV : PF3.ndAt
kernel_rfl PF3.ndFramed : PF15EV.frames.all PF3.ndAt = true
kernel_rfl PF3.memoFix : PFW3.R.data.a 4910 = 4910
kernel_rfl PF3.memoGet0 : PRE_pf_vw.s0.heap.get 4910 = some (.obj (Template.objOf PRE_pf_vw.s0 4910))
kernel_rfl PF3.memoGet1 : PRE_first_tail_x3_r0_suffix.s8.heap.get 4910 = some (.obj (Template.objOf PRE_first_tail_x3_r0_suffix.s8 4910))
noncomputable def PF3.memoEs : List (Val × Val) := match (Template.objOf PRE_first_tail_x3_r0_suffix.s8 4910).kind with | .map es => es | _ => []
kernel_rfl PF3.memoKind : (Template.objOf PRE_first_tail_x3_r0_suffix.s8 4910).kind = .map PF3.memoEs
kernel_rfl PF3.memoImg : PFW3.R.data.map.obj (Template.objOf PRE_pf_vw.s0 4910) = { Template.objOf PRE_first_tail_x3_r0_suffix.s8 4910 with kind := .map (StringIndex.dropCodes [causalKey] PF3.memoEs) }
kernel_rfl PF3.ghostFix1824 : PFW3.R.data.a 1824 = 1824
kernel_rfl PF3.ghostChk1824 : Pf.ghostChkB (PRE_pf_vw.s0.heap.get 1824) (PRE_first_tail_x3_r0_suffix.s8.heap.get 1824) = true
kernel_rfl PF3.ghostFix1834 : PFW3.R.data.a 1834 = 1834
kernel_rfl PF3.ghostChk1834 : Pf.ghostChkB (PRE_pf_vw.s0.heap.get 1834) (PRE_first_tail_x3_r0_suffix.s8.heap.get 1834) = true
kernel_rfl PF3.ghostFix1852 : PFW3.R.data.a 1852 = 1852
kernel_rfl PF3.ghostChk1852 : Pf.ghostChkB (PRE_pf_vw.s0.heap.get 1852) (PRE_first_tail_x3_r0_suffix.s8.heap.get 1852) = true
kernel_rfl PF3.ghostFix1993 : PFW3.R.data.a 1993 = 1993
kernel_rfl PF3.ghostChk1993 : Pf.ghostChkB (PRE_pf_vw.s0.heap.get 1993) (PRE_first_tail_x3_r0_suffix.s8.heap.get 1993) = true
kernel_rfl PF3.ghostFix2001 : PFW3.R.data.a 2001 = 2001
kernel_rfl PF3.ghostChk2001 : Pf.ghostChkB (PRE_pf_vw.s0.heap.get 2001) (PRE_first_tail_x3_r0_suffix.s8.heap.get 2001) = true

end Host.Load.Run.Tpl
