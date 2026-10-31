import host.sim.template.a4pre_first_tail_x15_r0_body.SiteS83
import host.sim.template.a4pre_first_tail_x15_r0_body.SiteK83
import host.sim.template.a4pre_first_tail_x15_r0_body.SiteF83
import host.sim.conv.CompactShift
import host.sim.template.Check
import host.sim.BigFreeP
import host.sim.template.CallGen
set_option Elab.async false
namespace Host.Load.Run.Tpl
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
open Host.Ts Host.Ts.Sim Host.Ts.Sim.Template

/-! The compaction's state shift at call site 83 of chain `PRE_first_tail_x15_r0_body` (`Conv.compact_shift`): the call `PRE_first_tail_x15_r0_body.s733`, the merged
state `PRE_first_tail_x15_r0_body.s734`, the canonical state `PRE_first_tail_x15_r0_body.s735`; its frames [2665,2673467,2673472,2673473] (kept arrays [2665,2673467]). -/

-- the map's places and counters
kernel_rfl PRE_first_tail_x15_r0_body.zpl83 : PRE_first_tail_x15_r0_body.pl83.all (Nat.ble PRE_first_tail_x15_r0_body.s733.next) = true
kernel_rfl PRE_first_tail_x15_r0_body.zplnd83 : nodupT PRE_first_tail_x15_r0_body.pl83 PTrie.nil = true
kernel_rfl PRE_first_tail_x15_r0_body.zn183 : Nat.ble PRE_first_tail_x15_r0_body.s733.next 2739888 = true
kernel_rfl PRE_first_tail_x15_r0_body.zfirst83 : Nat.ble aFirst PRE_first_tail_x15_r0_body.s733.next = true
kernel_rfl PRE_first_tail_x15_r0_body.zscn83 : PRE_first_tail_x15_r0_body.s735.next = PRE_first_tail_x15_r0_body.s733.next + PRE_first_tail_x15_r0_body.pl83.length
kernel_rfl PRE_first_tail_x15_r0_body.zsmn83 : PRE_first_tail_x15_r0_body.s734.next = 2739888
kernel_rfl PRE_first_tail_x15_r0_body.zgrow83 : Nat.ble PRE_first_tail_x15_r0_body.s735.next PRE_first_tail_x15_r0_body.s734.next = true
-- the tables
kernel_rfl PRE_first_tail_x15_r0_body.zfresh83 : PRE_first_tail_x15_r0_body.S733.tab.all (fun e => PRE_first_tail_x15_r0_body.cws83.all fun v => e.noVar v) = true
kernel_rfl PRE_first_tail_x15_r0_body.zcnd83 : nodupT PRE_first_tail_x15_r0_body.cws83 PTrie.nil = true
kernel_rfl PRE_first_tail_x15_r0_body.znrHi83 : PRE_first_tail_x15_r0_body.nr83.all (fun r => Nat.blt r PRE_first_tail_x15_r0_body.S734.tab.length) = true
-- the frames: every framed address below the call's counter; the kept arrays the chain start's, extended in the merged state
kernel_rfl PRE_first_tail_x15_r0_body.zfrlt83 : [2665, 2673467, 2673472, 2673473].all (fun a => Nat.blt a PRE_first_tail_x15_r0_body.s733.next) = true
kernel_rfl PRE_first_tail_x15_r0_body.zg83_2665 : PRE_first_tail_x15_r0_body.s735.heap.get 2665 = some (.obj (objOf PRE_first_tail_x15_r0_body.s735 2665))
kernel_rfl PRE_first_tail_x15_r0_body.zk83_2665 : (objOf PRE_first_tail_x15_r0_body.s735 2665).kind = .array (arrOf PRE_first_tail_x15_r0_body.s0 2665)
kernel_rfl PRE_first_tail_x15_r0_body.zm83_2665 : PRE_first_tail_x15_r0_body.s734.heap.get 2665 = some (.obj { PRE_first_tail_x15_r0_body.kappa83.obj (objOf PRE_first_tail_x15_r0_body.s735 2665) with
  kind := .array (arrOf PRE_first_tail_x15_r0_body.s0 2665 ++ (arrOf PRE_first_tail_x15_r0_body.s734 2665).drop (arrOf PRE_first_tail_x15_r0_body.s0 2665).length) })
kernel_rfl PRE_first_tail_x15_r0_body.zg83_2673467 : PRE_first_tail_x15_r0_body.s735.heap.get 2673467 = some (.obj (objOf PRE_first_tail_x15_r0_body.s735 2673467))
kernel_rfl PRE_first_tail_x15_r0_body.zk83_2673467 : (objOf PRE_first_tail_x15_r0_body.s735 2673467).kind = .array (arrOf PRE_first_tail_x15_r0_body.s0 2673467)
kernel_rfl PRE_first_tail_x15_r0_body.zm83_2673467 : PRE_first_tail_x15_r0_body.s734.heap.get 2673467 = some (.obj { PRE_first_tail_x15_r0_body.kappa83.obj (objOf PRE_first_tail_x15_r0_body.s735 2673467) with
  kind := .array (arrOf PRE_first_tail_x15_r0_body.s0 2673467 ++ (arrOf PRE_first_tail_x15_r0_body.s734 2673467).drop (arrOf PRE_first_tail_x15_r0_body.s0 2673467).length) })
kernel_rfl PRE_first_tail_x15_r0_body.zw83_4910 : (PRE_first_tail_x15_r0_body.s735.heap.get 4910).isSome = true
kernel_rfl PRE_first_tail_x15_r0_body.zw83_2673472 : (PRE_first_tail_x15_r0_body.s735.heap.get 2673472).isSome = true
kernel_rfl PRE_first_tail_x15_r0_body.zw83_2673473 : (PRE_first_tail_x15_r0_body.s735.heap.get 2673473).isSome = true
-- the heap: the changed list in range, holding the stage's written and fresh addresses; the canonical side's image
kernel_rfl PRE_first_tail_x15_r0_body.zclbd83 : PRE_first_tail_x15_r0_body.cl83.all (fun b => Nat.blt (b / 4096) (4 ^ 31)) = true
kernel_rfl PRE_first_tail_x15_r0_body.zwr83 : PRE_first_tail_x15_r0_body.st83.wr.all (fun b => !Nat.blt b PRE_first_tail_x15_r0_body.s733.next || PRE_first_tail_x15_r0_body.cl83.contains b) = true
def PRE_first_tail_x15_r0_body.zl83 : List Nat := PRE_first_tail_x15_r0_body.cl83.filter fun a => !(List.contains [2665, 2673467] a)
kernel_rfl PRE_first_tail_x15_r0_body.zimgE83 : PRE_first_tail_x15_r0_body.zl83.map (fun a => PRE_first_tail_x15_r0_body.s734.heap.get (PRE_first_tail_x15_r0_body.kappa83.a a)) = PRE_first_tail_x15_r0_body.zl83.map (fun a => (PRE_first_tail_x15_r0_body.s735.heap.get a).map PRE_first_tail_x15_r0_body.kappa83.hobj)
theorem PRE_first_tail_x15_r0_body.zimg83 : HeapImg PRE_first_tail_x15_r0_body.kappa83 PRE_first_tail_x15_r0_body.s735 PRE_first_tail_x15_r0_body.s734 PRE_first_tail_x15_r0_body.zl83 := PRE_first_tail_x15_r0_body.zimgE83
-- the roots and their supports
kernel_rfl PRE_first_tail_x15_r0_body.zctl83 : PRE_first_tail_x15_r0_body.s734.ctl = PRE_first_tail_x15_r0_body.kappa83.ctl PRE_first_tail_x15_r0_body.s735.ctl
kernel_rfl PRE_first_tail_x15_r0_body.zstack83 : PRE_first_tail_x15_r0_body.s734.stack = PRE_first_tail_x15_r0_body.s735.stack.map PRE_first_tail_x15_r0_body.kappa83.frame
kernel_rfl PRE_first_tail_x15_r0_body.zjobs83 : PRE_first_tail_x15_r0_body.s734.jobs = PRE_first_tail_x15_r0_body.s735.jobs.map PRE_first_tail_x15_r0_body.kappa83.job
kernel_rfl PRE_first_tail_x15_r0_body.zstores83 : PRE_first_tail_x15_r0_body.s734.stores = PRE_first_tail_x15_r0_body.kappa83.stores PRE_first_tail_x15_r0_body.s735.stores
kernel_rfl PRE_first_tail_x15_r0_body.zroots83 : checkRootsSupp PRE_first_tail_x15_r0_body.s735 3601 = true
kernel_rfl PRE_first_tail_x15_r0_body.znC83 : PRE_first_tail_x15_r0_body.S733.tab.length + PRE_first_tail_x15_r0_body.cws83.length = 3601
-- the map as `Conv.compact_shift` states it (the call's counters for the literals)
kernel_rfl PRE_first_tail_x15_r0_body.zkap83 : PRE_first_tail_x15_r0_body.kappa83 = Conv.Map.compact PRE_first_tail_x15_r0_body.s733.next 2739888 PRE_first_tail_x15_r0_body.S733.tab.length PRE_first_tail_x15_r0_body.pl83 (PRE_first_tail_x15_r0_body.nr83.map NumV.ref) PRE_first_tail_x15_r0_body.kd83.big
  PRE_first_tail_x15_r0_body.kd83.region PRE_first_tail_x15_r0_body.kd83.nodeF
-- the bridge inactive at the canonical state (`Conv.FullShiftQ.toX`; the merged state's bridge is the canonical's: cbridge)
theorem PRE_first_tail_x15_r0_body.zbin83 : (Host.Ts.Sim.Full.bridgeOf PRE_first_tail_x15_r0_body.s735.ffi).active = false := (Host.Load.Boot.replay_active Host.Load.Run.Prompt.P.oblog2818)
-- the JS bookkeeping's step (`Conv.JClean.step` over the changed list) and the canonical roots' bigint freedom
kernel_rfl PRE_first_tail_x15_r0_body.zjc83 : Conv.jcleanListB (⟨19833, 16918, 2739878, 3601⟩ : Conv.Cnt) PRE_first_tail_x15_r0_body.s735 PRE_first_tail_x15_r0_body.cl83 = true
kernel_rfl PRE_first_tail_x15_r0_body.zroots283 : noBigRootsP (fun i => !Conv.oldBigB (⟨19833, 16918, 2739878, 3601⟩ : Conv.Cnt) i) PRE_first_tail_x15_r0_body.s735.trace PRE_first_tail_x15_r0_body.s735 = true
kernel_rfl PRE_first_tail_x15_r0_body.zhm83 : Nat.ble (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s0.ffi).mlx.nnext 16918 = true
theorem PRE_first_tail_x15_r0_body.cjcl83 (h : Conv.JClean (⟨19833, 16918, 2739877, 3601⟩ : Conv.Cnt) PRE_first_tail_x15_r0_body.s733) : Conv.JClean (⟨19833, 16918, 2739878, 3601⟩ : Conv.Cnt) PRE_first_tail_x15_r0_body.s735 :=
  Conv.JClean.step h (Conv.Cnt.le_of_leB PRE_first_tail_x15_r0_body.cle83)
    (Conv.heap_off_setAll PRE_first_tail_x15_r0_body.cheap83 fun a ha => Nat.blt_eq.mp (List.all_eq_true.mp PRE_first_tail_x15_r0_body.zclbd83 a ha)) PRE_first_tail_x15_r0_body.zjc83

end Host.Load.Run.Tpl
