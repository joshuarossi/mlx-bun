import host.sim.template.a4pre_first_tail_x15_r0_body.SiteS107
import host.sim.template.a4pre_first_tail_x15_r0_body.SiteK107
import host.sim.template.a4pre_first_tail_x15_r0_body.SiteF107
import host.sim.conv.CompactShift
import host.sim.template.Check
import host.sim.BigFreeP
import host.sim.template.CallGen
set_option Elab.async false
namespace Host.Load.Run.Tpl
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
open Host.Ts Host.Ts.Sim Host.Ts.Sim.Template

/-! The compaction's state shift at call site 107 of chain `PRE_first_tail_x15_r0_body` (`Conv.compact_shift`): the call `PRE_first_tail_x15_r0_body.s943`, the merged
state `PRE_first_tail_x15_r0_body.s944`, the canonical state `PRE_first_tail_x15_r0_body.s945`; its frames [2665,2673467,2673472,2673473] (kept arrays [2665,2673467]). -/

-- the map's places and counters
kernel_rfl PRE_first_tail_x15_r0_body.zpl107 : PRE_first_tail_x15_r0_body.pl107.all (Nat.ble PRE_first_tail_x15_r0_body.s943.next) = true
kernel_rfl PRE_first_tail_x15_r0_body.zplnd107 : nodupT PRE_first_tail_x15_r0_body.pl107 PTrie.nil = true
kernel_rfl PRE_first_tail_x15_r0_body.zn1107 : Nat.ble PRE_first_tail_x15_r0_body.s943.next 2758728 = true
kernel_rfl PRE_first_tail_x15_r0_body.zfirst107 : Nat.ble aFirst PRE_first_tail_x15_r0_body.s943.next = true
kernel_rfl PRE_first_tail_x15_r0_body.zscn107 : PRE_first_tail_x15_r0_body.s945.next = PRE_first_tail_x15_r0_body.s943.next + PRE_first_tail_x15_r0_body.pl107.length
kernel_rfl PRE_first_tail_x15_r0_body.zsmn107 : PRE_first_tail_x15_r0_body.s944.next = 2758728
kernel_rfl PRE_first_tail_x15_r0_body.zgrow107 : Nat.ble PRE_first_tail_x15_r0_body.s945.next PRE_first_tail_x15_r0_body.s944.next = true
-- the tables
kernel_rfl PRE_first_tail_x15_r0_body.zfresh107 : PRE_first_tail_x15_r0_body.S943.tab.all (fun e => PRE_first_tail_x15_r0_body.cws107.all fun v => e.noVar v) = true
kernel_rfl PRE_first_tail_x15_r0_body.zcnd107 : nodupT PRE_first_tail_x15_r0_body.cws107 PTrie.nil = true
kernel_rfl PRE_first_tail_x15_r0_body.znrHi107 : PRE_first_tail_x15_r0_body.nr107.all (fun r => Nat.blt r PRE_first_tail_x15_r0_body.S944.tab.length) = true
-- the frames: every framed address below the call's counter; the kept arrays the chain start's, extended in the merged state
kernel_rfl PRE_first_tail_x15_r0_body.zfrlt107 : [2665, 2673467, 2673472, 2673473].all (fun a => Nat.blt a PRE_first_tail_x15_r0_body.s943.next) = true
kernel_rfl PRE_first_tail_x15_r0_body.zg107_2665 : PRE_first_tail_x15_r0_body.s945.heap.get 2665 = some (.obj (objOf PRE_first_tail_x15_r0_body.s945 2665))
kernel_rfl PRE_first_tail_x15_r0_body.zk107_2665 : (objOf PRE_first_tail_x15_r0_body.s945 2665).kind = .array (arrOf PRE_first_tail_x15_r0_body.s0 2665)
kernel_rfl PRE_first_tail_x15_r0_body.zm107_2665 : PRE_first_tail_x15_r0_body.s944.heap.get 2665 = some (.obj { PRE_first_tail_x15_r0_body.kappa107.obj (objOf PRE_first_tail_x15_r0_body.s945 2665) with
  kind := .array (arrOf PRE_first_tail_x15_r0_body.s0 2665 ++ (arrOf PRE_first_tail_x15_r0_body.s944 2665).drop (arrOf PRE_first_tail_x15_r0_body.s0 2665).length) })
kernel_rfl PRE_first_tail_x15_r0_body.zg107_2673467 : PRE_first_tail_x15_r0_body.s945.heap.get 2673467 = some (.obj (objOf PRE_first_tail_x15_r0_body.s945 2673467))
kernel_rfl PRE_first_tail_x15_r0_body.zk107_2673467 : (objOf PRE_first_tail_x15_r0_body.s945 2673467).kind = .array (arrOf PRE_first_tail_x15_r0_body.s0 2673467)
kernel_rfl PRE_first_tail_x15_r0_body.zm107_2673467 : PRE_first_tail_x15_r0_body.s944.heap.get 2673467 = some (.obj { PRE_first_tail_x15_r0_body.kappa107.obj (objOf PRE_first_tail_x15_r0_body.s945 2673467) with
  kind := .array (arrOf PRE_first_tail_x15_r0_body.s0 2673467 ++ (arrOf PRE_first_tail_x15_r0_body.s944 2673467).drop (arrOf PRE_first_tail_x15_r0_body.s0 2673467).length) })
kernel_rfl PRE_first_tail_x15_r0_body.zw107_4910 : (PRE_first_tail_x15_r0_body.s945.heap.get 4910).isSome = true
kernel_rfl PRE_first_tail_x15_r0_body.zw107_2673472 : (PRE_first_tail_x15_r0_body.s945.heap.get 2673472).isSome = true
kernel_rfl PRE_first_tail_x15_r0_body.zw107_2673473 : (PRE_first_tail_x15_r0_body.s945.heap.get 2673473).isSome = true
-- the heap: the changed list in range, holding the stage's written and fresh addresses; the canonical side's image
kernel_rfl PRE_first_tail_x15_r0_body.zclbd107 : PRE_first_tail_x15_r0_body.cl107.all (fun b => Nat.blt (b / 4096) (4 ^ 31)) = true
kernel_rfl PRE_first_tail_x15_r0_body.zwr107 : PRE_first_tail_x15_r0_body.st107.wr.all (fun b => !Nat.blt b PRE_first_tail_x15_r0_body.s943.next || PRE_first_tail_x15_r0_body.cl107.contains b) = true
def PRE_first_tail_x15_r0_body.zl107 : List Nat := PRE_first_tail_x15_r0_body.cl107.filter fun a => !(List.contains [2665, 2673467] a)
kernel_rfl PRE_first_tail_x15_r0_body.zimgE107 : PRE_first_tail_x15_r0_body.zl107.map (fun a => PRE_first_tail_x15_r0_body.s944.heap.get (PRE_first_tail_x15_r0_body.kappa107.a a)) = PRE_first_tail_x15_r0_body.zl107.map (fun a => (PRE_first_tail_x15_r0_body.s945.heap.get a).map PRE_first_tail_x15_r0_body.kappa107.hobj)
theorem PRE_first_tail_x15_r0_body.zimg107 : HeapImg PRE_first_tail_x15_r0_body.kappa107 PRE_first_tail_x15_r0_body.s945 PRE_first_tail_x15_r0_body.s944 PRE_first_tail_x15_r0_body.zl107 := PRE_first_tail_x15_r0_body.zimgE107
-- the roots and their supports
kernel_rfl PRE_first_tail_x15_r0_body.zctl107 : PRE_first_tail_x15_r0_body.s944.ctl = PRE_first_tail_x15_r0_body.kappa107.ctl PRE_first_tail_x15_r0_body.s945.ctl
kernel_rfl PRE_first_tail_x15_r0_body.zstack107 : PRE_first_tail_x15_r0_body.s944.stack = PRE_first_tail_x15_r0_body.s945.stack.map PRE_first_tail_x15_r0_body.kappa107.frame
kernel_rfl PRE_first_tail_x15_r0_body.zjobs107 : PRE_first_tail_x15_r0_body.s944.jobs = PRE_first_tail_x15_r0_body.s945.jobs.map PRE_first_tail_x15_r0_body.kappa107.job
kernel_rfl PRE_first_tail_x15_r0_body.zstores107 : PRE_first_tail_x15_r0_body.s944.stores = PRE_first_tail_x15_r0_body.kappa107.stores PRE_first_tail_x15_r0_body.s945.stores
kernel_rfl PRE_first_tail_x15_r0_body.zroots107 : checkRootsSupp PRE_first_tail_x15_r0_body.s945 4627 = true
kernel_rfl PRE_first_tail_x15_r0_body.znC107 : PRE_first_tail_x15_r0_body.S943.tab.length + PRE_first_tail_x15_r0_body.cws107.length = 4627
-- the map as `Conv.compact_shift` states it (the call's counters for the literals)
kernel_rfl PRE_first_tail_x15_r0_body.zkap107 : PRE_first_tail_x15_r0_body.kappa107 = Conv.Map.compact PRE_first_tail_x15_r0_body.s943.next 2758728 PRE_first_tail_x15_r0_body.S943.tab.length PRE_first_tail_x15_r0_body.pl107 (PRE_first_tail_x15_r0_body.nr107.map NumV.ref) PRE_first_tail_x15_r0_body.kd107.big
  PRE_first_tail_x15_r0_body.kd107.region PRE_first_tail_x15_r0_body.kd107.nodeF
-- the bridge inactive at the canonical state (`Conv.FullShiftQ.toX`; the merged state's bridge is the canonical's: cbridge)
theorem PRE_first_tail_x15_r0_body.zbin107 : (Host.Ts.Sim.Full.bridgeOf PRE_first_tail_x15_r0_body.s945.ffi).active = false := (Host.Load.Boot.replay_active Host.Load.Run.Prompt.P.oblog2818)
-- the JS bookkeeping's step (`Conv.JClean.step` over the changed list) and the canonical roots' bigint freedom
kernel_rfl PRE_first_tail_x15_r0_body.zjc107 : Conv.jcleanListB (⟨20305, 17392, 2758718, 4627⟩ : Conv.Cnt) PRE_first_tail_x15_r0_body.s945 PRE_first_tail_x15_r0_body.cl107 = true
kernel_rfl PRE_first_tail_x15_r0_body.zroots2107 : noBigRootsP (fun i => !Conv.oldBigB (⟨20305, 17392, 2758718, 4627⟩ : Conv.Cnt) i) PRE_first_tail_x15_r0_body.s945.trace PRE_first_tail_x15_r0_body.s945 = true
kernel_rfl PRE_first_tail_x15_r0_body.zhm107 : Nat.ble (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s0.ffi).mlx.nnext 17392 = true
theorem PRE_first_tail_x15_r0_body.cjcl107 (h : Conv.JClean (⟨20305, 17392, 2758717, 4627⟩ : Conv.Cnt) PRE_first_tail_x15_r0_body.s943) : Conv.JClean (⟨20305, 17392, 2758718, 4627⟩ : Conv.Cnt) PRE_first_tail_x15_r0_body.s945 :=
  Conv.JClean.step h (Conv.Cnt.le_of_leB PRE_first_tail_x15_r0_body.cle107)
    (Conv.heap_off_setAll PRE_first_tail_x15_r0_body.cheap107 fun a ha => Nat.blt_eq.mp (List.all_eq_true.mp PRE_first_tail_x15_r0_body.zclbd107 a ha)) PRE_first_tail_x15_r0_body.zjc107

end Host.Load.Run.Tpl
