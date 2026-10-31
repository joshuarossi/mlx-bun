import host.sim.template.a4pre_first_tail_x15_r0_body.SiteS125
import host.sim.template.a4pre_first_tail_x15_r0_body.SiteK125
import host.sim.template.a4pre_first_tail_x15_r0_body.SiteF125
import host.sim.conv.CompactShift
import host.sim.template.Check
import host.sim.BigFreeP
import host.sim.template.CallGen
set_option Elab.async false
namespace Host.Load.Run.Tpl
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
open Host.Ts Host.Ts.Sim Host.Ts.Sim.Template

/-! The compaction's state shift at call site 125 of chain `PRE_first_tail_x15_r0_body` (`Conv.compact_shift`): the call `PRE_first_tail_x15_r0_body.s1102`, the merged
state `PRE_first_tail_x15_r0_body.s1103`, the canonical state `PRE_first_tail_x15_r0_body.s1104`; its frames [2665,2673467,2673472,2673473] (kept arrays [2665,2673467]). -/

-- the map's places and counters
kernel_rfl PRE_first_tail_x15_r0_body.zpl125 : PRE_first_tail_x15_r0_body.pl125.all (Nat.ble PRE_first_tail_x15_r0_body.s1102.next) = true
kernel_rfl PRE_first_tail_x15_r0_body.zplnd125 : nodupT PRE_first_tail_x15_r0_body.pl125 PTrie.nil = true
kernel_rfl PRE_first_tail_x15_r0_body.zn1125 : Nat.ble PRE_first_tail_x15_r0_body.s1102.next 2772674 = true
kernel_rfl PRE_first_tail_x15_r0_body.zfirst125 : Nat.ble aFirst PRE_first_tail_x15_r0_body.s1102.next = true
kernel_rfl PRE_first_tail_x15_r0_body.zscn125 : PRE_first_tail_x15_r0_body.s1104.next = PRE_first_tail_x15_r0_body.s1102.next + PRE_first_tail_x15_r0_body.pl125.length
kernel_rfl PRE_first_tail_x15_r0_body.zsmn125 : PRE_first_tail_x15_r0_body.s1103.next = 2772674
kernel_rfl PRE_first_tail_x15_r0_body.zgrow125 : Nat.ble PRE_first_tail_x15_r0_body.s1104.next PRE_first_tail_x15_r0_body.s1103.next = true
-- the tables
kernel_rfl PRE_first_tail_x15_r0_body.zfresh125 : PRE_first_tail_x15_r0_body.S1102.tab.all (fun e => PRE_first_tail_x15_r0_body.cws125.all fun v => e.noVar v) = true
kernel_rfl PRE_first_tail_x15_r0_body.zcnd125 : nodupT PRE_first_tail_x15_r0_body.cws125 PTrie.nil = true
kernel_rfl PRE_first_tail_x15_r0_body.znrHi125 : PRE_first_tail_x15_r0_body.nr125.all (fun r => Nat.blt r PRE_first_tail_x15_r0_body.S1103.tab.length) = true
-- the frames: every framed address below the call's counter; the kept arrays the chain start's, extended in the merged state
kernel_rfl PRE_first_tail_x15_r0_body.zfrlt125 : [2665, 2673467, 2673472, 2673473].all (fun a => Nat.blt a PRE_first_tail_x15_r0_body.s1102.next) = true
kernel_rfl PRE_first_tail_x15_r0_body.zg125_2665 : PRE_first_tail_x15_r0_body.s1104.heap.get 2665 = some (.obj (objOf PRE_first_tail_x15_r0_body.s1104 2665))
kernel_rfl PRE_first_tail_x15_r0_body.zk125_2665 : (objOf PRE_first_tail_x15_r0_body.s1104 2665).kind = .array (arrOf PRE_first_tail_x15_r0_body.s0 2665)
kernel_rfl PRE_first_tail_x15_r0_body.zm125_2665 : PRE_first_tail_x15_r0_body.s1103.heap.get 2665 = some (.obj { PRE_first_tail_x15_r0_body.kappa125.obj (objOf PRE_first_tail_x15_r0_body.s1104 2665) with
  kind := .array (arrOf PRE_first_tail_x15_r0_body.s0 2665 ++ (arrOf PRE_first_tail_x15_r0_body.s1103 2665).drop (arrOf PRE_first_tail_x15_r0_body.s0 2665).length) })
kernel_rfl PRE_first_tail_x15_r0_body.zg125_2673467 : PRE_first_tail_x15_r0_body.s1104.heap.get 2673467 = some (.obj (objOf PRE_first_tail_x15_r0_body.s1104 2673467))
kernel_rfl PRE_first_tail_x15_r0_body.zk125_2673467 : (objOf PRE_first_tail_x15_r0_body.s1104 2673467).kind = .array (arrOf PRE_first_tail_x15_r0_body.s0 2673467)
kernel_rfl PRE_first_tail_x15_r0_body.zm125_2673467 : PRE_first_tail_x15_r0_body.s1103.heap.get 2673467 = some (.obj { PRE_first_tail_x15_r0_body.kappa125.obj (objOf PRE_first_tail_x15_r0_body.s1104 2673467) with
  kind := .array (arrOf PRE_first_tail_x15_r0_body.s0 2673467 ++ (arrOf PRE_first_tail_x15_r0_body.s1103 2673467).drop (arrOf PRE_first_tail_x15_r0_body.s0 2673467).length) })
kernel_rfl PRE_first_tail_x15_r0_body.zw125_4910 : (PRE_first_tail_x15_r0_body.s1104.heap.get 4910).isSome = true
kernel_rfl PRE_first_tail_x15_r0_body.zw125_2673472 : (PRE_first_tail_x15_r0_body.s1104.heap.get 2673472).isSome = true
kernel_rfl PRE_first_tail_x15_r0_body.zw125_2673473 : (PRE_first_tail_x15_r0_body.s1104.heap.get 2673473).isSome = true
-- the heap: the changed list in range, holding the stage's written and fresh addresses; the canonical side's image
kernel_rfl PRE_first_tail_x15_r0_body.zclbd125 : PRE_first_tail_x15_r0_body.cl125.all (fun b => Nat.blt (b / 4096) (4 ^ 31)) = true
kernel_rfl PRE_first_tail_x15_r0_body.zwr125 : PRE_first_tail_x15_r0_body.st125.wr.all (fun b => !Nat.blt b PRE_first_tail_x15_r0_body.s1102.next || PRE_first_tail_x15_r0_body.cl125.contains b) = true
def PRE_first_tail_x15_r0_body.zl125 : List Nat := PRE_first_tail_x15_r0_body.cl125.filter fun a => !(List.contains [2665, 2673467] a)
kernel_rfl PRE_first_tail_x15_r0_body.zimgE125 : PRE_first_tail_x15_r0_body.zl125.map (fun a => PRE_first_tail_x15_r0_body.s1103.heap.get (PRE_first_tail_x15_r0_body.kappa125.a a)) = PRE_first_tail_x15_r0_body.zl125.map (fun a => (PRE_first_tail_x15_r0_body.s1104.heap.get a).map PRE_first_tail_x15_r0_body.kappa125.hobj)
theorem PRE_first_tail_x15_r0_body.zimg125 : HeapImg PRE_first_tail_x15_r0_body.kappa125 PRE_first_tail_x15_r0_body.s1104 PRE_first_tail_x15_r0_body.s1103 PRE_first_tail_x15_r0_body.zl125 := PRE_first_tail_x15_r0_body.zimgE125
-- the roots and their supports
kernel_rfl PRE_first_tail_x15_r0_body.zctl125 : PRE_first_tail_x15_r0_body.s1103.ctl = PRE_first_tail_x15_r0_body.kappa125.ctl PRE_first_tail_x15_r0_body.s1104.ctl
kernel_rfl PRE_first_tail_x15_r0_body.zstack125 : PRE_first_tail_x15_r0_body.s1103.stack = PRE_first_tail_x15_r0_body.s1104.stack.map PRE_first_tail_x15_r0_body.kappa125.frame
kernel_rfl PRE_first_tail_x15_r0_body.zjobs125 : PRE_first_tail_x15_r0_body.s1103.jobs = PRE_first_tail_x15_r0_body.s1104.jobs.map PRE_first_tail_x15_r0_body.kappa125.job
kernel_rfl PRE_first_tail_x15_r0_body.zstores125 : PRE_first_tail_x15_r0_body.s1103.stores = PRE_first_tail_x15_r0_body.kappa125.stores PRE_first_tail_x15_r0_body.s1104.stores
kernel_rfl PRE_first_tail_x15_r0_body.zroots125 : checkRootsSupp PRE_first_tail_x15_r0_body.s1104 5398 = true
kernel_rfl PRE_first_tail_x15_r0_body.znC125 : PRE_first_tail_x15_r0_body.S1102.tab.length + PRE_first_tail_x15_r0_body.cws125.length = 5398
-- the map as `Conv.compact_shift` states it (the call's counters for the literals)
kernel_rfl PRE_first_tail_x15_r0_body.zkap125 : PRE_first_tail_x15_r0_body.kappa125 = Conv.Map.compact PRE_first_tail_x15_r0_body.s1102.next 2772674 PRE_first_tail_x15_r0_body.S1102.tab.length PRE_first_tail_x15_r0_body.pl125 (PRE_first_tail_x15_r0_body.nr125.map NumV.ref) PRE_first_tail_x15_r0_body.kd125.big
  PRE_first_tail_x15_r0_body.kd125.region PRE_first_tail_x15_r0_body.kd125.nodeF
-- the bridge inactive at the canonical state (`Conv.FullShiftQ.toX`; the merged state's bridge is the canonical's: cbridge)
theorem PRE_first_tail_x15_r0_body.zbin125 : (Host.Ts.Sim.Full.bridgeOf PRE_first_tail_x15_r0_body.s1104.ffi).active = false := (Host.Load.Boot.replay_active Host.Load.Run.Prompt.P.oblog2818)
-- the JS bookkeeping's step (`Conv.JClean.step` over the changed list) and the canonical roots' bigint freedom
kernel_rfl PRE_first_tail_x15_r0_body.zjc125 : Conv.jcleanListB (⟨20656, 17755, 2772664, 5398⟩ : Conv.Cnt) PRE_first_tail_x15_r0_body.s1104 PRE_first_tail_x15_r0_body.cl125 = true
kernel_rfl PRE_first_tail_x15_r0_body.zroots2125 : noBigRootsP (fun i => !Conv.oldBigB (⟨20656, 17755, 2772664, 5398⟩ : Conv.Cnt) i) PRE_first_tail_x15_r0_body.s1104.trace PRE_first_tail_x15_r0_body.s1104 = true
kernel_rfl PRE_first_tail_x15_r0_body.zhm125 : Nat.ble (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s0.ffi).mlx.nnext 17755 = true
theorem PRE_first_tail_x15_r0_body.cjcl125 (h : Conv.JClean (⟨20656, 17755, 2772663, 5398⟩ : Conv.Cnt) PRE_first_tail_x15_r0_body.s1102) : Conv.JClean (⟨20656, 17755, 2772664, 5398⟩ : Conv.Cnt) PRE_first_tail_x15_r0_body.s1104 :=
  Conv.JClean.step h (Conv.Cnt.le_of_leB PRE_first_tail_x15_r0_body.cle125)
    (Conv.heap_off_setAll PRE_first_tail_x15_r0_body.cheap125 fun a ha => Nat.blt_eq.mp (List.all_eq_true.mp PRE_first_tail_x15_r0_body.zclbd125 a ha)) PRE_first_tail_x15_r0_body.zjc125

end Host.Load.Run.Tpl
