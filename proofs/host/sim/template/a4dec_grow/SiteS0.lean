import host.sim.template.a4dec_grow.SiteCl0
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
def DEC_grow.P0 : LoadP := ⟨25000, 131072, 1099511627776, 20000, 22539, []⟩
noncomputable abbrev DEC_grow.cx0_0 : Host.Load.LSt := clearTokens (Host.Load.Layers.toLoad DEC_grow.s2.ffi)
noncomputable abbrev DEC_grow.cx1_0 : Host.Load.LSt := clearTokens (Host.Load.Layers.toLoad DEC_grow.s1.ffi)
def DEC_grow.khinv0 : PTrie Nat := Stage.setAll PTrie.nil []
def DEC_grow.kninv0 : PTrie Nat := Stage.setAll PTrie.nil []
/-- The stage's footprint: its written and fresh handles, fresh nodes, written and fresh items. -/
def DEC_grow.cwS0 : List Nat := []
def DEC_grow.cnS0 : List Nat := List.range' 22539 0
def DEC_grow.ciS0 : List Nat := [20157] ++ List.range' 22539 0

-- the small checks (`MChecks`'s)
kernel_rfl DEC_grow.cnh00 : DEC_grow.kd0.nh0 = DEC_grow.cx0_0.mlx.next
kernel_rfl DEC_grow.cnh10 : DEC_grow.kd0.nh1 = DEC_grow.cx1_0.mlx.next
kernel_rfl DEC_grow.cnn00 : DEC_grow.kd0.nn0 = DEC_grow.cx0_0.mlx.nnext
kernel_rfl DEC_grow.cnn10 : DEC_grow.kd0.nn1 = DEC_grow.cx1_0.mlx.nnext
kernel_rfl DEC_grow.cplo0 : (Nat.blt 0 DEC_grow.P0.lo && Nat.ble DEC_grow.P0.lo DEC_grow.cx0_0.mlx.next && Nat.ble DEC_grow.P0.lo RData.bigHi && Nat.ble RData.bigHi DEC_grow.P0.E) = true
kernel_rfl DEC_grow.ccnt0 : (Nat.ble DEC_grow.cx0_0.mlx.next DEC_grow.cx1_0.mlx.next && Nat.ble DEC_grow.cx0_0.mlx.nnext DEC_grow.cx1_0.mlx.nnext) = true
kernel_rfl DEC_grow.cnband0 : (Nat.blt 0 DEC_grow.P0.NL && Nat.ble DEC_grow.P0.NL DEC_grow.P0.N0 && Nat.ble DEC_grow.P0.N0 DEC_grow.cx0_0.mlx.nnext) = true
kernel_rfl DEC_grow.chbelow0 : DEC_grow.kd0.checkHndBelow = true
kernel_rfl DEC_grow.chren0 : checkRenG DEC_grow.kd0.hnd DEC_grow.khinv0 (phB DEC_grow.cx0_0.mlx) = true
kernel_rfl DEC_grow.cband0 : DEC_grow.kd0.checkBand DEC_grow.P0.lo = true
kernel_rfl DEC_grow.cnh1pos0 : Nat.blt 0 DEC_grow.kd0.nh1 = true
kernel_rfl DEC_grow.cnren0 : checkRenG DEC_grow.kd0.node DEC_grow.kninv0 (pnB DEC_grow.cx0_0.mlx) = true
kernel_rfl DEC_grow.cnlow0 : (PTrie.keysA DEC_grow.kd0.node).all (fun j => Nat.ble DEC_grow.P0.NL j && Nat.blt (DEC_grow.kd0.nodeF j) DEC_grow.cx1_0.mlx.nnext) = true
kernel_rfl DEC_grow.cabs0a0 : DEC_grow.cx0_0.mlx.arrs.get 0 = none
kernel_rfl DEC_grow.cabs0b0 : DEC_grow.cx0_0.mlx.objs.get 0 = none
kernel_rfl DEC_grow.ctok10 : DEC_grow.cx1_0.mlx.tokens = []
kernel_rfl DEC_grow.cpend0 : DEC_grow.cx1_0.mlx.pending = DEC_grow.cx0_0.mlx.pending.map DEC_grow.kappa0.pend
kernel_rfl DEC_grow.cerrh0 : DEC_grow.cx1_0.mlx.errh = DEC_grow.cx0_0.mlx.errh.map DEC_grow.kappa0.arg
kernel_rfl DEC_grow.cfiles0 : DEC_grow.cx1_0.mlx.files = DEC_grow.cx0_0.mlx.files
kernel_rfl DEC_grow.carch0 : DEC_grow.cx1_0.mlx.arch = DEC_grow.cx0_0.mlx.arch
kernel_rfl DEC_grow.csizes0 : DEC_grow.cx1_0.mlx.deviceSizes = DEC_grow.cx0_0.mlx.deviceSizes
kernel_rfl DEC_grow.cwired0 : DEC_grow.cx1_0.mlx.wired = DEC_grow.cx0_0.mlx.wired
kernel_rfl DEC_grow.chost0 : DEC_grow.cx1_0.host = DEC_grow.cx0_0.host
-- the compaction map's addresses are `DEC_grow.kd0`'s
kernel_rfl DEC_grow.ckn00 : DEC_grow.kd0.n0 = 3123568
kernel_rfl DEC_grow.ckn10 : DEC_grow.kd0.n1 = 3123580
kernel_rfl DEC_grow.ckheap0 : (PTrie.keysA DEC_grow.kd0.heap).all (fun x => Nat.ble 3123568 x) = true
kernel_rfl DEC_grow.ckpl0 : (List.range 0).all (fun j => decide (DEC_grow.kd0.heap.get (3123568 + j) = nth? DEC_grow.pl0 j)) = true
-- the map fixes the call's names (`Conv.fixOld_compact`), the call's counters
kernel_rfl DEC_grow.fja0 : Nat.ble 3123568 3123568 = true
kernel_rfl DEC_grow.fn0 : Nat.ble 123 123 = true
kernel_rfl DEC_grow.fjaD0 : Nat.ble 3123568 DEC_grow.kd0.n0 = true
kernel_rfl DEC_grow.fxn0 : Nat.ble 29302 DEC_grow.kd0.nh0 = true
kernel_rfl DEC_grow.fnn0 : Nat.ble 22539 DEC_grow.kd0.nn0 = true
kernel_rfl DEC_grow.fxb0 : Nat.ble 29302 RData.bigHi = true
kernel_rfl DEC_grow.fheap0 : (PTrie.keysA DEC_grow.kd0.heap).all (Nat.ble (⟨29302, 22539, 3123568, 123⟩ : Conv.Cnt).ja) = true
kernel_rfl DEC_grow.fhnd0 : (PTrie.keysA DEC_grow.kd0.hnd).all (Nat.ble (⟨29302, 22539, 3123568, 123⟩ : Conv.Cnt).xn) = true
kernel_rfl DEC_grow.fnode0 : (PTrie.keysA DEC_grow.kd0.node).all (Nat.ble (⟨29302, 22539, 3123568, 123⟩ : Conv.Cnt).nn) = true
/-- The compaction map fixes the call's names. -/
theorem DEC_grow.cfix0 : Conv.FixOld (⟨29302, 22539, 3123568, 123⟩ : Conv.Cnt) DEC_grow.kappa0 :=
  Conv.fixOld_compact (Nat.le_of_ble_eq_true DEC_grow.fja0) (Nat.le_of_ble_eq_true DEC_grow.fn0) (Nat.le_of_ble_eq_true DEC_grow.fjaD0) (Nat.le_of_ble_eq_true DEC_grow.fxn0) (Nat.le_of_ble_eq_true DEC_grow.fnn0) (Nat.le_of_ble_eq_true DEC_grow.fxb0) DEC_grow.fheap0 DEC_grow.fhnd0 DEC_grow.fnode0
kernel_rfl DEC_grow.fcxn0 : (⟨29302, 22539, 3123568, 123⟩ : Conv.Cnt).xn = (Host.Load.Layers.toLoad DEC_grow.s0.ffi).mlx.next
kernel_rfl DEC_grow.fcnn0 : (⟨29302, 22539, 3123568, 123⟩ : Conv.Cnt).nn = (Host.Load.Layers.toLoad DEC_grow.s0.ffi).mlx.nnext
kernel_rfl DEC_grow.fle00 : (Nat.ble (Host.Load.Layers.toLoad DEC_grow.s0.ffi).mlx.next DEC_grow.cx0_0.mlx.next && Nat.ble (Host.Load.Layers.toLoad DEC_grow.s0.ffi).mlx.nnext DEC_grow.cx0_0.mlx.nnext && Nat.ble (Host.Load.Layers.toLoad DEC_grow.s0.ffi).mlx.next RData.bigHi) = true
kernel_rfl DEC_grow.fnk0 : (PTrie.keysA DEC_grow.kd0.node).all (Nat.ble (Host.Load.Layers.toLoad DEC_grow.s0.ffi).mlx.nnext) = true
-- the merged state keeps the call's entries off the stage's footprint
kernel_rfl DEC_grow.f1A0 : DEC_grow.cx1_0.mlx.arrs = Stage.setAll (Host.Load.Layers.toLoad DEC_grow.s0.ffi).mlx.arrs (DEC_grow.cwS0.filterMap fun i => (DEC_grow.cx1_0.mlx.arrs.get i).map (i, ·))
kernel_rfl DEC_grow.f1O0 : DEC_grow.cx1_0.mlx.objs = Stage.setAll (Host.Load.Layers.toLoad DEC_grow.s0.ffi).mlx.objs (DEC_grow.cwS0.filterMap fun i => (DEC_grow.cx1_0.mlx.objs.get i).map (i, ·))
kernel_rfl DEC_grow.f1N0 : DEC_grow.cx1_0.mlx.nodes = Stage.setAll (Host.Load.Layers.toLoad DEC_grow.s0.ffi).mlx.nodes (DEC_grow.cnS0.filterMap fun i => (DEC_grow.cx1_0.mlx.nodes.get i).map (i, ·))
kernel_rfl DEC_grow.f1I0 : DEC_grow.cx1_0.mlx.items = Stage.setAll (Host.Load.Layers.toLoad DEC_grow.s0.ffi).mlx.items (DEC_grow.ciS0.filterMap fun i => (DEC_grow.cx1_0.mlx.items.get i).map (i, ·))
kernel_rfl DEC_grow.fbd0 : (DEC_grow.clo0 ++ DEC_grow.cln0 ++ DEC_grow.cli0 ++ DEC_grow.cwS0 ++ DEC_grow.cnS0 ++ DEC_grow.ciS0).all (fun i => Nat.blt (i / 4096) (4 ^ 31)) = true
kernel_rfl DEC_grow.fincW0 : DEC_grow.cwS0.all (fun h => !Nat.blt h (Host.Load.Layers.toLoad DEC_grow.s0.ffi).mlx.next || DEC_grow.clo0.contains h) = true
kernel_rfl DEC_grow.fincI0 : DEC_grow.ciS0.all (fun k => !Nat.blt k (Host.Load.Layers.toLoad DEC_grow.s0.ffi).mlx.nnext || DEC_grow.cli0.contains k) = true
kernel_rfl DEC_grow.fincN0 : DEC_grow.cnS0.all (Nat.ble (Host.Load.Layers.toLoad DEC_grow.s0.ffi).mlx.nnext) = true
kernel_rfl DEC_grow.flnF0 : DEC_grow.cln0.all (Nat.ble (Host.Load.Layers.toLoad DEC_grow.s0.ffi).mlx.nnext) = true
-- the checks over the changed lists
kernel_rfl DEC_grow.fh0 : DEC_grow.clo0.all (handleOK DEC_grow.kappa0 DEC_grow.P0.lo DEC_grow.cx0_0.mlx DEC_grow.cx1_0.mlx) = true
kernel_rfl DEC_grow.fo0 : DEC_grow.clo0.map (fun h => DEC_grow.cx1_0.mlx.objs.get (DEC_grow.kappa0.handle h)) = DEC_grow.clo0.map (fun h => (DEC_grow.cx0_0.mlx.objs.get h).map DEC_grow.kappa0.nobj)
kernel_rfl DEC_grow.fok0 : DEC_grow.clo0.all (objOK DEC_grow.kappa0 DEC_grow.P0.NL DEC_grow.cx0_0.mlx) = true
kernel_rfl DEC_grow.fnd0 : DEC_grow.cln0.all (nodeOKF DEC_grow.kappa0 DEC_grow.P0 DEC_grow.cx0_0.mlx DEC_grow.cx1_0.mlx) = true
kernel_rfl DEC_grow.fp0 : ((DEC_grow.cln0.filter (fullB DEC_grow.P0))).map (fun i => (DEC_grow.cx1_0.mlx.nodes.get (DEC_grow.kappa0.node i)).map Host.Mlx.Ffi.Node.prim) =
  ((DEC_grow.cln0.filter (fullB DEC_grow.P0))).map (fun i => (DEC_grow.cx0_0.mlx.nodes.get i).map fun nd => DEC_grow.kappa0.prim nd.prim)
kernel_rfl DEC_grow.fnordI0 : incrB DEC_grow.kd0.nodeF (List.range' 22539 0) = true
kernel_rfl DEC_grow.fnordK0 : (PTrie.keysA DEC_grow.kd0.node).all (fun k => Nat.ble 22539 k && Nat.blt k 22539) = true
kernel_rfl DEC_grow.fnordL0 : (DEC_grow.cln0.filter (Nat.ble DEC_grow.P0.N0)).all (fun i => Nat.ble i (DEC_grow.kd0.nodeF i) && (Nat.blt i 22539 || Nat.ble DEC_grow.kd0.nn0 i)) = true
theorem DEC_grow.fnord0 : (DEC_grow.cln0.filter (Nat.ble DEC_grow.P0.N0)).all (fun i => Nat.ble i (DEC_grow.kd0.nodeF i) &&
    (PTrie.keysA DEC_grow.kd0.node).all fun j => !Nat.blt j i || Nat.blt (DEC_grow.kd0.nodeF j) (DEC_grow.kd0.nodeF i)) = true :=
  cnord_of DEC_grow.cnlow0 DEC_grow.cnn10 DEC_grow.fnordI0 DEC_grow.fnordK0 DEC_grow.fnordL0
kernel_rfl DEC_grow.fi0 : DEC_grow.cli0.all (pnB DEC_grow.cx0_0.mlx) = true
kernel_rfl DEC_grow.fii0 : DEC_grow.cli0.all (fun k => decide (DEC_grow.cx1_0.mlx.items.get (DEC_grow.kappa0.node k) = (DEC_grow.cx0_0.mlx.items.get k).map DEC_grow.kappa0.nv)) = true
/-- **The compaction's footprint.** -/
theorem DEC_grow.cfoot0 (clean : Conv.NClean (⟨29302, 22539, 3123568, 123⟩ : Conv.Cnt) (Host.Load.Layers.toLoad DEC_grow.s0.ffi).mlx) (hltC : ∀ h, PH (Host.Load.Layers.toLoad DEC_grow.s0.ffi).mlx h → h < (Host.Load.Layers.toLoad DEC_grow.s0.ffi).mlx.next) (nltC : ∀ i, PN (Host.Load.Layers.toLoad DEC_grow.s0.ffi).mlx i → i < (Host.Load.Layers.toLoad DEC_grow.s0.ffi).mlx.nnext) (itemsC : ∀ k v, (Host.Load.Layers.toLoad DEC_grow.s0.ffi).mlx.items.get k = some v → PN (Host.Load.Layers.toLoad DEC_grow.s0.ffi).mlx k) (tracedC : ∀ h o, (Host.Load.Layers.toLoad DEC_grow.s0.ffi).mlx.objs.get h = some o → ∀ i ∈ objTraces o, i < DEC_grow.P0.NL) (cl : SSt (· < 123) DEC_grow.cx0_0.mlx) :
    Conv.MFoot DEC_grow.P0 123 DEC_grow.kappa0 DEC_grow.kd0 DEC_grow.khinv0 DEC_grow.kninv0 (Host.Load.Layers.toLoad DEC_grow.s0.ffi).mlx DEC_grow.cx0_0.mlx DEC_grow.cx1_0.mlx (⟨29302, 22539, 3123568, 123⟩ : Conv.Cnt) DEC_grow.clo0 DEC_grow.cln0 DEC_grow.cli0 DEC_grow.cwS0 DEC_grow.cnS0 DEC_grow.ciS0 :=
  ⟨rfl, rfl, rfl, DEC_grow.cnh00, DEC_grow.cnh10, DEC_grow.cnn00, DEC_grow.cnn10, DEC_grow.cplo0, DEC_grow.ccnt0, DEC_grow.cnband0, DEC_grow.chbelow0, DEC_grow.chren0, DEC_grow.cband0, DEC_grow.cnh1pos0, DEC_grow.cnren0, DEC_grow.cnlow0, DEC_grow.cabs0a0, DEC_grow.cabs0b0, DEC_grow.ctok10, DEC_grow.cpend0, DEC_grow.cerrh0, DEC_grow.cfiles0, DEC_grow.carch0, DEC_grow.csizes0, DEC_grow.cwired0, DEC_grow.cfix0, clean, DEC_grow.fcxn0, DEC_grow.fcnn0, hltC, nltC, itemsC, tracedC, cl, DEC_grow.fle00, DEC_grow.fnk0, DEC_grow.ckA0, DEC_grow.cobjsK0, DEC_grow.cnodesK0, DEC_grow.citemsK0, DEC_grow.f1A0, DEC_grow.f1O0, DEC_grow.f1N0, DEC_grow.f1I0, DEC_grow.fbd0, DEC_grow.fincW0, DEC_grow.fincI0, DEC_grow.fincN0, DEC_grow.flnF0, DEC_grow.fh0, DEC_grow.fo0, DEC_grow.fok0, DEC_grow.fnd0, DEC_grow.fp0, DEC_grow.fnord0, DEC_grow.fi0, DEC_grow.fii0⟩
theorem DEC_grow.cnshift0 (clean : Conv.NClean (⟨29302, 22539, 3123568, 123⟩ : Conv.Cnt) (Host.Load.Layers.toLoad DEC_grow.s0.ffi).mlx) (hltC : ∀ h, PH (Host.Load.Layers.toLoad DEC_grow.s0.ffi).mlx h → h < (Host.Load.Layers.toLoad DEC_grow.s0.ffi).mlx.next) (nltC : ∀ i, PN (Host.Load.Layers.toLoad DEC_grow.s0.ffi).mlx i → i < (Host.Load.Layers.toLoad DEC_grow.s0.ffi).mlx.nnext) (itemsC : ∀ k v, (Host.Load.Layers.toLoad DEC_grow.s0.ffi).mlx.items.get k = some v → PN (Host.Load.Layers.toLoad DEC_grow.s0.ffi).mlx k) (tracedC : ∀ h o, (Host.Load.Layers.toLoad DEC_grow.s0.ffi).mlx.objs.get h = some o → ∀ i ∈ objTraces o, i < DEC_grow.P0.NL) (cl : SSt (· < 123) DEC_grow.cx0_0.mlx) : NShift DEC_grow.P0 123 DEC_grow.kappa0 DEC_grow.cx0_0 DEC_grow.cx1_0 :=
  Conv.nshift_of_foot (DEC_grow.cfoot0 clean hltC nltC itemsC tracedC cl) DEC_grow.chost0 (compact_a_eq DEC_grow.ckn00 DEC_grow.ckn10 DEC_grow.ckheap0 DEC_grow.ckpl0)

-- the observers: the layers' states at the call, the canonical and the merged state, their footprints and checks
noncomputable def DEC_grow.fxC_0 : PTrie Unit := (Host.Ts.Sim.Full.freedOf DEC_grow.s0.ffi).getD PTrie.nil
noncomputable def DEC_grow.krC_0 : Host.Load.Layers.KRec := (Host.Ts.Sim.Full.krecOf DEC_grow.s0.ffi).getD Host.Load.Layers.KRec.empty
kernel_rfl DEC_grow.ofxC_0 : (Host.Ts.Sim.Full.freedOf DEC_grow.s0.ffi) = some DEC_grow.fxC_0
kernel_rfl DEC_grow.okrC_0 : (Host.Ts.Sim.Full.krecOf DEC_grow.s0.ffi) = some DEC_grow.krC_0
noncomputable def DEC_grow.fx0_0 : PTrie Unit := (Host.Ts.Sim.Full.freedOf DEC_grow.s2.ffi).getD PTrie.nil
noncomputable def DEC_grow.kr0_0 : Host.Load.Layers.KRec := (Host.Ts.Sim.Full.krecOf DEC_grow.s2.ffi).getD Host.Load.Layers.KRec.empty
kernel_rfl DEC_grow.ofx0_0 : (Host.Ts.Sim.Full.freedOf DEC_grow.s2.ffi) = some DEC_grow.fx0_0
kernel_rfl DEC_grow.okr0_0 : (Host.Ts.Sim.Full.krecOf DEC_grow.s2.ffi) = some DEC_grow.kr0_0
noncomputable def DEC_grow.fx1_0 : PTrie Unit := (Host.Ts.Sim.Full.freedOf DEC_grow.s1.ffi).getD PTrie.nil
noncomputable def DEC_grow.kr1_0 : Host.Load.Layers.KRec := (Host.Ts.Sim.Full.krecOf DEC_grow.s1.ffi).getD Host.Load.Layers.KRec.empty
kernel_rfl DEC_grow.ofx1_0 : (Host.Ts.Sim.Full.freedOf DEC_grow.s1.ffi) = some DEC_grow.fx1_0
kernel_rfl DEC_grow.okr1_0 : (Host.Ts.Sim.Full.krecOf DEC_grow.s1.ffi) = some DEC_grow.kr1_0
kernel_rfl DEC_grow.ff00 : DEC_grow.fx0_0 = Stage.setAll DEC_grow.fxC_0 (DEC_grow.clo0.filterMap fun i => (DEC_grow.fx0_0.get i).map (i, ·))
kernel_rfl DEC_grow.ff10 : DEC_grow.fx1_0 = Stage.setAll DEC_grow.fxC_0 (DEC_grow.cwS0.filterMap fun i => (DEC_grow.fx1_0.get i).map (i, ·))
kernel_rfl DEC_grow.ffck0 : freedLB DEC_grow.kappa0 DEC_grow.cx0_0.mlx DEC_grow.fx0_0 DEC_grow.fx1_0 DEC_grow.clo0 = true
kernel_rfl DEC_grow.fkf00 : DEC_grow.kr0_0.flags = Stage.setAll DEC_grow.krC_0.flags (DEC_grow.clo0.filterMap fun i => (DEC_grow.kr0_0.flags.get i).map (i, ·))
kernel_rfl DEC_grow.fkt00 : DEC_grow.kr0_0.targs = Stage.setAll DEC_grow.krC_0.targs (DEC_grow.clo0.filterMap fun i => (DEC_grow.kr0_0.targs.get i).map (i, ·))
kernel_rfl DEC_grow.fkf10 : DEC_grow.kr1_0.flags = Stage.setAll DEC_grow.krC_0.flags (DEC_grow.cwS0.filterMap fun i => (DEC_grow.kr1_0.flags.get i).map (i, ·))
kernel_rfl DEC_grow.fkt10 : DEC_grow.kr1_0.targs = Stage.setAll DEC_grow.krC_0.targs (DEC_grow.cwS0.filterMap fun i => (DEC_grow.kr1_0.targs.get i).map (i, ·))
kernel_rfl DEC_grow.fkck0 : krecLB DEC_grow.kappa0 123 DEC_grow.cx0_0.mlx DEC_grow.kr0_0 DEC_grow.kr1_0 DEC_grow.clo0 = true
kernel_rfl DEC_grow.fkn0 : Nat.ble 123 123 = true
-- the bridge and the pending traces' regions
kernel_rfl DEC_grow.cbridge0 : Host.Ts.Sim.Full.bridgeOf DEC_grow.s1.ffi = Host.Ts.Sim.Full.bridgeOf DEC_grow.s2.ffi
kernel_rfl DEC_grow.cpendR0 : pendRegB DEC_grow.kappa0 (Host.Load.Layers.toLoad DEC_grow.s2.ffi).mlx = true
kernel_rfl DEC_grow.cpendLe0 : Nat.ble (Host.Load.Layers.toLoad DEC_grow.s2.ffi).mlx.next (Host.Load.Layers.toLoad DEC_grow.s1.ffi).mlx.next = true
/-- **The compaction's native shift**, given the call's bookkeeping, its relation's facts (the model's and the
observers') and the canonical closedness. -/
theorem DEC_grow.cshift0 (clean : Conv.NClean (⟨29302, 22539, 3123568, 123⟩ : Conv.Cnt) (Host.Load.Layers.toLoad DEC_grow.s0.ffi).mlx) (hltC : ∀ h, PH (Host.Load.Layers.toLoad DEC_grow.s0.ffi).mlx h → h < (Host.Load.Layers.toLoad DEC_grow.s0.ffi).mlx.next) (nltC : ∀ i, PN (Host.Load.Layers.toLoad DEC_grow.s0.ffi).mlx i → i < (Host.Load.Layers.toLoad DEC_grow.s0.ffi).mlx.nnext) (itemsC : ∀ k v, (Host.Load.Layers.toLoad DEC_grow.s0.ffi).mlx.items.get k = some v → PN (Host.Load.Layers.toLoad DEC_grow.s0.ffi).mlx k) (tracedC : ∀ h o, (Host.Load.Layers.toLoad DEC_grow.s0.ffi).mlx.objs.get h = some o → ∀ i ∈ objTraces o, i < DEC_grow.P0.NL) (cl : SSt (· < 123) DEC_grow.cx0_0.mlx)
    (hobjC : ∀ h, DEC_grow.fxC_0.get h = some () → ((Host.Load.Layers.toLoad DEC_grow.s0.ffi).mlx.objs.get h).isSome = true)
    (hfC : ∀ h, (DEC_grow.krC_0.flags.get h).isSome = true → ((Host.Load.Layers.toLoad DEC_grow.s0.ffi).mlx.objs.get h).isSome = true)
    (htC : ∀ h, (DEC_grow.krC_0.targs.get h).isSome = true → ((Host.Load.Layers.toLoad DEC_grow.s0.ffi).mlx.objs.get h).isSome = true)
    (hclC : ∀ h l, DEC_grow.krC_0.targs.get h = some l → Host.Ts.Sim.Full.STargs (· < (⟨29302, 22539, 3123568, 123⟩ : Conv.Cnt).n) l) :
    Conv.FullShiftQ DEC_grow.P0 123 DEC_grow.kappa0 DEC_grow.s2.ffi DEC_grow.s1.ffi :=
  ⟨DEC_grow.cnshift0 clean hltC nltC itemsC tracedC cl, DEC_grow.cqueue0, fun t ht => bSN_sound (List.all_eq_true.mp DEC_grow.ctokSupp0 t ht),
    DEC_grow.cbridge0,
    liveShift_foot (x0' := Host.Ts.Sim.Full.mlxOf DEC_grow.s2.ffi) (x1' := Host.Ts.Sim.Full.mlxOf DEC_grow.s1.ffi) (DEC_grow.cfoot0 clean hltC nltC itemsC tracedC cl) rfl DEC_grow.ofx0_0 DEC_grow.ofx1_0 hobjC DEC_grow.ff00 DEC_grow.ff10 DEC_grow.ffck0,
    kernShift_foot (x0' := Host.Ts.Sim.Full.mlxOf DEC_grow.s2.ffi) (x1' := Host.Ts.Sim.Full.mlxOf DEC_grow.s1.ffi) (DEC_grow.cfoot0 clean hltC nltC itemsC tracedC cl) rfl DEC_grow.okr0_0 DEC_grow.okr1_0 (Nat.le_of_ble_eq_true DEC_grow.fkn0) hfC htC hclC
      DEC_grow.fkf00 DEC_grow.fkt00 DEC_grow.fkf10 DEC_grow.fkt10 DEC_grow.fkck0,
    pendReg_of rfl DEC_grow.cnh00 DEC_grow.cnh10 (Nat.le_of_ble_eq_true DEC_grow.cpendLe0) DEC_grow.cpendR0⟩

end Host.Load.Run.Tpl
