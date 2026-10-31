import host.sim.template.a4pre_first_tail_x15_r0_body.SiteS35
import host.sim.template.a4pre_first_tail_x15_r0_body.SiteK35
import host.sim.template.a4pre_first_tail_x15_r0_body.SiteF35
import host.sim.conv.CompactShift
import host.sim.template.Check
import host.sim.BigFreeP
import host.sim.template.CallGen
set_option Elab.async false
namespace Host.Load.Run.Tpl
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
open Host.Ts Host.Ts.Sim Host.Ts.Sim.Template

/-! The compaction's state shift at call site 35 of chain `PRE_first_tail_x15_r0_body` (`Conv.compact_shift`): the call `PRE_first_tail_x15_r0_body.s313`, the merged
state `PRE_first_tail_x15_r0_body.s314`, the canonical state `PRE_first_tail_x15_r0_body.s315`; its frames [2665,2673467,2673472,2673473] (kept arrays [2665,2673467]). -/

-- the map's places and counters
kernel_rfl PRE_first_tail_x15_r0_body.zpl35 : PRE_first_tail_x15_r0_body.pl35.all (Nat.ble PRE_first_tail_x15_r0_body.s313.next) = true
kernel_rfl PRE_first_tail_x15_r0_body.zplnd35 : nodupT PRE_first_tail_x15_r0_body.pl35 PTrie.nil = true
kernel_rfl PRE_first_tail_x15_r0_body.zn135 : Nat.ble PRE_first_tail_x15_r0_body.s313.next 2702225 = true
kernel_rfl PRE_first_tail_x15_r0_body.zfirst35 : Nat.ble aFirst PRE_first_tail_x15_r0_body.s313.next = true
kernel_rfl PRE_first_tail_x15_r0_body.zscn35 : PRE_first_tail_x15_r0_body.s315.next = PRE_first_tail_x15_r0_body.s313.next + PRE_first_tail_x15_r0_body.pl35.length
kernel_rfl PRE_first_tail_x15_r0_body.zsmn35 : PRE_first_tail_x15_r0_body.s314.next = 2702225
kernel_rfl PRE_first_tail_x15_r0_body.zgrow35 : Nat.ble PRE_first_tail_x15_r0_body.s315.next PRE_first_tail_x15_r0_body.s314.next = true
-- the tables
kernel_rfl PRE_first_tail_x15_r0_body.zfresh35 : PRE_first_tail_x15_r0_body.S313.tab.all (fun e => PRE_first_tail_x15_r0_body.cws35.all fun v => e.noVar v) = true
kernel_rfl PRE_first_tail_x15_r0_body.zcnd35 : nodupT PRE_first_tail_x15_r0_body.cws35 PTrie.nil = true
kernel_rfl PRE_first_tail_x15_r0_body.znrHi35 : PRE_first_tail_x15_r0_body.nr35.all (fun r => Nat.blt r PRE_first_tail_x15_r0_body.S314.tab.length) = true
-- the frames: every framed address below the call's counter; the kept arrays the chain start's, extended in the merged state
kernel_rfl PRE_first_tail_x15_r0_body.zfrlt35 : [2665, 2673467, 2673472, 2673473].all (fun a => Nat.blt a PRE_first_tail_x15_r0_body.s313.next) = true
kernel_rfl PRE_first_tail_x15_r0_body.zg35_2665 : PRE_first_tail_x15_r0_body.s315.heap.get 2665 = some (.obj (objOf PRE_first_tail_x15_r0_body.s315 2665))
kernel_rfl PRE_first_tail_x15_r0_body.zk35_2665 : (objOf PRE_first_tail_x15_r0_body.s315 2665).kind = .array (arrOf PRE_first_tail_x15_r0_body.s0 2665)
kernel_rfl PRE_first_tail_x15_r0_body.zm35_2665 : PRE_first_tail_x15_r0_body.s314.heap.get 2665 = some (.obj { PRE_first_tail_x15_r0_body.kappa35.obj (objOf PRE_first_tail_x15_r0_body.s315 2665) with
  kind := .array (arrOf PRE_first_tail_x15_r0_body.s0 2665 ++ (arrOf PRE_first_tail_x15_r0_body.s314 2665).drop (arrOf PRE_first_tail_x15_r0_body.s0 2665).length) })
kernel_rfl PRE_first_tail_x15_r0_body.zg35_2673467 : PRE_first_tail_x15_r0_body.s315.heap.get 2673467 = some (.obj (objOf PRE_first_tail_x15_r0_body.s315 2673467))
kernel_rfl PRE_first_tail_x15_r0_body.zk35_2673467 : (objOf PRE_first_tail_x15_r0_body.s315 2673467).kind = .array (arrOf PRE_first_tail_x15_r0_body.s0 2673467)
kernel_rfl PRE_first_tail_x15_r0_body.zm35_2673467 : PRE_first_tail_x15_r0_body.s314.heap.get 2673467 = some (.obj { PRE_first_tail_x15_r0_body.kappa35.obj (objOf PRE_first_tail_x15_r0_body.s315 2673467) with
  kind := .array (arrOf PRE_first_tail_x15_r0_body.s0 2673467 ++ (arrOf PRE_first_tail_x15_r0_body.s314 2673467).drop (arrOf PRE_first_tail_x15_r0_body.s0 2673467).length) })
kernel_rfl PRE_first_tail_x15_r0_body.zw35_4910 : (PRE_first_tail_x15_r0_body.s315.heap.get 4910).isSome = true
kernel_rfl PRE_first_tail_x15_r0_body.zw35_2673472 : (PRE_first_tail_x15_r0_body.s315.heap.get 2673472).isSome = true
kernel_rfl PRE_first_tail_x15_r0_body.zw35_2673473 : (PRE_first_tail_x15_r0_body.s315.heap.get 2673473).isSome = true
-- the heap: the changed list in range, holding the stage's written and fresh addresses; the canonical side's image
kernel_rfl PRE_first_tail_x15_r0_body.zclbd35 : PRE_first_tail_x15_r0_body.cl35.all (fun b => Nat.blt (b / 4096) (4 ^ 31)) = true
kernel_rfl PRE_first_tail_x15_r0_body.zwr35 : PRE_first_tail_x15_r0_body.st35.wr.all (fun b => !Nat.blt b PRE_first_tail_x15_r0_body.s313.next || PRE_first_tail_x15_r0_body.cl35.contains b) = true
def PRE_first_tail_x15_r0_body.zl35 : List Nat := PRE_first_tail_x15_r0_body.cl35.filter fun a => !(List.contains [2665, 2673467] a)
kernel_rfl PRE_first_tail_x15_r0_body.zimgE35 : PRE_first_tail_x15_r0_body.zl35.map (fun a => PRE_first_tail_x15_r0_body.s314.heap.get (PRE_first_tail_x15_r0_body.kappa35.a a)) = PRE_first_tail_x15_r0_body.zl35.map (fun a => (PRE_first_tail_x15_r0_body.s315.heap.get a).map PRE_first_tail_x15_r0_body.kappa35.hobj)
theorem PRE_first_tail_x15_r0_body.zimg35 : HeapImg PRE_first_tail_x15_r0_body.kappa35 PRE_first_tail_x15_r0_body.s315 PRE_first_tail_x15_r0_body.s314 PRE_first_tail_x15_r0_body.zl35 := PRE_first_tail_x15_r0_body.zimgE35
-- the roots and their supports
kernel_rfl PRE_first_tail_x15_r0_body.zctl35 : PRE_first_tail_x15_r0_body.s314.ctl = PRE_first_tail_x15_r0_body.kappa35.ctl PRE_first_tail_x15_r0_body.s315.ctl
kernel_rfl PRE_first_tail_x15_r0_body.zstack35 : PRE_first_tail_x15_r0_body.s314.stack = PRE_first_tail_x15_r0_body.s315.stack.map PRE_first_tail_x15_r0_body.kappa35.frame
kernel_rfl PRE_first_tail_x15_r0_body.zjobs35 : PRE_first_tail_x15_r0_body.s314.jobs = PRE_first_tail_x15_r0_body.s315.jobs.map PRE_first_tail_x15_r0_body.kappa35.job
kernel_rfl PRE_first_tail_x15_r0_body.zstores35 : PRE_first_tail_x15_r0_body.s314.stores = PRE_first_tail_x15_r0_body.kappa35.stores PRE_first_tail_x15_r0_body.s315.stores
kernel_rfl PRE_first_tail_x15_r0_body.zroots35 : checkRootsSupp PRE_first_tail_x15_r0_body.s315 1549 = true
kernel_rfl PRE_first_tail_x15_r0_body.znC35 : PRE_first_tail_x15_r0_body.S313.tab.length + PRE_first_tail_x15_r0_body.cws35.length = 1549
-- the map as `Conv.compact_shift` states it (the call's counters for the literals)
kernel_rfl PRE_first_tail_x15_r0_body.zkap35 : PRE_first_tail_x15_r0_body.kappa35 = Conv.Map.compact PRE_first_tail_x15_r0_body.s313.next 2702225 PRE_first_tail_x15_r0_body.S313.tab.length PRE_first_tail_x15_r0_body.pl35 (PRE_first_tail_x15_r0_body.nr35.map NumV.ref) PRE_first_tail_x15_r0_body.kd35.big
  PRE_first_tail_x15_r0_body.kd35.region PRE_first_tail_x15_r0_body.kd35.nodeF
-- the bridge inactive at the canonical state (`Conv.FullShiftQ.toX`; the merged state's bridge is the canonical's: cbridge)
theorem PRE_first_tail_x15_r0_body.zbin35 : (Host.Ts.Sim.Full.bridgeOf PRE_first_tail_x15_r0_body.s315.ffi).active = false := (Host.Load.Boot.replay_active Host.Load.Run.Prompt.P.oblog2818)
-- the JS bookkeeping's step (`Conv.JClean.step` over the changed list) and the canonical roots' bigint freedom
kernel_rfl PRE_first_tail_x15_r0_body.zjc35 : Conv.jcleanListB (⟨18889, 15970, 2702206, 1549⟩ : Conv.Cnt) PRE_first_tail_x15_r0_body.s315 PRE_first_tail_x15_r0_body.cl35 = true
kernel_rfl PRE_first_tail_x15_r0_body.zroots235 : noBigRootsP (fun i => !Conv.oldBigB (⟨18889, 15970, 2702206, 1549⟩ : Conv.Cnt) i) PRE_first_tail_x15_r0_body.s315.trace PRE_first_tail_x15_r0_body.s315 = true
kernel_rfl PRE_first_tail_x15_r0_body.zhm35 : Nat.ble (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s0.ffi).mlx.nnext 15970 = true
theorem PRE_first_tail_x15_r0_body.cjcl35 (h : Conv.JClean (⟨18889, 15970, 2702205, 1549⟩ : Conv.Cnt) PRE_first_tail_x15_r0_body.s313) : Conv.JClean (⟨18889, 15970, 2702206, 1549⟩ : Conv.Cnt) PRE_first_tail_x15_r0_body.s315 :=
  Conv.JClean.step h (Conv.Cnt.le_of_leB PRE_first_tail_x15_r0_body.cle35)
    (Conv.heap_off_setAll PRE_first_tail_x15_r0_body.cheap35 fun a ha => Nat.blt_eq.mp (List.all_eq_true.mp PRE_first_tail_x15_r0_body.zclbd35 a ha)) PRE_first_tail_x15_r0_body.zjc35

end Host.Load.Run.Tpl
