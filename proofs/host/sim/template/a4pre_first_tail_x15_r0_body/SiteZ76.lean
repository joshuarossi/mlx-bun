import host.sim.template.a4pre_first_tail_x15_r0_body.SiteS76
import host.sim.template.a4pre_first_tail_x15_r0_body.SiteK76
import host.sim.template.a4pre_first_tail_x15_r0_body.SiteF76
import host.sim.conv.CompactShift
import host.sim.template.Check
import host.sim.BigFreeP
import host.sim.template.CallGen
set_option Elab.async false
namespace Host.Load.Run.Tpl
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
open Host.Ts Host.Ts.Sim Host.Ts.Sim.Template

/-! The compaction's state shift at call site 76 of chain `PRE_first_tail_x15_r0_body` (`Conv.compact_shift`): the call `PRE_first_tail_x15_r0_body.s743`, the merged
state `PRE_first_tail_x15_r0_body.s744`, the canonical state `PRE_first_tail_x15_r0_body.s745`; its frames [2665,2673467,2673472,2673473] (kept arrays [2665,2673467]). -/

-- the map's places and counters
kernel_rfl PRE_first_tail_x15_r0_body.zpl76 : PRE_first_tail_x15_r0_body.pl76.all (Nat.ble PRE_first_tail_x15_r0_body.s743.next) = true
kernel_rfl PRE_first_tail_x15_r0_body.zplnd76 : nodupT PRE_first_tail_x15_r0_body.pl76 PTrie.nil = true
kernel_rfl PRE_first_tail_x15_r0_body.zn176 : Nat.ble PRE_first_tail_x15_r0_body.s743.next 2734713 = true
kernel_rfl PRE_first_tail_x15_r0_body.zfirst76 : Nat.ble aFirst PRE_first_tail_x15_r0_body.s743.next = true
kernel_rfl PRE_first_tail_x15_r0_body.zscn76 : PRE_first_tail_x15_r0_body.s745.next = PRE_first_tail_x15_r0_body.s743.next + PRE_first_tail_x15_r0_body.pl76.length
kernel_rfl PRE_first_tail_x15_r0_body.zsmn76 : PRE_first_tail_x15_r0_body.s744.next = 2734713
kernel_rfl PRE_first_tail_x15_r0_body.zgrow76 : Nat.ble PRE_first_tail_x15_r0_body.s745.next PRE_first_tail_x15_r0_body.s744.next = true
-- the tables
kernel_rfl PRE_first_tail_x15_r0_body.zfresh76 : PRE_first_tail_x15_r0_body.S743.tab.all (fun e => PRE_first_tail_x15_r0_body.cws76.all fun v => e.noVar v) = true
kernel_rfl PRE_first_tail_x15_r0_body.zcnd76 : nodupT PRE_first_tail_x15_r0_body.cws76 PTrie.nil = true
kernel_rfl PRE_first_tail_x15_r0_body.znrHi76 : PRE_first_tail_x15_r0_body.nr76.all (fun r => Nat.blt r PRE_first_tail_x15_r0_body.S744.tab.length) = true
-- the frames: every framed address below the call's counter; the kept arrays the chain start's, extended in the merged state
kernel_rfl PRE_first_tail_x15_r0_body.zfrlt76 : [2665, 2673467, 2673472, 2673473].all (fun a => Nat.blt a PRE_first_tail_x15_r0_body.s743.next) = true
kernel_rfl PRE_first_tail_x15_r0_body.zg76_2665 : PRE_first_tail_x15_r0_body.s745.heap.get 2665 = some (.obj (objOf PRE_first_tail_x15_r0_body.s745 2665))
kernel_rfl PRE_first_tail_x15_r0_body.zk76_2665 : (objOf PRE_first_tail_x15_r0_body.s745 2665).kind = .array (arrOf PRE_first_tail_x15_r0_body.s0 2665)
kernel_rfl PRE_first_tail_x15_r0_body.zm76_2665 : PRE_first_tail_x15_r0_body.s744.heap.get 2665 = some (.obj { PRE_first_tail_x15_r0_body.kappa76.obj (objOf PRE_first_tail_x15_r0_body.s745 2665) with
  kind := .array (arrOf PRE_first_tail_x15_r0_body.s0 2665 ++ (arrOf PRE_first_tail_x15_r0_body.s744 2665).drop (arrOf PRE_first_tail_x15_r0_body.s0 2665).length) })
kernel_rfl PRE_first_tail_x15_r0_body.zg76_2673467 : PRE_first_tail_x15_r0_body.s745.heap.get 2673467 = some (.obj (objOf PRE_first_tail_x15_r0_body.s745 2673467))
kernel_rfl PRE_first_tail_x15_r0_body.zk76_2673467 : (objOf PRE_first_tail_x15_r0_body.s745 2673467).kind = .array (arrOf PRE_first_tail_x15_r0_body.s0 2673467)
kernel_rfl PRE_first_tail_x15_r0_body.zm76_2673467 : PRE_first_tail_x15_r0_body.s744.heap.get 2673467 = some (.obj { PRE_first_tail_x15_r0_body.kappa76.obj (objOf PRE_first_tail_x15_r0_body.s745 2673467) with
  kind := .array (arrOf PRE_first_tail_x15_r0_body.s0 2673467 ++ (arrOf PRE_first_tail_x15_r0_body.s744 2673467).drop (arrOf PRE_first_tail_x15_r0_body.s0 2673467).length) })
kernel_rfl PRE_first_tail_x15_r0_body.zw76_4910 : (PRE_first_tail_x15_r0_body.s745.heap.get 4910).isSome = true
kernel_rfl PRE_first_tail_x15_r0_body.zw76_2673472 : (PRE_first_tail_x15_r0_body.s745.heap.get 2673472).isSome = true
kernel_rfl PRE_first_tail_x15_r0_body.zw76_2673473 : (PRE_first_tail_x15_r0_body.s745.heap.get 2673473).isSome = true
-- the heap: the changed list in range, holding the stage's written and fresh addresses; the canonical side's image
kernel_rfl PRE_first_tail_x15_r0_body.zclbd76 : PRE_first_tail_x15_r0_body.cl76.all (fun b => Nat.blt (b / 4096) (4 ^ 31)) = true
kernel_rfl PRE_first_tail_x15_r0_body.zwr76 : PRE_first_tail_x15_r0_body.st76.wr.all (fun b => !Nat.blt b PRE_first_tail_x15_r0_body.s743.next || PRE_first_tail_x15_r0_body.cl76.contains b) = true
def PRE_first_tail_x15_r0_body.zl76 : List Nat := PRE_first_tail_x15_r0_body.cl76.filter fun a => !(List.contains [2665, 2673467] a)
kernel_rfl PRE_first_tail_x15_r0_body.zimgE76 : PRE_first_tail_x15_r0_body.zl76.map (fun a => PRE_first_tail_x15_r0_body.s744.heap.get (PRE_first_tail_x15_r0_body.kappa76.a a)) = PRE_first_tail_x15_r0_body.zl76.map (fun a => (PRE_first_tail_x15_r0_body.s745.heap.get a).map PRE_first_tail_x15_r0_body.kappa76.hobj)
theorem PRE_first_tail_x15_r0_body.zimg76 : HeapImg PRE_first_tail_x15_r0_body.kappa76 PRE_first_tail_x15_r0_body.s745 PRE_first_tail_x15_r0_body.s744 PRE_first_tail_x15_r0_body.zl76 := PRE_first_tail_x15_r0_body.zimgE76
-- the roots and their supports
kernel_rfl PRE_first_tail_x15_r0_body.zctl76 : PRE_first_tail_x15_r0_body.s744.ctl = PRE_first_tail_x15_r0_body.kappa76.ctl PRE_first_tail_x15_r0_body.s745.ctl
kernel_rfl PRE_first_tail_x15_r0_body.zstack76 : PRE_first_tail_x15_r0_body.s744.stack = PRE_first_tail_x15_r0_body.s745.stack.map PRE_first_tail_x15_r0_body.kappa76.frame
kernel_rfl PRE_first_tail_x15_r0_body.zjobs76 : PRE_first_tail_x15_r0_body.s744.jobs = PRE_first_tail_x15_r0_body.s745.jobs.map PRE_first_tail_x15_r0_body.kappa76.job
kernel_rfl PRE_first_tail_x15_r0_body.zstores76 : PRE_first_tail_x15_r0_body.s744.stores = PRE_first_tail_x15_r0_body.kappa76.stores PRE_first_tail_x15_r0_body.s745.stores
kernel_rfl PRE_first_tail_x15_r0_body.zroots76 : checkRootsSupp PRE_first_tail_x15_r0_body.s745 3329 = true
kernel_rfl PRE_first_tail_x15_r0_body.znC76 : PRE_first_tail_x15_r0_body.S743.tab.length + PRE_first_tail_x15_r0_body.cws76.length = 3329
-- the map as `Conv.compact_shift` states it (the call's counters for the literals)
kernel_rfl PRE_first_tail_x15_r0_body.zkap76 : PRE_first_tail_x15_r0_body.kappa76 = Conv.Map.compact PRE_first_tail_x15_r0_body.s743.next 2734713 PRE_first_tail_x15_r0_body.S743.tab.length PRE_first_tail_x15_r0_body.pl76 (PRE_first_tail_x15_r0_body.nr76.map NumV.ref) PRE_first_tail_x15_r0_body.kd76.big
  PRE_first_tail_x15_r0_body.kd76.region PRE_first_tail_x15_r0_body.kd76.nodeF
-- the bridge inactive at the canonical state (`Conv.FullShiftQ.toX`; the merged state's bridge is the canonical's: cbridge)
theorem PRE_first_tail_x15_r0_body.zbin76 : (Host.Ts.Sim.Full.bridgeOf PRE_first_tail_x15_r0_body.s745.ffi).active = false := (Host.Load.Boot.replay_active Host.Load.Run.Prompt.P.oblog2818)
-- the JS bookkeeping's step (`Conv.JClean.step` over the changed list) and the canonical roots' bigint freedom
kernel_rfl PRE_first_tail_x15_r0_body.zjc76 : Conv.jcleanListB (⟨19705, 16803, 2734711, 3329⟩ : Conv.Cnt) PRE_first_tail_x15_r0_body.s745 PRE_first_tail_x15_r0_body.cl76 = true
kernel_rfl PRE_first_tail_x15_r0_body.zrootsB76 : noBigRootsP (fun i => !Conv.oldBigB (⟨19705, 16803, 2734711, 3329⟩ : Conv.Cnt) i) PRE_first_tail_x15_r0_body.s745.trace PRE_first_tail_x15_r0_body.s745 = true
kernel_rfl PRE_first_tail_x15_r0_body.zhm76 : Nat.ble (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s0.ffi).mlx.nnext 16803 = true
theorem PRE_first_tail_x15_r0_body.cjcl76 (h : Conv.JClean (⟨19705, 16803, 2734711, 3329⟩ : Conv.Cnt) PRE_first_tail_x15_r0_body.s743) : Conv.JClean (⟨19705, 16803, 2734711, 3329⟩ : Conv.Cnt) PRE_first_tail_x15_r0_body.s745 :=
  Conv.JClean.step h (Conv.Cnt.le_of_leB PRE_first_tail_x15_r0_body.cle76)
    (Conv.heap_off_setAll PRE_first_tail_x15_r0_body.cheap76 fun a ha => Nat.blt_eq.mp (List.all_eq_true.mp PRE_first_tail_x15_r0_body.zclbd76 a ha)) PRE_first_tail_x15_r0_body.zjc76

end Host.Load.Run.Tpl
