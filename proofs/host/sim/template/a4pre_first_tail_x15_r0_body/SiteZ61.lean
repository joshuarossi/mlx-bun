import host.sim.template.a4pre_first_tail_x15_r0_body.SiteS61
import host.sim.template.a4pre_first_tail_x15_r0_body.SiteK61
import host.sim.template.a4pre_first_tail_x15_r0_body.SiteF61
import host.sim.conv.CompactShift
import host.sim.template.Check
import host.sim.BigFreeP
import host.sim.template.CallGen
set_option Elab.async false
namespace Host.Load.Run.Tpl
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
open Host.Ts Host.Ts.Sim Host.Ts.Sim.Template

/-! The compaction's state shift at call site 61 of chain `PRE_first_tail_x15_r0_body` (`Conv.compact_shift`): the call `PRE_first_tail_x15_r0_body.s599`, the merged
state `PRE_first_tail_x15_r0_body.s600`, the canonical state `PRE_first_tail_x15_r0_body.s601`; its frames [2665,2673467,2673472,2673473] (kept arrays [2665,2673467]). -/

-- the map's places and counters
kernel_rfl PRE_first_tail_x15_r0_body.zpl61 : PRE_first_tail_x15_r0_body.pl61.all (Nat.ble PRE_first_tail_x15_r0_body.s599.next) = true
kernel_rfl PRE_first_tail_x15_r0_body.zplnd61 : nodupT PRE_first_tail_x15_r0_body.pl61 PTrie.nil = true
kernel_rfl PRE_first_tail_x15_r0_body.zn161 : Nat.ble PRE_first_tail_x15_r0_body.s599.next 2723045 = true
kernel_rfl PRE_first_tail_x15_r0_body.zfirst61 : Nat.ble aFirst PRE_first_tail_x15_r0_body.s599.next = true
kernel_rfl PRE_first_tail_x15_r0_body.zscn61 : PRE_first_tail_x15_r0_body.s601.next = PRE_first_tail_x15_r0_body.s599.next + PRE_first_tail_x15_r0_body.pl61.length
kernel_rfl PRE_first_tail_x15_r0_body.zsmn61 : PRE_first_tail_x15_r0_body.s600.next = 2723045
kernel_rfl PRE_first_tail_x15_r0_body.zgrow61 : Nat.ble PRE_first_tail_x15_r0_body.s601.next PRE_first_tail_x15_r0_body.s600.next = true
-- the tables
kernel_rfl PRE_first_tail_x15_r0_body.zfresh61 : PRE_first_tail_x15_r0_body.S599.tab.all (fun e => PRE_first_tail_x15_r0_body.cws61.all fun v => e.noVar v) = true
kernel_rfl PRE_first_tail_x15_r0_body.zcnd61 : nodupT PRE_first_tail_x15_r0_body.cws61 PTrie.nil = true
kernel_rfl PRE_first_tail_x15_r0_body.znrHi61 : PRE_first_tail_x15_r0_body.nr61.all (fun r => Nat.blt r PRE_first_tail_x15_r0_body.S600.tab.length) = true
-- the frames: every framed address below the call's counter; the kept arrays the chain start's, extended in the merged state
kernel_rfl PRE_first_tail_x15_r0_body.zfrlt61 : [2665, 2673467, 2673472, 2673473].all (fun a => Nat.blt a PRE_first_tail_x15_r0_body.s599.next) = true
kernel_rfl PRE_first_tail_x15_r0_body.zg61_2665 : PRE_first_tail_x15_r0_body.s601.heap.get 2665 = some (.obj (objOf PRE_first_tail_x15_r0_body.s601 2665))
kernel_rfl PRE_first_tail_x15_r0_body.zk61_2665 : (objOf PRE_first_tail_x15_r0_body.s601 2665).kind = .array (arrOf PRE_first_tail_x15_r0_body.s0 2665)
kernel_rfl PRE_first_tail_x15_r0_body.zm61_2665 : PRE_first_tail_x15_r0_body.s600.heap.get 2665 = some (.obj { PRE_first_tail_x15_r0_body.kappa61.obj (objOf PRE_first_tail_x15_r0_body.s601 2665) with
  kind := .array (arrOf PRE_first_tail_x15_r0_body.s0 2665 ++ (arrOf PRE_first_tail_x15_r0_body.s600 2665).drop (arrOf PRE_first_tail_x15_r0_body.s0 2665).length) })
kernel_rfl PRE_first_tail_x15_r0_body.zg61_2673467 : PRE_first_tail_x15_r0_body.s601.heap.get 2673467 = some (.obj (objOf PRE_first_tail_x15_r0_body.s601 2673467))
kernel_rfl PRE_first_tail_x15_r0_body.zk61_2673467 : (objOf PRE_first_tail_x15_r0_body.s601 2673467).kind = .array (arrOf PRE_first_tail_x15_r0_body.s0 2673467)
kernel_rfl PRE_first_tail_x15_r0_body.zm61_2673467 : PRE_first_tail_x15_r0_body.s600.heap.get 2673467 = some (.obj { PRE_first_tail_x15_r0_body.kappa61.obj (objOf PRE_first_tail_x15_r0_body.s601 2673467) with
  kind := .array (arrOf PRE_first_tail_x15_r0_body.s0 2673467 ++ (arrOf PRE_first_tail_x15_r0_body.s600 2673467).drop (arrOf PRE_first_tail_x15_r0_body.s0 2673467).length) })
kernel_rfl PRE_first_tail_x15_r0_body.zw61_4910 : (PRE_first_tail_x15_r0_body.s601.heap.get 4910).isSome = true
kernel_rfl PRE_first_tail_x15_r0_body.zw61_2673472 : (PRE_first_tail_x15_r0_body.s601.heap.get 2673472).isSome = true
kernel_rfl PRE_first_tail_x15_r0_body.zw61_2673473 : (PRE_first_tail_x15_r0_body.s601.heap.get 2673473).isSome = true
-- the heap: the changed list in range, holding the stage's written and fresh addresses; the canonical side's image
kernel_rfl PRE_first_tail_x15_r0_body.zclbd61 : PRE_first_tail_x15_r0_body.cl61.all (fun b => Nat.blt (b / 4096) (4 ^ 31)) = true
kernel_rfl PRE_first_tail_x15_r0_body.zwr61 : PRE_first_tail_x15_r0_body.st61.wr.all (fun b => !Nat.blt b PRE_first_tail_x15_r0_body.s599.next || PRE_first_tail_x15_r0_body.cl61.contains b) = true
def PRE_first_tail_x15_r0_body.zl61 : List Nat := PRE_first_tail_x15_r0_body.cl61.filter fun a => !(List.contains [2665, 2673467] a)
kernel_rfl PRE_first_tail_x15_r0_body.zimgE61 : PRE_first_tail_x15_r0_body.zl61.map (fun a => PRE_first_tail_x15_r0_body.s600.heap.get (PRE_first_tail_x15_r0_body.kappa61.a a)) = PRE_first_tail_x15_r0_body.zl61.map (fun a => (PRE_first_tail_x15_r0_body.s601.heap.get a).map PRE_first_tail_x15_r0_body.kappa61.hobj)
theorem PRE_first_tail_x15_r0_body.zimg61 : HeapImg PRE_first_tail_x15_r0_body.kappa61 PRE_first_tail_x15_r0_body.s601 PRE_first_tail_x15_r0_body.s600 PRE_first_tail_x15_r0_body.zl61 := PRE_first_tail_x15_r0_body.zimgE61
-- the roots and their supports
kernel_rfl PRE_first_tail_x15_r0_body.zctl61 : PRE_first_tail_x15_r0_body.s600.ctl = PRE_first_tail_x15_r0_body.kappa61.ctl PRE_first_tail_x15_r0_body.s601.ctl
kernel_rfl PRE_first_tail_x15_r0_body.zstack61 : PRE_first_tail_x15_r0_body.s600.stack = PRE_first_tail_x15_r0_body.s601.stack.map PRE_first_tail_x15_r0_body.kappa61.frame
kernel_rfl PRE_first_tail_x15_r0_body.zjobs61 : PRE_first_tail_x15_r0_body.s600.jobs = PRE_first_tail_x15_r0_body.s601.jobs.map PRE_first_tail_x15_r0_body.kappa61.job
kernel_rfl PRE_first_tail_x15_r0_body.zstores61 : PRE_first_tail_x15_r0_body.s600.stores = PRE_first_tail_x15_r0_body.kappa61.stores PRE_first_tail_x15_r0_body.s601.stores
kernel_rfl PRE_first_tail_x15_r0_body.zroots61 : checkRootsSupp PRE_first_tail_x15_r0_body.s601 2687 = true
kernel_rfl PRE_first_tail_x15_r0_body.znC61 : PRE_first_tail_x15_r0_body.S599.tab.length + PRE_first_tail_x15_r0_body.cws61.length = 2687
-- the map as `Conv.compact_shift` states it (the call's counters for the literals)
kernel_rfl PRE_first_tail_x15_r0_body.zkap61 : PRE_first_tail_x15_r0_body.kappa61 = Conv.Map.compact PRE_first_tail_x15_r0_body.s599.next 2723045 PRE_first_tail_x15_r0_body.S599.tab.length PRE_first_tail_x15_r0_body.pl61 (PRE_first_tail_x15_r0_body.nr61.map NumV.ref) PRE_first_tail_x15_r0_body.kd61.big
  PRE_first_tail_x15_r0_body.kd61.region PRE_first_tail_x15_r0_body.kd61.nodeF
-- the bridge inactive at the canonical state (`Conv.FullShiftQ.toX`; the merged state's bridge is the canonical's: cbridge)
theorem PRE_first_tail_x15_r0_body.zbin61 : (Host.Ts.Sim.Full.bridgeOf PRE_first_tail_x15_r0_body.s601.ffi).active = false := (Host.Load.Boot.replay_active Host.Load.Run.Prompt.P.oblog2818)
-- the JS bookkeeping's step (`Conv.JClean.step` over the changed list) and the canonical roots' bigint freedom
kernel_rfl PRE_first_tail_x15_r0_body.zjc61 : Conv.jcleanListB (⟨19412, 16503, 2723043, 2687⟩ : Conv.Cnt) PRE_first_tail_x15_r0_body.s601 PRE_first_tail_x15_r0_body.cl61 = true
kernel_rfl PRE_first_tail_x15_r0_body.zrootsB61 : noBigRootsP (fun i => !Conv.oldBigB (⟨19412, 16503, 2723043, 2687⟩ : Conv.Cnt) i) PRE_first_tail_x15_r0_body.s601.trace PRE_first_tail_x15_r0_body.s601 = true
kernel_rfl PRE_first_tail_x15_r0_body.zhm61 : Nat.ble (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s0.ffi).mlx.nnext 16503 = true
theorem PRE_first_tail_x15_r0_body.cjcl61 (h : Conv.JClean (⟨19412, 16503, 2723043, 2687⟩ : Conv.Cnt) PRE_first_tail_x15_r0_body.s599) : Conv.JClean (⟨19412, 16503, 2723043, 2687⟩ : Conv.Cnt) PRE_first_tail_x15_r0_body.s601 :=
  Conv.JClean.step h (Conv.Cnt.le_of_leB PRE_first_tail_x15_r0_body.cle61)
    (Conv.heap_off_setAll PRE_first_tail_x15_r0_body.cheap61 fun a ha => Nat.blt_eq.mp (List.all_eq_true.mp PRE_first_tail_x15_r0_body.zclbd61 a ha)) PRE_first_tail_x15_r0_body.zjc61

end Host.Load.Run.Tpl
