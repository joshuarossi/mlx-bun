import host.sim.template.a4pre_first_tail_x15_r0.SiteS1
import host.sim.template.a4pre_first_tail_x15_r0.SiteK1
import host.sim.template.a4pre_first_tail_x15_r0.SiteF1
import host.sim.conv.CompactShift
import host.sim.template.Check
import host.sim.BigFreeP
import host.sim.template.CallGen
set_option Elab.async false
namespace Host.Load.Run.Tpl
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
open Host.Ts Host.Ts.Sim Host.Ts.Sim.Template

/-! The compaction's state shift at call site 1 of chain `PRE_first_tail_x15_r0` (`Conv.compact_shift`): the call `PRE_first_tail_x15_r0.s17`, the merged
state `PRE_first_tail_x15_r0.s18`, the canonical state `PRE_first_tail_x15_r0.s19`; its frames [2665] (kept arrays [2665]). -/

-- the map's places and counters
kernel_rfl PRE_first_tail_x15_r0.zpl1 : PRE_first_tail_x15_r0.pl1.all (Nat.ble PRE_first_tail_x15_r0.s17.next) = true
kernel_rfl PRE_first_tail_x15_r0.zplnd1 : nodupT PRE_first_tail_x15_r0.pl1 PTrie.nil = true
kernel_rfl PRE_first_tail_x15_r0.zn11 : Nat.ble PRE_first_tail_x15_r0.s17.next 2673472 = true
kernel_rfl PRE_first_tail_x15_r0.zfirst1 : Nat.ble aFirst PRE_first_tail_x15_r0.s17.next = true
kernel_rfl PRE_first_tail_x15_r0.zscn1 : PRE_first_tail_x15_r0.s19.next = PRE_first_tail_x15_r0.s17.next + PRE_first_tail_x15_r0.pl1.length
kernel_rfl PRE_first_tail_x15_r0.zsmn1 : PRE_first_tail_x15_r0.s18.next = 2673472
kernel_rfl PRE_first_tail_x15_r0.zgrow1 : Nat.ble PRE_first_tail_x15_r0.s19.next PRE_first_tail_x15_r0.s18.next = true
-- the tables
kernel_rfl PRE_first_tail_x15_r0.zfresh1 : PRE_first_tail_x15_r0.S17.tab.all (fun e => PRE_first_tail_x15_r0.cws1.all fun v => e.noVar v) = true
kernel_rfl PRE_first_tail_x15_r0.zcnd1 : nodupT PRE_first_tail_x15_r0.cws1 PTrie.nil = true
kernel_rfl PRE_first_tail_x15_r0.znrHi1 : PRE_first_tail_x15_r0.nr1.all (fun r => Nat.blt r PRE_first_tail_x15_r0.S18.tab.length) = true
-- the frames: every framed address below the call's counter; the kept arrays the chain start's, extended in the merged state
kernel_rfl PRE_first_tail_x15_r0.zfrlt1 : [2665].all (fun a => Nat.blt a PRE_first_tail_x15_r0.s17.next) = true
kernel_rfl PRE_first_tail_x15_r0.zg1_2665 : PRE_first_tail_x15_r0.s19.heap.get 2665 = some (.obj (objOf PRE_first_tail_x15_r0.s19 2665))
kernel_rfl PRE_first_tail_x15_r0.zk1_2665 : (objOf PRE_first_tail_x15_r0.s19 2665).kind = .array (arrOf PRE_first_tail_x15_r0.s0 2665)
kernel_rfl PRE_first_tail_x15_r0.zm1_2665 : PRE_first_tail_x15_r0.s18.heap.get 2665 = some (.obj { PRE_first_tail_x15_r0.kappa1.obj (objOf PRE_first_tail_x15_r0.s19 2665) with
  kind := .array (arrOf PRE_first_tail_x15_r0.s0 2665 ++ (arrOf PRE_first_tail_x15_r0.s18 2665).drop (arrOf PRE_first_tail_x15_r0.s0 2665).length) })
kernel_rfl PRE_first_tail_x15_r0.zw1_4910 : (PRE_first_tail_x15_r0.s19.heap.get 4910).isSome = true
-- the heap: the changed list in range, holding the stage's written and fresh addresses; the canonical side's image
kernel_rfl PRE_first_tail_x15_r0.zclbd1 : PRE_first_tail_x15_r0.cl1.all (fun b => Nat.blt (b / 4096) (4 ^ 31)) = true
kernel_rfl PRE_first_tail_x15_r0.zwr1 : PRE_first_tail_x15_r0.st1.wr.all (fun b => !Nat.blt b PRE_first_tail_x15_r0.s17.next || PRE_first_tail_x15_r0.cl1.contains b) = true
def PRE_first_tail_x15_r0.zl1 : List Nat := PRE_first_tail_x15_r0.cl1.filter fun a => !(List.contains [2665] a)
kernel_rfl PRE_first_tail_x15_r0.zimgE1 : PRE_first_tail_x15_r0.zl1.map (fun a => PRE_first_tail_x15_r0.s18.heap.get (PRE_first_tail_x15_r0.kappa1.a a)) = PRE_first_tail_x15_r0.zl1.map (fun a => (PRE_first_tail_x15_r0.s19.heap.get a).map PRE_first_tail_x15_r0.kappa1.hobj)
theorem PRE_first_tail_x15_r0.zimg1 : HeapImg PRE_first_tail_x15_r0.kappa1 PRE_first_tail_x15_r0.s19 PRE_first_tail_x15_r0.s18 PRE_first_tail_x15_r0.zl1 := PRE_first_tail_x15_r0.zimgE1
-- the roots and their supports
kernel_rfl PRE_first_tail_x15_r0.zctl1 : PRE_first_tail_x15_r0.s18.ctl = PRE_first_tail_x15_r0.kappa1.ctl PRE_first_tail_x15_r0.s19.ctl
kernel_rfl PRE_first_tail_x15_r0.zstack1 : PRE_first_tail_x15_r0.s18.stack = PRE_first_tail_x15_r0.s19.stack.map PRE_first_tail_x15_r0.kappa1.frame
kernel_rfl PRE_first_tail_x15_r0.zjobs1 : PRE_first_tail_x15_r0.s18.jobs = PRE_first_tail_x15_r0.s19.jobs.map PRE_first_tail_x15_r0.kappa1.job
kernel_rfl PRE_first_tail_x15_r0.zstores1 : PRE_first_tail_x15_r0.s18.stores = PRE_first_tail_x15_r0.kappa1.stores PRE_first_tail_x15_r0.s19.stores
kernel_rfl PRE_first_tail_x15_r0.zroots1 : checkRootsSupp PRE_first_tail_x15_r0.s19 15 = true
kernel_rfl PRE_first_tail_x15_r0.znC1 : PRE_first_tail_x15_r0.S17.tab.length + PRE_first_tail_x15_r0.cws1.length = 15
-- the map as `Conv.compact_shift` states it (the call's counters for the literals)
kernel_rfl PRE_first_tail_x15_r0.zkap1 : PRE_first_tail_x15_r0.kappa1 = Conv.Map.compact PRE_first_tail_x15_r0.s17.next 2673472 PRE_first_tail_x15_r0.S17.tab.length PRE_first_tail_x15_r0.pl1 (PRE_first_tail_x15_r0.nr1.map NumV.ref) PRE_first_tail_x15_r0.kd1.big
  PRE_first_tail_x15_r0.kd1.region PRE_first_tail_x15_r0.kd1.nodeF
-- the bridge inactive at the canonical state (`Conv.FullShiftQ.toX`; the merged state's bridge is the canonical's: cbridge)
theorem PRE_first_tail_x15_r0.zbin1 : (Host.Ts.Sim.Full.bridgeOf PRE_first_tail_x15_r0.s19.ffi).active = false := (Host.Load.Boot.replay_active Host.Load.Run.Prompt.P.oblog2818)
-- the JS bookkeeping's step (`Conv.JClean.step` over the changed list) and the canonical roots' bigint freedom
kernel_rfl PRE_first_tail_x15_r0.zjc1 : Conv.jcleanListB (⟨18155, 15235, 2673458, 15⟩ : Conv.Cnt) PRE_first_tail_x15_r0.s19 PRE_first_tail_x15_r0.cl1 = true
kernel_rfl PRE_first_tail_x15_r0.zroots21 : noBigRootsP (fun i => !Conv.oldBigB (⟨18155, 15235, 2673458, 15⟩ : Conv.Cnt) i) PRE_first_tail_x15_r0.s19.trace PRE_first_tail_x15_r0.s19 = true
kernel_rfl PRE_first_tail_x15_r0.zhm1 : Nat.ble (Host.Load.Layers.toLoad PRE_first_tail_x15_r0.s0.ffi).mlx.nnext 15235 = true
theorem PRE_first_tail_x15_r0.cjcl1 (h : Conv.JClean (⟨18155, 15235, 2673457, 14⟩ : Conv.Cnt) PRE_first_tail_x15_r0.s17) : Conv.JClean (⟨18155, 15235, 2673458, 15⟩ : Conv.Cnt) PRE_first_tail_x15_r0.s19 :=
  Conv.JClean.step h (Conv.Cnt.le_of_leB PRE_first_tail_x15_r0.cle1)
    (Conv.heap_off_setAll PRE_first_tail_x15_r0.cheap1 fun a ha => Nat.blt_eq.mp (List.all_eq_true.mp PRE_first_tail_x15_r0.zclbd1 a ha)) PRE_first_tail_x15_r0.zjc1

end Host.Load.Run.Tpl
