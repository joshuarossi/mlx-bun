import host.sim.template.a4pre_first_tail_x15_r0_body.SiteS116
import host.sim.template.a4pre_first_tail_x15_r0_body.SiteK116
import host.sim.template.a4pre_first_tail_x15_r0_body.SiteF116
import host.sim.conv.CompactShift
import host.sim.template.Check
import host.sim.BigFreeP
import host.sim.template.CallGen
set_option Elab.async false
namespace Host.Load.Run.Tpl
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
open Host.Ts Host.Ts.Sim Host.Ts.Sim.Template

/-! The compaction's state shift at call site 116 of chain `PRE_first_tail_x15_r0_body` (`Conv.compact_shift`): the call `PRE_first_tail_x15_r0_body.s1121`, the merged
state `PRE_first_tail_x15_r0_body.s1122`, the canonical state `PRE_first_tail_x15_r0_body.s1123`; its frames [2665,2673467,2673472,2673473] (kept arrays [2665,2673467]). -/

-- the map's places and counters
kernel_rfl PRE_first_tail_x15_r0_body.zpl116 : PRE_first_tail_x15_r0_body.pl116.all (Nat.ble PRE_first_tail_x15_r0_body.s1121.next) = true
kernel_rfl PRE_first_tail_x15_r0_body.zplnd116 : nodupT PRE_first_tail_x15_r0_body.pl116 PTrie.nil = true
kernel_rfl PRE_first_tail_x15_r0_body.zn1116 : Nat.ble PRE_first_tail_x15_r0_body.s1121.next 2765518 = true
kernel_rfl PRE_first_tail_x15_r0_body.zfirst116 : Nat.ble aFirst PRE_first_tail_x15_r0_body.s1121.next = true
kernel_rfl PRE_first_tail_x15_r0_body.zscn116 : PRE_first_tail_x15_r0_body.s1123.next = PRE_first_tail_x15_r0_body.s1121.next + PRE_first_tail_x15_r0_body.pl116.length
kernel_rfl PRE_first_tail_x15_r0_body.zsmn116 : PRE_first_tail_x15_r0_body.s1122.next = 2765518
kernel_rfl PRE_first_tail_x15_r0_body.zgrow116 : Nat.ble PRE_first_tail_x15_r0_body.s1123.next PRE_first_tail_x15_r0_body.s1122.next = true
-- the tables
kernel_rfl PRE_first_tail_x15_r0_body.zfresh116 : PRE_first_tail_x15_r0_body.S1121.tab.all (fun e => PRE_first_tail_x15_r0_body.cws116.all fun v => e.noVar v) = true
kernel_rfl PRE_first_tail_x15_r0_body.zcnd116 : nodupT PRE_first_tail_x15_r0_body.cws116 PTrie.nil = true
kernel_rfl PRE_first_tail_x15_r0_body.znrHi116 : PRE_first_tail_x15_r0_body.nr116.all (fun r => Nat.blt r PRE_first_tail_x15_r0_body.S1122.tab.length) = true
-- the frames: every framed address below the call's counter; the kept arrays the chain start's, extended in the merged state
kernel_rfl PRE_first_tail_x15_r0_body.zfrlt116 : [2665, 2673467, 2673472, 2673473].all (fun a => Nat.blt a PRE_first_tail_x15_r0_body.s1121.next) = true
kernel_rfl PRE_first_tail_x15_r0_body.zg116_2665 : PRE_first_tail_x15_r0_body.s1123.heap.get 2665 = some (.obj (objOf PRE_first_tail_x15_r0_body.s1123 2665))
kernel_rfl PRE_first_tail_x15_r0_body.zk116_2665 : (objOf PRE_first_tail_x15_r0_body.s1123 2665).kind = .array (arrOf PRE_first_tail_x15_r0_body.s0 2665)
kernel_rfl PRE_first_tail_x15_r0_body.zm116_2665 : PRE_first_tail_x15_r0_body.s1122.heap.get 2665 = some (.obj { PRE_first_tail_x15_r0_body.kappa116.obj (objOf PRE_first_tail_x15_r0_body.s1123 2665) with
  kind := .array (arrOf PRE_first_tail_x15_r0_body.s0 2665 ++ (arrOf PRE_first_tail_x15_r0_body.s1122 2665).drop (arrOf PRE_first_tail_x15_r0_body.s0 2665).length) })
kernel_rfl PRE_first_tail_x15_r0_body.zg116_2673467 : PRE_first_tail_x15_r0_body.s1123.heap.get 2673467 = some (.obj (objOf PRE_first_tail_x15_r0_body.s1123 2673467))
kernel_rfl PRE_first_tail_x15_r0_body.zk116_2673467 : (objOf PRE_first_tail_x15_r0_body.s1123 2673467).kind = .array (arrOf PRE_first_tail_x15_r0_body.s0 2673467)
kernel_rfl PRE_first_tail_x15_r0_body.zm116_2673467 : PRE_first_tail_x15_r0_body.s1122.heap.get 2673467 = some (.obj { PRE_first_tail_x15_r0_body.kappa116.obj (objOf PRE_first_tail_x15_r0_body.s1123 2673467) with
  kind := .array (arrOf PRE_first_tail_x15_r0_body.s0 2673467 ++ (arrOf PRE_first_tail_x15_r0_body.s1122 2673467).drop (arrOf PRE_first_tail_x15_r0_body.s0 2673467).length) })
kernel_rfl PRE_first_tail_x15_r0_body.zw116_4910 : (PRE_first_tail_x15_r0_body.s1123.heap.get 4910).isSome = true
kernel_rfl PRE_first_tail_x15_r0_body.zw116_2673472 : (PRE_first_tail_x15_r0_body.s1123.heap.get 2673472).isSome = true
kernel_rfl PRE_first_tail_x15_r0_body.zw116_2673473 : (PRE_first_tail_x15_r0_body.s1123.heap.get 2673473).isSome = true
-- the heap: the changed list in range, holding the stage's written and fresh addresses; the canonical side's image
kernel_rfl PRE_first_tail_x15_r0_body.zclbd116 : PRE_first_tail_x15_r0_body.cl116.all (fun b => Nat.blt (b / 4096) (4 ^ 31)) = true
kernel_rfl PRE_first_tail_x15_r0_body.zwr116 : PRE_first_tail_x15_r0_body.st116.wr.all (fun b => !Nat.blt b PRE_first_tail_x15_r0_body.s1121.next || PRE_first_tail_x15_r0_body.cl116.contains b) = true
def PRE_first_tail_x15_r0_body.zl116 : List Nat := PRE_first_tail_x15_r0_body.cl116.filter fun a => !(List.contains [2665, 2673467] a)
kernel_rfl PRE_first_tail_x15_r0_body.zimgE116 : PRE_first_tail_x15_r0_body.zl116.map (fun a => PRE_first_tail_x15_r0_body.s1122.heap.get (PRE_first_tail_x15_r0_body.kappa116.a a)) = PRE_first_tail_x15_r0_body.zl116.map (fun a => (PRE_first_tail_x15_r0_body.s1123.heap.get a).map PRE_first_tail_x15_r0_body.kappa116.hobj)
theorem PRE_first_tail_x15_r0_body.zimg116 : HeapImg PRE_first_tail_x15_r0_body.kappa116 PRE_first_tail_x15_r0_body.s1123 PRE_first_tail_x15_r0_body.s1122 PRE_first_tail_x15_r0_body.zl116 := PRE_first_tail_x15_r0_body.zimgE116
-- the roots and their supports
kernel_rfl PRE_first_tail_x15_r0_body.zctl116 : PRE_first_tail_x15_r0_body.s1122.ctl = PRE_first_tail_x15_r0_body.kappa116.ctl PRE_first_tail_x15_r0_body.s1123.ctl
kernel_rfl PRE_first_tail_x15_r0_body.zstack116 : PRE_first_tail_x15_r0_body.s1122.stack = PRE_first_tail_x15_r0_body.s1123.stack.map PRE_first_tail_x15_r0_body.kappa116.frame
kernel_rfl PRE_first_tail_x15_r0_body.zjobs116 : PRE_first_tail_x15_r0_body.s1122.jobs = PRE_first_tail_x15_r0_body.s1123.jobs.map PRE_first_tail_x15_r0_body.kappa116.job
kernel_rfl PRE_first_tail_x15_r0_body.zstores116 : PRE_first_tail_x15_r0_body.s1122.stores = PRE_first_tail_x15_r0_body.kappa116.stores PRE_first_tail_x15_r0_body.s1123.stores
kernel_rfl PRE_first_tail_x15_r0_body.zroots116 : checkRootsSupp PRE_first_tail_x15_r0_body.s1123 5014 = true
kernel_rfl PRE_first_tail_x15_r0_body.znC116 : PRE_first_tail_x15_r0_body.S1121.tab.length + PRE_first_tail_x15_r0_body.cws116.length = 5014
-- the map as `Conv.compact_shift` states it (the call's counters for the literals)
kernel_rfl PRE_first_tail_x15_r0_body.zkap116 : PRE_first_tail_x15_r0_body.kappa116 = Conv.Map.compact PRE_first_tail_x15_r0_body.s1121.next 2765518 PRE_first_tail_x15_r0_body.S1121.tab.length PRE_first_tail_x15_r0_body.pl116 (PRE_first_tail_x15_r0_body.nr116.map NumV.ref) PRE_first_tail_x15_r0_body.kd116.big
  PRE_first_tail_x15_r0_body.kd116.region PRE_first_tail_x15_r0_body.kd116.nodeF
-- the bridge inactive at the canonical state (`Conv.FullShiftQ.toX`; the merged state's bridge is the canonical's: cbridge)
theorem PRE_first_tail_x15_r0_body.zbin116 : (Host.Ts.Sim.Full.bridgeOf PRE_first_tail_x15_r0_body.s1123.ffi).active = false := (Host.Load.Boot.replay_active Host.Load.Run.Prompt.P.oblog2818)
-- the JS bookkeeping's step (`Conv.JClean.step` over the changed list) and the canonical roots' bigint freedom
kernel_rfl PRE_first_tail_x15_r0_body.zjc116 : Conv.jcleanListB (⟨20477, 17581, 2765508, 5014⟩ : Conv.Cnt) PRE_first_tail_x15_r0_body.s1123 PRE_first_tail_x15_r0_body.cl116 = true
kernel_rfl PRE_first_tail_x15_r0_body.zrootsB116 : noBigRootsP (fun i => !Conv.oldBigB (⟨20477, 17581, 2765508, 5014⟩ : Conv.Cnt) i) PRE_first_tail_x15_r0_body.s1123.trace PRE_first_tail_x15_r0_body.s1123 = true
kernel_rfl PRE_first_tail_x15_r0_body.zhm116 : Nat.ble (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s0.ffi).mlx.nnext 17581 = true
theorem PRE_first_tail_x15_r0_body.cjcl116 (h : Conv.JClean (⟨20477, 17581, 2765507, 5014⟩ : Conv.Cnt) PRE_first_tail_x15_r0_body.s1121) : Conv.JClean (⟨20477, 17581, 2765508, 5014⟩ : Conv.Cnt) PRE_first_tail_x15_r0_body.s1123 :=
  Conv.JClean.step h (Conv.Cnt.le_of_leB PRE_first_tail_x15_r0_body.cle116)
    (Conv.heap_off_setAll PRE_first_tail_x15_r0_body.cheap116 fun a ha => Nat.blt_eq.mp (List.all_eq_true.mp PRE_first_tail_x15_r0_body.zclbd116 a ha)) PRE_first_tail_x15_r0_body.zjc116

end Host.Load.Run.Tpl
