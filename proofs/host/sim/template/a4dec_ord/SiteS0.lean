import host.sim.template.a4dec_ord.SiteCl0
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
def DEC_ord.P0 : LoadP := ⟨25000, 131072, 1099511627776, 20000, 22539, []⟩
noncomputable abbrev DEC_ord.cx0_0 : Host.Load.LSt := clearTokens (Host.Load.Layers.toLoad DEC_ord.s2.ffi)
noncomputable abbrev DEC_ord.cx1_0 : Host.Load.LSt := clearTokens (Host.Load.Layers.toLoad DEC_ord.s1.ffi)
def DEC_ord.khinv0 : PTrie Nat := Stage.setAll PTrie.nil []
def DEC_ord.kninv0 : PTrie Nat := Stage.setAll PTrie.nil []
/-- The stage's footprint: its written and fresh handles, fresh nodes, written and fresh items. -/
def DEC_ord.cwS0 : List Nat := []
def DEC_ord.cnS0 : List Nat := List.range' 22539 0
def DEC_ord.ciS0 : List Nat := [20157] ++ List.range' 22539 0

-- the small checks (`MChecks`'s)
kernel_rfl DEC_ord.cnh00 : DEC_ord.kd0.nh0 = DEC_ord.cx0_0.mlx.next
kernel_rfl DEC_ord.cnh10 : DEC_ord.kd0.nh1 = DEC_ord.cx1_0.mlx.next
kernel_rfl DEC_ord.cnn00 : DEC_ord.kd0.nn0 = DEC_ord.cx0_0.mlx.nnext
kernel_rfl DEC_ord.cnn10 : DEC_ord.kd0.nn1 = DEC_ord.cx1_0.mlx.nnext
kernel_rfl DEC_ord.cplo0 : (Nat.blt 0 DEC_ord.P0.lo && Nat.ble DEC_ord.P0.lo DEC_ord.cx0_0.mlx.next && Nat.ble DEC_ord.P0.lo RData.bigHi && Nat.ble RData.bigHi DEC_ord.P0.E) = true
kernel_rfl DEC_ord.ccnt0 : (Nat.ble DEC_ord.cx0_0.mlx.next DEC_ord.cx1_0.mlx.next && Nat.ble DEC_ord.cx0_0.mlx.nnext DEC_ord.cx1_0.mlx.nnext) = true
kernel_rfl DEC_ord.cnband0 : (Nat.blt 0 DEC_ord.P0.NL && Nat.ble DEC_ord.P0.NL DEC_ord.P0.N0 && Nat.ble DEC_ord.P0.N0 DEC_ord.cx0_0.mlx.nnext) = true
kernel_rfl DEC_ord.chbelow0 : DEC_ord.kd0.checkHndBelow = true
kernel_rfl DEC_ord.chren0 : checkRenG DEC_ord.kd0.hnd DEC_ord.khinv0 (phB DEC_ord.cx0_0.mlx) = true
kernel_rfl DEC_ord.cband0 : DEC_ord.kd0.checkBand DEC_ord.P0.lo = true
kernel_rfl DEC_ord.cnh1pos0 : Nat.blt 0 DEC_ord.kd0.nh1 = true
kernel_rfl DEC_ord.cnren0 : checkRenG DEC_ord.kd0.node DEC_ord.kninv0 (pnB DEC_ord.cx0_0.mlx) = true
kernel_rfl DEC_ord.cnlow0 : (PTrie.keysA DEC_ord.kd0.node).all (fun j => Nat.ble DEC_ord.P0.NL j && Nat.blt (DEC_ord.kd0.nodeF j) DEC_ord.cx1_0.mlx.nnext) = true
kernel_rfl DEC_ord.cabs0a0 : DEC_ord.cx0_0.mlx.arrs.get 0 = none
kernel_rfl DEC_ord.cabs0b0 : DEC_ord.cx0_0.mlx.objs.get 0 = none
kernel_rfl DEC_ord.ctok10 : DEC_ord.cx1_0.mlx.tokens = []
kernel_rfl DEC_ord.cpend0 : DEC_ord.cx1_0.mlx.pending = DEC_ord.cx0_0.mlx.pending.map DEC_ord.kappa0.pend
kernel_rfl DEC_ord.cerrh0 : DEC_ord.cx1_0.mlx.errh = DEC_ord.cx0_0.mlx.errh.map DEC_ord.kappa0.arg
kernel_rfl DEC_ord.cfiles0 : DEC_ord.cx1_0.mlx.files = DEC_ord.cx0_0.mlx.files
kernel_rfl DEC_ord.carch0 : DEC_ord.cx1_0.mlx.arch = DEC_ord.cx0_0.mlx.arch
kernel_rfl DEC_ord.csizes0 : DEC_ord.cx1_0.mlx.deviceSizes = DEC_ord.cx0_0.mlx.deviceSizes
kernel_rfl DEC_ord.cwired0 : DEC_ord.cx1_0.mlx.wired = DEC_ord.cx0_0.mlx.wired
kernel_rfl DEC_ord.chost0 : DEC_ord.cx1_0.host = DEC_ord.cx0_0.host
-- the compaction map's addresses are `DEC_ord.kd0`'s
kernel_rfl DEC_ord.ckn00 : DEC_ord.kd0.n0 = 3123568
kernel_rfl DEC_ord.ckn10 : DEC_ord.kd0.n1 = 3123580
kernel_rfl DEC_ord.ckheap0 : (PTrie.keysA DEC_ord.kd0.heap).all (fun x => Nat.ble 3123568 x) = true
kernel_rfl DEC_ord.ckpl0 : (List.range 0).all (fun j => decide (DEC_ord.kd0.heap.get (3123568 + j) = nth? DEC_ord.pl0 j)) = true
-- the map fixes the call's names (`Conv.fixOld_compact`), the call's counters
kernel_rfl DEC_ord.fja0 : Nat.ble 3123568 3123568 = true
kernel_rfl DEC_ord.fn0 : Nat.ble 123 123 = true
kernel_rfl DEC_ord.fjaD0 : Nat.ble 3123568 DEC_ord.kd0.n0 = true
kernel_rfl DEC_ord.fxn0 : Nat.ble 29302 DEC_ord.kd0.nh0 = true
kernel_rfl DEC_ord.fnn0 : Nat.ble 22539 DEC_ord.kd0.nn0 = true
kernel_rfl DEC_ord.fxb0 : Nat.ble 29302 RData.bigHi = true
kernel_rfl DEC_ord.fheap0 : (PTrie.keysA DEC_ord.kd0.heap).all (Nat.ble (⟨29302, 22539, 3123568, 123⟩ : Conv.Cnt).ja) = true
kernel_rfl DEC_ord.fhnd0 : (PTrie.keysA DEC_ord.kd0.hnd).all (Nat.ble (⟨29302, 22539, 3123568, 123⟩ : Conv.Cnt).xn) = true
kernel_rfl DEC_ord.fnode0 : (PTrie.keysA DEC_ord.kd0.node).all (Nat.ble (⟨29302, 22539, 3123568, 123⟩ : Conv.Cnt).nn) = true
/-- The compaction map fixes the call's names. -/
theorem DEC_ord.cfix0 : Conv.FixOld (⟨29302, 22539, 3123568, 123⟩ : Conv.Cnt) DEC_ord.kappa0 :=
  Conv.fixOld_compact (Nat.le_of_ble_eq_true DEC_ord.fja0) (Nat.le_of_ble_eq_true DEC_ord.fn0) (Nat.le_of_ble_eq_true DEC_ord.fjaD0) (Nat.le_of_ble_eq_true DEC_ord.fxn0) (Nat.le_of_ble_eq_true DEC_ord.fnn0) (Nat.le_of_ble_eq_true DEC_ord.fxb0) DEC_ord.fheap0 DEC_ord.fhnd0 DEC_ord.fnode0
kernel_rfl DEC_ord.fcxn0 : (⟨29302, 22539, 3123568, 123⟩ : Conv.Cnt).xn = (Host.Load.Layers.toLoad DEC_ord.s0.ffi).mlx.next
kernel_rfl DEC_ord.fcnn0 : (⟨29302, 22539, 3123568, 123⟩ : Conv.Cnt).nn = (Host.Load.Layers.toLoad DEC_ord.s0.ffi).mlx.nnext
kernel_rfl DEC_ord.fle00 : (Nat.ble (Host.Load.Layers.toLoad DEC_ord.s0.ffi).mlx.next DEC_ord.cx0_0.mlx.next && Nat.ble (Host.Load.Layers.toLoad DEC_ord.s0.ffi).mlx.nnext DEC_ord.cx0_0.mlx.nnext && Nat.ble (Host.Load.Layers.toLoad DEC_ord.s0.ffi).mlx.next RData.bigHi) = true
kernel_rfl DEC_ord.fnk0 : (PTrie.keysA DEC_ord.kd0.node).all (Nat.ble (Host.Load.Layers.toLoad DEC_ord.s0.ffi).mlx.nnext) = true
-- the merged state keeps the call's entries off the stage's footprint
kernel_rfl DEC_ord.f1A0 : DEC_ord.cx1_0.mlx.arrs = Stage.setAll (Host.Load.Layers.toLoad DEC_ord.s0.ffi).mlx.arrs (DEC_ord.cwS0.filterMap fun i => (DEC_ord.cx1_0.mlx.arrs.get i).map (i, ·))
kernel_rfl DEC_ord.f1O0 : DEC_ord.cx1_0.mlx.objs = Stage.setAll (Host.Load.Layers.toLoad DEC_ord.s0.ffi).mlx.objs (DEC_ord.cwS0.filterMap fun i => (DEC_ord.cx1_0.mlx.objs.get i).map (i, ·))
kernel_rfl DEC_ord.f1N0 : DEC_ord.cx1_0.mlx.nodes = Stage.setAll (Host.Load.Layers.toLoad DEC_ord.s0.ffi).mlx.nodes (DEC_ord.cnS0.filterMap fun i => (DEC_ord.cx1_0.mlx.nodes.get i).map (i, ·))
kernel_rfl DEC_ord.f1I0 : DEC_ord.cx1_0.mlx.items = Stage.setAll (Host.Load.Layers.toLoad DEC_ord.s0.ffi).mlx.items (DEC_ord.ciS0.filterMap fun i => (DEC_ord.cx1_0.mlx.items.get i).map (i, ·))
kernel_rfl DEC_ord.fbd0 : (DEC_ord.clo0 ++ DEC_ord.cln0 ++ DEC_ord.cli0 ++ DEC_ord.cwS0 ++ DEC_ord.cnS0 ++ DEC_ord.ciS0).all (fun i => Nat.blt (i / 4096) (4 ^ 31)) = true
kernel_rfl DEC_ord.fincW0 : DEC_ord.cwS0.all (fun h => !Nat.blt h (Host.Load.Layers.toLoad DEC_ord.s0.ffi).mlx.next || DEC_ord.clo0.contains h) = true
kernel_rfl DEC_ord.fincI0 : DEC_ord.ciS0.all (fun k => !Nat.blt k (Host.Load.Layers.toLoad DEC_ord.s0.ffi).mlx.nnext || DEC_ord.cli0.contains k) = true
kernel_rfl DEC_ord.fincN0 : DEC_ord.cnS0.all (Nat.ble (Host.Load.Layers.toLoad DEC_ord.s0.ffi).mlx.nnext) = true
kernel_rfl DEC_ord.flnF0 : DEC_ord.cln0.all (Nat.ble (Host.Load.Layers.toLoad DEC_ord.s0.ffi).mlx.nnext) = true
-- the checks over the changed lists
kernel_rfl DEC_ord.fh0 : DEC_ord.clo0.all (handleOK DEC_ord.kappa0 DEC_ord.P0.lo DEC_ord.cx0_0.mlx DEC_ord.cx1_0.mlx) = true
kernel_rfl DEC_ord.fo0 : DEC_ord.clo0.map (fun h => DEC_ord.cx1_0.mlx.objs.get (DEC_ord.kappa0.handle h)) = DEC_ord.clo0.map (fun h => (DEC_ord.cx0_0.mlx.objs.get h).map DEC_ord.kappa0.nobj)
kernel_rfl DEC_ord.fok0 : DEC_ord.clo0.all (objOK DEC_ord.kappa0 DEC_ord.P0.NL DEC_ord.cx0_0.mlx) = true
kernel_rfl DEC_ord.fnd0 : DEC_ord.cln0.all (nodeOKF DEC_ord.kappa0 DEC_ord.P0 DEC_ord.cx0_0.mlx DEC_ord.cx1_0.mlx) = true
kernel_rfl DEC_ord.fp0 : ((DEC_ord.cln0.filter (fullB DEC_ord.P0))).map (fun i => (DEC_ord.cx1_0.mlx.nodes.get (DEC_ord.kappa0.node i)).map Host.Mlx.Ffi.Node.prim) =
  ((DEC_ord.cln0.filter (fullB DEC_ord.P0))).map (fun i => (DEC_ord.cx0_0.mlx.nodes.get i).map fun nd => DEC_ord.kappa0.prim nd.prim)
kernel_rfl DEC_ord.fnordI0 : incrB DEC_ord.kd0.nodeF (List.range' 22539 0) = true
kernel_rfl DEC_ord.fnordK0 : (PTrie.keysA DEC_ord.kd0.node).all (fun k => Nat.ble 22539 k && Nat.blt k 22539) = true
kernel_rfl DEC_ord.fnordL0 : (DEC_ord.cln0.filter (Nat.ble DEC_ord.P0.N0)).all (fun i => Nat.ble i (DEC_ord.kd0.nodeF i) && (Nat.blt i 22539 || Nat.ble DEC_ord.kd0.nn0 i)) = true
theorem DEC_ord.fnord0 : (DEC_ord.cln0.filter (Nat.ble DEC_ord.P0.N0)).all (fun i => Nat.ble i (DEC_ord.kd0.nodeF i) &&
    (PTrie.keysA DEC_ord.kd0.node).all fun j => !Nat.blt j i || Nat.blt (DEC_ord.kd0.nodeF j) (DEC_ord.kd0.nodeF i)) = true :=
  cnord_of DEC_ord.cnlow0 DEC_ord.cnn10 DEC_ord.fnordI0 DEC_ord.fnordK0 DEC_ord.fnordL0
kernel_rfl DEC_ord.fi0 : DEC_ord.cli0.all (pnB DEC_ord.cx0_0.mlx) = true
kernel_rfl DEC_ord.fii0 : DEC_ord.cli0.all (fun k => decide (DEC_ord.cx1_0.mlx.items.get (DEC_ord.kappa0.node k) = (DEC_ord.cx0_0.mlx.items.get k).map DEC_ord.kappa0.nv)) = true
/-- **The compaction's footprint.** -/
theorem DEC_ord.cfoot0 (clean : Conv.NClean (⟨29302, 22539, 3123568, 123⟩ : Conv.Cnt) (Host.Load.Layers.toLoad DEC_ord.s0.ffi).mlx) (hltC : ∀ h, PH (Host.Load.Layers.toLoad DEC_ord.s0.ffi).mlx h → h < (Host.Load.Layers.toLoad DEC_ord.s0.ffi).mlx.next) (nltC : ∀ i, PN (Host.Load.Layers.toLoad DEC_ord.s0.ffi).mlx i → i < (Host.Load.Layers.toLoad DEC_ord.s0.ffi).mlx.nnext) (itemsC : ∀ k v, (Host.Load.Layers.toLoad DEC_ord.s0.ffi).mlx.items.get k = some v → PN (Host.Load.Layers.toLoad DEC_ord.s0.ffi).mlx k) (tracedC : ∀ h o, (Host.Load.Layers.toLoad DEC_ord.s0.ffi).mlx.objs.get h = some o → ∀ i ∈ objTraces o, i < DEC_ord.P0.NL) (cl : SSt (· < 123) DEC_ord.cx0_0.mlx) :
    Conv.MFoot DEC_ord.P0 123 DEC_ord.kappa0 DEC_ord.kd0 DEC_ord.khinv0 DEC_ord.kninv0 (Host.Load.Layers.toLoad DEC_ord.s0.ffi).mlx DEC_ord.cx0_0.mlx DEC_ord.cx1_0.mlx (⟨29302, 22539, 3123568, 123⟩ : Conv.Cnt) DEC_ord.clo0 DEC_ord.cln0 DEC_ord.cli0 DEC_ord.cwS0 DEC_ord.cnS0 DEC_ord.ciS0 :=
  ⟨rfl, rfl, rfl, DEC_ord.cnh00, DEC_ord.cnh10, DEC_ord.cnn00, DEC_ord.cnn10, DEC_ord.cplo0, DEC_ord.ccnt0, DEC_ord.cnband0, DEC_ord.chbelow0, DEC_ord.chren0, DEC_ord.cband0, DEC_ord.cnh1pos0, DEC_ord.cnren0, DEC_ord.cnlow0, DEC_ord.cabs0a0, DEC_ord.cabs0b0, DEC_ord.ctok10, DEC_ord.cpend0, DEC_ord.cerrh0, DEC_ord.cfiles0, DEC_ord.carch0, DEC_ord.csizes0, DEC_ord.cwired0, DEC_ord.cfix0, clean, DEC_ord.fcxn0, DEC_ord.fcnn0, hltC, nltC, itemsC, tracedC, cl, DEC_ord.fle00, DEC_ord.fnk0, DEC_ord.ckA0, DEC_ord.cobjsK0, DEC_ord.cnodesK0, DEC_ord.citemsK0, DEC_ord.f1A0, DEC_ord.f1O0, DEC_ord.f1N0, DEC_ord.f1I0, DEC_ord.fbd0, DEC_ord.fincW0, DEC_ord.fincI0, DEC_ord.fincN0, DEC_ord.flnF0, DEC_ord.fh0, DEC_ord.fo0, DEC_ord.fok0, DEC_ord.fnd0, DEC_ord.fp0, DEC_ord.fnord0, DEC_ord.fi0, DEC_ord.fii0⟩
theorem DEC_ord.cnshift0 (clean : Conv.NClean (⟨29302, 22539, 3123568, 123⟩ : Conv.Cnt) (Host.Load.Layers.toLoad DEC_ord.s0.ffi).mlx) (hltC : ∀ h, PH (Host.Load.Layers.toLoad DEC_ord.s0.ffi).mlx h → h < (Host.Load.Layers.toLoad DEC_ord.s0.ffi).mlx.next) (nltC : ∀ i, PN (Host.Load.Layers.toLoad DEC_ord.s0.ffi).mlx i → i < (Host.Load.Layers.toLoad DEC_ord.s0.ffi).mlx.nnext) (itemsC : ∀ k v, (Host.Load.Layers.toLoad DEC_ord.s0.ffi).mlx.items.get k = some v → PN (Host.Load.Layers.toLoad DEC_ord.s0.ffi).mlx k) (tracedC : ∀ h o, (Host.Load.Layers.toLoad DEC_ord.s0.ffi).mlx.objs.get h = some o → ∀ i ∈ objTraces o, i < DEC_ord.P0.NL) (cl : SSt (· < 123) DEC_ord.cx0_0.mlx) : NShift DEC_ord.P0 123 DEC_ord.kappa0 DEC_ord.cx0_0 DEC_ord.cx1_0 :=
  Conv.nshift_of_foot (DEC_ord.cfoot0 clean hltC nltC itemsC tracedC cl) DEC_ord.chost0 (compact_a_eq DEC_ord.ckn00 DEC_ord.ckn10 DEC_ord.ckheap0 DEC_ord.ckpl0)

-- the observers: the layers' states at the call, the canonical and the merged state, their footprints and checks
noncomputable def DEC_ord.fxC_0 : PTrie Unit := (Host.Ts.Sim.Full.freedOf DEC_ord.s0.ffi).getD PTrie.nil
noncomputable def DEC_ord.krC_0 : Host.Load.Layers.KRec := (Host.Ts.Sim.Full.krecOf DEC_ord.s0.ffi).getD Host.Load.Layers.KRec.empty
kernel_rfl DEC_ord.ofxC_0 : (Host.Ts.Sim.Full.freedOf DEC_ord.s0.ffi) = some DEC_ord.fxC_0
kernel_rfl DEC_ord.okrC_0 : (Host.Ts.Sim.Full.krecOf DEC_ord.s0.ffi) = some DEC_ord.krC_0
noncomputable def DEC_ord.fx0_0 : PTrie Unit := (Host.Ts.Sim.Full.freedOf DEC_ord.s2.ffi).getD PTrie.nil
noncomputable def DEC_ord.kr0_0 : Host.Load.Layers.KRec := (Host.Ts.Sim.Full.krecOf DEC_ord.s2.ffi).getD Host.Load.Layers.KRec.empty
kernel_rfl DEC_ord.ofx0_0 : (Host.Ts.Sim.Full.freedOf DEC_ord.s2.ffi) = some DEC_ord.fx0_0
kernel_rfl DEC_ord.okr0_0 : (Host.Ts.Sim.Full.krecOf DEC_ord.s2.ffi) = some DEC_ord.kr0_0
noncomputable def DEC_ord.fx1_0 : PTrie Unit := (Host.Ts.Sim.Full.freedOf DEC_ord.s1.ffi).getD PTrie.nil
noncomputable def DEC_ord.kr1_0 : Host.Load.Layers.KRec := (Host.Ts.Sim.Full.krecOf DEC_ord.s1.ffi).getD Host.Load.Layers.KRec.empty
kernel_rfl DEC_ord.ofx1_0 : (Host.Ts.Sim.Full.freedOf DEC_ord.s1.ffi) = some DEC_ord.fx1_0
kernel_rfl DEC_ord.okr1_0 : (Host.Ts.Sim.Full.krecOf DEC_ord.s1.ffi) = some DEC_ord.kr1_0
kernel_rfl DEC_ord.ff00 : DEC_ord.fx0_0 = Stage.setAll DEC_ord.fxC_0 (DEC_ord.clo0.filterMap fun i => (DEC_ord.fx0_0.get i).map (i, ·))
kernel_rfl DEC_ord.ff10 : DEC_ord.fx1_0 = Stage.setAll DEC_ord.fxC_0 (DEC_ord.cwS0.filterMap fun i => (DEC_ord.fx1_0.get i).map (i, ·))
kernel_rfl DEC_ord.ffck0 : freedLB DEC_ord.kappa0 DEC_ord.cx0_0.mlx DEC_ord.fx0_0 DEC_ord.fx1_0 DEC_ord.clo0 = true
kernel_rfl DEC_ord.fkf00 : DEC_ord.kr0_0.flags = Stage.setAll DEC_ord.krC_0.flags (DEC_ord.clo0.filterMap fun i => (DEC_ord.kr0_0.flags.get i).map (i, ·))
kernel_rfl DEC_ord.fkt00 : DEC_ord.kr0_0.targs = Stage.setAll DEC_ord.krC_0.targs (DEC_ord.clo0.filterMap fun i => (DEC_ord.kr0_0.targs.get i).map (i, ·))
kernel_rfl DEC_ord.fkf10 : DEC_ord.kr1_0.flags = Stage.setAll DEC_ord.krC_0.flags (DEC_ord.cwS0.filterMap fun i => (DEC_ord.kr1_0.flags.get i).map (i, ·))
kernel_rfl DEC_ord.fkt10 : DEC_ord.kr1_0.targs = Stage.setAll DEC_ord.krC_0.targs (DEC_ord.cwS0.filterMap fun i => (DEC_ord.kr1_0.targs.get i).map (i, ·))
kernel_rfl DEC_ord.fkck0 : krecLB DEC_ord.kappa0 123 DEC_ord.cx0_0.mlx DEC_ord.kr0_0 DEC_ord.kr1_0 DEC_ord.clo0 = true
kernel_rfl DEC_ord.fkn0 : Nat.ble 123 123 = true
-- the bridge and the pending traces' regions
kernel_rfl DEC_ord.cbridge0 : Host.Ts.Sim.Full.bridgeOf DEC_ord.s1.ffi = Host.Ts.Sim.Full.bridgeOf DEC_ord.s2.ffi
kernel_rfl DEC_ord.cpendR0 : pendRegB DEC_ord.kappa0 (Host.Load.Layers.toLoad DEC_ord.s2.ffi).mlx = true
kernel_rfl DEC_ord.cpendLe0 : Nat.ble (Host.Load.Layers.toLoad DEC_ord.s2.ffi).mlx.next (Host.Load.Layers.toLoad DEC_ord.s1.ffi).mlx.next = true
/-- **The compaction's native shift**, given the call's bookkeeping, its relation's facts (the model's and the
observers') and the canonical closedness. -/
theorem DEC_ord.cshift0 (clean : Conv.NClean (⟨29302, 22539, 3123568, 123⟩ : Conv.Cnt) (Host.Load.Layers.toLoad DEC_ord.s0.ffi).mlx) (hltC : ∀ h, PH (Host.Load.Layers.toLoad DEC_ord.s0.ffi).mlx h → h < (Host.Load.Layers.toLoad DEC_ord.s0.ffi).mlx.next) (nltC : ∀ i, PN (Host.Load.Layers.toLoad DEC_ord.s0.ffi).mlx i → i < (Host.Load.Layers.toLoad DEC_ord.s0.ffi).mlx.nnext) (itemsC : ∀ k v, (Host.Load.Layers.toLoad DEC_ord.s0.ffi).mlx.items.get k = some v → PN (Host.Load.Layers.toLoad DEC_ord.s0.ffi).mlx k) (tracedC : ∀ h o, (Host.Load.Layers.toLoad DEC_ord.s0.ffi).mlx.objs.get h = some o → ∀ i ∈ objTraces o, i < DEC_ord.P0.NL) (cl : SSt (· < 123) DEC_ord.cx0_0.mlx)
    (hobjC : ∀ h, DEC_ord.fxC_0.get h = some () → ((Host.Load.Layers.toLoad DEC_ord.s0.ffi).mlx.objs.get h).isSome = true)
    (hfC : ∀ h, (DEC_ord.krC_0.flags.get h).isSome = true → ((Host.Load.Layers.toLoad DEC_ord.s0.ffi).mlx.objs.get h).isSome = true)
    (htC : ∀ h, (DEC_ord.krC_0.targs.get h).isSome = true → ((Host.Load.Layers.toLoad DEC_ord.s0.ffi).mlx.objs.get h).isSome = true)
    (hclC : ∀ h l, DEC_ord.krC_0.targs.get h = some l → Host.Ts.Sim.Full.STargs (· < (⟨29302, 22539, 3123568, 123⟩ : Conv.Cnt).n) l) :
    Conv.FullShiftQ DEC_ord.P0 123 DEC_ord.kappa0 DEC_ord.s2.ffi DEC_ord.s1.ffi :=
  ⟨DEC_ord.cnshift0 clean hltC nltC itemsC tracedC cl, DEC_ord.cqueue0, fun t ht => bSN_sound (List.all_eq_true.mp DEC_ord.ctokSupp0 t ht),
    DEC_ord.cbridge0,
    liveShift_foot (x0' := Host.Ts.Sim.Full.mlxOf DEC_ord.s2.ffi) (x1' := Host.Ts.Sim.Full.mlxOf DEC_ord.s1.ffi) (DEC_ord.cfoot0 clean hltC nltC itemsC tracedC cl) rfl DEC_ord.ofx0_0 DEC_ord.ofx1_0 hobjC DEC_ord.ff00 DEC_ord.ff10 DEC_ord.ffck0,
    kernShift_foot (x0' := Host.Ts.Sim.Full.mlxOf DEC_ord.s2.ffi) (x1' := Host.Ts.Sim.Full.mlxOf DEC_ord.s1.ffi) (DEC_ord.cfoot0 clean hltC nltC itemsC tracedC cl) rfl DEC_ord.okr0_0 DEC_ord.okr1_0 (Nat.le_of_ble_eq_true DEC_ord.fkn0) hfC htC hclC
      DEC_ord.fkf00 DEC_ord.fkt00 DEC_ord.fkf10 DEC_ord.fkt10 DEC_ord.fkck0,
    pendReg_of rfl DEC_ord.cnh00 DEC_ord.cnh10 (Nat.le_of_ble_eq_true DEC_ord.cpendLe0) DEC_ord.cpendR0⟩

end Host.Load.Run.Tpl
