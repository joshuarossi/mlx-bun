import host.sim.template.a4pre_first_tail_x15_r0_body.SiteS14
import host.sim.template.a4pre_first_tail_x15_r0_body.SiteK14
import host.sim.template.a4pre_first_tail_x15_r0_body.SiteF14
import host.sim.conv.CompactShift
import host.sim.template.Check
import host.sim.BigFreeP
import host.sim.template.CallGen
set_option Elab.async false
namespace Host.Load.Run.Tpl
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
open Host.Ts Host.Ts.Sim Host.Ts.Sim.Template

/-! The compaction's state shift at call site 14 of chain `PRE_first_tail_x15_r0_body` (`Conv.compact_shift`): the call `PRE_first_tail_x15_r0_body.s143`, the merged
state `PRE_first_tail_x15_r0_body.s144`, the canonical state `PRE_first_tail_x15_r0_body.s145`; its frames [2665,2673467,2673472,2673473] (kept arrays [2665,2673467]). -/

-- the map's places and counters
kernel_rfl PRE_first_tail_x15_r0_body.zpl14 : PRE_first_tail_x15_r0_body.pl14.all (Nat.ble PRE_first_tail_x15_r0_body.s143.next) = true
kernel_rfl PRE_first_tail_x15_r0_body.zplnd14 : nodupT PRE_first_tail_x15_r0_body.pl14 PTrie.nil = true
kernel_rfl PRE_first_tail_x15_r0_body.zn114 : Nat.ble PRE_first_tail_x15_r0_body.s143.next 2685670 = true
kernel_rfl PRE_first_tail_x15_r0_body.zfirst14 : Nat.ble aFirst PRE_first_tail_x15_r0_body.s143.next = true
kernel_rfl PRE_first_tail_x15_r0_body.zscn14 : PRE_first_tail_x15_r0_body.s145.next = PRE_first_tail_x15_r0_body.s143.next + PRE_first_tail_x15_r0_body.pl14.length
kernel_rfl PRE_first_tail_x15_r0_body.zsmn14 : PRE_first_tail_x15_r0_body.s144.next = 2685670
kernel_rfl PRE_first_tail_x15_r0_body.zgrow14 : Nat.ble PRE_first_tail_x15_r0_body.s145.next PRE_first_tail_x15_r0_body.s144.next = true
-- the tables
kernel_rfl PRE_first_tail_x15_r0_body.zfresh14 : PRE_first_tail_x15_r0_body.S143.tab.all (fun e => PRE_first_tail_x15_r0_body.cws14.all fun v => e.noVar v) = true
kernel_rfl PRE_first_tail_x15_r0_body.zcnd14 : nodupT PRE_first_tail_x15_r0_body.cws14 PTrie.nil = true
kernel_rfl PRE_first_tail_x15_r0_body.znrHi14 : PRE_first_tail_x15_r0_body.nr14.all (fun r => Nat.blt r PRE_first_tail_x15_r0_body.S144.tab.length) = true
-- the frames: every framed address below the call's counter; the kept arrays the chain start's, extended in the merged state
kernel_rfl PRE_first_tail_x15_r0_body.zfrlt14 : [2665, 2673467, 2673472, 2673473].all (fun a => Nat.blt a PRE_first_tail_x15_r0_body.s143.next) = true
kernel_rfl PRE_first_tail_x15_r0_body.zg14_2665 : PRE_first_tail_x15_r0_body.s145.heap.get 2665 = some (.obj (objOf PRE_first_tail_x15_r0_body.s145 2665))
kernel_rfl PRE_first_tail_x15_r0_body.zk14_2665 : (objOf PRE_first_tail_x15_r0_body.s145 2665).kind = .array (arrOf PRE_first_tail_x15_r0_body.s0 2665)
kernel_rfl PRE_first_tail_x15_r0_body.zm14_2665 : PRE_first_tail_x15_r0_body.s144.heap.get 2665 = some (.obj { PRE_first_tail_x15_r0_body.kappa14.obj (objOf PRE_first_tail_x15_r0_body.s145 2665) with
  kind := .array (arrOf PRE_first_tail_x15_r0_body.s0 2665 ++ (arrOf PRE_first_tail_x15_r0_body.s144 2665).drop (arrOf PRE_first_tail_x15_r0_body.s0 2665).length) })
kernel_rfl PRE_first_tail_x15_r0_body.zg14_2673467 : PRE_first_tail_x15_r0_body.s145.heap.get 2673467 = some (.obj (objOf PRE_first_tail_x15_r0_body.s145 2673467))
kernel_rfl PRE_first_tail_x15_r0_body.zk14_2673467 : (objOf PRE_first_tail_x15_r0_body.s145 2673467).kind = .array (arrOf PRE_first_tail_x15_r0_body.s0 2673467)
kernel_rfl PRE_first_tail_x15_r0_body.zm14_2673467 : PRE_first_tail_x15_r0_body.s144.heap.get 2673467 = some (.obj { PRE_first_tail_x15_r0_body.kappa14.obj (objOf PRE_first_tail_x15_r0_body.s145 2673467) with
  kind := .array (arrOf PRE_first_tail_x15_r0_body.s0 2673467 ++ (arrOf PRE_first_tail_x15_r0_body.s144 2673467).drop (arrOf PRE_first_tail_x15_r0_body.s0 2673467).length) })
kernel_rfl PRE_first_tail_x15_r0_body.zw14_4910 : (PRE_first_tail_x15_r0_body.s145.heap.get 4910).isSome = true
kernel_rfl PRE_first_tail_x15_r0_body.zw14_2673472 : (PRE_first_tail_x15_r0_body.s145.heap.get 2673472).isSome = true
kernel_rfl PRE_first_tail_x15_r0_body.zw14_2673473 : (PRE_first_tail_x15_r0_body.s145.heap.get 2673473).isSome = true
-- the heap: the changed list in range, holding the stage's written and fresh addresses; the canonical side's image
kernel_rfl PRE_first_tail_x15_r0_body.zclbd14 : PRE_first_tail_x15_r0_body.cl14.all (fun b => Nat.blt (b / 4096) (4 ^ 31)) = true
kernel_rfl PRE_first_tail_x15_r0_body.zwr14 : PRE_first_tail_x15_r0_body.st14.wr.all (fun b => !Nat.blt b PRE_first_tail_x15_r0_body.s143.next || PRE_first_tail_x15_r0_body.cl14.contains b) = true
def PRE_first_tail_x15_r0_body.zl14 : List Nat := PRE_first_tail_x15_r0_body.cl14.filter fun a => !(List.contains [2665, 2673467] a)
kernel_rfl PRE_first_tail_x15_r0_body.zimgE14 : PRE_first_tail_x15_r0_body.zl14.map (fun a => PRE_first_tail_x15_r0_body.s144.heap.get (PRE_first_tail_x15_r0_body.kappa14.a a)) = PRE_first_tail_x15_r0_body.zl14.map (fun a => (PRE_first_tail_x15_r0_body.s145.heap.get a).map PRE_first_tail_x15_r0_body.kappa14.hobj)
theorem PRE_first_tail_x15_r0_body.zimg14 : HeapImg PRE_first_tail_x15_r0_body.kappa14 PRE_first_tail_x15_r0_body.s145 PRE_first_tail_x15_r0_body.s144 PRE_first_tail_x15_r0_body.zl14 := PRE_first_tail_x15_r0_body.zimgE14
-- the roots and their supports
kernel_rfl PRE_first_tail_x15_r0_body.zctl14 : PRE_first_tail_x15_r0_body.s144.ctl = PRE_first_tail_x15_r0_body.kappa14.ctl PRE_first_tail_x15_r0_body.s145.ctl
kernel_rfl PRE_first_tail_x15_r0_body.zstack14 : PRE_first_tail_x15_r0_body.s144.stack = PRE_first_tail_x15_r0_body.s145.stack.map PRE_first_tail_x15_r0_body.kappa14.frame
kernel_rfl PRE_first_tail_x15_r0_body.zjobs14 : PRE_first_tail_x15_r0_body.s144.jobs = PRE_first_tail_x15_r0_body.s145.jobs.map PRE_first_tail_x15_r0_body.kappa14.job
kernel_rfl PRE_first_tail_x15_r0_body.zstores14 : PRE_first_tail_x15_r0_body.s144.stores = PRE_first_tail_x15_r0_body.kappa14.stores PRE_first_tail_x15_r0_body.s145.stores
kernel_rfl PRE_first_tail_x15_r0_body.zroots14 : checkRootsSupp PRE_first_tail_x15_r0_body.s145 652 = true
kernel_rfl PRE_first_tail_x15_r0_body.znC14 : PRE_first_tail_x15_r0_body.S143.tab.length + PRE_first_tail_x15_r0_body.cws14.length = 652
-- the map as `Conv.compact_shift` states it (the call's counters for the literals)
kernel_rfl PRE_first_tail_x15_r0_body.zkap14 : PRE_first_tail_x15_r0_body.kappa14 = Conv.Map.compact PRE_first_tail_x15_r0_body.s143.next 2685670 PRE_first_tail_x15_r0_body.S143.tab.length PRE_first_tail_x15_r0_body.pl14 (PRE_first_tail_x15_r0_body.nr14.map NumV.ref) PRE_first_tail_x15_r0_body.kd14.big
  PRE_first_tail_x15_r0_body.kd14.region PRE_first_tail_x15_r0_body.kd14.nodeF
-- the bridge inactive at the canonical state (`Conv.FullShiftQ.toX`; the merged state's bridge is the canonical's: cbridge)
theorem PRE_first_tail_x15_r0_body.zbin14 : (Host.Ts.Sim.Full.bridgeOf PRE_first_tail_x15_r0_body.s145.ffi).active = false := (Host.Load.Boot.replay_active Host.Load.Run.Prompt.P.oblog2818)
-- the JS bookkeeping's step (`Conv.JClean.step` over the changed list) and the canonical roots' bigint freedom
kernel_rfl PRE_first_tail_x15_r0_body.zjc14 : Conv.jcleanListB (⟨18475, 15559, 2685660, 652⟩ : Conv.Cnt) PRE_first_tail_x15_r0_body.s145 PRE_first_tail_x15_r0_body.cl14 = true
kernel_rfl PRE_first_tail_x15_r0_body.zrootsB14 : noBigRootsP (fun i => !Conv.oldBigB (⟨18475, 15559, 2685660, 652⟩ : Conv.Cnt) i) PRE_first_tail_x15_r0_body.s145.trace PRE_first_tail_x15_r0_body.s145 = true
kernel_rfl PRE_first_tail_x15_r0_body.zhm14 : Nat.ble (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s0.ffi).mlx.nnext 15559 = true
theorem PRE_first_tail_x15_r0_body.cjcl14 (h : Conv.JClean (⟨18475, 15559, 2685659, 652⟩ : Conv.Cnt) PRE_first_tail_x15_r0_body.s143) : Conv.JClean (⟨18475, 15559, 2685660, 652⟩ : Conv.Cnt) PRE_first_tail_x15_r0_body.s145 :=
  Conv.JClean.step h (Conv.Cnt.le_of_leB PRE_first_tail_x15_r0_body.cle14)
    (Conv.heap_off_setAll PRE_first_tail_x15_r0_body.cheap14 fun a ha => Nat.blt_eq.mp (List.all_eq_true.mp PRE_first_tail_x15_r0_body.zclbd14 a ha)) PRE_first_tail_x15_r0_body.zjc14

end Host.Load.Run.Tpl
