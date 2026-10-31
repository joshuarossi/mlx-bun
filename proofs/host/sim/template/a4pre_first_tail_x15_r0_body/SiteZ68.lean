import host.sim.template.a4pre_first_tail_x15_r0_body.SiteS68
import host.sim.template.a4pre_first_tail_x15_r0_body.SiteK68
import host.sim.template.a4pre_first_tail_x15_r0_body.SiteF68
import host.sim.conv.CompactShift
import host.sim.template.Check
import host.sim.BigFreeP
import host.sim.template.CallGen
set_option Elab.async false
namespace Host.Load.Run.Tpl
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
open Host.Ts Host.Ts.Sim Host.Ts.Sim.Template

/-! The compaction's state shift at call site 68 of chain `PRE_first_tail_x15_r0_body` (`Conv.compact_shift`): the call `PRE_first_tail_x15_r0_body.s661`, the merged
state `PRE_first_tail_x15_r0_body.s662`, the canonical state `PRE_first_tail_x15_r0_body.s663`; its frames [2665,2673467,2673472,2673473] (kept arrays [2665,2673467]). -/

-- the map's places and counters
kernel_rfl PRE_first_tail_x15_r0_body.zpl68 : PRE_first_tail_x15_r0_body.pl68.all (Nat.ble PRE_first_tail_x15_r0_body.s661.next) = true
kernel_rfl PRE_first_tail_x15_r0_body.zplnd68 : nodupT PRE_first_tail_x15_r0_body.pl68 PTrie.nil = true
kernel_rfl PRE_first_tail_x15_r0_body.zn168 : Nat.ble PRE_first_tail_x15_r0_body.s661.next 2727854 = true
kernel_rfl PRE_first_tail_x15_r0_body.zfirst68 : Nat.ble aFirst PRE_first_tail_x15_r0_body.s661.next = true
kernel_rfl PRE_first_tail_x15_r0_body.zscn68 : PRE_first_tail_x15_r0_body.s663.next = PRE_first_tail_x15_r0_body.s661.next + PRE_first_tail_x15_r0_body.pl68.length
kernel_rfl PRE_first_tail_x15_r0_body.zsmn68 : PRE_first_tail_x15_r0_body.s662.next = 2727854
kernel_rfl PRE_first_tail_x15_r0_body.zgrow68 : Nat.ble PRE_first_tail_x15_r0_body.s663.next PRE_first_tail_x15_r0_body.s662.next = true
-- the tables
kernel_rfl PRE_first_tail_x15_r0_body.zfresh68 : PRE_first_tail_x15_r0_body.S661.tab.all (fun e => PRE_first_tail_x15_r0_body.cws68.all fun v => e.noVar v) = true
kernel_rfl PRE_first_tail_x15_r0_body.zcnd68 : nodupT PRE_first_tail_x15_r0_body.cws68 PTrie.nil = true
kernel_rfl PRE_first_tail_x15_r0_body.znrHi68 : PRE_first_tail_x15_r0_body.nr68.all (fun r => Nat.blt r PRE_first_tail_x15_r0_body.S662.tab.length) = true
-- the frames: every framed address below the call's counter; the kept arrays the chain start's, extended in the merged state
kernel_rfl PRE_first_tail_x15_r0_body.zfrlt68 : [2665, 2673467, 2673472, 2673473].all (fun a => Nat.blt a PRE_first_tail_x15_r0_body.s661.next) = true
kernel_rfl PRE_first_tail_x15_r0_body.zg68_2665 : PRE_first_tail_x15_r0_body.s663.heap.get 2665 = some (.obj (objOf PRE_first_tail_x15_r0_body.s663 2665))
kernel_rfl PRE_first_tail_x15_r0_body.zk68_2665 : (objOf PRE_first_tail_x15_r0_body.s663 2665).kind = .array (arrOf PRE_first_tail_x15_r0_body.s0 2665)
kernel_rfl PRE_first_tail_x15_r0_body.zm68_2665 : PRE_first_tail_x15_r0_body.s662.heap.get 2665 = some (.obj { PRE_first_tail_x15_r0_body.kappa68.obj (objOf PRE_first_tail_x15_r0_body.s663 2665) with
  kind := .array (arrOf PRE_first_tail_x15_r0_body.s0 2665 ++ (arrOf PRE_first_tail_x15_r0_body.s662 2665).drop (arrOf PRE_first_tail_x15_r0_body.s0 2665).length) })
kernel_rfl PRE_first_tail_x15_r0_body.zg68_2673467 : PRE_first_tail_x15_r0_body.s663.heap.get 2673467 = some (.obj (objOf PRE_first_tail_x15_r0_body.s663 2673467))
kernel_rfl PRE_first_tail_x15_r0_body.zk68_2673467 : (objOf PRE_first_tail_x15_r0_body.s663 2673467).kind = .array (arrOf PRE_first_tail_x15_r0_body.s0 2673467)
kernel_rfl PRE_first_tail_x15_r0_body.zm68_2673467 : PRE_first_tail_x15_r0_body.s662.heap.get 2673467 = some (.obj { PRE_first_tail_x15_r0_body.kappa68.obj (objOf PRE_first_tail_x15_r0_body.s663 2673467) with
  kind := .array (arrOf PRE_first_tail_x15_r0_body.s0 2673467 ++ (arrOf PRE_first_tail_x15_r0_body.s662 2673467).drop (arrOf PRE_first_tail_x15_r0_body.s0 2673467).length) })
kernel_rfl PRE_first_tail_x15_r0_body.zw68_4910 : (PRE_first_tail_x15_r0_body.s663.heap.get 4910).isSome = true
kernel_rfl PRE_first_tail_x15_r0_body.zw68_2673472 : (PRE_first_tail_x15_r0_body.s663.heap.get 2673472).isSome = true
kernel_rfl PRE_first_tail_x15_r0_body.zw68_2673473 : (PRE_first_tail_x15_r0_body.s663.heap.get 2673473).isSome = true
-- the heap: the changed list in range, holding the stage's written and fresh addresses; the canonical side's image
kernel_rfl PRE_first_tail_x15_r0_body.zclbd68 : PRE_first_tail_x15_r0_body.cl68.all (fun b => Nat.blt (b / 4096) (4 ^ 31)) = true
kernel_rfl PRE_first_tail_x15_r0_body.zwr68 : PRE_first_tail_x15_r0_body.st68.wr.all (fun b => !Nat.blt b PRE_first_tail_x15_r0_body.s661.next || PRE_first_tail_x15_r0_body.cl68.contains b) = true
def PRE_first_tail_x15_r0_body.zl68 : List Nat := PRE_first_tail_x15_r0_body.cl68.filter fun a => !(List.contains [2665, 2673467] a)
kernel_rfl PRE_first_tail_x15_r0_body.zimgE68 : PRE_first_tail_x15_r0_body.zl68.map (fun a => PRE_first_tail_x15_r0_body.s662.heap.get (PRE_first_tail_x15_r0_body.kappa68.a a)) = PRE_first_tail_x15_r0_body.zl68.map (fun a => (PRE_first_tail_x15_r0_body.s663.heap.get a).map PRE_first_tail_x15_r0_body.kappa68.hobj)
theorem PRE_first_tail_x15_r0_body.zimg68 : HeapImg PRE_first_tail_x15_r0_body.kappa68 PRE_first_tail_x15_r0_body.s663 PRE_first_tail_x15_r0_body.s662 PRE_first_tail_x15_r0_body.zl68 := PRE_first_tail_x15_r0_body.zimgE68
-- the roots and their supports
kernel_rfl PRE_first_tail_x15_r0_body.zctl68 : PRE_first_tail_x15_r0_body.s662.ctl = PRE_first_tail_x15_r0_body.kappa68.ctl PRE_first_tail_x15_r0_body.s663.ctl
kernel_rfl PRE_first_tail_x15_r0_body.zstack68 : PRE_first_tail_x15_r0_body.s662.stack = PRE_first_tail_x15_r0_body.s663.stack.map PRE_first_tail_x15_r0_body.kappa68.frame
kernel_rfl PRE_first_tail_x15_r0_body.zjobs68 : PRE_first_tail_x15_r0_body.s662.jobs = PRE_first_tail_x15_r0_body.s663.jobs.map PRE_first_tail_x15_r0_body.kappa68.job
kernel_rfl PRE_first_tail_x15_r0_body.zstores68 : PRE_first_tail_x15_r0_body.s662.stores = PRE_first_tail_x15_r0_body.kappa68.stores PRE_first_tail_x15_r0_body.s663.stores
kernel_rfl PRE_first_tail_x15_r0_body.zroots68 : checkRootsSupp PRE_first_tail_x15_r0_body.s663 2962 = true
kernel_rfl PRE_first_tail_x15_r0_body.znC68 : PRE_first_tail_x15_r0_body.S661.tab.length + PRE_first_tail_x15_r0_body.cws68.length = 2962
-- the map as `Conv.compact_shift` states it (the call's counters for the literals)
kernel_rfl PRE_first_tail_x15_r0_body.zkap68 : PRE_first_tail_x15_r0_body.kappa68 = Conv.Map.compact PRE_first_tail_x15_r0_body.s661.next 2727854 PRE_first_tail_x15_r0_body.S661.tab.length PRE_first_tail_x15_r0_body.pl68 (PRE_first_tail_x15_r0_body.nr68.map NumV.ref) PRE_first_tail_x15_r0_body.kd68.big
  PRE_first_tail_x15_r0_body.kd68.region PRE_first_tail_x15_r0_body.kd68.nodeF
-- the bridge inactive at the canonical state (`Conv.FullShiftQ.toX`; the merged state's bridge is the canonical's: cbridge)
theorem PRE_first_tail_x15_r0_body.zbin68 : (Host.Ts.Sim.Full.bridgeOf PRE_first_tail_x15_r0_body.s663.ffi).active = false := (Host.Load.Boot.replay_active Host.Load.Run.Prompt.P.oblog2818)
-- the JS bookkeeping's step (`Conv.JClean.step` over the changed list) and the canonical roots' bigint freedom
kernel_rfl PRE_first_tail_x15_r0_body.zjc68 : Conv.jcleanListB (⟨19533, 16633, 2727844, 2962⟩ : Conv.Cnt) PRE_first_tail_x15_r0_body.s663 PRE_first_tail_x15_r0_body.cl68 = true
kernel_rfl PRE_first_tail_x15_r0_body.zrootsB68 : noBigRootsP (fun i => !Conv.oldBigB (⟨19533, 16633, 2727844, 2962⟩ : Conv.Cnt) i) PRE_first_tail_x15_r0_body.s663.trace PRE_first_tail_x15_r0_body.s663 = true
kernel_rfl PRE_first_tail_x15_r0_body.zhm68 : Nat.ble (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s0.ffi).mlx.nnext 16633 = true
theorem PRE_first_tail_x15_r0_body.cjcl68 (h : Conv.JClean (⟨19533, 16633, 2727843, 2962⟩ : Conv.Cnt) PRE_first_tail_x15_r0_body.s661) : Conv.JClean (⟨19533, 16633, 2727844, 2962⟩ : Conv.Cnt) PRE_first_tail_x15_r0_body.s663 :=
  Conv.JClean.step h (Conv.Cnt.le_of_leB PRE_first_tail_x15_r0_body.cle68)
    (Conv.heap_off_setAll PRE_first_tail_x15_r0_body.cheap68 fun a ha => Nat.blt_eq.mp (List.all_eq_true.mp PRE_first_tail_x15_r0_body.zclbd68 a ha)) PRE_first_tail_x15_r0_body.zjc68

end Host.Load.Run.Tpl
