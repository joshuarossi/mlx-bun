import host.sim.template.a4dec_clearGrow.SiteCl2
import host.sim.conv.CompactFull
import host.sim.template.FootGen
set_option Elab.async false
namespace Host.Load.Run.Tpl
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
open Host.Ts Host.Ts.Sim Host.Ts.Sim.Template

/-! The compaction's native shift at call site 2 from its footprint (`Conv.nshift_of_foot`), and the observers'
(`liveShift_foot`, `kernShift_foot`): `Conv.FullShiftQ` for `Conv.full_compactQ`, given the call's bookkeeping and its
relation's facts. -/

/-- The load parameters of the chain (its start's node counter as `NL` and `N0`). -/
def DEC_clearGrow.P2 : LoadP := ⟨25000, 131072, 1099511627776, 20000, 22539, []⟩
noncomputable abbrev DEC_clearGrow.cx0_2 : Host.Load.LSt := clearTokens (Host.Load.Layers.toLoad DEC_clearGrow.s10.ffi)
noncomputable abbrev DEC_clearGrow.cx1_2 : Host.Load.LSt := clearTokens (Host.Load.Layers.toLoad DEC_clearGrow.s9.ffi)
def DEC_clearGrow.khinv2 : PTrie Nat := Stage.setAll PTrie.nil []
def DEC_clearGrow.kninv2 : PTrie Nat := Stage.setAll PTrie.nil []
/-- The stage's footprint: its written and fresh handles, fresh nodes, written and fresh items. -/
def DEC_clearGrow.cwS2 : List Nat := [29440]
def DEC_clearGrow.cnS2 : List Nat := List.range' 24984 0
def DEC_clearGrow.ciS2 : List Nat := [] ++ List.range' 24984 0

-- the small checks (`MChecks`'s)
kernel_rfl DEC_clearGrow.cnh02 : DEC_clearGrow.kd2.nh0 = DEC_clearGrow.cx0_2.mlx.next
kernel_rfl DEC_clearGrow.cnh12 : DEC_clearGrow.kd2.nh1 = DEC_clearGrow.cx1_2.mlx.next
kernel_rfl DEC_clearGrow.cnn02 : DEC_clearGrow.kd2.nn0 = DEC_clearGrow.cx0_2.mlx.nnext
kernel_rfl DEC_clearGrow.cnn12 : DEC_clearGrow.kd2.nn1 = DEC_clearGrow.cx1_2.mlx.nnext
kernel_rfl DEC_clearGrow.cplo2 : (Nat.blt 0 DEC_clearGrow.P2.lo && Nat.ble DEC_clearGrow.P2.lo DEC_clearGrow.cx0_2.mlx.next && Nat.ble DEC_clearGrow.P2.lo RData.bigHi && Nat.ble RData.bigHi DEC_clearGrow.P2.E) = true
kernel_rfl DEC_clearGrow.ccnt2 : (Nat.ble DEC_clearGrow.cx0_2.mlx.next DEC_clearGrow.cx1_2.mlx.next && Nat.ble DEC_clearGrow.cx0_2.mlx.nnext DEC_clearGrow.cx1_2.mlx.nnext) = true
kernel_rfl DEC_clearGrow.cnband2 : (Nat.blt 0 DEC_clearGrow.P2.NL && Nat.ble DEC_clearGrow.P2.NL DEC_clearGrow.P2.N0 && Nat.ble DEC_clearGrow.P2.N0 DEC_clearGrow.cx0_2.mlx.nnext) = true
kernel_rfl DEC_clearGrow.chbelow2 : DEC_clearGrow.kd2.checkHndBelow = true
kernel_rfl DEC_clearGrow.chren2 : checkRenG DEC_clearGrow.kd2.hnd DEC_clearGrow.khinv2 (phB DEC_clearGrow.cx0_2.mlx) = true
kernel_rfl DEC_clearGrow.cband2 : DEC_clearGrow.kd2.checkBand DEC_clearGrow.P2.lo = true
kernel_rfl DEC_clearGrow.cnh1pos2 : Nat.blt 0 DEC_clearGrow.kd2.nh1 = true
kernel_rfl DEC_clearGrow.cnren2 : checkRenG DEC_clearGrow.kd2.node DEC_clearGrow.kninv2 (pnB DEC_clearGrow.cx0_2.mlx) = true
kernel_rfl DEC_clearGrow.cnlow2 : (PTrie.keysA DEC_clearGrow.kd2.node).all (fun j => Nat.ble DEC_clearGrow.P2.NL j && Nat.blt (DEC_clearGrow.kd2.nodeF j) DEC_clearGrow.cx1_2.mlx.nnext) = true
kernel_rfl DEC_clearGrow.cabs0a2 : DEC_clearGrow.cx0_2.mlx.arrs.get 0 = none
kernel_rfl DEC_clearGrow.cabs0b2 : DEC_clearGrow.cx0_2.mlx.objs.get 0 = none
kernel_rfl DEC_clearGrow.ctok12 : DEC_clearGrow.cx1_2.mlx.tokens = []
kernel_rfl DEC_clearGrow.cpend2 : DEC_clearGrow.cx1_2.mlx.pending = DEC_clearGrow.cx0_2.mlx.pending.map DEC_clearGrow.kappa2.pend
kernel_rfl DEC_clearGrow.cerrh2 : DEC_clearGrow.cx1_2.mlx.errh = DEC_clearGrow.cx0_2.mlx.errh.map DEC_clearGrow.kappa2.arg
kernel_rfl DEC_clearGrow.cfiles2 : DEC_clearGrow.cx1_2.mlx.files = DEC_clearGrow.cx0_2.mlx.files
kernel_rfl DEC_clearGrow.carch2 : DEC_clearGrow.cx1_2.mlx.arch = DEC_clearGrow.cx0_2.mlx.arch
kernel_rfl DEC_clearGrow.csizes2 : DEC_clearGrow.cx1_2.mlx.deviceSizes = DEC_clearGrow.cx0_2.mlx.deviceSizes
kernel_rfl DEC_clearGrow.cwired2 : DEC_clearGrow.cx1_2.mlx.wired = DEC_clearGrow.cx0_2.mlx.wired
kernel_rfl DEC_clearGrow.chost2 : DEC_clearGrow.cx1_2.host = DEC_clearGrow.cx0_2.host
-- the compaction map's addresses are `DEC_clearGrow.kd2`'s
kernel_rfl DEC_clearGrow.ckn02 : DEC_clearGrow.kd2.n0 = 3124248
kernel_rfl DEC_clearGrow.ckn12 : DEC_clearGrow.kd2.n1 = 3124267
kernel_rfl DEC_clearGrow.ckheap2 : (PTrie.keysA DEC_clearGrow.kd2.heap).all (fun x => Nat.ble 3124248 x) = true
kernel_rfl DEC_clearGrow.ckpl2 : (List.range 0).all (fun j => decide (DEC_clearGrow.kd2.heap.get (3124248 + j) = nth? DEC_clearGrow.pl2 j)) = true
-- the map fixes the call's names (`Conv.fixOld_compact`), the call's counters
kernel_rfl DEC_clearGrow.fja2 : Nat.ble 3124248 3124248 = true
kernel_rfl DEC_clearGrow.fn2 : Nat.ble 386 386 = true
kernel_rfl DEC_clearGrow.fjaD2 : Nat.ble 3124248 DEC_clearGrow.kd2.n0 = true
kernel_rfl DEC_clearGrow.fxn2 : Nat.ble 29440 DEC_clearGrow.kd2.nh0 = true
kernel_rfl DEC_clearGrow.fnn2 : Nat.ble 24984 DEC_clearGrow.kd2.nn0 = true
kernel_rfl DEC_clearGrow.fxb2 : Nat.ble 29440 RData.bigHi = true
kernel_rfl DEC_clearGrow.fheap2 : (PTrie.keysA DEC_clearGrow.kd2.heap).all (Nat.ble (⟨29440, 24984, 3124248, 386⟩ : Conv.Cnt).ja) = true
kernel_rfl DEC_clearGrow.fhnd2 : (PTrie.keysA DEC_clearGrow.kd2.hnd).all (Nat.ble (⟨29440, 24984, 3124248, 386⟩ : Conv.Cnt).xn) = true
kernel_rfl DEC_clearGrow.fnode2 : (PTrie.keysA DEC_clearGrow.kd2.node).all (Nat.ble (⟨29440, 24984, 3124248, 386⟩ : Conv.Cnt).nn) = true
/-- The compaction map fixes the call's names. -/
theorem DEC_clearGrow.cfix2 : Conv.FixOld (⟨29440, 24984, 3124248, 386⟩ : Conv.Cnt) DEC_clearGrow.kappa2 :=
  Conv.fixOld_compact (Nat.le_of_ble_eq_true DEC_clearGrow.fja2) (Nat.le_of_ble_eq_true DEC_clearGrow.fn2) (Nat.le_of_ble_eq_true DEC_clearGrow.fjaD2) (Nat.le_of_ble_eq_true DEC_clearGrow.fxn2) (Nat.le_of_ble_eq_true DEC_clearGrow.fnn2) (Nat.le_of_ble_eq_true DEC_clearGrow.fxb2) DEC_clearGrow.fheap2 DEC_clearGrow.fhnd2 DEC_clearGrow.fnode2
kernel_rfl DEC_clearGrow.fcxn2 : (⟨29440, 24984, 3124248, 386⟩ : Conv.Cnt).xn = (Host.Load.Layers.toLoad DEC_clearGrow.s8.ffi).mlx.next
kernel_rfl DEC_clearGrow.fcnn2 : (⟨29440, 24984, 3124248, 386⟩ : Conv.Cnt).nn = (Host.Load.Layers.toLoad DEC_clearGrow.s8.ffi).mlx.nnext
kernel_rfl DEC_clearGrow.fle02 : (Nat.ble (Host.Load.Layers.toLoad DEC_clearGrow.s8.ffi).mlx.next DEC_clearGrow.cx0_2.mlx.next && Nat.ble (Host.Load.Layers.toLoad DEC_clearGrow.s8.ffi).mlx.nnext DEC_clearGrow.cx0_2.mlx.nnext && Nat.ble (Host.Load.Layers.toLoad DEC_clearGrow.s8.ffi).mlx.next RData.bigHi) = true
kernel_rfl DEC_clearGrow.fnk2 : (PTrie.keysA DEC_clearGrow.kd2.node).all (Nat.ble (Host.Load.Layers.toLoad DEC_clearGrow.s8.ffi).mlx.nnext) = true
-- the merged state keeps the call's entries off the stage's footprint
kernel_rfl DEC_clearGrow.f1A2 : DEC_clearGrow.cx1_2.mlx.arrs = Stage.setAll (Host.Load.Layers.toLoad DEC_clearGrow.s8.ffi).mlx.arrs (DEC_clearGrow.cwS2.filterMap fun i => (DEC_clearGrow.cx1_2.mlx.arrs.get i).map (i, ·))
kernel_rfl DEC_clearGrow.f1O2 : DEC_clearGrow.cx1_2.mlx.objs = Stage.setAll (Host.Load.Layers.toLoad DEC_clearGrow.s8.ffi).mlx.objs (DEC_clearGrow.cwS2.filterMap fun i => (DEC_clearGrow.cx1_2.mlx.objs.get i).map (i, ·))
kernel_rfl DEC_clearGrow.f1N2 : DEC_clearGrow.cx1_2.mlx.nodes = Stage.setAll (Host.Load.Layers.toLoad DEC_clearGrow.s8.ffi).mlx.nodes (DEC_clearGrow.cnS2.filterMap fun i => (DEC_clearGrow.cx1_2.mlx.nodes.get i).map (i, ·))
kernel_rfl DEC_clearGrow.f1I2 : DEC_clearGrow.cx1_2.mlx.items = Stage.setAll (Host.Load.Layers.toLoad DEC_clearGrow.s8.ffi).mlx.items (DEC_clearGrow.ciS2.filterMap fun i => (DEC_clearGrow.cx1_2.mlx.items.get i).map (i, ·))
kernel_rfl DEC_clearGrow.fbd2 : (DEC_clearGrow.clo2 ++ DEC_clearGrow.cln2 ++ DEC_clearGrow.cli2 ++ DEC_clearGrow.cwS2 ++ DEC_clearGrow.cnS2 ++ DEC_clearGrow.ciS2).all (fun i => Nat.blt (i / 4096) (4 ^ 31)) = true
kernel_rfl DEC_clearGrow.fincW2 : DEC_clearGrow.cwS2.all (fun h => !Nat.blt h (Host.Load.Layers.toLoad DEC_clearGrow.s8.ffi).mlx.next || DEC_clearGrow.clo2.contains h) = true
kernel_rfl DEC_clearGrow.fincI2 : DEC_clearGrow.ciS2.all (fun k => !Nat.blt k (Host.Load.Layers.toLoad DEC_clearGrow.s8.ffi).mlx.nnext || DEC_clearGrow.cli2.contains k) = true
kernel_rfl DEC_clearGrow.fincN2 : DEC_clearGrow.cnS2.all (Nat.ble (Host.Load.Layers.toLoad DEC_clearGrow.s8.ffi).mlx.nnext) = true
kernel_rfl DEC_clearGrow.flnF2 : DEC_clearGrow.cln2.all (Nat.ble (Host.Load.Layers.toLoad DEC_clearGrow.s8.ffi).mlx.nnext) = true
-- the checks over the changed lists
kernel_rfl DEC_clearGrow.fh2 : DEC_clearGrow.clo2.all (handleOK DEC_clearGrow.kappa2 DEC_clearGrow.P2.lo DEC_clearGrow.cx0_2.mlx DEC_clearGrow.cx1_2.mlx) = true
kernel_rfl DEC_clearGrow.fo2 : DEC_clearGrow.clo2.map (fun h => DEC_clearGrow.cx1_2.mlx.objs.get (DEC_clearGrow.kappa2.handle h)) = DEC_clearGrow.clo2.map (fun h => (DEC_clearGrow.cx0_2.mlx.objs.get h).map DEC_clearGrow.kappa2.nobj)
kernel_rfl DEC_clearGrow.fok2 : DEC_clearGrow.clo2.all (objOK DEC_clearGrow.kappa2 DEC_clearGrow.P2.NL DEC_clearGrow.cx0_2.mlx) = true
kernel_rfl DEC_clearGrow.fnd2 : DEC_clearGrow.cln2.all (nodeOKF DEC_clearGrow.kappa2 DEC_clearGrow.P2 DEC_clearGrow.cx0_2.mlx DEC_clearGrow.cx1_2.mlx) = true
kernel_rfl DEC_clearGrow.fp2 : ((DEC_clearGrow.cln2.filter (fullB DEC_clearGrow.P2))).map (fun i => (DEC_clearGrow.cx1_2.mlx.nodes.get (DEC_clearGrow.kappa2.node i)).map Host.Mlx.Ffi.Node.prim) =
  ((DEC_clearGrow.cln2.filter (fullB DEC_clearGrow.P2))).map (fun i => (DEC_clearGrow.cx0_2.mlx.nodes.get i).map fun nd => DEC_clearGrow.kappa2.prim nd.prim)
kernel_rfl DEC_clearGrow.fnordI2 : incrB DEC_clearGrow.kd2.nodeF (List.range' 24984 0) = true
kernel_rfl DEC_clearGrow.fnordK2 : (PTrie.keysA DEC_clearGrow.kd2.node).all (fun k => Nat.ble 24984 k && Nat.blt k 24984) = true
kernel_rfl DEC_clearGrow.fnordL2 : (DEC_clearGrow.cln2.filter (Nat.ble DEC_clearGrow.P2.N0)).all (fun i => Nat.ble i (DEC_clearGrow.kd2.nodeF i) && (Nat.blt i 24984 || Nat.ble DEC_clearGrow.kd2.nn0 i)) = true
theorem DEC_clearGrow.fnord2 : (DEC_clearGrow.cln2.filter (Nat.ble DEC_clearGrow.P2.N0)).all (fun i => Nat.ble i (DEC_clearGrow.kd2.nodeF i) &&
    (PTrie.keysA DEC_clearGrow.kd2.node).all fun j => !Nat.blt j i || Nat.blt (DEC_clearGrow.kd2.nodeF j) (DEC_clearGrow.kd2.nodeF i)) = true :=
  cnord_of DEC_clearGrow.cnlow2 DEC_clearGrow.cnn12 DEC_clearGrow.fnordI2 DEC_clearGrow.fnordK2 DEC_clearGrow.fnordL2
kernel_rfl DEC_clearGrow.fi2 : DEC_clearGrow.cli2.all (pnB DEC_clearGrow.cx0_2.mlx) = true
kernel_rfl DEC_clearGrow.fii2 : DEC_clearGrow.cli2.all (fun k => decide (DEC_clearGrow.cx1_2.mlx.items.get (DEC_clearGrow.kappa2.node k) = (DEC_clearGrow.cx0_2.mlx.items.get k).map DEC_clearGrow.kappa2.nv)) = true
/-- **The compaction's footprint.** -/
theorem DEC_clearGrow.cfoot2 (clean : Conv.NClean (⟨29440, 24984, 3124248, 386⟩ : Conv.Cnt) (Host.Load.Layers.toLoad DEC_clearGrow.s8.ffi).mlx) (hltC : ∀ h, PH (Host.Load.Layers.toLoad DEC_clearGrow.s8.ffi).mlx h → h < (Host.Load.Layers.toLoad DEC_clearGrow.s8.ffi).mlx.next) (nltC : ∀ i, PN (Host.Load.Layers.toLoad DEC_clearGrow.s8.ffi).mlx i → i < (Host.Load.Layers.toLoad DEC_clearGrow.s8.ffi).mlx.nnext) (itemsC : ∀ k v, (Host.Load.Layers.toLoad DEC_clearGrow.s8.ffi).mlx.items.get k = some v → PN (Host.Load.Layers.toLoad DEC_clearGrow.s8.ffi).mlx k) (tracedC : ∀ h o, (Host.Load.Layers.toLoad DEC_clearGrow.s8.ffi).mlx.objs.get h = some o → ∀ i ∈ objTraces o, i < DEC_clearGrow.P2.NL) (cl : SSt (· < 386) DEC_clearGrow.cx0_2.mlx) :
    Conv.MFoot DEC_clearGrow.P2 386 DEC_clearGrow.kappa2 DEC_clearGrow.kd2 DEC_clearGrow.khinv2 DEC_clearGrow.kninv2 (Host.Load.Layers.toLoad DEC_clearGrow.s8.ffi).mlx DEC_clearGrow.cx0_2.mlx DEC_clearGrow.cx1_2.mlx (⟨29440, 24984, 3124248, 386⟩ : Conv.Cnt) DEC_clearGrow.clo2 DEC_clearGrow.cln2 DEC_clearGrow.cli2 DEC_clearGrow.cwS2 DEC_clearGrow.cnS2 DEC_clearGrow.ciS2 :=
  ⟨rfl, rfl, rfl, DEC_clearGrow.cnh02, DEC_clearGrow.cnh12, DEC_clearGrow.cnn02, DEC_clearGrow.cnn12, DEC_clearGrow.cplo2, DEC_clearGrow.ccnt2, DEC_clearGrow.cnband2, DEC_clearGrow.chbelow2, DEC_clearGrow.chren2, DEC_clearGrow.cband2, DEC_clearGrow.cnh1pos2, DEC_clearGrow.cnren2, DEC_clearGrow.cnlow2, DEC_clearGrow.cabs0a2, DEC_clearGrow.cabs0b2, DEC_clearGrow.ctok12, DEC_clearGrow.cpend2, DEC_clearGrow.cerrh2, DEC_clearGrow.cfiles2, DEC_clearGrow.carch2, DEC_clearGrow.csizes2, DEC_clearGrow.cwired2, DEC_clearGrow.cfix2, clean, DEC_clearGrow.fcxn2, DEC_clearGrow.fcnn2, hltC, nltC, itemsC, tracedC, cl, DEC_clearGrow.fle02, DEC_clearGrow.fnk2, DEC_clearGrow.ckA2, DEC_clearGrow.cobjsK2, DEC_clearGrow.cnodesK2, DEC_clearGrow.citemsK2, DEC_clearGrow.f1A2, DEC_clearGrow.f1O2, DEC_clearGrow.f1N2, DEC_clearGrow.f1I2, DEC_clearGrow.fbd2, DEC_clearGrow.fincW2, DEC_clearGrow.fincI2, DEC_clearGrow.fincN2, DEC_clearGrow.flnF2, DEC_clearGrow.fh2, DEC_clearGrow.fo2, DEC_clearGrow.fok2, DEC_clearGrow.fnd2, DEC_clearGrow.fp2, DEC_clearGrow.fnord2, DEC_clearGrow.fi2, DEC_clearGrow.fii2⟩
theorem DEC_clearGrow.cnshift2 (clean : Conv.NClean (⟨29440, 24984, 3124248, 386⟩ : Conv.Cnt) (Host.Load.Layers.toLoad DEC_clearGrow.s8.ffi).mlx) (hltC : ∀ h, PH (Host.Load.Layers.toLoad DEC_clearGrow.s8.ffi).mlx h → h < (Host.Load.Layers.toLoad DEC_clearGrow.s8.ffi).mlx.next) (nltC : ∀ i, PN (Host.Load.Layers.toLoad DEC_clearGrow.s8.ffi).mlx i → i < (Host.Load.Layers.toLoad DEC_clearGrow.s8.ffi).mlx.nnext) (itemsC : ∀ k v, (Host.Load.Layers.toLoad DEC_clearGrow.s8.ffi).mlx.items.get k = some v → PN (Host.Load.Layers.toLoad DEC_clearGrow.s8.ffi).mlx k) (tracedC : ∀ h o, (Host.Load.Layers.toLoad DEC_clearGrow.s8.ffi).mlx.objs.get h = some o → ∀ i ∈ objTraces o, i < DEC_clearGrow.P2.NL) (cl : SSt (· < 386) DEC_clearGrow.cx0_2.mlx) : NShift DEC_clearGrow.P2 386 DEC_clearGrow.kappa2 DEC_clearGrow.cx0_2 DEC_clearGrow.cx1_2 :=
  Conv.nshift_of_foot (DEC_clearGrow.cfoot2 clean hltC nltC itemsC tracedC cl) DEC_clearGrow.chost2 (compact_a_eq DEC_clearGrow.ckn02 DEC_clearGrow.ckn12 DEC_clearGrow.ckheap2 DEC_clearGrow.ckpl2)

-- the observers: the layers' states at the call, the canonical and the merged state, their footprints and checks
noncomputable def DEC_clearGrow.fxC_2 : PTrie Unit := (Host.Ts.Sim.Full.freedOf DEC_clearGrow.s8.ffi).getD PTrie.nil
noncomputable def DEC_clearGrow.krC_2 : Host.Load.Layers.KRec := (Host.Ts.Sim.Full.krecOf DEC_clearGrow.s8.ffi).getD Host.Load.Layers.KRec.empty
kernel_rfl DEC_clearGrow.ofxC_2 : (Host.Ts.Sim.Full.freedOf DEC_clearGrow.s8.ffi) = some DEC_clearGrow.fxC_2
kernel_rfl DEC_clearGrow.okrC_2 : (Host.Ts.Sim.Full.krecOf DEC_clearGrow.s8.ffi) = some DEC_clearGrow.krC_2
noncomputable def DEC_clearGrow.fx0_2 : PTrie Unit := (Host.Ts.Sim.Full.freedOf DEC_clearGrow.s10.ffi).getD PTrie.nil
noncomputable def DEC_clearGrow.kr0_2 : Host.Load.Layers.KRec := (Host.Ts.Sim.Full.krecOf DEC_clearGrow.s10.ffi).getD Host.Load.Layers.KRec.empty
kernel_rfl DEC_clearGrow.ofx0_2 : (Host.Ts.Sim.Full.freedOf DEC_clearGrow.s10.ffi) = some DEC_clearGrow.fx0_2
kernel_rfl DEC_clearGrow.okr0_2 : (Host.Ts.Sim.Full.krecOf DEC_clearGrow.s10.ffi) = some DEC_clearGrow.kr0_2
noncomputable def DEC_clearGrow.fx1_2 : PTrie Unit := (Host.Ts.Sim.Full.freedOf DEC_clearGrow.s9.ffi).getD PTrie.nil
noncomputable def DEC_clearGrow.kr1_2 : Host.Load.Layers.KRec := (Host.Ts.Sim.Full.krecOf DEC_clearGrow.s9.ffi).getD Host.Load.Layers.KRec.empty
kernel_rfl DEC_clearGrow.ofx1_2 : (Host.Ts.Sim.Full.freedOf DEC_clearGrow.s9.ffi) = some DEC_clearGrow.fx1_2
kernel_rfl DEC_clearGrow.okr1_2 : (Host.Ts.Sim.Full.krecOf DEC_clearGrow.s9.ffi) = some DEC_clearGrow.kr1_2
kernel_rfl DEC_clearGrow.ff02 : DEC_clearGrow.fx0_2 = Stage.setAll DEC_clearGrow.fxC_2 (DEC_clearGrow.clo2.filterMap fun i => (DEC_clearGrow.fx0_2.get i).map (i, ·))
kernel_rfl DEC_clearGrow.ff12 : DEC_clearGrow.fx1_2 = Stage.setAll DEC_clearGrow.fxC_2 (DEC_clearGrow.cwS2.filterMap fun i => (DEC_clearGrow.fx1_2.get i).map (i, ·))
kernel_rfl DEC_clearGrow.ffck2 : freedLB DEC_clearGrow.kappa2 DEC_clearGrow.cx0_2.mlx DEC_clearGrow.fx0_2 DEC_clearGrow.fx1_2 DEC_clearGrow.clo2 = true
kernel_rfl DEC_clearGrow.fkf02 : DEC_clearGrow.kr0_2.flags = Stage.setAll DEC_clearGrow.krC_2.flags (DEC_clearGrow.clo2.filterMap fun i => (DEC_clearGrow.kr0_2.flags.get i).map (i, ·))
kernel_rfl DEC_clearGrow.fkt02 : DEC_clearGrow.kr0_2.targs = Stage.setAll DEC_clearGrow.krC_2.targs (DEC_clearGrow.clo2.filterMap fun i => (DEC_clearGrow.kr0_2.targs.get i).map (i, ·))
kernel_rfl DEC_clearGrow.fkf12 : DEC_clearGrow.kr1_2.flags = Stage.setAll DEC_clearGrow.krC_2.flags (DEC_clearGrow.cwS2.filterMap fun i => (DEC_clearGrow.kr1_2.flags.get i).map (i, ·))
kernel_rfl DEC_clearGrow.fkt12 : DEC_clearGrow.kr1_2.targs = Stage.setAll DEC_clearGrow.krC_2.targs (DEC_clearGrow.cwS2.filterMap fun i => (DEC_clearGrow.kr1_2.targs.get i).map (i, ·))
kernel_rfl DEC_clearGrow.fkck2 : krecLB DEC_clearGrow.kappa2 386 DEC_clearGrow.cx0_2.mlx DEC_clearGrow.kr0_2 DEC_clearGrow.kr1_2 DEC_clearGrow.clo2 = true
kernel_rfl DEC_clearGrow.fkn2 : Nat.ble 386 386 = true
-- the bridge and the pending traces' regions
kernel_rfl DEC_clearGrow.cbridge2 : Host.Ts.Sim.Full.bridgeOf DEC_clearGrow.s9.ffi = Host.Ts.Sim.Full.bridgeOf DEC_clearGrow.s10.ffi
kernel_rfl DEC_clearGrow.cpendR2 : pendRegB DEC_clearGrow.kappa2 (Host.Load.Layers.toLoad DEC_clearGrow.s10.ffi).mlx = true
kernel_rfl DEC_clearGrow.cpendLe2 : Nat.ble (Host.Load.Layers.toLoad DEC_clearGrow.s10.ffi).mlx.next (Host.Load.Layers.toLoad DEC_clearGrow.s9.ffi).mlx.next = true
/-- **The compaction's native shift**, given the call's bookkeeping, its relation's facts (the model's and the
observers') and the canonical closedness. -/
theorem DEC_clearGrow.cshift2 (clean : Conv.NClean (⟨29440, 24984, 3124248, 386⟩ : Conv.Cnt) (Host.Load.Layers.toLoad DEC_clearGrow.s8.ffi).mlx) (hltC : ∀ h, PH (Host.Load.Layers.toLoad DEC_clearGrow.s8.ffi).mlx h → h < (Host.Load.Layers.toLoad DEC_clearGrow.s8.ffi).mlx.next) (nltC : ∀ i, PN (Host.Load.Layers.toLoad DEC_clearGrow.s8.ffi).mlx i → i < (Host.Load.Layers.toLoad DEC_clearGrow.s8.ffi).mlx.nnext) (itemsC : ∀ k v, (Host.Load.Layers.toLoad DEC_clearGrow.s8.ffi).mlx.items.get k = some v → PN (Host.Load.Layers.toLoad DEC_clearGrow.s8.ffi).mlx k) (tracedC : ∀ h o, (Host.Load.Layers.toLoad DEC_clearGrow.s8.ffi).mlx.objs.get h = some o → ∀ i ∈ objTraces o, i < DEC_clearGrow.P2.NL) (cl : SSt (· < 386) DEC_clearGrow.cx0_2.mlx)
    (hobjC : ∀ h, DEC_clearGrow.fxC_2.get h = some () → ((Host.Load.Layers.toLoad DEC_clearGrow.s8.ffi).mlx.objs.get h).isSome = true)
    (hfC : ∀ h, (DEC_clearGrow.krC_2.flags.get h).isSome = true → ((Host.Load.Layers.toLoad DEC_clearGrow.s8.ffi).mlx.objs.get h).isSome = true)
    (htC : ∀ h, (DEC_clearGrow.krC_2.targs.get h).isSome = true → ((Host.Load.Layers.toLoad DEC_clearGrow.s8.ffi).mlx.objs.get h).isSome = true)
    (hclC : ∀ h l, DEC_clearGrow.krC_2.targs.get h = some l → Host.Ts.Sim.Full.STargs (· < (⟨29440, 24984, 3124248, 386⟩ : Conv.Cnt).n) l) :
    Conv.FullShiftQ DEC_clearGrow.P2 386 DEC_clearGrow.kappa2 DEC_clearGrow.s10.ffi DEC_clearGrow.s9.ffi :=
  ⟨DEC_clearGrow.cnshift2 clean hltC nltC itemsC tracedC cl, DEC_clearGrow.cqueue2, fun t ht => bSN_sound (List.all_eq_true.mp DEC_clearGrow.ctokSupp2 t ht),
    DEC_clearGrow.cbridge2,
    liveShift_foot (x0' := Host.Ts.Sim.Full.mlxOf DEC_clearGrow.s10.ffi) (x1' := Host.Ts.Sim.Full.mlxOf DEC_clearGrow.s9.ffi) (DEC_clearGrow.cfoot2 clean hltC nltC itemsC tracedC cl) rfl DEC_clearGrow.ofx0_2 DEC_clearGrow.ofx1_2 hobjC DEC_clearGrow.ff02 DEC_clearGrow.ff12 DEC_clearGrow.ffck2,
    kernShift_foot (x0' := Host.Ts.Sim.Full.mlxOf DEC_clearGrow.s10.ffi) (x1' := Host.Ts.Sim.Full.mlxOf DEC_clearGrow.s9.ffi) (DEC_clearGrow.cfoot2 clean hltC nltC itemsC tracedC cl) rfl DEC_clearGrow.okr0_2 DEC_clearGrow.okr1_2 (Nat.le_of_ble_eq_true DEC_clearGrow.fkn2) hfC htC hclC
      DEC_clearGrow.fkf02 DEC_clearGrow.fkt02 DEC_clearGrow.fkf12 DEC_clearGrow.fkt12 DEC_clearGrow.fkck2,
    pendReg_of rfl DEC_clearGrow.cnh02 DEC_clearGrow.cnh12 (Nat.le_of_ble_eq_true DEC_clearGrow.cpendLe2) DEC_clearGrow.cpendR2⟩

end Host.Load.Run.Tpl
