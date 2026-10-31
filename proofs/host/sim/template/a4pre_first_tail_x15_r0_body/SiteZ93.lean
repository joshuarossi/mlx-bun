import host.sim.template.a4pre_first_tail_x15_r0_body.SiteS93
import host.sim.template.a4pre_first_tail_x15_r0_body.SiteK93
import host.sim.template.a4pre_first_tail_x15_r0_body.SiteF93
import host.sim.conv.CompactShift
import host.sim.template.Check
import host.sim.BigFreeP
import host.sim.template.CallGen
set_option Elab.async false
namespace Host.Load.Run.Tpl
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
open Host.Ts Host.Ts.Sim Host.Ts.Sim.Template

/-! The compaction's state shift at call site 93 of chain `PRE_first_tail_x15_r0_body` (`Conv.compact_shift`): the call `PRE_first_tail_x15_r0_body.s907`, the merged
state `PRE_first_tail_x15_r0_body.s908`, the canonical state `PRE_first_tail_x15_r0_body.s909`; its frames [2665,2673467,2673472,2673473] (kept arrays [2665,2673467]). -/

-- the map's places and counters
kernel_rfl PRE_first_tail_x15_r0_body.zpl93 : PRE_first_tail_x15_r0_body.pl93.all (Nat.ble PRE_first_tail_x15_r0_body.s907.next) = true
kernel_rfl PRE_first_tail_x15_r0_body.zplnd93 : nodupT PRE_first_tail_x15_r0_body.pl93 PTrie.nil = true
kernel_rfl PRE_first_tail_x15_r0_body.zn193 : Nat.ble PRE_first_tail_x15_r0_body.s907.next 2748773 = true
kernel_rfl PRE_first_tail_x15_r0_body.zfirst93 : Nat.ble aFirst PRE_first_tail_x15_r0_body.s907.next = true
kernel_rfl PRE_first_tail_x15_r0_body.zscn93 : PRE_first_tail_x15_r0_body.s909.next = PRE_first_tail_x15_r0_body.s907.next + PRE_first_tail_x15_r0_body.pl93.length
kernel_rfl PRE_first_tail_x15_r0_body.zsmn93 : PRE_first_tail_x15_r0_body.s908.next = 2748773
kernel_rfl PRE_first_tail_x15_r0_body.zgrow93 : Nat.ble PRE_first_tail_x15_r0_body.s909.next PRE_first_tail_x15_r0_body.s908.next = true
-- the tables
kernel_rfl PRE_first_tail_x15_r0_body.zfresh93 : PRE_first_tail_x15_r0_body.S907.tab.all (fun e => PRE_first_tail_x15_r0_body.cws93.all fun v => e.noVar v) = true
kernel_rfl PRE_first_tail_x15_r0_body.zcnd93 : nodupT PRE_first_tail_x15_r0_body.cws93 PTrie.nil = true
kernel_rfl PRE_first_tail_x15_r0_body.znrHi93 : PRE_first_tail_x15_r0_body.nr93.all (fun r => Nat.blt r PRE_first_tail_x15_r0_body.S908.tab.length) = true
-- the frames: every framed address below the call's counter; the kept arrays the chain start's, extended in the merged state
kernel_rfl PRE_first_tail_x15_r0_body.zfrlt93 : [2665, 2673467, 2673472, 2673473].all (fun a => Nat.blt a PRE_first_tail_x15_r0_body.s907.next) = true
kernel_rfl PRE_first_tail_x15_r0_body.zg93_2665 : PRE_first_tail_x15_r0_body.s909.heap.get 2665 = some (.obj (objOf PRE_first_tail_x15_r0_body.s909 2665))
kernel_rfl PRE_first_tail_x15_r0_body.zk93_2665 : (objOf PRE_first_tail_x15_r0_body.s909 2665).kind = .array (arrOf PRE_first_tail_x15_r0_body.s0 2665)
kernel_rfl PRE_first_tail_x15_r0_body.zm93_2665 : PRE_first_tail_x15_r0_body.s908.heap.get 2665 = some (.obj { PRE_first_tail_x15_r0_body.kappa93.obj (objOf PRE_first_tail_x15_r0_body.s909 2665) with
  kind := .array (arrOf PRE_first_tail_x15_r0_body.s0 2665 ++ (arrOf PRE_first_tail_x15_r0_body.s908 2665).drop (arrOf PRE_first_tail_x15_r0_body.s0 2665).length) })
kernel_rfl PRE_first_tail_x15_r0_body.zg93_2673467 : PRE_first_tail_x15_r0_body.s909.heap.get 2673467 = some (.obj (objOf PRE_first_tail_x15_r0_body.s909 2673467))
kernel_rfl PRE_first_tail_x15_r0_body.zk93_2673467 : (objOf PRE_first_tail_x15_r0_body.s909 2673467).kind = .array (arrOf PRE_first_tail_x15_r0_body.s0 2673467)
kernel_rfl PRE_first_tail_x15_r0_body.zm93_2673467 : PRE_first_tail_x15_r0_body.s908.heap.get 2673467 = some (.obj { PRE_first_tail_x15_r0_body.kappa93.obj (objOf PRE_first_tail_x15_r0_body.s909 2673467) with
  kind := .array (arrOf PRE_first_tail_x15_r0_body.s0 2673467 ++ (arrOf PRE_first_tail_x15_r0_body.s908 2673467).drop (arrOf PRE_first_tail_x15_r0_body.s0 2673467).length) })
kernel_rfl PRE_first_tail_x15_r0_body.zw93_4910 : (PRE_first_tail_x15_r0_body.s909.heap.get 4910).isSome = true
kernel_rfl PRE_first_tail_x15_r0_body.zw93_2673472 : (PRE_first_tail_x15_r0_body.s909.heap.get 2673472).isSome = true
kernel_rfl PRE_first_tail_x15_r0_body.zw93_2673473 : (PRE_first_tail_x15_r0_body.s909.heap.get 2673473).isSome = true
-- the heap: the changed list in range, holding the stage's written and fresh addresses; the canonical side's image
kernel_rfl PRE_first_tail_x15_r0_body.zclbd93 : PRE_first_tail_x15_r0_body.cl93.all (fun b => Nat.blt (b / 4096) (4 ^ 31)) = true
kernel_rfl PRE_first_tail_x15_r0_body.zwr93 : PRE_first_tail_x15_r0_body.st93.wr.all (fun b => !Nat.blt b PRE_first_tail_x15_r0_body.s907.next || PRE_first_tail_x15_r0_body.cl93.contains b) = true
def PRE_first_tail_x15_r0_body.zl93 : List Nat := PRE_first_tail_x15_r0_body.cl93.filter fun a => !(List.contains [2665, 2673467] a)
kernel_rfl PRE_first_tail_x15_r0_body.zimgE93 : PRE_first_tail_x15_r0_body.zl93.map (fun a => PRE_first_tail_x15_r0_body.s908.heap.get (PRE_first_tail_x15_r0_body.kappa93.a a)) = PRE_first_tail_x15_r0_body.zl93.map (fun a => (PRE_first_tail_x15_r0_body.s909.heap.get a).map PRE_first_tail_x15_r0_body.kappa93.hobj)
theorem PRE_first_tail_x15_r0_body.zimg93 : HeapImg PRE_first_tail_x15_r0_body.kappa93 PRE_first_tail_x15_r0_body.s909 PRE_first_tail_x15_r0_body.s908 PRE_first_tail_x15_r0_body.zl93 := PRE_first_tail_x15_r0_body.zimgE93
-- the roots and their supports
kernel_rfl PRE_first_tail_x15_r0_body.zctl93 : PRE_first_tail_x15_r0_body.s908.ctl = PRE_first_tail_x15_r0_body.kappa93.ctl PRE_first_tail_x15_r0_body.s909.ctl
kernel_rfl PRE_first_tail_x15_r0_body.zstack93 : PRE_first_tail_x15_r0_body.s908.stack = PRE_first_tail_x15_r0_body.s909.stack.map PRE_first_tail_x15_r0_body.kappa93.frame
kernel_rfl PRE_first_tail_x15_r0_body.zjobs93 : PRE_first_tail_x15_r0_body.s908.jobs = PRE_first_tail_x15_r0_body.s909.jobs.map PRE_first_tail_x15_r0_body.kappa93.job
kernel_rfl PRE_first_tail_x15_r0_body.zstores93 : PRE_first_tail_x15_r0_body.s908.stores = PRE_first_tail_x15_r0_body.kappa93.stores PRE_first_tail_x15_r0_body.s909.stores
kernel_rfl PRE_first_tail_x15_r0_body.zroots93 : checkRootsSupp PRE_first_tail_x15_r0_body.s909 4074 = true
kernel_rfl PRE_first_tail_x15_r0_body.znC93 : PRE_first_tail_x15_r0_body.S907.tab.length + PRE_first_tail_x15_r0_body.cws93.length = 4074
-- the map as `Conv.compact_shift` states it (the call's counters for the literals)
kernel_rfl PRE_first_tail_x15_r0_body.zkap93 : PRE_first_tail_x15_r0_body.kappa93 = Conv.Map.compact PRE_first_tail_x15_r0_body.s907.next 2748773 PRE_first_tail_x15_r0_body.S907.tab.length PRE_first_tail_x15_r0_body.pl93 (PRE_first_tail_x15_r0_body.nr93.map NumV.ref) PRE_first_tail_x15_r0_body.kd93.big
  PRE_first_tail_x15_r0_body.kd93.region PRE_first_tail_x15_r0_body.kd93.nodeF
-- the bridge inactive at the canonical state (`Conv.FullShiftQ.toX`; the merged state's bridge is the canonical's: cbridge)
theorem PRE_first_tail_x15_r0_body.zbin93 : (Host.Ts.Sim.Full.bridgeOf PRE_first_tail_x15_r0_body.s909.ffi).active = false := (Host.Load.Boot.replay_active Host.Load.Run.Prompt.P.oblog2818)
-- the JS bookkeeping's step (`Conv.JClean.step` over the changed list) and the canonical roots' bigint freedom
kernel_rfl PRE_first_tail_x15_r0_body.zjc93 : Conv.jcleanListB (⟨20049, 17141, 2748423, 4074⟩ : Conv.Cnt) PRE_first_tail_x15_r0_body.s909 PRE_first_tail_x15_r0_body.cl93 = true
kernel_rfl PRE_first_tail_x15_r0_body.zrootsB93 : noBigRootsP (fun i => !Conv.oldBigB (⟨20049, 17141, 2748423, 4074⟩ : Conv.Cnt) i) PRE_first_tail_x15_r0_body.s909.trace PRE_first_tail_x15_r0_body.s909 = true
kernel_rfl PRE_first_tail_x15_r0_body.zhm93 : Nat.ble (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s0.ffi).mlx.nnext 17135 = true
theorem PRE_first_tail_x15_r0_body.cjcl93 (h : Conv.JClean (⟨20045, 17135, 2748408, 4065⟩ : Conv.Cnt) PRE_first_tail_x15_r0_body.s907) : Conv.JClean (⟨20049, 17141, 2748423, 4074⟩ : Conv.Cnt) PRE_first_tail_x15_r0_body.s909 :=
  Conv.JClean.step h (Conv.Cnt.le_of_leB PRE_first_tail_x15_r0_body.cle93)
    (Conv.heap_off_setAll PRE_first_tail_x15_r0_body.cheap93 fun a ha => Nat.blt_eq.mp (List.all_eq_true.mp PRE_first_tail_x15_r0_body.zclbd93 a ha)) PRE_first_tail_x15_r0_body.zjc93

end Host.Load.Run.Tpl
