import host.sim.template.a4pre_first_tail_x15_r0_body.SiteCl56
import host.sim.conv.CompactFull
import host.sim.template.FootGen
set_option Elab.async false
namespace Host.Load.Run.Tpl
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
open Host.Ts Host.Ts.Sim Host.Ts.Sim.Template

/-! The compaction's native shift at call site 56 from its footprint (`Conv.nshift_of_foot`), and the observers'
(`liveShift_foot`, `kernShift_foot`): `Conv.FullShiftQ` for `Conv.full_compactQ`, given the call's bookkeeping and its
relation's facts. -/

/-- The load parameters of the chain (band-free: its start's node counter as `NL` and `N0`). -/
def PRE_first_tail_x15_r0_body.Pc56 : LoadP := ⟨18151, 131072, 1099511627776, 15235, 15235, []⟩
/-- The site's band raised to the map's checked fixed-node prefix, including newly recorded closure traces. -/
def PRE_first_tail_x15_r0_body.P56 : LoadP := PRE_first_tail_x15_r0_body.Pc56.raise 16396
kernel_rfl PRE_first_tail_x15_r0_body.craise56 : Nat.ble PRE_first_tail_x15_r0_body.Pc56.N0 16396 = true
theorem PRE_first_tail_x15_r0_body.raised56 : Host.Ts.Sim.Full.Raised PRE_first_tail_x15_r0_body.Pc56 PRE_first_tail_x15_r0_body.P56 :=
  .inr ⟨16396, rfl, Nat.le_of_ble_eq_true PRE_first_tail_x15_r0_body.craise56, rfl⟩
noncomputable abbrev PRE_first_tail_x15_r0_body.cx0_56 : Host.Load.LSt := clearTokens (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s548.ffi)
noncomputable abbrev PRE_first_tail_x15_r0_body.cx1_56 : Host.Load.LSt := clearTokens (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s547.ffi)
def PRE_first_tail_x15_r0_body.khinv56 : PTrie Nat := Stage.setAll PTrie.nil []
def PRE_first_tail_x15_r0_body.kninv56 : PTrie Nat := Stage.setAll PTrie.nil []
/-- The stage's footprint: its written and fresh handles, fresh nodes, written and fresh items. -/
def PRE_first_tail_x15_r0_body.cwS56 : List Nat := []
def PRE_first_tail_x15_r0_body.cnS56 : List Nat := List.range' 16396 0
def PRE_first_tail_x15_r0_body.ciS56 : List Nat := [] ++ List.range' 16396 0

-- the small checks (`MChecks`'s)
kernel_rfl PRE_first_tail_x15_r0_body.cnh056 : PRE_first_tail_x15_r0_body.kd56.nh0 = PRE_first_tail_x15_r0_body.cx0_56.mlx.next
kernel_rfl PRE_first_tail_x15_r0_body.cnh156 : PRE_first_tail_x15_r0_body.kd56.nh1 = PRE_first_tail_x15_r0_body.cx1_56.mlx.next
kernel_rfl PRE_first_tail_x15_r0_body.cnn056 : PRE_first_tail_x15_r0_body.kd56.nn0 = PRE_first_tail_x15_r0_body.cx0_56.mlx.nnext
kernel_rfl PRE_first_tail_x15_r0_body.cnn156 : PRE_first_tail_x15_r0_body.kd56.nn1 = PRE_first_tail_x15_r0_body.cx1_56.mlx.nnext
kernel_rfl PRE_first_tail_x15_r0_body.cplo56 : (Nat.blt 0 PRE_first_tail_x15_r0_body.P56.lo && Nat.ble PRE_first_tail_x15_r0_body.P56.lo PRE_first_tail_x15_r0_body.cx0_56.mlx.next && Nat.ble PRE_first_tail_x15_r0_body.P56.lo RData.bigHi && Nat.ble RData.bigHi PRE_first_tail_x15_r0_body.P56.E) = true
kernel_rfl PRE_first_tail_x15_r0_body.ccnt56 : (Nat.ble PRE_first_tail_x15_r0_body.cx0_56.mlx.next PRE_first_tail_x15_r0_body.cx1_56.mlx.next && Nat.ble PRE_first_tail_x15_r0_body.cx0_56.mlx.nnext PRE_first_tail_x15_r0_body.cx1_56.mlx.nnext) = true
kernel_rfl PRE_first_tail_x15_r0_body.cnband56 : (Nat.blt 0 PRE_first_tail_x15_r0_body.P56.NL && Nat.ble PRE_first_tail_x15_r0_body.P56.NL PRE_first_tail_x15_r0_body.P56.N0 && Nat.ble PRE_first_tail_x15_r0_body.P56.N0 PRE_first_tail_x15_r0_body.cx0_56.mlx.nnext) = true
kernel_rfl PRE_first_tail_x15_r0_body.chbelow56 : PRE_first_tail_x15_r0_body.kd56.checkHndBelow = true
kernel_rfl PRE_first_tail_x15_r0_body.chren56 : checkRenG PRE_first_tail_x15_r0_body.kd56.hnd PRE_first_tail_x15_r0_body.khinv56 (phB PRE_first_tail_x15_r0_body.cx0_56.mlx) = true
kernel_rfl PRE_first_tail_x15_r0_body.cband56 : PRE_first_tail_x15_r0_body.kd56.checkBand PRE_first_tail_x15_r0_body.P56.lo = true
kernel_rfl PRE_first_tail_x15_r0_body.cnh1pos56 : Nat.blt 0 PRE_first_tail_x15_r0_body.kd56.nh1 = true
kernel_rfl PRE_first_tail_x15_r0_body.cnren56 : checkRenG PRE_first_tail_x15_r0_body.kd56.node PRE_first_tail_x15_r0_body.kninv56 (pnB PRE_first_tail_x15_r0_body.cx0_56.mlx) = true
kernel_rfl PRE_first_tail_x15_r0_body.cnlow56 : (PTrie.keysA PRE_first_tail_x15_r0_body.kd56.node).all (fun j => Nat.ble PRE_first_tail_x15_r0_body.P56.NL j && Nat.blt (PRE_first_tail_x15_r0_body.kd56.nodeF j) PRE_first_tail_x15_r0_body.cx1_56.mlx.nnext) = true
kernel_rfl PRE_first_tail_x15_r0_body.cabs0a56 : PRE_first_tail_x15_r0_body.cx0_56.mlx.arrs.get 0 = none
kernel_rfl PRE_first_tail_x15_r0_body.cabs0b56 : PRE_first_tail_x15_r0_body.cx0_56.mlx.objs.get 0 = none
kernel_rfl PRE_first_tail_x15_r0_body.ctok156 : PRE_first_tail_x15_r0_body.cx1_56.mlx.tokens = []
kernel_rfl PRE_first_tail_x15_r0_body.cpend56 : PRE_first_tail_x15_r0_body.cx1_56.mlx.pending = PRE_first_tail_x15_r0_body.cx0_56.mlx.pending.map PRE_first_tail_x15_r0_body.kappa56.pend
kernel_rfl PRE_first_tail_x15_r0_body.cerrh56 : PRE_first_tail_x15_r0_body.cx1_56.mlx.errh = PRE_first_tail_x15_r0_body.cx0_56.mlx.errh.map PRE_first_tail_x15_r0_body.kappa56.arg
kernel_rfl PRE_first_tail_x15_r0_body.cfiles56 : PRE_first_tail_x15_r0_body.cx1_56.mlx.files = PRE_first_tail_x15_r0_body.cx0_56.mlx.files
kernel_rfl PRE_first_tail_x15_r0_body.carch56 : PRE_first_tail_x15_r0_body.cx1_56.mlx.arch = PRE_first_tail_x15_r0_body.cx0_56.mlx.arch
kernel_rfl PRE_first_tail_x15_r0_body.csizes56 : PRE_first_tail_x15_r0_body.cx1_56.mlx.deviceSizes = PRE_first_tail_x15_r0_body.cx0_56.mlx.deviceSizes
kernel_rfl PRE_first_tail_x15_r0_body.cwired56 : PRE_first_tail_x15_r0_body.cx1_56.mlx.wired = PRE_first_tail_x15_r0_body.cx0_56.mlx.wired
kernel_rfl PRE_first_tail_x15_r0_body.chost56 : PRE_first_tail_x15_r0_body.cx1_56.host = PRE_first_tail_x15_r0_body.cx0_56.host
-- the compaction map's addresses are `PRE_first_tail_x15_r0_body.kd56`'s
kernel_rfl PRE_first_tail_x15_r0_body.ckn056 : PRE_first_tail_x15_r0_body.kd56.n0 = 2718428
kernel_rfl PRE_first_tail_x15_r0_body.ckn156 : PRE_first_tail_x15_r0_body.kd56.n1 = 2718447
kernel_rfl PRE_first_tail_x15_r0_body.ckheap56 : (PTrie.keysA PRE_first_tail_x15_r0_body.kd56.heap).all (fun x => Nat.ble 2718427 x) = true
kernel_rfl PRE_first_tail_x15_r0_body.ckpl56 : (List.range 1).all (fun j => decide (PRE_first_tail_x15_r0_body.kd56.heap.get (2718427 + j) = nth? PRE_first_tail_x15_r0_body.pl56 j)) = true
-- the map fixes the call's names (`Conv.fixOld_compact`), the call's counters
kernel_rfl PRE_first_tail_x15_r0_body.fja56 : Nat.ble 2718427 2718427 = true
kernel_rfl PRE_first_tail_x15_r0_body.fn56 : Nat.ble 2449 2449 = true
kernel_rfl PRE_first_tail_x15_r0_body.fjaD56 : Nat.ble 2718427 PRE_first_tail_x15_r0_body.kd56.n0 = true
kernel_rfl PRE_first_tail_x15_r0_body.fxn56 : Nat.ble 19297 PRE_first_tail_x15_r0_body.kd56.nh0 = true
kernel_rfl PRE_first_tail_x15_r0_body.fnn56 : Nat.ble 16396 PRE_first_tail_x15_r0_body.kd56.nn0 = true
kernel_rfl PRE_first_tail_x15_r0_body.fxb56 : Nat.ble 19297 RData.bigHi = true
kernel_rfl PRE_first_tail_x15_r0_body.fheap56 : (PTrie.keysA PRE_first_tail_x15_r0_body.kd56.heap).all (Nat.ble (⟨19297, 16396, 2718427, 2449⟩ : Conv.Cnt).ja) = true
kernel_rfl PRE_first_tail_x15_r0_body.fhnd56 : (PTrie.keysA PRE_first_tail_x15_r0_body.kd56.hnd).all (Nat.ble (⟨19297, 16396, 2718427, 2449⟩ : Conv.Cnt).xn) = true
kernel_rfl PRE_first_tail_x15_r0_body.fnode56 : (PTrie.keysA PRE_first_tail_x15_r0_body.kd56.node).all (Nat.ble (⟨19297, 16396, 2718427, 2449⟩ : Conv.Cnt).nn) = true
/-- The compaction map fixes the call's names. -/
theorem PRE_first_tail_x15_r0_body.cfix56 : Conv.FixOld (⟨19297, 16396, 2718427, 2449⟩ : Conv.Cnt) PRE_first_tail_x15_r0_body.kappa56 :=
  Conv.fixOld_compact (Nat.le_of_ble_eq_true PRE_first_tail_x15_r0_body.fja56) (Nat.le_of_ble_eq_true PRE_first_tail_x15_r0_body.fn56) (Nat.le_of_ble_eq_true PRE_first_tail_x15_r0_body.fjaD56) (Nat.le_of_ble_eq_true PRE_first_tail_x15_r0_body.fxn56) (Nat.le_of_ble_eq_true PRE_first_tail_x15_r0_body.fnn56) (Nat.le_of_ble_eq_true PRE_first_tail_x15_r0_body.fxb56) PRE_first_tail_x15_r0_body.fheap56 PRE_first_tail_x15_r0_body.fhnd56 PRE_first_tail_x15_r0_body.fnode56
kernel_rfl PRE_first_tail_x15_r0_body.fcxn56 : (⟨19297, 16396, 2718427, 2449⟩ : Conv.Cnt).xn = (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s546.ffi).mlx.next
kernel_rfl PRE_first_tail_x15_r0_body.fcnn56 : (⟨19297, 16396, 2718427, 2449⟩ : Conv.Cnt).nn = (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s546.ffi).mlx.nnext
kernel_rfl PRE_first_tail_x15_r0_body.fle056 : (Nat.ble (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s546.ffi).mlx.next PRE_first_tail_x15_r0_body.cx0_56.mlx.next && Nat.ble (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s546.ffi).mlx.nnext PRE_first_tail_x15_r0_body.cx0_56.mlx.nnext && Nat.ble (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s546.ffi).mlx.next RData.bigHi) = true
kernel_rfl PRE_first_tail_x15_r0_body.fnk56 : (PTrie.keysA PRE_first_tail_x15_r0_body.kd56.node).all (Nat.ble (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s546.ffi).mlx.nnext) = true
-- the merged state keeps the call's entries off the stage's footprint
kernel_rfl PRE_first_tail_x15_r0_body.f1A56 : PRE_first_tail_x15_r0_body.cx1_56.mlx.arrs = Stage.setAll (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s546.ffi).mlx.arrs (PRE_first_tail_x15_r0_body.cwS56.filterMap fun i => (PRE_first_tail_x15_r0_body.cx1_56.mlx.arrs.get i).map (i, ·))
kernel_rfl PRE_first_tail_x15_r0_body.f1O56 : PRE_first_tail_x15_r0_body.cx1_56.mlx.objs = Stage.setAll (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s546.ffi).mlx.objs (PRE_first_tail_x15_r0_body.cwS56.filterMap fun i => (PRE_first_tail_x15_r0_body.cx1_56.mlx.objs.get i).map (i, ·))
kernel_rfl PRE_first_tail_x15_r0_body.f1N56 : PRE_first_tail_x15_r0_body.cx1_56.mlx.nodes = Stage.setAll (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s546.ffi).mlx.nodes (PRE_first_tail_x15_r0_body.cnS56.filterMap fun i => (PRE_first_tail_x15_r0_body.cx1_56.mlx.nodes.get i).map (i, ·))
kernel_rfl PRE_first_tail_x15_r0_body.f1I56 : PRE_first_tail_x15_r0_body.cx1_56.mlx.items = Stage.setAll (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s546.ffi).mlx.items (PRE_first_tail_x15_r0_body.ciS56.filterMap fun i => (PRE_first_tail_x15_r0_body.cx1_56.mlx.items.get i).map (i, ·))
kernel_rfl PRE_first_tail_x15_r0_body.fbd56 : (PRE_first_tail_x15_r0_body.clo56 ++ PRE_first_tail_x15_r0_body.cln56 ++ PRE_first_tail_x15_r0_body.cli56 ++ PRE_first_tail_x15_r0_body.cwS56 ++ PRE_first_tail_x15_r0_body.cnS56 ++ PRE_first_tail_x15_r0_body.ciS56).all (fun i => Nat.blt (i / 4096) (4 ^ 31)) = true
kernel_rfl PRE_first_tail_x15_r0_body.fincW56 : PRE_first_tail_x15_r0_body.cwS56.all (fun h => !Nat.blt h (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s546.ffi).mlx.next || PRE_first_tail_x15_r0_body.clo56.contains h) = true
kernel_rfl PRE_first_tail_x15_r0_body.fincI56 : PRE_first_tail_x15_r0_body.ciS56.all (fun k => !Nat.blt k (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s546.ffi).mlx.nnext || PRE_first_tail_x15_r0_body.cli56.contains k) = true
kernel_rfl PRE_first_tail_x15_r0_body.fincN56 : PRE_first_tail_x15_r0_body.cnS56.all (Nat.ble (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s546.ffi).mlx.nnext) = true
kernel_rfl PRE_first_tail_x15_r0_body.flnF56 : PRE_first_tail_x15_r0_body.cln56.all (Nat.ble (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s546.ffi).mlx.nnext) = true
-- the checks over the changed lists
kernel_rfl PRE_first_tail_x15_r0_body.fh56 : PRE_first_tail_x15_r0_body.clo56.all (handleOK PRE_first_tail_x15_r0_body.kappa56 PRE_first_tail_x15_r0_body.P56.lo PRE_first_tail_x15_r0_body.cx0_56.mlx PRE_first_tail_x15_r0_body.cx1_56.mlx) = true
kernel_rfl PRE_first_tail_x15_r0_body.fo56 : PRE_first_tail_x15_r0_body.clo56.map (fun h => PRE_first_tail_x15_r0_body.cx1_56.mlx.objs.get (PRE_first_tail_x15_r0_body.kappa56.handle h)) = PRE_first_tail_x15_r0_body.clo56.map (fun h => (PRE_first_tail_x15_r0_body.cx0_56.mlx.objs.get h).map PRE_first_tail_x15_r0_body.kappa56.nobj)
kernel_rfl PRE_first_tail_x15_r0_body.fok56 : PRE_first_tail_x15_r0_body.clo56.all (objOK PRE_first_tail_x15_r0_body.kappa56 PRE_first_tail_x15_r0_body.P56.NL PRE_first_tail_x15_r0_body.cx0_56.mlx) = true
kernel_rfl PRE_first_tail_x15_r0_body.fnd56 : PRE_first_tail_x15_r0_body.cln56.all (nodeOKF PRE_first_tail_x15_r0_body.kappa56 PRE_first_tail_x15_r0_body.P56 PRE_first_tail_x15_r0_body.cx0_56.mlx PRE_first_tail_x15_r0_body.cx1_56.mlx) = true
kernel_rfl PRE_first_tail_x15_r0_body.fp56 : ((PRE_first_tail_x15_r0_body.cln56.filter (fullB PRE_first_tail_x15_r0_body.P56))).map (fun i => (PRE_first_tail_x15_r0_body.cx1_56.mlx.nodes.get (PRE_first_tail_x15_r0_body.kappa56.node i)).map Host.Mlx.Ffi.Node.prim) =
  ((PRE_first_tail_x15_r0_body.cln56.filter (fullB PRE_first_tail_x15_r0_body.P56))).map (fun i => (PRE_first_tail_x15_r0_body.cx0_56.mlx.nodes.get i).map fun nd => PRE_first_tail_x15_r0_body.kappa56.prim nd.prim)
kernel_rfl PRE_first_tail_x15_r0_body.fnordI56 : incrB PRE_first_tail_x15_r0_body.kd56.nodeF (List.range' 16396 0) = true
kernel_rfl PRE_first_tail_x15_r0_body.fnordK56 : (PTrie.keysA PRE_first_tail_x15_r0_body.kd56.node).all (fun k => Nat.ble 16396 k && Nat.blt k 16396) = true
kernel_rfl PRE_first_tail_x15_r0_body.fnordL56 : (PRE_first_tail_x15_r0_body.cln56.filter (Nat.ble PRE_first_tail_x15_r0_body.P56.N0)).all (fun i => Nat.ble i (PRE_first_tail_x15_r0_body.kd56.nodeF i) && (Nat.blt i 16396 || Nat.ble PRE_first_tail_x15_r0_body.kd56.nn0 i)) = true
theorem PRE_first_tail_x15_r0_body.fnord56 : (PRE_first_tail_x15_r0_body.cln56.filter (Nat.ble PRE_first_tail_x15_r0_body.P56.N0)).all (fun i => Nat.ble i (PRE_first_tail_x15_r0_body.kd56.nodeF i) &&
    (PTrie.keysA PRE_first_tail_x15_r0_body.kd56.node).all fun j => !Nat.blt j i || Nat.blt (PRE_first_tail_x15_r0_body.kd56.nodeF j) (PRE_first_tail_x15_r0_body.kd56.nodeF i)) = true :=
  cnord_of PRE_first_tail_x15_r0_body.cnlow56 PRE_first_tail_x15_r0_body.cnn156 PRE_first_tail_x15_r0_body.fnordI56 PRE_first_tail_x15_r0_body.fnordK56 PRE_first_tail_x15_r0_body.fnordL56
kernel_rfl PRE_first_tail_x15_r0_body.fi56 : PRE_first_tail_x15_r0_body.cli56.all (pnB PRE_first_tail_x15_r0_body.cx0_56.mlx) = true
kernel_rfl PRE_first_tail_x15_r0_body.fii56 : PRE_first_tail_x15_r0_body.cli56.all (fun k => decide (PRE_first_tail_x15_r0_body.cx1_56.mlx.items.get (PRE_first_tail_x15_r0_body.kappa56.node k) = (PRE_first_tail_x15_r0_body.cx0_56.mlx.items.get k).map PRE_first_tail_x15_r0_body.kappa56.nv)) = true
/-- **The compaction's footprint.** -/
theorem PRE_first_tail_x15_r0_body.cfoot56 (clean : Conv.NClean (⟨19297, 16396, 2718427, 2449⟩ : Conv.Cnt) (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s546.ffi).mlx) (hltC : ∀ h, PH (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s546.ffi).mlx h → h < (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s546.ffi).mlx.next) (nltC : ∀ i, PN (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s546.ffi).mlx i → i < (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s546.ffi).mlx.nnext) (itemsC : ∀ k v, (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s546.ffi).mlx.items.get k = some v → PN (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s546.ffi).mlx k) (tracedC : ∀ h o, (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s546.ffi).mlx.objs.get h = some o → ∀ i ∈ objTraces o, i < PRE_first_tail_x15_r0_body.P56.NL) (cl : SSt (· < 2449) PRE_first_tail_x15_r0_body.cx0_56.mlx) :
    Conv.MFoot PRE_first_tail_x15_r0_body.P56 2449 PRE_first_tail_x15_r0_body.kappa56 PRE_first_tail_x15_r0_body.kd56 PRE_first_tail_x15_r0_body.khinv56 PRE_first_tail_x15_r0_body.kninv56 (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s546.ffi).mlx PRE_first_tail_x15_r0_body.cx0_56.mlx PRE_first_tail_x15_r0_body.cx1_56.mlx (⟨19297, 16396, 2718427, 2449⟩ : Conv.Cnt) PRE_first_tail_x15_r0_body.clo56 PRE_first_tail_x15_r0_body.cln56 PRE_first_tail_x15_r0_body.cli56 PRE_first_tail_x15_r0_body.cwS56 PRE_first_tail_x15_r0_body.cnS56 PRE_first_tail_x15_r0_body.ciS56 :=
  ⟨rfl, rfl, rfl, PRE_first_tail_x15_r0_body.cnh056, PRE_first_tail_x15_r0_body.cnh156, PRE_first_tail_x15_r0_body.cnn056, PRE_first_tail_x15_r0_body.cnn156, PRE_first_tail_x15_r0_body.cplo56, PRE_first_tail_x15_r0_body.ccnt56, PRE_first_tail_x15_r0_body.cnband56, PRE_first_tail_x15_r0_body.chbelow56, PRE_first_tail_x15_r0_body.chren56, PRE_first_tail_x15_r0_body.cband56, PRE_first_tail_x15_r0_body.cnh1pos56, PRE_first_tail_x15_r0_body.cnren56, PRE_first_tail_x15_r0_body.cnlow56, PRE_first_tail_x15_r0_body.cabs0a56, PRE_first_tail_x15_r0_body.cabs0b56, PRE_first_tail_x15_r0_body.ctok156, PRE_first_tail_x15_r0_body.cpend56, PRE_first_tail_x15_r0_body.cerrh56, PRE_first_tail_x15_r0_body.cfiles56, PRE_first_tail_x15_r0_body.carch56, PRE_first_tail_x15_r0_body.csizes56, PRE_first_tail_x15_r0_body.cwired56, PRE_first_tail_x15_r0_body.cfix56, clean, PRE_first_tail_x15_r0_body.fcxn56, PRE_first_tail_x15_r0_body.fcnn56, hltC, nltC, itemsC, tracedC, cl, PRE_first_tail_x15_r0_body.fle056, PRE_first_tail_x15_r0_body.fnk56, PRE_first_tail_x15_r0_body.ckA56, PRE_first_tail_x15_r0_body.cobjsK56, PRE_first_tail_x15_r0_body.cnodesK56, PRE_first_tail_x15_r0_body.citemsK56, PRE_first_tail_x15_r0_body.f1A56, PRE_first_tail_x15_r0_body.f1O56, PRE_first_tail_x15_r0_body.f1N56, PRE_first_tail_x15_r0_body.f1I56, PRE_first_tail_x15_r0_body.fbd56, PRE_first_tail_x15_r0_body.fincW56, PRE_first_tail_x15_r0_body.fincI56, PRE_first_tail_x15_r0_body.fincN56, PRE_first_tail_x15_r0_body.flnF56, PRE_first_tail_x15_r0_body.fh56, PRE_first_tail_x15_r0_body.fo56, PRE_first_tail_x15_r0_body.fok56, PRE_first_tail_x15_r0_body.fnd56, PRE_first_tail_x15_r0_body.fp56, PRE_first_tail_x15_r0_body.fnord56, PRE_first_tail_x15_r0_body.fi56, PRE_first_tail_x15_r0_body.fii56⟩
theorem PRE_first_tail_x15_r0_body.cnshift56 (clean : Conv.NClean (⟨19297, 16396, 2718427, 2449⟩ : Conv.Cnt) (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s546.ffi).mlx) (hltC : ∀ h, PH (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s546.ffi).mlx h → h < (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s546.ffi).mlx.next) (nltC : ∀ i, PN (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s546.ffi).mlx i → i < (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s546.ffi).mlx.nnext) (itemsC : ∀ k v, (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s546.ffi).mlx.items.get k = some v → PN (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s546.ffi).mlx k) (tracedC : ∀ h o, (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s546.ffi).mlx.objs.get h = some o → ∀ i ∈ objTraces o, i < PRE_first_tail_x15_r0_body.P56.NL) (cl : SSt (· < 2449) PRE_first_tail_x15_r0_body.cx0_56.mlx) : NShift PRE_first_tail_x15_r0_body.P56 2449 PRE_first_tail_x15_r0_body.kappa56 PRE_first_tail_x15_r0_body.cx0_56 PRE_first_tail_x15_r0_body.cx1_56 :=
  Conv.nshift_of_foot (PRE_first_tail_x15_r0_body.cfoot56 clean hltC nltC itemsC tracedC cl) PRE_first_tail_x15_r0_body.chost56 (compact_a_eq PRE_first_tail_x15_r0_body.ckn056 PRE_first_tail_x15_r0_body.ckn156 PRE_first_tail_x15_r0_body.ckheap56 PRE_first_tail_x15_r0_body.ckpl56)

-- the observers: the layers' states at the call, the canonical and the merged state, their footprints and checks
noncomputable def PRE_first_tail_x15_r0_body.fxC_56 : PTrie Unit := (Host.Ts.Sim.Full.freedOf PRE_first_tail_x15_r0_body.s546.ffi).getD PTrie.nil
noncomputable def PRE_first_tail_x15_r0_body.krC_56 : Host.Load.Layers.KRec := (Host.Ts.Sim.Full.krecOf PRE_first_tail_x15_r0_body.s546.ffi).getD Host.Load.Layers.KRec.empty
kernel_rfl PRE_first_tail_x15_r0_body.ofxC_56 : (Host.Ts.Sim.Full.freedOf PRE_first_tail_x15_r0_body.s546.ffi) = some PRE_first_tail_x15_r0_body.fxC_56
kernel_rfl PRE_first_tail_x15_r0_body.okrC_56 : (Host.Ts.Sim.Full.krecOf PRE_first_tail_x15_r0_body.s546.ffi) = some PRE_first_tail_x15_r0_body.krC_56
noncomputable def PRE_first_tail_x15_r0_body.fx0_56 : PTrie Unit := (Host.Ts.Sim.Full.freedOf PRE_first_tail_x15_r0_body.s548.ffi).getD PTrie.nil
noncomputable def PRE_first_tail_x15_r0_body.kr0_56 : Host.Load.Layers.KRec := (Host.Ts.Sim.Full.krecOf PRE_first_tail_x15_r0_body.s548.ffi).getD Host.Load.Layers.KRec.empty
kernel_rfl PRE_first_tail_x15_r0_body.ofx0_56 : (Host.Ts.Sim.Full.freedOf PRE_first_tail_x15_r0_body.s548.ffi) = some PRE_first_tail_x15_r0_body.fx0_56
kernel_rfl PRE_first_tail_x15_r0_body.okr0_56 : (Host.Ts.Sim.Full.krecOf PRE_first_tail_x15_r0_body.s548.ffi) = some PRE_first_tail_x15_r0_body.kr0_56
noncomputable def PRE_first_tail_x15_r0_body.fx1_56 : PTrie Unit := (Host.Ts.Sim.Full.freedOf PRE_first_tail_x15_r0_body.s547.ffi).getD PTrie.nil
noncomputable def PRE_first_tail_x15_r0_body.kr1_56 : Host.Load.Layers.KRec := (Host.Ts.Sim.Full.krecOf PRE_first_tail_x15_r0_body.s547.ffi).getD Host.Load.Layers.KRec.empty
kernel_rfl PRE_first_tail_x15_r0_body.ofx1_56 : (Host.Ts.Sim.Full.freedOf PRE_first_tail_x15_r0_body.s547.ffi) = some PRE_first_tail_x15_r0_body.fx1_56
kernel_rfl PRE_first_tail_x15_r0_body.okr1_56 : (Host.Ts.Sim.Full.krecOf PRE_first_tail_x15_r0_body.s547.ffi) = some PRE_first_tail_x15_r0_body.kr1_56
kernel_rfl PRE_first_tail_x15_r0_body.ff056 : PRE_first_tail_x15_r0_body.fx0_56 = Stage.setAll PRE_first_tail_x15_r0_body.fxC_56 (PRE_first_tail_x15_r0_body.clo56.filterMap fun i => (PRE_first_tail_x15_r0_body.fx0_56.get i).map (i, ·))
kernel_rfl PRE_first_tail_x15_r0_body.ff156 : PRE_first_tail_x15_r0_body.fx1_56 = Stage.setAll PRE_first_tail_x15_r0_body.fxC_56 (PRE_first_tail_x15_r0_body.cwS56.filterMap fun i => (PRE_first_tail_x15_r0_body.fx1_56.get i).map (i, ·))
kernel_rfl PRE_first_tail_x15_r0_body.ffck56 : freedLB PRE_first_tail_x15_r0_body.kappa56 PRE_first_tail_x15_r0_body.cx0_56.mlx PRE_first_tail_x15_r0_body.fx0_56 PRE_first_tail_x15_r0_body.fx1_56 PRE_first_tail_x15_r0_body.clo56 = true
kernel_rfl PRE_first_tail_x15_r0_body.fkf056 : PRE_first_tail_x15_r0_body.kr0_56.flags = Stage.setAll PRE_first_tail_x15_r0_body.krC_56.flags (PRE_first_tail_x15_r0_body.clo56.filterMap fun i => (PRE_first_tail_x15_r0_body.kr0_56.flags.get i).map (i, ·))
kernel_rfl PRE_first_tail_x15_r0_body.fkt056 : PRE_first_tail_x15_r0_body.kr0_56.targs = Stage.setAll PRE_first_tail_x15_r0_body.krC_56.targs (PRE_first_tail_x15_r0_body.clo56.filterMap fun i => (PRE_first_tail_x15_r0_body.kr0_56.targs.get i).map (i, ·))
kernel_rfl PRE_first_tail_x15_r0_body.fkf156 : PRE_first_tail_x15_r0_body.kr1_56.flags = Stage.setAll PRE_first_tail_x15_r0_body.krC_56.flags (PRE_first_tail_x15_r0_body.cwS56.filterMap fun i => (PRE_first_tail_x15_r0_body.kr1_56.flags.get i).map (i, ·))
kernel_rfl PRE_first_tail_x15_r0_body.fkt156 : PRE_first_tail_x15_r0_body.kr1_56.targs = Stage.setAll PRE_first_tail_x15_r0_body.krC_56.targs (PRE_first_tail_x15_r0_body.cwS56.filterMap fun i => (PRE_first_tail_x15_r0_body.kr1_56.targs.get i).map (i, ·))
kernel_rfl PRE_first_tail_x15_r0_body.fkck56 : krecLB PRE_first_tail_x15_r0_body.kappa56 2449 PRE_first_tail_x15_r0_body.cx0_56.mlx PRE_first_tail_x15_r0_body.kr0_56 PRE_first_tail_x15_r0_body.kr1_56 PRE_first_tail_x15_r0_body.clo56 = true
kernel_rfl PRE_first_tail_x15_r0_body.fkn56 : Nat.ble 2449 2449 = true
-- the bridge and the pending traces' regions
kernel_rfl PRE_first_tail_x15_r0_body.cbridge56 : Host.Ts.Sim.Full.bridgeOf PRE_first_tail_x15_r0_body.s547.ffi = Host.Ts.Sim.Full.bridgeOf PRE_first_tail_x15_r0_body.s548.ffi
kernel_rfl PRE_first_tail_x15_r0_body.cpendR56 : pendRegB PRE_first_tail_x15_r0_body.kappa56 (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s548.ffi).mlx = true
kernel_rfl PRE_first_tail_x15_r0_body.cpendLe56 : Nat.ble (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s548.ffi).mlx.next (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s547.ffi).mlx.next = true
/-- **The compaction's native shift**, given the call's bookkeeping, its relation's facts (the model's and the
observers') and the canonical closedness. -/
theorem PRE_first_tail_x15_r0_body.cshift56 (clean : Conv.NClean (⟨19297, 16396, 2718427, 2449⟩ : Conv.Cnt) (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s546.ffi).mlx) (hltC : ∀ h, PH (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s546.ffi).mlx h → h < (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s546.ffi).mlx.next) (nltC : ∀ i, PN (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s546.ffi).mlx i → i < (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s546.ffi).mlx.nnext) (itemsC : ∀ k v, (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s546.ffi).mlx.items.get k = some v → PN (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s546.ffi).mlx k) (tracedC : ∀ h o, (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s546.ffi).mlx.objs.get h = some o → ∀ i ∈ objTraces o, i < PRE_first_tail_x15_r0_body.P56.NL) (cl : SSt (· < 2449) PRE_first_tail_x15_r0_body.cx0_56.mlx)
    (hobjC : ∀ h, PRE_first_tail_x15_r0_body.fxC_56.get h = some () → ((Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s546.ffi).mlx.objs.get h).isSome = true)
    (hfC : ∀ h, (PRE_first_tail_x15_r0_body.krC_56.flags.get h).isSome = true → ((Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s546.ffi).mlx.objs.get h).isSome = true)
    (htC : ∀ h, (PRE_first_tail_x15_r0_body.krC_56.targs.get h).isSome = true → ((Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s546.ffi).mlx.objs.get h).isSome = true)
    (hclC : ∀ h l, PRE_first_tail_x15_r0_body.krC_56.targs.get h = some l → Host.Ts.Sim.Full.STargs (· < (⟨19297, 16396, 2718427, 2449⟩ : Conv.Cnt).n) l) :
    Conv.FullShiftQ PRE_first_tail_x15_r0_body.P56 2449 PRE_first_tail_x15_r0_body.kappa56 PRE_first_tail_x15_r0_body.s548.ffi PRE_first_tail_x15_r0_body.s547.ffi :=
  ⟨PRE_first_tail_x15_r0_body.cnshift56 clean hltC nltC itemsC tracedC cl, PRE_first_tail_x15_r0_body.cqueue56, fun t ht => bSN_sound (List.all_eq_true.mp PRE_first_tail_x15_r0_body.ctokSupp56 t ht),
    PRE_first_tail_x15_r0_body.cbridge56,
    liveShift_foot (x0' := Host.Ts.Sim.Full.mlxOf PRE_first_tail_x15_r0_body.s548.ffi) (x1' := Host.Ts.Sim.Full.mlxOf PRE_first_tail_x15_r0_body.s547.ffi) (PRE_first_tail_x15_r0_body.cfoot56 clean hltC nltC itemsC tracedC cl) rfl PRE_first_tail_x15_r0_body.ofx0_56 PRE_first_tail_x15_r0_body.ofx1_56 hobjC PRE_first_tail_x15_r0_body.ff056 PRE_first_tail_x15_r0_body.ff156 PRE_first_tail_x15_r0_body.ffck56,
    kernShift_foot (x0' := Host.Ts.Sim.Full.mlxOf PRE_first_tail_x15_r0_body.s548.ffi) (x1' := Host.Ts.Sim.Full.mlxOf PRE_first_tail_x15_r0_body.s547.ffi) (PRE_first_tail_x15_r0_body.cfoot56 clean hltC nltC itemsC tracedC cl) rfl PRE_first_tail_x15_r0_body.okr0_56 PRE_first_tail_x15_r0_body.okr1_56 (Nat.le_of_ble_eq_true PRE_first_tail_x15_r0_body.fkn56) hfC htC hclC
      PRE_first_tail_x15_r0_body.fkf056 PRE_first_tail_x15_r0_body.fkt056 PRE_first_tail_x15_r0_body.fkf156 PRE_first_tail_x15_r0_body.fkt156 PRE_first_tail_x15_r0_body.fkck56,
    pendReg_of rfl PRE_first_tail_x15_r0_body.cnh056 PRE_first_tail_x15_r0_body.cnh156 (Nat.le_of_ble_eq_true PRE_first_tail_x15_r0_body.cpendLe56) PRE_first_tail_x15_r0_body.cpendR56⟩

end Host.Load.Run.Tpl
