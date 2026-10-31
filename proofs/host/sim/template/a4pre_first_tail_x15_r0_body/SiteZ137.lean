import host.sim.template.a4pre_first_tail_x15_r0_body.SiteS137
import host.sim.template.a4pre_first_tail_x15_r0_body.SiteK137
import host.sim.template.a4pre_first_tail_x15_r0_body.SiteF137
import host.sim.conv.CompactShift
import host.sim.template.Check
import host.sim.BigFreeP
import host.sim.template.CallGen
set_option Elab.async false
namespace Host.Load.Run.Tpl
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
open Host.Ts Host.Ts.Sim Host.Ts.Sim.Template

/-! The compaction's state shift at call site 137 of chain `PRE_first_tail_x15_r0_body` (`Conv.compact_shift`): the call `PRE_first_tail_x15_r0_body.s1322`, the merged
state `PRE_first_tail_x15_r0_body.s1323`, the canonical state `PRE_first_tail_x15_r0_body.s1324`; its frames [2665,2673467,2673472,2673473] (kept arrays [2665,2673467]). -/

-- the map's places and counters
kernel_rfl PRE_first_tail_x15_r0_body.zpl137 : PRE_first_tail_x15_r0_body.pl137.all (Nat.ble PRE_first_tail_x15_r0_body.s1322.next) = true
kernel_rfl PRE_first_tail_x15_r0_body.zplnd137 : nodupT PRE_first_tail_x15_r0_body.pl137 PTrie.nil = true
kernel_rfl PRE_first_tail_x15_r0_body.zn1137 : Nat.ble PRE_first_tail_x15_r0_body.s1322.next 2782095 = true
kernel_rfl PRE_first_tail_x15_r0_body.zfirst137 : Nat.ble aFirst PRE_first_tail_x15_r0_body.s1322.next = true
kernel_rfl PRE_first_tail_x15_r0_body.zscn137 : PRE_first_tail_x15_r0_body.s1324.next = PRE_first_tail_x15_r0_body.s1322.next + PRE_first_tail_x15_r0_body.pl137.length
kernel_rfl PRE_first_tail_x15_r0_body.zsmn137 : PRE_first_tail_x15_r0_body.s1323.next = 2782095
kernel_rfl PRE_first_tail_x15_r0_body.zgrow137 : Nat.ble PRE_first_tail_x15_r0_body.s1324.next PRE_first_tail_x15_r0_body.s1323.next = true
-- the tables
kernel_rfl PRE_first_tail_x15_r0_body.zfresh137 : PRE_first_tail_x15_r0_body.S1322.tab.all (fun e => PRE_first_tail_x15_r0_body.cws137.all fun v => e.noVar v) = true
kernel_rfl PRE_first_tail_x15_r0_body.zcnd137 : nodupT PRE_first_tail_x15_r0_body.cws137 PTrie.nil = true
kernel_rfl PRE_first_tail_x15_r0_body.znrHi137 : PRE_first_tail_x15_r0_body.nr137.all (fun r => Nat.blt r PRE_first_tail_x15_r0_body.S1323.tab.length) = true
-- the frames: every framed address below the call's counter; the kept arrays the chain start's, extended in the merged state
kernel_rfl PRE_first_tail_x15_r0_body.zfrlt137 : [2665, 2673467, 2673472, 2673473].all (fun a => Nat.blt a PRE_first_tail_x15_r0_body.s1322.next) = true
kernel_rfl PRE_first_tail_x15_r0_body.zg137_2665 : PRE_first_tail_x15_r0_body.s1324.heap.get 2665 = some (.obj (objOf PRE_first_tail_x15_r0_body.s1324 2665))
kernel_rfl PRE_first_tail_x15_r0_body.zk137_2665 : (objOf PRE_first_tail_x15_r0_body.s1324 2665).kind = .array (arrOf PRE_first_tail_x15_r0_body.s0 2665)
kernel_rfl PRE_first_tail_x15_r0_body.zm137_2665 : PRE_first_tail_x15_r0_body.s1323.heap.get 2665 = some (.obj { PRE_first_tail_x15_r0_body.kappa137.obj (objOf PRE_first_tail_x15_r0_body.s1324 2665) with
  kind := .array (arrOf PRE_first_tail_x15_r0_body.s0 2665 ++ (arrOf PRE_first_tail_x15_r0_body.s1323 2665).drop (arrOf PRE_first_tail_x15_r0_body.s0 2665).length) })
kernel_rfl PRE_first_tail_x15_r0_body.zg137_2673467 : PRE_first_tail_x15_r0_body.s1324.heap.get 2673467 = some (.obj (objOf PRE_first_tail_x15_r0_body.s1324 2673467))
kernel_rfl PRE_first_tail_x15_r0_body.zk137_2673467 : (objOf PRE_first_tail_x15_r0_body.s1324 2673467).kind = .array (arrOf PRE_first_tail_x15_r0_body.s0 2673467)
kernel_rfl PRE_first_tail_x15_r0_body.zm137_2673467 : PRE_first_tail_x15_r0_body.s1323.heap.get 2673467 = some (.obj { PRE_first_tail_x15_r0_body.kappa137.obj (objOf PRE_first_tail_x15_r0_body.s1324 2673467) with
  kind := .array (arrOf PRE_first_tail_x15_r0_body.s0 2673467 ++ (arrOf PRE_first_tail_x15_r0_body.s1323 2673467).drop (arrOf PRE_first_tail_x15_r0_body.s0 2673467).length) })
kernel_rfl PRE_first_tail_x15_r0_body.zw137_4910 : (PRE_first_tail_x15_r0_body.s1324.heap.get 4910).isSome = true
kernel_rfl PRE_first_tail_x15_r0_body.zw137_2673472 : (PRE_first_tail_x15_r0_body.s1324.heap.get 2673472).isSome = true
kernel_rfl PRE_first_tail_x15_r0_body.zw137_2673473 : (PRE_first_tail_x15_r0_body.s1324.heap.get 2673473).isSome = true
-- the heap: the changed list in range, holding the stage's written and fresh addresses; the canonical side's image
kernel_rfl PRE_first_tail_x15_r0_body.zclbd137 : PRE_first_tail_x15_r0_body.cl137.all (fun b => Nat.blt (b / 4096) (4 ^ 31)) = true
kernel_rfl PRE_first_tail_x15_r0_body.zwr137 : PRE_first_tail_x15_r0_body.st137.wr.all (fun b => !Nat.blt b PRE_first_tail_x15_r0_body.s1322.next || PRE_first_tail_x15_r0_body.cl137.contains b) = true
def PRE_first_tail_x15_r0_body.zl137 : List Nat := PRE_first_tail_x15_r0_body.cl137.filter fun a => !(List.contains [2665, 2673467] a)
kernel_rfl PRE_first_tail_x15_r0_body.zimgE137 : PRE_first_tail_x15_r0_body.zl137.map (fun a => PRE_first_tail_x15_r0_body.s1323.heap.get (PRE_first_tail_x15_r0_body.kappa137.a a)) = PRE_first_tail_x15_r0_body.zl137.map (fun a => (PRE_first_tail_x15_r0_body.s1324.heap.get a).map PRE_first_tail_x15_r0_body.kappa137.hobj)
theorem PRE_first_tail_x15_r0_body.zimg137 : HeapImg PRE_first_tail_x15_r0_body.kappa137 PRE_first_tail_x15_r0_body.s1324 PRE_first_tail_x15_r0_body.s1323 PRE_first_tail_x15_r0_body.zl137 := PRE_first_tail_x15_r0_body.zimgE137
-- the roots and their supports
kernel_rfl PRE_first_tail_x15_r0_body.zctl137 : PRE_first_tail_x15_r0_body.s1323.ctl = PRE_first_tail_x15_r0_body.kappa137.ctl PRE_first_tail_x15_r0_body.s1324.ctl
kernel_rfl PRE_first_tail_x15_r0_body.zstack137 : PRE_first_tail_x15_r0_body.s1323.stack = PRE_first_tail_x15_r0_body.s1324.stack.map PRE_first_tail_x15_r0_body.kappa137.frame
kernel_rfl PRE_first_tail_x15_r0_body.zjobs137 : PRE_first_tail_x15_r0_body.s1323.jobs = PRE_first_tail_x15_r0_body.s1324.jobs.map PRE_first_tail_x15_r0_body.kappa137.job
kernel_rfl PRE_first_tail_x15_r0_body.zstores137 : PRE_first_tail_x15_r0_body.s1323.stores = PRE_first_tail_x15_r0_body.kappa137.stores PRE_first_tail_x15_r0_body.s1324.stores
kernel_rfl PRE_first_tail_x15_r0_body.zroots137 : checkRootsSupp PRE_first_tail_x15_r0_body.s1324 5911 = true
kernel_rfl PRE_first_tail_x15_r0_body.znC137 : PRE_first_tail_x15_r0_body.S1322.tab.length + PRE_first_tail_x15_r0_body.cws137.length = 5911
-- the map as `Conv.compact_shift` states it (the call's counters for the literals)
kernel_rfl PRE_first_tail_x15_r0_body.zkap137 : PRE_first_tail_x15_r0_body.kappa137 = Conv.Map.compact PRE_first_tail_x15_r0_body.s1322.next 2782095 PRE_first_tail_x15_r0_body.S1322.tab.length PRE_first_tail_x15_r0_body.pl137 (PRE_first_tail_x15_r0_body.nr137.map NumV.ref) PRE_first_tail_x15_r0_body.kd137.big
  PRE_first_tail_x15_r0_body.kd137.region PRE_first_tail_x15_r0_body.kd137.nodeF
-- the bridge inactive at the canonical state (`Conv.FullShiftQ.toX`; the merged state's bridge is the canonical's: cbridge)
theorem PRE_first_tail_x15_r0_body.zbin137 : (Host.Ts.Sim.Full.bridgeOf PRE_first_tail_x15_r0_body.s1324.ffi).active = false := (Host.Load.Boot.replay_active Host.Load.Run.Prompt.P.oblog2818)
-- the JS bookkeeping's step (`Conv.JClean.step` over the changed list) and the canonical roots' bigint freedom
kernel_rfl PRE_first_tail_x15_r0_body.zjc137 : Conv.jcleanListB (⟨20892, 17992, 2782076, 5911⟩ : Conv.Cnt) PRE_first_tail_x15_r0_body.s1324 PRE_first_tail_x15_r0_body.cl137 = true
kernel_rfl PRE_first_tail_x15_r0_body.zrootsB137 : noBigRootsP (fun i => !Conv.oldBigB (⟨20892, 17992, 2782076, 5911⟩ : Conv.Cnt) i) PRE_first_tail_x15_r0_body.s1324.trace PRE_first_tail_x15_r0_body.s1324 = true
kernel_rfl PRE_first_tail_x15_r0_body.zhm137 : Nat.ble (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s0.ffi).mlx.nnext 17992 = true
theorem PRE_first_tail_x15_r0_body.cjcl137 (h : Conv.JClean (⟨20892, 17992, 2782075, 5911⟩ : Conv.Cnt) PRE_first_tail_x15_r0_body.s1322) : Conv.JClean (⟨20892, 17992, 2782076, 5911⟩ : Conv.Cnt) PRE_first_tail_x15_r0_body.s1324 :=
  Conv.JClean.step h (Conv.Cnt.le_of_leB PRE_first_tail_x15_r0_body.cle137)
    (Conv.heap_off_setAll PRE_first_tail_x15_r0_body.cheap137 fun a ha => Nat.blt_eq.mp (List.all_eq_true.mp PRE_first_tail_x15_r0_body.zclbd137 a ha)) PRE_first_tail_x15_r0_body.zjc137

end Host.Load.Run.Tpl
