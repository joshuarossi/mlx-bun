import host.sim.template.a4pre_first_tail_x15_r0_body.SiteS119
import host.sim.template.a4pre_first_tail_x15_r0_body.SiteK119
import host.sim.template.a4pre_first_tail_x15_r0_body.SiteF119
import host.sim.conv.CompactShift
import host.sim.template.Check
import host.sim.BigFreeP
import host.sim.template.CallGen
set_option Elab.async false
namespace Host.Load.Run.Tpl
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
open Host.Ts Host.Ts.Sim Host.Ts.Sim.Template

/-! The compaction's state shift at call site 119 of chain `PRE_first_tail_x15_r0_body` (`Conv.compact_shift`): the call `PRE_first_tail_x15_r0_body.s1149`, the merged
state `PRE_first_tail_x15_r0_body.s1150`, the canonical state `PRE_first_tail_x15_r0_body.s1151`; its frames [2665,2673467,2673472,2673473] (kept arrays [2665,2673467]). -/

-- the map's places and counters
kernel_rfl PRE_first_tail_x15_r0_body.zpl119 : PRE_first_tail_x15_r0_body.pl119.all (Nat.ble PRE_first_tail_x15_r0_body.s1149.next) = true
kernel_rfl PRE_first_tail_x15_r0_body.zplnd119 : nodupT PRE_first_tail_x15_r0_body.pl119 PTrie.nil = true
kernel_rfl PRE_first_tail_x15_r0_body.zn1119 : Nat.ble PRE_first_tail_x15_r0_body.s1149.next 2768140 = true
kernel_rfl PRE_first_tail_x15_r0_body.zfirst119 : Nat.ble aFirst PRE_first_tail_x15_r0_body.s1149.next = true
kernel_rfl PRE_first_tail_x15_r0_body.zscn119 : PRE_first_tail_x15_r0_body.s1151.next = PRE_first_tail_x15_r0_body.s1149.next + PRE_first_tail_x15_r0_body.pl119.length
kernel_rfl PRE_first_tail_x15_r0_body.zsmn119 : PRE_first_tail_x15_r0_body.s1150.next = 2768140
kernel_rfl PRE_first_tail_x15_r0_body.zgrow119 : Nat.ble PRE_first_tail_x15_r0_body.s1151.next PRE_first_tail_x15_r0_body.s1150.next = true
-- the tables
kernel_rfl PRE_first_tail_x15_r0_body.zfresh119 : PRE_first_tail_x15_r0_body.S1149.tab.all (fun e => PRE_first_tail_x15_r0_body.cws119.all fun v => e.noVar v) = true
kernel_rfl PRE_first_tail_x15_r0_body.zcnd119 : nodupT PRE_first_tail_x15_r0_body.cws119 PTrie.nil = true
kernel_rfl PRE_first_tail_x15_r0_body.znrHi119 : PRE_first_tail_x15_r0_body.nr119.all (fun r => Nat.blt r PRE_first_tail_x15_r0_body.S1150.tab.length) = true
-- the frames: every framed address below the call's counter; the kept arrays the chain start's, extended in the merged state
kernel_rfl PRE_first_tail_x15_r0_body.zfrlt119 : [2665, 2673467, 2673472, 2673473].all (fun a => Nat.blt a PRE_first_tail_x15_r0_body.s1149.next) = true
kernel_rfl PRE_first_tail_x15_r0_body.zg119_2665 : PRE_first_tail_x15_r0_body.s1151.heap.get 2665 = some (.obj (objOf PRE_first_tail_x15_r0_body.s1151 2665))
kernel_rfl PRE_first_tail_x15_r0_body.zk119_2665 : (objOf PRE_first_tail_x15_r0_body.s1151 2665).kind = .array (arrOf PRE_first_tail_x15_r0_body.s0 2665)
kernel_rfl PRE_first_tail_x15_r0_body.zm119_2665 : PRE_first_tail_x15_r0_body.s1150.heap.get 2665 = some (.obj { PRE_first_tail_x15_r0_body.kappa119.obj (objOf PRE_first_tail_x15_r0_body.s1151 2665) with
  kind := .array (arrOf PRE_first_tail_x15_r0_body.s0 2665 ++ (arrOf PRE_first_tail_x15_r0_body.s1150 2665).drop (arrOf PRE_first_tail_x15_r0_body.s0 2665).length) })
kernel_rfl PRE_first_tail_x15_r0_body.zg119_2673467 : PRE_first_tail_x15_r0_body.s1151.heap.get 2673467 = some (.obj (objOf PRE_first_tail_x15_r0_body.s1151 2673467))
kernel_rfl PRE_first_tail_x15_r0_body.zk119_2673467 : (objOf PRE_first_tail_x15_r0_body.s1151 2673467).kind = .array (arrOf PRE_first_tail_x15_r0_body.s0 2673467)
kernel_rfl PRE_first_tail_x15_r0_body.zm119_2673467 : PRE_first_tail_x15_r0_body.s1150.heap.get 2673467 = some (.obj { PRE_first_tail_x15_r0_body.kappa119.obj (objOf PRE_first_tail_x15_r0_body.s1151 2673467) with
  kind := .array (arrOf PRE_first_tail_x15_r0_body.s0 2673467 ++ (arrOf PRE_first_tail_x15_r0_body.s1150 2673467).drop (arrOf PRE_first_tail_x15_r0_body.s0 2673467).length) })
kernel_rfl PRE_first_tail_x15_r0_body.zw119_4910 : (PRE_first_tail_x15_r0_body.s1151.heap.get 4910).isSome = true
kernel_rfl PRE_first_tail_x15_r0_body.zw119_2673472 : (PRE_first_tail_x15_r0_body.s1151.heap.get 2673472).isSome = true
kernel_rfl PRE_first_tail_x15_r0_body.zw119_2673473 : (PRE_first_tail_x15_r0_body.s1151.heap.get 2673473).isSome = true
-- the heap: the changed list in range, holding the stage's written and fresh addresses; the canonical side's image
kernel_rfl PRE_first_tail_x15_r0_body.zclbd119 : PRE_first_tail_x15_r0_body.cl119.all (fun b => Nat.blt (b / 4096) (4 ^ 31)) = true
kernel_rfl PRE_first_tail_x15_r0_body.zwr119 : PRE_first_tail_x15_r0_body.st119.wr.all (fun b => !Nat.blt b PRE_first_tail_x15_r0_body.s1149.next || PRE_first_tail_x15_r0_body.cl119.contains b) = true
def PRE_first_tail_x15_r0_body.zl119 : List Nat := PRE_first_tail_x15_r0_body.cl119.filter fun a => !(List.contains [2665, 2673467] a)
kernel_rfl PRE_first_tail_x15_r0_body.zimgE119 : PRE_first_tail_x15_r0_body.zl119.map (fun a => PRE_first_tail_x15_r0_body.s1150.heap.get (PRE_first_tail_x15_r0_body.kappa119.a a)) = PRE_first_tail_x15_r0_body.zl119.map (fun a => (PRE_first_tail_x15_r0_body.s1151.heap.get a).map PRE_first_tail_x15_r0_body.kappa119.hobj)
theorem PRE_first_tail_x15_r0_body.zimg119 : HeapImg PRE_first_tail_x15_r0_body.kappa119 PRE_first_tail_x15_r0_body.s1151 PRE_first_tail_x15_r0_body.s1150 PRE_first_tail_x15_r0_body.zl119 := PRE_first_tail_x15_r0_body.zimgE119
-- the roots and their supports
kernel_rfl PRE_first_tail_x15_r0_body.zctl119 : PRE_first_tail_x15_r0_body.s1150.ctl = PRE_first_tail_x15_r0_body.kappa119.ctl PRE_first_tail_x15_r0_body.s1151.ctl
kernel_rfl PRE_first_tail_x15_r0_body.zstack119 : PRE_first_tail_x15_r0_body.s1150.stack = PRE_first_tail_x15_r0_body.s1151.stack.map PRE_first_tail_x15_r0_body.kappa119.frame
kernel_rfl PRE_first_tail_x15_r0_body.zjobs119 : PRE_first_tail_x15_r0_body.s1150.jobs = PRE_first_tail_x15_r0_body.s1151.jobs.map PRE_first_tail_x15_r0_body.kappa119.job
kernel_rfl PRE_first_tail_x15_r0_body.zstores119 : PRE_first_tail_x15_r0_body.s1150.stores = PRE_first_tail_x15_r0_body.kappa119.stores PRE_first_tail_x15_r0_body.s1151.stores
kernel_rfl PRE_first_tail_x15_r0_body.zroots119 : checkRootsSupp PRE_first_tail_x15_r0_body.s1151 5140 = true
kernel_rfl PRE_first_tail_x15_r0_body.znC119 : PRE_first_tail_x15_r0_body.S1149.tab.length + PRE_first_tail_x15_r0_body.cws119.length = 5140
-- the map as `Conv.compact_shift` states it (the call's counters for the literals)
kernel_rfl PRE_first_tail_x15_r0_body.zkap119 : PRE_first_tail_x15_r0_body.kappa119 = Conv.Map.compact PRE_first_tail_x15_r0_body.s1149.next 2768140 PRE_first_tail_x15_r0_body.S1149.tab.length PRE_first_tail_x15_r0_body.pl119 (PRE_first_tail_x15_r0_body.nr119.map NumV.ref) PRE_first_tail_x15_r0_body.kd119.big
  PRE_first_tail_x15_r0_body.kd119.region PRE_first_tail_x15_r0_body.kd119.nodeF
-- the bridge inactive at the canonical state (`Conv.FullShiftQ.toX`; the merged state's bridge is the canonical's: cbridge)
theorem PRE_first_tail_x15_r0_body.zbin119 : (Host.Ts.Sim.Full.bridgeOf PRE_first_tail_x15_r0_body.s1151.ffi).active = false := (Host.Load.Boot.replay_active Host.Load.Run.Prompt.P.oblog2818)
-- the JS bookkeeping's step (`Conv.JClean.step` over the changed list) and the canonical roots' bigint freedom
kernel_rfl PRE_first_tail_x15_r0_body.zjc119 : Conv.jcleanListB (⟨20541, 17629, 2768130, 5140⟩ : Conv.Cnt) PRE_first_tail_x15_r0_body.s1151 PRE_first_tail_x15_r0_body.cl119 = true
kernel_rfl PRE_first_tail_x15_r0_body.zrootsB119 : noBigRootsP (fun i => !Conv.oldBigB (⟨20541, 17629, 2768130, 5140⟩ : Conv.Cnt) i) PRE_first_tail_x15_r0_body.s1151.trace PRE_first_tail_x15_r0_body.s1151 = true
kernel_rfl PRE_first_tail_x15_r0_body.zhm119 : Nat.ble (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s0.ffi).mlx.nnext 17629 = true
theorem PRE_first_tail_x15_r0_body.cjcl119 (h : Conv.JClean (⟨20541, 17629, 2768129, 5140⟩ : Conv.Cnt) PRE_first_tail_x15_r0_body.s1149) : Conv.JClean (⟨20541, 17629, 2768130, 5140⟩ : Conv.Cnt) PRE_first_tail_x15_r0_body.s1151 :=
  Conv.JClean.step h (Conv.Cnt.le_of_leB PRE_first_tail_x15_r0_body.cle119)
    (Conv.heap_off_setAll PRE_first_tail_x15_r0_body.cheap119 fun a ha => Nat.blt_eq.mp (List.all_eq_true.mp PRE_first_tail_x15_r0_body.zclbd119 a ha)) PRE_first_tail_x15_r0_body.zjc119

end Host.Load.Run.Tpl
