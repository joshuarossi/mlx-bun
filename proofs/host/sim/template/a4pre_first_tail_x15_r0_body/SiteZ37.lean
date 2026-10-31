import host.sim.template.a4pre_first_tail_x15_r0_body.SiteS37
import host.sim.template.a4pre_first_tail_x15_r0_body.SiteK37
import host.sim.template.a4pre_first_tail_x15_r0_body.SiteF37
import host.sim.conv.CompactShift
import host.sim.template.Check
import host.sim.BigFreeP
import host.sim.template.CallGen
set_option Elab.async false
namespace Host.Load.Run.Tpl
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
open Host.Ts Host.Ts.Sim Host.Ts.Sim.Template

/-! The compaction's state shift at call site 37 of chain `PRE_first_tail_x15_r0_body` (`Conv.compact_shift`): the call `PRE_first_tail_x15_r0_body.s336`, the merged
state `PRE_first_tail_x15_r0_body.s337`, the canonical state `PRE_first_tail_x15_r0_body.s338`; its frames [2665,2673467,2673472,2673473] (kept arrays [2665,2673467]). -/

-- the map's places and counters
kernel_rfl PRE_first_tail_x15_r0_body.zpl37 : PRE_first_tail_x15_r0_body.pl37.all (Nat.ble PRE_first_tail_x15_r0_body.s336.next) = true
kernel_rfl PRE_first_tail_x15_r0_body.zplnd37 : nodupT PRE_first_tail_x15_r0_body.pl37 PTrie.nil = true
kernel_rfl PRE_first_tail_x15_r0_body.zn137 : Nat.ble PRE_first_tail_x15_r0_body.s336.next 2704201 = true
kernel_rfl PRE_first_tail_x15_r0_body.zfirst37 : Nat.ble aFirst PRE_first_tail_x15_r0_body.s336.next = true
kernel_rfl PRE_first_tail_x15_r0_body.zscn37 : PRE_first_tail_x15_r0_body.s338.next = PRE_first_tail_x15_r0_body.s336.next + PRE_first_tail_x15_r0_body.pl37.length
kernel_rfl PRE_first_tail_x15_r0_body.zsmn37 : PRE_first_tail_x15_r0_body.s337.next = 2704201
kernel_rfl PRE_first_tail_x15_r0_body.zgrow37 : Nat.ble PRE_first_tail_x15_r0_body.s338.next PRE_first_tail_x15_r0_body.s337.next = true
-- the tables
kernel_rfl PRE_first_tail_x15_r0_body.zfresh37 : PRE_first_tail_x15_r0_body.S336.tab.all (fun e => PRE_first_tail_x15_r0_body.cws37.all fun v => e.noVar v) = true
kernel_rfl PRE_first_tail_x15_r0_body.zcnd37 : nodupT PRE_first_tail_x15_r0_body.cws37 PTrie.nil = true
kernel_rfl PRE_first_tail_x15_r0_body.znrHi37 : PRE_first_tail_x15_r0_body.nr37.all (fun r => Nat.blt r PRE_first_tail_x15_r0_body.S337.tab.length) = true
-- the frames: every framed address below the call's counter; the kept arrays the chain start's, extended in the merged state
kernel_rfl PRE_first_tail_x15_r0_body.zfrlt37 : [2665, 2673467, 2673472, 2673473].all (fun a => Nat.blt a PRE_first_tail_x15_r0_body.s336.next) = true
kernel_rfl PRE_first_tail_x15_r0_body.zg37_2665 : PRE_first_tail_x15_r0_body.s338.heap.get 2665 = some (.obj (objOf PRE_first_tail_x15_r0_body.s338 2665))
kernel_rfl PRE_first_tail_x15_r0_body.zk37_2665 : (objOf PRE_first_tail_x15_r0_body.s338 2665).kind = .array (arrOf PRE_first_tail_x15_r0_body.s0 2665)
kernel_rfl PRE_first_tail_x15_r0_body.zm37_2665 : PRE_first_tail_x15_r0_body.s337.heap.get 2665 = some (.obj { PRE_first_tail_x15_r0_body.kappa37.obj (objOf PRE_first_tail_x15_r0_body.s338 2665) with
  kind := .array (arrOf PRE_first_tail_x15_r0_body.s0 2665 ++ (arrOf PRE_first_tail_x15_r0_body.s337 2665).drop (arrOf PRE_first_tail_x15_r0_body.s0 2665).length) })
kernel_rfl PRE_first_tail_x15_r0_body.zg37_2673467 : PRE_first_tail_x15_r0_body.s338.heap.get 2673467 = some (.obj (objOf PRE_first_tail_x15_r0_body.s338 2673467))
kernel_rfl PRE_first_tail_x15_r0_body.zk37_2673467 : (objOf PRE_first_tail_x15_r0_body.s338 2673467).kind = .array (arrOf PRE_first_tail_x15_r0_body.s0 2673467)
kernel_rfl PRE_first_tail_x15_r0_body.zm37_2673467 : PRE_first_tail_x15_r0_body.s337.heap.get 2673467 = some (.obj { PRE_first_tail_x15_r0_body.kappa37.obj (objOf PRE_first_tail_x15_r0_body.s338 2673467) with
  kind := .array (arrOf PRE_first_tail_x15_r0_body.s0 2673467 ++ (arrOf PRE_first_tail_x15_r0_body.s337 2673467).drop (arrOf PRE_first_tail_x15_r0_body.s0 2673467).length) })
kernel_rfl PRE_first_tail_x15_r0_body.zw37_4910 : (PRE_first_tail_x15_r0_body.s338.heap.get 4910).isSome = true
kernel_rfl PRE_first_tail_x15_r0_body.zw37_2673472 : (PRE_first_tail_x15_r0_body.s338.heap.get 2673472).isSome = true
kernel_rfl PRE_first_tail_x15_r0_body.zw37_2673473 : (PRE_first_tail_x15_r0_body.s338.heap.get 2673473).isSome = true
-- the heap: the changed list in range, holding the stage's written and fresh addresses; the canonical side's image
kernel_rfl PRE_first_tail_x15_r0_body.zclbd37 : PRE_first_tail_x15_r0_body.cl37.all (fun b => Nat.blt (b / 4096) (4 ^ 31)) = true
kernel_rfl PRE_first_tail_x15_r0_body.zwr37 : PRE_first_tail_x15_r0_body.st37.wr.all (fun b => !Nat.blt b PRE_first_tail_x15_r0_body.s336.next || PRE_first_tail_x15_r0_body.cl37.contains b) = true
def PRE_first_tail_x15_r0_body.zl37 : List Nat := PRE_first_tail_x15_r0_body.cl37.filter fun a => !(List.contains [2665, 2673467] a)
kernel_rfl PRE_first_tail_x15_r0_body.zimgE37 : PRE_first_tail_x15_r0_body.zl37.map (fun a => PRE_first_tail_x15_r0_body.s337.heap.get (PRE_first_tail_x15_r0_body.kappa37.a a)) = PRE_first_tail_x15_r0_body.zl37.map (fun a => (PRE_first_tail_x15_r0_body.s338.heap.get a).map PRE_first_tail_x15_r0_body.kappa37.hobj)
theorem PRE_first_tail_x15_r0_body.zimg37 : HeapImg PRE_first_tail_x15_r0_body.kappa37 PRE_first_tail_x15_r0_body.s338 PRE_first_tail_x15_r0_body.s337 PRE_first_tail_x15_r0_body.zl37 := PRE_first_tail_x15_r0_body.zimgE37
-- the roots and their supports
kernel_rfl PRE_first_tail_x15_r0_body.zctl37 : PRE_first_tail_x15_r0_body.s337.ctl = PRE_first_tail_x15_r0_body.kappa37.ctl PRE_first_tail_x15_r0_body.s338.ctl
kernel_rfl PRE_first_tail_x15_r0_body.zstack37 : PRE_first_tail_x15_r0_body.s337.stack = PRE_first_tail_x15_r0_body.s338.stack.map PRE_first_tail_x15_r0_body.kappa37.frame
kernel_rfl PRE_first_tail_x15_r0_body.zjobs37 : PRE_first_tail_x15_r0_body.s337.jobs = PRE_first_tail_x15_r0_body.s338.jobs.map PRE_first_tail_x15_r0_body.kappa37.job
kernel_rfl PRE_first_tail_x15_r0_body.zstores37 : PRE_first_tail_x15_r0_body.s337.stores = PRE_first_tail_x15_r0_body.kappa37.stores PRE_first_tail_x15_r0_body.s338.stores
kernel_rfl PRE_first_tail_x15_r0_body.zroots37 : checkRootsSupp PRE_first_tail_x15_r0_body.s338 1661 = true
kernel_rfl PRE_first_tail_x15_r0_body.znC37 : PRE_first_tail_x15_r0_body.S336.tab.length + PRE_first_tail_x15_r0_body.cws37.length = 1661
-- the map as `Conv.compact_shift` states it (the call's counters for the literals)
kernel_rfl PRE_first_tail_x15_r0_body.zkap37 : PRE_first_tail_x15_r0_body.kappa37 = Conv.Map.compact PRE_first_tail_x15_r0_body.s336.next 2704201 PRE_first_tail_x15_r0_body.S336.tab.length PRE_first_tail_x15_r0_body.pl37 (PRE_first_tail_x15_r0_body.nr37.map NumV.ref) PRE_first_tail_x15_r0_body.kd37.big
  PRE_first_tail_x15_r0_body.kd37.region PRE_first_tail_x15_r0_body.kd37.nodeF
-- the bridge inactive at the canonical state (`Conv.FullShiftQ.toX`; the merged state's bridge is the canonical's: cbridge)
theorem PRE_first_tail_x15_r0_body.zbin37 : (Host.Ts.Sim.Full.bridgeOf PRE_first_tail_x15_r0_body.s338.ffi).active = false := (Host.Load.Boot.replay_active Host.Load.Run.Prompt.P.oblog2818)
-- the JS bookkeeping's step (`Conv.JClean.step` over the changed list) and the canonical roots' bigint freedom
kernel_rfl PRE_first_tail_x15_r0_body.zjc37 : Conv.jcleanListB (⟨18940, 16029, 2704199, 1661⟩ : Conv.Cnt) PRE_first_tail_x15_r0_body.s338 PRE_first_tail_x15_r0_body.cl37 = true
kernel_rfl PRE_first_tail_x15_r0_body.zroots237 : noBigRootsP (fun i => !Conv.oldBigB (⟨18940, 16029, 2704199, 1661⟩ : Conv.Cnt) i) PRE_first_tail_x15_r0_body.s338.trace PRE_first_tail_x15_r0_body.s338 = true
kernel_rfl PRE_first_tail_x15_r0_body.zhm37 : Nat.ble (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s0.ffi).mlx.nnext 16029 = true
theorem PRE_first_tail_x15_r0_body.cjcl37 (h : Conv.JClean (⟨18940, 16029, 2704199, 1661⟩ : Conv.Cnt) PRE_first_tail_x15_r0_body.s336) : Conv.JClean (⟨18940, 16029, 2704199, 1661⟩ : Conv.Cnt) PRE_first_tail_x15_r0_body.s338 :=
  Conv.JClean.step h (Conv.Cnt.le_of_leB PRE_first_tail_x15_r0_body.cle37)
    (Conv.heap_off_setAll PRE_first_tail_x15_r0_body.cheap37 fun a ha => Nat.blt_eq.mp (List.all_eq_true.mp PRE_first_tail_x15_r0_body.zclbd37 a ha)) PRE_first_tail_x15_r0_body.zjc37

end Host.Load.Run.Tpl
