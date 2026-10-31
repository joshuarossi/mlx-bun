import host.sim.template.a4dec_grow.SiteS1
import host.sim.template.a4dec_grow.SiteK1
import host.sim.template.a4dec_grow.SiteF1
import host.sim.conv.CompactShift
import host.sim.template.Check
import host.sim.BigFreeP
import host.sim.template.CallGen
set_option Elab.async false
namespace Host.Load.Run.Tpl
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
open Host.Ts Host.Ts.Sim Host.Ts.Sim.Template

/-! The compaction's state shift at call site 1 of chain `DEC_grow` (`Conv.compact_shift`): the call `DEC_grow.s4`, the merged
state `DEC_grow.s5`, the canonical state `DEC_grow.s6`; its frames [2673448,12504,2665,4910] (kept arrays [2673448,12504,2665]). -/

-- the map's places and counters
kernel_rfl DEC_grow.zpl1 : DEC_grow.pl1.all (Nat.ble DEC_grow.s4.next) = true
kernel_rfl DEC_grow.zplnd1 : nodupT DEC_grow.pl1 PTrie.nil = true
kernel_rfl DEC_grow.zn11 : Nat.ble DEC_grow.s4.next 3274242 = true
kernel_rfl DEC_grow.zfirst1 : Nat.ble aFirst DEC_grow.s4.next = true
kernel_rfl DEC_grow.zscn1 : DEC_grow.s6.next = DEC_grow.s4.next + DEC_grow.pl1.length
kernel_rfl DEC_grow.zsmn1 : DEC_grow.s5.next = 3274242
kernel_rfl DEC_grow.zgrow1 : Nat.ble DEC_grow.s6.next DEC_grow.s5.next = true
-- the tables
kernel_rfl DEC_grow.zfresh1 : DEC_grow.S4.tab.all (fun e => DEC_grow.cws1.all fun v => e.noVar v) = true
kernel_rfl DEC_grow.zcnd1 : nodupT DEC_grow.cws1 PTrie.nil = true
kernel_rfl DEC_grow.znrHi1 : DEC_grow.nr1.all (fun r => Nat.blt r DEC_grow.S5.tab.length) = true
-- the frames: every framed address below the call's counter; the kept arrays the chain start's, extended in the merged state
kernel_rfl DEC_grow.zfrlt1 : [2673448, 12504, 2665, 4910].all (fun a => Nat.blt a DEC_grow.s4.next) = true
kernel_rfl DEC_grow.zg1_2673448 : DEC_grow.s6.heap.get 2673448 = some (.obj (objOf DEC_grow.s6 2673448))
kernel_rfl DEC_grow.zk1_2673448 : (objOf DEC_grow.s6 2673448).kind = .array (arrOf DEC_grow.s0 2673448)
kernel_rfl DEC_grow.zm1_2673448 : DEC_grow.s5.heap.get 2673448 = some (.obj { DEC_grow.kappa1.obj (objOf DEC_grow.s6 2673448) with
  kind := .array (arrOf DEC_grow.s0 2673448 ++ (arrOf DEC_grow.s5 2673448).drop (arrOf DEC_grow.s0 2673448).length) })
kernel_rfl DEC_grow.zg1_12504 : DEC_grow.s6.heap.get 12504 = some (.obj (objOf DEC_grow.s6 12504))
kernel_rfl DEC_grow.zk1_12504 : (objOf DEC_grow.s6 12504).kind = .array (arrOf DEC_grow.s0 12504)
kernel_rfl DEC_grow.zm1_12504 : DEC_grow.s5.heap.get 12504 = some (.obj { DEC_grow.kappa1.obj (objOf DEC_grow.s6 12504) with
  kind := .array (arrOf DEC_grow.s0 12504 ++ (arrOf DEC_grow.s5 12504).drop (arrOf DEC_grow.s0 12504).length) })
kernel_rfl DEC_grow.zg1_2665 : DEC_grow.s6.heap.get 2665 = some (.obj (objOf DEC_grow.s6 2665))
kernel_rfl DEC_grow.zk1_2665 : (objOf DEC_grow.s6 2665).kind = .array (arrOf DEC_grow.s0 2665)
kernel_rfl DEC_grow.zm1_2665 : DEC_grow.s5.heap.get 2665 = some (.obj { DEC_grow.kappa1.obj (objOf DEC_grow.s6 2665) with
  kind := .array (arrOf DEC_grow.s0 2665 ++ (arrOf DEC_grow.s5 2665).drop (arrOf DEC_grow.s0 2665).length) })
kernel_rfl DEC_grow.zw1_4910 : (DEC_grow.s6.heap.get 4910).isSome = true
-- the heap: the changed list in range, holding the stage's written and fresh addresses; the canonical side's image
kernel_rfl DEC_grow.zclbd1 : DEC_grow.cl1.all (fun b => Nat.blt (b / 4096) (4 ^ 31)) = true
kernel_rfl DEC_grow.zwrN1 : Nat.ble DEC_grow.s4.next DEC_grow.st1.s0.next = true
kernel_rfl DEC_grow.zwrO1 : (Stage.rangesOf DEC_grow.st1.s153.heap DEC_grow.st1.wrR).all (fun e => !Nat.blt e.1 DEC_grow.s4.next || DEC_grow.cl1.contains e.1) = true
theorem DEC_grow.zwr1 : DEC_grow.st1.wr.all (fun b => !Nat.blt b DEC_grow.s4.next || DEC_grow.cl1.contains b) = true :=
  footW_lowAll DEC_grow.zwrN1 DEC_grow.zwrO1
def DEC_grow.zl1 : List Nat := DEC_grow.cl1.filter fun a => !(List.contains [2673448, 12504, 2665] a)
kernel_rfl DEC_grow.zimgE1 : DEC_grow.zl1.map (fun a => DEC_grow.s5.heap.get (DEC_grow.kappa1.a a)) = DEC_grow.zl1.map (fun a => (DEC_grow.s6.heap.get a).map DEC_grow.kappa1.hobj)
theorem DEC_grow.zimg1 : HeapImg DEC_grow.kappa1 DEC_grow.s6 DEC_grow.s5 DEC_grow.zl1 := DEC_grow.zimgE1
-- the roots and their supports
kernel_rfl DEC_grow.zctl1 : DEC_grow.s5.ctl = DEC_grow.kappa1.ctl DEC_grow.s6.ctl
kernel_rfl DEC_grow.zstack1 : DEC_grow.s5.stack = DEC_grow.s6.stack.map DEC_grow.kappa1.frame
kernel_rfl DEC_grow.zjobs1 : DEC_grow.s5.jobs = DEC_grow.s6.jobs.map DEC_grow.kappa1.job
kernel_rfl DEC_grow.zstores1 : DEC_grow.s5.stores = DEC_grow.kappa1.stores DEC_grow.s6.stores
kernel_rfl DEC_grow.zroots1 : checkRootsSupp DEC_grow.s6 385 = true
kernel_rfl DEC_grow.znC1 : DEC_grow.S4.tab.length + DEC_grow.cws1.length = 385
-- the map as `Conv.compact_shift` states it (the call's counters for the literals)
kernel_rfl DEC_grow.zkap1 : DEC_grow.kappa1 = Conv.Map.compact DEC_grow.s4.next 3274242 DEC_grow.S4.tab.length DEC_grow.pl1 (DEC_grow.nr1.map NumV.ref) DEC_grow.kd1.big
  DEC_grow.kd1.region DEC_grow.kd1.nodeF
-- the bridge inactive at the canonical state (`Conv.FullShiftQ.toX`; the merged state's bridge is the canonical's: cbridge)
kernel_rfl DEC_grow.zbin1 : (Host.Ts.Sim.Full.bridgeOf DEC_grow.s6.ffi).active = false
-- the JS bookkeeping's step (`Conv.JClean.step` over the changed list) and the canonical roots' bigint freedom
kernel_rfl DEC_grow.zjc1 : Conv.jcleanListB (⟨29432, 24977, 3123899, 385⟩ : Conv.Cnt) DEC_grow.s6 DEC_grow.cl1 = true
kernel_rfl DEC_grow.zroots21 : noBigRootsP (fun i => !Conv.oldBigB (⟨29432, 24977, 3123899, 385⟩ : Conv.Cnt) i) DEC_grow.s6.trace DEC_grow.s6 = true
kernel_rfl DEC_grow.zhm1 : Nat.ble (Host.Load.Layers.toLoad DEC_grow.s0.ffi).mlx.nnext 22540 = true
theorem DEC_grow.cjcl1 (h : Conv.JClean (⟨29303, 22540, 3123641, 129⟩ : Conv.Cnt) DEC_grow.s4) : Conv.JClean (⟨29432, 24977, 3123899, 385⟩ : Conv.Cnt) DEC_grow.s6 :=
  Conv.JClean.step h (Conv.Cnt.le_of_leB DEC_grow.cle1)
    (Conv.heap_off_setAll DEC_grow.cheap1 fun a ha => Nat.blt_eq.mp (List.all_eq_true.mp DEC_grow.zclbd1 a ha)) DEC_grow.zjc1

end Host.Load.Run.Tpl
