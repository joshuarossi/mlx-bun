import host.sim.template.a4pre_first_tail_x15_r0_body.SiteS15
import host.sim.template.a4pre_first_tail_x15_r0_body.SiteK15
import host.sim.template.a4pre_first_tail_x15_r0_body.SiteF15
import host.sim.conv.CompactShift
import host.sim.template.Check
import host.sim.BigFreeP
import host.sim.template.CallGen
set_option Elab.async false
namespace Host.Load.Run.Tpl
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
open Host.Ts Host.Ts.Sim Host.Ts.Sim.Template

/-! The compaction's state shift at call site 15 of chain `PRE_first_tail_x15_r0_body` (`Conv.compact_shift`): the call `PRE_first_tail_x15_r0_body.s160`, the merged
state `PRE_first_tail_x15_r0_body.s161`, the canonical state `PRE_first_tail_x15_r0_body.s162`; its frames [2665,2673467,2673472,2673473] (kept arrays [2665,2673467]). -/

-- the map's places and counters
kernel_rfl PRE_first_tail_x15_r0_body.zpl15 : PRE_first_tail_x15_r0_body.pl15.all (Nat.ble PRE_first_tail_x15_r0_body.s160.next) = true
kernel_rfl PRE_first_tail_x15_r0_body.zplnd15 : nodupT PRE_first_tail_x15_r0_body.pl15 PTrie.nil = true
kernel_rfl PRE_first_tail_x15_r0_body.zn115 : Nat.ble PRE_first_tail_x15_r0_body.s160.next 2688286 = true
kernel_rfl PRE_first_tail_x15_r0_body.zfirst15 : Nat.ble aFirst PRE_first_tail_x15_r0_body.s160.next = true
kernel_rfl PRE_first_tail_x15_r0_body.zscn15 : PRE_first_tail_x15_r0_body.s162.next = PRE_first_tail_x15_r0_body.s160.next + PRE_first_tail_x15_r0_body.pl15.length
kernel_rfl PRE_first_tail_x15_r0_body.zsmn15 : PRE_first_tail_x15_r0_body.s161.next = 2688286
kernel_rfl PRE_first_tail_x15_r0_body.zgrow15 : Nat.ble PRE_first_tail_x15_r0_body.s162.next PRE_first_tail_x15_r0_body.s161.next = true
-- the tables
kernel_rfl PRE_first_tail_x15_r0_body.zfresh15 : PRE_first_tail_x15_r0_body.S160.tab.all (fun e => PRE_first_tail_x15_r0_body.cws15.all fun v => e.noVar v) = true
kernel_rfl PRE_first_tail_x15_r0_body.zcnd15 : nodupT PRE_first_tail_x15_r0_body.cws15 PTrie.nil = true
kernel_rfl PRE_first_tail_x15_r0_body.znrHi15 : PRE_first_tail_x15_r0_body.nr15.all (fun r => Nat.blt r PRE_first_tail_x15_r0_body.S161.tab.length) = true
-- the frames: every framed address below the call's counter; the kept arrays the chain start's, extended in the merged state
kernel_rfl PRE_first_tail_x15_r0_body.zfrlt15 : [2665, 2673467, 2673472, 2673473].all (fun a => Nat.blt a PRE_first_tail_x15_r0_body.s160.next) = true
kernel_rfl PRE_first_tail_x15_r0_body.zg15_2665 : PRE_first_tail_x15_r0_body.s162.heap.get 2665 = some (.obj (objOf PRE_first_tail_x15_r0_body.s162 2665))
kernel_rfl PRE_first_tail_x15_r0_body.zk15_2665 : (objOf PRE_first_tail_x15_r0_body.s162 2665).kind = .array (arrOf PRE_first_tail_x15_r0_body.s0 2665)
kernel_rfl PRE_first_tail_x15_r0_body.zm15_2665 : PRE_first_tail_x15_r0_body.s161.heap.get 2665 = some (.obj { PRE_first_tail_x15_r0_body.kappa15.obj (objOf PRE_first_tail_x15_r0_body.s162 2665) with
  kind := .array (arrOf PRE_first_tail_x15_r0_body.s0 2665 ++ (arrOf PRE_first_tail_x15_r0_body.s161 2665).drop (arrOf PRE_first_tail_x15_r0_body.s0 2665).length) })
kernel_rfl PRE_first_tail_x15_r0_body.zg15_2673467 : PRE_first_tail_x15_r0_body.s162.heap.get 2673467 = some (.obj (objOf PRE_first_tail_x15_r0_body.s162 2673467))
kernel_rfl PRE_first_tail_x15_r0_body.zk15_2673467 : (objOf PRE_first_tail_x15_r0_body.s162 2673467).kind = .array (arrOf PRE_first_tail_x15_r0_body.s0 2673467)
kernel_rfl PRE_first_tail_x15_r0_body.zm15_2673467 : PRE_first_tail_x15_r0_body.s161.heap.get 2673467 = some (.obj { PRE_first_tail_x15_r0_body.kappa15.obj (objOf PRE_first_tail_x15_r0_body.s162 2673467) with
  kind := .array (arrOf PRE_first_tail_x15_r0_body.s0 2673467 ++ (arrOf PRE_first_tail_x15_r0_body.s161 2673467).drop (arrOf PRE_first_tail_x15_r0_body.s0 2673467).length) })
kernel_rfl PRE_first_tail_x15_r0_body.zw15_4910 : (PRE_first_tail_x15_r0_body.s162.heap.get 4910).isSome = true
kernel_rfl PRE_first_tail_x15_r0_body.zw15_2673472 : (PRE_first_tail_x15_r0_body.s162.heap.get 2673472).isSome = true
kernel_rfl PRE_first_tail_x15_r0_body.zw15_2673473 : (PRE_first_tail_x15_r0_body.s162.heap.get 2673473).isSome = true
-- the heap: the changed list in range, holding the stage's written and fresh addresses; the canonical side's image
kernel_rfl PRE_first_tail_x15_r0_body.zclbd15 : PRE_first_tail_x15_r0_body.cl15.all (fun b => Nat.blt (b / 4096) (4 ^ 31)) = true
kernel_rfl PRE_first_tail_x15_r0_body.zwr15 : PRE_first_tail_x15_r0_body.st15.wr.all (fun b => !Nat.blt b PRE_first_tail_x15_r0_body.s160.next || PRE_first_tail_x15_r0_body.cl15.contains b) = true
def PRE_first_tail_x15_r0_body.zl15 : List Nat := PRE_first_tail_x15_r0_body.cl15.filter fun a => !(List.contains [2665, 2673467] a)
kernel_rfl PRE_first_tail_x15_r0_body.zimgE15 : PRE_first_tail_x15_r0_body.zl15.map (fun a => PRE_first_tail_x15_r0_body.s161.heap.get (PRE_first_tail_x15_r0_body.kappa15.a a)) = PRE_first_tail_x15_r0_body.zl15.map (fun a => (PRE_first_tail_x15_r0_body.s162.heap.get a).map PRE_first_tail_x15_r0_body.kappa15.hobj)
theorem PRE_first_tail_x15_r0_body.zimg15 : HeapImg PRE_first_tail_x15_r0_body.kappa15 PRE_first_tail_x15_r0_body.s162 PRE_first_tail_x15_r0_body.s161 PRE_first_tail_x15_r0_body.zl15 := PRE_first_tail_x15_r0_body.zimgE15
-- the roots and their supports
kernel_rfl PRE_first_tail_x15_r0_body.zctl15 : PRE_first_tail_x15_r0_body.s161.ctl = PRE_first_tail_x15_r0_body.kappa15.ctl PRE_first_tail_x15_r0_body.s162.ctl
kernel_rfl PRE_first_tail_x15_r0_body.zstack15 : PRE_first_tail_x15_r0_body.s161.stack = PRE_first_tail_x15_r0_body.s162.stack.map PRE_first_tail_x15_r0_body.kappa15.frame
kernel_rfl PRE_first_tail_x15_r0_body.zjobs15 : PRE_first_tail_x15_r0_body.s161.jobs = PRE_first_tail_x15_r0_body.s162.jobs.map PRE_first_tail_x15_r0_body.kappa15.job
kernel_rfl PRE_first_tail_x15_r0_body.zstores15 : PRE_first_tail_x15_r0_body.s161.stores = PRE_first_tail_x15_r0_body.kappa15.stores PRE_first_tail_x15_r0_body.s162.stores
kernel_rfl PRE_first_tail_x15_r0_body.zroots15 : checkRootsSupp PRE_first_tail_x15_r0_body.s162 743 = true
kernel_rfl PRE_first_tail_x15_r0_body.znC15 : PRE_first_tail_x15_r0_body.S160.tab.length + PRE_first_tail_x15_r0_body.cws15.length = 743
-- the map as `Conv.compact_shift` states it (the call's counters for the literals)
kernel_rfl PRE_first_tail_x15_r0_body.zkap15 : PRE_first_tail_x15_r0_body.kappa15 = Conv.Map.compact PRE_first_tail_x15_r0_body.s160.next 2688286 PRE_first_tail_x15_r0_body.S160.tab.length PRE_first_tail_x15_r0_body.pl15 (PRE_first_tail_x15_r0_body.nr15.map NumV.ref) PRE_first_tail_x15_r0_body.kd15.big
  PRE_first_tail_x15_r0_body.kd15.region PRE_first_tail_x15_r0_body.kd15.nodeF
-- the bridge inactive at the canonical state (`Conv.FullShiftQ.toX`; the merged state's bridge is the canonical's: cbridge)
theorem PRE_first_tail_x15_r0_body.zbin15 : (Host.Ts.Sim.Full.bridgeOf PRE_first_tail_x15_r0_body.s162.ffi).active = false := (Host.Load.Boot.replay_active Host.Load.Run.Prompt.P.oblog2818)
-- the JS bookkeeping's step (`Conv.JClean.step` over the changed list) and the canonical roots' bigint freedom
kernel_rfl PRE_first_tail_x15_r0_body.zjc15 : Conv.jcleanListB (⟨18512, 15605, 2687137, 743⟩ : Conv.Cnt) PRE_first_tail_x15_r0_body.s162 PRE_first_tail_x15_r0_body.cl15 = true
kernel_rfl PRE_first_tail_x15_r0_body.zrootsB15 : noBigRootsP (fun i => !Conv.oldBigB (⟨18512, 15605, 2687137, 743⟩ : Conv.Cnt) i) PRE_first_tail_x15_r0_body.s162.trace PRE_first_tail_x15_r0_body.s162 = true
kernel_rfl PRE_first_tail_x15_r0_body.zhm15 : Nat.ble (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s0.ffi).mlx.nnext 15578 = true
theorem PRE_first_tail_x15_r0_body.cjcl15 (h : Conv.JClean (⟨18509, 15578, 2687131, 725⟩ : Conv.Cnt) PRE_first_tail_x15_r0_body.s160) : Conv.JClean (⟨18512, 15605, 2687137, 743⟩ : Conv.Cnt) PRE_first_tail_x15_r0_body.s162 :=
  Conv.JClean.step h (Conv.Cnt.le_of_leB PRE_first_tail_x15_r0_body.cle15)
    (Conv.heap_off_setAll PRE_first_tail_x15_r0_body.cheap15 fun a ha => Nat.blt_eq.mp (List.all_eq_true.mp PRE_first_tail_x15_r0_body.zclbd15 a ha)) PRE_first_tail_x15_r0_body.zjc15

end Host.Load.Run.Tpl
