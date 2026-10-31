import host.sim.template.a4pre_first_tail_x15_r0_body.SiteS8
import host.sim.template.a4pre_first_tail_x15_r0_body.SiteK8
import host.sim.template.a4pre_first_tail_x15_r0_body.SiteF8
import host.sim.conv.CompactShift
import host.sim.template.Check
import host.sim.BigFreeP
import host.sim.template.CallGen
set_option Elab.async false
namespace Host.Load.Run.Tpl
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
open Host.Ts Host.Ts.Sim Host.Ts.Sim.Template

/-! The compaction's state shift at call site 8 of chain `PRE_first_tail_x15_r0_body` (`Conv.compact_shift`): the call `PRE_first_tail_x15_r0_body.s86`, the merged
state `PRE_first_tail_x15_r0_body.s87`, the canonical state `PRE_first_tail_x15_r0_body.s88`; its frames [2665,2673467,2673472,2673473] (kept arrays [2665,2673467]). -/

-- the map's places and counters
kernel_rfl PRE_first_tail_x15_r0_body.zpl8 : PRE_first_tail_x15_r0_body.pl8.all (Nat.ble PRE_first_tail_x15_r0_body.s86.next) = true
kernel_rfl PRE_first_tail_x15_r0_body.zplnd8 : nodupT PRE_first_tail_x15_r0_body.pl8 PTrie.nil = true
kernel_rfl PRE_first_tail_x15_r0_body.zn18 : Nat.ble PRE_first_tail_x15_r0_body.s86.next 2680768 = true
kernel_rfl PRE_first_tail_x15_r0_body.zfirst8 : Nat.ble aFirst PRE_first_tail_x15_r0_body.s86.next = true
kernel_rfl PRE_first_tail_x15_r0_body.zscn8 : PRE_first_tail_x15_r0_body.s88.next = PRE_first_tail_x15_r0_body.s86.next + PRE_first_tail_x15_r0_body.pl8.length
kernel_rfl PRE_first_tail_x15_r0_body.zsmn8 : PRE_first_tail_x15_r0_body.s87.next = 2680768
kernel_rfl PRE_first_tail_x15_r0_body.zgrow8 : Nat.ble PRE_first_tail_x15_r0_body.s88.next PRE_first_tail_x15_r0_body.s87.next = true
-- the tables
kernel_rfl PRE_first_tail_x15_r0_body.zfresh8 : PRE_first_tail_x15_r0_body.S86.tab.all (fun e => PRE_first_tail_x15_r0_body.cws8.all fun v => e.noVar v) = true
kernel_rfl PRE_first_tail_x15_r0_body.zcnd8 : nodupT PRE_first_tail_x15_r0_body.cws8 PTrie.nil = true
kernel_rfl PRE_first_tail_x15_r0_body.znrHi8 : PRE_first_tail_x15_r0_body.nr8.all (fun r => Nat.blt r PRE_first_tail_x15_r0_body.S87.tab.length) = true
-- the frames: every framed address below the call's counter; the kept arrays the chain start's, extended in the merged state
kernel_rfl PRE_first_tail_x15_r0_body.zfrlt8 : [2665, 2673467, 2673472, 2673473].all (fun a => Nat.blt a PRE_first_tail_x15_r0_body.s86.next) = true
kernel_rfl PRE_first_tail_x15_r0_body.zg8_2665 : PRE_first_tail_x15_r0_body.s88.heap.get 2665 = some (.obj (objOf PRE_first_tail_x15_r0_body.s88 2665))
kernel_rfl PRE_first_tail_x15_r0_body.zk8_2665 : (objOf PRE_first_tail_x15_r0_body.s88 2665).kind = .array (arrOf PRE_first_tail_x15_r0_body.s0 2665)
kernel_rfl PRE_first_tail_x15_r0_body.zm8_2665 : PRE_first_tail_x15_r0_body.s87.heap.get 2665 = some (.obj { PRE_first_tail_x15_r0_body.kappa8.obj (objOf PRE_first_tail_x15_r0_body.s88 2665) with
  kind := .array (arrOf PRE_first_tail_x15_r0_body.s0 2665 ++ (arrOf PRE_first_tail_x15_r0_body.s87 2665).drop (arrOf PRE_first_tail_x15_r0_body.s0 2665).length) })
kernel_rfl PRE_first_tail_x15_r0_body.zg8_2673467 : PRE_first_tail_x15_r0_body.s88.heap.get 2673467 = some (.obj (objOf PRE_first_tail_x15_r0_body.s88 2673467))
kernel_rfl PRE_first_tail_x15_r0_body.zk8_2673467 : (objOf PRE_first_tail_x15_r0_body.s88 2673467).kind = .array (arrOf PRE_first_tail_x15_r0_body.s0 2673467)
kernel_rfl PRE_first_tail_x15_r0_body.zm8_2673467 : PRE_first_tail_x15_r0_body.s87.heap.get 2673467 = some (.obj { PRE_first_tail_x15_r0_body.kappa8.obj (objOf PRE_first_tail_x15_r0_body.s88 2673467) with
  kind := .array (arrOf PRE_first_tail_x15_r0_body.s0 2673467 ++ (arrOf PRE_first_tail_x15_r0_body.s87 2673467).drop (arrOf PRE_first_tail_x15_r0_body.s0 2673467).length) })
kernel_rfl PRE_first_tail_x15_r0_body.zw8_4910 : (PRE_first_tail_x15_r0_body.s88.heap.get 4910).isSome = true
kernel_rfl PRE_first_tail_x15_r0_body.zw8_2673472 : (PRE_first_tail_x15_r0_body.s88.heap.get 2673472).isSome = true
kernel_rfl PRE_first_tail_x15_r0_body.zw8_2673473 : (PRE_first_tail_x15_r0_body.s88.heap.get 2673473).isSome = true
-- the heap: the changed list in range, holding the stage's written and fresh addresses; the canonical side's image
kernel_rfl PRE_first_tail_x15_r0_body.zclbd8 : PRE_first_tail_x15_r0_body.cl8.all (fun b => Nat.blt (b / 4096) (4 ^ 31)) = true
kernel_rfl PRE_first_tail_x15_r0_body.zwr8 : PRE_first_tail_x15_r0_body.st8.wr.all (fun b => !Nat.blt b PRE_first_tail_x15_r0_body.s86.next || PRE_first_tail_x15_r0_body.cl8.contains b) = true
def PRE_first_tail_x15_r0_body.zl8 : List Nat := PRE_first_tail_x15_r0_body.cl8.filter fun a => !(List.contains [2665, 2673467] a)
kernel_rfl PRE_first_tail_x15_r0_body.zimgE8 : PRE_first_tail_x15_r0_body.zl8.map (fun a => PRE_first_tail_x15_r0_body.s87.heap.get (PRE_first_tail_x15_r0_body.kappa8.a a)) = PRE_first_tail_x15_r0_body.zl8.map (fun a => (PRE_first_tail_x15_r0_body.s88.heap.get a).map PRE_first_tail_x15_r0_body.kappa8.hobj)
theorem PRE_first_tail_x15_r0_body.zimg8 : HeapImg PRE_first_tail_x15_r0_body.kappa8 PRE_first_tail_x15_r0_body.s88 PRE_first_tail_x15_r0_body.s87 PRE_first_tail_x15_r0_body.zl8 := PRE_first_tail_x15_r0_body.zimgE8
-- the roots and their supports
kernel_rfl PRE_first_tail_x15_r0_body.zctl8 : PRE_first_tail_x15_r0_body.s87.ctl = PRE_first_tail_x15_r0_body.kappa8.ctl PRE_first_tail_x15_r0_body.s88.ctl
kernel_rfl PRE_first_tail_x15_r0_body.zstack8 : PRE_first_tail_x15_r0_body.s87.stack = PRE_first_tail_x15_r0_body.s88.stack.map PRE_first_tail_x15_r0_body.kappa8.frame
kernel_rfl PRE_first_tail_x15_r0_body.zjobs8 : PRE_first_tail_x15_r0_body.s87.jobs = PRE_first_tail_x15_r0_body.s88.jobs.map PRE_first_tail_x15_r0_body.kappa8.job
kernel_rfl PRE_first_tail_x15_r0_body.zstores8 : PRE_first_tail_x15_r0_body.s87.stores = PRE_first_tail_x15_r0_body.kappa8.stores PRE_first_tail_x15_r0_body.s88.stores
kernel_rfl PRE_first_tail_x15_r0_body.zroots8 : checkRootsSupp PRE_first_tail_x15_r0_body.s88 397 = true
kernel_rfl PRE_first_tail_x15_r0_body.znC8 : PRE_first_tail_x15_r0_body.S86.tab.length + PRE_first_tail_x15_r0_body.cws8.length = 397
-- the map as `Conv.compact_shift` states it (the call's counters for the literals)
kernel_rfl PRE_first_tail_x15_r0_body.zkap8 : PRE_first_tail_x15_r0_body.kappa8 = Conv.Map.compact PRE_first_tail_x15_r0_body.s86.next 2680768 PRE_first_tail_x15_r0_body.S86.tab.length PRE_first_tail_x15_r0_body.pl8 (PRE_first_tail_x15_r0_body.nr8.map NumV.ref) PRE_first_tail_x15_r0_body.kd8.big
  PRE_first_tail_x15_r0_body.kd8.region PRE_first_tail_x15_r0_body.kd8.nodeF
-- the bridge inactive at the canonical state (`Conv.FullShiftQ.toX`; the merged state's bridge is the canonical's: cbridge)
theorem PRE_first_tail_x15_r0_body.zbin8 : (Host.Ts.Sim.Full.bridgeOf PRE_first_tail_x15_r0_body.s88.ffi).active = false := (Host.Load.Boot.replay_active Host.Load.Run.Prompt.P.oblog2818)
-- the JS bookkeeping's step (`Conv.JClean.step` over the changed list) and the canonical roots' bigint freedom
kernel_rfl PRE_first_tail_x15_r0_body.zjc8 : Conv.jcleanListB (⟨18353, 15448, 2680758, 397⟩ : Conv.Cnt) PRE_first_tail_x15_r0_body.s88 PRE_first_tail_x15_r0_body.cl8 = true
kernel_rfl PRE_first_tail_x15_r0_body.zrootsB8 : noBigRootsP (fun i => !Conv.oldBigB (⟨18353, 15448, 2680758, 397⟩ : Conv.Cnt) i) PRE_first_tail_x15_r0_body.s88.trace PRE_first_tail_x15_r0_body.s88 = true
kernel_rfl PRE_first_tail_x15_r0_body.zhm8 : Nat.ble (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s0.ffi).mlx.nnext 15448 = true
theorem PRE_first_tail_x15_r0_body.cjcl8 (h : Conv.JClean (⟨18353, 15448, 2680757, 397⟩ : Conv.Cnt) PRE_first_tail_x15_r0_body.s86) : Conv.JClean (⟨18353, 15448, 2680758, 397⟩ : Conv.Cnt) PRE_first_tail_x15_r0_body.s88 :=
  Conv.JClean.step h (Conv.Cnt.le_of_leB PRE_first_tail_x15_r0_body.cle8)
    (Conv.heap_off_setAll PRE_first_tail_x15_r0_body.cheap8 fun a ha => Nat.blt_eq.mp (List.all_eq_true.mp PRE_first_tail_x15_r0_body.zclbd8 a ha)) PRE_first_tail_x15_r0_body.zjc8

end Host.Load.Run.Tpl
