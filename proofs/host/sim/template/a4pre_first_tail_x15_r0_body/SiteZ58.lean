import host.sim.template.a4pre_first_tail_x15_r0_body.SiteS58
import host.sim.template.a4pre_first_tail_x15_r0_body.SiteK58
import host.sim.template.a4pre_first_tail_x15_r0_body.SiteF58
import host.sim.conv.CompactShift
import host.sim.template.Check
import host.sim.BigFreeP
import host.sim.template.CallGen
set_option Elab.async false
namespace Host.Load.Run.Tpl
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
open Host.Ts Host.Ts.Sim Host.Ts.Sim.Template

/-! The compaction's state shift at call site 58 of chain `PRE_first_tail_x15_r0_body` (`Conv.compact_shift`): the call `PRE_first_tail_x15_r0_body.s519`, the merged
state `PRE_first_tail_x15_r0_body.s520`, the canonical state `PRE_first_tail_x15_r0_body.s521`; its frames [2665,2673467,2673472,2673473] (kept arrays [2665,2673467]). -/

-- the map's places and counters
kernel_rfl PRE_first_tail_x15_r0_body.zpl58 : PRE_first_tail_x15_r0_body.pl58.all (Nat.ble PRE_first_tail_x15_r0_body.s519.next) = true
kernel_rfl PRE_first_tail_x15_r0_body.zplnd58 : nodupT PRE_first_tail_x15_r0_body.pl58 PTrie.nil = true
kernel_rfl PRE_first_tail_x15_r0_body.zn158 : Nat.ble PRE_first_tail_x15_r0_body.s519.next 2720767 = true
kernel_rfl PRE_first_tail_x15_r0_body.zfirst58 : Nat.ble aFirst PRE_first_tail_x15_r0_body.s519.next = true
kernel_rfl PRE_first_tail_x15_r0_body.zscn58 : PRE_first_tail_x15_r0_body.s521.next = PRE_first_tail_x15_r0_body.s519.next + PRE_first_tail_x15_r0_body.pl58.length
kernel_rfl PRE_first_tail_x15_r0_body.zsmn58 : PRE_first_tail_x15_r0_body.s520.next = 2720767
kernel_rfl PRE_first_tail_x15_r0_body.zgrow58 : Nat.ble PRE_first_tail_x15_r0_body.s521.next PRE_first_tail_x15_r0_body.s520.next = true
-- the tables
kernel_rfl PRE_first_tail_x15_r0_body.zfresh58 : PRE_first_tail_x15_r0_body.S519.tab.all (fun e => PRE_first_tail_x15_r0_body.cws58.all fun v => e.noVar v) = true
kernel_rfl PRE_first_tail_x15_r0_body.zcnd58 : nodupT PRE_first_tail_x15_r0_body.cws58 PTrie.nil = true
kernel_rfl PRE_first_tail_x15_r0_body.znrHi58 : PRE_first_tail_x15_r0_body.nr58.all (fun r => Nat.blt r PRE_first_tail_x15_r0_body.S520.tab.length) = true
-- the frames: every framed address below the call's counter; the kept arrays the chain start's, extended in the merged state
kernel_rfl PRE_first_tail_x15_r0_body.zfrlt58 : [2665, 2673467, 2673472, 2673473].all (fun a => Nat.blt a PRE_first_tail_x15_r0_body.s519.next) = true
kernel_rfl PRE_first_tail_x15_r0_body.zg58_2665 : PRE_first_tail_x15_r0_body.s521.heap.get 2665 = some (.obj (objOf PRE_first_tail_x15_r0_body.s521 2665))
kernel_rfl PRE_first_tail_x15_r0_body.zk58_2665 : (objOf PRE_first_tail_x15_r0_body.s521 2665).kind = .array (arrOf PRE_first_tail_x15_r0_body.s0 2665)
kernel_rfl PRE_first_tail_x15_r0_body.zm58_2665 : PRE_first_tail_x15_r0_body.s520.heap.get 2665 = some (.obj { PRE_first_tail_x15_r0_body.kappa58.obj (objOf PRE_first_tail_x15_r0_body.s521 2665) with
  kind := .array (arrOf PRE_first_tail_x15_r0_body.s0 2665 ++ (arrOf PRE_first_tail_x15_r0_body.s520 2665).drop (arrOf PRE_first_tail_x15_r0_body.s0 2665).length) })
kernel_rfl PRE_first_tail_x15_r0_body.zg58_2673467 : PRE_first_tail_x15_r0_body.s521.heap.get 2673467 = some (.obj (objOf PRE_first_tail_x15_r0_body.s521 2673467))
kernel_rfl PRE_first_tail_x15_r0_body.zk58_2673467 : (objOf PRE_first_tail_x15_r0_body.s521 2673467).kind = .array (arrOf PRE_first_tail_x15_r0_body.s0 2673467)
kernel_rfl PRE_first_tail_x15_r0_body.zm58_2673467 : PRE_first_tail_x15_r0_body.s520.heap.get 2673467 = some (.obj { PRE_first_tail_x15_r0_body.kappa58.obj (objOf PRE_first_tail_x15_r0_body.s521 2673467) with
  kind := .array (arrOf PRE_first_tail_x15_r0_body.s0 2673467 ++ (arrOf PRE_first_tail_x15_r0_body.s520 2673467).drop (arrOf PRE_first_tail_x15_r0_body.s0 2673467).length) })
kernel_rfl PRE_first_tail_x15_r0_body.zw58_4910 : (PRE_first_tail_x15_r0_body.s521.heap.get 4910).isSome = true
kernel_rfl PRE_first_tail_x15_r0_body.zw58_2673472 : (PRE_first_tail_x15_r0_body.s521.heap.get 2673472).isSome = true
kernel_rfl PRE_first_tail_x15_r0_body.zw58_2673473 : (PRE_first_tail_x15_r0_body.s521.heap.get 2673473).isSome = true
-- the heap: the changed list in range, holding the stage's written and fresh addresses; the canonical side's image
kernel_rfl PRE_first_tail_x15_r0_body.zclbd58 : PRE_first_tail_x15_r0_body.cl58.all (fun b => Nat.blt (b / 4096) (4 ^ 31)) = true
kernel_rfl PRE_first_tail_x15_r0_body.zwr58 : PRE_first_tail_x15_r0_body.st58.wr.all (fun b => !Nat.blt b PRE_first_tail_x15_r0_body.s519.next || PRE_first_tail_x15_r0_body.cl58.contains b) = true
def PRE_first_tail_x15_r0_body.zl58 : List Nat := PRE_first_tail_x15_r0_body.cl58.filter fun a => !(List.contains [2665, 2673467] a)
kernel_rfl PRE_first_tail_x15_r0_body.zimgE58 : PRE_first_tail_x15_r0_body.zl58.map (fun a => PRE_first_tail_x15_r0_body.s520.heap.get (PRE_first_tail_x15_r0_body.kappa58.a a)) = PRE_first_tail_x15_r0_body.zl58.map (fun a => (PRE_first_tail_x15_r0_body.s521.heap.get a).map PRE_first_tail_x15_r0_body.kappa58.hobj)
theorem PRE_first_tail_x15_r0_body.zimg58 : HeapImg PRE_first_tail_x15_r0_body.kappa58 PRE_first_tail_x15_r0_body.s521 PRE_first_tail_x15_r0_body.s520 PRE_first_tail_x15_r0_body.zl58 := PRE_first_tail_x15_r0_body.zimgE58
-- the roots and their supports
kernel_rfl PRE_first_tail_x15_r0_body.zctl58 : PRE_first_tail_x15_r0_body.s520.ctl = PRE_first_tail_x15_r0_body.kappa58.ctl PRE_first_tail_x15_r0_body.s521.ctl
kernel_rfl PRE_first_tail_x15_r0_body.zstack58 : PRE_first_tail_x15_r0_body.s520.stack = PRE_first_tail_x15_r0_body.s521.stack.map PRE_first_tail_x15_r0_body.kappa58.frame
kernel_rfl PRE_first_tail_x15_r0_body.zjobs58 : PRE_first_tail_x15_r0_body.s520.jobs = PRE_first_tail_x15_r0_body.s521.jobs.map PRE_first_tail_x15_r0_body.kappa58.job
kernel_rfl PRE_first_tail_x15_r0_body.zstores58 : PRE_first_tail_x15_r0_body.s520.stores = PRE_first_tail_x15_r0_body.kappa58.stores PRE_first_tail_x15_r0_body.s521.stores
kernel_rfl PRE_first_tail_x15_r0_body.zroots58 : checkRootsSupp PRE_first_tail_x15_r0_body.s521 2558 = true
kernel_rfl PRE_first_tail_x15_r0_body.znC58 : PRE_first_tail_x15_r0_body.S519.tab.length + PRE_first_tail_x15_r0_body.cws58.length = 2558
-- the map as `Conv.compact_shift` states it (the call's counters for the literals)
kernel_rfl PRE_first_tail_x15_r0_body.zkap58 : PRE_first_tail_x15_r0_body.kappa58 = Conv.Map.compact PRE_first_tail_x15_r0_body.s519.next 2720767 PRE_first_tail_x15_r0_body.S519.tab.length PRE_first_tail_x15_r0_body.pl58 (PRE_first_tail_x15_r0_body.nr58.map NumV.ref) PRE_first_tail_x15_r0_body.kd58.big
  PRE_first_tail_x15_r0_body.kd58.region PRE_first_tail_x15_r0_body.kd58.nodeF
-- the bridge inactive at the canonical state (`Conv.FullShiftQ.toX`; the merged state's bridge is the canonical's: cbridge)
theorem PRE_first_tail_x15_r0_body.zbin58 : (Host.Ts.Sim.Full.bridgeOf PRE_first_tail_x15_r0_body.s521.ffi).active = false := (Host.Load.Boot.replay_active Host.Load.Run.Prompt.P.oblog2818)
-- the JS bookkeeping's step (`Conv.JClean.step` over the changed list) and the canonical roots' bigint freedom
kernel_rfl PRE_first_tail_x15_r0_body.zjc58 : Conv.jcleanListB (⟨19354, 16440, 2720765, 2558⟩ : Conv.Cnt) PRE_first_tail_x15_r0_body.s521 PRE_first_tail_x15_r0_body.cl58 = true
kernel_rfl PRE_first_tail_x15_r0_body.zroots258 : noBigRootsP (fun i => !Conv.oldBigB (⟨19354, 16440, 2720765, 2558⟩ : Conv.Cnt) i) PRE_first_tail_x15_r0_body.s521.trace PRE_first_tail_x15_r0_body.s521 = true
kernel_rfl PRE_first_tail_x15_r0_body.zhm58 : Nat.ble (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s0.ffi).mlx.nnext 16440 = true
theorem PRE_first_tail_x15_r0_body.cjcl58 (h : Conv.JClean (⟨19354, 16440, 2720765, 2558⟩ : Conv.Cnt) PRE_first_tail_x15_r0_body.s519) : Conv.JClean (⟨19354, 16440, 2720765, 2558⟩ : Conv.Cnt) PRE_first_tail_x15_r0_body.s521 :=
  Conv.JClean.step h (Conv.Cnt.le_of_leB PRE_first_tail_x15_r0_body.cle58)
    (Conv.heap_off_setAll PRE_first_tail_x15_r0_body.cheap58 fun a ha => Nat.blt_eq.mp (List.all_eq_true.mp PRE_first_tail_x15_r0_body.zclbd58 a ha)) PRE_first_tail_x15_r0_body.zjc58

end Host.Load.Run.Tpl
