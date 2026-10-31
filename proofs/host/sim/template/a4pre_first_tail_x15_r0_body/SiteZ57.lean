import host.sim.template.a4pre_first_tail_x15_r0_body.SiteS57
import host.sim.template.a4pre_first_tail_x15_r0_body.SiteK57
import host.sim.template.a4pre_first_tail_x15_r0_body.SiteF57
import host.sim.conv.CompactShift
import host.sim.template.Check
import host.sim.BigFreeP
import host.sim.template.CallGen
set_option Elab.async false
namespace Host.Load.Run.Tpl
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
open Host.Ts Host.Ts.Sim Host.Ts.Sim.Template

/-! The compaction's state shift at call site 57 of chain `PRE_first_tail_x15_r0_body` (`Conv.compact_shift`): the call `PRE_first_tail_x15_r0_body.s562`, the merged
state `PRE_first_tail_x15_r0_body.s563`, the canonical state `PRE_first_tail_x15_r0_body.s564`; its frames [2665,2673467,2673472,2673473] (kept arrays [2665,2673467]). -/

-- the map's places and counters
kernel_rfl PRE_first_tail_x15_r0_body.zpl57 : PRE_first_tail_x15_r0_body.pl57.all (Nat.ble PRE_first_tail_x15_r0_body.s562.next) = true
kernel_rfl PRE_first_tail_x15_r0_body.zplnd57 : nodupT PRE_first_tail_x15_r0_body.pl57 PTrie.nil = true
kernel_rfl PRE_first_tail_x15_r0_body.zn157 : Nat.ble PRE_first_tail_x15_r0_body.s562.next 2720533 = true
kernel_rfl PRE_first_tail_x15_r0_body.zfirst57 : Nat.ble aFirst PRE_first_tail_x15_r0_body.s562.next = true
kernel_rfl PRE_first_tail_x15_r0_body.zscn57 : PRE_first_tail_x15_r0_body.s564.next = PRE_first_tail_x15_r0_body.s562.next + PRE_first_tail_x15_r0_body.pl57.length
kernel_rfl PRE_first_tail_x15_r0_body.zsmn57 : PRE_first_tail_x15_r0_body.s563.next = 2720533
kernel_rfl PRE_first_tail_x15_r0_body.zgrow57 : Nat.ble PRE_first_tail_x15_r0_body.s564.next PRE_first_tail_x15_r0_body.s563.next = true
-- the tables
kernel_rfl PRE_first_tail_x15_r0_body.zfresh57 : PRE_first_tail_x15_r0_body.S562.tab.all (fun e => PRE_first_tail_x15_r0_body.cws57.all fun v => e.noVar v) = true
kernel_rfl PRE_first_tail_x15_r0_body.zcnd57 : nodupT PRE_first_tail_x15_r0_body.cws57 PTrie.nil = true
kernel_rfl PRE_first_tail_x15_r0_body.znrHi57 : PRE_first_tail_x15_r0_body.nr57.all (fun r => Nat.blt r PRE_first_tail_x15_r0_body.S563.tab.length) = true
-- the frames: every framed address below the call's counter; the kept arrays the chain start's, extended in the merged state
kernel_rfl PRE_first_tail_x15_r0_body.zfrlt57 : [2665, 2673467, 2673472, 2673473].all (fun a => Nat.blt a PRE_first_tail_x15_r0_body.s562.next) = true
kernel_rfl PRE_first_tail_x15_r0_body.zg57_2665 : PRE_first_tail_x15_r0_body.s564.heap.get 2665 = some (.obj (objOf PRE_first_tail_x15_r0_body.s564 2665))
kernel_rfl PRE_first_tail_x15_r0_body.zk57_2665 : (objOf PRE_first_tail_x15_r0_body.s564 2665).kind = .array (arrOf PRE_first_tail_x15_r0_body.s0 2665)
kernel_rfl PRE_first_tail_x15_r0_body.zm57_2665 : PRE_first_tail_x15_r0_body.s563.heap.get 2665 = some (.obj { PRE_first_tail_x15_r0_body.kappa57.obj (objOf PRE_first_tail_x15_r0_body.s564 2665) with
  kind := .array (arrOf PRE_first_tail_x15_r0_body.s0 2665 ++ (arrOf PRE_first_tail_x15_r0_body.s563 2665).drop (arrOf PRE_first_tail_x15_r0_body.s0 2665).length) })
kernel_rfl PRE_first_tail_x15_r0_body.zg57_2673467 : PRE_first_tail_x15_r0_body.s564.heap.get 2673467 = some (.obj (objOf PRE_first_tail_x15_r0_body.s564 2673467))
kernel_rfl PRE_first_tail_x15_r0_body.zk57_2673467 : (objOf PRE_first_tail_x15_r0_body.s564 2673467).kind = .array (arrOf PRE_first_tail_x15_r0_body.s0 2673467)
kernel_rfl PRE_first_tail_x15_r0_body.zm57_2673467 : PRE_first_tail_x15_r0_body.s563.heap.get 2673467 = some (.obj { PRE_first_tail_x15_r0_body.kappa57.obj (objOf PRE_first_tail_x15_r0_body.s564 2673467) with
  kind := .array (arrOf PRE_first_tail_x15_r0_body.s0 2673467 ++ (arrOf PRE_first_tail_x15_r0_body.s563 2673467).drop (arrOf PRE_first_tail_x15_r0_body.s0 2673467).length) })
kernel_rfl PRE_first_tail_x15_r0_body.zw57_4910 : (PRE_first_tail_x15_r0_body.s564.heap.get 4910).isSome = true
kernel_rfl PRE_first_tail_x15_r0_body.zw57_2673472 : (PRE_first_tail_x15_r0_body.s564.heap.get 2673472).isSome = true
kernel_rfl PRE_first_tail_x15_r0_body.zw57_2673473 : (PRE_first_tail_x15_r0_body.s564.heap.get 2673473).isSome = true
-- the heap: the changed list in range, holding the stage's written and fresh addresses; the canonical side's image
kernel_rfl PRE_first_tail_x15_r0_body.zclbd57 : PRE_first_tail_x15_r0_body.cl57.all (fun b => Nat.blt (b / 4096) (4 ^ 31)) = true
kernel_rfl PRE_first_tail_x15_r0_body.zwr57 : PRE_first_tail_x15_r0_body.st57.wr.all (fun b => !Nat.blt b PRE_first_tail_x15_r0_body.s562.next || PRE_first_tail_x15_r0_body.cl57.contains b) = true
def PRE_first_tail_x15_r0_body.zl57 : List Nat := PRE_first_tail_x15_r0_body.cl57.filter fun a => !(List.contains [2665, 2673467] a)
kernel_rfl PRE_first_tail_x15_r0_body.zimgE57 : PRE_first_tail_x15_r0_body.zl57.map (fun a => PRE_first_tail_x15_r0_body.s563.heap.get (PRE_first_tail_x15_r0_body.kappa57.a a)) = PRE_first_tail_x15_r0_body.zl57.map (fun a => (PRE_first_tail_x15_r0_body.s564.heap.get a).map PRE_first_tail_x15_r0_body.kappa57.hobj)
theorem PRE_first_tail_x15_r0_body.zimg57 : HeapImg PRE_first_tail_x15_r0_body.kappa57 PRE_first_tail_x15_r0_body.s564 PRE_first_tail_x15_r0_body.s563 PRE_first_tail_x15_r0_body.zl57 := PRE_first_tail_x15_r0_body.zimgE57
-- the roots and their supports
kernel_rfl PRE_first_tail_x15_r0_body.zctl57 : PRE_first_tail_x15_r0_body.s563.ctl = PRE_first_tail_x15_r0_body.kappa57.ctl PRE_first_tail_x15_r0_body.s564.ctl
kernel_rfl PRE_first_tail_x15_r0_body.zstack57 : PRE_first_tail_x15_r0_body.s563.stack = PRE_first_tail_x15_r0_body.s564.stack.map PRE_first_tail_x15_r0_body.kappa57.frame
kernel_rfl PRE_first_tail_x15_r0_body.zjobs57 : PRE_first_tail_x15_r0_body.s563.jobs = PRE_first_tail_x15_r0_body.s564.jobs.map PRE_first_tail_x15_r0_body.kappa57.job
kernel_rfl PRE_first_tail_x15_r0_body.zstores57 : PRE_first_tail_x15_r0_body.s563.stores = PRE_first_tail_x15_r0_body.kappa57.stores PRE_first_tail_x15_r0_body.s564.stores
kernel_rfl PRE_first_tail_x15_r0_body.zroots57 : checkRootsSupp PRE_first_tail_x15_r0_body.s564 2535 = true
kernel_rfl PRE_first_tail_x15_r0_body.znC57 : PRE_first_tail_x15_r0_body.S562.tab.length + PRE_first_tail_x15_r0_body.cws57.length = 2535
-- the map as `Conv.compact_shift` states it (the call's counters for the literals)
kernel_rfl PRE_first_tail_x15_r0_body.zkap57 : PRE_first_tail_x15_r0_body.kappa57 = Conv.Map.compact PRE_first_tail_x15_r0_body.s562.next 2720533 PRE_first_tail_x15_r0_body.S562.tab.length PRE_first_tail_x15_r0_body.pl57 (PRE_first_tail_x15_r0_body.nr57.map NumV.ref) PRE_first_tail_x15_r0_body.kd57.big
  PRE_first_tail_x15_r0_body.kd57.region PRE_first_tail_x15_r0_body.kd57.nodeF
-- the bridge inactive at the canonical state (`Conv.FullShiftQ.toX`; the merged state's bridge is the canonical's: cbridge)
theorem PRE_first_tail_x15_r0_body.zbin57 : (Host.Ts.Sim.Full.bridgeOf PRE_first_tail_x15_r0_body.s564.ffi).active = false := (Host.Load.Boot.replay_active Host.Load.Run.Prompt.P.oblog2818)
-- the JS bookkeeping's step (`Conv.JClean.step` over the changed list) and the canonical roots' bigint freedom
kernel_rfl PRE_first_tail_x15_r0_body.zjc57 : Conv.jcleanListB (⟨19341, 16430, 2720183, 2535⟩ : Conv.Cnt) PRE_first_tail_x15_r0_body.s564 PRE_first_tail_x15_r0_body.cl57 = true
kernel_rfl PRE_first_tail_x15_r0_body.zrootsB57 : noBigRootsP (fun i => !Conv.oldBigB (⟨19341, 16430, 2720183, 2535⟩ : Conv.Cnt) i) PRE_first_tail_x15_r0_body.s564.trace PRE_first_tail_x15_r0_body.s564 = true
kernel_rfl PRE_first_tail_x15_r0_body.zhm57 : Nat.ble (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s0.ffi).mlx.nnext 16424 = true
theorem PRE_first_tail_x15_r0_body.cjcl57 (h : Conv.JClean (⟨19337, 16424, 2720168, 2526⟩ : Conv.Cnt) PRE_first_tail_x15_r0_body.s562) : Conv.JClean (⟨19341, 16430, 2720183, 2535⟩ : Conv.Cnt) PRE_first_tail_x15_r0_body.s564 :=
  Conv.JClean.step h (Conv.Cnt.le_of_leB PRE_first_tail_x15_r0_body.cle57)
    (Conv.heap_off_setAll PRE_first_tail_x15_r0_body.cheap57 fun a ha => Nat.blt_eq.mp (List.all_eq_true.mp PRE_first_tail_x15_r0_body.zclbd57 a ha)) PRE_first_tail_x15_r0_body.zjc57

end Host.Load.Run.Tpl
