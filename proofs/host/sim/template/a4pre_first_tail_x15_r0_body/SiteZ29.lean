import host.sim.template.a4pre_first_tail_x15_r0_body.SiteS29
import host.sim.template.a4pre_first_tail_x15_r0_body.SiteK29
import host.sim.template.a4pre_first_tail_x15_r0_body.SiteF29
import host.sim.conv.CompactShift
import host.sim.template.Check
import host.sim.BigFreeP
import host.sim.template.CallGen
set_option Elab.async false
namespace Host.Load.Run.Tpl
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
open Host.Ts Host.Ts.Sim Host.Ts.Sim.Template

/-! The compaction's state shift at call site 29 of chain `PRE_first_tail_x15_r0_body` (`Conv.compact_shift`): the call `PRE_first_tail_x15_r0_body.s287`, the merged
state `PRE_first_tail_x15_r0_body.s288`, the canonical state `PRE_first_tail_x15_r0_body.s289`; its frames [2665,2673467,2673472,2673473] (kept arrays [2665,2673467]). -/

-- the map's places and counters
kernel_rfl PRE_first_tail_x15_r0_body.zpl29 : PRE_first_tail_x15_r0_body.pl29.all (Nat.ble PRE_first_tail_x15_r0_body.s287.next) = true
kernel_rfl PRE_first_tail_x15_r0_body.zplnd29 : nodupT PRE_first_tail_x15_r0_body.pl29 PTrie.nil = true
kernel_rfl PRE_first_tail_x15_r0_body.zn129 : Nat.ble PRE_first_tail_x15_r0_body.s287.next 2697338 = true
kernel_rfl PRE_first_tail_x15_r0_body.zfirst29 : Nat.ble aFirst PRE_first_tail_x15_r0_body.s287.next = true
kernel_rfl PRE_first_tail_x15_r0_body.zscn29 : PRE_first_tail_x15_r0_body.s289.next = PRE_first_tail_x15_r0_body.s287.next + PRE_first_tail_x15_r0_body.pl29.length
kernel_rfl PRE_first_tail_x15_r0_body.zsmn29 : PRE_first_tail_x15_r0_body.s288.next = 2697338
kernel_rfl PRE_first_tail_x15_r0_body.zgrow29 : Nat.ble PRE_first_tail_x15_r0_body.s289.next PRE_first_tail_x15_r0_body.s288.next = true
-- the tables
kernel_rfl PRE_first_tail_x15_r0_body.zfresh29 : PRE_first_tail_x15_r0_body.S287.tab.all (fun e => PRE_first_tail_x15_r0_body.cws29.all fun v => e.noVar v) = true
kernel_rfl PRE_first_tail_x15_r0_body.zcnd29 : nodupT PRE_first_tail_x15_r0_body.cws29 PTrie.nil = true
kernel_rfl PRE_first_tail_x15_r0_body.znrHi29 : PRE_first_tail_x15_r0_body.nr29.all (fun r => Nat.blt r PRE_first_tail_x15_r0_body.S288.tab.length) = true
-- the frames: every framed address below the call's counter; the kept arrays the chain start's, extended in the merged state
kernel_rfl PRE_first_tail_x15_r0_body.zfrlt29 : [2665, 2673467, 2673472, 2673473].all (fun a => Nat.blt a PRE_first_tail_x15_r0_body.s287.next) = true
kernel_rfl PRE_first_tail_x15_r0_body.zg29_2665 : PRE_first_tail_x15_r0_body.s289.heap.get 2665 = some (.obj (objOf PRE_first_tail_x15_r0_body.s289 2665))
kernel_rfl PRE_first_tail_x15_r0_body.zk29_2665 : (objOf PRE_first_tail_x15_r0_body.s289 2665).kind = .array (arrOf PRE_first_tail_x15_r0_body.s0 2665)
kernel_rfl PRE_first_tail_x15_r0_body.zm29_2665 : PRE_first_tail_x15_r0_body.s288.heap.get 2665 = some (.obj { PRE_first_tail_x15_r0_body.kappa29.obj (objOf PRE_first_tail_x15_r0_body.s289 2665) with
  kind := .array (arrOf PRE_first_tail_x15_r0_body.s0 2665 ++ (arrOf PRE_first_tail_x15_r0_body.s288 2665).drop (arrOf PRE_first_tail_x15_r0_body.s0 2665).length) })
kernel_rfl PRE_first_tail_x15_r0_body.zg29_2673467 : PRE_first_tail_x15_r0_body.s289.heap.get 2673467 = some (.obj (objOf PRE_first_tail_x15_r0_body.s289 2673467))
kernel_rfl PRE_first_tail_x15_r0_body.zk29_2673467 : (objOf PRE_first_tail_x15_r0_body.s289 2673467).kind = .array (arrOf PRE_first_tail_x15_r0_body.s0 2673467)
kernel_rfl PRE_first_tail_x15_r0_body.zm29_2673467 : PRE_first_tail_x15_r0_body.s288.heap.get 2673467 = some (.obj { PRE_first_tail_x15_r0_body.kappa29.obj (objOf PRE_first_tail_x15_r0_body.s289 2673467) with
  kind := .array (arrOf PRE_first_tail_x15_r0_body.s0 2673467 ++ (arrOf PRE_first_tail_x15_r0_body.s288 2673467).drop (arrOf PRE_first_tail_x15_r0_body.s0 2673467).length) })
kernel_rfl PRE_first_tail_x15_r0_body.zw29_4910 : (PRE_first_tail_x15_r0_body.s289.heap.get 4910).isSome = true
kernel_rfl PRE_first_tail_x15_r0_body.zw29_2673472 : (PRE_first_tail_x15_r0_body.s289.heap.get 2673472).isSome = true
kernel_rfl PRE_first_tail_x15_r0_body.zw29_2673473 : (PRE_first_tail_x15_r0_body.s289.heap.get 2673473).isSome = true
-- the heap: the changed list in range, holding the stage's written and fresh addresses; the canonical side's image
kernel_rfl PRE_first_tail_x15_r0_body.zclbd29 : PRE_first_tail_x15_r0_body.cl29.all (fun b => Nat.blt (b / 4096) (4 ^ 31)) = true
kernel_rfl PRE_first_tail_x15_r0_body.zwr29 : PRE_first_tail_x15_r0_body.st29.wr.all (fun b => !Nat.blt b PRE_first_tail_x15_r0_body.s287.next || PRE_first_tail_x15_r0_body.cl29.contains b) = true
def PRE_first_tail_x15_r0_body.zl29 : List Nat := PRE_first_tail_x15_r0_body.cl29.filter fun a => !(List.contains [2665, 2673467] a)
kernel_rfl PRE_first_tail_x15_r0_body.zimgE29 : PRE_first_tail_x15_r0_body.zl29.map (fun a => PRE_first_tail_x15_r0_body.s288.heap.get (PRE_first_tail_x15_r0_body.kappa29.a a)) = PRE_first_tail_x15_r0_body.zl29.map (fun a => (PRE_first_tail_x15_r0_body.s289.heap.get a).map PRE_first_tail_x15_r0_body.kappa29.hobj)
theorem PRE_first_tail_x15_r0_body.zimg29 : HeapImg PRE_first_tail_x15_r0_body.kappa29 PRE_first_tail_x15_r0_body.s289 PRE_first_tail_x15_r0_body.s288 PRE_first_tail_x15_r0_body.zl29 := PRE_first_tail_x15_r0_body.zimgE29
-- the roots and their supports
kernel_rfl PRE_first_tail_x15_r0_body.zctl29 : PRE_first_tail_x15_r0_body.s288.ctl = PRE_first_tail_x15_r0_body.kappa29.ctl PRE_first_tail_x15_r0_body.s289.ctl
kernel_rfl PRE_first_tail_x15_r0_body.zstack29 : PRE_first_tail_x15_r0_body.s288.stack = PRE_first_tail_x15_r0_body.s289.stack.map PRE_first_tail_x15_r0_body.kappa29.frame
kernel_rfl PRE_first_tail_x15_r0_body.zjobs29 : PRE_first_tail_x15_r0_body.s288.jobs = PRE_first_tail_x15_r0_body.s289.jobs.map PRE_first_tail_x15_r0_body.kappa29.job
kernel_rfl PRE_first_tail_x15_r0_body.zstores29 : PRE_first_tail_x15_r0_body.s288.stores = PRE_first_tail_x15_r0_body.kappa29.stores PRE_first_tail_x15_r0_body.s289.stores
kernel_rfl PRE_first_tail_x15_r0_body.zroots29 : checkRootsSupp PRE_first_tail_x15_r0_body.s289 1294 = true
kernel_rfl PRE_first_tail_x15_r0_body.znC29 : PRE_first_tail_x15_r0_body.S287.tab.length + PRE_first_tail_x15_r0_body.cws29.length = 1294
-- the map as `Conv.compact_shift` states it (the call's counters for the literals)
kernel_rfl PRE_first_tail_x15_r0_body.zkap29 : PRE_first_tail_x15_r0_body.kappa29 = Conv.Map.compact PRE_first_tail_x15_r0_body.s287.next 2697338 PRE_first_tail_x15_r0_body.S287.tab.length PRE_first_tail_x15_r0_body.pl29 (PRE_first_tail_x15_r0_body.nr29.map NumV.ref) PRE_first_tail_x15_r0_body.kd29.big
  PRE_first_tail_x15_r0_body.kd29.region PRE_first_tail_x15_r0_body.kd29.nodeF
-- the bridge inactive at the canonical state (`Conv.FullShiftQ.toX`; the merged state's bridge is the canonical's: cbridge)
theorem PRE_first_tail_x15_r0_body.zbin29 : (Host.Ts.Sim.Full.bridgeOf PRE_first_tail_x15_r0_body.s289.ffi).active = false := (Host.Load.Boot.replay_active Host.Load.Run.Prompt.P.oblog2818)
-- the JS bookkeeping's step (`Conv.JClean.step` over the changed list) and the canonical roots' bigint freedom
kernel_rfl PRE_first_tail_x15_r0_body.zjc29 : Conv.jcleanListB (⟨18768, 15859, 2697328, 1294⟩ : Conv.Cnt) PRE_first_tail_x15_r0_body.s289 PRE_first_tail_x15_r0_body.cl29 = true
kernel_rfl PRE_first_tail_x15_r0_body.zrootsB29 : noBigRootsP (fun i => !Conv.oldBigB (⟨18768, 15859, 2697328, 1294⟩ : Conv.Cnt) i) PRE_first_tail_x15_r0_body.s289.trace PRE_first_tail_x15_r0_body.s289 = true
kernel_rfl PRE_first_tail_x15_r0_body.zhm29 : Nat.ble (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s0.ffi).mlx.nnext 15859 = true
theorem PRE_first_tail_x15_r0_body.cjcl29 (h : Conv.JClean (⟨18768, 15859, 2697327, 1294⟩ : Conv.Cnt) PRE_first_tail_x15_r0_body.s287) : Conv.JClean (⟨18768, 15859, 2697328, 1294⟩ : Conv.Cnt) PRE_first_tail_x15_r0_body.s289 :=
  Conv.JClean.step h (Conv.Cnt.le_of_leB PRE_first_tail_x15_r0_body.cle29)
    (Conv.heap_off_setAll PRE_first_tail_x15_r0_body.cheap29 fun a ha => Nat.blt_eq.mp (List.all_eq_true.mp PRE_first_tail_x15_r0_body.zclbd29 a ha)) PRE_first_tail_x15_r0_body.zjc29

end Host.Load.Run.Tpl
