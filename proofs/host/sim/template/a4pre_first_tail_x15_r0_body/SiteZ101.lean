import host.sim.template.a4pre_first_tail_x15_r0_body.SiteS101
import host.sim.template.a4pre_first_tail_x15_r0_body.SiteK101
import host.sim.template.a4pre_first_tail_x15_r0_body.SiteF101
import host.sim.conv.CompactShift
import host.sim.template.Check
import host.sim.BigFreeP
import host.sim.template.CallGen
set_option Elab.async false
namespace Host.Load.Run.Tpl
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
open Host.Ts Host.Ts.Sim Host.Ts.Sim.Template

/-! The compaction's state shift at call site 101 of chain `PRE_first_tail_x15_r0_body` (`Conv.compact_shift`): the call `PRE_first_tail_x15_r0_body.s892`, the merged
state `PRE_first_tail_x15_r0_body.s893`, the canonical state `PRE_first_tail_x15_r0_body.s894`; its frames [2665,2673467,2673472,2673473] (kept arrays [2665,2673467]). -/

-- the map's places and counters
kernel_rfl PRE_first_tail_x15_r0_body.zpl101 : PRE_first_tail_x15_r0_body.pl101.all (Nat.ble PRE_first_tail_x15_r0_body.s892.next) = true
kernel_rfl PRE_first_tail_x15_r0_body.zplnd101 : nodupT PRE_first_tail_x15_r0_body.pl101 PTrie.nil = true
kernel_rfl PRE_first_tail_x15_r0_body.zn1101 : Nat.ble PRE_first_tail_x15_r0_body.s892.next 2753855 = true
kernel_rfl PRE_first_tail_x15_r0_body.zfirst101 : Nat.ble aFirst PRE_first_tail_x15_r0_body.s892.next = true
kernel_rfl PRE_first_tail_x15_r0_body.zscn101 : PRE_first_tail_x15_r0_body.s894.next = PRE_first_tail_x15_r0_body.s892.next + PRE_first_tail_x15_r0_body.pl101.length
kernel_rfl PRE_first_tail_x15_r0_body.zsmn101 : PRE_first_tail_x15_r0_body.s893.next = 2753855
kernel_rfl PRE_first_tail_x15_r0_body.zgrow101 : Nat.ble PRE_first_tail_x15_r0_body.s894.next PRE_first_tail_x15_r0_body.s893.next = true
-- the tables
kernel_rfl PRE_first_tail_x15_r0_body.zfresh101 : PRE_first_tail_x15_r0_body.S892.tab.all (fun e => PRE_first_tail_x15_r0_body.cws101.all fun v => e.noVar v) = true
kernel_rfl PRE_first_tail_x15_r0_body.zcnd101 : nodupT PRE_first_tail_x15_r0_body.cws101 PTrie.nil = true
kernel_rfl PRE_first_tail_x15_r0_body.znrHi101 : PRE_first_tail_x15_r0_body.nr101.all (fun r => Nat.blt r PRE_first_tail_x15_r0_body.S893.tab.length) = true
-- the frames: every framed address below the call's counter; the kept arrays the chain start's, extended in the merged state
kernel_rfl PRE_first_tail_x15_r0_body.zfrlt101 : [2665, 2673467, 2673472, 2673473].all (fun a => Nat.blt a PRE_first_tail_x15_r0_body.s892.next) = true
kernel_rfl PRE_first_tail_x15_r0_body.zg101_2665 : PRE_first_tail_x15_r0_body.s894.heap.get 2665 = some (.obj (objOf PRE_first_tail_x15_r0_body.s894 2665))
kernel_rfl PRE_first_tail_x15_r0_body.zk101_2665 : (objOf PRE_first_tail_x15_r0_body.s894 2665).kind = .array (arrOf PRE_first_tail_x15_r0_body.s0 2665)
kernel_rfl PRE_first_tail_x15_r0_body.zm101_2665 : PRE_first_tail_x15_r0_body.s893.heap.get 2665 = some (.obj { PRE_first_tail_x15_r0_body.kappa101.obj (objOf PRE_first_tail_x15_r0_body.s894 2665) with
  kind := .array (arrOf PRE_first_tail_x15_r0_body.s0 2665 ++ (arrOf PRE_first_tail_x15_r0_body.s893 2665).drop (arrOf PRE_first_tail_x15_r0_body.s0 2665).length) })
kernel_rfl PRE_first_tail_x15_r0_body.zg101_2673467 : PRE_first_tail_x15_r0_body.s894.heap.get 2673467 = some (.obj (objOf PRE_first_tail_x15_r0_body.s894 2673467))
kernel_rfl PRE_first_tail_x15_r0_body.zk101_2673467 : (objOf PRE_first_tail_x15_r0_body.s894 2673467).kind = .array (arrOf PRE_first_tail_x15_r0_body.s0 2673467)
kernel_rfl PRE_first_tail_x15_r0_body.zm101_2673467 : PRE_first_tail_x15_r0_body.s893.heap.get 2673467 = some (.obj { PRE_first_tail_x15_r0_body.kappa101.obj (objOf PRE_first_tail_x15_r0_body.s894 2673467) with
  kind := .array (arrOf PRE_first_tail_x15_r0_body.s0 2673467 ++ (arrOf PRE_first_tail_x15_r0_body.s893 2673467).drop (arrOf PRE_first_tail_x15_r0_body.s0 2673467).length) })
kernel_rfl PRE_first_tail_x15_r0_body.zw101_4910 : (PRE_first_tail_x15_r0_body.s894.heap.get 4910).isSome = true
kernel_rfl PRE_first_tail_x15_r0_body.zw101_2673472 : (PRE_first_tail_x15_r0_body.s894.heap.get 2673472).isSome = true
kernel_rfl PRE_first_tail_x15_r0_body.zw101_2673473 : (PRE_first_tail_x15_r0_body.s894.heap.get 2673473).isSome = true
-- the heap: the changed list in range, holding the stage's written and fresh addresses; the canonical side's image
kernel_rfl PRE_first_tail_x15_r0_body.zclbd101 : PRE_first_tail_x15_r0_body.cl101.all (fun b => Nat.blt (b / 4096) (4 ^ 31)) = true
kernel_rfl PRE_first_tail_x15_r0_body.zwr101 : PRE_first_tail_x15_r0_body.st101.wr.all (fun b => !Nat.blt b PRE_first_tail_x15_r0_body.s892.next || PRE_first_tail_x15_r0_body.cl101.contains b) = true
def PRE_first_tail_x15_r0_body.zl101 : List Nat := PRE_first_tail_x15_r0_body.cl101.filter fun a => !(List.contains [2665, 2673467] a)
kernel_rfl PRE_first_tail_x15_r0_body.zimgE101 : PRE_first_tail_x15_r0_body.zl101.map (fun a => PRE_first_tail_x15_r0_body.s893.heap.get (PRE_first_tail_x15_r0_body.kappa101.a a)) = PRE_first_tail_x15_r0_body.zl101.map (fun a => (PRE_first_tail_x15_r0_body.s894.heap.get a).map PRE_first_tail_x15_r0_body.kappa101.hobj)
theorem PRE_first_tail_x15_r0_body.zimg101 : HeapImg PRE_first_tail_x15_r0_body.kappa101 PRE_first_tail_x15_r0_body.s894 PRE_first_tail_x15_r0_body.s893 PRE_first_tail_x15_r0_body.zl101 := PRE_first_tail_x15_r0_body.zimgE101
-- the roots and their supports
kernel_rfl PRE_first_tail_x15_r0_body.zctl101 : PRE_first_tail_x15_r0_body.s893.ctl = PRE_first_tail_x15_r0_body.kappa101.ctl PRE_first_tail_x15_r0_body.s894.ctl
kernel_rfl PRE_first_tail_x15_r0_body.zstack101 : PRE_first_tail_x15_r0_body.s893.stack = PRE_first_tail_x15_r0_body.s894.stack.map PRE_first_tail_x15_r0_body.kappa101.frame
kernel_rfl PRE_first_tail_x15_r0_body.zjobs101 : PRE_first_tail_x15_r0_body.s893.jobs = PRE_first_tail_x15_r0_body.s894.jobs.map PRE_first_tail_x15_r0_body.kappa101.job
kernel_rfl PRE_first_tail_x15_r0_body.zstores101 : PRE_first_tail_x15_r0_body.s893.stores = PRE_first_tail_x15_r0_body.kappa101.stores PRE_first_tail_x15_r0_body.s894.stores
kernel_rfl PRE_first_tail_x15_r0_body.zroots101 : checkRootsSupp PRE_first_tail_x15_r0_body.s894 4372 = true
kernel_rfl PRE_first_tail_x15_r0_body.znC101 : PRE_first_tail_x15_r0_body.S892.tab.length + PRE_first_tail_x15_r0_body.cws101.length = 4372
-- the map as `Conv.compact_shift` states it (the call's counters for the literals)
kernel_rfl PRE_first_tail_x15_r0_body.zkap101 : PRE_first_tail_x15_r0_body.kappa101 = Conv.Map.compact PRE_first_tail_x15_r0_body.s892.next 2753855 PRE_first_tail_x15_r0_body.S892.tab.length PRE_first_tail_x15_r0_body.pl101 (PRE_first_tail_x15_r0_body.nr101.map NumV.ref) PRE_first_tail_x15_r0_body.kd101.big
  PRE_first_tail_x15_r0_body.kd101.region PRE_first_tail_x15_r0_body.kd101.nodeF
-- the bridge inactive at the canonical state (`Conv.FullShiftQ.toX`; the merged state's bridge is the canonical's: cbridge)
theorem PRE_first_tail_x15_r0_body.zbin101 : (Host.Ts.Sim.Full.bridgeOf PRE_first_tail_x15_r0_body.s894.ffi).active = false := (Host.Load.Boot.replay_active Host.Load.Run.Prompt.P.oblog2818)
-- the JS bookkeeping's step (`Conv.JClean.step` over the changed list) and the canonical roots' bigint freedom
kernel_rfl PRE_first_tail_x15_r0_body.zjc101 : Conv.jcleanListB (⟨20184, 17281, 2753836, 4372⟩ : Conv.Cnt) PRE_first_tail_x15_r0_body.s894 PRE_first_tail_x15_r0_body.cl101 = true
kernel_rfl PRE_first_tail_x15_r0_body.zroots2101 : noBigRootsP (fun i => !Conv.oldBigB (⟨20184, 17281, 2753836, 4372⟩ : Conv.Cnt) i) PRE_first_tail_x15_r0_body.s894.trace PRE_first_tail_x15_r0_body.s894 = true
kernel_rfl PRE_first_tail_x15_r0_body.zhm101 : Nat.ble (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s0.ffi).mlx.nnext 17281 = true
theorem PRE_first_tail_x15_r0_body.cjcl101 (h : Conv.JClean (⟨20184, 17281, 2753835, 4372⟩ : Conv.Cnt) PRE_first_tail_x15_r0_body.s892) : Conv.JClean (⟨20184, 17281, 2753836, 4372⟩ : Conv.Cnt) PRE_first_tail_x15_r0_body.s894 :=
  Conv.JClean.step h (Conv.Cnt.le_of_leB PRE_first_tail_x15_r0_body.cle101)
    (Conv.heap_off_setAll PRE_first_tail_x15_r0_body.cheap101 fun a ha => Nat.blt_eq.mp (List.all_eq_true.mp PRE_first_tail_x15_r0_body.zclbd101 a ha)) PRE_first_tail_x15_r0_body.zjc101

end Host.Load.Run.Tpl
