import host.sim.template.a4pre_first_tail_x15_r0_body.SiteS17
import host.sim.template.a4pre_first_tail_x15_r0_body.SiteK17
import host.sim.template.a4pre_first_tail_x15_r0_body.SiteF17
import host.sim.conv.CompactShift
import host.sim.template.Check
import host.sim.BigFreeP
import host.sim.template.CallGen
set_option Elab.async false
namespace Host.Load.Run.Tpl
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
open Host.Ts Host.Ts.Sim Host.Ts.Sim.Template

/-! The compaction's state shift at call site 17 of chain `PRE_first_tail_x15_r0_body` (`Conv.compact_shift`): the call `PRE_first_tail_x15_r0_body.s157`, the merged
state `PRE_first_tail_x15_r0_body.s158`, the canonical state `PRE_first_tail_x15_r0_body.s159`; its frames [2665,2673467,2673472,2673473] (kept arrays [2665,2673467]). -/

-- the map's places and counters
kernel_rfl PRE_first_tail_x15_r0_body.zpl17 : PRE_first_tail_x15_r0_body.pl17.all (Nat.ble PRE_first_tail_x15_r0_body.s157.next) = true
kernel_rfl PRE_first_tail_x15_r0_body.zplnd17 : nodupT PRE_first_tail_x15_r0_body.pl17 PTrie.nil = true
kernel_rfl PRE_first_tail_x15_r0_body.zn117 : Nat.ble PRE_first_tail_x15_r0_body.s157.next 2687926 = true
kernel_rfl PRE_first_tail_x15_r0_body.zfirst17 : Nat.ble aFirst PRE_first_tail_x15_r0_body.s157.next = true
kernel_rfl PRE_first_tail_x15_r0_body.zscn17 : PRE_first_tail_x15_r0_body.s159.next = PRE_first_tail_x15_r0_body.s157.next + PRE_first_tail_x15_r0_body.pl17.length
kernel_rfl PRE_first_tail_x15_r0_body.zsmn17 : PRE_first_tail_x15_r0_body.s158.next = 2687926
kernel_rfl PRE_first_tail_x15_r0_body.zgrow17 : Nat.ble PRE_first_tail_x15_r0_body.s159.next PRE_first_tail_x15_r0_body.s158.next = true
-- the tables
kernel_rfl PRE_first_tail_x15_r0_body.zfresh17 : PRE_first_tail_x15_r0_body.S157.tab.all (fun e => PRE_first_tail_x15_r0_body.cws17.all fun v => e.noVar v) = true
kernel_rfl PRE_first_tail_x15_r0_body.zcnd17 : nodupT PRE_first_tail_x15_r0_body.cws17 PTrie.nil = true
kernel_rfl PRE_first_tail_x15_r0_body.znrHi17 : PRE_first_tail_x15_r0_body.nr17.all (fun r => Nat.blt r PRE_first_tail_x15_r0_body.S158.tab.length) = true
-- the frames: every framed address below the call's counter; the kept arrays the chain start's, extended in the merged state
kernel_rfl PRE_first_tail_x15_r0_body.zfrlt17 : [2665, 2673467, 2673472, 2673473].all (fun a => Nat.blt a PRE_first_tail_x15_r0_body.s157.next) = true
kernel_rfl PRE_first_tail_x15_r0_body.zg17_2665 : PRE_first_tail_x15_r0_body.s159.heap.get 2665 = some (.obj (objOf PRE_first_tail_x15_r0_body.s159 2665))
kernel_rfl PRE_first_tail_x15_r0_body.zk17_2665 : (objOf PRE_first_tail_x15_r0_body.s159 2665).kind = .array (arrOf PRE_first_tail_x15_r0_body.s0 2665)
kernel_rfl PRE_first_tail_x15_r0_body.zm17_2665 : PRE_first_tail_x15_r0_body.s158.heap.get 2665 = some (.obj { PRE_first_tail_x15_r0_body.kappa17.obj (objOf PRE_first_tail_x15_r0_body.s159 2665) with
  kind := .array (arrOf PRE_first_tail_x15_r0_body.s0 2665 ++ (arrOf PRE_first_tail_x15_r0_body.s158 2665).drop (arrOf PRE_first_tail_x15_r0_body.s0 2665).length) })
kernel_rfl PRE_first_tail_x15_r0_body.zg17_2673467 : PRE_first_tail_x15_r0_body.s159.heap.get 2673467 = some (.obj (objOf PRE_first_tail_x15_r0_body.s159 2673467))
kernel_rfl PRE_first_tail_x15_r0_body.zk17_2673467 : (objOf PRE_first_tail_x15_r0_body.s159 2673467).kind = .array (arrOf PRE_first_tail_x15_r0_body.s0 2673467)
kernel_rfl PRE_first_tail_x15_r0_body.zm17_2673467 : PRE_first_tail_x15_r0_body.s158.heap.get 2673467 = some (.obj { PRE_first_tail_x15_r0_body.kappa17.obj (objOf PRE_first_tail_x15_r0_body.s159 2673467) with
  kind := .array (arrOf PRE_first_tail_x15_r0_body.s0 2673467 ++ (arrOf PRE_first_tail_x15_r0_body.s158 2673467).drop (arrOf PRE_first_tail_x15_r0_body.s0 2673467).length) })
kernel_rfl PRE_first_tail_x15_r0_body.zw17_4910 : (PRE_first_tail_x15_r0_body.s159.heap.get 4910).isSome = true
kernel_rfl PRE_first_tail_x15_r0_body.zw17_2673472 : (PRE_first_tail_x15_r0_body.s159.heap.get 2673472).isSome = true
kernel_rfl PRE_first_tail_x15_r0_body.zw17_2673473 : (PRE_first_tail_x15_r0_body.s159.heap.get 2673473).isSome = true
-- the heap: the changed list in range, holding the stage's written and fresh addresses; the canonical side's image
kernel_rfl PRE_first_tail_x15_r0_body.zclbd17 : PRE_first_tail_x15_r0_body.cl17.all (fun b => Nat.blt (b / 4096) (4 ^ 31)) = true
kernel_rfl PRE_first_tail_x15_r0_body.zwr17 : PRE_first_tail_x15_r0_body.st17.wr.all (fun b => !Nat.blt b PRE_first_tail_x15_r0_body.s157.next || PRE_first_tail_x15_r0_body.cl17.contains b) = true
def PRE_first_tail_x15_r0_body.zl17 : List Nat := PRE_first_tail_x15_r0_body.cl17.filter fun a => !(List.contains [2665, 2673467] a)
kernel_rfl PRE_first_tail_x15_r0_body.zimgE17 : PRE_first_tail_x15_r0_body.zl17.map (fun a => PRE_first_tail_x15_r0_body.s158.heap.get (PRE_first_tail_x15_r0_body.kappa17.a a)) = PRE_first_tail_x15_r0_body.zl17.map (fun a => (PRE_first_tail_x15_r0_body.s159.heap.get a).map PRE_first_tail_x15_r0_body.kappa17.hobj)
theorem PRE_first_tail_x15_r0_body.zimg17 : HeapImg PRE_first_tail_x15_r0_body.kappa17 PRE_first_tail_x15_r0_body.s159 PRE_first_tail_x15_r0_body.s158 PRE_first_tail_x15_r0_body.zl17 := PRE_first_tail_x15_r0_body.zimgE17
-- the roots and their supports
kernel_rfl PRE_first_tail_x15_r0_body.zctl17 : PRE_first_tail_x15_r0_body.s158.ctl = PRE_first_tail_x15_r0_body.kappa17.ctl PRE_first_tail_x15_r0_body.s159.ctl
kernel_rfl PRE_first_tail_x15_r0_body.zstack17 : PRE_first_tail_x15_r0_body.s158.stack = PRE_first_tail_x15_r0_body.s159.stack.map PRE_first_tail_x15_r0_body.kappa17.frame
kernel_rfl PRE_first_tail_x15_r0_body.zjobs17 : PRE_first_tail_x15_r0_body.s158.jobs = PRE_first_tail_x15_r0_body.s159.jobs.map PRE_first_tail_x15_r0_body.kappa17.job
kernel_rfl PRE_first_tail_x15_r0_body.zstores17 : PRE_first_tail_x15_r0_body.s158.stores = PRE_first_tail_x15_r0_body.kappa17.stores PRE_first_tail_x15_r0_body.s159.stores
kernel_rfl PRE_first_tail_x15_r0_body.zroots17 : checkRootsSupp PRE_first_tail_x15_r0_body.s159 781 = true
kernel_rfl PRE_first_tail_x15_r0_body.znC17 : PRE_first_tail_x15_r0_body.S157.tab.length + PRE_first_tail_x15_r0_body.cws17.length = 781
-- the map as `Conv.compact_shift` states it (the call's counters for the literals)
kernel_rfl PRE_first_tail_x15_r0_body.zkap17 : PRE_first_tail_x15_r0_body.kappa17 = Conv.Map.compact PRE_first_tail_x15_r0_body.s157.next 2687926 PRE_first_tail_x15_r0_body.S157.tab.length PRE_first_tail_x15_r0_body.pl17 (PRE_first_tail_x15_r0_body.nr17.map NumV.ref) PRE_first_tail_x15_r0_body.kd17.big
  PRE_first_tail_x15_r0_body.kd17.region PRE_first_tail_x15_r0_body.kd17.nodeF
-- the bridge inactive at the canonical state (`Conv.FullShiftQ.toX`; the merged state's bridge is the canonical's: cbridge)
theorem PRE_first_tail_x15_r0_body.zbin17 : (Host.Ts.Sim.Full.bridgeOf PRE_first_tail_x15_r0_body.s159.ffi).active = false := (Host.Load.Boot.replay_active Host.Load.Run.Prompt.P.oblog2818)
-- the JS bookkeeping's step (`Conv.JClean.step` over the changed list) and the canonical roots' bigint freedom
kernel_rfl PRE_first_tail_x15_r0_body.zjc17 : Conv.jcleanListB (⟨18532, 15622, 2687916, 781⟩ : Conv.Cnt) PRE_first_tail_x15_r0_body.s159 PRE_first_tail_x15_r0_body.cl17 = true
kernel_rfl PRE_first_tail_x15_r0_body.zroots217 : noBigRootsP (fun i => !Conv.oldBigB (⟨18532, 15622, 2687916, 781⟩ : Conv.Cnt) i) PRE_first_tail_x15_r0_body.s159.trace PRE_first_tail_x15_r0_body.s159 = true
kernel_rfl PRE_first_tail_x15_r0_body.zhm17 : Nat.ble (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s0.ffi).mlx.nnext 15622 = true
theorem PRE_first_tail_x15_r0_body.cjcl17 (h : Conv.JClean (⟨18532, 15622, 2687915, 781⟩ : Conv.Cnt) PRE_first_tail_x15_r0_body.s157) : Conv.JClean (⟨18532, 15622, 2687916, 781⟩ : Conv.Cnt) PRE_first_tail_x15_r0_body.s159 :=
  Conv.JClean.step h (Conv.Cnt.le_of_leB PRE_first_tail_x15_r0_body.cle17)
    (Conv.heap_off_setAll PRE_first_tail_x15_r0_body.cheap17 fun a ha => Nat.blt_eq.mp (List.all_eq_true.mp PRE_first_tail_x15_r0_body.zclbd17 a ha)) PRE_first_tail_x15_r0_body.zjc17

end Host.Load.Run.Tpl
