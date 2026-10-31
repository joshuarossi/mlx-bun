import host.sim.template.a4dec_clearGrow.SiteS2
import host.sim.template.a4dec_clearGrow.SiteK2
import host.sim.template.a4dec_clearGrow.SiteF2
import host.sim.conv.CompactShift
import host.sim.template.Check
import host.sim.BigFreeP
import host.sim.template.CallGen
set_option Elab.async false
namespace Host.Load.Run.Tpl
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
open Host.Ts Host.Ts.Sim Host.Ts.Sim.Template

/-! The compaction's state shift at call site 2 of chain `DEC_clearGrow` (`Conv.compact_shift`): the call `DEC_clearGrow.s8`, the merged
state `DEC_clearGrow.s9`, the canonical state `DEC_clearGrow.s10`; its frames [2673448,12504,2665,4910] (kept arrays [2673448,12504,2665]). -/

-- the map's places and counters
kernel_rfl DEC_clearGrow.zpl2 : DEC_clearGrow.pl2.all (Nat.ble DEC_clearGrow.s8.next) = true
kernel_rfl DEC_clearGrow.zplnd2 : nodupT DEC_clearGrow.pl2 PTrie.nil = true
kernel_rfl DEC_clearGrow.zn12 : Nat.ble DEC_clearGrow.s8.next 3124267 = true
kernel_rfl DEC_clearGrow.zfirst2 : Nat.ble aFirst DEC_clearGrow.s8.next = true
kernel_rfl DEC_clearGrow.zscn2 : DEC_clearGrow.s10.next = DEC_clearGrow.s8.next + DEC_clearGrow.pl2.length
kernel_rfl DEC_clearGrow.zsmn2 : DEC_clearGrow.s9.next = 3124267
kernel_rfl DEC_clearGrow.zgrow2 : Nat.ble DEC_clearGrow.s10.next DEC_clearGrow.s9.next = true
-- the tables
kernel_rfl DEC_clearGrow.zfresh2 : DEC_clearGrow.S8.tab.all (fun e => DEC_clearGrow.cws2.all fun v => e.noVar v) = true
kernel_rfl DEC_clearGrow.zcnd2 : nodupT DEC_clearGrow.cws2 PTrie.nil = true
kernel_rfl DEC_clearGrow.znrHi2 : DEC_clearGrow.nr2.all (fun r => Nat.blt r DEC_clearGrow.S9.tab.length) = true
-- the frames: every framed address below the call's counter; the kept arrays the chain start's, extended in the merged state
kernel_rfl DEC_clearGrow.zfrlt2 : [2673448, 12504, 2665, 4910].all (fun a => Nat.blt a DEC_clearGrow.s8.next) = true
kernel_rfl DEC_clearGrow.zg2_2673448 : DEC_clearGrow.s10.heap.get 2673448 = some (.obj (objOf DEC_clearGrow.s10 2673448))
kernel_rfl DEC_clearGrow.zk2_2673448 : (objOf DEC_clearGrow.s10 2673448).kind = .array (arrOf DEC_clearGrow.s0 2673448)
kernel_rfl DEC_clearGrow.zm2_2673448 : DEC_clearGrow.s9.heap.get 2673448 = some (.obj { DEC_clearGrow.kappa2.obj (objOf DEC_clearGrow.s10 2673448) with
  kind := .array (arrOf DEC_clearGrow.s0 2673448 ++ (arrOf DEC_clearGrow.s9 2673448).drop (arrOf DEC_clearGrow.s0 2673448).length) })
kernel_rfl DEC_clearGrow.zg2_12504 : DEC_clearGrow.s10.heap.get 12504 = some (.obj (objOf DEC_clearGrow.s10 12504))
kernel_rfl DEC_clearGrow.zk2_12504 : (objOf DEC_clearGrow.s10 12504).kind = .array (arrOf DEC_clearGrow.s0 12504)
kernel_rfl DEC_clearGrow.zm2_12504 : DEC_clearGrow.s9.heap.get 12504 = some (.obj { DEC_clearGrow.kappa2.obj (objOf DEC_clearGrow.s10 12504) with
  kind := .array (arrOf DEC_clearGrow.s0 12504 ++ (arrOf DEC_clearGrow.s9 12504).drop (arrOf DEC_clearGrow.s0 12504).length) })
kernel_rfl DEC_clearGrow.zg2_2665 : DEC_clearGrow.s10.heap.get 2665 = some (.obj (objOf DEC_clearGrow.s10 2665))
kernel_rfl DEC_clearGrow.zk2_2665 : (objOf DEC_clearGrow.s10 2665).kind = .array (arrOf DEC_clearGrow.s0 2665)
kernel_rfl DEC_clearGrow.zm2_2665 : DEC_clearGrow.s9.heap.get 2665 = some (.obj { DEC_clearGrow.kappa2.obj (objOf DEC_clearGrow.s10 2665) with
  kind := .array (arrOf DEC_clearGrow.s0 2665 ++ (arrOf DEC_clearGrow.s9 2665).drop (arrOf DEC_clearGrow.s0 2665).length) })
kernel_rfl DEC_clearGrow.zw2_4910 : (DEC_clearGrow.s10.heap.get 4910).isSome = true
-- the heap: the changed list in range, holding the stage's written and fresh addresses; the canonical side's image
kernel_rfl DEC_clearGrow.zclbd2 : DEC_clearGrow.cl2.all (fun b => Nat.blt (b / 4096) (4 ^ 31)) = true
kernel_rfl DEC_clearGrow.zwr2 : DEC_clearGrow.st2.wr.all (fun b => !Nat.blt b DEC_clearGrow.s8.next || DEC_clearGrow.cl2.contains b) = true
def DEC_clearGrow.zl2 : List Nat := DEC_clearGrow.cl2.filter fun a => !(List.contains [2673448, 12504, 2665] a)
kernel_rfl DEC_clearGrow.zimgE2 : DEC_clearGrow.zl2.map (fun a => DEC_clearGrow.s9.heap.get (DEC_clearGrow.kappa2.a a)) = DEC_clearGrow.zl2.map (fun a => (DEC_clearGrow.s10.heap.get a).map DEC_clearGrow.kappa2.hobj)
theorem DEC_clearGrow.zimg2 : HeapImg DEC_clearGrow.kappa2 DEC_clearGrow.s10 DEC_clearGrow.s9 DEC_clearGrow.zl2 := DEC_clearGrow.zimgE2
-- the roots and their supports
kernel_rfl DEC_clearGrow.zctl2 : DEC_clearGrow.s9.ctl = DEC_clearGrow.kappa2.ctl DEC_clearGrow.s10.ctl
kernel_rfl DEC_clearGrow.zstack2 : DEC_clearGrow.s9.stack = DEC_clearGrow.s10.stack.map DEC_clearGrow.kappa2.frame
kernel_rfl DEC_clearGrow.zjobs2 : DEC_clearGrow.s9.jobs = DEC_clearGrow.s10.jobs.map DEC_clearGrow.kappa2.job
kernel_rfl DEC_clearGrow.zstores2 : DEC_clearGrow.s9.stores = DEC_clearGrow.kappa2.stores DEC_clearGrow.s10.stores
kernel_rfl DEC_clearGrow.zroots2 : checkRootsSupp DEC_clearGrow.s10 386 = true
kernel_rfl DEC_clearGrow.znC2 : DEC_clearGrow.S8.tab.length + DEC_clearGrow.cws2.length = 386
-- the map as `Conv.compact_shift` states it (the call's counters for the literals)
kernel_rfl DEC_clearGrow.zkap2 : DEC_clearGrow.kappa2 = Conv.Map.compact DEC_clearGrow.s8.next 3124267 DEC_clearGrow.S8.tab.length DEC_clearGrow.pl2 (DEC_clearGrow.nr2.map NumV.ref) DEC_clearGrow.kd2.big
  DEC_clearGrow.kd2.region DEC_clearGrow.kd2.nodeF
-- the bridge inactive at the canonical state (`Conv.FullShiftQ.toX`; the merged state's bridge is the canonical's: cbridge)
kernel_rfl DEC_clearGrow.zbin2 : (Host.Ts.Sim.Full.bridgeOf DEC_clearGrow.s10.ffi).active = false
-- the JS bookkeeping's step (`Conv.JClean.step` over the changed list) and the canonical roots' bigint freedom
kernel_rfl DEC_clearGrow.zjc2 : Conv.jcleanListB (⟨29440, 24984, 3124248, 386⟩ : Conv.Cnt) DEC_clearGrow.s10 DEC_clearGrow.cl2 = true
kernel_rfl DEC_clearGrow.zroots22 : noBigRootsP (fun i => !Conv.oldBigB (⟨29440, 24984, 3124248, 386⟩ : Conv.Cnt) i) DEC_clearGrow.s10.trace DEC_clearGrow.s10 = true
kernel_rfl DEC_clearGrow.zhm2 : Nat.ble (Host.Load.Layers.toLoad DEC_clearGrow.s0.ffi).mlx.nnext 24984 = true
theorem DEC_clearGrow.cjcl2 (h : Conv.JClean (⟨29440, 24984, 3124248, 386⟩ : Conv.Cnt) DEC_clearGrow.s8) : Conv.JClean (⟨29440, 24984, 3124248, 386⟩ : Conv.Cnt) DEC_clearGrow.s10 :=
  Conv.JClean.step h (Conv.Cnt.le_of_leB DEC_clearGrow.cle2)
    (Conv.heap_off_setAll DEC_clearGrow.cheap2 fun a ha => Nat.blt_eq.mp (List.all_eq_true.mp DEC_clearGrow.zclbd2 a ha)) DEC_clearGrow.zjc2

end Host.Load.Run.Tpl
