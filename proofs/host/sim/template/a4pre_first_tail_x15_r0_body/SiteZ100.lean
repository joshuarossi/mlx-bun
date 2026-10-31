import host.sim.template.a4pre_first_tail_x15_r0_body.SiteS100
import host.sim.template.a4pre_first_tail_x15_r0_body.SiteK100
import host.sim.template.a4pre_first_tail_x15_r0_body.SiteF100
import host.sim.conv.CompactShift
import host.sim.template.Check
import host.sim.BigFreeP
import host.sim.template.CallGen
set_option Elab.async false
namespace Host.Load.Run.Tpl
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
open Host.Ts Host.Ts.Sim Host.Ts.Sim.Template

/-! The compaction's state shift at call site 100 of chain `PRE_first_tail_x15_r0_body` (`Conv.compact_shift`): the call `PRE_first_tail_x15_r0_body.s973`, the merged
state `PRE_first_tail_x15_r0_body.s974`, the canonical state `PRE_first_tail_x15_r0_body.s975`; its frames [2665,2673467,2673472,2673473] (kept arrays [2665,2673467]). -/

-- the map's places and counters
kernel_rfl PRE_first_tail_x15_r0_body.zpl100 : PRE_first_tail_x15_r0_body.pl100.all (Nat.ble PRE_first_tail_x15_r0_body.s973.next) = true
kernel_rfl PRE_first_tail_x15_r0_body.zplnd100 : nodupT PRE_first_tail_x15_r0_body.pl100 PTrie.nil = true
kernel_rfl PRE_first_tail_x15_r0_body.zn1100 : Nat.ble PRE_first_tail_x15_r0_body.s973.next 2753549 = true
kernel_rfl PRE_first_tail_x15_r0_body.zfirst100 : Nat.ble aFirst PRE_first_tail_x15_r0_body.s973.next = true
kernel_rfl PRE_first_tail_x15_r0_body.zscn100 : PRE_first_tail_x15_r0_body.s975.next = PRE_first_tail_x15_r0_body.s973.next + PRE_first_tail_x15_r0_body.pl100.length
kernel_rfl PRE_first_tail_x15_r0_body.zsmn100 : PRE_first_tail_x15_r0_body.s974.next = 2753549
kernel_rfl PRE_first_tail_x15_r0_body.zgrow100 : Nat.ble PRE_first_tail_x15_r0_body.s975.next PRE_first_tail_x15_r0_body.s974.next = true
-- the tables
kernel_rfl PRE_first_tail_x15_r0_body.zfresh100 : PRE_first_tail_x15_r0_body.S973.tab.all (fun e => PRE_first_tail_x15_r0_body.cws100.all fun v => e.noVar v) = true
kernel_rfl PRE_first_tail_x15_r0_body.zcnd100 : nodupT PRE_first_tail_x15_r0_body.cws100 PTrie.nil = true
kernel_rfl PRE_first_tail_x15_r0_body.znrHi100 : PRE_first_tail_x15_r0_body.nr100.all (fun r => Nat.blt r PRE_first_tail_x15_r0_body.S974.tab.length) = true
-- the frames: every framed address below the call's counter; the kept arrays the chain start's, extended in the merged state
kernel_rfl PRE_first_tail_x15_r0_body.zfrlt100 : [2665, 2673467, 2673472, 2673473].all (fun a => Nat.blt a PRE_first_tail_x15_r0_body.s973.next) = true
kernel_rfl PRE_first_tail_x15_r0_body.zg100_2665 : PRE_first_tail_x15_r0_body.s975.heap.get 2665 = some (.obj (objOf PRE_first_tail_x15_r0_body.s975 2665))
kernel_rfl PRE_first_tail_x15_r0_body.zk100_2665 : (objOf PRE_first_tail_x15_r0_body.s975 2665).kind = .array (arrOf PRE_first_tail_x15_r0_body.s0 2665)
kernel_rfl PRE_first_tail_x15_r0_body.zm100_2665 : PRE_first_tail_x15_r0_body.s974.heap.get 2665 = some (.obj { PRE_first_tail_x15_r0_body.kappa100.obj (objOf PRE_first_tail_x15_r0_body.s975 2665) with
  kind := .array (arrOf PRE_first_tail_x15_r0_body.s0 2665 ++ (arrOf PRE_first_tail_x15_r0_body.s974 2665).drop (arrOf PRE_first_tail_x15_r0_body.s0 2665).length) })
kernel_rfl PRE_first_tail_x15_r0_body.zg100_2673467 : PRE_first_tail_x15_r0_body.s975.heap.get 2673467 = some (.obj (objOf PRE_first_tail_x15_r0_body.s975 2673467))
kernel_rfl PRE_first_tail_x15_r0_body.zk100_2673467 : (objOf PRE_first_tail_x15_r0_body.s975 2673467).kind = .array (arrOf PRE_first_tail_x15_r0_body.s0 2673467)
kernel_rfl PRE_first_tail_x15_r0_body.zm100_2673467 : PRE_first_tail_x15_r0_body.s974.heap.get 2673467 = some (.obj { PRE_first_tail_x15_r0_body.kappa100.obj (objOf PRE_first_tail_x15_r0_body.s975 2673467) with
  kind := .array (arrOf PRE_first_tail_x15_r0_body.s0 2673467 ++ (arrOf PRE_first_tail_x15_r0_body.s974 2673467).drop (arrOf PRE_first_tail_x15_r0_body.s0 2673467).length) })
kernel_rfl PRE_first_tail_x15_r0_body.zw100_4910 : (PRE_first_tail_x15_r0_body.s975.heap.get 4910).isSome = true
kernel_rfl PRE_first_tail_x15_r0_body.zw100_2673472 : (PRE_first_tail_x15_r0_body.s975.heap.get 2673472).isSome = true
kernel_rfl PRE_first_tail_x15_r0_body.zw100_2673473 : (PRE_first_tail_x15_r0_body.s975.heap.get 2673473).isSome = true
-- the heap: the changed list in range, holding the stage's written and fresh addresses; the canonical side's image
kernel_rfl PRE_first_tail_x15_r0_body.zclbd100 : PRE_first_tail_x15_r0_body.cl100.all (fun b => Nat.blt (b / 4096) (4 ^ 31)) = true
kernel_rfl PRE_first_tail_x15_r0_body.zwr100 : PRE_first_tail_x15_r0_body.st100.wr.all (fun b => !Nat.blt b PRE_first_tail_x15_r0_body.s973.next || PRE_first_tail_x15_r0_body.cl100.contains b) = true
def PRE_first_tail_x15_r0_body.zl100 : List Nat := PRE_first_tail_x15_r0_body.cl100.filter fun a => !(List.contains [2665, 2673467] a)
kernel_rfl PRE_first_tail_x15_r0_body.zimgE100 : PRE_first_tail_x15_r0_body.zl100.map (fun a => PRE_first_tail_x15_r0_body.s974.heap.get (PRE_first_tail_x15_r0_body.kappa100.a a)) = PRE_first_tail_x15_r0_body.zl100.map (fun a => (PRE_first_tail_x15_r0_body.s975.heap.get a).map PRE_first_tail_x15_r0_body.kappa100.hobj)
theorem PRE_first_tail_x15_r0_body.zimg100 : HeapImg PRE_first_tail_x15_r0_body.kappa100 PRE_first_tail_x15_r0_body.s975 PRE_first_tail_x15_r0_body.s974 PRE_first_tail_x15_r0_body.zl100 := PRE_first_tail_x15_r0_body.zimgE100
-- the roots and their supports
kernel_rfl PRE_first_tail_x15_r0_body.zctl100 : PRE_first_tail_x15_r0_body.s974.ctl = PRE_first_tail_x15_r0_body.kappa100.ctl PRE_first_tail_x15_r0_body.s975.ctl
kernel_rfl PRE_first_tail_x15_r0_body.zstack100 : PRE_first_tail_x15_r0_body.s974.stack = PRE_first_tail_x15_r0_body.s975.stack.map PRE_first_tail_x15_r0_body.kappa100.frame
kernel_rfl PRE_first_tail_x15_r0_body.zjobs100 : PRE_first_tail_x15_r0_body.s974.jobs = PRE_first_tail_x15_r0_body.s975.jobs.map PRE_first_tail_x15_r0_body.kappa100.job
kernel_rfl PRE_first_tail_x15_r0_body.zstores100 : PRE_first_tail_x15_r0_body.s974.stores = PRE_first_tail_x15_r0_body.kappa100.stores PRE_first_tail_x15_r0_body.s975.stores
kernel_rfl PRE_first_tail_x15_r0_body.zroots100 : checkRootsSupp PRE_first_tail_x15_r0_body.s975 4355 = true
kernel_rfl PRE_first_tail_x15_r0_body.znC100 : PRE_first_tail_x15_r0_body.S973.tab.length + PRE_first_tail_x15_r0_body.cws100.length = 4355
-- the map as `Conv.compact_shift` states it (the call's counters for the literals)
kernel_rfl PRE_first_tail_x15_r0_body.zkap100 : PRE_first_tail_x15_r0_body.kappa100 = Conv.Map.compact PRE_first_tail_x15_r0_body.s973.next 2753549 PRE_first_tail_x15_r0_body.S973.tab.length PRE_first_tail_x15_r0_body.pl100 (PRE_first_tail_x15_r0_body.nr100.map NumV.ref) PRE_first_tail_x15_r0_body.kd100.big
  PRE_first_tail_x15_r0_body.kd100.region PRE_first_tail_x15_r0_body.kd100.nodeF
-- the bridge inactive at the canonical state (`Conv.FullShiftQ.toX`; the merged state's bridge is the canonical's: cbridge)
theorem PRE_first_tail_x15_r0_body.zbin100 : (Host.Ts.Sim.Full.bridgeOf PRE_first_tail_x15_r0_body.s975.ffi).active = false := (Host.Load.Boot.replay_active Host.Load.Run.Prompt.P.oblog2818)
-- the JS bookkeeping's step (`Conv.JClean.step` over the changed list) and the canonical roots' bigint freedom
kernel_rfl PRE_first_tail_x15_r0_body.zjc100 : Conv.jcleanListB (⟨20177, 17277, 2753547, 4355⟩ : Conv.Cnt) PRE_first_tail_x15_r0_body.s975 PRE_first_tail_x15_r0_body.cl100 = true
kernel_rfl PRE_first_tail_x15_r0_body.zrootsB100 : noBigRootsP (fun i => !Conv.oldBigB (⟨20177, 17277, 2753547, 4355⟩ : Conv.Cnt) i) PRE_first_tail_x15_r0_body.s975.trace PRE_first_tail_x15_r0_body.s975 = true
kernel_rfl PRE_first_tail_x15_r0_body.zhm100 : Nat.ble (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s0.ffi).mlx.nnext 17277 = true
theorem PRE_first_tail_x15_r0_body.cjcl100 (h : Conv.JClean (⟨20177, 17277, 2753547, 4355⟩ : Conv.Cnt) PRE_first_tail_x15_r0_body.s973) : Conv.JClean (⟨20177, 17277, 2753547, 4355⟩ : Conv.Cnt) PRE_first_tail_x15_r0_body.s975 :=
  Conv.JClean.step h (Conv.Cnt.le_of_leB PRE_first_tail_x15_r0_body.cle100)
    (Conv.heap_off_setAll PRE_first_tail_x15_r0_body.cheap100 fun a ha => Nat.blt_eq.mp (List.all_eq_true.mp PRE_first_tail_x15_r0_body.zclbd100 a ha)) PRE_first_tail_x15_r0_body.zjc100

end Host.Load.Run.Tpl
