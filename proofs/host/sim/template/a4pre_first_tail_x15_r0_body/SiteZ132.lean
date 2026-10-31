import host.sim.template.a4pre_first_tail_x15_r0_body.SiteS132
import host.sim.template.a4pre_first_tail_x15_r0_body.SiteK132
import host.sim.template.a4pre_first_tail_x15_r0_body.SiteF132
import host.sim.conv.CompactShift
import host.sim.template.Check
import host.sim.BigFreeP
import host.sim.template.CallGen
set_option Elab.async false
namespace Host.Load.Run.Tpl
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
open Host.Ts Host.Ts.Sim Host.Ts.Sim.Template

/-! The compaction's state shift at call site 132 of chain `PRE_first_tail_x15_r0_body` (`Conv.compact_shift`): the call `PRE_first_tail_x15_r0_body.s1169`, the merged
state `PRE_first_tail_x15_r0_body.s1170`, the canonical state `PRE_first_tail_x15_r0_body.s1171`; its frames [2665,2673467,2673472,2673473] (kept arrays [2665,2673467]). -/

-- the map's places and counters
kernel_rfl PRE_first_tail_x15_r0_body.zpl132 : PRE_first_tail_x15_r0_body.pl132.all (Nat.ble PRE_first_tail_x15_r0_body.s1169.next) = true
kernel_rfl PRE_first_tail_x15_r0_body.zplnd132 : nodupT PRE_first_tail_x15_r0_body.pl132 PTrie.nil = true
kernel_rfl PRE_first_tail_x15_r0_body.zn1132 : Nat.ble PRE_first_tail_x15_r0_body.s1169.next 2780190 = true
kernel_rfl PRE_first_tail_x15_r0_body.zfirst132 : Nat.ble aFirst PRE_first_tail_x15_r0_body.s1169.next = true
kernel_rfl PRE_first_tail_x15_r0_body.zscn132 : PRE_first_tail_x15_r0_body.s1171.next = PRE_first_tail_x15_r0_body.s1169.next + PRE_first_tail_x15_r0_body.pl132.length
kernel_rfl PRE_first_tail_x15_r0_body.zsmn132 : PRE_first_tail_x15_r0_body.s1170.next = 2780190
kernel_rfl PRE_first_tail_x15_r0_body.zgrow132 : Nat.ble PRE_first_tail_x15_r0_body.s1171.next PRE_first_tail_x15_r0_body.s1170.next = true
-- the tables
kernel_rfl PRE_first_tail_x15_r0_body.zfresh132 : PRE_first_tail_x15_r0_body.S1169.tab.all (fun e => PRE_first_tail_x15_r0_body.cws132.all fun v => e.noVar v) = true
kernel_rfl PRE_first_tail_x15_r0_body.zcnd132 : nodupT PRE_first_tail_x15_r0_body.cws132 PTrie.nil = true
kernel_rfl PRE_first_tail_x15_r0_body.znrHi132 : PRE_first_tail_x15_r0_body.nr132.all (fun r => Nat.blt r PRE_first_tail_x15_r0_body.S1170.tab.length) = true
-- the frames: every framed address below the call's counter; the kept arrays the chain start's, extended in the merged state
kernel_rfl PRE_first_tail_x15_r0_body.zfrlt132 : [2665, 2673467, 2673472, 2673473].all (fun a => Nat.blt a PRE_first_tail_x15_r0_body.s1169.next) = true
kernel_rfl PRE_first_tail_x15_r0_body.zg132_2665 : PRE_first_tail_x15_r0_body.s1171.heap.get 2665 = some (.obj (objOf PRE_first_tail_x15_r0_body.s1171 2665))
kernel_rfl PRE_first_tail_x15_r0_body.zk132_2665 : (objOf PRE_first_tail_x15_r0_body.s1171 2665).kind = .array (arrOf PRE_first_tail_x15_r0_body.s0 2665)
kernel_rfl PRE_first_tail_x15_r0_body.zm132_2665 : PRE_first_tail_x15_r0_body.s1170.heap.get 2665 = some (.obj { PRE_first_tail_x15_r0_body.kappa132.obj (objOf PRE_first_tail_x15_r0_body.s1171 2665) with
  kind := .array (arrOf PRE_first_tail_x15_r0_body.s0 2665 ++ (arrOf PRE_first_tail_x15_r0_body.s1170 2665).drop (arrOf PRE_first_tail_x15_r0_body.s0 2665).length) })
kernel_rfl PRE_first_tail_x15_r0_body.zg132_2673467 : PRE_first_tail_x15_r0_body.s1171.heap.get 2673467 = some (.obj (objOf PRE_first_tail_x15_r0_body.s1171 2673467))
kernel_rfl PRE_first_tail_x15_r0_body.zk132_2673467 : (objOf PRE_first_tail_x15_r0_body.s1171 2673467).kind = .array (arrOf PRE_first_tail_x15_r0_body.s0 2673467)
kernel_rfl PRE_first_tail_x15_r0_body.zm132_2673467 : PRE_first_tail_x15_r0_body.s1170.heap.get 2673467 = some (.obj { PRE_first_tail_x15_r0_body.kappa132.obj (objOf PRE_first_tail_x15_r0_body.s1171 2673467) with
  kind := .array (arrOf PRE_first_tail_x15_r0_body.s0 2673467 ++ (arrOf PRE_first_tail_x15_r0_body.s1170 2673467).drop (arrOf PRE_first_tail_x15_r0_body.s0 2673467).length) })
kernel_rfl PRE_first_tail_x15_r0_body.zw132_4910 : (PRE_first_tail_x15_r0_body.s1171.heap.get 4910).isSome = true
kernel_rfl PRE_first_tail_x15_r0_body.zw132_2673472 : (PRE_first_tail_x15_r0_body.s1171.heap.get 2673472).isSome = true
kernel_rfl PRE_first_tail_x15_r0_body.zw132_2673473 : (PRE_first_tail_x15_r0_body.s1171.heap.get 2673473).isSome = true
-- the heap: the changed list in range, holding the stage's written and fresh addresses; the canonical side's image
kernel_rfl PRE_first_tail_x15_r0_body.zclbd132 : PRE_first_tail_x15_r0_body.cl132.all (fun b => Nat.blt (b / 4096) (4 ^ 31)) = true
kernel_rfl PRE_first_tail_x15_r0_body.zwr132 : PRE_first_tail_x15_r0_body.st132.wr.all (fun b => !Nat.blt b PRE_first_tail_x15_r0_body.s1169.next || PRE_first_tail_x15_r0_body.cl132.contains b) = true
def PRE_first_tail_x15_r0_body.zl132 : List Nat := PRE_first_tail_x15_r0_body.cl132.filter fun a => !(List.contains [2665, 2673467] a)
kernel_rfl PRE_first_tail_x15_r0_body.zimgE132 : PRE_first_tail_x15_r0_body.zl132.map (fun a => PRE_first_tail_x15_r0_body.s1170.heap.get (PRE_first_tail_x15_r0_body.kappa132.a a)) = PRE_first_tail_x15_r0_body.zl132.map (fun a => (PRE_first_tail_x15_r0_body.s1171.heap.get a).map PRE_first_tail_x15_r0_body.kappa132.hobj)
theorem PRE_first_tail_x15_r0_body.zimg132 : HeapImg PRE_first_tail_x15_r0_body.kappa132 PRE_first_tail_x15_r0_body.s1171 PRE_first_tail_x15_r0_body.s1170 PRE_first_tail_x15_r0_body.zl132 := PRE_first_tail_x15_r0_body.zimgE132
-- the roots and their supports
kernel_rfl PRE_first_tail_x15_r0_body.zctl132 : PRE_first_tail_x15_r0_body.s1170.ctl = PRE_first_tail_x15_r0_body.kappa132.ctl PRE_first_tail_x15_r0_body.s1171.ctl
kernel_rfl PRE_first_tail_x15_r0_body.zstack132 : PRE_first_tail_x15_r0_body.s1170.stack = PRE_first_tail_x15_r0_body.s1171.stack.map PRE_first_tail_x15_r0_body.kappa132.frame
kernel_rfl PRE_first_tail_x15_r0_body.zjobs132 : PRE_first_tail_x15_r0_body.s1170.jobs = PRE_first_tail_x15_r0_body.s1171.jobs.map PRE_first_tail_x15_r0_body.kappa132.job
kernel_rfl PRE_first_tail_x15_r0_body.zstores132 : PRE_first_tail_x15_r0_body.s1170.stores = PRE_first_tail_x15_r0_body.kappa132.stores PRE_first_tail_x15_r0_body.s1171.stores
kernel_rfl PRE_first_tail_x15_r0_body.zroots132 : checkRootsSupp PRE_first_tail_x15_r0_body.s1171 5744 = true
kernel_rfl PRE_first_tail_x15_r0_body.znC132 : PRE_first_tail_x15_r0_body.S1169.tab.length + PRE_first_tail_x15_r0_body.cws132.length = 5744
-- the map as `Conv.compact_shift` states it (the call's counters for the literals)
kernel_rfl PRE_first_tail_x15_r0_body.zkap132 : PRE_first_tail_x15_r0_body.kappa132 = Conv.Map.compact PRE_first_tail_x15_r0_body.s1169.next 2780190 PRE_first_tail_x15_r0_body.S1169.tab.length PRE_first_tail_x15_r0_body.pl132 (PRE_first_tail_x15_r0_body.nr132.map NumV.ref) PRE_first_tail_x15_r0_body.kd132.big
  PRE_first_tail_x15_r0_body.kd132.region PRE_first_tail_x15_r0_body.kd132.nodeF
-- the bridge inactive at the canonical state (`Conv.FullShiftQ.toX`; the merged state's bridge is the canonical's: cbridge)
theorem PRE_first_tail_x15_r0_body.zbin132 : (Host.Ts.Sim.Full.bridgeOf PRE_first_tail_x15_r0_body.s1171.ffi).active = false := (Host.Load.Boot.replay_active Host.Load.Run.Prompt.P.oblog2818)
-- the JS bookkeeping's step (`Conv.JClean.step` over the changed list) and the canonical roots' bigint freedom
kernel_rfl PRE_first_tail_x15_r0_body.zjc132 : Conv.jcleanListB (⟨20815, 17912, 2779041, 5744⟩ : Conv.Cnt) PRE_first_tail_x15_r0_body.s1171 PRE_first_tail_x15_r0_body.cl132 = true
kernel_rfl PRE_first_tail_x15_r0_body.zroots2132 : noBigRootsP (fun i => !Conv.oldBigB (⟨20815, 17912, 2779041, 5744⟩ : Conv.Cnt) i) PRE_first_tail_x15_r0_body.s1171.trace PRE_first_tail_x15_r0_body.s1171 = true
kernel_rfl PRE_first_tail_x15_r0_body.zhm132 : Nat.ble (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s0.ffi).mlx.nnext 17885 = true
theorem PRE_first_tail_x15_r0_body.cjcl132 (h : Conv.JClean (⟨20812, 17885, 2779035, 5726⟩ : Conv.Cnt) PRE_first_tail_x15_r0_body.s1169) : Conv.JClean (⟨20815, 17912, 2779041, 5744⟩ : Conv.Cnt) PRE_first_tail_x15_r0_body.s1171 :=
  Conv.JClean.step h (Conv.Cnt.le_of_leB PRE_first_tail_x15_r0_body.cle132)
    (Conv.heap_off_setAll PRE_first_tail_x15_r0_body.cheap132 fun a ha => Nat.blt_eq.mp (List.all_eq_true.mp PRE_first_tail_x15_r0_body.zclbd132 a ha)) PRE_first_tail_x15_r0_body.zjc132

end Host.Load.Run.Tpl
