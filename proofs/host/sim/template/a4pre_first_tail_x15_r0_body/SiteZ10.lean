import host.sim.template.a4pre_first_tail_x15_r0_body.SiteS10
import host.sim.template.a4pre_first_tail_x15_r0_body.SiteK10
import host.sim.template.a4pre_first_tail_x15_r0_body.SiteF10
import host.sim.conv.CompactShift
import host.sim.template.Check
import host.sim.BigFreeP
import host.sim.template.CallGen
set_option Elab.async false
namespace Host.Load.Run.Tpl
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
open Host.Ts Host.Ts.Sim Host.Ts.Sim.Template

/-! The compaction's state shift at call site 10 of chain `PRE_first_tail_x15_r0_body` (`Conv.compact_shift`): the call `PRE_first_tail_x15_r0_body.s110`, the merged
state `PRE_first_tail_x15_r0_body.s111`, the canonical state `PRE_first_tail_x15_r0_body.s112`; its frames [2665,2673467,2673472,2673473] (kept arrays [2665,2673467]). -/

-- the map's places and counters
kernel_rfl PRE_first_tail_x15_r0_body.zpl10 : PRE_first_tail_x15_r0_body.pl10.all (Nat.ble PRE_first_tail_x15_r0_body.s110.next) = true
kernel_rfl PRE_first_tail_x15_r0_body.zplnd10 : nodupT PRE_first_tail_x15_r0_body.pl10 PTrie.nil = true
kernel_rfl PRE_first_tail_x15_r0_body.zn110 : Nat.ble PRE_first_tail_x15_r0_body.s110.next 2683095 = true
kernel_rfl PRE_first_tail_x15_r0_body.zfirst10 : Nat.ble aFirst PRE_first_tail_x15_r0_body.s110.next = true
kernel_rfl PRE_first_tail_x15_r0_body.zscn10 : PRE_first_tail_x15_r0_body.s112.next = PRE_first_tail_x15_r0_body.s110.next + PRE_first_tail_x15_r0_body.pl10.length
kernel_rfl PRE_first_tail_x15_r0_body.zsmn10 : PRE_first_tail_x15_r0_body.s111.next = 2683095
kernel_rfl PRE_first_tail_x15_r0_body.zgrow10 : Nat.ble PRE_first_tail_x15_r0_body.s112.next PRE_first_tail_x15_r0_body.s111.next = true
-- the tables
kernel_rfl PRE_first_tail_x15_r0_body.zfresh10 : PRE_first_tail_x15_r0_body.S110.tab.all (fun e => PRE_first_tail_x15_r0_body.cws10.all fun v => e.noVar v) = true
kernel_rfl PRE_first_tail_x15_r0_body.zcnd10 : nodupT PRE_first_tail_x15_r0_body.cws10 PTrie.nil = true
kernel_rfl PRE_first_tail_x15_r0_body.znrHi10 : PRE_first_tail_x15_r0_body.nr10.all (fun r => Nat.blt r PRE_first_tail_x15_r0_body.S111.tab.length) = true
-- the frames: every framed address below the call's counter; the kept arrays the chain start's, extended in the merged state
kernel_rfl PRE_first_tail_x15_r0_body.zfrlt10 : [2665, 2673467, 2673472, 2673473].all (fun a => Nat.blt a PRE_first_tail_x15_r0_body.s110.next) = true
kernel_rfl PRE_first_tail_x15_r0_body.zg10_2665 : PRE_first_tail_x15_r0_body.s112.heap.get 2665 = some (.obj (objOf PRE_first_tail_x15_r0_body.s112 2665))
kernel_rfl PRE_first_tail_x15_r0_body.zk10_2665 : (objOf PRE_first_tail_x15_r0_body.s112 2665).kind = .array (arrOf PRE_first_tail_x15_r0_body.s0 2665)
kernel_rfl PRE_first_tail_x15_r0_body.zm10_2665 : PRE_first_tail_x15_r0_body.s111.heap.get 2665 = some (.obj { PRE_first_tail_x15_r0_body.kappa10.obj (objOf PRE_first_tail_x15_r0_body.s112 2665) with
  kind := .array (arrOf PRE_first_tail_x15_r0_body.s0 2665 ++ (arrOf PRE_first_tail_x15_r0_body.s111 2665).drop (arrOf PRE_first_tail_x15_r0_body.s0 2665).length) })
kernel_rfl PRE_first_tail_x15_r0_body.zg10_2673467 : PRE_first_tail_x15_r0_body.s112.heap.get 2673467 = some (.obj (objOf PRE_first_tail_x15_r0_body.s112 2673467))
kernel_rfl PRE_first_tail_x15_r0_body.zk10_2673467 : (objOf PRE_first_tail_x15_r0_body.s112 2673467).kind = .array (arrOf PRE_first_tail_x15_r0_body.s0 2673467)
kernel_rfl PRE_first_tail_x15_r0_body.zm10_2673467 : PRE_first_tail_x15_r0_body.s111.heap.get 2673467 = some (.obj { PRE_first_tail_x15_r0_body.kappa10.obj (objOf PRE_first_tail_x15_r0_body.s112 2673467) with
  kind := .array (arrOf PRE_first_tail_x15_r0_body.s0 2673467 ++ (arrOf PRE_first_tail_x15_r0_body.s111 2673467).drop (arrOf PRE_first_tail_x15_r0_body.s0 2673467).length) })
kernel_rfl PRE_first_tail_x15_r0_body.zw10_4910 : (PRE_first_tail_x15_r0_body.s112.heap.get 4910).isSome = true
kernel_rfl PRE_first_tail_x15_r0_body.zw10_2673472 : (PRE_first_tail_x15_r0_body.s112.heap.get 2673472).isSome = true
kernel_rfl PRE_first_tail_x15_r0_body.zw10_2673473 : (PRE_first_tail_x15_r0_body.s112.heap.get 2673473).isSome = true
-- the heap: the changed list in range, holding the stage's written and fresh addresses; the canonical side's image
kernel_rfl PRE_first_tail_x15_r0_body.zclbd10 : PRE_first_tail_x15_r0_body.cl10.all (fun b => Nat.blt (b / 4096) (4 ^ 31)) = true
kernel_rfl PRE_first_tail_x15_r0_body.zwr10 : PRE_first_tail_x15_r0_body.st10.wr.all (fun b => !Nat.blt b PRE_first_tail_x15_r0_body.s110.next || PRE_first_tail_x15_r0_body.cl10.contains b) = true
def PRE_first_tail_x15_r0_body.zl10 : List Nat := PRE_first_tail_x15_r0_body.cl10.filter fun a => !(List.contains [2665, 2673467] a)
kernel_rfl PRE_first_tail_x15_r0_body.zimgE10 : PRE_first_tail_x15_r0_body.zl10.map (fun a => PRE_first_tail_x15_r0_body.s111.heap.get (PRE_first_tail_x15_r0_body.kappa10.a a)) = PRE_first_tail_x15_r0_body.zl10.map (fun a => (PRE_first_tail_x15_r0_body.s112.heap.get a).map PRE_first_tail_x15_r0_body.kappa10.hobj)
theorem PRE_first_tail_x15_r0_body.zimg10 : HeapImg PRE_first_tail_x15_r0_body.kappa10 PRE_first_tail_x15_r0_body.s112 PRE_first_tail_x15_r0_body.s111 PRE_first_tail_x15_r0_body.zl10 := PRE_first_tail_x15_r0_body.zimgE10
-- the roots and their supports
kernel_rfl PRE_first_tail_x15_r0_body.zctl10 : PRE_first_tail_x15_r0_body.s111.ctl = PRE_first_tail_x15_r0_body.kappa10.ctl PRE_first_tail_x15_r0_body.s112.ctl
kernel_rfl PRE_first_tail_x15_r0_body.zstack10 : PRE_first_tail_x15_r0_body.s111.stack = PRE_first_tail_x15_r0_body.s112.stack.map PRE_first_tail_x15_r0_body.kappa10.frame
kernel_rfl PRE_first_tail_x15_r0_body.zjobs10 : PRE_first_tail_x15_r0_body.s111.jobs = PRE_first_tail_x15_r0_body.s112.jobs.map PRE_first_tail_x15_r0_body.kappa10.job
kernel_rfl PRE_first_tail_x15_r0_body.zstores10 : PRE_first_tail_x15_r0_body.s111.stores = PRE_first_tail_x15_r0_body.kappa10.stores PRE_first_tail_x15_r0_body.s112.stores
kernel_rfl PRE_first_tail_x15_r0_body.zroots10 : checkRootsSupp PRE_first_tail_x15_r0_body.s112 506 = true
kernel_rfl PRE_first_tail_x15_r0_body.znC10 : PRE_first_tail_x15_r0_body.S110.tab.length + PRE_first_tail_x15_r0_body.cws10.length = 506
-- the map as `Conv.compact_shift` states it (the call's counters for the literals)
kernel_rfl PRE_first_tail_x15_r0_body.zkap10 : PRE_first_tail_x15_r0_body.kappa10 = Conv.Map.compact PRE_first_tail_x15_r0_body.s110.next 2683095 PRE_first_tail_x15_r0_body.S110.tab.length PRE_first_tail_x15_r0_body.pl10 (PRE_first_tail_x15_r0_body.nr10.map NumV.ref) PRE_first_tail_x15_r0_body.kd10.big
  PRE_first_tail_x15_r0_body.kd10.region PRE_first_tail_x15_r0_body.kd10.nodeF
-- the bridge inactive at the canonical state (`Conv.FullShiftQ.toX`; the merged state's bridge is the canonical's: cbridge)
theorem PRE_first_tail_x15_r0_body.zbin10 : (Host.Ts.Sim.Full.bridgeOf PRE_first_tail_x15_r0_body.s112.ffi).active = false := (Host.Load.Boot.replay_active Host.Load.Run.Prompt.P.oblog2818)
-- the JS bookkeeping's step (`Conv.JClean.step` over the changed list) and the canonical roots' bigint freedom
kernel_rfl PRE_first_tail_x15_r0_body.zjc10 : Conv.jcleanListB (⟨18410, 15492, 2683093, 506⟩ : Conv.Cnt) PRE_first_tail_x15_r0_body.s112 PRE_first_tail_x15_r0_body.cl10 = true
kernel_rfl PRE_first_tail_x15_r0_body.zrootsB10 : noBigRootsP (fun i => !Conv.oldBigB (⟨18410, 15492, 2683093, 506⟩ : Conv.Cnt) i) PRE_first_tail_x15_r0_body.s112.trace PRE_first_tail_x15_r0_body.s112 = true
kernel_rfl PRE_first_tail_x15_r0_body.zhm10 : Nat.ble (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s0.ffi).mlx.nnext 15492 = true
theorem PRE_first_tail_x15_r0_body.cjcl10 (h : Conv.JClean (⟨18410, 15492, 2683093, 506⟩ : Conv.Cnt) PRE_first_tail_x15_r0_body.s110) : Conv.JClean (⟨18410, 15492, 2683093, 506⟩ : Conv.Cnt) PRE_first_tail_x15_r0_body.s112 :=
  Conv.JClean.step h (Conv.Cnt.le_of_leB PRE_first_tail_x15_r0_body.cle10)
    (Conv.heap_off_setAll PRE_first_tail_x15_r0_body.cheap10 fun a ha => Nat.blt_eq.mp (List.all_eq_true.mp PRE_first_tail_x15_r0_body.zclbd10 a ha)) PRE_first_tail_x15_r0_body.zjc10

end Host.Load.Run.Tpl
