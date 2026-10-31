import host.sim.template.a4pre_first_tail_x15_r0_body.SiteS86
import host.sim.template.a4pre_first_tail_x15_r0_body.SiteK86
import host.sim.template.a4pre_first_tail_x15_r0_body.SiteF86
import host.sim.conv.CompactShift
import host.sim.template.Check
import host.sim.BigFreeP
import host.sim.template.CallGen
set_option Elab.async false
namespace Host.Load.Run.Tpl
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
open Host.Ts Host.Ts.Sim Host.Ts.Sim.Template

/-! The compaction's state shift at call site 86 of chain `PRE_first_tail_x15_r0_body` (`Conv.compact_shift`): the call `PRE_first_tail_x15_r0_body.s833`, the merged
state `PRE_first_tail_x15_r0_body.s834`, the canonical state `PRE_first_tail_x15_r0_body.s835`; its frames [2665,2673467,2673472,2673473] (kept arrays [2665,2673467]). -/

-- the map's places and counters
kernel_rfl PRE_first_tail_x15_r0_body.zpl86 : PRE_first_tail_x15_r0_body.pl86.all (Nat.ble PRE_first_tail_x15_r0_body.s833.next) = true
kernel_rfl PRE_first_tail_x15_r0_body.zplnd86 : nodupT PRE_first_tail_x15_r0_body.pl86 PTrie.nil = true
kernel_rfl PRE_first_tail_x15_r0_body.zn186 : Nat.ble PRE_first_tail_x15_r0_body.s833.next 2742166 = true
kernel_rfl PRE_first_tail_x15_r0_body.zfirst86 : Nat.ble aFirst PRE_first_tail_x15_r0_body.s833.next = true
kernel_rfl PRE_first_tail_x15_r0_body.zscn86 : PRE_first_tail_x15_r0_body.s835.next = PRE_first_tail_x15_r0_body.s833.next + PRE_first_tail_x15_r0_body.pl86.length
kernel_rfl PRE_first_tail_x15_r0_body.zsmn86 : PRE_first_tail_x15_r0_body.s834.next = 2742166
kernel_rfl PRE_first_tail_x15_r0_body.zgrow86 : Nat.ble PRE_first_tail_x15_r0_body.s835.next PRE_first_tail_x15_r0_body.s834.next = true
-- the tables
kernel_rfl PRE_first_tail_x15_r0_body.zfresh86 : PRE_first_tail_x15_r0_body.S833.tab.all (fun e => PRE_first_tail_x15_r0_body.cws86.all fun v => e.noVar v) = true
kernel_rfl PRE_first_tail_x15_r0_body.zcnd86 : nodupT PRE_first_tail_x15_r0_body.cws86 PTrie.nil = true
kernel_rfl PRE_first_tail_x15_r0_body.znrHi86 : PRE_first_tail_x15_r0_body.nr86.all (fun r => Nat.blt r PRE_first_tail_x15_r0_body.S834.tab.length) = true
-- the frames: every framed address below the call's counter; the kept arrays the chain start's, extended in the merged state
kernel_rfl PRE_first_tail_x15_r0_body.zfrlt86 : [2665, 2673467, 2673472, 2673473].all (fun a => Nat.blt a PRE_first_tail_x15_r0_body.s833.next) = true
kernel_rfl PRE_first_tail_x15_r0_body.zg86_2665 : PRE_first_tail_x15_r0_body.s835.heap.get 2665 = some (.obj (objOf PRE_first_tail_x15_r0_body.s835 2665))
kernel_rfl PRE_first_tail_x15_r0_body.zk86_2665 : (objOf PRE_first_tail_x15_r0_body.s835 2665).kind = .array (arrOf PRE_first_tail_x15_r0_body.s0 2665)
kernel_rfl PRE_first_tail_x15_r0_body.zm86_2665 : PRE_first_tail_x15_r0_body.s834.heap.get 2665 = some (.obj { PRE_first_tail_x15_r0_body.kappa86.obj (objOf PRE_first_tail_x15_r0_body.s835 2665) with
  kind := .array (arrOf PRE_first_tail_x15_r0_body.s0 2665 ++ (arrOf PRE_first_tail_x15_r0_body.s834 2665).drop (arrOf PRE_first_tail_x15_r0_body.s0 2665).length) })
kernel_rfl PRE_first_tail_x15_r0_body.zg86_2673467 : PRE_first_tail_x15_r0_body.s835.heap.get 2673467 = some (.obj (objOf PRE_first_tail_x15_r0_body.s835 2673467))
kernel_rfl PRE_first_tail_x15_r0_body.zk86_2673467 : (objOf PRE_first_tail_x15_r0_body.s835 2673467).kind = .array (arrOf PRE_first_tail_x15_r0_body.s0 2673467)
kernel_rfl PRE_first_tail_x15_r0_body.zm86_2673467 : PRE_first_tail_x15_r0_body.s834.heap.get 2673467 = some (.obj { PRE_first_tail_x15_r0_body.kappa86.obj (objOf PRE_first_tail_x15_r0_body.s835 2673467) with
  kind := .array (arrOf PRE_first_tail_x15_r0_body.s0 2673467 ++ (arrOf PRE_first_tail_x15_r0_body.s834 2673467).drop (arrOf PRE_first_tail_x15_r0_body.s0 2673467).length) })
kernel_rfl PRE_first_tail_x15_r0_body.zw86_4910 : (PRE_first_tail_x15_r0_body.s835.heap.get 4910).isSome = true
kernel_rfl PRE_first_tail_x15_r0_body.zw86_2673472 : (PRE_first_tail_x15_r0_body.s835.heap.get 2673472).isSome = true
kernel_rfl PRE_first_tail_x15_r0_body.zw86_2673473 : (PRE_first_tail_x15_r0_body.s835.heap.get 2673473).isSome = true
-- the heap: the changed list in range, holding the stage's written and fresh addresses; the canonical side's image
kernel_rfl PRE_first_tail_x15_r0_body.zclbd86 : PRE_first_tail_x15_r0_body.cl86.all (fun b => Nat.blt (b / 4096) (4 ^ 31)) = true
kernel_rfl PRE_first_tail_x15_r0_body.zwr86 : PRE_first_tail_x15_r0_body.st86.wr.all (fun b => !Nat.blt b PRE_first_tail_x15_r0_body.s833.next || PRE_first_tail_x15_r0_body.cl86.contains b) = true
def PRE_first_tail_x15_r0_body.zl86 : List Nat := PRE_first_tail_x15_r0_body.cl86.filter fun a => !(List.contains [2665, 2673467] a)
kernel_rfl PRE_first_tail_x15_r0_body.zimgE86 : PRE_first_tail_x15_r0_body.zl86.map (fun a => PRE_first_tail_x15_r0_body.s834.heap.get (PRE_first_tail_x15_r0_body.kappa86.a a)) = PRE_first_tail_x15_r0_body.zl86.map (fun a => (PRE_first_tail_x15_r0_body.s835.heap.get a).map PRE_first_tail_x15_r0_body.kappa86.hobj)
theorem PRE_first_tail_x15_r0_body.zimg86 : HeapImg PRE_first_tail_x15_r0_body.kappa86 PRE_first_tail_x15_r0_body.s835 PRE_first_tail_x15_r0_body.s834 PRE_first_tail_x15_r0_body.zl86 := PRE_first_tail_x15_r0_body.zimgE86
-- the roots and their supports
kernel_rfl PRE_first_tail_x15_r0_body.zctl86 : PRE_first_tail_x15_r0_body.s834.ctl = PRE_first_tail_x15_r0_body.kappa86.ctl PRE_first_tail_x15_r0_body.s835.ctl
kernel_rfl PRE_first_tail_x15_r0_body.zstack86 : PRE_first_tail_x15_r0_body.s834.stack = PRE_first_tail_x15_r0_body.s835.stack.map PRE_first_tail_x15_r0_body.kappa86.frame
kernel_rfl PRE_first_tail_x15_r0_body.zjobs86 : PRE_first_tail_x15_r0_body.s834.jobs = PRE_first_tail_x15_r0_body.s835.jobs.map PRE_first_tail_x15_r0_body.kappa86.job
kernel_rfl PRE_first_tail_x15_r0_body.zstores86 : PRE_first_tail_x15_r0_body.s834.stores = PRE_first_tail_x15_r0_body.kappa86.stores PRE_first_tail_x15_r0_body.s835.stores
kernel_rfl PRE_first_tail_x15_r0_body.zroots86 : checkRootsSupp PRE_first_tail_x15_r0_body.s835 3730 = true
kernel_rfl PRE_first_tail_x15_r0_body.znC86 : PRE_first_tail_x15_r0_body.S833.tab.length + PRE_first_tail_x15_r0_body.cws86.length = 3730
-- the map as `Conv.compact_shift` states it (the call's counters for the literals)
kernel_rfl PRE_first_tail_x15_r0_body.zkap86 : PRE_first_tail_x15_r0_body.kappa86 = Conv.Map.compact PRE_first_tail_x15_r0_body.s833.next 2742166 PRE_first_tail_x15_r0_body.S833.tab.length PRE_first_tail_x15_r0_body.pl86 (PRE_first_tail_x15_r0_body.nr86.map NumV.ref) PRE_first_tail_x15_r0_body.kd86.big
  PRE_first_tail_x15_r0_body.kd86.region PRE_first_tail_x15_r0_body.kd86.nodeF
-- the bridge inactive at the canonical state (`Conv.FullShiftQ.toX`; the merged state's bridge is the canonical's: cbridge)
theorem PRE_first_tail_x15_r0_body.zbin86 : (Host.Ts.Sim.Full.bridgeOf PRE_first_tail_x15_r0_body.s835.ffi).active = false := (Host.Load.Boot.replay_active Host.Load.Run.Prompt.P.oblog2818)
-- the JS bookkeeping's step (`Conv.JClean.step` over the changed list) and the canonical roots' bigint freedom
kernel_rfl PRE_first_tail_x15_r0_body.zjc86 : Conv.jcleanListB (⟨19891, 16981, 2742156, 3730⟩ : Conv.Cnt) PRE_first_tail_x15_r0_body.s835 PRE_first_tail_x15_r0_body.cl86 = true
kernel_rfl PRE_first_tail_x15_r0_body.zrootsB86 : noBigRootsP (fun i => !Conv.oldBigB (⟨19891, 16981, 2742156, 3730⟩ : Conv.Cnt) i) PRE_first_tail_x15_r0_body.s835.trace PRE_first_tail_x15_r0_body.s835 = true
kernel_rfl PRE_first_tail_x15_r0_body.zhm86 : Nat.ble (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s0.ffi).mlx.nnext 16981 = true
theorem PRE_first_tail_x15_r0_body.cjcl86 (h : Conv.JClean (⟨19891, 16981, 2742155, 3730⟩ : Conv.Cnt) PRE_first_tail_x15_r0_body.s833) : Conv.JClean (⟨19891, 16981, 2742156, 3730⟩ : Conv.Cnt) PRE_first_tail_x15_r0_body.s835 :=
  Conv.JClean.step h (Conv.Cnt.le_of_leB PRE_first_tail_x15_r0_body.cle86)
    (Conv.heap_off_setAll PRE_first_tail_x15_r0_body.cheap86 fun a ha => Nat.blt_eq.mp (List.all_eq_true.mp PRE_first_tail_x15_r0_body.zclbd86 a ha)) PRE_first_tail_x15_r0_body.zjc86

end Host.Load.Run.Tpl
