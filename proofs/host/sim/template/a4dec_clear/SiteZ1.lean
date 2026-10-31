import host.sim.template.a4dec_clear.SiteS1
import host.sim.template.a4dec_clear.SiteK1
import host.sim.template.a4dec_clear.SiteF1
import host.sim.conv.CompactShift
import host.sim.template.Check
import host.sim.BigFreeP
import host.sim.template.CallGen
set_option Elab.async false
namespace Host.Load.Run.Tpl
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
open Host.Ts Host.Ts.Sim Host.Ts.Sim.Template

/-! The compaction's state shift at call site 1 of chain `DEC_clear` (`Conv.compact_shift`): the call `DEC_clear.s4`, the merged
state `DEC_clear.s5`, the canonical state `DEC_clear.s6`; its frames [2673448,12504,2665,4910] (kept arrays [2673448,12504,2665]). -/

-- the map's places and counters
kernel_rfl DEC_clear.zpl1 : DEC_clear.pl1.all (Nat.ble DEC_clear.s4.next) = true
kernel_rfl DEC_clear.zplnd1 : nodupT DEC_clear.pl1 PTrie.nil = true
kernel_rfl DEC_clear.zn11 : Nat.ble DEC_clear.s4.next 3271107 = true
kernel_rfl DEC_clear.zfirst1 : Nat.ble aFirst DEC_clear.s4.next = true
kernel_rfl DEC_clear.zscn1 : DEC_clear.s6.next = DEC_clear.s4.next + DEC_clear.pl1.length
kernel_rfl DEC_clear.zsmn1 : DEC_clear.s5.next = 3271107
kernel_rfl DEC_clear.zgrow1 : Nat.ble DEC_clear.s6.next DEC_clear.s5.next = true
-- the tables
kernel_rfl DEC_clear.zfresh1 : DEC_clear.S4.tab.all (fun e => DEC_clear.cws1.all fun v => e.noVar v) = true
kernel_rfl DEC_clear.zcnd1 : nodupT DEC_clear.cws1 PTrie.nil = true
kernel_rfl DEC_clear.znrHi1 : DEC_clear.nr1.all (fun r => Nat.blt r DEC_clear.S5.tab.length) = true
-- the frames: every framed address below the call's counter; the kept arrays the chain start's, extended in the merged state
kernel_rfl DEC_clear.zfrlt1 : [2673448, 12504, 2665, 4910].all (fun a => Nat.blt a DEC_clear.s4.next) = true
kernel_rfl DEC_clear.zg1_2673448 : DEC_clear.s6.heap.get 2673448 = some (.obj (objOf DEC_clear.s6 2673448))
kernel_rfl DEC_clear.zk1_2673448 : (objOf DEC_clear.s6 2673448).kind = .array (arrOf DEC_clear.s0 2673448)
kernel_rfl DEC_clear.zm1_2673448 : DEC_clear.s5.heap.get 2673448 = some (.obj { DEC_clear.kappa1.obj (objOf DEC_clear.s6 2673448) with
  kind := .array (arrOf DEC_clear.s0 2673448 ++ (arrOf DEC_clear.s5 2673448).drop (arrOf DEC_clear.s0 2673448).length) })
kernel_rfl DEC_clear.zg1_12504 : DEC_clear.s6.heap.get 12504 = some (.obj (objOf DEC_clear.s6 12504))
kernel_rfl DEC_clear.zk1_12504 : (objOf DEC_clear.s6 12504).kind = .array (arrOf DEC_clear.s0 12504)
kernel_rfl DEC_clear.zm1_12504 : DEC_clear.s5.heap.get 12504 = some (.obj { DEC_clear.kappa1.obj (objOf DEC_clear.s6 12504) with
  kind := .array (arrOf DEC_clear.s0 12504 ++ (arrOf DEC_clear.s5 12504).drop (arrOf DEC_clear.s0 12504).length) })
kernel_rfl DEC_clear.zg1_2665 : DEC_clear.s6.heap.get 2665 = some (.obj (objOf DEC_clear.s6 2665))
kernel_rfl DEC_clear.zk1_2665 : (objOf DEC_clear.s6 2665).kind = .array (arrOf DEC_clear.s0 2665)
kernel_rfl DEC_clear.zm1_2665 : DEC_clear.s5.heap.get 2665 = some (.obj { DEC_clear.kappa1.obj (objOf DEC_clear.s6 2665) with
  kind := .array (arrOf DEC_clear.s0 2665 ++ (arrOf DEC_clear.s5 2665).drop (arrOf DEC_clear.s0 2665).length) })
kernel_rfl DEC_clear.zw1_4910 : (DEC_clear.s6.heap.get 4910).isSome = true
-- the heap: the changed list in range, holding the stage's written and fresh addresses; the canonical side's image
kernel_rfl DEC_clear.zclbd1 : DEC_clear.cl1.all (fun b => Nat.blt (b / 4096) (4 ^ 31)) = true
kernel_rfl DEC_clear.zwrN1 : Nat.ble DEC_clear.s4.next DEC_clear.st1.s0.next = true
kernel_rfl DEC_clear.zwrO1 : (Stage.rangesOf DEC_clear.st1.s150.heap DEC_clear.st1.wrR).all (fun e => !Nat.blt e.1 DEC_clear.s4.next || DEC_clear.cl1.contains e.1) = true
theorem DEC_clear.zwr1 : DEC_clear.st1.wr.all (fun b => !Nat.blt b DEC_clear.s4.next || DEC_clear.cl1.contains b) = true :=
  footW_lowAll DEC_clear.zwrN1 DEC_clear.zwrO1
def DEC_clear.zl1 : List Nat := DEC_clear.cl1.filter fun a => !(List.contains [2673448, 12504, 2665] a)
kernel_rfl DEC_clear.zimgE1 : DEC_clear.zl1.map (fun a => DEC_clear.s5.heap.get (DEC_clear.kappa1.a a)) = DEC_clear.zl1.map (fun a => (DEC_clear.s6.heap.get a).map DEC_clear.kappa1.hobj)
theorem DEC_clear.zimg1 : HeapImg DEC_clear.kappa1 DEC_clear.s6 DEC_clear.s5 DEC_clear.zl1 := DEC_clear.zimgE1
-- the roots and their supports
kernel_rfl DEC_clear.zctl1 : DEC_clear.s5.ctl = DEC_clear.kappa1.ctl DEC_clear.s6.ctl
kernel_rfl DEC_clear.zstack1 : DEC_clear.s5.stack = DEC_clear.s6.stack.map DEC_clear.kappa1.frame
kernel_rfl DEC_clear.zjobs1 : DEC_clear.s5.jobs = DEC_clear.s6.jobs.map DEC_clear.kappa1.job
kernel_rfl DEC_clear.zstores1 : DEC_clear.s5.stores = DEC_clear.kappa1.stores DEC_clear.s6.stores
kernel_rfl DEC_clear.zroots1 : checkRootsSupp DEC_clear.s6 353 = true
kernel_rfl DEC_clear.znC1 : DEC_clear.S4.tab.length + DEC_clear.cws1.length = 353
-- the map as `Conv.compact_shift` states it (the call's counters for the literals)
kernel_rfl DEC_clear.zkap1 : DEC_clear.kappa1 = Conv.Map.compact DEC_clear.s4.next 3271107 DEC_clear.S4.tab.length DEC_clear.pl1 (DEC_clear.nr1.map NumV.ref) DEC_clear.kd1.big
  DEC_clear.kd1.region DEC_clear.kd1.nodeF
-- the bridge inactive at the canonical state (`Conv.FullShiftQ.toX`; the merged state's bridge is the canonical's: cbridge)
kernel_rfl DEC_clear.zbin1 : (Host.Ts.Sim.Full.bridgeOf DEC_clear.s6.ffi).active = false
-- the JS bookkeeping's step (`Conv.JClean.step` over the changed list) and the canonical roots' bigint freedom
kernel_rfl DEC_clear.zjc1 : Conv.jcleanListB (⟨29432, 24913, 3123900, 353⟩ : Conv.Cnt) DEC_clear.s6 DEC_clear.cl1 = true
kernel_rfl DEC_clear.zroots21 : noBigRootsP (fun i => !Conv.oldBigB (⟨29432, 24913, 3123900, 353⟩ : Conv.Cnt) i) DEC_clear.s6.trace DEC_clear.s6 = true
kernel_rfl DEC_clear.zhm1 : Nat.ble (Host.Load.Layers.toLoad DEC_clear.s0.ffi).mlx.nnext 22540 = true
theorem DEC_clear.cjcl1 (h : Conv.JClean (⟨29303, 22540, 3123642, 129⟩ : Conv.Cnt) DEC_clear.s4) : Conv.JClean (⟨29432, 24913, 3123900, 353⟩ : Conv.Cnt) DEC_clear.s6 :=
  Conv.JClean.step h (Conv.Cnt.le_of_leB DEC_clear.cle1)
    (Conv.heap_off_setAll DEC_clear.cheap1 fun a ha => Nat.blt_eq.mp (List.all_eq_true.mp DEC_clear.zclbd1 a ha)) DEC_clear.zjc1

end Host.Load.Run.Tpl
