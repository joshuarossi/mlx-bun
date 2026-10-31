import host.sim.template.a4pre_first_tail_x15_r0_body.SiteS191
import host.sim.template.a4pre_first_tail_x15_r0_body.SiteK191
import host.sim.template.a4pre_first_tail_x15_r0_body.SiteF191
import host.sim.conv.CompactShift
import host.sim.template.Check
import host.sim.BigFreeP
import host.sim.template.CallGen
set_option Elab.async false
namespace Host.Load.Run.Tpl
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
open Host.Ts Host.Ts.Sim Host.Ts.Sim.Template

/-! The compaction's state shift at call site 191 of chain `PRE_first_tail_x15_r0_body` (`Conv.compact_shift`): the call `PRE_first_tail_x15_r0_body.s1678`, the merged
state `PRE_first_tail_x15_r0_body.s1679`, the canonical state `PRE_first_tail_x15_r0_body.s1680`; its frames [2665,2673467,2673472,2673473] (kept arrays [2665,2673467]). -/

-- the map's places and counters
kernel_rfl PRE_first_tail_x15_r0_body.zpl191 : PRE_first_tail_x15_r0_body.pl191.all (Nat.ble PRE_first_tail_x15_r0_body.s1678.next) = true
kernel_rfl PRE_first_tail_x15_r0_body.zplnd191 : nodupT PRE_first_tail_x15_r0_body.pl191 PTrie.nil = true
kernel_rfl PRE_first_tail_x15_r0_body.zn1191 : Nat.ble PRE_first_tail_x15_r0_body.s1678.next 2824664 = true
kernel_rfl PRE_first_tail_x15_r0_body.zfirst191 : Nat.ble aFirst PRE_first_tail_x15_r0_body.s1678.next = true
kernel_rfl PRE_first_tail_x15_r0_body.zscn191 : PRE_first_tail_x15_r0_body.s1680.next = PRE_first_tail_x15_r0_body.s1678.next + PRE_first_tail_x15_r0_body.pl191.length
kernel_rfl PRE_first_tail_x15_r0_body.zsmn191 : PRE_first_tail_x15_r0_body.s1679.next = 2824664
kernel_rfl PRE_first_tail_x15_r0_body.zgrow191 : Nat.ble PRE_first_tail_x15_r0_body.s1680.next PRE_first_tail_x15_r0_body.s1679.next = true
-- the tables
kernel_rfl PRE_first_tail_x15_r0_body.zfresh191 : PRE_first_tail_x15_r0_body.S1678.tab.all (fun e => PRE_first_tail_x15_r0_body.cws191.all fun v => e.noVar v) = true
kernel_rfl PRE_first_tail_x15_r0_body.zcnd191 : nodupT PRE_first_tail_x15_r0_body.cws191 PTrie.nil = true
kernel_rfl PRE_first_tail_x15_r0_body.znrHi191 : PRE_first_tail_x15_r0_body.nr191.all (fun r => Nat.blt r PRE_first_tail_x15_r0_body.S1679.tab.length) = true
-- the frames: every framed address below the call's counter; the kept arrays the chain start's, extended in the merged state
kernel_rfl PRE_first_tail_x15_r0_body.zfrlt191 : [2665, 2673467, 2673472, 2673473].all (fun a => Nat.blt a PRE_first_tail_x15_r0_body.s1678.next) = true
kernel_rfl PRE_first_tail_x15_r0_body.zg191_2665 : PRE_first_tail_x15_r0_body.s1680.heap.get 2665 = some (.obj (objOf PRE_first_tail_x15_r0_body.s1680 2665))
kernel_rfl PRE_first_tail_x15_r0_body.zk191_2665 : (objOf PRE_first_tail_x15_r0_body.s1680 2665).kind = .array (arrOf PRE_first_tail_x15_r0_body.s0 2665)
kernel_rfl PRE_first_tail_x15_r0_body.zm191_2665 : PRE_first_tail_x15_r0_body.s1679.heap.get 2665 = some (.obj { PRE_first_tail_x15_r0_body.kappa191.obj (objOf PRE_first_tail_x15_r0_body.s1680 2665) with
  kind := .array (arrOf PRE_first_tail_x15_r0_body.s0 2665 ++ (arrOf PRE_first_tail_x15_r0_body.s1679 2665).drop (arrOf PRE_first_tail_x15_r0_body.s0 2665).length) })
kernel_rfl PRE_first_tail_x15_r0_body.zg191_2673467 : PRE_first_tail_x15_r0_body.s1680.heap.get 2673467 = some (.obj (objOf PRE_first_tail_x15_r0_body.s1680 2673467))
kernel_rfl PRE_first_tail_x15_r0_body.zk191_2673467 : (objOf PRE_first_tail_x15_r0_body.s1680 2673467).kind = .array (arrOf PRE_first_tail_x15_r0_body.s0 2673467)
kernel_rfl PRE_first_tail_x15_r0_body.zm191_2673467 : PRE_first_tail_x15_r0_body.s1679.heap.get 2673467 = some (.obj { PRE_first_tail_x15_r0_body.kappa191.obj (objOf PRE_first_tail_x15_r0_body.s1680 2673467) with
  kind := .array (arrOf PRE_first_tail_x15_r0_body.s0 2673467 ++ (arrOf PRE_first_tail_x15_r0_body.s1679 2673467).drop (arrOf PRE_first_tail_x15_r0_body.s0 2673467).length) })
kernel_rfl PRE_first_tail_x15_r0_body.zw191_4910 : (PRE_first_tail_x15_r0_body.s1680.heap.get 4910).isSome = true
kernel_rfl PRE_first_tail_x15_r0_body.zw191_2673472 : (PRE_first_tail_x15_r0_body.s1680.heap.get 2673472).isSome = true
kernel_rfl PRE_first_tail_x15_r0_body.zw191_2673473 : (PRE_first_tail_x15_r0_body.s1680.heap.get 2673473).isSome = true
-- the heap: the changed list in range, holding the stage's written and fresh addresses; the canonical side's image
kernel_rfl PRE_first_tail_x15_r0_body.zclbd191 : PRE_first_tail_x15_r0_body.cl191.all (fun b => Nat.blt (b / 4096) (4 ^ 31)) = true
kernel_rfl PRE_first_tail_x15_r0_body.zwr191 : PRE_first_tail_x15_r0_body.st191.wr.all (fun b => !Nat.blt b PRE_first_tail_x15_r0_body.s1678.next || PRE_first_tail_x15_r0_body.cl191.contains b) = true
def PRE_first_tail_x15_r0_body.zl191 : List Nat := PRE_first_tail_x15_r0_body.cl191.filter fun a => !(List.contains [2665, 2673467] a)
kernel_rfl PRE_first_tail_x15_r0_body.zimgE191 : PRE_first_tail_x15_r0_body.zl191.map (fun a => PRE_first_tail_x15_r0_body.s1679.heap.get (PRE_first_tail_x15_r0_body.kappa191.a a)) = PRE_first_tail_x15_r0_body.zl191.map (fun a => (PRE_first_tail_x15_r0_body.s1680.heap.get a).map PRE_first_tail_x15_r0_body.kappa191.hobj)
theorem PRE_first_tail_x15_r0_body.zimg191 : HeapImg PRE_first_tail_x15_r0_body.kappa191 PRE_first_tail_x15_r0_body.s1680 PRE_first_tail_x15_r0_body.s1679 PRE_first_tail_x15_r0_body.zl191 := PRE_first_tail_x15_r0_body.zimgE191
-- the roots and their supports
kernel_rfl PRE_first_tail_x15_r0_body.zctl191 : PRE_first_tail_x15_r0_body.s1679.ctl = PRE_first_tail_x15_r0_body.kappa191.ctl PRE_first_tail_x15_r0_body.s1680.ctl
kernel_rfl PRE_first_tail_x15_r0_body.zstack191 : PRE_first_tail_x15_r0_body.s1679.stack = PRE_first_tail_x15_r0_body.s1680.stack.map PRE_first_tail_x15_r0_body.kappa191.frame
kernel_rfl PRE_first_tail_x15_r0_body.zjobs191 : PRE_first_tail_x15_r0_body.s1679.jobs = PRE_first_tail_x15_r0_body.s1680.jobs.map PRE_first_tail_x15_r0_body.kappa191.job
kernel_rfl PRE_first_tail_x15_r0_body.zstores191 : PRE_first_tail_x15_r0_body.s1679.stores = PRE_first_tail_x15_r0_body.kappa191.stores PRE_first_tail_x15_r0_body.s1680.stores
kernel_rfl PRE_first_tail_x15_r0_body.zroots191 : checkRootsSupp PRE_first_tail_x15_r0_body.s1680 8218 = true
kernel_rfl PRE_first_tail_x15_r0_body.znC191 : PRE_first_tail_x15_r0_body.S1678.tab.length + PRE_first_tail_x15_r0_body.cws191.length = 8218
-- the map as `Conv.compact_shift` states it (the call's counters for the literals)
kernel_rfl PRE_first_tail_x15_r0_body.zkap191 : PRE_first_tail_x15_r0_body.kappa191 = Conv.Map.compact PRE_first_tail_x15_r0_body.s1678.next 2824664 PRE_first_tail_x15_r0_body.S1678.tab.length PRE_first_tail_x15_r0_body.pl191 (PRE_first_tail_x15_r0_body.nr191.map NumV.ref) PRE_first_tail_x15_r0_body.kd191.big
  PRE_first_tail_x15_r0_body.kd191.region PRE_first_tail_x15_r0_body.kd191.nodeF
-- the bridge inactive at the canonical state (`Conv.FullShiftQ.toX`; the merged state's bridge is the canonical's: cbridge)
theorem PRE_first_tail_x15_r0_body.zbin191 : (Host.Ts.Sim.Full.bridgeOf PRE_first_tail_x15_r0_body.s1680.ffi).active = false := (Host.Load.Boot.replay_active Host.Load.Run.Prompt.P.oblog2818)
-- the JS bookkeeping's step (`Conv.JClean.step` over the changed list) and the canonical roots' bigint freedom
kernel_rfl PRE_first_tail_x15_r0_body.zjc191 : Conv.jcleanListB (⟨21957, 19051, 2824654, 8218⟩ : Conv.Cnt) PRE_first_tail_x15_r0_body.s1680 PRE_first_tail_x15_r0_body.cl191 = true
kernel_rfl PRE_first_tail_x15_r0_body.zroots2191 : noBigRootsP (fun i => !Conv.oldBigB (⟨21957, 19051, 2824654, 8218⟩ : Conv.Cnt) i) PRE_first_tail_x15_r0_body.s1680.trace PRE_first_tail_x15_r0_body.s1680 = true
kernel_rfl PRE_first_tail_x15_r0_body.zhm191 : Nat.ble (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s0.ffi).mlx.nnext 19051 = true
theorem PRE_first_tail_x15_r0_body.cjcl191 (h : Conv.JClean (⟨21957, 19051, 2824653, 8218⟩ : Conv.Cnt) PRE_first_tail_x15_r0_body.s1678) : Conv.JClean (⟨21957, 19051, 2824654, 8218⟩ : Conv.Cnt) PRE_first_tail_x15_r0_body.s1680 :=
  Conv.JClean.step h (Conv.Cnt.le_of_leB PRE_first_tail_x15_r0_body.cle191)
    (Conv.heap_off_setAll PRE_first_tail_x15_r0_body.cheap191 fun a ha => Nat.blt_eq.mp (List.all_eq_true.mp PRE_first_tail_x15_r0_body.zclbd191 a ha)) PRE_first_tail_x15_r0_body.zjc191

end Host.Load.Run.Tpl
