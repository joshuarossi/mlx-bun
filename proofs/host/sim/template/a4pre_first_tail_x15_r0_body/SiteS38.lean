import host.sim.template.a4pre_first_tail_x15_r0_body.SiteCl38
import host.sim.conv.CompactFull
import host.sim.template.FootGen
set_option Elab.async false
namespace Host.Load.Run.Tpl
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
open Host.Ts Host.Ts.Sim Host.Ts.Sim.Template

/-! The compaction's native shift at call site 38 from its footprint (`Conv.nshift_of_foot`), and the observers'
(`liveShift_foot`, `kernShift_foot`): `Conv.FullShiftQ` for `Conv.full_compactQ`, given the call's bookkeeping and its
relation's facts. -/

/-- The load parameters of the chain (band-free: its start's node counter as `NL` and `N0`). -/
def PRE_first_tail_x15_r0_body.Pc38 : LoadP := ⟨18151, 131072, 1099511627776, 15235, 15235, []⟩
/-- The site's band raised to the map's checked fixed-node prefix, including newly recorded closure traces. -/
def PRE_first_tail_x15_r0_body.P38 : LoadP := PRE_first_tail_x15_r0_body.Pc38.raise 16033
kernel_rfl PRE_first_tail_x15_r0_body.craise38 : Nat.ble PRE_first_tail_x15_r0_body.Pc38.N0 16033 = true
theorem PRE_first_tail_x15_r0_body.raised38 : Host.Ts.Sim.Full.Raised PRE_first_tail_x15_r0_body.Pc38 PRE_first_tail_x15_r0_body.P38 :=
  .inr ⟨16033, rfl, Nat.le_of_ble_eq_true PRE_first_tail_x15_r0_body.craise38, rfl⟩
noncomputable abbrev PRE_first_tail_x15_r0_body.cx0_38 : Host.Load.LSt := clearTokens (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s375.ffi)
noncomputable abbrev PRE_first_tail_x15_r0_body.cx1_38 : Host.Load.LSt := clearTokens (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s374.ffi)
def PRE_first_tail_x15_r0_body.khinv38 : PTrie Nat := Stage.setAll PTrie.nil []
def PRE_first_tail_x15_r0_body.kninv38 : PTrie Nat := Stage.setAll PTrie.nil []
/-- The stage's footprint: its written and fresh handles, fresh nodes, written and fresh items. -/
def PRE_first_tail_x15_r0_body.cwS38 : List Nat := []
def PRE_first_tail_x15_r0_body.cnS38 : List Nat := List.range' 16033 0
def PRE_first_tail_x15_r0_body.ciS38 : List Nat := [] ++ List.range' 16033 0

-- the small checks (`MChecks`'s)
kernel_rfl PRE_first_tail_x15_r0_body.cnh038 : PRE_first_tail_x15_r0_body.kd38.nh0 = PRE_first_tail_x15_r0_body.cx0_38.mlx.next
kernel_rfl PRE_first_tail_x15_r0_body.cnh138 : PRE_first_tail_x15_r0_body.kd38.nh1 = PRE_first_tail_x15_r0_body.cx1_38.mlx.next
kernel_rfl PRE_first_tail_x15_r0_body.cnn038 : PRE_first_tail_x15_r0_body.kd38.nn0 = PRE_first_tail_x15_r0_body.cx0_38.mlx.nnext
kernel_rfl PRE_first_tail_x15_r0_body.cnn138 : PRE_first_tail_x15_r0_body.kd38.nn1 = PRE_first_tail_x15_r0_body.cx1_38.mlx.nnext
kernel_rfl PRE_first_tail_x15_r0_body.cplo38 : (Nat.blt 0 PRE_first_tail_x15_r0_body.P38.lo && Nat.ble PRE_first_tail_x15_r0_body.P38.lo PRE_first_tail_x15_r0_body.cx0_38.mlx.next && Nat.ble PRE_first_tail_x15_r0_body.P38.lo RData.bigHi && Nat.ble RData.bigHi PRE_first_tail_x15_r0_body.P38.E) = true
kernel_rfl PRE_first_tail_x15_r0_body.ccnt38 : (Nat.ble PRE_first_tail_x15_r0_body.cx0_38.mlx.next PRE_first_tail_x15_r0_body.cx1_38.mlx.next && Nat.ble PRE_first_tail_x15_r0_body.cx0_38.mlx.nnext PRE_first_tail_x15_r0_body.cx1_38.mlx.nnext) = true
kernel_rfl PRE_first_tail_x15_r0_body.cnband38 : (Nat.blt 0 PRE_first_tail_x15_r0_body.P38.NL && Nat.ble PRE_first_tail_x15_r0_body.P38.NL PRE_first_tail_x15_r0_body.P38.N0 && Nat.ble PRE_first_tail_x15_r0_body.P38.N0 PRE_first_tail_x15_r0_body.cx0_38.mlx.nnext) = true
kernel_rfl PRE_first_tail_x15_r0_body.chbelow38 : PRE_first_tail_x15_r0_body.kd38.checkHndBelow = true
kernel_rfl PRE_first_tail_x15_r0_body.chren38 : checkRenG PRE_first_tail_x15_r0_body.kd38.hnd PRE_first_tail_x15_r0_body.khinv38 (phB PRE_first_tail_x15_r0_body.cx0_38.mlx) = true
kernel_rfl PRE_first_tail_x15_r0_body.cband38 : PRE_first_tail_x15_r0_body.kd38.checkBand PRE_first_tail_x15_r0_body.P38.lo = true
kernel_rfl PRE_first_tail_x15_r0_body.cnh1pos38 : Nat.blt 0 PRE_first_tail_x15_r0_body.kd38.nh1 = true
kernel_rfl PRE_first_tail_x15_r0_body.cnren38 : checkRenG PRE_first_tail_x15_r0_body.kd38.node PRE_first_tail_x15_r0_body.kninv38 (pnB PRE_first_tail_x15_r0_body.cx0_38.mlx) = true
kernel_rfl PRE_first_tail_x15_r0_body.cnlow38 : (PTrie.keysA PRE_first_tail_x15_r0_body.kd38.node).all (fun j => Nat.ble PRE_first_tail_x15_r0_body.P38.NL j && Nat.blt (PRE_first_tail_x15_r0_body.kd38.nodeF j) PRE_first_tail_x15_r0_body.cx1_38.mlx.nnext) = true
kernel_rfl PRE_first_tail_x15_r0_body.cabs0a38 : PRE_first_tail_x15_r0_body.cx0_38.mlx.arrs.get 0 = none
kernel_rfl PRE_first_tail_x15_r0_body.cabs0b38 : PRE_first_tail_x15_r0_body.cx0_38.mlx.objs.get 0 = none
kernel_rfl PRE_first_tail_x15_r0_body.ctok138 : PRE_first_tail_x15_r0_body.cx1_38.mlx.tokens = []
kernel_rfl PRE_first_tail_x15_r0_body.cpend38 : PRE_first_tail_x15_r0_body.cx1_38.mlx.pending = PRE_first_tail_x15_r0_body.cx0_38.mlx.pending.map PRE_first_tail_x15_r0_body.kappa38.pend
kernel_rfl PRE_first_tail_x15_r0_body.cerrh38 : PRE_first_tail_x15_r0_body.cx1_38.mlx.errh = PRE_first_tail_x15_r0_body.cx0_38.mlx.errh.map PRE_first_tail_x15_r0_body.kappa38.arg
kernel_rfl PRE_first_tail_x15_r0_body.cfiles38 : PRE_first_tail_x15_r0_body.cx1_38.mlx.files = PRE_first_tail_x15_r0_body.cx0_38.mlx.files
kernel_rfl PRE_first_tail_x15_r0_body.carch38 : PRE_first_tail_x15_r0_body.cx1_38.mlx.arch = PRE_first_tail_x15_r0_body.cx0_38.mlx.arch
kernel_rfl PRE_first_tail_x15_r0_body.csizes38 : PRE_first_tail_x15_r0_body.cx1_38.mlx.deviceSizes = PRE_first_tail_x15_r0_body.cx0_38.mlx.deviceSizes
kernel_rfl PRE_first_tail_x15_r0_body.cwired38 : PRE_first_tail_x15_r0_body.cx1_38.mlx.wired = PRE_first_tail_x15_r0_body.cx0_38.mlx.wired
kernel_rfl PRE_first_tail_x15_r0_body.chost38 : PRE_first_tail_x15_r0_body.cx1_38.host = PRE_first_tail_x15_r0_body.cx0_38.host
-- the compaction map's addresses are `PRE_first_tail_x15_r0_body.kd38`'s
kernel_rfl PRE_first_tail_x15_r0_body.ckn038 : PRE_first_tail_x15_r0_body.kd38.n0 = 2704488
kernel_rfl PRE_first_tail_x15_r0_body.ckn138 : PRE_first_tail_x15_r0_body.kd38.n1 = 2704498
kernel_rfl PRE_first_tail_x15_r0_body.ckheap38 : (PTrie.keysA PRE_first_tail_x15_r0_body.kd38.heap).all (fun x => Nat.ble 2704487 x) = true
kernel_rfl PRE_first_tail_x15_r0_body.ckpl38 : (List.range 1).all (fun j => decide (PRE_first_tail_x15_r0_body.kd38.heap.get (2704487 + j) = nth? PRE_first_tail_x15_r0_body.pl38 j)) = true
-- the map fixes the call's names (`Conv.fixOld_compact`), the call's counters
kernel_rfl PRE_first_tail_x15_r0_body.fja38 : Nat.ble 2704487 2704487 = true
kernel_rfl PRE_first_tail_x15_r0_body.fn38 : Nat.ble 1678 1678 = true
kernel_rfl PRE_first_tail_x15_r0_body.fjaD38 : Nat.ble 2704487 PRE_first_tail_x15_r0_body.kd38.n0 = true
kernel_rfl PRE_first_tail_x15_r0_body.fxn38 : Nat.ble 18947 PRE_first_tail_x15_r0_body.kd38.nh0 = true
kernel_rfl PRE_first_tail_x15_r0_body.fnn38 : Nat.ble 16033 PRE_first_tail_x15_r0_body.kd38.nn0 = true
kernel_rfl PRE_first_tail_x15_r0_body.fxb38 : Nat.ble 18947 RData.bigHi = true
kernel_rfl PRE_first_tail_x15_r0_body.fheap38 : (PTrie.keysA PRE_first_tail_x15_r0_body.kd38.heap).all (Nat.ble (⟨18947, 16033, 2704487, 1678⟩ : Conv.Cnt).ja) = true
kernel_rfl PRE_first_tail_x15_r0_body.fhnd38 : (PTrie.keysA PRE_first_tail_x15_r0_body.kd38.hnd).all (Nat.ble (⟨18947, 16033, 2704487, 1678⟩ : Conv.Cnt).xn) = true
kernel_rfl PRE_first_tail_x15_r0_body.fnode38 : (PTrie.keysA PRE_first_tail_x15_r0_body.kd38.node).all (Nat.ble (⟨18947, 16033, 2704487, 1678⟩ : Conv.Cnt).nn) = true
/-- The compaction map fixes the call's names. -/
theorem PRE_first_tail_x15_r0_body.cfix38 : Conv.FixOld (⟨18947, 16033, 2704487, 1678⟩ : Conv.Cnt) PRE_first_tail_x15_r0_body.kappa38 :=
  Conv.fixOld_compact (Nat.le_of_ble_eq_true PRE_first_tail_x15_r0_body.fja38) (Nat.le_of_ble_eq_true PRE_first_tail_x15_r0_body.fn38) (Nat.le_of_ble_eq_true PRE_first_tail_x15_r0_body.fjaD38) (Nat.le_of_ble_eq_true PRE_first_tail_x15_r0_body.fxn38) (Nat.le_of_ble_eq_true PRE_first_tail_x15_r0_body.fnn38) (Nat.le_of_ble_eq_true PRE_first_tail_x15_r0_body.fxb38) PRE_first_tail_x15_r0_body.fheap38 PRE_first_tail_x15_r0_body.fhnd38 PRE_first_tail_x15_r0_body.fnode38
kernel_rfl PRE_first_tail_x15_r0_body.fcxn38 : (⟨18947, 16033, 2704487, 1678⟩ : Conv.Cnt).xn = (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s373.ffi).mlx.next
kernel_rfl PRE_first_tail_x15_r0_body.fcnn38 : (⟨18947, 16033, 2704487, 1678⟩ : Conv.Cnt).nn = (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s373.ffi).mlx.nnext
kernel_rfl PRE_first_tail_x15_r0_body.fle038 : (Nat.ble (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s373.ffi).mlx.next PRE_first_tail_x15_r0_body.cx0_38.mlx.next && Nat.ble (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s373.ffi).mlx.nnext PRE_first_tail_x15_r0_body.cx0_38.mlx.nnext && Nat.ble (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s373.ffi).mlx.next RData.bigHi) = true
kernel_rfl PRE_first_tail_x15_r0_body.fnk38 : (PTrie.keysA PRE_first_tail_x15_r0_body.kd38.node).all (Nat.ble (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s373.ffi).mlx.nnext) = true
-- the merged state keeps the call's entries off the stage's footprint
kernel_rfl PRE_first_tail_x15_r0_body.f1A38 : PRE_first_tail_x15_r0_body.cx1_38.mlx.arrs = Stage.setAll (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s373.ffi).mlx.arrs (PRE_first_tail_x15_r0_body.cwS38.filterMap fun i => (PRE_first_tail_x15_r0_body.cx1_38.mlx.arrs.get i).map (i, ·))
kernel_rfl PRE_first_tail_x15_r0_body.f1O38 : PRE_first_tail_x15_r0_body.cx1_38.mlx.objs = Stage.setAll (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s373.ffi).mlx.objs (PRE_first_tail_x15_r0_body.cwS38.filterMap fun i => (PRE_first_tail_x15_r0_body.cx1_38.mlx.objs.get i).map (i, ·))
kernel_rfl PRE_first_tail_x15_r0_body.f1N38 : PRE_first_tail_x15_r0_body.cx1_38.mlx.nodes = Stage.setAll (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s373.ffi).mlx.nodes (PRE_first_tail_x15_r0_body.cnS38.filterMap fun i => (PRE_first_tail_x15_r0_body.cx1_38.mlx.nodes.get i).map (i, ·))
kernel_rfl PRE_first_tail_x15_r0_body.f1I38 : PRE_first_tail_x15_r0_body.cx1_38.mlx.items = Stage.setAll (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s373.ffi).mlx.items (PRE_first_tail_x15_r0_body.ciS38.filterMap fun i => (PRE_first_tail_x15_r0_body.cx1_38.mlx.items.get i).map (i, ·))
kernel_rfl PRE_first_tail_x15_r0_body.fbd38 : (PRE_first_tail_x15_r0_body.clo38 ++ PRE_first_tail_x15_r0_body.cln38 ++ PRE_first_tail_x15_r0_body.cli38 ++ PRE_first_tail_x15_r0_body.cwS38 ++ PRE_first_tail_x15_r0_body.cnS38 ++ PRE_first_tail_x15_r0_body.ciS38).all (fun i => Nat.blt (i / 4096) (4 ^ 31)) = true
kernel_rfl PRE_first_tail_x15_r0_body.fincW38 : PRE_first_tail_x15_r0_body.cwS38.all (fun h => !Nat.blt h (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s373.ffi).mlx.next || PRE_first_tail_x15_r0_body.clo38.contains h) = true
kernel_rfl PRE_first_tail_x15_r0_body.fincI38 : PRE_first_tail_x15_r0_body.ciS38.all (fun k => !Nat.blt k (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s373.ffi).mlx.nnext || PRE_first_tail_x15_r0_body.cli38.contains k) = true
kernel_rfl PRE_first_tail_x15_r0_body.fincN38 : PRE_first_tail_x15_r0_body.cnS38.all (Nat.ble (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s373.ffi).mlx.nnext) = true
kernel_rfl PRE_first_tail_x15_r0_body.flnF38 : PRE_first_tail_x15_r0_body.cln38.all (Nat.ble (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s373.ffi).mlx.nnext) = true
-- the checks over the changed lists
kernel_rfl PRE_first_tail_x15_r0_body.fh38 : PRE_first_tail_x15_r0_body.clo38.all (handleOK PRE_first_tail_x15_r0_body.kappa38 PRE_first_tail_x15_r0_body.P38.lo PRE_first_tail_x15_r0_body.cx0_38.mlx PRE_first_tail_x15_r0_body.cx1_38.mlx) = true
kernel_rfl PRE_first_tail_x15_r0_body.fo38 : PRE_first_tail_x15_r0_body.clo38.map (fun h => PRE_first_tail_x15_r0_body.cx1_38.mlx.objs.get (PRE_first_tail_x15_r0_body.kappa38.handle h)) = PRE_first_tail_x15_r0_body.clo38.map (fun h => (PRE_first_tail_x15_r0_body.cx0_38.mlx.objs.get h).map PRE_first_tail_x15_r0_body.kappa38.nobj)
kernel_rfl PRE_first_tail_x15_r0_body.fok38 : PRE_first_tail_x15_r0_body.clo38.all (objOK PRE_first_tail_x15_r0_body.kappa38 PRE_first_tail_x15_r0_body.P38.NL PRE_first_tail_x15_r0_body.cx0_38.mlx) = true
kernel_rfl PRE_first_tail_x15_r0_body.fnd38 : PRE_first_tail_x15_r0_body.cln38.all (nodeOKF PRE_first_tail_x15_r0_body.kappa38 PRE_first_tail_x15_r0_body.P38 PRE_first_tail_x15_r0_body.cx0_38.mlx PRE_first_tail_x15_r0_body.cx1_38.mlx) = true
kernel_rfl PRE_first_tail_x15_r0_body.fp38 : ((PRE_first_tail_x15_r0_body.cln38.filter (fullB PRE_first_tail_x15_r0_body.P38))).map (fun i => (PRE_first_tail_x15_r0_body.cx1_38.mlx.nodes.get (PRE_first_tail_x15_r0_body.kappa38.node i)).map Host.Mlx.Ffi.Node.prim) =
  ((PRE_first_tail_x15_r0_body.cln38.filter (fullB PRE_first_tail_x15_r0_body.P38))).map (fun i => (PRE_first_tail_x15_r0_body.cx0_38.mlx.nodes.get i).map fun nd => PRE_first_tail_x15_r0_body.kappa38.prim nd.prim)
kernel_rfl PRE_first_tail_x15_r0_body.fnordI38 : incrB PRE_first_tail_x15_r0_body.kd38.nodeF (List.range' 16033 0) = true
kernel_rfl PRE_first_tail_x15_r0_body.fnordK38 : (PTrie.keysA PRE_first_tail_x15_r0_body.kd38.node).all (fun k => Nat.ble 16033 k && Nat.blt k 16033) = true
kernel_rfl PRE_first_tail_x15_r0_body.fnordL38 : (PRE_first_tail_x15_r0_body.cln38.filter (Nat.ble PRE_first_tail_x15_r0_body.P38.N0)).all (fun i => Nat.ble i (PRE_first_tail_x15_r0_body.kd38.nodeF i) && (Nat.blt i 16033 || Nat.ble PRE_first_tail_x15_r0_body.kd38.nn0 i)) = true
theorem PRE_first_tail_x15_r0_body.fnord38 : (PRE_first_tail_x15_r0_body.cln38.filter (Nat.ble PRE_first_tail_x15_r0_body.P38.N0)).all (fun i => Nat.ble i (PRE_first_tail_x15_r0_body.kd38.nodeF i) &&
    (PTrie.keysA PRE_first_tail_x15_r0_body.kd38.node).all fun j => !Nat.blt j i || Nat.blt (PRE_first_tail_x15_r0_body.kd38.nodeF j) (PRE_first_tail_x15_r0_body.kd38.nodeF i)) = true :=
  cnord_of PRE_first_tail_x15_r0_body.cnlow38 PRE_first_tail_x15_r0_body.cnn138 PRE_first_tail_x15_r0_body.fnordI38 PRE_first_tail_x15_r0_body.fnordK38 PRE_first_tail_x15_r0_body.fnordL38
kernel_rfl PRE_first_tail_x15_r0_body.fi38 : PRE_first_tail_x15_r0_body.cli38.all (pnB PRE_first_tail_x15_r0_body.cx0_38.mlx) = true
kernel_rfl PRE_first_tail_x15_r0_body.fii38 : PRE_first_tail_x15_r0_body.cli38.all (fun k => decide (PRE_first_tail_x15_r0_body.cx1_38.mlx.items.get (PRE_first_tail_x15_r0_body.kappa38.node k) = (PRE_first_tail_x15_r0_body.cx0_38.mlx.items.get k).map PRE_first_tail_x15_r0_body.kappa38.nv)) = true
/-- **The compaction's footprint.** -/
theorem PRE_first_tail_x15_r0_body.cfoot38 (clean : Conv.NClean (⟨18947, 16033, 2704487, 1678⟩ : Conv.Cnt) (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s373.ffi).mlx) (hltC : ∀ h, PH (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s373.ffi).mlx h → h < (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s373.ffi).mlx.next) (nltC : ∀ i, PN (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s373.ffi).mlx i → i < (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s373.ffi).mlx.nnext) (itemsC : ∀ k v, (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s373.ffi).mlx.items.get k = some v → PN (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s373.ffi).mlx k) (tracedC : ∀ h o, (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s373.ffi).mlx.objs.get h = some o → ∀ i ∈ objTraces o, i < PRE_first_tail_x15_r0_body.P38.NL) (cl : SSt (· < 1678) PRE_first_tail_x15_r0_body.cx0_38.mlx) :
    Conv.MFoot PRE_first_tail_x15_r0_body.P38 1678 PRE_first_tail_x15_r0_body.kappa38 PRE_first_tail_x15_r0_body.kd38 PRE_first_tail_x15_r0_body.khinv38 PRE_first_tail_x15_r0_body.kninv38 (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s373.ffi).mlx PRE_first_tail_x15_r0_body.cx0_38.mlx PRE_first_tail_x15_r0_body.cx1_38.mlx (⟨18947, 16033, 2704487, 1678⟩ : Conv.Cnt) PRE_first_tail_x15_r0_body.clo38 PRE_first_tail_x15_r0_body.cln38 PRE_first_tail_x15_r0_body.cli38 PRE_first_tail_x15_r0_body.cwS38 PRE_first_tail_x15_r0_body.cnS38 PRE_first_tail_x15_r0_body.ciS38 :=
  ⟨rfl, rfl, rfl, PRE_first_tail_x15_r0_body.cnh038, PRE_first_tail_x15_r0_body.cnh138, PRE_first_tail_x15_r0_body.cnn038, PRE_first_tail_x15_r0_body.cnn138, PRE_first_tail_x15_r0_body.cplo38, PRE_first_tail_x15_r0_body.ccnt38, PRE_first_tail_x15_r0_body.cnband38, PRE_first_tail_x15_r0_body.chbelow38, PRE_first_tail_x15_r0_body.chren38, PRE_first_tail_x15_r0_body.cband38, PRE_first_tail_x15_r0_body.cnh1pos38, PRE_first_tail_x15_r0_body.cnren38, PRE_first_tail_x15_r0_body.cnlow38, PRE_first_tail_x15_r0_body.cabs0a38, PRE_first_tail_x15_r0_body.cabs0b38, PRE_first_tail_x15_r0_body.ctok138, PRE_first_tail_x15_r0_body.cpend38, PRE_first_tail_x15_r0_body.cerrh38, PRE_first_tail_x15_r0_body.cfiles38, PRE_first_tail_x15_r0_body.carch38, PRE_first_tail_x15_r0_body.csizes38, PRE_first_tail_x15_r0_body.cwired38, PRE_first_tail_x15_r0_body.cfix38, clean, PRE_first_tail_x15_r0_body.fcxn38, PRE_first_tail_x15_r0_body.fcnn38, hltC, nltC, itemsC, tracedC, cl, PRE_first_tail_x15_r0_body.fle038, PRE_first_tail_x15_r0_body.fnk38, PRE_first_tail_x15_r0_body.ckA38, PRE_first_tail_x15_r0_body.cobjsK38, PRE_first_tail_x15_r0_body.cnodesK38, PRE_first_tail_x15_r0_body.citemsK38, PRE_first_tail_x15_r0_body.f1A38, PRE_first_tail_x15_r0_body.f1O38, PRE_first_tail_x15_r0_body.f1N38, PRE_first_tail_x15_r0_body.f1I38, PRE_first_tail_x15_r0_body.fbd38, PRE_first_tail_x15_r0_body.fincW38, PRE_first_tail_x15_r0_body.fincI38, PRE_first_tail_x15_r0_body.fincN38, PRE_first_tail_x15_r0_body.flnF38, PRE_first_tail_x15_r0_body.fh38, PRE_first_tail_x15_r0_body.fo38, PRE_first_tail_x15_r0_body.fok38, PRE_first_tail_x15_r0_body.fnd38, PRE_first_tail_x15_r0_body.fp38, PRE_first_tail_x15_r0_body.fnord38, PRE_first_tail_x15_r0_body.fi38, PRE_first_tail_x15_r0_body.fii38⟩
theorem PRE_first_tail_x15_r0_body.cnshift38 (clean : Conv.NClean (⟨18947, 16033, 2704487, 1678⟩ : Conv.Cnt) (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s373.ffi).mlx) (hltC : ∀ h, PH (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s373.ffi).mlx h → h < (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s373.ffi).mlx.next) (nltC : ∀ i, PN (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s373.ffi).mlx i → i < (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s373.ffi).mlx.nnext) (itemsC : ∀ k v, (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s373.ffi).mlx.items.get k = some v → PN (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s373.ffi).mlx k) (tracedC : ∀ h o, (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s373.ffi).mlx.objs.get h = some o → ∀ i ∈ objTraces o, i < PRE_first_tail_x15_r0_body.P38.NL) (cl : SSt (· < 1678) PRE_first_tail_x15_r0_body.cx0_38.mlx) : NShift PRE_first_tail_x15_r0_body.P38 1678 PRE_first_tail_x15_r0_body.kappa38 PRE_first_tail_x15_r0_body.cx0_38 PRE_first_tail_x15_r0_body.cx1_38 :=
  Conv.nshift_of_foot (PRE_first_tail_x15_r0_body.cfoot38 clean hltC nltC itemsC tracedC cl) PRE_first_tail_x15_r0_body.chost38 (compact_a_eq PRE_first_tail_x15_r0_body.ckn038 PRE_first_tail_x15_r0_body.ckn138 PRE_first_tail_x15_r0_body.ckheap38 PRE_first_tail_x15_r0_body.ckpl38)

-- the observers: the layers' states at the call, the canonical and the merged state, their footprints and checks
noncomputable def PRE_first_tail_x15_r0_body.fxC_38 : PTrie Unit := (Host.Ts.Sim.Full.freedOf PRE_first_tail_x15_r0_body.s373.ffi).getD PTrie.nil
noncomputable def PRE_first_tail_x15_r0_body.krC_38 : Host.Load.Layers.KRec := (Host.Ts.Sim.Full.krecOf PRE_first_tail_x15_r0_body.s373.ffi).getD Host.Load.Layers.KRec.empty
kernel_rfl PRE_first_tail_x15_r0_body.ofxC_38 : (Host.Ts.Sim.Full.freedOf PRE_first_tail_x15_r0_body.s373.ffi) = some PRE_first_tail_x15_r0_body.fxC_38
kernel_rfl PRE_first_tail_x15_r0_body.okrC_38 : (Host.Ts.Sim.Full.krecOf PRE_first_tail_x15_r0_body.s373.ffi) = some PRE_first_tail_x15_r0_body.krC_38
noncomputable def PRE_first_tail_x15_r0_body.fx0_38 : PTrie Unit := (Host.Ts.Sim.Full.freedOf PRE_first_tail_x15_r0_body.s375.ffi).getD PTrie.nil
noncomputable def PRE_first_tail_x15_r0_body.kr0_38 : Host.Load.Layers.KRec := (Host.Ts.Sim.Full.krecOf PRE_first_tail_x15_r0_body.s375.ffi).getD Host.Load.Layers.KRec.empty
kernel_rfl PRE_first_tail_x15_r0_body.ofx0_38 : (Host.Ts.Sim.Full.freedOf PRE_first_tail_x15_r0_body.s375.ffi) = some PRE_first_tail_x15_r0_body.fx0_38
kernel_rfl PRE_first_tail_x15_r0_body.okr0_38 : (Host.Ts.Sim.Full.krecOf PRE_first_tail_x15_r0_body.s375.ffi) = some PRE_first_tail_x15_r0_body.kr0_38
noncomputable def PRE_first_tail_x15_r0_body.fx1_38 : PTrie Unit := (Host.Ts.Sim.Full.freedOf PRE_first_tail_x15_r0_body.s374.ffi).getD PTrie.nil
noncomputable def PRE_first_tail_x15_r0_body.kr1_38 : Host.Load.Layers.KRec := (Host.Ts.Sim.Full.krecOf PRE_first_tail_x15_r0_body.s374.ffi).getD Host.Load.Layers.KRec.empty
kernel_rfl PRE_first_tail_x15_r0_body.ofx1_38 : (Host.Ts.Sim.Full.freedOf PRE_first_tail_x15_r0_body.s374.ffi) = some PRE_first_tail_x15_r0_body.fx1_38
kernel_rfl PRE_first_tail_x15_r0_body.okr1_38 : (Host.Ts.Sim.Full.krecOf PRE_first_tail_x15_r0_body.s374.ffi) = some PRE_first_tail_x15_r0_body.kr1_38
kernel_rfl PRE_first_tail_x15_r0_body.ff038 : PRE_first_tail_x15_r0_body.fx0_38 = Stage.setAll PRE_first_tail_x15_r0_body.fxC_38 (PRE_first_tail_x15_r0_body.clo38.filterMap fun i => (PRE_first_tail_x15_r0_body.fx0_38.get i).map (i, ·))
kernel_rfl PRE_first_tail_x15_r0_body.ff138 : PRE_first_tail_x15_r0_body.fx1_38 = Stage.setAll PRE_first_tail_x15_r0_body.fxC_38 (PRE_first_tail_x15_r0_body.cwS38.filterMap fun i => (PRE_first_tail_x15_r0_body.fx1_38.get i).map (i, ·))
kernel_rfl PRE_first_tail_x15_r0_body.ffck38 : freedLB PRE_first_tail_x15_r0_body.kappa38 PRE_first_tail_x15_r0_body.cx0_38.mlx PRE_first_tail_x15_r0_body.fx0_38 PRE_first_tail_x15_r0_body.fx1_38 PRE_first_tail_x15_r0_body.clo38 = true
kernel_rfl PRE_first_tail_x15_r0_body.fkf038 : PRE_first_tail_x15_r0_body.kr0_38.flags = Stage.setAll PRE_first_tail_x15_r0_body.krC_38.flags (PRE_first_tail_x15_r0_body.clo38.filterMap fun i => (PRE_first_tail_x15_r0_body.kr0_38.flags.get i).map (i, ·))
kernel_rfl PRE_first_tail_x15_r0_body.fkt038 : PRE_first_tail_x15_r0_body.kr0_38.targs = Stage.setAll PRE_first_tail_x15_r0_body.krC_38.targs (PRE_first_tail_x15_r0_body.clo38.filterMap fun i => (PRE_first_tail_x15_r0_body.kr0_38.targs.get i).map (i, ·))
kernel_rfl PRE_first_tail_x15_r0_body.fkf138 : PRE_first_tail_x15_r0_body.kr1_38.flags = Stage.setAll PRE_first_tail_x15_r0_body.krC_38.flags (PRE_first_tail_x15_r0_body.cwS38.filterMap fun i => (PRE_first_tail_x15_r0_body.kr1_38.flags.get i).map (i, ·))
kernel_rfl PRE_first_tail_x15_r0_body.fkt138 : PRE_first_tail_x15_r0_body.kr1_38.targs = Stage.setAll PRE_first_tail_x15_r0_body.krC_38.targs (PRE_first_tail_x15_r0_body.cwS38.filterMap fun i => (PRE_first_tail_x15_r0_body.kr1_38.targs.get i).map (i, ·))
kernel_rfl PRE_first_tail_x15_r0_body.fkck38 : krecLB PRE_first_tail_x15_r0_body.kappa38 1678 PRE_first_tail_x15_r0_body.cx0_38.mlx PRE_first_tail_x15_r0_body.kr0_38 PRE_first_tail_x15_r0_body.kr1_38 PRE_first_tail_x15_r0_body.clo38 = true
kernel_rfl PRE_first_tail_x15_r0_body.fkn38 : Nat.ble 1678 1678 = true
-- the bridge and the pending traces' regions
kernel_rfl PRE_first_tail_x15_r0_body.cbridge38 : Host.Ts.Sim.Full.bridgeOf PRE_first_tail_x15_r0_body.s374.ffi = Host.Ts.Sim.Full.bridgeOf PRE_first_tail_x15_r0_body.s375.ffi
kernel_rfl PRE_first_tail_x15_r0_body.cpendR38 : pendRegB PRE_first_tail_x15_r0_body.kappa38 (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s375.ffi).mlx = true
kernel_rfl PRE_first_tail_x15_r0_body.cpendLe38 : Nat.ble (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s375.ffi).mlx.next (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s374.ffi).mlx.next = true
/-- **The compaction's native shift**, given the call's bookkeeping, its relation's facts (the model's and the
observers') and the canonical closedness. -/
theorem PRE_first_tail_x15_r0_body.cshift38 (clean : Conv.NClean (⟨18947, 16033, 2704487, 1678⟩ : Conv.Cnt) (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s373.ffi).mlx) (hltC : ∀ h, PH (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s373.ffi).mlx h → h < (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s373.ffi).mlx.next) (nltC : ∀ i, PN (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s373.ffi).mlx i → i < (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s373.ffi).mlx.nnext) (itemsC : ∀ k v, (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s373.ffi).mlx.items.get k = some v → PN (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s373.ffi).mlx k) (tracedC : ∀ h o, (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s373.ffi).mlx.objs.get h = some o → ∀ i ∈ objTraces o, i < PRE_first_tail_x15_r0_body.P38.NL) (cl : SSt (· < 1678) PRE_first_tail_x15_r0_body.cx0_38.mlx)
    (hobjC : ∀ h, PRE_first_tail_x15_r0_body.fxC_38.get h = some () → ((Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s373.ffi).mlx.objs.get h).isSome = true)
    (hfC : ∀ h, (PRE_first_tail_x15_r0_body.krC_38.flags.get h).isSome = true → ((Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s373.ffi).mlx.objs.get h).isSome = true)
    (htC : ∀ h, (PRE_first_tail_x15_r0_body.krC_38.targs.get h).isSome = true → ((Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s373.ffi).mlx.objs.get h).isSome = true)
    (hclC : ∀ h l, PRE_first_tail_x15_r0_body.krC_38.targs.get h = some l → Host.Ts.Sim.Full.STargs (· < (⟨18947, 16033, 2704487, 1678⟩ : Conv.Cnt).n) l) :
    Conv.FullShiftQ PRE_first_tail_x15_r0_body.P38 1678 PRE_first_tail_x15_r0_body.kappa38 PRE_first_tail_x15_r0_body.s375.ffi PRE_first_tail_x15_r0_body.s374.ffi :=
  ⟨PRE_first_tail_x15_r0_body.cnshift38 clean hltC nltC itemsC tracedC cl, PRE_first_tail_x15_r0_body.cqueue38, fun t ht => bSN_sound (List.all_eq_true.mp PRE_first_tail_x15_r0_body.ctokSupp38 t ht),
    PRE_first_tail_x15_r0_body.cbridge38,
    liveShift_foot (x0' := Host.Ts.Sim.Full.mlxOf PRE_first_tail_x15_r0_body.s375.ffi) (x1' := Host.Ts.Sim.Full.mlxOf PRE_first_tail_x15_r0_body.s374.ffi) (PRE_first_tail_x15_r0_body.cfoot38 clean hltC nltC itemsC tracedC cl) rfl PRE_first_tail_x15_r0_body.ofx0_38 PRE_first_tail_x15_r0_body.ofx1_38 hobjC PRE_first_tail_x15_r0_body.ff038 PRE_first_tail_x15_r0_body.ff138 PRE_first_tail_x15_r0_body.ffck38,
    kernShift_foot (x0' := Host.Ts.Sim.Full.mlxOf PRE_first_tail_x15_r0_body.s375.ffi) (x1' := Host.Ts.Sim.Full.mlxOf PRE_first_tail_x15_r0_body.s374.ffi) (PRE_first_tail_x15_r0_body.cfoot38 clean hltC nltC itemsC tracedC cl) rfl PRE_first_tail_x15_r0_body.okr0_38 PRE_first_tail_x15_r0_body.okr1_38 (Nat.le_of_ble_eq_true PRE_first_tail_x15_r0_body.fkn38) hfC htC hclC
      PRE_first_tail_x15_r0_body.fkf038 PRE_first_tail_x15_r0_body.fkt038 PRE_first_tail_x15_r0_body.fkf138 PRE_first_tail_x15_r0_body.fkt138 PRE_first_tail_x15_r0_body.fkck38,
    pendReg_of rfl PRE_first_tail_x15_r0_body.cnh038 PRE_first_tail_x15_r0_body.cnh138 (Nat.le_of_ble_eq_true PRE_first_tail_x15_r0_body.cpendLe38) PRE_first_tail_x15_r0_body.cpendR38⟩

end Host.Load.Run.Tpl
