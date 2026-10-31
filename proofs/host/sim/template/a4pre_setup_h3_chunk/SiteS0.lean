import host.sim.template.a4pre_setup_h3_chunk.SiteCl0
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

/-- The load parameters of the chain (band-free: its start's node counter as `NL` and `N0`). -/
def PRE_setup_h3_chunk.Pc0 : LoadP := ⟨18151, 131072, 1099511627776, 15235, 15235, []⟩
/-- The site's band raised to the map's checked fixed-node prefix, including newly recorded closure traces. -/
def PRE_setup_h3_chunk.P0 : LoadP := PRE_setup_h3_chunk.Pc0.raise 15235
kernel_rfl PRE_setup_h3_chunk.craise0 : Nat.ble PRE_setup_h3_chunk.Pc0.N0 15235 = true
theorem PRE_setup_h3_chunk.raised0 : Host.Ts.Sim.Full.Raised PRE_setup_h3_chunk.Pc0 PRE_setup_h3_chunk.P0 :=
  .inr ⟨15235, rfl, Nat.le_of_ble_eq_true PRE_setup_h3_chunk.craise0, rfl⟩
noncomputable abbrev PRE_setup_h3_chunk.cx0_0 : Host.Load.LSt := clearTokens (Host.Load.Layers.toLoad PRE_setup_h3_chunk.s2.ffi)
noncomputable abbrev PRE_setup_h3_chunk.cx1_0 : Host.Load.LSt := clearTokens (Host.Load.Layers.toLoad PRE_setup_h3_chunk.s1.ffi)
def PRE_setup_h3_chunk.khinv0 : PTrie Nat := Stage.setAll PTrie.nil []
def PRE_setup_h3_chunk.kninv0 : PTrie Nat := Stage.setAll PTrie.nil []
/-- The stage's footprint: its written and fresh handles, fresh nodes, written and fresh items. -/
def PRE_setup_h3_chunk.cwS0 : List Nat := []
def PRE_setup_h3_chunk.cnS0 : List Nat := List.range' 15235 0
def PRE_setup_h3_chunk.ciS0 : List Nat := [] ++ List.range' 15235 0

-- the small checks (`MChecks`'s)
kernel_rfl PRE_setup_h3_chunk.cnh00 : PRE_setup_h3_chunk.kd0.nh0 = PRE_setup_h3_chunk.cx0_0.mlx.next
kernel_rfl PRE_setup_h3_chunk.cnh10 : PRE_setup_h3_chunk.kd0.nh1 = PRE_setup_h3_chunk.cx1_0.mlx.next
kernel_rfl PRE_setup_h3_chunk.cnn00 : PRE_setup_h3_chunk.kd0.nn0 = PRE_setup_h3_chunk.cx0_0.mlx.nnext
kernel_rfl PRE_setup_h3_chunk.cnn10 : PRE_setup_h3_chunk.kd0.nn1 = PRE_setup_h3_chunk.cx1_0.mlx.nnext
kernel_rfl PRE_setup_h3_chunk.cplo0 : (Nat.blt 0 PRE_setup_h3_chunk.P0.lo && Nat.ble PRE_setup_h3_chunk.P0.lo PRE_setup_h3_chunk.cx0_0.mlx.next && Nat.ble PRE_setup_h3_chunk.P0.lo RData.bigHi && Nat.ble RData.bigHi PRE_setup_h3_chunk.P0.E) = true
kernel_rfl PRE_setup_h3_chunk.ccnt0 : (Nat.ble PRE_setup_h3_chunk.cx0_0.mlx.next PRE_setup_h3_chunk.cx1_0.mlx.next && Nat.ble PRE_setup_h3_chunk.cx0_0.mlx.nnext PRE_setup_h3_chunk.cx1_0.mlx.nnext) = true
kernel_rfl PRE_setup_h3_chunk.cnband0 : (Nat.blt 0 PRE_setup_h3_chunk.P0.NL && Nat.ble PRE_setup_h3_chunk.P0.NL PRE_setup_h3_chunk.P0.N0 && Nat.ble PRE_setup_h3_chunk.P0.N0 PRE_setup_h3_chunk.cx0_0.mlx.nnext) = true
kernel_rfl PRE_setup_h3_chunk.chbelow0 : PRE_setup_h3_chunk.kd0.checkHndBelow = true
kernel_rfl PRE_setup_h3_chunk.chren0 : checkRenG PRE_setup_h3_chunk.kd0.hnd PRE_setup_h3_chunk.khinv0 (phB PRE_setup_h3_chunk.cx0_0.mlx) = true
kernel_rfl PRE_setup_h3_chunk.cband0 : PRE_setup_h3_chunk.kd0.checkBand PRE_setup_h3_chunk.P0.lo = true
kernel_rfl PRE_setup_h3_chunk.cnh1pos0 : Nat.blt 0 PRE_setup_h3_chunk.kd0.nh1 = true
kernel_rfl PRE_setup_h3_chunk.cnren0 : checkRenG PRE_setup_h3_chunk.kd0.node PRE_setup_h3_chunk.kninv0 (pnB PRE_setup_h3_chunk.cx0_0.mlx) = true
kernel_rfl PRE_setup_h3_chunk.cnlow0 : (PTrie.keysA PRE_setup_h3_chunk.kd0.node).all (fun j => Nat.ble PRE_setup_h3_chunk.P0.NL j && Nat.blt (PRE_setup_h3_chunk.kd0.nodeF j) PRE_setup_h3_chunk.cx1_0.mlx.nnext) = true
kernel_rfl PRE_setup_h3_chunk.cabs0a0 : PRE_setup_h3_chunk.cx0_0.mlx.arrs.get 0 = none
kernel_rfl PRE_setup_h3_chunk.cabs0b0 : PRE_setup_h3_chunk.cx0_0.mlx.objs.get 0 = none
kernel_rfl PRE_setup_h3_chunk.ctok10 : PRE_setup_h3_chunk.cx1_0.mlx.tokens = []
kernel_rfl PRE_setup_h3_chunk.cpend0 : PRE_setup_h3_chunk.cx1_0.mlx.pending = PRE_setup_h3_chunk.cx0_0.mlx.pending.map PRE_setup_h3_chunk.kappa0.pend
kernel_rfl PRE_setup_h3_chunk.cerrh0 : PRE_setup_h3_chunk.cx1_0.mlx.errh = PRE_setup_h3_chunk.cx0_0.mlx.errh.map PRE_setup_h3_chunk.kappa0.arg
kernel_rfl PRE_setup_h3_chunk.cfiles0 : PRE_setup_h3_chunk.cx1_0.mlx.files = PRE_setup_h3_chunk.cx0_0.mlx.files
kernel_rfl PRE_setup_h3_chunk.carch0 : PRE_setup_h3_chunk.cx1_0.mlx.arch = PRE_setup_h3_chunk.cx0_0.mlx.arch
kernel_rfl PRE_setup_h3_chunk.csizes0 : PRE_setup_h3_chunk.cx1_0.mlx.deviceSizes = PRE_setup_h3_chunk.cx0_0.mlx.deviceSizes
kernel_rfl PRE_setup_h3_chunk.cwired0 : PRE_setup_h3_chunk.cx1_0.mlx.wired = PRE_setup_h3_chunk.cx0_0.mlx.wired
kernel_rfl PRE_setup_h3_chunk.chost0 : PRE_setup_h3_chunk.cx1_0.host = PRE_setup_h3_chunk.cx0_0.host
-- the compaction map's addresses are `PRE_setup_h3_chunk.kd0`'s
kernel_rfl PRE_setup_h3_chunk.ckn00 : PRE_setup_h3_chunk.kd0.n0 = 2673336
kernel_rfl PRE_setup_h3_chunk.ckn10 : PRE_setup_h3_chunk.kd0.n1 = 2675688
kernel_rfl PRE_setup_h3_chunk.ckheap0 : (PTrie.keysA PRE_setup_h3_chunk.kd0.heap).all (fun x => Nat.ble 2673336 x) = true
kernel_rfl PRE_setup_h3_chunk.ckpl0 : (List.range 0).all (fun j => decide (PRE_setup_h3_chunk.kd0.heap.get (2673336 + j) = nth? PRE_setup_h3_chunk.pl0 j)) = true
-- the map fixes the call's names (`Conv.fixOld_compact`), the call's counters
kernel_rfl PRE_setup_h3_chunk.fja0 : Nat.ble 2673336 2673336 = true
kernel_rfl PRE_setup_h3_chunk.fn0 : Nat.ble 10 10 = true
kernel_rfl PRE_setup_h3_chunk.fjaD0 : Nat.ble 2673336 PRE_setup_h3_chunk.kd0.n0 = true
kernel_rfl PRE_setup_h3_chunk.fxn0 : Nat.ble 18155 PRE_setup_h3_chunk.kd0.nh0 = true
kernel_rfl PRE_setup_h3_chunk.fnn0 : Nat.ble 15235 PRE_setup_h3_chunk.kd0.nn0 = true
kernel_rfl PRE_setup_h3_chunk.fxb0 : Nat.ble 18155 RData.bigHi = true
kernel_rfl PRE_setup_h3_chunk.fheap0 : (PTrie.keysA PRE_setup_h3_chunk.kd0.heap).all (Nat.ble (⟨18155, 15235, 2673336, 10⟩ : Conv.Cnt).ja) = true
kernel_rfl PRE_setup_h3_chunk.fhnd0 : (PTrie.keysA PRE_setup_h3_chunk.kd0.hnd).all (Nat.ble (⟨18155, 15235, 2673336, 10⟩ : Conv.Cnt).xn) = true
kernel_rfl PRE_setup_h3_chunk.fnode0 : (PTrie.keysA PRE_setup_h3_chunk.kd0.node).all (Nat.ble (⟨18155, 15235, 2673336, 10⟩ : Conv.Cnt).nn) = true
/-- The compaction map fixes the call's names. -/
theorem PRE_setup_h3_chunk.cfix0 : Conv.FixOld (⟨18155, 15235, 2673336, 10⟩ : Conv.Cnt) PRE_setup_h3_chunk.kappa0 :=
  Conv.fixOld_compact (Nat.le_of_ble_eq_true PRE_setup_h3_chunk.fja0) (Nat.le_of_ble_eq_true PRE_setup_h3_chunk.fn0) (Nat.le_of_ble_eq_true PRE_setup_h3_chunk.fjaD0) (Nat.le_of_ble_eq_true PRE_setup_h3_chunk.fxn0) (Nat.le_of_ble_eq_true PRE_setup_h3_chunk.fnn0) (Nat.le_of_ble_eq_true PRE_setup_h3_chunk.fxb0) PRE_setup_h3_chunk.fheap0 PRE_setup_h3_chunk.fhnd0 PRE_setup_h3_chunk.fnode0
kernel_rfl PRE_setup_h3_chunk.fcxn0 : (⟨18155, 15235, 2673336, 10⟩ : Conv.Cnt).xn = (Host.Load.Layers.toLoad PRE_setup_h3_chunk.s0.ffi).mlx.next
kernel_rfl PRE_setup_h3_chunk.fcnn0 : (⟨18155, 15235, 2673336, 10⟩ : Conv.Cnt).nn = (Host.Load.Layers.toLoad PRE_setup_h3_chunk.s0.ffi).mlx.nnext
kernel_rfl PRE_setup_h3_chunk.fle00 : (Nat.ble (Host.Load.Layers.toLoad PRE_setup_h3_chunk.s0.ffi).mlx.next PRE_setup_h3_chunk.cx0_0.mlx.next && Nat.ble (Host.Load.Layers.toLoad PRE_setup_h3_chunk.s0.ffi).mlx.nnext PRE_setup_h3_chunk.cx0_0.mlx.nnext && Nat.ble (Host.Load.Layers.toLoad PRE_setup_h3_chunk.s0.ffi).mlx.next RData.bigHi) = true
kernel_rfl PRE_setup_h3_chunk.fnk0 : (PTrie.keysA PRE_setup_h3_chunk.kd0.node).all (Nat.ble (Host.Load.Layers.toLoad PRE_setup_h3_chunk.s0.ffi).mlx.nnext) = true
-- the merged state keeps the call's entries off the stage's footprint
kernel_rfl PRE_setup_h3_chunk.f1A0 : PRE_setup_h3_chunk.cx1_0.mlx.arrs = Stage.setAll (Host.Load.Layers.toLoad PRE_setup_h3_chunk.s0.ffi).mlx.arrs (PRE_setup_h3_chunk.cwS0.filterMap fun i => (PRE_setup_h3_chunk.cx1_0.mlx.arrs.get i).map (i, ·))
kernel_rfl PRE_setup_h3_chunk.f1O0 : PRE_setup_h3_chunk.cx1_0.mlx.objs = Stage.setAll (Host.Load.Layers.toLoad PRE_setup_h3_chunk.s0.ffi).mlx.objs (PRE_setup_h3_chunk.cwS0.filterMap fun i => (PRE_setup_h3_chunk.cx1_0.mlx.objs.get i).map (i, ·))
kernel_rfl PRE_setup_h3_chunk.f1N0 : PRE_setup_h3_chunk.cx1_0.mlx.nodes = Stage.setAll (Host.Load.Layers.toLoad PRE_setup_h3_chunk.s0.ffi).mlx.nodes (PRE_setup_h3_chunk.cnS0.filterMap fun i => (PRE_setup_h3_chunk.cx1_0.mlx.nodes.get i).map (i, ·))
kernel_rfl PRE_setup_h3_chunk.f1I0 : PRE_setup_h3_chunk.cx1_0.mlx.items = Stage.setAll (Host.Load.Layers.toLoad PRE_setup_h3_chunk.s0.ffi).mlx.items (PRE_setup_h3_chunk.ciS0.filterMap fun i => (PRE_setup_h3_chunk.cx1_0.mlx.items.get i).map (i, ·))
kernel_rfl PRE_setup_h3_chunk.fbd0 : (PRE_setup_h3_chunk.clo0 ++ PRE_setup_h3_chunk.cln0 ++ PRE_setup_h3_chunk.cli0 ++ PRE_setup_h3_chunk.cwS0 ++ PRE_setup_h3_chunk.cnS0 ++ PRE_setup_h3_chunk.ciS0).all (fun i => Nat.blt (i / 4096) (4 ^ 31)) = true
kernel_rfl PRE_setup_h3_chunk.fincW0 : PRE_setup_h3_chunk.cwS0.all (fun h => !Nat.blt h (Host.Load.Layers.toLoad PRE_setup_h3_chunk.s0.ffi).mlx.next || PRE_setup_h3_chunk.clo0.contains h) = true
kernel_rfl PRE_setup_h3_chunk.fincI0 : PRE_setup_h3_chunk.ciS0.all (fun k => !Nat.blt k (Host.Load.Layers.toLoad PRE_setup_h3_chunk.s0.ffi).mlx.nnext || PRE_setup_h3_chunk.cli0.contains k) = true
kernel_rfl PRE_setup_h3_chunk.fincN0 : PRE_setup_h3_chunk.cnS0.all (Nat.ble (Host.Load.Layers.toLoad PRE_setup_h3_chunk.s0.ffi).mlx.nnext) = true
kernel_rfl PRE_setup_h3_chunk.flnF0 : PRE_setup_h3_chunk.cln0.all (Nat.ble (Host.Load.Layers.toLoad PRE_setup_h3_chunk.s0.ffi).mlx.nnext) = true
-- the checks over the changed lists
kernel_rfl PRE_setup_h3_chunk.fh0 : PRE_setup_h3_chunk.clo0.all (handleOK PRE_setup_h3_chunk.kappa0 PRE_setup_h3_chunk.P0.lo PRE_setup_h3_chunk.cx0_0.mlx PRE_setup_h3_chunk.cx1_0.mlx) = true
kernel_rfl PRE_setup_h3_chunk.fo0 : PRE_setup_h3_chunk.clo0.map (fun h => PRE_setup_h3_chunk.cx1_0.mlx.objs.get (PRE_setup_h3_chunk.kappa0.handle h)) = PRE_setup_h3_chunk.clo0.map (fun h => (PRE_setup_h3_chunk.cx0_0.mlx.objs.get h).map PRE_setup_h3_chunk.kappa0.nobj)
kernel_rfl PRE_setup_h3_chunk.fok0 : PRE_setup_h3_chunk.clo0.all (objOK PRE_setup_h3_chunk.kappa0 PRE_setup_h3_chunk.P0.NL PRE_setup_h3_chunk.cx0_0.mlx) = true
kernel_rfl PRE_setup_h3_chunk.fnd0 : PRE_setup_h3_chunk.cln0.all (nodeOKF PRE_setup_h3_chunk.kappa0 PRE_setup_h3_chunk.P0 PRE_setup_h3_chunk.cx0_0.mlx PRE_setup_h3_chunk.cx1_0.mlx) = true
kernel_rfl PRE_setup_h3_chunk.fp0 : ((PRE_setup_h3_chunk.cln0.filter (fullB PRE_setup_h3_chunk.P0))).map (fun i => (PRE_setup_h3_chunk.cx1_0.mlx.nodes.get (PRE_setup_h3_chunk.kappa0.node i)).map Host.Mlx.Ffi.Node.prim) =
  ((PRE_setup_h3_chunk.cln0.filter (fullB PRE_setup_h3_chunk.P0))).map (fun i => (PRE_setup_h3_chunk.cx0_0.mlx.nodes.get i).map fun nd => PRE_setup_h3_chunk.kappa0.prim nd.prim)
kernel_rfl PRE_setup_h3_chunk.fnordI0 : incrB PRE_setup_h3_chunk.kd0.nodeF (List.range' 15235 0) = true
kernel_rfl PRE_setup_h3_chunk.fnordK0 : (PTrie.keysA PRE_setup_h3_chunk.kd0.node).all (fun k => Nat.ble 15235 k && Nat.blt k 15235) = true
kernel_rfl PRE_setup_h3_chunk.fnordL0 : (PRE_setup_h3_chunk.cln0.filter (Nat.ble PRE_setup_h3_chunk.P0.N0)).all (fun i => Nat.ble i (PRE_setup_h3_chunk.kd0.nodeF i) && (Nat.blt i 15235 || Nat.ble PRE_setup_h3_chunk.kd0.nn0 i)) = true
theorem PRE_setup_h3_chunk.fnord0 : (PRE_setup_h3_chunk.cln0.filter (Nat.ble PRE_setup_h3_chunk.P0.N0)).all (fun i => Nat.ble i (PRE_setup_h3_chunk.kd0.nodeF i) &&
    (PTrie.keysA PRE_setup_h3_chunk.kd0.node).all fun j => !Nat.blt j i || Nat.blt (PRE_setup_h3_chunk.kd0.nodeF j) (PRE_setup_h3_chunk.kd0.nodeF i)) = true :=
  cnord_of PRE_setup_h3_chunk.cnlow0 PRE_setup_h3_chunk.cnn10 PRE_setup_h3_chunk.fnordI0 PRE_setup_h3_chunk.fnordK0 PRE_setup_h3_chunk.fnordL0
kernel_rfl PRE_setup_h3_chunk.fi0 : PRE_setup_h3_chunk.cli0.all (pnB PRE_setup_h3_chunk.cx0_0.mlx) = true
kernel_rfl PRE_setup_h3_chunk.fii0 : PRE_setup_h3_chunk.cli0.all (fun k => decide (PRE_setup_h3_chunk.cx1_0.mlx.items.get (PRE_setup_h3_chunk.kappa0.node k) = (PRE_setup_h3_chunk.cx0_0.mlx.items.get k).map PRE_setup_h3_chunk.kappa0.nv)) = true
/-- **The compaction's footprint.** -/
theorem PRE_setup_h3_chunk.cfoot0 (clean : Conv.NClean (⟨18155, 15235, 2673336, 10⟩ : Conv.Cnt) (Host.Load.Layers.toLoad PRE_setup_h3_chunk.s0.ffi).mlx) (hltC : ∀ h, PH (Host.Load.Layers.toLoad PRE_setup_h3_chunk.s0.ffi).mlx h → h < (Host.Load.Layers.toLoad PRE_setup_h3_chunk.s0.ffi).mlx.next) (nltC : ∀ i, PN (Host.Load.Layers.toLoad PRE_setup_h3_chunk.s0.ffi).mlx i → i < (Host.Load.Layers.toLoad PRE_setup_h3_chunk.s0.ffi).mlx.nnext) (itemsC : ∀ k v, (Host.Load.Layers.toLoad PRE_setup_h3_chunk.s0.ffi).mlx.items.get k = some v → PN (Host.Load.Layers.toLoad PRE_setup_h3_chunk.s0.ffi).mlx k) (tracedC : ∀ h o, (Host.Load.Layers.toLoad PRE_setup_h3_chunk.s0.ffi).mlx.objs.get h = some o → ∀ i ∈ objTraces o, i < PRE_setup_h3_chunk.P0.NL) (cl : SSt (· < 10) PRE_setup_h3_chunk.cx0_0.mlx) :
    Conv.MFoot PRE_setup_h3_chunk.P0 10 PRE_setup_h3_chunk.kappa0 PRE_setup_h3_chunk.kd0 PRE_setup_h3_chunk.khinv0 PRE_setup_h3_chunk.kninv0 (Host.Load.Layers.toLoad PRE_setup_h3_chunk.s0.ffi).mlx PRE_setup_h3_chunk.cx0_0.mlx PRE_setup_h3_chunk.cx1_0.mlx (⟨18155, 15235, 2673336, 10⟩ : Conv.Cnt) PRE_setup_h3_chunk.clo0 PRE_setup_h3_chunk.cln0 PRE_setup_h3_chunk.cli0 PRE_setup_h3_chunk.cwS0 PRE_setup_h3_chunk.cnS0 PRE_setup_h3_chunk.ciS0 :=
  ⟨rfl, rfl, rfl, PRE_setup_h3_chunk.cnh00, PRE_setup_h3_chunk.cnh10, PRE_setup_h3_chunk.cnn00, PRE_setup_h3_chunk.cnn10, PRE_setup_h3_chunk.cplo0, PRE_setup_h3_chunk.ccnt0, PRE_setup_h3_chunk.cnband0, PRE_setup_h3_chunk.chbelow0, PRE_setup_h3_chunk.chren0, PRE_setup_h3_chunk.cband0, PRE_setup_h3_chunk.cnh1pos0, PRE_setup_h3_chunk.cnren0, PRE_setup_h3_chunk.cnlow0, PRE_setup_h3_chunk.cabs0a0, PRE_setup_h3_chunk.cabs0b0, PRE_setup_h3_chunk.ctok10, PRE_setup_h3_chunk.cpend0, PRE_setup_h3_chunk.cerrh0, PRE_setup_h3_chunk.cfiles0, PRE_setup_h3_chunk.carch0, PRE_setup_h3_chunk.csizes0, PRE_setup_h3_chunk.cwired0, PRE_setup_h3_chunk.cfix0, clean, PRE_setup_h3_chunk.fcxn0, PRE_setup_h3_chunk.fcnn0, hltC, nltC, itemsC, tracedC, cl, PRE_setup_h3_chunk.fle00, PRE_setup_h3_chunk.fnk0, PRE_setup_h3_chunk.ckA0, PRE_setup_h3_chunk.cobjsK0, PRE_setup_h3_chunk.cnodesK0, PRE_setup_h3_chunk.citemsK0, PRE_setup_h3_chunk.f1A0, PRE_setup_h3_chunk.f1O0, PRE_setup_h3_chunk.f1N0, PRE_setup_h3_chunk.f1I0, PRE_setup_h3_chunk.fbd0, PRE_setup_h3_chunk.fincW0, PRE_setup_h3_chunk.fincI0, PRE_setup_h3_chunk.fincN0, PRE_setup_h3_chunk.flnF0, PRE_setup_h3_chunk.fh0, PRE_setup_h3_chunk.fo0, PRE_setup_h3_chunk.fok0, PRE_setup_h3_chunk.fnd0, PRE_setup_h3_chunk.fp0, PRE_setup_h3_chunk.fnord0, PRE_setup_h3_chunk.fi0, PRE_setup_h3_chunk.fii0⟩
theorem PRE_setup_h3_chunk.cnshift0 (clean : Conv.NClean (⟨18155, 15235, 2673336, 10⟩ : Conv.Cnt) (Host.Load.Layers.toLoad PRE_setup_h3_chunk.s0.ffi).mlx) (hltC : ∀ h, PH (Host.Load.Layers.toLoad PRE_setup_h3_chunk.s0.ffi).mlx h → h < (Host.Load.Layers.toLoad PRE_setup_h3_chunk.s0.ffi).mlx.next) (nltC : ∀ i, PN (Host.Load.Layers.toLoad PRE_setup_h3_chunk.s0.ffi).mlx i → i < (Host.Load.Layers.toLoad PRE_setup_h3_chunk.s0.ffi).mlx.nnext) (itemsC : ∀ k v, (Host.Load.Layers.toLoad PRE_setup_h3_chunk.s0.ffi).mlx.items.get k = some v → PN (Host.Load.Layers.toLoad PRE_setup_h3_chunk.s0.ffi).mlx k) (tracedC : ∀ h o, (Host.Load.Layers.toLoad PRE_setup_h3_chunk.s0.ffi).mlx.objs.get h = some o → ∀ i ∈ objTraces o, i < PRE_setup_h3_chunk.P0.NL) (cl : SSt (· < 10) PRE_setup_h3_chunk.cx0_0.mlx) : NShift PRE_setup_h3_chunk.P0 10 PRE_setup_h3_chunk.kappa0 PRE_setup_h3_chunk.cx0_0 PRE_setup_h3_chunk.cx1_0 :=
  Conv.nshift_of_foot (PRE_setup_h3_chunk.cfoot0 clean hltC nltC itemsC tracedC cl) PRE_setup_h3_chunk.chost0 (compact_a_eq PRE_setup_h3_chunk.ckn00 PRE_setup_h3_chunk.ckn10 PRE_setup_h3_chunk.ckheap0 PRE_setup_h3_chunk.ckpl0)

-- the observers: the layers' states at the call, the canonical and the merged state, their footprints and checks
noncomputable def PRE_setup_h3_chunk.fxC_0 : PTrie Unit := (Host.Ts.Sim.Full.freedOf PRE_setup_h3_chunk.s0.ffi).getD PTrie.nil
noncomputable def PRE_setup_h3_chunk.krC_0 : Host.Load.Layers.KRec := (Host.Ts.Sim.Full.krecOf PRE_setup_h3_chunk.s0.ffi).getD Host.Load.Layers.KRec.empty
kernel_rfl PRE_setup_h3_chunk.ofxC_0 : (Host.Ts.Sim.Full.freedOf PRE_setup_h3_chunk.s0.ffi) = some PRE_setup_h3_chunk.fxC_0
kernel_rfl PRE_setup_h3_chunk.okrC_0 : (Host.Ts.Sim.Full.krecOf PRE_setup_h3_chunk.s0.ffi) = some PRE_setup_h3_chunk.krC_0
noncomputable def PRE_setup_h3_chunk.fx0_0 : PTrie Unit := (Host.Ts.Sim.Full.freedOf PRE_setup_h3_chunk.s2.ffi).getD PTrie.nil
noncomputable def PRE_setup_h3_chunk.kr0_0 : Host.Load.Layers.KRec := (Host.Ts.Sim.Full.krecOf PRE_setup_h3_chunk.s2.ffi).getD Host.Load.Layers.KRec.empty
kernel_rfl PRE_setup_h3_chunk.ofx0_0 : (Host.Ts.Sim.Full.freedOf PRE_setup_h3_chunk.s2.ffi) = some PRE_setup_h3_chunk.fx0_0
kernel_rfl PRE_setup_h3_chunk.okr0_0 : (Host.Ts.Sim.Full.krecOf PRE_setup_h3_chunk.s2.ffi) = some PRE_setup_h3_chunk.kr0_0
noncomputable def PRE_setup_h3_chunk.fx1_0 : PTrie Unit := (Host.Ts.Sim.Full.freedOf PRE_setup_h3_chunk.s1.ffi).getD PTrie.nil
noncomputable def PRE_setup_h3_chunk.kr1_0 : Host.Load.Layers.KRec := (Host.Ts.Sim.Full.krecOf PRE_setup_h3_chunk.s1.ffi).getD Host.Load.Layers.KRec.empty
kernel_rfl PRE_setup_h3_chunk.ofx1_0 : (Host.Ts.Sim.Full.freedOf PRE_setup_h3_chunk.s1.ffi) = some PRE_setup_h3_chunk.fx1_0
kernel_rfl PRE_setup_h3_chunk.okr1_0 : (Host.Ts.Sim.Full.krecOf PRE_setup_h3_chunk.s1.ffi) = some PRE_setup_h3_chunk.kr1_0
kernel_rfl PRE_setup_h3_chunk.ff00 : PRE_setup_h3_chunk.fx0_0 = Stage.setAll PRE_setup_h3_chunk.fxC_0 (PRE_setup_h3_chunk.clo0.filterMap fun i => (PRE_setup_h3_chunk.fx0_0.get i).map (i, ·))
kernel_rfl PRE_setup_h3_chunk.ff10 : PRE_setup_h3_chunk.fx1_0 = Stage.setAll PRE_setup_h3_chunk.fxC_0 (PRE_setup_h3_chunk.cwS0.filterMap fun i => (PRE_setup_h3_chunk.fx1_0.get i).map (i, ·))
kernel_rfl PRE_setup_h3_chunk.ffck0 : freedLB PRE_setup_h3_chunk.kappa0 PRE_setup_h3_chunk.cx0_0.mlx PRE_setup_h3_chunk.fx0_0 PRE_setup_h3_chunk.fx1_0 PRE_setup_h3_chunk.clo0 = true
kernel_rfl PRE_setup_h3_chunk.fkf00 : PRE_setup_h3_chunk.kr0_0.flags = Stage.setAll PRE_setup_h3_chunk.krC_0.flags (PRE_setup_h3_chunk.clo0.filterMap fun i => (PRE_setup_h3_chunk.kr0_0.flags.get i).map (i, ·))
kernel_rfl PRE_setup_h3_chunk.fkt00 : PRE_setup_h3_chunk.kr0_0.targs = Stage.setAll PRE_setup_h3_chunk.krC_0.targs (PRE_setup_h3_chunk.clo0.filterMap fun i => (PRE_setup_h3_chunk.kr0_0.targs.get i).map (i, ·))
kernel_rfl PRE_setup_h3_chunk.fkf10 : PRE_setup_h3_chunk.kr1_0.flags = Stage.setAll PRE_setup_h3_chunk.krC_0.flags (PRE_setup_h3_chunk.cwS0.filterMap fun i => (PRE_setup_h3_chunk.kr1_0.flags.get i).map (i, ·))
kernel_rfl PRE_setup_h3_chunk.fkt10 : PRE_setup_h3_chunk.kr1_0.targs = Stage.setAll PRE_setup_h3_chunk.krC_0.targs (PRE_setup_h3_chunk.cwS0.filterMap fun i => (PRE_setup_h3_chunk.kr1_0.targs.get i).map (i, ·))
kernel_rfl PRE_setup_h3_chunk.fkck0 : krecLB PRE_setup_h3_chunk.kappa0 10 PRE_setup_h3_chunk.cx0_0.mlx PRE_setup_h3_chunk.kr0_0 PRE_setup_h3_chunk.kr1_0 PRE_setup_h3_chunk.clo0 = true
kernel_rfl PRE_setup_h3_chunk.fkn0 : Nat.ble 10 10 = true
-- the bridge and the pending traces' regions
kernel_rfl PRE_setup_h3_chunk.cbridge0 : Host.Ts.Sim.Full.bridgeOf PRE_setup_h3_chunk.s1.ffi = Host.Ts.Sim.Full.bridgeOf PRE_setup_h3_chunk.s2.ffi
kernel_rfl PRE_setup_h3_chunk.cpendR0 : pendRegB PRE_setup_h3_chunk.kappa0 (Host.Load.Layers.toLoad PRE_setup_h3_chunk.s2.ffi).mlx = true
kernel_rfl PRE_setup_h3_chunk.cpendLe0 : Nat.ble (Host.Load.Layers.toLoad PRE_setup_h3_chunk.s2.ffi).mlx.next (Host.Load.Layers.toLoad PRE_setup_h3_chunk.s1.ffi).mlx.next = true
/-- **The compaction's native shift**, given the call's bookkeeping, its relation's facts (the model's and the
observers') and the canonical closedness. -/
theorem PRE_setup_h3_chunk.cshift0 (clean : Conv.NClean (⟨18155, 15235, 2673336, 10⟩ : Conv.Cnt) (Host.Load.Layers.toLoad PRE_setup_h3_chunk.s0.ffi).mlx) (hltC : ∀ h, PH (Host.Load.Layers.toLoad PRE_setup_h3_chunk.s0.ffi).mlx h → h < (Host.Load.Layers.toLoad PRE_setup_h3_chunk.s0.ffi).mlx.next) (nltC : ∀ i, PN (Host.Load.Layers.toLoad PRE_setup_h3_chunk.s0.ffi).mlx i → i < (Host.Load.Layers.toLoad PRE_setup_h3_chunk.s0.ffi).mlx.nnext) (itemsC : ∀ k v, (Host.Load.Layers.toLoad PRE_setup_h3_chunk.s0.ffi).mlx.items.get k = some v → PN (Host.Load.Layers.toLoad PRE_setup_h3_chunk.s0.ffi).mlx k) (tracedC : ∀ h o, (Host.Load.Layers.toLoad PRE_setup_h3_chunk.s0.ffi).mlx.objs.get h = some o → ∀ i ∈ objTraces o, i < PRE_setup_h3_chunk.P0.NL) (cl : SSt (· < 10) PRE_setup_h3_chunk.cx0_0.mlx)
    (hobjC : ∀ h, PRE_setup_h3_chunk.fxC_0.get h = some () → ((Host.Load.Layers.toLoad PRE_setup_h3_chunk.s0.ffi).mlx.objs.get h).isSome = true)
    (hfC : ∀ h, (PRE_setup_h3_chunk.krC_0.flags.get h).isSome = true → ((Host.Load.Layers.toLoad PRE_setup_h3_chunk.s0.ffi).mlx.objs.get h).isSome = true)
    (htC : ∀ h, (PRE_setup_h3_chunk.krC_0.targs.get h).isSome = true → ((Host.Load.Layers.toLoad PRE_setup_h3_chunk.s0.ffi).mlx.objs.get h).isSome = true)
    (hclC : ∀ h l, PRE_setup_h3_chunk.krC_0.targs.get h = some l → Host.Ts.Sim.Full.STargs (· < (⟨18155, 15235, 2673336, 10⟩ : Conv.Cnt).n) l) :
    Conv.FullShiftQ PRE_setup_h3_chunk.P0 10 PRE_setup_h3_chunk.kappa0 PRE_setup_h3_chunk.s2.ffi PRE_setup_h3_chunk.s1.ffi :=
  ⟨PRE_setup_h3_chunk.cnshift0 clean hltC nltC itemsC tracedC cl, PRE_setup_h3_chunk.cqueue0, fun t ht => bSN_sound (List.all_eq_true.mp PRE_setup_h3_chunk.ctokSupp0 t ht),
    PRE_setup_h3_chunk.cbridge0,
    liveShift_foot (x0' := Host.Ts.Sim.Full.mlxOf PRE_setup_h3_chunk.s2.ffi) (x1' := Host.Ts.Sim.Full.mlxOf PRE_setup_h3_chunk.s1.ffi) (PRE_setup_h3_chunk.cfoot0 clean hltC nltC itemsC tracedC cl) rfl PRE_setup_h3_chunk.ofx0_0 PRE_setup_h3_chunk.ofx1_0 hobjC PRE_setup_h3_chunk.ff00 PRE_setup_h3_chunk.ff10 PRE_setup_h3_chunk.ffck0,
    kernShift_foot (x0' := Host.Ts.Sim.Full.mlxOf PRE_setup_h3_chunk.s2.ffi) (x1' := Host.Ts.Sim.Full.mlxOf PRE_setup_h3_chunk.s1.ffi) (PRE_setup_h3_chunk.cfoot0 clean hltC nltC itemsC tracedC cl) rfl PRE_setup_h3_chunk.okr0_0 PRE_setup_h3_chunk.okr1_0 (Nat.le_of_ble_eq_true PRE_setup_h3_chunk.fkn0) hfC htC hclC
      PRE_setup_h3_chunk.fkf00 PRE_setup_h3_chunk.fkt00 PRE_setup_h3_chunk.fkf10 PRE_setup_h3_chunk.fkt10 PRE_setup_h3_chunk.fkck0,
    pendReg_of rfl PRE_setup_h3_chunk.cnh00 PRE_setup_h3_chunk.cnh10 (Nat.le_of_ble_eq_true PRE_setup_h3_chunk.cpendLe0) PRE_setup_h3_chunk.cpendR0⟩

end Host.Load.Run.Tpl
