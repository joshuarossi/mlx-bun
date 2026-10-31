import host.sim.template.a4pre_first_tail_x15_r0_body.SiteS88
import host.sim.template.a4pre_first_tail_x15_r0_body.SiteK88
import host.sim.template.a4pre_first_tail_x15_r0_body.SiteF88
import host.sim.conv.CompactShift
import host.sim.template.Check
import host.sim.BigFreeP
import host.sim.template.CallGen
set_option Elab.async false
namespace Host.Load.Run.Tpl
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
open Host.Ts Host.Ts.Sim Host.Ts.Sim.Template

/-! The compaction's state shift at call site 88 of chain `PRE_first_tail_x15_r0_body` (`Conv.compact_shift`): the call `PRE_first_tail_x15_r0_body.s858`, the merged
state `PRE_first_tail_x15_r0_body.s859`, the canonical state `PRE_first_tail_x15_r0_body.s860`; its frames [2665,2673467,2673472,2673473] (kept arrays [2665,2673467]). -/

-- the map's places and counters
kernel_rfl PRE_first_tail_x15_r0_body.zpl88 : PRE_first_tail_x15_r0_body.pl88.all (Nat.ble PRE_first_tail_x15_r0_body.s858.next) = true
kernel_rfl PRE_first_tail_x15_r0_body.zplnd88 : nodupT PRE_first_tail_x15_r0_body.pl88 PTrie.nil = true
kernel_rfl PRE_first_tail_x15_r0_body.zn188 : Nat.ble PRE_first_tail_x15_r0_body.s858.next 2744125 = true
kernel_rfl PRE_first_tail_x15_r0_body.zfirst88 : Nat.ble aFirst PRE_first_tail_x15_r0_body.s858.next = true
kernel_rfl PRE_first_tail_x15_r0_body.zscn88 : PRE_first_tail_x15_r0_body.s860.next = PRE_first_tail_x15_r0_body.s858.next + PRE_first_tail_x15_r0_body.pl88.length
kernel_rfl PRE_first_tail_x15_r0_body.zsmn88 : PRE_first_tail_x15_r0_body.s859.next = 2744125
kernel_rfl PRE_first_tail_x15_r0_body.zgrow88 : Nat.ble PRE_first_tail_x15_r0_body.s860.next PRE_first_tail_x15_r0_body.s859.next = true
-- the tables
kernel_rfl PRE_first_tail_x15_r0_body.zfresh88 : PRE_first_tail_x15_r0_body.S858.tab.all (fun e => PRE_first_tail_x15_r0_body.cws88.all fun v => e.noVar v) = true
kernel_rfl PRE_first_tail_x15_r0_body.zcnd88 : nodupT PRE_first_tail_x15_r0_body.cws88 PTrie.nil = true
kernel_rfl PRE_first_tail_x15_r0_body.znrHi88 : PRE_first_tail_x15_r0_body.nr88.all (fun r => Nat.blt r PRE_first_tail_x15_r0_body.S859.tab.length) = true
-- the frames: every framed address below the call's counter; the kept arrays the chain start's, extended in the merged state
kernel_rfl PRE_first_tail_x15_r0_body.zfrlt88 : [2665, 2673467, 2673472, 2673473].all (fun a => Nat.blt a PRE_first_tail_x15_r0_body.s858.next) = true
kernel_rfl PRE_first_tail_x15_r0_body.zg88_2665 : PRE_first_tail_x15_r0_body.s860.heap.get 2665 = some (.obj (objOf PRE_first_tail_x15_r0_body.s860 2665))
kernel_rfl PRE_first_tail_x15_r0_body.zk88_2665 : (objOf PRE_first_tail_x15_r0_body.s860 2665).kind = .array (arrOf PRE_first_tail_x15_r0_body.s0 2665)
kernel_rfl PRE_first_tail_x15_r0_body.zm88_2665 : PRE_first_tail_x15_r0_body.s859.heap.get 2665 = some (.obj { PRE_first_tail_x15_r0_body.kappa88.obj (objOf PRE_first_tail_x15_r0_body.s860 2665) with
  kind := .array (arrOf PRE_first_tail_x15_r0_body.s0 2665 ++ (arrOf PRE_first_tail_x15_r0_body.s859 2665).drop (arrOf PRE_first_tail_x15_r0_body.s0 2665).length) })
kernel_rfl PRE_first_tail_x15_r0_body.zg88_2673467 : PRE_first_tail_x15_r0_body.s860.heap.get 2673467 = some (.obj (objOf PRE_first_tail_x15_r0_body.s860 2673467))
kernel_rfl PRE_first_tail_x15_r0_body.zk88_2673467 : (objOf PRE_first_tail_x15_r0_body.s860 2673467).kind = .array (arrOf PRE_first_tail_x15_r0_body.s0 2673467)
kernel_rfl PRE_first_tail_x15_r0_body.zm88_2673467 : PRE_first_tail_x15_r0_body.s859.heap.get 2673467 = some (.obj { PRE_first_tail_x15_r0_body.kappa88.obj (objOf PRE_first_tail_x15_r0_body.s860 2673467) with
  kind := .array (arrOf PRE_first_tail_x15_r0_body.s0 2673467 ++ (arrOf PRE_first_tail_x15_r0_body.s859 2673467).drop (arrOf PRE_first_tail_x15_r0_body.s0 2673467).length) })
kernel_rfl PRE_first_tail_x15_r0_body.zw88_4910 : (PRE_first_tail_x15_r0_body.s860.heap.get 4910).isSome = true
kernel_rfl PRE_first_tail_x15_r0_body.zw88_2673472 : (PRE_first_tail_x15_r0_body.s860.heap.get 2673472).isSome = true
kernel_rfl PRE_first_tail_x15_r0_body.zw88_2673473 : (PRE_first_tail_x15_r0_body.s860.heap.get 2673473).isSome = true
-- the heap: the changed list in range, holding the stage's written and fresh addresses; the canonical side's image
kernel_rfl PRE_first_tail_x15_r0_body.zclbd88 : PRE_first_tail_x15_r0_body.cl88.all (fun b => Nat.blt (b / 4096) (4 ^ 31)) = true
kernel_rfl PRE_first_tail_x15_r0_body.zwr88 : PRE_first_tail_x15_r0_body.st88.wr.all (fun b => !Nat.blt b PRE_first_tail_x15_r0_body.s858.next || PRE_first_tail_x15_r0_body.cl88.contains b) = true
def PRE_first_tail_x15_r0_body.zl88 : List Nat := PRE_first_tail_x15_r0_body.cl88.filter fun a => !(List.contains [2665, 2673467] a)
kernel_rfl PRE_first_tail_x15_r0_body.zimgE88 : PRE_first_tail_x15_r0_body.zl88.map (fun a => PRE_first_tail_x15_r0_body.s859.heap.get (PRE_first_tail_x15_r0_body.kappa88.a a)) = PRE_first_tail_x15_r0_body.zl88.map (fun a => (PRE_first_tail_x15_r0_body.s860.heap.get a).map PRE_first_tail_x15_r0_body.kappa88.hobj)
theorem PRE_first_tail_x15_r0_body.zimg88 : HeapImg PRE_first_tail_x15_r0_body.kappa88 PRE_first_tail_x15_r0_body.s860 PRE_first_tail_x15_r0_body.s859 PRE_first_tail_x15_r0_body.zl88 := PRE_first_tail_x15_r0_body.zimgE88
-- the roots and their supports
kernel_rfl PRE_first_tail_x15_r0_body.zctl88 : PRE_first_tail_x15_r0_body.s859.ctl = PRE_first_tail_x15_r0_body.kappa88.ctl PRE_first_tail_x15_r0_body.s860.ctl
kernel_rfl PRE_first_tail_x15_r0_body.zstack88 : PRE_first_tail_x15_r0_body.s859.stack = PRE_first_tail_x15_r0_body.s860.stack.map PRE_first_tail_x15_r0_body.kappa88.frame
kernel_rfl PRE_first_tail_x15_r0_body.zjobs88 : PRE_first_tail_x15_r0_body.s859.jobs = PRE_first_tail_x15_r0_body.s860.jobs.map PRE_first_tail_x15_r0_body.kappa88.job
kernel_rfl PRE_first_tail_x15_r0_body.zstores88 : PRE_first_tail_x15_r0_body.s859.stores = PRE_first_tail_x15_r0_body.kappa88.stores PRE_first_tail_x15_r0_body.s860.stores
kernel_rfl PRE_first_tail_x15_r0_body.zroots88 : checkRootsSupp PRE_first_tail_x15_r0_body.s860 3842 = true
kernel_rfl PRE_first_tail_x15_r0_body.znC88 : PRE_first_tail_x15_r0_body.S858.tab.length + PRE_first_tail_x15_r0_body.cws88.length = 3842
-- the map as `Conv.compact_shift` states it (the call's counters for the literals)
kernel_rfl PRE_first_tail_x15_r0_body.zkap88 : PRE_first_tail_x15_r0_body.kappa88 = Conv.Map.compact PRE_first_tail_x15_r0_body.s858.next 2744125 PRE_first_tail_x15_r0_body.S858.tab.length PRE_first_tail_x15_r0_body.pl88 (PRE_first_tail_x15_r0_body.nr88.map NumV.ref) PRE_first_tail_x15_r0_body.kd88.big
  PRE_first_tail_x15_r0_body.kd88.region PRE_first_tail_x15_r0_body.kd88.nodeF
-- the bridge inactive at the canonical state (`Conv.FullShiftQ.toX`; the merged state's bridge is the canonical's: cbridge)
theorem PRE_first_tail_x15_r0_body.zbin88 : (Host.Ts.Sim.Full.bridgeOf PRE_first_tail_x15_r0_body.s860.ffi).active = false := (Host.Load.Boot.replay_active Host.Load.Run.Prompt.P.oblog2818)
-- the JS bookkeeping's step (`Conv.JClean.step` over the changed list) and the canonical roots' bigint freedom
kernel_rfl PRE_first_tail_x15_r0_body.zjc88 : Conv.jcleanListB (⟨19941, 17040, 2744123, 3842⟩ : Conv.Cnt) PRE_first_tail_x15_r0_body.s860 PRE_first_tail_x15_r0_body.cl88 = true
kernel_rfl PRE_first_tail_x15_r0_body.zrootsB88 : noBigRootsP (fun i => !Conv.oldBigB (⟨19941, 17040, 2744123, 3842⟩ : Conv.Cnt) i) PRE_first_tail_x15_r0_body.s860.trace PRE_first_tail_x15_r0_body.s860 = true
kernel_rfl PRE_first_tail_x15_r0_body.zhm88 : Nat.ble (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s0.ffi).mlx.nnext 17040 = true
theorem PRE_first_tail_x15_r0_body.cjcl88 (h : Conv.JClean (⟨19941, 17040, 2744123, 3842⟩ : Conv.Cnt) PRE_first_tail_x15_r0_body.s858) : Conv.JClean (⟨19941, 17040, 2744123, 3842⟩ : Conv.Cnt) PRE_first_tail_x15_r0_body.s860 :=
  Conv.JClean.step h (Conv.Cnt.le_of_leB PRE_first_tail_x15_r0_body.cle88)
    (Conv.heap_off_setAll PRE_first_tail_x15_r0_body.cheap88 fun a ha => Nat.blt_eq.mp (List.all_eq_true.mp PRE_first_tail_x15_r0_body.zclbd88 a ha)) PRE_first_tail_x15_r0_body.zjc88

end Host.Load.Run.Tpl
