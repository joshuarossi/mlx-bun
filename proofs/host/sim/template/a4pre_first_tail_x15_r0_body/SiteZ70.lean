import host.sim.template.a4pre_first_tail_x15_r0_body.SiteS70
import host.sim.template.a4pre_first_tail_x15_r0_body.SiteK70
import host.sim.template.a4pre_first_tail_x15_r0_body.SiteF70
import host.sim.conv.CompactShift
import host.sim.template.Check
import host.sim.BigFreeP
import host.sim.template.CallGen
set_option Elab.async false
namespace Host.Load.Run.Tpl
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
open Host.Ts Host.Ts.Sim Host.Ts.Sim.Template

/-! The compaction's state shift at call site 70 of chain `PRE_first_tail_x15_r0_body` (`Conv.compact_shift`): the call `PRE_first_tail_x15_r0_body.s624`, the merged
state `PRE_first_tail_x15_r0_body.s625`, the canonical state `PRE_first_tail_x15_r0_body.s626`; its frames [2665,2673467,2673472,2673473] (kept arrays [2665,2673467]). -/

-- the map's places and counters
kernel_rfl PRE_first_tail_x15_r0_body.zpl70 : PRE_first_tail_x15_r0_body.pl70.all (Nat.ble PRE_first_tail_x15_r0_body.s624.next) = true
kernel_rfl PRE_first_tail_x15_r0_body.zplnd70 : nodupT PRE_first_tail_x15_r0_body.pl70 PTrie.nil = true
kernel_rfl PRE_first_tail_x15_r0_body.zn170 : Nat.ble PRE_first_tail_x15_r0_body.s624.next 2730179 = true
kernel_rfl PRE_first_tail_x15_r0_body.zfirst70 : Nat.ble aFirst PRE_first_tail_x15_r0_body.s624.next = true
kernel_rfl PRE_first_tail_x15_r0_body.zscn70 : PRE_first_tail_x15_r0_body.s626.next = PRE_first_tail_x15_r0_body.s624.next + PRE_first_tail_x15_r0_body.pl70.length
kernel_rfl PRE_first_tail_x15_r0_body.zsmn70 : PRE_first_tail_x15_r0_body.s625.next = 2730179
kernel_rfl PRE_first_tail_x15_r0_body.zgrow70 : Nat.ble PRE_first_tail_x15_r0_body.s626.next PRE_first_tail_x15_r0_body.s625.next = true
-- the tables
kernel_rfl PRE_first_tail_x15_r0_body.zfresh70 : PRE_first_tail_x15_r0_body.S624.tab.all (fun e => PRE_first_tail_x15_r0_body.cws70.all fun v => e.noVar v) = true
kernel_rfl PRE_first_tail_x15_r0_body.zcnd70 : nodupT PRE_first_tail_x15_r0_body.cws70 PTrie.nil = true
kernel_rfl PRE_first_tail_x15_r0_body.znrHi70 : PRE_first_tail_x15_r0_body.nr70.all (fun r => Nat.blt r PRE_first_tail_x15_r0_body.S625.tab.length) = true
-- the frames: every framed address below the call's counter; the kept arrays the chain start's, extended in the merged state
kernel_rfl PRE_first_tail_x15_r0_body.zfrlt70 : [2665, 2673467, 2673472, 2673473].all (fun a => Nat.blt a PRE_first_tail_x15_r0_body.s624.next) = true
kernel_rfl PRE_first_tail_x15_r0_body.zg70_2665 : PRE_first_tail_x15_r0_body.s626.heap.get 2665 = some (.obj (objOf PRE_first_tail_x15_r0_body.s626 2665))
kernel_rfl PRE_first_tail_x15_r0_body.zk70_2665 : (objOf PRE_first_tail_x15_r0_body.s626 2665).kind = .array (arrOf PRE_first_tail_x15_r0_body.s0 2665)
kernel_rfl PRE_first_tail_x15_r0_body.zm70_2665 : PRE_first_tail_x15_r0_body.s625.heap.get 2665 = some (.obj { PRE_first_tail_x15_r0_body.kappa70.obj (objOf PRE_first_tail_x15_r0_body.s626 2665) with
  kind := .array (arrOf PRE_first_tail_x15_r0_body.s0 2665 ++ (arrOf PRE_first_tail_x15_r0_body.s625 2665).drop (arrOf PRE_first_tail_x15_r0_body.s0 2665).length) })
kernel_rfl PRE_first_tail_x15_r0_body.zg70_2673467 : PRE_first_tail_x15_r0_body.s626.heap.get 2673467 = some (.obj (objOf PRE_first_tail_x15_r0_body.s626 2673467))
kernel_rfl PRE_first_tail_x15_r0_body.zk70_2673467 : (objOf PRE_first_tail_x15_r0_body.s626 2673467).kind = .array (arrOf PRE_first_tail_x15_r0_body.s0 2673467)
kernel_rfl PRE_first_tail_x15_r0_body.zm70_2673467 : PRE_first_tail_x15_r0_body.s625.heap.get 2673467 = some (.obj { PRE_first_tail_x15_r0_body.kappa70.obj (objOf PRE_first_tail_x15_r0_body.s626 2673467) with
  kind := .array (arrOf PRE_first_tail_x15_r0_body.s0 2673467 ++ (arrOf PRE_first_tail_x15_r0_body.s625 2673467).drop (arrOf PRE_first_tail_x15_r0_body.s0 2673467).length) })
kernel_rfl PRE_first_tail_x15_r0_body.zw70_4910 : (PRE_first_tail_x15_r0_body.s626.heap.get 4910).isSome = true
kernel_rfl PRE_first_tail_x15_r0_body.zw70_2673472 : (PRE_first_tail_x15_r0_body.s626.heap.get 2673472).isSome = true
kernel_rfl PRE_first_tail_x15_r0_body.zw70_2673473 : (PRE_first_tail_x15_r0_body.s626.heap.get 2673473).isSome = true
-- the heap: the changed list in range, holding the stage's written and fresh addresses; the canonical side's image
kernel_rfl PRE_first_tail_x15_r0_body.zclbd70 : PRE_first_tail_x15_r0_body.cl70.all (fun b => Nat.blt (b / 4096) (4 ^ 31)) = true
kernel_rfl PRE_first_tail_x15_r0_body.zwr70 : PRE_first_tail_x15_r0_body.st70.wr.all (fun b => !Nat.blt b PRE_first_tail_x15_r0_body.s624.next || PRE_first_tail_x15_r0_body.cl70.contains b) = true
def PRE_first_tail_x15_r0_body.zl70 : List Nat := PRE_first_tail_x15_r0_body.cl70.filter fun a => !(List.contains [2665, 2673467] a)
kernel_rfl PRE_first_tail_x15_r0_body.zimgE70 : PRE_first_tail_x15_r0_body.zl70.map (fun a => PRE_first_tail_x15_r0_body.s625.heap.get (PRE_first_tail_x15_r0_body.kappa70.a a)) = PRE_first_tail_x15_r0_body.zl70.map (fun a => (PRE_first_tail_x15_r0_body.s626.heap.get a).map PRE_first_tail_x15_r0_body.kappa70.hobj)
theorem PRE_first_tail_x15_r0_body.zimg70 : HeapImg PRE_first_tail_x15_r0_body.kappa70 PRE_first_tail_x15_r0_body.s626 PRE_first_tail_x15_r0_body.s625 PRE_first_tail_x15_r0_body.zl70 := PRE_first_tail_x15_r0_body.zimgE70
-- the roots and their supports
kernel_rfl PRE_first_tail_x15_r0_body.zctl70 : PRE_first_tail_x15_r0_body.s625.ctl = PRE_first_tail_x15_r0_body.kappa70.ctl PRE_first_tail_x15_r0_body.s626.ctl
kernel_rfl PRE_first_tail_x15_r0_body.zstack70 : PRE_first_tail_x15_r0_body.s625.stack = PRE_first_tail_x15_r0_body.s626.stack.map PRE_first_tail_x15_r0_body.kappa70.frame
kernel_rfl PRE_first_tail_x15_r0_body.zjobs70 : PRE_first_tail_x15_r0_body.s625.jobs = PRE_first_tail_x15_r0_body.s626.jobs.map PRE_first_tail_x15_r0_body.kappa70.job
kernel_rfl PRE_first_tail_x15_r0_body.zstores70 : PRE_first_tail_x15_r0_body.s625.stores = PRE_first_tail_x15_r0_body.kappa70.stores PRE_first_tail_x15_r0_body.s626.stores
kernel_rfl PRE_first_tail_x15_r0_body.zroots70 : checkRootsSupp PRE_first_tail_x15_r0_body.s626 3071 = true
kernel_rfl PRE_first_tail_x15_r0_body.znC70 : PRE_first_tail_x15_r0_body.S624.tab.length + PRE_first_tail_x15_r0_body.cws70.length = 3071
-- the map as `Conv.compact_shift` states it (the call's counters for the literals)
kernel_rfl PRE_first_tail_x15_r0_body.zkap70 : PRE_first_tail_x15_r0_body.kappa70 = Conv.Map.compact PRE_first_tail_x15_r0_body.s624.next 2730179 PRE_first_tail_x15_r0_body.S624.tab.length PRE_first_tail_x15_r0_body.pl70 (PRE_first_tail_x15_r0_body.nr70.map NumV.ref) PRE_first_tail_x15_r0_body.kd70.big
  PRE_first_tail_x15_r0_body.kd70.region PRE_first_tail_x15_r0_body.kd70.nodeF
-- the bridge inactive at the canonical state (`Conv.FullShiftQ.toX`; the merged state's bridge is the canonical's: cbridge)
theorem PRE_first_tail_x15_r0_body.zbin70 : (Host.Ts.Sim.Full.bridgeOf PRE_first_tail_x15_r0_body.s626.ffi).active = false := (Host.Load.Boot.replay_active Host.Load.Run.Prompt.P.oblog2818)
-- the JS bookkeeping's step (`Conv.JClean.step` over the changed list) and the canonical roots' bigint freedom
kernel_rfl PRE_first_tail_x15_r0_body.zjc70 : Conv.jcleanListB (⟨19590, 16677, 2730177, 3071⟩ : Conv.Cnt) PRE_first_tail_x15_r0_body.s626 PRE_first_tail_x15_r0_body.cl70 = true
kernel_rfl PRE_first_tail_x15_r0_body.zroots270 : noBigRootsP (fun i => !Conv.oldBigB (⟨19590, 16677, 2730177, 3071⟩ : Conv.Cnt) i) PRE_first_tail_x15_r0_body.s626.trace PRE_first_tail_x15_r0_body.s626 = true
kernel_rfl PRE_first_tail_x15_r0_body.zhm70 : Nat.ble (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s0.ffi).mlx.nnext 16677 = true
theorem PRE_first_tail_x15_r0_body.cjcl70 (h : Conv.JClean (⟨19590, 16677, 2730177, 3071⟩ : Conv.Cnt) PRE_first_tail_x15_r0_body.s624) : Conv.JClean (⟨19590, 16677, 2730177, 3071⟩ : Conv.Cnt) PRE_first_tail_x15_r0_body.s626 :=
  Conv.JClean.step h (Conv.Cnt.le_of_leB PRE_first_tail_x15_r0_body.cle70)
    (Conv.heap_off_setAll PRE_first_tail_x15_r0_body.cheap70 fun a ha => Nat.blt_eq.mp (List.all_eq_true.mp PRE_first_tail_x15_r0_body.zclbd70 a ha)) PRE_first_tail_x15_r0_body.zjc70

end Host.Load.Run.Tpl
