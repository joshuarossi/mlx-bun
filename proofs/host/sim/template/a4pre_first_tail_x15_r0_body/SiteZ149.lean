import host.sim.template.a4pre_first_tail_x15_r0_body.SiteS149
import host.sim.template.a4pre_first_tail_x15_r0_body.SiteK149
import host.sim.template.a4pre_first_tail_x15_r0_body.SiteF149
import host.sim.conv.CompactShift
import host.sim.template.Check
import host.sim.BigFreeP
import host.sim.template.CallGen
set_option Elab.async false
namespace Host.Load.Run.Tpl
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
open Host.Ts Host.Ts.Sim Host.Ts.Sim.Template

/-! The compaction's state shift at call site 149 of chain `PRE_first_tail_x15_r0_body` (`Conv.compact_shift`): the call `PRE_first_tail_x15_r0_body.s1312`, the merged
state `PRE_first_tail_x15_r0_body.s1313`, the canonical state `PRE_first_tail_x15_r0_body.s1314`; its frames [2665,2673467,2673472,2673473] (kept arrays [2665,2673467]). -/

-- the map's places and counters
kernel_rfl PRE_first_tail_x15_r0_body.zpl149 : PRE_first_tail_x15_r0_body.pl149.all (Nat.ble PRE_first_tail_x15_r0_body.s1312.next) = true
kernel_rfl PRE_first_tail_x15_r0_body.zplnd149 : nodupT PRE_first_tail_x15_r0_body.pl149 PTrie.nil = true
kernel_rfl PRE_first_tail_x15_r0_body.zn1149 : Nat.ble PRE_first_tail_x15_r0_body.s1312.next 2791523 = true
kernel_rfl PRE_first_tail_x15_r0_body.zfirst149 : Nat.ble aFirst PRE_first_tail_x15_r0_body.s1312.next = true
kernel_rfl PRE_first_tail_x15_r0_body.zscn149 : PRE_first_tail_x15_r0_body.s1314.next = PRE_first_tail_x15_r0_body.s1312.next + PRE_first_tail_x15_r0_body.pl149.length
kernel_rfl PRE_first_tail_x15_r0_body.zsmn149 : PRE_first_tail_x15_r0_body.s1313.next = 2791523
kernel_rfl PRE_first_tail_x15_r0_body.zgrow149 : Nat.ble PRE_first_tail_x15_r0_body.s1314.next PRE_first_tail_x15_r0_body.s1313.next = true
-- the tables
kernel_rfl PRE_first_tail_x15_r0_body.zfresh149 : PRE_first_tail_x15_r0_body.S1312.tab.all (fun e => PRE_first_tail_x15_r0_body.cws149.all fun v => e.noVar v) = true
kernel_rfl PRE_first_tail_x15_r0_body.zcnd149 : nodupT PRE_first_tail_x15_r0_body.cws149 PTrie.nil = true
kernel_rfl PRE_first_tail_x15_r0_body.znrHi149 : PRE_first_tail_x15_r0_body.nr149.all (fun r => Nat.blt r PRE_first_tail_x15_r0_body.S1313.tab.length) = true
-- the frames: every framed address below the call's counter; the kept arrays the chain start's, extended in the merged state
kernel_rfl PRE_first_tail_x15_r0_body.zfrlt149 : [2665, 2673467, 2673472, 2673473].all (fun a => Nat.blt a PRE_first_tail_x15_r0_body.s1312.next) = true
kernel_rfl PRE_first_tail_x15_r0_body.zg149_2665 : PRE_first_tail_x15_r0_body.s1314.heap.get 2665 = some (.obj (objOf PRE_first_tail_x15_r0_body.s1314 2665))
kernel_rfl PRE_first_tail_x15_r0_body.zk149_2665 : (objOf PRE_first_tail_x15_r0_body.s1314 2665).kind = .array (arrOf PRE_first_tail_x15_r0_body.s0 2665)
kernel_rfl PRE_first_tail_x15_r0_body.zm149_2665 : PRE_first_tail_x15_r0_body.s1313.heap.get 2665 = some (.obj { PRE_first_tail_x15_r0_body.kappa149.obj (objOf PRE_first_tail_x15_r0_body.s1314 2665) with
  kind := .array (arrOf PRE_first_tail_x15_r0_body.s0 2665 ++ (arrOf PRE_first_tail_x15_r0_body.s1313 2665).drop (arrOf PRE_first_tail_x15_r0_body.s0 2665).length) })
kernel_rfl PRE_first_tail_x15_r0_body.zg149_2673467 : PRE_first_tail_x15_r0_body.s1314.heap.get 2673467 = some (.obj (objOf PRE_first_tail_x15_r0_body.s1314 2673467))
kernel_rfl PRE_first_tail_x15_r0_body.zk149_2673467 : (objOf PRE_first_tail_x15_r0_body.s1314 2673467).kind = .array (arrOf PRE_first_tail_x15_r0_body.s0 2673467)
kernel_rfl PRE_first_tail_x15_r0_body.zm149_2673467 : PRE_first_tail_x15_r0_body.s1313.heap.get 2673467 = some (.obj { PRE_first_tail_x15_r0_body.kappa149.obj (objOf PRE_first_tail_x15_r0_body.s1314 2673467) with
  kind := .array (arrOf PRE_first_tail_x15_r0_body.s0 2673467 ++ (arrOf PRE_first_tail_x15_r0_body.s1313 2673467).drop (arrOf PRE_first_tail_x15_r0_body.s0 2673467).length) })
kernel_rfl PRE_first_tail_x15_r0_body.zw149_4910 : (PRE_first_tail_x15_r0_body.s1314.heap.get 4910).isSome = true
kernel_rfl PRE_first_tail_x15_r0_body.zw149_2673472 : (PRE_first_tail_x15_r0_body.s1314.heap.get 2673472).isSome = true
kernel_rfl PRE_first_tail_x15_r0_body.zw149_2673473 : (PRE_first_tail_x15_r0_body.s1314.heap.get 2673473).isSome = true
-- the heap: the changed list in range, holding the stage's written and fresh addresses; the canonical side's image
kernel_rfl PRE_first_tail_x15_r0_body.zclbd149 : PRE_first_tail_x15_r0_body.cl149.all (fun b => Nat.blt (b / 4096) (4 ^ 31)) = true
kernel_rfl PRE_first_tail_x15_r0_body.zwr149 : PRE_first_tail_x15_r0_body.st149.wr.all (fun b => !Nat.blt b PRE_first_tail_x15_r0_body.s1312.next || PRE_first_tail_x15_r0_body.cl149.contains b) = true
def PRE_first_tail_x15_r0_body.zl149 : List Nat := PRE_first_tail_x15_r0_body.cl149.filter fun a => !(List.contains [2665, 2673467] a)
kernel_rfl PRE_first_tail_x15_r0_body.zimgE149 : PRE_first_tail_x15_r0_body.zl149.map (fun a => PRE_first_tail_x15_r0_body.s1313.heap.get (PRE_first_tail_x15_r0_body.kappa149.a a)) = PRE_first_tail_x15_r0_body.zl149.map (fun a => (PRE_first_tail_x15_r0_body.s1314.heap.get a).map PRE_first_tail_x15_r0_body.kappa149.hobj)
theorem PRE_first_tail_x15_r0_body.zimg149 : HeapImg PRE_first_tail_x15_r0_body.kappa149 PRE_first_tail_x15_r0_body.s1314 PRE_first_tail_x15_r0_body.s1313 PRE_first_tail_x15_r0_body.zl149 := PRE_first_tail_x15_r0_body.zimgE149
-- the roots and their supports
kernel_rfl PRE_first_tail_x15_r0_body.zctl149 : PRE_first_tail_x15_r0_body.s1313.ctl = PRE_first_tail_x15_r0_body.kappa149.ctl PRE_first_tail_x15_r0_body.s1314.ctl
kernel_rfl PRE_first_tail_x15_r0_body.zstack149 : PRE_first_tail_x15_r0_body.s1313.stack = PRE_first_tail_x15_r0_body.s1314.stack.map PRE_first_tail_x15_r0_body.kappa149.frame
kernel_rfl PRE_first_tail_x15_r0_body.zjobs149 : PRE_first_tail_x15_r0_body.s1313.jobs = PRE_first_tail_x15_r0_body.s1314.jobs.map PRE_first_tail_x15_r0_body.kappa149.job
kernel_rfl PRE_first_tail_x15_r0_body.zstores149 : PRE_first_tail_x15_r0_body.s1313.stores = PRE_first_tail_x15_r0_body.kappa149.stores PRE_first_tail_x15_r0_body.s1314.stores
kernel_rfl PRE_first_tail_x15_r0_body.zroots149 : checkRootsSupp PRE_first_tail_x15_r0_body.s1314 6424 = true
kernel_rfl PRE_first_tail_x15_r0_body.znC149 : PRE_first_tail_x15_r0_body.S1312.tab.length + PRE_first_tail_x15_r0_body.cws149.length = 6424
-- the map as `Conv.compact_shift` states it (the call's counters for the literals)
kernel_rfl PRE_first_tail_x15_r0_body.zkap149 : PRE_first_tail_x15_r0_body.kappa149 = Conv.Map.compact PRE_first_tail_x15_r0_body.s1312.next 2791523 PRE_first_tail_x15_r0_body.S1312.tab.length PRE_first_tail_x15_r0_body.pl149 (PRE_first_tail_x15_r0_body.nr149.map NumV.ref) PRE_first_tail_x15_r0_body.kd149.big
  PRE_first_tail_x15_r0_body.kd149.region PRE_first_tail_x15_r0_body.kd149.nodeF
-- the bridge inactive at the canonical state (`Conv.FullShiftQ.toX`; the merged state's bridge is the canonical's: cbridge)
theorem PRE_first_tail_x15_r0_body.zbin149 : (Host.Ts.Sim.Full.bridgeOf PRE_first_tail_x15_r0_body.s1314.ffi).active = false := (Host.Load.Boot.replay_active Host.Load.Run.Prompt.P.oblog2818)
-- the JS bookkeeping's step (`Conv.JClean.step` over the changed list) and the canonical roots' bigint freedom
kernel_rfl PRE_first_tail_x15_r0_body.zjc149 : Conv.jcleanListB (⟨21128, 18229, 2791504, 6424⟩ : Conv.Cnt) PRE_first_tail_x15_r0_body.s1314 PRE_first_tail_x15_r0_body.cl149 = true
kernel_rfl PRE_first_tail_x15_r0_body.zroots2149 : noBigRootsP (fun i => !Conv.oldBigB (⟨21128, 18229, 2791504, 6424⟩ : Conv.Cnt) i) PRE_first_tail_x15_r0_body.s1314.trace PRE_first_tail_x15_r0_body.s1314 = true
kernel_rfl PRE_first_tail_x15_r0_body.zhm149 : Nat.ble (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s0.ffi).mlx.nnext 18229 = true
theorem PRE_first_tail_x15_r0_body.cjcl149 (h : Conv.JClean (⟨21128, 18229, 2791503, 6424⟩ : Conv.Cnt) PRE_first_tail_x15_r0_body.s1312) : Conv.JClean (⟨21128, 18229, 2791504, 6424⟩ : Conv.Cnt) PRE_first_tail_x15_r0_body.s1314 :=
  Conv.JClean.step h (Conv.Cnt.le_of_leB PRE_first_tail_x15_r0_body.cle149)
    (Conv.heap_off_setAll PRE_first_tail_x15_r0_body.cheap149 fun a ha => Nat.blt_eq.mp (List.all_eq_true.mp PRE_first_tail_x15_r0_body.zclbd149 a ha)) PRE_first_tail_x15_r0_body.zjc149

end Host.Load.Run.Tpl
