import host.sim.template.a4pre_first_tail_x15_r0_body.SiteCl4
import host.sim.conv.CompactFull
import host.sim.template.FootGen
set_option Elab.async false
namespace Host.Load.Run.Tpl
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
open Host.Ts Host.Ts.Sim Host.Ts.Sim.Template

/-! The compaction's native shift at call site 4 from its footprint (`Conv.nshift_of_foot`), and the observers'
(`liveShift_foot`, `kernShift_foot`): `Conv.FullShiftQ` for `Conv.full_compactQ`, given the call's bookkeeping and its
relation's facts. -/

/-- The load parameters of the chain (band-free: its start's node counter as `NL` and `N0`). -/
def PRE_first_tail_x15_r0_body.Pc4 : LoadP := ⟨18151, 131072, 1099511627776, 15235, 15235, []⟩
/-- The site's band raised to the map's checked fixed-node prefix, including newly recorded closure traces. -/
def PRE_first_tail_x15_r0_body.P4 : LoadP := PRE_first_tail_x15_r0_body.Pc4.raise 15381
kernel_rfl PRE_first_tail_x15_r0_body.craise4 : Nat.ble PRE_first_tail_x15_r0_body.Pc4.N0 15381 = true
theorem PRE_first_tail_x15_r0_body.raised4 : Host.Ts.Sim.Full.Raised PRE_first_tail_x15_r0_body.Pc4 PRE_first_tail_x15_r0_body.P4 :=
  .inr ⟨15381, rfl, Nat.le_of_ble_eq_true PRE_first_tail_x15_r0_body.craise4, rfl⟩
noncomputable abbrev PRE_first_tail_x15_r0_body.cx0_4 : Host.Load.LSt := clearTokens (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s55.ffi)
noncomputable abbrev PRE_first_tail_x15_r0_body.cx1_4 : Host.Load.LSt := clearTokens (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s54.ffi)
def PRE_first_tail_x15_r0_body.khinv4 : PTrie Nat := Stage.setAll PTrie.nil []
def PRE_first_tail_x15_r0_body.kninv4 : PTrie Nat := Stage.setAll PTrie.nil []
/-- The stage's footprint: its written and fresh handles, fresh nodes, written and fresh items. -/
def PRE_first_tail_x15_r0_body.cwS4 : List Nat := []
def PRE_first_tail_x15_r0_body.cnS4 : List Nat := List.range' 15381 0
def PRE_first_tail_x15_r0_body.ciS4 : List Nat := [] ++ List.range' 15381 0

-- the small checks (`MChecks`'s)
kernel_rfl PRE_first_tail_x15_r0_body.cnh04 : PRE_first_tail_x15_r0_body.kd4.nh0 = PRE_first_tail_x15_r0_body.cx0_4.mlx.next
kernel_rfl PRE_first_tail_x15_r0_body.cnh14 : PRE_first_tail_x15_r0_body.kd4.nh1 = PRE_first_tail_x15_r0_body.cx1_4.mlx.next
kernel_rfl PRE_first_tail_x15_r0_body.cnn04 : PRE_first_tail_x15_r0_body.kd4.nn0 = PRE_first_tail_x15_r0_body.cx0_4.mlx.nnext
kernel_rfl PRE_first_tail_x15_r0_body.cnn14 : PRE_first_tail_x15_r0_body.kd4.nn1 = PRE_first_tail_x15_r0_body.cx1_4.mlx.nnext
kernel_rfl PRE_first_tail_x15_r0_body.cplo4 : (Nat.blt 0 PRE_first_tail_x15_r0_body.P4.lo && Nat.ble PRE_first_tail_x15_r0_body.P4.lo PRE_first_tail_x15_r0_body.cx0_4.mlx.next && Nat.ble PRE_first_tail_x15_r0_body.P4.lo RData.bigHi && Nat.ble RData.bigHi PRE_first_tail_x15_r0_body.P4.E) = true
kernel_rfl PRE_first_tail_x15_r0_body.ccnt4 : (Nat.ble PRE_first_tail_x15_r0_body.cx0_4.mlx.next PRE_first_tail_x15_r0_body.cx1_4.mlx.next && Nat.ble PRE_first_tail_x15_r0_body.cx0_4.mlx.nnext PRE_first_tail_x15_r0_body.cx1_4.mlx.nnext) = true
kernel_rfl PRE_first_tail_x15_r0_body.cnband4 : (Nat.blt 0 PRE_first_tail_x15_r0_body.P4.NL && Nat.ble PRE_first_tail_x15_r0_body.P4.NL PRE_first_tail_x15_r0_body.P4.N0 && Nat.ble PRE_first_tail_x15_r0_body.P4.N0 PRE_first_tail_x15_r0_body.cx0_4.mlx.nnext) = true
kernel_rfl PRE_first_tail_x15_r0_body.chbelow4 : PRE_first_tail_x15_r0_body.kd4.checkHndBelow = true
kernel_rfl PRE_first_tail_x15_r0_body.chren4 : checkRenG PRE_first_tail_x15_r0_body.kd4.hnd PRE_first_tail_x15_r0_body.khinv4 (phB PRE_first_tail_x15_r0_body.cx0_4.mlx) = true
kernel_rfl PRE_first_tail_x15_r0_body.cband4 : PRE_first_tail_x15_r0_body.kd4.checkBand PRE_first_tail_x15_r0_body.P4.lo = true
kernel_rfl PRE_first_tail_x15_r0_body.cnh1pos4 : Nat.blt 0 PRE_first_tail_x15_r0_body.kd4.nh1 = true
kernel_rfl PRE_first_tail_x15_r0_body.cnren4 : checkRenG PRE_first_tail_x15_r0_body.kd4.node PRE_first_tail_x15_r0_body.kninv4 (pnB PRE_first_tail_x15_r0_body.cx0_4.mlx) = true
kernel_rfl PRE_first_tail_x15_r0_body.cnlow4 : (PTrie.keysA PRE_first_tail_x15_r0_body.kd4.node).all (fun j => Nat.ble PRE_first_tail_x15_r0_body.P4.NL j && Nat.blt (PRE_first_tail_x15_r0_body.kd4.nodeF j) PRE_first_tail_x15_r0_body.cx1_4.mlx.nnext) = true
kernel_rfl PRE_first_tail_x15_r0_body.cabs0a4 : PRE_first_tail_x15_r0_body.cx0_4.mlx.arrs.get 0 = none
kernel_rfl PRE_first_tail_x15_r0_body.cabs0b4 : PRE_first_tail_x15_r0_body.cx0_4.mlx.objs.get 0 = none
kernel_rfl PRE_first_tail_x15_r0_body.ctok14 : PRE_first_tail_x15_r0_body.cx1_4.mlx.tokens = []
kernel_rfl PRE_first_tail_x15_r0_body.cpend4 : PRE_first_tail_x15_r0_body.cx1_4.mlx.pending = PRE_first_tail_x15_r0_body.cx0_4.mlx.pending.map PRE_first_tail_x15_r0_body.kappa4.pend
kernel_rfl PRE_first_tail_x15_r0_body.cerrh4 : PRE_first_tail_x15_r0_body.cx1_4.mlx.errh = PRE_first_tail_x15_r0_body.cx0_4.mlx.errh.map PRE_first_tail_x15_r0_body.kappa4.arg
kernel_rfl PRE_first_tail_x15_r0_body.cfiles4 : PRE_first_tail_x15_r0_body.cx1_4.mlx.files = PRE_first_tail_x15_r0_body.cx0_4.mlx.files
kernel_rfl PRE_first_tail_x15_r0_body.carch4 : PRE_first_tail_x15_r0_body.cx1_4.mlx.arch = PRE_first_tail_x15_r0_body.cx0_4.mlx.arch
kernel_rfl PRE_first_tail_x15_r0_body.csizes4 : PRE_first_tail_x15_r0_body.cx1_4.mlx.deviceSizes = PRE_first_tail_x15_r0_body.cx0_4.mlx.deviceSizes
kernel_rfl PRE_first_tail_x15_r0_body.cwired4 : PRE_first_tail_x15_r0_body.cx1_4.mlx.wired = PRE_first_tail_x15_r0_body.cx0_4.mlx.wired
kernel_rfl PRE_first_tail_x15_r0_body.chost4 : PRE_first_tail_x15_r0_body.cx1_4.host = PRE_first_tail_x15_r0_body.cx0_4.host
-- the compaction map's addresses are `PRE_first_tail_x15_r0_body.kd4`'s
kernel_rfl PRE_first_tail_x15_r0_body.ckn04 : PRE_first_tail_x15_r0_body.kd4.n0 = 2678119
kernel_rfl PRE_first_tail_x15_r0_body.ckn14 : PRE_first_tail_x15_r0_body.kd4.n1 = 2678121
kernel_rfl PRE_first_tail_x15_r0_body.ckheap4 : (PTrie.keysA PRE_first_tail_x15_r0_body.kd4.heap).all (fun x => Nat.ble 2678119 x) = true
kernel_rfl PRE_first_tail_x15_r0_body.ckpl4 : (List.range 0).all (fun j => decide (PRE_first_tail_x15_r0_body.kd4.heap.get (2678119 + j) = nth? PRE_first_tail_x15_r0_body.pl4 j)) = true
-- the map fixes the call's names (`Conv.fixOld_compact`), the call's counters
kernel_rfl PRE_first_tail_x15_r0_body.fja4 : Nat.ble 2678119 2678119 = true
kernel_rfl PRE_first_tail_x15_r0_body.fn4 : Nat.ble 251 251 = true
kernel_rfl PRE_first_tail_x15_r0_body.fjaD4 : Nat.ble 2678119 PRE_first_tail_x15_r0_body.kd4.n0 = true
kernel_rfl PRE_first_tail_x15_r0_body.fxn4 : Nat.ble 18286 PRE_first_tail_x15_r0_body.kd4.nh0 = true
kernel_rfl PRE_first_tail_x15_r0_body.fnn4 : Nat.ble 15381 PRE_first_tail_x15_r0_body.kd4.nn0 = true
kernel_rfl PRE_first_tail_x15_r0_body.fxb4 : Nat.ble 18286 RData.bigHi = true
kernel_rfl PRE_first_tail_x15_r0_body.fheap4 : (PTrie.keysA PRE_first_tail_x15_r0_body.kd4.heap).all (Nat.ble (⟨18286, 15381, 2678119, 251⟩ : Conv.Cnt).ja) = true
kernel_rfl PRE_first_tail_x15_r0_body.fhnd4 : (PTrie.keysA PRE_first_tail_x15_r0_body.kd4.hnd).all (Nat.ble (⟨18286, 15381, 2678119, 251⟩ : Conv.Cnt).xn) = true
kernel_rfl PRE_first_tail_x15_r0_body.fnode4 : (PTrie.keysA PRE_first_tail_x15_r0_body.kd4.node).all (Nat.ble (⟨18286, 15381, 2678119, 251⟩ : Conv.Cnt).nn) = true
/-- The compaction map fixes the call's names. -/
theorem PRE_first_tail_x15_r0_body.cfix4 : Conv.FixOld (⟨18286, 15381, 2678119, 251⟩ : Conv.Cnt) PRE_first_tail_x15_r0_body.kappa4 :=
  Conv.fixOld_compact (Nat.le_of_ble_eq_true PRE_first_tail_x15_r0_body.fja4) (Nat.le_of_ble_eq_true PRE_first_tail_x15_r0_body.fn4) (Nat.le_of_ble_eq_true PRE_first_tail_x15_r0_body.fjaD4) (Nat.le_of_ble_eq_true PRE_first_tail_x15_r0_body.fxn4) (Nat.le_of_ble_eq_true PRE_first_tail_x15_r0_body.fnn4) (Nat.le_of_ble_eq_true PRE_first_tail_x15_r0_body.fxb4) PRE_first_tail_x15_r0_body.fheap4 PRE_first_tail_x15_r0_body.fhnd4 PRE_first_tail_x15_r0_body.fnode4
kernel_rfl PRE_first_tail_x15_r0_body.fcxn4 : (⟨18286, 15381, 2678119, 251⟩ : Conv.Cnt).xn = (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s53.ffi).mlx.next
kernel_rfl PRE_first_tail_x15_r0_body.fcnn4 : (⟨18286, 15381, 2678119, 251⟩ : Conv.Cnt).nn = (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s53.ffi).mlx.nnext
kernel_rfl PRE_first_tail_x15_r0_body.fle04 : (Nat.ble (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s53.ffi).mlx.next PRE_first_tail_x15_r0_body.cx0_4.mlx.next && Nat.ble (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s53.ffi).mlx.nnext PRE_first_tail_x15_r0_body.cx0_4.mlx.nnext && Nat.ble (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s53.ffi).mlx.next RData.bigHi) = true
kernel_rfl PRE_first_tail_x15_r0_body.fnk4 : (PTrie.keysA PRE_first_tail_x15_r0_body.kd4.node).all (Nat.ble (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s53.ffi).mlx.nnext) = true
-- the merged state keeps the call's entries off the stage's footprint
kernel_rfl PRE_first_tail_x15_r0_body.f1A4 : PRE_first_tail_x15_r0_body.cx1_4.mlx.arrs = Stage.setAll (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s53.ffi).mlx.arrs (PRE_first_tail_x15_r0_body.cwS4.filterMap fun i => (PRE_first_tail_x15_r0_body.cx1_4.mlx.arrs.get i).map (i, ·))
kernel_rfl PRE_first_tail_x15_r0_body.f1O4 : PRE_first_tail_x15_r0_body.cx1_4.mlx.objs = Stage.setAll (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s53.ffi).mlx.objs (PRE_first_tail_x15_r0_body.cwS4.filterMap fun i => (PRE_first_tail_x15_r0_body.cx1_4.mlx.objs.get i).map (i, ·))
kernel_rfl PRE_first_tail_x15_r0_body.f1N4 : PRE_first_tail_x15_r0_body.cx1_4.mlx.nodes = Stage.setAll (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s53.ffi).mlx.nodes (PRE_first_tail_x15_r0_body.cnS4.filterMap fun i => (PRE_first_tail_x15_r0_body.cx1_4.mlx.nodes.get i).map (i, ·))
kernel_rfl PRE_first_tail_x15_r0_body.f1I4 : PRE_first_tail_x15_r0_body.cx1_4.mlx.items = Stage.setAll (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s53.ffi).mlx.items (PRE_first_tail_x15_r0_body.ciS4.filterMap fun i => (PRE_first_tail_x15_r0_body.cx1_4.mlx.items.get i).map (i, ·))
kernel_rfl PRE_first_tail_x15_r0_body.fbd4 : (PRE_first_tail_x15_r0_body.clo4 ++ PRE_first_tail_x15_r0_body.cln4 ++ PRE_first_tail_x15_r0_body.cli4 ++ PRE_first_tail_x15_r0_body.cwS4 ++ PRE_first_tail_x15_r0_body.cnS4 ++ PRE_first_tail_x15_r0_body.ciS4).all (fun i => Nat.blt (i / 4096) (4 ^ 31)) = true
kernel_rfl PRE_first_tail_x15_r0_body.fincW4 : PRE_first_tail_x15_r0_body.cwS4.all (fun h => !Nat.blt h (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s53.ffi).mlx.next || PRE_first_tail_x15_r0_body.clo4.contains h) = true
kernel_rfl PRE_first_tail_x15_r0_body.fincI4 : PRE_first_tail_x15_r0_body.ciS4.all (fun k => !Nat.blt k (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s53.ffi).mlx.nnext || PRE_first_tail_x15_r0_body.cli4.contains k) = true
kernel_rfl PRE_first_tail_x15_r0_body.fincN4 : PRE_first_tail_x15_r0_body.cnS4.all (Nat.ble (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s53.ffi).mlx.nnext) = true
kernel_rfl PRE_first_tail_x15_r0_body.flnF4 : PRE_first_tail_x15_r0_body.cln4.all (Nat.ble (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s53.ffi).mlx.nnext) = true
-- the checks over the changed lists
kernel_rfl PRE_first_tail_x15_r0_body.fh4 : PRE_first_tail_x15_r0_body.clo4.all (handleOK PRE_first_tail_x15_r0_body.kappa4 PRE_first_tail_x15_r0_body.P4.lo PRE_first_tail_x15_r0_body.cx0_4.mlx PRE_first_tail_x15_r0_body.cx1_4.mlx) = true
kernel_rfl PRE_first_tail_x15_r0_body.fo4 : PRE_first_tail_x15_r0_body.clo4.map (fun h => PRE_first_tail_x15_r0_body.cx1_4.mlx.objs.get (PRE_first_tail_x15_r0_body.kappa4.handle h)) = PRE_first_tail_x15_r0_body.clo4.map (fun h => (PRE_first_tail_x15_r0_body.cx0_4.mlx.objs.get h).map PRE_first_tail_x15_r0_body.kappa4.nobj)
kernel_rfl PRE_first_tail_x15_r0_body.fok4 : PRE_first_tail_x15_r0_body.clo4.all (objOK PRE_first_tail_x15_r0_body.kappa4 PRE_first_tail_x15_r0_body.P4.NL PRE_first_tail_x15_r0_body.cx0_4.mlx) = true
kernel_rfl PRE_first_tail_x15_r0_body.fnd4 : PRE_first_tail_x15_r0_body.cln4.all (nodeOKF PRE_first_tail_x15_r0_body.kappa4 PRE_first_tail_x15_r0_body.P4 PRE_first_tail_x15_r0_body.cx0_4.mlx PRE_first_tail_x15_r0_body.cx1_4.mlx) = true
kernel_rfl PRE_first_tail_x15_r0_body.fp4 : ((PRE_first_tail_x15_r0_body.cln4.filter (fullB PRE_first_tail_x15_r0_body.P4))).map (fun i => (PRE_first_tail_x15_r0_body.cx1_4.mlx.nodes.get (PRE_first_tail_x15_r0_body.kappa4.node i)).map Host.Mlx.Ffi.Node.prim) =
  ((PRE_first_tail_x15_r0_body.cln4.filter (fullB PRE_first_tail_x15_r0_body.P4))).map (fun i => (PRE_first_tail_x15_r0_body.cx0_4.mlx.nodes.get i).map fun nd => PRE_first_tail_x15_r0_body.kappa4.prim nd.prim)
kernel_rfl PRE_first_tail_x15_r0_body.fnordI4 : incrB PRE_first_tail_x15_r0_body.kd4.nodeF (List.range' 15381 0) = true
kernel_rfl PRE_first_tail_x15_r0_body.fnordK4 : (PTrie.keysA PRE_first_tail_x15_r0_body.kd4.node).all (fun k => Nat.ble 15381 k && Nat.blt k 15381) = true
kernel_rfl PRE_first_tail_x15_r0_body.fnordL4 : (PRE_first_tail_x15_r0_body.cln4.filter (Nat.ble PRE_first_tail_x15_r0_body.P4.N0)).all (fun i => Nat.ble i (PRE_first_tail_x15_r0_body.kd4.nodeF i) && (Nat.blt i 15381 || Nat.ble PRE_first_tail_x15_r0_body.kd4.nn0 i)) = true
theorem PRE_first_tail_x15_r0_body.fnord4 : (PRE_first_tail_x15_r0_body.cln4.filter (Nat.ble PRE_first_tail_x15_r0_body.P4.N0)).all (fun i => Nat.ble i (PRE_first_tail_x15_r0_body.kd4.nodeF i) &&
    (PTrie.keysA PRE_first_tail_x15_r0_body.kd4.node).all fun j => !Nat.blt j i || Nat.blt (PRE_first_tail_x15_r0_body.kd4.nodeF j) (PRE_first_tail_x15_r0_body.kd4.nodeF i)) = true :=
  cnord_of PRE_first_tail_x15_r0_body.cnlow4 PRE_first_tail_x15_r0_body.cnn14 PRE_first_tail_x15_r0_body.fnordI4 PRE_first_tail_x15_r0_body.fnordK4 PRE_first_tail_x15_r0_body.fnordL4
kernel_rfl PRE_first_tail_x15_r0_body.fi4 : PRE_first_tail_x15_r0_body.cli4.all (pnB PRE_first_tail_x15_r0_body.cx0_4.mlx) = true
kernel_rfl PRE_first_tail_x15_r0_body.fii4 : PRE_first_tail_x15_r0_body.cli4.all (fun k => decide (PRE_first_tail_x15_r0_body.cx1_4.mlx.items.get (PRE_first_tail_x15_r0_body.kappa4.node k) = (PRE_first_tail_x15_r0_body.cx0_4.mlx.items.get k).map PRE_first_tail_x15_r0_body.kappa4.nv)) = true
/-- **The compaction's footprint.** -/
theorem PRE_first_tail_x15_r0_body.cfoot4 (clean : Conv.NClean (⟨18286, 15381, 2678119, 251⟩ : Conv.Cnt) (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s53.ffi).mlx) (hltC : ∀ h, PH (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s53.ffi).mlx h → h < (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s53.ffi).mlx.next) (nltC : ∀ i, PN (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s53.ffi).mlx i → i < (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s53.ffi).mlx.nnext) (itemsC : ∀ k v, (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s53.ffi).mlx.items.get k = some v → PN (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s53.ffi).mlx k) (tracedC : ∀ h o, (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s53.ffi).mlx.objs.get h = some o → ∀ i ∈ objTraces o, i < PRE_first_tail_x15_r0_body.P4.NL) (cl : SSt (· < 251) PRE_first_tail_x15_r0_body.cx0_4.mlx) :
    Conv.MFoot PRE_first_tail_x15_r0_body.P4 251 PRE_first_tail_x15_r0_body.kappa4 PRE_first_tail_x15_r0_body.kd4 PRE_first_tail_x15_r0_body.khinv4 PRE_first_tail_x15_r0_body.kninv4 (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s53.ffi).mlx PRE_first_tail_x15_r0_body.cx0_4.mlx PRE_first_tail_x15_r0_body.cx1_4.mlx (⟨18286, 15381, 2678119, 251⟩ : Conv.Cnt) PRE_first_tail_x15_r0_body.clo4 PRE_first_tail_x15_r0_body.cln4 PRE_first_tail_x15_r0_body.cli4 PRE_first_tail_x15_r0_body.cwS4 PRE_first_tail_x15_r0_body.cnS4 PRE_first_tail_x15_r0_body.ciS4 :=
  ⟨rfl, rfl, rfl, PRE_first_tail_x15_r0_body.cnh04, PRE_first_tail_x15_r0_body.cnh14, PRE_first_tail_x15_r0_body.cnn04, PRE_first_tail_x15_r0_body.cnn14, PRE_first_tail_x15_r0_body.cplo4, PRE_first_tail_x15_r0_body.ccnt4, PRE_first_tail_x15_r0_body.cnband4, PRE_first_tail_x15_r0_body.chbelow4, PRE_first_tail_x15_r0_body.chren4, PRE_first_tail_x15_r0_body.cband4, PRE_first_tail_x15_r0_body.cnh1pos4, PRE_first_tail_x15_r0_body.cnren4, PRE_first_tail_x15_r0_body.cnlow4, PRE_first_tail_x15_r0_body.cabs0a4, PRE_first_tail_x15_r0_body.cabs0b4, PRE_first_tail_x15_r0_body.ctok14, PRE_first_tail_x15_r0_body.cpend4, PRE_first_tail_x15_r0_body.cerrh4, PRE_first_tail_x15_r0_body.cfiles4, PRE_first_tail_x15_r0_body.carch4, PRE_first_tail_x15_r0_body.csizes4, PRE_first_tail_x15_r0_body.cwired4, PRE_first_tail_x15_r0_body.cfix4, clean, PRE_first_tail_x15_r0_body.fcxn4, PRE_first_tail_x15_r0_body.fcnn4, hltC, nltC, itemsC, tracedC, cl, PRE_first_tail_x15_r0_body.fle04, PRE_first_tail_x15_r0_body.fnk4, PRE_first_tail_x15_r0_body.ckA4, PRE_first_tail_x15_r0_body.cobjsK4, PRE_first_tail_x15_r0_body.cnodesK4, PRE_first_tail_x15_r0_body.citemsK4, PRE_first_tail_x15_r0_body.f1A4, PRE_first_tail_x15_r0_body.f1O4, PRE_first_tail_x15_r0_body.f1N4, PRE_first_tail_x15_r0_body.f1I4, PRE_first_tail_x15_r0_body.fbd4, PRE_first_tail_x15_r0_body.fincW4, PRE_first_tail_x15_r0_body.fincI4, PRE_first_tail_x15_r0_body.fincN4, PRE_first_tail_x15_r0_body.flnF4, PRE_first_tail_x15_r0_body.fh4, PRE_first_tail_x15_r0_body.fo4, PRE_first_tail_x15_r0_body.fok4, PRE_first_tail_x15_r0_body.fnd4, PRE_first_tail_x15_r0_body.fp4, PRE_first_tail_x15_r0_body.fnord4, PRE_first_tail_x15_r0_body.fi4, PRE_first_tail_x15_r0_body.fii4⟩
theorem PRE_first_tail_x15_r0_body.cnshift4 (clean : Conv.NClean (⟨18286, 15381, 2678119, 251⟩ : Conv.Cnt) (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s53.ffi).mlx) (hltC : ∀ h, PH (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s53.ffi).mlx h → h < (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s53.ffi).mlx.next) (nltC : ∀ i, PN (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s53.ffi).mlx i → i < (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s53.ffi).mlx.nnext) (itemsC : ∀ k v, (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s53.ffi).mlx.items.get k = some v → PN (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s53.ffi).mlx k) (tracedC : ∀ h o, (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s53.ffi).mlx.objs.get h = some o → ∀ i ∈ objTraces o, i < PRE_first_tail_x15_r0_body.P4.NL) (cl : SSt (· < 251) PRE_first_tail_x15_r0_body.cx0_4.mlx) : NShift PRE_first_tail_x15_r0_body.P4 251 PRE_first_tail_x15_r0_body.kappa4 PRE_first_tail_x15_r0_body.cx0_4 PRE_first_tail_x15_r0_body.cx1_4 :=
  Conv.nshift_of_foot (PRE_first_tail_x15_r0_body.cfoot4 clean hltC nltC itemsC tracedC cl) PRE_first_tail_x15_r0_body.chost4 (compact_a_eq PRE_first_tail_x15_r0_body.ckn04 PRE_first_tail_x15_r0_body.ckn14 PRE_first_tail_x15_r0_body.ckheap4 PRE_first_tail_x15_r0_body.ckpl4)

-- the observers: the layers' states at the call, the canonical and the merged state, their footprints and checks
noncomputable def PRE_first_tail_x15_r0_body.fxC_4 : PTrie Unit := (Host.Ts.Sim.Full.freedOf PRE_first_tail_x15_r0_body.s53.ffi).getD PTrie.nil
noncomputable def PRE_first_tail_x15_r0_body.krC_4 : Host.Load.Layers.KRec := (Host.Ts.Sim.Full.krecOf PRE_first_tail_x15_r0_body.s53.ffi).getD Host.Load.Layers.KRec.empty
kernel_rfl PRE_first_tail_x15_r0_body.ofxC_4 : (Host.Ts.Sim.Full.freedOf PRE_first_tail_x15_r0_body.s53.ffi) = some PRE_first_tail_x15_r0_body.fxC_4
kernel_rfl PRE_first_tail_x15_r0_body.okrC_4 : (Host.Ts.Sim.Full.krecOf PRE_first_tail_x15_r0_body.s53.ffi) = some PRE_first_tail_x15_r0_body.krC_4
noncomputable def PRE_first_tail_x15_r0_body.fx0_4 : PTrie Unit := (Host.Ts.Sim.Full.freedOf PRE_first_tail_x15_r0_body.s55.ffi).getD PTrie.nil
noncomputable def PRE_first_tail_x15_r0_body.kr0_4 : Host.Load.Layers.KRec := (Host.Ts.Sim.Full.krecOf PRE_first_tail_x15_r0_body.s55.ffi).getD Host.Load.Layers.KRec.empty
kernel_rfl PRE_first_tail_x15_r0_body.ofx0_4 : (Host.Ts.Sim.Full.freedOf PRE_first_tail_x15_r0_body.s55.ffi) = some PRE_first_tail_x15_r0_body.fx0_4
kernel_rfl PRE_first_tail_x15_r0_body.okr0_4 : (Host.Ts.Sim.Full.krecOf PRE_first_tail_x15_r0_body.s55.ffi) = some PRE_first_tail_x15_r0_body.kr0_4
noncomputable def PRE_first_tail_x15_r0_body.fx1_4 : PTrie Unit := (Host.Ts.Sim.Full.freedOf PRE_first_tail_x15_r0_body.s54.ffi).getD PTrie.nil
noncomputable def PRE_first_tail_x15_r0_body.kr1_4 : Host.Load.Layers.KRec := (Host.Ts.Sim.Full.krecOf PRE_first_tail_x15_r0_body.s54.ffi).getD Host.Load.Layers.KRec.empty
kernel_rfl PRE_first_tail_x15_r0_body.ofx1_4 : (Host.Ts.Sim.Full.freedOf PRE_first_tail_x15_r0_body.s54.ffi) = some PRE_first_tail_x15_r0_body.fx1_4
kernel_rfl PRE_first_tail_x15_r0_body.okr1_4 : (Host.Ts.Sim.Full.krecOf PRE_first_tail_x15_r0_body.s54.ffi) = some PRE_first_tail_x15_r0_body.kr1_4
kernel_rfl PRE_first_tail_x15_r0_body.ff04 : PRE_first_tail_x15_r0_body.fx0_4 = Stage.setAll PRE_first_tail_x15_r0_body.fxC_4 (PRE_first_tail_x15_r0_body.clo4.filterMap fun i => (PRE_first_tail_x15_r0_body.fx0_4.get i).map (i, ·))
kernel_rfl PRE_first_tail_x15_r0_body.ff14 : PRE_first_tail_x15_r0_body.fx1_4 = Stage.setAll PRE_first_tail_x15_r0_body.fxC_4 (PRE_first_tail_x15_r0_body.cwS4.filterMap fun i => (PRE_first_tail_x15_r0_body.fx1_4.get i).map (i, ·))
kernel_rfl PRE_first_tail_x15_r0_body.ffck4 : freedLB PRE_first_tail_x15_r0_body.kappa4 PRE_first_tail_x15_r0_body.cx0_4.mlx PRE_first_tail_x15_r0_body.fx0_4 PRE_first_tail_x15_r0_body.fx1_4 PRE_first_tail_x15_r0_body.clo4 = true
kernel_rfl PRE_first_tail_x15_r0_body.fkf04 : PRE_first_tail_x15_r0_body.kr0_4.flags = Stage.setAll PRE_first_tail_x15_r0_body.krC_4.flags (PRE_first_tail_x15_r0_body.clo4.filterMap fun i => (PRE_first_tail_x15_r0_body.kr0_4.flags.get i).map (i, ·))
kernel_rfl PRE_first_tail_x15_r0_body.fkt04 : PRE_first_tail_x15_r0_body.kr0_4.targs = Stage.setAll PRE_first_tail_x15_r0_body.krC_4.targs (PRE_first_tail_x15_r0_body.clo4.filterMap fun i => (PRE_first_tail_x15_r0_body.kr0_4.targs.get i).map (i, ·))
kernel_rfl PRE_first_tail_x15_r0_body.fkf14 : PRE_first_tail_x15_r0_body.kr1_4.flags = Stage.setAll PRE_first_tail_x15_r0_body.krC_4.flags (PRE_first_tail_x15_r0_body.cwS4.filterMap fun i => (PRE_first_tail_x15_r0_body.kr1_4.flags.get i).map (i, ·))
kernel_rfl PRE_first_tail_x15_r0_body.fkt14 : PRE_first_tail_x15_r0_body.kr1_4.targs = Stage.setAll PRE_first_tail_x15_r0_body.krC_4.targs (PRE_first_tail_x15_r0_body.cwS4.filterMap fun i => (PRE_first_tail_x15_r0_body.kr1_4.targs.get i).map (i, ·))
kernel_rfl PRE_first_tail_x15_r0_body.fkck4 : krecLB PRE_first_tail_x15_r0_body.kappa4 251 PRE_first_tail_x15_r0_body.cx0_4.mlx PRE_first_tail_x15_r0_body.kr0_4 PRE_first_tail_x15_r0_body.kr1_4 PRE_first_tail_x15_r0_body.clo4 = true
kernel_rfl PRE_first_tail_x15_r0_body.fkn4 : Nat.ble 251 251 = true
-- the bridge and the pending traces' regions
kernel_rfl PRE_first_tail_x15_r0_body.cbridge4 : Host.Ts.Sim.Full.bridgeOf PRE_first_tail_x15_r0_body.s54.ffi = Host.Ts.Sim.Full.bridgeOf PRE_first_tail_x15_r0_body.s55.ffi
kernel_rfl PRE_first_tail_x15_r0_body.cpendR4 : pendRegB PRE_first_tail_x15_r0_body.kappa4 (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s55.ffi).mlx = true
kernel_rfl PRE_first_tail_x15_r0_body.cpendLe4 : Nat.ble (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s55.ffi).mlx.next (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s54.ffi).mlx.next = true
/-- **The compaction's native shift**, given the call's bookkeeping, its relation's facts (the model's and the
observers') and the canonical closedness. -/
theorem PRE_first_tail_x15_r0_body.cshift4 (clean : Conv.NClean (⟨18286, 15381, 2678119, 251⟩ : Conv.Cnt) (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s53.ffi).mlx) (hltC : ∀ h, PH (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s53.ffi).mlx h → h < (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s53.ffi).mlx.next) (nltC : ∀ i, PN (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s53.ffi).mlx i → i < (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s53.ffi).mlx.nnext) (itemsC : ∀ k v, (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s53.ffi).mlx.items.get k = some v → PN (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s53.ffi).mlx k) (tracedC : ∀ h o, (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s53.ffi).mlx.objs.get h = some o → ∀ i ∈ objTraces o, i < PRE_first_tail_x15_r0_body.P4.NL) (cl : SSt (· < 251) PRE_first_tail_x15_r0_body.cx0_4.mlx)
    (hobjC : ∀ h, PRE_first_tail_x15_r0_body.fxC_4.get h = some () → ((Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s53.ffi).mlx.objs.get h).isSome = true)
    (hfC : ∀ h, (PRE_first_tail_x15_r0_body.krC_4.flags.get h).isSome = true → ((Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s53.ffi).mlx.objs.get h).isSome = true)
    (htC : ∀ h, (PRE_first_tail_x15_r0_body.krC_4.targs.get h).isSome = true → ((Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s53.ffi).mlx.objs.get h).isSome = true)
    (hclC : ∀ h l, PRE_first_tail_x15_r0_body.krC_4.targs.get h = some l → Host.Ts.Sim.Full.STargs (· < (⟨18286, 15381, 2678119, 251⟩ : Conv.Cnt).n) l) :
    Conv.FullShiftQ PRE_first_tail_x15_r0_body.P4 251 PRE_first_tail_x15_r0_body.kappa4 PRE_first_tail_x15_r0_body.s55.ffi PRE_first_tail_x15_r0_body.s54.ffi :=
  ⟨PRE_first_tail_x15_r0_body.cnshift4 clean hltC nltC itemsC tracedC cl, PRE_first_tail_x15_r0_body.cqueue4, fun t ht => bSN_sound (List.all_eq_true.mp PRE_first_tail_x15_r0_body.ctokSupp4 t ht),
    PRE_first_tail_x15_r0_body.cbridge4,
    liveShift_foot (x0' := Host.Ts.Sim.Full.mlxOf PRE_first_tail_x15_r0_body.s55.ffi) (x1' := Host.Ts.Sim.Full.mlxOf PRE_first_tail_x15_r0_body.s54.ffi) (PRE_first_tail_x15_r0_body.cfoot4 clean hltC nltC itemsC tracedC cl) rfl PRE_first_tail_x15_r0_body.ofx0_4 PRE_first_tail_x15_r0_body.ofx1_4 hobjC PRE_first_tail_x15_r0_body.ff04 PRE_first_tail_x15_r0_body.ff14 PRE_first_tail_x15_r0_body.ffck4,
    kernShift_foot (x0' := Host.Ts.Sim.Full.mlxOf PRE_first_tail_x15_r0_body.s55.ffi) (x1' := Host.Ts.Sim.Full.mlxOf PRE_first_tail_x15_r0_body.s54.ffi) (PRE_first_tail_x15_r0_body.cfoot4 clean hltC nltC itemsC tracedC cl) rfl PRE_first_tail_x15_r0_body.okr0_4 PRE_first_tail_x15_r0_body.okr1_4 (Nat.le_of_ble_eq_true PRE_first_tail_x15_r0_body.fkn4) hfC htC hclC
      PRE_first_tail_x15_r0_body.fkf04 PRE_first_tail_x15_r0_body.fkt04 PRE_first_tail_x15_r0_body.fkf14 PRE_first_tail_x15_r0_body.fkt14 PRE_first_tail_x15_r0_body.fkck4,
    pendReg_of rfl PRE_first_tail_x15_r0_body.cnh04 PRE_first_tail_x15_r0_body.cnh14 (Nat.le_of_ble_eq_true PRE_first_tail_x15_r0_body.cpendLe4) PRE_first_tail_x15_r0_body.cpendR4⟩

end Host.Load.Run.Tpl
