import host.sim.compose.a4b.PL0Na
import host.sim.template.a4pre_fd_x0_r0_body.m.B00
import host.load.boot.World
set_option Elab.async false
namespace Host.Load.Run.Tpl
open Host.Ts Host.Ts.Sim Host.Ts.Sim.Template Host.Ts.Sim.Full Host.Ts.Sim.Compose Host.Route
set_option maxRecDepth 1000000
set_option maxHeartbeats 0

kernel_rfl PL0.getP : PRE_plx0_entry.s0.heap.get 2665 = some (.obj (Template.objOf PRE_plx0_entry.s0 2665))
kernel_rfl PL0.kindP : (Template.objOf PRE_plx0_entry.s0 2665).kind = .array []
kernel_rfl PL0.imgP : PRE_fd_x0_r0_body.s447.heap.get 2665 = some (.obj { PLW0.R.data.map.obj (Template.objOf PRE_plx0_entry.s0 2665) with kind := .array ([] ++ arrOf PRE_fd_x0_r0_body.s447 2665) })
kernel_rfl PL0.emptyP : arrOf PRE_fd_x0_r0_body.s447 2665 = []
kernel_rfl PL0.keptFix0 : PLW0.R.data.a 2826777 = 2826777
kernel_rfl PL0.keptNone0 : wideGPf 2826777 = none
kernel_rfl PL0.keptGet0 : PRE_plx0_entry.s0.heap.get 2826777 = some (.obj (Template.objOf PRE_plx0_entry.s0 2826777))
kernel_rfl PL0.keptKind0 : (Template.objOf PRE_plx0_entry.s0 2826777).kind = .array []
kernel_rfl PL0.keptImg0 : PRE_fd_x0_r0_body.s447.heap.get 2826777 = some (.obj { PLW0.R.data.map.obj (Template.objOf PRE_plx0_entry.s0 2826777) with kind := .array ([] ++ arrOf PRE_fd_x0_r0_body.s447 2826777) })
kernel_rfl PL0.keptEmpty0 : arrOf PRE_fd_x0_r0_body.s447 2826777 = []
noncomputable def PL0.ndAt (a : Nat) : Bool := [2826782, 2826783].all fun b => !Nat.beq (PLW0.R.data.a a) b
tpl_all_blocks PL0.ND from PL0EV : PL0.ndAt
kernel_rfl PL0.ndFramed : PL0EV.frames.all PL0.ndAt = true
kernel_rfl PL0.memoFix : PLW0.R.data.a 4910 = 4910
kernel_rfl PL0.memoGet0 : PRE_plx0_entry.s0.heap.get 4910 = some (.obj (Template.objOf PRE_plx0_entry.s0 4910))
kernel_rfl PL0.memoGet1 : PRE_fd_x0_r0_body.s447.heap.get 4910 = some (.obj (Template.objOf PRE_fd_x0_r0_body.s447 4910))
noncomputable def PL0.memoEs : List (Val × Val) := match (Template.objOf PRE_fd_x0_r0_body.s447 4910).kind with | .map es => es | _ => []
kernel_rfl PL0.memoKind : (Template.objOf PRE_fd_x0_r0_body.s447 4910).kind = .map PL0.memoEs
kernel_rfl PL0.memoImg : PLW0.R.data.map.obj (Template.objOf PRE_plx0_entry.s0 4910) = { Template.objOf PRE_fd_x0_r0_body.s447 4910 with kind := .map (StringIndex.dropCodes [causalKey] PL0.memoEs) }
kernel_rfl PL0.ghostFix1824 : PLW0.R.data.a 1824 = 1824
kernel_rfl PL0.ghostChk1824 : Pf.ghostChkB (PRE_plx0_entry.s0.heap.get 1824) (PRE_fd_x0_r0_body.s447.heap.get 1824) = true
kernel_rfl PL0.ghostFix1834 : PLW0.R.data.a 1834 = 1834
kernel_rfl PL0.ghostChk1834 : Pf.ghostChkB (PRE_plx0_entry.s0.heap.get 1834) (PRE_fd_x0_r0_body.s447.heap.get 1834) = true
kernel_rfl PL0.ghostFix1852 : PLW0.R.data.a 1852 = 1852
kernel_rfl PL0.ghostChk1852 : Pf.ghostChkB (PRE_plx0_entry.s0.heap.get 1852) (PRE_fd_x0_r0_body.s447.heap.get 1852) = true
kernel_rfl PL0.ghostFix1993 : PLW0.R.data.a 1993 = 1993
kernel_rfl PL0.ghostChk1993 : Pf.ghostChkB (PRE_plx0_entry.s0.heap.get 1993) (PRE_fd_x0_r0_body.s447.heap.get 1993) = true
kernel_rfl PL0.ghostFix2001 : PLW0.R.data.a 2001 = 2001
kernel_rfl PL0.ghostChk2001 : Pf.ghostChkB (PRE_plx0_entry.s0.heap.get 2001) (PRE_fd_x0_r0_body.s447.heap.get 2001) = true

end Host.Load.Run.Tpl
