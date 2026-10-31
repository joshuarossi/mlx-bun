import host.sim.template.a4pre_first_tail_x15_r0_body.SiteS95
import host.sim.template.a4pre_first_tail_x15_r0_body.SiteK95
import host.sim.template.a4pre_first_tail_x15_r0_body.SiteF95
import host.sim.conv.CompactShift
import host.sim.template.Check
import host.sim.BigFreeP
import host.sim.template.CallGen
set_option Elab.async false
namespace Host.Load.Run.Tpl
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
open Host.Ts Host.Ts.Sim Host.Ts.Sim.Template

/-! The compaction's state shift at call site 95 of chain `PRE_first_tail_x15_r0_body` (`Conv.compact_shift`): the call `PRE_first_tail_x15_r0_body.s919`, the merged
state `PRE_first_tail_x15_r0_body.s920`, the canonical state `PRE_first_tail_x15_r0_body.s921`; its frames [2665,2673467,2673472,2673473] (kept arrays [2665,2673467]). -/

-- the map's places and counters
kernel_rfl PRE_first_tail_x15_r0_body.zpl95 : PRE_first_tail_x15_r0_body.pl95.all (Nat.ble PRE_first_tail_x15_r0_body.s919.next) = true
kernel_rfl PRE_first_tail_x15_r0_body.zplnd95 : nodupT PRE_first_tail_x15_r0_body.pl95 PTrie.nil = true
kernel_rfl PRE_first_tail_x15_r0_body.zn195 : Nat.ble PRE_first_tail_x15_r0_body.s919.next 2749313 = true
kernel_rfl PRE_first_tail_x15_r0_body.zfirst95 : Nat.ble aFirst PRE_first_tail_x15_r0_body.s919.next = true
kernel_rfl PRE_first_tail_x15_r0_body.zscn95 : PRE_first_tail_x15_r0_body.s921.next = PRE_first_tail_x15_r0_body.s919.next + PRE_first_tail_x15_r0_body.pl95.length
kernel_rfl PRE_first_tail_x15_r0_body.zsmn95 : PRE_first_tail_x15_r0_body.s920.next = 2749313
kernel_rfl PRE_first_tail_x15_r0_body.zgrow95 : Nat.ble PRE_first_tail_x15_r0_body.s921.next PRE_first_tail_x15_r0_body.s920.next = true
-- the tables
kernel_rfl PRE_first_tail_x15_r0_body.zfresh95 : PRE_first_tail_x15_r0_body.S919.tab.all (fun e => PRE_first_tail_x15_r0_body.cws95.all fun v => e.noVar v) = true
kernel_rfl PRE_first_tail_x15_r0_body.zcnd95 : nodupT PRE_first_tail_x15_r0_body.cws95 PTrie.nil = true
kernel_rfl PRE_first_tail_x15_r0_body.znrHi95 : PRE_first_tail_x15_r0_body.nr95.all (fun r => Nat.blt r PRE_first_tail_x15_r0_body.S920.tab.length) = true
-- the frames: every framed address below the call's counter; the kept arrays the chain start's, extended in the merged state
kernel_rfl PRE_first_tail_x15_r0_body.zfrlt95 : [2665, 2673467, 2673472, 2673473].all (fun a => Nat.blt a PRE_first_tail_x15_r0_body.s919.next) = true
kernel_rfl PRE_first_tail_x15_r0_body.zg95_2665 : PRE_first_tail_x15_r0_body.s921.heap.get 2665 = some (.obj (objOf PRE_first_tail_x15_r0_body.s921 2665))
kernel_rfl PRE_first_tail_x15_r0_body.zk95_2665 : (objOf PRE_first_tail_x15_r0_body.s921 2665).kind = .array (arrOf PRE_first_tail_x15_r0_body.s0 2665)
kernel_rfl PRE_first_tail_x15_r0_body.zm95_2665 : PRE_first_tail_x15_r0_body.s920.heap.get 2665 = some (.obj { PRE_first_tail_x15_r0_body.kappa95.obj (objOf PRE_first_tail_x15_r0_body.s921 2665) with
  kind := .array (arrOf PRE_first_tail_x15_r0_body.s0 2665 ++ (arrOf PRE_first_tail_x15_r0_body.s920 2665).drop (arrOf PRE_first_tail_x15_r0_body.s0 2665).length) })
kernel_rfl PRE_first_tail_x15_r0_body.zg95_2673467 : PRE_first_tail_x15_r0_body.s921.heap.get 2673467 = some (.obj (objOf PRE_first_tail_x15_r0_body.s921 2673467))
kernel_rfl PRE_first_tail_x15_r0_body.zk95_2673467 : (objOf PRE_first_tail_x15_r0_body.s921 2673467).kind = .array (arrOf PRE_first_tail_x15_r0_body.s0 2673467)
kernel_rfl PRE_first_tail_x15_r0_body.zm95_2673467 : PRE_first_tail_x15_r0_body.s920.heap.get 2673467 = some (.obj { PRE_first_tail_x15_r0_body.kappa95.obj (objOf PRE_first_tail_x15_r0_body.s921 2673467) with
  kind := .array (arrOf PRE_first_tail_x15_r0_body.s0 2673467 ++ (arrOf PRE_first_tail_x15_r0_body.s920 2673467).drop (arrOf PRE_first_tail_x15_r0_body.s0 2673467).length) })
kernel_rfl PRE_first_tail_x15_r0_body.zw95_4910 : (PRE_first_tail_x15_r0_body.s921.heap.get 4910).isSome = true
kernel_rfl PRE_first_tail_x15_r0_body.zw95_2673472 : (PRE_first_tail_x15_r0_body.s921.heap.get 2673472).isSome = true
kernel_rfl PRE_first_tail_x15_r0_body.zw95_2673473 : (PRE_first_tail_x15_r0_body.s921.heap.get 2673473).isSome = true
-- the heap: the changed list in range, holding the stage's written and fresh addresses; the canonical side's image
kernel_rfl PRE_first_tail_x15_r0_body.zclbd95 : PRE_first_tail_x15_r0_body.cl95.all (fun b => Nat.blt (b / 4096) (4 ^ 31)) = true
kernel_rfl PRE_first_tail_x15_r0_body.zwr95 : PRE_first_tail_x15_r0_body.st95.wr.all (fun b => !Nat.blt b PRE_first_tail_x15_r0_body.s919.next || PRE_first_tail_x15_r0_body.cl95.contains b) = true
def PRE_first_tail_x15_r0_body.zl95 : List Nat := PRE_first_tail_x15_r0_body.cl95.filter fun a => !(List.contains [2665, 2673467] a)
kernel_rfl PRE_first_tail_x15_r0_body.zimgE95 : PRE_first_tail_x15_r0_body.zl95.map (fun a => PRE_first_tail_x15_r0_body.s920.heap.get (PRE_first_tail_x15_r0_body.kappa95.a a)) = PRE_first_tail_x15_r0_body.zl95.map (fun a => (PRE_first_tail_x15_r0_body.s921.heap.get a).map PRE_first_tail_x15_r0_body.kappa95.hobj)
theorem PRE_first_tail_x15_r0_body.zimg95 : HeapImg PRE_first_tail_x15_r0_body.kappa95 PRE_first_tail_x15_r0_body.s921 PRE_first_tail_x15_r0_body.s920 PRE_first_tail_x15_r0_body.zl95 := PRE_first_tail_x15_r0_body.zimgE95
-- the roots and their supports
kernel_rfl PRE_first_tail_x15_r0_body.zctl95 : PRE_first_tail_x15_r0_body.s920.ctl = PRE_first_tail_x15_r0_body.kappa95.ctl PRE_first_tail_x15_r0_body.s921.ctl
kernel_rfl PRE_first_tail_x15_r0_body.zstack95 : PRE_first_tail_x15_r0_body.s920.stack = PRE_first_tail_x15_r0_body.s921.stack.map PRE_first_tail_x15_r0_body.kappa95.frame
kernel_rfl PRE_first_tail_x15_r0_body.zjobs95 : PRE_first_tail_x15_r0_body.s920.jobs = PRE_first_tail_x15_r0_body.s921.jobs.map PRE_first_tail_x15_r0_body.kappa95.job
kernel_rfl PRE_first_tail_x15_r0_body.zstores95 : PRE_first_tail_x15_r0_body.s920.stores = PRE_first_tail_x15_r0_body.kappa95.stores PRE_first_tail_x15_r0_body.s921.stores
kernel_rfl PRE_first_tail_x15_r0_body.zroots95 : checkRootsSupp PRE_first_tail_x15_r0_body.s921 4114 = true
kernel_rfl PRE_first_tail_x15_r0_body.znC95 : PRE_first_tail_x15_r0_body.S919.tab.length + PRE_first_tail_x15_r0_body.cws95.length = 4114
-- the map as `Conv.compact_shift` states it (the call's counters for the literals)
kernel_rfl PRE_first_tail_x15_r0_body.zkap95 : PRE_first_tail_x15_r0_body.kappa95 = Conv.Map.compact PRE_first_tail_x15_r0_body.s919.next 2749313 PRE_first_tail_x15_r0_body.S919.tab.length PRE_first_tail_x15_r0_body.pl95 (PRE_first_tail_x15_r0_body.nr95.map NumV.ref) PRE_first_tail_x15_r0_body.kd95.big
  PRE_first_tail_x15_r0_body.kd95.region PRE_first_tail_x15_r0_body.kd95.nodeF
-- the bridge inactive at the canonical state (`Conv.FullShiftQ.toX`; the merged state's bridge is the canonical's: cbridge)
theorem PRE_first_tail_x15_r0_body.zbin95 : (Host.Ts.Sim.Full.bridgeOf PRE_first_tail_x15_r0_body.s921.ffi).active = false := (Host.Load.Boot.replay_active Host.Load.Run.Prompt.P.oblog2818)
-- the JS bookkeeping's step (`Conv.JClean.step` over the changed list) and the canonical roots' bigint freedom
kernel_rfl PRE_first_tail_x15_r0_body.zjc95 : Conv.jcleanListB (⟨20069, 17155, 2749294, 4114⟩ : Conv.Cnt) PRE_first_tail_x15_r0_body.s921 PRE_first_tail_x15_r0_body.cl95 = true
kernel_rfl PRE_first_tail_x15_r0_body.zrootsB95 : noBigRootsP (fun i => !Conv.oldBigB (⟨20069, 17155, 2749294, 4114⟩ : Conv.Cnt) i) PRE_first_tail_x15_r0_body.s921.trace PRE_first_tail_x15_r0_body.s921 = true
kernel_rfl PRE_first_tail_x15_r0_body.zhm95 : Nat.ble (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s0.ffi).mlx.nnext 17155 = true
theorem PRE_first_tail_x15_r0_body.cjcl95 (h : Conv.JClean (⟨20069, 17155, 2749293, 4114⟩ : Conv.Cnt) PRE_first_tail_x15_r0_body.s919) : Conv.JClean (⟨20069, 17155, 2749294, 4114⟩ : Conv.Cnt) PRE_first_tail_x15_r0_body.s921 :=
  Conv.JClean.step h (Conv.Cnt.le_of_leB PRE_first_tail_x15_r0_body.cle95)
    (Conv.heap_off_setAll PRE_first_tail_x15_r0_body.cheap95 fun a ha => Nat.blt_eq.mp (List.all_eq_true.mp PRE_first_tail_x15_r0_body.zclbd95 a ha)) PRE_first_tail_x15_r0_body.zjc95

end Host.Load.Run.Tpl
