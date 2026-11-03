import host.sim.compose.a4b.PL4L8Na
import host.sim.template.a4pre_fd_x4_L8_r0_body.m.B00
import host.load.boot.World
set_option Elab.async false
namespace Host.Load.Run.Tpl
open Host.Ts Host.Ts.Sim Host.Ts.Sim.Template Host.Ts.Sim.Full Host.Ts.Sim.Compose Host.Route
set_option maxRecDepth 1000000
set_option maxHeartbeats 0

kernel_rfl PL4L8.getP : PRE_plx4_L8_entry.s0.heap.get 2665 = some (.obj (Template.objOf PRE_plx4_L8_entry.s0 2665))
kernel_rfl PL4L8.kindP : (Template.objOf PRE_plx4_L8_entry.s0 2665).kind = .array []
kernel_rfl PL4L8.imgP : PRE_fd_x4_L8_r0_body.s451.heap.get 2665 = some (.obj { PLW4L8.R.data.map.obj (Template.objOf PRE_plx4_L8_entry.s0 2665) with kind := .array ([] ++ arrOf PRE_fd_x4_L8_r0_body.s451 2665) })
kernel_rfl PL4L8.emptyP : arrOf PRE_fd_x4_L8_r0_body.s451 2665 = []
kernel_rfl PL4L8.keptFix0 : PLW4L8.R.data.a 2834427 = 2834427
kernel_rfl PL4L8.keptNone0 : wideGPf 2834427 = none
kernel_rfl PL4L8.keptGet0 : PRE_plx4_L8_entry.s0.heap.get 2834427 = some (.obj (Template.objOf PRE_plx4_L8_entry.s0 2834427))
kernel_rfl PL4L8.keptKind0 : (Template.objOf PRE_plx4_L8_entry.s0 2834427).kind = .array []
kernel_rfl PL4L8.keptImg0 : PRE_fd_x4_L8_r0_body.s451.heap.get 2834427 = some (.obj { PLW4L8.R.data.map.obj (Template.objOf PRE_plx4_L8_entry.s0 2834427) with kind := .array ([] ++ arrOf PRE_fd_x4_L8_r0_body.s451 2834427) })
kernel_rfl PL4L8.keptEmpty0 : arrOf PRE_fd_x4_L8_r0_body.s451 2834427 = []
noncomputable def PL4L8.ndAt (a : Nat) : Bool := [2834432, 2834433].all fun b => !Nat.beq (PLW4L8.R.data.a a) b
tpl_all_blocks PL4L8.ND from PL4L8EV : PL4L8.ndAt
kernel_rfl PL4L8.ndFramed : PL4L8EV.frames.all PL4L8.ndAt = true
kernel_rfl PL4L8.memoFix : PLW4L8.R.data.a 4910 = 4910
kernel_rfl PL4L8.memoGet0 : PRE_plx4_L8_entry.s0.heap.get 4910 = some (.obj (Template.objOf PRE_plx4_L8_entry.s0 4910))
kernel_rfl PL4L8.memoGet1 : PRE_fd_x4_L8_r0_body.s451.heap.get 4910 = some (.obj (Template.objOf PRE_fd_x4_L8_r0_body.s451 4910))
noncomputable def PL4L8.memoEs : List (Val × Val) := match (Template.objOf PRE_fd_x4_L8_r0_body.s451 4910).kind with | .map es => es | _ => []
kernel_rfl PL4L8.memoKind : (Template.objOf PRE_fd_x4_L8_r0_body.s451 4910).kind = .map PL4L8.memoEs
kernel_rfl PL4L8.memoImg : PLW4L8.R.data.map.obj (Template.objOf PRE_plx4_L8_entry.s0 4910) = { Template.objOf PRE_fd_x4_L8_r0_body.s451 4910 with kind := .map (StringIndex.dropCodes [causalKey] PL4L8.memoEs) }
kernel_rfl PL4L8.ghostFix1824 : PLW4L8.R.data.a 1824 = 1824
kernel_rfl PL4L8.ghostChk1824 : Pf.ghostChkB (PRE_plx4_L8_entry.s0.heap.get 1824) (PRE_fd_x4_L8_r0_body.s451.heap.get 1824) = true
kernel_rfl PL4L8.ghostFix1834 : PLW4L8.R.data.a 1834 = 1834
kernel_rfl PL4L8.ghostChk1834 : Pf.ghostChkB (PRE_plx4_L8_entry.s0.heap.get 1834) (PRE_fd_x4_L8_r0_body.s451.heap.get 1834) = true
kernel_rfl PL4L8.ghostFix1852 : PLW4L8.R.data.a 1852 = 1852
kernel_rfl PL4L8.ghostChk1852 : Pf.ghostChkB (PRE_plx4_L8_entry.s0.heap.get 1852) (PRE_fd_x4_L8_r0_body.s451.heap.get 1852) = true
kernel_rfl PL4L8.ghostFix1993 : PLW4L8.R.data.a 1993 = 1993
kernel_rfl PL4L8.ghostChk1993 : Pf.ghostChkB (PRE_plx4_L8_entry.s0.heap.get 1993) (PRE_fd_x4_L8_r0_body.s451.heap.get 1993) = true
kernel_rfl PL4L8.ghostFix2001 : PLW4L8.R.data.a 2001 = 2001
kernel_rfl PL4L8.ghostChk2001 : Pf.ghostChkB (PRE_plx4_L8_entry.s0.heap.get 2001) (PRE_fd_x4_L8_r0_body.s451.heap.get 2001) = true

end Host.Load.Run.Tpl
