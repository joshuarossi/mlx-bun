import host.sim.template.a4pre_first_tail_x15_r0_body.SiteS7
import host.sim.template.a4pre_first_tail_x15_r0_body.SiteK7
import host.sim.template.a4pre_first_tail_x15_r0_body.SiteF7
import host.sim.conv.CompactShift
import host.sim.template.Check
import host.sim.BigFreeP
import host.sim.template.CallGen
set_option Elab.async false
namespace Host.Load.Run.Tpl
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
open Host.Ts Host.Ts.Sim Host.Ts.Sim.Template

/-! The compaction's state shift at call site 7 of chain `PRE_first_tail_x15_r0_body` (`Conv.compact_shift`): the call `PRE_first_tail_x15_r0_body.s82`, the merged
state `PRE_first_tail_x15_r0_body.s83`, the canonical state `PRE_first_tail_x15_r0_body.s84`; its frames [2665,2673467,2673472,2673473] (kept arrays [2665,2673467]). -/

-- the map's places and counters
kernel_rfl PRE_first_tail_x15_r0_body.zpl7 : PRE_first_tail_x15_r0_body.pl7.all (Nat.ble PRE_first_tail_x15_r0_body.s82.next) = true
kernel_rfl PRE_first_tail_x15_r0_body.zplnd7 : nodupT PRE_first_tail_x15_r0_body.pl7 PTrie.nil = true
kernel_rfl PRE_first_tail_x15_r0_body.zn17 : Nat.ble PRE_first_tail_x15_r0_body.s82.next 2680471 = true
kernel_rfl PRE_first_tail_x15_r0_body.zfirst7 : Nat.ble aFirst PRE_first_tail_x15_r0_body.s82.next = true
kernel_rfl PRE_first_tail_x15_r0_body.zscn7 : PRE_first_tail_x15_r0_body.s84.next = PRE_first_tail_x15_r0_body.s82.next + PRE_first_tail_x15_r0_body.pl7.length
kernel_rfl PRE_first_tail_x15_r0_body.zsmn7 : PRE_first_tail_x15_r0_body.s83.next = 2680471
kernel_rfl PRE_first_tail_x15_r0_body.zgrow7 : Nat.ble PRE_first_tail_x15_r0_body.s84.next PRE_first_tail_x15_r0_body.s83.next = true
-- the tables
kernel_rfl PRE_first_tail_x15_r0_body.zfresh7 : PRE_first_tail_x15_r0_body.S82.tab.all (fun e => PRE_first_tail_x15_r0_body.cws7.all fun v => e.noVar v) = true
kernel_rfl PRE_first_tail_x15_r0_body.zcnd7 : nodupT PRE_first_tail_x15_r0_body.cws7 PTrie.nil = true
kernel_rfl PRE_first_tail_x15_r0_body.znrHi7 : PRE_first_tail_x15_r0_body.nr7.all (fun r => Nat.blt r PRE_first_tail_x15_r0_body.S83.tab.length) = true
-- the frames: every framed address below the call's counter; the kept arrays the chain start's, extended in the merged state
kernel_rfl PRE_first_tail_x15_r0_body.zfrlt7 : [2665, 2673467, 2673472, 2673473].all (fun a => Nat.blt a PRE_first_tail_x15_r0_body.s82.next) = true
kernel_rfl PRE_first_tail_x15_r0_body.zg7_2665 : PRE_first_tail_x15_r0_body.s84.heap.get 2665 = some (.obj (objOf PRE_first_tail_x15_r0_body.s84 2665))
kernel_rfl PRE_first_tail_x15_r0_body.zk7_2665 : (objOf PRE_first_tail_x15_r0_body.s84 2665).kind = .array (arrOf PRE_first_tail_x15_r0_body.s0 2665)
kernel_rfl PRE_first_tail_x15_r0_body.zm7_2665 : PRE_first_tail_x15_r0_body.s83.heap.get 2665 = some (.obj { PRE_first_tail_x15_r0_body.kappa7.obj (objOf PRE_first_tail_x15_r0_body.s84 2665) with
  kind := .array (arrOf PRE_first_tail_x15_r0_body.s0 2665 ++ (arrOf PRE_first_tail_x15_r0_body.s83 2665).drop (arrOf PRE_first_tail_x15_r0_body.s0 2665).length) })
kernel_rfl PRE_first_tail_x15_r0_body.zg7_2673467 : PRE_first_tail_x15_r0_body.s84.heap.get 2673467 = some (.obj (objOf PRE_first_tail_x15_r0_body.s84 2673467))
kernel_rfl PRE_first_tail_x15_r0_body.zk7_2673467 : (objOf PRE_first_tail_x15_r0_body.s84 2673467).kind = .array (arrOf PRE_first_tail_x15_r0_body.s0 2673467)
kernel_rfl PRE_first_tail_x15_r0_body.zm7_2673467 : PRE_first_tail_x15_r0_body.s83.heap.get 2673467 = some (.obj { PRE_first_tail_x15_r0_body.kappa7.obj (objOf PRE_first_tail_x15_r0_body.s84 2673467) with
  kind := .array (arrOf PRE_first_tail_x15_r0_body.s0 2673467 ++ (arrOf PRE_first_tail_x15_r0_body.s83 2673467).drop (arrOf PRE_first_tail_x15_r0_body.s0 2673467).length) })
kernel_rfl PRE_first_tail_x15_r0_body.zw7_4910 : (PRE_first_tail_x15_r0_body.s84.heap.get 4910).isSome = true
kernel_rfl PRE_first_tail_x15_r0_body.zw7_2673472 : (PRE_first_tail_x15_r0_body.s84.heap.get 2673472).isSome = true
kernel_rfl PRE_first_tail_x15_r0_body.zw7_2673473 : (PRE_first_tail_x15_r0_body.s84.heap.get 2673473).isSome = true
-- the heap: the changed list in range, holding the stage's written and fresh addresses; the canonical side's image
kernel_rfl PRE_first_tail_x15_r0_body.zclbd7 : PRE_first_tail_x15_r0_body.cl7.all (fun b => Nat.blt (b / 4096) (4 ^ 31)) = true
kernel_rfl PRE_first_tail_x15_r0_body.zwr7 : PRE_first_tail_x15_r0_body.st7.wr.all (fun b => !Nat.blt b PRE_first_tail_x15_r0_body.s82.next || PRE_first_tail_x15_r0_body.cl7.contains b) = true
def PRE_first_tail_x15_r0_body.zl7 : List Nat := PRE_first_tail_x15_r0_body.cl7.filter fun a => !(List.contains [2665, 2673467] a)
kernel_rfl PRE_first_tail_x15_r0_body.zimgE7 : PRE_first_tail_x15_r0_body.zl7.map (fun a => PRE_first_tail_x15_r0_body.s83.heap.get (PRE_first_tail_x15_r0_body.kappa7.a a)) = PRE_first_tail_x15_r0_body.zl7.map (fun a => (PRE_first_tail_x15_r0_body.s84.heap.get a).map PRE_first_tail_x15_r0_body.kappa7.hobj)
theorem PRE_first_tail_x15_r0_body.zimg7 : HeapImg PRE_first_tail_x15_r0_body.kappa7 PRE_first_tail_x15_r0_body.s84 PRE_first_tail_x15_r0_body.s83 PRE_first_tail_x15_r0_body.zl7 := PRE_first_tail_x15_r0_body.zimgE7
-- the roots and their supports
kernel_rfl PRE_first_tail_x15_r0_body.zctl7 : PRE_first_tail_x15_r0_body.s83.ctl = PRE_first_tail_x15_r0_body.kappa7.ctl PRE_first_tail_x15_r0_body.s84.ctl
kernel_rfl PRE_first_tail_x15_r0_body.zstack7 : PRE_first_tail_x15_r0_body.s83.stack = PRE_first_tail_x15_r0_body.s84.stack.map PRE_first_tail_x15_r0_body.kappa7.frame
kernel_rfl PRE_first_tail_x15_r0_body.zjobs7 : PRE_first_tail_x15_r0_body.s83.jobs = PRE_first_tail_x15_r0_body.s84.jobs.map PRE_first_tail_x15_r0_body.kappa7.job
kernel_rfl PRE_first_tail_x15_r0_body.zstores7 : PRE_first_tail_x15_r0_body.s83.stores = PRE_first_tail_x15_r0_body.kappa7.stores PRE_first_tail_x15_r0_body.s84.stores
kernel_rfl PRE_first_tail_x15_r0_body.zroots7 : checkRootsSupp PRE_first_tail_x15_r0_body.s84 380 = true
kernel_rfl PRE_first_tail_x15_r0_body.znC7 : PRE_first_tail_x15_r0_body.S82.tab.length + PRE_first_tail_x15_r0_body.cws7.length = 380
-- the map as `Conv.compact_shift` states it (the call's counters for the literals)
kernel_rfl PRE_first_tail_x15_r0_body.zkap7 : PRE_first_tail_x15_r0_body.kappa7 = Conv.Map.compact PRE_first_tail_x15_r0_body.s82.next 2680471 PRE_first_tail_x15_r0_body.S82.tab.length PRE_first_tail_x15_r0_body.pl7 (PRE_first_tail_x15_r0_body.nr7.map NumV.ref) PRE_first_tail_x15_r0_body.kd7.big
  PRE_first_tail_x15_r0_body.kd7.region PRE_first_tail_x15_r0_body.kd7.nodeF
-- the bridge inactive at the canonical state (`Conv.FullShiftQ.toX`; the merged state's bridge is the canonical's: cbridge)
theorem PRE_first_tail_x15_r0_body.zbin7 : (Host.Ts.Sim.Full.bridgeOf PRE_first_tail_x15_r0_body.s84.ffi).active = false := (Host.Load.Boot.replay_active Host.Load.Run.Prompt.P.oblog2818)
-- the JS bookkeeping's step (`Conv.JClean.step` over the changed list) and the canonical roots' bigint freedom
kernel_rfl PRE_first_tail_x15_r0_body.zjc7 : Conv.jcleanListB (⟨18346, 15444, 2680469, 380⟩ : Conv.Cnt) PRE_first_tail_x15_r0_body.s84 PRE_first_tail_x15_r0_body.cl7 = true
kernel_rfl PRE_first_tail_x15_r0_body.zrootsB7 : noBigRootsP (fun i => !Conv.oldBigB (⟨18346, 15444, 2680469, 380⟩ : Conv.Cnt) i) PRE_first_tail_x15_r0_body.s84.trace PRE_first_tail_x15_r0_body.s84 = true
kernel_rfl PRE_first_tail_x15_r0_body.zhm7 : Nat.ble (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s0.ffi).mlx.nnext 15444 = true
theorem PRE_first_tail_x15_r0_body.cjcl7 (h : Conv.JClean (⟨18346, 15444, 2680469, 380⟩ : Conv.Cnt) PRE_first_tail_x15_r0_body.s82) : Conv.JClean (⟨18346, 15444, 2680469, 380⟩ : Conv.Cnt) PRE_first_tail_x15_r0_body.s84 :=
  Conv.JClean.step h (Conv.Cnt.le_of_leB PRE_first_tail_x15_r0_body.cle7)
    (Conv.heap_off_setAll PRE_first_tail_x15_r0_body.cheap7 fun a ha => Nat.blt_eq.mp (List.all_eq_true.mp PRE_first_tail_x15_r0_body.zclbd7 a ha)) PRE_first_tail_x15_r0_body.zjc7

end Host.Load.Run.Tpl
