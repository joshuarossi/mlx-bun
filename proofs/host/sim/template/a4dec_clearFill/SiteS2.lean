import host.sim.template.a4dec_clearFill.SiteCl2
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
def DEC_clearFill.P2 : LoadP := ⟨25000, 131072, 1099511627776, 20000, 22539, []⟩
noncomputable abbrev DEC_clearFill.cx0_2 : Host.Load.LSt := clearTokens (Host.Load.Layers.toLoad DEC_clearFill.s10.ffi)
noncomputable abbrev DEC_clearFill.cx1_2 : Host.Load.LSt := clearTokens (Host.Load.Layers.toLoad DEC_clearFill.s9.ffi)
def DEC_clearFill.khinv2 : PTrie Nat := Stage.setAll PTrie.nil []
def DEC_clearFill.kninv2 : PTrie Nat := Stage.setAll PTrie.nil []
/-- The stage's footprint: its written and fresh handles, fresh nodes, written and fresh items. -/
def DEC_clearFill.cwS2 : List Nat := [29440]
def DEC_clearFill.cnS2 : List Nat := List.range' 24888 0
def DEC_clearFill.ciS2 : List Nat := [] ++ List.range' 24888 0

-- the small checks (`MChecks`'s)
kernel_rfl DEC_clearFill.cnh02 : DEC_clearFill.kd2.nh0 = DEC_clearFill.cx0_2.mlx.next
kernel_rfl DEC_clearFill.cnh12 : DEC_clearFill.kd2.nh1 = DEC_clearFill.cx1_2.mlx.next
kernel_rfl DEC_clearFill.cnn02 : DEC_clearFill.kd2.nn0 = DEC_clearFill.cx0_2.mlx.nnext
kernel_rfl DEC_clearFill.cnn12 : DEC_clearFill.kd2.nn1 = DEC_clearFill.cx1_2.mlx.nnext
kernel_rfl DEC_clearFill.cplo2 : (Nat.blt 0 DEC_clearFill.P2.lo && Nat.ble DEC_clearFill.P2.lo DEC_clearFill.cx0_2.mlx.next && Nat.ble DEC_clearFill.P2.lo RData.bigHi && Nat.ble RData.bigHi DEC_clearFill.P2.E) = true
kernel_rfl DEC_clearFill.ccnt2 : (Nat.ble DEC_clearFill.cx0_2.mlx.next DEC_clearFill.cx1_2.mlx.next && Nat.ble DEC_clearFill.cx0_2.mlx.nnext DEC_clearFill.cx1_2.mlx.nnext) = true
kernel_rfl DEC_clearFill.cnband2 : (Nat.blt 0 DEC_clearFill.P2.NL && Nat.ble DEC_clearFill.P2.NL DEC_clearFill.P2.N0 && Nat.ble DEC_clearFill.P2.N0 DEC_clearFill.cx0_2.mlx.nnext) = true
kernel_rfl DEC_clearFill.chbelow2 : DEC_clearFill.kd2.checkHndBelow = true
kernel_rfl DEC_clearFill.chren2 : checkRenG DEC_clearFill.kd2.hnd DEC_clearFill.khinv2 (phB DEC_clearFill.cx0_2.mlx) = true
kernel_rfl DEC_clearFill.cband2 : DEC_clearFill.kd2.checkBand DEC_clearFill.P2.lo = true
kernel_rfl DEC_clearFill.cnh1pos2 : Nat.blt 0 DEC_clearFill.kd2.nh1 = true
kernel_rfl DEC_clearFill.cnren2 : checkRenG DEC_clearFill.kd2.node DEC_clearFill.kninv2 (pnB DEC_clearFill.cx0_2.mlx) = true
kernel_rfl DEC_clearFill.cnlow2 : (PTrie.keysA DEC_clearFill.kd2.node).all (fun j => Nat.ble DEC_clearFill.P2.NL j && Nat.blt (DEC_clearFill.kd2.nodeF j) DEC_clearFill.cx1_2.mlx.nnext) = true
kernel_rfl DEC_clearFill.cabs0a2 : DEC_clearFill.cx0_2.mlx.arrs.get 0 = none
kernel_rfl DEC_clearFill.cabs0b2 : DEC_clearFill.cx0_2.mlx.objs.get 0 = none
kernel_rfl DEC_clearFill.ctok12 : DEC_clearFill.cx1_2.mlx.tokens = []
kernel_rfl DEC_clearFill.cpend2 : DEC_clearFill.cx1_2.mlx.pending = DEC_clearFill.cx0_2.mlx.pending.map DEC_clearFill.kappa2.pend
kernel_rfl DEC_clearFill.cerrh2 : DEC_clearFill.cx1_2.mlx.errh = DEC_clearFill.cx0_2.mlx.errh.map DEC_clearFill.kappa2.arg
kernel_rfl DEC_clearFill.cfiles2 : DEC_clearFill.cx1_2.mlx.files = DEC_clearFill.cx0_2.mlx.files
kernel_rfl DEC_clearFill.carch2 : DEC_clearFill.cx1_2.mlx.arch = DEC_clearFill.cx0_2.mlx.arch
kernel_rfl DEC_clearFill.csizes2 : DEC_clearFill.cx1_2.mlx.deviceSizes = DEC_clearFill.cx0_2.mlx.deviceSizes
kernel_rfl DEC_clearFill.cwired2 : DEC_clearFill.cx1_2.mlx.wired = DEC_clearFill.cx0_2.mlx.wired
kernel_rfl DEC_clearFill.chost2 : DEC_clearFill.cx1_2.host = DEC_clearFill.cx0_2.host
-- the compaction map's addresses are `DEC_clearFill.kd2`'s
kernel_rfl DEC_clearFill.ckn02 : DEC_clearFill.kd2.n0 = 3124248
kernel_rfl DEC_clearFill.ckn12 : DEC_clearFill.kd2.n1 = 3124267
kernel_rfl DEC_clearFill.ckheap2 : (PTrie.keysA DEC_clearFill.kd2.heap).all (fun x => Nat.ble 3124248 x) = true
kernel_rfl DEC_clearFill.ckpl2 : (List.range 0).all (fun j => decide (DEC_clearFill.kd2.heap.get (3124248 + j) = nth? DEC_clearFill.pl2 j)) = true
-- the map fixes the call's names (`Conv.fixOld_compact`), the call's counters
kernel_rfl DEC_clearFill.fja2 : Nat.ble 3124248 3124248 = true
kernel_rfl DEC_clearFill.fn2 : Nat.ble 290 290 = true
kernel_rfl DEC_clearFill.fjaD2 : Nat.ble 3124248 DEC_clearFill.kd2.n0 = true
kernel_rfl DEC_clearFill.fxn2 : Nat.ble 29440 DEC_clearFill.kd2.nh0 = true
kernel_rfl DEC_clearFill.fnn2 : Nat.ble 24888 DEC_clearFill.kd2.nn0 = true
kernel_rfl DEC_clearFill.fxb2 : Nat.ble 29440 RData.bigHi = true
kernel_rfl DEC_clearFill.fheap2 : (PTrie.keysA DEC_clearFill.kd2.heap).all (Nat.ble (⟨29440, 24888, 3124248, 290⟩ : Conv.Cnt).ja) = true
kernel_rfl DEC_clearFill.fhnd2 : (PTrie.keysA DEC_clearFill.kd2.hnd).all (Nat.ble (⟨29440, 24888, 3124248, 290⟩ : Conv.Cnt).xn) = true
kernel_rfl DEC_clearFill.fnode2 : (PTrie.keysA DEC_clearFill.kd2.node).all (Nat.ble (⟨29440, 24888, 3124248, 290⟩ : Conv.Cnt).nn) = true
/-- The compaction map fixes the call's names. -/
theorem DEC_clearFill.cfix2 : Conv.FixOld (⟨29440, 24888, 3124248, 290⟩ : Conv.Cnt) DEC_clearFill.kappa2 :=
  Conv.fixOld_compact (Nat.le_of_ble_eq_true DEC_clearFill.fja2) (Nat.le_of_ble_eq_true DEC_clearFill.fn2) (Nat.le_of_ble_eq_true DEC_clearFill.fjaD2) (Nat.le_of_ble_eq_true DEC_clearFill.fxn2) (Nat.le_of_ble_eq_true DEC_clearFill.fnn2) (Nat.le_of_ble_eq_true DEC_clearFill.fxb2) DEC_clearFill.fheap2 DEC_clearFill.fhnd2 DEC_clearFill.fnode2
kernel_rfl DEC_clearFill.fcxn2 : (⟨29440, 24888, 3124248, 290⟩ : Conv.Cnt).xn = (Host.Load.Layers.toLoad DEC_clearFill.s8.ffi).mlx.next
kernel_rfl DEC_clearFill.fcnn2 : (⟨29440, 24888, 3124248, 290⟩ : Conv.Cnt).nn = (Host.Load.Layers.toLoad DEC_clearFill.s8.ffi).mlx.nnext
kernel_rfl DEC_clearFill.fle02 : (Nat.ble (Host.Load.Layers.toLoad DEC_clearFill.s8.ffi).mlx.next DEC_clearFill.cx0_2.mlx.next && Nat.ble (Host.Load.Layers.toLoad DEC_clearFill.s8.ffi).mlx.nnext DEC_clearFill.cx0_2.mlx.nnext && Nat.ble (Host.Load.Layers.toLoad DEC_clearFill.s8.ffi).mlx.next RData.bigHi) = true
kernel_rfl DEC_clearFill.fnk2 : (PTrie.keysA DEC_clearFill.kd2.node).all (Nat.ble (Host.Load.Layers.toLoad DEC_clearFill.s8.ffi).mlx.nnext) = true
-- the merged state keeps the call's entries off the stage's footprint
kernel_rfl DEC_clearFill.f1A2 : DEC_clearFill.cx1_2.mlx.arrs = Stage.setAll (Host.Load.Layers.toLoad DEC_clearFill.s8.ffi).mlx.arrs (DEC_clearFill.cwS2.filterMap fun i => (DEC_clearFill.cx1_2.mlx.arrs.get i).map (i, ·))
kernel_rfl DEC_clearFill.f1O2 : DEC_clearFill.cx1_2.mlx.objs = Stage.setAll (Host.Load.Layers.toLoad DEC_clearFill.s8.ffi).mlx.objs (DEC_clearFill.cwS2.filterMap fun i => (DEC_clearFill.cx1_2.mlx.objs.get i).map (i, ·))
kernel_rfl DEC_clearFill.f1N2 : DEC_clearFill.cx1_2.mlx.nodes = Stage.setAll (Host.Load.Layers.toLoad DEC_clearFill.s8.ffi).mlx.nodes (DEC_clearFill.cnS2.filterMap fun i => (DEC_clearFill.cx1_2.mlx.nodes.get i).map (i, ·))
kernel_rfl DEC_clearFill.f1I2 : DEC_clearFill.cx1_2.mlx.items = Stage.setAll (Host.Load.Layers.toLoad DEC_clearFill.s8.ffi).mlx.items (DEC_clearFill.ciS2.filterMap fun i => (DEC_clearFill.cx1_2.mlx.items.get i).map (i, ·))
kernel_rfl DEC_clearFill.fbd2 : (DEC_clearFill.clo2 ++ DEC_clearFill.cln2 ++ DEC_clearFill.cli2 ++ DEC_clearFill.cwS2 ++ DEC_clearFill.cnS2 ++ DEC_clearFill.ciS2).all (fun i => Nat.blt (i / 4096) (4 ^ 31)) = true
kernel_rfl DEC_clearFill.fincW2 : DEC_clearFill.cwS2.all (fun h => !Nat.blt h (Host.Load.Layers.toLoad DEC_clearFill.s8.ffi).mlx.next || DEC_clearFill.clo2.contains h) = true
kernel_rfl DEC_clearFill.fincI2 : DEC_clearFill.ciS2.all (fun k => !Nat.blt k (Host.Load.Layers.toLoad DEC_clearFill.s8.ffi).mlx.nnext || DEC_clearFill.cli2.contains k) = true
kernel_rfl DEC_clearFill.fincN2 : DEC_clearFill.cnS2.all (Nat.ble (Host.Load.Layers.toLoad DEC_clearFill.s8.ffi).mlx.nnext) = true
kernel_rfl DEC_clearFill.flnF2 : DEC_clearFill.cln2.all (Nat.ble (Host.Load.Layers.toLoad DEC_clearFill.s8.ffi).mlx.nnext) = true
-- the checks over the changed lists
kernel_rfl DEC_clearFill.fh2 : DEC_clearFill.clo2.all (handleOK DEC_clearFill.kappa2 DEC_clearFill.P2.lo DEC_clearFill.cx0_2.mlx DEC_clearFill.cx1_2.mlx) = true
kernel_rfl DEC_clearFill.fo2 : DEC_clearFill.clo2.map (fun h => DEC_clearFill.cx1_2.mlx.objs.get (DEC_clearFill.kappa2.handle h)) = DEC_clearFill.clo2.map (fun h => (DEC_clearFill.cx0_2.mlx.objs.get h).map DEC_clearFill.kappa2.nobj)
kernel_rfl DEC_clearFill.fok2 : DEC_clearFill.clo2.all (objOK DEC_clearFill.kappa2 DEC_clearFill.P2.NL DEC_clearFill.cx0_2.mlx) = true
kernel_rfl DEC_clearFill.fnd2 : DEC_clearFill.cln2.all (nodeOKF DEC_clearFill.kappa2 DEC_clearFill.P2 DEC_clearFill.cx0_2.mlx DEC_clearFill.cx1_2.mlx) = true
kernel_rfl DEC_clearFill.fp2 : ((DEC_clearFill.cln2.filter (fullB DEC_clearFill.P2))).map (fun i => (DEC_clearFill.cx1_2.mlx.nodes.get (DEC_clearFill.kappa2.node i)).map Host.Mlx.Ffi.Node.prim) =
  ((DEC_clearFill.cln2.filter (fullB DEC_clearFill.P2))).map (fun i => (DEC_clearFill.cx0_2.mlx.nodes.get i).map fun nd => DEC_clearFill.kappa2.prim nd.prim)
kernel_rfl DEC_clearFill.fnordI2 : incrB DEC_clearFill.kd2.nodeF (List.range' 24888 0) = true
kernel_rfl DEC_clearFill.fnordK2 : (PTrie.keysA DEC_clearFill.kd2.node).all (fun k => Nat.ble 24888 k && Nat.blt k 24888) = true
kernel_rfl DEC_clearFill.fnordL2 : (DEC_clearFill.cln2.filter (Nat.ble DEC_clearFill.P2.N0)).all (fun i => Nat.ble i (DEC_clearFill.kd2.nodeF i) && (Nat.blt i 24888 || Nat.ble DEC_clearFill.kd2.nn0 i)) = true
theorem DEC_clearFill.fnord2 : (DEC_clearFill.cln2.filter (Nat.ble DEC_clearFill.P2.N0)).all (fun i => Nat.ble i (DEC_clearFill.kd2.nodeF i) &&
    (PTrie.keysA DEC_clearFill.kd2.node).all fun j => !Nat.blt j i || Nat.blt (DEC_clearFill.kd2.nodeF j) (DEC_clearFill.kd2.nodeF i)) = true :=
  cnord_of DEC_clearFill.cnlow2 DEC_clearFill.cnn12 DEC_clearFill.fnordI2 DEC_clearFill.fnordK2 DEC_clearFill.fnordL2
kernel_rfl DEC_clearFill.fi2 : DEC_clearFill.cli2.all (pnB DEC_clearFill.cx0_2.mlx) = true
kernel_rfl DEC_clearFill.fii2 : DEC_clearFill.cli2.all (fun k => decide (DEC_clearFill.cx1_2.mlx.items.get (DEC_clearFill.kappa2.node k) = (DEC_clearFill.cx0_2.mlx.items.get k).map DEC_clearFill.kappa2.nv)) = true
/-- **The compaction's footprint.** -/
theorem DEC_clearFill.cfoot2 (clean : Conv.NClean (⟨29440, 24888, 3124248, 290⟩ : Conv.Cnt) (Host.Load.Layers.toLoad DEC_clearFill.s8.ffi).mlx) (hltC : ∀ h, PH (Host.Load.Layers.toLoad DEC_clearFill.s8.ffi).mlx h → h < (Host.Load.Layers.toLoad DEC_clearFill.s8.ffi).mlx.next) (nltC : ∀ i, PN (Host.Load.Layers.toLoad DEC_clearFill.s8.ffi).mlx i → i < (Host.Load.Layers.toLoad DEC_clearFill.s8.ffi).mlx.nnext) (itemsC : ∀ k v, (Host.Load.Layers.toLoad DEC_clearFill.s8.ffi).mlx.items.get k = some v → PN (Host.Load.Layers.toLoad DEC_clearFill.s8.ffi).mlx k) (tracedC : ∀ h o, (Host.Load.Layers.toLoad DEC_clearFill.s8.ffi).mlx.objs.get h = some o → ∀ i ∈ objTraces o, i < DEC_clearFill.P2.NL) (cl : SSt (· < 290) DEC_clearFill.cx0_2.mlx) :
    Conv.MFoot DEC_clearFill.P2 290 DEC_clearFill.kappa2 DEC_clearFill.kd2 DEC_clearFill.khinv2 DEC_clearFill.kninv2 (Host.Load.Layers.toLoad DEC_clearFill.s8.ffi).mlx DEC_clearFill.cx0_2.mlx DEC_clearFill.cx1_2.mlx (⟨29440, 24888, 3124248, 290⟩ : Conv.Cnt) DEC_clearFill.clo2 DEC_clearFill.cln2 DEC_clearFill.cli2 DEC_clearFill.cwS2 DEC_clearFill.cnS2 DEC_clearFill.ciS2 :=
  ⟨rfl, rfl, rfl, DEC_clearFill.cnh02, DEC_clearFill.cnh12, DEC_clearFill.cnn02, DEC_clearFill.cnn12, DEC_clearFill.cplo2, DEC_clearFill.ccnt2, DEC_clearFill.cnband2, DEC_clearFill.chbelow2, DEC_clearFill.chren2, DEC_clearFill.cband2, DEC_clearFill.cnh1pos2, DEC_clearFill.cnren2, DEC_clearFill.cnlow2, DEC_clearFill.cabs0a2, DEC_clearFill.cabs0b2, DEC_clearFill.ctok12, DEC_clearFill.cpend2, DEC_clearFill.cerrh2, DEC_clearFill.cfiles2, DEC_clearFill.carch2, DEC_clearFill.csizes2, DEC_clearFill.cwired2, DEC_clearFill.cfix2, clean, DEC_clearFill.fcxn2, DEC_clearFill.fcnn2, hltC, nltC, itemsC, tracedC, cl, DEC_clearFill.fle02, DEC_clearFill.fnk2, DEC_clearFill.ckA2, DEC_clearFill.cobjsK2, DEC_clearFill.cnodesK2, DEC_clearFill.citemsK2, DEC_clearFill.f1A2, DEC_clearFill.f1O2, DEC_clearFill.f1N2, DEC_clearFill.f1I2, DEC_clearFill.fbd2, DEC_clearFill.fincW2, DEC_clearFill.fincI2, DEC_clearFill.fincN2, DEC_clearFill.flnF2, DEC_clearFill.fh2, DEC_clearFill.fo2, DEC_clearFill.fok2, DEC_clearFill.fnd2, DEC_clearFill.fp2, DEC_clearFill.fnord2, DEC_clearFill.fi2, DEC_clearFill.fii2⟩
theorem DEC_clearFill.cnshift2 (clean : Conv.NClean (⟨29440, 24888, 3124248, 290⟩ : Conv.Cnt) (Host.Load.Layers.toLoad DEC_clearFill.s8.ffi).mlx) (hltC : ∀ h, PH (Host.Load.Layers.toLoad DEC_clearFill.s8.ffi).mlx h → h < (Host.Load.Layers.toLoad DEC_clearFill.s8.ffi).mlx.next) (nltC : ∀ i, PN (Host.Load.Layers.toLoad DEC_clearFill.s8.ffi).mlx i → i < (Host.Load.Layers.toLoad DEC_clearFill.s8.ffi).mlx.nnext) (itemsC : ∀ k v, (Host.Load.Layers.toLoad DEC_clearFill.s8.ffi).mlx.items.get k = some v → PN (Host.Load.Layers.toLoad DEC_clearFill.s8.ffi).mlx k) (tracedC : ∀ h o, (Host.Load.Layers.toLoad DEC_clearFill.s8.ffi).mlx.objs.get h = some o → ∀ i ∈ objTraces o, i < DEC_clearFill.P2.NL) (cl : SSt (· < 290) DEC_clearFill.cx0_2.mlx) : NShift DEC_clearFill.P2 290 DEC_clearFill.kappa2 DEC_clearFill.cx0_2 DEC_clearFill.cx1_2 :=
  Conv.nshift_of_foot (DEC_clearFill.cfoot2 clean hltC nltC itemsC tracedC cl) DEC_clearFill.chost2 (compact_a_eq DEC_clearFill.ckn02 DEC_clearFill.ckn12 DEC_clearFill.ckheap2 DEC_clearFill.ckpl2)

-- the observers: the layers' states at the call, the canonical and the merged state, their footprints and checks
noncomputable def DEC_clearFill.fxC_2 : PTrie Unit := (Host.Ts.Sim.Full.freedOf DEC_clearFill.s8.ffi).getD PTrie.nil
noncomputable def DEC_clearFill.krC_2 : Host.Load.Layers.KRec := (Host.Ts.Sim.Full.krecOf DEC_clearFill.s8.ffi).getD Host.Load.Layers.KRec.empty
kernel_rfl DEC_clearFill.ofxC_2 : (Host.Ts.Sim.Full.freedOf DEC_clearFill.s8.ffi) = some DEC_clearFill.fxC_2
kernel_rfl DEC_clearFill.okrC_2 : (Host.Ts.Sim.Full.krecOf DEC_clearFill.s8.ffi) = some DEC_clearFill.krC_2
noncomputable def DEC_clearFill.fx0_2 : PTrie Unit := (Host.Ts.Sim.Full.freedOf DEC_clearFill.s10.ffi).getD PTrie.nil
noncomputable def DEC_clearFill.kr0_2 : Host.Load.Layers.KRec := (Host.Ts.Sim.Full.krecOf DEC_clearFill.s10.ffi).getD Host.Load.Layers.KRec.empty
kernel_rfl DEC_clearFill.ofx0_2 : (Host.Ts.Sim.Full.freedOf DEC_clearFill.s10.ffi) = some DEC_clearFill.fx0_2
kernel_rfl DEC_clearFill.okr0_2 : (Host.Ts.Sim.Full.krecOf DEC_clearFill.s10.ffi) = some DEC_clearFill.kr0_2
noncomputable def DEC_clearFill.fx1_2 : PTrie Unit := (Host.Ts.Sim.Full.freedOf DEC_clearFill.s9.ffi).getD PTrie.nil
noncomputable def DEC_clearFill.kr1_2 : Host.Load.Layers.KRec := (Host.Ts.Sim.Full.krecOf DEC_clearFill.s9.ffi).getD Host.Load.Layers.KRec.empty
kernel_rfl DEC_clearFill.ofx1_2 : (Host.Ts.Sim.Full.freedOf DEC_clearFill.s9.ffi) = some DEC_clearFill.fx1_2
kernel_rfl DEC_clearFill.okr1_2 : (Host.Ts.Sim.Full.krecOf DEC_clearFill.s9.ffi) = some DEC_clearFill.kr1_2
kernel_rfl DEC_clearFill.ff02 : DEC_clearFill.fx0_2 = Stage.setAll DEC_clearFill.fxC_2 (DEC_clearFill.clo2.filterMap fun i => (DEC_clearFill.fx0_2.get i).map (i, ·))
kernel_rfl DEC_clearFill.ff12 : DEC_clearFill.fx1_2 = Stage.setAll DEC_clearFill.fxC_2 (DEC_clearFill.cwS2.filterMap fun i => (DEC_clearFill.fx1_2.get i).map (i, ·))
kernel_rfl DEC_clearFill.ffck2 : freedLB DEC_clearFill.kappa2 DEC_clearFill.cx0_2.mlx DEC_clearFill.fx0_2 DEC_clearFill.fx1_2 DEC_clearFill.clo2 = true
kernel_rfl DEC_clearFill.fkf02 : DEC_clearFill.kr0_2.flags = Stage.setAll DEC_clearFill.krC_2.flags (DEC_clearFill.clo2.filterMap fun i => (DEC_clearFill.kr0_2.flags.get i).map (i, ·))
kernel_rfl DEC_clearFill.fkt02 : DEC_clearFill.kr0_2.targs = Stage.setAll DEC_clearFill.krC_2.targs (DEC_clearFill.clo2.filterMap fun i => (DEC_clearFill.kr0_2.targs.get i).map (i, ·))
kernel_rfl DEC_clearFill.fkf12 : DEC_clearFill.kr1_2.flags = Stage.setAll DEC_clearFill.krC_2.flags (DEC_clearFill.cwS2.filterMap fun i => (DEC_clearFill.kr1_2.flags.get i).map (i, ·))
kernel_rfl DEC_clearFill.fkt12 : DEC_clearFill.kr1_2.targs = Stage.setAll DEC_clearFill.krC_2.targs (DEC_clearFill.cwS2.filterMap fun i => (DEC_clearFill.kr1_2.targs.get i).map (i, ·))
kernel_rfl DEC_clearFill.fkck2 : krecLB DEC_clearFill.kappa2 290 DEC_clearFill.cx0_2.mlx DEC_clearFill.kr0_2 DEC_clearFill.kr1_2 DEC_clearFill.clo2 = true
kernel_rfl DEC_clearFill.fkn2 : Nat.ble 290 290 = true
-- the bridge and the pending traces' regions
kernel_rfl DEC_clearFill.cbridge2 : Host.Ts.Sim.Full.bridgeOf DEC_clearFill.s9.ffi = Host.Ts.Sim.Full.bridgeOf DEC_clearFill.s10.ffi
kernel_rfl DEC_clearFill.cpendR2 : pendRegB DEC_clearFill.kappa2 (Host.Load.Layers.toLoad DEC_clearFill.s10.ffi).mlx = true
kernel_rfl DEC_clearFill.cpendLe2 : Nat.ble (Host.Load.Layers.toLoad DEC_clearFill.s10.ffi).mlx.next (Host.Load.Layers.toLoad DEC_clearFill.s9.ffi).mlx.next = true
/-- **The compaction's native shift**, given the call's bookkeeping, its relation's facts (the model's and the
observers') and the canonical closedness. -/
theorem DEC_clearFill.cshift2 (clean : Conv.NClean (⟨29440, 24888, 3124248, 290⟩ : Conv.Cnt) (Host.Load.Layers.toLoad DEC_clearFill.s8.ffi).mlx) (hltC : ∀ h, PH (Host.Load.Layers.toLoad DEC_clearFill.s8.ffi).mlx h → h < (Host.Load.Layers.toLoad DEC_clearFill.s8.ffi).mlx.next) (nltC : ∀ i, PN (Host.Load.Layers.toLoad DEC_clearFill.s8.ffi).mlx i → i < (Host.Load.Layers.toLoad DEC_clearFill.s8.ffi).mlx.nnext) (itemsC : ∀ k v, (Host.Load.Layers.toLoad DEC_clearFill.s8.ffi).mlx.items.get k = some v → PN (Host.Load.Layers.toLoad DEC_clearFill.s8.ffi).mlx k) (tracedC : ∀ h o, (Host.Load.Layers.toLoad DEC_clearFill.s8.ffi).mlx.objs.get h = some o → ∀ i ∈ objTraces o, i < DEC_clearFill.P2.NL) (cl : SSt (· < 290) DEC_clearFill.cx0_2.mlx)
    (hobjC : ∀ h, DEC_clearFill.fxC_2.get h = some () → ((Host.Load.Layers.toLoad DEC_clearFill.s8.ffi).mlx.objs.get h).isSome = true)
    (hfC : ∀ h, (DEC_clearFill.krC_2.flags.get h).isSome = true → ((Host.Load.Layers.toLoad DEC_clearFill.s8.ffi).mlx.objs.get h).isSome = true)
    (htC : ∀ h, (DEC_clearFill.krC_2.targs.get h).isSome = true → ((Host.Load.Layers.toLoad DEC_clearFill.s8.ffi).mlx.objs.get h).isSome = true)
    (hclC : ∀ h l, DEC_clearFill.krC_2.targs.get h = some l → Host.Ts.Sim.Full.STargs (· < (⟨29440, 24888, 3124248, 290⟩ : Conv.Cnt).n) l) :
    Conv.FullShiftQ DEC_clearFill.P2 290 DEC_clearFill.kappa2 DEC_clearFill.s10.ffi DEC_clearFill.s9.ffi :=
  ⟨DEC_clearFill.cnshift2 clean hltC nltC itemsC tracedC cl, DEC_clearFill.cqueue2, fun t ht => bSN_sound (List.all_eq_true.mp DEC_clearFill.ctokSupp2 t ht),
    DEC_clearFill.cbridge2,
    liveShift_foot (x0' := Host.Ts.Sim.Full.mlxOf DEC_clearFill.s10.ffi) (x1' := Host.Ts.Sim.Full.mlxOf DEC_clearFill.s9.ffi) (DEC_clearFill.cfoot2 clean hltC nltC itemsC tracedC cl) rfl DEC_clearFill.ofx0_2 DEC_clearFill.ofx1_2 hobjC DEC_clearFill.ff02 DEC_clearFill.ff12 DEC_clearFill.ffck2,
    kernShift_foot (x0' := Host.Ts.Sim.Full.mlxOf DEC_clearFill.s10.ffi) (x1' := Host.Ts.Sim.Full.mlxOf DEC_clearFill.s9.ffi) (DEC_clearFill.cfoot2 clean hltC nltC itemsC tracedC cl) rfl DEC_clearFill.okr0_2 DEC_clearFill.okr1_2 (Nat.le_of_ble_eq_true DEC_clearFill.fkn2) hfC htC hclC
      DEC_clearFill.fkf02 DEC_clearFill.fkt02 DEC_clearFill.fkf12 DEC_clearFill.fkt12 DEC_clearFill.fkck2,
    pendReg_of rfl DEC_clearFill.cnh02 DEC_clearFill.cnh12 (Nat.le_of_ble_eq_true DEC_clearFill.cpendLe2) DEC_clearFill.cpendR2⟩

end Host.Load.Run.Tpl
