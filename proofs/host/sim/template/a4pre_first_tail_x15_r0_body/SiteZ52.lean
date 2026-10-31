import host.sim.template.a4pre_first_tail_x15_r0_body.SiteS52
import host.sim.template.a4pre_first_tail_x15_r0_body.SiteK52
import host.sim.template.a4pre_first_tail_x15_r0_body.SiteF52
import host.sim.conv.CompactShift
import host.sim.template.Check
import host.sim.BigFreeP
import host.sim.template.CallGen
set_option Elab.async false
namespace Host.Load.Run.Tpl
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
open Host.Ts Host.Ts.Sim Host.Ts.Sim.Template

/-! The compaction's state shift at call site 52 of chain `PRE_first_tail_x15_r0_body` (`Conv.compact_shift`): the call `PRE_first_tail_x15_r0_body.s468`, the merged
state `PRE_first_tail_x15_r0_body.s469`, the canonical state `PRE_first_tail_x15_r0_body.s470`; its frames [2665,2673467,2673472,2673473] (kept arrays [2665,2673467]). -/

-- the map's places and counters
kernel_rfl PRE_first_tail_x15_r0_body.zpl52 : PRE_first_tail_x15_r0_body.pl52.all (Nat.ble PRE_first_tail_x15_r0_body.s468.next) = true
kernel_rfl PRE_first_tail_x15_r0_body.zplnd52 : nodupT PRE_first_tail_x15_r0_body.pl52 PTrie.nil = true
kernel_rfl PRE_first_tail_x15_r0_body.zn152 : Nat.ble PRE_first_tail_x15_r0_body.s468.next 2715881 = true
kernel_rfl PRE_first_tail_x15_r0_body.zfirst52 : Nat.ble aFirst PRE_first_tail_x15_r0_body.s468.next = true
kernel_rfl PRE_first_tail_x15_r0_body.zscn52 : PRE_first_tail_x15_r0_body.s470.next = PRE_first_tail_x15_r0_body.s468.next + PRE_first_tail_x15_r0_body.pl52.length
kernel_rfl PRE_first_tail_x15_r0_body.zsmn52 : PRE_first_tail_x15_r0_body.s469.next = 2715881
kernel_rfl PRE_first_tail_x15_r0_body.zgrow52 : Nat.ble PRE_first_tail_x15_r0_body.s470.next PRE_first_tail_x15_r0_body.s469.next = true
-- the tables
kernel_rfl PRE_first_tail_x15_r0_body.zfresh52 : PRE_first_tail_x15_r0_body.S468.tab.all (fun e => PRE_first_tail_x15_r0_body.cws52.all fun v => e.noVar v) = true
kernel_rfl PRE_first_tail_x15_r0_body.zcnd52 : nodupT PRE_first_tail_x15_r0_body.cws52 PTrie.nil = true
kernel_rfl PRE_first_tail_x15_r0_body.znrHi52 : PRE_first_tail_x15_r0_body.nr52.all (fun r => Nat.blt r PRE_first_tail_x15_r0_body.S469.tab.length) = true
-- the frames: every framed address below the call's counter; the kept arrays the chain start's, extended in the merged state
kernel_rfl PRE_first_tail_x15_r0_body.zfrlt52 : [2665, 2673467, 2673472, 2673473].all (fun a => Nat.blt a PRE_first_tail_x15_r0_body.s468.next) = true
kernel_rfl PRE_first_tail_x15_r0_body.zg52_2665 : PRE_first_tail_x15_r0_body.s470.heap.get 2665 = some (.obj (objOf PRE_first_tail_x15_r0_body.s470 2665))
kernel_rfl PRE_first_tail_x15_r0_body.zk52_2665 : (objOf PRE_first_tail_x15_r0_body.s470 2665).kind = .array (arrOf PRE_first_tail_x15_r0_body.s0 2665)
kernel_rfl PRE_first_tail_x15_r0_body.zm52_2665 : PRE_first_tail_x15_r0_body.s469.heap.get 2665 = some (.obj { PRE_first_tail_x15_r0_body.kappa52.obj (objOf PRE_first_tail_x15_r0_body.s470 2665) with
  kind := .array (arrOf PRE_first_tail_x15_r0_body.s0 2665 ++ (arrOf PRE_first_tail_x15_r0_body.s469 2665).drop (arrOf PRE_first_tail_x15_r0_body.s0 2665).length) })
kernel_rfl PRE_first_tail_x15_r0_body.zg52_2673467 : PRE_first_tail_x15_r0_body.s470.heap.get 2673467 = some (.obj (objOf PRE_first_tail_x15_r0_body.s470 2673467))
kernel_rfl PRE_first_tail_x15_r0_body.zk52_2673467 : (objOf PRE_first_tail_x15_r0_body.s470 2673467).kind = .array (arrOf PRE_first_tail_x15_r0_body.s0 2673467)
kernel_rfl PRE_first_tail_x15_r0_body.zm52_2673467 : PRE_first_tail_x15_r0_body.s469.heap.get 2673467 = some (.obj { PRE_first_tail_x15_r0_body.kappa52.obj (objOf PRE_first_tail_x15_r0_body.s470 2673467) with
  kind := .array (arrOf PRE_first_tail_x15_r0_body.s0 2673467 ++ (arrOf PRE_first_tail_x15_r0_body.s469 2673467).drop (arrOf PRE_first_tail_x15_r0_body.s0 2673467).length) })
kernel_rfl PRE_first_tail_x15_r0_body.zw52_4910 : (PRE_first_tail_x15_r0_body.s470.heap.get 4910).isSome = true
kernel_rfl PRE_first_tail_x15_r0_body.zw52_2673472 : (PRE_first_tail_x15_r0_body.s470.heap.get 2673472).isSome = true
kernel_rfl PRE_first_tail_x15_r0_body.zw52_2673473 : (PRE_first_tail_x15_r0_body.s470.heap.get 2673473).isSome = true
-- the heap: the changed list in range, holding the stage's written and fresh addresses; the canonical side's image
kernel_rfl PRE_first_tail_x15_r0_body.zclbd52 : PRE_first_tail_x15_r0_body.cl52.all (fun b => Nat.blt (b / 4096) (4 ^ 31)) = true
kernel_rfl PRE_first_tail_x15_r0_body.zwr52 : PRE_first_tail_x15_r0_body.st52.wr.all (fun b => !Nat.blt b PRE_first_tail_x15_r0_body.s468.next || PRE_first_tail_x15_r0_body.cl52.contains b) = true
def PRE_first_tail_x15_r0_body.zl52 : List Nat := PRE_first_tail_x15_r0_body.cl52.filter fun a => !(List.contains [2665, 2673467] a)
kernel_rfl PRE_first_tail_x15_r0_body.zimgE52 : PRE_first_tail_x15_r0_body.zl52.map (fun a => PRE_first_tail_x15_r0_body.s469.heap.get (PRE_first_tail_x15_r0_body.kappa52.a a)) = PRE_first_tail_x15_r0_body.zl52.map (fun a => (PRE_first_tail_x15_r0_body.s470.heap.get a).map PRE_first_tail_x15_r0_body.kappa52.hobj)
theorem PRE_first_tail_x15_r0_body.zimg52 : HeapImg PRE_first_tail_x15_r0_body.kappa52 PRE_first_tail_x15_r0_body.s470 PRE_first_tail_x15_r0_body.s469 PRE_first_tail_x15_r0_body.zl52 := PRE_first_tail_x15_r0_body.zimgE52
-- the roots and their supports
kernel_rfl PRE_first_tail_x15_r0_body.zctl52 : PRE_first_tail_x15_r0_body.s469.ctl = PRE_first_tail_x15_r0_body.kappa52.ctl PRE_first_tail_x15_r0_body.s470.ctl
kernel_rfl PRE_first_tail_x15_r0_body.zstack52 : PRE_first_tail_x15_r0_body.s469.stack = PRE_first_tail_x15_r0_body.s470.stack.map PRE_first_tail_x15_r0_body.kappa52.frame
kernel_rfl PRE_first_tail_x15_r0_body.zjobs52 : PRE_first_tail_x15_r0_body.s469.jobs = PRE_first_tail_x15_r0_body.s470.jobs.map PRE_first_tail_x15_r0_body.kappa52.job
kernel_rfl PRE_first_tail_x15_r0_body.zstores52 : PRE_first_tail_x15_r0_body.s469.stores = PRE_first_tail_x15_r0_body.kappa52.stores PRE_first_tail_x15_r0_body.s470.stores
kernel_rfl PRE_first_tail_x15_r0_body.zroots52 : checkRootsSupp PRE_first_tail_x15_r0_body.s470 2303 = true
kernel_rfl PRE_first_tail_x15_r0_body.znC52 : PRE_first_tail_x15_r0_body.S468.tab.length + PRE_first_tail_x15_r0_body.cws52.length = 2303
-- the map as `Conv.compact_shift` states it (the call's counters for the literals)
kernel_rfl PRE_first_tail_x15_r0_body.zkap52 : PRE_first_tail_x15_r0_body.kappa52 = Conv.Map.compact PRE_first_tail_x15_r0_body.s468.next 2715881 PRE_first_tail_x15_r0_body.S468.tab.length PRE_first_tail_x15_r0_body.pl52 (PRE_first_tail_x15_r0_body.nr52.map NumV.ref) PRE_first_tail_x15_r0_body.kd52.big
  PRE_first_tail_x15_r0_body.kd52.region PRE_first_tail_x15_r0_body.kd52.nodeF
-- the bridge inactive at the canonical state (`Conv.FullShiftQ.toX`; the merged state's bridge is the canonical's: cbridge)
theorem PRE_first_tail_x15_r0_body.zbin52 : (Host.Ts.Sim.Full.bridgeOf PRE_first_tail_x15_r0_body.s470.ffi).active = false := (Host.Load.Boot.replay_active Host.Load.Run.Prompt.P.oblog2818)
-- the JS bookkeeping's step (`Conv.JClean.step` over the changed list) and the canonical roots' bigint freedom
kernel_rfl PRE_first_tail_x15_r0_body.zjc52 : Conv.jcleanListB (⟨19233, 16329, 2715879, 2303⟩ : Conv.Cnt) PRE_first_tail_x15_r0_body.s470 PRE_first_tail_x15_r0_body.cl52 = true
kernel_rfl PRE_first_tail_x15_r0_body.zroots252 : noBigRootsP (fun i => !Conv.oldBigB (⟨19233, 16329, 2715879, 2303⟩ : Conv.Cnt) i) PRE_first_tail_x15_r0_body.s470.trace PRE_first_tail_x15_r0_body.s470 = true
kernel_rfl PRE_first_tail_x15_r0_body.zhm52 : Nat.ble (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s0.ffi).mlx.nnext 16329 = true
theorem PRE_first_tail_x15_r0_body.cjcl52 (h : Conv.JClean (⟨19233, 16329, 2715879, 2303⟩ : Conv.Cnt) PRE_first_tail_x15_r0_body.s468) : Conv.JClean (⟨19233, 16329, 2715879, 2303⟩ : Conv.Cnt) PRE_first_tail_x15_r0_body.s470 :=
  Conv.JClean.step h (Conv.Cnt.le_of_leB PRE_first_tail_x15_r0_body.cle52)
    (Conv.heap_off_setAll PRE_first_tail_x15_r0_body.cheap52 fun a ha => Nat.blt_eq.mp (List.all_eq_true.mp PRE_first_tail_x15_r0_body.zclbd52 a ha)) PRE_first_tail_x15_r0_body.zjc52

end Host.Load.Run.Tpl
