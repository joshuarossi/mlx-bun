import host.sim.template.a4pre_first_tail_x15_r0_body.SiteS167
import host.sim.template.a4pre_first_tail_x15_r0_body.SiteK167
import host.sim.template.a4pre_first_tail_x15_r0_body.SiteF167
import host.sim.conv.CompactShift
import host.sim.template.Check
import host.sim.BigFreeP
import host.sim.template.CallGen
set_option Elab.async false
namespace Host.Load.Run.Tpl
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
open Host.Ts Host.Ts.Sim Host.Ts.Sim.Template

/-! The compaction's state shift at call site 167 of chain `PRE_first_tail_x15_r0_body` (`Conv.compact_shift`): the call `PRE_first_tail_x15_r0_body.s1468`, the merged
state `PRE_first_tail_x15_r0_body.s1469`, the canonical state `PRE_first_tail_x15_r0_body.s1470`; its frames [2665,2673467,2673472,2673473] (kept arrays [2665,2673467]). -/

-- the map's places and counters
kernel_rfl PRE_first_tail_x15_r0_body.zpl167 : PRE_first_tail_x15_r0_body.pl167.all (Nat.ble PRE_first_tail_x15_r0_body.s1468.next) = true
kernel_rfl PRE_first_tail_x15_r0_body.zplnd167 : nodupT PRE_first_tail_x15_r0_body.pl167 PTrie.nil = true
kernel_rfl PRE_first_tail_x15_r0_body.zn1167 : Nat.ble PRE_first_tail_x15_r0_body.s1468.next 2805821 = true
kernel_rfl PRE_first_tail_x15_r0_body.zfirst167 : Nat.ble aFirst PRE_first_tail_x15_r0_body.s1468.next = true
kernel_rfl PRE_first_tail_x15_r0_body.zscn167 : PRE_first_tail_x15_r0_body.s1470.next = PRE_first_tail_x15_r0_body.s1468.next + PRE_first_tail_x15_r0_body.pl167.length
kernel_rfl PRE_first_tail_x15_r0_body.zsmn167 : PRE_first_tail_x15_r0_body.s1469.next = 2805821
kernel_rfl PRE_first_tail_x15_r0_body.zgrow167 : Nat.ble PRE_first_tail_x15_r0_body.s1470.next PRE_first_tail_x15_r0_body.s1469.next = true
-- the tables
kernel_rfl PRE_first_tail_x15_r0_body.zfresh167 : PRE_first_tail_x15_r0_body.S1468.tab.all (fun e => PRE_first_tail_x15_r0_body.cws167.all fun v => e.noVar v) = true
kernel_rfl PRE_first_tail_x15_r0_body.zcnd167 : nodupT PRE_first_tail_x15_r0_body.cws167 PTrie.nil = true
kernel_rfl PRE_first_tail_x15_r0_body.znrHi167 : PRE_first_tail_x15_r0_body.nr167.all (fun r => Nat.blt r PRE_first_tail_x15_r0_body.S1469.tab.length) = true
-- the frames: every framed address below the call's counter; the kept arrays the chain start's, extended in the merged state
kernel_rfl PRE_first_tail_x15_r0_body.zfrlt167 : [2665, 2673467, 2673472, 2673473].all (fun a => Nat.blt a PRE_first_tail_x15_r0_body.s1468.next) = true
kernel_rfl PRE_first_tail_x15_r0_body.zg167_2665 : PRE_first_tail_x15_r0_body.s1470.heap.get 2665 = some (.obj (objOf PRE_first_tail_x15_r0_body.s1470 2665))
kernel_rfl PRE_first_tail_x15_r0_body.zk167_2665 : (objOf PRE_first_tail_x15_r0_body.s1470 2665).kind = .array (arrOf PRE_first_tail_x15_r0_body.s0 2665)
kernel_rfl PRE_first_tail_x15_r0_body.zm167_2665 : PRE_first_tail_x15_r0_body.s1469.heap.get 2665 = some (.obj { PRE_first_tail_x15_r0_body.kappa167.obj (objOf PRE_first_tail_x15_r0_body.s1470 2665) with
  kind := .array (arrOf PRE_first_tail_x15_r0_body.s0 2665 ++ (arrOf PRE_first_tail_x15_r0_body.s1469 2665).drop (arrOf PRE_first_tail_x15_r0_body.s0 2665).length) })
kernel_rfl PRE_first_tail_x15_r0_body.zg167_2673467 : PRE_first_tail_x15_r0_body.s1470.heap.get 2673467 = some (.obj (objOf PRE_first_tail_x15_r0_body.s1470 2673467))
kernel_rfl PRE_first_tail_x15_r0_body.zk167_2673467 : (objOf PRE_first_tail_x15_r0_body.s1470 2673467).kind = .array (arrOf PRE_first_tail_x15_r0_body.s0 2673467)
kernel_rfl PRE_first_tail_x15_r0_body.zm167_2673467 : PRE_first_tail_x15_r0_body.s1469.heap.get 2673467 = some (.obj { PRE_first_tail_x15_r0_body.kappa167.obj (objOf PRE_first_tail_x15_r0_body.s1470 2673467) with
  kind := .array (arrOf PRE_first_tail_x15_r0_body.s0 2673467 ++ (arrOf PRE_first_tail_x15_r0_body.s1469 2673467).drop (arrOf PRE_first_tail_x15_r0_body.s0 2673467).length) })
kernel_rfl PRE_first_tail_x15_r0_body.zw167_4910 : (PRE_first_tail_x15_r0_body.s1470.heap.get 4910).isSome = true
kernel_rfl PRE_first_tail_x15_r0_body.zw167_2673472 : (PRE_first_tail_x15_r0_body.s1470.heap.get 2673472).isSome = true
kernel_rfl PRE_first_tail_x15_r0_body.zw167_2673473 : (PRE_first_tail_x15_r0_body.s1470.heap.get 2673473).isSome = true
-- the heap: the changed list in range, holding the stage's written and fresh addresses; the canonical side's image
kernel_rfl PRE_first_tail_x15_r0_body.zclbd167 : PRE_first_tail_x15_r0_body.cl167.all (fun b => Nat.blt (b / 4096) (4 ^ 31)) = true
kernel_rfl PRE_first_tail_x15_r0_body.zwr167 : PRE_first_tail_x15_r0_body.st167.wr.all (fun b => !Nat.blt b PRE_first_tail_x15_r0_body.s1468.next || PRE_first_tail_x15_r0_body.cl167.contains b) = true
def PRE_first_tail_x15_r0_body.zl167 : List Nat := PRE_first_tail_x15_r0_body.cl167.filter fun a => !(List.contains [2665, 2673467] a)
kernel_rfl PRE_first_tail_x15_r0_body.zimgE167 : PRE_first_tail_x15_r0_body.zl167.map (fun a => PRE_first_tail_x15_r0_body.s1469.heap.get (PRE_first_tail_x15_r0_body.kappa167.a a)) = PRE_first_tail_x15_r0_body.zl167.map (fun a => (PRE_first_tail_x15_r0_body.s1470.heap.get a).map PRE_first_tail_x15_r0_body.kappa167.hobj)
theorem PRE_first_tail_x15_r0_body.zimg167 : HeapImg PRE_first_tail_x15_r0_body.kappa167 PRE_first_tail_x15_r0_body.s1470 PRE_first_tail_x15_r0_body.s1469 PRE_first_tail_x15_r0_body.zl167 := PRE_first_tail_x15_r0_body.zimgE167
-- the roots and their supports
kernel_rfl PRE_first_tail_x15_r0_body.zctl167 : PRE_first_tail_x15_r0_body.s1469.ctl = PRE_first_tail_x15_r0_body.kappa167.ctl PRE_first_tail_x15_r0_body.s1470.ctl
kernel_rfl PRE_first_tail_x15_r0_body.zstack167 : PRE_first_tail_x15_r0_body.s1469.stack = PRE_first_tail_x15_r0_body.s1470.stack.map PRE_first_tail_x15_r0_body.kappa167.frame
kernel_rfl PRE_first_tail_x15_r0_body.zjobs167 : PRE_first_tail_x15_r0_body.s1469.jobs = PRE_first_tail_x15_r0_body.s1470.jobs.map PRE_first_tail_x15_r0_body.kappa167.job
kernel_rfl PRE_first_tail_x15_r0_body.zstores167 : PRE_first_tail_x15_r0_body.s1469.stores = PRE_first_tail_x15_r0_body.kappa167.stores PRE_first_tail_x15_r0_body.s1470.stores
kernel_rfl PRE_first_tail_x15_r0_body.zroots167 : checkRootsSupp PRE_first_tail_x15_r0_body.s1470 7192 = true
kernel_rfl PRE_first_tail_x15_r0_body.znC167 : PRE_first_tail_x15_r0_body.S1468.tab.length + PRE_first_tail_x15_r0_body.cws167.length = 7192
-- the map as `Conv.compact_shift` states it (the call's counters for the literals)
kernel_rfl PRE_first_tail_x15_r0_body.zkap167 : PRE_first_tail_x15_r0_body.kappa167 = Conv.Map.compact PRE_first_tail_x15_r0_body.s1468.next 2805821 PRE_first_tail_x15_r0_body.S1468.tab.length PRE_first_tail_x15_r0_body.pl167 (PRE_first_tail_x15_r0_body.nr167.map NumV.ref) PRE_first_tail_x15_r0_body.kd167.big
  PRE_first_tail_x15_r0_body.kd167.region PRE_first_tail_x15_r0_body.kd167.nodeF
-- the bridge inactive at the canonical state (`Conv.FullShiftQ.toX`; the merged state's bridge is the canonical's: cbridge)
theorem PRE_first_tail_x15_r0_body.zbin167 : (Host.Ts.Sim.Full.bridgeOf PRE_first_tail_x15_r0_body.s1470.ffi).active = false := (Host.Load.Boot.replay_active Host.Load.Run.Prompt.P.oblog2818)
-- the JS bookkeeping's step (`Conv.JClean.step` over the changed list) and the canonical roots' bigint freedom
kernel_rfl PRE_first_tail_x15_r0_body.zjc167 : Conv.jcleanListB (⟨21485, 18577, 2805802, 7192⟩ : Conv.Cnt) PRE_first_tail_x15_r0_body.s1470 PRE_first_tail_x15_r0_body.cl167 = true
kernel_rfl PRE_first_tail_x15_r0_body.zroots2167 : noBigRootsP (fun i => !Conv.oldBigB (⟨21485, 18577, 2805802, 7192⟩ : Conv.Cnt) i) PRE_first_tail_x15_r0_body.s1470.trace PRE_first_tail_x15_r0_body.s1470 = true
kernel_rfl PRE_first_tail_x15_r0_body.zhm167 : Nat.ble (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s0.ffi).mlx.nnext 18577 = true
theorem PRE_first_tail_x15_r0_body.cjcl167 (h : Conv.JClean (⟨21485, 18577, 2805801, 7192⟩ : Conv.Cnt) PRE_first_tail_x15_r0_body.s1468) : Conv.JClean (⟨21485, 18577, 2805802, 7192⟩ : Conv.Cnt) PRE_first_tail_x15_r0_body.s1470 :=
  Conv.JClean.step h (Conv.Cnt.le_of_leB PRE_first_tail_x15_r0_body.cle167)
    (Conv.heap_off_setAll PRE_first_tail_x15_r0_body.cheap167 fun a ha => Nat.blt_eq.mp (List.all_eq_true.mp PRE_first_tail_x15_r0_body.zclbd167 a ha)) PRE_first_tail_x15_r0_body.zjc167

end Host.Load.Run.Tpl
