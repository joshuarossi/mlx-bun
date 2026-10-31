import host.sim.template.a4dec_ord.SiteCl2
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
def DEC_ord.P2 : LoadP := ⟨25000, 131072, 1099511627776, 20000, 22539, []⟩
noncomputable abbrev DEC_ord.cx0_2 : Host.Load.LSt := clearTokens (Host.Load.Layers.toLoad DEC_ord.s10.ffi)
noncomputable abbrev DEC_ord.cx1_2 : Host.Load.LSt := clearTokens (Host.Load.Layers.toLoad DEC_ord.s9.ffi)
def DEC_ord.khinv2 : PTrie Nat := Stage.setAll PTrie.nil []
def DEC_ord.kninv2 : PTrie Nat := Stage.setAll PTrie.nil []
/-- The stage's footprint: its written and fresh handles, fresh nodes, written and fresh items. -/
def DEC_ord.cwS2 : List Nat := [29440]
def DEC_ord.cnS2 : List Nat := List.range' 24920 0
def DEC_ord.ciS2 : List Nat := [] ++ List.range' 24920 0

-- the small checks (`MChecks`'s)
kernel_rfl DEC_ord.cnh02 : DEC_ord.kd2.nh0 = DEC_ord.cx0_2.mlx.next
kernel_rfl DEC_ord.cnh12 : DEC_ord.kd2.nh1 = DEC_ord.cx1_2.mlx.next
kernel_rfl DEC_ord.cnn02 : DEC_ord.kd2.nn0 = DEC_ord.cx0_2.mlx.nnext
kernel_rfl DEC_ord.cnn12 : DEC_ord.kd2.nn1 = DEC_ord.cx1_2.mlx.nnext
kernel_rfl DEC_ord.cplo2 : (Nat.blt 0 DEC_ord.P2.lo && Nat.ble DEC_ord.P2.lo DEC_ord.cx0_2.mlx.next && Nat.ble DEC_ord.P2.lo RData.bigHi && Nat.ble RData.bigHi DEC_ord.P2.E) = true
kernel_rfl DEC_ord.ccnt2 : (Nat.ble DEC_ord.cx0_2.mlx.next DEC_ord.cx1_2.mlx.next && Nat.ble DEC_ord.cx0_2.mlx.nnext DEC_ord.cx1_2.mlx.nnext) = true
kernel_rfl DEC_ord.cnband2 : (Nat.blt 0 DEC_ord.P2.NL && Nat.ble DEC_ord.P2.NL DEC_ord.P2.N0 && Nat.ble DEC_ord.P2.N0 DEC_ord.cx0_2.mlx.nnext) = true
kernel_rfl DEC_ord.chbelow2 : DEC_ord.kd2.checkHndBelow = true
kernel_rfl DEC_ord.chren2 : checkRenG DEC_ord.kd2.hnd DEC_ord.khinv2 (phB DEC_ord.cx0_2.mlx) = true
kernel_rfl DEC_ord.cband2 : DEC_ord.kd2.checkBand DEC_ord.P2.lo = true
kernel_rfl DEC_ord.cnh1pos2 : Nat.blt 0 DEC_ord.kd2.nh1 = true
kernel_rfl DEC_ord.cnren2 : checkRenG DEC_ord.kd2.node DEC_ord.kninv2 (pnB DEC_ord.cx0_2.mlx) = true
kernel_rfl DEC_ord.cnlow2 : (PTrie.keysA DEC_ord.kd2.node).all (fun j => Nat.ble DEC_ord.P2.NL j && Nat.blt (DEC_ord.kd2.nodeF j) DEC_ord.cx1_2.mlx.nnext) = true
kernel_rfl DEC_ord.cabs0a2 : DEC_ord.cx0_2.mlx.arrs.get 0 = none
kernel_rfl DEC_ord.cabs0b2 : DEC_ord.cx0_2.mlx.objs.get 0 = none
kernel_rfl DEC_ord.ctok12 : DEC_ord.cx1_2.mlx.tokens = []
kernel_rfl DEC_ord.cpend2 : DEC_ord.cx1_2.mlx.pending = DEC_ord.cx0_2.mlx.pending.map DEC_ord.kappa2.pend
kernel_rfl DEC_ord.cerrh2 : DEC_ord.cx1_2.mlx.errh = DEC_ord.cx0_2.mlx.errh.map DEC_ord.kappa2.arg
kernel_rfl DEC_ord.cfiles2 : DEC_ord.cx1_2.mlx.files = DEC_ord.cx0_2.mlx.files
kernel_rfl DEC_ord.carch2 : DEC_ord.cx1_2.mlx.arch = DEC_ord.cx0_2.mlx.arch
kernel_rfl DEC_ord.csizes2 : DEC_ord.cx1_2.mlx.deviceSizes = DEC_ord.cx0_2.mlx.deviceSizes
kernel_rfl DEC_ord.cwired2 : DEC_ord.cx1_2.mlx.wired = DEC_ord.cx0_2.mlx.wired
kernel_rfl DEC_ord.chost2 : DEC_ord.cx1_2.host = DEC_ord.cx0_2.host
-- the compaction map's addresses are `DEC_ord.kd2`'s
kernel_rfl DEC_ord.ckn02 : DEC_ord.kd2.n0 = 3124247
kernel_rfl DEC_ord.ckn12 : DEC_ord.kd2.n1 = 3124266
kernel_rfl DEC_ord.ckheap2 : (PTrie.keysA DEC_ord.kd2.heap).all (fun x => Nat.ble 3124247 x) = true
kernel_rfl DEC_ord.ckpl2 : (List.range 0).all (fun j => decide (DEC_ord.kd2.heap.get (3124247 + j) = nth? DEC_ord.pl2 j)) = true
-- the map fixes the call's names (`Conv.fixOld_compact`), the call's counters
kernel_rfl DEC_ord.fja2 : Nat.ble 3124247 3124247 = true
kernel_rfl DEC_ord.fn2 : Nat.ble 354 354 = true
kernel_rfl DEC_ord.fjaD2 : Nat.ble 3124247 DEC_ord.kd2.n0 = true
kernel_rfl DEC_ord.fxn2 : Nat.ble 29440 DEC_ord.kd2.nh0 = true
kernel_rfl DEC_ord.fnn2 : Nat.ble 24920 DEC_ord.kd2.nn0 = true
kernel_rfl DEC_ord.fxb2 : Nat.ble 29440 RData.bigHi = true
kernel_rfl DEC_ord.fheap2 : (PTrie.keysA DEC_ord.kd2.heap).all (Nat.ble (⟨29440, 24920, 3124247, 354⟩ : Conv.Cnt).ja) = true
kernel_rfl DEC_ord.fhnd2 : (PTrie.keysA DEC_ord.kd2.hnd).all (Nat.ble (⟨29440, 24920, 3124247, 354⟩ : Conv.Cnt).xn) = true
kernel_rfl DEC_ord.fnode2 : (PTrie.keysA DEC_ord.kd2.node).all (Nat.ble (⟨29440, 24920, 3124247, 354⟩ : Conv.Cnt).nn) = true
/-- The compaction map fixes the call's names. -/
theorem DEC_ord.cfix2 : Conv.FixOld (⟨29440, 24920, 3124247, 354⟩ : Conv.Cnt) DEC_ord.kappa2 :=
  Conv.fixOld_compact (Nat.le_of_ble_eq_true DEC_ord.fja2) (Nat.le_of_ble_eq_true DEC_ord.fn2) (Nat.le_of_ble_eq_true DEC_ord.fjaD2) (Nat.le_of_ble_eq_true DEC_ord.fxn2) (Nat.le_of_ble_eq_true DEC_ord.fnn2) (Nat.le_of_ble_eq_true DEC_ord.fxb2) DEC_ord.fheap2 DEC_ord.fhnd2 DEC_ord.fnode2
kernel_rfl DEC_ord.fcxn2 : (⟨29440, 24920, 3124247, 354⟩ : Conv.Cnt).xn = (Host.Load.Layers.toLoad DEC_ord.s8.ffi).mlx.next
kernel_rfl DEC_ord.fcnn2 : (⟨29440, 24920, 3124247, 354⟩ : Conv.Cnt).nn = (Host.Load.Layers.toLoad DEC_ord.s8.ffi).mlx.nnext
kernel_rfl DEC_ord.fle02 : (Nat.ble (Host.Load.Layers.toLoad DEC_ord.s8.ffi).mlx.next DEC_ord.cx0_2.mlx.next && Nat.ble (Host.Load.Layers.toLoad DEC_ord.s8.ffi).mlx.nnext DEC_ord.cx0_2.mlx.nnext && Nat.ble (Host.Load.Layers.toLoad DEC_ord.s8.ffi).mlx.next RData.bigHi) = true
kernel_rfl DEC_ord.fnk2 : (PTrie.keysA DEC_ord.kd2.node).all (Nat.ble (Host.Load.Layers.toLoad DEC_ord.s8.ffi).mlx.nnext) = true
-- the merged state keeps the call's entries off the stage's footprint
kernel_rfl DEC_ord.f1A2 : DEC_ord.cx1_2.mlx.arrs = Stage.setAll (Host.Load.Layers.toLoad DEC_ord.s8.ffi).mlx.arrs (DEC_ord.cwS2.filterMap fun i => (DEC_ord.cx1_2.mlx.arrs.get i).map (i, ·))
kernel_rfl DEC_ord.f1O2 : DEC_ord.cx1_2.mlx.objs = Stage.setAll (Host.Load.Layers.toLoad DEC_ord.s8.ffi).mlx.objs (DEC_ord.cwS2.filterMap fun i => (DEC_ord.cx1_2.mlx.objs.get i).map (i, ·))
kernel_rfl DEC_ord.f1N2 : DEC_ord.cx1_2.mlx.nodes = Stage.setAll (Host.Load.Layers.toLoad DEC_ord.s8.ffi).mlx.nodes (DEC_ord.cnS2.filterMap fun i => (DEC_ord.cx1_2.mlx.nodes.get i).map (i, ·))
kernel_rfl DEC_ord.f1I2 : DEC_ord.cx1_2.mlx.items = Stage.setAll (Host.Load.Layers.toLoad DEC_ord.s8.ffi).mlx.items (DEC_ord.ciS2.filterMap fun i => (DEC_ord.cx1_2.mlx.items.get i).map (i, ·))
kernel_rfl DEC_ord.fbd2 : (DEC_ord.clo2 ++ DEC_ord.cln2 ++ DEC_ord.cli2 ++ DEC_ord.cwS2 ++ DEC_ord.cnS2 ++ DEC_ord.ciS2).all (fun i => Nat.blt (i / 4096) (4 ^ 31)) = true
kernel_rfl DEC_ord.fincW2 : DEC_ord.cwS2.all (fun h => !Nat.blt h (Host.Load.Layers.toLoad DEC_ord.s8.ffi).mlx.next || DEC_ord.clo2.contains h) = true
kernel_rfl DEC_ord.fincI2 : DEC_ord.ciS2.all (fun k => !Nat.blt k (Host.Load.Layers.toLoad DEC_ord.s8.ffi).mlx.nnext || DEC_ord.cli2.contains k) = true
kernel_rfl DEC_ord.fincN2 : DEC_ord.cnS2.all (Nat.ble (Host.Load.Layers.toLoad DEC_ord.s8.ffi).mlx.nnext) = true
kernel_rfl DEC_ord.flnF2 : DEC_ord.cln2.all (Nat.ble (Host.Load.Layers.toLoad DEC_ord.s8.ffi).mlx.nnext) = true
-- the checks over the changed lists
kernel_rfl DEC_ord.fh2 : DEC_ord.clo2.all (handleOK DEC_ord.kappa2 DEC_ord.P2.lo DEC_ord.cx0_2.mlx DEC_ord.cx1_2.mlx) = true
kernel_rfl DEC_ord.fo2 : DEC_ord.clo2.map (fun h => DEC_ord.cx1_2.mlx.objs.get (DEC_ord.kappa2.handle h)) = DEC_ord.clo2.map (fun h => (DEC_ord.cx0_2.mlx.objs.get h).map DEC_ord.kappa2.nobj)
kernel_rfl DEC_ord.fok2 : DEC_ord.clo2.all (objOK DEC_ord.kappa2 DEC_ord.P2.NL DEC_ord.cx0_2.mlx) = true
kernel_rfl DEC_ord.fnd2 : DEC_ord.cln2.all (nodeOKF DEC_ord.kappa2 DEC_ord.P2 DEC_ord.cx0_2.mlx DEC_ord.cx1_2.mlx) = true
kernel_rfl DEC_ord.fp2 : ((DEC_ord.cln2.filter (fullB DEC_ord.P2))).map (fun i => (DEC_ord.cx1_2.mlx.nodes.get (DEC_ord.kappa2.node i)).map Host.Mlx.Ffi.Node.prim) =
  ((DEC_ord.cln2.filter (fullB DEC_ord.P2))).map (fun i => (DEC_ord.cx0_2.mlx.nodes.get i).map fun nd => DEC_ord.kappa2.prim nd.prim)
kernel_rfl DEC_ord.fnordI2 : incrB DEC_ord.kd2.nodeF (List.range' 24920 0) = true
kernel_rfl DEC_ord.fnordK2 : (PTrie.keysA DEC_ord.kd2.node).all (fun k => Nat.ble 24920 k && Nat.blt k 24920) = true
kernel_rfl DEC_ord.fnordL2 : (DEC_ord.cln2.filter (Nat.ble DEC_ord.P2.N0)).all (fun i => Nat.ble i (DEC_ord.kd2.nodeF i) && (Nat.blt i 24920 || Nat.ble DEC_ord.kd2.nn0 i)) = true
theorem DEC_ord.fnord2 : (DEC_ord.cln2.filter (Nat.ble DEC_ord.P2.N0)).all (fun i => Nat.ble i (DEC_ord.kd2.nodeF i) &&
    (PTrie.keysA DEC_ord.kd2.node).all fun j => !Nat.blt j i || Nat.blt (DEC_ord.kd2.nodeF j) (DEC_ord.kd2.nodeF i)) = true :=
  cnord_of DEC_ord.cnlow2 DEC_ord.cnn12 DEC_ord.fnordI2 DEC_ord.fnordK2 DEC_ord.fnordL2
kernel_rfl DEC_ord.fi2 : DEC_ord.cli2.all (pnB DEC_ord.cx0_2.mlx) = true
kernel_rfl DEC_ord.fii2 : DEC_ord.cli2.all (fun k => decide (DEC_ord.cx1_2.mlx.items.get (DEC_ord.kappa2.node k) = (DEC_ord.cx0_2.mlx.items.get k).map DEC_ord.kappa2.nv)) = true
/-- **The compaction's footprint.** -/
theorem DEC_ord.cfoot2 (clean : Conv.NClean (⟨29440, 24920, 3124247, 354⟩ : Conv.Cnt) (Host.Load.Layers.toLoad DEC_ord.s8.ffi).mlx) (hltC : ∀ h, PH (Host.Load.Layers.toLoad DEC_ord.s8.ffi).mlx h → h < (Host.Load.Layers.toLoad DEC_ord.s8.ffi).mlx.next) (nltC : ∀ i, PN (Host.Load.Layers.toLoad DEC_ord.s8.ffi).mlx i → i < (Host.Load.Layers.toLoad DEC_ord.s8.ffi).mlx.nnext) (itemsC : ∀ k v, (Host.Load.Layers.toLoad DEC_ord.s8.ffi).mlx.items.get k = some v → PN (Host.Load.Layers.toLoad DEC_ord.s8.ffi).mlx k) (tracedC : ∀ h o, (Host.Load.Layers.toLoad DEC_ord.s8.ffi).mlx.objs.get h = some o → ∀ i ∈ objTraces o, i < DEC_ord.P2.NL) (cl : SSt (· < 354) DEC_ord.cx0_2.mlx) :
    Conv.MFoot DEC_ord.P2 354 DEC_ord.kappa2 DEC_ord.kd2 DEC_ord.khinv2 DEC_ord.kninv2 (Host.Load.Layers.toLoad DEC_ord.s8.ffi).mlx DEC_ord.cx0_2.mlx DEC_ord.cx1_2.mlx (⟨29440, 24920, 3124247, 354⟩ : Conv.Cnt) DEC_ord.clo2 DEC_ord.cln2 DEC_ord.cli2 DEC_ord.cwS2 DEC_ord.cnS2 DEC_ord.ciS2 :=
  ⟨rfl, rfl, rfl, DEC_ord.cnh02, DEC_ord.cnh12, DEC_ord.cnn02, DEC_ord.cnn12, DEC_ord.cplo2, DEC_ord.ccnt2, DEC_ord.cnband2, DEC_ord.chbelow2, DEC_ord.chren2, DEC_ord.cband2, DEC_ord.cnh1pos2, DEC_ord.cnren2, DEC_ord.cnlow2, DEC_ord.cabs0a2, DEC_ord.cabs0b2, DEC_ord.ctok12, DEC_ord.cpend2, DEC_ord.cerrh2, DEC_ord.cfiles2, DEC_ord.carch2, DEC_ord.csizes2, DEC_ord.cwired2, DEC_ord.cfix2, clean, DEC_ord.fcxn2, DEC_ord.fcnn2, hltC, nltC, itemsC, tracedC, cl, DEC_ord.fle02, DEC_ord.fnk2, DEC_ord.ckA2, DEC_ord.cobjsK2, DEC_ord.cnodesK2, DEC_ord.citemsK2, DEC_ord.f1A2, DEC_ord.f1O2, DEC_ord.f1N2, DEC_ord.f1I2, DEC_ord.fbd2, DEC_ord.fincW2, DEC_ord.fincI2, DEC_ord.fincN2, DEC_ord.flnF2, DEC_ord.fh2, DEC_ord.fo2, DEC_ord.fok2, DEC_ord.fnd2, DEC_ord.fp2, DEC_ord.fnord2, DEC_ord.fi2, DEC_ord.fii2⟩
theorem DEC_ord.cnshift2 (clean : Conv.NClean (⟨29440, 24920, 3124247, 354⟩ : Conv.Cnt) (Host.Load.Layers.toLoad DEC_ord.s8.ffi).mlx) (hltC : ∀ h, PH (Host.Load.Layers.toLoad DEC_ord.s8.ffi).mlx h → h < (Host.Load.Layers.toLoad DEC_ord.s8.ffi).mlx.next) (nltC : ∀ i, PN (Host.Load.Layers.toLoad DEC_ord.s8.ffi).mlx i → i < (Host.Load.Layers.toLoad DEC_ord.s8.ffi).mlx.nnext) (itemsC : ∀ k v, (Host.Load.Layers.toLoad DEC_ord.s8.ffi).mlx.items.get k = some v → PN (Host.Load.Layers.toLoad DEC_ord.s8.ffi).mlx k) (tracedC : ∀ h o, (Host.Load.Layers.toLoad DEC_ord.s8.ffi).mlx.objs.get h = some o → ∀ i ∈ objTraces o, i < DEC_ord.P2.NL) (cl : SSt (· < 354) DEC_ord.cx0_2.mlx) : NShift DEC_ord.P2 354 DEC_ord.kappa2 DEC_ord.cx0_2 DEC_ord.cx1_2 :=
  Conv.nshift_of_foot (DEC_ord.cfoot2 clean hltC nltC itemsC tracedC cl) DEC_ord.chost2 (compact_a_eq DEC_ord.ckn02 DEC_ord.ckn12 DEC_ord.ckheap2 DEC_ord.ckpl2)

-- the observers: the layers' states at the call, the canonical and the merged state, their footprints and checks
noncomputable def DEC_ord.fxC_2 : PTrie Unit := (Host.Ts.Sim.Full.freedOf DEC_ord.s8.ffi).getD PTrie.nil
noncomputable def DEC_ord.krC_2 : Host.Load.Layers.KRec := (Host.Ts.Sim.Full.krecOf DEC_ord.s8.ffi).getD Host.Load.Layers.KRec.empty
kernel_rfl DEC_ord.ofxC_2 : (Host.Ts.Sim.Full.freedOf DEC_ord.s8.ffi) = some DEC_ord.fxC_2
kernel_rfl DEC_ord.okrC_2 : (Host.Ts.Sim.Full.krecOf DEC_ord.s8.ffi) = some DEC_ord.krC_2
noncomputable def DEC_ord.fx0_2 : PTrie Unit := (Host.Ts.Sim.Full.freedOf DEC_ord.s10.ffi).getD PTrie.nil
noncomputable def DEC_ord.kr0_2 : Host.Load.Layers.KRec := (Host.Ts.Sim.Full.krecOf DEC_ord.s10.ffi).getD Host.Load.Layers.KRec.empty
kernel_rfl DEC_ord.ofx0_2 : (Host.Ts.Sim.Full.freedOf DEC_ord.s10.ffi) = some DEC_ord.fx0_2
kernel_rfl DEC_ord.okr0_2 : (Host.Ts.Sim.Full.krecOf DEC_ord.s10.ffi) = some DEC_ord.kr0_2
noncomputable def DEC_ord.fx1_2 : PTrie Unit := (Host.Ts.Sim.Full.freedOf DEC_ord.s9.ffi).getD PTrie.nil
noncomputable def DEC_ord.kr1_2 : Host.Load.Layers.KRec := (Host.Ts.Sim.Full.krecOf DEC_ord.s9.ffi).getD Host.Load.Layers.KRec.empty
kernel_rfl DEC_ord.ofx1_2 : (Host.Ts.Sim.Full.freedOf DEC_ord.s9.ffi) = some DEC_ord.fx1_2
kernel_rfl DEC_ord.okr1_2 : (Host.Ts.Sim.Full.krecOf DEC_ord.s9.ffi) = some DEC_ord.kr1_2
kernel_rfl DEC_ord.ff02 : DEC_ord.fx0_2 = Stage.setAll DEC_ord.fxC_2 (DEC_ord.clo2.filterMap fun i => (DEC_ord.fx0_2.get i).map (i, ·))
kernel_rfl DEC_ord.ff12 : DEC_ord.fx1_2 = Stage.setAll DEC_ord.fxC_2 (DEC_ord.cwS2.filterMap fun i => (DEC_ord.fx1_2.get i).map (i, ·))
kernel_rfl DEC_ord.ffck2 : freedLB DEC_ord.kappa2 DEC_ord.cx0_2.mlx DEC_ord.fx0_2 DEC_ord.fx1_2 DEC_ord.clo2 = true
kernel_rfl DEC_ord.fkf02 : DEC_ord.kr0_2.flags = Stage.setAll DEC_ord.krC_2.flags (DEC_ord.clo2.filterMap fun i => (DEC_ord.kr0_2.flags.get i).map (i, ·))
kernel_rfl DEC_ord.fkt02 : DEC_ord.kr0_2.targs = Stage.setAll DEC_ord.krC_2.targs (DEC_ord.clo2.filterMap fun i => (DEC_ord.kr0_2.targs.get i).map (i, ·))
kernel_rfl DEC_ord.fkf12 : DEC_ord.kr1_2.flags = Stage.setAll DEC_ord.krC_2.flags (DEC_ord.cwS2.filterMap fun i => (DEC_ord.kr1_2.flags.get i).map (i, ·))
kernel_rfl DEC_ord.fkt12 : DEC_ord.kr1_2.targs = Stage.setAll DEC_ord.krC_2.targs (DEC_ord.cwS2.filterMap fun i => (DEC_ord.kr1_2.targs.get i).map (i, ·))
kernel_rfl DEC_ord.fkck2 : krecLB DEC_ord.kappa2 354 DEC_ord.cx0_2.mlx DEC_ord.kr0_2 DEC_ord.kr1_2 DEC_ord.clo2 = true
kernel_rfl DEC_ord.fkn2 : Nat.ble 354 354 = true
-- the bridge and the pending traces' regions
kernel_rfl DEC_ord.cbridge2 : Host.Ts.Sim.Full.bridgeOf DEC_ord.s9.ffi = Host.Ts.Sim.Full.bridgeOf DEC_ord.s10.ffi
kernel_rfl DEC_ord.cpendR2 : pendRegB DEC_ord.kappa2 (Host.Load.Layers.toLoad DEC_ord.s10.ffi).mlx = true
kernel_rfl DEC_ord.cpendLe2 : Nat.ble (Host.Load.Layers.toLoad DEC_ord.s10.ffi).mlx.next (Host.Load.Layers.toLoad DEC_ord.s9.ffi).mlx.next = true
/-- **The compaction's native shift**, given the call's bookkeeping, its relation's facts (the model's and the
observers') and the canonical closedness. -/
theorem DEC_ord.cshift2 (clean : Conv.NClean (⟨29440, 24920, 3124247, 354⟩ : Conv.Cnt) (Host.Load.Layers.toLoad DEC_ord.s8.ffi).mlx) (hltC : ∀ h, PH (Host.Load.Layers.toLoad DEC_ord.s8.ffi).mlx h → h < (Host.Load.Layers.toLoad DEC_ord.s8.ffi).mlx.next) (nltC : ∀ i, PN (Host.Load.Layers.toLoad DEC_ord.s8.ffi).mlx i → i < (Host.Load.Layers.toLoad DEC_ord.s8.ffi).mlx.nnext) (itemsC : ∀ k v, (Host.Load.Layers.toLoad DEC_ord.s8.ffi).mlx.items.get k = some v → PN (Host.Load.Layers.toLoad DEC_ord.s8.ffi).mlx k) (tracedC : ∀ h o, (Host.Load.Layers.toLoad DEC_ord.s8.ffi).mlx.objs.get h = some o → ∀ i ∈ objTraces o, i < DEC_ord.P2.NL) (cl : SSt (· < 354) DEC_ord.cx0_2.mlx)
    (hobjC : ∀ h, DEC_ord.fxC_2.get h = some () → ((Host.Load.Layers.toLoad DEC_ord.s8.ffi).mlx.objs.get h).isSome = true)
    (hfC : ∀ h, (DEC_ord.krC_2.flags.get h).isSome = true → ((Host.Load.Layers.toLoad DEC_ord.s8.ffi).mlx.objs.get h).isSome = true)
    (htC : ∀ h, (DEC_ord.krC_2.targs.get h).isSome = true → ((Host.Load.Layers.toLoad DEC_ord.s8.ffi).mlx.objs.get h).isSome = true)
    (hclC : ∀ h l, DEC_ord.krC_2.targs.get h = some l → Host.Ts.Sim.Full.STargs (· < (⟨29440, 24920, 3124247, 354⟩ : Conv.Cnt).n) l) :
    Conv.FullShiftQ DEC_ord.P2 354 DEC_ord.kappa2 DEC_ord.s10.ffi DEC_ord.s9.ffi :=
  ⟨DEC_ord.cnshift2 clean hltC nltC itemsC tracedC cl, DEC_ord.cqueue2, fun t ht => bSN_sound (List.all_eq_true.mp DEC_ord.ctokSupp2 t ht),
    DEC_ord.cbridge2,
    liveShift_foot (x0' := Host.Ts.Sim.Full.mlxOf DEC_ord.s10.ffi) (x1' := Host.Ts.Sim.Full.mlxOf DEC_ord.s9.ffi) (DEC_ord.cfoot2 clean hltC nltC itemsC tracedC cl) rfl DEC_ord.ofx0_2 DEC_ord.ofx1_2 hobjC DEC_ord.ff02 DEC_ord.ff12 DEC_ord.ffck2,
    kernShift_foot (x0' := Host.Ts.Sim.Full.mlxOf DEC_ord.s10.ffi) (x1' := Host.Ts.Sim.Full.mlxOf DEC_ord.s9.ffi) (DEC_ord.cfoot2 clean hltC nltC itemsC tracedC cl) rfl DEC_ord.okr0_2 DEC_ord.okr1_2 (Nat.le_of_ble_eq_true DEC_ord.fkn2) hfC htC hclC
      DEC_ord.fkf02 DEC_ord.fkt02 DEC_ord.fkf12 DEC_ord.fkt12 DEC_ord.fkck2,
    pendReg_of rfl DEC_ord.cnh02 DEC_ord.cnh12 (Nat.le_of_ble_eq_true DEC_ord.cpendLe2) DEC_ord.cpendR2⟩

end Host.Load.Run.Tpl
