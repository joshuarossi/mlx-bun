import host.sim.template.a4pre_first_tail_x15_r0_body.SiteS146
import host.sim.template.a4pre_first_tail_x15_r0_body.SiteK146
import host.sim.template.a4pre_first_tail_x15_r0_body.SiteF146
import host.sim.conv.CompactShift
import host.sim.template.Check
import host.sim.BigFreeP
import host.sim.template.CallGen
set_option Elab.async false
namespace Host.Load.Run.Tpl
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
open Host.Ts Host.Ts.Sim Host.Ts.Sim.Template

/-! The compaction's state shift at call site 146 of chain `PRE_first_tail_x15_r0_body` (`Conv.compact_shift`): the call `PRE_first_tail_x15_r0_body.s1408`, the merged
state `PRE_first_tail_x15_r0_body.s1409`, the canonical state `PRE_first_tail_x15_r0_body.s1410`; its frames [2665,2673467,2673472,2673473] (kept arrays [2665,2673467]). -/

-- the map's places and counters
kernel_rfl PRE_first_tail_x15_r0_body.zpl146 : PRE_first_tail_x15_r0_body.pl146.all (Nat.ble PRE_first_tail_x15_r0_body.s1408.next) = true
kernel_rfl PRE_first_tail_x15_r0_body.zplnd146 : nodupT PRE_first_tail_x15_r0_body.pl146 PTrie.nil = true
kernel_rfl PRE_first_tail_x15_r0_body.zn1146 : Nat.ble PRE_first_tail_x15_r0_body.s1408.next 2789263 = true
kernel_rfl PRE_first_tail_x15_r0_body.zfirst146 : Nat.ble aFirst PRE_first_tail_x15_r0_body.s1408.next = true
kernel_rfl PRE_first_tail_x15_r0_body.zscn146 : PRE_first_tail_x15_r0_body.s1410.next = PRE_first_tail_x15_r0_body.s1408.next + PRE_first_tail_x15_r0_body.pl146.length
kernel_rfl PRE_first_tail_x15_r0_body.zsmn146 : PRE_first_tail_x15_r0_body.s1409.next = 2789263
kernel_rfl PRE_first_tail_x15_r0_body.zgrow146 : Nat.ble PRE_first_tail_x15_r0_body.s1410.next PRE_first_tail_x15_r0_body.s1409.next = true
-- the tables
kernel_rfl PRE_first_tail_x15_r0_body.zfresh146 : PRE_first_tail_x15_r0_body.S1408.tab.all (fun e => PRE_first_tail_x15_r0_body.cws146.all fun v => e.noVar v) = true
kernel_rfl PRE_first_tail_x15_r0_body.zcnd146 : nodupT PRE_first_tail_x15_r0_body.cws146 PTrie.nil = true
kernel_rfl PRE_first_tail_x15_r0_body.znrHi146 : PRE_first_tail_x15_r0_body.nr146.all (fun r => Nat.blt r PRE_first_tail_x15_r0_body.S1409.tab.length) = true
-- the frames: every framed address below the call's counter; the kept arrays the chain start's, extended in the merged state
kernel_rfl PRE_first_tail_x15_r0_body.zfrlt146 : [2665, 2673467, 2673472, 2673473].all (fun a => Nat.blt a PRE_first_tail_x15_r0_body.s1408.next) = true
kernel_rfl PRE_first_tail_x15_r0_body.zg146_2665 : PRE_first_tail_x15_r0_body.s1410.heap.get 2665 = some (.obj (objOf PRE_first_tail_x15_r0_body.s1410 2665))
kernel_rfl PRE_first_tail_x15_r0_body.zk146_2665 : (objOf PRE_first_tail_x15_r0_body.s1410 2665).kind = .array (arrOf PRE_first_tail_x15_r0_body.s0 2665)
kernel_rfl PRE_first_tail_x15_r0_body.zm146_2665 : PRE_first_tail_x15_r0_body.s1409.heap.get 2665 = some (.obj { PRE_first_tail_x15_r0_body.kappa146.obj (objOf PRE_first_tail_x15_r0_body.s1410 2665) with
  kind := .array (arrOf PRE_first_tail_x15_r0_body.s0 2665 ++ (arrOf PRE_first_tail_x15_r0_body.s1409 2665).drop (arrOf PRE_first_tail_x15_r0_body.s0 2665).length) })
kernel_rfl PRE_first_tail_x15_r0_body.zg146_2673467 : PRE_first_tail_x15_r0_body.s1410.heap.get 2673467 = some (.obj (objOf PRE_first_tail_x15_r0_body.s1410 2673467))
kernel_rfl PRE_first_tail_x15_r0_body.zk146_2673467 : (objOf PRE_first_tail_x15_r0_body.s1410 2673467).kind = .array (arrOf PRE_first_tail_x15_r0_body.s0 2673467)
kernel_rfl PRE_first_tail_x15_r0_body.zm146_2673467 : PRE_first_tail_x15_r0_body.s1409.heap.get 2673467 = some (.obj { PRE_first_tail_x15_r0_body.kappa146.obj (objOf PRE_first_tail_x15_r0_body.s1410 2673467) with
  kind := .array (arrOf PRE_first_tail_x15_r0_body.s0 2673467 ++ (arrOf PRE_first_tail_x15_r0_body.s1409 2673467).drop (arrOf PRE_first_tail_x15_r0_body.s0 2673467).length) })
kernel_rfl PRE_first_tail_x15_r0_body.zw146_4910 : (PRE_first_tail_x15_r0_body.s1410.heap.get 4910).isSome = true
kernel_rfl PRE_first_tail_x15_r0_body.zw146_2673472 : (PRE_first_tail_x15_r0_body.s1410.heap.get 2673472).isSome = true
kernel_rfl PRE_first_tail_x15_r0_body.zw146_2673473 : (PRE_first_tail_x15_r0_body.s1410.heap.get 2673473).isSome = true
-- the heap: the changed list in range, holding the stage's written and fresh addresses; the canonical side's image
kernel_rfl PRE_first_tail_x15_r0_body.zclbd146 : PRE_first_tail_x15_r0_body.cl146.all (fun b => Nat.blt (b / 4096) (4 ^ 31)) = true
kernel_rfl PRE_first_tail_x15_r0_body.zwr146 : PRE_first_tail_x15_r0_body.st146.wr.all (fun b => !Nat.blt b PRE_first_tail_x15_r0_body.s1408.next || PRE_first_tail_x15_r0_body.cl146.contains b) = true
def PRE_first_tail_x15_r0_body.zl146 : List Nat := PRE_first_tail_x15_r0_body.cl146.filter fun a => !(List.contains [2665, 2673467] a)
kernel_rfl PRE_first_tail_x15_r0_body.zimgE146 : PRE_first_tail_x15_r0_body.zl146.map (fun a => PRE_first_tail_x15_r0_body.s1409.heap.get (PRE_first_tail_x15_r0_body.kappa146.a a)) = PRE_first_tail_x15_r0_body.zl146.map (fun a => (PRE_first_tail_x15_r0_body.s1410.heap.get a).map PRE_first_tail_x15_r0_body.kappa146.hobj)
theorem PRE_first_tail_x15_r0_body.zimg146 : HeapImg PRE_first_tail_x15_r0_body.kappa146 PRE_first_tail_x15_r0_body.s1410 PRE_first_tail_x15_r0_body.s1409 PRE_first_tail_x15_r0_body.zl146 := PRE_first_tail_x15_r0_body.zimgE146
-- the roots and their supports
kernel_rfl PRE_first_tail_x15_r0_body.zctl146 : PRE_first_tail_x15_r0_body.s1409.ctl = PRE_first_tail_x15_r0_body.kappa146.ctl PRE_first_tail_x15_r0_body.s1410.ctl
kernel_rfl PRE_first_tail_x15_r0_body.zstack146 : PRE_first_tail_x15_r0_body.s1409.stack = PRE_first_tail_x15_r0_body.s1410.stack.map PRE_first_tail_x15_r0_body.kappa146.frame
kernel_rfl PRE_first_tail_x15_r0_body.zjobs146 : PRE_first_tail_x15_r0_body.s1409.jobs = PRE_first_tail_x15_r0_body.s1410.jobs.map PRE_first_tail_x15_r0_body.kappa146.job
kernel_rfl PRE_first_tail_x15_r0_body.zstores146 : PRE_first_tail_x15_r0_body.s1409.stores = PRE_first_tail_x15_r0_body.kappa146.stores PRE_first_tail_x15_r0_body.s1410.stores
kernel_rfl PRE_first_tail_x15_r0_body.zroots146 : checkRootsSupp PRE_first_tail_x15_r0_body.s1410 6295 = true
kernel_rfl PRE_first_tail_x15_r0_body.znC146 : PRE_first_tail_x15_r0_body.S1408.tab.length + PRE_first_tail_x15_r0_body.cws146.length = 6295
-- the map as `Conv.compact_shift` states it (the call's counters for the literals)
kernel_rfl PRE_first_tail_x15_r0_body.zkap146 : PRE_first_tail_x15_r0_body.kappa146 = Conv.Map.compact PRE_first_tail_x15_r0_body.s1408.next 2789263 PRE_first_tail_x15_r0_body.S1408.tab.length PRE_first_tail_x15_r0_body.pl146 (PRE_first_tail_x15_r0_body.nr146.map NumV.ref) PRE_first_tail_x15_r0_body.kd146.big
  PRE_first_tail_x15_r0_body.kd146.region PRE_first_tail_x15_r0_body.kd146.nodeF
-- the bridge inactive at the canonical state (`Conv.FullShiftQ.toX`; the merged state's bridge is the canonical's: cbridge)
theorem PRE_first_tail_x15_r0_body.zbin146 : (Host.Ts.Sim.Full.bridgeOf PRE_first_tail_x15_r0_body.s1410.ffi).active = false := (Host.Load.Boot.replay_active Host.Load.Run.Prompt.P.oblog2818)
-- the JS bookkeeping's step (`Conv.JClean.step` over the changed list) and the canonical roots' bigint freedom
kernel_rfl PRE_first_tail_x15_r0_body.zjc146 : Conv.jcleanListB (⟨21071, 18166, 2789244, 6295⟩ : Conv.Cnt) PRE_first_tail_x15_r0_body.s1410 PRE_first_tail_x15_r0_body.cl146 = true
kernel_rfl PRE_first_tail_x15_r0_body.zrootsB146 : noBigRootsP (fun i => !Conv.oldBigB (⟨21071, 18166, 2789244, 6295⟩ : Conv.Cnt) i) PRE_first_tail_x15_r0_body.s1410.trace PRE_first_tail_x15_r0_body.s1410 = true
kernel_rfl PRE_first_tail_x15_r0_body.zhm146 : Nat.ble (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s0.ffi).mlx.nnext 18166 = true
theorem PRE_first_tail_x15_r0_body.cjcl146 (h : Conv.JClean (⟨21071, 18166, 2789243, 6295⟩ : Conv.Cnt) PRE_first_tail_x15_r0_body.s1408) : Conv.JClean (⟨21071, 18166, 2789244, 6295⟩ : Conv.Cnt) PRE_first_tail_x15_r0_body.s1410 :=
  Conv.JClean.step h (Conv.Cnt.le_of_leB PRE_first_tail_x15_r0_body.cle146)
    (Conv.heap_off_setAll PRE_first_tail_x15_r0_body.cheap146 fun a ha => Nat.blt_eq.mp (List.all_eq_true.mp PRE_first_tail_x15_r0_body.zclbd146 a ha)) PRE_first_tail_x15_r0_body.zjc146

end Host.Load.Run.Tpl
