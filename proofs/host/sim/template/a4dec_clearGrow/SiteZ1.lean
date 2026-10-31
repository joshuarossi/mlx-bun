import host.sim.template.a4dec_clearGrow.SiteS1
import host.sim.template.a4dec_clearGrow.SiteK1
import host.sim.template.a4dec_clearGrow.SiteF1
import host.sim.conv.CompactShift
import host.sim.template.Check
import host.sim.BigFreeP
import host.sim.template.CallGen
set_option Elab.async false
namespace Host.Load.Run.Tpl
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
open Host.Ts Host.Ts.Sim Host.Ts.Sim.Template

/-! The compaction's state shift at call site 1 of chain `DEC_clearGrow` (`Conv.compact_shift`): the call `DEC_clearGrow.s4`, the merged
state `DEC_clearGrow.s5`, the canonical state `DEC_clearGrow.s6`; its frames [2673448,12504,2665,4910] (kept arrays [2673448,12504,2665]). -/

-- the map's places and counters
kernel_rfl DEC_clearGrow.zpl1 : DEC_clearGrow.pl1.all (Nat.ble DEC_clearGrow.s4.next) = true
kernel_rfl DEC_clearGrow.zplnd1 : nodupT DEC_clearGrow.pl1 PTrie.nil = true
kernel_rfl DEC_clearGrow.zn11 : Nat.ble DEC_clearGrow.s4.next 3274243 = true
kernel_rfl DEC_clearGrow.zfirst1 : Nat.ble aFirst DEC_clearGrow.s4.next = true
kernel_rfl DEC_clearGrow.zscn1 : DEC_clearGrow.s6.next = DEC_clearGrow.s4.next + DEC_clearGrow.pl1.length
kernel_rfl DEC_clearGrow.zsmn1 : DEC_clearGrow.s5.next = 3274243
kernel_rfl DEC_clearGrow.zgrow1 : Nat.ble DEC_clearGrow.s6.next DEC_clearGrow.s5.next = true
-- the tables
kernel_rfl DEC_clearGrow.zfresh1 : DEC_clearGrow.S4.tab.all (fun e => DEC_clearGrow.cws1.all fun v => e.noVar v) = true
kernel_rfl DEC_clearGrow.zcnd1 : nodupT DEC_clearGrow.cws1 PTrie.nil = true
kernel_rfl DEC_clearGrow.znrHi1 : DEC_clearGrow.nr1.all (fun r => Nat.blt r DEC_clearGrow.S5.tab.length) = true
-- the frames: every framed address below the call's counter; the kept arrays the chain start's, extended in the merged state
kernel_rfl DEC_clearGrow.zfrlt1 : [2673448, 12504, 2665, 4910].all (fun a => Nat.blt a DEC_clearGrow.s4.next) = true
kernel_rfl DEC_clearGrow.zg1_2673448 : DEC_clearGrow.s6.heap.get 2673448 = some (.obj (objOf DEC_clearGrow.s6 2673448))
kernel_rfl DEC_clearGrow.zk1_2673448 : (objOf DEC_clearGrow.s6 2673448).kind = .array (arrOf DEC_clearGrow.s0 2673448)
kernel_rfl DEC_clearGrow.zm1_2673448 : DEC_clearGrow.s5.heap.get 2673448 = some (.obj { DEC_clearGrow.kappa1.obj (objOf DEC_clearGrow.s6 2673448) with
  kind := .array (arrOf DEC_clearGrow.s0 2673448 ++ (arrOf DEC_clearGrow.s5 2673448).drop (arrOf DEC_clearGrow.s0 2673448).length) })
kernel_rfl DEC_clearGrow.zg1_12504 : DEC_clearGrow.s6.heap.get 12504 = some (.obj (objOf DEC_clearGrow.s6 12504))
kernel_rfl DEC_clearGrow.zk1_12504 : (objOf DEC_clearGrow.s6 12504).kind = .array (arrOf DEC_clearGrow.s0 12504)
kernel_rfl DEC_clearGrow.zm1_12504 : DEC_clearGrow.s5.heap.get 12504 = some (.obj { DEC_clearGrow.kappa1.obj (objOf DEC_clearGrow.s6 12504) with
  kind := .array (arrOf DEC_clearGrow.s0 12504 ++ (arrOf DEC_clearGrow.s5 12504).drop (arrOf DEC_clearGrow.s0 12504).length) })
kernel_rfl DEC_clearGrow.zg1_2665 : DEC_clearGrow.s6.heap.get 2665 = some (.obj (objOf DEC_clearGrow.s6 2665))
kernel_rfl DEC_clearGrow.zk1_2665 : (objOf DEC_clearGrow.s6 2665).kind = .array (arrOf DEC_clearGrow.s0 2665)
kernel_rfl DEC_clearGrow.zm1_2665 : DEC_clearGrow.s5.heap.get 2665 = some (.obj { DEC_clearGrow.kappa1.obj (objOf DEC_clearGrow.s6 2665) with
  kind := .array (arrOf DEC_clearGrow.s0 2665 ++ (arrOf DEC_clearGrow.s5 2665).drop (arrOf DEC_clearGrow.s0 2665).length) })
kernel_rfl DEC_clearGrow.zw1_4910 : (DEC_clearGrow.s6.heap.get 4910).isSome = true
-- the heap: the changed list in range, holding the stage's written and fresh addresses; the canonical side's image
kernel_rfl DEC_clearGrow.zclbd1 : DEC_clearGrow.cl1.all (fun b => Nat.blt (b / 4096) (4 ^ 31)) = true
kernel_rfl DEC_clearGrow.zwrN1 : Nat.ble DEC_clearGrow.s4.next DEC_clearGrow.st1.s0.next = true
kernel_rfl DEC_clearGrow.zwrO1 : (Stage.rangesOf DEC_clearGrow.st1.s153.heap DEC_clearGrow.st1.wrR).all (fun e => !Nat.blt e.1 DEC_clearGrow.s4.next || DEC_clearGrow.cl1.contains e.1) = true
theorem DEC_clearGrow.zwr1 : DEC_clearGrow.st1.wr.all (fun b => !Nat.blt b DEC_clearGrow.s4.next || DEC_clearGrow.cl1.contains b) = true :=
  footW_lowAll DEC_clearGrow.zwrN1 DEC_clearGrow.zwrO1
def DEC_clearGrow.zl1 : List Nat := DEC_clearGrow.cl1.filter fun a => !(List.contains [2673448, 12504, 2665] a)
kernel_rfl DEC_clearGrow.zimgE1 : DEC_clearGrow.zl1.map (fun a => DEC_clearGrow.s5.heap.get (DEC_clearGrow.kappa1.a a)) = DEC_clearGrow.zl1.map (fun a => (DEC_clearGrow.s6.heap.get a).map DEC_clearGrow.kappa1.hobj)
theorem DEC_clearGrow.zimg1 : HeapImg DEC_clearGrow.kappa1 DEC_clearGrow.s6 DEC_clearGrow.s5 DEC_clearGrow.zl1 := DEC_clearGrow.zimgE1
-- the roots and their supports
kernel_rfl DEC_clearGrow.zctl1 : DEC_clearGrow.s5.ctl = DEC_clearGrow.kappa1.ctl DEC_clearGrow.s6.ctl
kernel_rfl DEC_clearGrow.zstack1 : DEC_clearGrow.s5.stack = DEC_clearGrow.s6.stack.map DEC_clearGrow.kappa1.frame
kernel_rfl DEC_clearGrow.zjobs1 : DEC_clearGrow.s5.jobs = DEC_clearGrow.s6.jobs.map DEC_clearGrow.kappa1.job
kernel_rfl DEC_clearGrow.zstores1 : DEC_clearGrow.s5.stores = DEC_clearGrow.kappa1.stores DEC_clearGrow.s6.stores
kernel_rfl DEC_clearGrow.zroots1 : checkRootsSupp DEC_clearGrow.s6 385 = true
kernel_rfl DEC_clearGrow.znC1 : DEC_clearGrow.S4.tab.length + DEC_clearGrow.cws1.length = 385
-- the map as `Conv.compact_shift` states it (the call's counters for the literals)
kernel_rfl DEC_clearGrow.zkap1 : DEC_clearGrow.kappa1 = Conv.Map.compact DEC_clearGrow.s4.next 3274243 DEC_clearGrow.S4.tab.length DEC_clearGrow.pl1 (DEC_clearGrow.nr1.map NumV.ref) DEC_clearGrow.kd1.big
  DEC_clearGrow.kd1.region DEC_clearGrow.kd1.nodeF
-- the bridge inactive at the canonical state (`Conv.FullShiftQ.toX`; the merged state's bridge is the canonical's: cbridge)
kernel_rfl DEC_clearGrow.zbin1 : (Host.Ts.Sim.Full.bridgeOf DEC_clearGrow.s6.ffi).active = false
-- the JS bookkeeping's step (`Conv.JClean.step` over the changed list) and the canonical roots' bigint freedom
kernel_rfl DEC_clearGrow.zjc1 : Conv.jcleanListB (⟨29432, 24977, 3123900, 385⟩ : Conv.Cnt) DEC_clearGrow.s6 DEC_clearGrow.cl1 = true
kernel_rfl DEC_clearGrow.zroots21 : noBigRootsP (fun i => !Conv.oldBigB (⟨29432, 24977, 3123900, 385⟩ : Conv.Cnt) i) DEC_clearGrow.s6.trace DEC_clearGrow.s6 = true
kernel_rfl DEC_clearGrow.zhm1 : Nat.ble (Host.Load.Layers.toLoad DEC_clearGrow.s0.ffi).mlx.nnext 22540 = true
theorem DEC_clearGrow.cjcl1 (h : Conv.JClean (⟨29303, 22540, 3123642, 129⟩ : Conv.Cnt) DEC_clearGrow.s4) : Conv.JClean (⟨29432, 24977, 3123900, 385⟩ : Conv.Cnt) DEC_clearGrow.s6 :=
  Conv.JClean.step h (Conv.Cnt.le_of_leB DEC_clearGrow.cle1)
    (Conv.heap_off_setAll DEC_clearGrow.cheap1 fun a ha => Nat.blt_eq.mp (List.all_eq_true.mp DEC_clearGrow.zclbd1 a ha)) DEC_clearGrow.zjc1

end Host.Load.Run.Tpl
