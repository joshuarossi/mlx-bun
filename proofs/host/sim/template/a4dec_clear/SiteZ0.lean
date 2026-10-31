import host.sim.template.a4dec_clear.SiteS0
import host.sim.template.a4dec_clear.SiteK0
import host.sim.template.a4dec_clear.SiteF0
import host.sim.conv.CompactShift
import host.sim.template.Check
import host.sim.BigFreeP
import host.sim.template.CallGen
set_option Elab.async false
namespace Host.Load.Run.Tpl
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
open Host.Ts Host.Ts.Sim Host.Ts.Sim.Template

/-! The compaction's state shift at call site 0 of chain `DEC_clear` (`Conv.compact_shift`): the call `DEC_clear.s0`, the merged
state `DEC_clear.s1`, the canonical state `DEC_clear.s2`; its frames [2673448,12504,2665,4910] (kept arrays [2673448,12504,2665]). -/

-- the map's places and counters
kernel_rfl DEC_clear.zpl0 : DEC_clear.pl0.all (Nat.ble DEC_clear.s0.next) = true
kernel_rfl DEC_clear.zplnd0 : nodupT DEC_clear.pl0 PTrie.nil = true
kernel_rfl DEC_clear.zn10 : Nat.ble DEC_clear.s0.next 3123580 = true
kernel_rfl DEC_clear.zfirst0 : Nat.ble aFirst DEC_clear.s0.next = true
kernel_rfl DEC_clear.zscn0 : DEC_clear.s2.next = DEC_clear.s0.next + DEC_clear.pl0.length
kernel_rfl DEC_clear.zsmn0 : DEC_clear.s1.next = 3123580
kernel_rfl DEC_clear.zgrow0 : Nat.ble DEC_clear.s2.next DEC_clear.s1.next = true
-- the tables
kernel_rfl DEC_clear.zfresh0 : DEC_clear.S0.tab.all (fun e => DEC_clear.cws0.all fun v => e.noVar v) = true
kernel_rfl DEC_clear.zcnd0 : nodupT DEC_clear.cws0 PTrie.nil = true
kernel_rfl DEC_clear.znrHi0 : DEC_clear.nr0.all (fun r => Nat.blt r DEC_clear.S1.tab.length) = true
-- the frames: every framed address below the call's counter; the kept arrays the chain start's, extended in the merged state
kernel_rfl DEC_clear.zfrlt0 : [2673448, 12504, 2665, 4910].all (fun a => Nat.blt a DEC_clear.s0.next) = true
kernel_rfl DEC_clear.zg0_2673448 : DEC_clear.s2.heap.get 2673448 = some (.obj (objOf DEC_clear.s2 2673448))
kernel_rfl DEC_clear.zk0_2673448 : (objOf DEC_clear.s2 2673448).kind = .array (arrOf DEC_clear.s0 2673448)
kernel_rfl DEC_clear.zm0_2673448 : DEC_clear.s1.heap.get 2673448 = some (.obj { DEC_clear.kappa0.obj (objOf DEC_clear.s2 2673448) with
  kind := .array (arrOf DEC_clear.s0 2673448 ++ (arrOf DEC_clear.s1 2673448).drop (arrOf DEC_clear.s0 2673448).length) })
kernel_rfl DEC_clear.zg0_12504 : DEC_clear.s2.heap.get 12504 = some (.obj (objOf DEC_clear.s2 12504))
kernel_rfl DEC_clear.zk0_12504 : (objOf DEC_clear.s2 12504).kind = .array (arrOf DEC_clear.s0 12504)
kernel_rfl DEC_clear.zm0_12504 : DEC_clear.s1.heap.get 12504 = some (.obj { DEC_clear.kappa0.obj (objOf DEC_clear.s2 12504) with
  kind := .array (arrOf DEC_clear.s0 12504 ++ (arrOf DEC_clear.s1 12504).drop (arrOf DEC_clear.s0 12504).length) })
kernel_rfl DEC_clear.zg0_2665 : DEC_clear.s2.heap.get 2665 = some (.obj (objOf DEC_clear.s2 2665))
kernel_rfl DEC_clear.zk0_2665 : (objOf DEC_clear.s2 2665).kind = .array (arrOf DEC_clear.s0 2665)
kernel_rfl DEC_clear.zm0_2665 : DEC_clear.s1.heap.get 2665 = some (.obj { DEC_clear.kappa0.obj (objOf DEC_clear.s2 2665) with
  kind := .array (arrOf DEC_clear.s0 2665 ++ (arrOf DEC_clear.s1 2665).drop (arrOf DEC_clear.s0 2665).length) })
kernel_rfl DEC_clear.zw0_4910 : (DEC_clear.s2.heap.get 4910).isSome = true
-- the heap: the changed list in range, holding the stage's written and fresh addresses; the canonical side's image
kernel_rfl DEC_clear.zclbd0 : DEC_clear.cl0.all (fun b => Nat.blt (b / 4096) (4 ^ 31)) = true
kernel_rfl DEC_clear.zwr0 : DEC_clear.st0.wr.all (fun b => !Nat.blt b DEC_clear.s0.next || DEC_clear.cl0.contains b) = true
def DEC_clear.zl0 : List Nat := DEC_clear.cl0.filter fun a => !(List.contains [2673448, 12504, 2665] a)
kernel_rfl DEC_clear.zimgE0 : DEC_clear.zl0.map (fun a => DEC_clear.s1.heap.get (DEC_clear.kappa0.a a)) = DEC_clear.zl0.map (fun a => (DEC_clear.s2.heap.get a).map DEC_clear.kappa0.hobj)
theorem DEC_clear.zimg0 : HeapImg DEC_clear.kappa0 DEC_clear.s2 DEC_clear.s1 DEC_clear.zl0 := DEC_clear.zimgE0
-- the roots and their supports
kernel_rfl DEC_clear.zctl0 : DEC_clear.s1.ctl = DEC_clear.kappa0.ctl DEC_clear.s2.ctl
kernel_rfl DEC_clear.zstack0 : DEC_clear.s1.stack = DEC_clear.s2.stack.map DEC_clear.kappa0.frame
kernel_rfl DEC_clear.zjobs0 : DEC_clear.s1.jobs = DEC_clear.s2.jobs.map DEC_clear.kappa0.job
kernel_rfl DEC_clear.zstores0 : DEC_clear.s1.stores = DEC_clear.kappa0.stores DEC_clear.s2.stores
kernel_rfl DEC_clear.zroots0 : checkRootsSupp DEC_clear.s2 123 = true
kernel_rfl DEC_clear.znC0 : DEC_clear.S0.tab.length + DEC_clear.cws0.length = 123
-- the map as `Conv.compact_shift` states it (the call's counters for the literals)
kernel_rfl DEC_clear.zkap0 : DEC_clear.kappa0 = Conv.Map.compact DEC_clear.s0.next 3123580 DEC_clear.S0.tab.length DEC_clear.pl0 (DEC_clear.nr0.map NumV.ref) DEC_clear.kd0.big
  DEC_clear.kd0.region DEC_clear.kd0.nodeF
-- the bridge inactive at the canonical state (`Conv.FullShiftQ.toX`; the merged state's bridge is the canonical's: cbridge)
kernel_rfl DEC_clear.zbin0 : (Host.Ts.Sim.Full.bridgeOf DEC_clear.s2.ffi).active = false
-- the JS bookkeeping's step (`Conv.JClean.step` over the changed list) and the canonical roots' bigint freedom
kernel_rfl DEC_clear.zjc0 : Conv.jcleanListB (⟨29302, 22539, 3123568, 123⟩ : Conv.Cnt) DEC_clear.s2 DEC_clear.cl0 = true
kernel_rfl DEC_clear.zroots20 : noBigRootsP (fun i => !Conv.oldBigB (⟨29302, 22539, 3123568, 123⟩ : Conv.Cnt) i) DEC_clear.s2.trace DEC_clear.s2 = true
kernel_rfl DEC_clear.zhm0 : Nat.ble (Host.Load.Layers.toLoad DEC_clear.s0.ffi).mlx.nnext 22539 = true
theorem DEC_clear.cjcl0 (h : Conv.JClean (⟨29302, 22539, 3123568, 123⟩ : Conv.Cnt) DEC_clear.s0) : Conv.JClean (⟨29302, 22539, 3123568, 123⟩ : Conv.Cnt) DEC_clear.s2 :=
  Conv.JClean.step h (Conv.Cnt.le_of_leB DEC_clear.cle0)
    (Conv.heap_off_setAll DEC_clear.cheap0 fun a ha => Nat.blt_eq.mp (List.all_eq_true.mp DEC_clear.zclbd0 a ha)) DEC_clear.zjc0

end Host.Load.Run.Tpl
