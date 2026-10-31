import host.sim.template.a4pre_first_tail_x15_r0_body.SiteS4
import host.sim.template.a4pre_first_tail_x15_r0_body.SiteK4
import host.sim.template.a4pre_first_tail_x15_r0_body.SiteF4
import host.sim.conv.CompactShift
import host.sim.template.Check
import host.sim.BigFreeP
import host.sim.template.CallGen
set_option Elab.async false
namespace Host.Load.Run.Tpl
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
open Host.Ts Host.Ts.Sim Host.Ts.Sim.Template

/-! The compaction's state shift at call site 4 of chain `PRE_first_tail_x15_r0_body` (`Conv.compact_shift`): the call `PRE_first_tail_x15_r0_body.s53`, the merged
state `PRE_first_tail_x15_r0_body.s54`, the canonical state `PRE_first_tail_x15_r0_body.s55`; its frames [2665,2673467,2673472,2673473] (kept arrays [2665,2673467]). -/

-- the map's places and counters
kernel_rfl PRE_first_tail_x15_r0_body.zpl4 : PRE_first_tail_x15_r0_body.pl4.all (Nat.ble PRE_first_tail_x15_r0_body.s53.next) = true
kernel_rfl PRE_first_tail_x15_r0_body.zplnd4 : nodupT PRE_first_tail_x15_r0_body.pl4 PTrie.nil = true
kernel_rfl PRE_first_tail_x15_r0_body.zn14 : Nat.ble PRE_first_tail_x15_r0_body.s53.next 2678121 = true
kernel_rfl PRE_first_tail_x15_r0_body.zfirst4 : Nat.ble aFirst PRE_first_tail_x15_r0_body.s53.next = true
kernel_rfl PRE_first_tail_x15_r0_body.zscn4 : PRE_first_tail_x15_r0_body.s55.next = PRE_first_tail_x15_r0_body.s53.next + PRE_first_tail_x15_r0_body.pl4.length
kernel_rfl PRE_first_tail_x15_r0_body.zsmn4 : PRE_first_tail_x15_r0_body.s54.next = 2678121
kernel_rfl PRE_first_tail_x15_r0_body.zgrow4 : Nat.ble PRE_first_tail_x15_r0_body.s55.next PRE_first_tail_x15_r0_body.s54.next = true
-- the tables
kernel_rfl PRE_first_tail_x15_r0_body.zfresh4 : PRE_first_tail_x15_r0_body.S53.tab.all (fun e => PRE_first_tail_x15_r0_body.cws4.all fun v => e.noVar v) = true
kernel_rfl PRE_first_tail_x15_r0_body.zcnd4 : nodupT PRE_first_tail_x15_r0_body.cws4 PTrie.nil = true
kernel_rfl PRE_first_tail_x15_r0_body.znrHi4 : PRE_first_tail_x15_r0_body.nr4.all (fun r => Nat.blt r PRE_first_tail_x15_r0_body.S54.tab.length) = true
-- the frames: every framed address below the call's counter; the kept arrays the chain start's, extended in the merged state
kernel_rfl PRE_first_tail_x15_r0_body.zfrlt4 : [2665, 2673467, 2673472, 2673473].all (fun a => Nat.blt a PRE_first_tail_x15_r0_body.s53.next) = true
kernel_rfl PRE_first_tail_x15_r0_body.zg4_2665 : PRE_first_tail_x15_r0_body.s55.heap.get 2665 = some (.obj (objOf PRE_first_tail_x15_r0_body.s55 2665))
kernel_rfl PRE_first_tail_x15_r0_body.zk4_2665 : (objOf PRE_first_tail_x15_r0_body.s55 2665).kind = .array (arrOf PRE_first_tail_x15_r0_body.s0 2665)
kernel_rfl PRE_first_tail_x15_r0_body.zm4_2665 : PRE_first_tail_x15_r0_body.s54.heap.get 2665 = some (.obj { PRE_first_tail_x15_r0_body.kappa4.obj (objOf PRE_first_tail_x15_r0_body.s55 2665) with
  kind := .array (arrOf PRE_first_tail_x15_r0_body.s0 2665 ++ (arrOf PRE_first_tail_x15_r0_body.s54 2665).drop (arrOf PRE_first_tail_x15_r0_body.s0 2665).length) })
kernel_rfl PRE_first_tail_x15_r0_body.zg4_2673467 : PRE_first_tail_x15_r0_body.s55.heap.get 2673467 = some (.obj (objOf PRE_first_tail_x15_r0_body.s55 2673467))
kernel_rfl PRE_first_tail_x15_r0_body.zk4_2673467 : (objOf PRE_first_tail_x15_r0_body.s55 2673467).kind = .array (arrOf PRE_first_tail_x15_r0_body.s0 2673467)
kernel_rfl PRE_first_tail_x15_r0_body.zm4_2673467 : PRE_first_tail_x15_r0_body.s54.heap.get 2673467 = some (.obj { PRE_first_tail_x15_r0_body.kappa4.obj (objOf PRE_first_tail_x15_r0_body.s55 2673467) with
  kind := .array (arrOf PRE_first_tail_x15_r0_body.s0 2673467 ++ (arrOf PRE_first_tail_x15_r0_body.s54 2673467).drop (arrOf PRE_first_tail_x15_r0_body.s0 2673467).length) })
kernel_rfl PRE_first_tail_x15_r0_body.zw4_4910 : (PRE_first_tail_x15_r0_body.s55.heap.get 4910).isSome = true
kernel_rfl PRE_first_tail_x15_r0_body.zw4_2673472 : (PRE_first_tail_x15_r0_body.s55.heap.get 2673472).isSome = true
kernel_rfl PRE_first_tail_x15_r0_body.zw4_2673473 : (PRE_first_tail_x15_r0_body.s55.heap.get 2673473).isSome = true
-- the heap: the changed list in range, holding the stage's written and fresh addresses; the canonical side's image
kernel_rfl PRE_first_tail_x15_r0_body.zclbd4 : PRE_first_tail_x15_r0_body.cl4.all (fun b => Nat.blt (b / 4096) (4 ^ 31)) = true
kernel_rfl PRE_first_tail_x15_r0_body.zwr4 : PRE_first_tail_x15_r0_body.st4.wr.all (fun b => !Nat.blt b PRE_first_tail_x15_r0_body.s53.next || PRE_first_tail_x15_r0_body.cl4.contains b) = true
def PRE_first_tail_x15_r0_body.zl4 : List Nat := PRE_first_tail_x15_r0_body.cl4.filter fun a => !(List.contains [2665, 2673467] a)
kernel_rfl PRE_first_tail_x15_r0_body.zimgE4 : PRE_first_tail_x15_r0_body.zl4.map (fun a => PRE_first_tail_x15_r0_body.s54.heap.get (PRE_first_tail_x15_r0_body.kappa4.a a)) = PRE_first_tail_x15_r0_body.zl4.map (fun a => (PRE_first_tail_x15_r0_body.s55.heap.get a).map PRE_first_tail_x15_r0_body.kappa4.hobj)
theorem PRE_first_tail_x15_r0_body.zimg4 : HeapImg PRE_first_tail_x15_r0_body.kappa4 PRE_first_tail_x15_r0_body.s55 PRE_first_tail_x15_r0_body.s54 PRE_first_tail_x15_r0_body.zl4 := PRE_first_tail_x15_r0_body.zimgE4
-- the roots and their supports
kernel_rfl PRE_first_tail_x15_r0_body.zctl4 : PRE_first_tail_x15_r0_body.s54.ctl = PRE_first_tail_x15_r0_body.kappa4.ctl PRE_first_tail_x15_r0_body.s55.ctl
kernel_rfl PRE_first_tail_x15_r0_body.zstack4 : PRE_first_tail_x15_r0_body.s54.stack = PRE_first_tail_x15_r0_body.s55.stack.map PRE_first_tail_x15_r0_body.kappa4.frame
kernel_rfl PRE_first_tail_x15_r0_body.zjobs4 : PRE_first_tail_x15_r0_body.s54.jobs = PRE_first_tail_x15_r0_body.s55.jobs.map PRE_first_tail_x15_r0_body.kappa4.job
kernel_rfl PRE_first_tail_x15_r0_body.zstores4 : PRE_first_tail_x15_r0_body.s54.stores = PRE_first_tail_x15_r0_body.kappa4.stores PRE_first_tail_x15_r0_body.s55.stores
kernel_rfl PRE_first_tail_x15_r0_body.zroots4 : checkRootsSupp PRE_first_tail_x15_r0_body.s55 251 = true
kernel_rfl PRE_first_tail_x15_r0_body.znC4 : PRE_first_tail_x15_r0_body.S53.tab.length + PRE_first_tail_x15_r0_body.cws4.length = 251
-- the map as `Conv.compact_shift` states it (the call's counters for the literals)
kernel_rfl PRE_first_tail_x15_r0_body.zkap4 : PRE_first_tail_x15_r0_body.kappa4 = Conv.Map.compact PRE_first_tail_x15_r0_body.s53.next 2678121 PRE_first_tail_x15_r0_body.S53.tab.length PRE_first_tail_x15_r0_body.pl4 (PRE_first_tail_x15_r0_body.nr4.map NumV.ref) PRE_first_tail_x15_r0_body.kd4.big
  PRE_first_tail_x15_r0_body.kd4.region PRE_first_tail_x15_r0_body.kd4.nodeF
-- the bridge inactive at the canonical state (`Conv.FullShiftQ.toX`; the merged state's bridge is the canonical's: cbridge)
theorem PRE_first_tail_x15_r0_body.zbin4 : (Host.Ts.Sim.Full.bridgeOf PRE_first_tail_x15_r0_body.s55.ffi).active = false := (Host.Load.Boot.replay_active Host.Load.Run.Prompt.P.oblog2818)
-- the JS bookkeeping's step (`Conv.JClean.step` over the changed list) and the canonical roots' bigint freedom
kernel_rfl PRE_first_tail_x15_r0_body.zjc4 : Conv.jcleanListB (⟨18286, 15381, 2678119, 251⟩ : Conv.Cnt) PRE_first_tail_x15_r0_body.s55 PRE_first_tail_x15_r0_body.cl4 = true
kernel_rfl PRE_first_tail_x15_r0_body.zrootsB4 : noBigRootsP (fun i => !Conv.oldBigB (⟨18286, 15381, 2678119, 251⟩ : Conv.Cnt) i) PRE_first_tail_x15_r0_body.s55.trace PRE_first_tail_x15_r0_body.s55 = true
kernel_rfl PRE_first_tail_x15_r0_body.zhm4 : Nat.ble (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s0.ffi).mlx.nnext 15381 = true
theorem PRE_first_tail_x15_r0_body.cjcl4 (h : Conv.JClean (⟨18286, 15381, 2678119, 251⟩ : Conv.Cnt) PRE_first_tail_x15_r0_body.s53) : Conv.JClean (⟨18286, 15381, 2678119, 251⟩ : Conv.Cnt) PRE_first_tail_x15_r0_body.s55 :=
  Conv.JClean.step h (Conv.Cnt.le_of_leB PRE_first_tail_x15_r0_body.cle4)
    (Conv.heap_off_setAll PRE_first_tail_x15_r0_body.cheap4 fun a ha => Nat.blt_eq.mp (List.all_eq_true.mp PRE_first_tail_x15_r0_body.zclbd4 a ha)) PRE_first_tail_x15_r0_body.zjc4

end Host.Load.Run.Tpl
