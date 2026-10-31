import host.sim.template.a4pre_first_tail_x15_r0_body.SiteCl95
import host.sim.conv.CompactFull
import host.sim.template.FootGen
set_option Elab.async false
namespace Host.Load.Run.Tpl
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
open Host.Ts Host.Ts.Sim Host.Ts.Sim.Template

/-! The compaction's native shift at call site 95 from its footprint (`Conv.nshift_of_foot`), and the observers'
(`liveShift_foot`, `kernShift_foot`): `Conv.FullShiftQ` for `Conv.full_compactQ`, given the call's bookkeeping and its
relation's facts. -/

/-- The load parameters of the chain (band-free: its start's node counter as `NL` and `N0`). -/
def PRE_first_tail_x15_r0_body.Pc95 : LoadP := ⟨18151, 131072, 1099511627776, 15235, 15235, []⟩
/-- The site's band raised to the map's checked fixed-node prefix, including newly recorded closure traces. -/
def PRE_first_tail_x15_r0_body.P95 : LoadP := PRE_first_tail_x15_r0_body.Pc95.raise 17155
kernel_rfl PRE_first_tail_x15_r0_body.craise95 : Nat.ble PRE_first_tail_x15_r0_body.Pc95.N0 17155 = true
theorem PRE_first_tail_x15_r0_body.raised95 : Host.Ts.Sim.Full.Raised PRE_first_tail_x15_r0_body.Pc95 PRE_first_tail_x15_r0_body.P95 :=
  .inr ⟨17155, rfl, Nat.le_of_ble_eq_true PRE_first_tail_x15_r0_body.craise95, rfl⟩
noncomputable abbrev PRE_first_tail_x15_r0_body.cx0_95 : Host.Load.LSt := clearTokens (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s840.ffi)
noncomputable abbrev PRE_first_tail_x15_r0_body.cx1_95 : Host.Load.LSt := clearTokens (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s839.ffi)
def PRE_first_tail_x15_r0_body.khinv95 : PTrie Nat := Stage.setAll PTrie.nil []
def PRE_first_tail_x15_r0_body.kninv95 : PTrie Nat := Stage.setAll PTrie.nil []
/-- The stage's footprint: its written and fresh handles, fresh nodes, written and fresh items. -/
def PRE_first_tail_x15_r0_body.cwS95 : List Nat := []
def PRE_first_tail_x15_r0_body.cnS95 : List Nat := List.range' 17155 0
def PRE_first_tail_x15_r0_body.ciS95 : List Nat := [] ++ List.range' 17155 0

-- the small checks (`MChecks`'s)
kernel_rfl PRE_first_tail_x15_r0_body.cnh095 : PRE_first_tail_x15_r0_body.kd95.nh0 = PRE_first_tail_x15_r0_body.cx0_95.mlx.next
kernel_rfl PRE_first_tail_x15_r0_body.cnh195 : PRE_first_tail_x15_r0_body.kd95.nh1 = PRE_first_tail_x15_r0_body.cx1_95.mlx.next
kernel_rfl PRE_first_tail_x15_r0_body.cnn095 : PRE_first_tail_x15_r0_body.kd95.nn0 = PRE_first_tail_x15_r0_body.cx0_95.mlx.nnext
kernel_rfl PRE_first_tail_x15_r0_body.cnn195 : PRE_first_tail_x15_r0_body.kd95.nn1 = PRE_first_tail_x15_r0_body.cx1_95.mlx.nnext
kernel_rfl PRE_first_tail_x15_r0_body.cplo95 : (Nat.blt 0 PRE_first_tail_x15_r0_body.P95.lo && Nat.ble PRE_first_tail_x15_r0_body.P95.lo PRE_first_tail_x15_r0_body.cx0_95.mlx.next && Nat.ble PRE_first_tail_x15_r0_body.P95.lo RData.bigHi && Nat.ble RData.bigHi PRE_first_tail_x15_r0_body.P95.E) = true
kernel_rfl PRE_first_tail_x15_r0_body.ccnt95 : (Nat.ble PRE_first_tail_x15_r0_body.cx0_95.mlx.next PRE_first_tail_x15_r0_body.cx1_95.mlx.next && Nat.ble PRE_first_tail_x15_r0_body.cx0_95.mlx.nnext PRE_first_tail_x15_r0_body.cx1_95.mlx.nnext) = true
kernel_rfl PRE_first_tail_x15_r0_body.cnband95 : (Nat.blt 0 PRE_first_tail_x15_r0_body.P95.NL && Nat.ble PRE_first_tail_x15_r0_body.P95.NL PRE_first_tail_x15_r0_body.P95.N0 && Nat.ble PRE_first_tail_x15_r0_body.P95.N0 PRE_first_tail_x15_r0_body.cx0_95.mlx.nnext) = true
kernel_rfl PRE_first_tail_x15_r0_body.chbelow95 : PRE_first_tail_x15_r0_body.kd95.checkHndBelow = true
kernel_rfl PRE_first_tail_x15_r0_body.chren95 : checkRenG PRE_first_tail_x15_r0_body.kd95.hnd PRE_first_tail_x15_r0_body.khinv95 (phB PRE_first_tail_x15_r0_body.cx0_95.mlx) = true
kernel_rfl PRE_first_tail_x15_r0_body.cband95 : PRE_first_tail_x15_r0_body.kd95.checkBand PRE_first_tail_x15_r0_body.P95.lo = true
kernel_rfl PRE_first_tail_x15_r0_body.cnh1pos95 : Nat.blt 0 PRE_first_tail_x15_r0_body.kd95.nh1 = true
kernel_rfl PRE_first_tail_x15_r0_body.cnren95 : checkRenG PRE_first_tail_x15_r0_body.kd95.node PRE_first_tail_x15_r0_body.kninv95 (pnB PRE_first_tail_x15_r0_body.cx0_95.mlx) = true
kernel_rfl PRE_first_tail_x15_r0_body.cnlow95 : (PTrie.keysA PRE_first_tail_x15_r0_body.kd95.node).all (fun j => Nat.ble PRE_first_tail_x15_r0_body.P95.NL j && Nat.blt (PRE_first_tail_x15_r0_body.kd95.nodeF j) PRE_first_tail_x15_r0_body.cx1_95.mlx.nnext) = true
kernel_rfl PRE_first_tail_x15_r0_body.cabs0a95 : PRE_first_tail_x15_r0_body.cx0_95.mlx.arrs.get 0 = none
kernel_rfl PRE_first_tail_x15_r0_body.cabs0b95 : PRE_first_tail_x15_r0_body.cx0_95.mlx.objs.get 0 = none
kernel_rfl PRE_first_tail_x15_r0_body.ctok195 : PRE_first_tail_x15_r0_body.cx1_95.mlx.tokens = []
kernel_rfl PRE_first_tail_x15_r0_body.cpend95 : PRE_first_tail_x15_r0_body.cx1_95.mlx.pending = PRE_first_tail_x15_r0_body.cx0_95.mlx.pending.map PRE_first_tail_x15_r0_body.kappa95.pend
kernel_rfl PRE_first_tail_x15_r0_body.cerrh95 : PRE_first_tail_x15_r0_body.cx1_95.mlx.errh = PRE_first_tail_x15_r0_body.cx0_95.mlx.errh.map PRE_first_tail_x15_r0_body.kappa95.arg
kernel_rfl PRE_first_tail_x15_r0_body.cfiles95 : PRE_first_tail_x15_r0_body.cx1_95.mlx.files = PRE_first_tail_x15_r0_body.cx0_95.mlx.files
kernel_rfl PRE_first_tail_x15_r0_body.carch95 : PRE_first_tail_x15_r0_body.cx1_95.mlx.arch = PRE_first_tail_x15_r0_body.cx0_95.mlx.arch
kernel_rfl PRE_first_tail_x15_r0_body.csizes95 : PRE_first_tail_x15_r0_body.cx1_95.mlx.deviceSizes = PRE_first_tail_x15_r0_body.cx0_95.mlx.deviceSizes
kernel_rfl PRE_first_tail_x15_r0_body.cwired95 : PRE_first_tail_x15_r0_body.cx1_95.mlx.wired = PRE_first_tail_x15_r0_body.cx0_95.mlx.wired
kernel_rfl PRE_first_tail_x15_r0_body.chost95 : PRE_first_tail_x15_r0_body.cx1_95.host = PRE_first_tail_x15_r0_body.cx0_95.host
-- the compaction map's addresses are `PRE_first_tail_x15_r0_body.kd95`'s
kernel_rfl PRE_first_tail_x15_r0_body.ckn095 : PRE_first_tail_x15_r0_body.kd95.n0 = 2749294
kernel_rfl PRE_first_tail_x15_r0_body.ckn195 : PRE_first_tail_x15_r0_body.kd95.n1 = 2749313
kernel_rfl PRE_first_tail_x15_r0_body.ckheap95 : (PTrie.keysA PRE_first_tail_x15_r0_body.kd95.heap).all (fun x => Nat.ble 2749293 x) = true
kernel_rfl PRE_first_tail_x15_r0_body.ckpl95 : (List.range 1).all (fun j => decide (PRE_first_tail_x15_r0_body.kd95.heap.get (2749293 + j) = nth? PRE_first_tail_x15_r0_body.pl95 j)) = true
-- the map fixes the call's names (`Conv.fixOld_compact`), the call's counters
kernel_rfl PRE_first_tail_x15_r0_body.fja95 : Nat.ble 2749293 2749293 = true
kernel_rfl PRE_first_tail_x15_r0_body.fn95 : Nat.ble 4114 4114 = true
kernel_rfl PRE_first_tail_x15_r0_body.fjaD95 : Nat.ble 2749293 PRE_first_tail_x15_r0_body.kd95.n0 = true
kernel_rfl PRE_first_tail_x15_r0_body.fxn95 : Nat.ble 20069 PRE_first_tail_x15_r0_body.kd95.nh0 = true
kernel_rfl PRE_first_tail_x15_r0_body.fnn95 : Nat.ble 17155 PRE_first_tail_x15_r0_body.kd95.nn0 = true
kernel_rfl PRE_first_tail_x15_r0_body.fxb95 : Nat.ble 20069 RData.bigHi = true
kernel_rfl PRE_first_tail_x15_r0_body.fheap95 : (PTrie.keysA PRE_first_tail_x15_r0_body.kd95.heap).all (Nat.ble (⟨20069, 17155, 2749293, 4114⟩ : Conv.Cnt).ja) = true
kernel_rfl PRE_first_tail_x15_r0_body.fhnd95 : (PTrie.keysA PRE_first_tail_x15_r0_body.kd95.hnd).all (Nat.ble (⟨20069, 17155, 2749293, 4114⟩ : Conv.Cnt).xn) = true
kernel_rfl PRE_first_tail_x15_r0_body.fnode95 : (PTrie.keysA PRE_first_tail_x15_r0_body.kd95.node).all (Nat.ble (⟨20069, 17155, 2749293, 4114⟩ : Conv.Cnt).nn) = true
/-- The compaction map fixes the call's names. -/
theorem PRE_first_tail_x15_r0_body.cfix95 : Conv.FixOld (⟨20069, 17155, 2749293, 4114⟩ : Conv.Cnt) PRE_first_tail_x15_r0_body.kappa95 :=
  Conv.fixOld_compact (Nat.le_of_ble_eq_true PRE_first_tail_x15_r0_body.fja95) (Nat.le_of_ble_eq_true PRE_first_tail_x15_r0_body.fn95) (Nat.le_of_ble_eq_true PRE_first_tail_x15_r0_body.fjaD95) (Nat.le_of_ble_eq_true PRE_first_tail_x15_r0_body.fxn95) (Nat.le_of_ble_eq_true PRE_first_tail_x15_r0_body.fnn95) (Nat.le_of_ble_eq_true PRE_first_tail_x15_r0_body.fxb95) PRE_first_tail_x15_r0_body.fheap95 PRE_first_tail_x15_r0_body.fhnd95 PRE_first_tail_x15_r0_body.fnode95
kernel_rfl PRE_first_tail_x15_r0_body.fcxn95 : (⟨20069, 17155, 2749293, 4114⟩ : Conv.Cnt).xn = (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s838.ffi).mlx.next
kernel_rfl PRE_first_tail_x15_r0_body.fcnn95 : (⟨20069, 17155, 2749293, 4114⟩ : Conv.Cnt).nn = (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s838.ffi).mlx.nnext
kernel_rfl PRE_first_tail_x15_r0_body.fle095 : (Nat.ble (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s838.ffi).mlx.next PRE_first_tail_x15_r0_body.cx0_95.mlx.next && Nat.ble (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s838.ffi).mlx.nnext PRE_first_tail_x15_r0_body.cx0_95.mlx.nnext && Nat.ble (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s838.ffi).mlx.next RData.bigHi) = true
kernel_rfl PRE_first_tail_x15_r0_body.fnk95 : (PTrie.keysA PRE_first_tail_x15_r0_body.kd95.node).all (Nat.ble (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s838.ffi).mlx.nnext) = true
-- the merged state keeps the call's entries off the stage's footprint
kernel_rfl PRE_first_tail_x15_r0_body.f1A95 : PRE_first_tail_x15_r0_body.cx1_95.mlx.arrs = Stage.setAll (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s838.ffi).mlx.arrs (PRE_first_tail_x15_r0_body.cwS95.filterMap fun i => (PRE_first_tail_x15_r0_body.cx1_95.mlx.arrs.get i).map (i, ·))
kernel_rfl PRE_first_tail_x15_r0_body.f1O95 : PRE_first_tail_x15_r0_body.cx1_95.mlx.objs = Stage.setAll (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s838.ffi).mlx.objs (PRE_first_tail_x15_r0_body.cwS95.filterMap fun i => (PRE_first_tail_x15_r0_body.cx1_95.mlx.objs.get i).map (i, ·))
kernel_rfl PRE_first_tail_x15_r0_body.f1N95 : PRE_first_tail_x15_r0_body.cx1_95.mlx.nodes = Stage.setAll (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s838.ffi).mlx.nodes (PRE_first_tail_x15_r0_body.cnS95.filterMap fun i => (PRE_first_tail_x15_r0_body.cx1_95.mlx.nodes.get i).map (i, ·))
kernel_rfl PRE_first_tail_x15_r0_body.f1I95 : PRE_first_tail_x15_r0_body.cx1_95.mlx.items = Stage.setAll (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s838.ffi).mlx.items (PRE_first_tail_x15_r0_body.ciS95.filterMap fun i => (PRE_first_tail_x15_r0_body.cx1_95.mlx.items.get i).map (i, ·))
kernel_rfl PRE_first_tail_x15_r0_body.fbd95 : (PRE_first_tail_x15_r0_body.clo95 ++ PRE_first_tail_x15_r0_body.cln95 ++ PRE_first_tail_x15_r0_body.cli95 ++ PRE_first_tail_x15_r0_body.cwS95 ++ PRE_first_tail_x15_r0_body.cnS95 ++ PRE_first_tail_x15_r0_body.ciS95).all (fun i => Nat.blt (i / 4096) (4 ^ 31)) = true
kernel_rfl PRE_first_tail_x15_r0_body.fincW95 : PRE_first_tail_x15_r0_body.cwS95.all (fun h => !Nat.blt h (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s838.ffi).mlx.next || PRE_first_tail_x15_r0_body.clo95.contains h) = true
kernel_rfl PRE_first_tail_x15_r0_body.fincI95 : PRE_first_tail_x15_r0_body.ciS95.all (fun k => !Nat.blt k (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s838.ffi).mlx.nnext || PRE_first_tail_x15_r0_body.cli95.contains k) = true
kernel_rfl PRE_first_tail_x15_r0_body.fincN95 : PRE_first_tail_x15_r0_body.cnS95.all (Nat.ble (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s838.ffi).mlx.nnext) = true
kernel_rfl PRE_first_tail_x15_r0_body.flnF95 : PRE_first_tail_x15_r0_body.cln95.all (Nat.ble (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s838.ffi).mlx.nnext) = true
-- the checks over the changed lists
kernel_rfl PRE_first_tail_x15_r0_body.fh95 : PRE_first_tail_x15_r0_body.clo95.all (handleOK PRE_first_tail_x15_r0_body.kappa95 PRE_first_tail_x15_r0_body.P95.lo PRE_first_tail_x15_r0_body.cx0_95.mlx PRE_first_tail_x15_r0_body.cx1_95.mlx) = true
kernel_rfl PRE_first_tail_x15_r0_body.fo95 : PRE_first_tail_x15_r0_body.clo95.map (fun h => PRE_first_tail_x15_r0_body.cx1_95.mlx.objs.get (PRE_first_tail_x15_r0_body.kappa95.handle h)) = PRE_first_tail_x15_r0_body.clo95.map (fun h => (PRE_first_tail_x15_r0_body.cx0_95.mlx.objs.get h).map PRE_first_tail_x15_r0_body.kappa95.nobj)
kernel_rfl PRE_first_tail_x15_r0_body.fok95 : PRE_first_tail_x15_r0_body.clo95.all (objOK PRE_first_tail_x15_r0_body.kappa95 PRE_first_tail_x15_r0_body.P95.NL PRE_first_tail_x15_r0_body.cx0_95.mlx) = true
kernel_rfl PRE_first_tail_x15_r0_body.fnd95 : PRE_first_tail_x15_r0_body.cln95.all (nodeOKF PRE_first_tail_x15_r0_body.kappa95 PRE_first_tail_x15_r0_body.P95 PRE_first_tail_x15_r0_body.cx0_95.mlx PRE_first_tail_x15_r0_body.cx1_95.mlx) = true
kernel_rfl PRE_first_tail_x15_r0_body.fp95 : ((PRE_first_tail_x15_r0_body.cln95.filter (fullB PRE_first_tail_x15_r0_body.P95))).map (fun i => (PRE_first_tail_x15_r0_body.cx1_95.mlx.nodes.get (PRE_first_tail_x15_r0_body.kappa95.node i)).map Host.Mlx.Ffi.Node.prim) =
  ((PRE_first_tail_x15_r0_body.cln95.filter (fullB PRE_first_tail_x15_r0_body.P95))).map (fun i => (PRE_first_tail_x15_r0_body.cx0_95.mlx.nodes.get i).map fun nd => PRE_first_tail_x15_r0_body.kappa95.prim nd.prim)
kernel_rfl PRE_first_tail_x15_r0_body.fnordI95 : incrB PRE_first_tail_x15_r0_body.kd95.nodeF (List.range' 17155 0) = true
kernel_rfl PRE_first_tail_x15_r0_body.fnordK95 : (PTrie.keysA PRE_first_tail_x15_r0_body.kd95.node).all (fun k => Nat.ble 17155 k && Nat.blt k 17155) = true
kernel_rfl PRE_first_tail_x15_r0_body.fnordL95 : (PRE_first_tail_x15_r0_body.cln95.filter (Nat.ble PRE_first_tail_x15_r0_body.P95.N0)).all (fun i => Nat.ble i (PRE_first_tail_x15_r0_body.kd95.nodeF i) && (Nat.blt i 17155 || Nat.ble PRE_first_tail_x15_r0_body.kd95.nn0 i)) = true
theorem PRE_first_tail_x15_r0_body.fnord95 : (PRE_first_tail_x15_r0_body.cln95.filter (Nat.ble PRE_first_tail_x15_r0_body.P95.N0)).all (fun i => Nat.ble i (PRE_first_tail_x15_r0_body.kd95.nodeF i) &&
    (PTrie.keysA PRE_first_tail_x15_r0_body.kd95.node).all fun j => !Nat.blt j i || Nat.blt (PRE_first_tail_x15_r0_body.kd95.nodeF j) (PRE_first_tail_x15_r0_body.kd95.nodeF i)) = true :=
  cnord_of PRE_first_tail_x15_r0_body.cnlow95 PRE_first_tail_x15_r0_body.cnn195 PRE_first_tail_x15_r0_body.fnordI95 PRE_first_tail_x15_r0_body.fnordK95 PRE_first_tail_x15_r0_body.fnordL95
kernel_rfl PRE_first_tail_x15_r0_body.fi95 : PRE_first_tail_x15_r0_body.cli95.all (pnB PRE_first_tail_x15_r0_body.cx0_95.mlx) = true
kernel_rfl PRE_first_tail_x15_r0_body.fii95 : PRE_first_tail_x15_r0_body.cli95.all (fun k => decide (PRE_first_tail_x15_r0_body.cx1_95.mlx.items.get (PRE_first_tail_x15_r0_body.kappa95.node k) = (PRE_first_tail_x15_r0_body.cx0_95.mlx.items.get k).map PRE_first_tail_x15_r0_body.kappa95.nv)) = true
/-- **The compaction's footprint.** -/
theorem PRE_first_tail_x15_r0_body.cfoot95 (clean : Conv.NClean (⟨20069, 17155, 2749293, 4114⟩ : Conv.Cnt) (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s838.ffi).mlx) (hltC : ∀ h, PH (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s838.ffi).mlx h → h < (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s838.ffi).mlx.next) (nltC : ∀ i, PN (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s838.ffi).mlx i → i < (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s838.ffi).mlx.nnext) (itemsC : ∀ k v, (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s838.ffi).mlx.items.get k = some v → PN (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s838.ffi).mlx k) (tracedC : ∀ h o, (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s838.ffi).mlx.objs.get h = some o → ∀ i ∈ objTraces o, i < PRE_first_tail_x15_r0_body.P95.NL) (cl : SSt (· < 4114) PRE_first_tail_x15_r0_body.cx0_95.mlx) :
    Conv.MFoot PRE_first_tail_x15_r0_body.P95 4114 PRE_first_tail_x15_r0_body.kappa95 PRE_first_tail_x15_r0_body.kd95 PRE_first_tail_x15_r0_body.khinv95 PRE_first_tail_x15_r0_body.kninv95 (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s838.ffi).mlx PRE_first_tail_x15_r0_body.cx0_95.mlx PRE_first_tail_x15_r0_body.cx1_95.mlx (⟨20069, 17155, 2749293, 4114⟩ : Conv.Cnt) PRE_first_tail_x15_r0_body.clo95 PRE_first_tail_x15_r0_body.cln95 PRE_first_tail_x15_r0_body.cli95 PRE_first_tail_x15_r0_body.cwS95 PRE_first_tail_x15_r0_body.cnS95 PRE_first_tail_x15_r0_body.ciS95 :=
  ⟨rfl, rfl, rfl, PRE_first_tail_x15_r0_body.cnh095, PRE_first_tail_x15_r0_body.cnh195, PRE_first_tail_x15_r0_body.cnn095, PRE_first_tail_x15_r0_body.cnn195, PRE_first_tail_x15_r0_body.cplo95, PRE_first_tail_x15_r0_body.ccnt95, PRE_first_tail_x15_r0_body.cnband95, PRE_first_tail_x15_r0_body.chbelow95, PRE_first_tail_x15_r0_body.chren95, PRE_first_tail_x15_r0_body.cband95, PRE_first_tail_x15_r0_body.cnh1pos95, PRE_first_tail_x15_r0_body.cnren95, PRE_first_tail_x15_r0_body.cnlow95, PRE_first_tail_x15_r0_body.cabs0a95, PRE_first_tail_x15_r0_body.cabs0b95, PRE_first_tail_x15_r0_body.ctok195, PRE_first_tail_x15_r0_body.cpend95, PRE_first_tail_x15_r0_body.cerrh95, PRE_first_tail_x15_r0_body.cfiles95, PRE_first_tail_x15_r0_body.carch95, PRE_first_tail_x15_r0_body.csizes95, PRE_first_tail_x15_r0_body.cwired95, PRE_first_tail_x15_r0_body.cfix95, clean, PRE_first_tail_x15_r0_body.fcxn95, PRE_first_tail_x15_r0_body.fcnn95, hltC, nltC, itemsC, tracedC, cl, PRE_first_tail_x15_r0_body.fle095, PRE_first_tail_x15_r0_body.fnk95, PRE_first_tail_x15_r0_body.ckA95, PRE_first_tail_x15_r0_body.cobjsK95, PRE_first_tail_x15_r0_body.cnodesK95, PRE_first_tail_x15_r0_body.citemsK95, PRE_first_tail_x15_r0_body.f1A95, PRE_first_tail_x15_r0_body.f1O95, PRE_first_tail_x15_r0_body.f1N95, PRE_first_tail_x15_r0_body.f1I95, PRE_first_tail_x15_r0_body.fbd95, PRE_first_tail_x15_r0_body.fincW95, PRE_first_tail_x15_r0_body.fincI95, PRE_first_tail_x15_r0_body.fincN95, PRE_first_tail_x15_r0_body.flnF95, PRE_first_tail_x15_r0_body.fh95, PRE_first_tail_x15_r0_body.fo95, PRE_first_tail_x15_r0_body.fok95, PRE_first_tail_x15_r0_body.fnd95, PRE_first_tail_x15_r0_body.fp95, PRE_first_tail_x15_r0_body.fnord95, PRE_first_tail_x15_r0_body.fi95, PRE_first_tail_x15_r0_body.fii95⟩
theorem PRE_first_tail_x15_r0_body.cnshift95 (clean : Conv.NClean (⟨20069, 17155, 2749293, 4114⟩ : Conv.Cnt) (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s838.ffi).mlx) (hltC : ∀ h, PH (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s838.ffi).mlx h → h < (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s838.ffi).mlx.next) (nltC : ∀ i, PN (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s838.ffi).mlx i → i < (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s838.ffi).mlx.nnext) (itemsC : ∀ k v, (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s838.ffi).mlx.items.get k = some v → PN (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s838.ffi).mlx k) (tracedC : ∀ h o, (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s838.ffi).mlx.objs.get h = some o → ∀ i ∈ objTraces o, i < PRE_first_tail_x15_r0_body.P95.NL) (cl : SSt (· < 4114) PRE_first_tail_x15_r0_body.cx0_95.mlx) : NShift PRE_first_tail_x15_r0_body.P95 4114 PRE_first_tail_x15_r0_body.kappa95 PRE_first_tail_x15_r0_body.cx0_95 PRE_first_tail_x15_r0_body.cx1_95 :=
  Conv.nshift_of_foot (PRE_first_tail_x15_r0_body.cfoot95 clean hltC nltC itemsC tracedC cl) PRE_first_tail_x15_r0_body.chost95 (compact_a_eq PRE_first_tail_x15_r0_body.ckn095 PRE_first_tail_x15_r0_body.ckn195 PRE_first_tail_x15_r0_body.ckheap95 PRE_first_tail_x15_r0_body.ckpl95)

-- the observers: the layers' states at the call, the canonical and the merged state, their footprints and checks
noncomputable def PRE_first_tail_x15_r0_body.fxC_95 : PTrie Unit := (Host.Ts.Sim.Full.freedOf PRE_first_tail_x15_r0_body.s838.ffi).getD PTrie.nil
noncomputable def PRE_first_tail_x15_r0_body.krC_95 : Host.Load.Layers.KRec := (Host.Ts.Sim.Full.krecOf PRE_first_tail_x15_r0_body.s838.ffi).getD Host.Load.Layers.KRec.empty
kernel_rfl PRE_first_tail_x15_r0_body.ofxC_95 : (Host.Ts.Sim.Full.freedOf PRE_first_tail_x15_r0_body.s838.ffi) = some PRE_first_tail_x15_r0_body.fxC_95
kernel_rfl PRE_first_tail_x15_r0_body.okrC_95 : (Host.Ts.Sim.Full.krecOf PRE_first_tail_x15_r0_body.s838.ffi) = some PRE_first_tail_x15_r0_body.krC_95
noncomputable def PRE_first_tail_x15_r0_body.fx0_95 : PTrie Unit := (Host.Ts.Sim.Full.freedOf PRE_first_tail_x15_r0_body.s840.ffi).getD PTrie.nil
noncomputable def PRE_first_tail_x15_r0_body.kr0_95 : Host.Load.Layers.KRec := (Host.Ts.Sim.Full.krecOf PRE_first_tail_x15_r0_body.s840.ffi).getD Host.Load.Layers.KRec.empty
kernel_rfl PRE_first_tail_x15_r0_body.ofx0_95 : (Host.Ts.Sim.Full.freedOf PRE_first_tail_x15_r0_body.s840.ffi) = some PRE_first_tail_x15_r0_body.fx0_95
kernel_rfl PRE_first_tail_x15_r0_body.okr0_95 : (Host.Ts.Sim.Full.krecOf PRE_first_tail_x15_r0_body.s840.ffi) = some PRE_first_tail_x15_r0_body.kr0_95
noncomputable def PRE_first_tail_x15_r0_body.fx1_95 : PTrie Unit := (Host.Ts.Sim.Full.freedOf PRE_first_tail_x15_r0_body.s839.ffi).getD PTrie.nil
noncomputable def PRE_first_tail_x15_r0_body.kr1_95 : Host.Load.Layers.KRec := (Host.Ts.Sim.Full.krecOf PRE_first_tail_x15_r0_body.s839.ffi).getD Host.Load.Layers.KRec.empty
kernel_rfl PRE_first_tail_x15_r0_body.ofx1_95 : (Host.Ts.Sim.Full.freedOf PRE_first_tail_x15_r0_body.s839.ffi) = some PRE_first_tail_x15_r0_body.fx1_95
kernel_rfl PRE_first_tail_x15_r0_body.okr1_95 : (Host.Ts.Sim.Full.krecOf PRE_first_tail_x15_r0_body.s839.ffi) = some PRE_first_tail_x15_r0_body.kr1_95
kernel_rfl PRE_first_tail_x15_r0_body.ff095 : PRE_first_tail_x15_r0_body.fx0_95 = Stage.setAll PRE_first_tail_x15_r0_body.fxC_95 (PRE_first_tail_x15_r0_body.clo95.filterMap fun i => (PRE_first_tail_x15_r0_body.fx0_95.get i).map (i, ·))
kernel_rfl PRE_first_tail_x15_r0_body.ff195 : PRE_first_tail_x15_r0_body.fx1_95 = Stage.setAll PRE_first_tail_x15_r0_body.fxC_95 (PRE_first_tail_x15_r0_body.cwS95.filterMap fun i => (PRE_first_tail_x15_r0_body.fx1_95.get i).map (i, ·))
kernel_rfl PRE_first_tail_x15_r0_body.ffck95 : freedLB PRE_first_tail_x15_r0_body.kappa95 PRE_first_tail_x15_r0_body.cx0_95.mlx PRE_first_tail_x15_r0_body.fx0_95 PRE_first_tail_x15_r0_body.fx1_95 PRE_first_tail_x15_r0_body.clo95 = true
kernel_rfl PRE_first_tail_x15_r0_body.fkf095 : PRE_first_tail_x15_r0_body.kr0_95.flags = Stage.setAll PRE_first_tail_x15_r0_body.krC_95.flags (PRE_first_tail_x15_r0_body.clo95.filterMap fun i => (PRE_first_tail_x15_r0_body.kr0_95.flags.get i).map (i, ·))
kernel_rfl PRE_first_tail_x15_r0_body.fkt095 : PRE_first_tail_x15_r0_body.kr0_95.targs = Stage.setAll PRE_first_tail_x15_r0_body.krC_95.targs (PRE_first_tail_x15_r0_body.clo95.filterMap fun i => (PRE_first_tail_x15_r0_body.kr0_95.targs.get i).map (i, ·))
kernel_rfl PRE_first_tail_x15_r0_body.fkf195 : PRE_first_tail_x15_r0_body.kr1_95.flags = Stage.setAll PRE_first_tail_x15_r0_body.krC_95.flags (PRE_first_tail_x15_r0_body.cwS95.filterMap fun i => (PRE_first_tail_x15_r0_body.kr1_95.flags.get i).map (i, ·))
kernel_rfl PRE_first_tail_x15_r0_body.fkt195 : PRE_first_tail_x15_r0_body.kr1_95.targs = Stage.setAll PRE_first_tail_x15_r0_body.krC_95.targs (PRE_first_tail_x15_r0_body.cwS95.filterMap fun i => (PRE_first_tail_x15_r0_body.kr1_95.targs.get i).map (i, ·))
kernel_rfl PRE_first_tail_x15_r0_body.fkck95 : krecLB PRE_first_tail_x15_r0_body.kappa95 4114 PRE_first_tail_x15_r0_body.cx0_95.mlx PRE_first_tail_x15_r0_body.kr0_95 PRE_first_tail_x15_r0_body.kr1_95 PRE_first_tail_x15_r0_body.clo95 = true
kernel_rfl PRE_first_tail_x15_r0_body.fkn95 : Nat.ble 4114 4114 = true
-- the bridge and the pending traces' regions
kernel_rfl PRE_first_tail_x15_r0_body.cbridge95 : Host.Ts.Sim.Full.bridgeOf PRE_first_tail_x15_r0_body.s839.ffi = Host.Ts.Sim.Full.bridgeOf PRE_first_tail_x15_r0_body.s840.ffi
kernel_rfl PRE_first_tail_x15_r0_body.cpendR95 : pendRegB PRE_first_tail_x15_r0_body.kappa95 (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s840.ffi).mlx = true
kernel_rfl PRE_first_tail_x15_r0_body.cpendLe95 : Nat.ble (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s840.ffi).mlx.next (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s839.ffi).mlx.next = true
/-- **The compaction's native shift**, given the call's bookkeeping, its relation's facts (the model's and the
observers') and the canonical closedness. -/
theorem PRE_first_tail_x15_r0_body.cshift95 (clean : Conv.NClean (⟨20069, 17155, 2749293, 4114⟩ : Conv.Cnt) (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s838.ffi).mlx) (hltC : ∀ h, PH (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s838.ffi).mlx h → h < (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s838.ffi).mlx.next) (nltC : ∀ i, PN (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s838.ffi).mlx i → i < (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s838.ffi).mlx.nnext) (itemsC : ∀ k v, (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s838.ffi).mlx.items.get k = some v → PN (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s838.ffi).mlx k) (tracedC : ∀ h o, (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s838.ffi).mlx.objs.get h = some o → ∀ i ∈ objTraces o, i < PRE_first_tail_x15_r0_body.P95.NL) (cl : SSt (· < 4114) PRE_first_tail_x15_r0_body.cx0_95.mlx)
    (hobjC : ∀ h, PRE_first_tail_x15_r0_body.fxC_95.get h = some () → ((Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s838.ffi).mlx.objs.get h).isSome = true)
    (hfC : ∀ h, (PRE_first_tail_x15_r0_body.krC_95.flags.get h).isSome = true → ((Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s838.ffi).mlx.objs.get h).isSome = true)
    (htC : ∀ h, (PRE_first_tail_x15_r0_body.krC_95.targs.get h).isSome = true → ((Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s838.ffi).mlx.objs.get h).isSome = true)
    (hclC : ∀ h l, PRE_first_tail_x15_r0_body.krC_95.targs.get h = some l → Host.Ts.Sim.Full.STargs (· < (⟨20069, 17155, 2749293, 4114⟩ : Conv.Cnt).n) l) :
    Conv.FullShiftQ PRE_first_tail_x15_r0_body.P95 4114 PRE_first_tail_x15_r0_body.kappa95 PRE_first_tail_x15_r0_body.s840.ffi PRE_first_tail_x15_r0_body.s839.ffi :=
  ⟨PRE_first_tail_x15_r0_body.cnshift95 clean hltC nltC itemsC tracedC cl, PRE_first_tail_x15_r0_body.cqueue95, fun t ht => bSN_sound (List.all_eq_true.mp PRE_first_tail_x15_r0_body.ctokSupp95 t ht),
    PRE_first_tail_x15_r0_body.cbridge95,
    liveShift_foot (x0' := Host.Ts.Sim.Full.mlxOf PRE_first_tail_x15_r0_body.s840.ffi) (x1' := Host.Ts.Sim.Full.mlxOf PRE_first_tail_x15_r0_body.s839.ffi) (PRE_first_tail_x15_r0_body.cfoot95 clean hltC nltC itemsC tracedC cl) rfl PRE_first_tail_x15_r0_body.ofx0_95 PRE_first_tail_x15_r0_body.ofx1_95 hobjC PRE_first_tail_x15_r0_body.ff095 PRE_first_tail_x15_r0_body.ff195 PRE_first_tail_x15_r0_body.ffck95,
    kernShift_foot (x0' := Host.Ts.Sim.Full.mlxOf PRE_first_tail_x15_r0_body.s840.ffi) (x1' := Host.Ts.Sim.Full.mlxOf PRE_first_tail_x15_r0_body.s839.ffi) (PRE_first_tail_x15_r0_body.cfoot95 clean hltC nltC itemsC tracedC cl) rfl PRE_first_tail_x15_r0_body.okr0_95 PRE_first_tail_x15_r0_body.okr1_95 (Nat.le_of_ble_eq_true PRE_first_tail_x15_r0_body.fkn95) hfC htC hclC
      PRE_first_tail_x15_r0_body.fkf095 PRE_first_tail_x15_r0_body.fkt095 PRE_first_tail_x15_r0_body.fkf195 PRE_first_tail_x15_r0_body.fkt195 PRE_first_tail_x15_r0_body.fkck95,
    pendReg_of rfl PRE_first_tail_x15_r0_body.cnh095 PRE_first_tail_x15_r0_body.cnh195 (Nat.le_of_ble_eq_true PRE_first_tail_x15_r0_body.cpendLe95) PRE_first_tail_x15_r0_body.cpendR95⟩

end Host.Load.Run.Tpl
