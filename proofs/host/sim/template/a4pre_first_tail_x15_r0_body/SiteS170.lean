import host.sim.template.a4pre_first_tail_x15_r0_body.SiteCl170
import host.sim.conv.CompactFull
import host.sim.template.FootGen
set_option Elab.async false
namespace Host.Load.Run.Tpl
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
open Host.Ts Host.Ts.Sim Host.Ts.Sim.Template

/-! The compaction's native shift at call site 170 from its footprint (`Conv.nshift_of_foot`), and the observers'
(`liveShift_foot`, `kernShift_foot`): `Conv.FullShiftQ` for `Conv.full_compactQ`, given the call's bookkeeping and its
relation's facts. -/

/-- The load parameters of the chain (band-free: its start's node counter as `NL` and `N0`). -/
def PRE_first_tail_x15_r0_body.Pc170 : LoadP := ⟨18151, 131072, 1099511627776, 15235, 15235, []⟩
/-- The site's band raised to the map's checked fixed-node prefix, including newly recorded closure traces. -/
def PRE_first_tail_x15_r0_body.P170 : LoadP := PRE_first_tail_x15_r0_body.Pc170.raise 18640
kernel_rfl PRE_first_tail_x15_r0_body.craise170 : Nat.ble PRE_first_tail_x15_r0_body.Pc170.N0 18640 = true
theorem PRE_first_tail_x15_r0_body.raised170 : Host.Ts.Sim.Full.Raised PRE_first_tail_x15_r0_body.Pc170 PRE_first_tail_x15_r0_body.P170 :=
  .inr ⟨18640, rfl, Nat.le_of_ble_eq_true PRE_first_tail_x15_r0_body.craise170, rfl⟩
noncomputable abbrev PRE_first_tail_x15_r0_body.cx0_170 : Host.Load.LSt := clearTokens (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1497.ffi)
noncomputable abbrev PRE_first_tail_x15_r0_body.cx1_170 : Host.Load.LSt := clearTokens (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1496.ffi)
def PRE_first_tail_x15_r0_body.khinv170 : PTrie Nat := Stage.setAll PTrie.nil []
def PRE_first_tail_x15_r0_body.kninv170 : PTrie Nat := Stage.setAll PTrie.nil []
/-- The stage's footprint: its written and fresh handles, fresh nodes, written and fresh items. -/
def PRE_first_tail_x15_r0_body.cwS170 : List Nat := []
def PRE_first_tail_x15_r0_body.cnS170 : List Nat := List.range' 18640 0
def PRE_first_tail_x15_r0_body.ciS170 : List Nat := [] ++ List.range' 18640 0

-- the small checks (`MChecks`'s)
kernel_rfl PRE_first_tail_x15_r0_body.cnh0170 : PRE_first_tail_x15_r0_body.kd170.nh0 = PRE_first_tail_x15_r0_body.cx0_170.mlx.next
kernel_rfl PRE_first_tail_x15_r0_body.cnh1170 : PRE_first_tail_x15_r0_body.kd170.nh1 = PRE_first_tail_x15_r0_body.cx1_170.mlx.next
kernel_rfl PRE_first_tail_x15_r0_body.cnn0170 : PRE_first_tail_x15_r0_body.kd170.nn0 = PRE_first_tail_x15_r0_body.cx0_170.mlx.nnext
kernel_rfl PRE_first_tail_x15_r0_body.cnn1170 : PRE_first_tail_x15_r0_body.kd170.nn1 = PRE_first_tail_x15_r0_body.cx1_170.mlx.nnext
kernel_rfl PRE_first_tail_x15_r0_body.cplo170 : (Nat.blt 0 PRE_first_tail_x15_r0_body.P170.lo && Nat.ble PRE_first_tail_x15_r0_body.P170.lo PRE_first_tail_x15_r0_body.cx0_170.mlx.next && Nat.ble PRE_first_tail_x15_r0_body.P170.lo RData.bigHi && Nat.ble RData.bigHi PRE_first_tail_x15_r0_body.P170.E) = true
kernel_rfl PRE_first_tail_x15_r0_body.ccnt170 : (Nat.ble PRE_first_tail_x15_r0_body.cx0_170.mlx.next PRE_first_tail_x15_r0_body.cx1_170.mlx.next && Nat.ble PRE_first_tail_x15_r0_body.cx0_170.mlx.nnext PRE_first_tail_x15_r0_body.cx1_170.mlx.nnext) = true
kernel_rfl PRE_first_tail_x15_r0_body.cnband170 : (Nat.blt 0 PRE_first_tail_x15_r0_body.P170.NL && Nat.ble PRE_first_tail_x15_r0_body.P170.NL PRE_first_tail_x15_r0_body.P170.N0 && Nat.ble PRE_first_tail_x15_r0_body.P170.N0 PRE_first_tail_x15_r0_body.cx0_170.mlx.nnext) = true
kernel_rfl PRE_first_tail_x15_r0_body.chbelow170 : PRE_first_tail_x15_r0_body.kd170.checkHndBelow = true
kernel_rfl PRE_first_tail_x15_r0_body.chren170 : checkRenG PRE_first_tail_x15_r0_body.kd170.hnd PRE_first_tail_x15_r0_body.khinv170 (phB PRE_first_tail_x15_r0_body.cx0_170.mlx) = true
kernel_rfl PRE_first_tail_x15_r0_body.cband170 : PRE_first_tail_x15_r0_body.kd170.checkBand PRE_first_tail_x15_r0_body.P170.lo = true
kernel_rfl PRE_first_tail_x15_r0_body.cnh1pos170 : Nat.blt 0 PRE_first_tail_x15_r0_body.kd170.nh1 = true
kernel_rfl PRE_first_tail_x15_r0_body.cnren170 : checkRenG PRE_first_tail_x15_r0_body.kd170.node PRE_first_tail_x15_r0_body.kninv170 (pnB PRE_first_tail_x15_r0_body.cx0_170.mlx) = true
kernel_rfl PRE_first_tail_x15_r0_body.cnlow170 : (PTrie.keysA PRE_first_tail_x15_r0_body.kd170.node).all (fun j => Nat.ble PRE_first_tail_x15_r0_body.P170.NL j && Nat.blt (PRE_first_tail_x15_r0_body.kd170.nodeF j) PRE_first_tail_x15_r0_body.cx1_170.mlx.nnext) = true
kernel_rfl PRE_first_tail_x15_r0_body.cabs0a170 : PRE_first_tail_x15_r0_body.cx0_170.mlx.arrs.get 0 = none
kernel_rfl PRE_first_tail_x15_r0_body.cabs0b170 : PRE_first_tail_x15_r0_body.cx0_170.mlx.objs.get 0 = none
kernel_rfl PRE_first_tail_x15_r0_body.ctok1170 : PRE_first_tail_x15_r0_body.cx1_170.mlx.tokens = []
kernel_rfl PRE_first_tail_x15_r0_body.cpend170 : PRE_first_tail_x15_r0_body.cx1_170.mlx.pending = PRE_first_tail_x15_r0_body.cx0_170.mlx.pending.map PRE_first_tail_x15_r0_body.kappa170.pend
kernel_rfl PRE_first_tail_x15_r0_body.cerrh170 : PRE_first_tail_x15_r0_body.cx1_170.mlx.errh = PRE_first_tail_x15_r0_body.cx0_170.mlx.errh.map PRE_first_tail_x15_r0_body.kappa170.arg
kernel_rfl PRE_first_tail_x15_r0_body.cfiles170 : PRE_first_tail_x15_r0_body.cx1_170.mlx.files = PRE_first_tail_x15_r0_body.cx0_170.mlx.files
kernel_rfl PRE_first_tail_x15_r0_body.carch170 : PRE_first_tail_x15_r0_body.cx1_170.mlx.arch = PRE_first_tail_x15_r0_body.cx0_170.mlx.arch
kernel_rfl PRE_first_tail_x15_r0_body.csizes170 : PRE_first_tail_x15_r0_body.cx1_170.mlx.deviceSizes = PRE_first_tail_x15_r0_body.cx0_170.mlx.deviceSizes
kernel_rfl PRE_first_tail_x15_r0_body.cwired170 : PRE_first_tail_x15_r0_body.cx1_170.mlx.wired = PRE_first_tail_x15_r0_body.cx0_170.mlx.wired
kernel_rfl PRE_first_tail_x15_r0_body.chost170 : PRE_first_tail_x15_r0_body.cx1_170.host = PRE_first_tail_x15_r0_body.cx0_170.host
-- the compaction map's addresses are `PRE_first_tail_x15_r0_body.kd170`'s
kernel_rfl PRE_first_tail_x15_r0_body.ckn0170 : PRE_first_tail_x15_r0_body.kd170.n0 = 2808084
kernel_rfl PRE_first_tail_x15_r0_body.ckn1170 : PRE_first_tail_x15_r0_body.kd170.n1 = 2808103
kernel_rfl PRE_first_tail_x15_r0_body.ckheap170 : (PTrie.keysA PRE_first_tail_x15_r0_body.kd170.heap).all (fun x => Nat.ble 2808083 x) = true
kernel_rfl PRE_first_tail_x15_r0_body.ckpl170 : (List.range 1).all (fun j => decide (PRE_first_tail_x15_r0_body.kd170.heap.get (2808083 + j) = nth? PRE_first_tail_x15_r0_body.pl170 j)) = true
-- the map fixes the call's names (`Conv.fixOld_compact`), the call's counters
kernel_rfl PRE_first_tail_x15_r0_body.fja170 : Nat.ble 2808083 2808083 = true
kernel_rfl PRE_first_tail_x15_r0_body.fn170 : Nat.ble 7321 7321 = true
kernel_rfl PRE_first_tail_x15_r0_body.fjaD170 : Nat.ble 2808083 PRE_first_tail_x15_r0_body.kd170.n0 = true
kernel_rfl PRE_first_tail_x15_r0_body.fxn170 : Nat.ble 21543 PRE_first_tail_x15_r0_body.kd170.nh0 = true
kernel_rfl PRE_first_tail_x15_r0_body.fnn170 : Nat.ble 18640 PRE_first_tail_x15_r0_body.kd170.nn0 = true
kernel_rfl PRE_first_tail_x15_r0_body.fxb170 : Nat.ble 21543 RData.bigHi = true
kernel_rfl PRE_first_tail_x15_r0_body.fheap170 : (PTrie.keysA PRE_first_tail_x15_r0_body.kd170.heap).all (Nat.ble (⟨21543, 18640, 2808083, 7321⟩ : Conv.Cnt).ja) = true
kernel_rfl PRE_first_tail_x15_r0_body.fhnd170 : (PTrie.keysA PRE_first_tail_x15_r0_body.kd170.hnd).all (Nat.ble (⟨21543, 18640, 2808083, 7321⟩ : Conv.Cnt).xn) = true
kernel_rfl PRE_first_tail_x15_r0_body.fnode170 : (PTrie.keysA PRE_first_tail_x15_r0_body.kd170.node).all (Nat.ble (⟨21543, 18640, 2808083, 7321⟩ : Conv.Cnt).nn) = true
/-- The compaction map fixes the call's names. -/
theorem PRE_first_tail_x15_r0_body.cfix170 : Conv.FixOld (⟨21543, 18640, 2808083, 7321⟩ : Conv.Cnt) PRE_first_tail_x15_r0_body.kappa170 :=
  Conv.fixOld_compact (Nat.le_of_ble_eq_true PRE_first_tail_x15_r0_body.fja170) (Nat.le_of_ble_eq_true PRE_first_tail_x15_r0_body.fn170) (Nat.le_of_ble_eq_true PRE_first_tail_x15_r0_body.fjaD170) (Nat.le_of_ble_eq_true PRE_first_tail_x15_r0_body.fxn170) (Nat.le_of_ble_eq_true PRE_first_tail_x15_r0_body.fnn170) (Nat.le_of_ble_eq_true PRE_first_tail_x15_r0_body.fxb170) PRE_first_tail_x15_r0_body.fheap170 PRE_first_tail_x15_r0_body.fhnd170 PRE_first_tail_x15_r0_body.fnode170
kernel_rfl PRE_first_tail_x15_r0_body.fcxn170 : (⟨21543, 18640, 2808083, 7321⟩ : Conv.Cnt).xn = (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1495.ffi).mlx.next
kernel_rfl PRE_first_tail_x15_r0_body.fcnn170 : (⟨21543, 18640, 2808083, 7321⟩ : Conv.Cnt).nn = (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1495.ffi).mlx.nnext
kernel_rfl PRE_first_tail_x15_r0_body.fle0170 : (Nat.ble (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1495.ffi).mlx.next PRE_first_tail_x15_r0_body.cx0_170.mlx.next && Nat.ble (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1495.ffi).mlx.nnext PRE_first_tail_x15_r0_body.cx0_170.mlx.nnext && Nat.ble (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1495.ffi).mlx.next RData.bigHi) = true
kernel_rfl PRE_first_tail_x15_r0_body.fnk170 : (PTrie.keysA PRE_first_tail_x15_r0_body.kd170.node).all (Nat.ble (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1495.ffi).mlx.nnext) = true
-- the merged state keeps the call's entries off the stage's footprint
kernel_rfl PRE_first_tail_x15_r0_body.f1A170 : PRE_first_tail_x15_r0_body.cx1_170.mlx.arrs = Stage.setAll (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1495.ffi).mlx.arrs (PRE_first_tail_x15_r0_body.cwS170.filterMap fun i => (PRE_first_tail_x15_r0_body.cx1_170.mlx.arrs.get i).map (i, ·))
kernel_rfl PRE_first_tail_x15_r0_body.f1O170 : PRE_first_tail_x15_r0_body.cx1_170.mlx.objs = Stage.setAll (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1495.ffi).mlx.objs (PRE_first_tail_x15_r0_body.cwS170.filterMap fun i => (PRE_first_tail_x15_r0_body.cx1_170.mlx.objs.get i).map (i, ·))
kernel_rfl PRE_first_tail_x15_r0_body.f1N170 : PRE_first_tail_x15_r0_body.cx1_170.mlx.nodes = Stage.setAll (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1495.ffi).mlx.nodes (PRE_first_tail_x15_r0_body.cnS170.filterMap fun i => (PRE_first_tail_x15_r0_body.cx1_170.mlx.nodes.get i).map (i, ·))
kernel_rfl PRE_first_tail_x15_r0_body.f1I170 : PRE_first_tail_x15_r0_body.cx1_170.mlx.items = Stage.setAll (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1495.ffi).mlx.items (PRE_first_tail_x15_r0_body.ciS170.filterMap fun i => (PRE_first_tail_x15_r0_body.cx1_170.mlx.items.get i).map (i, ·))
kernel_rfl PRE_first_tail_x15_r0_body.fbd170 : (PRE_first_tail_x15_r0_body.clo170 ++ PRE_first_tail_x15_r0_body.cln170 ++ PRE_first_tail_x15_r0_body.cli170 ++ PRE_first_tail_x15_r0_body.cwS170 ++ PRE_first_tail_x15_r0_body.cnS170 ++ PRE_first_tail_x15_r0_body.ciS170).all (fun i => Nat.blt (i / 4096) (4 ^ 31)) = true
kernel_rfl PRE_first_tail_x15_r0_body.fincW170 : PRE_first_tail_x15_r0_body.cwS170.all (fun h => !Nat.blt h (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1495.ffi).mlx.next || PRE_first_tail_x15_r0_body.clo170.contains h) = true
kernel_rfl PRE_first_tail_x15_r0_body.fincI170 : PRE_first_tail_x15_r0_body.ciS170.all (fun k => !Nat.blt k (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1495.ffi).mlx.nnext || PRE_first_tail_x15_r0_body.cli170.contains k) = true
kernel_rfl PRE_first_tail_x15_r0_body.fincN170 : PRE_first_tail_x15_r0_body.cnS170.all (Nat.ble (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1495.ffi).mlx.nnext) = true
kernel_rfl PRE_first_tail_x15_r0_body.flnF170 : PRE_first_tail_x15_r0_body.cln170.all (Nat.ble (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1495.ffi).mlx.nnext) = true
-- the checks over the changed lists
kernel_rfl PRE_first_tail_x15_r0_body.fh170 : PRE_first_tail_x15_r0_body.clo170.all (handleOK PRE_first_tail_x15_r0_body.kappa170 PRE_first_tail_x15_r0_body.P170.lo PRE_first_tail_x15_r0_body.cx0_170.mlx PRE_first_tail_x15_r0_body.cx1_170.mlx) = true
kernel_rfl PRE_first_tail_x15_r0_body.fo170 : PRE_first_tail_x15_r0_body.clo170.map (fun h => PRE_first_tail_x15_r0_body.cx1_170.mlx.objs.get (PRE_first_tail_x15_r0_body.kappa170.handle h)) = PRE_first_tail_x15_r0_body.clo170.map (fun h => (PRE_first_tail_x15_r0_body.cx0_170.mlx.objs.get h).map PRE_first_tail_x15_r0_body.kappa170.nobj)
kernel_rfl PRE_first_tail_x15_r0_body.fok170 : PRE_first_tail_x15_r0_body.clo170.all (objOK PRE_first_tail_x15_r0_body.kappa170 PRE_first_tail_x15_r0_body.P170.NL PRE_first_tail_x15_r0_body.cx0_170.mlx) = true
kernel_rfl PRE_first_tail_x15_r0_body.fnd170 : PRE_first_tail_x15_r0_body.cln170.all (nodeOKF PRE_first_tail_x15_r0_body.kappa170 PRE_first_tail_x15_r0_body.P170 PRE_first_tail_x15_r0_body.cx0_170.mlx PRE_first_tail_x15_r0_body.cx1_170.mlx) = true
kernel_rfl PRE_first_tail_x15_r0_body.fp170 : ((PRE_first_tail_x15_r0_body.cln170.filter (fullB PRE_first_tail_x15_r0_body.P170))).map (fun i => (PRE_first_tail_x15_r0_body.cx1_170.mlx.nodes.get (PRE_first_tail_x15_r0_body.kappa170.node i)).map Host.Mlx.Ffi.Node.prim) =
  ((PRE_first_tail_x15_r0_body.cln170.filter (fullB PRE_first_tail_x15_r0_body.P170))).map (fun i => (PRE_first_tail_x15_r0_body.cx0_170.mlx.nodes.get i).map fun nd => PRE_first_tail_x15_r0_body.kappa170.prim nd.prim)
kernel_rfl PRE_first_tail_x15_r0_body.fnordI170 : incrB PRE_first_tail_x15_r0_body.kd170.nodeF (List.range' 18640 0) = true
kernel_rfl PRE_first_tail_x15_r0_body.fnordK170 : (PTrie.keysA PRE_first_tail_x15_r0_body.kd170.node).all (fun k => Nat.ble 18640 k && Nat.blt k 18640) = true
kernel_rfl PRE_first_tail_x15_r0_body.fnordL170 : (PRE_first_tail_x15_r0_body.cln170.filter (Nat.ble PRE_first_tail_x15_r0_body.P170.N0)).all (fun i => Nat.ble i (PRE_first_tail_x15_r0_body.kd170.nodeF i) && (Nat.blt i 18640 || Nat.ble PRE_first_tail_x15_r0_body.kd170.nn0 i)) = true
theorem PRE_first_tail_x15_r0_body.fnord170 : (PRE_first_tail_x15_r0_body.cln170.filter (Nat.ble PRE_first_tail_x15_r0_body.P170.N0)).all (fun i => Nat.ble i (PRE_first_tail_x15_r0_body.kd170.nodeF i) &&
    (PTrie.keysA PRE_first_tail_x15_r0_body.kd170.node).all fun j => !Nat.blt j i || Nat.blt (PRE_first_tail_x15_r0_body.kd170.nodeF j) (PRE_first_tail_x15_r0_body.kd170.nodeF i)) = true :=
  cnord_of PRE_first_tail_x15_r0_body.cnlow170 PRE_first_tail_x15_r0_body.cnn1170 PRE_first_tail_x15_r0_body.fnordI170 PRE_first_tail_x15_r0_body.fnordK170 PRE_first_tail_x15_r0_body.fnordL170
kernel_rfl PRE_first_tail_x15_r0_body.fi170 : PRE_first_tail_x15_r0_body.cli170.all (pnB PRE_first_tail_x15_r0_body.cx0_170.mlx) = true
kernel_rfl PRE_first_tail_x15_r0_body.fii170 : PRE_first_tail_x15_r0_body.cli170.all (fun k => decide (PRE_first_tail_x15_r0_body.cx1_170.mlx.items.get (PRE_first_tail_x15_r0_body.kappa170.node k) = (PRE_first_tail_x15_r0_body.cx0_170.mlx.items.get k).map PRE_first_tail_x15_r0_body.kappa170.nv)) = true
/-- **The compaction's footprint.** -/
theorem PRE_first_tail_x15_r0_body.cfoot170 (clean : Conv.NClean (⟨21543, 18640, 2808083, 7321⟩ : Conv.Cnt) (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1495.ffi).mlx) (hltC : ∀ h, PH (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1495.ffi).mlx h → h < (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1495.ffi).mlx.next) (nltC : ∀ i, PN (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1495.ffi).mlx i → i < (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1495.ffi).mlx.nnext) (itemsC : ∀ k v, (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1495.ffi).mlx.items.get k = some v → PN (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1495.ffi).mlx k) (tracedC : ∀ h o, (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1495.ffi).mlx.objs.get h = some o → ∀ i ∈ objTraces o, i < PRE_first_tail_x15_r0_body.P170.NL) (cl : SSt (· < 7321) PRE_first_tail_x15_r0_body.cx0_170.mlx) :
    Conv.MFoot PRE_first_tail_x15_r0_body.P170 7321 PRE_first_tail_x15_r0_body.kappa170 PRE_first_tail_x15_r0_body.kd170 PRE_first_tail_x15_r0_body.khinv170 PRE_first_tail_x15_r0_body.kninv170 (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1495.ffi).mlx PRE_first_tail_x15_r0_body.cx0_170.mlx PRE_first_tail_x15_r0_body.cx1_170.mlx (⟨21543, 18640, 2808083, 7321⟩ : Conv.Cnt) PRE_first_tail_x15_r0_body.clo170 PRE_first_tail_x15_r0_body.cln170 PRE_first_tail_x15_r0_body.cli170 PRE_first_tail_x15_r0_body.cwS170 PRE_first_tail_x15_r0_body.cnS170 PRE_first_tail_x15_r0_body.ciS170 :=
  ⟨rfl, rfl, rfl, PRE_first_tail_x15_r0_body.cnh0170, PRE_first_tail_x15_r0_body.cnh1170, PRE_first_tail_x15_r0_body.cnn0170, PRE_first_tail_x15_r0_body.cnn1170, PRE_first_tail_x15_r0_body.cplo170, PRE_first_tail_x15_r0_body.ccnt170, PRE_first_tail_x15_r0_body.cnband170, PRE_first_tail_x15_r0_body.chbelow170, PRE_first_tail_x15_r0_body.chren170, PRE_first_tail_x15_r0_body.cband170, PRE_first_tail_x15_r0_body.cnh1pos170, PRE_first_tail_x15_r0_body.cnren170, PRE_first_tail_x15_r0_body.cnlow170, PRE_first_tail_x15_r0_body.cabs0a170, PRE_first_tail_x15_r0_body.cabs0b170, PRE_first_tail_x15_r0_body.ctok1170, PRE_first_tail_x15_r0_body.cpend170, PRE_first_tail_x15_r0_body.cerrh170, PRE_first_tail_x15_r0_body.cfiles170, PRE_first_tail_x15_r0_body.carch170, PRE_first_tail_x15_r0_body.csizes170, PRE_first_tail_x15_r0_body.cwired170, PRE_first_tail_x15_r0_body.cfix170, clean, PRE_first_tail_x15_r0_body.fcxn170, PRE_first_tail_x15_r0_body.fcnn170, hltC, nltC, itemsC, tracedC, cl, PRE_first_tail_x15_r0_body.fle0170, PRE_first_tail_x15_r0_body.fnk170, PRE_first_tail_x15_r0_body.ckA170, PRE_first_tail_x15_r0_body.cobjsK170, PRE_first_tail_x15_r0_body.cnodesK170, PRE_first_tail_x15_r0_body.citemsK170, PRE_first_tail_x15_r0_body.f1A170, PRE_first_tail_x15_r0_body.f1O170, PRE_first_tail_x15_r0_body.f1N170, PRE_first_tail_x15_r0_body.f1I170, PRE_first_tail_x15_r0_body.fbd170, PRE_first_tail_x15_r0_body.fincW170, PRE_first_tail_x15_r0_body.fincI170, PRE_first_tail_x15_r0_body.fincN170, PRE_first_tail_x15_r0_body.flnF170, PRE_first_tail_x15_r0_body.fh170, PRE_first_tail_x15_r0_body.fo170, PRE_first_tail_x15_r0_body.fok170, PRE_first_tail_x15_r0_body.fnd170, PRE_first_tail_x15_r0_body.fp170, PRE_first_tail_x15_r0_body.fnord170, PRE_first_tail_x15_r0_body.fi170, PRE_first_tail_x15_r0_body.fii170⟩
theorem PRE_first_tail_x15_r0_body.cnshift170 (clean : Conv.NClean (⟨21543, 18640, 2808083, 7321⟩ : Conv.Cnt) (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1495.ffi).mlx) (hltC : ∀ h, PH (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1495.ffi).mlx h → h < (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1495.ffi).mlx.next) (nltC : ∀ i, PN (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1495.ffi).mlx i → i < (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1495.ffi).mlx.nnext) (itemsC : ∀ k v, (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1495.ffi).mlx.items.get k = some v → PN (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1495.ffi).mlx k) (tracedC : ∀ h o, (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1495.ffi).mlx.objs.get h = some o → ∀ i ∈ objTraces o, i < PRE_first_tail_x15_r0_body.P170.NL) (cl : SSt (· < 7321) PRE_first_tail_x15_r0_body.cx0_170.mlx) : NShift PRE_first_tail_x15_r0_body.P170 7321 PRE_first_tail_x15_r0_body.kappa170 PRE_first_tail_x15_r0_body.cx0_170 PRE_first_tail_x15_r0_body.cx1_170 :=
  Conv.nshift_of_foot (PRE_first_tail_x15_r0_body.cfoot170 clean hltC nltC itemsC tracedC cl) PRE_first_tail_x15_r0_body.chost170 (compact_a_eq PRE_first_tail_x15_r0_body.ckn0170 PRE_first_tail_x15_r0_body.ckn1170 PRE_first_tail_x15_r0_body.ckheap170 PRE_first_tail_x15_r0_body.ckpl170)

-- the observers: the layers' states at the call, the canonical and the merged state, their footprints and checks
noncomputable def PRE_first_tail_x15_r0_body.fxC_170 : PTrie Unit := (Host.Ts.Sim.Full.freedOf PRE_first_tail_x15_r0_body.s1495.ffi).getD PTrie.nil
noncomputable def PRE_first_tail_x15_r0_body.krC_170 : Host.Load.Layers.KRec := (Host.Ts.Sim.Full.krecOf PRE_first_tail_x15_r0_body.s1495.ffi).getD Host.Load.Layers.KRec.empty
kernel_rfl PRE_first_tail_x15_r0_body.ofxC_170 : (Host.Ts.Sim.Full.freedOf PRE_first_tail_x15_r0_body.s1495.ffi) = some PRE_first_tail_x15_r0_body.fxC_170
kernel_rfl PRE_first_tail_x15_r0_body.okrC_170 : (Host.Ts.Sim.Full.krecOf PRE_first_tail_x15_r0_body.s1495.ffi) = some PRE_first_tail_x15_r0_body.krC_170
noncomputable def PRE_first_tail_x15_r0_body.fx0_170 : PTrie Unit := (Host.Ts.Sim.Full.freedOf PRE_first_tail_x15_r0_body.s1497.ffi).getD PTrie.nil
noncomputable def PRE_first_tail_x15_r0_body.kr0_170 : Host.Load.Layers.KRec := (Host.Ts.Sim.Full.krecOf PRE_first_tail_x15_r0_body.s1497.ffi).getD Host.Load.Layers.KRec.empty
kernel_rfl PRE_first_tail_x15_r0_body.ofx0_170 : (Host.Ts.Sim.Full.freedOf PRE_first_tail_x15_r0_body.s1497.ffi) = some PRE_first_tail_x15_r0_body.fx0_170
kernel_rfl PRE_first_tail_x15_r0_body.okr0_170 : (Host.Ts.Sim.Full.krecOf PRE_first_tail_x15_r0_body.s1497.ffi) = some PRE_first_tail_x15_r0_body.kr0_170
noncomputable def PRE_first_tail_x15_r0_body.fx1_170 : PTrie Unit := (Host.Ts.Sim.Full.freedOf PRE_first_tail_x15_r0_body.s1496.ffi).getD PTrie.nil
noncomputable def PRE_first_tail_x15_r0_body.kr1_170 : Host.Load.Layers.KRec := (Host.Ts.Sim.Full.krecOf PRE_first_tail_x15_r0_body.s1496.ffi).getD Host.Load.Layers.KRec.empty
kernel_rfl PRE_first_tail_x15_r0_body.ofx1_170 : (Host.Ts.Sim.Full.freedOf PRE_first_tail_x15_r0_body.s1496.ffi) = some PRE_first_tail_x15_r0_body.fx1_170
kernel_rfl PRE_first_tail_x15_r0_body.okr1_170 : (Host.Ts.Sim.Full.krecOf PRE_first_tail_x15_r0_body.s1496.ffi) = some PRE_first_tail_x15_r0_body.kr1_170
kernel_rfl PRE_first_tail_x15_r0_body.ff0170 : PRE_first_tail_x15_r0_body.fx0_170 = Stage.setAll PRE_first_tail_x15_r0_body.fxC_170 (PRE_first_tail_x15_r0_body.clo170.filterMap fun i => (PRE_first_tail_x15_r0_body.fx0_170.get i).map (i, ·))
kernel_rfl PRE_first_tail_x15_r0_body.ff1170 : PRE_first_tail_x15_r0_body.fx1_170 = Stage.setAll PRE_first_tail_x15_r0_body.fxC_170 (PRE_first_tail_x15_r0_body.cwS170.filterMap fun i => (PRE_first_tail_x15_r0_body.fx1_170.get i).map (i, ·))
kernel_rfl PRE_first_tail_x15_r0_body.ffck170 : freedLB PRE_first_tail_x15_r0_body.kappa170 PRE_first_tail_x15_r0_body.cx0_170.mlx PRE_first_tail_x15_r0_body.fx0_170 PRE_first_tail_x15_r0_body.fx1_170 PRE_first_tail_x15_r0_body.clo170 = true
kernel_rfl PRE_first_tail_x15_r0_body.fkf0170 : PRE_first_tail_x15_r0_body.kr0_170.flags = Stage.setAll PRE_first_tail_x15_r0_body.krC_170.flags (PRE_first_tail_x15_r0_body.clo170.filterMap fun i => (PRE_first_tail_x15_r0_body.kr0_170.flags.get i).map (i, ·))
kernel_rfl PRE_first_tail_x15_r0_body.fkt0170 : PRE_first_tail_x15_r0_body.kr0_170.targs = Stage.setAll PRE_first_tail_x15_r0_body.krC_170.targs (PRE_first_tail_x15_r0_body.clo170.filterMap fun i => (PRE_first_tail_x15_r0_body.kr0_170.targs.get i).map (i, ·))
kernel_rfl PRE_first_tail_x15_r0_body.fkf1170 : PRE_first_tail_x15_r0_body.kr1_170.flags = Stage.setAll PRE_first_tail_x15_r0_body.krC_170.flags (PRE_first_tail_x15_r0_body.cwS170.filterMap fun i => (PRE_first_tail_x15_r0_body.kr1_170.flags.get i).map (i, ·))
kernel_rfl PRE_first_tail_x15_r0_body.fkt1170 : PRE_first_tail_x15_r0_body.kr1_170.targs = Stage.setAll PRE_first_tail_x15_r0_body.krC_170.targs (PRE_first_tail_x15_r0_body.cwS170.filterMap fun i => (PRE_first_tail_x15_r0_body.kr1_170.targs.get i).map (i, ·))
kernel_rfl PRE_first_tail_x15_r0_body.fkck170 : krecLB PRE_first_tail_x15_r0_body.kappa170 7321 PRE_first_tail_x15_r0_body.cx0_170.mlx PRE_first_tail_x15_r0_body.kr0_170 PRE_first_tail_x15_r0_body.kr1_170 PRE_first_tail_x15_r0_body.clo170 = true
kernel_rfl PRE_first_tail_x15_r0_body.fkn170 : Nat.ble 7321 7321 = true
-- the bridge and the pending traces' regions
kernel_rfl PRE_first_tail_x15_r0_body.cbridge170 : Host.Ts.Sim.Full.bridgeOf PRE_first_tail_x15_r0_body.s1496.ffi = Host.Ts.Sim.Full.bridgeOf PRE_first_tail_x15_r0_body.s1497.ffi
kernel_rfl PRE_first_tail_x15_r0_body.cpendR170 : pendRegB PRE_first_tail_x15_r0_body.kappa170 (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1497.ffi).mlx = true
kernel_rfl PRE_first_tail_x15_r0_body.cpendLe170 : Nat.ble (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1497.ffi).mlx.next (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1496.ffi).mlx.next = true
/-- **The compaction's native shift**, given the call's bookkeeping, its relation's facts (the model's and the
observers') and the canonical closedness. -/
theorem PRE_first_tail_x15_r0_body.cshift170 (clean : Conv.NClean (⟨21543, 18640, 2808083, 7321⟩ : Conv.Cnt) (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1495.ffi).mlx) (hltC : ∀ h, PH (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1495.ffi).mlx h → h < (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1495.ffi).mlx.next) (nltC : ∀ i, PN (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1495.ffi).mlx i → i < (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1495.ffi).mlx.nnext) (itemsC : ∀ k v, (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1495.ffi).mlx.items.get k = some v → PN (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1495.ffi).mlx k) (tracedC : ∀ h o, (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1495.ffi).mlx.objs.get h = some o → ∀ i ∈ objTraces o, i < PRE_first_tail_x15_r0_body.P170.NL) (cl : SSt (· < 7321) PRE_first_tail_x15_r0_body.cx0_170.mlx)
    (hobjC : ∀ h, PRE_first_tail_x15_r0_body.fxC_170.get h = some () → ((Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1495.ffi).mlx.objs.get h).isSome = true)
    (hfC : ∀ h, (PRE_first_tail_x15_r0_body.krC_170.flags.get h).isSome = true → ((Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1495.ffi).mlx.objs.get h).isSome = true)
    (htC : ∀ h, (PRE_first_tail_x15_r0_body.krC_170.targs.get h).isSome = true → ((Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1495.ffi).mlx.objs.get h).isSome = true)
    (hclC : ∀ h l, PRE_first_tail_x15_r0_body.krC_170.targs.get h = some l → Host.Ts.Sim.Full.STargs (· < (⟨21543, 18640, 2808083, 7321⟩ : Conv.Cnt).n) l) :
    Conv.FullShiftQ PRE_first_tail_x15_r0_body.P170 7321 PRE_first_tail_x15_r0_body.kappa170 PRE_first_tail_x15_r0_body.s1497.ffi PRE_first_tail_x15_r0_body.s1496.ffi :=
  ⟨PRE_first_tail_x15_r0_body.cnshift170 clean hltC nltC itemsC tracedC cl, PRE_first_tail_x15_r0_body.cqueue170, fun t ht => bSN_sound (List.all_eq_true.mp PRE_first_tail_x15_r0_body.ctokSupp170 t ht),
    PRE_first_tail_x15_r0_body.cbridge170,
    liveShift_foot (x0' := Host.Ts.Sim.Full.mlxOf PRE_first_tail_x15_r0_body.s1497.ffi) (x1' := Host.Ts.Sim.Full.mlxOf PRE_first_tail_x15_r0_body.s1496.ffi) (PRE_first_tail_x15_r0_body.cfoot170 clean hltC nltC itemsC tracedC cl) rfl PRE_first_tail_x15_r0_body.ofx0_170 PRE_first_tail_x15_r0_body.ofx1_170 hobjC PRE_first_tail_x15_r0_body.ff0170 PRE_first_tail_x15_r0_body.ff1170 PRE_first_tail_x15_r0_body.ffck170,
    kernShift_foot (x0' := Host.Ts.Sim.Full.mlxOf PRE_first_tail_x15_r0_body.s1497.ffi) (x1' := Host.Ts.Sim.Full.mlxOf PRE_first_tail_x15_r0_body.s1496.ffi) (PRE_first_tail_x15_r0_body.cfoot170 clean hltC nltC itemsC tracedC cl) rfl PRE_first_tail_x15_r0_body.okr0_170 PRE_first_tail_x15_r0_body.okr1_170 (Nat.le_of_ble_eq_true PRE_first_tail_x15_r0_body.fkn170) hfC htC hclC
      PRE_first_tail_x15_r0_body.fkf0170 PRE_first_tail_x15_r0_body.fkt0170 PRE_first_tail_x15_r0_body.fkf1170 PRE_first_tail_x15_r0_body.fkt1170 PRE_first_tail_x15_r0_body.fkck170,
    pendReg_of rfl PRE_first_tail_x15_r0_body.cnh0170 PRE_first_tail_x15_r0_body.cnh1170 (Nat.le_of_ble_eq_true PRE_first_tail_x15_r0_body.cpendLe170) PRE_first_tail_x15_r0_body.cpendR170⟩

end Host.Load.Run.Tpl
