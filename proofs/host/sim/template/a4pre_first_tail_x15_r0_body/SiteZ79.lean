import host.sim.template.a4pre_first_tail_x15_r0_body.SiteS79
import host.sim.template.a4pre_first_tail_x15_r0_body.SiteK79
import host.sim.template.a4pre_first_tail_x15_r0_body.SiteF79
import host.sim.conv.CompactShift
import host.sim.template.Check
import host.sim.BigFreeP
import host.sim.template.CallGen
set_option Elab.async false
namespace Host.Load.Run.Tpl
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
open Host.Ts Host.Ts.Sim Host.Ts.Sim.Template

/-! The compaction's state shift at call site 79 of chain `PRE_first_tail_x15_r0_body` (`Conv.compact_shift`): the call `PRE_first_tail_x15_r0_body.s705`, the merged
state `PRE_first_tail_x15_r0_body.s706`, the canonical state `PRE_first_tail_x15_r0_body.s707`; its frames [2665,2673467,2673472,2673473] (kept arrays [2665,2673467]). -/

-- the map's places and counters
kernel_rfl PRE_first_tail_x15_r0_body.zpl79 : PRE_first_tail_x15_r0_body.pl79.all (Nat.ble PRE_first_tail_x15_r0_body.s705.next) = true
kernel_rfl PRE_first_tail_x15_r0_body.zplnd79 : nodupT PRE_first_tail_x15_r0_body.pl79 PTrie.nil = true
kernel_rfl PRE_first_tail_x15_r0_body.zn179 : Nat.ble PRE_first_tail_x15_r0_body.s705.next 2736969 = true
kernel_rfl PRE_first_tail_x15_r0_body.zfirst79 : Nat.ble aFirst PRE_first_tail_x15_r0_body.s705.next = true
kernel_rfl PRE_first_tail_x15_r0_body.zscn79 : PRE_first_tail_x15_r0_body.s707.next = PRE_first_tail_x15_r0_body.s705.next + PRE_first_tail_x15_r0_body.pl79.length
kernel_rfl PRE_first_tail_x15_r0_body.zsmn79 : PRE_first_tail_x15_r0_body.s706.next = 2736969
kernel_rfl PRE_first_tail_x15_r0_body.zgrow79 : Nat.ble PRE_first_tail_x15_r0_body.s707.next PRE_first_tail_x15_r0_body.s706.next = true
-- the tables
kernel_rfl PRE_first_tail_x15_r0_body.zfresh79 : PRE_first_tail_x15_r0_body.S705.tab.all (fun e => PRE_first_tail_x15_r0_body.cws79.all fun v => e.noVar v) = true
kernel_rfl PRE_first_tail_x15_r0_body.zcnd79 : nodupT PRE_first_tail_x15_r0_body.cws79 PTrie.nil = true
kernel_rfl PRE_first_tail_x15_r0_body.znrHi79 : PRE_first_tail_x15_r0_body.nr79.all (fun r => Nat.blt r PRE_first_tail_x15_r0_body.S706.tab.length) = true
-- the frames: every framed address below the call's counter; the kept arrays the chain start's, extended in the merged state
kernel_rfl PRE_first_tail_x15_r0_body.zfrlt79 : [2665, 2673467, 2673472, 2673473].all (fun a => Nat.blt a PRE_first_tail_x15_r0_body.s705.next) = true
kernel_rfl PRE_first_tail_x15_r0_body.zg79_2665 : PRE_first_tail_x15_r0_body.s707.heap.get 2665 = some (.obj (objOf PRE_first_tail_x15_r0_body.s707 2665))
kernel_rfl PRE_first_tail_x15_r0_body.zk79_2665 : (objOf PRE_first_tail_x15_r0_body.s707 2665).kind = .array (arrOf PRE_first_tail_x15_r0_body.s0 2665)
kernel_rfl PRE_first_tail_x15_r0_body.zm79_2665 : PRE_first_tail_x15_r0_body.s706.heap.get 2665 = some (.obj { PRE_first_tail_x15_r0_body.kappa79.obj (objOf PRE_first_tail_x15_r0_body.s707 2665) with
  kind := .array (arrOf PRE_first_tail_x15_r0_body.s0 2665 ++ (arrOf PRE_first_tail_x15_r0_body.s706 2665).drop (arrOf PRE_first_tail_x15_r0_body.s0 2665).length) })
kernel_rfl PRE_first_tail_x15_r0_body.zg79_2673467 : PRE_first_tail_x15_r0_body.s707.heap.get 2673467 = some (.obj (objOf PRE_first_tail_x15_r0_body.s707 2673467))
kernel_rfl PRE_first_tail_x15_r0_body.zk79_2673467 : (objOf PRE_first_tail_x15_r0_body.s707 2673467).kind = .array (arrOf PRE_first_tail_x15_r0_body.s0 2673467)
kernel_rfl PRE_first_tail_x15_r0_body.zm79_2673467 : PRE_first_tail_x15_r0_body.s706.heap.get 2673467 = some (.obj { PRE_first_tail_x15_r0_body.kappa79.obj (objOf PRE_first_tail_x15_r0_body.s707 2673467) with
  kind := .array (arrOf PRE_first_tail_x15_r0_body.s0 2673467 ++ (arrOf PRE_first_tail_x15_r0_body.s706 2673467).drop (arrOf PRE_first_tail_x15_r0_body.s0 2673467).length) })
kernel_rfl PRE_first_tail_x15_r0_body.zw79_4910 : (PRE_first_tail_x15_r0_body.s707.heap.get 4910).isSome = true
kernel_rfl PRE_first_tail_x15_r0_body.zw79_2673472 : (PRE_first_tail_x15_r0_body.s707.heap.get 2673472).isSome = true
kernel_rfl PRE_first_tail_x15_r0_body.zw79_2673473 : (PRE_first_tail_x15_r0_body.s707.heap.get 2673473).isSome = true
-- the heap: the changed list in range, holding the stage's written and fresh addresses; the canonical side's image
kernel_rfl PRE_first_tail_x15_r0_body.zclbd79 : PRE_first_tail_x15_r0_body.cl79.all (fun b => Nat.blt (b / 4096) (4 ^ 31)) = true
kernel_rfl PRE_first_tail_x15_r0_body.zwr79 : PRE_first_tail_x15_r0_body.st79.wr.all (fun b => !Nat.blt b PRE_first_tail_x15_r0_body.s705.next || PRE_first_tail_x15_r0_body.cl79.contains b) = true
def PRE_first_tail_x15_r0_body.zl79 : List Nat := PRE_first_tail_x15_r0_body.cl79.filter fun a => !(List.contains [2665, 2673467] a)
kernel_rfl PRE_first_tail_x15_r0_body.zimgE79 : PRE_first_tail_x15_r0_body.zl79.map (fun a => PRE_first_tail_x15_r0_body.s706.heap.get (PRE_first_tail_x15_r0_body.kappa79.a a)) = PRE_first_tail_x15_r0_body.zl79.map (fun a => (PRE_first_tail_x15_r0_body.s707.heap.get a).map PRE_first_tail_x15_r0_body.kappa79.hobj)
theorem PRE_first_tail_x15_r0_body.zimg79 : HeapImg PRE_first_tail_x15_r0_body.kappa79 PRE_first_tail_x15_r0_body.s707 PRE_first_tail_x15_r0_body.s706 PRE_first_tail_x15_r0_body.zl79 := PRE_first_tail_x15_r0_body.zimgE79
-- the roots and their supports
kernel_rfl PRE_first_tail_x15_r0_body.zctl79 : PRE_first_tail_x15_r0_body.s706.ctl = PRE_first_tail_x15_r0_body.kappa79.ctl PRE_first_tail_x15_r0_body.s707.ctl
kernel_rfl PRE_first_tail_x15_r0_body.zstack79 : PRE_first_tail_x15_r0_body.s706.stack = PRE_first_tail_x15_r0_body.s707.stack.map PRE_first_tail_x15_r0_body.kappa79.frame
kernel_rfl PRE_first_tail_x15_r0_body.zjobs79 : PRE_first_tail_x15_r0_body.s706.jobs = PRE_first_tail_x15_r0_body.s707.jobs.map PRE_first_tail_x15_r0_body.kappa79.job
kernel_rfl PRE_first_tail_x15_r0_body.zstores79 : PRE_first_tail_x15_r0_body.s706.stores = PRE_first_tail_x15_r0_body.kappa79.stores PRE_first_tail_x15_r0_body.s707.stores
kernel_rfl PRE_first_tail_x15_r0_body.zroots79 : checkRootsSupp PRE_first_tail_x15_r0_body.s707 3458 = true
kernel_rfl PRE_first_tail_x15_r0_body.znC79 : PRE_first_tail_x15_r0_body.S705.tab.length + PRE_first_tail_x15_r0_body.cws79.length = 3458
-- the map as `Conv.compact_shift` states it (the call's counters for the literals)
kernel_rfl PRE_first_tail_x15_r0_body.zkap79 : PRE_first_tail_x15_r0_body.kappa79 = Conv.Map.compact PRE_first_tail_x15_r0_body.s705.next 2736969 PRE_first_tail_x15_r0_body.S705.tab.length PRE_first_tail_x15_r0_body.pl79 (PRE_first_tail_x15_r0_body.nr79.map NumV.ref) PRE_first_tail_x15_r0_body.kd79.big
  PRE_first_tail_x15_r0_body.kd79.region PRE_first_tail_x15_r0_body.kd79.nodeF
-- the bridge inactive at the canonical state (`Conv.FullShiftQ.toX`; the merged state's bridge is the canonical's: cbridge)
theorem PRE_first_tail_x15_r0_body.zbin79 : (Host.Ts.Sim.Full.bridgeOf PRE_first_tail_x15_r0_body.s707.ffi).active = false := (Host.Load.Boot.replay_active Host.Load.Run.Prompt.P.oblog2818)
-- the JS bookkeeping's step (`Conv.JClean.step` over the changed list) and the canonical roots' bigint freedom
kernel_rfl PRE_first_tail_x15_r0_body.zjc79 : Conv.jcleanListB (⟨19762, 16866, 2736967, 3458⟩ : Conv.Cnt) PRE_first_tail_x15_r0_body.s707 PRE_first_tail_x15_r0_body.cl79 = true
kernel_rfl PRE_first_tail_x15_r0_body.zroots279 : noBigRootsP (fun i => !Conv.oldBigB (⟨19762, 16866, 2736967, 3458⟩ : Conv.Cnt) i) PRE_first_tail_x15_r0_body.s707.trace PRE_first_tail_x15_r0_body.s707 = true
kernel_rfl PRE_first_tail_x15_r0_body.zhm79 : Nat.ble (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s0.ffi).mlx.nnext 16866 = true
theorem PRE_first_tail_x15_r0_body.cjcl79 (h : Conv.JClean (⟨19762, 16866, 2736967, 3458⟩ : Conv.Cnt) PRE_first_tail_x15_r0_body.s705) : Conv.JClean (⟨19762, 16866, 2736967, 3458⟩ : Conv.Cnt) PRE_first_tail_x15_r0_body.s707 :=
  Conv.JClean.step h (Conv.Cnt.le_of_leB PRE_first_tail_x15_r0_body.cle79)
    (Conv.heap_off_setAll PRE_first_tail_x15_r0_body.cheap79 fun a ha => Nat.blt_eq.mp (List.all_eq_true.mp PRE_first_tail_x15_r0_body.zclbd79 a ha)) PRE_first_tail_x15_r0_body.zjc79

end Host.Load.Run.Tpl
