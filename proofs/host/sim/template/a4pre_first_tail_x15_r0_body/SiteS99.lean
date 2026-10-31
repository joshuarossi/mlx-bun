import host.sim.template.a4pre_first_tail_x15_r0_body.SiteCl99
import host.sim.conv.CompactFull
import host.sim.template.FootGen
set_option Elab.async false
namespace Host.Load.Run.Tpl
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
open Host.Ts Host.Ts.Sim Host.Ts.Sim.Template

/-! The compaction's native shift at call site 99 from its footprint (`Conv.nshift_of_foot`), and the observers'
(`liveShift_foot`, `kernShift_foot`): `Conv.FullShiftQ` for `Conv.full_compactQ`, given the call's bookkeeping and its
relation's facts. -/

/-- The load parameters of the chain (band-free: its start's node counter as `NL` and `N0`). -/
def PRE_first_tail_x15_r0_body.Pc99 : LoadP := ⟨18151, 131072, 1099511627776, 15235, 15235, []⟩
/-- The site's band raised to the map's checked fixed-node prefix, including newly recorded closure traces. -/
def PRE_first_tail_x15_r0_body.P99 : LoadP := PRE_first_tail_x15_r0_body.Pc99.raise 17264
kernel_rfl PRE_first_tail_x15_r0_body.craise99 : Nat.ble PRE_first_tail_x15_r0_body.Pc99.N0 17264 = true
theorem PRE_first_tail_x15_r0_body.raised99 : Host.Ts.Sim.Full.Raised PRE_first_tail_x15_r0_body.Pc99 PRE_first_tail_x15_r0_body.P99 :=
  .inr ⟨17264, rfl, Nat.le_of_ble_eq_true PRE_first_tail_x15_r0_body.craise99, rfl⟩
noncomputable abbrev PRE_first_tail_x15_r0_body.cx0_99 : Host.Load.LSt := clearTokens (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s883.ffi)
noncomputable abbrev PRE_first_tail_x15_r0_body.cx1_99 : Host.Load.LSt := clearTokens (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s882.ffi)
def PRE_first_tail_x15_r0_body.khinv99 : PTrie Nat := Stage.setAll PTrie.nil [(20187, 20161), (20165, 20162), (20188, 20163)]
def PRE_first_tail_x15_r0_body.kninv99 : PTrie Nat := Stage.setAll PTrie.nil [(17237, 17237), (17238, 17238), (17239, 17239), (17240, 17240), (17241, 17241), (17242, 17242), (17243, 17243), (17244, 17244), (17245, 17245), (17246, 17246), (17247, 17247), (17248, 17248), (17249, 17249), (17250, 17250), (17251, 17251), (17252, 17252), (17253, 17253), (17254, 17254), (17255, 17255), (17256, 17256), (17257, 17257), (17258, 17258), (17259, 17259), (17260, 17260), (17261, 17261), (17262, 17262), (17263, 17263)]
/-- The stage's footprint: its written and fresh handles, fresh nodes, written and fresh items. -/
def PRE_first_tail_x15_r0_body.cwS99 : List Nat := [20141, 20154, 20160, 20161, 20162, 20163, 20164, 20165, 20166, 20167, 20168, 20169, 20170, 20171, 20172, 20173, 20174, 20175, 20176, 20177, 20178, 20179, 20180, 20181, 20182, 20183, 20184, 20185, 20186, 20187, 20188]
def PRE_first_tail_x15_r0_body.cnS99 : List Nat := List.range' 17237 27
def PRE_first_tail_x15_r0_body.ciS99 : List Nat := [] ++ List.range' 17237 27

-- the small checks (`MChecks`'s)
kernel_rfl PRE_first_tail_x15_r0_body.cnh099 : PRE_first_tail_x15_r0_body.kd99.nh0 = PRE_first_tail_x15_r0_body.cx0_99.mlx.next
kernel_rfl PRE_first_tail_x15_r0_body.cnh199 : PRE_first_tail_x15_r0_body.kd99.nh1 = PRE_first_tail_x15_r0_body.cx1_99.mlx.next
kernel_rfl PRE_first_tail_x15_r0_body.cnn099 : PRE_first_tail_x15_r0_body.kd99.nn0 = PRE_first_tail_x15_r0_body.cx0_99.mlx.nnext
kernel_rfl PRE_first_tail_x15_r0_body.cnn199 : PRE_first_tail_x15_r0_body.kd99.nn1 = PRE_first_tail_x15_r0_body.cx1_99.mlx.nnext
kernel_rfl PRE_first_tail_x15_r0_body.cplo99 : (Nat.blt 0 PRE_first_tail_x15_r0_body.P99.lo && Nat.ble PRE_first_tail_x15_r0_body.P99.lo PRE_first_tail_x15_r0_body.cx0_99.mlx.next && Nat.ble PRE_first_tail_x15_r0_body.P99.lo RData.bigHi && Nat.ble RData.bigHi PRE_first_tail_x15_r0_body.P99.E) = true
kernel_rfl PRE_first_tail_x15_r0_body.ccnt99 : (Nat.ble PRE_first_tail_x15_r0_body.cx0_99.mlx.next PRE_first_tail_x15_r0_body.cx1_99.mlx.next && Nat.ble PRE_first_tail_x15_r0_body.cx0_99.mlx.nnext PRE_first_tail_x15_r0_body.cx1_99.mlx.nnext) = true
kernel_rfl PRE_first_tail_x15_r0_body.cnband99 : (Nat.blt 0 PRE_first_tail_x15_r0_body.P99.NL && Nat.ble PRE_first_tail_x15_r0_body.P99.NL PRE_first_tail_x15_r0_body.P99.N0 && Nat.ble PRE_first_tail_x15_r0_body.P99.N0 PRE_first_tail_x15_r0_body.cx0_99.mlx.nnext) = true
kernel_rfl PRE_first_tail_x15_r0_body.chbelow99 : PRE_first_tail_x15_r0_body.kd99.checkHndBelow = true
kernel_rfl PRE_first_tail_x15_r0_body.chren99 : checkRenG PRE_first_tail_x15_r0_body.kd99.hnd PRE_first_tail_x15_r0_body.khinv99 (phB PRE_first_tail_x15_r0_body.cx0_99.mlx) = true
kernel_rfl PRE_first_tail_x15_r0_body.cband99 : PRE_first_tail_x15_r0_body.kd99.checkBand PRE_first_tail_x15_r0_body.P99.lo = true
kernel_rfl PRE_first_tail_x15_r0_body.cnh1pos99 : Nat.blt 0 PRE_first_tail_x15_r0_body.kd99.nh1 = true
kernel_rfl PRE_first_tail_x15_r0_body.cnren99 : checkRenG PRE_first_tail_x15_r0_body.kd99.node PRE_first_tail_x15_r0_body.kninv99 (pnB PRE_first_tail_x15_r0_body.cx0_99.mlx) = true
kernel_rfl PRE_first_tail_x15_r0_body.cnlow99 : (PTrie.keysA PRE_first_tail_x15_r0_body.kd99.node).all (fun j => Nat.ble PRE_first_tail_x15_r0_body.P99.NL j && Nat.blt (PRE_first_tail_x15_r0_body.kd99.nodeF j) PRE_first_tail_x15_r0_body.cx1_99.mlx.nnext) = true
kernel_rfl PRE_first_tail_x15_r0_body.cabs0a99 : PRE_first_tail_x15_r0_body.cx0_99.mlx.arrs.get 0 = none
kernel_rfl PRE_first_tail_x15_r0_body.cabs0b99 : PRE_first_tail_x15_r0_body.cx0_99.mlx.objs.get 0 = none
kernel_rfl PRE_first_tail_x15_r0_body.ctok199 : PRE_first_tail_x15_r0_body.cx1_99.mlx.tokens = []
kernel_rfl PRE_first_tail_x15_r0_body.cpend99 : PRE_first_tail_x15_r0_body.cx1_99.mlx.pending = PRE_first_tail_x15_r0_body.cx0_99.mlx.pending.map PRE_first_tail_x15_r0_body.kappa99.pend
kernel_rfl PRE_first_tail_x15_r0_body.cerrh99 : PRE_first_tail_x15_r0_body.cx1_99.mlx.errh = PRE_first_tail_x15_r0_body.cx0_99.mlx.errh.map PRE_first_tail_x15_r0_body.kappa99.arg
kernel_rfl PRE_first_tail_x15_r0_body.cfiles99 : PRE_first_tail_x15_r0_body.cx1_99.mlx.files = PRE_first_tail_x15_r0_body.cx0_99.mlx.files
kernel_rfl PRE_first_tail_x15_r0_body.carch99 : PRE_first_tail_x15_r0_body.cx1_99.mlx.arch = PRE_first_tail_x15_r0_body.cx0_99.mlx.arch
kernel_rfl PRE_first_tail_x15_r0_body.csizes99 : PRE_first_tail_x15_r0_body.cx1_99.mlx.deviceSizes = PRE_first_tail_x15_r0_body.cx0_99.mlx.deviceSizes
kernel_rfl PRE_first_tail_x15_r0_body.cwired99 : PRE_first_tail_x15_r0_body.cx1_99.mlx.wired = PRE_first_tail_x15_r0_body.cx0_99.mlx.wired
kernel_rfl PRE_first_tail_x15_r0_body.chost99 : PRE_first_tail_x15_r0_body.cx1_99.host = PRE_first_tail_x15_r0_body.cx0_99.host
-- the compaction map's addresses are `PRE_first_tail_x15_r0_body.kd99`'s
kernel_rfl PRE_first_tail_x15_r0_body.ckn099 : PRE_first_tail_x15_r0_body.kd99.n0 = 2753057
kernel_rfl PRE_first_tail_x15_r0_body.ckn199 : PRE_first_tail_x15_r0_body.kd99.n1 = 2754206
kernel_rfl PRE_first_tail_x15_r0_body.ckheap99 : (PTrie.keysA PRE_first_tail_x15_r0_body.kd99.heap).all (fun x => Nat.ble 2753051 x) = true
kernel_rfl PRE_first_tail_x15_r0_body.ckpl99 : (List.range 6).all (fun j => decide (PRE_first_tail_x15_r0_body.kd99.heap.get (2753051 + j) = nth? PRE_first_tail_x15_r0_body.pl99 j)) = true
-- the map fixes the call's names (`Conv.fixOld_compact`), the call's counters
kernel_rfl PRE_first_tail_x15_r0_body.fja99 : Nat.ble 2753051 2753051 = true
kernel_rfl PRE_first_tail_x15_r0_body.fn99 : Nat.ble 4316 4316 = true
kernel_rfl PRE_first_tail_x15_r0_body.fjaD99 : Nat.ble 2753051 PRE_first_tail_x15_r0_body.kd99.n0 = true
kernel_rfl PRE_first_tail_x15_r0_body.fxn99 : Nat.ble 20161 PRE_first_tail_x15_r0_body.kd99.nh0 = true
kernel_rfl PRE_first_tail_x15_r0_body.fnn99 : Nat.ble 17237 PRE_first_tail_x15_r0_body.kd99.nn0 = true
kernel_rfl PRE_first_tail_x15_r0_body.fxb99 : Nat.ble 20161 RData.bigHi = true
kernel_rfl PRE_first_tail_x15_r0_body.fheap99 : (PTrie.keysA PRE_first_tail_x15_r0_body.kd99.heap).all (Nat.ble (⟨20161, 17237, 2753051, 4316⟩ : Conv.Cnt).ja) = true
kernel_rfl PRE_first_tail_x15_r0_body.fhnd99 : (PTrie.keysA PRE_first_tail_x15_r0_body.kd99.hnd).all (Nat.ble (⟨20161, 17237, 2753051, 4316⟩ : Conv.Cnt).xn) = true
kernel_rfl PRE_first_tail_x15_r0_body.fnode99 : (PTrie.keysA PRE_first_tail_x15_r0_body.kd99.node).all (Nat.ble (⟨20161, 17237, 2753051, 4316⟩ : Conv.Cnt).nn) = true
/-- The compaction map fixes the call's names. -/
theorem PRE_first_tail_x15_r0_body.cfix99 : Conv.FixOld (⟨20161, 17237, 2753051, 4316⟩ : Conv.Cnt) PRE_first_tail_x15_r0_body.kappa99 :=
  Conv.fixOld_compact (Nat.le_of_ble_eq_true PRE_first_tail_x15_r0_body.fja99) (Nat.le_of_ble_eq_true PRE_first_tail_x15_r0_body.fn99) (Nat.le_of_ble_eq_true PRE_first_tail_x15_r0_body.fjaD99) (Nat.le_of_ble_eq_true PRE_first_tail_x15_r0_body.fxn99) (Nat.le_of_ble_eq_true PRE_first_tail_x15_r0_body.fnn99) (Nat.le_of_ble_eq_true PRE_first_tail_x15_r0_body.fxb99) PRE_first_tail_x15_r0_body.fheap99 PRE_first_tail_x15_r0_body.fhnd99 PRE_first_tail_x15_r0_body.fnode99
kernel_rfl PRE_first_tail_x15_r0_body.fcxn99 : (⟨20161, 17237, 2753051, 4316⟩ : Conv.Cnt).xn = (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s881.ffi).mlx.next
kernel_rfl PRE_first_tail_x15_r0_body.fcnn99 : (⟨20161, 17237, 2753051, 4316⟩ : Conv.Cnt).nn = (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s881.ffi).mlx.nnext
kernel_rfl PRE_first_tail_x15_r0_body.fle099 : (Nat.ble (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s881.ffi).mlx.next PRE_first_tail_x15_r0_body.cx0_99.mlx.next && Nat.ble (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s881.ffi).mlx.nnext PRE_first_tail_x15_r0_body.cx0_99.mlx.nnext && Nat.ble (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s881.ffi).mlx.next RData.bigHi) = true
kernel_rfl PRE_first_tail_x15_r0_body.fnk99 : (PTrie.keysA PRE_first_tail_x15_r0_body.kd99.node).all (Nat.ble (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s881.ffi).mlx.nnext) = true
-- the merged state keeps the call's entries off the stage's footprint
kernel_rfl PRE_first_tail_x15_r0_body.f1A99 : PRE_first_tail_x15_r0_body.cx1_99.mlx.arrs = Stage.setAll (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s881.ffi).mlx.arrs (PRE_first_tail_x15_r0_body.cwS99.filterMap fun i => (PRE_first_tail_x15_r0_body.cx1_99.mlx.arrs.get i).map (i, ·))
kernel_rfl PRE_first_tail_x15_r0_body.f1O99 : PRE_first_tail_x15_r0_body.cx1_99.mlx.objs = Stage.setAll (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s881.ffi).mlx.objs (PRE_first_tail_x15_r0_body.cwS99.filterMap fun i => (PRE_first_tail_x15_r0_body.cx1_99.mlx.objs.get i).map (i, ·))
kernel_rfl PRE_first_tail_x15_r0_body.f1N99 : PRE_first_tail_x15_r0_body.cx1_99.mlx.nodes = Stage.setAll (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s881.ffi).mlx.nodes (PRE_first_tail_x15_r0_body.cnS99.filterMap fun i => (PRE_first_tail_x15_r0_body.cx1_99.mlx.nodes.get i).map (i, ·))
kernel_rfl PRE_first_tail_x15_r0_body.f1I99 : PRE_first_tail_x15_r0_body.cx1_99.mlx.items = Stage.setAll (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s881.ffi).mlx.items (PRE_first_tail_x15_r0_body.ciS99.filterMap fun i => (PRE_first_tail_x15_r0_body.cx1_99.mlx.items.get i).map (i, ·))
kernel_rfl PRE_first_tail_x15_r0_body.fbd99 : (PRE_first_tail_x15_r0_body.clo99 ++ PRE_first_tail_x15_r0_body.cln99 ++ PRE_first_tail_x15_r0_body.cli99 ++ PRE_first_tail_x15_r0_body.cwS99 ++ PRE_first_tail_x15_r0_body.cnS99 ++ PRE_first_tail_x15_r0_body.ciS99).all (fun i => Nat.blt (i / 4096) (4 ^ 31)) = true
kernel_rfl PRE_first_tail_x15_r0_body.fincW99 : PRE_first_tail_x15_r0_body.cwS99.all (fun h => !Nat.blt h (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s881.ffi).mlx.next || PRE_first_tail_x15_r0_body.clo99.contains h) = true
kernel_rfl PRE_first_tail_x15_r0_body.fincI99 : PRE_first_tail_x15_r0_body.ciS99.all (fun k => !Nat.blt k (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s881.ffi).mlx.nnext || PRE_first_tail_x15_r0_body.cli99.contains k) = true
kernel_rfl PRE_first_tail_x15_r0_body.fincN99 : PRE_first_tail_x15_r0_body.cnS99.all (Nat.ble (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s881.ffi).mlx.nnext) = true
kernel_rfl PRE_first_tail_x15_r0_body.flnF99 : PRE_first_tail_x15_r0_body.cln99.all (Nat.ble (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s881.ffi).mlx.nnext) = true
-- the checks over the changed lists
kernel_rfl PRE_first_tail_x15_r0_body.fh99 : PRE_first_tail_x15_r0_body.clo99.all (handleOK PRE_first_tail_x15_r0_body.kappa99 PRE_first_tail_x15_r0_body.P99.lo PRE_first_tail_x15_r0_body.cx0_99.mlx PRE_first_tail_x15_r0_body.cx1_99.mlx) = true
kernel_rfl PRE_first_tail_x15_r0_body.fo99 : PRE_first_tail_x15_r0_body.clo99.map (fun h => PRE_first_tail_x15_r0_body.cx1_99.mlx.objs.get (PRE_first_tail_x15_r0_body.kappa99.handle h)) = PRE_first_tail_x15_r0_body.clo99.map (fun h => (PRE_first_tail_x15_r0_body.cx0_99.mlx.objs.get h).map PRE_first_tail_x15_r0_body.kappa99.nobj)
kernel_rfl PRE_first_tail_x15_r0_body.fok99 : PRE_first_tail_x15_r0_body.clo99.all (objOK PRE_first_tail_x15_r0_body.kappa99 PRE_first_tail_x15_r0_body.P99.NL PRE_first_tail_x15_r0_body.cx0_99.mlx) = true
kernel_rfl PRE_first_tail_x15_r0_body.fnd99 : PRE_first_tail_x15_r0_body.cln99.all (nodeOKF PRE_first_tail_x15_r0_body.kappa99 PRE_first_tail_x15_r0_body.P99 PRE_first_tail_x15_r0_body.cx0_99.mlx PRE_first_tail_x15_r0_body.cx1_99.mlx) = true
kernel_rfl PRE_first_tail_x15_r0_body.fp99 : ((PRE_first_tail_x15_r0_body.cln99.filter (fullB PRE_first_tail_x15_r0_body.P99))).map (fun i => (PRE_first_tail_x15_r0_body.cx1_99.mlx.nodes.get (PRE_first_tail_x15_r0_body.kappa99.node i)).map Host.Mlx.Ffi.Node.prim) =
  ((PRE_first_tail_x15_r0_body.cln99.filter (fullB PRE_first_tail_x15_r0_body.P99))).map (fun i => (PRE_first_tail_x15_r0_body.cx0_99.mlx.nodes.get i).map fun nd => PRE_first_tail_x15_r0_body.kappa99.prim nd.prim)
kernel_rfl PRE_first_tail_x15_r0_body.fnordI99 : incrB PRE_first_tail_x15_r0_body.kd99.nodeF (List.range' 17237 27) = true
kernel_rfl PRE_first_tail_x15_r0_body.fnordK99 : (PTrie.keysA PRE_first_tail_x15_r0_body.kd99.node).all (fun k => Nat.ble 17237 k && Nat.blt k 17264) = true
kernel_rfl PRE_first_tail_x15_r0_body.fnordL99 : (PRE_first_tail_x15_r0_body.cln99.filter (Nat.ble PRE_first_tail_x15_r0_body.P99.N0)).all (fun i => Nat.ble i (PRE_first_tail_x15_r0_body.kd99.nodeF i) && (Nat.blt i 17264 || Nat.ble PRE_first_tail_x15_r0_body.kd99.nn0 i)) = true
theorem PRE_first_tail_x15_r0_body.fnord99 : (PRE_first_tail_x15_r0_body.cln99.filter (Nat.ble PRE_first_tail_x15_r0_body.P99.N0)).all (fun i => Nat.ble i (PRE_first_tail_x15_r0_body.kd99.nodeF i) &&
    (PTrie.keysA PRE_first_tail_x15_r0_body.kd99.node).all fun j => !Nat.blt j i || Nat.blt (PRE_first_tail_x15_r0_body.kd99.nodeF j) (PRE_first_tail_x15_r0_body.kd99.nodeF i)) = true :=
  cnord_of PRE_first_tail_x15_r0_body.cnlow99 PRE_first_tail_x15_r0_body.cnn199 PRE_first_tail_x15_r0_body.fnordI99 PRE_first_tail_x15_r0_body.fnordK99 PRE_first_tail_x15_r0_body.fnordL99
kernel_rfl PRE_first_tail_x15_r0_body.fi99 : PRE_first_tail_x15_r0_body.cli99.all (pnB PRE_first_tail_x15_r0_body.cx0_99.mlx) = true
kernel_rfl PRE_first_tail_x15_r0_body.fii99 : PRE_first_tail_x15_r0_body.cli99.all (fun k => decide (PRE_first_tail_x15_r0_body.cx1_99.mlx.items.get (PRE_first_tail_x15_r0_body.kappa99.node k) = (PRE_first_tail_x15_r0_body.cx0_99.mlx.items.get k).map PRE_first_tail_x15_r0_body.kappa99.nv)) = true
/-- **The compaction's footprint.** -/
theorem PRE_first_tail_x15_r0_body.cfoot99 (clean : Conv.NClean (⟨20161, 17237, 2753051, 4316⟩ : Conv.Cnt) (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s881.ffi).mlx) (hltC : ∀ h, PH (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s881.ffi).mlx h → h < (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s881.ffi).mlx.next) (nltC : ∀ i, PN (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s881.ffi).mlx i → i < (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s881.ffi).mlx.nnext) (itemsC : ∀ k v, (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s881.ffi).mlx.items.get k = some v → PN (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s881.ffi).mlx k) (tracedC : ∀ h o, (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s881.ffi).mlx.objs.get h = some o → ∀ i ∈ objTraces o, i < PRE_first_tail_x15_r0_body.P99.NL) (cl : SSt (· < 4334) PRE_first_tail_x15_r0_body.cx0_99.mlx) :
    Conv.MFoot PRE_first_tail_x15_r0_body.P99 4334 PRE_first_tail_x15_r0_body.kappa99 PRE_first_tail_x15_r0_body.kd99 PRE_first_tail_x15_r0_body.khinv99 PRE_first_tail_x15_r0_body.kninv99 (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s881.ffi).mlx PRE_first_tail_x15_r0_body.cx0_99.mlx PRE_first_tail_x15_r0_body.cx1_99.mlx (⟨20161, 17237, 2753051, 4316⟩ : Conv.Cnt) PRE_first_tail_x15_r0_body.clo99 PRE_first_tail_x15_r0_body.cln99 PRE_first_tail_x15_r0_body.cli99 PRE_first_tail_x15_r0_body.cwS99 PRE_first_tail_x15_r0_body.cnS99 PRE_first_tail_x15_r0_body.ciS99 :=
  ⟨rfl, rfl, rfl, PRE_first_tail_x15_r0_body.cnh099, PRE_first_tail_x15_r0_body.cnh199, PRE_first_tail_x15_r0_body.cnn099, PRE_first_tail_x15_r0_body.cnn199, PRE_first_tail_x15_r0_body.cplo99, PRE_first_tail_x15_r0_body.ccnt99, PRE_first_tail_x15_r0_body.cnband99, PRE_first_tail_x15_r0_body.chbelow99, PRE_first_tail_x15_r0_body.chren99, PRE_first_tail_x15_r0_body.cband99, PRE_first_tail_x15_r0_body.cnh1pos99, PRE_first_tail_x15_r0_body.cnren99, PRE_first_tail_x15_r0_body.cnlow99, PRE_first_tail_x15_r0_body.cabs0a99, PRE_first_tail_x15_r0_body.cabs0b99, PRE_first_tail_x15_r0_body.ctok199, PRE_first_tail_x15_r0_body.cpend99, PRE_first_tail_x15_r0_body.cerrh99, PRE_first_tail_x15_r0_body.cfiles99, PRE_first_tail_x15_r0_body.carch99, PRE_first_tail_x15_r0_body.csizes99, PRE_first_tail_x15_r0_body.cwired99, PRE_first_tail_x15_r0_body.cfix99, clean, PRE_first_tail_x15_r0_body.fcxn99, PRE_first_tail_x15_r0_body.fcnn99, hltC, nltC, itemsC, tracedC, cl, PRE_first_tail_x15_r0_body.fle099, PRE_first_tail_x15_r0_body.fnk99, PRE_first_tail_x15_r0_body.ckA99, PRE_first_tail_x15_r0_body.cobjsK99, PRE_first_tail_x15_r0_body.cnodesK99, PRE_first_tail_x15_r0_body.citemsK99, PRE_first_tail_x15_r0_body.f1A99, PRE_first_tail_x15_r0_body.f1O99, PRE_first_tail_x15_r0_body.f1N99, PRE_first_tail_x15_r0_body.f1I99, PRE_first_tail_x15_r0_body.fbd99, PRE_first_tail_x15_r0_body.fincW99, PRE_first_tail_x15_r0_body.fincI99, PRE_first_tail_x15_r0_body.fincN99, PRE_first_tail_x15_r0_body.flnF99, PRE_first_tail_x15_r0_body.fh99, PRE_first_tail_x15_r0_body.fo99, PRE_first_tail_x15_r0_body.fok99, PRE_first_tail_x15_r0_body.fnd99, PRE_first_tail_x15_r0_body.fp99, PRE_first_tail_x15_r0_body.fnord99, PRE_first_tail_x15_r0_body.fi99, PRE_first_tail_x15_r0_body.fii99⟩
theorem PRE_first_tail_x15_r0_body.cnshift99 (clean : Conv.NClean (⟨20161, 17237, 2753051, 4316⟩ : Conv.Cnt) (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s881.ffi).mlx) (hltC : ∀ h, PH (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s881.ffi).mlx h → h < (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s881.ffi).mlx.next) (nltC : ∀ i, PN (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s881.ffi).mlx i → i < (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s881.ffi).mlx.nnext) (itemsC : ∀ k v, (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s881.ffi).mlx.items.get k = some v → PN (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s881.ffi).mlx k) (tracedC : ∀ h o, (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s881.ffi).mlx.objs.get h = some o → ∀ i ∈ objTraces o, i < PRE_first_tail_x15_r0_body.P99.NL) (cl : SSt (· < 4334) PRE_first_tail_x15_r0_body.cx0_99.mlx) : NShift PRE_first_tail_x15_r0_body.P99 4334 PRE_first_tail_x15_r0_body.kappa99 PRE_first_tail_x15_r0_body.cx0_99 PRE_first_tail_x15_r0_body.cx1_99 :=
  Conv.nshift_of_foot (PRE_first_tail_x15_r0_body.cfoot99 clean hltC nltC itemsC tracedC cl) PRE_first_tail_x15_r0_body.chost99 (compact_a_eq PRE_first_tail_x15_r0_body.ckn099 PRE_first_tail_x15_r0_body.ckn199 PRE_first_tail_x15_r0_body.ckheap99 PRE_first_tail_x15_r0_body.ckpl99)

-- the observers: the layers' states at the call, the canonical and the merged state, their footprints and checks
noncomputable def PRE_first_tail_x15_r0_body.fxC_99 : PTrie Unit := (Host.Ts.Sim.Full.freedOf PRE_first_tail_x15_r0_body.s881.ffi).getD PTrie.nil
noncomputable def PRE_first_tail_x15_r0_body.krC_99 : Host.Load.Layers.KRec := (Host.Ts.Sim.Full.krecOf PRE_first_tail_x15_r0_body.s881.ffi).getD Host.Load.Layers.KRec.empty
kernel_rfl PRE_first_tail_x15_r0_body.ofxC_99 : (Host.Ts.Sim.Full.freedOf PRE_first_tail_x15_r0_body.s881.ffi) = some PRE_first_tail_x15_r0_body.fxC_99
kernel_rfl PRE_first_tail_x15_r0_body.okrC_99 : (Host.Ts.Sim.Full.krecOf PRE_first_tail_x15_r0_body.s881.ffi) = some PRE_first_tail_x15_r0_body.krC_99
noncomputable def PRE_first_tail_x15_r0_body.fx0_99 : PTrie Unit := (Host.Ts.Sim.Full.freedOf PRE_first_tail_x15_r0_body.s883.ffi).getD PTrie.nil
noncomputable def PRE_first_tail_x15_r0_body.kr0_99 : Host.Load.Layers.KRec := (Host.Ts.Sim.Full.krecOf PRE_first_tail_x15_r0_body.s883.ffi).getD Host.Load.Layers.KRec.empty
kernel_rfl PRE_first_tail_x15_r0_body.ofx0_99 : (Host.Ts.Sim.Full.freedOf PRE_first_tail_x15_r0_body.s883.ffi) = some PRE_first_tail_x15_r0_body.fx0_99
kernel_rfl PRE_first_tail_x15_r0_body.okr0_99 : (Host.Ts.Sim.Full.krecOf PRE_first_tail_x15_r0_body.s883.ffi) = some PRE_first_tail_x15_r0_body.kr0_99
noncomputable def PRE_first_tail_x15_r0_body.fx1_99 : PTrie Unit := (Host.Ts.Sim.Full.freedOf PRE_first_tail_x15_r0_body.s882.ffi).getD PTrie.nil
noncomputable def PRE_first_tail_x15_r0_body.kr1_99 : Host.Load.Layers.KRec := (Host.Ts.Sim.Full.krecOf PRE_first_tail_x15_r0_body.s882.ffi).getD Host.Load.Layers.KRec.empty
kernel_rfl PRE_first_tail_x15_r0_body.ofx1_99 : (Host.Ts.Sim.Full.freedOf PRE_first_tail_x15_r0_body.s882.ffi) = some PRE_first_tail_x15_r0_body.fx1_99
kernel_rfl PRE_first_tail_x15_r0_body.okr1_99 : (Host.Ts.Sim.Full.krecOf PRE_first_tail_x15_r0_body.s882.ffi) = some PRE_first_tail_x15_r0_body.kr1_99
kernel_rfl PRE_first_tail_x15_r0_body.ff099 : PRE_first_tail_x15_r0_body.fx0_99 = Stage.setAll PRE_first_tail_x15_r0_body.fxC_99 (PRE_first_tail_x15_r0_body.clo99.filterMap fun i => (PRE_first_tail_x15_r0_body.fx0_99.get i).map (i, ·))
kernel_rfl PRE_first_tail_x15_r0_body.ff199 : PRE_first_tail_x15_r0_body.fx1_99 = Stage.setAll PRE_first_tail_x15_r0_body.fxC_99 (PRE_first_tail_x15_r0_body.cwS99.filterMap fun i => (PRE_first_tail_x15_r0_body.fx1_99.get i).map (i, ·))
kernel_rfl PRE_first_tail_x15_r0_body.ffck99 : freedLB PRE_first_tail_x15_r0_body.kappa99 PRE_first_tail_x15_r0_body.cx0_99.mlx PRE_first_tail_x15_r0_body.fx0_99 PRE_first_tail_x15_r0_body.fx1_99 PRE_first_tail_x15_r0_body.clo99 = true
kernel_rfl PRE_first_tail_x15_r0_body.fkf099 : PRE_first_tail_x15_r0_body.kr0_99.flags = Stage.setAll PRE_first_tail_x15_r0_body.krC_99.flags (PRE_first_tail_x15_r0_body.clo99.filterMap fun i => (PRE_first_tail_x15_r0_body.kr0_99.flags.get i).map (i, ·))
kernel_rfl PRE_first_tail_x15_r0_body.fkt099 : PRE_first_tail_x15_r0_body.kr0_99.targs = Stage.setAll PRE_first_tail_x15_r0_body.krC_99.targs (PRE_first_tail_x15_r0_body.clo99.filterMap fun i => (PRE_first_tail_x15_r0_body.kr0_99.targs.get i).map (i, ·))
kernel_rfl PRE_first_tail_x15_r0_body.fkf199 : PRE_first_tail_x15_r0_body.kr1_99.flags = Stage.setAll PRE_first_tail_x15_r0_body.krC_99.flags (PRE_first_tail_x15_r0_body.cwS99.filterMap fun i => (PRE_first_tail_x15_r0_body.kr1_99.flags.get i).map (i, ·))
kernel_rfl PRE_first_tail_x15_r0_body.fkt199 : PRE_first_tail_x15_r0_body.kr1_99.targs = Stage.setAll PRE_first_tail_x15_r0_body.krC_99.targs (PRE_first_tail_x15_r0_body.cwS99.filterMap fun i => (PRE_first_tail_x15_r0_body.kr1_99.targs.get i).map (i, ·))
kernel_rfl PRE_first_tail_x15_r0_body.fkck99 : krecLB PRE_first_tail_x15_r0_body.kappa99 4334 PRE_first_tail_x15_r0_body.cx0_99.mlx PRE_first_tail_x15_r0_body.kr0_99 PRE_first_tail_x15_r0_body.kr1_99 PRE_first_tail_x15_r0_body.clo99 = true
kernel_rfl PRE_first_tail_x15_r0_body.fkn99 : Nat.ble 4316 4334 = true
-- the bridge and the pending traces' regions
kernel_rfl PRE_first_tail_x15_r0_body.cbridge99 : Host.Ts.Sim.Full.bridgeOf PRE_first_tail_x15_r0_body.s882.ffi = Host.Ts.Sim.Full.bridgeOf PRE_first_tail_x15_r0_body.s883.ffi
kernel_rfl PRE_first_tail_x15_r0_body.cpendR99 : pendRegB PRE_first_tail_x15_r0_body.kappa99 (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s883.ffi).mlx = true
kernel_rfl PRE_first_tail_x15_r0_body.cpendLe99 : Nat.ble (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s883.ffi).mlx.next (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s882.ffi).mlx.next = true
/-- **The compaction's native shift**, given the call's bookkeeping, its relation's facts (the model's and the
observers') and the canonical closedness. -/
theorem PRE_first_tail_x15_r0_body.cshift99 (clean : Conv.NClean (⟨20161, 17237, 2753051, 4316⟩ : Conv.Cnt) (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s881.ffi).mlx) (hltC : ∀ h, PH (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s881.ffi).mlx h → h < (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s881.ffi).mlx.next) (nltC : ∀ i, PN (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s881.ffi).mlx i → i < (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s881.ffi).mlx.nnext) (itemsC : ∀ k v, (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s881.ffi).mlx.items.get k = some v → PN (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s881.ffi).mlx k) (tracedC : ∀ h o, (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s881.ffi).mlx.objs.get h = some o → ∀ i ∈ objTraces o, i < PRE_first_tail_x15_r0_body.P99.NL) (cl : SSt (· < 4334) PRE_first_tail_x15_r0_body.cx0_99.mlx)
    (hobjC : ∀ h, PRE_first_tail_x15_r0_body.fxC_99.get h = some () → ((Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s881.ffi).mlx.objs.get h).isSome = true)
    (hfC : ∀ h, (PRE_first_tail_x15_r0_body.krC_99.flags.get h).isSome = true → ((Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s881.ffi).mlx.objs.get h).isSome = true)
    (htC : ∀ h, (PRE_first_tail_x15_r0_body.krC_99.targs.get h).isSome = true → ((Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s881.ffi).mlx.objs.get h).isSome = true)
    (hclC : ∀ h l, PRE_first_tail_x15_r0_body.krC_99.targs.get h = some l → Host.Ts.Sim.Full.STargs (· < (⟨20161, 17237, 2753051, 4316⟩ : Conv.Cnt).n) l) :
    Conv.FullShiftQ PRE_first_tail_x15_r0_body.P99 4334 PRE_first_tail_x15_r0_body.kappa99 PRE_first_tail_x15_r0_body.s883.ffi PRE_first_tail_x15_r0_body.s882.ffi :=
  ⟨PRE_first_tail_x15_r0_body.cnshift99 clean hltC nltC itemsC tracedC cl, PRE_first_tail_x15_r0_body.cqueue99, fun t ht => bSN_sound (List.all_eq_true.mp PRE_first_tail_x15_r0_body.ctokSupp99 t ht),
    PRE_first_tail_x15_r0_body.cbridge99,
    liveShift_foot (x0' := Host.Ts.Sim.Full.mlxOf PRE_first_tail_x15_r0_body.s883.ffi) (x1' := Host.Ts.Sim.Full.mlxOf PRE_first_tail_x15_r0_body.s882.ffi) (PRE_first_tail_x15_r0_body.cfoot99 clean hltC nltC itemsC tracedC cl) rfl PRE_first_tail_x15_r0_body.ofx0_99 PRE_first_tail_x15_r0_body.ofx1_99 hobjC PRE_first_tail_x15_r0_body.ff099 PRE_first_tail_x15_r0_body.ff199 PRE_first_tail_x15_r0_body.ffck99,
    kernShift_foot (x0' := Host.Ts.Sim.Full.mlxOf PRE_first_tail_x15_r0_body.s883.ffi) (x1' := Host.Ts.Sim.Full.mlxOf PRE_first_tail_x15_r0_body.s882.ffi) (PRE_first_tail_x15_r0_body.cfoot99 clean hltC nltC itemsC tracedC cl) rfl PRE_first_tail_x15_r0_body.okr0_99 PRE_first_tail_x15_r0_body.okr1_99 (Nat.le_of_ble_eq_true PRE_first_tail_x15_r0_body.fkn99) hfC htC hclC
      PRE_first_tail_x15_r0_body.fkf099 PRE_first_tail_x15_r0_body.fkt099 PRE_first_tail_x15_r0_body.fkf199 PRE_first_tail_x15_r0_body.fkt199 PRE_first_tail_x15_r0_body.fkck99,
    pendReg_of rfl PRE_first_tail_x15_r0_body.cnh099 PRE_first_tail_x15_r0_body.cnh199 (Nat.le_of_ble_eq_true PRE_first_tail_x15_r0_body.cpendLe99) PRE_first_tail_x15_r0_body.cpendR99⟩

end Host.Load.Run.Tpl
