import host.sim.template.a4pre_first_tail_x15_r0_body.SiteS44
import host.sim.template.a4pre_first_tail_x15_r0_body.SiteK44
import host.sim.template.a4pre_first_tail_x15_r0_body.SiteF44
import host.sim.conv.CompactShift
import host.sim.template.Check
import host.sim.BigFreeP
import host.sim.template.CallGen
set_option Elab.async false
namespace Host.Load.Run.Tpl
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
open Host.Ts Host.Ts.Sim Host.Ts.Sim.Template

/-! The compaction's state shift at call site 44 of chain `PRE_first_tail_x15_r0_body` (`Conv.compact_shift`): the call `PRE_first_tail_x15_r0_body.s431`, the merged
state `PRE_first_tail_x15_r0_body.s432`, the canonical state `PRE_first_tail_x15_r0_body.s433`; its frames [2665,2673467,2673472,2673473] (kept arrays [2665,2673467]). -/

-- the map's places and counters
kernel_rfl PRE_first_tail_x15_r0_body.zpl44 : PRE_first_tail_x15_r0_body.pl44.all (Nat.ble PRE_first_tail_x15_r0_body.s431.next) = true
kernel_rfl PRE_first_tail_x15_r0_body.zplnd44 : nodupT PRE_first_tail_x15_r0_body.pl44 PTrie.nil = true
kernel_rfl PRE_first_tail_x15_r0_body.zn144 : Nat.ble PRE_first_tail_x15_r0_body.s431.next 2709014 = true
kernel_rfl PRE_first_tail_x15_r0_body.zfirst44 : Nat.ble aFirst PRE_first_tail_x15_r0_body.s431.next = true
kernel_rfl PRE_first_tail_x15_r0_body.zscn44 : PRE_first_tail_x15_r0_body.s433.next = PRE_first_tail_x15_r0_body.s431.next + PRE_first_tail_x15_r0_body.pl44.length
kernel_rfl PRE_first_tail_x15_r0_body.zsmn44 : PRE_first_tail_x15_r0_body.s432.next = 2709014
kernel_rfl PRE_first_tail_x15_r0_body.zgrow44 : Nat.ble PRE_first_tail_x15_r0_body.s433.next PRE_first_tail_x15_r0_body.s432.next = true
-- the tables
kernel_rfl PRE_first_tail_x15_r0_body.zfresh44 : PRE_first_tail_x15_r0_body.S431.tab.all (fun e => PRE_first_tail_x15_r0_body.cws44.all fun v => e.noVar v) = true
kernel_rfl PRE_first_tail_x15_r0_body.zcnd44 : nodupT PRE_first_tail_x15_r0_body.cws44 PTrie.nil = true
kernel_rfl PRE_first_tail_x15_r0_body.znrHi44 : PRE_first_tail_x15_r0_body.nr44.all (fun r => Nat.blt r PRE_first_tail_x15_r0_body.S432.tab.length) = true
-- the frames: every framed address below the call's counter; the kept arrays the chain start's, extended in the merged state
kernel_rfl PRE_first_tail_x15_r0_body.zfrlt44 : [2665, 2673467, 2673472, 2673473].all (fun a => Nat.blt a PRE_first_tail_x15_r0_body.s431.next) = true
kernel_rfl PRE_first_tail_x15_r0_body.zg44_2665 : PRE_first_tail_x15_r0_body.s433.heap.get 2665 = some (.obj (objOf PRE_first_tail_x15_r0_body.s433 2665))
kernel_rfl PRE_first_tail_x15_r0_body.zk44_2665 : (objOf PRE_first_tail_x15_r0_body.s433 2665).kind = .array (arrOf PRE_first_tail_x15_r0_body.s0 2665)
kernel_rfl PRE_first_tail_x15_r0_body.zm44_2665 : PRE_first_tail_x15_r0_body.s432.heap.get 2665 = some (.obj { PRE_first_tail_x15_r0_body.kappa44.obj (objOf PRE_first_tail_x15_r0_body.s433 2665) with
  kind := .array (arrOf PRE_first_tail_x15_r0_body.s0 2665 ++ (arrOf PRE_first_tail_x15_r0_body.s432 2665).drop (arrOf PRE_first_tail_x15_r0_body.s0 2665).length) })
kernel_rfl PRE_first_tail_x15_r0_body.zg44_2673467 : PRE_first_tail_x15_r0_body.s433.heap.get 2673467 = some (.obj (objOf PRE_first_tail_x15_r0_body.s433 2673467))
kernel_rfl PRE_first_tail_x15_r0_body.zk44_2673467 : (objOf PRE_first_tail_x15_r0_body.s433 2673467).kind = .array (arrOf PRE_first_tail_x15_r0_body.s0 2673467)
kernel_rfl PRE_first_tail_x15_r0_body.zm44_2673467 : PRE_first_tail_x15_r0_body.s432.heap.get 2673467 = some (.obj { PRE_first_tail_x15_r0_body.kappa44.obj (objOf PRE_first_tail_x15_r0_body.s433 2673467) with
  kind := .array (arrOf PRE_first_tail_x15_r0_body.s0 2673467 ++ (arrOf PRE_first_tail_x15_r0_body.s432 2673467).drop (arrOf PRE_first_tail_x15_r0_body.s0 2673467).length) })
kernel_rfl PRE_first_tail_x15_r0_body.zw44_4910 : (PRE_first_tail_x15_r0_body.s433.heap.get 4910).isSome = true
kernel_rfl PRE_first_tail_x15_r0_body.zw44_2673472 : (PRE_first_tail_x15_r0_body.s433.heap.get 2673472).isSome = true
kernel_rfl PRE_first_tail_x15_r0_body.zw44_2673473 : (PRE_first_tail_x15_r0_body.s433.heap.get 2673473).isSome = true
-- the heap: the changed list in range, holding the stage's written and fresh addresses; the canonical side's image
kernel_rfl PRE_first_tail_x15_r0_body.zclbd44 : PRE_first_tail_x15_r0_body.cl44.all (fun b => Nat.blt (b / 4096) (4 ^ 31)) = true
kernel_rfl PRE_first_tail_x15_r0_body.zwr44 : PRE_first_tail_x15_r0_body.st44.wr.all (fun b => !Nat.blt b PRE_first_tail_x15_r0_body.s431.next || PRE_first_tail_x15_r0_body.cl44.contains b) = true
def PRE_first_tail_x15_r0_body.zl44 : List Nat := PRE_first_tail_x15_r0_body.cl44.filter fun a => !(List.contains [2665, 2673467] a)
kernel_rfl PRE_first_tail_x15_r0_body.zimgE44 : PRE_first_tail_x15_r0_body.zl44.map (fun a => PRE_first_tail_x15_r0_body.s432.heap.get (PRE_first_tail_x15_r0_body.kappa44.a a)) = PRE_first_tail_x15_r0_body.zl44.map (fun a => (PRE_first_tail_x15_r0_body.s433.heap.get a).map PRE_first_tail_x15_r0_body.kappa44.hobj)
theorem PRE_first_tail_x15_r0_body.zimg44 : HeapImg PRE_first_tail_x15_r0_body.kappa44 PRE_first_tail_x15_r0_body.s433 PRE_first_tail_x15_r0_body.s432 PRE_first_tail_x15_r0_body.zl44 := PRE_first_tail_x15_r0_body.zimgE44
-- the roots and their supports
kernel_rfl PRE_first_tail_x15_r0_body.zctl44 : PRE_first_tail_x15_r0_body.s432.ctl = PRE_first_tail_x15_r0_body.kappa44.ctl PRE_first_tail_x15_r0_body.s433.ctl
kernel_rfl PRE_first_tail_x15_r0_body.zstack44 : PRE_first_tail_x15_r0_body.s432.stack = PRE_first_tail_x15_r0_body.s433.stack.map PRE_first_tail_x15_r0_body.kappa44.frame
kernel_rfl PRE_first_tail_x15_r0_body.zjobs44 : PRE_first_tail_x15_r0_body.s432.jobs = PRE_first_tail_x15_r0_body.s433.jobs.map PRE_first_tail_x15_r0_body.kappa44.job
kernel_rfl PRE_first_tail_x15_r0_body.zstores44 : PRE_first_tail_x15_r0_body.s432.stores = PRE_first_tail_x15_r0_body.kappa44.stores PRE_first_tail_x15_r0_body.s433.stores
kernel_rfl PRE_first_tail_x15_r0_body.zroots44 : checkRootsSupp PRE_first_tail_x15_r0_body.s433 1936 = true
kernel_rfl PRE_first_tail_x15_r0_body.znC44 : PRE_first_tail_x15_r0_body.S431.tab.length + PRE_first_tail_x15_r0_body.cws44.length = 1936
-- the map as `Conv.compact_shift` states it (the call's counters for the literals)
kernel_rfl PRE_first_tail_x15_r0_body.zkap44 : PRE_first_tail_x15_r0_body.kappa44 = Conv.Map.compact PRE_first_tail_x15_r0_body.s431.next 2709014 PRE_first_tail_x15_r0_body.S431.tab.length PRE_first_tail_x15_r0_body.pl44 (PRE_first_tail_x15_r0_body.nr44.map NumV.ref) PRE_first_tail_x15_r0_body.kd44.big
  PRE_first_tail_x15_r0_body.kd44.region PRE_first_tail_x15_r0_body.kd44.nodeF
-- the bridge inactive at the canonical state (`Conv.FullShiftQ.toX`; the merged state's bridge is the canonical's: cbridge)
theorem PRE_first_tail_x15_r0_body.zbin44 : (Host.Ts.Sim.Full.bridgeOf PRE_first_tail_x15_r0_body.s433.ffi).active = false := (Host.Load.Boot.replay_active Host.Load.Run.Prompt.P.oblog2818)
-- the JS bookkeeping's step (`Conv.JClean.step` over the changed list) and the canonical roots' bigint freedom
kernel_rfl PRE_first_tail_x15_r0_body.zjc44 : Conv.jcleanListB (⟨19061, 16159, 2709004, 1936⟩ : Conv.Cnt) PRE_first_tail_x15_r0_body.s433 PRE_first_tail_x15_r0_body.cl44 = true
kernel_rfl PRE_first_tail_x15_r0_body.zrootsB44 : noBigRootsP (fun i => !Conv.oldBigB (⟨19061, 16159, 2709004, 1936⟩ : Conv.Cnt) i) PRE_first_tail_x15_r0_body.s433.trace PRE_first_tail_x15_r0_body.s433 = true
kernel_rfl PRE_first_tail_x15_r0_body.zhm44 : Nat.ble (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s0.ffi).mlx.nnext 16159 = true
theorem PRE_first_tail_x15_r0_body.cjcl44 (h : Conv.JClean (⟨19061, 16159, 2709003, 1936⟩ : Conv.Cnt) PRE_first_tail_x15_r0_body.s431) : Conv.JClean (⟨19061, 16159, 2709004, 1936⟩ : Conv.Cnt) PRE_first_tail_x15_r0_body.s433 :=
  Conv.JClean.step h (Conv.Cnt.le_of_leB PRE_first_tail_x15_r0_body.cle44)
    (Conv.heap_off_setAll PRE_first_tail_x15_r0_body.cheap44 fun a ha => Nat.blt_eq.mp (List.all_eq_true.mp PRE_first_tail_x15_r0_body.zclbd44 a ha)) PRE_first_tail_x15_r0_body.zjc44

end Host.Load.Run.Tpl
