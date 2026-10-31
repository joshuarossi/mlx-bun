import host.sim.template.a4pre_first_tail_x15_r0_body.SiteS131
import host.sim.template.a4pre_first_tail_x15_r0_body.SiteK131
import host.sim.template.a4pre_first_tail_x15_r0_body.SiteF131
import host.sim.conv.CompactShift
import host.sim.template.Check
import host.sim.BigFreeP
import host.sim.template.CallGen
set_option Elab.async false
namespace Host.Load.Run.Tpl
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
open Host.Ts Host.Ts.Sim Host.Ts.Sim.Template

/-! The compaction's state shift at call site 131 of chain `PRE_first_tail_x15_r0_body` (`Conv.compact_shift`): the call `PRE_first_tail_x15_r0_body.s1264`, the merged
state `PRE_first_tail_x15_r0_body.s1265`, the canonical state `PRE_first_tail_x15_r0_body.s1266`; its frames [2665,2673467,2673472,2673473] (kept arrays [2665,2673467]). -/

-- the map's places and counters
kernel_rfl PRE_first_tail_x15_r0_body.zpl131 : PRE_first_tail_x15_r0_body.pl131.all (Nat.ble PRE_first_tail_x15_r0_body.s1264.next) = true
kernel_rfl PRE_first_tail_x15_r0_body.zplnd131 : nodupT PRE_first_tail_x15_r0_body.pl131 PTrie.nil = true
kernel_rfl PRE_first_tail_x15_r0_body.zn1131 : Nat.ble PRE_first_tail_x15_r0_body.s1264.next 2777552 = true
kernel_rfl PRE_first_tail_x15_r0_body.zfirst131 : Nat.ble aFirst PRE_first_tail_x15_r0_body.s1264.next = true
kernel_rfl PRE_first_tail_x15_r0_body.zscn131 : PRE_first_tail_x15_r0_body.s1266.next = PRE_first_tail_x15_r0_body.s1264.next + PRE_first_tail_x15_r0_body.pl131.length
kernel_rfl PRE_first_tail_x15_r0_body.zsmn131 : PRE_first_tail_x15_r0_body.s1265.next = 2777552
kernel_rfl PRE_first_tail_x15_r0_body.zgrow131 : Nat.ble PRE_first_tail_x15_r0_body.s1266.next PRE_first_tail_x15_r0_body.s1265.next = true
-- the tables
kernel_rfl PRE_first_tail_x15_r0_body.zfresh131 : PRE_first_tail_x15_r0_body.S1264.tab.all (fun e => PRE_first_tail_x15_r0_body.cws131.all fun v => e.noVar v) = true
kernel_rfl PRE_first_tail_x15_r0_body.zcnd131 : nodupT PRE_first_tail_x15_r0_body.cws131 PTrie.nil = true
kernel_rfl PRE_first_tail_x15_r0_body.znrHi131 : PRE_first_tail_x15_r0_body.nr131.all (fun r => Nat.blt r PRE_first_tail_x15_r0_body.S1265.tab.length) = true
-- the frames: every framed address below the call's counter; the kept arrays the chain start's, extended in the merged state
kernel_rfl PRE_first_tail_x15_r0_body.zfrlt131 : [2665, 2673467, 2673472, 2673473].all (fun a => Nat.blt a PRE_first_tail_x15_r0_body.s1264.next) = true
kernel_rfl PRE_first_tail_x15_r0_body.zg131_2665 : PRE_first_tail_x15_r0_body.s1266.heap.get 2665 = some (.obj (objOf PRE_first_tail_x15_r0_body.s1266 2665))
kernel_rfl PRE_first_tail_x15_r0_body.zk131_2665 : (objOf PRE_first_tail_x15_r0_body.s1266 2665).kind = .array (arrOf PRE_first_tail_x15_r0_body.s0 2665)
kernel_rfl PRE_first_tail_x15_r0_body.zm131_2665 : PRE_first_tail_x15_r0_body.s1265.heap.get 2665 = some (.obj { PRE_first_tail_x15_r0_body.kappa131.obj (objOf PRE_first_tail_x15_r0_body.s1266 2665) with
  kind := .array (arrOf PRE_first_tail_x15_r0_body.s0 2665 ++ (arrOf PRE_first_tail_x15_r0_body.s1265 2665).drop (arrOf PRE_first_tail_x15_r0_body.s0 2665).length) })
kernel_rfl PRE_first_tail_x15_r0_body.zg131_2673467 : PRE_first_tail_x15_r0_body.s1266.heap.get 2673467 = some (.obj (objOf PRE_first_tail_x15_r0_body.s1266 2673467))
kernel_rfl PRE_first_tail_x15_r0_body.zk131_2673467 : (objOf PRE_first_tail_x15_r0_body.s1266 2673467).kind = .array (arrOf PRE_first_tail_x15_r0_body.s0 2673467)
kernel_rfl PRE_first_tail_x15_r0_body.zm131_2673467 : PRE_first_tail_x15_r0_body.s1265.heap.get 2673467 = some (.obj { PRE_first_tail_x15_r0_body.kappa131.obj (objOf PRE_first_tail_x15_r0_body.s1266 2673467) with
  kind := .array (arrOf PRE_first_tail_x15_r0_body.s0 2673467 ++ (arrOf PRE_first_tail_x15_r0_body.s1265 2673467).drop (arrOf PRE_first_tail_x15_r0_body.s0 2673467).length) })
kernel_rfl PRE_first_tail_x15_r0_body.zw131_4910 : (PRE_first_tail_x15_r0_body.s1266.heap.get 4910).isSome = true
kernel_rfl PRE_first_tail_x15_r0_body.zw131_2673472 : (PRE_first_tail_x15_r0_body.s1266.heap.get 2673472).isSome = true
kernel_rfl PRE_first_tail_x15_r0_body.zw131_2673473 : (PRE_first_tail_x15_r0_body.s1266.heap.get 2673473).isSome = true
-- the heap: the changed list in range, holding the stage's written and fresh addresses; the canonical side's image
kernel_rfl PRE_first_tail_x15_r0_body.zclbd131 : PRE_first_tail_x15_r0_body.cl131.all (fun b => Nat.blt (b / 4096) (4 ^ 31)) = true
kernel_rfl PRE_first_tail_x15_r0_body.zwr131 : PRE_first_tail_x15_r0_body.st131.wr.all (fun b => !Nat.blt b PRE_first_tail_x15_r0_body.s1264.next || PRE_first_tail_x15_r0_body.cl131.contains b) = true
def PRE_first_tail_x15_r0_body.zl131 : List Nat := PRE_first_tail_x15_r0_body.cl131.filter fun a => !(List.contains [2665, 2673467] a)
kernel_rfl PRE_first_tail_x15_r0_body.zimgE131 : PRE_first_tail_x15_r0_body.zl131.map (fun a => PRE_first_tail_x15_r0_body.s1265.heap.get (PRE_first_tail_x15_r0_body.kappa131.a a)) = PRE_first_tail_x15_r0_body.zl131.map (fun a => (PRE_first_tail_x15_r0_body.s1266.heap.get a).map PRE_first_tail_x15_r0_body.kappa131.hobj)
theorem PRE_first_tail_x15_r0_body.zimg131 : HeapImg PRE_first_tail_x15_r0_body.kappa131 PRE_first_tail_x15_r0_body.s1266 PRE_first_tail_x15_r0_body.s1265 PRE_first_tail_x15_r0_body.zl131 := PRE_first_tail_x15_r0_body.zimgE131
-- the roots and their supports
kernel_rfl PRE_first_tail_x15_r0_body.zctl131 : PRE_first_tail_x15_r0_body.s1265.ctl = PRE_first_tail_x15_r0_body.kappa131.ctl PRE_first_tail_x15_r0_body.s1266.ctl
kernel_rfl PRE_first_tail_x15_r0_body.zstack131 : PRE_first_tail_x15_r0_body.s1265.stack = PRE_first_tail_x15_r0_body.s1266.stack.map PRE_first_tail_x15_r0_body.kappa131.frame
kernel_rfl PRE_first_tail_x15_r0_body.zjobs131 : PRE_first_tail_x15_r0_body.s1265.jobs = PRE_first_tail_x15_r0_body.s1266.jobs.map PRE_first_tail_x15_r0_body.kappa131.job
kernel_rfl PRE_first_tail_x15_r0_body.zstores131 : PRE_first_tail_x15_r0_body.s1265.stores = PRE_first_tail_x15_r0_body.kappa131.stores PRE_first_tail_x15_r0_body.s1266.stores
kernel_rfl PRE_first_tail_x15_r0_body.zroots131 : checkRootsSupp PRE_first_tail_x15_r0_body.s1266 5653 = true
kernel_rfl PRE_first_tail_x15_r0_body.znC131 : PRE_first_tail_x15_r0_body.S1264.tab.length + PRE_first_tail_x15_r0_body.cws131.length = 5653
-- the map as `Conv.compact_shift` states it (the call's counters for the literals)
kernel_rfl PRE_first_tail_x15_r0_body.zkap131 : PRE_first_tail_x15_r0_body.kappa131 = Conv.Map.compact PRE_first_tail_x15_r0_body.s1264.next 2777552 PRE_first_tail_x15_r0_body.S1264.tab.length PRE_first_tail_x15_r0_body.pl131 (PRE_first_tail_x15_r0_body.nr131.map NumV.ref) PRE_first_tail_x15_r0_body.kd131.big
  PRE_first_tail_x15_r0_body.kd131.region PRE_first_tail_x15_r0_body.kd131.nodeF
-- the bridge inactive at the canonical state (`Conv.FullShiftQ.toX`; the merged state's bridge is the canonical's: cbridge)
theorem PRE_first_tail_x15_r0_body.zbin131 : (Host.Ts.Sim.Full.bridgeOf PRE_first_tail_x15_r0_body.s1266.ffi).active = false := (Host.Load.Boot.replay_active Host.Load.Run.Prompt.P.oblog2818)
-- the JS bookkeeping's step (`Conv.JClean.step` over the changed list) and the canonical roots' bigint freedom
kernel_rfl PRE_first_tail_x15_r0_body.zjc131 : Conv.jcleanListB (⟨20777, 17866, 2777542, 5653⟩ : Conv.Cnt) PRE_first_tail_x15_r0_body.s1266 PRE_first_tail_x15_r0_body.cl131 = true
kernel_rfl PRE_first_tail_x15_r0_body.zrootsB131 : noBigRootsP (fun i => !Conv.oldBigB (⟨20777, 17866, 2777542, 5653⟩ : Conv.Cnt) i) PRE_first_tail_x15_r0_body.s1266.trace PRE_first_tail_x15_r0_body.s1266 = true
kernel_rfl PRE_first_tail_x15_r0_body.zhm131 : Nat.ble (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s0.ffi).mlx.nnext 17866 = true
theorem PRE_first_tail_x15_r0_body.cjcl131 (h : Conv.JClean (⟨20777, 17866, 2777541, 5653⟩ : Conv.Cnt) PRE_first_tail_x15_r0_body.s1264) : Conv.JClean (⟨20777, 17866, 2777542, 5653⟩ : Conv.Cnt) PRE_first_tail_x15_r0_body.s1266 :=
  Conv.JClean.step h (Conv.Cnt.le_of_leB PRE_first_tail_x15_r0_body.cle131)
    (Conv.heap_off_setAll PRE_first_tail_x15_r0_body.cheap131 fun a ha => Nat.blt_eq.mp (List.all_eq_true.mp PRE_first_tail_x15_r0_body.zclbd131 a ha)) PRE_first_tail_x15_r0_body.zjc131

end Host.Load.Run.Tpl
