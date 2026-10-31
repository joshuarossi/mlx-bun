import host.sim.template.a4pre_first_tail_x15_r0_body.SiteCl25
import host.sim.conv.CompactFull
import host.sim.template.FootGen
set_option Elab.async false
namespace Host.Load.Run.Tpl
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
open Host.Ts Host.Ts.Sim Host.Ts.Sim.Template

/-! The compaction's native shift at call site 25 from its footprint (`Conv.nshift_of_foot`), and the observers'
(`liveShift_foot`, `kernShift_foot`): `Conv.FullShiftQ` for `Conv.full_compactQ`, given the call's bookkeeping and its
relation's facts. -/

/-- The load parameters of the chain (band-free: its start's node counter as `NL` and `N0`). -/
def PRE_first_tail_x15_r0_body.Pc25 : LoadP := ⟨18151, 131072, 1099511627776, 15235, 15235, []⟩
/-- The site's band raised to the map's checked fixed-node prefix, including newly recorded closure traces. -/
def PRE_first_tail_x15_r0_body.P25 : LoadP := PRE_first_tail_x15_r0_body.Pc25.raise 15792
kernel_rfl PRE_first_tail_x15_r0_body.craise25 : Nat.ble PRE_first_tail_x15_r0_body.Pc25.N0 15792 = true
theorem PRE_first_tail_x15_r0_body.raised25 : Host.Ts.Sim.Full.Raised PRE_first_tail_x15_r0_body.Pc25 PRE_first_tail_x15_r0_body.P25 :=
  .inr ⟨15792, rfl, Nat.le_of_ble_eq_true PRE_first_tail_x15_r0_body.craise25, rfl⟩
noncomputable abbrev PRE_first_tail_x15_r0_body.cx0_25 : Host.Load.LSt := clearTokens (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s233.ffi)
noncomputable abbrev PRE_first_tail_x15_r0_body.cx1_25 : Host.Load.LSt := clearTokens (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s232.ffi)
def PRE_first_tail_x15_r0_body.khinv25 : PTrie Nat := Stage.setAll PTrie.nil []
def PRE_first_tail_x15_r0_body.kninv25 : PTrie Nat := Stage.setAll PTrie.nil []
/-- The stage's footprint: its written and fresh handles, fresh nodes, written and fresh items. -/
def PRE_first_tail_x15_r0_body.cwS25 : List Nat := []
def PRE_first_tail_x15_r0_body.cnS25 : List Nat := List.range' 15792 0
def PRE_first_tail_x15_r0_body.ciS25 : List Nat := [] ++ List.range' 15792 0

-- the small checks (`MChecks`'s)
kernel_rfl PRE_first_tail_x15_r0_body.cnh025 : PRE_first_tail_x15_r0_body.kd25.nh0 = PRE_first_tail_x15_r0_body.cx0_25.mlx.next
kernel_rfl PRE_first_tail_x15_r0_body.cnh125 : PRE_first_tail_x15_r0_body.kd25.nh1 = PRE_first_tail_x15_r0_body.cx1_25.mlx.next
kernel_rfl PRE_first_tail_x15_r0_body.cnn025 : PRE_first_tail_x15_r0_body.kd25.nn0 = PRE_first_tail_x15_r0_body.cx0_25.mlx.nnext
kernel_rfl PRE_first_tail_x15_r0_body.cnn125 : PRE_first_tail_x15_r0_body.kd25.nn1 = PRE_first_tail_x15_r0_body.cx1_25.mlx.nnext
kernel_rfl PRE_first_tail_x15_r0_body.cplo25 : (Nat.blt 0 PRE_first_tail_x15_r0_body.P25.lo && Nat.ble PRE_first_tail_x15_r0_body.P25.lo PRE_first_tail_x15_r0_body.cx0_25.mlx.next && Nat.ble PRE_first_tail_x15_r0_body.P25.lo RData.bigHi && Nat.ble RData.bigHi PRE_first_tail_x15_r0_body.P25.E) = true
kernel_rfl PRE_first_tail_x15_r0_body.ccnt25 : (Nat.ble PRE_first_tail_x15_r0_body.cx0_25.mlx.next PRE_first_tail_x15_r0_body.cx1_25.mlx.next && Nat.ble PRE_first_tail_x15_r0_body.cx0_25.mlx.nnext PRE_first_tail_x15_r0_body.cx1_25.mlx.nnext) = true
kernel_rfl PRE_first_tail_x15_r0_body.cnband25 : (Nat.blt 0 PRE_first_tail_x15_r0_body.P25.NL && Nat.ble PRE_first_tail_x15_r0_body.P25.NL PRE_first_tail_x15_r0_body.P25.N0 && Nat.ble PRE_first_tail_x15_r0_body.P25.N0 PRE_first_tail_x15_r0_body.cx0_25.mlx.nnext) = true
kernel_rfl PRE_first_tail_x15_r0_body.chbelow25 : PRE_first_tail_x15_r0_body.kd25.checkHndBelow = true
kernel_rfl PRE_first_tail_x15_r0_body.chren25 : checkRenG PRE_first_tail_x15_r0_body.kd25.hnd PRE_first_tail_x15_r0_body.khinv25 (phB PRE_first_tail_x15_r0_body.cx0_25.mlx) = true
kernel_rfl PRE_first_tail_x15_r0_body.cband25 : PRE_first_tail_x15_r0_body.kd25.checkBand PRE_first_tail_x15_r0_body.P25.lo = true
kernel_rfl PRE_first_tail_x15_r0_body.cnh1pos25 : Nat.blt 0 PRE_first_tail_x15_r0_body.kd25.nh1 = true
kernel_rfl PRE_first_tail_x15_r0_body.cnren25 : checkRenG PRE_first_tail_x15_r0_body.kd25.node PRE_first_tail_x15_r0_body.kninv25 (pnB PRE_first_tail_x15_r0_body.cx0_25.mlx) = true
kernel_rfl PRE_first_tail_x15_r0_body.cnlow25 : (PTrie.keysA PRE_first_tail_x15_r0_body.kd25.node).all (fun j => Nat.ble PRE_first_tail_x15_r0_body.P25.NL j && Nat.blt (PRE_first_tail_x15_r0_body.kd25.nodeF j) PRE_first_tail_x15_r0_body.cx1_25.mlx.nnext) = true
kernel_rfl PRE_first_tail_x15_r0_body.cabs0a25 : PRE_first_tail_x15_r0_body.cx0_25.mlx.arrs.get 0 = none
kernel_rfl PRE_first_tail_x15_r0_body.cabs0b25 : PRE_first_tail_x15_r0_body.cx0_25.mlx.objs.get 0 = none
kernel_rfl PRE_first_tail_x15_r0_body.ctok125 : PRE_first_tail_x15_r0_body.cx1_25.mlx.tokens = []
kernel_rfl PRE_first_tail_x15_r0_body.cpend25 : PRE_first_tail_x15_r0_body.cx1_25.mlx.pending = PRE_first_tail_x15_r0_body.cx0_25.mlx.pending.map PRE_first_tail_x15_r0_body.kappa25.pend
kernel_rfl PRE_first_tail_x15_r0_body.cerrh25 : PRE_first_tail_x15_r0_body.cx1_25.mlx.errh = PRE_first_tail_x15_r0_body.cx0_25.mlx.errh.map PRE_first_tail_x15_r0_body.kappa25.arg
kernel_rfl PRE_first_tail_x15_r0_body.cfiles25 : PRE_first_tail_x15_r0_body.cx1_25.mlx.files = PRE_first_tail_x15_r0_body.cx0_25.mlx.files
kernel_rfl PRE_first_tail_x15_r0_body.carch25 : PRE_first_tail_x15_r0_body.cx1_25.mlx.arch = PRE_first_tail_x15_r0_body.cx0_25.mlx.arch
kernel_rfl PRE_first_tail_x15_r0_body.csizes25 : PRE_first_tail_x15_r0_body.cx1_25.mlx.deviceSizes = PRE_first_tail_x15_r0_body.cx0_25.mlx.deviceSizes
kernel_rfl PRE_first_tail_x15_r0_body.cwired25 : PRE_first_tail_x15_r0_body.cx1_25.mlx.wired = PRE_first_tail_x15_r0_body.cx0_25.mlx.wired
kernel_rfl PRE_first_tail_x15_r0_body.chost25 : PRE_first_tail_x15_r0_body.cx1_25.host = PRE_first_tail_x15_r0_body.cx0_25.host
-- the compaction map's addresses are `PRE_first_tail_x15_r0_body.kd25`'s
kernel_rfl PRE_first_tail_x15_r0_body.ckn025 : PRE_first_tail_x15_r0_body.kd25.n0 = 2694783
kernel_rfl PRE_first_tail_x15_r0_body.ckn125 : PRE_first_tail_x15_r0_body.kd25.n1 = 2694785
kernel_rfl PRE_first_tail_x15_r0_body.ckheap25 : (PTrie.keysA PRE_first_tail_x15_r0_body.kd25.heap).all (fun x => Nat.ble 2694783 x) = true
kernel_rfl PRE_first_tail_x15_r0_body.ckpl25 : (List.range 0).all (fun j => decide (PRE_first_tail_x15_r0_body.kd25.heap.get (2694783 + j) = nth? PRE_first_tail_x15_r0_body.pl25 j)) = true
-- the map fixes the call's names (`Conv.fixOld_compact`), the call's counters
kernel_rfl PRE_first_tail_x15_r0_body.fja25 : Nat.ble 2694783 2694783 = true
kernel_rfl PRE_first_tail_x15_r0_body.fn25 : Nat.ble 1148 1148 = true
kernel_rfl PRE_first_tail_x15_r0_body.fjaD25 : Nat.ble 2694783 PRE_first_tail_x15_r0_body.kd25.n0 = true
kernel_rfl PRE_first_tail_x15_r0_body.fxn25 : Nat.ble 18704 PRE_first_tail_x15_r0_body.kd25.nh0 = true
kernel_rfl PRE_first_tail_x15_r0_body.fnn25 : Nat.ble 15792 PRE_first_tail_x15_r0_body.kd25.nn0 = true
kernel_rfl PRE_first_tail_x15_r0_body.fxb25 : Nat.ble 18704 RData.bigHi = true
kernel_rfl PRE_first_tail_x15_r0_body.fheap25 : (PTrie.keysA PRE_first_tail_x15_r0_body.kd25.heap).all (Nat.ble (⟨18704, 15792, 2694783, 1148⟩ : Conv.Cnt).ja) = true
kernel_rfl PRE_first_tail_x15_r0_body.fhnd25 : (PTrie.keysA PRE_first_tail_x15_r0_body.kd25.hnd).all (Nat.ble (⟨18704, 15792, 2694783, 1148⟩ : Conv.Cnt).xn) = true
kernel_rfl PRE_first_tail_x15_r0_body.fnode25 : (PTrie.keysA PRE_first_tail_x15_r0_body.kd25.node).all (Nat.ble (⟨18704, 15792, 2694783, 1148⟩ : Conv.Cnt).nn) = true
/-- The compaction map fixes the call's names. -/
theorem PRE_first_tail_x15_r0_body.cfix25 : Conv.FixOld (⟨18704, 15792, 2694783, 1148⟩ : Conv.Cnt) PRE_first_tail_x15_r0_body.kappa25 :=
  Conv.fixOld_compact (Nat.le_of_ble_eq_true PRE_first_tail_x15_r0_body.fja25) (Nat.le_of_ble_eq_true PRE_first_tail_x15_r0_body.fn25) (Nat.le_of_ble_eq_true PRE_first_tail_x15_r0_body.fjaD25) (Nat.le_of_ble_eq_true PRE_first_tail_x15_r0_body.fxn25) (Nat.le_of_ble_eq_true PRE_first_tail_x15_r0_body.fnn25) (Nat.le_of_ble_eq_true PRE_first_tail_x15_r0_body.fxb25) PRE_first_tail_x15_r0_body.fheap25 PRE_first_tail_x15_r0_body.fhnd25 PRE_first_tail_x15_r0_body.fnode25
kernel_rfl PRE_first_tail_x15_r0_body.fcxn25 : (⟨18704, 15792, 2694783, 1148⟩ : Conv.Cnt).xn = (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s231.ffi).mlx.next
kernel_rfl PRE_first_tail_x15_r0_body.fcnn25 : (⟨18704, 15792, 2694783, 1148⟩ : Conv.Cnt).nn = (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s231.ffi).mlx.nnext
kernel_rfl PRE_first_tail_x15_r0_body.fle025 : (Nat.ble (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s231.ffi).mlx.next PRE_first_tail_x15_r0_body.cx0_25.mlx.next && Nat.ble (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s231.ffi).mlx.nnext PRE_first_tail_x15_r0_body.cx0_25.mlx.nnext && Nat.ble (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s231.ffi).mlx.next RData.bigHi) = true
kernel_rfl PRE_first_tail_x15_r0_body.fnk25 : (PTrie.keysA PRE_first_tail_x15_r0_body.kd25.node).all (Nat.ble (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s231.ffi).mlx.nnext) = true
-- the merged state keeps the call's entries off the stage's footprint
kernel_rfl PRE_first_tail_x15_r0_body.f1A25 : PRE_first_tail_x15_r0_body.cx1_25.mlx.arrs = Stage.setAll (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s231.ffi).mlx.arrs (PRE_first_tail_x15_r0_body.cwS25.filterMap fun i => (PRE_first_tail_x15_r0_body.cx1_25.mlx.arrs.get i).map (i, ·))
kernel_rfl PRE_first_tail_x15_r0_body.f1O25 : PRE_first_tail_x15_r0_body.cx1_25.mlx.objs = Stage.setAll (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s231.ffi).mlx.objs (PRE_first_tail_x15_r0_body.cwS25.filterMap fun i => (PRE_first_tail_x15_r0_body.cx1_25.mlx.objs.get i).map (i, ·))
kernel_rfl PRE_first_tail_x15_r0_body.f1N25 : PRE_first_tail_x15_r0_body.cx1_25.mlx.nodes = Stage.setAll (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s231.ffi).mlx.nodes (PRE_first_tail_x15_r0_body.cnS25.filterMap fun i => (PRE_first_tail_x15_r0_body.cx1_25.mlx.nodes.get i).map (i, ·))
kernel_rfl PRE_first_tail_x15_r0_body.f1I25 : PRE_first_tail_x15_r0_body.cx1_25.mlx.items = Stage.setAll (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s231.ffi).mlx.items (PRE_first_tail_x15_r0_body.ciS25.filterMap fun i => (PRE_first_tail_x15_r0_body.cx1_25.mlx.items.get i).map (i, ·))
kernel_rfl PRE_first_tail_x15_r0_body.fbd25 : (PRE_first_tail_x15_r0_body.clo25 ++ PRE_first_tail_x15_r0_body.cln25 ++ PRE_first_tail_x15_r0_body.cli25 ++ PRE_first_tail_x15_r0_body.cwS25 ++ PRE_first_tail_x15_r0_body.cnS25 ++ PRE_first_tail_x15_r0_body.ciS25).all (fun i => Nat.blt (i / 4096) (4 ^ 31)) = true
kernel_rfl PRE_first_tail_x15_r0_body.fincW25 : PRE_first_tail_x15_r0_body.cwS25.all (fun h => !Nat.blt h (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s231.ffi).mlx.next || PRE_first_tail_x15_r0_body.clo25.contains h) = true
kernel_rfl PRE_first_tail_x15_r0_body.fincI25 : PRE_first_tail_x15_r0_body.ciS25.all (fun k => !Nat.blt k (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s231.ffi).mlx.nnext || PRE_first_tail_x15_r0_body.cli25.contains k) = true
kernel_rfl PRE_first_tail_x15_r0_body.fincN25 : PRE_first_tail_x15_r0_body.cnS25.all (Nat.ble (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s231.ffi).mlx.nnext) = true
kernel_rfl PRE_first_tail_x15_r0_body.flnF25 : PRE_first_tail_x15_r0_body.cln25.all (Nat.ble (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s231.ffi).mlx.nnext) = true
-- the checks over the changed lists
kernel_rfl PRE_first_tail_x15_r0_body.fh25 : PRE_first_tail_x15_r0_body.clo25.all (handleOK PRE_first_tail_x15_r0_body.kappa25 PRE_first_tail_x15_r0_body.P25.lo PRE_first_tail_x15_r0_body.cx0_25.mlx PRE_first_tail_x15_r0_body.cx1_25.mlx) = true
kernel_rfl PRE_first_tail_x15_r0_body.fo25 : PRE_first_tail_x15_r0_body.clo25.map (fun h => PRE_first_tail_x15_r0_body.cx1_25.mlx.objs.get (PRE_first_tail_x15_r0_body.kappa25.handle h)) = PRE_first_tail_x15_r0_body.clo25.map (fun h => (PRE_first_tail_x15_r0_body.cx0_25.mlx.objs.get h).map PRE_first_tail_x15_r0_body.kappa25.nobj)
kernel_rfl PRE_first_tail_x15_r0_body.fok25 : PRE_first_tail_x15_r0_body.clo25.all (objOK PRE_first_tail_x15_r0_body.kappa25 PRE_first_tail_x15_r0_body.P25.NL PRE_first_tail_x15_r0_body.cx0_25.mlx) = true
kernel_rfl PRE_first_tail_x15_r0_body.fnd25 : PRE_first_tail_x15_r0_body.cln25.all (nodeOKF PRE_first_tail_x15_r0_body.kappa25 PRE_first_tail_x15_r0_body.P25 PRE_first_tail_x15_r0_body.cx0_25.mlx PRE_first_tail_x15_r0_body.cx1_25.mlx) = true
kernel_rfl PRE_first_tail_x15_r0_body.fp25 : ((PRE_first_tail_x15_r0_body.cln25.filter (fullB PRE_first_tail_x15_r0_body.P25))).map (fun i => (PRE_first_tail_x15_r0_body.cx1_25.mlx.nodes.get (PRE_first_tail_x15_r0_body.kappa25.node i)).map Host.Mlx.Ffi.Node.prim) =
  ((PRE_first_tail_x15_r0_body.cln25.filter (fullB PRE_first_tail_x15_r0_body.P25))).map (fun i => (PRE_first_tail_x15_r0_body.cx0_25.mlx.nodes.get i).map fun nd => PRE_first_tail_x15_r0_body.kappa25.prim nd.prim)
kernel_rfl PRE_first_tail_x15_r0_body.fnordI25 : incrB PRE_first_tail_x15_r0_body.kd25.nodeF (List.range' 15792 0) = true
kernel_rfl PRE_first_tail_x15_r0_body.fnordK25 : (PTrie.keysA PRE_first_tail_x15_r0_body.kd25.node).all (fun k => Nat.ble 15792 k && Nat.blt k 15792) = true
kernel_rfl PRE_first_tail_x15_r0_body.fnordL25 : (PRE_first_tail_x15_r0_body.cln25.filter (Nat.ble PRE_first_tail_x15_r0_body.P25.N0)).all (fun i => Nat.ble i (PRE_first_tail_x15_r0_body.kd25.nodeF i) && (Nat.blt i 15792 || Nat.ble PRE_first_tail_x15_r0_body.kd25.nn0 i)) = true
theorem PRE_first_tail_x15_r0_body.fnord25 : (PRE_first_tail_x15_r0_body.cln25.filter (Nat.ble PRE_first_tail_x15_r0_body.P25.N0)).all (fun i => Nat.ble i (PRE_first_tail_x15_r0_body.kd25.nodeF i) &&
    (PTrie.keysA PRE_first_tail_x15_r0_body.kd25.node).all fun j => !Nat.blt j i || Nat.blt (PRE_first_tail_x15_r0_body.kd25.nodeF j) (PRE_first_tail_x15_r0_body.kd25.nodeF i)) = true :=
  cnord_of PRE_first_tail_x15_r0_body.cnlow25 PRE_first_tail_x15_r0_body.cnn125 PRE_first_tail_x15_r0_body.fnordI25 PRE_first_tail_x15_r0_body.fnordK25 PRE_first_tail_x15_r0_body.fnordL25
kernel_rfl PRE_first_tail_x15_r0_body.fi25 : PRE_first_tail_x15_r0_body.cli25.all (pnB PRE_first_tail_x15_r0_body.cx0_25.mlx) = true
kernel_rfl PRE_first_tail_x15_r0_body.fii25 : PRE_first_tail_x15_r0_body.cli25.all (fun k => decide (PRE_first_tail_x15_r0_body.cx1_25.mlx.items.get (PRE_first_tail_x15_r0_body.kappa25.node k) = (PRE_first_tail_x15_r0_body.cx0_25.mlx.items.get k).map PRE_first_tail_x15_r0_body.kappa25.nv)) = true
/-- **The compaction's footprint.** -/
theorem PRE_first_tail_x15_r0_body.cfoot25 (clean : Conv.NClean (⟨18704, 15792, 2694783, 1148⟩ : Conv.Cnt) (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s231.ffi).mlx) (hltC : ∀ h, PH (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s231.ffi).mlx h → h < (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s231.ffi).mlx.next) (nltC : ∀ i, PN (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s231.ffi).mlx i → i < (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s231.ffi).mlx.nnext) (itemsC : ∀ k v, (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s231.ffi).mlx.items.get k = some v → PN (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s231.ffi).mlx k) (tracedC : ∀ h o, (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s231.ffi).mlx.objs.get h = some o → ∀ i ∈ objTraces o, i < PRE_first_tail_x15_r0_body.P25.NL) (cl : SSt (· < 1148) PRE_first_tail_x15_r0_body.cx0_25.mlx) :
    Conv.MFoot PRE_first_tail_x15_r0_body.P25 1148 PRE_first_tail_x15_r0_body.kappa25 PRE_first_tail_x15_r0_body.kd25 PRE_first_tail_x15_r0_body.khinv25 PRE_first_tail_x15_r0_body.kninv25 (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s231.ffi).mlx PRE_first_tail_x15_r0_body.cx0_25.mlx PRE_first_tail_x15_r0_body.cx1_25.mlx (⟨18704, 15792, 2694783, 1148⟩ : Conv.Cnt) PRE_first_tail_x15_r0_body.clo25 PRE_first_tail_x15_r0_body.cln25 PRE_first_tail_x15_r0_body.cli25 PRE_first_tail_x15_r0_body.cwS25 PRE_first_tail_x15_r0_body.cnS25 PRE_first_tail_x15_r0_body.ciS25 :=
  ⟨rfl, rfl, rfl, PRE_first_tail_x15_r0_body.cnh025, PRE_first_tail_x15_r0_body.cnh125, PRE_first_tail_x15_r0_body.cnn025, PRE_first_tail_x15_r0_body.cnn125, PRE_first_tail_x15_r0_body.cplo25, PRE_first_tail_x15_r0_body.ccnt25, PRE_first_tail_x15_r0_body.cnband25, PRE_first_tail_x15_r0_body.chbelow25, PRE_first_tail_x15_r0_body.chren25, PRE_first_tail_x15_r0_body.cband25, PRE_first_tail_x15_r0_body.cnh1pos25, PRE_first_tail_x15_r0_body.cnren25, PRE_first_tail_x15_r0_body.cnlow25, PRE_first_tail_x15_r0_body.cabs0a25, PRE_first_tail_x15_r0_body.cabs0b25, PRE_first_tail_x15_r0_body.ctok125, PRE_first_tail_x15_r0_body.cpend25, PRE_first_tail_x15_r0_body.cerrh25, PRE_first_tail_x15_r0_body.cfiles25, PRE_first_tail_x15_r0_body.carch25, PRE_first_tail_x15_r0_body.csizes25, PRE_first_tail_x15_r0_body.cwired25, PRE_first_tail_x15_r0_body.cfix25, clean, PRE_first_tail_x15_r0_body.fcxn25, PRE_first_tail_x15_r0_body.fcnn25, hltC, nltC, itemsC, tracedC, cl, PRE_first_tail_x15_r0_body.fle025, PRE_first_tail_x15_r0_body.fnk25, PRE_first_tail_x15_r0_body.ckA25, PRE_first_tail_x15_r0_body.cobjsK25, PRE_first_tail_x15_r0_body.cnodesK25, PRE_first_tail_x15_r0_body.citemsK25, PRE_first_tail_x15_r0_body.f1A25, PRE_first_tail_x15_r0_body.f1O25, PRE_first_tail_x15_r0_body.f1N25, PRE_first_tail_x15_r0_body.f1I25, PRE_first_tail_x15_r0_body.fbd25, PRE_first_tail_x15_r0_body.fincW25, PRE_first_tail_x15_r0_body.fincI25, PRE_first_tail_x15_r0_body.fincN25, PRE_first_tail_x15_r0_body.flnF25, PRE_first_tail_x15_r0_body.fh25, PRE_first_tail_x15_r0_body.fo25, PRE_first_tail_x15_r0_body.fok25, PRE_first_tail_x15_r0_body.fnd25, PRE_first_tail_x15_r0_body.fp25, PRE_first_tail_x15_r0_body.fnord25, PRE_first_tail_x15_r0_body.fi25, PRE_first_tail_x15_r0_body.fii25⟩
theorem PRE_first_tail_x15_r0_body.cnshift25 (clean : Conv.NClean (⟨18704, 15792, 2694783, 1148⟩ : Conv.Cnt) (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s231.ffi).mlx) (hltC : ∀ h, PH (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s231.ffi).mlx h → h < (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s231.ffi).mlx.next) (nltC : ∀ i, PN (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s231.ffi).mlx i → i < (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s231.ffi).mlx.nnext) (itemsC : ∀ k v, (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s231.ffi).mlx.items.get k = some v → PN (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s231.ffi).mlx k) (tracedC : ∀ h o, (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s231.ffi).mlx.objs.get h = some o → ∀ i ∈ objTraces o, i < PRE_first_tail_x15_r0_body.P25.NL) (cl : SSt (· < 1148) PRE_first_tail_x15_r0_body.cx0_25.mlx) : NShift PRE_first_tail_x15_r0_body.P25 1148 PRE_first_tail_x15_r0_body.kappa25 PRE_first_tail_x15_r0_body.cx0_25 PRE_first_tail_x15_r0_body.cx1_25 :=
  Conv.nshift_of_foot (PRE_first_tail_x15_r0_body.cfoot25 clean hltC nltC itemsC tracedC cl) PRE_first_tail_x15_r0_body.chost25 (compact_a_eq PRE_first_tail_x15_r0_body.ckn025 PRE_first_tail_x15_r0_body.ckn125 PRE_first_tail_x15_r0_body.ckheap25 PRE_first_tail_x15_r0_body.ckpl25)

-- the observers: the layers' states at the call, the canonical and the merged state, their footprints and checks
noncomputable def PRE_first_tail_x15_r0_body.fxC_25 : PTrie Unit := (Host.Ts.Sim.Full.freedOf PRE_first_tail_x15_r0_body.s231.ffi).getD PTrie.nil
noncomputable def PRE_first_tail_x15_r0_body.krC_25 : Host.Load.Layers.KRec := (Host.Ts.Sim.Full.krecOf PRE_first_tail_x15_r0_body.s231.ffi).getD Host.Load.Layers.KRec.empty
kernel_rfl PRE_first_tail_x15_r0_body.ofxC_25 : (Host.Ts.Sim.Full.freedOf PRE_first_tail_x15_r0_body.s231.ffi) = some PRE_first_tail_x15_r0_body.fxC_25
kernel_rfl PRE_first_tail_x15_r0_body.okrC_25 : (Host.Ts.Sim.Full.krecOf PRE_first_tail_x15_r0_body.s231.ffi) = some PRE_first_tail_x15_r0_body.krC_25
noncomputable def PRE_first_tail_x15_r0_body.fx0_25 : PTrie Unit := (Host.Ts.Sim.Full.freedOf PRE_first_tail_x15_r0_body.s233.ffi).getD PTrie.nil
noncomputable def PRE_first_tail_x15_r0_body.kr0_25 : Host.Load.Layers.KRec := (Host.Ts.Sim.Full.krecOf PRE_first_tail_x15_r0_body.s233.ffi).getD Host.Load.Layers.KRec.empty
kernel_rfl PRE_first_tail_x15_r0_body.ofx0_25 : (Host.Ts.Sim.Full.freedOf PRE_first_tail_x15_r0_body.s233.ffi) = some PRE_first_tail_x15_r0_body.fx0_25
kernel_rfl PRE_first_tail_x15_r0_body.okr0_25 : (Host.Ts.Sim.Full.krecOf PRE_first_tail_x15_r0_body.s233.ffi) = some PRE_first_tail_x15_r0_body.kr0_25
noncomputable def PRE_first_tail_x15_r0_body.fx1_25 : PTrie Unit := (Host.Ts.Sim.Full.freedOf PRE_first_tail_x15_r0_body.s232.ffi).getD PTrie.nil
noncomputable def PRE_first_tail_x15_r0_body.kr1_25 : Host.Load.Layers.KRec := (Host.Ts.Sim.Full.krecOf PRE_first_tail_x15_r0_body.s232.ffi).getD Host.Load.Layers.KRec.empty
kernel_rfl PRE_first_tail_x15_r0_body.ofx1_25 : (Host.Ts.Sim.Full.freedOf PRE_first_tail_x15_r0_body.s232.ffi) = some PRE_first_tail_x15_r0_body.fx1_25
kernel_rfl PRE_first_tail_x15_r0_body.okr1_25 : (Host.Ts.Sim.Full.krecOf PRE_first_tail_x15_r0_body.s232.ffi) = some PRE_first_tail_x15_r0_body.kr1_25
kernel_rfl PRE_first_tail_x15_r0_body.ff025 : PRE_first_tail_x15_r0_body.fx0_25 = Stage.setAll PRE_first_tail_x15_r0_body.fxC_25 (PRE_first_tail_x15_r0_body.clo25.filterMap fun i => (PRE_first_tail_x15_r0_body.fx0_25.get i).map (i, ·))
kernel_rfl PRE_first_tail_x15_r0_body.ff125 : PRE_first_tail_x15_r0_body.fx1_25 = Stage.setAll PRE_first_tail_x15_r0_body.fxC_25 (PRE_first_tail_x15_r0_body.cwS25.filterMap fun i => (PRE_first_tail_x15_r0_body.fx1_25.get i).map (i, ·))
kernel_rfl PRE_first_tail_x15_r0_body.ffck25 : freedLB PRE_first_tail_x15_r0_body.kappa25 PRE_first_tail_x15_r0_body.cx0_25.mlx PRE_first_tail_x15_r0_body.fx0_25 PRE_first_tail_x15_r0_body.fx1_25 PRE_first_tail_x15_r0_body.clo25 = true
kernel_rfl PRE_first_tail_x15_r0_body.fkf025 : PRE_first_tail_x15_r0_body.kr0_25.flags = Stage.setAll PRE_first_tail_x15_r0_body.krC_25.flags (PRE_first_tail_x15_r0_body.clo25.filterMap fun i => (PRE_first_tail_x15_r0_body.kr0_25.flags.get i).map (i, ·))
kernel_rfl PRE_first_tail_x15_r0_body.fkt025 : PRE_first_tail_x15_r0_body.kr0_25.targs = Stage.setAll PRE_first_tail_x15_r0_body.krC_25.targs (PRE_first_tail_x15_r0_body.clo25.filterMap fun i => (PRE_first_tail_x15_r0_body.kr0_25.targs.get i).map (i, ·))
kernel_rfl PRE_first_tail_x15_r0_body.fkf125 : PRE_first_tail_x15_r0_body.kr1_25.flags = Stage.setAll PRE_first_tail_x15_r0_body.krC_25.flags (PRE_first_tail_x15_r0_body.cwS25.filterMap fun i => (PRE_first_tail_x15_r0_body.kr1_25.flags.get i).map (i, ·))
kernel_rfl PRE_first_tail_x15_r0_body.fkt125 : PRE_first_tail_x15_r0_body.kr1_25.targs = Stage.setAll PRE_first_tail_x15_r0_body.krC_25.targs (PRE_first_tail_x15_r0_body.cwS25.filterMap fun i => (PRE_first_tail_x15_r0_body.kr1_25.targs.get i).map (i, ·))
kernel_rfl PRE_first_tail_x15_r0_body.fkck25 : krecLB PRE_first_tail_x15_r0_body.kappa25 1148 PRE_first_tail_x15_r0_body.cx0_25.mlx PRE_first_tail_x15_r0_body.kr0_25 PRE_first_tail_x15_r0_body.kr1_25 PRE_first_tail_x15_r0_body.clo25 = true
kernel_rfl PRE_first_tail_x15_r0_body.fkn25 : Nat.ble 1148 1148 = true
-- the bridge and the pending traces' regions
kernel_rfl PRE_first_tail_x15_r0_body.cbridge25 : Host.Ts.Sim.Full.bridgeOf PRE_first_tail_x15_r0_body.s232.ffi = Host.Ts.Sim.Full.bridgeOf PRE_first_tail_x15_r0_body.s233.ffi
kernel_rfl PRE_first_tail_x15_r0_body.cpendR25 : pendRegB PRE_first_tail_x15_r0_body.kappa25 (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s233.ffi).mlx = true
kernel_rfl PRE_first_tail_x15_r0_body.cpendLe25 : Nat.ble (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s233.ffi).mlx.next (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s232.ffi).mlx.next = true
/-- **The compaction's native shift**, given the call's bookkeeping, its relation's facts (the model's and the
observers') and the canonical closedness. -/
theorem PRE_first_tail_x15_r0_body.cshift25 (clean : Conv.NClean (⟨18704, 15792, 2694783, 1148⟩ : Conv.Cnt) (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s231.ffi).mlx) (hltC : ∀ h, PH (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s231.ffi).mlx h → h < (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s231.ffi).mlx.next) (nltC : ∀ i, PN (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s231.ffi).mlx i → i < (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s231.ffi).mlx.nnext) (itemsC : ∀ k v, (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s231.ffi).mlx.items.get k = some v → PN (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s231.ffi).mlx k) (tracedC : ∀ h o, (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s231.ffi).mlx.objs.get h = some o → ∀ i ∈ objTraces o, i < PRE_first_tail_x15_r0_body.P25.NL) (cl : SSt (· < 1148) PRE_first_tail_x15_r0_body.cx0_25.mlx)
    (hobjC : ∀ h, PRE_first_tail_x15_r0_body.fxC_25.get h = some () → ((Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s231.ffi).mlx.objs.get h).isSome = true)
    (hfC : ∀ h, (PRE_first_tail_x15_r0_body.krC_25.flags.get h).isSome = true → ((Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s231.ffi).mlx.objs.get h).isSome = true)
    (htC : ∀ h, (PRE_first_tail_x15_r0_body.krC_25.targs.get h).isSome = true → ((Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s231.ffi).mlx.objs.get h).isSome = true)
    (hclC : ∀ h l, PRE_first_tail_x15_r0_body.krC_25.targs.get h = some l → Host.Ts.Sim.Full.STargs (· < (⟨18704, 15792, 2694783, 1148⟩ : Conv.Cnt).n) l) :
    Conv.FullShiftQ PRE_first_tail_x15_r0_body.P25 1148 PRE_first_tail_x15_r0_body.kappa25 PRE_first_tail_x15_r0_body.s233.ffi PRE_first_tail_x15_r0_body.s232.ffi :=
  ⟨PRE_first_tail_x15_r0_body.cnshift25 clean hltC nltC itemsC tracedC cl, PRE_first_tail_x15_r0_body.cqueue25, fun t ht => bSN_sound (List.all_eq_true.mp PRE_first_tail_x15_r0_body.ctokSupp25 t ht),
    PRE_first_tail_x15_r0_body.cbridge25,
    liveShift_foot (x0' := Host.Ts.Sim.Full.mlxOf PRE_first_tail_x15_r0_body.s233.ffi) (x1' := Host.Ts.Sim.Full.mlxOf PRE_first_tail_x15_r0_body.s232.ffi) (PRE_first_tail_x15_r0_body.cfoot25 clean hltC nltC itemsC tracedC cl) rfl PRE_first_tail_x15_r0_body.ofx0_25 PRE_first_tail_x15_r0_body.ofx1_25 hobjC PRE_first_tail_x15_r0_body.ff025 PRE_first_tail_x15_r0_body.ff125 PRE_first_tail_x15_r0_body.ffck25,
    kernShift_foot (x0' := Host.Ts.Sim.Full.mlxOf PRE_first_tail_x15_r0_body.s233.ffi) (x1' := Host.Ts.Sim.Full.mlxOf PRE_first_tail_x15_r0_body.s232.ffi) (PRE_first_tail_x15_r0_body.cfoot25 clean hltC nltC itemsC tracedC cl) rfl PRE_first_tail_x15_r0_body.okr0_25 PRE_first_tail_x15_r0_body.okr1_25 (Nat.le_of_ble_eq_true PRE_first_tail_x15_r0_body.fkn25) hfC htC hclC
      PRE_first_tail_x15_r0_body.fkf025 PRE_first_tail_x15_r0_body.fkt025 PRE_first_tail_x15_r0_body.fkf125 PRE_first_tail_x15_r0_body.fkt125 PRE_first_tail_x15_r0_body.fkck25,
    pendReg_of rfl PRE_first_tail_x15_r0_body.cnh025 PRE_first_tail_x15_r0_body.cnh125 (Nat.le_of_ble_eq_true PRE_first_tail_x15_r0_body.cpendLe25) PRE_first_tail_x15_r0_body.cpendR25⟩

end Host.Load.Run.Tpl
