import host.sim.template.a4pre_first_tail_x15_r0_body.SiteS28
import host.sim.template.a4pre_first_tail_x15_r0_body.SiteK28
import host.sim.template.a4pre_first_tail_x15_r0_body.SiteF28
import host.sim.conv.CompactShift
import host.sim.template.Check
import host.sim.BigFreeP
import host.sim.template.CallGen
set_option Elab.async false
namespace Host.Load.Run.Tpl
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
open Host.Ts Host.Ts.Sim Host.Ts.Sim.Template

/-! The compaction's state shift at call site 28 of chain `PRE_first_tail_x15_r0_body` (`Conv.compact_shift`): the call `PRE_first_tail_x15_r0_body.s258`, the merged
state `PRE_first_tail_x15_r0_body.s259`, the canonical state `PRE_first_tail_x15_r0_body.s260`; its frames [2665,2673467,2673472,2673473] (kept arrays [2665,2673467]). -/

-- the map's places and counters
kernel_rfl PRE_first_tail_x15_r0_body.zpl28 : PRE_first_tail_x15_r0_body.pl28.all (Nat.ble PRE_first_tail_x15_r0_body.s258.next) = true
kernel_rfl PRE_first_tail_x15_r0_body.zplnd28 : nodupT PRE_first_tail_x15_r0_body.pl28 PTrie.nil = true
kernel_rfl PRE_first_tail_x15_r0_body.zn128 : Nat.ble PRE_first_tail_x15_r0_body.s258.next 2697041 = true
kernel_rfl PRE_first_tail_x15_r0_body.zfirst28 : Nat.ble aFirst PRE_first_tail_x15_r0_body.s258.next = true
kernel_rfl PRE_first_tail_x15_r0_body.zscn28 : PRE_first_tail_x15_r0_body.s260.next = PRE_first_tail_x15_r0_body.s258.next + PRE_first_tail_x15_r0_body.pl28.length
kernel_rfl PRE_first_tail_x15_r0_body.zsmn28 : PRE_first_tail_x15_r0_body.s259.next = 2697041
kernel_rfl PRE_first_tail_x15_r0_body.zgrow28 : Nat.ble PRE_first_tail_x15_r0_body.s260.next PRE_first_tail_x15_r0_body.s259.next = true
-- the tables
kernel_rfl PRE_first_tail_x15_r0_body.zfresh28 : PRE_first_tail_x15_r0_body.S258.tab.all (fun e => PRE_first_tail_x15_r0_body.cws28.all fun v => e.noVar v) = true
kernel_rfl PRE_first_tail_x15_r0_body.zcnd28 : nodupT PRE_first_tail_x15_r0_body.cws28 PTrie.nil = true
kernel_rfl PRE_first_tail_x15_r0_body.znrHi28 : PRE_first_tail_x15_r0_body.nr28.all (fun r => Nat.blt r PRE_first_tail_x15_r0_body.S259.tab.length) = true
-- the frames: every framed address below the call's counter; the kept arrays the chain start's, extended in the merged state
kernel_rfl PRE_first_tail_x15_r0_body.zfrlt28 : [2665, 2673467, 2673472, 2673473].all (fun a => Nat.blt a PRE_first_tail_x15_r0_body.s258.next) = true
kernel_rfl PRE_first_tail_x15_r0_body.zg28_2665 : PRE_first_tail_x15_r0_body.s260.heap.get 2665 = some (.obj (objOf PRE_first_tail_x15_r0_body.s260 2665))
kernel_rfl PRE_first_tail_x15_r0_body.zk28_2665 : (objOf PRE_first_tail_x15_r0_body.s260 2665).kind = .array (arrOf PRE_first_tail_x15_r0_body.s0 2665)
kernel_rfl PRE_first_tail_x15_r0_body.zm28_2665 : PRE_first_tail_x15_r0_body.s259.heap.get 2665 = some (.obj { PRE_first_tail_x15_r0_body.kappa28.obj (objOf PRE_first_tail_x15_r0_body.s260 2665) with
  kind := .array (arrOf PRE_first_tail_x15_r0_body.s0 2665 ++ (arrOf PRE_first_tail_x15_r0_body.s259 2665).drop (arrOf PRE_first_tail_x15_r0_body.s0 2665).length) })
kernel_rfl PRE_first_tail_x15_r0_body.zg28_2673467 : PRE_first_tail_x15_r0_body.s260.heap.get 2673467 = some (.obj (objOf PRE_first_tail_x15_r0_body.s260 2673467))
kernel_rfl PRE_first_tail_x15_r0_body.zk28_2673467 : (objOf PRE_first_tail_x15_r0_body.s260 2673467).kind = .array (arrOf PRE_first_tail_x15_r0_body.s0 2673467)
kernel_rfl PRE_first_tail_x15_r0_body.zm28_2673467 : PRE_first_tail_x15_r0_body.s259.heap.get 2673467 = some (.obj { PRE_first_tail_x15_r0_body.kappa28.obj (objOf PRE_first_tail_x15_r0_body.s260 2673467) with
  kind := .array (arrOf PRE_first_tail_x15_r0_body.s0 2673467 ++ (arrOf PRE_first_tail_x15_r0_body.s259 2673467).drop (arrOf PRE_first_tail_x15_r0_body.s0 2673467).length) })
kernel_rfl PRE_first_tail_x15_r0_body.zw28_4910 : (PRE_first_tail_x15_r0_body.s260.heap.get 4910).isSome = true
kernel_rfl PRE_first_tail_x15_r0_body.zw28_2673472 : (PRE_first_tail_x15_r0_body.s260.heap.get 2673472).isSome = true
kernel_rfl PRE_first_tail_x15_r0_body.zw28_2673473 : (PRE_first_tail_x15_r0_body.s260.heap.get 2673473).isSome = true
-- the heap: the changed list in range, holding the stage's written and fresh addresses; the canonical side's image
kernel_rfl PRE_first_tail_x15_r0_body.zclbd28 : PRE_first_tail_x15_r0_body.cl28.all (fun b => Nat.blt (b / 4096) (4 ^ 31)) = true
kernel_rfl PRE_first_tail_x15_r0_body.zwr28 : PRE_first_tail_x15_r0_body.st28.wr.all (fun b => !Nat.blt b PRE_first_tail_x15_r0_body.s258.next || PRE_first_tail_x15_r0_body.cl28.contains b) = true
def PRE_first_tail_x15_r0_body.zl28 : List Nat := PRE_first_tail_x15_r0_body.cl28.filter fun a => !(List.contains [2665, 2673467] a)
kernel_rfl PRE_first_tail_x15_r0_body.zimgE28 : PRE_first_tail_x15_r0_body.zl28.map (fun a => PRE_first_tail_x15_r0_body.s259.heap.get (PRE_first_tail_x15_r0_body.kappa28.a a)) = PRE_first_tail_x15_r0_body.zl28.map (fun a => (PRE_first_tail_x15_r0_body.s260.heap.get a).map PRE_first_tail_x15_r0_body.kappa28.hobj)
theorem PRE_first_tail_x15_r0_body.zimg28 : HeapImg PRE_first_tail_x15_r0_body.kappa28 PRE_first_tail_x15_r0_body.s260 PRE_first_tail_x15_r0_body.s259 PRE_first_tail_x15_r0_body.zl28 := PRE_first_tail_x15_r0_body.zimgE28
-- the roots and their supports
kernel_rfl PRE_first_tail_x15_r0_body.zctl28 : PRE_first_tail_x15_r0_body.s259.ctl = PRE_first_tail_x15_r0_body.kappa28.ctl PRE_first_tail_x15_r0_body.s260.ctl
kernel_rfl PRE_first_tail_x15_r0_body.zstack28 : PRE_first_tail_x15_r0_body.s259.stack = PRE_first_tail_x15_r0_body.s260.stack.map PRE_first_tail_x15_r0_body.kappa28.frame
kernel_rfl PRE_first_tail_x15_r0_body.zjobs28 : PRE_first_tail_x15_r0_body.s259.jobs = PRE_first_tail_x15_r0_body.s260.jobs.map PRE_first_tail_x15_r0_body.kappa28.job
kernel_rfl PRE_first_tail_x15_r0_body.zstores28 : PRE_first_tail_x15_r0_body.s259.stores = PRE_first_tail_x15_r0_body.kappa28.stores PRE_first_tail_x15_r0_body.s260.stores
kernel_rfl PRE_first_tail_x15_r0_body.zroots28 : checkRootsSupp PRE_first_tail_x15_r0_body.s260 1277 = true
kernel_rfl PRE_first_tail_x15_r0_body.znC28 : PRE_first_tail_x15_r0_body.S258.tab.length + PRE_first_tail_x15_r0_body.cws28.length = 1277
-- the map as `Conv.compact_shift` states it (the call's counters for the literals)
kernel_rfl PRE_first_tail_x15_r0_body.zkap28 : PRE_first_tail_x15_r0_body.kappa28 = Conv.Map.compact PRE_first_tail_x15_r0_body.s258.next 2697041 PRE_first_tail_x15_r0_body.S258.tab.length PRE_first_tail_x15_r0_body.pl28 (PRE_first_tail_x15_r0_body.nr28.map NumV.ref) PRE_first_tail_x15_r0_body.kd28.big
  PRE_first_tail_x15_r0_body.kd28.region PRE_first_tail_x15_r0_body.kd28.nodeF
-- the bridge inactive at the canonical state (`Conv.FullShiftQ.toX`; the merged state's bridge is the canonical's: cbridge)
theorem PRE_first_tail_x15_r0_body.zbin28 : (Host.Ts.Sim.Full.bridgeOf PRE_first_tail_x15_r0_body.s260.ffi).active = false := (Host.Load.Boot.replay_active Host.Load.Run.Prompt.P.oblog2818)
-- the JS bookkeeping's step (`Conv.JClean.step` over the changed list) and the canonical roots' bigint freedom
kernel_rfl PRE_first_tail_x15_r0_body.zjc28 : Conv.jcleanListB (⟨18761, 15855, 2697039, 1277⟩ : Conv.Cnt) PRE_first_tail_x15_r0_body.s260 PRE_first_tail_x15_r0_body.cl28 = true
kernel_rfl PRE_first_tail_x15_r0_body.zroots228 : noBigRootsP (fun i => !Conv.oldBigB (⟨18761, 15855, 2697039, 1277⟩ : Conv.Cnt) i) PRE_first_tail_x15_r0_body.s260.trace PRE_first_tail_x15_r0_body.s260 = true
kernel_rfl PRE_first_tail_x15_r0_body.zhm28 : Nat.ble (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s0.ffi).mlx.nnext 15855 = true
theorem PRE_first_tail_x15_r0_body.cjcl28 (h : Conv.JClean (⟨18761, 15855, 2697039, 1277⟩ : Conv.Cnt) PRE_first_tail_x15_r0_body.s258) : Conv.JClean (⟨18761, 15855, 2697039, 1277⟩ : Conv.Cnt) PRE_first_tail_x15_r0_body.s260 :=
  Conv.JClean.step h (Conv.Cnt.le_of_leB PRE_first_tail_x15_r0_body.cle28)
    (Conv.heap_off_setAll PRE_first_tail_x15_r0_body.cheap28 fun a ha => Nat.blt_eq.mp (List.all_eq_true.mp PRE_first_tail_x15_r0_body.zclbd28 a ha)) PRE_first_tail_x15_r0_body.zjc28

end Host.Load.Run.Tpl
