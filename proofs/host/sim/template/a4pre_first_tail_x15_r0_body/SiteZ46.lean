import host.sim.template.a4pre_first_tail_x15_r0_body.SiteS46
import host.sim.template.a4pre_first_tail_x15_r0_body.SiteK46
import host.sim.template.a4pre_first_tail_x15_r0_body.SiteF46
import host.sim.conv.CompactShift
import host.sim.template.Check
import host.sim.BigFreeP
import host.sim.template.CallGen
set_option Elab.async false
namespace Host.Load.Run.Tpl
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
open Host.Ts Host.Ts.Sim Host.Ts.Sim.Template

/-! The compaction's state shift at call site 46 of chain `PRE_first_tail_x15_r0_body` (`Conv.compact_shift`): the call `PRE_first_tail_x15_r0_body.s455`, the merged
state `PRE_first_tail_x15_r0_body.s456`, the canonical state `PRE_first_tail_x15_r0_body.s457`; its frames [2665,2673467,2673472,2673473] (kept arrays [2665,2673467]). -/

-- the map's places and counters
kernel_rfl PRE_first_tail_x15_r0_body.zpl46 : PRE_first_tail_x15_r0_body.pl46.all (Nat.ble PRE_first_tail_x15_r0_body.s455.next) = true
kernel_rfl PRE_first_tail_x15_r0_body.zplnd46 : nodupT PRE_first_tail_x15_r0_body.pl46 PTrie.nil = true
kernel_rfl PRE_first_tail_x15_r0_body.zn146 : Nat.ble PRE_first_tail_x15_r0_body.s455.next 2711339 = true
kernel_rfl PRE_first_tail_x15_r0_body.zfirst46 : Nat.ble aFirst PRE_first_tail_x15_r0_body.s455.next = true
kernel_rfl PRE_first_tail_x15_r0_body.zscn46 : PRE_first_tail_x15_r0_body.s457.next = PRE_first_tail_x15_r0_body.s455.next + PRE_first_tail_x15_r0_body.pl46.length
kernel_rfl PRE_first_tail_x15_r0_body.zsmn46 : PRE_first_tail_x15_r0_body.s456.next = 2711339
kernel_rfl PRE_first_tail_x15_r0_body.zgrow46 : Nat.ble PRE_first_tail_x15_r0_body.s457.next PRE_first_tail_x15_r0_body.s456.next = true
-- the tables
kernel_rfl PRE_first_tail_x15_r0_body.zfresh46 : PRE_first_tail_x15_r0_body.S455.tab.all (fun e => PRE_first_tail_x15_r0_body.cws46.all fun v => e.noVar v) = true
kernel_rfl PRE_first_tail_x15_r0_body.zcnd46 : nodupT PRE_first_tail_x15_r0_body.cws46 PTrie.nil = true
kernel_rfl PRE_first_tail_x15_r0_body.znrHi46 : PRE_first_tail_x15_r0_body.nr46.all (fun r => Nat.blt r PRE_first_tail_x15_r0_body.S456.tab.length) = true
-- the frames: every framed address below the call's counter; the kept arrays the chain start's, extended in the merged state
kernel_rfl PRE_first_tail_x15_r0_body.zfrlt46 : [2665, 2673467, 2673472, 2673473].all (fun a => Nat.blt a PRE_first_tail_x15_r0_body.s455.next) = true
kernel_rfl PRE_first_tail_x15_r0_body.zg46_2665 : PRE_first_tail_x15_r0_body.s457.heap.get 2665 = some (.obj (objOf PRE_first_tail_x15_r0_body.s457 2665))
kernel_rfl PRE_first_tail_x15_r0_body.zk46_2665 : (objOf PRE_first_tail_x15_r0_body.s457 2665).kind = .array (arrOf PRE_first_tail_x15_r0_body.s0 2665)
kernel_rfl PRE_first_tail_x15_r0_body.zm46_2665 : PRE_first_tail_x15_r0_body.s456.heap.get 2665 = some (.obj { PRE_first_tail_x15_r0_body.kappa46.obj (objOf PRE_first_tail_x15_r0_body.s457 2665) with
  kind := .array (arrOf PRE_first_tail_x15_r0_body.s0 2665 ++ (arrOf PRE_first_tail_x15_r0_body.s456 2665).drop (arrOf PRE_first_tail_x15_r0_body.s0 2665).length) })
kernel_rfl PRE_first_tail_x15_r0_body.zg46_2673467 : PRE_first_tail_x15_r0_body.s457.heap.get 2673467 = some (.obj (objOf PRE_first_tail_x15_r0_body.s457 2673467))
kernel_rfl PRE_first_tail_x15_r0_body.zk46_2673467 : (objOf PRE_first_tail_x15_r0_body.s457 2673467).kind = .array (arrOf PRE_first_tail_x15_r0_body.s0 2673467)
kernel_rfl PRE_first_tail_x15_r0_body.zm46_2673467 : PRE_first_tail_x15_r0_body.s456.heap.get 2673467 = some (.obj { PRE_first_tail_x15_r0_body.kappa46.obj (objOf PRE_first_tail_x15_r0_body.s457 2673467) with
  kind := .array (arrOf PRE_first_tail_x15_r0_body.s0 2673467 ++ (arrOf PRE_first_tail_x15_r0_body.s456 2673467).drop (arrOf PRE_first_tail_x15_r0_body.s0 2673467).length) })
kernel_rfl PRE_first_tail_x15_r0_body.zw46_4910 : (PRE_first_tail_x15_r0_body.s457.heap.get 4910).isSome = true
kernel_rfl PRE_first_tail_x15_r0_body.zw46_2673472 : (PRE_first_tail_x15_r0_body.s457.heap.get 2673472).isSome = true
kernel_rfl PRE_first_tail_x15_r0_body.zw46_2673473 : (PRE_first_tail_x15_r0_body.s457.heap.get 2673473).isSome = true
-- the heap: the changed list in range, holding the stage's written and fresh addresses; the canonical side's image
kernel_rfl PRE_first_tail_x15_r0_body.zclbd46 : PRE_first_tail_x15_r0_body.cl46.all (fun b => Nat.blt (b / 4096) (4 ^ 31)) = true
kernel_rfl PRE_first_tail_x15_r0_body.zwr46 : PRE_first_tail_x15_r0_body.st46.wr.all (fun b => !Nat.blt b PRE_first_tail_x15_r0_body.s455.next || PRE_first_tail_x15_r0_body.cl46.contains b) = true
def PRE_first_tail_x15_r0_body.zl46 : List Nat := PRE_first_tail_x15_r0_body.cl46.filter fun a => !(List.contains [2665, 2673467] a)
kernel_rfl PRE_first_tail_x15_r0_body.zimgE46 : PRE_first_tail_x15_r0_body.zl46.map (fun a => PRE_first_tail_x15_r0_body.s456.heap.get (PRE_first_tail_x15_r0_body.kappa46.a a)) = PRE_first_tail_x15_r0_body.zl46.map (fun a => (PRE_first_tail_x15_r0_body.s457.heap.get a).map PRE_first_tail_x15_r0_body.kappa46.hobj)
theorem PRE_first_tail_x15_r0_body.zimg46 : HeapImg PRE_first_tail_x15_r0_body.kappa46 PRE_first_tail_x15_r0_body.s457 PRE_first_tail_x15_r0_body.s456 PRE_first_tail_x15_r0_body.zl46 := PRE_first_tail_x15_r0_body.zimgE46
-- the roots and their supports
kernel_rfl PRE_first_tail_x15_r0_body.zctl46 : PRE_first_tail_x15_r0_body.s456.ctl = PRE_first_tail_x15_r0_body.kappa46.ctl PRE_first_tail_x15_r0_body.s457.ctl
kernel_rfl PRE_first_tail_x15_r0_body.zstack46 : PRE_first_tail_x15_r0_body.s456.stack = PRE_first_tail_x15_r0_body.s457.stack.map PRE_first_tail_x15_r0_body.kappa46.frame
kernel_rfl PRE_first_tail_x15_r0_body.zjobs46 : PRE_first_tail_x15_r0_body.s456.jobs = PRE_first_tail_x15_r0_body.s457.jobs.map PRE_first_tail_x15_r0_body.kappa46.job
kernel_rfl PRE_first_tail_x15_r0_body.zstores46 : PRE_first_tail_x15_r0_body.s456.stores = PRE_first_tail_x15_r0_body.kappa46.stores PRE_first_tail_x15_r0_body.s457.stores
kernel_rfl PRE_first_tail_x15_r0_body.zroots46 : checkRootsSupp PRE_first_tail_x15_r0_body.s457 2045 = true
kernel_rfl PRE_first_tail_x15_r0_body.znC46 : PRE_first_tail_x15_r0_body.S455.tab.length + PRE_first_tail_x15_r0_body.cws46.length = 2045
-- the map as `Conv.compact_shift` states it (the call's counters for the literals)
kernel_rfl PRE_first_tail_x15_r0_body.zkap46 : PRE_first_tail_x15_r0_body.kappa46 = Conv.Map.compact PRE_first_tail_x15_r0_body.s455.next 2711339 PRE_first_tail_x15_r0_body.S455.tab.length PRE_first_tail_x15_r0_body.pl46 (PRE_first_tail_x15_r0_body.nr46.map NumV.ref) PRE_first_tail_x15_r0_body.kd46.big
  PRE_first_tail_x15_r0_body.kd46.region PRE_first_tail_x15_r0_body.kd46.nodeF
-- the bridge inactive at the canonical state (`Conv.FullShiftQ.toX`; the merged state's bridge is the canonical's: cbridge)
theorem PRE_first_tail_x15_r0_body.zbin46 : (Host.Ts.Sim.Full.bridgeOf PRE_first_tail_x15_r0_body.s457.ffi).active = false := (Host.Load.Boot.replay_active Host.Load.Run.Prompt.P.oblog2818)
-- the JS bookkeeping's step (`Conv.JClean.step` over the changed list) and the canonical roots' bigint freedom
kernel_rfl PRE_first_tail_x15_r0_body.zjc46 : Conv.jcleanListB (⟨19118, 16203, 2711337, 2045⟩ : Conv.Cnt) PRE_first_tail_x15_r0_body.s457 PRE_first_tail_x15_r0_body.cl46 = true
kernel_rfl PRE_first_tail_x15_r0_body.zrootsB46 : noBigRootsP (fun i => !Conv.oldBigB (⟨19118, 16203, 2711337, 2045⟩ : Conv.Cnt) i) PRE_first_tail_x15_r0_body.s457.trace PRE_first_tail_x15_r0_body.s457 = true
kernel_rfl PRE_first_tail_x15_r0_body.zhm46 : Nat.ble (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s0.ffi).mlx.nnext 16203 = true
theorem PRE_first_tail_x15_r0_body.cjcl46 (h : Conv.JClean (⟨19118, 16203, 2711337, 2045⟩ : Conv.Cnt) PRE_first_tail_x15_r0_body.s455) : Conv.JClean (⟨19118, 16203, 2711337, 2045⟩ : Conv.Cnt) PRE_first_tail_x15_r0_body.s457 :=
  Conv.JClean.step h (Conv.Cnt.le_of_leB PRE_first_tail_x15_r0_body.cle46)
    (Conv.heap_off_setAll PRE_first_tail_x15_r0_body.cheap46 fun a ha => Nat.blt_eq.mp (List.all_eq_true.mp PRE_first_tail_x15_r0_body.zclbd46 a ha)) PRE_first_tail_x15_r0_body.zjc46

end Host.Load.Run.Tpl
