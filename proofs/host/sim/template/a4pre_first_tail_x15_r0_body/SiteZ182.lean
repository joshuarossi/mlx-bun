import host.sim.template.a4pre_first_tail_x15_r0_body.SiteS182
import host.sim.template.a4pre_first_tail_x15_r0_body.SiteK182
import host.sim.template.a4pre_first_tail_x15_r0_body.SiteF182
import host.sim.conv.CompactShift
import host.sim.template.Check
import host.sim.BigFreeP
import host.sim.template.CallGen
set_option Elab.async false
namespace Host.Load.Run.Tpl
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
open Host.Ts Host.Ts.Sim Host.Ts.Sim.Template

/-! The compaction's state shift at call site 182 of chain `PRE_first_tail_x15_r0_body` (`Conv.compact_shift`): the call `PRE_first_tail_x15_r0_body.s1753`, the merged
state `PRE_first_tail_x15_r0_body.s1754`, the canonical state `PRE_first_tail_x15_r0_body.s1755`; its frames [2665,2673467,2673472,2673473] (kept arrays [2665,2673467]). -/

-- the map's places and counters
kernel_rfl PRE_first_tail_x15_r0_body.zpl182 : PRE_first_tail_x15_r0_body.pl182.all (Nat.ble PRE_first_tail_x15_r0_body.s1753.next) = true
kernel_rfl PRE_first_tail_x15_r0_body.zplnd182 : nodupT PRE_first_tail_x15_r0_body.pl182 PTrie.nil = true
kernel_rfl PRE_first_tail_x15_r0_body.zn1182 : Nat.ble PRE_first_tail_x15_r0_body.s1753.next 2817531 = true
kernel_rfl PRE_first_tail_x15_r0_body.zfirst182 : Nat.ble aFirst PRE_first_tail_x15_r0_body.s1753.next = true
kernel_rfl PRE_first_tail_x15_r0_body.zscn182 : PRE_first_tail_x15_r0_body.s1755.next = PRE_first_tail_x15_r0_body.s1753.next + PRE_first_tail_x15_r0_body.pl182.length
kernel_rfl PRE_first_tail_x15_r0_body.zsmn182 : PRE_first_tail_x15_r0_body.s1754.next = 2817531
kernel_rfl PRE_first_tail_x15_r0_body.zgrow182 : Nat.ble PRE_first_tail_x15_r0_body.s1755.next PRE_first_tail_x15_r0_body.s1754.next = true
-- the tables
kernel_rfl PRE_first_tail_x15_r0_body.zfresh182 : PRE_first_tail_x15_r0_body.S1753.tab.all (fun e => PRE_first_tail_x15_r0_body.cws182.all fun v => e.noVar v) = true
kernel_rfl PRE_first_tail_x15_r0_body.zcnd182 : nodupT PRE_first_tail_x15_r0_body.cws182 PTrie.nil = true
kernel_rfl PRE_first_tail_x15_r0_body.znrHi182 : PRE_first_tail_x15_r0_body.nr182.all (fun r => Nat.blt r PRE_first_tail_x15_r0_body.S1754.tab.length) = true
-- the frames: every framed address below the call's counter; the kept arrays the chain start's, extended in the merged state
kernel_rfl PRE_first_tail_x15_r0_body.zfrlt182 : [2665, 2673467, 2673472, 2673473].all (fun a => Nat.blt a PRE_first_tail_x15_r0_body.s1753.next) = true
kernel_rfl PRE_first_tail_x15_r0_body.zg182_2665 : PRE_first_tail_x15_r0_body.s1755.heap.get 2665 = some (.obj (objOf PRE_first_tail_x15_r0_body.s1755 2665))
kernel_rfl PRE_first_tail_x15_r0_body.zk182_2665 : (objOf PRE_first_tail_x15_r0_body.s1755 2665).kind = .array (arrOf PRE_first_tail_x15_r0_body.s0 2665)
kernel_rfl PRE_first_tail_x15_r0_body.zm182_2665 : PRE_first_tail_x15_r0_body.s1754.heap.get 2665 = some (.obj { PRE_first_tail_x15_r0_body.kappa182.obj (objOf PRE_first_tail_x15_r0_body.s1755 2665) with
  kind := .array (arrOf PRE_first_tail_x15_r0_body.s0 2665 ++ (arrOf PRE_first_tail_x15_r0_body.s1754 2665).drop (arrOf PRE_first_tail_x15_r0_body.s0 2665).length) })
kernel_rfl PRE_first_tail_x15_r0_body.zg182_2673467 : PRE_first_tail_x15_r0_body.s1755.heap.get 2673467 = some (.obj (objOf PRE_first_tail_x15_r0_body.s1755 2673467))
kernel_rfl PRE_first_tail_x15_r0_body.zk182_2673467 : (objOf PRE_first_tail_x15_r0_body.s1755 2673467).kind = .array (arrOf PRE_first_tail_x15_r0_body.s0 2673467)
kernel_rfl PRE_first_tail_x15_r0_body.zm182_2673467 : PRE_first_tail_x15_r0_body.s1754.heap.get 2673467 = some (.obj { PRE_first_tail_x15_r0_body.kappa182.obj (objOf PRE_first_tail_x15_r0_body.s1755 2673467) with
  kind := .array (arrOf PRE_first_tail_x15_r0_body.s0 2673467 ++ (arrOf PRE_first_tail_x15_r0_body.s1754 2673467).drop (arrOf PRE_first_tail_x15_r0_body.s0 2673467).length) })
kernel_rfl PRE_first_tail_x15_r0_body.zw182_4910 : (PRE_first_tail_x15_r0_body.s1755.heap.get 4910).isSome = true
kernel_rfl PRE_first_tail_x15_r0_body.zw182_2673472 : (PRE_first_tail_x15_r0_body.s1755.heap.get 2673472).isSome = true
kernel_rfl PRE_first_tail_x15_r0_body.zw182_2673473 : (PRE_first_tail_x15_r0_body.s1755.heap.get 2673473).isSome = true
-- the heap: the changed list in range, holding the stage's written and fresh addresses; the canonical side's image
kernel_rfl PRE_first_tail_x15_r0_body.zclbd182 : PRE_first_tail_x15_r0_body.cl182.all (fun b => Nat.blt (b / 4096) (4 ^ 31)) = true
kernel_rfl PRE_first_tail_x15_r0_body.zwr182 : PRE_first_tail_x15_r0_body.st182.wr.all (fun b => !Nat.blt b PRE_first_tail_x15_r0_body.s1753.next || PRE_first_tail_x15_r0_body.cl182.contains b) = true
def PRE_first_tail_x15_r0_body.zl182 : List Nat := PRE_first_tail_x15_r0_body.cl182.filter fun a => !(List.contains [2665, 2673467] a)
kernel_rfl PRE_first_tail_x15_r0_body.zimgE182 : PRE_first_tail_x15_r0_body.zl182.map (fun a => PRE_first_tail_x15_r0_body.s1754.heap.get (PRE_first_tail_x15_r0_body.kappa182.a a)) = PRE_first_tail_x15_r0_body.zl182.map (fun a => (PRE_first_tail_x15_r0_body.s1755.heap.get a).map PRE_first_tail_x15_r0_body.kappa182.hobj)
theorem PRE_first_tail_x15_r0_body.zimg182 : HeapImg PRE_first_tail_x15_r0_body.kappa182 PRE_first_tail_x15_r0_body.s1755 PRE_first_tail_x15_r0_body.s1754 PRE_first_tail_x15_r0_body.zl182 := PRE_first_tail_x15_r0_body.zimgE182
-- the roots and their supports
kernel_rfl PRE_first_tail_x15_r0_body.zctl182 : PRE_first_tail_x15_r0_body.s1754.ctl = PRE_first_tail_x15_r0_body.kappa182.ctl PRE_first_tail_x15_r0_body.s1755.ctl
kernel_rfl PRE_first_tail_x15_r0_body.zstack182 : PRE_first_tail_x15_r0_body.s1754.stack = PRE_first_tail_x15_r0_body.s1755.stack.map PRE_first_tail_x15_r0_body.kappa182.frame
kernel_rfl PRE_first_tail_x15_r0_body.zjobs182 : PRE_first_tail_x15_r0_body.s1754.jobs = PRE_first_tail_x15_r0_body.s1755.jobs.map PRE_first_tail_x15_r0_body.kappa182.job
kernel_rfl PRE_first_tail_x15_r0_body.zstores182 : PRE_first_tail_x15_r0_body.s1754.stores = PRE_first_tail_x15_r0_body.kappa182.stores PRE_first_tail_x15_r0_body.s1755.stores
kernel_rfl PRE_first_tail_x15_r0_body.zroots182 : checkRootsSupp PRE_first_tail_x15_r0_body.s1755 7834 = true
kernel_rfl PRE_first_tail_x15_r0_body.znC182 : PRE_first_tail_x15_r0_body.S1753.tab.length + PRE_first_tail_x15_r0_body.cws182.length = 7834
-- the map as `Conv.compact_shift` states it (the call's counters for the literals)
kernel_rfl PRE_first_tail_x15_r0_body.zkap182 : PRE_first_tail_x15_r0_body.kappa182 = Conv.Map.compact PRE_first_tail_x15_r0_body.s1753.next 2817531 PRE_first_tail_x15_r0_body.S1753.tab.length PRE_first_tail_x15_r0_body.pl182 (PRE_first_tail_x15_r0_body.nr182.map NumV.ref) PRE_first_tail_x15_r0_body.kd182.big
  PRE_first_tail_x15_r0_body.kd182.region PRE_first_tail_x15_r0_body.kd182.nodeF
-- the bridge inactive at the canonical state (`Conv.FullShiftQ.toX`; the merged state's bridge is the canonical's: cbridge)
theorem PRE_first_tail_x15_r0_body.zbin182 : (Host.Ts.Sim.Full.bridgeOf PRE_first_tail_x15_r0_body.s1755.ffi).active = false := (Host.Load.Boot.replay_active Host.Load.Run.Prompt.P.oblog2818)
-- the JS bookkeeping's step (`Conv.JClean.step` over the changed list) and the canonical roots' bigint freedom
kernel_rfl PRE_first_tail_x15_r0_body.zjc182 : Conv.jcleanListB (⟨21779, 18877, 2817512, 7834⟩ : Conv.Cnt) PRE_first_tail_x15_r0_body.s1755 PRE_first_tail_x15_r0_body.cl182 = true
kernel_rfl PRE_first_tail_x15_r0_body.zrootsB182 : noBigRootsP (fun i => !Conv.oldBigB (⟨21779, 18877, 2817512, 7834⟩ : Conv.Cnt) i) PRE_first_tail_x15_r0_body.s1755.trace PRE_first_tail_x15_r0_body.s1755 = true
kernel_rfl PRE_first_tail_x15_r0_body.zhm182 : Nat.ble (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s0.ffi).mlx.nnext 18877 = true
theorem PRE_first_tail_x15_r0_body.cjcl182 (h : Conv.JClean (⟨21779, 18877, 2817511, 7834⟩ : Conv.Cnt) PRE_first_tail_x15_r0_body.s1753) : Conv.JClean (⟨21779, 18877, 2817512, 7834⟩ : Conv.Cnt) PRE_first_tail_x15_r0_body.s1755 :=
  Conv.JClean.step h (Conv.Cnt.le_of_leB PRE_first_tail_x15_r0_body.cle182)
    (Conv.heap_off_setAll PRE_first_tail_x15_r0_body.cheap182 fun a ha => Nat.blt_eq.mp (List.all_eq_true.mp PRE_first_tail_x15_r0_body.zclbd182 a ha)) PRE_first_tail_x15_r0_body.zjc182

end Host.Load.Run.Tpl
