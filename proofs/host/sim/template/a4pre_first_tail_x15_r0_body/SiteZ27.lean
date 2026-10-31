import host.sim.template.a4pre_first_tail_x15_r0_body.SiteS27
import host.sim.template.a4pre_first_tail_x15_r0_body.SiteK27
import host.sim.template.a4pre_first_tail_x15_r0_body.SiteF27
import host.sim.conv.CompactShift
import host.sim.template.Check
import host.sim.BigFreeP
import host.sim.template.CallGen
set_option Elab.async false
namespace Host.Load.Run.Tpl
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
open Host.Ts Host.Ts.Sim Host.Ts.Sim.Template

/-! The compaction's state shift at call site 27 of chain `PRE_first_tail_x15_r0_body` (`Conv.compact_shift`): the call `PRE_first_tail_x15_r0_body.s251`, the merged
state `PRE_first_tail_x15_r0_body.s252`, the canonical state `PRE_first_tail_x15_r0_body.s253`; its frames [2665,2673467,2673472,2673473] (kept arrays [2665,2673467]). -/

-- the map's places and counters
kernel_rfl PRE_first_tail_x15_r0_body.zpl27 : PRE_first_tail_x15_r0_body.pl27.all (Nat.ble PRE_first_tail_x15_r0_body.s251.next) = true
kernel_rfl PRE_first_tail_x15_r0_body.zplnd27 : nodupT PRE_first_tail_x15_r0_body.pl27 PTrie.nil = true
kernel_rfl PRE_first_tail_x15_r0_body.zn127 : Nat.ble PRE_first_tail_x15_r0_body.s251.next 2697698 = true
kernel_rfl PRE_first_tail_x15_r0_body.zfirst27 : Nat.ble aFirst PRE_first_tail_x15_r0_body.s251.next = true
kernel_rfl PRE_first_tail_x15_r0_body.zscn27 : PRE_first_tail_x15_r0_body.s253.next = PRE_first_tail_x15_r0_body.s251.next + PRE_first_tail_x15_r0_body.pl27.length
kernel_rfl PRE_first_tail_x15_r0_body.zsmn27 : PRE_first_tail_x15_r0_body.s252.next = 2697698
kernel_rfl PRE_first_tail_x15_r0_body.zgrow27 : Nat.ble PRE_first_tail_x15_r0_body.s253.next PRE_first_tail_x15_r0_body.s252.next = true
-- the tables
kernel_rfl PRE_first_tail_x15_r0_body.zfresh27 : PRE_first_tail_x15_r0_body.S251.tab.all (fun e => PRE_first_tail_x15_r0_body.cws27.all fun v => e.noVar v) = true
kernel_rfl PRE_first_tail_x15_r0_body.zcnd27 : nodupT PRE_first_tail_x15_r0_body.cws27 PTrie.nil = true
kernel_rfl PRE_first_tail_x15_r0_body.znrHi27 : PRE_first_tail_x15_r0_body.nr27.all (fun r => Nat.blt r PRE_first_tail_x15_r0_body.S252.tab.length) = true
-- the frames: every framed address below the call's counter; the kept arrays the chain start's, extended in the merged state
kernel_rfl PRE_first_tail_x15_r0_body.zfrlt27 : [2665, 2673467, 2673472, 2673473].all (fun a => Nat.blt a PRE_first_tail_x15_r0_body.s251.next) = true
kernel_rfl PRE_first_tail_x15_r0_body.zg27_2665 : PRE_first_tail_x15_r0_body.s253.heap.get 2665 = some (.obj (objOf PRE_first_tail_x15_r0_body.s253 2665))
kernel_rfl PRE_first_tail_x15_r0_body.zk27_2665 : (objOf PRE_first_tail_x15_r0_body.s253 2665).kind = .array (arrOf PRE_first_tail_x15_r0_body.s0 2665)
kernel_rfl PRE_first_tail_x15_r0_body.zm27_2665 : PRE_first_tail_x15_r0_body.s252.heap.get 2665 = some (.obj { PRE_first_tail_x15_r0_body.kappa27.obj (objOf PRE_first_tail_x15_r0_body.s253 2665) with
  kind := .array (arrOf PRE_first_tail_x15_r0_body.s0 2665 ++ (arrOf PRE_first_tail_x15_r0_body.s252 2665).drop (arrOf PRE_first_tail_x15_r0_body.s0 2665).length) })
kernel_rfl PRE_first_tail_x15_r0_body.zg27_2673467 : PRE_first_tail_x15_r0_body.s253.heap.get 2673467 = some (.obj (objOf PRE_first_tail_x15_r0_body.s253 2673467))
kernel_rfl PRE_first_tail_x15_r0_body.zk27_2673467 : (objOf PRE_first_tail_x15_r0_body.s253 2673467).kind = .array (arrOf PRE_first_tail_x15_r0_body.s0 2673467)
kernel_rfl PRE_first_tail_x15_r0_body.zm27_2673467 : PRE_first_tail_x15_r0_body.s252.heap.get 2673467 = some (.obj { PRE_first_tail_x15_r0_body.kappa27.obj (objOf PRE_first_tail_x15_r0_body.s253 2673467) with
  kind := .array (arrOf PRE_first_tail_x15_r0_body.s0 2673467 ++ (arrOf PRE_first_tail_x15_r0_body.s252 2673467).drop (arrOf PRE_first_tail_x15_r0_body.s0 2673467).length) })
kernel_rfl PRE_first_tail_x15_r0_body.zw27_4910 : (PRE_first_tail_x15_r0_body.s253.heap.get 4910).isSome = true
kernel_rfl PRE_first_tail_x15_r0_body.zw27_2673472 : (PRE_first_tail_x15_r0_body.s253.heap.get 2673472).isSome = true
kernel_rfl PRE_first_tail_x15_r0_body.zw27_2673473 : (PRE_first_tail_x15_r0_body.s253.heap.get 2673473).isSome = true
-- the heap: the changed list in range, holding the stage's written and fresh addresses; the canonical side's image
kernel_rfl PRE_first_tail_x15_r0_body.zclbd27 : PRE_first_tail_x15_r0_body.cl27.all (fun b => Nat.blt (b / 4096) (4 ^ 31)) = true
kernel_rfl PRE_first_tail_x15_r0_body.zwr27 : PRE_first_tail_x15_r0_body.st27.wr.all (fun b => !Nat.blt b PRE_first_tail_x15_r0_body.s251.next || PRE_first_tail_x15_r0_body.cl27.contains b) = true
def PRE_first_tail_x15_r0_body.zl27 : List Nat := PRE_first_tail_x15_r0_body.cl27.filter fun a => !(List.contains [2665, 2673467] a)
kernel_rfl PRE_first_tail_x15_r0_body.zimgE27 : PRE_first_tail_x15_r0_body.zl27.map (fun a => PRE_first_tail_x15_r0_body.s252.heap.get (PRE_first_tail_x15_r0_body.kappa27.a a)) = PRE_first_tail_x15_r0_body.zl27.map (fun a => (PRE_first_tail_x15_r0_body.s253.heap.get a).map PRE_first_tail_x15_r0_body.kappa27.hobj)
theorem PRE_first_tail_x15_r0_body.zimg27 : HeapImg PRE_first_tail_x15_r0_body.kappa27 PRE_first_tail_x15_r0_body.s253 PRE_first_tail_x15_r0_body.s252 PRE_first_tail_x15_r0_body.zl27 := PRE_first_tail_x15_r0_body.zimgE27
-- the roots and their supports
kernel_rfl PRE_first_tail_x15_r0_body.zctl27 : PRE_first_tail_x15_r0_body.s252.ctl = PRE_first_tail_x15_r0_body.kappa27.ctl PRE_first_tail_x15_r0_body.s253.ctl
kernel_rfl PRE_first_tail_x15_r0_body.zstack27 : PRE_first_tail_x15_r0_body.s252.stack = PRE_first_tail_x15_r0_body.s253.stack.map PRE_first_tail_x15_r0_body.kappa27.frame
kernel_rfl PRE_first_tail_x15_r0_body.zjobs27 : PRE_first_tail_x15_r0_body.s252.jobs = PRE_first_tail_x15_r0_body.s253.jobs.map PRE_first_tail_x15_r0_body.kappa27.job
kernel_rfl PRE_first_tail_x15_r0_body.zstores27 : PRE_first_tail_x15_r0_body.s252.stores = PRE_first_tail_x15_r0_body.kappa27.stores PRE_first_tail_x15_r0_body.s253.stores
kernel_rfl PRE_first_tail_x15_r0_body.zroots27 : checkRootsSupp PRE_first_tail_x15_r0_body.s253 1256 = true
kernel_rfl PRE_first_tail_x15_r0_body.znC27 : PRE_first_tail_x15_r0_body.S251.tab.length + PRE_first_tail_x15_r0_body.cws27.length = 1256
-- the map as `Conv.compact_shift` states it (the call's counters for the literals)
kernel_rfl PRE_first_tail_x15_r0_body.zkap27 : PRE_first_tail_x15_r0_body.kappa27 = Conv.Map.compact PRE_first_tail_x15_r0_body.s251.next 2697698 PRE_first_tail_x15_r0_body.S251.tab.length PRE_first_tail_x15_r0_body.pl27 (PRE_first_tail_x15_r0_body.nr27.map NumV.ref) PRE_first_tail_x15_r0_body.kd27.big
  PRE_first_tail_x15_r0_body.kd27.region PRE_first_tail_x15_r0_body.kd27.nodeF
-- the bridge inactive at the canonical state (`Conv.FullShiftQ.toX`; the merged state's bridge is the canonical's: cbridge)
theorem PRE_first_tail_x15_r0_body.zbin27 : (Host.Ts.Sim.Full.bridgeOf PRE_first_tail_x15_r0_body.s253.ffi).active = false := (Host.Load.Boot.replay_active Host.Load.Run.Prompt.P.oblog2818)
-- the JS bookkeeping's step (`Conv.JClean.step` over the changed list) and the canonical roots' bigint freedom
kernel_rfl PRE_first_tail_x15_r0_body.zjc27 : Conv.jcleanListB (⟨18748, 15842, 2696549, 1256⟩ : Conv.Cnt) PRE_first_tail_x15_r0_body.s253 PRE_first_tail_x15_r0_body.cl27 = true
kernel_rfl PRE_first_tail_x15_r0_body.zroots227 : noBigRootsP (fun i => !Conv.oldBigB (⟨18748, 15842, 2696549, 1256⟩ : Conv.Cnt) i) PRE_first_tail_x15_r0_body.s253.trace PRE_first_tail_x15_r0_body.s253 = true
kernel_rfl PRE_first_tail_x15_r0_body.zhm27 : Nat.ble (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s0.ffi).mlx.nnext 15815 = true
theorem PRE_first_tail_x15_r0_body.cjcl27 (h : Conv.JClean (⟨18745, 15815, 2696543, 1238⟩ : Conv.Cnt) PRE_first_tail_x15_r0_body.s251) : Conv.JClean (⟨18748, 15842, 2696549, 1256⟩ : Conv.Cnt) PRE_first_tail_x15_r0_body.s253 :=
  Conv.JClean.step h (Conv.Cnt.le_of_leB PRE_first_tail_x15_r0_body.cle27)
    (Conv.heap_off_setAll PRE_first_tail_x15_r0_body.cheap27 fun a ha => Nat.blt_eq.mp (List.all_eq_true.mp PRE_first_tail_x15_r0_body.zclbd27 a ha)) PRE_first_tail_x15_r0_body.zjc27

end Host.Load.Run.Tpl
