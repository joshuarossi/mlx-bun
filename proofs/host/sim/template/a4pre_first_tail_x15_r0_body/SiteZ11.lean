import host.sim.template.a4pre_first_tail_x15_r0_body.SiteS11
import host.sim.template.a4pre_first_tail_x15_r0_body.SiteK11
import host.sim.template.a4pre_first_tail_x15_r0_body.SiteF11
import host.sim.conv.CompactShift
import host.sim.template.Check
import host.sim.BigFreeP
import host.sim.template.CallGen
set_option Elab.async false
namespace Host.Load.Run.Tpl
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
open Host.Ts Host.Ts.Sim Host.Ts.Sim.Template

/-! The compaction's state shift at call site 11 of chain `PRE_first_tail_x15_r0_body` (`Conv.compact_shift`): the call `PRE_first_tail_x15_r0_body.s114`, the merged
state `PRE_first_tail_x15_r0_body.s115`, the canonical state `PRE_first_tail_x15_r0_body.s116`; its frames [2665,2673467,2673472,2673473] (kept arrays [2665,2673467]). -/

-- the map's places and counters
kernel_rfl PRE_first_tail_x15_r0_body.zpl11 : PRE_first_tail_x15_r0_body.pl11.all (Nat.ble PRE_first_tail_x15_r0_body.s114.next) = true
kernel_rfl PRE_first_tail_x15_r0_body.zplnd11 : nodupT PRE_first_tail_x15_r0_body.pl11 PTrie.nil = true
kernel_rfl PRE_first_tail_x15_r0_body.zn111 : Nat.ble PRE_first_tail_x15_r0_body.s114.next 2683392 = true
kernel_rfl PRE_first_tail_x15_r0_body.zfirst11 : Nat.ble aFirst PRE_first_tail_x15_r0_body.s114.next = true
kernel_rfl PRE_first_tail_x15_r0_body.zscn11 : PRE_first_tail_x15_r0_body.s116.next = PRE_first_tail_x15_r0_body.s114.next + PRE_first_tail_x15_r0_body.pl11.length
kernel_rfl PRE_first_tail_x15_r0_body.zsmn11 : PRE_first_tail_x15_r0_body.s115.next = 2683392
kernel_rfl PRE_first_tail_x15_r0_body.zgrow11 : Nat.ble PRE_first_tail_x15_r0_body.s116.next PRE_first_tail_x15_r0_body.s115.next = true
-- the tables
kernel_rfl PRE_first_tail_x15_r0_body.zfresh11 : PRE_first_tail_x15_r0_body.S114.tab.all (fun e => PRE_first_tail_x15_r0_body.cws11.all fun v => e.noVar v) = true
kernel_rfl PRE_first_tail_x15_r0_body.zcnd11 : nodupT PRE_first_tail_x15_r0_body.cws11 PTrie.nil = true
kernel_rfl PRE_first_tail_x15_r0_body.znrHi11 : PRE_first_tail_x15_r0_body.nr11.all (fun r => Nat.blt r PRE_first_tail_x15_r0_body.S115.tab.length) = true
-- the frames: every framed address below the call's counter; the kept arrays the chain start's, extended in the merged state
kernel_rfl PRE_first_tail_x15_r0_body.zfrlt11 : [2665, 2673467, 2673472, 2673473].all (fun a => Nat.blt a PRE_first_tail_x15_r0_body.s114.next) = true
kernel_rfl PRE_first_tail_x15_r0_body.zg11_2665 : PRE_first_tail_x15_r0_body.s116.heap.get 2665 = some (.obj (objOf PRE_first_tail_x15_r0_body.s116 2665))
kernel_rfl PRE_first_tail_x15_r0_body.zk11_2665 : (objOf PRE_first_tail_x15_r0_body.s116 2665).kind = .array (arrOf PRE_first_tail_x15_r0_body.s0 2665)
kernel_rfl PRE_first_tail_x15_r0_body.zm11_2665 : PRE_first_tail_x15_r0_body.s115.heap.get 2665 = some (.obj { PRE_first_tail_x15_r0_body.kappa11.obj (objOf PRE_first_tail_x15_r0_body.s116 2665) with
  kind := .array (arrOf PRE_first_tail_x15_r0_body.s0 2665 ++ (arrOf PRE_first_tail_x15_r0_body.s115 2665).drop (arrOf PRE_first_tail_x15_r0_body.s0 2665).length) })
kernel_rfl PRE_first_tail_x15_r0_body.zg11_2673467 : PRE_first_tail_x15_r0_body.s116.heap.get 2673467 = some (.obj (objOf PRE_first_tail_x15_r0_body.s116 2673467))
kernel_rfl PRE_first_tail_x15_r0_body.zk11_2673467 : (objOf PRE_first_tail_x15_r0_body.s116 2673467).kind = .array (arrOf PRE_first_tail_x15_r0_body.s0 2673467)
kernel_rfl PRE_first_tail_x15_r0_body.zm11_2673467 : PRE_first_tail_x15_r0_body.s115.heap.get 2673467 = some (.obj { PRE_first_tail_x15_r0_body.kappa11.obj (objOf PRE_first_tail_x15_r0_body.s116 2673467) with
  kind := .array (arrOf PRE_first_tail_x15_r0_body.s0 2673467 ++ (arrOf PRE_first_tail_x15_r0_body.s115 2673467).drop (arrOf PRE_first_tail_x15_r0_body.s0 2673467).length) })
kernel_rfl PRE_first_tail_x15_r0_body.zw11_4910 : (PRE_first_tail_x15_r0_body.s116.heap.get 4910).isSome = true
kernel_rfl PRE_first_tail_x15_r0_body.zw11_2673472 : (PRE_first_tail_x15_r0_body.s116.heap.get 2673472).isSome = true
kernel_rfl PRE_first_tail_x15_r0_body.zw11_2673473 : (PRE_first_tail_x15_r0_body.s116.heap.get 2673473).isSome = true
-- the heap: the changed list in range, holding the stage's written and fresh addresses; the canonical side's image
kernel_rfl PRE_first_tail_x15_r0_body.zclbd11 : PRE_first_tail_x15_r0_body.cl11.all (fun b => Nat.blt (b / 4096) (4 ^ 31)) = true
kernel_rfl PRE_first_tail_x15_r0_body.zwr11 : PRE_first_tail_x15_r0_body.st11.wr.all (fun b => !Nat.blt b PRE_first_tail_x15_r0_body.s114.next || PRE_first_tail_x15_r0_body.cl11.contains b) = true
def PRE_first_tail_x15_r0_body.zl11 : List Nat := PRE_first_tail_x15_r0_body.cl11.filter fun a => !(List.contains [2665, 2673467] a)
kernel_rfl PRE_first_tail_x15_r0_body.zimgE11 : PRE_first_tail_x15_r0_body.zl11.map (fun a => PRE_first_tail_x15_r0_body.s115.heap.get (PRE_first_tail_x15_r0_body.kappa11.a a)) = PRE_first_tail_x15_r0_body.zl11.map (fun a => (PRE_first_tail_x15_r0_body.s116.heap.get a).map PRE_first_tail_x15_r0_body.kappa11.hobj)
theorem PRE_first_tail_x15_r0_body.zimg11 : HeapImg PRE_first_tail_x15_r0_body.kappa11 PRE_first_tail_x15_r0_body.s116 PRE_first_tail_x15_r0_body.s115 PRE_first_tail_x15_r0_body.zl11 := PRE_first_tail_x15_r0_body.zimgE11
-- the roots and their supports
kernel_rfl PRE_first_tail_x15_r0_body.zctl11 : PRE_first_tail_x15_r0_body.s115.ctl = PRE_first_tail_x15_r0_body.kappa11.ctl PRE_first_tail_x15_r0_body.s116.ctl
kernel_rfl PRE_first_tail_x15_r0_body.zstack11 : PRE_first_tail_x15_r0_body.s115.stack = PRE_first_tail_x15_r0_body.s116.stack.map PRE_first_tail_x15_r0_body.kappa11.frame
kernel_rfl PRE_first_tail_x15_r0_body.zjobs11 : PRE_first_tail_x15_r0_body.s115.jobs = PRE_first_tail_x15_r0_body.s116.jobs.map PRE_first_tail_x15_r0_body.kappa11.job
kernel_rfl PRE_first_tail_x15_r0_body.zstores11 : PRE_first_tail_x15_r0_body.s115.stores = PRE_first_tail_x15_r0_body.kappa11.stores PRE_first_tail_x15_r0_body.s116.stores
kernel_rfl PRE_first_tail_x15_r0_body.zroots11 : checkRootsSupp PRE_first_tail_x15_r0_body.s116 523 = true
kernel_rfl PRE_first_tail_x15_r0_body.znC11 : PRE_first_tail_x15_r0_body.S114.tab.length + PRE_first_tail_x15_r0_body.cws11.length = 523
-- the map as `Conv.compact_shift` states it (the call's counters for the literals)
kernel_rfl PRE_first_tail_x15_r0_body.zkap11 : PRE_first_tail_x15_r0_body.kappa11 = Conv.Map.compact PRE_first_tail_x15_r0_body.s114.next 2683392 PRE_first_tail_x15_r0_body.S114.tab.length PRE_first_tail_x15_r0_body.pl11 (PRE_first_tail_x15_r0_body.nr11.map NumV.ref) PRE_first_tail_x15_r0_body.kd11.big
  PRE_first_tail_x15_r0_body.kd11.region PRE_first_tail_x15_r0_body.kd11.nodeF
-- the bridge inactive at the canonical state (`Conv.FullShiftQ.toX`; the merged state's bridge is the canonical's: cbridge)
theorem PRE_first_tail_x15_r0_body.zbin11 : (Host.Ts.Sim.Full.bridgeOf PRE_first_tail_x15_r0_body.s116.ffi).active = false := (Host.Load.Boot.replay_active Host.Load.Run.Prompt.P.oblog2818)
-- the JS bookkeeping's step (`Conv.JClean.step` over the changed list) and the canonical roots' bigint freedom
kernel_rfl PRE_first_tail_x15_r0_body.zjc11 : Conv.jcleanListB (⟨18417, 15496, 2683382, 523⟩ : Conv.Cnt) PRE_first_tail_x15_r0_body.s116 PRE_first_tail_x15_r0_body.cl11 = true
kernel_rfl PRE_first_tail_x15_r0_body.zrootsB11 : noBigRootsP (fun i => !Conv.oldBigB (⟨18417, 15496, 2683382, 523⟩ : Conv.Cnt) i) PRE_first_tail_x15_r0_body.s116.trace PRE_first_tail_x15_r0_body.s116 = true
kernel_rfl PRE_first_tail_x15_r0_body.zhm11 : Nat.ble (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s0.ffi).mlx.nnext 15496 = true
theorem PRE_first_tail_x15_r0_body.cjcl11 (h : Conv.JClean (⟨18417, 15496, 2683381, 523⟩ : Conv.Cnt) PRE_first_tail_x15_r0_body.s114) : Conv.JClean (⟨18417, 15496, 2683382, 523⟩ : Conv.Cnt) PRE_first_tail_x15_r0_body.s116 :=
  Conv.JClean.step h (Conv.Cnt.le_of_leB PRE_first_tail_x15_r0_body.cle11)
    (Conv.heap_off_setAll PRE_first_tail_x15_r0_body.cheap11 fun a ha => Nat.blt_eq.mp (List.all_eq_true.mp PRE_first_tail_x15_r0_body.zclbd11 a ha)) PRE_first_tail_x15_r0_body.zjc11

end Host.Load.Run.Tpl
