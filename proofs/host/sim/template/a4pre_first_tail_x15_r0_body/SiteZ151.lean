import host.sim.template.a4pre_first_tail_x15_r0_body.SiteS151
import host.sim.template.a4pre_first_tail_x15_r0_body.SiteK151
import host.sim.template.a4pre_first_tail_x15_r0_body.SiteF151
import host.sim.conv.CompactShift
import host.sim.template.Check
import host.sim.BigFreeP
import host.sim.template.CallGen
set_option Elab.async false
namespace Host.Load.Run.Tpl
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
open Host.Ts Host.Ts.Sim Host.Ts.Sim.Template

/-! The compaction's state shift at call site 151 of chain `PRE_first_tail_x15_r0_body` (`Conv.compact_shift`): the call `PRE_first_tail_x15_r0_body.s1462`, the merged
state `PRE_first_tail_x15_r0_body.s1463`, the canonical state `PRE_first_tail_x15_r0_body.s1464`; its frames [2665,2673467,2673472,2673473] (kept arrays [2665,2673467]). -/

-- the map's places and counters
kernel_rfl PRE_first_tail_x15_r0_body.zpl151 : PRE_first_tail_x15_r0_body.pl151.all (Nat.ble PRE_first_tail_x15_r0_body.s1462.next) = true
kernel_rfl PRE_first_tail_x15_r0_body.zplnd151 : nodupT PRE_first_tail_x15_r0_body.pl151 PTrie.nil = true
kernel_rfl PRE_first_tail_x15_r0_body.zn1151 : Nat.ble PRE_first_tail_x15_r0_body.s1462.next 2793477 = true
kernel_rfl PRE_first_tail_x15_r0_body.zfirst151 : Nat.ble aFirst PRE_first_tail_x15_r0_body.s1462.next = true
kernel_rfl PRE_first_tail_x15_r0_body.zscn151 : PRE_first_tail_x15_r0_body.s1464.next = PRE_first_tail_x15_r0_body.s1462.next + PRE_first_tail_x15_r0_body.pl151.length
kernel_rfl PRE_first_tail_x15_r0_body.zsmn151 : PRE_first_tail_x15_r0_body.s1463.next = 2793477
kernel_rfl PRE_first_tail_x15_r0_body.zgrow151 : Nat.ble PRE_first_tail_x15_r0_body.s1464.next PRE_first_tail_x15_r0_body.s1463.next = true
-- the tables
kernel_rfl PRE_first_tail_x15_r0_body.zfresh151 : PRE_first_tail_x15_r0_body.S1462.tab.all (fun e => PRE_first_tail_x15_r0_body.cws151.all fun v => e.noVar v) = true
kernel_rfl PRE_first_tail_x15_r0_body.zcnd151 : nodupT PRE_first_tail_x15_r0_body.cws151 PTrie.nil = true
kernel_rfl PRE_first_tail_x15_r0_body.znrHi151 : PRE_first_tail_x15_r0_body.nr151.all (fun r => Nat.blt r PRE_first_tail_x15_r0_body.S1463.tab.length) = true
-- the frames: every framed address below the call's counter; the kept arrays the chain start's, extended in the merged state
kernel_rfl PRE_first_tail_x15_r0_body.zfrlt151 : [2665, 2673467, 2673472, 2673473].all (fun a => Nat.blt a PRE_first_tail_x15_r0_body.s1462.next) = true
kernel_rfl PRE_first_tail_x15_r0_body.zg151_2665 : PRE_first_tail_x15_r0_body.s1464.heap.get 2665 = some (.obj (objOf PRE_first_tail_x15_r0_body.s1464 2665))
kernel_rfl PRE_first_tail_x15_r0_body.zk151_2665 : (objOf PRE_first_tail_x15_r0_body.s1464 2665).kind = .array (arrOf PRE_first_tail_x15_r0_body.s0 2665)
kernel_rfl PRE_first_tail_x15_r0_body.zm151_2665 : PRE_first_tail_x15_r0_body.s1463.heap.get 2665 = some (.obj { PRE_first_tail_x15_r0_body.kappa151.obj (objOf PRE_first_tail_x15_r0_body.s1464 2665) with
  kind := .array (arrOf PRE_first_tail_x15_r0_body.s0 2665 ++ (arrOf PRE_first_tail_x15_r0_body.s1463 2665).drop (arrOf PRE_first_tail_x15_r0_body.s0 2665).length) })
kernel_rfl PRE_first_tail_x15_r0_body.zg151_2673467 : PRE_first_tail_x15_r0_body.s1464.heap.get 2673467 = some (.obj (objOf PRE_first_tail_x15_r0_body.s1464 2673467))
kernel_rfl PRE_first_tail_x15_r0_body.zk151_2673467 : (objOf PRE_first_tail_x15_r0_body.s1464 2673467).kind = .array (arrOf PRE_first_tail_x15_r0_body.s0 2673467)
kernel_rfl PRE_first_tail_x15_r0_body.zm151_2673467 : PRE_first_tail_x15_r0_body.s1463.heap.get 2673467 = some (.obj { PRE_first_tail_x15_r0_body.kappa151.obj (objOf PRE_first_tail_x15_r0_body.s1464 2673467) with
  kind := .array (arrOf PRE_first_tail_x15_r0_body.s0 2673467 ++ (arrOf PRE_first_tail_x15_r0_body.s1463 2673467).drop (arrOf PRE_first_tail_x15_r0_body.s0 2673467).length) })
kernel_rfl PRE_first_tail_x15_r0_body.zw151_4910 : (PRE_first_tail_x15_r0_body.s1464.heap.get 4910).isSome = true
kernel_rfl PRE_first_tail_x15_r0_body.zw151_2673472 : (PRE_first_tail_x15_r0_body.s1464.heap.get 2673472).isSome = true
kernel_rfl PRE_first_tail_x15_r0_body.zw151_2673473 : (PRE_first_tail_x15_r0_body.s1464.heap.get 2673473).isSome = true
-- the heap: the changed list in range, holding the stage's written and fresh addresses; the canonical side's image
kernel_rfl PRE_first_tail_x15_r0_body.zclbd151 : PRE_first_tail_x15_r0_body.cl151.all (fun b => Nat.blt (b / 4096) (4 ^ 31)) = true
kernel_rfl PRE_first_tail_x15_r0_body.zwr151 : PRE_first_tail_x15_r0_body.st151.wr.all (fun b => !Nat.blt b PRE_first_tail_x15_r0_body.s1462.next || PRE_first_tail_x15_r0_body.cl151.contains b) = true
def PRE_first_tail_x15_r0_body.zl151 : List Nat := PRE_first_tail_x15_r0_body.cl151.filter fun a => !(List.contains [2665, 2673467] a)
kernel_rfl PRE_first_tail_x15_r0_body.zimgE151 : PRE_first_tail_x15_r0_body.zl151.map (fun a => PRE_first_tail_x15_r0_body.s1463.heap.get (PRE_first_tail_x15_r0_body.kappa151.a a)) = PRE_first_tail_x15_r0_body.zl151.map (fun a => (PRE_first_tail_x15_r0_body.s1464.heap.get a).map PRE_first_tail_x15_r0_body.kappa151.hobj)
theorem PRE_first_tail_x15_r0_body.zimg151 : HeapImg PRE_first_tail_x15_r0_body.kappa151 PRE_first_tail_x15_r0_body.s1464 PRE_first_tail_x15_r0_body.s1463 PRE_first_tail_x15_r0_body.zl151 := PRE_first_tail_x15_r0_body.zimgE151
-- the roots and their supports
kernel_rfl PRE_first_tail_x15_r0_body.zctl151 : PRE_first_tail_x15_r0_body.s1463.ctl = PRE_first_tail_x15_r0_body.kappa151.ctl PRE_first_tail_x15_r0_body.s1464.ctl
kernel_rfl PRE_first_tail_x15_r0_body.zstack151 : PRE_first_tail_x15_r0_body.s1463.stack = PRE_first_tail_x15_r0_body.s1464.stack.map PRE_first_tail_x15_r0_body.kappa151.frame
kernel_rfl PRE_first_tail_x15_r0_body.zjobs151 : PRE_first_tail_x15_r0_body.s1463.jobs = PRE_first_tail_x15_r0_body.s1464.jobs.map PRE_first_tail_x15_r0_body.kappa151.job
kernel_rfl PRE_first_tail_x15_r0_body.zstores151 : PRE_first_tail_x15_r0_body.s1463.stores = PRE_first_tail_x15_r0_body.kappa151.stores PRE_first_tail_x15_r0_body.s1464.stores
kernel_rfl PRE_first_tail_x15_r0_body.zroots151 : checkRootsSupp PRE_first_tail_x15_r0_body.s1464 6536 = true
kernel_rfl PRE_first_tail_x15_r0_body.znC151 : PRE_first_tail_x15_r0_body.S1462.tab.length + PRE_first_tail_x15_r0_body.cws151.length = 6536
-- the map as `Conv.compact_shift` states it (the call's counters for the literals)
kernel_rfl PRE_first_tail_x15_r0_body.zkap151 : PRE_first_tail_x15_r0_body.kappa151 = Conv.Map.compact PRE_first_tail_x15_r0_body.s1462.next 2793477 PRE_first_tail_x15_r0_body.S1462.tab.length PRE_first_tail_x15_r0_body.pl151 (PRE_first_tail_x15_r0_body.nr151.map NumV.ref) PRE_first_tail_x15_r0_body.kd151.big
  PRE_first_tail_x15_r0_body.kd151.region PRE_first_tail_x15_r0_body.kd151.nodeF
-- the bridge inactive at the canonical state (`Conv.FullShiftQ.toX`; the merged state's bridge is the canonical's: cbridge)
theorem PRE_first_tail_x15_r0_body.zbin151 : (Host.Ts.Sim.Full.bridgeOf PRE_first_tail_x15_r0_body.s1464.ffi).active = false := (Host.Load.Boot.replay_active Host.Load.Run.Prompt.P.oblog2818)
-- the JS bookkeeping's step (`Conv.JClean.step` over the changed list) and the canonical roots' bigint freedom
kernel_rfl PRE_first_tail_x15_r0_body.zjc151 : Conv.jcleanListB (⟨21178, 18288, 2793475, 6536⟩ : Conv.Cnt) PRE_first_tail_x15_r0_body.s1464 PRE_first_tail_x15_r0_body.cl151 = true
kernel_rfl PRE_first_tail_x15_r0_body.zrootsB151 : noBigRootsP (fun i => !Conv.oldBigB (⟨21178, 18288, 2793475, 6536⟩ : Conv.Cnt) i) PRE_first_tail_x15_r0_body.s1464.trace PRE_first_tail_x15_r0_body.s1464 = true
kernel_rfl PRE_first_tail_x15_r0_body.zhm151 : Nat.ble (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s0.ffi).mlx.nnext 18288 = true
theorem PRE_first_tail_x15_r0_body.cjcl151 (h : Conv.JClean (⟨21178, 18288, 2793475, 6536⟩ : Conv.Cnt) PRE_first_tail_x15_r0_body.s1462) : Conv.JClean (⟨21178, 18288, 2793475, 6536⟩ : Conv.Cnt) PRE_first_tail_x15_r0_body.s1464 :=
  Conv.JClean.step h (Conv.Cnt.le_of_leB PRE_first_tail_x15_r0_body.cle151)
    (Conv.heap_off_setAll PRE_first_tail_x15_r0_body.cheap151 fun a ha => Nat.blt_eq.mp (List.all_eq_true.mp PRE_first_tail_x15_r0_body.zclbd151 a ha)) PRE_first_tail_x15_r0_body.zjc151

end Host.Load.Run.Tpl
