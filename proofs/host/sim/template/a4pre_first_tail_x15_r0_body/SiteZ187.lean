import host.sim.template.a4pre_first_tail_x15_r0_body.SiteS187
import host.sim.template.a4pre_first_tail_x15_r0_body.SiteK187
import host.sim.template.a4pre_first_tail_x15_r0_body.SiteF187
import host.sim.conv.CompactShift
import host.sim.template.Check
import host.sim.BigFreeP
import host.sim.template.CallGen
set_option Elab.async false
namespace Host.Load.Run.Tpl
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
open Host.Ts Host.Ts.Sim Host.Ts.Sim.Template

/-! The compaction's state shift at call site 187 of chain `PRE_first_tail_x15_r0_body` (`Conv.compact_shift`): the call `PRE_first_tail_x15_r0_body.s1650`, the merged
state `PRE_first_tail_x15_r0_body.s1651`, the canonical state `PRE_first_tail_x15_r0_body.s1652`; its frames [2665,2673467,2673472,2673473] (kept arrays [2665,2673467]). -/

-- the map's places and counters
kernel_rfl PRE_first_tail_x15_r0_body.zpl187 : PRE_first_tail_x15_r0_body.pl187.all (Nat.ble PRE_first_tail_x15_r0_body.s1650.next) = true
kernel_rfl PRE_first_tail_x15_r0_body.zplnd187 : nodupT PRE_first_tail_x15_r0_body.pl187 PTrie.nil = true
kernel_rfl PRE_first_tail_x15_r0_body.zn1187 : Nat.ble PRE_first_tail_x15_r0_body.s1650.next 2821745 = true
kernel_rfl PRE_first_tail_x15_r0_body.zfirst187 : Nat.ble aFirst PRE_first_tail_x15_r0_body.s1650.next = true
kernel_rfl PRE_first_tail_x15_r0_body.zscn187 : PRE_first_tail_x15_r0_body.s1652.next = PRE_first_tail_x15_r0_body.s1650.next + PRE_first_tail_x15_r0_body.pl187.length
kernel_rfl PRE_first_tail_x15_r0_body.zsmn187 : PRE_first_tail_x15_r0_body.s1651.next = 2821745
kernel_rfl PRE_first_tail_x15_r0_body.zgrow187 : Nat.ble PRE_first_tail_x15_r0_body.s1652.next PRE_first_tail_x15_r0_body.s1651.next = true
-- the tables
kernel_rfl PRE_first_tail_x15_r0_body.zfresh187 : PRE_first_tail_x15_r0_body.S1650.tab.all (fun e => PRE_first_tail_x15_r0_body.cws187.all fun v => e.noVar v) = true
kernel_rfl PRE_first_tail_x15_r0_body.zcnd187 : nodupT PRE_first_tail_x15_r0_body.cws187 PTrie.nil = true
kernel_rfl PRE_first_tail_x15_r0_body.znrHi187 : PRE_first_tail_x15_r0_body.nr187.all (fun r => Nat.blt r PRE_first_tail_x15_r0_body.S1651.tab.length) = true
-- the frames: every framed address below the call's counter; the kept arrays the chain start's, extended in the merged state
kernel_rfl PRE_first_tail_x15_r0_body.zfrlt187 : [2665, 2673467, 2673472, 2673473].all (fun a => Nat.blt a PRE_first_tail_x15_r0_body.s1650.next) = true
kernel_rfl PRE_first_tail_x15_r0_body.zg187_2665 : PRE_first_tail_x15_r0_body.s1652.heap.get 2665 = some (.obj (objOf PRE_first_tail_x15_r0_body.s1652 2665))
kernel_rfl PRE_first_tail_x15_r0_body.zk187_2665 : (objOf PRE_first_tail_x15_r0_body.s1652 2665).kind = .array (arrOf PRE_first_tail_x15_r0_body.s0 2665)
kernel_rfl PRE_first_tail_x15_r0_body.zm187_2665 : PRE_first_tail_x15_r0_body.s1651.heap.get 2665 = some (.obj { PRE_first_tail_x15_r0_body.kappa187.obj (objOf PRE_first_tail_x15_r0_body.s1652 2665) with
  kind := .array (arrOf PRE_first_tail_x15_r0_body.s0 2665 ++ (arrOf PRE_first_tail_x15_r0_body.s1651 2665).drop (arrOf PRE_first_tail_x15_r0_body.s0 2665).length) })
kernel_rfl PRE_first_tail_x15_r0_body.zg187_2673467 : PRE_first_tail_x15_r0_body.s1652.heap.get 2673467 = some (.obj (objOf PRE_first_tail_x15_r0_body.s1652 2673467))
kernel_rfl PRE_first_tail_x15_r0_body.zk187_2673467 : (objOf PRE_first_tail_x15_r0_body.s1652 2673467).kind = .array (arrOf PRE_first_tail_x15_r0_body.s0 2673467)
kernel_rfl PRE_first_tail_x15_r0_body.zm187_2673467 : PRE_first_tail_x15_r0_body.s1651.heap.get 2673467 = some (.obj { PRE_first_tail_x15_r0_body.kappa187.obj (objOf PRE_first_tail_x15_r0_body.s1652 2673467) with
  kind := .array (arrOf PRE_first_tail_x15_r0_body.s0 2673467 ++ (arrOf PRE_first_tail_x15_r0_body.s1651 2673467).drop (arrOf PRE_first_tail_x15_r0_body.s0 2673467).length) })
kernel_rfl PRE_first_tail_x15_r0_body.zw187_4910 : (PRE_first_tail_x15_r0_body.s1652.heap.get 4910).isSome = true
kernel_rfl PRE_first_tail_x15_r0_body.zw187_2673472 : (PRE_first_tail_x15_r0_body.s1652.heap.get 2673472).isSome = true
kernel_rfl PRE_first_tail_x15_r0_body.zw187_2673473 : (PRE_first_tail_x15_r0_body.s1652.heap.get 2673473).isSome = true
-- the heap: the changed list in range, holding the stage's written and fresh addresses; the canonical side's image
kernel_rfl PRE_first_tail_x15_r0_body.zclbd187 : PRE_first_tail_x15_r0_body.cl187.all (fun b => Nat.blt (b / 4096) (4 ^ 31)) = true
kernel_rfl PRE_first_tail_x15_r0_body.zwr187 : PRE_first_tail_x15_r0_body.st187.wr.all (fun b => !Nat.blt b PRE_first_tail_x15_r0_body.s1650.next || PRE_first_tail_x15_r0_body.cl187.contains b) = true
def PRE_first_tail_x15_r0_body.zl187 : List Nat := PRE_first_tail_x15_r0_body.cl187.filter fun a => !(List.contains [2665, 2673467] a)
kernel_rfl PRE_first_tail_x15_r0_body.zimgE187 : PRE_first_tail_x15_r0_body.zl187.map (fun a => PRE_first_tail_x15_r0_body.s1651.heap.get (PRE_first_tail_x15_r0_body.kappa187.a a)) = PRE_first_tail_x15_r0_body.zl187.map (fun a => (PRE_first_tail_x15_r0_body.s1652.heap.get a).map PRE_first_tail_x15_r0_body.kappa187.hobj)
theorem PRE_first_tail_x15_r0_body.zimg187 : HeapImg PRE_first_tail_x15_r0_body.kappa187 PRE_first_tail_x15_r0_body.s1652 PRE_first_tail_x15_r0_body.s1651 PRE_first_tail_x15_r0_body.zl187 := PRE_first_tail_x15_r0_body.zimgE187
-- the roots and their supports
kernel_rfl PRE_first_tail_x15_r0_body.zctl187 : PRE_first_tail_x15_r0_body.s1651.ctl = PRE_first_tail_x15_r0_body.kappa187.ctl PRE_first_tail_x15_r0_body.s1652.ctl
kernel_rfl PRE_first_tail_x15_r0_body.zstack187 : PRE_first_tail_x15_r0_body.s1651.stack = PRE_first_tail_x15_r0_body.s1652.stack.map PRE_first_tail_x15_r0_body.kappa187.frame
kernel_rfl PRE_first_tail_x15_r0_body.zjobs187 : PRE_first_tail_x15_r0_body.s1651.jobs = PRE_first_tail_x15_r0_body.s1652.jobs.map PRE_first_tail_x15_r0_body.kappa187.job
kernel_rfl PRE_first_tail_x15_r0_body.zstores187 : PRE_first_tail_x15_r0_body.s1651.stores = PRE_first_tail_x15_r0_body.kappa187.stores PRE_first_tail_x15_r0_body.s1652.stores
kernel_rfl PRE_first_tail_x15_r0_body.zroots187 : checkRootsSupp PRE_first_tail_x15_r0_body.s1652 8075 = true
kernel_rfl PRE_first_tail_x15_r0_body.znC187 : PRE_first_tail_x15_r0_body.S1650.tab.length + PRE_first_tail_x15_r0_body.cws187.length = 8075
-- the map as `Conv.compact_shift` states it (the call's counters for the literals)
kernel_rfl PRE_first_tail_x15_r0_body.zkap187 : PRE_first_tail_x15_r0_body.kappa187 = Conv.Map.compact PRE_first_tail_x15_r0_body.s1650.next 2821745 PRE_first_tail_x15_r0_body.S1650.tab.length PRE_first_tail_x15_r0_body.pl187 (PRE_first_tail_x15_r0_body.nr187.map NumV.ref) PRE_first_tail_x15_r0_body.kd187.big
  PRE_first_tail_x15_r0_body.kd187.region PRE_first_tail_x15_r0_body.kd187.nodeF
-- the bridge inactive at the canonical state (`Conv.FullShiftQ.toX`; the merged state's bridge is the canonical's: cbridge)
theorem PRE_first_tail_x15_r0_body.zbin187 : (Host.Ts.Sim.Full.bridgeOf PRE_first_tail_x15_r0_body.s1652.ffi).active = false := (Host.Load.Boot.replay_active Host.Load.Run.Prompt.P.oblog2818)
-- the JS bookkeeping's step (`Conv.JClean.step` over the changed list) and the canonical roots' bigint freedom
kernel_rfl PRE_first_tail_x15_r0_body.zjc187 : Conv.jcleanListB (⟨21886, 18999, 2821743, 8075⟩ : Conv.Cnt) PRE_first_tail_x15_r0_body.s1652 PRE_first_tail_x15_r0_body.cl187 = true
kernel_rfl PRE_first_tail_x15_r0_body.zroots2187 : noBigRootsP (fun i => !Conv.oldBigB (⟨21886, 18999, 2821743, 8075⟩ : Conv.Cnt) i) PRE_first_tail_x15_r0_body.s1652.trace PRE_first_tail_x15_r0_body.s1652 = true
kernel_rfl PRE_first_tail_x15_r0_body.zhm187 : Nat.ble (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s0.ffi).mlx.nnext 18999 = true
theorem PRE_first_tail_x15_r0_body.cjcl187 (h : Conv.JClean (⟨21886, 18999, 2821743, 8075⟩ : Conv.Cnt) PRE_first_tail_x15_r0_body.s1650) : Conv.JClean (⟨21886, 18999, 2821743, 8075⟩ : Conv.Cnt) PRE_first_tail_x15_r0_body.s1652 :=
  Conv.JClean.step h (Conv.Cnt.le_of_leB PRE_first_tail_x15_r0_body.cle187)
    (Conv.heap_off_setAll PRE_first_tail_x15_r0_body.cheap187 fun a ha => Nat.blt_eq.mp (List.all_eq_true.mp PRE_first_tail_x15_r0_body.zclbd187 a ha)) PRE_first_tail_x15_r0_body.zjc187

end Host.Load.Run.Tpl
