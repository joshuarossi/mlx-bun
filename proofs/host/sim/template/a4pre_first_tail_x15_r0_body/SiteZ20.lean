import host.sim.template.a4pre_first_tail_x15_r0_body.SiteS20
import host.sim.template.a4pre_first_tail_x15_r0_body.SiteK20
import host.sim.template.a4pre_first_tail_x15_r0_body.SiteF20
import host.sim.conv.CompactShift
import host.sim.template.Check
import host.sim.BigFreeP
import host.sim.template.CallGen
set_option Elab.async false
namespace Host.Load.Run.Tpl
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
open Host.Ts Host.Ts.Sim Host.Ts.Sim.Template

/-! The compaction's state shift at call site 20 of chain `PRE_first_tail_x15_r0_body` (`Conv.compact_shift`): the call `PRE_first_tail_x15_r0_body.s201`, the merged
state `PRE_first_tail_x15_r0_body.s202`, the canonical state `PRE_first_tail_x15_r0_body.s203`; its frames [2665,2673467,2673472,2673473] (kept arrays [2665,2673467]). -/

-- the map's places and counters
kernel_rfl PRE_first_tail_x15_r0_body.zpl20 : PRE_first_tail_x15_r0_body.pl20.all (Nat.ble PRE_first_tail_x15_r0_body.s201.next) = true
kernel_rfl PRE_first_tail_x15_r0_body.zplnd20 : nodupT PRE_first_tail_x15_r0_body.pl20 PTrie.nil = true
kernel_rfl PRE_first_tail_x15_r0_body.zn120 : Nat.ble PRE_first_tail_x15_r0_body.s201.next 2690182 = true
kernel_rfl PRE_first_tail_x15_r0_body.zfirst20 : Nat.ble aFirst PRE_first_tail_x15_r0_body.s201.next = true
kernel_rfl PRE_first_tail_x15_r0_body.zscn20 : PRE_first_tail_x15_r0_body.s203.next = PRE_first_tail_x15_r0_body.s201.next + PRE_first_tail_x15_r0_body.pl20.length
kernel_rfl PRE_first_tail_x15_r0_body.zsmn20 : PRE_first_tail_x15_r0_body.s202.next = 2690182
kernel_rfl PRE_first_tail_x15_r0_body.zgrow20 : Nat.ble PRE_first_tail_x15_r0_body.s203.next PRE_first_tail_x15_r0_body.s202.next = true
-- the tables
kernel_rfl PRE_first_tail_x15_r0_body.zfresh20 : PRE_first_tail_x15_r0_body.S201.tab.all (fun e => PRE_first_tail_x15_r0_body.cws20.all fun v => e.noVar v) = true
kernel_rfl PRE_first_tail_x15_r0_body.zcnd20 : nodupT PRE_first_tail_x15_r0_body.cws20 PTrie.nil = true
kernel_rfl PRE_first_tail_x15_r0_body.znrHi20 : PRE_first_tail_x15_r0_body.nr20.all (fun r => Nat.blt r PRE_first_tail_x15_r0_body.S202.tab.length) = true
-- the frames: every framed address below the call's counter; the kept arrays the chain start's, extended in the merged state
kernel_rfl PRE_first_tail_x15_r0_body.zfrlt20 : [2665, 2673467, 2673472, 2673473].all (fun a => Nat.blt a PRE_first_tail_x15_r0_body.s201.next) = true
kernel_rfl PRE_first_tail_x15_r0_body.zg20_2665 : PRE_first_tail_x15_r0_body.s203.heap.get 2665 = some (.obj (objOf PRE_first_tail_x15_r0_body.s203 2665))
kernel_rfl PRE_first_tail_x15_r0_body.zk20_2665 : (objOf PRE_first_tail_x15_r0_body.s203 2665).kind = .array (arrOf PRE_first_tail_x15_r0_body.s0 2665)
kernel_rfl PRE_first_tail_x15_r0_body.zm20_2665 : PRE_first_tail_x15_r0_body.s202.heap.get 2665 = some (.obj { PRE_first_tail_x15_r0_body.kappa20.obj (objOf PRE_first_tail_x15_r0_body.s203 2665) with
  kind := .array (arrOf PRE_first_tail_x15_r0_body.s0 2665 ++ (arrOf PRE_first_tail_x15_r0_body.s202 2665).drop (arrOf PRE_first_tail_x15_r0_body.s0 2665).length) })
kernel_rfl PRE_first_tail_x15_r0_body.zg20_2673467 : PRE_first_tail_x15_r0_body.s203.heap.get 2673467 = some (.obj (objOf PRE_first_tail_x15_r0_body.s203 2673467))
kernel_rfl PRE_first_tail_x15_r0_body.zk20_2673467 : (objOf PRE_first_tail_x15_r0_body.s203 2673467).kind = .array (arrOf PRE_first_tail_x15_r0_body.s0 2673467)
kernel_rfl PRE_first_tail_x15_r0_body.zm20_2673467 : PRE_first_tail_x15_r0_body.s202.heap.get 2673467 = some (.obj { PRE_first_tail_x15_r0_body.kappa20.obj (objOf PRE_first_tail_x15_r0_body.s203 2673467) with
  kind := .array (arrOf PRE_first_tail_x15_r0_body.s0 2673467 ++ (arrOf PRE_first_tail_x15_r0_body.s202 2673467).drop (arrOf PRE_first_tail_x15_r0_body.s0 2673467).length) })
kernel_rfl PRE_first_tail_x15_r0_body.zw20_4910 : (PRE_first_tail_x15_r0_body.s203.heap.get 4910).isSome = true
kernel_rfl PRE_first_tail_x15_r0_body.zw20_2673472 : (PRE_first_tail_x15_r0_body.s203.heap.get 2673472).isSome = true
kernel_rfl PRE_first_tail_x15_r0_body.zw20_2673473 : (PRE_first_tail_x15_r0_body.s203.heap.get 2673473).isSome = true
-- the heap: the changed list in range, holding the stage's written and fresh addresses; the canonical side's image
kernel_rfl PRE_first_tail_x15_r0_body.zclbd20 : PRE_first_tail_x15_r0_body.cl20.all (fun b => Nat.blt (b / 4096) (4 ^ 31)) = true
kernel_rfl PRE_first_tail_x15_r0_body.zwr20 : PRE_first_tail_x15_r0_body.st20.wr.all (fun b => !Nat.blt b PRE_first_tail_x15_r0_body.s201.next || PRE_first_tail_x15_r0_body.cl20.contains b) = true
def PRE_first_tail_x15_r0_body.zl20 : List Nat := PRE_first_tail_x15_r0_body.cl20.filter fun a => !(List.contains [2665, 2673467] a)
kernel_rfl PRE_first_tail_x15_r0_body.zimgE20 : PRE_first_tail_x15_r0_body.zl20.map (fun a => PRE_first_tail_x15_r0_body.s202.heap.get (PRE_first_tail_x15_r0_body.kappa20.a a)) = PRE_first_tail_x15_r0_body.zl20.map (fun a => (PRE_first_tail_x15_r0_body.s203.heap.get a).map PRE_first_tail_x15_r0_body.kappa20.hobj)
theorem PRE_first_tail_x15_r0_body.zimg20 : HeapImg PRE_first_tail_x15_r0_body.kappa20 PRE_first_tail_x15_r0_body.s203 PRE_first_tail_x15_r0_body.s202 PRE_first_tail_x15_r0_body.zl20 := PRE_first_tail_x15_r0_body.zimgE20
-- the roots and their supports
kernel_rfl PRE_first_tail_x15_r0_body.zctl20 : PRE_first_tail_x15_r0_body.s202.ctl = PRE_first_tail_x15_r0_body.kappa20.ctl PRE_first_tail_x15_r0_body.s203.ctl
kernel_rfl PRE_first_tail_x15_r0_body.zstack20 : PRE_first_tail_x15_r0_body.s202.stack = PRE_first_tail_x15_r0_body.s203.stack.map PRE_first_tail_x15_r0_body.kappa20.frame
kernel_rfl PRE_first_tail_x15_r0_body.zjobs20 : PRE_first_tail_x15_r0_body.s202.jobs = PRE_first_tail_x15_r0_body.s203.jobs.map PRE_first_tail_x15_r0_body.kappa20.job
kernel_rfl PRE_first_tail_x15_r0_body.zstores20 : PRE_first_tail_x15_r0_body.s202.stores = PRE_first_tail_x15_r0_body.kappa20.stores PRE_first_tail_x15_r0_body.s203.stores
kernel_rfl PRE_first_tail_x15_r0_body.zroots20 : checkRootsSupp PRE_first_tail_x15_r0_body.s203 910 = true
kernel_rfl PRE_first_tail_x15_r0_body.znC20 : PRE_first_tail_x15_r0_body.S201.tab.length + PRE_first_tail_x15_r0_body.cws20.length = 910
-- the map as `Conv.compact_shift` states it (the call's counters for the literals)
kernel_rfl PRE_first_tail_x15_r0_body.zkap20 : PRE_first_tail_x15_r0_body.kappa20 = Conv.Map.compact PRE_first_tail_x15_r0_body.s201.next 2690182 PRE_first_tail_x15_r0_body.S201.tab.length PRE_first_tail_x15_r0_body.pl20 (PRE_first_tail_x15_r0_body.nr20.map NumV.ref) PRE_first_tail_x15_r0_body.kd20.big
  PRE_first_tail_x15_r0_body.kd20.region PRE_first_tail_x15_r0_body.kd20.nodeF
-- the bridge inactive at the canonical state (`Conv.FullShiftQ.toX`; the merged state's bridge is the canonical's: cbridge)
theorem PRE_first_tail_x15_r0_body.zbin20 : (Host.Ts.Sim.Full.bridgeOf PRE_first_tail_x15_r0_body.s203.ffi).active = false := (Host.Load.Boot.replay_active Host.Load.Run.Prompt.P.oblog2818)
-- the JS bookkeeping's step (`Conv.JClean.step` over the changed list) and the canonical roots' bigint freedom
kernel_rfl PRE_first_tail_x15_r0_body.zjc20 : Conv.jcleanListB (⟨18589, 15685, 2690172, 910⟩ : Conv.Cnt) PRE_first_tail_x15_r0_body.s203 PRE_first_tail_x15_r0_body.cl20 = true
kernel_rfl PRE_first_tail_x15_r0_body.zrootsB20 : noBigRootsP (fun i => !Conv.oldBigB (⟨18589, 15685, 2690172, 910⟩ : Conv.Cnt) i) PRE_first_tail_x15_r0_body.s203.trace PRE_first_tail_x15_r0_body.s203 = true
kernel_rfl PRE_first_tail_x15_r0_body.zhm20 : Nat.ble (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s0.ffi).mlx.nnext 15685 = true
theorem PRE_first_tail_x15_r0_body.cjcl20 (h : Conv.JClean (⟨18589, 15685, 2690171, 910⟩ : Conv.Cnt) PRE_first_tail_x15_r0_body.s201) : Conv.JClean (⟨18589, 15685, 2690172, 910⟩ : Conv.Cnt) PRE_first_tail_x15_r0_body.s203 :=
  Conv.JClean.step h (Conv.Cnt.le_of_leB PRE_first_tail_x15_r0_body.cle20)
    (Conv.heap_off_setAll PRE_first_tail_x15_r0_body.cheap20 fun a ha => Nat.blt_eq.mp (List.all_eq_true.mp PRE_first_tail_x15_r0_body.zclbd20 a ha)) PRE_first_tail_x15_r0_body.zjc20

end Host.Load.Run.Tpl
