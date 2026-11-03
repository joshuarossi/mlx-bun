import host.sim.compose.a4b.PLT4L7Na
import host.sim.template.a4pre_plx4_L7_common.H0
import host.load.boot.World
set_option Elab.async false
namespace Host.Load.Run.Tpl
open Host.Ts Host.Ts.Sim Host.Ts.Sim.Template Host.Ts.Sim.Full Host.Ts.Sim.Compose Host.Route
set_option maxRecDepth 1000000
set_option maxHeartbeats 0

kernel_rfl PLT4L7.getP : PRE_pl_tail.s0.heap.get 2665 = some (.obj (Template.objOf PRE_pl_tail.s0 2665))
kernel_rfl PLT4L7.kindP : (Template.objOf PRE_pl_tail.s0 2665).kind = .array []
kernel_rfl PLT4L7.imgP : PRE_plx4_L7_common.s1.heap.get 2665 = some (.obj { PLTW4L7.R.data.map.obj (Template.objOf PRE_pl_tail.s0 2665) with kind := .array ([] ++ arrOf PRE_plx4_L7_common.s1 2665) })
kernel_rfl PLT4L7.emptyP : arrOf PRE_plx4_L7_common.s1 2665 = []
noncomputable def PLT4L7.ndAt (a : Nat) : Bool := [2834123].all fun b => !Nat.beq (PLTW4L7.R.data.a a) b
tpl_all_blocks PLT4L7.ND from PLTEV : PLT4L7.ndAt
kernel_rfl PLT4L7.ndFramed : PLTEV.frames.all PLT4L7.ndAt = true
kernel_rfl PLT4L7.memoFix : PLTW4L7.R.data.a 4910 = 4910
kernel_rfl PLT4L7.memoGet0 : PRE_pl_tail.s0.heap.get 4910 = some (.obj (Template.objOf PRE_pl_tail.s0 4910))
kernel_rfl PLT4L7.memoGet1 : PRE_plx4_L7_common.s1.heap.get 4910 = some (.obj (Template.objOf PRE_plx4_L7_common.s1 4910))
noncomputable def PLT4L7.memoEs : List (Val × Val) := match (Template.objOf PRE_plx4_L7_common.s1 4910).kind with | .map es => es | _ => []
kernel_rfl PLT4L7.memoKind : (Template.objOf PRE_plx4_L7_common.s1 4910).kind = .map PLT4L7.memoEs
kernel_rfl PLT4L7.memoImg : PLTW4L7.R.data.map.obj (Template.objOf PRE_pl_tail.s0 4910) = { Template.objOf PRE_plx4_L7_common.s1 4910 with kind := .map (StringIndex.dropCodes [causalKey] PLT4L7.memoEs) }
kernel_rfl PLT4L7.ghostFix1824 : PLTW4L7.R.data.a 1824 = 1824
kernel_rfl PLT4L7.ghostChk1824 : Pf.ghostChkB (PRE_pl_tail.s0.heap.get 1824) (PRE_plx4_L7_common.s1.heap.get 1824) = true
kernel_rfl PLT4L7.ghostFix1834 : PLTW4L7.R.data.a 1834 = 1834
kernel_rfl PLT4L7.ghostChk1834 : Pf.ghostChkB (PRE_pl_tail.s0.heap.get 1834) (PRE_plx4_L7_common.s1.heap.get 1834) = true
kernel_rfl PLT4L7.ghostFix1852 : PLTW4L7.R.data.a 1852 = 1852
kernel_rfl PLT4L7.ghostChk1852 : Pf.ghostChkB (PRE_pl_tail.s0.heap.get 1852) (PRE_plx4_L7_common.s1.heap.get 1852) = true
kernel_rfl PLT4L7.ghostFix1993 : PLTW4L7.R.data.a 1993 = 1993
kernel_rfl PLT4L7.ghostChk1993 : Pf.ghostChkB (PRE_pl_tail.s0.heap.get 1993) (PRE_plx4_L7_common.s1.heap.get 1993) = true
kernel_rfl PLT4L7.ghostFix2001 : PLTW4L7.R.data.a 2001 = 2001
kernel_rfl PLT4L7.ghostChk2001 : Pf.ghostChkB (PRE_pl_tail.s0.heap.get 2001) (PRE_plx4_L7_common.s1.heap.get 2001) = true
kernel_rfl PLT4L7.ghostFix1279 : PLTW4L7.R.data.a 1279 = 1279
kernel_rfl PLT4L7.ghostChk1279 : Pf.ghostChkB (PRE_pl_tail.s0.heap.get 1279) (PRE_plx4_L7_common.s1.heap.get 1279) = true
kernel_rfl PLT4L7.ghostFix1281 : PLTW4L7.R.data.a 1281 = 1281
kernel_rfl PLT4L7.ghostChk1281 : Pf.ghostChkB (PRE_pl_tail.s0.heap.get 1281) (PRE_plx4_L7_common.s1.heap.get 1281) = true
kernel_rfl PLT4L7.ghostFix1958 : PLTW4L7.R.data.a 1958 = 1958
kernel_rfl PLT4L7.ghostChk1958 : Pf.ghostChkB (PRE_pl_tail.s0.heap.get 1958) (PRE_plx4_L7_common.s1.heap.get 1958) = true
kernel_rfl PLT4L7.ghostFix1959 : PLTW4L7.R.data.a 1959 = 1959
kernel_rfl PLT4L7.ghostChk1959 : Pf.ghostChkB (PRE_pl_tail.s0.heap.get 1959) (PRE_plx4_L7_common.s1.heap.get 1959) = true
kernel_rfl PLT4L7.ghostFix4941 : PLTW4L7.R.data.a 4941 = 4941
kernel_rfl PLT4L7.ghostChk4941 : Pf.ghostChkB (PRE_pl_tail.s0.heap.get 4941) (PRE_plx4_L7_common.s1.heap.get 4941) = true

end Host.Load.Run.Tpl
