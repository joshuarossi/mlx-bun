import host.sim.template.a4pre_first_tail_x15_r0_body.SiteS170
import host.sim.template.a4pre_first_tail_x15_r0_body.SiteK170
import host.sim.template.a4pre_first_tail_x15_r0_body.SiteF170
import host.sim.conv.CompactShift
import host.sim.template.Check
import host.sim.BigFreeP
import host.sim.template.CallGen
set_option Elab.async false
namespace Host.Load.Run.Tpl
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
open Host.Ts Host.Ts.Sim Host.Ts.Sim.Template

/-! The compaction's state shift at call site 170 of chain `PRE_first_tail_x15_r0_body` (`Conv.compact_shift`): the call `PRE_first_tail_x15_r0_body.s1495`, the merged
state `PRE_first_tail_x15_r0_body.s1496`, the canonical state `PRE_first_tail_x15_r0_body.s1497`; its frames [2665,2673467,2673472,2673473] (kept arrays [2665,2673467]). -/

-- the map's places and counters
kernel_rfl PRE_first_tail_x15_r0_body.zpl170 : PRE_first_tail_x15_r0_body.pl170.all (Nat.ble PRE_first_tail_x15_r0_body.s1495.next) = true
kernel_rfl PRE_first_tail_x15_r0_body.zplnd170 : nodupT PRE_first_tail_x15_r0_body.pl170 PTrie.nil = true
kernel_rfl PRE_first_tail_x15_r0_body.zn1170 : Nat.ble PRE_first_tail_x15_r0_body.s1495.next 2808103 = true
kernel_rfl PRE_first_tail_x15_r0_body.zfirst170 : Nat.ble aFirst PRE_first_tail_x15_r0_body.s1495.next = true
kernel_rfl PRE_first_tail_x15_r0_body.zscn170 : PRE_first_tail_x15_r0_body.s1497.next = PRE_first_tail_x15_r0_body.s1495.next + PRE_first_tail_x15_r0_body.pl170.length
kernel_rfl PRE_first_tail_x15_r0_body.zsmn170 : PRE_first_tail_x15_r0_body.s1496.next = 2808103
kernel_rfl PRE_first_tail_x15_r0_body.zgrow170 : Nat.ble PRE_first_tail_x15_r0_body.s1497.next PRE_first_tail_x15_r0_body.s1496.next = true
-- the tables
kernel_rfl PRE_first_tail_x15_r0_body.zfresh170 : PRE_first_tail_x15_r0_body.S1495.tab.all (fun e => PRE_first_tail_x15_r0_body.cws170.all fun v => e.noVar v) = true
kernel_rfl PRE_first_tail_x15_r0_body.zcnd170 : nodupT PRE_first_tail_x15_r0_body.cws170 PTrie.nil = true
kernel_rfl PRE_first_tail_x15_r0_body.znrHi170 : PRE_first_tail_x15_r0_body.nr170.all (fun r => Nat.blt r PRE_first_tail_x15_r0_body.S1496.tab.length) = true
-- the frames: every framed address below the call's counter; the kept arrays the chain start's, extended in the merged state
kernel_rfl PRE_first_tail_x15_r0_body.zfrlt170 : [2665, 2673467, 2673472, 2673473].all (fun a => Nat.blt a PRE_first_tail_x15_r0_body.s1495.next) = true
kernel_rfl PRE_first_tail_x15_r0_body.zg170_2665 : PRE_first_tail_x15_r0_body.s1497.heap.get 2665 = some (.obj (objOf PRE_first_tail_x15_r0_body.s1497 2665))
kernel_rfl PRE_first_tail_x15_r0_body.zk170_2665 : (objOf PRE_first_tail_x15_r0_body.s1497 2665).kind = .array (arrOf PRE_first_tail_x15_r0_body.s0 2665)
kernel_rfl PRE_first_tail_x15_r0_body.zm170_2665 : PRE_first_tail_x15_r0_body.s1496.heap.get 2665 = some (.obj { PRE_first_tail_x15_r0_body.kappa170.obj (objOf PRE_first_tail_x15_r0_body.s1497 2665) with
  kind := .array (arrOf PRE_first_tail_x15_r0_body.s0 2665 ++ (arrOf PRE_first_tail_x15_r0_body.s1496 2665).drop (arrOf PRE_first_tail_x15_r0_body.s0 2665).length) })
kernel_rfl PRE_first_tail_x15_r0_body.zg170_2673467 : PRE_first_tail_x15_r0_body.s1497.heap.get 2673467 = some (.obj (objOf PRE_first_tail_x15_r0_body.s1497 2673467))
kernel_rfl PRE_first_tail_x15_r0_body.zk170_2673467 : (objOf PRE_first_tail_x15_r0_body.s1497 2673467).kind = .array (arrOf PRE_first_tail_x15_r0_body.s0 2673467)
kernel_rfl PRE_first_tail_x15_r0_body.zm170_2673467 : PRE_first_tail_x15_r0_body.s1496.heap.get 2673467 = some (.obj { PRE_first_tail_x15_r0_body.kappa170.obj (objOf PRE_first_tail_x15_r0_body.s1497 2673467) with
  kind := .array (arrOf PRE_first_tail_x15_r0_body.s0 2673467 ++ (arrOf PRE_first_tail_x15_r0_body.s1496 2673467).drop (arrOf PRE_first_tail_x15_r0_body.s0 2673467).length) })
kernel_rfl PRE_first_tail_x15_r0_body.zw170_4910 : (PRE_first_tail_x15_r0_body.s1497.heap.get 4910).isSome = true
kernel_rfl PRE_first_tail_x15_r0_body.zw170_2673472 : (PRE_first_tail_x15_r0_body.s1497.heap.get 2673472).isSome = true
kernel_rfl PRE_first_tail_x15_r0_body.zw170_2673473 : (PRE_first_tail_x15_r0_body.s1497.heap.get 2673473).isSome = true
-- the heap: the changed list in range, holding the stage's written and fresh addresses; the canonical side's image
kernel_rfl PRE_first_tail_x15_r0_body.zclbd170 : PRE_first_tail_x15_r0_body.cl170.all (fun b => Nat.blt (b / 4096) (4 ^ 31)) = true
kernel_rfl PRE_first_tail_x15_r0_body.zwr170 : PRE_first_tail_x15_r0_body.st170.wr.all (fun b => !Nat.blt b PRE_first_tail_x15_r0_body.s1495.next || PRE_first_tail_x15_r0_body.cl170.contains b) = true
def PRE_first_tail_x15_r0_body.zl170 : List Nat := PRE_first_tail_x15_r0_body.cl170.filter fun a => !(List.contains [2665, 2673467] a)
kernel_rfl PRE_first_tail_x15_r0_body.zimgE170 : PRE_first_tail_x15_r0_body.zl170.map (fun a => PRE_first_tail_x15_r0_body.s1496.heap.get (PRE_first_tail_x15_r0_body.kappa170.a a)) = PRE_first_tail_x15_r0_body.zl170.map (fun a => (PRE_first_tail_x15_r0_body.s1497.heap.get a).map PRE_first_tail_x15_r0_body.kappa170.hobj)
theorem PRE_first_tail_x15_r0_body.zimg170 : HeapImg PRE_first_tail_x15_r0_body.kappa170 PRE_first_tail_x15_r0_body.s1497 PRE_first_tail_x15_r0_body.s1496 PRE_first_tail_x15_r0_body.zl170 := PRE_first_tail_x15_r0_body.zimgE170
-- the roots and their supports
kernel_rfl PRE_first_tail_x15_r0_body.zctl170 : PRE_first_tail_x15_r0_body.s1496.ctl = PRE_first_tail_x15_r0_body.kappa170.ctl PRE_first_tail_x15_r0_body.s1497.ctl
kernel_rfl PRE_first_tail_x15_r0_body.zstack170 : PRE_first_tail_x15_r0_body.s1496.stack = PRE_first_tail_x15_r0_body.s1497.stack.map PRE_first_tail_x15_r0_body.kappa170.frame
kernel_rfl PRE_first_tail_x15_r0_body.zjobs170 : PRE_first_tail_x15_r0_body.s1496.jobs = PRE_first_tail_x15_r0_body.s1497.jobs.map PRE_first_tail_x15_r0_body.kappa170.job
kernel_rfl PRE_first_tail_x15_r0_body.zstores170 : PRE_first_tail_x15_r0_body.s1496.stores = PRE_first_tail_x15_r0_body.kappa170.stores PRE_first_tail_x15_r0_body.s1497.stores
kernel_rfl PRE_first_tail_x15_r0_body.zroots170 : checkRootsSupp PRE_first_tail_x15_r0_body.s1497 7321 = true
kernel_rfl PRE_first_tail_x15_r0_body.znC170 : PRE_first_tail_x15_r0_body.S1495.tab.length + PRE_first_tail_x15_r0_body.cws170.length = 7321
-- the map as `Conv.compact_shift` states it (the call's counters for the literals)
kernel_rfl PRE_first_tail_x15_r0_body.zkap170 : PRE_first_tail_x15_r0_body.kappa170 = Conv.Map.compact PRE_first_tail_x15_r0_body.s1495.next 2808103 PRE_first_tail_x15_r0_body.S1495.tab.length PRE_first_tail_x15_r0_body.pl170 (PRE_first_tail_x15_r0_body.nr170.map NumV.ref) PRE_first_tail_x15_r0_body.kd170.big
  PRE_first_tail_x15_r0_body.kd170.region PRE_first_tail_x15_r0_body.kd170.nodeF
-- the bridge inactive at the canonical state (`Conv.FullShiftQ.toX`; the merged state's bridge is the canonical's: cbridge)
theorem PRE_first_tail_x15_r0_body.zbin170 : (Host.Ts.Sim.Full.bridgeOf PRE_first_tail_x15_r0_body.s1497.ffi).active = false := (Host.Load.Boot.replay_active Host.Load.Run.Prompt.P.oblog2818)
-- the JS bookkeeping's step (`Conv.JClean.step` over the changed list) and the canonical roots' bigint freedom
kernel_rfl PRE_first_tail_x15_r0_body.zjc170 : Conv.jcleanListB (⟨21543, 18640, 2808084, 7321⟩ : Conv.Cnt) PRE_first_tail_x15_r0_body.s1497 PRE_first_tail_x15_r0_body.cl170 = true
kernel_rfl PRE_first_tail_x15_r0_body.zroots2170 : noBigRootsP (fun i => !Conv.oldBigB (⟨21543, 18640, 2808084, 7321⟩ : Conv.Cnt) i) PRE_first_tail_x15_r0_body.s1497.trace PRE_first_tail_x15_r0_body.s1497 = true
kernel_rfl PRE_first_tail_x15_r0_body.zhm170 : Nat.ble (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s0.ffi).mlx.nnext 18640 = true
theorem PRE_first_tail_x15_r0_body.cjcl170 (h : Conv.JClean (⟨21543, 18640, 2808083, 7321⟩ : Conv.Cnt) PRE_first_tail_x15_r0_body.s1495) : Conv.JClean (⟨21543, 18640, 2808084, 7321⟩ : Conv.Cnt) PRE_first_tail_x15_r0_body.s1497 :=
  Conv.JClean.step h (Conv.Cnt.le_of_leB PRE_first_tail_x15_r0_body.cle170)
    (Conv.heap_off_setAll PRE_first_tail_x15_r0_body.cheap170 fun a ha => Nat.blt_eq.mp (List.all_eq_true.mp PRE_first_tail_x15_r0_body.zclbd170 a ha)) PRE_first_tail_x15_r0_body.zjc170

end Host.Load.Run.Tpl
