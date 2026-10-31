import host.sim.template.a4pre_first_tail_x15_r0_body.SiteCl2
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

/-- The load parameters of the chain (band-free: its start's node counter as `NL` and `N0`). -/
def PRE_first_tail_x15_r0_body.Pc2 : LoadP := ⟨18151, 131072, 1099511627776, 15235, 15235, []⟩
/-- The site's band raised to the map's checked fixed-node prefix, including newly recorded closure traces. -/
def PRE_first_tail_x15_r0_body.P2 : LoadP := PRE_first_tail_x15_r0_body.Pc2.raise 15322
kernel_rfl PRE_first_tail_x15_r0_body.craise2 : Nat.ble PRE_first_tail_x15_r0_body.Pc2.N0 15322 = true
theorem PRE_first_tail_x15_r0_body.raised2 : Host.Ts.Sim.Full.Raised PRE_first_tail_x15_r0_body.Pc2 PRE_first_tail_x15_r0_body.P2 :=
  .inr ⟨15322, rfl, Nat.le_of_ble_eq_true PRE_first_tail_x15_r0_body.craise2, rfl⟩
noncomputable abbrev PRE_first_tail_x15_r0_body.cx0_2 : Host.Load.LSt := clearTokens (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s27.ffi)
noncomputable abbrev PRE_first_tail_x15_r0_body.cx1_2 : Host.Load.LSt := clearTokens (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s26.ffi)
def PRE_first_tail_x15_r0_body.khinv2 : PTrie Nat := Stage.setAll PTrie.nil []
def PRE_first_tail_x15_r0_body.kninv2 : PTrie Nat := Stage.setAll PTrie.nil []
/-- The stage's footprint: its written and fresh handles, fresh nodes, written and fresh items. -/
def PRE_first_tail_x15_r0_body.cwS2 : List Nat := []
def PRE_first_tail_x15_r0_body.cnS2 : List Nat := List.range' 15322 0
def PRE_first_tail_x15_r0_body.ciS2 : List Nat := [] ++ List.range' 15322 0

-- the small checks (`MChecks`'s)
kernel_rfl PRE_first_tail_x15_r0_body.cnh02 : PRE_first_tail_x15_r0_body.kd2.nh0 = PRE_first_tail_x15_r0_body.cx0_2.mlx.next
kernel_rfl PRE_first_tail_x15_r0_body.cnh12 : PRE_first_tail_x15_r0_body.kd2.nh1 = PRE_first_tail_x15_r0_body.cx1_2.mlx.next
kernel_rfl PRE_first_tail_x15_r0_body.cnn02 : PRE_first_tail_x15_r0_body.kd2.nn0 = PRE_first_tail_x15_r0_body.cx0_2.mlx.nnext
kernel_rfl PRE_first_tail_x15_r0_body.cnn12 : PRE_first_tail_x15_r0_body.kd2.nn1 = PRE_first_tail_x15_r0_body.cx1_2.mlx.nnext
kernel_rfl PRE_first_tail_x15_r0_body.cplo2 : (Nat.blt 0 PRE_first_tail_x15_r0_body.P2.lo && Nat.ble PRE_first_tail_x15_r0_body.P2.lo PRE_first_tail_x15_r0_body.cx0_2.mlx.next && Nat.ble PRE_first_tail_x15_r0_body.P2.lo RData.bigHi && Nat.ble RData.bigHi PRE_first_tail_x15_r0_body.P2.E) = true
kernel_rfl PRE_first_tail_x15_r0_body.ccnt2 : (Nat.ble PRE_first_tail_x15_r0_body.cx0_2.mlx.next PRE_first_tail_x15_r0_body.cx1_2.mlx.next && Nat.ble PRE_first_tail_x15_r0_body.cx0_2.mlx.nnext PRE_first_tail_x15_r0_body.cx1_2.mlx.nnext) = true
kernel_rfl PRE_first_tail_x15_r0_body.cnband2 : (Nat.blt 0 PRE_first_tail_x15_r0_body.P2.NL && Nat.ble PRE_first_tail_x15_r0_body.P2.NL PRE_first_tail_x15_r0_body.P2.N0 && Nat.ble PRE_first_tail_x15_r0_body.P2.N0 PRE_first_tail_x15_r0_body.cx0_2.mlx.nnext) = true
kernel_rfl PRE_first_tail_x15_r0_body.chbelow2 : PRE_first_tail_x15_r0_body.kd2.checkHndBelow = true
kernel_rfl PRE_first_tail_x15_r0_body.chren2 : checkRenG PRE_first_tail_x15_r0_body.kd2.hnd PRE_first_tail_x15_r0_body.khinv2 (phB PRE_first_tail_x15_r0_body.cx0_2.mlx) = true
kernel_rfl PRE_first_tail_x15_r0_body.cband2 : PRE_first_tail_x15_r0_body.kd2.checkBand PRE_first_tail_x15_r0_body.P2.lo = true
kernel_rfl PRE_first_tail_x15_r0_body.cnh1pos2 : Nat.blt 0 PRE_first_tail_x15_r0_body.kd2.nh1 = true
kernel_rfl PRE_first_tail_x15_r0_body.cnren2 : checkRenG PRE_first_tail_x15_r0_body.kd2.node PRE_first_tail_x15_r0_body.kninv2 (pnB PRE_first_tail_x15_r0_body.cx0_2.mlx) = true
kernel_rfl PRE_first_tail_x15_r0_body.cnlow2 : (PTrie.keysA PRE_first_tail_x15_r0_body.kd2.node).all (fun j => Nat.ble PRE_first_tail_x15_r0_body.P2.NL j && Nat.blt (PRE_first_tail_x15_r0_body.kd2.nodeF j) PRE_first_tail_x15_r0_body.cx1_2.mlx.nnext) = true
kernel_rfl PRE_first_tail_x15_r0_body.cabs0a2 : PRE_first_tail_x15_r0_body.cx0_2.mlx.arrs.get 0 = none
kernel_rfl PRE_first_tail_x15_r0_body.cabs0b2 : PRE_first_tail_x15_r0_body.cx0_2.mlx.objs.get 0 = none
kernel_rfl PRE_first_tail_x15_r0_body.ctok12 : PRE_first_tail_x15_r0_body.cx1_2.mlx.tokens = []
kernel_rfl PRE_first_tail_x15_r0_body.cpend2 : PRE_first_tail_x15_r0_body.cx1_2.mlx.pending = PRE_first_tail_x15_r0_body.cx0_2.mlx.pending.map PRE_first_tail_x15_r0_body.kappa2.pend
kernel_rfl PRE_first_tail_x15_r0_body.cerrh2 : PRE_first_tail_x15_r0_body.cx1_2.mlx.errh = PRE_first_tail_x15_r0_body.cx0_2.mlx.errh.map PRE_first_tail_x15_r0_body.kappa2.arg
kernel_rfl PRE_first_tail_x15_r0_body.cfiles2 : PRE_first_tail_x15_r0_body.cx1_2.mlx.files = PRE_first_tail_x15_r0_body.cx0_2.mlx.files
kernel_rfl PRE_first_tail_x15_r0_body.carch2 : PRE_first_tail_x15_r0_body.cx1_2.mlx.arch = PRE_first_tail_x15_r0_body.cx0_2.mlx.arch
kernel_rfl PRE_first_tail_x15_r0_body.csizes2 : PRE_first_tail_x15_r0_body.cx1_2.mlx.deviceSizes = PRE_first_tail_x15_r0_body.cx0_2.mlx.deviceSizes
kernel_rfl PRE_first_tail_x15_r0_body.cwired2 : PRE_first_tail_x15_r0_body.cx1_2.mlx.wired = PRE_first_tail_x15_r0_body.cx0_2.mlx.wired
kernel_rfl PRE_first_tail_x15_r0_body.chost2 : PRE_first_tail_x15_r0_body.cx1_2.host = PRE_first_tail_x15_r0_body.cx0_2.host
-- the compaction map's addresses are `PRE_first_tail_x15_r0_body.kd2`'s
kernel_rfl PRE_first_tail_x15_r0_body.ckn02 : PRE_first_tail_x15_r0_body.kd2.n0 = 2676054
kernel_rfl PRE_first_tail_x15_r0_body.ckn12 : PRE_first_tail_x15_r0_body.kd2.n1 = 2676073
kernel_rfl PRE_first_tail_x15_r0_body.ckheap2 : (PTrie.keysA PRE_first_tail_x15_r0_body.kd2.heap).all (fun x => Nat.ble 2676053 x) = true
kernel_rfl PRE_first_tail_x15_r0_body.ckpl2 : (List.range 1).all (fun j => decide (PRE_first_tail_x15_r0_body.kd2.heap.get (2676053 + j) = nth? PRE_first_tail_x15_r0_body.pl2 j)) = true
-- the map fixes the call's names (`Conv.fixOld_compact`), the call's counters
kernel_rfl PRE_first_tail_x15_r0_body.fja2 : Nat.ble 2676053 2676053 = true
kernel_rfl PRE_first_tail_x15_r0_body.fn2 : Nat.ble 139 139 = true
kernel_rfl PRE_first_tail_x15_r0_body.fjaD2 : Nat.ble 2676053 PRE_first_tail_x15_r0_body.kd2.n0 = true
kernel_rfl PRE_first_tail_x15_r0_body.fxn2 : Nat.ble 18233 PRE_first_tail_x15_r0_body.kd2.nh0 = true
kernel_rfl PRE_first_tail_x15_r0_body.fnn2 : Nat.ble 15322 PRE_first_tail_x15_r0_body.kd2.nn0 = true
kernel_rfl PRE_first_tail_x15_r0_body.fxb2 : Nat.ble 18233 RData.bigHi = true
kernel_rfl PRE_first_tail_x15_r0_body.fheap2 : (PTrie.keysA PRE_first_tail_x15_r0_body.kd2.heap).all (Nat.ble (⟨18233, 15322, 2676053, 139⟩ : Conv.Cnt).ja) = true
kernel_rfl PRE_first_tail_x15_r0_body.fhnd2 : (PTrie.keysA PRE_first_tail_x15_r0_body.kd2.hnd).all (Nat.ble (⟨18233, 15322, 2676053, 139⟩ : Conv.Cnt).xn) = true
kernel_rfl PRE_first_tail_x15_r0_body.fnode2 : (PTrie.keysA PRE_first_tail_x15_r0_body.kd2.node).all (Nat.ble (⟨18233, 15322, 2676053, 139⟩ : Conv.Cnt).nn) = true
/-- The compaction map fixes the call's names. -/
theorem PRE_first_tail_x15_r0_body.cfix2 : Conv.FixOld (⟨18233, 15322, 2676053, 139⟩ : Conv.Cnt) PRE_first_tail_x15_r0_body.kappa2 :=
  Conv.fixOld_compact (Nat.le_of_ble_eq_true PRE_first_tail_x15_r0_body.fja2) (Nat.le_of_ble_eq_true PRE_first_tail_x15_r0_body.fn2) (Nat.le_of_ble_eq_true PRE_first_tail_x15_r0_body.fjaD2) (Nat.le_of_ble_eq_true PRE_first_tail_x15_r0_body.fxn2) (Nat.le_of_ble_eq_true PRE_first_tail_x15_r0_body.fnn2) (Nat.le_of_ble_eq_true PRE_first_tail_x15_r0_body.fxb2) PRE_first_tail_x15_r0_body.fheap2 PRE_first_tail_x15_r0_body.fhnd2 PRE_first_tail_x15_r0_body.fnode2
kernel_rfl PRE_first_tail_x15_r0_body.fcxn2 : (⟨18233, 15322, 2676053, 139⟩ : Conv.Cnt).xn = (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s25.ffi).mlx.next
kernel_rfl PRE_first_tail_x15_r0_body.fcnn2 : (⟨18233, 15322, 2676053, 139⟩ : Conv.Cnt).nn = (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s25.ffi).mlx.nnext
kernel_rfl PRE_first_tail_x15_r0_body.fle02 : (Nat.ble (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s25.ffi).mlx.next PRE_first_tail_x15_r0_body.cx0_2.mlx.next && Nat.ble (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s25.ffi).mlx.nnext PRE_first_tail_x15_r0_body.cx0_2.mlx.nnext && Nat.ble (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s25.ffi).mlx.next RData.bigHi) = true
kernel_rfl PRE_first_tail_x15_r0_body.fnk2 : (PTrie.keysA PRE_first_tail_x15_r0_body.kd2.node).all (Nat.ble (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s25.ffi).mlx.nnext) = true
-- the merged state keeps the call's entries off the stage's footprint
kernel_rfl PRE_first_tail_x15_r0_body.f1A2 : PRE_first_tail_x15_r0_body.cx1_2.mlx.arrs = Stage.setAll (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s25.ffi).mlx.arrs (PRE_first_tail_x15_r0_body.cwS2.filterMap fun i => (PRE_first_tail_x15_r0_body.cx1_2.mlx.arrs.get i).map (i, ·))
kernel_rfl PRE_first_tail_x15_r0_body.f1O2 : PRE_first_tail_x15_r0_body.cx1_2.mlx.objs = Stage.setAll (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s25.ffi).mlx.objs (PRE_first_tail_x15_r0_body.cwS2.filterMap fun i => (PRE_first_tail_x15_r0_body.cx1_2.mlx.objs.get i).map (i, ·))
kernel_rfl PRE_first_tail_x15_r0_body.f1N2 : PRE_first_tail_x15_r0_body.cx1_2.mlx.nodes = Stage.setAll (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s25.ffi).mlx.nodes (PRE_first_tail_x15_r0_body.cnS2.filterMap fun i => (PRE_first_tail_x15_r0_body.cx1_2.mlx.nodes.get i).map (i, ·))
kernel_rfl PRE_first_tail_x15_r0_body.f1I2 : PRE_first_tail_x15_r0_body.cx1_2.mlx.items = Stage.setAll (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s25.ffi).mlx.items (PRE_first_tail_x15_r0_body.ciS2.filterMap fun i => (PRE_first_tail_x15_r0_body.cx1_2.mlx.items.get i).map (i, ·))
kernel_rfl PRE_first_tail_x15_r0_body.fbd2 : (PRE_first_tail_x15_r0_body.clo2 ++ PRE_first_tail_x15_r0_body.cln2 ++ PRE_first_tail_x15_r0_body.cli2 ++ PRE_first_tail_x15_r0_body.cwS2 ++ PRE_first_tail_x15_r0_body.cnS2 ++ PRE_first_tail_x15_r0_body.ciS2).all (fun i => Nat.blt (i / 4096) (4 ^ 31)) = true
kernel_rfl PRE_first_tail_x15_r0_body.fincW2 : PRE_first_tail_x15_r0_body.cwS2.all (fun h => !Nat.blt h (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s25.ffi).mlx.next || PRE_first_tail_x15_r0_body.clo2.contains h) = true
kernel_rfl PRE_first_tail_x15_r0_body.fincI2 : PRE_first_tail_x15_r0_body.ciS2.all (fun k => !Nat.blt k (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s25.ffi).mlx.nnext || PRE_first_tail_x15_r0_body.cli2.contains k) = true
kernel_rfl PRE_first_tail_x15_r0_body.fincN2 : PRE_first_tail_x15_r0_body.cnS2.all (Nat.ble (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s25.ffi).mlx.nnext) = true
kernel_rfl PRE_first_tail_x15_r0_body.flnF2 : PRE_first_tail_x15_r0_body.cln2.all (Nat.ble (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s25.ffi).mlx.nnext) = true
-- the checks over the changed lists
kernel_rfl PRE_first_tail_x15_r0_body.fh2 : PRE_first_tail_x15_r0_body.clo2.all (handleOK PRE_first_tail_x15_r0_body.kappa2 PRE_first_tail_x15_r0_body.P2.lo PRE_first_tail_x15_r0_body.cx0_2.mlx PRE_first_tail_x15_r0_body.cx1_2.mlx) = true
kernel_rfl PRE_first_tail_x15_r0_body.fo2 : PRE_first_tail_x15_r0_body.clo2.map (fun h => PRE_first_tail_x15_r0_body.cx1_2.mlx.objs.get (PRE_first_tail_x15_r0_body.kappa2.handle h)) = PRE_first_tail_x15_r0_body.clo2.map (fun h => (PRE_first_tail_x15_r0_body.cx0_2.mlx.objs.get h).map PRE_first_tail_x15_r0_body.kappa2.nobj)
kernel_rfl PRE_first_tail_x15_r0_body.fok2 : PRE_first_tail_x15_r0_body.clo2.all (objOK PRE_first_tail_x15_r0_body.kappa2 PRE_first_tail_x15_r0_body.P2.NL PRE_first_tail_x15_r0_body.cx0_2.mlx) = true
kernel_rfl PRE_first_tail_x15_r0_body.fnd2 : PRE_first_tail_x15_r0_body.cln2.all (nodeOKF PRE_first_tail_x15_r0_body.kappa2 PRE_first_tail_x15_r0_body.P2 PRE_first_tail_x15_r0_body.cx0_2.mlx PRE_first_tail_x15_r0_body.cx1_2.mlx) = true
kernel_rfl PRE_first_tail_x15_r0_body.fp2 : ((PRE_first_tail_x15_r0_body.cln2.filter (fullB PRE_first_tail_x15_r0_body.P2))).map (fun i => (PRE_first_tail_x15_r0_body.cx1_2.mlx.nodes.get (PRE_first_tail_x15_r0_body.kappa2.node i)).map Host.Mlx.Ffi.Node.prim) =
  ((PRE_first_tail_x15_r0_body.cln2.filter (fullB PRE_first_tail_x15_r0_body.P2))).map (fun i => (PRE_first_tail_x15_r0_body.cx0_2.mlx.nodes.get i).map fun nd => PRE_first_tail_x15_r0_body.kappa2.prim nd.prim)
kernel_rfl PRE_first_tail_x15_r0_body.fnordI2 : incrB PRE_first_tail_x15_r0_body.kd2.nodeF (List.range' 15322 0) = true
kernel_rfl PRE_first_tail_x15_r0_body.fnordK2 : (PTrie.keysA PRE_first_tail_x15_r0_body.kd2.node).all (fun k => Nat.ble 15322 k && Nat.blt k 15322) = true
kernel_rfl PRE_first_tail_x15_r0_body.fnordL2 : (PRE_first_tail_x15_r0_body.cln2.filter (Nat.ble PRE_first_tail_x15_r0_body.P2.N0)).all (fun i => Nat.ble i (PRE_first_tail_x15_r0_body.kd2.nodeF i) && (Nat.blt i 15322 || Nat.ble PRE_first_tail_x15_r0_body.kd2.nn0 i)) = true
theorem PRE_first_tail_x15_r0_body.fnord2 : (PRE_first_tail_x15_r0_body.cln2.filter (Nat.ble PRE_first_tail_x15_r0_body.P2.N0)).all (fun i => Nat.ble i (PRE_first_tail_x15_r0_body.kd2.nodeF i) &&
    (PTrie.keysA PRE_first_tail_x15_r0_body.kd2.node).all fun j => !Nat.blt j i || Nat.blt (PRE_first_tail_x15_r0_body.kd2.nodeF j) (PRE_first_tail_x15_r0_body.kd2.nodeF i)) = true :=
  cnord_of PRE_first_tail_x15_r0_body.cnlow2 PRE_first_tail_x15_r0_body.cnn12 PRE_first_tail_x15_r0_body.fnordI2 PRE_first_tail_x15_r0_body.fnordK2 PRE_first_tail_x15_r0_body.fnordL2
kernel_rfl PRE_first_tail_x15_r0_body.fi2 : PRE_first_tail_x15_r0_body.cli2.all (pnB PRE_first_tail_x15_r0_body.cx0_2.mlx) = true
kernel_rfl PRE_first_tail_x15_r0_body.fii2 : PRE_first_tail_x15_r0_body.cli2.all (fun k => decide (PRE_first_tail_x15_r0_body.cx1_2.mlx.items.get (PRE_first_tail_x15_r0_body.kappa2.node k) = (PRE_first_tail_x15_r0_body.cx0_2.mlx.items.get k).map PRE_first_tail_x15_r0_body.kappa2.nv)) = true
/-- **The compaction's footprint.** -/
theorem PRE_first_tail_x15_r0_body.cfoot2 (clean : Conv.NClean (⟨18233, 15322, 2676053, 139⟩ : Conv.Cnt) (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s25.ffi).mlx) (hltC : ∀ h, PH (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s25.ffi).mlx h → h < (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s25.ffi).mlx.next) (nltC : ∀ i, PN (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s25.ffi).mlx i → i < (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s25.ffi).mlx.nnext) (itemsC : ∀ k v, (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s25.ffi).mlx.items.get k = some v → PN (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s25.ffi).mlx k) (tracedC : ∀ h o, (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s25.ffi).mlx.objs.get h = some o → ∀ i ∈ objTraces o, i < PRE_first_tail_x15_r0_body.P2.NL) (cl : SSt (· < 139) PRE_first_tail_x15_r0_body.cx0_2.mlx) :
    Conv.MFoot PRE_first_tail_x15_r0_body.P2 139 PRE_first_tail_x15_r0_body.kappa2 PRE_first_tail_x15_r0_body.kd2 PRE_first_tail_x15_r0_body.khinv2 PRE_first_tail_x15_r0_body.kninv2 (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s25.ffi).mlx PRE_first_tail_x15_r0_body.cx0_2.mlx PRE_first_tail_x15_r0_body.cx1_2.mlx (⟨18233, 15322, 2676053, 139⟩ : Conv.Cnt) PRE_first_tail_x15_r0_body.clo2 PRE_first_tail_x15_r0_body.cln2 PRE_first_tail_x15_r0_body.cli2 PRE_first_tail_x15_r0_body.cwS2 PRE_first_tail_x15_r0_body.cnS2 PRE_first_tail_x15_r0_body.ciS2 :=
  ⟨rfl, rfl, rfl, PRE_first_tail_x15_r0_body.cnh02, PRE_first_tail_x15_r0_body.cnh12, PRE_first_tail_x15_r0_body.cnn02, PRE_first_tail_x15_r0_body.cnn12, PRE_first_tail_x15_r0_body.cplo2, PRE_first_tail_x15_r0_body.ccnt2, PRE_first_tail_x15_r0_body.cnband2, PRE_first_tail_x15_r0_body.chbelow2, PRE_first_tail_x15_r0_body.chren2, PRE_first_tail_x15_r0_body.cband2, PRE_first_tail_x15_r0_body.cnh1pos2, PRE_first_tail_x15_r0_body.cnren2, PRE_first_tail_x15_r0_body.cnlow2, PRE_first_tail_x15_r0_body.cabs0a2, PRE_first_tail_x15_r0_body.cabs0b2, PRE_first_tail_x15_r0_body.ctok12, PRE_first_tail_x15_r0_body.cpend2, PRE_first_tail_x15_r0_body.cerrh2, PRE_first_tail_x15_r0_body.cfiles2, PRE_first_tail_x15_r0_body.carch2, PRE_first_tail_x15_r0_body.csizes2, PRE_first_tail_x15_r0_body.cwired2, PRE_first_tail_x15_r0_body.cfix2, clean, PRE_first_tail_x15_r0_body.fcxn2, PRE_first_tail_x15_r0_body.fcnn2, hltC, nltC, itemsC, tracedC, cl, PRE_first_tail_x15_r0_body.fle02, PRE_first_tail_x15_r0_body.fnk2, PRE_first_tail_x15_r0_body.ckA2, PRE_first_tail_x15_r0_body.cobjsK2, PRE_first_tail_x15_r0_body.cnodesK2, PRE_first_tail_x15_r0_body.citemsK2, PRE_first_tail_x15_r0_body.f1A2, PRE_first_tail_x15_r0_body.f1O2, PRE_first_tail_x15_r0_body.f1N2, PRE_first_tail_x15_r0_body.f1I2, PRE_first_tail_x15_r0_body.fbd2, PRE_first_tail_x15_r0_body.fincW2, PRE_first_tail_x15_r0_body.fincI2, PRE_first_tail_x15_r0_body.fincN2, PRE_first_tail_x15_r0_body.flnF2, PRE_first_tail_x15_r0_body.fh2, PRE_first_tail_x15_r0_body.fo2, PRE_first_tail_x15_r0_body.fok2, PRE_first_tail_x15_r0_body.fnd2, PRE_first_tail_x15_r0_body.fp2, PRE_first_tail_x15_r0_body.fnord2, PRE_first_tail_x15_r0_body.fi2, PRE_first_tail_x15_r0_body.fii2⟩
theorem PRE_first_tail_x15_r0_body.cnshift2 (clean : Conv.NClean (⟨18233, 15322, 2676053, 139⟩ : Conv.Cnt) (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s25.ffi).mlx) (hltC : ∀ h, PH (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s25.ffi).mlx h → h < (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s25.ffi).mlx.next) (nltC : ∀ i, PN (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s25.ffi).mlx i → i < (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s25.ffi).mlx.nnext) (itemsC : ∀ k v, (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s25.ffi).mlx.items.get k = some v → PN (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s25.ffi).mlx k) (tracedC : ∀ h o, (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s25.ffi).mlx.objs.get h = some o → ∀ i ∈ objTraces o, i < PRE_first_tail_x15_r0_body.P2.NL) (cl : SSt (· < 139) PRE_first_tail_x15_r0_body.cx0_2.mlx) : NShift PRE_first_tail_x15_r0_body.P2 139 PRE_first_tail_x15_r0_body.kappa2 PRE_first_tail_x15_r0_body.cx0_2 PRE_first_tail_x15_r0_body.cx1_2 :=
  Conv.nshift_of_foot (PRE_first_tail_x15_r0_body.cfoot2 clean hltC nltC itemsC tracedC cl) PRE_first_tail_x15_r0_body.chost2 (compact_a_eq PRE_first_tail_x15_r0_body.ckn02 PRE_first_tail_x15_r0_body.ckn12 PRE_first_tail_x15_r0_body.ckheap2 PRE_first_tail_x15_r0_body.ckpl2)

-- the observers: the layers' states at the call, the canonical and the merged state, their footprints and checks
noncomputable def PRE_first_tail_x15_r0_body.fxC_2 : PTrie Unit := (Host.Ts.Sim.Full.freedOf PRE_first_tail_x15_r0_body.s25.ffi).getD PTrie.nil
noncomputable def PRE_first_tail_x15_r0_body.krC_2 : Host.Load.Layers.KRec := (Host.Ts.Sim.Full.krecOf PRE_first_tail_x15_r0_body.s25.ffi).getD Host.Load.Layers.KRec.empty
kernel_rfl PRE_first_tail_x15_r0_body.ofxC_2 : (Host.Ts.Sim.Full.freedOf PRE_first_tail_x15_r0_body.s25.ffi) = some PRE_first_tail_x15_r0_body.fxC_2
kernel_rfl PRE_first_tail_x15_r0_body.okrC_2 : (Host.Ts.Sim.Full.krecOf PRE_first_tail_x15_r0_body.s25.ffi) = some PRE_first_tail_x15_r0_body.krC_2
noncomputable def PRE_first_tail_x15_r0_body.fx0_2 : PTrie Unit := (Host.Ts.Sim.Full.freedOf PRE_first_tail_x15_r0_body.s27.ffi).getD PTrie.nil
noncomputable def PRE_first_tail_x15_r0_body.kr0_2 : Host.Load.Layers.KRec := (Host.Ts.Sim.Full.krecOf PRE_first_tail_x15_r0_body.s27.ffi).getD Host.Load.Layers.KRec.empty
kernel_rfl PRE_first_tail_x15_r0_body.ofx0_2 : (Host.Ts.Sim.Full.freedOf PRE_first_tail_x15_r0_body.s27.ffi) = some PRE_first_tail_x15_r0_body.fx0_2
kernel_rfl PRE_first_tail_x15_r0_body.okr0_2 : (Host.Ts.Sim.Full.krecOf PRE_first_tail_x15_r0_body.s27.ffi) = some PRE_first_tail_x15_r0_body.kr0_2
noncomputable def PRE_first_tail_x15_r0_body.fx1_2 : PTrie Unit := (Host.Ts.Sim.Full.freedOf PRE_first_tail_x15_r0_body.s26.ffi).getD PTrie.nil
noncomputable def PRE_first_tail_x15_r0_body.kr1_2 : Host.Load.Layers.KRec := (Host.Ts.Sim.Full.krecOf PRE_first_tail_x15_r0_body.s26.ffi).getD Host.Load.Layers.KRec.empty
kernel_rfl PRE_first_tail_x15_r0_body.ofx1_2 : (Host.Ts.Sim.Full.freedOf PRE_first_tail_x15_r0_body.s26.ffi) = some PRE_first_tail_x15_r0_body.fx1_2
kernel_rfl PRE_first_tail_x15_r0_body.okr1_2 : (Host.Ts.Sim.Full.krecOf PRE_first_tail_x15_r0_body.s26.ffi) = some PRE_first_tail_x15_r0_body.kr1_2
kernel_rfl PRE_first_tail_x15_r0_body.ff02 : PRE_first_tail_x15_r0_body.fx0_2 = Stage.setAll PRE_first_tail_x15_r0_body.fxC_2 (PRE_first_tail_x15_r0_body.clo2.filterMap fun i => (PRE_first_tail_x15_r0_body.fx0_2.get i).map (i, ·))
kernel_rfl PRE_first_tail_x15_r0_body.ff12 : PRE_first_tail_x15_r0_body.fx1_2 = Stage.setAll PRE_first_tail_x15_r0_body.fxC_2 (PRE_first_tail_x15_r0_body.cwS2.filterMap fun i => (PRE_first_tail_x15_r0_body.fx1_2.get i).map (i, ·))
kernel_rfl PRE_first_tail_x15_r0_body.ffck2 : freedLB PRE_first_tail_x15_r0_body.kappa2 PRE_first_tail_x15_r0_body.cx0_2.mlx PRE_first_tail_x15_r0_body.fx0_2 PRE_first_tail_x15_r0_body.fx1_2 PRE_first_tail_x15_r0_body.clo2 = true
kernel_rfl PRE_first_tail_x15_r0_body.fkf02 : PRE_first_tail_x15_r0_body.kr0_2.flags = Stage.setAll PRE_first_tail_x15_r0_body.krC_2.flags (PRE_first_tail_x15_r0_body.clo2.filterMap fun i => (PRE_first_tail_x15_r0_body.kr0_2.flags.get i).map (i, ·))
kernel_rfl PRE_first_tail_x15_r0_body.fkt02 : PRE_first_tail_x15_r0_body.kr0_2.targs = Stage.setAll PRE_first_tail_x15_r0_body.krC_2.targs (PRE_first_tail_x15_r0_body.clo2.filterMap fun i => (PRE_first_tail_x15_r0_body.kr0_2.targs.get i).map (i, ·))
kernel_rfl PRE_first_tail_x15_r0_body.fkf12 : PRE_first_tail_x15_r0_body.kr1_2.flags = Stage.setAll PRE_first_tail_x15_r0_body.krC_2.flags (PRE_first_tail_x15_r0_body.cwS2.filterMap fun i => (PRE_first_tail_x15_r0_body.kr1_2.flags.get i).map (i, ·))
kernel_rfl PRE_first_tail_x15_r0_body.fkt12 : PRE_first_tail_x15_r0_body.kr1_2.targs = Stage.setAll PRE_first_tail_x15_r0_body.krC_2.targs (PRE_first_tail_x15_r0_body.cwS2.filterMap fun i => (PRE_first_tail_x15_r0_body.kr1_2.targs.get i).map (i, ·))
kernel_rfl PRE_first_tail_x15_r0_body.fkck2 : krecLB PRE_first_tail_x15_r0_body.kappa2 139 PRE_first_tail_x15_r0_body.cx0_2.mlx PRE_first_tail_x15_r0_body.kr0_2 PRE_first_tail_x15_r0_body.kr1_2 PRE_first_tail_x15_r0_body.clo2 = true
kernel_rfl PRE_first_tail_x15_r0_body.fkn2 : Nat.ble 139 139 = true
-- the bridge and the pending traces' regions
kernel_rfl PRE_first_tail_x15_r0_body.cbridge2 : Host.Ts.Sim.Full.bridgeOf PRE_first_tail_x15_r0_body.s26.ffi = Host.Ts.Sim.Full.bridgeOf PRE_first_tail_x15_r0_body.s27.ffi
kernel_rfl PRE_first_tail_x15_r0_body.cpendR2 : pendRegB PRE_first_tail_x15_r0_body.kappa2 (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s27.ffi).mlx = true
kernel_rfl PRE_first_tail_x15_r0_body.cpendLe2 : Nat.ble (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s27.ffi).mlx.next (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s26.ffi).mlx.next = true
/-- **The compaction's native shift**, given the call's bookkeeping, its relation's facts (the model's and the
observers') and the canonical closedness. -/
theorem PRE_first_tail_x15_r0_body.cshift2 (clean : Conv.NClean (⟨18233, 15322, 2676053, 139⟩ : Conv.Cnt) (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s25.ffi).mlx) (hltC : ∀ h, PH (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s25.ffi).mlx h → h < (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s25.ffi).mlx.next) (nltC : ∀ i, PN (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s25.ffi).mlx i → i < (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s25.ffi).mlx.nnext) (itemsC : ∀ k v, (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s25.ffi).mlx.items.get k = some v → PN (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s25.ffi).mlx k) (tracedC : ∀ h o, (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s25.ffi).mlx.objs.get h = some o → ∀ i ∈ objTraces o, i < PRE_first_tail_x15_r0_body.P2.NL) (cl : SSt (· < 139) PRE_first_tail_x15_r0_body.cx0_2.mlx)
    (hobjC : ∀ h, PRE_first_tail_x15_r0_body.fxC_2.get h = some () → ((Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s25.ffi).mlx.objs.get h).isSome = true)
    (hfC : ∀ h, (PRE_first_tail_x15_r0_body.krC_2.flags.get h).isSome = true → ((Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s25.ffi).mlx.objs.get h).isSome = true)
    (htC : ∀ h, (PRE_first_tail_x15_r0_body.krC_2.targs.get h).isSome = true → ((Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s25.ffi).mlx.objs.get h).isSome = true)
    (hclC : ∀ h l, PRE_first_tail_x15_r0_body.krC_2.targs.get h = some l → Host.Ts.Sim.Full.STargs (· < (⟨18233, 15322, 2676053, 139⟩ : Conv.Cnt).n) l) :
    Conv.FullShiftQ PRE_first_tail_x15_r0_body.P2 139 PRE_first_tail_x15_r0_body.kappa2 PRE_first_tail_x15_r0_body.s27.ffi PRE_first_tail_x15_r0_body.s26.ffi :=
  ⟨PRE_first_tail_x15_r0_body.cnshift2 clean hltC nltC itemsC tracedC cl, PRE_first_tail_x15_r0_body.cqueue2, fun t ht => bSN_sound (List.all_eq_true.mp PRE_first_tail_x15_r0_body.ctokSupp2 t ht),
    PRE_first_tail_x15_r0_body.cbridge2,
    liveShift_foot (x0' := Host.Ts.Sim.Full.mlxOf PRE_first_tail_x15_r0_body.s27.ffi) (x1' := Host.Ts.Sim.Full.mlxOf PRE_first_tail_x15_r0_body.s26.ffi) (PRE_first_tail_x15_r0_body.cfoot2 clean hltC nltC itemsC tracedC cl) rfl PRE_first_tail_x15_r0_body.ofx0_2 PRE_first_tail_x15_r0_body.ofx1_2 hobjC PRE_first_tail_x15_r0_body.ff02 PRE_first_tail_x15_r0_body.ff12 PRE_first_tail_x15_r0_body.ffck2,
    kernShift_foot (x0' := Host.Ts.Sim.Full.mlxOf PRE_first_tail_x15_r0_body.s27.ffi) (x1' := Host.Ts.Sim.Full.mlxOf PRE_first_tail_x15_r0_body.s26.ffi) (PRE_first_tail_x15_r0_body.cfoot2 clean hltC nltC itemsC tracedC cl) rfl PRE_first_tail_x15_r0_body.okr0_2 PRE_first_tail_x15_r0_body.okr1_2 (Nat.le_of_ble_eq_true PRE_first_tail_x15_r0_body.fkn2) hfC htC hclC
      PRE_first_tail_x15_r0_body.fkf02 PRE_first_tail_x15_r0_body.fkt02 PRE_first_tail_x15_r0_body.fkf12 PRE_first_tail_x15_r0_body.fkt12 PRE_first_tail_x15_r0_body.fkck2,
    pendReg_of rfl PRE_first_tail_x15_r0_body.cnh02 PRE_first_tail_x15_r0_body.cnh12 (Nat.le_of_ble_eq_true PRE_first_tail_x15_r0_body.cpendLe2) PRE_first_tail_x15_r0_body.cpendR2⟩

end Host.Load.Run.Tpl
