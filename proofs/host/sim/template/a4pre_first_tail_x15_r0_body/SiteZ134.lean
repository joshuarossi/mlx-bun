import host.sim.template.a4pre_first_tail_x15_r0_body.SiteS134
import host.sim.template.a4pre_first_tail_x15_r0_body.SiteK134
import host.sim.template.a4pre_first_tail_x15_r0_body.SiteF134
import host.sim.conv.CompactShift
import host.sim.template.Check
import host.sim.BigFreeP
import host.sim.template.CallGen
set_option Elab.async false
namespace Host.Load.Run.Tpl
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
open Host.Ts Host.Ts.Sim Host.Ts.Sim.Template

/-! The compaction's state shift at call site 134 of chain `PRE_first_tail_x15_r0_body` (`Conv.compact_shift`): the call `PRE_first_tail_x15_r0_body.s1293`, the merged
state `PRE_first_tail_x15_r0_body.s1294`, the canonical state `PRE_first_tail_x15_r0_body.s1295`; its frames [2665,2673467,2673472,2673473] (kept arrays [2665,2673467]). -/

-- the map's places and counters
kernel_rfl PRE_first_tail_x15_r0_body.zpl134 : PRE_first_tail_x15_r0_body.pl134.all (Nat.ble PRE_first_tail_x15_r0_body.s1293.next) = true
kernel_rfl PRE_first_tail_x15_r0_body.zplnd134 : nodupT PRE_first_tail_x15_r0_body.pl134 PTrie.nil = true
kernel_rfl PRE_first_tail_x15_r0_body.zn1134 : Nat.ble PRE_first_tail_x15_r0_body.s1293.next 2779830 = true
kernel_rfl PRE_first_tail_x15_r0_body.zfirst134 : Nat.ble aFirst PRE_first_tail_x15_r0_body.s1293.next = true
kernel_rfl PRE_first_tail_x15_r0_body.zscn134 : PRE_first_tail_x15_r0_body.s1295.next = PRE_first_tail_x15_r0_body.s1293.next + PRE_first_tail_x15_r0_body.pl134.length
kernel_rfl PRE_first_tail_x15_r0_body.zsmn134 : PRE_first_tail_x15_r0_body.s1294.next = 2779830
kernel_rfl PRE_first_tail_x15_r0_body.zgrow134 : Nat.ble PRE_first_tail_x15_r0_body.s1295.next PRE_first_tail_x15_r0_body.s1294.next = true
-- the tables
kernel_rfl PRE_first_tail_x15_r0_body.zfresh134 : PRE_first_tail_x15_r0_body.S1293.tab.all (fun e => PRE_first_tail_x15_r0_body.cws134.all fun v => e.noVar v) = true
kernel_rfl PRE_first_tail_x15_r0_body.zcnd134 : nodupT PRE_first_tail_x15_r0_body.cws134 PTrie.nil = true
kernel_rfl PRE_first_tail_x15_r0_body.znrHi134 : PRE_first_tail_x15_r0_body.nr134.all (fun r => Nat.blt r PRE_first_tail_x15_r0_body.S1294.tab.length) = true
-- the frames: every framed address below the call's counter; the kept arrays the chain start's, extended in the merged state
kernel_rfl PRE_first_tail_x15_r0_body.zfrlt134 : [2665, 2673467, 2673472, 2673473].all (fun a => Nat.blt a PRE_first_tail_x15_r0_body.s1293.next) = true
kernel_rfl PRE_first_tail_x15_r0_body.zg134_2665 : PRE_first_tail_x15_r0_body.s1295.heap.get 2665 = some (.obj (objOf PRE_first_tail_x15_r0_body.s1295 2665))
kernel_rfl PRE_first_tail_x15_r0_body.zk134_2665 : (objOf PRE_first_tail_x15_r0_body.s1295 2665).kind = .array (arrOf PRE_first_tail_x15_r0_body.s0 2665)
kernel_rfl PRE_first_tail_x15_r0_body.zm134_2665 : PRE_first_tail_x15_r0_body.s1294.heap.get 2665 = some (.obj { PRE_first_tail_x15_r0_body.kappa134.obj (objOf PRE_first_tail_x15_r0_body.s1295 2665) with
  kind := .array (arrOf PRE_first_tail_x15_r0_body.s0 2665 ++ (arrOf PRE_first_tail_x15_r0_body.s1294 2665).drop (arrOf PRE_first_tail_x15_r0_body.s0 2665).length) })
kernel_rfl PRE_first_tail_x15_r0_body.zg134_2673467 : PRE_first_tail_x15_r0_body.s1295.heap.get 2673467 = some (.obj (objOf PRE_first_tail_x15_r0_body.s1295 2673467))
kernel_rfl PRE_first_tail_x15_r0_body.zk134_2673467 : (objOf PRE_first_tail_x15_r0_body.s1295 2673467).kind = .array (arrOf PRE_first_tail_x15_r0_body.s0 2673467)
kernel_rfl PRE_first_tail_x15_r0_body.zm134_2673467 : PRE_first_tail_x15_r0_body.s1294.heap.get 2673467 = some (.obj { PRE_first_tail_x15_r0_body.kappa134.obj (objOf PRE_first_tail_x15_r0_body.s1295 2673467) with
  kind := .array (arrOf PRE_first_tail_x15_r0_body.s0 2673467 ++ (arrOf PRE_first_tail_x15_r0_body.s1294 2673467).drop (arrOf PRE_first_tail_x15_r0_body.s0 2673467).length) })
kernel_rfl PRE_first_tail_x15_r0_body.zw134_4910 : (PRE_first_tail_x15_r0_body.s1295.heap.get 4910).isSome = true
kernel_rfl PRE_first_tail_x15_r0_body.zw134_2673472 : (PRE_first_tail_x15_r0_body.s1295.heap.get 2673472).isSome = true
kernel_rfl PRE_first_tail_x15_r0_body.zw134_2673473 : (PRE_first_tail_x15_r0_body.s1295.heap.get 2673473).isSome = true
-- the heap: the changed list in range, holding the stage's written and fresh addresses; the canonical side's image
kernel_rfl PRE_first_tail_x15_r0_body.zclbd134 : PRE_first_tail_x15_r0_body.cl134.all (fun b => Nat.blt (b / 4096) (4 ^ 31)) = true
kernel_rfl PRE_first_tail_x15_r0_body.zwr134 : PRE_first_tail_x15_r0_body.st134.wr.all (fun b => !Nat.blt b PRE_first_tail_x15_r0_body.s1293.next || PRE_first_tail_x15_r0_body.cl134.contains b) = true
def PRE_first_tail_x15_r0_body.zl134 : List Nat := PRE_first_tail_x15_r0_body.cl134.filter fun a => !(List.contains [2665, 2673467] a)
kernel_rfl PRE_first_tail_x15_r0_body.zimgE134 : PRE_first_tail_x15_r0_body.zl134.map (fun a => PRE_first_tail_x15_r0_body.s1294.heap.get (PRE_first_tail_x15_r0_body.kappa134.a a)) = PRE_first_tail_x15_r0_body.zl134.map (fun a => (PRE_first_tail_x15_r0_body.s1295.heap.get a).map PRE_first_tail_x15_r0_body.kappa134.hobj)
theorem PRE_first_tail_x15_r0_body.zimg134 : HeapImg PRE_first_tail_x15_r0_body.kappa134 PRE_first_tail_x15_r0_body.s1295 PRE_first_tail_x15_r0_body.s1294 PRE_first_tail_x15_r0_body.zl134 := PRE_first_tail_x15_r0_body.zimgE134
-- the roots and their supports
kernel_rfl PRE_first_tail_x15_r0_body.zctl134 : PRE_first_tail_x15_r0_body.s1294.ctl = PRE_first_tail_x15_r0_body.kappa134.ctl PRE_first_tail_x15_r0_body.s1295.ctl
kernel_rfl PRE_first_tail_x15_r0_body.zstack134 : PRE_first_tail_x15_r0_body.s1294.stack = PRE_first_tail_x15_r0_body.s1295.stack.map PRE_first_tail_x15_r0_body.kappa134.frame
kernel_rfl PRE_first_tail_x15_r0_body.zjobs134 : PRE_first_tail_x15_r0_body.s1294.jobs = PRE_first_tail_x15_r0_body.s1295.jobs.map PRE_first_tail_x15_r0_body.kappa134.job
kernel_rfl PRE_first_tail_x15_r0_body.zstores134 : PRE_first_tail_x15_r0_body.s1294.stores = PRE_first_tail_x15_r0_body.kappa134.stores PRE_first_tail_x15_r0_body.s1295.stores
kernel_rfl PRE_first_tail_x15_r0_body.zroots134 : checkRootsSupp PRE_first_tail_x15_r0_body.s1295 5782 = true
kernel_rfl PRE_first_tail_x15_r0_body.znC134 : PRE_first_tail_x15_r0_body.S1293.tab.length + PRE_first_tail_x15_r0_body.cws134.length = 5782
-- the map as `Conv.compact_shift` states it (the call's counters for the literals)
kernel_rfl PRE_first_tail_x15_r0_body.zkap134 : PRE_first_tail_x15_r0_body.kappa134 = Conv.Map.compact PRE_first_tail_x15_r0_body.s1293.next 2779830 PRE_first_tail_x15_r0_body.S1293.tab.length PRE_first_tail_x15_r0_body.pl134 (PRE_first_tail_x15_r0_body.nr134.map NumV.ref) PRE_first_tail_x15_r0_body.kd134.big
  PRE_first_tail_x15_r0_body.kd134.region PRE_first_tail_x15_r0_body.kd134.nodeF
-- the bridge inactive at the canonical state (`Conv.FullShiftQ.toX`; the merged state's bridge is the canonical's: cbridge)
theorem PRE_first_tail_x15_r0_body.zbin134 : (Host.Ts.Sim.Full.bridgeOf PRE_first_tail_x15_r0_body.s1295.ffi).active = false := (Host.Load.Boot.replay_active Host.Load.Run.Prompt.P.oblog2818)
-- the JS bookkeeping's step (`Conv.JClean.step` over the changed list) and the canonical roots' bigint freedom
kernel_rfl PRE_first_tail_x15_r0_body.zjc134 : Conv.jcleanListB (⟨20835, 17929, 2779820, 5782⟩ : Conv.Cnt) PRE_first_tail_x15_r0_body.s1295 PRE_first_tail_x15_r0_body.cl134 = true
kernel_rfl PRE_first_tail_x15_r0_body.zrootsB134 : noBigRootsP (fun i => !Conv.oldBigB (⟨20835, 17929, 2779820, 5782⟩ : Conv.Cnt) i) PRE_first_tail_x15_r0_body.s1295.trace PRE_first_tail_x15_r0_body.s1295 = true
kernel_rfl PRE_first_tail_x15_r0_body.zhm134 : Nat.ble (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s0.ffi).mlx.nnext 17929 = true
theorem PRE_first_tail_x15_r0_body.cjcl134 (h : Conv.JClean (⟨20835, 17929, 2779819, 5782⟩ : Conv.Cnt) PRE_first_tail_x15_r0_body.s1293) : Conv.JClean (⟨20835, 17929, 2779820, 5782⟩ : Conv.Cnt) PRE_first_tail_x15_r0_body.s1295 :=
  Conv.JClean.step h (Conv.Cnt.le_of_leB PRE_first_tail_x15_r0_body.cle134)
    (Conv.heap_off_setAll PRE_first_tail_x15_r0_body.cheap134 fun a ha => Nat.blt_eq.mp (List.all_eq_true.mp PRE_first_tail_x15_r0_body.zclbd134 a ha)) PRE_first_tail_x15_r0_body.zjc134

end Host.Load.Run.Tpl
