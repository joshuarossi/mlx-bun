import host.sim.template.a4pre_first_tail_x15_r0_body.SiteS105
import host.sim.template.a4pre_first_tail_x15_r0_body.SiteK105
import host.sim.template.a4pre_first_tail_x15_r0_body.SiteF105
import host.sim.conv.CompactShift
import host.sim.template.Check
import host.sim.BigFreeP
import host.sim.template.CallGen
set_option Elab.async false
namespace Host.Load.Run.Tpl
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
open Host.Ts Host.Ts.Sim Host.Ts.Sim.Template

/-! The compaction's state shift at call site 105 of chain `PRE_first_tail_x15_r0_body` (`Conv.compact_shift`): the call `PRE_first_tail_x15_r0_body.s932`, the merged
state `PRE_first_tail_x15_r0_body.s933`, the canonical state `PRE_first_tail_x15_r0_body.s934`; its frames [2665,2673467,2673472,2673473] (kept arrays [2665,2673467]). -/

-- the map's places and counters
kernel_rfl PRE_first_tail_x15_r0_body.zpl105 : PRE_first_tail_x15_r0_body.pl105.all (Nat.ble PRE_first_tail_x15_r0_body.s932.next) = true
kernel_rfl PRE_first_tail_x15_r0_body.zplnd105 : nodupT PRE_first_tail_x15_r0_body.pl105 PTrie.nil = true
kernel_rfl PRE_first_tail_x15_r0_body.zn1105 : Nat.ble PRE_first_tail_x15_r0_body.s932.next 2758197 = true
kernel_rfl PRE_first_tail_x15_r0_body.zfirst105 : Nat.ble aFirst PRE_first_tail_x15_r0_body.s932.next = true
kernel_rfl PRE_first_tail_x15_r0_body.zscn105 : PRE_first_tail_x15_r0_body.s934.next = PRE_first_tail_x15_r0_body.s932.next + PRE_first_tail_x15_r0_body.pl105.length
kernel_rfl PRE_first_tail_x15_r0_body.zsmn105 : PRE_first_tail_x15_r0_body.s933.next = 2758197
kernel_rfl PRE_first_tail_x15_r0_body.zgrow105 : Nat.ble PRE_first_tail_x15_r0_body.s934.next PRE_first_tail_x15_r0_body.s933.next = true
-- the tables
kernel_rfl PRE_first_tail_x15_r0_body.zfresh105 : PRE_first_tail_x15_r0_body.S932.tab.all (fun e => PRE_first_tail_x15_r0_body.cws105.all fun v => e.noVar v) = true
kernel_rfl PRE_first_tail_x15_r0_body.zcnd105 : nodupT PRE_first_tail_x15_r0_body.cws105 PTrie.nil = true
kernel_rfl PRE_first_tail_x15_r0_body.znrHi105 : PRE_first_tail_x15_r0_body.nr105.all (fun r => Nat.blt r PRE_first_tail_x15_r0_body.S933.tab.length) = true
-- the frames: every framed address below the call's counter; the kept arrays the chain start's, extended in the merged state
kernel_rfl PRE_first_tail_x15_r0_body.zfrlt105 : [2665, 2673467, 2673472, 2673473].all (fun a => Nat.blt a PRE_first_tail_x15_r0_body.s932.next) = true
kernel_rfl PRE_first_tail_x15_r0_body.zg105_2665 : PRE_first_tail_x15_r0_body.s934.heap.get 2665 = some (.obj (objOf PRE_first_tail_x15_r0_body.s934 2665))
kernel_rfl PRE_first_tail_x15_r0_body.zk105_2665 : (objOf PRE_first_tail_x15_r0_body.s934 2665).kind = .array (arrOf PRE_first_tail_x15_r0_body.s0 2665)
kernel_rfl PRE_first_tail_x15_r0_body.zm105_2665 : PRE_first_tail_x15_r0_body.s933.heap.get 2665 = some (.obj { PRE_first_tail_x15_r0_body.kappa105.obj (objOf PRE_first_tail_x15_r0_body.s934 2665) with
  kind := .array (arrOf PRE_first_tail_x15_r0_body.s0 2665 ++ (arrOf PRE_first_tail_x15_r0_body.s933 2665).drop (arrOf PRE_first_tail_x15_r0_body.s0 2665).length) })
kernel_rfl PRE_first_tail_x15_r0_body.zg105_2673467 : PRE_first_tail_x15_r0_body.s934.heap.get 2673467 = some (.obj (objOf PRE_first_tail_x15_r0_body.s934 2673467))
kernel_rfl PRE_first_tail_x15_r0_body.zk105_2673467 : (objOf PRE_first_tail_x15_r0_body.s934 2673467).kind = .array (arrOf PRE_first_tail_x15_r0_body.s0 2673467)
kernel_rfl PRE_first_tail_x15_r0_body.zm105_2673467 : PRE_first_tail_x15_r0_body.s933.heap.get 2673467 = some (.obj { PRE_first_tail_x15_r0_body.kappa105.obj (objOf PRE_first_tail_x15_r0_body.s934 2673467) with
  kind := .array (arrOf PRE_first_tail_x15_r0_body.s0 2673467 ++ (arrOf PRE_first_tail_x15_r0_body.s933 2673467).drop (arrOf PRE_first_tail_x15_r0_body.s0 2673467).length) })
kernel_rfl PRE_first_tail_x15_r0_body.zw105_4910 : (PRE_first_tail_x15_r0_body.s934.heap.get 4910).isSome = true
kernel_rfl PRE_first_tail_x15_r0_body.zw105_2673472 : (PRE_first_tail_x15_r0_body.s934.heap.get 2673472).isSome = true
kernel_rfl PRE_first_tail_x15_r0_body.zw105_2673473 : (PRE_first_tail_x15_r0_body.s934.heap.get 2673473).isSome = true
-- the heap: the changed list in range, holding the stage's written and fresh addresses; the canonical side's image
kernel_rfl PRE_first_tail_x15_r0_body.zclbd105 : PRE_first_tail_x15_r0_body.cl105.all (fun b => Nat.blt (b / 4096) (4 ^ 31)) = true
kernel_rfl PRE_first_tail_x15_r0_body.zwr105 : PRE_first_tail_x15_r0_body.st105.wr.all (fun b => !Nat.blt b PRE_first_tail_x15_r0_body.s932.next || PRE_first_tail_x15_r0_body.cl105.contains b) = true
def PRE_first_tail_x15_r0_body.zl105 : List Nat := PRE_first_tail_x15_r0_body.cl105.filter fun a => !(List.contains [2665, 2673467] a)
kernel_rfl PRE_first_tail_x15_r0_body.zimgE105 : PRE_first_tail_x15_r0_body.zl105.map (fun a => PRE_first_tail_x15_r0_body.s933.heap.get (PRE_first_tail_x15_r0_body.kappa105.a a)) = PRE_first_tail_x15_r0_body.zl105.map (fun a => (PRE_first_tail_x15_r0_body.s934.heap.get a).map PRE_first_tail_x15_r0_body.kappa105.hobj)
theorem PRE_first_tail_x15_r0_body.zimg105 : HeapImg PRE_first_tail_x15_r0_body.kappa105 PRE_first_tail_x15_r0_body.s934 PRE_first_tail_x15_r0_body.s933 PRE_first_tail_x15_r0_body.zl105 := PRE_first_tail_x15_r0_body.zimgE105
-- the roots and their supports
kernel_rfl PRE_first_tail_x15_r0_body.zctl105 : PRE_first_tail_x15_r0_body.s933.ctl = PRE_first_tail_x15_r0_body.kappa105.ctl PRE_first_tail_x15_r0_body.s934.ctl
kernel_rfl PRE_first_tail_x15_r0_body.zstack105 : PRE_first_tail_x15_r0_body.s933.stack = PRE_first_tail_x15_r0_body.s934.stack.map PRE_first_tail_x15_r0_body.kappa105.frame
kernel_rfl PRE_first_tail_x15_r0_body.zjobs105 : PRE_first_tail_x15_r0_body.s933.jobs = PRE_first_tail_x15_r0_body.s934.jobs.map PRE_first_tail_x15_r0_body.kappa105.job
kernel_rfl PRE_first_tail_x15_r0_body.zstores105 : PRE_first_tail_x15_r0_body.s933.stores = PRE_first_tail_x15_r0_body.kappa105.stores PRE_first_tail_x15_r0_body.s934.stores
kernel_rfl PRE_first_tail_x15_r0_body.zroots105 : checkRootsSupp PRE_first_tail_x15_r0_body.s934 4587 = true
kernel_rfl PRE_first_tail_x15_r0_body.znC105 : PRE_first_tail_x15_r0_body.S932.tab.length + PRE_first_tail_x15_r0_body.cws105.length = 4587
-- the map as `Conv.compact_shift` states it (the call's counters for the literals)
kernel_rfl PRE_first_tail_x15_r0_body.zkap105 : PRE_first_tail_x15_r0_body.kappa105 = Conv.Map.compact PRE_first_tail_x15_r0_body.s932.next 2758197 PRE_first_tail_x15_r0_body.S932.tab.length PRE_first_tail_x15_r0_body.pl105 (PRE_first_tail_x15_r0_body.nr105.map NumV.ref) PRE_first_tail_x15_r0_body.kd105.big
  PRE_first_tail_x15_r0_body.kd105.region PRE_first_tail_x15_r0_body.kd105.nodeF
-- the bridge inactive at the canonical state (`Conv.FullShiftQ.toX`; the merged state's bridge is the canonical's: cbridge)
theorem PRE_first_tail_x15_r0_body.zbin105 : (Host.Ts.Sim.Full.bridgeOf PRE_first_tail_x15_r0_body.s934.ffi).active = false := (Host.Load.Boot.replay_active Host.Load.Run.Prompt.P.oblog2818)
-- the JS bookkeeping's step (`Conv.JClean.step` over the changed list) and the canonical roots' bigint freedom
kernel_rfl PRE_first_tail_x15_r0_body.zjc105 : Conv.jcleanListB (⟨20285, 17378, 2757847, 4587⟩ : Conv.Cnt) PRE_first_tail_x15_r0_body.s934 PRE_first_tail_x15_r0_body.cl105 = true
kernel_rfl PRE_first_tail_x15_r0_body.zroots2105 : noBigRootsP (fun i => !Conv.oldBigB (⟨20285, 17378, 2757847, 4587⟩ : Conv.Cnt) i) PRE_first_tail_x15_r0_body.s934.trace PRE_first_tail_x15_r0_body.s934 = true
kernel_rfl PRE_first_tail_x15_r0_body.zhm105 : Nat.ble (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s0.ffi).mlx.nnext 17372 = true
theorem PRE_first_tail_x15_r0_body.cjcl105 (h : Conv.JClean (⟨20281, 17372, 2757832, 4578⟩ : Conv.Cnt) PRE_first_tail_x15_r0_body.s932) : Conv.JClean (⟨20285, 17378, 2757847, 4587⟩ : Conv.Cnt) PRE_first_tail_x15_r0_body.s934 :=
  Conv.JClean.step h (Conv.Cnt.le_of_leB PRE_first_tail_x15_r0_body.cle105)
    (Conv.heap_off_setAll PRE_first_tail_x15_r0_body.cheap105 fun a ha => Nat.blt_eq.mp (List.all_eq_true.mp PRE_first_tail_x15_r0_body.zclbd105 a ha)) PRE_first_tail_x15_r0_body.zjc105

end Host.Load.Run.Tpl
