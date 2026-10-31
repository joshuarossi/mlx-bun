import host.sim.template.a4pre_first_tail_x15_r0_body.SiteCl124
import host.sim.conv.CompactFull
import host.sim.template.FootGen
set_option Elab.async false
namespace Host.Load.Run.Tpl
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
open Host.Ts Host.Ts.Sim Host.Ts.Sim.Template

/-! The compaction's native shift at call site 124 from its footprint (`Conv.nshift_of_foot`), and the observers'
(`liveShift_foot`, `kernShift_foot`): `Conv.FullShiftQ` for `Conv.full_compactQ`, given the call's bookkeeping and its
relation's facts. -/

/-- The load parameters of the chain (band-free: its start's node counter as `NL` and `N0`). -/
def PRE_first_tail_x15_r0_body.Pc124 : LoadP := ⟨18151, 131072, 1099511627776, 15235, 15235, []⟩
/-- The site's band raised to the map's checked fixed-node prefix, including newly recorded closure traces. -/
def PRE_first_tail_x15_r0_body.P124 : LoadP := PRE_first_tail_x15_r0_body.Pc124.raise 17751
kernel_rfl PRE_first_tail_x15_r0_body.craise124 : Nat.ble PRE_first_tail_x15_r0_body.Pc124.N0 17751 = true
theorem PRE_first_tail_x15_r0_body.raised124 : Host.Ts.Sim.Full.Raised PRE_first_tail_x15_r0_body.Pc124 PRE_first_tail_x15_r0_body.P124 :=
  .inr ⟨17751, rfl, Nat.le_of_ble_eq_true PRE_first_tail_x15_r0_body.craise124, rfl⟩
noncomputable abbrev PRE_first_tail_x15_r0_body.cx0_124 : Host.Load.LSt := clearTokens (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1100.ffi)
noncomputable abbrev PRE_first_tail_x15_r0_body.cx1_124 : Host.Load.LSt := clearTokens (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1099.ffi)
def PRE_first_tail_x15_r0_body.khinv124 : PTrie Nat := Stage.setAll PTrie.nil []
def PRE_first_tail_x15_r0_body.kninv124 : PTrie Nat := Stage.setAll PTrie.nil []
/-- The stage's footprint: its written and fresh handles, fresh nodes, written and fresh items. -/
def PRE_first_tail_x15_r0_body.cwS124 : List Nat := []
def PRE_first_tail_x15_r0_body.cnS124 : List Nat := List.range' 17751 0
def PRE_first_tail_x15_r0_body.ciS124 : List Nat := [] ++ List.range' 17751 0

-- the small checks (`MChecks`'s)
kernel_rfl PRE_first_tail_x15_r0_body.cnh0124 : PRE_first_tail_x15_r0_body.kd124.nh0 = PRE_first_tail_x15_r0_body.cx0_124.mlx.next
kernel_rfl PRE_first_tail_x15_r0_body.cnh1124 : PRE_first_tail_x15_r0_body.kd124.nh1 = PRE_first_tail_x15_r0_body.cx1_124.mlx.next
kernel_rfl PRE_first_tail_x15_r0_body.cnn0124 : PRE_first_tail_x15_r0_body.kd124.nn0 = PRE_first_tail_x15_r0_body.cx0_124.mlx.nnext
kernel_rfl PRE_first_tail_x15_r0_body.cnn1124 : PRE_first_tail_x15_r0_body.kd124.nn1 = PRE_first_tail_x15_r0_body.cx1_124.mlx.nnext
kernel_rfl PRE_first_tail_x15_r0_body.cplo124 : (Nat.blt 0 PRE_first_tail_x15_r0_body.P124.lo && Nat.ble PRE_first_tail_x15_r0_body.P124.lo PRE_first_tail_x15_r0_body.cx0_124.mlx.next && Nat.ble PRE_first_tail_x15_r0_body.P124.lo RData.bigHi && Nat.ble RData.bigHi PRE_first_tail_x15_r0_body.P124.E) = true
kernel_rfl PRE_first_tail_x15_r0_body.ccnt124 : (Nat.ble PRE_first_tail_x15_r0_body.cx0_124.mlx.next PRE_first_tail_x15_r0_body.cx1_124.mlx.next && Nat.ble PRE_first_tail_x15_r0_body.cx0_124.mlx.nnext PRE_first_tail_x15_r0_body.cx1_124.mlx.nnext) = true
kernel_rfl PRE_first_tail_x15_r0_body.cnband124 : (Nat.blt 0 PRE_first_tail_x15_r0_body.P124.NL && Nat.ble PRE_first_tail_x15_r0_body.P124.NL PRE_first_tail_x15_r0_body.P124.N0 && Nat.ble PRE_first_tail_x15_r0_body.P124.N0 PRE_first_tail_x15_r0_body.cx0_124.mlx.nnext) = true
kernel_rfl PRE_first_tail_x15_r0_body.chbelow124 : PRE_first_tail_x15_r0_body.kd124.checkHndBelow = true
kernel_rfl PRE_first_tail_x15_r0_body.chren124 : checkRenG PRE_first_tail_x15_r0_body.kd124.hnd PRE_first_tail_x15_r0_body.khinv124 (phB PRE_first_tail_x15_r0_body.cx0_124.mlx) = true
kernel_rfl PRE_first_tail_x15_r0_body.cband124 : PRE_first_tail_x15_r0_body.kd124.checkBand PRE_first_tail_x15_r0_body.P124.lo = true
kernel_rfl PRE_first_tail_x15_r0_body.cnh1pos124 : Nat.blt 0 PRE_first_tail_x15_r0_body.kd124.nh1 = true
kernel_rfl PRE_first_tail_x15_r0_body.cnren124 : checkRenG PRE_first_tail_x15_r0_body.kd124.node PRE_first_tail_x15_r0_body.kninv124 (pnB PRE_first_tail_x15_r0_body.cx0_124.mlx) = true
kernel_rfl PRE_first_tail_x15_r0_body.cnlow124 : (PTrie.keysA PRE_first_tail_x15_r0_body.kd124.node).all (fun j => Nat.ble PRE_first_tail_x15_r0_body.P124.NL j && Nat.blt (PRE_first_tail_x15_r0_body.kd124.nodeF j) PRE_first_tail_x15_r0_body.cx1_124.mlx.nnext) = true
kernel_rfl PRE_first_tail_x15_r0_body.cabs0a124 : PRE_first_tail_x15_r0_body.cx0_124.mlx.arrs.get 0 = none
kernel_rfl PRE_first_tail_x15_r0_body.cabs0b124 : PRE_first_tail_x15_r0_body.cx0_124.mlx.objs.get 0 = none
kernel_rfl PRE_first_tail_x15_r0_body.ctok1124 : PRE_first_tail_x15_r0_body.cx1_124.mlx.tokens = []
kernel_rfl PRE_first_tail_x15_r0_body.cpend124 : PRE_first_tail_x15_r0_body.cx1_124.mlx.pending = PRE_first_tail_x15_r0_body.cx0_124.mlx.pending.map PRE_first_tail_x15_r0_body.kappa124.pend
kernel_rfl PRE_first_tail_x15_r0_body.cerrh124 : PRE_first_tail_x15_r0_body.cx1_124.mlx.errh = PRE_first_tail_x15_r0_body.cx0_124.mlx.errh.map PRE_first_tail_x15_r0_body.kappa124.arg
kernel_rfl PRE_first_tail_x15_r0_body.cfiles124 : PRE_first_tail_x15_r0_body.cx1_124.mlx.files = PRE_first_tail_x15_r0_body.cx0_124.mlx.files
kernel_rfl PRE_first_tail_x15_r0_body.carch124 : PRE_first_tail_x15_r0_body.cx1_124.mlx.arch = PRE_first_tail_x15_r0_body.cx0_124.mlx.arch
kernel_rfl PRE_first_tail_x15_r0_body.csizes124 : PRE_first_tail_x15_r0_body.cx1_124.mlx.deviceSizes = PRE_first_tail_x15_r0_body.cx0_124.mlx.deviceSizes
kernel_rfl PRE_first_tail_x15_r0_body.cwired124 : PRE_first_tail_x15_r0_body.cx1_124.mlx.wired = PRE_first_tail_x15_r0_body.cx0_124.mlx.wired
kernel_rfl PRE_first_tail_x15_r0_body.chost124 : PRE_first_tail_x15_r0_body.cx1_124.host = PRE_first_tail_x15_r0_body.cx0_124.host
-- the compaction map's addresses are `PRE_first_tail_x15_r0_body.kd124`'s
kernel_rfl PRE_first_tail_x15_r0_body.ckn0124 : PRE_first_tail_x15_r0_body.kd124.n0 = 2772375
kernel_rfl PRE_first_tail_x15_r0_body.ckn1124 : PRE_first_tail_x15_r0_body.kd124.n1 = 2772377
kernel_rfl PRE_first_tail_x15_r0_body.ckheap124 : (PTrie.keysA PRE_first_tail_x15_r0_body.kd124.heap).all (fun x => Nat.ble 2772375 x) = true
kernel_rfl PRE_first_tail_x15_r0_body.ckpl124 : (List.range 0).all (fun j => decide (PRE_first_tail_x15_r0_body.kd124.heap.get (2772375 + j) = nth? PRE_first_tail_x15_r0_body.pl124 j)) = true
-- the map fixes the call's names (`Conv.fixOld_compact`), the call's counters
kernel_rfl PRE_first_tail_x15_r0_body.fja124 : Nat.ble 2772375 2772375 = true
kernel_rfl PRE_first_tail_x15_r0_body.fn124 : Nat.ble 5381 5381 = true
kernel_rfl PRE_first_tail_x15_r0_body.fjaD124 : Nat.ble 2772375 PRE_first_tail_x15_r0_body.kd124.n0 = true
kernel_rfl PRE_first_tail_x15_r0_body.fxn124 : Nat.ble 20649 PRE_first_tail_x15_r0_body.kd124.nh0 = true
kernel_rfl PRE_first_tail_x15_r0_body.fnn124 : Nat.ble 17751 PRE_first_tail_x15_r0_body.kd124.nn0 = true
kernel_rfl PRE_first_tail_x15_r0_body.fxb124 : Nat.ble 20649 RData.bigHi = true
kernel_rfl PRE_first_tail_x15_r0_body.fheap124 : (PTrie.keysA PRE_first_tail_x15_r0_body.kd124.heap).all (Nat.ble (⟨20649, 17751, 2772375, 5381⟩ : Conv.Cnt).ja) = true
kernel_rfl PRE_first_tail_x15_r0_body.fhnd124 : (PTrie.keysA PRE_first_tail_x15_r0_body.kd124.hnd).all (Nat.ble (⟨20649, 17751, 2772375, 5381⟩ : Conv.Cnt).xn) = true
kernel_rfl PRE_first_tail_x15_r0_body.fnode124 : (PTrie.keysA PRE_first_tail_x15_r0_body.kd124.node).all (Nat.ble (⟨20649, 17751, 2772375, 5381⟩ : Conv.Cnt).nn) = true
/-- The compaction map fixes the call's names. -/
theorem PRE_first_tail_x15_r0_body.cfix124 : Conv.FixOld (⟨20649, 17751, 2772375, 5381⟩ : Conv.Cnt) PRE_first_tail_x15_r0_body.kappa124 :=
  Conv.fixOld_compact (Nat.le_of_ble_eq_true PRE_first_tail_x15_r0_body.fja124) (Nat.le_of_ble_eq_true PRE_first_tail_x15_r0_body.fn124) (Nat.le_of_ble_eq_true PRE_first_tail_x15_r0_body.fjaD124) (Nat.le_of_ble_eq_true PRE_first_tail_x15_r0_body.fxn124) (Nat.le_of_ble_eq_true PRE_first_tail_x15_r0_body.fnn124) (Nat.le_of_ble_eq_true PRE_first_tail_x15_r0_body.fxb124) PRE_first_tail_x15_r0_body.fheap124 PRE_first_tail_x15_r0_body.fhnd124 PRE_first_tail_x15_r0_body.fnode124
kernel_rfl PRE_first_tail_x15_r0_body.fcxn124 : (⟨20649, 17751, 2772375, 5381⟩ : Conv.Cnt).xn = (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1098.ffi).mlx.next
kernel_rfl PRE_first_tail_x15_r0_body.fcnn124 : (⟨20649, 17751, 2772375, 5381⟩ : Conv.Cnt).nn = (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1098.ffi).mlx.nnext
kernel_rfl PRE_first_tail_x15_r0_body.fle0124 : (Nat.ble (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1098.ffi).mlx.next PRE_first_tail_x15_r0_body.cx0_124.mlx.next && Nat.ble (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1098.ffi).mlx.nnext PRE_first_tail_x15_r0_body.cx0_124.mlx.nnext && Nat.ble (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1098.ffi).mlx.next RData.bigHi) = true
kernel_rfl PRE_first_tail_x15_r0_body.fnk124 : (PTrie.keysA PRE_first_tail_x15_r0_body.kd124.node).all (Nat.ble (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1098.ffi).mlx.nnext) = true
-- the merged state keeps the call's entries off the stage's footprint
kernel_rfl PRE_first_tail_x15_r0_body.f1A124 : PRE_first_tail_x15_r0_body.cx1_124.mlx.arrs = Stage.setAll (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1098.ffi).mlx.arrs (PRE_first_tail_x15_r0_body.cwS124.filterMap fun i => (PRE_first_tail_x15_r0_body.cx1_124.mlx.arrs.get i).map (i, ·))
kernel_rfl PRE_first_tail_x15_r0_body.f1O124 : PRE_first_tail_x15_r0_body.cx1_124.mlx.objs = Stage.setAll (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1098.ffi).mlx.objs (PRE_first_tail_x15_r0_body.cwS124.filterMap fun i => (PRE_first_tail_x15_r0_body.cx1_124.mlx.objs.get i).map (i, ·))
kernel_rfl PRE_first_tail_x15_r0_body.f1N124 : PRE_first_tail_x15_r0_body.cx1_124.mlx.nodes = Stage.setAll (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1098.ffi).mlx.nodes (PRE_first_tail_x15_r0_body.cnS124.filterMap fun i => (PRE_first_tail_x15_r0_body.cx1_124.mlx.nodes.get i).map (i, ·))
kernel_rfl PRE_first_tail_x15_r0_body.f1I124 : PRE_first_tail_x15_r0_body.cx1_124.mlx.items = Stage.setAll (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1098.ffi).mlx.items (PRE_first_tail_x15_r0_body.ciS124.filterMap fun i => (PRE_first_tail_x15_r0_body.cx1_124.mlx.items.get i).map (i, ·))
kernel_rfl PRE_first_tail_x15_r0_body.fbd124 : (PRE_first_tail_x15_r0_body.clo124 ++ PRE_first_tail_x15_r0_body.cln124 ++ PRE_first_tail_x15_r0_body.cli124 ++ PRE_first_tail_x15_r0_body.cwS124 ++ PRE_first_tail_x15_r0_body.cnS124 ++ PRE_first_tail_x15_r0_body.ciS124).all (fun i => Nat.blt (i / 4096) (4 ^ 31)) = true
kernel_rfl PRE_first_tail_x15_r0_body.fincW124 : PRE_first_tail_x15_r0_body.cwS124.all (fun h => !Nat.blt h (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1098.ffi).mlx.next || PRE_first_tail_x15_r0_body.clo124.contains h) = true
kernel_rfl PRE_first_tail_x15_r0_body.fincI124 : PRE_first_tail_x15_r0_body.ciS124.all (fun k => !Nat.blt k (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1098.ffi).mlx.nnext || PRE_first_tail_x15_r0_body.cli124.contains k) = true
kernel_rfl PRE_first_tail_x15_r0_body.fincN124 : PRE_first_tail_x15_r0_body.cnS124.all (Nat.ble (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1098.ffi).mlx.nnext) = true
kernel_rfl PRE_first_tail_x15_r0_body.flnF124 : PRE_first_tail_x15_r0_body.cln124.all (Nat.ble (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1098.ffi).mlx.nnext) = true
-- the checks over the changed lists
kernel_rfl PRE_first_tail_x15_r0_body.fh124 : PRE_first_tail_x15_r0_body.clo124.all (handleOK PRE_first_tail_x15_r0_body.kappa124 PRE_first_tail_x15_r0_body.P124.lo PRE_first_tail_x15_r0_body.cx0_124.mlx PRE_first_tail_x15_r0_body.cx1_124.mlx) = true
kernel_rfl PRE_first_tail_x15_r0_body.fo124 : PRE_first_tail_x15_r0_body.clo124.map (fun h => PRE_first_tail_x15_r0_body.cx1_124.mlx.objs.get (PRE_first_tail_x15_r0_body.kappa124.handle h)) = PRE_first_tail_x15_r0_body.clo124.map (fun h => (PRE_first_tail_x15_r0_body.cx0_124.mlx.objs.get h).map PRE_first_tail_x15_r0_body.kappa124.nobj)
kernel_rfl PRE_first_tail_x15_r0_body.fok124 : PRE_first_tail_x15_r0_body.clo124.all (objOK PRE_first_tail_x15_r0_body.kappa124 PRE_first_tail_x15_r0_body.P124.NL PRE_first_tail_x15_r0_body.cx0_124.mlx) = true
kernel_rfl PRE_first_tail_x15_r0_body.fnd124 : PRE_first_tail_x15_r0_body.cln124.all (nodeOKF PRE_first_tail_x15_r0_body.kappa124 PRE_first_tail_x15_r0_body.P124 PRE_first_tail_x15_r0_body.cx0_124.mlx PRE_first_tail_x15_r0_body.cx1_124.mlx) = true
kernel_rfl PRE_first_tail_x15_r0_body.fp124 : ((PRE_first_tail_x15_r0_body.cln124.filter (fullB PRE_first_tail_x15_r0_body.P124))).map (fun i => (PRE_first_tail_x15_r0_body.cx1_124.mlx.nodes.get (PRE_first_tail_x15_r0_body.kappa124.node i)).map Host.Mlx.Ffi.Node.prim) =
  ((PRE_first_tail_x15_r0_body.cln124.filter (fullB PRE_first_tail_x15_r0_body.P124))).map (fun i => (PRE_first_tail_x15_r0_body.cx0_124.mlx.nodes.get i).map fun nd => PRE_first_tail_x15_r0_body.kappa124.prim nd.prim)
kernel_rfl PRE_first_tail_x15_r0_body.fnordI124 : incrB PRE_first_tail_x15_r0_body.kd124.nodeF (List.range' 17751 0) = true
kernel_rfl PRE_first_tail_x15_r0_body.fnordK124 : (PTrie.keysA PRE_first_tail_x15_r0_body.kd124.node).all (fun k => Nat.ble 17751 k && Nat.blt k 17751) = true
kernel_rfl PRE_first_tail_x15_r0_body.fnordL124 : (PRE_first_tail_x15_r0_body.cln124.filter (Nat.ble PRE_first_tail_x15_r0_body.P124.N0)).all (fun i => Nat.ble i (PRE_first_tail_x15_r0_body.kd124.nodeF i) && (Nat.blt i 17751 || Nat.ble PRE_first_tail_x15_r0_body.kd124.nn0 i)) = true
theorem PRE_first_tail_x15_r0_body.fnord124 : (PRE_first_tail_x15_r0_body.cln124.filter (Nat.ble PRE_first_tail_x15_r0_body.P124.N0)).all (fun i => Nat.ble i (PRE_first_tail_x15_r0_body.kd124.nodeF i) &&
    (PTrie.keysA PRE_first_tail_x15_r0_body.kd124.node).all fun j => !Nat.blt j i || Nat.blt (PRE_first_tail_x15_r0_body.kd124.nodeF j) (PRE_first_tail_x15_r0_body.kd124.nodeF i)) = true :=
  cnord_of PRE_first_tail_x15_r0_body.cnlow124 PRE_first_tail_x15_r0_body.cnn1124 PRE_first_tail_x15_r0_body.fnordI124 PRE_first_tail_x15_r0_body.fnordK124 PRE_first_tail_x15_r0_body.fnordL124
kernel_rfl PRE_first_tail_x15_r0_body.fi124 : PRE_first_tail_x15_r0_body.cli124.all (pnB PRE_first_tail_x15_r0_body.cx0_124.mlx) = true
kernel_rfl PRE_first_tail_x15_r0_body.fii124 : PRE_first_tail_x15_r0_body.cli124.all (fun k => decide (PRE_first_tail_x15_r0_body.cx1_124.mlx.items.get (PRE_first_tail_x15_r0_body.kappa124.node k) = (PRE_first_tail_x15_r0_body.cx0_124.mlx.items.get k).map PRE_first_tail_x15_r0_body.kappa124.nv)) = true
/-- **The compaction's footprint.** -/
theorem PRE_first_tail_x15_r0_body.cfoot124 (clean : Conv.NClean (⟨20649, 17751, 2772375, 5381⟩ : Conv.Cnt) (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1098.ffi).mlx) (hltC : ∀ h, PH (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1098.ffi).mlx h → h < (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1098.ffi).mlx.next) (nltC : ∀ i, PN (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1098.ffi).mlx i → i < (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1098.ffi).mlx.nnext) (itemsC : ∀ k v, (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1098.ffi).mlx.items.get k = some v → PN (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1098.ffi).mlx k) (tracedC : ∀ h o, (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1098.ffi).mlx.objs.get h = some o → ∀ i ∈ objTraces o, i < PRE_first_tail_x15_r0_body.P124.NL) (cl : SSt (· < 5381) PRE_first_tail_x15_r0_body.cx0_124.mlx) :
    Conv.MFoot PRE_first_tail_x15_r0_body.P124 5381 PRE_first_tail_x15_r0_body.kappa124 PRE_first_tail_x15_r0_body.kd124 PRE_first_tail_x15_r0_body.khinv124 PRE_first_tail_x15_r0_body.kninv124 (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1098.ffi).mlx PRE_first_tail_x15_r0_body.cx0_124.mlx PRE_first_tail_x15_r0_body.cx1_124.mlx (⟨20649, 17751, 2772375, 5381⟩ : Conv.Cnt) PRE_first_tail_x15_r0_body.clo124 PRE_first_tail_x15_r0_body.cln124 PRE_first_tail_x15_r0_body.cli124 PRE_first_tail_x15_r0_body.cwS124 PRE_first_tail_x15_r0_body.cnS124 PRE_first_tail_x15_r0_body.ciS124 :=
  ⟨rfl, rfl, rfl, PRE_first_tail_x15_r0_body.cnh0124, PRE_first_tail_x15_r0_body.cnh1124, PRE_first_tail_x15_r0_body.cnn0124, PRE_first_tail_x15_r0_body.cnn1124, PRE_first_tail_x15_r0_body.cplo124, PRE_first_tail_x15_r0_body.ccnt124, PRE_first_tail_x15_r0_body.cnband124, PRE_first_tail_x15_r0_body.chbelow124, PRE_first_tail_x15_r0_body.chren124, PRE_first_tail_x15_r0_body.cband124, PRE_first_tail_x15_r0_body.cnh1pos124, PRE_first_tail_x15_r0_body.cnren124, PRE_first_tail_x15_r0_body.cnlow124, PRE_first_tail_x15_r0_body.cabs0a124, PRE_first_tail_x15_r0_body.cabs0b124, PRE_first_tail_x15_r0_body.ctok1124, PRE_first_tail_x15_r0_body.cpend124, PRE_first_tail_x15_r0_body.cerrh124, PRE_first_tail_x15_r0_body.cfiles124, PRE_first_tail_x15_r0_body.carch124, PRE_first_tail_x15_r0_body.csizes124, PRE_first_tail_x15_r0_body.cwired124, PRE_first_tail_x15_r0_body.cfix124, clean, PRE_first_tail_x15_r0_body.fcxn124, PRE_first_tail_x15_r0_body.fcnn124, hltC, nltC, itemsC, tracedC, cl, PRE_first_tail_x15_r0_body.fle0124, PRE_first_tail_x15_r0_body.fnk124, PRE_first_tail_x15_r0_body.ckA124, PRE_first_tail_x15_r0_body.cobjsK124, PRE_first_tail_x15_r0_body.cnodesK124, PRE_first_tail_x15_r0_body.citemsK124, PRE_first_tail_x15_r0_body.f1A124, PRE_first_tail_x15_r0_body.f1O124, PRE_first_tail_x15_r0_body.f1N124, PRE_first_tail_x15_r0_body.f1I124, PRE_first_tail_x15_r0_body.fbd124, PRE_first_tail_x15_r0_body.fincW124, PRE_first_tail_x15_r0_body.fincI124, PRE_first_tail_x15_r0_body.fincN124, PRE_first_tail_x15_r0_body.flnF124, PRE_first_tail_x15_r0_body.fh124, PRE_first_tail_x15_r0_body.fo124, PRE_first_tail_x15_r0_body.fok124, PRE_first_tail_x15_r0_body.fnd124, PRE_first_tail_x15_r0_body.fp124, PRE_first_tail_x15_r0_body.fnord124, PRE_first_tail_x15_r0_body.fi124, PRE_first_tail_x15_r0_body.fii124⟩
theorem PRE_first_tail_x15_r0_body.cnshift124 (clean : Conv.NClean (⟨20649, 17751, 2772375, 5381⟩ : Conv.Cnt) (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1098.ffi).mlx) (hltC : ∀ h, PH (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1098.ffi).mlx h → h < (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1098.ffi).mlx.next) (nltC : ∀ i, PN (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1098.ffi).mlx i → i < (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1098.ffi).mlx.nnext) (itemsC : ∀ k v, (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1098.ffi).mlx.items.get k = some v → PN (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1098.ffi).mlx k) (tracedC : ∀ h o, (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1098.ffi).mlx.objs.get h = some o → ∀ i ∈ objTraces o, i < PRE_first_tail_x15_r0_body.P124.NL) (cl : SSt (· < 5381) PRE_first_tail_x15_r0_body.cx0_124.mlx) : NShift PRE_first_tail_x15_r0_body.P124 5381 PRE_first_tail_x15_r0_body.kappa124 PRE_first_tail_x15_r0_body.cx0_124 PRE_first_tail_x15_r0_body.cx1_124 :=
  Conv.nshift_of_foot (PRE_first_tail_x15_r0_body.cfoot124 clean hltC nltC itemsC tracedC cl) PRE_first_tail_x15_r0_body.chost124 (compact_a_eq PRE_first_tail_x15_r0_body.ckn0124 PRE_first_tail_x15_r0_body.ckn1124 PRE_first_tail_x15_r0_body.ckheap124 PRE_first_tail_x15_r0_body.ckpl124)

-- the observers: the layers' states at the call, the canonical and the merged state, their footprints and checks
noncomputable def PRE_first_tail_x15_r0_body.fxC_124 : PTrie Unit := (Host.Ts.Sim.Full.freedOf PRE_first_tail_x15_r0_body.s1098.ffi).getD PTrie.nil
noncomputable def PRE_first_tail_x15_r0_body.krC_124 : Host.Load.Layers.KRec := (Host.Ts.Sim.Full.krecOf PRE_first_tail_x15_r0_body.s1098.ffi).getD Host.Load.Layers.KRec.empty
kernel_rfl PRE_first_tail_x15_r0_body.ofxC_124 : (Host.Ts.Sim.Full.freedOf PRE_first_tail_x15_r0_body.s1098.ffi) = some PRE_first_tail_x15_r0_body.fxC_124
kernel_rfl PRE_first_tail_x15_r0_body.okrC_124 : (Host.Ts.Sim.Full.krecOf PRE_first_tail_x15_r0_body.s1098.ffi) = some PRE_first_tail_x15_r0_body.krC_124
noncomputable def PRE_first_tail_x15_r0_body.fx0_124 : PTrie Unit := (Host.Ts.Sim.Full.freedOf PRE_first_tail_x15_r0_body.s1100.ffi).getD PTrie.nil
noncomputable def PRE_first_tail_x15_r0_body.kr0_124 : Host.Load.Layers.KRec := (Host.Ts.Sim.Full.krecOf PRE_first_tail_x15_r0_body.s1100.ffi).getD Host.Load.Layers.KRec.empty
kernel_rfl PRE_first_tail_x15_r0_body.ofx0_124 : (Host.Ts.Sim.Full.freedOf PRE_first_tail_x15_r0_body.s1100.ffi) = some PRE_first_tail_x15_r0_body.fx0_124
kernel_rfl PRE_first_tail_x15_r0_body.okr0_124 : (Host.Ts.Sim.Full.krecOf PRE_first_tail_x15_r0_body.s1100.ffi) = some PRE_first_tail_x15_r0_body.kr0_124
noncomputable def PRE_first_tail_x15_r0_body.fx1_124 : PTrie Unit := (Host.Ts.Sim.Full.freedOf PRE_first_tail_x15_r0_body.s1099.ffi).getD PTrie.nil
noncomputable def PRE_first_tail_x15_r0_body.kr1_124 : Host.Load.Layers.KRec := (Host.Ts.Sim.Full.krecOf PRE_first_tail_x15_r0_body.s1099.ffi).getD Host.Load.Layers.KRec.empty
kernel_rfl PRE_first_tail_x15_r0_body.ofx1_124 : (Host.Ts.Sim.Full.freedOf PRE_first_tail_x15_r0_body.s1099.ffi) = some PRE_first_tail_x15_r0_body.fx1_124
kernel_rfl PRE_first_tail_x15_r0_body.okr1_124 : (Host.Ts.Sim.Full.krecOf PRE_first_tail_x15_r0_body.s1099.ffi) = some PRE_first_tail_x15_r0_body.kr1_124
kernel_rfl PRE_first_tail_x15_r0_body.ff0124 : PRE_first_tail_x15_r0_body.fx0_124 = Stage.setAll PRE_first_tail_x15_r0_body.fxC_124 (PRE_first_tail_x15_r0_body.clo124.filterMap fun i => (PRE_first_tail_x15_r0_body.fx0_124.get i).map (i, ·))
kernel_rfl PRE_first_tail_x15_r0_body.ff1124 : PRE_first_tail_x15_r0_body.fx1_124 = Stage.setAll PRE_first_tail_x15_r0_body.fxC_124 (PRE_first_tail_x15_r0_body.cwS124.filterMap fun i => (PRE_first_tail_x15_r0_body.fx1_124.get i).map (i, ·))
kernel_rfl PRE_first_tail_x15_r0_body.ffck124 : freedLB PRE_first_tail_x15_r0_body.kappa124 PRE_first_tail_x15_r0_body.cx0_124.mlx PRE_first_tail_x15_r0_body.fx0_124 PRE_first_tail_x15_r0_body.fx1_124 PRE_first_tail_x15_r0_body.clo124 = true
kernel_rfl PRE_first_tail_x15_r0_body.fkf0124 : PRE_first_tail_x15_r0_body.kr0_124.flags = Stage.setAll PRE_first_tail_x15_r0_body.krC_124.flags (PRE_first_tail_x15_r0_body.clo124.filterMap fun i => (PRE_first_tail_x15_r0_body.kr0_124.flags.get i).map (i, ·))
kernel_rfl PRE_first_tail_x15_r0_body.fkt0124 : PRE_first_tail_x15_r0_body.kr0_124.targs = Stage.setAll PRE_first_tail_x15_r0_body.krC_124.targs (PRE_first_tail_x15_r0_body.clo124.filterMap fun i => (PRE_first_tail_x15_r0_body.kr0_124.targs.get i).map (i, ·))
kernel_rfl PRE_first_tail_x15_r0_body.fkf1124 : PRE_first_tail_x15_r0_body.kr1_124.flags = Stage.setAll PRE_first_tail_x15_r0_body.krC_124.flags (PRE_first_tail_x15_r0_body.cwS124.filterMap fun i => (PRE_first_tail_x15_r0_body.kr1_124.flags.get i).map (i, ·))
kernel_rfl PRE_first_tail_x15_r0_body.fkt1124 : PRE_first_tail_x15_r0_body.kr1_124.targs = Stage.setAll PRE_first_tail_x15_r0_body.krC_124.targs (PRE_first_tail_x15_r0_body.cwS124.filterMap fun i => (PRE_first_tail_x15_r0_body.kr1_124.targs.get i).map (i, ·))
kernel_rfl PRE_first_tail_x15_r0_body.fkck124 : krecLB PRE_first_tail_x15_r0_body.kappa124 5381 PRE_first_tail_x15_r0_body.cx0_124.mlx PRE_first_tail_x15_r0_body.kr0_124 PRE_first_tail_x15_r0_body.kr1_124 PRE_first_tail_x15_r0_body.clo124 = true
kernel_rfl PRE_first_tail_x15_r0_body.fkn124 : Nat.ble 5381 5381 = true
-- the bridge and the pending traces' regions
kernel_rfl PRE_first_tail_x15_r0_body.cbridge124 : Host.Ts.Sim.Full.bridgeOf PRE_first_tail_x15_r0_body.s1099.ffi = Host.Ts.Sim.Full.bridgeOf PRE_first_tail_x15_r0_body.s1100.ffi
kernel_rfl PRE_first_tail_x15_r0_body.cpendR124 : pendRegB PRE_first_tail_x15_r0_body.kappa124 (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1100.ffi).mlx = true
kernel_rfl PRE_first_tail_x15_r0_body.cpendLe124 : Nat.ble (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1100.ffi).mlx.next (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1099.ffi).mlx.next = true
/-- **The compaction's native shift**, given the call's bookkeeping, its relation's facts (the model's and the
observers') and the canonical closedness. -/
theorem PRE_first_tail_x15_r0_body.cshift124 (clean : Conv.NClean (⟨20649, 17751, 2772375, 5381⟩ : Conv.Cnt) (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1098.ffi).mlx) (hltC : ∀ h, PH (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1098.ffi).mlx h → h < (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1098.ffi).mlx.next) (nltC : ∀ i, PN (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1098.ffi).mlx i → i < (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1098.ffi).mlx.nnext) (itemsC : ∀ k v, (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1098.ffi).mlx.items.get k = some v → PN (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1098.ffi).mlx k) (tracedC : ∀ h o, (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1098.ffi).mlx.objs.get h = some o → ∀ i ∈ objTraces o, i < PRE_first_tail_x15_r0_body.P124.NL) (cl : SSt (· < 5381) PRE_first_tail_x15_r0_body.cx0_124.mlx)
    (hobjC : ∀ h, PRE_first_tail_x15_r0_body.fxC_124.get h = some () → ((Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1098.ffi).mlx.objs.get h).isSome = true)
    (hfC : ∀ h, (PRE_first_tail_x15_r0_body.krC_124.flags.get h).isSome = true → ((Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1098.ffi).mlx.objs.get h).isSome = true)
    (htC : ∀ h, (PRE_first_tail_x15_r0_body.krC_124.targs.get h).isSome = true → ((Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1098.ffi).mlx.objs.get h).isSome = true)
    (hclC : ∀ h l, PRE_first_tail_x15_r0_body.krC_124.targs.get h = some l → Host.Ts.Sim.Full.STargs (· < (⟨20649, 17751, 2772375, 5381⟩ : Conv.Cnt).n) l) :
    Conv.FullShiftQ PRE_first_tail_x15_r0_body.P124 5381 PRE_first_tail_x15_r0_body.kappa124 PRE_first_tail_x15_r0_body.s1100.ffi PRE_first_tail_x15_r0_body.s1099.ffi :=
  ⟨PRE_first_tail_x15_r0_body.cnshift124 clean hltC nltC itemsC tracedC cl, PRE_first_tail_x15_r0_body.cqueue124, fun t ht => bSN_sound (List.all_eq_true.mp PRE_first_tail_x15_r0_body.ctokSupp124 t ht),
    PRE_first_tail_x15_r0_body.cbridge124,
    liveShift_foot (x0' := Host.Ts.Sim.Full.mlxOf PRE_first_tail_x15_r0_body.s1100.ffi) (x1' := Host.Ts.Sim.Full.mlxOf PRE_first_tail_x15_r0_body.s1099.ffi) (PRE_first_tail_x15_r0_body.cfoot124 clean hltC nltC itemsC tracedC cl) rfl PRE_first_tail_x15_r0_body.ofx0_124 PRE_first_tail_x15_r0_body.ofx1_124 hobjC PRE_first_tail_x15_r0_body.ff0124 PRE_first_tail_x15_r0_body.ff1124 PRE_first_tail_x15_r0_body.ffck124,
    kernShift_foot (x0' := Host.Ts.Sim.Full.mlxOf PRE_first_tail_x15_r0_body.s1100.ffi) (x1' := Host.Ts.Sim.Full.mlxOf PRE_first_tail_x15_r0_body.s1099.ffi) (PRE_first_tail_x15_r0_body.cfoot124 clean hltC nltC itemsC tracedC cl) rfl PRE_first_tail_x15_r0_body.okr0_124 PRE_first_tail_x15_r0_body.okr1_124 (Nat.le_of_ble_eq_true PRE_first_tail_x15_r0_body.fkn124) hfC htC hclC
      PRE_first_tail_x15_r0_body.fkf0124 PRE_first_tail_x15_r0_body.fkt0124 PRE_first_tail_x15_r0_body.fkf1124 PRE_first_tail_x15_r0_body.fkt1124 PRE_first_tail_x15_r0_body.fkck124,
    pendReg_of rfl PRE_first_tail_x15_r0_body.cnh0124 PRE_first_tail_x15_r0_body.cnh1124 (Nat.le_of_ble_eq_true PRE_first_tail_x15_r0_body.cpendLe124) PRE_first_tail_x15_r0_body.cpendR124⟩

end Host.Load.Run.Tpl
