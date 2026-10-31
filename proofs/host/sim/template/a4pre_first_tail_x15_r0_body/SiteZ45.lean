import host.sim.template.a4pre_first_tail_x15_r0_body.SiteS45
import host.sim.template.a4pre_first_tail_x15_r0_body.SiteK45
import host.sim.template.a4pre_first_tail_x15_r0_body.SiteF45
import host.sim.conv.CompactShift
import host.sim.template.Check
import host.sim.BigFreeP
import host.sim.template.CallGen
set_option Elab.async false
namespace Host.Load.Run.Tpl
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
open Host.Ts Host.Ts.Sim Host.Ts.Sim.Template

/-! The compaction's state shift at call site 45 of chain `PRE_first_tail_x15_r0_body` (`Conv.compact_shift`): the call `PRE_first_tail_x15_r0_body.s447`, the merged
state `PRE_first_tail_x15_r0_body.s448`, the canonical state `PRE_first_tail_x15_r0_body.s449`; its frames [2665,2673467,2673472,2673473] (kept arrays [2665,2673467]). -/

-- the map's places and counters
kernel_rfl PRE_first_tail_x15_r0_body.zpl45 : PRE_first_tail_x15_r0_body.pl45.all (Nat.ble PRE_first_tail_x15_r0_body.s447.next) = true
kernel_rfl PRE_first_tail_x15_r0_body.zplnd45 : nodupT PRE_first_tail_x15_r0_body.pl45 PTrie.nil = true
kernel_rfl PRE_first_tail_x15_r0_body.zn145 : Nat.ble PRE_first_tail_x15_r0_body.s447.next 2711105 = true
kernel_rfl PRE_first_tail_x15_r0_body.zfirst45 : Nat.ble aFirst PRE_first_tail_x15_r0_body.s447.next = true
kernel_rfl PRE_first_tail_x15_r0_body.zscn45 : PRE_first_tail_x15_r0_body.s449.next = PRE_first_tail_x15_r0_body.s447.next + PRE_first_tail_x15_r0_body.pl45.length
kernel_rfl PRE_first_tail_x15_r0_body.zsmn45 : PRE_first_tail_x15_r0_body.s448.next = 2711105
kernel_rfl PRE_first_tail_x15_r0_body.zgrow45 : Nat.ble PRE_first_tail_x15_r0_body.s449.next PRE_first_tail_x15_r0_body.s448.next = true
-- the tables
kernel_rfl PRE_first_tail_x15_r0_body.zfresh45 : PRE_first_tail_x15_r0_body.S447.tab.all (fun e => PRE_first_tail_x15_r0_body.cws45.all fun v => e.noVar v) = true
kernel_rfl PRE_first_tail_x15_r0_body.zcnd45 : nodupT PRE_first_tail_x15_r0_body.cws45 PTrie.nil = true
kernel_rfl PRE_first_tail_x15_r0_body.znrHi45 : PRE_first_tail_x15_r0_body.nr45.all (fun r => Nat.blt r PRE_first_tail_x15_r0_body.S448.tab.length) = true
-- the frames: every framed address below the call's counter; the kept arrays the chain start's, extended in the merged state
kernel_rfl PRE_first_tail_x15_r0_body.zfrlt45 : [2665, 2673467, 2673472, 2673473].all (fun a => Nat.blt a PRE_first_tail_x15_r0_body.s447.next) = true
kernel_rfl PRE_first_tail_x15_r0_body.zg45_2665 : PRE_first_tail_x15_r0_body.s449.heap.get 2665 = some (.obj (objOf PRE_first_tail_x15_r0_body.s449 2665))
kernel_rfl PRE_first_tail_x15_r0_body.zk45_2665 : (objOf PRE_first_tail_x15_r0_body.s449 2665).kind = .array (arrOf PRE_first_tail_x15_r0_body.s0 2665)
kernel_rfl PRE_first_tail_x15_r0_body.zm45_2665 : PRE_first_tail_x15_r0_body.s448.heap.get 2665 = some (.obj { PRE_first_tail_x15_r0_body.kappa45.obj (objOf PRE_first_tail_x15_r0_body.s449 2665) with
  kind := .array (arrOf PRE_first_tail_x15_r0_body.s0 2665 ++ (arrOf PRE_first_tail_x15_r0_body.s448 2665).drop (arrOf PRE_first_tail_x15_r0_body.s0 2665).length) })
kernel_rfl PRE_first_tail_x15_r0_body.zg45_2673467 : PRE_first_tail_x15_r0_body.s449.heap.get 2673467 = some (.obj (objOf PRE_first_tail_x15_r0_body.s449 2673467))
kernel_rfl PRE_first_tail_x15_r0_body.zk45_2673467 : (objOf PRE_first_tail_x15_r0_body.s449 2673467).kind = .array (arrOf PRE_first_tail_x15_r0_body.s0 2673467)
kernel_rfl PRE_first_tail_x15_r0_body.zm45_2673467 : PRE_first_tail_x15_r0_body.s448.heap.get 2673467 = some (.obj { PRE_first_tail_x15_r0_body.kappa45.obj (objOf PRE_first_tail_x15_r0_body.s449 2673467) with
  kind := .array (arrOf PRE_first_tail_x15_r0_body.s0 2673467 ++ (arrOf PRE_first_tail_x15_r0_body.s448 2673467).drop (arrOf PRE_first_tail_x15_r0_body.s0 2673467).length) })
kernel_rfl PRE_first_tail_x15_r0_body.zw45_4910 : (PRE_first_tail_x15_r0_body.s449.heap.get 4910).isSome = true
kernel_rfl PRE_first_tail_x15_r0_body.zw45_2673472 : (PRE_first_tail_x15_r0_body.s449.heap.get 2673472).isSome = true
kernel_rfl PRE_first_tail_x15_r0_body.zw45_2673473 : (PRE_first_tail_x15_r0_body.s449.heap.get 2673473).isSome = true
-- the heap: the changed list in range, holding the stage's written and fresh addresses; the canonical side's image
kernel_rfl PRE_first_tail_x15_r0_body.zclbd45 : PRE_first_tail_x15_r0_body.cl45.all (fun b => Nat.blt (b / 4096) (4 ^ 31)) = true
kernel_rfl PRE_first_tail_x15_r0_body.zwr45 : PRE_first_tail_x15_r0_body.st45.wr.all (fun b => !Nat.blt b PRE_first_tail_x15_r0_body.s447.next || PRE_first_tail_x15_r0_body.cl45.contains b) = true
def PRE_first_tail_x15_r0_body.zl45 : List Nat := PRE_first_tail_x15_r0_body.cl45.filter fun a => !(List.contains [2665, 2673467] a)
kernel_rfl PRE_first_tail_x15_r0_body.zimgE45 : PRE_first_tail_x15_r0_body.zl45.map (fun a => PRE_first_tail_x15_r0_body.s448.heap.get (PRE_first_tail_x15_r0_body.kappa45.a a)) = PRE_first_tail_x15_r0_body.zl45.map (fun a => (PRE_first_tail_x15_r0_body.s449.heap.get a).map PRE_first_tail_x15_r0_body.kappa45.hobj)
theorem PRE_first_tail_x15_r0_body.zimg45 : HeapImg PRE_first_tail_x15_r0_body.kappa45 PRE_first_tail_x15_r0_body.s449 PRE_first_tail_x15_r0_body.s448 PRE_first_tail_x15_r0_body.zl45 := PRE_first_tail_x15_r0_body.zimgE45
-- the roots and their supports
kernel_rfl PRE_first_tail_x15_r0_body.zctl45 : PRE_first_tail_x15_r0_body.s448.ctl = PRE_first_tail_x15_r0_body.kappa45.ctl PRE_first_tail_x15_r0_body.s449.ctl
kernel_rfl PRE_first_tail_x15_r0_body.zstack45 : PRE_first_tail_x15_r0_body.s448.stack = PRE_first_tail_x15_r0_body.s449.stack.map PRE_first_tail_x15_r0_body.kappa45.frame
kernel_rfl PRE_first_tail_x15_r0_body.zjobs45 : PRE_first_tail_x15_r0_body.s448.jobs = PRE_first_tail_x15_r0_body.s449.jobs.map PRE_first_tail_x15_r0_body.kappa45.job
kernel_rfl PRE_first_tail_x15_r0_body.zstores45 : PRE_first_tail_x15_r0_body.s448.stores = PRE_first_tail_x15_r0_body.kappa45.stores PRE_first_tail_x15_r0_body.s449.stores
kernel_rfl PRE_first_tail_x15_r0_body.zroots45 : checkRootsSupp PRE_first_tail_x15_r0_body.s449 2022 = true
kernel_rfl PRE_first_tail_x15_r0_body.znC45 : PRE_first_tail_x15_r0_body.S447.tab.length + PRE_first_tail_x15_r0_body.cws45.length = 2022
-- the map as `Conv.compact_shift` states it (the call's counters for the literals)
kernel_rfl PRE_first_tail_x15_r0_body.zkap45 : PRE_first_tail_x15_r0_body.kappa45 = Conv.Map.compact PRE_first_tail_x15_r0_body.s447.next 2711105 PRE_first_tail_x15_r0_body.S447.tab.length PRE_first_tail_x15_r0_body.pl45 (PRE_first_tail_x15_r0_body.nr45.map NumV.ref) PRE_first_tail_x15_r0_body.kd45.big
  PRE_first_tail_x15_r0_body.kd45.region PRE_first_tail_x15_r0_body.kd45.nodeF
-- the bridge inactive at the canonical state (`Conv.FullShiftQ.toX`; the merged state's bridge is the canonical's: cbridge)
theorem PRE_first_tail_x15_r0_body.zbin45 : (Host.Ts.Sim.Full.bridgeOf PRE_first_tail_x15_r0_body.s449.ffi).active = false := (Host.Load.Boot.replay_active Host.Load.Run.Prompt.P.oblog2818)
-- the JS bookkeeping's step (`Conv.JClean.step` over the changed list) and the canonical roots' bigint freedom
kernel_rfl PRE_first_tail_x15_r0_body.zjc45 : Conv.jcleanListB (⟨19105, 16193, 2710755, 2022⟩ : Conv.Cnt) PRE_first_tail_x15_r0_body.s449 PRE_first_tail_x15_r0_body.cl45 = true
kernel_rfl PRE_first_tail_x15_r0_body.zrootsB45 : noBigRootsP (fun i => !Conv.oldBigB (⟨19105, 16193, 2710755, 2022⟩ : Conv.Cnt) i) PRE_first_tail_x15_r0_body.s449.trace PRE_first_tail_x15_r0_body.s449 = true
kernel_rfl PRE_first_tail_x15_r0_body.zhm45 : Nat.ble (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s0.ffi).mlx.nnext 16187 = true
theorem PRE_first_tail_x15_r0_body.cjcl45 (h : Conv.JClean (⟨19101, 16187, 2710740, 2013⟩ : Conv.Cnt) PRE_first_tail_x15_r0_body.s447) : Conv.JClean (⟨19105, 16193, 2710755, 2022⟩ : Conv.Cnt) PRE_first_tail_x15_r0_body.s449 :=
  Conv.JClean.step h (Conv.Cnt.le_of_leB PRE_first_tail_x15_r0_body.cle45)
    (Conv.heap_off_setAll PRE_first_tail_x15_r0_body.cheap45 fun a ha => Nat.blt_eq.mp (List.all_eq_true.mp PRE_first_tail_x15_r0_body.zclbd45 a ha)) PRE_first_tail_x15_r0_body.zjc45

end Host.Load.Run.Tpl
