import host.sim.template.a4pre_first_tail_x15_r0_body.SiteS54
import host.sim.template.a4pre_first_tail_x15_r0_body.SiteK54
import host.sim.template.a4pre_first_tail_x15_r0_body.SiteF54
import host.sim.conv.CompactShift
import host.sim.template.Check
import host.sim.BigFreeP
import host.sim.template.CallGen
set_option Elab.async false
namespace Host.Load.Run.Tpl
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
open Host.Ts Host.Ts.Sim Host.Ts.Sim.Template

/-! The compaction's state shift at call site 54 of chain `PRE_first_tail_x15_r0_body` (`Conv.compact_shift`): the call `PRE_first_tail_x15_r0_body.s488`, the merged
state `PRE_first_tail_x15_r0_body.s489`, the canonical state `PRE_first_tail_x15_r0_body.s490`; its frames [2665,2673467,2673472,2673473] (kept arrays [2665,2673467]). -/

-- the map's places and counters
kernel_rfl PRE_first_tail_x15_r0_body.zpl54 : PRE_first_tail_x15_r0_body.pl54.all (Nat.ble PRE_first_tail_x15_r0_body.s488.next) = true
kernel_rfl PRE_first_tail_x15_r0_body.zplnd54 : nodupT PRE_first_tail_x15_r0_body.pl54 PTrie.nil = true
kernel_rfl PRE_first_tail_x15_r0_body.zn154 : Nat.ble PRE_first_tail_x15_r0_body.s488.next 2718798 = true
kernel_rfl PRE_first_tail_x15_r0_body.zfirst54 : Nat.ble aFirst PRE_first_tail_x15_r0_body.s488.next = true
kernel_rfl PRE_first_tail_x15_r0_body.zscn54 : PRE_first_tail_x15_r0_body.s490.next = PRE_first_tail_x15_r0_body.s488.next + PRE_first_tail_x15_r0_body.pl54.length
kernel_rfl PRE_first_tail_x15_r0_body.zsmn54 : PRE_first_tail_x15_r0_body.s489.next = 2718798
kernel_rfl PRE_first_tail_x15_r0_body.zgrow54 : Nat.ble PRE_first_tail_x15_r0_body.s490.next PRE_first_tail_x15_r0_body.s489.next = true
-- the tables
kernel_rfl PRE_first_tail_x15_r0_body.zfresh54 : PRE_first_tail_x15_r0_body.S488.tab.all (fun e => PRE_first_tail_x15_r0_body.cws54.all fun v => e.noVar v) = true
kernel_rfl PRE_first_tail_x15_r0_body.zcnd54 : nodupT PRE_first_tail_x15_r0_body.cws54 PTrie.nil = true
kernel_rfl PRE_first_tail_x15_r0_body.znrHi54 : PRE_first_tail_x15_r0_body.nr54.all (fun r => Nat.blt r PRE_first_tail_x15_r0_body.S489.tab.length) = true
-- the frames: every framed address below the call's counter; the kept arrays the chain start's, extended in the merged state
kernel_rfl PRE_first_tail_x15_r0_body.zfrlt54 : [2665, 2673467, 2673472, 2673473].all (fun a => Nat.blt a PRE_first_tail_x15_r0_body.s488.next) = true
kernel_rfl PRE_first_tail_x15_r0_body.zg54_2665 : PRE_first_tail_x15_r0_body.s490.heap.get 2665 = some (.obj (objOf PRE_first_tail_x15_r0_body.s490 2665))
kernel_rfl PRE_first_tail_x15_r0_body.zk54_2665 : (objOf PRE_first_tail_x15_r0_body.s490 2665).kind = .array (arrOf PRE_first_tail_x15_r0_body.s0 2665)
kernel_rfl PRE_first_tail_x15_r0_body.zm54_2665 : PRE_first_tail_x15_r0_body.s489.heap.get 2665 = some (.obj { PRE_first_tail_x15_r0_body.kappa54.obj (objOf PRE_first_tail_x15_r0_body.s490 2665) with
  kind := .array (arrOf PRE_first_tail_x15_r0_body.s0 2665 ++ (arrOf PRE_first_tail_x15_r0_body.s489 2665).drop (arrOf PRE_first_tail_x15_r0_body.s0 2665).length) })
kernel_rfl PRE_first_tail_x15_r0_body.zg54_2673467 : PRE_first_tail_x15_r0_body.s490.heap.get 2673467 = some (.obj (objOf PRE_first_tail_x15_r0_body.s490 2673467))
kernel_rfl PRE_first_tail_x15_r0_body.zk54_2673467 : (objOf PRE_first_tail_x15_r0_body.s490 2673467).kind = .array (arrOf PRE_first_tail_x15_r0_body.s0 2673467)
kernel_rfl PRE_first_tail_x15_r0_body.zm54_2673467 : PRE_first_tail_x15_r0_body.s489.heap.get 2673467 = some (.obj { PRE_first_tail_x15_r0_body.kappa54.obj (objOf PRE_first_tail_x15_r0_body.s490 2673467) with
  kind := .array (arrOf PRE_first_tail_x15_r0_body.s0 2673467 ++ (arrOf PRE_first_tail_x15_r0_body.s489 2673467).drop (arrOf PRE_first_tail_x15_r0_body.s0 2673467).length) })
kernel_rfl PRE_first_tail_x15_r0_body.zw54_4910 : (PRE_first_tail_x15_r0_body.s490.heap.get 4910).isSome = true
kernel_rfl PRE_first_tail_x15_r0_body.zw54_2673472 : (PRE_first_tail_x15_r0_body.s490.heap.get 2673472).isSome = true
kernel_rfl PRE_first_tail_x15_r0_body.zw54_2673473 : (PRE_first_tail_x15_r0_body.s490.heap.get 2673473).isSome = true
-- the heap: the changed list in range, holding the stage's written and fresh addresses; the canonical side's image
kernel_rfl PRE_first_tail_x15_r0_body.zclbd54 : PRE_first_tail_x15_r0_body.cl54.all (fun b => Nat.blt (b / 4096) (4 ^ 31)) = true
kernel_rfl PRE_first_tail_x15_r0_body.zwr54 : PRE_first_tail_x15_r0_body.st54.wr.all (fun b => !Nat.blt b PRE_first_tail_x15_r0_body.s488.next || PRE_first_tail_x15_r0_body.cl54.contains b) = true
def PRE_first_tail_x15_r0_body.zl54 : List Nat := PRE_first_tail_x15_r0_body.cl54.filter fun a => !(List.contains [2665, 2673467] a)
kernel_rfl PRE_first_tail_x15_r0_body.zimgE54 : PRE_first_tail_x15_r0_body.zl54.map (fun a => PRE_first_tail_x15_r0_body.s489.heap.get (PRE_first_tail_x15_r0_body.kappa54.a a)) = PRE_first_tail_x15_r0_body.zl54.map (fun a => (PRE_first_tail_x15_r0_body.s490.heap.get a).map PRE_first_tail_x15_r0_body.kappa54.hobj)
theorem PRE_first_tail_x15_r0_body.zimg54 : HeapImg PRE_first_tail_x15_r0_body.kappa54 PRE_first_tail_x15_r0_body.s490 PRE_first_tail_x15_r0_body.s489 PRE_first_tail_x15_r0_body.zl54 := PRE_first_tail_x15_r0_body.zimgE54
-- the roots and their supports
kernel_rfl PRE_first_tail_x15_r0_body.zctl54 : PRE_first_tail_x15_r0_body.s489.ctl = PRE_first_tail_x15_r0_body.kappa54.ctl PRE_first_tail_x15_r0_body.s490.ctl
kernel_rfl PRE_first_tail_x15_r0_body.zstack54 : PRE_first_tail_x15_r0_body.s489.stack = PRE_first_tail_x15_r0_body.s490.stack.map PRE_first_tail_x15_r0_body.kappa54.frame
kernel_rfl PRE_first_tail_x15_r0_body.zjobs54 : PRE_first_tail_x15_r0_body.s489.jobs = PRE_first_tail_x15_r0_body.s490.jobs.map PRE_first_tail_x15_r0_body.kappa54.job
kernel_rfl PRE_first_tail_x15_r0_body.zstores54 : PRE_first_tail_x15_r0_body.s489.stores = PRE_first_tail_x15_r0_body.kappa54.stores PRE_first_tail_x15_r0_body.s490.stores
kernel_rfl PRE_first_tail_x15_r0_body.zroots54 : checkRootsSupp PRE_first_tail_x15_r0_body.s490 2411 = true
kernel_rfl PRE_first_tail_x15_r0_body.znC54 : PRE_first_tail_x15_r0_body.S488.tab.length + PRE_first_tail_x15_r0_body.cws54.length = 2411
-- the map as `Conv.compact_shift` states it (the call's counters for the literals)
kernel_rfl PRE_first_tail_x15_r0_body.zkap54 : PRE_first_tail_x15_r0_body.kappa54 = Conv.Map.compact PRE_first_tail_x15_r0_body.s488.next 2718798 PRE_first_tail_x15_r0_body.S488.tab.length PRE_first_tail_x15_r0_body.pl54 (PRE_first_tail_x15_r0_body.nr54.map NumV.ref) PRE_first_tail_x15_r0_body.kd54.big
  PRE_first_tail_x15_r0_body.kd54.region PRE_first_tail_x15_r0_body.kd54.nodeF
-- the bridge inactive at the canonical state (`Conv.FullShiftQ.toX`; the merged state's bridge is the canonical's: cbridge)
theorem PRE_first_tail_x15_r0_body.zbin54 : (Host.Ts.Sim.Full.bridgeOf PRE_first_tail_x15_r0_body.s490.ffi).active = false := (Host.Load.Boot.replay_active Host.Load.Run.Prompt.P.oblog2818)
-- the JS bookkeeping's step (`Conv.JClean.step` over the changed list) and the canonical roots' bigint freedom
kernel_rfl PRE_first_tail_x15_r0_body.zjc54 : Conv.jcleanListB (⟨19277, 16379, 2717649, 2411⟩ : Conv.Cnt) PRE_first_tail_x15_r0_body.s490 PRE_first_tail_x15_r0_body.cl54 = true
kernel_rfl PRE_first_tail_x15_r0_body.zroots254 : noBigRootsP (fun i => !Conv.oldBigB (⟨19277, 16379, 2717649, 2411⟩ : Conv.Cnt) i) PRE_first_tail_x15_r0_body.s490.trace PRE_first_tail_x15_r0_body.s490 = true
kernel_rfl PRE_first_tail_x15_r0_body.zhm54 : Nat.ble (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s0.ffi).mlx.nnext 16352 = true
theorem PRE_first_tail_x15_r0_body.cjcl54 (h : Conv.JClean (⟨19274, 16352, 2717643, 2393⟩ : Conv.Cnt) PRE_first_tail_x15_r0_body.s488) : Conv.JClean (⟨19277, 16379, 2717649, 2411⟩ : Conv.Cnt) PRE_first_tail_x15_r0_body.s490 :=
  Conv.JClean.step h (Conv.Cnt.le_of_leB PRE_first_tail_x15_r0_body.cle54)
    (Conv.heap_off_setAll PRE_first_tail_x15_r0_body.cheap54 fun a ha => Nat.blt_eq.mp (List.all_eq_true.mp PRE_first_tail_x15_r0_body.zclbd54 a ha)) PRE_first_tail_x15_r0_body.zjc54

end Host.Load.Run.Tpl
