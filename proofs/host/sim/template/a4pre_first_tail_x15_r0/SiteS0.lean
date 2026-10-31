import host.sim.template.a4pre_first_tail_x15_r0.SiteCl0
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
def PRE_first_tail_x15_r0.Pc0 : LoadP := ⟨18151, 131072, 1099511627776, 15235, 15235, []⟩
/-- The site's band raised to the call's node counter (`Conv.full_compactQD`; `κ` fixes the call's nodes). -/
def PRE_first_tail_x15_r0.P0 : LoadP := PRE_first_tail_x15_r0.Pc0.raise 15235
kernel_rfl PRE_first_tail_x15_r0.craise0 : Nat.ble PRE_first_tail_x15_r0.Pc0.N0 15235 = true
theorem PRE_first_tail_x15_r0.raised0 : Host.Ts.Sim.Full.Raised PRE_first_tail_x15_r0.Pc0 PRE_first_tail_x15_r0.P0 :=
  .inr ⟨15235, rfl, Nat.le_of_ble_eq_true PRE_first_tail_x15_r0.craise0, rfl⟩
noncomputable abbrev PRE_first_tail_x15_r0.cx0_0 : Host.Load.LSt := clearTokens (Host.Load.Layers.toLoad PRE_first_tail_x15_r0.s6.ffi)
noncomputable abbrev PRE_first_tail_x15_r0.cx1_0 : Host.Load.LSt := clearTokens (Host.Load.Layers.toLoad PRE_first_tail_x15_r0.s5.ffi)
def PRE_first_tail_x15_r0.khinv0 : PTrie Nat := Stage.setAll PTrie.nil []
def PRE_first_tail_x15_r0.kninv0 : PTrie Nat := Stage.setAll PTrie.nil []
/-- The stage's footprint: its written and fresh handles, fresh nodes, written and fresh items. -/
def PRE_first_tail_x15_r0.cwS0 : List Nat := []
def PRE_first_tail_x15_r0.cnS0 : List Nat := List.range' 15235 0
def PRE_first_tail_x15_r0.ciS0 : List Nat := [] ++ List.range' 15235 0

-- the small checks (`MChecks`'s)
kernel_rfl PRE_first_tail_x15_r0.cnh00 : PRE_first_tail_x15_r0.kd0.nh0 = PRE_first_tail_x15_r0.cx0_0.mlx.next
kernel_rfl PRE_first_tail_x15_r0.cnh10 : PRE_first_tail_x15_r0.kd0.nh1 = PRE_first_tail_x15_r0.cx1_0.mlx.next
kernel_rfl PRE_first_tail_x15_r0.cnn00 : PRE_first_tail_x15_r0.kd0.nn0 = PRE_first_tail_x15_r0.cx0_0.mlx.nnext
kernel_rfl PRE_first_tail_x15_r0.cnn10 : PRE_first_tail_x15_r0.kd0.nn1 = PRE_first_tail_x15_r0.cx1_0.mlx.nnext
kernel_rfl PRE_first_tail_x15_r0.cplo0 : (Nat.blt 0 PRE_first_tail_x15_r0.P0.lo && Nat.ble PRE_first_tail_x15_r0.P0.lo PRE_first_tail_x15_r0.cx0_0.mlx.next && Nat.ble PRE_first_tail_x15_r0.P0.lo RData.bigHi && Nat.ble RData.bigHi PRE_first_tail_x15_r0.P0.E) = true
kernel_rfl PRE_first_tail_x15_r0.ccnt0 : (Nat.ble PRE_first_tail_x15_r0.cx0_0.mlx.next PRE_first_tail_x15_r0.cx1_0.mlx.next && Nat.ble PRE_first_tail_x15_r0.cx0_0.mlx.nnext PRE_first_tail_x15_r0.cx1_0.mlx.nnext) = true
kernel_rfl PRE_first_tail_x15_r0.cnband0 : (Nat.blt 0 PRE_first_tail_x15_r0.P0.NL && Nat.ble PRE_first_tail_x15_r0.P0.NL PRE_first_tail_x15_r0.P0.N0 && Nat.ble PRE_first_tail_x15_r0.P0.N0 PRE_first_tail_x15_r0.cx0_0.mlx.nnext) = true
kernel_rfl PRE_first_tail_x15_r0.chbelow0 : PRE_first_tail_x15_r0.kd0.checkHndBelow = true
kernel_rfl PRE_first_tail_x15_r0.chren0 : checkRenG PRE_first_tail_x15_r0.kd0.hnd PRE_first_tail_x15_r0.khinv0 (phB PRE_first_tail_x15_r0.cx0_0.mlx) = true
kernel_rfl PRE_first_tail_x15_r0.cband0 : PRE_first_tail_x15_r0.kd0.checkBand PRE_first_tail_x15_r0.P0.lo = true
kernel_rfl PRE_first_tail_x15_r0.cnh1pos0 : Nat.blt 0 PRE_first_tail_x15_r0.kd0.nh1 = true
kernel_rfl PRE_first_tail_x15_r0.cnren0 : checkRenG PRE_first_tail_x15_r0.kd0.node PRE_first_tail_x15_r0.kninv0 (pnB PRE_first_tail_x15_r0.cx0_0.mlx) = true
kernel_rfl PRE_first_tail_x15_r0.cnlow0 : (PTrie.keysA PRE_first_tail_x15_r0.kd0.node).all (fun j => Nat.ble PRE_first_tail_x15_r0.P0.NL j && Nat.blt (PRE_first_tail_x15_r0.kd0.nodeF j) PRE_first_tail_x15_r0.cx1_0.mlx.nnext) = true
kernel_rfl PRE_first_tail_x15_r0.cabs0a0 : PRE_first_tail_x15_r0.cx0_0.mlx.arrs.get 0 = none
kernel_rfl PRE_first_tail_x15_r0.cabs0b0 : PRE_first_tail_x15_r0.cx0_0.mlx.objs.get 0 = none
kernel_rfl PRE_first_tail_x15_r0.ctok10 : PRE_first_tail_x15_r0.cx1_0.mlx.tokens = []
kernel_rfl PRE_first_tail_x15_r0.cpend0 : PRE_first_tail_x15_r0.cx1_0.mlx.pending = PRE_first_tail_x15_r0.cx0_0.mlx.pending.map PRE_first_tail_x15_r0.kappa0.pend
kernel_rfl PRE_first_tail_x15_r0.cerrh0 : PRE_first_tail_x15_r0.cx1_0.mlx.errh = PRE_first_tail_x15_r0.cx0_0.mlx.errh.map PRE_first_tail_x15_r0.kappa0.arg
kernel_rfl PRE_first_tail_x15_r0.cfiles0 : PRE_first_tail_x15_r0.cx1_0.mlx.files = PRE_first_tail_x15_r0.cx0_0.mlx.files
kernel_rfl PRE_first_tail_x15_r0.carch0 : PRE_first_tail_x15_r0.cx1_0.mlx.arch = PRE_first_tail_x15_r0.cx0_0.mlx.arch
kernel_rfl PRE_first_tail_x15_r0.csizes0 : PRE_first_tail_x15_r0.cx1_0.mlx.deviceSizes = PRE_first_tail_x15_r0.cx0_0.mlx.deviceSizes
kernel_rfl PRE_first_tail_x15_r0.cwired0 : PRE_first_tail_x15_r0.cx1_0.mlx.wired = PRE_first_tail_x15_r0.cx0_0.mlx.wired
kernel_rfl PRE_first_tail_x15_r0.chost0 : PRE_first_tail_x15_r0.cx1_0.host = PRE_first_tail_x15_r0.cx0_0.host
-- the compaction map's addresses are `PRE_first_tail_x15_r0.kd0`'s
kernel_rfl PRE_first_tail_x15_r0.ckn00 : PRE_first_tail_x15_r0.kd0.n0 = 2673336
kernel_rfl PRE_first_tail_x15_r0.ckn10 : PRE_first_tail_x15_r0.kd0.n1 = 2673927
kernel_rfl PRE_first_tail_x15_r0.ckheap0 : (PTrie.keysA PRE_first_tail_x15_r0.kd0.heap).all (fun x => Nat.ble 2673336 x) = true
kernel_rfl PRE_first_tail_x15_r0.ckpl0 : (List.range 0).all (fun j => decide (PRE_first_tail_x15_r0.kd0.heap.get (2673336 + j) = nth? PRE_first_tail_x15_r0.pl0 j)) = true
-- the map fixes the call's names (`Conv.fixOld_compact`), the call's counters
kernel_rfl PRE_first_tail_x15_r0.fja0 : Nat.ble 2673336 2673336 = true
kernel_rfl PRE_first_tail_x15_r0.fn0 : Nat.ble 10 10 = true
kernel_rfl PRE_first_tail_x15_r0.fjaD0 : Nat.ble 2673336 PRE_first_tail_x15_r0.kd0.n0 = true
kernel_rfl PRE_first_tail_x15_r0.fxn0 : Nat.ble 18155 PRE_first_tail_x15_r0.kd0.nh0 = true
kernel_rfl PRE_first_tail_x15_r0.fnn0 : Nat.ble 15235 PRE_first_tail_x15_r0.kd0.nn0 = true
kernel_rfl PRE_first_tail_x15_r0.fxb0 : Nat.ble 18155 RData.bigHi = true
kernel_rfl PRE_first_tail_x15_r0.fheap0 : (PTrie.keysA PRE_first_tail_x15_r0.kd0.heap).all (Nat.ble (⟨18155, 15235, 2673336, 10⟩ : Conv.Cnt).ja) = true
kernel_rfl PRE_first_tail_x15_r0.fhnd0 : (PTrie.keysA PRE_first_tail_x15_r0.kd0.hnd).all (Nat.ble (⟨18155, 15235, 2673336, 10⟩ : Conv.Cnt).xn) = true
kernel_rfl PRE_first_tail_x15_r0.fnode0 : (PTrie.keysA PRE_first_tail_x15_r0.kd0.node).all (Nat.ble (⟨18155, 15235, 2673336, 10⟩ : Conv.Cnt).nn) = true
/-- The compaction map fixes the call's names. -/
theorem PRE_first_tail_x15_r0.cfix0 : Conv.FixOld (⟨18155, 15235, 2673336, 10⟩ : Conv.Cnt) PRE_first_tail_x15_r0.kappa0 :=
  Conv.fixOld_compact (Nat.le_of_ble_eq_true PRE_first_tail_x15_r0.fja0) (Nat.le_of_ble_eq_true PRE_first_tail_x15_r0.fn0) (Nat.le_of_ble_eq_true PRE_first_tail_x15_r0.fjaD0) (Nat.le_of_ble_eq_true PRE_first_tail_x15_r0.fxn0) (Nat.le_of_ble_eq_true PRE_first_tail_x15_r0.fnn0) (Nat.le_of_ble_eq_true PRE_first_tail_x15_r0.fxb0) PRE_first_tail_x15_r0.fheap0 PRE_first_tail_x15_r0.fhnd0 PRE_first_tail_x15_r0.fnode0
kernel_rfl PRE_first_tail_x15_r0.fcxn0 : (⟨18155, 15235, 2673336, 10⟩ : Conv.Cnt).xn = (Host.Load.Layers.toLoad PRE_first_tail_x15_r0.s4.ffi).mlx.next
kernel_rfl PRE_first_tail_x15_r0.fcnn0 : (⟨18155, 15235, 2673336, 10⟩ : Conv.Cnt).nn = (Host.Load.Layers.toLoad PRE_first_tail_x15_r0.s4.ffi).mlx.nnext
kernel_rfl PRE_first_tail_x15_r0.fle00 : (Nat.ble (Host.Load.Layers.toLoad PRE_first_tail_x15_r0.s4.ffi).mlx.next PRE_first_tail_x15_r0.cx0_0.mlx.next && Nat.ble (Host.Load.Layers.toLoad PRE_first_tail_x15_r0.s4.ffi).mlx.nnext PRE_first_tail_x15_r0.cx0_0.mlx.nnext && Nat.ble (Host.Load.Layers.toLoad PRE_first_tail_x15_r0.s4.ffi).mlx.next RData.bigHi) = true
kernel_rfl PRE_first_tail_x15_r0.fnk0 : (PTrie.keysA PRE_first_tail_x15_r0.kd0.node).all (Nat.ble (Host.Load.Layers.toLoad PRE_first_tail_x15_r0.s4.ffi).mlx.nnext) = true
-- the merged state keeps the call's entries off the stage's footprint
kernel_rfl PRE_first_tail_x15_r0.f1A0 : PRE_first_tail_x15_r0.cx1_0.mlx.arrs = Stage.setAll (Host.Load.Layers.toLoad PRE_first_tail_x15_r0.s4.ffi).mlx.arrs (PRE_first_tail_x15_r0.cwS0.filterMap fun i => (PRE_first_tail_x15_r0.cx1_0.mlx.arrs.get i).map (i, ·))
kernel_rfl PRE_first_tail_x15_r0.f1O0 : PRE_first_tail_x15_r0.cx1_0.mlx.objs = Stage.setAll (Host.Load.Layers.toLoad PRE_first_tail_x15_r0.s4.ffi).mlx.objs (PRE_first_tail_x15_r0.cwS0.filterMap fun i => (PRE_first_tail_x15_r0.cx1_0.mlx.objs.get i).map (i, ·))
kernel_rfl PRE_first_tail_x15_r0.f1N0 : PRE_first_tail_x15_r0.cx1_0.mlx.nodes = Stage.setAll (Host.Load.Layers.toLoad PRE_first_tail_x15_r0.s4.ffi).mlx.nodes (PRE_first_tail_x15_r0.cnS0.filterMap fun i => (PRE_first_tail_x15_r0.cx1_0.mlx.nodes.get i).map (i, ·))
kernel_rfl PRE_first_tail_x15_r0.f1I0 : PRE_first_tail_x15_r0.cx1_0.mlx.items = Stage.setAll (Host.Load.Layers.toLoad PRE_first_tail_x15_r0.s4.ffi).mlx.items (PRE_first_tail_x15_r0.ciS0.filterMap fun i => (PRE_first_tail_x15_r0.cx1_0.mlx.items.get i).map (i, ·))
kernel_rfl PRE_first_tail_x15_r0.fbd0 : (PRE_first_tail_x15_r0.clo0 ++ PRE_first_tail_x15_r0.cln0 ++ PRE_first_tail_x15_r0.cli0 ++ PRE_first_tail_x15_r0.cwS0 ++ PRE_first_tail_x15_r0.cnS0 ++ PRE_first_tail_x15_r0.ciS0).all (fun i => Nat.blt (i / 4096) (4 ^ 31)) = true
kernel_rfl PRE_first_tail_x15_r0.fincW0 : PRE_first_tail_x15_r0.cwS0.all (fun h => !Nat.blt h (Host.Load.Layers.toLoad PRE_first_tail_x15_r0.s4.ffi).mlx.next || PRE_first_tail_x15_r0.clo0.contains h) = true
kernel_rfl PRE_first_tail_x15_r0.fincI0 : PRE_first_tail_x15_r0.ciS0.all (fun k => !Nat.blt k (Host.Load.Layers.toLoad PRE_first_tail_x15_r0.s4.ffi).mlx.nnext || PRE_first_tail_x15_r0.cli0.contains k) = true
kernel_rfl PRE_first_tail_x15_r0.fincN0 : PRE_first_tail_x15_r0.cnS0.all (Nat.ble (Host.Load.Layers.toLoad PRE_first_tail_x15_r0.s4.ffi).mlx.nnext) = true
kernel_rfl PRE_first_tail_x15_r0.flnF0 : PRE_first_tail_x15_r0.cln0.all (Nat.ble (Host.Load.Layers.toLoad PRE_first_tail_x15_r0.s4.ffi).mlx.nnext) = true
-- the checks over the changed lists
kernel_rfl PRE_first_tail_x15_r0.fh0 : PRE_first_tail_x15_r0.clo0.all (handleOK PRE_first_tail_x15_r0.kappa0 PRE_first_tail_x15_r0.P0.lo PRE_first_tail_x15_r0.cx0_0.mlx PRE_first_tail_x15_r0.cx1_0.mlx) = true
kernel_rfl PRE_first_tail_x15_r0.fo0 : PRE_first_tail_x15_r0.clo0.map (fun h => PRE_first_tail_x15_r0.cx1_0.mlx.objs.get (PRE_first_tail_x15_r0.kappa0.handle h)) = PRE_first_tail_x15_r0.clo0.map (fun h => (PRE_first_tail_x15_r0.cx0_0.mlx.objs.get h).map PRE_first_tail_x15_r0.kappa0.nobj)
kernel_rfl PRE_first_tail_x15_r0.fok0 : PRE_first_tail_x15_r0.clo0.all (objOK PRE_first_tail_x15_r0.kappa0 PRE_first_tail_x15_r0.P0.NL PRE_first_tail_x15_r0.cx0_0.mlx) = true
kernel_rfl PRE_first_tail_x15_r0.fnd0 : PRE_first_tail_x15_r0.cln0.all (nodeOKF PRE_first_tail_x15_r0.kappa0 PRE_first_tail_x15_r0.P0 PRE_first_tail_x15_r0.cx0_0.mlx PRE_first_tail_x15_r0.cx1_0.mlx) = true
kernel_rfl PRE_first_tail_x15_r0.fp0 : ((PRE_first_tail_x15_r0.cln0.filter (fullB PRE_first_tail_x15_r0.P0))).map (fun i => (PRE_first_tail_x15_r0.cx1_0.mlx.nodes.get (PRE_first_tail_x15_r0.kappa0.node i)).map Host.Mlx.Ffi.Node.prim) =
  ((PRE_first_tail_x15_r0.cln0.filter (fullB PRE_first_tail_x15_r0.P0))).map (fun i => (PRE_first_tail_x15_r0.cx0_0.mlx.nodes.get i).map fun nd => PRE_first_tail_x15_r0.kappa0.prim nd.prim)
kernel_rfl PRE_first_tail_x15_r0.fnordI0 : incrB PRE_first_tail_x15_r0.kd0.nodeF (List.range' 15235 0) = true
kernel_rfl PRE_first_tail_x15_r0.fnordK0 : (PTrie.keysA PRE_first_tail_x15_r0.kd0.node).all (fun k => Nat.ble 15235 k && Nat.blt k 15235) = true
kernel_rfl PRE_first_tail_x15_r0.fnordL0 : (PRE_first_tail_x15_r0.cln0.filter (Nat.ble PRE_first_tail_x15_r0.P0.N0)).all (fun i => Nat.ble i (PRE_first_tail_x15_r0.kd0.nodeF i) && (Nat.blt i 15235 || Nat.ble PRE_first_tail_x15_r0.kd0.nn0 i)) = true
theorem PRE_first_tail_x15_r0.fnord0 : (PRE_first_tail_x15_r0.cln0.filter (Nat.ble PRE_first_tail_x15_r0.P0.N0)).all (fun i => Nat.ble i (PRE_first_tail_x15_r0.kd0.nodeF i) &&
    (PTrie.keysA PRE_first_tail_x15_r0.kd0.node).all fun j => !Nat.blt j i || Nat.blt (PRE_first_tail_x15_r0.kd0.nodeF j) (PRE_first_tail_x15_r0.kd0.nodeF i)) = true :=
  cnord_of PRE_first_tail_x15_r0.cnlow0 PRE_first_tail_x15_r0.cnn10 PRE_first_tail_x15_r0.fnordI0 PRE_first_tail_x15_r0.fnordK0 PRE_first_tail_x15_r0.fnordL0
kernel_rfl PRE_first_tail_x15_r0.fi0 : PRE_first_tail_x15_r0.cli0.all (pnB PRE_first_tail_x15_r0.cx0_0.mlx) = true
kernel_rfl PRE_first_tail_x15_r0.fii0 : PRE_first_tail_x15_r0.cli0.all (fun k => decide (PRE_first_tail_x15_r0.cx1_0.mlx.items.get (PRE_first_tail_x15_r0.kappa0.node k) = (PRE_first_tail_x15_r0.cx0_0.mlx.items.get k).map PRE_first_tail_x15_r0.kappa0.nv)) = true
/-- **The compaction's footprint.** -/
theorem PRE_first_tail_x15_r0.cfoot0 (clean : Conv.NClean (⟨18155, 15235, 2673336, 10⟩ : Conv.Cnt) (Host.Load.Layers.toLoad PRE_first_tail_x15_r0.s4.ffi).mlx) (hltC : ∀ h, PH (Host.Load.Layers.toLoad PRE_first_tail_x15_r0.s4.ffi).mlx h → h < (Host.Load.Layers.toLoad PRE_first_tail_x15_r0.s4.ffi).mlx.next) (nltC : ∀ i, PN (Host.Load.Layers.toLoad PRE_first_tail_x15_r0.s4.ffi).mlx i → i < (Host.Load.Layers.toLoad PRE_first_tail_x15_r0.s4.ffi).mlx.nnext) (itemsC : ∀ k v, (Host.Load.Layers.toLoad PRE_first_tail_x15_r0.s4.ffi).mlx.items.get k = some v → PN (Host.Load.Layers.toLoad PRE_first_tail_x15_r0.s4.ffi).mlx k) (tracedC : ∀ h o, (Host.Load.Layers.toLoad PRE_first_tail_x15_r0.s4.ffi).mlx.objs.get h = some o → ∀ i ∈ objTraces o, i < PRE_first_tail_x15_r0.P0.NL) (cl : SSt (· < 10) PRE_first_tail_x15_r0.cx0_0.mlx) :
    Conv.MFoot PRE_first_tail_x15_r0.P0 10 PRE_first_tail_x15_r0.kappa0 PRE_first_tail_x15_r0.kd0 PRE_first_tail_x15_r0.khinv0 PRE_first_tail_x15_r0.kninv0 (Host.Load.Layers.toLoad PRE_first_tail_x15_r0.s4.ffi).mlx PRE_first_tail_x15_r0.cx0_0.mlx PRE_first_tail_x15_r0.cx1_0.mlx (⟨18155, 15235, 2673336, 10⟩ : Conv.Cnt) PRE_first_tail_x15_r0.clo0 PRE_first_tail_x15_r0.cln0 PRE_first_tail_x15_r0.cli0 PRE_first_tail_x15_r0.cwS0 PRE_first_tail_x15_r0.cnS0 PRE_first_tail_x15_r0.ciS0 :=
  ⟨rfl, rfl, rfl, PRE_first_tail_x15_r0.cnh00, PRE_first_tail_x15_r0.cnh10, PRE_first_tail_x15_r0.cnn00, PRE_first_tail_x15_r0.cnn10, PRE_first_tail_x15_r0.cplo0, PRE_first_tail_x15_r0.ccnt0, PRE_first_tail_x15_r0.cnband0, PRE_first_tail_x15_r0.chbelow0, PRE_first_tail_x15_r0.chren0, PRE_first_tail_x15_r0.cband0, PRE_first_tail_x15_r0.cnh1pos0, PRE_first_tail_x15_r0.cnren0, PRE_first_tail_x15_r0.cnlow0, PRE_first_tail_x15_r0.cabs0a0, PRE_first_tail_x15_r0.cabs0b0, PRE_first_tail_x15_r0.ctok10, PRE_first_tail_x15_r0.cpend0, PRE_first_tail_x15_r0.cerrh0, PRE_first_tail_x15_r0.cfiles0, PRE_first_tail_x15_r0.carch0, PRE_first_tail_x15_r0.csizes0, PRE_first_tail_x15_r0.cwired0, PRE_first_tail_x15_r0.cfix0, clean, PRE_first_tail_x15_r0.fcxn0, PRE_first_tail_x15_r0.fcnn0, hltC, nltC, itemsC, tracedC, cl, PRE_first_tail_x15_r0.fle00, PRE_first_tail_x15_r0.fnk0, PRE_first_tail_x15_r0.ckA0, PRE_first_tail_x15_r0.cobjsK0, PRE_first_tail_x15_r0.cnodesK0, PRE_first_tail_x15_r0.citemsK0, PRE_first_tail_x15_r0.f1A0, PRE_first_tail_x15_r0.f1O0, PRE_first_tail_x15_r0.f1N0, PRE_first_tail_x15_r0.f1I0, PRE_first_tail_x15_r0.fbd0, PRE_first_tail_x15_r0.fincW0, PRE_first_tail_x15_r0.fincI0, PRE_first_tail_x15_r0.fincN0, PRE_first_tail_x15_r0.flnF0, PRE_first_tail_x15_r0.fh0, PRE_first_tail_x15_r0.fo0, PRE_first_tail_x15_r0.fok0, PRE_first_tail_x15_r0.fnd0, PRE_first_tail_x15_r0.fp0, PRE_first_tail_x15_r0.fnord0, PRE_first_tail_x15_r0.fi0, PRE_first_tail_x15_r0.fii0⟩
theorem PRE_first_tail_x15_r0.cnshift0 (clean : Conv.NClean (⟨18155, 15235, 2673336, 10⟩ : Conv.Cnt) (Host.Load.Layers.toLoad PRE_first_tail_x15_r0.s4.ffi).mlx) (hltC : ∀ h, PH (Host.Load.Layers.toLoad PRE_first_tail_x15_r0.s4.ffi).mlx h → h < (Host.Load.Layers.toLoad PRE_first_tail_x15_r0.s4.ffi).mlx.next) (nltC : ∀ i, PN (Host.Load.Layers.toLoad PRE_first_tail_x15_r0.s4.ffi).mlx i → i < (Host.Load.Layers.toLoad PRE_first_tail_x15_r0.s4.ffi).mlx.nnext) (itemsC : ∀ k v, (Host.Load.Layers.toLoad PRE_first_tail_x15_r0.s4.ffi).mlx.items.get k = some v → PN (Host.Load.Layers.toLoad PRE_first_tail_x15_r0.s4.ffi).mlx k) (tracedC : ∀ h o, (Host.Load.Layers.toLoad PRE_first_tail_x15_r0.s4.ffi).mlx.objs.get h = some o → ∀ i ∈ objTraces o, i < PRE_first_tail_x15_r0.P0.NL) (cl : SSt (· < 10) PRE_first_tail_x15_r0.cx0_0.mlx) : NShift PRE_first_tail_x15_r0.P0 10 PRE_first_tail_x15_r0.kappa0 PRE_first_tail_x15_r0.cx0_0 PRE_first_tail_x15_r0.cx1_0 :=
  Conv.nshift_of_foot (PRE_first_tail_x15_r0.cfoot0 clean hltC nltC itemsC tracedC cl) PRE_first_tail_x15_r0.chost0 (compact_a_eq PRE_first_tail_x15_r0.ckn00 PRE_first_tail_x15_r0.ckn10 PRE_first_tail_x15_r0.ckheap0 PRE_first_tail_x15_r0.ckpl0)

-- the observers: the layers' states at the call, the canonical and the merged state, their footprints and checks
noncomputable def PRE_first_tail_x15_r0.fxC_0 : PTrie Unit := (Host.Ts.Sim.Full.freedOf PRE_first_tail_x15_r0.s4.ffi).getD PTrie.nil
noncomputable def PRE_first_tail_x15_r0.krC_0 : Host.Load.Layers.KRec := (Host.Ts.Sim.Full.krecOf PRE_first_tail_x15_r0.s4.ffi).getD Host.Load.Layers.KRec.empty
kernel_rfl PRE_first_tail_x15_r0.ofxC_0 : (Host.Ts.Sim.Full.freedOf PRE_first_tail_x15_r0.s4.ffi) = some PRE_first_tail_x15_r0.fxC_0
kernel_rfl PRE_first_tail_x15_r0.okrC_0 : (Host.Ts.Sim.Full.krecOf PRE_first_tail_x15_r0.s4.ffi) = some PRE_first_tail_x15_r0.krC_0
noncomputable def PRE_first_tail_x15_r0.fx0_0 : PTrie Unit := (Host.Ts.Sim.Full.freedOf PRE_first_tail_x15_r0.s6.ffi).getD PTrie.nil
noncomputable def PRE_first_tail_x15_r0.kr0_0 : Host.Load.Layers.KRec := (Host.Ts.Sim.Full.krecOf PRE_first_tail_x15_r0.s6.ffi).getD Host.Load.Layers.KRec.empty
kernel_rfl PRE_first_tail_x15_r0.ofx0_0 : (Host.Ts.Sim.Full.freedOf PRE_first_tail_x15_r0.s6.ffi) = some PRE_first_tail_x15_r0.fx0_0
kernel_rfl PRE_first_tail_x15_r0.okr0_0 : (Host.Ts.Sim.Full.krecOf PRE_first_tail_x15_r0.s6.ffi) = some PRE_first_tail_x15_r0.kr0_0
noncomputable def PRE_first_tail_x15_r0.fx1_0 : PTrie Unit := (Host.Ts.Sim.Full.freedOf PRE_first_tail_x15_r0.s5.ffi).getD PTrie.nil
noncomputable def PRE_first_tail_x15_r0.kr1_0 : Host.Load.Layers.KRec := (Host.Ts.Sim.Full.krecOf PRE_first_tail_x15_r0.s5.ffi).getD Host.Load.Layers.KRec.empty
kernel_rfl PRE_first_tail_x15_r0.ofx1_0 : (Host.Ts.Sim.Full.freedOf PRE_first_tail_x15_r0.s5.ffi) = some PRE_first_tail_x15_r0.fx1_0
kernel_rfl PRE_first_tail_x15_r0.okr1_0 : (Host.Ts.Sim.Full.krecOf PRE_first_tail_x15_r0.s5.ffi) = some PRE_first_tail_x15_r0.kr1_0
kernel_rfl PRE_first_tail_x15_r0.ff00 : PRE_first_tail_x15_r0.fx0_0 = Stage.setAll PRE_first_tail_x15_r0.fxC_0 (PRE_first_tail_x15_r0.clo0.filterMap fun i => (PRE_first_tail_x15_r0.fx0_0.get i).map (i, ·))
kernel_rfl PRE_first_tail_x15_r0.ff10 : PRE_first_tail_x15_r0.fx1_0 = Stage.setAll PRE_first_tail_x15_r0.fxC_0 (PRE_first_tail_x15_r0.cwS0.filterMap fun i => (PRE_first_tail_x15_r0.fx1_0.get i).map (i, ·))
kernel_rfl PRE_first_tail_x15_r0.ffck0 : freedLB PRE_first_tail_x15_r0.kappa0 PRE_first_tail_x15_r0.cx0_0.mlx PRE_first_tail_x15_r0.fx0_0 PRE_first_tail_x15_r0.fx1_0 PRE_first_tail_x15_r0.clo0 = true
kernel_rfl PRE_first_tail_x15_r0.fkf00 : PRE_first_tail_x15_r0.kr0_0.flags = Stage.setAll PRE_first_tail_x15_r0.krC_0.flags (PRE_first_tail_x15_r0.clo0.filterMap fun i => (PRE_first_tail_x15_r0.kr0_0.flags.get i).map (i, ·))
kernel_rfl PRE_first_tail_x15_r0.fkt00 : PRE_first_tail_x15_r0.kr0_0.targs = Stage.setAll PRE_first_tail_x15_r0.krC_0.targs (PRE_first_tail_x15_r0.clo0.filterMap fun i => (PRE_first_tail_x15_r0.kr0_0.targs.get i).map (i, ·))
kernel_rfl PRE_first_tail_x15_r0.fkf10 : PRE_first_tail_x15_r0.kr1_0.flags = Stage.setAll PRE_first_tail_x15_r0.krC_0.flags (PRE_first_tail_x15_r0.cwS0.filterMap fun i => (PRE_first_tail_x15_r0.kr1_0.flags.get i).map (i, ·))
kernel_rfl PRE_first_tail_x15_r0.fkt10 : PRE_first_tail_x15_r0.kr1_0.targs = Stage.setAll PRE_first_tail_x15_r0.krC_0.targs (PRE_first_tail_x15_r0.cwS0.filterMap fun i => (PRE_first_tail_x15_r0.kr1_0.targs.get i).map (i, ·))
kernel_rfl PRE_first_tail_x15_r0.fkck0 : krecLB PRE_first_tail_x15_r0.kappa0 10 PRE_first_tail_x15_r0.cx0_0.mlx PRE_first_tail_x15_r0.kr0_0 PRE_first_tail_x15_r0.kr1_0 PRE_first_tail_x15_r0.clo0 = true
kernel_rfl PRE_first_tail_x15_r0.fkn0 : Nat.ble 10 10 = true
-- the bridge and the pending traces' regions
kernel_rfl PRE_first_tail_x15_r0.cbridge0 : Host.Ts.Sim.Full.bridgeOf PRE_first_tail_x15_r0.s5.ffi = Host.Ts.Sim.Full.bridgeOf PRE_first_tail_x15_r0.s6.ffi
kernel_rfl PRE_first_tail_x15_r0.cpendR0 : pendRegB PRE_first_tail_x15_r0.kappa0 (Host.Load.Layers.toLoad PRE_first_tail_x15_r0.s6.ffi).mlx = true
kernel_rfl PRE_first_tail_x15_r0.cpendLe0 : Nat.ble (Host.Load.Layers.toLoad PRE_first_tail_x15_r0.s6.ffi).mlx.next (Host.Load.Layers.toLoad PRE_first_tail_x15_r0.s5.ffi).mlx.next = true
/-- **The compaction's native shift**, given the call's bookkeeping, its relation's facts (the model's and the
observers') and the canonical closedness. -/
theorem PRE_first_tail_x15_r0.cshift0 (clean : Conv.NClean (⟨18155, 15235, 2673336, 10⟩ : Conv.Cnt) (Host.Load.Layers.toLoad PRE_first_tail_x15_r0.s4.ffi).mlx) (hltC : ∀ h, PH (Host.Load.Layers.toLoad PRE_first_tail_x15_r0.s4.ffi).mlx h → h < (Host.Load.Layers.toLoad PRE_first_tail_x15_r0.s4.ffi).mlx.next) (nltC : ∀ i, PN (Host.Load.Layers.toLoad PRE_first_tail_x15_r0.s4.ffi).mlx i → i < (Host.Load.Layers.toLoad PRE_first_tail_x15_r0.s4.ffi).mlx.nnext) (itemsC : ∀ k v, (Host.Load.Layers.toLoad PRE_first_tail_x15_r0.s4.ffi).mlx.items.get k = some v → PN (Host.Load.Layers.toLoad PRE_first_tail_x15_r0.s4.ffi).mlx k) (tracedC : ∀ h o, (Host.Load.Layers.toLoad PRE_first_tail_x15_r0.s4.ffi).mlx.objs.get h = some o → ∀ i ∈ objTraces o, i < PRE_first_tail_x15_r0.P0.NL) (cl : SSt (· < 10) PRE_first_tail_x15_r0.cx0_0.mlx)
    (hobjC : ∀ h, PRE_first_tail_x15_r0.fxC_0.get h = some () → ((Host.Load.Layers.toLoad PRE_first_tail_x15_r0.s4.ffi).mlx.objs.get h).isSome = true)
    (hfC : ∀ h, (PRE_first_tail_x15_r0.krC_0.flags.get h).isSome = true → ((Host.Load.Layers.toLoad PRE_first_tail_x15_r0.s4.ffi).mlx.objs.get h).isSome = true)
    (htC : ∀ h, (PRE_first_tail_x15_r0.krC_0.targs.get h).isSome = true → ((Host.Load.Layers.toLoad PRE_first_tail_x15_r0.s4.ffi).mlx.objs.get h).isSome = true)
    (hclC : ∀ h l, PRE_first_tail_x15_r0.krC_0.targs.get h = some l → Host.Ts.Sim.Full.STargs (· < (⟨18155, 15235, 2673336, 10⟩ : Conv.Cnt).n) l) :
    Conv.FullShiftQ PRE_first_tail_x15_r0.P0 10 PRE_first_tail_x15_r0.kappa0 PRE_first_tail_x15_r0.s6.ffi PRE_first_tail_x15_r0.s5.ffi :=
  ⟨PRE_first_tail_x15_r0.cnshift0 clean hltC nltC itemsC tracedC cl, PRE_first_tail_x15_r0.cqueue0, fun t ht => bSN_sound (List.all_eq_true.mp PRE_first_tail_x15_r0.ctokSupp0 t ht),
    PRE_first_tail_x15_r0.cbridge0,
    liveShift_foot (x0' := Host.Ts.Sim.Full.mlxOf PRE_first_tail_x15_r0.s6.ffi) (x1' := Host.Ts.Sim.Full.mlxOf PRE_first_tail_x15_r0.s5.ffi) (PRE_first_tail_x15_r0.cfoot0 clean hltC nltC itemsC tracedC cl) rfl PRE_first_tail_x15_r0.ofx0_0 PRE_first_tail_x15_r0.ofx1_0 hobjC PRE_first_tail_x15_r0.ff00 PRE_first_tail_x15_r0.ff10 PRE_first_tail_x15_r0.ffck0,
    kernShift_foot (x0' := Host.Ts.Sim.Full.mlxOf PRE_first_tail_x15_r0.s6.ffi) (x1' := Host.Ts.Sim.Full.mlxOf PRE_first_tail_x15_r0.s5.ffi) (PRE_first_tail_x15_r0.cfoot0 clean hltC nltC itemsC tracedC cl) rfl PRE_first_tail_x15_r0.okr0_0 PRE_first_tail_x15_r0.okr1_0 (Nat.le_of_ble_eq_true PRE_first_tail_x15_r0.fkn0) hfC htC hclC
      PRE_first_tail_x15_r0.fkf00 PRE_first_tail_x15_r0.fkt00 PRE_first_tail_x15_r0.fkf10 PRE_first_tail_x15_r0.fkt10 PRE_first_tail_x15_r0.fkck0,
    pendReg_of rfl PRE_first_tail_x15_r0.cnh00 PRE_first_tail_x15_r0.cnh10 (Nat.le_of_ble_eq_true PRE_first_tail_x15_r0.cpendLe0) PRE_first_tail_x15_r0.cpendR0⟩

end Host.Load.Run.Tpl
