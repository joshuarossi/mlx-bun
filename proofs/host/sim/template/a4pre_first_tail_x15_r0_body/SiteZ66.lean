import host.sim.template.a4pre_first_tail_x15_r0_body.SiteS66
import host.sim.template.a4pre_first_tail_x15_r0_body.SiteK66
import host.sim.template.a4pre_first_tail_x15_r0_body.SiteF66
import host.sim.conv.CompactShift
import host.sim.template.Check
import host.sim.BigFreeP
import host.sim.template.CallGen
set_option Elab.async false
namespace Host.Load.Run.Tpl
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
open Host.Ts Host.Ts.Sim Host.Ts.Sim.Template

/-! The compaction's state shift at call site 66 of chain `PRE_first_tail_x15_r0_body` (`Conv.compact_shift`): the call `PRE_first_tail_x15_r0_body.s593`, the merged
state `PRE_first_tail_x15_r0_body.s594`, the canonical state `PRE_first_tail_x15_r0_body.s595`; its frames [2665,2673467,2673472,2673473] (kept arrays [2665,2673467]). -/

-- the map's places and counters
kernel_rfl PRE_first_tail_x15_r0_body.zpl66 : PRE_first_tail_x15_r0_body.pl66.all (Nat.ble PRE_first_tail_x15_r0_body.s593.next) = true
kernel_rfl PRE_first_tail_x15_r0_body.zplnd66 : nodupT PRE_first_tail_x15_r0_body.pl66 PTrie.nil = true
kernel_rfl PRE_first_tail_x15_r0_body.zn166 : Nat.ble PRE_first_tail_x15_r0_body.s593.next 2728214 = true
kernel_rfl PRE_first_tail_x15_r0_body.zfirst66 : Nat.ble aFirst PRE_first_tail_x15_r0_body.s593.next = true
kernel_rfl PRE_first_tail_x15_r0_body.zscn66 : PRE_first_tail_x15_r0_body.s595.next = PRE_first_tail_x15_r0_body.s593.next + PRE_first_tail_x15_r0_body.pl66.length
kernel_rfl PRE_first_tail_x15_r0_body.zsmn66 : PRE_first_tail_x15_r0_body.s594.next = 2728214
kernel_rfl PRE_first_tail_x15_r0_body.zgrow66 : Nat.ble PRE_first_tail_x15_r0_body.s595.next PRE_first_tail_x15_r0_body.s594.next = true
-- the tables
kernel_rfl PRE_first_tail_x15_r0_body.zfresh66 : PRE_first_tail_x15_r0_body.S593.tab.all (fun e => PRE_first_tail_x15_r0_body.cws66.all fun v => e.noVar v) = true
kernel_rfl PRE_first_tail_x15_r0_body.zcnd66 : nodupT PRE_first_tail_x15_r0_body.cws66 PTrie.nil = true
kernel_rfl PRE_first_tail_x15_r0_body.znrHi66 : PRE_first_tail_x15_r0_body.nr66.all (fun r => Nat.blt r PRE_first_tail_x15_r0_body.S594.tab.length) = true
-- the frames: every framed address below the call's counter; the kept arrays the chain start's, extended in the merged state
kernel_rfl PRE_first_tail_x15_r0_body.zfrlt66 : [2665, 2673467, 2673472, 2673473].all (fun a => Nat.blt a PRE_first_tail_x15_r0_body.s593.next) = true
kernel_rfl PRE_first_tail_x15_r0_body.zg66_2665 : PRE_first_tail_x15_r0_body.s595.heap.get 2665 = some (.obj (objOf PRE_first_tail_x15_r0_body.s595 2665))
kernel_rfl PRE_first_tail_x15_r0_body.zk66_2665 : (objOf PRE_first_tail_x15_r0_body.s595 2665).kind = .array (arrOf PRE_first_tail_x15_r0_body.s0 2665)
kernel_rfl PRE_first_tail_x15_r0_body.zm66_2665 : PRE_first_tail_x15_r0_body.s594.heap.get 2665 = some (.obj { PRE_first_tail_x15_r0_body.kappa66.obj (objOf PRE_first_tail_x15_r0_body.s595 2665) with
  kind := .array (arrOf PRE_first_tail_x15_r0_body.s0 2665 ++ (arrOf PRE_first_tail_x15_r0_body.s594 2665).drop (arrOf PRE_first_tail_x15_r0_body.s0 2665).length) })
kernel_rfl PRE_first_tail_x15_r0_body.zg66_2673467 : PRE_first_tail_x15_r0_body.s595.heap.get 2673467 = some (.obj (objOf PRE_first_tail_x15_r0_body.s595 2673467))
kernel_rfl PRE_first_tail_x15_r0_body.zk66_2673467 : (objOf PRE_first_tail_x15_r0_body.s595 2673467).kind = .array (arrOf PRE_first_tail_x15_r0_body.s0 2673467)
kernel_rfl PRE_first_tail_x15_r0_body.zm66_2673467 : PRE_first_tail_x15_r0_body.s594.heap.get 2673467 = some (.obj { PRE_first_tail_x15_r0_body.kappa66.obj (objOf PRE_first_tail_x15_r0_body.s595 2673467) with
  kind := .array (arrOf PRE_first_tail_x15_r0_body.s0 2673467 ++ (arrOf PRE_first_tail_x15_r0_body.s594 2673467).drop (arrOf PRE_first_tail_x15_r0_body.s0 2673467).length) })
kernel_rfl PRE_first_tail_x15_r0_body.zw66_4910 : (PRE_first_tail_x15_r0_body.s595.heap.get 4910).isSome = true
kernel_rfl PRE_first_tail_x15_r0_body.zw66_2673472 : (PRE_first_tail_x15_r0_body.s595.heap.get 2673472).isSome = true
kernel_rfl PRE_first_tail_x15_r0_body.zw66_2673473 : (PRE_first_tail_x15_r0_body.s595.heap.get 2673473).isSome = true
-- the heap: the changed list in range, holding the stage's written and fresh addresses; the canonical side's image
kernel_rfl PRE_first_tail_x15_r0_body.zclbd66 : PRE_first_tail_x15_r0_body.cl66.all (fun b => Nat.blt (b / 4096) (4 ^ 31)) = true
kernel_rfl PRE_first_tail_x15_r0_body.zwr66 : PRE_first_tail_x15_r0_body.st66.wr.all (fun b => !Nat.blt b PRE_first_tail_x15_r0_body.s593.next || PRE_first_tail_x15_r0_body.cl66.contains b) = true
def PRE_first_tail_x15_r0_body.zl66 : List Nat := PRE_first_tail_x15_r0_body.cl66.filter fun a => !(List.contains [2665, 2673467] a)
kernel_rfl PRE_first_tail_x15_r0_body.zimgE66 : PRE_first_tail_x15_r0_body.zl66.map (fun a => PRE_first_tail_x15_r0_body.s594.heap.get (PRE_first_tail_x15_r0_body.kappa66.a a)) = PRE_first_tail_x15_r0_body.zl66.map (fun a => (PRE_first_tail_x15_r0_body.s595.heap.get a).map PRE_first_tail_x15_r0_body.kappa66.hobj)
theorem PRE_first_tail_x15_r0_body.zimg66 : HeapImg PRE_first_tail_x15_r0_body.kappa66 PRE_first_tail_x15_r0_body.s595 PRE_first_tail_x15_r0_body.s594 PRE_first_tail_x15_r0_body.zl66 := PRE_first_tail_x15_r0_body.zimgE66
-- the roots and their supports
kernel_rfl PRE_first_tail_x15_r0_body.zctl66 : PRE_first_tail_x15_r0_body.s594.ctl = PRE_first_tail_x15_r0_body.kappa66.ctl PRE_first_tail_x15_r0_body.s595.ctl
kernel_rfl PRE_first_tail_x15_r0_body.zstack66 : PRE_first_tail_x15_r0_body.s594.stack = PRE_first_tail_x15_r0_body.s595.stack.map PRE_first_tail_x15_r0_body.kappa66.frame
kernel_rfl PRE_first_tail_x15_r0_body.zjobs66 : PRE_first_tail_x15_r0_body.s594.jobs = PRE_first_tail_x15_r0_body.s595.jobs.map PRE_first_tail_x15_r0_body.kappa66.job
kernel_rfl PRE_first_tail_x15_r0_body.zstores66 : PRE_first_tail_x15_r0_body.s594.stores = PRE_first_tail_x15_r0_body.kappa66.stores PRE_first_tail_x15_r0_body.s595.stores
kernel_rfl PRE_first_tail_x15_r0_body.zroots66 : checkRootsSupp PRE_first_tail_x15_r0_body.s595 2924 = true
kernel_rfl PRE_first_tail_x15_r0_body.znC66 : PRE_first_tail_x15_r0_body.S593.tab.length + PRE_first_tail_x15_r0_body.cws66.length = 2924
-- the map as `Conv.compact_shift` states it (the call's counters for the literals)
kernel_rfl PRE_first_tail_x15_r0_body.zkap66 : PRE_first_tail_x15_r0_body.kappa66 = Conv.Map.compact PRE_first_tail_x15_r0_body.s593.next 2728214 PRE_first_tail_x15_r0_body.S593.tab.length PRE_first_tail_x15_r0_body.pl66 (PRE_first_tail_x15_r0_body.nr66.map NumV.ref) PRE_first_tail_x15_r0_body.kd66.big
  PRE_first_tail_x15_r0_body.kd66.region PRE_first_tail_x15_r0_body.kd66.nodeF
-- the bridge inactive at the canonical state (`Conv.FullShiftQ.toX`; the merged state's bridge is the canonical's: cbridge)
theorem PRE_first_tail_x15_r0_body.zbin66 : (Host.Ts.Sim.Full.bridgeOf PRE_first_tail_x15_r0_body.s595.ffi).active = false := (Host.Load.Boot.replay_active Host.Load.Run.Prompt.P.oblog2818)
-- the JS bookkeeping's step (`Conv.JClean.step` over the changed list) and the canonical roots' bigint freedom
kernel_rfl PRE_first_tail_x15_r0_body.zjc66 : Conv.jcleanListB (⟨19513, 16616, 2727065, 2924⟩ : Conv.Cnt) PRE_first_tail_x15_r0_body.s595 PRE_first_tail_x15_r0_body.cl66 = true
kernel_rfl PRE_first_tail_x15_r0_body.zroots266 : noBigRootsP (fun i => !Conv.oldBigB (⟨19513, 16616, 2727065, 2924⟩ : Conv.Cnt) i) PRE_first_tail_x15_r0_body.s595.trace PRE_first_tail_x15_r0_body.s595 = true
kernel_rfl PRE_first_tail_x15_r0_body.zhm66 : Nat.ble (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s0.ffi).mlx.nnext 16589 = true
theorem PRE_first_tail_x15_r0_body.cjcl66 (h : Conv.JClean (⟨19510, 16589, 2727059, 2906⟩ : Conv.Cnt) PRE_first_tail_x15_r0_body.s593) : Conv.JClean (⟨19513, 16616, 2727065, 2924⟩ : Conv.Cnt) PRE_first_tail_x15_r0_body.s595 :=
  Conv.JClean.step h (Conv.Cnt.le_of_leB PRE_first_tail_x15_r0_body.cle66)
    (Conv.heap_off_setAll PRE_first_tail_x15_r0_body.cheap66 fun a ha => Nat.blt_eq.mp (List.all_eq_true.mp PRE_first_tail_x15_r0_body.zclbd66 a ha)) PRE_first_tail_x15_r0_body.zjc66

end Host.Load.Run.Tpl
