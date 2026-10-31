import host.sim.template.a4pre_first_tail_x15_r0_body.SiteS185
import host.sim.template.a4pre_first_tail_x15_r0_body.SiteK185
import host.sim.template.a4pre_first_tail_x15_r0_body.SiteF185
import host.sim.conv.CompactShift
import host.sim.template.Check
import host.sim.BigFreeP
import host.sim.template.CallGen
set_option Elab.async false
namespace Host.Load.Run.Tpl
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
open Host.Ts Host.Ts.Sim Host.Ts.Sim.Template

/-! The compaction's state shift at call site 185 of chain `PRE_first_tail_x15_r0_body` (`Conv.compact_shift`): the call `PRE_first_tail_x15_r0_body.s1627`, the merged
state `PRE_first_tail_x15_r0_body.s1628`, the canonical state `PRE_first_tail_x15_r0_body.s1629`; its frames [2665,2673467,2673472,2673473] (kept arrays [2665,2673467]). -/

-- the map's places and counters
kernel_rfl PRE_first_tail_x15_r0_body.zpl185 : PRE_first_tail_x15_r0_body.pl185.all (Nat.ble PRE_first_tail_x15_r0_body.s1627.next) = true
kernel_rfl PRE_first_tail_x15_r0_body.zplnd185 : nodupT PRE_first_tail_x15_r0_body.pl185 PTrie.nil = true
kernel_rfl PRE_first_tail_x15_r0_body.zn1185 : Nat.ble PRE_first_tail_x15_r0_body.s1627.next 2819791 = true
kernel_rfl PRE_first_tail_x15_r0_body.zfirst185 : Nat.ble aFirst PRE_first_tail_x15_r0_body.s1627.next = true
kernel_rfl PRE_first_tail_x15_r0_body.zscn185 : PRE_first_tail_x15_r0_body.s1629.next = PRE_first_tail_x15_r0_body.s1627.next + PRE_first_tail_x15_r0_body.pl185.length
kernel_rfl PRE_first_tail_x15_r0_body.zsmn185 : PRE_first_tail_x15_r0_body.s1628.next = 2819791
kernel_rfl PRE_first_tail_x15_r0_body.zgrow185 : Nat.ble PRE_first_tail_x15_r0_body.s1629.next PRE_first_tail_x15_r0_body.s1628.next = true
-- the tables
kernel_rfl PRE_first_tail_x15_r0_body.zfresh185 : PRE_first_tail_x15_r0_body.S1627.tab.all (fun e => PRE_first_tail_x15_r0_body.cws185.all fun v => e.noVar v) = true
kernel_rfl PRE_first_tail_x15_r0_body.zcnd185 : nodupT PRE_first_tail_x15_r0_body.cws185 PTrie.nil = true
kernel_rfl PRE_first_tail_x15_r0_body.znrHi185 : PRE_first_tail_x15_r0_body.nr185.all (fun r => Nat.blt r PRE_first_tail_x15_r0_body.S1628.tab.length) = true
-- the frames: every framed address below the call's counter; the kept arrays the chain start's, extended in the merged state
kernel_rfl PRE_first_tail_x15_r0_body.zfrlt185 : [2665, 2673467, 2673472, 2673473].all (fun a => Nat.blt a PRE_first_tail_x15_r0_body.s1627.next) = true
kernel_rfl PRE_first_tail_x15_r0_body.zg185_2665 : PRE_first_tail_x15_r0_body.s1629.heap.get 2665 = some (.obj (objOf PRE_first_tail_x15_r0_body.s1629 2665))
kernel_rfl PRE_first_tail_x15_r0_body.zk185_2665 : (objOf PRE_first_tail_x15_r0_body.s1629 2665).kind = .array (arrOf PRE_first_tail_x15_r0_body.s0 2665)
kernel_rfl PRE_first_tail_x15_r0_body.zm185_2665 : PRE_first_tail_x15_r0_body.s1628.heap.get 2665 = some (.obj { PRE_first_tail_x15_r0_body.kappa185.obj (objOf PRE_first_tail_x15_r0_body.s1629 2665) with
  kind := .array (arrOf PRE_first_tail_x15_r0_body.s0 2665 ++ (arrOf PRE_first_tail_x15_r0_body.s1628 2665).drop (arrOf PRE_first_tail_x15_r0_body.s0 2665).length) })
kernel_rfl PRE_first_tail_x15_r0_body.zg185_2673467 : PRE_first_tail_x15_r0_body.s1629.heap.get 2673467 = some (.obj (objOf PRE_first_tail_x15_r0_body.s1629 2673467))
kernel_rfl PRE_first_tail_x15_r0_body.zk185_2673467 : (objOf PRE_first_tail_x15_r0_body.s1629 2673467).kind = .array (arrOf PRE_first_tail_x15_r0_body.s0 2673467)
kernel_rfl PRE_first_tail_x15_r0_body.zm185_2673467 : PRE_first_tail_x15_r0_body.s1628.heap.get 2673467 = some (.obj { PRE_first_tail_x15_r0_body.kappa185.obj (objOf PRE_first_tail_x15_r0_body.s1629 2673467) with
  kind := .array (arrOf PRE_first_tail_x15_r0_body.s0 2673467 ++ (arrOf PRE_first_tail_x15_r0_body.s1628 2673467).drop (arrOf PRE_first_tail_x15_r0_body.s0 2673467).length) })
kernel_rfl PRE_first_tail_x15_r0_body.zw185_4910 : (PRE_first_tail_x15_r0_body.s1629.heap.get 4910).isSome = true
kernel_rfl PRE_first_tail_x15_r0_body.zw185_2673472 : (PRE_first_tail_x15_r0_body.s1629.heap.get 2673472).isSome = true
kernel_rfl PRE_first_tail_x15_r0_body.zw185_2673473 : (PRE_first_tail_x15_r0_body.s1629.heap.get 2673473).isSome = true
-- the heap: the changed list in range, holding the stage's written and fresh addresses; the canonical side's image
kernel_rfl PRE_first_tail_x15_r0_body.zclbd185 : PRE_first_tail_x15_r0_body.cl185.all (fun b => Nat.blt (b / 4096) (4 ^ 31)) = true
kernel_rfl PRE_first_tail_x15_r0_body.zwr185 : PRE_first_tail_x15_r0_body.st185.wr.all (fun b => !Nat.blt b PRE_first_tail_x15_r0_body.s1627.next || PRE_first_tail_x15_r0_body.cl185.contains b) = true
def PRE_first_tail_x15_r0_body.zl185 : List Nat := PRE_first_tail_x15_r0_body.cl185.filter fun a => !(List.contains [2665, 2673467] a)
kernel_rfl PRE_first_tail_x15_r0_body.zimgE185 : PRE_first_tail_x15_r0_body.zl185.map (fun a => PRE_first_tail_x15_r0_body.s1628.heap.get (PRE_first_tail_x15_r0_body.kappa185.a a)) = PRE_first_tail_x15_r0_body.zl185.map (fun a => (PRE_first_tail_x15_r0_body.s1629.heap.get a).map PRE_first_tail_x15_r0_body.kappa185.hobj)
theorem PRE_first_tail_x15_r0_body.zimg185 : HeapImg PRE_first_tail_x15_r0_body.kappa185 PRE_first_tail_x15_r0_body.s1629 PRE_first_tail_x15_r0_body.s1628 PRE_first_tail_x15_r0_body.zl185 := PRE_first_tail_x15_r0_body.zimgE185
-- the roots and their supports
kernel_rfl PRE_first_tail_x15_r0_body.zctl185 : PRE_first_tail_x15_r0_body.s1628.ctl = PRE_first_tail_x15_r0_body.kappa185.ctl PRE_first_tail_x15_r0_body.s1629.ctl
kernel_rfl PRE_first_tail_x15_r0_body.zstack185 : PRE_first_tail_x15_r0_body.s1628.stack = PRE_first_tail_x15_r0_body.s1629.stack.map PRE_first_tail_x15_r0_body.kappa185.frame
kernel_rfl PRE_first_tail_x15_r0_body.zjobs185 : PRE_first_tail_x15_r0_body.s1628.jobs = PRE_first_tail_x15_r0_body.s1629.jobs.map PRE_first_tail_x15_r0_body.kappa185.job
kernel_rfl PRE_first_tail_x15_r0_body.zstores185 : PRE_first_tail_x15_r0_body.s1628.stores = PRE_first_tail_x15_r0_body.kappa185.stores PRE_first_tail_x15_r0_body.s1629.stores
kernel_rfl PRE_first_tail_x15_r0_body.zroots185 : checkRootsSupp PRE_first_tail_x15_r0_body.s1629 7963 = true
kernel_rfl PRE_first_tail_x15_r0_body.znC185 : PRE_first_tail_x15_r0_body.S1627.tab.length + PRE_first_tail_x15_r0_body.cws185.length = 7963
-- the map as `Conv.compact_shift` states it (the call's counters for the literals)
kernel_rfl PRE_first_tail_x15_r0_body.zkap185 : PRE_first_tail_x15_r0_body.kappa185 = Conv.Map.compact PRE_first_tail_x15_r0_body.s1627.next 2819791 PRE_first_tail_x15_r0_body.S1627.tab.length PRE_first_tail_x15_r0_body.pl185 (PRE_first_tail_x15_r0_body.nr185.map NumV.ref) PRE_first_tail_x15_r0_body.kd185.big
  PRE_first_tail_x15_r0_body.kd185.region PRE_first_tail_x15_r0_body.kd185.nodeF
-- the bridge inactive at the canonical state (`Conv.FullShiftQ.toX`; the merged state's bridge is the canonical's: cbridge)
theorem PRE_first_tail_x15_r0_body.zbin185 : (Host.Ts.Sim.Full.bridgeOf PRE_first_tail_x15_r0_body.s1629.ffi).active = false := (Host.Load.Boot.replay_active Host.Load.Run.Prompt.P.oblog2818)
-- the JS bookkeeping's step (`Conv.JClean.step` over the changed list) and the canonical roots' bigint freedom
kernel_rfl PRE_first_tail_x15_r0_body.zjc185 : Conv.jcleanListB (⟨21836, 18940, 2819772, 7963⟩ : Conv.Cnt) PRE_first_tail_x15_r0_body.s1629 PRE_first_tail_x15_r0_body.cl185 = true
kernel_rfl PRE_first_tail_x15_r0_body.zroots2185 : noBigRootsP (fun i => !Conv.oldBigB (⟨21836, 18940, 2819772, 7963⟩ : Conv.Cnt) i) PRE_first_tail_x15_r0_body.s1629.trace PRE_first_tail_x15_r0_body.s1629 = true
kernel_rfl PRE_first_tail_x15_r0_body.zhm185 : Nat.ble (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s0.ffi).mlx.nnext 18940 = true
theorem PRE_first_tail_x15_r0_body.cjcl185 (h : Conv.JClean (⟨21836, 18940, 2819771, 7963⟩ : Conv.Cnt) PRE_first_tail_x15_r0_body.s1627) : Conv.JClean (⟨21836, 18940, 2819772, 7963⟩ : Conv.Cnt) PRE_first_tail_x15_r0_body.s1629 :=
  Conv.JClean.step h (Conv.Cnt.le_of_leB PRE_first_tail_x15_r0_body.cle185)
    (Conv.heap_off_setAll PRE_first_tail_x15_r0_body.cheap185 fun a ha => Nat.blt_eq.mp (List.all_eq_true.mp PRE_first_tail_x15_r0_body.zclbd185 a ha)) PRE_first_tail_x15_r0_body.zjc185

end Host.Load.Run.Tpl
