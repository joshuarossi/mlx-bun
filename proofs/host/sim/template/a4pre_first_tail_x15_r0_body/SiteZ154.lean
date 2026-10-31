import host.sim.template.a4pre_first_tail_x15_r0_body.SiteS154
import host.sim.template.a4pre_first_tail_x15_r0_body.SiteK154
import host.sim.template.a4pre_first_tail_x15_r0_body.SiteF154
import host.sim.conv.CompactShift
import host.sim.template.Check
import host.sim.BigFreeP
import host.sim.template.CallGen
set_option Elab.async false
namespace Host.Load.Run.Tpl
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
open Host.Ts Host.Ts.Sim Host.Ts.Sim.Template

/-! The compaction's state shift at call site 154 of chain `PRE_first_tail_x15_r0_body` (`Conv.compact_shift`): the call `PRE_first_tail_x15_r0_body.s1359`, the merged
state `PRE_first_tail_x15_r0_body.s1360`, the canonical state `PRE_first_tail_x15_r0_body.s1361`; its frames [2665,2673467,2673472,2673473] (kept arrays [2665,2673467]). -/

-- the map's places and counters
kernel_rfl PRE_first_tail_x15_r0_body.zpl154 : PRE_first_tail_x15_r0_body.pl154.all (Nat.ble PRE_first_tail_x15_r0_body.s1359.next) = true
kernel_rfl PRE_first_tail_x15_r0_body.zplnd154 : nodupT PRE_first_tail_x15_r0_body.pl154 PTrie.nil = true
kernel_rfl PRE_first_tail_x15_r0_body.zn1154 : Nat.ble PRE_first_tail_x15_r0_body.s1359.next 2796099 = true
kernel_rfl PRE_first_tail_x15_r0_body.zfirst154 : Nat.ble aFirst PRE_first_tail_x15_r0_body.s1359.next = true
kernel_rfl PRE_first_tail_x15_r0_body.zscn154 : PRE_first_tail_x15_r0_body.s1361.next = PRE_first_tail_x15_r0_body.s1359.next + PRE_first_tail_x15_r0_body.pl154.length
kernel_rfl PRE_first_tail_x15_r0_body.zsmn154 : PRE_first_tail_x15_r0_body.s1360.next = 2796099
kernel_rfl PRE_first_tail_x15_r0_body.zgrow154 : Nat.ble PRE_first_tail_x15_r0_body.s1361.next PRE_first_tail_x15_r0_body.s1360.next = true
-- the tables
kernel_rfl PRE_first_tail_x15_r0_body.zfresh154 : PRE_first_tail_x15_r0_body.S1359.tab.all (fun e => PRE_first_tail_x15_r0_body.cws154.all fun v => e.noVar v) = true
kernel_rfl PRE_first_tail_x15_r0_body.zcnd154 : nodupT PRE_first_tail_x15_r0_body.cws154 PTrie.nil = true
kernel_rfl PRE_first_tail_x15_r0_body.znrHi154 : PRE_first_tail_x15_r0_body.nr154.all (fun r => Nat.blt r PRE_first_tail_x15_r0_body.S1360.tab.length) = true
-- the frames: every framed address below the call's counter; the kept arrays the chain start's, extended in the merged state
kernel_rfl PRE_first_tail_x15_r0_body.zfrlt154 : [2665, 2673467, 2673472, 2673473].all (fun a => Nat.blt a PRE_first_tail_x15_r0_body.s1359.next) = true
kernel_rfl PRE_first_tail_x15_r0_body.zg154_2665 : PRE_first_tail_x15_r0_body.s1361.heap.get 2665 = some (.obj (objOf PRE_first_tail_x15_r0_body.s1361 2665))
kernel_rfl PRE_first_tail_x15_r0_body.zk154_2665 : (objOf PRE_first_tail_x15_r0_body.s1361 2665).kind = .array (arrOf PRE_first_tail_x15_r0_body.s0 2665)
kernel_rfl PRE_first_tail_x15_r0_body.zm154_2665 : PRE_first_tail_x15_r0_body.s1360.heap.get 2665 = some (.obj { PRE_first_tail_x15_r0_body.kappa154.obj (objOf PRE_first_tail_x15_r0_body.s1361 2665) with
  kind := .array (arrOf PRE_first_tail_x15_r0_body.s0 2665 ++ (arrOf PRE_first_tail_x15_r0_body.s1360 2665).drop (arrOf PRE_first_tail_x15_r0_body.s0 2665).length) })
kernel_rfl PRE_first_tail_x15_r0_body.zg154_2673467 : PRE_first_tail_x15_r0_body.s1361.heap.get 2673467 = some (.obj (objOf PRE_first_tail_x15_r0_body.s1361 2673467))
kernel_rfl PRE_first_tail_x15_r0_body.zk154_2673467 : (objOf PRE_first_tail_x15_r0_body.s1361 2673467).kind = .array (arrOf PRE_first_tail_x15_r0_body.s0 2673467)
kernel_rfl PRE_first_tail_x15_r0_body.zm154_2673467 : PRE_first_tail_x15_r0_body.s1360.heap.get 2673467 = some (.obj { PRE_first_tail_x15_r0_body.kappa154.obj (objOf PRE_first_tail_x15_r0_body.s1361 2673467) with
  kind := .array (arrOf PRE_first_tail_x15_r0_body.s0 2673467 ++ (arrOf PRE_first_tail_x15_r0_body.s1360 2673467).drop (arrOf PRE_first_tail_x15_r0_body.s0 2673467).length) })
kernel_rfl PRE_first_tail_x15_r0_body.zw154_4910 : (PRE_first_tail_x15_r0_body.s1361.heap.get 4910).isSome = true
kernel_rfl PRE_first_tail_x15_r0_body.zw154_2673472 : (PRE_first_tail_x15_r0_body.s1361.heap.get 2673472).isSome = true
kernel_rfl PRE_first_tail_x15_r0_body.zw154_2673473 : (PRE_first_tail_x15_r0_body.s1361.heap.get 2673473).isSome = true
-- the heap: the changed list in range, holding the stage's written and fresh addresses; the canonical side's image
kernel_rfl PRE_first_tail_x15_r0_body.zclbd154 : PRE_first_tail_x15_r0_body.cl154.all (fun b => Nat.blt (b / 4096) (4 ^ 31)) = true
kernel_rfl PRE_first_tail_x15_r0_body.zwr154 : PRE_first_tail_x15_r0_body.st154.wr.all (fun b => !Nat.blt b PRE_first_tail_x15_r0_body.s1359.next || PRE_first_tail_x15_r0_body.cl154.contains b) = true
def PRE_first_tail_x15_r0_body.zl154 : List Nat := PRE_first_tail_x15_r0_body.cl154.filter fun a => !(List.contains [2665, 2673467] a)
kernel_rfl PRE_first_tail_x15_r0_body.zimgE154 : PRE_first_tail_x15_r0_body.zl154.map (fun a => PRE_first_tail_x15_r0_body.s1360.heap.get (PRE_first_tail_x15_r0_body.kappa154.a a)) = PRE_first_tail_x15_r0_body.zl154.map (fun a => (PRE_first_tail_x15_r0_body.s1361.heap.get a).map PRE_first_tail_x15_r0_body.kappa154.hobj)
theorem PRE_first_tail_x15_r0_body.zimg154 : HeapImg PRE_first_tail_x15_r0_body.kappa154 PRE_first_tail_x15_r0_body.s1361 PRE_first_tail_x15_r0_body.s1360 PRE_first_tail_x15_r0_body.zl154 := PRE_first_tail_x15_r0_body.zimgE154
-- the roots and their supports
kernel_rfl PRE_first_tail_x15_r0_body.zctl154 : PRE_first_tail_x15_r0_body.s1360.ctl = PRE_first_tail_x15_r0_body.kappa154.ctl PRE_first_tail_x15_r0_body.s1361.ctl
kernel_rfl PRE_first_tail_x15_r0_body.zstack154 : PRE_first_tail_x15_r0_body.s1360.stack = PRE_first_tail_x15_r0_body.s1361.stack.map PRE_first_tail_x15_r0_body.kappa154.frame
kernel_rfl PRE_first_tail_x15_r0_body.zjobs154 : PRE_first_tail_x15_r0_body.s1360.jobs = PRE_first_tail_x15_r0_body.s1361.jobs.map PRE_first_tail_x15_r0_body.kappa154.job
kernel_rfl PRE_first_tail_x15_r0_body.zstores154 : PRE_first_tail_x15_r0_body.s1360.stores = PRE_first_tail_x15_r0_body.kappa154.stores PRE_first_tail_x15_r0_body.s1361.stores
kernel_rfl PRE_first_tail_x15_r0_body.zroots154 : checkRootsSupp PRE_first_tail_x15_r0_body.s1361 6662 = true
kernel_rfl PRE_first_tail_x15_r0_body.znC154 : PRE_first_tail_x15_r0_body.S1359.tab.length + PRE_first_tail_x15_r0_body.cws154.length = 6662
-- the map as `Conv.compact_shift` states it (the call's counters for the literals)
kernel_rfl PRE_first_tail_x15_r0_body.zkap154 : PRE_first_tail_x15_r0_body.kappa154 = Conv.Map.compact PRE_first_tail_x15_r0_body.s1359.next 2796099 PRE_first_tail_x15_r0_body.S1359.tab.length PRE_first_tail_x15_r0_body.pl154 (PRE_first_tail_x15_r0_body.nr154.map NumV.ref) PRE_first_tail_x15_r0_body.kd154.big
  PRE_first_tail_x15_r0_body.kd154.region PRE_first_tail_x15_r0_body.kd154.nodeF
-- the bridge inactive at the canonical state (`Conv.FullShiftQ.toX`; the merged state's bridge is the canonical's: cbridge)
theorem PRE_first_tail_x15_r0_body.zbin154 : (Host.Ts.Sim.Full.bridgeOf PRE_first_tail_x15_r0_body.s1361.ffi).active = false := (Host.Load.Boot.replay_active Host.Load.Run.Prompt.P.oblog2818)
-- the JS bookkeeping's step (`Conv.JClean.step` over the changed list) and the canonical roots' bigint freedom
kernel_rfl PRE_first_tail_x15_r0_body.zjc154 : Conv.jcleanListB (⟨21242, 18336, 2796097, 6662⟩ : Conv.Cnt) PRE_first_tail_x15_r0_body.s1361 PRE_first_tail_x15_r0_body.cl154 = true
kernel_rfl PRE_first_tail_x15_r0_body.zroots2154 : noBigRootsP (fun i => !Conv.oldBigB (⟨21242, 18336, 2796097, 6662⟩ : Conv.Cnt) i) PRE_first_tail_x15_r0_body.s1361.trace PRE_first_tail_x15_r0_body.s1361 = true
kernel_rfl PRE_first_tail_x15_r0_body.zhm154 : Nat.ble (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s0.ffi).mlx.nnext 18336 = true
theorem PRE_first_tail_x15_r0_body.cjcl154 (h : Conv.JClean (⟨21242, 18336, 2796097, 6662⟩ : Conv.Cnt) PRE_first_tail_x15_r0_body.s1359) : Conv.JClean (⟨21242, 18336, 2796097, 6662⟩ : Conv.Cnt) PRE_first_tail_x15_r0_body.s1361 :=
  Conv.JClean.step h (Conv.Cnt.le_of_leB PRE_first_tail_x15_r0_body.cle154)
    (Conv.heap_off_setAll PRE_first_tail_x15_r0_body.cheap154 fun a ha => Nat.blt_eq.mp (List.all_eq_true.mp PRE_first_tail_x15_r0_body.zclbd154 a ha)) PRE_first_tail_x15_r0_body.zjc154

end Host.Load.Run.Tpl
