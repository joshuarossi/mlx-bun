import host.sim.template.a4pre_first_tail_x15_r0_body.SiteS97
import host.sim.template.a4pre_first_tail_x15_r0_body.SiteK97
import host.sim.template.a4pre_first_tail_x15_r0_body.SiteF97
import host.sim.conv.CompactShift
import host.sim.template.Check
import host.sim.BigFreeP
import host.sim.template.CallGen
set_option Elab.async false
namespace Host.Load.Run.Tpl
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
open Host.Ts Host.Ts.Sim Host.Ts.Sim.Template

/-! The compaction's state shift at call site 97 of chain `PRE_first_tail_x15_r0_body` (`Conv.compact_shift`): the call `PRE_first_tail_x15_r0_body.s944`, the merged
state `PRE_first_tail_x15_r0_body.s945`, the canonical state `PRE_first_tail_x15_r0_body.s946`; its frames [2665,2673467,2673472,2673473] (kept arrays [2665,2673467]). -/

-- the map's places and counters
kernel_rfl PRE_first_tail_x15_r0_body.zpl97 : PRE_first_tail_x15_r0_body.pl97.all (Nat.ble PRE_first_tail_x15_r0_body.s944.next) = true
kernel_rfl PRE_first_tail_x15_r0_body.zplnd97 : nodupT PRE_first_tail_x15_r0_body.pl97 PTrie.nil = true
kernel_rfl PRE_first_tail_x15_r0_body.zn197 : Nat.ble PRE_first_tail_x15_r0_body.s944.next 2751289 = true
kernel_rfl PRE_first_tail_x15_r0_body.zfirst97 : Nat.ble aFirst PRE_first_tail_x15_r0_body.s944.next = true
kernel_rfl PRE_first_tail_x15_r0_body.zscn97 : PRE_first_tail_x15_r0_body.s946.next = PRE_first_tail_x15_r0_body.s944.next + PRE_first_tail_x15_r0_body.pl97.length
kernel_rfl PRE_first_tail_x15_r0_body.zsmn97 : PRE_first_tail_x15_r0_body.s945.next = 2751289
kernel_rfl PRE_first_tail_x15_r0_body.zgrow97 : Nat.ble PRE_first_tail_x15_r0_body.s946.next PRE_first_tail_x15_r0_body.s945.next = true
-- the tables
kernel_rfl PRE_first_tail_x15_r0_body.zfresh97 : PRE_first_tail_x15_r0_body.S944.tab.all (fun e => PRE_first_tail_x15_r0_body.cws97.all fun v => e.noVar v) = true
kernel_rfl PRE_first_tail_x15_r0_body.zcnd97 : nodupT PRE_first_tail_x15_r0_body.cws97 PTrie.nil = true
kernel_rfl PRE_first_tail_x15_r0_body.znrHi97 : PRE_first_tail_x15_r0_body.nr97.all (fun r => Nat.blt r PRE_first_tail_x15_r0_body.S945.tab.length) = true
-- the frames: every framed address below the call's counter; the kept arrays the chain start's, extended in the merged state
kernel_rfl PRE_first_tail_x15_r0_body.zfrlt97 : [2665, 2673467, 2673472, 2673473].all (fun a => Nat.blt a PRE_first_tail_x15_r0_body.s944.next) = true
kernel_rfl PRE_first_tail_x15_r0_body.zg97_2665 : PRE_first_tail_x15_r0_body.s946.heap.get 2665 = some (.obj (objOf PRE_first_tail_x15_r0_body.s946 2665))
kernel_rfl PRE_first_tail_x15_r0_body.zk97_2665 : (objOf PRE_first_tail_x15_r0_body.s946 2665).kind = .array (arrOf PRE_first_tail_x15_r0_body.s0 2665)
kernel_rfl PRE_first_tail_x15_r0_body.zm97_2665 : PRE_first_tail_x15_r0_body.s945.heap.get 2665 = some (.obj { PRE_first_tail_x15_r0_body.kappa97.obj (objOf PRE_first_tail_x15_r0_body.s946 2665) with
  kind := .array (arrOf PRE_first_tail_x15_r0_body.s0 2665 ++ (arrOf PRE_first_tail_x15_r0_body.s945 2665).drop (arrOf PRE_first_tail_x15_r0_body.s0 2665).length) })
kernel_rfl PRE_first_tail_x15_r0_body.zg97_2673467 : PRE_first_tail_x15_r0_body.s946.heap.get 2673467 = some (.obj (objOf PRE_first_tail_x15_r0_body.s946 2673467))
kernel_rfl PRE_first_tail_x15_r0_body.zk97_2673467 : (objOf PRE_first_tail_x15_r0_body.s946 2673467).kind = .array (arrOf PRE_first_tail_x15_r0_body.s0 2673467)
kernel_rfl PRE_first_tail_x15_r0_body.zm97_2673467 : PRE_first_tail_x15_r0_body.s945.heap.get 2673467 = some (.obj { PRE_first_tail_x15_r0_body.kappa97.obj (objOf PRE_first_tail_x15_r0_body.s946 2673467) with
  kind := .array (arrOf PRE_first_tail_x15_r0_body.s0 2673467 ++ (arrOf PRE_first_tail_x15_r0_body.s945 2673467).drop (arrOf PRE_first_tail_x15_r0_body.s0 2673467).length) })
kernel_rfl PRE_first_tail_x15_r0_body.zw97_4910 : (PRE_first_tail_x15_r0_body.s946.heap.get 4910).isSome = true
kernel_rfl PRE_first_tail_x15_r0_body.zw97_2673472 : (PRE_first_tail_x15_r0_body.s946.heap.get 2673472).isSome = true
kernel_rfl PRE_first_tail_x15_r0_body.zw97_2673473 : (PRE_first_tail_x15_r0_body.s946.heap.get 2673473).isSome = true
-- the heap: the changed list in range, holding the stage's written and fresh addresses; the canonical side's image
kernel_rfl PRE_first_tail_x15_r0_body.zclbd97 : PRE_first_tail_x15_r0_body.cl97.all (fun b => Nat.blt (b / 4096) (4 ^ 31)) = true
kernel_rfl PRE_first_tail_x15_r0_body.zwr97 : PRE_first_tail_x15_r0_body.st97.wr.all (fun b => !Nat.blt b PRE_first_tail_x15_r0_body.s944.next || PRE_first_tail_x15_r0_body.cl97.contains b) = true
def PRE_first_tail_x15_r0_body.zl97 : List Nat := PRE_first_tail_x15_r0_body.cl97.filter fun a => !(List.contains [2665, 2673467] a)
kernel_rfl PRE_first_tail_x15_r0_body.zimgE97 : PRE_first_tail_x15_r0_body.zl97.map (fun a => PRE_first_tail_x15_r0_body.s945.heap.get (PRE_first_tail_x15_r0_body.kappa97.a a)) = PRE_first_tail_x15_r0_body.zl97.map (fun a => (PRE_first_tail_x15_r0_body.s946.heap.get a).map PRE_first_tail_x15_r0_body.kappa97.hobj)
theorem PRE_first_tail_x15_r0_body.zimg97 : HeapImg PRE_first_tail_x15_r0_body.kappa97 PRE_first_tail_x15_r0_body.s946 PRE_first_tail_x15_r0_body.s945 PRE_first_tail_x15_r0_body.zl97 := PRE_first_tail_x15_r0_body.zimgE97
-- the roots and their supports
kernel_rfl PRE_first_tail_x15_r0_body.zctl97 : PRE_first_tail_x15_r0_body.s945.ctl = PRE_first_tail_x15_r0_body.kappa97.ctl PRE_first_tail_x15_r0_body.s946.ctl
kernel_rfl PRE_first_tail_x15_r0_body.zstack97 : PRE_first_tail_x15_r0_body.s945.stack = PRE_first_tail_x15_r0_body.s946.stack.map PRE_first_tail_x15_r0_body.kappa97.frame
kernel_rfl PRE_first_tail_x15_r0_body.zjobs97 : PRE_first_tail_x15_r0_body.s945.jobs = PRE_first_tail_x15_r0_body.s946.jobs.map PRE_first_tail_x15_r0_body.kappa97.job
kernel_rfl PRE_first_tail_x15_r0_body.zstores97 : PRE_first_tail_x15_r0_body.s945.stores = PRE_first_tail_x15_r0_body.kappa97.stores PRE_first_tail_x15_r0_body.s946.stores
kernel_rfl PRE_first_tail_x15_r0_body.zroots97 : checkRootsSupp PRE_first_tail_x15_r0_body.s946 4226 = true
kernel_rfl PRE_first_tail_x15_r0_body.znC97 : PRE_first_tail_x15_r0_body.S944.tab.length + PRE_first_tail_x15_r0_body.cws97.length = 4226
-- the map as `Conv.compact_shift` states it (the call's counters for the literals)
kernel_rfl PRE_first_tail_x15_r0_body.zkap97 : PRE_first_tail_x15_r0_body.kappa97 = Conv.Map.compact PRE_first_tail_x15_r0_body.s944.next 2751289 PRE_first_tail_x15_r0_body.S944.tab.length PRE_first_tail_x15_r0_body.pl97 (PRE_first_tail_x15_r0_body.nr97.map NumV.ref) PRE_first_tail_x15_r0_body.kd97.big
  PRE_first_tail_x15_r0_body.kd97.region PRE_first_tail_x15_r0_body.kd97.nodeF
-- the bridge inactive at the canonical state (`Conv.FullShiftQ.toX`; the merged state's bridge is the canonical's: cbridge)
theorem PRE_first_tail_x15_r0_body.zbin97 : (Host.Ts.Sim.Full.bridgeOf PRE_first_tail_x15_r0_body.s946.ffi).active = false := (Host.Load.Boot.replay_active Host.Load.Run.Prompt.P.oblog2818)
-- the JS bookkeeping's step (`Conv.JClean.step` over the changed list) and the canonical roots' bigint freedom
kernel_rfl PRE_first_tail_x15_r0_body.zjc97 : Conv.jcleanListB (⟨20120, 17214, 2751287, 4226⟩ : Conv.Cnt) PRE_first_tail_x15_r0_body.s946 PRE_first_tail_x15_r0_body.cl97 = true
kernel_rfl PRE_first_tail_x15_r0_body.zrootsB97 : noBigRootsP (fun i => !Conv.oldBigB (⟨20120, 17214, 2751287, 4226⟩ : Conv.Cnt) i) PRE_first_tail_x15_r0_body.s946.trace PRE_first_tail_x15_r0_body.s946 = true
kernel_rfl PRE_first_tail_x15_r0_body.zhm97 : Nat.ble (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s0.ffi).mlx.nnext 17214 = true
theorem PRE_first_tail_x15_r0_body.cjcl97 (h : Conv.JClean (⟨20120, 17214, 2751287, 4226⟩ : Conv.Cnt) PRE_first_tail_x15_r0_body.s944) : Conv.JClean (⟨20120, 17214, 2751287, 4226⟩ : Conv.Cnt) PRE_first_tail_x15_r0_body.s946 :=
  Conv.JClean.step h (Conv.Cnt.le_of_leB PRE_first_tail_x15_r0_body.cle97)
    (Conv.heap_off_setAll PRE_first_tail_x15_r0_body.cheap97 fun a ha => Nat.blt_eq.mp (List.all_eq_true.mp PRE_first_tail_x15_r0_body.zclbd97 a ha)) PRE_first_tail_x15_r0_body.zjc97

end Host.Load.Run.Tpl
