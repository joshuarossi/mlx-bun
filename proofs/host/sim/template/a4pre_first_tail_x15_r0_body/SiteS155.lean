import host.sim.template.a4pre_first_tail_x15_r0_body.SiteCl155
import host.sim.conv.CompactFull
import host.sim.template.FootGen
set_option Elab.async false
namespace Host.Load.Run.Tpl
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
open Host.Ts Host.Ts.Sim Host.Ts.Sim.Template

/-! The compaction's native shift at call site 155 from its footprint (`Conv.nshift_of_foot`), and the observers'
(`liveShift_foot`, `kernShift_foot`): `Conv.FullShiftQ` for `Conv.full_compactQ`, given the call's bookkeeping and its
relation's facts. -/

/-- The load parameters of the chain (band-free: its start's node counter as `NL` and `N0`). -/
def PRE_first_tail_x15_r0_body.Pc155 : LoadP := ⟨18151, 131072, 1099511627776, 15235, 15235, []⟩
/-- The site's band raised to the map's checked fixed-node prefix, including newly recorded closure traces. -/
def PRE_first_tail_x15_r0_body.P155 : LoadP := PRE_first_tail_x15_r0_body.Pc155.raise 18340
kernel_rfl PRE_first_tail_x15_r0_body.craise155 : Nat.ble PRE_first_tail_x15_r0_body.Pc155.N0 18340 = true
theorem PRE_first_tail_x15_r0_body.raised155 : Host.Ts.Sim.Full.Raised PRE_first_tail_x15_r0_body.Pc155 PRE_first_tail_x15_r0_body.P155 :=
  .inr ⟨18340, rfl, Nat.le_of_ble_eq_true PRE_first_tail_x15_r0_body.craise155, rfl⟩
noncomputable abbrev PRE_first_tail_x15_r0_body.cx0_155 : Host.Load.LSt := clearTokens (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1496.ffi)
noncomputable abbrev PRE_first_tail_x15_r0_body.cx1_155 : Host.Load.LSt := clearTokens (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1495.ffi)
def PRE_first_tail_x15_r0_body.khinv155 : PTrie Nat := Stage.setAll PTrie.nil []
def PRE_first_tail_x15_r0_body.kninv155 : PTrie Nat := Stage.setAll PTrie.nil []
/-- The stage's footprint: its written and fresh handles, fresh nodes, written and fresh items. -/
def PRE_first_tail_x15_r0_body.cwS155 : List Nat := []
def PRE_first_tail_x15_r0_body.cnS155 : List Nat := List.range' 18340 0
def PRE_first_tail_x15_r0_body.ciS155 : List Nat := [] ++ List.range' 18340 0

-- the small checks (`MChecks`'s)
kernel_rfl PRE_first_tail_x15_r0_body.cnh0155 : PRE_first_tail_x15_r0_body.kd155.nh0 = PRE_first_tail_x15_r0_body.cx0_155.mlx.next
kernel_rfl PRE_first_tail_x15_r0_body.cnh1155 : PRE_first_tail_x15_r0_body.kd155.nh1 = PRE_first_tail_x15_r0_body.cx1_155.mlx.next
kernel_rfl PRE_first_tail_x15_r0_body.cnn0155 : PRE_first_tail_x15_r0_body.kd155.nn0 = PRE_first_tail_x15_r0_body.cx0_155.mlx.nnext
kernel_rfl PRE_first_tail_x15_r0_body.cnn1155 : PRE_first_tail_x15_r0_body.kd155.nn1 = PRE_first_tail_x15_r0_body.cx1_155.mlx.nnext
kernel_rfl PRE_first_tail_x15_r0_body.cplo155 : (Nat.blt 0 PRE_first_tail_x15_r0_body.P155.lo && Nat.ble PRE_first_tail_x15_r0_body.P155.lo PRE_first_tail_x15_r0_body.cx0_155.mlx.next && Nat.ble PRE_first_tail_x15_r0_body.P155.lo RData.bigHi && Nat.ble RData.bigHi PRE_first_tail_x15_r0_body.P155.E) = true
kernel_rfl PRE_first_tail_x15_r0_body.ccnt155 : (Nat.ble PRE_first_tail_x15_r0_body.cx0_155.mlx.next PRE_first_tail_x15_r0_body.cx1_155.mlx.next && Nat.ble PRE_first_tail_x15_r0_body.cx0_155.mlx.nnext PRE_first_tail_x15_r0_body.cx1_155.mlx.nnext) = true
kernel_rfl PRE_first_tail_x15_r0_body.cnband155 : (Nat.blt 0 PRE_first_tail_x15_r0_body.P155.NL && Nat.ble PRE_first_tail_x15_r0_body.P155.NL PRE_first_tail_x15_r0_body.P155.N0 && Nat.ble PRE_first_tail_x15_r0_body.P155.N0 PRE_first_tail_x15_r0_body.cx0_155.mlx.nnext) = true
kernel_rfl PRE_first_tail_x15_r0_body.chbelow155 : PRE_first_tail_x15_r0_body.kd155.checkHndBelow = true
kernel_rfl PRE_first_tail_x15_r0_body.chren155 : checkRenG PRE_first_tail_x15_r0_body.kd155.hnd PRE_first_tail_x15_r0_body.khinv155 (phB PRE_first_tail_x15_r0_body.cx0_155.mlx) = true
kernel_rfl PRE_first_tail_x15_r0_body.cband155 : PRE_first_tail_x15_r0_body.kd155.checkBand PRE_first_tail_x15_r0_body.P155.lo = true
kernel_rfl PRE_first_tail_x15_r0_body.cnh1pos155 : Nat.blt 0 PRE_first_tail_x15_r0_body.kd155.nh1 = true
kernel_rfl PRE_first_tail_x15_r0_body.cnren155 : checkRenG PRE_first_tail_x15_r0_body.kd155.node PRE_first_tail_x15_r0_body.kninv155 (pnB PRE_first_tail_x15_r0_body.cx0_155.mlx) = true
kernel_rfl PRE_first_tail_x15_r0_body.cnlow155 : (PTrie.keysA PRE_first_tail_x15_r0_body.kd155.node).all (fun j => Nat.ble PRE_first_tail_x15_r0_body.P155.NL j && Nat.blt (PRE_first_tail_x15_r0_body.kd155.nodeF j) PRE_first_tail_x15_r0_body.cx1_155.mlx.nnext) = true
kernel_rfl PRE_first_tail_x15_r0_body.cabs0a155 : PRE_first_tail_x15_r0_body.cx0_155.mlx.arrs.get 0 = none
kernel_rfl PRE_first_tail_x15_r0_body.cabs0b155 : PRE_first_tail_x15_r0_body.cx0_155.mlx.objs.get 0 = none
kernel_rfl PRE_first_tail_x15_r0_body.ctok1155 : PRE_first_tail_x15_r0_body.cx1_155.mlx.tokens = []
kernel_rfl PRE_first_tail_x15_r0_body.cpend155 : PRE_first_tail_x15_r0_body.cx1_155.mlx.pending = PRE_first_tail_x15_r0_body.cx0_155.mlx.pending.map PRE_first_tail_x15_r0_body.kappa155.pend
kernel_rfl PRE_first_tail_x15_r0_body.cerrh155 : PRE_first_tail_x15_r0_body.cx1_155.mlx.errh = PRE_first_tail_x15_r0_body.cx0_155.mlx.errh.map PRE_first_tail_x15_r0_body.kappa155.arg
kernel_rfl PRE_first_tail_x15_r0_body.cfiles155 : PRE_first_tail_x15_r0_body.cx1_155.mlx.files = PRE_first_tail_x15_r0_body.cx0_155.mlx.files
kernel_rfl PRE_first_tail_x15_r0_body.carch155 : PRE_first_tail_x15_r0_body.cx1_155.mlx.arch = PRE_first_tail_x15_r0_body.cx0_155.mlx.arch
kernel_rfl PRE_first_tail_x15_r0_body.csizes155 : PRE_first_tail_x15_r0_body.cx1_155.mlx.deviceSizes = PRE_first_tail_x15_r0_body.cx0_155.mlx.deviceSizes
kernel_rfl PRE_first_tail_x15_r0_body.cwired155 : PRE_first_tail_x15_r0_body.cx1_155.mlx.wired = PRE_first_tail_x15_r0_body.cx0_155.mlx.wired
kernel_rfl PRE_first_tail_x15_r0_body.chost155 : PRE_first_tail_x15_r0_body.cx1_155.host = PRE_first_tail_x15_r0_body.cx0_155.host
-- the compaction map's addresses are `PRE_first_tail_x15_r0_body.kd155`'s
kernel_rfl PRE_first_tail_x15_r0_body.ckn0155 : PRE_first_tail_x15_r0_body.kd155.n0 = 2796386
kernel_rfl PRE_first_tail_x15_r0_body.ckn1155 : PRE_first_tail_x15_r0_body.kd155.n1 = 2796396
kernel_rfl PRE_first_tail_x15_r0_body.ckheap155 : (PTrie.keysA PRE_first_tail_x15_r0_body.kd155.heap).all (fun x => Nat.ble 2796385 x) = true
kernel_rfl PRE_first_tail_x15_r0_body.ckpl155 : (List.range 1).all (fun j => decide (PRE_first_tail_x15_r0_body.kd155.heap.get (2796385 + j) = nth? PRE_first_tail_x15_r0_body.pl155 j)) = true
-- the map fixes the call's names (`Conv.fixOld_compact`), the call's counters
kernel_rfl PRE_first_tail_x15_r0_body.fja155 : Nat.ble 2796385 2796385 = true
kernel_rfl PRE_first_tail_x15_r0_body.fn155 : Nat.ble 6679 6679 = true
kernel_rfl PRE_first_tail_x15_r0_body.fjaD155 : Nat.ble 2796385 PRE_first_tail_x15_r0_body.kd155.n0 = true
kernel_rfl PRE_first_tail_x15_r0_body.fxn155 : Nat.ble 21249 PRE_first_tail_x15_r0_body.kd155.nh0 = true
kernel_rfl PRE_first_tail_x15_r0_body.fnn155 : Nat.ble 18340 PRE_first_tail_x15_r0_body.kd155.nn0 = true
kernel_rfl PRE_first_tail_x15_r0_body.fxb155 : Nat.ble 21249 RData.bigHi = true
kernel_rfl PRE_first_tail_x15_r0_body.fheap155 : (PTrie.keysA PRE_first_tail_x15_r0_body.kd155.heap).all (Nat.ble (⟨21249, 18340, 2796385, 6679⟩ : Conv.Cnt).ja) = true
kernel_rfl PRE_first_tail_x15_r0_body.fhnd155 : (PTrie.keysA PRE_first_tail_x15_r0_body.kd155.hnd).all (Nat.ble (⟨21249, 18340, 2796385, 6679⟩ : Conv.Cnt).xn) = true
kernel_rfl PRE_first_tail_x15_r0_body.fnode155 : (PTrie.keysA PRE_first_tail_x15_r0_body.kd155.node).all (Nat.ble (⟨21249, 18340, 2796385, 6679⟩ : Conv.Cnt).nn) = true
/-- The compaction map fixes the call's names. -/
theorem PRE_first_tail_x15_r0_body.cfix155 : Conv.FixOld (⟨21249, 18340, 2796385, 6679⟩ : Conv.Cnt) PRE_first_tail_x15_r0_body.kappa155 :=
  Conv.fixOld_compact (Nat.le_of_ble_eq_true PRE_first_tail_x15_r0_body.fja155) (Nat.le_of_ble_eq_true PRE_first_tail_x15_r0_body.fn155) (Nat.le_of_ble_eq_true PRE_first_tail_x15_r0_body.fjaD155) (Nat.le_of_ble_eq_true PRE_first_tail_x15_r0_body.fxn155) (Nat.le_of_ble_eq_true PRE_first_tail_x15_r0_body.fnn155) (Nat.le_of_ble_eq_true PRE_first_tail_x15_r0_body.fxb155) PRE_first_tail_x15_r0_body.fheap155 PRE_first_tail_x15_r0_body.fhnd155 PRE_first_tail_x15_r0_body.fnode155
kernel_rfl PRE_first_tail_x15_r0_body.fcxn155 : (⟨21249, 18340, 2796385, 6679⟩ : Conv.Cnt).xn = (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1494.ffi).mlx.next
kernel_rfl PRE_first_tail_x15_r0_body.fcnn155 : (⟨21249, 18340, 2796385, 6679⟩ : Conv.Cnt).nn = (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1494.ffi).mlx.nnext
kernel_rfl PRE_first_tail_x15_r0_body.fle0155 : (Nat.ble (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1494.ffi).mlx.next PRE_first_tail_x15_r0_body.cx0_155.mlx.next && Nat.ble (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1494.ffi).mlx.nnext PRE_first_tail_x15_r0_body.cx0_155.mlx.nnext && Nat.ble (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1494.ffi).mlx.next RData.bigHi) = true
kernel_rfl PRE_first_tail_x15_r0_body.fnk155 : (PTrie.keysA PRE_first_tail_x15_r0_body.kd155.node).all (Nat.ble (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1494.ffi).mlx.nnext) = true
-- the merged state keeps the call's entries off the stage's footprint
kernel_rfl PRE_first_tail_x15_r0_body.f1A155 : PRE_first_tail_x15_r0_body.cx1_155.mlx.arrs = Stage.setAll (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1494.ffi).mlx.arrs (PRE_first_tail_x15_r0_body.cwS155.filterMap fun i => (PRE_first_tail_x15_r0_body.cx1_155.mlx.arrs.get i).map (i, ·))
kernel_rfl PRE_first_tail_x15_r0_body.f1O155 : PRE_first_tail_x15_r0_body.cx1_155.mlx.objs = Stage.setAll (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1494.ffi).mlx.objs (PRE_first_tail_x15_r0_body.cwS155.filterMap fun i => (PRE_first_tail_x15_r0_body.cx1_155.mlx.objs.get i).map (i, ·))
kernel_rfl PRE_first_tail_x15_r0_body.f1N155 : PRE_first_tail_x15_r0_body.cx1_155.mlx.nodes = Stage.setAll (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1494.ffi).mlx.nodes (PRE_first_tail_x15_r0_body.cnS155.filterMap fun i => (PRE_first_tail_x15_r0_body.cx1_155.mlx.nodes.get i).map (i, ·))
kernel_rfl PRE_first_tail_x15_r0_body.f1I155 : PRE_first_tail_x15_r0_body.cx1_155.mlx.items = Stage.setAll (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1494.ffi).mlx.items (PRE_first_tail_x15_r0_body.ciS155.filterMap fun i => (PRE_first_tail_x15_r0_body.cx1_155.mlx.items.get i).map (i, ·))
kernel_rfl PRE_first_tail_x15_r0_body.fbd155 : (PRE_first_tail_x15_r0_body.clo155 ++ PRE_first_tail_x15_r0_body.cln155 ++ PRE_first_tail_x15_r0_body.cli155 ++ PRE_first_tail_x15_r0_body.cwS155 ++ PRE_first_tail_x15_r0_body.cnS155 ++ PRE_first_tail_x15_r0_body.ciS155).all (fun i => Nat.blt (i / 4096) (4 ^ 31)) = true
kernel_rfl PRE_first_tail_x15_r0_body.fincW155 : PRE_first_tail_x15_r0_body.cwS155.all (fun h => !Nat.blt h (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1494.ffi).mlx.next || PRE_first_tail_x15_r0_body.clo155.contains h) = true
kernel_rfl PRE_first_tail_x15_r0_body.fincI155 : PRE_first_tail_x15_r0_body.ciS155.all (fun k => !Nat.blt k (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1494.ffi).mlx.nnext || PRE_first_tail_x15_r0_body.cli155.contains k) = true
kernel_rfl PRE_first_tail_x15_r0_body.fincN155 : PRE_first_tail_x15_r0_body.cnS155.all (Nat.ble (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1494.ffi).mlx.nnext) = true
kernel_rfl PRE_first_tail_x15_r0_body.flnF155 : PRE_first_tail_x15_r0_body.cln155.all (Nat.ble (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1494.ffi).mlx.nnext) = true
-- the checks over the changed lists
kernel_rfl PRE_first_tail_x15_r0_body.fh155 : PRE_first_tail_x15_r0_body.clo155.all (handleOK PRE_first_tail_x15_r0_body.kappa155 PRE_first_tail_x15_r0_body.P155.lo PRE_first_tail_x15_r0_body.cx0_155.mlx PRE_first_tail_x15_r0_body.cx1_155.mlx) = true
kernel_rfl PRE_first_tail_x15_r0_body.fo155 : PRE_first_tail_x15_r0_body.clo155.map (fun h => PRE_first_tail_x15_r0_body.cx1_155.mlx.objs.get (PRE_first_tail_x15_r0_body.kappa155.handle h)) = PRE_first_tail_x15_r0_body.clo155.map (fun h => (PRE_first_tail_x15_r0_body.cx0_155.mlx.objs.get h).map PRE_first_tail_x15_r0_body.kappa155.nobj)
kernel_rfl PRE_first_tail_x15_r0_body.fok155 : PRE_first_tail_x15_r0_body.clo155.all (objOK PRE_first_tail_x15_r0_body.kappa155 PRE_first_tail_x15_r0_body.P155.NL PRE_first_tail_x15_r0_body.cx0_155.mlx) = true
kernel_rfl PRE_first_tail_x15_r0_body.fnd155 : PRE_first_tail_x15_r0_body.cln155.all (nodeOKF PRE_first_tail_x15_r0_body.kappa155 PRE_first_tail_x15_r0_body.P155 PRE_first_tail_x15_r0_body.cx0_155.mlx PRE_first_tail_x15_r0_body.cx1_155.mlx) = true
kernel_rfl PRE_first_tail_x15_r0_body.fp155 : ((PRE_first_tail_x15_r0_body.cln155.filter (fullB PRE_first_tail_x15_r0_body.P155))).map (fun i => (PRE_first_tail_x15_r0_body.cx1_155.mlx.nodes.get (PRE_first_tail_x15_r0_body.kappa155.node i)).map Host.Mlx.Ffi.Node.prim) =
  ((PRE_first_tail_x15_r0_body.cln155.filter (fullB PRE_first_tail_x15_r0_body.P155))).map (fun i => (PRE_first_tail_x15_r0_body.cx0_155.mlx.nodes.get i).map fun nd => PRE_first_tail_x15_r0_body.kappa155.prim nd.prim)
kernel_rfl PRE_first_tail_x15_r0_body.fnordI155 : incrB PRE_first_tail_x15_r0_body.kd155.nodeF (List.range' 18340 0) = true
kernel_rfl PRE_first_tail_x15_r0_body.fnordK155 : (PTrie.keysA PRE_first_tail_x15_r0_body.kd155.node).all (fun k => Nat.ble 18340 k && Nat.blt k 18340) = true
kernel_rfl PRE_first_tail_x15_r0_body.fnordL155 : (PRE_first_tail_x15_r0_body.cln155.filter (Nat.ble PRE_first_tail_x15_r0_body.P155.N0)).all (fun i => Nat.ble i (PRE_first_tail_x15_r0_body.kd155.nodeF i) && (Nat.blt i 18340 || Nat.ble PRE_first_tail_x15_r0_body.kd155.nn0 i)) = true
theorem PRE_first_tail_x15_r0_body.fnord155 : (PRE_first_tail_x15_r0_body.cln155.filter (Nat.ble PRE_first_tail_x15_r0_body.P155.N0)).all (fun i => Nat.ble i (PRE_first_tail_x15_r0_body.kd155.nodeF i) &&
    (PTrie.keysA PRE_first_tail_x15_r0_body.kd155.node).all fun j => !Nat.blt j i || Nat.blt (PRE_first_tail_x15_r0_body.kd155.nodeF j) (PRE_first_tail_x15_r0_body.kd155.nodeF i)) = true :=
  cnord_of PRE_first_tail_x15_r0_body.cnlow155 PRE_first_tail_x15_r0_body.cnn1155 PRE_first_tail_x15_r0_body.fnordI155 PRE_first_tail_x15_r0_body.fnordK155 PRE_first_tail_x15_r0_body.fnordL155
kernel_rfl PRE_first_tail_x15_r0_body.fi155 : PRE_first_tail_x15_r0_body.cli155.all (pnB PRE_first_tail_x15_r0_body.cx0_155.mlx) = true
kernel_rfl PRE_first_tail_x15_r0_body.fii155 : PRE_first_tail_x15_r0_body.cli155.all (fun k => decide (PRE_first_tail_x15_r0_body.cx1_155.mlx.items.get (PRE_first_tail_x15_r0_body.kappa155.node k) = (PRE_first_tail_x15_r0_body.cx0_155.mlx.items.get k).map PRE_first_tail_x15_r0_body.kappa155.nv)) = true
/-- **The compaction's footprint.** -/
theorem PRE_first_tail_x15_r0_body.cfoot155 (clean : Conv.NClean (⟨21249, 18340, 2796385, 6679⟩ : Conv.Cnt) (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1494.ffi).mlx) (hltC : ∀ h, PH (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1494.ffi).mlx h → h < (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1494.ffi).mlx.next) (nltC : ∀ i, PN (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1494.ffi).mlx i → i < (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1494.ffi).mlx.nnext) (itemsC : ∀ k v, (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1494.ffi).mlx.items.get k = some v → PN (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1494.ffi).mlx k) (tracedC : ∀ h o, (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1494.ffi).mlx.objs.get h = some o → ∀ i ∈ objTraces o, i < PRE_first_tail_x15_r0_body.P155.NL) (cl : SSt (· < 6679) PRE_first_tail_x15_r0_body.cx0_155.mlx) :
    Conv.MFoot PRE_first_tail_x15_r0_body.P155 6679 PRE_first_tail_x15_r0_body.kappa155 PRE_first_tail_x15_r0_body.kd155 PRE_first_tail_x15_r0_body.khinv155 PRE_first_tail_x15_r0_body.kninv155 (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1494.ffi).mlx PRE_first_tail_x15_r0_body.cx0_155.mlx PRE_first_tail_x15_r0_body.cx1_155.mlx (⟨21249, 18340, 2796385, 6679⟩ : Conv.Cnt) PRE_first_tail_x15_r0_body.clo155 PRE_first_tail_x15_r0_body.cln155 PRE_first_tail_x15_r0_body.cli155 PRE_first_tail_x15_r0_body.cwS155 PRE_first_tail_x15_r0_body.cnS155 PRE_first_tail_x15_r0_body.ciS155 :=
  ⟨rfl, rfl, rfl, PRE_first_tail_x15_r0_body.cnh0155, PRE_first_tail_x15_r0_body.cnh1155, PRE_first_tail_x15_r0_body.cnn0155, PRE_first_tail_x15_r0_body.cnn1155, PRE_first_tail_x15_r0_body.cplo155, PRE_first_tail_x15_r0_body.ccnt155, PRE_first_tail_x15_r0_body.cnband155, PRE_first_tail_x15_r0_body.chbelow155, PRE_first_tail_x15_r0_body.chren155, PRE_first_tail_x15_r0_body.cband155, PRE_first_tail_x15_r0_body.cnh1pos155, PRE_first_tail_x15_r0_body.cnren155, PRE_first_tail_x15_r0_body.cnlow155, PRE_first_tail_x15_r0_body.cabs0a155, PRE_first_tail_x15_r0_body.cabs0b155, PRE_first_tail_x15_r0_body.ctok1155, PRE_first_tail_x15_r0_body.cpend155, PRE_first_tail_x15_r0_body.cerrh155, PRE_first_tail_x15_r0_body.cfiles155, PRE_first_tail_x15_r0_body.carch155, PRE_first_tail_x15_r0_body.csizes155, PRE_first_tail_x15_r0_body.cwired155, PRE_first_tail_x15_r0_body.cfix155, clean, PRE_first_tail_x15_r0_body.fcxn155, PRE_first_tail_x15_r0_body.fcnn155, hltC, nltC, itemsC, tracedC, cl, PRE_first_tail_x15_r0_body.fle0155, PRE_first_tail_x15_r0_body.fnk155, PRE_first_tail_x15_r0_body.ckA155, PRE_first_tail_x15_r0_body.cobjsK155, PRE_first_tail_x15_r0_body.cnodesK155, PRE_first_tail_x15_r0_body.citemsK155, PRE_first_tail_x15_r0_body.f1A155, PRE_first_tail_x15_r0_body.f1O155, PRE_first_tail_x15_r0_body.f1N155, PRE_first_tail_x15_r0_body.f1I155, PRE_first_tail_x15_r0_body.fbd155, PRE_first_tail_x15_r0_body.fincW155, PRE_first_tail_x15_r0_body.fincI155, PRE_first_tail_x15_r0_body.fincN155, PRE_first_tail_x15_r0_body.flnF155, PRE_first_tail_x15_r0_body.fh155, PRE_first_tail_x15_r0_body.fo155, PRE_first_tail_x15_r0_body.fok155, PRE_first_tail_x15_r0_body.fnd155, PRE_first_tail_x15_r0_body.fp155, PRE_first_tail_x15_r0_body.fnord155, PRE_first_tail_x15_r0_body.fi155, PRE_first_tail_x15_r0_body.fii155⟩
theorem PRE_first_tail_x15_r0_body.cnshift155 (clean : Conv.NClean (⟨21249, 18340, 2796385, 6679⟩ : Conv.Cnt) (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1494.ffi).mlx) (hltC : ∀ h, PH (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1494.ffi).mlx h → h < (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1494.ffi).mlx.next) (nltC : ∀ i, PN (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1494.ffi).mlx i → i < (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1494.ffi).mlx.nnext) (itemsC : ∀ k v, (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1494.ffi).mlx.items.get k = some v → PN (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1494.ffi).mlx k) (tracedC : ∀ h o, (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1494.ffi).mlx.objs.get h = some o → ∀ i ∈ objTraces o, i < PRE_first_tail_x15_r0_body.P155.NL) (cl : SSt (· < 6679) PRE_first_tail_x15_r0_body.cx0_155.mlx) : NShift PRE_first_tail_x15_r0_body.P155 6679 PRE_first_tail_x15_r0_body.kappa155 PRE_first_tail_x15_r0_body.cx0_155 PRE_first_tail_x15_r0_body.cx1_155 :=
  Conv.nshift_of_foot (PRE_first_tail_x15_r0_body.cfoot155 clean hltC nltC itemsC tracedC cl) PRE_first_tail_x15_r0_body.chost155 (compact_a_eq PRE_first_tail_x15_r0_body.ckn0155 PRE_first_tail_x15_r0_body.ckn1155 PRE_first_tail_x15_r0_body.ckheap155 PRE_first_tail_x15_r0_body.ckpl155)

-- the observers: the layers' states at the call, the canonical and the merged state, their footprints and checks
noncomputable def PRE_first_tail_x15_r0_body.fxC_155 : PTrie Unit := (Host.Ts.Sim.Full.freedOf PRE_first_tail_x15_r0_body.s1494.ffi).getD PTrie.nil
noncomputable def PRE_first_tail_x15_r0_body.krC_155 : Host.Load.Layers.KRec := (Host.Ts.Sim.Full.krecOf PRE_first_tail_x15_r0_body.s1494.ffi).getD Host.Load.Layers.KRec.empty
kernel_rfl PRE_first_tail_x15_r0_body.ofxC_155 : (Host.Ts.Sim.Full.freedOf PRE_first_tail_x15_r0_body.s1494.ffi) = some PRE_first_tail_x15_r0_body.fxC_155
kernel_rfl PRE_first_tail_x15_r0_body.okrC_155 : (Host.Ts.Sim.Full.krecOf PRE_first_tail_x15_r0_body.s1494.ffi) = some PRE_first_tail_x15_r0_body.krC_155
noncomputable def PRE_first_tail_x15_r0_body.fx0_155 : PTrie Unit := (Host.Ts.Sim.Full.freedOf PRE_first_tail_x15_r0_body.s1496.ffi).getD PTrie.nil
noncomputable def PRE_first_tail_x15_r0_body.kr0_155 : Host.Load.Layers.KRec := (Host.Ts.Sim.Full.krecOf PRE_first_tail_x15_r0_body.s1496.ffi).getD Host.Load.Layers.KRec.empty
kernel_rfl PRE_first_tail_x15_r0_body.ofx0_155 : (Host.Ts.Sim.Full.freedOf PRE_first_tail_x15_r0_body.s1496.ffi) = some PRE_first_tail_x15_r0_body.fx0_155
kernel_rfl PRE_first_tail_x15_r0_body.okr0_155 : (Host.Ts.Sim.Full.krecOf PRE_first_tail_x15_r0_body.s1496.ffi) = some PRE_first_tail_x15_r0_body.kr0_155
noncomputable def PRE_first_tail_x15_r0_body.fx1_155 : PTrie Unit := (Host.Ts.Sim.Full.freedOf PRE_first_tail_x15_r0_body.s1495.ffi).getD PTrie.nil
noncomputable def PRE_first_tail_x15_r0_body.kr1_155 : Host.Load.Layers.KRec := (Host.Ts.Sim.Full.krecOf PRE_first_tail_x15_r0_body.s1495.ffi).getD Host.Load.Layers.KRec.empty
kernel_rfl PRE_first_tail_x15_r0_body.ofx1_155 : (Host.Ts.Sim.Full.freedOf PRE_first_tail_x15_r0_body.s1495.ffi) = some PRE_first_tail_x15_r0_body.fx1_155
kernel_rfl PRE_first_tail_x15_r0_body.okr1_155 : (Host.Ts.Sim.Full.krecOf PRE_first_tail_x15_r0_body.s1495.ffi) = some PRE_first_tail_x15_r0_body.kr1_155
kernel_rfl PRE_first_tail_x15_r0_body.ff0155 : PRE_first_tail_x15_r0_body.fx0_155 = Stage.setAll PRE_first_tail_x15_r0_body.fxC_155 (PRE_first_tail_x15_r0_body.clo155.filterMap fun i => (PRE_first_tail_x15_r0_body.fx0_155.get i).map (i, ·))
kernel_rfl PRE_first_tail_x15_r0_body.ff1155 : PRE_first_tail_x15_r0_body.fx1_155 = Stage.setAll PRE_first_tail_x15_r0_body.fxC_155 (PRE_first_tail_x15_r0_body.cwS155.filterMap fun i => (PRE_first_tail_x15_r0_body.fx1_155.get i).map (i, ·))
kernel_rfl PRE_first_tail_x15_r0_body.ffck155 : freedLB PRE_first_tail_x15_r0_body.kappa155 PRE_first_tail_x15_r0_body.cx0_155.mlx PRE_first_tail_x15_r0_body.fx0_155 PRE_first_tail_x15_r0_body.fx1_155 PRE_first_tail_x15_r0_body.clo155 = true
kernel_rfl PRE_first_tail_x15_r0_body.fkf0155 : PRE_first_tail_x15_r0_body.kr0_155.flags = Stage.setAll PRE_first_tail_x15_r0_body.krC_155.flags (PRE_first_tail_x15_r0_body.clo155.filterMap fun i => (PRE_first_tail_x15_r0_body.kr0_155.flags.get i).map (i, ·))
kernel_rfl PRE_first_tail_x15_r0_body.fkt0155 : PRE_first_tail_x15_r0_body.kr0_155.targs = Stage.setAll PRE_first_tail_x15_r0_body.krC_155.targs (PRE_first_tail_x15_r0_body.clo155.filterMap fun i => (PRE_first_tail_x15_r0_body.kr0_155.targs.get i).map (i, ·))
kernel_rfl PRE_first_tail_x15_r0_body.fkf1155 : PRE_first_tail_x15_r0_body.kr1_155.flags = Stage.setAll PRE_first_tail_x15_r0_body.krC_155.flags (PRE_first_tail_x15_r0_body.cwS155.filterMap fun i => (PRE_first_tail_x15_r0_body.kr1_155.flags.get i).map (i, ·))
kernel_rfl PRE_first_tail_x15_r0_body.fkt1155 : PRE_first_tail_x15_r0_body.kr1_155.targs = Stage.setAll PRE_first_tail_x15_r0_body.krC_155.targs (PRE_first_tail_x15_r0_body.cwS155.filterMap fun i => (PRE_first_tail_x15_r0_body.kr1_155.targs.get i).map (i, ·))
kernel_rfl PRE_first_tail_x15_r0_body.fkck155 : krecLB PRE_first_tail_x15_r0_body.kappa155 6679 PRE_first_tail_x15_r0_body.cx0_155.mlx PRE_first_tail_x15_r0_body.kr0_155 PRE_first_tail_x15_r0_body.kr1_155 PRE_first_tail_x15_r0_body.clo155 = true
kernel_rfl PRE_first_tail_x15_r0_body.fkn155 : Nat.ble 6679 6679 = true
-- the bridge and the pending traces' regions
kernel_rfl PRE_first_tail_x15_r0_body.cbridge155 : Host.Ts.Sim.Full.bridgeOf PRE_first_tail_x15_r0_body.s1495.ffi = Host.Ts.Sim.Full.bridgeOf PRE_first_tail_x15_r0_body.s1496.ffi
kernel_rfl PRE_first_tail_x15_r0_body.cpendR155 : pendRegB PRE_first_tail_x15_r0_body.kappa155 (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1496.ffi).mlx = true
kernel_rfl PRE_first_tail_x15_r0_body.cpendLe155 : Nat.ble (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1496.ffi).mlx.next (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1495.ffi).mlx.next = true
/-- **The compaction's native shift**, given the call's bookkeeping, its relation's facts (the model's and the
observers') and the canonical closedness. -/
theorem PRE_first_tail_x15_r0_body.cshift155 (clean : Conv.NClean (⟨21249, 18340, 2796385, 6679⟩ : Conv.Cnt) (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1494.ffi).mlx) (hltC : ∀ h, PH (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1494.ffi).mlx h → h < (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1494.ffi).mlx.next) (nltC : ∀ i, PN (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1494.ffi).mlx i → i < (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1494.ffi).mlx.nnext) (itemsC : ∀ k v, (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1494.ffi).mlx.items.get k = some v → PN (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1494.ffi).mlx k) (tracedC : ∀ h o, (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1494.ffi).mlx.objs.get h = some o → ∀ i ∈ objTraces o, i < PRE_first_tail_x15_r0_body.P155.NL) (cl : SSt (· < 6679) PRE_first_tail_x15_r0_body.cx0_155.mlx)
    (hobjC : ∀ h, PRE_first_tail_x15_r0_body.fxC_155.get h = some () → ((Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1494.ffi).mlx.objs.get h).isSome = true)
    (hfC : ∀ h, (PRE_first_tail_x15_r0_body.krC_155.flags.get h).isSome = true → ((Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1494.ffi).mlx.objs.get h).isSome = true)
    (htC : ∀ h, (PRE_first_tail_x15_r0_body.krC_155.targs.get h).isSome = true → ((Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1494.ffi).mlx.objs.get h).isSome = true)
    (hclC : ∀ h l, PRE_first_tail_x15_r0_body.krC_155.targs.get h = some l → Host.Ts.Sim.Full.STargs (· < (⟨21249, 18340, 2796385, 6679⟩ : Conv.Cnt).n) l) :
    Conv.FullShiftQ PRE_first_tail_x15_r0_body.P155 6679 PRE_first_tail_x15_r0_body.kappa155 PRE_first_tail_x15_r0_body.s1496.ffi PRE_first_tail_x15_r0_body.s1495.ffi :=
  ⟨PRE_first_tail_x15_r0_body.cnshift155 clean hltC nltC itemsC tracedC cl, PRE_first_tail_x15_r0_body.cqueue155, fun t ht => bSN_sound (List.all_eq_true.mp PRE_first_tail_x15_r0_body.ctokSupp155 t ht),
    PRE_first_tail_x15_r0_body.cbridge155,
    liveShift_foot (x0' := Host.Ts.Sim.Full.mlxOf PRE_first_tail_x15_r0_body.s1496.ffi) (x1' := Host.Ts.Sim.Full.mlxOf PRE_first_tail_x15_r0_body.s1495.ffi) (PRE_first_tail_x15_r0_body.cfoot155 clean hltC nltC itemsC tracedC cl) rfl PRE_first_tail_x15_r0_body.ofx0_155 PRE_first_tail_x15_r0_body.ofx1_155 hobjC PRE_first_tail_x15_r0_body.ff0155 PRE_first_tail_x15_r0_body.ff1155 PRE_first_tail_x15_r0_body.ffck155,
    kernShift_foot (x0' := Host.Ts.Sim.Full.mlxOf PRE_first_tail_x15_r0_body.s1496.ffi) (x1' := Host.Ts.Sim.Full.mlxOf PRE_first_tail_x15_r0_body.s1495.ffi) (PRE_first_tail_x15_r0_body.cfoot155 clean hltC nltC itemsC tracedC cl) rfl PRE_first_tail_x15_r0_body.okr0_155 PRE_first_tail_x15_r0_body.okr1_155 (Nat.le_of_ble_eq_true PRE_first_tail_x15_r0_body.fkn155) hfC htC hclC
      PRE_first_tail_x15_r0_body.fkf0155 PRE_first_tail_x15_r0_body.fkt0155 PRE_first_tail_x15_r0_body.fkf1155 PRE_first_tail_x15_r0_body.fkt1155 PRE_first_tail_x15_r0_body.fkck155,
    pendReg_of rfl PRE_first_tail_x15_r0_body.cnh0155 PRE_first_tail_x15_r0_body.cnh1155 (Nat.le_of_ble_eq_true PRE_first_tail_x15_r0_body.cpendLe155) PRE_first_tail_x15_r0_body.cpendR155⟩

end Host.Load.Run.Tpl
