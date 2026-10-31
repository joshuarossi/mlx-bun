import host.sim.template.a4pre_first_tail_x15_r0_body.SiteS122
import host.sim.template.a4pre_first_tail_x15_r0_body.SiteK122
import host.sim.template.a4pre_first_tail_x15_r0_body.SiteF122
import host.sim.conv.CompactShift
import host.sim.template.Check
import host.sim.BigFreeP
import host.sim.template.CallGen
set_option Elab.async false
namespace Host.Load.Run.Tpl
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
open Host.Ts Host.Ts.Sim Host.Ts.Sim.Template

/-! The compaction's state shift at call site 122 of chain `PRE_first_tail_x15_r0_body` (`Conv.compact_shift`): the call `PRE_first_tail_x15_r0_body.s1075`, the merged
state `PRE_first_tail_x15_r0_body.s1076`, the canonical state `PRE_first_tail_x15_r0_body.s1077`; its frames [2665,2673467,2673472,2673473] (kept arrays [2665,2673467]). -/

-- the map's places and counters
kernel_rfl PRE_first_tail_x15_r0_body.zpl122 : PRE_first_tail_x15_r0_body.pl122.all (Nat.ble PRE_first_tail_x15_r0_body.s1075.next) = true
kernel_rfl PRE_first_tail_x15_r0_body.zplnd122 : nodupT PRE_first_tail_x15_r0_body.pl122 PTrie.nil = true
kernel_rfl PRE_first_tail_x15_r0_body.zn1122 : Nat.ble PRE_first_tail_x15_r0_body.s1075.next 2770418 = true
kernel_rfl PRE_first_tail_x15_r0_body.zfirst122 : Nat.ble aFirst PRE_first_tail_x15_r0_body.s1075.next = true
kernel_rfl PRE_first_tail_x15_r0_body.zscn122 : PRE_first_tail_x15_r0_body.s1077.next = PRE_first_tail_x15_r0_body.s1075.next + PRE_first_tail_x15_r0_body.pl122.length
kernel_rfl PRE_first_tail_x15_r0_body.zsmn122 : PRE_first_tail_x15_r0_body.s1076.next = 2770418
kernel_rfl PRE_first_tail_x15_r0_body.zgrow122 : Nat.ble PRE_first_tail_x15_r0_body.s1077.next PRE_first_tail_x15_r0_body.s1076.next = true
-- the tables
kernel_rfl PRE_first_tail_x15_r0_body.zfresh122 : PRE_first_tail_x15_r0_body.S1075.tab.all (fun e => PRE_first_tail_x15_r0_body.cws122.all fun v => e.noVar v) = true
kernel_rfl PRE_first_tail_x15_r0_body.zcnd122 : nodupT PRE_first_tail_x15_r0_body.cws122 PTrie.nil = true
kernel_rfl PRE_first_tail_x15_r0_body.znrHi122 : PRE_first_tail_x15_r0_body.nr122.all (fun r => Nat.blt r PRE_first_tail_x15_r0_body.S1076.tab.length) = true
-- the frames: every framed address below the call's counter; the kept arrays the chain start's, extended in the merged state
kernel_rfl PRE_first_tail_x15_r0_body.zfrlt122 : [2665, 2673467, 2673472, 2673473].all (fun a => Nat.blt a PRE_first_tail_x15_r0_body.s1075.next) = true
kernel_rfl PRE_first_tail_x15_r0_body.zg122_2665 : PRE_first_tail_x15_r0_body.s1077.heap.get 2665 = some (.obj (objOf PRE_first_tail_x15_r0_body.s1077 2665))
kernel_rfl PRE_first_tail_x15_r0_body.zk122_2665 : (objOf PRE_first_tail_x15_r0_body.s1077 2665).kind = .array (arrOf PRE_first_tail_x15_r0_body.s0 2665)
kernel_rfl PRE_first_tail_x15_r0_body.zm122_2665 : PRE_first_tail_x15_r0_body.s1076.heap.get 2665 = some (.obj { PRE_first_tail_x15_r0_body.kappa122.obj (objOf PRE_first_tail_x15_r0_body.s1077 2665) with
  kind := .array (arrOf PRE_first_tail_x15_r0_body.s0 2665 ++ (arrOf PRE_first_tail_x15_r0_body.s1076 2665).drop (arrOf PRE_first_tail_x15_r0_body.s0 2665).length) })
kernel_rfl PRE_first_tail_x15_r0_body.zg122_2673467 : PRE_first_tail_x15_r0_body.s1077.heap.get 2673467 = some (.obj (objOf PRE_first_tail_x15_r0_body.s1077 2673467))
kernel_rfl PRE_first_tail_x15_r0_body.zk122_2673467 : (objOf PRE_first_tail_x15_r0_body.s1077 2673467).kind = .array (arrOf PRE_first_tail_x15_r0_body.s0 2673467)
kernel_rfl PRE_first_tail_x15_r0_body.zm122_2673467 : PRE_first_tail_x15_r0_body.s1076.heap.get 2673467 = some (.obj { PRE_first_tail_x15_r0_body.kappa122.obj (objOf PRE_first_tail_x15_r0_body.s1077 2673467) with
  kind := .array (arrOf PRE_first_tail_x15_r0_body.s0 2673467 ++ (arrOf PRE_first_tail_x15_r0_body.s1076 2673467).drop (arrOf PRE_first_tail_x15_r0_body.s0 2673467).length) })
kernel_rfl PRE_first_tail_x15_r0_body.zw122_4910 : (PRE_first_tail_x15_r0_body.s1077.heap.get 4910).isSome = true
kernel_rfl PRE_first_tail_x15_r0_body.zw122_2673472 : (PRE_first_tail_x15_r0_body.s1077.heap.get 2673472).isSome = true
kernel_rfl PRE_first_tail_x15_r0_body.zw122_2673473 : (PRE_first_tail_x15_r0_body.s1077.heap.get 2673473).isSome = true
-- the heap: the changed list in range, holding the stage's written and fresh addresses; the canonical side's image
kernel_rfl PRE_first_tail_x15_r0_body.zclbd122 : PRE_first_tail_x15_r0_body.cl122.all (fun b => Nat.blt (b / 4096) (4 ^ 31)) = true
kernel_rfl PRE_first_tail_x15_r0_body.zwr122 : PRE_first_tail_x15_r0_body.st122.wr.all (fun b => !Nat.blt b PRE_first_tail_x15_r0_body.s1075.next || PRE_first_tail_x15_r0_body.cl122.contains b) = true
def PRE_first_tail_x15_r0_body.zl122 : List Nat := PRE_first_tail_x15_r0_body.cl122.filter fun a => !(List.contains [2665, 2673467] a)
kernel_rfl PRE_first_tail_x15_r0_body.zimgE122 : PRE_first_tail_x15_r0_body.zl122.map (fun a => PRE_first_tail_x15_r0_body.s1076.heap.get (PRE_first_tail_x15_r0_body.kappa122.a a)) = PRE_first_tail_x15_r0_body.zl122.map (fun a => (PRE_first_tail_x15_r0_body.s1077.heap.get a).map PRE_first_tail_x15_r0_body.kappa122.hobj)
theorem PRE_first_tail_x15_r0_body.zimg122 : HeapImg PRE_first_tail_x15_r0_body.kappa122 PRE_first_tail_x15_r0_body.s1077 PRE_first_tail_x15_r0_body.s1076 PRE_first_tail_x15_r0_body.zl122 := PRE_first_tail_x15_r0_body.zimgE122
-- the roots and their supports
kernel_rfl PRE_first_tail_x15_r0_body.zctl122 : PRE_first_tail_x15_r0_body.s1076.ctl = PRE_first_tail_x15_r0_body.kappa122.ctl PRE_first_tail_x15_r0_body.s1077.ctl
kernel_rfl PRE_first_tail_x15_r0_body.zstack122 : PRE_first_tail_x15_r0_body.s1076.stack = PRE_first_tail_x15_r0_body.s1077.stack.map PRE_first_tail_x15_r0_body.kappa122.frame
kernel_rfl PRE_first_tail_x15_r0_body.zjobs122 : PRE_first_tail_x15_r0_body.s1076.jobs = PRE_first_tail_x15_r0_body.s1077.jobs.map PRE_first_tail_x15_r0_body.kappa122.job
kernel_rfl PRE_first_tail_x15_r0_body.zstores122 : PRE_first_tail_x15_r0_body.s1076.stores = PRE_first_tail_x15_r0_body.kappa122.stores PRE_first_tail_x15_r0_body.s1077.stores
kernel_rfl PRE_first_tail_x15_r0_body.zroots122 : checkRootsSupp PRE_first_tail_x15_r0_body.s1077 5269 = true
kernel_rfl PRE_first_tail_x15_r0_body.znC122 : PRE_first_tail_x15_r0_body.S1075.tab.length + PRE_first_tail_x15_r0_body.cws122.length = 5269
-- the map as `Conv.compact_shift` states it (the call's counters for the literals)
kernel_rfl PRE_first_tail_x15_r0_body.zkap122 : PRE_first_tail_x15_r0_body.kappa122 = Conv.Map.compact PRE_first_tail_x15_r0_body.s1075.next 2770418 PRE_first_tail_x15_r0_body.S1075.tab.length PRE_first_tail_x15_r0_body.pl122 (PRE_first_tail_x15_r0_body.nr122.map NumV.ref) PRE_first_tail_x15_r0_body.kd122.big
  PRE_first_tail_x15_r0_body.kd122.region PRE_first_tail_x15_r0_body.kd122.nodeF
-- the bridge inactive at the canonical state (`Conv.FullShiftQ.toX`; the merged state's bridge is the canonical's: cbridge)
theorem PRE_first_tail_x15_r0_body.zbin122 : (Host.Ts.Sim.Full.bridgeOf PRE_first_tail_x15_r0_body.s1077.ffi).active = false := (Host.Load.Boot.replay_active Host.Load.Run.Prompt.P.oblog2818)
-- the JS bookkeeping's step (`Conv.JClean.step` over the changed list) and the canonical roots' bigint freedom
kernel_rfl PRE_first_tail_x15_r0_body.zjc122 : Conv.jcleanListB (⟨20599, 17692, 2770408, 5269⟩ : Conv.Cnt) PRE_first_tail_x15_r0_body.s1077 PRE_first_tail_x15_r0_body.cl122 = true
kernel_rfl PRE_first_tail_x15_r0_body.zroots2122 : noBigRootsP (fun i => !Conv.oldBigB (⟨20599, 17692, 2770408, 5269⟩ : Conv.Cnt) i) PRE_first_tail_x15_r0_body.s1077.trace PRE_first_tail_x15_r0_body.s1077 = true
kernel_rfl PRE_first_tail_x15_r0_body.zhm122 : Nat.ble (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s0.ffi).mlx.nnext 17692 = true
theorem PRE_first_tail_x15_r0_body.cjcl122 (h : Conv.JClean (⟨20599, 17692, 2770407, 5269⟩ : Conv.Cnt) PRE_first_tail_x15_r0_body.s1075) : Conv.JClean (⟨20599, 17692, 2770408, 5269⟩ : Conv.Cnt) PRE_first_tail_x15_r0_body.s1077 :=
  Conv.JClean.step h (Conv.Cnt.le_of_leB PRE_first_tail_x15_r0_body.cle122)
    (Conv.heap_off_setAll PRE_first_tail_x15_r0_body.cheap122 fun a ha => Nat.blt_eq.mp (List.all_eq_true.mp PRE_first_tail_x15_r0_body.zclbd122 a ha)) PRE_first_tail_x15_r0_body.zjc122

end Host.Load.Run.Tpl
