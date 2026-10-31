import host.sim.template.a4pre_first_tail_x15_r0_body.SiteS162
import host.sim.template.a4pre_first_tail_x15_r0_body.SiteK162
import host.sim.template.a4pre_first_tail_x15_r0_body.SiteF162
import host.sim.conv.CompactShift
import host.sim.template.Check
import host.sim.BigFreeP
import host.sim.template.CallGen
set_option Elab.async false
namespace Host.Load.Run.Tpl
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
open Host.Ts Host.Ts.Sim Host.Ts.Sim.Template

/-! The compaction's state shift at call site 162 of chain `PRE_first_tail_x15_r0_body` (`Conv.compact_shift`): the call `PRE_first_tail_x15_r0_body.s1433`, the merged
state `PRE_first_tail_x15_r0_body.s1434`, the canonical state `PRE_first_tail_x15_r0_body.s1435`; its frames [2665,2673467,2673472,2673473] (kept arrays [2665,2673467]). -/

-- the map's places and counters
kernel_rfl PRE_first_tail_x15_r0_body.zpl162 : PRE_first_tail_x15_r0_body.pl162.all (Nat.ble PRE_first_tail_x15_r0_body.s1433.next) = true
kernel_rfl PRE_first_tail_x15_r0_body.zplnd162 : nodupT PRE_first_tail_x15_r0_body.pl162 PTrie.nil = true
kernel_rfl PRE_first_tail_x15_r0_body.zn1162 : Nat.ble PRE_first_tail_x15_r0_body.s1433.next 2803546 = true
kernel_rfl PRE_first_tail_x15_r0_body.zfirst162 : Nat.ble aFirst PRE_first_tail_x15_r0_body.s1433.next = true
kernel_rfl PRE_first_tail_x15_r0_body.zscn162 : PRE_first_tail_x15_r0_body.s1435.next = PRE_first_tail_x15_r0_body.s1433.next + PRE_first_tail_x15_r0_body.pl162.length
kernel_rfl PRE_first_tail_x15_r0_body.zsmn162 : PRE_first_tail_x15_r0_body.s1434.next = 2803546
kernel_rfl PRE_first_tail_x15_r0_body.zgrow162 : Nat.ble PRE_first_tail_x15_r0_body.s1435.next PRE_first_tail_x15_r0_body.s1434.next = true
-- the tables
kernel_rfl PRE_first_tail_x15_r0_body.zfresh162 : PRE_first_tail_x15_r0_body.S1433.tab.all (fun e => PRE_first_tail_x15_r0_body.cws162.all fun v => e.noVar v) = true
kernel_rfl PRE_first_tail_x15_r0_body.zcnd162 : nodupT PRE_first_tail_x15_r0_body.cws162 PTrie.nil = true
kernel_rfl PRE_first_tail_x15_r0_body.znrHi162 : PRE_first_tail_x15_r0_body.nr162.all (fun r => Nat.blt r PRE_first_tail_x15_r0_body.S1434.tab.length) = true
-- the frames: every framed address below the call's counter; the kept arrays the chain start's, extended in the merged state
kernel_rfl PRE_first_tail_x15_r0_body.zfrlt162 : [2665, 2673467, 2673472, 2673473].all (fun a => Nat.blt a PRE_first_tail_x15_r0_body.s1433.next) = true
kernel_rfl PRE_first_tail_x15_r0_body.zg162_2665 : PRE_first_tail_x15_r0_body.s1435.heap.get 2665 = some (.obj (objOf PRE_first_tail_x15_r0_body.s1435 2665))
kernel_rfl PRE_first_tail_x15_r0_body.zk162_2665 : (objOf PRE_first_tail_x15_r0_body.s1435 2665).kind = .array (arrOf PRE_first_tail_x15_r0_body.s0 2665)
kernel_rfl PRE_first_tail_x15_r0_body.zm162_2665 : PRE_first_tail_x15_r0_body.s1434.heap.get 2665 = some (.obj { PRE_first_tail_x15_r0_body.kappa162.obj (objOf PRE_first_tail_x15_r0_body.s1435 2665) with
  kind := .array (arrOf PRE_first_tail_x15_r0_body.s0 2665 ++ (arrOf PRE_first_tail_x15_r0_body.s1434 2665).drop (arrOf PRE_first_tail_x15_r0_body.s0 2665).length) })
kernel_rfl PRE_first_tail_x15_r0_body.zg162_2673467 : PRE_first_tail_x15_r0_body.s1435.heap.get 2673467 = some (.obj (objOf PRE_first_tail_x15_r0_body.s1435 2673467))
kernel_rfl PRE_first_tail_x15_r0_body.zk162_2673467 : (objOf PRE_first_tail_x15_r0_body.s1435 2673467).kind = .array (arrOf PRE_first_tail_x15_r0_body.s0 2673467)
kernel_rfl PRE_first_tail_x15_r0_body.zm162_2673467 : PRE_first_tail_x15_r0_body.s1434.heap.get 2673467 = some (.obj { PRE_first_tail_x15_r0_body.kappa162.obj (objOf PRE_first_tail_x15_r0_body.s1435 2673467) with
  kind := .array (arrOf PRE_first_tail_x15_r0_body.s0 2673467 ++ (arrOf PRE_first_tail_x15_r0_body.s1434 2673467).drop (arrOf PRE_first_tail_x15_r0_body.s0 2673467).length) })
kernel_rfl PRE_first_tail_x15_r0_body.zw162_4910 : (PRE_first_tail_x15_r0_body.s1435.heap.get 4910).isSome = true
kernel_rfl PRE_first_tail_x15_r0_body.zw162_2673472 : (PRE_first_tail_x15_r0_body.s1435.heap.get 2673472).isSome = true
kernel_rfl PRE_first_tail_x15_r0_body.zw162_2673473 : (PRE_first_tail_x15_r0_body.s1435.heap.get 2673473).isSome = true
-- the heap: the changed list in range, holding the stage's written and fresh addresses; the canonical side's image
kernel_rfl PRE_first_tail_x15_r0_body.zclbd162 : PRE_first_tail_x15_r0_body.cl162.all (fun b => Nat.blt (b / 4096) (4 ^ 31)) = true
kernel_rfl PRE_first_tail_x15_r0_body.zwr162 : PRE_first_tail_x15_r0_body.st162.wr.all (fun b => !Nat.blt b PRE_first_tail_x15_r0_body.s1433.next || PRE_first_tail_x15_r0_body.cl162.contains b) = true
def PRE_first_tail_x15_r0_body.zl162 : List Nat := PRE_first_tail_x15_r0_body.cl162.filter fun a => !(List.contains [2665, 2673467] a)
kernel_rfl PRE_first_tail_x15_r0_body.zimgE162 : PRE_first_tail_x15_r0_body.zl162.map (fun a => PRE_first_tail_x15_r0_body.s1434.heap.get (PRE_first_tail_x15_r0_body.kappa162.a a)) = PRE_first_tail_x15_r0_body.zl162.map (fun a => (PRE_first_tail_x15_r0_body.s1435.heap.get a).map PRE_first_tail_x15_r0_body.kappa162.hobj)
theorem PRE_first_tail_x15_r0_body.zimg162 : HeapImg PRE_first_tail_x15_r0_body.kappa162 PRE_first_tail_x15_r0_body.s1435 PRE_first_tail_x15_r0_body.s1434 PRE_first_tail_x15_r0_body.zl162 := PRE_first_tail_x15_r0_body.zimgE162
-- the roots and their supports
kernel_rfl PRE_first_tail_x15_r0_body.zctl162 : PRE_first_tail_x15_r0_body.s1434.ctl = PRE_first_tail_x15_r0_body.kappa162.ctl PRE_first_tail_x15_r0_body.s1435.ctl
kernel_rfl PRE_first_tail_x15_r0_body.zstack162 : PRE_first_tail_x15_r0_body.s1434.stack = PRE_first_tail_x15_r0_body.s1435.stack.map PRE_first_tail_x15_r0_body.kappa162.frame
kernel_rfl PRE_first_tail_x15_r0_body.zjobs162 : PRE_first_tail_x15_r0_body.s1434.jobs = PRE_first_tail_x15_r0_body.s1435.jobs.map PRE_first_tail_x15_r0_body.kappa162.job
kernel_rfl PRE_first_tail_x15_r0_body.zstores162 : PRE_first_tail_x15_r0_body.s1434.stores = PRE_first_tail_x15_r0_body.kappa162.stores PRE_first_tail_x15_r0_body.s1435.stores
kernel_rfl PRE_first_tail_x15_r0_body.zroots162 : checkRootsSupp PRE_first_tail_x15_r0_body.s1435 7028 = true
kernel_rfl PRE_first_tail_x15_r0_body.znC162 : PRE_first_tail_x15_r0_body.S1433.tab.length + PRE_first_tail_x15_r0_body.cws162.length = 7028
-- the map as `Conv.compact_shift` states it (the call's counters for the literals)
kernel_rfl PRE_first_tail_x15_r0_body.zkap162 : PRE_first_tail_x15_r0_body.kappa162 = Conv.Map.compact PRE_first_tail_x15_r0_body.s1433.next 2803546 PRE_first_tail_x15_r0_body.S1433.tab.length PRE_first_tail_x15_r0_body.pl162 (PRE_first_tail_x15_r0_body.nr162.map NumV.ref) PRE_first_tail_x15_r0_body.kd162.big
  PRE_first_tail_x15_r0_body.kd162.region PRE_first_tail_x15_r0_body.kd162.nodeF
-- the bridge inactive at the canonical state (`Conv.FullShiftQ.toX`; the merged state's bridge is the canonical's: cbridge)
theorem PRE_first_tail_x15_r0_body.zbin162 : (Host.Ts.Sim.Full.bridgeOf PRE_first_tail_x15_r0_body.s1435.ffi).active = false := (Host.Load.Boot.replay_active Host.Load.Run.Prompt.P.oblog2818)
-- the JS bookkeeping's step (`Conv.JClean.step` over the changed list) and the canonical roots' bigint freedom
kernel_rfl PRE_first_tail_x15_r0_body.zjc162 : Conv.jcleanListB (⟨21401, 18512, 2802397, 7028⟩ : Conv.Cnt) PRE_first_tail_x15_r0_body.s1435 PRE_first_tail_x15_r0_body.cl162 = true
kernel_rfl PRE_first_tail_x15_r0_body.zroots2162 : noBigRootsP (fun i => !Conv.oldBigB (⟨21401, 18512, 2802397, 7028⟩ : Conv.Cnt) i) PRE_first_tail_x15_r0_body.s1435.trace PRE_first_tail_x15_r0_body.s1435 = true
kernel_rfl PRE_first_tail_x15_r0_body.zhm162 : Nat.ble (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s0.ffi).mlx.nnext 18485 = true
theorem PRE_first_tail_x15_r0_body.cjcl162 (h : Conv.JClean (⟨21398, 18485, 2802391, 7010⟩ : Conv.Cnt) PRE_first_tail_x15_r0_body.s1433) : Conv.JClean (⟨21401, 18512, 2802397, 7028⟩ : Conv.Cnt) PRE_first_tail_x15_r0_body.s1435 :=
  Conv.JClean.step h (Conv.Cnt.le_of_leB PRE_first_tail_x15_r0_body.cle162)
    (Conv.heap_off_setAll PRE_first_tail_x15_r0_body.cheap162 fun a ha => Nat.blt_eq.mp (List.all_eq_true.mp PRE_first_tail_x15_r0_body.zclbd162 a ha)) PRE_first_tail_x15_r0_body.zjc162

end Host.Load.Run.Tpl
