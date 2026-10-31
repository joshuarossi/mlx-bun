import host.sim.template.a4pre_first_tail_x15_r0_body.SiteS129
import host.sim.template.a4pre_first_tail_x15_r0_body.SiteK129
import host.sim.template.a4pre_first_tail_x15_r0_body.SiteF129
import host.sim.conv.CompactShift
import host.sim.template.Check
import host.sim.BigFreeP
import host.sim.template.CallGen
set_option Elab.async false
namespace Host.Load.Run.Tpl
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
open Host.Ts Host.Ts.Sim Host.Ts.Sim.Template

/-! The compaction's state shift at call site 129 of chain `PRE_first_tail_x15_r0_body` (`Conv.compact_shift`): the call `PRE_first_tail_x15_r0_body.s1252`, the merged
state `PRE_first_tail_x15_r0_body.s1253`, the canonical state `PRE_first_tail_x15_r0_body.s1254`; its frames [2665,2673467,2673472,2673473] (kept arrays [2665,2673467]). -/

-- the map's places and counters
kernel_rfl PRE_first_tail_x15_r0_body.zpl129 : PRE_first_tail_x15_r0_body.pl129.all (Nat.ble PRE_first_tail_x15_r0_body.s1252.next) = true
kernel_rfl PRE_first_tail_x15_r0_body.zplnd129 : nodupT PRE_first_tail_x15_r0_body.pl129 PTrie.nil = true
kernel_rfl PRE_first_tail_x15_r0_body.zn1129 : Nat.ble PRE_first_tail_x15_r0_body.s1252.next 2777021 = true
kernel_rfl PRE_first_tail_x15_r0_body.zfirst129 : Nat.ble aFirst PRE_first_tail_x15_r0_body.s1252.next = true
kernel_rfl PRE_first_tail_x15_r0_body.zscn129 : PRE_first_tail_x15_r0_body.s1254.next = PRE_first_tail_x15_r0_body.s1252.next + PRE_first_tail_x15_r0_body.pl129.length
kernel_rfl PRE_first_tail_x15_r0_body.zsmn129 : PRE_first_tail_x15_r0_body.s1253.next = 2777021
kernel_rfl PRE_first_tail_x15_r0_body.zgrow129 : Nat.ble PRE_first_tail_x15_r0_body.s1254.next PRE_first_tail_x15_r0_body.s1253.next = true
-- the tables
kernel_rfl PRE_first_tail_x15_r0_body.zfresh129 : PRE_first_tail_x15_r0_body.S1252.tab.all (fun e => PRE_first_tail_x15_r0_body.cws129.all fun v => e.noVar v) = true
kernel_rfl PRE_first_tail_x15_r0_body.zcnd129 : nodupT PRE_first_tail_x15_r0_body.cws129 PTrie.nil = true
kernel_rfl PRE_first_tail_x15_r0_body.znrHi129 : PRE_first_tail_x15_r0_body.nr129.all (fun r => Nat.blt r PRE_first_tail_x15_r0_body.S1253.tab.length) = true
-- the frames: every framed address below the call's counter; the kept arrays the chain start's, extended in the merged state
kernel_rfl PRE_first_tail_x15_r0_body.zfrlt129 : [2665, 2673467, 2673472, 2673473].all (fun a => Nat.blt a PRE_first_tail_x15_r0_body.s1252.next) = true
kernel_rfl PRE_first_tail_x15_r0_body.zg129_2665 : PRE_first_tail_x15_r0_body.s1254.heap.get 2665 = some (.obj (objOf PRE_first_tail_x15_r0_body.s1254 2665))
kernel_rfl PRE_first_tail_x15_r0_body.zk129_2665 : (objOf PRE_first_tail_x15_r0_body.s1254 2665).kind = .array (arrOf PRE_first_tail_x15_r0_body.s0 2665)
kernel_rfl PRE_first_tail_x15_r0_body.zm129_2665 : PRE_first_tail_x15_r0_body.s1253.heap.get 2665 = some (.obj { PRE_first_tail_x15_r0_body.kappa129.obj (objOf PRE_first_tail_x15_r0_body.s1254 2665) with
  kind := .array (arrOf PRE_first_tail_x15_r0_body.s0 2665 ++ (arrOf PRE_first_tail_x15_r0_body.s1253 2665).drop (arrOf PRE_first_tail_x15_r0_body.s0 2665).length) })
kernel_rfl PRE_first_tail_x15_r0_body.zg129_2673467 : PRE_first_tail_x15_r0_body.s1254.heap.get 2673467 = some (.obj (objOf PRE_first_tail_x15_r0_body.s1254 2673467))
kernel_rfl PRE_first_tail_x15_r0_body.zk129_2673467 : (objOf PRE_first_tail_x15_r0_body.s1254 2673467).kind = .array (arrOf PRE_first_tail_x15_r0_body.s0 2673467)
kernel_rfl PRE_first_tail_x15_r0_body.zm129_2673467 : PRE_first_tail_x15_r0_body.s1253.heap.get 2673467 = some (.obj { PRE_first_tail_x15_r0_body.kappa129.obj (objOf PRE_first_tail_x15_r0_body.s1254 2673467) with
  kind := .array (arrOf PRE_first_tail_x15_r0_body.s0 2673467 ++ (arrOf PRE_first_tail_x15_r0_body.s1253 2673467).drop (arrOf PRE_first_tail_x15_r0_body.s0 2673467).length) })
kernel_rfl PRE_first_tail_x15_r0_body.zw129_4910 : (PRE_first_tail_x15_r0_body.s1254.heap.get 4910).isSome = true
kernel_rfl PRE_first_tail_x15_r0_body.zw129_2673472 : (PRE_first_tail_x15_r0_body.s1254.heap.get 2673472).isSome = true
kernel_rfl PRE_first_tail_x15_r0_body.zw129_2673473 : (PRE_first_tail_x15_r0_body.s1254.heap.get 2673473).isSome = true
-- the heap: the changed list in range, holding the stage's written and fresh addresses; the canonical side's image
kernel_rfl PRE_first_tail_x15_r0_body.zclbd129 : PRE_first_tail_x15_r0_body.cl129.all (fun b => Nat.blt (b / 4096) (4 ^ 31)) = true
kernel_rfl PRE_first_tail_x15_r0_body.zwr129 : PRE_first_tail_x15_r0_body.st129.wr.all (fun b => !Nat.blt b PRE_first_tail_x15_r0_body.s1252.next || PRE_first_tail_x15_r0_body.cl129.contains b) = true
def PRE_first_tail_x15_r0_body.zl129 : List Nat := PRE_first_tail_x15_r0_body.cl129.filter fun a => !(List.contains [2665, 2673467] a)
kernel_rfl PRE_first_tail_x15_r0_body.zimgE129 : PRE_first_tail_x15_r0_body.zl129.map (fun a => PRE_first_tail_x15_r0_body.s1253.heap.get (PRE_first_tail_x15_r0_body.kappa129.a a)) = PRE_first_tail_x15_r0_body.zl129.map (fun a => (PRE_first_tail_x15_r0_body.s1254.heap.get a).map PRE_first_tail_x15_r0_body.kappa129.hobj)
theorem PRE_first_tail_x15_r0_body.zimg129 : HeapImg PRE_first_tail_x15_r0_body.kappa129 PRE_first_tail_x15_r0_body.s1254 PRE_first_tail_x15_r0_body.s1253 PRE_first_tail_x15_r0_body.zl129 := PRE_first_tail_x15_r0_body.zimgE129
-- the roots and their supports
kernel_rfl PRE_first_tail_x15_r0_body.zctl129 : PRE_first_tail_x15_r0_body.s1253.ctl = PRE_first_tail_x15_r0_body.kappa129.ctl PRE_first_tail_x15_r0_body.s1254.ctl
kernel_rfl PRE_first_tail_x15_r0_body.zstack129 : PRE_first_tail_x15_r0_body.s1253.stack = PRE_first_tail_x15_r0_body.s1254.stack.map PRE_first_tail_x15_r0_body.kappa129.frame
kernel_rfl PRE_first_tail_x15_r0_body.zjobs129 : PRE_first_tail_x15_r0_body.s1253.jobs = PRE_first_tail_x15_r0_body.s1254.jobs.map PRE_first_tail_x15_r0_body.kappa129.job
kernel_rfl PRE_first_tail_x15_r0_body.zstores129 : PRE_first_tail_x15_r0_body.s1253.stores = PRE_first_tail_x15_r0_body.kappa129.stores PRE_first_tail_x15_r0_body.s1254.stores
kernel_rfl PRE_first_tail_x15_r0_body.zroots129 : checkRootsSupp PRE_first_tail_x15_r0_body.s1254 5613 = true
kernel_rfl PRE_first_tail_x15_r0_body.znC129 : PRE_first_tail_x15_r0_body.S1252.tab.length + PRE_first_tail_x15_r0_body.cws129.length = 5613
-- the map as `Conv.compact_shift` states it (the call's counters for the literals)
kernel_rfl PRE_first_tail_x15_r0_body.zkap129 : PRE_first_tail_x15_r0_body.kappa129 = Conv.Map.compact PRE_first_tail_x15_r0_body.s1252.next 2777021 PRE_first_tail_x15_r0_body.S1252.tab.length PRE_first_tail_x15_r0_body.pl129 (PRE_first_tail_x15_r0_body.nr129.map NumV.ref) PRE_first_tail_x15_r0_body.kd129.big
  PRE_first_tail_x15_r0_body.kd129.region PRE_first_tail_x15_r0_body.kd129.nodeF
-- the bridge inactive at the canonical state (`Conv.FullShiftQ.toX`; the merged state's bridge is the canonical's: cbridge)
theorem PRE_first_tail_x15_r0_body.zbin129 : (Host.Ts.Sim.Full.bridgeOf PRE_first_tail_x15_r0_body.s1254.ffi).active = false := (Host.Load.Boot.replay_active Host.Load.Run.Prompt.P.oblog2818)
-- the JS bookkeeping's step (`Conv.JClean.step` over the changed list) and the canonical roots' bigint freedom
kernel_rfl PRE_first_tail_x15_r0_body.zjc129 : Conv.jcleanListB (⟨20757, 17852, 2776671, 5613⟩ : Conv.Cnt) PRE_first_tail_x15_r0_body.s1254 PRE_first_tail_x15_r0_body.cl129 = true
kernel_rfl PRE_first_tail_x15_r0_body.zrootsB129 : noBigRootsP (fun i => !Conv.oldBigB (⟨20757, 17852, 2776671, 5613⟩ : Conv.Cnt) i) PRE_first_tail_x15_r0_body.s1254.trace PRE_first_tail_x15_r0_body.s1254 = true
kernel_rfl PRE_first_tail_x15_r0_body.zhm129 : Nat.ble (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s0.ffi).mlx.nnext 17846 = true
theorem PRE_first_tail_x15_r0_body.cjcl129 (h : Conv.JClean (⟨20753, 17846, 2776656, 5604⟩ : Conv.Cnt) PRE_first_tail_x15_r0_body.s1252) : Conv.JClean (⟨20757, 17852, 2776671, 5613⟩ : Conv.Cnt) PRE_first_tail_x15_r0_body.s1254 :=
  Conv.JClean.step h (Conv.Cnt.le_of_leB PRE_first_tail_x15_r0_body.cle129)
    (Conv.heap_off_setAll PRE_first_tail_x15_r0_body.cheap129 fun a ha => Nat.blt_eq.mp (List.all_eq_true.mp PRE_first_tail_x15_r0_body.zclbd129 a ha)) PRE_first_tail_x15_r0_body.zjc129

end Host.Load.Run.Tpl
