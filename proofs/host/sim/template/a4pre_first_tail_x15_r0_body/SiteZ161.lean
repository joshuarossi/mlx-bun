import host.sim.template.a4pre_first_tail_x15_r0_body.SiteS161
import host.sim.template.a4pre_first_tail_x15_r0_body.SiteK161
import host.sim.template.a4pre_first_tail_x15_r0_body.SiteF161
import host.sim.conv.CompactShift
import host.sim.template.Check
import host.sim.BigFreeP
import host.sim.template.CallGen
set_option Elab.async false
namespace Host.Load.Run.Tpl
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
open Host.Ts Host.Ts.Sim Host.Ts.Sim.Template

/-! The compaction's state shift at call site 161 of chain `PRE_first_tail_x15_r0_body` (`Conv.compact_shift`): the call `PRE_first_tail_x15_r0_body.s1417`, the merged
state `PRE_first_tail_x15_r0_body.s1418`, the canonical state `PRE_first_tail_x15_r0_body.s1419`; its frames [2665,2673467,2673472,2673473] (kept arrays [2665,2673467]). -/

-- the map's places and counters
kernel_rfl PRE_first_tail_x15_r0_body.zpl161 : PRE_first_tail_x15_r0_body.pl161.all (Nat.ble PRE_first_tail_x15_r0_body.s1417.next) = true
kernel_rfl PRE_first_tail_x15_r0_body.zplnd161 : nodupT PRE_first_tail_x15_r0_body.pl161 PTrie.nil = true
kernel_rfl PRE_first_tail_x15_r0_body.zn1161 : Nat.ble PRE_first_tail_x15_r0_body.s1417.next 2800930 = true
kernel_rfl PRE_first_tail_x15_r0_body.zfirst161 : Nat.ble aFirst PRE_first_tail_x15_r0_body.s1417.next = true
kernel_rfl PRE_first_tail_x15_r0_body.zscn161 : PRE_first_tail_x15_r0_body.s1419.next = PRE_first_tail_x15_r0_body.s1417.next + PRE_first_tail_x15_r0_body.pl161.length
kernel_rfl PRE_first_tail_x15_r0_body.zsmn161 : PRE_first_tail_x15_r0_body.s1418.next = 2800930
kernel_rfl PRE_first_tail_x15_r0_body.zgrow161 : Nat.ble PRE_first_tail_x15_r0_body.s1419.next PRE_first_tail_x15_r0_body.s1418.next = true
-- the tables
kernel_rfl PRE_first_tail_x15_r0_body.zfresh161 : PRE_first_tail_x15_r0_body.S1417.tab.all (fun e => PRE_first_tail_x15_r0_body.cws161.all fun v => e.noVar v) = true
kernel_rfl PRE_first_tail_x15_r0_body.zcnd161 : nodupT PRE_first_tail_x15_r0_body.cws161 PTrie.nil = true
kernel_rfl PRE_first_tail_x15_r0_body.znrHi161 : PRE_first_tail_x15_r0_body.nr161.all (fun r => Nat.blt r PRE_first_tail_x15_r0_body.S1418.tab.length) = true
-- the frames: every framed address below the call's counter; the kept arrays the chain start's, extended in the merged state
kernel_rfl PRE_first_tail_x15_r0_body.zfrlt161 : [2665, 2673467, 2673472, 2673473].all (fun a => Nat.blt a PRE_first_tail_x15_r0_body.s1417.next) = true
kernel_rfl PRE_first_tail_x15_r0_body.zg161_2665 : PRE_first_tail_x15_r0_body.s1419.heap.get 2665 = some (.obj (objOf PRE_first_tail_x15_r0_body.s1419 2665))
kernel_rfl PRE_first_tail_x15_r0_body.zk161_2665 : (objOf PRE_first_tail_x15_r0_body.s1419 2665).kind = .array (arrOf PRE_first_tail_x15_r0_body.s0 2665)
kernel_rfl PRE_first_tail_x15_r0_body.zm161_2665 : PRE_first_tail_x15_r0_body.s1418.heap.get 2665 = some (.obj { PRE_first_tail_x15_r0_body.kappa161.obj (objOf PRE_first_tail_x15_r0_body.s1419 2665) with
  kind := .array (arrOf PRE_first_tail_x15_r0_body.s0 2665 ++ (arrOf PRE_first_tail_x15_r0_body.s1418 2665).drop (arrOf PRE_first_tail_x15_r0_body.s0 2665).length) })
kernel_rfl PRE_first_tail_x15_r0_body.zg161_2673467 : PRE_first_tail_x15_r0_body.s1419.heap.get 2673467 = some (.obj (objOf PRE_first_tail_x15_r0_body.s1419 2673467))
kernel_rfl PRE_first_tail_x15_r0_body.zk161_2673467 : (objOf PRE_first_tail_x15_r0_body.s1419 2673467).kind = .array (arrOf PRE_first_tail_x15_r0_body.s0 2673467)
kernel_rfl PRE_first_tail_x15_r0_body.zm161_2673467 : PRE_first_tail_x15_r0_body.s1418.heap.get 2673467 = some (.obj { PRE_first_tail_x15_r0_body.kappa161.obj (objOf PRE_first_tail_x15_r0_body.s1419 2673467) with
  kind := .array (arrOf PRE_first_tail_x15_r0_body.s0 2673467 ++ (arrOf PRE_first_tail_x15_r0_body.s1418 2673467).drop (arrOf PRE_first_tail_x15_r0_body.s0 2673467).length) })
kernel_rfl PRE_first_tail_x15_r0_body.zw161_4910 : (PRE_first_tail_x15_r0_body.s1419.heap.get 4910).isSome = true
kernel_rfl PRE_first_tail_x15_r0_body.zw161_2673472 : (PRE_first_tail_x15_r0_body.s1419.heap.get 2673472).isSome = true
kernel_rfl PRE_first_tail_x15_r0_body.zw161_2673473 : (PRE_first_tail_x15_r0_body.s1419.heap.get 2673473).isSome = true
-- the heap: the changed list in range, holding the stage's written and fresh addresses; the canonical side's image
kernel_rfl PRE_first_tail_x15_r0_body.zclbd161 : PRE_first_tail_x15_r0_body.cl161.all (fun b => Nat.blt (b / 4096) (4 ^ 31)) = true
kernel_rfl PRE_first_tail_x15_r0_body.zwr161 : PRE_first_tail_x15_r0_body.st161.wr.all (fun b => !Nat.blt b PRE_first_tail_x15_r0_body.s1417.next || PRE_first_tail_x15_r0_body.cl161.contains b) = true
def PRE_first_tail_x15_r0_body.zl161 : List Nat := PRE_first_tail_x15_r0_body.cl161.filter fun a => !(List.contains [2665, 2673467] a)
kernel_rfl PRE_first_tail_x15_r0_body.zimgE161 : PRE_first_tail_x15_r0_body.zl161.map (fun a => PRE_first_tail_x15_r0_body.s1418.heap.get (PRE_first_tail_x15_r0_body.kappa161.a a)) = PRE_first_tail_x15_r0_body.zl161.map (fun a => (PRE_first_tail_x15_r0_body.s1419.heap.get a).map PRE_first_tail_x15_r0_body.kappa161.hobj)
theorem PRE_first_tail_x15_r0_body.zimg161 : HeapImg PRE_first_tail_x15_r0_body.kappa161 PRE_first_tail_x15_r0_body.s1419 PRE_first_tail_x15_r0_body.s1418 PRE_first_tail_x15_r0_body.zl161 := PRE_first_tail_x15_r0_body.zimgE161
-- the roots and their supports
kernel_rfl PRE_first_tail_x15_r0_body.zctl161 : PRE_first_tail_x15_r0_body.s1418.ctl = PRE_first_tail_x15_r0_body.kappa161.ctl PRE_first_tail_x15_r0_body.s1419.ctl
kernel_rfl PRE_first_tail_x15_r0_body.zstack161 : PRE_first_tail_x15_r0_body.s1418.stack = PRE_first_tail_x15_r0_body.s1419.stack.map PRE_first_tail_x15_r0_body.kappa161.frame
kernel_rfl PRE_first_tail_x15_r0_body.zjobs161 : PRE_first_tail_x15_r0_body.s1418.jobs = PRE_first_tail_x15_r0_body.s1419.jobs.map PRE_first_tail_x15_r0_body.kappa161.job
kernel_rfl PRE_first_tail_x15_r0_body.zstores161 : PRE_first_tail_x15_r0_body.s1418.stores = PRE_first_tail_x15_r0_body.kappa161.stores PRE_first_tail_x15_r0_body.s1419.stores
kernel_rfl PRE_first_tail_x15_r0_body.zroots161 : checkRootsSupp PRE_first_tail_x15_r0_body.s1419 6937 = true
kernel_rfl PRE_first_tail_x15_r0_body.znC161 : PRE_first_tail_x15_r0_body.S1417.tab.length + PRE_first_tail_x15_r0_body.cws161.length = 6937
-- the map as `Conv.compact_shift` states it (the call's counters for the literals)
kernel_rfl PRE_first_tail_x15_r0_body.zkap161 : PRE_first_tail_x15_r0_body.kappa161 = Conv.Map.compact PRE_first_tail_x15_r0_body.s1417.next 2800930 PRE_first_tail_x15_r0_body.S1417.tab.length PRE_first_tail_x15_r0_body.pl161 (PRE_first_tail_x15_r0_body.nr161.map NumV.ref) PRE_first_tail_x15_r0_body.kd161.big
  PRE_first_tail_x15_r0_body.kd161.region PRE_first_tail_x15_r0_body.kd161.nodeF
-- the bridge inactive at the canonical state (`Conv.FullShiftQ.toX`; the merged state's bridge is the canonical's: cbridge)
theorem PRE_first_tail_x15_r0_body.zbin161 : (Host.Ts.Sim.Full.bridgeOf PRE_first_tail_x15_r0_body.s1419.ffi).active = false := (Host.Load.Boot.replay_active Host.Load.Run.Prompt.P.oblog2818)
-- the JS bookkeeping's step (`Conv.JClean.step` over the changed list) and the canonical roots' bigint freedom
kernel_rfl PRE_first_tail_x15_r0_body.zjc161 : Conv.jcleanListB (⟨21364, 18466, 2800920, 6937⟩ : Conv.Cnt) PRE_first_tail_x15_r0_body.s1419 PRE_first_tail_x15_r0_body.cl161 = true
kernel_rfl PRE_first_tail_x15_r0_body.zroots2161 : noBigRootsP (fun i => !Conv.oldBigB (⟨21364, 18466, 2800920, 6937⟩ : Conv.Cnt) i) PRE_first_tail_x15_r0_body.s1419.trace PRE_first_tail_x15_r0_body.s1419 = true
kernel_rfl PRE_first_tail_x15_r0_body.zhm161 : Nat.ble (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s0.ffi).mlx.nnext 18466 = true
theorem PRE_first_tail_x15_r0_body.cjcl161 (h : Conv.JClean (⟨21364, 18466, 2800919, 6937⟩ : Conv.Cnt) PRE_first_tail_x15_r0_body.s1417) : Conv.JClean (⟨21364, 18466, 2800920, 6937⟩ : Conv.Cnt) PRE_first_tail_x15_r0_body.s1419 :=
  Conv.JClean.step h (Conv.Cnt.le_of_leB PRE_first_tail_x15_r0_body.cle161)
    (Conv.heap_off_setAll PRE_first_tail_x15_r0_body.cheap161 fun a ha => Nat.blt_eq.mp (List.all_eq_true.mp PRE_first_tail_x15_r0_body.zclbd161 a ha)) PRE_first_tail_x15_r0_body.zjc161

end Host.Load.Run.Tpl
