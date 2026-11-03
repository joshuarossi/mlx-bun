import host.sim.compose.a4b.PL4L9Na
import host.sim.template.a4pre_fd_x4_L9_r0_body.m.B00
import host.load.boot.World
set_option Elab.async false
namespace Host.Load.Run.Tpl
open Host.Ts Host.Ts.Sim Host.Ts.Sim.Template Host.Ts.Sim.Full Host.Ts.Sim.Compose Host.Route
set_option maxRecDepth 1000000
set_option maxHeartbeats 0

kernel_rfl PL4L9.getP : PRE_plx4_L9_entry.s0.heap.get 2665 = some (.obj (Template.objOf PRE_plx4_L9_entry.s0 2665))
kernel_rfl PL4L9.kindP : (Template.objOf PRE_plx4_L9_entry.s0 2665).kind = .array []
kernel_rfl PL4L9.imgP : PRE_fd_x4_L9_r0_body.s451.heap.get 2665 = some (.obj { PLW4L9.R.data.map.obj (Template.objOf PRE_plx4_L9_entry.s0 2665) with kind := .array ([] ++ arrOf PRE_fd_x4_L9_r0_body.s451 2665) })
kernel_rfl PL4L9.emptyP : arrOf PRE_fd_x4_L9_r0_body.s451 2665 = []
kernel_rfl PL4L9.keptFix0 : PLW4L9.R.data.a 2834731 = 2834731
kernel_rfl PL4L9.keptNone0 : wideGPf 2834731 = none
kernel_rfl PL4L9.keptGet0 : PRE_plx4_L9_entry.s0.heap.get 2834731 = some (.obj (Template.objOf PRE_plx4_L9_entry.s0 2834731))
kernel_rfl PL4L9.keptKind0 : (Template.objOf PRE_plx4_L9_entry.s0 2834731).kind = .array []
kernel_rfl PL4L9.keptImg0 : PRE_fd_x4_L9_r0_body.s451.heap.get 2834731 = some (.obj { PLW4L9.R.data.map.obj (Template.objOf PRE_plx4_L9_entry.s0 2834731) with kind := .array ([] ++ arrOf PRE_fd_x4_L9_r0_body.s451 2834731) })
kernel_rfl PL4L9.keptEmpty0 : arrOf PRE_fd_x4_L9_r0_body.s451 2834731 = []
noncomputable def PL4L9.ndAt (a : Nat) : Bool := [2834736, 2834737].all fun b => !Nat.beq (PLW4L9.R.data.a a) b
tpl_all_blocks PL4L9.ND from PL4L9EV : PL4L9.ndAt
kernel_rfl PL4L9.ndFramed : PL4L9EV.frames.all PL4L9.ndAt = true
kernel_rfl PL4L9.memoFix : PLW4L9.R.data.a 4910 = 4910
kernel_rfl PL4L9.memoGet0 : PRE_plx4_L9_entry.s0.heap.get 4910 = some (.obj (Template.objOf PRE_plx4_L9_entry.s0 4910))
kernel_rfl PL4L9.memoGet1 : PRE_fd_x4_L9_r0_body.s451.heap.get 4910 = some (.obj (Template.objOf PRE_fd_x4_L9_r0_body.s451 4910))
noncomputable def PL4L9.memoEs : List (Val × Val) := match (Template.objOf PRE_fd_x4_L9_r0_body.s451 4910).kind with | .map es => es | _ => []
kernel_rfl PL4L9.memoKind : (Template.objOf PRE_fd_x4_L9_r0_body.s451 4910).kind = .map PL4L9.memoEs
kernel_rfl PL4L9.memoImg : PLW4L9.R.data.map.obj (Template.objOf PRE_plx4_L9_entry.s0 4910) = { Template.objOf PRE_fd_x4_L9_r0_body.s451 4910 with kind := .map (StringIndex.dropCodes [causalKey] PL4L9.memoEs) }
kernel_rfl PL4L9.ghostFix1824 : PLW4L9.R.data.a 1824 = 1824
kernel_rfl PL4L9.ghostChk1824 : Pf.ghostChkB (PRE_plx4_L9_entry.s0.heap.get 1824) (PRE_fd_x4_L9_r0_body.s451.heap.get 1824) = true
kernel_rfl PL4L9.ghostFix1834 : PLW4L9.R.data.a 1834 = 1834
kernel_rfl PL4L9.ghostChk1834 : Pf.ghostChkB (PRE_plx4_L9_entry.s0.heap.get 1834) (PRE_fd_x4_L9_r0_body.s451.heap.get 1834) = true
kernel_rfl PL4L9.ghostFix1852 : PLW4L9.R.data.a 1852 = 1852
kernel_rfl PL4L9.ghostChk1852 : Pf.ghostChkB (PRE_plx4_L9_entry.s0.heap.get 1852) (PRE_fd_x4_L9_r0_body.s451.heap.get 1852) = true
kernel_rfl PL4L9.ghostFix1993 : PLW4L9.R.data.a 1993 = 1993
kernel_rfl PL4L9.ghostChk1993 : Pf.ghostChkB (PRE_plx4_L9_entry.s0.heap.get 1993) (PRE_fd_x4_L9_r0_body.s451.heap.get 1993) = true
kernel_rfl PL4L9.ghostFix2001 : PLW4L9.R.data.a 2001 = 2001
kernel_rfl PL4L9.ghostChk2001 : Pf.ghostChkB (PRE_plx4_L9_entry.s0.heap.get 2001) (PRE_fd_x4_L9_r0_body.s451.heap.get 2001) = true

end Host.Load.Run.Tpl
