import host.sim.template.a4dec_ord.SiteS2
import host.sim.template.a4dec_ord.SiteK2
import host.sim.template.a4dec_ord.SiteF2
import host.sim.conv.CompactShift
import host.sim.template.Check
import host.sim.BigFreeP
import host.sim.template.CallGen
set_option Elab.async false
namespace Host.Load.Run.Tpl
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
open Host.Ts Host.Ts.Sim Host.Ts.Sim.Template

/-! The compaction's state shift at call site 2 of chain `DEC_ord` (`Conv.compact_shift`): the call `DEC_ord.s8`, the merged
state `DEC_ord.s9`, the canonical state `DEC_ord.s10`; its frames [2673448,12504,2665,4910] (kept arrays [2673448,12504,2665]). -/

-- the map's places and counters
kernel_rfl DEC_ord.zpl2 : DEC_ord.pl2.all (Nat.ble DEC_ord.s8.next) = true
kernel_rfl DEC_ord.zplnd2 : nodupT DEC_ord.pl2 PTrie.nil = true
kernel_rfl DEC_ord.zn12 : Nat.ble DEC_ord.s8.next 3124266 = true
kernel_rfl DEC_ord.zfirst2 : Nat.ble aFirst DEC_ord.s8.next = true
kernel_rfl DEC_ord.zscn2 : DEC_ord.s10.next = DEC_ord.s8.next + DEC_ord.pl2.length
kernel_rfl DEC_ord.zsmn2 : DEC_ord.s9.next = 3124266
kernel_rfl DEC_ord.zgrow2 : Nat.ble DEC_ord.s10.next DEC_ord.s9.next = true
-- the tables
kernel_rfl DEC_ord.zfresh2 : DEC_ord.S8.tab.all (fun e => DEC_ord.cws2.all fun v => e.noVar v) = true
kernel_rfl DEC_ord.zcnd2 : nodupT DEC_ord.cws2 PTrie.nil = true
kernel_rfl DEC_ord.znrHi2 : DEC_ord.nr2.all (fun r => Nat.blt r DEC_ord.S9.tab.length) = true
-- the frames: every framed address below the call's counter; the kept arrays the chain start's, extended in the merged state
kernel_rfl DEC_ord.zfrlt2 : [2673448, 12504, 2665, 4910].all (fun a => Nat.blt a DEC_ord.s8.next) = true
kernel_rfl DEC_ord.zg2_2673448 : DEC_ord.s10.heap.get 2673448 = some (.obj (objOf DEC_ord.s10 2673448))
kernel_rfl DEC_ord.zk2_2673448 : (objOf DEC_ord.s10 2673448).kind = .array (arrOf DEC_ord.s0 2673448)
kernel_rfl DEC_ord.zm2_2673448 : DEC_ord.s9.heap.get 2673448 = some (.obj { DEC_ord.kappa2.obj (objOf DEC_ord.s10 2673448) with
  kind := .array (arrOf DEC_ord.s0 2673448 ++ (arrOf DEC_ord.s9 2673448).drop (arrOf DEC_ord.s0 2673448).length) })
kernel_rfl DEC_ord.zg2_12504 : DEC_ord.s10.heap.get 12504 = some (.obj (objOf DEC_ord.s10 12504))
kernel_rfl DEC_ord.zk2_12504 : (objOf DEC_ord.s10 12504).kind = .array (arrOf DEC_ord.s0 12504)
kernel_rfl DEC_ord.zm2_12504 : DEC_ord.s9.heap.get 12504 = some (.obj { DEC_ord.kappa2.obj (objOf DEC_ord.s10 12504) with
  kind := .array (arrOf DEC_ord.s0 12504 ++ (arrOf DEC_ord.s9 12504).drop (arrOf DEC_ord.s0 12504).length) })
kernel_rfl DEC_ord.zg2_2665 : DEC_ord.s10.heap.get 2665 = some (.obj (objOf DEC_ord.s10 2665))
kernel_rfl DEC_ord.zk2_2665 : (objOf DEC_ord.s10 2665).kind = .array (arrOf DEC_ord.s0 2665)
kernel_rfl DEC_ord.zm2_2665 : DEC_ord.s9.heap.get 2665 = some (.obj { DEC_ord.kappa2.obj (objOf DEC_ord.s10 2665) with
  kind := .array (arrOf DEC_ord.s0 2665 ++ (arrOf DEC_ord.s9 2665).drop (arrOf DEC_ord.s0 2665).length) })
kernel_rfl DEC_ord.zw2_4910 : (DEC_ord.s10.heap.get 4910).isSome = true
-- the heap: the changed list in range, holding the stage's written and fresh addresses; the canonical side's image
kernel_rfl DEC_ord.zclbd2 : DEC_ord.cl2.all (fun b => Nat.blt (b / 4096) (4 ^ 31)) = true
kernel_rfl DEC_ord.zwr2 : DEC_ord.st2.wr.all (fun b => !Nat.blt b DEC_ord.s8.next || DEC_ord.cl2.contains b) = true
def DEC_ord.zl2 : List Nat := DEC_ord.cl2.filter fun a => !(List.contains [2673448, 12504, 2665] a)
kernel_rfl DEC_ord.zimgE2 : DEC_ord.zl2.map (fun a => DEC_ord.s9.heap.get (DEC_ord.kappa2.a a)) = DEC_ord.zl2.map (fun a => (DEC_ord.s10.heap.get a).map DEC_ord.kappa2.hobj)
theorem DEC_ord.zimg2 : HeapImg DEC_ord.kappa2 DEC_ord.s10 DEC_ord.s9 DEC_ord.zl2 := DEC_ord.zimgE2
-- the roots and their supports
kernel_rfl DEC_ord.zctl2 : DEC_ord.s9.ctl = DEC_ord.kappa2.ctl DEC_ord.s10.ctl
kernel_rfl DEC_ord.zstack2 : DEC_ord.s9.stack = DEC_ord.s10.stack.map DEC_ord.kappa2.frame
kernel_rfl DEC_ord.zjobs2 : DEC_ord.s9.jobs = DEC_ord.s10.jobs.map DEC_ord.kappa2.job
kernel_rfl DEC_ord.zstores2 : DEC_ord.s9.stores = DEC_ord.kappa2.stores DEC_ord.s10.stores
kernel_rfl DEC_ord.zroots2 : checkRootsSupp DEC_ord.s10 354 = true
kernel_rfl DEC_ord.znC2 : DEC_ord.S8.tab.length + DEC_ord.cws2.length = 354
-- the map as `Conv.compact_shift` states it (the call's counters for the literals)
kernel_rfl DEC_ord.zkap2 : DEC_ord.kappa2 = Conv.Map.compact DEC_ord.s8.next 3124266 DEC_ord.S8.tab.length DEC_ord.pl2 (DEC_ord.nr2.map NumV.ref) DEC_ord.kd2.big
  DEC_ord.kd2.region DEC_ord.kd2.nodeF
-- the bridge inactive at the canonical state (`Conv.FullShiftQ.toX`; the merged state's bridge is the canonical's: cbridge)
kernel_rfl DEC_ord.zbin2 : (Host.Ts.Sim.Full.bridgeOf DEC_ord.s10.ffi).active = false
-- the JS bookkeeping's step (`Conv.JClean.step` over the changed list) and the canonical roots' bigint freedom
kernel_rfl DEC_ord.zjc2 : Conv.jcleanListB (⟨29440, 24920, 3124247, 354⟩ : Conv.Cnt) DEC_ord.s10 DEC_ord.cl2 = true
kernel_rfl DEC_ord.zroots22 : noBigRootsP (fun i => !Conv.oldBigB (⟨29440, 24920, 3124247, 354⟩ : Conv.Cnt) i) DEC_ord.s10.trace DEC_ord.s10 = true
kernel_rfl DEC_ord.zhm2 : Nat.ble (Host.Load.Layers.toLoad DEC_ord.s0.ffi).mlx.nnext 24920 = true
theorem DEC_ord.cjcl2 (h : Conv.JClean (⟨29440, 24920, 3124247, 354⟩ : Conv.Cnt) DEC_ord.s8) : Conv.JClean (⟨29440, 24920, 3124247, 354⟩ : Conv.Cnt) DEC_ord.s10 :=
  Conv.JClean.step h (Conv.Cnt.le_of_leB DEC_ord.cle2)
    (Conv.heap_off_setAll DEC_ord.cheap2 fun a ha => Nat.blt_eq.mp (List.all_eq_true.mp DEC_ord.zclbd2 a ha)) DEC_ord.zjc2

end Host.Load.Run.Tpl
