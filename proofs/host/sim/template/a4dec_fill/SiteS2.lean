import host.sim.template.a4dec_fill.SiteCl2
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
def DEC_fill.P2 : LoadP := ⟨25000, 131072, 1099511627776, 20000, 22539, []⟩
noncomputable abbrev DEC_fill.cx0_2 : Host.Load.LSt := clearTokens (Host.Load.Layers.toLoad DEC_fill.s10.ffi)
noncomputable abbrev DEC_fill.cx1_2 : Host.Load.LSt := clearTokens (Host.Load.Layers.toLoad DEC_fill.s9.ffi)
def DEC_fill.khinv2 : PTrie Nat := Stage.setAll PTrie.nil []
def DEC_fill.kninv2 : PTrie Nat := Stage.setAll PTrie.nil []
/-- The stage's footprint: its written and fresh handles, fresh nodes, written and fresh items. -/
def DEC_fill.cwS2 : List Nat := [29440]
def DEC_fill.cnS2 : List Nat := List.range' 24888 0
def DEC_fill.ciS2 : List Nat := [] ++ List.range' 24888 0

-- the small checks (`MChecks`'s)
kernel_rfl DEC_fill.cnh02 : DEC_fill.kd2.nh0 = DEC_fill.cx0_2.mlx.next
kernel_rfl DEC_fill.cnh12 : DEC_fill.kd2.nh1 = DEC_fill.cx1_2.mlx.next
kernel_rfl DEC_fill.cnn02 : DEC_fill.kd2.nn0 = DEC_fill.cx0_2.mlx.nnext
kernel_rfl DEC_fill.cnn12 : DEC_fill.kd2.nn1 = DEC_fill.cx1_2.mlx.nnext
kernel_rfl DEC_fill.cplo2 : (Nat.blt 0 DEC_fill.P2.lo && Nat.ble DEC_fill.P2.lo DEC_fill.cx0_2.mlx.next && Nat.ble DEC_fill.P2.lo RData.bigHi && Nat.ble RData.bigHi DEC_fill.P2.E) = true
kernel_rfl DEC_fill.ccnt2 : (Nat.ble DEC_fill.cx0_2.mlx.next DEC_fill.cx1_2.mlx.next && Nat.ble DEC_fill.cx0_2.mlx.nnext DEC_fill.cx1_2.mlx.nnext) = true
kernel_rfl DEC_fill.cnband2 : (Nat.blt 0 DEC_fill.P2.NL && Nat.ble DEC_fill.P2.NL DEC_fill.P2.N0 && Nat.ble DEC_fill.P2.N0 DEC_fill.cx0_2.mlx.nnext) = true
kernel_rfl DEC_fill.chbelow2 : DEC_fill.kd2.checkHndBelow = true
kernel_rfl DEC_fill.chren2 : checkRenG DEC_fill.kd2.hnd DEC_fill.khinv2 (phB DEC_fill.cx0_2.mlx) = true
kernel_rfl DEC_fill.cband2 : DEC_fill.kd2.checkBand DEC_fill.P2.lo = true
kernel_rfl DEC_fill.cnh1pos2 : Nat.blt 0 DEC_fill.kd2.nh1 = true
kernel_rfl DEC_fill.cnren2 : checkRenG DEC_fill.kd2.node DEC_fill.kninv2 (pnB DEC_fill.cx0_2.mlx) = true
kernel_rfl DEC_fill.cnlow2 : (PTrie.keysA DEC_fill.kd2.node).all (fun j => Nat.ble DEC_fill.P2.NL j && Nat.blt (DEC_fill.kd2.nodeF j) DEC_fill.cx1_2.mlx.nnext) = true
kernel_rfl DEC_fill.cabs0a2 : DEC_fill.cx0_2.mlx.arrs.get 0 = none
kernel_rfl DEC_fill.cabs0b2 : DEC_fill.cx0_2.mlx.objs.get 0 = none
kernel_rfl DEC_fill.ctok12 : DEC_fill.cx1_2.mlx.tokens = []
kernel_rfl DEC_fill.cpend2 : DEC_fill.cx1_2.mlx.pending = DEC_fill.cx0_2.mlx.pending.map DEC_fill.kappa2.pend
kernel_rfl DEC_fill.cerrh2 : DEC_fill.cx1_2.mlx.errh = DEC_fill.cx0_2.mlx.errh.map DEC_fill.kappa2.arg
kernel_rfl DEC_fill.cfiles2 : DEC_fill.cx1_2.mlx.files = DEC_fill.cx0_2.mlx.files
kernel_rfl DEC_fill.carch2 : DEC_fill.cx1_2.mlx.arch = DEC_fill.cx0_2.mlx.arch
kernel_rfl DEC_fill.csizes2 : DEC_fill.cx1_2.mlx.deviceSizes = DEC_fill.cx0_2.mlx.deviceSizes
kernel_rfl DEC_fill.cwired2 : DEC_fill.cx1_2.mlx.wired = DEC_fill.cx0_2.mlx.wired
kernel_rfl DEC_fill.chost2 : DEC_fill.cx1_2.host = DEC_fill.cx0_2.host
-- the compaction map's addresses are `DEC_fill.kd2`'s
kernel_rfl DEC_fill.ckn02 : DEC_fill.kd2.n0 = 3124247
kernel_rfl DEC_fill.ckn12 : DEC_fill.kd2.n1 = 3124266
kernel_rfl DEC_fill.ckheap2 : (PTrie.keysA DEC_fill.kd2.heap).all (fun x => Nat.ble 3124247 x) = true
kernel_rfl DEC_fill.ckpl2 : (List.range 0).all (fun j => decide (DEC_fill.kd2.heap.get (3124247 + j) = nth? DEC_fill.pl2 j)) = true
-- the map fixes the call's names (`Conv.fixOld_compact`), the call's counters
kernel_rfl DEC_fill.fja2 : Nat.ble 3124247 3124247 = true
kernel_rfl DEC_fill.fn2 : Nat.ble 290 290 = true
kernel_rfl DEC_fill.fjaD2 : Nat.ble 3124247 DEC_fill.kd2.n0 = true
kernel_rfl DEC_fill.fxn2 : Nat.ble 29440 DEC_fill.kd2.nh0 = true
kernel_rfl DEC_fill.fnn2 : Nat.ble 24888 DEC_fill.kd2.nn0 = true
kernel_rfl DEC_fill.fxb2 : Nat.ble 29440 RData.bigHi = true
kernel_rfl DEC_fill.fheap2 : (PTrie.keysA DEC_fill.kd2.heap).all (Nat.ble (⟨29440, 24888, 3124247, 290⟩ : Conv.Cnt).ja) = true
kernel_rfl DEC_fill.fhnd2 : (PTrie.keysA DEC_fill.kd2.hnd).all (Nat.ble (⟨29440, 24888, 3124247, 290⟩ : Conv.Cnt).xn) = true
kernel_rfl DEC_fill.fnode2 : (PTrie.keysA DEC_fill.kd2.node).all (Nat.ble (⟨29440, 24888, 3124247, 290⟩ : Conv.Cnt).nn) = true
/-- The compaction map fixes the call's names. -/
theorem DEC_fill.cfix2 : Conv.FixOld (⟨29440, 24888, 3124247, 290⟩ : Conv.Cnt) DEC_fill.kappa2 :=
  Conv.fixOld_compact (Nat.le_of_ble_eq_true DEC_fill.fja2) (Nat.le_of_ble_eq_true DEC_fill.fn2) (Nat.le_of_ble_eq_true DEC_fill.fjaD2) (Nat.le_of_ble_eq_true DEC_fill.fxn2) (Nat.le_of_ble_eq_true DEC_fill.fnn2) (Nat.le_of_ble_eq_true DEC_fill.fxb2) DEC_fill.fheap2 DEC_fill.fhnd2 DEC_fill.fnode2
kernel_rfl DEC_fill.fcxn2 : (⟨29440, 24888, 3124247, 290⟩ : Conv.Cnt).xn = (Host.Load.Layers.toLoad DEC_fill.s8.ffi).mlx.next
kernel_rfl DEC_fill.fcnn2 : (⟨29440, 24888, 3124247, 290⟩ : Conv.Cnt).nn = (Host.Load.Layers.toLoad DEC_fill.s8.ffi).mlx.nnext
kernel_rfl DEC_fill.fle02 : (Nat.ble (Host.Load.Layers.toLoad DEC_fill.s8.ffi).mlx.next DEC_fill.cx0_2.mlx.next && Nat.ble (Host.Load.Layers.toLoad DEC_fill.s8.ffi).mlx.nnext DEC_fill.cx0_2.mlx.nnext && Nat.ble (Host.Load.Layers.toLoad DEC_fill.s8.ffi).mlx.next RData.bigHi) = true
kernel_rfl DEC_fill.fnk2 : (PTrie.keysA DEC_fill.kd2.node).all (Nat.ble (Host.Load.Layers.toLoad DEC_fill.s8.ffi).mlx.nnext) = true
-- the merged state keeps the call's entries off the stage's footprint
kernel_rfl DEC_fill.f1A2 : DEC_fill.cx1_2.mlx.arrs = Stage.setAll (Host.Load.Layers.toLoad DEC_fill.s8.ffi).mlx.arrs (DEC_fill.cwS2.filterMap fun i => (DEC_fill.cx1_2.mlx.arrs.get i).map (i, ·))
kernel_rfl DEC_fill.f1O2 : DEC_fill.cx1_2.mlx.objs = Stage.setAll (Host.Load.Layers.toLoad DEC_fill.s8.ffi).mlx.objs (DEC_fill.cwS2.filterMap fun i => (DEC_fill.cx1_2.mlx.objs.get i).map (i, ·))
kernel_rfl DEC_fill.f1N2 : DEC_fill.cx1_2.mlx.nodes = Stage.setAll (Host.Load.Layers.toLoad DEC_fill.s8.ffi).mlx.nodes (DEC_fill.cnS2.filterMap fun i => (DEC_fill.cx1_2.mlx.nodes.get i).map (i, ·))
kernel_rfl DEC_fill.f1I2 : DEC_fill.cx1_2.mlx.items = Stage.setAll (Host.Load.Layers.toLoad DEC_fill.s8.ffi).mlx.items (DEC_fill.ciS2.filterMap fun i => (DEC_fill.cx1_2.mlx.items.get i).map (i, ·))
kernel_rfl DEC_fill.fbd2 : (DEC_fill.clo2 ++ DEC_fill.cln2 ++ DEC_fill.cli2 ++ DEC_fill.cwS2 ++ DEC_fill.cnS2 ++ DEC_fill.ciS2).all (fun i => Nat.blt (i / 4096) (4 ^ 31)) = true
kernel_rfl DEC_fill.fincW2 : DEC_fill.cwS2.all (fun h => !Nat.blt h (Host.Load.Layers.toLoad DEC_fill.s8.ffi).mlx.next || DEC_fill.clo2.contains h) = true
kernel_rfl DEC_fill.fincI2 : DEC_fill.ciS2.all (fun k => !Nat.blt k (Host.Load.Layers.toLoad DEC_fill.s8.ffi).mlx.nnext || DEC_fill.cli2.contains k) = true
kernel_rfl DEC_fill.fincN2 : DEC_fill.cnS2.all (Nat.ble (Host.Load.Layers.toLoad DEC_fill.s8.ffi).mlx.nnext) = true
kernel_rfl DEC_fill.flnF2 : DEC_fill.cln2.all (Nat.ble (Host.Load.Layers.toLoad DEC_fill.s8.ffi).mlx.nnext) = true
-- the checks over the changed lists
kernel_rfl DEC_fill.fh2 : DEC_fill.clo2.all (handleOK DEC_fill.kappa2 DEC_fill.P2.lo DEC_fill.cx0_2.mlx DEC_fill.cx1_2.mlx) = true
kernel_rfl DEC_fill.fo2 : DEC_fill.clo2.map (fun h => DEC_fill.cx1_2.mlx.objs.get (DEC_fill.kappa2.handle h)) = DEC_fill.clo2.map (fun h => (DEC_fill.cx0_2.mlx.objs.get h).map DEC_fill.kappa2.nobj)
kernel_rfl DEC_fill.fok2 : DEC_fill.clo2.all (objOK DEC_fill.kappa2 DEC_fill.P2.NL DEC_fill.cx0_2.mlx) = true
kernel_rfl DEC_fill.fnd2 : DEC_fill.cln2.all (nodeOKF DEC_fill.kappa2 DEC_fill.P2 DEC_fill.cx0_2.mlx DEC_fill.cx1_2.mlx) = true
kernel_rfl DEC_fill.fp2 : ((DEC_fill.cln2.filter (fullB DEC_fill.P2))).map (fun i => (DEC_fill.cx1_2.mlx.nodes.get (DEC_fill.kappa2.node i)).map Host.Mlx.Ffi.Node.prim) =
  ((DEC_fill.cln2.filter (fullB DEC_fill.P2))).map (fun i => (DEC_fill.cx0_2.mlx.nodes.get i).map fun nd => DEC_fill.kappa2.prim nd.prim)
kernel_rfl DEC_fill.fnordI2 : incrB DEC_fill.kd2.nodeF (List.range' 24888 0) = true
kernel_rfl DEC_fill.fnordK2 : (PTrie.keysA DEC_fill.kd2.node).all (fun k => Nat.ble 24888 k && Nat.blt k 24888) = true
kernel_rfl DEC_fill.fnordL2 : (DEC_fill.cln2.filter (Nat.ble DEC_fill.P2.N0)).all (fun i => Nat.ble i (DEC_fill.kd2.nodeF i) && (Nat.blt i 24888 || Nat.ble DEC_fill.kd2.nn0 i)) = true
theorem DEC_fill.fnord2 : (DEC_fill.cln2.filter (Nat.ble DEC_fill.P2.N0)).all (fun i => Nat.ble i (DEC_fill.kd2.nodeF i) &&
    (PTrie.keysA DEC_fill.kd2.node).all fun j => !Nat.blt j i || Nat.blt (DEC_fill.kd2.nodeF j) (DEC_fill.kd2.nodeF i)) = true :=
  cnord_of DEC_fill.cnlow2 DEC_fill.cnn12 DEC_fill.fnordI2 DEC_fill.fnordK2 DEC_fill.fnordL2
kernel_rfl DEC_fill.fi2 : DEC_fill.cli2.all (pnB DEC_fill.cx0_2.mlx) = true
kernel_rfl DEC_fill.fii2 : DEC_fill.cli2.all (fun k => decide (DEC_fill.cx1_2.mlx.items.get (DEC_fill.kappa2.node k) = (DEC_fill.cx0_2.mlx.items.get k).map DEC_fill.kappa2.nv)) = true
/-- **The compaction's footprint.** -/
theorem DEC_fill.cfoot2 (clean : Conv.NClean (⟨29440, 24888, 3124247, 290⟩ : Conv.Cnt) (Host.Load.Layers.toLoad DEC_fill.s8.ffi).mlx) (hltC : ∀ h, PH (Host.Load.Layers.toLoad DEC_fill.s8.ffi).mlx h → h < (Host.Load.Layers.toLoad DEC_fill.s8.ffi).mlx.next) (nltC : ∀ i, PN (Host.Load.Layers.toLoad DEC_fill.s8.ffi).mlx i → i < (Host.Load.Layers.toLoad DEC_fill.s8.ffi).mlx.nnext) (itemsC : ∀ k v, (Host.Load.Layers.toLoad DEC_fill.s8.ffi).mlx.items.get k = some v → PN (Host.Load.Layers.toLoad DEC_fill.s8.ffi).mlx k) (tracedC : ∀ h o, (Host.Load.Layers.toLoad DEC_fill.s8.ffi).mlx.objs.get h = some o → ∀ i ∈ objTraces o, i < DEC_fill.P2.NL) (cl : SSt (· < 290) DEC_fill.cx0_2.mlx) :
    Conv.MFoot DEC_fill.P2 290 DEC_fill.kappa2 DEC_fill.kd2 DEC_fill.khinv2 DEC_fill.kninv2 (Host.Load.Layers.toLoad DEC_fill.s8.ffi).mlx DEC_fill.cx0_2.mlx DEC_fill.cx1_2.mlx (⟨29440, 24888, 3124247, 290⟩ : Conv.Cnt) DEC_fill.clo2 DEC_fill.cln2 DEC_fill.cli2 DEC_fill.cwS2 DEC_fill.cnS2 DEC_fill.ciS2 :=
  ⟨rfl, rfl, rfl, DEC_fill.cnh02, DEC_fill.cnh12, DEC_fill.cnn02, DEC_fill.cnn12, DEC_fill.cplo2, DEC_fill.ccnt2, DEC_fill.cnband2, DEC_fill.chbelow2, DEC_fill.chren2, DEC_fill.cband2, DEC_fill.cnh1pos2, DEC_fill.cnren2, DEC_fill.cnlow2, DEC_fill.cabs0a2, DEC_fill.cabs0b2, DEC_fill.ctok12, DEC_fill.cpend2, DEC_fill.cerrh2, DEC_fill.cfiles2, DEC_fill.carch2, DEC_fill.csizes2, DEC_fill.cwired2, DEC_fill.cfix2, clean, DEC_fill.fcxn2, DEC_fill.fcnn2, hltC, nltC, itemsC, tracedC, cl, DEC_fill.fle02, DEC_fill.fnk2, DEC_fill.ckA2, DEC_fill.cobjsK2, DEC_fill.cnodesK2, DEC_fill.citemsK2, DEC_fill.f1A2, DEC_fill.f1O2, DEC_fill.f1N2, DEC_fill.f1I2, DEC_fill.fbd2, DEC_fill.fincW2, DEC_fill.fincI2, DEC_fill.fincN2, DEC_fill.flnF2, DEC_fill.fh2, DEC_fill.fo2, DEC_fill.fok2, DEC_fill.fnd2, DEC_fill.fp2, DEC_fill.fnord2, DEC_fill.fi2, DEC_fill.fii2⟩
theorem DEC_fill.cnshift2 (clean : Conv.NClean (⟨29440, 24888, 3124247, 290⟩ : Conv.Cnt) (Host.Load.Layers.toLoad DEC_fill.s8.ffi).mlx) (hltC : ∀ h, PH (Host.Load.Layers.toLoad DEC_fill.s8.ffi).mlx h → h < (Host.Load.Layers.toLoad DEC_fill.s8.ffi).mlx.next) (nltC : ∀ i, PN (Host.Load.Layers.toLoad DEC_fill.s8.ffi).mlx i → i < (Host.Load.Layers.toLoad DEC_fill.s8.ffi).mlx.nnext) (itemsC : ∀ k v, (Host.Load.Layers.toLoad DEC_fill.s8.ffi).mlx.items.get k = some v → PN (Host.Load.Layers.toLoad DEC_fill.s8.ffi).mlx k) (tracedC : ∀ h o, (Host.Load.Layers.toLoad DEC_fill.s8.ffi).mlx.objs.get h = some o → ∀ i ∈ objTraces o, i < DEC_fill.P2.NL) (cl : SSt (· < 290) DEC_fill.cx0_2.mlx) : NShift DEC_fill.P2 290 DEC_fill.kappa2 DEC_fill.cx0_2 DEC_fill.cx1_2 :=
  Conv.nshift_of_foot (DEC_fill.cfoot2 clean hltC nltC itemsC tracedC cl) DEC_fill.chost2 (compact_a_eq DEC_fill.ckn02 DEC_fill.ckn12 DEC_fill.ckheap2 DEC_fill.ckpl2)

-- the observers: the layers' states at the call, the canonical and the merged state, their footprints and checks
noncomputable def DEC_fill.fxC_2 : PTrie Unit := (Host.Ts.Sim.Full.freedOf DEC_fill.s8.ffi).getD PTrie.nil
noncomputable def DEC_fill.krC_2 : Host.Load.Layers.KRec := (Host.Ts.Sim.Full.krecOf DEC_fill.s8.ffi).getD Host.Load.Layers.KRec.empty
kernel_rfl DEC_fill.ofxC_2 : (Host.Ts.Sim.Full.freedOf DEC_fill.s8.ffi) = some DEC_fill.fxC_2
kernel_rfl DEC_fill.okrC_2 : (Host.Ts.Sim.Full.krecOf DEC_fill.s8.ffi) = some DEC_fill.krC_2
noncomputable def DEC_fill.fx0_2 : PTrie Unit := (Host.Ts.Sim.Full.freedOf DEC_fill.s10.ffi).getD PTrie.nil
noncomputable def DEC_fill.kr0_2 : Host.Load.Layers.KRec := (Host.Ts.Sim.Full.krecOf DEC_fill.s10.ffi).getD Host.Load.Layers.KRec.empty
kernel_rfl DEC_fill.ofx0_2 : (Host.Ts.Sim.Full.freedOf DEC_fill.s10.ffi) = some DEC_fill.fx0_2
kernel_rfl DEC_fill.okr0_2 : (Host.Ts.Sim.Full.krecOf DEC_fill.s10.ffi) = some DEC_fill.kr0_2
noncomputable def DEC_fill.fx1_2 : PTrie Unit := (Host.Ts.Sim.Full.freedOf DEC_fill.s9.ffi).getD PTrie.nil
noncomputable def DEC_fill.kr1_2 : Host.Load.Layers.KRec := (Host.Ts.Sim.Full.krecOf DEC_fill.s9.ffi).getD Host.Load.Layers.KRec.empty
kernel_rfl DEC_fill.ofx1_2 : (Host.Ts.Sim.Full.freedOf DEC_fill.s9.ffi) = some DEC_fill.fx1_2
kernel_rfl DEC_fill.okr1_2 : (Host.Ts.Sim.Full.krecOf DEC_fill.s9.ffi) = some DEC_fill.kr1_2
kernel_rfl DEC_fill.ff02 : DEC_fill.fx0_2 = Stage.setAll DEC_fill.fxC_2 (DEC_fill.clo2.filterMap fun i => (DEC_fill.fx0_2.get i).map (i, ·))
kernel_rfl DEC_fill.ff12 : DEC_fill.fx1_2 = Stage.setAll DEC_fill.fxC_2 (DEC_fill.cwS2.filterMap fun i => (DEC_fill.fx1_2.get i).map (i, ·))
kernel_rfl DEC_fill.ffck2 : freedLB DEC_fill.kappa2 DEC_fill.cx0_2.mlx DEC_fill.fx0_2 DEC_fill.fx1_2 DEC_fill.clo2 = true
kernel_rfl DEC_fill.fkf02 : DEC_fill.kr0_2.flags = Stage.setAll DEC_fill.krC_2.flags (DEC_fill.clo2.filterMap fun i => (DEC_fill.kr0_2.flags.get i).map (i, ·))
kernel_rfl DEC_fill.fkt02 : DEC_fill.kr0_2.targs = Stage.setAll DEC_fill.krC_2.targs (DEC_fill.clo2.filterMap fun i => (DEC_fill.kr0_2.targs.get i).map (i, ·))
kernel_rfl DEC_fill.fkf12 : DEC_fill.kr1_2.flags = Stage.setAll DEC_fill.krC_2.flags (DEC_fill.cwS2.filterMap fun i => (DEC_fill.kr1_2.flags.get i).map (i, ·))
kernel_rfl DEC_fill.fkt12 : DEC_fill.kr1_2.targs = Stage.setAll DEC_fill.krC_2.targs (DEC_fill.cwS2.filterMap fun i => (DEC_fill.kr1_2.targs.get i).map (i, ·))
kernel_rfl DEC_fill.fkck2 : krecLB DEC_fill.kappa2 290 DEC_fill.cx0_2.mlx DEC_fill.kr0_2 DEC_fill.kr1_2 DEC_fill.clo2 = true
kernel_rfl DEC_fill.fkn2 : Nat.ble 290 290 = true
-- the bridge and the pending traces' regions
kernel_rfl DEC_fill.cbridge2 : Host.Ts.Sim.Full.bridgeOf DEC_fill.s9.ffi = Host.Ts.Sim.Full.bridgeOf DEC_fill.s10.ffi
kernel_rfl DEC_fill.cpendR2 : pendRegB DEC_fill.kappa2 (Host.Load.Layers.toLoad DEC_fill.s10.ffi).mlx = true
kernel_rfl DEC_fill.cpendLe2 : Nat.ble (Host.Load.Layers.toLoad DEC_fill.s10.ffi).mlx.next (Host.Load.Layers.toLoad DEC_fill.s9.ffi).mlx.next = true
/-- **The compaction's native shift**, given the call's bookkeeping, its relation's facts (the model's and the
observers') and the canonical closedness. -/
theorem DEC_fill.cshift2 (clean : Conv.NClean (⟨29440, 24888, 3124247, 290⟩ : Conv.Cnt) (Host.Load.Layers.toLoad DEC_fill.s8.ffi).mlx) (hltC : ∀ h, PH (Host.Load.Layers.toLoad DEC_fill.s8.ffi).mlx h → h < (Host.Load.Layers.toLoad DEC_fill.s8.ffi).mlx.next) (nltC : ∀ i, PN (Host.Load.Layers.toLoad DEC_fill.s8.ffi).mlx i → i < (Host.Load.Layers.toLoad DEC_fill.s8.ffi).mlx.nnext) (itemsC : ∀ k v, (Host.Load.Layers.toLoad DEC_fill.s8.ffi).mlx.items.get k = some v → PN (Host.Load.Layers.toLoad DEC_fill.s8.ffi).mlx k) (tracedC : ∀ h o, (Host.Load.Layers.toLoad DEC_fill.s8.ffi).mlx.objs.get h = some o → ∀ i ∈ objTraces o, i < DEC_fill.P2.NL) (cl : SSt (· < 290) DEC_fill.cx0_2.mlx)
    (hobjC : ∀ h, DEC_fill.fxC_2.get h = some () → ((Host.Load.Layers.toLoad DEC_fill.s8.ffi).mlx.objs.get h).isSome = true)
    (hfC : ∀ h, (DEC_fill.krC_2.flags.get h).isSome = true → ((Host.Load.Layers.toLoad DEC_fill.s8.ffi).mlx.objs.get h).isSome = true)
    (htC : ∀ h, (DEC_fill.krC_2.targs.get h).isSome = true → ((Host.Load.Layers.toLoad DEC_fill.s8.ffi).mlx.objs.get h).isSome = true)
    (hclC : ∀ h l, DEC_fill.krC_2.targs.get h = some l → Host.Ts.Sim.Full.STargs (· < (⟨29440, 24888, 3124247, 290⟩ : Conv.Cnt).n) l) :
    Conv.FullShiftQ DEC_fill.P2 290 DEC_fill.kappa2 DEC_fill.s10.ffi DEC_fill.s9.ffi :=
  ⟨DEC_fill.cnshift2 clean hltC nltC itemsC tracedC cl, DEC_fill.cqueue2, fun t ht => bSN_sound (List.all_eq_true.mp DEC_fill.ctokSupp2 t ht),
    DEC_fill.cbridge2,
    liveShift_foot (x0' := Host.Ts.Sim.Full.mlxOf DEC_fill.s10.ffi) (x1' := Host.Ts.Sim.Full.mlxOf DEC_fill.s9.ffi) (DEC_fill.cfoot2 clean hltC nltC itemsC tracedC cl) rfl DEC_fill.ofx0_2 DEC_fill.ofx1_2 hobjC DEC_fill.ff02 DEC_fill.ff12 DEC_fill.ffck2,
    kernShift_foot (x0' := Host.Ts.Sim.Full.mlxOf DEC_fill.s10.ffi) (x1' := Host.Ts.Sim.Full.mlxOf DEC_fill.s9.ffi) (DEC_fill.cfoot2 clean hltC nltC itemsC tracedC cl) rfl DEC_fill.okr0_2 DEC_fill.okr1_2 (Nat.le_of_ble_eq_true DEC_fill.fkn2) hfC htC hclC
      DEC_fill.fkf02 DEC_fill.fkt02 DEC_fill.fkf12 DEC_fill.fkt12 DEC_fill.fkck2,
    pendReg_of rfl DEC_fill.cnh02 DEC_fill.cnh12 (Nat.le_of_ble_eq_true DEC_fill.cpendLe2) DEC_fill.cpendR2⟩

end Host.Load.Run.Tpl
