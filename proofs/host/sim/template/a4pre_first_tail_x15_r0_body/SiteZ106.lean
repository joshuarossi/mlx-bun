import host.sim.template.a4pre_first_tail_x15_r0_body.SiteS106
import host.sim.template.a4pre_first_tail_x15_r0_body.SiteK106
import host.sim.template.a4pre_first_tail_x15_r0_body.SiteF106
import host.sim.conv.CompactShift
import host.sim.template.Check
import host.sim.BigFreeP
import host.sim.template.CallGen
set_option Elab.async false
namespace Host.Load.Run.Tpl
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
open Host.Ts Host.Ts.Sim Host.Ts.Sim.Template

/-! The compaction's state shift at call site 106 of chain `PRE_first_tail_x15_r0_body` (`Conv.compact_shift`): the call `PRE_first_tail_x15_r0_body.s1030`, the merged
state `PRE_first_tail_x15_r0_body.s1031`, the canonical state `PRE_first_tail_x15_r0_body.s1032`; its frames [2665,2673467,2673472,2673473] (kept arrays [2665,2673467]). -/

-- the map's places and counters
kernel_rfl PRE_first_tail_x15_r0_body.zpl106 : PRE_first_tail_x15_r0_body.pl106.all (Nat.ble PRE_first_tail_x15_r0_body.s1030.next) = true
kernel_rfl PRE_first_tail_x15_r0_body.zplnd106 : nodupT PRE_first_tail_x15_r0_body.pl106 PTrie.nil = true
kernel_rfl PRE_first_tail_x15_r0_body.zn1106 : Nat.ble PRE_first_tail_x15_r0_body.s1030.next 2758431 = true
kernel_rfl PRE_first_tail_x15_r0_body.zfirst106 : Nat.ble aFirst PRE_first_tail_x15_r0_body.s1030.next = true
kernel_rfl PRE_first_tail_x15_r0_body.zscn106 : PRE_first_tail_x15_r0_body.s1032.next = PRE_first_tail_x15_r0_body.s1030.next + PRE_first_tail_x15_r0_body.pl106.length
kernel_rfl PRE_first_tail_x15_r0_body.zsmn106 : PRE_first_tail_x15_r0_body.s1031.next = 2758431
kernel_rfl PRE_first_tail_x15_r0_body.zgrow106 : Nat.ble PRE_first_tail_x15_r0_body.s1032.next PRE_first_tail_x15_r0_body.s1031.next = true
-- the tables
kernel_rfl PRE_first_tail_x15_r0_body.zfresh106 : PRE_first_tail_x15_r0_body.S1030.tab.all (fun e => PRE_first_tail_x15_r0_body.cws106.all fun v => e.noVar v) = true
kernel_rfl PRE_first_tail_x15_r0_body.zcnd106 : nodupT PRE_first_tail_x15_r0_body.cws106 PTrie.nil = true
kernel_rfl PRE_first_tail_x15_r0_body.znrHi106 : PRE_first_tail_x15_r0_body.nr106.all (fun r => Nat.blt r PRE_first_tail_x15_r0_body.S1031.tab.length) = true
-- the frames: every framed address below the call's counter; the kept arrays the chain start's, extended in the merged state
kernel_rfl PRE_first_tail_x15_r0_body.zfrlt106 : [2665, 2673467, 2673472, 2673473].all (fun a => Nat.blt a PRE_first_tail_x15_r0_body.s1030.next) = true
kernel_rfl PRE_first_tail_x15_r0_body.zg106_2665 : PRE_first_tail_x15_r0_body.s1032.heap.get 2665 = some (.obj (objOf PRE_first_tail_x15_r0_body.s1032 2665))
kernel_rfl PRE_first_tail_x15_r0_body.zk106_2665 : (objOf PRE_first_tail_x15_r0_body.s1032 2665).kind = .array (arrOf PRE_first_tail_x15_r0_body.s0 2665)
kernel_rfl PRE_first_tail_x15_r0_body.zm106_2665 : PRE_first_tail_x15_r0_body.s1031.heap.get 2665 = some (.obj { PRE_first_tail_x15_r0_body.kappa106.obj (objOf PRE_first_tail_x15_r0_body.s1032 2665) with
  kind := .array (arrOf PRE_first_tail_x15_r0_body.s0 2665 ++ (arrOf PRE_first_tail_x15_r0_body.s1031 2665).drop (arrOf PRE_first_tail_x15_r0_body.s0 2665).length) })
kernel_rfl PRE_first_tail_x15_r0_body.zg106_2673467 : PRE_first_tail_x15_r0_body.s1032.heap.get 2673467 = some (.obj (objOf PRE_first_tail_x15_r0_body.s1032 2673467))
kernel_rfl PRE_first_tail_x15_r0_body.zk106_2673467 : (objOf PRE_first_tail_x15_r0_body.s1032 2673467).kind = .array (arrOf PRE_first_tail_x15_r0_body.s0 2673467)
kernel_rfl PRE_first_tail_x15_r0_body.zm106_2673467 : PRE_first_tail_x15_r0_body.s1031.heap.get 2673467 = some (.obj { PRE_first_tail_x15_r0_body.kappa106.obj (objOf PRE_first_tail_x15_r0_body.s1032 2673467) with
  kind := .array (arrOf PRE_first_tail_x15_r0_body.s0 2673467 ++ (arrOf PRE_first_tail_x15_r0_body.s1031 2673467).drop (arrOf PRE_first_tail_x15_r0_body.s0 2673467).length) })
kernel_rfl PRE_first_tail_x15_r0_body.zw106_4910 : (PRE_first_tail_x15_r0_body.s1032.heap.get 4910).isSome = true
kernel_rfl PRE_first_tail_x15_r0_body.zw106_2673472 : (PRE_first_tail_x15_r0_body.s1032.heap.get 2673472).isSome = true
kernel_rfl PRE_first_tail_x15_r0_body.zw106_2673473 : (PRE_first_tail_x15_r0_body.s1032.heap.get 2673473).isSome = true
-- the heap: the changed list in range, holding the stage's written and fresh addresses; the canonical side's image
kernel_rfl PRE_first_tail_x15_r0_body.zclbd106 : PRE_first_tail_x15_r0_body.cl106.all (fun b => Nat.blt (b / 4096) (4 ^ 31)) = true
kernel_rfl PRE_first_tail_x15_r0_body.zwr106 : PRE_first_tail_x15_r0_body.st106.wr.all (fun b => !Nat.blt b PRE_first_tail_x15_r0_body.s1030.next || PRE_first_tail_x15_r0_body.cl106.contains b) = true
def PRE_first_tail_x15_r0_body.zl106 : List Nat := PRE_first_tail_x15_r0_body.cl106.filter fun a => !(List.contains [2665, 2673467] a)
kernel_rfl PRE_first_tail_x15_r0_body.zimgE106 : PRE_first_tail_x15_r0_body.zl106.map (fun a => PRE_first_tail_x15_r0_body.s1031.heap.get (PRE_first_tail_x15_r0_body.kappa106.a a)) = PRE_first_tail_x15_r0_body.zl106.map (fun a => (PRE_first_tail_x15_r0_body.s1032.heap.get a).map PRE_first_tail_x15_r0_body.kappa106.hobj)
theorem PRE_first_tail_x15_r0_body.zimg106 : HeapImg PRE_first_tail_x15_r0_body.kappa106 PRE_first_tail_x15_r0_body.s1032 PRE_first_tail_x15_r0_body.s1031 PRE_first_tail_x15_r0_body.zl106 := PRE_first_tail_x15_r0_body.zimgE106
-- the roots and their supports
kernel_rfl PRE_first_tail_x15_r0_body.zctl106 : PRE_first_tail_x15_r0_body.s1031.ctl = PRE_first_tail_x15_r0_body.kappa106.ctl PRE_first_tail_x15_r0_body.s1032.ctl
kernel_rfl PRE_first_tail_x15_r0_body.zstack106 : PRE_first_tail_x15_r0_body.s1031.stack = PRE_first_tail_x15_r0_body.s1032.stack.map PRE_first_tail_x15_r0_body.kappa106.frame
kernel_rfl PRE_first_tail_x15_r0_body.zjobs106 : PRE_first_tail_x15_r0_body.s1031.jobs = PRE_first_tail_x15_r0_body.s1032.jobs.map PRE_first_tail_x15_r0_body.kappa106.job
kernel_rfl PRE_first_tail_x15_r0_body.zstores106 : PRE_first_tail_x15_r0_body.s1031.stores = PRE_first_tail_x15_r0_body.kappa106.stores PRE_first_tail_x15_r0_body.s1032.stores
kernel_rfl PRE_first_tail_x15_r0_body.zroots106 : checkRootsSupp PRE_first_tail_x15_r0_body.s1032 4610 = true
kernel_rfl PRE_first_tail_x15_r0_body.znC106 : PRE_first_tail_x15_r0_body.S1030.tab.length + PRE_first_tail_x15_r0_body.cws106.length = 4610
-- the map as `Conv.compact_shift` states it (the call's counters for the literals)
kernel_rfl PRE_first_tail_x15_r0_body.zkap106 : PRE_first_tail_x15_r0_body.kappa106 = Conv.Map.compact PRE_first_tail_x15_r0_body.s1030.next 2758431 PRE_first_tail_x15_r0_body.S1030.tab.length PRE_first_tail_x15_r0_body.pl106 (PRE_first_tail_x15_r0_body.nr106.map NumV.ref) PRE_first_tail_x15_r0_body.kd106.big
  PRE_first_tail_x15_r0_body.kd106.region PRE_first_tail_x15_r0_body.kd106.nodeF
-- the bridge inactive at the canonical state (`Conv.FullShiftQ.toX`; the merged state's bridge is the canonical's: cbridge)
theorem PRE_first_tail_x15_r0_body.zbin106 : (Host.Ts.Sim.Full.bridgeOf PRE_first_tail_x15_r0_body.s1032.ffi).active = false := (Host.Load.Boot.replay_active Host.Load.Run.Prompt.P.oblog2818)
-- the JS bookkeeping's step (`Conv.JClean.step` over the changed list) and the canonical roots' bigint freedom
kernel_rfl PRE_first_tail_x15_r0_body.zjc106 : Conv.jcleanListB (⟨20298, 17388, 2758429, 4610⟩ : Conv.Cnt) PRE_first_tail_x15_r0_body.s1032 PRE_first_tail_x15_r0_body.cl106 = true
kernel_rfl PRE_first_tail_x15_r0_body.zrootsB106 : noBigRootsP (fun i => !Conv.oldBigB (⟨20298, 17388, 2758429, 4610⟩ : Conv.Cnt) i) PRE_first_tail_x15_r0_body.s1032.trace PRE_first_tail_x15_r0_body.s1032 = true
kernel_rfl PRE_first_tail_x15_r0_body.zhm106 : Nat.ble (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s0.ffi).mlx.nnext 17388 = true
theorem PRE_first_tail_x15_r0_body.cjcl106 (h : Conv.JClean (⟨20298, 17388, 2758429, 4610⟩ : Conv.Cnt) PRE_first_tail_x15_r0_body.s1030) : Conv.JClean (⟨20298, 17388, 2758429, 4610⟩ : Conv.Cnt) PRE_first_tail_x15_r0_body.s1032 :=
  Conv.JClean.step h (Conv.Cnt.le_of_leB PRE_first_tail_x15_r0_body.cle106)
    (Conv.heap_off_setAll PRE_first_tail_x15_r0_body.cheap106 fun a ha => Nat.blt_eq.mp (List.all_eq_true.mp PRE_first_tail_x15_r0_body.zclbd106 a ha)) PRE_first_tail_x15_r0_body.zjc106

end Host.Load.Run.Tpl
