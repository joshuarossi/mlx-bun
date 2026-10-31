import host.sim.template.a4pre_first_tail_x15_r0_body.SiteS155
import host.sim.template.a4pre_first_tail_x15_r0_body.SiteK155
import host.sim.template.a4pre_first_tail_x15_r0_body.SiteF155
import host.sim.conv.CompactShift
import host.sim.template.Check
import host.sim.BigFreeP
import host.sim.template.CallGen
set_option Elab.async false
namespace Host.Load.Run.Tpl
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
open Host.Ts Host.Ts.Sim Host.Ts.Sim.Template

/-! The compaction's state shift at call site 155 of chain `PRE_first_tail_x15_r0_body` (`Conv.compact_shift`): the call `PRE_first_tail_x15_r0_body.s1494`, the merged
state `PRE_first_tail_x15_r0_body.s1495`, the canonical state `PRE_first_tail_x15_r0_body.s1496`; its frames [2665,2673467,2673472,2673473] (kept arrays [2665,2673467]). -/

-- the map's places and counters
kernel_rfl PRE_first_tail_x15_r0_body.zpl155 : PRE_first_tail_x15_r0_body.pl155.all (Nat.ble PRE_first_tail_x15_r0_body.s1494.next) = true
kernel_rfl PRE_first_tail_x15_r0_body.zplnd155 : nodupT PRE_first_tail_x15_r0_body.pl155 PTrie.nil = true
kernel_rfl PRE_first_tail_x15_r0_body.zn1155 : Nat.ble PRE_first_tail_x15_r0_body.s1494.next 2796396 = true
kernel_rfl PRE_first_tail_x15_r0_body.zfirst155 : Nat.ble aFirst PRE_first_tail_x15_r0_body.s1494.next = true
kernel_rfl PRE_first_tail_x15_r0_body.zscn155 : PRE_first_tail_x15_r0_body.s1496.next = PRE_first_tail_x15_r0_body.s1494.next + PRE_first_tail_x15_r0_body.pl155.length
kernel_rfl PRE_first_tail_x15_r0_body.zsmn155 : PRE_first_tail_x15_r0_body.s1495.next = 2796396
kernel_rfl PRE_first_tail_x15_r0_body.zgrow155 : Nat.ble PRE_first_tail_x15_r0_body.s1496.next PRE_first_tail_x15_r0_body.s1495.next = true
-- the tables
kernel_rfl PRE_first_tail_x15_r0_body.zfresh155 : PRE_first_tail_x15_r0_body.S1494.tab.all (fun e => PRE_first_tail_x15_r0_body.cws155.all fun v => e.noVar v) = true
kernel_rfl PRE_first_tail_x15_r0_body.zcnd155 : nodupT PRE_first_tail_x15_r0_body.cws155 PTrie.nil = true
kernel_rfl PRE_first_tail_x15_r0_body.znrHi155 : PRE_first_tail_x15_r0_body.nr155.all (fun r => Nat.blt r PRE_first_tail_x15_r0_body.S1495.tab.length) = true
-- the frames: every framed address below the call's counter; the kept arrays the chain start's, extended in the merged state
kernel_rfl PRE_first_tail_x15_r0_body.zfrlt155 : [2665, 2673467, 2673472, 2673473].all (fun a => Nat.blt a PRE_first_tail_x15_r0_body.s1494.next) = true
kernel_rfl PRE_first_tail_x15_r0_body.zg155_2665 : PRE_first_tail_x15_r0_body.s1496.heap.get 2665 = some (.obj (objOf PRE_first_tail_x15_r0_body.s1496 2665))
kernel_rfl PRE_first_tail_x15_r0_body.zk155_2665 : (objOf PRE_first_tail_x15_r0_body.s1496 2665).kind = .array (arrOf PRE_first_tail_x15_r0_body.s0 2665)
kernel_rfl PRE_first_tail_x15_r0_body.zm155_2665 : PRE_first_tail_x15_r0_body.s1495.heap.get 2665 = some (.obj { PRE_first_tail_x15_r0_body.kappa155.obj (objOf PRE_first_tail_x15_r0_body.s1496 2665) with
  kind := .array (arrOf PRE_first_tail_x15_r0_body.s0 2665 ++ (arrOf PRE_first_tail_x15_r0_body.s1495 2665).drop (arrOf PRE_first_tail_x15_r0_body.s0 2665).length) })
kernel_rfl PRE_first_tail_x15_r0_body.zg155_2673467 : PRE_first_tail_x15_r0_body.s1496.heap.get 2673467 = some (.obj (objOf PRE_first_tail_x15_r0_body.s1496 2673467))
kernel_rfl PRE_first_tail_x15_r0_body.zk155_2673467 : (objOf PRE_first_tail_x15_r0_body.s1496 2673467).kind = .array (arrOf PRE_first_tail_x15_r0_body.s0 2673467)
kernel_rfl PRE_first_tail_x15_r0_body.zm155_2673467 : PRE_first_tail_x15_r0_body.s1495.heap.get 2673467 = some (.obj { PRE_first_tail_x15_r0_body.kappa155.obj (objOf PRE_first_tail_x15_r0_body.s1496 2673467) with
  kind := .array (arrOf PRE_first_tail_x15_r0_body.s0 2673467 ++ (arrOf PRE_first_tail_x15_r0_body.s1495 2673467).drop (arrOf PRE_first_tail_x15_r0_body.s0 2673467).length) })
kernel_rfl PRE_first_tail_x15_r0_body.zw155_4910 : (PRE_first_tail_x15_r0_body.s1496.heap.get 4910).isSome = true
kernel_rfl PRE_first_tail_x15_r0_body.zw155_2673472 : (PRE_first_tail_x15_r0_body.s1496.heap.get 2673472).isSome = true
kernel_rfl PRE_first_tail_x15_r0_body.zw155_2673473 : (PRE_first_tail_x15_r0_body.s1496.heap.get 2673473).isSome = true
-- the heap: the changed list in range, holding the stage's written and fresh addresses; the canonical side's image
kernel_rfl PRE_first_tail_x15_r0_body.zclbd155 : PRE_first_tail_x15_r0_body.cl155.all (fun b => Nat.blt (b / 4096) (4 ^ 31)) = true
kernel_rfl PRE_first_tail_x15_r0_body.zwr155 : PRE_first_tail_x15_r0_body.st155.wr.all (fun b => !Nat.blt b PRE_first_tail_x15_r0_body.s1494.next || PRE_first_tail_x15_r0_body.cl155.contains b) = true
def PRE_first_tail_x15_r0_body.zl155 : List Nat := PRE_first_tail_x15_r0_body.cl155.filter fun a => !(List.contains [2665, 2673467] a)
kernel_rfl PRE_first_tail_x15_r0_body.zimgE155 : PRE_first_tail_x15_r0_body.zl155.map (fun a => PRE_first_tail_x15_r0_body.s1495.heap.get (PRE_first_tail_x15_r0_body.kappa155.a a)) = PRE_first_tail_x15_r0_body.zl155.map (fun a => (PRE_first_tail_x15_r0_body.s1496.heap.get a).map PRE_first_tail_x15_r0_body.kappa155.hobj)
theorem PRE_first_tail_x15_r0_body.zimg155 : HeapImg PRE_first_tail_x15_r0_body.kappa155 PRE_first_tail_x15_r0_body.s1496 PRE_first_tail_x15_r0_body.s1495 PRE_first_tail_x15_r0_body.zl155 := PRE_first_tail_x15_r0_body.zimgE155
-- the roots and their supports
kernel_rfl PRE_first_tail_x15_r0_body.zctl155 : PRE_first_tail_x15_r0_body.s1495.ctl = PRE_first_tail_x15_r0_body.kappa155.ctl PRE_first_tail_x15_r0_body.s1496.ctl
kernel_rfl PRE_first_tail_x15_r0_body.zstack155 : PRE_first_tail_x15_r0_body.s1495.stack = PRE_first_tail_x15_r0_body.s1496.stack.map PRE_first_tail_x15_r0_body.kappa155.frame
kernel_rfl PRE_first_tail_x15_r0_body.zjobs155 : PRE_first_tail_x15_r0_body.s1495.jobs = PRE_first_tail_x15_r0_body.s1496.jobs.map PRE_first_tail_x15_r0_body.kappa155.job
kernel_rfl PRE_first_tail_x15_r0_body.zstores155 : PRE_first_tail_x15_r0_body.s1495.stores = PRE_first_tail_x15_r0_body.kappa155.stores PRE_first_tail_x15_r0_body.s1496.stores
kernel_rfl PRE_first_tail_x15_r0_body.zroots155 : checkRootsSupp PRE_first_tail_x15_r0_body.s1496 6679 = true
kernel_rfl PRE_first_tail_x15_r0_body.znC155 : PRE_first_tail_x15_r0_body.S1494.tab.length + PRE_first_tail_x15_r0_body.cws155.length = 6679
-- the map as `Conv.compact_shift` states it (the call's counters for the literals)
kernel_rfl PRE_first_tail_x15_r0_body.zkap155 : PRE_first_tail_x15_r0_body.kappa155 = Conv.Map.compact PRE_first_tail_x15_r0_body.s1494.next 2796396 PRE_first_tail_x15_r0_body.S1494.tab.length PRE_first_tail_x15_r0_body.pl155 (PRE_first_tail_x15_r0_body.nr155.map NumV.ref) PRE_first_tail_x15_r0_body.kd155.big
  PRE_first_tail_x15_r0_body.kd155.region PRE_first_tail_x15_r0_body.kd155.nodeF
-- the bridge inactive at the canonical state (`Conv.FullShiftQ.toX`; the merged state's bridge is the canonical's: cbridge)
theorem PRE_first_tail_x15_r0_body.zbin155 : (Host.Ts.Sim.Full.bridgeOf PRE_first_tail_x15_r0_body.s1496.ffi).active = false := (Host.Load.Boot.replay_active Host.Load.Run.Prompt.P.oblog2818)
-- the JS bookkeeping's step (`Conv.JClean.step` over the changed list) and the canonical roots' bigint freedom
kernel_rfl PRE_first_tail_x15_r0_body.zjc155 : Conv.jcleanListB (⟨21249, 18340, 2796386, 6679⟩ : Conv.Cnt) PRE_first_tail_x15_r0_body.s1496 PRE_first_tail_x15_r0_body.cl155 = true
kernel_rfl PRE_first_tail_x15_r0_body.zrootsB155 : noBigRootsP (fun i => !Conv.oldBigB (⟨21249, 18340, 2796386, 6679⟩ : Conv.Cnt) i) PRE_first_tail_x15_r0_body.s1496.trace PRE_first_tail_x15_r0_body.s1496 = true
kernel_rfl PRE_first_tail_x15_r0_body.zhm155 : Nat.ble (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s0.ffi).mlx.nnext 18340 = true
theorem PRE_first_tail_x15_r0_body.cjcl155 (h : Conv.JClean (⟨21249, 18340, 2796385, 6679⟩ : Conv.Cnt) PRE_first_tail_x15_r0_body.s1494) : Conv.JClean (⟨21249, 18340, 2796386, 6679⟩ : Conv.Cnt) PRE_first_tail_x15_r0_body.s1496 :=
  Conv.JClean.step h (Conv.Cnt.le_of_leB PRE_first_tail_x15_r0_body.cle155)
    (Conv.heap_off_setAll PRE_first_tail_x15_r0_body.cheap155 fun a ha => Nat.blt_eq.mp (List.all_eq_true.mp PRE_first_tail_x15_r0_body.zclbd155 a ha)) PRE_first_tail_x15_r0_body.zjc155

end Host.Load.Run.Tpl
