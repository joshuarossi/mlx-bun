import host.sim.template.a4pre_first_tail_x15_r0_body.SiteS98
import host.sim.template.a4pre_first_tail_x15_r0_body.SiteK98
import host.sim.template.a4pre_first_tail_x15_r0_body.SiteF98
import host.sim.conv.CompactShift
import host.sim.template.Check
import host.sim.BigFreeP
import host.sim.template.CallGen
set_option Elab.async false
namespace Host.Load.Run.Tpl
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
open Host.Ts Host.Ts.Sim Host.Ts.Sim.Template

/-! The compaction's state shift at call site 98 of chain `PRE_first_tail_x15_r0_body` (`Conv.compact_shift`): the call `PRE_first_tail_x15_r0_body.s948`, the merged
state `PRE_first_tail_x15_r0_body.s949`, the canonical state `PRE_first_tail_x15_r0_body.s950`; its frames [2665,2673467,2673472,2673473] (kept arrays [2665,2673467]). -/

-- the map's places and counters
kernel_rfl PRE_first_tail_x15_r0_body.zpl98 : PRE_first_tail_x15_r0_body.pl98.all (Nat.ble PRE_first_tail_x15_r0_body.s948.next) = true
kernel_rfl PRE_first_tail_x15_r0_body.zplnd98 : nodupT PRE_first_tail_x15_r0_body.pl98 PTrie.nil = true
kernel_rfl PRE_first_tail_x15_r0_body.zn198 : Nat.ble PRE_first_tail_x15_r0_body.s948.next 2751595 = true
kernel_rfl PRE_first_tail_x15_r0_body.zfirst98 : Nat.ble aFirst PRE_first_tail_x15_r0_body.s948.next = true
kernel_rfl PRE_first_tail_x15_r0_body.zscn98 : PRE_first_tail_x15_r0_body.s950.next = PRE_first_tail_x15_r0_body.s948.next + PRE_first_tail_x15_r0_body.pl98.length
kernel_rfl PRE_first_tail_x15_r0_body.zsmn98 : PRE_first_tail_x15_r0_body.s949.next = 2751595
kernel_rfl PRE_first_tail_x15_r0_body.zgrow98 : Nat.ble PRE_first_tail_x15_r0_body.s950.next PRE_first_tail_x15_r0_body.s949.next = true
-- the tables
kernel_rfl PRE_first_tail_x15_r0_body.zfresh98 : PRE_first_tail_x15_r0_body.S948.tab.all (fun e => PRE_first_tail_x15_r0_body.cws98.all fun v => e.noVar v) = true
kernel_rfl PRE_first_tail_x15_r0_body.zcnd98 : nodupT PRE_first_tail_x15_r0_body.cws98 PTrie.nil = true
kernel_rfl PRE_first_tail_x15_r0_body.znrHi98 : PRE_first_tail_x15_r0_body.nr98.all (fun r => Nat.blt r PRE_first_tail_x15_r0_body.S949.tab.length) = true
-- the frames: every framed address below the call's counter; the kept arrays the chain start's, extended in the merged state
kernel_rfl PRE_first_tail_x15_r0_body.zfrlt98 : [2665, 2673467, 2673472, 2673473].all (fun a => Nat.blt a PRE_first_tail_x15_r0_body.s948.next) = true
kernel_rfl PRE_first_tail_x15_r0_body.zg98_2665 : PRE_first_tail_x15_r0_body.s950.heap.get 2665 = some (.obj (objOf PRE_first_tail_x15_r0_body.s950 2665))
kernel_rfl PRE_first_tail_x15_r0_body.zk98_2665 : (objOf PRE_first_tail_x15_r0_body.s950 2665).kind = .array (arrOf PRE_first_tail_x15_r0_body.s0 2665)
kernel_rfl PRE_first_tail_x15_r0_body.zm98_2665 : PRE_first_tail_x15_r0_body.s949.heap.get 2665 = some (.obj { PRE_first_tail_x15_r0_body.kappa98.obj (objOf PRE_first_tail_x15_r0_body.s950 2665) with
  kind := .array (arrOf PRE_first_tail_x15_r0_body.s0 2665 ++ (arrOf PRE_first_tail_x15_r0_body.s949 2665).drop (arrOf PRE_first_tail_x15_r0_body.s0 2665).length) })
kernel_rfl PRE_first_tail_x15_r0_body.zg98_2673467 : PRE_first_tail_x15_r0_body.s950.heap.get 2673467 = some (.obj (objOf PRE_first_tail_x15_r0_body.s950 2673467))
kernel_rfl PRE_first_tail_x15_r0_body.zk98_2673467 : (objOf PRE_first_tail_x15_r0_body.s950 2673467).kind = .array (arrOf PRE_first_tail_x15_r0_body.s0 2673467)
kernel_rfl PRE_first_tail_x15_r0_body.zm98_2673467 : PRE_first_tail_x15_r0_body.s949.heap.get 2673467 = some (.obj { PRE_first_tail_x15_r0_body.kappa98.obj (objOf PRE_first_tail_x15_r0_body.s950 2673467) with
  kind := .array (arrOf PRE_first_tail_x15_r0_body.s0 2673467 ++ (arrOf PRE_first_tail_x15_r0_body.s949 2673467).drop (arrOf PRE_first_tail_x15_r0_body.s0 2673467).length) })
kernel_rfl PRE_first_tail_x15_r0_body.zw98_4910 : (PRE_first_tail_x15_r0_body.s950.heap.get 4910).isSome = true
kernel_rfl PRE_first_tail_x15_r0_body.zw98_2673472 : (PRE_first_tail_x15_r0_body.s950.heap.get 2673472).isSome = true
kernel_rfl PRE_first_tail_x15_r0_body.zw98_2673473 : (PRE_first_tail_x15_r0_body.s950.heap.get 2673473).isSome = true
-- the heap: the changed list in range, holding the stage's written and fresh addresses; the canonical side's image
kernel_rfl PRE_first_tail_x15_r0_body.zclbd98 : PRE_first_tail_x15_r0_body.cl98.all (fun b => Nat.blt (b / 4096) (4 ^ 31)) = true
kernel_rfl PRE_first_tail_x15_r0_body.zwr98 : PRE_first_tail_x15_r0_body.st98.wr.all (fun b => !Nat.blt b PRE_first_tail_x15_r0_body.s948.next || PRE_first_tail_x15_r0_body.cl98.contains b) = true
def PRE_first_tail_x15_r0_body.zl98 : List Nat := PRE_first_tail_x15_r0_body.cl98.filter fun a => !(List.contains [2665, 2673467] a)
kernel_rfl PRE_first_tail_x15_r0_body.zimgE98 : PRE_first_tail_x15_r0_body.zl98.map (fun a => PRE_first_tail_x15_r0_body.s949.heap.get (PRE_first_tail_x15_r0_body.kappa98.a a)) = PRE_first_tail_x15_r0_body.zl98.map (fun a => (PRE_first_tail_x15_r0_body.s950.heap.get a).map PRE_first_tail_x15_r0_body.kappa98.hobj)
theorem PRE_first_tail_x15_r0_body.zimg98 : HeapImg PRE_first_tail_x15_r0_body.kappa98 PRE_first_tail_x15_r0_body.s950 PRE_first_tail_x15_r0_body.s949 PRE_first_tail_x15_r0_body.zl98 := PRE_first_tail_x15_r0_body.zimgE98
-- the roots and their supports
kernel_rfl PRE_first_tail_x15_r0_body.zctl98 : PRE_first_tail_x15_r0_body.s949.ctl = PRE_first_tail_x15_r0_body.kappa98.ctl PRE_first_tail_x15_r0_body.s950.ctl
kernel_rfl PRE_first_tail_x15_r0_body.zstack98 : PRE_first_tail_x15_r0_body.s949.stack = PRE_first_tail_x15_r0_body.s950.stack.map PRE_first_tail_x15_r0_body.kappa98.frame
kernel_rfl PRE_first_tail_x15_r0_body.zjobs98 : PRE_first_tail_x15_r0_body.s949.jobs = PRE_first_tail_x15_r0_body.s950.jobs.map PRE_first_tail_x15_r0_body.kappa98.job
kernel_rfl PRE_first_tail_x15_r0_body.zstores98 : PRE_first_tail_x15_r0_body.s949.stores = PRE_first_tail_x15_r0_body.kappa98.stores PRE_first_tail_x15_r0_body.s950.stores
kernel_rfl PRE_first_tail_x15_r0_body.zroots98 : checkRootsSupp PRE_first_tail_x15_r0_body.s950 4243 = true
kernel_rfl PRE_first_tail_x15_r0_body.znC98 : PRE_first_tail_x15_r0_body.S948.tab.length + PRE_first_tail_x15_r0_body.cws98.length = 4243
-- the map as `Conv.compact_shift` states it (the call's counters for the literals)
kernel_rfl PRE_first_tail_x15_r0_body.zkap98 : PRE_first_tail_x15_r0_body.kappa98 = Conv.Map.compact PRE_first_tail_x15_r0_body.s948.next 2751595 PRE_first_tail_x15_r0_body.S948.tab.length PRE_first_tail_x15_r0_body.pl98 (PRE_first_tail_x15_r0_body.nr98.map NumV.ref) PRE_first_tail_x15_r0_body.kd98.big
  PRE_first_tail_x15_r0_body.kd98.region PRE_first_tail_x15_r0_body.kd98.nodeF
-- the bridge inactive at the canonical state (`Conv.FullShiftQ.toX`; the merged state's bridge is the canonical's: cbridge)
theorem PRE_first_tail_x15_r0_body.zbin98 : (Host.Ts.Sim.Full.bridgeOf PRE_first_tail_x15_r0_body.s950.ffi).active = false := (Host.Load.Boot.replay_active Host.Load.Run.Prompt.P.oblog2818)
-- the JS bookkeeping's step (`Conv.JClean.step` over the changed list) and the canonical roots' bigint freedom
kernel_rfl PRE_first_tail_x15_r0_body.zjc98 : Conv.jcleanListB (⟨20127, 17218, 2751576, 4243⟩ : Conv.Cnt) PRE_first_tail_x15_r0_body.s950 PRE_first_tail_x15_r0_body.cl98 = true
kernel_rfl PRE_first_tail_x15_r0_body.zrootsB98 : noBigRootsP (fun i => !Conv.oldBigB (⟨20127, 17218, 2751576, 4243⟩ : Conv.Cnt) i) PRE_first_tail_x15_r0_body.s950.trace PRE_first_tail_x15_r0_body.s950 = true
kernel_rfl PRE_first_tail_x15_r0_body.zhm98 : Nat.ble (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s0.ffi).mlx.nnext 17218 = true
theorem PRE_first_tail_x15_r0_body.cjcl98 (h : Conv.JClean (⟨20127, 17218, 2751575, 4243⟩ : Conv.Cnt) PRE_first_tail_x15_r0_body.s948) : Conv.JClean (⟨20127, 17218, 2751576, 4243⟩ : Conv.Cnt) PRE_first_tail_x15_r0_body.s950 :=
  Conv.JClean.step h (Conv.Cnt.le_of_leB PRE_first_tail_x15_r0_body.cle98)
    (Conv.heap_off_setAll PRE_first_tail_x15_r0_body.cheap98 fun a ha => Nat.blt_eq.mp (List.all_eq_true.mp PRE_first_tail_x15_r0_body.zclbd98 a ha)) PRE_first_tail_x15_r0_body.zjc98

end Host.Load.Run.Tpl
