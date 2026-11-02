import host.sim.compose.a4b.PLTNa
import host.sim.template.a4pre_pl_common.H0
import host.load.boot.World
set_option Elab.async false
namespace Host.Load.Run.Tpl
open Host.Ts Host.Ts.Sim Host.Ts.Sim.Template Host.Ts.Sim.Full Host.Ts.Sim.Compose Host.Route
set_option maxRecDepth 1000000
set_option maxHeartbeats 0

kernel_rfl PLT.getP : PRE_pl_tail.s0.heap.get 2665 = some (.obj (Template.objOf PRE_pl_tail.s0 2665))
kernel_rfl PLT.kindP : (Template.objOf PRE_pl_tail.s0 2665).kind = .array []
kernel_rfl PLT.imgP : PRE_pl_common.s1.heap.get 2665 = some (.obj { PLTP.R.data.map.obj (Template.objOf PRE_pl_tail.s0 2665) with kind := .array ([] ++ arrOf PRE_pl_common.s1 2665) })
kernel_rfl PLT.emptyP : arrOf PRE_pl_common.s1 2665 = []
noncomputable def PLT.ndAt (a : Nat) : Bool := [ ].all fun b => !Nat.beq (PLTP.R.data.a a) b
tpl_all_blocks PLT.ND from PLTEV : PLT.ndAt
kernel_rfl PLT.ndFramed : PLTEV.frames.all PLT.ndAt = true
kernel_rfl PLT.memoFix : PLTP.R.data.a 4910 = 4910
kernel_rfl PLT.memoGet0 : PRE_pl_tail.s0.heap.get 4910 = some (.obj (Template.objOf PRE_pl_tail.s0 4910))
kernel_rfl PLT.memoGet1 : PRE_pl_common.s1.heap.get 4910 = some (.obj (Template.objOf PRE_pl_common.s1 4910))
noncomputable def PLT.memoEs : List (Val × Val) := match (Template.objOf PRE_pl_common.s1 4910).kind with | .map es => es | _ => []
kernel_rfl PLT.memoKind : (Template.objOf PRE_pl_common.s1 4910).kind = .map PLT.memoEs
kernel_rfl PLT.memoImg : PLTP.R.data.map.obj (Template.objOf PRE_pl_tail.s0 4910) = { Template.objOf PRE_pl_common.s1 4910 with kind := .map (StringIndex.dropCodes [causalKey] PLT.memoEs) }
kernel_rfl PLT.ghostFix1824 : PLTP.R.data.a 1824 = 1824
kernel_rfl PLT.ghostChk1824 : Pf.ghostChkB (PRE_pl_tail.s0.heap.get 1824) (PRE_pl_common.s1.heap.get 1824) = true
kernel_rfl PLT.ghostFix1834 : PLTP.R.data.a 1834 = 1834
kernel_rfl PLT.ghostChk1834 : Pf.ghostChkB (PRE_pl_tail.s0.heap.get 1834) (PRE_pl_common.s1.heap.get 1834) = true
kernel_rfl PLT.ghostFix1852 : PLTP.R.data.a 1852 = 1852
kernel_rfl PLT.ghostChk1852 : Pf.ghostChkB (PRE_pl_tail.s0.heap.get 1852) (PRE_pl_common.s1.heap.get 1852) = true
kernel_rfl PLT.ghostFix1993 : PLTP.R.data.a 1993 = 1993
kernel_rfl PLT.ghostChk1993 : Pf.ghostChkB (PRE_pl_tail.s0.heap.get 1993) (PRE_pl_common.s1.heap.get 1993) = true
kernel_rfl PLT.ghostFix2001 : PLTP.R.data.a 2001 = 2001
kernel_rfl PLT.ghostChk2001 : Pf.ghostChkB (PRE_pl_tail.s0.heap.get 2001) (PRE_pl_common.s1.heap.get 2001) = true
kernel_rfl PLT.ghostFix1279 : PLTP.R.data.a 1279 = 1279
kernel_rfl PLT.ghostChk1279 : Pf.ghostChkB (PRE_pl_tail.s0.heap.get 1279) (PRE_pl_common.s1.heap.get 1279) = true
kernel_rfl PLT.ghostFix1281 : PLTP.R.data.a 1281 = 1281
kernel_rfl PLT.ghostChk1281 : Pf.ghostChkB (PRE_pl_tail.s0.heap.get 1281) (PRE_pl_common.s1.heap.get 1281) = true
kernel_rfl PLT.ghostFix1958 : PLTP.R.data.a 1958 = 1958
kernel_rfl PLT.ghostChk1958 : Pf.ghostChkB (PRE_pl_tail.s0.heap.get 1958) (PRE_pl_common.s1.heap.get 1958) = true
kernel_rfl PLT.ghostFix1959 : PLTP.R.data.a 1959 = 1959
kernel_rfl PLT.ghostChk1959 : Pf.ghostChkB (PRE_pl_tail.s0.heap.get 1959) (PRE_pl_common.s1.heap.get 1959) = true
kernel_rfl PLT.ghostFix4941 : PLTP.R.data.a 4941 = 4941
kernel_rfl PLT.ghostChk4941 : Pf.ghostChkB (PRE_pl_tail.s0.heap.get 4941) (PRE_pl_common.s1.heap.get 4941) = true

end Host.Load.Run.Tpl
