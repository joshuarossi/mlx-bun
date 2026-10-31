import host.sim.template.a4dec_ord.SiteS1
import host.sim.template.a4dec_ord.SiteK1
import host.sim.template.a4dec_ord.SiteF1
import host.sim.conv.CompactShift
import host.sim.template.Check
import host.sim.BigFreeP
import host.sim.template.CallGen
set_option Elab.async false
namespace Host.Load.Run.Tpl
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
open Host.Ts Host.Ts.Sim Host.Ts.Sim.Template

/-! The compaction's state shift at call site 1 of chain `DEC_ord` (`Conv.compact_shift`): the call `DEC_ord.s4`, the merged
state `DEC_ord.s5`, the canonical state `DEC_ord.s6`; its frames [2673448,12504,2665,4910] (kept arrays [2673448,12504,2665]). -/

-- the map's places and counters
kernel_rfl DEC_ord.zpl1 : DEC_ord.pl1.all (Nat.ble DEC_ord.s4.next) = true
kernel_rfl DEC_ord.zplnd1 : nodupT DEC_ord.pl1 PTrie.nil = true
kernel_rfl DEC_ord.zn11 : Nat.ble DEC_ord.s4.next 3271106 = true
kernel_rfl DEC_ord.zfirst1 : Nat.ble aFirst DEC_ord.s4.next = true
kernel_rfl DEC_ord.zscn1 : DEC_ord.s6.next = DEC_ord.s4.next + DEC_ord.pl1.length
kernel_rfl DEC_ord.zsmn1 : DEC_ord.s5.next = 3271106
kernel_rfl DEC_ord.zgrow1 : Nat.ble DEC_ord.s6.next DEC_ord.s5.next = true
-- the tables
kernel_rfl DEC_ord.zfresh1 : DEC_ord.S4.tab.all (fun e => DEC_ord.cws1.all fun v => e.noVar v) = true
kernel_rfl DEC_ord.zcnd1 : nodupT DEC_ord.cws1 PTrie.nil = true
kernel_rfl DEC_ord.znrHi1 : DEC_ord.nr1.all (fun r => Nat.blt r DEC_ord.S5.tab.length) = true
-- the frames: every framed address below the call's counter; the kept arrays the chain start's, extended in the merged state
kernel_rfl DEC_ord.zfrlt1 : [2673448, 12504, 2665, 4910].all (fun a => Nat.blt a DEC_ord.s4.next) = true
kernel_rfl DEC_ord.zg1_2673448 : DEC_ord.s6.heap.get 2673448 = some (.obj (objOf DEC_ord.s6 2673448))
kernel_rfl DEC_ord.zk1_2673448 : (objOf DEC_ord.s6 2673448).kind = .array (arrOf DEC_ord.s0 2673448)
kernel_rfl DEC_ord.zm1_2673448 : DEC_ord.s5.heap.get 2673448 = some (.obj { DEC_ord.kappa1.obj (objOf DEC_ord.s6 2673448) with
  kind := .array (arrOf DEC_ord.s0 2673448 ++ (arrOf DEC_ord.s5 2673448).drop (arrOf DEC_ord.s0 2673448).length) })
kernel_rfl DEC_ord.zg1_12504 : DEC_ord.s6.heap.get 12504 = some (.obj (objOf DEC_ord.s6 12504))
kernel_rfl DEC_ord.zk1_12504 : (objOf DEC_ord.s6 12504).kind = .array (arrOf DEC_ord.s0 12504)
kernel_rfl DEC_ord.zm1_12504 : DEC_ord.s5.heap.get 12504 = some (.obj { DEC_ord.kappa1.obj (objOf DEC_ord.s6 12504) with
  kind := .array (arrOf DEC_ord.s0 12504 ++ (arrOf DEC_ord.s5 12504).drop (arrOf DEC_ord.s0 12504).length) })
kernel_rfl DEC_ord.zg1_2665 : DEC_ord.s6.heap.get 2665 = some (.obj (objOf DEC_ord.s6 2665))
kernel_rfl DEC_ord.zk1_2665 : (objOf DEC_ord.s6 2665).kind = .array (arrOf DEC_ord.s0 2665)
kernel_rfl DEC_ord.zm1_2665 : DEC_ord.s5.heap.get 2665 = some (.obj { DEC_ord.kappa1.obj (objOf DEC_ord.s6 2665) with
  kind := .array (arrOf DEC_ord.s0 2665 ++ (arrOf DEC_ord.s5 2665).drop (arrOf DEC_ord.s0 2665).length) })
kernel_rfl DEC_ord.zw1_4910 : (DEC_ord.s6.heap.get 4910).isSome = true
-- the heap: the changed list in range, holding the stage's written and fresh addresses; the canonical side's image
kernel_rfl DEC_ord.zclbd1 : DEC_ord.cl1.all (fun b => Nat.blt (b / 4096) (4 ^ 31)) = true
kernel_rfl DEC_ord.zwrN1 : Nat.ble DEC_ord.s4.next DEC_ord.st1.s0.next = true
kernel_rfl DEC_ord.zwrO1 : (Stage.rangesOf DEC_ord.st1.s150.heap DEC_ord.st1.wrR).all (fun e => !Nat.blt e.1 DEC_ord.s4.next || DEC_ord.cl1.contains e.1) = true
theorem DEC_ord.zwr1 : DEC_ord.st1.wr.all (fun b => !Nat.blt b DEC_ord.s4.next || DEC_ord.cl1.contains b) = true :=
  footW_lowAll DEC_ord.zwrN1 DEC_ord.zwrO1
def DEC_ord.zl1 : List Nat := DEC_ord.cl1.filter fun a => !(List.contains [2673448, 12504, 2665] a)
kernel_rfl DEC_ord.zimgE1 : DEC_ord.zl1.map (fun a => DEC_ord.s5.heap.get (DEC_ord.kappa1.a a)) = DEC_ord.zl1.map (fun a => (DEC_ord.s6.heap.get a).map DEC_ord.kappa1.hobj)
theorem DEC_ord.zimg1 : HeapImg DEC_ord.kappa1 DEC_ord.s6 DEC_ord.s5 DEC_ord.zl1 := DEC_ord.zimgE1
-- the roots and their supports
kernel_rfl DEC_ord.zctl1 : DEC_ord.s5.ctl = DEC_ord.kappa1.ctl DEC_ord.s6.ctl
kernel_rfl DEC_ord.zstack1 : DEC_ord.s5.stack = DEC_ord.s6.stack.map DEC_ord.kappa1.frame
kernel_rfl DEC_ord.zjobs1 : DEC_ord.s5.jobs = DEC_ord.s6.jobs.map DEC_ord.kappa1.job
kernel_rfl DEC_ord.zstores1 : DEC_ord.s5.stores = DEC_ord.kappa1.stores DEC_ord.s6.stores
kernel_rfl DEC_ord.zroots1 : checkRootsSupp DEC_ord.s6 353 = true
kernel_rfl DEC_ord.znC1 : DEC_ord.S4.tab.length + DEC_ord.cws1.length = 353
-- the map as `Conv.compact_shift` states it (the call's counters for the literals)
kernel_rfl DEC_ord.zkap1 : DEC_ord.kappa1 = Conv.Map.compact DEC_ord.s4.next 3271106 DEC_ord.S4.tab.length DEC_ord.pl1 (DEC_ord.nr1.map NumV.ref) DEC_ord.kd1.big
  DEC_ord.kd1.region DEC_ord.kd1.nodeF
-- the bridge inactive at the canonical state (`Conv.FullShiftQ.toX`; the merged state's bridge is the canonical's: cbridge)
kernel_rfl DEC_ord.zbin1 : (Host.Ts.Sim.Full.bridgeOf DEC_ord.s6.ffi).active = false
-- the JS bookkeeping's step (`Conv.JClean.step` over the changed list) and the canonical roots' bigint freedom
kernel_rfl DEC_ord.zjc1 : Conv.jcleanListB (⟨29432, 24913, 3123899, 353⟩ : Conv.Cnt) DEC_ord.s6 DEC_ord.cl1 = true
kernel_rfl DEC_ord.zroots21 : noBigRootsP (fun i => !Conv.oldBigB (⟨29432, 24913, 3123899, 353⟩ : Conv.Cnt) i) DEC_ord.s6.trace DEC_ord.s6 = true
kernel_rfl DEC_ord.zhm1 : Nat.ble (Host.Load.Layers.toLoad DEC_ord.s0.ffi).mlx.nnext 22540 = true
theorem DEC_ord.cjcl1 (h : Conv.JClean (⟨29303, 22540, 3123641, 129⟩ : Conv.Cnt) DEC_ord.s4) : Conv.JClean (⟨29432, 24913, 3123899, 353⟩ : Conv.Cnt) DEC_ord.s6 :=
  Conv.JClean.step h (Conv.Cnt.le_of_leB DEC_ord.cle1)
    (Conv.heap_off_setAll DEC_ord.cheap1 fun a ha => Nat.blt_eq.mp (List.all_eq_true.mp DEC_ord.zclbd1 a ha)) DEC_ord.zjc1

end Host.Load.Run.Tpl
