import host.sim.template.a4pre_first_tail_x15_r0_body.SiteS166
import host.sim.template.a4pre_first_tail_x15_r0_body.SiteK166
import host.sim.template.a4pre_first_tail_x15_r0_body.SiteF166
import host.sim.conv.CompactShift
import host.sim.template.Check
import host.sim.BigFreeP
import host.sim.template.CallGen
set_option Elab.async false
namespace Host.Load.Run.Tpl
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
open Host.Ts Host.Ts.Sim Host.Ts.Sim.Template

/-! The compaction's state shift at call site 166 of chain `PRE_first_tail_x15_r0_body` (`Conv.compact_shift`): the call `PRE_first_tail_x15_r0_body.s1605`, the merged
state `PRE_first_tail_x15_r0_body.s1606`, the canonical state `PRE_first_tail_x15_r0_body.s1607`; its frames [2665,2673467,2673472,2673473] (kept arrays [2665,2673467]). -/

-- the map's places and counters
kernel_rfl PRE_first_tail_x15_r0_body.zpl166 : PRE_first_tail_x15_r0_body.pl166.all (Nat.ble PRE_first_tail_x15_r0_body.s1605.next) = true
kernel_rfl PRE_first_tail_x15_r0_body.zplnd166 : nodupT PRE_first_tail_x15_r0_body.pl166 PTrie.nil = true
kernel_rfl PRE_first_tail_x15_r0_body.zn1166 : Nat.ble PRE_first_tail_x15_r0_body.s1605.next 2805515 = true
kernel_rfl PRE_first_tail_x15_r0_body.zfirst166 : Nat.ble aFirst PRE_first_tail_x15_r0_body.s1605.next = true
kernel_rfl PRE_first_tail_x15_r0_body.zscn166 : PRE_first_tail_x15_r0_body.s1607.next = PRE_first_tail_x15_r0_body.s1605.next + PRE_first_tail_x15_r0_body.pl166.length
kernel_rfl PRE_first_tail_x15_r0_body.zsmn166 : PRE_first_tail_x15_r0_body.s1606.next = 2805515
kernel_rfl PRE_first_tail_x15_r0_body.zgrow166 : Nat.ble PRE_first_tail_x15_r0_body.s1607.next PRE_first_tail_x15_r0_body.s1606.next = true
-- the tables
kernel_rfl PRE_first_tail_x15_r0_body.zfresh166 : PRE_first_tail_x15_r0_body.S1605.tab.all (fun e => PRE_first_tail_x15_r0_body.cws166.all fun v => e.noVar v) = true
kernel_rfl PRE_first_tail_x15_r0_body.zcnd166 : nodupT PRE_first_tail_x15_r0_body.cws166 PTrie.nil = true
kernel_rfl PRE_first_tail_x15_r0_body.znrHi166 : PRE_first_tail_x15_r0_body.nr166.all (fun r => Nat.blt r PRE_first_tail_x15_r0_body.S1606.tab.length) = true
-- the frames: every framed address below the call's counter; the kept arrays the chain start's, extended in the merged state
kernel_rfl PRE_first_tail_x15_r0_body.zfrlt166 : [2665, 2673467, 2673472, 2673473].all (fun a => Nat.blt a PRE_first_tail_x15_r0_body.s1605.next) = true
kernel_rfl PRE_first_tail_x15_r0_body.zg166_2665 : PRE_first_tail_x15_r0_body.s1607.heap.get 2665 = some (.obj (objOf PRE_first_tail_x15_r0_body.s1607 2665))
kernel_rfl PRE_first_tail_x15_r0_body.zk166_2665 : (objOf PRE_first_tail_x15_r0_body.s1607 2665).kind = .array (arrOf PRE_first_tail_x15_r0_body.s0 2665)
kernel_rfl PRE_first_tail_x15_r0_body.zm166_2665 : PRE_first_tail_x15_r0_body.s1606.heap.get 2665 = some (.obj { PRE_first_tail_x15_r0_body.kappa166.obj (objOf PRE_first_tail_x15_r0_body.s1607 2665) with
  kind := .array (arrOf PRE_first_tail_x15_r0_body.s0 2665 ++ (arrOf PRE_first_tail_x15_r0_body.s1606 2665).drop (arrOf PRE_first_tail_x15_r0_body.s0 2665).length) })
kernel_rfl PRE_first_tail_x15_r0_body.zg166_2673467 : PRE_first_tail_x15_r0_body.s1607.heap.get 2673467 = some (.obj (objOf PRE_first_tail_x15_r0_body.s1607 2673467))
kernel_rfl PRE_first_tail_x15_r0_body.zk166_2673467 : (objOf PRE_first_tail_x15_r0_body.s1607 2673467).kind = .array (arrOf PRE_first_tail_x15_r0_body.s0 2673467)
kernel_rfl PRE_first_tail_x15_r0_body.zm166_2673467 : PRE_first_tail_x15_r0_body.s1606.heap.get 2673467 = some (.obj { PRE_first_tail_x15_r0_body.kappa166.obj (objOf PRE_first_tail_x15_r0_body.s1607 2673467) with
  kind := .array (arrOf PRE_first_tail_x15_r0_body.s0 2673467 ++ (arrOf PRE_first_tail_x15_r0_body.s1606 2673467).drop (arrOf PRE_first_tail_x15_r0_body.s0 2673467).length) })
kernel_rfl PRE_first_tail_x15_r0_body.zw166_4910 : (PRE_first_tail_x15_r0_body.s1607.heap.get 4910).isSome = true
kernel_rfl PRE_first_tail_x15_r0_body.zw166_2673472 : (PRE_first_tail_x15_r0_body.s1607.heap.get 2673472).isSome = true
kernel_rfl PRE_first_tail_x15_r0_body.zw166_2673473 : (PRE_first_tail_x15_r0_body.s1607.heap.get 2673473).isSome = true
-- the heap: the changed list in range, holding the stage's written and fresh addresses; the canonical side's image
kernel_rfl PRE_first_tail_x15_r0_body.zclbd166 : PRE_first_tail_x15_r0_body.cl166.all (fun b => Nat.blt (b / 4096) (4 ^ 31)) = true
kernel_rfl PRE_first_tail_x15_r0_body.zwr166 : PRE_first_tail_x15_r0_body.st166.wr.all (fun b => !Nat.blt b PRE_first_tail_x15_r0_body.s1605.next || PRE_first_tail_x15_r0_body.cl166.contains b) = true
def PRE_first_tail_x15_r0_body.zl166 : List Nat := PRE_first_tail_x15_r0_body.cl166.filter fun a => !(List.contains [2665, 2673467] a)
kernel_rfl PRE_first_tail_x15_r0_body.zimgE166 : PRE_first_tail_x15_r0_body.zl166.map (fun a => PRE_first_tail_x15_r0_body.s1606.heap.get (PRE_first_tail_x15_r0_body.kappa166.a a)) = PRE_first_tail_x15_r0_body.zl166.map (fun a => (PRE_first_tail_x15_r0_body.s1607.heap.get a).map PRE_first_tail_x15_r0_body.kappa166.hobj)
theorem PRE_first_tail_x15_r0_body.zimg166 : HeapImg PRE_first_tail_x15_r0_body.kappa166 PRE_first_tail_x15_r0_body.s1607 PRE_first_tail_x15_r0_body.s1606 PRE_first_tail_x15_r0_body.zl166 := PRE_first_tail_x15_r0_body.zimgE166
-- the roots and their supports
kernel_rfl PRE_first_tail_x15_r0_body.zctl166 : PRE_first_tail_x15_r0_body.s1606.ctl = PRE_first_tail_x15_r0_body.kappa166.ctl PRE_first_tail_x15_r0_body.s1607.ctl
kernel_rfl PRE_first_tail_x15_r0_body.zstack166 : PRE_first_tail_x15_r0_body.s1606.stack = PRE_first_tail_x15_r0_body.s1607.stack.map PRE_first_tail_x15_r0_body.kappa166.frame
kernel_rfl PRE_first_tail_x15_r0_body.zjobs166 : PRE_first_tail_x15_r0_body.s1606.jobs = PRE_first_tail_x15_r0_body.s1607.jobs.map PRE_first_tail_x15_r0_body.kappa166.job
kernel_rfl PRE_first_tail_x15_r0_body.zstores166 : PRE_first_tail_x15_r0_body.s1606.stores = PRE_first_tail_x15_r0_body.kappa166.stores PRE_first_tail_x15_r0_body.s1607.stores
kernel_rfl PRE_first_tail_x15_r0_body.zroots166 : checkRootsSupp PRE_first_tail_x15_r0_body.s1607 7175 = true
kernel_rfl PRE_first_tail_x15_r0_body.znC166 : PRE_first_tail_x15_r0_body.S1605.tab.length + PRE_first_tail_x15_r0_body.cws166.length = 7175
-- the map as `Conv.compact_shift` states it (the call's counters for the literals)
kernel_rfl PRE_first_tail_x15_r0_body.zkap166 : PRE_first_tail_x15_r0_body.kappa166 = Conv.Map.compact PRE_first_tail_x15_r0_body.s1605.next 2805515 PRE_first_tail_x15_r0_body.S1605.tab.length PRE_first_tail_x15_r0_body.pl166 (PRE_first_tail_x15_r0_body.nr166.map NumV.ref) PRE_first_tail_x15_r0_body.kd166.big
  PRE_first_tail_x15_r0_body.kd166.region PRE_first_tail_x15_r0_body.kd166.nodeF
-- the bridge inactive at the canonical state (`Conv.FullShiftQ.toX`; the merged state's bridge is the canonical's: cbridge)
theorem PRE_first_tail_x15_r0_body.zbin166 : (Host.Ts.Sim.Full.bridgeOf PRE_first_tail_x15_r0_body.s1607.ffi).active = false := (Host.Load.Boot.replay_active Host.Load.Run.Prompt.P.oblog2818)
-- the JS bookkeeping's step (`Conv.JClean.step` over the changed list) and the canonical roots' bigint freedom
kernel_rfl PRE_first_tail_x15_r0_body.zjc166 : Conv.jcleanListB (⟨21478, 18573, 2805513, 7175⟩ : Conv.Cnt) PRE_first_tail_x15_r0_body.s1607 PRE_first_tail_x15_r0_body.cl166 = true
kernel_rfl PRE_first_tail_x15_r0_body.zrootsB166 : noBigRootsP (fun i => !Conv.oldBigB (⟨21478, 18573, 2805513, 7175⟩ : Conv.Cnt) i) PRE_first_tail_x15_r0_body.s1607.trace PRE_first_tail_x15_r0_body.s1607 = true
kernel_rfl PRE_first_tail_x15_r0_body.zhm166 : Nat.ble (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s0.ffi).mlx.nnext 18573 = true
theorem PRE_first_tail_x15_r0_body.cjcl166 (h : Conv.JClean (⟨21478, 18573, 2805513, 7175⟩ : Conv.Cnt) PRE_first_tail_x15_r0_body.s1605) : Conv.JClean (⟨21478, 18573, 2805513, 7175⟩ : Conv.Cnt) PRE_first_tail_x15_r0_body.s1607 :=
  Conv.JClean.step h (Conv.Cnt.le_of_leB PRE_first_tail_x15_r0_body.cle166)
    (Conv.heap_off_setAll PRE_first_tail_x15_r0_body.cheap166 fun a ha => Nat.blt_eq.mp (List.all_eq_true.mp PRE_first_tail_x15_r0_body.zclbd166 a ha)) PRE_first_tail_x15_r0_body.zjc166

end Host.Load.Run.Tpl
