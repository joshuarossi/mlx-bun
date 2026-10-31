import host.sim.template.a4pre_first_tail_x15_r0_body.SiteCl100
import host.sim.conv.CompactFull
import host.sim.template.FootGen
set_option Elab.async false
namespace Host.Load.Run.Tpl
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
open Host.Ts Host.Ts.Sim Host.Ts.Sim.Template

/-! The compaction's native shift at call site 100 from its footprint (`Conv.nshift_of_foot`), and the observers'
(`liveShift_foot`, `kernShift_foot`): `Conv.FullShiftQ` for `Conv.full_compactQ`, given the call's bookkeeping and its
relation's facts. -/

/-- The load parameters of the chain (band-free: its start's node counter as `NL` and `N0`). -/
def PRE_first_tail_x15_r0_body.Pc100 : LoadP := ⟨18151, 131072, 1099511627776, 15235, 15235, []⟩
/-- The site's band raised to the map's checked fixed-node prefix, including newly recorded closure traces. -/
def PRE_first_tail_x15_r0_body.P100 : LoadP := PRE_first_tail_x15_r0_body.Pc100.raise 17277
kernel_rfl PRE_first_tail_x15_r0_body.craise100 : Nat.ble PRE_first_tail_x15_r0_body.Pc100.N0 17277 = true
theorem PRE_first_tail_x15_r0_body.raised100 : Host.Ts.Sim.Full.Raised PRE_first_tail_x15_r0_body.Pc100 PRE_first_tail_x15_r0_body.P100 :=
  .inr ⟨17277, rfl, Nat.le_of_ble_eq_true PRE_first_tail_x15_r0_body.craise100, rfl⟩
noncomputable abbrev PRE_first_tail_x15_r0_body.cx0_100 : Host.Load.LSt := clearTokens (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s975.ffi)
noncomputable abbrev PRE_first_tail_x15_r0_body.cx1_100 : Host.Load.LSt := clearTokens (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s974.ffi)
def PRE_first_tail_x15_r0_body.khinv100 : PTrie Nat := Stage.setAll PTrie.nil []
def PRE_first_tail_x15_r0_body.kninv100 : PTrie Nat := Stage.setAll PTrie.nil []
/-- The stage's footprint: its written and fresh handles, fresh nodes, written and fresh items. -/
def PRE_first_tail_x15_r0_body.cwS100 : List Nat := []
def PRE_first_tail_x15_r0_body.cnS100 : List Nat := List.range' 17277 0
def PRE_first_tail_x15_r0_body.ciS100 : List Nat := [] ++ List.range' 17277 0

-- the small checks (`MChecks`'s)
kernel_rfl PRE_first_tail_x15_r0_body.cnh0100 : PRE_first_tail_x15_r0_body.kd100.nh0 = PRE_first_tail_x15_r0_body.cx0_100.mlx.next
kernel_rfl PRE_first_tail_x15_r0_body.cnh1100 : PRE_first_tail_x15_r0_body.kd100.nh1 = PRE_first_tail_x15_r0_body.cx1_100.mlx.next
kernel_rfl PRE_first_tail_x15_r0_body.cnn0100 : PRE_first_tail_x15_r0_body.kd100.nn0 = PRE_first_tail_x15_r0_body.cx0_100.mlx.nnext
kernel_rfl PRE_first_tail_x15_r0_body.cnn1100 : PRE_first_tail_x15_r0_body.kd100.nn1 = PRE_first_tail_x15_r0_body.cx1_100.mlx.nnext
kernel_rfl PRE_first_tail_x15_r0_body.cplo100 : (Nat.blt 0 PRE_first_tail_x15_r0_body.P100.lo && Nat.ble PRE_first_tail_x15_r0_body.P100.lo PRE_first_tail_x15_r0_body.cx0_100.mlx.next && Nat.ble PRE_first_tail_x15_r0_body.P100.lo RData.bigHi && Nat.ble RData.bigHi PRE_first_tail_x15_r0_body.P100.E) = true
kernel_rfl PRE_first_tail_x15_r0_body.ccnt100 : (Nat.ble PRE_first_tail_x15_r0_body.cx0_100.mlx.next PRE_first_tail_x15_r0_body.cx1_100.mlx.next && Nat.ble PRE_first_tail_x15_r0_body.cx0_100.mlx.nnext PRE_first_tail_x15_r0_body.cx1_100.mlx.nnext) = true
kernel_rfl PRE_first_tail_x15_r0_body.cnband100 : (Nat.blt 0 PRE_first_tail_x15_r0_body.P100.NL && Nat.ble PRE_first_tail_x15_r0_body.P100.NL PRE_first_tail_x15_r0_body.P100.N0 && Nat.ble PRE_first_tail_x15_r0_body.P100.N0 PRE_first_tail_x15_r0_body.cx0_100.mlx.nnext) = true
kernel_rfl PRE_first_tail_x15_r0_body.chbelow100 : PRE_first_tail_x15_r0_body.kd100.checkHndBelow = true
kernel_rfl PRE_first_tail_x15_r0_body.chren100 : checkRenG PRE_first_tail_x15_r0_body.kd100.hnd PRE_first_tail_x15_r0_body.khinv100 (phB PRE_first_tail_x15_r0_body.cx0_100.mlx) = true
kernel_rfl PRE_first_tail_x15_r0_body.cband100 : PRE_first_tail_x15_r0_body.kd100.checkBand PRE_first_tail_x15_r0_body.P100.lo = true
kernel_rfl PRE_first_tail_x15_r0_body.cnh1pos100 : Nat.blt 0 PRE_first_tail_x15_r0_body.kd100.nh1 = true
kernel_rfl PRE_first_tail_x15_r0_body.cnren100 : checkRenG PRE_first_tail_x15_r0_body.kd100.node PRE_first_tail_x15_r0_body.kninv100 (pnB PRE_first_tail_x15_r0_body.cx0_100.mlx) = true
kernel_rfl PRE_first_tail_x15_r0_body.cnlow100 : (PTrie.keysA PRE_first_tail_x15_r0_body.kd100.node).all (fun j => Nat.ble PRE_first_tail_x15_r0_body.P100.NL j && Nat.blt (PRE_first_tail_x15_r0_body.kd100.nodeF j) PRE_first_tail_x15_r0_body.cx1_100.mlx.nnext) = true
kernel_rfl PRE_first_tail_x15_r0_body.cabs0a100 : PRE_first_tail_x15_r0_body.cx0_100.mlx.arrs.get 0 = none
kernel_rfl PRE_first_tail_x15_r0_body.cabs0b100 : PRE_first_tail_x15_r0_body.cx0_100.mlx.objs.get 0 = none
kernel_rfl PRE_first_tail_x15_r0_body.ctok1100 : PRE_first_tail_x15_r0_body.cx1_100.mlx.tokens = []
kernel_rfl PRE_first_tail_x15_r0_body.cpend100 : PRE_first_tail_x15_r0_body.cx1_100.mlx.pending = PRE_first_tail_x15_r0_body.cx0_100.mlx.pending.map PRE_first_tail_x15_r0_body.kappa100.pend
kernel_rfl PRE_first_tail_x15_r0_body.cerrh100 : PRE_first_tail_x15_r0_body.cx1_100.mlx.errh = PRE_first_tail_x15_r0_body.cx0_100.mlx.errh.map PRE_first_tail_x15_r0_body.kappa100.arg
kernel_rfl PRE_first_tail_x15_r0_body.cfiles100 : PRE_first_tail_x15_r0_body.cx1_100.mlx.files = PRE_first_tail_x15_r0_body.cx0_100.mlx.files
kernel_rfl PRE_first_tail_x15_r0_body.carch100 : PRE_first_tail_x15_r0_body.cx1_100.mlx.arch = PRE_first_tail_x15_r0_body.cx0_100.mlx.arch
kernel_rfl PRE_first_tail_x15_r0_body.csizes100 : PRE_first_tail_x15_r0_body.cx1_100.mlx.deviceSizes = PRE_first_tail_x15_r0_body.cx0_100.mlx.deviceSizes
kernel_rfl PRE_first_tail_x15_r0_body.cwired100 : PRE_first_tail_x15_r0_body.cx1_100.mlx.wired = PRE_first_tail_x15_r0_body.cx0_100.mlx.wired
kernel_rfl PRE_first_tail_x15_r0_body.chost100 : PRE_first_tail_x15_r0_body.cx1_100.host = PRE_first_tail_x15_r0_body.cx0_100.host
-- the compaction map's addresses are `PRE_first_tail_x15_r0_body.kd100`'s
kernel_rfl PRE_first_tail_x15_r0_body.ckn0100 : PRE_first_tail_x15_r0_body.kd100.n0 = 2753547
kernel_rfl PRE_first_tail_x15_r0_body.ckn1100 : PRE_first_tail_x15_r0_body.kd100.n1 = 2753549
kernel_rfl PRE_first_tail_x15_r0_body.ckheap100 : (PTrie.keysA PRE_first_tail_x15_r0_body.kd100.heap).all (fun x => Nat.ble 2753547 x) = true
kernel_rfl PRE_first_tail_x15_r0_body.ckpl100 : (List.range 0).all (fun j => decide (PRE_first_tail_x15_r0_body.kd100.heap.get (2753547 + j) = nth? PRE_first_tail_x15_r0_body.pl100 j)) = true
-- the map fixes the call's names (`Conv.fixOld_compact`), the call's counters
kernel_rfl PRE_first_tail_x15_r0_body.fja100 : Nat.ble 2753547 2753547 = true
kernel_rfl PRE_first_tail_x15_r0_body.fn100 : Nat.ble 4355 4355 = true
kernel_rfl PRE_first_tail_x15_r0_body.fjaD100 : Nat.ble 2753547 PRE_first_tail_x15_r0_body.kd100.n0 = true
kernel_rfl PRE_first_tail_x15_r0_body.fxn100 : Nat.ble 20177 PRE_first_tail_x15_r0_body.kd100.nh0 = true
kernel_rfl PRE_first_tail_x15_r0_body.fnn100 : Nat.ble 17277 PRE_first_tail_x15_r0_body.kd100.nn0 = true
kernel_rfl PRE_first_tail_x15_r0_body.fxb100 : Nat.ble 20177 RData.bigHi = true
kernel_rfl PRE_first_tail_x15_r0_body.fheap100 : (PTrie.keysA PRE_first_tail_x15_r0_body.kd100.heap).all (Nat.ble (⟨20177, 17277, 2753547, 4355⟩ : Conv.Cnt).ja) = true
kernel_rfl PRE_first_tail_x15_r0_body.fhnd100 : (PTrie.keysA PRE_first_tail_x15_r0_body.kd100.hnd).all (Nat.ble (⟨20177, 17277, 2753547, 4355⟩ : Conv.Cnt).xn) = true
kernel_rfl PRE_first_tail_x15_r0_body.fnode100 : (PTrie.keysA PRE_first_tail_x15_r0_body.kd100.node).all (Nat.ble (⟨20177, 17277, 2753547, 4355⟩ : Conv.Cnt).nn) = true
/-- The compaction map fixes the call's names. -/
theorem PRE_first_tail_x15_r0_body.cfix100 : Conv.FixOld (⟨20177, 17277, 2753547, 4355⟩ : Conv.Cnt) PRE_first_tail_x15_r0_body.kappa100 :=
  Conv.fixOld_compact (Nat.le_of_ble_eq_true PRE_first_tail_x15_r0_body.fja100) (Nat.le_of_ble_eq_true PRE_first_tail_x15_r0_body.fn100) (Nat.le_of_ble_eq_true PRE_first_tail_x15_r0_body.fjaD100) (Nat.le_of_ble_eq_true PRE_first_tail_x15_r0_body.fxn100) (Nat.le_of_ble_eq_true PRE_first_tail_x15_r0_body.fnn100) (Nat.le_of_ble_eq_true PRE_first_tail_x15_r0_body.fxb100) PRE_first_tail_x15_r0_body.fheap100 PRE_first_tail_x15_r0_body.fhnd100 PRE_first_tail_x15_r0_body.fnode100
kernel_rfl PRE_first_tail_x15_r0_body.fcxn100 : (⟨20177, 17277, 2753547, 4355⟩ : Conv.Cnt).xn = (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s973.ffi).mlx.next
kernel_rfl PRE_first_tail_x15_r0_body.fcnn100 : (⟨20177, 17277, 2753547, 4355⟩ : Conv.Cnt).nn = (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s973.ffi).mlx.nnext
kernel_rfl PRE_first_tail_x15_r0_body.fle0100 : (Nat.ble (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s973.ffi).mlx.next PRE_first_tail_x15_r0_body.cx0_100.mlx.next && Nat.ble (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s973.ffi).mlx.nnext PRE_first_tail_x15_r0_body.cx0_100.mlx.nnext && Nat.ble (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s973.ffi).mlx.next RData.bigHi) = true
kernel_rfl PRE_first_tail_x15_r0_body.fnk100 : (PTrie.keysA PRE_first_tail_x15_r0_body.kd100.node).all (Nat.ble (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s973.ffi).mlx.nnext) = true
-- the merged state keeps the call's entries off the stage's footprint
kernel_rfl PRE_first_tail_x15_r0_body.f1A100 : PRE_first_tail_x15_r0_body.cx1_100.mlx.arrs = Stage.setAll (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s973.ffi).mlx.arrs (PRE_first_tail_x15_r0_body.cwS100.filterMap fun i => (PRE_first_tail_x15_r0_body.cx1_100.mlx.arrs.get i).map (i, ·))
kernel_rfl PRE_first_tail_x15_r0_body.f1O100 : PRE_first_tail_x15_r0_body.cx1_100.mlx.objs = Stage.setAll (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s973.ffi).mlx.objs (PRE_first_tail_x15_r0_body.cwS100.filterMap fun i => (PRE_first_tail_x15_r0_body.cx1_100.mlx.objs.get i).map (i, ·))
kernel_rfl PRE_first_tail_x15_r0_body.f1N100 : PRE_first_tail_x15_r0_body.cx1_100.mlx.nodes = Stage.setAll (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s973.ffi).mlx.nodes (PRE_first_tail_x15_r0_body.cnS100.filterMap fun i => (PRE_first_tail_x15_r0_body.cx1_100.mlx.nodes.get i).map (i, ·))
kernel_rfl PRE_first_tail_x15_r0_body.f1I100 : PRE_first_tail_x15_r0_body.cx1_100.mlx.items = Stage.setAll (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s973.ffi).mlx.items (PRE_first_tail_x15_r0_body.ciS100.filterMap fun i => (PRE_first_tail_x15_r0_body.cx1_100.mlx.items.get i).map (i, ·))
kernel_rfl PRE_first_tail_x15_r0_body.fbd100 : (PRE_first_tail_x15_r0_body.clo100 ++ PRE_first_tail_x15_r0_body.cln100 ++ PRE_first_tail_x15_r0_body.cli100 ++ PRE_first_tail_x15_r0_body.cwS100 ++ PRE_first_tail_x15_r0_body.cnS100 ++ PRE_first_tail_x15_r0_body.ciS100).all (fun i => Nat.blt (i / 4096) (4 ^ 31)) = true
kernel_rfl PRE_first_tail_x15_r0_body.fincW100 : PRE_first_tail_x15_r0_body.cwS100.all (fun h => !Nat.blt h (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s973.ffi).mlx.next || PRE_first_tail_x15_r0_body.clo100.contains h) = true
kernel_rfl PRE_first_tail_x15_r0_body.fincI100 : PRE_first_tail_x15_r0_body.ciS100.all (fun k => !Nat.blt k (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s973.ffi).mlx.nnext || PRE_first_tail_x15_r0_body.cli100.contains k) = true
kernel_rfl PRE_first_tail_x15_r0_body.fincN100 : PRE_first_tail_x15_r0_body.cnS100.all (Nat.ble (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s973.ffi).mlx.nnext) = true
kernel_rfl PRE_first_tail_x15_r0_body.flnF100 : PRE_first_tail_x15_r0_body.cln100.all (Nat.ble (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s973.ffi).mlx.nnext) = true
-- the checks over the changed lists
kernel_rfl PRE_first_tail_x15_r0_body.fh100 : PRE_first_tail_x15_r0_body.clo100.all (handleOK PRE_first_tail_x15_r0_body.kappa100 PRE_first_tail_x15_r0_body.P100.lo PRE_first_tail_x15_r0_body.cx0_100.mlx PRE_first_tail_x15_r0_body.cx1_100.mlx) = true
kernel_rfl PRE_first_tail_x15_r0_body.fo100 : PRE_first_tail_x15_r0_body.clo100.map (fun h => PRE_first_tail_x15_r0_body.cx1_100.mlx.objs.get (PRE_first_tail_x15_r0_body.kappa100.handle h)) = PRE_first_tail_x15_r0_body.clo100.map (fun h => (PRE_first_tail_x15_r0_body.cx0_100.mlx.objs.get h).map PRE_first_tail_x15_r0_body.kappa100.nobj)
kernel_rfl PRE_first_tail_x15_r0_body.fok100 : PRE_first_tail_x15_r0_body.clo100.all (objOK PRE_first_tail_x15_r0_body.kappa100 PRE_first_tail_x15_r0_body.P100.NL PRE_first_tail_x15_r0_body.cx0_100.mlx) = true
kernel_rfl PRE_first_tail_x15_r0_body.fnd100 : PRE_first_tail_x15_r0_body.cln100.all (nodeOKF PRE_first_tail_x15_r0_body.kappa100 PRE_first_tail_x15_r0_body.P100 PRE_first_tail_x15_r0_body.cx0_100.mlx PRE_first_tail_x15_r0_body.cx1_100.mlx) = true
kernel_rfl PRE_first_tail_x15_r0_body.fp100 : ((PRE_first_tail_x15_r0_body.cln100.filter (fullB PRE_first_tail_x15_r0_body.P100))).map (fun i => (PRE_first_tail_x15_r0_body.cx1_100.mlx.nodes.get (PRE_first_tail_x15_r0_body.kappa100.node i)).map Host.Mlx.Ffi.Node.prim) =
  ((PRE_first_tail_x15_r0_body.cln100.filter (fullB PRE_first_tail_x15_r0_body.P100))).map (fun i => (PRE_first_tail_x15_r0_body.cx0_100.mlx.nodes.get i).map fun nd => PRE_first_tail_x15_r0_body.kappa100.prim nd.prim)
kernel_rfl PRE_first_tail_x15_r0_body.fnordI100 : incrB PRE_first_tail_x15_r0_body.kd100.nodeF (List.range' 17277 0) = true
kernel_rfl PRE_first_tail_x15_r0_body.fnordK100 : (PTrie.keysA PRE_first_tail_x15_r0_body.kd100.node).all (fun k => Nat.ble 17277 k && Nat.blt k 17277) = true
kernel_rfl PRE_first_tail_x15_r0_body.fnordL100 : (PRE_first_tail_x15_r0_body.cln100.filter (Nat.ble PRE_first_tail_x15_r0_body.P100.N0)).all (fun i => Nat.ble i (PRE_first_tail_x15_r0_body.kd100.nodeF i) && (Nat.blt i 17277 || Nat.ble PRE_first_tail_x15_r0_body.kd100.nn0 i)) = true
theorem PRE_first_tail_x15_r0_body.fnord100 : (PRE_first_tail_x15_r0_body.cln100.filter (Nat.ble PRE_first_tail_x15_r0_body.P100.N0)).all (fun i => Nat.ble i (PRE_first_tail_x15_r0_body.kd100.nodeF i) &&
    (PTrie.keysA PRE_first_tail_x15_r0_body.kd100.node).all fun j => !Nat.blt j i || Nat.blt (PRE_first_tail_x15_r0_body.kd100.nodeF j) (PRE_first_tail_x15_r0_body.kd100.nodeF i)) = true :=
  cnord_of PRE_first_tail_x15_r0_body.cnlow100 PRE_first_tail_x15_r0_body.cnn1100 PRE_first_tail_x15_r0_body.fnordI100 PRE_first_tail_x15_r0_body.fnordK100 PRE_first_tail_x15_r0_body.fnordL100
kernel_rfl PRE_first_tail_x15_r0_body.fi100 : PRE_first_tail_x15_r0_body.cli100.all (pnB PRE_first_tail_x15_r0_body.cx0_100.mlx) = true
kernel_rfl PRE_first_tail_x15_r0_body.fii100 : PRE_first_tail_x15_r0_body.cli100.all (fun k => decide (PRE_first_tail_x15_r0_body.cx1_100.mlx.items.get (PRE_first_tail_x15_r0_body.kappa100.node k) = (PRE_first_tail_x15_r0_body.cx0_100.mlx.items.get k).map PRE_first_tail_x15_r0_body.kappa100.nv)) = true
/-- **The compaction's footprint.** -/
theorem PRE_first_tail_x15_r0_body.cfoot100 (clean : Conv.NClean (⟨20177, 17277, 2753547, 4355⟩ : Conv.Cnt) (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s973.ffi).mlx) (hltC : ∀ h, PH (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s973.ffi).mlx h → h < (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s973.ffi).mlx.next) (nltC : ∀ i, PN (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s973.ffi).mlx i → i < (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s973.ffi).mlx.nnext) (itemsC : ∀ k v, (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s973.ffi).mlx.items.get k = some v → PN (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s973.ffi).mlx k) (tracedC : ∀ h o, (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s973.ffi).mlx.objs.get h = some o → ∀ i ∈ objTraces o, i < PRE_first_tail_x15_r0_body.P100.NL) (cl : SSt (· < 4355) PRE_first_tail_x15_r0_body.cx0_100.mlx) :
    Conv.MFoot PRE_first_tail_x15_r0_body.P100 4355 PRE_first_tail_x15_r0_body.kappa100 PRE_first_tail_x15_r0_body.kd100 PRE_first_tail_x15_r0_body.khinv100 PRE_first_tail_x15_r0_body.kninv100 (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s973.ffi).mlx PRE_first_tail_x15_r0_body.cx0_100.mlx PRE_first_tail_x15_r0_body.cx1_100.mlx (⟨20177, 17277, 2753547, 4355⟩ : Conv.Cnt) PRE_first_tail_x15_r0_body.clo100 PRE_first_tail_x15_r0_body.cln100 PRE_first_tail_x15_r0_body.cli100 PRE_first_tail_x15_r0_body.cwS100 PRE_first_tail_x15_r0_body.cnS100 PRE_first_tail_x15_r0_body.ciS100 :=
  ⟨rfl, rfl, rfl, PRE_first_tail_x15_r0_body.cnh0100, PRE_first_tail_x15_r0_body.cnh1100, PRE_first_tail_x15_r0_body.cnn0100, PRE_first_tail_x15_r0_body.cnn1100, PRE_first_tail_x15_r0_body.cplo100, PRE_first_tail_x15_r0_body.ccnt100, PRE_first_tail_x15_r0_body.cnband100, PRE_first_tail_x15_r0_body.chbelow100, PRE_first_tail_x15_r0_body.chren100, PRE_first_tail_x15_r0_body.cband100, PRE_first_tail_x15_r0_body.cnh1pos100, PRE_first_tail_x15_r0_body.cnren100, PRE_first_tail_x15_r0_body.cnlow100, PRE_first_tail_x15_r0_body.cabs0a100, PRE_first_tail_x15_r0_body.cabs0b100, PRE_first_tail_x15_r0_body.ctok1100, PRE_first_tail_x15_r0_body.cpend100, PRE_first_tail_x15_r0_body.cerrh100, PRE_first_tail_x15_r0_body.cfiles100, PRE_first_tail_x15_r0_body.carch100, PRE_first_tail_x15_r0_body.csizes100, PRE_first_tail_x15_r0_body.cwired100, PRE_first_tail_x15_r0_body.cfix100, clean, PRE_first_tail_x15_r0_body.fcxn100, PRE_first_tail_x15_r0_body.fcnn100, hltC, nltC, itemsC, tracedC, cl, PRE_first_tail_x15_r0_body.fle0100, PRE_first_tail_x15_r0_body.fnk100, PRE_first_tail_x15_r0_body.ckA100, PRE_first_tail_x15_r0_body.cobjsK100, PRE_first_tail_x15_r0_body.cnodesK100, PRE_first_tail_x15_r0_body.citemsK100, PRE_first_tail_x15_r0_body.f1A100, PRE_first_tail_x15_r0_body.f1O100, PRE_first_tail_x15_r0_body.f1N100, PRE_first_tail_x15_r0_body.f1I100, PRE_first_tail_x15_r0_body.fbd100, PRE_first_tail_x15_r0_body.fincW100, PRE_first_tail_x15_r0_body.fincI100, PRE_first_tail_x15_r0_body.fincN100, PRE_first_tail_x15_r0_body.flnF100, PRE_first_tail_x15_r0_body.fh100, PRE_first_tail_x15_r0_body.fo100, PRE_first_tail_x15_r0_body.fok100, PRE_first_tail_x15_r0_body.fnd100, PRE_first_tail_x15_r0_body.fp100, PRE_first_tail_x15_r0_body.fnord100, PRE_first_tail_x15_r0_body.fi100, PRE_first_tail_x15_r0_body.fii100⟩
theorem PRE_first_tail_x15_r0_body.cnshift100 (clean : Conv.NClean (⟨20177, 17277, 2753547, 4355⟩ : Conv.Cnt) (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s973.ffi).mlx) (hltC : ∀ h, PH (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s973.ffi).mlx h → h < (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s973.ffi).mlx.next) (nltC : ∀ i, PN (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s973.ffi).mlx i → i < (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s973.ffi).mlx.nnext) (itemsC : ∀ k v, (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s973.ffi).mlx.items.get k = some v → PN (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s973.ffi).mlx k) (tracedC : ∀ h o, (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s973.ffi).mlx.objs.get h = some o → ∀ i ∈ objTraces o, i < PRE_first_tail_x15_r0_body.P100.NL) (cl : SSt (· < 4355) PRE_first_tail_x15_r0_body.cx0_100.mlx) : NShift PRE_first_tail_x15_r0_body.P100 4355 PRE_first_tail_x15_r0_body.kappa100 PRE_first_tail_x15_r0_body.cx0_100 PRE_first_tail_x15_r0_body.cx1_100 :=
  Conv.nshift_of_foot (PRE_first_tail_x15_r0_body.cfoot100 clean hltC nltC itemsC tracedC cl) PRE_first_tail_x15_r0_body.chost100 (compact_a_eq PRE_first_tail_x15_r0_body.ckn0100 PRE_first_tail_x15_r0_body.ckn1100 PRE_first_tail_x15_r0_body.ckheap100 PRE_first_tail_x15_r0_body.ckpl100)

-- the observers: the layers' states at the call, the canonical and the merged state, their footprints and checks
noncomputable def PRE_first_tail_x15_r0_body.fxC_100 : PTrie Unit := (Host.Ts.Sim.Full.freedOf PRE_first_tail_x15_r0_body.s973.ffi).getD PTrie.nil
noncomputable def PRE_first_tail_x15_r0_body.krC_100 : Host.Load.Layers.KRec := (Host.Ts.Sim.Full.krecOf PRE_first_tail_x15_r0_body.s973.ffi).getD Host.Load.Layers.KRec.empty
kernel_rfl PRE_first_tail_x15_r0_body.ofxC_100 : (Host.Ts.Sim.Full.freedOf PRE_first_tail_x15_r0_body.s973.ffi) = some PRE_first_tail_x15_r0_body.fxC_100
kernel_rfl PRE_first_tail_x15_r0_body.okrC_100 : (Host.Ts.Sim.Full.krecOf PRE_first_tail_x15_r0_body.s973.ffi) = some PRE_first_tail_x15_r0_body.krC_100
noncomputable def PRE_first_tail_x15_r0_body.fx0_100 : PTrie Unit := (Host.Ts.Sim.Full.freedOf PRE_first_tail_x15_r0_body.s975.ffi).getD PTrie.nil
noncomputable def PRE_first_tail_x15_r0_body.kr0_100 : Host.Load.Layers.KRec := (Host.Ts.Sim.Full.krecOf PRE_first_tail_x15_r0_body.s975.ffi).getD Host.Load.Layers.KRec.empty
kernel_rfl PRE_first_tail_x15_r0_body.ofx0_100 : (Host.Ts.Sim.Full.freedOf PRE_first_tail_x15_r0_body.s975.ffi) = some PRE_first_tail_x15_r0_body.fx0_100
kernel_rfl PRE_first_tail_x15_r0_body.okr0_100 : (Host.Ts.Sim.Full.krecOf PRE_first_tail_x15_r0_body.s975.ffi) = some PRE_first_tail_x15_r0_body.kr0_100
noncomputable def PRE_first_tail_x15_r0_body.fx1_100 : PTrie Unit := (Host.Ts.Sim.Full.freedOf PRE_first_tail_x15_r0_body.s974.ffi).getD PTrie.nil
noncomputable def PRE_first_tail_x15_r0_body.kr1_100 : Host.Load.Layers.KRec := (Host.Ts.Sim.Full.krecOf PRE_first_tail_x15_r0_body.s974.ffi).getD Host.Load.Layers.KRec.empty
kernel_rfl PRE_first_tail_x15_r0_body.ofx1_100 : (Host.Ts.Sim.Full.freedOf PRE_first_tail_x15_r0_body.s974.ffi) = some PRE_first_tail_x15_r0_body.fx1_100
kernel_rfl PRE_first_tail_x15_r0_body.okr1_100 : (Host.Ts.Sim.Full.krecOf PRE_first_tail_x15_r0_body.s974.ffi) = some PRE_first_tail_x15_r0_body.kr1_100
kernel_rfl PRE_first_tail_x15_r0_body.ff0100 : PRE_first_tail_x15_r0_body.fx0_100 = Stage.setAll PRE_first_tail_x15_r0_body.fxC_100 (PRE_first_tail_x15_r0_body.clo100.filterMap fun i => (PRE_first_tail_x15_r0_body.fx0_100.get i).map (i, ·))
kernel_rfl PRE_first_tail_x15_r0_body.ff1100 : PRE_first_tail_x15_r0_body.fx1_100 = Stage.setAll PRE_first_tail_x15_r0_body.fxC_100 (PRE_first_tail_x15_r0_body.cwS100.filterMap fun i => (PRE_first_tail_x15_r0_body.fx1_100.get i).map (i, ·))
kernel_rfl PRE_first_tail_x15_r0_body.ffck100 : freedLB PRE_first_tail_x15_r0_body.kappa100 PRE_first_tail_x15_r0_body.cx0_100.mlx PRE_first_tail_x15_r0_body.fx0_100 PRE_first_tail_x15_r0_body.fx1_100 PRE_first_tail_x15_r0_body.clo100 = true
kernel_rfl PRE_first_tail_x15_r0_body.fkf0100 : PRE_first_tail_x15_r0_body.kr0_100.flags = Stage.setAll PRE_first_tail_x15_r0_body.krC_100.flags (PRE_first_tail_x15_r0_body.clo100.filterMap fun i => (PRE_first_tail_x15_r0_body.kr0_100.flags.get i).map (i, ·))
kernel_rfl PRE_first_tail_x15_r0_body.fkt0100 : PRE_first_tail_x15_r0_body.kr0_100.targs = Stage.setAll PRE_first_tail_x15_r0_body.krC_100.targs (PRE_first_tail_x15_r0_body.clo100.filterMap fun i => (PRE_first_tail_x15_r0_body.kr0_100.targs.get i).map (i, ·))
kernel_rfl PRE_first_tail_x15_r0_body.fkf1100 : PRE_first_tail_x15_r0_body.kr1_100.flags = Stage.setAll PRE_first_tail_x15_r0_body.krC_100.flags (PRE_first_tail_x15_r0_body.cwS100.filterMap fun i => (PRE_first_tail_x15_r0_body.kr1_100.flags.get i).map (i, ·))
kernel_rfl PRE_first_tail_x15_r0_body.fkt1100 : PRE_first_tail_x15_r0_body.kr1_100.targs = Stage.setAll PRE_first_tail_x15_r0_body.krC_100.targs (PRE_first_tail_x15_r0_body.cwS100.filterMap fun i => (PRE_first_tail_x15_r0_body.kr1_100.targs.get i).map (i, ·))
kernel_rfl PRE_first_tail_x15_r0_body.fkck100 : krecLB PRE_first_tail_x15_r0_body.kappa100 4355 PRE_first_tail_x15_r0_body.cx0_100.mlx PRE_first_tail_x15_r0_body.kr0_100 PRE_first_tail_x15_r0_body.kr1_100 PRE_first_tail_x15_r0_body.clo100 = true
kernel_rfl PRE_first_tail_x15_r0_body.fkn100 : Nat.ble 4355 4355 = true
-- the bridge and the pending traces' regions
kernel_rfl PRE_first_tail_x15_r0_body.cbridge100 : Host.Ts.Sim.Full.bridgeOf PRE_first_tail_x15_r0_body.s974.ffi = Host.Ts.Sim.Full.bridgeOf PRE_first_tail_x15_r0_body.s975.ffi
kernel_rfl PRE_first_tail_x15_r0_body.cpendR100 : pendRegB PRE_first_tail_x15_r0_body.kappa100 (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s975.ffi).mlx = true
kernel_rfl PRE_first_tail_x15_r0_body.cpendLe100 : Nat.ble (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s975.ffi).mlx.next (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s974.ffi).mlx.next = true
/-- **The compaction's native shift**, given the call's bookkeeping, its relation's facts (the model's and the
observers') and the canonical closedness. -/
theorem PRE_first_tail_x15_r0_body.cshift100 (clean : Conv.NClean (⟨20177, 17277, 2753547, 4355⟩ : Conv.Cnt) (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s973.ffi).mlx) (hltC : ∀ h, PH (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s973.ffi).mlx h → h < (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s973.ffi).mlx.next) (nltC : ∀ i, PN (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s973.ffi).mlx i → i < (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s973.ffi).mlx.nnext) (itemsC : ∀ k v, (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s973.ffi).mlx.items.get k = some v → PN (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s973.ffi).mlx k) (tracedC : ∀ h o, (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s973.ffi).mlx.objs.get h = some o → ∀ i ∈ objTraces o, i < PRE_first_tail_x15_r0_body.P100.NL) (cl : SSt (· < 4355) PRE_first_tail_x15_r0_body.cx0_100.mlx)
    (hobjC : ∀ h, PRE_first_tail_x15_r0_body.fxC_100.get h = some () → ((Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s973.ffi).mlx.objs.get h).isSome = true)
    (hfC : ∀ h, (PRE_first_tail_x15_r0_body.krC_100.flags.get h).isSome = true → ((Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s973.ffi).mlx.objs.get h).isSome = true)
    (htC : ∀ h, (PRE_first_tail_x15_r0_body.krC_100.targs.get h).isSome = true → ((Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s973.ffi).mlx.objs.get h).isSome = true)
    (hclC : ∀ h l, PRE_first_tail_x15_r0_body.krC_100.targs.get h = some l → Host.Ts.Sim.Full.STargs (· < (⟨20177, 17277, 2753547, 4355⟩ : Conv.Cnt).n) l) :
    Conv.FullShiftQ PRE_first_tail_x15_r0_body.P100 4355 PRE_first_tail_x15_r0_body.kappa100 PRE_first_tail_x15_r0_body.s975.ffi PRE_first_tail_x15_r0_body.s974.ffi :=
  ⟨PRE_first_tail_x15_r0_body.cnshift100 clean hltC nltC itemsC tracedC cl, PRE_first_tail_x15_r0_body.cqueue100, fun t ht => bSN_sound (List.all_eq_true.mp PRE_first_tail_x15_r0_body.ctokSupp100 t ht),
    PRE_first_tail_x15_r0_body.cbridge100,
    liveShift_foot (x0' := Host.Ts.Sim.Full.mlxOf PRE_first_tail_x15_r0_body.s975.ffi) (x1' := Host.Ts.Sim.Full.mlxOf PRE_first_tail_x15_r0_body.s974.ffi) (PRE_first_tail_x15_r0_body.cfoot100 clean hltC nltC itemsC tracedC cl) rfl PRE_first_tail_x15_r0_body.ofx0_100 PRE_first_tail_x15_r0_body.ofx1_100 hobjC PRE_first_tail_x15_r0_body.ff0100 PRE_first_tail_x15_r0_body.ff1100 PRE_first_tail_x15_r0_body.ffck100,
    kernShift_foot (x0' := Host.Ts.Sim.Full.mlxOf PRE_first_tail_x15_r0_body.s975.ffi) (x1' := Host.Ts.Sim.Full.mlxOf PRE_first_tail_x15_r0_body.s974.ffi) (PRE_first_tail_x15_r0_body.cfoot100 clean hltC nltC itemsC tracedC cl) rfl PRE_first_tail_x15_r0_body.okr0_100 PRE_first_tail_x15_r0_body.okr1_100 (Nat.le_of_ble_eq_true PRE_first_tail_x15_r0_body.fkn100) hfC htC hclC
      PRE_first_tail_x15_r0_body.fkf0100 PRE_first_tail_x15_r0_body.fkt0100 PRE_first_tail_x15_r0_body.fkf1100 PRE_first_tail_x15_r0_body.fkt1100 PRE_first_tail_x15_r0_body.fkck100,
    pendReg_of rfl PRE_first_tail_x15_r0_body.cnh0100 PRE_first_tail_x15_r0_body.cnh1100 (Nat.le_of_ble_eq_true PRE_first_tail_x15_r0_body.cpendLe100) PRE_first_tail_x15_r0_body.cpendR100⟩

end Host.Load.Run.Tpl
