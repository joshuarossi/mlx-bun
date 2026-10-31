import host.sim.template.a4pre_first_tail_x15_r0_body.SiteS160
import host.sim.template.a4pre_first_tail_x15_r0_body.SiteK160
import host.sim.template.a4pre_first_tail_x15_r0_body.SiteF160
import host.sim.conv.CompactShift
import host.sim.template.Check
import host.sim.BigFreeP
import host.sim.template.CallGen
set_option Elab.async false
namespace Host.Load.Run.Tpl
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
open Host.Ts Host.Ts.Sim Host.Ts.Sim.Template

/-! The compaction's state shift at call site 160 of chain `PRE_first_tail_x15_r0_body` (`Conv.compact_shift`): the call `PRE_first_tail_x15_r0_body.s1413`, the merged
state `PRE_first_tail_x15_r0_body.s1414`, the canonical state `PRE_first_tail_x15_r0_body.s1415`; its frames [2665,2673467,2673472,2673473] (kept arrays [2665,2673467]). -/

-- the map's places and counters
kernel_rfl PRE_first_tail_x15_r0_body.zpl160 : PRE_first_tail_x15_r0_body.pl160.all (Nat.ble PRE_first_tail_x15_r0_body.s1413.next) = true
kernel_rfl PRE_first_tail_x15_r0_body.zplnd160 : nodupT PRE_first_tail_x15_r0_body.pl160 PTrie.nil = true
kernel_rfl PRE_first_tail_x15_r0_body.zn1160 : Nat.ble PRE_first_tail_x15_r0_body.s1413.next 2800633 = true
kernel_rfl PRE_first_tail_x15_r0_body.zfirst160 : Nat.ble aFirst PRE_first_tail_x15_r0_body.s1413.next = true
kernel_rfl PRE_first_tail_x15_r0_body.zscn160 : PRE_first_tail_x15_r0_body.s1415.next = PRE_first_tail_x15_r0_body.s1413.next + PRE_first_tail_x15_r0_body.pl160.length
kernel_rfl PRE_first_tail_x15_r0_body.zsmn160 : PRE_first_tail_x15_r0_body.s1414.next = 2800633
kernel_rfl PRE_first_tail_x15_r0_body.zgrow160 : Nat.ble PRE_first_tail_x15_r0_body.s1415.next PRE_first_tail_x15_r0_body.s1414.next = true
-- the tables
kernel_rfl PRE_first_tail_x15_r0_body.zfresh160 : PRE_first_tail_x15_r0_body.S1413.tab.all (fun e => PRE_first_tail_x15_r0_body.cws160.all fun v => e.noVar v) = true
kernel_rfl PRE_first_tail_x15_r0_body.zcnd160 : nodupT PRE_first_tail_x15_r0_body.cws160 PTrie.nil = true
kernel_rfl PRE_first_tail_x15_r0_body.znrHi160 : PRE_first_tail_x15_r0_body.nr160.all (fun r => Nat.blt r PRE_first_tail_x15_r0_body.S1414.tab.length) = true
-- the frames: every framed address below the call's counter; the kept arrays the chain start's, extended in the merged state
kernel_rfl PRE_first_tail_x15_r0_body.zfrlt160 : [2665, 2673467, 2673472, 2673473].all (fun a => Nat.blt a PRE_first_tail_x15_r0_body.s1413.next) = true
kernel_rfl PRE_first_tail_x15_r0_body.zg160_2665 : PRE_first_tail_x15_r0_body.s1415.heap.get 2665 = some (.obj (objOf PRE_first_tail_x15_r0_body.s1415 2665))
kernel_rfl PRE_first_tail_x15_r0_body.zk160_2665 : (objOf PRE_first_tail_x15_r0_body.s1415 2665).kind = .array (arrOf PRE_first_tail_x15_r0_body.s0 2665)
kernel_rfl PRE_first_tail_x15_r0_body.zm160_2665 : PRE_first_tail_x15_r0_body.s1414.heap.get 2665 = some (.obj { PRE_first_tail_x15_r0_body.kappa160.obj (objOf PRE_first_tail_x15_r0_body.s1415 2665) with
  kind := .array (arrOf PRE_first_tail_x15_r0_body.s0 2665 ++ (arrOf PRE_first_tail_x15_r0_body.s1414 2665).drop (arrOf PRE_first_tail_x15_r0_body.s0 2665).length) })
kernel_rfl PRE_first_tail_x15_r0_body.zg160_2673467 : PRE_first_tail_x15_r0_body.s1415.heap.get 2673467 = some (.obj (objOf PRE_first_tail_x15_r0_body.s1415 2673467))
kernel_rfl PRE_first_tail_x15_r0_body.zk160_2673467 : (objOf PRE_first_tail_x15_r0_body.s1415 2673467).kind = .array (arrOf PRE_first_tail_x15_r0_body.s0 2673467)
kernel_rfl PRE_first_tail_x15_r0_body.zm160_2673467 : PRE_first_tail_x15_r0_body.s1414.heap.get 2673467 = some (.obj { PRE_first_tail_x15_r0_body.kappa160.obj (objOf PRE_first_tail_x15_r0_body.s1415 2673467) with
  kind := .array (arrOf PRE_first_tail_x15_r0_body.s0 2673467 ++ (arrOf PRE_first_tail_x15_r0_body.s1414 2673467).drop (arrOf PRE_first_tail_x15_r0_body.s0 2673467).length) })
kernel_rfl PRE_first_tail_x15_r0_body.zw160_4910 : (PRE_first_tail_x15_r0_body.s1415.heap.get 4910).isSome = true
kernel_rfl PRE_first_tail_x15_r0_body.zw160_2673472 : (PRE_first_tail_x15_r0_body.s1415.heap.get 2673472).isSome = true
kernel_rfl PRE_first_tail_x15_r0_body.zw160_2673473 : (PRE_first_tail_x15_r0_body.s1415.heap.get 2673473).isSome = true
-- the heap: the changed list in range, holding the stage's written and fresh addresses; the canonical side's image
kernel_rfl PRE_first_tail_x15_r0_body.zclbd160 : PRE_first_tail_x15_r0_body.cl160.all (fun b => Nat.blt (b / 4096) (4 ^ 31)) = true
kernel_rfl PRE_first_tail_x15_r0_body.zwr160 : PRE_first_tail_x15_r0_body.st160.wr.all (fun b => !Nat.blt b PRE_first_tail_x15_r0_body.s1413.next || PRE_first_tail_x15_r0_body.cl160.contains b) = true
def PRE_first_tail_x15_r0_body.zl160 : List Nat := PRE_first_tail_x15_r0_body.cl160.filter fun a => !(List.contains [2665, 2673467] a)
kernel_rfl PRE_first_tail_x15_r0_body.zimgE160 : PRE_first_tail_x15_r0_body.zl160.map (fun a => PRE_first_tail_x15_r0_body.s1414.heap.get (PRE_first_tail_x15_r0_body.kappa160.a a)) = PRE_first_tail_x15_r0_body.zl160.map (fun a => (PRE_first_tail_x15_r0_body.s1415.heap.get a).map PRE_first_tail_x15_r0_body.kappa160.hobj)
theorem PRE_first_tail_x15_r0_body.zimg160 : HeapImg PRE_first_tail_x15_r0_body.kappa160 PRE_first_tail_x15_r0_body.s1415 PRE_first_tail_x15_r0_body.s1414 PRE_first_tail_x15_r0_body.zl160 := PRE_first_tail_x15_r0_body.zimgE160
-- the roots and their supports
kernel_rfl PRE_first_tail_x15_r0_body.zctl160 : PRE_first_tail_x15_r0_body.s1414.ctl = PRE_first_tail_x15_r0_body.kappa160.ctl PRE_first_tail_x15_r0_body.s1415.ctl
kernel_rfl PRE_first_tail_x15_r0_body.zstack160 : PRE_first_tail_x15_r0_body.s1414.stack = PRE_first_tail_x15_r0_body.s1415.stack.map PRE_first_tail_x15_r0_body.kappa160.frame
kernel_rfl PRE_first_tail_x15_r0_body.zjobs160 : PRE_first_tail_x15_r0_body.s1414.jobs = PRE_first_tail_x15_r0_body.s1415.jobs.map PRE_first_tail_x15_r0_body.kappa160.job
kernel_rfl PRE_first_tail_x15_r0_body.zstores160 : PRE_first_tail_x15_r0_body.s1414.stores = PRE_first_tail_x15_r0_body.kappa160.stores PRE_first_tail_x15_r0_body.s1415.stores
kernel_rfl PRE_first_tail_x15_r0_body.zroots160 : checkRootsSupp PRE_first_tail_x15_r0_body.s1415 6920 = true
kernel_rfl PRE_first_tail_x15_r0_body.znC160 : PRE_first_tail_x15_r0_body.S1413.tab.length + PRE_first_tail_x15_r0_body.cws160.length = 6920
-- the map as `Conv.compact_shift` states it (the call's counters for the literals)
kernel_rfl PRE_first_tail_x15_r0_body.zkap160 : PRE_first_tail_x15_r0_body.kappa160 = Conv.Map.compact PRE_first_tail_x15_r0_body.s1413.next 2800633 PRE_first_tail_x15_r0_body.S1413.tab.length PRE_first_tail_x15_r0_body.pl160 (PRE_first_tail_x15_r0_body.nr160.map NumV.ref) PRE_first_tail_x15_r0_body.kd160.big
  PRE_first_tail_x15_r0_body.kd160.region PRE_first_tail_x15_r0_body.kd160.nodeF
-- the bridge inactive at the canonical state (`Conv.FullShiftQ.toX`; the merged state's bridge is the canonical's: cbridge)
theorem PRE_first_tail_x15_r0_body.zbin160 : (Host.Ts.Sim.Full.bridgeOf PRE_first_tail_x15_r0_body.s1415.ffi).active = false := (Host.Load.Boot.replay_active Host.Load.Run.Prompt.P.oblog2818)
-- the JS bookkeeping's step (`Conv.JClean.step` over the changed list) and the canonical roots' bigint freedom
kernel_rfl PRE_first_tail_x15_r0_body.zjc160 : Conv.jcleanListB (⟨21357, 18462, 2800631, 6920⟩ : Conv.Cnt) PRE_first_tail_x15_r0_body.s1415 PRE_first_tail_x15_r0_body.cl160 = true
kernel_rfl PRE_first_tail_x15_r0_body.zroots2160 : noBigRootsP (fun i => !Conv.oldBigB (⟨21357, 18462, 2800631, 6920⟩ : Conv.Cnt) i) PRE_first_tail_x15_r0_body.s1415.trace PRE_first_tail_x15_r0_body.s1415 = true
kernel_rfl PRE_first_tail_x15_r0_body.zhm160 : Nat.ble (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s0.ffi).mlx.nnext 18462 = true
theorem PRE_first_tail_x15_r0_body.cjcl160 (h : Conv.JClean (⟨21357, 18462, 2800631, 6920⟩ : Conv.Cnt) PRE_first_tail_x15_r0_body.s1413) : Conv.JClean (⟨21357, 18462, 2800631, 6920⟩ : Conv.Cnt) PRE_first_tail_x15_r0_body.s1415 :=
  Conv.JClean.step h (Conv.Cnt.le_of_leB PRE_first_tail_x15_r0_body.cle160)
    (Conv.heap_off_setAll PRE_first_tail_x15_r0_body.cheap160 fun a ha => Nat.blt_eq.mp (List.all_eq_true.mp PRE_first_tail_x15_r0_body.zclbd160 a ha)) PRE_first_tail_x15_r0_body.zjc160

end Host.Load.Run.Tpl
