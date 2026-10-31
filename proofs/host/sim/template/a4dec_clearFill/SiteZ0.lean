import host.sim.template.a4dec_clearFill.SiteS0
import host.sim.template.a4dec_clearFill.SiteK0
import host.sim.template.a4dec_clearFill.SiteF0
import host.sim.conv.CompactShift
import host.sim.template.Check
import host.sim.BigFreeP
import host.sim.template.CallGen
set_option Elab.async false
namespace Host.Load.Run.Tpl
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
open Host.Ts Host.Ts.Sim Host.Ts.Sim.Template

/-! The compaction's state shift at call site 0 of chain `DEC_clearFill` (`Conv.compact_shift`): the call `DEC_clearFill.s0`, the merged
state `DEC_clearFill.s1`, the canonical state `DEC_clearFill.s2`; its frames [2673448,12504,2665,4910] (kept arrays [2673448,12504,2665]). -/

-- the map's places and counters
kernel_rfl DEC_clearFill.zpl0 : DEC_clearFill.pl0.all (Nat.ble DEC_clearFill.s0.next) = true
kernel_rfl DEC_clearFill.zplnd0 : nodupT DEC_clearFill.pl0 PTrie.nil = true
kernel_rfl DEC_clearFill.zn10 : Nat.ble DEC_clearFill.s0.next 3123580 = true
kernel_rfl DEC_clearFill.zfirst0 : Nat.ble aFirst DEC_clearFill.s0.next = true
kernel_rfl DEC_clearFill.zscn0 : DEC_clearFill.s2.next = DEC_clearFill.s0.next + DEC_clearFill.pl0.length
kernel_rfl DEC_clearFill.zsmn0 : DEC_clearFill.s1.next = 3123580
kernel_rfl DEC_clearFill.zgrow0 : Nat.ble DEC_clearFill.s2.next DEC_clearFill.s1.next = true
-- the tables
kernel_rfl DEC_clearFill.zfresh0 : DEC_clearFill.S0.tab.all (fun e => DEC_clearFill.cws0.all fun v => e.noVar v) = true
kernel_rfl DEC_clearFill.zcnd0 : nodupT DEC_clearFill.cws0 PTrie.nil = true
kernel_rfl DEC_clearFill.znrHi0 : DEC_clearFill.nr0.all (fun r => Nat.blt r DEC_clearFill.S1.tab.length) = true
-- the frames: every framed address below the call's counter; the kept arrays the chain start's, extended in the merged state
kernel_rfl DEC_clearFill.zfrlt0 : [2673448, 12504, 2665, 4910].all (fun a => Nat.blt a DEC_clearFill.s0.next) = true
kernel_rfl DEC_clearFill.zg0_2673448 : DEC_clearFill.s2.heap.get 2673448 = some (.obj (objOf DEC_clearFill.s2 2673448))
kernel_rfl DEC_clearFill.zk0_2673448 : (objOf DEC_clearFill.s2 2673448).kind = .array (arrOf DEC_clearFill.s0 2673448)
kernel_rfl DEC_clearFill.zm0_2673448 : DEC_clearFill.s1.heap.get 2673448 = some (.obj { DEC_clearFill.kappa0.obj (objOf DEC_clearFill.s2 2673448) with
  kind := .array (arrOf DEC_clearFill.s0 2673448 ++ (arrOf DEC_clearFill.s1 2673448).drop (arrOf DEC_clearFill.s0 2673448).length) })
kernel_rfl DEC_clearFill.zg0_12504 : DEC_clearFill.s2.heap.get 12504 = some (.obj (objOf DEC_clearFill.s2 12504))
kernel_rfl DEC_clearFill.zk0_12504 : (objOf DEC_clearFill.s2 12504).kind = .array (arrOf DEC_clearFill.s0 12504)
kernel_rfl DEC_clearFill.zm0_12504 : DEC_clearFill.s1.heap.get 12504 = some (.obj { DEC_clearFill.kappa0.obj (objOf DEC_clearFill.s2 12504) with
  kind := .array (arrOf DEC_clearFill.s0 12504 ++ (arrOf DEC_clearFill.s1 12504).drop (arrOf DEC_clearFill.s0 12504).length) })
kernel_rfl DEC_clearFill.zg0_2665 : DEC_clearFill.s2.heap.get 2665 = some (.obj (objOf DEC_clearFill.s2 2665))
kernel_rfl DEC_clearFill.zk0_2665 : (objOf DEC_clearFill.s2 2665).kind = .array (arrOf DEC_clearFill.s0 2665)
kernel_rfl DEC_clearFill.zm0_2665 : DEC_clearFill.s1.heap.get 2665 = some (.obj { DEC_clearFill.kappa0.obj (objOf DEC_clearFill.s2 2665) with
  kind := .array (arrOf DEC_clearFill.s0 2665 ++ (arrOf DEC_clearFill.s1 2665).drop (arrOf DEC_clearFill.s0 2665).length) })
kernel_rfl DEC_clearFill.zw0_4910 : (DEC_clearFill.s2.heap.get 4910).isSome = true
-- the heap: the changed list in range, holding the stage's written and fresh addresses; the canonical side's image
kernel_rfl DEC_clearFill.zclbd0 : DEC_clearFill.cl0.all (fun b => Nat.blt (b / 4096) (4 ^ 31)) = true
kernel_rfl DEC_clearFill.zwr0 : DEC_clearFill.st0.wr.all (fun b => !Nat.blt b DEC_clearFill.s0.next || DEC_clearFill.cl0.contains b) = true
def DEC_clearFill.zl0 : List Nat := DEC_clearFill.cl0.filter fun a => !(List.contains [2673448, 12504, 2665] a)
kernel_rfl DEC_clearFill.zimgE0 : DEC_clearFill.zl0.map (fun a => DEC_clearFill.s1.heap.get (DEC_clearFill.kappa0.a a)) = DEC_clearFill.zl0.map (fun a => (DEC_clearFill.s2.heap.get a).map DEC_clearFill.kappa0.hobj)
theorem DEC_clearFill.zimg0 : HeapImg DEC_clearFill.kappa0 DEC_clearFill.s2 DEC_clearFill.s1 DEC_clearFill.zl0 := DEC_clearFill.zimgE0
-- the roots and their supports
kernel_rfl DEC_clearFill.zctl0 : DEC_clearFill.s1.ctl = DEC_clearFill.kappa0.ctl DEC_clearFill.s2.ctl
kernel_rfl DEC_clearFill.zstack0 : DEC_clearFill.s1.stack = DEC_clearFill.s2.stack.map DEC_clearFill.kappa0.frame
kernel_rfl DEC_clearFill.zjobs0 : DEC_clearFill.s1.jobs = DEC_clearFill.s2.jobs.map DEC_clearFill.kappa0.job
kernel_rfl DEC_clearFill.zstores0 : DEC_clearFill.s1.stores = DEC_clearFill.kappa0.stores DEC_clearFill.s2.stores
kernel_rfl DEC_clearFill.zroots0 : checkRootsSupp DEC_clearFill.s2 123 = true
kernel_rfl DEC_clearFill.znC0 : DEC_clearFill.S0.tab.length + DEC_clearFill.cws0.length = 123
-- the map as `Conv.compact_shift` states it (the call's counters for the literals)
kernel_rfl DEC_clearFill.zkap0 : DEC_clearFill.kappa0 = Conv.Map.compact DEC_clearFill.s0.next 3123580 DEC_clearFill.S0.tab.length DEC_clearFill.pl0 (DEC_clearFill.nr0.map NumV.ref) DEC_clearFill.kd0.big
  DEC_clearFill.kd0.region DEC_clearFill.kd0.nodeF
-- the bridge inactive at the canonical state (`Conv.FullShiftQ.toX`; the merged state's bridge is the canonical's: cbridge)
kernel_rfl DEC_clearFill.zbin0 : (Host.Ts.Sim.Full.bridgeOf DEC_clearFill.s2.ffi).active = false
-- the JS bookkeeping's step (`Conv.JClean.step` over the changed list) and the canonical roots' bigint freedom
kernel_rfl DEC_clearFill.zjc0 : Conv.jcleanListB (⟨29302, 22539, 3123568, 123⟩ : Conv.Cnt) DEC_clearFill.s2 DEC_clearFill.cl0 = true
kernel_rfl DEC_clearFill.zroots20 : noBigRootsP (fun i => !Conv.oldBigB (⟨29302, 22539, 3123568, 123⟩ : Conv.Cnt) i) DEC_clearFill.s2.trace DEC_clearFill.s2 = true
kernel_rfl DEC_clearFill.zhm0 : Nat.ble (Host.Load.Layers.toLoad DEC_clearFill.s0.ffi).mlx.nnext 22539 = true
theorem DEC_clearFill.cjcl0 (h : Conv.JClean (⟨29302, 22539, 3123568, 123⟩ : Conv.Cnt) DEC_clearFill.s0) : Conv.JClean (⟨29302, 22539, 3123568, 123⟩ : Conv.Cnt) DEC_clearFill.s2 :=
  Conv.JClean.step h (Conv.Cnt.le_of_leB DEC_clearFill.cle0)
    (Conv.heap_off_setAll DEC_clearFill.cheap0 fun a ha => Nat.blt_eq.mp (List.all_eq_true.mp DEC_clearFill.zclbd0 a ha)) DEC_clearFill.zjc0

end Host.Load.Run.Tpl
