import host.sim.template.a4pre_first_tail_x15_r0_body.SiteS6
import host.sim.template.a4pre_first_tail_x15_r0_body.SiteK6
import host.sim.template.a4pre_first_tail_x15_r0_body.SiteF6
import host.sim.conv.CompactShift
import host.sim.template.Check
import host.sim.BigFreeP
import host.sim.template.CallGen
set_option Elab.async false
namespace Host.Load.Run.Tpl
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
open Host.Ts Host.Ts.Sim Host.Ts.Sim.Template

/-! The compaction's state shift at call site 6 of chain `PRE_first_tail_x15_r0_body` (`Conv.compact_shift`): the call `PRE_first_tail_x15_r0_body.s74`, the merged
state `PRE_first_tail_x15_r0_body.s75`, the canonical state `PRE_first_tail_x15_r0_body.s76`; its frames [2665,2673467,2673472,2673473] (kept arrays [2665,2673467]). -/

-- the map's places and counters
kernel_rfl PRE_first_tail_x15_r0_body.zpl6 : PRE_first_tail_x15_r0_body.pl6.all (Nat.ble PRE_first_tail_x15_r0_body.s74.next) = true
kernel_rfl PRE_first_tail_x15_r0_body.zplnd6 : nodupT PRE_first_tail_x15_r0_body.pl6 PTrie.nil = true
kernel_rfl PRE_first_tail_x15_r0_body.zn16 : Nat.ble PRE_first_tail_x15_r0_body.s74.next 2681128 = true
kernel_rfl PRE_first_tail_x15_r0_body.zfirst6 : Nat.ble aFirst PRE_first_tail_x15_r0_body.s74.next = true
kernel_rfl PRE_first_tail_x15_r0_body.zscn6 : PRE_first_tail_x15_r0_body.s76.next = PRE_first_tail_x15_r0_body.s74.next + PRE_first_tail_x15_r0_body.pl6.length
kernel_rfl PRE_first_tail_x15_r0_body.zsmn6 : PRE_first_tail_x15_r0_body.s75.next = 2681128
kernel_rfl PRE_first_tail_x15_r0_body.zgrow6 : Nat.ble PRE_first_tail_x15_r0_body.s76.next PRE_first_tail_x15_r0_body.s75.next = true
-- the tables
kernel_rfl PRE_first_tail_x15_r0_body.zfresh6 : PRE_first_tail_x15_r0_body.S74.tab.all (fun e => PRE_first_tail_x15_r0_body.cws6.all fun v => e.noVar v) = true
kernel_rfl PRE_first_tail_x15_r0_body.zcnd6 : nodupT PRE_first_tail_x15_r0_body.cws6 PTrie.nil = true
kernel_rfl PRE_first_tail_x15_r0_body.znrHi6 : PRE_first_tail_x15_r0_body.nr6.all (fun r => Nat.blt r PRE_first_tail_x15_r0_body.S75.tab.length) = true
-- the frames: every framed address below the call's counter; the kept arrays the chain start's, extended in the merged state
kernel_rfl PRE_first_tail_x15_r0_body.zfrlt6 : [2665, 2673467, 2673472, 2673473].all (fun a => Nat.blt a PRE_first_tail_x15_r0_body.s74.next) = true
kernel_rfl PRE_first_tail_x15_r0_body.zg6_2665 : PRE_first_tail_x15_r0_body.s76.heap.get 2665 = some (.obj (objOf PRE_first_tail_x15_r0_body.s76 2665))
kernel_rfl PRE_first_tail_x15_r0_body.zk6_2665 : (objOf PRE_first_tail_x15_r0_body.s76 2665).kind = .array (arrOf PRE_first_tail_x15_r0_body.s0 2665)
kernel_rfl PRE_first_tail_x15_r0_body.zm6_2665 : PRE_first_tail_x15_r0_body.s75.heap.get 2665 = some (.obj { PRE_first_tail_x15_r0_body.kappa6.obj (objOf PRE_first_tail_x15_r0_body.s76 2665) with
  kind := .array (arrOf PRE_first_tail_x15_r0_body.s0 2665 ++ (arrOf PRE_first_tail_x15_r0_body.s75 2665).drop (arrOf PRE_first_tail_x15_r0_body.s0 2665).length) })
kernel_rfl PRE_first_tail_x15_r0_body.zg6_2673467 : PRE_first_tail_x15_r0_body.s76.heap.get 2673467 = some (.obj (objOf PRE_first_tail_x15_r0_body.s76 2673467))
kernel_rfl PRE_first_tail_x15_r0_body.zk6_2673467 : (objOf PRE_first_tail_x15_r0_body.s76 2673467).kind = .array (arrOf PRE_first_tail_x15_r0_body.s0 2673467)
kernel_rfl PRE_first_tail_x15_r0_body.zm6_2673467 : PRE_first_tail_x15_r0_body.s75.heap.get 2673467 = some (.obj { PRE_first_tail_x15_r0_body.kappa6.obj (objOf PRE_first_tail_x15_r0_body.s76 2673467) with
  kind := .array (arrOf PRE_first_tail_x15_r0_body.s0 2673467 ++ (arrOf PRE_first_tail_x15_r0_body.s75 2673467).drop (arrOf PRE_first_tail_x15_r0_body.s0 2673467).length) })
kernel_rfl PRE_first_tail_x15_r0_body.zw6_4910 : (PRE_first_tail_x15_r0_body.s76.heap.get 4910).isSome = true
kernel_rfl PRE_first_tail_x15_r0_body.zw6_2673472 : (PRE_first_tail_x15_r0_body.s76.heap.get 2673472).isSome = true
kernel_rfl PRE_first_tail_x15_r0_body.zw6_2673473 : (PRE_first_tail_x15_r0_body.s76.heap.get 2673473).isSome = true
-- the heap: the changed list in range, holding the stage's written and fresh addresses; the canonical side's image
kernel_rfl PRE_first_tail_x15_r0_body.zclbd6 : PRE_first_tail_x15_r0_body.cl6.all (fun b => Nat.blt (b / 4096) (4 ^ 31)) = true
kernel_rfl PRE_first_tail_x15_r0_body.zwr6 : PRE_first_tail_x15_r0_body.st6.wr.all (fun b => !Nat.blt b PRE_first_tail_x15_r0_body.s74.next || PRE_first_tail_x15_r0_body.cl6.contains b) = true
def PRE_first_tail_x15_r0_body.zl6 : List Nat := PRE_first_tail_x15_r0_body.cl6.filter fun a => !(List.contains [2665, 2673467] a)
kernel_rfl PRE_first_tail_x15_r0_body.zimgE6 : PRE_first_tail_x15_r0_body.zl6.map (fun a => PRE_first_tail_x15_r0_body.s75.heap.get (PRE_first_tail_x15_r0_body.kappa6.a a)) = PRE_first_tail_x15_r0_body.zl6.map (fun a => (PRE_first_tail_x15_r0_body.s76.heap.get a).map PRE_first_tail_x15_r0_body.kappa6.hobj)
theorem PRE_first_tail_x15_r0_body.zimg6 : HeapImg PRE_first_tail_x15_r0_body.kappa6 PRE_first_tail_x15_r0_body.s76 PRE_first_tail_x15_r0_body.s75 PRE_first_tail_x15_r0_body.zl6 := PRE_first_tail_x15_r0_body.zimgE6
-- the roots and their supports
kernel_rfl PRE_first_tail_x15_r0_body.zctl6 : PRE_first_tail_x15_r0_body.s75.ctl = PRE_first_tail_x15_r0_body.kappa6.ctl PRE_first_tail_x15_r0_body.s76.ctl
kernel_rfl PRE_first_tail_x15_r0_body.zstack6 : PRE_first_tail_x15_r0_body.s75.stack = PRE_first_tail_x15_r0_body.s76.stack.map PRE_first_tail_x15_r0_body.kappa6.frame
kernel_rfl PRE_first_tail_x15_r0_body.zjobs6 : PRE_first_tail_x15_r0_body.s75.jobs = PRE_first_tail_x15_r0_body.s76.jobs.map PRE_first_tail_x15_r0_body.kappa6.job
kernel_rfl PRE_first_tail_x15_r0_body.zstores6 : PRE_first_tail_x15_r0_body.s75.stores = PRE_first_tail_x15_r0_body.kappa6.stores PRE_first_tail_x15_r0_body.s76.stores
kernel_rfl PRE_first_tail_x15_r0_body.zroots6 : checkRootsSupp PRE_first_tail_x15_r0_body.s76 359 = true
kernel_rfl PRE_first_tail_x15_r0_body.znC6 : PRE_first_tail_x15_r0_body.S74.tab.length + PRE_first_tail_x15_r0_body.cws6.length = 359
-- the map as `Conv.compact_shift` states it (the call's counters for the literals)
kernel_rfl PRE_first_tail_x15_r0_body.zkap6 : PRE_first_tail_x15_r0_body.kappa6 = Conv.Map.compact PRE_first_tail_x15_r0_body.s74.next 2681128 PRE_first_tail_x15_r0_body.S74.tab.length PRE_first_tail_x15_r0_body.pl6 (PRE_first_tail_x15_r0_body.nr6.map NumV.ref) PRE_first_tail_x15_r0_body.kd6.big
  PRE_first_tail_x15_r0_body.kd6.region PRE_first_tail_x15_r0_body.kd6.nodeF
-- the bridge inactive at the canonical state (`Conv.FullShiftQ.toX`; the merged state's bridge is the canonical's: cbridge)
theorem PRE_first_tail_x15_r0_body.zbin6 : (Host.Ts.Sim.Full.bridgeOf PRE_first_tail_x15_r0_body.s76.ffi).active = false := (Host.Load.Boot.replay_active Host.Load.Run.Prompt.P.oblog2818)
-- the JS bookkeeping's step (`Conv.JClean.step` over the changed list) and the canonical roots' bigint freedom
kernel_rfl PRE_first_tail_x15_r0_body.zjc6 : Conv.jcleanListB (⟨18333, 15431, 2679979, 359⟩ : Conv.Cnt) PRE_first_tail_x15_r0_body.s76 PRE_first_tail_x15_r0_body.cl6 = true
kernel_rfl PRE_first_tail_x15_r0_body.zrootsB6 : noBigRootsP (fun i => !Conv.oldBigB (⟨18333, 15431, 2679979, 359⟩ : Conv.Cnt) i) PRE_first_tail_x15_r0_body.s76.trace PRE_first_tail_x15_r0_body.s76 = true
kernel_rfl PRE_first_tail_x15_r0_body.zhm6 : Nat.ble (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s0.ffi).mlx.nnext 15404 = true
theorem PRE_first_tail_x15_r0_body.cjcl6 (h : Conv.JClean (⟨18330, 15404, 2679973, 341⟩ : Conv.Cnt) PRE_first_tail_x15_r0_body.s74) : Conv.JClean (⟨18333, 15431, 2679979, 359⟩ : Conv.Cnt) PRE_first_tail_x15_r0_body.s76 :=
  Conv.JClean.step h (Conv.Cnt.le_of_leB PRE_first_tail_x15_r0_body.cle6)
    (Conv.heap_off_setAll PRE_first_tail_x15_r0_body.cheap6 fun a ha => Nat.blt_eq.mp (List.all_eq_true.mp PRE_first_tail_x15_r0_body.zclbd6 a ha)) PRE_first_tail_x15_r0_body.zjc6

end Host.Load.Run.Tpl
