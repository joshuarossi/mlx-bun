import host.sim.template.a4pre_first_tail_x15_r0_body.SiteCl39
import host.sim.conv.CompactFull
import host.sim.template.FootGen
set_option Elab.async false
namespace Host.Load.Run.Tpl
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
open Host.Ts Host.Ts.Sim Host.Ts.Sim.Template

/-! The compaction's native shift at call site 39 from its footprint (`Conv.nshift_of_foot`), and the observers'
(`liveShift_foot`, `kernShift_foot`): `Conv.FullShiftQ` for `Conv.full_compactQ`, given the call's bookkeeping and its
relation's facts. -/

/-- The load parameters of the chain (band-free: its start's node counter as `NL` and `N0`). -/
def PRE_first_tail_x15_r0_body.Pc39 : LoadP := ⟨18151, 131072, 1099511627776, 15235, 15235, []⟩
/-- The site's band raised to the map's checked fixed-node prefix, including newly recorded closure traces. -/
def PRE_first_tail_x15_r0_body.P39 : LoadP := PRE_first_tail_x15_r0_body.Pc39.raise 16079
kernel_rfl PRE_first_tail_x15_r0_body.craise39 : Nat.ble PRE_first_tail_x15_r0_body.Pc39.N0 16079 = true
theorem PRE_first_tail_x15_r0_body.raised39 : Host.Ts.Sim.Full.Raised PRE_first_tail_x15_r0_body.Pc39 PRE_first_tail_x15_r0_body.P39 :=
  .inr ⟨16079, rfl, Nat.le_of_ble_eq_true PRE_first_tail_x15_r0_body.craise39, rfl⟩
noncomputable abbrev PRE_first_tail_x15_r0_body.cx0_39 : Host.Load.LSt := clearTokens (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s358.ffi)
noncomputable abbrev PRE_first_tail_x15_r0_body.cx1_39 : Host.Load.LSt := clearTokens (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s357.ffi)
def PRE_first_tail_x15_r0_body.khinv39 : PTrie Nat := Stage.setAll PTrie.nil [(19007, 18981), (18985, 18982), (19008, 18983)]
def PRE_first_tail_x15_r0_body.kninv39 : PTrie Nat := Stage.setAll PTrie.nil [(16052, 16052), (16053, 16053), (16054, 16054), (16055, 16055), (16056, 16056), (16057, 16057), (16058, 16058), (16059, 16059), (16060, 16060), (16061, 16061), (16062, 16062), (16063, 16063), (16064, 16064), (16065, 16065), (16066, 16066), (16067, 16067), (16068, 16068), (16069, 16069), (16070, 16070), (16071, 16071), (16072, 16072), (16073, 16073), (16074, 16074), (16075, 16075), (16076, 16076), (16077, 16077), (16078, 16078)]
/-- The stage's footprint: its written and fresh handles, fresh nodes, written and fresh items. -/
def PRE_first_tail_x15_r0_body.cwS39 : List Nat := [18961, 18974, 18980, 18981, 18982, 18983, 18984, 18985, 18986, 18987, 18988, 18989, 18990, 18991, 18992, 18993, 18994, 18995, 18996, 18997, 18998, 18999, 19000, 19001, 19002, 19003, 19004, 19005, 19006, 19007, 19008]
def PRE_first_tail_x15_r0_body.cnS39 : List Nat := List.range' 16052 27
def PRE_first_tail_x15_r0_body.ciS39 : List Nat := [] ++ List.range' 16052 27

-- the small checks (`MChecks`'s)
kernel_rfl PRE_first_tail_x15_r0_body.cnh039 : PRE_first_tail_x15_r0_body.kd39.nh0 = PRE_first_tail_x15_r0_body.cx0_39.mlx.next
kernel_rfl PRE_first_tail_x15_r0_body.cnh139 : PRE_first_tail_x15_r0_body.kd39.nh1 = PRE_first_tail_x15_r0_body.cx1_39.mlx.next
kernel_rfl PRE_first_tail_x15_r0_body.cnn039 : PRE_first_tail_x15_r0_body.kd39.nn0 = PRE_first_tail_x15_r0_body.cx0_39.mlx.nnext
kernel_rfl PRE_first_tail_x15_r0_body.cnn139 : PRE_first_tail_x15_r0_body.kd39.nn1 = PRE_first_tail_x15_r0_body.cx1_39.mlx.nnext
kernel_rfl PRE_first_tail_x15_r0_body.cplo39 : (Nat.blt 0 PRE_first_tail_x15_r0_body.P39.lo && Nat.ble PRE_first_tail_x15_r0_body.P39.lo PRE_first_tail_x15_r0_body.cx0_39.mlx.next && Nat.ble PRE_first_tail_x15_r0_body.P39.lo RData.bigHi && Nat.ble RData.bigHi PRE_first_tail_x15_r0_body.P39.E) = true
kernel_rfl PRE_first_tail_x15_r0_body.ccnt39 : (Nat.ble PRE_first_tail_x15_r0_body.cx0_39.mlx.next PRE_first_tail_x15_r0_body.cx1_39.mlx.next && Nat.ble PRE_first_tail_x15_r0_body.cx0_39.mlx.nnext PRE_first_tail_x15_r0_body.cx1_39.mlx.nnext) = true
kernel_rfl PRE_first_tail_x15_r0_body.cnband39 : (Nat.blt 0 PRE_first_tail_x15_r0_body.P39.NL && Nat.ble PRE_first_tail_x15_r0_body.P39.NL PRE_first_tail_x15_r0_body.P39.N0 && Nat.ble PRE_first_tail_x15_r0_body.P39.N0 PRE_first_tail_x15_r0_body.cx0_39.mlx.nnext) = true
kernel_rfl PRE_first_tail_x15_r0_body.chbelow39 : PRE_first_tail_x15_r0_body.kd39.checkHndBelow = true
kernel_rfl PRE_first_tail_x15_r0_body.chren39 : checkRenG PRE_first_tail_x15_r0_body.kd39.hnd PRE_first_tail_x15_r0_body.khinv39 (phB PRE_first_tail_x15_r0_body.cx0_39.mlx) = true
kernel_rfl PRE_first_tail_x15_r0_body.cband39 : PRE_first_tail_x15_r0_body.kd39.checkBand PRE_first_tail_x15_r0_body.P39.lo = true
kernel_rfl PRE_first_tail_x15_r0_body.cnh1pos39 : Nat.blt 0 PRE_first_tail_x15_r0_body.kd39.nh1 = true
kernel_rfl PRE_first_tail_x15_r0_body.cnren39 : checkRenG PRE_first_tail_x15_r0_body.kd39.node PRE_first_tail_x15_r0_body.kninv39 (pnB PRE_first_tail_x15_r0_body.cx0_39.mlx) = true
kernel_rfl PRE_first_tail_x15_r0_body.cnlow39 : (PTrie.keysA PRE_first_tail_x15_r0_body.kd39.node).all (fun j => Nat.ble PRE_first_tail_x15_r0_body.P39.NL j && Nat.blt (PRE_first_tail_x15_r0_body.kd39.nodeF j) PRE_first_tail_x15_r0_body.cx1_39.mlx.nnext) = true
kernel_rfl PRE_first_tail_x15_r0_body.cabs0a39 : PRE_first_tail_x15_r0_body.cx0_39.mlx.arrs.get 0 = none
kernel_rfl PRE_first_tail_x15_r0_body.cabs0b39 : PRE_first_tail_x15_r0_body.cx0_39.mlx.objs.get 0 = none
kernel_rfl PRE_first_tail_x15_r0_body.ctok139 : PRE_first_tail_x15_r0_body.cx1_39.mlx.tokens = []
kernel_rfl PRE_first_tail_x15_r0_body.cpend39 : PRE_first_tail_x15_r0_body.cx1_39.mlx.pending = PRE_first_tail_x15_r0_body.cx0_39.mlx.pending.map PRE_first_tail_x15_r0_body.kappa39.pend
kernel_rfl PRE_first_tail_x15_r0_body.cerrh39 : PRE_first_tail_x15_r0_body.cx1_39.mlx.errh = PRE_first_tail_x15_r0_body.cx0_39.mlx.errh.map PRE_first_tail_x15_r0_body.kappa39.arg
kernel_rfl PRE_first_tail_x15_r0_body.cfiles39 : PRE_first_tail_x15_r0_body.cx1_39.mlx.files = PRE_first_tail_x15_r0_body.cx0_39.mlx.files
kernel_rfl PRE_first_tail_x15_r0_body.carch39 : PRE_first_tail_x15_r0_body.cx1_39.mlx.arch = PRE_first_tail_x15_r0_body.cx0_39.mlx.arch
kernel_rfl PRE_first_tail_x15_r0_body.csizes39 : PRE_first_tail_x15_r0_body.cx1_39.mlx.deviceSizes = PRE_first_tail_x15_r0_body.cx0_39.mlx.deviceSizes
kernel_rfl PRE_first_tail_x15_r0_body.cwired39 : PRE_first_tail_x15_r0_body.cx1_39.mlx.wired = PRE_first_tail_x15_r0_body.cx0_39.mlx.wired
kernel_rfl PRE_first_tail_x15_r0_body.chost39 : PRE_first_tail_x15_r0_body.cx1_39.host = PRE_first_tail_x15_r0_body.cx0_39.host
-- the compaction map's addresses are `PRE_first_tail_x15_r0_body.kd39`'s
kernel_rfl PRE_first_tail_x15_r0_body.ckn039 : PRE_first_tail_x15_r0_body.kd39.n0 = 2705965
kernel_rfl PRE_first_tail_x15_r0_body.ckn139 : PRE_first_tail_x15_r0_body.kd39.n1 = 2707114
kernel_rfl PRE_first_tail_x15_r0_body.ckheap39 : (PTrie.keysA PRE_first_tail_x15_r0_body.kd39.heap).all (fun x => Nat.ble 2705959 x) = true
kernel_rfl PRE_first_tail_x15_r0_body.ckpl39 : (List.range 6).all (fun j => decide (PRE_first_tail_x15_r0_body.kd39.heap.get (2705959 + j) = nth? PRE_first_tail_x15_r0_body.pl39 j)) = true
-- the map fixes the call's names (`Conv.fixOld_compact`), the call's counters
kernel_rfl PRE_first_tail_x15_r0_body.fja39 : Nat.ble 2705959 2705959 = true
kernel_rfl PRE_first_tail_x15_r0_body.fn39 : Nat.ble 1751 1751 = true
kernel_rfl PRE_first_tail_x15_r0_body.fjaD39 : Nat.ble 2705959 PRE_first_tail_x15_r0_body.kd39.n0 = true
kernel_rfl PRE_first_tail_x15_r0_body.fxn39 : Nat.ble 18981 PRE_first_tail_x15_r0_body.kd39.nh0 = true
kernel_rfl PRE_first_tail_x15_r0_body.fnn39 : Nat.ble 16052 PRE_first_tail_x15_r0_body.kd39.nn0 = true
kernel_rfl PRE_first_tail_x15_r0_body.fxb39 : Nat.ble 18981 RData.bigHi = true
kernel_rfl PRE_first_tail_x15_r0_body.fheap39 : (PTrie.keysA PRE_first_tail_x15_r0_body.kd39.heap).all (Nat.ble (⟨18981, 16052, 2705959, 1751⟩ : Conv.Cnt).ja) = true
kernel_rfl PRE_first_tail_x15_r0_body.fhnd39 : (PTrie.keysA PRE_first_tail_x15_r0_body.kd39.hnd).all (Nat.ble (⟨18981, 16052, 2705959, 1751⟩ : Conv.Cnt).xn) = true
kernel_rfl PRE_first_tail_x15_r0_body.fnode39 : (PTrie.keysA PRE_first_tail_x15_r0_body.kd39.node).all (Nat.ble (⟨18981, 16052, 2705959, 1751⟩ : Conv.Cnt).nn) = true
/-- The compaction map fixes the call's names. -/
theorem PRE_first_tail_x15_r0_body.cfix39 : Conv.FixOld (⟨18981, 16052, 2705959, 1751⟩ : Conv.Cnt) PRE_first_tail_x15_r0_body.kappa39 :=
  Conv.fixOld_compact (Nat.le_of_ble_eq_true PRE_first_tail_x15_r0_body.fja39) (Nat.le_of_ble_eq_true PRE_first_tail_x15_r0_body.fn39) (Nat.le_of_ble_eq_true PRE_first_tail_x15_r0_body.fjaD39) (Nat.le_of_ble_eq_true PRE_first_tail_x15_r0_body.fxn39) (Nat.le_of_ble_eq_true PRE_first_tail_x15_r0_body.fnn39) (Nat.le_of_ble_eq_true PRE_first_tail_x15_r0_body.fxb39) PRE_first_tail_x15_r0_body.fheap39 PRE_first_tail_x15_r0_body.fhnd39 PRE_first_tail_x15_r0_body.fnode39
kernel_rfl PRE_first_tail_x15_r0_body.fcxn39 : (⟨18981, 16052, 2705959, 1751⟩ : Conv.Cnt).xn = (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s356.ffi).mlx.next
kernel_rfl PRE_first_tail_x15_r0_body.fcnn39 : (⟨18981, 16052, 2705959, 1751⟩ : Conv.Cnt).nn = (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s356.ffi).mlx.nnext
kernel_rfl PRE_first_tail_x15_r0_body.fle039 : (Nat.ble (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s356.ffi).mlx.next PRE_first_tail_x15_r0_body.cx0_39.mlx.next && Nat.ble (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s356.ffi).mlx.nnext PRE_first_tail_x15_r0_body.cx0_39.mlx.nnext && Nat.ble (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s356.ffi).mlx.next RData.bigHi) = true
kernel_rfl PRE_first_tail_x15_r0_body.fnk39 : (PTrie.keysA PRE_first_tail_x15_r0_body.kd39.node).all (Nat.ble (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s356.ffi).mlx.nnext) = true
-- the merged state keeps the call's entries off the stage's footprint
kernel_rfl PRE_first_tail_x15_r0_body.f1A39 : PRE_first_tail_x15_r0_body.cx1_39.mlx.arrs = Stage.setAll (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s356.ffi).mlx.arrs (PRE_first_tail_x15_r0_body.cwS39.filterMap fun i => (PRE_first_tail_x15_r0_body.cx1_39.mlx.arrs.get i).map (i, ·))
kernel_rfl PRE_first_tail_x15_r0_body.f1O39 : PRE_first_tail_x15_r0_body.cx1_39.mlx.objs = Stage.setAll (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s356.ffi).mlx.objs (PRE_first_tail_x15_r0_body.cwS39.filterMap fun i => (PRE_first_tail_x15_r0_body.cx1_39.mlx.objs.get i).map (i, ·))
kernel_rfl PRE_first_tail_x15_r0_body.f1N39 : PRE_first_tail_x15_r0_body.cx1_39.mlx.nodes = Stage.setAll (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s356.ffi).mlx.nodes (PRE_first_tail_x15_r0_body.cnS39.filterMap fun i => (PRE_first_tail_x15_r0_body.cx1_39.mlx.nodes.get i).map (i, ·))
kernel_rfl PRE_first_tail_x15_r0_body.f1I39 : PRE_first_tail_x15_r0_body.cx1_39.mlx.items = Stage.setAll (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s356.ffi).mlx.items (PRE_first_tail_x15_r0_body.ciS39.filterMap fun i => (PRE_first_tail_x15_r0_body.cx1_39.mlx.items.get i).map (i, ·))
kernel_rfl PRE_first_tail_x15_r0_body.fbd39 : (PRE_first_tail_x15_r0_body.clo39 ++ PRE_first_tail_x15_r0_body.cln39 ++ PRE_first_tail_x15_r0_body.cli39 ++ PRE_first_tail_x15_r0_body.cwS39 ++ PRE_first_tail_x15_r0_body.cnS39 ++ PRE_first_tail_x15_r0_body.ciS39).all (fun i => Nat.blt (i / 4096) (4 ^ 31)) = true
kernel_rfl PRE_first_tail_x15_r0_body.fincW39 : PRE_first_tail_x15_r0_body.cwS39.all (fun h => !Nat.blt h (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s356.ffi).mlx.next || PRE_first_tail_x15_r0_body.clo39.contains h) = true
kernel_rfl PRE_first_tail_x15_r0_body.fincI39 : PRE_first_tail_x15_r0_body.ciS39.all (fun k => !Nat.blt k (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s356.ffi).mlx.nnext || PRE_first_tail_x15_r0_body.cli39.contains k) = true
kernel_rfl PRE_first_tail_x15_r0_body.fincN39 : PRE_first_tail_x15_r0_body.cnS39.all (Nat.ble (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s356.ffi).mlx.nnext) = true
kernel_rfl PRE_first_tail_x15_r0_body.flnF39 : PRE_first_tail_x15_r0_body.cln39.all (Nat.ble (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s356.ffi).mlx.nnext) = true
-- the checks over the changed lists
kernel_rfl PRE_first_tail_x15_r0_body.fh39 : PRE_first_tail_x15_r0_body.clo39.all (handleOK PRE_first_tail_x15_r0_body.kappa39 PRE_first_tail_x15_r0_body.P39.lo PRE_first_tail_x15_r0_body.cx0_39.mlx PRE_first_tail_x15_r0_body.cx1_39.mlx) = true
kernel_rfl PRE_first_tail_x15_r0_body.fo39 : PRE_first_tail_x15_r0_body.clo39.map (fun h => PRE_first_tail_x15_r0_body.cx1_39.mlx.objs.get (PRE_first_tail_x15_r0_body.kappa39.handle h)) = PRE_first_tail_x15_r0_body.clo39.map (fun h => (PRE_first_tail_x15_r0_body.cx0_39.mlx.objs.get h).map PRE_first_tail_x15_r0_body.kappa39.nobj)
kernel_rfl PRE_first_tail_x15_r0_body.fok39 : PRE_first_tail_x15_r0_body.clo39.all (objOK PRE_first_tail_x15_r0_body.kappa39 PRE_first_tail_x15_r0_body.P39.NL PRE_first_tail_x15_r0_body.cx0_39.mlx) = true
kernel_rfl PRE_first_tail_x15_r0_body.fnd39 : PRE_first_tail_x15_r0_body.cln39.all (nodeOKF PRE_first_tail_x15_r0_body.kappa39 PRE_first_tail_x15_r0_body.P39 PRE_first_tail_x15_r0_body.cx0_39.mlx PRE_first_tail_x15_r0_body.cx1_39.mlx) = true
kernel_rfl PRE_first_tail_x15_r0_body.fp39 : ((PRE_first_tail_x15_r0_body.cln39.filter (fullB PRE_first_tail_x15_r0_body.P39))).map (fun i => (PRE_first_tail_x15_r0_body.cx1_39.mlx.nodes.get (PRE_first_tail_x15_r0_body.kappa39.node i)).map Host.Mlx.Ffi.Node.prim) =
  ((PRE_first_tail_x15_r0_body.cln39.filter (fullB PRE_first_tail_x15_r0_body.P39))).map (fun i => (PRE_first_tail_x15_r0_body.cx0_39.mlx.nodes.get i).map fun nd => PRE_first_tail_x15_r0_body.kappa39.prim nd.prim)
kernel_rfl PRE_first_tail_x15_r0_body.fnordI39 : incrB PRE_first_tail_x15_r0_body.kd39.nodeF (List.range' 16052 27) = true
kernel_rfl PRE_first_tail_x15_r0_body.fnordK39 : (PTrie.keysA PRE_first_tail_x15_r0_body.kd39.node).all (fun k => Nat.ble 16052 k && Nat.blt k 16079) = true
kernel_rfl PRE_first_tail_x15_r0_body.fnordL39 : (PRE_first_tail_x15_r0_body.cln39.filter (Nat.ble PRE_first_tail_x15_r0_body.P39.N0)).all (fun i => Nat.ble i (PRE_first_tail_x15_r0_body.kd39.nodeF i) && (Nat.blt i 16079 || Nat.ble PRE_first_tail_x15_r0_body.kd39.nn0 i)) = true
theorem PRE_first_tail_x15_r0_body.fnord39 : (PRE_first_tail_x15_r0_body.cln39.filter (Nat.ble PRE_first_tail_x15_r0_body.P39.N0)).all (fun i => Nat.ble i (PRE_first_tail_x15_r0_body.kd39.nodeF i) &&
    (PTrie.keysA PRE_first_tail_x15_r0_body.kd39.node).all fun j => !Nat.blt j i || Nat.blt (PRE_first_tail_x15_r0_body.kd39.nodeF j) (PRE_first_tail_x15_r0_body.kd39.nodeF i)) = true :=
  cnord_of PRE_first_tail_x15_r0_body.cnlow39 PRE_first_tail_x15_r0_body.cnn139 PRE_first_tail_x15_r0_body.fnordI39 PRE_first_tail_x15_r0_body.fnordK39 PRE_first_tail_x15_r0_body.fnordL39
kernel_rfl PRE_first_tail_x15_r0_body.fi39 : PRE_first_tail_x15_r0_body.cli39.all (pnB PRE_first_tail_x15_r0_body.cx0_39.mlx) = true
kernel_rfl PRE_first_tail_x15_r0_body.fii39 : PRE_first_tail_x15_r0_body.cli39.all (fun k => decide (PRE_first_tail_x15_r0_body.cx1_39.mlx.items.get (PRE_first_tail_x15_r0_body.kappa39.node k) = (PRE_first_tail_x15_r0_body.cx0_39.mlx.items.get k).map PRE_first_tail_x15_r0_body.kappa39.nv)) = true
/-- **The compaction's footprint.** -/
theorem PRE_first_tail_x15_r0_body.cfoot39 (clean : Conv.NClean (⟨18981, 16052, 2705959, 1751⟩ : Conv.Cnt) (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s356.ffi).mlx) (hltC : ∀ h, PH (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s356.ffi).mlx h → h < (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s356.ffi).mlx.next) (nltC : ∀ i, PN (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s356.ffi).mlx i → i < (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s356.ffi).mlx.nnext) (itemsC : ∀ k v, (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s356.ffi).mlx.items.get k = some v → PN (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s356.ffi).mlx k) (tracedC : ∀ h o, (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s356.ffi).mlx.objs.get h = some o → ∀ i ∈ objTraces o, i < PRE_first_tail_x15_r0_body.P39.NL) (cl : SSt (· < 1769) PRE_first_tail_x15_r0_body.cx0_39.mlx) :
    Conv.MFoot PRE_first_tail_x15_r0_body.P39 1769 PRE_first_tail_x15_r0_body.kappa39 PRE_first_tail_x15_r0_body.kd39 PRE_first_tail_x15_r0_body.khinv39 PRE_first_tail_x15_r0_body.kninv39 (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s356.ffi).mlx PRE_first_tail_x15_r0_body.cx0_39.mlx PRE_first_tail_x15_r0_body.cx1_39.mlx (⟨18981, 16052, 2705959, 1751⟩ : Conv.Cnt) PRE_first_tail_x15_r0_body.clo39 PRE_first_tail_x15_r0_body.cln39 PRE_first_tail_x15_r0_body.cli39 PRE_first_tail_x15_r0_body.cwS39 PRE_first_tail_x15_r0_body.cnS39 PRE_first_tail_x15_r0_body.ciS39 :=
  ⟨rfl, rfl, rfl, PRE_first_tail_x15_r0_body.cnh039, PRE_first_tail_x15_r0_body.cnh139, PRE_first_tail_x15_r0_body.cnn039, PRE_first_tail_x15_r0_body.cnn139, PRE_first_tail_x15_r0_body.cplo39, PRE_first_tail_x15_r0_body.ccnt39, PRE_first_tail_x15_r0_body.cnband39, PRE_first_tail_x15_r0_body.chbelow39, PRE_first_tail_x15_r0_body.chren39, PRE_first_tail_x15_r0_body.cband39, PRE_first_tail_x15_r0_body.cnh1pos39, PRE_first_tail_x15_r0_body.cnren39, PRE_first_tail_x15_r0_body.cnlow39, PRE_first_tail_x15_r0_body.cabs0a39, PRE_first_tail_x15_r0_body.cabs0b39, PRE_first_tail_x15_r0_body.ctok139, PRE_first_tail_x15_r0_body.cpend39, PRE_first_tail_x15_r0_body.cerrh39, PRE_first_tail_x15_r0_body.cfiles39, PRE_first_tail_x15_r0_body.carch39, PRE_first_tail_x15_r0_body.csizes39, PRE_first_tail_x15_r0_body.cwired39, PRE_first_tail_x15_r0_body.cfix39, clean, PRE_first_tail_x15_r0_body.fcxn39, PRE_first_tail_x15_r0_body.fcnn39, hltC, nltC, itemsC, tracedC, cl, PRE_first_tail_x15_r0_body.fle039, PRE_first_tail_x15_r0_body.fnk39, PRE_first_tail_x15_r0_body.ckA39, PRE_first_tail_x15_r0_body.cobjsK39, PRE_first_tail_x15_r0_body.cnodesK39, PRE_first_tail_x15_r0_body.citemsK39, PRE_first_tail_x15_r0_body.f1A39, PRE_first_tail_x15_r0_body.f1O39, PRE_first_tail_x15_r0_body.f1N39, PRE_first_tail_x15_r0_body.f1I39, PRE_first_tail_x15_r0_body.fbd39, PRE_first_tail_x15_r0_body.fincW39, PRE_first_tail_x15_r0_body.fincI39, PRE_first_tail_x15_r0_body.fincN39, PRE_first_tail_x15_r0_body.flnF39, PRE_first_tail_x15_r0_body.fh39, PRE_first_tail_x15_r0_body.fo39, PRE_first_tail_x15_r0_body.fok39, PRE_first_tail_x15_r0_body.fnd39, PRE_first_tail_x15_r0_body.fp39, PRE_first_tail_x15_r0_body.fnord39, PRE_first_tail_x15_r0_body.fi39, PRE_first_tail_x15_r0_body.fii39⟩
theorem PRE_first_tail_x15_r0_body.cnshift39 (clean : Conv.NClean (⟨18981, 16052, 2705959, 1751⟩ : Conv.Cnt) (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s356.ffi).mlx) (hltC : ∀ h, PH (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s356.ffi).mlx h → h < (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s356.ffi).mlx.next) (nltC : ∀ i, PN (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s356.ffi).mlx i → i < (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s356.ffi).mlx.nnext) (itemsC : ∀ k v, (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s356.ffi).mlx.items.get k = some v → PN (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s356.ffi).mlx k) (tracedC : ∀ h o, (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s356.ffi).mlx.objs.get h = some o → ∀ i ∈ objTraces o, i < PRE_first_tail_x15_r0_body.P39.NL) (cl : SSt (· < 1769) PRE_first_tail_x15_r0_body.cx0_39.mlx) : NShift PRE_first_tail_x15_r0_body.P39 1769 PRE_first_tail_x15_r0_body.kappa39 PRE_first_tail_x15_r0_body.cx0_39 PRE_first_tail_x15_r0_body.cx1_39 :=
  Conv.nshift_of_foot (PRE_first_tail_x15_r0_body.cfoot39 clean hltC nltC itemsC tracedC cl) PRE_first_tail_x15_r0_body.chost39 (compact_a_eq PRE_first_tail_x15_r0_body.ckn039 PRE_first_tail_x15_r0_body.ckn139 PRE_first_tail_x15_r0_body.ckheap39 PRE_first_tail_x15_r0_body.ckpl39)

-- the observers: the layers' states at the call, the canonical and the merged state, their footprints and checks
noncomputable def PRE_first_tail_x15_r0_body.fxC_39 : PTrie Unit := (Host.Ts.Sim.Full.freedOf PRE_first_tail_x15_r0_body.s356.ffi).getD PTrie.nil
noncomputable def PRE_first_tail_x15_r0_body.krC_39 : Host.Load.Layers.KRec := (Host.Ts.Sim.Full.krecOf PRE_first_tail_x15_r0_body.s356.ffi).getD Host.Load.Layers.KRec.empty
kernel_rfl PRE_first_tail_x15_r0_body.ofxC_39 : (Host.Ts.Sim.Full.freedOf PRE_first_tail_x15_r0_body.s356.ffi) = some PRE_first_tail_x15_r0_body.fxC_39
kernel_rfl PRE_first_tail_x15_r0_body.okrC_39 : (Host.Ts.Sim.Full.krecOf PRE_first_tail_x15_r0_body.s356.ffi) = some PRE_first_tail_x15_r0_body.krC_39
noncomputable def PRE_first_tail_x15_r0_body.fx0_39 : PTrie Unit := (Host.Ts.Sim.Full.freedOf PRE_first_tail_x15_r0_body.s358.ffi).getD PTrie.nil
noncomputable def PRE_first_tail_x15_r0_body.kr0_39 : Host.Load.Layers.KRec := (Host.Ts.Sim.Full.krecOf PRE_first_tail_x15_r0_body.s358.ffi).getD Host.Load.Layers.KRec.empty
kernel_rfl PRE_first_tail_x15_r0_body.ofx0_39 : (Host.Ts.Sim.Full.freedOf PRE_first_tail_x15_r0_body.s358.ffi) = some PRE_first_tail_x15_r0_body.fx0_39
kernel_rfl PRE_first_tail_x15_r0_body.okr0_39 : (Host.Ts.Sim.Full.krecOf PRE_first_tail_x15_r0_body.s358.ffi) = some PRE_first_tail_x15_r0_body.kr0_39
noncomputable def PRE_first_tail_x15_r0_body.fx1_39 : PTrie Unit := (Host.Ts.Sim.Full.freedOf PRE_first_tail_x15_r0_body.s357.ffi).getD PTrie.nil
noncomputable def PRE_first_tail_x15_r0_body.kr1_39 : Host.Load.Layers.KRec := (Host.Ts.Sim.Full.krecOf PRE_first_tail_x15_r0_body.s357.ffi).getD Host.Load.Layers.KRec.empty
kernel_rfl PRE_first_tail_x15_r0_body.ofx1_39 : (Host.Ts.Sim.Full.freedOf PRE_first_tail_x15_r0_body.s357.ffi) = some PRE_first_tail_x15_r0_body.fx1_39
kernel_rfl PRE_first_tail_x15_r0_body.okr1_39 : (Host.Ts.Sim.Full.krecOf PRE_first_tail_x15_r0_body.s357.ffi) = some PRE_first_tail_x15_r0_body.kr1_39
kernel_rfl PRE_first_tail_x15_r0_body.ff039 : PRE_first_tail_x15_r0_body.fx0_39 = Stage.setAll PRE_first_tail_x15_r0_body.fxC_39 (PRE_first_tail_x15_r0_body.clo39.filterMap fun i => (PRE_first_tail_x15_r0_body.fx0_39.get i).map (i, ·))
kernel_rfl PRE_first_tail_x15_r0_body.ff139 : PRE_first_tail_x15_r0_body.fx1_39 = Stage.setAll PRE_first_tail_x15_r0_body.fxC_39 (PRE_first_tail_x15_r0_body.cwS39.filterMap fun i => (PRE_first_tail_x15_r0_body.fx1_39.get i).map (i, ·))
kernel_rfl PRE_first_tail_x15_r0_body.ffck39 : freedLB PRE_first_tail_x15_r0_body.kappa39 PRE_first_tail_x15_r0_body.cx0_39.mlx PRE_first_tail_x15_r0_body.fx0_39 PRE_first_tail_x15_r0_body.fx1_39 PRE_first_tail_x15_r0_body.clo39 = true
kernel_rfl PRE_first_tail_x15_r0_body.fkf039 : PRE_first_tail_x15_r0_body.kr0_39.flags = Stage.setAll PRE_first_tail_x15_r0_body.krC_39.flags (PRE_first_tail_x15_r0_body.clo39.filterMap fun i => (PRE_first_tail_x15_r0_body.kr0_39.flags.get i).map (i, ·))
kernel_rfl PRE_first_tail_x15_r0_body.fkt039 : PRE_first_tail_x15_r0_body.kr0_39.targs = Stage.setAll PRE_first_tail_x15_r0_body.krC_39.targs (PRE_first_tail_x15_r0_body.clo39.filterMap fun i => (PRE_first_tail_x15_r0_body.kr0_39.targs.get i).map (i, ·))
kernel_rfl PRE_first_tail_x15_r0_body.fkf139 : PRE_first_tail_x15_r0_body.kr1_39.flags = Stage.setAll PRE_first_tail_x15_r0_body.krC_39.flags (PRE_first_tail_x15_r0_body.cwS39.filterMap fun i => (PRE_first_tail_x15_r0_body.kr1_39.flags.get i).map (i, ·))
kernel_rfl PRE_first_tail_x15_r0_body.fkt139 : PRE_first_tail_x15_r0_body.kr1_39.targs = Stage.setAll PRE_first_tail_x15_r0_body.krC_39.targs (PRE_first_tail_x15_r0_body.cwS39.filterMap fun i => (PRE_first_tail_x15_r0_body.kr1_39.targs.get i).map (i, ·))
kernel_rfl PRE_first_tail_x15_r0_body.fkck39 : krecLB PRE_first_tail_x15_r0_body.kappa39 1769 PRE_first_tail_x15_r0_body.cx0_39.mlx PRE_first_tail_x15_r0_body.kr0_39 PRE_first_tail_x15_r0_body.kr1_39 PRE_first_tail_x15_r0_body.clo39 = true
kernel_rfl PRE_first_tail_x15_r0_body.fkn39 : Nat.ble 1751 1769 = true
-- the bridge and the pending traces' regions
kernel_rfl PRE_first_tail_x15_r0_body.cbridge39 : Host.Ts.Sim.Full.bridgeOf PRE_first_tail_x15_r0_body.s357.ffi = Host.Ts.Sim.Full.bridgeOf PRE_first_tail_x15_r0_body.s358.ffi
kernel_rfl PRE_first_tail_x15_r0_body.cpendR39 : pendRegB PRE_first_tail_x15_r0_body.kappa39 (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s358.ffi).mlx = true
kernel_rfl PRE_first_tail_x15_r0_body.cpendLe39 : Nat.ble (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s358.ffi).mlx.next (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s357.ffi).mlx.next = true
/-- **The compaction's native shift**, given the call's bookkeeping, its relation's facts (the model's and the
observers') and the canonical closedness. -/
theorem PRE_first_tail_x15_r0_body.cshift39 (clean : Conv.NClean (⟨18981, 16052, 2705959, 1751⟩ : Conv.Cnt) (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s356.ffi).mlx) (hltC : ∀ h, PH (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s356.ffi).mlx h → h < (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s356.ffi).mlx.next) (nltC : ∀ i, PN (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s356.ffi).mlx i → i < (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s356.ffi).mlx.nnext) (itemsC : ∀ k v, (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s356.ffi).mlx.items.get k = some v → PN (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s356.ffi).mlx k) (tracedC : ∀ h o, (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s356.ffi).mlx.objs.get h = some o → ∀ i ∈ objTraces o, i < PRE_first_tail_x15_r0_body.P39.NL) (cl : SSt (· < 1769) PRE_first_tail_x15_r0_body.cx0_39.mlx)
    (hobjC : ∀ h, PRE_first_tail_x15_r0_body.fxC_39.get h = some () → ((Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s356.ffi).mlx.objs.get h).isSome = true)
    (hfC : ∀ h, (PRE_first_tail_x15_r0_body.krC_39.flags.get h).isSome = true → ((Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s356.ffi).mlx.objs.get h).isSome = true)
    (htC : ∀ h, (PRE_first_tail_x15_r0_body.krC_39.targs.get h).isSome = true → ((Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s356.ffi).mlx.objs.get h).isSome = true)
    (hclC : ∀ h l, PRE_first_tail_x15_r0_body.krC_39.targs.get h = some l → Host.Ts.Sim.Full.STargs (· < (⟨18981, 16052, 2705959, 1751⟩ : Conv.Cnt).n) l) :
    Conv.FullShiftQ PRE_first_tail_x15_r0_body.P39 1769 PRE_first_tail_x15_r0_body.kappa39 PRE_first_tail_x15_r0_body.s358.ffi PRE_first_tail_x15_r0_body.s357.ffi :=
  ⟨PRE_first_tail_x15_r0_body.cnshift39 clean hltC nltC itemsC tracedC cl, PRE_first_tail_x15_r0_body.cqueue39, fun t ht => bSN_sound (List.all_eq_true.mp PRE_first_tail_x15_r0_body.ctokSupp39 t ht),
    PRE_first_tail_x15_r0_body.cbridge39,
    liveShift_foot (x0' := Host.Ts.Sim.Full.mlxOf PRE_first_tail_x15_r0_body.s358.ffi) (x1' := Host.Ts.Sim.Full.mlxOf PRE_first_tail_x15_r0_body.s357.ffi) (PRE_first_tail_x15_r0_body.cfoot39 clean hltC nltC itemsC tracedC cl) rfl PRE_first_tail_x15_r0_body.ofx0_39 PRE_first_tail_x15_r0_body.ofx1_39 hobjC PRE_first_tail_x15_r0_body.ff039 PRE_first_tail_x15_r0_body.ff139 PRE_first_tail_x15_r0_body.ffck39,
    kernShift_foot (x0' := Host.Ts.Sim.Full.mlxOf PRE_first_tail_x15_r0_body.s358.ffi) (x1' := Host.Ts.Sim.Full.mlxOf PRE_first_tail_x15_r0_body.s357.ffi) (PRE_first_tail_x15_r0_body.cfoot39 clean hltC nltC itemsC tracedC cl) rfl PRE_first_tail_x15_r0_body.okr0_39 PRE_first_tail_x15_r0_body.okr1_39 (Nat.le_of_ble_eq_true PRE_first_tail_x15_r0_body.fkn39) hfC htC hclC
      PRE_first_tail_x15_r0_body.fkf039 PRE_first_tail_x15_r0_body.fkt039 PRE_first_tail_x15_r0_body.fkf139 PRE_first_tail_x15_r0_body.fkt139 PRE_first_tail_x15_r0_body.fkck39,
    pendReg_of rfl PRE_first_tail_x15_r0_body.cnh039 PRE_first_tail_x15_r0_body.cnh139 (Nat.le_of_ble_eq_true PRE_first_tail_x15_r0_body.cpendLe39) PRE_first_tail_x15_r0_body.cpendR39⟩

end Host.Load.Run.Tpl
