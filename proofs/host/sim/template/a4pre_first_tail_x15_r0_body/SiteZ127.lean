import host.sim.template.a4pre_first_tail_x15_r0_body.SiteS127
import host.sim.template.a4pre_first_tail_x15_r0_body.SiteK127
import host.sim.template.a4pre_first_tail_x15_r0_body.SiteF127
import host.sim.conv.CompactShift
import host.sim.template.Check
import host.sim.BigFreeP
import host.sim.template.CallGen
set_option Elab.async false
namespace Host.Load.Run.Tpl
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
open Host.Ts Host.Ts.Sim Host.Ts.Sim.Template

/-! The compaction's state shift at call site 127 of chain `PRE_first_tail_x15_r0_body` (`Conv.compact_shift`): the call `PRE_first_tail_x15_r0_body.s1125`, the merged
state `PRE_first_tail_x15_r0_body.s1126`, the canonical state `PRE_first_tail_x15_r0_body.s1127`; its frames [2665,2673467,2673472,2673473] (kept arrays [2665,2673467]). -/

-- the map's places and counters
kernel_rfl PRE_first_tail_x15_r0_body.zpl127 : PRE_first_tail_x15_r0_body.pl127.all (Nat.ble PRE_first_tail_x15_r0_body.s1125.next) = true
kernel_rfl PRE_first_tail_x15_r0_body.zplnd127 : nodupT PRE_first_tail_x15_r0_body.pl127 PTrie.nil = true
kernel_rfl PRE_first_tail_x15_r0_body.zn1127 : Nat.ble PRE_first_tail_x15_r0_body.s1125.next 2774633 = true
kernel_rfl PRE_first_tail_x15_r0_body.zfirst127 : Nat.ble aFirst PRE_first_tail_x15_r0_body.s1125.next = true
kernel_rfl PRE_first_tail_x15_r0_body.zscn127 : PRE_first_tail_x15_r0_body.s1127.next = PRE_first_tail_x15_r0_body.s1125.next + PRE_first_tail_x15_r0_body.pl127.length
kernel_rfl PRE_first_tail_x15_r0_body.zsmn127 : PRE_first_tail_x15_r0_body.s1126.next = 2774633
kernel_rfl PRE_first_tail_x15_r0_body.zgrow127 : Nat.ble PRE_first_tail_x15_r0_body.s1127.next PRE_first_tail_x15_r0_body.s1126.next = true
-- the tables
kernel_rfl PRE_first_tail_x15_r0_body.zfresh127 : PRE_first_tail_x15_r0_body.S1125.tab.all (fun e => PRE_first_tail_x15_r0_body.cws127.all fun v => e.noVar v) = true
kernel_rfl PRE_first_tail_x15_r0_body.zcnd127 : nodupT PRE_first_tail_x15_r0_body.cws127 PTrie.nil = true
kernel_rfl PRE_first_tail_x15_r0_body.znrHi127 : PRE_first_tail_x15_r0_body.nr127.all (fun r => Nat.blt r PRE_first_tail_x15_r0_body.S1126.tab.length) = true
-- the frames: every framed address below the call's counter; the kept arrays the chain start's, extended in the merged state
kernel_rfl PRE_first_tail_x15_r0_body.zfrlt127 : [2665, 2673467, 2673472, 2673473].all (fun a => Nat.blt a PRE_first_tail_x15_r0_body.s1125.next) = true
kernel_rfl PRE_first_tail_x15_r0_body.zg127_2665 : PRE_first_tail_x15_r0_body.s1127.heap.get 2665 = some (.obj (objOf PRE_first_tail_x15_r0_body.s1127 2665))
kernel_rfl PRE_first_tail_x15_r0_body.zk127_2665 : (objOf PRE_first_tail_x15_r0_body.s1127 2665).kind = .array (arrOf PRE_first_tail_x15_r0_body.s0 2665)
kernel_rfl PRE_first_tail_x15_r0_body.zm127_2665 : PRE_first_tail_x15_r0_body.s1126.heap.get 2665 = some (.obj { PRE_first_tail_x15_r0_body.kappa127.obj (objOf PRE_first_tail_x15_r0_body.s1127 2665) with
  kind := .array (arrOf PRE_first_tail_x15_r0_body.s0 2665 ++ (arrOf PRE_first_tail_x15_r0_body.s1126 2665).drop (arrOf PRE_first_tail_x15_r0_body.s0 2665).length) })
kernel_rfl PRE_first_tail_x15_r0_body.zg127_2673467 : PRE_first_tail_x15_r0_body.s1127.heap.get 2673467 = some (.obj (objOf PRE_first_tail_x15_r0_body.s1127 2673467))
kernel_rfl PRE_first_tail_x15_r0_body.zk127_2673467 : (objOf PRE_first_tail_x15_r0_body.s1127 2673467).kind = .array (arrOf PRE_first_tail_x15_r0_body.s0 2673467)
kernel_rfl PRE_first_tail_x15_r0_body.zm127_2673467 : PRE_first_tail_x15_r0_body.s1126.heap.get 2673467 = some (.obj { PRE_first_tail_x15_r0_body.kappa127.obj (objOf PRE_first_tail_x15_r0_body.s1127 2673467) with
  kind := .array (arrOf PRE_first_tail_x15_r0_body.s0 2673467 ++ (arrOf PRE_first_tail_x15_r0_body.s1126 2673467).drop (arrOf PRE_first_tail_x15_r0_body.s0 2673467).length) })
kernel_rfl PRE_first_tail_x15_r0_body.zw127_4910 : (PRE_first_tail_x15_r0_body.s1127.heap.get 4910).isSome = true
kernel_rfl PRE_first_tail_x15_r0_body.zw127_2673472 : (PRE_first_tail_x15_r0_body.s1127.heap.get 2673472).isSome = true
kernel_rfl PRE_first_tail_x15_r0_body.zw127_2673473 : (PRE_first_tail_x15_r0_body.s1127.heap.get 2673473).isSome = true
-- the heap: the changed list in range, holding the stage's written and fresh addresses; the canonical side's image
kernel_rfl PRE_first_tail_x15_r0_body.zclbd127 : PRE_first_tail_x15_r0_body.cl127.all (fun b => Nat.blt (b / 4096) (4 ^ 31)) = true
kernel_rfl PRE_first_tail_x15_r0_body.zwr127 : PRE_first_tail_x15_r0_body.st127.wr.all (fun b => !Nat.blt b PRE_first_tail_x15_r0_body.s1125.next || PRE_first_tail_x15_r0_body.cl127.contains b) = true
def PRE_first_tail_x15_r0_body.zl127 : List Nat := PRE_first_tail_x15_r0_body.cl127.filter fun a => !(List.contains [2665, 2673467] a)
kernel_rfl PRE_first_tail_x15_r0_body.zimgE127 : PRE_first_tail_x15_r0_body.zl127.map (fun a => PRE_first_tail_x15_r0_body.s1126.heap.get (PRE_first_tail_x15_r0_body.kappa127.a a)) = PRE_first_tail_x15_r0_body.zl127.map (fun a => (PRE_first_tail_x15_r0_body.s1127.heap.get a).map PRE_first_tail_x15_r0_body.kappa127.hobj)
theorem PRE_first_tail_x15_r0_body.zimg127 : HeapImg PRE_first_tail_x15_r0_body.kappa127 PRE_first_tail_x15_r0_body.s1127 PRE_first_tail_x15_r0_body.s1126 PRE_first_tail_x15_r0_body.zl127 := PRE_first_tail_x15_r0_body.zimgE127
-- the roots and their supports
kernel_rfl PRE_first_tail_x15_r0_body.zctl127 : PRE_first_tail_x15_r0_body.s1126.ctl = PRE_first_tail_x15_r0_body.kappa127.ctl PRE_first_tail_x15_r0_body.s1127.ctl
kernel_rfl PRE_first_tail_x15_r0_body.zstack127 : PRE_first_tail_x15_r0_body.s1126.stack = PRE_first_tail_x15_r0_body.s1127.stack.map PRE_first_tail_x15_r0_body.kappa127.frame
kernel_rfl PRE_first_tail_x15_r0_body.zjobs127 : PRE_first_tail_x15_r0_body.s1126.jobs = PRE_first_tail_x15_r0_body.s1127.jobs.map PRE_first_tail_x15_r0_body.kappa127.job
kernel_rfl PRE_first_tail_x15_r0_body.zstores127 : PRE_first_tail_x15_r0_body.s1126.stores = PRE_first_tail_x15_r0_body.kappa127.stores PRE_first_tail_x15_r0_body.s1127.stores
kernel_rfl PRE_first_tail_x15_r0_body.zroots127 : checkRootsSupp PRE_first_tail_x15_r0_body.s1127 5510 = true
kernel_rfl PRE_first_tail_x15_r0_body.znC127 : PRE_first_tail_x15_r0_body.S1125.tab.length + PRE_first_tail_x15_r0_body.cws127.length = 5510
-- the map as `Conv.compact_shift` states it (the call's counters for the literals)
kernel_rfl PRE_first_tail_x15_r0_body.zkap127 : PRE_first_tail_x15_r0_body.kappa127 = Conv.Map.compact PRE_first_tail_x15_r0_body.s1125.next 2774633 PRE_first_tail_x15_r0_body.S1125.tab.length PRE_first_tail_x15_r0_body.pl127 (PRE_first_tail_x15_r0_body.nr127.map NumV.ref) PRE_first_tail_x15_r0_body.kd127.big
  PRE_first_tail_x15_r0_body.kd127.region PRE_first_tail_x15_r0_body.kd127.nodeF
-- the bridge inactive at the canonical state (`Conv.FullShiftQ.toX`; the merged state's bridge is the canonical's: cbridge)
theorem PRE_first_tail_x15_r0_body.zbin127 : (Host.Ts.Sim.Full.bridgeOf PRE_first_tail_x15_r0_body.s1127.ffi).active = false := (Host.Load.Boot.replay_active Host.Load.Run.Prompt.P.oblog2818)
-- the JS bookkeeping's step (`Conv.JClean.step` over the changed list) and the canonical roots' bigint freedom
kernel_rfl PRE_first_tail_x15_r0_body.zjc127 : Conv.jcleanListB (⟨20706, 17814, 2774631, 5510⟩ : Conv.Cnt) PRE_first_tail_x15_r0_body.s1127 PRE_first_tail_x15_r0_body.cl127 = true
kernel_rfl PRE_first_tail_x15_r0_body.zroots2127 : noBigRootsP (fun i => !Conv.oldBigB (⟨20706, 17814, 2774631, 5510⟩ : Conv.Cnt) i) PRE_first_tail_x15_r0_body.s1127.trace PRE_first_tail_x15_r0_body.s1127 = true
kernel_rfl PRE_first_tail_x15_r0_body.zhm127 : Nat.ble (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s0.ffi).mlx.nnext 17814 = true
theorem PRE_first_tail_x15_r0_body.cjcl127 (h : Conv.JClean (⟨20706, 17814, 2774631, 5510⟩ : Conv.Cnt) PRE_first_tail_x15_r0_body.s1125) : Conv.JClean (⟨20706, 17814, 2774631, 5510⟩ : Conv.Cnt) PRE_first_tail_x15_r0_body.s1127 :=
  Conv.JClean.step h (Conv.Cnt.le_of_leB PRE_first_tail_x15_r0_body.cle127)
    (Conv.heap_off_setAll PRE_first_tail_x15_r0_body.cheap127 fun a ha => Nat.blt_eq.mp (List.all_eq_true.mp PRE_first_tail_x15_r0_body.zclbd127 a ha)) PRE_first_tail_x15_r0_body.zjc127

end Host.Load.Run.Tpl
