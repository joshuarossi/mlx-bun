import host.sim.template.a4pre_first_tail_x15_r0_body.SiteS152
import host.sim.template.a4pre_first_tail_x15_r0_body.SiteK152
import host.sim.template.a4pre_first_tail_x15_r0_body.SiteF152
import host.sim.conv.CompactShift
import host.sim.template.Check
import host.sim.BigFreeP
import host.sim.template.CallGen
set_option Elab.async false
namespace Host.Load.Run.Tpl
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
open Host.Ts Host.Ts.Sim Host.Ts.Sim.Template

/-! The compaction's state shift at call site 152 of chain `PRE_first_tail_x15_r0_body` (`Conv.compact_shift`): the call `PRE_first_tail_x15_r0_body.s1339`, the merged
state `PRE_first_tail_x15_r0_body.s1340`, the canonical state `PRE_first_tail_x15_r0_body.s1341`; its frames [2665,2673467,2673472,2673473] (kept arrays [2665,2673467]). -/

-- the map's places and counters
kernel_rfl PRE_first_tail_x15_r0_body.zpl152 : PRE_first_tail_x15_r0_body.pl152.all (Nat.ble PRE_first_tail_x15_r0_body.s1339.next) = true
kernel_rfl PRE_first_tail_x15_r0_body.zplnd152 : nodupT PRE_first_tail_x15_r0_body.pl152 PTrie.nil = true
kernel_rfl PRE_first_tail_x15_r0_body.zn1152 : Nat.ble PRE_first_tail_x15_r0_body.s1339.next 2793774 = true
kernel_rfl PRE_first_tail_x15_r0_body.zfirst152 : Nat.ble aFirst PRE_first_tail_x15_r0_body.s1339.next = true
kernel_rfl PRE_first_tail_x15_r0_body.zscn152 : PRE_first_tail_x15_r0_body.s1341.next = PRE_first_tail_x15_r0_body.s1339.next + PRE_first_tail_x15_r0_body.pl152.length
kernel_rfl PRE_first_tail_x15_r0_body.zsmn152 : PRE_first_tail_x15_r0_body.s1340.next = 2793774
kernel_rfl PRE_first_tail_x15_r0_body.zgrow152 : Nat.ble PRE_first_tail_x15_r0_body.s1341.next PRE_first_tail_x15_r0_body.s1340.next = true
-- the tables
kernel_rfl PRE_first_tail_x15_r0_body.zfresh152 : PRE_first_tail_x15_r0_body.S1339.tab.all (fun e => PRE_first_tail_x15_r0_body.cws152.all fun v => e.noVar v) = true
kernel_rfl PRE_first_tail_x15_r0_body.zcnd152 : nodupT PRE_first_tail_x15_r0_body.cws152 PTrie.nil = true
kernel_rfl PRE_first_tail_x15_r0_body.znrHi152 : PRE_first_tail_x15_r0_body.nr152.all (fun r => Nat.blt r PRE_first_tail_x15_r0_body.S1340.tab.length) = true
-- the frames: every framed address below the call's counter; the kept arrays the chain start's, extended in the merged state
kernel_rfl PRE_first_tail_x15_r0_body.zfrlt152 : [2665, 2673467, 2673472, 2673473].all (fun a => Nat.blt a PRE_first_tail_x15_r0_body.s1339.next) = true
kernel_rfl PRE_first_tail_x15_r0_body.zg152_2665 : PRE_first_tail_x15_r0_body.s1341.heap.get 2665 = some (.obj (objOf PRE_first_tail_x15_r0_body.s1341 2665))
kernel_rfl PRE_first_tail_x15_r0_body.zk152_2665 : (objOf PRE_first_tail_x15_r0_body.s1341 2665).kind = .array (arrOf PRE_first_tail_x15_r0_body.s0 2665)
kernel_rfl PRE_first_tail_x15_r0_body.zm152_2665 : PRE_first_tail_x15_r0_body.s1340.heap.get 2665 = some (.obj { PRE_first_tail_x15_r0_body.kappa152.obj (objOf PRE_first_tail_x15_r0_body.s1341 2665) with
  kind := .array (arrOf PRE_first_tail_x15_r0_body.s0 2665 ++ (arrOf PRE_first_tail_x15_r0_body.s1340 2665).drop (arrOf PRE_first_tail_x15_r0_body.s0 2665).length) })
kernel_rfl PRE_first_tail_x15_r0_body.zg152_2673467 : PRE_first_tail_x15_r0_body.s1341.heap.get 2673467 = some (.obj (objOf PRE_first_tail_x15_r0_body.s1341 2673467))
kernel_rfl PRE_first_tail_x15_r0_body.zk152_2673467 : (objOf PRE_first_tail_x15_r0_body.s1341 2673467).kind = .array (arrOf PRE_first_tail_x15_r0_body.s0 2673467)
kernel_rfl PRE_first_tail_x15_r0_body.zm152_2673467 : PRE_first_tail_x15_r0_body.s1340.heap.get 2673467 = some (.obj { PRE_first_tail_x15_r0_body.kappa152.obj (objOf PRE_first_tail_x15_r0_body.s1341 2673467) with
  kind := .array (arrOf PRE_first_tail_x15_r0_body.s0 2673467 ++ (arrOf PRE_first_tail_x15_r0_body.s1340 2673467).drop (arrOf PRE_first_tail_x15_r0_body.s0 2673467).length) })
kernel_rfl PRE_first_tail_x15_r0_body.zw152_4910 : (PRE_first_tail_x15_r0_body.s1341.heap.get 4910).isSome = true
kernel_rfl PRE_first_tail_x15_r0_body.zw152_2673472 : (PRE_first_tail_x15_r0_body.s1341.heap.get 2673472).isSome = true
kernel_rfl PRE_first_tail_x15_r0_body.zw152_2673473 : (PRE_first_tail_x15_r0_body.s1341.heap.get 2673473).isSome = true
-- the heap: the changed list in range, holding the stage's written and fresh addresses; the canonical side's image
kernel_rfl PRE_first_tail_x15_r0_body.zclbd152 : PRE_first_tail_x15_r0_body.cl152.all (fun b => Nat.blt (b / 4096) (4 ^ 31)) = true
kernel_rfl PRE_first_tail_x15_r0_body.zwr152 : PRE_first_tail_x15_r0_body.st152.wr.all (fun b => !Nat.blt b PRE_first_tail_x15_r0_body.s1339.next || PRE_first_tail_x15_r0_body.cl152.contains b) = true
def PRE_first_tail_x15_r0_body.zl152 : List Nat := PRE_first_tail_x15_r0_body.cl152.filter fun a => !(List.contains [2665, 2673467] a)
kernel_rfl PRE_first_tail_x15_r0_body.zimgE152 : PRE_first_tail_x15_r0_body.zl152.map (fun a => PRE_first_tail_x15_r0_body.s1340.heap.get (PRE_first_tail_x15_r0_body.kappa152.a a)) = PRE_first_tail_x15_r0_body.zl152.map (fun a => (PRE_first_tail_x15_r0_body.s1341.heap.get a).map PRE_first_tail_x15_r0_body.kappa152.hobj)
theorem PRE_first_tail_x15_r0_body.zimg152 : HeapImg PRE_first_tail_x15_r0_body.kappa152 PRE_first_tail_x15_r0_body.s1341 PRE_first_tail_x15_r0_body.s1340 PRE_first_tail_x15_r0_body.zl152 := PRE_first_tail_x15_r0_body.zimgE152
-- the roots and their supports
kernel_rfl PRE_first_tail_x15_r0_body.zctl152 : PRE_first_tail_x15_r0_body.s1340.ctl = PRE_first_tail_x15_r0_body.kappa152.ctl PRE_first_tail_x15_r0_body.s1341.ctl
kernel_rfl PRE_first_tail_x15_r0_body.zstack152 : PRE_first_tail_x15_r0_body.s1340.stack = PRE_first_tail_x15_r0_body.s1341.stack.map PRE_first_tail_x15_r0_body.kappa152.frame
kernel_rfl PRE_first_tail_x15_r0_body.zjobs152 : PRE_first_tail_x15_r0_body.s1340.jobs = PRE_first_tail_x15_r0_body.s1341.jobs.map PRE_first_tail_x15_r0_body.kappa152.job
kernel_rfl PRE_first_tail_x15_r0_body.zstores152 : PRE_first_tail_x15_r0_body.s1340.stores = PRE_first_tail_x15_r0_body.kappa152.stores PRE_first_tail_x15_r0_body.s1341.stores
kernel_rfl PRE_first_tail_x15_r0_body.zroots152 : checkRootsSupp PRE_first_tail_x15_r0_body.s1341 6553 = true
kernel_rfl PRE_first_tail_x15_r0_body.znC152 : PRE_first_tail_x15_r0_body.S1339.tab.length + PRE_first_tail_x15_r0_body.cws152.length = 6553
-- the map as `Conv.compact_shift` states it (the call's counters for the literals)
kernel_rfl PRE_first_tail_x15_r0_body.zkap152 : PRE_first_tail_x15_r0_body.kappa152 = Conv.Map.compact PRE_first_tail_x15_r0_body.s1339.next 2793774 PRE_first_tail_x15_r0_body.S1339.tab.length PRE_first_tail_x15_r0_body.pl152 (PRE_first_tail_x15_r0_body.nr152.map NumV.ref) PRE_first_tail_x15_r0_body.kd152.big
  PRE_first_tail_x15_r0_body.kd152.region PRE_first_tail_x15_r0_body.kd152.nodeF
-- the bridge inactive at the canonical state (`Conv.FullShiftQ.toX`; the merged state's bridge is the canonical's: cbridge)
theorem PRE_first_tail_x15_r0_body.zbin152 : (Host.Ts.Sim.Full.bridgeOf PRE_first_tail_x15_r0_body.s1341.ffi).active = false := (Host.Load.Boot.replay_active Host.Load.Run.Prompt.P.oblog2818)
-- the JS bookkeeping's step (`Conv.JClean.step` over the changed list) and the canonical roots' bigint freedom
kernel_rfl PRE_first_tail_x15_r0_body.zjc152 : Conv.jcleanListB (⟨21185, 18292, 2793764, 6553⟩ : Conv.Cnt) PRE_first_tail_x15_r0_body.s1341 PRE_first_tail_x15_r0_body.cl152 = true
kernel_rfl PRE_first_tail_x15_r0_body.zroots2152 : noBigRootsP (fun i => !Conv.oldBigB (⟨21185, 18292, 2793764, 6553⟩ : Conv.Cnt) i) PRE_first_tail_x15_r0_body.s1341.trace PRE_first_tail_x15_r0_body.s1341 = true
kernel_rfl PRE_first_tail_x15_r0_body.zhm152 : Nat.ble (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s0.ffi).mlx.nnext 18292 = true
theorem PRE_first_tail_x15_r0_body.cjcl152 (h : Conv.JClean (⟨21185, 18292, 2793763, 6553⟩ : Conv.Cnt) PRE_first_tail_x15_r0_body.s1339) : Conv.JClean (⟨21185, 18292, 2793764, 6553⟩ : Conv.Cnt) PRE_first_tail_x15_r0_body.s1341 :=
  Conv.JClean.step h (Conv.Cnt.le_of_leB PRE_first_tail_x15_r0_body.cle152)
    (Conv.heap_off_setAll PRE_first_tail_x15_r0_body.cheap152 fun a ha => Nat.blt_eq.mp (List.all_eq_true.mp PRE_first_tail_x15_r0_body.zclbd152 a ha)) PRE_first_tail_x15_r0_body.zjc152

end Host.Load.Run.Tpl
