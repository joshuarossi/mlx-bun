import host.sim.template.a4pre_first_tail_x15_r0_body.SiteS144
import host.sim.template.a4pre_first_tail_x15_r0_body.SiteK144
import host.sim.template.a4pre_first_tail_x15_r0_body.SiteF144
import host.sim.conv.CompactShift
import host.sim.template.Check
import host.sim.BigFreeP
import host.sim.template.CallGen
set_option Elab.async false
namespace Host.Load.Run.Tpl
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
open Host.Ts Host.Ts.Sim Host.Ts.Sim.Template

/-! The compaction's state shift at call site 144 of chain `PRE_first_tail_x15_r0_body` (`Conv.compact_shift`): the call `PRE_first_tail_x15_r0_body.s1396`, the merged
state `PRE_first_tail_x15_r0_body.s1397`, the canonical state `PRE_first_tail_x15_r0_body.s1398`; its frames [2665,2673467,2673472,2673473] (kept arrays [2665,2673467]). -/

-- the map's places and counters
kernel_rfl PRE_first_tail_x15_r0_body.zpl144 : PRE_first_tail_x15_r0_body.pl144.all (Nat.ble PRE_first_tail_x15_r0_body.s1396.next) = true
kernel_rfl PRE_first_tail_x15_r0_body.zplnd144 : nodupT PRE_first_tail_x15_r0_body.pl144 PTrie.nil = true
kernel_rfl PRE_first_tail_x15_r0_body.zn1144 : Nat.ble PRE_first_tail_x15_r0_body.s1396.next 2789614 = true
kernel_rfl PRE_first_tail_x15_r0_body.zfirst144 : Nat.ble aFirst PRE_first_tail_x15_r0_body.s1396.next = true
kernel_rfl PRE_first_tail_x15_r0_body.zscn144 : PRE_first_tail_x15_r0_body.s1398.next = PRE_first_tail_x15_r0_body.s1396.next + PRE_first_tail_x15_r0_body.pl144.length
kernel_rfl PRE_first_tail_x15_r0_body.zsmn144 : PRE_first_tail_x15_r0_body.s1397.next = 2789614
kernel_rfl PRE_first_tail_x15_r0_body.zgrow144 : Nat.ble PRE_first_tail_x15_r0_body.s1398.next PRE_first_tail_x15_r0_body.s1397.next = true
-- the tables
kernel_rfl PRE_first_tail_x15_r0_body.zfresh144 : PRE_first_tail_x15_r0_body.S1396.tab.all (fun e => PRE_first_tail_x15_r0_body.cws144.all fun v => e.noVar v) = true
kernel_rfl PRE_first_tail_x15_r0_body.zcnd144 : nodupT PRE_first_tail_x15_r0_body.cws144 PTrie.nil = true
kernel_rfl PRE_first_tail_x15_r0_body.znrHi144 : PRE_first_tail_x15_r0_body.nr144.all (fun r => Nat.blt r PRE_first_tail_x15_r0_body.S1397.tab.length) = true
-- the frames: every framed address below the call's counter; the kept arrays the chain start's, extended in the merged state
kernel_rfl PRE_first_tail_x15_r0_body.zfrlt144 : [2665, 2673467, 2673472, 2673473].all (fun a => Nat.blt a PRE_first_tail_x15_r0_body.s1396.next) = true
kernel_rfl PRE_first_tail_x15_r0_body.zg144_2665 : PRE_first_tail_x15_r0_body.s1398.heap.get 2665 = some (.obj (objOf PRE_first_tail_x15_r0_body.s1398 2665))
kernel_rfl PRE_first_tail_x15_r0_body.zk144_2665 : (objOf PRE_first_tail_x15_r0_body.s1398 2665).kind = .array (arrOf PRE_first_tail_x15_r0_body.s0 2665)
kernel_rfl PRE_first_tail_x15_r0_body.zm144_2665 : PRE_first_tail_x15_r0_body.s1397.heap.get 2665 = some (.obj { PRE_first_tail_x15_r0_body.kappa144.obj (objOf PRE_first_tail_x15_r0_body.s1398 2665) with
  kind := .array (arrOf PRE_first_tail_x15_r0_body.s0 2665 ++ (arrOf PRE_first_tail_x15_r0_body.s1397 2665).drop (arrOf PRE_first_tail_x15_r0_body.s0 2665).length) })
kernel_rfl PRE_first_tail_x15_r0_body.zg144_2673467 : PRE_first_tail_x15_r0_body.s1398.heap.get 2673467 = some (.obj (objOf PRE_first_tail_x15_r0_body.s1398 2673467))
kernel_rfl PRE_first_tail_x15_r0_body.zk144_2673467 : (objOf PRE_first_tail_x15_r0_body.s1398 2673467).kind = .array (arrOf PRE_first_tail_x15_r0_body.s0 2673467)
kernel_rfl PRE_first_tail_x15_r0_body.zm144_2673467 : PRE_first_tail_x15_r0_body.s1397.heap.get 2673467 = some (.obj { PRE_first_tail_x15_r0_body.kappa144.obj (objOf PRE_first_tail_x15_r0_body.s1398 2673467) with
  kind := .array (arrOf PRE_first_tail_x15_r0_body.s0 2673467 ++ (arrOf PRE_first_tail_x15_r0_body.s1397 2673467).drop (arrOf PRE_first_tail_x15_r0_body.s0 2673467).length) })
kernel_rfl PRE_first_tail_x15_r0_body.zw144_4910 : (PRE_first_tail_x15_r0_body.s1398.heap.get 4910).isSome = true
kernel_rfl PRE_first_tail_x15_r0_body.zw144_2673472 : (PRE_first_tail_x15_r0_body.s1398.heap.get 2673472).isSome = true
kernel_rfl PRE_first_tail_x15_r0_body.zw144_2673473 : (PRE_first_tail_x15_r0_body.s1398.heap.get 2673473).isSome = true
-- the heap: the changed list in range, holding the stage's written and fresh addresses; the canonical side's image
kernel_rfl PRE_first_tail_x15_r0_body.zclbd144 : PRE_first_tail_x15_r0_body.cl144.all (fun b => Nat.blt (b / 4096) (4 ^ 31)) = true
kernel_rfl PRE_first_tail_x15_r0_body.zwr144 : PRE_first_tail_x15_r0_body.st144.wr.all (fun b => !Nat.blt b PRE_first_tail_x15_r0_body.s1396.next || PRE_first_tail_x15_r0_body.cl144.contains b) = true
def PRE_first_tail_x15_r0_body.zl144 : List Nat := PRE_first_tail_x15_r0_body.cl144.filter fun a => !(List.contains [2665, 2673467] a)
kernel_rfl PRE_first_tail_x15_r0_body.zimgE144 : PRE_first_tail_x15_r0_body.zl144.map (fun a => PRE_first_tail_x15_r0_body.s1397.heap.get (PRE_first_tail_x15_r0_body.kappa144.a a)) = PRE_first_tail_x15_r0_body.zl144.map (fun a => (PRE_first_tail_x15_r0_body.s1398.heap.get a).map PRE_first_tail_x15_r0_body.kappa144.hobj)
theorem PRE_first_tail_x15_r0_body.zimg144 : HeapImg PRE_first_tail_x15_r0_body.kappa144 PRE_first_tail_x15_r0_body.s1398 PRE_first_tail_x15_r0_body.s1397 PRE_first_tail_x15_r0_body.zl144 := PRE_first_tail_x15_r0_body.zimgE144
-- the roots and their supports
kernel_rfl PRE_first_tail_x15_r0_body.zctl144 : PRE_first_tail_x15_r0_body.s1397.ctl = PRE_first_tail_x15_r0_body.kappa144.ctl PRE_first_tail_x15_r0_body.s1398.ctl
kernel_rfl PRE_first_tail_x15_r0_body.zstack144 : PRE_first_tail_x15_r0_body.s1397.stack = PRE_first_tail_x15_r0_body.s1398.stack.map PRE_first_tail_x15_r0_body.kappa144.frame
kernel_rfl PRE_first_tail_x15_r0_body.zjobs144 : PRE_first_tail_x15_r0_body.s1397.jobs = PRE_first_tail_x15_r0_body.s1398.jobs.map PRE_first_tail_x15_r0_body.kappa144.job
kernel_rfl PRE_first_tail_x15_r0_body.zstores144 : PRE_first_tail_x15_r0_body.s1397.stores = PRE_first_tail_x15_r0_body.kappa144.stores PRE_first_tail_x15_r0_body.s1398.stores
kernel_rfl PRE_first_tail_x15_r0_body.zroots144 : checkRootsSupp PRE_first_tail_x15_r0_body.s1398 6257 = true
kernel_rfl PRE_first_tail_x15_r0_body.znC144 : PRE_first_tail_x15_r0_body.S1396.tab.length + PRE_first_tail_x15_r0_body.cws144.length = 6257
-- the map as `Conv.compact_shift` states it (the call's counters for the literals)
kernel_rfl PRE_first_tail_x15_r0_body.zkap144 : PRE_first_tail_x15_r0_body.kappa144 = Conv.Map.compact PRE_first_tail_x15_r0_body.s1396.next 2789614 PRE_first_tail_x15_r0_body.S1396.tab.length PRE_first_tail_x15_r0_body.pl144 (PRE_first_tail_x15_r0_body.nr144.map NumV.ref) PRE_first_tail_x15_r0_body.kd144.big
  PRE_first_tail_x15_r0_body.kd144.region PRE_first_tail_x15_r0_body.kd144.nodeF
-- the bridge inactive at the canonical state (`Conv.FullShiftQ.toX`; the merged state's bridge is the canonical's: cbridge)
theorem PRE_first_tail_x15_r0_body.zbin144 : (Host.Ts.Sim.Full.bridgeOf PRE_first_tail_x15_r0_body.s1398.ffi).active = false := (Host.Load.Boot.replay_active Host.Load.Run.Prompt.P.oblog2818)
-- the JS bookkeeping's step (`Conv.JClean.step` over the changed list) and the canonical roots' bigint freedom
kernel_rfl PRE_first_tail_x15_r0_body.zjc144 : Conv.jcleanListB (⟨21051, 18149, 2788465, 6257⟩ : Conv.Cnt) PRE_first_tail_x15_r0_body.s1398 PRE_first_tail_x15_r0_body.cl144 = true
kernel_rfl PRE_first_tail_x15_r0_body.zrootsB144 : noBigRootsP (fun i => !Conv.oldBigB (⟨21051, 18149, 2788465, 6257⟩ : Conv.Cnt) i) PRE_first_tail_x15_r0_body.s1398.trace PRE_first_tail_x15_r0_body.s1398 = true
kernel_rfl PRE_first_tail_x15_r0_body.zhm144 : Nat.ble (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s0.ffi).mlx.nnext 18122 = true
theorem PRE_first_tail_x15_r0_body.cjcl144 (h : Conv.JClean (⟨21048, 18122, 2788459, 6239⟩ : Conv.Cnt) PRE_first_tail_x15_r0_body.s1396) : Conv.JClean (⟨21051, 18149, 2788465, 6257⟩ : Conv.Cnt) PRE_first_tail_x15_r0_body.s1398 :=
  Conv.JClean.step h (Conv.Cnt.le_of_leB PRE_first_tail_x15_r0_body.cle144)
    (Conv.heap_off_setAll PRE_first_tail_x15_r0_body.cheap144 fun a ha => Nat.blt_eq.mp (List.all_eq_true.mp PRE_first_tail_x15_r0_body.zclbd144 a ha)) PRE_first_tail_x15_r0_body.zjc144

end Host.Load.Run.Tpl
