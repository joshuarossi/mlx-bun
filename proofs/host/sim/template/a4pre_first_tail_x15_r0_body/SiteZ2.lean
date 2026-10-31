import host.sim.template.a4pre_first_tail_x15_r0_body.SiteS2
import host.sim.template.a4pre_first_tail_x15_r0_body.SiteK2
import host.sim.template.a4pre_first_tail_x15_r0_body.SiteF2
import host.sim.conv.CompactShift
import host.sim.template.Check
import host.sim.BigFreeP
import host.sim.template.CallGen
set_option Elab.async false
namespace Host.Load.Run.Tpl
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
open Host.Ts Host.Ts.Sim Host.Ts.Sim.Template

/-! The compaction's state shift at call site 2 of chain `PRE_first_tail_x15_r0_body` (`Conv.compact_shift`): the call `PRE_first_tail_x15_r0_body.s25`, the merged
state `PRE_first_tail_x15_r0_body.s26`, the canonical state `PRE_first_tail_x15_r0_body.s27`; its frames [2665,2673467,2673472,2673473] (kept arrays [2665,2673467]). -/

-- the map's places and counters
kernel_rfl PRE_first_tail_x15_r0_body.zpl2 : PRE_first_tail_x15_r0_body.pl2.all (Nat.ble PRE_first_tail_x15_r0_body.s25.next) = true
kernel_rfl PRE_first_tail_x15_r0_body.zplnd2 : nodupT PRE_first_tail_x15_r0_body.pl2 PTrie.nil = true
kernel_rfl PRE_first_tail_x15_r0_body.zn12 : Nat.ble PRE_first_tail_x15_r0_body.s25.next 2676073 = true
kernel_rfl PRE_first_tail_x15_r0_body.zfirst2 : Nat.ble aFirst PRE_first_tail_x15_r0_body.s25.next = true
kernel_rfl PRE_first_tail_x15_r0_body.zscn2 : PRE_first_tail_x15_r0_body.s27.next = PRE_first_tail_x15_r0_body.s25.next + PRE_first_tail_x15_r0_body.pl2.length
kernel_rfl PRE_first_tail_x15_r0_body.zsmn2 : PRE_first_tail_x15_r0_body.s26.next = 2676073
kernel_rfl PRE_first_tail_x15_r0_body.zgrow2 : Nat.ble PRE_first_tail_x15_r0_body.s27.next PRE_first_tail_x15_r0_body.s26.next = true
-- the tables
kernel_rfl PRE_first_tail_x15_r0_body.zfresh2 : PRE_first_tail_x15_r0_body.S25.tab.all (fun e => PRE_first_tail_x15_r0_body.cws2.all fun v => e.noVar v) = true
kernel_rfl PRE_first_tail_x15_r0_body.zcnd2 : nodupT PRE_first_tail_x15_r0_body.cws2 PTrie.nil = true
kernel_rfl PRE_first_tail_x15_r0_body.znrHi2 : PRE_first_tail_x15_r0_body.nr2.all (fun r => Nat.blt r PRE_first_tail_x15_r0_body.S26.tab.length) = true
-- the frames: every framed address below the call's counter; the kept arrays the chain start's, extended in the merged state
kernel_rfl PRE_first_tail_x15_r0_body.zfrlt2 : [2665, 2673467, 2673472, 2673473].all (fun a => Nat.blt a PRE_first_tail_x15_r0_body.s25.next) = true
kernel_rfl PRE_first_tail_x15_r0_body.zg2_2665 : PRE_first_tail_x15_r0_body.s27.heap.get 2665 = some (.obj (objOf PRE_first_tail_x15_r0_body.s27 2665))
kernel_rfl PRE_first_tail_x15_r0_body.zk2_2665 : (objOf PRE_first_tail_x15_r0_body.s27 2665).kind = .array (arrOf PRE_first_tail_x15_r0_body.s0 2665)
kernel_rfl PRE_first_tail_x15_r0_body.zm2_2665 : PRE_first_tail_x15_r0_body.s26.heap.get 2665 = some (.obj { PRE_first_tail_x15_r0_body.kappa2.obj (objOf PRE_first_tail_x15_r0_body.s27 2665) with
  kind := .array (arrOf PRE_first_tail_x15_r0_body.s0 2665 ++ (arrOf PRE_first_tail_x15_r0_body.s26 2665).drop (arrOf PRE_first_tail_x15_r0_body.s0 2665).length) })
kernel_rfl PRE_first_tail_x15_r0_body.zg2_2673467 : PRE_first_tail_x15_r0_body.s27.heap.get 2673467 = some (.obj (objOf PRE_first_tail_x15_r0_body.s27 2673467))
kernel_rfl PRE_first_tail_x15_r0_body.zk2_2673467 : (objOf PRE_first_tail_x15_r0_body.s27 2673467).kind = .array (arrOf PRE_first_tail_x15_r0_body.s0 2673467)
kernel_rfl PRE_first_tail_x15_r0_body.zm2_2673467 : PRE_first_tail_x15_r0_body.s26.heap.get 2673467 = some (.obj { PRE_first_tail_x15_r0_body.kappa2.obj (objOf PRE_first_tail_x15_r0_body.s27 2673467) with
  kind := .array (arrOf PRE_first_tail_x15_r0_body.s0 2673467 ++ (arrOf PRE_first_tail_x15_r0_body.s26 2673467).drop (arrOf PRE_first_tail_x15_r0_body.s0 2673467).length) })
kernel_rfl PRE_first_tail_x15_r0_body.zw2_4910 : (PRE_first_tail_x15_r0_body.s27.heap.get 4910).isSome = true
kernel_rfl PRE_first_tail_x15_r0_body.zw2_2673472 : (PRE_first_tail_x15_r0_body.s27.heap.get 2673472).isSome = true
kernel_rfl PRE_first_tail_x15_r0_body.zw2_2673473 : (PRE_first_tail_x15_r0_body.s27.heap.get 2673473).isSome = true
-- the heap: the changed list in range, holding the stage's written and fresh addresses; the canonical side's image
kernel_rfl PRE_first_tail_x15_r0_body.zclbd2 : PRE_first_tail_x15_r0_body.cl2.all (fun b => Nat.blt (b / 4096) (4 ^ 31)) = true
kernel_rfl PRE_first_tail_x15_r0_body.zwr2 : PRE_first_tail_x15_r0_body.st2.wr.all (fun b => !Nat.blt b PRE_first_tail_x15_r0_body.s25.next || PRE_first_tail_x15_r0_body.cl2.contains b) = true
def PRE_first_tail_x15_r0_body.zl2 : List Nat := PRE_first_tail_x15_r0_body.cl2.filter fun a => !(List.contains [2665, 2673467] a)
kernel_rfl PRE_first_tail_x15_r0_body.zimgE2 : PRE_first_tail_x15_r0_body.zl2.map (fun a => PRE_first_tail_x15_r0_body.s26.heap.get (PRE_first_tail_x15_r0_body.kappa2.a a)) = PRE_first_tail_x15_r0_body.zl2.map (fun a => (PRE_first_tail_x15_r0_body.s27.heap.get a).map PRE_first_tail_x15_r0_body.kappa2.hobj)
theorem PRE_first_tail_x15_r0_body.zimg2 : HeapImg PRE_first_tail_x15_r0_body.kappa2 PRE_first_tail_x15_r0_body.s27 PRE_first_tail_x15_r0_body.s26 PRE_first_tail_x15_r0_body.zl2 := PRE_first_tail_x15_r0_body.zimgE2
-- the roots and their supports
kernel_rfl PRE_first_tail_x15_r0_body.zctl2 : PRE_first_tail_x15_r0_body.s26.ctl = PRE_first_tail_x15_r0_body.kappa2.ctl PRE_first_tail_x15_r0_body.s27.ctl
kernel_rfl PRE_first_tail_x15_r0_body.zstack2 : PRE_first_tail_x15_r0_body.s26.stack = PRE_first_tail_x15_r0_body.s27.stack.map PRE_first_tail_x15_r0_body.kappa2.frame
kernel_rfl PRE_first_tail_x15_r0_body.zjobs2 : PRE_first_tail_x15_r0_body.s26.jobs = PRE_first_tail_x15_r0_body.s27.jobs.map PRE_first_tail_x15_r0_body.kappa2.job
kernel_rfl PRE_first_tail_x15_r0_body.zstores2 : PRE_first_tail_x15_r0_body.s26.stores = PRE_first_tail_x15_r0_body.kappa2.stores PRE_first_tail_x15_r0_body.s27.stores
kernel_rfl PRE_first_tail_x15_r0_body.zroots2 : checkRootsSupp PRE_first_tail_x15_r0_body.s27 139 = true
kernel_rfl PRE_first_tail_x15_r0_body.znC2 : PRE_first_tail_x15_r0_body.S25.tab.length + PRE_first_tail_x15_r0_body.cws2.length = 139
-- the map as `Conv.compact_shift` states it (the call's counters for the literals)
kernel_rfl PRE_first_tail_x15_r0_body.zkap2 : PRE_first_tail_x15_r0_body.kappa2 = Conv.Map.compact PRE_first_tail_x15_r0_body.s25.next 2676073 PRE_first_tail_x15_r0_body.S25.tab.length PRE_first_tail_x15_r0_body.pl2 (PRE_first_tail_x15_r0_body.nr2.map NumV.ref) PRE_first_tail_x15_r0_body.kd2.big
  PRE_first_tail_x15_r0_body.kd2.region PRE_first_tail_x15_r0_body.kd2.nodeF
-- the bridge inactive at the canonical state (`Conv.FullShiftQ.toX`; the merged state's bridge is the canonical's: cbridge)
theorem PRE_first_tail_x15_r0_body.zbin2 : (Host.Ts.Sim.Full.bridgeOf PRE_first_tail_x15_r0_body.s27.ffi).active = false := (Host.Load.Boot.replay_active Host.Load.Run.Prompt.P.oblog2818)
-- the JS bookkeeping's step (`Conv.JClean.step` over the changed list) and the canonical roots' bigint freedom
kernel_rfl PRE_first_tail_x15_r0_body.zjc2 : Conv.jcleanListB (⟨18233, 15322, 2676054, 139⟩ : Conv.Cnt) PRE_first_tail_x15_r0_body.s27 PRE_first_tail_x15_r0_body.cl2 = true
kernel_rfl PRE_first_tail_x15_r0_body.zroots22 : noBigRootsP (fun i => !Conv.oldBigB (⟨18233, 15322, 2676054, 139⟩ : Conv.Cnt) i) PRE_first_tail_x15_r0_body.s27.trace PRE_first_tail_x15_r0_body.s27 = true
kernel_rfl PRE_first_tail_x15_r0_body.zhm2 : Nat.ble (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s0.ffi).mlx.nnext 15322 = true
theorem PRE_first_tail_x15_r0_body.cjcl2 (h : Conv.JClean (⟨18233, 15322, 2676053, 139⟩ : Conv.Cnt) PRE_first_tail_x15_r0_body.s25) : Conv.JClean (⟨18233, 15322, 2676054, 139⟩ : Conv.Cnt) PRE_first_tail_x15_r0_body.s27 :=
  Conv.JClean.step h (Conv.Cnt.le_of_leB PRE_first_tail_x15_r0_body.cle2)
    (Conv.heap_off_setAll PRE_first_tail_x15_r0_body.cheap2 fun a ha => Nat.blt_eq.mp (List.all_eq_true.mp PRE_first_tail_x15_r0_body.zclbd2 a ha)) PRE_first_tail_x15_r0_body.zjc2

end Host.Load.Run.Tpl
