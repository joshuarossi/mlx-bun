import host.sim.template.a4pre_first_tail_x15_r0_body.SiteS104
import host.sim.template.a4pre_first_tail_x15_r0_body.SiteK104
import host.sim.template.a4pre_first_tail_x15_r0_body.SiteF104
import host.sim.conv.CompactShift
import host.sim.template.Check
import host.sim.BigFreeP
import host.sim.template.CallGen
set_option Elab.async false
namespace Host.Load.Run.Tpl
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
open Host.Ts Host.Ts.Sim Host.Ts.Sim.Template

/-! The compaction's state shift at call site 104 of chain `PRE_first_tail_x15_r0_body` (`Conv.compact_shift`): the call `PRE_first_tail_x15_r0_body.s1006`, the merged
state `PRE_first_tail_x15_r0_body.s1007`, the canonical state `PRE_first_tail_x15_r0_body.s1008`; its frames [2665,2673467,2673472,2673473] (kept arrays [2665,2673467]). -/

-- the map's places and counters
kernel_rfl PRE_first_tail_x15_r0_body.zpl104 : PRE_first_tail_x15_r0_body.pl104.all (Nat.ble PRE_first_tail_x15_r0_body.s1006.next) = true
kernel_rfl PRE_first_tail_x15_r0_body.zplnd104 : nodupT PRE_first_tail_x15_r0_body.pl104 PTrie.nil = true
kernel_rfl PRE_first_tail_x15_r0_body.zn1104 : Nat.ble PRE_first_tail_x15_r0_body.s1006.next 2756106 = true
kernel_rfl PRE_first_tail_x15_r0_body.zfirst104 : Nat.ble aFirst PRE_first_tail_x15_r0_body.s1006.next = true
kernel_rfl PRE_first_tail_x15_r0_body.zscn104 : PRE_first_tail_x15_r0_body.s1008.next = PRE_first_tail_x15_r0_body.s1006.next + PRE_first_tail_x15_r0_body.pl104.length
kernel_rfl PRE_first_tail_x15_r0_body.zsmn104 : PRE_first_tail_x15_r0_body.s1007.next = 2756106
kernel_rfl PRE_first_tail_x15_r0_body.zgrow104 : Nat.ble PRE_first_tail_x15_r0_body.s1008.next PRE_first_tail_x15_r0_body.s1007.next = true
-- the tables
kernel_rfl PRE_first_tail_x15_r0_body.zfresh104 : PRE_first_tail_x15_r0_body.S1006.tab.all (fun e => PRE_first_tail_x15_r0_body.cws104.all fun v => e.noVar v) = true
kernel_rfl PRE_first_tail_x15_r0_body.zcnd104 : nodupT PRE_first_tail_x15_r0_body.cws104 PTrie.nil = true
kernel_rfl PRE_first_tail_x15_r0_body.znrHi104 : PRE_first_tail_x15_r0_body.nr104.all (fun r => Nat.blt r PRE_first_tail_x15_r0_body.S1007.tab.length) = true
-- the frames: every framed address below the call's counter; the kept arrays the chain start's, extended in the merged state
kernel_rfl PRE_first_tail_x15_r0_body.zfrlt104 : [2665, 2673467, 2673472, 2673473].all (fun a => Nat.blt a PRE_first_tail_x15_r0_body.s1006.next) = true
kernel_rfl PRE_first_tail_x15_r0_body.zg104_2665 : PRE_first_tail_x15_r0_body.s1008.heap.get 2665 = some (.obj (objOf PRE_first_tail_x15_r0_body.s1008 2665))
kernel_rfl PRE_first_tail_x15_r0_body.zk104_2665 : (objOf PRE_first_tail_x15_r0_body.s1008 2665).kind = .array (arrOf PRE_first_tail_x15_r0_body.s0 2665)
kernel_rfl PRE_first_tail_x15_r0_body.zm104_2665 : PRE_first_tail_x15_r0_body.s1007.heap.get 2665 = some (.obj { PRE_first_tail_x15_r0_body.kappa104.obj (objOf PRE_first_tail_x15_r0_body.s1008 2665) with
  kind := .array (arrOf PRE_first_tail_x15_r0_body.s0 2665 ++ (arrOf PRE_first_tail_x15_r0_body.s1007 2665).drop (arrOf PRE_first_tail_x15_r0_body.s0 2665).length) })
kernel_rfl PRE_first_tail_x15_r0_body.zg104_2673467 : PRE_first_tail_x15_r0_body.s1008.heap.get 2673467 = some (.obj (objOf PRE_first_tail_x15_r0_body.s1008 2673467))
kernel_rfl PRE_first_tail_x15_r0_body.zk104_2673467 : (objOf PRE_first_tail_x15_r0_body.s1008 2673467).kind = .array (arrOf PRE_first_tail_x15_r0_body.s0 2673467)
kernel_rfl PRE_first_tail_x15_r0_body.zm104_2673467 : PRE_first_tail_x15_r0_body.s1007.heap.get 2673467 = some (.obj { PRE_first_tail_x15_r0_body.kappa104.obj (objOf PRE_first_tail_x15_r0_body.s1008 2673467) with
  kind := .array (arrOf PRE_first_tail_x15_r0_body.s0 2673467 ++ (arrOf PRE_first_tail_x15_r0_body.s1007 2673467).drop (arrOf PRE_first_tail_x15_r0_body.s0 2673467).length) })
kernel_rfl PRE_first_tail_x15_r0_body.zw104_4910 : (PRE_first_tail_x15_r0_body.s1008.heap.get 4910).isSome = true
kernel_rfl PRE_first_tail_x15_r0_body.zw104_2673472 : (PRE_first_tail_x15_r0_body.s1008.heap.get 2673472).isSome = true
kernel_rfl PRE_first_tail_x15_r0_body.zw104_2673473 : (PRE_first_tail_x15_r0_body.s1008.heap.get 2673473).isSome = true
-- the heap: the changed list in range, holding the stage's written and fresh addresses; the canonical side's image
kernel_rfl PRE_first_tail_x15_r0_body.zclbd104 : PRE_first_tail_x15_r0_body.cl104.all (fun b => Nat.blt (b / 4096) (4 ^ 31)) = true
kernel_rfl PRE_first_tail_x15_r0_body.zwr104 : PRE_first_tail_x15_r0_body.st104.wr.all (fun b => !Nat.blt b PRE_first_tail_x15_r0_body.s1006.next || PRE_first_tail_x15_r0_body.cl104.contains b) = true
def PRE_first_tail_x15_r0_body.zl104 : List Nat := PRE_first_tail_x15_r0_body.cl104.filter fun a => !(List.contains [2665, 2673467] a)
kernel_rfl PRE_first_tail_x15_r0_body.zimgE104 : PRE_first_tail_x15_r0_body.zl104.map (fun a => PRE_first_tail_x15_r0_body.s1007.heap.get (PRE_first_tail_x15_r0_body.kappa104.a a)) = PRE_first_tail_x15_r0_body.zl104.map (fun a => (PRE_first_tail_x15_r0_body.s1008.heap.get a).map PRE_first_tail_x15_r0_body.kappa104.hobj)
theorem PRE_first_tail_x15_r0_body.zimg104 : HeapImg PRE_first_tail_x15_r0_body.kappa104 PRE_first_tail_x15_r0_body.s1008 PRE_first_tail_x15_r0_body.s1007 PRE_first_tail_x15_r0_body.zl104 := PRE_first_tail_x15_r0_body.zimgE104
-- the roots and their supports
kernel_rfl PRE_first_tail_x15_r0_body.zctl104 : PRE_first_tail_x15_r0_body.s1007.ctl = PRE_first_tail_x15_r0_body.kappa104.ctl PRE_first_tail_x15_r0_body.s1008.ctl
kernel_rfl PRE_first_tail_x15_r0_body.zstack104 : PRE_first_tail_x15_r0_body.s1007.stack = PRE_first_tail_x15_r0_body.s1008.stack.map PRE_first_tail_x15_r0_body.kappa104.frame
kernel_rfl PRE_first_tail_x15_r0_body.zjobs104 : PRE_first_tail_x15_r0_body.s1007.jobs = PRE_first_tail_x15_r0_body.s1008.jobs.map PRE_first_tail_x15_r0_body.kappa104.job
kernel_rfl PRE_first_tail_x15_r0_body.zstores104 : PRE_first_tail_x15_r0_body.s1007.stores = PRE_first_tail_x15_r0_body.kappa104.stores PRE_first_tail_x15_r0_body.s1008.stores
kernel_rfl PRE_first_tail_x15_r0_body.zroots104 : checkRootsSupp PRE_first_tail_x15_r0_body.s1008 4501 = true
kernel_rfl PRE_first_tail_x15_r0_body.znC104 : PRE_first_tail_x15_r0_body.S1006.tab.length + PRE_first_tail_x15_r0_body.cws104.length = 4501
-- the map as `Conv.compact_shift` states it (the call's counters for the literals)
kernel_rfl PRE_first_tail_x15_r0_body.zkap104 : PRE_first_tail_x15_r0_body.kappa104 = Conv.Map.compact PRE_first_tail_x15_r0_body.s1006.next 2756106 PRE_first_tail_x15_r0_body.S1006.tab.length PRE_first_tail_x15_r0_body.pl104 (PRE_first_tail_x15_r0_body.nr104.map NumV.ref) PRE_first_tail_x15_r0_body.kd104.big
  PRE_first_tail_x15_r0_body.kd104.region PRE_first_tail_x15_r0_body.kd104.nodeF
-- the bridge inactive at the canonical state (`Conv.FullShiftQ.toX`; the merged state's bridge is the canonical's: cbridge)
theorem PRE_first_tail_x15_r0_body.zbin104 : (Host.Ts.Sim.Full.bridgeOf PRE_first_tail_x15_r0_body.s1008.ffi).active = false := (Host.Load.Boot.replay_active Host.Load.Run.Prompt.P.oblog2818)
-- the JS bookkeeping's step (`Conv.JClean.step` over the changed list) and the canonical roots' bigint freedom
kernel_rfl PRE_first_tail_x15_r0_body.zjc104 : Conv.jcleanListB (⟨20241, 17344, 2756096, 4501⟩ : Conv.Cnt) PRE_first_tail_x15_r0_body.s1008 PRE_first_tail_x15_r0_body.cl104 = true
kernel_rfl PRE_first_tail_x15_r0_body.zrootsB104 : noBigRootsP (fun i => !Conv.oldBigB (⟨20241, 17344, 2756096, 4501⟩ : Conv.Cnt) i) PRE_first_tail_x15_r0_body.s1008.trace PRE_first_tail_x15_r0_body.s1008 = true
kernel_rfl PRE_first_tail_x15_r0_body.zhm104 : Nat.ble (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s0.ffi).mlx.nnext 17344 = true
theorem PRE_first_tail_x15_r0_body.cjcl104 (h : Conv.JClean (⟨20241, 17344, 2756095, 4501⟩ : Conv.Cnt) PRE_first_tail_x15_r0_body.s1006) : Conv.JClean (⟨20241, 17344, 2756096, 4501⟩ : Conv.Cnt) PRE_first_tail_x15_r0_body.s1008 :=
  Conv.JClean.step h (Conv.Cnt.le_of_leB PRE_first_tail_x15_r0_body.cle104)
    (Conv.heap_off_setAll PRE_first_tail_x15_r0_body.cheap104 fun a ha => Nat.blt_eq.mp (List.all_eq_true.mp PRE_first_tail_x15_r0_body.zclbd104 a ha)) PRE_first_tail_x15_r0_body.zjc104

end Host.Load.Run.Tpl
