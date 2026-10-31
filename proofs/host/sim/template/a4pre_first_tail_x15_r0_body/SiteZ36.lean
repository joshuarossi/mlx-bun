import host.sim.template.a4pre_first_tail_x15_r0_body.SiteS36
import host.sim.template.a4pre_first_tail_x15_r0_body.SiteK36
import host.sim.template.a4pre_first_tail_x15_r0_body.SiteF36
import host.sim.conv.CompactShift
import host.sim.template.Check
import host.sim.BigFreeP
import host.sim.template.CallGen
set_option Elab.async false
namespace Host.Load.Run.Tpl
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
open Host.Ts Host.Ts.Sim Host.Ts.Sim.Template

/-! The compaction's state shift at call site 36 of chain `PRE_first_tail_x15_r0_body` (`Conv.compact_shift`): the call `PRE_first_tail_x15_r0_body.s361`, the merged
state `PRE_first_tail_x15_r0_body.s362`, the canonical state `PRE_first_tail_x15_r0_body.s363`; its frames [2665,2673467,2673472,2673473] (kept arrays [2665,2673467]). -/

-- the map's places and counters
kernel_rfl PRE_first_tail_x15_r0_body.zpl36 : PRE_first_tail_x15_r0_body.pl36.all (Nat.ble PRE_first_tail_x15_r0_body.s361.next) = true
kernel_rfl PRE_first_tail_x15_r0_body.zplnd36 : nodupT PRE_first_tail_x15_r0_body.pl36 PTrie.nil = true
kernel_rfl PRE_first_tail_x15_r0_body.zn136 : Nat.ble PRE_first_tail_x15_r0_body.s361.next 2704858 = true
kernel_rfl PRE_first_tail_x15_r0_body.zfirst36 : Nat.ble aFirst PRE_first_tail_x15_r0_body.s361.next = true
kernel_rfl PRE_first_tail_x15_r0_body.zscn36 : PRE_first_tail_x15_r0_body.s363.next = PRE_first_tail_x15_r0_body.s361.next + PRE_first_tail_x15_r0_body.pl36.length
kernel_rfl PRE_first_tail_x15_r0_body.zsmn36 : PRE_first_tail_x15_r0_body.s362.next = 2704858
kernel_rfl PRE_first_tail_x15_r0_body.zgrow36 : Nat.ble PRE_first_tail_x15_r0_body.s363.next PRE_first_tail_x15_r0_body.s362.next = true
-- the tables
kernel_rfl PRE_first_tail_x15_r0_body.zfresh36 : PRE_first_tail_x15_r0_body.S361.tab.all (fun e => PRE_first_tail_x15_r0_body.cws36.all fun v => e.noVar v) = true
kernel_rfl PRE_first_tail_x15_r0_body.zcnd36 : nodupT PRE_first_tail_x15_r0_body.cws36 PTrie.nil = true
kernel_rfl PRE_first_tail_x15_r0_body.znrHi36 : PRE_first_tail_x15_r0_body.nr36.all (fun r => Nat.blt r PRE_first_tail_x15_r0_body.S362.tab.length) = true
-- the frames: every framed address below the call's counter; the kept arrays the chain start's, extended in the merged state
kernel_rfl PRE_first_tail_x15_r0_body.zfrlt36 : [2665, 2673467, 2673472, 2673473].all (fun a => Nat.blt a PRE_first_tail_x15_r0_body.s361.next) = true
kernel_rfl PRE_first_tail_x15_r0_body.zg36_2665 : PRE_first_tail_x15_r0_body.s363.heap.get 2665 = some (.obj (objOf PRE_first_tail_x15_r0_body.s363 2665))
kernel_rfl PRE_first_tail_x15_r0_body.zk36_2665 : (objOf PRE_first_tail_x15_r0_body.s363 2665).kind = .array (arrOf PRE_first_tail_x15_r0_body.s0 2665)
kernel_rfl PRE_first_tail_x15_r0_body.zm36_2665 : PRE_first_tail_x15_r0_body.s362.heap.get 2665 = some (.obj { PRE_first_tail_x15_r0_body.kappa36.obj (objOf PRE_first_tail_x15_r0_body.s363 2665) with
  kind := .array (arrOf PRE_first_tail_x15_r0_body.s0 2665 ++ (arrOf PRE_first_tail_x15_r0_body.s362 2665).drop (arrOf PRE_first_tail_x15_r0_body.s0 2665).length) })
kernel_rfl PRE_first_tail_x15_r0_body.zg36_2673467 : PRE_first_tail_x15_r0_body.s363.heap.get 2673467 = some (.obj (objOf PRE_first_tail_x15_r0_body.s363 2673467))
kernel_rfl PRE_first_tail_x15_r0_body.zk36_2673467 : (objOf PRE_first_tail_x15_r0_body.s363 2673467).kind = .array (arrOf PRE_first_tail_x15_r0_body.s0 2673467)
kernel_rfl PRE_first_tail_x15_r0_body.zm36_2673467 : PRE_first_tail_x15_r0_body.s362.heap.get 2673467 = some (.obj { PRE_first_tail_x15_r0_body.kappa36.obj (objOf PRE_first_tail_x15_r0_body.s363 2673467) with
  kind := .array (arrOf PRE_first_tail_x15_r0_body.s0 2673467 ++ (arrOf PRE_first_tail_x15_r0_body.s362 2673467).drop (arrOf PRE_first_tail_x15_r0_body.s0 2673467).length) })
kernel_rfl PRE_first_tail_x15_r0_body.zw36_4910 : (PRE_first_tail_x15_r0_body.s363.heap.get 4910).isSome = true
kernel_rfl PRE_first_tail_x15_r0_body.zw36_2673472 : (PRE_first_tail_x15_r0_body.s363.heap.get 2673472).isSome = true
kernel_rfl PRE_first_tail_x15_r0_body.zw36_2673473 : (PRE_first_tail_x15_r0_body.s363.heap.get 2673473).isSome = true
-- the heap: the changed list in range, holding the stage's written and fresh addresses; the canonical side's image
kernel_rfl PRE_first_tail_x15_r0_body.zclbd36 : PRE_first_tail_x15_r0_body.cl36.all (fun b => Nat.blt (b / 4096) (4 ^ 31)) = true
kernel_rfl PRE_first_tail_x15_r0_body.zwr36 : PRE_first_tail_x15_r0_body.st36.wr.all (fun b => !Nat.blt b PRE_first_tail_x15_r0_body.s361.next || PRE_first_tail_x15_r0_body.cl36.contains b) = true
def PRE_first_tail_x15_r0_body.zl36 : List Nat := PRE_first_tail_x15_r0_body.cl36.filter fun a => !(List.contains [2665, 2673467] a)
kernel_rfl PRE_first_tail_x15_r0_body.zimgE36 : PRE_first_tail_x15_r0_body.zl36.map (fun a => PRE_first_tail_x15_r0_body.s362.heap.get (PRE_first_tail_x15_r0_body.kappa36.a a)) = PRE_first_tail_x15_r0_body.zl36.map (fun a => (PRE_first_tail_x15_r0_body.s363.heap.get a).map PRE_first_tail_x15_r0_body.kappa36.hobj)
theorem PRE_first_tail_x15_r0_body.zimg36 : HeapImg PRE_first_tail_x15_r0_body.kappa36 PRE_first_tail_x15_r0_body.s363 PRE_first_tail_x15_r0_body.s362 PRE_first_tail_x15_r0_body.zl36 := PRE_first_tail_x15_r0_body.zimgE36
-- the roots and their supports
kernel_rfl PRE_first_tail_x15_r0_body.zctl36 : PRE_first_tail_x15_r0_body.s362.ctl = PRE_first_tail_x15_r0_body.kappa36.ctl PRE_first_tail_x15_r0_body.s363.ctl
kernel_rfl PRE_first_tail_x15_r0_body.zstack36 : PRE_first_tail_x15_r0_body.s362.stack = PRE_first_tail_x15_r0_body.s363.stack.map PRE_first_tail_x15_r0_body.kappa36.frame
kernel_rfl PRE_first_tail_x15_r0_body.zjobs36 : PRE_first_tail_x15_r0_body.s362.jobs = PRE_first_tail_x15_r0_body.s363.jobs.map PRE_first_tail_x15_r0_body.kappa36.job
kernel_rfl PRE_first_tail_x15_r0_body.zstores36 : PRE_first_tail_x15_r0_body.s362.stores = PRE_first_tail_x15_r0_body.kappa36.stores PRE_first_tail_x15_r0_body.s363.stores
kernel_rfl PRE_first_tail_x15_r0_body.zroots36 : checkRootsSupp PRE_first_tail_x15_r0_body.s363 1640 = true
kernel_rfl PRE_first_tail_x15_r0_body.znC36 : PRE_first_tail_x15_r0_body.S361.tab.length + PRE_first_tail_x15_r0_body.cws36.length = 1640
-- the map as `Conv.compact_shift` states it (the call's counters for the literals)
kernel_rfl PRE_first_tail_x15_r0_body.zkap36 : PRE_first_tail_x15_r0_body.kappa36 = Conv.Map.compact PRE_first_tail_x15_r0_body.s361.next 2704858 PRE_first_tail_x15_r0_body.S361.tab.length PRE_first_tail_x15_r0_body.pl36 (PRE_first_tail_x15_r0_body.nr36.map NumV.ref) PRE_first_tail_x15_r0_body.kd36.big
  PRE_first_tail_x15_r0_body.kd36.region PRE_first_tail_x15_r0_body.kd36.nodeF
-- the bridge inactive at the canonical state (`Conv.FullShiftQ.toX`; the merged state's bridge is the canonical's: cbridge)
theorem PRE_first_tail_x15_r0_body.zbin36 : (Host.Ts.Sim.Full.bridgeOf PRE_first_tail_x15_r0_body.s363.ffi).active = false := (Host.Load.Boot.replay_active Host.Load.Run.Prompt.P.oblog2818)
-- the JS bookkeeping's step (`Conv.JClean.step` over the changed list) and the canonical roots' bigint freedom
kernel_rfl PRE_first_tail_x15_r0_body.zjc36 : Conv.jcleanListB (⟨18927, 16016, 2703709, 1640⟩ : Conv.Cnt) PRE_first_tail_x15_r0_body.s363 PRE_first_tail_x15_r0_body.cl36 = true
kernel_rfl PRE_first_tail_x15_r0_body.zrootsB36 : noBigRootsP (fun i => !Conv.oldBigB (⟨18927, 16016, 2703709, 1640⟩ : Conv.Cnt) i) PRE_first_tail_x15_r0_body.s363.trace PRE_first_tail_x15_r0_body.s363 = true
kernel_rfl PRE_first_tail_x15_r0_body.zhm36 : Nat.ble (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s0.ffi).mlx.nnext 15989 = true
theorem PRE_first_tail_x15_r0_body.cjcl36 (h : Conv.JClean (⟨18924, 15989, 2703703, 1622⟩ : Conv.Cnt) PRE_first_tail_x15_r0_body.s361) : Conv.JClean (⟨18927, 16016, 2703709, 1640⟩ : Conv.Cnt) PRE_first_tail_x15_r0_body.s363 :=
  Conv.JClean.step h (Conv.Cnt.le_of_leB PRE_first_tail_x15_r0_body.cle36)
    (Conv.heap_off_setAll PRE_first_tail_x15_r0_body.cheap36 fun a ha => Nat.blt_eq.mp (List.all_eq_true.mp PRE_first_tail_x15_r0_body.zclbd36 a ha)) PRE_first_tail_x15_r0_body.zjc36

end Host.Load.Run.Tpl
