import host.sim.template.a4pre_first_tail_x15_r0.SiteS2
import host.sim.template.a4pre_first_tail_x15_r0.SiteK2
import host.sim.template.a4pre_first_tail_x15_r0.SiteF2
import host.sim.conv.CompactShift
import host.sim.template.Check
import host.sim.BigFreeP
import host.sim.template.CallGen
set_option Elab.async false
namespace Host.Load.Run.Tpl
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
open Host.Ts Host.Ts.Sim Host.Ts.Sim.Template

/-! The compaction's state shift at call site 2 of chain `PRE_first_tail_x15_r0` (`Conv.compact_shift`): the call `PRE_first_tail_x15_r0.s38`, the merged
state `PRE_first_tail_x15_r0.s39`, the canonical state `PRE_first_tail_x15_r0.s40`; its frames [2665] (kept arrays [2665]). -/

-- the map's places and counters
kernel_rfl PRE_first_tail_x15_r0.zpl2 : PRE_first_tail_x15_r0.pl2.all (Nat.ble PRE_first_tail_x15_r0.s38.next) = true
kernel_rfl PRE_first_tail_x15_r0.zplnd2 : nodupT PRE_first_tail_x15_r0.pl2 PTrie.nil = true
kernel_rfl PRE_first_tail_x15_r0.zn12 : Nat.ble PRE_first_tail_x15_r0.s38.next 2673519 = true
kernel_rfl PRE_first_tail_x15_r0.zfirst2 : Nat.ble aFirst PRE_first_tail_x15_r0.s38.next = true
kernel_rfl PRE_first_tail_x15_r0.zscn2 : PRE_first_tail_x15_r0.s40.next = PRE_first_tail_x15_r0.s38.next + PRE_first_tail_x15_r0.pl2.length
kernel_rfl PRE_first_tail_x15_r0.zsmn2 : PRE_first_tail_x15_r0.s39.next = 2673519
kernel_rfl PRE_first_tail_x15_r0.zgrow2 : Nat.ble PRE_first_tail_x15_r0.s40.next PRE_first_tail_x15_r0.s39.next = true
-- the tables
kernel_rfl PRE_first_tail_x15_r0.zfresh2 : PRE_first_tail_x15_r0.S38.tab.all (fun e => PRE_first_tail_x15_r0.cws2.all fun v => e.noVar v) = true
kernel_rfl PRE_first_tail_x15_r0.zcnd2 : nodupT PRE_first_tail_x15_r0.cws2 PTrie.nil = true
kernel_rfl PRE_first_tail_x15_r0.znrHi2 : PRE_first_tail_x15_r0.nr2.all (fun r => Nat.blt r PRE_first_tail_x15_r0.S39.tab.length) = true
-- the frames: every framed address below the call's counter; the kept arrays the chain start's, extended in the merged state
kernel_rfl PRE_first_tail_x15_r0.zfrlt2 : [2665].all (fun a => Nat.blt a PRE_first_tail_x15_r0.s38.next) = true
kernel_rfl PRE_first_tail_x15_r0.zg2_2665 : PRE_first_tail_x15_r0.s40.heap.get 2665 = some (.obj (objOf PRE_first_tail_x15_r0.s40 2665))
kernel_rfl PRE_first_tail_x15_r0.zk2_2665 : (objOf PRE_first_tail_x15_r0.s40 2665).kind = .array (arrOf PRE_first_tail_x15_r0.s0 2665)
kernel_rfl PRE_first_tail_x15_r0.zm2_2665 : PRE_first_tail_x15_r0.s39.heap.get 2665 = some (.obj { PRE_first_tail_x15_r0.kappa2.obj (objOf PRE_first_tail_x15_r0.s40 2665) with
  kind := .array (arrOf PRE_first_tail_x15_r0.s0 2665 ++ (arrOf PRE_first_tail_x15_r0.s39 2665).drop (arrOf PRE_first_tail_x15_r0.s0 2665).length) })
kernel_rfl PRE_first_tail_x15_r0.zw2_4910 : (PRE_first_tail_x15_r0.s40.heap.get 4910).isSome = true
-- the heap: the changed list in range, holding the stage's written and fresh addresses; the canonical side's image
kernel_rfl PRE_first_tail_x15_r0.zclbd2 : PRE_first_tail_x15_r0.cl2.all (fun b => Nat.blt (b / 4096) (4 ^ 31)) = true
kernel_rfl PRE_first_tail_x15_r0.zwr2 : PRE_first_tail_x15_r0.st2.wr.all (fun b => !Nat.blt b PRE_first_tail_x15_r0.s38.next || PRE_first_tail_x15_r0.cl2.contains b) = true
def PRE_first_tail_x15_r0.zl2 : List Nat := PRE_first_tail_x15_r0.cl2.filter fun a => !(List.contains [2665] a)
kernel_rfl PRE_first_tail_x15_r0.zimgE2 : PRE_first_tail_x15_r0.zl2.map (fun a => PRE_first_tail_x15_r0.s39.heap.get (PRE_first_tail_x15_r0.kappa2.a a)) = PRE_first_tail_x15_r0.zl2.map (fun a => (PRE_first_tail_x15_r0.s40.heap.get a).map PRE_first_tail_x15_r0.kappa2.hobj)
theorem PRE_first_tail_x15_r0.zimg2 : HeapImg PRE_first_tail_x15_r0.kappa2 PRE_first_tail_x15_r0.s40 PRE_first_tail_x15_r0.s39 PRE_first_tail_x15_r0.zl2 := PRE_first_tail_x15_r0.zimgE2
-- the roots and their supports
kernel_rfl PRE_first_tail_x15_r0.zctl2 : PRE_first_tail_x15_r0.s39.ctl = PRE_first_tail_x15_r0.kappa2.ctl PRE_first_tail_x15_r0.s40.ctl
kernel_rfl PRE_first_tail_x15_r0.zstack2 : PRE_first_tail_x15_r0.s39.stack = PRE_first_tail_x15_r0.s40.stack.map PRE_first_tail_x15_r0.kappa2.frame
kernel_rfl PRE_first_tail_x15_r0.zjobs2 : PRE_first_tail_x15_r0.s39.jobs = PRE_first_tail_x15_r0.s40.jobs.map PRE_first_tail_x15_r0.kappa2.job
kernel_rfl PRE_first_tail_x15_r0.zstores2 : PRE_first_tail_x15_r0.s39.stores = PRE_first_tail_x15_r0.kappa2.stores PRE_first_tail_x15_r0.s40.stores
kernel_rfl PRE_first_tail_x15_r0.zroots2 : checkRootsSupp PRE_first_tail_x15_r0.s40 18 = true
kernel_rfl PRE_first_tail_x15_r0.znC2 : PRE_first_tail_x15_r0.S38.tab.length + PRE_first_tail_x15_r0.cws2.length = 18
-- the map as `Conv.compact_shift` states it (the call's counters for the literals)
kernel_rfl PRE_first_tail_x15_r0.zkap2 : PRE_first_tail_x15_r0.kappa2 = Conv.Map.compact PRE_first_tail_x15_r0.s38.next 2673519 PRE_first_tail_x15_r0.S38.tab.length PRE_first_tail_x15_r0.pl2 (PRE_first_tail_x15_r0.nr2.map NumV.ref) PRE_first_tail_x15_r0.kd2.big
  PRE_first_tail_x15_r0.kd2.region PRE_first_tail_x15_r0.kd2.nodeF
-- the bridge inactive at the canonical state (`Conv.FullShiftQ.toX`; the merged state's bridge is the canonical's: cbridge)
theorem PRE_first_tail_x15_r0.zbin2 : (Host.Ts.Sim.Full.bridgeOf PRE_first_tail_x15_r0.s40.ffi).active = false := (Host.Load.Boot.replay_active Host.Load.Run.Prompt.P.oblog2818)
-- the JS bookkeeping's step (`Conv.JClean.step` over the changed list) and the canonical roots' bigint freedom
kernel_rfl PRE_first_tail_x15_r0.zjc2 : Conv.jcleanListB (⟨18156, 15236, 2673488, 18⟩ : Conv.Cnt) PRE_first_tail_x15_r0.s40 PRE_first_tail_x15_r0.cl2 = true
kernel_rfl PRE_first_tail_x15_r0.zroots22 : noBigRootsP (fun i => !Conv.oldBigB (⟨18156, 15236, 2673488, 18⟩ : Conv.Cnt) i) PRE_first_tail_x15_r0.s40.trace PRE_first_tail_x15_r0.s40 = true
kernel_rfl PRE_first_tail_x15_r0.zhm2 : Nat.ble (Host.Load.Layers.toLoad PRE_first_tail_x15_r0.s0.ffi).mlx.nnext 15236 = true
theorem PRE_first_tail_x15_r0.cjcl2 (h : Conv.JClean (⟨18156, 15236, 2673488, 18⟩ : Conv.Cnt) PRE_first_tail_x15_r0.s38) : Conv.JClean (⟨18156, 15236, 2673488, 18⟩ : Conv.Cnt) PRE_first_tail_x15_r0.s40 :=
  Conv.JClean.step h (Conv.Cnt.le_of_leB PRE_first_tail_x15_r0.cle2)
    (Conv.heap_off_setAll PRE_first_tail_x15_r0.cheap2 fun a ha => Nat.blt_eq.mp (List.all_eq_true.mp PRE_first_tail_x15_r0.zclbd2 a ha)) PRE_first_tail_x15_r0.zjc2

end Host.Load.Run.Tpl
