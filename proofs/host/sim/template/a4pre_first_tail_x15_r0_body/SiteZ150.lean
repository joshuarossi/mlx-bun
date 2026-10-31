import host.sim.template.a4pre_first_tail_x15_r0_body.SiteS150
import host.sim.template.a4pre_first_tail_x15_r0_body.SiteK150
import host.sim.template.a4pre_first_tail_x15_r0_body.SiteF150
import host.sim.conv.CompactShift
import host.sim.template.Check
import host.sim.BigFreeP
import host.sim.template.CallGen
set_option Elab.async false
namespace Host.Load.Run.Tpl
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
open Host.Ts Host.Ts.Sim Host.Ts.Sim.Template

/-! The compaction's state shift at call site 150 of chain `PRE_first_tail_x15_r0_body` (`Conv.compact_shift`): the call `PRE_first_tail_x15_r0_body.s1328`, the merged
state `PRE_first_tail_x15_r0_body.s1329`, the canonical state `PRE_first_tail_x15_r0_body.s1330`; its frames [2665,2673467,2673472,2673473] (kept arrays [2665,2673467]). -/

-- the map's places and counters
kernel_rfl PRE_first_tail_x15_r0_body.zpl150 : PRE_first_tail_x15_r0_body.pl150.all (Nat.ble PRE_first_tail_x15_r0_body.s1328.next) = true
kernel_rfl PRE_first_tail_x15_r0_body.zplnd150 : nodupT PRE_first_tail_x15_r0_body.pl150 PTrie.nil = true
kernel_rfl PRE_first_tail_x15_r0_body.zn1150 : Nat.ble PRE_first_tail_x15_r0_body.s1328.next 2794134 = true
kernel_rfl PRE_first_tail_x15_r0_body.zfirst150 : Nat.ble aFirst PRE_first_tail_x15_r0_body.s1328.next = true
kernel_rfl PRE_first_tail_x15_r0_body.zscn150 : PRE_first_tail_x15_r0_body.s1330.next = PRE_first_tail_x15_r0_body.s1328.next + PRE_first_tail_x15_r0_body.pl150.length
kernel_rfl PRE_first_tail_x15_r0_body.zsmn150 : PRE_first_tail_x15_r0_body.s1329.next = 2794134
kernel_rfl PRE_first_tail_x15_r0_body.zgrow150 : Nat.ble PRE_first_tail_x15_r0_body.s1330.next PRE_first_tail_x15_r0_body.s1329.next = true
-- the tables
kernel_rfl PRE_first_tail_x15_r0_body.zfresh150 : PRE_first_tail_x15_r0_body.S1328.tab.all (fun e => PRE_first_tail_x15_r0_body.cws150.all fun v => e.noVar v) = true
kernel_rfl PRE_first_tail_x15_r0_body.zcnd150 : nodupT PRE_first_tail_x15_r0_body.cws150 PTrie.nil = true
kernel_rfl PRE_first_tail_x15_r0_body.znrHi150 : PRE_first_tail_x15_r0_body.nr150.all (fun r => Nat.blt r PRE_first_tail_x15_r0_body.S1329.tab.length) = true
-- the frames: every framed address below the call's counter; the kept arrays the chain start's, extended in the merged state
kernel_rfl PRE_first_tail_x15_r0_body.zfrlt150 : [2665, 2673467, 2673472, 2673473].all (fun a => Nat.blt a PRE_first_tail_x15_r0_body.s1328.next) = true
kernel_rfl PRE_first_tail_x15_r0_body.zg150_2665 : PRE_first_tail_x15_r0_body.s1330.heap.get 2665 = some (.obj (objOf PRE_first_tail_x15_r0_body.s1330 2665))
kernel_rfl PRE_first_tail_x15_r0_body.zk150_2665 : (objOf PRE_first_tail_x15_r0_body.s1330 2665).kind = .array (arrOf PRE_first_tail_x15_r0_body.s0 2665)
kernel_rfl PRE_first_tail_x15_r0_body.zm150_2665 : PRE_first_tail_x15_r0_body.s1329.heap.get 2665 = some (.obj { PRE_first_tail_x15_r0_body.kappa150.obj (objOf PRE_first_tail_x15_r0_body.s1330 2665) with
  kind := .array (arrOf PRE_first_tail_x15_r0_body.s0 2665 ++ (arrOf PRE_first_tail_x15_r0_body.s1329 2665).drop (arrOf PRE_first_tail_x15_r0_body.s0 2665).length) })
kernel_rfl PRE_first_tail_x15_r0_body.zg150_2673467 : PRE_first_tail_x15_r0_body.s1330.heap.get 2673467 = some (.obj (objOf PRE_first_tail_x15_r0_body.s1330 2673467))
kernel_rfl PRE_first_tail_x15_r0_body.zk150_2673467 : (objOf PRE_first_tail_x15_r0_body.s1330 2673467).kind = .array (arrOf PRE_first_tail_x15_r0_body.s0 2673467)
kernel_rfl PRE_first_tail_x15_r0_body.zm150_2673467 : PRE_first_tail_x15_r0_body.s1329.heap.get 2673467 = some (.obj { PRE_first_tail_x15_r0_body.kappa150.obj (objOf PRE_first_tail_x15_r0_body.s1330 2673467) with
  kind := .array (arrOf PRE_first_tail_x15_r0_body.s0 2673467 ++ (arrOf PRE_first_tail_x15_r0_body.s1329 2673467).drop (arrOf PRE_first_tail_x15_r0_body.s0 2673467).length) })
kernel_rfl PRE_first_tail_x15_r0_body.zw150_4910 : (PRE_first_tail_x15_r0_body.s1330.heap.get 4910).isSome = true
kernel_rfl PRE_first_tail_x15_r0_body.zw150_2673472 : (PRE_first_tail_x15_r0_body.s1330.heap.get 2673472).isSome = true
kernel_rfl PRE_first_tail_x15_r0_body.zw150_2673473 : (PRE_first_tail_x15_r0_body.s1330.heap.get 2673473).isSome = true
-- the heap: the changed list in range, holding the stage's written and fresh addresses; the canonical side's image
kernel_rfl PRE_first_tail_x15_r0_body.zclbd150 : PRE_first_tail_x15_r0_body.cl150.all (fun b => Nat.blt (b / 4096) (4 ^ 31)) = true
kernel_rfl PRE_first_tail_x15_r0_body.zwr150 : PRE_first_tail_x15_r0_body.st150.wr.all (fun b => !Nat.blt b PRE_first_tail_x15_r0_body.s1328.next || PRE_first_tail_x15_r0_body.cl150.contains b) = true
def PRE_first_tail_x15_r0_body.zl150 : List Nat := PRE_first_tail_x15_r0_body.cl150.filter fun a => !(List.contains [2665, 2673467] a)
kernel_rfl PRE_first_tail_x15_r0_body.zimgE150 : PRE_first_tail_x15_r0_body.zl150.map (fun a => PRE_first_tail_x15_r0_body.s1329.heap.get (PRE_first_tail_x15_r0_body.kappa150.a a)) = PRE_first_tail_x15_r0_body.zl150.map (fun a => (PRE_first_tail_x15_r0_body.s1330.heap.get a).map PRE_first_tail_x15_r0_body.kappa150.hobj)
theorem PRE_first_tail_x15_r0_body.zimg150 : HeapImg PRE_first_tail_x15_r0_body.kappa150 PRE_first_tail_x15_r0_body.s1330 PRE_first_tail_x15_r0_body.s1329 PRE_first_tail_x15_r0_body.zl150 := PRE_first_tail_x15_r0_body.zimgE150
-- the roots and their supports
kernel_rfl PRE_first_tail_x15_r0_body.zctl150 : PRE_first_tail_x15_r0_body.s1329.ctl = PRE_first_tail_x15_r0_body.kappa150.ctl PRE_first_tail_x15_r0_body.s1330.ctl
kernel_rfl PRE_first_tail_x15_r0_body.zstack150 : PRE_first_tail_x15_r0_body.s1329.stack = PRE_first_tail_x15_r0_body.s1330.stack.map PRE_first_tail_x15_r0_body.kappa150.frame
kernel_rfl PRE_first_tail_x15_r0_body.zjobs150 : PRE_first_tail_x15_r0_body.s1329.jobs = PRE_first_tail_x15_r0_body.s1330.jobs.map PRE_first_tail_x15_r0_body.kappa150.job
kernel_rfl PRE_first_tail_x15_r0_body.zstores150 : PRE_first_tail_x15_r0_body.s1329.stores = PRE_first_tail_x15_r0_body.kappa150.stores PRE_first_tail_x15_r0_body.s1330.stores
kernel_rfl PRE_first_tail_x15_r0_body.zroots150 : checkRootsSupp PRE_first_tail_x15_r0_body.s1330 6515 = true
kernel_rfl PRE_first_tail_x15_r0_body.znC150 : PRE_first_tail_x15_r0_body.S1328.tab.length + PRE_first_tail_x15_r0_body.cws150.length = 6515
-- the map as `Conv.compact_shift` states it (the call's counters for the literals)
kernel_rfl PRE_first_tail_x15_r0_body.zkap150 : PRE_first_tail_x15_r0_body.kappa150 = Conv.Map.compact PRE_first_tail_x15_r0_body.s1328.next 2794134 PRE_first_tail_x15_r0_body.S1328.tab.length PRE_first_tail_x15_r0_body.pl150 (PRE_first_tail_x15_r0_body.nr150.map NumV.ref) PRE_first_tail_x15_r0_body.kd150.big
  PRE_first_tail_x15_r0_body.kd150.region PRE_first_tail_x15_r0_body.kd150.nodeF
-- the bridge inactive at the canonical state (`Conv.FullShiftQ.toX`; the merged state's bridge is the canonical's: cbridge)
theorem PRE_first_tail_x15_r0_body.zbin150 : (Host.Ts.Sim.Full.bridgeOf PRE_first_tail_x15_r0_body.s1330.ffi).active = false := (Host.Load.Boot.replay_active Host.Load.Run.Prompt.P.oblog2818)
-- the JS bookkeeping's step (`Conv.JClean.step` over the changed list) and the canonical roots' bigint freedom
kernel_rfl PRE_first_tail_x15_r0_body.zjc150 : Conv.jcleanListB (⟨21165, 18275, 2792985, 6515⟩ : Conv.Cnt) PRE_first_tail_x15_r0_body.s1330 PRE_first_tail_x15_r0_body.cl150 = true
kernel_rfl PRE_first_tail_x15_r0_body.zroots2150 : noBigRootsP (fun i => !Conv.oldBigB (⟨21165, 18275, 2792985, 6515⟩ : Conv.Cnt) i) PRE_first_tail_x15_r0_body.s1330.trace PRE_first_tail_x15_r0_body.s1330 = true
kernel_rfl PRE_first_tail_x15_r0_body.zhm150 : Nat.ble (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s0.ffi).mlx.nnext 18248 = true
theorem PRE_first_tail_x15_r0_body.cjcl150 (h : Conv.JClean (⟨21162, 18248, 2792979, 6497⟩ : Conv.Cnt) PRE_first_tail_x15_r0_body.s1328) : Conv.JClean (⟨21165, 18275, 2792985, 6515⟩ : Conv.Cnt) PRE_first_tail_x15_r0_body.s1330 :=
  Conv.JClean.step h (Conv.Cnt.le_of_leB PRE_first_tail_x15_r0_body.cle150)
    (Conv.heap_off_setAll PRE_first_tail_x15_r0_body.cheap150 fun a ha => Nat.blt_eq.mp (List.all_eq_true.mp PRE_first_tail_x15_r0_body.zclbd150 a ha)) PRE_first_tail_x15_r0_body.zjc150

end Host.Load.Run.Tpl
