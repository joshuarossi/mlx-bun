import host.sim.template.a4pre_first_tail_x15_r0_body.SiteS74
import host.sim.template.a4pre_first_tail_x15_r0_body.SiteK74
import host.sim.template.a4pre_first_tail_x15_r0_body.SiteF74
import host.sim.conv.CompactShift
import host.sim.template.Check
import host.sim.BigFreeP
import host.sim.template.CallGen
set_option Elab.async false
namespace Host.Load.Run.Tpl
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
open Host.Ts Host.Ts.Sim Host.Ts.Sim.Template

/-! The compaction's state shift at call site 74 of chain `PRE_first_tail_x15_r0_body` (`Conv.compact_shift`): the call `PRE_first_tail_x15_r0_body.s718`, the merged
state `PRE_first_tail_x15_r0_body.s719`, the canonical state `PRE_first_tail_x15_r0_body.s720`; its frames [2665,2673467,2673472,2673473] (kept arrays [2665,2673467]). -/

-- the map's places and counters
kernel_rfl PRE_first_tail_x15_r0_body.zpl74 : PRE_first_tail_x15_r0_body.pl74.all (Nat.ble PRE_first_tail_x15_r0_body.s718.next) = true
kernel_rfl PRE_first_tail_x15_r0_body.zplnd74 : nodupT PRE_first_tail_x15_r0_body.pl74 PTrie.nil = true
kernel_rfl PRE_first_tail_x15_r0_body.zn174 : Nat.ble PRE_first_tail_x15_r0_body.s718.next 2732754 = true
kernel_rfl PRE_first_tail_x15_r0_body.zfirst74 : Nat.ble aFirst PRE_first_tail_x15_r0_body.s718.next = true
kernel_rfl PRE_first_tail_x15_r0_body.zscn74 : PRE_first_tail_x15_r0_body.s720.next = PRE_first_tail_x15_r0_body.s718.next + PRE_first_tail_x15_r0_body.pl74.length
kernel_rfl PRE_first_tail_x15_r0_body.zsmn74 : PRE_first_tail_x15_r0_body.s719.next = 2732754
kernel_rfl PRE_first_tail_x15_r0_body.zgrow74 : Nat.ble PRE_first_tail_x15_r0_body.s720.next PRE_first_tail_x15_r0_body.s719.next = true
-- the tables
kernel_rfl PRE_first_tail_x15_r0_body.zfresh74 : PRE_first_tail_x15_r0_body.S718.tab.all (fun e => PRE_first_tail_x15_r0_body.cws74.all fun v => e.noVar v) = true
kernel_rfl PRE_first_tail_x15_r0_body.zcnd74 : nodupT PRE_first_tail_x15_r0_body.cws74 PTrie.nil = true
kernel_rfl PRE_first_tail_x15_r0_body.znrHi74 : PRE_first_tail_x15_r0_body.nr74.all (fun r => Nat.blt r PRE_first_tail_x15_r0_body.S719.tab.length) = true
-- the frames: every framed address below the call's counter; the kept arrays the chain start's, extended in the merged state
kernel_rfl PRE_first_tail_x15_r0_body.zfrlt74 : [2665, 2673467, 2673472, 2673473].all (fun a => Nat.blt a PRE_first_tail_x15_r0_body.s718.next) = true
kernel_rfl PRE_first_tail_x15_r0_body.zg74_2665 : PRE_first_tail_x15_r0_body.s720.heap.get 2665 = some (.obj (objOf PRE_first_tail_x15_r0_body.s720 2665))
kernel_rfl PRE_first_tail_x15_r0_body.zk74_2665 : (objOf PRE_first_tail_x15_r0_body.s720 2665).kind = .array (arrOf PRE_first_tail_x15_r0_body.s0 2665)
kernel_rfl PRE_first_tail_x15_r0_body.zm74_2665 : PRE_first_tail_x15_r0_body.s719.heap.get 2665 = some (.obj { PRE_first_tail_x15_r0_body.kappa74.obj (objOf PRE_first_tail_x15_r0_body.s720 2665) with
  kind := .array (arrOf PRE_first_tail_x15_r0_body.s0 2665 ++ (arrOf PRE_first_tail_x15_r0_body.s719 2665).drop (arrOf PRE_first_tail_x15_r0_body.s0 2665).length) })
kernel_rfl PRE_first_tail_x15_r0_body.zg74_2673467 : PRE_first_tail_x15_r0_body.s720.heap.get 2673467 = some (.obj (objOf PRE_first_tail_x15_r0_body.s720 2673467))
kernel_rfl PRE_first_tail_x15_r0_body.zk74_2673467 : (objOf PRE_first_tail_x15_r0_body.s720 2673467).kind = .array (arrOf PRE_first_tail_x15_r0_body.s0 2673467)
kernel_rfl PRE_first_tail_x15_r0_body.zm74_2673467 : PRE_first_tail_x15_r0_body.s719.heap.get 2673467 = some (.obj { PRE_first_tail_x15_r0_body.kappa74.obj (objOf PRE_first_tail_x15_r0_body.s720 2673467) with
  kind := .array (arrOf PRE_first_tail_x15_r0_body.s0 2673467 ++ (arrOf PRE_first_tail_x15_r0_body.s719 2673467).drop (arrOf PRE_first_tail_x15_r0_body.s0 2673467).length) })
kernel_rfl PRE_first_tail_x15_r0_body.zw74_4910 : (PRE_first_tail_x15_r0_body.s720.heap.get 4910).isSome = true
kernel_rfl PRE_first_tail_x15_r0_body.zw74_2673472 : (PRE_first_tail_x15_r0_body.s720.heap.get 2673472).isSome = true
kernel_rfl PRE_first_tail_x15_r0_body.zw74_2673473 : (PRE_first_tail_x15_r0_body.s720.heap.get 2673473).isSome = true
-- the heap: the changed list in range, holding the stage's written and fresh addresses; the canonical side's image
kernel_rfl PRE_first_tail_x15_r0_body.zclbd74 : PRE_first_tail_x15_r0_body.cl74.all (fun b => Nat.blt (b / 4096) (4 ^ 31)) = true
kernel_rfl PRE_first_tail_x15_r0_body.zwr74 : PRE_first_tail_x15_r0_body.st74.wr.all (fun b => !Nat.blt b PRE_first_tail_x15_r0_body.s718.next || PRE_first_tail_x15_r0_body.cl74.contains b) = true
def PRE_first_tail_x15_r0_body.zl74 : List Nat := PRE_first_tail_x15_r0_body.cl74.filter fun a => !(List.contains [2665, 2673467] a)
kernel_rfl PRE_first_tail_x15_r0_body.zimgE74 : PRE_first_tail_x15_r0_body.zl74.map (fun a => PRE_first_tail_x15_r0_body.s719.heap.get (PRE_first_tail_x15_r0_body.kappa74.a a)) = PRE_first_tail_x15_r0_body.zl74.map (fun a => (PRE_first_tail_x15_r0_body.s720.heap.get a).map PRE_first_tail_x15_r0_body.kappa74.hobj)
theorem PRE_first_tail_x15_r0_body.zimg74 : HeapImg PRE_first_tail_x15_r0_body.kappa74 PRE_first_tail_x15_r0_body.s720 PRE_first_tail_x15_r0_body.s719 PRE_first_tail_x15_r0_body.zl74 := PRE_first_tail_x15_r0_body.zimgE74
-- the roots and their supports
kernel_rfl PRE_first_tail_x15_r0_body.zctl74 : PRE_first_tail_x15_r0_body.s719.ctl = PRE_first_tail_x15_r0_body.kappa74.ctl PRE_first_tail_x15_r0_body.s720.ctl
kernel_rfl PRE_first_tail_x15_r0_body.zstack74 : PRE_first_tail_x15_r0_body.s719.stack = PRE_first_tail_x15_r0_body.s720.stack.map PRE_first_tail_x15_r0_body.kappa74.frame
kernel_rfl PRE_first_tail_x15_r0_body.zjobs74 : PRE_first_tail_x15_r0_body.s719.jobs = PRE_first_tail_x15_r0_body.s720.jobs.map PRE_first_tail_x15_r0_body.kappa74.job
kernel_rfl PRE_first_tail_x15_r0_body.zstores74 : PRE_first_tail_x15_r0_body.s719.stores = PRE_first_tail_x15_r0_body.kappa74.stores PRE_first_tail_x15_r0_body.s720.stores
kernel_rfl PRE_first_tail_x15_r0_body.zroots74 : checkRootsSupp PRE_first_tail_x15_r0_body.s720 3217 = true
kernel_rfl PRE_first_tail_x15_r0_body.znC74 : PRE_first_tail_x15_r0_body.S718.tab.length + PRE_first_tail_x15_r0_body.cws74.length = 3217
-- the map as `Conv.compact_shift` states it (the call's counters for the literals)
kernel_rfl PRE_first_tail_x15_r0_body.zkap74 : PRE_first_tail_x15_r0_body.kappa74 = Conv.Map.compact PRE_first_tail_x15_r0_body.s718.next 2732754 PRE_first_tail_x15_r0_body.S718.tab.length PRE_first_tail_x15_r0_body.pl74 (PRE_first_tail_x15_r0_body.nr74.map NumV.ref) PRE_first_tail_x15_r0_body.kd74.big
  PRE_first_tail_x15_r0_body.kd74.region PRE_first_tail_x15_r0_body.kd74.nodeF
-- the bridge inactive at the canonical state (`Conv.FullShiftQ.toX`; the merged state's bridge is the canonical's: cbridge)
theorem PRE_first_tail_x15_r0_body.zbin74 : (Host.Ts.Sim.Full.bridgeOf PRE_first_tail_x15_r0_body.s720.ffi).active = false := (Host.Load.Boot.replay_active Host.Load.Run.Prompt.P.oblog2818)
-- the JS bookkeeping's step (`Conv.JClean.step` over the changed list) and the canonical roots' bigint freedom
kernel_rfl PRE_first_tail_x15_r0_body.zjc74 : Conv.jcleanListB (⟨19655, 16744, 2732744, 3217⟩ : Conv.Cnt) PRE_first_tail_x15_r0_body.s720 PRE_first_tail_x15_r0_body.cl74 = true
kernel_rfl PRE_first_tail_x15_r0_body.zrootsB74 : noBigRootsP (fun i => !Conv.oldBigB (⟨19655, 16744, 2732744, 3217⟩ : Conv.Cnt) i) PRE_first_tail_x15_r0_body.s720.trace PRE_first_tail_x15_r0_body.s720 = true
kernel_rfl PRE_first_tail_x15_r0_body.zhm74 : Nat.ble (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s0.ffi).mlx.nnext 16744 = true
theorem PRE_first_tail_x15_r0_body.cjcl74 (h : Conv.JClean (⟨19655, 16744, 2732743, 3217⟩ : Conv.Cnt) PRE_first_tail_x15_r0_body.s718) : Conv.JClean (⟨19655, 16744, 2732744, 3217⟩ : Conv.Cnt) PRE_first_tail_x15_r0_body.s720 :=
  Conv.JClean.step h (Conv.Cnt.le_of_leB PRE_first_tail_x15_r0_body.cle74)
    (Conv.heap_off_setAll PRE_first_tail_x15_r0_body.cheap74 fun a ha => Nat.blt_eq.mp (List.all_eq_true.mp PRE_first_tail_x15_r0_body.zclbd74 a ha)) PRE_first_tail_x15_r0_body.zjc74

end Host.Load.Run.Tpl
