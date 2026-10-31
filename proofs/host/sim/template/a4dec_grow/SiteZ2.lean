import host.sim.template.a4dec_grow.SiteS2
import host.sim.template.a4dec_grow.SiteK2
import host.sim.template.a4dec_grow.SiteF2
import host.sim.conv.CompactShift
import host.sim.template.Check
import host.sim.BigFreeP
import host.sim.template.CallGen
set_option Elab.async false
namespace Host.Load.Run.Tpl
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
open Host.Ts Host.Ts.Sim Host.Ts.Sim.Template

/-! The compaction's state shift at call site 2 of chain `DEC_grow` (`Conv.compact_shift`): the call `DEC_grow.s8`, the merged
state `DEC_grow.s9`, the canonical state `DEC_grow.s10`; its frames [2673448,12504,2665,4910] (kept arrays [2673448,12504,2665]). -/

-- the map's places and counters
kernel_rfl DEC_grow.zpl2 : DEC_grow.pl2.all (Nat.ble DEC_grow.s8.next) = true
kernel_rfl DEC_grow.zplnd2 : nodupT DEC_grow.pl2 PTrie.nil = true
kernel_rfl DEC_grow.zn12 : Nat.ble DEC_grow.s8.next 3124266 = true
kernel_rfl DEC_grow.zfirst2 : Nat.ble aFirst DEC_grow.s8.next = true
kernel_rfl DEC_grow.zscn2 : DEC_grow.s10.next = DEC_grow.s8.next + DEC_grow.pl2.length
kernel_rfl DEC_grow.zsmn2 : DEC_grow.s9.next = 3124266
kernel_rfl DEC_grow.zgrow2 : Nat.ble DEC_grow.s10.next DEC_grow.s9.next = true
-- the tables
kernel_rfl DEC_grow.zfresh2 : DEC_grow.S8.tab.all (fun e => DEC_grow.cws2.all fun v => e.noVar v) = true
kernel_rfl DEC_grow.zcnd2 : nodupT DEC_grow.cws2 PTrie.nil = true
kernel_rfl DEC_grow.znrHi2 : DEC_grow.nr2.all (fun r => Nat.blt r DEC_grow.S9.tab.length) = true
-- the frames: every framed address below the call's counter; the kept arrays the chain start's, extended in the merged state
kernel_rfl DEC_grow.zfrlt2 : [2673448, 12504, 2665, 4910].all (fun a => Nat.blt a DEC_grow.s8.next) = true
kernel_rfl DEC_grow.zg2_2673448 : DEC_grow.s10.heap.get 2673448 = some (.obj (objOf DEC_grow.s10 2673448))
kernel_rfl DEC_grow.zk2_2673448 : (objOf DEC_grow.s10 2673448).kind = .array (arrOf DEC_grow.s0 2673448)
kernel_rfl DEC_grow.zm2_2673448 : DEC_grow.s9.heap.get 2673448 = some (.obj { DEC_grow.kappa2.obj (objOf DEC_grow.s10 2673448) with
  kind := .array (arrOf DEC_grow.s0 2673448 ++ (arrOf DEC_grow.s9 2673448).drop (arrOf DEC_grow.s0 2673448).length) })
kernel_rfl DEC_grow.zg2_12504 : DEC_grow.s10.heap.get 12504 = some (.obj (objOf DEC_grow.s10 12504))
kernel_rfl DEC_grow.zk2_12504 : (objOf DEC_grow.s10 12504).kind = .array (arrOf DEC_grow.s0 12504)
kernel_rfl DEC_grow.zm2_12504 : DEC_grow.s9.heap.get 12504 = some (.obj { DEC_grow.kappa2.obj (objOf DEC_grow.s10 12504) with
  kind := .array (arrOf DEC_grow.s0 12504 ++ (arrOf DEC_grow.s9 12504).drop (arrOf DEC_grow.s0 12504).length) })
kernel_rfl DEC_grow.zg2_2665 : DEC_grow.s10.heap.get 2665 = some (.obj (objOf DEC_grow.s10 2665))
kernel_rfl DEC_grow.zk2_2665 : (objOf DEC_grow.s10 2665).kind = .array (arrOf DEC_grow.s0 2665)
kernel_rfl DEC_grow.zm2_2665 : DEC_grow.s9.heap.get 2665 = some (.obj { DEC_grow.kappa2.obj (objOf DEC_grow.s10 2665) with
  kind := .array (arrOf DEC_grow.s0 2665 ++ (arrOf DEC_grow.s9 2665).drop (arrOf DEC_grow.s0 2665).length) })
kernel_rfl DEC_grow.zw2_4910 : (DEC_grow.s10.heap.get 4910).isSome = true
-- the heap: the changed list in range, holding the stage's written and fresh addresses; the canonical side's image
kernel_rfl DEC_grow.zclbd2 : DEC_grow.cl2.all (fun b => Nat.blt (b / 4096) (4 ^ 31)) = true
kernel_rfl DEC_grow.zwr2 : DEC_grow.st2.wr.all (fun b => !Nat.blt b DEC_grow.s8.next || DEC_grow.cl2.contains b) = true
def DEC_grow.zl2 : List Nat := DEC_grow.cl2.filter fun a => !(List.contains [2673448, 12504, 2665] a)
kernel_rfl DEC_grow.zimgE2 : DEC_grow.zl2.map (fun a => DEC_grow.s9.heap.get (DEC_grow.kappa2.a a)) = DEC_grow.zl2.map (fun a => (DEC_grow.s10.heap.get a).map DEC_grow.kappa2.hobj)
theorem DEC_grow.zimg2 : HeapImg DEC_grow.kappa2 DEC_grow.s10 DEC_grow.s9 DEC_grow.zl2 := DEC_grow.zimgE2
-- the roots and their supports
kernel_rfl DEC_grow.zctl2 : DEC_grow.s9.ctl = DEC_grow.kappa2.ctl DEC_grow.s10.ctl
kernel_rfl DEC_grow.zstack2 : DEC_grow.s9.stack = DEC_grow.s10.stack.map DEC_grow.kappa2.frame
kernel_rfl DEC_grow.zjobs2 : DEC_grow.s9.jobs = DEC_grow.s10.jobs.map DEC_grow.kappa2.job
kernel_rfl DEC_grow.zstores2 : DEC_grow.s9.stores = DEC_grow.kappa2.stores DEC_grow.s10.stores
kernel_rfl DEC_grow.zroots2 : checkRootsSupp DEC_grow.s10 386 = true
kernel_rfl DEC_grow.znC2 : DEC_grow.S8.tab.length + DEC_grow.cws2.length = 386
-- the map as `Conv.compact_shift` states it (the call's counters for the literals)
kernel_rfl DEC_grow.zkap2 : DEC_grow.kappa2 = Conv.Map.compact DEC_grow.s8.next 3124266 DEC_grow.S8.tab.length DEC_grow.pl2 (DEC_grow.nr2.map NumV.ref) DEC_grow.kd2.big
  DEC_grow.kd2.region DEC_grow.kd2.nodeF
-- the bridge inactive at the canonical state (`Conv.FullShiftQ.toX`; the merged state's bridge is the canonical's: cbridge)
kernel_rfl DEC_grow.zbin2 : (Host.Ts.Sim.Full.bridgeOf DEC_grow.s10.ffi).active = false
-- the JS bookkeeping's step (`Conv.JClean.step` over the changed list) and the canonical roots' bigint freedom
kernel_rfl DEC_grow.zjc2 : Conv.jcleanListB (⟨29440, 24984, 3124247, 386⟩ : Conv.Cnt) DEC_grow.s10 DEC_grow.cl2 = true
kernel_rfl DEC_grow.zroots22 : noBigRootsP (fun i => !Conv.oldBigB (⟨29440, 24984, 3124247, 386⟩ : Conv.Cnt) i) DEC_grow.s10.trace DEC_grow.s10 = true
kernel_rfl DEC_grow.zhm2 : Nat.ble (Host.Load.Layers.toLoad DEC_grow.s0.ffi).mlx.nnext 24984 = true
theorem DEC_grow.cjcl2 (h : Conv.JClean (⟨29440, 24984, 3124247, 386⟩ : Conv.Cnt) DEC_grow.s8) : Conv.JClean (⟨29440, 24984, 3124247, 386⟩ : Conv.Cnt) DEC_grow.s10 :=
  Conv.JClean.step h (Conv.Cnt.le_of_leB DEC_grow.cle2)
    (Conv.heap_off_setAll DEC_grow.cheap2 fun a ha => Nat.blt_eq.mp (List.all_eq_true.mp DEC_grow.zclbd2 a ha)) DEC_grow.zjc2

end Host.Load.Run.Tpl
