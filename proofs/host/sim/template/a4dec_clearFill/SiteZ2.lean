import host.sim.template.a4dec_clearFill.SiteS2
import host.sim.template.a4dec_clearFill.SiteK2
import host.sim.template.a4dec_clearFill.SiteF2
import host.sim.conv.CompactShift
import host.sim.template.Check
import host.sim.BigFreeP
import host.sim.template.CallGen
set_option Elab.async false
namespace Host.Load.Run.Tpl
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
open Host.Ts Host.Ts.Sim Host.Ts.Sim.Template

/-! The compaction's state shift at call site 2 of chain `DEC_clearFill` (`Conv.compact_shift`): the call `DEC_clearFill.s8`, the merged
state `DEC_clearFill.s9`, the canonical state `DEC_clearFill.s10`; its frames [2673448,12504,2665,4910] (kept arrays [2673448,12504,2665]). -/

-- the map's places and counters
kernel_rfl DEC_clearFill.zpl2 : DEC_clearFill.pl2.all (Nat.ble DEC_clearFill.s8.next) = true
kernel_rfl DEC_clearFill.zplnd2 : nodupT DEC_clearFill.pl2 PTrie.nil = true
kernel_rfl DEC_clearFill.zn12 : Nat.ble DEC_clearFill.s8.next 3124267 = true
kernel_rfl DEC_clearFill.zfirst2 : Nat.ble aFirst DEC_clearFill.s8.next = true
kernel_rfl DEC_clearFill.zscn2 : DEC_clearFill.s10.next = DEC_clearFill.s8.next + DEC_clearFill.pl2.length
kernel_rfl DEC_clearFill.zsmn2 : DEC_clearFill.s9.next = 3124267
kernel_rfl DEC_clearFill.zgrow2 : Nat.ble DEC_clearFill.s10.next DEC_clearFill.s9.next = true
-- the tables
kernel_rfl DEC_clearFill.zfresh2 : DEC_clearFill.S8.tab.all (fun e => DEC_clearFill.cws2.all fun v => e.noVar v) = true
kernel_rfl DEC_clearFill.zcnd2 : nodupT DEC_clearFill.cws2 PTrie.nil = true
kernel_rfl DEC_clearFill.znrHi2 : DEC_clearFill.nr2.all (fun r => Nat.blt r DEC_clearFill.S9.tab.length) = true
-- the frames: every framed address below the call's counter; the kept arrays the chain start's, extended in the merged state
kernel_rfl DEC_clearFill.zfrlt2 : [2673448, 12504, 2665, 4910].all (fun a => Nat.blt a DEC_clearFill.s8.next) = true
kernel_rfl DEC_clearFill.zg2_2673448 : DEC_clearFill.s10.heap.get 2673448 = some (.obj (objOf DEC_clearFill.s10 2673448))
kernel_rfl DEC_clearFill.zk2_2673448 : (objOf DEC_clearFill.s10 2673448).kind = .array (arrOf DEC_clearFill.s0 2673448)
kernel_rfl DEC_clearFill.zm2_2673448 : DEC_clearFill.s9.heap.get 2673448 = some (.obj { DEC_clearFill.kappa2.obj (objOf DEC_clearFill.s10 2673448) with
  kind := .array (arrOf DEC_clearFill.s0 2673448 ++ (arrOf DEC_clearFill.s9 2673448).drop (arrOf DEC_clearFill.s0 2673448).length) })
kernel_rfl DEC_clearFill.zg2_12504 : DEC_clearFill.s10.heap.get 12504 = some (.obj (objOf DEC_clearFill.s10 12504))
kernel_rfl DEC_clearFill.zk2_12504 : (objOf DEC_clearFill.s10 12504).kind = .array (arrOf DEC_clearFill.s0 12504)
kernel_rfl DEC_clearFill.zm2_12504 : DEC_clearFill.s9.heap.get 12504 = some (.obj { DEC_clearFill.kappa2.obj (objOf DEC_clearFill.s10 12504) with
  kind := .array (arrOf DEC_clearFill.s0 12504 ++ (arrOf DEC_clearFill.s9 12504).drop (arrOf DEC_clearFill.s0 12504).length) })
kernel_rfl DEC_clearFill.zg2_2665 : DEC_clearFill.s10.heap.get 2665 = some (.obj (objOf DEC_clearFill.s10 2665))
kernel_rfl DEC_clearFill.zk2_2665 : (objOf DEC_clearFill.s10 2665).kind = .array (arrOf DEC_clearFill.s0 2665)
kernel_rfl DEC_clearFill.zm2_2665 : DEC_clearFill.s9.heap.get 2665 = some (.obj { DEC_clearFill.kappa2.obj (objOf DEC_clearFill.s10 2665) with
  kind := .array (arrOf DEC_clearFill.s0 2665 ++ (arrOf DEC_clearFill.s9 2665).drop (arrOf DEC_clearFill.s0 2665).length) })
kernel_rfl DEC_clearFill.zw2_4910 : (DEC_clearFill.s10.heap.get 4910).isSome = true
-- the heap: the changed list in range, holding the stage's written and fresh addresses; the canonical side's image
kernel_rfl DEC_clearFill.zclbd2 : DEC_clearFill.cl2.all (fun b => Nat.blt (b / 4096) (4 ^ 31)) = true
kernel_rfl DEC_clearFill.zwr2 : DEC_clearFill.st2.wr.all (fun b => !Nat.blt b DEC_clearFill.s8.next || DEC_clearFill.cl2.contains b) = true
def DEC_clearFill.zl2 : List Nat := DEC_clearFill.cl2.filter fun a => !(List.contains [2673448, 12504, 2665] a)
kernel_rfl DEC_clearFill.zimgE2 : DEC_clearFill.zl2.map (fun a => DEC_clearFill.s9.heap.get (DEC_clearFill.kappa2.a a)) = DEC_clearFill.zl2.map (fun a => (DEC_clearFill.s10.heap.get a).map DEC_clearFill.kappa2.hobj)
theorem DEC_clearFill.zimg2 : HeapImg DEC_clearFill.kappa2 DEC_clearFill.s10 DEC_clearFill.s9 DEC_clearFill.zl2 := DEC_clearFill.zimgE2
-- the roots and their supports
kernel_rfl DEC_clearFill.zctl2 : DEC_clearFill.s9.ctl = DEC_clearFill.kappa2.ctl DEC_clearFill.s10.ctl
kernel_rfl DEC_clearFill.zstack2 : DEC_clearFill.s9.stack = DEC_clearFill.s10.stack.map DEC_clearFill.kappa2.frame
kernel_rfl DEC_clearFill.zjobs2 : DEC_clearFill.s9.jobs = DEC_clearFill.s10.jobs.map DEC_clearFill.kappa2.job
kernel_rfl DEC_clearFill.zstores2 : DEC_clearFill.s9.stores = DEC_clearFill.kappa2.stores DEC_clearFill.s10.stores
kernel_rfl DEC_clearFill.zroots2 : checkRootsSupp DEC_clearFill.s10 290 = true
kernel_rfl DEC_clearFill.znC2 : DEC_clearFill.S8.tab.length + DEC_clearFill.cws2.length = 290
-- the map as `Conv.compact_shift` states it (the call's counters for the literals)
kernel_rfl DEC_clearFill.zkap2 : DEC_clearFill.kappa2 = Conv.Map.compact DEC_clearFill.s8.next 3124267 DEC_clearFill.S8.tab.length DEC_clearFill.pl2 (DEC_clearFill.nr2.map NumV.ref) DEC_clearFill.kd2.big
  DEC_clearFill.kd2.region DEC_clearFill.kd2.nodeF
-- the bridge inactive at the canonical state (`Conv.FullShiftQ.toX`; the merged state's bridge is the canonical's: cbridge)
kernel_rfl DEC_clearFill.zbin2 : (Host.Ts.Sim.Full.bridgeOf DEC_clearFill.s10.ffi).active = false
-- the JS bookkeeping's step (`Conv.JClean.step` over the changed list) and the canonical roots' bigint freedom
kernel_rfl DEC_clearFill.zjc2 : Conv.jcleanListB (⟨29440, 24888, 3124248, 290⟩ : Conv.Cnt) DEC_clearFill.s10 DEC_clearFill.cl2 = true
kernel_rfl DEC_clearFill.zroots22 : noBigRootsP (fun i => !Conv.oldBigB (⟨29440, 24888, 3124248, 290⟩ : Conv.Cnt) i) DEC_clearFill.s10.trace DEC_clearFill.s10 = true
kernel_rfl DEC_clearFill.zhm2 : Nat.ble (Host.Load.Layers.toLoad DEC_clearFill.s0.ffi).mlx.nnext 24888 = true
theorem DEC_clearFill.cjcl2 (h : Conv.JClean (⟨29440, 24888, 3124248, 290⟩ : Conv.Cnt) DEC_clearFill.s8) : Conv.JClean (⟨29440, 24888, 3124248, 290⟩ : Conv.Cnt) DEC_clearFill.s10 :=
  Conv.JClean.step h (Conv.Cnt.le_of_leB DEC_clearFill.cle2)
    (Conv.heap_off_setAll DEC_clearFill.cheap2 fun a ha => Nat.blt_eq.mp (List.all_eq_true.mp DEC_clearFill.zclbd2 a ha)) DEC_clearFill.zjc2

end Host.Load.Run.Tpl
