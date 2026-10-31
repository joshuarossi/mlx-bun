import host.sim.template.a4pre_first_tail_x15_r0_body.SiteS47
import host.sim.template.a4pre_first_tail_x15_r0_body.SiteK47
import host.sim.template.a4pre_first_tail_x15_r0_body.SiteF47
import host.sim.conv.CompactShift
import host.sim.template.Check
import host.sim.BigFreeP
import host.sim.template.CallGen
set_option Elab.async false
namespace Host.Load.Run.Tpl
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
open Host.Ts Host.Ts.Sim Host.Ts.Sim.Template

/-! The compaction's state shift at call site 47 of chain `PRE_first_tail_x15_r0_body` (`Conv.compact_shift`): the call `PRE_first_tail_x15_r0_body.s459`, the merged
state `PRE_first_tail_x15_r0_body.s460`, the canonical state `PRE_first_tail_x15_r0_body.s461`; its frames [2665,2673467,2673472,2673473] (kept arrays [2665,2673467]). -/

-- the map's places and counters
kernel_rfl PRE_first_tail_x15_r0_body.zpl47 : PRE_first_tail_x15_r0_body.pl47.all (Nat.ble PRE_first_tail_x15_r0_body.s459.next) = true
kernel_rfl PRE_first_tail_x15_r0_body.zplnd47 : nodupT PRE_first_tail_x15_r0_body.pl47 PTrie.nil = true
kernel_rfl PRE_first_tail_x15_r0_body.zn147 : Nat.ble PRE_first_tail_x15_r0_body.s459.next 2711645 = true
kernel_rfl PRE_first_tail_x15_r0_body.zfirst47 : Nat.ble aFirst PRE_first_tail_x15_r0_body.s459.next = true
kernel_rfl PRE_first_tail_x15_r0_body.zscn47 : PRE_first_tail_x15_r0_body.s461.next = PRE_first_tail_x15_r0_body.s459.next + PRE_first_tail_x15_r0_body.pl47.length
kernel_rfl PRE_first_tail_x15_r0_body.zsmn47 : PRE_first_tail_x15_r0_body.s460.next = 2711645
kernel_rfl PRE_first_tail_x15_r0_body.zgrow47 : Nat.ble PRE_first_tail_x15_r0_body.s461.next PRE_first_tail_x15_r0_body.s460.next = true
-- the tables
kernel_rfl PRE_first_tail_x15_r0_body.zfresh47 : PRE_first_tail_x15_r0_body.S459.tab.all (fun e => PRE_first_tail_x15_r0_body.cws47.all fun v => e.noVar v) = true
kernel_rfl PRE_first_tail_x15_r0_body.zcnd47 : nodupT PRE_first_tail_x15_r0_body.cws47 PTrie.nil = true
kernel_rfl PRE_first_tail_x15_r0_body.znrHi47 : PRE_first_tail_x15_r0_body.nr47.all (fun r => Nat.blt r PRE_first_tail_x15_r0_body.S460.tab.length) = true
-- the frames: every framed address below the call's counter; the kept arrays the chain start's, extended in the merged state
kernel_rfl PRE_first_tail_x15_r0_body.zfrlt47 : [2665, 2673467, 2673472, 2673473].all (fun a => Nat.blt a PRE_first_tail_x15_r0_body.s459.next) = true
kernel_rfl PRE_first_tail_x15_r0_body.zg47_2665 : PRE_first_tail_x15_r0_body.s461.heap.get 2665 = some (.obj (objOf PRE_first_tail_x15_r0_body.s461 2665))
kernel_rfl PRE_first_tail_x15_r0_body.zk47_2665 : (objOf PRE_first_tail_x15_r0_body.s461 2665).kind = .array (arrOf PRE_first_tail_x15_r0_body.s0 2665)
kernel_rfl PRE_first_tail_x15_r0_body.zm47_2665 : PRE_first_tail_x15_r0_body.s460.heap.get 2665 = some (.obj { PRE_first_tail_x15_r0_body.kappa47.obj (objOf PRE_first_tail_x15_r0_body.s461 2665) with
  kind := .array (arrOf PRE_first_tail_x15_r0_body.s0 2665 ++ (arrOf PRE_first_tail_x15_r0_body.s460 2665).drop (arrOf PRE_first_tail_x15_r0_body.s0 2665).length) })
kernel_rfl PRE_first_tail_x15_r0_body.zg47_2673467 : PRE_first_tail_x15_r0_body.s461.heap.get 2673467 = some (.obj (objOf PRE_first_tail_x15_r0_body.s461 2673467))
kernel_rfl PRE_first_tail_x15_r0_body.zk47_2673467 : (objOf PRE_first_tail_x15_r0_body.s461 2673467).kind = .array (arrOf PRE_first_tail_x15_r0_body.s0 2673467)
kernel_rfl PRE_first_tail_x15_r0_body.zm47_2673467 : PRE_first_tail_x15_r0_body.s460.heap.get 2673467 = some (.obj { PRE_first_tail_x15_r0_body.kappa47.obj (objOf PRE_first_tail_x15_r0_body.s461 2673467) with
  kind := .array (arrOf PRE_first_tail_x15_r0_body.s0 2673467 ++ (arrOf PRE_first_tail_x15_r0_body.s460 2673467).drop (arrOf PRE_first_tail_x15_r0_body.s0 2673467).length) })
kernel_rfl PRE_first_tail_x15_r0_body.zw47_4910 : (PRE_first_tail_x15_r0_body.s461.heap.get 4910).isSome = true
kernel_rfl PRE_first_tail_x15_r0_body.zw47_2673472 : (PRE_first_tail_x15_r0_body.s461.heap.get 2673472).isSome = true
kernel_rfl PRE_first_tail_x15_r0_body.zw47_2673473 : (PRE_first_tail_x15_r0_body.s461.heap.get 2673473).isSome = true
-- the heap: the changed list in range, holding the stage's written and fresh addresses; the canonical side's image
kernel_rfl PRE_first_tail_x15_r0_body.zclbd47 : PRE_first_tail_x15_r0_body.cl47.all (fun b => Nat.blt (b / 4096) (4 ^ 31)) = true
kernel_rfl PRE_first_tail_x15_r0_body.zwr47 : PRE_first_tail_x15_r0_body.st47.wr.all (fun b => !Nat.blt b PRE_first_tail_x15_r0_body.s459.next || PRE_first_tail_x15_r0_body.cl47.contains b) = true
def PRE_first_tail_x15_r0_body.zl47 : List Nat := PRE_first_tail_x15_r0_body.cl47.filter fun a => !(List.contains [2665, 2673467] a)
kernel_rfl PRE_first_tail_x15_r0_body.zimgE47 : PRE_first_tail_x15_r0_body.zl47.map (fun a => PRE_first_tail_x15_r0_body.s460.heap.get (PRE_first_tail_x15_r0_body.kappa47.a a)) = PRE_first_tail_x15_r0_body.zl47.map (fun a => (PRE_first_tail_x15_r0_body.s461.heap.get a).map PRE_first_tail_x15_r0_body.kappa47.hobj)
theorem PRE_first_tail_x15_r0_body.zimg47 : HeapImg PRE_first_tail_x15_r0_body.kappa47 PRE_first_tail_x15_r0_body.s461 PRE_first_tail_x15_r0_body.s460 PRE_first_tail_x15_r0_body.zl47 := PRE_first_tail_x15_r0_body.zimgE47
-- the roots and their supports
kernel_rfl PRE_first_tail_x15_r0_body.zctl47 : PRE_first_tail_x15_r0_body.s460.ctl = PRE_first_tail_x15_r0_body.kappa47.ctl PRE_first_tail_x15_r0_body.s461.ctl
kernel_rfl PRE_first_tail_x15_r0_body.zstack47 : PRE_first_tail_x15_r0_body.s460.stack = PRE_first_tail_x15_r0_body.s461.stack.map PRE_first_tail_x15_r0_body.kappa47.frame
kernel_rfl PRE_first_tail_x15_r0_body.zjobs47 : PRE_first_tail_x15_r0_body.s460.jobs = PRE_first_tail_x15_r0_body.s461.jobs.map PRE_first_tail_x15_r0_body.kappa47.job
kernel_rfl PRE_first_tail_x15_r0_body.zstores47 : PRE_first_tail_x15_r0_body.s460.stores = PRE_first_tail_x15_r0_body.kappa47.stores PRE_first_tail_x15_r0_body.s461.stores
kernel_rfl PRE_first_tail_x15_r0_body.zroots47 : checkRootsSupp PRE_first_tail_x15_r0_body.s461 2062 = true
kernel_rfl PRE_first_tail_x15_r0_body.znC47 : PRE_first_tail_x15_r0_body.S459.tab.length + PRE_first_tail_x15_r0_body.cws47.length = 2062
-- the map as `Conv.compact_shift` states it (the call's counters for the literals)
kernel_rfl PRE_first_tail_x15_r0_body.zkap47 : PRE_first_tail_x15_r0_body.kappa47 = Conv.Map.compact PRE_first_tail_x15_r0_body.s459.next 2711645 PRE_first_tail_x15_r0_body.S459.tab.length PRE_first_tail_x15_r0_body.pl47 (PRE_first_tail_x15_r0_body.nr47.map NumV.ref) PRE_first_tail_x15_r0_body.kd47.big
  PRE_first_tail_x15_r0_body.kd47.region PRE_first_tail_x15_r0_body.kd47.nodeF
-- the bridge inactive at the canonical state (`Conv.FullShiftQ.toX`; the merged state's bridge is the canonical's: cbridge)
theorem PRE_first_tail_x15_r0_body.zbin47 : (Host.Ts.Sim.Full.bridgeOf PRE_first_tail_x15_r0_body.s461.ffi).active = false := (Host.Load.Boot.replay_active Host.Load.Run.Prompt.P.oblog2818)
-- the JS bookkeeping's step (`Conv.JClean.step` over the changed list) and the canonical roots' bigint freedom
kernel_rfl PRE_first_tail_x15_r0_body.zjc47 : Conv.jcleanListB (⟨19125, 16207, 2711626, 2062⟩ : Conv.Cnt) PRE_first_tail_x15_r0_body.s461 PRE_first_tail_x15_r0_body.cl47 = true
kernel_rfl PRE_first_tail_x15_r0_body.zrootsB47 : noBigRootsP (fun i => !Conv.oldBigB (⟨19125, 16207, 2711626, 2062⟩ : Conv.Cnt) i) PRE_first_tail_x15_r0_body.s461.trace PRE_first_tail_x15_r0_body.s461 = true
kernel_rfl PRE_first_tail_x15_r0_body.zhm47 : Nat.ble (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s0.ffi).mlx.nnext 16207 = true
theorem PRE_first_tail_x15_r0_body.cjcl47 (h : Conv.JClean (⟨19125, 16207, 2711625, 2062⟩ : Conv.Cnt) PRE_first_tail_x15_r0_body.s459) : Conv.JClean (⟨19125, 16207, 2711626, 2062⟩ : Conv.Cnt) PRE_first_tail_x15_r0_body.s461 :=
  Conv.JClean.step h (Conv.Cnt.le_of_leB PRE_first_tail_x15_r0_body.cle47)
    (Conv.heap_off_setAll PRE_first_tail_x15_r0_body.cheap47 fun a ha => Nat.blt_eq.mp (List.all_eq_true.mp PRE_first_tail_x15_r0_body.zclbd47 a ha)) PRE_first_tail_x15_r0_body.zjc47

end Host.Load.Run.Tpl
