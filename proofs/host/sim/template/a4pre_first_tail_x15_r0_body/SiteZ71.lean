import host.sim.template.a4pre_first_tail_x15_r0_body.SiteS71
import host.sim.template.a4pre_first_tail_x15_r0_body.SiteK71
import host.sim.template.a4pre_first_tail_x15_r0_body.SiteF71
import host.sim.conv.CompactShift
import host.sim.template.Check
import host.sim.BigFreeP
import host.sim.template.CallGen
set_option Elab.async false
namespace Host.Load.Run.Tpl
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
open Host.Ts Host.Ts.Sim Host.Ts.Sim.Template

/-! The compaction's state shift at call site 71 of chain `PRE_first_tail_x15_r0_body` (`Conv.compact_shift`): the call `PRE_first_tail_x15_r0_body.s689`, the merged
state `PRE_first_tail_x15_r0_body.s690`, the canonical state `PRE_first_tail_x15_r0_body.s691`; its frames [2665,2673467,2673472,2673473] (kept arrays [2665,2673467]). -/

-- the map's places and counters
kernel_rfl PRE_first_tail_x15_r0_body.zpl71 : PRE_first_tail_x15_r0_body.pl71.all (Nat.ble PRE_first_tail_x15_r0_body.s689.next) = true
kernel_rfl PRE_first_tail_x15_r0_body.zplnd71 : nodupT PRE_first_tail_x15_r0_body.pl71 PTrie.nil = true
kernel_rfl PRE_first_tail_x15_r0_body.zn171 : Nat.ble PRE_first_tail_x15_r0_body.s689.next 2730476 = true
kernel_rfl PRE_first_tail_x15_r0_body.zfirst71 : Nat.ble aFirst PRE_first_tail_x15_r0_body.s689.next = true
kernel_rfl PRE_first_tail_x15_r0_body.zscn71 : PRE_first_tail_x15_r0_body.s691.next = PRE_first_tail_x15_r0_body.s689.next + PRE_first_tail_x15_r0_body.pl71.length
kernel_rfl PRE_first_tail_x15_r0_body.zsmn71 : PRE_first_tail_x15_r0_body.s690.next = 2730476
kernel_rfl PRE_first_tail_x15_r0_body.zgrow71 : Nat.ble PRE_first_tail_x15_r0_body.s691.next PRE_first_tail_x15_r0_body.s690.next = true
-- the tables
kernel_rfl PRE_first_tail_x15_r0_body.zfresh71 : PRE_first_tail_x15_r0_body.S689.tab.all (fun e => PRE_first_tail_x15_r0_body.cws71.all fun v => e.noVar v) = true
kernel_rfl PRE_first_tail_x15_r0_body.zcnd71 : nodupT PRE_first_tail_x15_r0_body.cws71 PTrie.nil = true
kernel_rfl PRE_first_tail_x15_r0_body.znrHi71 : PRE_first_tail_x15_r0_body.nr71.all (fun r => Nat.blt r PRE_first_tail_x15_r0_body.S690.tab.length) = true
-- the frames: every framed address below the call's counter; the kept arrays the chain start's, extended in the merged state
kernel_rfl PRE_first_tail_x15_r0_body.zfrlt71 : [2665, 2673467, 2673472, 2673473].all (fun a => Nat.blt a PRE_first_tail_x15_r0_body.s689.next) = true
kernel_rfl PRE_first_tail_x15_r0_body.zg71_2665 : PRE_first_tail_x15_r0_body.s691.heap.get 2665 = some (.obj (objOf PRE_first_tail_x15_r0_body.s691 2665))
kernel_rfl PRE_first_tail_x15_r0_body.zk71_2665 : (objOf PRE_first_tail_x15_r0_body.s691 2665).kind = .array (arrOf PRE_first_tail_x15_r0_body.s0 2665)
kernel_rfl PRE_first_tail_x15_r0_body.zm71_2665 : PRE_first_tail_x15_r0_body.s690.heap.get 2665 = some (.obj { PRE_first_tail_x15_r0_body.kappa71.obj (objOf PRE_first_tail_x15_r0_body.s691 2665) with
  kind := .array (arrOf PRE_first_tail_x15_r0_body.s0 2665 ++ (arrOf PRE_first_tail_x15_r0_body.s690 2665).drop (arrOf PRE_first_tail_x15_r0_body.s0 2665).length) })
kernel_rfl PRE_first_tail_x15_r0_body.zg71_2673467 : PRE_first_tail_x15_r0_body.s691.heap.get 2673467 = some (.obj (objOf PRE_first_tail_x15_r0_body.s691 2673467))
kernel_rfl PRE_first_tail_x15_r0_body.zk71_2673467 : (objOf PRE_first_tail_x15_r0_body.s691 2673467).kind = .array (arrOf PRE_first_tail_x15_r0_body.s0 2673467)
kernel_rfl PRE_first_tail_x15_r0_body.zm71_2673467 : PRE_first_tail_x15_r0_body.s690.heap.get 2673467 = some (.obj { PRE_first_tail_x15_r0_body.kappa71.obj (objOf PRE_first_tail_x15_r0_body.s691 2673467) with
  kind := .array (arrOf PRE_first_tail_x15_r0_body.s0 2673467 ++ (arrOf PRE_first_tail_x15_r0_body.s690 2673467).drop (arrOf PRE_first_tail_x15_r0_body.s0 2673467).length) })
kernel_rfl PRE_first_tail_x15_r0_body.zw71_4910 : (PRE_first_tail_x15_r0_body.s691.heap.get 4910).isSome = true
kernel_rfl PRE_first_tail_x15_r0_body.zw71_2673472 : (PRE_first_tail_x15_r0_body.s691.heap.get 2673472).isSome = true
kernel_rfl PRE_first_tail_x15_r0_body.zw71_2673473 : (PRE_first_tail_x15_r0_body.s691.heap.get 2673473).isSome = true
-- the heap: the changed list in range, holding the stage's written and fresh addresses; the canonical side's image
kernel_rfl PRE_first_tail_x15_r0_body.zclbd71 : PRE_first_tail_x15_r0_body.cl71.all (fun b => Nat.blt (b / 4096) (4 ^ 31)) = true
kernel_rfl PRE_first_tail_x15_r0_body.zwr71 : PRE_first_tail_x15_r0_body.st71.wr.all (fun b => !Nat.blt b PRE_first_tail_x15_r0_body.s689.next || PRE_first_tail_x15_r0_body.cl71.contains b) = true
def PRE_first_tail_x15_r0_body.zl71 : List Nat := PRE_first_tail_x15_r0_body.cl71.filter fun a => !(List.contains [2665, 2673467] a)
kernel_rfl PRE_first_tail_x15_r0_body.zimgE71 : PRE_first_tail_x15_r0_body.zl71.map (fun a => PRE_first_tail_x15_r0_body.s690.heap.get (PRE_first_tail_x15_r0_body.kappa71.a a)) = PRE_first_tail_x15_r0_body.zl71.map (fun a => (PRE_first_tail_x15_r0_body.s691.heap.get a).map PRE_first_tail_x15_r0_body.kappa71.hobj)
theorem PRE_first_tail_x15_r0_body.zimg71 : HeapImg PRE_first_tail_x15_r0_body.kappa71 PRE_first_tail_x15_r0_body.s691 PRE_first_tail_x15_r0_body.s690 PRE_first_tail_x15_r0_body.zl71 := PRE_first_tail_x15_r0_body.zimgE71
-- the roots and their supports
kernel_rfl PRE_first_tail_x15_r0_body.zctl71 : PRE_first_tail_x15_r0_body.s690.ctl = PRE_first_tail_x15_r0_body.kappa71.ctl PRE_first_tail_x15_r0_body.s691.ctl
kernel_rfl PRE_first_tail_x15_r0_body.zstack71 : PRE_first_tail_x15_r0_body.s690.stack = PRE_first_tail_x15_r0_body.s691.stack.map PRE_first_tail_x15_r0_body.kappa71.frame
kernel_rfl PRE_first_tail_x15_r0_body.zjobs71 : PRE_first_tail_x15_r0_body.s690.jobs = PRE_first_tail_x15_r0_body.s691.jobs.map PRE_first_tail_x15_r0_body.kappa71.job
kernel_rfl PRE_first_tail_x15_r0_body.zstores71 : PRE_first_tail_x15_r0_body.s690.stores = PRE_first_tail_x15_r0_body.kappa71.stores PRE_first_tail_x15_r0_body.s691.stores
kernel_rfl PRE_first_tail_x15_r0_body.zroots71 : checkRootsSupp PRE_first_tail_x15_r0_body.s691 3088 = true
kernel_rfl PRE_first_tail_x15_r0_body.znC71 : PRE_first_tail_x15_r0_body.S689.tab.length + PRE_first_tail_x15_r0_body.cws71.length = 3088
-- the map as `Conv.compact_shift` states it (the call's counters for the literals)
kernel_rfl PRE_first_tail_x15_r0_body.zkap71 : PRE_first_tail_x15_r0_body.kappa71 = Conv.Map.compact PRE_first_tail_x15_r0_body.s689.next 2730476 PRE_first_tail_x15_r0_body.S689.tab.length PRE_first_tail_x15_r0_body.pl71 (PRE_first_tail_x15_r0_body.nr71.map NumV.ref) PRE_first_tail_x15_r0_body.kd71.big
  PRE_first_tail_x15_r0_body.kd71.region PRE_first_tail_x15_r0_body.kd71.nodeF
-- the bridge inactive at the canonical state (`Conv.FullShiftQ.toX`; the merged state's bridge is the canonical's: cbridge)
theorem PRE_first_tail_x15_r0_body.zbin71 : (Host.Ts.Sim.Full.bridgeOf PRE_first_tail_x15_r0_body.s691.ffi).active = false := (Host.Load.Boot.replay_active Host.Load.Run.Prompt.P.oblog2818)
-- the JS bookkeeping's step (`Conv.JClean.step` over the changed list) and the canonical roots' bigint freedom
kernel_rfl PRE_first_tail_x15_r0_body.zjc71 : Conv.jcleanListB (⟨19597, 16681, 2730466, 3088⟩ : Conv.Cnt) PRE_first_tail_x15_r0_body.s691 PRE_first_tail_x15_r0_body.cl71 = true
kernel_rfl PRE_first_tail_x15_r0_body.zrootsB71 : noBigRootsP (fun i => !Conv.oldBigB (⟨19597, 16681, 2730466, 3088⟩ : Conv.Cnt) i) PRE_first_tail_x15_r0_body.s691.trace PRE_first_tail_x15_r0_body.s691 = true
kernel_rfl PRE_first_tail_x15_r0_body.zhm71 : Nat.ble (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s0.ffi).mlx.nnext 16681 = true
theorem PRE_first_tail_x15_r0_body.cjcl71 (h : Conv.JClean (⟨19597, 16681, 2730465, 3088⟩ : Conv.Cnt) PRE_first_tail_x15_r0_body.s689) : Conv.JClean (⟨19597, 16681, 2730466, 3088⟩ : Conv.Cnt) PRE_first_tail_x15_r0_body.s691 :=
  Conv.JClean.step h (Conv.Cnt.le_of_leB PRE_first_tail_x15_r0_body.cle71)
    (Conv.heap_off_setAll PRE_first_tail_x15_r0_body.cheap71 fun a ha => Nat.blt_eq.mp (List.all_eq_true.mp PRE_first_tail_x15_r0_body.zclbd71 a ha)) PRE_first_tail_x15_r0_body.zjc71

end Host.Load.Run.Tpl
