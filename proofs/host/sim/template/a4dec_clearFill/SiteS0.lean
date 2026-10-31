import host.sim.template.a4dec_clearFill.SiteCl0
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
def DEC_clearFill.P0 : LoadP := ⟨25000, 131072, 1099511627776, 20000, 22539, []⟩
noncomputable abbrev DEC_clearFill.cx0_0 : Host.Load.LSt := clearTokens (Host.Load.Layers.toLoad DEC_clearFill.s2.ffi)
noncomputable abbrev DEC_clearFill.cx1_0 : Host.Load.LSt := clearTokens (Host.Load.Layers.toLoad DEC_clearFill.s1.ffi)
def DEC_clearFill.khinv0 : PTrie Nat := Stage.setAll PTrie.nil []
def DEC_clearFill.kninv0 : PTrie Nat := Stage.setAll PTrie.nil []
/-- The stage's footprint: its written and fresh handles, fresh nodes, written and fresh items. -/
def DEC_clearFill.cwS0 : List Nat := []
def DEC_clearFill.cnS0 : List Nat := List.range' 22539 0
def DEC_clearFill.ciS0 : List Nat := [20157] ++ List.range' 22539 0

-- the small checks (`MChecks`'s)
kernel_rfl DEC_clearFill.cnh00 : DEC_clearFill.kd0.nh0 = DEC_clearFill.cx0_0.mlx.next
kernel_rfl DEC_clearFill.cnh10 : DEC_clearFill.kd0.nh1 = DEC_clearFill.cx1_0.mlx.next
kernel_rfl DEC_clearFill.cnn00 : DEC_clearFill.kd0.nn0 = DEC_clearFill.cx0_0.mlx.nnext
kernel_rfl DEC_clearFill.cnn10 : DEC_clearFill.kd0.nn1 = DEC_clearFill.cx1_0.mlx.nnext
kernel_rfl DEC_clearFill.cplo0 : (Nat.blt 0 DEC_clearFill.P0.lo && Nat.ble DEC_clearFill.P0.lo DEC_clearFill.cx0_0.mlx.next && Nat.ble DEC_clearFill.P0.lo RData.bigHi && Nat.ble RData.bigHi DEC_clearFill.P0.E) = true
kernel_rfl DEC_clearFill.ccnt0 : (Nat.ble DEC_clearFill.cx0_0.mlx.next DEC_clearFill.cx1_0.mlx.next && Nat.ble DEC_clearFill.cx0_0.mlx.nnext DEC_clearFill.cx1_0.mlx.nnext) = true
kernel_rfl DEC_clearFill.cnband0 : (Nat.blt 0 DEC_clearFill.P0.NL && Nat.ble DEC_clearFill.P0.NL DEC_clearFill.P0.N0 && Nat.ble DEC_clearFill.P0.N0 DEC_clearFill.cx0_0.mlx.nnext) = true
kernel_rfl DEC_clearFill.chbelow0 : DEC_clearFill.kd0.checkHndBelow = true
kernel_rfl DEC_clearFill.chren0 : checkRenG DEC_clearFill.kd0.hnd DEC_clearFill.khinv0 (phB DEC_clearFill.cx0_0.mlx) = true
kernel_rfl DEC_clearFill.cband0 : DEC_clearFill.kd0.checkBand DEC_clearFill.P0.lo = true
kernel_rfl DEC_clearFill.cnh1pos0 : Nat.blt 0 DEC_clearFill.kd0.nh1 = true
kernel_rfl DEC_clearFill.cnren0 : checkRenG DEC_clearFill.kd0.node DEC_clearFill.kninv0 (pnB DEC_clearFill.cx0_0.mlx) = true
kernel_rfl DEC_clearFill.cnlow0 : (PTrie.keysA DEC_clearFill.kd0.node).all (fun j => Nat.ble DEC_clearFill.P0.NL j && Nat.blt (DEC_clearFill.kd0.nodeF j) DEC_clearFill.cx1_0.mlx.nnext) = true
kernel_rfl DEC_clearFill.cabs0a0 : DEC_clearFill.cx0_0.mlx.arrs.get 0 = none
kernel_rfl DEC_clearFill.cabs0b0 : DEC_clearFill.cx0_0.mlx.objs.get 0 = none
kernel_rfl DEC_clearFill.ctok10 : DEC_clearFill.cx1_0.mlx.tokens = []
kernel_rfl DEC_clearFill.cpend0 : DEC_clearFill.cx1_0.mlx.pending = DEC_clearFill.cx0_0.mlx.pending.map DEC_clearFill.kappa0.pend
kernel_rfl DEC_clearFill.cerrh0 : DEC_clearFill.cx1_0.mlx.errh = DEC_clearFill.cx0_0.mlx.errh.map DEC_clearFill.kappa0.arg
kernel_rfl DEC_clearFill.cfiles0 : DEC_clearFill.cx1_0.mlx.files = DEC_clearFill.cx0_0.mlx.files
kernel_rfl DEC_clearFill.carch0 : DEC_clearFill.cx1_0.mlx.arch = DEC_clearFill.cx0_0.mlx.arch
kernel_rfl DEC_clearFill.csizes0 : DEC_clearFill.cx1_0.mlx.deviceSizes = DEC_clearFill.cx0_0.mlx.deviceSizes
kernel_rfl DEC_clearFill.cwired0 : DEC_clearFill.cx1_0.mlx.wired = DEC_clearFill.cx0_0.mlx.wired
kernel_rfl DEC_clearFill.chost0 : DEC_clearFill.cx1_0.host = DEC_clearFill.cx0_0.host
-- the compaction map's addresses are `DEC_clearFill.kd0`'s
kernel_rfl DEC_clearFill.ckn00 : DEC_clearFill.kd0.n0 = 3123568
kernel_rfl DEC_clearFill.ckn10 : DEC_clearFill.kd0.n1 = 3123580
kernel_rfl DEC_clearFill.ckheap0 : (PTrie.keysA DEC_clearFill.kd0.heap).all (fun x => Nat.ble 3123568 x) = true
kernel_rfl DEC_clearFill.ckpl0 : (List.range 0).all (fun j => decide (DEC_clearFill.kd0.heap.get (3123568 + j) = nth? DEC_clearFill.pl0 j)) = true
-- the map fixes the call's names (`Conv.fixOld_compact`), the call's counters
kernel_rfl DEC_clearFill.fja0 : Nat.ble 3123568 3123568 = true
kernel_rfl DEC_clearFill.fn0 : Nat.ble 123 123 = true
kernel_rfl DEC_clearFill.fjaD0 : Nat.ble 3123568 DEC_clearFill.kd0.n0 = true
kernel_rfl DEC_clearFill.fxn0 : Nat.ble 29302 DEC_clearFill.kd0.nh0 = true
kernel_rfl DEC_clearFill.fnn0 : Nat.ble 22539 DEC_clearFill.kd0.nn0 = true
kernel_rfl DEC_clearFill.fxb0 : Nat.ble 29302 RData.bigHi = true
kernel_rfl DEC_clearFill.fheap0 : (PTrie.keysA DEC_clearFill.kd0.heap).all (Nat.ble (⟨29302, 22539, 3123568, 123⟩ : Conv.Cnt).ja) = true
kernel_rfl DEC_clearFill.fhnd0 : (PTrie.keysA DEC_clearFill.kd0.hnd).all (Nat.ble (⟨29302, 22539, 3123568, 123⟩ : Conv.Cnt).xn) = true
kernel_rfl DEC_clearFill.fnode0 : (PTrie.keysA DEC_clearFill.kd0.node).all (Nat.ble (⟨29302, 22539, 3123568, 123⟩ : Conv.Cnt).nn) = true
/-- The compaction map fixes the call's names. -/
theorem DEC_clearFill.cfix0 : Conv.FixOld (⟨29302, 22539, 3123568, 123⟩ : Conv.Cnt) DEC_clearFill.kappa0 :=
  Conv.fixOld_compact (Nat.le_of_ble_eq_true DEC_clearFill.fja0) (Nat.le_of_ble_eq_true DEC_clearFill.fn0) (Nat.le_of_ble_eq_true DEC_clearFill.fjaD0) (Nat.le_of_ble_eq_true DEC_clearFill.fxn0) (Nat.le_of_ble_eq_true DEC_clearFill.fnn0) (Nat.le_of_ble_eq_true DEC_clearFill.fxb0) DEC_clearFill.fheap0 DEC_clearFill.fhnd0 DEC_clearFill.fnode0
kernel_rfl DEC_clearFill.fcxn0 : (⟨29302, 22539, 3123568, 123⟩ : Conv.Cnt).xn = (Host.Load.Layers.toLoad DEC_clearFill.s0.ffi).mlx.next
kernel_rfl DEC_clearFill.fcnn0 : (⟨29302, 22539, 3123568, 123⟩ : Conv.Cnt).nn = (Host.Load.Layers.toLoad DEC_clearFill.s0.ffi).mlx.nnext
kernel_rfl DEC_clearFill.fle00 : (Nat.ble (Host.Load.Layers.toLoad DEC_clearFill.s0.ffi).mlx.next DEC_clearFill.cx0_0.mlx.next && Nat.ble (Host.Load.Layers.toLoad DEC_clearFill.s0.ffi).mlx.nnext DEC_clearFill.cx0_0.mlx.nnext && Nat.ble (Host.Load.Layers.toLoad DEC_clearFill.s0.ffi).mlx.next RData.bigHi) = true
kernel_rfl DEC_clearFill.fnk0 : (PTrie.keysA DEC_clearFill.kd0.node).all (Nat.ble (Host.Load.Layers.toLoad DEC_clearFill.s0.ffi).mlx.nnext) = true
-- the merged state keeps the call's entries off the stage's footprint
kernel_rfl DEC_clearFill.f1A0 : DEC_clearFill.cx1_0.mlx.arrs = Stage.setAll (Host.Load.Layers.toLoad DEC_clearFill.s0.ffi).mlx.arrs (DEC_clearFill.cwS0.filterMap fun i => (DEC_clearFill.cx1_0.mlx.arrs.get i).map (i, ·))
kernel_rfl DEC_clearFill.f1O0 : DEC_clearFill.cx1_0.mlx.objs = Stage.setAll (Host.Load.Layers.toLoad DEC_clearFill.s0.ffi).mlx.objs (DEC_clearFill.cwS0.filterMap fun i => (DEC_clearFill.cx1_0.mlx.objs.get i).map (i, ·))
kernel_rfl DEC_clearFill.f1N0 : DEC_clearFill.cx1_0.mlx.nodes = Stage.setAll (Host.Load.Layers.toLoad DEC_clearFill.s0.ffi).mlx.nodes (DEC_clearFill.cnS0.filterMap fun i => (DEC_clearFill.cx1_0.mlx.nodes.get i).map (i, ·))
kernel_rfl DEC_clearFill.f1I0 : DEC_clearFill.cx1_0.mlx.items = Stage.setAll (Host.Load.Layers.toLoad DEC_clearFill.s0.ffi).mlx.items (DEC_clearFill.ciS0.filterMap fun i => (DEC_clearFill.cx1_0.mlx.items.get i).map (i, ·))
kernel_rfl DEC_clearFill.fbd0 : (DEC_clearFill.clo0 ++ DEC_clearFill.cln0 ++ DEC_clearFill.cli0 ++ DEC_clearFill.cwS0 ++ DEC_clearFill.cnS0 ++ DEC_clearFill.ciS0).all (fun i => Nat.blt (i / 4096) (4 ^ 31)) = true
kernel_rfl DEC_clearFill.fincW0 : DEC_clearFill.cwS0.all (fun h => !Nat.blt h (Host.Load.Layers.toLoad DEC_clearFill.s0.ffi).mlx.next || DEC_clearFill.clo0.contains h) = true
kernel_rfl DEC_clearFill.fincI0 : DEC_clearFill.ciS0.all (fun k => !Nat.blt k (Host.Load.Layers.toLoad DEC_clearFill.s0.ffi).mlx.nnext || DEC_clearFill.cli0.contains k) = true
kernel_rfl DEC_clearFill.fincN0 : DEC_clearFill.cnS0.all (Nat.ble (Host.Load.Layers.toLoad DEC_clearFill.s0.ffi).mlx.nnext) = true
kernel_rfl DEC_clearFill.flnF0 : DEC_clearFill.cln0.all (Nat.ble (Host.Load.Layers.toLoad DEC_clearFill.s0.ffi).mlx.nnext) = true
-- the checks over the changed lists
kernel_rfl DEC_clearFill.fh0 : DEC_clearFill.clo0.all (handleOK DEC_clearFill.kappa0 DEC_clearFill.P0.lo DEC_clearFill.cx0_0.mlx DEC_clearFill.cx1_0.mlx) = true
kernel_rfl DEC_clearFill.fo0 : DEC_clearFill.clo0.map (fun h => DEC_clearFill.cx1_0.mlx.objs.get (DEC_clearFill.kappa0.handle h)) = DEC_clearFill.clo0.map (fun h => (DEC_clearFill.cx0_0.mlx.objs.get h).map DEC_clearFill.kappa0.nobj)
kernel_rfl DEC_clearFill.fok0 : DEC_clearFill.clo0.all (objOK DEC_clearFill.kappa0 DEC_clearFill.P0.NL DEC_clearFill.cx0_0.mlx) = true
kernel_rfl DEC_clearFill.fnd0 : DEC_clearFill.cln0.all (nodeOKF DEC_clearFill.kappa0 DEC_clearFill.P0 DEC_clearFill.cx0_0.mlx DEC_clearFill.cx1_0.mlx) = true
kernel_rfl DEC_clearFill.fp0 : ((DEC_clearFill.cln0.filter (fullB DEC_clearFill.P0))).map (fun i => (DEC_clearFill.cx1_0.mlx.nodes.get (DEC_clearFill.kappa0.node i)).map Host.Mlx.Ffi.Node.prim) =
  ((DEC_clearFill.cln0.filter (fullB DEC_clearFill.P0))).map (fun i => (DEC_clearFill.cx0_0.mlx.nodes.get i).map fun nd => DEC_clearFill.kappa0.prim nd.prim)
kernel_rfl DEC_clearFill.fnordI0 : incrB DEC_clearFill.kd0.nodeF (List.range' 22539 0) = true
kernel_rfl DEC_clearFill.fnordK0 : (PTrie.keysA DEC_clearFill.kd0.node).all (fun k => Nat.ble 22539 k && Nat.blt k 22539) = true
kernel_rfl DEC_clearFill.fnordL0 : (DEC_clearFill.cln0.filter (Nat.ble DEC_clearFill.P0.N0)).all (fun i => Nat.ble i (DEC_clearFill.kd0.nodeF i) && (Nat.blt i 22539 || Nat.ble DEC_clearFill.kd0.nn0 i)) = true
theorem DEC_clearFill.fnord0 : (DEC_clearFill.cln0.filter (Nat.ble DEC_clearFill.P0.N0)).all (fun i => Nat.ble i (DEC_clearFill.kd0.nodeF i) &&
    (PTrie.keysA DEC_clearFill.kd0.node).all fun j => !Nat.blt j i || Nat.blt (DEC_clearFill.kd0.nodeF j) (DEC_clearFill.kd0.nodeF i)) = true :=
  cnord_of DEC_clearFill.cnlow0 DEC_clearFill.cnn10 DEC_clearFill.fnordI0 DEC_clearFill.fnordK0 DEC_clearFill.fnordL0
kernel_rfl DEC_clearFill.fi0 : DEC_clearFill.cli0.all (pnB DEC_clearFill.cx0_0.mlx) = true
kernel_rfl DEC_clearFill.fii0 : DEC_clearFill.cli0.all (fun k => decide (DEC_clearFill.cx1_0.mlx.items.get (DEC_clearFill.kappa0.node k) = (DEC_clearFill.cx0_0.mlx.items.get k).map DEC_clearFill.kappa0.nv)) = true
/-- **The compaction's footprint.** -/
theorem DEC_clearFill.cfoot0 (clean : Conv.NClean (⟨29302, 22539, 3123568, 123⟩ : Conv.Cnt) (Host.Load.Layers.toLoad DEC_clearFill.s0.ffi).mlx) (hltC : ∀ h, PH (Host.Load.Layers.toLoad DEC_clearFill.s0.ffi).mlx h → h < (Host.Load.Layers.toLoad DEC_clearFill.s0.ffi).mlx.next) (nltC : ∀ i, PN (Host.Load.Layers.toLoad DEC_clearFill.s0.ffi).mlx i → i < (Host.Load.Layers.toLoad DEC_clearFill.s0.ffi).mlx.nnext) (itemsC : ∀ k v, (Host.Load.Layers.toLoad DEC_clearFill.s0.ffi).mlx.items.get k = some v → PN (Host.Load.Layers.toLoad DEC_clearFill.s0.ffi).mlx k) (tracedC : ∀ h o, (Host.Load.Layers.toLoad DEC_clearFill.s0.ffi).mlx.objs.get h = some o → ∀ i ∈ objTraces o, i < DEC_clearFill.P0.NL) (cl : SSt (· < 123) DEC_clearFill.cx0_0.mlx) :
    Conv.MFoot DEC_clearFill.P0 123 DEC_clearFill.kappa0 DEC_clearFill.kd0 DEC_clearFill.khinv0 DEC_clearFill.kninv0 (Host.Load.Layers.toLoad DEC_clearFill.s0.ffi).mlx DEC_clearFill.cx0_0.mlx DEC_clearFill.cx1_0.mlx (⟨29302, 22539, 3123568, 123⟩ : Conv.Cnt) DEC_clearFill.clo0 DEC_clearFill.cln0 DEC_clearFill.cli0 DEC_clearFill.cwS0 DEC_clearFill.cnS0 DEC_clearFill.ciS0 :=
  ⟨rfl, rfl, rfl, DEC_clearFill.cnh00, DEC_clearFill.cnh10, DEC_clearFill.cnn00, DEC_clearFill.cnn10, DEC_clearFill.cplo0, DEC_clearFill.ccnt0, DEC_clearFill.cnband0, DEC_clearFill.chbelow0, DEC_clearFill.chren0, DEC_clearFill.cband0, DEC_clearFill.cnh1pos0, DEC_clearFill.cnren0, DEC_clearFill.cnlow0, DEC_clearFill.cabs0a0, DEC_clearFill.cabs0b0, DEC_clearFill.ctok10, DEC_clearFill.cpend0, DEC_clearFill.cerrh0, DEC_clearFill.cfiles0, DEC_clearFill.carch0, DEC_clearFill.csizes0, DEC_clearFill.cwired0, DEC_clearFill.cfix0, clean, DEC_clearFill.fcxn0, DEC_clearFill.fcnn0, hltC, nltC, itemsC, tracedC, cl, DEC_clearFill.fle00, DEC_clearFill.fnk0, DEC_clearFill.ckA0, DEC_clearFill.cobjsK0, DEC_clearFill.cnodesK0, DEC_clearFill.citemsK0, DEC_clearFill.f1A0, DEC_clearFill.f1O0, DEC_clearFill.f1N0, DEC_clearFill.f1I0, DEC_clearFill.fbd0, DEC_clearFill.fincW0, DEC_clearFill.fincI0, DEC_clearFill.fincN0, DEC_clearFill.flnF0, DEC_clearFill.fh0, DEC_clearFill.fo0, DEC_clearFill.fok0, DEC_clearFill.fnd0, DEC_clearFill.fp0, DEC_clearFill.fnord0, DEC_clearFill.fi0, DEC_clearFill.fii0⟩
theorem DEC_clearFill.cnshift0 (clean : Conv.NClean (⟨29302, 22539, 3123568, 123⟩ : Conv.Cnt) (Host.Load.Layers.toLoad DEC_clearFill.s0.ffi).mlx) (hltC : ∀ h, PH (Host.Load.Layers.toLoad DEC_clearFill.s0.ffi).mlx h → h < (Host.Load.Layers.toLoad DEC_clearFill.s0.ffi).mlx.next) (nltC : ∀ i, PN (Host.Load.Layers.toLoad DEC_clearFill.s0.ffi).mlx i → i < (Host.Load.Layers.toLoad DEC_clearFill.s0.ffi).mlx.nnext) (itemsC : ∀ k v, (Host.Load.Layers.toLoad DEC_clearFill.s0.ffi).mlx.items.get k = some v → PN (Host.Load.Layers.toLoad DEC_clearFill.s0.ffi).mlx k) (tracedC : ∀ h o, (Host.Load.Layers.toLoad DEC_clearFill.s0.ffi).mlx.objs.get h = some o → ∀ i ∈ objTraces o, i < DEC_clearFill.P0.NL) (cl : SSt (· < 123) DEC_clearFill.cx0_0.mlx) : NShift DEC_clearFill.P0 123 DEC_clearFill.kappa0 DEC_clearFill.cx0_0 DEC_clearFill.cx1_0 :=
  Conv.nshift_of_foot (DEC_clearFill.cfoot0 clean hltC nltC itemsC tracedC cl) DEC_clearFill.chost0 (compact_a_eq DEC_clearFill.ckn00 DEC_clearFill.ckn10 DEC_clearFill.ckheap0 DEC_clearFill.ckpl0)

-- the observers: the layers' states at the call, the canonical and the merged state, their footprints and checks
noncomputable def DEC_clearFill.fxC_0 : PTrie Unit := (Host.Ts.Sim.Full.freedOf DEC_clearFill.s0.ffi).getD PTrie.nil
noncomputable def DEC_clearFill.krC_0 : Host.Load.Layers.KRec := (Host.Ts.Sim.Full.krecOf DEC_clearFill.s0.ffi).getD Host.Load.Layers.KRec.empty
kernel_rfl DEC_clearFill.ofxC_0 : (Host.Ts.Sim.Full.freedOf DEC_clearFill.s0.ffi) = some DEC_clearFill.fxC_0
kernel_rfl DEC_clearFill.okrC_0 : (Host.Ts.Sim.Full.krecOf DEC_clearFill.s0.ffi) = some DEC_clearFill.krC_0
noncomputable def DEC_clearFill.fx0_0 : PTrie Unit := (Host.Ts.Sim.Full.freedOf DEC_clearFill.s2.ffi).getD PTrie.nil
noncomputable def DEC_clearFill.kr0_0 : Host.Load.Layers.KRec := (Host.Ts.Sim.Full.krecOf DEC_clearFill.s2.ffi).getD Host.Load.Layers.KRec.empty
kernel_rfl DEC_clearFill.ofx0_0 : (Host.Ts.Sim.Full.freedOf DEC_clearFill.s2.ffi) = some DEC_clearFill.fx0_0
kernel_rfl DEC_clearFill.okr0_0 : (Host.Ts.Sim.Full.krecOf DEC_clearFill.s2.ffi) = some DEC_clearFill.kr0_0
noncomputable def DEC_clearFill.fx1_0 : PTrie Unit := (Host.Ts.Sim.Full.freedOf DEC_clearFill.s1.ffi).getD PTrie.nil
noncomputable def DEC_clearFill.kr1_0 : Host.Load.Layers.KRec := (Host.Ts.Sim.Full.krecOf DEC_clearFill.s1.ffi).getD Host.Load.Layers.KRec.empty
kernel_rfl DEC_clearFill.ofx1_0 : (Host.Ts.Sim.Full.freedOf DEC_clearFill.s1.ffi) = some DEC_clearFill.fx1_0
kernel_rfl DEC_clearFill.okr1_0 : (Host.Ts.Sim.Full.krecOf DEC_clearFill.s1.ffi) = some DEC_clearFill.kr1_0
kernel_rfl DEC_clearFill.ff00 : DEC_clearFill.fx0_0 = Stage.setAll DEC_clearFill.fxC_0 (DEC_clearFill.clo0.filterMap fun i => (DEC_clearFill.fx0_0.get i).map (i, ·))
kernel_rfl DEC_clearFill.ff10 : DEC_clearFill.fx1_0 = Stage.setAll DEC_clearFill.fxC_0 (DEC_clearFill.cwS0.filterMap fun i => (DEC_clearFill.fx1_0.get i).map (i, ·))
kernel_rfl DEC_clearFill.ffck0 : freedLB DEC_clearFill.kappa0 DEC_clearFill.cx0_0.mlx DEC_clearFill.fx0_0 DEC_clearFill.fx1_0 DEC_clearFill.clo0 = true
kernel_rfl DEC_clearFill.fkf00 : DEC_clearFill.kr0_0.flags = Stage.setAll DEC_clearFill.krC_0.flags (DEC_clearFill.clo0.filterMap fun i => (DEC_clearFill.kr0_0.flags.get i).map (i, ·))
kernel_rfl DEC_clearFill.fkt00 : DEC_clearFill.kr0_0.targs = Stage.setAll DEC_clearFill.krC_0.targs (DEC_clearFill.clo0.filterMap fun i => (DEC_clearFill.kr0_0.targs.get i).map (i, ·))
kernel_rfl DEC_clearFill.fkf10 : DEC_clearFill.kr1_0.flags = Stage.setAll DEC_clearFill.krC_0.flags (DEC_clearFill.cwS0.filterMap fun i => (DEC_clearFill.kr1_0.flags.get i).map (i, ·))
kernel_rfl DEC_clearFill.fkt10 : DEC_clearFill.kr1_0.targs = Stage.setAll DEC_clearFill.krC_0.targs (DEC_clearFill.cwS0.filterMap fun i => (DEC_clearFill.kr1_0.targs.get i).map (i, ·))
kernel_rfl DEC_clearFill.fkck0 : krecLB DEC_clearFill.kappa0 123 DEC_clearFill.cx0_0.mlx DEC_clearFill.kr0_0 DEC_clearFill.kr1_0 DEC_clearFill.clo0 = true
kernel_rfl DEC_clearFill.fkn0 : Nat.ble 123 123 = true
-- the bridge and the pending traces' regions
kernel_rfl DEC_clearFill.cbridge0 : Host.Ts.Sim.Full.bridgeOf DEC_clearFill.s1.ffi = Host.Ts.Sim.Full.bridgeOf DEC_clearFill.s2.ffi
kernel_rfl DEC_clearFill.cpendR0 : pendRegB DEC_clearFill.kappa0 (Host.Load.Layers.toLoad DEC_clearFill.s2.ffi).mlx = true
kernel_rfl DEC_clearFill.cpendLe0 : Nat.ble (Host.Load.Layers.toLoad DEC_clearFill.s2.ffi).mlx.next (Host.Load.Layers.toLoad DEC_clearFill.s1.ffi).mlx.next = true
/-- **The compaction's native shift**, given the call's bookkeeping, its relation's facts (the model's and the
observers') and the canonical closedness. -/
theorem DEC_clearFill.cshift0 (clean : Conv.NClean (⟨29302, 22539, 3123568, 123⟩ : Conv.Cnt) (Host.Load.Layers.toLoad DEC_clearFill.s0.ffi).mlx) (hltC : ∀ h, PH (Host.Load.Layers.toLoad DEC_clearFill.s0.ffi).mlx h → h < (Host.Load.Layers.toLoad DEC_clearFill.s0.ffi).mlx.next) (nltC : ∀ i, PN (Host.Load.Layers.toLoad DEC_clearFill.s0.ffi).mlx i → i < (Host.Load.Layers.toLoad DEC_clearFill.s0.ffi).mlx.nnext) (itemsC : ∀ k v, (Host.Load.Layers.toLoad DEC_clearFill.s0.ffi).mlx.items.get k = some v → PN (Host.Load.Layers.toLoad DEC_clearFill.s0.ffi).mlx k) (tracedC : ∀ h o, (Host.Load.Layers.toLoad DEC_clearFill.s0.ffi).mlx.objs.get h = some o → ∀ i ∈ objTraces o, i < DEC_clearFill.P0.NL) (cl : SSt (· < 123) DEC_clearFill.cx0_0.mlx)
    (hobjC : ∀ h, DEC_clearFill.fxC_0.get h = some () → ((Host.Load.Layers.toLoad DEC_clearFill.s0.ffi).mlx.objs.get h).isSome = true)
    (hfC : ∀ h, (DEC_clearFill.krC_0.flags.get h).isSome = true → ((Host.Load.Layers.toLoad DEC_clearFill.s0.ffi).mlx.objs.get h).isSome = true)
    (htC : ∀ h, (DEC_clearFill.krC_0.targs.get h).isSome = true → ((Host.Load.Layers.toLoad DEC_clearFill.s0.ffi).mlx.objs.get h).isSome = true)
    (hclC : ∀ h l, DEC_clearFill.krC_0.targs.get h = some l → Host.Ts.Sim.Full.STargs (· < (⟨29302, 22539, 3123568, 123⟩ : Conv.Cnt).n) l) :
    Conv.FullShiftQ DEC_clearFill.P0 123 DEC_clearFill.kappa0 DEC_clearFill.s2.ffi DEC_clearFill.s1.ffi :=
  ⟨DEC_clearFill.cnshift0 clean hltC nltC itemsC tracedC cl, DEC_clearFill.cqueue0, fun t ht => bSN_sound (List.all_eq_true.mp DEC_clearFill.ctokSupp0 t ht),
    DEC_clearFill.cbridge0,
    liveShift_foot (x0' := Host.Ts.Sim.Full.mlxOf DEC_clearFill.s2.ffi) (x1' := Host.Ts.Sim.Full.mlxOf DEC_clearFill.s1.ffi) (DEC_clearFill.cfoot0 clean hltC nltC itemsC tracedC cl) rfl DEC_clearFill.ofx0_0 DEC_clearFill.ofx1_0 hobjC DEC_clearFill.ff00 DEC_clearFill.ff10 DEC_clearFill.ffck0,
    kernShift_foot (x0' := Host.Ts.Sim.Full.mlxOf DEC_clearFill.s2.ffi) (x1' := Host.Ts.Sim.Full.mlxOf DEC_clearFill.s1.ffi) (DEC_clearFill.cfoot0 clean hltC nltC itemsC tracedC cl) rfl DEC_clearFill.okr0_0 DEC_clearFill.okr1_0 (Nat.le_of_ble_eq_true DEC_clearFill.fkn0) hfC htC hclC
      DEC_clearFill.fkf00 DEC_clearFill.fkt00 DEC_clearFill.fkf10 DEC_clearFill.fkt10 DEC_clearFill.fkck0,
    pendReg_of rfl DEC_clearFill.cnh00 DEC_clearFill.cnh10 (Nat.le_of_ble_eq_true DEC_clearFill.cpendLe0) DEC_clearFill.cpendR0⟩

end Host.Load.Run.Tpl
