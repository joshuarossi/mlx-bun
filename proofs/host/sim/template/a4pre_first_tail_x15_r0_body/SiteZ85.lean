import host.sim.template.a4pre_first_tail_x15_r0_body.SiteS85
import host.sim.template.a4pre_first_tail_x15_r0_body.SiteK85
import host.sim.template.a4pre_first_tail_x15_r0_body.SiteF85
import host.sim.conv.CompactShift
import host.sim.template.Check
import host.sim.BigFreeP
import host.sim.template.CallGen
set_option Elab.async false
namespace Host.Load.Run.Tpl
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
open Host.Ts Host.Ts.Sim Host.Ts.Sim.Template

/-! The compaction's state shift at call site 85 of chain `PRE_first_tail_x15_r0_body` (`Conv.compact_shift`): the call `PRE_first_tail_x15_r0_body.s829`, the merged
state `PRE_first_tail_x15_r0_body.s830`, the canonical state `PRE_first_tail_x15_r0_body.s831`; its frames [2665,2673467,2673472,2673473] (kept arrays [2665,2673467]). -/

-- the map's places and counters
kernel_rfl PRE_first_tail_x15_r0_body.zpl85 : PRE_first_tail_x15_r0_body.pl85.all (Nat.ble PRE_first_tail_x15_r0_body.s829.next) = true
kernel_rfl PRE_first_tail_x15_r0_body.zplnd85 : nodupT PRE_first_tail_x15_r0_body.pl85 PTrie.nil = true
kernel_rfl PRE_first_tail_x15_r0_body.zn185 : Nat.ble PRE_first_tail_x15_r0_body.s829.next 2741869 = true
kernel_rfl PRE_first_tail_x15_r0_body.zfirst85 : Nat.ble aFirst PRE_first_tail_x15_r0_body.s829.next = true
kernel_rfl PRE_first_tail_x15_r0_body.zscn85 : PRE_first_tail_x15_r0_body.s831.next = PRE_first_tail_x15_r0_body.s829.next + PRE_first_tail_x15_r0_body.pl85.length
kernel_rfl PRE_first_tail_x15_r0_body.zsmn85 : PRE_first_tail_x15_r0_body.s830.next = 2741869
kernel_rfl PRE_first_tail_x15_r0_body.zgrow85 : Nat.ble PRE_first_tail_x15_r0_body.s831.next PRE_first_tail_x15_r0_body.s830.next = true
-- the tables
kernel_rfl PRE_first_tail_x15_r0_body.zfresh85 : PRE_first_tail_x15_r0_body.S829.tab.all (fun e => PRE_first_tail_x15_r0_body.cws85.all fun v => e.noVar v) = true
kernel_rfl PRE_first_tail_x15_r0_body.zcnd85 : nodupT PRE_first_tail_x15_r0_body.cws85 PTrie.nil = true
kernel_rfl PRE_first_tail_x15_r0_body.znrHi85 : PRE_first_tail_x15_r0_body.nr85.all (fun r => Nat.blt r PRE_first_tail_x15_r0_body.S830.tab.length) = true
-- the frames: every framed address below the call's counter; the kept arrays the chain start's, extended in the merged state
kernel_rfl PRE_first_tail_x15_r0_body.zfrlt85 : [2665, 2673467, 2673472, 2673473].all (fun a => Nat.blt a PRE_first_tail_x15_r0_body.s829.next) = true
kernel_rfl PRE_first_tail_x15_r0_body.zg85_2665 : PRE_first_tail_x15_r0_body.s831.heap.get 2665 = some (.obj (objOf PRE_first_tail_x15_r0_body.s831 2665))
kernel_rfl PRE_first_tail_x15_r0_body.zk85_2665 : (objOf PRE_first_tail_x15_r0_body.s831 2665).kind = .array (arrOf PRE_first_tail_x15_r0_body.s0 2665)
kernel_rfl PRE_first_tail_x15_r0_body.zm85_2665 : PRE_first_tail_x15_r0_body.s830.heap.get 2665 = some (.obj { PRE_first_tail_x15_r0_body.kappa85.obj (objOf PRE_first_tail_x15_r0_body.s831 2665) with
  kind := .array (arrOf PRE_first_tail_x15_r0_body.s0 2665 ++ (arrOf PRE_first_tail_x15_r0_body.s830 2665).drop (arrOf PRE_first_tail_x15_r0_body.s0 2665).length) })
kernel_rfl PRE_first_tail_x15_r0_body.zg85_2673467 : PRE_first_tail_x15_r0_body.s831.heap.get 2673467 = some (.obj (objOf PRE_first_tail_x15_r0_body.s831 2673467))
kernel_rfl PRE_first_tail_x15_r0_body.zk85_2673467 : (objOf PRE_first_tail_x15_r0_body.s831 2673467).kind = .array (arrOf PRE_first_tail_x15_r0_body.s0 2673467)
kernel_rfl PRE_first_tail_x15_r0_body.zm85_2673467 : PRE_first_tail_x15_r0_body.s830.heap.get 2673467 = some (.obj { PRE_first_tail_x15_r0_body.kappa85.obj (objOf PRE_first_tail_x15_r0_body.s831 2673467) with
  kind := .array (arrOf PRE_first_tail_x15_r0_body.s0 2673467 ++ (arrOf PRE_first_tail_x15_r0_body.s830 2673467).drop (arrOf PRE_first_tail_x15_r0_body.s0 2673467).length) })
kernel_rfl PRE_first_tail_x15_r0_body.zw85_4910 : (PRE_first_tail_x15_r0_body.s831.heap.get 4910).isSome = true
kernel_rfl PRE_first_tail_x15_r0_body.zw85_2673472 : (PRE_first_tail_x15_r0_body.s831.heap.get 2673472).isSome = true
kernel_rfl PRE_first_tail_x15_r0_body.zw85_2673473 : (PRE_first_tail_x15_r0_body.s831.heap.get 2673473).isSome = true
-- the heap: the changed list in range, holding the stage's written and fresh addresses; the canonical side's image
kernel_rfl PRE_first_tail_x15_r0_body.zclbd85 : PRE_first_tail_x15_r0_body.cl85.all (fun b => Nat.blt (b / 4096) (4 ^ 31)) = true
kernel_rfl PRE_first_tail_x15_r0_body.zwr85 : PRE_first_tail_x15_r0_body.st85.wr.all (fun b => !Nat.blt b PRE_first_tail_x15_r0_body.s829.next || PRE_first_tail_x15_r0_body.cl85.contains b) = true
def PRE_first_tail_x15_r0_body.zl85 : List Nat := PRE_first_tail_x15_r0_body.cl85.filter fun a => !(List.contains [2665, 2673467] a)
kernel_rfl PRE_first_tail_x15_r0_body.zimgE85 : PRE_first_tail_x15_r0_body.zl85.map (fun a => PRE_first_tail_x15_r0_body.s830.heap.get (PRE_first_tail_x15_r0_body.kappa85.a a)) = PRE_first_tail_x15_r0_body.zl85.map (fun a => (PRE_first_tail_x15_r0_body.s831.heap.get a).map PRE_first_tail_x15_r0_body.kappa85.hobj)
theorem PRE_first_tail_x15_r0_body.zimg85 : HeapImg PRE_first_tail_x15_r0_body.kappa85 PRE_first_tail_x15_r0_body.s831 PRE_first_tail_x15_r0_body.s830 PRE_first_tail_x15_r0_body.zl85 := PRE_first_tail_x15_r0_body.zimgE85
-- the roots and their supports
kernel_rfl PRE_first_tail_x15_r0_body.zctl85 : PRE_first_tail_x15_r0_body.s830.ctl = PRE_first_tail_x15_r0_body.kappa85.ctl PRE_first_tail_x15_r0_body.s831.ctl
kernel_rfl PRE_first_tail_x15_r0_body.zstack85 : PRE_first_tail_x15_r0_body.s830.stack = PRE_first_tail_x15_r0_body.s831.stack.map PRE_first_tail_x15_r0_body.kappa85.frame
kernel_rfl PRE_first_tail_x15_r0_body.zjobs85 : PRE_first_tail_x15_r0_body.s830.jobs = PRE_first_tail_x15_r0_body.s831.jobs.map PRE_first_tail_x15_r0_body.kappa85.job
kernel_rfl PRE_first_tail_x15_r0_body.zstores85 : PRE_first_tail_x15_r0_body.s830.stores = PRE_first_tail_x15_r0_body.kappa85.stores PRE_first_tail_x15_r0_body.s831.stores
kernel_rfl PRE_first_tail_x15_r0_body.zroots85 : checkRootsSupp PRE_first_tail_x15_r0_body.s831 3713 = true
kernel_rfl PRE_first_tail_x15_r0_body.znC85 : PRE_first_tail_x15_r0_body.S829.tab.length + PRE_first_tail_x15_r0_body.cws85.length = 3713
-- the map as `Conv.compact_shift` states it (the call's counters for the literals)
kernel_rfl PRE_first_tail_x15_r0_body.zkap85 : PRE_first_tail_x15_r0_body.kappa85 = Conv.Map.compact PRE_first_tail_x15_r0_body.s829.next 2741869 PRE_first_tail_x15_r0_body.S829.tab.length PRE_first_tail_x15_r0_body.pl85 (PRE_first_tail_x15_r0_body.nr85.map NumV.ref) PRE_first_tail_x15_r0_body.kd85.big
  PRE_first_tail_x15_r0_body.kd85.region PRE_first_tail_x15_r0_body.kd85.nodeF
-- the bridge inactive at the canonical state (`Conv.FullShiftQ.toX`; the merged state's bridge is the canonical's: cbridge)
theorem PRE_first_tail_x15_r0_body.zbin85 : (Host.Ts.Sim.Full.bridgeOf PRE_first_tail_x15_r0_body.s831.ffi).active = false := (Host.Load.Boot.replay_active Host.Load.Run.Prompt.P.oblog2818)
-- the JS bookkeeping's step (`Conv.JClean.step` over the changed list) and the canonical roots' bigint freedom
kernel_rfl PRE_first_tail_x15_r0_body.zjc85 : Conv.jcleanListB (⟨19884, 16977, 2741867, 3713⟩ : Conv.Cnt) PRE_first_tail_x15_r0_body.s831 PRE_first_tail_x15_r0_body.cl85 = true
kernel_rfl PRE_first_tail_x15_r0_body.zrootsB85 : noBigRootsP (fun i => !Conv.oldBigB (⟨19884, 16977, 2741867, 3713⟩ : Conv.Cnt) i) PRE_first_tail_x15_r0_body.s831.trace PRE_first_tail_x15_r0_body.s831 = true
kernel_rfl PRE_first_tail_x15_r0_body.zhm85 : Nat.ble (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s0.ffi).mlx.nnext 16977 = true
theorem PRE_first_tail_x15_r0_body.cjcl85 (h : Conv.JClean (⟨19884, 16977, 2741867, 3713⟩ : Conv.Cnt) PRE_first_tail_x15_r0_body.s829) : Conv.JClean (⟨19884, 16977, 2741867, 3713⟩ : Conv.Cnt) PRE_first_tail_x15_r0_body.s831 :=
  Conv.JClean.step h (Conv.Cnt.le_of_leB PRE_first_tail_x15_r0_body.cle85)
    (Conv.heap_off_setAll PRE_first_tail_x15_r0_body.cheap85 fun a ha => Nat.blt_eq.mp (List.all_eq_true.mp PRE_first_tail_x15_r0_body.zclbd85 a ha)) PRE_first_tail_x15_r0_body.zjc85

end Host.Load.Run.Tpl
