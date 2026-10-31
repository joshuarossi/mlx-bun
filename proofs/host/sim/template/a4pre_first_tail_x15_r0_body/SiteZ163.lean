import host.sim.template.a4pre_first_tail_x15_r0_body.SiteS163
import host.sim.template.a4pre_first_tail_x15_r0_body.SiteK163
import host.sim.template.a4pre_first_tail_x15_r0_body.SiteF163
import host.sim.conv.CompactShift
import host.sim.template.Check
import host.sim.BigFreeP
import host.sim.template.CallGen
set_option Elab.async false
namespace Host.Load.Run.Tpl
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
open Host.Ts Host.Ts.Sim Host.Ts.Sim.Template

/-! The compaction's state shift at call site 163 of chain `PRE_first_tail_x15_r0_body` (`Conv.compact_shift`): the call `PRE_first_tail_x15_r0_body.s1577`, the merged
state `PRE_first_tail_x15_r0_body.s1578`, the canonical state `PRE_first_tail_x15_r0_body.s1579`; its frames [2665,2673467,2673472,2673473] (kept arrays [2665,2673467]). -/

-- the map's places and counters
kernel_rfl PRE_first_tail_x15_r0_body.zpl163 : PRE_first_tail_x15_r0_body.pl163.all (Nat.ble PRE_first_tail_x15_r0_body.s1577.next) = true
kernel_rfl PRE_first_tail_x15_r0_body.zplnd163 : nodupT PRE_first_tail_x15_r0_body.pl163 PTrie.nil = true
kernel_rfl PRE_first_tail_x15_r0_body.zn1163 : Nat.ble PRE_first_tail_x15_r0_body.s1577.next 2802889 = true
kernel_rfl PRE_first_tail_x15_r0_body.zfirst163 : Nat.ble aFirst PRE_first_tail_x15_r0_body.s1577.next = true
kernel_rfl PRE_first_tail_x15_r0_body.zscn163 : PRE_first_tail_x15_r0_body.s1579.next = PRE_first_tail_x15_r0_body.s1577.next + PRE_first_tail_x15_r0_body.pl163.length
kernel_rfl PRE_first_tail_x15_r0_body.zsmn163 : PRE_first_tail_x15_r0_body.s1578.next = 2802889
kernel_rfl PRE_first_tail_x15_r0_body.zgrow163 : Nat.ble PRE_first_tail_x15_r0_body.s1579.next PRE_first_tail_x15_r0_body.s1578.next = true
-- the tables
kernel_rfl PRE_first_tail_x15_r0_body.zfresh163 : PRE_first_tail_x15_r0_body.S1577.tab.all (fun e => PRE_first_tail_x15_r0_body.cws163.all fun v => e.noVar v) = true
kernel_rfl PRE_first_tail_x15_r0_body.zcnd163 : nodupT PRE_first_tail_x15_r0_body.cws163 PTrie.nil = true
kernel_rfl PRE_first_tail_x15_r0_body.znrHi163 : PRE_first_tail_x15_r0_body.nr163.all (fun r => Nat.blt r PRE_first_tail_x15_r0_body.S1578.tab.length) = true
-- the frames: every framed address below the call's counter; the kept arrays the chain start's, extended in the merged state
kernel_rfl PRE_first_tail_x15_r0_body.zfrlt163 : [2665, 2673467, 2673472, 2673473].all (fun a => Nat.blt a PRE_first_tail_x15_r0_body.s1577.next) = true
kernel_rfl PRE_first_tail_x15_r0_body.zg163_2665 : PRE_first_tail_x15_r0_body.s1579.heap.get 2665 = some (.obj (objOf PRE_first_tail_x15_r0_body.s1579 2665))
kernel_rfl PRE_first_tail_x15_r0_body.zk163_2665 : (objOf PRE_first_tail_x15_r0_body.s1579 2665).kind = .array (arrOf PRE_first_tail_x15_r0_body.s0 2665)
kernel_rfl PRE_first_tail_x15_r0_body.zm163_2665 : PRE_first_tail_x15_r0_body.s1578.heap.get 2665 = some (.obj { PRE_first_tail_x15_r0_body.kappa163.obj (objOf PRE_first_tail_x15_r0_body.s1579 2665) with
  kind := .array (arrOf PRE_first_tail_x15_r0_body.s0 2665 ++ (arrOf PRE_first_tail_x15_r0_body.s1578 2665).drop (arrOf PRE_first_tail_x15_r0_body.s0 2665).length) })
kernel_rfl PRE_first_tail_x15_r0_body.zg163_2673467 : PRE_first_tail_x15_r0_body.s1579.heap.get 2673467 = some (.obj (objOf PRE_first_tail_x15_r0_body.s1579 2673467))
kernel_rfl PRE_first_tail_x15_r0_body.zk163_2673467 : (objOf PRE_first_tail_x15_r0_body.s1579 2673467).kind = .array (arrOf PRE_first_tail_x15_r0_body.s0 2673467)
kernel_rfl PRE_first_tail_x15_r0_body.zm163_2673467 : PRE_first_tail_x15_r0_body.s1578.heap.get 2673467 = some (.obj { PRE_first_tail_x15_r0_body.kappa163.obj (objOf PRE_first_tail_x15_r0_body.s1579 2673467) with
  kind := .array (arrOf PRE_first_tail_x15_r0_body.s0 2673467 ++ (arrOf PRE_first_tail_x15_r0_body.s1578 2673467).drop (arrOf PRE_first_tail_x15_r0_body.s0 2673467).length) })
kernel_rfl PRE_first_tail_x15_r0_body.zw163_4910 : (PRE_first_tail_x15_r0_body.s1579.heap.get 4910).isSome = true
kernel_rfl PRE_first_tail_x15_r0_body.zw163_2673472 : (PRE_first_tail_x15_r0_body.s1579.heap.get 2673472).isSome = true
kernel_rfl PRE_first_tail_x15_r0_body.zw163_2673473 : (PRE_first_tail_x15_r0_body.s1579.heap.get 2673473).isSome = true
-- the heap: the changed list in range, holding the stage's written and fresh addresses; the canonical side's image
kernel_rfl PRE_first_tail_x15_r0_body.zclbd163 : PRE_first_tail_x15_r0_body.cl163.all (fun b => Nat.blt (b / 4096) (4 ^ 31)) = true
kernel_rfl PRE_first_tail_x15_r0_body.zwr163 : PRE_first_tail_x15_r0_body.st163.wr.all (fun b => !Nat.blt b PRE_first_tail_x15_r0_body.s1577.next || PRE_first_tail_x15_r0_body.cl163.contains b) = true
def PRE_first_tail_x15_r0_body.zl163 : List Nat := PRE_first_tail_x15_r0_body.cl163.filter fun a => !(List.contains [2665, 2673467] a)
kernel_rfl PRE_first_tail_x15_r0_body.zimgE163 : PRE_first_tail_x15_r0_body.zl163.map (fun a => PRE_first_tail_x15_r0_body.s1578.heap.get (PRE_first_tail_x15_r0_body.kappa163.a a)) = PRE_first_tail_x15_r0_body.zl163.map (fun a => (PRE_first_tail_x15_r0_body.s1579.heap.get a).map PRE_first_tail_x15_r0_body.kappa163.hobj)
theorem PRE_first_tail_x15_r0_body.zimg163 : HeapImg PRE_first_tail_x15_r0_body.kappa163 PRE_first_tail_x15_r0_body.s1579 PRE_first_tail_x15_r0_body.s1578 PRE_first_tail_x15_r0_body.zl163 := PRE_first_tail_x15_r0_body.zimgE163
-- the roots and their supports
kernel_rfl PRE_first_tail_x15_r0_body.zctl163 : PRE_first_tail_x15_r0_body.s1578.ctl = PRE_first_tail_x15_r0_body.kappa163.ctl PRE_first_tail_x15_r0_body.s1579.ctl
kernel_rfl PRE_first_tail_x15_r0_body.zstack163 : PRE_first_tail_x15_r0_body.s1578.stack = PRE_first_tail_x15_r0_body.s1579.stack.map PRE_first_tail_x15_r0_body.kappa163.frame
kernel_rfl PRE_first_tail_x15_r0_body.zjobs163 : PRE_first_tail_x15_r0_body.s1578.jobs = PRE_first_tail_x15_r0_body.s1579.jobs.map PRE_first_tail_x15_r0_body.kappa163.job
kernel_rfl PRE_first_tail_x15_r0_body.zstores163 : PRE_first_tail_x15_r0_body.s1578.stores = PRE_first_tail_x15_r0_body.kappa163.stores PRE_first_tail_x15_r0_body.s1579.stores
kernel_rfl PRE_first_tail_x15_r0_body.zroots163 : checkRootsSupp PRE_first_tail_x15_r0_body.s1579 7049 = true
kernel_rfl PRE_first_tail_x15_r0_body.znC163 : PRE_first_tail_x15_r0_body.S1577.tab.length + PRE_first_tail_x15_r0_body.cws163.length = 7049
-- the map as `Conv.compact_shift` states it (the call's counters for the literals)
kernel_rfl PRE_first_tail_x15_r0_body.zkap163 : PRE_first_tail_x15_r0_body.kappa163 = Conv.Map.compact PRE_first_tail_x15_r0_body.s1577.next 2802889 PRE_first_tail_x15_r0_body.S1577.tab.length PRE_first_tail_x15_r0_body.pl163 (PRE_first_tail_x15_r0_body.nr163.map NumV.ref) PRE_first_tail_x15_r0_body.kd163.big
  PRE_first_tail_x15_r0_body.kd163.region PRE_first_tail_x15_r0_body.kd163.nodeF
-- the bridge inactive at the canonical state (`Conv.FullShiftQ.toX`; the merged state's bridge is the canonical's: cbridge)
theorem PRE_first_tail_x15_r0_body.zbin163 : (Host.Ts.Sim.Full.bridgeOf PRE_first_tail_x15_r0_body.s1579.ffi).active = false := (Host.Load.Boot.replay_active Host.Load.Run.Prompt.P.oblog2818)
-- the JS bookkeeping's step (`Conv.JClean.step` over the changed list) and the canonical roots' bigint freedom
kernel_rfl PRE_first_tail_x15_r0_body.zjc163 : Conv.jcleanListB (⟨21414, 18525, 2802887, 7049⟩ : Conv.Cnt) PRE_first_tail_x15_r0_body.s1579 PRE_first_tail_x15_r0_body.cl163 = true
kernel_rfl PRE_first_tail_x15_r0_body.zrootsB163 : noBigRootsP (fun i => !Conv.oldBigB (⟨21414, 18525, 2802887, 7049⟩ : Conv.Cnt) i) PRE_first_tail_x15_r0_body.s1579.trace PRE_first_tail_x15_r0_body.s1579 = true
kernel_rfl PRE_first_tail_x15_r0_body.zhm163 : Nat.ble (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s0.ffi).mlx.nnext 18525 = true
theorem PRE_first_tail_x15_r0_body.cjcl163 (h : Conv.JClean (⟨21414, 18525, 2802887, 7049⟩ : Conv.Cnt) PRE_first_tail_x15_r0_body.s1577) : Conv.JClean (⟨21414, 18525, 2802887, 7049⟩ : Conv.Cnt) PRE_first_tail_x15_r0_body.s1579 :=
  Conv.JClean.step h (Conv.Cnt.le_of_leB PRE_first_tail_x15_r0_body.cle163)
    (Conv.heap_off_setAll PRE_first_tail_x15_r0_body.cheap163 fun a ha => Nat.blt_eq.mp (List.all_eq_true.mp PRE_first_tail_x15_r0_body.zclbd163 a ha)) PRE_first_tail_x15_r0_body.zjc163

end Host.Load.Run.Tpl
