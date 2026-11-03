import host.sim.compose.a4b.PLVNa
import host.sim.template.a4pre_fd_vw_r0_body.m.B00
import host.load.boot.World
set_option Elab.async false
namespace Host.Load.Run.Tpl
open Host.Ts Host.Ts.Sim Host.Ts.Sim.Template Host.Ts.Sim.Full Host.Ts.Sim.Compose Host.Route
set_option maxRecDepth 1000000
set_option maxHeartbeats 0

kernel_rfl PLV.getP : PRE_plvw_entry.s0.heap.get 2665 = some (.obj (Template.objOf PRE_plvw_entry.s0 2665))
kernel_rfl PLV.kindP : (Template.objOf PRE_plvw_entry.s0 2665).kind = .array []
kernel_rfl PLV.imgP : PRE_fd_vw_r0_body.s900.heap.get 2665 = some (.obj { PLVW.R.data.map.obj (Template.objOf PRE_plvw_entry.s0 2665) with kind := .array ([] ++ arrOf PRE_fd_vw_r0_body.s900 2665) })
kernel_rfl PLV.emptyP : arrOf PRE_fd_vw_r0_body.s900 2665 = []
kernel_rfl PLV.keptFix0 : PLVW.R.data.a 2823901 = 2823901
kernel_rfl PLV.keptNone0 : wideGPf 2823901 = none
kernel_rfl PLV.keptGet0 : PRE_plvw_entry.s0.heap.get 2823901 = some (.obj (Template.objOf PRE_plvw_entry.s0 2823901))
kernel_rfl PLV.keptKind0 : (Template.objOf PRE_plvw_entry.s0 2823901).kind = .array []
kernel_rfl PLV.keptImg0 : PRE_fd_vw_r0_body.s900.heap.get 2823901 = some (.obj { PLVW.R.data.map.obj (Template.objOf PRE_plvw_entry.s0 2823901) with kind := .array ([] ++ arrOf PRE_fd_vw_r0_body.s900 2823901) })
kernel_rfl PLV.keptEmpty0 : arrOf PRE_fd_vw_r0_body.s900 2823901 = []
noncomputable def PLV.ndAt (a : Nat) : Bool := [2823906, 2823907].all fun b => !Nat.beq (PLVW.R.data.a a) b
tpl_all_blocks PLV.ND from PLVEV : PLV.ndAt
kernel_rfl PLV.ndFramed : PLVEV.frames.all PLV.ndAt = true
kernel_rfl PLV.memoFix : PLVW.R.data.a 4910 = 4910
kernel_rfl PLV.memoGet0 : PRE_plvw_entry.s0.heap.get 4910 = some (.obj (Template.objOf PRE_plvw_entry.s0 4910))
kernel_rfl PLV.memoGet1 : PRE_fd_vw_r0_body.s900.heap.get 4910 = some (.obj (Template.objOf PRE_fd_vw_r0_body.s900 4910))
noncomputable def PLV.memoEs : List (Val × Val) := match (Template.objOf PRE_fd_vw_r0_body.s900 4910).kind with | .map es => es | _ => []
kernel_rfl PLV.memoKind : (Template.objOf PRE_fd_vw_r0_body.s900 4910).kind = .map PLV.memoEs
kernel_rfl PLV.memoImg : PLVW.R.data.map.obj (Template.objOf PRE_plvw_entry.s0 4910) = { Template.objOf PRE_fd_vw_r0_body.s900 4910 with kind := .map (StringIndex.dropCodes [causalKey] PLV.memoEs) }
kernel_rfl PLV.ghostFix1824 : PLVW.R.data.a 1824 = 1824
kernel_rfl PLV.ghostChk1824 : Pf.ghostChkB (PRE_plvw_entry.s0.heap.get 1824) (PRE_fd_vw_r0_body.s900.heap.get 1824) = true
kernel_rfl PLV.ghostFix1834 : PLVW.R.data.a 1834 = 1834
kernel_rfl PLV.ghostChk1834 : Pf.ghostChkB (PRE_plvw_entry.s0.heap.get 1834) (PRE_fd_vw_r0_body.s900.heap.get 1834) = true
kernel_rfl PLV.ghostFix1852 : PLVW.R.data.a 1852 = 1852
kernel_rfl PLV.ghostChk1852 : Pf.ghostChkB (PRE_plvw_entry.s0.heap.get 1852) (PRE_fd_vw_r0_body.s900.heap.get 1852) = true
kernel_rfl PLV.ghostFix1993 : PLVW.R.data.a 1993 = 1993
kernel_rfl PLV.ghostChk1993 : Pf.ghostChkB (PRE_plvw_entry.s0.heap.get 1993) (PRE_fd_vw_r0_body.s900.heap.get 1993) = true
kernel_rfl PLV.ghostFix2001 : PLVW.R.data.a 2001 = 2001
kernel_rfl PLV.ghostChk2001 : Pf.ghostChkB (PRE_plvw_entry.s0.heap.get 2001) (PRE_fd_vw_r0_body.s900.heap.get 2001) = true

end Host.Load.Run.Tpl
