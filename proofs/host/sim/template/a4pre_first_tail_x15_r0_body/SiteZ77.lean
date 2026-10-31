import host.sim.template.a4pre_first_tail_x15_r0_body.SiteS77
import host.sim.template.a4pre_first_tail_x15_r0_body.SiteK77
import host.sim.template.a4pre_first_tail_x15_r0_body.SiteF77
import host.sim.conv.CompactShift
import host.sim.template.Check
import host.sim.BigFreeP
import host.sim.template.CallGen
set_option Elab.async false
namespace Host.Load.Run.Tpl
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
open Host.Ts Host.Ts.Sim Host.Ts.Sim.Template

/-! The compaction's state shift at call site 77 of chain `PRE_first_tail_x15_r0_body` (`Conv.compact_shift`): the call `PRE_first_tail_x15_r0_body.s682`, the merged
state `PRE_first_tail_x15_r0_body.s683`, the canonical state `PRE_first_tail_x15_r0_body.s684`; its frames [2665,2673467,2673472,2673473] (kept arrays [2665,2673467]). -/

-- the map's places and counters
kernel_rfl PRE_first_tail_x15_r0_body.zpl77 : PRE_first_tail_x15_r0_body.pl77.all (Nat.ble PRE_first_tail_x15_r0_body.s682.next) = true
kernel_rfl PRE_first_tail_x15_r0_body.zplnd77 : nodupT PRE_first_tail_x15_r0_body.pl77 PTrie.nil = true
kernel_rfl PRE_first_tail_x15_r0_body.zn177 : Nat.ble PRE_first_tail_x15_r0_body.s682.next 2735010 = true
kernel_rfl PRE_first_tail_x15_r0_body.zfirst77 : Nat.ble aFirst PRE_first_tail_x15_r0_body.s682.next = true
kernel_rfl PRE_first_tail_x15_r0_body.zscn77 : PRE_first_tail_x15_r0_body.s684.next = PRE_first_tail_x15_r0_body.s682.next + PRE_first_tail_x15_r0_body.pl77.length
kernel_rfl PRE_first_tail_x15_r0_body.zsmn77 : PRE_first_tail_x15_r0_body.s683.next = 2735010
kernel_rfl PRE_first_tail_x15_r0_body.zgrow77 : Nat.ble PRE_first_tail_x15_r0_body.s684.next PRE_first_tail_x15_r0_body.s683.next = true
-- the tables
kernel_rfl PRE_first_tail_x15_r0_body.zfresh77 : PRE_first_tail_x15_r0_body.S682.tab.all (fun e => PRE_first_tail_x15_r0_body.cws77.all fun v => e.noVar v) = true
kernel_rfl PRE_first_tail_x15_r0_body.zcnd77 : nodupT PRE_first_tail_x15_r0_body.cws77 PTrie.nil = true
kernel_rfl PRE_first_tail_x15_r0_body.znrHi77 : PRE_first_tail_x15_r0_body.nr77.all (fun r => Nat.blt r PRE_first_tail_x15_r0_body.S683.tab.length) = true
-- the frames: every framed address below the call's counter; the kept arrays the chain start's, extended in the merged state
kernel_rfl PRE_first_tail_x15_r0_body.zfrlt77 : [2665, 2673467, 2673472, 2673473].all (fun a => Nat.blt a PRE_first_tail_x15_r0_body.s682.next) = true
kernel_rfl PRE_first_tail_x15_r0_body.zg77_2665 : PRE_first_tail_x15_r0_body.s684.heap.get 2665 = some (.obj (objOf PRE_first_tail_x15_r0_body.s684 2665))
kernel_rfl PRE_first_tail_x15_r0_body.zk77_2665 : (objOf PRE_first_tail_x15_r0_body.s684 2665).kind = .array (arrOf PRE_first_tail_x15_r0_body.s0 2665)
kernel_rfl PRE_first_tail_x15_r0_body.zm77_2665 : PRE_first_tail_x15_r0_body.s683.heap.get 2665 = some (.obj { PRE_first_tail_x15_r0_body.kappa77.obj (objOf PRE_first_tail_x15_r0_body.s684 2665) with
  kind := .array (arrOf PRE_first_tail_x15_r0_body.s0 2665 ++ (arrOf PRE_first_tail_x15_r0_body.s683 2665).drop (arrOf PRE_first_tail_x15_r0_body.s0 2665).length) })
kernel_rfl PRE_first_tail_x15_r0_body.zg77_2673467 : PRE_first_tail_x15_r0_body.s684.heap.get 2673467 = some (.obj (objOf PRE_first_tail_x15_r0_body.s684 2673467))
kernel_rfl PRE_first_tail_x15_r0_body.zk77_2673467 : (objOf PRE_first_tail_x15_r0_body.s684 2673467).kind = .array (arrOf PRE_first_tail_x15_r0_body.s0 2673467)
kernel_rfl PRE_first_tail_x15_r0_body.zm77_2673467 : PRE_first_tail_x15_r0_body.s683.heap.get 2673467 = some (.obj { PRE_first_tail_x15_r0_body.kappa77.obj (objOf PRE_first_tail_x15_r0_body.s684 2673467) with
  kind := .array (arrOf PRE_first_tail_x15_r0_body.s0 2673467 ++ (arrOf PRE_first_tail_x15_r0_body.s683 2673467).drop (arrOf PRE_first_tail_x15_r0_body.s0 2673467).length) })
kernel_rfl PRE_first_tail_x15_r0_body.zw77_4910 : (PRE_first_tail_x15_r0_body.s684.heap.get 4910).isSome = true
kernel_rfl PRE_first_tail_x15_r0_body.zw77_2673472 : (PRE_first_tail_x15_r0_body.s684.heap.get 2673472).isSome = true
kernel_rfl PRE_first_tail_x15_r0_body.zw77_2673473 : (PRE_first_tail_x15_r0_body.s684.heap.get 2673473).isSome = true
-- the heap: the changed list in range, holding the stage's written and fresh addresses; the canonical side's image
kernel_rfl PRE_first_tail_x15_r0_body.zclbd77 : PRE_first_tail_x15_r0_body.cl77.all (fun b => Nat.blt (b / 4096) (4 ^ 31)) = true
kernel_rfl PRE_first_tail_x15_r0_body.zwr77 : PRE_first_tail_x15_r0_body.st77.wr.all (fun b => !Nat.blt b PRE_first_tail_x15_r0_body.s682.next || PRE_first_tail_x15_r0_body.cl77.contains b) = true
def PRE_first_tail_x15_r0_body.zl77 : List Nat := PRE_first_tail_x15_r0_body.cl77.filter fun a => !(List.contains [2665, 2673467] a)
kernel_rfl PRE_first_tail_x15_r0_body.zimgE77 : PRE_first_tail_x15_r0_body.zl77.map (fun a => PRE_first_tail_x15_r0_body.s683.heap.get (PRE_first_tail_x15_r0_body.kappa77.a a)) = PRE_first_tail_x15_r0_body.zl77.map (fun a => (PRE_first_tail_x15_r0_body.s684.heap.get a).map PRE_first_tail_x15_r0_body.kappa77.hobj)
theorem PRE_first_tail_x15_r0_body.zimg77 : HeapImg PRE_first_tail_x15_r0_body.kappa77 PRE_first_tail_x15_r0_body.s684 PRE_first_tail_x15_r0_body.s683 PRE_first_tail_x15_r0_body.zl77 := PRE_first_tail_x15_r0_body.zimgE77
-- the roots and their supports
kernel_rfl PRE_first_tail_x15_r0_body.zctl77 : PRE_first_tail_x15_r0_body.s683.ctl = PRE_first_tail_x15_r0_body.kappa77.ctl PRE_first_tail_x15_r0_body.s684.ctl
kernel_rfl PRE_first_tail_x15_r0_body.zstack77 : PRE_first_tail_x15_r0_body.s683.stack = PRE_first_tail_x15_r0_body.s684.stack.map PRE_first_tail_x15_r0_body.kappa77.frame
kernel_rfl PRE_first_tail_x15_r0_body.zjobs77 : PRE_first_tail_x15_r0_body.s683.jobs = PRE_first_tail_x15_r0_body.s684.jobs.map PRE_first_tail_x15_r0_body.kappa77.job
kernel_rfl PRE_first_tail_x15_r0_body.zstores77 : PRE_first_tail_x15_r0_body.s683.stores = PRE_first_tail_x15_r0_body.kappa77.stores PRE_first_tail_x15_r0_body.s684.stores
kernel_rfl PRE_first_tail_x15_r0_body.zroots77 : checkRootsSupp PRE_first_tail_x15_r0_body.s684 3346 = true
kernel_rfl PRE_first_tail_x15_r0_body.znC77 : PRE_first_tail_x15_r0_body.S682.tab.length + PRE_first_tail_x15_r0_body.cws77.length = 3346
-- the map as `Conv.compact_shift` states it (the call's counters for the literals)
kernel_rfl PRE_first_tail_x15_r0_body.zkap77 : PRE_first_tail_x15_r0_body.kappa77 = Conv.Map.compact PRE_first_tail_x15_r0_body.s682.next 2735010 PRE_first_tail_x15_r0_body.S682.tab.length PRE_first_tail_x15_r0_body.pl77 (PRE_first_tail_x15_r0_body.nr77.map NumV.ref) PRE_first_tail_x15_r0_body.kd77.big
  PRE_first_tail_x15_r0_body.kd77.region PRE_first_tail_x15_r0_body.kd77.nodeF
-- the bridge inactive at the canonical state (`Conv.FullShiftQ.toX`; the merged state's bridge is the canonical's: cbridge)
theorem PRE_first_tail_x15_r0_body.zbin77 : (Host.Ts.Sim.Full.bridgeOf PRE_first_tail_x15_r0_body.s684.ffi).active = false := (Host.Load.Boot.replay_active Host.Load.Run.Prompt.P.oblog2818)
-- the JS bookkeeping's step (`Conv.JClean.step` over the changed list) and the canonical roots' bigint freedom
kernel_rfl PRE_first_tail_x15_r0_body.zjc77 : Conv.jcleanListB (⟨19712, 16807, 2735000, 3346⟩ : Conv.Cnt) PRE_first_tail_x15_r0_body.s684 PRE_first_tail_x15_r0_body.cl77 = true
kernel_rfl PRE_first_tail_x15_r0_body.zroots277 : noBigRootsP (fun i => !Conv.oldBigB (⟨19712, 16807, 2735000, 3346⟩ : Conv.Cnt) i) PRE_first_tail_x15_r0_body.s684.trace PRE_first_tail_x15_r0_body.s684 = true
kernel_rfl PRE_first_tail_x15_r0_body.zhm77 : Nat.ble (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s0.ffi).mlx.nnext 16807 = true
theorem PRE_first_tail_x15_r0_body.cjcl77 (h : Conv.JClean (⟨19712, 16807, 2734999, 3346⟩ : Conv.Cnt) PRE_first_tail_x15_r0_body.s682) : Conv.JClean (⟨19712, 16807, 2735000, 3346⟩ : Conv.Cnt) PRE_first_tail_x15_r0_body.s684 :=
  Conv.JClean.step h (Conv.Cnt.le_of_leB PRE_first_tail_x15_r0_body.cle77)
    (Conv.heap_off_setAll PRE_first_tail_x15_r0_body.cheap77 fun a ha => Nat.blt_eq.mp (List.all_eq_true.mp PRE_first_tail_x15_r0_body.zclbd77 a ha)) PRE_first_tail_x15_r0_body.zjc77

end Host.Load.Run.Tpl
