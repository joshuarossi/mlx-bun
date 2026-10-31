import host.sim.template.a4pre_first_tail_x15_r0_body.SiteCl128
import host.sim.conv.CompactFull
import host.sim.template.FootGen
set_option Elab.async false
namespace Host.Load.Run.Tpl
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
open Host.Ts Host.Ts.Sim Host.Ts.Sim.Template

/-! The compaction's native shift at call site 128 from its footprint (`Conv.nshift_of_foot`), and the observers'
(`liveShift_foot`, `kernShift_foot`): `Conv.FullShiftQ` for `Conv.full_compactQ`, given the call's bookkeeping and its
relation's facts. -/

/-- The load parameters of the chain (band-free: its start's node counter as `NL` and `N0`). -/
def PRE_first_tail_x15_r0_body.Pc128 : LoadP := ⟨18151, 131072, 1099511627776, 15235, 15235, []⟩
/-- The site's band raised to the map's checked fixed-node prefix, including newly recorded closure traces. -/
def PRE_first_tail_x15_r0_body.P128 : LoadP := PRE_first_tail_x15_r0_body.Pc128.raise 17818
kernel_rfl PRE_first_tail_x15_r0_body.craise128 : Nat.ble PRE_first_tail_x15_r0_body.Pc128.N0 17818 = true
theorem PRE_first_tail_x15_r0_body.raised128 : Host.Ts.Sim.Full.Raised PRE_first_tail_x15_r0_body.Pc128 PRE_first_tail_x15_r0_body.P128 :=
  .inr ⟨17818, rfl, Nat.le_of_ble_eq_true PRE_first_tail_x15_r0_body.craise128, rfl⟩
noncomputable abbrev PRE_first_tail_x15_r0_body.cx0_128 : Host.Load.LSt := clearTokens (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1238.ffi)
noncomputable abbrev PRE_first_tail_x15_r0_body.cx1_128 : Host.Load.LSt := clearTokens (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1237.ffi)
def PRE_first_tail_x15_r0_body.khinv128 : PTrie Nat := Stage.setAll PTrie.nil []
def PRE_first_tail_x15_r0_body.kninv128 : PTrie Nat := Stage.setAll PTrie.nil []
/-- The stage's footprint: its written and fresh handles, fresh nodes, written and fresh items. -/
def PRE_first_tail_x15_r0_body.cwS128 : List Nat := []
def PRE_first_tail_x15_r0_body.cnS128 : List Nat := List.range' 17818 0
def PRE_first_tail_x15_r0_body.ciS128 : List Nat := [] ++ List.range' 17818 0

-- the small checks (`MChecks`'s)
kernel_rfl PRE_first_tail_x15_r0_body.cnh0128 : PRE_first_tail_x15_r0_body.kd128.nh0 = PRE_first_tail_x15_r0_body.cx0_128.mlx.next
kernel_rfl PRE_first_tail_x15_r0_body.cnh1128 : PRE_first_tail_x15_r0_body.kd128.nh1 = PRE_first_tail_x15_r0_body.cx1_128.mlx.next
kernel_rfl PRE_first_tail_x15_r0_body.cnn0128 : PRE_first_tail_x15_r0_body.kd128.nn0 = PRE_first_tail_x15_r0_body.cx0_128.mlx.nnext
kernel_rfl PRE_first_tail_x15_r0_body.cnn1128 : PRE_first_tail_x15_r0_body.kd128.nn1 = PRE_first_tail_x15_r0_body.cx1_128.mlx.nnext
kernel_rfl PRE_first_tail_x15_r0_body.cplo128 : (Nat.blt 0 PRE_first_tail_x15_r0_body.P128.lo && Nat.ble PRE_first_tail_x15_r0_body.P128.lo PRE_first_tail_x15_r0_body.cx0_128.mlx.next && Nat.ble PRE_first_tail_x15_r0_body.P128.lo RData.bigHi && Nat.ble RData.bigHi PRE_first_tail_x15_r0_body.P128.E) = true
kernel_rfl PRE_first_tail_x15_r0_body.ccnt128 : (Nat.ble PRE_first_tail_x15_r0_body.cx0_128.mlx.next PRE_first_tail_x15_r0_body.cx1_128.mlx.next && Nat.ble PRE_first_tail_x15_r0_body.cx0_128.mlx.nnext PRE_first_tail_x15_r0_body.cx1_128.mlx.nnext) = true
kernel_rfl PRE_first_tail_x15_r0_body.cnband128 : (Nat.blt 0 PRE_first_tail_x15_r0_body.P128.NL && Nat.ble PRE_first_tail_x15_r0_body.P128.NL PRE_first_tail_x15_r0_body.P128.N0 && Nat.ble PRE_first_tail_x15_r0_body.P128.N0 PRE_first_tail_x15_r0_body.cx0_128.mlx.nnext) = true
kernel_rfl PRE_first_tail_x15_r0_body.chbelow128 : PRE_first_tail_x15_r0_body.kd128.checkHndBelow = true
kernel_rfl PRE_first_tail_x15_r0_body.chren128 : checkRenG PRE_first_tail_x15_r0_body.kd128.hnd PRE_first_tail_x15_r0_body.khinv128 (phB PRE_first_tail_x15_r0_body.cx0_128.mlx) = true
kernel_rfl PRE_first_tail_x15_r0_body.cband128 : PRE_first_tail_x15_r0_body.kd128.checkBand PRE_first_tail_x15_r0_body.P128.lo = true
kernel_rfl PRE_first_tail_x15_r0_body.cnh1pos128 : Nat.blt 0 PRE_first_tail_x15_r0_body.kd128.nh1 = true
kernel_rfl PRE_first_tail_x15_r0_body.cnren128 : checkRenG PRE_first_tail_x15_r0_body.kd128.node PRE_first_tail_x15_r0_body.kninv128 (pnB PRE_first_tail_x15_r0_body.cx0_128.mlx) = true
kernel_rfl PRE_first_tail_x15_r0_body.cnlow128 : (PTrie.keysA PRE_first_tail_x15_r0_body.kd128.node).all (fun j => Nat.ble PRE_first_tail_x15_r0_body.P128.NL j && Nat.blt (PRE_first_tail_x15_r0_body.kd128.nodeF j) PRE_first_tail_x15_r0_body.cx1_128.mlx.nnext) = true
kernel_rfl PRE_first_tail_x15_r0_body.cabs0a128 : PRE_first_tail_x15_r0_body.cx0_128.mlx.arrs.get 0 = none
kernel_rfl PRE_first_tail_x15_r0_body.cabs0b128 : PRE_first_tail_x15_r0_body.cx0_128.mlx.objs.get 0 = none
kernel_rfl PRE_first_tail_x15_r0_body.ctok1128 : PRE_first_tail_x15_r0_body.cx1_128.mlx.tokens = []
kernel_rfl PRE_first_tail_x15_r0_body.cpend128 : PRE_first_tail_x15_r0_body.cx1_128.mlx.pending = PRE_first_tail_x15_r0_body.cx0_128.mlx.pending.map PRE_first_tail_x15_r0_body.kappa128.pend
kernel_rfl PRE_first_tail_x15_r0_body.cerrh128 : PRE_first_tail_x15_r0_body.cx1_128.mlx.errh = PRE_first_tail_x15_r0_body.cx0_128.mlx.errh.map PRE_first_tail_x15_r0_body.kappa128.arg
kernel_rfl PRE_first_tail_x15_r0_body.cfiles128 : PRE_first_tail_x15_r0_body.cx1_128.mlx.files = PRE_first_tail_x15_r0_body.cx0_128.mlx.files
kernel_rfl PRE_first_tail_x15_r0_body.carch128 : PRE_first_tail_x15_r0_body.cx1_128.mlx.arch = PRE_first_tail_x15_r0_body.cx0_128.mlx.arch
kernel_rfl PRE_first_tail_x15_r0_body.csizes128 : PRE_first_tail_x15_r0_body.cx1_128.mlx.deviceSizes = PRE_first_tail_x15_r0_body.cx0_128.mlx.deviceSizes
kernel_rfl PRE_first_tail_x15_r0_body.cwired128 : PRE_first_tail_x15_r0_body.cx1_128.mlx.wired = PRE_first_tail_x15_r0_body.cx0_128.mlx.wired
kernel_rfl PRE_first_tail_x15_r0_body.chost128 : PRE_first_tail_x15_r0_body.cx1_128.host = PRE_first_tail_x15_r0_body.cx0_128.host
-- the compaction map's addresses are `PRE_first_tail_x15_r0_body.kd128`'s
kernel_rfl PRE_first_tail_x15_r0_body.ckn0128 : PRE_first_tail_x15_r0_body.kd128.n0 = 2774920
kernel_rfl PRE_first_tail_x15_r0_body.ckn1128 : PRE_first_tail_x15_r0_body.kd128.n1 = 2774930
kernel_rfl PRE_first_tail_x15_r0_body.ckheap128 : (PTrie.keysA PRE_first_tail_x15_r0_body.kd128.heap).all (fun x => Nat.ble 2774919 x) = true
kernel_rfl PRE_first_tail_x15_r0_body.ckpl128 : (List.range 1).all (fun j => decide (PRE_first_tail_x15_r0_body.kd128.heap.get (2774919 + j) = nth? PRE_first_tail_x15_r0_body.pl128 j)) = true
-- the map fixes the call's names (`Conv.fixOld_compact`), the call's counters
kernel_rfl PRE_first_tail_x15_r0_body.fja128 : Nat.ble 2774919 2774919 = true
kernel_rfl PRE_first_tail_x15_r0_body.fn128 : Nat.ble 5527 5527 = true
kernel_rfl PRE_first_tail_x15_r0_body.fjaD128 : Nat.ble 2774919 PRE_first_tail_x15_r0_body.kd128.n0 = true
kernel_rfl PRE_first_tail_x15_r0_body.fxn128 : Nat.ble 20713 PRE_first_tail_x15_r0_body.kd128.nh0 = true
kernel_rfl PRE_first_tail_x15_r0_body.fnn128 : Nat.ble 17818 PRE_first_tail_x15_r0_body.kd128.nn0 = true
kernel_rfl PRE_first_tail_x15_r0_body.fxb128 : Nat.ble 20713 RData.bigHi = true
kernel_rfl PRE_first_tail_x15_r0_body.fheap128 : (PTrie.keysA PRE_first_tail_x15_r0_body.kd128.heap).all (Nat.ble (⟨20713, 17818, 2774919, 5527⟩ : Conv.Cnt).ja) = true
kernel_rfl PRE_first_tail_x15_r0_body.fhnd128 : (PTrie.keysA PRE_first_tail_x15_r0_body.kd128.hnd).all (Nat.ble (⟨20713, 17818, 2774919, 5527⟩ : Conv.Cnt).xn) = true
kernel_rfl PRE_first_tail_x15_r0_body.fnode128 : (PTrie.keysA PRE_first_tail_x15_r0_body.kd128.node).all (Nat.ble (⟨20713, 17818, 2774919, 5527⟩ : Conv.Cnt).nn) = true
/-- The compaction map fixes the call's names. -/
theorem PRE_first_tail_x15_r0_body.cfix128 : Conv.FixOld (⟨20713, 17818, 2774919, 5527⟩ : Conv.Cnt) PRE_first_tail_x15_r0_body.kappa128 :=
  Conv.fixOld_compact (Nat.le_of_ble_eq_true PRE_first_tail_x15_r0_body.fja128) (Nat.le_of_ble_eq_true PRE_first_tail_x15_r0_body.fn128) (Nat.le_of_ble_eq_true PRE_first_tail_x15_r0_body.fjaD128) (Nat.le_of_ble_eq_true PRE_first_tail_x15_r0_body.fxn128) (Nat.le_of_ble_eq_true PRE_first_tail_x15_r0_body.fnn128) (Nat.le_of_ble_eq_true PRE_first_tail_x15_r0_body.fxb128) PRE_first_tail_x15_r0_body.fheap128 PRE_first_tail_x15_r0_body.fhnd128 PRE_first_tail_x15_r0_body.fnode128
kernel_rfl PRE_first_tail_x15_r0_body.fcxn128 : (⟨20713, 17818, 2774919, 5527⟩ : Conv.Cnt).xn = (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1236.ffi).mlx.next
kernel_rfl PRE_first_tail_x15_r0_body.fcnn128 : (⟨20713, 17818, 2774919, 5527⟩ : Conv.Cnt).nn = (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1236.ffi).mlx.nnext
kernel_rfl PRE_first_tail_x15_r0_body.fle0128 : (Nat.ble (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1236.ffi).mlx.next PRE_first_tail_x15_r0_body.cx0_128.mlx.next && Nat.ble (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1236.ffi).mlx.nnext PRE_first_tail_x15_r0_body.cx0_128.mlx.nnext && Nat.ble (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1236.ffi).mlx.next RData.bigHi) = true
kernel_rfl PRE_first_tail_x15_r0_body.fnk128 : (PTrie.keysA PRE_first_tail_x15_r0_body.kd128.node).all (Nat.ble (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1236.ffi).mlx.nnext) = true
-- the merged state keeps the call's entries off the stage's footprint
kernel_rfl PRE_first_tail_x15_r0_body.f1A128 : PRE_first_tail_x15_r0_body.cx1_128.mlx.arrs = Stage.setAll (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1236.ffi).mlx.arrs (PRE_first_tail_x15_r0_body.cwS128.filterMap fun i => (PRE_first_tail_x15_r0_body.cx1_128.mlx.arrs.get i).map (i, ·))
kernel_rfl PRE_first_tail_x15_r0_body.f1O128 : PRE_first_tail_x15_r0_body.cx1_128.mlx.objs = Stage.setAll (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1236.ffi).mlx.objs (PRE_first_tail_x15_r0_body.cwS128.filterMap fun i => (PRE_first_tail_x15_r0_body.cx1_128.mlx.objs.get i).map (i, ·))
kernel_rfl PRE_first_tail_x15_r0_body.f1N128 : PRE_first_tail_x15_r0_body.cx1_128.mlx.nodes = Stage.setAll (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1236.ffi).mlx.nodes (PRE_first_tail_x15_r0_body.cnS128.filterMap fun i => (PRE_first_tail_x15_r0_body.cx1_128.mlx.nodes.get i).map (i, ·))
kernel_rfl PRE_first_tail_x15_r0_body.f1I128 : PRE_first_tail_x15_r0_body.cx1_128.mlx.items = Stage.setAll (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1236.ffi).mlx.items (PRE_first_tail_x15_r0_body.ciS128.filterMap fun i => (PRE_first_tail_x15_r0_body.cx1_128.mlx.items.get i).map (i, ·))
kernel_rfl PRE_first_tail_x15_r0_body.fbd128 : (PRE_first_tail_x15_r0_body.clo128 ++ PRE_first_tail_x15_r0_body.cln128 ++ PRE_first_tail_x15_r0_body.cli128 ++ PRE_first_tail_x15_r0_body.cwS128 ++ PRE_first_tail_x15_r0_body.cnS128 ++ PRE_first_tail_x15_r0_body.ciS128).all (fun i => Nat.blt (i / 4096) (4 ^ 31)) = true
kernel_rfl PRE_first_tail_x15_r0_body.fincW128 : PRE_first_tail_x15_r0_body.cwS128.all (fun h => !Nat.blt h (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1236.ffi).mlx.next || PRE_first_tail_x15_r0_body.clo128.contains h) = true
kernel_rfl PRE_first_tail_x15_r0_body.fincI128 : PRE_first_tail_x15_r0_body.ciS128.all (fun k => !Nat.blt k (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1236.ffi).mlx.nnext || PRE_first_tail_x15_r0_body.cli128.contains k) = true
kernel_rfl PRE_first_tail_x15_r0_body.fincN128 : PRE_first_tail_x15_r0_body.cnS128.all (Nat.ble (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1236.ffi).mlx.nnext) = true
kernel_rfl PRE_first_tail_x15_r0_body.flnF128 : PRE_first_tail_x15_r0_body.cln128.all (Nat.ble (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1236.ffi).mlx.nnext) = true
-- the checks over the changed lists
kernel_rfl PRE_first_tail_x15_r0_body.fh128 : PRE_first_tail_x15_r0_body.clo128.all (handleOK PRE_first_tail_x15_r0_body.kappa128 PRE_first_tail_x15_r0_body.P128.lo PRE_first_tail_x15_r0_body.cx0_128.mlx PRE_first_tail_x15_r0_body.cx1_128.mlx) = true
kernel_rfl PRE_first_tail_x15_r0_body.fo128 : PRE_first_tail_x15_r0_body.clo128.map (fun h => PRE_first_tail_x15_r0_body.cx1_128.mlx.objs.get (PRE_first_tail_x15_r0_body.kappa128.handle h)) = PRE_first_tail_x15_r0_body.clo128.map (fun h => (PRE_first_tail_x15_r0_body.cx0_128.mlx.objs.get h).map PRE_first_tail_x15_r0_body.kappa128.nobj)
kernel_rfl PRE_first_tail_x15_r0_body.fok128 : PRE_first_tail_x15_r0_body.clo128.all (objOK PRE_first_tail_x15_r0_body.kappa128 PRE_first_tail_x15_r0_body.P128.NL PRE_first_tail_x15_r0_body.cx0_128.mlx) = true
kernel_rfl PRE_first_tail_x15_r0_body.fnd128 : PRE_first_tail_x15_r0_body.cln128.all (nodeOKF PRE_first_tail_x15_r0_body.kappa128 PRE_first_tail_x15_r0_body.P128 PRE_first_tail_x15_r0_body.cx0_128.mlx PRE_first_tail_x15_r0_body.cx1_128.mlx) = true
kernel_rfl PRE_first_tail_x15_r0_body.fp128 : ((PRE_first_tail_x15_r0_body.cln128.filter (fullB PRE_first_tail_x15_r0_body.P128))).map (fun i => (PRE_first_tail_x15_r0_body.cx1_128.mlx.nodes.get (PRE_first_tail_x15_r0_body.kappa128.node i)).map Host.Mlx.Ffi.Node.prim) =
  ((PRE_first_tail_x15_r0_body.cln128.filter (fullB PRE_first_tail_x15_r0_body.P128))).map (fun i => (PRE_first_tail_x15_r0_body.cx0_128.mlx.nodes.get i).map fun nd => PRE_first_tail_x15_r0_body.kappa128.prim nd.prim)
kernel_rfl PRE_first_tail_x15_r0_body.fnordI128 : incrB PRE_first_tail_x15_r0_body.kd128.nodeF (List.range' 17818 0) = true
kernel_rfl PRE_first_tail_x15_r0_body.fnordK128 : (PTrie.keysA PRE_first_tail_x15_r0_body.kd128.node).all (fun k => Nat.ble 17818 k && Nat.blt k 17818) = true
kernel_rfl PRE_first_tail_x15_r0_body.fnordL128 : (PRE_first_tail_x15_r0_body.cln128.filter (Nat.ble PRE_first_tail_x15_r0_body.P128.N0)).all (fun i => Nat.ble i (PRE_first_tail_x15_r0_body.kd128.nodeF i) && (Nat.blt i 17818 || Nat.ble PRE_first_tail_x15_r0_body.kd128.nn0 i)) = true
theorem PRE_first_tail_x15_r0_body.fnord128 : (PRE_first_tail_x15_r0_body.cln128.filter (Nat.ble PRE_first_tail_x15_r0_body.P128.N0)).all (fun i => Nat.ble i (PRE_first_tail_x15_r0_body.kd128.nodeF i) &&
    (PTrie.keysA PRE_first_tail_x15_r0_body.kd128.node).all fun j => !Nat.blt j i || Nat.blt (PRE_first_tail_x15_r0_body.kd128.nodeF j) (PRE_first_tail_x15_r0_body.kd128.nodeF i)) = true :=
  cnord_of PRE_first_tail_x15_r0_body.cnlow128 PRE_first_tail_x15_r0_body.cnn1128 PRE_first_tail_x15_r0_body.fnordI128 PRE_first_tail_x15_r0_body.fnordK128 PRE_first_tail_x15_r0_body.fnordL128
kernel_rfl PRE_first_tail_x15_r0_body.fi128 : PRE_first_tail_x15_r0_body.cli128.all (pnB PRE_first_tail_x15_r0_body.cx0_128.mlx) = true
kernel_rfl PRE_first_tail_x15_r0_body.fii128 : PRE_first_tail_x15_r0_body.cli128.all (fun k => decide (PRE_first_tail_x15_r0_body.cx1_128.mlx.items.get (PRE_first_tail_x15_r0_body.kappa128.node k) = (PRE_first_tail_x15_r0_body.cx0_128.mlx.items.get k).map PRE_first_tail_x15_r0_body.kappa128.nv)) = true
/-- **The compaction's footprint.** -/
theorem PRE_first_tail_x15_r0_body.cfoot128 (clean : Conv.NClean (⟨20713, 17818, 2774919, 5527⟩ : Conv.Cnt) (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1236.ffi).mlx) (hltC : ∀ h, PH (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1236.ffi).mlx h → h < (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1236.ffi).mlx.next) (nltC : ∀ i, PN (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1236.ffi).mlx i → i < (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1236.ffi).mlx.nnext) (itemsC : ∀ k v, (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1236.ffi).mlx.items.get k = some v → PN (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1236.ffi).mlx k) (tracedC : ∀ h o, (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1236.ffi).mlx.objs.get h = some o → ∀ i ∈ objTraces o, i < PRE_first_tail_x15_r0_body.P128.NL) (cl : SSt (· < 5527) PRE_first_tail_x15_r0_body.cx0_128.mlx) :
    Conv.MFoot PRE_first_tail_x15_r0_body.P128 5527 PRE_first_tail_x15_r0_body.kappa128 PRE_first_tail_x15_r0_body.kd128 PRE_first_tail_x15_r0_body.khinv128 PRE_first_tail_x15_r0_body.kninv128 (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1236.ffi).mlx PRE_first_tail_x15_r0_body.cx0_128.mlx PRE_first_tail_x15_r0_body.cx1_128.mlx (⟨20713, 17818, 2774919, 5527⟩ : Conv.Cnt) PRE_first_tail_x15_r0_body.clo128 PRE_first_tail_x15_r0_body.cln128 PRE_first_tail_x15_r0_body.cli128 PRE_first_tail_x15_r0_body.cwS128 PRE_first_tail_x15_r0_body.cnS128 PRE_first_tail_x15_r0_body.ciS128 :=
  ⟨rfl, rfl, rfl, PRE_first_tail_x15_r0_body.cnh0128, PRE_first_tail_x15_r0_body.cnh1128, PRE_first_tail_x15_r0_body.cnn0128, PRE_first_tail_x15_r0_body.cnn1128, PRE_first_tail_x15_r0_body.cplo128, PRE_first_tail_x15_r0_body.ccnt128, PRE_first_tail_x15_r0_body.cnband128, PRE_first_tail_x15_r0_body.chbelow128, PRE_first_tail_x15_r0_body.chren128, PRE_first_tail_x15_r0_body.cband128, PRE_first_tail_x15_r0_body.cnh1pos128, PRE_first_tail_x15_r0_body.cnren128, PRE_first_tail_x15_r0_body.cnlow128, PRE_first_tail_x15_r0_body.cabs0a128, PRE_first_tail_x15_r0_body.cabs0b128, PRE_first_tail_x15_r0_body.ctok1128, PRE_first_tail_x15_r0_body.cpend128, PRE_first_tail_x15_r0_body.cerrh128, PRE_first_tail_x15_r0_body.cfiles128, PRE_first_tail_x15_r0_body.carch128, PRE_first_tail_x15_r0_body.csizes128, PRE_first_tail_x15_r0_body.cwired128, PRE_first_tail_x15_r0_body.cfix128, clean, PRE_first_tail_x15_r0_body.fcxn128, PRE_first_tail_x15_r0_body.fcnn128, hltC, nltC, itemsC, tracedC, cl, PRE_first_tail_x15_r0_body.fle0128, PRE_first_tail_x15_r0_body.fnk128, PRE_first_tail_x15_r0_body.ckA128, PRE_first_tail_x15_r0_body.cobjsK128, PRE_first_tail_x15_r0_body.cnodesK128, PRE_first_tail_x15_r0_body.citemsK128, PRE_first_tail_x15_r0_body.f1A128, PRE_first_tail_x15_r0_body.f1O128, PRE_first_tail_x15_r0_body.f1N128, PRE_first_tail_x15_r0_body.f1I128, PRE_first_tail_x15_r0_body.fbd128, PRE_first_tail_x15_r0_body.fincW128, PRE_first_tail_x15_r0_body.fincI128, PRE_first_tail_x15_r0_body.fincN128, PRE_first_tail_x15_r0_body.flnF128, PRE_first_tail_x15_r0_body.fh128, PRE_first_tail_x15_r0_body.fo128, PRE_first_tail_x15_r0_body.fok128, PRE_first_tail_x15_r0_body.fnd128, PRE_first_tail_x15_r0_body.fp128, PRE_first_tail_x15_r0_body.fnord128, PRE_first_tail_x15_r0_body.fi128, PRE_first_tail_x15_r0_body.fii128⟩
theorem PRE_first_tail_x15_r0_body.cnshift128 (clean : Conv.NClean (⟨20713, 17818, 2774919, 5527⟩ : Conv.Cnt) (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1236.ffi).mlx) (hltC : ∀ h, PH (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1236.ffi).mlx h → h < (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1236.ffi).mlx.next) (nltC : ∀ i, PN (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1236.ffi).mlx i → i < (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1236.ffi).mlx.nnext) (itemsC : ∀ k v, (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1236.ffi).mlx.items.get k = some v → PN (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1236.ffi).mlx k) (tracedC : ∀ h o, (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1236.ffi).mlx.objs.get h = some o → ∀ i ∈ objTraces o, i < PRE_first_tail_x15_r0_body.P128.NL) (cl : SSt (· < 5527) PRE_first_tail_x15_r0_body.cx0_128.mlx) : NShift PRE_first_tail_x15_r0_body.P128 5527 PRE_first_tail_x15_r0_body.kappa128 PRE_first_tail_x15_r0_body.cx0_128 PRE_first_tail_x15_r0_body.cx1_128 :=
  Conv.nshift_of_foot (PRE_first_tail_x15_r0_body.cfoot128 clean hltC nltC itemsC tracedC cl) PRE_first_tail_x15_r0_body.chost128 (compact_a_eq PRE_first_tail_x15_r0_body.ckn0128 PRE_first_tail_x15_r0_body.ckn1128 PRE_first_tail_x15_r0_body.ckheap128 PRE_first_tail_x15_r0_body.ckpl128)

-- the observers: the layers' states at the call, the canonical and the merged state, their footprints and checks
noncomputable def PRE_first_tail_x15_r0_body.fxC_128 : PTrie Unit := (Host.Ts.Sim.Full.freedOf PRE_first_tail_x15_r0_body.s1236.ffi).getD PTrie.nil
noncomputable def PRE_first_tail_x15_r0_body.krC_128 : Host.Load.Layers.KRec := (Host.Ts.Sim.Full.krecOf PRE_first_tail_x15_r0_body.s1236.ffi).getD Host.Load.Layers.KRec.empty
kernel_rfl PRE_first_tail_x15_r0_body.ofxC_128 : (Host.Ts.Sim.Full.freedOf PRE_first_tail_x15_r0_body.s1236.ffi) = some PRE_first_tail_x15_r0_body.fxC_128
kernel_rfl PRE_first_tail_x15_r0_body.okrC_128 : (Host.Ts.Sim.Full.krecOf PRE_first_tail_x15_r0_body.s1236.ffi) = some PRE_first_tail_x15_r0_body.krC_128
noncomputable def PRE_first_tail_x15_r0_body.fx0_128 : PTrie Unit := (Host.Ts.Sim.Full.freedOf PRE_first_tail_x15_r0_body.s1238.ffi).getD PTrie.nil
noncomputable def PRE_first_tail_x15_r0_body.kr0_128 : Host.Load.Layers.KRec := (Host.Ts.Sim.Full.krecOf PRE_first_tail_x15_r0_body.s1238.ffi).getD Host.Load.Layers.KRec.empty
kernel_rfl PRE_first_tail_x15_r0_body.ofx0_128 : (Host.Ts.Sim.Full.freedOf PRE_first_tail_x15_r0_body.s1238.ffi) = some PRE_first_tail_x15_r0_body.fx0_128
kernel_rfl PRE_first_tail_x15_r0_body.okr0_128 : (Host.Ts.Sim.Full.krecOf PRE_first_tail_x15_r0_body.s1238.ffi) = some PRE_first_tail_x15_r0_body.kr0_128
noncomputable def PRE_first_tail_x15_r0_body.fx1_128 : PTrie Unit := (Host.Ts.Sim.Full.freedOf PRE_first_tail_x15_r0_body.s1237.ffi).getD PTrie.nil
noncomputable def PRE_first_tail_x15_r0_body.kr1_128 : Host.Load.Layers.KRec := (Host.Ts.Sim.Full.krecOf PRE_first_tail_x15_r0_body.s1237.ffi).getD Host.Load.Layers.KRec.empty
kernel_rfl PRE_first_tail_x15_r0_body.ofx1_128 : (Host.Ts.Sim.Full.freedOf PRE_first_tail_x15_r0_body.s1237.ffi) = some PRE_first_tail_x15_r0_body.fx1_128
kernel_rfl PRE_first_tail_x15_r0_body.okr1_128 : (Host.Ts.Sim.Full.krecOf PRE_first_tail_x15_r0_body.s1237.ffi) = some PRE_first_tail_x15_r0_body.kr1_128
kernel_rfl PRE_first_tail_x15_r0_body.ff0128 : PRE_first_tail_x15_r0_body.fx0_128 = Stage.setAll PRE_first_tail_x15_r0_body.fxC_128 (PRE_first_tail_x15_r0_body.clo128.filterMap fun i => (PRE_first_tail_x15_r0_body.fx0_128.get i).map (i, ·))
kernel_rfl PRE_first_tail_x15_r0_body.ff1128 : PRE_first_tail_x15_r0_body.fx1_128 = Stage.setAll PRE_first_tail_x15_r0_body.fxC_128 (PRE_first_tail_x15_r0_body.cwS128.filterMap fun i => (PRE_first_tail_x15_r0_body.fx1_128.get i).map (i, ·))
kernel_rfl PRE_first_tail_x15_r0_body.ffck128 : freedLB PRE_first_tail_x15_r0_body.kappa128 PRE_first_tail_x15_r0_body.cx0_128.mlx PRE_first_tail_x15_r0_body.fx0_128 PRE_first_tail_x15_r0_body.fx1_128 PRE_first_tail_x15_r0_body.clo128 = true
kernel_rfl PRE_first_tail_x15_r0_body.fkf0128 : PRE_first_tail_x15_r0_body.kr0_128.flags = Stage.setAll PRE_first_tail_x15_r0_body.krC_128.flags (PRE_first_tail_x15_r0_body.clo128.filterMap fun i => (PRE_first_tail_x15_r0_body.kr0_128.flags.get i).map (i, ·))
kernel_rfl PRE_first_tail_x15_r0_body.fkt0128 : PRE_first_tail_x15_r0_body.kr0_128.targs = Stage.setAll PRE_first_tail_x15_r0_body.krC_128.targs (PRE_first_tail_x15_r0_body.clo128.filterMap fun i => (PRE_first_tail_x15_r0_body.kr0_128.targs.get i).map (i, ·))
kernel_rfl PRE_first_tail_x15_r0_body.fkf1128 : PRE_first_tail_x15_r0_body.kr1_128.flags = Stage.setAll PRE_first_tail_x15_r0_body.krC_128.flags (PRE_first_tail_x15_r0_body.cwS128.filterMap fun i => (PRE_first_tail_x15_r0_body.kr1_128.flags.get i).map (i, ·))
kernel_rfl PRE_first_tail_x15_r0_body.fkt1128 : PRE_first_tail_x15_r0_body.kr1_128.targs = Stage.setAll PRE_first_tail_x15_r0_body.krC_128.targs (PRE_first_tail_x15_r0_body.cwS128.filterMap fun i => (PRE_first_tail_x15_r0_body.kr1_128.targs.get i).map (i, ·))
kernel_rfl PRE_first_tail_x15_r0_body.fkck128 : krecLB PRE_first_tail_x15_r0_body.kappa128 5527 PRE_first_tail_x15_r0_body.cx0_128.mlx PRE_first_tail_x15_r0_body.kr0_128 PRE_first_tail_x15_r0_body.kr1_128 PRE_first_tail_x15_r0_body.clo128 = true
kernel_rfl PRE_first_tail_x15_r0_body.fkn128 : Nat.ble 5527 5527 = true
-- the bridge and the pending traces' regions
kernel_rfl PRE_first_tail_x15_r0_body.cbridge128 : Host.Ts.Sim.Full.bridgeOf PRE_first_tail_x15_r0_body.s1237.ffi = Host.Ts.Sim.Full.bridgeOf PRE_first_tail_x15_r0_body.s1238.ffi
kernel_rfl PRE_first_tail_x15_r0_body.cpendR128 : pendRegB PRE_first_tail_x15_r0_body.kappa128 (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1238.ffi).mlx = true
kernel_rfl PRE_first_tail_x15_r0_body.cpendLe128 : Nat.ble (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1238.ffi).mlx.next (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1237.ffi).mlx.next = true
/-- **The compaction's native shift**, given the call's bookkeeping, its relation's facts (the model's and the
observers') and the canonical closedness. -/
theorem PRE_first_tail_x15_r0_body.cshift128 (clean : Conv.NClean (⟨20713, 17818, 2774919, 5527⟩ : Conv.Cnt) (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1236.ffi).mlx) (hltC : ∀ h, PH (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1236.ffi).mlx h → h < (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1236.ffi).mlx.next) (nltC : ∀ i, PN (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1236.ffi).mlx i → i < (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1236.ffi).mlx.nnext) (itemsC : ∀ k v, (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1236.ffi).mlx.items.get k = some v → PN (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1236.ffi).mlx k) (tracedC : ∀ h o, (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1236.ffi).mlx.objs.get h = some o → ∀ i ∈ objTraces o, i < PRE_first_tail_x15_r0_body.P128.NL) (cl : SSt (· < 5527) PRE_first_tail_x15_r0_body.cx0_128.mlx)
    (hobjC : ∀ h, PRE_first_tail_x15_r0_body.fxC_128.get h = some () → ((Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1236.ffi).mlx.objs.get h).isSome = true)
    (hfC : ∀ h, (PRE_first_tail_x15_r0_body.krC_128.flags.get h).isSome = true → ((Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1236.ffi).mlx.objs.get h).isSome = true)
    (htC : ∀ h, (PRE_first_tail_x15_r0_body.krC_128.targs.get h).isSome = true → ((Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1236.ffi).mlx.objs.get h).isSome = true)
    (hclC : ∀ h l, PRE_first_tail_x15_r0_body.krC_128.targs.get h = some l → Host.Ts.Sim.Full.STargs (· < (⟨20713, 17818, 2774919, 5527⟩ : Conv.Cnt).n) l) :
    Conv.FullShiftQ PRE_first_tail_x15_r0_body.P128 5527 PRE_first_tail_x15_r0_body.kappa128 PRE_first_tail_x15_r0_body.s1238.ffi PRE_first_tail_x15_r0_body.s1237.ffi :=
  ⟨PRE_first_tail_x15_r0_body.cnshift128 clean hltC nltC itemsC tracedC cl, PRE_first_tail_x15_r0_body.cqueue128, fun t ht => bSN_sound (List.all_eq_true.mp PRE_first_tail_x15_r0_body.ctokSupp128 t ht),
    PRE_first_tail_x15_r0_body.cbridge128,
    liveShift_foot (x0' := Host.Ts.Sim.Full.mlxOf PRE_first_tail_x15_r0_body.s1238.ffi) (x1' := Host.Ts.Sim.Full.mlxOf PRE_first_tail_x15_r0_body.s1237.ffi) (PRE_first_tail_x15_r0_body.cfoot128 clean hltC nltC itemsC tracedC cl) rfl PRE_first_tail_x15_r0_body.ofx0_128 PRE_first_tail_x15_r0_body.ofx1_128 hobjC PRE_first_tail_x15_r0_body.ff0128 PRE_first_tail_x15_r0_body.ff1128 PRE_first_tail_x15_r0_body.ffck128,
    kernShift_foot (x0' := Host.Ts.Sim.Full.mlxOf PRE_first_tail_x15_r0_body.s1238.ffi) (x1' := Host.Ts.Sim.Full.mlxOf PRE_first_tail_x15_r0_body.s1237.ffi) (PRE_first_tail_x15_r0_body.cfoot128 clean hltC nltC itemsC tracedC cl) rfl PRE_first_tail_x15_r0_body.okr0_128 PRE_first_tail_x15_r0_body.okr1_128 (Nat.le_of_ble_eq_true PRE_first_tail_x15_r0_body.fkn128) hfC htC hclC
      PRE_first_tail_x15_r0_body.fkf0128 PRE_first_tail_x15_r0_body.fkt0128 PRE_first_tail_x15_r0_body.fkf1128 PRE_first_tail_x15_r0_body.fkt1128 PRE_first_tail_x15_r0_body.fkck128,
    pendReg_of rfl PRE_first_tail_x15_r0_body.cnh0128 PRE_first_tail_x15_r0_body.cnh1128 (Nat.le_of_ble_eq_true PRE_first_tail_x15_r0_body.cpendLe128) PRE_first_tail_x15_r0_body.cpendR128⟩

end Host.Load.Run.Tpl
