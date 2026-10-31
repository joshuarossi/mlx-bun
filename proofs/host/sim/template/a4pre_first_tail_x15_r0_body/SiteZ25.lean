import host.sim.template.a4pre_first_tail_x15_r0_body.SiteS25
import host.sim.template.a4pre_first_tail_x15_r0_body.SiteK25
import host.sim.template.a4pre_first_tail_x15_r0_body.SiteF25
import host.sim.conv.CompactShift
import host.sim.template.Check
import host.sim.BigFreeP
import host.sim.template.CallGen
set_option Elab.async false
namespace Host.Load.Run.Tpl
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
open Host.Ts Host.Ts.Sim Host.Ts.Sim.Template

/-! The compaction's state shift at call site 25 of chain `PRE_first_tail_x15_r0_body` (`Conv.compact_shift`): the call `PRE_first_tail_x15_r0_body.s254`, the merged
state `PRE_first_tail_x15_r0_body.s255`, the canonical state `PRE_first_tail_x15_r0_body.s256`; its frames [2665,2673467,2673472,2673473] (kept arrays [2665,2673467]). -/

-- the map's places and counters
kernel_rfl PRE_first_tail_x15_r0_body.zpl25 : PRE_first_tail_x15_r0_body.pl25.all (Nat.ble PRE_first_tail_x15_r0_body.s254.next) = true
kernel_rfl PRE_first_tail_x15_r0_body.zplnd25 : nodupT PRE_first_tail_x15_r0_body.pl25 PTrie.nil = true
kernel_rfl PRE_first_tail_x15_r0_body.zn125 : Nat.ble PRE_first_tail_x15_r0_body.s254.next 2694785 = true
kernel_rfl PRE_first_tail_x15_r0_body.zfirst25 : Nat.ble aFirst PRE_first_tail_x15_r0_body.s254.next = true
kernel_rfl PRE_first_tail_x15_r0_body.zscn25 : PRE_first_tail_x15_r0_body.s256.next = PRE_first_tail_x15_r0_body.s254.next + PRE_first_tail_x15_r0_body.pl25.length
kernel_rfl PRE_first_tail_x15_r0_body.zsmn25 : PRE_first_tail_x15_r0_body.s255.next = 2694785
kernel_rfl PRE_first_tail_x15_r0_body.zgrow25 : Nat.ble PRE_first_tail_x15_r0_body.s256.next PRE_first_tail_x15_r0_body.s255.next = true
-- the tables
kernel_rfl PRE_first_tail_x15_r0_body.zfresh25 : PRE_first_tail_x15_r0_body.S254.tab.all (fun e => PRE_first_tail_x15_r0_body.cws25.all fun v => e.noVar v) = true
kernel_rfl PRE_first_tail_x15_r0_body.zcnd25 : nodupT PRE_first_tail_x15_r0_body.cws25 PTrie.nil = true
kernel_rfl PRE_first_tail_x15_r0_body.znrHi25 : PRE_first_tail_x15_r0_body.nr25.all (fun r => Nat.blt r PRE_first_tail_x15_r0_body.S255.tab.length) = true
-- the frames: every framed address below the call's counter; the kept arrays the chain start's, extended in the merged state
kernel_rfl PRE_first_tail_x15_r0_body.zfrlt25 : [2665, 2673467, 2673472, 2673473].all (fun a => Nat.blt a PRE_first_tail_x15_r0_body.s254.next) = true
kernel_rfl PRE_first_tail_x15_r0_body.zg25_2665 : PRE_first_tail_x15_r0_body.s256.heap.get 2665 = some (.obj (objOf PRE_first_tail_x15_r0_body.s256 2665))
kernel_rfl PRE_first_tail_x15_r0_body.zk25_2665 : (objOf PRE_first_tail_x15_r0_body.s256 2665).kind = .array (arrOf PRE_first_tail_x15_r0_body.s0 2665)
kernel_rfl PRE_first_tail_x15_r0_body.zm25_2665 : PRE_first_tail_x15_r0_body.s255.heap.get 2665 = some (.obj { PRE_first_tail_x15_r0_body.kappa25.obj (objOf PRE_first_tail_x15_r0_body.s256 2665) with
  kind := .array (arrOf PRE_first_tail_x15_r0_body.s0 2665 ++ (arrOf PRE_first_tail_x15_r0_body.s255 2665).drop (arrOf PRE_first_tail_x15_r0_body.s0 2665).length) })
kernel_rfl PRE_first_tail_x15_r0_body.zg25_2673467 : PRE_first_tail_x15_r0_body.s256.heap.get 2673467 = some (.obj (objOf PRE_first_tail_x15_r0_body.s256 2673467))
kernel_rfl PRE_first_tail_x15_r0_body.zk25_2673467 : (objOf PRE_first_tail_x15_r0_body.s256 2673467).kind = .array (arrOf PRE_first_tail_x15_r0_body.s0 2673467)
kernel_rfl PRE_first_tail_x15_r0_body.zm25_2673467 : PRE_first_tail_x15_r0_body.s255.heap.get 2673467 = some (.obj { PRE_first_tail_x15_r0_body.kappa25.obj (objOf PRE_first_tail_x15_r0_body.s256 2673467) with
  kind := .array (arrOf PRE_first_tail_x15_r0_body.s0 2673467 ++ (arrOf PRE_first_tail_x15_r0_body.s255 2673467).drop (arrOf PRE_first_tail_x15_r0_body.s0 2673467).length) })
kernel_rfl PRE_first_tail_x15_r0_body.zw25_4910 : (PRE_first_tail_x15_r0_body.s256.heap.get 4910).isSome = true
kernel_rfl PRE_first_tail_x15_r0_body.zw25_2673472 : (PRE_first_tail_x15_r0_body.s256.heap.get 2673472).isSome = true
kernel_rfl PRE_first_tail_x15_r0_body.zw25_2673473 : (PRE_first_tail_x15_r0_body.s256.heap.get 2673473).isSome = true
-- the heap: the changed list in range, holding the stage's written and fresh addresses; the canonical side's image
kernel_rfl PRE_first_tail_x15_r0_body.zclbd25 : PRE_first_tail_x15_r0_body.cl25.all (fun b => Nat.blt (b / 4096) (4 ^ 31)) = true
kernel_rfl PRE_first_tail_x15_r0_body.zwr25 : PRE_first_tail_x15_r0_body.st25.wr.all (fun b => !Nat.blt b PRE_first_tail_x15_r0_body.s254.next || PRE_first_tail_x15_r0_body.cl25.contains b) = true
def PRE_first_tail_x15_r0_body.zl25 : List Nat := PRE_first_tail_x15_r0_body.cl25.filter fun a => !(List.contains [2665, 2673467] a)
kernel_rfl PRE_first_tail_x15_r0_body.zimgE25 : PRE_first_tail_x15_r0_body.zl25.map (fun a => PRE_first_tail_x15_r0_body.s255.heap.get (PRE_first_tail_x15_r0_body.kappa25.a a)) = PRE_first_tail_x15_r0_body.zl25.map (fun a => (PRE_first_tail_x15_r0_body.s256.heap.get a).map PRE_first_tail_x15_r0_body.kappa25.hobj)
theorem PRE_first_tail_x15_r0_body.zimg25 : HeapImg PRE_first_tail_x15_r0_body.kappa25 PRE_first_tail_x15_r0_body.s256 PRE_first_tail_x15_r0_body.s255 PRE_first_tail_x15_r0_body.zl25 := PRE_first_tail_x15_r0_body.zimgE25
-- the roots and their supports
kernel_rfl PRE_first_tail_x15_r0_body.zctl25 : PRE_first_tail_x15_r0_body.s255.ctl = PRE_first_tail_x15_r0_body.kappa25.ctl PRE_first_tail_x15_r0_body.s256.ctl
kernel_rfl PRE_first_tail_x15_r0_body.zstack25 : PRE_first_tail_x15_r0_body.s255.stack = PRE_first_tail_x15_r0_body.s256.stack.map PRE_first_tail_x15_r0_body.kappa25.frame
kernel_rfl PRE_first_tail_x15_r0_body.zjobs25 : PRE_first_tail_x15_r0_body.s255.jobs = PRE_first_tail_x15_r0_body.s256.jobs.map PRE_first_tail_x15_r0_body.kappa25.job
kernel_rfl PRE_first_tail_x15_r0_body.zstores25 : PRE_first_tail_x15_r0_body.s255.stores = PRE_first_tail_x15_r0_body.kappa25.stores PRE_first_tail_x15_r0_body.s256.stores
kernel_rfl PRE_first_tail_x15_r0_body.zroots25 : checkRootsSupp PRE_first_tail_x15_r0_body.s256 1148 = true
kernel_rfl PRE_first_tail_x15_r0_body.znC25 : PRE_first_tail_x15_r0_body.S254.tab.length + PRE_first_tail_x15_r0_body.cws25.length = 1148
-- the map as `Conv.compact_shift` states it (the call's counters for the literals)
kernel_rfl PRE_first_tail_x15_r0_body.zkap25 : PRE_first_tail_x15_r0_body.kappa25 = Conv.Map.compact PRE_first_tail_x15_r0_body.s254.next 2694785 PRE_first_tail_x15_r0_body.S254.tab.length PRE_first_tail_x15_r0_body.pl25 (PRE_first_tail_x15_r0_body.nr25.map NumV.ref) PRE_first_tail_x15_r0_body.kd25.big
  PRE_first_tail_x15_r0_body.kd25.region PRE_first_tail_x15_r0_body.kd25.nodeF
-- the bridge inactive at the canonical state (`Conv.FullShiftQ.toX`; the merged state's bridge is the canonical's: cbridge)
theorem PRE_first_tail_x15_r0_body.zbin25 : (Host.Ts.Sim.Full.bridgeOf PRE_first_tail_x15_r0_body.s256.ffi).active = false := (Host.Load.Boot.replay_active Host.Load.Run.Prompt.P.oblog2818)
-- the JS bookkeeping's step (`Conv.JClean.step` over the changed list) and the canonical roots' bigint freedom
kernel_rfl PRE_first_tail_x15_r0_body.zjc25 : Conv.jcleanListB (⟨18704, 15792, 2694783, 1148⟩ : Conv.Cnt) PRE_first_tail_x15_r0_body.s256 PRE_first_tail_x15_r0_body.cl25 = true
kernel_rfl PRE_first_tail_x15_r0_body.zrootsB25 : noBigRootsP (fun i => !Conv.oldBigB (⟨18704, 15792, 2694783, 1148⟩ : Conv.Cnt) i) PRE_first_tail_x15_r0_body.s256.trace PRE_first_tail_x15_r0_body.s256 = true
kernel_rfl PRE_first_tail_x15_r0_body.zhm25 : Nat.ble (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s0.ffi).mlx.nnext 15792 = true
theorem PRE_first_tail_x15_r0_body.cjcl25 (h : Conv.JClean (⟨18704, 15792, 2694783, 1148⟩ : Conv.Cnt) PRE_first_tail_x15_r0_body.s254) : Conv.JClean (⟨18704, 15792, 2694783, 1148⟩ : Conv.Cnt) PRE_first_tail_x15_r0_body.s256 :=
  Conv.JClean.step h (Conv.Cnt.le_of_leB PRE_first_tail_x15_r0_body.cle25)
    (Conv.heap_off_setAll PRE_first_tail_x15_r0_body.cheap25 fun a ha => Nat.blt_eq.mp (List.all_eq_true.mp PRE_first_tail_x15_r0_body.zclbd25 a ha)) PRE_first_tail_x15_r0_body.zjc25

end Host.Load.Run.Tpl
