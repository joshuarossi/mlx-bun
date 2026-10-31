import host.sim.template.a4pre_first_tail_x15_r0_body.SiteS23
import host.sim.template.a4pre_first_tail_x15_r0_body.SiteK23
import host.sim.template.a4pre_first_tail_x15_r0_body.SiteF23
import host.sim.conv.CompactShift
import host.sim.template.Check
import host.sim.BigFreeP
import host.sim.template.CallGen
set_option Elab.async false
namespace Host.Load.Run.Tpl
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
open Host.Ts Host.Ts.Sim Host.Ts.Sim.Template

/-! The compaction's state shift at call site 23 of chain `PRE_first_tail_x15_r0_body` (`Conv.compact_shift`): the call `PRE_first_tail_x15_r0_body.s208`, the merged
state `PRE_first_tail_x15_r0_body.s209`, the canonical state `PRE_first_tail_x15_r0_body.s210`; its frames [2665,2673467,2673472,2673473] (kept arrays [2665,2673467]). -/

-- the map's places and counters
kernel_rfl PRE_first_tail_x15_r0_body.zpl23 : PRE_first_tail_x15_r0_body.pl23.all (Nat.ble PRE_first_tail_x15_r0_body.s208.next) = true
kernel_rfl PRE_first_tail_x15_r0_body.zplnd23 : nodupT PRE_first_tail_x15_r0_body.pl23 PTrie.nil = true
kernel_rfl PRE_first_tail_x15_r0_body.zn123 : Nat.ble PRE_first_tail_x15_r0_body.s208.next 2692804 = true
kernel_rfl PRE_first_tail_x15_r0_body.zfirst23 : Nat.ble aFirst PRE_first_tail_x15_r0_body.s208.next = true
kernel_rfl PRE_first_tail_x15_r0_body.zscn23 : PRE_first_tail_x15_r0_body.s210.next = PRE_first_tail_x15_r0_body.s208.next + PRE_first_tail_x15_r0_body.pl23.length
kernel_rfl PRE_first_tail_x15_r0_body.zsmn23 : PRE_first_tail_x15_r0_body.s209.next = 2692804
kernel_rfl PRE_first_tail_x15_r0_body.zgrow23 : Nat.ble PRE_first_tail_x15_r0_body.s210.next PRE_first_tail_x15_r0_body.s209.next = true
-- the tables
kernel_rfl PRE_first_tail_x15_r0_body.zfresh23 : PRE_first_tail_x15_r0_body.S208.tab.all (fun e => PRE_first_tail_x15_r0_body.cws23.all fun v => e.noVar v) = true
kernel_rfl PRE_first_tail_x15_r0_body.zcnd23 : nodupT PRE_first_tail_x15_r0_body.cws23 PTrie.nil = true
kernel_rfl PRE_first_tail_x15_r0_body.znrHi23 : PRE_first_tail_x15_r0_body.nr23.all (fun r => Nat.blt r PRE_first_tail_x15_r0_body.S209.tab.length) = true
-- the frames: every framed address below the call's counter; the kept arrays the chain start's, extended in the merged state
kernel_rfl PRE_first_tail_x15_r0_body.zfrlt23 : [2665, 2673467, 2673472, 2673473].all (fun a => Nat.blt a PRE_first_tail_x15_r0_body.s208.next) = true
kernel_rfl PRE_first_tail_x15_r0_body.zg23_2665 : PRE_first_tail_x15_r0_body.s210.heap.get 2665 = some (.obj (objOf PRE_first_tail_x15_r0_body.s210 2665))
kernel_rfl PRE_first_tail_x15_r0_body.zk23_2665 : (objOf PRE_first_tail_x15_r0_body.s210 2665).kind = .array (arrOf PRE_first_tail_x15_r0_body.s0 2665)
kernel_rfl PRE_first_tail_x15_r0_body.zm23_2665 : PRE_first_tail_x15_r0_body.s209.heap.get 2665 = some (.obj { PRE_first_tail_x15_r0_body.kappa23.obj (objOf PRE_first_tail_x15_r0_body.s210 2665) with
  kind := .array (arrOf PRE_first_tail_x15_r0_body.s0 2665 ++ (arrOf PRE_first_tail_x15_r0_body.s209 2665).drop (arrOf PRE_first_tail_x15_r0_body.s0 2665).length) })
kernel_rfl PRE_first_tail_x15_r0_body.zg23_2673467 : PRE_first_tail_x15_r0_body.s210.heap.get 2673467 = some (.obj (objOf PRE_first_tail_x15_r0_body.s210 2673467))
kernel_rfl PRE_first_tail_x15_r0_body.zk23_2673467 : (objOf PRE_first_tail_x15_r0_body.s210 2673467).kind = .array (arrOf PRE_first_tail_x15_r0_body.s0 2673467)
kernel_rfl PRE_first_tail_x15_r0_body.zm23_2673467 : PRE_first_tail_x15_r0_body.s209.heap.get 2673467 = some (.obj { PRE_first_tail_x15_r0_body.kappa23.obj (objOf PRE_first_tail_x15_r0_body.s210 2673467) with
  kind := .array (arrOf PRE_first_tail_x15_r0_body.s0 2673467 ++ (arrOf PRE_first_tail_x15_r0_body.s209 2673467).drop (arrOf PRE_first_tail_x15_r0_body.s0 2673467).length) })
kernel_rfl PRE_first_tail_x15_r0_body.zw23_4910 : (PRE_first_tail_x15_r0_body.s210.heap.get 4910).isSome = true
kernel_rfl PRE_first_tail_x15_r0_body.zw23_2673472 : (PRE_first_tail_x15_r0_body.s210.heap.get 2673472).isSome = true
kernel_rfl PRE_first_tail_x15_r0_body.zw23_2673473 : (PRE_first_tail_x15_r0_body.s210.heap.get 2673473).isSome = true
-- the heap: the changed list in range, holding the stage's written and fresh addresses; the canonical side's image
kernel_rfl PRE_first_tail_x15_r0_body.zclbd23 : PRE_first_tail_x15_r0_body.cl23.all (fun b => Nat.blt (b / 4096) (4 ^ 31)) = true
kernel_rfl PRE_first_tail_x15_r0_body.zwr23 : PRE_first_tail_x15_r0_body.st23.wr.all (fun b => !Nat.blt b PRE_first_tail_x15_r0_body.s208.next || PRE_first_tail_x15_r0_body.cl23.contains b) = true
def PRE_first_tail_x15_r0_body.zl23 : List Nat := PRE_first_tail_x15_r0_body.cl23.filter fun a => !(List.contains [2665, 2673467] a)
kernel_rfl PRE_first_tail_x15_r0_body.zimgE23 : PRE_first_tail_x15_r0_body.zl23.map (fun a => PRE_first_tail_x15_r0_body.s209.heap.get (PRE_first_tail_x15_r0_body.kappa23.a a)) = PRE_first_tail_x15_r0_body.zl23.map (fun a => (PRE_first_tail_x15_r0_body.s210.heap.get a).map PRE_first_tail_x15_r0_body.kappa23.hobj)
theorem PRE_first_tail_x15_r0_body.zimg23 : HeapImg PRE_first_tail_x15_r0_body.kappa23 PRE_first_tail_x15_r0_body.s210 PRE_first_tail_x15_r0_body.s209 PRE_first_tail_x15_r0_body.zl23 := PRE_first_tail_x15_r0_body.zimgE23
-- the roots and their supports
kernel_rfl PRE_first_tail_x15_r0_body.zctl23 : PRE_first_tail_x15_r0_body.s209.ctl = PRE_first_tail_x15_r0_body.kappa23.ctl PRE_first_tail_x15_r0_body.s210.ctl
kernel_rfl PRE_first_tail_x15_r0_body.zstack23 : PRE_first_tail_x15_r0_body.s209.stack = PRE_first_tail_x15_r0_body.s210.stack.map PRE_first_tail_x15_r0_body.kappa23.frame
kernel_rfl PRE_first_tail_x15_r0_body.zjobs23 : PRE_first_tail_x15_r0_body.s209.jobs = PRE_first_tail_x15_r0_body.s210.jobs.map PRE_first_tail_x15_r0_body.kappa23.job
kernel_rfl PRE_first_tail_x15_r0_body.zstores23 : PRE_first_tail_x15_r0_body.s209.stores = PRE_first_tail_x15_r0_body.kappa23.stores PRE_first_tail_x15_r0_body.s210.stores
kernel_rfl PRE_first_tail_x15_r0_body.zroots23 : checkRootsSupp PRE_first_tail_x15_r0_body.s210 1036 = true
kernel_rfl PRE_first_tail_x15_r0_body.znC23 : PRE_first_tail_x15_r0_body.S208.tab.length + PRE_first_tail_x15_r0_body.cws23.length = 1036
-- the map as `Conv.compact_shift` states it (the call's counters for the literals)
kernel_rfl PRE_first_tail_x15_r0_body.zkap23 : PRE_first_tail_x15_r0_body.kappa23 = Conv.Map.compact PRE_first_tail_x15_r0_body.s208.next 2692804 PRE_first_tail_x15_r0_body.S208.tab.length PRE_first_tail_x15_r0_body.pl23 (PRE_first_tail_x15_r0_body.nr23.map NumV.ref) PRE_first_tail_x15_r0_body.kd23.big
  PRE_first_tail_x15_r0_body.kd23.region PRE_first_tail_x15_r0_body.kd23.nodeF
-- the bridge inactive at the canonical state (`Conv.FullShiftQ.toX`; the merged state's bridge is the canonical's: cbridge)
theorem PRE_first_tail_x15_r0_body.zbin23 : (Host.Ts.Sim.Full.bridgeOf PRE_first_tail_x15_r0_body.s210.ffi).active = false := (Host.Load.Boot.replay_active Host.Load.Run.Prompt.P.oblog2818)
-- the JS bookkeeping's step (`Conv.JClean.step` over the changed list) and the canonical roots' bigint freedom
kernel_rfl PRE_first_tail_x15_r0_body.zjc23 : Conv.jcleanListB (⟨18653, 15733, 2692794, 1036⟩ : Conv.Cnt) PRE_first_tail_x15_r0_body.s210 PRE_first_tail_x15_r0_body.cl23 = true
kernel_rfl PRE_first_tail_x15_r0_body.zroots223 : noBigRootsP (fun i => !Conv.oldBigB (⟨18653, 15733, 2692794, 1036⟩ : Conv.Cnt) i) PRE_first_tail_x15_r0_body.s210.trace PRE_first_tail_x15_r0_body.s210 = true
kernel_rfl PRE_first_tail_x15_r0_body.zhm23 : Nat.ble (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s0.ffi).mlx.nnext 15733 = true
theorem PRE_first_tail_x15_r0_body.cjcl23 (h : Conv.JClean (⟨18653, 15733, 2692793, 1036⟩ : Conv.Cnt) PRE_first_tail_x15_r0_body.s208) : Conv.JClean (⟨18653, 15733, 2692794, 1036⟩ : Conv.Cnt) PRE_first_tail_x15_r0_body.s210 :=
  Conv.JClean.step h (Conv.Cnt.le_of_leB PRE_first_tail_x15_r0_body.cle23)
    (Conv.heap_off_setAll PRE_first_tail_x15_r0_body.cheap23 fun a ha => Nat.blt_eq.mp (List.all_eq_true.mp PRE_first_tail_x15_r0_body.zclbd23 a ha)) PRE_first_tail_x15_r0_body.zjc23

end Host.Load.Run.Tpl
