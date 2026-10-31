import host.sim.template.a4pre_first_tail_x15_r0_body.SiteCl109
import host.sim.conv.CompactFull
import host.sim.template.FootGen
set_option Elab.async false
namespace Host.Load.Run.Tpl
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
open Host.Ts Host.Ts.Sim Host.Ts.Sim.Template

/-! The compaction's native shift at call site 109 from its footprint (`Conv.nshift_of_foot`), and the observers'
(`liveShift_foot`, `kernShift_foot`): `Conv.FullShiftQ` for `Conv.full_compactQ`, given the call's bookkeeping and its
relation's facts. -/

/-- The load parameters of the chain (band-free: its start's node counter as `NL` and `N0`). -/
def PRE_first_tail_x15_r0_body.Pc109 : LoadP := ⟨18151, 131072, 1099511627776, 15235, 15235, []⟩
/-- The site's band raised to the map's checked fixed-node prefix, including newly recorded closure traces. -/
def PRE_first_tail_x15_r0_body.P109 : LoadP := PRE_first_tail_x15_r0_body.Pc109.raise 17451
kernel_rfl PRE_first_tail_x15_r0_body.craise109 : Nat.ble PRE_first_tail_x15_r0_body.Pc109.N0 17451 = true
theorem PRE_first_tail_x15_r0_body.raised109 : Host.Ts.Sim.Full.Raised PRE_first_tail_x15_r0_body.Pc109 PRE_first_tail_x15_r0_body.P109 :=
  .inr ⟨17451, rfl, Nat.le_of_ble_eq_true PRE_first_tail_x15_r0_body.craise109, rfl⟩
noncomputable abbrev PRE_first_tail_x15_r0_body.cx0_109 : Host.Load.LSt := clearTokens (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1061.ffi)
noncomputable abbrev PRE_first_tail_x15_r0_body.cx1_109 : Host.Load.LSt := clearTokens (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1060.ffi)
def PRE_first_tail_x15_r0_body.khinv109 : PTrie Nat := Stage.setAll PTrie.nil []
def PRE_first_tail_x15_r0_body.kninv109 : PTrie Nat := Stage.setAll PTrie.nil []
/-- The stage's footprint: its written and fresh handles, fresh nodes, written and fresh items. -/
def PRE_first_tail_x15_r0_body.cwS109 : List Nat := []
def PRE_first_tail_x15_r0_body.cnS109 : List Nat := List.range' 17451 0
def PRE_first_tail_x15_r0_body.ciS109 : List Nat := [] ++ List.range' 17451 0

-- the small checks (`MChecks`'s)
kernel_rfl PRE_first_tail_x15_r0_body.cnh0109 : PRE_first_tail_x15_r0_body.kd109.nh0 = PRE_first_tail_x15_r0_body.cx0_109.mlx.next
kernel_rfl PRE_first_tail_x15_r0_body.cnh1109 : PRE_first_tail_x15_r0_body.kd109.nh1 = PRE_first_tail_x15_r0_body.cx1_109.mlx.next
kernel_rfl PRE_first_tail_x15_r0_body.cnn0109 : PRE_first_tail_x15_r0_body.kd109.nn0 = PRE_first_tail_x15_r0_body.cx0_109.mlx.nnext
kernel_rfl PRE_first_tail_x15_r0_body.cnn1109 : PRE_first_tail_x15_r0_body.kd109.nn1 = PRE_first_tail_x15_r0_body.cx1_109.mlx.nnext
kernel_rfl PRE_first_tail_x15_r0_body.cplo109 : (Nat.blt 0 PRE_first_tail_x15_r0_body.P109.lo && Nat.ble PRE_first_tail_x15_r0_body.P109.lo PRE_first_tail_x15_r0_body.cx0_109.mlx.next && Nat.ble PRE_first_tail_x15_r0_body.P109.lo RData.bigHi && Nat.ble RData.bigHi PRE_first_tail_x15_r0_body.P109.E) = true
kernel_rfl PRE_first_tail_x15_r0_body.ccnt109 : (Nat.ble PRE_first_tail_x15_r0_body.cx0_109.mlx.next PRE_first_tail_x15_r0_body.cx1_109.mlx.next && Nat.ble PRE_first_tail_x15_r0_body.cx0_109.mlx.nnext PRE_first_tail_x15_r0_body.cx1_109.mlx.nnext) = true
kernel_rfl PRE_first_tail_x15_r0_body.cnband109 : (Nat.blt 0 PRE_first_tail_x15_r0_body.P109.NL && Nat.ble PRE_first_tail_x15_r0_body.P109.NL PRE_first_tail_x15_r0_body.P109.N0 && Nat.ble PRE_first_tail_x15_r0_body.P109.N0 PRE_first_tail_x15_r0_body.cx0_109.mlx.nnext) = true
kernel_rfl PRE_first_tail_x15_r0_body.chbelow109 : PRE_first_tail_x15_r0_body.kd109.checkHndBelow = true
kernel_rfl PRE_first_tail_x15_r0_body.chren109 : checkRenG PRE_first_tail_x15_r0_body.kd109.hnd PRE_first_tail_x15_r0_body.khinv109 (phB PRE_first_tail_x15_r0_body.cx0_109.mlx) = true
kernel_rfl PRE_first_tail_x15_r0_body.cband109 : PRE_first_tail_x15_r0_body.kd109.checkBand PRE_first_tail_x15_r0_body.P109.lo = true
kernel_rfl PRE_first_tail_x15_r0_body.cnh1pos109 : Nat.blt 0 PRE_first_tail_x15_r0_body.kd109.nh1 = true
kernel_rfl PRE_first_tail_x15_r0_body.cnren109 : checkRenG PRE_first_tail_x15_r0_body.kd109.node PRE_first_tail_x15_r0_body.kninv109 (pnB PRE_first_tail_x15_r0_body.cx0_109.mlx) = true
kernel_rfl PRE_first_tail_x15_r0_body.cnlow109 : (PTrie.keysA PRE_first_tail_x15_r0_body.kd109.node).all (fun j => Nat.ble PRE_first_tail_x15_r0_body.P109.NL j && Nat.blt (PRE_first_tail_x15_r0_body.kd109.nodeF j) PRE_first_tail_x15_r0_body.cx1_109.mlx.nnext) = true
kernel_rfl PRE_first_tail_x15_r0_body.cabs0a109 : PRE_first_tail_x15_r0_body.cx0_109.mlx.arrs.get 0 = none
kernel_rfl PRE_first_tail_x15_r0_body.cabs0b109 : PRE_first_tail_x15_r0_body.cx0_109.mlx.objs.get 0 = none
kernel_rfl PRE_first_tail_x15_r0_body.ctok1109 : PRE_first_tail_x15_r0_body.cx1_109.mlx.tokens = []
kernel_rfl PRE_first_tail_x15_r0_body.cpend109 : PRE_first_tail_x15_r0_body.cx1_109.mlx.pending = PRE_first_tail_x15_r0_body.cx0_109.mlx.pending.map PRE_first_tail_x15_r0_body.kappa109.pend
kernel_rfl PRE_first_tail_x15_r0_body.cerrh109 : PRE_first_tail_x15_r0_body.cx1_109.mlx.errh = PRE_first_tail_x15_r0_body.cx0_109.mlx.errh.map PRE_first_tail_x15_r0_body.kappa109.arg
kernel_rfl PRE_first_tail_x15_r0_body.cfiles109 : PRE_first_tail_x15_r0_body.cx1_109.mlx.files = PRE_first_tail_x15_r0_body.cx0_109.mlx.files
kernel_rfl PRE_first_tail_x15_r0_body.carch109 : PRE_first_tail_x15_r0_body.cx1_109.mlx.arch = PRE_first_tail_x15_r0_body.cx0_109.mlx.arch
kernel_rfl PRE_first_tail_x15_r0_body.csizes109 : PRE_first_tail_x15_r0_body.cx1_109.mlx.deviceSizes = PRE_first_tail_x15_r0_body.cx0_109.mlx.deviceSizes
kernel_rfl PRE_first_tail_x15_r0_body.cwired109 : PRE_first_tail_x15_r0_body.cx1_109.mlx.wired = PRE_first_tail_x15_r0_body.cx0_109.mlx.wired
kernel_rfl PRE_first_tail_x15_r0_body.chost109 : PRE_first_tail_x15_r0_body.cx1_109.host = PRE_first_tail_x15_r0_body.cx0_109.host
-- the compaction map's addresses are `PRE_first_tail_x15_r0_body.kd109`'s
kernel_rfl PRE_first_tail_x15_r0_body.ckn0109 : PRE_first_tail_x15_r0_body.kd109.n0 = 2760707
kernel_rfl PRE_first_tail_x15_r0_body.ckn1109 : PRE_first_tail_x15_r0_body.kd109.n1 = 2760709
kernel_rfl PRE_first_tail_x15_r0_body.ckheap109 : (PTrie.keysA PRE_first_tail_x15_r0_body.kd109.heap).all (fun x => Nat.ble 2760707 x) = true
kernel_rfl PRE_first_tail_x15_r0_body.ckpl109 : (List.range 0).all (fun j => decide (PRE_first_tail_x15_r0_body.kd109.heap.get (2760707 + j) = nth? PRE_first_tail_x15_r0_body.pl109 j)) = true
-- the map fixes the call's names (`Conv.fixOld_compact`), the call's counters
kernel_rfl PRE_first_tail_x15_r0_body.fja109 : Nat.ble 2760707 2760707 = true
kernel_rfl PRE_first_tail_x15_r0_body.fn109 : Nat.ble 4739 4739 = true
kernel_rfl PRE_first_tail_x15_r0_body.fjaD109 : Nat.ble 2760707 PRE_first_tail_x15_r0_body.kd109.n0 = true
kernel_rfl PRE_first_tail_x15_r0_body.fxn109 : Nat.ble 20356 PRE_first_tail_x15_r0_body.kd109.nh0 = true
kernel_rfl PRE_first_tail_x15_r0_body.fnn109 : Nat.ble 17451 PRE_first_tail_x15_r0_body.kd109.nn0 = true
kernel_rfl PRE_first_tail_x15_r0_body.fxb109 : Nat.ble 20356 RData.bigHi = true
kernel_rfl PRE_first_tail_x15_r0_body.fheap109 : (PTrie.keysA PRE_first_tail_x15_r0_body.kd109.heap).all (Nat.ble (⟨20356, 17451, 2760707, 4739⟩ : Conv.Cnt).ja) = true
kernel_rfl PRE_first_tail_x15_r0_body.fhnd109 : (PTrie.keysA PRE_first_tail_x15_r0_body.kd109.hnd).all (Nat.ble (⟨20356, 17451, 2760707, 4739⟩ : Conv.Cnt).xn) = true
kernel_rfl PRE_first_tail_x15_r0_body.fnode109 : (PTrie.keysA PRE_first_tail_x15_r0_body.kd109.node).all (Nat.ble (⟨20356, 17451, 2760707, 4739⟩ : Conv.Cnt).nn) = true
/-- The compaction map fixes the call's names. -/
theorem PRE_first_tail_x15_r0_body.cfix109 : Conv.FixOld (⟨20356, 17451, 2760707, 4739⟩ : Conv.Cnt) PRE_first_tail_x15_r0_body.kappa109 :=
  Conv.fixOld_compact (Nat.le_of_ble_eq_true PRE_first_tail_x15_r0_body.fja109) (Nat.le_of_ble_eq_true PRE_first_tail_x15_r0_body.fn109) (Nat.le_of_ble_eq_true PRE_first_tail_x15_r0_body.fjaD109) (Nat.le_of_ble_eq_true PRE_first_tail_x15_r0_body.fxn109) (Nat.le_of_ble_eq_true PRE_first_tail_x15_r0_body.fnn109) (Nat.le_of_ble_eq_true PRE_first_tail_x15_r0_body.fxb109) PRE_first_tail_x15_r0_body.fheap109 PRE_first_tail_x15_r0_body.fhnd109 PRE_first_tail_x15_r0_body.fnode109
kernel_rfl PRE_first_tail_x15_r0_body.fcxn109 : (⟨20356, 17451, 2760707, 4739⟩ : Conv.Cnt).xn = (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1059.ffi).mlx.next
kernel_rfl PRE_first_tail_x15_r0_body.fcnn109 : (⟨20356, 17451, 2760707, 4739⟩ : Conv.Cnt).nn = (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1059.ffi).mlx.nnext
kernel_rfl PRE_first_tail_x15_r0_body.fle0109 : (Nat.ble (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1059.ffi).mlx.next PRE_first_tail_x15_r0_body.cx0_109.mlx.next && Nat.ble (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1059.ffi).mlx.nnext PRE_first_tail_x15_r0_body.cx0_109.mlx.nnext && Nat.ble (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1059.ffi).mlx.next RData.bigHi) = true
kernel_rfl PRE_first_tail_x15_r0_body.fnk109 : (PTrie.keysA PRE_first_tail_x15_r0_body.kd109.node).all (Nat.ble (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1059.ffi).mlx.nnext) = true
-- the merged state keeps the call's entries off the stage's footprint
kernel_rfl PRE_first_tail_x15_r0_body.f1A109 : PRE_first_tail_x15_r0_body.cx1_109.mlx.arrs = Stage.setAll (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1059.ffi).mlx.arrs (PRE_first_tail_x15_r0_body.cwS109.filterMap fun i => (PRE_first_tail_x15_r0_body.cx1_109.mlx.arrs.get i).map (i, ·))
kernel_rfl PRE_first_tail_x15_r0_body.f1O109 : PRE_first_tail_x15_r0_body.cx1_109.mlx.objs = Stage.setAll (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1059.ffi).mlx.objs (PRE_first_tail_x15_r0_body.cwS109.filterMap fun i => (PRE_first_tail_x15_r0_body.cx1_109.mlx.objs.get i).map (i, ·))
kernel_rfl PRE_first_tail_x15_r0_body.f1N109 : PRE_first_tail_x15_r0_body.cx1_109.mlx.nodes = Stage.setAll (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1059.ffi).mlx.nodes (PRE_first_tail_x15_r0_body.cnS109.filterMap fun i => (PRE_first_tail_x15_r0_body.cx1_109.mlx.nodes.get i).map (i, ·))
kernel_rfl PRE_first_tail_x15_r0_body.f1I109 : PRE_first_tail_x15_r0_body.cx1_109.mlx.items = Stage.setAll (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1059.ffi).mlx.items (PRE_first_tail_x15_r0_body.ciS109.filterMap fun i => (PRE_first_tail_x15_r0_body.cx1_109.mlx.items.get i).map (i, ·))
kernel_rfl PRE_first_tail_x15_r0_body.fbd109 : (PRE_first_tail_x15_r0_body.clo109 ++ PRE_first_tail_x15_r0_body.cln109 ++ PRE_first_tail_x15_r0_body.cli109 ++ PRE_first_tail_x15_r0_body.cwS109 ++ PRE_first_tail_x15_r0_body.cnS109 ++ PRE_first_tail_x15_r0_body.ciS109).all (fun i => Nat.blt (i / 4096) (4 ^ 31)) = true
kernel_rfl PRE_first_tail_x15_r0_body.fincW109 : PRE_first_tail_x15_r0_body.cwS109.all (fun h => !Nat.blt h (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1059.ffi).mlx.next || PRE_first_tail_x15_r0_body.clo109.contains h) = true
kernel_rfl PRE_first_tail_x15_r0_body.fincI109 : PRE_first_tail_x15_r0_body.ciS109.all (fun k => !Nat.blt k (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1059.ffi).mlx.nnext || PRE_first_tail_x15_r0_body.cli109.contains k) = true
kernel_rfl PRE_first_tail_x15_r0_body.fincN109 : PRE_first_tail_x15_r0_body.cnS109.all (Nat.ble (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1059.ffi).mlx.nnext) = true
kernel_rfl PRE_first_tail_x15_r0_body.flnF109 : PRE_first_tail_x15_r0_body.cln109.all (Nat.ble (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1059.ffi).mlx.nnext) = true
-- the checks over the changed lists
kernel_rfl PRE_first_tail_x15_r0_body.fh109 : PRE_first_tail_x15_r0_body.clo109.all (handleOK PRE_first_tail_x15_r0_body.kappa109 PRE_first_tail_x15_r0_body.P109.lo PRE_first_tail_x15_r0_body.cx0_109.mlx PRE_first_tail_x15_r0_body.cx1_109.mlx) = true
kernel_rfl PRE_first_tail_x15_r0_body.fo109 : PRE_first_tail_x15_r0_body.clo109.map (fun h => PRE_first_tail_x15_r0_body.cx1_109.mlx.objs.get (PRE_first_tail_x15_r0_body.kappa109.handle h)) = PRE_first_tail_x15_r0_body.clo109.map (fun h => (PRE_first_tail_x15_r0_body.cx0_109.mlx.objs.get h).map PRE_first_tail_x15_r0_body.kappa109.nobj)
kernel_rfl PRE_first_tail_x15_r0_body.fok109 : PRE_first_tail_x15_r0_body.clo109.all (objOK PRE_first_tail_x15_r0_body.kappa109 PRE_first_tail_x15_r0_body.P109.NL PRE_first_tail_x15_r0_body.cx0_109.mlx) = true
kernel_rfl PRE_first_tail_x15_r0_body.fnd109 : PRE_first_tail_x15_r0_body.cln109.all (nodeOKF PRE_first_tail_x15_r0_body.kappa109 PRE_first_tail_x15_r0_body.P109 PRE_first_tail_x15_r0_body.cx0_109.mlx PRE_first_tail_x15_r0_body.cx1_109.mlx) = true
kernel_rfl PRE_first_tail_x15_r0_body.fp109 : ((PRE_first_tail_x15_r0_body.cln109.filter (fullB PRE_first_tail_x15_r0_body.P109))).map (fun i => (PRE_first_tail_x15_r0_body.cx1_109.mlx.nodes.get (PRE_first_tail_x15_r0_body.kappa109.node i)).map Host.Mlx.Ffi.Node.prim) =
  ((PRE_first_tail_x15_r0_body.cln109.filter (fullB PRE_first_tail_x15_r0_body.P109))).map (fun i => (PRE_first_tail_x15_r0_body.cx0_109.mlx.nodes.get i).map fun nd => PRE_first_tail_x15_r0_body.kappa109.prim nd.prim)
kernel_rfl PRE_first_tail_x15_r0_body.fnordI109 : incrB PRE_first_tail_x15_r0_body.kd109.nodeF (List.range' 17451 0) = true
kernel_rfl PRE_first_tail_x15_r0_body.fnordK109 : (PTrie.keysA PRE_first_tail_x15_r0_body.kd109.node).all (fun k => Nat.ble 17451 k && Nat.blt k 17451) = true
kernel_rfl PRE_first_tail_x15_r0_body.fnordL109 : (PRE_first_tail_x15_r0_body.cln109.filter (Nat.ble PRE_first_tail_x15_r0_body.P109.N0)).all (fun i => Nat.ble i (PRE_first_tail_x15_r0_body.kd109.nodeF i) && (Nat.blt i 17451 || Nat.ble PRE_first_tail_x15_r0_body.kd109.nn0 i)) = true
theorem PRE_first_tail_x15_r0_body.fnord109 : (PRE_first_tail_x15_r0_body.cln109.filter (Nat.ble PRE_first_tail_x15_r0_body.P109.N0)).all (fun i => Nat.ble i (PRE_first_tail_x15_r0_body.kd109.nodeF i) &&
    (PTrie.keysA PRE_first_tail_x15_r0_body.kd109.node).all fun j => !Nat.blt j i || Nat.blt (PRE_first_tail_x15_r0_body.kd109.nodeF j) (PRE_first_tail_x15_r0_body.kd109.nodeF i)) = true :=
  cnord_of PRE_first_tail_x15_r0_body.cnlow109 PRE_first_tail_x15_r0_body.cnn1109 PRE_first_tail_x15_r0_body.fnordI109 PRE_first_tail_x15_r0_body.fnordK109 PRE_first_tail_x15_r0_body.fnordL109
kernel_rfl PRE_first_tail_x15_r0_body.fi109 : PRE_first_tail_x15_r0_body.cli109.all (pnB PRE_first_tail_x15_r0_body.cx0_109.mlx) = true
kernel_rfl PRE_first_tail_x15_r0_body.fii109 : PRE_first_tail_x15_r0_body.cli109.all (fun k => decide (PRE_first_tail_x15_r0_body.cx1_109.mlx.items.get (PRE_first_tail_x15_r0_body.kappa109.node k) = (PRE_first_tail_x15_r0_body.cx0_109.mlx.items.get k).map PRE_first_tail_x15_r0_body.kappa109.nv)) = true
/-- **The compaction's footprint.** -/
theorem PRE_first_tail_x15_r0_body.cfoot109 (clean : Conv.NClean (⟨20356, 17451, 2760707, 4739⟩ : Conv.Cnt) (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1059.ffi).mlx) (hltC : ∀ h, PH (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1059.ffi).mlx h → h < (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1059.ffi).mlx.next) (nltC : ∀ i, PN (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1059.ffi).mlx i → i < (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1059.ffi).mlx.nnext) (itemsC : ∀ k v, (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1059.ffi).mlx.items.get k = some v → PN (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1059.ffi).mlx k) (tracedC : ∀ h o, (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1059.ffi).mlx.objs.get h = some o → ∀ i ∈ objTraces o, i < PRE_first_tail_x15_r0_body.P109.NL) (cl : SSt (· < 4739) PRE_first_tail_x15_r0_body.cx0_109.mlx) :
    Conv.MFoot PRE_first_tail_x15_r0_body.P109 4739 PRE_first_tail_x15_r0_body.kappa109 PRE_first_tail_x15_r0_body.kd109 PRE_first_tail_x15_r0_body.khinv109 PRE_first_tail_x15_r0_body.kninv109 (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1059.ffi).mlx PRE_first_tail_x15_r0_body.cx0_109.mlx PRE_first_tail_x15_r0_body.cx1_109.mlx (⟨20356, 17451, 2760707, 4739⟩ : Conv.Cnt) PRE_first_tail_x15_r0_body.clo109 PRE_first_tail_x15_r0_body.cln109 PRE_first_tail_x15_r0_body.cli109 PRE_first_tail_x15_r0_body.cwS109 PRE_first_tail_x15_r0_body.cnS109 PRE_first_tail_x15_r0_body.ciS109 :=
  ⟨rfl, rfl, rfl, PRE_first_tail_x15_r0_body.cnh0109, PRE_first_tail_x15_r0_body.cnh1109, PRE_first_tail_x15_r0_body.cnn0109, PRE_first_tail_x15_r0_body.cnn1109, PRE_first_tail_x15_r0_body.cplo109, PRE_first_tail_x15_r0_body.ccnt109, PRE_first_tail_x15_r0_body.cnband109, PRE_first_tail_x15_r0_body.chbelow109, PRE_first_tail_x15_r0_body.chren109, PRE_first_tail_x15_r0_body.cband109, PRE_first_tail_x15_r0_body.cnh1pos109, PRE_first_tail_x15_r0_body.cnren109, PRE_first_tail_x15_r0_body.cnlow109, PRE_first_tail_x15_r0_body.cabs0a109, PRE_first_tail_x15_r0_body.cabs0b109, PRE_first_tail_x15_r0_body.ctok1109, PRE_first_tail_x15_r0_body.cpend109, PRE_first_tail_x15_r0_body.cerrh109, PRE_first_tail_x15_r0_body.cfiles109, PRE_first_tail_x15_r0_body.carch109, PRE_first_tail_x15_r0_body.csizes109, PRE_first_tail_x15_r0_body.cwired109, PRE_first_tail_x15_r0_body.cfix109, clean, PRE_first_tail_x15_r0_body.fcxn109, PRE_first_tail_x15_r0_body.fcnn109, hltC, nltC, itemsC, tracedC, cl, PRE_first_tail_x15_r0_body.fle0109, PRE_first_tail_x15_r0_body.fnk109, PRE_first_tail_x15_r0_body.ckA109, PRE_first_tail_x15_r0_body.cobjsK109, PRE_first_tail_x15_r0_body.cnodesK109, PRE_first_tail_x15_r0_body.citemsK109, PRE_first_tail_x15_r0_body.f1A109, PRE_first_tail_x15_r0_body.f1O109, PRE_first_tail_x15_r0_body.f1N109, PRE_first_tail_x15_r0_body.f1I109, PRE_first_tail_x15_r0_body.fbd109, PRE_first_tail_x15_r0_body.fincW109, PRE_first_tail_x15_r0_body.fincI109, PRE_first_tail_x15_r0_body.fincN109, PRE_first_tail_x15_r0_body.flnF109, PRE_first_tail_x15_r0_body.fh109, PRE_first_tail_x15_r0_body.fo109, PRE_first_tail_x15_r0_body.fok109, PRE_first_tail_x15_r0_body.fnd109, PRE_first_tail_x15_r0_body.fp109, PRE_first_tail_x15_r0_body.fnord109, PRE_first_tail_x15_r0_body.fi109, PRE_first_tail_x15_r0_body.fii109⟩
theorem PRE_first_tail_x15_r0_body.cnshift109 (clean : Conv.NClean (⟨20356, 17451, 2760707, 4739⟩ : Conv.Cnt) (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1059.ffi).mlx) (hltC : ∀ h, PH (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1059.ffi).mlx h → h < (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1059.ffi).mlx.next) (nltC : ∀ i, PN (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1059.ffi).mlx i → i < (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1059.ffi).mlx.nnext) (itemsC : ∀ k v, (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1059.ffi).mlx.items.get k = some v → PN (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1059.ffi).mlx k) (tracedC : ∀ h o, (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1059.ffi).mlx.objs.get h = some o → ∀ i ∈ objTraces o, i < PRE_first_tail_x15_r0_body.P109.NL) (cl : SSt (· < 4739) PRE_first_tail_x15_r0_body.cx0_109.mlx) : NShift PRE_first_tail_x15_r0_body.P109 4739 PRE_first_tail_x15_r0_body.kappa109 PRE_first_tail_x15_r0_body.cx0_109 PRE_first_tail_x15_r0_body.cx1_109 :=
  Conv.nshift_of_foot (PRE_first_tail_x15_r0_body.cfoot109 clean hltC nltC itemsC tracedC cl) PRE_first_tail_x15_r0_body.chost109 (compact_a_eq PRE_first_tail_x15_r0_body.ckn0109 PRE_first_tail_x15_r0_body.ckn1109 PRE_first_tail_x15_r0_body.ckheap109 PRE_first_tail_x15_r0_body.ckpl109)

-- the observers: the layers' states at the call, the canonical and the merged state, their footprints and checks
noncomputable def PRE_first_tail_x15_r0_body.fxC_109 : PTrie Unit := (Host.Ts.Sim.Full.freedOf PRE_first_tail_x15_r0_body.s1059.ffi).getD PTrie.nil
noncomputable def PRE_first_tail_x15_r0_body.krC_109 : Host.Load.Layers.KRec := (Host.Ts.Sim.Full.krecOf PRE_first_tail_x15_r0_body.s1059.ffi).getD Host.Load.Layers.KRec.empty
kernel_rfl PRE_first_tail_x15_r0_body.ofxC_109 : (Host.Ts.Sim.Full.freedOf PRE_first_tail_x15_r0_body.s1059.ffi) = some PRE_first_tail_x15_r0_body.fxC_109
kernel_rfl PRE_first_tail_x15_r0_body.okrC_109 : (Host.Ts.Sim.Full.krecOf PRE_first_tail_x15_r0_body.s1059.ffi) = some PRE_first_tail_x15_r0_body.krC_109
noncomputable def PRE_first_tail_x15_r0_body.fx0_109 : PTrie Unit := (Host.Ts.Sim.Full.freedOf PRE_first_tail_x15_r0_body.s1061.ffi).getD PTrie.nil
noncomputable def PRE_first_tail_x15_r0_body.kr0_109 : Host.Load.Layers.KRec := (Host.Ts.Sim.Full.krecOf PRE_first_tail_x15_r0_body.s1061.ffi).getD Host.Load.Layers.KRec.empty
kernel_rfl PRE_first_tail_x15_r0_body.ofx0_109 : (Host.Ts.Sim.Full.freedOf PRE_first_tail_x15_r0_body.s1061.ffi) = some PRE_first_tail_x15_r0_body.fx0_109
kernel_rfl PRE_first_tail_x15_r0_body.okr0_109 : (Host.Ts.Sim.Full.krecOf PRE_first_tail_x15_r0_body.s1061.ffi) = some PRE_first_tail_x15_r0_body.kr0_109
noncomputable def PRE_first_tail_x15_r0_body.fx1_109 : PTrie Unit := (Host.Ts.Sim.Full.freedOf PRE_first_tail_x15_r0_body.s1060.ffi).getD PTrie.nil
noncomputable def PRE_first_tail_x15_r0_body.kr1_109 : Host.Load.Layers.KRec := (Host.Ts.Sim.Full.krecOf PRE_first_tail_x15_r0_body.s1060.ffi).getD Host.Load.Layers.KRec.empty
kernel_rfl PRE_first_tail_x15_r0_body.ofx1_109 : (Host.Ts.Sim.Full.freedOf PRE_first_tail_x15_r0_body.s1060.ffi) = some PRE_first_tail_x15_r0_body.fx1_109
kernel_rfl PRE_first_tail_x15_r0_body.okr1_109 : (Host.Ts.Sim.Full.krecOf PRE_first_tail_x15_r0_body.s1060.ffi) = some PRE_first_tail_x15_r0_body.kr1_109
kernel_rfl PRE_first_tail_x15_r0_body.ff0109 : PRE_first_tail_x15_r0_body.fx0_109 = Stage.setAll PRE_first_tail_x15_r0_body.fxC_109 (PRE_first_tail_x15_r0_body.clo109.filterMap fun i => (PRE_first_tail_x15_r0_body.fx0_109.get i).map (i, ·))
kernel_rfl PRE_first_tail_x15_r0_body.ff1109 : PRE_first_tail_x15_r0_body.fx1_109 = Stage.setAll PRE_first_tail_x15_r0_body.fxC_109 (PRE_first_tail_x15_r0_body.cwS109.filterMap fun i => (PRE_first_tail_x15_r0_body.fx1_109.get i).map (i, ·))
kernel_rfl PRE_first_tail_x15_r0_body.ffck109 : freedLB PRE_first_tail_x15_r0_body.kappa109 PRE_first_tail_x15_r0_body.cx0_109.mlx PRE_first_tail_x15_r0_body.fx0_109 PRE_first_tail_x15_r0_body.fx1_109 PRE_first_tail_x15_r0_body.clo109 = true
kernel_rfl PRE_first_tail_x15_r0_body.fkf0109 : PRE_first_tail_x15_r0_body.kr0_109.flags = Stage.setAll PRE_first_tail_x15_r0_body.krC_109.flags (PRE_first_tail_x15_r0_body.clo109.filterMap fun i => (PRE_first_tail_x15_r0_body.kr0_109.flags.get i).map (i, ·))
kernel_rfl PRE_first_tail_x15_r0_body.fkt0109 : PRE_first_tail_x15_r0_body.kr0_109.targs = Stage.setAll PRE_first_tail_x15_r0_body.krC_109.targs (PRE_first_tail_x15_r0_body.clo109.filterMap fun i => (PRE_first_tail_x15_r0_body.kr0_109.targs.get i).map (i, ·))
kernel_rfl PRE_first_tail_x15_r0_body.fkf1109 : PRE_first_tail_x15_r0_body.kr1_109.flags = Stage.setAll PRE_first_tail_x15_r0_body.krC_109.flags (PRE_first_tail_x15_r0_body.cwS109.filterMap fun i => (PRE_first_tail_x15_r0_body.kr1_109.flags.get i).map (i, ·))
kernel_rfl PRE_first_tail_x15_r0_body.fkt1109 : PRE_first_tail_x15_r0_body.kr1_109.targs = Stage.setAll PRE_first_tail_x15_r0_body.krC_109.targs (PRE_first_tail_x15_r0_body.cwS109.filterMap fun i => (PRE_first_tail_x15_r0_body.kr1_109.targs.get i).map (i, ·))
kernel_rfl PRE_first_tail_x15_r0_body.fkck109 : krecLB PRE_first_tail_x15_r0_body.kappa109 4739 PRE_first_tail_x15_r0_body.cx0_109.mlx PRE_first_tail_x15_r0_body.kr0_109 PRE_first_tail_x15_r0_body.kr1_109 PRE_first_tail_x15_r0_body.clo109 = true
kernel_rfl PRE_first_tail_x15_r0_body.fkn109 : Nat.ble 4739 4739 = true
-- the bridge and the pending traces' regions
kernel_rfl PRE_first_tail_x15_r0_body.cbridge109 : Host.Ts.Sim.Full.bridgeOf PRE_first_tail_x15_r0_body.s1060.ffi = Host.Ts.Sim.Full.bridgeOf PRE_first_tail_x15_r0_body.s1061.ffi
kernel_rfl PRE_first_tail_x15_r0_body.cpendR109 : pendRegB PRE_first_tail_x15_r0_body.kappa109 (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1061.ffi).mlx = true
kernel_rfl PRE_first_tail_x15_r0_body.cpendLe109 : Nat.ble (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1061.ffi).mlx.next (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1060.ffi).mlx.next = true
/-- **The compaction's native shift**, given the call's bookkeeping, its relation's facts (the model's and the
observers') and the canonical closedness. -/
theorem PRE_first_tail_x15_r0_body.cshift109 (clean : Conv.NClean (⟨20356, 17451, 2760707, 4739⟩ : Conv.Cnt) (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1059.ffi).mlx) (hltC : ∀ h, PH (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1059.ffi).mlx h → h < (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1059.ffi).mlx.next) (nltC : ∀ i, PN (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1059.ffi).mlx i → i < (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1059.ffi).mlx.nnext) (itemsC : ∀ k v, (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1059.ffi).mlx.items.get k = some v → PN (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1059.ffi).mlx k) (tracedC : ∀ h o, (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1059.ffi).mlx.objs.get h = some o → ∀ i ∈ objTraces o, i < PRE_first_tail_x15_r0_body.P109.NL) (cl : SSt (· < 4739) PRE_first_tail_x15_r0_body.cx0_109.mlx)
    (hobjC : ∀ h, PRE_first_tail_x15_r0_body.fxC_109.get h = some () → ((Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1059.ffi).mlx.objs.get h).isSome = true)
    (hfC : ∀ h, (PRE_first_tail_x15_r0_body.krC_109.flags.get h).isSome = true → ((Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1059.ffi).mlx.objs.get h).isSome = true)
    (htC : ∀ h, (PRE_first_tail_x15_r0_body.krC_109.targs.get h).isSome = true → ((Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1059.ffi).mlx.objs.get h).isSome = true)
    (hclC : ∀ h l, PRE_first_tail_x15_r0_body.krC_109.targs.get h = some l → Host.Ts.Sim.Full.STargs (· < (⟨20356, 17451, 2760707, 4739⟩ : Conv.Cnt).n) l) :
    Conv.FullShiftQ PRE_first_tail_x15_r0_body.P109 4739 PRE_first_tail_x15_r0_body.kappa109 PRE_first_tail_x15_r0_body.s1061.ffi PRE_first_tail_x15_r0_body.s1060.ffi :=
  ⟨PRE_first_tail_x15_r0_body.cnshift109 clean hltC nltC itemsC tracedC cl, PRE_first_tail_x15_r0_body.cqueue109, fun t ht => bSN_sound (List.all_eq_true.mp PRE_first_tail_x15_r0_body.ctokSupp109 t ht),
    PRE_first_tail_x15_r0_body.cbridge109,
    liveShift_foot (x0' := Host.Ts.Sim.Full.mlxOf PRE_first_tail_x15_r0_body.s1061.ffi) (x1' := Host.Ts.Sim.Full.mlxOf PRE_first_tail_x15_r0_body.s1060.ffi) (PRE_first_tail_x15_r0_body.cfoot109 clean hltC nltC itemsC tracedC cl) rfl PRE_first_tail_x15_r0_body.ofx0_109 PRE_first_tail_x15_r0_body.ofx1_109 hobjC PRE_first_tail_x15_r0_body.ff0109 PRE_first_tail_x15_r0_body.ff1109 PRE_first_tail_x15_r0_body.ffck109,
    kernShift_foot (x0' := Host.Ts.Sim.Full.mlxOf PRE_first_tail_x15_r0_body.s1061.ffi) (x1' := Host.Ts.Sim.Full.mlxOf PRE_first_tail_x15_r0_body.s1060.ffi) (PRE_first_tail_x15_r0_body.cfoot109 clean hltC nltC itemsC tracedC cl) rfl PRE_first_tail_x15_r0_body.okr0_109 PRE_first_tail_x15_r0_body.okr1_109 (Nat.le_of_ble_eq_true PRE_first_tail_x15_r0_body.fkn109) hfC htC hclC
      PRE_first_tail_x15_r0_body.fkf0109 PRE_first_tail_x15_r0_body.fkt0109 PRE_first_tail_x15_r0_body.fkf1109 PRE_first_tail_x15_r0_body.fkt1109 PRE_first_tail_x15_r0_body.fkck109,
    pendReg_of rfl PRE_first_tail_x15_r0_body.cnh0109 PRE_first_tail_x15_r0_body.cnh1109 (Nat.le_of_ble_eq_true PRE_first_tail_x15_r0_body.cpendLe109) PRE_first_tail_x15_r0_body.cpendR109⟩

end Host.Load.Run.Tpl
