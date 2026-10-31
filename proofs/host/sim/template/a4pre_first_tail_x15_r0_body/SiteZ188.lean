import host.sim.template.a4pre_first_tail_x15_r0_body.SiteS188
import host.sim.template.a4pre_first_tail_x15_r0_body.SiteK188
import host.sim.template.a4pre_first_tail_x15_r0_body.SiteF188
import host.sim.conv.CompactShift
import host.sim.template.Check
import host.sim.BigFreeP
import host.sim.template.CallGen
set_option Elab.async false
namespace Host.Load.Run.Tpl
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
open Host.Ts Host.Ts.Sim Host.Ts.Sim.Template

/-! The compaction's state shift at call site 188 of chain `PRE_first_tail_x15_r0_body` (`Conv.compact_shift`): the call `PRE_first_tail_x15_r0_body.s1654`, the merged
state `PRE_first_tail_x15_r0_body.s1655`, the canonical state `PRE_first_tail_x15_r0_body.s1656`; its frames [2665,2673467,2673472,2673473] (kept arrays [2665,2673467]). -/

-- the map's places and counters
kernel_rfl PRE_first_tail_x15_r0_body.zpl188 : PRE_first_tail_x15_r0_body.pl188.all (Nat.ble PRE_first_tail_x15_r0_body.s1654.next) = true
kernel_rfl PRE_first_tail_x15_r0_body.zplnd188 : nodupT PRE_first_tail_x15_r0_body.pl188 PTrie.nil = true
kernel_rfl PRE_first_tail_x15_r0_body.zn1188 : Nat.ble PRE_first_tail_x15_r0_body.s1654.next 2822042 = true
kernel_rfl PRE_first_tail_x15_r0_body.zfirst188 : Nat.ble aFirst PRE_first_tail_x15_r0_body.s1654.next = true
kernel_rfl PRE_first_tail_x15_r0_body.zscn188 : PRE_first_tail_x15_r0_body.s1656.next = PRE_first_tail_x15_r0_body.s1654.next + PRE_first_tail_x15_r0_body.pl188.length
kernel_rfl PRE_first_tail_x15_r0_body.zsmn188 : PRE_first_tail_x15_r0_body.s1655.next = 2822042
kernel_rfl PRE_first_tail_x15_r0_body.zgrow188 : Nat.ble PRE_first_tail_x15_r0_body.s1656.next PRE_first_tail_x15_r0_body.s1655.next = true
-- the tables
kernel_rfl PRE_first_tail_x15_r0_body.zfresh188 : PRE_first_tail_x15_r0_body.S1654.tab.all (fun e => PRE_first_tail_x15_r0_body.cws188.all fun v => e.noVar v) = true
kernel_rfl PRE_first_tail_x15_r0_body.zcnd188 : nodupT PRE_first_tail_x15_r0_body.cws188 PTrie.nil = true
kernel_rfl PRE_first_tail_x15_r0_body.znrHi188 : PRE_first_tail_x15_r0_body.nr188.all (fun r => Nat.blt r PRE_first_tail_x15_r0_body.S1655.tab.length) = true
-- the frames: every framed address below the call's counter; the kept arrays the chain start's, extended in the merged state
kernel_rfl PRE_first_tail_x15_r0_body.zfrlt188 : [2665, 2673467, 2673472, 2673473].all (fun a => Nat.blt a PRE_first_tail_x15_r0_body.s1654.next) = true
kernel_rfl PRE_first_tail_x15_r0_body.zg188_2665 : PRE_first_tail_x15_r0_body.s1656.heap.get 2665 = some (.obj (objOf PRE_first_tail_x15_r0_body.s1656 2665))
kernel_rfl PRE_first_tail_x15_r0_body.zk188_2665 : (objOf PRE_first_tail_x15_r0_body.s1656 2665).kind = .array (arrOf PRE_first_tail_x15_r0_body.s0 2665)
kernel_rfl PRE_first_tail_x15_r0_body.zm188_2665 : PRE_first_tail_x15_r0_body.s1655.heap.get 2665 = some (.obj { PRE_first_tail_x15_r0_body.kappa188.obj (objOf PRE_first_tail_x15_r0_body.s1656 2665) with
  kind := .array (arrOf PRE_first_tail_x15_r0_body.s0 2665 ++ (arrOf PRE_first_tail_x15_r0_body.s1655 2665).drop (arrOf PRE_first_tail_x15_r0_body.s0 2665).length) })
kernel_rfl PRE_first_tail_x15_r0_body.zg188_2673467 : PRE_first_tail_x15_r0_body.s1656.heap.get 2673467 = some (.obj (objOf PRE_first_tail_x15_r0_body.s1656 2673467))
kernel_rfl PRE_first_tail_x15_r0_body.zk188_2673467 : (objOf PRE_first_tail_x15_r0_body.s1656 2673467).kind = .array (arrOf PRE_first_tail_x15_r0_body.s0 2673467)
kernel_rfl PRE_first_tail_x15_r0_body.zm188_2673467 : PRE_first_tail_x15_r0_body.s1655.heap.get 2673467 = some (.obj { PRE_first_tail_x15_r0_body.kappa188.obj (objOf PRE_first_tail_x15_r0_body.s1656 2673467) with
  kind := .array (arrOf PRE_first_tail_x15_r0_body.s0 2673467 ++ (arrOf PRE_first_tail_x15_r0_body.s1655 2673467).drop (arrOf PRE_first_tail_x15_r0_body.s0 2673467).length) })
kernel_rfl PRE_first_tail_x15_r0_body.zw188_4910 : (PRE_first_tail_x15_r0_body.s1656.heap.get 4910).isSome = true
kernel_rfl PRE_first_tail_x15_r0_body.zw188_2673472 : (PRE_first_tail_x15_r0_body.s1656.heap.get 2673472).isSome = true
kernel_rfl PRE_first_tail_x15_r0_body.zw188_2673473 : (PRE_first_tail_x15_r0_body.s1656.heap.get 2673473).isSome = true
-- the heap: the changed list in range, holding the stage's written and fresh addresses; the canonical side's image
kernel_rfl PRE_first_tail_x15_r0_body.zclbd188 : PRE_first_tail_x15_r0_body.cl188.all (fun b => Nat.blt (b / 4096) (4 ^ 31)) = true
kernel_rfl PRE_first_tail_x15_r0_body.zwr188 : PRE_first_tail_x15_r0_body.st188.wr.all (fun b => !Nat.blt b PRE_first_tail_x15_r0_body.s1654.next || PRE_first_tail_x15_r0_body.cl188.contains b) = true
def PRE_first_tail_x15_r0_body.zl188 : List Nat := PRE_first_tail_x15_r0_body.cl188.filter fun a => !(List.contains [2665, 2673467] a)
kernel_rfl PRE_first_tail_x15_r0_body.zimgE188 : PRE_first_tail_x15_r0_body.zl188.map (fun a => PRE_first_tail_x15_r0_body.s1655.heap.get (PRE_first_tail_x15_r0_body.kappa188.a a)) = PRE_first_tail_x15_r0_body.zl188.map (fun a => (PRE_first_tail_x15_r0_body.s1656.heap.get a).map PRE_first_tail_x15_r0_body.kappa188.hobj)
theorem PRE_first_tail_x15_r0_body.zimg188 : HeapImg PRE_first_tail_x15_r0_body.kappa188 PRE_first_tail_x15_r0_body.s1656 PRE_first_tail_x15_r0_body.s1655 PRE_first_tail_x15_r0_body.zl188 := PRE_first_tail_x15_r0_body.zimgE188
-- the roots and their supports
kernel_rfl PRE_first_tail_x15_r0_body.zctl188 : PRE_first_tail_x15_r0_body.s1655.ctl = PRE_first_tail_x15_r0_body.kappa188.ctl PRE_first_tail_x15_r0_body.s1656.ctl
kernel_rfl PRE_first_tail_x15_r0_body.zstack188 : PRE_first_tail_x15_r0_body.s1655.stack = PRE_first_tail_x15_r0_body.s1656.stack.map PRE_first_tail_x15_r0_body.kappa188.frame
kernel_rfl PRE_first_tail_x15_r0_body.zjobs188 : PRE_first_tail_x15_r0_body.s1655.jobs = PRE_first_tail_x15_r0_body.s1656.jobs.map PRE_first_tail_x15_r0_body.kappa188.job
kernel_rfl PRE_first_tail_x15_r0_body.zstores188 : PRE_first_tail_x15_r0_body.s1655.stores = PRE_first_tail_x15_r0_body.kappa188.stores PRE_first_tail_x15_r0_body.s1656.stores
kernel_rfl PRE_first_tail_x15_r0_body.zroots188 : checkRootsSupp PRE_first_tail_x15_r0_body.s1656 8092 = true
kernel_rfl PRE_first_tail_x15_r0_body.znC188 : PRE_first_tail_x15_r0_body.S1654.tab.length + PRE_first_tail_x15_r0_body.cws188.length = 8092
-- the map as `Conv.compact_shift` states it (the call's counters for the literals)
kernel_rfl PRE_first_tail_x15_r0_body.zkap188 : PRE_first_tail_x15_r0_body.kappa188 = Conv.Map.compact PRE_first_tail_x15_r0_body.s1654.next 2822042 PRE_first_tail_x15_r0_body.S1654.tab.length PRE_first_tail_x15_r0_body.pl188 (PRE_first_tail_x15_r0_body.nr188.map NumV.ref) PRE_first_tail_x15_r0_body.kd188.big
  PRE_first_tail_x15_r0_body.kd188.region PRE_first_tail_x15_r0_body.kd188.nodeF
-- the bridge inactive at the canonical state (`Conv.FullShiftQ.toX`; the merged state's bridge is the canonical's: cbridge)
theorem PRE_first_tail_x15_r0_body.zbin188 : (Host.Ts.Sim.Full.bridgeOf PRE_first_tail_x15_r0_body.s1656.ffi).active = false := (Host.Load.Boot.replay_active Host.Load.Run.Prompt.P.oblog2818)
-- the JS bookkeeping's step (`Conv.JClean.step` over the changed list) and the canonical roots' bigint freedom
kernel_rfl PRE_first_tail_x15_r0_body.zjc188 : Conv.jcleanListB (⟨21893, 19003, 2822032, 8092⟩ : Conv.Cnt) PRE_first_tail_x15_r0_body.s1656 PRE_first_tail_x15_r0_body.cl188 = true
kernel_rfl PRE_first_tail_x15_r0_body.zroots2188 : noBigRootsP (fun i => !Conv.oldBigB (⟨21893, 19003, 2822032, 8092⟩ : Conv.Cnt) i) PRE_first_tail_x15_r0_body.s1656.trace PRE_first_tail_x15_r0_body.s1656 = true
kernel_rfl PRE_first_tail_x15_r0_body.zhm188 : Nat.ble (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s0.ffi).mlx.nnext 19003 = true
theorem PRE_first_tail_x15_r0_body.cjcl188 (h : Conv.JClean (⟨21893, 19003, 2822031, 8092⟩ : Conv.Cnt) PRE_first_tail_x15_r0_body.s1654) : Conv.JClean (⟨21893, 19003, 2822032, 8092⟩ : Conv.Cnt) PRE_first_tail_x15_r0_body.s1656 :=
  Conv.JClean.step h (Conv.Cnt.le_of_leB PRE_first_tail_x15_r0_body.cle188)
    (Conv.heap_off_setAll PRE_first_tail_x15_r0_body.cheap188 fun a ha => Nat.blt_eq.mp (List.all_eq_true.mp PRE_first_tail_x15_r0_body.zclbd188 a ha)) PRE_first_tail_x15_r0_body.zjc188

end Host.Load.Run.Tpl
