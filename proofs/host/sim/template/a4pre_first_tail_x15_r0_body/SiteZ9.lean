import host.sim.template.a4pre_first_tail_x15_r0_body.SiteS9
import host.sim.template.a4pre_first_tail_x15_r0_body.SiteK9
import host.sim.template.a4pre_first_tail_x15_r0_body.SiteF9
import host.sim.conv.CompactShift
import host.sim.template.Check
import host.sim.BigFreeP
import host.sim.template.CallGen
set_option Elab.async false
namespace Host.Load.Run.Tpl
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
open Host.Ts Host.Ts.Sim Host.Ts.Sim.Template

/-! The compaction's state shift at call site 9 of chain `PRE_first_tail_x15_r0_body` (`Conv.compact_shift`): the call `PRE_first_tail_x15_r0_body.s102`, the merged
state `PRE_first_tail_x15_r0_body.s103`, the canonical state `PRE_first_tail_x15_r0_body.s104`; its frames [2665,2673467,2673472,2673473] (kept arrays [2665,2673467]). -/

-- the map's places and counters
kernel_rfl PRE_first_tail_x15_r0_body.zpl9 : PRE_first_tail_x15_r0_body.pl9.all (Nat.ble PRE_first_tail_x15_r0_body.s102.next) = true
kernel_rfl PRE_first_tail_x15_r0_body.zplnd9 : nodupT PRE_first_tail_x15_r0_body.pl9 PTrie.nil = true
kernel_rfl PRE_first_tail_x15_r0_body.zn19 : Nat.ble PRE_first_tail_x15_r0_body.s102.next 2682859 = true
kernel_rfl PRE_first_tail_x15_r0_body.zfirst9 : Nat.ble aFirst PRE_first_tail_x15_r0_body.s102.next = true
kernel_rfl PRE_first_tail_x15_r0_body.zscn9 : PRE_first_tail_x15_r0_body.s104.next = PRE_first_tail_x15_r0_body.s102.next + PRE_first_tail_x15_r0_body.pl9.length
kernel_rfl PRE_first_tail_x15_r0_body.zsmn9 : PRE_first_tail_x15_r0_body.s103.next = 2682859
kernel_rfl PRE_first_tail_x15_r0_body.zgrow9 : Nat.ble PRE_first_tail_x15_r0_body.s104.next PRE_first_tail_x15_r0_body.s103.next = true
-- the tables
kernel_rfl PRE_first_tail_x15_r0_body.zfresh9 : PRE_first_tail_x15_r0_body.S102.tab.all (fun e => PRE_first_tail_x15_r0_body.cws9.all fun v => e.noVar v) = true
kernel_rfl PRE_first_tail_x15_r0_body.zcnd9 : nodupT PRE_first_tail_x15_r0_body.cws9 PTrie.nil = true
kernel_rfl PRE_first_tail_x15_r0_body.znrHi9 : PRE_first_tail_x15_r0_body.nr9.all (fun r => Nat.blt r PRE_first_tail_x15_r0_body.S103.tab.length) = true
-- the frames: every framed address below the call's counter; the kept arrays the chain start's, extended in the merged state
kernel_rfl PRE_first_tail_x15_r0_body.zfrlt9 : [2665, 2673467, 2673472, 2673473].all (fun a => Nat.blt a PRE_first_tail_x15_r0_body.s102.next) = true
kernel_rfl PRE_first_tail_x15_r0_body.zg9_2665 : PRE_first_tail_x15_r0_body.s104.heap.get 2665 = some (.obj (objOf PRE_first_tail_x15_r0_body.s104 2665))
kernel_rfl PRE_first_tail_x15_r0_body.zk9_2665 : (objOf PRE_first_tail_x15_r0_body.s104 2665).kind = .array (arrOf PRE_first_tail_x15_r0_body.s0 2665)
kernel_rfl PRE_first_tail_x15_r0_body.zm9_2665 : PRE_first_tail_x15_r0_body.s103.heap.get 2665 = some (.obj { PRE_first_tail_x15_r0_body.kappa9.obj (objOf PRE_first_tail_x15_r0_body.s104 2665) with
  kind := .array (arrOf PRE_first_tail_x15_r0_body.s0 2665 ++ (arrOf PRE_first_tail_x15_r0_body.s103 2665).drop (arrOf PRE_first_tail_x15_r0_body.s0 2665).length) })
kernel_rfl PRE_first_tail_x15_r0_body.zg9_2673467 : PRE_first_tail_x15_r0_body.s104.heap.get 2673467 = some (.obj (objOf PRE_first_tail_x15_r0_body.s104 2673467))
kernel_rfl PRE_first_tail_x15_r0_body.zk9_2673467 : (objOf PRE_first_tail_x15_r0_body.s104 2673467).kind = .array (arrOf PRE_first_tail_x15_r0_body.s0 2673467)
kernel_rfl PRE_first_tail_x15_r0_body.zm9_2673467 : PRE_first_tail_x15_r0_body.s103.heap.get 2673467 = some (.obj { PRE_first_tail_x15_r0_body.kappa9.obj (objOf PRE_first_tail_x15_r0_body.s104 2673467) with
  kind := .array (arrOf PRE_first_tail_x15_r0_body.s0 2673467 ++ (arrOf PRE_first_tail_x15_r0_body.s103 2673467).drop (arrOf PRE_first_tail_x15_r0_body.s0 2673467).length) })
kernel_rfl PRE_first_tail_x15_r0_body.zw9_4910 : (PRE_first_tail_x15_r0_body.s104.heap.get 4910).isSome = true
kernel_rfl PRE_first_tail_x15_r0_body.zw9_2673472 : (PRE_first_tail_x15_r0_body.s104.heap.get 2673472).isSome = true
kernel_rfl PRE_first_tail_x15_r0_body.zw9_2673473 : (PRE_first_tail_x15_r0_body.s104.heap.get 2673473).isSome = true
-- the heap: the changed list in range, holding the stage's written and fresh addresses; the canonical side's image
kernel_rfl PRE_first_tail_x15_r0_body.zclbd9 : PRE_first_tail_x15_r0_body.cl9.all (fun b => Nat.blt (b / 4096) (4 ^ 31)) = true
kernel_rfl PRE_first_tail_x15_r0_body.zwr9 : PRE_first_tail_x15_r0_body.st9.wr.all (fun b => !Nat.blt b PRE_first_tail_x15_r0_body.s102.next || PRE_first_tail_x15_r0_body.cl9.contains b) = true
def PRE_first_tail_x15_r0_body.zl9 : List Nat := PRE_first_tail_x15_r0_body.cl9.filter fun a => !(List.contains [2665, 2673467] a)
kernel_rfl PRE_first_tail_x15_r0_body.zimgE9 : PRE_first_tail_x15_r0_body.zl9.map (fun a => PRE_first_tail_x15_r0_body.s103.heap.get (PRE_first_tail_x15_r0_body.kappa9.a a)) = PRE_first_tail_x15_r0_body.zl9.map (fun a => (PRE_first_tail_x15_r0_body.s104.heap.get a).map PRE_first_tail_x15_r0_body.kappa9.hobj)
theorem PRE_first_tail_x15_r0_body.zimg9 : HeapImg PRE_first_tail_x15_r0_body.kappa9 PRE_first_tail_x15_r0_body.s104 PRE_first_tail_x15_r0_body.s103 PRE_first_tail_x15_r0_body.zl9 := PRE_first_tail_x15_r0_body.zimgE9
-- the roots and their supports
kernel_rfl PRE_first_tail_x15_r0_body.zctl9 : PRE_first_tail_x15_r0_body.s103.ctl = PRE_first_tail_x15_r0_body.kappa9.ctl PRE_first_tail_x15_r0_body.s104.ctl
kernel_rfl PRE_first_tail_x15_r0_body.zstack9 : PRE_first_tail_x15_r0_body.s103.stack = PRE_first_tail_x15_r0_body.s104.stack.map PRE_first_tail_x15_r0_body.kappa9.frame
kernel_rfl PRE_first_tail_x15_r0_body.zjobs9 : PRE_first_tail_x15_r0_body.s103.jobs = PRE_first_tail_x15_r0_body.s104.jobs.map PRE_first_tail_x15_r0_body.kappa9.job
kernel_rfl PRE_first_tail_x15_r0_body.zstores9 : PRE_first_tail_x15_r0_body.s103.stores = PRE_first_tail_x15_r0_body.kappa9.stores PRE_first_tail_x15_r0_body.s104.stores
kernel_rfl PRE_first_tail_x15_r0_body.zroots9 : checkRootsSupp PRE_first_tail_x15_r0_body.s104 483 = true
kernel_rfl PRE_first_tail_x15_r0_body.znC9 : PRE_first_tail_x15_r0_body.S102.tab.length + PRE_first_tail_x15_r0_body.cws9.length = 483
-- the map as `Conv.compact_shift` states it (the call's counters for the literals)
kernel_rfl PRE_first_tail_x15_r0_body.zkap9 : PRE_first_tail_x15_r0_body.kappa9 = Conv.Map.compact PRE_first_tail_x15_r0_body.s102.next 2682859 PRE_first_tail_x15_r0_body.S102.tab.length PRE_first_tail_x15_r0_body.pl9 (PRE_first_tail_x15_r0_body.nr9.map NumV.ref) PRE_first_tail_x15_r0_body.kd9.big
  PRE_first_tail_x15_r0_body.kd9.region PRE_first_tail_x15_r0_body.kd9.nodeF
-- the bridge inactive at the canonical state (`Conv.FullShiftQ.toX`; the merged state's bridge is the canonical's: cbridge)
theorem PRE_first_tail_x15_r0_body.zbin9 : (Host.Ts.Sim.Full.bridgeOf PRE_first_tail_x15_r0_body.s104.ffi).active = false := (Host.Load.Boot.replay_active Host.Load.Run.Prompt.P.oblog2818)
-- the JS bookkeeping's step (`Conv.JClean.step` over the changed list) and the canonical roots' bigint freedom
kernel_rfl PRE_first_tail_x15_r0_body.zjc9 : Conv.jcleanListB (⟨18397, 15482, 2682509, 483⟩ : Conv.Cnt) PRE_first_tail_x15_r0_body.s104 PRE_first_tail_x15_r0_body.cl9 = true
kernel_rfl PRE_first_tail_x15_r0_body.zrootsB9 : noBigRootsP (fun i => !Conv.oldBigB (⟨18397, 15482, 2682509, 483⟩ : Conv.Cnt) i) PRE_first_tail_x15_r0_body.s104.trace PRE_first_tail_x15_r0_body.s104 = true
kernel_rfl PRE_first_tail_x15_r0_body.zhm9 : Nat.ble (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s0.ffi).mlx.nnext 15476 = true
theorem PRE_first_tail_x15_r0_body.cjcl9 (h : Conv.JClean (⟨18393, 15476, 2682494, 474⟩ : Conv.Cnt) PRE_first_tail_x15_r0_body.s102) : Conv.JClean (⟨18397, 15482, 2682509, 483⟩ : Conv.Cnt) PRE_first_tail_x15_r0_body.s104 :=
  Conv.JClean.step h (Conv.Cnt.le_of_leB PRE_first_tail_x15_r0_body.cle9)
    (Conv.heap_off_setAll PRE_first_tail_x15_r0_body.cheap9 fun a ha => Nat.blt_eq.mp (List.all_eq_true.mp PRE_first_tail_x15_r0_body.zclbd9 a ha)) PRE_first_tail_x15_r0_body.zjc9

end Host.Load.Run.Tpl
