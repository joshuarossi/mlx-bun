import host.sim.template.a4pre_first_tail_x15_r0_body.SiteS180
import host.sim.template.a4pre_first_tail_x15_r0_body.SiteK180
import host.sim.template.a4pre_first_tail_x15_r0_body.SiteF180
import host.sim.conv.CompactShift
import host.sim.template.Check
import host.sim.BigFreeP
import host.sim.template.CallGen
set_option Elab.async false
namespace Host.Load.Run.Tpl
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
open Host.Ts Host.Ts.Sim Host.Ts.Sim.Template

/-! The compaction's state shift at call site 180 of chain `PRE_first_tail_x15_r0_body` (`Conv.compact_shift`): the call `PRE_first_tail_x15_r0_body.s1589`, the merged
state `PRE_first_tail_x15_r0_body.s1590`, the canonical state `PRE_first_tail_x15_r0_body.s1591`; its frames [2665,2673467,2673472,2673473] (kept arrays [2665,2673467]). -/

-- the map's places and counters
kernel_rfl PRE_first_tail_x15_r0_body.zpl180 : PRE_first_tail_x15_r0_body.pl180.all (Nat.ble PRE_first_tail_x15_r0_body.s1589.next) = true
kernel_rfl PRE_first_tail_x15_r0_body.zplnd180 : nodupT PRE_first_tail_x15_r0_body.pl180 PTrie.nil = true
kernel_rfl PRE_first_tail_x15_r0_body.zn1180 : Nat.ble PRE_first_tail_x15_r0_body.s1589.next 2817882 = true
kernel_rfl PRE_first_tail_x15_r0_body.zfirst180 : Nat.ble aFirst PRE_first_tail_x15_r0_body.s1589.next = true
kernel_rfl PRE_first_tail_x15_r0_body.zscn180 : PRE_first_tail_x15_r0_body.s1591.next = PRE_first_tail_x15_r0_body.s1589.next + PRE_first_tail_x15_r0_body.pl180.length
kernel_rfl PRE_first_tail_x15_r0_body.zsmn180 : PRE_first_tail_x15_r0_body.s1590.next = 2817882
kernel_rfl PRE_first_tail_x15_r0_body.zgrow180 : Nat.ble PRE_first_tail_x15_r0_body.s1591.next PRE_first_tail_x15_r0_body.s1590.next = true
-- the tables
kernel_rfl PRE_first_tail_x15_r0_body.zfresh180 : PRE_first_tail_x15_r0_body.S1589.tab.all (fun e => PRE_first_tail_x15_r0_body.cws180.all fun v => e.noVar v) = true
kernel_rfl PRE_first_tail_x15_r0_body.zcnd180 : nodupT PRE_first_tail_x15_r0_body.cws180 PTrie.nil = true
kernel_rfl PRE_first_tail_x15_r0_body.znrHi180 : PRE_first_tail_x15_r0_body.nr180.all (fun r => Nat.blt r PRE_first_tail_x15_r0_body.S1590.tab.length) = true
-- the frames: every framed address below the call's counter; the kept arrays the chain start's, extended in the merged state
kernel_rfl PRE_first_tail_x15_r0_body.zfrlt180 : [2665, 2673467, 2673472, 2673473].all (fun a => Nat.blt a PRE_first_tail_x15_r0_body.s1589.next) = true
kernel_rfl PRE_first_tail_x15_r0_body.zg180_2665 : PRE_first_tail_x15_r0_body.s1591.heap.get 2665 = some (.obj (objOf PRE_first_tail_x15_r0_body.s1591 2665))
kernel_rfl PRE_first_tail_x15_r0_body.zk180_2665 : (objOf PRE_first_tail_x15_r0_body.s1591 2665).kind = .array (arrOf PRE_first_tail_x15_r0_body.s0 2665)
kernel_rfl PRE_first_tail_x15_r0_body.zm180_2665 : PRE_first_tail_x15_r0_body.s1590.heap.get 2665 = some (.obj { PRE_first_tail_x15_r0_body.kappa180.obj (objOf PRE_first_tail_x15_r0_body.s1591 2665) with
  kind := .array (arrOf PRE_first_tail_x15_r0_body.s0 2665 ++ (arrOf PRE_first_tail_x15_r0_body.s1590 2665).drop (arrOf PRE_first_tail_x15_r0_body.s0 2665).length) })
kernel_rfl PRE_first_tail_x15_r0_body.zg180_2673467 : PRE_first_tail_x15_r0_body.s1591.heap.get 2673467 = some (.obj (objOf PRE_first_tail_x15_r0_body.s1591 2673467))
kernel_rfl PRE_first_tail_x15_r0_body.zk180_2673467 : (objOf PRE_first_tail_x15_r0_body.s1591 2673467).kind = .array (arrOf PRE_first_tail_x15_r0_body.s0 2673467)
kernel_rfl PRE_first_tail_x15_r0_body.zm180_2673467 : PRE_first_tail_x15_r0_body.s1590.heap.get 2673467 = some (.obj { PRE_first_tail_x15_r0_body.kappa180.obj (objOf PRE_first_tail_x15_r0_body.s1591 2673467) with
  kind := .array (arrOf PRE_first_tail_x15_r0_body.s0 2673467 ++ (arrOf PRE_first_tail_x15_r0_body.s1590 2673467).drop (arrOf PRE_first_tail_x15_r0_body.s0 2673467).length) })
kernel_rfl PRE_first_tail_x15_r0_body.zw180_4910 : (PRE_first_tail_x15_r0_body.s1591.heap.get 4910).isSome = true
kernel_rfl PRE_first_tail_x15_r0_body.zw180_2673472 : (PRE_first_tail_x15_r0_body.s1591.heap.get 2673472).isSome = true
kernel_rfl PRE_first_tail_x15_r0_body.zw180_2673473 : (PRE_first_tail_x15_r0_body.s1591.heap.get 2673473).isSome = true
-- the heap: the changed list in range, holding the stage's written and fresh addresses; the canonical side's image
kernel_rfl PRE_first_tail_x15_r0_body.zclbd180 : PRE_first_tail_x15_r0_body.cl180.all (fun b => Nat.blt (b / 4096) (4 ^ 31)) = true
kernel_rfl PRE_first_tail_x15_r0_body.zwr180 : PRE_first_tail_x15_r0_body.st180.wr.all (fun b => !Nat.blt b PRE_first_tail_x15_r0_body.s1589.next || PRE_first_tail_x15_r0_body.cl180.contains b) = true
def PRE_first_tail_x15_r0_body.zl180 : List Nat := PRE_first_tail_x15_r0_body.cl180.filter fun a => !(List.contains [2665, 2673467] a)
kernel_rfl PRE_first_tail_x15_r0_body.zimgE180 : PRE_first_tail_x15_r0_body.zl180.map (fun a => PRE_first_tail_x15_r0_body.s1590.heap.get (PRE_first_tail_x15_r0_body.kappa180.a a)) = PRE_first_tail_x15_r0_body.zl180.map (fun a => (PRE_first_tail_x15_r0_body.s1591.heap.get a).map PRE_first_tail_x15_r0_body.kappa180.hobj)
theorem PRE_first_tail_x15_r0_body.zimg180 : HeapImg PRE_first_tail_x15_r0_body.kappa180 PRE_first_tail_x15_r0_body.s1591 PRE_first_tail_x15_r0_body.s1590 PRE_first_tail_x15_r0_body.zl180 := PRE_first_tail_x15_r0_body.zimgE180
-- the roots and their supports
kernel_rfl PRE_first_tail_x15_r0_body.zctl180 : PRE_first_tail_x15_r0_body.s1590.ctl = PRE_first_tail_x15_r0_body.kappa180.ctl PRE_first_tail_x15_r0_body.s1591.ctl
kernel_rfl PRE_first_tail_x15_r0_body.zstack180 : PRE_first_tail_x15_r0_body.s1590.stack = PRE_first_tail_x15_r0_body.s1591.stack.map PRE_first_tail_x15_r0_body.kappa180.frame
kernel_rfl PRE_first_tail_x15_r0_body.zjobs180 : PRE_first_tail_x15_r0_body.s1590.jobs = PRE_first_tail_x15_r0_body.s1591.jobs.map PRE_first_tail_x15_r0_body.kappa180.job
kernel_rfl PRE_first_tail_x15_r0_body.zstores180 : PRE_first_tail_x15_r0_body.s1590.stores = PRE_first_tail_x15_r0_body.kappa180.stores PRE_first_tail_x15_r0_body.s1591.stores
kernel_rfl PRE_first_tail_x15_r0_body.zroots180 : checkRootsSupp PRE_first_tail_x15_r0_body.s1591 7796 = true
kernel_rfl PRE_first_tail_x15_r0_body.znC180 : PRE_first_tail_x15_r0_body.S1589.tab.length + PRE_first_tail_x15_r0_body.cws180.length = 7796
-- the map as `Conv.compact_shift` states it (the call's counters for the literals)
kernel_rfl PRE_first_tail_x15_r0_body.zkap180 : PRE_first_tail_x15_r0_body.kappa180 = Conv.Map.compact PRE_first_tail_x15_r0_body.s1589.next 2817882 PRE_first_tail_x15_r0_body.S1589.tab.length PRE_first_tail_x15_r0_body.pl180 (PRE_first_tail_x15_r0_body.nr180.map NumV.ref) PRE_first_tail_x15_r0_body.kd180.big
  PRE_first_tail_x15_r0_body.kd180.region PRE_first_tail_x15_r0_body.kd180.nodeF
-- the bridge inactive at the canonical state (`Conv.FullShiftQ.toX`; the merged state's bridge is the canonical's: cbridge)
theorem PRE_first_tail_x15_r0_body.zbin180 : (Host.Ts.Sim.Full.bridgeOf PRE_first_tail_x15_r0_body.s1591.ffi).active = false := (Host.Load.Boot.replay_active Host.Load.Run.Prompt.P.oblog2818)
-- the JS bookkeeping's step (`Conv.JClean.step` over the changed list) and the canonical roots' bigint freedom
kernel_rfl PRE_first_tail_x15_r0_body.zjc180 : Conv.jcleanListB (⟨21759, 18860, 2816733, 7796⟩ : Conv.Cnt) PRE_first_tail_x15_r0_body.s1591 PRE_first_tail_x15_r0_body.cl180 = true
kernel_rfl PRE_first_tail_x15_r0_body.zroots2180 : noBigRootsP (fun i => !Conv.oldBigB (⟨21759, 18860, 2816733, 7796⟩ : Conv.Cnt) i) PRE_first_tail_x15_r0_body.s1591.trace PRE_first_tail_x15_r0_body.s1591 = true
kernel_rfl PRE_first_tail_x15_r0_body.zhm180 : Nat.ble (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s0.ffi).mlx.nnext 18833 = true
theorem PRE_first_tail_x15_r0_body.cjcl180 (h : Conv.JClean (⟨21756, 18833, 2816727, 7778⟩ : Conv.Cnt) PRE_first_tail_x15_r0_body.s1589) : Conv.JClean (⟨21759, 18860, 2816733, 7796⟩ : Conv.Cnt) PRE_first_tail_x15_r0_body.s1591 :=
  Conv.JClean.step h (Conv.Cnt.le_of_leB PRE_first_tail_x15_r0_body.cle180)
    (Conv.heap_off_setAll PRE_first_tail_x15_r0_body.cheap180 fun a ha => Nat.blt_eq.mp (List.all_eq_true.mp PRE_first_tail_x15_r0_body.zclbd180 a ha)) PRE_first_tail_x15_r0_body.zjc180

end Host.Load.Run.Tpl
