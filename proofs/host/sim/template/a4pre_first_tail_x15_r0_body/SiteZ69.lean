import host.sim.template.a4pre_first_tail_x15_r0_body.SiteS69
import host.sim.template.a4pre_first_tail_x15_r0_body.SiteK69
import host.sim.template.a4pre_first_tail_x15_r0_body.SiteF69
import host.sim.conv.CompactShift
import host.sim.template.Check
import host.sim.BigFreeP
import host.sim.template.CallGen
set_option Elab.async false
namespace Host.Load.Run.Tpl
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
open Host.Ts Host.Ts.Sim Host.Ts.Sim.Template

/-! The compaction's state shift at call site 69 of chain `PRE_first_tail_x15_r0_body` (`Conv.compact_shift`): the call `PRE_first_tail_x15_r0_body.s677`, the merged
state `PRE_first_tail_x15_r0_body.s678`, the canonical state `PRE_first_tail_x15_r0_body.s679`; its frames [2665,2673467,2673472,2673473] (kept arrays [2665,2673467]). -/

-- the map's places and counters
kernel_rfl PRE_first_tail_x15_r0_body.zpl69 : PRE_first_tail_x15_r0_body.pl69.all (Nat.ble PRE_first_tail_x15_r0_body.s677.next) = true
kernel_rfl PRE_first_tail_x15_r0_body.zplnd69 : nodupT PRE_first_tail_x15_r0_body.pl69 PTrie.nil = true
kernel_rfl PRE_first_tail_x15_r0_body.zn169 : Nat.ble PRE_first_tail_x15_r0_body.s677.next 2729945 = true
kernel_rfl PRE_first_tail_x15_r0_body.zfirst69 : Nat.ble aFirst PRE_first_tail_x15_r0_body.s677.next = true
kernel_rfl PRE_first_tail_x15_r0_body.zscn69 : PRE_first_tail_x15_r0_body.s679.next = PRE_first_tail_x15_r0_body.s677.next + PRE_first_tail_x15_r0_body.pl69.length
kernel_rfl PRE_first_tail_x15_r0_body.zsmn69 : PRE_first_tail_x15_r0_body.s678.next = 2729945
kernel_rfl PRE_first_tail_x15_r0_body.zgrow69 : Nat.ble PRE_first_tail_x15_r0_body.s679.next PRE_first_tail_x15_r0_body.s678.next = true
-- the tables
kernel_rfl PRE_first_tail_x15_r0_body.zfresh69 : PRE_first_tail_x15_r0_body.S677.tab.all (fun e => PRE_first_tail_x15_r0_body.cws69.all fun v => e.noVar v) = true
kernel_rfl PRE_first_tail_x15_r0_body.zcnd69 : nodupT PRE_first_tail_x15_r0_body.cws69 PTrie.nil = true
kernel_rfl PRE_first_tail_x15_r0_body.znrHi69 : PRE_first_tail_x15_r0_body.nr69.all (fun r => Nat.blt r PRE_first_tail_x15_r0_body.S678.tab.length) = true
-- the frames: every framed address below the call's counter; the kept arrays the chain start's, extended in the merged state
kernel_rfl PRE_first_tail_x15_r0_body.zfrlt69 : [2665, 2673467, 2673472, 2673473].all (fun a => Nat.blt a PRE_first_tail_x15_r0_body.s677.next) = true
kernel_rfl PRE_first_tail_x15_r0_body.zg69_2665 : PRE_first_tail_x15_r0_body.s679.heap.get 2665 = some (.obj (objOf PRE_first_tail_x15_r0_body.s679 2665))
kernel_rfl PRE_first_tail_x15_r0_body.zk69_2665 : (objOf PRE_first_tail_x15_r0_body.s679 2665).kind = .array (arrOf PRE_first_tail_x15_r0_body.s0 2665)
kernel_rfl PRE_first_tail_x15_r0_body.zm69_2665 : PRE_first_tail_x15_r0_body.s678.heap.get 2665 = some (.obj { PRE_first_tail_x15_r0_body.kappa69.obj (objOf PRE_first_tail_x15_r0_body.s679 2665) with
  kind := .array (arrOf PRE_first_tail_x15_r0_body.s0 2665 ++ (arrOf PRE_first_tail_x15_r0_body.s678 2665).drop (arrOf PRE_first_tail_x15_r0_body.s0 2665).length) })
kernel_rfl PRE_first_tail_x15_r0_body.zg69_2673467 : PRE_first_tail_x15_r0_body.s679.heap.get 2673467 = some (.obj (objOf PRE_first_tail_x15_r0_body.s679 2673467))
kernel_rfl PRE_first_tail_x15_r0_body.zk69_2673467 : (objOf PRE_first_tail_x15_r0_body.s679 2673467).kind = .array (arrOf PRE_first_tail_x15_r0_body.s0 2673467)
kernel_rfl PRE_first_tail_x15_r0_body.zm69_2673467 : PRE_first_tail_x15_r0_body.s678.heap.get 2673467 = some (.obj { PRE_first_tail_x15_r0_body.kappa69.obj (objOf PRE_first_tail_x15_r0_body.s679 2673467) with
  kind := .array (arrOf PRE_first_tail_x15_r0_body.s0 2673467 ++ (arrOf PRE_first_tail_x15_r0_body.s678 2673467).drop (arrOf PRE_first_tail_x15_r0_body.s0 2673467).length) })
kernel_rfl PRE_first_tail_x15_r0_body.zw69_4910 : (PRE_first_tail_x15_r0_body.s679.heap.get 4910).isSome = true
kernel_rfl PRE_first_tail_x15_r0_body.zw69_2673472 : (PRE_first_tail_x15_r0_body.s679.heap.get 2673472).isSome = true
kernel_rfl PRE_first_tail_x15_r0_body.zw69_2673473 : (PRE_first_tail_x15_r0_body.s679.heap.get 2673473).isSome = true
-- the heap: the changed list in range, holding the stage's written and fresh addresses; the canonical side's image
kernel_rfl PRE_first_tail_x15_r0_body.zclbd69 : PRE_first_tail_x15_r0_body.cl69.all (fun b => Nat.blt (b / 4096) (4 ^ 31)) = true
kernel_rfl PRE_first_tail_x15_r0_body.zwr69 : PRE_first_tail_x15_r0_body.st69.wr.all (fun b => !Nat.blt b PRE_first_tail_x15_r0_body.s677.next || PRE_first_tail_x15_r0_body.cl69.contains b) = true
def PRE_first_tail_x15_r0_body.zl69 : List Nat := PRE_first_tail_x15_r0_body.cl69.filter fun a => !(List.contains [2665, 2673467] a)
kernel_rfl PRE_first_tail_x15_r0_body.zimgE69 : PRE_first_tail_x15_r0_body.zl69.map (fun a => PRE_first_tail_x15_r0_body.s678.heap.get (PRE_first_tail_x15_r0_body.kappa69.a a)) = PRE_first_tail_x15_r0_body.zl69.map (fun a => (PRE_first_tail_x15_r0_body.s679.heap.get a).map PRE_first_tail_x15_r0_body.kappa69.hobj)
theorem PRE_first_tail_x15_r0_body.zimg69 : HeapImg PRE_first_tail_x15_r0_body.kappa69 PRE_first_tail_x15_r0_body.s679 PRE_first_tail_x15_r0_body.s678 PRE_first_tail_x15_r0_body.zl69 := PRE_first_tail_x15_r0_body.zimgE69
-- the roots and their supports
kernel_rfl PRE_first_tail_x15_r0_body.zctl69 : PRE_first_tail_x15_r0_body.s678.ctl = PRE_first_tail_x15_r0_body.kappa69.ctl PRE_first_tail_x15_r0_body.s679.ctl
kernel_rfl PRE_first_tail_x15_r0_body.zstack69 : PRE_first_tail_x15_r0_body.s678.stack = PRE_first_tail_x15_r0_body.s679.stack.map PRE_first_tail_x15_r0_body.kappa69.frame
kernel_rfl PRE_first_tail_x15_r0_body.zjobs69 : PRE_first_tail_x15_r0_body.s678.jobs = PRE_first_tail_x15_r0_body.s679.jobs.map PRE_first_tail_x15_r0_body.kappa69.job
kernel_rfl PRE_first_tail_x15_r0_body.zstores69 : PRE_first_tail_x15_r0_body.s678.stores = PRE_first_tail_x15_r0_body.kappa69.stores PRE_first_tail_x15_r0_body.s679.stores
kernel_rfl PRE_first_tail_x15_r0_body.zroots69 : checkRootsSupp PRE_first_tail_x15_r0_body.s679 3048 = true
kernel_rfl PRE_first_tail_x15_r0_body.znC69 : PRE_first_tail_x15_r0_body.S677.tab.length + PRE_first_tail_x15_r0_body.cws69.length = 3048
-- the map as `Conv.compact_shift` states it (the call's counters for the literals)
kernel_rfl PRE_first_tail_x15_r0_body.zkap69 : PRE_first_tail_x15_r0_body.kappa69 = Conv.Map.compact PRE_first_tail_x15_r0_body.s677.next 2729945 PRE_first_tail_x15_r0_body.S677.tab.length PRE_first_tail_x15_r0_body.pl69 (PRE_first_tail_x15_r0_body.nr69.map NumV.ref) PRE_first_tail_x15_r0_body.kd69.big
  PRE_first_tail_x15_r0_body.kd69.region PRE_first_tail_x15_r0_body.kd69.nodeF
-- the bridge inactive at the canonical state (`Conv.FullShiftQ.toX`; the merged state's bridge is the canonical's: cbridge)
theorem PRE_first_tail_x15_r0_body.zbin69 : (Host.Ts.Sim.Full.bridgeOf PRE_first_tail_x15_r0_body.s679.ffi).active = false := (Host.Load.Boot.replay_active Host.Load.Run.Prompt.P.oblog2818)
-- the JS bookkeeping's step (`Conv.JClean.step` over the changed list) and the canonical roots' bigint freedom
kernel_rfl PRE_first_tail_x15_r0_body.zjc69 : Conv.jcleanListB (⟨19577, 16667, 2729595, 3048⟩ : Conv.Cnt) PRE_first_tail_x15_r0_body.s679 PRE_first_tail_x15_r0_body.cl69 = true
kernel_rfl PRE_first_tail_x15_r0_body.zrootsB69 : noBigRootsP (fun i => !Conv.oldBigB (⟨19577, 16667, 2729595, 3048⟩ : Conv.Cnt) i) PRE_first_tail_x15_r0_body.s679.trace PRE_first_tail_x15_r0_body.s679 = true
kernel_rfl PRE_first_tail_x15_r0_body.zhm69 : Nat.ble (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s0.ffi).mlx.nnext 16661 = true
theorem PRE_first_tail_x15_r0_body.cjcl69 (h : Conv.JClean (⟨19573, 16661, 2729580, 3039⟩ : Conv.Cnt) PRE_first_tail_x15_r0_body.s677) : Conv.JClean (⟨19577, 16667, 2729595, 3048⟩ : Conv.Cnt) PRE_first_tail_x15_r0_body.s679 :=
  Conv.JClean.step h (Conv.Cnt.le_of_leB PRE_first_tail_x15_r0_body.cle69)
    (Conv.heap_off_setAll PRE_first_tail_x15_r0_body.cheap69 fun a ha => Nat.blt_eq.mp (List.all_eq_true.mp PRE_first_tail_x15_r0_body.zclbd69 a ha)) PRE_first_tail_x15_r0_body.zjc69

end Host.Load.Run.Tpl
