import host.sim.template.a4pre_first_tail_x15_r0_body.SiteS51
import host.sim.template.a4pre_first_tail_x15_r0_body.SiteK51
import host.sim.template.a4pre_first_tail_x15_r0_body.SiteF51
import host.sim.conv.CompactShift
import host.sim.template.Check
import host.sim.BigFreeP
import host.sim.template.CallGen
set_option Elab.async false
namespace Host.Load.Run.Tpl
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
open Host.Ts Host.Ts.Sim Host.Ts.Sim.Template

/-! The compaction's state shift at call site 51 of chain `PRE_first_tail_x15_r0_body` (`Conv.compact_shift`): the call `PRE_first_tail_x15_r0_body.s505`, the merged
state `PRE_first_tail_x15_r0_body.s506`, the canonical state `PRE_first_tail_x15_r0_body.s507`; its frames [2665,2673467,2673472,2673473] (kept arrays [2665,2673467]). -/

-- the map's places and counters
kernel_rfl PRE_first_tail_x15_r0_body.zpl51 : PRE_first_tail_x15_r0_body.pl51.all (Nat.ble PRE_first_tail_x15_r0_body.s505.next) = true
kernel_rfl PRE_first_tail_x15_r0_body.zplnd51 : nodupT PRE_first_tail_x15_r0_body.pl51 PTrie.nil = true
kernel_rfl PRE_first_tail_x15_r0_body.zn151 : Nat.ble PRE_first_tail_x15_r0_body.s505.next 2716538 = true
kernel_rfl PRE_first_tail_x15_r0_body.zfirst51 : Nat.ble aFirst PRE_first_tail_x15_r0_body.s505.next = true
kernel_rfl PRE_first_tail_x15_r0_body.zscn51 : PRE_first_tail_x15_r0_body.s507.next = PRE_first_tail_x15_r0_body.s505.next + PRE_first_tail_x15_r0_body.pl51.length
kernel_rfl PRE_first_tail_x15_r0_body.zsmn51 : PRE_first_tail_x15_r0_body.s506.next = 2716538
kernel_rfl PRE_first_tail_x15_r0_body.zgrow51 : Nat.ble PRE_first_tail_x15_r0_body.s507.next PRE_first_tail_x15_r0_body.s506.next = true
-- the tables
kernel_rfl PRE_first_tail_x15_r0_body.zfresh51 : PRE_first_tail_x15_r0_body.S505.tab.all (fun e => PRE_first_tail_x15_r0_body.cws51.all fun v => e.noVar v) = true
kernel_rfl PRE_first_tail_x15_r0_body.zcnd51 : nodupT PRE_first_tail_x15_r0_body.cws51 PTrie.nil = true
kernel_rfl PRE_first_tail_x15_r0_body.znrHi51 : PRE_first_tail_x15_r0_body.nr51.all (fun r => Nat.blt r PRE_first_tail_x15_r0_body.S506.tab.length) = true
-- the frames: every framed address below the call's counter; the kept arrays the chain start's, extended in the merged state
kernel_rfl PRE_first_tail_x15_r0_body.zfrlt51 : [2665, 2673467, 2673472, 2673473].all (fun a => Nat.blt a PRE_first_tail_x15_r0_body.s505.next) = true
kernel_rfl PRE_first_tail_x15_r0_body.zg51_2665 : PRE_first_tail_x15_r0_body.s507.heap.get 2665 = some (.obj (objOf PRE_first_tail_x15_r0_body.s507 2665))
kernel_rfl PRE_first_tail_x15_r0_body.zk51_2665 : (objOf PRE_first_tail_x15_r0_body.s507 2665).kind = .array (arrOf PRE_first_tail_x15_r0_body.s0 2665)
kernel_rfl PRE_first_tail_x15_r0_body.zm51_2665 : PRE_first_tail_x15_r0_body.s506.heap.get 2665 = some (.obj { PRE_first_tail_x15_r0_body.kappa51.obj (objOf PRE_first_tail_x15_r0_body.s507 2665) with
  kind := .array (arrOf PRE_first_tail_x15_r0_body.s0 2665 ++ (arrOf PRE_first_tail_x15_r0_body.s506 2665).drop (arrOf PRE_first_tail_x15_r0_body.s0 2665).length) })
kernel_rfl PRE_first_tail_x15_r0_body.zg51_2673467 : PRE_first_tail_x15_r0_body.s507.heap.get 2673467 = some (.obj (objOf PRE_first_tail_x15_r0_body.s507 2673467))
kernel_rfl PRE_first_tail_x15_r0_body.zk51_2673467 : (objOf PRE_first_tail_x15_r0_body.s507 2673467).kind = .array (arrOf PRE_first_tail_x15_r0_body.s0 2673467)
kernel_rfl PRE_first_tail_x15_r0_body.zm51_2673467 : PRE_first_tail_x15_r0_body.s506.heap.get 2673467 = some (.obj { PRE_first_tail_x15_r0_body.kappa51.obj (objOf PRE_first_tail_x15_r0_body.s507 2673467) with
  kind := .array (arrOf PRE_first_tail_x15_r0_body.s0 2673467 ++ (arrOf PRE_first_tail_x15_r0_body.s506 2673467).drop (arrOf PRE_first_tail_x15_r0_body.s0 2673467).length) })
kernel_rfl PRE_first_tail_x15_r0_body.zw51_4910 : (PRE_first_tail_x15_r0_body.s507.heap.get 4910).isSome = true
kernel_rfl PRE_first_tail_x15_r0_body.zw51_2673472 : (PRE_first_tail_x15_r0_body.s507.heap.get 2673472).isSome = true
kernel_rfl PRE_first_tail_x15_r0_body.zw51_2673473 : (PRE_first_tail_x15_r0_body.s507.heap.get 2673473).isSome = true
-- the heap: the changed list in range, holding the stage's written and fresh addresses; the canonical side's image
kernel_rfl PRE_first_tail_x15_r0_body.zclbd51 : PRE_first_tail_x15_r0_body.cl51.all (fun b => Nat.blt (b / 4096) (4 ^ 31)) = true
kernel_rfl PRE_first_tail_x15_r0_body.zwr51 : PRE_first_tail_x15_r0_body.st51.wr.all (fun b => !Nat.blt b PRE_first_tail_x15_r0_body.s505.next || PRE_first_tail_x15_r0_body.cl51.contains b) = true
def PRE_first_tail_x15_r0_body.zl51 : List Nat := PRE_first_tail_x15_r0_body.cl51.filter fun a => !(List.contains [2665, 2673467] a)
kernel_rfl PRE_first_tail_x15_r0_body.zimgE51 : PRE_first_tail_x15_r0_body.zl51.map (fun a => PRE_first_tail_x15_r0_body.s506.heap.get (PRE_first_tail_x15_r0_body.kappa51.a a)) = PRE_first_tail_x15_r0_body.zl51.map (fun a => (PRE_first_tail_x15_r0_body.s507.heap.get a).map PRE_first_tail_x15_r0_body.kappa51.hobj)
theorem PRE_first_tail_x15_r0_body.zimg51 : HeapImg PRE_first_tail_x15_r0_body.kappa51 PRE_first_tail_x15_r0_body.s507 PRE_first_tail_x15_r0_body.s506 PRE_first_tail_x15_r0_body.zl51 := PRE_first_tail_x15_r0_body.zimgE51
-- the roots and their supports
kernel_rfl PRE_first_tail_x15_r0_body.zctl51 : PRE_first_tail_x15_r0_body.s506.ctl = PRE_first_tail_x15_r0_body.kappa51.ctl PRE_first_tail_x15_r0_body.s507.ctl
kernel_rfl PRE_first_tail_x15_r0_body.zstack51 : PRE_first_tail_x15_r0_body.s506.stack = PRE_first_tail_x15_r0_body.s507.stack.map PRE_first_tail_x15_r0_body.kappa51.frame
kernel_rfl PRE_first_tail_x15_r0_body.zjobs51 : PRE_first_tail_x15_r0_body.s506.jobs = PRE_first_tail_x15_r0_body.s507.jobs.map PRE_first_tail_x15_r0_body.kappa51.job
kernel_rfl PRE_first_tail_x15_r0_body.zstores51 : PRE_first_tail_x15_r0_body.s506.stores = PRE_first_tail_x15_r0_body.kappa51.stores PRE_first_tail_x15_r0_body.s507.stores
kernel_rfl PRE_first_tail_x15_r0_body.zroots51 : checkRootsSupp PRE_first_tail_x15_r0_body.s507 2282 = true
kernel_rfl PRE_first_tail_x15_r0_body.znC51 : PRE_first_tail_x15_r0_body.S505.tab.length + PRE_first_tail_x15_r0_body.cws51.length = 2282
-- the map as `Conv.compact_shift` states it (the call's counters for the literals)
kernel_rfl PRE_first_tail_x15_r0_body.zkap51 : PRE_first_tail_x15_r0_body.kappa51 = Conv.Map.compact PRE_first_tail_x15_r0_body.s505.next 2716538 PRE_first_tail_x15_r0_body.S505.tab.length PRE_first_tail_x15_r0_body.pl51 (PRE_first_tail_x15_r0_body.nr51.map NumV.ref) PRE_first_tail_x15_r0_body.kd51.big
  PRE_first_tail_x15_r0_body.kd51.region PRE_first_tail_x15_r0_body.kd51.nodeF
-- the bridge inactive at the canonical state (`Conv.FullShiftQ.toX`; the merged state's bridge is the canonical's: cbridge)
theorem PRE_first_tail_x15_r0_body.zbin51 : (Host.Ts.Sim.Full.bridgeOf PRE_first_tail_x15_r0_body.s507.ffi).active = false := (Host.Load.Boot.replay_active Host.Load.Run.Prompt.P.oblog2818)
-- the JS bookkeeping's step (`Conv.JClean.step` over the changed list) and the canonical roots' bigint freedom
kernel_rfl PRE_first_tail_x15_r0_body.zjc51 : Conv.jcleanListB (⟨19220, 16316, 2715389, 2282⟩ : Conv.Cnt) PRE_first_tail_x15_r0_body.s507 PRE_first_tail_x15_r0_body.cl51 = true
kernel_rfl PRE_first_tail_x15_r0_body.zrootsB51 : noBigRootsP (fun i => !Conv.oldBigB (⟨19220, 16316, 2715389, 2282⟩ : Conv.Cnt) i) PRE_first_tail_x15_r0_body.s507.trace PRE_first_tail_x15_r0_body.s507 = true
kernel_rfl PRE_first_tail_x15_r0_body.zhm51 : Nat.ble (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s0.ffi).mlx.nnext 16289 = true
theorem PRE_first_tail_x15_r0_body.cjcl51 (h : Conv.JClean (⟨19217, 16289, 2715383, 2264⟩ : Conv.Cnt) PRE_first_tail_x15_r0_body.s505) : Conv.JClean (⟨19220, 16316, 2715389, 2282⟩ : Conv.Cnt) PRE_first_tail_x15_r0_body.s507 :=
  Conv.JClean.step h (Conv.Cnt.le_of_leB PRE_first_tail_x15_r0_body.cle51)
    (Conv.heap_off_setAll PRE_first_tail_x15_r0_body.cheap51 fun a ha => Nat.blt_eq.mp (List.all_eq_true.mp PRE_first_tail_x15_r0_body.zclbd51 a ha)) PRE_first_tail_x15_r0_body.zjc51

end Host.Load.Run.Tpl
