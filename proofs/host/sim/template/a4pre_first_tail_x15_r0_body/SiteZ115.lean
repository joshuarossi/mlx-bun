import host.sim.template.a4pre_first_tail_x15_r0_body.SiteS115
import host.sim.template.a4pre_first_tail_x15_r0_body.SiteK115
import host.sim.template.a4pre_first_tail_x15_r0_body.SiteF115
import host.sim.conv.CompactShift
import host.sim.template.Check
import host.sim.BigFreeP
import host.sim.template.CallGen
set_option Elab.async false
namespace Host.Load.Run.Tpl
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
open Host.Ts Host.Ts.Sim Host.Ts.Sim.Template

/-! The compaction's state shift at call site 115 of chain `PRE_first_tail_x15_r0_body` (`Conv.compact_shift`): the call `PRE_first_tail_x15_r0_body.s1117`, the merged
state `PRE_first_tail_x15_r0_body.s1118`, the canonical state `PRE_first_tail_x15_r0_body.s1119`; its frames [2665,2673467,2673472,2673473] (kept arrays [2665,2673467]). -/

-- the map's places and counters
kernel_rfl PRE_first_tail_x15_r0_body.zpl115 : PRE_first_tail_x15_r0_body.pl115.all (Nat.ble PRE_first_tail_x15_r0_body.s1117.next) = true
kernel_rfl PRE_first_tail_x15_r0_body.zplnd115 : nodupT PRE_first_tail_x15_r0_body.pl115 PTrie.nil = true
kernel_rfl PRE_first_tail_x15_r0_body.zn1115 : Nat.ble PRE_first_tail_x15_r0_body.s1117.next 2765221 = true
kernel_rfl PRE_first_tail_x15_r0_body.zfirst115 : Nat.ble aFirst PRE_first_tail_x15_r0_body.s1117.next = true
kernel_rfl PRE_first_tail_x15_r0_body.zscn115 : PRE_first_tail_x15_r0_body.s1119.next = PRE_first_tail_x15_r0_body.s1117.next + PRE_first_tail_x15_r0_body.pl115.length
kernel_rfl PRE_first_tail_x15_r0_body.zsmn115 : PRE_first_tail_x15_r0_body.s1118.next = 2765221
kernel_rfl PRE_first_tail_x15_r0_body.zgrow115 : Nat.ble PRE_first_tail_x15_r0_body.s1119.next PRE_first_tail_x15_r0_body.s1118.next = true
-- the tables
kernel_rfl PRE_first_tail_x15_r0_body.zfresh115 : PRE_first_tail_x15_r0_body.S1117.tab.all (fun e => PRE_first_tail_x15_r0_body.cws115.all fun v => e.noVar v) = true
kernel_rfl PRE_first_tail_x15_r0_body.zcnd115 : nodupT PRE_first_tail_x15_r0_body.cws115 PTrie.nil = true
kernel_rfl PRE_first_tail_x15_r0_body.znrHi115 : PRE_first_tail_x15_r0_body.nr115.all (fun r => Nat.blt r PRE_first_tail_x15_r0_body.S1118.tab.length) = true
-- the frames: every framed address below the call's counter; the kept arrays the chain start's, extended in the merged state
kernel_rfl PRE_first_tail_x15_r0_body.zfrlt115 : [2665, 2673467, 2673472, 2673473].all (fun a => Nat.blt a PRE_first_tail_x15_r0_body.s1117.next) = true
kernel_rfl PRE_first_tail_x15_r0_body.zg115_2665 : PRE_first_tail_x15_r0_body.s1119.heap.get 2665 = some (.obj (objOf PRE_first_tail_x15_r0_body.s1119 2665))
kernel_rfl PRE_first_tail_x15_r0_body.zk115_2665 : (objOf PRE_first_tail_x15_r0_body.s1119 2665).kind = .array (arrOf PRE_first_tail_x15_r0_body.s0 2665)
kernel_rfl PRE_first_tail_x15_r0_body.zm115_2665 : PRE_first_tail_x15_r0_body.s1118.heap.get 2665 = some (.obj { PRE_first_tail_x15_r0_body.kappa115.obj (objOf PRE_first_tail_x15_r0_body.s1119 2665) with
  kind := .array (arrOf PRE_first_tail_x15_r0_body.s0 2665 ++ (arrOf PRE_first_tail_x15_r0_body.s1118 2665).drop (arrOf PRE_first_tail_x15_r0_body.s0 2665).length) })
kernel_rfl PRE_first_tail_x15_r0_body.zg115_2673467 : PRE_first_tail_x15_r0_body.s1119.heap.get 2673467 = some (.obj (objOf PRE_first_tail_x15_r0_body.s1119 2673467))
kernel_rfl PRE_first_tail_x15_r0_body.zk115_2673467 : (objOf PRE_first_tail_x15_r0_body.s1119 2673467).kind = .array (arrOf PRE_first_tail_x15_r0_body.s0 2673467)
kernel_rfl PRE_first_tail_x15_r0_body.zm115_2673467 : PRE_first_tail_x15_r0_body.s1118.heap.get 2673467 = some (.obj { PRE_first_tail_x15_r0_body.kappa115.obj (objOf PRE_first_tail_x15_r0_body.s1119 2673467) with
  kind := .array (arrOf PRE_first_tail_x15_r0_body.s0 2673467 ++ (arrOf PRE_first_tail_x15_r0_body.s1118 2673467).drop (arrOf PRE_first_tail_x15_r0_body.s0 2673467).length) })
kernel_rfl PRE_first_tail_x15_r0_body.zw115_4910 : (PRE_first_tail_x15_r0_body.s1119.heap.get 4910).isSome = true
kernel_rfl PRE_first_tail_x15_r0_body.zw115_2673472 : (PRE_first_tail_x15_r0_body.s1119.heap.get 2673472).isSome = true
kernel_rfl PRE_first_tail_x15_r0_body.zw115_2673473 : (PRE_first_tail_x15_r0_body.s1119.heap.get 2673473).isSome = true
-- the heap: the changed list in range, holding the stage's written and fresh addresses; the canonical side's image
kernel_rfl PRE_first_tail_x15_r0_body.zclbd115 : PRE_first_tail_x15_r0_body.cl115.all (fun b => Nat.blt (b / 4096) (4 ^ 31)) = true
kernel_rfl PRE_first_tail_x15_r0_body.zwr115 : PRE_first_tail_x15_r0_body.st115.wr.all (fun b => !Nat.blt b PRE_first_tail_x15_r0_body.s1117.next || PRE_first_tail_x15_r0_body.cl115.contains b) = true
def PRE_first_tail_x15_r0_body.zl115 : List Nat := PRE_first_tail_x15_r0_body.cl115.filter fun a => !(List.contains [2665, 2673467] a)
kernel_rfl PRE_first_tail_x15_r0_body.zimgE115 : PRE_first_tail_x15_r0_body.zl115.map (fun a => PRE_first_tail_x15_r0_body.s1118.heap.get (PRE_first_tail_x15_r0_body.kappa115.a a)) = PRE_first_tail_x15_r0_body.zl115.map (fun a => (PRE_first_tail_x15_r0_body.s1119.heap.get a).map PRE_first_tail_x15_r0_body.kappa115.hobj)
theorem PRE_first_tail_x15_r0_body.zimg115 : HeapImg PRE_first_tail_x15_r0_body.kappa115 PRE_first_tail_x15_r0_body.s1119 PRE_first_tail_x15_r0_body.s1118 PRE_first_tail_x15_r0_body.zl115 := PRE_first_tail_x15_r0_body.zimgE115
-- the roots and their supports
kernel_rfl PRE_first_tail_x15_r0_body.zctl115 : PRE_first_tail_x15_r0_body.s1118.ctl = PRE_first_tail_x15_r0_body.kappa115.ctl PRE_first_tail_x15_r0_body.s1119.ctl
kernel_rfl PRE_first_tail_x15_r0_body.zstack115 : PRE_first_tail_x15_r0_body.s1118.stack = PRE_first_tail_x15_r0_body.s1119.stack.map PRE_first_tail_x15_r0_body.kappa115.frame
kernel_rfl PRE_first_tail_x15_r0_body.zjobs115 : PRE_first_tail_x15_r0_body.s1118.jobs = PRE_first_tail_x15_r0_body.s1119.jobs.map PRE_first_tail_x15_r0_body.kappa115.job
kernel_rfl PRE_first_tail_x15_r0_body.zstores115 : PRE_first_tail_x15_r0_body.s1118.stores = PRE_first_tail_x15_r0_body.kappa115.stores PRE_first_tail_x15_r0_body.s1119.stores
kernel_rfl PRE_first_tail_x15_r0_body.zroots115 : checkRootsSupp PRE_first_tail_x15_r0_body.s1119 4997 = true
kernel_rfl PRE_first_tail_x15_r0_body.znC115 : PRE_first_tail_x15_r0_body.S1117.tab.length + PRE_first_tail_x15_r0_body.cws115.length = 4997
-- the map as `Conv.compact_shift` states it (the call's counters for the literals)
kernel_rfl PRE_first_tail_x15_r0_body.zkap115 : PRE_first_tail_x15_r0_body.kappa115 = Conv.Map.compact PRE_first_tail_x15_r0_body.s1117.next 2765221 PRE_first_tail_x15_r0_body.S1117.tab.length PRE_first_tail_x15_r0_body.pl115 (PRE_first_tail_x15_r0_body.nr115.map NumV.ref) PRE_first_tail_x15_r0_body.kd115.big
  PRE_first_tail_x15_r0_body.kd115.region PRE_first_tail_x15_r0_body.kd115.nodeF
-- the bridge inactive at the canonical state (`Conv.FullShiftQ.toX`; the merged state's bridge is the canonical's: cbridge)
theorem PRE_first_tail_x15_r0_body.zbin115 : (Host.Ts.Sim.Full.bridgeOf PRE_first_tail_x15_r0_body.s1119.ffi).active = false := (Host.Load.Boot.replay_active Host.Load.Run.Prompt.P.oblog2818)
-- the JS bookkeeping's step (`Conv.JClean.step` over the changed list) and the canonical roots' bigint freedom
kernel_rfl PRE_first_tail_x15_r0_body.zjc115 : Conv.jcleanListB (⟨20470, 17577, 2765219, 4997⟩ : Conv.Cnt) PRE_first_tail_x15_r0_body.s1119 PRE_first_tail_x15_r0_body.cl115 = true
kernel_rfl PRE_first_tail_x15_r0_body.zrootsB115 : noBigRootsP (fun i => !Conv.oldBigB (⟨20470, 17577, 2765219, 4997⟩ : Conv.Cnt) i) PRE_first_tail_x15_r0_body.s1119.trace PRE_first_tail_x15_r0_body.s1119 = true
kernel_rfl PRE_first_tail_x15_r0_body.zhm115 : Nat.ble (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s0.ffi).mlx.nnext 17577 = true
theorem PRE_first_tail_x15_r0_body.cjcl115 (h : Conv.JClean (⟨20470, 17577, 2765219, 4997⟩ : Conv.Cnt) PRE_first_tail_x15_r0_body.s1117) : Conv.JClean (⟨20470, 17577, 2765219, 4997⟩ : Conv.Cnt) PRE_first_tail_x15_r0_body.s1119 :=
  Conv.JClean.step h (Conv.Cnt.le_of_leB PRE_first_tail_x15_r0_body.cle115)
    (Conv.heap_off_setAll PRE_first_tail_x15_r0_body.cheap115 fun a ha => Nat.blt_eq.mp (List.all_eq_true.mp PRE_first_tail_x15_r0_body.zclbd115 a ha)) PRE_first_tail_x15_r0_body.zjc115

end Host.Load.Run.Tpl
