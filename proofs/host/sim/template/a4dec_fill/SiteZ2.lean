import host.sim.template.a4dec_fill.SiteS2
import host.sim.template.a4dec_fill.SiteK2
import host.sim.template.a4dec_fill.SiteF2
import host.sim.conv.CompactShift
import host.sim.template.Check
import host.sim.BigFreeP
import host.sim.template.CallGen
set_option Elab.async false
namespace Host.Load.Run.Tpl
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
open Host.Ts Host.Ts.Sim Host.Ts.Sim.Template

/-! The compaction's state shift at call site 2 of chain `DEC_fill` (`Conv.compact_shift`): the call `DEC_fill.s8`, the merged
state `DEC_fill.s9`, the canonical state `DEC_fill.s10`; its frames [2673448,12504,2665,4910] (kept arrays [2673448,12504,2665]). -/

-- the map's places and counters
kernel_rfl DEC_fill.zpl2 : DEC_fill.pl2.all (Nat.ble DEC_fill.s8.next) = true
kernel_rfl DEC_fill.zplnd2 : nodupT DEC_fill.pl2 PTrie.nil = true
kernel_rfl DEC_fill.zn12 : Nat.ble DEC_fill.s8.next 3124266 = true
kernel_rfl DEC_fill.zfirst2 : Nat.ble aFirst DEC_fill.s8.next = true
kernel_rfl DEC_fill.zscn2 : DEC_fill.s10.next = DEC_fill.s8.next + DEC_fill.pl2.length
kernel_rfl DEC_fill.zsmn2 : DEC_fill.s9.next = 3124266
kernel_rfl DEC_fill.zgrow2 : Nat.ble DEC_fill.s10.next DEC_fill.s9.next = true
-- the tables
kernel_rfl DEC_fill.zfresh2 : DEC_fill.S8.tab.all (fun e => DEC_fill.cws2.all fun v => e.noVar v) = true
kernel_rfl DEC_fill.zcnd2 : nodupT DEC_fill.cws2 PTrie.nil = true
kernel_rfl DEC_fill.znrHi2 : DEC_fill.nr2.all (fun r => Nat.blt r DEC_fill.S9.tab.length) = true
-- the frames: every framed address below the call's counter; the kept arrays the chain start's, extended in the merged state
kernel_rfl DEC_fill.zfrlt2 : [2673448, 12504, 2665, 4910].all (fun a => Nat.blt a DEC_fill.s8.next) = true
kernel_rfl DEC_fill.zg2_2673448 : DEC_fill.s10.heap.get 2673448 = some (.obj (objOf DEC_fill.s10 2673448))
kernel_rfl DEC_fill.zk2_2673448 : (objOf DEC_fill.s10 2673448).kind = .array (arrOf DEC_fill.s0 2673448)
kernel_rfl DEC_fill.zm2_2673448 : DEC_fill.s9.heap.get 2673448 = some (.obj { DEC_fill.kappa2.obj (objOf DEC_fill.s10 2673448) with
  kind := .array (arrOf DEC_fill.s0 2673448 ++ (arrOf DEC_fill.s9 2673448).drop (arrOf DEC_fill.s0 2673448).length) })
kernel_rfl DEC_fill.zg2_12504 : DEC_fill.s10.heap.get 12504 = some (.obj (objOf DEC_fill.s10 12504))
kernel_rfl DEC_fill.zk2_12504 : (objOf DEC_fill.s10 12504).kind = .array (arrOf DEC_fill.s0 12504)
kernel_rfl DEC_fill.zm2_12504 : DEC_fill.s9.heap.get 12504 = some (.obj { DEC_fill.kappa2.obj (objOf DEC_fill.s10 12504) with
  kind := .array (arrOf DEC_fill.s0 12504 ++ (arrOf DEC_fill.s9 12504).drop (arrOf DEC_fill.s0 12504).length) })
kernel_rfl DEC_fill.zg2_2665 : DEC_fill.s10.heap.get 2665 = some (.obj (objOf DEC_fill.s10 2665))
kernel_rfl DEC_fill.zk2_2665 : (objOf DEC_fill.s10 2665).kind = .array (arrOf DEC_fill.s0 2665)
kernel_rfl DEC_fill.zm2_2665 : DEC_fill.s9.heap.get 2665 = some (.obj { DEC_fill.kappa2.obj (objOf DEC_fill.s10 2665) with
  kind := .array (arrOf DEC_fill.s0 2665 ++ (arrOf DEC_fill.s9 2665).drop (arrOf DEC_fill.s0 2665).length) })
kernel_rfl DEC_fill.zw2_4910 : (DEC_fill.s10.heap.get 4910).isSome = true
-- the heap: the changed list in range, holding the stage's written and fresh addresses; the canonical side's image
kernel_rfl DEC_fill.zclbd2 : DEC_fill.cl2.all (fun b => Nat.blt (b / 4096) (4 ^ 31)) = true
kernel_rfl DEC_fill.zwr2 : DEC_fill.st2.wr.all (fun b => !Nat.blt b DEC_fill.s8.next || DEC_fill.cl2.contains b) = true
def DEC_fill.zl2 : List Nat := DEC_fill.cl2.filter fun a => !(List.contains [2673448, 12504, 2665] a)
kernel_rfl DEC_fill.zimgE2 : DEC_fill.zl2.map (fun a => DEC_fill.s9.heap.get (DEC_fill.kappa2.a a)) = DEC_fill.zl2.map (fun a => (DEC_fill.s10.heap.get a).map DEC_fill.kappa2.hobj)
theorem DEC_fill.zimg2 : HeapImg DEC_fill.kappa2 DEC_fill.s10 DEC_fill.s9 DEC_fill.zl2 := DEC_fill.zimgE2
-- the roots and their supports
kernel_rfl DEC_fill.zctl2 : DEC_fill.s9.ctl = DEC_fill.kappa2.ctl DEC_fill.s10.ctl
kernel_rfl DEC_fill.zstack2 : DEC_fill.s9.stack = DEC_fill.s10.stack.map DEC_fill.kappa2.frame
kernel_rfl DEC_fill.zjobs2 : DEC_fill.s9.jobs = DEC_fill.s10.jobs.map DEC_fill.kappa2.job
kernel_rfl DEC_fill.zstores2 : DEC_fill.s9.stores = DEC_fill.kappa2.stores DEC_fill.s10.stores
kernel_rfl DEC_fill.zroots2 : checkRootsSupp DEC_fill.s10 290 = true
kernel_rfl DEC_fill.znC2 : DEC_fill.S8.tab.length + DEC_fill.cws2.length = 290
-- the map as `Conv.compact_shift` states it (the call's counters for the literals)
kernel_rfl DEC_fill.zkap2 : DEC_fill.kappa2 = Conv.Map.compact DEC_fill.s8.next 3124266 DEC_fill.S8.tab.length DEC_fill.pl2 (DEC_fill.nr2.map NumV.ref) DEC_fill.kd2.big
  DEC_fill.kd2.region DEC_fill.kd2.nodeF
-- the bridge inactive at the canonical state (`Conv.FullShiftQ.toX`; the merged state's bridge is the canonical's: cbridge)
kernel_rfl DEC_fill.zbin2 : (Host.Ts.Sim.Full.bridgeOf DEC_fill.s10.ffi).active = false
-- the JS bookkeeping's step (`Conv.JClean.step` over the changed list) and the canonical roots' bigint freedom
kernel_rfl DEC_fill.zjc2 : Conv.jcleanListB (⟨29440, 24888, 3124247, 290⟩ : Conv.Cnt) DEC_fill.s10 DEC_fill.cl2 = true
kernel_rfl DEC_fill.zroots22 : noBigRootsP (fun i => !Conv.oldBigB (⟨29440, 24888, 3124247, 290⟩ : Conv.Cnt) i) DEC_fill.s10.trace DEC_fill.s10 = true
kernel_rfl DEC_fill.zhm2 : Nat.ble (Host.Load.Layers.toLoad DEC_fill.s0.ffi).mlx.nnext 24888 = true
theorem DEC_fill.cjcl2 (h : Conv.JClean (⟨29440, 24888, 3124247, 290⟩ : Conv.Cnt) DEC_fill.s8) : Conv.JClean (⟨29440, 24888, 3124247, 290⟩ : Conv.Cnt) DEC_fill.s10 :=
  Conv.JClean.step h (Conv.Cnt.le_of_leB DEC_fill.cle2)
    (Conv.heap_off_setAll DEC_fill.cheap2 fun a ha => Nat.blt_eq.mp (List.all_eq_true.mp DEC_fill.zclbd2 a ha)) DEC_fill.zjc2

end Host.Load.Run.Tpl
