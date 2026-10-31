import host.sim.template.a4pre_first_tail_x15_r0_body.SiteS147
import host.sim.template.a4pre_first_tail_x15_r0_body.SiteK147
import host.sim.template.a4pre_first_tail_x15_r0_body.SiteF147
import host.sim.conv.CompactShift
import host.sim.template.Check
import host.sim.BigFreeP
import host.sim.template.CallGen
set_option Elab.async false
namespace Host.Load.Run.Tpl
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
open Host.Ts Host.Ts.Sim Host.Ts.Sim.Template

/-! The compaction's state shift at call site 147 of chain `PRE_first_tail_x15_r0_body` (`Conv.compact_shift`): the call `PRE_first_tail_x15_r0_body.s1301`, the merged
state `PRE_first_tail_x15_r0_body.s1302`, the canonical state `PRE_first_tail_x15_r0_body.s1303`; its frames [2665,2673467,2673472,2673473] (kept arrays [2665,2673467]). -/

-- the map's places and counters
kernel_rfl PRE_first_tail_x15_r0_body.zpl147 : PRE_first_tail_x15_r0_body.pl147.all (Nat.ble PRE_first_tail_x15_r0_body.s1301.next) = true
kernel_rfl PRE_first_tail_x15_r0_body.zplnd147 : nodupT PRE_first_tail_x15_r0_body.pl147 PTrie.nil = true
kernel_rfl PRE_first_tail_x15_r0_body.zn1147 : Nat.ble PRE_first_tail_x15_r0_body.s1301.next 2791874 = true
kernel_rfl PRE_first_tail_x15_r0_body.zfirst147 : Nat.ble aFirst PRE_first_tail_x15_r0_body.s1301.next = true
kernel_rfl PRE_first_tail_x15_r0_body.zscn147 : PRE_first_tail_x15_r0_body.s1303.next = PRE_first_tail_x15_r0_body.s1301.next + PRE_first_tail_x15_r0_body.pl147.length
kernel_rfl PRE_first_tail_x15_r0_body.zsmn147 : PRE_first_tail_x15_r0_body.s1302.next = 2791874
kernel_rfl PRE_first_tail_x15_r0_body.zgrow147 : Nat.ble PRE_first_tail_x15_r0_body.s1303.next PRE_first_tail_x15_r0_body.s1302.next = true
-- the tables
kernel_rfl PRE_first_tail_x15_r0_body.zfresh147 : PRE_first_tail_x15_r0_body.S1301.tab.all (fun e => PRE_first_tail_x15_r0_body.cws147.all fun v => e.noVar v) = true
kernel_rfl PRE_first_tail_x15_r0_body.zcnd147 : nodupT PRE_first_tail_x15_r0_body.cws147 PTrie.nil = true
kernel_rfl PRE_first_tail_x15_r0_body.znrHi147 : PRE_first_tail_x15_r0_body.nr147.all (fun r => Nat.blt r PRE_first_tail_x15_r0_body.S1302.tab.length) = true
-- the frames: every framed address below the call's counter; the kept arrays the chain start's, extended in the merged state
kernel_rfl PRE_first_tail_x15_r0_body.zfrlt147 : [2665, 2673467, 2673472, 2673473].all (fun a => Nat.blt a PRE_first_tail_x15_r0_body.s1301.next) = true
kernel_rfl PRE_first_tail_x15_r0_body.zg147_2665 : PRE_first_tail_x15_r0_body.s1303.heap.get 2665 = some (.obj (objOf PRE_first_tail_x15_r0_body.s1303 2665))
kernel_rfl PRE_first_tail_x15_r0_body.zk147_2665 : (objOf PRE_first_tail_x15_r0_body.s1303 2665).kind = .array (arrOf PRE_first_tail_x15_r0_body.s0 2665)
kernel_rfl PRE_first_tail_x15_r0_body.zm147_2665 : PRE_first_tail_x15_r0_body.s1302.heap.get 2665 = some (.obj { PRE_first_tail_x15_r0_body.kappa147.obj (objOf PRE_first_tail_x15_r0_body.s1303 2665) with
  kind := .array (arrOf PRE_first_tail_x15_r0_body.s0 2665 ++ (arrOf PRE_first_tail_x15_r0_body.s1302 2665).drop (arrOf PRE_first_tail_x15_r0_body.s0 2665).length) })
kernel_rfl PRE_first_tail_x15_r0_body.zg147_2673467 : PRE_first_tail_x15_r0_body.s1303.heap.get 2673467 = some (.obj (objOf PRE_first_tail_x15_r0_body.s1303 2673467))
kernel_rfl PRE_first_tail_x15_r0_body.zk147_2673467 : (objOf PRE_first_tail_x15_r0_body.s1303 2673467).kind = .array (arrOf PRE_first_tail_x15_r0_body.s0 2673467)
kernel_rfl PRE_first_tail_x15_r0_body.zm147_2673467 : PRE_first_tail_x15_r0_body.s1302.heap.get 2673467 = some (.obj { PRE_first_tail_x15_r0_body.kappa147.obj (objOf PRE_first_tail_x15_r0_body.s1303 2673467) with
  kind := .array (arrOf PRE_first_tail_x15_r0_body.s0 2673467 ++ (arrOf PRE_first_tail_x15_r0_body.s1302 2673467).drop (arrOf PRE_first_tail_x15_r0_body.s0 2673467).length) })
kernel_rfl PRE_first_tail_x15_r0_body.zw147_4910 : (PRE_first_tail_x15_r0_body.s1303.heap.get 4910).isSome = true
kernel_rfl PRE_first_tail_x15_r0_body.zw147_2673472 : (PRE_first_tail_x15_r0_body.s1303.heap.get 2673472).isSome = true
kernel_rfl PRE_first_tail_x15_r0_body.zw147_2673473 : (PRE_first_tail_x15_r0_body.s1303.heap.get 2673473).isSome = true
-- the heap: the changed list in range, holding the stage's written and fresh addresses; the canonical side's image
kernel_rfl PRE_first_tail_x15_r0_body.zclbd147 : PRE_first_tail_x15_r0_body.cl147.all (fun b => Nat.blt (b / 4096) (4 ^ 31)) = true
kernel_rfl PRE_first_tail_x15_r0_body.zwr147 : PRE_first_tail_x15_r0_body.st147.wr.all (fun b => !Nat.blt b PRE_first_tail_x15_r0_body.s1301.next || PRE_first_tail_x15_r0_body.cl147.contains b) = true
def PRE_first_tail_x15_r0_body.zl147 : List Nat := PRE_first_tail_x15_r0_body.cl147.filter fun a => !(List.contains [2665, 2673467] a)
kernel_rfl PRE_first_tail_x15_r0_body.zimgE147 : PRE_first_tail_x15_r0_body.zl147.map (fun a => PRE_first_tail_x15_r0_body.s1302.heap.get (PRE_first_tail_x15_r0_body.kappa147.a a)) = PRE_first_tail_x15_r0_body.zl147.map (fun a => (PRE_first_tail_x15_r0_body.s1303.heap.get a).map PRE_first_tail_x15_r0_body.kappa147.hobj)
theorem PRE_first_tail_x15_r0_body.zimg147 : HeapImg PRE_first_tail_x15_r0_body.kappa147 PRE_first_tail_x15_r0_body.s1303 PRE_first_tail_x15_r0_body.s1302 PRE_first_tail_x15_r0_body.zl147 := PRE_first_tail_x15_r0_body.zimgE147
-- the roots and their supports
kernel_rfl PRE_first_tail_x15_r0_body.zctl147 : PRE_first_tail_x15_r0_body.s1302.ctl = PRE_first_tail_x15_r0_body.kappa147.ctl PRE_first_tail_x15_r0_body.s1303.ctl
kernel_rfl PRE_first_tail_x15_r0_body.zstack147 : PRE_first_tail_x15_r0_body.s1302.stack = PRE_first_tail_x15_r0_body.s1303.stack.map PRE_first_tail_x15_r0_body.kappa147.frame
kernel_rfl PRE_first_tail_x15_r0_body.zjobs147 : PRE_first_tail_x15_r0_body.s1302.jobs = PRE_first_tail_x15_r0_body.s1303.jobs.map PRE_first_tail_x15_r0_body.kappa147.job
kernel_rfl PRE_first_tail_x15_r0_body.zstores147 : PRE_first_tail_x15_r0_body.s1302.stores = PRE_first_tail_x15_r0_body.kappa147.stores PRE_first_tail_x15_r0_body.s1303.stores
kernel_rfl PRE_first_tail_x15_r0_body.zroots147 : checkRootsSupp PRE_first_tail_x15_r0_body.s1303 6386 = true
kernel_rfl PRE_first_tail_x15_r0_body.znC147 : PRE_first_tail_x15_r0_body.S1301.tab.length + PRE_first_tail_x15_r0_body.cws147.length = 6386
-- the map as `Conv.compact_shift` states it (the call's counters for the literals)
kernel_rfl PRE_first_tail_x15_r0_body.zkap147 : PRE_first_tail_x15_r0_body.kappa147 = Conv.Map.compact PRE_first_tail_x15_r0_body.s1301.next 2791874 PRE_first_tail_x15_r0_body.S1301.tab.length PRE_first_tail_x15_r0_body.pl147 (PRE_first_tail_x15_r0_body.nr147.map NumV.ref) PRE_first_tail_x15_r0_body.kd147.big
  PRE_first_tail_x15_r0_body.kd147.region PRE_first_tail_x15_r0_body.kd147.nodeF
-- the bridge inactive at the canonical state (`Conv.FullShiftQ.toX`; the merged state's bridge is the canonical's: cbridge)
theorem PRE_first_tail_x15_r0_body.zbin147 : (Host.Ts.Sim.Full.bridgeOf PRE_first_tail_x15_r0_body.s1303.ffi).active = false := (Host.Load.Boot.replay_active Host.Load.Run.Prompt.P.oblog2818)
-- the JS bookkeeping's step (`Conv.JClean.step` over the changed list) and the canonical roots' bigint freedom
kernel_rfl PRE_first_tail_x15_r0_body.zjc147 : Conv.jcleanListB (⟨21108, 18212, 2790725, 6386⟩ : Conv.Cnt) PRE_first_tail_x15_r0_body.s1303 PRE_first_tail_x15_r0_body.cl147 = true
kernel_rfl PRE_first_tail_x15_r0_body.zroots2147 : noBigRootsP (fun i => !Conv.oldBigB (⟨21108, 18212, 2790725, 6386⟩ : Conv.Cnt) i) PRE_first_tail_x15_r0_body.s1303.trace PRE_first_tail_x15_r0_body.s1303 = true
kernel_rfl PRE_first_tail_x15_r0_body.zhm147 : Nat.ble (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s0.ffi).mlx.nnext 18185 = true
theorem PRE_first_tail_x15_r0_body.cjcl147 (h : Conv.JClean (⟨21105, 18185, 2790719, 6368⟩ : Conv.Cnt) PRE_first_tail_x15_r0_body.s1301) : Conv.JClean (⟨21108, 18212, 2790725, 6386⟩ : Conv.Cnt) PRE_first_tail_x15_r0_body.s1303 :=
  Conv.JClean.step h (Conv.Cnt.le_of_leB PRE_first_tail_x15_r0_body.cle147)
    (Conv.heap_off_setAll PRE_first_tail_x15_r0_body.cheap147 fun a ha => Nat.blt_eq.mp (List.all_eq_true.mp PRE_first_tail_x15_r0_body.zclbd147 a ha)) PRE_first_tail_x15_r0_body.zjc147

end Host.Load.Run.Tpl
