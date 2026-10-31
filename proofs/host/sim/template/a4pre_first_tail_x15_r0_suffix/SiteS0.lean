import host.sim.template.a4pre_first_tail_x15_r0_suffix.SiteCl0
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
def PRE_first_tail_x15_r0_suffix.Pc0 : LoadP := ⟨18151, 131072, 1099511627776, 15235, 15235, []⟩
/-- The site's band raised to the map's checked fixed-node prefix, including newly recorded closure traces. -/
def PRE_first_tail_x15_r0_suffix.P0 : LoadP := PRE_first_tail_x15_r0_suffix.Pc0.raise 19057
kernel_rfl PRE_first_tail_x15_r0_suffix.craise0 : Nat.ble PRE_first_tail_x15_r0_suffix.Pc0.N0 19057 = true
theorem PRE_first_tail_x15_r0_suffix.raised0 : Host.Ts.Sim.Full.Raised PRE_first_tail_x15_r0_suffix.Pc0 PRE_first_tail_x15_r0_suffix.P0 :=
  .inr ⟨19057, rfl, Nat.le_of_ble_eq_true PRE_first_tail_x15_r0_suffix.craise0, rfl⟩
noncomputable abbrev PRE_first_tail_x15_r0_suffix.cx0_0 : Host.Load.LSt := clearTokens (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_suffix.s4.ffi)
noncomputable abbrev PRE_first_tail_x15_r0_suffix.cx1_0 : Host.Load.LSt := clearTokens (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_suffix.s3.ffi)
def PRE_first_tail_x15_r0_suffix.khinv0 : PTrie Nat := Stage.setAll PTrie.nil []
def PRE_first_tail_x15_r0_suffix.kninv0 : PTrie Nat := Stage.setAll PTrie.nil []
/-- The stage's footprint: its written and fresh handles, fresh nodes, written and fresh items. -/
def PRE_first_tail_x15_r0_suffix.cwS0 : List Nat := [21966]
def PRE_first_tail_x15_r0_suffix.cnS0 : List Nat := List.range' 19057 0
def PRE_first_tail_x15_r0_suffix.ciS0 : List Nat := [] ++ List.range' 19057 0

-- the small checks (`MChecks`'s)
kernel_rfl PRE_first_tail_x15_r0_suffix.cnh00 : PRE_first_tail_x15_r0_suffix.kd0.nh0 = PRE_first_tail_x15_r0_suffix.cx0_0.mlx.next
kernel_rfl PRE_first_tail_x15_r0_suffix.cnh10 : PRE_first_tail_x15_r0_suffix.kd0.nh1 = PRE_first_tail_x15_r0_suffix.cx1_0.mlx.next
kernel_rfl PRE_first_tail_x15_r0_suffix.cnn00 : PRE_first_tail_x15_r0_suffix.kd0.nn0 = PRE_first_tail_x15_r0_suffix.cx0_0.mlx.nnext
kernel_rfl PRE_first_tail_x15_r0_suffix.cnn10 : PRE_first_tail_x15_r0_suffix.kd0.nn1 = PRE_first_tail_x15_r0_suffix.cx1_0.mlx.nnext
kernel_rfl PRE_first_tail_x15_r0_suffix.cplo0 : (Nat.blt 0 PRE_first_tail_x15_r0_suffix.P0.lo && Nat.ble PRE_first_tail_x15_r0_suffix.P0.lo PRE_first_tail_x15_r0_suffix.cx0_0.mlx.next && Nat.ble PRE_first_tail_x15_r0_suffix.P0.lo RData.bigHi && Nat.ble RData.bigHi PRE_first_tail_x15_r0_suffix.P0.E) = true
kernel_rfl PRE_first_tail_x15_r0_suffix.ccnt0 : (Nat.ble PRE_first_tail_x15_r0_suffix.cx0_0.mlx.next PRE_first_tail_x15_r0_suffix.cx1_0.mlx.next && Nat.ble PRE_first_tail_x15_r0_suffix.cx0_0.mlx.nnext PRE_first_tail_x15_r0_suffix.cx1_0.mlx.nnext) = true
kernel_rfl PRE_first_tail_x15_r0_suffix.cnband0 : (Nat.blt 0 PRE_first_tail_x15_r0_suffix.P0.NL && Nat.ble PRE_first_tail_x15_r0_suffix.P0.NL PRE_first_tail_x15_r0_suffix.P0.N0 && Nat.ble PRE_first_tail_x15_r0_suffix.P0.N0 PRE_first_tail_x15_r0_suffix.cx0_0.mlx.nnext) = true
kernel_rfl PRE_first_tail_x15_r0_suffix.chbelow0 : PRE_first_tail_x15_r0_suffix.kd0.checkHndBelow = true
kernel_rfl PRE_first_tail_x15_r0_suffix.chren0 : checkRenG PRE_first_tail_x15_r0_suffix.kd0.hnd PRE_first_tail_x15_r0_suffix.khinv0 (phB PRE_first_tail_x15_r0_suffix.cx0_0.mlx) = true
kernel_rfl PRE_first_tail_x15_r0_suffix.cband0 : PRE_first_tail_x15_r0_suffix.kd0.checkBand PRE_first_tail_x15_r0_suffix.P0.lo = true
kernel_rfl PRE_first_tail_x15_r0_suffix.cnh1pos0 : Nat.blt 0 PRE_first_tail_x15_r0_suffix.kd0.nh1 = true
kernel_rfl PRE_first_tail_x15_r0_suffix.cnren0 : checkRenG PRE_first_tail_x15_r0_suffix.kd0.node PRE_first_tail_x15_r0_suffix.kninv0 (pnB PRE_first_tail_x15_r0_suffix.cx0_0.mlx) = true
kernel_rfl PRE_first_tail_x15_r0_suffix.cnlow0 : (PTrie.keysA PRE_first_tail_x15_r0_suffix.kd0.node).all (fun j => Nat.ble PRE_first_tail_x15_r0_suffix.P0.NL j && Nat.blt (PRE_first_tail_x15_r0_suffix.kd0.nodeF j) PRE_first_tail_x15_r0_suffix.cx1_0.mlx.nnext) = true
kernel_rfl PRE_first_tail_x15_r0_suffix.cabs0a0 : PRE_first_tail_x15_r0_suffix.cx0_0.mlx.arrs.get 0 = none
kernel_rfl PRE_first_tail_x15_r0_suffix.cabs0b0 : PRE_first_tail_x15_r0_suffix.cx0_0.mlx.objs.get 0 = none
kernel_rfl PRE_first_tail_x15_r0_suffix.ctok10 : PRE_first_tail_x15_r0_suffix.cx1_0.mlx.tokens = []
kernel_rfl PRE_first_tail_x15_r0_suffix.cpend0 : PRE_first_tail_x15_r0_suffix.cx1_0.mlx.pending = PRE_first_tail_x15_r0_suffix.cx0_0.mlx.pending.map PRE_first_tail_x15_r0_suffix.kappa0.pend
kernel_rfl PRE_first_tail_x15_r0_suffix.cerrh0 : PRE_first_tail_x15_r0_suffix.cx1_0.mlx.errh = PRE_first_tail_x15_r0_suffix.cx0_0.mlx.errh.map PRE_first_tail_x15_r0_suffix.kappa0.arg
kernel_rfl PRE_first_tail_x15_r0_suffix.cfiles0 : PRE_first_tail_x15_r0_suffix.cx1_0.mlx.files = PRE_first_tail_x15_r0_suffix.cx0_0.mlx.files
kernel_rfl PRE_first_tail_x15_r0_suffix.carch0 : PRE_first_tail_x15_r0_suffix.cx1_0.mlx.arch = PRE_first_tail_x15_r0_suffix.cx0_0.mlx.arch
kernel_rfl PRE_first_tail_x15_r0_suffix.csizes0 : PRE_first_tail_x15_r0_suffix.cx1_0.mlx.deviceSizes = PRE_first_tail_x15_r0_suffix.cx0_0.mlx.deviceSizes
kernel_rfl PRE_first_tail_x15_r0_suffix.cwired0 : PRE_first_tail_x15_r0_suffix.cx1_0.mlx.wired = PRE_first_tail_x15_r0_suffix.cx0_0.mlx.wired
kernel_rfl PRE_first_tail_x15_r0_suffix.chost0 : PRE_first_tail_x15_r0_suffix.cx1_0.host = PRE_first_tail_x15_r0_suffix.cx0_0.host
-- the compaction map's addresses are `PRE_first_tail_x15_r0_suffix.kd0`'s
kernel_rfl PRE_first_tail_x15_r0_suffix.ckn00 : PRE_first_tail_x15_r0_suffix.kd0.n0 = 2825030
kernel_rfl PRE_first_tail_x15_r0_suffix.ckn10 : PRE_first_tail_x15_r0_suffix.kd0.n1 = 2828013
kernel_rfl PRE_first_tail_x15_r0_suffix.ckheap0 : (PTrie.keysA PRE_first_tail_x15_r0_suffix.kd0.heap).all (fun x => Nat.ble 2825030 x) = true
kernel_rfl PRE_first_tail_x15_r0_suffix.ckpl0 : (List.range 0).all (fun j => decide (PRE_first_tail_x15_r0_suffix.kd0.heap.get (2825030 + j) = nth? PRE_first_tail_x15_r0_suffix.pl0 j)) = true
-- the map fixes the call's names (`Conv.fixOld_compact`), the call's counters
kernel_rfl PRE_first_tail_x15_r0_suffix.fja0 : Nat.ble 2825030 2825030 = true
kernel_rfl PRE_first_tail_x15_r0_suffix.fn0 : Nat.ble 8226 8226 = true
kernel_rfl PRE_first_tail_x15_r0_suffix.fjaD0 : Nat.ble 2825030 PRE_first_tail_x15_r0_suffix.kd0.n0 = true
kernel_rfl PRE_first_tail_x15_r0_suffix.fxn0 : Nat.ble 21966 PRE_first_tail_x15_r0_suffix.kd0.nh0 = true
kernel_rfl PRE_first_tail_x15_r0_suffix.fnn0 : Nat.ble 19057 PRE_first_tail_x15_r0_suffix.kd0.nn0 = true
kernel_rfl PRE_first_tail_x15_r0_suffix.fxb0 : Nat.ble 21966 RData.bigHi = true
kernel_rfl PRE_first_tail_x15_r0_suffix.fheap0 : (PTrie.keysA PRE_first_tail_x15_r0_suffix.kd0.heap).all (Nat.ble (⟨21966, 19057, 2825030, 8226⟩ : Conv.Cnt).ja) = true
kernel_rfl PRE_first_tail_x15_r0_suffix.fhnd0 : (PTrie.keysA PRE_first_tail_x15_r0_suffix.kd0.hnd).all (Nat.ble (⟨21966, 19057, 2825030, 8226⟩ : Conv.Cnt).xn) = true
kernel_rfl PRE_first_tail_x15_r0_suffix.fnode0 : (PTrie.keysA PRE_first_tail_x15_r0_suffix.kd0.node).all (Nat.ble (⟨21966, 19057, 2825030, 8226⟩ : Conv.Cnt).nn) = true
/-- The compaction map fixes the call's names. -/
theorem PRE_first_tail_x15_r0_suffix.cfix0 : Conv.FixOld (⟨21966, 19057, 2825030, 8226⟩ : Conv.Cnt) PRE_first_tail_x15_r0_suffix.kappa0 :=
  Conv.fixOld_compact (Nat.le_of_ble_eq_true PRE_first_tail_x15_r0_suffix.fja0) (Nat.le_of_ble_eq_true PRE_first_tail_x15_r0_suffix.fn0) (Nat.le_of_ble_eq_true PRE_first_tail_x15_r0_suffix.fjaD0) (Nat.le_of_ble_eq_true PRE_first_tail_x15_r0_suffix.fxn0) (Nat.le_of_ble_eq_true PRE_first_tail_x15_r0_suffix.fnn0) (Nat.le_of_ble_eq_true PRE_first_tail_x15_r0_suffix.fxb0) PRE_first_tail_x15_r0_suffix.fheap0 PRE_first_tail_x15_r0_suffix.fhnd0 PRE_first_tail_x15_r0_suffix.fnode0
kernel_rfl PRE_first_tail_x15_r0_suffix.fcxn0 : (⟨21966, 19057, 2825030, 8226⟩ : Conv.Cnt).xn = (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_suffix.s2.ffi).mlx.next
kernel_rfl PRE_first_tail_x15_r0_suffix.fcnn0 : (⟨21966, 19057, 2825030, 8226⟩ : Conv.Cnt).nn = (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_suffix.s2.ffi).mlx.nnext
kernel_rfl PRE_first_tail_x15_r0_suffix.fle00 : (Nat.ble (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_suffix.s2.ffi).mlx.next PRE_first_tail_x15_r0_suffix.cx0_0.mlx.next && Nat.ble (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_suffix.s2.ffi).mlx.nnext PRE_first_tail_x15_r0_suffix.cx0_0.mlx.nnext && Nat.ble (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_suffix.s2.ffi).mlx.next RData.bigHi) = true
kernel_rfl PRE_first_tail_x15_r0_suffix.fnk0 : (PTrie.keysA PRE_first_tail_x15_r0_suffix.kd0.node).all (Nat.ble (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_suffix.s2.ffi).mlx.nnext) = true
-- the merged state keeps the call's entries off the stage's footprint
kernel_rfl PRE_first_tail_x15_r0_suffix.f1A0 : PRE_first_tail_x15_r0_suffix.cx1_0.mlx.arrs = Stage.setAll (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_suffix.s2.ffi).mlx.arrs (PRE_first_tail_x15_r0_suffix.cwS0.filterMap fun i => (PRE_first_tail_x15_r0_suffix.cx1_0.mlx.arrs.get i).map (i, ·))
kernel_rfl PRE_first_tail_x15_r0_suffix.f1O0 : PRE_first_tail_x15_r0_suffix.cx1_0.mlx.objs = Stage.setAll (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_suffix.s2.ffi).mlx.objs (PRE_first_tail_x15_r0_suffix.cwS0.filterMap fun i => (PRE_first_tail_x15_r0_suffix.cx1_0.mlx.objs.get i).map (i, ·))
kernel_rfl PRE_first_tail_x15_r0_suffix.f1N0 : PRE_first_tail_x15_r0_suffix.cx1_0.mlx.nodes = Stage.setAll (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_suffix.s2.ffi).mlx.nodes (PRE_first_tail_x15_r0_suffix.cnS0.filterMap fun i => (PRE_first_tail_x15_r0_suffix.cx1_0.mlx.nodes.get i).map (i, ·))
kernel_rfl PRE_first_tail_x15_r0_suffix.f1I0 : PRE_first_tail_x15_r0_suffix.cx1_0.mlx.items = Stage.setAll (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_suffix.s2.ffi).mlx.items (PRE_first_tail_x15_r0_suffix.ciS0.filterMap fun i => (PRE_first_tail_x15_r0_suffix.cx1_0.mlx.items.get i).map (i, ·))
kernel_rfl PRE_first_tail_x15_r0_suffix.fbd0 : (PRE_first_tail_x15_r0_suffix.clo0 ++ PRE_first_tail_x15_r0_suffix.cln0 ++ PRE_first_tail_x15_r0_suffix.cli0 ++ PRE_first_tail_x15_r0_suffix.cwS0 ++ PRE_first_tail_x15_r0_suffix.cnS0 ++ PRE_first_tail_x15_r0_suffix.ciS0).all (fun i => Nat.blt (i / 4096) (4 ^ 31)) = true
kernel_rfl PRE_first_tail_x15_r0_suffix.fincW0 : PRE_first_tail_x15_r0_suffix.cwS0.all (fun h => !Nat.blt h (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_suffix.s2.ffi).mlx.next || PRE_first_tail_x15_r0_suffix.clo0.contains h) = true
kernel_rfl PRE_first_tail_x15_r0_suffix.fincI0 : PRE_first_tail_x15_r0_suffix.ciS0.all (fun k => !Nat.blt k (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_suffix.s2.ffi).mlx.nnext || PRE_first_tail_x15_r0_suffix.cli0.contains k) = true
kernel_rfl PRE_first_tail_x15_r0_suffix.fincN0 : PRE_first_tail_x15_r0_suffix.cnS0.all (Nat.ble (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_suffix.s2.ffi).mlx.nnext) = true
kernel_rfl PRE_first_tail_x15_r0_suffix.flnF0 : PRE_first_tail_x15_r0_suffix.cln0.all (Nat.ble (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_suffix.s2.ffi).mlx.nnext) = true
-- the checks over the changed lists
kernel_rfl PRE_first_tail_x15_r0_suffix.fh0 : PRE_first_tail_x15_r0_suffix.clo0.all (handleOK PRE_first_tail_x15_r0_suffix.kappa0 PRE_first_tail_x15_r0_suffix.P0.lo PRE_first_tail_x15_r0_suffix.cx0_0.mlx PRE_first_tail_x15_r0_suffix.cx1_0.mlx) = true
kernel_rfl PRE_first_tail_x15_r0_suffix.fo0 : PRE_first_tail_x15_r0_suffix.clo0.map (fun h => PRE_first_tail_x15_r0_suffix.cx1_0.mlx.objs.get (PRE_first_tail_x15_r0_suffix.kappa0.handle h)) = PRE_first_tail_x15_r0_suffix.clo0.map (fun h => (PRE_first_tail_x15_r0_suffix.cx0_0.mlx.objs.get h).map PRE_first_tail_x15_r0_suffix.kappa0.nobj)
kernel_rfl PRE_first_tail_x15_r0_suffix.fok0 : PRE_first_tail_x15_r0_suffix.clo0.all (objOK PRE_first_tail_x15_r0_suffix.kappa0 PRE_first_tail_x15_r0_suffix.P0.NL PRE_first_tail_x15_r0_suffix.cx0_0.mlx) = true
kernel_rfl PRE_first_tail_x15_r0_suffix.fnd0 : PRE_first_tail_x15_r0_suffix.cln0.all (nodeOKF PRE_first_tail_x15_r0_suffix.kappa0 PRE_first_tail_x15_r0_suffix.P0 PRE_first_tail_x15_r0_suffix.cx0_0.mlx PRE_first_tail_x15_r0_suffix.cx1_0.mlx) = true
kernel_rfl PRE_first_tail_x15_r0_suffix.fp0 : ((PRE_first_tail_x15_r0_suffix.cln0.filter (fullB PRE_first_tail_x15_r0_suffix.P0))).map (fun i => (PRE_first_tail_x15_r0_suffix.cx1_0.mlx.nodes.get (PRE_first_tail_x15_r0_suffix.kappa0.node i)).map Host.Mlx.Ffi.Node.prim) =
  ((PRE_first_tail_x15_r0_suffix.cln0.filter (fullB PRE_first_tail_x15_r0_suffix.P0))).map (fun i => (PRE_first_tail_x15_r0_suffix.cx0_0.mlx.nodes.get i).map fun nd => PRE_first_tail_x15_r0_suffix.kappa0.prim nd.prim)
kernel_rfl PRE_first_tail_x15_r0_suffix.fnordI0 : incrB PRE_first_tail_x15_r0_suffix.kd0.nodeF (List.range' 19057 0) = true
kernel_rfl PRE_first_tail_x15_r0_suffix.fnordK0 : (PTrie.keysA PRE_first_tail_x15_r0_suffix.kd0.node).all (fun k => Nat.ble 19057 k && Nat.blt k 19057) = true
kernel_rfl PRE_first_tail_x15_r0_suffix.fnordL0 : (PRE_first_tail_x15_r0_suffix.cln0.filter (Nat.ble PRE_first_tail_x15_r0_suffix.P0.N0)).all (fun i => Nat.ble i (PRE_first_tail_x15_r0_suffix.kd0.nodeF i) && (Nat.blt i 19057 || Nat.ble PRE_first_tail_x15_r0_suffix.kd0.nn0 i)) = true
theorem PRE_first_tail_x15_r0_suffix.fnord0 : (PRE_first_tail_x15_r0_suffix.cln0.filter (Nat.ble PRE_first_tail_x15_r0_suffix.P0.N0)).all (fun i => Nat.ble i (PRE_first_tail_x15_r0_suffix.kd0.nodeF i) &&
    (PTrie.keysA PRE_first_tail_x15_r0_suffix.kd0.node).all fun j => !Nat.blt j i || Nat.blt (PRE_first_tail_x15_r0_suffix.kd0.nodeF j) (PRE_first_tail_x15_r0_suffix.kd0.nodeF i)) = true :=
  cnord_of PRE_first_tail_x15_r0_suffix.cnlow0 PRE_first_tail_x15_r0_suffix.cnn10 PRE_first_tail_x15_r0_suffix.fnordI0 PRE_first_tail_x15_r0_suffix.fnordK0 PRE_first_tail_x15_r0_suffix.fnordL0
kernel_rfl PRE_first_tail_x15_r0_suffix.fi0 : PRE_first_tail_x15_r0_suffix.cli0.all (pnB PRE_first_tail_x15_r0_suffix.cx0_0.mlx) = true
kernel_rfl PRE_first_tail_x15_r0_suffix.fii0 : PRE_first_tail_x15_r0_suffix.cli0.all (fun k => decide (PRE_first_tail_x15_r0_suffix.cx1_0.mlx.items.get (PRE_first_tail_x15_r0_suffix.kappa0.node k) = (PRE_first_tail_x15_r0_suffix.cx0_0.mlx.items.get k).map PRE_first_tail_x15_r0_suffix.kappa0.nv)) = true
/-- **The compaction's footprint.** -/
theorem PRE_first_tail_x15_r0_suffix.cfoot0 (clean : Conv.NClean (⟨21966, 19057, 2825030, 8226⟩ : Conv.Cnt) (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_suffix.s2.ffi).mlx) (hltC : ∀ h, PH (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_suffix.s2.ffi).mlx h → h < (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_suffix.s2.ffi).mlx.next) (nltC : ∀ i, PN (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_suffix.s2.ffi).mlx i → i < (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_suffix.s2.ffi).mlx.nnext) (itemsC : ∀ k v, (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_suffix.s2.ffi).mlx.items.get k = some v → PN (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_suffix.s2.ffi).mlx k) (tracedC : ∀ h o, (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_suffix.s2.ffi).mlx.objs.get h = some o → ∀ i ∈ objTraces o, i < PRE_first_tail_x15_r0_suffix.P0.NL) (cl : SSt (· < 8226) PRE_first_tail_x15_r0_suffix.cx0_0.mlx) :
    Conv.MFoot PRE_first_tail_x15_r0_suffix.P0 8226 PRE_first_tail_x15_r0_suffix.kappa0 PRE_first_tail_x15_r0_suffix.kd0 PRE_first_tail_x15_r0_suffix.khinv0 PRE_first_tail_x15_r0_suffix.kninv0 (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_suffix.s2.ffi).mlx PRE_first_tail_x15_r0_suffix.cx0_0.mlx PRE_first_tail_x15_r0_suffix.cx1_0.mlx (⟨21966, 19057, 2825030, 8226⟩ : Conv.Cnt) PRE_first_tail_x15_r0_suffix.clo0 PRE_first_tail_x15_r0_suffix.cln0 PRE_first_tail_x15_r0_suffix.cli0 PRE_first_tail_x15_r0_suffix.cwS0 PRE_first_tail_x15_r0_suffix.cnS0 PRE_first_tail_x15_r0_suffix.ciS0 :=
  ⟨rfl, rfl, rfl, PRE_first_tail_x15_r0_suffix.cnh00, PRE_first_tail_x15_r0_suffix.cnh10, PRE_first_tail_x15_r0_suffix.cnn00, PRE_first_tail_x15_r0_suffix.cnn10, PRE_first_tail_x15_r0_suffix.cplo0, PRE_first_tail_x15_r0_suffix.ccnt0, PRE_first_tail_x15_r0_suffix.cnband0, PRE_first_tail_x15_r0_suffix.chbelow0, PRE_first_tail_x15_r0_suffix.chren0, PRE_first_tail_x15_r0_suffix.cband0, PRE_first_tail_x15_r0_suffix.cnh1pos0, PRE_first_tail_x15_r0_suffix.cnren0, PRE_first_tail_x15_r0_suffix.cnlow0, PRE_first_tail_x15_r0_suffix.cabs0a0, PRE_first_tail_x15_r0_suffix.cabs0b0, PRE_first_tail_x15_r0_suffix.ctok10, PRE_first_tail_x15_r0_suffix.cpend0, PRE_first_tail_x15_r0_suffix.cerrh0, PRE_first_tail_x15_r0_suffix.cfiles0, PRE_first_tail_x15_r0_suffix.carch0, PRE_first_tail_x15_r0_suffix.csizes0, PRE_first_tail_x15_r0_suffix.cwired0, PRE_first_tail_x15_r0_suffix.cfix0, clean, PRE_first_tail_x15_r0_suffix.fcxn0, PRE_first_tail_x15_r0_suffix.fcnn0, hltC, nltC, itemsC, tracedC, cl, PRE_first_tail_x15_r0_suffix.fle00, PRE_first_tail_x15_r0_suffix.fnk0, PRE_first_tail_x15_r0_suffix.ckA0, PRE_first_tail_x15_r0_suffix.cobjsK0, PRE_first_tail_x15_r0_suffix.cnodesK0, PRE_first_tail_x15_r0_suffix.citemsK0, PRE_first_tail_x15_r0_suffix.f1A0, PRE_first_tail_x15_r0_suffix.f1O0, PRE_first_tail_x15_r0_suffix.f1N0, PRE_first_tail_x15_r0_suffix.f1I0, PRE_first_tail_x15_r0_suffix.fbd0, PRE_first_tail_x15_r0_suffix.fincW0, PRE_first_tail_x15_r0_suffix.fincI0, PRE_first_tail_x15_r0_suffix.fincN0, PRE_first_tail_x15_r0_suffix.flnF0, PRE_first_tail_x15_r0_suffix.fh0, PRE_first_tail_x15_r0_suffix.fo0, PRE_first_tail_x15_r0_suffix.fok0, PRE_first_tail_x15_r0_suffix.fnd0, PRE_first_tail_x15_r0_suffix.fp0, PRE_first_tail_x15_r0_suffix.fnord0, PRE_first_tail_x15_r0_suffix.fi0, PRE_first_tail_x15_r0_suffix.fii0⟩
theorem PRE_first_tail_x15_r0_suffix.cnshift0 (clean : Conv.NClean (⟨21966, 19057, 2825030, 8226⟩ : Conv.Cnt) (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_suffix.s2.ffi).mlx) (hltC : ∀ h, PH (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_suffix.s2.ffi).mlx h → h < (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_suffix.s2.ffi).mlx.next) (nltC : ∀ i, PN (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_suffix.s2.ffi).mlx i → i < (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_suffix.s2.ffi).mlx.nnext) (itemsC : ∀ k v, (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_suffix.s2.ffi).mlx.items.get k = some v → PN (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_suffix.s2.ffi).mlx k) (tracedC : ∀ h o, (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_suffix.s2.ffi).mlx.objs.get h = some o → ∀ i ∈ objTraces o, i < PRE_first_tail_x15_r0_suffix.P0.NL) (cl : SSt (· < 8226) PRE_first_tail_x15_r0_suffix.cx0_0.mlx) : NShift PRE_first_tail_x15_r0_suffix.P0 8226 PRE_first_tail_x15_r0_suffix.kappa0 PRE_first_tail_x15_r0_suffix.cx0_0 PRE_first_tail_x15_r0_suffix.cx1_0 :=
  Conv.nshift_of_foot (PRE_first_tail_x15_r0_suffix.cfoot0 clean hltC nltC itemsC tracedC cl) PRE_first_tail_x15_r0_suffix.chost0 (compact_a_eq PRE_first_tail_x15_r0_suffix.ckn00 PRE_first_tail_x15_r0_suffix.ckn10 PRE_first_tail_x15_r0_suffix.ckheap0 PRE_first_tail_x15_r0_suffix.ckpl0)

-- the observers: the layers' states at the call, the canonical and the merged state, their footprints and checks
noncomputable def PRE_first_tail_x15_r0_suffix.fxC_0 : PTrie Unit := (Host.Ts.Sim.Full.freedOf PRE_first_tail_x15_r0_suffix.s2.ffi).getD PTrie.nil
noncomputable def PRE_first_tail_x15_r0_suffix.krC_0 : Host.Load.Layers.KRec := (Host.Ts.Sim.Full.krecOf PRE_first_tail_x15_r0_suffix.s2.ffi).getD Host.Load.Layers.KRec.empty
kernel_rfl PRE_first_tail_x15_r0_suffix.ofxC_0 : (Host.Ts.Sim.Full.freedOf PRE_first_tail_x15_r0_suffix.s2.ffi) = some PRE_first_tail_x15_r0_suffix.fxC_0
kernel_rfl PRE_first_tail_x15_r0_suffix.okrC_0 : (Host.Ts.Sim.Full.krecOf PRE_first_tail_x15_r0_suffix.s2.ffi) = some PRE_first_tail_x15_r0_suffix.krC_0
noncomputable def PRE_first_tail_x15_r0_suffix.fx0_0 : PTrie Unit := (Host.Ts.Sim.Full.freedOf PRE_first_tail_x15_r0_suffix.s4.ffi).getD PTrie.nil
noncomputable def PRE_first_tail_x15_r0_suffix.kr0_0 : Host.Load.Layers.KRec := (Host.Ts.Sim.Full.krecOf PRE_first_tail_x15_r0_suffix.s4.ffi).getD Host.Load.Layers.KRec.empty
kernel_rfl PRE_first_tail_x15_r0_suffix.ofx0_0 : (Host.Ts.Sim.Full.freedOf PRE_first_tail_x15_r0_suffix.s4.ffi) = some PRE_first_tail_x15_r0_suffix.fx0_0
kernel_rfl PRE_first_tail_x15_r0_suffix.okr0_0 : (Host.Ts.Sim.Full.krecOf PRE_first_tail_x15_r0_suffix.s4.ffi) = some PRE_first_tail_x15_r0_suffix.kr0_0
noncomputable def PRE_first_tail_x15_r0_suffix.fx1_0 : PTrie Unit := (Host.Ts.Sim.Full.freedOf PRE_first_tail_x15_r0_suffix.s3.ffi).getD PTrie.nil
noncomputable def PRE_first_tail_x15_r0_suffix.kr1_0 : Host.Load.Layers.KRec := (Host.Ts.Sim.Full.krecOf PRE_first_tail_x15_r0_suffix.s3.ffi).getD Host.Load.Layers.KRec.empty
kernel_rfl PRE_first_tail_x15_r0_suffix.ofx1_0 : (Host.Ts.Sim.Full.freedOf PRE_first_tail_x15_r0_suffix.s3.ffi) = some PRE_first_tail_x15_r0_suffix.fx1_0
kernel_rfl PRE_first_tail_x15_r0_suffix.okr1_0 : (Host.Ts.Sim.Full.krecOf PRE_first_tail_x15_r0_suffix.s3.ffi) = some PRE_first_tail_x15_r0_suffix.kr1_0
kernel_rfl PRE_first_tail_x15_r0_suffix.ff00 : PRE_first_tail_x15_r0_suffix.fx0_0 = Stage.setAll PRE_first_tail_x15_r0_suffix.fxC_0 (PRE_first_tail_x15_r0_suffix.clo0.filterMap fun i => (PRE_first_tail_x15_r0_suffix.fx0_0.get i).map (i, ·))
kernel_rfl PRE_first_tail_x15_r0_suffix.ff10 : PRE_first_tail_x15_r0_suffix.fx1_0 = Stage.setAll PRE_first_tail_x15_r0_suffix.fxC_0 (PRE_first_tail_x15_r0_suffix.cwS0.filterMap fun i => (PRE_first_tail_x15_r0_suffix.fx1_0.get i).map (i, ·))
kernel_rfl PRE_first_tail_x15_r0_suffix.ffck0 : freedLB PRE_first_tail_x15_r0_suffix.kappa0 PRE_first_tail_x15_r0_suffix.cx0_0.mlx PRE_first_tail_x15_r0_suffix.fx0_0 PRE_first_tail_x15_r0_suffix.fx1_0 PRE_first_tail_x15_r0_suffix.clo0 = true
kernel_rfl PRE_first_tail_x15_r0_suffix.fkf00 : PRE_first_tail_x15_r0_suffix.kr0_0.flags = Stage.setAll PRE_first_tail_x15_r0_suffix.krC_0.flags (PRE_first_tail_x15_r0_suffix.clo0.filterMap fun i => (PRE_first_tail_x15_r0_suffix.kr0_0.flags.get i).map (i, ·))
kernel_rfl PRE_first_tail_x15_r0_suffix.fkt00 : PRE_first_tail_x15_r0_suffix.kr0_0.targs = Stage.setAll PRE_first_tail_x15_r0_suffix.krC_0.targs (PRE_first_tail_x15_r0_suffix.clo0.filterMap fun i => (PRE_first_tail_x15_r0_suffix.kr0_0.targs.get i).map (i, ·))
kernel_rfl PRE_first_tail_x15_r0_suffix.fkf10 : PRE_first_tail_x15_r0_suffix.kr1_0.flags = Stage.setAll PRE_first_tail_x15_r0_suffix.krC_0.flags (PRE_first_tail_x15_r0_suffix.cwS0.filterMap fun i => (PRE_first_tail_x15_r0_suffix.kr1_0.flags.get i).map (i, ·))
kernel_rfl PRE_first_tail_x15_r0_suffix.fkt10 : PRE_first_tail_x15_r0_suffix.kr1_0.targs = Stage.setAll PRE_first_tail_x15_r0_suffix.krC_0.targs (PRE_first_tail_x15_r0_suffix.cwS0.filterMap fun i => (PRE_first_tail_x15_r0_suffix.kr1_0.targs.get i).map (i, ·))
kernel_rfl PRE_first_tail_x15_r0_suffix.fkck0 : krecLB PRE_first_tail_x15_r0_suffix.kappa0 8226 PRE_first_tail_x15_r0_suffix.cx0_0.mlx PRE_first_tail_x15_r0_suffix.kr0_0 PRE_first_tail_x15_r0_suffix.kr1_0 PRE_first_tail_x15_r0_suffix.clo0 = true
kernel_rfl PRE_first_tail_x15_r0_suffix.fkn0 : Nat.ble 8226 8226 = true
-- the bridge and the pending traces' regions
kernel_rfl PRE_first_tail_x15_r0_suffix.cbridge0 : Host.Ts.Sim.Full.bridgeOf PRE_first_tail_x15_r0_suffix.s3.ffi = Host.Ts.Sim.Full.bridgeOf PRE_first_tail_x15_r0_suffix.s4.ffi
kernel_rfl PRE_first_tail_x15_r0_suffix.cpendR0 : pendRegB PRE_first_tail_x15_r0_suffix.kappa0 (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_suffix.s4.ffi).mlx = true
kernel_rfl PRE_first_tail_x15_r0_suffix.cpendLe0 : Nat.ble (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_suffix.s4.ffi).mlx.next (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_suffix.s3.ffi).mlx.next = true
/-- **The compaction's native shift**, given the call's bookkeeping, its relation's facts (the model's and the
observers') and the canonical closedness. -/
theorem PRE_first_tail_x15_r0_suffix.cshift0 (clean : Conv.NClean (⟨21966, 19057, 2825030, 8226⟩ : Conv.Cnt) (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_suffix.s2.ffi).mlx) (hltC : ∀ h, PH (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_suffix.s2.ffi).mlx h → h < (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_suffix.s2.ffi).mlx.next) (nltC : ∀ i, PN (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_suffix.s2.ffi).mlx i → i < (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_suffix.s2.ffi).mlx.nnext) (itemsC : ∀ k v, (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_suffix.s2.ffi).mlx.items.get k = some v → PN (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_suffix.s2.ffi).mlx k) (tracedC : ∀ h o, (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_suffix.s2.ffi).mlx.objs.get h = some o → ∀ i ∈ objTraces o, i < PRE_first_tail_x15_r0_suffix.P0.NL) (cl : SSt (· < 8226) PRE_first_tail_x15_r0_suffix.cx0_0.mlx)
    (hobjC : ∀ h, PRE_first_tail_x15_r0_suffix.fxC_0.get h = some () → ((Host.Load.Layers.toLoad PRE_first_tail_x15_r0_suffix.s2.ffi).mlx.objs.get h).isSome = true)
    (hfC : ∀ h, (PRE_first_tail_x15_r0_suffix.krC_0.flags.get h).isSome = true → ((Host.Load.Layers.toLoad PRE_first_tail_x15_r0_suffix.s2.ffi).mlx.objs.get h).isSome = true)
    (htC : ∀ h, (PRE_first_tail_x15_r0_suffix.krC_0.targs.get h).isSome = true → ((Host.Load.Layers.toLoad PRE_first_tail_x15_r0_suffix.s2.ffi).mlx.objs.get h).isSome = true)
    (hclC : ∀ h l, PRE_first_tail_x15_r0_suffix.krC_0.targs.get h = some l → Host.Ts.Sim.Full.STargs (· < (⟨21966, 19057, 2825030, 8226⟩ : Conv.Cnt).n) l) :
    Conv.FullShiftQ PRE_first_tail_x15_r0_suffix.P0 8226 PRE_first_tail_x15_r0_suffix.kappa0 PRE_first_tail_x15_r0_suffix.s4.ffi PRE_first_tail_x15_r0_suffix.s3.ffi :=
  ⟨PRE_first_tail_x15_r0_suffix.cnshift0 clean hltC nltC itemsC tracedC cl, PRE_first_tail_x15_r0_suffix.cqueue0, fun t ht => bSN_sound (List.all_eq_true.mp PRE_first_tail_x15_r0_suffix.ctokSupp0 t ht),
    PRE_first_tail_x15_r0_suffix.cbridge0,
    liveShift_foot (x0' := Host.Ts.Sim.Full.mlxOf PRE_first_tail_x15_r0_suffix.s4.ffi) (x1' := Host.Ts.Sim.Full.mlxOf PRE_first_tail_x15_r0_suffix.s3.ffi) (PRE_first_tail_x15_r0_suffix.cfoot0 clean hltC nltC itemsC tracedC cl) rfl PRE_first_tail_x15_r0_suffix.ofx0_0 PRE_first_tail_x15_r0_suffix.ofx1_0 hobjC PRE_first_tail_x15_r0_suffix.ff00 PRE_first_tail_x15_r0_suffix.ff10 PRE_first_tail_x15_r0_suffix.ffck0,
    kernShift_foot (x0' := Host.Ts.Sim.Full.mlxOf PRE_first_tail_x15_r0_suffix.s4.ffi) (x1' := Host.Ts.Sim.Full.mlxOf PRE_first_tail_x15_r0_suffix.s3.ffi) (PRE_first_tail_x15_r0_suffix.cfoot0 clean hltC nltC itemsC tracedC cl) rfl PRE_first_tail_x15_r0_suffix.okr0_0 PRE_first_tail_x15_r0_suffix.okr1_0 (Nat.le_of_ble_eq_true PRE_first_tail_x15_r0_suffix.fkn0) hfC htC hclC
      PRE_first_tail_x15_r0_suffix.fkf00 PRE_first_tail_x15_r0_suffix.fkt00 PRE_first_tail_x15_r0_suffix.fkf10 PRE_first_tail_x15_r0_suffix.fkt10 PRE_first_tail_x15_r0_suffix.fkck0,
    pendReg_of rfl PRE_first_tail_x15_r0_suffix.cnh00 PRE_first_tail_x15_r0_suffix.cnh10 (Nat.le_of_ble_eq_true PRE_first_tail_x15_r0_suffix.cpendLe0) PRE_first_tail_x15_r0_suffix.cpendR0⟩

end Host.Load.Run.Tpl
