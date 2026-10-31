import host.sim.template.a4pre_first_tail_x15_r0_body.SiteS82
import host.sim.template.a4pre_first_tail_x15_r0_body.SiteK82
import host.sim.template.a4pre_first_tail_x15_r0_body.SiteF82
import host.sim.conv.CompactShift
import host.sim.template.Check
import host.sim.BigFreeP
import host.sim.template.CallGen
set_option Elab.async false
namespace Host.Load.Run.Tpl
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
open Host.Ts Host.Ts.Sim Host.Ts.Sim.Template

/-! The compaction's state shift at call site 82 of chain `PRE_first_tail_x15_r0_body` (`Conv.compact_shift`): the call `PRE_first_tail_x15_r0_body.s729`, the merged
state `PRE_first_tail_x15_r0_body.s730`, the canonical state `PRE_first_tail_x15_r0_body.s731`; its frames [2665,2673467,2673472,2673473] (kept arrays [2665,2673467]). -/

-- the map's places and counters
kernel_rfl PRE_first_tail_x15_r0_body.zpl82 : PRE_first_tail_x15_r0_body.pl82.all (Nat.ble PRE_first_tail_x15_r0_body.s729.next) = true
kernel_rfl PRE_first_tail_x15_r0_body.zplnd82 : nodupT PRE_first_tail_x15_r0_body.pl82 PTrie.nil = true
kernel_rfl PRE_first_tail_x15_r0_body.zn182 : Nat.ble PRE_first_tail_x15_r0_body.s729.next 2739591 = true
kernel_rfl PRE_first_tail_x15_r0_body.zfirst82 : Nat.ble aFirst PRE_first_tail_x15_r0_body.s729.next = true
kernel_rfl PRE_first_tail_x15_r0_body.zscn82 : PRE_first_tail_x15_r0_body.s731.next = PRE_first_tail_x15_r0_body.s729.next + PRE_first_tail_x15_r0_body.pl82.length
kernel_rfl PRE_first_tail_x15_r0_body.zsmn82 : PRE_first_tail_x15_r0_body.s730.next = 2739591
kernel_rfl PRE_first_tail_x15_r0_body.zgrow82 : Nat.ble PRE_first_tail_x15_r0_body.s731.next PRE_first_tail_x15_r0_body.s730.next = true
-- the tables
kernel_rfl PRE_first_tail_x15_r0_body.zfresh82 : PRE_first_tail_x15_r0_body.S729.tab.all (fun e => PRE_first_tail_x15_r0_body.cws82.all fun v => e.noVar v) = true
kernel_rfl PRE_first_tail_x15_r0_body.zcnd82 : nodupT PRE_first_tail_x15_r0_body.cws82 PTrie.nil = true
kernel_rfl PRE_first_tail_x15_r0_body.znrHi82 : PRE_first_tail_x15_r0_body.nr82.all (fun r => Nat.blt r PRE_first_tail_x15_r0_body.S730.tab.length) = true
-- the frames: every framed address below the call's counter; the kept arrays the chain start's, extended in the merged state
kernel_rfl PRE_first_tail_x15_r0_body.zfrlt82 : [2665, 2673467, 2673472, 2673473].all (fun a => Nat.blt a PRE_first_tail_x15_r0_body.s729.next) = true
kernel_rfl PRE_first_tail_x15_r0_body.zg82_2665 : PRE_first_tail_x15_r0_body.s731.heap.get 2665 = some (.obj (objOf PRE_first_tail_x15_r0_body.s731 2665))
kernel_rfl PRE_first_tail_x15_r0_body.zk82_2665 : (objOf PRE_first_tail_x15_r0_body.s731 2665).kind = .array (arrOf PRE_first_tail_x15_r0_body.s0 2665)
kernel_rfl PRE_first_tail_x15_r0_body.zm82_2665 : PRE_first_tail_x15_r0_body.s730.heap.get 2665 = some (.obj { PRE_first_tail_x15_r0_body.kappa82.obj (objOf PRE_first_tail_x15_r0_body.s731 2665) with
  kind := .array (arrOf PRE_first_tail_x15_r0_body.s0 2665 ++ (arrOf PRE_first_tail_x15_r0_body.s730 2665).drop (arrOf PRE_first_tail_x15_r0_body.s0 2665).length) })
kernel_rfl PRE_first_tail_x15_r0_body.zg82_2673467 : PRE_first_tail_x15_r0_body.s731.heap.get 2673467 = some (.obj (objOf PRE_first_tail_x15_r0_body.s731 2673467))
kernel_rfl PRE_first_tail_x15_r0_body.zk82_2673467 : (objOf PRE_first_tail_x15_r0_body.s731 2673467).kind = .array (arrOf PRE_first_tail_x15_r0_body.s0 2673467)
kernel_rfl PRE_first_tail_x15_r0_body.zm82_2673467 : PRE_first_tail_x15_r0_body.s730.heap.get 2673467 = some (.obj { PRE_first_tail_x15_r0_body.kappa82.obj (objOf PRE_first_tail_x15_r0_body.s731 2673467) with
  kind := .array (arrOf PRE_first_tail_x15_r0_body.s0 2673467 ++ (arrOf PRE_first_tail_x15_r0_body.s730 2673467).drop (arrOf PRE_first_tail_x15_r0_body.s0 2673467).length) })
kernel_rfl PRE_first_tail_x15_r0_body.zw82_4910 : (PRE_first_tail_x15_r0_body.s731.heap.get 4910).isSome = true
kernel_rfl PRE_first_tail_x15_r0_body.zw82_2673472 : (PRE_first_tail_x15_r0_body.s731.heap.get 2673472).isSome = true
kernel_rfl PRE_first_tail_x15_r0_body.zw82_2673473 : (PRE_first_tail_x15_r0_body.s731.heap.get 2673473).isSome = true
-- the heap: the changed list in range, holding the stage's written and fresh addresses; the canonical side's image
kernel_rfl PRE_first_tail_x15_r0_body.zclbd82 : PRE_first_tail_x15_r0_body.cl82.all (fun b => Nat.blt (b / 4096) (4 ^ 31)) = true
kernel_rfl PRE_first_tail_x15_r0_body.zwr82 : PRE_first_tail_x15_r0_body.st82.wr.all (fun b => !Nat.blt b PRE_first_tail_x15_r0_body.s729.next || PRE_first_tail_x15_r0_body.cl82.contains b) = true
def PRE_first_tail_x15_r0_body.zl82 : List Nat := PRE_first_tail_x15_r0_body.cl82.filter fun a => !(List.contains [2665, 2673467] a)
kernel_rfl PRE_first_tail_x15_r0_body.zimgE82 : PRE_first_tail_x15_r0_body.zl82.map (fun a => PRE_first_tail_x15_r0_body.s730.heap.get (PRE_first_tail_x15_r0_body.kappa82.a a)) = PRE_first_tail_x15_r0_body.zl82.map (fun a => (PRE_first_tail_x15_r0_body.s731.heap.get a).map PRE_first_tail_x15_r0_body.kappa82.hobj)
theorem PRE_first_tail_x15_r0_body.zimg82 : HeapImg PRE_first_tail_x15_r0_body.kappa82 PRE_first_tail_x15_r0_body.s731 PRE_first_tail_x15_r0_body.s730 PRE_first_tail_x15_r0_body.zl82 := PRE_first_tail_x15_r0_body.zimgE82
-- the roots and their supports
kernel_rfl PRE_first_tail_x15_r0_body.zctl82 : PRE_first_tail_x15_r0_body.s730.ctl = PRE_first_tail_x15_r0_body.kappa82.ctl PRE_first_tail_x15_r0_body.s731.ctl
kernel_rfl PRE_first_tail_x15_r0_body.zstack82 : PRE_first_tail_x15_r0_body.s730.stack = PRE_first_tail_x15_r0_body.s731.stack.map PRE_first_tail_x15_r0_body.kappa82.frame
kernel_rfl PRE_first_tail_x15_r0_body.zjobs82 : PRE_first_tail_x15_r0_body.s730.jobs = PRE_first_tail_x15_r0_body.s731.jobs.map PRE_first_tail_x15_r0_body.kappa82.job
kernel_rfl PRE_first_tail_x15_r0_body.zstores82 : PRE_first_tail_x15_r0_body.s730.stores = PRE_first_tail_x15_r0_body.kappa82.stores PRE_first_tail_x15_r0_body.s731.stores
kernel_rfl PRE_first_tail_x15_r0_body.zroots82 : checkRootsSupp PRE_first_tail_x15_r0_body.s731 3584 = true
kernel_rfl PRE_first_tail_x15_r0_body.znC82 : PRE_first_tail_x15_r0_body.S729.tab.length + PRE_first_tail_x15_r0_body.cws82.length = 3584
-- the map as `Conv.compact_shift` states it (the call's counters for the literals)
kernel_rfl PRE_first_tail_x15_r0_body.zkap82 : PRE_first_tail_x15_r0_body.kappa82 = Conv.Map.compact PRE_first_tail_x15_r0_body.s729.next 2739591 PRE_first_tail_x15_r0_body.S729.tab.length PRE_first_tail_x15_r0_body.pl82 (PRE_first_tail_x15_r0_body.nr82.map NumV.ref) PRE_first_tail_x15_r0_body.kd82.big
  PRE_first_tail_x15_r0_body.kd82.region PRE_first_tail_x15_r0_body.kd82.nodeF
-- the bridge inactive at the canonical state (`Conv.FullShiftQ.toX`; the merged state's bridge is the canonical's: cbridge)
theorem PRE_first_tail_x15_r0_body.zbin82 : (Host.Ts.Sim.Full.bridgeOf PRE_first_tail_x15_r0_body.s731.ffi).active = false := (Host.Load.Boot.replay_active Host.Load.Run.Prompt.P.oblog2818)
-- the JS bookkeeping's step (`Conv.JClean.step` over the changed list) and the canonical roots' bigint freedom
kernel_rfl PRE_first_tail_x15_r0_body.zjc82 : Conv.jcleanListB (⟨19826, 16914, 2739589, 3584⟩ : Conv.Cnt) PRE_first_tail_x15_r0_body.s731 PRE_first_tail_x15_r0_body.cl82 = true
kernel_rfl PRE_first_tail_x15_r0_body.zroots282 : noBigRootsP (fun i => !Conv.oldBigB (⟨19826, 16914, 2739589, 3584⟩ : Conv.Cnt) i) PRE_first_tail_x15_r0_body.s731.trace PRE_first_tail_x15_r0_body.s731 = true
kernel_rfl PRE_first_tail_x15_r0_body.zhm82 : Nat.ble (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s0.ffi).mlx.nnext 16914 = true
theorem PRE_first_tail_x15_r0_body.cjcl82 (h : Conv.JClean (⟨19826, 16914, 2739589, 3584⟩ : Conv.Cnt) PRE_first_tail_x15_r0_body.s729) : Conv.JClean (⟨19826, 16914, 2739589, 3584⟩ : Conv.Cnt) PRE_first_tail_x15_r0_body.s731 :=
  Conv.JClean.step h (Conv.Cnt.le_of_leB PRE_first_tail_x15_r0_body.cle82)
    (Conv.heap_off_setAll PRE_first_tail_x15_r0_body.cheap82 fun a ha => Nat.blt_eq.mp (List.all_eq_true.mp PRE_first_tail_x15_r0_body.zclbd82 a ha)) PRE_first_tail_x15_r0_body.zjc82

end Host.Load.Run.Tpl
