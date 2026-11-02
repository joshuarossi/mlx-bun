import host.sim.compose.a4b.PLD1Na
import host.sim.template.a4pre_d1_body.D4
import host.load.boot.World
set_option Elab.async false
namespace Host.Load.Run.Tpl
open Host.Ts Host.Ts.Sim Host.Ts.Sim.Template Host.Ts.Sim.Full Host.Ts.Sim.Compose Host.Route
set_option maxRecDepth 1000000
set_option maxHeartbeats 0

kernel_rfl PLD1.getP : PRE_pl_entry.s0.heap.get 2665 = some (.obj (Template.objOf PRE_pl_entry.s0 2665))
kernel_rfl PLD1.kindP : (Template.objOf PRE_pl_entry.s0 2665).kind = .array []
kernel_rfl PLD1.imgP : D1Body.s155.heap.get 2665 = some (.obj { PLWalkD1.R.data.map.obj (Template.objOf PRE_pl_entry.s0 2665) with kind := .array ([] ++ arrOf D1Body.s155 2665) })
kernel_rfl PLD1.emptyP : arrOf D1Body.s155 2665 = []
kernel_rfl PLD1.keptFix0 : PLWalkD1.R.data.a 2673479 = 2673479
kernel_rfl PLD1.keptNone0 : wideGPf 2673479 = none
kernel_rfl PLD1.keptGet0 : PRE_pl_entry.s0.heap.get 2673479 = some (.obj (Template.objOf PRE_pl_entry.s0 2673479))
kernel_rfl PLD1.keptKind0 : (Template.objOf PRE_pl_entry.s0 2673479).kind = .array []
kernel_rfl PLD1.keptImg0 : D1Body.s155.heap.get 2673479 = some (.obj { PLWalkD1.R.data.map.obj (Template.objOf PRE_pl_entry.s0 2673479) with kind := .array ([] ++ arrOf D1Body.s155 2673479) })
kernel_rfl PLD1.keptEmpty0 : arrOf D1Body.s155 2673479 = []
noncomputable def PLD1.ndAt (a : Nat) : Bool := [D1Frames.buffer, D1Frames.view].all fun b => !Nat.beq (PLWalkD1.R.data.a a) b
tpl_all_blocks PLD1.ND from PLEntryV : PLD1.ndAt
kernel_rfl PLD1.ndFramed : PLEntryV.frames.all PLD1.ndAt = true
kernel_rfl PLD1.memoFix : PLWalkD1.R.data.a 4910 = 4910
kernel_rfl PLD1.memoGet0 : PRE_pl_entry.s0.heap.get 4910 = some (.obj (Template.objOf PRE_pl_entry.s0 4910))
kernel_rfl PLD1.memoGet1 : D1Body.s155.heap.get 4910 = some (.obj (Template.objOf D1Body.s155 4910))
noncomputable def PLD1.memoEs : List (Val × Val) := match (Template.objOf D1Body.s155 4910).kind with | .map es => es | _ => []
kernel_rfl PLD1.memoKind : (Template.objOf D1Body.s155 4910).kind = .map PLD1.memoEs
kernel_rfl PLD1.memoImg : PLWalkD1.R.data.map.obj (Template.objOf PRE_pl_entry.s0 4910) = { Template.objOf D1Body.s155 4910 with kind := .map (StringIndex.dropCodes [causalKey] PLD1.memoEs) }
kernel_rfl PLD1.ghostFix1824 : PLWalkD1.R.data.a 1824 = 1824
kernel_rfl PLD1.ghostChk1824 : Pf.ghostChkB (PRE_pl_entry.s0.heap.get 1824) (D1Body.s155.heap.get 1824) = true
kernel_rfl PLD1.ghostFix1834 : PLWalkD1.R.data.a 1834 = 1834
kernel_rfl PLD1.ghostChk1834 : Pf.ghostChkB (PRE_pl_entry.s0.heap.get 1834) (D1Body.s155.heap.get 1834) = true
kernel_rfl PLD1.ghostFix1852 : PLWalkD1.R.data.a 1852 = 1852
kernel_rfl PLD1.ghostChk1852 : Pf.ghostChkB (PRE_pl_entry.s0.heap.get 1852) (D1Body.s155.heap.get 1852) = true
kernel_rfl PLD1.ghostFix1993 : PLWalkD1.R.data.a 1993 = 1993
kernel_rfl PLD1.ghostChk1993 : Pf.ghostChkB (PRE_pl_entry.s0.heap.get 1993) (D1Body.s155.heap.get 1993) = true
kernel_rfl PLD1.ghostFix2001 : PLWalkD1.R.data.a 2001 = 2001
kernel_rfl PLD1.ghostChk2001 : Pf.ghostChkB (PRE_pl_entry.s0.heap.get 2001) (D1Body.s155.heap.get 2001) = true

end Host.Load.Run.Tpl
