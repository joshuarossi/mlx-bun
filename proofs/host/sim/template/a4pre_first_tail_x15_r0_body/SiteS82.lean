import host.sim.template.a4pre_first_tail_x15_r0_body.SiteCl82
import host.sim.conv.CompactFull
import host.sim.template.FootGen
set_option Elab.async false
namespace Host.Load.Run.Tpl
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
open Host.Ts Host.Ts.Sim Host.Ts.Sim.Template

/-! The compaction's native shift at call site 82 from its footprint (`Conv.nshift_of_foot`), and the observers'
(`liveShift_foot`, `kernShift_foot`): `Conv.FullShiftQ` for `Conv.full_compactQ`, given the call's bookkeeping and its
relation's facts. -/

/-- The load parameters of the chain (band-free: its start's node counter as `NL` and `N0`). -/
def PRE_first_tail_x15_r0_body.Pc82 : LoadP := ⟨18151, 131072, 1099511627776, 15235, 15235, []⟩
/-- The site's band raised to the map's checked fixed-node prefix, including newly recorded closure traces. -/
def PRE_first_tail_x15_r0_body.P82 : LoadP := PRE_first_tail_x15_r0_body.Pc82.raise 16914
kernel_rfl PRE_first_tail_x15_r0_body.craise82 : Nat.ble PRE_first_tail_x15_r0_body.Pc82.N0 16914 = true
theorem PRE_first_tail_x15_r0_body.raised82 : Host.Ts.Sim.Full.Raised PRE_first_tail_x15_r0_body.Pc82 PRE_first_tail_x15_r0_body.P82 :=
  .inr ⟨16914, rfl, Nat.le_of_ble_eq_true PRE_first_tail_x15_r0_body.craise82, rfl⟩
noncomputable abbrev PRE_first_tail_x15_r0_body.cx0_82 : Host.Load.LSt := clearTokens (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s802.ffi)
noncomputable abbrev PRE_first_tail_x15_r0_body.cx1_82 : Host.Load.LSt := clearTokens (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s801.ffi)
def PRE_first_tail_x15_r0_body.khinv82 : PTrie Nat := Stage.setAll PTrie.nil []
def PRE_first_tail_x15_r0_body.kninv82 : PTrie Nat := Stage.setAll PTrie.nil []
/-- The stage's footprint: its written and fresh handles, fresh nodes, written and fresh items. -/
def PRE_first_tail_x15_r0_body.cwS82 : List Nat := []
def PRE_first_tail_x15_r0_body.cnS82 : List Nat := List.range' 16914 0
def PRE_first_tail_x15_r0_body.ciS82 : List Nat := [] ++ List.range' 16914 0

-- the small checks (`MChecks`'s)
kernel_rfl PRE_first_tail_x15_r0_body.cnh082 : PRE_first_tail_x15_r0_body.kd82.nh0 = PRE_first_tail_x15_r0_body.cx0_82.mlx.next
kernel_rfl PRE_first_tail_x15_r0_body.cnh182 : PRE_first_tail_x15_r0_body.kd82.nh1 = PRE_first_tail_x15_r0_body.cx1_82.mlx.next
kernel_rfl PRE_first_tail_x15_r0_body.cnn082 : PRE_first_tail_x15_r0_body.kd82.nn0 = PRE_first_tail_x15_r0_body.cx0_82.mlx.nnext
kernel_rfl PRE_first_tail_x15_r0_body.cnn182 : PRE_first_tail_x15_r0_body.kd82.nn1 = PRE_first_tail_x15_r0_body.cx1_82.mlx.nnext
kernel_rfl PRE_first_tail_x15_r0_body.cplo82 : (Nat.blt 0 PRE_first_tail_x15_r0_body.P82.lo && Nat.ble PRE_first_tail_x15_r0_body.P82.lo PRE_first_tail_x15_r0_body.cx0_82.mlx.next && Nat.ble PRE_first_tail_x15_r0_body.P82.lo RData.bigHi && Nat.ble RData.bigHi PRE_first_tail_x15_r0_body.P82.E) = true
kernel_rfl PRE_first_tail_x15_r0_body.ccnt82 : (Nat.ble PRE_first_tail_x15_r0_body.cx0_82.mlx.next PRE_first_tail_x15_r0_body.cx1_82.mlx.next && Nat.ble PRE_first_tail_x15_r0_body.cx0_82.mlx.nnext PRE_first_tail_x15_r0_body.cx1_82.mlx.nnext) = true
kernel_rfl PRE_first_tail_x15_r0_body.cnband82 : (Nat.blt 0 PRE_first_tail_x15_r0_body.P82.NL && Nat.ble PRE_first_tail_x15_r0_body.P82.NL PRE_first_tail_x15_r0_body.P82.N0 && Nat.ble PRE_first_tail_x15_r0_body.P82.N0 PRE_first_tail_x15_r0_body.cx0_82.mlx.nnext) = true
kernel_rfl PRE_first_tail_x15_r0_body.chbelow82 : PRE_first_tail_x15_r0_body.kd82.checkHndBelow = true
kernel_rfl PRE_first_tail_x15_r0_body.chren82 : checkRenG PRE_first_tail_x15_r0_body.kd82.hnd PRE_first_tail_x15_r0_body.khinv82 (phB PRE_first_tail_x15_r0_body.cx0_82.mlx) = true
kernel_rfl PRE_first_tail_x15_r0_body.cband82 : PRE_first_tail_x15_r0_body.kd82.checkBand PRE_first_tail_x15_r0_body.P82.lo = true
kernel_rfl PRE_first_tail_x15_r0_body.cnh1pos82 : Nat.blt 0 PRE_first_tail_x15_r0_body.kd82.nh1 = true
kernel_rfl PRE_first_tail_x15_r0_body.cnren82 : checkRenG PRE_first_tail_x15_r0_body.kd82.node PRE_first_tail_x15_r0_body.kninv82 (pnB PRE_first_tail_x15_r0_body.cx0_82.mlx) = true
kernel_rfl PRE_first_tail_x15_r0_body.cnlow82 : (PTrie.keysA PRE_first_tail_x15_r0_body.kd82.node).all (fun j => Nat.ble PRE_first_tail_x15_r0_body.P82.NL j && Nat.blt (PRE_first_tail_x15_r0_body.kd82.nodeF j) PRE_first_tail_x15_r0_body.cx1_82.mlx.nnext) = true
kernel_rfl PRE_first_tail_x15_r0_body.cabs0a82 : PRE_first_tail_x15_r0_body.cx0_82.mlx.arrs.get 0 = none
kernel_rfl PRE_first_tail_x15_r0_body.cabs0b82 : PRE_first_tail_x15_r0_body.cx0_82.mlx.objs.get 0 = none
kernel_rfl PRE_first_tail_x15_r0_body.ctok182 : PRE_first_tail_x15_r0_body.cx1_82.mlx.tokens = []
kernel_rfl PRE_first_tail_x15_r0_body.cpend82 : PRE_first_tail_x15_r0_body.cx1_82.mlx.pending = PRE_first_tail_x15_r0_body.cx0_82.mlx.pending.map PRE_first_tail_x15_r0_body.kappa82.pend
kernel_rfl PRE_first_tail_x15_r0_body.cerrh82 : PRE_first_tail_x15_r0_body.cx1_82.mlx.errh = PRE_first_tail_x15_r0_body.cx0_82.mlx.errh.map PRE_first_tail_x15_r0_body.kappa82.arg
kernel_rfl PRE_first_tail_x15_r0_body.cfiles82 : PRE_first_tail_x15_r0_body.cx1_82.mlx.files = PRE_first_tail_x15_r0_body.cx0_82.mlx.files
kernel_rfl PRE_first_tail_x15_r0_body.carch82 : PRE_first_tail_x15_r0_body.cx1_82.mlx.arch = PRE_first_tail_x15_r0_body.cx0_82.mlx.arch
kernel_rfl PRE_first_tail_x15_r0_body.csizes82 : PRE_first_tail_x15_r0_body.cx1_82.mlx.deviceSizes = PRE_first_tail_x15_r0_body.cx0_82.mlx.deviceSizes
kernel_rfl PRE_first_tail_x15_r0_body.cwired82 : PRE_first_tail_x15_r0_body.cx1_82.mlx.wired = PRE_first_tail_x15_r0_body.cx0_82.mlx.wired
kernel_rfl PRE_first_tail_x15_r0_body.chost82 : PRE_first_tail_x15_r0_body.cx1_82.host = PRE_first_tail_x15_r0_body.cx0_82.host
-- the compaction map's addresses are `PRE_first_tail_x15_r0_body.kd82`'s
kernel_rfl PRE_first_tail_x15_r0_body.ckn082 : PRE_first_tail_x15_r0_body.kd82.n0 = 2739589
kernel_rfl PRE_first_tail_x15_r0_body.ckn182 : PRE_first_tail_x15_r0_body.kd82.n1 = 2739591
kernel_rfl PRE_first_tail_x15_r0_body.ckheap82 : (PTrie.keysA PRE_first_tail_x15_r0_body.kd82.heap).all (fun x => Nat.ble 2739589 x) = true
kernel_rfl PRE_first_tail_x15_r0_body.ckpl82 : (List.range 0).all (fun j => decide (PRE_first_tail_x15_r0_body.kd82.heap.get (2739589 + j) = nth? PRE_first_tail_x15_r0_body.pl82 j)) = true
-- the map fixes the call's names (`Conv.fixOld_compact`), the call's counters
kernel_rfl PRE_first_tail_x15_r0_body.fja82 : Nat.ble 2739589 2739589 = true
kernel_rfl PRE_first_tail_x15_r0_body.fn82 : Nat.ble 3584 3584 = true
kernel_rfl PRE_first_tail_x15_r0_body.fjaD82 : Nat.ble 2739589 PRE_first_tail_x15_r0_body.kd82.n0 = true
kernel_rfl PRE_first_tail_x15_r0_body.fxn82 : Nat.ble 19826 PRE_first_tail_x15_r0_body.kd82.nh0 = true
kernel_rfl PRE_first_tail_x15_r0_body.fnn82 : Nat.ble 16914 PRE_first_tail_x15_r0_body.kd82.nn0 = true
kernel_rfl PRE_first_tail_x15_r0_body.fxb82 : Nat.ble 19826 RData.bigHi = true
kernel_rfl PRE_first_tail_x15_r0_body.fheap82 : (PTrie.keysA PRE_first_tail_x15_r0_body.kd82.heap).all (Nat.ble (⟨19826, 16914, 2739589, 3584⟩ : Conv.Cnt).ja) = true
kernel_rfl PRE_first_tail_x15_r0_body.fhnd82 : (PTrie.keysA PRE_first_tail_x15_r0_body.kd82.hnd).all (Nat.ble (⟨19826, 16914, 2739589, 3584⟩ : Conv.Cnt).xn) = true
kernel_rfl PRE_first_tail_x15_r0_body.fnode82 : (PTrie.keysA PRE_first_tail_x15_r0_body.kd82.node).all (Nat.ble (⟨19826, 16914, 2739589, 3584⟩ : Conv.Cnt).nn) = true
/-- The compaction map fixes the call's names. -/
theorem PRE_first_tail_x15_r0_body.cfix82 : Conv.FixOld (⟨19826, 16914, 2739589, 3584⟩ : Conv.Cnt) PRE_first_tail_x15_r0_body.kappa82 :=
  Conv.fixOld_compact (Nat.le_of_ble_eq_true PRE_first_tail_x15_r0_body.fja82) (Nat.le_of_ble_eq_true PRE_first_tail_x15_r0_body.fn82) (Nat.le_of_ble_eq_true PRE_first_tail_x15_r0_body.fjaD82) (Nat.le_of_ble_eq_true PRE_first_tail_x15_r0_body.fxn82) (Nat.le_of_ble_eq_true PRE_first_tail_x15_r0_body.fnn82) (Nat.le_of_ble_eq_true PRE_first_tail_x15_r0_body.fxb82) PRE_first_tail_x15_r0_body.fheap82 PRE_first_tail_x15_r0_body.fhnd82 PRE_first_tail_x15_r0_body.fnode82
kernel_rfl PRE_first_tail_x15_r0_body.fcxn82 : (⟨19826, 16914, 2739589, 3584⟩ : Conv.Cnt).xn = (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s800.ffi).mlx.next
kernel_rfl PRE_first_tail_x15_r0_body.fcnn82 : (⟨19826, 16914, 2739589, 3584⟩ : Conv.Cnt).nn = (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s800.ffi).mlx.nnext
kernel_rfl PRE_first_tail_x15_r0_body.fle082 : (Nat.ble (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s800.ffi).mlx.next PRE_first_tail_x15_r0_body.cx0_82.mlx.next && Nat.ble (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s800.ffi).mlx.nnext PRE_first_tail_x15_r0_body.cx0_82.mlx.nnext && Nat.ble (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s800.ffi).mlx.next RData.bigHi) = true
kernel_rfl PRE_first_tail_x15_r0_body.fnk82 : (PTrie.keysA PRE_first_tail_x15_r0_body.kd82.node).all (Nat.ble (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s800.ffi).mlx.nnext) = true
-- the merged state keeps the call's entries off the stage's footprint
kernel_rfl PRE_first_tail_x15_r0_body.f1A82 : PRE_first_tail_x15_r0_body.cx1_82.mlx.arrs = Stage.setAll (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s800.ffi).mlx.arrs (PRE_first_tail_x15_r0_body.cwS82.filterMap fun i => (PRE_first_tail_x15_r0_body.cx1_82.mlx.arrs.get i).map (i, ·))
kernel_rfl PRE_first_tail_x15_r0_body.f1O82 : PRE_first_tail_x15_r0_body.cx1_82.mlx.objs = Stage.setAll (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s800.ffi).mlx.objs (PRE_first_tail_x15_r0_body.cwS82.filterMap fun i => (PRE_first_tail_x15_r0_body.cx1_82.mlx.objs.get i).map (i, ·))
kernel_rfl PRE_first_tail_x15_r0_body.f1N82 : PRE_first_tail_x15_r0_body.cx1_82.mlx.nodes = Stage.setAll (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s800.ffi).mlx.nodes (PRE_first_tail_x15_r0_body.cnS82.filterMap fun i => (PRE_first_tail_x15_r0_body.cx1_82.mlx.nodes.get i).map (i, ·))
kernel_rfl PRE_first_tail_x15_r0_body.f1I82 : PRE_first_tail_x15_r0_body.cx1_82.mlx.items = Stage.setAll (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s800.ffi).mlx.items (PRE_first_tail_x15_r0_body.ciS82.filterMap fun i => (PRE_first_tail_x15_r0_body.cx1_82.mlx.items.get i).map (i, ·))
kernel_rfl PRE_first_tail_x15_r0_body.fbd82 : (PRE_first_tail_x15_r0_body.clo82 ++ PRE_first_tail_x15_r0_body.cln82 ++ PRE_first_tail_x15_r0_body.cli82 ++ PRE_first_tail_x15_r0_body.cwS82 ++ PRE_first_tail_x15_r0_body.cnS82 ++ PRE_first_tail_x15_r0_body.ciS82).all (fun i => Nat.blt (i / 4096) (4 ^ 31)) = true
kernel_rfl PRE_first_tail_x15_r0_body.fincW82 : PRE_first_tail_x15_r0_body.cwS82.all (fun h => !Nat.blt h (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s800.ffi).mlx.next || PRE_first_tail_x15_r0_body.clo82.contains h) = true
kernel_rfl PRE_first_tail_x15_r0_body.fincI82 : PRE_first_tail_x15_r0_body.ciS82.all (fun k => !Nat.blt k (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s800.ffi).mlx.nnext || PRE_first_tail_x15_r0_body.cli82.contains k) = true
kernel_rfl PRE_first_tail_x15_r0_body.fincN82 : PRE_first_tail_x15_r0_body.cnS82.all (Nat.ble (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s800.ffi).mlx.nnext) = true
kernel_rfl PRE_first_tail_x15_r0_body.flnF82 : PRE_first_tail_x15_r0_body.cln82.all (Nat.ble (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s800.ffi).mlx.nnext) = true
-- the checks over the changed lists
kernel_rfl PRE_first_tail_x15_r0_body.fh82 : PRE_first_tail_x15_r0_body.clo82.all (handleOK PRE_first_tail_x15_r0_body.kappa82 PRE_first_tail_x15_r0_body.P82.lo PRE_first_tail_x15_r0_body.cx0_82.mlx PRE_first_tail_x15_r0_body.cx1_82.mlx) = true
kernel_rfl PRE_first_tail_x15_r0_body.fo82 : PRE_first_tail_x15_r0_body.clo82.map (fun h => PRE_first_tail_x15_r0_body.cx1_82.mlx.objs.get (PRE_first_tail_x15_r0_body.kappa82.handle h)) = PRE_first_tail_x15_r0_body.clo82.map (fun h => (PRE_first_tail_x15_r0_body.cx0_82.mlx.objs.get h).map PRE_first_tail_x15_r0_body.kappa82.nobj)
kernel_rfl PRE_first_tail_x15_r0_body.fok82 : PRE_first_tail_x15_r0_body.clo82.all (objOK PRE_first_tail_x15_r0_body.kappa82 PRE_first_tail_x15_r0_body.P82.NL PRE_first_tail_x15_r0_body.cx0_82.mlx) = true
kernel_rfl PRE_first_tail_x15_r0_body.fnd82 : PRE_first_tail_x15_r0_body.cln82.all (nodeOKF PRE_first_tail_x15_r0_body.kappa82 PRE_first_tail_x15_r0_body.P82 PRE_first_tail_x15_r0_body.cx0_82.mlx PRE_first_tail_x15_r0_body.cx1_82.mlx) = true
kernel_rfl PRE_first_tail_x15_r0_body.fp82 : ((PRE_first_tail_x15_r0_body.cln82.filter (fullB PRE_first_tail_x15_r0_body.P82))).map (fun i => (PRE_first_tail_x15_r0_body.cx1_82.mlx.nodes.get (PRE_first_tail_x15_r0_body.kappa82.node i)).map Host.Mlx.Ffi.Node.prim) =
  ((PRE_first_tail_x15_r0_body.cln82.filter (fullB PRE_first_tail_x15_r0_body.P82))).map (fun i => (PRE_first_tail_x15_r0_body.cx0_82.mlx.nodes.get i).map fun nd => PRE_first_tail_x15_r0_body.kappa82.prim nd.prim)
kernel_rfl PRE_first_tail_x15_r0_body.fnordI82 : incrB PRE_first_tail_x15_r0_body.kd82.nodeF (List.range' 16914 0) = true
kernel_rfl PRE_first_tail_x15_r0_body.fnordK82 : (PTrie.keysA PRE_first_tail_x15_r0_body.kd82.node).all (fun k => Nat.ble 16914 k && Nat.blt k 16914) = true
kernel_rfl PRE_first_tail_x15_r0_body.fnordL82 : (PRE_first_tail_x15_r0_body.cln82.filter (Nat.ble PRE_first_tail_x15_r0_body.P82.N0)).all (fun i => Nat.ble i (PRE_first_tail_x15_r0_body.kd82.nodeF i) && (Nat.blt i 16914 || Nat.ble PRE_first_tail_x15_r0_body.kd82.nn0 i)) = true
theorem PRE_first_tail_x15_r0_body.fnord82 : (PRE_first_tail_x15_r0_body.cln82.filter (Nat.ble PRE_first_tail_x15_r0_body.P82.N0)).all (fun i => Nat.ble i (PRE_first_tail_x15_r0_body.kd82.nodeF i) &&
    (PTrie.keysA PRE_first_tail_x15_r0_body.kd82.node).all fun j => !Nat.blt j i || Nat.blt (PRE_first_tail_x15_r0_body.kd82.nodeF j) (PRE_first_tail_x15_r0_body.kd82.nodeF i)) = true :=
  cnord_of PRE_first_tail_x15_r0_body.cnlow82 PRE_first_tail_x15_r0_body.cnn182 PRE_first_tail_x15_r0_body.fnordI82 PRE_first_tail_x15_r0_body.fnordK82 PRE_first_tail_x15_r0_body.fnordL82
kernel_rfl PRE_first_tail_x15_r0_body.fi82 : PRE_first_tail_x15_r0_body.cli82.all (pnB PRE_first_tail_x15_r0_body.cx0_82.mlx) = true
kernel_rfl PRE_first_tail_x15_r0_body.fii82 : PRE_first_tail_x15_r0_body.cli82.all (fun k => decide (PRE_first_tail_x15_r0_body.cx1_82.mlx.items.get (PRE_first_tail_x15_r0_body.kappa82.node k) = (PRE_first_tail_x15_r0_body.cx0_82.mlx.items.get k).map PRE_first_tail_x15_r0_body.kappa82.nv)) = true
/-- **The compaction's footprint.** -/
theorem PRE_first_tail_x15_r0_body.cfoot82 (clean : Conv.NClean (⟨19826, 16914, 2739589, 3584⟩ : Conv.Cnt) (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s800.ffi).mlx) (hltC : ∀ h, PH (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s800.ffi).mlx h → h < (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s800.ffi).mlx.next) (nltC : ∀ i, PN (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s800.ffi).mlx i → i < (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s800.ffi).mlx.nnext) (itemsC : ∀ k v, (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s800.ffi).mlx.items.get k = some v → PN (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s800.ffi).mlx k) (tracedC : ∀ h o, (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s800.ffi).mlx.objs.get h = some o → ∀ i ∈ objTraces o, i < PRE_first_tail_x15_r0_body.P82.NL) (cl : SSt (· < 3584) PRE_first_tail_x15_r0_body.cx0_82.mlx) :
    Conv.MFoot PRE_first_tail_x15_r0_body.P82 3584 PRE_first_tail_x15_r0_body.kappa82 PRE_first_tail_x15_r0_body.kd82 PRE_first_tail_x15_r0_body.khinv82 PRE_first_tail_x15_r0_body.kninv82 (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s800.ffi).mlx PRE_first_tail_x15_r0_body.cx0_82.mlx PRE_first_tail_x15_r0_body.cx1_82.mlx (⟨19826, 16914, 2739589, 3584⟩ : Conv.Cnt) PRE_first_tail_x15_r0_body.clo82 PRE_first_tail_x15_r0_body.cln82 PRE_first_tail_x15_r0_body.cli82 PRE_first_tail_x15_r0_body.cwS82 PRE_first_tail_x15_r0_body.cnS82 PRE_first_tail_x15_r0_body.ciS82 :=
  ⟨rfl, rfl, rfl, PRE_first_tail_x15_r0_body.cnh082, PRE_first_tail_x15_r0_body.cnh182, PRE_first_tail_x15_r0_body.cnn082, PRE_first_tail_x15_r0_body.cnn182, PRE_first_tail_x15_r0_body.cplo82, PRE_first_tail_x15_r0_body.ccnt82, PRE_first_tail_x15_r0_body.cnband82, PRE_first_tail_x15_r0_body.chbelow82, PRE_first_tail_x15_r0_body.chren82, PRE_first_tail_x15_r0_body.cband82, PRE_first_tail_x15_r0_body.cnh1pos82, PRE_first_tail_x15_r0_body.cnren82, PRE_first_tail_x15_r0_body.cnlow82, PRE_first_tail_x15_r0_body.cabs0a82, PRE_first_tail_x15_r0_body.cabs0b82, PRE_first_tail_x15_r0_body.ctok182, PRE_first_tail_x15_r0_body.cpend82, PRE_first_tail_x15_r0_body.cerrh82, PRE_first_tail_x15_r0_body.cfiles82, PRE_first_tail_x15_r0_body.carch82, PRE_first_tail_x15_r0_body.csizes82, PRE_first_tail_x15_r0_body.cwired82, PRE_first_tail_x15_r0_body.cfix82, clean, PRE_first_tail_x15_r0_body.fcxn82, PRE_first_tail_x15_r0_body.fcnn82, hltC, nltC, itemsC, tracedC, cl, PRE_first_tail_x15_r0_body.fle082, PRE_first_tail_x15_r0_body.fnk82, PRE_first_tail_x15_r0_body.ckA82, PRE_first_tail_x15_r0_body.cobjsK82, PRE_first_tail_x15_r0_body.cnodesK82, PRE_first_tail_x15_r0_body.citemsK82, PRE_first_tail_x15_r0_body.f1A82, PRE_first_tail_x15_r0_body.f1O82, PRE_first_tail_x15_r0_body.f1N82, PRE_first_tail_x15_r0_body.f1I82, PRE_first_tail_x15_r0_body.fbd82, PRE_first_tail_x15_r0_body.fincW82, PRE_first_tail_x15_r0_body.fincI82, PRE_first_tail_x15_r0_body.fincN82, PRE_first_tail_x15_r0_body.flnF82, PRE_first_tail_x15_r0_body.fh82, PRE_first_tail_x15_r0_body.fo82, PRE_first_tail_x15_r0_body.fok82, PRE_first_tail_x15_r0_body.fnd82, PRE_first_tail_x15_r0_body.fp82, PRE_first_tail_x15_r0_body.fnord82, PRE_first_tail_x15_r0_body.fi82, PRE_first_tail_x15_r0_body.fii82⟩
theorem PRE_first_tail_x15_r0_body.cnshift82 (clean : Conv.NClean (⟨19826, 16914, 2739589, 3584⟩ : Conv.Cnt) (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s800.ffi).mlx) (hltC : ∀ h, PH (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s800.ffi).mlx h → h < (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s800.ffi).mlx.next) (nltC : ∀ i, PN (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s800.ffi).mlx i → i < (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s800.ffi).mlx.nnext) (itemsC : ∀ k v, (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s800.ffi).mlx.items.get k = some v → PN (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s800.ffi).mlx k) (tracedC : ∀ h o, (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s800.ffi).mlx.objs.get h = some o → ∀ i ∈ objTraces o, i < PRE_first_tail_x15_r0_body.P82.NL) (cl : SSt (· < 3584) PRE_first_tail_x15_r0_body.cx0_82.mlx) : NShift PRE_first_tail_x15_r0_body.P82 3584 PRE_first_tail_x15_r0_body.kappa82 PRE_first_tail_x15_r0_body.cx0_82 PRE_first_tail_x15_r0_body.cx1_82 :=
  Conv.nshift_of_foot (PRE_first_tail_x15_r0_body.cfoot82 clean hltC nltC itemsC tracedC cl) PRE_first_tail_x15_r0_body.chost82 (compact_a_eq PRE_first_tail_x15_r0_body.ckn082 PRE_first_tail_x15_r0_body.ckn182 PRE_first_tail_x15_r0_body.ckheap82 PRE_first_tail_x15_r0_body.ckpl82)

-- the observers: the layers' states at the call, the canonical and the merged state, their footprints and checks
noncomputable def PRE_first_tail_x15_r0_body.fxC_82 : PTrie Unit := (Host.Ts.Sim.Full.freedOf PRE_first_tail_x15_r0_body.s800.ffi).getD PTrie.nil
noncomputable def PRE_first_tail_x15_r0_body.krC_82 : Host.Load.Layers.KRec := (Host.Ts.Sim.Full.krecOf PRE_first_tail_x15_r0_body.s800.ffi).getD Host.Load.Layers.KRec.empty
kernel_rfl PRE_first_tail_x15_r0_body.ofxC_82 : (Host.Ts.Sim.Full.freedOf PRE_first_tail_x15_r0_body.s800.ffi) = some PRE_first_tail_x15_r0_body.fxC_82
kernel_rfl PRE_first_tail_x15_r0_body.okrC_82 : (Host.Ts.Sim.Full.krecOf PRE_first_tail_x15_r0_body.s800.ffi) = some PRE_first_tail_x15_r0_body.krC_82
noncomputable def PRE_first_tail_x15_r0_body.fx0_82 : PTrie Unit := (Host.Ts.Sim.Full.freedOf PRE_first_tail_x15_r0_body.s802.ffi).getD PTrie.nil
noncomputable def PRE_first_tail_x15_r0_body.kr0_82 : Host.Load.Layers.KRec := (Host.Ts.Sim.Full.krecOf PRE_first_tail_x15_r0_body.s802.ffi).getD Host.Load.Layers.KRec.empty
kernel_rfl PRE_first_tail_x15_r0_body.ofx0_82 : (Host.Ts.Sim.Full.freedOf PRE_first_tail_x15_r0_body.s802.ffi) = some PRE_first_tail_x15_r0_body.fx0_82
kernel_rfl PRE_first_tail_x15_r0_body.okr0_82 : (Host.Ts.Sim.Full.krecOf PRE_first_tail_x15_r0_body.s802.ffi) = some PRE_first_tail_x15_r0_body.kr0_82
noncomputable def PRE_first_tail_x15_r0_body.fx1_82 : PTrie Unit := (Host.Ts.Sim.Full.freedOf PRE_first_tail_x15_r0_body.s801.ffi).getD PTrie.nil
noncomputable def PRE_first_tail_x15_r0_body.kr1_82 : Host.Load.Layers.KRec := (Host.Ts.Sim.Full.krecOf PRE_first_tail_x15_r0_body.s801.ffi).getD Host.Load.Layers.KRec.empty
kernel_rfl PRE_first_tail_x15_r0_body.ofx1_82 : (Host.Ts.Sim.Full.freedOf PRE_first_tail_x15_r0_body.s801.ffi) = some PRE_first_tail_x15_r0_body.fx1_82
kernel_rfl PRE_first_tail_x15_r0_body.okr1_82 : (Host.Ts.Sim.Full.krecOf PRE_first_tail_x15_r0_body.s801.ffi) = some PRE_first_tail_x15_r0_body.kr1_82
kernel_rfl PRE_first_tail_x15_r0_body.ff082 : PRE_first_tail_x15_r0_body.fx0_82 = Stage.setAll PRE_first_tail_x15_r0_body.fxC_82 (PRE_first_tail_x15_r0_body.clo82.filterMap fun i => (PRE_first_tail_x15_r0_body.fx0_82.get i).map (i, ·))
kernel_rfl PRE_first_tail_x15_r0_body.ff182 : PRE_first_tail_x15_r0_body.fx1_82 = Stage.setAll PRE_first_tail_x15_r0_body.fxC_82 (PRE_first_tail_x15_r0_body.cwS82.filterMap fun i => (PRE_first_tail_x15_r0_body.fx1_82.get i).map (i, ·))
kernel_rfl PRE_first_tail_x15_r0_body.ffck82 : freedLB PRE_first_tail_x15_r0_body.kappa82 PRE_first_tail_x15_r0_body.cx0_82.mlx PRE_first_tail_x15_r0_body.fx0_82 PRE_first_tail_x15_r0_body.fx1_82 PRE_first_tail_x15_r0_body.clo82 = true
kernel_rfl PRE_first_tail_x15_r0_body.fkf082 : PRE_first_tail_x15_r0_body.kr0_82.flags = Stage.setAll PRE_first_tail_x15_r0_body.krC_82.flags (PRE_first_tail_x15_r0_body.clo82.filterMap fun i => (PRE_first_tail_x15_r0_body.kr0_82.flags.get i).map (i, ·))
kernel_rfl PRE_first_tail_x15_r0_body.fkt082 : PRE_first_tail_x15_r0_body.kr0_82.targs = Stage.setAll PRE_first_tail_x15_r0_body.krC_82.targs (PRE_first_tail_x15_r0_body.clo82.filterMap fun i => (PRE_first_tail_x15_r0_body.kr0_82.targs.get i).map (i, ·))
kernel_rfl PRE_first_tail_x15_r0_body.fkf182 : PRE_first_tail_x15_r0_body.kr1_82.flags = Stage.setAll PRE_first_tail_x15_r0_body.krC_82.flags (PRE_first_tail_x15_r0_body.cwS82.filterMap fun i => (PRE_first_tail_x15_r0_body.kr1_82.flags.get i).map (i, ·))
kernel_rfl PRE_first_tail_x15_r0_body.fkt182 : PRE_first_tail_x15_r0_body.kr1_82.targs = Stage.setAll PRE_first_tail_x15_r0_body.krC_82.targs (PRE_first_tail_x15_r0_body.cwS82.filterMap fun i => (PRE_first_tail_x15_r0_body.kr1_82.targs.get i).map (i, ·))
kernel_rfl PRE_first_tail_x15_r0_body.fkck82 : krecLB PRE_first_tail_x15_r0_body.kappa82 3584 PRE_first_tail_x15_r0_body.cx0_82.mlx PRE_first_tail_x15_r0_body.kr0_82 PRE_first_tail_x15_r0_body.kr1_82 PRE_first_tail_x15_r0_body.clo82 = true
kernel_rfl PRE_first_tail_x15_r0_body.fkn82 : Nat.ble 3584 3584 = true
-- the bridge and the pending traces' regions
kernel_rfl PRE_first_tail_x15_r0_body.cbridge82 : Host.Ts.Sim.Full.bridgeOf PRE_first_tail_x15_r0_body.s801.ffi = Host.Ts.Sim.Full.bridgeOf PRE_first_tail_x15_r0_body.s802.ffi
kernel_rfl PRE_first_tail_x15_r0_body.cpendR82 : pendRegB PRE_first_tail_x15_r0_body.kappa82 (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s802.ffi).mlx = true
kernel_rfl PRE_first_tail_x15_r0_body.cpendLe82 : Nat.ble (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s802.ffi).mlx.next (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s801.ffi).mlx.next = true
/-- **The compaction's native shift**, given the call's bookkeeping, its relation's facts (the model's and the
observers') and the canonical closedness. -/
theorem PRE_first_tail_x15_r0_body.cshift82 (clean : Conv.NClean (⟨19826, 16914, 2739589, 3584⟩ : Conv.Cnt) (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s800.ffi).mlx) (hltC : ∀ h, PH (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s800.ffi).mlx h → h < (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s800.ffi).mlx.next) (nltC : ∀ i, PN (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s800.ffi).mlx i → i < (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s800.ffi).mlx.nnext) (itemsC : ∀ k v, (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s800.ffi).mlx.items.get k = some v → PN (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s800.ffi).mlx k) (tracedC : ∀ h o, (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s800.ffi).mlx.objs.get h = some o → ∀ i ∈ objTraces o, i < PRE_first_tail_x15_r0_body.P82.NL) (cl : SSt (· < 3584) PRE_first_tail_x15_r0_body.cx0_82.mlx)
    (hobjC : ∀ h, PRE_first_tail_x15_r0_body.fxC_82.get h = some () → ((Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s800.ffi).mlx.objs.get h).isSome = true)
    (hfC : ∀ h, (PRE_first_tail_x15_r0_body.krC_82.flags.get h).isSome = true → ((Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s800.ffi).mlx.objs.get h).isSome = true)
    (htC : ∀ h, (PRE_first_tail_x15_r0_body.krC_82.targs.get h).isSome = true → ((Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s800.ffi).mlx.objs.get h).isSome = true)
    (hclC : ∀ h l, PRE_first_tail_x15_r0_body.krC_82.targs.get h = some l → Host.Ts.Sim.Full.STargs (· < (⟨19826, 16914, 2739589, 3584⟩ : Conv.Cnt).n) l) :
    Conv.FullShiftQ PRE_first_tail_x15_r0_body.P82 3584 PRE_first_tail_x15_r0_body.kappa82 PRE_first_tail_x15_r0_body.s802.ffi PRE_first_tail_x15_r0_body.s801.ffi :=
  ⟨PRE_first_tail_x15_r0_body.cnshift82 clean hltC nltC itemsC tracedC cl, PRE_first_tail_x15_r0_body.cqueue82, fun t ht => bSN_sound (List.all_eq_true.mp PRE_first_tail_x15_r0_body.ctokSupp82 t ht),
    PRE_first_tail_x15_r0_body.cbridge82,
    liveShift_foot (x0' := Host.Ts.Sim.Full.mlxOf PRE_first_tail_x15_r0_body.s802.ffi) (x1' := Host.Ts.Sim.Full.mlxOf PRE_first_tail_x15_r0_body.s801.ffi) (PRE_first_tail_x15_r0_body.cfoot82 clean hltC nltC itemsC tracedC cl) rfl PRE_first_tail_x15_r0_body.ofx0_82 PRE_first_tail_x15_r0_body.ofx1_82 hobjC PRE_first_tail_x15_r0_body.ff082 PRE_first_tail_x15_r0_body.ff182 PRE_first_tail_x15_r0_body.ffck82,
    kernShift_foot (x0' := Host.Ts.Sim.Full.mlxOf PRE_first_tail_x15_r0_body.s802.ffi) (x1' := Host.Ts.Sim.Full.mlxOf PRE_first_tail_x15_r0_body.s801.ffi) (PRE_first_tail_x15_r0_body.cfoot82 clean hltC nltC itemsC tracedC cl) rfl PRE_first_tail_x15_r0_body.okr0_82 PRE_first_tail_x15_r0_body.okr1_82 (Nat.le_of_ble_eq_true PRE_first_tail_x15_r0_body.fkn82) hfC htC hclC
      PRE_first_tail_x15_r0_body.fkf082 PRE_first_tail_x15_r0_body.fkt082 PRE_first_tail_x15_r0_body.fkf182 PRE_first_tail_x15_r0_body.fkt182 PRE_first_tail_x15_r0_body.fkck82,
    pendReg_of rfl PRE_first_tail_x15_r0_body.cnh082 PRE_first_tail_x15_r0_body.cnh182 (Nat.le_of_ble_eq_true PRE_first_tail_x15_r0_body.cpendLe82) PRE_first_tail_x15_r0_body.cpendR82⟩

end Host.Load.Run.Tpl
