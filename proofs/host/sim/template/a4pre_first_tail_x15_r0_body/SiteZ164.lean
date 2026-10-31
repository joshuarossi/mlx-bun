import host.sim.template.a4pre_first_tail_x15_r0_body.SiteS164
import host.sim.template.a4pre_first_tail_x15_r0_body.SiteK164
import host.sim.template.a4pre_first_tail_x15_r0_body.SiteF164
import host.sim.conv.CompactShift
import host.sim.template.Check
import host.sim.BigFreeP
import host.sim.template.CallGen
set_option Elab.async false
namespace Host.Load.Run.Tpl
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
open Host.Ts Host.Ts.Sim Host.Ts.Sim.Template

/-! The compaction's state shift at call site 164 of chain `PRE_first_tail_x15_r0_body` (`Conv.compact_shift`): the call `PRE_first_tail_x15_r0_body.s1581`, the merged
state `PRE_first_tail_x15_r0_body.s1582`, the canonical state `PRE_first_tail_x15_r0_body.s1583`; its frames [2665,2673467,2673472,2673473] (kept arrays [2665,2673467]). -/

-- the map's places and counters
kernel_rfl PRE_first_tail_x15_r0_body.zpl164 : PRE_first_tail_x15_r0_body.pl164.all (Nat.ble PRE_first_tail_x15_r0_body.s1581.next) = true
kernel_rfl PRE_first_tail_x15_r0_body.zplnd164 : nodupT PRE_first_tail_x15_r0_body.pl164 PTrie.nil = true
kernel_rfl PRE_first_tail_x15_r0_body.zn1164 : Nat.ble PRE_first_tail_x15_r0_body.s1581.next 2803195 = true
kernel_rfl PRE_first_tail_x15_r0_body.zfirst164 : Nat.ble aFirst PRE_first_tail_x15_r0_body.s1581.next = true
kernel_rfl PRE_first_tail_x15_r0_body.zscn164 : PRE_first_tail_x15_r0_body.s1583.next = PRE_first_tail_x15_r0_body.s1581.next + PRE_first_tail_x15_r0_body.pl164.length
kernel_rfl PRE_first_tail_x15_r0_body.zsmn164 : PRE_first_tail_x15_r0_body.s1582.next = 2803195
kernel_rfl PRE_first_tail_x15_r0_body.zgrow164 : Nat.ble PRE_first_tail_x15_r0_body.s1583.next PRE_first_tail_x15_r0_body.s1582.next = true
-- the tables
kernel_rfl PRE_first_tail_x15_r0_body.zfresh164 : PRE_first_tail_x15_r0_body.S1581.tab.all (fun e => PRE_first_tail_x15_r0_body.cws164.all fun v => e.noVar v) = true
kernel_rfl PRE_first_tail_x15_r0_body.zcnd164 : nodupT PRE_first_tail_x15_r0_body.cws164 PTrie.nil = true
kernel_rfl PRE_first_tail_x15_r0_body.znrHi164 : PRE_first_tail_x15_r0_body.nr164.all (fun r => Nat.blt r PRE_first_tail_x15_r0_body.S1582.tab.length) = true
-- the frames: every framed address below the call's counter; the kept arrays the chain start's, extended in the merged state
kernel_rfl PRE_first_tail_x15_r0_body.zfrlt164 : [2665, 2673467, 2673472, 2673473].all (fun a => Nat.blt a PRE_first_tail_x15_r0_body.s1581.next) = true
kernel_rfl PRE_first_tail_x15_r0_body.zg164_2665 : PRE_first_tail_x15_r0_body.s1583.heap.get 2665 = some (.obj (objOf PRE_first_tail_x15_r0_body.s1583 2665))
kernel_rfl PRE_first_tail_x15_r0_body.zk164_2665 : (objOf PRE_first_tail_x15_r0_body.s1583 2665).kind = .array (arrOf PRE_first_tail_x15_r0_body.s0 2665)
kernel_rfl PRE_first_tail_x15_r0_body.zm164_2665 : PRE_first_tail_x15_r0_body.s1582.heap.get 2665 = some (.obj { PRE_first_tail_x15_r0_body.kappa164.obj (objOf PRE_first_tail_x15_r0_body.s1583 2665) with
  kind := .array (arrOf PRE_first_tail_x15_r0_body.s0 2665 ++ (arrOf PRE_first_tail_x15_r0_body.s1582 2665).drop (arrOf PRE_first_tail_x15_r0_body.s0 2665).length) })
kernel_rfl PRE_first_tail_x15_r0_body.zg164_2673467 : PRE_first_tail_x15_r0_body.s1583.heap.get 2673467 = some (.obj (objOf PRE_first_tail_x15_r0_body.s1583 2673467))
kernel_rfl PRE_first_tail_x15_r0_body.zk164_2673467 : (objOf PRE_first_tail_x15_r0_body.s1583 2673467).kind = .array (arrOf PRE_first_tail_x15_r0_body.s0 2673467)
kernel_rfl PRE_first_tail_x15_r0_body.zm164_2673467 : PRE_first_tail_x15_r0_body.s1582.heap.get 2673467 = some (.obj { PRE_first_tail_x15_r0_body.kappa164.obj (objOf PRE_first_tail_x15_r0_body.s1583 2673467) with
  kind := .array (arrOf PRE_first_tail_x15_r0_body.s0 2673467 ++ (arrOf PRE_first_tail_x15_r0_body.s1582 2673467).drop (arrOf PRE_first_tail_x15_r0_body.s0 2673467).length) })
kernel_rfl PRE_first_tail_x15_r0_body.zw164_4910 : (PRE_first_tail_x15_r0_body.s1583.heap.get 4910).isSome = true
kernel_rfl PRE_first_tail_x15_r0_body.zw164_2673472 : (PRE_first_tail_x15_r0_body.s1583.heap.get 2673472).isSome = true
kernel_rfl PRE_first_tail_x15_r0_body.zw164_2673473 : (PRE_first_tail_x15_r0_body.s1583.heap.get 2673473).isSome = true
-- the heap: the changed list in range, holding the stage's written and fresh addresses; the canonical side's image
kernel_rfl PRE_first_tail_x15_r0_body.zclbd164 : PRE_first_tail_x15_r0_body.cl164.all (fun b => Nat.blt (b / 4096) (4 ^ 31)) = true
kernel_rfl PRE_first_tail_x15_r0_body.zwr164 : PRE_first_tail_x15_r0_body.st164.wr.all (fun b => !Nat.blt b PRE_first_tail_x15_r0_body.s1581.next || PRE_first_tail_x15_r0_body.cl164.contains b) = true
def PRE_first_tail_x15_r0_body.zl164 : List Nat := PRE_first_tail_x15_r0_body.cl164.filter fun a => !(List.contains [2665, 2673467] a)
kernel_rfl PRE_first_tail_x15_r0_body.zimgE164 : PRE_first_tail_x15_r0_body.zl164.map (fun a => PRE_first_tail_x15_r0_body.s1582.heap.get (PRE_first_tail_x15_r0_body.kappa164.a a)) = PRE_first_tail_x15_r0_body.zl164.map (fun a => (PRE_first_tail_x15_r0_body.s1583.heap.get a).map PRE_first_tail_x15_r0_body.kappa164.hobj)
theorem PRE_first_tail_x15_r0_body.zimg164 : HeapImg PRE_first_tail_x15_r0_body.kappa164 PRE_first_tail_x15_r0_body.s1583 PRE_first_tail_x15_r0_body.s1582 PRE_first_tail_x15_r0_body.zl164 := PRE_first_tail_x15_r0_body.zimgE164
-- the roots and their supports
kernel_rfl PRE_first_tail_x15_r0_body.zctl164 : PRE_first_tail_x15_r0_body.s1582.ctl = PRE_first_tail_x15_r0_body.kappa164.ctl PRE_first_tail_x15_r0_body.s1583.ctl
kernel_rfl PRE_first_tail_x15_r0_body.zstack164 : PRE_first_tail_x15_r0_body.s1582.stack = PRE_first_tail_x15_r0_body.s1583.stack.map PRE_first_tail_x15_r0_body.kappa164.frame
kernel_rfl PRE_first_tail_x15_r0_body.zjobs164 : PRE_first_tail_x15_r0_body.s1582.jobs = PRE_first_tail_x15_r0_body.s1583.jobs.map PRE_first_tail_x15_r0_body.kappa164.job
kernel_rfl PRE_first_tail_x15_r0_body.zstores164 : PRE_first_tail_x15_r0_body.s1582.stores = PRE_first_tail_x15_r0_body.kappa164.stores PRE_first_tail_x15_r0_body.s1583.stores
kernel_rfl PRE_first_tail_x15_r0_body.zroots164 : checkRootsSupp PRE_first_tail_x15_r0_body.s1583 7066 = true
kernel_rfl PRE_first_tail_x15_r0_body.znC164 : PRE_first_tail_x15_r0_body.S1581.tab.length + PRE_first_tail_x15_r0_body.cws164.length = 7066
-- the map as `Conv.compact_shift` states it (the call's counters for the literals)
kernel_rfl PRE_first_tail_x15_r0_body.zkap164 : PRE_first_tail_x15_r0_body.kappa164 = Conv.Map.compact PRE_first_tail_x15_r0_body.s1581.next 2803195 PRE_first_tail_x15_r0_body.S1581.tab.length PRE_first_tail_x15_r0_body.pl164 (PRE_first_tail_x15_r0_body.nr164.map NumV.ref) PRE_first_tail_x15_r0_body.kd164.big
  PRE_first_tail_x15_r0_body.kd164.region PRE_first_tail_x15_r0_body.kd164.nodeF
-- the bridge inactive at the canonical state (`Conv.FullShiftQ.toX`; the merged state's bridge is the canonical's: cbridge)
theorem PRE_first_tail_x15_r0_body.zbin164 : (Host.Ts.Sim.Full.bridgeOf PRE_first_tail_x15_r0_body.s1583.ffi).active = false := (Host.Load.Boot.replay_active Host.Load.Run.Prompt.P.oblog2818)
-- the JS bookkeeping's step (`Conv.JClean.step` over the changed list) and the canonical roots' bigint freedom
kernel_rfl PRE_first_tail_x15_r0_body.zjc164 : Conv.jcleanListB (⟨21421, 18529, 2803176, 7066⟩ : Conv.Cnt) PRE_first_tail_x15_r0_body.s1583 PRE_first_tail_x15_r0_body.cl164 = true
kernel_rfl PRE_first_tail_x15_r0_body.zrootsB164 : noBigRootsP (fun i => !Conv.oldBigB (⟨21421, 18529, 2803176, 7066⟩ : Conv.Cnt) i) PRE_first_tail_x15_r0_body.s1583.trace PRE_first_tail_x15_r0_body.s1583 = true
kernel_rfl PRE_first_tail_x15_r0_body.zhm164 : Nat.ble (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s0.ffi).mlx.nnext 18529 = true
theorem PRE_first_tail_x15_r0_body.cjcl164 (h : Conv.JClean (⟨21421, 18529, 2803175, 7066⟩ : Conv.Cnt) PRE_first_tail_x15_r0_body.s1581) : Conv.JClean (⟨21421, 18529, 2803176, 7066⟩ : Conv.Cnt) PRE_first_tail_x15_r0_body.s1583 :=
  Conv.JClean.step h (Conv.Cnt.le_of_leB PRE_first_tail_x15_r0_body.cle164)
    (Conv.heap_off_setAll PRE_first_tail_x15_r0_body.cheap164 fun a ha => Nat.blt_eq.mp (List.all_eq_true.mp PRE_first_tail_x15_r0_body.zclbd164 a ha)) PRE_first_tail_x15_r0_body.zjc164

end Host.Load.Run.Tpl
