import host.sim.compose.a4b.PLTVNa
import host.sim.template.a4pre_plvw_common.H0
import host.load.boot.World
set_option Elab.async false
namespace Host.Load.Run.Tpl
open Host.Ts Host.Ts.Sim Host.Ts.Sim.Template Host.Ts.Sim.Full Host.Ts.Sim.Compose Host.Route
set_option maxRecDepth 1000000
set_option maxHeartbeats 0

kernel_rfl PLTV.getP : PRE_pl_tail.s0.heap.get 2665 = some (.obj (Template.objOf PRE_pl_tail.s0 2665))
kernel_rfl PLTV.kindP : (Template.objOf PRE_pl_tail.s0 2665).kind = .array []
kernel_rfl PLTV.imgP : PRE_plvw_common.s1.heap.get 2665 = some (.obj { PLTVW.R.data.map.obj (Template.objOf PRE_pl_tail.s0 2665) with kind := .array ([] ++ arrOf PRE_plvw_common.s1 2665) })
kernel_rfl PLTV.emptyP : arrOf PRE_plvw_common.s1 2665 = []
noncomputable def PLTV.ndAt (a : Nat) : Bool := [2823901].all fun b => !Nat.beq (PLTVW.R.data.a a) b
tpl_all_blocks PLTV.ND from PLTEV : PLTV.ndAt
kernel_rfl PLTV.ndFramed : PLTEV.frames.all PLTV.ndAt = true
kernel_rfl PLTV.memoFix : PLTVW.R.data.a 4910 = 4910
kernel_rfl PLTV.memoGet0 : PRE_pl_tail.s0.heap.get 4910 = some (.obj (Template.objOf PRE_pl_tail.s0 4910))
kernel_rfl PLTV.memoGet1 : PRE_plvw_common.s1.heap.get 4910 = some (.obj (Template.objOf PRE_plvw_common.s1 4910))
noncomputable def PLTV.memoEs : List (Val × Val) := match (Template.objOf PRE_plvw_common.s1 4910).kind with | .map es => es | _ => []
kernel_rfl PLTV.memoKind : (Template.objOf PRE_plvw_common.s1 4910).kind = .map PLTV.memoEs
kernel_rfl PLTV.memoImg : PLTVW.R.data.map.obj (Template.objOf PRE_pl_tail.s0 4910) = { Template.objOf PRE_plvw_common.s1 4910 with kind := .map (StringIndex.dropCodes [causalKey] PLTV.memoEs) }
kernel_rfl PLTV.ghostFix1824 : PLTVW.R.data.a 1824 = 1824
kernel_rfl PLTV.ghostChk1824 : Pf.ghostChkB (PRE_pl_tail.s0.heap.get 1824) (PRE_plvw_common.s1.heap.get 1824) = true
kernel_rfl PLTV.ghostFix1834 : PLTVW.R.data.a 1834 = 1834
kernel_rfl PLTV.ghostChk1834 : Pf.ghostChkB (PRE_pl_tail.s0.heap.get 1834) (PRE_plvw_common.s1.heap.get 1834) = true
kernel_rfl PLTV.ghostFix1852 : PLTVW.R.data.a 1852 = 1852
kernel_rfl PLTV.ghostChk1852 : Pf.ghostChkB (PRE_pl_tail.s0.heap.get 1852) (PRE_plvw_common.s1.heap.get 1852) = true
kernel_rfl PLTV.ghostFix1993 : PLTVW.R.data.a 1993 = 1993
kernel_rfl PLTV.ghostChk1993 : Pf.ghostChkB (PRE_pl_tail.s0.heap.get 1993) (PRE_plvw_common.s1.heap.get 1993) = true
kernel_rfl PLTV.ghostFix2001 : PLTVW.R.data.a 2001 = 2001
kernel_rfl PLTV.ghostChk2001 : Pf.ghostChkB (PRE_pl_tail.s0.heap.get 2001) (PRE_plvw_common.s1.heap.get 2001) = true
kernel_rfl PLTV.ghostFix1279 : PLTVW.R.data.a 1279 = 1279
kernel_rfl PLTV.ghostChk1279 : Pf.ghostChkB (PRE_pl_tail.s0.heap.get 1279) (PRE_plvw_common.s1.heap.get 1279) = true
kernel_rfl PLTV.ghostFix1281 : PLTVW.R.data.a 1281 = 1281
kernel_rfl PLTV.ghostChk1281 : Pf.ghostChkB (PRE_pl_tail.s0.heap.get 1281) (PRE_plvw_common.s1.heap.get 1281) = true
kernel_rfl PLTV.ghostFix1958 : PLTVW.R.data.a 1958 = 1958
kernel_rfl PLTV.ghostChk1958 : Pf.ghostChkB (PRE_pl_tail.s0.heap.get 1958) (PRE_plvw_common.s1.heap.get 1958) = true
kernel_rfl PLTV.ghostFix1959 : PLTVW.R.data.a 1959 = 1959
kernel_rfl PLTV.ghostChk1959 : Pf.ghostChkB (PRE_pl_tail.s0.heap.get 1959) (PRE_plvw_common.s1.heap.get 1959) = true
kernel_rfl PLTV.ghostFix4941 : PLTVW.R.data.a 4941 = 4941
kernel_rfl PLTV.ghostChk4941 : Pf.ghostChkB (PRE_pl_tail.s0.heap.get 4941) (PRE_plvw_common.s1.heap.get 4941) = true

end Host.Load.Run.Tpl
