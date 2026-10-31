import host.sim.template.a4pre_first_tail_x15_r0_body.SiteS141
import host.sim.template.a4pre_first_tail_x15_r0_body.SiteK141
import host.sim.template.a4pre_first_tail_x15_r0_body.SiteF141
import host.sim.conv.CompactShift
import host.sim.template.Check
import host.sim.BigFreeP
import host.sim.template.CallGen
set_option Elab.async false
namespace Host.Load.Run.Tpl
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
open Host.Ts Host.Ts.Sim Host.Ts.Sim.Template

/-! The compaction's state shift at call site 141 of chain `PRE_first_tail_x15_r0_body` (`Conv.compact_shift`): the call `PRE_first_tail_x15_r0_body.s1367`, the merged
state `PRE_first_tail_x15_r0_body.s1368`, the canonical state `PRE_first_tail_x15_r0_body.s1369`; its frames [2665,2673467,2673472,2673473] (kept arrays [2665,2673467]). -/

-- the map's places and counters
kernel_rfl PRE_first_tail_x15_r0_body.zpl141 : PRE_first_tail_x15_r0_body.pl141.all (Nat.ble PRE_first_tail_x15_r0_body.s1367.next) = true
kernel_rfl PRE_first_tail_x15_r0_body.zplnd141 : nodupT PRE_first_tail_x15_r0_body.pl141 PTrie.nil = true
kernel_rfl PRE_first_tail_x15_r0_body.zn1141 : Nat.ble PRE_first_tail_x15_r0_body.s1367.next 2786441 = true
kernel_rfl PRE_first_tail_x15_r0_body.zfirst141 : Nat.ble aFirst PRE_first_tail_x15_r0_body.s1367.next = true
kernel_rfl PRE_first_tail_x15_r0_body.zscn141 : PRE_first_tail_x15_r0_body.s1369.next = PRE_first_tail_x15_r0_body.s1367.next + PRE_first_tail_x15_r0_body.pl141.length
kernel_rfl PRE_first_tail_x15_r0_body.zsmn141 : PRE_first_tail_x15_r0_body.s1368.next = 2786441
kernel_rfl PRE_first_tail_x15_r0_body.zgrow141 : Nat.ble PRE_first_tail_x15_r0_body.s1369.next PRE_first_tail_x15_r0_body.s1368.next = true
-- the tables
kernel_rfl PRE_first_tail_x15_r0_body.zfresh141 : PRE_first_tail_x15_r0_body.S1367.tab.all (fun e => PRE_first_tail_x15_r0_body.cws141.all fun v => e.noVar v) = true
kernel_rfl PRE_first_tail_x15_r0_body.zcnd141 : nodupT PRE_first_tail_x15_r0_body.cws141 PTrie.nil = true
kernel_rfl PRE_first_tail_x15_r0_body.znrHi141 : PRE_first_tail_x15_r0_body.nr141.all (fun r => Nat.blt r PRE_first_tail_x15_r0_body.S1368.tab.length) = true
-- the frames: every framed address below the call's counter; the kept arrays the chain start's, extended in the merged state
kernel_rfl PRE_first_tail_x15_r0_body.zfrlt141 : [2665, 2673467, 2673472, 2673473].all (fun a => Nat.blt a PRE_first_tail_x15_r0_body.s1367.next) = true
kernel_rfl PRE_first_tail_x15_r0_body.zg141_2665 : PRE_first_tail_x15_r0_body.s1369.heap.get 2665 = some (.obj (objOf PRE_first_tail_x15_r0_body.s1369 2665))
kernel_rfl PRE_first_tail_x15_r0_body.zk141_2665 : (objOf PRE_first_tail_x15_r0_body.s1369 2665).kind = .array (arrOf PRE_first_tail_x15_r0_body.s0 2665)
kernel_rfl PRE_first_tail_x15_r0_body.zm141_2665 : PRE_first_tail_x15_r0_body.s1368.heap.get 2665 = some (.obj { PRE_first_tail_x15_r0_body.kappa141.obj (objOf PRE_first_tail_x15_r0_body.s1369 2665) with
  kind := .array (arrOf PRE_first_tail_x15_r0_body.s0 2665 ++ (arrOf PRE_first_tail_x15_r0_body.s1368 2665).drop (arrOf PRE_first_tail_x15_r0_body.s0 2665).length) })
kernel_rfl PRE_first_tail_x15_r0_body.zg141_2673467 : PRE_first_tail_x15_r0_body.s1369.heap.get 2673467 = some (.obj (objOf PRE_first_tail_x15_r0_body.s1369 2673467))
kernel_rfl PRE_first_tail_x15_r0_body.zk141_2673467 : (objOf PRE_first_tail_x15_r0_body.s1369 2673467).kind = .array (arrOf PRE_first_tail_x15_r0_body.s0 2673467)
kernel_rfl PRE_first_tail_x15_r0_body.zm141_2673467 : PRE_first_tail_x15_r0_body.s1368.heap.get 2673467 = some (.obj { PRE_first_tail_x15_r0_body.kappa141.obj (objOf PRE_first_tail_x15_r0_body.s1369 2673467) with
  kind := .array (arrOf PRE_first_tail_x15_r0_body.s0 2673467 ++ (arrOf PRE_first_tail_x15_r0_body.s1368 2673467).drop (arrOf PRE_first_tail_x15_r0_body.s0 2673467).length) })
kernel_rfl PRE_first_tail_x15_r0_body.zw141_4910 : (PRE_first_tail_x15_r0_body.s1369.heap.get 4910).isSome = true
kernel_rfl PRE_first_tail_x15_r0_body.zw141_2673472 : (PRE_first_tail_x15_r0_body.s1369.heap.get 2673472).isSome = true
kernel_rfl PRE_first_tail_x15_r0_body.zw141_2673473 : (PRE_first_tail_x15_r0_body.s1369.heap.get 2673473).isSome = true
-- the heap: the changed list in range, holding the stage's written and fresh addresses; the canonical side's image
kernel_rfl PRE_first_tail_x15_r0_body.zclbd141 : PRE_first_tail_x15_r0_body.cl141.all (fun b => Nat.blt (b / 4096) (4 ^ 31)) = true
kernel_rfl PRE_first_tail_x15_r0_body.zwr141 : PRE_first_tail_x15_r0_body.st141.wr.all (fun b => !Nat.blt b PRE_first_tail_x15_r0_body.s1367.next || PRE_first_tail_x15_r0_body.cl141.contains b) = true
def PRE_first_tail_x15_r0_body.zl141 : List Nat := PRE_first_tail_x15_r0_body.cl141.filter fun a => !(List.contains [2665, 2673467] a)
kernel_rfl PRE_first_tail_x15_r0_body.zimgE141 : PRE_first_tail_x15_r0_body.zl141.map (fun a => PRE_first_tail_x15_r0_body.s1368.heap.get (PRE_first_tail_x15_r0_body.kappa141.a a)) = PRE_first_tail_x15_r0_body.zl141.map (fun a => (PRE_first_tail_x15_r0_body.s1369.heap.get a).map PRE_first_tail_x15_r0_body.kappa141.hobj)
theorem PRE_first_tail_x15_r0_body.zimg141 : HeapImg PRE_first_tail_x15_r0_body.kappa141 PRE_first_tail_x15_r0_body.s1369 PRE_first_tail_x15_r0_body.s1368 PRE_first_tail_x15_r0_body.zl141 := PRE_first_tail_x15_r0_body.zimgE141
-- the roots and their supports
kernel_rfl PRE_first_tail_x15_r0_body.zctl141 : PRE_first_tail_x15_r0_body.s1368.ctl = PRE_first_tail_x15_r0_body.kappa141.ctl PRE_first_tail_x15_r0_body.s1369.ctl
kernel_rfl PRE_first_tail_x15_r0_body.zstack141 : PRE_first_tail_x15_r0_body.s1368.stack = PRE_first_tail_x15_r0_body.s1369.stack.map PRE_first_tail_x15_r0_body.kappa141.frame
kernel_rfl PRE_first_tail_x15_r0_body.zjobs141 : PRE_first_tail_x15_r0_body.s1368.jobs = PRE_first_tail_x15_r0_body.s1369.jobs.map PRE_first_tail_x15_r0_body.kappa141.job
kernel_rfl PRE_first_tail_x15_r0_body.zstores141 : PRE_first_tail_x15_r0_body.s1368.stores = PRE_first_tail_x15_r0_body.kappa141.stores PRE_first_tail_x15_r0_body.s1369.stores
kernel_rfl PRE_first_tail_x15_r0_body.zroots141 : checkRootsSupp PRE_first_tail_x15_r0_body.s1369 6126 = true
kernel_rfl PRE_first_tail_x15_r0_body.znC141 : PRE_first_tail_x15_r0_body.S1367.tab.length + PRE_first_tail_x15_r0_body.cws141.length = 6126
-- the map as `Conv.compact_shift` states it (the call's counters for the literals)
kernel_rfl PRE_first_tail_x15_r0_body.zkap141 : PRE_first_tail_x15_r0_body.kappa141 = Conv.Map.compact PRE_first_tail_x15_r0_body.s1367.next 2786441 PRE_first_tail_x15_r0_body.S1367.tab.length PRE_first_tail_x15_r0_body.pl141 (PRE_first_tail_x15_r0_body.nr141.map NumV.ref) PRE_first_tail_x15_r0_body.kd141.big
  PRE_first_tail_x15_r0_body.kd141.region PRE_first_tail_x15_r0_body.kd141.nodeF
-- the bridge inactive at the canonical state (`Conv.FullShiftQ.toX`; the merged state's bridge is the canonical's: cbridge)
theorem PRE_first_tail_x15_r0_body.zbin141 : (Host.Ts.Sim.Full.bridgeOf PRE_first_tail_x15_r0_body.s1369.ffi).active = false := (Host.Load.Boot.replay_active Host.Load.Run.Prompt.P.oblog2818)
-- the JS bookkeeping's step (`Conv.JClean.step` over the changed list) and the canonical roots' bigint freedom
kernel_rfl PRE_first_tail_x15_r0_body.zjc141 : Conv.jcleanListB (⟨20993, 18089, 2786091, 6126⟩ : Conv.Cnt) PRE_first_tail_x15_r0_body.s1369 PRE_first_tail_x15_r0_body.cl141 = true
kernel_rfl PRE_first_tail_x15_r0_body.zrootsB141 : noBigRootsP (fun i => !Conv.oldBigB (⟨20993, 18089, 2786091, 6126⟩ : Conv.Cnt) i) PRE_first_tail_x15_r0_body.s1369.trace PRE_first_tail_x15_r0_body.s1369 = true
kernel_rfl PRE_first_tail_x15_r0_body.zhm141 : Nat.ble (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s0.ffi).mlx.nnext 18083 = true
theorem PRE_first_tail_x15_r0_body.cjcl141 (h : Conv.JClean (⟨20989, 18083, 2786076, 6117⟩ : Conv.Cnt) PRE_first_tail_x15_r0_body.s1367) : Conv.JClean (⟨20993, 18089, 2786091, 6126⟩ : Conv.Cnt) PRE_first_tail_x15_r0_body.s1369 :=
  Conv.JClean.step h (Conv.Cnt.le_of_leB PRE_first_tail_x15_r0_body.cle141)
    (Conv.heap_off_setAll PRE_first_tail_x15_r0_body.cheap141 fun a ha => Nat.blt_eq.mp (List.all_eq_true.mp PRE_first_tail_x15_r0_body.zclbd141 a ha)) PRE_first_tail_x15_r0_body.zjc141

end Host.Load.Run.Tpl
