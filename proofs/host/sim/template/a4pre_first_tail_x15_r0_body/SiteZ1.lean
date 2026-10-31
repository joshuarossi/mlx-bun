import host.sim.template.a4pre_first_tail_x15_r0_body.SiteS1
import host.sim.template.a4pre_first_tail_x15_r0_body.SiteK1
import host.sim.template.a4pre_first_tail_x15_r0_body.SiteF1
import host.sim.conv.CompactShift
import host.sim.template.Check
import host.sim.BigFreeP
import host.sim.template.CallGen
set_option Elab.async false
namespace Host.Load.Run.Tpl
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
open Host.Ts Host.Ts.Sim Host.Ts.Sim.Template

/-! The compaction's state shift at call site 1 of chain `PRE_first_tail_x15_r0_body` (`Conv.compact_shift`): the call `PRE_first_tail_x15_r0_body.s21`, the merged
state `PRE_first_tail_x15_r0_body.s22`, the canonical state `PRE_first_tail_x15_r0_body.s23`; its frames [2665,2673467,2673472,2673473] (kept arrays [2665,2673467]). -/

-- the map's places and counters
kernel_rfl PRE_first_tail_x15_r0_body.zpl1 : PRE_first_tail_x15_r0_body.pl1.all (Nat.ble PRE_first_tail_x15_r0_body.s21.next) = true
kernel_rfl PRE_first_tail_x15_r0_body.zplnd1 : nodupT PRE_first_tail_x15_r0_body.pl1 PTrie.nil = true
kernel_rfl PRE_first_tail_x15_r0_body.zn11 : Nat.ble PRE_first_tail_x15_r0_body.s21.next 2675767 = true
kernel_rfl PRE_first_tail_x15_r0_body.zfirst1 : Nat.ble aFirst PRE_first_tail_x15_r0_body.s21.next = true
kernel_rfl PRE_first_tail_x15_r0_body.zscn1 : PRE_first_tail_x15_r0_body.s23.next = PRE_first_tail_x15_r0_body.s21.next + PRE_first_tail_x15_r0_body.pl1.length
kernel_rfl PRE_first_tail_x15_r0_body.zsmn1 : PRE_first_tail_x15_r0_body.s22.next = 2675767
kernel_rfl PRE_first_tail_x15_r0_body.zgrow1 : Nat.ble PRE_first_tail_x15_r0_body.s23.next PRE_first_tail_x15_r0_body.s22.next = true
-- the tables
kernel_rfl PRE_first_tail_x15_r0_body.zfresh1 : PRE_first_tail_x15_r0_body.S21.tab.all (fun e => PRE_first_tail_x15_r0_body.cws1.all fun v => e.noVar v) = true
kernel_rfl PRE_first_tail_x15_r0_body.zcnd1 : nodupT PRE_first_tail_x15_r0_body.cws1 PTrie.nil = true
kernel_rfl PRE_first_tail_x15_r0_body.znrHi1 : PRE_first_tail_x15_r0_body.nr1.all (fun r => Nat.blt r PRE_first_tail_x15_r0_body.S22.tab.length) = true
-- the frames: every framed address below the call's counter; the kept arrays the chain start's, extended in the merged state
kernel_rfl PRE_first_tail_x15_r0_body.zfrlt1 : [2665, 2673467, 2673472, 2673473].all (fun a => Nat.blt a PRE_first_tail_x15_r0_body.s21.next) = true
kernel_rfl PRE_first_tail_x15_r0_body.zg1_2665 : PRE_first_tail_x15_r0_body.s23.heap.get 2665 = some (.obj (objOf PRE_first_tail_x15_r0_body.s23 2665))
kernel_rfl PRE_first_tail_x15_r0_body.zk1_2665 : (objOf PRE_first_tail_x15_r0_body.s23 2665).kind = .array (arrOf PRE_first_tail_x15_r0_body.s0 2665)
kernel_rfl PRE_first_tail_x15_r0_body.zm1_2665 : PRE_first_tail_x15_r0_body.s22.heap.get 2665 = some (.obj { PRE_first_tail_x15_r0_body.kappa1.obj (objOf PRE_first_tail_x15_r0_body.s23 2665) with
  kind := .array (arrOf PRE_first_tail_x15_r0_body.s0 2665 ++ (arrOf PRE_first_tail_x15_r0_body.s22 2665).drop (arrOf PRE_first_tail_x15_r0_body.s0 2665).length) })
kernel_rfl PRE_first_tail_x15_r0_body.zg1_2673467 : PRE_first_tail_x15_r0_body.s23.heap.get 2673467 = some (.obj (objOf PRE_first_tail_x15_r0_body.s23 2673467))
kernel_rfl PRE_first_tail_x15_r0_body.zk1_2673467 : (objOf PRE_first_tail_x15_r0_body.s23 2673467).kind = .array (arrOf PRE_first_tail_x15_r0_body.s0 2673467)
kernel_rfl PRE_first_tail_x15_r0_body.zm1_2673467 : PRE_first_tail_x15_r0_body.s22.heap.get 2673467 = some (.obj { PRE_first_tail_x15_r0_body.kappa1.obj (objOf PRE_first_tail_x15_r0_body.s23 2673467) with
  kind := .array (arrOf PRE_first_tail_x15_r0_body.s0 2673467 ++ (arrOf PRE_first_tail_x15_r0_body.s22 2673467).drop (arrOf PRE_first_tail_x15_r0_body.s0 2673467).length) })
kernel_rfl PRE_first_tail_x15_r0_body.zw1_4910 : (PRE_first_tail_x15_r0_body.s23.heap.get 4910).isSome = true
kernel_rfl PRE_first_tail_x15_r0_body.zw1_2673472 : (PRE_first_tail_x15_r0_body.s23.heap.get 2673472).isSome = true
kernel_rfl PRE_first_tail_x15_r0_body.zw1_2673473 : (PRE_first_tail_x15_r0_body.s23.heap.get 2673473).isSome = true
-- the heap: the changed list in range, holding the stage's written and fresh addresses; the canonical side's image
kernel_rfl PRE_first_tail_x15_r0_body.zclbd1 : PRE_first_tail_x15_r0_body.cl1.all (fun b => Nat.blt (b / 4096) (4 ^ 31)) = true
kernel_rfl PRE_first_tail_x15_r0_body.zwr1 : PRE_first_tail_x15_r0_body.st1.wr.all (fun b => !Nat.blt b PRE_first_tail_x15_r0_body.s21.next || PRE_first_tail_x15_r0_body.cl1.contains b) = true
def PRE_first_tail_x15_r0_body.zl1 : List Nat := PRE_first_tail_x15_r0_body.cl1.filter fun a => !(List.contains [2665, 2673467] a)
kernel_rfl PRE_first_tail_x15_r0_body.zimgE1 : PRE_first_tail_x15_r0_body.zl1.map (fun a => PRE_first_tail_x15_r0_body.s22.heap.get (PRE_first_tail_x15_r0_body.kappa1.a a)) = PRE_first_tail_x15_r0_body.zl1.map (fun a => (PRE_first_tail_x15_r0_body.s23.heap.get a).map PRE_first_tail_x15_r0_body.kappa1.hobj)
theorem PRE_first_tail_x15_r0_body.zimg1 : HeapImg PRE_first_tail_x15_r0_body.kappa1 PRE_first_tail_x15_r0_body.s23 PRE_first_tail_x15_r0_body.s22 PRE_first_tail_x15_r0_body.zl1 := PRE_first_tail_x15_r0_body.zimgE1
-- the roots and their supports
kernel_rfl PRE_first_tail_x15_r0_body.zctl1 : PRE_first_tail_x15_r0_body.s22.ctl = PRE_first_tail_x15_r0_body.kappa1.ctl PRE_first_tail_x15_r0_body.s23.ctl
kernel_rfl PRE_first_tail_x15_r0_body.zstack1 : PRE_first_tail_x15_r0_body.s22.stack = PRE_first_tail_x15_r0_body.s23.stack.map PRE_first_tail_x15_r0_body.kappa1.frame
kernel_rfl PRE_first_tail_x15_r0_body.zjobs1 : PRE_first_tail_x15_r0_body.s22.jobs = PRE_first_tail_x15_r0_body.s23.jobs.map PRE_first_tail_x15_r0_body.kappa1.job
kernel_rfl PRE_first_tail_x15_r0_body.zstores1 : PRE_first_tail_x15_r0_body.s22.stores = PRE_first_tail_x15_r0_body.kappa1.stores PRE_first_tail_x15_r0_body.s23.stores
kernel_rfl PRE_first_tail_x15_r0_body.zroots1 : checkRootsSupp PRE_first_tail_x15_r0_body.s23 122 = true
kernel_rfl PRE_first_tail_x15_r0_body.znC1 : PRE_first_tail_x15_r0_body.S21.tab.length + PRE_first_tail_x15_r0_body.cws1.length = 122
-- the map as `Conv.compact_shift` states it (the call's counters for the literals)
kernel_rfl PRE_first_tail_x15_r0_body.zkap1 : PRE_first_tail_x15_r0_body.kappa1 = Conv.Map.compact PRE_first_tail_x15_r0_body.s21.next 2675767 PRE_first_tail_x15_r0_body.S21.tab.length PRE_first_tail_x15_r0_body.pl1 (PRE_first_tail_x15_r0_body.nr1.map NumV.ref) PRE_first_tail_x15_r0_body.kd1.big
  PRE_first_tail_x15_r0_body.kd1.region PRE_first_tail_x15_r0_body.kd1.nodeF
-- the bridge inactive at the canonical state (`Conv.FullShiftQ.toX`; the merged state's bridge is the canonical's: cbridge)
theorem PRE_first_tail_x15_r0_body.zbin1 : (Host.Ts.Sim.Full.bridgeOf PRE_first_tail_x15_r0_body.s23.ffi).active = false := (Host.Load.Boot.replay_active Host.Load.Run.Prompt.P.oblog2818)
-- the JS bookkeeping's step (`Conv.JClean.step` over the changed list) and the canonical roots' bigint freedom
kernel_rfl PRE_first_tail_x15_r0_body.zjc1 : Conv.jcleanListB (⟨18226, 15318, 2675765, 122⟩ : Conv.Cnt) PRE_first_tail_x15_r0_body.s23 PRE_first_tail_x15_r0_body.cl1 = true
kernel_rfl PRE_first_tail_x15_r0_body.zroots21 : noBigRootsP (fun i => !Conv.oldBigB (⟨18226, 15318, 2675765, 122⟩ : Conv.Cnt) i) PRE_first_tail_x15_r0_body.s23.trace PRE_first_tail_x15_r0_body.s23 = true
kernel_rfl PRE_first_tail_x15_r0_body.zhm1 : Nat.ble (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s0.ffi).mlx.nnext 15318 = true
theorem PRE_first_tail_x15_r0_body.cjcl1 (h : Conv.JClean (⟨18226, 15318, 2675765, 122⟩ : Conv.Cnt) PRE_first_tail_x15_r0_body.s21) : Conv.JClean (⟨18226, 15318, 2675765, 122⟩ : Conv.Cnt) PRE_first_tail_x15_r0_body.s23 :=
  Conv.JClean.step h (Conv.Cnt.le_of_leB PRE_first_tail_x15_r0_body.cle1)
    (Conv.heap_off_setAll PRE_first_tail_x15_r0_body.cheap1 fun a ha => Nat.blt_eq.mp (List.all_eq_true.mp PRE_first_tail_x15_r0_body.zclbd1 a ha)) PRE_first_tail_x15_r0_body.zjc1

end Host.Load.Run.Tpl
