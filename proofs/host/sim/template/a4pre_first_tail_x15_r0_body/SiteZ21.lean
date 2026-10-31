import host.sim.template.a4pre_first_tail_x15_r0_body.SiteS21
import host.sim.template.a4pre_first_tail_x15_r0_body.SiteK21
import host.sim.template.a4pre_first_tail_x15_r0_body.SiteF21
import host.sim.conv.CompactShift
import host.sim.template.Check
import host.sim.BigFreeP
import host.sim.template.CallGen
set_option Elab.async false
namespace Host.Load.Run.Tpl
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
open Host.Ts Host.Ts.Sim Host.Ts.Sim.Template

/-! The compaction's state shift at call site 21 of chain `PRE_first_tail_x15_r0_body` (`Conv.compact_shift`): the call `PRE_first_tail_x15_r0_body.s217`, the merged
state `PRE_first_tail_x15_r0_body.s218`, the canonical state `PRE_first_tail_x15_r0_body.s219`; its frames [2665,2673467,2673472,2673473] (kept arrays [2665,2673467]). -/

-- the map's places and counters
kernel_rfl PRE_first_tail_x15_r0_body.zpl21 : PRE_first_tail_x15_r0_body.pl21.all (Nat.ble PRE_first_tail_x15_r0_body.s217.next) = true
kernel_rfl PRE_first_tail_x15_r0_body.zplnd21 : nodupT PRE_first_tail_x15_r0_body.pl21 PTrie.nil = true
kernel_rfl PRE_first_tail_x15_r0_body.zn121 : Nat.ble PRE_first_tail_x15_r0_body.s217.next 2692273 = true
kernel_rfl PRE_first_tail_x15_r0_body.zfirst21 : Nat.ble aFirst PRE_first_tail_x15_r0_body.s217.next = true
kernel_rfl PRE_first_tail_x15_r0_body.zscn21 : PRE_first_tail_x15_r0_body.s219.next = PRE_first_tail_x15_r0_body.s217.next + PRE_first_tail_x15_r0_body.pl21.length
kernel_rfl PRE_first_tail_x15_r0_body.zsmn21 : PRE_first_tail_x15_r0_body.s218.next = 2692273
kernel_rfl PRE_first_tail_x15_r0_body.zgrow21 : Nat.ble PRE_first_tail_x15_r0_body.s219.next PRE_first_tail_x15_r0_body.s218.next = true
-- the tables
kernel_rfl PRE_first_tail_x15_r0_body.zfresh21 : PRE_first_tail_x15_r0_body.S217.tab.all (fun e => PRE_first_tail_x15_r0_body.cws21.all fun v => e.noVar v) = true
kernel_rfl PRE_first_tail_x15_r0_body.zcnd21 : nodupT PRE_first_tail_x15_r0_body.cws21 PTrie.nil = true
kernel_rfl PRE_first_tail_x15_r0_body.znrHi21 : PRE_first_tail_x15_r0_body.nr21.all (fun r => Nat.blt r PRE_first_tail_x15_r0_body.S218.tab.length) = true
-- the frames: every framed address below the call's counter; the kept arrays the chain start's, extended in the merged state
kernel_rfl PRE_first_tail_x15_r0_body.zfrlt21 : [2665, 2673467, 2673472, 2673473].all (fun a => Nat.blt a PRE_first_tail_x15_r0_body.s217.next) = true
kernel_rfl PRE_first_tail_x15_r0_body.zg21_2665 : PRE_first_tail_x15_r0_body.s219.heap.get 2665 = some (.obj (objOf PRE_first_tail_x15_r0_body.s219 2665))
kernel_rfl PRE_first_tail_x15_r0_body.zk21_2665 : (objOf PRE_first_tail_x15_r0_body.s219 2665).kind = .array (arrOf PRE_first_tail_x15_r0_body.s0 2665)
kernel_rfl PRE_first_tail_x15_r0_body.zm21_2665 : PRE_first_tail_x15_r0_body.s218.heap.get 2665 = some (.obj { PRE_first_tail_x15_r0_body.kappa21.obj (objOf PRE_first_tail_x15_r0_body.s219 2665) with
  kind := .array (arrOf PRE_first_tail_x15_r0_body.s0 2665 ++ (arrOf PRE_first_tail_x15_r0_body.s218 2665).drop (arrOf PRE_first_tail_x15_r0_body.s0 2665).length) })
kernel_rfl PRE_first_tail_x15_r0_body.zg21_2673467 : PRE_first_tail_x15_r0_body.s219.heap.get 2673467 = some (.obj (objOf PRE_first_tail_x15_r0_body.s219 2673467))
kernel_rfl PRE_first_tail_x15_r0_body.zk21_2673467 : (objOf PRE_first_tail_x15_r0_body.s219 2673467).kind = .array (arrOf PRE_first_tail_x15_r0_body.s0 2673467)
kernel_rfl PRE_first_tail_x15_r0_body.zm21_2673467 : PRE_first_tail_x15_r0_body.s218.heap.get 2673467 = some (.obj { PRE_first_tail_x15_r0_body.kappa21.obj (objOf PRE_first_tail_x15_r0_body.s219 2673467) with
  kind := .array (arrOf PRE_first_tail_x15_r0_body.s0 2673467 ++ (arrOf PRE_first_tail_x15_r0_body.s218 2673467).drop (arrOf PRE_first_tail_x15_r0_body.s0 2673467).length) })
kernel_rfl PRE_first_tail_x15_r0_body.zw21_4910 : (PRE_first_tail_x15_r0_body.s219.heap.get 4910).isSome = true
kernel_rfl PRE_first_tail_x15_r0_body.zw21_2673472 : (PRE_first_tail_x15_r0_body.s219.heap.get 2673472).isSome = true
kernel_rfl PRE_first_tail_x15_r0_body.zw21_2673473 : (PRE_first_tail_x15_r0_body.s219.heap.get 2673473).isSome = true
-- the heap: the changed list in range, holding the stage's written and fresh addresses; the canonical side's image
kernel_rfl PRE_first_tail_x15_r0_body.zclbd21 : PRE_first_tail_x15_r0_body.cl21.all (fun b => Nat.blt (b / 4096) (4 ^ 31)) = true
kernel_rfl PRE_first_tail_x15_r0_body.zwr21 : PRE_first_tail_x15_r0_body.st21.wr.all (fun b => !Nat.blt b PRE_first_tail_x15_r0_body.s217.next || PRE_first_tail_x15_r0_body.cl21.contains b) = true
def PRE_first_tail_x15_r0_body.zl21 : List Nat := PRE_first_tail_x15_r0_body.cl21.filter fun a => !(List.contains [2665, 2673467] a)
kernel_rfl PRE_first_tail_x15_r0_body.zimgE21 : PRE_first_tail_x15_r0_body.zl21.map (fun a => PRE_first_tail_x15_r0_body.s218.heap.get (PRE_first_tail_x15_r0_body.kappa21.a a)) = PRE_first_tail_x15_r0_body.zl21.map (fun a => (PRE_first_tail_x15_r0_body.s219.heap.get a).map PRE_first_tail_x15_r0_body.kappa21.hobj)
theorem PRE_first_tail_x15_r0_body.zimg21 : HeapImg PRE_first_tail_x15_r0_body.kappa21 PRE_first_tail_x15_r0_body.s219 PRE_first_tail_x15_r0_body.s218 PRE_first_tail_x15_r0_body.zl21 := PRE_first_tail_x15_r0_body.zimgE21
-- the roots and their supports
kernel_rfl PRE_first_tail_x15_r0_body.zctl21 : PRE_first_tail_x15_r0_body.s218.ctl = PRE_first_tail_x15_r0_body.kappa21.ctl PRE_first_tail_x15_r0_body.s219.ctl
kernel_rfl PRE_first_tail_x15_r0_body.zstack21 : PRE_first_tail_x15_r0_body.s218.stack = PRE_first_tail_x15_r0_body.s219.stack.map PRE_first_tail_x15_r0_body.kappa21.frame
kernel_rfl PRE_first_tail_x15_r0_body.zjobs21 : PRE_first_tail_x15_r0_body.s218.jobs = PRE_first_tail_x15_r0_body.s219.jobs.map PRE_first_tail_x15_r0_body.kappa21.job
kernel_rfl PRE_first_tail_x15_r0_body.zstores21 : PRE_first_tail_x15_r0_body.s218.stores = PRE_first_tail_x15_r0_body.kappa21.stores PRE_first_tail_x15_r0_body.s219.stores
kernel_rfl PRE_first_tail_x15_r0_body.zroots21 : checkRootsSupp PRE_first_tail_x15_r0_body.s219 996 = true
kernel_rfl PRE_first_tail_x15_r0_body.znC21 : PRE_first_tail_x15_r0_body.S217.tab.length + PRE_first_tail_x15_r0_body.cws21.length = 996
-- the map as `Conv.compact_shift` states it (the call's counters for the literals)
kernel_rfl PRE_first_tail_x15_r0_body.zkap21 : PRE_first_tail_x15_r0_body.kappa21 = Conv.Map.compact PRE_first_tail_x15_r0_body.s217.next 2692273 PRE_first_tail_x15_r0_body.S217.tab.length PRE_first_tail_x15_r0_body.pl21 (PRE_first_tail_x15_r0_body.nr21.map NumV.ref) PRE_first_tail_x15_r0_body.kd21.big
  PRE_first_tail_x15_r0_body.kd21.region PRE_first_tail_x15_r0_body.kd21.nodeF
-- the bridge inactive at the canonical state (`Conv.FullShiftQ.toX`; the merged state's bridge is the canonical's: cbridge)
theorem PRE_first_tail_x15_r0_body.zbin21 : (Host.Ts.Sim.Full.bridgeOf PRE_first_tail_x15_r0_body.s219.ffi).active = false := (Host.Load.Boot.replay_active Host.Load.Run.Prompt.P.oblog2818)
-- the JS bookkeeping's step (`Conv.JClean.step` over the changed list) and the canonical roots' bigint freedom
kernel_rfl PRE_first_tail_x15_r0_body.zjc21 : Conv.jcleanListB (⟨18633, 15719, 2691923, 996⟩ : Conv.Cnt) PRE_first_tail_x15_r0_body.s219 PRE_first_tail_x15_r0_body.cl21 = true
kernel_rfl PRE_first_tail_x15_r0_body.zrootsB21 : noBigRootsP (fun i => !Conv.oldBigB (⟨18633, 15719, 2691923, 996⟩ : Conv.Cnt) i) PRE_first_tail_x15_r0_body.s219.trace PRE_first_tail_x15_r0_body.s219 = true
kernel_rfl PRE_first_tail_x15_r0_body.zhm21 : Nat.ble (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s0.ffi).mlx.nnext 15713 = true
theorem PRE_first_tail_x15_r0_body.cjcl21 (h : Conv.JClean (⟨18629, 15713, 2691908, 987⟩ : Conv.Cnt) PRE_first_tail_x15_r0_body.s217) : Conv.JClean (⟨18633, 15719, 2691923, 996⟩ : Conv.Cnt) PRE_first_tail_x15_r0_body.s219 :=
  Conv.JClean.step h (Conv.Cnt.le_of_leB PRE_first_tail_x15_r0_body.cle21)
    (Conv.heap_off_setAll PRE_first_tail_x15_r0_body.cheap21 fun a ha => Nat.blt_eq.mp (List.all_eq_true.mp PRE_first_tail_x15_r0_body.zclbd21 a ha)) PRE_first_tail_x15_r0_body.zjc21

end Host.Load.Run.Tpl
