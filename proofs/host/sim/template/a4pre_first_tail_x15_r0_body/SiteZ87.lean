import host.sim.template.a4pre_first_tail_x15_r0_body.SiteS87
import host.sim.template.a4pre_first_tail_x15_r0_body.SiteK87
import host.sim.template.a4pre_first_tail_x15_r0_body.SiteF87
import host.sim.conv.CompactShift
import host.sim.template.Check
import host.sim.BigFreeP
import host.sim.template.CallGen
set_option Elab.async false
namespace Host.Load.Run.Tpl
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
open Host.Ts Host.Ts.Sim Host.Ts.Sim.Template

/-! The compaction's state shift at call site 87 of chain `PRE_first_tail_x15_r0_body` (`Conv.compact_shift`): the call `PRE_first_tail_x15_r0_body.s776`, the merged
state `PRE_first_tail_x15_r0_body.s777`, the canonical state `PRE_first_tail_x15_r0_body.s778`; its frames [2665,2673467,2673472,2673473] (kept arrays [2665,2673467]). -/

-- the map's places and counters
kernel_rfl PRE_first_tail_x15_r0_body.zpl87 : PRE_first_tail_x15_r0_body.pl87.all (Nat.ble PRE_first_tail_x15_r0_body.s776.next) = true
kernel_rfl PRE_first_tail_x15_r0_body.zplnd87 : nodupT PRE_first_tail_x15_r0_body.pl87 PTrie.nil = true
kernel_rfl PRE_first_tail_x15_r0_body.zn187 : Nat.ble PRE_first_tail_x15_r0_body.s776.next 2744782 = true
kernel_rfl PRE_first_tail_x15_r0_body.zfirst87 : Nat.ble aFirst PRE_first_tail_x15_r0_body.s776.next = true
kernel_rfl PRE_first_tail_x15_r0_body.zscn87 : PRE_first_tail_x15_r0_body.s778.next = PRE_first_tail_x15_r0_body.s776.next + PRE_first_tail_x15_r0_body.pl87.length
kernel_rfl PRE_first_tail_x15_r0_body.zsmn87 : PRE_first_tail_x15_r0_body.s777.next = 2744782
kernel_rfl PRE_first_tail_x15_r0_body.zgrow87 : Nat.ble PRE_first_tail_x15_r0_body.s778.next PRE_first_tail_x15_r0_body.s777.next = true
-- the tables
kernel_rfl PRE_first_tail_x15_r0_body.zfresh87 : PRE_first_tail_x15_r0_body.S776.tab.all (fun e => PRE_first_tail_x15_r0_body.cws87.all fun v => e.noVar v) = true
kernel_rfl PRE_first_tail_x15_r0_body.zcnd87 : nodupT PRE_first_tail_x15_r0_body.cws87 PTrie.nil = true
kernel_rfl PRE_first_tail_x15_r0_body.znrHi87 : PRE_first_tail_x15_r0_body.nr87.all (fun r => Nat.blt r PRE_first_tail_x15_r0_body.S777.tab.length) = true
-- the frames: every framed address below the call's counter; the kept arrays the chain start's, extended in the merged state
kernel_rfl PRE_first_tail_x15_r0_body.zfrlt87 : [2665, 2673467, 2673472, 2673473].all (fun a => Nat.blt a PRE_first_tail_x15_r0_body.s776.next) = true
kernel_rfl PRE_first_tail_x15_r0_body.zg87_2665 : PRE_first_tail_x15_r0_body.s778.heap.get 2665 = some (.obj (objOf PRE_first_tail_x15_r0_body.s778 2665))
kernel_rfl PRE_first_tail_x15_r0_body.zk87_2665 : (objOf PRE_first_tail_x15_r0_body.s778 2665).kind = .array (arrOf PRE_first_tail_x15_r0_body.s0 2665)
kernel_rfl PRE_first_tail_x15_r0_body.zm87_2665 : PRE_first_tail_x15_r0_body.s777.heap.get 2665 = some (.obj { PRE_first_tail_x15_r0_body.kappa87.obj (objOf PRE_first_tail_x15_r0_body.s778 2665) with
  kind := .array (arrOf PRE_first_tail_x15_r0_body.s0 2665 ++ (arrOf PRE_first_tail_x15_r0_body.s777 2665).drop (arrOf PRE_first_tail_x15_r0_body.s0 2665).length) })
kernel_rfl PRE_first_tail_x15_r0_body.zg87_2673467 : PRE_first_tail_x15_r0_body.s778.heap.get 2673467 = some (.obj (objOf PRE_first_tail_x15_r0_body.s778 2673467))
kernel_rfl PRE_first_tail_x15_r0_body.zk87_2673467 : (objOf PRE_first_tail_x15_r0_body.s778 2673467).kind = .array (arrOf PRE_first_tail_x15_r0_body.s0 2673467)
kernel_rfl PRE_first_tail_x15_r0_body.zm87_2673467 : PRE_first_tail_x15_r0_body.s777.heap.get 2673467 = some (.obj { PRE_first_tail_x15_r0_body.kappa87.obj (objOf PRE_first_tail_x15_r0_body.s778 2673467) with
  kind := .array (arrOf PRE_first_tail_x15_r0_body.s0 2673467 ++ (arrOf PRE_first_tail_x15_r0_body.s777 2673467).drop (arrOf PRE_first_tail_x15_r0_body.s0 2673467).length) })
kernel_rfl PRE_first_tail_x15_r0_body.zw87_4910 : (PRE_first_tail_x15_r0_body.s778.heap.get 4910).isSome = true
kernel_rfl PRE_first_tail_x15_r0_body.zw87_2673472 : (PRE_first_tail_x15_r0_body.s778.heap.get 2673472).isSome = true
kernel_rfl PRE_first_tail_x15_r0_body.zw87_2673473 : (PRE_first_tail_x15_r0_body.s778.heap.get 2673473).isSome = true
-- the heap: the changed list in range, holding the stage's written and fresh addresses; the canonical side's image
kernel_rfl PRE_first_tail_x15_r0_body.zclbd87 : PRE_first_tail_x15_r0_body.cl87.all (fun b => Nat.blt (b / 4096) (4 ^ 31)) = true
kernel_rfl PRE_first_tail_x15_r0_body.zwr87 : PRE_first_tail_x15_r0_body.st87.wr.all (fun b => !Nat.blt b PRE_first_tail_x15_r0_body.s776.next || PRE_first_tail_x15_r0_body.cl87.contains b) = true
def PRE_first_tail_x15_r0_body.zl87 : List Nat := PRE_first_tail_x15_r0_body.cl87.filter fun a => !(List.contains [2665, 2673467] a)
kernel_rfl PRE_first_tail_x15_r0_body.zimgE87 : PRE_first_tail_x15_r0_body.zl87.map (fun a => PRE_first_tail_x15_r0_body.s777.heap.get (PRE_first_tail_x15_r0_body.kappa87.a a)) = PRE_first_tail_x15_r0_body.zl87.map (fun a => (PRE_first_tail_x15_r0_body.s778.heap.get a).map PRE_first_tail_x15_r0_body.kappa87.hobj)
theorem PRE_first_tail_x15_r0_body.zimg87 : HeapImg PRE_first_tail_x15_r0_body.kappa87 PRE_first_tail_x15_r0_body.s778 PRE_first_tail_x15_r0_body.s777 PRE_first_tail_x15_r0_body.zl87 := PRE_first_tail_x15_r0_body.zimgE87
-- the roots and their supports
kernel_rfl PRE_first_tail_x15_r0_body.zctl87 : PRE_first_tail_x15_r0_body.s777.ctl = PRE_first_tail_x15_r0_body.kappa87.ctl PRE_first_tail_x15_r0_body.s778.ctl
kernel_rfl PRE_first_tail_x15_r0_body.zstack87 : PRE_first_tail_x15_r0_body.s777.stack = PRE_first_tail_x15_r0_body.s778.stack.map PRE_first_tail_x15_r0_body.kappa87.frame
kernel_rfl PRE_first_tail_x15_r0_body.zjobs87 : PRE_first_tail_x15_r0_body.s777.jobs = PRE_first_tail_x15_r0_body.s778.jobs.map PRE_first_tail_x15_r0_body.kappa87.job
kernel_rfl PRE_first_tail_x15_r0_body.zstores87 : PRE_first_tail_x15_r0_body.s777.stores = PRE_first_tail_x15_r0_body.kappa87.stores PRE_first_tail_x15_r0_body.s778.stores
kernel_rfl PRE_first_tail_x15_r0_body.zroots87 : checkRootsSupp PRE_first_tail_x15_r0_body.s778 3821 = true
kernel_rfl PRE_first_tail_x15_r0_body.znC87 : PRE_first_tail_x15_r0_body.S776.tab.length + PRE_first_tail_x15_r0_body.cws87.length = 3821
-- the map as `Conv.compact_shift` states it (the call's counters for the literals)
kernel_rfl PRE_first_tail_x15_r0_body.zkap87 : PRE_first_tail_x15_r0_body.kappa87 = Conv.Map.compact PRE_first_tail_x15_r0_body.s776.next 2744782 PRE_first_tail_x15_r0_body.S776.tab.length PRE_first_tail_x15_r0_body.pl87 (PRE_first_tail_x15_r0_body.nr87.map NumV.ref) PRE_first_tail_x15_r0_body.kd87.big
  PRE_first_tail_x15_r0_body.kd87.region PRE_first_tail_x15_r0_body.kd87.nodeF
-- the bridge inactive at the canonical state (`Conv.FullShiftQ.toX`; the merged state's bridge is the canonical's: cbridge)
theorem PRE_first_tail_x15_r0_body.zbin87 : (Host.Ts.Sim.Full.bridgeOf PRE_first_tail_x15_r0_body.s778.ffi).active = false := (Host.Load.Boot.replay_active Host.Load.Run.Prompt.P.oblog2818)
-- the JS bookkeeping's step (`Conv.JClean.step` over the changed list) and the canonical roots' bigint freedom
kernel_rfl PRE_first_tail_x15_r0_body.zjc87 : Conv.jcleanListB (⟨19928, 17027, 2743633, 3821⟩ : Conv.Cnt) PRE_first_tail_x15_r0_body.s778 PRE_first_tail_x15_r0_body.cl87 = true
kernel_rfl PRE_first_tail_x15_r0_body.zroots287 : noBigRootsP (fun i => !Conv.oldBigB (⟨19928, 17027, 2743633, 3821⟩ : Conv.Cnt) i) PRE_first_tail_x15_r0_body.s778.trace PRE_first_tail_x15_r0_body.s778 = true
kernel_rfl PRE_first_tail_x15_r0_body.zhm87 : Nat.ble (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s0.ffi).mlx.nnext 17000 = true
theorem PRE_first_tail_x15_r0_body.cjcl87 (h : Conv.JClean (⟨19925, 17000, 2743627, 3803⟩ : Conv.Cnt) PRE_first_tail_x15_r0_body.s776) : Conv.JClean (⟨19928, 17027, 2743633, 3821⟩ : Conv.Cnt) PRE_first_tail_x15_r0_body.s778 :=
  Conv.JClean.step h (Conv.Cnt.le_of_leB PRE_first_tail_x15_r0_body.cle87)
    (Conv.heap_off_setAll PRE_first_tail_x15_r0_body.cheap87 fun a ha => Nat.blt_eq.mp (List.all_eq_true.mp PRE_first_tail_x15_r0_body.zclbd87 a ha)) PRE_first_tail_x15_r0_body.zjc87

end Host.Load.Run.Tpl
