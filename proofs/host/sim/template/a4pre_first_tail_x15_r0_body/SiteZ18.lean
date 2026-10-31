import host.sim.template.a4pre_first_tail_x15_r0_body.SiteS18
import host.sim.template.a4pre_first_tail_x15_r0_body.SiteK18
import host.sim.template.a4pre_first_tail_x15_r0_body.SiteF18
import host.sim.conv.CompactShift
import host.sim.template.Check
import host.sim.BigFreeP
import host.sim.template.CallGen
set_option Elab.async false
namespace Host.Load.Run.Tpl
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
open Host.Ts Host.Ts.Sim Host.Ts.Sim.Template

/-! The compaction's state shift at call site 18 of chain `PRE_first_tail_x15_r0_body` (`Conv.compact_shift`): the call `PRE_first_tail_x15_r0_body.s189`, the merged
state `PRE_first_tail_x15_r0_body.s190`, the canonical state `PRE_first_tail_x15_r0_body.s191`; its frames [2665,2673467,2673472,2673473] (kept arrays [2665,2673467]). -/

-- the map's places and counters
kernel_rfl PRE_first_tail_x15_r0_body.zpl18 : PRE_first_tail_x15_r0_body.pl18.all (Nat.ble PRE_first_tail_x15_r0_body.s189.next) = true
kernel_rfl PRE_first_tail_x15_r0_body.zplnd18 : nodupT PRE_first_tail_x15_r0_body.pl18 PTrie.nil = true
kernel_rfl PRE_first_tail_x15_r0_body.zn118 : Nat.ble PRE_first_tail_x15_r0_body.s189.next 2690542 = true
kernel_rfl PRE_first_tail_x15_r0_body.zfirst18 : Nat.ble aFirst PRE_first_tail_x15_r0_body.s189.next = true
kernel_rfl PRE_first_tail_x15_r0_body.zscn18 : PRE_first_tail_x15_r0_body.s191.next = PRE_first_tail_x15_r0_body.s189.next + PRE_first_tail_x15_r0_body.pl18.length
kernel_rfl PRE_first_tail_x15_r0_body.zsmn18 : PRE_first_tail_x15_r0_body.s190.next = 2690542
kernel_rfl PRE_first_tail_x15_r0_body.zgrow18 : Nat.ble PRE_first_tail_x15_r0_body.s191.next PRE_first_tail_x15_r0_body.s190.next = true
-- the tables
kernel_rfl PRE_first_tail_x15_r0_body.zfresh18 : PRE_first_tail_x15_r0_body.S189.tab.all (fun e => PRE_first_tail_x15_r0_body.cws18.all fun v => e.noVar v) = true
kernel_rfl PRE_first_tail_x15_r0_body.zcnd18 : nodupT PRE_first_tail_x15_r0_body.cws18 PTrie.nil = true
kernel_rfl PRE_first_tail_x15_r0_body.znrHi18 : PRE_first_tail_x15_r0_body.nr18.all (fun r => Nat.blt r PRE_first_tail_x15_r0_body.S190.tab.length) = true
-- the frames: every framed address below the call's counter; the kept arrays the chain start's, extended in the merged state
kernel_rfl PRE_first_tail_x15_r0_body.zfrlt18 : [2665, 2673467, 2673472, 2673473].all (fun a => Nat.blt a PRE_first_tail_x15_r0_body.s189.next) = true
kernel_rfl PRE_first_tail_x15_r0_body.zg18_2665 : PRE_first_tail_x15_r0_body.s191.heap.get 2665 = some (.obj (objOf PRE_first_tail_x15_r0_body.s191 2665))
kernel_rfl PRE_first_tail_x15_r0_body.zk18_2665 : (objOf PRE_first_tail_x15_r0_body.s191 2665).kind = .array (arrOf PRE_first_tail_x15_r0_body.s0 2665)
kernel_rfl PRE_first_tail_x15_r0_body.zm18_2665 : PRE_first_tail_x15_r0_body.s190.heap.get 2665 = some (.obj { PRE_first_tail_x15_r0_body.kappa18.obj (objOf PRE_first_tail_x15_r0_body.s191 2665) with
  kind := .array (arrOf PRE_first_tail_x15_r0_body.s0 2665 ++ (arrOf PRE_first_tail_x15_r0_body.s190 2665).drop (arrOf PRE_first_tail_x15_r0_body.s0 2665).length) })
kernel_rfl PRE_first_tail_x15_r0_body.zg18_2673467 : PRE_first_tail_x15_r0_body.s191.heap.get 2673467 = some (.obj (objOf PRE_first_tail_x15_r0_body.s191 2673467))
kernel_rfl PRE_first_tail_x15_r0_body.zk18_2673467 : (objOf PRE_first_tail_x15_r0_body.s191 2673467).kind = .array (arrOf PRE_first_tail_x15_r0_body.s0 2673467)
kernel_rfl PRE_first_tail_x15_r0_body.zm18_2673467 : PRE_first_tail_x15_r0_body.s190.heap.get 2673467 = some (.obj { PRE_first_tail_x15_r0_body.kappa18.obj (objOf PRE_first_tail_x15_r0_body.s191 2673467) with
  kind := .array (arrOf PRE_first_tail_x15_r0_body.s0 2673467 ++ (arrOf PRE_first_tail_x15_r0_body.s190 2673467).drop (arrOf PRE_first_tail_x15_r0_body.s0 2673467).length) })
kernel_rfl PRE_first_tail_x15_r0_body.zw18_4910 : (PRE_first_tail_x15_r0_body.s191.heap.get 4910).isSome = true
kernel_rfl PRE_first_tail_x15_r0_body.zw18_2673472 : (PRE_first_tail_x15_r0_body.s191.heap.get 2673472).isSome = true
kernel_rfl PRE_first_tail_x15_r0_body.zw18_2673473 : (PRE_first_tail_x15_r0_body.s191.heap.get 2673473).isSome = true
-- the heap: the changed list in range, holding the stage's written and fresh addresses; the canonical side's image
kernel_rfl PRE_first_tail_x15_r0_body.zclbd18 : PRE_first_tail_x15_r0_body.cl18.all (fun b => Nat.blt (b / 4096) (4 ^ 31)) = true
kernel_rfl PRE_first_tail_x15_r0_body.zwr18 : PRE_first_tail_x15_r0_body.st18.wr.all (fun b => !Nat.blt b PRE_first_tail_x15_r0_body.s189.next || PRE_first_tail_x15_r0_body.cl18.contains b) = true
def PRE_first_tail_x15_r0_body.zl18 : List Nat := PRE_first_tail_x15_r0_body.cl18.filter fun a => !(List.contains [2665, 2673467] a)
kernel_rfl PRE_first_tail_x15_r0_body.zimgE18 : PRE_first_tail_x15_r0_body.zl18.map (fun a => PRE_first_tail_x15_r0_body.s190.heap.get (PRE_first_tail_x15_r0_body.kappa18.a a)) = PRE_first_tail_x15_r0_body.zl18.map (fun a => (PRE_first_tail_x15_r0_body.s191.heap.get a).map PRE_first_tail_x15_r0_body.kappa18.hobj)
theorem PRE_first_tail_x15_r0_body.zimg18 : HeapImg PRE_first_tail_x15_r0_body.kappa18 PRE_first_tail_x15_r0_body.s191 PRE_first_tail_x15_r0_body.s190 PRE_first_tail_x15_r0_body.zl18 := PRE_first_tail_x15_r0_body.zimgE18
-- the roots and their supports
kernel_rfl PRE_first_tail_x15_r0_body.zctl18 : PRE_first_tail_x15_r0_body.s190.ctl = PRE_first_tail_x15_r0_body.kappa18.ctl PRE_first_tail_x15_r0_body.s191.ctl
kernel_rfl PRE_first_tail_x15_r0_body.zstack18 : PRE_first_tail_x15_r0_body.s190.stack = PRE_first_tail_x15_r0_body.s191.stack.map PRE_first_tail_x15_r0_body.kappa18.frame
kernel_rfl PRE_first_tail_x15_r0_body.zjobs18 : PRE_first_tail_x15_r0_body.s190.jobs = PRE_first_tail_x15_r0_body.s191.jobs.map PRE_first_tail_x15_r0_body.kappa18.job
kernel_rfl PRE_first_tail_x15_r0_body.zstores18 : PRE_first_tail_x15_r0_body.s190.stores = PRE_first_tail_x15_r0_body.kappa18.stores PRE_first_tail_x15_r0_body.s191.stores
kernel_rfl PRE_first_tail_x15_r0_body.zroots18 : checkRootsSupp PRE_first_tail_x15_r0_body.s191 872 = true
kernel_rfl PRE_first_tail_x15_r0_body.znC18 : PRE_first_tail_x15_r0_body.S189.tab.length + PRE_first_tail_x15_r0_body.cws18.length = 872
-- the map as `Conv.compact_shift` states it (the call's counters for the literals)
kernel_rfl PRE_first_tail_x15_r0_body.zkap18 : PRE_first_tail_x15_r0_body.kappa18 = Conv.Map.compact PRE_first_tail_x15_r0_body.s189.next 2690542 PRE_first_tail_x15_r0_body.S189.tab.length PRE_first_tail_x15_r0_body.pl18 (PRE_first_tail_x15_r0_body.nr18.map NumV.ref) PRE_first_tail_x15_r0_body.kd18.big
  PRE_first_tail_x15_r0_body.kd18.region PRE_first_tail_x15_r0_body.kd18.nodeF
-- the bridge inactive at the canonical state (`Conv.FullShiftQ.toX`; the merged state's bridge is the canonical's: cbridge)
theorem PRE_first_tail_x15_r0_body.zbin18 : (Host.Ts.Sim.Full.bridgeOf PRE_first_tail_x15_r0_body.s191.ffi).active = false := (Host.Load.Boot.replay_active Host.Load.Run.Prompt.P.oblog2818)
-- the JS bookkeeping's step (`Conv.JClean.step` over the changed list) and the canonical roots' bigint freedom
kernel_rfl PRE_first_tail_x15_r0_body.zjc18 : Conv.jcleanListB (⟨18569, 15668, 2689393, 872⟩ : Conv.Cnt) PRE_first_tail_x15_r0_body.s191 PRE_first_tail_x15_r0_body.cl18 = true
kernel_rfl PRE_first_tail_x15_r0_body.zrootsB18 : noBigRootsP (fun i => !Conv.oldBigB (⟨18569, 15668, 2689393, 872⟩ : Conv.Cnt) i) PRE_first_tail_x15_r0_body.s191.trace PRE_first_tail_x15_r0_body.s191 = true
kernel_rfl PRE_first_tail_x15_r0_body.zhm18 : Nat.ble (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s0.ffi).mlx.nnext 15641 = true
theorem PRE_first_tail_x15_r0_body.cjcl18 (h : Conv.JClean (⟨18566, 15641, 2689387, 854⟩ : Conv.Cnt) PRE_first_tail_x15_r0_body.s189) : Conv.JClean (⟨18569, 15668, 2689393, 872⟩ : Conv.Cnt) PRE_first_tail_x15_r0_body.s191 :=
  Conv.JClean.step h (Conv.Cnt.le_of_leB PRE_first_tail_x15_r0_body.cle18)
    (Conv.heap_off_setAll PRE_first_tail_x15_r0_body.cheap18 fun a ha => Nat.blt_eq.mp (List.all_eq_true.mp PRE_first_tail_x15_r0_body.zclbd18 a ha)) PRE_first_tail_x15_r0_body.zjc18

end Host.Load.Run.Tpl
