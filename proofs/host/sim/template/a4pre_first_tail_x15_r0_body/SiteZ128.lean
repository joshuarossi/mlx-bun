import host.sim.template.a4pre_first_tail_x15_r0_body.SiteS128
import host.sim.template.a4pre_first_tail_x15_r0_body.SiteK128
import host.sim.template.a4pre_first_tail_x15_r0_body.SiteF128
import host.sim.conv.CompactShift
import host.sim.template.Check
import host.sim.BigFreeP
import host.sim.template.CallGen
set_option Elab.async false
namespace Host.Load.Run.Tpl
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
open Host.Ts Host.Ts.Sim Host.Ts.Sim.Template

/-! The compaction's state shift at call site 128 of chain `PRE_first_tail_x15_r0_body` (`Conv.compact_shift`): the call `PRE_first_tail_x15_r0_body.s1129`, the merged
state `PRE_first_tail_x15_r0_body.s1130`, the canonical state `PRE_first_tail_x15_r0_body.s1131`; its frames [2665,2673467,2673472,2673473] (kept arrays [2665,2673467]). -/

-- the map's places and counters
kernel_rfl PRE_first_tail_x15_r0_body.zpl128 : PRE_first_tail_x15_r0_body.pl128.all (Nat.ble PRE_first_tail_x15_r0_body.s1129.next) = true
kernel_rfl PRE_first_tail_x15_r0_body.zplnd128 : nodupT PRE_first_tail_x15_r0_body.pl128 PTrie.nil = true
kernel_rfl PRE_first_tail_x15_r0_body.zn1128 : Nat.ble PRE_first_tail_x15_r0_body.s1129.next 2774930 = true
kernel_rfl PRE_first_tail_x15_r0_body.zfirst128 : Nat.ble aFirst PRE_first_tail_x15_r0_body.s1129.next = true
kernel_rfl PRE_first_tail_x15_r0_body.zscn128 : PRE_first_tail_x15_r0_body.s1131.next = PRE_first_tail_x15_r0_body.s1129.next + PRE_first_tail_x15_r0_body.pl128.length
kernel_rfl PRE_first_tail_x15_r0_body.zsmn128 : PRE_first_tail_x15_r0_body.s1130.next = 2774930
kernel_rfl PRE_first_tail_x15_r0_body.zgrow128 : Nat.ble PRE_first_tail_x15_r0_body.s1131.next PRE_first_tail_x15_r0_body.s1130.next = true
-- the tables
kernel_rfl PRE_first_tail_x15_r0_body.zfresh128 : PRE_first_tail_x15_r0_body.S1129.tab.all (fun e => PRE_first_tail_x15_r0_body.cws128.all fun v => e.noVar v) = true
kernel_rfl PRE_first_tail_x15_r0_body.zcnd128 : nodupT PRE_first_tail_x15_r0_body.cws128 PTrie.nil = true
kernel_rfl PRE_first_tail_x15_r0_body.znrHi128 : PRE_first_tail_x15_r0_body.nr128.all (fun r => Nat.blt r PRE_first_tail_x15_r0_body.S1130.tab.length) = true
-- the frames: every framed address below the call's counter; the kept arrays the chain start's, extended in the merged state
kernel_rfl PRE_first_tail_x15_r0_body.zfrlt128 : [2665, 2673467, 2673472, 2673473].all (fun a => Nat.blt a PRE_first_tail_x15_r0_body.s1129.next) = true
kernel_rfl PRE_first_tail_x15_r0_body.zg128_2665 : PRE_first_tail_x15_r0_body.s1131.heap.get 2665 = some (.obj (objOf PRE_first_tail_x15_r0_body.s1131 2665))
kernel_rfl PRE_first_tail_x15_r0_body.zk128_2665 : (objOf PRE_first_tail_x15_r0_body.s1131 2665).kind = .array (arrOf PRE_first_tail_x15_r0_body.s0 2665)
kernel_rfl PRE_first_tail_x15_r0_body.zm128_2665 : PRE_first_tail_x15_r0_body.s1130.heap.get 2665 = some (.obj { PRE_first_tail_x15_r0_body.kappa128.obj (objOf PRE_first_tail_x15_r0_body.s1131 2665) with
  kind := .array (arrOf PRE_first_tail_x15_r0_body.s0 2665 ++ (arrOf PRE_first_tail_x15_r0_body.s1130 2665).drop (arrOf PRE_first_tail_x15_r0_body.s0 2665).length) })
kernel_rfl PRE_first_tail_x15_r0_body.zg128_2673467 : PRE_first_tail_x15_r0_body.s1131.heap.get 2673467 = some (.obj (objOf PRE_first_tail_x15_r0_body.s1131 2673467))
kernel_rfl PRE_first_tail_x15_r0_body.zk128_2673467 : (objOf PRE_first_tail_x15_r0_body.s1131 2673467).kind = .array (arrOf PRE_first_tail_x15_r0_body.s0 2673467)
kernel_rfl PRE_first_tail_x15_r0_body.zm128_2673467 : PRE_first_tail_x15_r0_body.s1130.heap.get 2673467 = some (.obj { PRE_first_tail_x15_r0_body.kappa128.obj (objOf PRE_first_tail_x15_r0_body.s1131 2673467) with
  kind := .array (arrOf PRE_first_tail_x15_r0_body.s0 2673467 ++ (arrOf PRE_first_tail_x15_r0_body.s1130 2673467).drop (arrOf PRE_first_tail_x15_r0_body.s0 2673467).length) })
kernel_rfl PRE_first_tail_x15_r0_body.zw128_4910 : (PRE_first_tail_x15_r0_body.s1131.heap.get 4910).isSome = true
kernel_rfl PRE_first_tail_x15_r0_body.zw128_2673472 : (PRE_first_tail_x15_r0_body.s1131.heap.get 2673472).isSome = true
kernel_rfl PRE_first_tail_x15_r0_body.zw128_2673473 : (PRE_first_tail_x15_r0_body.s1131.heap.get 2673473).isSome = true
-- the heap: the changed list in range, holding the stage's written and fresh addresses; the canonical side's image
kernel_rfl PRE_first_tail_x15_r0_body.zclbd128 : PRE_first_tail_x15_r0_body.cl128.all (fun b => Nat.blt (b / 4096) (4 ^ 31)) = true
kernel_rfl PRE_first_tail_x15_r0_body.zwr128 : PRE_first_tail_x15_r0_body.st128.wr.all (fun b => !Nat.blt b PRE_first_tail_x15_r0_body.s1129.next || PRE_first_tail_x15_r0_body.cl128.contains b) = true
def PRE_first_tail_x15_r0_body.zl128 : List Nat := PRE_first_tail_x15_r0_body.cl128.filter fun a => !(List.contains [2665, 2673467] a)
kernel_rfl PRE_first_tail_x15_r0_body.zimgE128 : PRE_first_tail_x15_r0_body.zl128.map (fun a => PRE_first_tail_x15_r0_body.s1130.heap.get (PRE_first_tail_x15_r0_body.kappa128.a a)) = PRE_first_tail_x15_r0_body.zl128.map (fun a => (PRE_first_tail_x15_r0_body.s1131.heap.get a).map PRE_first_tail_x15_r0_body.kappa128.hobj)
theorem PRE_first_tail_x15_r0_body.zimg128 : HeapImg PRE_first_tail_x15_r0_body.kappa128 PRE_first_tail_x15_r0_body.s1131 PRE_first_tail_x15_r0_body.s1130 PRE_first_tail_x15_r0_body.zl128 := PRE_first_tail_x15_r0_body.zimgE128
-- the roots and their supports
kernel_rfl PRE_first_tail_x15_r0_body.zctl128 : PRE_first_tail_x15_r0_body.s1130.ctl = PRE_first_tail_x15_r0_body.kappa128.ctl PRE_first_tail_x15_r0_body.s1131.ctl
kernel_rfl PRE_first_tail_x15_r0_body.zstack128 : PRE_first_tail_x15_r0_body.s1130.stack = PRE_first_tail_x15_r0_body.s1131.stack.map PRE_first_tail_x15_r0_body.kappa128.frame
kernel_rfl PRE_first_tail_x15_r0_body.zjobs128 : PRE_first_tail_x15_r0_body.s1130.jobs = PRE_first_tail_x15_r0_body.s1131.jobs.map PRE_first_tail_x15_r0_body.kappa128.job
kernel_rfl PRE_first_tail_x15_r0_body.zstores128 : PRE_first_tail_x15_r0_body.s1130.stores = PRE_first_tail_x15_r0_body.kappa128.stores PRE_first_tail_x15_r0_body.s1131.stores
kernel_rfl PRE_first_tail_x15_r0_body.zroots128 : checkRootsSupp PRE_first_tail_x15_r0_body.s1131 5527 = true
kernel_rfl PRE_first_tail_x15_r0_body.znC128 : PRE_first_tail_x15_r0_body.S1129.tab.length + PRE_first_tail_x15_r0_body.cws128.length = 5527
-- the map as `Conv.compact_shift` states it (the call's counters for the literals)
kernel_rfl PRE_first_tail_x15_r0_body.zkap128 : PRE_first_tail_x15_r0_body.kappa128 = Conv.Map.compact PRE_first_tail_x15_r0_body.s1129.next 2774930 PRE_first_tail_x15_r0_body.S1129.tab.length PRE_first_tail_x15_r0_body.pl128 (PRE_first_tail_x15_r0_body.nr128.map NumV.ref) PRE_first_tail_x15_r0_body.kd128.big
  PRE_first_tail_x15_r0_body.kd128.region PRE_first_tail_x15_r0_body.kd128.nodeF
-- the bridge inactive at the canonical state (`Conv.FullShiftQ.toX`; the merged state's bridge is the canonical's: cbridge)
theorem PRE_first_tail_x15_r0_body.zbin128 : (Host.Ts.Sim.Full.bridgeOf PRE_first_tail_x15_r0_body.s1131.ffi).active = false := (Host.Load.Boot.replay_active Host.Load.Run.Prompt.P.oblog2818)
-- the JS bookkeeping's step (`Conv.JClean.step` over the changed list) and the canonical roots' bigint freedom
kernel_rfl PRE_first_tail_x15_r0_body.zjc128 : Conv.jcleanListB (⟨20713, 17818, 2774920, 5527⟩ : Conv.Cnt) PRE_first_tail_x15_r0_body.s1131 PRE_first_tail_x15_r0_body.cl128 = true
kernel_rfl PRE_first_tail_x15_r0_body.zroots2128 : noBigRootsP (fun i => !Conv.oldBigB (⟨20713, 17818, 2774920, 5527⟩ : Conv.Cnt) i) PRE_first_tail_x15_r0_body.s1131.trace PRE_first_tail_x15_r0_body.s1131 = true
kernel_rfl PRE_first_tail_x15_r0_body.zhm128 : Nat.ble (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s0.ffi).mlx.nnext 17818 = true
theorem PRE_first_tail_x15_r0_body.cjcl128 (h : Conv.JClean (⟨20713, 17818, 2774919, 5527⟩ : Conv.Cnt) PRE_first_tail_x15_r0_body.s1129) : Conv.JClean (⟨20713, 17818, 2774920, 5527⟩ : Conv.Cnt) PRE_first_tail_x15_r0_body.s1131 :=
  Conv.JClean.step h (Conv.Cnt.le_of_leB PRE_first_tail_x15_r0_body.cle128)
    (Conv.heap_off_setAll PRE_first_tail_x15_r0_body.cheap128 fun a ha => Nat.blt_eq.mp (List.all_eq_true.mp PRE_first_tail_x15_r0_body.zclbd128 a ha)) PRE_first_tail_x15_r0_body.zjc128

end Host.Load.Run.Tpl
