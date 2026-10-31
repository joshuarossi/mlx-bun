import host.sim.template.a4pre_first_tail_x15_r0_body.SiteS112
import host.sim.template.a4pre_first_tail_x15_r0_body.SiteK112
import host.sim.template.a4pre_first_tail_x15_r0_body.SiteF112
import host.sim.conv.CompactShift
import host.sim.template.Check
import host.sim.BigFreeP
import host.sim.template.CallGen
set_option Elab.async false
namespace Host.Load.Run.Tpl
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
open Host.Ts Host.Ts.Sim Host.Ts.Sim.Template

/-! The compaction's state shift at call site 112 of chain `PRE_first_tail_x15_r0_body` (`Conv.compact_shift`): the call `PRE_first_tail_x15_r0_body.s993`, the merged
state `PRE_first_tail_x15_r0_body.s994`, the canonical state `PRE_first_tail_x15_r0_body.s995`; its frames [2665,2673467,2673472,2673473] (kept arrays [2665,2673467]). -/

-- the map's places and counters
kernel_rfl PRE_first_tail_x15_r0_body.zpl112 : PRE_first_tail_x15_r0_body.pl112.all (Nat.ble PRE_first_tail_x15_r0_body.s993.next) = true
kernel_rfl PRE_first_tail_x15_r0_body.zplnd112 : nodupT PRE_first_tail_x15_r0_body.pl112 PTrie.nil = true
kernel_rfl PRE_first_tail_x15_r0_body.zn1112 : Nat.ble PRE_first_tail_x15_r0_body.s993.next 2762965 = true
kernel_rfl PRE_first_tail_x15_r0_body.zfirst112 : Nat.ble aFirst PRE_first_tail_x15_r0_body.s993.next = true
kernel_rfl PRE_first_tail_x15_r0_body.zscn112 : PRE_first_tail_x15_r0_body.s995.next = PRE_first_tail_x15_r0_body.s993.next + PRE_first_tail_x15_r0_body.pl112.length
kernel_rfl PRE_first_tail_x15_r0_body.zsmn112 : PRE_first_tail_x15_r0_body.s994.next = 2762965
kernel_rfl PRE_first_tail_x15_r0_body.zgrow112 : Nat.ble PRE_first_tail_x15_r0_body.s995.next PRE_first_tail_x15_r0_body.s994.next = true
-- the tables
kernel_rfl PRE_first_tail_x15_r0_body.zfresh112 : PRE_first_tail_x15_r0_body.S993.tab.all (fun e => PRE_first_tail_x15_r0_body.cws112.all fun v => e.noVar v) = true
kernel_rfl PRE_first_tail_x15_r0_body.zcnd112 : nodupT PRE_first_tail_x15_r0_body.cws112 PTrie.nil = true
kernel_rfl PRE_first_tail_x15_r0_body.znrHi112 : PRE_first_tail_x15_r0_body.nr112.all (fun r => Nat.blt r PRE_first_tail_x15_r0_body.S994.tab.length) = true
-- the frames: every framed address below the call's counter; the kept arrays the chain start's, extended in the merged state
kernel_rfl PRE_first_tail_x15_r0_body.zfrlt112 : [2665, 2673467, 2673472, 2673473].all (fun a => Nat.blt a PRE_first_tail_x15_r0_body.s993.next) = true
kernel_rfl PRE_first_tail_x15_r0_body.zg112_2665 : PRE_first_tail_x15_r0_body.s995.heap.get 2665 = some (.obj (objOf PRE_first_tail_x15_r0_body.s995 2665))
kernel_rfl PRE_first_tail_x15_r0_body.zk112_2665 : (objOf PRE_first_tail_x15_r0_body.s995 2665).kind = .array (arrOf PRE_first_tail_x15_r0_body.s0 2665)
kernel_rfl PRE_first_tail_x15_r0_body.zm112_2665 : PRE_first_tail_x15_r0_body.s994.heap.get 2665 = some (.obj { PRE_first_tail_x15_r0_body.kappa112.obj (objOf PRE_first_tail_x15_r0_body.s995 2665) with
  kind := .array (arrOf PRE_first_tail_x15_r0_body.s0 2665 ++ (arrOf PRE_first_tail_x15_r0_body.s994 2665).drop (arrOf PRE_first_tail_x15_r0_body.s0 2665).length) })
kernel_rfl PRE_first_tail_x15_r0_body.zg112_2673467 : PRE_first_tail_x15_r0_body.s995.heap.get 2673467 = some (.obj (objOf PRE_first_tail_x15_r0_body.s995 2673467))
kernel_rfl PRE_first_tail_x15_r0_body.zk112_2673467 : (objOf PRE_first_tail_x15_r0_body.s995 2673467).kind = .array (arrOf PRE_first_tail_x15_r0_body.s0 2673467)
kernel_rfl PRE_first_tail_x15_r0_body.zm112_2673467 : PRE_first_tail_x15_r0_body.s994.heap.get 2673467 = some (.obj { PRE_first_tail_x15_r0_body.kappa112.obj (objOf PRE_first_tail_x15_r0_body.s995 2673467) with
  kind := .array (arrOf PRE_first_tail_x15_r0_body.s0 2673467 ++ (arrOf PRE_first_tail_x15_r0_body.s994 2673467).drop (arrOf PRE_first_tail_x15_r0_body.s0 2673467).length) })
kernel_rfl PRE_first_tail_x15_r0_body.zw112_4910 : (PRE_first_tail_x15_r0_body.s995.heap.get 4910).isSome = true
kernel_rfl PRE_first_tail_x15_r0_body.zw112_2673472 : (PRE_first_tail_x15_r0_body.s995.heap.get 2673472).isSome = true
kernel_rfl PRE_first_tail_x15_r0_body.zw112_2673473 : (PRE_first_tail_x15_r0_body.s995.heap.get 2673473).isSome = true
-- the heap: the changed list in range, holding the stage's written and fresh addresses; the canonical side's image
kernel_rfl PRE_first_tail_x15_r0_body.zclbd112 : PRE_first_tail_x15_r0_body.cl112.all (fun b => Nat.blt (b / 4096) (4 ^ 31)) = true
kernel_rfl PRE_first_tail_x15_r0_body.zwr112 : PRE_first_tail_x15_r0_body.st112.wr.all (fun b => !Nat.blt b PRE_first_tail_x15_r0_body.s993.next || PRE_first_tail_x15_r0_body.cl112.contains b) = true
def PRE_first_tail_x15_r0_body.zl112 : List Nat := PRE_first_tail_x15_r0_body.cl112.filter fun a => !(List.contains [2665, 2673467] a)
kernel_rfl PRE_first_tail_x15_r0_body.zimgE112 : PRE_first_tail_x15_r0_body.zl112.map (fun a => PRE_first_tail_x15_r0_body.s994.heap.get (PRE_first_tail_x15_r0_body.kappa112.a a)) = PRE_first_tail_x15_r0_body.zl112.map (fun a => (PRE_first_tail_x15_r0_body.s995.heap.get a).map PRE_first_tail_x15_r0_body.kappa112.hobj)
theorem PRE_first_tail_x15_r0_body.zimg112 : HeapImg PRE_first_tail_x15_r0_body.kappa112 PRE_first_tail_x15_r0_body.s995 PRE_first_tail_x15_r0_body.s994 PRE_first_tail_x15_r0_body.zl112 := PRE_first_tail_x15_r0_body.zimgE112
-- the roots and their supports
kernel_rfl PRE_first_tail_x15_r0_body.zctl112 : PRE_first_tail_x15_r0_body.s994.ctl = PRE_first_tail_x15_r0_body.kappa112.ctl PRE_first_tail_x15_r0_body.s995.ctl
kernel_rfl PRE_first_tail_x15_r0_body.zstack112 : PRE_first_tail_x15_r0_body.s994.stack = PRE_first_tail_x15_r0_body.s995.stack.map PRE_first_tail_x15_r0_body.kappa112.frame
kernel_rfl PRE_first_tail_x15_r0_body.zjobs112 : PRE_first_tail_x15_r0_body.s994.jobs = PRE_first_tail_x15_r0_body.s995.jobs.map PRE_first_tail_x15_r0_body.kappa112.job
kernel_rfl PRE_first_tail_x15_r0_body.zstores112 : PRE_first_tail_x15_r0_body.s994.stores = PRE_first_tail_x15_r0_body.kappa112.stores PRE_first_tail_x15_r0_body.s995.stores
kernel_rfl PRE_first_tail_x15_r0_body.zroots112 : checkRootsSupp PRE_first_tail_x15_r0_body.s995 4868 = true
kernel_rfl PRE_first_tail_x15_r0_body.znC112 : PRE_first_tail_x15_r0_body.S993.tab.length + PRE_first_tail_x15_r0_body.cws112.length = 4868
-- the map as `Conv.compact_shift` states it (the call's counters for the literals)
kernel_rfl PRE_first_tail_x15_r0_body.zkap112 : PRE_first_tail_x15_r0_body.kappa112 = Conv.Map.compact PRE_first_tail_x15_r0_body.s993.next 2762965 PRE_first_tail_x15_r0_body.S993.tab.length PRE_first_tail_x15_r0_body.pl112 (PRE_first_tail_x15_r0_body.nr112.map NumV.ref) PRE_first_tail_x15_r0_body.kd112.big
  PRE_first_tail_x15_r0_body.kd112.region PRE_first_tail_x15_r0_body.kd112.nodeF
-- the bridge inactive at the canonical state (`Conv.FullShiftQ.toX`; the merged state's bridge is the canonical's: cbridge)
theorem PRE_first_tail_x15_r0_body.zbin112 : (Host.Ts.Sim.Full.bridgeOf PRE_first_tail_x15_r0_body.s995.ffi).active = false := (Host.Load.Boot.replay_active Host.Load.Run.Prompt.P.oblog2818)
-- the JS bookkeeping's step (`Conv.JClean.step` over the changed list) and the canonical roots' bigint freedom
kernel_rfl PRE_first_tail_x15_r0_body.zjc112 : Conv.jcleanListB (⟨20413, 17514, 2762963, 4868⟩ : Conv.Cnt) PRE_first_tail_x15_r0_body.s995 PRE_first_tail_x15_r0_body.cl112 = true
kernel_rfl PRE_first_tail_x15_r0_body.zroots2112 : noBigRootsP (fun i => !Conv.oldBigB (⟨20413, 17514, 2762963, 4868⟩ : Conv.Cnt) i) PRE_first_tail_x15_r0_body.s995.trace PRE_first_tail_x15_r0_body.s995 = true
kernel_rfl PRE_first_tail_x15_r0_body.zhm112 : Nat.ble (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s0.ffi).mlx.nnext 17514 = true
theorem PRE_first_tail_x15_r0_body.cjcl112 (h : Conv.JClean (⟨20413, 17514, 2762963, 4868⟩ : Conv.Cnt) PRE_first_tail_x15_r0_body.s993) : Conv.JClean (⟨20413, 17514, 2762963, 4868⟩ : Conv.Cnt) PRE_first_tail_x15_r0_body.s995 :=
  Conv.JClean.step h (Conv.Cnt.le_of_leB PRE_first_tail_x15_r0_body.cle112)
    (Conv.heap_off_setAll PRE_first_tail_x15_r0_body.cheap112 fun a ha => Nat.blt_eq.mp (List.all_eq_true.mp PRE_first_tail_x15_r0_body.zclbd112 a ha)) PRE_first_tail_x15_r0_body.zjc112

end Host.Load.Run.Tpl
