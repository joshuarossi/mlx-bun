import host.sim.template.a4pre_first_tail_x15_r0_body.SiteS178
import host.sim.template.a4pre_first_tail_x15_r0_body.SiteK178
import host.sim.template.a4pre_first_tail_x15_r0_body.SiteF178
import host.sim.conv.CompactShift
import host.sim.template.Check
import host.sim.BigFreeP
import host.sim.template.CallGen
set_option Elab.async false
namespace Host.Load.Run.Tpl
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
open Host.Ts Host.Ts.Sim Host.Ts.Sim.Template

/-! The compaction's state shift at call site 178 of chain `PRE_first_tail_x15_r0_body` (`Conv.compact_shift`): the call `PRE_first_tail_x15_r0_body.s1569`, the merged
state `PRE_first_tail_x15_r0_body.s1570`, the canonical state `PRE_first_tail_x15_r0_body.s1571`; its frames [2665,2673467,2673472,2673473] (kept arrays [2665,2673467]). -/

-- the map's places and counters
kernel_rfl PRE_first_tail_x15_r0_body.zpl178 : PRE_first_tail_x15_r0_body.pl178.all (Nat.ble PRE_first_tail_x15_r0_body.s1569.next) = true
kernel_rfl PRE_first_tail_x15_r0_body.zplnd178 : nodupT PRE_first_tail_x15_r0_body.pl178 PTrie.nil = true
kernel_rfl PRE_first_tail_x15_r0_body.zn1178 : Nat.ble PRE_first_tail_x15_r0_body.s1569.next 2814943 = true
kernel_rfl PRE_first_tail_x15_r0_body.zfirst178 : Nat.ble aFirst PRE_first_tail_x15_r0_body.s1569.next = true
kernel_rfl PRE_first_tail_x15_r0_body.zscn178 : PRE_first_tail_x15_r0_body.s1571.next = PRE_first_tail_x15_r0_body.s1569.next + PRE_first_tail_x15_r0_body.pl178.length
kernel_rfl PRE_first_tail_x15_r0_body.zsmn178 : PRE_first_tail_x15_r0_body.s1570.next = 2814943
kernel_rfl PRE_first_tail_x15_r0_body.zgrow178 : Nat.ble PRE_first_tail_x15_r0_body.s1571.next PRE_first_tail_x15_r0_body.s1570.next = true
-- the tables
kernel_rfl PRE_first_tail_x15_r0_body.zfresh178 : PRE_first_tail_x15_r0_body.S1569.tab.all (fun e => PRE_first_tail_x15_r0_body.cws178.all fun v => e.noVar v) = true
kernel_rfl PRE_first_tail_x15_r0_body.zcnd178 : nodupT PRE_first_tail_x15_r0_body.cws178 PTrie.nil = true
kernel_rfl PRE_first_tail_x15_r0_body.znrHi178 : PRE_first_tail_x15_r0_body.nr178.all (fun r => Nat.blt r PRE_first_tail_x15_r0_body.S1570.tab.length) = true
-- the frames: every framed address below the call's counter; the kept arrays the chain start's, extended in the merged state
kernel_rfl PRE_first_tail_x15_r0_body.zfrlt178 : [2665, 2673467, 2673472, 2673473].all (fun a => Nat.blt a PRE_first_tail_x15_r0_body.s1569.next) = true
kernel_rfl PRE_first_tail_x15_r0_body.zg178_2665 : PRE_first_tail_x15_r0_body.s1571.heap.get 2665 = some (.obj (objOf PRE_first_tail_x15_r0_body.s1571 2665))
kernel_rfl PRE_first_tail_x15_r0_body.zk178_2665 : (objOf PRE_first_tail_x15_r0_body.s1571 2665).kind = .array (arrOf PRE_first_tail_x15_r0_body.s0 2665)
kernel_rfl PRE_first_tail_x15_r0_body.zm178_2665 : PRE_first_tail_x15_r0_body.s1570.heap.get 2665 = some (.obj { PRE_first_tail_x15_r0_body.kappa178.obj (objOf PRE_first_tail_x15_r0_body.s1571 2665) with
  kind := .array (arrOf PRE_first_tail_x15_r0_body.s0 2665 ++ (arrOf PRE_first_tail_x15_r0_body.s1570 2665).drop (arrOf PRE_first_tail_x15_r0_body.s0 2665).length) })
kernel_rfl PRE_first_tail_x15_r0_body.zg178_2673467 : PRE_first_tail_x15_r0_body.s1571.heap.get 2673467 = some (.obj (objOf PRE_first_tail_x15_r0_body.s1571 2673467))
kernel_rfl PRE_first_tail_x15_r0_body.zk178_2673467 : (objOf PRE_first_tail_x15_r0_body.s1571 2673467).kind = .array (arrOf PRE_first_tail_x15_r0_body.s0 2673467)
kernel_rfl PRE_first_tail_x15_r0_body.zm178_2673467 : PRE_first_tail_x15_r0_body.s1570.heap.get 2673467 = some (.obj { PRE_first_tail_x15_r0_body.kappa178.obj (objOf PRE_first_tail_x15_r0_body.s1571 2673467) with
  kind := .array (arrOf PRE_first_tail_x15_r0_body.s0 2673467 ++ (arrOf PRE_first_tail_x15_r0_body.s1570 2673467).drop (arrOf PRE_first_tail_x15_r0_body.s0 2673467).length) })
kernel_rfl PRE_first_tail_x15_r0_body.zw178_4910 : (PRE_first_tail_x15_r0_body.s1571.heap.get 4910).isSome = true
kernel_rfl PRE_first_tail_x15_r0_body.zw178_2673472 : (PRE_first_tail_x15_r0_body.s1571.heap.get 2673472).isSome = true
kernel_rfl PRE_first_tail_x15_r0_body.zw178_2673473 : (PRE_first_tail_x15_r0_body.s1571.heap.get 2673473).isSome = true
-- the heap: the changed list in range, holding the stage's written and fresh addresses; the canonical side's image
kernel_rfl PRE_first_tail_x15_r0_body.zclbd178 : PRE_first_tail_x15_r0_body.cl178.all (fun b => Nat.blt (b / 4096) (4 ^ 31)) = true
kernel_rfl PRE_first_tail_x15_r0_body.zwr178 : PRE_first_tail_x15_r0_body.st178.wr.all (fun b => !Nat.blt b PRE_first_tail_x15_r0_body.s1569.next || PRE_first_tail_x15_r0_body.cl178.contains b) = true
def PRE_first_tail_x15_r0_body.zl178 : List Nat := PRE_first_tail_x15_r0_body.cl178.filter fun a => !(List.contains [2665, 2673467] a)
kernel_rfl PRE_first_tail_x15_r0_body.zimgE178 : PRE_first_tail_x15_r0_body.zl178.map (fun a => PRE_first_tail_x15_r0_body.s1570.heap.get (PRE_first_tail_x15_r0_body.kappa178.a a)) = PRE_first_tail_x15_r0_body.zl178.map (fun a => (PRE_first_tail_x15_r0_body.s1571.heap.get a).map PRE_first_tail_x15_r0_body.kappa178.hobj)
theorem PRE_first_tail_x15_r0_body.zimg178 : HeapImg PRE_first_tail_x15_r0_body.kappa178 PRE_first_tail_x15_r0_body.s1571 PRE_first_tail_x15_r0_body.s1570 PRE_first_tail_x15_r0_body.zl178 := PRE_first_tail_x15_r0_body.zimgE178
-- the roots and their supports
kernel_rfl PRE_first_tail_x15_r0_body.zctl178 : PRE_first_tail_x15_r0_body.s1570.ctl = PRE_first_tail_x15_r0_body.kappa178.ctl PRE_first_tail_x15_r0_body.s1571.ctl
kernel_rfl PRE_first_tail_x15_r0_body.zstack178 : PRE_first_tail_x15_r0_body.s1570.stack = PRE_first_tail_x15_r0_body.s1571.stack.map PRE_first_tail_x15_r0_body.kappa178.frame
kernel_rfl PRE_first_tail_x15_r0_body.zjobs178 : PRE_first_tail_x15_r0_body.s1570.jobs = PRE_first_tail_x15_r0_body.s1571.jobs.map PRE_first_tail_x15_r0_body.kappa178.job
kernel_rfl PRE_first_tail_x15_r0_body.zstores178 : PRE_first_tail_x15_r0_body.s1570.stores = PRE_first_tail_x15_r0_body.kappa178.stores PRE_first_tail_x15_r0_body.s1571.stores
kernel_rfl PRE_first_tail_x15_r0_body.zroots178 : checkRootsSupp PRE_first_tail_x15_r0_body.s1571 7688 = true
kernel_rfl PRE_first_tail_x15_r0_body.znC178 : PRE_first_tail_x15_r0_body.S1569.tab.length + PRE_first_tail_x15_r0_body.cws178.length = 7688
-- the map as `Conv.compact_shift` states it (the call's counters for the literals)
kernel_rfl PRE_first_tail_x15_r0_body.zkap178 : PRE_first_tail_x15_r0_body.kappa178 = Conv.Map.compact PRE_first_tail_x15_r0_body.s1569.next 2814943 PRE_first_tail_x15_r0_body.S1569.tab.length PRE_first_tail_x15_r0_body.pl178 (PRE_first_tail_x15_r0_body.nr178.map NumV.ref) PRE_first_tail_x15_r0_body.kd178.big
  PRE_first_tail_x15_r0_body.kd178.region PRE_first_tail_x15_r0_body.kd178.nodeF
-- the bridge inactive at the canonical state (`Conv.FullShiftQ.toX`; the merged state's bridge is the canonical's: cbridge)
theorem PRE_first_tail_x15_r0_body.zbin178 : (Host.Ts.Sim.Full.bridgeOf PRE_first_tail_x15_r0_body.s1571.ffi).active = false := (Host.Load.Boot.replay_active Host.Load.Run.Prompt.P.oblog2818)
-- the JS bookkeeping's step (`Conv.JClean.step` over the changed list) and the canonical roots' bigint freedom
kernel_rfl PRE_first_tail_x15_r0_body.zjc178 : Conv.jcleanListB (⟨21714, 18810, 2814941, 7688⟩ : Conv.Cnt) PRE_first_tail_x15_r0_body.s1571 PRE_first_tail_x15_r0_body.cl178 = true
kernel_rfl PRE_first_tail_x15_r0_body.zroots2178 : noBigRootsP (fun i => !Conv.oldBigB (⟨21714, 18810, 2814941, 7688⟩ : Conv.Cnt) i) PRE_first_tail_x15_r0_body.s1571.trace PRE_first_tail_x15_r0_body.s1571 = true
kernel_rfl PRE_first_tail_x15_r0_body.zhm178 : Nat.ble (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s0.ffi).mlx.nnext 18810 = true
theorem PRE_first_tail_x15_r0_body.cjcl178 (h : Conv.JClean (⟨21714, 18810, 2814941, 7688⟩ : Conv.Cnt) PRE_first_tail_x15_r0_body.s1569) : Conv.JClean (⟨21714, 18810, 2814941, 7688⟩ : Conv.Cnt) PRE_first_tail_x15_r0_body.s1571 :=
  Conv.JClean.step h (Conv.Cnt.le_of_leB PRE_first_tail_x15_r0_body.cle178)
    (Conv.heap_off_setAll PRE_first_tail_x15_r0_body.cheap178 fun a ha => Nat.blt_eq.mp (List.all_eq_true.mp PRE_first_tail_x15_r0_body.zclbd178 a ha)) PRE_first_tail_x15_r0_body.zjc178

end Host.Load.Run.Tpl
