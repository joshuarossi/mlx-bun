import host.sim.template.a4pre_first_tail_x15_r0_body.SiteS136
import host.sim.template.a4pre_first_tail_x15_r0_body.SiteK136
import host.sim.template.a4pre_first_tail_x15_r0_body.SiteF136
import host.sim.conv.CompactShift
import host.sim.template.Check
import host.sim.BigFreeP
import host.sim.template.CallGen
set_option Elab.async false
namespace Host.Load.Run.Tpl
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
open Host.Ts Host.Ts.Sim Host.Ts.Sim.Template

/-! The compaction's state shift at call site 136 of chain `PRE_first_tail_x15_r0_body` (`Conv.compact_shift`): the call `PRE_first_tail_x15_r0_body.s1318`, the merged
state `PRE_first_tail_x15_r0_body.s1319`, the canonical state `PRE_first_tail_x15_r0_body.s1320`; its frames [2665,2673467,2673472,2673473] (kept arrays [2665,2673467]). -/

-- the map's places and counters
kernel_rfl PRE_first_tail_x15_r0_body.zpl136 : PRE_first_tail_x15_r0_body.pl136.all (Nat.ble PRE_first_tail_x15_r0_body.s1318.next) = true
kernel_rfl PRE_first_tail_x15_r0_body.zplnd136 : nodupT PRE_first_tail_x15_r0_body.pl136 PTrie.nil = true
kernel_rfl PRE_first_tail_x15_r0_body.zn1136 : Nat.ble PRE_first_tail_x15_r0_body.s1318.next 2781789 = true
kernel_rfl PRE_first_tail_x15_r0_body.zfirst136 : Nat.ble aFirst PRE_first_tail_x15_r0_body.s1318.next = true
kernel_rfl PRE_first_tail_x15_r0_body.zscn136 : PRE_first_tail_x15_r0_body.s1320.next = PRE_first_tail_x15_r0_body.s1318.next + PRE_first_tail_x15_r0_body.pl136.length
kernel_rfl PRE_first_tail_x15_r0_body.zsmn136 : PRE_first_tail_x15_r0_body.s1319.next = 2781789
kernel_rfl PRE_first_tail_x15_r0_body.zgrow136 : Nat.ble PRE_first_tail_x15_r0_body.s1320.next PRE_first_tail_x15_r0_body.s1319.next = true
-- the tables
kernel_rfl PRE_first_tail_x15_r0_body.zfresh136 : PRE_first_tail_x15_r0_body.S1318.tab.all (fun e => PRE_first_tail_x15_r0_body.cws136.all fun v => e.noVar v) = true
kernel_rfl PRE_first_tail_x15_r0_body.zcnd136 : nodupT PRE_first_tail_x15_r0_body.cws136 PTrie.nil = true
kernel_rfl PRE_first_tail_x15_r0_body.znrHi136 : PRE_first_tail_x15_r0_body.nr136.all (fun r => Nat.blt r PRE_first_tail_x15_r0_body.S1319.tab.length) = true
-- the frames: every framed address below the call's counter; the kept arrays the chain start's, extended in the merged state
kernel_rfl PRE_first_tail_x15_r0_body.zfrlt136 : [2665, 2673467, 2673472, 2673473].all (fun a => Nat.blt a PRE_first_tail_x15_r0_body.s1318.next) = true
kernel_rfl PRE_first_tail_x15_r0_body.zg136_2665 : PRE_first_tail_x15_r0_body.s1320.heap.get 2665 = some (.obj (objOf PRE_first_tail_x15_r0_body.s1320 2665))
kernel_rfl PRE_first_tail_x15_r0_body.zk136_2665 : (objOf PRE_first_tail_x15_r0_body.s1320 2665).kind = .array (arrOf PRE_first_tail_x15_r0_body.s0 2665)
kernel_rfl PRE_first_tail_x15_r0_body.zm136_2665 : PRE_first_tail_x15_r0_body.s1319.heap.get 2665 = some (.obj { PRE_first_tail_x15_r0_body.kappa136.obj (objOf PRE_first_tail_x15_r0_body.s1320 2665) with
  kind := .array (arrOf PRE_first_tail_x15_r0_body.s0 2665 ++ (arrOf PRE_first_tail_x15_r0_body.s1319 2665).drop (arrOf PRE_first_tail_x15_r0_body.s0 2665).length) })
kernel_rfl PRE_first_tail_x15_r0_body.zg136_2673467 : PRE_first_tail_x15_r0_body.s1320.heap.get 2673467 = some (.obj (objOf PRE_first_tail_x15_r0_body.s1320 2673467))
kernel_rfl PRE_first_tail_x15_r0_body.zk136_2673467 : (objOf PRE_first_tail_x15_r0_body.s1320 2673467).kind = .array (arrOf PRE_first_tail_x15_r0_body.s0 2673467)
kernel_rfl PRE_first_tail_x15_r0_body.zm136_2673467 : PRE_first_tail_x15_r0_body.s1319.heap.get 2673467 = some (.obj { PRE_first_tail_x15_r0_body.kappa136.obj (objOf PRE_first_tail_x15_r0_body.s1320 2673467) with
  kind := .array (arrOf PRE_first_tail_x15_r0_body.s0 2673467 ++ (arrOf PRE_first_tail_x15_r0_body.s1319 2673467).drop (arrOf PRE_first_tail_x15_r0_body.s0 2673467).length) })
kernel_rfl PRE_first_tail_x15_r0_body.zw136_4910 : (PRE_first_tail_x15_r0_body.s1320.heap.get 4910).isSome = true
kernel_rfl PRE_first_tail_x15_r0_body.zw136_2673472 : (PRE_first_tail_x15_r0_body.s1320.heap.get 2673472).isSome = true
kernel_rfl PRE_first_tail_x15_r0_body.zw136_2673473 : (PRE_first_tail_x15_r0_body.s1320.heap.get 2673473).isSome = true
-- the heap: the changed list in range, holding the stage's written and fresh addresses; the canonical side's image
kernel_rfl PRE_first_tail_x15_r0_body.zclbd136 : PRE_first_tail_x15_r0_body.cl136.all (fun b => Nat.blt (b / 4096) (4 ^ 31)) = true
kernel_rfl PRE_first_tail_x15_r0_body.zwr136 : PRE_first_tail_x15_r0_body.st136.wr.all (fun b => !Nat.blt b PRE_first_tail_x15_r0_body.s1318.next || PRE_first_tail_x15_r0_body.cl136.contains b) = true
def PRE_first_tail_x15_r0_body.zl136 : List Nat := PRE_first_tail_x15_r0_body.cl136.filter fun a => !(List.contains [2665, 2673467] a)
kernel_rfl PRE_first_tail_x15_r0_body.zimgE136 : PRE_first_tail_x15_r0_body.zl136.map (fun a => PRE_first_tail_x15_r0_body.s1319.heap.get (PRE_first_tail_x15_r0_body.kappa136.a a)) = PRE_first_tail_x15_r0_body.zl136.map (fun a => (PRE_first_tail_x15_r0_body.s1320.heap.get a).map PRE_first_tail_x15_r0_body.kappa136.hobj)
theorem PRE_first_tail_x15_r0_body.zimg136 : HeapImg PRE_first_tail_x15_r0_body.kappa136 PRE_first_tail_x15_r0_body.s1320 PRE_first_tail_x15_r0_body.s1319 PRE_first_tail_x15_r0_body.zl136 := PRE_first_tail_x15_r0_body.zimgE136
-- the roots and their supports
kernel_rfl PRE_first_tail_x15_r0_body.zctl136 : PRE_first_tail_x15_r0_body.s1319.ctl = PRE_first_tail_x15_r0_body.kappa136.ctl PRE_first_tail_x15_r0_body.s1320.ctl
kernel_rfl PRE_first_tail_x15_r0_body.zstack136 : PRE_first_tail_x15_r0_body.s1319.stack = PRE_first_tail_x15_r0_body.s1320.stack.map PRE_first_tail_x15_r0_body.kappa136.frame
kernel_rfl PRE_first_tail_x15_r0_body.zjobs136 : PRE_first_tail_x15_r0_body.s1319.jobs = PRE_first_tail_x15_r0_body.s1320.jobs.map PRE_first_tail_x15_r0_body.kappa136.job
kernel_rfl PRE_first_tail_x15_r0_body.zstores136 : PRE_first_tail_x15_r0_body.s1319.stores = PRE_first_tail_x15_r0_body.kappa136.stores PRE_first_tail_x15_r0_body.s1320.stores
kernel_rfl PRE_first_tail_x15_r0_body.zroots136 : checkRootsSupp PRE_first_tail_x15_r0_body.s1320 5894 = true
kernel_rfl PRE_first_tail_x15_r0_body.znC136 : PRE_first_tail_x15_r0_body.S1318.tab.length + PRE_first_tail_x15_r0_body.cws136.length = 5894
-- the map as `Conv.compact_shift` states it (the call's counters for the literals)
kernel_rfl PRE_first_tail_x15_r0_body.zkap136 : PRE_first_tail_x15_r0_body.kappa136 = Conv.Map.compact PRE_first_tail_x15_r0_body.s1318.next 2781789 PRE_first_tail_x15_r0_body.S1318.tab.length PRE_first_tail_x15_r0_body.pl136 (PRE_first_tail_x15_r0_body.nr136.map NumV.ref) PRE_first_tail_x15_r0_body.kd136.big
  PRE_first_tail_x15_r0_body.kd136.region PRE_first_tail_x15_r0_body.kd136.nodeF
-- the bridge inactive at the canonical state (`Conv.FullShiftQ.toX`; the merged state's bridge is the canonical's: cbridge)
theorem PRE_first_tail_x15_r0_body.zbin136 : (Host.Ts.Sim.Full.bridgeOf PRE_first_tail_x15_r0_body.s1320.ffi).active = false := (Host.Load.Boot.replay_active Host.Load.Run.Prompt.P.oblog2818)
-- the JS bookkeeping's step (`Conv.JClean.step` over the changed list) and the canonical roots' bigint freedom
kernel_rfl PRE_first_tail_x15_r0_body.zjc136 : Conv.jcleanListB (⟨20885, 17988, 2781787, 5894⟩ : Conv.Cnt) PRE_first_tail_x15_r0_body.s1320 PRE_first_tail_x15_r0_body.cl136 = true
kernel_rfl PRE_first_tail_x15_r0_body.zrootsB136 : noBigRootsP (fun i => !Conv.oldBigB (⟨20885, 17988, 2781787, 5894⟩ : Conv.Cnt) i) PRE_first_tail_x15_r0_body.s1320.trace PRE_first_tail_x15_r0_body.s1320 = true
kernel_rfl PRE_first_tail_x15_r0_body.zhm136 : Nat.ble (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s0.ffi).mlx.nnext 17988 = true
theorem PRE_first_tail_x15_r0_body.cjcl136 (h : Conv.JClean (⟨20885, 17988, 2781787, 5894⟩ : Conv.Cnt) PRE_first_tail_x15_r0_body.s1318) : Conv.JClean (⟨20885, 17988, 2781787, 5894⟩ : Conv.Cnt) PRE_first_tail_x15_r0_body.s1320 :=
  Conv.JClean.step h (Conv.Cnt.le_of_leB PRE_first_tail_x15_r0_body.cle136)
    (Conv.heap_off_setAll PRE_first_tail_x15_r0_body.cheap136 fun a ha => Nat.blt_eq.mp (List.all_eq_true.mp PRE_first_tail_x15_r0_body.zclbd136 a ha)) PRE_first_tail_x15_r0_body.zjc136

end Host.Load.Run.Tpl
