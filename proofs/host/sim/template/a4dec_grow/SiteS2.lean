import host.sim.template.a4dec_grow.SiteCl2
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
def DEC_grow.P2 : LoadP := ⟨25000, 131072, 1099511627776, 20000, 22539, []⟩
noncomputable abbrev DEC_grow.cx0_2 : Host.Load.LSt := clearTokens (Host.Load.Layers.toLoad DEC_grow.s10.ffi)
noncomputable abbrev DEC_grow.cx1_2 : Host.Load.LSt := clearTokens (Host.Load.Layers.toLoad DEC_grow.s9.ffi)
def DEC_grow.khinv2 : PTrie Nat := Stage.setAll PTrie.nil []
def DEC_grow.kninv2 : PTrie Nat := Stage.setAll PTrie.nil []
/-- The stage's footprint: its written and fresh handles, fresh nodes, written and fresh items. -/
def DEC_grow.cwS2 : List Nat := [29440]
def DEC_grow.cnS2 : List Nat := List.range' 24984 0
def DEC_grow.ciS2 : List Nat := [] ++ List.range' 24984 0

-- the small checks (`MChecks`'s)
kernel_rfl DEC_grow.cnh02 : DEC_grow.kd2.nh0 = DEC_grow.cx0_2.mlx.next
kernel_rfl DEC_grow.cnh12 : DEC_grow.kd2.nh1 = DEC_grow.cx1_2.mlx.next
kernel_rfl DEC_grow.cnn02 : DEC_grow.kd2.nn0 = DEC_grow.cx0_2.mlx.nnext
kernel_rfl DEC_grow.cnn12 : DEC_grow.kd2.nn1 = DEC_grow.cx1_2.mlx.nnext
kernel_rfl DEC_grow.cplo2 : (Nat.blt 0 DEC_grow.P2.lo && Nat.ble DEC_grow.P2.lo DEC_grow.cx0_2.mlx.next && Nat.ble DEC_grow.P2.lo RData.bigHi && Nat.ble RData.bigHi DEC_grow.P2.E) = true
kernel_rfl DEC_grow.ccnt2 : (Nat.ble DEC_grow.cx0_2.mlx.next DEC_grow.cx1_2.mlx.next && Nat.ble DEC_grow.cx0_2.mlx.nnext DEC_grow.cx1_2.mlx.nnext) = true
kernel_rfl DEC_grow.cnband2 : (Nat.blt 0 DEC_grow.P2.NL && Nat.ble DEC_grow.P2.NL DEC_grow.P2.N0 && Nat.ble DEC_grow.P2.N0 DEC_grow.cx0_2.mlx.nnext) = true
kernel_rfl DEC_grow.chbelow2 : DEC_grow.kd2.checkHndBelow = true
kernel_rfl DEC_grow.chren2 : checkRenG DEC_grow.kd2.hnd DEC_grow.khinv2 (phB DEC_grow.cx0_2.mlx) = true
kernel_rfl DEC_grow.cband2 : DEC_grow.kd2.checkBand DEC_grow.P2.lo = true
kernel_rfl DEC_grow.cnh1pos2 : Nat.blt 0 DEC_grow.kd2.nh1 = true
kernel_rfl DEC_grow.cnren2 : checkRenG DEC_grow.kd2.node DEC_grow.kninv2 (pnB DEC_grow.cx0_2.mlx) = true
kernel_rfl DEC_grow.cnlow2 : (PTrie.keysA DEC_grow.kd2.node).all (fun j => Nat.ble DEC_grow.P2.NL j && Nat.blt (DEC_grow.kd2.nodeF j) DEC_grow.cx1_2.mlx.nnext) = true
kernel_rfl DEC_grow.cabs0a2 : DEC_grow.cx0_2.mlx.arrs.get 0 = none
kernel_rfl DEC_grow.cabs0b2 : DEC_grow.cx0_2.mlx.objs.get 0 = none
kernel_rfl DEC_grow.ctok12 : DEC_grow.cx1_2.mlx.tokens = []
kernel_rfl DEC_grow.cpend2 : DEC_grow.cx1_2.mlx.pending = DEC_grow.cx0_2.mlx.pending.map DEC_grow.kappa2.pend
kernel_rfl DEC_grow.cerrh2 : DEC_grow.cx1_2.mlx.errh = DEC_grow.cx0_2.mlx.errh.map DEC_grow.kappa2.arg
kernel_rfl DEC_grow.cfiles2 : DEC_grow.cx1_2.mlx.files = DEC_grow.cx0_2.mlx.files
kernel_rfl DEC_grow.carch2 : DEC_grow.cx1_2.mlx.arch = DEC_grow.cx0_2.mlx.arch
kernel_rfl DEC_grow.csizes2 : DEC_grow.cx1_2.mlx.deviceSizes = DEC_grow.cx0_2.mlx.deviceSizes
kernel_rfl DEC_grow.cwired2 : DEC_grow.cx1_2.mlx.wired = DEC_grow.cx0_2.mlx.wired
kernel_rfl DEC_grow.chost2 : DEC_grow.cx1_2.host = DEC_grow.cx0_2.host
-- the compaction map's addresses are `DEC_grow.kd2`'s
kernel_rfl DEC_grow.ckn02 : DEC_grow.kd2.n0 = 3124247
kernel_rfl DEC_grow.ckn12 : DEC_grow.kd2.n1 = 3124266
kernel_rfl DEC_grow.ckheap2 : (PTrie.keysA DEC_grow.kd2.heap).all (fun x => Nat.ble 3124247 x) = true
kernel_rfl DEC_grow.ckpl2 : (List.range 0).all (fun j => decide (DEC_grow.kd2.heap.get (3124247 + j) = nth? DEC_grow.pl2 j)) = true
-- the map fixes the call's names (`Conv.fixOld_compact`), the call's counters
kernel_rfl DEC_grow.fja2 : Nat.ble 3124247 3124247 = true
kernel_rfl DEC_grow.fn2 : Nat.ble 386 386 = true
kernel_rfl DEC_grow.fjaD2 : Nat.ble 3124247 DEC_grow.kd2.n0 = true
kernel_rfl DEC_grow.fxn2 : Nat.ble 29440 DEC_grow.kd2.nh0 = true
kernel_rfl DEC_grow.fnn2 : Nat.ble 24984 DEC_grow.kd2.nn0 = true
kernel_rfl DEC_grow.fxb2 : Nat.ble 29440 RData.bigHi = true
kernel_rfl DEC_grow.fheap2 : (PTrie.keysA DEC_grow.kd2.heap).all (Nat.ble (⟨29440, 24984, 3124247, 386⟩ : Conv.Cnt).ja) = true
kernel_rfl DEC_grow.fhnd2 : (PTrie.keysA DEC_grow.kd2.hnd).all (Nat.ble (⟨29440, 24984, 3124247, 386⟩ : Conv.Cnt).xn) = true
kernel_rfl DEC_grow.fnode2 : (PTrie.keysA DEC_grow.kd2.node).all (Nat.ble (⟨29440, 24984, 3124247, 386⟩ : Conv.Cnt).nn) = true
/-- The compaction map fixes the call's names. -/
theorem DEC_grow.cfix2 : Conv.FixOld (⟨29440, 24984, 3124247, 386⟩ : Conv.Cnt) DEC_grow.kappa2 :=
  Conv.fixOld_compact (Nat.le_of_ble_eq_true DEC_grow.fja2) (Nat.le_of_ble_eq_true DEC_grow.fn2) (Nat.le_of_ble_eq_true DEC_grow.fjaD2) (Nat.le_of_ble_eq_true DEC_grow.fxn2) (Nat.le_of_ble_eq_true DEC_grow.fnn2) (Nat.le_of_ble_eq_true DEC_grow.fxb2) DEC_grow.fheap2 DEC_grow.fhnd2 DEC_grow.fnode2
kernel_rfl DEC_grow.fcxn2 : (⟨29440, 24984, 3124247, 386⟩ : Conv.Cnt).xn = (Host.Load.Layers.toLoad DEC_grow.s8.ffi).mlx.next
kernel_rfl DEC_grow.fcnn2 : (⟨29440, 24984, 3124247, 386⟩ : Conv.Cnt).nn = (Host.Load.Layers.toLoad DEC_grow.s8.ffi).mlx.nnext
kernel_rfl DEC_grow.fle02 : (Nat.ble (Host.Load.Layers.toLoad DEC_grow.s8.ffi).mlx.next DEC_grow.cx0_2.mlx.next && Nat.ble (Host.Load.Layers.toLoad DEC_grow.s8.ffi).mlx.nnext DEC_grow.cx0_2.mlx.nnext && Nat.ble (Host.Load.Layers.toLoad DEC_grow.s8.ffi).mlx.next RData.bigHi) = true
kernel_rfl DEC_grow.fnk2 : (PTrie.keysA DEC_grow.kd2.node).all (Nat.ble (Host.Load.Layers.toLoad DEC_grow.s8.ffi).mlx.nnext) = true
-- the merged state keeps the call's entries off the stage's footprint
kernel_rfl DEC_grow.f1A2 : DEC_grow.cx1_2.mlx.arrs = Stage.setAll (Host.Load.Layers.toLoad DEC_grow.s8.ffi).mlx.arrs (DEC_grow.cwS2.filterMap fun i => (DEC_grow.cx1_2.mlx.arrs.get i).map (i, ·))
kernel_rfl DEC_grow.f1O2 : DEC_grow.cx1_2.mlx.objs = Stage.setAll (Host.Load.Layers.toLoad DEC_grow.s8.ffi).mlx.objs (DEC_grow.cwS2.filterMap fun i => (DEC_grow.cx1_2.mlx.objs.get i).map (i, ·))
kernel_rfl DEC_grow.f1N2 : DEC_grow.cx1_2.mlx.nodes = Stage.setAll (Host.Load.Layers.toLoad DEC_grow.s8.ffi).mlx.nodes (DEC_grow.cnS2.filterMap fun i => (DEC_grow.cx1_2.mlx.nodes.get i).map (i, ·))
kernel_rfl DEC_grow.f1I2 : DEC_grow.cx1_2.mlx.items = Stage.setAll (Host.Load.Layers.toLoad DEC_grow.s8.ffi).mlx.items (DEC_grow.ciS2.filterMap fun i => (DEC_grow.cx1_2.mlx.items.get i).map (i, ·))
kernel_rfl DEC_grow.fbd2 : (DEC_grow.clo2 ++ DEC_grow.cln2 ++ DEC_grow.cli2 ++ DEC_grow.cwS2 ++ DEC_grow.cnS2 ++ DEC_grow.ciS2).all (fun i => Nat.blt (i / 4096) (4 ^ 31)) = true
kernel_rfl DEC_grow.fincW2 : DEC_grow.cwS2.all (fun h => !Nat.blt h (Host.Load.Layers.toLoad DEC_grow.s8.ffi).mlx.next || DEC_grow.clo2.contains h) = true
kernel_rfl DEC_grow.fincI2 : DEC_grow.ciS2.all (fun k => !Nat.blt k (Host.Load.Layers.toLoad DEC_grow.s8.ffi).mlx.nnext || DEC_grow.cli2.contains k) = true
kernel_rfl DEC_grow.fincN2 : DEC_grow.cnS2.all (Nat.ble (Host.Load.Layers.toLoad DEC_grow.s8.ffi).mlx.nnext) = true
kernel_rfl DEC_grow.flnF2 : DEC_grow.cln2.all (Nat.ble (Host.Load.Layers.toLoad DEC_grow.s8.ffi).mlx.nnext) = true
-- the checks over the changed lists
kernel_rfl DEC_grow.fh2 : DEC_grow.clo2.all (handleOK DEC_grow.kappa2 DEC_grow.P2.lo DEC_grow.cx0_2.mlx DEC_grow.cx1_2.mlx) = true
kernel_rfl DEC_grow.fo2 : DEC_grow.clo2.map (fun h => DEC_grow.cx1_2.mlx.objs.get (DEC_grow.kappa2.handle h)) = DEC_grow.clo2.map (fun h => (DEC_grow.cx0_2.mlx.objs.get h).map DEC_grow.kappa2.nobj)
kernel_rfl DEC_grow.fok2 : DEC_grow.clo2.all (objOK DEC_grow.kappa2 DEC_grow.P2.NL DEC_grow.cx0_2.mlx) = true
kernel_rfl DEC_grow.fnd2 : DEC_grow.cln2.all (nodeOKF DEC_grow.kappa2 DEC_grow.P2 DEC_grow.cx0_2.mlx DEC_grow.cx1_2.mlx) = true
kernel_rfl DEC_grow.fp2 : ((DEC_grow.cln2.filter (fullB DEC_grow.P2))).map (fun i => (DEC_grow.cx1_2.mlx.nodes.get (DEC_grow.kappa2.node i)).map Host.Mlx.Ffi.Node.prim) =
  ((DEC_grow.cln2.filter (fullB DEC_grow.P2))).map (fun i => (DEC_grow.cx0_2.mlx.nodes.get i).map fun nd => DEC_grow.kappa2.prim nd.prim)
kernel_rfl DEC_grow.fnordI2 : incrB DEC_grow.kd2.nodeF (List.range' 24984 0) = true
kernel_rfl DEC_grow.fnordK2 : (PTrie.keysA DEC_grow.kd2.node).all (fun k => Nat.ble 24984 k && Nat.blt k 24984) = true
kernel_rfl DEC_grow.fnordL2 : (DEC_grow.cln2.filter (Nat.ble DEC_grow.P2.N0)).all (fun i => Nat.ble i (DEC_grow.kd2.nodeF i) && (Nat.blt i 24984 || Nat.ble DEC_grow.kd2.nn0 i)) = true
theorem DEC_grow.fnord2 : (DEC_grow.cln2.filter (Nat.ble DEC_grow.P2.N0)).all (fun i => Nat.ble i (DEC_grow.kd2.nodeF i) &&
    (PTrie.keysA DEC_grow.kd2.node).all fun j => !Nat.blt j i || Nat.blt (DEC_grow.kd2.nodeF j) (DEC_grow.kd2.nodeF i)) = true :=
  cnord_of DEC_grow.cnlow2 DEC_grow.cnn12 DEC_grow.fnordI2 DEC_grow.fnordK2 DEC_grow.fnordL2
kernel_rfl DEC_grow.fi2 : DEC_grow.cli2.all (pnB DEC_grow.cx0_2.mlx) = true
kernel_rfl DEC_grow.fii2 : DEC_grow.cli2.all (fun k => decide (DEC_grow.cx1_2.mlx.items.get (DEC_grow.kappa2.node k) = (DEC_grow.cx0_2.mlx.items.get k).map DEC_grow.kappa2.nv)) = true
/-- **The compaction's footprint.** -/
theorem DEC_grow.cfoot2 (clean : Conv.NClean (⟨29440, 24984, 3124247, 386⟩ : Conv.Cnt) (Host.Load.Layers.toLoad DEC_grow.s8.ffi).mlx) (hltC : ∀ h, PH (Host.Load.Layers.toLoad DEC_grow.s8.ffi).mlx h → h < (Host.Load.Layers.toLoad DEC_grow.s8.ffi).mlx.next) (nltC : ∀ i, PN (Host.Load.Layers.toLoad DEC_grow.s8.ffi).mlx i → i < (Host.Load.Layers.toLoad DEC_grow.s8.ffi).mlx.nnext) (itemsC : ∀ k v, (Host.Load.Layers.toLoad DEC_grow.s8.ffi).mlx.items.get k = some v → PN (Host.Load.Layers.toLoad DEC_grow.s8.ffi).mlx k) (tracedC : ∀ h o, (Host.Load.Layers.toLoad DEC_grow.s8.ffi).mlx.objs.get h = some o → ∀ i ∈ objTraces o, i < DEC_grow.P2.NL) (cl : SSt (· < 386) DEC_grow.cx0_2.mlx) :
    Conv.MFoot DEC_grow.P2 386 DEC_grow.kappa2 DEC_grow.kd2 DEC_grow.khinv2 DEC_grow.kninv2 (Host.Load.Layers.toLoad DEC_grow.s8.ffi).mlx DEC_grow.cx0_2.mlx DEC_grow.cx1_2.mlx (⟨29440, 24984, 3124247, 386⟩ : Conv.Cnt) DEC_grow.clo2 DEC_grow.cln2 DEC_grow.cli2 DEC_grow.cwS2 DEC_grow.cnS2 DEC_grow.ciS2 :=
  ⟨rfl, rfl, rfl, DEC_grow.cnh02, DEC_grow.cnh12, DEC_grow.cnn02, DEC_grow.cnn12, DEC_grow.cplo2, DEC_grow.ccnt2, DEC_grow.cnband2, DEC_grow.chbelow2, DEC_grow.chren2, DEC_grow.cband2, DEC_grow.cnh1pos2, DEC_grow.cnren2, DEC_grow.cnlow2, DEC_grow.cabs0a2, DEC_grow.cabs0b2, DEC_grow.ctok12, DEC_grow.cpend2, DEC_grow.cerrh2, DEC_grow.cfiles2, DEC_grow.carch2, DEC_grow.csizes2, DEC_grow.cwired2, DEC_grow.cfix2, clean, DEC_grow.fcxn2, DEC_grow.fcnn2, hltC, nltC, itemsC, tracedC, cl, DEC_grow.fle02, DEC_grow.fnk2, DEC_grow.ckA2, DEC_grow.cobjsK2, DEC_grow.cnodesK2, DEC_grow.citemsK2, DEC_grow.f1A2, DEC_grow.f1O2, DEC_grow.f1N2, DEC_grow.f1I2, DEC_grow.fbd2, DEC_grow.fincW2, DEC_grow.fincI2, DEC_grow.fincN2, DEC_grow.flnF2, DEC_grow.fh2, DEC_grow.fo2, DEC_grow.fok2, DEC_grow.fnd2, DEC_grow.fp2, DEC_grow.fnord2, DEC_grow.fi2, DEC_grow.fii2⟩
theorem DEC_grow.cnshift2 (clean : Conv.NClean (⟨29440, 24984, 3124247, 386⟩ : Conv.Cnt) (Host.Load.Layers.toLoad DEC_grow.s8.ffi).mlx) (hltC : ∀ h, PH (Host.Load.Layers.toLoad DEC_grow.s8.ffi).mlx h → h < (Host.Load.Layers.toLoad DEC_grow.s8.ffi).mlx.next) (nltC : ∀ i, PN (Host.Load.Layers.toLoad DEC_grow.s8.ffi).mlx i → i < (Host.Load.Layers.toLoad DEC_grow.s8.ffi).mlx.nnext) (itemsC : ∀ k v, (Host.Load.Layers.toLoad DEC_grow.s8.ffi).mlx.items.get k = some v → PN (Host.Load.Layers.toLoad DEC_grow.s8.ffi).mlx k) (tracedC : ∀ h o, (Host.Load.Layers.toLoad DEC_grow.s8.ffi).mlx.objs.get h = some o → ∀ i ∈ objTraces o, i < DEC_grow.P2.NL) (cl : SSt (· < 386) DEC_grow.cx0_2.mlx) : NShift DEC_grow.P2 386 DEC_grow.kappa2 DEC_grow.cx0_2 DEC_grow.cx1_2 :=
  Conv.nshift_of_foot (DEC_grow.cfoot2 clean hltC nltC itemsC tracedC cl) DEC_grow.chost2 (compact_a_eq DEC_grow.ckn02 DEC_grow.ckn12 DEC_grow.ckheap2 DEC_grow.ckpl2)

-- the observers: the layers' states at the call, the canonical and the merged state, their footprints and checks
noncomputable def DEC_grow.fxC_2 : PTrie Unit := (Host.Ts.Sim.Full.freedOf DEC_grow.s8.ffi).getD PTrie.nil
noncomputable def DEC_grow.krC_2 : Host.Load.Layers.KRec := (Host.Ts.Sim.Full.krecOf DEC_grow.s8.ffi).getD Host.Load.Layers.KRec.empty
kernel_rfl DEC_grow.ofxC_2 : (Host.Ts.Sim.Full.freedOf DEC_grow.s8.ffi) = some DEC_grow.fxC_2
kernel_rfl DEC_grow.okrC_2 : (Host.Ts.Sim.Full.krecOf DEC_grow.s8.ffi) = some DEC_grow.krC_2
noncomputable def DEC_grow.fx0_2 : PTrie Unit := (Host.Ts.Sim.Full.freedOf DEC_grow.s10.ffi).getD PTrie.nil
noncomputable def DEC_grow.kr0_2 : Host.Load.Layers.KRec := (Host.Ts.Sim.Full.krecOf DEC_grow.s10.ffi).getD Host.Load.Layers.KRec.empty
kernel_rfl DEC_grow.ofx0_2 : (Host.Ts.Sim.Full.freedOf DEC_grow.s10.ffi) = some DEC_grow.fx0_2
kernel_rfl DEC_grow.okr0_2 : (Host.Ts.Sim.Full.krecOf DEC_grow.s10.ffi) = some DEC_grow.kr0_2
noncomputable def DEC_grow.fx1_2 : PTrie Unit := (Host.Ts.Sim.Full.freedOf DEC_grow.s9.ffi).getD PTrie.nil
noncomputable def DEC_grow.kr1_2 : Host.Load.Layers.KRec := (Host.Ts.Sim.Full.krecOf DEC_grow.s9.ffi).getD Host.Load.Layers.KRec.empty
kernel_rfl DEC_grow.ofx1_2 : (Host.Ts.Sim.Full.freedOf DEC_grow.s9.ffi) = some DEC_grow.fx1_2
kernel_rfl DEC_grow.okr1_2 : (Host.Ts.Sim.Full.krecOf DEC_grow.s9.ffi) = some DEC_grow.kr1_2
kernel_rfl DEC_grow.ff02 : DEC_grow.fx0_2 = Stage.setAll DEC_grow.fxC_2 (DEC_grow.clo2.filterMap fun i => (DEC_grow.fx0_2.get i).map (i, ·))
kernel_rfl DEC_grow.ff12 : DEC_grow.fx1_2 = Stage.setAll DEC_grow.fxC_2 (DEC_grow.cwS2.filterMap fun i => (DEC_grow.fx1_2.get i).map (i, ·))
kernel_rfl DEC_grow.ffck2 : freedLB DEC_grow.kappa2 DEC_grow.cx0_2.mlx DEC_grow.fx0_2 DEC_grow.fx1_2 DEC_grow.clo2 = true
kernel_rfl DEC_grow.fkf02 : DEC_grow.kr0_2.flags = Stage.setAll DEC_grow.krC_2.flags (DEC_grow.clo2.filterMap fun i => (DEC_grow.kr0_2.flags.get i).map (i, ·))
kernel_rfl DEC_grow.fkt02 : DEC_grow.kr0_2.targs = Stage.setAll DEC_grow.krC_2.targs (DEC_grow.clo2.filterMap fun i => (DEC_grow.kr0_2.targs.get i).map (i, ·))
kernel_rfl DEC_grow.fkf12 : DEC_grow.kr1_2.flags = Stage.setAll DEC_grow.krC_2.flags (DEC_grow.cwS2.filterMap fun i => (DEC_grow.kr1_2.flags.get i).map (i, ·))
kernel_rfl DEC_grow.fkt12 : DEC_grow.kr1_2.targs = Stage.setAll DEC_grow.krC_2.targs (DEC_grow.cwS2.filterMap fun i => (DEC_grow.kr1_2.targs.get i).map (i, ·))
kernel_rfl DEC_grow.fkck2 : krecLB DEC_grow.kappa2 386 DEC_grow.cx0_2.mlx DEC_grow.kr0_2 DEC_grow.kr1_2 DEC_grow.clo2 = true
kernel_rfl DEC_grow.fkn2 : Nat.ble 386 386 = true
-- the bridge and the pending traces' regions
kernel_rfl DEC_grow.cbridge2 : Host.Ts.Sim.Full.bridgeOf DEC_grow.s9.ffi = Host.Ts.Sim.Full.bridgeOf DEC_grow.s10.ffi
kernel_rfl DEC_grow.cpendR2 : pendRegB DEC_grow.kappa2 (Host.Load.Layers.toLoad DEC_grow.s10.ffi).mlx = true
kernel_rfl DEC_grow.cpendLe2 : Nat.ble (Host.Load.Layers.toLoad DEC_grow.s10.ffi).mlx.next (Host.Load.Layers.toLoad DEC_grow.s9.ffi).mlx.next = true
/-- **The compaction's native shift**, given the call's bookkeeping, its relation's facts (the model's and the
observers') and the canonical closedness. -/
theorem DEC_grow.cshift2 (clean : Conv.NClean (⟨29440, 24984, 3124247, 386⟩ : Conv.Cnt) (Host.Load.Layers.toLoad DEC_grow.s8.ffi).mlx) (hltC : ∀ h, PH (Host.Load.Layers.toLoad DEC_grow.s8.ffi).mlx h → h < (Host.Load.Layers.toLoad DEC_grow.s8.ffi).mlx.next) (nltC : ∀ i, PN (Host.Load.Layers.toLoad DEC_grow.s8.ffi).mlx i → i < (Host.Load.Layers.toLoad DEC_grow.s8.ffi).mlx.nnext) (itemsC : ∀ k v, (Host.Load.Layers.toLoad DEC_grow.s8.ffi).mlx.items.get k = some v → PN (Host.Load.Layers.toLoad DEC_grow.s8.ffi).mlx k) (tracedC : ∀ h o, (Host.Load.Layers.toLoad DEC_grow.s8.ffi).mlx.objs.get h = some o → ∀ i ∈ objTraces o, i < DEC_grow.P2.NL) (cl : SSt (· < 386) DEC_grow.cx0_2.mlx)
    (hobjC : ∀ h, DEC_grow.fxC_2.get h = some () → ((Host.Load.Layers.toLoad DEC_grow.s8.ffi).mlx.objs.get h).isSome = true)
    (hfC : ∀ h, (DEC_grow.krC_2.flags.get h).isSome = true → ((Host.Load.Layers.toLoad DEC_grow.s8.ffi).mlx.objs.get h).isSome = true)
    (htC : ∀ h, (DEC_grow.krC_2.targs.get h).isSome = true → ((Host.Load.Layers.toLoad DEC_grow.s8.ffi).mlx.objs.get h).isSome = true)
    (hclC : ∀ h l, DEC_grow.krC_2.targs.get h = some l → Host.Ts.Sim.Full.STargs (· < (⟨29440, 24984, 3124247, 386⟩ : Conv.Cnt).n) l) :
    Conv.FullShiftQ DEC_grow.P2 386 DEC_grow.kappa2 DEC_grow.s10.ffi DEC_grow.s9.ffi :=
  ⟨DEC_grow.cnshift2 clean hltC nltC itemsC tracedC cl, DEC_grow.cqueue2, fun t ht => bSN_sound (List.all_eq_true.mp DEC_grow.ctokSupp2 t ht),
    DEC_grow.cbridge2,
    liveShift_foot (x0' := Host.Ts.Sim.Full.mlxOf DEC_grow.s10.ffi) (x1' := Host.Ts.Sim.Full.mlxOf DEC_grow.s9.ffi) (DEC_grow.cfoot2 clean hltC nltC itemsC tracedC cl) rfl DEC_grow.ofx0_2 DEC_grow.ofx1_2 hobjC DEC_grow.ff02 DEC_grow.ff12 DEC_grow.ffck2,
    kernShift_foot (x0' := Host.Ts.Sim.Full.mlxOf DEC_grow.s10.ffi) (x1' := Host.Ts.Sim.Full.mlxOf DEC_grow.s9.ffi) (DEC_grow.cfoot2 clean hltC nltC itemsC tracedC cl) rfl DEC_grow.okr0_2 DEC_grow.okr1_2 (Nat.le_of_ble_eq_true DEC_grow.fkn2) hfC htC hclC
      DEC_grow.fkf02 DEC_grow.fkt02 DEC_grow.fkf12 DEC_grow.fkt12 DEC_grow.fkck2,
    pendReg_of rfl DEC_grow.cnh02 DEC_grow.cnh12 (Nat.le_of_ble_eq_true DEC_grow.cpendLe2) DEC_grow.cpendR2⟩

end Host.Load.Run.Tpl
