import host.sim.template.a4pre_first_tail_x15_r0_body.SiteS174
import host.sim.template.a4pre_first_tail_x15_r0_body.SiteK174
import host.sim.template.a4pre_first_tail_x15_r0_body.SiteF174
import host.sim.conv.CompactShift
import host.sim.template.Check
import host.sim.BigFreeP
import host.sim.template.CallGen
set_option Elab.async false
namespace Host.Load.Run.Tpl
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
open Host.Ts Host.Ts.Sim Host.Ts.Sim.Template

/-! The compaction's state shift at call site 174 of chain `PRE_first_tail_x15_r0_body` (`Conv.compact_shift`): the call `PRE_first_tail_x15_r0_body.s1684`, the merged
state `PRE_first_tail_x15_r0_body.s1685`, the canonical state `PRE_first_tail_x15_r0_body.s1686`; its frames [2665,2673467,2673472,2673473] (kept arrays [2665,2673467]). -/

-- the map's places and counters
kernel_rfl PRE_first_tail_x15_r0_body.zpl174 : PRE_first_tail_x15_r0_body.pl174.all (Nat.ble PRE_first_tail_x15_r0_body.s1684.next) = true
kernel_rfl PRE_first_tail_x15_r0_body.zplnd174 : nodupT PRE_first_tail_x15_r0_body.pl174 PTrie.nil = true
kernel_rfl PRE_first_tail_x15_r0_body.zn1174 : Nat.ble PRE_first_tail_x15_r0_body.s1684.next 2812974 = true
kernel_rfl PRE_first_tail_x15_r0_body.zfirst174 : Nat.ble aFirst PRE_first_tail_x15_r0_body.s1684.next = true
kernel_rfl PRE_first_tail_x15_r0_body.zscn174 : PRE_first_tail_x15_r0_body.s1686.next = PRE_first_tail_x15_r0_body.s1684.next + PRE_first_tail_x15_r0_body.pl174.length
kernel_rfl PRE_first_tail_x15_r0_body.zsmn174 : PRE_first_tail_x15_r0_body.s1685.next = 2812974
kernel_rfl PRE_first_tail_x15_r0_body.zgrow174 : Nat.ble PRE_first_tail_x15_r0_body.s1686.next PRE_first_tail_x15_r0_body.s1685.next = true
-- the tables
kernel_rfl PRE_first_tail_x15_r0_body.zfresh174 : PRE_first_tail_x15_r0_body.S1684.tab.all (fun e => PRE_first_tail_x15_r0_body.cws174.all fun v => e.noVar v) = true
kernel_rfl PRE_first_tail_x15_r0_body.zcnd174 : nodupT PRE_first_tail_x15_r0_body.cws174 PTrie.nil = true
kernel_rfl PRE_first_tail_x15_r0_body.znrHi174 : PRE_first_tail_x15_r0_body.nr174.all (fun r => Nat.blt r PRE_first_tail_x15_r0_body.S1685.tab.length) = true
-- the frames: every framed address below the call's counter; the kept arrays the chain start's, extended in the merged state
kernel_rfl PRE_first_tail_x15_r0_body.zfrlt174 : [2665, 2673467, 2673472, 2673473].all (fun a => Nat.blt a PRE_first_tail_x15_r0_body.s1684.next) = true
kernel_rfl PRE_first_tail_x15_r0_body.zg174_2665 : PRE_first_tail_x15_r0_body.s1686.heap.get 2665 = some (.obj (objOf PRE_first_tail_x15_r0_body.s1686 2665))
kernel_rfl PRE_first_tail_x15_r0_body.zk174_2665 : (objOf PRE_first_tail_x15_r0_body.s1686 2665).kind = .array (arrOf PRE_first_tail_x15_r0_body.s0 2665)
kernel_rfl PRE_first_tail_x15_r0_body.zm174_2665 : PRE_first_tail_x15_r0_body.s1685.heap.get 2665 = some (.obj { PRE_first_tail_x15_r0_body.kappa174.obj (objOf PRE_first_tail_x15_r0_body.s1686 2665) with
  kind := .array (arrOf PRE_first_tail_x15_r0_body.s0 2665 ++ (arrOf PRE_first_tail_x15_r0_body.s1685 2665).drop (arrOf PRE_first_tail_x15_r0_body.s0 2665).length) })
kernel_rfl PRE_first_tail_x15_r0_body.zg174_2673467 : PRE_first_tail_x15_r0_body.s1686.heap.get 2673467 = some (.obj (objOf PRE_first_tail_x15_r0_body.s1686 2673467))
kernel_rfl PRE_first_tail_x15_r0_body.zk174_2673467 : (objOf PRE_first_tail_x15_r0_body.s1686 2673467).kind = .array (arrOf PRE_first_tail_x15_r0_body.s0 2673467)
kernel_rfl PRE_first_tail_x15_r0_body.zm174_2673467 : PRE_first_tail_x15_r0_body.s1685.heap.get 2673467 = some (.obj { PRE_first_tail_x15_r0_body.kappa174.obj (objOf PRE_first_tail_x15_r0_body.s1686 2673467) with
  kind := .array (arrOf PRE_first_tail_x15_r0_body.s0 2673467 ++ (arrOf PRE_first_tail_x15_r0_body.s1685 2673467).drop (arrOf PRE_first_tail_x15_r0_body.s0 2673467).length) })
kernel_rfl PRE_first_tail_x15_r0_body.zw174_4910 : (PRE_first_tail_x15_r0_body.s1686.heap.get 4910).isSome = true
kernel_rfl PRE_first_tail_x15_r0_body.zw174_2673472 : (PRE_first_tail_x15_r0_body.s1686.heap.get 2673472).isSome = true
kernel_rfl PRE_first_tail_x15_r0_body.zw174_2673473 : (PRE_first_tail_x15_r0_body.s1686.heap.get 2673473).isSome = true
-- the heap: the changed list in range, holding the stage's written and fresh addresses; the canonical side's image
kernel_rfl PRE_first_tail_x15_r0_body.zclbd174 : PRE_first_tail_x15_r0_body.cl174.all (fun b => Nat.blt (b / 4096) (4 ^ 31)) = true
kernel_rfl PRE_first_tail_x15_r0_body.zwr174 : PRE_first_tail_x15_r0_body.st174.wr.all (fun b => !Nat.blt b PRE_first_tail_x15_r0_body.s1684.next || PRE_first_tail_x15_r0_body.cl174.contains b) = true
def PRE_first_tail_x15_r0_body.zl174 : List Nat := PRE_first_tail_x15_r0_body.cl174.filter fun a => !(List.contains [2665, 2673467] a)
kernel_rfl PRE_first_tail_x15_r0_body.zimgE174 : PRE_first_tail_x15_r0_body.zl174.map (fun a => PRE_first_tail_x15_r0_body.s1685.heap.get (PRE_first_tail_x15_r0_body.kappa174.a a)) = PRE_first_tail_x15_r0_body.zl174.map (fun a => (PRE_first_tail_x15_r0_body.s1686.heap.get a).map PRE_first_tail_x15_r0_body.kappa174.hobj)
theorem PRE_first_tail_x15_r0_body.zimg174 : HeapImg PRE_first_tail_x15_r0_body.kappa174 PRE_first_tail_x15_r0_body.s1686 PRE_first_tail_x15_r0_body.s1685 PRE_first_tail_x15_r0_body.zl174 := PRE_first_tail_x15_r0_body.zimgE174
-- the roots and their supports
kernel_rfl PRE_first_tail_x15_r0_body.zctl174 : PRE_first_tail_x15_r0_body.s1685.ctl = PRE_first_tail_x15_r0_body.kappa174.ctl PRE_first_tail_x15_r0_body.s1686.ctl
kernel_rfl PRE_first_tail_x15_r0_body.zstack174 : PRE_first_tail_x15_r0_body.s1685.stack = PRE_first_tail_x15_r0_body.s1686.stack.map PRE_first_tail_x15_r0_body.kappa174.frame
kernel_rfl PRE_first_tail_x15_r0_body.zjobs174 : PRE_first_tail_x15_r0_body.s1685.jobs = PRE_first_tail_x15_r0_body.s1686.jobs.map PRE_first_tail_x15_r0_body.kappa174.job
kernel_rfl PRE_first_tail_x15_r0_body.zstores174 : PRE_first_tail_x15_r0_body.s1685.stores = PRE_first_tail_x15_r0_body.kappa174.stores PRE_first_tail_x15_r0_body.s1686.stores
kernel_rfl PRE_first_tail_x15_r0_body.zroots174 : checkRootsSupp PRE_first_tail_x15_r0_body.s1686 7541 = true
kernel_rfl PRE_first_tail_x15_r0_body.znC174 : PRE_first_tail_x15_r0_body.S1684.tab.length + PRE_first_tail_x15_r0_body.cws174.length = 7541
-- the map as `Conv.compact_shift` states it (the call's counters for the literals)
kernel_rfl PRE_first_tail_x15_r0_body.zkap174 : PRE_first_tail_x15_r0_body.kappa174 = Conv.Map.compact PRE_first_tail_x15_r0_body.s1684.next 2812974 PRE_first_tail_x15_r0_body.S1684.tab.length PRE_first_tail_x15_r0_body.pl174 (PRE_first_tail_x15_r0_body.nr174.map NumV.ref) PRE_first_tail_x15_r0_body.kd174.big
  PRE_first_tail_x15_r0_body.kd174.region PRE_first_tail_x15_r0_body.kd174.nodeF
-- the bridge inactive at the canonical state (`Conv.FullShiftQ.toX`; the merged state's bridge is the canonical's: cbridge)
theorem PRE_first_tail_x15_r0_body.zbin174 : (Host.Ts.Sim.Full.bridgeOf PRE_first_tail_x15_r0_body.s1686.ffi).active = false := (Host.Load.Boot.replay_active Host.Load.Run.Prompt.P.oblog2818)
-- the JS bookkeeping's step (`Conv.JClean.step` over the changed list) and the canonical roots' bigint freedom
kernel_rfl PRE_first_tail_x15_r0_body.zjc174 : Conv.jcleanListB (⟨21637, 18749, 2811825, 7541⟩ : Conv.Cnt) PRE_first_tail_x15_r0_body.s1686 PRE_first_tail_x15_r0_body.cl174 = true
kernel_rfl PRE_first_tail_x15_r0_body.zrootsB174 : noBigRootsP (fun i => !Conv.oldBigB (⟨21637, 18749, 2811825, 7541⟩ : Conv.Cnt) i) PRE_first_tail_x15_r0_body.s1686.trace PRE_first_tail_x15_r0_body.s1686 = true
kernel_rfl PRE_first_tail_x15_r0_body.zhm174 : Nat.ble (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s0.ffi).mlx.nnext 18722 = true
theorem PRE_first_tail_x15_r0_body.cjcl174 (h : Conv.JClean (⟨21634, 18722, 2811819, 7523⟩ : Conv.Cnt) PRE_first_tail_x15_r0_body.s1684) : Conv.JClean (⟨21637, 18749, 2811825, 7541⟩ : Conv.Cnt) PRE_first_tail_x15_r0_body.s1686 :=
  Conv.JClean.step h (Conv.Cnt.le_of_leB PRE_first_tail_x15_r0_body.cle174)
    (Conv.heap_off_setAll PRE_first_tail_x15_r0_body.cheap174 fun a ha => Nat.blt_eq.mp (List.all_eq_true.mp PRE_first_tail_x15_r0_body.zclbd174 a ha)) PRE_first_tail_x15_r0_body.zjc174

end Host.Load.Run.Tpl
