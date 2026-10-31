import host.sim.template.a4dec_ord.SiteS0
import host.sim.template.a4dec_ord.SiteK0
import host.sim.template.a4dec_ord.SiteF0
import host.sim.conv.CompactShift
import host.sim.template.Check
import host.sim.BigFreeP
import host.sim.template.CallGen
set_option Elab.async false
namespace Host.Load.Run.Tpl
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
open Host.Ts Host.Ts.Sim Host.Ts.Sim.Template

/-! The compaction's state shift at call site 0 of chain `DEC_ord` (`Conv.compact_shift`): the call `DEC_ord.s0`, the merged
state `DEC_ord.s1`, the canonical state `DEC_ord.s2`; its frames [2673448,12504,2665,4910] (kept arrays [2673448,12504,2665]). -/

-- the map's places and counters
kernel_rfl DEC_ord.zpl0 : DEC_ord.pl0.all (Nat.ble DEC_ord.s0.next) = true
kernel_rfl DEC_ord.zplnd0 : nodupT DEC_ord.pl0 PTrie.nil = true
kernel_rfl DEC_ord.zn10 : Nat.ble DEC_ord.s0.next 3123580 = true
kernel_rfl DEC_ord.zfirst0 : Nat.ble aFirst DEC_ord.s0.next = true
kernel_rfl DEC_ord.zscn0 : DEC_ord.s2.next = DEC_ord.s0.next + DEC_ord.pl0.length
kernel_rfl DEC_ord.zsmn0 : DEC_ord.s1.next = 3123580
kernel_rfl DEC_ord.zgrow0 : Nat.ble DEC_ord.s2.next DEC_ord.s1.next = true
-- the tables
kernel_rfl DEC_ord.zfresh0 : DEC_ord.S0.tab.all (fun e => DEC_ord.cws0.all fun v => e.noVar v) = true
kernel_rfl DEC_ord.zcnd0 : nodupT DEC_ord.cws0 PTrie.nil = true
kernel_rfl DEC_ord.znrHi0 : DEC_ord.nr0.all (fun r => Nat.blt r DEC_ord.S1.tab.length) = true
-- the frames: every framed address below the call's counter; the kept arrays the chain start's, extended in the merged state
kernel_rfl DEC_ord.zfrlt0 : [2673448, 12504, 2665, 4910].all (fun a => Nat.blt a DEC_ord.s0.next) = true
kernel_rfl DEC_ord.zg0_2673448 : DEC_ord.s2.heap.get 2673448 = some (.obj (objOf DEC_ord.s2 2673448))
kernel_rfl DEC_ord.zk0_2673448 : (objOf DEC_ord.s2 2673448).kind = .array (arrOf DEC_ord.s0 2673448)
kernel_rfl DEC_ord.zm0_2673448 : DEC_ord.s1.heap.get 2673448 = some (.obj { DEC_ord.kappa0.obj (objOf DEC_ord.s2 2673448) with
  kind := .array (arrOf DEC_ord.s0 2673448 ++ (arrOf DEC_ord.s1 2673448).drop (arrOf DEC_ord.s0 2673448).length) })
kernel_rfl DEC_ord.zg0_12504 : DEC_ord.s2.heap.get 12504 = some (.obj (objOf DEC_ord.s2 12504))
kernel_rfl DEC_ord.zk0_12504 : (objOf DEC_ord.s2 12504).kind = .array (arrOf DEC_ord.s0 12504)
kernel_rfl DEC_ord.zm0_12504 : DEC_ord.s1.heap.get 12504 = some (.obj { DEC_ord.kappa0.obj (objOf DEC_ord.s2 12504) with
  kind := .array (arrOf DEC_ord.s0 12504 ++ (arrOf DEC_ord.s1 12504).drop (arrOf DEC_ord.s0 12504).length) })
kernel_rfl DEC_ord.zg0_2665 : DEC_ord.s2.heap.get 2665 = some (.obj (objOf DEC_ord.s2 2665))
kernel_rfl DEC_ord.zk0_2665 : (objOf DEC_ord.s2 2665).kind = .array (arrOf DEC_ord.s0 2665)
kernel_rfl DEC_ord.zm0_2665 : DEC_ord.s1.heap.get 2665 = some (.obj { DEC_ord.kappa0.obj (objOf DEC_ord.s2 2665) with
  kind := .array (arrOf DEC_ord.s0 2665 ++ (arrOf DEC_ord.s1 2665).drop (arrOf DEC_ord.s0 2665).length) })
kernel_rfl DEC_ord.zw0_4910 : (DEC_ord.s2.heap.get 4910).isSome = true
-- the heap: the changed list in range, holding the stage's written and fresh addresses; the canonical side's image
kernel_rfl DEC_ord.zclbd0 : DEC_ord.cl0.all (fun b => Nat.blt (b / 4096) (4 ^ 31)) = true
kernel_rfl DEC_ord.zwr0 : DEC_ord.st0.wr.all (fun b => !Nat.blt b DEC_ord.s0.next || DEC_ord.cl0.contains b) = true
def DEC_ord.zl0 : List Nat := DEC_ord.cl0.filter fun a => !(List.contains [2673448, 12504, 2665] a)
kernel_rfl DEC_ord.zimgE0 : DEC_ord.zl0.map (fun a => DEC_ord.s1.heap.get (DEC_ord.kappa0.a a)) = DEC_ord.zl0.map (fun a => (DEC_ord.s2.heap.get a).map DEC_ord.kappa0.hobj)
theorem DEC_ord.zimg0 : HeapImg DEC_ord.kappa0 DEC_ord.s2 DEC_ord.s1 DEC_ord.zl0 := DEC_ord.zimgE0
-- the roots and their supports
kernel_rfl DEC_ord.zctl0 : DEC_ord.s1.ctl = DEC_ord.kappa0.ctl DEC_ord.s2.ctl
kernel_rfl DEC_ord.zstack0 : DEC_ord.s1.stack = DEC_ord.s2.stack.map DEC_ord.kappa0.frame
kernel_rfl DEC_ord.zjobs0 : DEC_ord.s1.jobs = DEC_ord.s2.jobs.map DEC_ord.kappa0.job
kernel_rfl DEC_ord.zstores0 : DEC_ord.s1.stores = DEC_ord.kappa0.stores DEC_ord.s2.stores
kernel_rfl DEC_ord.zroots0 : checkRootsSupp DEC_ord.s2 123 = true
kernel_rfl DEC_ord.znC0 : DEC_ord.S0.tab.length + DEC_ord.cws0.length = 123
-- the map as `Conv.compact_shift` states it (the call's counters for the literals)
kernel_rfl DEC_ord.zkap0 : DEC_ord.kappa0 = Conv.Map.compact DEC_ord.s0.next 3123580 DEC_ord.S0.tab.length DEC_ord.pl0 (DEC_ord.nr0.map NumV.ref) DEC_ord.kd0.big
  DEC_ord.kd0.region DEC_ord.kd0.nodeF
-- the bridge inactive at the canonical state (`Conv.FullShiftQ.toX`; the merged state's bridge is the canonical's: cbridge)
kernel_rfl DEC_ord.zbin0 : (Host.Ts.Sim.Full.bridgeOf DEC_ord.s2.ffi).active = false
-- the JS bookkeeping's step (`Conv.JClean.step` over the changed list) and the canonical roots' bigint freedom
kernel_rfl DEC_ord.zjc0 : Conv.jcleanListB (⟨29302, 22539, 3123568, 123⟩ : Conv.Cnt) DEC_ord.s2 DEC_ord.cl0 = true
kernel_rfl DEC_ord.zroots20 : noBigRootsP (fun i => !Conv.oldBigB (⟨29302, 22539, 3123568, 123⟩ : Conv.Cnt) i) DEC_ord.s2.trace DEC_ord.s2 = true
kernel_rfl DEC_ord.zhm0 : Nat.ble (Host.Load.Layers.toLoad DEC_ord.s0.ffi).mlx.nnext 22539 = true
theorem DEC_ord.cjcl0 (h : Conv.JClean (⟨29302, 22539, 3123568, 123⟩ : Conv.Cnt) DEC_ord.s0) : Conv.JClean (⟨29302, 22539, 3123568, 123⟩ : Conv.Cnt) DEC_ord.s2 :=
  Conv.JClean.step h (Conv.Cnt.le_of_leB DEC_ord.cle0)
    (Conv.heap_off_setAll DEC_ord.cheap0 fun a ha => Nat.blt_eq.mp (List.all_eq_true.mp DEC_ord.zclbd0 a ha)) DEC_ord.zjc0

end Host.Load.Run.Tpl
