import host.sim.template.a4pre_first_tail_x15_r0_body.SiteS171
import host.sim.template.a4pre_first_tail_x15_r0_body.SiteK171
import host.sim.template.a4pre_first_tail_x15_r0_body.SiteF171
import host.sim.conv.CompactShift
import host.sim.template.Check
import host.sim.BigFreeP
import host.sim.template.CallGen
set_option Elab.async false
namespace Host.Load.Run.Tpl
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
open Host.Ts Host.Ts.Sim Host.Ts.Sim.Template

/-! The compaction's state shift at call site 171 of chain `PRE_first_tail_x15_r0_body` (`Conv.compact_shift`): the call `PRE_first_tail_x15_r0_body.s1655`, the merged
state `PRE_first_tail_x15_r0_body.s1656`, the canonical state `PRE_first_tail_x15_r0_body.s1657`; its frames [2665,2673467,2673472,2673473] (kept arrays [2665,2673467]). -/

-- the map's places and counters
kernel_rfl PRE_first_tail_x15_r0_body.zpl171 : PRE_first_tail_x15_r0_body.pl171.all (Nat.ble PRE_first_tail_x15_r0_body.s1655.next) = true
kernel_rfl PRE_first_tail_x15_r0_body.zplnd171 : nodupT PRE_first_tail_x15_r0_body.pl171 PTrie.nil = true
kernel_rfl PRE_first_tail_x15_r0_body.zn1171 : Nat.ble PRE_first_tail_x15_r0_body.s1655.next 2810714 = true
kernel_rfl PRE_first_tail_x15_r0_body.zfirst171 : Nat.ble aFirst PRE_first_tail_x15_r0_body.s1655.next = true
kernel_rfl PRE_first_tail_x15_r0_body.zscn171 : PRE_first_tail_x15_r0_body.s1657.next = PRE_first_tail_x15_r0_body.s1655.next + PRE_first_tail_x15_r0_body.pl171.length
kernel_rfl PRE_first_tail_x15_r0_body.zsmn171 : PRE_first_tail_x15_r0_body.s1656.next = 2810714
kernel_rfl PRE_first_tail_x15_r0_body.zgrow171 : Nat.ble PRE_first_tail_x15_r0_body.s1657.next PRE_first_tail_x15_r0_body.s1656.next = true
-- the tables
kernel_rfl PRE_first_tail_x15_r0_body.zfresh171 : PRE_first_tail_x15_r0_body.S1655.tab.all (fun e => PRE_first_tail_x15_r0_body.cws171.all fun v => e.noVar v) = true
kernel_rfl PRE_first_tail_x15_r0_body.zcnd171 : nodupT PRE_first_tail_x15_r0_body.cws171 PTrie.nil = true
kernel_rfl PRE_first_tail_x15_r0_body.znrHi171 : PRE_first_tail_x15_r0_body.nr171.all (fun r => Nat.blt r PRE_first_tail_x15_r0_body.S1656.tab.length) = true
-- the frames: every framed address below the call's counter; the kept arrays the chain start's, extended in the merged state
kernel_rfl PRE_first_tail_x15_r0_body.zfrlt171 : [2665, 2673467, 2673472, 2673473].all (fun a => Nat.blt a PRE_first_tail_x15_r0_body.s1655.next) = true
kernel_rfl PRE_first_tail_x15_r0_body.zg171_2665 : PRE_first_tail_x15_r0_body.s1657.heap.get 2665 = some (.obj (objOf PRE_first_tail_x15_r0_body.s1657 2665))
kernel_rfl PRE_first_tail_x15_r0_body.zk171_2665 : (objOf PRE_first_tail_x15_r0_body.s1657 2665).kind = .array (arrOf PRE_first_tail_x15_r0_body.s0 2665)
kernel_rfl PRE_first_tail_x15_r0_body.zm171_2665 : PRE_first_tail_x15_r0_body.s1656.heap.get 2665 = some (.obj { PRE_first_tail_x15_r0_body.kappa171.obj (objOf PRE_first_tail_x15_r0_body.s1657 2665) with
  kind := .array (arrOf PRE_first_tail_x15_r0_body.s0 2665 ++ (arrOf PRE_first_tail_x15_r0_body.s1656 2665).drop (arrOf PRE_first_tail_x15_r0_body.s0 2665).length) })
kernel_rfl PRE_first_tail_x15_r0_body.zg171_2673467 : PRE_first_tail_x15_r0_body.s1657.heap.get 2673467 = some (.obj (objOf PRE_first_tail_x15_r0_body.s1657 2673467))
kernel_rfl PRE_first_tail_x15_r0_body.zk171_2673467 : (objOf PRE_first_tail_x15_r0_body.s1657 2673467).kind = .array (arrOf PRE_first_tail_x15_r0_body.s0 2673467)
kernel_rfl PRE_first_tail_x15_r0_body.zm171_2673467 : PRE_first_tail_x15_r0_body.s1656.heap.get 2673467 = some (.obj { PRE_first_tail_x15_r0_body.kappa171.obj (objOf PRE_first_tail_x15_r0_body.s1657 2673467) with
  kind := .array (arrOf PRE_first_tail_x15_r0_body.s0 2673467 ++ (arrOf PRE_first_tail_x15_r0_body.s1656 2673467).drop (arrOf PRE_first_tail_x15_r0_body.s0 2673467).length) })
kernel_rfl PRE_first_tail_x15_r0_body.zw171_4910 : (PRE_first_tail_x15_r0_body.s1657.heap.get 4910).isSome = true
kernel_rfl PRE_first_tail_x15_r0_body.zw171_2673472 : (PRE_first_tail_x15_r0_body.s1657.heap.get 2673472).isSome = true
kernel_rfl PRE_first_tail_x15_r0_body.zw171_2673473 : (PRE_first_tail_x15_r0_body.s1657.heap.get 2673473).isSome = true
-- the heap: the changed list in range, holding the stage's written and fresh addresses; the canonical side's image
kernel_rfl PRE_first_tail_x15_r0_body.zclbd171 : PRE_first_tail_x15_r0_body.cl171.all (fun b => Nat.blt (b / 4096) (4 ^ 31)) = true
kernel_rfl PRE_first_tail_x15_r0_body.zwr171 : PRE_first_tail_x15_r0_body.st171.wr.all (fun b => !Nat.blt b PRE_first_tail_x15_r0_body.s1655.next || PRE_first_tail_x15_r0_body.cl171.contains b) = true
def PRE_first_tail_x15_r0_body.zl171 : List Nat := PRE_first_tail_x15_r0_body.cl171.filter fun a => !(List.contains [2665, 2673467] a)
kernel_rfl PRE_first_tail_x15_r0_body.zimgE171 : PRE_first_tail_x15_r0_body.zl171.map (fun a => PRE_first_tail_x15_r0_body.s1656.heap.get (PRE_first_tail_x15_r0_body.kappa171.a a)) = PRE_first_tail_x15_r0_body.zl171.map (fun a => (PRE_first_tail_x15_r0_body.s1657.heap.get a).map PRE_first_tail_x15_r0_body.kappa171.hobj)
theorem PRE_first_tail_x15_r0_body.zimg171 : HeapImg PRE_first_tail_x15_r0_body.kappa171 PRE_first_tail_x15_r0_body.s1657 PRE_first_tail_x15_r0_body.s1656 PRE_first_tail_x15_r0_body.zl171 := PRE_first_tail_x15_r0_body.zimgE171
-- the roots and their supports
kernel_rfl PRE_first_tail_x15_r0_body.zctl171 : PRE_first_tail_x15_r0_body.s1656.ctl = PRE_first_tail_x15_r0_body.kappa171.ctl PRE_first_tail_x15_r0_body.s1657.ctl
kernel_rfl PRE_first_tail_x15_r0_body.zstack171 : PRE_first_tail_x15_r0_body.s1656.stack = PRE_first_tail_x15_r0_body.s1657.stack.map PRE_first_tail_x15_r0_body.kappa171.frame
kernel_rfl PRE_first_tail_x15_r0_body.zjobs171 : PRE_first_tail_x15_r0_body.s1656.jobs = PRE_first_tail_x15_r0_body.s1657.jobs.map PRE_first_tail_x15_r0_body.kappa171.job
kernel_rfl PRE_first_tail_x15_r0_body.zstores171 : PRE_first_tail_x15_r0_body.s1656.stores = PRE_first_tail_x15_r0_body.kappa171.stores PRE_first_tail_x15_r0_body.s1657.stores
kernel_rfl PRE_first_tail_x15_r0_body.zroots171 : checkRootsSupp PRE_first_tail_x15_r0_body.s1657 7412 = true
kernel_rfl PRE_first_tail_x15_r0_body.znC171 : PRE_first_tail_x15_r0_body.S1655.tab.length + PRE_first_tail_x15_r0_body.cws171.length = 7412
-- the map as `Conv.compact_shift` states it (the call's counters for the literals)
kernel_rfl PRE_first_tail_x15_r0_body.zkap171 : PRE_first_tail_x15_r0_body.kappa171 = Conv.Map.compact PRE_first_tail_x15_r0_body.s1655.next 2810714 PRE_first_tail_x15_r0_body.S1655.tab.length PRE_first_tail_x15_r0_body.pl171 (PRE_first_tail_x15_r0_body.nr171.map NumV.ref) PRE_first_tail_x15_r0_body.kd171.big
  PRE_first_tail_x15_r0_body.kd171.region PRE_first_tail_x15_r0_body.kd171.nodeF
-- the bridge inactive at the canonical state (`Conv.FullShiftQ.toX`; the merged state's bridge is the canonical's: cbridge)
theorem PRE_first_tail_x15_r0_body.zbin171 : (Host.Ts.Sim.Full.bridgeOf PRE_first_tail_x15_r0_body.s1657.ffi).active = false := (Host.Load.Boot.replay_active Host.Load.Run.Prompt.P.oblog2818)
-- the JS bookkeeping's step (`Conv.JClean.step` over the changed list) and the canonical roots' bigint freedom
kernel_rfl PRE_first_tail_x15_r0_body.zjc171 : Conv.jcleanListB (⟨21580, 18686, 2809565, 7412⟩ : Conv.Cnt) PRE_first_tail_x15_r0_body.s1657 PRE_first_tail_x15_r0_body.cl171 = true
kernel_rfl PRE_first_tail_x15_r0_body.zrootsB171 : noBigRootsP (fun i => !Conv.oldBigB (⟨21580, 18686, 2809565, 7412⟩ : Conv.Cnt) i) PRE_first_tail_x15_r0_body.s1657.trace PRE_first_tail_x15_r0_body.s1657 = true
kernel_rfl PRE_first_tail_x15_r0_body.zhm171 : Nat.ble (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s0.ffi).mlx.nnext 18659 = true
theorem PRE_first_tail_x15_r0_body.cjcl171 (h : Conv.JClean (⟨21577, 18659, 2809559, 7394⟩ : Conv.Cnt) PRE_first_tail_x15_r0_body.s1655) : Conv.JClean (⟨21580, 18686, 2809565, 7412⟩ : Conv.Cnt) PRE_first_tail_x15_r0_body.s1657 :=
  Conv.JClean.step h (Conv.Cnt.le_of_leB PRE_first_tail_x15_r0_body.cle171)
    (Conv.heap_off_setAll PRE_first_tail_x15_r0_body.cheap171 fun a ha => Nat.blt_eq.mp (List.all_eq_true.mp PRE_first_tail_x15_r0_body.zclbd171 a ha)) PRE_first_tail_x15_r0_body.zjc171

end Host.Load.Run.Tpl
