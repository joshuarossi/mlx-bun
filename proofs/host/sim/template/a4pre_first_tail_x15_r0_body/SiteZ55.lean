import host.sim.template.a4pre_first_tail_x15_r0_body.SiteS55
import host.sim.template.a4pre_first_tail_x15_r0_body.SiteK55
import host.sim.template.a4pre_first_tail_x15_r0_body.SiteF55
import host.sim.conv.CompactShift
import host.sim.template.Check
import host.sim.BigFreeP
import host.sim.template.CallGen
set_option Elab.async false
namespace Host.Load.Run.Tpl
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
open Host.Ts Host.Ts.Sim Host.Ts.Sim.Template

/-! The compaction's state shift at call site 55 of chain `PRE_first_tail_x15_r0_body` (`Conv.compact_shift`): the call `PRE_first_tail_x15_r0_body.s495`, the merged
state `PRE_first_tail_x15_r0_body.s496`, the canonical state `PRE_first_tail_x15_r0_body.s497`; its frames [2665,2673467,2673472,2673473] (kept arrays [2665,2673467]). -/

-- the map's places and counters
kernel_rfl PRE_first_tail_x15_r0_body.zpl55 : PRE_first_tail_x15_r0_body.pl55.all (Nat.ble PRE_first_tail_x15_r0_body.s495.next) = true
kernel_rfl PRE_first_tail_x15_r0_body.zplnd55 : nodupT PRE_first_tail_x15_r0_body.pl55 PTrie.nil = true
kernel_rfl PRE_first_tail_x15_r0_body.zn155 : Nat.ble PRE_first_tail_x15_r0_body.s495.next 2718141 = true
kernel_rfl PRE_first_tail_x15_r0_body.zfirst55 : Nat.ble aFirst PRE_first_tail_x15_r0_body.s495.next = true
kernel_rfl PRE_first_tail_x15_r0_body.zscn55 : PRE_first_tail_x15_r0_body.s497.next = PRE_first_tail_x15_r0_body.s495.next + PRE_first_tail_x15_r0_body.pl55.length
kernel_rfl PRE_first_tail_x15_r0_body.zsmn55 : PRE_first_tail_x15_r0_body.s496.next = 2718141
kernel_rfl PRE_first_tail_x15_r0_body.zgrow55 : Nat.ble PRE_first_tail_x15_r0_body.s497.next PRE_first_tail_x15_r0_body.s496.next = true
-- the tables
kernel_rfl PRE_first_tail_x15_r0_body.zfresh55 : PRE_first_tail_x15_r0_body.S495.tab.all (fun e => PRE_first_tail_x15_r0_body.cws55.all fun v => e.noVar v) = true
kernel_rfl PRE_first_tail_x15_r0_body.zcnd55 : nodupT PRE_first_tail_x15_r0_body.cws55 PTrie.nil = true
kernel_rfl PRE_first_tail_x15_r0_body.znrHi55 : PRE_first_tail_x15_r0_body.nr55.all (fun r => Nat.blt r PRE_first_tail_x15_r0_body.S496.tab.length) = true
-- the frames: every framed address below the call's counter; the kept arrays the chain start's, extended in the merged state
kernel_rfl PRE_first_tail_x15_r0_body.zfrlt55 : [2665, 2673467, 2673472, 2673473].all (fun a => Nat.blt a PRE_first_tail_x15_r0_body.s495.next) = true
kernel_rfl PRE_first_tail_x15_r0_body.zg55_2665 : PRE_first_tail_x15_r0_body.s497.heap.get 2665 = some (.obj (objOf PRE_first_tail_x15_r0_body.s497 2665))
kernel_rfl PRE_first_tail_x15_r0_body.zk55_2665 : (objOf PRE_first_tail_x15_r0_body.s497 2665).kind = .array (arrOf PRE_first_tail_x15_r0_body.s0 2665)
kernel_rfl PRE_first_tail_x15_r0_body.zm55_2665 : PRE_first_tail_x15_r0_body.s496.heap.get 2665 = some (.obj { PRE_first_tail_x15_r0_body.kappa55.obj (objOf PRE_first_tail_x15_r0_body.s497 2665) with
  kind := .array (arrOf PRE_first_tail_x15_r0_body.s0 2665 ++ (arrOf PRE_first_tail_x15_r0_body.s496 2665).drop (arrOf PRE_first_tail_x15_r0_body.s0 2665).length) })
kernel_rfl PRE_first_tail_x15_r0_body.zg55_2673467 : PRE_first_tail_x15_r0_body.s497.heap.get 2673467 = some (.obj (objOf PRE_first_tail_x15_r0_body.s497 2673467))
kernel_rfl PRE_first_tail_x15_r0_body.zk55_2673467 : (objOf PRE_first_tail_x15_r0_body.s497 2673467).kind = .array (arrOf PRE_first_tail_x15_r0_body.s0 2673467)
kernel_rfl PRE_first_tail_x15_r0_body.zm55_2673467 : PRE_first_tail_x15_r0_body.s496.heap.get 2673467 = some (.obj { PRE_first_tail_x15_r0_body.kappa55.obj (objOf PRE_first_tail_x15_r0_body.s497 2673467) with
  kind := .array (arrOf PRE_first_tail_x15_r0_body.s0 2673467 ++ (arrOf PRE_first_tail_x15_r0_body.s496 2673467).drop (arrOf PRE_first_tail_x15_r0_body.s0 2673467).length) })
kernel_rfl PRE_first_tail_x15_r0_body.zw55_4910 : (PRE_first_tail_x15_r0_body.s497.heap.get 4910).isSome = true
kernel_rfl PRE_first_tail_x15_r0_body.zw55_2673472 : (PRE_first_tail_x15_r0_body.s497.heap.get 2673472).isSome = true
kernel_rfl PRE_first_tail_x15_r0_body.zw55_2673473 : (PRE_first_tail_x15_r0_body.s497.heap.get 2673473).isSome = true
-- the heap: the changed list in range, holding the stage's written and fresh addresses; the canonical side's image
kernel_rfl PRE_first_tail_x15_r0_body.zclbd55 : PRE_first_tail_x15_r0_body.cl55.all (fun b => Nat.blt (b / 4096) (4 ^ 31)) = true
kernel_rfl PRE_first_tail_x15_r0_body.zwr55 : PRE_first_tail_x15_r0_body.st55.wr.all (fun b => !Nat.blt b PRE_first_tail_x15_r0_body.s495.next || PRE_first_tail_x15_r0_body.cl55.contains b) = true
def PRE_first_tail_x15_r0_body.zl55 : List Nat := PRE_first_tail_x15_r0_body.cl55.filter fun a => !(List.contains [2665, 2673467] a)
kernel_rfl PRE_first_tail_x15_r0_body.zimgE55 : PRE_first_tail_x15_r0_body.zl55.map (fun a => PRE_first_tail_x15_r0_body.s496.heap.get (PRE_first_tail_x15_r0_body.kappa55.a a)) = PRE_first_tail_x15_r0_body.zl55.map (fun a => (PRE_first_tail_x15_r0_body.s497.heap.get a).map PRE_first_tail_x15_r0_body.kappa55.hobj)
theorem PRE_first_tail_x15_r0_body.zimg55 : HeapImg PRE_first_tail_x15_r0_body.kappa55 PRE_first_tail_x15_r0_body.s497 PRE_first_tail_x15_r0_body.s496 PRE_first_tail_x15_r0_body.zl55 := PRE_first_tail_x15_r0_body.zimgE55
-- the roots and their supports
kernel_rfl PRE_first_tail_x15_r0_body.zctl55 : PRE_first_tail_x15_r0_body.s496.ctl = PRE_first_tail_x15_r0_body.kappa55.ctl PRE_first_tail_x15_r0_body.s497.ctl
kernel_rfl PRE_first_tail_x15_r0_body.zstack55 : PRE_first_tail_x15_r0_body.s496.stack = PRE_first_tail_x15_r0_body.s497.stack.map PRE_first_tail_x15_r0_body.kappa55.frame
kernel_rfl PRE_first_tail_x15_r0_body.zjobs55 : PRE_first_tail_x15_r0_body.s496.jobs = PRE_first_tail_x15_r0_body.s497.jobs.map PRE_first_tail_x15_r0_body.kappa55.job
kernel_rfl PRE_first_tail_x15_r0_body.zstores55 : PRE_first_tail_x15_r0_body.s496.stores = PRE_first_tail_x15_r0_body.kappa55.stores PRE_first_tail_x15_r0_body.s497.stores
kernel_rfl PRE_first_tail_x15_r0_body.zroots55 : checkRootsSupp PRE_first_tail_x15_r0_body.s497 2432 = true
kernel_rfl PRE_first_tail_x15_r0_body.znC55 : PRE_first_tail_x15_r0_body.S495.tab.length + PRE_first_tail_x15_r0_body.cws55.length = 2432
-- the map as `Conv.compact_shift` states it (the call's counters for the literals)
kernel_rfl PRE_first_tail_x15_r0_body.zkap55 : PRE_first_tail_x15_r0_body.kappa55 = Conv.Map.compact PRE_first_tail_x15_r0_body.s495.next 2718141 PRE_first_tail_x15_r0_body.S495.tab.length PRE_first_tail_x15_r0_body.pl55 (PRE_first_tail_x15_r0_body.nr55.map NumV.ref) PRE_first_tail_x15_r0_body.kd55.big
  PRE_first_tail_x15_r0_body.kd55.region PRE_first_tail_x15_r0_body.kd55.nodeF
-- the bridge inactive at the canonical state (`Conv.FullShiftQ.toX`; the merged state's bridge is the canonical's: cbridge)
theorem PRE_first_tail_x15_r0_body.zbin55 : (Host.Ts.Sim.Full.bridgeOf PRE_first_tail_x15_r0_body.s497.ffi).active = false := (Host.Load.Boot.replay_active Host.Load.Run.Prompt.P.oblog2818)
-- the JS bookkeeping's step (`Conv.JClean.step` over the changed list) and the canonical roots' bigint freedom
kernel_rfl PRE_first_tail_x15_r0_body.zjc55 : Conv.jcleanListB (⟨19290, 16392, 2718139, 2432⟩ : Conv.Cnt) PRE_first_tail_x15_r0_body.s497 PRE_first_tail_x15_r0_body.cl55 = true
kernel_rfl PRE_first_tail_x15_r0_body.zroots255 : noBigRootsP (fun i => !Conv.oldBigB (⟨19290, 16392, 2718139, 2432⟩ : Conv.Cnt) i) PRE_first_tail_x15_r0_body.s497.trace PRE_first_tail_x15_r0_body.s497 = true
kernel_rfl PRE_first_tail_x15_r0_body.zhm55 : Nat.ble (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s0.ffi).mlx.nnext 16392 = true
theorem PRE_first_tail_x15_r0_body.cjcl55 (h : Conv.JClean (⟨19290, 16392, 2718139, 2432⟩ : Conv.Cnt) PRE_first_tail_x15_r0_body.s495) : Conv.JClean (⟨19290, 16392, 2718139, 2432⟩ : Conv.Cnt) PRE_first_tail_x15_r0_body.s497 :=
  Conv.JClean.step h (Conv.Cnt.le_of_leB PRE_first_tail_x15_r0_body.cle55)
    (Conv.heap_off_setAll PRE_first_tail_x15_r0_body.cheap55 fun a ha => Nat.blt_eq.mp (List.all_eq_true.mp PRE_first_tail_x15_r0_body.zclbd55 a ha)) PRE_first_tail_x15_r0_body.zjc55

end Host.Load.Run.Tpl
