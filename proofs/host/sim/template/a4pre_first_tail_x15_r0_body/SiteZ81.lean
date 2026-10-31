import host.sim.template.a4pre_first_tail_x15_r0_body.SiteS81
import host.sim.template.a4pre_first_tail_x15_r0_body.SiteK81
import host.sim.template.a4pre_first_tail_x15_r0_body.SiteF81
import host.sim.conv.CompactShift
import host.sim.template.Check
import host.sim.BigFreeP
import host.sim.template.CallGen
set_option Elab.async false
namespace Host.Load.Run.Tpl
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
open Host.Ts Host.Ts.Sim Host.Ts.Sim.Template

/-! The compaction's state shift at call site 81 of chain `PRE_first_tail_x15_r0_body` (`Conv.compact_shift`): the call `PRE_first_tail_x15_r0_body.s722`, the merged
state `PRE_first_tail_x15_r0_body.s723`, the canonical state `PRE_first_tail_x15_r0_body.s724`; its frames [2665,2673467,2673472,2673473] (kept arrays [2665,2673467]). -/

-- the map's places and counters
kernel_rfl PRE_first_tail_x15_r0_body.zpl81 : PRE_first_tail_x15_r0_body.pl81.all (Nat.ble PRE_first_tail_x15_r0_body.s722.next) = true
kernel_rfl PRE_first_tail_x15_r0_body.zplnd81 : nodupT PRE_first_tail_x15_r0_body.pl81 PTrie.nil = true
kernel_rfl PRE_first_tail_x15_r0_body.zn181 : Nat.ble PRE_first_tail_x15_r0_body.s722.next 2739357 = true
kernel_rfl PRE_first_tail_x15_r0_body.zfirst81 : Nat.ble aFirst PRE_first_tail_x15_r0_body.s722.next = true
kernel_rfl PRE_first_tail_x15_r0_body.zscn81 : PRE_first_tail_x15_r0_body.s724.next = PRE_first_tail_x15_r0_body.s722.next + PRE_first_tail_x15_r0_body.pl81.length
kernel_rfl PRE_first_tail_x15_r0_body.zsmn81 : PRE_first_tail_x15_r0_body.s723.next = 2739357
kernel_rfl PRE_first_tail_x15_r0_body.zgrow81 : Nat.ble PRE_first_tail_x15_r0_body.s724.next PRE_first_tail_x15_r0_body.s723.next = true
-- the tables
kernel_rfl PRE_first_tail_x15_r0_body.zfresh81 : PRE_first_tail_x15_r0_body.S722.tab.all (fun e => PRE_first_tail_x15_r0_body.cws81.all fun v => e.noVar v) = true
kernel_rfl PRE_first_tail_x15_r0_body.zcnd81 : nodupT PRE_first_tail_x15_r0_body.cws81 PTrie.nil = true
kernel_rfl PRE_first_tail_x15_r0_body.znrHi81 : PRE_first_tail_x15_r0_body.nr81.all (fun r => Nat.blt r PRE_first_tail_x15_r0_body.S723.tab.length) = true
-- the frames: every framed address below the call's counter; the kept arrays the chain start's, extended in the merged state
kernel_rfl PRE_first_tail_x15_r0_body.zfrlt81 : [2665, 2673467, 2673472, 2673473].all (fun a => Nat.blt a PRE_first_tail_x15_r0_body.s722.next) = true
kernel_rfl PRE_first_tail_x15_r0_body.zg81_2665 : PRE_first_tail_x15_r0_body.s724.heap.get 2665 = some (.obj (objOf PRE_first_tail_x15_r0_body.s724 2665))
kernel_rfl PRE_first_tail_x15_r0_body.zk81_2665 : (objOf PRE_first_tail_x15_r0_body.s724 2665).kind = .array (arrOf PRE_first_tail_x15_r0_body.s0 2665)
kernel_rfl PRE_first_tail_x15_r0_body.zm81_2665 : PRE_first_tail_x15_r0_body.s723.heap.get 2665 = some (.obj { PRE_first_tail_x15_r0_body.kappa81.obj (objOf PRE_first_tail_x15_r0_body.s724 2665) with
  kind := .array (arrOf PRE_first_tail_x15_r0_body.s0 2665 ++ (arrOf PRE_first_tail_x15_r0_body.s723 2665).drop (arrOf PRE_first_tail_x15_r0_body.s0 2665).length) })
kernel_rfl PRE_first_tail_x15_r0_body.zg81_2673467 : PRE_first_tail_x15_r0_body.s724.heap.get 2673467 = some (.obj (objOf PRE_first_tail_x15_r0_body.s724 2673467))
kernel_rfl PRE_first_tail_x15_r0_body.zk81_2673467 : (objOf PRE_first_tail_x15_r0_body.s724 2673467).kind = .array (arrOf PRE_first_tail_x15_r0_body.s0 2673467)
kernel_rfl PRE_first_tail_x15_r0_body.zm81_2673467 : PRE_first_tail_x15_r0_body.s723.heap.get 2673467 = some (.obj { PRE_first_tail_x15_r0_body.kappa81.obj (objOf PRE_first_tail_x15_r0_body.s724 2673467) with
  kind := .array (arrOf PRE_first_tail_x15_r0_body.s0 2673467 ++ (arrOf PRE_first_tail_x15_r0_body.s723 2673467).drop (arrOf PRE_first_tail_x15_r0_body.s0 2673467).length) })
kernel_rfl PRE_first_tail_x15_r0_body.zw81_4910 : (PRE_first_tail_x15_r0_body.s724.heap.get 4910).isSome = true
kernel_rfl PRE_first_tail_x15_r0_body.zw81_2673472 : (PRE_first_tail_x15_r0_body.s724.heap.get 2673472).isSome = true
kernel_rfl PRE_first_tail_x15_r0_body.zw81_2673473 : (PRE_first_tail_x15_r0_body.s724.heap.get 2673473).isSome = true
-- the heap: the changed list in range, holding the stage's written and fresh addresses; the canonical side's image
kernel_rfl PRE_first_tail_x15_r0_body.zclbd81 : PRE_first_tail_x15_r0_body.cl81.all (fun b => Nat.blt (b / 4096) (4 ^ 31)) = true
kernel_rfl PRE_first_tail_x15_r0_body.zwr81 : PRE_first_tail_x15_r0_body.st81.wr.all (fun b => !Nat.blt b PRE_first_tail_x15_r0_body.s722.next || PRE_first_tail_x15_r0_body.cl81.contains b) = true
def PRE_first_tail_x15_r0_body.zl81 : List Nat := PRE_first_tail_x15_r0_body.cl81.filter fun a => !(List.contains [2665, 2673467] a)
kernel_rfl PRE_first_tail_x15_r0_body.zimgE81 : PRE_first_tail_x15_r0_body.zl81.map (fun a => PRE_first_tail_x15_r0_body.s723.heap.get (PRE_first_tail_x15_r0_body.kappa81.a a)) = PRE_first_tail_x15_r0_body.zl81.map (fun a => (PRE_first_tail_x15_r0_body.s724.heap.get a).map PRE_first_tail_x15_r0_body.kappa81.hobj)
theorem PRE_first_tail_x15_r0_body.zimg81 : HeapImg PRE_first_tail_x15_r0_body.kappa81 PRE_first_tail_x15_r0_body.s724 PRE_first_tail_x15_r0_body.s723 PRE_first_tail_x15_r0_body.zl81 := PRE_first_tail_x15_r0_body.zimgE81
-- the roots and their supports
kernel_rfl PRE_first_tail_x15_r0_body.zctl81 : PRE_first_tail_x15_r0_body.s723.ctl = PRE_first_tail_x15_r0_body.kappa81.ctl PRE_first_tail_x15_r0_body.s724.ctl
kernel_rfl PRE_first_tail_x15_r0_body.zstack81 : PRE_first_tail_x15_r0_body.s723.stack = PRE_first_tail_x15_r0_body.s724.stack.map PRE_first_tail_x15_r0_body.kappa81.frame
kernel_rfl PRE_first_tail_x15_r0_body.zjobs81 : PRE_first_tail_x15_r0_body.s723.jobs = PRE_first_tail_x15_r0_body.s724.jobs.map PRE_first_tail_x15_r0_body.kappa81.job
kernel_rfl PRE_first_tail_x15_r0_body.zstores81 : PRE_first_tail_x15_r0_body.s723.stores = PRE_first_tail_x15_r0_body.kappa81.stores PRE_first_tail_x15_r0_body.s724.stores
kernel_rfl PRE_first_tail_x15_r0_body.zroots81 : checkRootsSupp PRE_first_tail_x15_r0_body.s724 3561 = true
kernel_rfl PRE_first_tail_x15_r0_body.znC81 : PRE_first_tail_x15_r0_body.S722.tab.length + PRE_first_tail_x15_r0_body.cws81.length = 3561
-- the map as `Conv.compact_shift` states it (the call's counters for the literals)
kernel_rfl PRE_first_tail_x15_r0_body.zkap81 : PRE_first_tail_x15_r0_body.kappa81 = Conv.Map.compact PRE_first_tail_x15_r0_body.s722.next 2739357 PRE_first_tail_x15_r0_body.S722.tab.length PRE_first_tail_x15_r0_body.pl81 (PRE_first_tail_x15_r0_body.nr81.map NumV.ref) PRE_first_tail_x15_r0_body.kd81.big
  PRE_first_tail_x15_r0_body.kd81.region PRE_first_tail_x15_r0_body.kd81.nodeF
-- the bridge inactive at the canonical state (`Conv.FullShiftQ.toX`; the merged state's bridge is the canonical's: cbridge)
theorem PRE_first_tail_x15_r0_body.zbin81 : (Host.Ts.Sim.Full.bridgeOf PRE_first_tail_x15_r0_body.s724.ffi).active = false := (Host.Load.Boot.replay_active Host.Load.Run.Prompt.P.oblog2818)
-- the JS bookkeeping's step (`Conv.JClean.step` over the changed list) and the canonical roots' bigint freedom
kernel_rfl PRE_first_tail_x15_r0_body.zjc81 : Conv.jcleanListB (⟨19813, 16904, 2739007, 3561⟩ : Conv.Cnt) PRE_first_tail_x15_r0_body.s724 PRE_first_tail_x15_r0_body.cl81 = true
kernel_rfl PRE_first_tail_x15_r0_body.zroots281 : noBigRootsP (fun i => !Conv.oldBigB (⟨19813, 16904, 2739007, 3561⟩ : Conv.Cnt) i) PRE_first_tail_x15_r0_body.s724.trace PRE_first_tail_x15_r0_body.s724 = true
kernel_rfl PRE_first_tail_x15_r0_body.zhm81 : Nat.ble (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s0.ffi).mlx.nnext 16898 = true
theorem PRE_first_tail_x15_r0_body.cjcl81 (h : Conv.JClean (⟨19809, 16898, 2738992, 3552⟩ : Conv.Cnt) PRE_first_tail_x15_r0_body.s722) : Conv.JClean (⟨19813, 16904, 2739007, 3561⟩ : Conv.Cnt) PRE_first_tail_x15_r0_body.s724 :=
  Conv.JClean.step h (Conv.Cnt.le_of_leB PRE_first_tail_x15_r0_body.cle81)
    (Conv.heap_off_setAll PRE_first_tail_x15_r0_body.cheap81 fun a ha => Nat.blt_eq.mp (List.all_eq_true.mp PRE_first_tail_x15_r0_body.zclbd81 a ha)) PRE_first_tail_x15_r0_body.zjc81

end Host.Load.Run.Tpl
