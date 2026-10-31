import host.sim.template.a4pre_first_tail_x15_r0_body.SiteS53
import host.sim.template.a4pre_first_tail_x15_r0_body.SiteK53
import host.sim.template.a4pre_first_tail_x15_r0_body.SiteF53
import host.sim.conv.CompactShift
import host.sim.template.Check
import host.sim.BigFreeP
import host.sim.template.CallGen
set_option Elab.async false
namespace Host.Load.Run.Tpl
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
open Host.Ts Host.Ts.Sim Host.Ts.Sim.Template

/-! The compaction's state shift at call site 53 of chain `PRE_first_tail_x15_r0_body` (`Conv.compact_shift`): the call `PRE_first_tail_x15_r0_body.s472`, the merged
state `PRE_first_tail_x15_r0_body.s473`, the canonical state `PRE_first_tail_x15_r0_body.s474`; its frames [2665,2673467,2673472,2673473] (kept arrays [2665,2673467]). -/

-- the map's places and counters
kernel_rfl PRE_first_tail_x15_r0_body.zpl53 : PRE_first_tail_x15_r0_body.pl53.all (Nat.ble PRE_first_tail_x15_r0_body.s472.next) = true
kernel_rfl PRE_first_tail_x15_r0_body.zplnd53 : nodupT PRE_first_tail_x15_r0_body.pl53 PTrie.nil = true
kernel_rfl PRE_first_tail_x15_r0_body.zn153 : Nat.ble PRE_first_tail_x15_r0_body.s472.next 2716187 = true
kernel_rfl PRE_first_tail_x15_r0_body.zfirst53 : Nat.ble aFirst PRE_first_tail_x15_r0_body.s472.next = true
kernel_rfl PRE_first_tail_x15_r0_body.zscn53 : PRE_first_tail_x15_r0_body.s474.next = PRE_first_tail_x15_r0_body.s472.next + PRE_first_tail_x15_r0_body.pl53.length
kernel_rfl PRE_first_tail_x15_r0_body.zsmn53 : PRE_first_tail_x15_r0_body.s473.next = 2716187
kernel_rfl PRE_first_tail_x15_r0_body.zgrow53 : Nat.ble PRE_first_tail_x15_r0_body.s474.next PRE_first_tail_x15_r0_body.s473.next = true
-- the tables
kernel_rfl PRE_first_tail_x15_r0_body.zfresh53 : PRE_first_tail_x15_r0_body.S472.tab.all (fun e => PRE_first_tail_x15_r0_body.cws53.all fun v => e.noVar v) = true
kernel_rfl PRE_first_tail_x15_r0_body.zcnd53 : nodupT PRE_first_tail_x15_r0_body.cws53 PTrie.nil = true
kernel_rfl PRE_first_tail_x15_r0_body.znrHi53 : PRE_first_tail_x15_r0_body.nr53.all (fun r => Nat.blt r PRE_first_tail_x15_r0_body.S473.tab.length) = true
-- the frames: every framed address below the call's counter; the kept arrays the chain start's, extended in the merged state
kernel_rfl PRE_first_tail_x15_r0_body.zfrlt53 : [2665, 2673467, 2673472, 2673473].all (fun a => Nat.blt a PRE_first_tail_x15_r0_body.s472.next) = true
kernel_rfl PRE_first_tail_x15_r0_body.zg53_2665 : PRE_first_tail_x15_r0_body.s474.heap.get 2665 = some (.obj (objOf PRE_first_tail_x15_r0_body.s474 2665))
kernel_rfl PRE_first_tail_x15_r0_body.zk53_2665 : (objOf PRE_first_tail_x15_r0_body.s474 2665).kind = .array (arrOf PRE_first_tail_x15_r0_body.s0 2665)
kernel_rfl PRE_first_tail_x15_r0_body.zm53_2665 : PRE_first_tail_x15_r0_body.s473.heap.get 2665 = some (.obj { PRE_first_tail_x15_r0_body.kappa53.obj (objOf PRE_first_tail_x15_r0_body.s474 2665) with
  kind := .array (arrOf PRE_first_tail_x15_r0_body.s0 2665 ++ (arrOf PRE_first_tail_x15_r0_body.s473 2665).drop (arrOf PRE_first_tail_x15_r0_body.s0 2665).length) })
kernel_rfl PRE_first_tail_x15_r0_body.zg53_2673467 : PRE_first_tail_x15_r0_body.s474.heap.get 2673467 = some (.obj (objOf PRE_first_tail_x15_r0_body.s474 2673467))
kernel_rfl PRE_first_tail_x15_r0_body.zk53_2673467 : (objOf PRE_first_tail_x15_r0_body.s474 2673467).kind = .array (arrOf PRE_first_tail_x15_r0_body.s0 2673467)
kernel_rfl PRE_first_tail_x15_r0_body.zm53_2673467 : PRE_first_tail_x15_r0_body.s473.heap.get 2673467 = some (.obj { PRE_first_tail_x15_r0_body.kappa53.obj (objOf PRE_first_tail_x15_r0_body.s474 2673467) with
  kind := .array (arrOf PRE_first_tail_x15_r0_body.s0 2673467 ++ (arrOf PRE_first_tail_x15_r0_body.s473 2673467).drop (arrOf PRE_first_tail_x15_r0_body.s0 2673467).length) })
kernel_rfl PRE_first_tail_x15_r0_body.zw53_4910 : (PRE_first_tail_x15_r0_body.s474.heap.get 4910).isSome = true
kernel_rfl PRE_first_tail_x15_r0_body.zw53_2673472 : (PRE_first_tail_x15_r0_body.s474.heap.get 2673472).isSome = true
kernel_rfl PRE_first_tail_x15_r0_body.zw53_2673473 : (PRE_first_tail_x15_r0_body.s474.heap.get 2673473).isSome = true
-- the heap: the changed list in range, holding the stage's written and fresh addresses; the canonical side's image
kernel_rfl PRE_first_tail_x15_r0_body.zclbd53 : PRE_first_tail_x15_r0_body.cl53.all (fun b => Nat.blt (b / 4096) (4 ^ 31)) = true
kernel_rfl PRE_first_tail_x15_r0_body.zwr53 : PRE_first_tail_x15_r0_body.st53.wr.all (fun b => !Nat.blt b PRE_first_tail_x15_r0_body.s472.next || PRE_first_tail_x15_r0_body.cl53.contains b) = true
def PRE_first_tail_x15_r0_body.zl53 : List Nat := PRE_first_tail_x15_r0_body.cl53.filter fun a => !(List.contains [2665, 2673467] a)
kernel_rfl PRE_first_tail_x15_r0_body.zimgE53 : PRE_first_tail_x15_r0_body.zl53.map (fun a => PRE_first_tail_x15_r0_body.s473.heap.get (PRE_first_tail_x15_r0_body.kappa53.a a)) = PRE_first_tail_x15_r0_body.zl53.map (fun a => (PRE_first_tail_x15_r0_body.s474.heap.get a).map PRE_first_tail_x15_r0_body.kappa53.hobj)
theorem PRE_first_tail_x15_r0_body.zimg53 : HeapImg PRE_first_tail_x15_r0_body.kappa53 PRE_first_tail_x15_r0_body.s474 PRE_first_tail_x15_r0_body.s473 PRE_first_tail_x15_r0_body.zl53 := PRE_first_tail_x15_r0_body.zimgE53
-- the roots and their supports
kernel_rfl PRE_first_tail_x15_r0_body.zctl53 : PRE_first_tail_x15_r0_body.s473.ctl = PRE_first_tail_x15_r0_body.kappa53.ctl PRE_first_tail_x15_r0_body.s474.ctl
kernel_rfl PRE_first_tail_x15_r0_body.zstack53 : PRE_first_tail_x15_r0_body.s473.stack = PRE_first_tail_x15_r0_body.s474.stack.map PRE_first_tail_x15_r0_body.kappa53.frame
kernel_rfl PRE_first_tail_x15_r0_body.zjobs53 : PRE_first_tail_x15_r0_body.s473.jobs = PRE_first_tail_x15_r0_body.s474.jobs.map PRE_first_tail_x15_r0_body.kappa53.job
kernel_rfl PRE_first_tail_x15_r0_body.zstores53 : PRE_first_tail_x15_r0_body.s473.stores = PRE_first_tail_x15_r0_body.kappa53.stores PRE_first_tail_x15_r0_body.s474.stores
kernel_rfl PRE_first_tail_x15_r0_body.zroots53 : checkRootsSupp PRE_first_tail_x15_r0_body.s474 2320 = true
kernel_rfl PRE_first_tail_x15_r0_body.znC53 : PRE_first_tail_x15_r0_body.S472.tab.length + PRE_first_tail_x15_r0_body.cws53.length = 2320
-- the map as `Conv.compact_shift` states it (the call's counters for the literals)
kernel_rfl PRE_first_tail_x15_r0_body.zkap53 : PRE_first_tail_x15_r0_body.kappa53 = Conv.Map.compact PRE_first_tail_x15_r0_body.s472.next 2716187 PRE_first_tail_x15_r0_body.S472.tab.length PRE_first_tail_x15_r0_body.pl53 (PRE_first_tail_x15_r0_body.nr53.map NumV.ref) PRE_first_tail_x15_r0_body.kd53.big
  PRE_first_tail_x15_r0_body.kd53.region PRE_first_tail_x15_r0_body.kd53.nodeF
-- the bridge inactive at the canonical state (`Conv.FullShiftQ.toX`; the merged state's bridge is the canonical's: cbridge)
theorem PRE_first_tail_x15_r0_body.zbin53 : (Host.Ts.Sim.Full.bridgeOf PRE_first_tail_x15_r0_body.s474.ffi).active = false := (Host.Load.Boot.replay_active Host.Load.Run.Prompt.P.oblog2818)
-- the JS bookkeeping's step (`Conv.JClean.step` over the changed list) and the canonical roots' bigint freedom
kernel_rfl PRE_first_tail_x15_r0_body.zjc53 : Conv.jcleanListB (⟨19240, 16333, 2716168, 2320⟩ : Conv.Cnt) PRE_first_tail_x15_r0_body.s474 PRE_first_tail_x15_r0_body.cl53 = true
kernel_rfl PRE_first_tail_x15_r0_body.zroots253 : noBigRootsP (fun i => !Conv.oldBigB (⟨19240, 16333, 2716168, 2320⟩ : Conv.Cnt) i) PRE_first_tail_x15_r0_body.s474.trace PRE_first_tail_x15_r0_body.s474 = true
kernel_rfl PRE_first_tail_x15_r0_body.zhm53 : Nat.ble (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s0.ffi).mlx.nnext 16333 = true
theorem PRE_first_tail_x15_r0_body.cjcl53 (h : Conv.JClean (⟨19240, 16333, 2716167, 2320⟩ : Conv.Cnt) PRE_first_tail_x15_r0_body.s472) : Conv.JClean (⟨19240, 16333, 2716168, 2320⟩ : Conv.Cnt) PRE_first_tail_x15_r0_body.s474 :=
  Conv.JClean.step h (Conv.Cnt.le_of_leB PRE_first_tail_x15_r0_body.cle53)
    (Conv.heap_off_setAll PRE_first_tail_x15_r0_body.cheap53 fun a ha => Nat.blt_eq.mp (List.all_eq_true.mp PRE_first_tail_x15_r0_body.zclbd53 a ha)) PRE_first_tail_x15_r0_body.zjc53

end Host.Load.Run.Tpl
