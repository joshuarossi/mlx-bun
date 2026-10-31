import host.sim.template.a4pre_first_tail_x15_r0_body.SiteS78
import host.sim.template.a4pre_first_tail_x15_r0_body.SiteK78
import host.sim.template.a4pre_first_tail_x15_r0_body.SiteF78
import host.sim.conv.CompactShift
import host.sim.template.Check
import host.sim.BigFreeP
import host.sim.template.CallGen
set_option Elab.async false
namespace Host.Load.Run.Tpl
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
open Host.Ts Host.Ts.Sim Host.Ts.Sim.Template

/-! The compaction's state shift at call site 78 of chain `PRE_first_tail_x15_r0_body` (`Conv.compact_shift`): the call `PRE_first_tail_x15_r0_body.s764`, the merged
state `PRE_first_tail_x15_r0_body.s765`, the canonical state `PRE_first_tail_x15_r0_body.s766`; its frames [2665,2673467,2673472,2673473] (kept arrays [2665,2673467]). -/

-- the map's places and counters
kernel_rfl PRE_first_tail_x15_r0_body.zpl78 : PRE_first_tail_x15_r0_body.pl78.all (Nat.ble PRE_first_tail_x15_r0_body.s764.next) = true
kernel_rfl PRE_first_tail_x15_r0_body.zplnd78 : nodupT PRE_first_tail_x15_r0_body.pl78 PTrie.nil = true
kernel_rfl PRE_first_tail_x15_r0_body.zn178 : Nat.ble PRE_first_tail_x15_r0_body.s764.next 2737626 = true
kernel_rfl PRE_first_tail_x15_r0_body.zfirst78 : Nat.ble aFirst PRE_first_tail_x15_r0_body.s764.next = true
kernel_rfl PRE_first_tail_x15_r0_body.zscn78 : PRE_first_tail_x15_r0_body.s766.next = PRE_first_tail_x15_r0_body.s764.next + PRE_first_tail_x15_r0_body.pl78.length
kernel_rfl PRE_first_tail_x15_r0_body.zsmn78 : PRE_first_tail_x15_r0_body.s765.next = 2737626
kernel_rfl PRE_first_tail_x15_r0_body.zgrow78 : Nat.ble PRE_first_tail_x15_r0_body.s766.next PRE_first_tail_x15_r0_body.s765.next = true
-- the tables
kernel_rfl PRE_first_tail_x15_r0_body.zfresh78 : PRE_first_tail_x15_r0_body.S764.tab.all (fun e => PRE_first_tail_x15_r0_body.cws78.all fun v => e.noVar v) = true
kernel_rfl PRE_first_tail_x15_r0_body.zcnd78 : nodupT PRE_first_tail_x15_r0_body.cws78 PTrie.nil = true
kernel_rfl PRE_first_tail_x15_r0_body.znrHi78 : PRE_first_tail_x15_r0_body.nr78.all (fun r => Nat.blt r PRE_first_tail_x15_r0_body.S765.tab.length) = true
-- the frames: every framed address below the call's counter; the kept arrays the chain start's, extended in the merged state
kernel_rfl PRE_first_tail_x15_r0_body.zfrlt78 : [2665, 2673467, 2673472, 2673473].all (fun a => Nat.blt a PRE_first_tail_x15_r0_body.s764.next) = true
kernel_rfl PRE_first_tail_x15_r0_body.zg78_2665 : PRE_first_tail_x15_r0_body.s766.heap.get 2665 = some (.obj (objOf PRE_first_tail_x15_r0_body.s766 2665))
kernel_rfl PRE_first_tail_x15_r0_body.zk78_2665 : (objOf PRE_first_tail_x15_r0_body.s766 2665).kind = .array (arrOf PRE_first_tail_x15_r0_body.s0 2665)
kernel_rfl PRE_first_tail_x15_r0_body.zm78_2665 : PRE_first_tail_x15_r0_body.s765.heap.get 2665 = some (.obj { PRE_first_tail_x15_r0_body.kappa78.obj (objOf PRE_first_tail_x15_r0_body.s766 2665) with
  kind := .array (arrOf PRE_first_tail_x15_r0_body.s0 2665 ++ (arrOf PRE_first_tail_x15_r0_body.s765 2665).drop (arrOf PRE_first_tail_x15_r0_body.s0 2665).length) })
kernel_rfl PRE_first_tail_x15_r0_body.zg78_2673467 : PRE_first_tail_x15_r0_body.s766.heap.get 2673467 = some (.obj (objOf PRE_first_tail_x15_r0_body.s766 2673467))
kernel_rfl PRE_first_tail_x15_r0_body.zk78_2673467 : (objOf PRE_first_tail_x15_r0_body.s766 2673467).kind = .array (arrOf PRE_first_tail_x15_r0_body.s0 2673467)
kernel_rfl PRE_first_tail_x15_r0_body.zm78_2673467 : PRE_first_tail_x15_r0_body.s765.heap.get 2673467 = some (.obj { PRE_first_tail_x15_r0_body.kappa78.obj (objOf PRE_first_tail_x15_r0_body.s766 2673467) with
  kind := .array (arrOf PRE_first_tail_x15_r0_body.s0 2673467 ++ (arrOf PRE_first_tail_x15_r0_body.s765 2673467).drop (arrOf PRE_first_tail_x15_r0_body.s0 2673467).length) })
kernel_rfl PRE_first_tail_x15_r0_body.zw78_4910 : (PRE_first_tail_x15_r0_body.s766.heap.get 4910).isSome = true
kernel_rfl PRE_first_tail_x15_r0_body.zw78_2673472 : (PRE_first_tail_x15_r0_body.s766.heap.get 2673472).isSome = true
kernel_rfl PRE_first_tail_x15_r0_body.zw78_2673473 : (PRE_first_tail_x15_r0_body.s766.heap.get 2673473).isSome = true
-- the heap: the changed list in range, holding the stage's written and fresh addresses; the canonical side's image
kernel_rfl PRE_first_tail_x15_r0_body.zclbd78 : PRE_first_tail_x15_r0_body.cl78.all (fun b => Nat.blt (b / 4096) (4 ^ 31)) = true
kernel_rfl PRE_first_tail_x15_r0_body.zwr78 : PRE_first_tail_x15_r0_body.st78.wr.all (fun b => !Nat.blt b PRE_first_tail_x15_r0_body.s764.next || PRE_first_tail_x15_r0_body.cl78.contains b) = true
def PRE_first_tail_x15_r0_body.zl78 : List Nat := PRE_first_tail_x15_r0_body.cl78.filter fun a => !(List.contains [2665, 2673467] a)
kernel_rfl PRE_first_tail_x15_r0_body.zimgE78 : PRE_first_tail_x15_r0_body.zl78.map (fun a => PRE_first_tail_x15_r0_body.s765.heap.get (PRE_first_tail_x15_r0_body.kappa78.a a)) = PRE_first_tail_x15_r0_body.zl78.map (fun a => (PRE_first_tail_x15_r0_body.s766.heap.get a).map PRE_first_tail_x15_r0_body.kappa78.hobj)
theorem PRE_first_tail_x15_r0_body.zimg78 : HeapImg PRE_first_tail_x15_r0_body.kappa78 PRE_first_tail_x15_r0_body.s766 PRE_first_tail_x15_r0_body.s765 PRE_first_tail_x15_r0_body.zl78 := PRE_first_tail_x15_r0_body.zimgE78
-- the roots and their supports
kernel_rfl PRE_first_tail_x15_r0_body.zctl78 : PRE_first_tail_x15_r0_body.s765.ctl = PRE_first_tail_x15_r0_body.kappa78.ctl PRE_first_tail_x15_r0_body.s766.ctl
kernel_rfl PRE_first_tail_x15_r0_body.zstack78 : PRE_first_tail_x15_r0_body.s765.stack = PRE_first_tail_x15_r0_body.s766.stack.map PRE_first_tail_x15_r0_body.kappa78.frame
kernel_rfl PRE_first_tail_x15_r0_body.zjobs78 : PRE_first_tail_x15_r0_body.s765.jobs = PRE_first_tail_x15_r0_body.s766.jobs.map PRE_first_tail_x15_r0_body.kappa78.job
kernel_rfl PRE_first_tail_x15_r0_body.zstores78 : PRE_first_tail_x15_r0_body.s765.stores = PRE_first_tail_x15_r0_body.kappa78.stores PRE_first_tail_x15_r0_body.s766.stores
kernel_rfl PRE_first_tail_x15_r0_body.zroots78 : checkRootsSupp PRE_first_tail_x15_r0_body.s766 3437 = true
kernel_rfl PRE_first_tail_x15_r0_body.znC78 : PRE_first_tail_x15_r0_body.S764.tab.length + PRE_first_tail_x15_r0_body.cws78.length = 3437
-- the map as `Conv.compact_shift` states it (the call's counters for the literals)
kernel_rfl PRE_first_tail_x15_r0_body.zkap78 : PRE_first_tail_x15_r0_body.kappa78 = Conv.Map.compact PRE_first_tail_x15_r0_body.s764.next 2737626 PRE_first_tail_x15_r0_body.S764.tab.length PRE_first_tail_x15_r0_body.pl78 (PRE_first_tail_x15_r0_body.nr78.map NumV.ref) PRE_first_tail_x15_r0_body.kd78.big
  PRE_first_tail_x15_r0_body.kd78.region PRE_first_tail_x15_r0_body.kd78.nodeF
-- the bridge inactive at the canonical state (`Conv.FullShiftQ.toX`; the merged state's bridge is the canonical's: cbridge)
theorem PRE_first_tail_x15_r0_body.zbin78 : (Host.Ts.Sim.Full.bridgeOf PRE_first_tail_x15_r0_body.s766.ffi).active = false := (Host.Load.Boot.replay_active Host.Load.Run.Prompt.P.oblog2818)
-- the JS bookkeeping's step (`Conv.JClean.step` over the changed list) and the canonical roots' bigint freedom
kernel_rfl PRE_first_tail_x15_r0_body.zjc78 : Conv.jcleanListB (⟨19749, 16853, 2736477, 3437⟩ : Conv.Cnt) PRE_first_tail_x15_r0_body.s766 PRE_first_tail_x15_r0_body.cl78 = true
kernel_rfl PRE_first_tail_x15_r0_body.zrootsB78 : noBigRootsP (fun i => !Conv.oldBigB (⟨19749, 16853, 2736477, 3437⟩ : Conv.Cnt) i) PRE_first_tail_x15_r0_body.s766.trace PRE_first_tail_x15_r0_body.s766 = true
kernel_rfl PRE_first_tail_x15_r0_body.zhm78 : Nat.ble (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s0.ffi).mlx.nnext 16826 = true
theorem PRE_first_tail_x15_r0_body.cjcl78 (h : Conv.JClean (⟨19746, 16826, 2736471, 3419⟩ : Conv.Cnt) PRE_first_tail_x15_r0_body.s764) : Conv.JClean (⟨19749, 16853, 2736477, 3437⟩ : Conv.Cnt) PRE_first_tail_x15_r0_body.s766 :=
  Conv.JClean.step h (Conv.Cnt.le_of_leB PRE_first_tail_x15_r0_body.cle78)
    (Conv.heap_off_setAll PRE_first_tail_x15_r0_body.cheap78 fun a ha => Nat.blt_eq.mp (List.all_eq_true.mp PRE_first_tail_x15_r0_body.zclbd78 a ha)) PRE_first_tail_x15_r0_body.zjc78

end Host.Load.Run.Tpl
