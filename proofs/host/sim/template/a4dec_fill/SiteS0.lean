import host.sim.template.a4dec_fill.SiteCl0
import host.sim.conv.CompactFull
import host.sim.template.FootGen
set_option Elab.async false
namespace Host.Load.Run.Tpl
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
open Host.Ts Host.Ts.Sim Host.Ts.Sim.Template

/-! The compaction's native shift at call site 0 from its footprint (`Conv.nshift_of_foot`), and the observers'
(`liveShift_foot`, `kernShift_foot`): `Conv.FullShiftQ` for `Conv.full_compactQ`, given the call's bookkeeping and its
relation's facts. -/

/-- The load parameters of the chain (its start's node counter as `NL` and `N0`). -/
def DEC_fill.P0 : LoadP := ⟨25000, 131072, 1099511627776, 20000, 22539, []⟩
noncomputable abbrev DEC_fill.cx0_0 : Host.Load.LSt := clearTokens (Host.Load.Layers.toLoad DEC_fill.s2.ffi)
noncomputable abbrev DEC_fill.cx1_0 : Host.Load.LSt := clearTokens (Host.Load.Layers.toLoad DEC_fill.s1.ffi)
def DEC_fill.khinv0 : PTrie Nat := Stage.setAll PTrie.nil []
def DEC_fill.kninv0 : PTrie Nat := Stage.setAll PTrie.nil []
/-- The stage's footprint: its written and fresh handles, fresh nodes, written and fresh items. -/
def DEC_fill.cwS0 : List Nat := []
def DEC_fill.cnS0 : List Nat := List.range' 22539 0
def DEC_fill.ciS0 : List Nat := [20157] ++ List.range' 22539 0

-- the small checks (`MChecks`'s)
kernel_rfl DEC_fill.cnh00 : DEC_fill.kd0.nh0 = DEC_fill.cx0_0.mlx.next
kernel_rfl DEC_fill.cnh10 : DEC_fill.kd0.nh1 = DEC_fill.cx1_0.mlx.next
kernel_rfl DEC_fill.cnn00 : DEC_fill.kd0.nn0 = DEC_fill.cx0_0.mlx.nnext
kernel_rfl DEC_fill.cnn10 : DEC_fill.kd0.nn1 = DEC_fill.cx1_0.mlx.nnext
kernel_rfl DEC_fill.cplo0 : (Nat.blt 0 DEC_fill.P0.lo && Nat.ble DEC_fill.P0.lo DEC_fill.cx0_0.mlx.next && Nat.ble DEC_fill.P0.lo RData.bigHi && Nat.ble RData.bigHi DEC_fill.P0.E) = true
kernel_rfl DEC_fill.ccnt0 : (Nat.ble DEC_fill.cx0_0.mlx.next DEC_fill.cx1_0.mlx.next && Nat.ble DEC_fill.cx0_0.mlx.nnext DEC_fill.cx1_0.mlx.nnext) = true
kernel_rfl DEC_fill.cnband0 : (Nat.blt 0 DEC_fill.P0.NL && Nat.ble DEC_fill.P0.NL DEC_fill.P0.N0 && Nat.ble DEC_fill.P0.N0 DEC_fill.cx0_0.mlx.nnext) = true
kernel_rfl DEC_fill.chbelow0 : DEC_fill.kd0.checkHndBelow = true
kernel_rfl DEC_fill.chren0 : checkRenG DEC_fill.kd0.hnd DEC_fill.khinv0 (phB DEC_fill.cx0_0.mlx) = true
kernel_rfl DEC_fill.cband0 : DEC_fill.kd0.checkBand DEC_fill.P0.lo = true
kernel_rfl DEC_fill.cnh1pos0 : Nat.blt 0 DEC_fill.kd0.nh1 = true
kernel_rfl DEC_fill.cnren0 : checkRenG DEC_fill.kd0.node DEC_fill.kninv0 (pnB DEC_fill.cx0_0.mlx) = true
kernel_rfl DEC_fill.cnlow0 : (PTrie.keysA DEC_fill.kd0.node).all (fun j => Nat.ble DEC_fill.P0.NL j && Nat.blt (DEC_fill.kd0.nodeF j) DEC_fill.cx1_0.mlx.nnext) = true
kernel_rfl DEC_fill.cabs0a0 : DEC_fill.cx0_0.mlx.arrs.get 0 = none
kernel_rfl DEC_fill.cabs0b0 : DEC_fill.cx0_0.mlx.objs.get 0 = none
kernel_rfl DEC_fill.ctok10 : DEC_fill.cx1_0.mlx.tokens = []
kernel_rfl DEC_fill.cpend0 : DEC_fill.cx1_0.mlx.pending = DEC_fill.cx0_0.mlx.pending.map DEC_fill.kappa0.pend
kernel_rfl DEC_fill.cerrh0 : DEC_fill.cx1_0.mlx.errh = DEC_fill.cx0_0.mlx.errh.map DEC_fill.kappa0.arg
kernel_rfl DEC_fill.cfiles0 : DEC_fill.cx1_0.mlx.files = DEC_fill.cx0_0.mlx.files
kernel_rfl DEC_fill.carch0 : DEC_fill.cx1_0.mlx.arch = DEC_fill.cx0_0.mlx.arch
kernel_rfl DEC_fill.csizes0 : DEC_fill.cx1_0.mlx.deviceSizes = DEC_fill.cx0_0.mlx.deviceSizes
kernel_rfl DEC_fill.cwired0 : DEC_fill.cx1_0.mlx.wired = DEC_fill.cx0_0.mlx.wired
kernel_rfl DEC_fill.chost0 : DEC_fill.cx1_0.host = DEC_fill.cx0_0.host
-- the compaction map's addresses are `DEC_fill.kd0`'s
kernel_rfl DEC_fill.ckn00 : DEC_fill.kd0.n0 = 3123568
kernel_rfl DEC_fill.ckn10 : DEC_fill.kd0.n1 = 3123580
kernel_rfl DEC_fill.ckheap0 : (PTrie.keysA DEC_fill.kd0.heap).all (fun x => Nat.ble 3123568 x) = true
kernel_rfl DEC_fill.ckpl0 : (List.range 0).all (fun j => decide (DEC_fill.kd0.heap.get (3123568 + j) = nth? DEC_fill.pl0 j)) = true
-- the map fixes the call's names (`Conv.fixOld_compact`), the call's counters
kernel_rfl DEC_fill.fja0 : Nat.ble 3123568 3123568 = true
kernel_rfl DEC_fill.fn0 : Nat.ble 123 123 = true
kernel_rfl DEC_fill.fjaD0 : Nat.ble 3123568 DEC_fill.kd0.n0 = true
kernel_rfl DEC_fill.fxn0 : Nat.ble 29302 DEC_fill.kd0.nh0 = true
kernel_rfl DEC_fill.fnn0 : Nat.ble 22539 DEC_fill.kd0.nn0 = true
kernel_rfl DEC_fill.fxb0 : Nat.ble 29302 RData.bigHi = true
kernel_rfl DEC_fill.fheap0 : (PTrie.keysA DEC_fill.kd0.heap).all (Nat.ble (⟨29302, 22539, 3123568, 123⟩ : Conv.Cnt).ja) = true
kernel_rfl DEC_fill.fhnd0 : (PTrie.keysA DEC_fill.kd0.hnd).all (Nat.ble (⟨29302, 22539, 3123568, 123⟩ : Conv.Cnt).xn) = true
kernel_rfl DEC_fill.fnode0 : (PTrie.keysA DEC_fill.kd0.node).all (Nat.ble (⟨29302, 22539, 3123568, 123⟩ : Conv.Cnt).nn) = true
/-- The compaction map fixes the call's names. -/
theorem DEC_fill.cfix0 : Conv.FixOld (⟨29302, 22539, 3123568, 123⟩ : Conv.Cnt) DEC_fill.kappa0 :=
  Conv.fixOld_compact (Nat.le_of_ble_eq_true DEC_fill.fja0) (Nat.le_of_ble_eq_true DEC_fill.fn0) (Nat.le_of_ble_eq_true DEC_fill.fjaD0) (Nat.le_of_ble_eq_true DEC_fill.fxn0) (Nat.le_of_ble_eq_true DEC_fill.fnn0) (Nat.le_of_ble_eq_true DEC_fill.fxb0) DEC_fill.fheap0 DEC_fill.fhnd0 DEC_fill.fnode0
kernel_rfl DEC_fill.fcxn0 : (⟨29302, 22539, 3123568, 123⟩ : Conv.Cnt).xn = (Host.Load.Layers.toLoad DEC_fill.s0.ffi).mlx.next
kernel_rfl DEC_fill.fcnn0 : (⟨29302, 22539, 3123568, 123⟩ : Conv.Cnt).nn = (Host.Load.Layers.toLoad DEC_fill.s0.ffi).mlx.nnext
kernel_rfl DEC_fill.fle00 : (Nat.ble (Host.Load.Layers.toLoad DEC_fill.s0.ffi).mlx.next DEC_fill.cx0_0.mlx.next && Nat.ble (Host.Load.Layers.toLoad DEC_fill.s0.ffi).mlx.nnext DEC_fill.cx0_0.mlx.nnext && Nat.ble (Host.Load.Layers.toLoad DEC_fill.s0.ffi).mlx.next RData.bigHi) = true
kernel_rfl DEC_fill.fnk0 : (PTrie.keysA DEC_fill.kd0.node).all (Nat.ble (Host.Load.Layers.toLoad DEC_fill.s0.ffi).mlx.nnext) = true
-- the merged state keeps the call's entries off the stage's footprint
kernel_rfl DEC_fill.f1A0 : DEC_fill.cx1_0.mlx.arrs = Stage.setAll (Host.Load.Layers.toLoad DEC_fill.s0.ffi).mlx.arrs (DEC_fill.cwS0.filterMap fun i => (DEC_fill.cx1_0.mlx.arrs.get i).map (i, ·))
kernel_rfl DEC_fill.f1O0 : DEC_fill.cx1_0.mlx.objs = Stage.setAll (Host.Load.Layers.toLoad DEC_fill.s0.ffi).mlx.objs (DEC_fill.cwS0.filterMap fun i => (DEC_fill.cx1_0.mlx.objs.get i).map (i, ·))
kernel_rfl DEC_fill.f1N0 : DEC_fill.cx1_0.mlx.nodes = Stage.setAll (Host.Load.Layers.toLoad DEC_fill.s0.ffi).mlx.nodes (DEC_fill.cnS0.filterMap fun i => (DEC_fill.cx1_0.mlx.nodes.get i).map (i, ·))
kernel_rfl DEC_fill.f1I0 : DEC_fill.cx1_0.mlx.items = Stage.setAll (Host.Load.Layers.toLoad DEC_fill.s0.ffi).mlx.items (DEC_fill.ciS0.filterMap fun i => (DEC_fill.cx1_0.mlx.items.get i).map (i, ·))
kernel_rfl DEC_fill.fbd0 : (DEC_fill.clo0 ++ DEC_fill.cln0 ++ DEC_fill.cli0 ++ DEC_fill.cwS0 ++ DEC_fill.cnS0 ++ DEC_fill.ciS0).all (fun i => Nat.blt (i / 4096) (4 ^ 31)) = true
kernel_rfl DEC_fill.fincW0 : DEC_fill.cwS0.all (fun h => !Nat.blt h (Host.Load.Layers.toLoad DEC_fill.s0.ffi).mlx.next || DEC_fill.clo0.contains h) = true
kernel_rfl DEC_fill.fincI0 : DEC_fill.ciS0.all (fun k => !Nat.blt k (Host.Load.Layers.toLoad DEC_fill.s0.ffi).mlx.nnext || DEC_fill.cli0.contains k) = true
kernel_rfl DEC_fill.fincN0 : DEC_fill.cnS0.all (Nat.ble (Host.Load.Layers.toLoad DEC_fill.s0.ffi).mlx.nnext) = true
kernel_rfl DEC_fill.flnF0 : DEC_fill.cln0.all (Nat.ble (Host.Load.Layers.toLoad DEC_fill.s0.ffi).mlx.nnext) = true
-- the checks over the changed lists
kernel_rfl DEC_fill.fh0 : DEC_fill.clo0.all (handleOK DEC_fill.kappa0 DEC_fill.P0.lo DEC_fill.cx0_0.mlx DEC_fill.cx1_0.mlx) = true
kernel_rfl DEC_fill.fo0 : DEC_fill.clo0.map (fun h => DEC_fill.cx1_0.mlx.objs.get (DEC_fill.kappa0.handle h)) = DEC_fill.clo0.map (fun h => (DEC_fill.cx0_0.mlx.objs.get h).map DEC_fill.kappa0.nobj)
kernel_rfl DEC_fill.fok0 : DEC_fill.clo0.all (objOK DEC_fill.kappa0 DEC_fill.P0.NL DEC_fill.cx0_0.mlx) = true
kernel_rfl DEC_fill.fnd0 : DEC_fill.cln0.all (nodeOKF DEC_fill.kappa0 DEC_fill.P0 DEC_fill.cx0_0.mlx DEC_fill.cx1_0.mlx) = true
kernel_rfl DEC_fill.fp0 : ((DEC_fill.cln0.filter (fullB DEC_fill.P0))).map (fun i => (DEC_fill.cx1_0.mlx.nodes.get (DEC_fill.kappa0.node i)).map Host.Mlx.Ffi.Node.prim) =
  ((DEC_fill.cln0.filter (fullB DEC_fill.P0))).map (fun i => (DEC_fill.cx0_0.mlx.nodes.get i).map fun nd => DEC_fill.kappa0.prim nd.prim)
kernel_rfl DEC_fill.fnordI0 : incrB DEC_fill.kd0.nodeF (List.range' 22539 0) = true
kernel_rfl DEC_fill.fnordK0 : (PTrie.keysA DEC_fill.kd0.node).all (fun k => Nat.ble 22539 k && Nat.blt k 22539) = true
kernel_rfl DEC_fill.fnordL0 : (DEC_fill.cln0.filter (Nat.ble DEC_fill.P0.N0)).all (fun i => Nat.ble i (DEC_fill.kd0.nodeF i) && (Nat.blt i 22539 || Nat.ble DEC_fill.kd0.nn0 i)) = true
theorem DEC_fill.fnord0 : (DEC_fill.cln0.filter (Nat.ble DEC_fill.P0.N0)).all (fun i => Nat.ble i (DEC_fill.kd0.nodeF i) &&
    (PTrie.keysA DEC_fill.kd0.node).all fun j => !Nat.blt j i || Nat.blt (DEC_fill.kd0.nodeF j) (DEC_fill.kd0.nodeF i)) = true :=
  cnord_of DEC_fill.cnlow0 DEC_fill.cnn10 DEC_fill.fnordI0 DEC_fill.fnordK0 DEC_fill.fnordL0
kernel_rfl DEC_fill.fi0 : DEC_fill.cli0.all (pnB DEC_fill.cx0_0.mlx) = true
kernel_rfl DEC_fill.fii0 : DEC_fill.cli0.all (fun k => decide (DEC_fill.cx1_0.mlx.items.get (DEC_fill.kappa0.node k) = (DEC_fill.cx0_0.mlx.items.get k).map DEC_fill.kappa0.nv)) = true
/-- **The compaction's footprint.** -/
theorem DEC_fill.cfoot0 (clean : Conv.NClean (⟨29302, 22539, 3123568, 123⟩ : Conv.Cnt) (Host.Load.Layers.toLoad DEC_fill.s0.ffi).mlx) (hltC : ∀ h, PH (Host.Load.Layers.toLoad DEC_fill.s0.ffi).mlx h → h < (Host.Load.Layers.toLoad DEC_fill.s0.ffi).mlx.next) (nltC : ∀ i, PN (Host.Load.Layers.toLoad DEC_fill.s0.ffi).mlx i → i < (Host.Load.Layers.toLoad DEC_fill.s0.ffi).mlx.nnext) (itemsC : ∀ k v, (Host.Load.Layers.toLoad DEC_fill.s0.ffi).mlx.items.get k = some v → PN (Host.Load.Layers.toLoad DEC_fill.s0.ffi).mlx k) (tracedC : ∀ h o, (Host.Load.Layers.toLoad DEC_fill.s0.ffi).mlx.objs.get h = some o → ∀ i ∈ objTraces o, i < DEC_fill.P0.NL) (cl : SSt (· < 123) DEC_fill.cx0_0.mlx) :
    Conv.MFoot DEC_fill.P0 123 DEC_fill.kappa0 DEC_fill.kd0 DEC_fill.khinv0 DEC_fill.kninv0 (Host.Load.Layers.toLoad DEC_fill.s0.ffi).mlx DEC_fill.cx0_0.mlx DEC_fill.cx1_0.mlx (⟨29302, 22539, 3123568, 123⟩ : Conv.Cnt) DEC_fill.clo0 DEC_fill.cln0 DEC_fill.cli0 DEC_fill.cwS0 DEC_fill.cnS0 DEC_fill.ciS0 :=
  ⟨rfl, rfl, rfl, DEC_fill.cnh00, DEC_fill.cnh10, DEC_fill.cnn00, DEC_fill.cnn10, DEC_fill.cplo0, DEC_fill.ccnt0, DEC_fill.cnband0, DEC_fill.chbelow0, DEC_fill.chren0, DEC_fill.cband0, DEC_fill.cnh1pos0, DEC_fill.cnren0, DEC_fill.cnlow0, DEC_fill.cabs0a0, DEC_fill.cabs0b0, DEC_fill.ctok10, DEC_fill.cpend0, DEC_fill.cerrh0, DEC_fill.cfiles0, DEC_fill.carch0, DEC_fill.csizes0, DEC_fill.cwired0, DEC_fill.cfix0, clean, DEC_fill.fcxn0, DEC_fill.fcnn0, hltC, nltC, itemsC, tracedC, cl, DEC_fill.fle00, DEC_fill.fnk0, DEC_fill.ckA0, DEC_fill.cobjsK0, DEC_fill.cnodesK0, DEC_fill.citemsK0, DEC_fill.f1A0, DEC_fill.f1O0, DEC_fill.f1N0, DEC_fill.f1I0, DEC_fill.fbd0, DEC_fill.fincW0, DEC_fill.fincI0, DEC_fill.fincN0, DEC_fill.flnF0, DEC_fill.fh0, DEC_fill.fo0, DEC_fill.fok0, DEC_fill.fnd0, DEC_fill.fp0, DEC_fill.fnord0, DEC_fill.fi0, DEC_fill.fii0⟩
theorem DEC_fill.cnshift0 (clean : Conv.NClean (⟨29302, 22539, 3123568, 123⟩ : Conv.Cnt) (Host.Load.Layers.toLoad DEC_fill.s0.ffi).mlx) (hltC : ∀ h, PH (Host.Load.Layers.toLoad DEC_fill.s0.ffi).mlx h → h < (Host.Load.Layers.toLoad DEC_fill.s0.ffi).mlx.next) (nltC : ∀ i, PN (Host.Load.Layers.toLoad DEC_fill.s0.ffi).mlx i → i < (Host.Load.Layers.toLoad DEC_fill.s0.ffi).mlx.nnext) (itemsC : ∀ k v, (Host.Load.Layers.toLoad DEC_fill.s0.ffi).mlx.items.get k = some v → PN (Host.Load.Layers.toLoad DEC_fill.s0.ffi).mlx k) (tracedC : ∀ h o, (Host.Load.Layers.toLoad DEC_fill.s0.ffi).mlx.objs.get h = some o → ∀ i ∈ objTraces o, i < DEC_fill.P0.NL) (cl : SSt (· < 123) DEC_fill.cx0_0.mlx) : NShift DEC_fill.P0 123 DEC_fill.kappa0 DEC_fill.cx0_0 DEC_fill.cx1_0 :=
  Conv.nshift_of_foot (DEC_fill.cfoot0 clean hltC nltC itemsC tracedC cl) DEC_fill.chost0 (compact_a_eq DEC_fill.ckn00 DEC_fill.ckn10 DEC_fill.ckheap0 DEC_fill.ckpl0)

-- the observers: the layers' states at the call, the canonical and the merged state, their footprints and checks
noncomputable def DEC_fill.fxC_0 : PTrie Unit := (Host.Ts.Sim.Full.freedOf DEC_fill.s0.ffi).getD PTrie.nil
noncomputable def DEC_fill.krC_0 : Host.Load.Layers.KRec := (Host.Ts.Sim.Full.krecOf DEC_fill.s0.ffi).getD Host.Load.Layers.KRec.empty
kernel_rfl DEC_fill.ofxC_0 : (Host.Ts.Sim.Full.freedOf DEC_fill.s0.ffi) = some DEC_fill.fxC_0
kernel_rfl DEC_fill.okrC_0 : (Host.Ts.Sim.Full.krecOf DEC_fill.s0.ffi) = some DEC_fill.krC_0
noncomputable def DEC_fill.fx0_0 : PTrie Unit := (Host.Ts.Sim.Full.freedOf DEC_fill.s2.ffi).getD PTrie.nil
noncomputable def DEC_fill.kr0_0 : Host.Load.Layers.KRec := (Host.Ts.Sim.Full.krecOf DEC_fill.s2.ffi).getD Host.Load.Layers.KRec.empty
kernel_rfl DEC_fill.ofx0_0 : (Host.Ts.Sim.Full.freedOf DEC_fill.s2.ffi) = some DEC_fill.fx0_0
kernel_rfl DEC_fill.okr0_0 : (Host.Ts.Sim.Full.krecOf DEC_fill.s2.ffi) = some DEC_fill.kr0_0
noncomputable def DEC_fill.fx1_0 : PTrie Unit := (Host.Ts.Sim.Full.freedOf DEC_fill.s1.ffi).getD PTrie.nil
noncomputable def DEC_fill.kr1_0 : Host.Load.Layers.KRec := (Host.Ts.Sim.Full.krecOf DEC_fill.s1.ffi).getD Host.Load.Layers.KRec.empty
kernel_rfl DEC_fill.ofx1_0 : (Host.Ts.Sim.Full.freedOf DEC_fill.s1.ffi) = some DEC_fill.fx1_0
kernel_rfl DEC_fill.okr1_0 : (Host.Ts.Sim.Full.krecOf DEC_fill.s1.ffi) = some DEC_fill.kr1_0
kernel_rfl DEC_fill.ff00 : DEC_fill.fx0_0 = Stage.setAll DEC_fill.fxC_0 (DEC_fill.clo0.filterMap fun i => (DEC_fill.fx0_0.get i).map (i, ·))
kernel_rfl DEC_fill.ff10 : DEC_fill.fx1_0 = Stage.setAll DEC_fill.fxC_0 (DEC_fill.cwS0.filterMap fun i => (DEC_fill.fx1_0.get i).map (i, ·))
kernel_rfl DEC_fill.ffck0 : freedLB DEC_fill.kappa0 DEC_fill.cx0_0.mlx DEC_fill.fx0_0 DEC_fill.fx1_0 DEC_fill.clo0 = true
kernel_rfl DEC_fill.fkf00 : DEC_fill.kr0_0.flags = Stage.setAll DEC_fill.krC_0.flags (DEC_fill.clo0.filterMap fun i => (DEC_fill.kr0_0.flags.get i).map (i, ·))
kernel_rfl DEC_fill.fkt00 : DEC_fill.kr0_0.targs = Stage.setAll DEC_fill.krC_0.targs (DEC_fill.clo0.filterMap fun i => (DEC_fill.kr0_0.targs.get i).map (i, ·))
kernel_rfl DEC_fill.fkf10 : DEC_fill.kr1_0.flags = Stage.setAll DEC_fill.krC_0.flags (DEC_fill.cwS0.filterMap fun i => (DEC_fill.kr1_0.flags.get i).map (i, ·))
kernel_rfl DEC_fill.fkt10 : DEC_fill.kr1_0.targs = Stage.setAll DEC_fill.krC_0.targs (DEC_fill.cwS0.filterMap fun i => (DEC_fill.kr1_0.targs.get i).map (i, ·))
kernel_rfl DEC_fill.fkck0 : krecLB DEC_fill.kappa0 123 DEC_fill.cx0_0.mlx DEC_fill.kr0_0 DEC_fill.kr1_0 DEC_fill.clo0 = true
kernel_rfl DEC_fill.fkn0 : Nat.ble 123 123 = true
-- the bridge and the pending traces' regions
kernel_rfl DEC_fill.cbridge0 : Host.Ts.Sim.Full.bridgeOf DEC_fill.s1.ffi = Host.Ts.Sim.Full.bridgeOf DEC_fill.s2.ffi
kernel_rfl DEC_fill.cpendR0 : pendRegB DEC_fill.kappa0 (Host.Load.Layers.toLoad DEC_fill.s2.ffi).mlx = true
kernel_rfl DEC_fill.cpendLe0 : Nat.ble (Host.Load.Layers.toLoad DEC_fill.s2.ffi).mlx.next (Host.Load.Layers.toLoad DEC_fill.s1.ffi).mlx.next = true
/-- **The compaction's native shift**, given the call's bookkeeping, its relation's facts (the model's and the
observers') and the canonical closedness. -/
theorem DEC_fill.cshift0 (clean : Conv.NClean (⟨29302, 22539, 3123568, 123⟩ : Conv.Cnt) (Host.Load.Layers.toLoad DEC_fill.s0.ffi).mlx) (hltC : ∀ h, PH (Host.Load.Layers.toLoad DEC_fill.s0.ffi).mlx h → h < (Host.Load.Layers.toLoad DEC_fill.s0.ffi).mlx.next) (nltC : ∀ i, PN (Host.Load.Layers.toLoad DEC_fill.s0.ffi).mlx i → i < (Host.Load.Layers.toLoad DEC_fill.s0.ffi).mlx.nnext) (itemsC : ∀ k v, (Host.Load.Layers.toLoad DEC_fill.s0.ffi).mlx.items.get k = some v → PN (Host.Load.Layers.toLoad DEC_fill.s0.ffi).mlx k) (tracedC : ∀ h o, (Host.Load.Layers.toLoad DEC_fill.s0.ffi).mlx.objs.get h = some o → ∀ i ∈ objTraces o, i < DEC_fill.P0.NL) (cl : SSt (· < 123) DEC_fill.cx0_0.mlx)
    (hobjC : ∀ h, DEC_fill.fxC_0.get h = some () → ((Host.Load.Layers.toLoad DEC_fill.s0.ffi).mlx.objs.get h).isSome = true)
    (hfC : ∀ h, (DEC_fill.krC_0.flags.get h).isSome = true → ((Host.Load.Layers.toLoad DEC_fill.s0.ffi).mlx.objs.get h).isSome = true)
    (htC : ∀ h, (DEC_fill.krC_0.targs.get h).isSome = true → ((Host.Load.Layers.toLoad DEC_fill.s0.ffi).mlx.objs.get h).isSome = true)
    (hclC : ∀ h l, DEC_fill.krC_0.targs.get h = some l → Host.Ts.Sim.Full.STargs (· < (⟨29302, 22539, 3123568, 123⟩ : Conv.Cnt).n) l) :
    Conv.FullShiftQ DEC_fill.P0 123 DEC_fill.kappa0 DEC_fill.s2.ffi DEC_fill.s1.ffi :=
  ⟨DEC_fill.cnshift0 clean hltC nltC itemsC tracedC cl, DEC_fill.cqueue0, fun t ht => bSN_sound (List.all_eq_true.mp DEC_fill.ctokSupp0 t ht),
    DEC_fill.cbridge0,
    liveShift_foot (x0' := Host.Ts.Sim.Full.mlxOf DEC_fill.s2.ffi) (x1' := Host.Ts.Sim.Full.mlxOf DEC_fill.s1.ffi) (DEC_fill.cfoot0 clean hltC nltC itemsC tracedC cl) rfl DEC_fill.ofx0_0 DEC_fill.ofx1_0 hobjC DEC_fill.ff00 DEC_fill.ff10 DEC_fill.ffck0,
    kernShift_foot (x0' := Host.Ts.Sim.Full.mlxOf DEC_fill.s2.ffi) (x1' := Host.Ts.Sim.Full.mlxOf DEC_fill.s1.ffi) (DEC_fill.cfoot0 clean hltC nltC itemsC tracedC cl) rfl DEC_fill.okr0_0 DEC_fill.okr1_0 (Nat.le_of_ble_eq_true DEC_fill.fkn0) hfC htC hclC
      DEC_fill.fkf00 DEC_fill.fkt00 DEC_fill.fkf10 DEC_fill.fkt10 DEC_fill.fkck0,
    pendReg_of rfl DEC_fill.cnh00 DEC_fill.cnh10 (Nat.le_of_ble_eq_true DEC_fill.cpendLe0) DEC_fill.cpendR0⟩

end Host.Load.Run.Tpl
