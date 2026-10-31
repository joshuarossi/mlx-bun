import host.sim.template.a4pre_first_tail_x15_r0_body.SiteS33
import host.sim.template.a4pre_first_tail_x15_r0_body.SiteK33
import host.sim.template.a4pre_first_tail_x15_r0_body.SiteF33
import host.sim.conv.CompactShift
import host.sim.template.Check
import host.sim.BigFreeP
import host.sim.template.CallGen
set_option Elab.async false
namespace Host.Load.Run.Tpl
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
open Host.Ts Host.Ts.Sim Host.Ts.Sim.Template

/-! The compaction's state shift at call site 33 of chain `PRE_first_tail_x15_r0_body` (`Conv.compact_shift`): the call `PRE_first_tail_x15_r0_body.s302`, the merged
state `PRE_first_tail_x15_r0_body.s303`, the canonical state `PRE_first_tail_x15_r0_body.s304`; its frames [2665,2673467,2673472,2673473] (kept arrays [2665,2673467]). -/

-- the map's places and counters
kernel_rfl PRE_first_tail_x15_r0_body.zpl33 : PRE_first_tail_x15_r0_body.pl33.all (Nat.ble PRE_first_tail_x15_r0_body.s302.next) = true
kernel_rfl PRE_first_tail_x15_r0_body.zplnd33 : nodupT PRE_first_tail_x15_r0_body.pl33 PTrie.nil = true
kernel_rfl PRE_first_tail_x15_r0_body.zn133 : Nat.ble PRE_first_tail_x15_r0_body.s302.next 2701685 = true
kernel_rfl PRE_first_tail_x15_r0_body.zfirst33 : Nat.ble aFirst PRE_first_tail_x15_r0_body.s302.next = true
kernel_rfl PRE_first_tail_x15_r0_body.zscn33 : PRE_first_tail_x15_r0_body.s304.next = PRE_first_tail_x15_r0_body.s302.next + PRE_first_tail_x15_r0_body.pl33.length
kernel_rfl PRE_first_tail_x15_r0_body.zsmn33 : PRE_first_tail_x15_r0_body.s303.next = 2701685
kernel_rfl PRE_first_tail_x15_r0_body.zgrow33 : Nat.ble PRE_first_tail_x15_r0_body.s304.next PRE_first_tail_x15_r0_body.s303.next = true
-- the tables
kernel_rfl PRE_first_tail_x15_r0_body.zfresh33 : PRE_first_tail_x15_r0_body.S302.tab.all (fun e => PRE_first_tail_x15_r0_body.cws33.all fun v => e.noVar v) = true
kernel_rfl PRE_first_tail_x15_r0_body.zcnd33 : nodupT PRE_first_tail_x15_r0_body.cws33 PTrie.nil = true
kernel_rfl PRE_first_tail_x15_r0_body.znrHi33 : PRE_first_tail_x15_r0_body.nr33.all (fun r => Nat.blt r PRE_first_tail_x15_r0_body.S303.tab.length) = true
-- the frames: every framed address below the call's counter; the kept arrays the chain start's, extended in the merged state
kernel_rfl PRE_first_tail_x15_r0_body.zfrlt33 : [2665, 2673467, 2673472, 2673473].all (fun a => Nat.blt a PRE_first_tail_x15_r0_body.s302.next) = true
kernel_rfl PRE_first_tail_x15_r0_body.zg33_2665 : PRE_first_tail_x15_r0_body.s304.heap.get 2665 = some (.obj (objOf PRE_first_tail_x15_r0_body.s304 2665))
kernel_rfl PRE_first_tail_x15_r0_body.zk33_2665 : (objOf PRE_first_tail_x15_r0_body.s304 2665).kind = .array (arrOf PRE_first_tail_x15_r0_body.s0 2665)
kernel_rfl PRE_first_tail_x15_r0_body.zm33_2665 : PRE_first_tail_x15_r0_body.s303.heap.get 2665 = some (.obj { PRE_first_tail_x15_r0_body.kappa33.obj (objOf PRE_first_tail_x15_r0_body.s304 2665) with
  kind := .array (arrOf PRE_first_tail_x15_r0_body.s0 2665 ++ (arrOf PRE_first_tail_x15_r0_body.s303 2665).drop (arrOf PRE_first_tail_x15_r0_body.s0 2665).length) })
kernel_rfl PRE_first_tail_x15_r0_body.zg33_2673467 : PRE_first_tail_x15_r0_body.s304.heap.get 2673467 = some (.obj (objOf PRE_first_tail_x15_r0_body.s304 2673467))
kernel_rfl PRE_first_tail_x15_r0_body.zk33_2673467 : (objOf PRE_first_tail_x15_r0_body.s304 2673467).kind = .array (arrOf PRE_first_tail_x15_r0_body.s0 2673467)
kernel_rfl PRE_first_tail_x15_r0_body.zm33_2673467 : PRE_first_tail_x15_r0_body.s303.heap.get 2673467 = some (.obj { PRE_first_tail_x15_r0_body.kappa33.obj (objOf PRE_first_tail_x15_r0_body.s304 2673467) with
  kind := .array (arrOf PRE_first_tail_x15_r0_body.s0 2673467 ++ (arrOf PRE_first_tail_x15_r0_body.s303 2673467).drop (arrOf PRE_first_tail_x15_r0_body.s0 2673467).length) })
kernel_rfl PRE_first_tail_x15_r0_body.zw33_4910 : (PRE_first_tail_x15_r0_body.s304.heap.get 4910).isSome = true
kernel_rfl PRE_first_tail_x15_r0_body.zw33_2673472 : (PRE_first_tail_x15_r0_body.s304.heap.get 2673472).isSome = true
kernel_rfl PRE_first_tail_x15_r0_body.zw33_2673473 : (PRE_first_tail_x15_r0_body.s304.heap.get 2673473).isSome = true
-- the heap: the changed list in range, holding the stage's written and fresh addresses; the canonical side's image
kernel_rfl PRE_first_tail_x15_r0_body.zclbd33 : PRE_first_tail_x15_r0_body.cl33.all (fun b => Nat.blt (b / 4096) (4 ^ 31)) = true
kernel_rfl PRE_first_tail_x15_r0_body.zwr33 : PRE_first_tail_x15_r0_body.st33.wr.all (fun b => !Nat.blt b PRE_first_tail_x15_r0_body.s302.next || PRE_first_tail_x15_r0_body.cl33.contains b) = true
def PRE_first_tail_x15_r0_body.zl33 : List Nat := PRE_first_tail_x15_r0_body.cl33.filter fun a => !(List.contains [2665, 2673467] a)
kernel_rfl PRE_first_tail_x15_r0_body.zimgE33 : PRE_first_tail_x15_r0_body.zl33.map (fun a => PRE_first_tail_x15_r0_body.s303.heap.get (PRE_first_tail_x15_r0_body.kappa33.a a)) = PRE_first_tail_x15_r0_body.zl33.map (fun a => (PRE_first_tail_x15_r0_body.s304.heap.get a).map PRE_first_tail_x15_r0_body.kappa33.hobj)
theorem PRE_first_tail_x15_r0_body.zimg33 : HeapImg PRE_first_tail_x15_r0_body.kappa33 PRE_first_tail_x15_r0_body.s304 PRE_first_tail_x15_r0_body.s303 PRE_first_tail_x15_r0_body.zl33 := PRE_first_tail_x15_r0_body.zimgE33
-- the roots and their supports
kernel_rfl PRE_first_tail_x15_r0_body.zctl33 : PRE_first_tail_x15_r0_body.s303.ctl = PRE_first_tail_x15_r0_body.kappa33.ctl PRE_first_tail_x15_r0_body.s304.ctl
kernel_rfl PRE_first_tail_x15_r0_body.zstack33 : PRE_first_tail_x15_r0_body.s303.stack = PRE_first_tail_x15_r0_body.s304.stack.map PRE_first_tail_x15_r0_body.kappa33.frame
kernel_rfl PRE_first_tail_x15_r0_body.zjobs33 : PRE_first_tail_x15_r0_body.s303.jobs = PRE_first_tail_x15_r0_body.s304.jobs.map PRE_first_tail_x15_r0_body.kappa33.job
kernel_rfl PRE_first_tail_x15_r0_body.zstores33 : PRE_first_tail_x15_r0_body.s303.stores = PRE_first_tail_x15_r0_body.kappa33.stores PRE_first_tail_x15_r0_body.s304.stores
kernel_rfl PRE_first_tail_x15_r0_body.zroots33 : checkRootsSupp PRE_first_tail_x15_r0_body.s304 1509 = true
kernel_rfl PRE_first_tail_x15_r0_body.znC33 : PRE_first_tail_x15_r0_body.S302.tab.length + PRE_first_tail_x15_r0_body.cws33.length = 1509
-- the map as `Conv.compact_shift` states it (the call's counters for the literals)
kernel_rfl PRE_first_tail_x15_r0_body.zkap33 : PRE_first_tail_x15_r0_body.kappa33 = Conv.Map.compact PRE_first_tail_x15_r0_body.s302.next 2701685 PRE_first_tail_x15_r0_body.S302.tab.length PRE_first_tail_x15_r0_body.pl33 (PRE_first_tail_x15_r0_body.nr33.map NumV.ref) PRE_first_tail_x15_r0_body.kd33.big
  PRE_first_tail_x15_r0_body.kd33.region PRE_first_tail_x15_r0_body.kd33.nodeF
-- the bridge inactive at the canonical state (`Conv.FullShiftQ.toX`; the merged state's bridge is the canonical's: cbridge)
theorem PRE_first_tail_x15_r0_body.zbin33 : (Host.Ts.Sim.Full.bridgeOf PRE_first_tail_x15_r0_body.s304.ffi).active = false := (Host.Load.Boot.replay_active Host.Load.Run.Prompt.P.oblog2818)
-- the JS bookkeeping's step (`Conv.JClean.step` over the changed list) and the canonical roots' bigint freedom
kernel_rfl PRE_first_tail_x15_r0_body.zjc33 : Conv.jcleanListB (⟨18869, 15956, 2701335, 1509⟩ : Conv.Cnt) PRE_first_tail_x15_r0_body.s304 PRE_first_tail_x15_r0_body.cl33 = true
kernel_rfl PRE_first_tail_x15_r0_body.zroots233 : noBigRootsP (fun i => !Conv.oldBigB (⟨18869, 15956, 2701335, 1509⟩ : Conv.Cnt) i) PRE_first_tail_x15_r0_body.s304.trace PRE_first_tail_x15_r0_body.s304 = true
kernel_rfl PRE_first_tail_x15_r0_body.zhm33 : Nat.ble (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s0.ffi).mlx.nnext 15950 = true
theorem PRE_first_tail_x15_r0_body.cjcl33 (h : Conv.JClean (⟨18865, 15950, 2701320, 1500⟩ : Conv.Cnt) PRE_first_tail_x15_r0_body.s302) : Conv.JClean (⟨18869, 15956, 2701335, 1509⟩ : Conv.Cnt) PRE_first_tail_x15_r0_body.s304 :=
  Conv.JClean.step h (Conv.Cnt.le_of_leB PRE_first_tail_x15_r0_body.cle33)
    (Conv.heap_off_setAll PRE_first_tail_x15_r0_body.cheap33 fun a ha => Nat.blt_eq.mp (List.all_eq_true.mp PRE_first_tail_x15_r0_body.zclbd33 a ha)) PRE_first_tail_x15_r0_body.zjc33

end Host.Load.Run.Tpl
