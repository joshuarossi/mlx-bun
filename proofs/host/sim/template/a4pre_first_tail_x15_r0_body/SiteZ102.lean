import host.sim.template.a4pre_first_tail_x15_r0_body.SiteS102
import host.sim.template.a4pre_first_tail_x15_r0_body.SiteK102
import host.sim.template.a4pre_first_tail_x15_r0_body.SiteF102
import host.sim.conv.CompactShift
import host.sim.template.Check
import host.sim.BigFreeP
import host.sim.template.CallGen
set_option Elab.async false
namespace Host.Load.Run.Tpl
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
open Host.Ts Host.Ts.Sim Host.Ts.Sim.Template

/-! The compaction's state shift at call site 102 of chain `PRE_first_tail_x15_r0_body` (`Conv.compact_shift`): the call `PRE_first_tail_x15_r0_body.s908`, the merged
state `PRE_first_tail_x15_r0_body.s909`, the canonical state `PRE_first_tail_x15_r0_body.s910`; its frames [2665,2673467,2673472,2673473] (kept arrays [2665,2673467]). -/

-- the map's places and counters
kernel_rfl PRE_first_tail_x15_r0_body.zpl102 : PRE_first_tail_x15_r0_body.pl102.all (Nat.ble PRE_first_tail_x15_r0_body.s908.next) = true
kernel_rfl PRE_first_tail_x15_r0_body.zplnd102 : nodupT PRE_first_tail_x15_r0_body.pl102 PTrie.nil = true
kernel_rfl PRE_first_tail_x15_r0_body.zn1102 : Nat.ble PRE_first_tail_x15_r0_body.s908.next 2756466 = true
kernel_rfl PRE_first_tail_x15_r0_body.zfirst102 : Nat.ble aFirst PRE_first_tail_x15_r0_body.s908.next = true
kernel_rfl PRE_first_tail_x15_r0_body.zscn102 : PRE_first_tail_x15_r0_body.s910.next = PRE_first_tail_x15_r0_body.s908.next + PRE_first_tail_x15_r0_body.pl102.length
kernel_rfl PRE_first_tail_x15_r0_body.zsmn102 : PRE_first_tail_x15_r0_body.s909.next = 2756466
kernel_rfl PRE_first_tail_x15_r0_body.zgrow102 : Nat.ble PRE_first_tail_x15_r0_body.s910.next PRE_first_tail_x15_r0_body.s909.next = true
-- the tables
kernel_rfl PRE_first_tail_x15_r0_body.zfresh102 : PRE_first_tail_x15_r0_body.S908.tab.all (fun e => PRE_first_tail_x15_r0_body.cws102.all fun v => e.noVar v) = true
kernel_rfl PRE_first_tail_x15_r0_body.zcnd102 : nodupT PRE_first_tail_x15_r0_body.cws102 PTrie.nil = true
kernel_rfl PRE_first_tail_x15_r0_body.znrHi102 : PRE_first_tail_x15_r0_body.nr102.all (fun r => Nat.blt r PRE_first_tail_x15_r0_body.S909.tab.length) = true
-- the frames: every framed address below the call's counter; the kept arrays the chain start's, extended in the merged state
kernel_rfl PRE_first_tail_x15_r0_body.zfrlt102 : [2665, 2673467, 2673472, 2673473].all (fun a => Nat.blt a PRE_first_tail_x15_r0_body.s908.next) = true
kernel_rfl PRE_first_tail_x15_r0_body.zg102_2665 : PRE_first_tail_x15_r0_body.s910.heap.get 2665 = some (.obj (objOf PRE_first_tail_x15_r0_body.s910 2665))
kernel_rfl PRE_first_tail_x15_r0_body.zk102_2665 : (objOf PRE_first_tail_x15_r0_body.s910 2665).kind = .array (arrOf PRE_first_tail_x15_r0_body.s0 2665)
kernel_rfl PRE_first_tail_x15_r0_body.zm102_2665 : PRE_first_tail_x15_r0_body.s909.heap.get 2665 = some (.obj { PRE_first_tail_x15_r0_body.kappa102.obj (objOf PRE_first_tail_x15_r0_body.s910 2665) with
  kind := .array (arrOf PRE_first_tail_x15_r0_body.s0 2665 ++ (arrOf PRE_first_tail_x15_r0_body.s909 2665).drop (arrOf PRE_first_tail_x15_r0_body.s0 2665).length) })
kernel_rfl PRE_first_tail_x15_r0_body.zg102_2673467 : PRE_first_tail_x15_r0_body.s910.heap.get 2673467 = some (.obj (objOf PRE_first_tail_x15_r0_body.s910 2673467))
kernel_rfl PRE_first_tail_x15_r0_body.zk102_2673467 : (objOf PRE_first_tail_x15_r0_body.s910 2673467).kind = .array (arrOf PRE_first_tail_x15_r0_body.s0 2673467)
kernel_rfl PRE_first_tail_x15_r0_body.zm102_2673467 : PRE_first_tail_x15_r0_body.s909.heap.get 2673467 = some (.obj { PRE_first_tail_x15_r0_body.kappa102.obj (objOf PRE_first_tail_x15_r0_body.s910 2673467) with
  kind := .array (arrOf PRE_first_tail_x15_r0_body.s0 2673467 ++ (arrOf PRE_first_tail_x15_r0_body.s909 2673467).drop (arrOf PRE_first_tail_x15_r0_body.s0 2673467).length) })
kernel_rfl PRE_first_tail_x15_r0_body.zw102_4910 : (PRE_first_tail_x15_r0_body.s910.heap.get 4910).isSome = true
kernel_rfl PRE_first_tail_x15_r0_body.zw102_2673472 : (PRE_first_tail_x15_r0_body.s910.heap.get 2673472).isSome = true
kernel_rfl PRE_first_tail_x15_r0_body.zw102_2673473 : (PRE_first_tail_x15_r0_body.s910.heap.get 2673473).isSome = true
-- the heap: the changed list in range, holding the stage's written and fresh addresses; the canonical side's image
kernel_rfl PRE_first_tail_x15_r0_body.zclbd102 : PRE_first_tail_x15_r0_body.cl102.all (fun b => Nat.blt (b / 4096) (4 ^ 31)) = true
kernel_rfl PRE_first_tail_x15_r0_body.zwr102 : PRE_first_tail_x15_r0_body.st102.wr.all (fun b => !Nat.blt b PRE_first_tail_x15_r0_body.s908.next || PRE_first_tail_x15_r0_body.cl102.contains b) = true
def PRE_first_tail_x15_r0_body.zl102 : List Nat := PRE_first_tail_x15_r0_body.cl102.filter fun a => !(List.contains [2665, 2673467] a)
kernel_rfl PRE_first_tail_x15_r0_body.zimgE102 : PRE_first_tail_x15_r0_body.zl102.map (fun a => PRE_first_tail_x15_r0_body.s909.heap.get (PRE_first_tail_x15_r0_body.kappa102.a a)) = PRE_first_tail_x15_r0_body.zl102.map (fun a => (PRE_first_tail_x15_r0_body.s910.heap.get a).map PRE_first_tail_x15_r0_body.kappa102.hobj)
theorem PRE_first_tail_x15_r0_body.zimg102 : HeapImg PRE_first_tail_x15_r0_body.kappa102 PRE_first_tail_x15_r0_body.s910 PRE_first_tail_x15_r0_body.s909 PRE_first_tail_x15_r0_body.zl102 := PRE_first_tail_x15_r0_body.zimgE102
-- the roots and their supports
kernel_rfl PRE_first_tail_x15_r0_body.zctl102 : PRE_first_tail_x15_r0_body.s909.ctl = PRE_first_tail_x15_r0_body.kappa102.ctl PRE_first_tail_x15_r0_body.s910.ctl
kernel_rfl PRE_first_tail_x15_r0_body.zstack102 : PRE_first_tail_x15_r0_body.s909.stack = PRE_first_tail_x15_r0_body.s910.stack.map PRE_first_tail_x15_r0_body.kappa102.frame
kernel_rfl PRE_first_tail_x15_r0_body.zjobs102 : PRE_first_tail_x15_r0_body.s909.jobs = PRE_first_tail_x15_r0_body.s910.jobs.map PRE_first_tail_x15_r0_body.kappa102.job
kernel_rfl PRE_first_tail_x15_r0_body.zstores102 : PRE_first_tail_x15_r0_body.s909.stores = PRE_first_tail_x15_r0_body.kappa102.stores PRE_first_tail_x15_r0_body.s910.stores
kernel_rfl PRE_first_tail_x15_r0_body.zroots102 : checkRootsSupp PRE_first_tail_x15_r0_body.s910 4463 = true
kernel_rfl PRE_first_tail_x15_r0_body.znC102 : PRE_first_tail_x15_r0_body.S908.tab.length + PRE_first_tail_x15_r0_body.cws102.length = 4463
-- the map as `Conv.compact_shift` states it (the call's counters for the literals)
kernel_rfl PRE_first_tail_x15_r0_body.zkap102 : PRE_first_tail_x15_r0_body.kappa102 = Conv.Map.compact PRE_first_tail_x15_r0_body.s908.next 2756466 PRE_first_tail_x15_r0_body.S908.tab.length PRE_first_tail_x15_r0_body.pl102 (PRE_first_tail_x15_r0_body.nr102.map NumV.ref) PRE_first_tail_x15_r0_body.kd102.big
  PRE_first_tail_x15_r0_body.kd102.region PRE_first_tail_x15_r0_body.kd102.nodeF
-- the bridge inactive at the canonical state (`Conv.FullShiftQ.toX`; the merged state's bridge is the canonical's: cbridge)
theorem PRE_first_tail_x15_r0_body.zbin102 : (Host.Ts.Sim.Full.bridgeOf PRE_first_tail_x15_r0_body.s910.ffi).active = false := (Host.Load.Boot.replay_active Host.Load.Run.Prompt.P.oblog2818)
-- the JS bookkeeping's step (`Conv.JClean.step` over the changed list) and the canonical roots' bigint freedom
kernel_rfl PRE_first_tail_x15_r0_body.zjc102 : Conv.jcleanListB (⟨20221, 17327, 2755317, 4463⟩ : Conv.Cnt) PRE_first_tail_x15_r0_body.s910 PRE_first_tail_x15_r0_body.cl102 = true
kernel_rfl PRE_first_tail_x15_r0_body.zroots2102 : noBigRootsP (fun i => !Conv.oldBigB (⟨20221, 17327, 2755317, 4463⟩ : Conv.Cnt) i) PRE_first_tail_x15_r0_body.s910.trace PRE_first_tail_x15_r0_body.s910 = true
kernel_rfl PRE_first_tail_x15_r0_body.zhm102 : Nat.ble (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s0.ffi).mlx.nnext 17300 = true
theorem PRE_first_tail_x15_r0_body.cjcl102 (h : Conv.JClean (⟨20218, 17300, 2755311, 4445⟩ : Conv.Cnt) PRE_first_tail_x15_r0_body.s908) : Conv.JClean (⟨20221, 17327, 2755317, 4463⟩ : Conv.Cnt) PRE_first_tail_x15_r0_body.s910 :=
  Conv.JClean.step h (Conv.Cnt.le_of_leB PRE_first_tail_x15_r0_body.cle102)
    (Conv.heap_off_setAll PRE_first_tail_x15_r0_body.cheap102 fun a ha => Nat.blt_eq.mp (List.all_eq_true.mp PRE_first_tail_x15_r0_body.zclbd102 a ha)) PRE_first_tail_x15_r0_body.zjc102

end Host.Load.Run.Tpl
