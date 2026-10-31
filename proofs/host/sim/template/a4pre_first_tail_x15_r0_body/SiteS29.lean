import host.sim.template.a4pre_first_tail_x15_r0_body.SiteCl29
import host.sim.conv.CompactFull
import host.sim.template.FootGen
set_option Elab.async false
namespace Host.Load.Run.Tpl
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
open Host.Ts Host.Ts.Sim Host.Ts.Sim.Template

/-! The compaction's native shift at call site 29 from its footprint (`Conv.nshift_of_foot`), and the observers'
(`liveShift_foot`, `kernShift_foot`): `Conv.FullShiftQ` for `Conv.full_compactQ`, given the call's bookkeeping and its
relation's facts. -/

/-- The load parameters of the chain (band-free: its start's node counter as `NL` and `N0`). -/
def PRE_first_tail_x15_r0_body.Pc29 : LoadP := ⟨18151, 131072, 1099511627776, 15235, 15235, []⟩
/-- The site's band raised to the map's checked fixed-node prefix, including newly recorded closure traces. -/
def PRE_first_tail_x15_r0_body.P29 : LoadP := PRE_first_tail_x15_r0_body.Pc29.raise 15859
kernel_rfl PRE_first_tail_x15_r0_body.craise29 : Nat.ble PRE_first_tail_x15_r0_body.Pc29.N0 15859 = true
theorem PRE_first_tail_x15_r0_body.raised29 : Host.Ts.Sim.Full.Raised PRE_first_tail_x15_r0_body.Pc29 PRE_first_tail_x15_r0_body.P29 :=
  .inr ⟨15859, rfl, Nat.le_of_ble_eq_true PRE_first_tail_x15_r0_body.craise29, rfl⟩
noncomputable abbrev PRE_first_tail_x15_r0_body.cx0_29 : Host.Load.LSt := clearTokens (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s264.ffi)
noncomputable abbrev PRE_first_tail_x15_r0_body.cx1_29 : Host.Load.LSt := clearTokens (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s263.ffi)
def PRE_first_tail_x15_r0_body.khinv29 : PTrie Nat := Stage.setAll PTrie.nil []
def PRE_first_tail_x15_r0_body.kninv29 : PTrie Nat := Stage.setAll PTrie.nil []
/-- The stage's footprint: its written and fresh handles, fresh nodes, written and fresh items. -/
def PRE_first_tail_x15_r0_body.cwS29 : List Nat := []
def PRE_first_tail_x15_r0_body.cnS29 : List Nat := List.range' 15859 0
def PRE_first_tail_x15_r0_body.ciS29 : List Nat := [] ++ List.range' 15859 0

-- the small checks (`MChecks`'s)
kernel_rfl PRE_first_tail_x15_r0_body.cnh029 : PRE_first_tail_x15_r0_body.kd29.nh0 = PRE_first_tail_x15_r0_body.cx0_29.mlx.next
kernel_rfl PRE_first_tail_x15_r0_body.cnh129 : PRE_first_tail_x15_r0_body.kd29.nh1 = PRE_first_tail_x15_r0_body.cx1_29.mlx.next
kernel_rfl PRE_first_tail_x15_r0_body.cnn029 : PRE_first_tail_x15_r0_body.kd29.nn0 = PRE_first_tail_x15_r0_body.cx0_29.mlx.nnext
kernel_rfl PRE_first_tail_x15_r0_body.cnn129 : PRE_first_tail_x15_r0_body.kd29.nn1 = PRE_first_tail_x15_r0_body.cx1_29.mlx.nnext
kernel_rfl PRE_first_tail_x15_r0_body.cplo29 : (Nat.blt 0 PRE_first_tail_x15_r0_body.P29.lo && Nat.ble PRE_first_tail_x15_r0_body.P29.lo PRE_first_tail_x15_r0_body.cx0_29.mlx.next && Nat.ble PRE_first_tail_x15_r0_body.P29.lo RData.bigHi && Nat.ble RData.bigHi PRE_first_tail_x15_r0_body.P29.E) = true
kernel_rfl PRE_first_tail_x15_r0_body.ccnt29 : (Nat.ble PRE_first_tail_x15_r0_body.cx0_29.mlx.next PRE_first_tail_x15_r0_body.cx1_29.mlx.next && Nat.ble PRE_first_tail_x15_r0_body.cx0_29.mlx.nnext PRE_first_tail_x15_r0_body.cx1_29.mlx.nnext) = true
kernel_rfl PRE_first_tail_x15_r0_body.cnband29 : (Nat.blt 0 PRE_first_tail_x15_r0_body.P29.NL && Nat.ble PRE_first_tail_x15_r0_body.P29.NL PRE_first_tail_x15_r0_body.P29.N0 && Nat.ble PRE_first_tail_x15_r0_body.P29.N0 PRE_first_tail_x15_r0_body.cx0_29.mlx.nnext) = true
kernel_rfl PRE_first_tail_x15_r0_body.chbelow29 : PRE_first_tail_x15_r0_body.kd29.checkHndBelow = true
kernel_rfl PRE_first_tail_x15_r0_body.chren29 : checkRenG PRE_first_tail_x15_r0_body.kd29.hnd PRE_first_tail_x15_r0_body.khinv29 (phB PRE_first_tail_x15_r0_body.cx0_29.mlx) = true
kernel_rfl PRE_first_tail_x15_r0_body.cband29 : PRE_first_tail_x15_r0_body.kd29.checkBand PRE_first_tail_x15_r0_body.P29.lo = true
kernel_rfl PRE_first_tail_x15_r0_body.cnh1pos29 : Nat.blt 0 PRE_first_tail_x15_r0_body.kd29.nh1 = true
kernel_rfl PRE_first_tail_x15_r0_body.cnren29 : checkRenG PRE_first_tail_x15_r0_body.kd29.node PRE_first_tail_x15_r0_body.kninv29 (pnB PRE_first_tail_x15_r0_body.cx0_29.mlx) = true
kernel_rfl PRE_first_tail_x15_r0_body.cnlow29 : (PTrie.keysA PRE_first_tail_x15_r0_body.kd29.node).all (fun j => Nat.ble PRE_first_tail_x15_r0_body.P29.NL j && Nat.blt (PRE_first_tail_x15_r0_body.kd29.nodeF j) PRE_first_tail_x15_r0_body.cx1_29.mlx.nnext) = true
kernel_rfl PRE_first_tail_x15_r0_body.cabs0a29 : PRE_first_tail_x15_r0_body.cx0_29.mlx.arrs.get 0 = none
kernel_rfl PRE_first_tail_x15_r0_body.cabs0b29 : PRE_first_tail_x15_r0_body.cx0_29.mlx.objs.get 0 = none
kernel_rfl PRE_first_tail_x15_r0_body.ctok129 : PRE_first_tail_x15_r0_body.cx1_29.mlx.tokens = []
kernel_rfl PRE_first_tail_x15_r0_body.cpend29 : PRE_first_tail_x15_r0_body.cx1_29.mlx.pending = PRE_first_tail_x15_r0_body.cx0_29.mlx.pending.map PRE_first_tail_x15_r0_body.kappa29.pend
kernel_rfl PRE_first_tail_x15_r0_body.cerrh29 : PRE_first_tail_x15_r0_body.cx1_29.mlx.errh = PRE_first_tail_x15_r0_body.cx0_29.mlx.errh.map PRE_first_tail_x15_r0_body.kappa29.arg
kernel_rfl PRE_first_tail_x15_r0_body.cfiles29 : PRE_first_tail_x15_r0_body.cx1_29.mlx.files = PRE_first_tail_x15_r0_body.cx0_29.mlx.files
kernel_rfl PRE_first_tail_x15_r0_body.carch29 : PRE_first_tail_x15_r0_body.cx1_29.mlx.arch = PRE_first_tail_x15_r0_body.cx0_29.mlx.arch
kernel_rfl PRE_first_tail_x15_r0_body.csizes29 : PRE_first_tail_x15_r0_body.cx1_29.mlx.deviceSizes = PRE_first_tail_x15_r0_body.cx0_29.mlx.deviceSizes
kernel_rfl PRE_first_tail_x15_r0_body.cwired29 : PRE_first_tail_x15_r0_body.cx1_29.mlx.wired = PRE_first_tail_x15_r0_body.cx0_29.mlx.wired
kernel_rfl PRE_first_tail_x15_r0_body.chost29 : PRE_first_tail_x15_r0_body.cx1_29.host = PRE_first_tail_x15_r0_body.cx0_29.host
-- the compaction map's addresses are `PRE_first_tail_x15_r0_body.kd29`'s
kernel_rfl PRE_first_tail_x15_r0_body.ckn029 : PRE_first_tail_x15_r0_body.kd29.n0 = 2697328
kernel_rfl PRE_first_tail_x15_r0_body.ckn129 : PRE_first_tail_x15_r0_body.kd29.n1 = 2697338
kernel_rfl PRE_first_tail_x15_r0_body.ckheap29 : (PTrie.keysA PRE_first_tail_x15_r0_body.kd29.heap).all (fun x => Nat.ble 2697327 x) = true
kernel_rfl PRE_first_tail_x15_r0_body.ckpl29 : (List.range 1).all (fun j => decide (PRE_first_tail_x15_r0_body.kd29.heap.get (2697327 + j) = nth? PRE_first_tail_x15_r0_body.pl29 j)) = true
-- the map fixes the call's names (`Conv.fixOld_compact`), the call's counters
kernel_rfl PRE_first_tail_x15_r0_body.fja29 : Nat.ble 2697327 2697327 = true
kernel_rfl PRE_first_tail_x15_r0_body.fn29 : Nat.ble 1294 1294 = true
kernel_rfl PRE_first_tail_x15_r0_body.fjaD29 : Nat.ble 2697327 PRE_first_tail_x15_r0_body.kd29.n0 = true
kernel_rfl PRE_first_tail_x15_r0_body.fxn29 : Nat.ble 18768 PRE_first_tail_x15_r0_body.kd29.nh0 = true
kernel_rfl PRE_first_tail_x15_r0_body.fnn29 : Nat.ble 15859 PRE_first_tail_x15_r0_body.kd29.nn0 = true
kernel_rfl PRE_first_tail_x15_r0_body.fxb29 : Nat.ble 18768 RData.bigHi = true
kernel_rfl PRE_first_tail_x15_r0_body.fheap29 : (PTrie.keysA PRE_first_tail_x15_r0_body.kd29.heap).all (Nat.ble (⟨18768, 15859, 2697327, 1294⟩ : Conv.Cnt).ja) = true
kernel_rfl PRE_first_tail_x15_r0_body.fhnd29 : (PTrie.keysA PRE_first_tail_x15_r0_body.kd29.hnd).all (Nat.ble (⟨18768, 15859, 2697327, 1294⟩ : Conv.Cnt).xn) = true
kernel_rfl PRE_first_tail_x15_r0_body.fnode29 : (PTrie.keysA PRE_first_tail_x15_r0_body.kd29.node).all (Nat.ble (⟨18768, 15859, 2697327, 1294⟩ : Conv.Cnt).nn) = true
/-- The compaction map fixes the call's names. -/
theorem PRE_first_tail_x15_r0_body.cfix29 : Conv.FixOld (⟨18768, 15859, 2697327, 1294⟩ : Conv.Cnt) PRE_first_tail_x15_r0_body.kappa29 :=
  Conv.fixOld_compact (Nat.le_of_ble_eq_true PRE_first_tail_x15_r0_body.fja29) (Nat.le_of_ble_eq_true PRE_first_tail_x15_r0_body.fn29) (Nat.le_of_ble_eq_true PRE_first_tail_x15_r0_body.fjaD29) (Nat.le_of_ble_eq_true PRE_first_tail_x15_r0_body.fxn29) (Nat.le_of_ble_eq_true PRE_first_tail_x15_r0_body.fnn29) (Nat.le_of_ble_eq_true PRE_first_tail_x15_r0_body.fxb29) PRE_first_tail_x15_r0_body.fheap29 PRE_first_tail_x15_r0_body.fhnd29 PRE_first_tail_x15_r0_body.fnode29
kernel_rfl PRE_first_tail_x15_r0_body.fcxn29 : (⟨18768, 15859, 2697327, 1294⟩ : Conv.Cnt).xn = (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s262.ffi).mlx.next
kernel_rfl PRE_first_tail_x15_r0_body.fcnn29 : (⟨18768, 15859, 2697327, 1294⟩ : Conv.Cnt).nn = (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s262.ffi).mlx.nnext
kernel_rfl PRE_first_tail_x15_r0_body.fle029 : (Nat.ble (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s262.ffi).mlx.next PRE_first_tail_x15_r0_body.cx0_29.mlx.next && Nat.ble (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s262.ffi).mlx.nnext PRE_first_tail_x15_r0_body.cx0_29.mlx.nnext && Nat.ble (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s262.ffi).mlx.next RData.bigHi) = true
kernel_rfl PRE_first_tail_x15_r0_body.fnk29 : (PTrie.keysA PRE_first_tail_x15_r0_body.kd29.node).all (Nat.ble (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s262.ffi).mlx.nnext) = true
-- the merged state keeps the call's entries off the stage's footprint
kernel_rfl PRE_first_tail_x15_r0_body.f1A29 : PRE_first_tail_x15_r0_body.cx1_29.mlx.arrs = Stage.setAll (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s262.ffi).mlx.arrs (PRE_first_tail_x15_r0_body.cwS29.filterMap fun i => (PRE_first_tail_x15_r0_body.cx1_29.mlx.arrs.get i).map (i, ·))
kernel_rfl PRE_first_tail_x15_r0_body.f1O29 : PRE_first_tail_x15_r0_body.cx1_29.mlx.objs = Stage.setAll (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s262.ffi).mlx.objs (PRE_first_tail_x15_r0_body.cwS29.filterMap fun i => (PRE_first_tail_x15_r0_body.cx1_29.mlx.objs.get i).map (i, ·))
kernel_rfl PRE_first_tail_x15_r0_body.f1N29 : PRE_first_tail_x15_r0_body.cx1_29.mlx.nodes = Stage.setAll (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s262.ffi).mlx.nodes (PRE_first_tail_x15_r0_body.cnS29.filterMap fun i => (PRE_first_tail_x15_r0_body.cx1_29.mlx.nodes.get i).map (i, ·))
kernel_rfl PRE_first_tail_x15_r0_body.f1I29 : PRE_first_tail_x15_r0_body.cx1_29.mlx.items = Stage.setAll (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s262.ffi).mlx.items (PRE_first_tail_x15_r0_body.ciS29.filterMap fun i => (PRE_first_tail_x15_r0_body.cx1_29.mlx.items.get i).map (i, ·))
kernel_rfl PRE_first_tail_x15_r0_body.fbd29 : (PRE_first_tail_x15_r0_body.clo29 ++ PRE_first_tail_x15_r0_body.cln29 ++ PRE_first_tail_x15_r0_body.cli29 ++ PRE_first_tail_x15_r0_body.cwS29 ++ PRE_first_tail_x15_r0_body.cnS29 ++ PRE_first_tail_x15_r0_body.ciS29).all (fun i => Nat.blt (i / 4096) (4 ^ 31)) = true
kernel_rfl PRE_first_tail_x15_r0_body.fincW29 : PRE_first_tail_x15_r0_body.cwS29.all (fun h => !Nat.blt h (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s262.ffi).mlx.next || PRE_first_tail_x15_r0_body.clo29.contains h) = true
kernel_rfl PRE_first_tail_x15_r0_body.fincI29 : PRE_first_tail_x15_r0_body.ciS29.all (fun k => !Nat.blt k (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s262.ffi).mlx.nnext || PRE_first_tail_x15_r0_body.cli29.contains k) = true
kernel_rfl PRE_first_tail_x15_r0_body.fincN29 : PRE_first_tail_x15_r0_body.cnS29.all (Nat.ble (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s262.ffi).mlx.nnext) = true
kernel_rfl PRE_first_tail_x15_r0_body.flnF29 : PRE_first_tail_x15_r0_body.cln29.all (Nat.ble (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s262.ffi).mlx.nnext) = true
-- the checks over the changed lists
kernel_rfl PRE_first_tail_x15_r0_body.fh29 : PRE_first_tail_x15_r0_body.clo29.all (handleOK PRE_first_tail_x15_r0_body.kappa29 PRE_first_tail_x15_r0_body.P29.lo PRE_first_tail_x15_r0_body.cx0_29.mlx PRE_first_tail_x15_r0_body.cx1_29.mlx) = true
kernel_rfl PRE_first_tail_x15_r0_body.fo29 : PRE_first_tail_x15_r0_body.clo29.map (fun h => PRE_first_tail_x15_r0_body.cx1_29.mlx.objs.get (PRE_first_tail_x15_r0_body.kappa29.handle h)) = PRE_first_tail_x15_r0_body.clo29.map (fun h => (PRE_first_tail_x15_r0_body.cx0_29.mlx.objs.get h).map PRE_first_tail_x15_r0_body.kappa29.nobj)
kernel_rfl PRE_first_tail_x15_r0_body.fok29 : PRE_first_tail_x15_r0_body.clo29.all (objOK PRE_first_tail_x15_r0_body.kappa29 PRE_first_tail_x15_r0_body.P29.NL PRE_first_tail_x15_r0_body.cx0_29.mlx) = true
kernel_rfl PRE_first_tail_x15_r0_body.fnd29 : PRE_first_tail_x15_r0_body.cln29.all (nodeOKF PRE_first_tail_x15_r0_body.kappa29 PRE_first_tail_x15_r0_body.P29 PRE_first_tail_x15_r0_body.cx0_29.mlx PRE_first_tail_x15_r0_body.cx1_29.mlx) = true
kernel_rfl PRE_first_tail_x15_r0_body.fp29 : ((PRE_first_tail_x15_r0_body.cln29.filter (fullB PRE_first_tail_x15_r0_body.P29))).map (fun i => (PRE_first_tail_x15_r0_body.cx1_29.mlx.nodes.get (PRE_first_tail_x15_r0_body.kappa29.node i)).map Host.Mlx.Ffi.Node.prim) =
  ((PRE_first_tail_x15_r0_body.cln29.filter (fullB PRE_first_tail_x15_r0_body.P29))).map (fun i => (PRE_first_tail_x15_r0_body.cx0_29.mlx.nodes.get i).map fun nd => PRE_first_tail_x15_r0_body.kappa29.prim nd.prim)
kernel_rfl PRE_first_tail_x15_r0_body.fnordI29 : incrB PRE_first_tail_x15_r0_body.kd29.nodeF (List.range' 15859 0) = true
kernel_rfl PRE_first_tail_x15_r0_body.fnordK29 : (PTrie.keysA PRE_first_tail_x15_r0_body.kd29.node).all (fun k => Nat.ble 15859 k && Nat.blt k 15859) = true
kernel_rfl PRE_first_tail_x15_r0_body.fnordL29 : (PRE_first_tail_x15_r0_body.cln29.filter (Nat.ble PRE_first_tail_x15_r0_body.P29.N0)).all (fun i => Nat.ble i (PRE_first_tail_x15_r0_body.kd29.nodeF i) && (Nat.blt i 15859 || Nat.ble PRE_first_tail_x15_r0_body.kd29.nn0 i)) = true
theorem PRE_first_tail_x15_r0_body.fnord29 : (PRE_first_tail_x15_r0_body.cln29.filter (Nat.ble PRE_first_tail_x15_r0_body.P29.N0)).all (fun i => Nat.ble i (PRE_first_tail_x15_r0_body.kd29.nodeF i) &&
    (PTrie.keysA PRE_first_tail_x15_r0_body.kd29.node).all fun j => !Nat.blt j i || Nat.blt (PRE_first_tail_x15_r0_body.kd29.nodeF j) (PRE_first_tail_x15_r0_body.kd29.nodeF i)) = true :=
  cnord_of PRE_first_tail_x15_r0_body.cnlow29 PRE_first_tail_x15_r0_body.cnn129 PRE_first_tail_x15_r0_body.fnordI29 PRE_first_tail_x15_r0_body.fnordK29 PRE_first_tail_x15_r0_body.fnordL29
kernel_rfl PRE_first_tail_x15_r0_body.fi29 : PRE_first_tail_x15_r0_body.cli29.all (pnB PRE_first_tail_x15_r0_body.cx0_29.mlx) = true
kernel_rfl PRE_first_tail_x15_r0_body.fii29 : PRE_first_tail_x15_r0_body.cli29.all (fun k => decide (PRE_first_tail_x15_r0_body.cx1_29.mlx.items.get (PRE_first_tail_x15_r0_body.kappa29.node k) = (PRE_first_tail_x15_r0_body.cx0_29.mlx.items.get k).map PRE_first_tail_x15_r0_body.kappa29.nv)) = true
/-- **The compaction's footprint.** -/
theorem PRE_first_tail_x15_r0_body.cfoot29 (clean : Conv.NClean (⟨18768, 15859, 2697327, 1294⟩ : Conv.Cnt) (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s262.ffi).mlx) (hltC : ∀ h, PH (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s262.ffi).mlx h → h < (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s262.ffi).mlx.next) (nltC : ∀ i, PN (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s262.ffi).mlx i → i < (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s262.ffi).mlx.nnext) (itemsC : ∀ k v, (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s262.ffi).mlx.items.get k = some v → PN (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s262.ffi).mlx k) (tracedC : ∀ h o, (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s262.ffi).mlx.objs.get h = some o → ∀ i ∈ objTraces o, i < PRE_first_tail_x15_r0_body.P29.NL) (cl : SSt (· < 1294) PRE_first_tail_x15_r0_body.cx0_29.mlx) :
    Conv.MFoot PRE_first_tail_x15_r0_body.P29 1294 PRE_first_tail_x15_r0_body.kappa29 PRE_first_tail_x15_r0_body.kd29 PRE_first_tail_x15_r0_body.khinv29 PRE_first_tail_x15_r0_body.kninv29 (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s262.ffi).mlx PRE_first_tail_x15_r0_body.cx0_29.mlx PRE_first_tail_x15_r0_body.cx1_29.mlx (⟨18768, 15859, 2697327, 1294⟩ : Conv.Cnt) PRE_first_tail_x15_r0_body.clo29 PRE_first_tail_x15_r0_body.cln29 PRE_first_tail_x15_r0_body.cli29 PRE_first_tail_x15_r0_body.cwS29 PRE_first_tail_x15_r0_body.cnS29 PRE_first_tail_x15_r0_body.ciS29 :=
  ⟨rfl, rfl, rfl, PRE_first_tail_x15_r0_body.cnh029, PRE_first_tail_x15_r0_body.cnh129, PRE_first_tail_x15_r0_body.cnn029, PRE_first_tail_x15_r0_body.cnn129, PRE_first_tail_x15_r0_body.cplo29, PRE_first_tail_x15_r0_body.ccnt29, PRE_first_tail_x15_r0_body.cnband29, PRE_first_tail_x15_r0_body.chbelow29, PRE_first_tail_x15_r0_body.chren29, PRE_first_tail_x15_r0_body.cband29, PRE_first_tail_x15_r0_body.cnh1pos29, PRE_first_tail_x15_r0_body.cnren29, PRE_first_tail_x15_r0_body.cnlow29, PRE_first_tail_x15_r0_body.cabs0a29, PRE_first_tail_x15_r0_body.cabs0b29, PRE_first_tail_x15_r0_body.ctok129, PRE_first_tail_x15_r0_body.cpend29, PRE_first_tail_x15_r0_body.cerrh29, PRE_first_tail_x15_r0_body.cfiles29, PRE_first_tail_x15_r0_body.carch29, PRE_first_tail_x15_r0_body.csizes29, PRE_first_tail_x15_r0_body.cwired29, PRE_first_tail_x15_r0_body.cfix29, clean, PRE_first_tail_x15_r0_body.fcxn29, PRE_first_tail_x15_r0_body.fcnn29, hltC, nltC, itemsC, tracedC, cl, PRE_first_tail_x15_r0_body.fle029, PRE_first_tail_x15_r0_body.fnk29, PRE_first_tail_x15_r0_body.ckA29, PRE_first_tail_x15_r0_body.cobjsK29, PRE_first_tail_x15_r0_body.cnodesK29, PRE_first_tail_x15_r0_body.citemsK29, PRE_first_tail_x15_r0_body.f1A29, PRE_first_tail_x15_r0_body.f1O29, PRE_first_tail_x15_r0_body.f1N29, PRE_first_tail_x15_r0_body.f1I29, PRE_first_tail_x15_r0_body.fbd29, PRE_first_tail_x15_r0_body.fincW29, PRE_first_tail_x15_r0_body.fincI29, PRE_first_tail_x15_r0_body.fincN29, PRE_first_tail_x15_r0_body.flnF29, PRE_first_tail_x15_r0_body.fh29, PRE_first_tail_x15_r0_body.fo29, PRE_first_tail_x15_r0_body.fok29, PRE_first_tail_x15_r0_body.fnd29, PRE_first_tail_x15_r0_body.fp29, PRE_first_tail_x15_r0_body.fnord29, PRE_first_tail_x15_r0_body.fi29, PRE_first_tail_x15_r0_body.fii29⟩
theorem PRE_first_tail_x15_r0_body.cnshift29 (clean : Conv.NClean (⟨18768, 15859, 2697327, 1294⟩ : Conv.Cnt) (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s262.ffi).mlx) (hltC : ∀ h, PH (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s262.ffi).mlx h → h < (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s262.ffi).mlx.next) (nltC : ∀ i, PN (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s262.ffi).mlx i → i < (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s262.ffi).mlx.nnext) (itemsC : ∀ k v, (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s262.ffi).mlx.items.get k = some v → PN (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s262.ffi).mlx k) (tracedC : ∀ h o, (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s262.ffi).mlx.objs.get h = some o → ∀ i ∈ objTraces o, i < PRE_first_tail_x15_r0_body.P29.NL) (cl : SSt (· < 1294) PRE_first_tail_x15_r0_body.cx0_29.mlx) : NShift PRE_first_tail_x15_r0_body.P29 1294 PRE_first_tail_x15_r0_body.kappa29 PRE_first_tail_x15_r0_body.cx0_29 PRE_first_tail_x15_r0_body.cx1_29 :=
  Conv.nshift_of_foot (PRE_first_tail_x15_r0_body.cfoot29 clean hltC nltC itemsC tracedC cl) PRE_first_tail_x15_r0_body.chost29 (compact_a_eq PRE_first_tail_x15_r0_body.ckn029 PRE_first_tail_x15_r0_body.ckn129 PRE_first_tail_x15_r0_body.ckheap29 PRE_first_tail_x15_r0_body.ckpl29)

-- the observers: the layers' states at the call, the canonical and the merged state, their footprints and checks
noncomputable def PRE_first_tail_x15_r0_body.fxC_29 : PTrie Unit := (Host.Ts.Sim.Full.freedOf PRE_first_tail_x15_r0_body.s262.ffi).getD PTrie.nil
noncomputable def PRE_first_tail_x15_r0_body.krC_29 : Host.Load.Layers.KRec := (Host.Ts.Sim.Full.krecOf PRE_first_tail_x15_r0_body.s262.ffi).getD Host.Load.Layers.KRec.empty
kernel_rfl PRE_first_tail_x15_r0_body.ofxC_29 : (Host.Ts.Sim.Full.freedOf PRE_first_tail_x15_r0_body.s262.ffi) = some PRE_first_tail_x15_r0_body.fxC_29
kernel_rfl PRE_first_tail_x15_r0_body.okrC_29 : (Host.Ts.Sim.Full.krecOf PRE_first_tail_x15_r0_body.s262.ffi) = some PRE_first_tail_x15_r0_body.krC_29
noncomputable def PRE_first_tail_x15_r0_body.fx0_29 : PTrie Unit := (Host.Ts.Sim.Full.freedOf PRE_first_tail_x15_r0_body.s264.ffi).getD PTrie.nil
noncomputable def PRE_first_tail_x15_r0_body.kr0_29 : Host.Load.Layers.KRec := (Host.Ts.Sim.Full.krecOf PRE_first_tail_x15_r0_body.s264.ffi).getD Host.Load.Layers.KRec.empty
kernel_rfl PRE_first_tail_x15_r0_body.ofx0_29 : (Host.Ts.Sim.Full.freedOf PRE_first_tail_x15_r0_body.s264.ffi) = some PRE_first_tail_x15_r0_body.fx0_29
kernel_rfl PRE_first_tail_x15_r0_body.okr0_29 : (Host.Ts.Sim.Full.krecOf PRE_first_tail_x15_r0_body.s264.ffi) = some PRE_first_tail_x15_r0_body.kr0_29
noncomputable def PRE_first_tail_x15_r0_body.fx1_29 : PTrie Unit := (Host.Ts.Sim.Full.freedOf PRE_first_tail_x15_r0_body.s263.ffi).getD PTrie.nil
noncomputable def PRE_first_tail_x15_r0_body.kr1_29 : Host.Load.Layers.KRec := (Host.Ts.Sim.Full.krecOf PRE_first_tail_x15_r0_body.s263.ffi).getD Host.Load.Layers.KRec.empty
kernel_rfl PRE_first_tail_x15_r0_body.ofx1_29 : (Host.Ts.Sim.Full.freedOf PRE_first_tail_x15_r0_body.s263.ffi) = some PRE_first_tail_x15_r0_body.fx1_29
kernel_rfl PRE_first_tail_x15_r0_body.okr1_29 : (Host.Ts.Sim.Full.krecOf PRE_first_tail_x15_r0_body.s263.ffi) = some PRE_first_tail_x15_r0_body.kr1_29
kernel_rfl PRE_first_tail_x15_r0_body.ff029 : PRE_first_tail_x15_r0_body.fx0_29 = Stage.setAll PRE_first_tail_x15_r0_body.fxC_29 (PRE_first_tail_x15_r0_body.clo29.filterMap fun i => (PRE_first_tail_x15_r0_body.fx0_29.get i).map (i, ·))
kernel_rfl PRE_first_tail_x15_r0_body.ff129 : PRE_first_tail_x15_r0_body.fx1_29 = Stage.setAll PRE_first_tail_x15_r0_body.fxC_29 (PRE_first_tail_x15_r0_body.cwS29.filterMap fun i => (PRE_first_tail_x15_r0_body.fx1_29.get i).map (i, ·))
kernel_rfl PRE_first_tail_x15_r0_body.ffck29 : freedLB PRE_first_tail_x15_r0_body.kappa29 PRE_first_tail_x15_r0_body.cx0_29.mlx PRE_first_tail_x15_r0_body.fx0_29 PRE_first_tail_x15_r0_body.fx1_29 PRE_first_tail_x15_r0_body.clo29 = true
kernel_rfl PRE_first_tail_x15_r0_body.fkf029 : PRE_first_tail_x15_r0_body.kr0_29.flags = Stage.setAll PRE_first_tail_x15_r0_body.krC_29.flags (PRE_first_tail_x15_r0_body.clo29.filterMap fun i => (PRE_first_tail_x15_r0_body.kr0_29.flags.get i).map (i, ·))
kernel_rfl PRE_first_tail_x15_r0_body.fkt029 : PRE_first_tail_x15_r0_body.kr0_29.targs = Stage.setAll PRE_first_tail_x15_r0_body.krC_29.targs (PRE_first_tail_x15_r0_body.clo29.filterMap fun i => (PRE_first_tail_x15_r0_body.kr0_29.targs.get i).map (i, ·))
kernel_rfl PRE_first_tail_x15_r0_body.fkf129 : PRE_first_tail_x15_r0_body.kr1_29.flags = Stage.setAll PRE_first_tail_x15_r0_body.krC_29.flags (PRE_first_tail_x15_r0_body.cwS29.filterMap fun i => (PRE_first_tail_x15_r0_body.kr1_29.flags.get i).map (i, ·))
kernel_rfl PRE_first_tail_x15_r0_body.fkt129 : PRE_first_tail_x15_r0_body.kr1_29.targs = Stage.setAll PRE_first_tail_x15_r0_body.krC_29.targs (PRE_first_tail_x15_r0_body.cwS29.filterMap fun i => (PRE_first_tail_x15_r0_body.kr1_29.targs.get i).map (i, ·))
kernel_rfl PRE_first_tail_x15_r0_body.fkck29 : krecLB PRE_first_tail_x15_r0_body.kappa29 1294 PRE_first_tail_x15_r0_body.cx0_29.mlx PRE_first_tail_x15_r0_body.kr0_29 PRE_first_tail_x15_r0_body.kr1_29 PRE_first_tail_x15_r0_body.clo29 = true
kernel_rfl PRE_first_tail_x15_r0_body.fkn29 : Nat.ble 1294 1294 = true
-- the bridge and the pending traces' regions
kernel_rfl PRE_first_tail_x15_r0_body.cbridge29 : Host.Ts.Sim.Full.bridgeOf PRE_first_tail_x15_r0_body.s263.ffi = Host.Ts.Sim.Full.bridgeOf PRE_first_tail_x15_r0_body.s264.ffi
kernel_rfl PRE_first_tail_x15_r0_body.cpendR29 : pendRegB PRE_first_tail_x15_r0_body.kappa29 (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s264.ffi).mlx = true
kernel_rfl PRE_first_tail_x15_r0_body.cpendLe29 : Nat.ble (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s264.ffi).mlx.next (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s263.ffi).mlx.next = true
/-- **The compaction's native shift**, given the call's bookkeeping, its relation's facts (the model's and the
observers') and the canonical closedness. -/
theorem PRE_first_tail_x15_r0_body.cshift29 (clean : Conv.NClean (⟨18768, 15859, 2697327, 1294⟩ : Conv.Cnt) (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s262.ffi).mlx) (hltC : ∀ h, PH (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s262.ffi).mlx h → h < (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s262.ffi).mlx.next) (nltC : ∀ i, PN (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s262.ffi).mlx i → i < (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s262.ffi).mlx.nnext) (itemsC : ∀ k v, (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s262.ffi).mlx.items.get k = some v → PN (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s262.ffi).mlx k) (tracedC : ∀ h o, (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s262.ffi).mlx.objs.get h = some o → ∀ i ∈ objTraces o, i < PRE_first_tail_x15_r0_body.P29.NL) (cl : SSt (· < 1294) PRE_first_tail_x15_r0_body.cx0_29.mlx)
    (hobjC : ∀ h, PRE_first_tail_x15_r0_body.fxC_29.get h = some () → ((Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s262.ffi).mlx.objs.get h).isSome = true)
    (hfC : ∀ h, (PRE_first_tail_x15_r0_body.krC_29.flags.get h).isSome = true → ((Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s262.ffi).mlx.objs.get h).isSome = true)
    (htC : ∀ h, (PRE_first_tail_x15_r0_body.krC_29.targs.get h).isSome = true → ((Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s262.ffi).mlx.objs.get h).isSome = true)
    (hclC : ∀ h l, PRE_first_tail_x15_r0_body.krC_29.targs.get h = some l → Host.Ts.Sim.Full.STargs (· < (⟨18768, 15859, 2697327, 1294⟩ : Conv.Cnt).n) l) :
    Conv.FullShiftQ PRE_first_tail_x15_r0_body.P29 1294 PRE_first_tail_x15_r0_body.kappa29 PRE_first_tail_x15_r0_body.s264.ffi PRE_first_tail_x15_r0_body.s263.ffi :=
  ⟨PRE_first_tail_x15_r0_body.cnshift29 clean hltC nltC itemsC tracedC cl, PRE_first_tail_x15_r0_body.cqueue29, fun t ht => bSN_sound (List.all_eq_true.mp PRE_first_tail_x15_r0_body.ctokSupp29 t ht),
    PRE_first_tail_x15_r0_body.cbridge29,
    liveShift_foot (x0' := Host.Ts.Sim.Full.mlxOf PRE_first_tail_x15_r0_body.s264.ffi) (x1' := Host.Ts.Sim.Full.mlxOf PRE_first_tail_x15_r0_body.s263.ffi) (PRE_first_tail_x15_r0_body.cfoot29 clean hltC nltC itemsC tracedC cl) rfl PRE_first_tail_x15_r0_body.ofx0_29 PRE_first_tail_x15_r0_body.ofx1_29 hobjC PRE_first_tail_x15_r0_body.ff029 PRE_first_tail_x15_r0_body.ff129 PRE_first_tail_x15_r0_body.ffck29,
    kernShift_foot (x0' := Host.Ts.Sim.Full.mlxOf PRE_first_tail_x15_r0_body.s264.ffi) (x1' := Host.Ts.Sim.Full.mlxOf PRE_first_tail_x15_r0_body.s263.ffi) (PRE_first_tail_x15_r0_body.cfoot29 clean hltC nltC itemsC tracedC cl) rfl PRE_first_tail_x15_r0_body.okr0_29 PRE_first_tail_x15_r0_body.okr1_29 (Nat.le_of_ble_eq_true PRE_first_tail_x15_r0_body.fkn29) hfC htC hclC
      PRE_first_tail_x15_r0_body.fkf029 PRE_first_tail_x15_r0_body.fkt029 PRE_first_tail_x15_r0_body.fkf129 PRE_first_tail_x15_r0_body.fkt129 PRE_first_tail_x15_r0_body.fkck29,
    pendReg_of rfl PRE_first_tail_x15_r0_body.cnh029 PRE_first_tail_x15_r0_body.cnh129 (Nat.le_of_ble_eq_true PRE_first_tail_x15_r0_body.cpendLe29) PRE_first_tail_x15_r0_body.cpendR29⟩

end Host.Load.Run.Tpl
