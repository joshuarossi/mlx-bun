import host.sim.template.a4pre_first_tail_x15_r0_body.SiteCl20
import host.sim.conv.CompactFull
import host.sim.template.FootGen
set_option Elab.async false
namespace Host.Load.Run.Tpl
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
open Host.Ts Host.Ts.Sim Host.Ts.Sim.Template

/-! The compaction's native shift at call site 20 from its footprint (`Conv.nshift_of_foot`), and the observers'
(`liveShift_foot`, `kernShift_foot`): `Conv.FullShiftQ` for `Conv.full_compactQ`, given the call's bookkeeping and its
relation's facts. -/

/-- The load parameters of the chain (band-free: its start's node counter as `NL` and `N0`). -/
def PRE_first_tail_x15_r0_body.Pc20 : LoadP := ⟨18151, 131072, 1099511627776, 15235, 15235, []⟩
/-- The site's band raised to the map's checked fixed-node prefix, including newly recorded closure traces. -/
def PRE_first_tail_x15_r0_body.P20 : LoadP := PRE_first_tail_x15_r0_body.Pc20.raise 15685
kernel_rfl PRE_first_tail_x15_r0_body.craise20 : Nat.ble PRE_first_tail_x15_r0_body.Pc20.N0 15685 = true
theorem PRE_first_tail_x15_r0_body.raised20 : Host.Ts.Sim.Full.Raised PRE_first_tail_x15_r0_body.Pc20 PRE_first_tail_x15_r0_body.P20 :=
  .inr ⟨15685, rfl, Nat.le_of_ble_eq_true PRE_first_tail_x15_r0_body.craise20, rfl⟩
noncomputable abbrev PRE_first_tail_x15_r0_body.cx0_20 : Host.Load.LSt := clearTokens (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s203.ffi)
noncomputable abbrev PRE_first_tail_x15_r0_body.cx1_20 : Host.Load.LSt := clearTokens (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s202.ffi)
def PRE_first_tail_x15_r0_body.khinv20 : PTrie Nat := Stage.setAll PTrie.nil []
def PRE_first_tail_x15_r0_body.kninv20 : PTrie Nat := Stage.setAll PTrie.nil []
/-- The stage's footprint: its written and fresh handles, fresh nodes, written and fresh items. -/
def PRE_first_tail_x15_r0_body.cwS20 : List Nat := []
def PRE_first_tail_x15_r0_body.cnS20 : List Nat := List.range' 15685 0
def PRE_first_tail_x15_r0_body.ciS20 : List Nat := [] ++ List.range' 15685 0

-- the small checks (`MChecks`'s)
kernel_rfl PRE_first_tail_x15_r0_body.cnh020 : PRE_first_tail_x15_r0_body.kd20.nh0 = PRE_first_tail_x15_r0_body.cx0_20.mlx.next
kernel_rfl PRE_first_tail_x15_r0_body.cnh120 : PRE_first_tail_x15_r0_body.kd20.nh1 = PRE_first_tail_x15_r0_body.cx1_20.mlx.next
kernel_rfl PRE_first_tail_x15_r0_body.cnn020 : PRE_first_tail_x15_r0_body.kd20.nn0 = PRE_first_tail_x15_r0_body.cx0_20.mlx.nnext
kernel_rfl PRE_first_tail_x15_r0_body.cnn120 : PRE_first_tail_x15_r0_body.kd20.nn1 = PRE_first_tail_x15_r0_body.cx1_20.mlx.nnext
kernel_rfl PRE_first_tail_x15_r0_body.cplo20 : (Nat.blt 0 PRE_first_tail_x15_r0_body.P20.lo && Nat.ble PRE_first_tail_x15_r0_body.P20.lo PRE_first_tail_x15_r0_body.cx0_20.mlx.next && Nat.ble PRE_first_tail_x15_r0_body.P20.lo RData.bigHi && Nat.ble RData.bigHi PRE_first_tail_x15_r0_body.P20.E) = true
kernel_rfl PRE_first_tail_x15_r0_body.ccnt20 : (Nat.ble PRE_first_tail_x15_r0_body.cx0_20.mlx.next PRE_first_tail_x15_r0_body.cx1_20.mlx.next && Nat.ble PRE_first_tail_x15_r0_body.cx0_20.mlx.nnext PRE_first_tail_x15_r0_body.cx1_20.mlx.nnext) = true
kernel_rfl PRE_first_tail_x15_r0_body.cnband20 : (Nat.blt 0 PRE_first_tail_x15_r0_body.P20.NL && Nat.ble PRE_first_tail_x15_r0_body.P20.NL PRE_first_tail_x15_r0_body.P20.N0 && Nat.ble PRE_first_tail_x15_r0_body.P20.N0 PRE_first_tail_x15_r0_body.cx0_20.mlx.nnext) = true
kernel_rfl PRE_first_tail_x15_r0_body.chbelow20 : PRE_first_tail_x15_r0_body.kd20.checkHndBelow = true
kernel_rfl PRE_first_tail_x15_r0_body.chren20 : checkRenG PRE_first_tail_x15_r0_body.kd20.hnd PRE_first_tail_x15_r0_body.khinv20 (phB PRE_first_tail_x15_r0_body.cx0_20.mlx) = true
kernel_rfl PRE_first_tail_x15_r0_body.cband20 : PRE_first_tail_x15_r0_body.kd20.checkBand PRE_first_tail_x15_r0_body.P20.lo = true
kernel_rfl PRE_first_tail_x15_r0_body.cnh1pos20 : Nat.blt 0 PRE_first_tail_x15_r0_body.kd20.nh1 = true
kernel_rfl PRE_first_tail_x15_r0_body.cnren20 : checkRenG PRE_first_tail_x15_r0_body.kd20.node PRE_first_tail_x15_r0_body.kninv20 (pnB PRE_first_tail_x15_r0_body.cx0_20.mlx) = true
kernel_rfl PRE_first_tail_x15_r0_body.cnlow20 : (PTrie.keysA PRE_first_tail_x15_r0_body.kd20.node).all (fun j => Nat.ble PRE_first_tail_x15_r0_body.P20.NL j && Nat.blt (PRE_first_tail_x15_r0_body.kd20.nodeF j) PRE_first_tail_x15_r0_body.cx1_20.mlx.nnext) = true
kernel_rfl PRE_first_tail_x15_r0_body.cabs0a20 : PRE_first_tail_x15_r0_body.cx0_20.mlx.arrs.get 0 = none
kernel_rfl PRE_first_tail_x15_r0_body.cabs0b20 : PRE_first_tail_x15_r0_body.cx0_20.mlx.objs.get 0 = none
kernel_rfl PRE_first_tail_x15_r0_body.ctok120 : PRE_first_tail_x15_r0_body.cx1_20.mlx.tokens = []
kernel_rfl PRE_first_tail_x15_r0_body.cpend20 : PRE_first_tail_x15_r0_body.cx1_20.mlx.pending = PRE_first_tail_x15_r0_body.cx0_20.mlx.pending.map PRE_first_tail_x15_r0_body.kappa20.pend
kernel_rfl PRE_first_tail_x15_r0_body.cerrh20 : PRE_first_tail_x15_r0_body.cx1_20.mlx.errh = PRE_first_tail_x15_r0_body.cx0_20.mlx.errh.map PRE_first_tail_x15_r0_body.kappa20.arg
kernel_rfl PRE_first_tail_x15_r0_body.cfiles20 : PRE_first_tail_x15_r0_body.cx1_20.mlx.files = PRE_first_tail_x15_r0_body.cx0_20.mlx.files
kernel_rfl PRE_first_tail_x15_r0_body.carch20 : PRE_first_tail_x15_r0_body.cx1_20.mlx.arch = PRE_first_tail_x15_r0_body.cx0_20.mlx.arch
kernel_rfl PRE_first_tail_x15_r0_body.csizes20 : PRE_first_tail_x15_r0_body.cx1_20.mlx.deviceSizes = PRE_first_tail_x15_r0_body.cx0_20.mlx.deviceSizes
kernel_rfl PRE_first_tail_x15_r0_body.cwired20 : PRE_first_tail_x15_r0_body.cx1_20.mlx.wired = PRE_first_tail_x15_r0_body.cx0_20.mlx.wired
kernel_rfl PRE_first_tail_x15_r0_body.chost20 : PRE_first_tail_x15_r0_body.cx1_20.host = PRE_first_tail_x15_r0_body.cx0_20.host
-- the compaction map's addresses are `PRE_first_tail_x15_r0_body.kd20`'s
kernel_rfl PRE_first_tail_x15_r0_body.ckn020 : PRE_first_tail_x15_r0_body.kd20.n0 = 2690172
kernel_rfl PRE_first_tail_x15_r0_body.ckn120 : PRE_first_tail_x15_r0_body.kd20.n1 = 2690182
kernel_rfl PRE_first_tail_x15_r0_body.ckheap20 : (PTrie.keysA PRE_first_tail_x15_r0_body.kd20.heap).all (fun x => Nat.ble 2690171 x) = true
kernel_rfl PRE_first_tail_x15_r0_body.ckpl20 : (List.range 1).all (fun j => decide (PRE_first_tail_x15_r0_body.kd20.heap.get (2690171 + j) = nth? PRE_first_tail_x15_r0_body.pl20 j)) = true
-- the map fixes the call's names (`Conv.fixOld_compact`), the call's counters
kernel_rfl PRE_first_tail_x15_r0_body.fja20 : Nat.ble 2690171 2690171 = true
kernel_rfl PRE_first_tail_x15_r0_body.fn20 : Nat.ble 910 910 = true
kernel_rfl PRE_first_tail_x15_r0_body.fjaD20 : Nat.ble 2690171 PRE_first_tail_x15_r0_body.kd20.n0 = true
kernel_rfl PRE_first_tail_x15_r0_body.fxn20 : Nat.ble 18589 PRE_first_tail_x15_r0_body.kd20.nh0 = true
kernel_rfl PRE_first_tail_x15_r0_body.fnn20 : Nat.ble 15685 PRE_first_tail_x15_r0_body.kd20.nn0 = true
kernel_rfl PRE_first_tail_x15_r0_body.fxb20 : Nat.ble 18589 RData.bigHi = true
kernel_rfl PRE_first_tail_x15_r0_body.fheap20 : (PTrie.keysA PRE_first_tail_x15_r0_body.kd20.heap).all (Nat.ble (⟨18589, 15685, 2690171, 910⟩ : Conv.Cnt).ja) = true
kernel_rfl PRE_first_tail_x15_r0_body.fhnd20 : (PTrie.keysA PRE_first_tail_x15_r0_body.kd20.hnd).all (Nat.ble (⟨18589, 15685, 2690171, 910⟩ : Conv.Cnt).xn) = true
kernel_rfl PRE_first_tail_x15_r0_body.fnode20 : (PTrie.keysA PRE_first_tail_x15_r0_body.kd20.node).all (Nat.ble (⟨18589, 15685, 2690171, 910⟩ : Conv.Cnt).nn) = true
/-- The compaction map fixes the call's names. -/
theorem PRE_first_tail_x15_r0_body.cfix20 : Conv.FixOld (⟨18589, 15685, 2690171, 910⟩ : Conv.Cnt) PRE_first_tail_x15_r0_body.kappa20 :=
  Conv.fixOld_compact (Nat.le_of_ble_eq_true PRE_first_tail_x15_r0_body.fja20) (Nat.le_of_ble_eq_true PRE_first_tail_x15_r0_body.fn20) (Nat.le_of_ble_eq_true PRE_first_tail_x15_r0_body.fjaD20) (Nat.le_of_ble_eq_true PRE_first_tail_x15_r0_body.fxn20) (Nat.le_of_ble_eq_true PRE_first_tail_x15_r0_body.fnn20) (Nat.le_of_ble_eq_true PRE_first_tail_x15_r0_body.fxb20) PRE_first_tail_x15_r0_body.fheap20 PRE_first_tail_x15_r0_body.fhnd20 PRE_first_tail_x15_r0_body.fnode20
kernel_rfl PRE_first_tail_x15_r0_body.fcxn20 : (⟨18589, 15685, 2690171, 910⟩ : Conv.Cnt).xn = (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s201.ffi).mlx.next
kernel_rfl PRE_first_tail_x15_r0_body.fcnn20 : (⟨18589, 15685, 2690171, 910⟩ : Conv.Cnt).nn = (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s201.ffi).mlx.nnext
kernel_rfl PRE_first_tail_x15_r0_body.fle020 : (Nat.ble (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s201.ffi).mlx.next PRE_first_tail_x15_r0_body.cx0_20.mlx.next && Nat.ble (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s201.ffi).mlx.nnext PRE_first_tail_x15_r0_body.cx0_20.mlx.nnext && Nat.ble (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s201.ffi).mlx.next RData.bigHi) = true
kernel_rfl PRE_first_tail_x15_r0_body.fnk20 : (PTrie.keysA PRE_first_tail_x15_r0_body.kd20.node).all (Nat.ble (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s201.ffi).mlx.nnext) = true
-- the merged state keeps the call's entries off the stage's footprint
kernel_rfl PRE_first_tail_x15_r0_body.f1A20 : PRE_first_tail_x15_r0_body.cx1_20.mlx.arrs = Stage.setAll (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s201.ffi).mlx.arrs (PRE_first_tail_x15_r0_body.cwS20.filterMap fun i => (PRE_first_tail_x15_r0_body.cx1_20.mlx.arrs.get i).map (i, ·))
kernel_rfl PRE_first_tail_x15_r0_body.f1O20 : PRE_first_tail_x15_r0_body.cx1_20.mlx.objs = Stage.setAll (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s201.ffi).mlx.objs (PRE_first_tail_x15_r0_body.cwS20.filterMap fun i => (PRE_first_tail_x15_r0_body.cx1_20.mlx.objs.get i).map (i, ·))
kernel_rfl PRE_first_tail_x15_r0_body.f1N20 : PRE_first_tail_x15_r0_body.cx1_20.mlx.nodes = Stage.setAll (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s201.ffi).mlx.nodes (PRE_first_tail_x15_r0_body.cnS20.filterMap fun i => (PRE_first_tail_x15_r0_body.cx1_20.mlx.nodes.get i).map (i, ·))
kernel_rfl PRE_first_tail_x15_r0_body.f1I20 : PRE_first_tail_x15_r0_body.cx1_20.mlx.items = Stage.setAll (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s201.ffi).mlx.items (PRE_first_tail_x15_r0_body.ciS20.filterMap fun i => (PRE_first_tail_x15_r0_body.cx1_20.mlx.items.get i).map (i, ·))
kernel_rfl PRE_first_tail_x15_r0_body.fbd20 : (PRE_first_tail_x15_r0_body.clo20 ++ PRE_first_tail_x15_r0_body.cln20 ++ PRE_first_tail_x15_r0_body.cli20 ++ PRE_first_tail_x15_r0_body.cwS20 ++ PRE_first_tail_x15_r0_body.cnS20 ++ PRE_first_tail_x15_r0_body.ciS20).all (fun i => Nat.blt (i / 4096) (4 ^ 31)) = true
kernel_rfl PRE_first_tail_x15_r0_body.fincW20 : PRE_first_tail_x15_r0_body.cwS20.all (fun h => !Nat.blt h (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s201.ffi).mlx.next || PRE_first_tail_x15_r0_body.clo20.contains h) = true
kernel_rfl PRE_first_tail_x15_r0_body.fincI20 : PRE_first_tail_x15_r0_body.ciS20.all (fun k => !Nat.blt k (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s201.ffi).mlx.nnext || PRE_first_tail_x15_r0_body.cli20.contains k) = true
kernel_rfl PRE_first_tail_x15_r0_body.fincN20 : PRE_first_tail_x15_r0_body.cnS20.all (Nat.ble (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s201.ffi).mlx.nnext) = true
kernel_rfl PRE_first_tail_x15_r0_body.flnF20 : PRE_first_tail_x15_r0_body.cln20.all (Nat.ble (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s201.ffi).mlx.nnext) = true
-- the checks over the changed lists
kernel_rfl PRE_first_tail_x15_r0_body.fh20 : PRE_first_tail_x15_r0_body.clo20.all (handleOK PRE_first_tail_x15_r0_body.kappa20 PRE_first_tail_x15_r0_body.P20.lo PRE_first_tail_x15_r0_body.cx0_20.mlx PRE_first_tail_x15_r0_body.cx1_20.mlx) = true
kernel_rfl PRE_first_tail_x15_r0_body.fo20 : PRE_first_tail_x15_r0_body.clo20.map (fun h => PRE_first_tail_x15_r0_body.cx1_20.mlx.objs.get (PRE_first_tail_x15_r0_body.kappa20.handle h)) = PRE_first_tail_x15_r0_body.clo20.map (fun h => (PRE_first_tail_x15_r0_body.cx0_20.mlx.objs.get h).map PRE_first_tail_x15_r0_body.kappa20.nobj)
kernel_rfl PRE_first_tail_x15_r0_body.fok20 : PRE_first_tail_x15_r0_body.clo20.all (objOK PRE_first_tail_x15_r0_body.kappa20 PRE_first_tail_x15_r0_body.P20.NL PRE_first_tail_x15_r0_body.cx0_20.mlx) = true
kernel_rfl PRE_first_tail_x15_r0_body.fnd20 : PRE_first_tail_x15_r0_body.cln20.all (nodeOKF PRE_first_tail_x15_r0_body.kappa20 PRE_first_tail_x15_r0_body.P20 PRE_first_tail_x15_r0_body.cx0_20.mlx PRE_first_tail_x15_r0_body.cx1_20.mlx) = true
kernel_rfl PRE_first_tail_x15_r0_body.fp20 : ((PRE_first_tail_x15_r0_body.cln20.filter (fullB PRE_first_tail_x15_r0_body.P20))).map (fun i => (PRE_first_tail_x15_r0_body.cx1_20.mlx.nodes.get (PRE_first_tail_x15_r0_body.kappa20.node i)).map Host.Mlx.Ffi.Node.prim) =
  ((PRE_first_tail_x15_r0_body.cln20.filter (fullB PRE_first_tail_x15_r0_body.P20))).map (fun i => (PRE_first_tail_x15_r0_body.cx0_20.mlx.nodes.get i).map fun nd => PRE_first_tail_x15_r0_body.kappa20.prim nd.prim)
kernel_rfl PRE_first_tail_x15_r0_body.fnordI20 : incrB PRE_first_tail_x15_r0_body.kd20.nodeF (List.range' 15685 0) = true
kernel_rfl PRE_first_tail_x15_r0_body.fnordK20 : (PTrie.keysA PRE_first_tail_x15_r0_body.kd20.node).all (fun k => Nat.ble 15685 k && Nat.blt k 15685) = true
kernel_rfl PRE_first_tail_x15_r0_body.fnordL20 : (PRE_first_tail_x15_r0_body.cln20.filter (Nat.ble PRE_first_tail_x15_r0_body.P20.N0)).all (fun i => Nat.ble i (PRE_first_tail_x15_r0_body.kd20.nodeF i) && (Nat.blt i 15685 || Nat.ble PRE_first_tail_x15_r0_body.kd20.nn0 i)) = true
theorem PRE_first_tail_x15_r0_body.fnord20 : (PRE_first_tail_x15_r0_body.cln20.filter (Nat.ble PRE_first_tail_x15_r0_body.P20.N0)).all (fun i => Nat.ble i (PRE_first_tail_x15_r0_body.kd20.nodeF i) &&
    (PTrie.keysA PRE_first_tail_x15_r0_body.kd20.node).all fun j => !Nat.blt j i || Nat.blt (PRE_first_tail_x15_r0_body.kd20.nodeF j) (PRE_first_tail_x15_r0_body.kd20.nodeF i)) = true :=
  cnord_of PRE_first_tail_x15_r0_body.cnlow20 PRE_first_tail_x15_r0_body.cnn120 PRE_first_tail_x15_r0_body.fnordI20 PRE_first_tail_x15_r0_body.fnordK20 PRE_first_tail_x15_r0_body.fnordL20
kernel_rfl PRE_first_tail_x15_r0_body.fi20 : PRE_first_tail_x15_r0_body.cli20.all (pnB PRE_first_tail_x15_r0_body.cx0_20.mlx) = true
kernel_rfl PRE_first_tail_x15_r0_body.fii20 : PRE_first_tail_x15_r0_body.cli20.all (fun k => decide (PRE_first_tail_x15_r0_body.cx1_20.mlx.items.get (PRE_first_tail_x15_r0_body.kappa20.node k) = (PRE_first_tail_x15_r0_body.cx0_20.mlx.items.get k).map PRE_first_tail_x15_r0_body.kappa20.nv)) = true
/-- **The compaction's footprint.** -/
theorem PRE_first_tail_x15_r0_body.cfoot20 (clean : Conv.NClean (⟨18589, 15685, 2690171, 910⟩ : Conv.Cnt) (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s201.ffi).mlx) (hltC : ∀ h, PH (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s201.ffi).mlx h → h < (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s201.ffi).mlx.next) (nltC : ∀ i, PN (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s201.ffi).mlx i → i < (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s201.ffi).mlx.nnext) (itemsC : ∀ k v, (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s201.ffi).mlx.items.get k = some v → PN (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s201.ffi).mlx k) (tracedC : ∀ h o, (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s201.ffi).mlx.objs.get h = some o → ∀ i ∈ objTraces o, i < PRE_first_tail_x15_r0_body.P20.NL) (cl : SSt (· < 910) PRE_first_tail_x15_r0_body.cx0_20.mlx) :
    Conv.MFoot PRE_first_tail_x15_r0_body.P20 910 PRE_first_tail_x15_r0_body.kappa20 PRE_first_tail_x15_r0_body.kd20 PRE_first_tail_x15_r0_body.khinv20 PRE_first_tail_x15_r0_body.kninv20 (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s201.ffi).mlx PRE_first_tail_x15_r0_body.cx0_20.mlx PRE_first_tail_x15_r0_body.cx1_20.mlx (⟨18589, 15685, 2690171, 910⟩ : Conv.Cnt) PRE_first_tail_x15_r0_body.clo20 PRE_first_tail_x15_r0_body.cln20 PRE_first_tail_x15_r0_body.cli20 PRE_first_tail_x15_r0_body.cwS20 PRE_first_tail_x15_r0_body.cnS20 PRE_first_tail_x15_r0_body.ciS20 :=
  ⟨rfl, rfl, rfl, PRE_first_tail_x15_r0_body.cnh020, PRE_first_tail_x15_r0_body.cnh120, PRE_first_tail_x15_r0_body.cnn020, PRE_first_tail_x15_r0_body.cnn120, PRE_first_tail_x15_r0_body.cplo20, PRE_first_tail_x15_r0_body.ccnt20, PRE_first_tail_x15_r0_body.cnband20, PRE_first_tail_x15_r0_body.chbelow20, PRE_first_tail_x15_r0_body.chren20, PRE_first_tail_x15_r0_body.cband20, PRE_first_tail_x15_r0_body.cnh1pos20, PRE_first_tail_x15_r0_body.cnren20, PRE_first_tail_x15_r0_body.cnlow20, PRE_first_tail_x15_r0_body.cabs0a20, PRE_first_tail_x15_r0_body.cabs0b20, PRE_first_tail_x15_r0_body.ctok120, PRE_first_tail_x15_r0_body.cpend20, PRE_first_tail_x15_r0_body.cerrh20, PRE_first_tail_x15_r0_body.cfiles20, PRE_first_tail_x15_r0_body.carch20, PRE_first_tail_x15_r0_body.csizes20, PRE_first_tail_x15_r0_body.cwired20, PRE_first_tail_x15_r0_body.cfix20, clean, PRE_first_tail_x15_r0_body.fcxn20, PRE_first_tail_x15_r0_body.fcnn20, hltC, nltC, itemsC, tracedC, cl, PRE_first_tail_x15_r0_body.fle020, PRE_first_tail_x15_r0_body.fnk20, PRE_first_tail_x15_r0_body.ckA20, PRE_first_tail_x15_r0_body.cobjsK20, PRE_first_tail_x15_r0_body.cnodesK20, PRE_first_tail_x15_r0_body.citemsK20, PRE_first_tail_x15_r0_body.f1A20, PRE_first_tail_x15_r0_body.f1O20, PRE_first_tail_x15_r0_body.f1N20, PRE_first_tail_x15_r0_body.f1I20, PRE_first_tail_x15_r0_body.fbd20, PRE_first_tail_x15_r0_body.fincW20, PRE_first_tail_x15_r0_body.fincI20, PRE_first_tail_x15_r0_body.fincN20, PRE_first_tail_x15_r0_body.flnF20, PRE_first_tail_x15_r0_body.fh20, PRE_first_tail_x15_r0_body.fo20, PRE_first_tail_x15_r0_body.fok20, PRE_first_tail_x15_r0_body.fnd20, PRE_first_tail_x15_r0_body.fp20, PRE_first_tail_x15_r0_body.fnord20, PRE_first_tail_x15_r0_body.fi20, PRE_first_tail_x15_r0_body.fii20⟩
theorem PRE_first_tail_x15_r0_body.cnshift20 (clean : Conv.NClean (⟨18589, 15685, 2690171, 910⟩ : Conv.Cnt) (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s201.ffi).mlx) (hltC : ∀ h, PH (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s201.ffi).mlx h → h < (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s201.ffi).mlx.next) (nltC : ∀ i, PN (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s201.ffi).mlx i → i < (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s201.ffi).mlx.nnext) (itemsC : ∀ k v, (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s201.ffi).mlx.items.get k = some v → PN (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s201.ffi).mlx k) (tracedC : ∀ h o, (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s201.ffi).mlx.objs.get h = some o → ∀ i ∈ objTraces o, i < PRE_first_tail_x15_r0_body.P20.NL) (cl : SSt (· < 910) PRE_first_tail_x15_r0_body.cx0_20.mlx) : NShift PRE_first_tail_x15_r0_body.P20 910 PRE_first_tail_x15_r0_body.kappa20 PRE_first_tail_x15_r0_body.cx0_20 PRE_first_tail_x15_r0_body.cx1_20 :=
  Conv.nshift_of_foot (PRE_first_tail_x15_r0_body.cfoot20 clean hltC nltC itemsC tracedC cl) PRE_first_tail_x15_r0_body.chost20 (compact_a_eq PRE_first_tail_x15_r0_body.ckn020 PRE_first_tail_x15_r0_body.ckn120 PRE_first_tail_x15_r0_body.ckheap20 PRE_first_tail_x15_r0_body.ckpl20)

-- the observers: the layers' states at the call, the canonical and the merged state, their footprints and checks
noncomputable def PRE_first_tail_x15_r0_body.fxC_20 : PTrie Unit := (Host.Ts.Sim.Full.freedOf PRE_first_tail_x15_r0_body.s201.ffi).getD PTrie.nil
noncomputable def PRE_first_tail_x15_r0_body.krC_20 : Host.Load.Layers.KRec := (Host.Ts.Sim.Full.krecOf PRE_first_tail_x15_r0_body.s201.ffi).getD Host.Load.Layers.KRec.empty
kernel_rfl PRE_first_tail_x15_r0_body.ofxC_20 : (Host.Ts.Sim.Full.freedOf PRE_first_tail_x15_r0_body.s201.ffi) = some PRE_first_tail_x15_r0_body.fxC_20
kernel_rfl PRE_first_tail_x15_r0_body.okrC_20 : (Host.Ts.Sim.Full.krecOf PRE_first_tail_x15_r0_body.s201.ffi) = some PRE_first_tail_x15_r0_body.krC_20
noncomputable def PRE_first_tail_x15_r0_body.fx0_20 : PTrie Unit := (Host.Ts.Sim.Full.freedOf PRE_first_tail_x15_r0_body.s203.ffi).getD PTrie.nil
noncomputable def PRE_first_tail_x15_r0_body.kr0_20 : Host.Load.Layers.KRec := (Host.Ts.Sim.Full.krecOf PRE_first_tail_x15_r0_body.s203.ffi).getD Host.Load.Layers.KRec.empty
kernel_rfl PRE_first_tail_x15_r0_body.ofx0_20 : (Host.Ts.Sim.Full.freedOf PRE_first_tail_x15_r0_body.s203.ffi) = some PRE_first_tail_x15_r0_body.fx0_20
kernel_rfl PRE_first_tail_x15_r0_body.okr0_20 : (Host.Ts.Sim.Full.krecOf PRE_first_tail_x15_r0_body.s203.ffi) = some PRE_first_tail_x15_r0_body.kr0_20
noncomputable def PRE_first_tail_x15_r0_body.fx1_20 : PTrie Unit := (Host.Ts.Sim.Full.freedOf PRE_first_tail_x15_r0_body.s202.ffi).getD PTrie.nil
noncomputable def PRE_first_tail_x15_r0_body.kr1_20 : Host.Load.Layers.KRec := (Host.Ts.Sim.Full.krecOf PRE_first_tail_x15_r0_body.s202.ffi).getD Host.Load.Layers.KRec.empty
kernel_rfl PRE_first_tail_x15_r0_body.ofx1_20 : (Host.Ts.Sim.Full.freedOf PRE_first_tail_x15_r0_body.s202.ffi) = some PRE_first_tail_x15_r0_body.fx1_20
kernel_rfl PRE_first_tail_x15_r0_body.okr1_20 : (Host.Ts.Sim.Full.krecOf PRE_first_tail_x15_r0_body.s202.ffi) = some PRE_first_tail_x15_r0_body.kr1_20
kernel_rfl PRE_first_tail_x15_r0_body.ff020 : PRE_first_tail_x15_r0_body.fx0_20 = Stage.setAll PRE_first_tail_x15_r0_body.fxC_20 (PRE_first_tail_x15_r0_body.clo20.filterMap fun i => (PRE_first_tail_x15_r0_body.fx0_20.get i).map (i, ·))
kernel_rfl PRE_first_tail_x15_r0_body.ff120 : PRE_first_tail_x15_r0_body.fx1_20 = Stage.setAll PRE_first_tail_x15_r0_body.fxC_20 (PRE_first_tail_x15_r0_body.cwS20.filterMap fun i => (PRE_first_tail_x15_r0_body.fx1_20.get i).map (i, ·))
kernel_rfl PRE_first_tail_x15_r0_body.ffck20 : freedLB PRE_first_tail_x15_r0_body.kappa20 PRE_first_tail_x15_r0_body.cx0_20.mlx PRE_first_tail_x15_r0_body.fx0_20 PRE_first_tail_x15_r0_body.fx1_20 PRE_first_tail_x15_r0_body.clo20 = true
kernel_rfl PRE_first_tail_x15_r0_body.fkf020 : PRE_first_tail_x15_r0_body.kr0_20.flags = Stage.setAll PRE_first_tail_x15_r0_body.krC_20.flags (PRE_first_tail_x15_r0_body.clo20.filterMap fun i => (PRE_first_tail_x15_r0_body.kr0_20.flags.get i).map (i, ·))
kernel_rfl PRE_first_tail_x15_r0_body.fkt020 : PRE_first_tail_x15_r0_body.kr0_20.targs = Stage.setAll PRE_first_tail_x15_r0_body.krC_20.targs (PRE_first_tail_x15_r0_body.clo20.filterMap fun i => (PRE_first_tail_x15_r0_body.kr0_20.targs.get i).map (i, ·))
kernel_rfl PRE_first_tail_x15_r0_body.fkf120 : PRE_first_tail_x15_r0_body.kr1_20.flags = Stage.setAll PRE_first_tail_x15_r0_body.krC_20.flags (PRE_first_tail_x15_r0_body.cwS20.filterMap fun i => (PRE_first_tail_x15_r0_body.kr1_20.flags.get i).map (i, ·))
kernel_rfl PRE_first_tail_x15_r0_body.fkt120 : PRE_first_tail_x15_r0_body.kr1_20.targs = Stage.setAll PRE_first_tail_x15_r0_body.krC_20.targs (PRE_first_tail_x15_r0_body.cwS20.filterMap fun i => (PRE_first_tail_x15_r0_body.kr1_20.targs.get i).map (i, ·))
kernel_rfl PRE_first_tail_x15_r0_body.fkck20 : krecLB PRE_first_tail_x15_r0_body.kappa20 910 PRE_first_tail_x15_r0_body.cx0_20.mlx PRE_first_tail_x15_r0_body.kr0_20 PRE_first_tail_x15_r0_body.kr1_20 PRE_first_tail_x15_r0_body.clo20 = true
kernel_rfl PRE_first_tail_x15_r0_body.fkn20 : Nat.ble 910 910 = true
-- the bridge and the pending traces' regions
kernel_rfl PRE_first_tail_x15_r0_body.cbridge20 : Host.Ts.Sim.Full.bridgeOf PRE_first_tail_x15_r0_body.s202.ffi = Host.Ts.Sim.Full.bridgeOf PRE_first_tail_x15_r0_body.s203.ffi
kernel_rfl PRE_first_tail_x15_r0_body.cpendR20 : pendRegB PRE_first_tail_x15_r0_body.kappa20 (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s203.ffi).mlx = true
kernel_rfl PRE_first_tail_x15_r0_body.cpendLe20 : Nat.ble (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s203.ffi).mlx.next (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s202.ffi).mlx.next = true
/-- **The compaction's native shift**, given the call's bookkeeping, its relation's facts (the model's and the
observers') and the canonical closedness. -/
theorem PRE_first_tail_x15_r0_body.cshift20 (clean : Conv.NClean (⟨18589, 15685, 2690171, 910⟩ : Conv.Cnt) (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s201.ffi).mlx) (hltC : ∀ h, PH (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s201.ffi).mlx h → h < (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s201.ffi).mlx.next) (nltC : ∀ i, PN (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s201.ffi).mlx i → i < (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s201.ffi).mlx.nnext) (itemsC : ∀ k v, (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s201.ffi).mlx.items.get k = some v → PN (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s201.ffi).mlx k) (tracedC : ∀ h o, (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s201.ffi).mlx.objs.get h = some o → ∀ i ∈ objTraces o, i < PRE_first_tail_x15_r0_body.P20.NL) (cl : SSt (· < 910) PRE_first_tail_x15_r0_body.cx0_20.mlx)
    (hobjC : ∀ h, PRE_first_tail_x15_r0_body.fxC_20.get h = some () → ((Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s201.ffi).mlx.objs.get h).isSome = true)
    (hfC : ∀ h, (PRE_first_tail_x15_r0_body.krC_20.flags.get h).isSome = true → ((Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s201.ffi).mlx.objs.get h).isSome = true)
    (htC : ∀ h, (PRE_first_tail_x15_r0_body.krC_20.targs.get h).isSome = true → ((Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s201.ffi).mlx.objs.get h).isSome = true)
    (hclC : ∀ h l, PRE_first_tail_x15_r0_body.krC_20.targs.get h = some l → Host.Ts.Sim.Full.STargs (· < (⟨18589, 15685, 2690171, 910⟩ : Conv.Cnt).n) l) :
    Conv.FullShiftQ PRE_first_tail_x15_r0_body.P20 910 PRE_first_tail_x15_r0_body.kappa20 PRE_first_tail_x15_r0_body.s203.ffi PRE_first_tail_x15_r0_body.s202.ffi :=
  ⟨PRE_first_tail_x15_r0_body.cnshift20 clean hltC nltC itemsC tracedC cl, PRE_first_tail_x15_r0_body.cqueue20, fun t ht => bSN_sound (List.all_eq_true.mp PRE_first_tail_x15_r0_body.ctokSupp20 t ht),
    PRE_first_tail_x15_r0_body.cbridge20,
    liveShift_foot (x0' := Host.Ts.Sim.Full.mlxOf PRE_first_tail_x15_r0_body.s203.ffi) (x1' := Host.Ts.Sim.Full.mlxOf PRE_first_tail_x15_r0_body.s202.ffi) (PRE_first_tail_x15_r0_body.cfoot20 clean hltC nltC itemsC tracedC cl) rfl PRE_first_tail_x15_r0_body.ofx0_20 PRE_first_tail_x15_r0_body.ofx1_20 hobjC PRE_first_tail_x15_r0_body.ff020 PRE_first_tail_x15_r0_body.ff120 PRE_first_tail_x15_r0_body.ffck20,
    kernShift_foot (x0' := Host.Ts.Sim.Full.mlxOf PRE_first_tail_x15_r0_body.s203.ffi) (x1' := Host.Ts.Sim.Full.mlxOf PRE_first_tail_x15_r0_body.s202.ffi) (PRE_first_tail_x15_r0_body.cfoot20 clean hltC nltC itemsC tracedC cl) rfl PRE_first_tail_x15_r0_body.okr0_20 PRE_first_tail_x15_r0_body.okr1_20 (Nat.le_of_ble_eq_true PRE_first_tail_x15_r0_body.fkn20) hfC htC hclC
      PRE_first_tail_x15_r0_body.fkf020 PRE_first_tail_x15_r0_body.fkt020 PRE_first_tail_x15_r0_body.fkf120 PRE_first_tail_x15_r0_body.fkt120 PRE_first_tail_x15_r0_body.fkck20,
    pendReg_of rfl PRE_first_tail_x15_r0_body.cnh020 PRE_first_tail_x15_r0_body.cnh120 (Nat.le_of_ble_eq_true PRE_first_tail_x15_r0_body.cpendLe20) PRE_first_tail_x15_r0_body.cpendR20⟩

end Host.Load.Run.Tpl
