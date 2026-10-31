import host.sim.template.a4pre_first_tail_x15_r0_body.SiteS24
import host.sim.template.a4pre_first_tail_x15_r0_body.SiteK24
import host.sim.template.a4pre_first_tail_x15_r0_body.SiteF24
import host.sim.conv.CompactShift
import host.sim.template.Check
import host.sim.BigFreeP
import host.sim.template.CallGen
set_option Elab.async false
namespace Host.Load.Run.Tpl
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
open Host.Ts Host.Ts.Sim Host.Ts.Sim.Template

/-! The compaction's state shift at call site 24 of chain `PRE_first_tail_x15_r0_body` (`Conv.compact_shift`): the call `PRE_first_tail_x15_r0_body.s246`, the merged
state `PRE_first_tail_x15_r0_body.s247`, the canonical state `PRE_first_tail_x15_r0_body.s248`; its frames [2665,2673467,2673472,2673473] (kept arrays [2665,2673467]). -/

-- the map's places and counters
kernel_rfl PRE_first_tail_x15_r0_body.zpl24 : PRE_first_tail_x15_r0_body.pl24.all (Nat.ble PRE_first_tail_x15_r0_body.s246.next) = true
kernel_rfl PRE_first_tail_x15_r0_body.zplnd24 : nodupT PRE_first_tail_x15_r0_body.pl24 PTrie.nil = true
kernel_rfl PRE_first_tail_x15_r0_body.zn124 : Nat.ble PRE_first_tail_x15_r0_body.s246.next 2695442 = true
kernel_rfl PRE_first_tail_x15_r0_body.zfirst24 : Nat.ble aFirst PRE_first_tail_x15_r0_body.s246.next = true
kernel_rfl PRE_first_tail_x15_r0_body.zscn24 : PRE_first_tail_x15_r0_body.s248.next = PRE_first_tail_x15_r0_body.s246.next + PRE_first_tail_x15_r0_body.pl24.length
kernel_rfl PRE_first_tail_x15_r0_body.zsmn24 : PRE_first_tail_x15_r0_body.s247.next = 2695442
kernel_rfl PRE_first_tail_x15_r0_body.zgrow24 : Nat.ble PRE_first_tail_x15_r0_body.s248.next PRE_first_tail_x15_r0_body.s247.next = true
-- the tables
kernel_rfl PRE_first_tail_x15_r0_body.zfresh24 : PRE_first_tail_x15_r0_body.S246.tab.all (fun e => PRE_first_tail_x15_r0_body.cws24.all fun v => e.noVar v) = true
kernel_rfl PRE_first_tail_x15_r0_body.zcnd24 : nodupT PRE_first_tail_x15_r0_body.cws24 PTrie.nil = true
kernel_rfl PRE_first_tail_x15_r0_body.znrHi24 : PRE_first_tail_x15_r0_body.nr24.all (fun r => Nat.blt r PRE_first_tail_x15_r0_body.S247.tab.length) = true
-- the frames: every framed address below the call's counter; the kept arrays the chain start's, extended in the merged state
kernel_rfl PRE_first_tail_x15_r0_body.zfrlt24 : [2665, 2673467, 2673472, 2673473].all (fun a => Nat.blt a PRE_first_tail_x15_r0_body.s246.next) = true
kernel_rfl PRE_first_tail_x15_r0_body.zg24_2665 : PRE_first_tail_x15_r0_body.s248.heap.get 2665 = some (.obj (objOf PRE_first_tail_x15_r0_body.s248 2665))
kernel_rfl PRE_first_tail_x15_r0_body.zk24_2665 : (objOf PRE_first_tail_x15_r0_body.s248 2665).kind = .array (arrOf PRE_first_tail_x15_r0_body.s0 2665)
kernel_rfl PRE_first_tail_x15_r0_body.zm24_2665 : PRE_first_tail_x15_r0_body.s247.heap.get 2665 = some (.obj { PRE_first_tail_x15_r0_body.kappa24.obj (objOf PRE_first_tail_x15_r0_body.s248 2665) with
  kind := .array (arrOf PRE_first_tail_x15_r0_body.s0 2665 ++ (arrOf PRE_first_tail_x15_r0_body.s247 2665).drop (arrOf PRE_first_tail_x15_r0_body.s0 2665).length) })
kernel_rfl PRE_first_tail_x15_r0_body.zg24_2673467 : PRE_first_tail_x15_r0_body.s248.heap.get 2673467 = some (.obj (objOf PRE_first_tail_x15_r0_body.s248 2673467))
kernel_rfl PRE_first_tail_x15_r0_body.zk24_2673467 : (objOf PRE_first_tail_x15_r0_body.s248 2673467).kind = .array (arrOf PRE_first_tail_x15_r0_body.s0 2673467)
kernel_rfl PRE_first_tail_x15_r0_body.zm24_2673467 : PRE_first_tail_x15_r0_body.s247.heap.get 2673467 = some (.obj { PRE_first_tail_x15_r0_body.kappa24.obj (objOf PRE_first_tail_x15_r0_body.s248 2673467) with
  kind := .array (arrOf PRE_first_tail_x15_r0_body.s0 2673467 ++ (arrOf PRE_first_tail_x15_r0_body.s247 2673467).drop (arrOf PRE_first_tail_x15_r0_body.s0 2673467).length) })
kernel_rfl PRE_first_tail_x15_r0_body.zw24_4910 : (PRE_first_tail_x15_r0_body.s248.heap.get 4910).isSome = true
kernel_rfl PRE_first_tail_x15_r0_body.zw24_2673472 : (PRE_first_tail_x15_r0_body.s248.heap.get 2673472).isSome = true
kernel_rfl PRE_first_tail_x15_r0_body.zw24_2673473 : (PRE_first_tail_x15_r0_body.s248.heap.get 2673473).isSome = true
-- the heap: the changed list in range, holding the stage's written and fresh addresses; the canonical side's image
kernel_rfl PRE_first_tail_x15_r0_body.zclbd24 : PRE_first_tail_x15_r0_body.cl24.all (fun b => Nat.blt (b / 4096) (4 ^ 31)) = true
kernel_rfl PRE_first_tail_x15_r0_body.zwr24 : PRE_first_tail_x15_r0_body.st24.wr.all (fun b => !Nat.blt b PRE_first_tail_x15_r0_body.s246.next || PRE_first_tail_x15_r0_body.cl24.contains b) = true
def PRE_first_tail_x15_r0_body.zl24 : List Nat := PRE_first_tail_x15_r0_body.cl24.filter fun a => !(List.contains [2665, 2673467] a)
kernel_rfl PRE_first_tail_x15_r0_body.zimgE24 : PRE_first_tail_x15_r0_body.zl24.map (fun a => PRE_first_tail_x15_r0_body.s247.heap.get (PRE_first_tail_x15_r0_body.kappa24.a a)) = PRE_first_tail_x15_r0_body.zl24.map (fun a => (PRE_first_tail_x15_r0_body.s248.heap.get a).map PRE_first_tail_x15_r0_body.kappa24.hobj)
theorem PRE_first_tail_x15_r0_body.zimg24 : HeapImg PRE_first_tail_x15_r0_body.kappa24 PRE_first_tail_x15_r0_body.s248 PRE_first_tail_x15_r0_body.s247 PRE_first_tail_x15_r0_body.zl24 := PRE_first_tail_x15_r0_body.zimgE24
-- the roots and their supports
kernel_rfl PRE_first_tail_x15_r0_body.zctl24 : PRE_first_tail_x15_r0_body.s247.ctl = PRE_first_tail_x15_r0_body.kappa24.ctl PRE_first_tail_x15_r0_body.s248.ctl
kernel_rfl PRE_first_tail_x15_r0_body.zstack24 : PRE_first_tail_x15_r0_body.s247.stack = PRE_first_tail_x15_r0_body.s248.stack.map PRE_first_tail_x15_r0_body.kappa24.frame
kernel_rfl PRE_first_tail_x15_r0_body.zjobs24 : PRE_first_tail_x15_r0_body.s247.jobs = PRE_first_tail_x15_r0_body.s248.jobs.map PRE_first_tail_x15_r0_body.kappa24.job
kernel_rfl PRE_first_tail_x15_r0_body.zstores24 : PRE_first_tail_x15_r0_body.s247.stores = PRE_first_tail_x15_r0_body.kappa24.stores PRE_first_tail_x15_r0_body.s248.stores
kernel_rfl PRE_first_tail_x15_r0_body.zroots24 : checkRootsSupp PRE_first_tail_x15_r0_body.s248 1127 = true
kernel_rfl PRE_first_tail_x15_r0_body.znC24 : PRE_first_tail_x15_r0_body.S246.tab.length + PRE_first_tail_x15_r0_body.cws24.length = 1127
-- the map as `Conv.compact_shift` states it (the call's counters for the literals)
kernel_rfl PRE_first_tail_x15_r0_body.zkap24 : PRE_first_tail_x15_r0_body.kappa24 = Conv.Map.compact PRE_first_tail_x15_r0_body.s246.next 2695442 PRE_first_tail_x15_r0_body.S246.tab.length PRE_first_tail_x15_r0_body.pl24 (PRE_first_tail_x15_r0_body.nr24.map NumV.ref) PRE_first_tail_x15_r0_body.kd24.big
  PRE_first_tail_x15_r0_body.kd24.region PRE_first_tail_x15_r0_body.kd24.nodeF
-- the bridge inactive at the canonical state (`Conv.FullShiftQ.toX`; the merged state's bridge is the canonical's: cbridge)
theorem PRE_first_tail_x15_r0_body.zbin24 : (Host.Ts.Sim.Full.bridgeOf PRE_first_tail_x15_r0_body.s248.ffi).active = false := (Host.Load.Boot.replay_active Host.Load.Run.Prompt.P.oblog2818)
-- the JS bookkeeping's step (`Conv.JClean.step` over the changed list) and the canonical roots' bigint freedom
kernel_rfl PRE_first_tail_x15_r0_body.zjc24 : Conv.jcleanListB (⟨18691, 15779, 2694293, 1127⟩ : Conv.Cnt) PRE_first_tail_x15_r0_body.s248 PRE_first_tail_x15_r0_body.cl24 = true
kernel_rfl PRE_first_tail_x15_r0_body.zrootsB24 : noBigRootsP (fun i => !Conv.oldBigB (⟨18691, 15779, 2694293, 1127⟩ : Conv.Cnt) i) PRE_first_tail_x15_r0_body.s248.trace PRE_first_tail_x15_r0_body.s248 = true
kernel_rfl PRE_first_tail_x15_r0_body.zhm24 : Nat.ble (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s0.ffi).mlx.nnext 15752 = true
theorem PRE_first_tail_x15_r0_body.cjcl24 (h : Conv.JClean (⟨18688, 15752, 2694287, 1109⟩ : Conv.Cnt) PRE_first_tail_x15_r0_body.s246) : Conv.JClean (⟨18691, 15779, 2694293, 1127⟩ : Conv.Cnt) PRE_first_tail_x15_r0_body.s248 :=
  Conv.JClean.step h (Conv.Cnt.le_of_leB PRE_first_tail_x15_r0_body.cle24)
    (Conv.heap_off_setAll PRE_first_tail_x15_r0_body.cheap24 fun a ha => Nat.blt_eq.mp (List.all_eq_true.mp PRE_first_tail_x15_r0_body.zclbd24 a ha)) PRE_first_tail_x15_r0_body.zjc24

end Host.Load.Run.Tpl
