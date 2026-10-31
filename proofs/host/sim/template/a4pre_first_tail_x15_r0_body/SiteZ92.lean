import host.sim.template.a4pre_first_tail_x15_r0_body.SiteS92
import host.sim.template.a4pre_first_tail_x15_r0_body.SiteK92
import host.sim.template.a4pre_first_tail_x15_r0_body.SiteF92
import host.sim.conv.CompactShift
import host.sim.template.Check
import host.sim.BigFreeP
import host.sim.template.CallGen
set_option Elab.async false
namespace Host.Load.Run.Tpl
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
open Host.Ts Host.Ts.Sim Host.Ts.Sim.Template

/-! The compaction's state shift at call site 92 of chain `PRE_first_tail_x15_r0_body` (`Conv.compact_shift`): the call `PRE_first_tail_x15_r0_body.s814`, the merged
state `PRE_first_tail_x15_r0_body.s815`, the canonical state `PRE_first_tail_x15_r0_body.s816`; its frames [2665,2673467,2673472,2673473] (kept arrays [2665,2673467]). -/

-- the map's places and counters
kernel_rfl PRE_first_tail_x15_r0_body.zpl92 : PRE_first_tail_x15_r0_body.pl92.all (Nat.ble PRE_first_tail_x15_r0_body.s814.next) = true
kernel_rfl PRE_first_tail_x15_r0_body.zplnd92 : nodupT PRE_first_tail_x15_r0_body.pl92 PTrie.nil = true
kernel_rfl PRE_first_tail_x15_r0_body.zn192 : Nat.ble PRE_first_tail_x15_r0_body.s814.next 2746682 = true
kernel_rfl PRE_first_tail_x15_r0_body.zfirst92 : Nat.ble aFirst PRE_first_tail_x15_r0_body.s814.next = true
kernel_rfl PRE_first_tail_x15_r0_body.zscn92 : PRE_first_tail_x15_r0_body.s816.next = PRE_first_tail_x15_r0_body.s814.next + PRE_first_tail_x15_r0_body.pl92.length
kernel_rfl PRE_first_tail_x15_r0_body.zsmn92 : PRE_first_tail_x15_r0_body.s815.next = 2746682
kernel_rfl PRE_first_tail_x15_r0_body.zgrow92 : Nat.ble PRE_first_tail_x15_r0_body.s816.next PRE_first_tail_x15_r0_body.s815.next = true
-- the tables
kernel_rfl PRE_first_tail_x15_r0_body.zfresh92 : PRE_first_tail_x15_r0_body.S814.tab.all (fun e => PRE_first_tail_x15_r0_body.cws92.all fun v => e.noVar v) = true
kernel_rfl PRE_first_tail_x15_r0_body.zcnd92 : nodupT PRE_first_tail_x15_r0_body.cws92 PTrie.nil = true
kernel_rfl PRE_first_tail_x15_r0_body.znrHi92 : PRE_first_tail_x15_r0_body.nr92.all (fun r => Nat.blt r PRE_first_tail_x15_r0_body.S815.tab.length) = true
-- the frames: every framed address below the call's counter; the kept arrays the chain start's, extended in the merged state
kernel_rfl PRE_first_tail_x15_r0_body.zfrlt92 : [2665, 2673467, 2673472, 2673473].all (fun a => Nat.blt a PRE_first_tail_x15_r0_body.s814.next) = true
kernel_rfl PRE_first_tail_x15_r0_body.zg92_2665 : PRE_first_tail_x15_r0_body.s816.heap.get 2665 = some (.obj (objOf PRE_first_tail_x15_r0_body.s816 2665))
kernel_rfl PRE_first_tail_x15_r0_body.zk92_2665 : (objOf PRE_first_tail_x15_r0_body.s816 2665).kind = .array (arrOf PRE_first_tail_x15_r0_body.s0 2665)
kernel_rfl PRE_first_tail_x15_r0_body.zm92_2665 : PRE_first_tail_x15_r0_body.s815.heap.get 2665 = some (.obj { PRE_first_tail_x15_r0_body.kappa92.obj (objOf PRE_first_tail_x15_r0_body.s816 2665) with
  kind := .array (arrOf PRE_first_tail_x15_r0_body.s0 2665 ++ (arrOf PRE_first_tail_x15_r0_body.s815 2665).drop (arrOf PRE_first_tail_x15_r0_body.s0 2665).length) })
kernel_rfl PRE_first_tail_x15_r0_body.zg92_2673467 : PRE_first_tail_x15_r0_body.s816.heap.get 2673467 = some (.obj (objOf PRE_first_tail_x15_r0_body.s816 2673467))
kernel_rfl PRE_first_tail_x15_r0_body.zk92_2673467 : (objOf PRE_first_tail_x15_r0_body.s816 2673467).kind = .array (arrOf PRE_first_tail_x15_r0_body.s0 2673467)
kernel_rfl PRE_first_tail_x15_r0_body.zm92_2673467 : PRE_first_tail_x15_r0_body.s815.heap.get 2673467 = some (.obj { PRE_first_tail_x15_r0_body.kappa92.obj (objOf PRE_first_tail_x15_r0_body.s816 2673467) with
  kind := .array (arrOf PRE_first_tail_x15_r0_body.s0 2673467 ++ (arrOf PRE_first_tail_x15_r0_body.s815 2673467).drop (arrOf PRE_first_tail_x15_r0_body.s0 2673467).length) })
kernel_rfl PRE_first_tail_x15_r0_body.zw92_4910 : (PRE_first_tail_x15_r0_body.s816.heap.get 4910).isSome = true
kernel_rfl PRE_first_tail_x15_r0_body.zw92_2673472 : (PRE_first_tail_x15_r0_body.s816.heap.get 2673472).isSome = true
kernel_rfl PRE_first_tail_x15_r0_body.zw92_2673473 : (PRE_first_tail_x15_r0_body.s816.heap.get 2673473).isSome = true
-- the heap: the changed list in range, holding the stage's written and fresh addresses; the canonical side's image
kernel_rfl PRE_first_tail_x15_r0_body.zclbd92 : PRE_first_tail_x15_r0_body.cl92.all (fun b => Nat.blt (b / 4096) (4 ^ 31)) = true
kernel_rfl PRE_first_tail_x15_r0_body.zwr92 : PRE_first_tail_x15_r0_body.st92.wr.all (fun b => !Nat.blt b PRE_first_tail_x15_r0_body.s814.next || PRE_first_tail_x15_r0_body.cl92.contains b) = true
def PRE_first_tail_x15_r0_body.zl92 : List Nat := PRE_first_tail_x15_r0_body.cl92.filter fun a => !(List.contains [2665, 2673467] a)
kernel_rfl PRE_first_tail_x15_r0_body.zimgE92 : PRE_first_tail_x15_r0_body.zl92.map (fun a => PRE_first_tail_x15_r0_body.s815.heap.get (PRE_first_tail_x15_r0_body.kappa92.a a)) = PRE_first_tail_x15_r0_body.zl92.map (fun a => (PRE_first_tail_x15_r0_body.s816.heap.get a).map PRE_first_tail_x15_r0_body.kappa92.hobj)
theorem PRE_first_tail_x15_r0_body.zimg92 : HeapImg PRE_first_tail_x15_r0_body.kappa92 PRE_first_tail_x15_r0_body.s816 PRE_first_tail_x15_r0_body.s815 PRE_first_tail_x15_r0_body.zl92 := PRE_first_tail_x15_r0_body.zimgE92
-- the roots and their supports
kernel_rfl PRE_first_tail_x15_r0_body.zctl92 : PRE_first_tail_x15_r0_body.s815.ctl = PRE_first_tail_x15_r0_body.kappa92.ctl PRE_first_tail_x15_r0_body.s816.ctl
kernel_rfl PRE_first_tail_x15_r0_body.zstack92 : PRE_first_tail_x15_r0_body.s815.stack = PRE_first_tail_x15_r0_body.s816.stack.map PRE_first_tail_x15_r0_body.kappa92.frame
kernel_rfl PRE_first_tail_x15_r0_body.zjobs92 : PRE_first_tail_x15_r0_body.s815.jobs = PRE_first_tail_x15_r0_body.s816.jobs.map PRE_first_tail_x15_r0_body.kappa92.job
kernel_rfl PRE_first_tail_x15_r0_body.zstores92 : PRE_first_tail_x15_r0_body.s815.stores = PRE_first_tail_x15_r0_body.kappa92.stores PRE_first_tail_x15_r0_body.s816.stores
kernel_rfl PRE_first_tail_x15_r0_body.zroots92 : checkRootsSupp PRE_first_tail_x15_r0_body.s816 3988 = true
kernel_rfl PRE_first_tail_x15_r0_body.znC92 : PRE_first_tail_x15_r0_body.S814.tab.length + PRE_first_tail_x15_r0_body.cws92.length = 3988
-- the map as `Conv.compact_shift` states it (the call's counters for the literals)
kernel_rfl PRE_first_tail_x15_r0_body.zkap92 : PRE_first_tail_x15_r0_body.kappa92 = Conv.Map.compact PRE_first_tail_x15_r0_body.s814.next 2746682 PRE_first_tail_x15_r0_body.S814.tab.length PRE_first_tail_x15_r0_body.pl92 (PRE_first_tail_x15_r0_body.nr92.map NumV.ref) PRE_first_tail_x15_r0_body.kd92.big
  PRE_first_tail_x15_r0_body.kd92.region PRE_first_tail_x15_r0_body.kd92.nodeF
-- the bridge inactive at the canonical state (`Conv.FullShiftQ.toX`; the merged state's bridge is the canonical's: cbridge)
theorem PRE_first_tail_x15_r0_body.zbin92 : (Host.Ts.Sim.Full.bridgeOf PRE_first_tail_x15_r0_body.s816.ffi).active = false := (Host.Load.Boot.replay_active Host.Load.Run.Prompt.P.oblog2818)
-- the JS bookkeeping's step (`Conv.JClean.step` over the changed list) and the canonical roots' bigint freedom
kernel_rfl PRE_first_tail_x15_r0_body.zjc92 : Conv.jcleanListB (⟨20005, 17107, 2746672, 3988⟩ : Conv.Cnt) PRE_first_tail_x15_r0_body.s816 PRE_first_tail_x15_r0_body.cl92 = true
kernel_rfl PRE_first_tail_x15_r0_body.zroots292 : noBigRootsP (fun i => !Conv.oldBigB (⟨20005, 17107, 2746672, 3988⟩ : Conv.Cnt) i) PRE_first_tail_x15_r0_body.s816.trace PRE_first_tail_x15_r0_body.s816 = true
kernel_rfl PRE_first_tail_x15_r0_body.zhm92 : Nat.ble (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s0.ffi).mlx.nnext 17107 = true
theorem PRE_first_tail_x15_r0_body.cjcl92 (h : Conv.JClean (⟨20005, 17107, 2746671, 3988⟩ : Conv.Cnt) PRE_first_tail_x15_r0_body.s814) : Conv.JClean (⟨20005, 17107, 2746672, 3988⟩ : Conv.Cnt) PRE_first_tail_x15_r0_body.s816 :=
  Conv.JClean.step h (Conv.Cnt.le_of_leB PRE_first_tail_x15_r0_body.cle92)
    (Conv.heap_off_setAll PRE_first_tail_x15_r0_body.cheap92 fun a ha => Nat.blt_eq.mp (List.all_eq_true.mp PRE_first_tail_x15_r0_body.zclbd92 a ha)) PRE_first_tail_x15_r0_body.zjc92

end Host.Load.Run.Tpl
