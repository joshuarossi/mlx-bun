import host.sim.template.a4pre_first_tail_x15_r0_body.SiteS184
import host.sim.template.a4pre_first_tail_x15_r0_body.SiteK184
import host.sim.template.a4pre_first_tail_x15_r0_body.SiteF184
import host.sim.conv.CompactShift
import host.sim.template.Check
import host.sim.BigFreeP
import host.sim.template.CallGen
set_option Elab.async false
namespace Host.Load.Run.Tpl
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
open Host.Ts Host.Ts.Sim Host.Ts.Sim.Template

/-! The compaction's state shift at call site 184 of chain `PRE_first_tail_x15_r0_body` (`Conv.compact_shift`): the call `PRE_first_tail_x15_r0_body.s1623`, the merged
state `PRE_first_tail_x15_r0_body.s1624`, the canonical state `PRE_first_tail_x15_r0_body.s1625`; its frames [2665,2673467,2673472,2673473] (kept arrays [2665,2673467]). -/

-- the map's places and counters
kernel_rfl PRE_first_tail_x15_r0_body.zpl184 : PRE_first_tail_x15_r0_body.pl184.all (Nat.ble PRE_first_tail_x15_r0_body.s1623.next) = true
kernel_rfl PRE_first_tail_x15_r0_body.zplnd184 : nodupT PRE_first_tail_x15_r0_body.pl184 PTrie.nil = true
kernel_rfl PRE_first_tail_x15_r0_body.zn1184 : Nat.ble PRE_first_tail_x15_r0_body.s1623.next 2819485 = true
kernel_rfl PRE_first_tail_x15_r0_body.zfirst184 : Nat.ble aFirst PRE_first_tail_x15_r0_body.s1623.next = true
kernel_rfl PRE_first_tail_x15_r0_body.zscn184 : PRE_first_tail_x15_r0_body.s1625.next = PRE_first_tail_x15_r0_body.s1623.next + PRE_first_tail_x15_r0_body.pl184.length
kernel_rfl PRE_first_tail_x15_r0_body.zsmn184 : PRE_first_tail_x15_r0_body.s1624.next = 2819485
kernel_rfl PRE_first_tail_x15_r0_body.zgrow184 : Nat.ble PRE_first_tail_x15_r0_body.s1625.next PRE_first_tail_x15_r0_body.s1624.next = true
-- the tables
kernel_rfl PRE_first_tail_x15_r0_body.zfresh184 : PRE_first_tail_x15_r0_body.S1623.tab.all (fun e => PRE_first_tail_x15_r0_body.cws184.all fun v => e.noVar v) = true
kernel_rfl PRE_first_tail_x15_r0_body.zcnd184 : nodupT PRE_first_tail_x15_r0_body.cws184 PTrie.nil = true
kernel_rfl PRE_first_tail_x15_r0_body.znrHi184 : PRE_first_tail_x15_r0_body.nr184.all (fun r => Nat.blt r PRE_first_tail_x15_r0_body.S1624.tab.length) = true
-- the frames: every framed address below the call's counter; the kept arrays the chain start's, extended in the merged state
kernel_rfl PRE_first_tail_x15_r0_body.zfrlt184 : [2665, 2673467, 2673472, 2673473].all (fun a => Nat.blt a PRE_first_tail_x15_r0_body.s1623.next) = true
kernel_rfl PRE_first_tail_x15_r0_body.zg184_2665 : PRE_first_tail_x15_r0_body.s1625.heap.get 2665 = some (.obj (objOf PRE_first_tail_x15_r0_body.s1625 2665))
kernel_rfl PRE_first_tail_x15_r0_body.zk184_2665 : (objOf PRE_first_tail_x15_r0_body.s1625 2665).kind = .array (arrOf PRE_first_tail_x15_r0_body.s0 2665)
kernel_rfl PRE_first_tail_x15_r0_body.zm184_2665 : PRE_first_tail_x15_r0_body.s1624.heap.get 2665 = some (.obj { PRE_first_tail_x15_r0_body.kappa184.obj (objOf PRE_first_tail_x15_r0_body.s1625 2665) with
  kind := .array (arrOf PRE_first_tail_x15_r0_body.s0 2665 ++ (arrOf PRE_first_tail_x15_r0_body.s1624 2665).drop (arrOf PRE_first_tail_x15_r0_body.s0 2665).length) })
kernel_rfl PRE_first_tail_x15_r0_body.zg184_2673467 : PRE_first_tail_x15_r0_body.s1625.heap.get 2673467 = some (.obj (objOf PRE_first_tail_x15_r0_body.s1625 2673467))
kernel_rfl PRE_first_tail_x15_r0_body.zk184_2673467 : (objOf PRE_first_tail_x15_r0_body.s1625 2673467).kind = .array (arrOf PRE_first_tail_x15_r0_body.s0 2673467)
kernel_rfl PRE_first_tail_x15_r0_body.zm184_2673467 : PRE_first_tail_x15_r0_body.s1624.heap.get 2673467 = some (.obj { PRE_first_tail_x15_r0_body.kappa184.obj (objOf PRE_first_tail_x15_r0_body.s1625 2673467) with
  kind := .array (arrOf PRE_first_tail_x15_r0_body.s0 2673467 ++ (arrOf PRE_first_tail_x15_r0_body.s1624 2673467).drop (arrOf PRE_first_tail_x15_r0_body.s0 2673467).length) })
kernel_rfl PRE_first_tail_x15_r0_body.zw184_4910 : (PRE_first_tail_x15_r0_body.s1625.heap.get 4910).isSome = true
kernel_rfl PRE_first_tail_x15_r0_body.zw184_2673472 : (PRE_first_tail_x15_r0_body.s1625.heap.get 2673472).isSome = true
kernel_rfl PRE_first_tail_x15_r0_body.zw184_2673473 : (PRE_first_tail_x15_r0_body.s1625.heap.get 2673473).isSome = true
-- the heap: the changed list in range, holding the stage's written and fresh addresses; the canonical side's image
kernel_rfl PRE_first_tail_x15_r0_body.zclbd184 : PRE_first_tail_x15_r0_body.cl184.all (fun b => Nat.blt (b / 4096) (4 ^ 31)) = true
kernel_rfl PRE_first_tail_x15_r0_body.zwr184 : PRE_first_tail_x15_r0_body.st184.wr.all (fun b => !Nat.blt b PRE_first_tail_x15_r0_body.s1623.next || PRE_first_tail_x15_r0_body.cl184.contains b) = true
def PRE_first_tail_x15_r0_body.zl184 : List Nat := PRE_first_tail_x15_r0_body.cl184.filter fun a => !(List.contains [2665, 2673467] a)
kernel_rfl PRE_first_tail_x15_r0_body.zimgE184 : PRE_first_tail_x15_r0_body.zl184.map (fun a => PRE_first_tail_x15_r0_body.s1624.heap.get (PRE_first_tail_x15_r0_body.kappa184.a a)) = PRE_first_tail_x15_r0_body.zl184.map (fun a => (PRE_first_tail_x15_r0_body.s1625.heap.get a).map PRE_first_tail_x15_r0_body.kappa184.hobj)
theorem PRE_first_tail_x15_r0_body.zimg184 : HeapImg PRE_first_tail_x15_r0_body.kappa184 PRE_first_tail_x15_r0_body.s1625 PRE_first_tail_x15_r0_body.s1624 PRE_first_tail_x15_r0_body.zl184 := PRE_first_tail_x15_r0_body.zimgE184
-- the roots and their supports
kernel_rfl PRE_first_tail_x15_r0_body.zctl184 : PRE_first_tail_x15_r0_body.s1624.ctl = PRE_first_tail_x15_r0_body.kappa184.ctl PRE_first_tail_x15_r0_body.s1625.ctl
kernel_rfl PRE_first_tail_x15_r0_body.zstack184 : PRE_first_tail_x15_r0_body.s1624.stack = PRE_first_tail_x15_r0_body.s1625.stack.map PRE_first_tail_x15_r0_body.kappa184.frame
kernel_rfl PRE_first_tail_x15_r0_body.zjobs184 : PRE_first_tail_x15_r0_body.s1624.jobs = PRE_first_tail_x15_r0_body.s1625.jobs.map PRE_first_tail_x15_r0_body.kappa184.job
kernel_rfl PRE_first_tail_x15_r0_body.zstores184 : PRE_first_tail_x15_r0_body.s1624.stores = PRE_first_tail_x15_r0_body.kappa184.stores PRE_first_tail_x15_r0_body.s1625.stores
kernel_rfl PRE_first_tail_x15_r0_body.zroots184 : checkRootsSupp PRE_first_tail_x15_r0_body.s1625 7946 = true
kernel_rfl PRE_first_tail_x15_r0_body.znC184 : PRE_first_tail_x15_r0_body.S1623.tab.length + PRE_first_tail_x15_r0_body.cws184.length = 7946
-- the map as `Conv.compact_shift` states it (the call's counters for the literals)
kernel_rfl PRE_first_tail_x15_r0_body.zkap184 : PRE_first_tail_x15_r0_body.kappa184 = Conv.Map.compact PRE_first_tail_x15_r0_body.s1623.next 2819485 PRE_first_tail_x15_r0_body.S1623.tab.length PRE_first_tail_x15_r0_body.pl184 (PRE_first_tail_x15_r0_body.nr184.map NumV.ref) PRE_first_tail_x15_r0_body.kd184.big
  PRE_first_tail_x15_r0_body.kd184.region PRE_first_tail_x15_r0_body.kd184.nodeF
-- the bridge inactive at the canonical state (`Conv.FullShiftQ.toX`; the merged state's bridge is the canonical's: cbridge)
theorem PRE_first_tail_x15_r0_body.zbin184 : (Host.Ts.Sim.Full.bridgeOf PRE_first_tail_x15_r0_body.s1625.ffi).active = false := (Host.Load.Boot.replay_active Host.Load.Run.Prompt.P.oblog2818)
-- the JS bookkeeping's step (`Conv.JClean.step` over the changed list) and the canonical roots' bigint freedom
kernel_rfl PRE_first_tail_x15_r0_body.zjc184 : Conv.jcleanListB (⟨21829, 18936, 2819483, 7946⟩ : Conv.Cnt) PRE_first_tail_x15_r0_body.s1625 PRE_first_tail_x15_r0_body.cl184 = true
kernel_rfl PRE_first_tail_x15_r0_body.zroots2184 : noBigRootsP (fun i => !Conv.oldBigB (⟨21829, 18936, 2819483, 7946⟩ : Conv.Cnt) i) PRE_first_tail_x15_r0_body.s1625.trace PRE_first_tail_x15_r0_body.s1625 = true
kernel_rfl PRE_first_tail_x15_r0_body.zhm184 : Nat.ble (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s0.ffi).mlx.nnext 18936 = true
theorem PRE_first_tail_x15_r0_body.cjcl184 (h : Conv.JClean (⟨21829, 18936, 2819483, 7946⟩ : Conv.Cnt) PRE_first_tail_x15_r0_body.s1623) : Conv.JClean (⟨21829, 18936, 2819483, 7946⟩ : Conv.Cnt) PRE_first_tail_x15_r0_body.s1625 :=
  Conv.JClean.step h (Conv.Cnt.le_of_leB PRE_first_tail_x15_r0_body.cle184)
    (Conv.heap_off_setAll PRE_first_tail_x15_r0_body.cheap184 fun a ha => Nat.blt_eq.mp (List.all_eq_true.mp PRE_first_tail_x15_r0_body.zclbd184 a ha)) PRE_first_tail_x15_r0_body.zjc184

end Host.Load.Run.Tpl
