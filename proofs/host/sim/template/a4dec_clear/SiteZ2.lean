import host.sim.template.a4dec_clear.SiteS2
import host.sim.template.a4dec_clear.SiteK2
import host.sim.template.a4dec_clear.SiteF2
import host.sim.conv.CompactShift
import host.sim.template.Check
import host.sim.BigFreeP
import host.sim.template.CallGen
set_option Elab.async false
namespace Host.Load.Run.Tpl
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
open Host.Ts Host.Ts.Sim Host.Ts.Sim.Template

/-! The compaction's state shift at call site 2 of chain `DEC_clear` (`Conv.compact_shift`): the call `DEC_clear.s8`, the merged
state `DEC_clear.s9`, the canonical state `DEC_clear.s10`; its frames [2673448,12504,2665,4910] (kept arrays [2673448,12504,2665]). -/

-- the map's places and counters
kernel_rfl DEC_clear.zpl2 : DEC_clear.pl2.all (Nat.ble DEC_clear.s8.next) = true
kernel_rfl DEC_clear.zplnd2 : nodupT DEC_clear.pl2 PTrie.nil = true
kernel_rfl DEC_clear.zn12 : Nat.ble DEC_clear.s8.next 3124267 = true
kernel_rfl DEC_clear.zfirst2 : Nat.ble aFirst DEC_clear.s8.next = true
kernel_rfl DEC_clear.zscn2 : DEC_clear.s10.next = DEC_clear.s8.next + DEC_clear.pl2.length
kernel_rfl DEC_clear.zsmn2 : DEC_clear.s9.next = 3124267
kernel_rfl DEC_clear.zgrow2 : Nat.ble DEC_clear.s10.next DEC_clear.s9.next = true
-- the tables
kernel_rfl DEC_clear.zfresh2 : DEC_clear.S8.tab.all (fun e => DEC_clear.cws2.all fun v => e.noVar v) = true
kernel_rfl DEC_clear.zcnd2 : nodupT DEC_clear.cws2 PTrie.nil = true
kernel_rfl DEC_clear.znrHi2 : DEC_clear.nr2.all (fun r => Nat.blt r DEC_clear.S9.tab.length) = true
-- the frames: every framed address below the call's counter; the kept arrays the chain start's, extended in the merged state
kernel_rfl DEC_clear.zfrlt2 : [2673448, 12504, 2665, 4910].all (fun a => Nat.blt a DEC_clear.s8.next) = true
kernel_rfl DEC_clear.zg2_2673448 : DEC_clear.s10.heap.get 2673448 = some (.obj (objOf DEC_clear.s10 2673448))
kernel_rfl DEC_clear.zk2_2673448 : (objOf DEC_clear.s10 2673448).kind = .array (arrOf DEC_clear.s0 2673448)
kernel_rfl DEC_clear.zm2_2673448 : DEC_clear.s9.heap.get 2673448 = some (.obj { DEC_clear.kappa2.obj (objOf DEC_clear.s10 2673448) with
  kind := .array (arrOf DEC_clear.s0 2673448 ++ (arrOf DEC_clear.s9 2673448).drop (arrOf DEC_clear.s0 2673448).length) })
kernel_rfl DEC_clear.zg2_12504 : DEC_clear.s10.heap.get 12504 = some (.obj (objOf DEC_clear.s10 12504))
kernel_rfl DEC_clear.zk2_12504 : (objOf DEC_clear.s10 12504).kind = .array (arrOf DEC_clear.s0 12504)
kernel_rfl DEC_clear.zm2_12504 : DEC_clear.s9.heap.get 12504 = some (.obj { DEC_clear.kappa2.obj (objOf DEC_clear.s10 12504) with
  kind := .array (arrOf DEC_clear.s0 12504 ++ (arrOf DEC_clear.s9 12504).drop (arrOf DEC_clear.s0 12504).length) })
kernel_rfl DEC_clear.zg2_2665 : DEC_clear.s10.heap.get 2665 = some (.obj (objOf DEC_clear.s10 2665))
kernel_rfl DEC_clear.zk2_2665 : (objOf DEC_clear.s10 2665).kind = .array (arrOf DEC_clear.s0 2665)
kernel_rfl DEC_clear.zm2_2665 : DEC_clear.s9.heap.get 2665 = some (.obj { DEC_clear.kappa2.obj (objOf DEC_clear.s10 2665) with
  kind := .array (arrOf DEC_clear.s0 2665 ++ (arrOf DEC_clear.s9 2665).drop (arrOf DEC_clear.s0 2665).length) })
kernel_rfl DEC_clear.zw2_4910 : (DEC_clear.s10.heap.get 4910).isSome = true
-- the heap: the changed list in range, holding the stage's written and fresh addresses; the canonical side's image
kernel_rfl DEC_clear.zclbd2 : DEC_clear.cl2.all (fun b => Nat.blt (b / 4096) (4 ^ 31)) = true
kernel_rfl DEC_clear.zwr2 : DEC_clear.st2.wr.all (fun b => !Nat.blt b DEC_clear.s8.next || DEC_clear.cl2.contains b) = true
def DEC_clear.zl2 : List Nat := DEC_clear.cl2.filter fun a => !(List.contains [2673448, 12504, 2665] a)
kernel_rfl DEC_clear.zimgE2 : DEC_clear.zl2.map (fun a => DEC_clear.s9.heap.get (DEC_clear.kappa2.a a)) = DEC_clear.zl2.map (fun a => (DEC_clear.s10.heap.get a).map DEC_clear.kappa2.hobj)
theorem DEC_clear.zimg2 : HeapImg DEC_clear.kappa2 DEC_clear.s10 DEC_clear.s9 DEC_clear.zl2 := DEC_clear.zimgE2
-- the roots and their supports
kernel_rfl DEC_clear.zctl2 : DEC_clear.s9.ctl = DEC_clear.kappa2.ctl DEC_clear.s10.ctl
kernel_rfl DEC_clear.zstack2 : DEC_clear.s9.stack = DEC_clear.s10.stack.map DEC_clear.kappa2.frame
kernel_rfl DEC_clear.zjobs2 : DEC_clear.s9.jobs = DEC_clear.s10.jobs.map DEC_clear.kappa2.job
kernel_rfl DEC_clear.zstores2 : DEC_clear.s9.stores = DEC_clear.kappa2.stores DEC_clear.s10.stores
kernel_rfl DEC_clear.zroots2 : checkRootsSupp DEC_clear.s10 354 = true
kernel_rfl DEC_clear.znC2 : DEC_clear.S8.tab.length + DEC_clear.cws2.length = 354
-- the map as `Conv.compact_shift` states it (the call's counters for the literals)
kernel_rfl DEC_clear.zkap2 : DEC_clear.kappa2 = Conv.Map.compact DEC_clear.s8.next 3124267 DEC_clear.S8.tab.length DEC_clear.pl2 (DEC_clear.nr2.map NumV.ref) DEC_clear.kd2.big
  DEC_clear.kd2.region DEC_clear.kd2.nodeF
-- the bridge inactive at the canonical state (`Conv.FullShiftQ.toX`; the merged state's bridge is the canonical's: cbridge)
kernel_rfl DEC_clear.zbin2 : (Host.Ts.Sim.Full.bridgeOf DEC_clear.s10.ffi).active = false
-- the JS bookkeeping's step (`Conv.JClean.step` over the changed list) and the canonical roots' bigint freedom
kernel_rfl DEC_clear.zjc2 : Conv.jcleanListB (⟨29440, 24920, 3124248, 354⟩ : Conv.Cnt) DEC_clear.s10 DEC_clear.cl2 = true
kernel_rfl DEC_clear.zroots22 : noBigRootsP (fun i => !Conv.oldBigB (⟨29440, 24920, 3124248, 354⟩ : Conv.Cnt) i) DEC_clear.s10.trace DEC_clear.s10 = true
kernel_rfl DEC_clear.zhm2 : Nat.ble (Host.Load.Layers.toLoad DEC_clear.s0.ffi).mlx.nnext 24920 = true
theorem DEC_clear.cjcl2 (h : Conv.JClean (⟨29440, 24920, 3124248, 354⟩ : Conv.Cnt) DEC_clear.s8) : Conv.JClean (⟨29440, 24920, 3124248, 354⟩ : Conv.Cnt) DEC_clear.s10 :=
  Conv.JClean.step h (Conv.Cnt.le_of_leB DEC_clear.cle2)
    (Conv.heap_off_setAll DEC_clear.cheap2 fun a ha => Nat.blt_eq.mp (List.all_eq_true.mp DEC_clear.zclbd2 a ha)) DEC_clear.zjc2

end Host.Load.Run.Tpl
