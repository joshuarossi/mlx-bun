import host.sim.template.a4pre_first_tail_x15_r0_body.SiteS133
import host.sim.template.a4pre_first_tail_x15_r0_body.SiteK133
import host.sim.template.a4pre_first_tail_x15_r0_body.SiteF133
import host.sim.conv.CompactShift
import host.sim.template.Check
import host.sim.BigFreeP
import host.sim.template.CallGen
set_option Elab.async false
namespace Host.Load.Run.Tpl
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
open Host.Ts Host.Ts.Sim Host.Ts.Sim.Template

/-! The compaction's state shift at call site 133 of chain `PRE_first_tail_x15_r0_body` (`Conv.compact_shift`): the call `PRE_first_tail_x15_r0_body.s1176`, the merged
state `PRE_first_tail_x15_r0_body.s1177`, the canonical state `PRE_first_tail_x15_r0_body.s1178`; its frames [2665,2673467,2673472,2673473] (kept arrays [2665,2673467]). -/

-- the map's places and counters
kernel_rfl PRE_first_tail_x15_r0_body.zpl133 : PRE_first_tail_x15_r0_body.pl133.all (Nat.ble PRE_first_tail_x15_r0_body.s1176.next) = true
kernel_rfl PRE_first_tail_x15_r0_body.zplnd133 : nodupT PRE_first_tail_x15_r0_body.pl133 PTrie.nil = true
kernel_rfl PRE_first_tail_x15_r0_body.zn1133 : Nat.ble PRE_first_tail_x15_r0_body.s1176.next 2779533 = true
kernel_rfl PRE_first_tail_x15_r0_body.zfirst133 : Nat.ble aFirst PRE_first_tail_x15_r0_body.s1176.next = true
kernel_rfl PRE_first_tail_x15_r0_body.zscn133 : PRE_first_tail_x15_r0_body.s1178.next = PRE_first_tail_x15_r0_body.s1176.next + PRE_first_tail_x15_r0_body.pl133.length
kernel_rfl PRE_first_tail_x15_r0_body.zsmn133 : PRE_first_tail_x15_r0_body.s1177.next = 2779533
kernel_rfl PRE_first_tail_x15_r0_body.zgrow133 : Nat.ble PRE_first_tail_x15_r0_body.s1178.next PRE_first_tail_x15_r0_body.s1177.next = true
-- the tables
kernel_rfl PRE_first_tail_x15_r0_body.zfresh133 : PRE_first_tail_x15_r0_body.S1176.tab.all (fun e => PRE_first_tail_x15_r0_body.cws133.all fun v => e.noVar v) = true
kernel_rfl PRE_first_tail_x15_r0_body.zcnd133 : nodupT PRE_first_tail_x15_r0_body.cws133 PTrie.nil = true
kernel_rfl PRE_first_tail_x15_r0_body.znrHi133 : PRE_first_tail_x15_r0_body.nr133.all (fun r => Nat.blt r PRE_first_tail_x15_r0_body.S1177.tab.length) = true
-- the frames: every framed address below the call's counter; the kept arrays the chain start's, extended in the merged state
kernel_rfl PRE_first_tail_x15_r0_body.zfrlt133 : [2665, 2673467, 2673472, 2673473].all (fun a => Nat.blt a PRE_first_tail_x15_r0_body.s1176.next) = true
kernel_rfl PRE_first_tail_x15_r0_body.zg133_2665 : PRE_first_tail_x15_r0_body.s1178.heap.get 2665 = some (.obj (objOf PRE_first_tail_x15_r0_body.s1178 2665))
kernel_rfl PRE_first_tail_x15_r0_body.zk133_2665 : (objOf PRE_first_tail_x15_r0_body.s1178 2665).kind = .array (arrOf PRE_first_tail_x15_r0_body.s0 2665)
kernel_rfl PRE_first_tail_x15_r0_body.zm133_2665 : PRE_first_tail_x15_r0_body.s1177.heap.get 2665 = some (.obj { PRE_first_tail_x15_r0_body.kappa133.obj (objOf PRE_first_tail_x15_r0_body.s1178 2665) with
  kind := .array (arrOf PRE_first_tail_x15_r0_body.s0 2665 ++ (arrOf PRE_first_tail_x15_r0_body.s1177 2665).drop (arrOf PRE_first_tail_x15_r0_body.s0 2665).length) })
kernel_rfl PRE_first_tail_x15_r0_body.zg133_2673467 : PRE_first_tail_x15_r0_body.s1178.heap.get 2673467 = some (.obj (objOf PRE_first_tail_x15_r0_body.s1178 2673467))
kernel_rfl PRE_first_tail_x15_r0_body.zk133_2673467 : (objOf PRE_first_tail_x15_r0_body.s1178 2673467).kind = .array (arrOf PRE_first_tail_x15_r0_body.s0 2673467)
kernel_rfl PRE_first_tail_x15_r0_body.zm133_2673467 : PRE_first_tail_x15_r0_body.s1177.heap.get 2673467 = some (.obj { PRE_first_tail_x15_r0_body.kappa133.obj (objOf PRE_first_tail_x15_r0_body.s1178 2673467) with
  kind := .array (arrOf PRE_first_tail_x15_r0_body.s0 2673467 ++ (arrOf PRE_first_tail_x15_r0_body.s1177 2673467).drop (arrOf PRE_first_tail_x15_r0_body.s0 2673467).length) })
kernel_rfl PRE_first_tail_x15_r0_body.zw133_4910 : (PRE_first_tail_x15_r0_body.s1178.heap.get 4910).isSome = true
kernel_rfl PRE_first_tail_x15_r0_body.zw133_2673472 : (PRE_first_tail_x15_r0_body.s1178.heap.get 2673472).isSome = true
kernel_rfl PRE_first_tail_x15_r0_body.zw133_2673473 : (PRE_first_tail_x15_r0_body.s1178.heap.get 2673473).isSome = true
-- the heap: the changed list in range, holding the stage's written and fresh addresses; the canonical side's image
kernel_rfl PRE_first_tail_x15_r0_body.zclbd133 : PRE_first_tail_x15_r0_body.cl133.all (fun b => Nat.blt (b / 4096) (4 ^ 31)) = true
kernel_rfl PRE_first_tail_x15_r0_body.zwr133 : PRE_first_tail_x15_r0_body.st133.wr.all (fun b => !Nat.blt b PRE_first_tail_x15_r0_body.s1176.next || PRE_first_tail_x15_r0_body.cl133.contains b) = true
def PRE_first_tail_x15_r0_body.zl133 : List Nat := PRE_first_tail_x15_r0_body.cl133.filter fun a => !(List.contains [2665, 2673467] a)
kernel_rfl PRE_first_tail_x15_r0_body.zimgE133 : PRE_first_tail_x15_r0_body.zl133.map (fun a => PRE_first_tail_x15_r0_body.s1177.heap.get (PRE_first_tail_x15_r0_body.kappa133.a a)) = PRE_first_tail_x15_r0_body.zl133.map (fun a => (PRE_first_tail_x15_r0_body.s1178.heap.get a).map PRE_first_tail_x15_r0_body.kappa133.hobj)
theorem PRE_first_tail_x15_r0_body.zimg133 : HeapImg PRE_first_tail_x15_r0_body.kappa133 PRE_first_tail_x15_r0_body.s1178 PRE_first_tail_x15_r0_body.s1177 PRE_first_tail_x15_r0_body.zl133 := PRE_first_tail_x15_r0_body.zimgE133
-- the roots and their supports
kernel_rfl PRE_first_tail_x15_r0_body.zctl133 : PRE_first_tail_x15_r0_body.s1177.ctl = PRE_first_tail_x15_r0_body.kappa133.ctl PRE_first_tail_x15_r0_body.s1178.ctl
kernel_rfl PRE_first_tail_x15_r0_body.zstack133 : PRE_first_tail_x15_r0_body.s1177.stack = PRE_first_tail_x15_r0_body.s1178.stack.map PRE_first_tail_x15_r0_body.kappa133.frame
kernel_rfl PRE_first_tail_x15_r0_body.zjobs133 : PRE_first_tail_x15_r0_body.s1177.jobs = PRE_first_tail_x15_r0_body.s1178.jobs.map PRE_first_tail_x15_r0_body.kappa133.job
kernel_rfl PRE_first_tail_x15_r0_body.zstores133 : PRE_first_tail_x15_r0_body.s1177.stores = PRE_first_tail_x15_r0_body.kappa133.stores PRE_first_tail_x15_r0_body.s1178.stores
kernel_rfl PRE_first_tail_x15_r0_body.zroots133 : checkRootsSupp PRE_first_tail_x15_r0_body.s1178 5765 = true
kernel_rfl PRE_first_tail_x15_r0_body.znC133 : PRE_first_tail_x15_r0_body.S1176.tab.length + PRE_first_tail_x15_r0_body.cws133.length = 5765
-- the map as `Conv.compact_shift` states it (the call's counters for the literals)
kernel_rfl PRE_first_tail_x15_r0_body.zkap133 : PRE_first_tail_x15_r0_body.kappa133 = Conv.Map.compact PRE_first_tail_x15_r0_body.s1176.next 2779533 PRE_first_tail_x15_r0_body.S1176.tab.length PRE_first_tail_x15_r0_body.pl133 (PRE_first_tail_x15_r0_body.nr133.map NumV.ref) PRE_first_tail_x15_r0_body.kd133.big
  PRE_first_tail_x15_r0_body.kd133.region PRE_first_tail_x15_r0_body.kd133.nodeF
-- the bridge inactive at the canonical state (`Conv.FullShiftQ.toX`; the merged state's bridge is the canonical's: cbridge)
theorem PRE_first_tail_x15_r0_body.zbin133 : (Host.Ts.Sim.Full.bridgeOf PRE_first_tail_x15_r0_body.s1178.ffi).active = false := (Host.Load.Boot.replay_active Host.Load.Run.Prompt.P.oblog2818)
-- the JS bookkeeping's step (`Conv.JClean.step` over the changed list) and the canonical roots' bigint freedom
kernel_rfl PRE_first_tail_x15_r0_body.zjc133 : Conv.jcleanListB (⟨20828, 17925, 2779531, 5765⟩ : Conv.Cnt) PRE_first_tail_x15_r0_body.s1178 PRE_first_tail_x15_r0_body.cl133 = true
kernel_rfl PRE_first_tail_x15_r0_body.zroots2133 : noBigRootsP (fun i => !Conv.oldBigB (⟨20828, 17925, 2779531, 5765⟩ : Conv.Cnt) i) PRE_first_tail_x15_r0_body.s1178.trace PRE_first_tail_x15_r0_body.s1178 = true
kernel_rfl PRE_first_tail_x15_r0_body.zhm133 : Nat.ble (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s0.ffi).mlx.nnext 17925 = true
theorem PRE_first_tail_x15_r0_body.cjcl133 (h : Conv.JClean (⟨20828, 17925, 2779531, 5765⟩ : Conv.Cnt) PRE_first_tail_x15_r0_body.s1176) : Conv.JClean (⟨20828, 17925, 2779531, 5765⟩ : Conv.Cnt) PRE_first_tail_x15_r0_body.s1178 :=
  Conv.JClean.step h (Conv.Cnt.le_of_leB PRE_first_tail_x15_r0_body.cle133)
    (Conv.heap_off_setAll PRE_first_tail_x15_r0_body.cheap133 fun a ha => Nat.blt_eq.mp (List.all_eq_true.mp PRE_first_tail_x15_r0_body.zclbd133 a ha)) PRE_first_tail_x15_r0_body.zjc133

end Host.Load.Run.Tpl
