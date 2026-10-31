import host.sim.template.a4pre_first_tail_x15_r0_body.SiteS22
import host.sim.template.a4pre_first_tail_x15_r0_body.SiteK22
import host.sim.template.a4pre_first_tail_x15_r0_body.SiteF22
import host.sim.conv.CompactShift
import host.sim.template.Check
import host.sim.BigFreeP
import host.sim.template.CallGen
set_option Elab.async false
namespace Host.Load.Run.Tpl
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
open Host.Ts Host.Ts.Sim Host.Ts.Sim.Template

/-! The compaction's state shift at call site 22 of chain `PRE_first_tail_x15_r0_body` (`Conv.compact_shift`): the call `PRE_first_tail_x15_r0_body.s204`, the merged
state `PRE_first_tail_x15_r0_body.s205`, the canonical state `PRE_first_tail_x15_r0_body.s206`; its frames [2665,2673467,2673472,2673473] (kept arrays [2665,2673467]). -/

-- the map's places and counters
kernel_rfl PRE_first_tail_x15_r0_body.zpl22 : PRE_first_tail_x15_r0_body.pl22.all (Nat.ble PRE_first_tail_x15_r0_body.s204.next) = true
kernel_rfl PRE_first_tail_x15_r0_body.zplnd22 : nodupT PRE_first_tail_x15_r0_body.pl22 PTrie.nil = true
kernel_rfl PRE_first_tail_x15_r0_body.zn122 : Nat.ble PRE_first_tail_x15_r0_body.s204.next 2692507 = true
kernel_rfl PRE_first_tail_x15_r0_body.zfirst22 : Nat.ble aFirst PRE_first_tail_x15_r0_body.s204.next = true
kernel_rfl PRE_first_tail_x15_r0_body.zscn22 : PRE_first_tail_x15_r0_body.s206.next = PRE_first_tail_x15_r0_body.s204.next + PRE_first_tail_x15_r0_body.pl22.length
kernel_rfl PRE_first_tail_x15_r0_body.zsmn22 : PRE_first_tail_x15_r0_body.s205.next = 2692507
kernel_rfl PRE_first_tail_x15_r0_body.zgrow22 : Nat.ble PRE_first_tail_x15_r0_body.s206.next PRE_first_tail_x15_r0_body.s205.next = true
-- the tables
kernel_rfl PRE_first_tail_x15_r0_body.zfresh22 : PRE_first_tail_x15_r0_body.S204.tab.all (fun e => PRE_first_tail_x15_r0_body.cws22.all fun v => e.noVar v) = true
kernel_rfl PRE_first_tail_x15_r0_body.zcnd22 : nodupT PRE_first_tail_x15_r0_body.cws22 PTrie.nil = true
kernel_rfl PRE_first_tail_x15_r0_body.znrHi22 : PRE_first_tail_x15_r0_body.nr22.all (fun r => Nat.blt r PRE_first_tail_x15_r0_body.S205.tab.length) = true
-- the frames: every framed address below the call's counter; the kept arrays the chain start's, extended in the merged state
kernel_rfl PRE_first_tail_x15_r0_body.zfrlt22 : [2665, 2673467, 2673472, 2673473].all (fun a => Nat.blt a PRE_first_tail_x15_r0_body.s204.next) = true
kernel_rfl PRE_first_tail_x15_r0_body.zg22_2665 : PRE_first_tail_x15_r0_body.s206.heap.get 2665 = some (.obj (objOf PRE_first_tail_x15_r0_body.s206 2665))
kernel_rfl PRE_first_tail_x15_r0_body.zk22_2665 : (objOf PRE_first_tail_x15_r0_body.s206 2665).kind = .array (arrOf PRE_first_tail_x15_r0_body.s0 2665)
kernel_rfl PRE_first_tail_x15_r0_body.zm22_2665 : PRE_first_tail_x15_r0_body.s205.heap.get 2665 = some (.obj { PRE_first_tail_x15_r0_body.kappa22.obj (objOf PRE_first_tail_x15_r0_body.s206 2665) with
  kind := .array (arrOf PRE_first_tail_x15_r0_body.s0 2665 ++ (arrOf PRE_first_tail_x15_r0_body.s205 2665).drop (arrOf PRE_first_tail_x15_r0_body.s0 2665).length) })
kernel_rfl PRE_first_tail_x15_r0_body.zg22_2673467 : PRE_first_tail_x15_r0_body.s206.heap.get 2673467 = some (.obj (objOf PRE_first_tail_x15_r0_body.s206 2673467))
kernel_rfl PRE_first_tail_x15_r0_body.zk22_2673467 : (objOf PRE_first_tail_x15_r0_body.s206 2673467).kind = .array (arrOf PRE_first_tail_x15_r0_body.s0 2673467)
kernel_rfl PRE_first_tail_x15_r0_body.zm22_2673467 : PRE_first_tail_x15_r0_body.s205.heap.get 2673467 = some (.obj { PRE_first_tail_x15_r0_body.kappa22.obj (objOf PRE_first_tail_x15_r0_body.s206 2673467) with
  kind := .array (arrOf PRE_first_tail_x15_r0_body.s0 2673467 ++ (arrOf PRE_first_tail_x15_r0_body.s205 2673467).drop (arrOf PRE_first_tail_x15_r0_body.s0 2673467).length) })
kernel_rfl PRE_first_tail_x15_r0_body.zw22_4910 : (PRE_first_tail_x15_r0_body.s206.heap.get 4910).isSome = true
kernel_rfl PRE_first_tail_x15_r0_body.zw22_2673472 : (PRE_first_tail_x15_r0_body.s206.heap.get 2673472).isSome = true
kernel_rfl PRE_first_tail_x15_r0_body.zw22_2673473 : (PRE_first_tail_x15_r0_body.s206.heap.get 2673473).isSome = true
-- the heap: the changed list in range, holding the stage's written and fresh addresses; the canonical side's image
kernel_rfl PRE_first_tail_x15_r0_body.zclbd22 : PRE_first_tail_x15_r0_body.cl22.all (fun b => Nat.blt (b / 4096) (4 ^ 31)) = true
kernel_rfl PRE_first_tail_x15_r0_body.zwr22 : PRE_first_tail_x15_r0_body.st22.wr.all (fun b => !Nat.blt b PRE_first_tail_x15_r0_body.s204.next || PRE_first_tail_x15_r0_body.cl22.contains b) = true
def PRE_first_tail_x15_r0_body.zl22 : List Nat := PRE_first_tail_x15_r0_body.cl22.filter fun a => !(List.contains [2665, 2673467] a)
kernel_rfl PRE_first_tail_x15_r0_body.zimgE22 : PRE_first_tail_x15_r0_body.zl22.map (fun a => PRE_first_tail_x15_r0_body.s205.heap.get (PRE_first_tail_x15_r0_body.kappa22.a a)) = PRE_first_tail_x15_r0_body.zl22.map (fun a => (PRE_first_tail_x15_r0_body.s206.heap.get a).map PRE_first_tail_x15_r0_body.kappa22.hobj)
theorem PRE_first_tail_x15_r0_body.zimg22 : HeapImg PRE_first_tail_x15_r0_body.kappa22 PRE_first_tail_x15_r0_body.s206 PRE_first_tail_x15_r0_body.s205 PRE_first_tail_x15_r0_body.zl22 := PRE_first_tail_x15_r0_body.zimgE22
-- the roots and their supports
kernel_rfl PRE_first_tail_x15_r0_body.zctl22 : PRE_first_tail_x15_r0_body.s205.ctl = PRE_first_tail_x15_r0_body.kappa22.ctl PRE_first_tail_x15_r0_body.s206.ctl
kernel_rfl PRE_first_tail_x15_r0_body.zstack22 : PRE_first_tail_x15_r0_body.s205.stack = PRE_first_tail_x15_r0_body.s206.stack.map PRE_first_tail_x15_r0_body.kappa22.frame
kernel_rfl PRE_first_tail_x15_r0_body.zjobs22 : PRE_first_tail_x15_r0_body.s205.jobs = PRE_first_tail_x15_r0_body.s206.jobs.map PRE_first_tail_x15_r0_body.kappa22.job
kernel_rfl PRE_first_tail_x15_r0_body.zstores22 : PRE_first_tail_x15_r0_body.s205.stores = PRE_first_tail_x15_r0_body.kappa22.stores PRE_first_tail_x15_r0_body.s206.stores
kernel_rfl PRE_first_tail_x15_r0_body.zroots22 : checkRootsSupp PRE_first_tail_x15_r0_body.s206 1019 = true
kernel_rfl PRE_first_tail_x15_r0_body.znC22 : PRE_first_tail_x15_r0_body.S204.tab.length + PRE_first_tail_x15_r0_body.cws22.length = 1019
-- the map as `Conv.compact_shift` states it (the call's counters for the literals)
kernel_rfl PRE_first_tail_x15_r0_body.zkap22 : PRE_first_tail_x15_r0_body.kappa22 = Conv.Map.compact PRE_first_tail_x15_r0_body.s204.next 2692507 PRE_first_tail_x15_r0_body.S204.tab.length PRE_first_tail_x15_r0_body.pl22 (PRE_first_tail_x15_r0_body.nr22.map NumV.ref) PRE_first_tail_x15_r0_body.kd22.big
  PRE_first_tail_x15_r0_body.kd22.region PRE_first_tail_x15_r0_body.kd22.nodeF
-- the bridge inactive at the canonical state (`Conv.FullShiftQ.toX`; the merged state's bridge is the canonical's: cbridge)
theorem PRE_first_tail_x15_r0_body.zbin22 : (Host.Ts.Sim.Full.bridgeOf PRE_first_tail_x15_r0_body.s206.ffi).active = false := (Host.Load.Boot.replay_active Host.Load.Run.Prompt.P.oblog2818)
-- the JS bookkeeping's step (`Conv.JClean.step` over the changed list) and the canonical roots' bigint freedom
kernel_rfl PRE_first_tail_x15_r0_body.zjc22 : Conv.jcleanListB (⟨18646, 15729, 2692505, 1019⟩ : Conv.Cnt) PRE_first_tail_x15_r0_body.s206 PRE_first_tail_x15_r0_body.cl22 = true
kernel_rfl PRE_first_tail_x15_r0_body.zroots222 : noBigRootsP (fun i => !Conv.oldBigB (⟨18646, 15729, 2692505, 1019⟩ : Conv.Cnt) i) PRE_first_tail_x15_r0_body.s206.trace PRE_first_tail_x15_r0_body.s206 = true
kernel_rfl PRE_first_tail_x15_r0_body.zhm22 : Nat.ble (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s0.ffi).mlx.nnext 15729 = true
theorem PRE_first_tail_x15_r0_body.cjcl22 (h : Conv.JClean (⟨18646, 15729, 2692505, 1019⟩ : Conv.Cnt) PRE_first_tail_x15_r0_body.s204) : Conv.JClean (⟨18646, 15729, 2692505, 1019⟩ : Conv.Cnt) PRE_first_tail_x15_r0_body.s206 :=
  Conv.JClean.step h (Conv.Cnt.le_of_leB PRE_first_tail_x15_r0_body.cle22)
    (Conv.heap_off_setAll PRE_first_tail_x15_r0_body.cheap22 fun a ha => Nat.blt_eq.mp (List.all_eq_true.mp PRE_first_tail_x15_r0_body.zclbd22 a ha)) PRE_first_tail_x15_r0_body.zjc22

end Host.Load.Run.Tpl
