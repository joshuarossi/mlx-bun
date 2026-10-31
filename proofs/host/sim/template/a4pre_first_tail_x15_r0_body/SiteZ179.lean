import host.sim.template.a4pre_first_tail_x15_r0_body.SiteS179
import host.sim.template.a4pre_first_tail_x15_r0_body.SiteK179
import host.sim.template.a4pre_first_tail_x15_r0_body.SiteF179
import host.sim.conv.CompactShift
import host.sim.template.Check
import host.sim.BigFreeP
import host.sim.template.CallGen
set_option Elab.async false
namespace Host.Load.Run.Tpl
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
open Host.Ts Host.Ts.Sim Host.Ts.Sim.Template

/-! The compaction's state shift at call site 179 of chain `PRE_first_tail_x15_r0_body` (`Conv.compact_shift`): the call `PRE_first_tail_x15_r0_body.s1573`, the merged
state `PRE_first_tail_x15_r0_body.s1574`, the canonical state `PRE_first_tail_x15_r0_body.s1575`; its frames [2665,2673467,2673472,2673473] (kept arrays [2665,2673467]). -/

-- the map's places and counters
kernel_rfl PRE_first_tail_x15_r0_body.zpl179 : PRE_first_tail_x15_r0_body.pl179.all (Nat.ble PRE_first_tail_x15_r0_body.s1573.next) = true
kernel_rfl PRE_first_tail_x15_r0_body.zplnd179 : nodupT PRE_first_tail_x15_r0_body.pl179 PTrie.nil = true
kernel_rfl PRE_first_tail_x15_r0_body.zn1179 : Nat.ble PRE_first_tail_x15_r0_body.s1573.next 2815249 = true
kernel_rfl PRE_first_tail_x15_r0_body.zfirst179 : Nat.ble aFirst PRE_first_tail_x15_r0_body.s1573.next = true
kernel_rfl PRE_first_tail_x15_r0_body.zscn179 : PRE_first_tail_x15_r0_body.s1575.next = PRE_first_tail_x15_r0_body.s1573.next + PRE_first_tail_x15_r0_body.pl179.length
kernel_rfl PRE_first_tail_x15_r0_body.zsmn179 : PRE_first_tail_x15_r0_body.s1574.next = 2815249
kernel_rfl PRE_first_tail_x15_r0_body.zgrow179 : Nat.ble PRE_first_tail_x15_r0_body.s1575.next PRE_first_tail_x15_r0_body.s1574.next = true
-- the tables
kernel_rfl PRE_first_tail_x15_r0_body.zfresh179 : PRE_first_tail_x15_r0_body.S1573.tab.all (fun e => PRE_first_tail_x15_r0_body.cws179.all fun v => e.noVar v) = true
kernel_rfl PRE_first_tail_x15_r0_body.zcnd179 : nodupT PRE_first_tail_x15_r0_body.cws179 PTrie.nil = true
kernel_rfl PRE_first_tail_x15_r0_body.znrHi179 : PRE_first_tail_x15_r0_body.nr179.all (fun r => Nat.blt r PRE_first_tail_x15_r0_body.S1574.tab.length) = true
-- the frames: every framed address below the call's counter; the kept arrays the chain start's, extended in the merged state
kernel_rfl PRE_first_tail_x15_r0_body.zfrlt179 : [2665, 2673467, 2673472, 2673473].all (fun a => Nat.blt a PRE_first_tail_x15_r0_body.s1573.next) = true
kernel_rfl PRE_first_tail_x15_r0_body.zg179_2665 : PRE_first_tail_x15_r0_body.s1575.heap.get 2665 = some (.obj (objOf PRE_first_tail_x15_r0_body.s1575 2665))
kernel_rfl PRE_first_tail_x15_r0_body.zk179_2665 : (objOf PRE_first_tail_x15_r0_body.s1575 2665).kind = .array (arrOf PRE_first_tail_x15_r0_body.s0 2665)
kernel_rfl PRE_first_tail_x15_r0_body.zm179_2665 : PRE_first_tail_x15_r0_body.s1574.heap.get 2665 = some (.obj { PRE_first_tail_x15_r0_body.kappa179.obj (objOf PRE_first_tail_x15_r0_body.s1575 2665) with
  kind := .array (arrOf PRE_first_tail_x15_r0_body.s0 2665 ++ (arrOf PRE_first_tail_x15_r0_body.s1574 2665).drop (arrOf PRE_first_tail_x15_r0_body.s0 2665).length) })
kernel_rfl PRE_first_tail_x15_r0_body.zg179_2673467 : PRE_first_tail_x15_r0_body.s1575.heap.get 2673467 = some (.obj (objOf PRE_first_tail_x15_r0_body.s1575 2673467))
kernel_rfl PRE_first_tail_x15_r0_body.zk179_2673467 : (objOf PRE_first_tail_x15_r0_body.s1575 2673467).kind = .array (arrOf PRE_first_tail_x15_r0_body.s0 2673467)
kernel_rfl PRE_first_tail_x15_r0_body.zm179_2673467 : PRE_first_tail_x15_r0_body.s1574.heap.get 2673467 = some (.obj { PRE_first_tail_x15_r0_body.kappa179.obj (objOf PRE_first_tail_x15_r0_body.s1575 2673467) with
  kind := .array (arrOf PRE_first_tail_x15_r0_body.s0 2673467 ++ (arrOf PRE_first_tail_x15_r0_body.s1574 2673467).drop (arrOf PRE_first_tail_x15_r0_body.s0 2673467).length) })
kernel_rfl PRE_first_tail_x15_r0_body.zw179_4910 : (PRE_first_tail_x15_r0_body.s1575.heap.get 4910).isSome = true
kernel_rfl PRE_first_tail_x15_r0_body.zw179_2673472 : (PRE_first_tail_x15_r0_body.s1575.heap.get 2673472).isSome = true
kernel_rfl PRE_first_tail_x15_r0_body.zw179_2673473 : (PRE_first_tail_x15_r0_body.s1575.heap.get 2673473).isSome = true
-- the heap: the changed list in range, holding the stage's written and fresh addresses; the canonical side's image
kernel_rfl PRE_first_tail_x15_r0_body.zclbd179 : PRE_first_tail_x15_r0_body.cl179.all (fun b => Nat.blt (b / 4096) (4 ^ 31)) = true
kernel_rfl PRE_first_tail_x15_r0_body.zwr179 : PRE_first_tail_x15_r0_body.st179.wr.all (fun b => !Nat.blt b PRE_first_tail_x15_r0_body.s1573.next || PRE_first_tail_x15_r0_body.cl179.contains b) = true
def PRE_first_tail_x15_r0_body.zl179 : List Nat := PRE_first_tail_x15_r0_body.cl179.filter fun a => !(List.contains [2665, 2673467] a)
kernel_rfl PRE_first_tail_x15_r0_body.zimgE179 : PRE_first_tail_x15_r0_body.zl179.map (fun a => PRE_first_tail_x15_r0_body.s1574.heap.get (PRE_first_tail_x15_r0_body.kappa179.a a)) = PRE_first_tail_x15_r0_body.zl179.map (fun a => (PRE_first_tail_x15_r0_body.s1575.heap.get a).map PRE_first_tail_x15_r0_body.kappa179.hobj)
theorem PRE_first_tail_x15_r0_body.zimg179 : HeapImg PRE_first_tail_x15_r0_body.kappa179 PRE_first_tail_x15_r0_body.s1575 PRE_first_tail_x15_r0_body.s1574 PRE_first_tail_x15_r0_body.zl179 := PRE_first_tail_x15_r0_body.zimgE179
-- the roots and their supports
kernel_rfl PRE_first_tail_x15_r0_body.zctl179 : PRE_first_tail_x15_r0_body.s1574.ctl = PRE_first_tail_x15_r0_body.kappa179.ctl PRE_first_tail_x15_r0_body.s1575.ctl
kernel_rfl PRE_first_tail_x15_r0_body.zstack179 : PRE_first_tail_x15_r0_body.s1574.stack = PRE_first_tail_x15_r0_body.s1575.stack.map PRE_first_tail_x15_r0_body.kappa179.frame
kernel_rfl PRE_first_tail_x15_r0_body.zjobs179 : PRE_first_tail_x15_r0_body.s1574.jobs = PRE_first_tail_x15_r0_body.s1575.jobs.map PRE_first_tail_x15_r0_body.kappa179.job
kernel_rfl PRE_first_tail_x15_r0_body.zstores179 : PRE_first_tail_x15_r0_body.s1574.stores = PRE_first_tail_x15_r0_body.kappa179.stores PRE_first_tail_x15_r0_body.s1575.stores
kernel_rfl PRE_first_tail_x15_r0_body.zroots179 : checkRootsSupp PRE_first_tail_x15_r0_body.s1575 7705 = true
kernel_rfl PRE_first_tail_x15_r0_body.znC179 : PRE_first_tail_x15_r0_body.S1573.tab.length + PRE_first_tail_x15_r0_body.cws179.length = 7705
-- the map as `Conv.compact_shift` states it (the call's counters for the literals)
kernel_rfl PRE_first_tail_x15_r0_body.zkap179 : PRE_first_tail_x15_r0_body.kappa179 = Conv.Map.compact PRE_first_tail_x15_r0_body.s1573.next 2815249 PRE_first_tail_x15_r0_body.S1573.tab.length PRE_first_tail_x15_r0_body.pl179 (PRE_first_tail_x15_r0_body.nr179.map NumV.ref) PRE_first_tail_x15_r0_body.kd179.big
  PRE_first_tail_x15_r0_body.kd179.region PRE_first_tail_x15_r0_body.kd179.nodeF
-- the bridge inactive at the canonical state (`Conv.FullShiftQ.toX`; the merged state's bridge is the canonical's: cbridge)
theorem PRE_first_tail_x15_r0_body.zbin179 : (Host.Ts.Sim.Full.bridgeOf PRE_first_tail_x15_r0_body.s1575.ffi).active = false := (Host.Load.Boot.replay_active Host.Load.Run.Prompt.P.oblog2818)
-- the JS bookkeeping's step (`Conv.JClean.step` over the changed list) and the canonical roots' bigint freedom
kernel_rfl PRE_first_tail_x15_r0_body.zjc179 : Conv.jcleanListB (⟨21721, 18814, 2815230, 7705⟩ : Conv.Cnt) PRE_first_tail_x15_r0_body.s1575 PRE_first_tail_x15_r0_body.cl179 = true
kernel_rfl PRE_first_tail_x15_r0_body.zroots2179 : noBigRootsP (fun i => !Conv.oldBigB (⟨21721, 18814, 2815230, 7705⟩ : Conv.Cnt) i) PRE_first_tail_x15_r0_body.s1575.trace PRE_first_tail_x15_r0_body.s1575 = true
kernel_rfl PRE_first_tail_x15_r0_body.zhm179 : Nat.ble (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s0.ffi).mlx.nnext 18814 = true
theorem PRE_first_tail_x15_r0_body.cjcl179 (h : Conv.JClean (⟨21721, 18814, 2815229, 7705⟩ : Conv.Cnt) PRE_first_tail_x15_r0_body.s1573) : Conv.JClean (⟨21721, 18814, 2815230, 7705⟩ : Conv.Cnt) PRE_first_tail_x15_r0_body.s1575 :=
  Conv.JClean.step h (Conv.Cnt.le_of_leB PRE_first_tail_x15_r0_body.cle179)
    (Conv.heap_off_setAll PRE_first_tail_x15_r0_body.cheap179 fun a ha => Nat.blt_eq.mp (List.all_eq_true.mp PRE_first_tail_x15_r0_body.zclbd179 a ha)) PRE_first_tail_x15_r0_body.zjc179

end Host.Load.Run.Tpl
