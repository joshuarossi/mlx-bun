import host.sim.template.a4dec_clear.SiteCl0
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
def DEC_clear.P0 : LoadP := ⟨25000, 131072, 1099511627776, 20000, 22539, []⟩
noncomputable abbrev DEC_clear.cx0_0 : Host.Load.LSt := clearTokens (Host.Load.Layers.toLoad DEC_clear.s2.ffi)
noncomputable abbrev DEC_clear.cx1_0 : Host.Load.LSt := clearTokens (Host.Load.Layers.toLoad DEC_clear.s1.ffi)
def DEC_clear.khinv0 : PTrie Nat := Stage.setAll PTrie.nil []
def DEC_clear.kninv0 : PTrie Nat := Stage.setAll PTrie.nil []
/-- The stage's footprint: its written and fresh handles, fresh nodes, written and fresh items. -/
def DEC_clear.cwS0 : List Nat := []
def DEC_clear.cnS0 : List Nat := List.range' 22539 0
def DEC_clear.ciS0 : List Nat := [20157] ++ List.range' 22539 0

-- the small checks (`MChecks`'s)
kernel_rfl DEC_clear.cnh00 : DEC_clear.kd0.nh0 = DEC_clear.cx0_0.mlx.next
kernel_rfl DEC_clear.cnh10 : DEC_clear.kd0.nh1 = DEC_clear.cx1_0.mlx.next
kernel_rfl DEC_clear.cnn00 : DEC_clear.kd0.nn0 = DEC_clear.cx0_0.mlx.nnext
kernel_rfl DEC_clear.cnn10 : DEC_clear.kd0.nn1 = DEC_clear.cx1_0.mlx.nnext
kernel_rfl DEC_clear.cplo0 : (Nat.blt 0 DEC_clear.P0.lo && Nat.ble DEC_clear.P0.lo DEC_clear.cx0_0.mlx.next && Nat.ble DEC_clear.P0.lo RData.bigHi && Nat.ble RData.bigHi DEC_clear.P0.E) = true
kernel_rfl DEC_clear.ccnt0 : (Nat.ble DEC_clear.cx0_0.mlx.next DEC_clear.cx1_0.mlx.next && Nat.ble DEC_clear.cx0_0.mlx.nnext DEC_clear.cx1_0.mlx.nnext) = true
kernel_rfl DEC_clear.cnband0 : (Nat.blt 0 DEC_clear.P0.NL && Nat.ble DEC_clear.P0.NL DEC_clear.P0.N0 && Nat.ble DEC_clear.P0.N0 DEC_clear.cx0_0.mlx.nnext) = true
kernel_rfl DEC_clear.chbelow0 : DEC_clear.kd0.checkHndBelow = true
kernel_rfl DEC_clear.chren0 : checkRenG DEC_clear.kd0.hnd DEC_clear.khinv0 (phB DEC_clear.cx0_0.mlx) = true
kernel_rfl DEC_clear.cband0 : DEC_clear.kd0.checkBand DEC_clear.P0.lo = true
kernel_rfl DEC_clear.cnh1pos0 : Nat.blt 0 DEC_clear.kd0.nh1 = true
kernel_rfl DEC_clear.cnren0 : checkRenG DEC_clear.kd0.node DEC_clear.kninv0 (pnB DEC_clear.cx0_0.mlx) = true
kernel_rfl DEC_clear.cnlow0 : (PTrie.keysA DEC_clear.kd0.node).all (fun j => Nat.ble DEC_clear.P0.NL j && Nat.blt (DEC_clear.kd0.nodeF j) DEC_clear.cx1_0.mlx.nnext) = true
kernel_rfl DEC_clear.cabs0a0 : DEC_clear.cx0_0.mlx.arrs.get 0 = none
kernel_rfl DEC_clear.cabs0b0 : DEC_clear.cx0_0.mlx.objs.get 0 = none
kernel_rfl DEC_clear.ctok10 : DEC_clear.cx1_0.mlx.tokens = []
kernel_rfl DEC_clear.cpend0 : DEC_clear.cx1_0.mlx.pending = DEC_clear.cx0_0.mlx.pending.map DEC_clear.kappa0.pend
kernel_rfl DEC_clear.cerrh0 : DEC_clear.cx1_0.mlx.errh = DEC_clear.cx0_0.mlx.errh.map DEC_clear.kappa0.arg
kernel_rfl DEC_clear.cfiles0 : DEC_clear.cx1_0.mlx.files = DEC_clear.cx0_0.mlx.files
kernel_rfl DEC_clear.carch0 : DEC_clear.cx1_0.mlx.arch = DEC_clear.cx0_0.mlx.arch
kernel_rfl DEC_clear.csizes0 : DEC_clear.cx1_0.mlx.deviceSizes = DEC_clear.cx0_0.mlx.deviceSizes
kernel_rfl DEC_clear.cwired0 : DEC_clear.cx1_0.mlx.wired = DEC_clear.cx0_0.mlx.wired
kernel_rfl DEC_clear.chost0 : DEC_clear.cx1_0.host = DEC_clear.cx0_0.host
-- the compaction map's addresses are `DEC_clear.kd0`'s
kernel_rfl DEC_clear.ckn00 : DEC_clear.kd0.n0 = 3123568
kernel_rfl DEC_clear.ckn10 : DEC_clear.kd0.n1 = 3123580
kernel_rfl DEC_clear.ckheap0 : (PTrie.keysA DEC_clear.kd0.heap).all (fun x => Nat.ble 3123568 x) = true
kernel_rfl DEC_clear.ckpl0 : (List.range 0).all (fun j => decide (DEC_clear.kd0.heap.get (3123568 + j) = nth? DEC_clear.pl0 j)) = true
-- the map fixes the call's names (`Conv.fixOld_compact`), the call's counters
kernel_rfl DEC_clear.fja0 : Nat.ble 3123568 3123568 = true
kernel_rfl DEC_clear.fn0 : Nat.ble 123 123 = true
kernel_rfl DEC_clear.fjaD0 : Nat.ble 3123568 DEC_clear.kd0.n0 = true
kernel_rfl DEC_clear.fxn0 : Nat.ble 29302 DEC_clear.kd0.nh0 = true
kernel_rfl DEC_clear.fnn0 : Nat.ble 22539 DEC_clear.kd0.nn0 = true
kernel_rfl DEC_clear.fxb0 : Nat.ble 29302 RData.bigHi = true
kernel_rfl DEC_clear.fheap0 : (PTrie.keysA DEC_clear.kd0.heap).all (Nat.ble (⟨29302, 22539, 3123568, 123⟩ : Conv.Cnt).ja) = true
kernel_rfl DEC_clear.fhnd0 : (PTrie.keysA DEC_clear.kd0.hnd).all (Nat.ble (⟨29302, 22539, 3123568, 123⟩ : Conv.Cnt).xn) = true
kernel_rfl DEC_clear.fnode0 : (PTrie.keysA DEC_clear.kd0.node).all (Nat.ble (⟨29302, 22539, 3123568, 123⟩ : Conv.Cnt).nn) = true
/-- The compaction map fixes the call's names. -/
theorem DEC_clear.cfix0 : Conv.FixOld (⟨29302, 22539, 3123568, 123⟩ : Conv.Cnt) DEC_clear.kappa0 :=
  Conv.fixOld_compact (Nat.le_of_ble_eq_true DEC_clear.fja0) (Nat.le_of_ble_eq_true DEC_clear.fn0) (Nat.le_of_ble_eq_true DEC_clear.fjaD0) (Nat.le_of_ble_eq_true DEC_clear.fxn0) (Nat.le_of_ble_eq_true DEC_clear.fnn0) (Nat.le_of_ble_eq_true DEC_clear.fxb0) DEC_clear.fheap0 DEC_clear.fhnd0 DEC_clear.fnode0
kernel_rfl DEC_clear.fcxn0 : (⟨29302, 22539, 3123568, 123⟩ : Conv.Cnt).xn = (Host.Load.Layers.toLoad DEC_clear.s0.ffi).mlx.next
kernel_rfl DEC_clear.fcnn0 : (⟨29302, 22539, 3123568, 123⟩ : Conv.Cnt).nn = (Host.Load.Layers.toLoad DEC_clear.s0.ffi).mlx.nnext
kernel_rfl DEC_clear.fle00 : (Nat.ble (Host.Load.Layers.toLoad DEC_clear.s0.ffi).mlx.next DEC_clear.cx0_0.mlx.next && Nat.ble (Host.Load.Layers.toLoad DEC_clear.s0.ffi).mlx.nnext DEC_clear.cx0_0.mlx.nnext && Nat.ble (Host.Load.Layers.toLoad DEC_clear.s0.ffi).mlx.next RData.bigHi) = true
kernel_rfl DEC_clear.fnk0 : (PTrie.keysA DEC_clear.kd0.node).all (Nat.ble (Host.Load.Layers.toLoad DEC_clear.s0.ffi).mlx.nnext) = true
-- the merged state keeps the call's entries off the stage's footprint
kernel_rfl DEC_clear.f1A0 : DEC_clear.cx1_0.mlx.arrs = Stage.setAll (Host.Load.Layers.toLoad DEC_clear.s0.ffi).mlx.arrs (DEC_clear.cwS0.filterMap fun i => (DEC_clear.cx1_0.mlx.arrs.get i).map (i, ·))
kernel_rfl DEC_clear.f1O0 : DEC_clear.cx1_0.mlx.objs = Stage.setAll (Host.Load.Layers.toLoad DEC_clear.s0.ffi).mlx.objs (DEC_clear.cwS0.filterMap fun i => (DEC_clear.cx1_0.mlx.objs.get i).map (i, ·))
kernel_rfl DEC_clear.f1N0 : DEC_clear.cx1_0.mlx.nodes = Stage.setAll (Host.Load.Layers.toLoad DEC_clear.s0.ffi).mlx.nodes (DEC_clear.cnS0.filterMap fun i => (DEC_clear.cx1_0.mlx.nodes.get i).map (i, ·))
kernel_rfl DEC_clear.f1I0 : DEC_clear.cx1_0.mlx.items = Stage.setAll (Host.Load.Layers.toLoad DEC_clear.s0.ffi).mlx.items (DEC_clear.ciS0.filterMap fun i => (DEC_clear.cx1_0.mlx.items.get i).map (i, ·))
kernel_rfl DEC_clear.fbd0 : (DEC_clear.clo0 ++ DEC_clear.cln0 ++ DEC_clear.cli0 ++ DEC_clear.cwS0 ++ DEC_clear.cnS0 ++ DEC_clear.ciS0).all (fun i => Nat.blt (i / 4096) (4 ^ 31)) = true
kernel_rfl DEC_clear.fincW0 : DEC_clear.cwS0.all (fun h => !Nat.blt h (Host.Load.Layers.toLoad DEC_clear.s0.ffi).mlx.next || DEC_clear.clo0.contains h) = true
kernel_rfl DEC_clear.fincI0 : DEC_clear.ciS0.all (fun k => !Nat.blt k (Host.Load.Layers.toLoad DEC_clear.s0.ffi).mlx.nnext || DEC_clear.cli0.contains k) = true
kernel_rfl DEC_clear.fincN0 : DEC_clear.cnS0.all (Nat.ble (Host.Load.Layers.toLoad DEC_clear.s0.ffi).mlx.nnext) = true
kernel_rfl DEC_clear.flnF0 : DEC_clear.cln0.all (Nat.ble (Host.Load.Layers.toLoad DEC_clear.s0.ffi).mlx.nnext) = true
-- the checks over the changed lists
kernel_rfl DEC_clear.fh0 : DEC_clear.clo0.all (handleOK DEC_clear.kappa0 DEC_clear.P0.lo DEC_clear.cx0_0.mlx DEC_clear.cx1_0.mlx) = true
kernel_rfl DEC_clear.fo0 : DEC_clear.clo0.map (fun h => DEC_clear.cx1_0.mlx.objs.get (DEC_clear.kappa0.handle h)) = DEC_clear.clo0.map (fun h => (DEC_clear.cx0_0.mlx.objs.get h).map DEC_clear.kappa0.nobj)
kernel_rfl DEC_clear.fok0 : DEC_clear.clo0.all (objOK DEC_clear.kappa0 DEC_clear.P0.NL DEC_clear.cx0_0.mlx) = true
kernel_rfl DEC_clear.fnd0 : DEC_clear.cln0.all (nodeOKF DEC_clear.kappa0 DEC_clear.P0 DEC_clear.cx0_0.mlx DEC_clear.cx1_0.mlx) = true
kernel_rfl DEC_clear.fp0 : ((DEC_clear.cln0.filter (fullB DEC_clear.P0))).map (fun i => (DEC_clear.cx1_0.mlx.nodes.get (DEC_clear.kappa0.node i)).map Host.Mlx.Ffi.Node.prim) =
  ((DEC_clear.cln0.filter (fullB DEC_clear.P0))).map (fun i => (DEC_clear.cx0_0.mlx.nodes.get i).map fun nd => DEC_clear.kappa0.prim nd.prim)
kernel_rfl DEC_clear.fnordI0 : incrB DEC_clear.kd0.nodeF (List.range' 22539 0) = true
kernel_rfl DEC_clear.fnordK0 : (PTrie.keysA DEC_clear.kd0.node).all (fun k => Nat.ble 22539 k && Nat.blt k 22539) = true
kernel_rfl DEC_clear.fnordL0 : (DEC_clear.cln0.filter (Nat.ble DEC_clear.P0.N0)).all (fun i => Nat.ble i (DEC_clear.kd0.nodeF i) && (Nat.blt i 22539 || Nat.ble DEC_clear.kd0.nn0 i)) = true
theorem DEC_clear.fnord0 : (DEC_clear.cln0.filter (Nat.ble DEC_clear.P0.N0)).all (fun i => Nat.ble i (DEC_clear.kd0.nodeF i) &&
    (PTrie.keysA DEC_clear.kd0.node).all fun j => !Nat.blt j i || Nat.blt (DEC_clear.kd0.nodeF j) (DEC_clear.kd0.nodeF i)) = true :=
  cnord_of DEC_clear.cnlow0 DEC_clear.cnn10 DEC_clear.fnordI0 DEC_clear.fnordK0 DEC_clear.fnordL0
kernel_rfl DEC_clear.fi0 : DEC_clear.cli0.all (pnB DEC_clear.cx0_0.mlx) = true
kernel_rfl DEC_clear.fii0 : DEC_clear.cli0.all (fun k => decide (DEC_clear.cx1_0.mlx.items.get (DEC_clear.kappa0.node k) = (DEC_clear.cx0_0.mlx.items.get k).map DEC_clear.kappa0.nv)) = true
/-- **The compaction's footprint.** -/
theorem DEC_clear.cfoot0 (clean : Conv.NClean (⟨29302, 22539, 3123568, 123⟩ : Conv.Cnt) (Host.Load.Layers.toLoad DEC_clear.s0.ffi).mlx) (hltC : ∀ h, PH (Host.Load.Layers.toLoad DEC_clear.s0.ffi).mlx h → h < (Host.Load.Layers.toLoad DEC_clear.s0.ffi).mlx.next) (nltC : ∀ i, PN (Host.Load.Layers.toLoad DEC_clear.s0.ffi).mlx i → i < (Host.Load.Layers.toLoad DEC_clear.s0.ffi).mlx.nnext) (itemsC : ∀ k v, (Host.Load.Layers.toLoad DEC_clear.s0.ffi).mlx.items.get k = some v → PN (Host.Load.Layers.toLoad DEC_clear.s0.ffi).mlx k) (tracedC : ∀ h o, (Host.Load.Layers.toLoad DEC_clear.s0.ffi).mlx.objs.get h = some o → ∀ i ∈ objTraces o, i < DEC_clear.P0.NL) (cl : SSt (· < 123) DEC_clear.cx0_0.mlx) :
    Conv.MFoot DEC_clear.P0 123 DEC_clear.kappa0 DEC_clear.kd0 DEC_clear.khinv0 DEC_clear.kninv0 (Host.Load.Layers.toLoad DEC_clear.s0.ffi).mlx DEC_clear.cx0_0.mlx DEC_clear.cx1_0.mlx (⟨29302, 22539, 3123568, 123⟩ : Conv.Cnt) DEC_clear.clo0 DEC_clear.cln0 DEC_clear.cli0 DEC_clear.cwS0 DEC_clear.cnS0 DEC_clear.ciS0 :=
  ⟨rfl, rfl, rfl, DEC_clear.cnh00, DEC_clear.cnh10, DEC_clear.cnn00, DEC_clear.cnn10, DEC_clear.cplo0, DEC_clear.ccnt0, DEC_clear.cnband0, DEC_clear.chbelow0, DEC_clear.chren0, DEC_clear.cband0, DEC_clear.cnh1pos0, DEC_clear.cnren0, DEC_clear.cnlow0, DEC_clear.cabs0a0, DEC_clear.cabs0b0, DEC_clear.ctok10, DEC_clear.cpend0, DEC_clear.cerrh0, DEC_clear.cfiles0, DEC_clear.carch0, DEC_clear.csizes0, DEC_clear.cwired0, DEC_clear.cfix0, clean, DEC_clear.fcxn0, DEC_clear.fcnn0, hltC, nltC, itemsC, tracedC, cl, DEC_clear.fle00, DEC_clear.fnk0, DEC_clear.ckA0, DEC_clear.cobjsK0, DEC_clear.cnodesK0, DEC_clear.citemsK0, DEC_clear.f1A0, DEC_clear.f1O0, DEC_clear.f1N0, DEC_clear.f1I0, DEC_clear.fbd0, DEC_clear.fincW0, DEC_clear.fincI0, DEC_clear.fincN0, DEC_clear.flnF0, DEC_clear.fh0, DEC_clear.fo0, DEC_clear.fok0, DEC_clear.fnd0, DEC_clear.fp0, DEC_clear.fnord0, DEC_clear.fi0, DEC_clear.fii0⟩
theorem DEC_clear.cnshift0 (clean : Conv.NClean (⟨29302, 22539, 3123568, 123⟩ : Conv.Cnt) (Host.Load.Layers.toLoad DEC_clear.s0.ffi).mlx) (hltC : ∀ h, PH (Host.Load.Layers.toLoad DEC_clear.s0.ffi).mlx h → h < (Host.Load.Layers.toLoad DEC_clear.s0.ffi).mlx.next) (nltC : ∀ i, PN (Host.Load.Layers.toLoad DEC_clear.s0.ffi).mlx i → i < (Host.Load.Layers.toLoad DEC_clear.s0.ffi).mlx.nnext) (itemsC : ∀ k v, (Host.Load.Layers.toLoad DEC_clear.s0.ffi).mlx.items.get k = some v → PN (Host.Load.Layers.toLoad DEC_clear.s0.ffi).mlx k) (tracedC : ∀ h o, (Host.Load.Layers.toLoad DEC_clear.s0.ffi).mlx.objs.get h = some o → ∀ i ∈ objTraces o, i < DEC_clear.P0.NL) (cl : SSt (· < 123) DEC_clear.cx0_0.mlx) : NShift DEC_clear.P0 123 DEC_clear.kappa0 DEC_clear.cx0_0 DEC_clear.cx1_0 :=
  Conv.nshift_of_foot (DEC_clear.cfoot0 clean hltC nltC itemsC tracedC cl) DEC_clear.chost0 (compact_a_eq DEC_clear.ckn00 DEC_clear.ckn10 DEC_clear.ckheap0 DEC_clear.ckpl0)

-- the observers: the layers' states at the call, the canonical and the merged state, their footprints and checks
noncomputable def DEC_clear.fxC_0 : PTrie Unit := (Host.Ts.Sim.Full.freedOf DEC_clear.s0.ffi).getD PTrie.nil
noncomputable def DEC_clear.krC_0 : Host.Load.Layers.KRec := (Host.Ts.Sim.Full.krecOf DEC_clear.s0.ffi).getD Host.Load.Layers.KRec.empty
kernel_rfl DEC_clear.ofxC_0 : (Host.Ts.Sim.Full.freedOf DEC_clear.s0.ffi) = some DEC_clear.fxC_0
kernel_rfl DEC_clear.okrC_0 : (Host.Ts.Sim.Full.krecOf DEC_clear.s0.ffi) = some DEC_clear.krC_0
noncomputable def DEC_clear.fx0_0 : PTrie Unit := (Host.Ts.Sim.Full.freedOf DEC_clear.s2.ffi).getD PTrie.nil
noncomputable def DEC_clear.kr0_0 : Host.Load.Layers.KRec := (Host.Ts.Sim.Full.krecOf DEC_clear.s2.ffi).getD Host.Load.Layers.KRec.empty
kernel_rfl DEC_clear.ofx0_0 : (Host.Ts.Sim.Full.freedOf DEC_clear.s2.ffi) = some DEC_clear.fx0_0
kernel_rfl DEC_clear.okr0_0 : (Host.Ts.Sim.Full.krecOf DEC_clear.s2.ffi) = some DEC_clear.kr0_0
noncomputable def DEC_clear.fx1_0 : PTrie Unit := (Host.Ts.Sim.Full.freedOf DEC_clear.s1.ffi).getD PTrie.nil
noncomputable def DEC_clear.kr1_0 : Host.Load.Layers.KRec := (Host.Ts.Sim.Full.krecOf DEC_clear.s1.ffi).getD Host.Load.Layers.KRec.empty
kernel_rfl DEC_clear.ofx1_0 : (Host.Ts.Sim.Full.freedOf DEC_clear.s1.ffi) = some DEC_clear.fx1_0
kernel_rfl DEC_clear.okr1_0 : (Host.Ts.Sim.Full.krecOf DEC_clear.s1.ffi) = some DEC_clear.kr1_0
kernel_rfl DEC_clear.ff00 : DEC_clear.fx0_0 = Stage.setAll DEC_clear.fxC_0 (DEC_clear.clo0.filterMap fun i => (DEC_clear.fx0_0.get i).map (i, ·))
kernel_rfl DEC_clear.ff10 : DEC_clear.fx1_0 = Stage.setAll DEC_clear.fxC_0 (DEC_clear.cwS0.filterMap fun i => (DEC_clear.fx1_0.get i).map (i, ·))
kernel_rfl DEC_clear.ffck0 : freedLB DEC_clear.kappa0 DEC_clear.cx0_0.mlx DEC_clear.fx0_0 DEC_clear.fx1_0 DEC_clear.clo0 = true
kernel_rfl DEC_clear.fkf00 : DEC_clear.kr0_0.flags = Stage.setAll DEC_clear.krC_0.flags (DEC_clear.clo0.filterMap fun i => (DEC_clear.kr0_0.flags.get i).map (i, ·))
kernel_rfl DEC_clear.fkt00 : DEC_clear.kr0_0.targs = Stage.setAll DEC_clear.krC_0.targs (DEC_clear.clo0.filterMap fun i => (DEC_clear.kr0_0.targs.get i).map (i, ·))
kernel_rfl DEC_clear.fkf10 : DEC_clear.kr1_0.flags = Stage.setAll DEC_clear.krC_0.flags (DEC_clear.cwS0.filterMap fun i => (DEC_clear.kr1_0.flags.get i).map (i, ·))
kernel_rfl DEC_clear.fkt10 : DEC_clear.kr1_0.targs = Stage.setAll DEC_clear.krC_0.targs (DEC_clear.cwS0.filterMap fun i => (DEC_clear.kr1_0.targs.get i).map (i, ·))
kernel_rfl DEC_clear.fkck0 : krecLB DEC_clear.kappa0 123 DEC_clear.cx0_0.mlx DEC_clear.kr0_0 DEC_clear.kr1_0 DEC_clear.clo0 = true
kernel_rfl DEC_clear.fkn0 : Nat.ble 123 123 = true
-- the bridge and the pending traces' regions
kernel_rfl DEC_clear.cbridge0 : Host.Ts.Sim.Full.bridgeOf DEC_clear.s1.ffi = Host.Ts.Sim.Full.bridgeOf DEC_clear.s2.ffi
kernel_rfl DEC_clear.cpendR0 : pendRegB DEC_clear.kappa0 (Host.Load.Layers.toLoad DEC_clear.s2.ffi).mlx = true
kernel_rfl DEC_clear.cpendLe0 : Nat.ble (Host.Load.Layers.toLoad DEC_clear.s2.ffi).mlx.next (Host.Load.Layers.toLoad DEC_clear.s1.ffi).mlx.next = true
/-- **The compaction's native shift**, given the call's bookkeeping, its relation's facts (the model's and the
observers') and the canonical closedness. -/
theorem DEC_clear.cshift0 (clean : Conv.NClean (⟨29302, 22539, 3123568, 123⟩ : Conv.Cnt) (Host.Load.Layers.toLoad DEC_clear.s0.ffi).mlx) (hltC : ∀ h, PH (Host.Load.Layers.toLoad DEC_clear.s0.ffi).mlx h → h < (Host.Load.Layers.toLoad DEC_clear.s0.ffi).mlx.next) (nltC : ∀ i, PN (Host.Load.Layers.toLoad DEC_clear.s0.ffi).mlx i → i < (Host.Load.Layers.toLoad DEC_clear.s0.ffi).mlx.nnext) (itemsC : ∀ k v, (Host.Load.Layers.toLoad DEC_clear.s0.ffi).mlx.items.get k = some v → PN (Host.Load.Layers.toLoad DEC_clear.s0.ffi).mlx k) (tracedC : ∀ h o, (Host.Load.Layers.toLoad DEC_clear.s0.ffi).mlx.objs.get h = some o → ∀ i ∈ objTraces o, i < DEC_clear.P0.NL) (cl : SSt (· < 123) DEC_clear.cx0_0.mlx)
    (hobjC : ∀ h, DEC_clear.fxC_0.get h = some () → ((Host.Load.Layers.toLoad DEC_clear.s0.ffi).mlx.objs.get h).isSome = true)
    (hfC : ∀ h, (DEC_clear.krC_0.flags.get h).isSome = true → ((Host.Load.Layers.toLoad DEC_clear.s0.ffi).mlx.objs.get h).isSome = true)
    (htC : ∀ h, (DEC_clear.krC_0.targs.get h).isSome = true → ((Host.Load.Layers.toLoad DEC_clear.s0.ffi).mlx.objs.get h).isSome = true)
    (hclC : ∀ h l, DEC_clear.krC_0.targs.get h = some l → Host.Ts.Sim.Full.STargs (· < (⟨29302, 22539, 3123568, 123⟩ : Conv.Cnt).n) l) :
    Conv.FullShiftQ DEC_clear.P0 123 DEC_clear.kappa0 DEC_clear.s2.ffi DEC_clear.s1.ffi :=
  ⟨DEC_clear.cnshift0 clean hltC nltC itemsC tracedC cl, DEC_clear.cqueue0, fun t ht => bSN_sound (List.all_eq_true.mp DEC_clear.ctokSupp0 t ht),
    DEC_clear.cbridge0,
    liveShift_foot (x0' := Host.Ts.Sim.Full.mlxOf DEC_clear.s2.ffi) (x1' := Host.Ts.Sim.Full.mlxOf DEC_clear.s1.ffi) (DEC_clear.cfoot0 clean hltC nltC itemsC tracedC cl) rfl DEC_clear.ofx0_0 DEC_clear.ofx1_0 hobjC DEC_clear.ff00 DEC_clear.ff10 DEC_clear.ffck0,
    kernShift_foot (x0' := Host.Ts.Sim.Full.mlxOf DEC_clear.s2.ffi) (x1' := Host.Ts.Sim.Full.mlxOf DEC_clear.s1.ffi) (DEC_clear.cfoot0 clean hltC nltC itemsC tracedC cl) rfl DEC_clear.okr0_0 DEC_clear.okr1_0 (Nat.le_of_ble_eq_true DEC_clear.fkn0) hfC htC hclC
      DEC_clear.fkf00 DEC_clear.fkt00 DEC_clear.fkf10 DEC_clear.fkt10 DEC_clear.fkck0,
    pendReg_of rfl DEC_clear.cnh00 DEC_clear.cnh10 (Nat.le_of_ble_eq_true DEC_clear.cpendLe0) DEC_clear.cpendR0⟩

end Host.Load.Run.Tpl
