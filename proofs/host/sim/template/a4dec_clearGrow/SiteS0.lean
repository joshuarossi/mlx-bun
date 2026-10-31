import host.sim.template.a4dec_clearGrow.SiteCl0
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
def DEC_clearGrow.P0 : LoadP := ⟨25000, 131072, 1099511627776, 20000, 22539, []⟩
noncomputable abbrev DEC_clearGrow.cx0_0 : Host.Load.LSt := clearTokens (Host.Load.Layers.toLoad DEC_clearGrow.s2.ffi)
noncomputable abbrev DEC_clearGrow.cx1_0 : Host.Load.LSt := clearTokens (Host.Load.Layers.toLoad DEC_clearGrow.s1.ffi)
def DEC_clearGrow.khinv0 : PTrie Nat := Stage.setAll PTrie.nil []
def DEC_clearGrow.kninv0 : PTrie Nat := Stage.setAll PTrie.nil []
/-- The stage's footprint: its written and fresh handles, fresh nodes, written and fresh items. -/
def DEC_clearGrow.cwS0 : List Nat := []
def DEC_clearGrow.cnS0 : List Nat := List.range' 22539 0
def DEC_clearGrow.ciS0 : List Nat := [20157] ++ List.range' 22539 0

-- the small checks (`MChecks`'s)
kernel_rfl DEC_clearGrow.cnh00 : DEC_clearGrow.kd0.nh0 = DEC_clearGrow.cx0_0.mlx.next
kernel_rfl DEC_clearGrow.cnh10 : DEC_clearGrow.kd0.nh1 = DEC_clearGrow.cx1_0.mlx.next
kernel_rfl DEC_clearGrow.cnn00 : DEC_clearGrow.kd0.nn0 = DEC_clearGrow.cx0_0.mlx.nnext
kernel_rfl DEC_clearGrow.cnn10 : DEC_clearGrow.kd0.nn1 = DEC_clearGrow.cx1_0.mlx.nnext
kernel_rfl DEC_clearGrow.cplo0 : (Nat.blt 0 DEC_clearGrow.P0.lo && Nat.ble DEC_clearGrow.P0.lo DEC_clearGrow.cx0_0.mlx.next && Nat.ble DEC_clearGrow.P0.lo RData.bigHi && Nat.ble RData.bigHi DEC_clearGrow.P0.E) = true
kernel_rfl DEC_clearGrow.ccnt0 : (Nat.ble DEC_clearGrow.cx0_0.mlx.next DEC_clearGrow.cx1_0.mlx.next && Nat.ble DEC_clearGrow.cx0_0.mlx.nnext DEC_clearGrow.cx1_0.mlx.nnext) = true
kernel_rfl DEC_clearGrow.cnband0 : (Nat.blt 0 DEC_clearGrow.P0.NL && Nat.ble DEC_clearGrow.P0.NL DEC_clearGrow.P0.N0 && Nat.ble DEC_clearGrow.P0.N0 DEC_clearGrow.cx0_0.mlx.nnext) = true
kernel_rfl DEC_clearGrow.chbelow0 : DEC_clearGrow.kd0.checkHndBelow = true
kernel_rfl DEC_clearGrow.chren0 : checkRenG DEC_clearGrow.kd0.hnd DEC_clearGrow.khinv0 (phB DEC_clearGrow.cx0_0.mlx) = true
kernel_rfl DEC_clearGrow.cband0 : DEC_clearGrow.kd0.checkBand DEC_clearGrow.P0.lo = true
kernel_rfl DEC_clearGrow.cnh1pos0 : Nat.blt 0 DEC_clearGrow.kd0.nh1 = true
kernel_rfl DEC_clearGrow.cnren0 : checkRenG DEC_clearGrow.kd0.node DEC_clearGrow.kninv0 (pnB DEC_clearGrow.cx0_0.mlx) = true
kernel_rfl DEC_clearGrow.cnlow0 : (PTrie.keysA DEC_clearGrow.kd0.node).all (fun j => Nat.ble DEC_clearGrow.P0.NL j && Nat.blt (DEC_clearGrow.kd0.nodeF j) DEC_clearGrow.cx1_0.mlx.nnext) = true
kernel_rfl DEC_clearGrow.cabs0a0 : DEC_clearGrow.cx0_0.mlx.arrs.get 0 = none
kernel_rfl DEC_clearGrow.cabs0b0 : DEC_clearGrow.cx0_0.mlx.objs.get 0 = none
kernel_rfl DEC_clearGrow.ctok10 : DEC_clearGrow.cx1_0.mlx.tokens = []
kernel_rfl DEC_clearGrow.cpend0 : DEC_clearGrow.cx1_0.mlx.pending = DEC_clearGrow.cx0_0.mlx.pending.map DEC_clearGrow.kappa0.pend
kernel_rfl DEC_clearGrow.cerrh0 : DEC_clearGrow.cx1_0.mlx.errh = DEC_clearGrow.cx0_0.mlx.errh.map DEC_clearGrow.kappa0.arg
kernel_rfl DEC_clearGrow.cfiles0 : DEC_clearGrow.cx1_0.mlx.files = DEC_clearGrow.cx0_0.mlx.files
kernel_rfl DEC_clearGrow.carch0 : DEC_clearGrow.cx1_0.mlx.arch = DEC_clearGrow.cx0_0.mlx.arch
kernel_rfl DEC_clearGrow.csizes0 : DEC_clearGrow.cx1_0.mlx.deviceSizes = DEC_clearGrow.cx0_0.mlx.deviceSizes
kernel_rfl DEC_clearGrow.cwired0 : DEC_clearGrow.cx1_0.mlx.wired = DEC_clearGrow.cx0_0.mlx.wired
kernel_rfl DEC_clearGrow.chost0 : DEC_clearGrow.cx1_0.host = DEC_clearGrow.cx0_0.host
-- the compaction map's addresses are `DEC_clearGrow.kd0`'s
kernel_rfl DEC_clearGrow.ckn00 : DEC_clearGrow.kd0.n0 = 3123568
kernel_rfl DEC_clearGrow.ckn10 : DEC_clearGrow.kd0.n1 = 3123580
kernel_rfl DEC_clearGrow.ckheap0 : (PTrie.keysA DEC_clearGrow.kd0.heap).all (fun x => Nat.ble 3123568 x) = true
kernel_rfl DEC_clearGrow.ckpl0 : (List.range 0).all (fun j => decide (DEC_clearGrow.kd0.heap.get (3123568 + j) = nth? DEC_clearGrow.pl0 j)) = true
-- the map fixes the call's names (`Conv.fixOld_compact`), the call's counters
kernel_rfl DEC_clearGrow.fja0 : Nat.ble 3123568 3123568 = true
kernel_rfl DEC_clearGrow.fn0 : Nat.ble 123 123 = true
kernel_rfl DEC_clearGrow.fjaD0 : Nat.ble 3123568 DEC_clearGrow.kd0.n0 = true
kernel_rfl DEC_clearGrow.fxn0 : Nat.ble 29302 DEC_clearGrow.kd0.nh0 = true
kernel_rfl DEC_clearGrow.fnn0 : Nat.ble 22539 DEC_clearGrow.kd0.nn0 = true
kernel_rfl DEC_clearGrow.fxb0 : Nat.ble 29302 RData.bigHi = true
kernel_rfl DEC_clearGrow.fheap0 : (PTrie.keysA DEC_clearGrow.kd0.heap).all (Nat.ble (⟨29302, 22539, 3123568, 123⟩ : Conv.Cnt).ja) = true
kernel_rfl DEC_clearGrow.fhnd0 : (PTrie.keysA DEC_clearGrow.kd0.hnd).all (Nat.ble (⟨29302, 22539, 3123568, 123⟩ : Conv.Cnt).xn) = true
kernel_rfl DEC_clearGrow.fnode0 : (PTrie.keysA DEC_clearGrow.kd0.node).all (Nat.ble (⟨29302, 22539, 3123568, 123⟩ : Conv.Cnt).nn) = true
/-- The compaction map fixes the call's names. -/
theorem DEC_clearGrow.cfix0 : Conv.FixOld (⟨29302, 22539, 3123568, 123⟩ : Conv.Cnt) DEC_clearGrow.kappa0 :=
  Conv.fixOld_compact (Nat.le_of_ble_eq_true DEC_clearGrow.fja0) (Nat.le_of_ble_eq_true DEC_clearGrow.fn0) (Nat.le_of_ble_eq_true DEC_clearGrow.fjaD0) (Nat.le_of_ble_eq_true DEC_clearGrow.fxn0) (Nat.le_of_ble_eq_true DEC_clearGrow.fnn0) (Nat.le_of_ble_eq_true DEC_clearGrow.fxb0) DEC_clearGrow.fheap0 DEC_clearGrow.fhnd0 DEC_clearGrow.fnode0
kernel_rfl DEC_clearGrow.fcxn0 : (⟨29302, 22539, 3123568, 123⟩ : Conv.Cnt).xn = (Host.Load.Layers.toLoad DEC_clearGrow.s0.ffi).mlx.next
kernel_rfl DEC_clearGrow.fcnn0 : (⟨29302, 22539, 3123568, 123⟩ : Conv.Cnt).nn = (Host.Load.Layers.toLoad DEC_clearGrow.s0.ffi).mlx.nnext
kernel_rfl DEC_clearGrow.fle00 : (Nat.ble (Host.Load.Layers.toLoad DEC_clearGrow.s0.ffi).mlx.next DEC_clearGrow.cx0_0.mlx.next && Nat.ble (Host.Load.Layers.toLoad DEC_clearGrow.s0.ffi).mlx.nnext DEC_clearGrow.cx0_0.mlx.nnext && Nat.ble (Host.Load.Layers.toLoad DEC_clearGrow.s0.ffi).mlx.next RData.bigHi) = true
kernel_rfl DEC_clearGrow.fnk0 : (PTrie.keysA DEC_clearGrow.kd0.node).all (Nat.ble (Host.Load.Layers.toLoad DEC_clearGrow.s0.ffi).mlx.nnext) = true
-- the merged state keeps the call's entries off the stage's footprint
kernel_rfl DEC_clearGrow.f1A0 : DEC_clearGrow.cx1_0.mlx.arrs = Stage.setAll (Host.Load.Layers.toLoad DEC_clearGrow.s0.ffi).mlx.arrs (DEC_clearGrow.cwS0.filterMap fun i => (DEC_clearGrow.cx1_0.mlx.arrs.get i).map (i, ·))
kernel_rfl DEC_clearGrow.f1O0 : DEC_clearGrow.cx1_0.mlx.objs = Stage.setAll (Host.Load.Layers.toLoad DEC_clearGrow.s0.ffi).mlx.objs (DEC_clearGrow.cwS0.filterMap fun i => (DEC_clearGrow.cx1_0.mlx.objs.get i).map (i, ·))
kernel_rfl DEC_clearGrow.f1N0 : DEC_clearGrow.cx1_0.mlx.nodes = Stage.setAll (Host.Load.Layers.toLoad DEC_clearGrow.s0.ffi).mlx.nodes (DEC_clearGrow.cnS0.filterMap fun i => (DEC_clearGrow.cx1_0.mlx.nodes.get i).map (i, ·))
kernel_rfl DEC_clearGrow.f1I0 : DEC_clearGrow.cx1_0.mlx.items = Stage.setAll (Host.Load.Layers.toLoad DEC_clearGrow.s0.ffi).mlx.items (DEC_clearGrow.ciS0.filterMap fun i => (DEC_clearGrow.cx1_0.mlx.items.get i).map (i, ·))
kernel_rfl DEC_clearGrow.fbd0 : (DEC_clearGrow.clo0 ++ DEC_clearGrow.cln0 ++ DEC_clearGrow.cli0 ++ DEC_clearGrow.cwS0 ++ DEC_clearGrow.cnS0 ++ DEC_clearGrow.ciS0).all (fun i => Nat.blt (i / 4096) (4 ^ 31)) = true
kernel_rfl DEC_clearGrow.fincW0 : DEC_clearGrow.cwS0.all (fun h => !Nat.blt h (Host.Load.Layers.toLoad DEC_clearGrow.s0.ffi).mlx.next || DEC_clearGrow.clo0.contains h) = true
kernel_rfl DEC_clearGrow.fincI0 : DEC_clearGrow.ciS0.all (fun k => !Nat.blt k (Host.Load.Layers.toLoad DEC_clearGrow.s0.ffi).mlx.nnext || DEC_clearGrow.cli0.contains k) = true
kernel_rfl DEC_clearGrow.fincN0 : DEC_clearGrow.cnS0.all (Nat.ble (Host.Load.Layers.toLoad DEC_clearGrow.s0.ffi).mlx.nnext) = true
kernel_rfl DEC_clearGrow.flnF0 : DEC_clearGrow.cln0.all (Nat.ble (Host.Load.Layers.toLoad DEC_clearGrow.s0.ffi).mlx.nnext) = true
-- the checks over the changed lists
kernel_rfl DEC_clearGrow.fh0 : DEC_clearGrow.clo0.all (handleOK DEC_clearGrow.kappa0 DEC_clearGrow.P0.lo DEC_clearGrow.cx0_0.mlx DEC_clearGrow.cx1_0.mlx) = true
kernel_rfl DEC_clearGrow.fo0 : DEC_clearGrow.clo0.map (fun h => DEC_clearGrow.cx1_0.mlx.objs.get (DEC_clearGrow.kappa0.handle h)) = DEC_clearGrow.clo0.map (fun h => (DEC_clearGrow.cx0_0.mlx.objs.get h).map DEC_clearGrow.kappa0.nobj)
kernel_rfl DEC_clearGrow.fok0 : DEC_clearGrow.clo0.all (objOK DEC_clearGrow.kappa0 DEC_clearGrow.P0.NL DEC_clearGrow.cx0_0.mlx) = true
kernel_rfl DEC_clearGrow.fnd0 : DEC_clearGrow.cln0.all (nodeOKF DEC_clearGrow.kappa0 DEC_clearGrow.P0 DEC_clearGrow.cx0_0.mlx DEC_clearGrow.cx1_0.mlx) = true
kernel_rfl DEC_clearGrow.fp0 : ((DEC_clearGrow.cln0.filter (fullB DEC_clearGrow.P0))).map (fun i => (DEC_clearGrow.cx1_0.mlx.nodes.get (DEC_clearGrow.kappa0.node i)).map Host.Mlx.Ffi.Node.prim) =
  ((DEC_clearGrow.cln0.filter (fullB DEC_clearGrow.P0))).map (fun i => (DEC_clearGrow.cx0_0.mlx.nodes.get i).map fun nd => DEC_clearGrow.kappa0.prim nd.prim)
kernel_rfl DEC_clearGrow.fnordI0 : incrB DEC_clearGrow.kd0.nodeF (List.range' 22539 0) = true
kernel_rfl DEC_clearGrow.fnordK0 : (PTrie.keysA DEC_clearGrow.kd0.node).all (fun k => Nat.ble 22539 k && Nat.blt k 22539) = true
kernel_rfl DEC_clearGrow.fnordL0 : (DEC_clearGrow.cln0.filter (Nat.ble DEC_clearGrow.P0.N0)).all (fun i => Nat.ble i (DEC_clearGrow.kd0.nodeF i) && (Nat.blt i 22539 || Nat.ble DEC_clearGrow.kd0.nn0 i)) = true
theorem DEC_clearGrow.fnord0 : (DEC_clearGrow.cln0.filter (Nat.ble DEC_clearGrow.P0.N0)).all (fun i => Nat.ble i (DEC_clearGrow.kd0.nodeF i) &&
    (PTrie.keysA DEC_clearGrow.kd0.node).all fun j => !Nat.blt j i || Nat.blt (DEC_clearGrow.kd0.nodeF j) (DEC_clearGrow.kd0.nodeF i)) = true :=
  cnord_of DEC_clearGrow.cnlow0 DEC_clearGrow.cnn10 DEC_clearGrow.fnordI0 DEC_clearGrow.fnordK0 DEC_clearGrow.fnordL0
kernel_rfl DEC_clearGrow.fi0 : DEC_clearGrow.cli0.all (pnB DEC_clearGrow.cx0_0.mlx) = true
kernel_rfl DEC_clearGrow.fii0 : DEC_clearGrow.cli0.all (fun k => decide (DEC_clearGrow.cx1_0.mlx.items.get (DEC_clearGrow.kappa0.node k) = (DEC_clearGrow.cx0_0.mlx.items.get k).map DEC_clearGrow.kappa0.nv)) = true
/-- **The compaction's footprint.** -/
theorem DEC_clearGrow.cfoot0 (clean : Conv.NClean (⟨29302, 22539, 3123568, 123⟩ : Conv.Cnt) (Host.Load.Layers.toLoad DEC_clearGrow.s0.ffi).mlx) (hltC : ∀ h, PH (Host.Load.Layers.toLoad DEC_clearGrow.s0.ffi).mlx h → h < (Host.Load.Layers.toLoad DEC_clearGrow.s0.ffi).mlx.next) (nltC : ∀ i, PN (Host.Load.Layers.toLoad DEC_clearGrow.s0.ffi).mlx i → i < (Host.Load.Layers.toLoad DEC_clearGrow.s0.ffi).mlx.nnext) (itemsC : ∀ k v, (Host.Load.Layers.toLoad DEC_clearGrow.s0.ffi).mlx.items.get k = some v → PN (Host.Load.Layers.toLoad DEC_clearGrow.s0.ffi).mlx k) (tracedC : ∀ h o, (Host.Load.Layers.toLoad DEC_clearGrow.s0.ffi).mlx.objs.get h = some o → ∀ i ∈ objTraces o, i < DEC_clearGrow.P0.NL) (cl : SSt (· < 123) DEC_clearGrow.cx0_0.mlx) :
    Conv.MFoot DEC_clearGrow.P0 123 DEC_clearGrow.kappa0 DEC_clearGrow.kd0 DEC_clearGrow.khinv0 DEC_clearGrow.kninv0 (Host.Load.Layers.toLoad DEC_clearGrow.s0.ffi).mlx DEC_clearGrow.cx0_0.mlx DEC_clearGrow.cx1_0.mlx (⟨29302, 22539, 3123568, 123⟩ : Conv.Cnt) DEC_clearGrow.clo0 DEC_clearGrow.cln0 DEC_clearGrow.cli0 DEC_clearGrow.cwS0 DEC_clearGrow.cnS0 DEC_clearGrow.ciS0 :=
  ⟨rfl, rfl, rfl, DEC_clearGrow.cnh00, DEC_clearGrow.cnh10, DEC_clearGrow.cnn00, DEC_clearGrow.cnn10, DEC_clearGrow.cplo0, DEC_clearGrow.ccnt0, DEC_clearGrow.cnband0, DEC_clearGrow.chbelow0, DEC_clearGrow.chren0, DEC_clearGrow.cband0, DEC_clearGrow.cnh1pos0, DEC_clearGrow.cnren0, DEC_clearGrow.cnlow0, DEC_clearGrow.cabs0a0, DEC_clearGrow.cabs0b0, DEC_clearGrow.ctok10, DEC_clearGrow.cpend0, DEC_clearGrow.cerrh0, DEC_clearGrow.cfiles0, DEC_clearGrow.carch0, DEC_clearGrow.csizes0, DEC_clearGrow.cwired0, DEC_clearGrow.cfix0, clean, DEC_clearGrow.fcxn0, DEC_clearGrow.fcnn0, hltC, nltC, itemsC, tracedC, cl, DEC_clearGrow.fle00, DEC_clearGrow.fnk0, DEC_clearGrow.ckA0, DEC_clearGrow.cobjsK0, DEC_clearGrow.cnodesK0, DEC_clearGrow.citemsK0, DEC_clearGrow.f1A0, DEC_clearGrow.f1O0, DEC_clearGrow.f1N0, DEC_clearGrow.f1I0, DEC_clearGrow.fbd0, DEC_clearGrow.fincW0, DEC_clearGrow.fincI0, DEC_clearGrow.fincN0, DEC_clearGrow.flnF0, DEC_clearGrow.fh0, DEC_clearGrow.fo0, DEC_clearGrow.fok0, DEC_clearGrow.fnd0, DEC_clearGrow.fp0, DEC_clearGrow.fnord0, DEC_clearGrow.fi0, DEC_clearGrow.fii0⟩
theorem DEC_clearGrow.cnshift0 (clean : Conv.NClean (⟨29302, 22539, 3123568, 123⟩ : Conv.Cnt) (Host.Load.Layers.toLoad DEC_clearGrow.s0.ffi).mlx) (hltC : ∀ h, PH (Host.Load.Layers.toLoad DEC_clearGrow.s0.ffi).mlx h → h < (Host.Load.Layers.toLoad DEC_clearGrow.s0.ffi).mlx.next) (nltC : ∀ i, PN (Host.Load.Layers.toLoad DEC_clearGrow.s0.ffi).mlx i → i < (Host.Load.Layers.toLoad DEC_clearGrow.s0.ffi).mlx.nnext) (itemsC : ∀ k v, (Host.Load.Layers.toLoad DEC_clearGrow.s0.ffi).mlx.items.get k = some v → PN (Host.Load.Layers.toLoad DEC_clearGrow.s0.ffi).mlx k) (tracedC : ∀ h o, (Host.Load.Layers.toLoad DEC_clearGrow.s0.ffi).mlx.objs.get h = some o → ∀ i ∈ objTraces o, i < DEC_clearGrow.P0.NL) (cl : SSt (· < 123) DEC_clearGrow.cx0_0.mlx) : NShift DEC_clearGrow.P0 123 DEC_clearGrow.kappa0 DEC_clearGrow.cx0_0 DEC_clearGrow.cx1_0 :=
  Conv.nshift_of_foot (DEC_clearGrow.cfoot0 clean hltC nltC itemsC tracedC cl) DEC_clearGrow.chost0 (compact_a_eq DEC_clearGrow.ckn00 DEC_clearGrow.ckn10 DEC_clearGrow.ckheap0 DEC_clearGrow.ckpl0)

-- the observers: the layers' states at the call, the canonical and the merged state, their footprints and checks
noncomputable def DEC_clearGrow.fxC_0 : PTrie Unit := (Host.Ts.Sim.Full.freedOf DEC_clearGrow.s0.ffi).getD PTrie.nil
noncomputable def DEC_clearGrow.krC_0 : Host.Load.Layers.KRec := (Host.Ts.Sim.Full.krecOf DEC_clearGrow.s0.ffi).getD Host.Load.Layers.KRec.empty
kernel_rfl DEC_clearGrow.ofxC_0 : (Host.Ts.Sim.Full.freedOf DEC_clearGrow.s0.ffi) = some DEC_clearGrow.fxC_0
kernel_rfl DEC_clearGrow.okrC_0 : (Host.Ts.Sim.Full.krecOf DEC_clearGrow.s0.ffi) = some DEC_clearGrow.krC_0
noncomputable def DEC_clearGrow.fx0_0 : PTrie Unit := (Host.Ts.Sim.Full.freedOf DEC_clearGrow.s2.ffi).getD PTrie.nil
noncomputable def DEC_clearGrow.kr0_0 : Host.Load.Layers.KRec := (Host.Ts.Sim.Full.krecOf DEC_clearGrow.s2.ffi).getD Host.Load.Layers.KRec.empty
kernel_rfl DEC_clearGrow.ofx0_0 : (Host.Ts.Sim.Full.freedOf DEC_clearGrow.s2.ffi) = some DEC_clearGrow.fx0_0
kernel_rfl DEC_clearGrow.okr0_0 : (Host.Ts.Sim.Full.krecOf DEC_clearGrow.s2.ffi) = some DEC_clearGrow.kr0_0
noncomputable def DEC_clearGrow.fx1_0 : PTrie Unit := (Host.Ts.Sim.Full.freedOf DEC_clearGrow.s1.ffi).getD PTrie.nil
noncomputable def DEC_clearGrow.kr1_0 : Host.Load.Layers.KRec := (Host.Ts.Sim.Full.krecOf DEC_clearGrow.s1.ffi).getD Host.Load.Layers.KRec.empty
kernel_rfl DEC_clearGrow.ofx1_0 : (Host.Ts.Sim.Full.freedOf DEC_clearGrow.s1.ffi) = some DEC_clearGrow.fx1_0
kernel_rfl DEC_clearGrow.okr1_0 : (Host.Ts.Sim.Full.krecOf DEC_clearGrow.s1.ffi) = some DEC_clearGrow.kr1_0
kernel_rfl DEC_clearGrow.ff00 : DEC_clearGrow.fx0_0 = Stage.setAll DEC_clearGrow.fxC_0 (DEC_clearGrow.clo0.filterMap fun i => (DEC_clearGrow.fx0_0.get i).map (i, ·))
kernel_rfl DEC_clearGrow.ff10 : DEC_clearGrow.fx1_0 = Stage.setAll DEC_clearGrow.fxC_0 (DEC_clearGrow.cwS0.filterMap fun i => (DEC_clearGrow.fx1_0.get i).map (i, ·))
kernel_rfl DEC_clearGrow.ffck0 : freedLB DEC_clearGrow.kappa0 DEC_clearGrow.cx0_0.mlx DEC_clearGrow.fx0_0 DEC_clearGrow.fx1_0 DEC_clearGrow.clo0 = true
kernel_rfl DEC_clearGrow.fkf00 : DEC_clearGrow.kr0_0.flags = Stage.setAll DEC_clearGrow.krC_0.flags (DEC_clearGrow.clo0.filterMap fun i => (DEC_clearGrow.kr0_0.flags.get i).map (i, ·))
kernel_rfl DEC_clearGrow.fkt00 : DEC_clearGrow.kr0_0.targs = Stage.setAll DEC_clearGrow.krC_0.targs (DEC_clearGrow.clo0.filterMap fun i => (DEC_clearGrow.kr0_0.targs.get i).map (i, ·))
kernel_rfl DEC_clearGrow.fkf10 : DEC_clearGrow.kr1_0.flags = Stage.setAll DEC_clearGrow.krC_0.flags (DEC_clearGrow.cwS0.filterMap fun i => (DEC_clearGrow.kr1_0.flags.get i).map (i, ·))
kernel_rfl DEC_clearGrow.fkt10 : DEC_clearGrow.kr1_0.targs = Stage.setAll DEC_clearGrow.krC_0.targs (DEC_clearGrow.cwS0.filterMap fun i => (DEC_clearGrow.kr1_0.targs.get i).map (i, ·))
kernel_rfl DEC_clearGrow.fkck0 : krecLB DEC_clearGrow.kappa0 123 DEC_clearGrow.cx0_0.mlx DEC_clearGrow.kr0_0 DEC_clearGrow.kr1_0 DEC_clearGrow.clo0 = true
kernel_rfl DEC_clearGrow.fkn0 : Nat.ble 123 123 = true
-- the bridge and the pending traces' regions
kernel_rfl DEC_clearGrow.cbridge0 : Host.Ts.Sim.Full.bridgeOf DEC_clearGrow.s1.ffi = Host.Ts.Sim.Full.bridgeOf DEC_clearGrow.s2.ffi
kernel_rfl DEC_clearGrow.cpendR0 : pendRegB DEC_clearGrow.kappa0 (Host.Load.Layers.toLoad DEC_clearGrow.s2.ffi).mlx = true
kernel_rfl DEC_clearGrow.cpendLe0 : Nat.ble (Host.Load.Layers.toLoad DEC_clearGrow.s2.ffi).mlx.next (Host.Load.Layers.toLoad DEC_clearGrow.s1.ffi).mlx.next = true
/-- **The compaction's native shift**, given the call's bookkeeping, its relation's facts (the model's and the
observers') and the canonical closedness. -/
theorem DEC_clearGrow.cshift0 (clean : Conv.NClean (⟨29302, 22539, 3123568, 123⟩ : Conv.Cnt) (Host.Load.Layers.toLoad DEC_clearGrow.s0.ffi).mlx) (hltC : ∀ h, PH (Host.Load.Layers.toLoad DEC_clearGrow.s0.ffi).mlx h → h < (Host.Load.Layers.toLoad DEC_clearGrow.s0.ffi).mlx.next) (nltC : ∀ i, PN (Host.Load.Layers.toLoad DEC_clearGrow.s0.ffi).mlx i → i < (Host.Load.Layers.toLoad DEC_clearGrow.s0.ffi).mlx.nnext) (itemsC : ∀ k v, (Host.Load.Layers.toLoad DEC_clearGrow.s0.ffi).mlx.items.get k = some v → PN (Host.Load.Layers.toLoad DEC_clearGrow.s0.ffi).mlx k) (tracedC : ∀ h o, (Host.Load.Layers.toLoad DEC_clearGrow.s0.ffi).mlx.objs.get h = some o → ∀ i ∈ objTraces o, i < DEC_clearGrow.P0.NL) (cl : SSt (· < 123) DEC_clearGrow.cx0_0.mlx)
    (hobjC : ∀ h, DEC_clearGrow.fxC_0.get h = some () → ((Host.Load.Layers.toLoad DEC_clearGrow.s0.ffi).mlx.objs.get h).isSome = true)
    (hfC : ∀ h, (DEC_clearGrow.krC_0.flags.get h).isSome = true → ((Host.Load.Layers.toLoad DEC_clearGrow.s0.ffi).mlx.objs.get h).isSome = true)
    (htC : ∀ h, (DEC_clearGrow.krC_0.targs.get h).isSome = true → ((Host.Load.Layers.toLoad DEC_clearGrow.s0.ffi).mlx.objs.get h).isSome = true)
    (hclC : ∀ h l, DEC_clearGrow.krC_0.targs.get h = some l → Host.Ts.Sim.Full.STargs (· < (⟨29302, 22539, 3123568, 123⟩ : Conv.Cnt).n) l) :
    Conv.FullShiftQ DEC_clearGrow.P0 123 DEC_clearGrow.kappa0 DEC_clearGrow.s2.ffi DEC_clearGrow.s1.ffi :=
  ⟨DEC_clearGrow.cnshift0 clean hltC nltC itemsC tracedC cl, DEC_clearGrow.cqueue0, fun t ht => bSN_sound (List.all_eq_true.mp DEC_clearGrow.ctokSupp0 t ht),
    DEC_clearGrow.cbridge0,
    liveShift_foot (x0' := Host.Ts.Sim.Full.mlxOf DEC_clearGrow.s2.ffi) (x1' := Host.Ts.Sim.Full.mlxOf DEC_clearGrow.s1.ffi) (DEC_clearGrow.cfoot0 clean hltC nltC itemsC tracedC cl) rfl DEC_clearGrow.ofx0_0 DEC_clearGrow.ofx1_0 hobjC DEC_clearGrow.ff00 DEC_clearGrow.ff10 DEC_clearGrow.ffck0,
    kernShift_foot (x0' := Host.Ts.Sim.Full.mlxOf DEC_clearGrow.s2.ffi) (x1' := Host.Ts.Sim.Full.mlxOf DEC_clearGrow.s1.ffi) (DEC_clearGrow.cfoot0 clean hltC nltC itemsC tracedC cl) rfl DEC_clearGrow.okr0_0 DEC_clearGrow.okr1_0 (Nat.le_of_ble_eq_true DEC_clearGrow.fkn0) hfC htC hclC
      DEC_clearGrow.fkf00 DEC_clearGrow.fkt00 DEC_clearGrow.fkf10 DEC_clearGrow.fkt10 DEC_clearGrow.fkck0,
    pendReg_of rfl DEC_clearGrow.cnh00 DEC_clearGrow.cnh10 (Nat.le_of_ble_eq_true DEC_clearGrow.cpendLe0) DEC_clearGrow.cpendR0⟩

end Host.Load.Run.Tpl
