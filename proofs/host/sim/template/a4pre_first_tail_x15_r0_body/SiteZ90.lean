import host.sim.template.a4pre_first_tail_x15_r0_body.SiteS90
import host.sim.template.a4pre_first_tail_x15_r0_body.SiteK90
import host.sim.template.a4pre_first_tail_x15_r0_body.SiteF90
import host.sim.conv.CompactShift
import host.sim.template.Check
import host.sim.BigFreeP
import host.sim.template.CallGen
set_option Elab.async false
namespace Host.Load.Run.Tpl
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
open Host.Ts Host.Ts.Sim Host.Ts.Sim.Template

/-! The compaction's state shift at call site 90 of chain `PRE_first_tail_x15_r0_body` (`Conv.compact_shift`): the call `PRE_first_tail_x15_r0_body.s803`, the merged
state `PRE_first_tail_x15_r0_body.s804`, the canonical state `PRE_first_tail_x15_r0_body.s805`; its frames [2665,2673467,2673472,2673473] (kept arrays [2665,2673467]). -/

-- the map's places and counters
kernel_rfl PRE_first_tail_x15_r0_body.zpl90 : PRE_first_tail_x15_r0_body.pl90.all (Nat.ble PRE_first_tail_x15_r0_body.s803.next) = true
kernel_rfl PRE_first_tail_x15_r0_body.zplnd90 : nodupT PRE_first_tail_x15_r0_body.pl90 PTrie.nil = true
kernel_rfl PRE_first_tail_x15_r0_body.zn190 : Nat.ble PRE_first_tail_x15_r0_body.s803.next 2747042 = true
kernel_rfl PRE_first_tail_x15_r0_body.zfirst90 : Nat.ble aFirst PRE_first_tail_x15_r0_body.s803.next = true
kernel_rfl PRE_first_tail_x15_r0_body.zscn90 : PRE_first_tail_x15_r0_body.s805.next = PRE_first_tail_x15_r0_body.s803.next + PRE_first_tail_x15_r0_body.pl90.length
kernel_rfl PRE_first_tail_x15_r0_body.zsmn90 : PRE_first_tail_x15_r0_body.s804.next = 2747042
kernel_rfl PRE_first_tail_x15_r0_body.zgrow90 : Nat.ble PRE_first_tail_x15_r0_body.s805.next PRE_first_tail_x15_r0_body.s804.next = true
-- the tables
kernel_rfl PRE_first_tail_x15_r0_body.zfresh90 : PRE_first_tail_x15_r0_body.S803.tab.all (fun e => PRE_first_tail_x15_r0_body.cws90.all fun v => e.noVar v) = true
kernel_rfl PRE_first_tail_x15_r0_body.zcnd90 : nodupT PRE_first_tail_x15_r0_body.cws90 PTrie.nil = true
kernel_rfl PRE_first_tail_x15_r0_body.znrHi90 : PRE_first_tail_x15_r0_body.nr90.all (fun r => Nat.blt r PRE_first_tail_x15_r0_body.S804.tab.length) = true
-- the frames: every framed address below the call's counter; the kept arrays the chain start's, extended in the merged state
kernel_rfl PRE_first_tail_x15_r0_body.zfrlt90 : [2665, 2673467, 2673472, 2673473].all (fun a => Nat.blt a PRE_first_tail_x15_r0_body.s803.next) = true
kernel_rfl PRE_first_tail_x15_r0_body.zg90_2665 : PRE_first_tail_x15_r0_body.s805.heap.get 2665 = some (.obj (objOf PRE_first_tail_x15_r0_body.s805 2665))
kernel_rfl PRE_first_tail_x15_r0_body.zk90_2665 : (objOf PRE_first_tail_x15_r0_body.s805 2665).kind = .array (arrOf PRE_first_tail_x15_r0_body.s0 2665)
kernel_rfl PRE_first_tail_x15_r0_body.zm90_2665 : PRE_first_tail_x15_r0_body.s804.heap.get 2665 = some (.obj { PRE_first_tail_x15_r0_body.kappa90.obj (objOf PRE_first_tail_x15_r0_body.s805 2665) with
  kind := .array (arrOf PRE_first_tail_x15_r0_body.s0 2665 ++ (arrOf PRE_first_tail_x15_r0_body.s804 2665).drop (arrOf PRE_first_tail_x15_r0_body.s0 2665).length) })
kernel_rfl PRE_first_tail_x15_r0_body.zg90_2673467 : PRE_first_tail_x15_r0_body.s805.heap.get 2673467 = some (.obj (objOf PRE_first_tail_x15_r0_body.s805 2673467))
kernel_rfl PRE_first_tail_x15_r0_body.zk90_2673467 : (objOf PRE_first_tail_x15_r0_body.s805 2673467).kind = .array (arrOf PRE_first_tail_x15_r0_body.s0 2673467)
kernel_rfl PRE_first_tail_x15_r0_body.zm90_2673467 : PRE_first_tail_x15_r0_body.s804.heap.get 2673467 = some (.obj { PRE_first_tail_x15_r0_body.kappa90.obj (objOf PRE_first_tail_x15_r0_body.s805 2673467) with
  kind := .array (arrOf PRE_first_tail_x15_r0_body.s0 2673467 ++ (arrOf PRE_first_tail_x15_r0_body.s804 2673467).drop (arrOf PRE_first_tail_x15_r0_body.s0 2673467).length) })
kernel_rfl PRE_first_tail_x15_r0_body.zw90_4910 : (PRE_first_tail_x15_r0_body.s805.heap.get 4910).isSome = true
kernel_rfl PRE_first_tail_x15_r0_body.zw90_2673472 : (PRE_first_tail_x15_r0_body.s805.heap.get 2673472).isSome = true
kernel_rfl PRE_first_tail_x15_r0_body.zw90_2673473 : (PRE_first_tail_x15_r0_body.s805.heap.get 2673473).isSome = true
-- the heap: the changed list in range, holding the stage's written and fresh addresses; the canonical side's image
kernel_rfl PRE_first_tail_x15_r0_body.zclbd90 : PRE_first_tail_x15_r0_body.cl90.all (fun b => Nat.blt (b / 4096) (4 ^ 31)) = true
kernel_rfl PRE_first_tail_x15_r0_body.zwr90 : PRE_first_tail_x15_r0_body.st90.wr.all (fun b => !Nat.blt b PRE_first_tail_x15_r0_body.s803.next || PRE_first_tail_x15_r0_body.cl90.contains b) = true
def PRE_first_tail_x15_r0_body.zl90 : List Nat := PRE_first_tail_x15_r0_body.cl90.filter fun a => !(List.contains [2665, 2673467] a)
kernel_rfl PRE_first_tail_x15_r0_body.zimgE90 : PRE_first_tail_x15_r0_body.zl90.map (fun a => PRE_first_tail_x15_r0_body.s804.heap.get (PRE_first_tail_x15_r0_body.kappa90.a a)) = PRE_first_tail_x15_r0_body.zl90.map (fun a => (PRE_first_tail_x15_r0_body.s805.heap.get a).map PRE_first_tail_x15_r0_body.kappa90.hobj)
theorem PRE_first_tail_x15_r0_body.zimg90 : HeapImg PRE_first_tail_x15_r0_body.kappa90 PRE_first_tail_x15_r0_body.s805 PRE_first_tail_x15_r0_body.s804 PRE_first_tail_x15_r0_body.zl90 := PRE_first_tail_x15_r0_body.zimgE90
-- the roots and their supports
kernel_rfl PRE_first_tail_x15_r0_body.zctl90 : PRE_first_tail_x15_r0_body.s804.ctl = PRE_first_tail_x15_r0_body.kappa90.ctl PRE_first_tail_x15_r0_body.s805.ctl
kernel_rfl PRE_first_tail_x15_r0_body.zstack90 : PRE_first_tail_x15_r0_body.s804.stack = PRE_first_tail_x15_r0_body.s805.stack.map PRE_first_tail_x15_r0_body.kappa90.frame
kernel_rfl PRE_first_tail_x15_r0_body.zjobs90 : PRE_first_tail_x15_r0_body.s804.jobs = PRE_first_tail_x15_r0_body.s805.jobs.map PRE_first_tail_x15_r0_body.kappa90.job
kernel_rfl PRE_first_tail_x15_r0_body.zstores90 : PRE_first_tail_x15_r0_body.s804.stores = PRE_first_tail_x15_r0_body.kappa90.stores PRE_first_tail_x15_r0_body.s805.stores
kernel_rfl PRE_first_tail_x15_r0_body.zroots90 : checkRootsSupp PRE_first_tail_x15_r0_body.s805 3950 = true
kernel_rfl PRE_first_tail_x15_r0_body.znC90 : PRE_first_tail_x15_r0_body.S803.tab.length + PRE_first_tail_x15_r0_body.cws90.length = 3950
-- the map as `Conv.compact_shift` states it (the call's counters for the literals)
kernel_rfl PRE_first_tail_x15_r0_body.zkap90 : PRE_first_tail_x15_r0_body.kappa90 = Conv.Map.compact PRE_first_tail_x15_r0_body.s803.next 2747042 PRE_first_tail_x15_r0_body.S803.tab.length PRE_first_tail_x15_r0_body.pl90 (PRE_first_tail_x15_r0_body.nr90.map NumV.ref) PRE_first_tail_x15_r0_body.kd90.big
  PRE_first_tail_x15_r0_body.kd90.region PRE_first_tail_x15_r0_body.kd90.nodeF
-- the bridge inactive at the canonical state (`Conv.FullShiftQ.toX`; the merged state's bridge is the canonical's: cbridge)
theorem PRE_first_tail_x15_r0_body.zbin90 : (Host.Ts.Sim.Full.bridgeOf PRE_first_tail_x15_r0_body.s805.ffi).active = false := (Host.Load.Boot.replay_active Host.Load.Run.Prompt.P.oblog2818)
-- the JS bookkeeping's step (`Conv.JClean.step` over the changed list) and the canonical roots' bigint freedom
kernel_rfl PRE_first_tail_x15_r0_body.zjc90 : Conv.jcleanListB (⟨19985, 17090, 2745893, 3950⟩ : Conv.Cnt) PRE_first_tail_x15_r0_body.s805 PRE_first_tail_x15_r0_body.cl90 = true
kernel_rfl PRE_first_tail_x15_r0_body.zroots290 : noBigRootsP (fun i => !Conv.oldBigB (⟨19985, 17090, 2745893, 3950⟩ : Conv.Cnt) i) PRE_first_tail_x15_r0_body.s805.trace PRE_first_tail_x15_r0_body.s805 = true
kernel_rfl PRE_first_tail_x15_r0_body.zhm90 : Nat.ble (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s0.ffi).mlx.nnext 17063 = true
theorem PRE_first_tail_x15_r0_body.cjcl90 (h : Conv.JClean (⟨19982, 17063, 2745887, 3932⟩ : Conv.Cnt) PRE_first_tail_x15_r0_body.s803) : Conv.JClean (⟨19985, 17090, 2745893, 3950⟩ : Conv.Cnt) PRE_first_tail_x15_r0_body.s805 :=
  Conv.JClean.step h (Conv.Cnt.le_of_leB PRE_first_tail_x15_r0_body.cle90)
    (Conv.heap_off_setAll PRE_first_tail_x15_r0_body.cheap90 fun a ha => Nat.blt_eq.mp (List.all_eq_true.mp PRE_first_tail_x15_r0_body.zclbd90 a ha)) PRE_first_tail_x15_r0_body.zjc90

end Host.Load.Run.Tpl
