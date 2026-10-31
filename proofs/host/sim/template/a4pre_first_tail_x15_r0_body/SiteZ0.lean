import host.sim.template.a4pre_first_tail_x15_r0_body.SiteS0
import host.sim.template.a4pre_first_tail_x15_r0_body.SiteK0
import host.sim.template.a4pre_first_tail_x15_r0_body.SiteF0
import host.sim.conv.CompactShift
import host.sim.template.Check
import host.sim.BigFreeP
import host.sim.template.CallGen
set_option Elab.async false
namespace Host.Load.Run.Tpl
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
open Host.Ts Host.Ts.Sim Host.Ts.Sim.Template

/-! The compaction's state shift at call site 0 of chain `PRE_first_tail_x15_r0_body` (`Conv.compact_shift`): the call `PRE_first_tail_x15_r0_body.s15`, the merged
state `PRE_first_tail_x15_r0_body.s16`, the canonical state `PRE_first_tail_x15_r0_body.s17`; its frames [2665,2673467,2673472,2673473] (kept arrays [2665,2673467]). -/

-- the map's places and counters
kernel_rfl PRE_first_tail_x15_r0_body.zpl0 : PRE_first_tail_x15_r0_body.pl0.all (Nat.ble PRE_first_tail_x15_r0_body.s15.next) = true
kernel_rfl PRE_first_tail_x15_r0_body.zplnd0 : nodupT PRE_first_tail_x15_r0_body.pl0 PTrie.nil = true
kernel_rfl PRE_first_tail_x15_r0_body.zn10 : Nat.ble PRE_first_tail_x15_r0_body.s15.next 2676612 = true
kernel_rfl PRE_first_tail_x15_r0_body.zfirst0 : Nat.ble aFirst PRE_first_tail_x15_r0_body.s15.next = true
kernel_rfl PRE_first_tail_x15_r0_body.zscn0 : PRE_first_tail_x15_r0_body.s17.next = PRE_first_tail_x15_r0_body.s15.next + PRE_first_tail_x15_r0_body.pl0.length
kernel_rfl PRE_first_tail_x15_r0_body.zsmn0 : PRE_first_tail_x15_r0_body.s16.next = 2676612
kernel_rfl PRE_first_tail_x15_r0_body.zgrow0 : Nat.ble PRE_first_tail_x15_r0_body.s17.next PRE_first_tail_x15_r0_body.s16.next = true
-- the tables
kernel_rfl PRE_first_tail_x15_r0_body.zfresh0 : PRE_first_tail_x15_r0_body.S15.tab.all (fun e => PRE_first_tail_x15_r0_body.cws0.all fun v => e.noVar v) = true
kernel_rfl PRE_first_tail_x15_r0_body.zcnd0 : nodupT PRE_first_tail_x15_r0_body.cws0 PTrie.nil = true
kernel_rfl PRE_first_tail_x15_r0_body.znrHi0 : PRE_first_tail_x15_r0_body.nr0.all (fun r => Nat.blt r PRE_first_tail_x15_r0_body.S16.tab.length) = true
-- the frames: every framed address below the call's counter; the kept arrays the chain start's, extended in the merged state
kernel_rfl PRE_first_tail_x15_r0_body.zfrlt0 : [2665, 2673467, 2673472, 2673473].all (fun a => Nat.blt a PRE_first_tail_x15_r0_body.s15.next) = true
kernel_rfl PRE_first_tail_x15_r0_body.zg0_2665 : PRE_first_tail_x15_r0_body.s17.heap.get 2665 = some (.obj (objOf PRE_first_tail_x15_r0_body.s17 2665))
kernel_rfl PRE_first_tail_x15_r0_body.zk0_2665 : (objOf PRE_first_tail_x15_r0_body.s17 2665).kind = .array (arrOf PRE_first_tail_x15_r0_body.s0 2665)
kernel_rfl PRE_first_tail_x15_r0_body.zm0_2665 : PRE_first_tail_x15_r0_body.s16.heap.get 2665 = some (.obj { PRE_first_tail_x15_r0_body.kappa0.obj (objOf PRE_first_tail_x15_r0_body.s17 2665) with
  kind := .array (arrOf PRE_first_tail_x15_r0_body.s0 2665 ++ (arrOf PRE_first_tail_x15_r0_body.s16 2665).drop (arrOf PRE_first_tail_x15_r0_body.s0 2665).length) })
kernel_rfl PRE_first_tail_x15_r0_body.zg0_2673467 : PRE_first_tail_x15_r0_body.s17.heap.get 2673467 = some (.obj (objOf PRE_first_tail_x15_r0_body.s17 2673467))
kernel_rfl PRE_first_tail_x15_r0_body.zk0_2673467 : (objOf PRE_first_tail_x15_r0_body.s17 2673467).kind = .array (arrOf PRE_first_tail_x15_r0_body.s0 2673467)
kernel_rfl PRE_first_tail_x15_r0_body.zm0_2673467 : PRE_first_tail_x15_r0_body.s16.heap.get 2673467 = some (.obj { PRE_first_tail_x15_r0_body.kappa0.obj (objOf PRE_first_tail_x15_r0_body.s17 2673467) with
  kind := .array (arrOf PRE_first_tail_x15_r0_body.s0 2673467 ++ (arrOf PRE_first_tail_x15_r0_body.s16 2673467).drop (arrOf PRE_first_tail_x15_r0_body.s0 2673467).length) })
kernel_rfl PRE_first_tail_x15_r0_body.zw0_4910 : (PRE_first_tail_x15_r0_body.s17.heap.get 4910).isSome = true
kernel_rfl PRE_first_tail_x15_r0_body.zw0_2673472 : (PRE_first_tail_x15_r0_body.s17.heap.get 2673472).isSome = true
kernel_rfl PRE_first_tail_x15_r0_body.zw0_2673473 : (PRE_first_tail_x15_r0_body.s17.heap.get 2673473).isSome = true
-- the heap: the changed list in range, holding the stage's written and fresh addresses; the canonical side's image
kernel_rfl PRE_first_tail_x15_r0_body.zclbd0 : PRE_first_tail_x15_r0_body.cl0.all (fun b => Nat.blt (b / 4096) (4 ^ 31)) = true
kernel_rfl PRE_first_tail_x15_r0_body.zwr0 : PRE_first_tail_x15_r0_body.st0.wr.all (fun b => !Nat.blt b PRE_first_tail_x15_r0_body.s15.next || PRE_first_tail_x15_r0_body.cl0.contains b) = true
def PRE_first_tail_x15_r0_body.zl0 : List Nat := PRE_first_tail_x15_r0_body.cl0.filter fun a => !(List.contains [2665, 2673467] a)
kernel_rfl PRE_first_tail_x15_r0_body.zimgE0 : PRE_first_tail_x15_r0_body.zl0.map (fun a => PRE_first_tail_x15_r0_body.s16.heap.get (PRE_first_tail_x15_r0_body.kappa0.a a)) = PRE_first_tail_x15_r0_body.zl0.map (fun a => (PRE_first_tail_x15_r0_body.s17.heap.get a).map PRE_first_tail_x15_r0_body.kappa0.hobj)
theorem PRE_first_tail_x15_r0_body.zimg0 : HeapImg PRE_first_tail_x15_r0_body.kappa0 PRE_first_tail_x15_r0_body.s17 PRE_first_tail_x15_r0_body.s16 PRE_first_tail_x15_r0_body.zl0 := PRE_first_tail_x15_r0_body.zimgE0
-- the roots and their supports
kernel_rfl PRE_first_tail_x15_r0_body.zctl0 : PRE_first_tail_x15_r0_body.s16.ctl = PRE_first_tail_x15_r0_body.kappa0.ctl PRE_first_tail_x15_r0_body.s17.ctl
kernel_rfl PRE_first_tail_x15_r0_body.zstack0 : PRE_first_tail_x15_r0_body.s16.stack = PRE_first_tail_x15_r0_body.s17.stack.map PRE_first_tail_x15_r0_body.kappa0.frame
kernel_rfl PRE_first_tail_x15_r0_body.zjobs0 : PRE_first_tail_x15_r0_body.s16.jobs = PRE_first_tail_x15_r0_body.s17.jobs.map PRE_first_tail_x15_r0_body.kappa0.job
kernel_rfl PRE_first_tail_x15_r0_body.zstores0 : PRE_first_tail_x15_r0_body.s16.stores = PRE_first_tail_x15_r0_body.kappa0.stores PRE_first_tail_x15_r0_body.s17.stores
kernel_rfl PRE_first_tail_x15_r0_body.zroots0 : checkRootsSupp PRE_first_tail_x15_r0_body.s17 101 = true
kernel_rfl PRE_first_tail_x15_r0_body.znC0 : PRE_first_tail_x15_r0_body.S15.tab.length + PRE_first_tail_x15_r0_body.cws0.length = 101
-- the map as `Conv.compact_shift` states it (the call's counters for the literals)
kernel_rfl PRE_first_tail_x15_r0_body.zkap0 : PRE_first_tail_x15_r0_body.kappa0 = Conv.Map.compact PRE_first_tail_x15_r0_body.s15.next 2676612 PRE_first_tail_x15_r0_body.S15.tab.length PRE_first_tail_x15_r0_body.pl0 (PRE_first_tail_x15_r0_body.nr0.map NumV.ref) PRE_first_tail_x15_r0_body.kd0.big
  PRE_first_tail_x15_r0_body.kd0.region PRE_first_tail_x15_r0_body.kd0.nodeF
-- the bridge inactive at the canonical state (`Conv.FullShiftQ.toX`; the merged state's bridge is the canonical's: cbridge)
theorem PRE_first_tail_x15_r0_body.zbin0 : (Host.Ts.Sim.Full.bridgeOf PRE_first_tail_x15_r0_body.s17.ffi).active = false := (Host.Load.Boot.replay_active Host.Load.Run.Prompt.P.oblog2818)
-- the JS bookkeeping's step (`Conv.JClean.step` over the changed list) and the canonical roots' bigint freedom
kernel_rfl PRE_first_tail_x15_r0_body.zjc0 : Conv.jcleanListB (⟨18197, 15296, 2674920, 101⟩ : Conv.Cnt) PRE_first_tail_x15_r0_body.s17 PRE_first_tail_x15_r0_body.cl0 = true
kernel_rfl PRE_first_tail_x15_r0_body.zrootsB0 : noBigRootsP (fun i => !Conv.oldBigB (⟨18197, 15296, 2674920, 101⟩ : Conv.Cnt) i) PRE_first_tail_x15_r0_body.s17.trace PRE_first_tail_x15_r0_body.s17 = true
kernel_rfl PRE_first_tail_x15_r0_body.zhm0 : Nat.ble (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s0.ffi).mlx.nnext 15254 = true
theorem PRE_first_tail_x15_r0_body.cjcl0 (h : Conv.JClean (⟨18189, 15254, 2674897, 83⟩ : Conv.Cnt) PRE_first_tail_x15_r0_body.s15) : Conv.JClean (⟨18197, 15296, 2674920, 101⟩ : Conv.Cnt) PRE_first_tail_x15_r0_body.s17 :=
  Conv.JClean.step h (Conv.Cnt.le_of_leB PRE_first_tail_x15_r0_body.cle0)
    (Conv.heap_off_setAll PRE_first_tail_x15_r0_body.cheap0 fun a ha => Nat.blt_eq.mp (List.all_eq_true.mp PRE_first_tail_x15_r0_body.zclbd0 a ha)) PRE_first_tail_x15_r0_body.zjc0

end Host.Load.Run.Tpl
