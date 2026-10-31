import host.sim.template.a4dec_clearFill.SiteS1
import host.sim.template.a4dec_clearFill.SiteK1
import host.sim.template.a4dec_clearFill.SiteF1
import host.sim.conv.CompactShift
import host.sim.template.Check
import host.sim.BigFreeP
import host.sim.template.CallGen
set_option Elab.async false
namespace Host.Load.Run.Tpl
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
open Host.Ts Host.Ts.Sim Host.Ts.Sim.Template

/-! The compaction's state shift at call site 1 of chain `DEC_clearFill` (`Conv.compact_shift`): the call `DEC_clearFill.s4`, the merged
state `DEC_clearFill.s5`, the canonical state `DEC_clearFill.s6`; its frames [2673448,12504,2665,4910] (kept arrays [2673448,12504,2665]). -/

-- the map's places and counters
kernel_rfl DEC_clearFill.zpl1 : DEC_clearFill.pl1.all (Nat.ble DEC_clearFill.s4.next) = true
kernel_rfl DEC_clearFill.zplnd1 : nodupT DEC_clearFill.pl1 PTrie.nil = true
kernel_rfl DEC_clearFill.zn11 : Nat.ble DEC_clearFill.s4.next 3271107 = true
kernel_rfl DEC_clearFill.zfirst1 : Nat.ble aFirst DEC_clearFill.s4.next = true
kernel_rfl DEC_clearFill.zscn1 : DEC_clearFill.s6.next = DEC_clearFill.s4.next + DEC_clearFill.pl1.length
kernel_rfl DEC_clearFill.zsmn1 : DEC_clearFill.s5.next = 3271107
kernel_rfl DEC_clearFill.zgrow1 : Nat.ble DEC_clearFill.s6.next DEC_clearFill.s5.next = true
-- the tables
kernel_rfl DEC_clearFill.zfresh1 : DEC_clearFill.S4.tab.all (fun e => DEC_clearFill.cws1.all fun v => e.noVar v) = true
kernel_rfl DEC_clearFill.zcnd1 : nodupT DEC_clearFill.cws1 PTrie.nil = true
kernel_rfl DEC_clearFill.znrHi1 : DEC_clearFill.nr1.all (fun r => Nat.blt r DEC_clearFill.S5.tab.length) = true
-- the frames: every framed address below the call's counter; the kept arrays the chain start's, extended in the merged state
kernel_rfl DEC_clearFill.zfrlt1 : [2673448, 12504, 2665, 4910].all (fun a => Nat.blt a DEC_clearFill.s4.next) = true
kernel_rfl DEC_clearFill.zg1_2673448 : DEC_clearFill.s6.heap.get 2673448 = some (.obj (objOf DEC_clearFill.s6 2673448))
kernel_rfl DEC_clearFill.zk1_2673448 : (objOf DEC_clearFill.s6 2673448).kind = .array (arrOf DEC_clearFill.s0 2673448)
kernel_rfl DEC_clearFill.zm1_2673448 : DEC_clearFill.s5.heap.get 2673448 = some (.obj { DEC_clearFill.kappa1.obj (objOf DEC_clearFill.s6 2673448) with
  kind := .array (arrOf DEC_clearFill.s0 2673448 ++ (arrOf DEC_clearFill.s5 2673448).drop (arrOf DEC_clearFill.s0 2673448).length) })
kernel_rfl DEC_clearFill.zg1_12504 : DEC_clearFill.s6.heap.get 12504 = some (.obj (objOf DEC_clearFill.s6 12504))
kernel_rfl DEC_clearFill.zk1_12504 : (objOf DEC_clearFill.s6 12504).kind = .array (arrOf DEC_clearFill.s0 12504)
kernel_rfl DEC_clearFill.zm1_12504 : DEC_clearFill.s5.heap.get 12504 = some (.obj { DEC_clearFill.kappa1.obj (objOf DEC_clearFill.s6 12504) with
  kind := .array (arrOf DEC_clearFill.s0 12504 ++ (arrOf DEC_clearFill.s5 12504).drop (arrOf DEC_clearFill.s0 12504).length) })
kernel_rfl DEC_clearFill.zg1_2665 : DEC_clearFill.s6.heap.get 2665 = some (.obj (objOf DEC_clearFill.s6 2665))
kernel_rfl DEC_clearFill.zk1_2665 : (objOf DEC_clearFill.s6 2665).kind = .array (arrOf DEC_clearFill.s0 2665)
kernel_rfl DEC_clearFill.zm1_2665 : DEC_clearFill.s5.heap.get 2665 = some (.obj { DEC_clearFill.kappa1.obj (objOf DEC_clearFill.s6 2665) with
  kind := .array (arrOf DEC_clearFill.s0 2665 ++ (arrOf DEC_clearFill.s5 2665).drop (arrOf DEC_clearFill.s0 2665).length) })
kernel_rfl DEC_clearFill.zw1_4910 : (DEC_clearFill.s6.heap.get 4910).isSome = true
-- the heap: the changed list in range, holding the stage's written and fresh addresses; the canonical side's image
kernel_rfl DEC_clearFill.zclbd1 : DEC_clearFill.cl1.all (fun b => Nat.blt (b / 4096) (4 ^ 31)) = true
kernel_rfl DEC_clearFill.zwrN1 : Nat.ble DEC_clearFill.s4.next DEC_clearFill.st1.s0.next = true
kernel_rfl DEC_clearFill.zwrO1 : (Stage.rangesOf DEC_clearFill.st1.s150.heap DEC_clearFill.st1.wrR).all (fun e => !Nat.blt e.1 DEC_clearFill.s4.next || DEC_clearFill.cl1.contains e.1) = true
theorem DEC_clearFill.zwr1 : DEC_clearFill.st1.wr.all (fun b => !Nat.blt b DEC_clearFill.s4.next || DEC_clearFill.cl1.contains b) = true :=
  footW_lowAll DEC_clearFill.zwrN1 DEC_clearFill.zwrO1
def DEC_clearFill.zl1 : List Nat := DEC_clearFill.cl1.filter fun a => !(List.contains [2673448, 12504, 2665] a)
kernel_rfl DEC_clearFill.zimgE1 : DEC_clearFill.zl1.map (fun a => DEC_clearFill.s5.heap.get (DEC_clearFill.kappa1.a a)) = DEC_clearFill.zl1.map (fun a => (DEC_clearFill.s6.heap.get a).map DEC_clearFill.kappa1.hobj)
theorem DEC_clearFill.zimg1 : HeapImg DEC_clearFill.kappa1 DEC_clearFill.s6 DEC_clearFill.s5 DEC_clearFill.zl1 := DEC_clearFill.zimgE1
-- the roots and their supports
kernel_rfl DEC_clearFill.zctl1 : DEC_clearFill.s5.ctl = DEC_clearFill.kappa1.ctl DEC_clearFill.s6.ctl
kernel_rfl DEC_clearFill.zstack1 : DEC_clearFill.s5.stack = DEC_clearFill.s6.stack.map DEC_clearFill.kappa1.frame
kernel_rfl DEC_clearFill.zjobs1 : DEC_clearFill.s5.jobs = DEC_clearFill.s6.jobs.map DEC_clearFill.kappa1.job
kernel_rfl DEC_clearFill.zstores1 : DEC_clearFill.s5.stores = DEC_clearFill.kappa1.stores DEC_clearFill.s6.stores
kernel_rfl DEC_clearFill.zroots1 : checkRootsSupp DEC_clearFill.s6 289 = true
kernel_rfl DEC_clearFill.znC1 : DEC_clearFill.S4.tab.length + DEC_clearFill.cws1.length = 289
-- the map as `Conv.compact_shift` states it (the call's counters for the literals)
kernel_rfl DEC_clearFill.zkap1 : DEC_clearFill.kappa1 = Conv.Map.compact DEC_clearFill.s4.next 3271107 DEC_clearFill.S4.tab.length DEC_clearFill.pl1 (DEC_clearFill.nr1.map NumV.ref) DEC_clearFill.kd1.big
  DEC_clearFill.kd1.region DEC_clearFill.kd1.nodeF
-- the bridge inactive at the canonical state (`Conv.FullShiftQ.toX`; the merged state's bridge is the canonical's: cbridge)
kernel_rfl DEC_clearFill.zbin1 : (Host.Ts.Sim.Full.bridgeOf DEC_clearFill.s6.ffi).active = false
-- the JS bookkeeping's step (`Conv.JClean.step` over the changed list) and the canonical roots' bigint freedom
kernel_rfl DEC_clearFill.zjc1 : Conv.jcleanListB (⟨29432, 24881, 3123900, 289⟩ : Conv.Cnt) DEC_clearFill.s6 DEC_clearFill.cl1 = true
kernel_rfl DEC_clearFill.zroots21 : noBigRootsP (fun i => !Conv.oldBigB (⟨29432, 24881, 3123900, 289⟩ : Conv.Cnt) i) DEC_clearFill.s6.trace DEC_clearFill.s6 = true
kernel_rfl DEC_clearFill.zhm1 : Nat.ble (Host.Load.Layers.toLoad DEC_clearFill.s0.ffi).mlx.nnext 22540 = true
theorem DEC_clearFill.cjcl1 (h : Conv.JClean (⟨29303, 22540, 3123642, 129⟩ : Conv.Cnt) DEC_clearFill.s4) : Conv.JClean (⟨29432, 24881, 3123900, 289⟩ : Conv.Cnt) DEC_clearFill.s6 :=
  Conv.JClean.step h (Conv.Cnt.le_of_leB DEC_clearFill.cle1)
    (Conv.heap_off_setAll DEC_clearFill.cheap1 fun a ha => Nat.blt_eq.mp (List.all_eq_true.mp DEC_clearFill.zclbd1 a ha)) DEC_clearFill.zjc1

end Host.Load.Run.Tpl
