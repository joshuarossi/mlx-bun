import host.sim.template.a4pre_first_tail_x15_r0_body.SiteS56
import host.sim.template.a4pre_first_tail_x15_r0_body.SiteK56
import host.sim.template.a4pre_first_tail_x15_r0_body.SiteF56
import host.sim.conv.CompactShift
import host.sim.template.Check
import host.sim.BigFreeP
import host.sim.template.CallGen
set_option Elab.async false
namespace Host.Load.Run.Tpl
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
open Host.Ts Host.Ts.Sim Host.Ts.Sim.Template

/-! The compaction's state shift at call site 56 of chain `PRE_first_tail_x15_r0_body` (`Conv.compact_shift`): the call `PRE_first_tail_x15_r0_body.s499`, the merged
state `PRE_first_tail_x15_r0_body.s500`, the canonical state `PRE_first_tail_x15_r0_body.s501`; its frames [2665,2673467,2673472,2673473] (kept arrays [2665,2673467]). -/

-- the map's places and counters
kernel_rfl PRE_first_tail_x15_r0_body.zpl56 : PRE_first_tail_x15_r0_body.pl56.all (Nat.ble PRE_first_tail_x15_r0_body.s499.next) = true
kernel_rfl PRE_first_tail_x15_r0_body.zplnd56 : nodupT PRE_first_tail_x15_r0_body.pl56 PTrie.nil = true
kernel_rfl PRE_first_tail_x15_r0_body.zn156 : Nat.ble PRE_first_tail_x15_r0_body.s499.next 2718447 = true
kernel_rfl PRE_first_tail_x15_r0_body.zfirst56 : Nat.ble aFirst PRE_first_tail_x15_r0_body.s499.next = true
kernel_rfl PRE_first_tail_x15_r0_body.zscn56 : PRE_first_tail_x15_r0_body.s501.next = PRE_first_tail_x15_r0_body.s499.next + PRE_first_tail_x15_r0_body.pl56.length
kernel_rfl PRE_first_tail_x15_r0_body.zsmn56 : PRE_first_tail_x15_r0_body.s500.next = 2718447
kernel_rfl PRE_first_tail_x15_r0_body.zgrow56 : Nat.ble PRE_first_tail_x15_r0_body.s501.next PRE_first_tail_x15_r0_body.s500.next = true
-- the tables
kernel_rfl PRE_first_tail_x15_r0_body.zfresh56 : PRE_first_tail_x15_r0_body.S499.tab.all (fun e => PRE_first_tail_x15_r0_body.cws56.all fun v => e.noVar v) = true
kernel_rfl PRE_first_tail_x15_r0_body.zcnd56 : nodupT PRE_first_tail_x15_r0_body.cws56 PTrie.nil = true
kernel_rfl PRE_first_tail_x15_r0_body.znrHi56 : PRE_first_tail_x15_r0_body.nr56.all (fun r => Nat.blt r PRE_first_tail_x15_r0_body.S500.tab.length) = true
-- the frames: every framed address below the call's counter; the kept arrays the chain start's, extended in the merged state
kernel_rfl PRE_first_tail_x15_r0_body.zfrlt56 : [2665, 2673467, 2673472, 2673473].all (fun a => Nat.blt a PRE_first_tail_x15_r0_body.s499.next) = true
kernel_rfl PRE_first_tail_x15_r0_body.zg56_2665 : PRE_first_tail_x15_r0_body.s501.heap.get 2665 = some (.obj (objOf PRE_first_tail_x15_r0_body.s501 2665))
kernel_rfl PRE_first_tail_x15_r0_body.zk56_2665 : (objOf PRE_first_tail_x15_r0_body.s501 2665).kind = .array (arrOf PRE_first_tail_x15_r0_body.s0 2665)
kernel_rfl PRE_first_tail_x15_r0_body.zm56_2665 : PRE_first_tail_x15_r0_body.s500.heap.get 2665 = some (.obj { PRE_first_tail_x15_r0_body.kappa56.obj (objOf PRE_first_tail_x15_r0_body.s501 2665) with
  kind := .array (arrOf PRE_first_tail_x15_r0_body.s0 2665 ++ (arrOf PRE_first_tail_x15_r0_body.s500 2665).drop (arrOf PRE_first_tail_x15_r0_body.s0 2665).length) })
kernel_rfl PRE_first_tail_x15_r0_body.zg56_2673467 : PRE_first_tail_x15_r0_body.s501.heap.get 2673467 = some (.obj (objOf PRE_first_tail_x15_r0_body.s501 2673467))
kernel_rfl PRE_first_tail_x15_r0_body.zk56_2673467 : (objOf PRE_first_tail_x15_r0_body.s501 2673467).kind = .array (arrOf PRE_first_tail_x15_r0_body.s0 2673467)
kernel_rfl PRE_first_tail_x15_r0_body.zm56_2673467 : PRE_first_tail_x15_r0_body.s500.heap.get 2673467 = some (.obj { PRE_first_tail_x15_r0_body.kappa56.obj (objOf PRE_first_tail_x15_r0_body.s501 2673467) with
  kind := .array (arrOf PRE_first_tail_x15_r0_body.s0 2673467 ++ (arrOf PRE_first_tail_x15_r0_body.s500 2673467).drop (arrOf PRE_first_tail_x15_r0_body.s0 2673467).length) })
kernel_rfl PRE_first_tail_x15_r0_body.zw56_4910 : (PRE_first_tail_x15_r0_body.s501.heap.get 4910).isSome = true
kernel_rfl PRE_first_tail_x15_r0_body.zw56_2673472 : (PRE_first_tail_x15_r0_body.s501.heap.get 2673472).isSome = true
kernel_rfl PRE_first_tail_x15_r0_body.zw56_2673473 : (PRE_first_tail_x15_r0_body.s501.heap.get 2673473).isSome = true
-- the heap: the changed list in range, holding the stage's written and fresh addresses; the canonical side's image
kernel_rfl PRE_first_tail_x15_r0_body.zclbd56 : PRE_first_tail_x15_r0_body.cl56.all (fun b => Nat.blt (b / 4096) (4 ^ 31)) = true
kernel_rfl PRE_first_tail_x15_r0_body.zwr56 : PRE_first_tail_x15_r0_body.st56.wr.all (fun b => !Nat.blt b PRE_first_tail_x15_r0_body.s499.next || PRE_first_tail_x15_r0_body.cl56.contains b) = true
def PRE_first_tail_x15_r0_body.zl56 : List Nat := PRE_first_tail_x15_r0_body.cl56.filter fun a => !(List.contains [2665, 2673467] a)
kernel_rfl PRE_first_tail_x15_r0_body.zimgE56 : PRE_first_tail_x15_r0_body.zl56.map (fun a => PRE_first_tail_x15_r0_body.s500.heap.get (PRE_first_tail_x15_r0_body.kappa56.a a)) = PRE_first_tail_x15_r0_body.zl56.map (fun a => (PRE_first_tail_x15_r0_body.s501.heap.get a).map PRE_first_tail_x15_r0_body.kappa56.hobj)
theorem PRE_first_tail_x15_r0_body.zimg56 : HeapImg PRE_first_tail_x15_r0_body.kappa56 PRE_first_tail_x15_r0_body.s501 PRE_first_tail_x15_r0_body.s500 PRE_first_tail_x15_r0_body.zl56 := PRE_first_tail_x15_r0_body.zimgE56
-- the roots and their supports
kernel_rfl PRE_first_tail_x15_r0_body.zctl56 : PRE_first_tail_x15_r0_body.s500.ctl = PRE_first_tail_x15_r0_body.kappa56.ctl PRE_first_tail_x15_r0_body.s501.ctl
kernel_rfl PRE_first_tail_x15_r0_body.zstack56 : PRE_first_tail_x15_r0_body.s500.stack = PRE_first_tail_x15_r0_body.s501.stack.map PRE_first_tail_x15_r0_body.kappa56.frame
kernel_rfl PRE_first_tail_x15_r0_body.zjobs56 : PRE_first_tail_x15_r0_body.s500.jobs = PRE_first_tail_x15_r0_body.s501.jobs.map PRE_first_tail_x15_r0_body.kappa56.job
kernel_rfl PRE_first_tail_x15_r0_body.zstores56 : PRE_first_tail_x15_r0_body.s500.stores = PRE_first_tail_x15_r0_body.kappa56.stores PRE_first_tail_x15_r0_body.s501.stores
kernel_rfl PRE_first_tail_x15_r0_body.zroots56 : checkRootsSupp PRE_first_tail_x15_r0_body.s501 2449 = true
kernel_rfl PRE_first_tail_x15_r0_body.znC56 : PRE_first_tail_x15_r0_body.S499.tab.length + PRE_first_tail_x15_r0_body.cws56.length = 2449
-- the map as `Conv.compact_shift` states it (the call's counters for the literals)
kernel_rfl PRE_first_tail_x15_r0_body.zkap56 : PRE_first_tail_x15_r0_body.kappa56 = Conv.Map.compact PRE_first_tail_x15_r0_body.s499.next 2718447 PRE_first_tail_x15_r0_body.S499.tab.length PRE_first_tail_x15_r0_body.pl56 (PRE_first_tail_x15_r0_body.nr56.map NumV.ref) PRE_first_tail_x15_r0_body.kd56.big
  PRE_first_tail_x15_r0_body.kd56.region PRE_first_tail_x15_r0_body.kd56.nodeF
-- the bridge inactive at the canonical state (`Conv.FullShiftQ.toX`; the merged state's bridge is the canonical's: cbridge)
theorem PRE_first_tail_x15_r0_body.zbin56 : (Host.Ts.Sim.Full.bridgeOf PRE_first_tail_x15_r0_body.s501.ffi).active = false := (Host.Load.Boot.replay_active Host.Load.Run.Prompt.P.oblog2818)
-- the JS bookkeeping's step (`Conv.JClean.step` over the changed list) and the canonical roots' bigint freedom
kernel_rfl PRE_first_tail_x15_r0_body.zjc56 : Conv.jcleanListB (⟨19297, 16396, 2718428, 2449⟩ : Conv.Cnt) PRE_first_tail_x15_r0_body.s501 PRE_first_tail_x15_r0_body.cl56 = true
kernel_rfl PRE_first_tail_x15_r0_body.zroots256 : noBigRootsP (fun i => !Conv.oldBigB (⟨19297, 16396, 2718428, 2449⟩ : Conv.Cnt) i) PRE_first_tail_x15_r0_body.s501.trace PRE_first_tail_x15_r0_body.s501 = true
kernel_rfl PRE_first_tail_x15_r0_body.zhm56 : Nat.ble (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s0.ffi).mlx.nnext 16396 = true
theorem PRE_first_tail_x15_r0_body.cjcl56 (h : Conv.JClean (⟨19297, 16396, 2718427, 2449⟩ : Conv.Cnt) PRE_first_tail_x15_r0_body.s499) : Conv.JClean (⟨19297, 16396, 2718428, 2449⟩ : Conv.Cnt) PRE_first_tail_x15_r0_body.s501 :=
  Conv.JClean.step h (Conv.Cnt.le_of_leB PRE_first_tail_x15_r0_body.cle56)
    (Conv.heap_off_setAll PRE_first_tail_x15_r0_body.cheap56 fun a ha => Nat.blt_eq.mp (List.all_eq_true.mp PRE_first_tail_x15_r0_body.zclbd56 a ha)) PRE_first_tail_x15_r0_body.zjc56

end Host.Load.Run.Tpl
