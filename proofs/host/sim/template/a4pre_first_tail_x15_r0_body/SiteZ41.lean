import host.sim.template.a4pre_first_tail_x15_r0_body.SiteS41
import host.sim.template.a4pre_first_tail_x15_r0_body.SiteK41
import host.sim.template.a4pre_first_tail_x15_r0_body.SiteF41
import host.sim.conv.CompactShift
import host.sim.template.Check
import host.sim.BigFreeP
import host.sim.template.CallGen
set_option Elab.async false
namespace Host.Load.Run.Tpl
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
open Host.Ts Host.Ts.Sim Host.Ts.Sim.Template

/-! The compaction's state shift at call site 41 of chain `PRE_first_tail_x15_r0_body` (`Conv.compact_shift`): the call `PRE_first_tail_x15_r0_body.s402`, the merged
state `PRE_first_tail_x15_r0_body.s403`, the canonical state `PRE_first_tail_x15_r0_body.s404`; its frames [2665,2673467,2673472,2673473] (kept arrays [2665,2673467]). -/

-- the map's places and counters
kernel_rfl PRE_first_tail_x15_r0_body.zpl41 : PRE_first_tail_x15_r0_body.pl41.all (Nat.ble PRE_first_tail_x15_r0_body.s402.next) = true
kernel_rfl PRE_first_tail_x15_r0_body.zplnd41 : nodupT PRE_first_tail_x15_r0_body.pl41 PTrie.nil = true
kernel_rfl PRE_first_tail_x15_r0_body.zn141 : Nat.ble PRE_first_tail_x15_r0_body.s402.next 2706763 = true
kernel_rfl PRE_first_tail_x15_r0_body.zfirst41 : Nat.ble aFirst PRE_first_tail_x15_r0_body.s402.next = true
kernel_rfl PRE_first_tail_x15_r0_body.zscn41 : PRE_first_tail_x15_r0_body.s404.next = PRE_first_tail_x15_r0_body.s402.next + PRE_first_tail_x15_r0_body.pl41.length
kernel_rfl PRE_first_tail_x15_r0_body.zsmn41 : PRE_first_tail_x15_r0_body.s403.next = 2706763
kernel_rfl PRE_first_tail_x15_r0_body.zgrow41 : Nat.ble PRE_first_tail_x15_r0_body.s404.next PRE_first_tail_x15_r0_body.s403.next = true
-- the tables
kernel_rfl PRE_first_tail_x15_r0_body.zfresh41 : PRE_first_tail_x15_r0_body.S402.tab.all (fun e => PRE_first_tail_x15_r0_body.cws41.all fun v => e.noVar v) = true
kernel_rfl PRE_first_tail_x15_r0_body.zcnd41 : nodupT PRE_first_tail_x15_r0_body.cws41 PTrie.nil = true
kernel_rfl PRE_first_tail_x15_r0_body.znrHi41 : PRE_first_tail_x15_r0_body.nr41.all (fun r => Nat.blt r PRE_first_tail_x15_r0_body.S403.tab.length) = true
-- the frames: every framed address below the call's counter; the kept arrays the chain start's, extended in the merged state
kernel_rfl PRE_first_tail_x15_r0_body.zfrlt41 : [2665, 2673467, 2673472, 2673473].all (fun a => Nat.blt a PRE_first_tail_x15_r0_body.s402.next) = true
kernel_rfl PRE_first_tail_x15_r0_body.zg41_2665 : PRE_first_tail_x15_r0_body.s404.heap.get 2665 = some (.obj (objOf PRE_first_tail_x15_r0_body.s404 2665))
kernel_rfl PRE_first_tail_x15_r0_body.zk41_2665 : (objOf PRE_first_tail_x15_r0_body.s404 2665).kind = .array (arrOf PRE_first_tail_x15_r0_body.s0 2665)
kernel_rfl PRE_first_tail_x15_r0_body.zm41_2665 : PRE_first_tail_x15_r0_body.s403.heap.get 2665 = some (.obj { PRE_first_tail_x15_r0_body.kappa41.obj (objOf PRE_first_tail_x15_r0_body.s404 2665) with
  kind := .array (arrOf PRE_first_tail_x15_r0_body.s0 2665 ++ (arrOf PRE_first_tail_x15_r0_body.s403 2665).drop (arrOf PRE_first_tail_x15_r0_body.s0 2665).length) })
kernel_rfl PRE_first_tail_x15_r0_body.zg41_2673467 : PRE_first_tail_x15_r0_body.s404.heap.get 2673467 = some (.obj (objOf PRE_first_tail_x15_r0_body.s404 2673467))
kernel_rfl PRE_first_tail_x15_r0_body.zk41_2673467 : (objOf PRE_first_tail_x15_r0_body.s404 2673467).kind = .array (arrOf PRE_first_tail_x15_r0_body.s0 2673467)
kernel_rfl PRE_first_tail_x15_r0_body.zm41_2673467 : PRE_first_tail_x15_r0_body.s403.heap.get 2673467 = some (.obj { PRE_first_tail_x15_r0_body.kappa41.obj (objOf PRE_first_tail_x15_r0_body.s404 2673467) with
  kind := .array (arrOf PRE_first_tail_x15_r0_body.s0 2673467 ++ (arrOf PRE_first_tail_x15_r0_body.s403 2673467).drop (arrOf PRE_first_tail_x15_r0_body.s0 2673467).length) })
kernel_rfl PRE_first_tail_x15_r0_body.zw41_4910 : (PRE_first_tail_x15_r0_body.s404.heap.get 4910).isSome = true
kernel_rfl PRE_first_tail_x15_r0_body.zw41_2673472 : (PRE_first_tail_x15_r0_body.s404.heap.get 2673472).isSome = true
kernel_rfl PRE_first_tail_x15_r0_body.zw41_2673473 : (PRE_first_tail_x15_r0_body.s404.heap.get 2673473).isSome = true
-- the heap: the changed list in range, holding the stage's written and fresh addresses; the canonical side's image
kernel_rfl PRE_first_tail_x15_r0_body.zclbd41 : PRE_first_tail_x15_r0_body.cl41.all (fun b => Nat.blt (b / 4096) (4 ^ 31)) = true
kernel_rfl PRE_first_tail_x15_r0_body.zwr41 : PRE_first_tail_x15_r0_body.st41.wr.all (fun b => !Nat.blt b PRE_first_tail_x15_r0_body.s402.next || PRE_first_tail_x15_r0_body.cl41.contains b) = true
def PRE_first_tail_x15_r0_body.zl41 : List Nat := PRE_first_tail_x15_r0_body.cl41.filter fun a => !(List.contains [2665, 2673467] a)
kernel_rfl PRE_first_tail_x15_r0_body.zimgE41 : PRE_first_tail_x15_r0_body.zl41.map (fun a => PRE_first_tail_x15_r0_body.s403.heap.get (PRE_first_tail_x15_r0_body.kappa41.a a)) = PRE_first_tail_x15_r0_body.zl41.map (fun a => (PRE_first_tail_x15_r0_body.s404.heap.get a).map PRE_first_tail_x15_r0_body.kappa41.hobj)
theorem PRE_first_tail_x15_r0_body.zimg41 : HeapImg PRE_first_tail_x15_r0_body.kappa41 PRE_first_tail_x15_r0_body.s404 PRE_first_tail_x15_r0_body.s403 PRE_first_tail_x15_r0_body.zl41 := PRE_first_tail_x15_r0_body.zimgE41
-- the roots and their supports
kernel_rfl PRE_first_tail_x15_r0_body.zctl41 : PRE_first_tail_x15_r0_body.s403.ctl = PRE_first_tail_x15_r0_body.kappa41.ctl PRE_first_tail_x15_r0_body.s404.ctl
kernel_rfl PRE_first_tail_x15_r0_body.zstack41 : PRE_first_tail_x15_r0_body.s403.stack = PRE_first_tail_x15_r0_body.s404.stack.map PRE_first_tail_x15_r0_body.kappa41.frame
kernel_rfl PRE_first_tail_x15_r0_body.zjobs41 : PRE_first_tail_x15_r0_body.s403.jobs = PRE_first_tail_x15_r0_body.s404.jobs.map PRE_first_tail_x15_r0_body.kappa41.job
kernel_rfl PRE_first_tail_x15_r0_body.zstores41 : PRE_first_tail_x15_r0_body.s403.stores = PRE_first_tail_x15_r0_body.kappa41.stores PRE_first_tail_x15_r0_body.s404.stores
kernel_rfl PRE_first_tail_x15_r0_body.zroots41 : checkRootsSupp PRE_first_tail_x15_r0_body.s404 1807 = true
kernel_rfl PRE_first_tail_x15_r0_body.znC41 : PRE_first_tail_x15_r0_body.S402.tab.length + PRE_first_tail_x15_r0_body.cws41.length = 1807
-- the map as `Conv.compact_shift` states it (the call's counters for the literals)
kernel_rfl PRE_first_tail_x15_r0_body.zkap41 : PRE_first_tail_x15_r0_body.kappa41 = Conv.Map.compact PRE_first_tail_x15_r0_body.s402.next 2706763 PRE_first_tail_x15_r0_body.S402.tab.length PRE_first_tail_x15_r0_body.pl41 (PRE_first_tail_x15_r0_body.nr41.map NumV.ref) PRE_first_tail_x15_r0_body.kd41.big
  PRE_first_tail_x15_r0_body.kd41.region PRE_first_tail_x15_r0_body.kd41.nodeF
-- the bridge inactive at the canonical state (`Conv.FullShiftQ.toX`; the merged state's bridge is the canonical's: cbridge)
theorem PRE_first_tail_x15_r0_body.zbin41 : (Host.Ts.Sim.Full.bridgeOf PRE_first_tail_x15_r0_body.s404.ffi).active = false := (Host.Load.Boot.replay_active Host.Load.Run.Prompt.P.oblog2818)
-- the JS bookkeeping's step (`Conv.JClean.step` over the changed list) and the canonical roots' bigint freedom
kernel_rfl PRE_first_tail_x15_r0_body.zjc41 : Conv.jcleanListB (⟨19004, 16096, 2706744, 1807⟩ : Conv.Cnt) PRE_first_tail_x15_r0_body.s404 PRE_first_tail_x15_r0_body.cl41 = true
kernel_rfl PRE_first_tail_x15_r0_body.zrootsB41 : noBigRootsP (fun i => !Conv.oldBigB (⟨19004, 16096, 2706744, 1807⟩ : Conv.Cnt) i) PRE_first_tail_x15_r0_body.s404.trace PRE_first_tail_x15_r0_body.s404 = true
kernel_rfl PRE_first_tail_x15_r0_body.zhm41 : Nat.ble (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s0.ffi).mlx.nnext 16096 = true
theorem PRE_first_tail_x15_r0_body.cjcl41 (h : Conv.JClean (⟨19004, 16096, 2706743, 1807⟩ : Conv.Cnt) PRE_first_tail_x15_r0_body.s402) : Conv.JClean (⟨19004, 16096, 2706744, 1807⟩ : Conv.Cnt) PRE_first_tail_x15_r0_body.s404 :=
  Conv.JClean.step h (Conv.Cnt.le_of_leB PRE_first_tail_x15_r0_body.cle41)
    (Conv.heap_off_setAll PRE_first_tail_x15_r0_body.cheap41 fun a ha => Nat.blt_eq.mp (List.all_eq_true.mp PRE_first_tail_x15_r0_body.zclbd41 a ha)) PRE_first_tail_x15_r0_body.zjc41

end Host.Load.Run.Tpl
