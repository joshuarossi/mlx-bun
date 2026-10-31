import host.sim.template.a4pre_first_tail_x15_r0_body.SiteCl74
import host.sim.conv.CompactFull
import host.sim.template.FootGen
set_option Elab.async false
namespace Host.Load.Run.Tpl
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
open Host.Ts Host.Ts.Sim Host.Ts.Sim.Template

/-! The compaction's native shift at call site 74 from its footprint (`Conv.nshift_of_foot`), and the observers'
(`liveShift_foot`, `kernShift_foot`): `Conv.FullShiftQ` for `Conv.full_compactQ`, given the call's bookkeeping and its
relation's facts. -/

/-- The load parameters of the chain (band-free: its start's node counter as `NL` and `N0`). -/
def PRE_first_tail_x15_r0_body.Pc74 : LoadP := ⟨18151, 131072, 1099511627776, 15235, 15235, []⟩
/-- The site's band raised to the map's checked fixed-node prefix, including newly recorded closure traces. -/
def PRE_first_tail_x15_r0_body.P74 : LoadP := PRE_first_tail_x15_r0_body.Pc74.raise 16744
kernel_rfl PRE_first_tail_x15_r0_body.craise74 : Nat.ble PRE_first_tail_x15_r0_body.Pc74.N0 16744 = true
theorem PRE_first_tail_x15_r0_body.raised74 : Host.Ts.Sim.Full.Raised PRE_first_tail_x15_r0_body.Pc74 PRE_first_tail_x15_r0_body.P74 :=
  .inr ⟨16744, rfl, Nat.le_of_ble_eq_true PRE_first_tail_x15_r0_body.craise74, rfl⟩
noncomputable abbrev PRE_first_tail_x15_r0_body.cx0_74 : Host.Load.LSt := clearTokens (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s657.ffi)
noncomputable abbrev PRE_first_tail_x15_r0_body.cx1_74 : Host.Load.LSt := clearTokens (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s656.ffi)
def PRE_first_tail_x15_r0_body.khinv74 : PTrie Nat := Stage.setAll PTrie.nil []
def PRE_first_tail_x15_r0_body.kninv74 : PTrie Nat := Stage.setAll PTrie.nil []
/-- The stage's footprint: its written and fresh handles, fresh nodes, written and fresh items. -/
def PRE_first_tail_x15_r0_body.cwS74 : List Nat := []
def PRE_first_tail_x15_r0_body.cnS74 : List Nat := List.range' 16744 0
def PRE_first_tail_x15_r0_body.ciS74 : List Nat := [] ++ List.range' 16744 0

-- the small checks (`MChecks`'s)
kernel_rfl PRE_first_tail_x15_r0_body.cnh074 : PRE_first_tail_x15_r0_body.kd74.nh0 = PRE_first_tail_x15_r0_body.cx0_74.mlx.next
kernel_rfl PRE_first_tail_x15_r0_body.cnh174 : PRE_first_tail_x15_r0_body.kd74.nh1 = PRE_first_tail_x15_r0_body.cx1_74.mlx.next
kernel_rfl PRE_first_tail_x15_r0_body.cnn074 : PRE_first_tail_x15_r0_body.kd74.nn0 = PRE_first_tail_x15_r0_body.cx0_74.mlx.nnext
kernel_rfl PRE_first_tail_x15_r0_body.cnn174 : PRE_first_tail_x15_r0_body.kd74.nn1 = PRE_first_tail_x15_r0_body.cx1_74.mlx.nnext
kernel_rfl PRE_first_tail_x15_r0_body.cplo74 : (Nat.blt 0 PRE_first_tail_x15_r0_body.P74.lo && Nat.ble PRE_first_tail_x15_r0_body.P74.lo PRE_first_tail_x15_r0_body.cx0_74.mlx.next && Nat.ble PRE_first_tail_x15_r0_body.P74.lo RData.bigHi && Nat.ble RData.bigHi PRE_first_tail_x15_r0_body.P74.E) = true
kernel_rfl PRE_first_tail_x15_r0_body.ccnt74 : (Nat.ble PRE_first_tail_x15_r0_body.cx0_74.mlx.next PRE_first_tail_x15_r0_body.cx1_74.mlx.next && Nat.ble PRE_first_tail_x15_r0_body.cx0_74.mlx.nnext PRE_first_tail_x15_r0_body.cx1_74.mlx.nnext) = true
kernel_rfl PRE_first_tail_x15_r0_body.cnband74 : (Nat.blt 0 PRE_first_tail_x15_r0_body.P74.NL && Nat.ble PRE_first_tail_x15_r0_body.P74.NL PRE_first_tail_x15_r0_body.P74.N0 && Nat.ble PRE_first_tail_x15_r0_body.P74.N0 PRE_first_tail_x15_r0_body.cx0_74.mlx.nnext) = true
kernel_rfl PRE_first_tail_x15_r0_body.chbelow74 : PRE_first_tail_x15_r0_body.kd74.checkHndBelow = true
kernel_rfl PRE_first_tail_x15_r0_body.chren74 : checkRenG PRE_first_tail_x15_r0_body.kd74.hnd PRE_first_tail_x15_r0_body.khinv74 (phB PRE_first_tail_x15_r0_body.cx0_74.mlx) = true
kernel_rfl PRE_first_tail_x15_r0_body.cband74 : PRE_first_tail_x15_r0_body.kd74.checkBand PRE_first_tail_x15_r0_body.P74.lo = true
kernel_rfl PRE_first_tail_x15_r0_body.cnh1pos74 : Nat.blt 0 PRE_first_tail_x15_r0_body.kd74.nh1 = true
kernel_rfl PRE_first_tail_x15_r0_body.cnren74 : checkRenG PRE_first_tail_x15_r0_body.kd74.node PRE_first_tail_x15_r0_body.kninv74 (pnB PRE_first_tail_x15_r0_body.cx0_74.mlx) = true
kernel_rfl PRE_first_tail_x15_r0_body.cnlow74 : (PTrie.keysA PRE_first_tail_x15_r0_body.kd74.node).all (fun j => Nat.ble PRE_first_tail_x15_r0_body.P74.NL j && Nat.blt (PRE_first_tail_x15_r0_body.kd74.nodeF j) PRE_first_tail_x15_r0_body.cx1_74.mlx.nnext) = true
kernel_rfl PRE_first_tail_x15_r0_body.cabs0a74 : PRE_first_tail_x15_r0_body.cx0_74.mlx.arrs.get 0 = none
kernel_rfl PRE_first_tail_x15_r0_body.cabs0b74 : PRE_first_tail_x15_r0_body.cx0_74.mlx.objs.get 0 = none
kernel_rfl PRE_first_tail_x15_r0_body.ctok174 : PRE_first_tail_x15_r0_body.cx1_74.mlx.tokens = []
kernel_rfl PRE_first_tail_x15_r0_body.cpend74 : PRE_first_tail_x15_r0_body.cx1_74.mlx.pending = PRE_first_tail_x15_r0_body.cx0_74.mlx.pending.map PRE_first_tail_x15_r0_body.kappa74.pend
kernel_rfl PRE_first_tail_x15_r0_body.cerrh74 : PRE_first_tail_x15_r0_body.cx1_74.mlx.errh = PRE_first_tail_x15_r0_body.cx0_74.mlx.errh.map PRE_first_tail_x15_r0_body.kappa74.arg
kernel_rfl PRE_first_tail_x15_r0_body.cfiles74 : PRE_first_tail_x15_r0_body.cx1_74.mlx.files = PRE_first_tail_x15_r0_body.cx0_74.mlx.files
kernel_rfl PRE_first_tail_x15_r0_body.carch74 : PRE_first_tail_x15_r0_body.cx1_74.mlx.arch = PRE_first_tail_x15_r0_body.cx0_74.mlx.arch
kernel_rfl PRE_first_tail_x15_r0_body.csizes74 : PRE_first_tail_x15_r0_body.cx1_74.mlx.deviceSizes = PRE_first_tail_x15_r0_body.cx0_74.mlx.deviceSizes
kernel_rfl PRE_first_tail_x15_r0_body.cwired74 : PRE_first_tail_x15_r0_body.cx1_74.mlx.wired = PRE_first_tail_x15_r0_body.cx0_74.mlx.wired
kernel_rfl PRE_first_tail_x15_r0_body.chost74 : PRE_first_tail_x15_r0_body.cx1_74.host = PRE_first_tail_x15_r0_body.cx0_74.host
-- the compaction map's addresses are `PRE_first_tail_x15_r0_body.kd74`'s
kernel_rfl PRE_first_tail_x15_r0_body.ckn074 : PRE_first_tail_x15_r0_body.kd74.n0 = 2732744
kernel_rfl PRE_first_tail_x15_r0_body.ckn174 : PRE_first_tail_x15_r0_body.kd74.n1 = 2732754
kernel_rfl PRE_first_tail_x15_r0_body.ckheap74 : (PTrie.keysA PRE_first_tail_x15_r0_body.kd74.heap).all (fun x => Nat.ble 2732743 x) = true
kernel_rfl PRE_first_tail_x15_r0_body.ckpl74 : (List.range 1).all (fun j => decide (PRE_first_tail_x15_r0_body.kd74.heap.get (2732743 + j) = nth? PRE_first_tail_x15_r0_body.pl74 j)) = true
-- the map fixes the call's names (`Conv.fixOld_compact`), the call's counters
kernel_rfl PRE_first_tail_x15_r0_body.fja74 : Nat.ble 2732743 2732743 = true
kernel_rfl PRE_first_tail_x15_r0_body.fn74 : Nat.ble 3217 3217 = true
kernel_rfl PRE_first_tail_x15_r0_body.fjaD74 : Nat.ble 2732743 PRE_first_tail_x15_r0_body.kd74.n0 = true
kernel_rfl PRE_first_tail_x15_r0_body.fxn74 : Nat.ble 19655 PRE_first_tail_x15_r0_body.kd74.nh0 = true
kernel_rfl PRE_first_tail_x15_r0_body.fnn74 : Nat.ble 16744 PRE_first_tail_x15_r0_body.kd74.nn0 = true
kernel_rfl PRE_first_tail_x15_r0_body.fxb74 : Nat.ble 19655 RData.bigHi = true
kernel_rfl PRE_first_tail_x15_r0_body.fheap74 : (PTrie.keysA PRE_first_tail_x15_r0_body.kd74.heap).all (Nat.ble (⟨19655, 16744, 2732743, 3217⟩ : Conv.Cnt).ja) = true
kernel_rfl PRE_first_tail_x15_r0_body.fhnd74 : (PTrie.keysA PRE_first_tail_x15_r0_body.kd74.hnd).all (Nat.ble (⟨19655, 16744, 2732743, 3217⟩ : Conv.Cnt).xn) = true
kernel_rfl PRE_first_tail_x15_r0_body.fnode74 : (PTrie.keysA PRE_first_tail_x15_r0_body.kd74.node).all (Nat.ble (⟨19655, 16744, 2732743, 3217⟩ : Conv.Cnt).nn) = true
/-- The compaction map fixes the call's names. -/
theorem PRE_first_tail_x15_r0_body.cfix74 : Conv.FixOld (⟨19655, 16744, 2732743, 3217⟩ : Conv.Cnt) PRE_first_tail_x15_r0_body.kappa74 :=
  Conv.fixOld_compact (Nat.le_of_ble_eq_true PRE_first_tail_x15_r0_body.fja74) (Nat.le_of_ble_eq_true PRE_first_tail_x15_r0_body.fn74) (Nat.le_of_ble_eq_true PRE_first_tail_x15_r0_body.fjaD74) (Nat.le_of_ble_eq_true PRE_first_tail_x15_r0_body.fxn74) (Nat.le_of_ble_eq_true PRE_first_tail_x15_r0_body.fnn74) (Nat.le_of_ble_eq_true PRE_first_tail_x15_r0_body.fxb74) PRE_first_tail_x15_r0_body.fheap74 PRE_first_tail_x15_r0_body.fhnd74 PRE_first_tail_x15_r0_body.fnode74
kernel_rfl PRE_first_tail_x15_r0_body.fcxn74 : (⟨19655, 16744, 2732743, 3217⟩ : Conv.Cnt).xn = (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s655.ffi).mlx.next
kernel_rfl PRE_first_tail_x15_r0_body.fcnn74 : (⟨19655, 16744, 2732743, 3217⟩ : Conv.Cnt).nn = (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s655.ffi).mlx.nnext
kernel_rfl PRE_first_tail_x15_r0_body.fle074 : (Nat.ble (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s655.ffi).mlx.next PRE_first_tail_x15_r0_body.cx0_74.mlx.next && Nat.ble (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s655.ffi).mlx.nnext PRE_first_tail_x15_r0_body.cx0_74.mlx.nnext && Nat.ble (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s655.ffi).mlx.next RData.bigHi) = true
kernel_rfl PRE_first_tail_x15_r0_body.fnk74 : (PTrie.keysA PRE_first_tail_x15_r0_body.kd74.node).all (Nat.ble (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s655.ffi).mlx.nnext) = true
-- the merged state keeps the call's entries off the stage's footprint
kernel_rfl PRE_first_tail_x15_r0_body.f1A74 : PRE_first_tail_x15_r0_body.cx1_74.mlx.arrs = Stage.setAll (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s655.ffi).mlx.arrs (PRE_first_tail_x15_r0_body.cwS74.filterMap fun i => (PRE_first_tail_x15_r0_body.cx1_74.mlx.arrs.get i).map (i, ·))
kernel_rfl PRE_first_tail_x15_r0_body.f1O74 : PRE_first_tail_x15_r0_body.cx1_74.mlx.objs = Stage.setAll (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s655.ffi).mlx.objs (PRE_first_tail_x15_r0_body.cwS74.filterMap fun i => (PRE_first_tail_x15_r0_body.cx1_74.mlx.objs.get i).map (i, ·))
kernel_rfl PRE_first_tail_x15_r0_body.f1N74 : PRE_first_tail_x15_r0_body.cx1_74.mlx.nodes = Stage.setAll (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s655.ffi).mlx.nodes (PRE_first_tail_x15_r0_body.cnS74.filterMap fun i => (PRE_first_tail_x15_r0_body.cx1_74.mlx.nodes.get i).map (i, ·))
kernel_rfl PRE_first_tail_x15_r0_body.f1I74 : PRE_first_tail_x15_r0_body.cx1_74.mlx.items = Stage.setAll (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s655.ffi).mlx.items (PRE_first_tail_x15_r0_body.ciS74.filterMap fun i => (PRE_first_tail_x15_r0_body.cx1_74.mlx.items.get i).map (i, ·))
kernel_rfl PRE_first_tail_x15_r0_body.fbd74 : (PRE_first_tail_x15_r0_body.clo74 ++ PRE_first_tail_x15_r0_body.cln74 ++ PRE_first_tail_x15_r0_body.cli74 ++ PRE_first_tail_x15_r0_body.cwS74 ++ PRE_first_tail_x15_r0_body.cnS74 ++ PRE_first_tail_x15_r0_body.ciS74).all (fun i => Nat.blt (i / 4096) (4 ^ 31)) = true
kernel_rfl PRE_first_tail_x15_r0_body.fincW74 : PRE_first_tail_x15_r0_body.cwS74.all (fun h => !Nat.blt h (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s655.ffi).mlx.next || PRE_first_tail_x15_r0_body.clo74.contains h) = true
kernel_rfl PRE_first_tail_x15_r0_body.fincI74 : PRE_first_tail_x15_r0_body.ciS74.all (fun k => !Nat.blt k (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s655.ffi).mlx.nnext || PRE_first_tail_x15_r0_body.cli74.contains k) = true
kernel_rfl PRE_first_tail_x15_r0_body.fincN74 : PRE_first_tail_x15_r0_body.cnS74.all (Nat.ble (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s655.ffi).mlx.nnext) = true
kernel_rfl PRE_first_tail_x15_r0_body.flnF74 : PRE_first_tail_x15_r0_body.cln74.all (Nat.ble (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s655.ffi).mlx.nnext) = true
-- the checks over the changed lists
kernel_rfl PRE_first_tail_x15_r0_body.fh74 : PRE_first_tail_x15_r0_body.clo74.all (handleOK PRE_first_tail_x15_r0_body.kappa74 PRE_first_tail_x15_r0_body.P74.lo PRE_first_tail_x15_r0_body.cx0_74.mlx PRE_first_tail_x15_r0_body.cx1_74.mlx) = true
kernel_rfl PRE_first_tail_x15_r0_body.fo74 : PRE_first_tail_x15_r0_body.clo74.map (fun h => PRE_first_tail_x15_r0_body.cx1_74.mlx.objs.get (PRE_first_tail_x15_r0_body.kappa74.handle h)) = PRE_first_tail_x15_r0_body.clo74.map (fun h => (PRE_first_tail_x15_r0_body.cx0_74.mlx.objs.get h).map PRE_first_tail_x15_r0_body.kappa74.nobj)
kernel_rfl PRE_first_tail_x15_r0_body.fok74 : PRE_first_tail_x15_r0_body.clo74.all (objOK PRE_first_tail_x15_r0_body.kappa74 PRE_first_tail_x15_r0_body.P74.NL PRE_first_tail_x15_r0_body.cx0_74.mlx) = true
kernel_rfl PRE_first_tail_x15_r0_body.fnd74 : PRE_first_tail_x15_r0_body.cln74.all (nodeOKF PRE_first_tail_x15_r0_body.kappa74 PRE_first_tail_x15_r0_body.P74 PRE_first_tail_x15_r0_body.cx0_74.mlx PRE_first_tail_x15_r0_body.cx1_74.mlx) = true
kernel_rfl PRE_first_tail_x15_r0_body.fp74 : ((PRE_first_tail_x15_r0_body.cln74.filter (fullB PRE_first_tail_x15_r0_body.P74))).map (fun i => (PRE_first_tail_x15_r0_body.cx1_74.mlx.nodes.get (PRE_first_tail_x15_r0_body.kappa74.node i)).map Host.Mlx.Ffi.Node.prim) =
  ((PRE_first_tail_x15_r0_body.cln74.filter (fullB PRE_first_tail_x15_r0_body.P74))).map (fun i => (PRE_first_tail_x15_r0_body.cx0_74.mlx.nodes.get i).map fun nd => PRE_first_tail_x15_r0_body.kappa74.prim nd.prim)
kernel_rfl PRE_first_tail_x15_r0_body.fnordI74 : incrB PRE_first_tail_x15_r0_body.kd74.nodeF (List.range' 16744 0) = true
kernel_rfl PRE_first_tail_x15_r0_body.fnordK74 : (PTrie.keysA PRE_first_tail_x15_r0_body.kd74.node).all (fun k => Nat.ble 16744 k && Nat.blt k 16744) = true
kernel_rfl PRE_first_tail_x15_r0_body.fnordL74 : (PRE_first_tail_x15_r0_body.cln74.filter (Nat.ble PRE_first_tail_x15_r0_body.P74.N0)).all (fun i => Nat.ble i (PRE_first_tail_x15_r0_body.kd74.nodeF i) && (Nat.blt i 16744 || Nat.ble PRE_first_tail_x15_r0_body.kd74.nn0 i)) = true
theorem PRE_first_tail_x15_r0_body.fnord74 : (PRE_first_tail_x15_r0_body.cln74.filter (Nat.ble PRE_first_tail_x15_r0_body.P74.N0)).all (fun i => Nat.ble i (PRE_first_tail_x15_r0_body.kd74.nodeF i) &&
    (PTrie.keysA PRE_first_tail_x15_r0_body.kd74.node).all fun j => !Nat.blt j i || Nat.blt (PRE_first_tail_x15_r0_body.kd74.nodeF j) (PRE_first_tail_x15_r0_body.kd74.nodeF i)) = true :=
  cnord_of PRE_first_tail_x15_r0_body.cnlow74 PRE_first_tail_x15_r0_body.cnn174 PRE_first_tail_x15_r0_body.fnordI74 PRE_first_tail_x15_r0_body.fnordK74 PRE_first_tail_x15_r0_body.fnordL74
kernel_rfl PRE_first_tail_x15_r0_body.fi74 : PRE_first_tail_x15_r0_body.cli74.all (pnB PRE_first_tail_x15_r0_body.cx0_74.mlx) = true
kernel_rfl PRE_first_tail_x15_r0_body.fii74 : PRE_first_tail_x15_r0_body.cli74.all (fun k => decide (PRE_first_tail_x15_r0_body.cx1_74.mlx.items.get (PRE_first_tail_x15_r0_body.kappa74.node k) = (PRE_first_tail_x15_r0_body.cx0_74.mlx.items.get k).map PRE_first_tail_x15_r0_body.kappa74.nv)) = true
/-- **The compaction's footprint.** -/
theorem PRE_first_tail_x15_r0_body.cfoot74 (clean : Conv.NClean (⟨19655, 16744, 2732743, 3217⟩ : Conv.Cnt) (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s655.ffi).mlx) (hltC : ∀ h, PH (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s655.ffi).mlx h → h < (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s655.ffi).mlx.next) (nltC : ∀ i, PN (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s655.ffi).mlx i → i < (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s655.ffi).mlx.nnext) (itemsC : ∀ k v, (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s655.ffi).mlx.items.get k = some v → PN (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s655.ffi).mlx k) (tracedC : ∀ h o, (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s655.ffi).mlx.objs.get h = some o → ∀ i ∈ objTraces o, i < PRE_first_tail_x15_r0_body.P74.NL) (cl : SSt (· < 3217) PRE_first_tail_x15_r0_body.cx0_74.mlx) :
    Conv.MFoot PRE_first_tail_x15_r0_body.P74 3217 PRE_first_tail_x15_r0_body.kappa74 PRE_first_tail_x15_r0_body.kd74 PRE_first_tail_x15_r0_body.khinv74 PRE_first_tail_x15_r0_body.kninv74 (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s655.ffi).mlx PRE_first_tail_x15_r0_body.cx0_74.mlx PRE_first_tail_x15_r0_body.cx1_74.mlx (⟨19655, 16744, 2732743, 3217⟩ : Conv.Cnt) PRE_first_tail_x15_r0_body.clo74 PRE_first_tail_x15_r0_body.cln74 PRE_first_tail_x15_r0_body.cli74 PRE_first_tail_x15_r0_body.cwS74 PRE_first_tail_x15_r0_body.cnS74 PRE_first_tail_x15_r0_body.ciS74 :=
  ⟨rfl, rfl, rfl, PRE_first_tail_x15_r0_body.cnh074, PRE_first_tail_x15_r0_body.cnh174, PRE_first_tail_x15_r0_body.cnn074, PRE_first_tail_x15_r0_body.cnn174, PRE_first_tail_x15_r0_body.cplo74, PRE_first_tail_x15_r0_body.ccnt74, PRE_first_tail_x15_r0_body.cnband74, PRE_first_tail_x15_r0_body.chbelow74, PRE_first_tail_x15_r0_body.chren74, PRE_first_tail_x15_r0_body.cband74, PRE_first_tail_x15_r0_body.cnh1pos74, PRE_first_tail_x15_r0_body.cnren74, PRE_first_tail_x15_r0_body.cnlow74, PRE_first_tail_x15_r0_body.cabs0a74, PRE_first_tail_x15_r0_body.cabs0b74, PRE_first_tail_x15_r0_body.ctok174, PRE_first_tail_x15_r0_body.cpend74, PRE_first_tail_x15_r0_body.cerrh74, PRE_first_tail_x15_r0_body.cfiles74, PRE_first_tail_x15_r0_body.carch74, PRE_first_tail_x15_r0_body.csizes74, PRE_first_tail_x15_r0_body.cwired74, PRE_first_tail_x15_r0_body.cfix74, clean, PRE_first_tail_x15_r0_body.fcxn74, PRE_first_tail_x15_r0_body.fcnn74, hltC, nltC, itemsC, tracedC, cl, PRE_first_tail_x15_r0_body.fle074, PRE_first_tail_x15_r0_body.fnk74, PRE_first_tail_x15_r0_body.ckA74, PRE_first_tail_x15_r0_body.cobjsK74, PRE_first_tail_x15_r0_body.cnodesK74, PRE_first_tail_x15_r0_body.citemsK74, PRE_first_tail_x15_r0_body.f1A74, PRE_first_tail_x15_r0_body.f1O74, PRE_first_tail_x15_r0_body.f1N74, PRE_first_tail_x15_r0_body.f1I74, PRE_first_tail_x15_r0_body.fbd74, PRE_first_tail_x15_r0_body.fincW74, PRE_first_tail_x15_r0_body.fincI74, PRE_first_tail_x15_r0_body.fincN74, PRE_first_tail_x15_r0_body.flnF74, PRE_first_tail_x15_r0_body.fh74, PRE_first_tail_x15_r0_body.fo74, PRE_first_tail_x15_r0_body.fok74, PRE_first_tail_x15_r0_body.fnd74, PRE_first_tail_x15_r0_body.fp74, PRE_first_tail_x15_r0_body.fnord74, PRE_first_tail_x15_r0_body.fi74, PRE_first_tail_x15_r0_body.fii74⟩
theorem PRE_first_tail_x15_r0_body.cnshift74 (clean : Conv.NClean (⟨19655, 16744, 2732743, 3217⟩ : Conv.Cnt) (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s655.ffi).mlx) (hltC : ∀ h, PH (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s655.ffi).mlx h → h < (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s655.ffi).mlx.next) (nltC : ∀ i, PN (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s655.ffi).mlx i → i < (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s655.ffi).mlx.nnext) (itemsC : ∀ k v, (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s655.ffi).mlx.items.get k = some v → PN (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s655.ffi).mlx k) (tracedC : ∀ h o, (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s655.ffi).mlx.objs.get h = some o → ∀ i ∈ objTraces o, i < PRE_first_tail_x15_r0_body.P74.NL) (cl : SSt (· < 3217) PRE_first_tail_x15_r0_body.cx0_74.mlx) : NShift PRE_first_tail_x15_r0_body.P74 3217 PRE_first_tail_x15_r0_body.kappa74 PRE_first_tail_x15_r0_body.cx0_74 PRE_first_tail_x15_r0_body.cx1_74 :=
  Conv.nshift_of_foot (PRE_first_tail_x15_r0_body.cfoot74 clean hltC nltC itemsC tracedC cl) PRE_first_tail_x15_r0_body.chost74 (compact_a_eq PRE_first_tail_x15_r0_body.ckn074 PRE_first_tail_x15_r0_body.ckn174 PRE_first_tail_x15_r0_body.ckheap74 PRE_first_tail_x15_r0_body.ckpl74)

-- the observers: the layers' states at the call, the canonical and the merged state, their footprints and checks
noncomputable def PRE_first_tail_x15_r0_body.fxC_74 : PTrie Unit := (Host.Ts.Sim.Full.freedOf PRE_first_tail_x15_r0_body.s655.ffi).getD PTrie.nil
noncomputable def PRE_first_tail_x15_r0_body.krC_74 : Host.Load.Layers.KRec := (Host.Ts.Sim.Full.krecOf PRE_first_tail_x15_r0_body.s655.ffi).getD Host.Load.Layers.KRec.empty
kernel_rfl PRE_first_tail_x15_r0_body.ofxC_74 : (Host.Ts.Sim.Full.freedOf PRE_first_tail_x15_r0_body.s655.ffi) = some PRE_first_tail_x15_r0_body.fxC_74
kernel_rfl PRE_first_tail_x15_r0_body.okrC_74 : (Host.Ts.Sim.Full.krecOf PRE_first_tail_x15_r0_body.s655.ffi) = some PRE_first_tail_x15_r0_body.krC_74
noncomputable def PRE_first_tail_x15_r0_body.fx0_74 : PTrie Unit := (Host.Ts.Sim.Full.freedOf PRE_first_tail_x15_r0_body.s657.ffi).getD PTrie.nil
noncomputable def PRE_first_tail_x15_r0_body.kr0_74 : Host.Load.Layers.KRec := (Host.Ts.Sim.Full.krecOf PRE_first_tail_x15_r0_body.s657.ffi).getD Host.Load.Layers.KRec.empty
kernel_rfl PRE_first_tail_x15_r0_body.ofx0_74 : (Host.Ts.Sim.Full.freedOf PRE_first_tail_x15_r0_body.s657.ffi) = some PRE_first_tail_x15_r0_body.fx0_74
kernel_rfl PRE_first_tail_x15_r0_body.okr0_74 : (Host.Ts.Sim.Full.krecOf PRE_first_tail_x15_r0_body.s657.ffi) = some PRE_first_tail_x15_r0_body.kr0_74
noncomputable def PRE_first_tail_x15_r0_body.fx1_74 : PTrie Unit := (Host.Ts.Sim.Full.freedOf PRE_first_tail_x15_r0_body.s656.ffi).getD PTrie.nil
noncomputable def PRE_first_tail_x15_r0_body.kr1_74 : Host.Load.Layers.KRec := (Host.Ts.Sim.Full.krecOf PRE_first_tail_x15_r0_body.s656.ffi).getD Host.Load.Layers.KRec.empty
kernel_rfl PRE_first_tail_x15_r0_body.ofx1_74 : (Host.Ts.Sim.Full.freedOf PRE_first_tail_x15_r0_body.s656.ffi) = some PRE_first_tail_x15_r0_body.fx1_74
kernel_rfl PRE_first_tail_x15_r0_body.okr1_74 : (Host.Ts.Sim.Full.krecOf PRE_first_tail_x15_r0_body.s656.ffi) = some PRE_first_tail_x15_r0_body.kr1_74
kernel_rfl PRE_first_tail_x15_r0_body.ff074 : PRE_first_tail_x15_r0_body.fx0_74 = Stage.setAll PRE_first_tail_x15_r0_body.fxC_74 (PRE_first_tail_x15_r0_body.clo74.filterMap fun i => (PRE_first_tail_x15_r0_body.fx0_74.get i).map (i, ·))
kernel_rfl PRE_first_tail_x15_r0_body.ff174 : PRE_first_tail_x15_r0_body.fx1_74 = Stage.setAll PRE_first_tail_x15_r0_body.fxC_74 (PRE_first_tail_x15_r0_body.cwS74.filterMap fun i => (PRE_first_tail_x15_r0_body.fx1_74.get i).map (i, ·))
kernel_rfl PRE_first_tail_x15_r0_body.ffck74 : freedLB PRE_first_tail_x15_r0_body.kappa74 PRE_first_tail_x15_r0_body.cx0_74.mlx PRE_first_tail_x15_r0_body.fx0_74 PRE_first_tail_x15_r0_body.fx1_74 PRE_first_tail_x15_r0_body.clo74 = true
kernel_rfl PRE_first_tail_x15_r0_body.fkf074 : PRE_first_tail_x15_r0_body.kr0_74.flags = Stage.setAll PRE_first_tail_x15_r0_body.krC_74.flags (PRE_first_tail_x15_r0_body.clo74.filterMap fun i => (PRE_first_tail_x15_r0_body.kr0_74.flags.get i).map (i, ·))
kernel_rfl PRE_first_tail_x15_r0_body.fkt074 : PRE_first_tail_x15_r0_body.kr0_74.targs = Stage.setAll PRE_first_tail_x15_r0_body.krC_74.targs (PRE_first_tail_x15_r0_body.clo74.filterMap fun i => (PRE_first_tail_x15_r0_body.kr0_74.targs.get i).map (i, ·))
kernel_rfl PRE_first_tail_x15_r0_body.fkf174 : PRE_first_tail_x15_r0_body.kr1_74.flags = Stage.setAll PRE_first_tail_x15_r0_body.krC_74.flags (PRE_first_tail_x15_r0_body.cwS74.filterMap fun i => (PRE_first_tail_x15_r0_body.kr1_74.flags.get i).map (i, ·))
kernel_rfl PRE_first_tail_x15_r0_body.fkt174 : PRE_first_tail_x15_r0_body.kr1_74.targs = Stage.setAll PRE_first_tail_x15_r0_body.krC_74.targs (PRE_first_tail_x15_r0_body.cwS74.filterMap fun i => (PRE_first_tail_x15_r0_body.kr1_74.targs.get i).map (i, ·))
kernel_rfl PRE_first_tail_x15_r0_body.fkck74 : krecLB PRE_first_tail_x15_r0_body.kappa74 3217 PRE_first_tail_x15_r0_body.cx0_74.mlx PRE_first_tail_x15_r0_body.kr0_74 PRE_first_tail_x15_r0_body.kr1_74 PRE_first_tail_x15_r0_body.clo74 = true
kernel_rfl PRE_first_tail_x15_r0_body.fkn74 : Nat.ble 3217 3217 = true
-- the bridge and the pending traces' regions
kernel_rfl PRE_first_tail_x15_r0_body.cbridge74 : Host.Ts.Sim.Full.bridgeOf PRE_first_tail_x15_r0_body.s656.ffi = Host.Ts.Sim.Full.bridgeOf PRE_first_tail_x15_r0_body.s657.ffi
kernel_rfl PRE_first_tail_x15_r0_body.cpendR74 : pendRegB PRE_first_tail_x15_r0_body.kappa74 (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s657.ffi).mlx = true
kernel_rfl PRE_first_tail_x15_r0_body.cpendLe74 : Nat.ble (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s657.ffi).mlx.next (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s656.ffi).mlx.next = true
/-- **The compaction's native shift**, given the call's bookkeeping, its relation's facts (the model's and the
observers') and the canonical closedness. -/
theorem PRE_first_tail_x15_r0_body.cshift74 (clean : Conv.NClean (⟨19655, 16744, 2732743, 3217⟩ : Conv.Cnt) (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s655.ffi).mlx) (hltC : ∀ h, PH (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s655.ffi).mlx h → h < (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s655.ffi).mlx.next) (nltC : ∀ i, PN (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s655.ffi).mlx i → i < (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s655.ffi).mlx.nnext) (itemsC : ∀ k v, (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s655.ffi).mlx.items.get k = some v → PN (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s655.ffi).mlx k) (tracedC : ∀ h o, (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s655.ffi).mlx.objs.get h = some o → ∀ i ∈ objTraces o, i < PRE_first_tail_x15_r0_body.P74.NL) (cl : SSt (· < 3217) PRE_first_tail_x15_r0_body.cx0_74.mlx)
    (hobjC : ∀ h, PRE_first_tail_x15_r0_body.fxC_74.get h = some () → ((Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s655.ffi).mlx.objs.get h).isSome = true)
    (hfC : ∀ h, (PRE_first_tail_x15_r0_body.krC_74.flags.get h).isSome = true → ((Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s655.ffi).mlx.objs.get h).isSome = true)
    (htC : ∀ h, (PRE_first_tail_x15_r0_body.krC_74.targs.get h).isSome = true → ((Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s655.ffi).mlx.objs.get h).isSome = true)
    (hclC : ∀ h l, PRE_first_tail_x15_r0_body.krC_74.targs.get h = some l → Host.Ts.Sim.Full.STargs (· < (⟨19655, 16744, 2732743, 3217⟩ : Conv.Cnt).n) l) :
    Conv.FullShiftQ PRE_first_tail_x15_r0_body.P74 3217 PRE_first_tail_x15_r0_body.kappa74 PRE_first_tail_x15_r0_body.s657.ffi PRE_first_tail_x15_r0_body.s656.ffi :=
  ⟨PRE_first_tail_x15_r0_body.cnshift74 clean hltC nltC itemsC tracedC cl, PRE_first_tail_x15_r0_body.cqueue74, fun t ht => bSN_sound (List.all_eq_true.mp PRE_first_tail_x15_r0_body.ctokSupp74 t ht),
    PRE_first_tail_x15_r0_body.cbridge74,
    liveShift_foot (x0' := Host.Ts.Sim.Full.mlxOf PRE_first_tail_x15_r0_body.s657.ffi) (x1' := Host.Ts.Sim.Full.mlxOf PRE_first_tail_x15_r0_body.s656.ffi) (PRE_first_tail_x15_r0_body.cfoot74 clean hltC nltC itemsC tracedC cl) rfl PRE_first_tail_x15_r0_body.ofx0_74 PRE_first_tail_x15_r0_body.ofx1_74 hobjC PRE_first_tail_x15_r0_body.ff074 PRE_first_tail_x15_r0_body.ff174 PRE_first_tail_x15_r0_body.ffck74,
    kernShift_foot (x0' := Host.Ts.Sim.Full.mlxOf PRE_first_tail_x15_r0_body.s657.ffi) (x1' := Host.Ts.Sim.Full.mlxOf PRE_first_tail_x15_r0_body.s656.ffi) (PRE_first_tail_x15_r0_body.cfoot74 clean hltC nltC itemsC tracedC cl) rfl PRE_first_tail_x15_r0_body.okr0_74 PRE_first_tail_x15_r0_body.okr1_74 (Nat.le_of_ble_eq_true PRE_first_tail_x15_r0_body.fkn74) hfC htC hclC
      PRE_first_tail_x15_r0_body.fkf074 PRE_first_tail_x15_r0_body.fkt074 PRE_first_tail_x15_r0_body.fkf174 PRE_first_tail_x15_r0_body.fkt174 PRE_first_tail_x15_r0_body.fkck74,
    pendReg_of rfl PRE_first_tail_x15_r0_body.cnh074 PRE_first_tail_x15_r0_body.cnh174 (Nat.le_of_ble_eq_true PRE_first_tail_x15_r0_body.cpendLe74) PRE_first_tail_x15_r0_body.cpendR74⟩

end Host.Load.Run.Tpl
