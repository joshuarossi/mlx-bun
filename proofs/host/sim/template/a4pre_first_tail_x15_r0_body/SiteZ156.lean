import host.sim.template.a4pre_first_tail_x15_r0_body.SiteS156
import host.sim.template.a4pre_first_tail_x15_r0_body.SiteK156
import host.sim.template.a4pre_first_tail_x15_r0_body.SiteF156
import host.sim.conv.CompactShift
import host.sim.template.Check
import host.sim.BigFreeP
import host.sim.template.CallGen
set_option Elab.async false
namespace Host.Load.Run.Tpl
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
open Host.Ts Host.Ts.Sim Host.Ts.Sim.Template

/-! The compaction's state shift at call site 156 of chain `PRE_first_tail_x15_r0_body` (`Conv.compact_shift`): the call `PRE_first_tail_x15_r0_body.s1511`, the merged
state `PRE_first_tail_x15_r0_body.s1512`, the canonical state `PRE_first_tail_x15_r0_body.s1513`; its frames [2665,2673467,2673472,2673473] (kept arrays [2665,2673467]). -/

-- the map's places and counters
kernel_rfl PRE_first_tail_x15_r0_body.zpl156 : PRE_first_tail_x15_r0_body.pl156.all (Nat.ble PRE_first_tail_x15_r0_body.s1511.next) = true
kernel_rfl PRE_first_tail_x15_r0_body.zplnd156 : nodupT PRE_first_tail_x15_r0_body.pl156 PTrie.nil = true
kernel_rfl PRE_first_tail_x15_r0_body.zn1156 : Nat.ble PRE_first_tail_x15_r0_body.s1511.next 2799034 = true
kernel_rfl PRE_first_tail_x15_r0_body.zfirst156 : Nat.ble aFirst PRE_first_tail_x15_r0_body.s1511.next = true
kernel_rfl PRE_first_tail_x15_r0_body.zscn156 : PRE_first_tail_x15_r0_body.s1513.next = PRE_first_tail_x15_r0_body.s1511.next + PRE_first_tail_x15_r0_body.pl156.length
kernel_rfl PRE_first_tail_x15_r0_body.zsmn156 : PRE_first_tail_x15_r0_body.s1512.next = 2799034
kernel_rfl PRE_first_tail_x15_r0_body.zgrow156 : Nat.ble PRE_first_tail_x15_r0_body.s1513.next PRE_first_tail_x15_r0_body.s1512.next = true
-- the tables
kernel_rfl PRE_first_tail_x15_r0_body.zfresh156 : PRE_first_tail_x15_r0_body.S1511.tab.all (fun e => PRE_first_tail_x15_r0_body.cws156.all fun v => e.noVar v) = true
kernel_rfl PRE_first_tail_x15_r0_body.zcnd156 : nodupT PRE_first_tail_x15_r0_body.cws156 PTrie.nil = true
kernel_rfl PRE_first_tail_x15_r0_body.znrHi156 : PRE_first_tail_x15_r0_body.nr156.all (fun r => Nat.blt r PRE_first_tail_x15_r0_body.S1512.tab.length) = true
-- the frames: every framed address below the call's counter; the kept arrays the chain start's, extended in the merged state
kernel_rfl PRE_first_tail_x15_r0_body.zfrlt156 : [2665, 2673467, 2673472, 2673473].all (fun a => Nat.blt a PRE_first_tail_x15_r0_body.s1511.next) = true
kernel_rfl PRE_first_tail_x15_r0_body.zg156_2665 : PRE_first_tail_x15_r0_body.s1513.heap.get 2665 = some (.obj (objOf PRE_first_tail_x15_r0_body.s1513 2665))
kernel_rfl PRE_first_tail_x15_r0_body.zk156_2665 : (objOf PRE_first_tail_x15_r0_body.s1513 2665).kind = .array (arrOf PRE_first_tail_x15_r0_body.s0 2665)
kernel_rfl PRE_first_tail_x15_r0_body.zm156_2665 : PRE_first_tail_x15_r0_body.s1512.heap.get 2665 = some (.obj { PRE_first_tail_x15_r0_body.kappa156.obj (objOf PRE_first_tail_x15_r0_body.s1513 2665) with
  kind := .array (arrOf PRE_first_tail_x15_r0_body.s0 2665 ++ (arrOf PRE_first_tail_x15_r0_body.s1512 2665).drop (arrOf PRE_first_tail_x15_r0_body.s0 2665).length) })
kernel_rfl PRE_first_tail_x15_r0_body.zg156_2673467 : PRE_first_tail_x15_r0_body.s1513.heap.get 2673467 = some (.obj (objOf PRE_first_tail_x15_r0_body.s1513 2673467))
kernel_rfl PRE_first_tail_x15_r0_body.zk156_2673467 : (objOf PRE_first_tail_x15_r0_body.s1513 2673467).kind = .array (arrOf PRE_first_tail_x15_r0_body.s0 2673467)
kernel_rfl PRE_first_tail_x15_r0_body.zm156_2673467 : PRE_first_tail_x15_r0_body.s1512.heap.get 2673467 = some (.obj { PRE_first_tail_x15_r0_body.kappa156.obj (objOf PRE_first_tail_x15_r0_body.s1513 2673467) with
  kind := .array (arrOf PRE_first_tail_x15_r0_body.s0 2673467 ++ (arrOf PRE_first_tail_x15_r0_body.s1512 2673467).drop (arrOf PRE_first_tail_x15_r0_body.s0 2673467).length) })
kernel_rfl PRE_first_tail_x15_r0_body.zw156_4910 : (PRE_first_tail_x15_r0_body.s1513.heap.get 4910).isSome = true
kernel_rfl PRE_first_tail_x15_r0_body.zw156_2673472 : (PRE_first_tail_x15_r0_body.s1513.heap.get 2673472).isSome = true
kernel_rfl PRE_first_tail_x15_r0_body.zw156_2673473 : (PRE_first_tail_x15_r0_body.s1513.heap.get 2673473).isSome = true
-- the heap: the changed list in range, holding the stage's written and fresh addresses; the canonical side's image
kernel_rfl PRE_first_tail_x15_r0_body.zclbd156 : PRE_first_tail_x15_r0_body.cl156.all (fun b => Nat.blt (b / 4096) (4 ^ 31)) = true
kernel_rfl PRE_first_tail_x15_r0_body.zwr156 : PRE_first_tail_x15_r0_body.st156.wr.all (fun b => !Nat.blt b PRE_first_tail_x15_r0_body.s1511.next || PRE_first_tail_x15_r0_body.cl156.contains b) = true
def PRE_first_tail_x15_r0_body.zl156 : List Nat := PRE_first_tail_x15_r0_body.cl156.filter fun a => !(List.contains [2665, 2673467] a)
kernel_rfl PRE_first_tail_x15_r0_body.zimgE156 : PRE_first_tail_x15_r0_body.zl156.map (fun a => PRE_first_tail_x15_r0_body.s1512.heap.get (PRE_first_tail_x15_r0_body.kappa156.a a)) = PRE_first_tail_x15_r0_body.zl156.map (fun a => (PRE_first_tail_x15_r0_body.s1513.heap.get a).map PRE_first_tail_x15_r0_body.kappa156.hobj)
theorem PRE_first_tail_x15_r0_body.zimg156 : HeapImg PRE_first_tail_x15_r0_body.kappa156 PRE_first_tail_x15_r0_body.s1513 PRE_first_tail_x15_r0_body.s1512 PRE_first_tail_x15_r0_body.zl156 := PRE_first_tail_x15_r0_body.zimgE156
-- the roots and their supports
kernel_rfl PRE_first_tail_x15_r0_body.zctl156 : PRE_first_tail_x15_r0_body.s1512.ctl = PRE_first_tail_x15_r0_body.kappa156.ctl PRE_first_tail_x15_r0_body.s1513.ctl
kernel_rfl PRE_first_tail_x15_r0_body.zstack156 : PRE_first_tail_x15_r0_body.s1512.stack = PRE_first_tail_x15_r0_body.s1513.stack.map PRE_first_tail_x15_r0_body.kappa156.frame
kernel_rfl PRE_first_tail_x15_r0_body.zjobs156 : PRE_first_tail_x15_r0_body.s1512.jobs = PRE_first_tail_x15_r0_body.s1513.jobs.map PRE_first_tail_x15_r0_body.kappa156.job
kernel_rfl PRE_first_tail_x15_r0_body.zstores156 : PRE_first_tail_x15_r0_body.s1512.stores = PRE_first_tail_x15_r0_body.kappa156.stores PRE_first_tail_x15_r0_body.s1513.stores
kernel_rfl PRE_first_tail_x15_r0_body.zroots156 : checkRootsSupp PRE_first_tail_x15_r0_body.s1513 6770 = true
kernel_rfl PRE_first_tail_x15_r0_body.znC156 : PRE_first_tail_x15_r0_body.S1511.tab.length + PRE_first_tail_x15_r0_body.cws156.length = 6770
-- the map as `Conv.compact_shift` states it (the call's counters for the literals)
kernel_rfl PRE_first_tail_x15_r0_body.zkap156 : PRE_first_tail_x15_r0_body.kappa156 = Conv.Map.compact PRE_first_tail_x15_r0_body.s1511.next 2799034 PRE_first_tail_x15_r0_body.S1511.tab.length PRE_first_tail_x15_r0_body.pl156 (PRE_first_tail_x15_r0_body.nr156.map NumV.ref) PRE_first_tail_x15_r0_body.kd156.big
  PRE_first_tail_x15_r0_body.kd156.region PRE_first_tail_x15_r0_body.kd156.nodeF
-- the bridge inactive at the canonical state (`Conv.FullShiftQ.toX`; the merged state's bridge is the canonical's: cbridge)
theorem PRE_first_tail_x15_r0_body.zbin156 : (Host.Ts.Sim.Full.bridgeOf PRE_first_tail_x15_r0_body.s1513.ffi).active = false := (Host.Load.Boot.replay_active Host.Load.Run.Prompt.P.oblog2818)
-- the JS bookkeeping's step (`Conv.JClean.step` over the changed list) and the canonical roots' bigint freedom
kernel_rfl PRE_first_tail_x15_r0_body.zjc156 : Conv.jcleanListB (⟨21287, 18386, 2797885, 6770⟩ : Conv.Cnt) PRE_first_tail_x15_r0_body.s1513 PRE_first_tail_x15_r0_body.cl156 = true
kernel_rfl PRE_first_tail_x15_r0_body.zrootsB156 : noBigRootsP (fun i => !Conv.oldBigB (⟨21287, 18386, 2797885, 6770⟩ : Conv.Cnt) i) PRE_first_tail_x15_r0_body.s1513.trace PRE_first_tail_x15_r0_body.s1513 = true
kernel_rfl PRE_first_tail_x15_r0_body.zhm156 : Nat.ble (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s0.ffi).mlx.nnext 18359 = true
theorem PRE_first_tail_x15_r0_body.cjcl156 (h : Conv.JClean (⟨21284, 18359, 2797879, 6752⟩ : Conv.Cnt) PRE_first_tail_x15_r0_body.s1511) : Conv.JClean (⟨21287, 18386, 2797885, 6770⟩ : Conv.Cnt) PRE_first_tail_x15_r0_body.s1513 :=
  Conv.JClean.step h (Conv.Cnt.le_of_leB PRE_first_tail_x15_r0_body.cle156)
    (Conv.heap_off_setAll PRE_first_tail_x15_r0_body.cheap156 fun a ha => Nat.blt_eq.mp (List.all_eq_true.mp PRE_first_tail_x15_r0_body.zclbd156 a ha)) PRE_first_tail_x15_r0_body.zjc156

end Host.Load.Run.Tpl
