import host.sim.template.a4dec_fill.SiteS1
import host.sim.template.a4dec_fill.SiteK1
import host.sim.template.a4dec_fill.SiteF1
import host.sim.conv.CompactShift
import host.sim.template.Check
import host.sim.BigFreeP
import host.sim.template.CallGen
set_option Elab.async false
namespace Host.Load.Run.Tpl
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
open Host.Ts Host.Ts.Sim Host.Ts.Sim.Template

/-! The compaction's state shift at call site 1 of chain `DEC_fill` (`Conv.compact_shift`): the call `DEC_fill.s4`, the merged
state `DEC_fill.s5`, the canonical state `DEC_fill.s6`; its frames [2673448,12504,2665,4910] (kept arrays [2673448,12504,2665]). -/

-- the map's places and counters
kernel_rfl DEC_fill.zpl1 : DEC_fill.pl1.all (Nat.ble DEC_fill.s4.next) = true
kernel_rfl DEC_fill.zplnd1 : nodupT DEC_fill.pl1 PTrie.nil = true
kernel_rfl DEC_fill.zn11 : Nat.ble DEC_fill.s4.next 3271106 = true
kernel_rfl DEC_fill.zfirst1 : Nat.ble aFirst DEC_fill.s4.next = true
kernel_rfl DEC_fill.zscn1 : DEC_fill.s6.next = DEC_fill.s4.next + DEC_fill.pl1.length
kernel_rfl DEC_fill.zsmn1 : DEC_fill.s5.next = 3271106
kernel_rfl DEC_fill.zgrow1 : Nat.ble DEC_fill.s6.next DEC_fill.s5.next = true
-- the tables
kernel_rfl DEC_fill.zfresh1 : DEC_fill.S4.tab.all (fun e => DEC_fill.cws1.all fun v => e.noVar v) = true
kernel_rfl DEC_fill.zcnd1 : nodupT DEC_fill.cws1 PTrie.nil = true
kernel_rfl DEC_fill.znrHi1 : DEC_fill.nr1.all (fun r => Nat.blt r DEC_fill.S5.tab.length) = true
-- the frames: every framed address below the call's counter; the kept arrays the chain start's, extended in the merged state
kernel_rfl DEC_fill.zfrlt1 : [2673448, 12504, 2665, 4910].all (fun a => Nat.blt a DEC_fill.s4.next) = true
kernel_rfl DEC_fill.zg1_2673448 : DEC_fill.s6.heap.get 2673448 = some (.obj (objOf DEC_fill.s6 2673448))
kernel_rfl DEC_fill.zk1_2673448 : (objOf DEC_fill.s6 2673448).kind = .array (arrOf DEC_fill.s0 2673448)
kernel_rfl DEC_fill.zm1_2673448 : DEC_fill.s5.heap.get 2673448 = some (.obj { DEC_fill.kappa1.obj (objOf DEC_fill.s6 2673448) with
  kind := .array (arrOf DEC_fill.s0 2673448 ++ (arrOf DEC_fill.s5 2673448).drop (arrOf DEC_fill.s0 2673448).length) })
kernel_rfl DEC_fill.zg1_12504 : DEC_fill.s6.heap.get 12504 = some (.obj (objOf DEC_fill.s6 12504))
kernel_rfl DEC_fill.zk1_12504 : (objOf DEC_fill.s6 12504).kind = .array (arrOf DEC_fill.s0 12504)
kernel_rfl DEC_fill.zm1_12504 : DEC_fill.s5.heap.get 12504 = some (.obj { DEC_fill.kappa1.obj (objOf DEC_fill.s6 12504) with
  kind := .array (arrOf DEC_fill.s0 12504 ++ (arrOf DEC_fill.s5 12504).drop (arrOf DEC_fill.s0 12504).length) })
kernel_rfl DEC_fill.zg1_2665 : DEC_fill.s6.heap.get 2665 = some (.obj (objOf DEC_fill.s6 2665))
kernel_rfl DEC_fill.zk1_2665 : (objOf DEC_fill.s6 2665).kind = .array (arrOf DEC_fill.s0 2665)
kernel_rfl DEC_fill.zm1_2665 : DEC_fill.s5.heap.get 2665 = some (.obj { DEC_fill.kappa1.obj (objOf DEC_fill.s6 2665) with
  kind := .array (arrOf DEC_fill.s0 2665 ++ (arrOf DEC_fill.s5 2665).drop (arrOf DEC_fill.s0 2665).length) })
kernel_rfl DEC_fill.zw1_4910 : (DEC_fill.s6.heap.get 4910).isSome = true
-- the heap: the changed list in range, holding the stage's written and fresh addresses; the canonical side's image
kernel_rfl DEC_fill.zclbd1 : DEC_fill.cl1.all (fun b => Nat.blt (b / 4096) (4 ^ 31)) = true
kernel_rfl DEC_fill.zwrN1 : Nat.ble DEC_fill.s4.next DEC_fill.st1.s0.next = true
kernel_rfl DEC_fill.zwrO1 : (Stage.rangesOf DEC_fill.st1.s150.heap DEC_fill.st1.wrR).all (fun e => !Nat.blt e.1 DEC_fill.s4.next || DEC_fill.cl1.contains e.1) = true
theorem DEC_fill.zwr1 : DEC_fill.st1.wr.all (fun b => !Nat.blt b DEC_fill.s4.next || DEC_fill.cl1.contains b) = true :=
  footW_lowAll DEC_fill.zwrN1 DEC_fill.zwrO1
def DEC_fill.zl1 : List Nat := DEC_fill.cl1.filter fun a => !(List.contains [2673448, 12504, 2665] a)
kernel_rfl DEC_fill.zimgE1 : DEC_fill.zl1.map (fun a => DEC_fill.s5.heap.get (DEC_fill.kappa1.a a)) = DEC_fill.zl1.map (fun a => (DEC_fill.s6.heap.get a).map DEC_fill.kappa1.hobj)
theorem DEC_fill.zimg1 : HeapImg DEC_fill.kappa1 DEC_fill.s6 DEC_fill.s5 DEC_fill.zl1 := DEC_fill.zimgE1
-- the roots and their supports
kernel_rfl DEC_fill.zctl1 : DEC_fill.s5.ctl = DEC_fill.kappa1.ctl DEC_fill.s6.ctl
kernel_rfl DEC_fill.zstack1 : DEC_fill.s5.stack = DEC_fill.s6.stack.map DEC_fill.kappa1.frame
kernel_rfl DEC_fill.zjobs1 : DEC_fill.s5.jobs = DEC_fill.s6.jobs.map DEC_fill.kappa1.job
kernel_rfl DEC_fill.zstores1 : DEC_fill.s5.stores = DEC_fill.kappa1.stores DEC_fill.s6.stores
kernel_rfl DEC_fill.zroots1 : checkRootsSupp DEC_fill.s6 289 = true
kernel_rfl DEC_fill.znC1 : DEC_fill.S4.tab.length + DEC_fill.cws1.length = 289
-- the map as `Conv.compact_shift` states it (the call's counters for the literals)
kernel_rfl DEC_fill.zkap1 : DEC_fill.kappa1 = Conv.Map.compact DEC_fill.s4.next 3271106 DEC_fill.S4.tab.length DEC_fill.pl1 (DEC_fill.nr1.map NumV.ref) DEC_fill.kd1.big
  DEC_fill.kd1.region DEC_fill.kd1.nodeF
-- the bridge inactive at the canonical state (`Conv.FullShiftQ.toX`; the merged state's bridge is the canonical's: cbridge)
kernel_rfl DEC_fill.zbin1 : (Host.Ts.Sim.Full.bridgeOf DEC_fill.s6.ffi).active = false
-- the JS bookkeeping's step (`Conv.JClean.step` over the changed list) and the canonical roots' bigint freedom
kernel_rfl DEC_fill.zjc1 : Conv.jcleanListB (⟨29432, 24881, 3123899, 289⟩ : Conv.Cnt) DEC_fill.s6 DEC_fill.cl1 = true
kernel_rfl DEC_fill.zroots21 : noBigRootsP (fun i => !Conv.oldBigB (⟨29432, 24881, 3123899, 289⟩ : Conv.Cnt) i) DEC_fill.s6.trace DEC_fill.s6 = true
kernel_rfl DEC_fill.zhm1 : Nat.ble (Host.Load.Layers.toLoad DEC_fill.s0.ffi).mlx.nnext 22540 = true
theorem DEC_fill.cjcl1 (h : Conv.JClean (⟨29303, 22540, 3123641, 129⟩ : Conv.Cnt) DEC_fill.s4) : Conv.JClean (⟨29432, 24881, 3123899, 289⟩ : Conv.Cnt) DEC_fill.s6 :=
  Conv.JClean.step h (Conv.Cnt.le_of_leB DEC_fill.cle1)
    (Conv.heap_off_setAll DEC_fill.cheap1 fun a ha => Nat.blt_eq.mp (List.all_eq_true.mp DEC_fill.zclbd1 a ha)) DEC_fill.zjc1

end Host.Load.Run.Tpl
