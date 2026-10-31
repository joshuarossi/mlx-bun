import host.sim.template.a4pre_first_tail_x15_r0_body.SiteCl8
import host.sim.conv.CompactFull
import host.sim.template.FootGen
set_option Elab.async false
namespace Host.Load.Run.Tpl
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
open Host.Ts Host.Ts.Sim Host.Ts.Sim.Template

/-! The compaction's native shift at call site 8 from its footprint (`Conv.nshift_of_foot`), and the observers'
(`liveShift_foot`, `kernShift_foot`): `Conv.FullShiftQ` for `Conv.full_compactQ`, given the call's bookkeeping and its
relation's facts. -/

/-- The load parameters of the chain (band-free: its start's node counter as `NL` and `N0`). -/
def PRE_first_tail_x15_r0_body.Pc8 : LoadP := ⟨18151, 131072, 1099511627776, 15235, 15235, []⟩
/-- The site's band raised to the map's checked fixed-node prefix, including newly recorded closure traces. -/
def PRE_first_tail_x15_r0_body.P8 : LoadP := PRE_first_tail_x15_r0_body.Pc8.raise 15448
kernel_rfl PRE_first_tail_x15_r0_body.craise8 : Nat.ble PRE_first_tail_x15_r0_body.Pc8.N0 15448 = true
theorem PRE_first_tail_x15_r0_body.raised8 : Host.Ts.Sim.Full.Raised PRE_first_tail_x15_r0_body.Pc8 PRE_first_tail_x15_r0_body.P8 :=
  .inr ⟨15448, rfl, Nat.le_of_ble_eq_true PRE_first_tail_x15_r0_body.craise8, rfl⟩
noncomputable abbrev PRE_first_tail_x15_r0_body.cx0_8 : Host.Load.LSt := clearTokens (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s81.ffi)
noncomputable abbrev PRE_first_tail_x15_r0_body.cx1_8 : Host.Load.LSt := clearTokens (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s80.ffi)
def PRE_first_tail_x15_r0_body.khinv8 : PTrie Nat := Stage.setAll PTrie.nil []
def PRE_first_tail_x15_r0_body.kninv8 : PTrie Nat := Stage.setAll PTrie.nil []
/-- The stage's footprint: its written and fresh handles, fresh nodes, written and fresh items. -/
def PRE_first_tail_x15_r0_body.cwS8 : List Nat := []
def PRE_first_tail_x15_r0_body.cnS8 : List Nat := List.range' 15448 0
def PRE_first_tail_x15_r0_body.ciS8 : List Nat := [] ++ List.range' 15448 0

-- the small checks (`MChecks`'s)
kernel_rfl PRE_first_tail_x15_r0_body.cnh08 : PRE_first_tail_x15_r0_body.kd8.nh0 = PRE_first_tail_x15_r0_body.cx0_8.mlx.next
kernel_rfl PRE_first_tail_x15_r0_body.cnh18 : PRE_first_tail_x15_r0_body.kd8.nh1 = PRE_first_tail_x15_r0_body.cx1_8.mlx.next
kernel_rfl PRE_first_tail_x15_r0_body.cnn08 : PRE_first_tail_x15_r0_body.kd8.nn0 = PRE_first_tail_x15_r0_body.cx0_8.mlx.nnext
kernel_rfl PRE_first_tail_x15_r0_body.cnn18 : PRE_first_tail_x15_r0_body.kd8.nn1 = PRE_first_tail_x15_r0_body.cx1_8.mlx.nnext
kernel_rfl PRE_first_tail_x15_r0_body.cplo8 : (Nat.blt 0 PRE_first_tail_x15_r0_body.P8.lo && Nat.ble PRE_first_tail_x15_r0_body.P8.lo PRE_first_tail_x15_r0_body.cx0_8.mlx.next && Nat.ble PRE_first_tail_x15_r0_body.P8.lo RData.bigHi && Nat.ble RData.bigHi PRE_first_tail_x15_r0_body.P8.E) = true
kernel_rfl PRE_first_tail_x15_r0_body.ccnt8 : (Nat.ble PRE_first_tail_x15_r0_body.cx0_8.mlx.next PRE_first_tail_x15_r0_body.cx1_8.mlx.next && Nat.ble PRE_first_tail_x15_r0_body.cx0_8.mlx.nnext PRE_first_tail_x15_r0_body.cx1_8.mlx.nnext) = true
kernel_rfl PRE_first_tail_x15_r0_body.cnband8 : (Nat.blt 0 PRE_first_tail_x15_r0_body.P8.NL && Nat.ble PRE_first_tail_x15_r0_body.P8.NL PRE_first_tail_x15_r0_body.P8.N0 && Nat.ble PRE_first_tail_x15_r0_body.P8.N0 PRE_first_tail_x15_r0_body.cx0_8.mlx.nnext) = true
kernel_rfl PRE_first_tail_x15_r0_body.chbelow8 : PRE_first_tail_x15_r0_body.kd8.checkHndBelow = true
kernel_rfl PRE_first_tail_x15_r0_body.chren8 : checkRenG PRE_first_tail_x15_r0_body.kd8.hnd PRE_first_tail_x15_r0_body.khinv8 (phB PRE_first_tail_x15_r0_body.cx0_8.mlx) = true
kernel_rfl PRE_first_tail_x15_r0_body.cband8 : PRE_first_tail_x15_r0_body.kd8.checkBand PRE_first_tail_x15_r0_body.P8.lo = true
kernel_rfl PRE_first_tail_x15_r0_body.cnh1pos8 : Nat.blt 0 PRE_first_tail_x15_r0_body.kd8.nh1 = true
kernel_rfl PRE_first_tail_x15_r0_body.cnren8 : checkRenG PRE_first_tail_x15_r0_body.kd8.node PRE_first_tail_x15_r0_body.kninv8 (pnB PRE_first_tail_x15_r0_body.cx0_8.mlx) = true
kernel_rfl PRE_first_tail_x15_r0_body.cnlow8 : (PTrie.keysA PRE_first_tail_x15_r0_body.kd8.node).all (fun j => Nat.ble PRE_first_tail_x15_r0_body.P8.NL j && Nat.blt (PRE_first_tail_x15_r0_body.kd8.nodeF j) PRE_first_tail_x15_r0_body.cx1_8.mlx.nnext) = true
kernel_rfl PRE_first_tail_x15_r0_body.cabs0a8 : PRE_first_tail_x15_r0_body.cx0_8.mlx.arrs.get 0 = none
kernel_rfl PRE_first_tail_x15_r0_body.cabs0b8 : PRE_first_tail_x15_r0_body.cx0_8.mlx.objs.get 0 = none
kernel_rfl PRE_first_tail_x15_r0_body.ctok18 : PRE_first_tail_x15_r0_body.cx1_8.mlx.tokens = []
kernel_rfl PRE_first_tail_x15_r0_body.cpend8 : PRE_first_tail_x15_r0_body.cx1_8.mlx.pending = PRE_first_tail_x15_r0_body.cx0_8.mlx.pending.map PRE_first_tail_x15_r0_body.kappa8.pend
kernel_rfl PRE_first_tail_x15_r0_body.cerrh8 : PRE_first_tail_x15_r0_body.cx1_8.mlx.errh = PRE_first_tail_x15_r0_body.cx0_8.mlx.errh.map PRE_first_tail_x15_r0_body.kappa8.arg
kernel_rfl PRE_first_tail_x15_r0_body.cfiles8 : PRE_first_tail_x15_r0_body.cx1_8.mlx.files = PRE_first_tail_x15_r0_body.cx0_8.mlx.files
kernel_rfl PRE_first_tail_x15_r0_body.carch8 : PRE_first_tail_x15_r0_body.cx1_8.mlx.arch = PRE_first_tail_x15_r0_body.cx0_8.mlx.arch
kernel_rfl PRE_first_tail_x15_r0_body.csizes8 : PRE_first_tail_x15_r0_body.cx1_8.mlx.deviceSizes = PRE_first_tail_x15_r0_body.cx0_8.mlx.deviceSizes
kernel_rfl PRE_first_tail_x15_r0_body.cwired8 : PRE_first_tail_x15_r0_body.cx1_8.mlx.wired = PRE_first_tail_x15_r0_body.cx0_8.mlx.wired
kernel_rfl PRE_first_tail_x15_r0_body.chost8 : PRE_first_tail_x15_r0_body.cx1_8.host = PRE_first_tail_x15_r0_body.cx0_8.host
-- the compaction map's addresses are `PRE_first_tail_x15_r0_body.kd8`'s
kernel_rfl PRE_first_tail_x15_r0_body.ckn08 : PRE_first_tail_x15_r0_body.kd8.n0 = 2680758
kernel_rfl PRE_first_tail_x15_r0_body.ckn18 : PRE_first_tail_x15_r0_body.kd8.n1 = 2680768
kernel_rfl PRE_first_tail_x15_r0_body.ckheap8 : (PTrie.keysA PRE_first_tail_x15_r0_body.kd8.heap).all (fun x => Nat.ble 2680757 x) = true
kernel_rfl PRE_first_tail_x15_r0_body.ckpl8 : (List.range 1).all (fun j => decide (PRE_first_tail_x15_r0_body.kd8.heap.get (2680757 + j) = nth? PRE_first_tail_x15_r0_body.pl8 j)) = true
-- the map fixes the call's names (`Conv.fixOld_compact`), the call's counters
kernel_rfl PRE_first_tail_x15_r0_body.fja8 : Nat.ble 2680757 2680757 = true
kernel_rfl PRE_first_tail_x15_r0_body.fn8 : Nat.ble 397 397 = true
kernel_rfl PRE_first_tail_x15_r0_body.fjaD8 : Nat.ble 2680757 PRE_first_tail_x15_r0_body.kd8.n0 = true
kernel_rfl PRE_first_tail_x15_r0_body.fxn8 : Nat.ble 18353 PRE_first_tail_x15_r0_body.kd8.nh0 = true
kernel_rfl PRE_first_tail_x15_r0_body.fnn8 : Nat.ble 15448 PRE_first_tail_x15_r0_body.kd8.nn0 = true
kernel_rfl PRE_first_tail_x15_r0_body.fxb8 : Nat.ble 18353 RData.bigHi = true
kernel_rfl PRE_first_tail_x15_r0_body.fheap8 : (PTrie.keysA PRE_first_tail_x15_r0_body.kd8.heap).all (Nat.ble (⟨18353, 15448, 2680757, 397⟩ : Conv.Cnt).ja) = true
kernel_rfl PRE_first_tail_x15_r0_body.fhnd8 : (PTrie.keysA PRE_first_tail_x15_r0_body.kd8.hnd).all (Nat.ble (⟨18353, 15448, 2680757, 397⟩ : Conv.Cnt).xn) = true
kernel_rfl PRE_first_tail_x15_r0_body.fnode8 : (PTrie.keysA PRE_first_tail_x15_r0_body.kd8.node).all (Nat.ble (⟨18353, 15448, 2680757, 397⟩ : Conv.Cnt).nn) = true
/-- The compaction map fixes the call's names. -/
theorem PRE_first_tail_x15_r0_body.cfix8 : Conv.FixOld (⟨18353, 15448, 2680757, 397⟩ : Conv.Cnt) PRE_first_tail_x15_r0_body.kappa8 :=
  Conv.fixOld_compact (Nat.le_of_ble_eq_true PRE_first_tail_x15_r0_body.fja8) (Nat.le_of_ble_eq_true PRE_first_tail_x15_r0_body.fn8) (Nat.le_of_ble_eq_true PRE_first_tail_x15_r0_body.fjaD8) (Nat.le_of_ble_eq_true PRE_first_tail_x15_r0_body.fxn8) (Nat.le_of_ble_eq_true PRE_first_tail_x15_r0_body.fnn8) (Nat.le_of_ble_eq_true PRE_first_tail_x15_r0_body.fxb8) PRE_first_tail_x15_r0_body.fheap8 PRE_first_tail_x15_r0_body.fhnd8 PRE_first_tail_x15_r0_body.fnode8
kernel_rfl PRE_first_tail_x15_r0_body.fcxn8 : (⟨18353, 15448, 2680757, 397⟩ : Conv.Cnt).xn = (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s79.ffi).mlx.next
kernel_rfl PRE_first_tail_x15_r0_body.fcnn8 : (⟨18353, 15448, 2680757, 397⟩ : Conv.Cnt).nn = (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s79.ffi).mlx.nnext
kernel_rfl PRE_first_tail_x15_r0_body.fle08 : (Nat.ble (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s79.ffi).mlx.next PRE_first_tail_x15_r0_body.cx0_8.mlx.next && Nat.ble (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s79.ffi).mlx.nnext PRE_first_tail_x15_r0_body.cx0_8.mlx.nnext && Nat.ble (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s79.ffi).mlx.next RData.bigHi) = true
kernel_rfl PRE_first_tail_x15_r0_body.fnk8 : (PTrie.keysA PRE_first_tail_x15_r0_body.kd8.node).all (Nat.ble (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s79.ffi).mlx.nnext) = true
-- the merged state keeps the call's entries off the stage's footprint
kernel_rfl PRE_first_tail_x15_r0_body.f1A8 : PRE_first_tail_x15_r0_body.cx1_8.mlx.arrs = Stage.setAll (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s79.ffi).mlx.arrs (PRE_first_tail_x15_r0_body.cwS8.filterMap fun i => (PRE_first_tail_x15_r0_body.cx1_8.mlx.arrs.get i).map (i, ·))
kernel_rfl PRE_first_tail_x15_r0_body.f1O8 : PRE_first_tail_x15_r0_body.cx1_8.mlx.objs = Stage.setAll (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s79.ffi).mlx.objs (PRE_first_tail_x15_r0_body.cwS8.filterMap fun i => (PRE_first_tail_x15_r0_body.cx1_8.mlx.objs.get i).map (i, ·))
kernel_rfl PRE_first_tail_x15_r0_body.f1N8 : PRE_first_tail_x15_r0_body.cx1_8.mlx.nodes = Stage.setAll (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s79.ffi).mlx.nodes (PRE_first_tail_x15_r0_body.cnS8.filterMap fun i => (PRE_first_tail_x15_r0_body.cx1_8.mlx.nodes.get i).map (i, ·))
kernel_rfl PRE_first_tail_x15_r0_body.f1I8 : PRE_first_tail_x15_r0_body.cx1_8.mlx.items = Stage.setAll (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s79.ffi).mlx.items (PRE_first_tail_x15_r0_body.ciS8.filterMap fun i => (PRE_first_tail_x15_r0_body.cx1_8.mlx.items.get i).map (i, ·))
kernel_rfl PRE_first_tail_x15_r0_body.fbd8 : (PRE_first_tail_x15_r0_body.clo8 ++ PRE_first_tail_x15_r0_body.cln8 ++ PRE_first_tail_x15_r0_body.cli8 ++ PRE_first_tail_x15_r0_body.cwS8 ++ PRE_first_tail_x15_r0_body.cnS8 ++ PRE_first_tail_x15_r0_body.ciS8).all (fun i => Nat.blt (i / 4096) (4 ^ 31)) = true
kernel_rfl PRE_first_tail_x15_r0_body.fincW8 : PRE_first_tail_x15_r0_body.cwS8.all (fun h => !Nat.blt h (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s79.ffi).mlx.next || PRE_first_tail_x15_r0_body.clo8.contains h) = true
kernel_rfl PRE_first_tail_x15_r0_body.fincI8 : PRE_first_tail_x15_r0_body.ciS8.all (fun k => !Nat.blt k (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s79.ffi).mlx.nnext || PRE_first_tail_x15_r0_body.cli8.contains k) = true
kernel_rfl PRE_first_tail_x15_r0_body.fincN8 : PRE_first_tail_x15_r0_body.cnS8.all (Nat.ble (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s79.ffi).mlx.nnext) = true
kernel_rfl PRE_first_tail_x15_r0_body.flnF8 : PRE_first_tail_x15_r0_body.cln8.all (Nat.ble (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s79.ffi).mlx.nnext) = true
-- the checks over the changed lists
kernel_rfl PRE_first_tail_x15_r0_body.fh8 : PRE_first_tail_x15_r0_body.clo8.all (handleOK PRE_first_tail_x15_r0_body.kappa8 PRE_first_tail_x15_r0_body.P8.lo PRE_first_tail_x15_r0_body.cx0_8.mlx PRE_first_tail_x15_r0_body.cx1_8.mlx) = true
kernel_rfl PRE_first_tail_x15_r0_body.fo8 : PRE_first_tail_x15_r0_body.clo8.map (fun h => PRE_first_tail_x15_r0_body.cx1_8.mlx.objs.get (PRE_first_tail_x15_r0_body.kappa8.handle h)) = PRE_first_tail_x15_r0_body.clo8.map (fun h => (PRE_first_tail_x15_r0_body.cx0_8.mlx.objs.get h).map PRE_first_tail_x15_r0_body.kappa8.nobj)
kernel_rfl PRE_first_tail_x15_r0_body.fok8 : PRE_first_tail_x15_r0_body.clo8.all (objOK PRE_first_tail_x15_r0_body.kappa8 PRE_first_tail_x15_r0_body.P8.NL PRE_first_tail_x15_r0_body.cx0_8.mlx) = true
kernel_rfl PRE_first_tail_x15_r0_body.fnd8 : PRE_first_tail_x15_r0_body.cln8.all (nodeOKF PRE_first_tail_x15_r0_body.kappa8 PRE_first_tail_x15_r0_body.P8 PRE_first_tail_x15_r0_body.cx0_8.mlx PRE_first_tail_x15_r0_body.cx1_8.mlx) = true
kernel_rfl PRE_first_tail_x15_r0_body.fp8 : ((PRE_first_tail_x15_r0_body.cln8.filter (fullB PRE_first_tail_x15_r0_body.P8))).map (fun i => (PRE_first_tail_x15_r0_body.cx1_8.mlx.nodes.get (PRE_first_tail_x15_r0_body.kappa8.node i)).map Host.Mlx.Ffi.Node.prim) =
  ((PRE_first_tail_x15_r0_body.cln8.filter (fullB PRE_first_tail_x15_r0_body.P8))).map (fun i => (PRE_first_tail_x15_r0_body.cx0_8.mlx.nodes.get i).map fun nd => PRE_first_tail_x15_r0_body.kappa8.prim nd.prim)
kernel_rfl PRE_first_tail_x15_r0_body.fnordI8 : incrB PRE_first_tail_x15_r0_body.kd8.nodeF (List.range' 15448 0) = true
kernel_rfl PRE_first_tail_x15_r0_body.fnordK8 : (PTrie.keysA PRE_first_tail_x15_r0_body.kd8.node).all (fun k => Nat.ble 15448 k && Nat.blt k 15448) = true
kernel_rfl PRE_first_tail_x15_r0_body.fnordL8 : (PRE_first_tail_x15_r0_body.cln8.filter (Nat.ble PRE_first_tail_x15_r0_body.P8.N0)).all (fun i => Nat.ble i (PRE_first_tail_x15_r0_body.kd8.nodeF i) && (Nat.blt i 15448 || Nat.ble PRE_first_tail_x15_r0_body.kd8.nn0 i)) = true
theorem PRE_first_tail_x15_r0_body.fnord8 : (PRE_first_tail_x15_r0_body.cln8.filter (Nat.ble PRE_first_tail_x15_r0_body.P8.N0)).all (fun i => Nat.ble i (PRE_first_tail_x15_r0_body.kd8.nodeF i) &&
    (PTrie.keysA PRE_first_tail_x15_r0_body.kd8.node).all fun j => !Nat.blt j i || Nat.blt (PRE_first_tail_x15_r0_body.kd8.nodeF j) (PRE_first_tail_x15_r0_body.kd8.nodeF i)) = true :=
  cnord_of PRE_first_tail_x15_r0_body.cnlow8 PRE_first_tail_x15_r0_body.cnn18 PRE_first_tail_x15_r0_body.fnordI8 PRE_first_tail_x15_r0_body.fnordK8 PRE_first_tail_x15_r0_body.fnordL8
kernel_rfl PRE_first_tail_x15_r0_body.fi8 : PRE_first_tail_x15_r0_body.cli8.all (pnB PRE_first_tail_x15_r0_body.cx0_8.mlx) = true
kernel_rfl PRE_first_tail_x15_r0_body.fii8 : PRE_first_tail_x15_r0_body.cli8.all (fun k => decide (PRE_first_tail_x15_r0_body.cx1_8.mlx.items.get (PRE_first_tail_x15_r0_body.kappa8.node k) = (PRE_first_tail_x15_r0_body.cx0_8.mlx.items.get k).map PRE_first_tail_x15_r0_body.kappa8.nv)) = true
/-- **The compaction's footprint.** -/
theorem PRE_first_tail_x15_r0_body.cfoot8 (clean : Conv.NClean (⟨18353, 15448, 2680757, 397⟩ : Conv.Cnt) (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s79.ffi).mlx) (hltC : ∀ h, PH (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s79.ffi).mlx h → h < (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s79.ffi).mlx.next) (nltC : ∀ i, PN (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s79.ffi).mlx i → i < (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s79.ffi).mlx.nnext) (itemsC : ∀ k v, (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s79.ffi).mlx.items.get k = some v → PN (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s79.ffi).mlx k) (tracedC : ∀ h o, (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s79.ffi).mlx.objs.get h = some o → ∀ i ∈ objTraces o, i < PRE_first_tail_x15_r0_body.P8.NL) (cl : SSt (· < 397) PRE_first_tail_x15_r0_body.cx0_8.mlx) :
    Conv.MFoot PRE_first_tail_x15_r0_body.P8 397 PRE_first_tail_x15_r0_body.kappa8 PRE_first_tail_x15_r0_body.kd8 PRE_first_tail_x15_r0_body.khinv8 PRE_first_tail_x15_r0_body.kninv8 (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s79.ffi).mlx PRE_first_tail_x15_r0_body.cx0_8.mlx PRE_first_tail_x15_r0_body.cx1_8.mlx (⟨18353, 15448, 2680757, 397⟩ : Conv.Cnt) PRE_first_tail_x15_r0_body.clo8 PRE_first_tail_x15_r0_body.cln8 PRE_first_tail_x15_r0_body.cli8 PRE_first_tail_x15_r0_body.cwS8 PRE_first_tail_x15_r0_body.cnS8 PRE_first_tail_x15_r0_body.ciS8 :=
  ⟨rfl, rfl, rfl, PRE_first_tail_x15_r0_body.cnh08, PRE_first_tail_x15_r0_body.cnh18, PRE_first_tail_x15_r0_body.cnn08, PRE_first_tail_x15_r0_body.cnn18, PRE_first_tail_x15_r0_body.cplo8, PRE_first_tail_x15_r0_body.ccnt8, PRE_first_tail_x15_r0_body.cnband8, PRE_first_tail_x15_r0_body.chbelow8, PRE_first_tail_x15_r0_body.chren8, PRE_first_tail_x15_r0_body.cband8, PRE_first_tail_x15_r0_body.cnh1pos8, PRE_first_tail_x15_r0_body.cnren8, PRE_first_tail_x15_r0_body.cnlow8, PRE_first_tail_x15_r0_body.cabs0a8, PRE_first_tail_x15_r0_body.cabs0b8, PRE_first_tail_x15_r0_body.ctok18, PRE_first_tail_x15_r0_body.cpend8, PRE_first_tail_x15_r0_body.cerrh8, PRE_first_tail_x15_r0_body.cfiles8, PRE_first_tail_x15_r0_body.carch8, PRE_first_tail_x15_r0_body.csizes8, PRE_first_tail_x15_r0_body.cwired8, PRE_first_tail_x15_r0_body.cfix8, clean, PRE_first_tail_x15_r0_body.fcxn8, PRE_first_tail_x15_r0_body.fcnn8, hltC, nltC, itemsC, tracedC, cl, PRE_first_tail_x15_r0_body.fle08, PRE_first_tail_x15_r0_body.fnk8, PRE_first_tail_x15_r0_body.ckA8, PRE_first_tail_x15_r0_body.cobjsK8, PRE_first_tail_x15_r0_body.cnodesK8, PRE_first_tail_x15_r0_body.citemsK8, PRE_first_tail_x15_r0_body.f1A8, PRE_first_tail_x15_r0_body.f1O8, PRE_first_tail_x15_r0_body.f1N8, PRE_first_tail_x15_r0_body.f1I8, PRE_first_tail_x15_r0_body.fbd8, PRE_first_tail_x15_r0_body.fincW8, PRE_first_tail_x15_r0_body.fincI8, PRE_first_tail_x15_r0_body.fincN8, PRE_first_tail_x15_r0_body.flnF8, PRE_first_tail_x15_r0_body.fh8, PRE_first_tail_x15_r0_body.fo8, PRE_first_tail_x15_r0_body.fok8, PRE_first_tail_x15_r0_body.fnd8, PRE_first_tail_x15_r0_body.fp8, PRE_first_tail_x15_r0_body.fnord8, PRE_first_tail_x15_r0_body.fi8, PRE_first_tail_x15_r0_body.fii8⟩
theorem PRE_first_tail_x15_r0_body.cnshift8 (clean : Conv.NClean (⟨18353, 15448, 2680757, 397⟩ : Conv.Cnt) (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s79.ffi).mlx) (hltC : ∀ h, PH (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s79.ffi).mlx h → h < (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s79.ffi).mlx.next) (nltC : ∀ i, PN (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s79.ffi).mlx i → i < (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s79.ffi).mlx.nnext) (itemsC : ∀ k v, (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s79.ffi).mlx.items.get k = some v → PN (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s79.ffi).mlx k) (tracedC : ∀ h o, (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s79.ffi).mlx.objs.get h = some o → ∀ i ∈ objTraces o, i < PRE_first_tail_x15_r0_body.P8.NL) (cl : SSt (· < 397) PRE_first_tail_x15_r0_body.cx0_8.mlx) : NShift PRE_first_tail_x15_r0_body.P8 397 PRE_first_tail_x15_r0_body.kappa8 PRE_first_tail_x15_r0_body.cx0_8 PRE_first_tail_x15_r0_body.cx1_8 :=
  Conv.nshift_of_foot (PRE_first_tail_x15_r0_body.cfoot8 clean hltC nltC itemsC tracedC cl) PRE_first_tail_x15_r0_body.chost8 (compact_a_eq PRE_first_tail_x15_r0_body.ckn08 PRE_first_tail_x15_r0_body.ckn18 PRE_first_tail_x15_r0_body.ckheap8 PRE_first_tail_x15_r0_body.ckpl8)

-- the observers: the layers' states at the call, the canonical and the merged state, their footprints and checks
noncomputable def PRE_first_tail_x15_r0_body.fxC_8 : PTrie Unit := (Host.Ts.Sim.Full.freedOf PRE_first_tail_x15_r0_body.s79.ffi).getD PTrie.nil
noncomputable def PRE_first_tail_x15_r0_body.krC_8 : Host.Load.Layers.KRec := (Host.Ts.Sim.Full.krecOf PRE_first_tail_x15_r0_body.s79.ffi).getD Host.Load.Layers.KRec.empty
kernel_rfl PRE_first_tail_x15_r0_body.ofxC_8 : (Host.Ts.Sim.Full.freedOf PRE_first_tail_x15_r0_body.s79.ffi) = some PRE_first_tail_x15_r0_body.fxC_8
kernel_rfl PRE_first_tail_x15_r0_body.okrC_8 : (Host.Ts.Sim.Full.krecOf PRE_first_tail_x15_r0_body.s79.ffi) = some PRE_first_tail_x15_r0_body.krC_8
noncomputable def PRE_first_tail_x15_r0_body.fx0_8 : PTrie Unit := (Host.Ts.Sim.Full.freedOf PRE_first_tail_x15_r0_body.s81.ffi).getD PTrie.nil
noncomputable def PRE_first_tail_x15_r0_body.kr0_8 : Host.Load.Layers.KRec := (Host.Ts.Sim.Full.krecOf PRE_first_tail_x15_r0_body.s81.ffi).getD Host.Load.Layers.KRec.empty
kernel_rfl PRE_first_tail_x15_r0_body.ofx0_8 : (Host.Ts.Sim.Full.freedOf PRE_first_tail_x15_r0_body.s81.ffi) = some PRE_first_tail_x15_r0_body.fx0_8
kernel_rfl PRE_first_tail_x15_r0_body.okr0_8 : (Host.Ts.Sim.Full.krecOf PRE_first_tail_x15_r0_body.s81.ffi) = some PRE_first_tail_x15_r0_body.kr0_8
noncomputable def PRE_first_tail_x15_r0_body.fx1_8 : PTrie Unit := (Host.Ts.Sim.Full.freedOf PRE_first_tail_x15_r0_body.s80.ffi).getD PTrie.nil
noncomputable def PRE_first_tail_x15_r0_body.kr1_8 : Host.Load.Layers.KRec := (Host.Ts.Sim.Full.krecOf PRE_first_tail_x15_r0_body.s80.ffi).getD Host.Load.Layers.KRec.empty
kernel_rfl PRE_first_tail_x15_r0_body.ofx1_8 : (Host.Ts.Sim.Full.freedOf PRE_first_tail_x15_r0_body.s80.ffi) = some PRE_first_tail_x15_r0_body.fx1_8
kernel_rfl PRE_first_tail_x15_r0_body.okr1_8 : (Host.Ts.Sim.Full.krecOf PRE_first_tail_x15_r0_body.s80.ffi) = some PRE_first_tail_x15_r0_body.kr1_8
kernel_rfl PRE_first_tail_x15_r0_body.ff08 : PRE_first_tail_x15_r0_body.fx0_8 = Stage.setAll PRE_first_tail_x15_r0_body.fxC_8 (PRE_first_tail_x15_r0_body.clo8.filterMap fun i => (PRE_first_tail_x15_r0_body.fx0_8.get i).map (i, ·))
kernel_rfl PRE_first_tail_x15_r0_body.ff18 : PRE_first_tail_x15_r0_body.fx1_8 = Stage.setAll PRE_first_tail_x15_r0_body.fxC_8 (PRE_first_tail_x15_r0_body.cwS8.filterMap fun i => (PRE_first_tail_x15_r0_body.fx1_8.get i).map (i, ·))
kernel_rfl PRE_first_tail_x15_r0_body.ffck8 : freedLB PRE_first_tail_x15_r0_body.kappa8 PRE_first_tail_x15_r0_body.cx0_8.mlx PRE_first_tail_x15_r0_body.fx0_8 PRE_first_tail_x15_r0_body.fx1_8 PRE_first_tail_x15_r0_body.clo8 = true
kernel_rfl PRE_first_tail_x15_r0_body.fkf08 : PRE_first_tail_x15_r0_body.kr0_8.flags = Stage.setAll PRE_first_tail_x15_r0_body.krC_8.flags (PRE_first_tail_x15_r0_body.clo8.filterMap fun i => (PRE_first_tail_x15_r0_body.kr0_8.flags.get i).map (i, ·))
kernel_rfl PRE_first_tail_x15_r0_body.fkt08 : PRE_first_tail_x15_r0_body.kr0_8.targs = Stage.setAll PRE_first_tail_x15_r0_body.krC_8.targs (PRE_first_tail_x15_r0_body.clo8.filterMap fun i => (PRE_first_tail_x15_r0_body.kr0_8.targs.get i).map (i, ·))
kernel_rfl PRE_first_tail_x15_r0_body.fkf18 : PRE_first_tail_x15_r0_body.kr1_8.flags = Stage.setAll PRE_first_tail_x15_r0_body.krC_8.flags (PRE_first_tail_x15_r0_body.cwS8.filterMap fun i => (PRE_first_tail_x15_r0_body.kr1_8.flags.get i).map (i, ·))
kernel_rfl PRE_first_tail_x15_r0_body.fkt18 : PRE_first_tail_x15_r0_body.kr1_8.targs = Stage.setAll PRE_first_tail_x15_r0_body.krC_8.targs (PRE_first_tail_x15_r0_body.cwS8.filterMap fun i => (PRE_first_tail_x15_r0_body.kr1_8.targs.get i).map (i, ·))
kernel_rfl PRE_first_tail_x15_r0_body.fkck8 : krecLB PRE_first_tail_x15_r0_body.kappa8 397 PRE_first_tail_x15_r0_body.cx0_8.mlx PRE_first_tail_x15_r0_body.kr0_8 PRE_first_tail_x15_r0_body.kr1_8 PRE_first_tail_x15_r0_body.clo8 = true
kernel_rfl PRE_first_tail_x15_r0_body.fkn8 : Nat.ble 397 397 = true
-- the bridge and the pending traces' regions
kernel_rfl PRE_first_tail_x15_r0_body.cbridge8 : Host.Ts.Sim.Full.bridgeOf PRE_first_tail_x15_r0_body.s80.ffi = Host.Ts.Sim.Full.bridgeOf PRE_first_tail_x15_r0_body.s81.ffi
kernel_rfl PRE_first_tail_x15_r0_body.cpendR8 : pendRegB PRE_first_tail_x15_r0_body.kappa8 (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s81.ffi).mlx = true
kernel_rfl PRE_first_tail_x15_r0_body.cpendLe8 : Nat.ble (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s81.ffi).mlx.next (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s80.ffi).mlx.next = true
/-- **The compaction's native shift**, given the call's bookkeeping, its relation's facts (the model's and the
observers') and the canonical closedness. -/
theorem PRE_first_tail_x15_r0_body.cshift8 (clean : Conv.NClean (⟨18353, 15448, 2680757, 397⟩ : Conv.Cnt) (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s79.ffi).mlx) (hltC : ∀ h, PH (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s79.ffi).mlx h → h < (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s79.ffi).mlx.next) (nltC : ∀ i, PN (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s79.ffi).mlx i → i < (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s79.ffi).mlx.nnext) (itemsC : ∀ k v, (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s79.ffi).mlx.items.get k = some v → PN (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s79.ffi).mlx k) (tracedC : ∀ h o, (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s79.ffi).mlx.objs.get h = some o → ∀ i ∈ objTraces o, i < PRE_first_tail_x15_r0_body.P8.NL) (cl : SSt (· < 397) PRE_first_tail_x15_r0_body.cx0_8.mlx)
    (hobjC : ∀ h, PRE_first_tail_x15_r0_body.fxC_8.get h = some () → ((Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s79.ffi).mlx.objs.get h).isSome = true)
    (hfC : ∀ h, (PRE_first_tail_x15_r0_body.krC_8.flags.get h).isSome = true → ((Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s79.ffi).mlx.objs.get h).isSome = true)
    (htC : ∀ h, (PRE_first_tail_x15_r0_body.krC_8.targs.get h).isSome = true → ((Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s79.ffi).mlx.objs.get h).isSome = true)
    (hclC : ∀ h l, PRE_first_tail_x15_r0_body.krC_8.targs.get h = some l → Host.Ts.Sim.Full.STargs (· < (⟨18353, 15448, 2680757, 397⟩ : Conv.Cnt).n) l) :
    Conv.FullShiftQ PRE_first_tail_x15_r0_body.P8 397 PRE_first_tail_x15_r0_body.kappa8 PRE_first_tail_x15_r0_body.s81.ffi PRE_first_tail_x15_r0_body.s80.ffi :=
  ⟨PRE_first_tail_x15_r0_body.cnshift8 clean hltC nltC itemsC tracedC cl, PRE_first_tail_x15_r0_body.cqueue8, fun t ht => bSN_sound (List.all_eq_true.mp PRE_first_tail_x15_r0_body.ctokSupp8 t ht),
    PRE_first_tail_x15_r0_body.cbridge8,
    liveShift_foot (x0' := Host.Ts.Sim.Full.mlxOf PRE_first_tail_x15_r0_body.s81.ffi) (x1' := Host.Ts.Sim.Full.mlxOf PRE_first_tail_x15_r0_body.s80.ffi) (PRE_first_tail_x15_r0_body.cfoot8 clean hltC nltC itemsC tracedC cl) rfl PRE_first_tail_x15_r0_body.ofx0_8 PRE_first_tail_x15_r0_body.ofx1_8 hobjC PRE_first_tail_x15_r0_body.ff08 PRE_first_tail_x15_r0_body.ff18 PRE_first_tail_x15_r0_body.ffck8,
    kernShift_foot (x0' := Host.Ts.Sim.Full.mlxOf PRE_first_tail_x15_r0_body.s81.ffi) (x1' := Host.Ts.Sim.Full.mlxOf PRE_first_tail_x15_r0_body.s80.ffi) (PRE_first_tail_x15_r0_body.cfoot8 clean hltC nltC itemsC tracedC cl) rfl PRE_first_tail_x15_r0_body.okr0_8 PRE_first_tail_x15_r0_body.okr1_8 (Nat.le_of_ble_eq_true PRE_first_tail_x15_r0_body.fkn8) hfC htC hclC
      PRE_first_tail_x15_r0_body.fkf08 PRE_first_tail_x15_r0_body.fkt08 PRE_first_tail_x15_r0_body.fkf18 PRE_first_tail_x15_r0_body.fkt18 PRE_first_tail_x15_r0_body.fkck8,
    pendReg_of rfl PRE_first_tail_x15_r0_body.cnh08 PRE_first_tail_x15_r0_body.cnh18 (Nat.le_of_ble_eq_true PRE_first_tail_x15_r0_body.cpendLe8) PRE_first_tail_x15_r0_body.cpendR8⟩

end Host.Load.Run.Tpl
