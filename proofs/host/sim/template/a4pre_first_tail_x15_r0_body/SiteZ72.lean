import host.sim.template.a4pre_first_tail_x15_r0_body.SiteS72
import host.sim.template.a4pre_first_tail_x15_r0_body.SiteK72
import host.sim.template.a4pre_first_tail_x15_r0_body.SiteF72
import host.sim.conv.CompactShift
import host.sim.template.Check
import host.sim.BigFreeP
import host.sim.template.CallGen
set_option Elab.async false
namespace Host.Load.Run.Tpl
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
open Host.Ts Host.Ts.Sim Host.Ts.Sim.Template

/-! The compaction's state shift at call site 72 of chain `PRE_first_tail_x15_r0_body` (`Conv.compact_shift`): the call `PRE_first_tail_x15_r0_body.s644`, the merged
state `PRE_first_tail_x15_r0_body.s645`, the canonical state `PRE_first_tail_x15_r0_body.s646`; its frames [2665,2673467,2673472,2673473] (kept arrays [2665,2673467]). -/

-- the map's places and counters
kernel_rfl PRE_first_tail_x15_r0_body.zpl72 : PRE_first_tail_x15_r0_body.pl72.all (Nat.ble PRE_first_tail_x15_r0_body.s644.next) = true
kernel_rfl PRE_first_tail_x15_r0_body.zplnd72 : nodupT PRE_first_tail_x15_r0_body.pl72 PTrie.nil = true
kernel_rfl PRE_first_tail_x15_r0_body.zn172 : Nat.ble PRE_first_tail_x15_r0_body.s644.next 2733114 = true
kernel_rfl PRE_first_tail_x15_r0_body.zfirst72 : Nat.ble aFirst PRE_first_tail_x15_r0_body.s644.next = true
kernel_rfl PRE_first_tail_x15_r0_body.zscn72 : PRE_first_tail_x15_r0_body.s646.next = PRE_first_tail_x15_r0_body.s644.next + PRE_first_tail_x15_r0_body.pl72.length
kernel_rfl PRE_first_tail_x15_r0_body.zsmn72 : PRE_first_tail_x15_r0_body.s645.next = 2733114
kernel_rfl PRE_first_tail_x15_r0_body.zgrow72 : Nat.ble PRE_first_tail_x15_r0_body.s646.next PRE_first_tail_x15_r0_body.s645.next = true
-- the tables
kernel_rfl PRE_first_tail_x15_r0_body.zfresh72 : PRE_first_tail_x15_r0_body.S644.tab.all (fun e => PRE_first_tail_x15_r0_body.cws72.all fun v => e.noVar v) = true
kernel_rfl PRE_first_tail_x15_r0_body.zcnd72 : nodupT PRE_first_tail_x15_r0_body.cws72 PTrie.nil = true
kernel_rfl PRE_first_tail_x15_r0_body.znrHi72 : PRE_first_tail_x15_r0_body.nr72.all (fun r => Nat.blt r PRE_first_tail_x15_r0_body.S645.tab.length) = true
-- the frames: every framed address below the call's counter; the kept arrays the chain start's, extended in the merged state
kernel_rfl PRE_first_tail_x15_r0_body.zfrlt72 : [2665, 2673467, 2673472, 2673473].all (fun a => Nat.blt a PRE_first_tail_x15_r0_body.s644.next) = true
kernel_rfl PRE_first_tail_x15_r0_body.zg72_2665 : PRE_first_tail_x15_r0_body.s646.heap.get 2665 = some (.obj (objOf PRE_first_tail_x15_r0_body.s646 2665))
kernel_rfl PRE_first_tail_x15_r0_body.zk72_2665 : (objOf PRE_first_tail_x15_r0_body.s646 2665).kind = .array (arrOf PRE_first_tail_x15_r0_body.s0 2665)
kernel_rfl PRE_first_tail_x15_r0_body.zm72_2665 : PRE_first_tail_x15_r0_body.s645.heap.get 2665 = some (.obj { PRE_first_tail_x15_r0_body.kappa72.obj (objOf PRE_first_tail_x15_r0_body.s646 2665) with
  kind := .array (arrOf PRE_first_tail_x15_r0_body.s0 2665 ++ (arrOf PRE_first_tail_x15_r0_body.s645 2665).drop (arrOf PRE_first_tail_x15_r0_body.s0 2665).length) })
kernel_rfl PRE_first_tail_x15_r0_body.zg72_2673467 : PRE_first_tail_x15_r0_body.s646.heap.get 2673467 = some (.obj (objOf PRE_first_tail_x15_r0_body.s646 2673467))
kernel_rfl PRE_first_tail_x15_r0_body.zk72_2673467 : (objOf PRE_first_tail_x15_r0_body.s646 2673467).kind = .array (arrOf PRE_first_tail_x15_r0_body.s0 2673467)
kernel_rfl PRE_first_tail_x15_r0_body.zm72_2673467 : PRE_first_tail_x15_r0_body.s645.heap.get 2673467 = some (.obj { PRE_first_tail_x15_r0_body.kappa72.obj (objOf PRE_first_tail_x15_r0_body.s646 2673467) with
  kind := .array (arrOf PRE_first_tail_x15_r0_body.s0 2673467 ++ (arrOf PRE_first_tail_x15_r0_body.s645 2673467).drop (arrOf PRE_first_tail_x15_r0_body.s0 2673467).length) })
kernel_rfl PRE_first_tail_x15_r0_body.zw72_4910 : (PRE_first_tail_x15_r0_body.s646.heap.get 4910).isSome = true
kernel_rfl PRE_first_tail_x15_r0_body.zw72_2673472 : (PRE_first_tail_x15_r0_body.s646.heap.get 2673472).isSome = true
kernel_rfl PRE_first_tail_x15_r0_body.zw72_2673473 : (PRE_first_tail_x15_r0_body.s646.heap.get 2673473).isSome = true
-- the heap: the changed list in range, holding the stage's written and fresh addresses; the canonical side's image
kernel_rfl PRE_first_tail_x15_r0_body.zclbd72 : PRE_first_tail_x15_r0_body.cl72.all (fun b => Nat.blt (b / 4096) (4 ^ 31)) = true
kernel_rfl PRE_first_tail_x15_r0_body.zwr72 : PRE_first_tail_x15_r0_body.st72.wr.all (fun b => !Nat.blt b PRE_first_tail_x15_r0_body.s644.next || PRE_first_tail_x15_r0_body.cl72.contains b) = true
def PRE_first_tail_x15_r0_body.zl72 : List Nat := PRE_first_tail_x15_r0_body.cl72.filter fun a => !(List.contains [2665, 2673467] a)
kernel_rfl PRE_first_tail_x15_r0_body.zimgE72 : PRE_first_tail_x15_r0_body.zl72.map (fun a => PRE_first_tail_x15_r0_body.s645.heap.get (PRE_first_tail_x15_r0_body.kappa72.a a)) = PRE_first_tail_x15_r0_body.zl72.map (fun a => (PRE_first_tail_x15_r0_body.s646.heap.get a).map PRE_first_tail_x15_r0_body.kappa72.hobj)
theorem PRE_first_tail_x15_r0_body.zimg72 : HeapImg PRE_first_tail_x15_r0_body.kappa72 PRE_first_tail_x15_r0_body.s646 PRE_first_tail_x15_r0_body.s645 PRE_first_tail_x15_r0_body.zl72 := PRE_first_tail_x15_r0_body.zimgE72
-- the roots and their supports
kernel_rfl PRE_first_tail_x15_r0_body.zctl72 : PRE_first_tail_x15_r0_body.s645.ctl = PRE_first_tail_x15_r0_body.kappa72.ctl PRE_first_tail_x15_r0_body.s646.ctl
kernel_rfl PRE_first_tail_x15_r0_body.zstack72 : PRE_first_tail_x15_r0_body.s645.stack = PRE_first_tail_x15_r0_body.s646.stack.map PRE_first_tail_x15_r0_body.kappa72.frame
kernel_rfl PRE_first_tail_x15_r0_body.zjobs72 : PRE_first_tail_x15_r0_body.s645.jobs = PRE_first_tail_x15_r0_body.s646.jobs.map PRE_first_tail_x15_r0_body.kappa72.job
kernel_rfl PRE_first_tail_x15_r0_body.zstores72 : PRE_first_tail_x15_r0_body.s645.stores = PRE_first_tail_x15_r0_body.kappa72.stores PRE_first_tail_x15_r0_body.s646.stores
kernel_rfl PRE_first_tail_x15_r0_body.zroots72 : checkRootsSupp PRE_first_tail_x15_r0_body.s646 3179 = true
kernel_rfl PRE_first_tail_x15_r0_body.znC72 : PRE_first_tail_x15_r0_body.S644.tab.length + PRE_first_tail_x15_r0_body.cws72.length = 3179
-- the map as `Conv.compact_shift` states it (the call's counters for the literals)
kernel_rfl PRE_first_tail_x15_r0_body.zkap72 : PRE_first_tail_x15_r0_body.kappa72 = Conv.Map.compact PRE_first_tail_x15_r0_body.s644.next 2733114 PRE_first_tail_x15_r0_body.S644.tab.length PRE_first_tail_x15_r0_body.pl72 (PRE_first_tail_x15_r0_body.nr72.map NumV.ref) PRE_first_tail_x15_r0_body.kd72.big
  PRE_first_tail_x15_r0_body.kd72.region PRE_first_tail_x15_r0_body.kd72.nodeF
-- the bridge inactive at the canonical state (`Conv.FullShiftQ.toX`; the merged state's bridge is the canonical's: cbridge)
theorem PRE_first_tail_x15_r0_body.zbin72 : (Host.Ts.Sim.Full.bridgeOf PRE_first_tail_x15_r0_body.s646.ffi).active = false := (Host.Load.Boot.replay_active Host.Load.Run.Prompt.P.oblog2818)
-- the JS bookkeeping's step (`Conv.JClean.step` over the changed list) and the canonical roots' bigint freedom
kernel_rfl PRE_first_tail_x15_r0_body.zjc72 : Conv.jcleanListB (⟨19635, 16727, 2731965, 3179⟩ : Conv.Cnt) PRE_first_tail_x15_r0_body.s646 PRE_first_tail_x15_r0_body.cl72 = true
kernel_rfl PRE_first_tail_x15_r0_body.zroots272 : noBigRootsP (fun i => !Conv.oldBigB (⟨19635, 16727, 2731965, 3179⟩ : Conv.Cnt) i) PRE_first_tail_x15_r0_body.s646.trace PRE_first_tail_x15_r0_body.s646 = true
kernel_rfl PRE_first_tail_x15_r0_body.zhm72 : Nat.ble (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s0.ffi).mlx.nnext 16700 = true
theorem PRE_first_tail_x15_r0_body.cjcl72 (h : Conv.JClean (⟨19632, 16700, 2731959, 3161⟩ : Conv.Cnt) PRE_first_tail_x15_r0_body.s644) : Conv.JClean (⟨19635, 16727, 2731965, 3179⟩ : Conv.Cnt) PRE_first_tail_x15_r0_body.s646 :=
  Conv.JClean.step h (Conv.Cnt.le_of_leB PRE_first_tail_x15_r0_body.cle72)
    (Conv.heap_off_setAll PRE_first_tail_x15_r0_body.cheap72 fun a ha => Nat.blt_eq.mp (List.all_eq_true.mp PRE_first_tail_x15_r0_body.zclbd72 a ha)) PRE_first_tail_x15_r0_body.zjc72

end Host.Load.Run.Tpl
