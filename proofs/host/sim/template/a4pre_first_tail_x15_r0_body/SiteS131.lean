import host.sim.template.a4pre_first_tail_x15_r0_body.SiteCl131
import host.sim.conv.CompactFull
import host.sim.template.FootGen
set_option Elab.async false
namespace Host.Load.Run.Tpl
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
open Host.Ts Host.Ts.Sim Host.Ts.Sim.Template

/-! The compaction's native shift at call site 131 from its footprint (`Conv.nshift_of_foot`), and the observers'
(`liveShift_foot`, `kernShift_foot`): `Conv.FullShiftQ` for `Conv.full_compactQ`, given the call's bookkeeping and its
relation's facts. -/

/-- The load parameters of the chain (band-free: its start's node counter as `NL` and `N0`). -/
def PRE_first_tail_x15_r0_body.Pc131 : LoadP := ⟨18151, 131072, 1099511627776, 15235, 15235, []⟩
/-- The site's band raised to the map's checked fixed-node prefix, including newly recorded closure traces. -/
def PRE_first_tail_x15_r0_body.P131 : LoadP := PRE_first_tail_x15_r0_body.Pc131.raise 17866
kernel_rfl PRE_first_tail_x15_r0_body.craise131 : Nat.ble PRE_first_tail_x15_r0_body.Pc131.N0 17866 = true
theorem PRE_first_tail_x15_r0_body.raised131 : Host.Ts.Sim.Full.Raised PRE_first_tail_x15_r0_body.Pc131 PRE_first_tail_x15_r0_body.P131 :=
  .inr ⟨17866, rfl, Nat.le_of_ble_eq_true PRE_first_tail_x15_r0_body.craise131, rfl⟩
noncomputable abbrev PRE_first_tail_x15_r0_body.cx0_131 : Host.Load.LSt := clearTokens (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1155.ffi)
noncomputable abbrev PRE_first_tail_x15_r0_body.cx1_131 : Host.Load.LSt := clearTokens (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1154.ffi)
def PRE_first_tail_x15_r0_body.khinv131 : PTrie Nat := Stage.setAll PTrie.nil []
def PRE_first_tail_x15_r0_body.kninv131 : PTrie Nat := Stage.setAll PTrie.nil []
/-- The stage's footprint: its written and fresh handles, fresh nodes, written and fresh items. -/
def PRE_first_tail_x15_r0_body.cwS131 : List Nat := []
def PRE_first_tail_x15_r0_body.cnS131 : List Nat := List.range' 17866 0
def PRE_first_tail_x15_r0_body.ciS131 : List Nat := [] ++ List.range' 17866 0

-- the small checks (`MChecks`'s)
kernel_rfl PRE_first_tail_x15_r0_body.cnh0131 : PRE_first_tail_x15_r0_body.kd131.nh0 = PRE_first_tail_x15_r0_body.cx0_131.mlx.next
kernel_rfl PRE_first_tail_x15_r0_body.cnh1131 : PRE_first_tail_x15_r0_body.kd131.nh1 = PRE_first_tail_x15_r0_body.cx1_131.mlx.next
kernel_rfl PRE_first_tail_x15_r0_body.cnn0131 : PRE_first_tail_x15_r0_body.kd131.nn0 = PRE_first_tail_x15_r0_body.cx0_131.mlx.nnext
kernel_rfl PRE_first_tail_x15_r0_body.cnn1131 : PRE_first_tail_x15_r0_body.kd131.nn1 = PRE_first_tail_x15_r0_body.cx1_131.mlx.nnext
kernel_rfl PRE_first_tail_x15_r0_body.cplo131 : (Nat.blt 0 PRE_first_tail_x15_r0_body.P131.lo && Nat.ble PRE_first_tail_x15_r0_body.P131.lo PRE_first_tail_x15_r0_body.cx0_131.mlx.next && Nat.ble PRE_first_tail_x15_r0_body.P131.lo RData.bigHi && Nat.ble RData.bigHi PRE_first_tail_x15_r0_body.P131.E) = true
kernel_rfl PRE_first_tail_x15_r0_body.ccnt131 : (Nat.ble PRE_first_tail_x15_r0_body.cx0_131.mlx.next PRE_first_tail_x15_r0_body.cx1_131.mlx.next && Nat.ble PRE_first_tail_x15_r0_body.cx0_131.mlx.nnext PRE_first_tail_x15_r0_body.cx1_131.mlx.nnext) = true
kernel_rfl PRE_first_tail_x15_r0_body.cnband131 : (Nat.blt 0 PRE_first_tail_x15_r0_body.P131.NL && Nat.ble PRE_first_tail_x15_r0_body.P131.NL PRE_first_tail_x15_r0_body.P131.N0 && Nat.ble PRE_first_tail_x15_r0_body.P131.N0 PRE_first_tail_x15_r0_body.cx0_131.mlx.nnext) = true
kernel_rfl PRE_first_tail_x15_r0_body.chbelow131 : PRE_first_tail_x15_r0_body.kd131.checkHndBelow = true
kernel_rfl PRE_first_tail_x15_r0_body.chren131 : checkRenG PRE_first_tail_x15_r0_body.kd131.hnd PRE_first_tail_x15_r0_body.khinv131 (phB PRE_first_tail_x15_r0_body.cx0_131.mlx) = true
kernel_rfl PRE_first_tail_x15_r0_body.cband131 : PRE_first_tail_x15_r0_body.kd131.checkBand PRE_first_tail_x15_r0_body.P131.lo = true
kernel_rfl PRE_first_tail_x15_r0_body.cnh1pos131 : Nat.blt 0 PRE_first_tail_x15_r0_body.kd131.nh1 = true
kernel_rfl PRE_first_tail_x15_r0_body.cnren131 : checkRenG PRE_first_tail_x15_r0_body.kd131.node PRE_first_tail_x15_r0_body.kninv131 (pnB PRE_first_tail_x15_r0_body.cx0_131.mlx) = true
kernel_rfl PRE_first_tail_x15_r0_body.cnlow131 : (PTrie.keysA PRE_first_tail_x15_r0_body.kd131.node).all (fun j => Nat.ble PRE_first_tail_x15_r0_body.P131.NL j && Nat.blt (PRE_first_tail_x15_r0_body.kd131.nodeF j) PRE_first_tail_x15_r0_body.cx1_131.mlx.nnext) = true
kernel_rfl PRE_first_tail_x15_r0_body.cabs0a131 : PRE_first_tail_x15_r0_body.cx0_131.mlx.arrs.get 0 = none
kernel_rfl PRE_first_tail_x15_r0_body.cabs0b131 : PRE_first_tail_x15_r0_body.cx0_131.mlx.objs.get 0 = none
kernel_rfl PRE_first_tail_x15_r0_body.ctok1131 : PRE_first_tail_x15_r0_body.cx1_131.mlx.tokens = []
kernel_rfl PRE_first_tail_x15_r0_body.cpend131 : PRE_first_tail_x15_r0_body.cx1_131.mlx.pending = PRE_first_tail_x15_r0_body.cx0_131.mlx.pending.map PRE_first_tail_x15_r0_body.kappa131.pend
kernel_rfl PRE_first_tail_x15_r0_body.cerrh131 : PRE_first_tail_x15_r0_body.cx1_131.mlx.errh = PRE_first_tail_x15_r0_body.cx0_131.mlx.errh.map PRE_first_tail_x15_r0_body.kappa131.arg
kernel_rfl PRE_first_tail_x15_r0_body.cfiles131 : PRE_first_tail_x15_r0_body.cx1_131.mlx.files = PRE_first_tail_x15_r0_body.cx0_131.mlx.files
kernel_rfl PRE_first_tail_x15_r0_body.carch131 : PRE_first_tail_x15_r0_body.cx1_131.mlx.arch = PRE_first_tail_x15_r0_body.cx0_131.mlx.arch
kernel_rfl PRE_first_tail_x15_r0_body.csizes131 : PRE_first_tail_x15_r0_body.cx1_131.mlx.deviceSizes = PRE_first_tail_x15_r0_body.cx0_131.mlx.deviceSizes
kernel_rfl PRE_first_tail_x15_r0_body.cwired131 : PRE_first_tail_x15_r0_body.cx1_131.mlx.wired = PRE_first_tail_x15_r0_body.cx0_131.mlx.wired
kernel_rfl PRE_first_tail_x15_r0_body.chost131 : PRE_first_tail_x15_r0_body.cx1_131.host = PRE_first_tail_x15_r0_body.cx0_131.host
-- the compaction map's addresses are `PRE_first_tail_x15_r0_body.kd131`'s
kernel_rfl PRE_first_tail_x15_r0_body.ckn0131 : PRE_first_tail_x15_r0_body.kd131.n0 = 2777542
kernel_rfl PRE_first_tail_x15_r0_body.ckn1131 : PRE_first_tail_x15_r0_body.kd131.n1 = 2777552
kernel_rfl PRE_first_tail_x15_r0_body.ckheap131 : (PTrie.keysA PRE_first_tail_x15_r0_body.kd131.heap).all (fun x => Nat.ble 2777541 x) = true
kernel_rfl PRE_first_tail_x15_r0_body.ckpl131 : (List.range 1).all (fun j => decide (PRE_first_tail_x15_r0_body.kd131.heap.get (2777541 + j) = nth? PRE_first_tail_x15_r0_body.pl131 j)) = true
-- the map fixes the call's names (`Conv.fixOld_compact`), the call's counters
kernel_rfl PRE_first_tail_x15_r0_body.fja131 : Nat.ble 2777541 2777541 = true
kernel_rfl PRE_first_tail_x15_r0_body.fn131 : Nat.ble 5653 5653 = true
kernel_rfl PRE_first_tail_x15_r0_body.fjaD131 : Nat.ble 2777541 PRE_first_tail_x15_r0_body.kd131.n0 = true
kernel_rfl PRE_first_tail_x15_r0_body.fxn131 : Nat.ble 20777 PRE_first_tail_x15_r0_body.kd131.nh0 = true
kernel_rfl PRE_first_tail_x15_r0_body.fnn131 : Nat.ble 17866 PRE_first_tail_x15_r0_body.kd131.nn0 = true
kernel_rfl PRE_first_tail_x15_r0_body.fxb131 : Nat.ble 20777 RData.bigHi = true
kernel_rfl PRE_first_tail_x15_r0_body.fheap131 : (PTrie.keysA PRE_first_tail_x15_r0_body.kd131.heap).all (Nat.ble (⟨20777, 17866, 2777541, 5653⟩ : Conv.Cnt).ja) = true
kernel_rfl PRE_first_tail_x15_r0_body.fhnd131 : (PTrie.keysA PRE_first_tail_x15_r0_body.kd131.hnd).all (Nat.ble (⟨20777, 17866, 2777541, 5653⟩ : Conv.Cnt).xn) = true
kernel_rfl PRE_first_tail_x15_r0_body.fnode131 : (PTrie.keysA PRE_first_tail_x15_r0_body.kd131.node).all (Nat.ble (⟨20777, 17866, 2777541, 5653⟩ : Conv.Cnt).nn) = true
/-- The compaction map fixes the call's names. -/
theorem PRE_first_tail_x15_r0_body.cfix131 : Conv.FixOld (⟨20777, 17866, 2777541, 5653⟩ : Conv.Cnt) PRE_first_tail_x15_r0_body.kappa131 :=
  Conv.fixOld_compact (Nat.le_of_ble_eq_true PRE_first_tail_x15_r0_body.fja131) (Nat.le_of_ble_eq_true PRE_first_tail_x15_r0_body.fn131) (Nat.le_of_ble_eq_true PRE_first_tail_x15_r0_body.fjaD131) (Nat.le_of_ble_eq_true PRE_first_tail_x15_r0_body.fxn131) (Nat.le_of_ble_eq_true PRE_first_tail_x15_r0_body.fnn131) (Nat.le_of_ble_eq_true PRE_first_tail_x15_r0_body.fxb131) PRE_first_tail_x15_r0_body.fheap131 PRE_first_tail_x15_r0_body.fhnd131 PRE_first_tail_x15_r0_body.fnode131
kernel_rfl PRE_first_tail_x15_r0_body.fcxn131 : (⟨20777, 17866, 2777541, 5653⟩ : Conv.Cnt).xn = (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1153.ffi).mlx.next
kernel_rfl PRE_first_tail_x15_r0_body.fcnn131 : (⟨20777, 17866, 2777541, 5653⟩ : Conv.Cnt).nn = (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1153.ffi).mlx.nnext
kernel_rfl PRE_first_tail_x15_r0_body.fle0131 : (Nat.ble (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1153.ffi).mlx.next PRE_first_tail_x15_r0_body.cx0_131.mlx.next && Nat.ble (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1153.ffi).mlx.nnext PRE_first_tail_x15_r0_body.cx0_131.mlx.nnext && Nat.ble (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1153.ffi).mlx.next RData.bigHi) = true
kernel_rfl PRE_first_tail_x15_r0_body.fnk131 : (PTrie.keysA PRE_first_tail_x15_r0_body.kd131.node).all (Nat.ble (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1153.ffi).mlx.nnext) = true
-- the merged state keeps the call's entries off the stage's footprint
kernel_rfl PRE_first_tail_x15_r0_body.f1A131 : PRE_first_tail_x15_r0_body.cx1_131.mlx.arrs = Stage.setAll (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1153.ffi).mlx.arrs (PRE_first_tail_x15_r0_body.cwS131.filterMap fun i => (PRE_first_tail_x15_r0_body.cx1_131.mlx.arrs.get i).map (i, ·))
kernel_rfl PRE_first_tail_x15_r0_body.f1O131 : PRE_first_tail_x15_r0_body.cx1_131.mlx.objs = Stage.setAll (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1153.ffi).mlx.objs (PRE_first_tail_x15_r0_body.cwS131.filterMap fun i => (PRE_first_tail_x15_r0_body.cx1_131.mlx.objs.get i).map (i, ·))
kernel_rfl PRE_first_tail_x15_r0_body.f1N131 : PRE_first_tail_x15_r0_body.cx1_131.mlx.nodes = Stage.setAll (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1153.ffi).mlx.nodes (PRE_first_tail_x15_r0_body.cnS131.filterMap fun i => (PRE_first_tail_x15_r0_body.cx1_131.mlx.nodes.get i).map (i, ·))
kernel_rfl PRE_first_tail_x15_r0_body.f1I131 : PRE_first_tail_x15_r0_body.cx1_131.mlx.items = Stage.setAll (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1153.ffi).mlx.items (PRE_first_tail_x15_r0_body.ciS131.filterMap fun i => (PRE_first_tail_x15_r0_body.cx1_131.mlx.items.get i).map (i, ·))
kernel_rfl PRE_first_tail_x15_r0_body.fbd131 : (PRE_first_tail_x15_r0_body.clo131 ++ PRE_first_tail_x15_r0_body.cln131 ++ PRE_first_tail_x15_r0_body.cli131 ++ PRE_first_tail_x15_r0_body.cwS131 ++ PRE_first_tail_x15_r0_body.cnS131 ++ PRE_first_tail_x15_r0_body.ciS131).all (fun i => Nat.blt (i / 4096) (4 ^ 31)) = true
kernel_rfl PRE_first_tail_x15_r0_body.fincW131 : PRE_first_tail_x15_r0_body.cwS131.all (fun h => !Nat.blt h (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1153.ffi).mlx.next || PRE_first_tail_x15_r0_body.clo131.contains h) = true
kernel_rfl PRE_first_tail_x15_r0_body.fincI131 : PRE_first_tail_x15_r0_body.ciS131.all (fun k => !Nat.blt k (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1153.ffi).mlx.nnext || PRE_first_tail_x15_r0_body.cli131.contains k) = true
kernel_rfl PRE_first_tail_x15_r0_body.fincN131 : PRE_first_tail_x15_r0_body.cnS131.all (Nat.ble (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1153.ffi).mlx.nnext) = true
kernel_rfl PRE_first_tail_x15_r0_body.flnF131 : PRE_first_tail_x15_r0_body.cln131.all (Nat.ble (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1153.ffi).mlx.nnext) = true
-- the checks over the changed lists
kernel_rfl PRE_first_tail_x15_r0_body.fh131 : PRE_first_tail_x15_r0_body.clo131.all (handleOK PRE_first_tail_x15_r0_body.kappa131 PRE_first_tail_x15_r0_body.P131.lo PRE_first_tail_x15_r0_body.cx0_131.mlx PRE_first_tail_x15_r0_body.cx1_131.mlx) = true
kernel_rfl PRE_first_tail_x15_r0_body.fo131 : PRE_first_tail_x15_r0_body.clo131.map (fun h => PRE_first_tail_x15_r0_body.cx1_131.mlx.objs.get (PRE_first_tail_x15_r0_body.kappa131.handle h)) = PRE_first_tail_x15_r0_body.clo131.map (fun h => (PRE_first_tail_x15_r0_body.cx0_131.mlx.objs.get h).map PRE_first_tail_x15_r0_body.kappa131.nobj)
kernel_rfl PRE_first_tail_x15_r0_body.fok131 : PRE_first_tail_x15_r0_body.clo131.all (objOK PRE_first_tail_x15_r0_body.kappa131 PRE_first_tail_x15_r0_body.P131.NL PRE_first_tail_x15_r0_body.cx0_131.mlx) = true
kernel_rfl PRE_first_tail_x15_r0_body.fnd131 : PRE_first_tail_x15_r0_body.cln131.all (nodeOKF PRE_first_tail_x15_r0_body.kappa131 PRE_first_tail_x15_r0_body.P131 PRE_first_tail_x15_r0_body.cx0_131.mlx PRE_first_tail_x15_r0_body.cx1_131.mlx) = true
kernel_rfl PRE_first_tail_x15_r0_body.fp131 : ((PRE_first_tail_x15_r0_body.cln131.filter (fullB PRE_first_tail_x15_r0_body.P131))).map (fun i => (PRE_first_tail_x15_r0_body.cx1_131.mlx.nodes.get (PRE_first_tail_x15_r0_body.kappa131.node i)).map Host.Mlx.Ffi.Node.prim) =
  ((PRE_first_tail_x15_r0_body.cln131.filter (fullB PRE_first_tail_x15_r0_body.P131))).map (fun i => (PRE_first_tail_x15_r0_body.cx0_131.mlx.nodes.get i).map fun nd => PRE_first_tail_x15_r0_body.kappa131.prim nd.prim)
kernel_rfl PRE_first_tail_x15_r0_body.fnordI131 : incrB PRE_first_tail_x15_r0_body.kd131.nodeF (List.range' 17866 0) = true
kernel_rfl PRE_first_tail_x15_r0_body.fnordK131 : (PTrie.keysA PRE_first_tail_x15_r0_body.kd131.node).all (fun k => Nat.ble 17866 k && Nat.blt k 17866) = true
kernel_rfl PRE_first_tail_x15_r0_body.fnordL131 : (PRE_first_tail_x15_r0_body.cln131.filter (Nat.ble PRE_first_tail_x15_r0_body.P131.N0)).all (fun i => Nat.ble i (PRE_first_tail_x15_r0_body.kd131.nodeF i) && (Nat.blt i 17866 || Nat.ble PRE_first_tail_x15_r0_body.kd131.nn0 i)) = true
theorem PRE_first_tail_x15_r0_body.fnord131 : (PRE_first_tail_x15_r0_body.cln131.filter (Nat.ble PRE_first_tail_x15_r0_body.P131.N0)).all (fun i => Nat.ble i (PRE_first_tail_x15_r0_body.kd131.nodeF i) &&
    (PTrie.keysA PRE_first_tail_x15_r0_body.kd131.node).all fun j => !Nat.blt j i || Nat.blt (PRE_first_tail_x15_r0_body.kd131.nodeF j) (PRE_first_tail_x15_r0_body.kd131.nodeF i)) = true :=
  cnord_of PRE_first_tail_x15_r0_body.cnlow131 PRE_first_tail_x15_r0_body.cnn1131 PRE_first_tail_x15_r0_body.fnordI131 PRE_first_tail_x15_r0_body.fnordK131 PRE_first_tail_x15_r0_body.fnordL131
kernel_rfl PRE_first_tail_x15_r0_body.fi131 : PRE_first_tail_x15_r0_body.cli131.all (pnB PRE_first_tail_x15_r0_body.cx0_131.mlx) = true
kernel_rfl PRE_first_tail_x15_r0_body.fii131 : PRE_first_tail_x15_r0_body.cli131.all (fun k => decide (PRE_first_tail_x15_r0_body.cx1_131.mlx.items.get (PRE_first_tail_x15_r0_body.kappa131.node k) = (PRE_first_tail_x15_r0_body.cx0_131.mlx.items.get k).map PRE_first_tail_x15_r0_body.kappa131.nv)) = true
/-- **The compaction's footprint.** -/
theorem PRE_first_tail_x15_r0_body.cfoot131 (clean : Conv.NClean (⟨20777, 17866, 2777541, 5653⟩ : Conv.Cnt) (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1153.ffi).mlx) (hltC : ∀ h, PH (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1153.ffi).mlx h → h < (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1153.ffi).mlx.next) (nltC : ∀ i, PN (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1153.ffi).mlx i → i < (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1153.ffi).mlx.nnext) (itemsC : ∀ k v, (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1153.ffi).mlx.items.get k = some v → PN (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1153.ffi).mlx k) (tracedC : ∀ h o, (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1153.ffi).mlx.objs.get h = some o → ∀ i ∈ objTraces o, i < PRE_first_tail_x15_r0_body.P131.NL) (cl : SSt (· < 5653) PRE_first_tail_x15_r0_body.cx0_131.mlx) :
    Conv.MFoot PRE_first_tail_x15_r0_body.P131 5653 PRE_first_tail_x15_r0_body.kappa131 PRE_first_tail_x15_r0_body.kd131 PRE_first_tail_x15_r0_body.khinv131 PRE_first_tail_x15_r0_body.kninv131 (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1153.ffi).mlx PRE_first_tail_x15_r0_body.cx0_131.mlx PRE_first_tail_x15_r0_body.cx1_131.mlx (⟨20777, 17866, 2777541, 5653⟩ : Conv.Cnt) PRE_first_tail_x15_r0_body.clo131 PRE_first_tail_x15_r0_body.cln131 PRE_first_tail_x15_r0_body.cli131 PRE_first_tail_x15_r0_body.cwS131 PRE_first_tail_x15_r0_body.cnS131 PRE_first_tail_x15_r0_body.ciS131 :=
  ⟨rfl, rfl, rfl, PRE_first_tail_x15_r0_body.cnh0131, PRE_first_tail_x15_r0_body.cnh1131, PRE_first_tail_x15_r0_body.cnn0131, PRE_first_tail_x15_r0_body.cnn1131, PRE_first_tail_x15_r0_body.cplo131, PRE_first_tail_x15_r0_body.ccnt131, PRE_first_tail_x15_r0_body.cnband131, PRE_first_tail_x15_r0_body.chbelow131, PRE_first_tail_x15_r0_body.chren131, PRE_first_tail_x15_r0_body.cband131, PRE_first_tail_x15_r0_body.cnh1pos131, PRE_first_tail_x15_r0_body.cnren131, PRE_first_tail_x15_r0_body.cnlow131, PRE_first_tail_x15_r0_body.cabs0a131, PRE_first_tail_x15_r0_body.cabs0b131, PRE_first_tail_x15_r0_body.ctok1131, PRE_first_tail_x15_r0_body.cpend131, PRE_first_tail_x15_r0_body.cerrh131, PRE_first_tail_x15_r0_body.cfiles131, PRE_first_tail_x15_r0_body.carch131, PRE_first_tail_x15_r0_body.csizes131, PRE_first_tail_x15_r0_body.cwired131, PRE_first_tail_x15_r0_body.cfix131, clean, PRE_first_tail_x15_r0_body.fcxn131, PRE_first_tail_x15_r0_body.fcnn131, hltC, nltC, itemsC, tracedC, cl, PRE_first_tail_x15_r0_body.fle0131, PRE_first_tail_x15_r0_body.fnk131, PRE_first_tail_x15_r0_body.ckA131, PRE_first_tail_x15_r0_body.cobjsK131, PRE_first_tail_x15_r0_body.cnodesK131, PRE_first_tail_x15_r0_body.citemsK131, PRE_first_tail_x15_r0_body.f1A131, PRE_first_tail_x15_r0_body.f1O131, PRE_first_tail_x15_r0_body.f1N131, PRE_first_tail_x15_r0_body.f1I131, PRE_first_tail_x15_r0_body.fbd131, PRE_first_tail_x15_r0_body.fincW131, PRE_first_tail_x15_r0_body.fincI131, PRE_first_tail_x15_r0_body.fincN131, PRE_first_tail_x15_r0_body.flnF131, PRE_first_tail_x15_r0_body.fh131, PRE_first_tail_x15_r0_body.fo131, PRE_first_tail_x15_r0_body.fok131, PRE_first_tail_x15_r0_body.fnd131, PRE_first_tail_x15_r0_body.fp131, PRE_first_tail_x15_r0_body.fnord131, PRE_first_tail_x15_r0_body.fi131, PRE_first_tail_x15_r0_body.fii131⟩
theorem PRE_first_tail_x15_r0_body.cnshift131 (clean : Conv.NClean (⟨20777, 17866, 2777541, 5653⟩ : Conv.Cnt) (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1153.ffi).mlx) (hltC : ∀ h, PH (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1153.ffi).mlx h → h < (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1153.ffi).mlx.next) (nltC : ∀ i, PN (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1153.ffi).mlx i → i < (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1153.ffi).mlx.nnext) (itemsC : ∀ k v, (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1153.ffi).mlx.items.get k = some v → PN (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1153.ffi).mlx k) (tracedC : ∀ h o, (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1153.ffi).mlx.objs.get h = some o → ∀ i ∈ objTraces o, i < PRE_first_tail_x15_r0_body.P131.NL) (cl : SSt (· < 5653) PRE_first_tail_x15_r0_body.cx0_131.mlx) : NShift PRE_first_tail_x15_r0_body.P131 5653 PRE_first_tail_x15_r0_body.kappa131 PRE_first_tail_x15_r0_body.cx0_131 PRE_first_tail_x15_r0_body.cx1_131 :=
  Conv.nshift_of_foot (PRE_first_tail_x15_r0_body.cfoot131 clean hltC nltC itemsC tracedC cl) PRE_first_tail_x15_r0_body.chost131 (compact_a_eq PRE_first_tail_x15_r0_body.ckn0131 PRE_first_tail_x15_r0_body.ckn1131 PRE_first_tail_x15_r0_body.ckheap131 PRE_first_tail_x15_r0_body.ckpl131)

-- the observers: the layers' states at the call, the canonical and the merged state, their footprints and checks
noncomputable def PRE_first_tail_x15_r0_body.fxC_131 : PTrie Unit := (Host.Ts.Sim.Full.freedOf PRE_first_tail_x15_r0_body.s1153.ffi).getD PTrie.nil
noncomputable def PRE_first_tail_x15_r0_body.krC_131 : Host.Load.Layers.KRec := (Host.Ts.Sim.Full.krecOf PRE_first_tail_x15_r0_body.s1153.ffi).getD Host.Load.Layers.KRec.empty
kernel_rfl PRE_first_tail_x15_r0_body.ofxC_131 : (Host.Ts.Sim.Full.freedOf PRE_first_tail_x15_r0_body.s1153.ffi) = some PRE_first_tail_x15_r0_body.fxC_131
kernel_rfl PRE_first_tail_x15_r0_body.okrC_131 : (Host.Ts.Sim.Full.krecOf PRE_first_tail_x15_r0_body.s1153.ffi) = some PRE_first_tail_x15_r0_body.krC_131
noncomputable def PRE_first_tail_x15_r0_body.fx0_131 : PTrie Unit := (Host.Ts.Sim.Full.freedOf PRE_first_tail_x15_r0_body.s1155.ffi).getD PTrie.nil
noncomputable def PRE_first_tail_x15_r0_body.kr0_131 : Host.Load.Layers.KRec := (Host.Ts.Sim.Full.krecOf PRE_first_tail_x15_r0_body.s1155.ffi).getD Host.Load.Layers.KRec.empty
kernel_rfl PRE_first_tail_x15_r0_body.ofx0_131 : (Host.Ts.Sim.Full.freedOf PRE_first_tail_x15_r0_body.s1155.ffi) = some PRE_first_tail_x15_r0_body.fx0_131
kernel_rfl PRE_first_tail_x15_r0_body.okr0_131 : (Host.Ts.Sim.Full.krecOf PRE_first_tail_x15_r0_body.s1155.ffi) = some PRE_first_tail_x15_r0_body.kr0_131
noncomputable def PRE_first_tail_x15_r0_body.fx1_131 : PTrie Unit := (Host.Ts.Sim.Full.freedOf PRE_first_tail_x15_r0_body.s1154.ffi).getD PTrie.nil
noncomputable def PRE_first_tail_x15_r0_body.kr1_131 : Host.Load.Layers.KRec := (Host.Ts.Sim.Full.krecOf PRE_first_tail_x15_r0_body.s1154.ffi).getD Host.Load.Layers.KRec.empty
kernel_rfl PRE_first_tail_x15_r0_body.ofx1_131 : (Host.Ts.Sim.Full.freedOf PRE_first_tail_x15_r0_body.s1154.ffi) = some PRE_first_tail_x15_r0_body.fx1_131
kernel_rfl PRE_first_tail_x15_r0_body.okr1_131 : (Host.Ts.Sim.Full.krecOf PRE_first_tail_x15_r0_body.s1154.ffi) = some PRE_first_tail_x15_r0_body.kr1_131
kernel_rfl PRE_first_tail_x15_r0_body.ff0131 : PRE_first_tail_x15_r0_body.fx0_131 = Stage.setAll PRE_first_tail_x15_r0_body.fxC_131 (PRE_first_tail_x15_r0_body.clo131.filterMap fun i => (PRE_first_tail_x15_r0_body.fx0_131.get i).map (i, ·))
kernel_rfl PRE_first_tail_x15_r0_body.ff1131 : PRE_first_tail_x15_r0_body.fx1_131 = Stage.setAll PRE_first_tail_x15_r0_body.fxC_131 (PRE_first_tail_x15_r0_body.cwS131.filterMap fun i => (PRE_first_tail_x15_r0_body.fx1_131.get i).map (i, ·))
kernel_rfl PRE_first_tail_x15_r0_body.ffck131 : freedLB PRE_first_tail_x15_r0_body.kappa131 PRE_first_tail_x15_r0_body.cx0_131.mlx PRE_first_tail_x15_r0_body.fx0_131 PRE_first_tail_x15_r0_body.fx1_131 PRE_first_tail_x15_r0_body.clo131 = true
kernel_rfl PRE_first_tail_x15_r0_body.fkf0131 : PRE_first_tail_x15_r0_body.kr0_131.flags = Stage.setAll PRE_first_tail_x15_r0_body.krC_131.flags (PRE_first_tail_x15_r0_body.clo131.filterMap fun i => (PRE_first_tail_x15_r0_body.kr0_131.flags.get i).map (i, ·))
kernel_rfl PRE_first_tail_x15_r0_body.fkt0131 : PRE_first_tail_x15_r0_body.kr0_131.targs = Stage.setAll PRE_first_tail_x15_r0_body.krC_131.targs (PRE_first_tail_x15_r0_body.clo131.filterMap fun i => (PRE_first_tail_x15_r0_body.kr0_131.targs.get i).map (i, ·))
kernel_rfl PRE_first_tail_x15_r0_body.fkf1131 : PRE_first_tail_x15_r0_body.kr1_131.flags = Stage.setAll PRE_first_tail_x15_r0_body.krC_131.flags (PRE_first_tail_x15_r0_body.cwS131.filterMap fun i => (PRE_first_tail_x15_r0_body.kr1_131.flags.get i).map (i, ·))
kernel_rfl PRE_first_tail_x15_r0_body.fkt1131 : PRE_first_tail_x15_r0_body.kr1_131.targs = Stage.setAll PRE_first_tail_x15_r0_body.krC_131.targs (PRE_first_tail_x15_r0_body.cwS131.filterMap fun i => (PRE_first_tail_x15_r0_body.kr1_131.targs.get i).map (i, ·))
kernel_rfl PRE_first_tail_x15_r0_body.fkck131 : krecLB PRE_first_tail_x15_r0_body.kappa131 5653 PRE_first_tail_x15_r0_body.cx0_131.mlx PRE_first_tail_x15_r0_body.kr0_131 PRE_first_tail_x15_r0_body.kr1_131 PRE_first_tail_x15_r0_body.clo131 = true
kernel_rfl PRE_first_tail_x15_r0_body.fkn131 : Nat.ble 5653 5653 = true
-- the bridge and the pending traces' regions
kernel_rfl PRE_first_tail_x15_r0_body.cbridge131 : Host.Ts.Sim.Full.bridgeOf PRE_first_tail_x15_r0_body.s1154.ffi = Host.Ts.Sim.Full.bridgeOf PRE_first_tail_x15_r0_body.s1155.ffi
kernel_rfl PRE_first_tail_x15_r0_body.cpendR131 : pendRegB PRE_first_tail_x15_r0_body.kappa131 (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1155.ffi).mlx = true
kernel_rfl PRE_first_tail_x15_r0_body.cpendLe131 : Nat.ble (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1155.ffi).mlx.next (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1154.ffi).mlx.next = true
/-- **The compaction's native shift**, given the call's bookkeeping, its relation's facts (the model's and the
observers') and the canonical closedness. -/
theorem PRE_first_tail_x15_r0_body.cshift131 (clean : Conv.NClean (⟨20777, 17866, 2777541, 5653⟩ : Conv.Cnt) (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1153.ffi).mlx) (hltC : ∀ h, PH (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1153.ffi).mlx h → h < (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1153.ffi).mlx.next) (nltC : ∀ i, PN (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1153.ffi).mlx i → i < (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1153.ffi).mlx.nnext) (itemsC : ∀ k v, (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1153.ffi).mlx.items.get k = some v → PN (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1153.ffi).mlx k) (tracedC : ∀ h o, (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1153.ffi).mlx.objs.get h = some o → ∀ i ∈ objTraces o, i < PRE_first_tail_x15_r0_body.P131.NL) (cl : SSt (· < 5653) PRE_first_tail_x15_r0_body.cx0_131.mlx)
    (hobjC : ∀ h, PRE_first_tail_x15_r0_body.fxC_131.get h = some () → ((Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1153.ffi).mlx.objs.get h).isSome = true)
    (hfC : ∀ h, (PRE_first_tail_x15_r0_body.krC_131.flags.get h).isSome = true → ((Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1153.ffi).mlx.objs.get h).isSome = true)
    (htC : ∀ h, (PRE_first_tail_x15_r0_body.krC_131.targs.get h).isSome = true → ((Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1153.ffi).mlx.objs.get h).isSome = true)
    (hclC : ∀ h l, PRE_first_tail_x15_r0_body.krC_131.targs.get h = some l → Host.Ts.Sim.Full.STargs (· < (⟨20777, 17866, 2777541, 5653⟩ : Conv.Cnt).n) l) :
    Conv.FullShiftQ PRE_first_tail_x15_r0_body.P131 5653 PRE_first_tail_x15_r0_body.kappa131 PRE_first_tail_x15_r0_body.s1155.ffi PRE_first_tail_x15_r0_body.s1154.ffi :=
  ⟨PRE_first_tail_x15_r0_body.cnshift131 clean hltC nltC itemsC tracedC cl, PRE_first_tail_x15_r0_body.cqueue131, fun t ht => bSN_sound (List.all_eq_true.mp PRE_first_tail_x15_r0_body.ctokSupp131 t ht),
    PRE_first_tail_x15_r0_body.cbridge131,
    liveShift_foot (x0' := Host.Ts.Sim.Full.mlxOf PRE_first_tail_x15_r0_body.s1155.ffi) (x1' := Host.Ts.Sim.Full.mlxOf PRE_first_tail_x15_r0_body.s1154.ffi) (PRE_first_tail_x15_r0_body.cfoot131 clean hltC nltC itemsC tracedC cl) rfl PRE_first_tail_x15_r0_body.ofx0_131 PRE_first_tail_x15_r0_body.ofx1_131 hobjC PRE_first_tail_x15_r0_body.ff0131 PRE_first_tail_x15_r0_body.ff1131 PRE_first_tail_x15_r0_body.ffck131,
    kernShift_foot (x0' := Host.Ts.Sim.Full.mlxOf PRE_first_tail_x15_r0_body.s1155.ffi) (x1' := Host.Ts.Sim.Full.mlxOf PRE_first_tail_x15_r0_body.s1154.ffi) (PRE_first_tail_x15_r0_body.cfoot131 clean hltC nltC itemsC tracedC cl) rfl PRE_first_tail_x15_r0_body.okr0_131 PRE_first_tail_x15_r0_body.okr1_131 (Nat.le_of_ble_eq_true PRE_first_tail_x15_r0_body.fkn131) hfC htC hclC
      PRE_first_tail_x15_r0_body.fkf0131 PRE_first_tail_x15_r0_body.fkt0131 PRE_first_tail_x15_r0_body.fkf1131 PRE_first_tail_x15_r0_body.fkt1131 PRE_first_tail_x15_r0_body.fkck131,
    pendReg_of rfl PRE_first_tail_x15_r0_body.cnh0131 PRE_first_tail_x15_r0_body.cnh1131 (Nat.le_of_ble_eq_true PRE_first_tail_x15_r0_body.cpendLe131) PRE_first_tail_x15_r0_body.cpendR131⟩

end Host.Load.Run.Tpl
