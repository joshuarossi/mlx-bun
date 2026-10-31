import host.sim.template.a4pre_first_tail_x15_r0_body.SiteS118
import host.sim.template.a4pre_first_tail_x15_r0_body.SiteK118
import host.sim.template.a4pre_first_tail_x15_r0_body.SiteF118
import host.sim.conv.CompactShift
import host.sim.template.Check
import host.sim.BigFreeP
import host.sim.template.CallGen
set_option Elab.async false
namespace Host.Load.Run.Tpl
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
open Host.Ts Host.Ts.Sim Host.Ts.Sim.Template

/-! The compaction's state shift at call site 118 of chain `PRE_first_tail_x15_r0_body` (`Conv.compact_shift`): the call `PRE_first_tail_x15_r0_body.s1044`, the merged
state `PRE_first_tail_x15_r0_body.s1045`, the canonical state `PRE_first_tail_x15_r0_body.s1046`; its frames [2665,2673467,2673472,2673473] (kept arrays [2665,2673467]). -/

-- the map's places and counters
kernel_rfl PRE_first_tail_x15_r0_body.zpl118 : PRE_first_tail_x15_r0_body.pl118.all (Nat.ble PRE_first_tail_x15_r0_body.s1044.next) = true
kernel_rfl PRE_first_tail_x15_r0_body.zplnd118 : nodupT PRE_first_tail_x15_r0_body.pl118 PTrie.nil = true
kernel_rfl PRE_first_tail_x15_r0_body.zn1118 : Nat.ble PRE_first_tail_x15_r0_body.s1044.next 2767843 = true
kernel_rfl PRE_first_tail_x15_r0_body.zfirst118 : Nat.ble aFirst PRE_first_tail_x15_r0_body.s1044.next = true
kernel_rfl PRE_first_tail_x15_r0_body.zscn118 : PRE_first_tail_x15_r0_body.s1046.next = PRE_first_tail_x15_r0_body.s1044.next + PRE_first_tail_x15_r0_body.pl118.length
kernel_rfl PRE_first_tail_x15_r0_body.zsmn118 : PRE_first_tail_x15_r0_body.s1045.next = 2767843
kernel_rfl PRE_first_tail_x15_r0_body.zgrow118 : Nat.ble PRE_first_tail_x15_r0_body.s1046.next PRE_first_tail_x15_r0_body.s1045.next = true
-- the tables
kernel_rfl PRE_first_tail_x15_r0_body.zfresh118 : PRE_first_tail_x15_r0_body.S1044.tab.all (fun e => PRE_first_tail_x15_r0_body.cws118.all fun v => e.noVar v) = true
kernel_rfl PRE_first_tail_x15_r0_body.zcnd118 : nodupT PRE_first_tail_x15_r0_body.cws118 PTrie.nil = true
kernel_rfl PRE_first_tail_x15_r0_body.znrHi118 : PRE_first_tail_x15_r0_body.nr118.all (fun r => Nat.blt r PRE_first_tail_x15_r0_body.S1045.tab.length) = true
-- the frames: every framed address below the call's counter; the kept arrays the chain start's, extended in the merged state
kernel_rfl PRE_first_tail_x15_r0_body.zfrlt118 : [2665, 2673467, 2673472, 2673473].all (fun a => Nat.blt a PRE_first_tail_x15_r0_body.s1044.next) = true
kernel_rfl PRE_first_tail_x15_r0_body.zg118_2665 : PRE_first_tail_x15_r0_body.s1046.heap.get 2665 = some (.obj (objOf PRE_first_tail_x15_r0_body.s1046 2665))
kernel_rfl PRE_first_tail_x15_r0_body.zk118_2665 : (objOf PRE_first_tail_x15_r0_body.s1046 2665).kind = .array (arrOf PRE_first_tail_x15_r0_body.s0 2665)
kernel_rfl PRE_first_tail_x15_r0_body.zm118_2665 : PRE_first_tail_x15_r0_body.s1045.heap.get 2665 = some (.obj { PRE_first_tail_x15_r0_body.kappa118.obj (objOf PRE_first_tail_x15_r0_body.s1046 2665) with
  kind := .array (arrOf PRE_first_tail_x15_r0_body.s0 2665 ++ (arrOf PRE_first_tail_x15_r0_body.s1045 2665).drop (arrOf PRE_first_tail_x15_r0_body.s0 2665).length) })
kernel_rfl PRE_first_tail_x15_r0_body.zg118_2673467 : PRE_first_tail_x15_r0_body.s1046.heap.get 2673467 = some (.obj (objOf PRE_first_tail_x15_r0_body.s1046 2673467))
kernel_rfl PRE_first_tail_x15_r0_body.zk118_2673467 : (objOf PRE_first_tail_x15_r0_body.s1046 2673467).kind = .array (arrOf PRE_first_tail_x15_r0_body.s0 2673467)
kernel_rfl PRE_first_tail_x15_r0_body.zm118_2673467 : PRE_first_tail_x15_r0_body.s1045.heap.get 2673467 = some (.obj { PRE_first_tail_x15_r0_body.kappa118.obj (objOf PRE_first_tail_x15_r0_body.s1046 2673467) with
  kind := .array (arrOf PRE_first_tail_x15_r0_body.s0 2673467 ++ (arrOf PRE_first_tail_x15_r0_body.s1045 2673467).drop (arrOf PRE_first_tail_x15_r0_body.s0 2673467).length) })
kernel_rfl PRE_first_tail_x15_r0_body.zw118_4910 : (PRE_first_tail_x15_r0_body.s1046.heap.get 4910).isSome = true
kernel_rfl PRE_first_tail_x15_r0_body.zw118_2673472 : (PRE_first_tail_x15_r0_body.s1046.heap.get 2673472).isSome = true
kernel_rfl PRE_first_tail_x15_r0_body.zw118_2673473 : (PRE_first_tail_x15_r0_body.s1046.heap.get 2673473).isSome = true
-- the heap: the changed list in range, holding the stage's written and fresh addresses; the canonical side's image
kernel_rfl PRE_first_tail_x15_r0_body.zclbd118 : PRE_first_tail_x15_r0_body.cl118.all (fun b => Nat.blt (b / 4096) (4 ^ 31)) = true
kernel_rfl PRE_first_tail_x15_r0_body.zwr118 : PRE_first_tail_x15_r0_body.st118.wr.all (fun b => !Nat.blt b PRE_first_tail_x15_r0_body.s1044.next || PRE_first_tail_x15_r0_body.cl118.contains b) = true
def PRE_first_tail_x15_r0_body.zl118 : List Nat := PRE_first_tail_x15_r0_body.cl118.filter fun a => !(List.contains [2665, 2673467] a)
kernel_rfl PRE_first_tail_x15_r0_body.zimgE118 : PRE_first_tail_x15_r0_body.zl118.map (fun a => PRE_first_tail_x15_r0_body.s1045.heap.get (PRE_first_tail_x15_r0_body.kappa118.a a)) = PRE_first_tail_x15_r0_body.zl118.map (fun a => (PRE_first_tail_x15_r0_body.s1046.heap.get a).map PRE_first_tail_x15_r0_body.kappa118.hobj)
theorem PRE_first_tail_x15_r0_body.zimg118 : HeapImg PRE_first_tail_x15_r0_body.kappa118 PRE_first_tail_x15_r0_body.s1046 PRE_first_tail_x15_r0_body.s1045 PRE_first_tail_x15_r0_body.zl118 := PRE_first_tail_x15_r0_body.zimgE118
-- the roots and their supports
kernel_rfl PRE_first_tail_x15_r0_body.zctl118 : PRE_first_tail_x15_r0_body.s1045.ctl = PRE_first_tail_x15_r0_body.kappa118.ctl PRE_first_tail_x15_r0_body.s1046.ctl
kernel_rfl PRE_first_tail_x15_r0_body.zstack118 : PRE_first_tail_x15_r0_body.s1045.stack = PRE_first_tail_x15_r0_body.s1046.stack.map PRE_first_tail_x15_r0_body.kappa118.frame
kernel_rfl PRE_first_tail_x15_r0_body.zjobs118 : PRE_first_tail_x15_r0_body.s1045.jobs = PRE_first_tail_x15_r0_body.s1046.jobs.map PRE_first_tail_x15_r0_body.kappa118.job
kernel_rfl PRE_first_tail_x15_r0_body.zstores118 : PRE_first_tail_x15_r0_body.s1045.stores = PRE_first_tail_x15_r0_body.kappa118.stores PRE_first_tail_x15_r0_body.s1046.stores
kernel_rfl PRE_first_tail_x15_r0_body.zroots118 : checkRootsSupp PRE_first_tail_x15_r0_body.s1046 5123 = true
kernel_rfl PRE_first_tail_x15_r0_body.znC118 : PRE_first_tail_x15_r0_body.S1044.tab.length + PRE_first_tail_x15_r0_body.cws118.length = 5123
-- the map as `Conv.compact_shift` states it (the call's counters for the literals)
kernel_rfl PRE_first_tail_x15_r0_body.zkap118 : PRE_first_tail_x15_r0_body.kappa118 = Conv.Map.compact PRE_first_tail_x15_r0_body.s1044.next 2767843 PRE_first_tail_x15_r0_body.S1044.tab.length PRE_first_tail_x15_r0_body.pl118 (PRE_first_tail_x15_r0_body.nr118.map NumV.ref) PRE_first_tail_x15_r0_body.kd118.big
  PRE_first_tail_x15_r0_body.kd118.region PRE_first_tail_x15_r0_body.kd118.nodeF
-- the bridge inactive at the canonical state (`Conv.FullShiftQ.toX`; the merged state's bridge is the canonical's: cbridge)
theorem PRE_first_tail_x15_r0_body.zbin118 : (Host.Ts.Sim.Full.bridgeOf PRE_first_tail_x15_r0_body.s1046.ffi).active = false := (Host.Load.Boot.replay_active Host.Load.Run.Prompt.P.oblog2818)
-- the JS bookkeeping's step (`Conv.JClean.step` over the changed list) and the canonical roots' bigint freedom
kernel_rfl PRE_first_tail_x15_r0_body.zjc118 : Conv.jcleanListB (⟨20534, 17625, 2767841, 5123⟩ : Conv.Cnt) PRE_first_tail_x15_r0_body.s1046 PRE_first_tail_x15_r0_body.cl118 = true
kernel_rfl PRE_first_tail_x15_r0_body.zroots2118 : noBigRootsP (fun i => !Conv.oldBigB (⟨20534, 17625, 2767841, 5123⟩ : Conv.Cnt) i) PRE_first_tail_x15_r0_body.s1046.trace PRE_first_tail_x15_r0_body.s1046 = true
kernel_rfl PRE_first_tail_x15_r0_body.zhm118 : Nat.ble (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s0.ffi).mlx.nnext 17625 = true
theorem PRE_first_tail_x15_r0_body.cjcl118 (h : Conv.JClean (⟨20534, 17625, 2767841, 5123⟩ : Conv.Cnt) PRE_first_tail_x15_r0_body.s1044) : Conv.JClean (⟨20534, 17625, 2767841, 5123⟩ : Conv.Cnt) PRE_first_tail_x15_r0_body.s1046 :=
  Conv.JClean.step h (Conv.Cnt.le_of_leB PRE_first_tail_x15_r0_body.cle118)
    (Conv.heap_off_setAll PRE_first_tail_x15_r0_body.cheap118 fun a ha => Nat.blt_eq.mp (List.all_eq_true.mp PRE_first_tail_x15_r0_body.zclbd118 a ha)) PRE_first_tail_x15_r0_body.zjc118

end Host.Load.Run.Tpl
