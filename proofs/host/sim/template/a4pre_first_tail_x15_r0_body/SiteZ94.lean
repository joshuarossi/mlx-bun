import host.sim.template.a4pre_first_tail_x15_r0_body.SiteS94
import host.sim.template.a4pre_first_tail_x15_r0_body.SiteK94
import host.sim.template.a4pre_first_tail_x15_r0_body.SiteF94
import host.sim.conv.CompactShift
import host.sim.template.Check
import host.sim.BigFreeP
import host.sim.template.CallGen
set_option Elab.async false
namespace Host.Load.Run.Tpl
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
open Host.Ts Host.Ts.Sim Host.Ts.Sim.Template

/-! The compaction's state shift at call site 94 of chain `PRE_first_tail_x15_r0_body` (`Conv.compact_shift`): the call `PRE_first_tail_x15_r0_body.s834`, the merged
state `PRE_first_tail_x15_r0_body.s835`, the canonical state `PRE_first_tail_x15_r0_body.s836`; its frames [2665,2673467,2673472,2673473] (kept arrays [2665,2673467]). -/

-- the map's places and counters
kernel_rfl PRE_first_tail_x15_r0_body.zpl94 : PRE_first_tail_x15_r0_body.pl94.all (Nat.ble PRE_first_tail_x15_r0_body.s834.next) = true
kernel_rfl PRE_first_tail_x15_r0_body.zplnd94 : nodupT PRE_first_tail_x15_r0_body.pl94 PTrie.nil = true
kernel_rfl PRE_first_tail_x15_r0_body.zn194 : Nat.ble PRE_first_tail_x15_r0_body.s834.next 2749007 = true
kernel_rfl PRE_first_tail_x15_r0_body.zfirst94 : Nat.ble aFirst PRE_first_tail_x15_r0_body.s834.next = true
kernel_rfl PRE_first_tail_x15_r0_body.zscn94 : PRE_first_tail_x15_r0_body.s836.next = PRE_first_tail_x15_r0_body.s834.next + PRE_first_tail_x15_r0_body.pl94.length
kernel_rfl PRE_first_tail_x15_r0_body.zsmn94 : PRE_first_tail_x15_r0_body.s835.next = 2749007
kernel_rfl PRE_first_tail_x15_r0_body.zgrow94 : Nat.ble PRE_first_tail_x15_r0_body.s836.next PRE_first_tail_x15_r0_body.s835.next = true
-- the tables
kernel_rfl PRE_first_tail_x15_r0_body.zfresh94 : PRE_first_tail_x15_r0_body.S834.tab.all (fun e => PRE_first_tail_x15_r0_body.cws94.all fun v => e.noVar v) = true
kernel_rfl PRE_first_tail_x15_r0_body.zcnd94 : nodupT PRE_first_tail_x15_r0_body.cws94 PTrie.nil = true
kernel_rfl PRE_first_tail_x15_r0_body.znrHi94 : PRE_first_tail_x15_r0_body.nr94.all (fun r => Nat.blt r PRE_first_tail_x15_r0_body.S835.tab.length) = true
-- the frames: every framed address below the call's counter; the kept arrays the chain start's, extended in the merged state
kernel_rfl PRE_first_tail_x15_r0_body.zfrlt94 : [2665, 2673467, 2673472, 2673473].all (fun a => Nat.blt a PRE_first_tail_x15_r0_body.s834.next) = true
kernel_rfl PRE_first_tail_x15_r0_body.zg94_2665 : PRE_first_tail_x15_r0_body.s836.heap.get 2665 = some (.obj (objOf PRE_first_tail_x15_r0_body.s836 2665))
kernel_rfl PRE_first_tail_x15_r0_body.zk94_2665 : (objOf PRE_first_tail_x15_r0_body.s836 2665).kind = .array (arrOf PRE_first_tail_x15_r0_body.s0 2665)
kernel_rfl PRE_first_tail_x15_r0_body.zm94_2665 : PRE_first_tail_x15_r0_body.s835.heap.get 2665 = some (.obj { PRE_first_tail_x15_r0_body.kappa94.obj (objOf PRE_first_tail_x15_r0_body.s836 2665) with
  kind := .array (arrOf PRE_first_tail_x15_r0_body.s0 2665 ++ (arrOf PRE_first_tail_x15_r0_body.s835 2665).drop (arrOf PRE_first_tail_x15_r0_body.s0 2665).length) })
kernel_rfl PRE_first_tail_x15_r0_body.zg94_2673467 : PRE_first_tail_x15_r0_body.s836.heap.get 2673467 = some (.obj (objOf PRE_first_tail_x15_r0_body.s836 2673467))
kernel_rfl PRE_first_tail_x15_r0_body.zk94_2673467 : (objOf PRE_first_tail_x15_r0_body.s836 2673467).kind = .array (arrOf PRE_first_tail_x15_r0_body.s0 2673467)
kernel_rfl PRE_first_tail_x15_r0_body.zm94_2673467 : PRE_first_tail_x15_r0_body.s835.heap.get 2673467 = some (.obj { PRE_first_tail_x15_r0_body.kappa94.obj (objOf PRE_first_tail_x15_r0_body.s836 2673467) with
  kind := .array (arrOf PRE_first_tail_x15_r0_body.s0 2673467 ++ (arrOf PRE_first_tail_x15_r0_body.s835 2673467).drop (arrOf PRE_first_tail_x15_r0_body.s0 2673467).length) })
kernel_rfl PRE_first_tail_x15_r0_body.zw94_4910 : (PRE_first_tail_x15_r0_body.s836.heap.get 4910).isSome = true
kernel_rfl PRE_first_tail_x15_r0_body.zw94_2673472 : (PRE_first_tail_x15_r0_body.s836.heap.get 2673472).isSome = true
kernel_rfl PRE_first_tail_x15_r0_body.zw94_2673473 : (PRE_first_tail_x15_r0_body.s836.heap.get 2673473).isSome = true
-- the heap: the changed list in range, holding the stage's written and fresh addresses; the canonical side's image
kernel_rfl PRE_first_tail_x15_r0_body.zclbd94 : PRE_first_tail_x15_r0_body.cl94.all (fun b => Nat.blt (b / 4096) (4 ^ 31)) = true
kernel_rfl PRE_first_tail_x15_r0_body.zwr94 : PRE_first_tail_x15_r0_body.st94.wr.all (fun b => !Nat.blt b PRE_first_tail_x15_r0_body.s834.next || PRE_first_tail_x15_r0_body.cl94.contains b) = true
def PRE_first_tail_x15_r0_body.zl94 : List Nat := PRE_first_tail_x15_r0_body.cl94.filter fun a => !(List.contains [2665, 2673467] a)
kernel_rfl PRE_first_tail_x15_r0_body.zimgE94 : PRE_first_tail_x15_r0_body.zl94.map (fun a => PRE_first_tail_x15_r0_body.s835.heap.get (PRE_first_tail_x15_r0_body.kappa94.a a)) = PRE_first_tail_x15_r0_body.zl94.map (fun a => (PRE_first_tail_x15_r0_body.s836.heap.get a).map PRE_first_tail_x15_r0_body.kappa94.hobj)
theorem PRE_first_tail_x15_r0_body.zimg94 : HeapImg PRE_first_tail_x15_r0_body.kappa94 PRE_first_tail_x15_r0_body.s836 PRE_first_tail_x15_r0_body.s835 PRE_first_tail_x15_r0_body.zl94 := PRE_first_tail_x15_r0_body.zimgE94
-- the roots and their supports
kernel_rfl PRE_first_tail_x15_r0_body.zctl94 : PRE_first_tail_x15_r0_body.s835.ctl = PRE_first_tail_x15_r0_body.kappa94.ctl PRE_first_tail_x15_r0_body.s836.ctl
kernel_rfl PRE_first_tail_x15_r0_body.zstack94 : PRE_first_tail_x15_r0_body.s835.stack = PRE_first_tail_x15_r0_body.s836.stack.map PRE_first_tail_x15_r0_body.kappa94.frame
kernel_rfl PRE_first_tail_x15_r0_body.zjobs94 : PRE_first_tail_x15_r0_body.s835.jobs = PRE_first_tail_x15_r0_body.s836.jobs.map PRE_first_tail_x15_r0_body.kappa94.job
kernel_rfl PRE_first_tail_x15_r0_body.zstores94 : PRE_first_tail_x15_r0_body.s835.stores = PRE_first_tail_x15_r0_body.kappa94.stores PRE_first_tail_x15_r0_body.s836.stores
kernel_rfl PRE_first_tail_x15_r0_body.zroots94 : checkRootsSupp PRE_first_tail_x15_r0_body.s836 4097 = true
kernel_rfl PRE_first_tail_x15_r0_body.znC94 : PRE_first_tail_x15_r0_body.S834.tab.length + PRE_first_tail_x15_r0_body.cws94.length = 4097
-- the map as `Conv.compact_shift` states it (the call's counters for the literals)
kernel_rfl PRE_first_tail_x15_r0_body.zkap94 : PRE_first_tail_x15_r0_body.kappa94 = Conv.Map.compact PRE_first_tail_x15_r0_body.s834.next 2749007 PRE_first_tail_x15_r0_body.S834.tab.length PRE_first_tail_x15_r0_body.pl94 (PRE_first_tail_x15_r0_body.nr94.map NumV.ref) PRE_first_tail_x15_r0_body.kd94.big
  PRE_first_tail_x15_r0_body.kd94.region PRE_first_tail_x15_r0_body.kd94.nodeF
-- the bridge inactive at the canonical state (`Conv.FullShiftQ.toX`; the merged state's bridge is the canonical's: cbridge)
theorem PRE_first_tail_x15_r0_body.zbin94 : (Host.Ts.Sim.Full.bridgeOf PRE_first_tail_x15_r0_body.s836.ffi).active = false := (Host.Load.Boot.replay_active Host.Load.Run.Prompt.P.oblog2818)
-- the JS bookkeeping's step (`Conv.JClean.step` over the changed list) and the canonical roots' bigint freedom
kernel_rfl PRE_first_tail_x15_r0_body.zjc94 : Conv.jcleanListB (⟨20062, 17151, 2749005, 4097⟩ : Conv.Cnt) PRE_first_tail_x15_r0_body.s836 PRE_first_tail_x15_r0_body.cl94 = true
kernel_rfl PRE_first_tail_x15_r0_body.zroots294 : noBigRootsP (fun i => !Conv.oldBigB (⟨20062, 17151, 2749005, 4097⟩ : Conv.Cnt) i) PRE_first_tail_x15_r0_body.s836.trace PRE_first_tail_x15_r0_body.s836 = true
kernel_rfl PRE_first_tail_x15_r0_body.zhm94 : Nat.ble (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s0.ffi).mlx.nnext 17151 = true
theorem PRE_first_tail_x15_r0_body.cjcl94 (h : Conv.JClean (⟨20062, 17151, 2749005, 4097⟩ : Conv.Cnt) PRE_first_tail_x15_r0_body.s834) : Conv.JClean (⟨20062, 17151, 2749005, 4097⟩ : Conv.Cnt) PRE_first_tail_x15_r0_body.s836 :=
  Conv.JClean.step h (Conv.Cnt.le_of_leB PRE_first_tail_x15_r0_body.cle94)
    (Conv.heap_off_setAll PRE_first_tail_x15_r0_body.cheap94 fun a ha => Nat.blt_eq.mp (List.all_eq_true.mp PRE_first_tail_x15_r0_body.zclbd94 a ha)) PRE_first_tail_x15_r0_body.zjc94

end Host.Load.Run.Tpl
