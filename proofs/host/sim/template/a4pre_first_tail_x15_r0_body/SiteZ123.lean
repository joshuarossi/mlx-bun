import host.sim.template.a4pre_first_tail_x15_r0_body.SiteS123
import host.sim.template.a4pre_first_tail_x15_r0_body.SiteK123
import host.sim.template.a4pre_first_tail_x15_r0_body.SiteF123
import host.sim.conv.CompactShift
import host.sim.template.Check
import host.sim.BigFreeP
import host.sim.template.CallGen
set_option Elab.async false
namespace Host.Load.Run.Tpl
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
open Host.Ts Host.Ts.Sim Host.Ts.Sim.Template

/-! The compaction's state shift at call site 123 of chain `PRE_first_tail_x15_r0_body` (`Conv.compact_shift`): the call `PRE_first_tail_x15_r0_body.s1091`, the merged
state `PRE_first_tail_x15_r0_body.s1092`, the canonical state `PRE_first_tail_x15_r0_body.s1093`; its frames [2665,2673467,2673472,2673473] (kept arrays [2665,2673467]). -/

-- the map's places and counters
kernel_rfl PRE_first_tail_x15_r0_body.zpl123 : PRE_first_tail_x15_r0_body.pl123.all (Nat.ble PRE_first_tail_x15_r0_body.s1091.next) = true
kernel_rfl PRE_first_tail_x15_r0_body.zplnd123 : nodupT PRE_first_tail_x15_r0_body.pl123 PTrie.nil = true
kernel_rfl PRE_first_tail_x15_r0_body.zn1123 : Nat.ble PRE_first_tail_x15_r0_body.s1091.next 2773034 = true
kernel_rfl PRE_first_tail_x15_r0_body.zfirst123 : Nat.ble aFirst PRE_first_tail_x15_r0_body.s1091.next = true
kernel_rfl PRE_first_tail_x15_r0_body.zscn123 : PRE_first_tail_x15_r0_body.s1093.next = PRE_first_tail_x15_r0_body.s1091.next + PRE_first_tail_x15_r0_body.pl123.length
kernel_rfl PRE_first_tail_x15_r0_body.zsmn123 : PRE_first_tail_x15_r0_body.s1092.next = 2773034
kernel_rfl PRE_first_tail_x15_r0_body.zgrow123 : Nat.ble PRE_first_tail_x15_r0_body.s1093.next PRE_first_tail_x15_r0_body.s1092.next = true
-- the tables
kernel_rfl PRE_first_tail_x15_r0_body.zfresh123 : PRE_first_tail_x15_r0_body.S1091.tab.all (fun e => PRE_first_tail_x15_r0_body.cws123.all fun v => e.noVar v) = true
kernel_rfl PRE_first_tail_x15_r0_body.zcnd123 : nodupT PRE_first_tail_x15_r0_body.cws123 PTrie.nil = true
kernel_rfl PRE_first_tail_x15_r0_body.znrHi123 : PRE_first_tail_x15_r0_body.nr123.all (fun r => Nat.blt r PRE_first_tail_x15_r0_body.S1092.tab.length) = true
-- the frames: every framed address below the call's counter; the kept arrays the chain start's, extended in the merged state
kernel_rfl PRE_first_tail_x15_r0_body.zfrlt123 : [2665, 2673467, 2673472, 2673473].all (fun a => Nat.blt a PRE_first_tail_x15_r0_body.s1091.next) = true
kernel_rfl PRE_first_tail_x15_r0_body.zg123_2665 : PRE_first_tail_x15_r0_body.s1093.heap.get 2665 = some (.obj (objOf PRE_first_tail_x15_r0_body.s1093 2665))
kernel_rfl PRE_first_tail_x15_r0_body.zk123_2665 : (objOf PRE_first_tail_x15_r0_body.s1093 2665).kind = .array (arrOf PRE_first_tail_x15_r0_body.s0 2665)
kernel_rfl PRE_first_tail_x15_r0_body.zm123_2665 : PRE_first_tail_x15_r0_body.s1092.heap.get 2665 = some (.obj { PRE_first_tail_x15_r0_body.kappa123.obj (objOf PRE_first_tail_x15_r0_body.s1093 2665) with
  kind := .array (arrOf PRE_first_tail_x15_r0_body.s0 2665 ++ (arrOf PRE_first_tail_x15_r0_body.s1092 2665).drop (arrOf PRE_first_tail_x15_r0_body.s0 2665).length) })
kernel_rfl PRE_first_tail_x15_r0_body.zg123_2673467 : PRE_first_tail_x15_r0_body.s1093.heap.get 2673467 = some (.obj (objOf PRE_first_tail_x15_r0_body.s1093 2673467))
kernel_rfl PRE_first_tail_x15_r0_body.zk123_2673467 : (objOf PRE_first_tail_x15_r0_body.s1093 2673467).kind = .array (arrOf PRE_first_tail_x15_r0_body.s0 2673467)
kernel_rfl PRE_first_tail_x15_r0_body.zm123_2673467 : PRE_first_tail_x15_r0_body.s1092.heap.get 2673467 = some (.obj { PRE_first_tail_x15_r0_body.kappa123.obj (objOf PRE_first_tail_x15_r0_body.s1093 2673467) with
  kind := .array (arrOf PRE_first_tail_x15_r0_body.s0 2673467 ++ (arrOf PRE_first_tail_x15_r0_body.s1092 2673467).drop (arrOf PRE_first_tail_x15_r0_body.s0 2673467).length) })
kernel_rfl PRE_first_tail_x15_r0_body.zw123_4910 : (PRE_first_tail_x15_r0_body.s1093.heap.get 4910).isSome = true
kernel_rfl PRE_first_tail_x15_r0_body.zw123_2673472 : (PRE_first_tail_x15_r0_body.s1093.heap.get 2673472).isSome = true
kernel_rfl PRE_first_tail_x15_r0_body.zw123_2673473 : (PRE_first_tail_x15_r0_body.s1093.heap.get 2673473).isSome = true
-- the heap: the changed list in range, holding the stage's written and fresh addresses; the canonical side's image
kernel_rfl PRE_first_tail_x15_r0_body.zclbd123 : PRE_first_tail_x15_r0_body.cl123.all (fun b => Nat.blt (b / 4096) (4 ^ 31)) = true
kernel_rfl PRE_first_tail_x15_r0_body.zwr123 : PRE_first_tail_x15_r0_body.st123.wr.all (fun b => !Nat.blt b PRE_first_tail_x15_r0_body.s1091.next || PRE_first_tail_x15_r0_body.cl123.contains b) = true
def PRE_first_tail_x15_r0_body.zl123 : List Nat := PRE_first_tail_x15_r0_body.cl123.filter fun a => !(List.contains [2665, 2673467] a)
kernel_rfl PRE_first_tail_x15_r0_body.zimgE123 : PRE_first_tail_x15_r0_body.zl123.map (fun a => PRE_first_tail_x15_r0_body.s1092.heap.get (PRE_first_tail_x15_r0_body.kappa123.a a)) = PRE_first_tail_x15_r0_body.zl123.map (fun a => (PRE_first_tail_x15_r0_body.s1093.heap.get a).map PRE_first_tail_x15_r0_body.kappa123.hobj)
theorem PRE_first_tail_x15_r0_body.zimg123 : HeapImg PRE_first_tail_x15_r0_body.kappa123 PRE_first_tail_x15_r0_body.s1093 PRE_first_tail_x15_r0_body.s1092 PRE_first_tail_x15_r0_body.zl123 := PRE_first_tail_x15_r0_body.zimgE123
-- the roots and their supports
kernel_rfl PRE_first_tail_x15_r0_body.zctl123 : PRE_first_tail_x15_r0_body.s1092.ctl = PRE_first_tail_x15_r0_body.kappa123.ctl PRE_first_tail_x15_r0_body.s1093.ctl
kernel_rfl PRE_first_tail_x15_r0_body.zstack123 : PRE_first_tail_x15_r0_body.s1092.stack = PRE_first_tail_x15_r0_body.s1093.stack.map PRE_first_tail_x15_r0_body.kappa123.frame
kernel_rfl PRE_first_tail_x15_r0_body.zjobs123 : PRE_first_tail_x15_r0_body.s1092.jobs = PRE_first_tail_x15_r0_body.s1093.jobs.map PRE_first_tail_x15_r0_body.kappa123.job
kernel_rfl PRE_first_tail_x15_r0_body.zstores123 : PRE_first_tail_x15_r0_body.s1092.stores = PRE_first_tail_x15_r0_body.kappa123.stores PRE_first_tail_x15_r0_body.s1093.stores
kernel_rfl PRE_first_tail_x15_r0_body.zroots123 : checkRootsSupp PRE_first_tail_x15_r0_body.s1093 5360 = true
kernel_rfl PRE_first_tail_x15_r0_body.znC123 : PRE_first_tail_x15_r0_body.S1091.tab.length + PRE_first_tail_x15_r0_body.cws123.length = 5360
-- the map as `Conv.compact_shift` states it (the call's counters for the literals)
kernel_rfl PRE_first_tail_x15_r0_body.zkap123 : PRE_first_tail_x15_r0_body.kappa123 = Conv.Map.compact PRE_first_tail_x15_r0_body.s1091.next 2773034 PRE_first_tail_x15_r0_body.S1091.tab.length PRE_first_tail_x15_r0_body.pl123 (PRE_first_tail_x15_r0_body.nr123.map NumV.ref) PRE_first_tail_x15_r0_body.kd123.big
  PRE_first_tail_x15_r0_body.kd123.region PRE_first_tail_x15_r0_body.kd123.nodeF
-- the bridge inactive at the canonical state (`Conv.FullShiftQ.toX`; the merged state's bridge is the canonical's: cbridge)
theorem PRE_first_tail_x15_r0_body.zbin123 : (Host.Ts.Sim.Full.bridgeOf PRE_first_tail_x15_r0_body.s1093.ffi).active = false := (Host.Load.Boot.replay_active Host.Load.Run.Prompt.P.oblog2818)
-- the JS bookkeeping's step (`Conv.JClean.step` over the changed list) and the canonical roots' bigint freedom
kernel_rfl PRE_first_tail_x15_r0_body.zjc123 : Conv.jcleanListB (⟨20636, 17738, 2771885, 5360⟩ : Conv.Cnt) PRE_first_tail_x15_r0_body.s1093 PRE_first_tail_x15_r0_body.cl123 = true
kernel_rfl PRE_first_tail_x15_r0_body.zroots2123 : noBigRootsP (fun i => !Conv.oldBigB (⟨20636, 17738, 2771885, 5360⟩ : Conv.Cnt) i) PRE_first_tail_x15_r0_body.s1093.trace PRE_first_tail_x15_r0_body.s1093 = true
kernel_rfl PRE_first_tail_x15_r0_body.zhm123 : Nat.ble (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s0.ffi).mlx.nnext 17711 = true
theorem PRE_first_tail_x15_r0_body.cjcl123 (h : Conv.JClean (⟨20633, 17711, 2771879, 5342⟩ : Conv.Cnt) PRE_first_tail_x15_r0_body.s1091) : Conv.JClean (⟨20636, 17738, 2771885, 5360⟩ : Conv.Cnt) PRE_first_tail_x15_r0_body.s1093 :=
  Conv.JClean.step h (Conv.Cnt.le_of_leB PRE_first_tail_x15_r0_body.cle123)
    (Conv.heap_off_setAll PRE_first_tail_x15_r0_body.cheap123 fun a ha => Nat.blt_eq.mp (List.all_eq_true.mp PRE_first_tail_x15_r0_body.zclbd123 a ha)) PRE_first_tail_x15_r0_body.zjc123

end Host.Load.Run.Tpl
