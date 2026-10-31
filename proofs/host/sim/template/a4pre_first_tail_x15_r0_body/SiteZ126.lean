import host.sim.template.a4pre_first_tail_x15_r0_body.SiteS126
import host.sim.template.a4pre_first_tail_x15_r0_body.SiteK126
import host.sim.template.a4pre_first_tail_x15_r0_body.SiteF126
import host.sim.conv.CompactShift
import host.sim.template.Check
import host.sim.BigFreeP
import host.sim.template.CallGen
set_option Elab.async false
namespace Host.Load.Run.Tpl
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
open Host.Ts Host.Ts.Sim Host.Ts.Sim.Template

/-! The compaction's state shift at call site 126 of chain `PRE_first_tail_x15_r0_body` (`Conv.compact_shift`): the call `PRE_first_tail_x15_r0_body.s1118`, the merged
state `PRE_first_tail_x15_r0_body.s1119`, the canonical state `PRE_first_tail_x15_r0_body.s1120`; its frames [2665,2673467,2673472,2673473] (kept arrays [2665,2673467]). -/

-- the map's places and counters
kernel_rfl PRE_first_tail_x15_r0_body.zpl126 : PRE_first_tail_x15_r0_body.pl126.all (Nat.ble PRE_first_tail_x15_r0_body.s1118.next) = true
kernel_rfl PRE_first_tail_x15_r0_body.zplnd126 : nodupT PRE_first_tail_x15_r0_body.pl126 PTrie.nil = true
kernel_rfl PRE_first_tail_x15_r0_body.zn1126 : Nat.ble PRE_first_tail_x15_r0_body.s1118.next 2775290 = true
kernel_rfl PRE_first_tail_x15_r0_body.zfirst126 : Nat.ble aFirst PRE_first_tail_x15_r0_body.s1118.next = true
kernel_rfl PRE_first_tail_x15_r0_body.zscn126 : PRE_first_tail_x15_r0_body.s1120.next = PRE_first_tail_x15_r0_body.s1118.next + PRE_first_tail_x15_r0_body.pl126.length
kernel_rfl PRE_first_tail_x15_r0_body.zsmn126 : PRE_first_tail_x15_r0_body.s1119.next = 2775290
kernel_rfl PRE_first_tail_x15_r0_body.zgrow126 : Nat.ble PRE_first_tail_x15_r0_body.s1120.next PRE_first_tail_x15_r0_body.s1119.next = true
-- the tables
kernel_rfl PRE_first_tail_x15_r0_body.zfresh126 : PRE_first_tail_x15_r0_body.S1118.tab.all (fun e => PRE_first_tail_x15_r0_body.cws126.all fun v => e.noVar v) = true
kernel_rfl PRE_first_tail_x15_r0_body.zcnd126 : nodupT PRE_first_tail_x15_r0_body.cws126 PTrie.nil = true
kernel_rfl PRE_first_tail_x15_r0_body.znrHi126 : PRE_first_tail_x15_r0_body.nr126.all (fun r => Nat.blt r PRE_first_tail_x15_r0_body.S1119.tab.length) = true
-- the frames: every framed address below the call's counter; the kept arrays the chain start's, extended in the merged state
kernel_rfl PRE_first_tail_x15_r0_body.zfrlt126 : [2665, 2673467, 2673472, 2673473].all (fun a => Nat.blt a PRE_first_tail_x15_r0_body.s1118.next) = true
kernel_rfl PRE_first_tail_x15_r0_body.zg126_2665 : PRE_first_tail_x15_r0_body.s1120.heap.get 2665 = some (.obj (objOf PRE_first_tail_x15_r0_body.s1120 2665))
kernel_rfl PRE_first_tail_x15_r0_body.zk126_2665 : (objOf PRE_first_tail_x15_r0_body.s1120 2665).kind = .array (arrOf PRE_first_tail_x15_r0_body.s0 2665)
kernel_rfl PRE_first_tail_x15_r0_body.zm126_2665 : PRE_first_tail_x15_r0_body.s1119.heap.get 2665 = some (.obj { PRE_first_tail_x15_r0_body.kappa126.obj (objOf PRE_first_tail_x15_r0_body.s1120 2665) with
  kind := .array (arrOf PRE_first_tail_x15_r0_body.s0 2665 ++ (arrOf PRE_first_tail_x15_r0_body.s1119 2665).drop (arrOf PRE_first_tail_x15_r0_body.s0 2665).length) })
kernel_rfl PRE_first_tail_x15_r0_body.zg126_2673467 : PRE_first_tail_x15_r0_body.s1120.heap.get 2673467 = some (.obj (objOf PRE_first_tail_x15_r0_body.s1120 2673467))
kernel_rfl PRE_first_tail_x15_r0_body.zk126_2673467 : (objOf PRE_first_tail_x15_r0_body.s1120 2673467).kind = .array (arrOf PRE_first_tail_x15_r0_body.s0 2673467)
kernel_rfl PRE_first_tail_x15_r0_body.zm126_2673467 : PRE_first_tail_x15_r0_body.s1119.heap.get 2673467 = some (.obj { PRE_first_tail_x15_r0_body.kappa126.obj (objOf PRE_first_tail_x15_r0_body.s1120 2673467) with
  kind := .array (arrOf PRE_first_tail_x15_r0_body.s0 2673467 ++ (arrOf PRE_first_tail_x15_r0_body.s1119 2673467).drop (arrOf PRE_first_tail_x15_r0_body.s0 2673467).length) })
kernel_rfl PRE_first_tail_x15_r0_body.zw126_4910 : (PRE_first_tail_x15_r0_body.s1120.heap.get 4910).isSome = true
kernel_rfl PRE_first_tail_x15_r0_body.zw126_2673472 : (PRE_first_tail_x15_r0_body.s1120.heap.get 2673472).isSome = true
kernel_rfl PRE_first_tail_x15_r0_body.zw126_2673473 : (PRE_first_tail_x15_r0_body.s1120.heap.get 2673473).isSome = true
-- the heap: the changed list in range, holding the stage's written and fresh addresses; the canonical side's image
kernel_rfl PRE_first_tail_x15_r0_body.zclbd126 : PRE_first_tail_x15_r0_body.cl126.all (fun b => Nat.blt (b / 4096) (4 ^ 31)) = true
kernel_rfl PRE_first_tail_x15_r0_body.zwr126 : PRE_first_tail_x15_r0_body.st126.wr.all (fun b => !Nat.blt b PRE_first_tail_x15_r0_body.s1118.next || PRE_first_tail_x15_r0_body.cl126.contains b) = true
def PRE_first_tail_x15_r0_body.zl126 : List Nat := PRE_first_tail_x15_r0_body.cl126.filter fun a => !(List.contains [2665, 2673467] a)
kernel_rfl PRE_first_tail_x15_r0_body.zimgE126 : PRE_first_tail_x15_r0_body.zl126.map (fun a => PRE_first_tail_x15_r0_body.s1119.heap.get (PRE_first_tail_x15_r0_body.kappa126.a a)) = PRE_first_tail_x15_r0_body.zl126.map (fun a => (PRE_first_tail_x15_r0_body.s1120.heap.get a).map PRE_first_tail_x15_r0_body.kappa126.hobj)
theorem PRE_first_tail_x15_r0_body.zimg126 : HeapImg PRE_first_tail_x15_r0_body.kappa126 PRE_first_tail_x15_r0_body.s1120 PRE_first_tail_x15_r0_body.s1119 PRE_first_tail_x15_r0_body.zl126 := PRE_first_tail_x15_r0_body.zimgE126
-- the roots and their supports
kernel_rfl PRE_first_tail_x15_r0_body.zctl126 : PRE_first_tail_x15_r0_body.s1119.ctl = PRE_first_tail_x15_r0_body.kappa126.ctl PRE_first_tail_x15_r0_body.s1120.ctl
kernel_rfl PRE_first_tail_x15_r0_body.zstack126 : PRE_first_tail_x15_r0_body.s1119.stack = PRE_first_tail_x15_r0_body.s1120.stack.map PRE_first_tail_x15_r0_body.kappa126.frame
kernel_rfl PRE_first_tail_x15_r0_body.zjobs126 : PRE_first_tail_x15_r0_body.s1119.jobs = PRE_first_tail_x15_r0_body.s1120.jobs.map PRE_first_tail_x15_r0_body.kappa126.job
kernel_rfl PRE_first_tail_x15_r0_body.zstores126 : PRE_first_tail_x15_r0_body.s1119.stores = PRE_first_tail_x15_r0_body.kappa126.stores PRE_first_tail_x15_r0_body.s1120.stores
kernel_rfl PRE_first_tail_x15_r0_body.zroots126 : checkRootsSupp PRE_first_tail_x15_r0_body.s1120 5489 = true
kernel_rfl PRE_first_tail_x15_r0_body.znC126 : PRE_first_tail_x15_r0_body.S1118.tab.length + PRE_first_tail_x15_r0_body.cws126.length = 5489
-- the map as `Conv.compact_shift` states it (the call's counters for the literals)
kernel_rfl PRE_first_tail_x15_r0_body.zkap126 : PRE_first_tail_x15_r0_body.kappa126 = Conv.Map.compact PRE_first_tail_x15_r0_body.s1118.next 2775290 PRE_first_tail_x15_r0_body.S1118.tab.length PRE_first_tail_x15_r0_body.pl126 (PRE_first_tail_x15_r0_body.nr126.map NumV.ref) PRE_first_tail_x15_r0_body.kd126.big
  PRE_first_tail_x15_r0_body.kd126.region PRE_first_tail_x15_r0_body.kd126.nodeF
-- the bridge inactive at the canonical state (`Conv.FullShiftQ.toX`; the merged state's bridge is the canonical's: cbridge)
theorem PRE_first_tail_x15_r0_body.zbin126 : (Host.Ts.Sim.Full.bridgeOf PRE_first_tail_x15_r0_body.s1120.ffi).active = false := (Host.Load.Boot.replay_active Host.Load.Run.Prompt.P.oblog2818)
-- the JS bookkeeping's step (`Conv.JClean.step` over the changed list) and the canonical roots' bigint freedom
kernel_rfl PRE_first_tail_x15_r0_body.zjc126 : Conv.jcleanListB (⟨20693, 17801, 2774141, 5489⟩ : Conv.Cnt) PRE_first_tail_x15_r0_body.s1120 PRE_first_tail_x15_r0_body.cl126 = true
kernel_rfl PRE_first_tail_x15_r0_body.zroots2126 : noBigRootsP (fun i => !Conv.oldBigB (⟨20693, 17801, 2774141, 5489⟩ : Conv.Cnt) i) PRE_first_tail_x15_r0_body.s1120.trace PRE_first_tail_x15_r0_body.s1120 = true
kernel_rfl PRE_first_tail_x15_r0_body.zhm126 : Nat.ble (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s0.ffi).mlx.nnext 17774 = true
theorem PRE_first_tail_x15_r0_body.cjcl126 (h : Conv.JClean (⟨20690, 17774, 2774135, 5471⟩ : Conv.Cnt) PRE_first_tail_x15_r0_body.s1118) : Conv.JClean (⟨20693, 17801, 2774141, 5489⟩ : Conv.Cnt) PRE_first_tail_x15_r0_body.s1120 :=
  Conv.JClean.step h (Conv.Cnt.le_of_leB PRE_first_tail_x15_r0_body.cle126)
    (Conv.heap_off_setAll PRE_first_tail_x15_r0_body.cheap126 fun a ha => Nat.blt_eq.mp (List.all_eq_true.mp PRE_first_tail_x15_r0_body.zclbd126 a ha)) PRE_first_tail_x15_r0_body.zjc126

end Host.Load.Run.Tpl
