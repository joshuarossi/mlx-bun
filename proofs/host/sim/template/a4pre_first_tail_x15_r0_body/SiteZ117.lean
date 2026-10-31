import host.sim.template.a4pre_first_tail_x15_r0_body.SiteS117
import host.sim.template.a4pre_first_tail_x15_r0_body.SiteK117
import host.sim.template.a4pre_first_tail_x15_r0_body.SiteF117
import host.sim.conv.CompactShift
import host.sim.template.Check
import host.sim.BigFreeP
import host.sim.template.CallGen
set_option Elab.async false
namespace Host.Load.Run.Tpl
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
open Host.Ts Host.Ts.Sim Host.Ts.Sim.Template

/-! The compaction's state shift at call site 117 of chain `PRE_first_tail_x15_r0_body` (`Conv.compact_shift`): the call `PRE_first_tail_x15_r0_body.s1037`, the merged
state `PRE_first_tail_x15_r0_body.s1038`, the canonical state `PRE_first_tail_x15_r0_body.s1039`; its frames [2665,2673467,2673472,2673473] (kept arrays [2665,2673467]). -/

-- the map's places and counters
kernel_rfl PRE_first_tail_x15_r0_body.zpl117 : PRE_first_tail_x15_r0_body.pl117.all (Nat.ble PRE_first_tail_x15_r0_body.s1037.next) = true
kernel_rfl PRE_first_tail_x15_r0_body.zplnd117 : nodupT PRE_first_tail_x15_r0_body.pl117 PTrie.nil = true
kernel_rfl PRE_first_tail_x15_r0_body.zn1117 : Nat.ble PRE_first_tail_x15_r0_body.s1037.next 2767609 = true
kernel_rfl PRE_first_tail_x15_r0_body.zfirst117 : Nat.ble aFirst PRE_first_tail_x15_r0_body.s1037.next = true
kernel_rfl PRE_first_tail_x15_r0_body.zscn117 : PRE_first_tail_x15_r0_body.s1039.next = PRE_first_tail_x15_r0_body.s1037.next + PRE_first_tail_x15_r0_body.pl117.length
kernel_rfl PRE_first_tail_x15_r0_body.zsmn117 : PRE_first_tail_x15_r0_body.s1038.next = 2767609
kernel_rfl PRE_first_tail_x15_r0_body.zgrow117 : Nat.ble PRE_first_tail_x15_r0_body.s1039.next PRE_first_tail_x15_r0_body.s1038.next = true
-- the tables
kernel_rfl PRE_first_tail_x15_r0_body.zfresh117 : PRE_first_tail_x15_r0_body.S1037.tab.all (fun e => PRE_first_tail_x15_r0_body.cws117.all fun v => e.noVar v) = true
kernel_rfl PRE_first_tail_x15_r0_body.zcnd117 : nodupT PRE_first_tail_x15_r0_body.cws117 PTrie.nil = true
kernel_rfl PRE_first_tail_x15_r0_body.znrHi117 : PRE_first_tail_x15_r0_body.nr117.all (fun r => Nat.blt r PRE_first_tail_x15_r0_body.S1038.tab.length) = true
-- the frames: every framed address below the call's counter; the kept arrays the chain start's, extended in the merged state
kernel_rfl PRE_first_tail_x15_r0_body.zfrlt117 : [2665, 2673467, 2673472, 2673473].all (fun a => Nat.blt a PRE_first_tail_x15_r0_body.s1037.next) = true
kernel_rfl PRE_first_tail_x15_r0_body.zg117_2665 : PRE_first_tail_x15_r0_body.s1039.heap.get 2665 = some (.obj (objOf PRE_first_tail_x15_r0_body.s1039 2665))
kernel_rfl PRE_first_tail_x15_r0_body.zk117_2665 : (objOf PRE_first_tail_x15_r0_body.s1039 2665).kind = .array (arrOf PRE_first_tail_x15_r0_body.s0 2665)
kernel_rfl PRE_first_tail_x15_r0_body.zm117_2665 : PRE_first_tail_x15_r0_body.s1038.heap.get 2665 = some (.obj { PRE_first_tail_x15_r0_body.kappa117.obj (objOf PRE_first_tail_x15_r0_body.s1039 2665) with
  kind := .array (arrOf PRE_first_tail_x15_r0_body.s0 2665 ++ (arrOf PRE_first_tail_x15_r0_body.s1038 2665).drop (arrOf PRE_first_tail_x15_r0_body.s0 2665).length) })
kernel_rfl PRE_first_tail_x15_r0_body.zg117_2673467 : PRE_first_tail_x15_r0_body.s1039.heap.get 2673467 = some (.obj (objOf PRE_first_tail_x15_r0_body.s1039 2673467))
kernel_rfl PRE_first_tail_x15_r0_body.zk117_2673467 : (objOf PRE_first_tail_x15_r0_body.s1039 2673467).kind = .array (arrOf PRE_first_tail_x15_r0_body.s0 2673467)
kernel_rfl PRE_first_tail_x15_r0_body.zm117_2673467 : PRE_first_tail_x15_r0_body.s1038.heap.get 2673467 = some (.obj { PRE_first_tail_x15_r0_body.kappa117.obj (objOf PRE_first_tail_x15_r0_body.s1039 2673467) with
  kind := .array (arrOf PRE_first_tail_x15_r0_body.s0 2673467 ++ (arrOf PRE_first_tail_x15_r0_body.s1038 2673467).drop (arrOf PRE_first_tail_x15_r0_body.s0 2673467).length) })
kernel_rfl PRE_first_tail_x15_r0_body.zw117_4910 : (PRE_first_tail_x15_r0_body.s1039.heap.get 4910).isSome = true
kernel_rfl PRE_first_tail_x15_r0_body.zw117_2673472 : (PRE_first_tail_x15_r0_body.s1039.heap.get 2673472).isSome = true
kernel_rfl PRE_first_tail_x15_r0_body.zw117_2673473 : (PRE_first_tail_x15_r0_body.s1039.heap.get 2673473).isSome = true
-- the heap: the changed list in range, holding the stage's written and fresh addresses; the canonical side's image
kernel_rfl PRE_first_tail_x15_r0_body.zclbd117 : PRE_first_tail_x15_r0_body.cl117.all (fun b => Nat.blt (b / 4096) (4 ^ 31)) = true
kernel_rfl PRE_first_tail_x15_r0_body.zwr117 : PRE_first_tail_x15_r0_body.st117.wr.all (fun b => !Nat.blt b PRE_first_tail_x15_r0_body.s1037.next || PRE_first_tail_x15_r0_body.cl117.contains b) = true
def PRE_first_tail_x15_r0_body.zl117 : List Nat := PRE_first_tail_x15_r0_body.cl117.filter fun a => !(List.contains [2665, 2673467] a)
kernel_rfl PRE_first_tail_x15_r0_body.zimgE117 : PRE_first_tail_x15_r0_body.zl117.map (fun a => PRE_first_tail_x15_r0_body.s1038.heap.get (PRE_first_tail_x15_r0_body.kappa117.a a)) = PRE_first_tail_x15_r0_body.zl117.map (fun a => (PRE_first_tail_x15_r0_body.s1039.heap.get a).map PRE_first_tail_x15_r0_body.kappa117.hobj)
theorem PRE_first_tail_x15_r0_body.zimg117 : HeapImg PRE_first_tail_x15_r0_body.kappa117 PRE_first_tail_x15_r0_body.s1039 PRE_first_tail_x15_r0_body.s1038 PRE_first_tail_x15_r0_body.zl117 := PRE_first_tail_x15_r0_body.zimgE117
-- the roots and their supports
kernel_rfl PRE_first_tail_x15_r0_body.zctl117 : PRE_first_tail_x15_r0_body.s1038.ctl = PRE_first_tail_x15_r0_body.kappa117.ctl PRE_first_tail_x15_r0_body.s1039.ctl
kernel_rfl PRE_first_tail_x15_r0_body.zstack117 : PRE_first_tail_x15_r0_body.s1038.stack = PRE_first_tail_x15_r0_body.s1039.stack.map PRE_first_tail_x15_r0_body.kappa117.frame
kernel_rfl PRE_first_tail_x15_r0_body.zjobs117 : PRE_first_tail_x15_r0_body.s1038.jobs = PRE_first_tail_x15_r0_body.s1039.jobs.map PRE_first_tail_x15_r0_body.kappa117.job
kernel_rfl PRE_first_tail_x15_r0_body.zstores117 : PRE_first_tail_x15_r0_body.s1038.stores = PRE_first_tail_x15_r0_body.kappa117.stores PRE_first_tail_x15_r0_body.s1039.stores
kernel_rfl PRE_first_tail_x15_r0_body.zroots117 : checkRootsSupp PRE_first_tail_x15_r0_body.s1039 5100 = true
kernel_rfl PRE_first_tail_x15_r0_body.znC117 : PRE_first_tail_x15_r0_body.S1037.tab.length + PRE_first_tail_x15_r0_body.cws117.length = 5100
-- the map as `Conv.compact_shift` states it (the call's counters for the literals)
kernel_rfl PRE_first_tail_x15_r0_body.zkap117 : PRE_first_tail_x15_r0_body.kappa117 = Conv.Map.compact PRE_first_tail_x15_r0_body.s1037.next 2767609 PRE_first_tail_x15_r0_body.S1037.tab.length PRE_first_tail_x15_r0_body.pl117 (PRE_first_tail_x15_r0_body.nr117.map NumV.ref) PRE_first_tail_x15_r0_body.kd117.big
  PRE_first_tail_x15_r0_body.kd117.region PRE_first_tail_x15_r0_body.kd117.nodeF
-- the bridge inactive at the canonical state (`Conv.FullShiftQ.toX`; the merged state's bridge is the canonical's: cbridge)
theorem PRE_first_tail_x15_r0_body.zbin117 : (Host.Ts.Sim.Full.bridgeOf PRE_first_tail_x15_r0_body.s1039.ffi).active = false := (Host.Load.Boot.replay_active Host.Load.Run.Prompt.P.oblog2818)
-- the JS bookkeeping's step (`Conv.JClean.step` over the changed list) and the canonical roots' bigint freedom
kernel_rfl PRE_first_tail_x15_r0_body.zjc117 : Conv.jcleanListB (⟨20521, 17615, 2767259, 5100⟩ : Conv.Cnt) PRE_first_tail_x15_r0_body.s1039 PRE_first_tail_x15_r0_body.cl117 = true
kernel_rfl PRE_first_tail_x15_r0_body.zroots2117 : noBigRootsP (fun i => !Conv.oldBigB (⟨20521, 17615, 2767259, 5100⟩ : Conv.Cnt) i) PRE_first_tail_x15_r0_body.s1039.trace PRE_first_tail_x15_r0_body.s1039 = true
kernel_rfl PRE_first_tail_x15_r0_body.zhm117 : Nat.ble (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s0.ffi).mlx.nnext 17609 = true
theorem PRE_first_tail_x15_r0_body.cjcl117 (h : Conv.JClean (⟨20517, 17609, 2767244, 5091⟩ : Conv.Cnt) PRE_first_tail_x15_r0_body.s1037) : Conv.JClean (⟨20521, 17615, 2767259, 5100⟩ : Conv.Cnt) PRE_first_tail_x15_r0_body.s1039 :=
  Conv.JClean.step h (Conv.Cnt.le_of_leB PRE_first_tail_x15_r0_body.cle117)
    (Conv.heap_off_setAll PRE_first_tail_x15_r0_body.cheap117 fun a ha => Nat.blt_eq.mp (List.all_eq_true.mp PRE_first_tail_x15_r0_body.zclbd117 a ha)) PRE_first_tail_x15_r0_body.zjc117

end Host.Load.Run.Tpl
