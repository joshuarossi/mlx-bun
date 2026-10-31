import host.sim.template.a4pre_first_tail_x15_r0_body.SiteS60
import host.sim.template.a4pre_first_tail_x15_r0_body.SiteK60
import host.sim.template.a4pre_first_tail_x15_r0_body.SiteF60
import host.sim.conv.CompactShift
import host.sim.template.Check
import host.sim.BigFreeP
import host.sim.template.CallGen
set_option Elab.async false
namespace Host.Load.Run.Tpl
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
open Host.Ts Host.Ts.Sim Host.Ts.Sim.Template

/-! The compaction's state shift at call site 60 of chain `PRE_first_tail_x15_r0_body` (`Conv.compact_shift`): the call `PRE_first_tail_x15_r0_body.s539`, the merged
state `PRE_first_tail_x15_r0_body.s540`, the canonical state `PRE_first_tail_x15_r0_body.s541`; its frames [2665,2673467,2673472,2673473] (kept arrays [2665,2673467]). -/

-- the map's places and counters
kernel_rfl PRE_first_tail_x15_r0_body.zpl60 : PRE_first_tail_x15_r0_body.pl60.all (Nat.ble PRE_first_tail_x15_r0_body.s539.next) = true
kernel_rfl PRE_first_tail_x15_r0_body.zplnd60 : nodupT PRE_first_tail_x15_r0_body.pl60 PTrie.nil = true
kernel_rfl PRE_first_tail_x15_r0_body.zn160 : Nat.ble PRE_first_tail_x15_r0_body.s539.next 2723702 = true
kernel_rfl PRE_first_tail_x15_r0_body.zfirst60 : Nat.ble aFirst PRE_first_tail_x15_r0_body.s539.next = true
kernel_rfl PRE_first_tail_x15_r0_body.zscn60 : PRE_first_tail_x15_r0_body.s541.next = PRE_first_tail_x15_r0_body.s539.next + PRE_first_tail_x15_r0_body.pl60.length
kernel_rfl PRE_first_tail_x15_r0_body.zsmn60 : PRE_first_tail_x15_r0_body.s540.next = 2723702
kernel_rfl PRE_first_tail_x15_r0_body.zgrow60 : Nat.ble PRE_first_tail_x15_r0_body.s541.next PRE_first_tail_x15_r0_body.s540.next = true
-- the tables
kernel_rfl PRE_first_tail_x15_r0_body.zfresh60 : PRE_first_tail_x15_r0_body.S539.tab.all (fun e => PRE_first_tail_x15_r0_body.cws60.all fun v => e.noVar v) = true
kernel_rfl PRE_first_tail_x15_r0_body.zcnd60 : nodupT PRE_first_tail_x15_r0_body.cws60 PTrie.nil = true
kernel_rfl PRE_first_tail_x15_r0_body.znrHi60 : PRE_first_tail_x15_r0_body.nr60.all (fun r => Nat.blt r PRE_first_tail_x15_r0_body.S540.tab.length) = true
-- the frames: every framed address below the call's counter; the kept arrays the chain start's, extended in the merged state
kernel_rfl PRE_first_tail_x15_r0_body.zfrlt60 : [2665, 2673467, 2673472, 2673473].all (fun a => Nat.blt a PRE_first_tail_x15_r0_body.s539.next) = true
kernel_rfl PRE_first_tail_x15_r0_body.zg60_2665 : PRE_first_tail_x15_r0_body.s541.heap.get 2665 = some (.obj (objOf PRE_first_tail_x15_r0_body.s541 2665))
kernel_rfl PRE_first_tail_x15_r0_body.zk60_2665 : (objOf PRE_first_tail_x15_r0_body.s541 2665).kind = .array (arrOf PRE_first_tail_x15_r0_body.s0 2665)
kernel_rfl PRE_first_tail_x15_r0_body.zm60_2665 : PRE_first_tail_x15_r0_body.s540.heap.get 2665 = some (.obj { PRE_first_tail_x15_r0_body.kappa60.obj (objOf PRE_first_tail_x15_r0_body.s541 2665) with
  kind := .array (arrOf PRE_first_tail_x15_r0_body.s0 2665 ++ (arrOf PRE_first_tail_x15_r0_body.s540 2665).drop (arrOf PRE_first_tail_x15_r0_body.s0 2665).length) })
kernel_rfl PRE_first_tail_x15_r0_body.zg60_2673467 : PRE_first_tail_x15_r0_body.s541.heap.get 2673467 = some (.obj (objOf PRE_first_tail_x15_r0_body.s541 2673467))
kernel_rfl PRE_first_tail_x15_r0_body.zk60_2673467 : (objOf PRE_first_tail_x15_r0_body.s541 2673467).kind = .array (arrOf PRE_first_tail_x15_r0_body.s0 2673467)
kernel_rfl PRE_first_tail_x15_r0_body.zm60_2673467 : PRE_first_tail_x15_r0_body.s540.heap.get 2673467 = some (.obj { PRE_first_tail_x15_r0_body.kappa60.obj (objOf PRE_first_tail_x15_r0_body.s541 2673467) with
  kind := .array (arrOf PRE_first_tail_x15_r0_body.s0 2673467 ++ (arrOf PRE_first_tail_x15_r0_body.s540 2673467).drop (arrOf PRE_first_tail_x15_r0_body.s0 2673467).length) })
kernel_rfl PRE_first_tail_x15_r0_body.zw60_4910 : (PRE_first_tail_x15_r0_body.s541.heap.get 4910).isSome = true
kernel_rfl PRE_first_tail_x15_r0_body.zw60_2673472 : (PRE_first_tail_x15_r0_body.s541.heap.get 2673472).isSome = true
kernel_rfl PRE_first_tail_x15_r0_body.zw60_2673473 : (PRE_first_tail_x15_r0_body.s541.heap.get 2673473).isSome = true
-- the heap: the changed list in range, holding the stage's written and fresh addresses; the canonical side's image
kernel_rfl PRE_first_tail_x15_r0_body.zclbd60 : PRE_first_tail_x15_r0_body.cl60.all (fun b => Nat.blt (b / 4096) (4 ^ 31)) = true
kernel_rfl PRE_first_tail_x15_r0_body.zwr60 : PRE_first_tail_x15_r0_body.st60.wr.all (fun b => !Nat.blt b PRE_first_tail_x15_r0_body.s539.next || PRE_first_tail_x15_r0_body.cl60.contains b) = true
def PRE_first_tail_x15_r0_body.zl60 : List Nat := PRE_first_tail_x15_r0_body.cl60.filter fun a => !(List.contains [2665, 2673467] a)
kernel_rfl PRE_first_tail_x15_r0_body.zimgE60 : PRE_first_tail_x15_r0_body.zl60.map (fun a => PRE_first_tail_x15_r0_body.s540.heap.get (PRE_first_tail_x15_r0_body.kappa60.a a)) = PRE_first_tail_x15_r0_body.zl60.map (fun a => (PRE_first_tail_x15_r0_body.s541.heap.get a).map PRE_first_tail_x15_r0_body.kappa60.hobj)
theorem PRE_first_tail_x15_r0_body.zimg60 : HeapImg PRE_first_tail_x15_r0_body.kappa60 PRE_first_tail_x15_r0_body.s541 PRE_first_tail_x15_r0_body.s540 PRE_first_tail_x15_r0_body.zl60 := PRE_first_tail_x15_r0_body.zimgE60
-- the roots and their supports
kernel_rfl PRE_first_tail_x15_r0_body.zctl60 : PRE_first_tail_x15_r0_body.s540.ctl = PRE_first_tail_x15_r0_body.kappa60.ctl PRE_first_tail_x15_r0_body.s541.ctl
kernel_rfl PRE_first_tail_x15_r0_body.zstack60 : PRE_first_tail_x15_r0_body.s540.stack = PRE_first_tail_x15_r0_body.s541.stack.map PRE_first_tail_x15_r0_body.kappa60.frame
kernel_rfl PRE_first_tail_x15_r0_body.zjobs60 : PRE_first_tail_x15_r0_body.s540.jobs = PRE_first_tail_x15_r0_body.s541.jobs.map PRE_first_tail_x15_r0_body.kappa60.job
kernel_rfl PRE_first_tail_x15_r0_body.zstores60 : PRE_first_tail_x15_r0_body.s540.stores = PRE_first_tail_x15_r0_body.kappa60.stores PRE_first_tail_x15_r0_body.s541.stores
kernel_rfl PRE_first_tail_x15_r0_body.zroots60 : checkRootsSupp PRE_first_tail_x15_r0_body.s541 2666 = true
kernel_rfl PRE_first_tail_x15_r0_body.znC60 : PRE_first_tail_x15_r0_body.S539.tab.length + PRE_first_tail_x15_r0_body.cws60.length = 2666
-- the map as `Conv.compact_shift` states it (the call's counters for the literals)
kernel_rfl PRE_first_tail_x15_r0_body.zkap60 : PRE_first_tail_x15_r0_body.kappa60 = Conv.Map.compact PRE_first_tail_x15_r0_body.s539.next 2723702 PRE_first_tail_x15_r0_body.S539.tab.length PRE_first_tail_x15_r0_body.pl60 (PRE_first_tail_x15_r0_body.nr60.map NumV.ref) PRE_first_tail_x15_r0_body.kd60.big
  PRE_first_tail_x15_r0_body.kd60.region PRE_first_tail_x15_r0_body.kd60.nodeF
-- the bridge inactive at the canonical state (`Conv.FullShiftQ.toX`; the merged state's bridge is the canonical's: cbridge)
theorem PRE_first_tail_x15_r0_body.zbin60 : (Host.Ts.Sim.Full.bridgeOf PRE_first_tail_x15_r0_body.s541.ffi).active = false := (Host.Load.Boot.replay_active Host.Load.Run.Prompt.P.oblog2818)
-- the JS bookkeeping's step (`Conv.JClean.step` over the changed list) and the canonical roots' bigint freedom
kernel_rfl PRE_first_tail_x15_r0_body.zjc60 : Conv.jcleanListB (⟨19399, 16490, 2722553, 2666⟩ : Conv.Cnt) PRE_first_tail_x15_r0_body.s541 PRE_first_tail_x15_r0_body.cl60 = true
kernel_rfl PRE_first_tail_x15_r0_body.zroots260 : noBigRootsP (fun i => !Conv.oldBigB (⟨19399, 16490, 2722553, 2666⟩ : Conv.Cnt) i) PRE_first_tail_x15_r0_body.s541.trace PRE_first_tail_x15_r0_body.s541 = true
kernel_rfl PRE_first_tail_x15_r0_body.zhm60 : Nat.ble (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s0.ffi).mlx.nnext 16463 = true
theorem PRE_first_tail_x15_r0_body.cjcl60 (h : Conv.JClean (⟨19396, 16463, 2722547, 2648⟩ : Conv.Cnt) PRE_first_tail_x15_r0_body.s539) : Conv.JClean (⟨19399, 16490, 2722553, 2666⟩ : Conv.Cnt) PRE_first_tail_x15_r0_body.s541 :=
  Conv.JClean.step h (Conv.Cnt.le_of_leB PRE_first_tail_x15_r0_body.cle60)
    (Conv.heap_off_setAll PRE_first_tail_x15_r0_body.cheap60 fun a ha => Nat.blt_eq.mp (List.all_eq_true.mp PRE_first_tail_x15_r0_body.zclbd60 a ha)) PRE_first_tail_x15_r0_body.zjc60

end Host.Load.Run.Tpl
