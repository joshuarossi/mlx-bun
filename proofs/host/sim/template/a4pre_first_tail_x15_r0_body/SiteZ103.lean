import host.sim.template.a4pre_first_tail_x15_r0_body.SiteS103
import host.sim.template.a4pre_first_tail_x15_r0_body.SiteK103
import host.sim.template.a4pre_first_tail_x15_r0_body.SiteF103
import host.sim.conv.CompactShift
import host.sim.template.Check
import host.sim.BigFreeP
import host.sim.template.CallGen
set_option Elab.async false
namespace Host.Load.Run.Tpl
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
open Host.Ts Host.Ts.Sim Host.Ts.Sim.Template

/-! The compaction's state shift at call site 103 of chain `PRE_first_tail_x15_r0_body` (`Conv.compact_shift`): the call `PRE_first_tail_x15_r0_body.s915`, the merged
state `PRE_first_tail_x15_r0_body.s916`, the canonical state `PRE_first_tail_x15_r0_body.s917`; its frames [2665,2673467,2673472,2673473] (kept arrays [2665,2673467]). -/

-- the map's places and counters
kernel_rfl PRE_first_tail_x15_r0_body.zpl103 : PRE_first_tail_x15_r0_body.pl103.all (Nat.ble PRE_first_tail_x15_r0_body.s915.next) = true
kernel_rfl PRE_first_tail_x15_r0_body.zplnd103 : nodupT PRE_first_tail_x15_r0_body.pl103 PTrie.nil = true
kernel_rfl PRE_first_tail_x15_r0_body.zn1103 : Nat.ble PRE_first_tail_x15_r0_body.s915.next 2755809 = true
kernel_rfl PRE_first_tail_x15_r0_body.zfirst103 : Nat.ble aFirst PRE_first_tail_x15_r0_body.s915.next = true
kernel_rfl PRE_first_tail_x15_r0_body.zscn103 : PRE_first_tail_x15_r0_body.s917.next = PRE_first_tail_x15_r0_body.s915.next + PRE_first_tail_x15_r0_body.pl103.length
kernel_rfl PRE_first_tail_x15_r0_body.zsmn103 : PRE_first_tail_x15_r0_body.s916.next = 2755809
kernel_rfl PRE_first_tail_x15_r0_body.zgrow103 : Nat.ble PRE_first_tail_x15_r0_body.s917.next PRE_first_tail_x15_r0_body.s916.next = true
-- the tables
kernel_rfl PRE_first_tail_x15_r0_body.zfresh103 : PRE_first_tail_x15_r0_body.S915.tab.all (fun e => PRE_first_tail_x15_r0_body.cws103.all fun v => e.noVar v) = true
kernel_rfl PRE_first_tail_x15_r0_body.zcnd103 : nodupT PRE_first_tail_x15_r0_body.cws103 PTrie.nil = true
kernel_rfl PRE_first_tail_x15_r0_body.znrHi103 : PRE_first_tail_x15_r0_body.nr103.all (fun r => Nat.blt r PRE_first_tail_x15_r0_body.S916.tab.length) = true
-- the frames: every framed address below the call's counter; the kept arrays the chain start's, extended in the merged state
kernel_rfl PRE_first_tail_x15_r0_body.zfrlt103 : [2665, 2673467, 2673472, 2673473].all (fun a => Nat.blt a PRE_first_tail_x15_r0_body.s915.next) = true
kernel_rfl PRE_first_tail_x15_r0_body.zg103_2665 : PRE_first_tail_x15_r0_body.s917.heap.get 2665 = some (.obj (objOf PRE_first_tail_x15_r0_body.s917 2665))
kernel_rfl PRE_first_tail_x15_r0_body.zk103_2665 : (objOf PRE_first_tail_x15_r0_body.s917 2665).kind = .array (arrOf PRE_first_tail_x15_r0_body.s0 2665)
kernel_rfl PRE_first_tail_x15_r0_body.zm103_2665 : PRE_first_tail_x15_r0_body.s916.heap.get 2665 = some (.obj { PRE_first_tail_x15_r0_body.kappa103.obj (objOf PRE_first_tail_x15_r0_body.s917 2665) with
  kind := .array (arrOf PRE_first_tail_x15_r0_body.s0 2665 ++ (arrOf PRE_first_tail_x15_r0_body.s916 2665).drop (arrOf PRE_first_tail_x15_r0_body.s0 2665).length) })
kernel_rfl PRE_first_tail_x15_r0_body.zg103_2673467 : PRE_first_tail_x15_r0_body.s917.heap.get 2673467 = some (.obj (objOf PRE_first_tail_x15_r0_body.s917 2673467))
kernel_rfl PRE_first_tail_x15_r0_body.zk103_2673467 : (objOf PRE_first_tail_x15_r0_body.s917 2673467).kind = .array (arrOf PRE_first_tail_x15_r0_body.s0 2673467)
kernel_rfl PRE_first_tail_x15_r0_body.zm103_2673467 : PRE_first_tail_x15_r0_body.s916.heap.get 2673467 = some (.obj { PRE_first_tail_x15_r0_body.kappa103.obj (objOf PRE_first_tail_x15_r0_body.s917 2673467) with
  kind := .array (arrOf PRE_first_tail_x15_r0_body.s0 2673467 ++ (arrOf PRE_first_tail_x15_r0_body.s916 2673467).drop (arrOf PRE_first_tail_x15_r0_body.s0 2673467).length) })
kernel_rfl PRE_first_tail_x15_r0_body.zw103_4910 : (PRE_first_tail_x15_r0_body.s917.heap.get 4910).isSome = true
kernel_rfl PRE_first_tail_x15_r0_body.zw103_2673472 : (PRE_first_tail_x15_r0_body.s917.heap.get 2673472).isSome = true
kernel_rfl PRE_first_tail_x15_r0_body.zw103_2673473 : (PRE_first_tail_x15_r0_body.s917.heap.get 2673473).isSome = true
-- the heap: the changed list in range, holding the stage's written and fresh addresses; the canonical side's image
kernel_rfl PRE_first_tail_x15_r0_body.zclbd103 : PRE_first_tail_x15_r0_body.cl103.all (fun b => Nat.blt (b / 4096) (4 ^ 31)) = true
kernel_rfl PRE_first_tail_x15_r0_body.zwr103 : PRE_first_tail_x15_r0_body.st103.wr.all (fun b => !Nat.blt b PRE_first_tail_x15_r0_body.s915.next || PRE_first_tail_x15_r0_body.cl103.contains b) = true
def PRE_first_tail_x15_r0_body.zl103 : List Nat := PRE_first_tail_x15_r0_body.cl103.filter fun a => !(List.contains [2665, 2673467] a)
kernel_rfl PRE_first_tail_x15_r0_body.zimgE103 : PRE_first_tail_x15_r0_body.zl103.map (fun a => PRE_first_tail_x15_r0_body.s916.heap.get (PRE_first_tail_x15_r0_body.kappa103.a a)) = PRE_first_tail_x15_r0_body.zl103.map (fun a => (PRE_first_tail_x15_r0_body.s917.heap.get a).map PRE_first_tail_x15_r0_body.kappa103.hobj)
theorem PRE_first_tail_x15_r0_body.zimg103 : HeapImg PRE_first_tail_x15_r0_body.kappa103 PRE_first_tail_x15_r0_body.s917 PRE_first_tail_x15_r0_body.s916 PRE_first_tail_x15_r0_body.zl103 := PRE_first_tail_x15_r0_body.zimgE103
-- the roots and their supports
kernel_rfl PRE_first_tail_x15_r0_body.zctl103 : PRE_first_tail_x15_r0_body.s916.ctl = PRE_first_tail_x15_r0_body.kappa103.ctl PRE_first_tail_x15_r0_body.s917.ctl
kernel_rfl PRE_first_tail_x15_r0_body.zstack103 : PRE_first_tail_x15_r0_body.s916.stack = PRE_first_tail_x15_r0_body.s917.stack.map PRE_first_tail_x15_r0_body.kappa103.frame
kernel_rfl PRE_first_tail_x15_r0_body.zjobs103 : PRE_first_tail_x15_r0_body.s916.jobs = PRE_first_tail_x15_r0_body.s917.jobs.map PRE_first_tail_x15_r0_body.kappa103.job
kernel_rfl PRE_first_tail_x15_r0_body.zstores103 : PRE_first_tail_x15_r0_body.s916.stores = PRE_first_tail_x15_r0_body.kappa103.stores PRE_first_tail_x15_r0_body.s917.stores
kernel_rfl PRE_first_tail_x15_r0_body.zroots103 : checkRootsSupp PRE_first_tail_x15_r0_body.s917 4484 = true
kernel_rfl PRE_first_tail_x15_r0_body.znC103 : PRE_first_tail_x15_r0_body.S915.tab.length + PRE_first_tail_x15_r0_body.cws103.length = 4484
-- the map as `Conv.compact_shift` states it (the call's counters for the literals)
kernel_rfl PRE_first_tail_x15_r0_body.zkap103 : PRE_first_tail_x15_r0_body.kappa103 = Conv.Map.compact PRE_first_tail_x15_r0_body.s915.next 2755809 PRE_first_tail_x15_r0_body.S915.tab.length PRE_first_tail_x15_r0_body.pl103 (PRE_first_tail_x15_r0_body.nr103.map NumV.ref) PRE_first_tail_x15_r0_body.kd103.big
  PRE_first_tail_x15_r0_body.kd103.region PRE_first_tail_x15_r0_body.kd103.nodeF
-- the bridge inactive at the canonical state (`Conv.FullShiftQ.toX`; the merged state's bridge is the canonical's: cbridge)
theorem PRE_first_tail_x15_r0_body.zbin103 : (Host.Ts.Sim.Full.bridgeOf PRE_first_tail_x15_r0_body.s917.ffi).active = false := (Host.Load.Boot.replay_active Host.Load.Run.Prompt.P.oblog2818)
-- the JS bookkeeping's step (`Conv.JClean.step` over the changed list) and the canonical roots' bigint freedom
kernel_rfl PRE_first_tail_x15_r0_body.zjc103 : Conv.jcleanListB (⟨20234, 17340, 2755807, 4484⟩ : Conv.Cnt) PRE_first_tail_x15_r0_body.s917 PRE_first_tail_x15_r0_body.cl103 = true
kernel_rfl PRE_first_tail_x15_r0_body.zroots2103 : noBigRootsP (fun i => !Conv.oldBigB (⟨20234, 17340, 2755807, 4484⟩ : Conv.Cnt) i) PRE_first_tail_x15_r0_body.s917.trace PRE_first_tail_x15_r0_body.s917 = true
kernel_rfl PRE_first_tail_x15_r0_body.zhm103 : Nat.ble (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s0.ffi).mlx.nnext 17340 = true
theorem PRE_first_tail_x15_r0_body.cjcl103 (h : Conv.JClean (⟨20234, 17340, 2755807, 4484⟩ : Conv.Cnt) PRE_first_tail_x15_r0_body.s915) : Conv.JClean (⟨20234, 17340, 2755807, 4484⟩ : Conv.Cnt) PRE_first_tail_x15_r0_body.s917 :=
  Conv.JClean.step h (Conv.Cnt.le_of_leB PRE_first_tail_x15_r0_body.cle103)
    (Conv.heap_off_setAll PRE_first_tail_x15_r0_body.cheap103 fun a ha => Nat.blt_eq.mp (List.all_eq_true.mp PRE_first_tail_x15_r0_body.zclbd103 a ha)) PRE_first_tail_x15_r0_body.zjc103

end Host.Load.Run.Tpl
