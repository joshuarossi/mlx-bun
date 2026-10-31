import host.sim.template.a4dec_clear.SiteCl2
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
def DEC_clear.P2 : LoadP := ⟨25000, 131072, 1099511627776, 20000, 22539, []⟩
noncomputable abbrev DEC_clear.cx0_2 : Host.Load.LSt := clearTokens (Host.Load.Layers.toLoad DEC_clear.s10.ffi)
noncomputable abbrev DEC_clear.cx1_2 : Host.Load.LSt := clearTokens (Host.Load.Layers.toLoad DEC_clear.s9.ffi)
def DEC_clear.khinv2 : PTrie Nat := Stage.setAll PTrie.nil []
def DEC_clear.kninv2 : PTrie Nat := Stage.setAll PTrie.nil []
/-- The stage's footprint: its written and fresh handles, fresh nodes, written and fresh items. -/
def DEC_clear.cwS2 : List Nat := [29440]
def DEC_clear.cnS2 : List Nat := List.range' 24920 0
def DEC_clear.ciS2 : List Nat := [] ++ List.range' 24920 0

-- the small checks (`MChecks`'s)
kernel_rfl DEC_clear.cnh02 : DEC_clear.kd2.nh0 = DEC_clear.cx0_2.mlx.next
kernel_rfl DEC_clear.cnh12 : DEC_clear.kd2.nh1 = DEC_clear.cx1_2.mlx.next
kernel_rfl DEC_clear.cnn02 : DEC_clear.kd2.nn0 = DEC_clear.cx0_2.mlx.nnext
kernel_rfl DEC_clear.cnn12 : DEC_clear.kd2.nn1 = DEC_clear.cx1_2.mlx.nnext
kernel_rfl DEC_clear.cplo2 : (Nat.blt 0 DEC_clear.P2.lo && Nat.ble DEC_clear.P2.lo DEC_clear.cx0_2.mlx.next && Nat.ble DEC_clear.P2.lo RData.bigHi && Nat.ble RData.bigHi DEC_clear.P2.E) = true
kernel_rfl DEC_clear.ccnt2 : (Nat.ble DEC_clear.cx0_2.mlx.next DEC_clear.cx1_2.mlx.next && Nat.ble DEC_clear.cx0_2.mlx.nnext DEC_clear.cx1_2.mlx.nnext) = true
kernel_rfl DEC_clear.cnband2 : (Nat.blt 0 DEC_clear.P2.NL && Nat.ble DEC_clear.P2.NL DEC_clear.P2.N0 && Nat.ble DEC_clear.P2.N0 DEC_clear.cx0_2.mlx.nnext) = true
kernel_rfl DEC_clear.chbelow2 : DEC_clear.kd2.checkHndBelow = true
kernel_rfl DEC_clear.chren2 : checkRenG DEC_clear.kd2.hnd DEC_clear.khinv2 (phB DEC_clear.cx0_2.mlx) = true
kernel_rfl DEC_clear.cband2 : DEC_clear.kd2.checkBand DEC_clear.P2.lo = true
kernel_rfl DEC_clear.cnh1pos2 : Nat.blt 0 DEC_clear.kd2.nh1 = true
kernel_rfl DEC_clear.cnren2 : checkRenG DEC_clear.kd2.node DEC_clear.kninv2 (pnB DEC_clear.cx0_2.mlx) = true
kernel_rfl DEC_clear.cnlow2 : (PTrie.keysA DEC_clear.kd2.node).all (fun j => Nat.ble DEC_clear.P2.NL j && Nat.blt (DEC_clear.kd2.nodeF j) DEC_clear.cx1_2.mlx.nnext) = true
kernel_rfl DEC_clear.cabs0a2 : DEC_clear.cx0_2.mlx.arrs.get 0 = none
kernel_rfl DEC_clear.cabs0b2 : DEC_clear.cx0_2.mlx.objs.get 0 = none
kernel_rfl DEC_clear.ctok12 : DEC_clear.cx1_2.mlx.tokens = []
kernel_rfl DEC_clear.cpend2 : DEC_clear.cx1_2.mlx.pending = DEC_clear.cx0_2.mlx.pending.map DEC_clear.kappa2.pend
kernel_rfl DEC_clear.cerrh2 : DEC_clear.cx1_2.mlx.errh = DEC_clear.cx0_2.mlx.errh.map DEC_clear.kappa2.arg
kernel_rfl DEC_clear.cfiles2 : DEC_clear.cx1_2.mlx.files = DEC_clear.cx0_2.mlx.files
kernel_rfl DEC_clear.carch2 : DEC_clear.cx1_2.mlx.arch = DEC_clear.cx0_2.mlx.arch
kernel_rfl DEC_clear.csizes2 : DEC_clear.cx1_2.mlx.deviceSizes = DEC_clear.cx0_2.mlx.deviceSizes
kernel_rfl DEC_clear.cwired2 : DEC_clear.cx1_2.mlx.wired = DEC_clear.cx0_2.mlx.wired
kernel_rfl DEC_clear.chost2 : DEC_clear.cx1_2.host = DEC_clear.cx0_2.host
-- the compaction map's addresses are `DEC_clear.kd2`'s
kernel_rfl DEC_clear.ckn02 : DEC_clear.kd2.n0 = 3124248
kernel_rfl DEC_clear.ckn12 : DEC_clear.kd2.n1 = 3124267
kernel_rfl DEC_clear.ckheap2 : (PTrie.keysA DEC_clear.kd2.heap).all (fun x => Nat.ble 3124248 x) = true
kernel_rfl DEC_clear.ckpl2 : (List.range 0).all (fun j => decide (DEC_clear.kd2.heap.get (3124248 + j) = nth? DEC_clear.pl2 j)) = true
-- the map fixes the call's names (`Conv.fixOld_compact`), the call's counters
kernel_rfl DEC_clear.fja2 : Nat.ble 3124248 3124248 = true
kernel_rfl DEC_clear.fn2 : Nat.ble 354 354 = true
kernel_rfl DEC_clear.fjaD2 : Nat.ble 3124248 DEC_clear.kd2.n0 = true
kernel_rfl DEC_clear.fxn2 : Nat.ble 29440 DEC_clear.kd2.nh0 = true
kernel_rfl DEC_clear.fnn2 : Nat.ble 24920 DEC_clear.kd2.nn0 = true
kernel_rfl DEC_clear.fxb2 : Nat.ble 29440 RData.bigHi = true
kernel_rfl DEC_clear.fheap2 : (PTrie.keysA DEC_clear.kd2.heap).all (Nat.ble (⟨29440, 24920, 3124248, 354⟩ : Conv.Cnt).ja) = true
kernel_rfl DEC_clear.fhnd2 : (PTrie.keysA DEC_clear.kd2.hnd).all (Nat.ble (⟨29440, 24920, 3124248, 354⟩ : Conv.Cnt).xn) = true
kernel_rfl DEC_clear.fnode2 : (PTrie.keysA DEC_clear.kd2.node).all (Nat.ble (⟨29440, 24920, 3124248, 354⟩ : Conv.Cnt).nn) = true
/-- The compaction map fixes the call's names. -/
theorem DEC_clear.cfix2 : Conv.FixOld (⟨29440, 24920, 3124248, 354⟩ : Conv.Cnt) DEC_clear.kappa2 :=
  Conv.fixOld_compact (Nat.le_of_ble_eq_true DEC_clear.fja2) (Nat.le_of_ble_eq_true DEC_clear.fn2) (Nat.le_of_ble_eq_true DEC_clear.fjaD2) (Nat.le_of_ble_eq_true DEC_clear.fxn2) (Nat.le_of_ble_eq_true DEC_clear.fnn2) (Nat.le_of_ble_eq_true DEC_clear.fxb2) DEC_clear.fheap2 DEC_clear.fhnd2 DEC_clear.fnode2
kernel_rfl DEC_clear.fcxn2 : (⟨29440, 24920, 3124248, 354⟩ : Conv.Cnt).xn = (Host.Load.Layers.toLoad DEC_clear.s8.ffi).mlx.next
kernel_rfl DEC_clear.fcnn2 : (⟨29440, 24920, 3124248, 354⟩ : Conv.Cnt).nn = (Host.Load.Layers.toLoad DEC_clear.s8.ffi).mlx.nnext
kernel_rfl DEC_clear.fle02 : (Nat.ble (Host.Load.Layers.toLoad DEC_clear.s8.ffi).mlx.next DEC_clear.cx0_2.mlx.next && Nat.ble (Host.Load.Layers.toLoad DEC_clear.s8.ffi).mlx.nnext DEC_clear.cx0_2.mlx.nnext && Nat.ble (Host.Load.Layers.toLoad DEC_clear.s8.ffi).mlx.next RData.bigHi) = true
kernel_rfl DEC_clear.fnk2 : (PTrie.keysA DEC_clear.kd2.node).all (Nat.ble (Host.Load.Layers.toLoad DEC_clear.s8.ffi).mlx.nnext) = true
-- the merged state keeps the call's entries off the stage's footprint
kernel_rfl DEC_clear.f1A2 : DEC_clear.cx1_2.mlx.arrs = Stage.setAll (Host.Load.Layers.toLoad DEC_clear.s8.ffi).mlx.arrs (DEC_clear.cwS2.filterMap fun i => (DEC_clear.cx1_2.mlx.arrs.get i).map (i, ·))
kernel_rfl DEC_clear.f1O2 : DEC_clear.cx1_2.mlx.objs = Stage.setAll (Host.Load.Layers.toLoad DEC_clear.s8.ffi).mlx.objs (DEC_clear.cwS2.filterMap fun i => (DEC_clear.cx1_2.mlx.objs.get i).map (i, ·))
kernel_rfl DEC_clear.f1N2 : DEC_clear.cx1_2.mlx.nodes = Stage.setAll (Host.Load.Layers.toLoad DEC_clear.s8.ffi).mlx.nodes (DEC_clear.cnS2.filterMap fun i => (DEC_clear.cx1_2.mlx.nodes.get i).map (i, ·))
kernel_rfl DEC_clear.f1I2 : DEC_clear.cx1_2.mlx.items = Stage.setAll (Host.Load.Layers.toLoad DEC_clear.s8.ffi).mlx.items (DEC_clear.ciS2.filterMap fun i => (DEC_clear.cx1_2.mlx.items.get i).map (i, ·))
kernel_rfl DEC_clear.fbd2 : (DEC_clear.clo2 ++ DEC_clear.cln2 ++ DEC_clear.cli2 ++ DEC_clear.cwS2 ++ DEC_clear.cnS2 ++ DEC_clear.ciS2).all (fun i => Nat.blt (i / 4096) (4 ^ 31)) = true
kernel_rfl DEC_clear.fincW2 : DEC_clear.cwS2.all (fun h => !Nat.blt h (Host.Load.Layers.toLoad DEC_clear.s8.ffi).mlx.next || DEC_clear.clo2.contains h) = true
kernel_rfl DEC_clear.fincI2 : DEC_clear.ciS2.all (fun k => !Nat.blt k (Host.Load.Layers.toLoad DEC_clear.s8.ffi).mlx.nnext || DEC_clear.cli2.contains k) = true
kernel_rfl DEC_clear.fincN2 : DEC_clear.cnS2.all (Nat.ble (Host.Load.Layers.toLoad DEC_clear.s8.ffi).mlx.nnext) = true
kernel_rfl DEC_clear.flnF2 : DEC_clear.cln2.all (Nat.ble (Host.Load.Layers.toLoad DEC_clear.s8.ffi).mlx.nnext) = true
-- the checks over the changed lists
kernel_rfl DEC_clear.fh2 : DEC_clear.clo2.all (handleOK DEC_clear.kappa2 DEC_clear.P2.lo DEC_clear.cx0_2.mlx DEC_clear.cx1_2.mlx) = true
kernel_rfl DEC_clear.fo2 : DEC_clear.clo2.map (fun h => DEC_clear.cx1_2.mlx.objs.get (DEC_clear.kappa2.handle h)) = DEC_clear.clo2.map (fun h => (DEC_clear.cx0_2.mlx.objs.get h).map DEC_clear.kappa2.nobj)
kernel_rfl DEC_clear.fok2 : DEC_clear.clo2.all (objOK DEC_clear.kappa2 DEC_clear.P2.NL DEC_clear.cx0_2.mlx) = true
kernel_rfl DEC_clear.fnd2 : DEC_clear.cln2.all (nodeOKF DEC_clear.kappa2 DEC_clear.P2 DEC_clear.cx0_2.mlx DEC_clear.cx1_2.mlx) = true
kernel_rfl DEC_clear.fp2 : ((DEC_clear.cln2.filter (fullB DEC_clear.P2))).map (fun i => (DEC_clear.cx1_2.mlx.nodes.get (DEC_clear.kappa2.node i)).map Host.Mlx.Ffi.Node.prim) =
  ((DEC_clear.cln2.filter (fullB DEC_clear.P2))).map (fun i => (DEC_clear.cx0_2.mlx.nodes.get i).map fun nd => DEC_clear.kappa2.prim nd.prim)
kernel_rfl DEC_clear.fnordI2 : incrB DEC_clear.kd2.nodeF (List.range' 24920 0) = true
kernel_rfl DEC_clear.fnordK2 : (PTrie.keysA DEC_clear.kd2.node).all (fun k => Nat.ble 24920 k && Nat.blt k 24920) = true
kernel_rfl DEC_clear.fnordL2 : (DEC_clear.cln2.filter (Nat.ble DEC_clear.P2.N0)).all (fun i => Nat.ble i (DEC_clear.kd2.nodeF i) && (Nat.blt i 24920 || Nat.ble DEC_clear.kd2.nn0 i)) = true
theorem DEC_clear.fnord2 : (DEC_clear.cln2.filter (Nat.ble DEC_clear.P2.N0)).all (fun i => Nat.ble i (DEC_clear.kd2.nodeF i) &&
    (PTrie.keysA DEC_clear.kd2.node).all fun j => !Nat.blt j i || Nat.blt (DEC_clear.kd2.nodeF j) (DEC_clear.kd2.nodeF i)) = true :=
  cnord_of DEC_clear.cnlow2 DEC_clear.cnn12 DEC_clear.fnordI2 DEC_clear.fnordK2 DEC_clear.fnordL2
kernel_rfl DEC_clear.fi2 : DEC_clear.cli2.all (pnB DEC_clear.cx0_2.mlx) = true
kernel_rfl DEC_clear.fii2 : DEC_clear.cli2.all (fun k => decide (DEC_clear.cx1_2.mlx.items.get (DEC_clear.kappa2.node k) = (DEC_clear.cx0_2.mlx.items.get k).map DEC_clear.kappa2.nv)) = true
/-- **The compaction's footprint.** -/
theorem DEC_clear.cfoot2 (clean : Conv.NClean (⟨29440, 24920, 3124248, 354⟩ : Conv.Cnt) (Host.Load.Layers.toLoad DEC_clear.s8.ffi).mlx) (hltC : ∀ h, PH (Host.Load.Layers.toLoad DEC_clear.s8.ffi).mlx h → h < (Host.Load.Layers.toLoad DEC_clear.s8.ffi).mlx.next) (nltC : ∀ i, PN (Host.Load.Layers.toLoad DEC_clear.s8.ffi).mlx i → i < (Host.Load.Layers.toLoad DEC_clear.s8.ffi).mlx.nnext) (itemsC : ∀ k v, (Host.Load.Layers.toLoad DEC_clear.s8.ffi).mlx.items.get k = some v → PN (Host.Load.Layers.toLoad DEC_clear.s8.ffi).mlx k) (tracedC : ∀ h o, (Host.Load.Layers.toLoad DEC_clear.s8.ffi).mlx.objs.get h = some o → ∀ i ∈ objTraces o, i < DEC_clear.P2.NL) (cl : SSt (· < 354) DEC_clear.cx0_2.mlx) :
    Conv.MFoot DEC_clear.P2 354 DEC_clear.kappa2 DEC_clear.kd2 DEC_clear.khinv2 DEC_clear.kninv2 (Host.Load.Layers.toLoad DEC_clear.s8.ffi).mlx DEC_clear.cx0_2.mlx DEC_clear.cx1_2.mlx (⟨29440, 24920, 3124248, 354⟩ : Conv.Cnt) DEC_clear.clo2 DEC_clear.cln2 DEC_clear.cli2 DEC_clear.cwS2 DEC_clear.cnS2 DEC_clear.ciS2 :=
  ⟨rfl, rfl, rfl, DEC_clear.cnh02, DEC_clear.cnh12, DEC_clear.cnn02, DEC_clear.cnn12, DEC_clear.cplo2, DEC_clear.ccnt2, DEC_clear.cnband2, DEC_clear.chbelow2, DEC_clear.chren2, DEC_clear.cband2, DEC_clear.cnh1pos2, DEC_clear.cnren2, DEC_clear.cnlow2, DEC_clear.cabs0a2, DEC_clear.cabs0b2, DEC_clear.ctok12, DEC_clear.cpend2, DEC_clear.cerrh2, DEC_clear.cfiles2, DEC_clear.carch2, DEC_clear.csizes2, DEC_clear.cwired2, DEC_clear.cfix2, clean, DEC_clear.fcxn2, DEC_clear.fcnn2, hltC, nltC, itemsC, tracedC, cl, DEC_clear.fle02, DEC_clear.fnk2, DEC_clear.ckA2, DEC_clear.cobjsK2, DEC_clear.cnodesK2, DEC_clear.citemsK2, DEC_clear.f1A2, DEC_clear.f1O2, DEC_clear.f1N2, DEC_clear.f1I2, DEC_clear.fbd2, DEC_clear.fincW2, DEC_clear.fincI2, DEC_clear.fincN2, DEC_clear.flnF2, DEC_clear.fh2, DEC_clear.fo2, DEC_clear.fok2, DEC_clear.fnd2, DEC_clear.fp2, DEC_clear.fnord2, DEC_clear.fi2, DEC_clear.fii2⟩
theorem DEC_clear.cnshift2 (clean : Conv.NClean (⟨29440, 24920, 3124248, 354⟩ : Conv.Cnt) (Host.Load.Layers.toLoad DEC_clear.s8.ffi).mlx) (hltC : ∀ h, PH (Host.Load.Layers.toLoad DEC_clear.s8.ffi).mlx h → h < (Host.Load.Layers.toLoad DEC_clear.s8.ffi).mlx.next) (nltC : ∀ i, PN (Host.Load.Layers.toLoad DEC_clear.s8.ffi).mlx i → i < (Host.Load.Layers.toLoad DEC_clear.s8.ffi).mlx.nnext) (itemsC : ∀ k v, (Host.Load.Layers.toLoad DEC_clear.s8.ffi).mlx.items.get k = some v → PN (Host.Load.Layers.toLoad DEC_clear.s8.ffi).mlx k) (tracedC : ∀ h o, (Host.Load.Layers.toLoad DEC_clear.s8.ffi).mlx.objs.get h = some o → ∀ i ∈ objTraces o, i < DEC_clear.P2.NL) (cl : SSt (· < 354) DEC_clear.cx0_2.mlx) : NShift DEC_clear.P2 354 DEC_clear.kappa2 DEC_clear.cx0_2 DEC_clear.cx1_2 :=
  Conv.nshift_of_foot (DEC_clear.cfoot2 clean hltC nltC itemsC tracedC cl) DEC_clear.chost2 (compact_a_eq DEC_clear.ckn02 DEC_clear.ckn12 DEC_clear.ckheap2 DEC_clear.ckpl2)

-- the observers: the layers' states at the call, the canonical and the merged state, their footprints and checks
noncomputable def DEC_clear.fxC_2 : PTrie Unit := (Host.Ts.Sim.Full.freedOf DEC_clear.s8.ffi).getD PTrie.nil
noncomputable def DEC_clear.krC_2 : Host.Load.Layers.KRec := (Host.Ts.Sim.Full.krecOf DEC_clear.s8.ffi).getD Host.Load.Layers.KRec.empty
kernel_rfl DEC_clear.ofxC_2 : (Host.Ts.Sim.Full.freedOf DEC_clear.s8.ffi) = some DEC_clear.fxC_2
kernel_rfl DEC_clear.okrC_2 : (Host.Ts.Sim.Full.krecOf DEC_clear.s8.ffi) = some DEC_clear.krC_2
noncomputable def DEC_clear.fx0_2 : PTrie Unit := (Host.Ts.Sim.Full.freedOf DEC_clear.s10.ffi).getD PTrie.nil
noncomputable def DEC_clear.kr0_2 : Host.Load.Layers.KRec := (Host.Ts.Sim.Full.krecOf DEC_clear.s10.ffi).getD Host.Load.Layers.KRec.empty
kernel_rfl DEC_clear.ofx0_2 : (Host.Ts.Sim.Full.freedOf DEC_clear.s10.ffi) = some DEC_clear.fx0_2
kernel_rfl DEC_clear.okr0_2 : (Host.Ts.Sim.Full.krecOf DEC_clear.s10.ffi) = some DEC_clear.kr0_2
noncomputable def DEC_clear.fx1_2 : PTrie Unit := (Host.Ts.Sim.Full.freedOf DEC_clear.s9.ffi).getD PTrie.nil
noncomputable def DEC_clear.kr1_2 : Host.Load.Layers.KRec := (Host.Ts.Sim.Full.krecOf DEC_clear.s9.ffi).getD Host.Load.Layers.KRec.empty
kernel_rfl DEC_clear.ofx1_2 : (Host.Ts.Sim.Full.freedOf DEC_clear.s9.ffi) = some DEC_clear.fx1_2
kernel_rfl DEC_clear.okr1_2 : (Host.Ts.Sim.Full.krecOf DEC_clear.s9.ffi) = some DEC_clear.kr1_2
kernel_rfl DEC_clear.ff02 : DEC_clear.fx0_2 = Stage.setAll DEC_clear.fxC_2 (DEC_clear.clo2.filterMap fun i => (DEC_clear.fx0_2.get i).map (i, ·))
kernel_rfl DEC_clear.ff12 : DEC_clear.fx1_2 = Stage.setAll DEC_clear.fxC_2 (DEC_clear.cwS2.filterMap fun i => (DEC_clear.fx1_2.get i).map (i, ·))
kernel_rfl DEC_clear.ffck2 : freedLB DEC_clear.kappa2 DEC_clear.cx0_2.mlx DEC_clear.fx0_2 DEC_clear.fx1_2 DEC_clear.clo2 = true
kernel_rfl DEC_clear.fkf02 : DEC_clear.kr0_2.flags = Stage.setAll DEC_clear.krC_2.flags (DEC_clear.clo2.filterMap fun i => (DEC_clear.kr0_2.flags.get i).map (i, ·))
kernel_rfl DEC_clear.fkt02 : DEC_clear.kr0_2.targs = Stage.setAll DEC_clear.krC_2.targs (DEC_clear.clo2.filterMap fun i => (DEC_clear.kr0_2.targs.get i).map (i, ·))
kernel_rfl DEC_clear.fkf12 : DEC_clear.kr1_2.flags = Stage.setAll DEC_clear.krC_2.flags (DEC_clear.cwS2.filterMap fun i => (DEC_clear.kr1_2.flags.get i).map (i, ·))
kernel_rfl DEC_clear.fkt12 : DEC_clear.kr1_2.targs = Stage.setAll DEC_clear.krC_2.targs (DEC_clear.cwS2.filterMap fun i => (DEC_clear.kr1_2.targs.get i).map (i, ·))
kernel_rfl DEC_clear.fkck2 : krecLB DEC_clear.kappa2 354 DEC_clear.cx0_2.mlx DEC_clear.kr0_2 DEC_clear.kr1_2 DEC_clear.clo2 = true
kernel_rfl DEC_clear.fkn2 : Nat.ble 354 354 = true
-- the bridge and the pending traces' regions
kernel_rfl DEC_clear.cbridge2 : Host.Ts.Sim.Full.bridgeOf DEC_clear.s9.ffi = Host.Ts.Sim.Full.bridgeOf DEC_clear.s10.ffi
kernel_rfl DEC_clear.cpendR2 : pendRegB DEC_clear.kappa2 (Host.Load.Layers.toLoad DEC_clear.s10.ffi).mlx = true
kernel_rfl DEC_clear.cpendLe2 : Nat.ble (Host.Load.Layers.toLoad DEC_clear.s10.ffi).mlx.next (Host.Load.Layers.toLoad DEC_clear.s9.ffi).mlx.next = true
/-- **The compaction's native shift**, given the call's bookkeeping, its relation's facts (the model's and the
observers') and the canonical closedness. -/
theorem DEC_clear.cshift2 (clean : Conv.NClean (⟨29440, 24920, 3124248, 354⟩ : Conv.Cnt) (Host.Load.Layers.toLoad DEC_clear.s8.ffi).mlx) (hltC : ∀ h, PH (Host.Load.Layers.toLoad DEC_clear.s8.ffi).mlx h → h < (Host.Load.Layers.toLoad DEC_clear.s8.ffi).mlx.next) (nltC : ∀ i, PN (Host.Load.Layers.toLoad DEC_clear.s8.ffi).mlx i → i < (Host.Load.Layers.toLoad DEC_clear.s8.ffi).mlx.nnext) (itemsC : ∀ k v, (Host.Load.Layers.toLoad DEC_clear.s8.ffi).mlx.items.get k = some v → PN (Host.Load.Layers.toLoad DEC_clear.s8.ffi).mlx k) (tracedC : ∀ h o, (Host.Load.Layers.toLoad DEC_clear.s8.ffi).mlx.objs.get h = some o → ∀ i ∈ objTraces o, i < DEC_clear.P2.NL) (cl : SSt (· < 354) DEC_clear.cx0_2.mlx)
    (hobjC : ∀ h, DEC_clear.fxC_2.get h = some () → ((Host.Load.Layers.toLoad DEC_clear.s8.ffi).mlx.objs.get h).isSome = true)
    (hfC : ∀ h, (DEC_clear.krC_2.flags.get h).isSome = true → ((Host.Load.Layers.toLoad DEC_clear.s8.ffi).mlx.objs.get h).isSome = true)
    (htC : ∀ h, (DEC_clear.krC_2.targs.get h).isSome = true → ((Host.Load.Layers.toLoad DEC_clear.s8.ffi).mlx.objs.get h).isSome = true)
    (hclC : ∀ h l, DEC_clear.krC_2.targs.get h = some l → Host.Ts.Sim.Full.STargs (· < (⟨29440, 24920, 3124248, 354⟩ : Conv.Cnt).n) l) :
    Conv.FullShiftQ DEC_clear.P2 354 DEC_clear.kappa2 DEC_clear.s10.ffi DEC_clear.s9.ffi :=
  ⟨DEC_clear.cnshift2 clean hltC nltC itemsC tracedC cl, DEC_clear.cqueue2, fun t ht => bSN_sound (List.all_eq_true.mp DEC_clear.ctokSupp2 t ht),
    DEC_clear.cbridge2,
    liveShift_foot (x0' := Host.Ts.Sim.Full.mlxOf DEC_clear.s10.ffi) (x1' := Host.Ts.Sim.Full.mlxOf DEC_clear.s9.ffi) (DEC_clear.cfoot2 clean hltC nltC itemsC tracedC cl) rfl DEC_clear.ofx0_2 DEC_clear.ofx1_2 hobjC DEC_clear.ff02 DEC_clear.ff12 DEC_clear.ffck2,
    kernShift_foot (x0' := Host.Ts.Sim.Full.mlxOf DEC_clear.s10.ffi) (x1' := Host.Ts.Sim.Full.mlxOf DEC_clear.s9.ffi) (DEC_clear.cfoot2 clean hltC nltC itemsC tracedC cl) rfl DEC_clear.okr0_2 DEC_clear.okr1_2 (Nat.le_of_ble_eq_true DEC_clear.fkn2) hfC htC hclC
      DEC_clear.fkf02 DEC_clear.fkt02 DEC_clear.fkf12 DEC_clear.fkt12 DEC_clear.fkck2,
    pendReg_of rfl DEC_clear.cnh02 DEC_clear.cnh12 (Nat.le_of_ble_eq_true DEC_clear.cpendLe2) DEC_clear.cpendR2⟩

end Host.Load.Run.Tpl
