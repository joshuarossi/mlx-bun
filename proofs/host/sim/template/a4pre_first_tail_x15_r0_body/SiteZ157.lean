import host.sim.template.a4pre_first_tail_x15_r0_body.SiteS157
import host.sim.template.a4pre_first_tail_x15_r0_body.SiteK157
import host.sim.template.a4pre_first_tail_x15_r0_body.SiteF157
import host.sim.conv.CompactShift
import host.sim.template.Check
import host.sim.BigFreeP
import host.sim.template.CallGen
set_option Elab.async false
namespace Host.Load.Run.Tpl
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
open Host.Ts Host.Ts.Sim Host.Ts.Sim.Template

/-! The compaction's state shift at call site 157 of chain `PRE_first_tail_x15_r0_body` (`Conv.compact_shift`): the call `PRE_first_tail_x15_r0_body.s1386`, the merged
state `PRE_first_tail_x15_r0_body.s1387`, the canonical state `PRE_first_tail_x15_r0_body.s1388`; its frames [2665,2673467,2673472,2673473] (kept arrays [2665,2673467]). -/

-- the map's places and counters
kernel_rfl PRE_first_tail_x15_r0_body.zpl157 : PRE_first_tail_x15_r0_body.pl157.all (Nat.ble PRE_first_tail_x15_r0_body.s1386.next) = true
kernel_rfl PRE_first_tail_x15_r0_body.zplnd157 : nodupT PRE_first_tail_x15_r0_body.pl157 PTrie.nil = true
kernel_rfl PRE_first_tail_x15_r0_body.zn1157 : Nat.ble PRE_first_tail_x15_r0_body.s1386.next 2798377 = true
kernel_rfl PRE_first_tail_x15_r0_body.zfirst157 : Nat.ble aFirst PRE_first_tail_x15_r0_body.s1386.next = true
kernel_rfl PRE_first_tail_x15_r0_body.zscn157 : PRE_first_tail_x15_r0_body.s1388.next = PRE_first_tail_x15_r0_body.s1386.next + PRE_first_tail_x15_r0_body.pl157.length
kernel_rfl PRE_first_tail_x15_r0_body.zsmn157 : PRE_first_tail_x15_r0_body.s1387.next = 2798377
kernel_rfl PRE_first_tail_x15_r0_body.zgrow157 : Nat.ble PRE_first_tail_x15_r0_body.s1388.next PRE_first_tail_x15_r0_body.s1387.next = true
-- the tables
kernel_rfl PRE_first_tail_x15_r0_body.zfresh157 : PRE_first_tail_x15_r0_body.S1386.tab.all (fun e => PRE_first_tail_x15_r0_body.cws157.all fun v => e.noVar v) = true
kernel_rfl PRE_first_tail_x15_r0_body.zcnd157 : nodupT PRE_first_tail_x15_r0_body.cws157 PTrie.nil = true
kernel_rfl PRE_first_tail_x15_r0_body.znrHi157 : PRE_first_tail_x15_r0_body.nr157.all (fun r => Nat.blt r PRE_first_tail_x15_r0_body.S1387.tab.length) = true
-- the frames: every framed address below the call's counter; the kept arrays the chain start's, extended in the merged state
kernel_rfl PRE_first_tail_x15_r0_body.zfrlt157 : [2665, 2673467, 2673472, 2673473].all (fun a => Nat.blt a PRE_first_tail_x15_r0_body.s1386.next) = true
kernel_rfl PRE_first_tail_x15_r0_body.zg157_2665 : PRE_first_tail_x15_r0_body.s1388.heap.get 2665 = some (.obj (objOf PRE_first_tail_x15_r0_body.s1388 2665))
kernel_rfl PRE_first_tail_x15_r0_body.zk157_2665 : (objOf PRE_first_tail_x15_r0_body.s1388 2665).kind = .array (arrOf PRE_first_tail_x15_r0_body.s0 2665)
kernel_rfl PRE_first_tail_x15_r0_body.zm157_2665 : PRE_first_tail_x15_r0_body.s1387.heap.get 2665 = some (.obj { PRE_first_tail_x15_r0_body.kappa157.obj (objOf PRE_first_tail_x15_r0_body.s1388 2665) with
  kind := .array (arrOf PRE_first_tail_x15_r0_body.s0 2665 ++ (arrOf PRE_first_tail_x15_r0_body.s1387 2665).drop (arrOf PRE_first_tail_x15_r0_body.s0 2665).length) })
kernel_rfl PRE_first_tail_x15_r0_body.zg157_2673467 : PRE_first_tail_x15_r0_body.s1388.heap.get 2673467 = some (.obj (objOf PRE_first_tail_x15_r0_body.s1388 2673467))
kernel_rfl PRE_first_tail_x15_r0_body.zk157_2673467 : (objOf PRE_first_tail_x15_r0_body.s1388 2673467).kind = .array (arrOf PRE_first_tail_x15_r0_body.s0 2673467)
kernel_rfl PRE_first_tail_x15_r0_body.zm157_2673467 : PRE_first_tail_x15_r0_body.s1387.heap.get 2673467 = some (.obj { PRE_first_tail_x15_r0_body.kappa157.obj (objOf PRE_first_tail_x15_r0_body.s1388 2673467) with
  kind := .array (arrOf PRE_first_tail_x15_r0_body.s0 2673467 ++ (arrOf PRE_first_tail_x15_r0_body.s1387 2673467).drop (arrOf PRE_first_tail_x15_r0_body.s0 2673467).length) })
kernel_rfl PRE_first_tail_x15_r0_body.zw157_4910 : (PRE_first_tail_x15_r0_body.s1388.heap.get 4910).isSome = true
kernel_rfl PRE_first_tail_x15_r0_body.zw157_2673472 : (PRE_first_tail_x15_r0_body.s1388.heap.get 2673472).isSome = true
kernel_rfl PRE_first_tail_x15_r0_body.zw157_2673473 : (PRE_first_tail_x15_r0_body.s1388.heap.get 2673473).isSome = true
-- the heap: the changed list in range, holding the stage's written and fresh addresses; the canonical side's image
kernel_rfl PRE_first_tail_x15_r0_body.zclbd157 : PRE_first_tail_x15_r0_body.cl157.all (fun b => Nat.blt (b / 4096) (4 ^ 31)) = true
kernel_rfl PRE_first_tail_x15_r0_body.zwr157 : PRE_first_tail_x15_r0_body.st157.wr.all (fun b => !Nat.blt b PRE_first_tail_x15_r0_body.s1386.next || PRE_first_tail_x15_r0_body.cl157.contains b) = true
def PRE_first_tail_x15_r0_body.zl157 : List Nat := PRE_first_tail_x15_r0_body.cl157.filter fun a => !(List.contains [2665, 2673467] a)
kernel_rfl PRE_first_tail_x15_r0_body.zimgE157 : PRE_first_tail_x15_r0_body.zl157.map (fun a => PRE_first_tail_x15_r0_body.s1387.heap.get (PRE_first_tail_x15_r0_body.kappa157.a a)) = PRE_first_tail_x15_r0_body.zl157.map (fun a => (PRE_first_tail_x15_r0_body.s1388.heap.get a).map PRE_first_tail_x15_r0_body.kappa157.hobj)
theorem PRE_first_tail_x15_r0_body.zimg157 : HeapImg PRE_first_tail_x15_r0_body.kappa157 PRE_first_tail_x15_r0_body.s1388 PRE_first_tail_x15_r0_body.s1387 PRE_first_tail_x15_r0_body.zl157 := PRE_first_tail_x15_r0_body.zimgE157
-- the roots and their supports
kernel_rfl PRE_first_tail_x15_r0_body.zctl157 : PRE_first_tail_x15_r0_body.s1387.ctl = PRE_first_tail_x15_r0_body.kappa157.ctl PRE_first_tail_x15_r0_body.s1388.ctl
kernel_rfl PRE_first_tail_x15_r0_body.zstack157 : PRE_first_tail_x15_r0_body.s1387.stack = PRE_first_tail_x15_r0_body.s1388.stack.map PRE_first_tail_x15_r0_body.kappa157.frame
kernel_rfl PRE_first_tail_x15_r0_body.zjobs157 : PRE_first_tail_x15_r0_body.s1387.jobs = PRE_first_tail_x15_r0_body.s1388.jobs.map PRE_first_tail_x15_r0_body.kappa157.job
kernel_rfl PRE_first_tail_x15_r0_body.zstores157 : PRE_first_tail_x15_r0_body.s1387.stores = PRE_first_tail_x15_r0_body.kappa157.stores PRE_first_tail_x15_r0_body.s1388.stores
kernel_rfl PRE_first_tail_x15_r0_body.zroots157 : checkRootsSupp PRE_first_tail_x15_r0_body.s1388 6791 = true
kernel_rfl PRE_first_tail_x15_r0_body.znC157 : PRE_first_tail_x15_r0_body.S1386.tab.length + PRE_first_tail_x15_r0_body.cws157.length = 6791
-- the map as `Conv.compact_shift` states it (the call's counters for the literals)
kernel_rfl PRE_first_tail_x15_r0_body.zkap157 : PRE_first_tail_x15_r0_body.kappa157 = Conv.Map.compact PRE_first_tail_x15_r0_body.s1386.next 2798377 PRE_first_tail_x15_r0_body.S1386.tab.length PRE_first_tail_x15_r0_body.pl157 (PRE_first_tail_x15_r0_body.nr157.map NumV.ref) PRE_first_tail_x15_r0_body.kd157.big
  PRE_first_tail_x15_r0_body.kd157.region PRE_first_tail_x15_r0_body.kd157.nodeF
-- the bridge inactive at the canonical state (`Conv.FullShiftQ.toX`; the merged state's bridge is the canonical's: cbridge)
theorem PRE_first_tail_x15_r0_body.zbin157 : (Host.Ts.Sim.Full.bridgeOf PRE_first_tail_x15_r0_body.s1388.ffi).active = false := (Host.Load.Boot.replay_active Host.Load.Run.Prompt.P.oblog2818)
-- the JS bookkeeping's step (`Conv.JClean.step` over the changed list) and the canonical roots' bigint freedom
kernel_rfl PRE_first_tail_x15_r0_body.zjc157 : Conv.jcleanListB (⟨21300, 18399, 2798375, 6791⟩ : Conv.Cnt) PRE_first_tail_x15_r0_body.s1388 PRE_first_tail_x15_r0_body.cl157 = true
kernel_rfl PRE_first_tail_x15_r0_body.zroots2157 : noBigRootsP (fun i => !Conv.oldBigB (⟨21300, 18399, 2798375, 6791⟩ : Conv.Cnt) i) PRE_first_tail_x15_r0_body.s1388.trace PRE_first_tail_x15_r0_body.s1388 = true
kernel_rfl PRE_first_tail_x15_r0_body.zhm157 : Nat.ble (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s0.ffi).mlx.nnext 18399 = true
theorem PRE_first_tail_x15_r0_body.cjcl157 (h : Conv.JClean (⟨21300, 18399, 2798375, 6791⟩ : Conv.Cnt) PRE_first_tail_x15_r0_body.s1386) : Conv.JClean (⟨21300, 18399, 2798375, 6791⟩ : Conv.Cnt) PRE_first_tail_x15_r0_body.s1388 :=
  Conv.JClean.step h (Conv.Cnt.le_of_leB PRE_first_tail_x15_r0_body.cle157)
    (Conv.heap_off_setAll PRE_first_tail_x15_r0_body.cheap157 fun a ha => Nat.blt_eq.mp (List.all_eq_true.mp PRE_first_tail_x15_r0_body.zclbd157 a ha)) PRE_first_tail_x15_r0_body.zjc157

end Host.Load.Run.Tpl
