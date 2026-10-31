import host.sim.template.a4pre_first_tail_x15_r0_body.SiteS99
import host.sim.template.a4pre_first_tail_x15_r0_body.SiteK99
import host.sim.template.a4pre_first_tail_x15_r0_body.SiteF99
import host.sim.conv.CompactShift
import host.sim.template.Check
import host.sim.BigFreeP
import host.sim.template.CallGen
set_option Elab.async false
namespace Host.Load.Run.Tpl
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
open Host.Ts Host.Ts.Sim Host.Ts.Sim.Template

/-! The compaction's state shift at call site 99 of chain `PRE_first_tail_x15_r0_body` (`Conv.compact_shift`): the call `PRE_first_tail_x15_r0_body.s965`, the merged
state `PRE_first_tail_x15_r0_body.s966`, the canonical state `PRE_first_tail_x15_r0_body.s967`; its frames [2665,2673467,2673472,2673473] (kept arrays [2665,2673467]). -/

-- the map's places and counters
kernel_rfl PRE_first_tail_x15_r0_body.zpl99 : PRE_first_tail_x15_r0_body.pl99.all (Nat.ble PRE_first_tail_x15_r0_body.s965.next) = true
kernel_rfl PRE_first_tail_x15_r0_body.zplnd99 : nodupT PRE_first_tail_x15_r0_body.pl99 PTrie.nil = true
kernel_rfl PRE_first_tail_x15_r0_body.zn199 : Nat.ble PRE_first_tail_x15_r0_body.s965.next 2754206 = true
kernel_rfl PRE_first_tail_x15_r0_body.zfirst99 : Nat.ble aFirst PRE_first_tail_x15_r0_body.s965.next = true
kernel_rfl PRE_first_tail_x15_r0_body.zscn99 : PRE_first_tail_x15_r0_body.s967.next = PRE_first_tail_x15_r0_body.s965.next + PRE_first_tail_x15_r0_body.pl99.length
kernel_rfl PRE_first_tail_x15_r0_body.zsmn99 : PRE_first_tail_x15_r0_body.s966.next = 2754206
kernel_rfl PRE_first_tail_x15_r0_body.zgrow99 : Nat.ble PRE_first_tail_x15_r0_body.s967.next PRE_first_tail_x15_r0_body.s966.next = true
-- the tables
kernel_rfl PRE_first_tail_x15_r0_body.zfresh99 : PRE_first_tail_x15_r0_body.S965.tab.all (fun e => PRE_first_tail_x15_r0_body.cws99.all fun v => e.noVar v) = true
kernel_rfl PRE_first_tail_x15_r0_body.zcnd99 : nodupT PRE_first_tail_x15_r0_body.cws99 PTrie.nil = true
kernel_rfl PRE_first_tail_x15_r0_body.znrHi99 : PRE_first_tail_x15_r0_body.nr99.all (fun r => Nat.blt r PRE_first_tail_x15_r0_body.S966.tab.length) = true
-- the frames: every framed address below the call's counter; the kept arrays the chain start's, extended in the merged state
kernel_rfl PRE_first_tail_x15_r0_body.zfrlt99 : [2665, 2673467, 2673472, 2673473].all (fun a => Nat.blt a PRE_first_tail_x15_r0_body.s965.next) = true
kernel_rfl PRE_first_tail_x15_r0_body.zg99_2665 : PRE_first_tail_x15_r0_body.s967.heap.get 2665 = some (.obj (objOf PRE_first_tail_x15_r0_body.s967 2665))
kernel_rfl PRE_first_tail_x15_r0_body.zk99_2665 : (objOf PRE_first_tail_x15_r0_body.s967 2665).kind = .array (arrOf PRE_first_tail_x15_r0_body.s0 2665)
kernel_rfl PRE_first_tail_x15_r0_body.zm99_2665 : PRE_first_tail_x15_r0_body.s966.heap.get 2665 = some (.obj { PRE_first_tail_x15_r0_body.kappa99.obj (objOf PRE_first_tail_x15_r0_body.s967 2665) with
  kind := .array (arrOf PRE_first_tail_x15_r0_body.s0 2665 ++ (arrOf PRE_first_tail_x15_r0_body.s966 2665).drop (arrOf PRE_first_tail_x15_r0_body.s0 2665).length) })
kernel_rfl PRE_first_tail_x15_r0_body.zg99_2673467 : PRE_first_tail_x15_r0_body.s967.heap.get 2673467 = some (.obj (objOf PRE_first_tail_x15_r0_body.s967 2673467))
kernel_rfl PRE_first_tail_x15_r0_body.zk99_2673467 : (objOf PRE_first_tail_x15_r0_body.s967 2673467).kind = .array (arrOf PRE_first_tail_x15_r0_body.s0 2673467)
kernel_rfl PRE_first_tail_x15_r0_body.zm99_2673467 : PRE_first_tail_x15_r0_body.s966.heap.get 2673467 = some (.obj { PRE_first_tail_x15_r0_body.kappa99.obj (objOf PRE_first_tail_x15_r0_body.s967 2673467) with
  kind := .array (arrOf PRE_first_tail_x15_r0_body.s0 2673467 ++ (arrOf PRE_first_tail_x15_r0_body.s966 2673467).drop (arrOf PRE_first_tail_x15_r0_body.s0 2673467).length) })
kernel_rfl PRE_first_tail_x15_r0_body.zw99_4910 : (PRE_first_tail_x15_r0_body.s967.heap.get 4910).isSome = true
kernel_rfl PRE_first_tail_x15_r0_body.zw99_2673472 : (PRE_first_tail_x15_r0_body.s967.heap.get 2673472).isSome = true
kernel_rfl PRE_first_tail_x15_r0_body.zw99_2673473 : (PRE_first_tail_x15_r0_body.s967.heap.get 2673473).isSome = true
-- the heap: the changed list in range, holding the stage's written and fresh addresses; the canonical side's image
kernel_rfl PRE_first_tail_x15_r0_body.zclbd99 : PRE_first_tail_x15_r0_body.cl99.all (fun b => Nat.blt (b / 4096) (4 ^ 31)) = true
kernel_rfl PRE_first_tail_x15_r0_body.zwr99 : PRE_first_tail_x15_r0_body.st99.wr.all (fun b => !Nat.blt b PRE_first_tail_x15_r0_body.s965.next || PRE_first_tail_x15_r0_body.cl99.contains b) = true
def PRE_first_tail_x15_r0_body.zl99 : List Nat := PRE_first_tail_x15_r0_body.cl99.filter fun a => !(List.contains [2665, 2673467] a)
kernel_rfl PRE_first_tail_x15_r0_body.zimgE99 : PRE_first_tail_x15_r0_body.zl99.map (fun a => PRE_first_tail_x15_r0_body.s966.heap.get (PRE_first_tail_x15_r0_body.kappa99.a a)) = PRE_first_tail_x15_r0_body.zl99.map (fun a => (PRE_first_tail_x15_r0_body.s967.heap.get a).map PRE_first_tail_x15_r0_body.kappa99.hobj)
theorem PRE_first_tail_x15_r0_body.zimg99 : HeapImg PRE_first_tail_x15_r0_body.kappa99 PRE_first_tail_x15_r0_body.s967 PRE_first_tail_x15_r0_body.s966 PRE_first_tail_x15_r0_body.zl99 := PRE_first_tail_x15_r0_body.zimgE99
-- the roots and their supports
kernel_rfl PRE_first_tail_x15_r0_body.zctl99 : PRE_first_tail_x15_r0_body.s966.ctl = PRE_first_tail_x15_r0_body.kappa99.ctl PRE_first_tail_x15_r0_body.s967.ctl
kernel_rfl PRE_first_tail_x15_r0_body.zstack99 : PRE_first_tail_x15_r0_body.s966.stack = PRE_first_tail_x15_r0_body.s967.stack.map PRE_first_tail_x15_r0_body.kappa99.frame
kernel_rfl PRE_first_tail_x15_r0_body.zjobs99 : PRE_first_tail_x15_r0_body.s966.jobs = PRE_first_tail_x15_r0_body.s967.jobs.map PRE_first_tail_x15_r0_body.kappa99.job
kernel_rfl PRE_first_tail_x15_r0_body.zstores99 : PRE_first_tail_x15_r0_body.s966.stores = PRE_first_tail_x15_r0_body.kappa99.stores PRE_first_tail_x15_r0_body.s967.stores
kernel_rfl PRE_first_tail_x15_r0_body.zroots99 : checkRootsSupp PRE_first_tail_x15_r0_body.s967 4334 = true
kernel_rfl PRE_first_tail_x15_r0_body.znC99 : PRE_first_tail_x15_r0_body.S965.tab.length + PRE_first_tail_x15_r0_body.cws99.length = 4334
-- the map as `Conv.compact_shift` states it (the call's counters for the literals)
kernel_rfl PRE_first_tail_x15_r0_body.zkap99 : PRE_first_tail_x15_r0_body.kappa99 = Conv.Map.compact PRE_first_tail_x15_r0_body.s965.next 2754206 PRE_first_tail_x15_r0_body.S965.tab.length PRE_first_tail_x15_r0_body.pl99 (PRE_first_tail_x15_r0_body.nr99.map NumV.ref) PRE_first_tail_x15_r0_body.kd99.big
  PRE_first_tail_x15_r0_body.kd99.region PRE_first_tail_x15_r0_body.kd99.nodeF
-- the bridge inactive at the canonical state (`Conv.FullShiftQ.toX`; the merged state's bridge is the canonical's: cbridge)
theorem PRE_first_tail_x15_r0_body.zbin99 : (Host.Ts.Sim.Full.bridgeOf PRE_first_tail_x15_r0_body.s967.ffi).active = false := (Host.Load.Boot.replay_active Host.Load.Run.Prompt.P.oblog2818)
-- the JS bookkeeping's step (`Conv.JClean.step` over the changed list) and the canonical roots' bigint freedom
kernel_rfl PRE_first_tail_x15_r0_body.zjc99 : Conv.jcleanListB (⟨20164, 17264, 2753057, 4334⟩ : Conv.Cnt) PRE_first_tail_x15_r0_body.s967 PRE_first_tail_x15_r0_body.cl99 = true
kernel_rfl PRE_first_tail_x15_r0_body.zrootsB99 : noBigRootsP (fun i => !Conv.oldBigB (⟨20164, 17264, 2753057, 4334⟩ : Conv.Cnt) i) PRE_first_tail_x15_r0_body.s967.trace PRE_first_tail_x15_r0_body.s967 = true
kernel_rfl PRE_first_tail_x15_r0_body.zhm99 : Nat.ble (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s0.ffi).mlx.nnext 17237 = true
theorem PRE_first_tail_x15_r0_body.cjcl99 (h : Conv.JClean (⟨20161, 17237, 2753051, 4316⟩ : Conv.Cnt) PRE_first_tail_x15_r0_body.s965) : Conv.JClean (⟨20164, 17264, 2753057, 4334⟩ : Conv.Cnt) PRE_first_tail_x15_r0_body.s967 :=
  Conv.JClean.step h (Conv.Cnt.le_of_leB PRE_first_tail_x15_r0_body.cle99)
    (Conv.heap_off_setAll PRE_first_tail_x15_r0_body.cheap99 fun a ha => Nat.blt_eq.mp (List.all_eq_true.mp PRE_first_tail_x15_r0_body.zclbd99 a ha)) PRE_first_tail_x15_r0_body.zjc99

end Host.Load.Run.Tpl
