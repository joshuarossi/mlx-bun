import host.sim.template.a4pre_first_tail_x15_r0_body.SiteS124
import host.sim.template.a4pre_first_tail_x15_r0_body.SiteK124
import host.sim.template.a4pre_first_tail_x15_r0_body.SiteF124
import host.sim.conv.CompactShift
import host.sim.template.Check
import host.sim.BigFreeP
import host.sim.template.CallGen
set_option Elab.async false
namespace Host.Load.Run.Tpl
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
open Host.Ts Host.Ts.Sim Host.Ts.Sim.Template

/-! The compaction's state shift at call site 124 of chain `PRE_first_tail_x15_r0_body` (`Conv.compact_shift`): the call `PRE_first_tail_x15_r0_body.s1098`, the merged
state `PRE_first_tail_x15_r0_body.s1099`, the canonical state `PRE_first_tail_x15_r0_body.s1100`; its frames [2665,2673467,2673472,2673473] (kept arrays [2665,2673467]). -/

-- the map's places and counters
kernel_rfl PRE_first_tail_x15_r0_body.zpl124 : PRE_first_tail_x15_r0_body.pl124.all (Nat.ble PRE_first_tail_x15_r0_body.s1098.next) = true
kernel_rfl PRE_first_tail_x15_r0_body.zplnd124 : nodupT PRE_first_tail_x15_r0_body.pl124 PTrie.nil = true
kernel_rfl PRE_first_tail_x15_r0_body.zn1124 : Nat.ble PRE_first_tail_x15_r0_body.s1098.next 2772377 = true
kernel_rfl PRE_first_tail_x15_r0_body.zfirst124 : Nat.ble aFirst PRE_first_tail_x15_r0_body.s1098.next = true
kernel_rfl PRE_first_tail_x15_r0_body.zscn124 : PRE_first_tail_x15_r0_body.s1100.next = PRE_first_tail_x15_r0_body.s1098.next + PRE_first_tail_x15_r0_body.pl124.length
kernel_rfl PRE_first_tail_x15_r0_body.zsmn124 : PRE_first_tail_x15_r0_body.s1099.next = 2772377
kernel_rfl PRE_first_tail_x15_r0_body.zgrow124 : Nat.ble PRE_first_tail_x15_r0_body.s1100.next PRE_first_tail_x15_r0_body.s1099.next = true
-- the tables
kernel_rfl PRE_first_tail_x15_r0_body.zfresh124 : PRE_first_tail_x15_r0_body.S1098.tab.all (fun e => PRE_first_tail_x15_r0_body.cws124.all fun v => e.noVar v) = true
kernel_rfl PRE_first_tail_x15_r0_body.zcnd124 : nodupT PRE_first_tail_x15_r0_body.cws124 PTrie.nil = true
kernel_rfl PRE_first_tail_x15_r0_body.znrHi124 : PRE_first_tail_x15_r0_body.nr124.all (fun r => Nat.blt r PRE_first_tail_x15_r0_body.S1099.tab.length) = true
-- the frames: every framed address below the call's counter; the kept arrays the chain start's, extended in the merged state
kernel_rfl PRE_first_tail_x15_r0_body.zfrlt124 : [2665, 2673467, 2673472, 2673473].all (fun a => Nat.blt a PRE_first_tail_x15_r0_body.s1098.next) = true
kernel_rfl PRE_first_tail_x15_r0_body.zg124_2665 : PRE_first_tail_x15_r0_body.s1100.heap.get 2665 = some (.obj (objOf PRE_first_tail_x15_r0_body.s1100 2665))
kernel_rfl PRE_first_tail_x15_r0_body.zk124_2665 : (objOf PRE_first_tail_x15_r0_body.s1100 2665).kind = .array (arrOf PRE_first_tail_x15_r0_body.s0 2665)
kernel_rfl PRE_first_tail_x15_r0_body.zm124_2665 : PRE_first_tail_x15_r0_body.s1099.heap.get 2665 = some (.obj { PRE_first_tail_x15_r0_body.kappa124.obj (objOf PRE_first_tail_x15_r0_body.s1100 2665) with
  kind := .array (arrOf PRE_first_tail_x15_r0_body.s0 2665 ++ (arrOf PRE_first_tail_x15_r0_body.s1099 2665).drop (arrOf PRE_first_tail_x15_r0_body.s0 2665).length) })
kernel_rfl PRE_first_tail_x15_r0_body.zg124_2673467 : PRE_first_tail_x15_r0_body.s1100.heap.get 2673467 = some (.obj (objOf PRE_first_tail_x15_r0_body.s1100 2673467))
kernel_rfl PRE_first_tail_x15_r0_body.zk124_2673467 : (objOf PRE_first_tail_x15_r0_body.s1100 2673467).kind = .array (arrOf PRE_first_tail_x15_r0_body.s0 2673467)
kernel_rfl PRE_first_tail_x15_r0_body.zm124_2673467 : PRE_first_tail_x15_r0_body.s1099.heap.get 2673467 = some (.obj { PRE_first_tail_x15_r0_body.kappa124.obj (objOf PRE_first_tail_x15_r0_body.s1100 2673467) with
  kind := .array (arrOf PRE_first_tail_x15_r0_body.s0 2673467 ++ (arrOf PRE_first_tail_x15_r0_body.s1099 2673467).drop (arrOf PRE_first_tail_x15_r0_body.s0 2673467).length) })
kernel_rfl PRE_first_tail_x15_r0_body.zw124_4910 : (PRE_first_tail_x15_r0_body.s1100.heap.get 4910).isSome = true
kernel_rfl PRE_first_tail_x15_r0_body.zw124_2673472 : (PRE_first_tail_x15_r0_body.s1100.heap.get 2673472).isSome = true
kernel_rfl PRE_first_tail_x15_r0_body.zw124_2673473 : (PRE_first_tail_x15_r0_body.s1100.heap.get 2673473).isSome = true
-- the heap: the changed list in range, holding the stage's written and fresh addresses; the canonical side's image
kernel_rfl PRE_first_tail_x15_r0_body.zclbd124 : PRE_first_tail_x15_r0_body.cl124.all (fun b => Nat.blt (b / 4096) (4 ^ 31)) = true
kernel_rfl PRE_first_tail_x15_r0_body.zwr124 : PRE_first_tail_x15_r0_body.st124.wr.all (fun b => !Nat.blt b PRE_first_tail_x15_r0_body.s1098.next || PRE_first_tail_x15_r0_body.cl124.contains b) = true
def PRE_first_tail_x15_r0_body.zl124 : List Nat := PRE_first_tail_x15_r0_body.cl124.filter fun a => !(List.contains [2665, 2673467] a)
kernel_rfl PRE_first_tail_x15_r0_body.zimgE124 : PRE_first_tail_x15_r0_body.zl124.map (fun a => PRE_first_tail_x15_r0_body.s1099.heap.get (PRE_first_tail_x15_r0_body.kappa124.a a)) = PRE_first_tail_x15_r0_body.zl124.map (fun a => (PRE_first_tail_x15_r0_body.s1100.heap.get a).map PRE_first_tail_x15_r0_body.kappa124.hobj)
theorem PRE_first_tail_x15_r0_body.zimg124 : HeapImg PRE_first_tail_x15_r0_body.kappa124 PRE_first_tail_x15_r0_body.s1100 PRE_first_tail_x15_r0_body.s1099 PRE_first_tail_x15_r0_body.zl124 := PRE_first_tail_x15_r0_body.zimgE124
-- the roots and their supports
kernel_rfl PRE_first_tail_x15_r0_body.zctl124 : PRE_first_tail_x15_r0_body.s1099.ctl = PRE_first_tail_x15_r0_body.kappa124.ctl PRE_first_tail_x15_r0_body.s1100.ctl
kernel_rfl PRE_first_tail_x15_r0_body.zstack124 : PRE_first_tail_x15_r0_body.s1099.stack = PRE_first_tail_x15_r0_body.s1100.stack.map PRE_first_tail_x15_r0_body.kappa124.frame
kernel_rfl PRE_first_tail_x15_r0_body.zjobs124 : PRE_first_tail_x15_r0_body.s1099.jobs = PRE_first_tail_x15_r0_body.s1100.jobs.map PRE_first_tail_x15_r0_body.kappa124.job
kernel_rfl PRE_first_tail_x15_r0_body.zstores124 : PRE_first_tail_x15_r0_body.s1099.stores = PRE_first_tail_x15_r0_body.kappa124.stores PRE_first_tail_x15_r0_body.s1100.stores
kernel_rfl PRE_first_tail_x15_r0_body.zroots124 : checkRootsSupp PRE_first_tail_x15_r0_body.s1100 5381 = true
kernel_rfl PRE_first_tail_x15_r0_body.znC124 : PRE_first_tail_x15_r0_body.S1098.tab.length + PRE_first_tail_x15_r0_body.cws124.length = 5381
-- the map as `Conv.compact_shift` states it (the call's counters for the literals)
kernel_rfl PRE_first_tail_x15_r0_body.zkap124 : PRE_first_tail_x15_r0_body.kappa124 = Conv.Map.compact PRE_first_tail_x15_r0_body.s1098.next 2772377 PRE_first_tail_x15_r0_body.S1098.tab.length PRE_first_tail_x15_r0_body.pl124 (PRE_first_tail_x15_r0_body.nr124.map NumV.ref) PRE_first_tail_x15_r0_body.kd124.big
  PRE_first_tail_x15_r0_body.kd124.region PRE_first_tail_x15_r0_body.kd124.nodeF
-- the bridge inactive at the canonical state (`Conv.FullShiftQ.toX`; the merged state's bridge is the canonical's: cbridge)
theorem PRE_first_tail_x15_r0_body.zbin124 : (Host.Ts.Sim.Full.bridgeOf PRE_first_tail_x15_r0_body.s1100.ffi).active = false := (Host.Load.Boot.replay_active Host.Load.Run.Prompt.P.oblog2818)
-- the JS bookkeeping's step (`Conv.JClean.step` over the changed list) and the canonical roots' bigint freedom
kernel_rfl PRE_first_tail_x15_r0_body.zjc124 : Conv.jcleanListB (⟨20649, 17751, 2772375, 5381⟩ : Conv.Cnt) PRE_first_tail_x15_r0_body.s1100 PRE_first_tail_x15_r0_body.cl124 = true
kernel_rfl PRE_first_tail_x15_r0_body.zroots2124 : noBigRootsP (fun i => !Conv.oldBigB (⟨20649, 17751, 2772375, 5381⟩ : Conv.Cnt) i) PRE_first_tail_x15_r0_body.s1100.trace PRE_first_tail_x15_r0_body.s1100 = true
kernel_rfl PRE_first_tail_x15_r0_body.zhm124 : Nat.ble (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s0.ffi).mlx.nnext 17751 = true
theorem PRE_first_tail_x15_r0_body.cjcl124 (h : Conv.JClean (⟨20649, 17751, 2772375, 5381⟩ : Conv.Cnt) PRE_first_tail_x15_r0_body.s1098) : Conv.JClean (⟨20649, 17751, 2772375, 5381⟩ : Conv.Cnt) PRE_first_tail_x15_r0_body.s1100 :=
  Conv.JClean.step h (Conv.Cnt.le_of_leB PRE_first_tail_x15_r0_body.cle124)
    (Conv.heap_off_setAll PRE_first_tail_x15_r0_body.cheap124 fun a ha => Nat.blt_eq.mp (List.all_eq_true.mp PRE_first_tail_x15_r0_body.zclbd124 a ha)) PRE_first_tail_x15_r0_body.zjc124

end Host.Load.Run.Tpl
