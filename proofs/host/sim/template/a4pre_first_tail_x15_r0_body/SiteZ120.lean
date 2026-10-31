import host.sim.template.a4pre_first_tail_x15_r0_body.SiteS120
import host.sim.template.a4pre_first_tail_x15_r0_body.SiteK120
import host.sim.template.a4pre_first_tail_x15_r0_body.SiteF120
import host.sim.conv.CompactShift
import host.sim.template.Check
import host.sim.BigFreeP
import host.sim.template.CallGen
set_option Elab.async false
namespace Host.Load.Run.Tpl
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
open Host.Ts Host.Ts.Sim Host.Ts.Sim.Template

/-! The compaction's state shift at call site 120 of chain `PRE_first_tail_x15_r0_body` (`Conv.compact_shift`): the call `PRE_first_tail_x15_r0_body.s1166`, the merged
state `PRE_first_tail_x15_r0_body.s1167`, the canonical state `PRE_first_tail_x15_r0_body.s1168`; its frames [2665,2673467,2673472,2673473] (kept arrays [2665,2673467]). -/

-- the map's places and counters
kernel_rfl PRE_first_tail_x15_r0_body.zpl120 : PRE_first_tail_x15_r0_body.pl120.all (Nat.ble PRE_first_tail_x15_r0_body.s1166.next) = true
kernel_rfl PRE_first_tail_x15_r0_body.zplnd120 : nodupT PRE_first_tail_x15_r0_body.pl120 PTrie.nil = true
kernel_rfl PRE_first_tail_x15_r0_body.zn1120 : Nat.ble PRE_first_tail_x15_r0_body.s1166.next 2770778 = true
kernel_rfl PRE_first_tail_x15_r0_body.zfirst120 : Nat.ble aFirst PRE_first_tail_x15_r0_body.s1166.next = true
kernel_rfl PRE_first_tail_x15_r0_body.zscn120 : PRE_first_tail_x15_r0_body.s1168.next = PRE_first_tail_x15_r0_body.s1166.next + PRE_first_tail_x15_r0_body.pl120.length
kernel_rfl PRE_first_tail_x15_r0_body.zsmn120 : PRE_first_tail_x15_r0_body.s1167.next = 2770778
kernel_rfl PRE_first_tail_x15_r0_body.zgrow120 : Nat.ble PRE_first_tail_x15_r0_body.s1168.next PRE_first_tail_x15_r0_body.s1167.next = true
-- the tables
kernel_rfl PRE_first_tail_x15_r0_body.zfresh120 : PRE_first_tail_x15_r0_body.S1166.tab.all (fun e => PRE_first_tail_x15_r0_body.cws120.all fun v => e.noVar v) = true
kernel_rfl PRE_first_tail_x15_r0_body.zcnd120 : nodupT PRE_first_tail_x15_r0_body.cws120 PTrie.nil = true
kernel_rfl PRE_first_tail_x15_r0_body.znrHi120 : PRE_first_tail_x15_r0_body.nr120.all (fun r => Nat.blt r PRE_first_tail_x15_r0_body.S1167.tab.length) = true
-- the frames: every framed address below the call's counter; the kept arrays the chain start's, extended in the merged state
kernel_rfl PRE_first_tail_x15_r0_body.zfrlt120 : [2665, 2673467, 2673472, 2673473].all (fun a => Nat.blt a PRE_first_tail_x15_r0_body.s1166.next) = true
kernel_rfl PRE_first_tail_x15_r0_body.zg120_2665 : PRE_first_tail_x15_r0_body.s1168.heap.get 2665 = some (.obj (objOf PRE_first_tail_x15_r0_body.s1168 2665))
kernel_rfl PRE_first_tail_x15_r0_body.zk120_2665 : (objOf PRE_first_tail_x15_r0_body.s1168 2665).kind = .array (arrOf PRE_first_tail_x15_r0_body.s0 2665)
kernel_rfl PRE_first_tail_x15_r0_body.zm120_2665 : PRE_first_tail_x15_r0_body.s1167.heap.get 2665 = some (.obj { PRE_first_tail_x15_r0_body.kappa120.obj (objOf PRE_first_tail_x15_r0_body.s1168 2665) with
  kind := .array (arrOf PRE_first_tail_x15_r0_body.s0 2665 ++ (arrOf PRE_first_tail_x15_r0_body.s1167 2665).drop (arrOf PRE_first_tail_x15_r0_body.s0 2665).length) })
kernel_rfl PRE_first_tail_x15_r0_body.zg120_2673467 : PRE_first_tail_x15_r0_body.s1168.heap.get 2673467 = some (.obj (objOf PRE_first_tail_x15_r0_body.s1168 2673467))
kernel_rfl PRE_first_tail_x15_r0_body.zk120_2673467 : (objOf PRE_first_tail_x15_r0_body.s1168 2673467).kind = .array (arrOf PRE_first_tail_x15_r0_body.s0 2673467)
kernel_rfl PRE_first_tail_x15_r0_body.zm120_2673467 : PRE_first_tail_x15_r0_body.s1167.heap.get 2673467 = some (.obj { PRE_first_tail_x15_r0_body.kappa120.obj (objOf PRE_first_tail_x15_r0_body.s1168 2673467) with
  kind := .array (arrOf PRE_first_tail_x15_r0_body.s0 2673467 ++ (arrOf PRE_first_tail_x15_r0_body.s1167 2673467).drop (arrOf PRE_first_tail_x15_r0_body.s0 2673467).length) })
kernel_rfl PRE_first_tail_x15_r0_body.zw120_4910 : (PRE_first_tail_x15_r0_body.s1168.heap.get 4910).isSome = true
kernel_rfl PRE_first_tail_x15_r0_body.zw120_2673472 : (PRE_first_tail_x15_r0_body.s1168.heap.get 2673472).isSome = true
kernel_rfl PRE_first_tail_x15_r0_body.zw120_2673473 : (PRE_first_tail_x15_r0_body.s1168.heap.get 2673473).isSome = true
-- the heap: the changed list in range, holding the stage's written and fresh addresses; the canonical side's image
kernel_rfl PRE_first_tail_x15_r0_body.zclbd120 : PRE_first_tail_x15_r0_body.cl120.all (fun b => Nat.blt (b / 4096) (4 ^ 31)) = true
kernel_rfl PRE_first_tail_x15_r0_body.zwr120 : PRE_first_tail_x15_r0_body.st120.wr.all (fun b => !Nat.blt b PRE_first_tail_x15_r0_body.s1166.next || PRE_first_tail_x15_r0_body.cl120.contains b) = true
def PRE_first_tail_x15_r0_body.zl120 : List Nat := PRE_first_tail_x15_r0_body.cl120.filter fun a => !(List.contains [2665, 2673467] a)
kernel_rfl PRE_first_tail_x15_r0_body.zimgE120 : PRE_first_tail_x15_r0_body.zl120.map (fun a => PRE_first_tail_x15_r0_body.s1167.heap.get (PRE_first_tail_x15_r0_body.kappa120.a a)) = PRE_first_tail_x15_r0_body.zl120.map (fun a => (PRE_first_tail_x15_r0_body.s1168.heap.get a).map PRE_first_tail_x15_r0_body.kappa120.hobj)
theorem PRE_first_tail_x15_r0_body.zimg120 : HeapImg PRE_first_tail_x15_r0_body.kappa120 PRE_first_tail_x15_r0_body.s1168 PRE_first_tail_x15_r0_body.s1167 PRE_first_tail_x15_r0_body.zl120 := PRE_first_tail_x15_r0_body.zimgE120
-- the roots and their supports
kernel_rfl PRE_first_tail_x15_r0_body.zctl120 : PRE_first_tail_x15_r0_body.s1167.ctl = PRE_first_tail_x15_r0_body.kappa120.ctl PRE_first_tail_x15_r0_body.s1168.ctl
kernel_rfl PRE_first_tail_x15_r0_body.zstack120 : PRE_first_tail_x15_r0_body.s1167.stack = PRE_first_tail_x15_r0_body.s1168.stack.map PRE_first_tail_x15_r0_body.kappa120.frame
kernel_rfl PRE_first_tail_x15_r0_body.zjobs120 : PRE_first_tail_x15_r0_body.s1167.jobs = PRE_first_tail_x15_r0_body.s1168.jobs.map PRE_first_tail_x15_r0_body.kappa120.job
kernel_rfl PRE_first_tail_x15_r0_body.zstores120 : PRE_first_tail_x15_r0_body.s1167.stores = PRE_first_tail_x15_r0_body.kappa120.stores PRE_first_tail_x15_r0_body.s1168.stores
kernel_rfl PRE_first_tail_x15_r0_body.zroots120 : checkRootsSupp PRE_first_tail_x15_r0_body.s1168 5231 = true
kernel_rfl PRE_first_tail_x15_r0_body.znC120 : PRE_first_tail_x15_r0_body.S1166.tab.length + PRE_first_tail_x15_r0_body.cws120.length = 5231
-- the map as `Conv.compact_shift` states it (the call's counters for the literals)
kernel_rfl PRE_first_tail_x15_r0_body.zkap120 : PRE_first_tail_x15_r0_body.kappa120 = Conv.Map.compact PRE_first_tail_x15_r0_body.s1166.next 2770778 PRE_first_tail_x15_r0_body.S1166.tab.length PRE_first_tail_x15_r0_body.pl120 (PRE_first_tail_x15_r0_body.nr120.map NumV.ref) PRE_first_tail_x15_r0_body.kd120.big
  PRE_first_tail_x15_r0_body.kd120.region PRE_first_tail_x15_r0_body.kd120.nodeF
-- the bridge inactive at the canonical state (`Conv.FullShiftQ.toX`; the merged state's bridge is the canonical's: cbridge)
theorem PRE_first_tail_x15_r0_body.zbin120 : (Host.Ts.Sim.Full.bridgeOf PRE_first_tail_x15_r0_body.s1168.ffi).active = false := (Host.Load.Boot.replay_active Host.Load.Run.Prompt.P.oblog2818)
-- the JS bookkeeping's step (`Conv.JClean.step` over the changed list) and the canonical roots' bigint freedom
kernel_rfl PRE_first_tail_x15_r0_body.zjc120 : Conv.jcleanListB (⟨20579, 17675, 2769629, 5231⟩ : Conv.Cnt) PRE_first_tail_x15_r0_body.s1168 PRE_first_tail_x15_r0_body.cl120 = true
kernel_rfl PRE_first_tail_x15_r0_body.zrootsB120 : noBigRootsP (fun i => !Conv.oldBigB (⟨20579, 17675, 2769629, 5231⟩ : Conv.Cnt) i) PRE_first_tail_x15_r0_body.s1168.trace PRE_first_tail_x15_r0_body.s1168 = true
kernel_rfl PRE_first_tail_x15_r0_body.zhm120 : Nat.ble (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s0.ffi).mlx.nnext 17648 = true
theorem PRE_first_tail_x15_r0_body.cjcl120 (h : Conv.JClean (⟨20576, 17648, 2769623, 5213⟩ : Conv.Cnt) PRE_first_tail_x15_r0_body.s1166) : Conv.JClean (⟨20579, 17675, 2769629, 5231⟩ : Conv.Cnt) PRE_first_tail_x15_r0_body.s1168 :=
  Conv.JClean.step h (Conv.Cnt.le_of_leB PRE_first_tail_x15_r0_body.cle120)
    (Conv.heap_off_setAll PRE_first_tail_x15_r0_body.cheap120 fun a ha => Nat.blt_eq.mp (List.all_eq_true.mp PRE_first_tail_x15_r0_body.zclbd120 a ha)) PRE_first_tail_x15_r0_body.zjc120

end Host.Load.Run.Tpl
