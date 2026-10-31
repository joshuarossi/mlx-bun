import host.sim.template.a4pre_first_tail_x15_r0_body.SiteCl190
import host.sim.conv.CompactFull
import host.sim.template.FootGen
set_option Elab.async false
namespace Host.Load.Run.Tpl
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
open Host.Ts Host.Ts.Sim Host.Ts.Sim.Template

/-! The compaction's native shift at call site 190 from its footprint (`Conv.nshift_of_foot`), and the observers'
(`liveShift_foot`, `kernShift_foot`): `Conv.FullShiftQ` for `Conv.full_compactQ`, given the call's bookkeeping and its
relation's facts. -/

/-- The load parameters of the chain (band-free: its start's node counter as `NL` and `N0`). -/
def PRE_first_tail_x15_r0_body.Pc190 : LoadP := ⟨18151, 131072, 1099511627776, 15235, 15235, []⟩
/-- The site's band raised to the map's checked fixed-node prefix, including newly recorded closure traces. -/
def PRE_first_tail_x15_r0_body.P190 : LoadP := PRE_first_tail_x15_r0_body.Pc190.raise 19047
kernel_rfl PRE_first_tail_x15_r0_body.craise190 : Nat.ble PRE_first_tail_x15_r0_body.Pc190.N0 19047 = true
theorem PRE_first_tail_x15_r0_body.raised190 : Host.Ts.Sim.Full.Raised PRE_first_tail_x15_r0_body.Pc190 PRE_first_tail_x15_r0_body.P190 :=
  .inr ⟨19047, rfl, Nat.le_of_ble_eq_true PRE_first_tail_x15_r0_body.craise190, rfl⟩
noncomputable abbrev PRE_first_tail_x15_r0_body.cx0_190 : Host.Load.LSt := clearTokens (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1837.ffi)
noncomputable abbrev PRE_first_tail_x15_r0_body.cx1_190 : Host.Load.LSt := clearTokens (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1836.ffi)
def PRE_first_tail_x15_r0_body.khinv190 : PTrie Nat := Stage.setAll PTrie.nil []
def PRE_first_tail_x15_r0_body.kninv190 : PTrie Nat := Stage.setAll PTrie.nil []
/-- The stage's footprint: its written and fresh handles, fresh nodes, written and fresh items. -/
def PRE_first_tail_x15_r0_body.cwS190 : List Nat := []
def PRE_first_tail_x15_r0_body.cnS190 : List Nat := List.range' 19047 0
def PRE_first_tail_x15_r0_body.ciS190 : List Nat := [] ++ List.range' 19047 0

-- the small checks (`MChecks`'s)
kernel_rfl PRE_first_tail_x15_r0_body.cnh0190 : PRE_first_tail_x15_r0_body.kd190.nh0 = PRE_first_tail_x15_r0_body.cx0_190.mlx.next
kernel_rfl PRE_first_tail_x15_r0_body.cnh1190 : PRE_first_tail_x15_r0_body.kd190.nh1 = PRE_first_tail_x15_r0_body.cx1_190.mlx.next
kernel_rfl PRE_first_tail_x15_r0_body.cnn0190 : PRE_first_tail_x15_r0_body.kd190.nn0 = PRE_first_tail_x15_r0_body.cx0_190.mlx.nnext
kernel_rfl PRE_first_tail_x15_r0_body.cnn1190 : PRE_first_tail_x15_r0_body.kd190.nn1 = PRE_first_tail_x15_r0_body.cx1_190.mlx.nnext
kernel_rfl PRE_first_tail_x15_r0_body.cplo190 : (Nat.blt 0 PRE_first_tail_x15_r0_body.P190.lo && Nat.ble PRE_first_tail_x15_r0_body.P190.lo PRE_first_tail_x15_r0_body.cx0_190.mlx.next && Nat.ble PRE_first_tail_x15_r0_body.P190.lo RData.bigHi && Nat.ble RData.bigHi PRE_first_tail_x15_r0_body.P190.E) = true
kernel_rfl PRE_first_tail_x15_r0_body.ccnt190 : (Nat.ble PRE_first_tail_x15_r0_body.cx0_190.mlx.next PRE_first_tail_x15_r0_body.cx1_190.mlx.next && Nat.ble PRE_first_tail_x15_r0_body.cx0_190.mlx.nnext PRE_first_tail_x15_r0_body.cx1_190.mlx.nnext) = true
kernel_rfl PRE_first_tail_x15_r0_body.cnband190 : (Nat.blt 0 PRE_first_tail_x15_r0_body.P190.NL && Nat.ble PRE_first_tail_x15_r0_body.P190.NL PRE_first_tail_x15_r0_body.P190.N0 && Nat.ble PRE_first_tail_x15_r0_body.P190.N0 PRE_first_tail_x15_r0_body.cx0_190.mlx.nnext) = true
kernel_rfl PRE_first_tail_x15_r0_body.chbelow190 : PRE_first_tail_x15_r0_body.kd190.checkHndBelow = true
kernel_rfl PRE_first_tail_x15_r0_body.chren190 : checkRenG PRE_first_tail_x15_r0_body.kd190.hnd PRE_first_tail_x15_r0_body.khinv190 (phB PRE_first_tail_x15_r0_body.cx0_190.mlx) = true
kernel_rfl PRE_first_tail_x15_r0_body.cband190 : PRE_first_tail_x15_r0_body.kd190.checkBand PRE_first_tail_x15_r0_body.P190.lo = true
kernel_rfl PRE_first_tail_x15_r0_body.cnh1pos190 : Nat.blt 0 PRE_first_tail_x15_r0_body.kd190.nh1 = true
kernel_rfl PRE_first_tail_x15_r0_body.cnren190 : checkRenG PRE_first_tail_x15_r0_body.kd190.node PRE_first_tail_x15_r0_body.kninv190 (pnB PRE_first_tail_x15_r0_body.cx0_190.mlx) = true
kernel_rfl PRE_first_tail_x15_r0_body.cnlow190 : (PTrie.keysA PRE_first_tail_x15_r0_body.kd190.node).all (fun j => Nat.ble PRE_first_tail_x15_r0_body.P190.NL j && Nat.blt (PRE_first_tail_x15_r0_body.kd190.nodeF j) PRE_first_tail_x15_r0_body.cx1_190.mlx.nnext) = true
kernel_rfl PRE_first_tail_x15_r0_body.cabs0a190 : PRE_first_tail_x15_r0_body.cx0_190.mlx.arrs.get 0 = none
kernel_rfl PRE_first_tail_x15_r0_body.cabs0b190 : PRE_first_tail_x15_r0_body.cx0_190.mlx.objs.get 0 = none
kernel_rfl PRE_first_tail_x15_r0_body.ctok1190 : PRE_first_tail_x15_r0_body.cx1_190.mlx.tokens = []
kernel_rfl PRE_first_tail_x15_r0_body.cpend190 : PRE_first_tail_x15_r0_body.cx1_190.mlx.pending = PRE_first_tail_x15_r0_body.cx0_190.mlx.pending.map PRE_first_tail_x15_r0_body.kappa190.pend
kernel_rfl PRE_first_tail_x15_r0_body.cerrh190 : PRE_first_tail_x15_r0_body.cx1_190.mlx.errh = PRE_first_tail_x15_r0_body.cx0_190.mlx.errh.map PRE_first_tail_x15_r0_body.kappa190.arg
kernel_rfl PRE_first_tail_x15_r0_body.cfiles190 : PRE_first_tail_x15_r0_body.cx1_190.mlx.files = PRE_first_tail_x15_r0_body.cx0_190.mlx.files
kernel_rfl PRE_first_tail_x15_r0_body.carch190 : PRE_first_tail_x15_r0_body.cx1_190.mlx.arch = PRE_first_tail_x15_r0_body.cx0_190.mlx.arch
kernel_rfl PRE_first_tail_x15_r0_body.csizes190 : PRE_first_tail_x15_r0_body.cx1_190.mlx.deviceSizes = PRE_first_tail_x15_r0_body.cx0_190.mlx.deviceSizes
kernel_rfl PRE_first_tail_x15_r0_body.cwired190 : PRE_first_tail_x15_r0_body.cx1_190.mlx.wired = PRE_first_tail_x15_r0_body.cx0_190.mlx.wired
kernel_rfl PRE_first_tail_x15_r0_body.chost190 : PRE_first_tail_x15_r0_body.cx1_190.host = PRE_first_tail_x15_r0_body.cx0_190.host
-- the compaction map's addresses are `PRE_first_tail_x15_r0_body.kd190`'s
kernel_rfl PRE_first_tail_x15_r0_body.ckn0190 : PRE_first_tail_x15_r0_body.kd190.n0 = 2824365
kernel_rfl PRE_first_tail_x15_r0_body.ckn1190 : PRE_first_tail_x15_r0_body.kd190.n1 = 2824367
kernel_rfl PRE_first_tail_x15_r0_body.ckheap190 : (PTrie.keysA PRE_first_tail_x15_r0_body.kd190.heap).all (fun x => Nat.ble 2824365 x) = true
kernel_rfl PRE_first_tail_x15_r0_body.ckpl190 : (List.range 0).all (fun j => decide (PRE_first_tail_x15_r0_body.kd190.heap.get (2824365 + j) = nth? PRE_first_tail_x15_r0_body.pl190 j)) = true
-- the map fixes the call's names (`Conv.fixOld_compact`), the call's counters
kernel_rfl PRE_first_tail_x15_r0_body.fja190 : Nat.ble 2824365 2824365 = true
kernel_rfl PRE_first_tail_x15_r0_body.fn190 : Nat.ble 8201 8201 = true
kernel_rfl PRE_first_tail_x15_r0_body.fjaD190 : Nat.ble 2824365 PRE_first_tail_x15_r0_body.kd190.n0 = true
kernel_rfl PRE_first_tail_x15_r0_body.fxn190 : Nat.ble 21950 PRE_first_tail_x15_r0_body.kd190.nh0 = true
kernel_rfl PRE_first_tail_x15_r0_body.fnn190 : Nat.ble 19047 PRE_first_tail_x15_r0_body.kd190.nn0 = true
kernel_rfl PRE_first_tail_x15_r0_body.fxb190 : Nat.ble 21950 RData.bigHi = true
kernel_rfl PRE_first_tail_x15_r0_body.fheap190 : (PTrie.keysA PRE_first_tail_x15_r0_body.kd190.heap).all (Nat.ble (⟨21950, 19047, 2824365, 8201⟩ : Conv.Cnt).ja) = true
kernel_rfl PRE_first_tail_x15_r0_body.fhnd190 : (PTrie.keysA PRE_first_tail_x15_r0_body.kd190.hnd).all (Nat.ble (⟨21950, 19047, 2824365, 8201⟩ : Conv.Cnt).xn) = true
kernel_rfl PRE_first_tail_x15_r0_body.fnode190 : (PTrie.keysA PRE_first_tail_x15_r0_body.kd190.node).all (Nat.ble (⟨21950, 19047, 2824365, 8201⟩ : Conv.Cnt).nn) = true
/-- The compaction map fixes the call's names. -/
theorem PRE_first_tail_x15_r0_body.cfix190 : Conv.FixOld (⟨21950, 19047, 2824365, 8201⟩ : Conv.Cnt) PRE_first_tail_x15_r0_body.kappa190 :=
  Conv.fixOld_compact (Nat.le_of_ble_eq_true PRE_first_tail_x15_r0_body.fja190) (Nat.le_of_ble_eq_true PRE_first_tail_x15_r0_body.fn190) (Nat.le_of_ble_eq_true PRE_first_tail_x15_r0_body.fjaD190) (Nat.le_of_ble_eq_true PRE_first_tail_x15_r0_body.fxn190) (Nat.le_of_ble_eq_true PRE_first_tail_x15_r0_body.fnn190) (Nat.le_of_ble_eq_true PRE_first_tail_x15_r0_body.fxb190) PRE_first_tail_x15_r0_body.fheap190 PRE_first_tail_x15_r0_body.fhnd190 PRE_first_tail_x15_r0_body.fnode190
kernel_rfl PRE_first_tail_x15_r0_body.fcxn190 : (⟨21950, 19047, 2824365, 8201⟩ : Conv.Cnt).xn = (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1835.ffi).mlx.next
kernel_rfl PRE_first_tail_x15_r0_body.fcnn190 : (⟨21950, 19047, 2824365, 8201⟩ : Conv.Cnt).nn = (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1835.ffi).mlx.nnext
kernel_rfl PRE_first_tail_x15_r0_body.fle0190 : (Nat.ble (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1835.ffi).mlx.next PRE_first_tail_x15_r0_body.cx0_190.mlx.next && Nat.ble (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1835.ffi).mlx.nnext PRE_first_tail_x15_r0_body.cx0_190.mlx.nnext && Nat.ble (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1835.ffi).mlx.next RData.bigHi) = true
kernel_rfl PRE_first_tail_x15_r0_body.fnk190 : (PTrie.keysA PRE_first_tail_x15_r0_body.kd190.node).all (Nat.ble (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1835.ffi).mlx.nnext) = true
-- the merged state keeps the call's entries off the stage's footprint
kernel_rfl PRE_first_tail_x15_r0_body.f1A190 : PRE_first_tail_x15_r0_body.cx1_190.mlx.arrs = Stage.setAll (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1835.ffi).mlx.arrs (PRE_first_tail_x15_r0_body.cwS190.filterMap fun i => (PRE_first_tail_x15_r0_body.cx1_190.mlx.arrs.get i).map (i, ·))
kernel_rfl PRE_first_tail_x15_r0_body.f1O190 : PRE_first_tail_x15_r0_body.cx1_190.mlx.objs = Stage.setAll (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1835.ffi).mlx.objs (PRE_first_tail_x15_r0_body.cwS190.filterMap fun i => (PRE_first_tail_x15_r0_body.cx1_190.mlx.objs.get i).map (i, ·))
kernel_rfl PRE_first_tail_x15_r0_body.f1N190 : PRE_first_tail_x15_r0_body.cx1_190.mlx.nodes = Stage.setAll (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1835.ffi).mlx.nodes (PRE_first_tail_x15_r0_body.cnS190.filterMap fun i => (PRE_first_tail_x15_r0_body.cx1_190.mlx.nodes.get i).map (i, ·))
kernel_rfl PRE_first_tail_x15_r0_body.f1I190 : PRE_first_tail_x15_r0_body.cx1_190.mlx.items = Stage.setAll (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1835.ffi).mlx.items (PRE_first_tail_x15_r0_body.ciS190.filterMap fun i => (PRE_first_tail_x15_r0_body.cx1_190.mlx.items.get i).map (i, ·))
kernel_rfl PRE_first_tail_x15_r0_body.fbd190 : (PRE_first_tail_x15_r0_body.clo190 ++ PRE_first_tail_x15_r0_body.cln190 ++ PRE_first_tail_x15_r0_body.cli190 ++ PRE_first_tail_x15_r0_body.cwS190 ++ PRE_first_tail_x15_r0_body.cnS190 ++ PRE_first_tail_x15_r0_body.ciS190).all (fun i => Nat.blt (i / 4096) (4 ^ 31)) = true
kernel_rfl PRE_first_tail_x15_r0_body.fincW190 : PRE_first_tail_x15_r0_body.cwS190.all (fun h => !Nat.blt h (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1835.ffi).mlx.next || PRE_first_tail_x15_r0_body.clo190.contains h) = true
kernel_rfl PRE_first_tail_x15_r0_body.fincI190 : PRE_first_tail_x15_r0_body.ciS190.all (fun k => !Nat.blt k (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1835.ffi).mlx.nnext || PRE_first_tail_x15_r0_body.cli190.contains k) = true
kernel_rfl PRE_first_tail_x15_r0_body.fincN190 : PRE_first_tail_x15_r0_body.cnS190.all (Nat.ble (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1835.ffi).mlx.nnext) = true
kernel_rfl PRE_first_tail_x15_r0_body.flnF190 : PRE_first_tail_x15_r0_body.cln190.all (Nat.ble (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1835.ffi).mlx.nnext) = true
-- the checks over the changed lists
kernel_rfl PRE_first_tail_x15_r0_body.fh190 : PRE_first_tail_x15_r0_body.clo190.all (handleOK PRE_first_tail_x15_r0_body.kappa190 PRE_first_tail_x15_r0_body.P190.lo PRE_first_tail_x15_r0_body.cx0_190.mlx PRE_first_tail_x15_r0_body.cx1_190.mlx) = true
kernel_rfl PRE_first_tail_x15_r0_body.fo190 : PRE_first_tail_x15_r0_body.clo190.map (fun h => PRE_first_tail_x15_r0_body.cx1_190.mlx.objs.get (PRE_first_tail_x15_r0_body.kappa190.handle h)) = PRE_first_tail_x15_r0_body.clo190.map (fun h => (PRE_first_tail_x15_r0_body.cx0_190.mlx.objs.get h).map PRE_first_tail_x15_r0_body.kappa190.nobj)
kernel_rfl PRE_first_tail_x15_r0_body.fok190 : PRE_first_tail_x15_r0_body.clo190.all (objOK PRE_first_tail_x15_r0_body.kappa190 PRE_first_tail_x15_r0_body.P190.NL PRE_first_tail_x15_r0_body.cx0_190.mlx) = true
kernel_rfl PRE_first_tail_x15_r0_body.fnd190 : PRE_first_tail_x15_r0_body.cln190.all (nodeOKF PRE_first_tail_x15_r0_body.kappa190 PRE_first_tail_x15_r0_body.P190 PRE_first_tail_x15_r0_body.cx0_190.mlx PRE_first_tail_x15_r0_body.cx1_190.mlx) = true
kernel_rfl PRE_first_tail_x15_r0_body.fp190 : ((PRE_first_tail_x15_r0_body.cln190.filter (fullB PRE_first_tail_x15_r0_body.P190))).map (fun i => (PRE_first_tail_x15_r0_body.cx1_190.mlx.nodes.get (PRE_first_tail_x15_r0_body.kappa190.node i)).map Host.Mlx.Ffi.Node.prim) =
  ((PRE_first_tail_x15_r0_body.cln190.filter (fullB PRE_first_tail_x15_r0_body.P190))).map (fun i => (PRE_first_tail_x15_r0_body.cx0_190.mlx.nodes.get i).map fun nd => PRE_first_tail_x15_r0_body.kappa190.prim nd.prim)
kernel_rfl PRE_first_tail_x15_r0_body.fnordI190 : incrB PRE_first_tail_x15_r0_body.kd190.nodeF (List.range' 19047 0) = true
kernel_rfl PRE_first_tail_x15_r0_body.fnordK190 : (PTrie.keysA PRE_first_tail_x15_r0_body.kd190.node).all (fun k => Nat.ble 19047 k && Nat.blt k 19047) = true
kernel_rfl PRE_first_tail_x15_r0_body.fnordL190 : (PRE_first_tail_x15_r0_body.cln190.filter (Nat.ble PRE_first_tail_x15_r0_body.P190.N0)).all (fun i => Nat.ble i (PRE_first_tail_x15_r0_body.kd190.nodeF i) && (Nat.blt i 19047 || Nat.ble PRE_first_tail_x15_r0_body.kd190.nn0 i)) = true
theorem PRE_first_tail_x15_r0_body.fnord190 : (PRE_first_tail_x15_r0_body.cln190.filter (Nat.ble PRE_first_tail_x15_r0_body.P190.N0)).all (fun i => Nat.ble i (PRE_first_tail_x15_r0_body.kd190.nodeF i) &&
    (PTrie.keysA PRE_first_tail_x15_r0_body.kd190.node).all fun j => !Nat.blt j i || Nat.blt (PRE_first_tail_x15_r0_body.kd190.nodeF j) (PRE_first_tail_x15_r0_body.kd190.nodeF i)) = true :=
  cnord_of PRE_first_tail_x15_r0_body.cnlow190 PRE_first_tail_x15_r0_body.cnn1190 PRE_first_tail_x15_r0_body.fnordI190 PRE_first_tail_x15_r0_body.fnordK190 PRE_first_tail_x15_r0_body.fnordL190
kernel_rfl PRE_first_tail_x15_r0_body.fi190 : PRE_first_tail_x15_r0_body.cli190.all (pnB PRE_first_tail_x15_r0_body.cx0_190.mlx) = true
kernel_rfl PRE_first_tail_x15_r0_body.fii190 : PRE_first_tail_x15_r0_body.cli190.all (fun k => decide (PRE_first_tail_x15_r0_body.cx1_190.mlx.items.get (PRE_first_tail_x15_r0_body.kappa190.node k) = (PRE_first_tail_x15_r0_body.cx0_190.mlx.items.get k).map PRE_first_tail_x15_r0_body.kappa190.nv)) = true
/-- **The compaction's footprint.** -/
theorem PRE_first_tail_x15_r0_body.cfoot190 (clean : Conv.NClean (⟨21950, 19047, 2824365, 8201⟩ : Conv.Cnt) (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1835.ffi).mlx) (hltC : ∀ h, PH (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1835.ffi).mlx h → h < (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1835.ffi).mlx.next) (nltC : ∀ i, PN (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1835.ffi).mlx i → i < (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1835.ffi).mlx.nnext) (itemsC : ∀ k v, (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1835.ffi).mlx.items.get k = some v → PN (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1835.ffi).mlx k) (tracedC : ∀ h o, (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1835.ffi).mlx.objs.get h = some o → ∀ i ∈ objTraces o, i < PRE_first_tail_x15_r0_body.P190.NL) (cl : SSt (· < 8201) PRE_first_tail_x15_r0_body.cx0_190.mlx) :
    Conv.MFoot PRE_first_tail_x15_r0_body.P190 8201 PRE_first_tail_x15_r0_body.kappa190 PRE_first_tail_x15_r0_body.kd190 PRE_first_tail_x15_r0_body.khinv190 PRE_first_tail_x15_r0_body.kninv190 (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1835.ffi).mlx PRE_first_tail_x15_r0_body.cx0_190.mlx PRE_first_tail_x15_r0_body.cx1_190.mlx (⟨21950, 19047, 2824365, 8201⟩ : Conv.Cnt) PRE_first_tail_x15_r0_body.clo190 PRE_first_tail_x15_r0_body.cln190 PRE_first_tail_x15_r0_body.cli190 PRE_first_tail_x15_r0_body.cwS190 PRE_first_tail_x15_r0_body.cnS190 PRE_first_tail_x15_r0_body.ciS190 :=
  ⟨rfl, rfl, rfl, PRE_first_tail_x15_r0_body.cnh0190, PRE_first_tail_x15_r0_body.cnh1190, PRE_first_tail_x15_r0_body.cnn0190, PRE_first_tail_x15_r0_body.cnn1190, PRE_first_tail_x15_r0_body.cplo190, PRE_first_tail_x15_r0_body.ccnt190, PRE_first_tail_x15_r0_body.cnband190, PRE_first_tail_x15_r0_body.chbelow190, PRE_first_tail_x15_r0_body.chren190, PRE_first_tail_x15_r0_body.cband190, PRE_first_tail_x15_r0_body.cnh1pos190, PRE_first_tail_x15_r0_body.cnren190, PRE_first_tail_x15_r0_body.cnlow190, PRE_first_tail_x15_r0_body.cabs0a190, PRE_first_tail_x15_r0_body.cabs0b190, PRE_first_tail_x15_r0_body.ctok1190, PRE_first_tail_x15_r0_body.cpend190, PRE_first_tail_x15_r0_body.cerrh190, PRE_first_tail_x15_r0_body.cfiles190, PRE_first_tail_x15_r0_body.carch190, PRE_first_tail_x15_r0_body.csizes190, PRE_first_tail_x15_r0_body.cwired190, PRE_first_tail_x15_r0_body.cfix190, clean, PRE_first_tail_x15_r0_body.fcxn190, PRE_first_tail_x15_r0_body.fcnn190, hltC, nltC, itemsC, tracedC, cl, PRE_first_tail_x15_r0_body.fle0190, PRE_first_tail_x15_r0_body.fnk190, PRE_first_tail_x15_r0_body.ckA190, PRE_first_tail_x15_r0_body.cobjsK190, PRE_first_tail_x15_r0_body.cnodesK190, PRE_first_tail_x15_r0_body.citemsK190, PRE_first_tail_x15_r0_body.f1A190, PRE_first_tail_x15_r0_body.f1O190, PRE_first_tail_x15_r0_body.f1N190, PRE_first_tail_x15_r0_body.f1I190, PRE_first_tail_x15_r0_body.fbd190, PRE_first_tail_x15_r0_body.fincW190, PRE_first_tail_x15_r0_body.fincI190, PRE_first_tail_x15_r0_body.fincN190, PRE_first_tail_x15_r0_body.flnF190, PRE_first_tail_x15_r0_body.fh190, PRE_first_tail_x15_r0_body.fo190, PRE_first_tail_x15_r0_body.fok190, PRE_first_tail_x15_r0_body.fnd190, PRE_first_tail_x15_r0_body.fp190, PRE_first_tail_x15_r0_body.fnord190, PRE_first_tail_x15_r0_body.fi190, PRE_first_tail_x15_r0_body.fii190⟩
theorem PRE_first_tail_x15_r0_body.cnshift190 (clean : Conv.NClean (⟨21950, 19047, 2824365, 8201⟩ : Conv.Cnt) (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1835.ffi).mlx) (hltC : ∀ h, PH (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1835.ffi).mlx h → h < (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1835.ffi).mlx.next) (nltC : ∀ i, PN (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1835.ffi).mlx i → i < (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1835.ffi).mlx.nnext) (itemsC : ∀ k v, (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1835.ffi).mlx.items.get k = some v → PN (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1835.ffi).mlx k) (tracedC : ∀ h o, (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1835.ffi).mlx.objs.get h = some o → ∀ i ∈ objTraces o, i < PRE_first_tail_x15_r0_body.P190.NL) (cl : SSt (· < 8201) PRE_first_tail_x15_r0_body.cx0_190.mlx) : NShift PRE_first_tail_x15_r0_body.P190 8201 PRE_first_tail_x15_r0_body.kappa190 PRE_first_tail_x15_r0_body.cx0_190 PRE_first_tail_x15_r0_body.cx1_190 :=
  Conv.nshift_of_foot (PRE_first_tail_x15_r0_body.cfoot190 clean hltC nltC itemsC tracedC cl) PRE_first_tail_x15_r0_body.chost190 (compact_a_eq PRE_first_tail_x15_r0_body.ckn0190 PRE_first_tail_x15_r0_body.ckn1190 PRE_first_tail_x15_r0_body.ckheap190 PRE_first_tail_x15_r0_body.ckpl190)

-- the observers: the layers' states at the call, the canonical and the merged state, their footprints and checks
noncomputable def PRE_first_tail_x15_r0_body.fxC_190 : PTrie Unit := (Host.Ts.Sim.Full.freedOf PRE_first_tail_x15_r0_body.s1835.ffi).getD PTrie.nil
noncomputable def PRE_first_tail_x15_r0_body.krC_190 : Host.Load.Layers.KRec := (Host.Ts.Sim.Full.krecOf PRE_first_tail_x15_r0_body.s1835.ffi).getD Host.Load.Layers.KRec.empty
kernel_rfl PRE_first_tail_x15_r0_body.ofxC_190 : (Host.Ts.Sim.Full.freedOf PRE_first_tail_x15_r0_body.s1835.ffi) = some PRE_first_tail_x15_r0_body.fxC_190
kernel_rfl PRE_first_tail_x15_r0_body.okrC_190 : (Host.Ts.Sim.Full.krecOf PRE_first_tail_x15_r0_body.s1835.ffi) = some PRE_first_tail_x15_r0_body.krC_190
noncomputable def PRE_first_tail_x15_r0_body.fx0_190 : PTrie Unit := (Host.Ts.Sim.Full.freedOf PRE_first_tail_x15_r0_body.s1837.ffi).getD PTrie.nil
noncomputable def PRE_first_tail_x15_r0_body.kr0_190 : Host.Load.Layers.KRec := (Host.Ts.Sim.Full.krecOf PRE_first_tail_x15_r0_body.s1837.ffi).getD Host.Load.Layers.KRec.empty
kernel_rfl PRE_first_tail_x15_r0_body.ofx0_190 : (Host.Ts.Sim.Full.freedOf PRE_first_tail_x15_r0_body.s1837.ffi) = some PRE_first_tail_x15_r0_body.fx0_190
kernel_rfl PRE_first_tail_x15_r0_body.okr0_190 : (Host.Ts.Sim.Full.krecOf PRE_first_tail_x15_r0_body.s1837.ffi) = some PRE_first_tail_x15_r0_body.kr0_190
noncomputable def PRE_first_tail_x15_r0_body.fx1_190 : PTrie Unit := (Host.Ts.Sim.Full.freedOf PRE_first_tail_x15_r0_body.s1836.ffi).getD PTrie.nil
noncomputable def PRE_first_tail_x15_r0_body.kr1_190 : Host.Load.Layers.KRec := (Host.Ts.Sim.Full.krecOf PRE_first_tail_x15_r0_body.s1836.ffi).getD Host.Load.Layers.KRec.empty
kernel_rfl PRE_first_tail_x15_r0_body.ofx1_190 : (Host.Ts.Sim.Full.freedOf PRE_first_tail_x15_r0_body.s1836.ffi) = some PRE_first_tail_x15_r0_body.fx1_190
kernel_rfl PRE_first_tail_x15_r0_body.okr1_190 : (Host.Ts.Sim.Full.krecOf PRE_first_tail_x15_r0_body.s1836.ffi) = some PRE_first_tail_x15_r0_body.kr1_190
kernel_rfl PRE_first_tail_x15_r0_body.ff0190 : PRE_first_tail_x15_r0_body.fx0_190 = Stage.setAll PRE_first_tail_x15_r0_body.fxC_190 (PRE_first_tail_x15_r0_body.clo190.filterMap fun i => (PRE_first_tail_x15_r0_body.fx0_190.get i).map (i, ·))
kernel_rfl PRE_first_tail_x15_r0_body.ff1190 : PRE_first_tail_x15_r0_body.fx1_190 = Stage.setAll PRE_first_tail_x15_r0_body.fxC_190 (PRE_first_tail_x15_r0_body.cwS190.filterMap fun i => (PRE_first_tail_x15_r0_body.fx1_190.get i).map (i, ·))
kernel_rfl PRE_first_tail_x15_r0_body.ffck190 : freedLB PRE_first_tail_x15_r0_body.kappa190 PRE_first_tail_x15_r0_body.cx0_190.mlx PRE_first_tail_x15_r0_body.fx0_190 PRE_first_tail_x15_r0_body.fx1_190 PRE_first_tail_x15_r0_body.clo190 = true
kernel_rfl PRE_first_tail_x15_r0_body.fkf0190 : PRE_first_tail_x15_r0_body.kr0_190.flags = Stage.setAll PRE_first_tail_x15_r0_body.krC_190.flags (PRE_first_tail_x15_r0_body.clo190.filterMap fun i => (PRE_first_tail_x15_r0_body.kr0_190.flags.get i).map (i, ·))
kernel_rfl PRE_first_tail_x15_r0_body.fkt0190 : PRE_first_tail_x15_r0_body.kr0_190.targs = Stage.setAll PRE_first_tail_x15_r0_body.krC_190.targs (PRE_first_tail_x15_r0_body.clo190.filterMap fun i => (PRE_first_tail_x15_r0_body.kr0_190.targs.get i).map (i, ·))
kernel_rfl PRE_first_tail_x15_r0_body.fkf1190 : PRE_first_tail_x15_r0_body.kr1_190.flags = Stage.setAll PRE_first_tail_x15_r0_body.krC_190.flags (PRE_first_tail_x15_r0_body.cwS190.filterMap fun i => (PRE_first_tail_x15_r0_body.kr1_190.flags.get i).map (i, ·))
kernel_rfl PRE_first_tail_x15_r0_body.fkt1190 : PRE_first_tail_x15_r0_body.kr1_190.targs = Stage.setAll PRE_first_tail_x15_r0_body.krC_190.targs (PRE_first_tail_x15_r0_body.cwS190.filterMap fun i => (PRE_first_tail_x15_r0_body.kr1_190.targs.get i).map (i, ·))
kernel_rfl PRE_first_tail_x15_r0_body.fkck190 : krecLB PRE_first_tail_x15_r0_body.kappa190 8201 PRE_first_tail_x15_r0_body.cx0_190.mlx PRE_first_tail_x15_r0_body.kr0_190 PRE_first_tail_x15_r0_body.kr1_190 PRE_first_tail_x15_r0_body.clo190 = true
kernel_rfl PRE_first_tail_x15_r0_body.fkn190 : Nat.ble 8201 8201 = true
-- the bridge and the pending traces' regions
kernel_rfl PRE_first_tail_x15_r0_body.cbridge190 : Host.Ts.Sim.Full.bridgeOf PRE_first_tail_x15_r0_body.s1836.ffi = Host.Ts.Sim.Full.bridgeOf PRE_first_tail_x15_r0_body.s1837.ffi
kernel_rfl PRE_first_tail_x15_r0_body.cpendR190 : pendRegB PRE_first_tail_x15_r0_body.kappa190 (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1837.ffi).mlx = true
kernel_rfl PRE_first_tail_x15_r0_body.cpendLe190 : Nat.ble (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1837.ffi).mlx.next (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1836.ffi).mlx.next = true
/-- **The compaction's native shift**, given the call's bookkeeping, its relation's facts (the model's and the
observers') and the canonical closedness. -/
theorem PRE_first_tail_x15_r0_body.cshift190 (clean : Conv.NClean (⟨21950, 19047, 2824365, 8201⟩ : Conv.Cnt) (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1835.ffi).mlx) (hltC : ∀ h, PH (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1835.ffi).mlx h → h < (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1835.ffi).mlx.next) (nltC : ∀ i, PN (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1835.ffi).mlx i → i < (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1835.ffi).mlx.nnext) (itemsC : ∀ k v, (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1835.ffi).mlx.items.get k = some v → PN (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1835.ffi).mlx k) (tracedC : ∀ h o, (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1835.ffi).mlx.objs.get h = some o → ∀ i ∈ objTraces o, i < PRE_first_tail_x15_r0_body.P190.NL) (cl : SSt (· < 8201) PRE_first_tail_x15_r0_body.cx0_190.mlx)
    (hobjC : ∀ h, PRE_first_tail_x15_r0_body.fxC_190.get h = some () → ((Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1835.ffi).mlx.objs.get h).isSome = true)
    (hfC : ∀ h, (PRE_first_tail_x15_r0_body.krC_190.flags.get h).isSome = true → ((Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1835.ffi).mlx.objs.get h).isSome = true)
    (htC : ∀ h, (PRE_first_tail_x15_r0_body.krC_190.targs.get h).isSome = true → ((Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1835.ffi).mlx.objs.get h).isSome = true)
    (hclC : ∀ h l, PRE_first_tail_x15_r0_body.krC_190.targs.get h = some l → Host.Ts.Sim.Full.STargs (· < (⟨21950, 19047, 2824365, 8201⟩ : Conv.Cnt).n) l) :
    Conv.FullShiftQ PRE_first_tail_x15_r0_body.P190 8201 PRE_first_tail_x15_r0_body.kappa190 PRE_first_tail_x15_r0_body.s1837.ffi PRE_first_tail_x15_r0_body.s1836.ffi :=
  ⟨PRE_first_tail_x15_r0_body.cnshift190 clean hltC nltC itemsC tracedC cl, PRE_first_tail_x15_r0_body.cqueue190, fun t ht => bSN_sound (List.all_eq_true.mp PRE_first_tail_x15_r0_body.ctokSupp190 t ht),
    PRE_first_tail_x15_r0_body.cbridge190,
    liveShift_foot (x0' := Host.Ts.Sim.Full.mlxOf PRE_first_tail_x15_r0_body.s1837.ffi) (x1' := Host.Ts.Sim.Full.mlxOf PRE_first_tail_x15_r0_body.s1836.ffi) (PRE_first_tail_x15_r0_body.cfoot190 clean hltC nltC itemsC tracedC cl) rfl PRE_first_tail_x15_r0_body.ofx0_190 PRE_first_tail_x15_r0_body.ofx1_190 hobjC PRE_first_tail_x15_r0_body.ff0190 PRE_first_tail_x15_r0_body.ff1190 PRE_first_tail_x15_r0_body.ffck190,
    kernShift_foot (x0' := Host.Ts.Sim.Full.mlxOf PRE_first_tail_x15_r0_body.s1837.ffi) (x1' := Host.Ts.Sim.Full.mlxOf PRE_first_tail_x15_r0_body.s1836.ffi) (PRE_first_tail_x15_r0_body.cfoot190 clean hltC nltC itemsC tracedC cl) rfl PRE_first_tail_x15_r0_body.okr0_190 PRE_first_tail_x15_r0_body.okr1_190 (Nat.le_of_ble_eq_true PRE_first_tail_x15_r0_body.fkn190) hfC htC hclC
      PRE_first_tail_x15_r0_body.fkf0190 PRE_first_tail_x15_r0_body.fkt0190 PRE_first_tail_x15_r0_body.fkf1190 PRE_first_tail_x15_r0_body.fkt1190 PRE_first_tail_x15_r0_body.fkck190,
    pendReg_of rfl PRE_first_tail_x15_r0_body.cnh0190 PRE_first_tail_x15_r0_body.cnh1190 (Nat.le_of_ble_eq_true PRE_first_tail_x15_r0_body.cpendLe190) PRE_first_tail_x15_r0_body.cpendR190⟩

end Host.Load.Run.Tpl
