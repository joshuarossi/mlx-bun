import host.sim.template.a4pre_first_tail_x15_r0_body.SiteS135
import host.sim.template.a4pre_first_tail_x15_r0_body.SiteK135
import host.sim.template.a4pre_first_tail_x15_r0_body.SiteF135
import host.sim.conv.CompactShift
import host.sim.template.Check
import host.sim.BigFreeP
import host.sim.template.CallGen
set_option Elab.async false
namespace Host.Load.Run.Tpl
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
open Host.Ts Host.Ts.Sim Host.Ts.Sim.Template

/-! The compaction's state shift at call site 135 of chain `PRE_first_tail_x15_r0_body` (`Conv.compact_shift`): the call `PRE_first_tail_x15_r0_body.s1310`, the merged
state `PRE_first_tail_x15_r0_body.s1311`, the canonical state `PRE_first_tail_x15_r0_body.s1312`; its frames [2665,2673467,2673472,2673473] (kept arrays [2665,2673467]). -/

-- the map's places and counters
kernel_rfl PRE_first_tail_x15_r0_body.zpl135 : PRE_first_tail_x15_r0_body.pl135.all (Nat.ble PRE_first_tail_x15_r0_body.s1310.next) = true
kernel_rfl PRE_first_tail_x15_r0_body.zplnd135 : nodupT PRE_first_tail_x15_r0_body.pl135 PTrie.nil = true
kernel_rfl PRE_first_tail_x15_r0_body.zn1135 : Nat.ble PRE_first_tail_x15_r0_body.s1310.next 2782446 = true
kernel_rfl PRE_first_tail_x15_r0_body.zfirst135 : Nat.ble aFirst PRE_first_tail_x15_r0_body.s1310.next = true
kernel_rfl PRE_first_tail_x15_r0_body.zscn135 : PRE_first_tail_x15_r0_body.s1312.next = PRE_first_tail_x15_r0_body.s1310.next + PRE_first_tail_x15_r0_body.pl135.length
kernel_rfl PRE_first_tail_x15_r0_body.zsmn135 : PRE_first_tail_x15_r0_body.s1311.next = 2782446
kernel_rfl PRE_first_tail_x15_r0_body.zgrow135 : Nat.ble PRE_first_tail_x15_r0_body.s1312.next PRE_first_tail_x15_r0_body.s1311.next = true
-- the tables
kernel_rfl PRE_first_tail_x15_r0_body.zfresh135 : PRE_first_tail_x15_r0_body.S1310.tab.all (fun e => PRE_first_tail_x15_r0_body.cws135.all fun v => e.noVar v) = true
kernel_rfl PRE_first_tail_x15_r0_body.zcnd135 : nodupT PRE_first_tail_x15_r0_body.cws135 PTrie.nil = true
kernel_rfl PRE_first_tail_x15_r0_body.znrHi135 : PRE_first_tail_x15_r0_body.nr135.all (fun r => Nat.blt r PRE_first_tail_x15_r0_body.S1311.tab.length) = true
-- the frames: every framed address below the call's counter; the kept arrays the chain start's, extended in the merged state
kernel_rfl PRE_first_tail_x15_r0_body.zfrlt135 : [2665, 2673467, 2673472, 2673473].all (fun a => Nat.blt a PRE_first_tail_x15_r0_body.s1310.next) = true
kernel_rfl PRE_first_tail_x15_r0_body.zg135_2665 : PRE_first_tail_x15_r0_body.s1312.heap.get 2665 = some (.obj (objOf PRE_first_tail_x15_r0_body.s1312 2665))
kernel_rfl PRE_first_tail_x15_r0_body.zk135_2665 : (objOf PRE_first_tail_x15_r0_body.s1312 2665).kind = .array (arrOf PRE_first_tail_x15_r0_body.s0 2665)
kernel_rfl PRE_first_tail_x15_r0_body.zm135_2665 : PRE_first_tail_x15_r0_body.s1311.heap.get 2665 = some (.obj { PRE_first_tail_x15_r0_body.kappa135.obj (objOf PRE_first_tail_x15_r0_body.s1312 2665) with
  kind := .array (arrOf PRE_first_tail_x15_r0_body.s0 2665 ++ (arrOf PRE_first_tail_x15_r0_body.s1311 2665).drop (arrOf PRE_first_tail_x15_r0_body.s0 2665).length) })
kernel_rfl PRE_first_tail_x15_r0_body.zg135_2673467 : PRE_first_tail_x15_r0_body.s1312.heap.get 2673467 = some (.obj (objOf PRE_first_tail_x15_r0_body.s1312 2673467))
kernel_rfl PRE_first_tail_x15_r0_body.zk135_2673467 : (objOf PRE_first_tail_x15_r0_body.s1312 2673467).kind = .array (arrOf PRE_first_tail_x15_r0_body.s0 2673467)
kernel_rfl PRE_first_tail_x15_r0_body.zm135_2673467 : PRE_first_tail_x15_r0_body.s1311.heap.get 2673467 = some (.obj { PRE_first_tail_x15_r0_body.kappa135.obj (objOf PRE_first_tail_x15_r0_body.s1312 2673467) with
  kind := .array (arrOf PRE_first_tail_x15_r0_body.s0 2673467 ++ (arrOf PRE_first_tail_x15_r0_body.s1311 2673467).drop (arrOf PRE_first_tail_x15_r0_body.s0 2673467).length) })
kernel_rfl PRE_first_tail_x15_r0_body.zw135_4910 : (PRE_first_tail_x15_r0_body.s1312.heap.get 4910).isSome = true
kernel_rfl PRE_first_tail_x15_r0_body.zw135_2673472 : (PRE_first_tail_x15_r0_body.s1312.heap.get 2673472).isSome = true
kernel_rfl PRE_first_tail_x15_r0_body.zw135_2673473 : (PRE_first_tail_x15_r0_body.s1312.heap.get 2673473).isSome = true
-- the heap: the changed list in range, holding the stage's written and fresh addresses; the canonical side's image
kernel_rfl PRE_first_tail_x15_r0_body.zclbd135 : PRE_first_tail_x15_r0_body.cl135.all (fun b => Nat.blt (b / 4096) (4 ^ 31)) = true
kernel_rfl PRE_first_tail_x15_r0_body.zwr135 : PRE_first_tail_x15_r0_body.st135.wr.all (fun b => !Nat.blt b PRE_first_tail_x15_r0_body.s1310.next || PRE_first_tail_x15_r0_body.cl135.contains b) = true
def PRE_first_tail_x15_r0_body.zl135 : List Nat := PRE_first_tail_x15_r0_body.cl135.filter fun a => !(List.contains [2665, 2673467] a)
kernel_rfl PRE_first_tail_x15_r0_body.zimgE135 : PRE_first_tail_x15_r0_body.zl135.map (fun a => PRE_first_tail_x15_r0_body.s1311.heap.get (PRE_first_tail_x15_r0_body.kappa135.a a)) = PRE_first_tail_x15_r0_body.zl135.map (fun a => (PRE_first_tail_x15_r0_body.s1312.heap.get a).map PRE_first_tail_x15_r0_body.kappa135.hobj)
theorem PRE_first_tail_x15_r0_body.zimg135 : HeapImg PRE_first_tail_x15_r0_body.kappa135 PRE_first_tail_x15_r0_body.s1312 PRE_first_tail_x15_r0_body.s1311 PRE_first_tail_x15_r0_body.zl135 := PRE_first_tail_x15_r0_body.zimgE135
-- the roots and their supports
kernel_rfl PRE_first_tail_x15_r0_body.zctl135 : PRE_first_tail_x15_r0_body.s1311.ctl = PRE_first_tail_x15_r0_body.kappa135.ctl PRE_first_tail_x15_r0_body.s1312.ctl
kernel_rfl PRE_first_tail_x15_r0_body.zstack135 : PRE_first_tail_x15_r0_body.s1311.stack = PRE_first_tail_x15_r0_body.s1312.stack.map PRE_first_tail_x15_r0_body.kappa135.frame
kernel_rfl PRE_first_tail_x15_r0_body.zjobs135 : PRE_first_tail_x15_r0_body.s1311.jobs = PRE_first_tail_x15_r0_body.s1312.jobs.map PRE_first_tail_x15_r0_body.kappa135.job
kernel_rfl PRE_first_tail_x15_r0_body.zstores135 : PRE_first_tail_x15_r0_body.s1311.stores = PRE_first_tail_x15_r0_body.kappa135.stores PRE_first_tail_x15_r0_body.s1312.stores
kernel_rfl PRE_first_tail_x15_r0_body.zroots135 : checkRootsSupp PRE_first_tail_x15_r0_body.s1312 5873 = true
kernel_rfl PRE_first_tail_x15_r0_body.znC135 : PRE_first_tail_x15_r0_body.S1310.tab.length + PRE_first_tail_x15_r0_body.cws135.length = 5873
-- the map as `Conv.compact_shift` states it (the call's counters for the literals)
kernel_rfl PRE_first_tail_x15_r0_body.zkap135 : PRE_first_tail_x15_r0_body.kappa135 = Conv.Map.compact PRE_first_tail_x15_r0_body.s1310.next 2782446 PRE_first_tail_x15_r0_body.S1310.tab.length PRE_first_tail_x15_r0_body.pl135 (PRE_first_tail_x15_r0_body.nr135.map NumV.ref) PRE_first_tail_x15_r0_body.kd135.big
  PRE_first_tail_x15_r0_body.kd135.region PRE_first_tail_x15_r0_body.kd135.nodeF
-- the bridge inactive at the canonical state (`Conv.FullShiftQ.toX`; the merged state's bridge is the canonical's: cbridge)
theorem PRE_first_tail_x15_r0_body.zbin135 : (Host.Ts.Sim.Full.bridgeOf PRE_first_tail_x15_r0_body.s1312.ffi).active = false := (Host.Load.Boot.replay_active Host.Load.Run.Prompt.P.oblog2818)
-- the JS bookkeeping's step (`Conv.JClean.step` over the changed list) and the canonical roots' bigint freedom
kernel_rfl PRE_first_tail_x15_r0_body.zjc135 : Conv.jcleanListB (⟨20872, 17975, 2781297, 5873⟩ : Conv.Cnt) PRE_first_tail_x15_r0_body.s1312 PRE_first_tail_x15_r0_body.cl135 = true
kernel_rfl PRE_first_tail_x15_r0_body.zrootsB135 : noBigRootsP (fun i => !Conv.oldBigB (⟨20872, 17975, 2781297, 5873⟩ : Conv.Cnt) i) PRE_first_tail_x15_r0_body.s1312.trace PRE_first_tail_x15_r0_body.s1312 = true
kernel_rfl PRE_first_tail_x15_r0_body.zhm135 : Nat.ble (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s0.ffi).mlx.nnext 17948 = true
theorem PRE_first_tail_x15_r0_body.cjcl135 (h : Conv.JClean (⟨20869, 17948, 2781291, 5855⟩ : Conv.Cnt) PRE_first_tail_x15_r0_body.s1310) : Conv.JClean (⟨20872, 17975, 2781297, 5873⟩ : Conv.Cnt) PRE_first_tail_x15_r0_body.s1312 :=
  Conv.JClean.step h (Conv.Cnt.le_of_leB PRE_first_tail_x15_r0_body.cle135)
    (Conv.heap_off_setAll PRE_first_tail_x15_r0_body.cheap135 fun a ha => Nat.blt_eq.mp (List.all_eq_true.mp PRE_first_tail_x15_r0_body.zclbd135 a ha)) PRE_first_tail_x15_r0_body.zjc135

end Host.Load.Run.Tpl
