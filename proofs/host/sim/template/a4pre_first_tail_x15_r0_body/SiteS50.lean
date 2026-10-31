import host.sim.template.a4pre_first_tail_x15_r0_body.SiteCl50
import host.sim.conv.CompactFull
import host.sim.template.FootGen
set_option Elab.async false
namespace Host.Load.Run.Tpl
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
open Host.Ts Host.Ts.Sim Host.Ts.Sim.Template

/-! The compaction's native shift at call site 50 from its footprint (`Conv.nshift_of_foot`), and the observers'
(`liveShift_foot`, `kernShift_foot`): `Conv.FullShiftQ` for `Conv.full_compactQ`, given the call's bookkeeping and its
relation's facts. -/

/-- The load parameters of the chain (band-free: its start's node counter as `NL` and `N0`). -/
def PRE_first_tail_x15_r0_body.Pc50 : LoadP := ⟨18151, 131072, 1099511627776, 15235, 15235, []⟩
/-- The site's band raised to the map's checked fixed-node prefix, including newly recorded closure traces. -/
def PRE_first_tail_x15_r0_body.P50 : LoadP := PRE_first_tail_x15_r0_body.Pc50.raise 16270
kernel_rfl PRE_first_tail_x15_r0_body.craise50 : Nat.ble PRE_first_tail_x15_r0_body.Pc50.N0 16270 = true
theorem PRE_first_tail_x15_r0_body.raised50 : Host.Ts.Sim.Full.Raised PRE_first_tail_x15_r0_body.Pc50 PRE_first_tail_x15_r0_body.P50 :=
  .inr ⟨16270, rfl, Nat.le_of_ble_eq_true PRE_first_tail_x15_r0_body.craise50, rfl⟩
noncomputable abbrev PRE_first_tail_x15_r0_body.cx0_50 : Host.Load.LSt := clearTokens (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s490.ffi)
noncomputable abbrev PRE_first_tail_x15_r0_body.cx1_50 : Host.Load.LSt := clearTokens (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s489.ffi)
def PRE_first_tail_x15_r0_body.khinv50 : PTrie Nat := Stage.setAll PTrie.nil []
def PRE_first_tail_x15_r0_body.kninv50 : PTrie Nat := Stage.setAll PTrie.nil []
/-- The stage's footprint: its written and fresh handles, fresh nodes, written and fresh items. -/
def PRE_first_tail_x15_r0_body.cwS50 : List Nat := []
def PRE_first_tail_x15_r0_body.cnS50 : List Nat := List.range' 16270 0
def PRE_first_tail_x15_r0_body.ciS50 : List Nat := [] ++ List.range' 16270 0

-- the small checks (`MChecks`'s)
kernel_rfl PRE_first_tail_x15_r0_body.cnh050 : PRE_first_tail_x15_r0_body.kd50.nh0 = PRE_first_tail_x15_r0_body.cx0_50.mlx.next
kernel_rfl PRE_first_tail_x15_r0_body.cnh150 : PRE_first_tail_x15_r0_body.kd50.nh1 = PRE_first_tail_x15_r0_body.cx1_50.mlx.next
kernel_rfl PRE_first_tail_x15_r0_body.cnn050 : PRE_first_tail_x15_r0_body.kd50.nn0 = PRE_first_tail_x15_r0_body.cx0_50.mlx.nnext
kernel_rfl PRE_first_tail_x15_r0_body.cnn150 : PRE_first_tail_x15_r0_body.kd50.nn1 = PRE_first_tail_x15_r0_body.cx1_50.mlx.nnext
kernel_rfl PRE_first_tail_x15_r0_body.cplo50 : (Nat.blt 0 PRE_first_tail_x15_r0_body.P50.lo && Nat.ble PRE_first_tail_x15_r0_body.P50.lo PRE_first_tail_x15_r0_body.cx0_50.mlx.next && Nat.ble PRE_first_tail_x15_r0_body.P50.lo RData.bigHi && Nat.ble RData.bigHi PRE_first_tail_x15_r0_body.P50.E) = true
kernel_rfl PRE_first_tail_x15_r0_body.ccnt50 : (Nat.ble PRE_first_tail_x15_r0_body.cx0_50.mlx.next PRE_first_tail_x15_r0_body.cx1_50.mlx.next && Nat.ble PRE_first_tail_x15_r0_body.cx0_50.mlx.nnext PRE_first_tail_x15_r0_body.cx1_50.mlx.nnext) = true
kernel_rfl PRE_first_tail_x15_r0_body.cnband50 : (Nat.blt 0 PRE_first_tail_x15_r0_body.P50.NL && Nat.ble PRE_first_tail_x15_r0_body.P50.NL PRE_first_tail_x15_r0_body.P50.N0 && Nat.ble PRE_first_tail_x15_r0_body.P50.N0 PRE_first_tail_x15_r0_body.cx0_50.mlx.nnext) = true
kernel_rfl PRE_first_tail_x15_r0_body.chbelow50 : PRE_first_tail_x15_r0_body.kd50.checkHndBelow = true
kernel_rfl PRE_first_tail_x15_r0_body.chren50 : checkRenG PRE_first_tail_x15_r0_body.kd50.hnd PRE_first_tail_x15_r0_body.khinv50 (phB PRE_first_tail_x15_r0_body.cx0_50.mlx) = true
kernel_rfl PRE_first_tail_x15_r0_body.cband50 : PRE_first_tail_x15_r0_body.kd50.checkBand PRE_first_tail_x15_r0_body.P50.lo = true
kernel_rfl PRE_first_tail_x15_r0_body.cnh1pos50 : Nat.blt 0 PRE_first_tail_x15_r0_body.kd50.nh1 = true
kernel_rfl PRE_first_tail_x15_r0_body.cnren50 : checkRenG PRE_first_tail_x15_r0_body.kd50.node PRE_first_tail_x15_r0_body.kninv50 (pnB PRE_first_tail_x15_r0_body.cx0_50.mlx) = true
kernel_rfl PRE_first_tail_x15_r0_body.cnlow50 : (PTrie.keysA PRE_first_tail_x15_r0_body.kd50.node).all (fun j => Nat.ble PRE_first_tail_x15_r0_body.P50.NL j && Nat.blt (PRE_first_tail_x15_r0_body.kd50.nodeF j) PRE_first_tail_x15_r0_body.cx1_50.mlx.nnext) = true
kernel_rfl PRE_first_tail_x15_r0_body.cabs0a50 : PRE_first_tail_x15_r0_body.cx0_50.mlx.arrs.get 0 = none
kernel_rfl PRE_first_tail_x15_r0_body.cabs0b50 : PRE_first_tail_x15_r0_body.cx0_50.mlx.objs.get 0 = none
kernel_rfl PRE_first_tail_x15_r0_body.ctok150 : PRE_first_tail_x15_r0_body.cx1_50.mlx.tokens = []
kernel_rfl PRE_first_tail_x15_r0_body.cpend50 : PRE_first_tail_x15_r0_body.cx1_50.mlx.pending = PRE_first_tail_x15_r0_body.cx0_50.mlx.pending.map PRE_first_tail_x15_r0_body.kappa50.pend
kernel_rfl PRE_first_tail_x15_r0_body.cerrh50 : PRE_first_tail_x15_r0_body.cx1_50.mlx.errh = PRE_first_tail_x15_r0_body.cx0_50.mlx.errh.map PRE_first_tail_x15_r0_body.kappa50.arg
kernel_rfl PRE_first_tail_x15_r0_body.cfiles50 : PRE_first_tail_x15_r0_body.cx1_50.mlx.files = PRE_first_tail_x15_r0_body.cx0_50.mlx.files
kernel_rfl PRE_first_tail_x15_r0_body.carch50 : PRE_first_tail_x15_r0_body.cx1_50.mlx.arch = PRE_first_tail_x15_r0_body.cx0_50.mlx.arch
kernel_rfl PRE_first_tail_x15_r0_body.csizes50 : PRE_first_tail_x15_r0_body.cx1_50.mlx.deviceSizes = PRE_first_tail_x15_r0_body.cx0_50.mlx.deviceSizes
kernel_rfl PRE_first_tail_x15_r0_body.cwired50 : PRE_first_tail_x15_r0_body.cx1_50.mlx.wired = PRE_first_tail_x15_r0_body.cx0_50.mlx.wired
kernel_rfl PRE_first_tail_x15_r0_body.chost50 : PRE_first_tail_x15_r0_body.cx1_50.host = PRE_first_tail_x15_r0_body.cx0_50.host
-- the compaction map's addresses are `PRE_first_tail_x15_r0_body.kd50`'s
kernel_rfl PRE_first_tail_x15_r0_body.ckn050 : PRE_first_tail_x15_r0_body.kd50.n0 = 2713908
kernel_rfl PRE_first_tail_x15_r0_body.ckn150 : PRE_first_tail_x15_r0_body.kd50.n1 = 2713927
kernel_rfl PRE_first_tail_x15_r0_body.ckheap50 : (PTrie.keysA PRE_first_tail_x15_r0_body.kd50.heap).all (fun x => Nat.ble 2713907 x) = true
kernel_rfl PRE_first_tail_x15_r0_body.ckpl50 : (List.range 1).all (fun j => decide (PRE_first_tail_x15_r0_body.kd50.heap.get (2713907 + j) = nth? PRE_first_tail_x15_r0_body.pl50 j)) = true
-- the map fixes the call's names (`Conv.fixOld_compact`), the call's counters
kernel_rfl PRE_first_tail_x15_r0_body.fja50 : Nat.ble 2713907 2713907 = true
kernel_rfl PRE_first_tail_x15_r0_body.fn50 : Nat.ble 2191 2191 = true
kernel_rfl PRE_first_tail_x15_r0_body.fjaD50 : Nat.ble 2713907 PRE_first_tail_x15_r0_body.kd50.n0 = true
kernel_rfl PRE_first_tail_x15_r0_body.fxn50 : Nat.ble 19183 PRE_first_tail_x15_r0_body.kd50.nh0 = true
kernel_rfl PRE_first_tail_x15_r0_body.fnn50 : Nat.ble 16270 PRE_first_tail_x15_r0_body.kd50.nn0 = true
kernel_rfl PRE_first_tail_x15_r0_body.fxb50 : Nat.ble 19183 RData.bigHi = true
kernel_rfl PRE_first_tail_x15_r0_body.fheap50 : (PTrie.keysA PRE_first_tail_x15_r0_body.kd50.heap).all (Nat.ble (⟨19183, 16270, 2713907, 2191⟩ : Conv.Cnt).ja) = true
kernel_rfl PRE_first_tail_x15_r0_body.fhnd50 : (PTrie.keysA PRE_first_tail_x15_r0_body.kd50.hnd).all (Nat.ble (⟨19183, 16270, 2713907, 2191⟩ : Conv.Cnt).xn) = true
kernel_rfl PRE_first_tail_x15_r0_body.fnode50 : (PTrie.keysA PRE_first_tail_x15_r0_body.kd50.node).all (Nat.ble (⟨19183, 16270, 2713907, 2191⟩ : Conv.Cnt).nn) = true
/-- The compaction map fixes the call's names. -/
theorem PRE_first_tail_x15_r0_body.cfix50 : Conv.FixOld (⟨19183, 16270, 2713907, 2191⟩ : Conv.Cnt) PRE_first_tail_x15_r0_body.kappa50 :=
  Conv.fixOld_compact (Nat.le_of_ble_eq_true PRE_first_tail_x15_r0_body.fja50) (Nat.le_of_ble_eq_true PRE_first_tail_x15_r0_body.fn50) (Nat.le_of_ble_eq_true PRE_first_tail_x15_r0_body.fjaD50) (Nat.le_of_ble_eq_true PRE_first_tail_x15_r0_body.fxn50) (Nat.le_of_ble_eq_true PRE_first_tail_x15_r0_body.fnn50) (Nat.le_of_ble_eq_true PRE_first_tail_x15_r0_body.fxb50) PRE_first_tail_x15_r0_body.fheap50 PRE_first_tail_x15_r0_body.fhnd50 PRE_first_tail_x15_r0_body.fnode50
kernel_rfl PRE_first_tail_x15_r0_body.fcxn50 : (⟨19183, 16270, 2713907, 2191⟩ : Conv.Cnt).xn = (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s488.ffi).mlx.next
kernel_rfl PRE_first_tail_x15_r0_body.fcnn50 : (⟨19183, 16270, 2713907, 2191⟩ : Conv.Cnt).nn = (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s488.ffi).mlx.nnext
kernel_rfl PRE_first_tail_x15_r0_body.fle050 : (Nat.ble (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s488.ffi).mlx.next PRE_first_tail_x15_r0_body.cx0_50.mlx.next && Nat.ble (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s488.ffi).mlx.nnext PRE_first_tail_x15_r0_body.cx0_50.mlx.nnext && Nat.ble (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s488.ffi).mlx.next RData.bigHi) = true
kernel_rfl PRE_first_tail_x15_r0_body.fnk50 : (PTrie.keysA PRE_first_tail_x15_r0_body.kd50.node).all (Nat.ble (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s488.ffi).mlx.nnext) = true
-- the merged state keeps the call's entries off the stage's footprint
kernel_rfl PRE_first_tail_x15_r0_body.f1A50 : PRE_first_tail_x15_r0_body.cx1_50.mlx.arrs = Stage.setAll (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s488.ffi).mlx.arrs (PRE_first_tail_x15_r0_body.cwS50.filterMap fun i => (PRE_first_tail_x15_r0_body.cx1_50.mlx.arrs.get i).map (i, ·))
kernel_rfl PRE_first_tail_x15_r0_body.f1O50 : PRE_first_tail_x15_r0_body.cx1_50.mlx.objs = Stage.setAll (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s488.ffi).mlx.objs (PRE_first_tail_x15_r0_body.cwS50.filterMap fun i => (PRE_first_tail_x15_r0_body.cx1_50.mlx.objs.get i).map (i, ·))
kernel_rfl PRE_first_tail_x15_r0_body.f1N50 : PRE_first_tail_x15_r0_body.cx1_50.mlx.nodes = Stage.setAll (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s488.ffi).mlx.nodes (PRE_first_tail_x15_r0_body.cnS50.filterMap fun i => (PRE_first_tail_x15_r0_body.cx1_50.mlx.nodes.get i).map (i, ·))
kernel_rfl PRE_first_tail_x15_r0_body.f1I50 : PRE_first_tail_x15_r0_body.cx1_50.mlx.items = Stage.setAll (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s488.ffi).mlx.items (PRE_first_tail_x15_r0_body.ciS50.filterMap fun i => (PRE_first_tail_x15_r0_body.cx1_50.mlx.items.get i).map (i, ·))
kernel_rfl PRE_first_tail_x15_r0_body.fbd50 : (PRE_first_tail_x15_r0_body.clo50 ++ PRE_first_tail_x15_r0_body.cln50 ++ PRE_first_tail_x15_r0_body.cli50 ++ PRE_first_tail_x15_r0_body.cwS50 ++ PRE_first_tail_x15_r0_body.cnS50 ++ PRE_first_tail_x15_r0_body.ciS50).all (fun i => Nat.blt (i / 4096) (4 ^ 31)) = true
kernel_rfl PRE_first_tail_x15_r0_body.fincW50 : PRE_first_tail_x15_r0_body.cwS50.all (fun h => !Nat.blt h (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s488.ffi).mlx.next || PRE_first_tail_x15_r0_body.clo50.contains h) = true
kernel_rfl PRE_first_tail_x15_r0_body.fincI50 : PRE_first_tail_x15_r0_body.ciS50.all (fun k => !Nat.blt k (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s488.ffi).mlx.nnext || PRE_first_tail_x15_r0_body.cli50.contains k) = true
kernel_rfl PRE_first_tail_x15_r0_body.fincN50 : PRE_first_tail_x15_r0_body.cnS50.all (Nat.ble (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s488.ffi).mlx.nnext) = true
kernel_rfl PRE_first_tail_x15_r0_body.flnF50 : PRE_first_tail_x15_r0_body.cln50.all (Nat.ble (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s488.ffi).mlx.nnext) = true
-- the checks over the changed lists
kernel_rfl PRE_first_tail_x15_r0_body.fh50 : PRE_first_tail_x15_r0_body.clo50.all (handleOK PRE_first_tail_x15_r0_body.kappa50 PRE_first_tail_x15_r0_body.P50.lo PRE_first_tail_x15_r0_body.cx0_50.mlx PRE_first_tail_x15_r0_body.cx1_50.mlx) = true
kernel_rfl PRE_first_tail_x15_r0_body.fo50 : PRE_first_tail_x15_r0_body.clo50.map (fun h => PRE_first_tail_x15_r0_body.cx1_50.mlx.objs.get (PRE_first_tail_x15_r0_body.kappa50.handle h)) = PRE_first_tail_x15_r0_body.clo50.map (fun h => (PRE_first_tail_x15_r0_body.cx0_50.mlx.objs.get h).map PRE_first_tail_x15_r0_body.kappa50.nobj)
kernel_rfl PRE_first_tail_x15_r0_body.fok50 : PRE_first_tail_x15_r0_body.clo50.all (objOK PRE_first_tail_x15_r0_body.kappa50 PRE_first_tail_x15_r0_body.P50.NL PRE_first_tail_x15_r0_body.cx0_50.mlx) = true
kernel_rfl PRE_first_tail_x15_r0_body.fnd50 : PRE_first_tail_x15_r0_body.cln50.all (nodeOKF PRE_first_tail_x15_r0_body.kappa50 PRE_first_tail_x15_r0_body.P50 PRE_first_tail_x15_r0_body.cx0_50.mlx PRE_first_tail_x15_r0_body.cx1_50.mlx) = true
kernel_rfl PRE_first_tail_x15_r0_body.fp50 : ((PRE_first_tail_x15_r0_body.cln50.filter (fullB PRE_first_tail_x15_r0_body.P50))).map (fun i => (PRE_first_tail_x15_r0_body.cx1_50.mlx.nodes.get (PRE_first_tail_x15_r0_body.kappa50.node i)).map Host.Mlx.Ffi.Node.prim) =
  ((PRE_first_tail_x15_r0_body.cln50.filter (fullB PRE_first_tail_x15_r0_body.P50))).map (fun i => (PRE_first_tail_x15_r0_body.cx0_50.mlx.nodes.get i).map fun nd => PRE_first_tail_x15_r0_body.kappa50.prim nd.prim)
kernel_rfl PRE_first_tail_x15_r0_body.fnordI50 : incrB PRE_first_tail_x15_r0_body.kd50.nodeF (List.range' 16270 0) = true
kernel_rfl PRE_first_tail_x15_r0_body.fnordK50 : (PTrie.keysA PRE_first_tail_x15_r0_body.kd50.node).all (fun k => Nat.ble 16270 k && Nat.blt k 16270) = true
kernel_rfl PRE_first_tail_x15_r0_body.fnordL50 : (PRE_first_tail_x15_r0_body.cln50.filter (Nat.ble PRE_first_tail_x15_r0_body.P50.N0)).all (fun i => Nat.ble i (PRE_first_tail_x15_r0_body.kd50.nodeF i) && (Nat.blt i 16270 || Nat.ble PRE_first_tail_x15_r0_body.kd50.nn0 i)) = true
theorem PRE_first_tail_x15_r0_body.fnord50 : (PRE_first_tail_x15_r0_body.cln50.filter (Nat.ble PRE_first_tail_x15_r0_body.P50.N0)).all (fun i => Nat.ble i (PRE_first_tail_x15_r0_body.kd50.nodeF i) &&
    (PTrie.keysA PRE_first_tail_x15_r0_body.kd50.node).all fun j => !Nat.blt j i || Nat.blt (PRE_first_tail_x15_r0_body.kd50.nodeF j) (PRE_first_tail_x15_r0_body.kd50.nodeF i)) = true :=
  cnord_of PRE_first_tail_x15_r0_body.cnlow50 PRE_first_tail_x15_r0_body.cnn150 PRE_first_tail_x15_r0_body.fnordI50 PRE_first_tail_x15_r0_body.fnordK50 PRE_first_tail_x15_r0_body.fnordL50
kernel_rfl PRE_first_tail_x15_r0_body.fi50 : PRE_first_tail_x15_r0_body.cli50.all (pnB PRE_first_tail_x15_r0_body.cx0_50.mlx) = true
kernel_rfl PRE_first_tail_x15_r0_body.fii50 : PRE_first_tail_x15_r0_body.cli50.all (fun k => decide (PRE_first_tail_x15_r0_body.cx1_50.mlx.items.get (PRE_first_tail_x15_r0_body.kappa50.node k) = (PRE_first_tail_x15_r0_body.cx0_50.mlx.items.get k).map PRE_first_tail_x15_r0_body.kappa50.nv)) = true
/-- **The compaction's footprint.** -/
theorem PRE_first_tail_x15_r0_body.cfoot50 (clean : Conv.NClean (⟨19183, 16270, 2713907, 2191⟩ : Conv.Cnt) (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s488.ffi).mlx) (hltC : ∀ h, PH (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s488.ffi).mlx h → h < (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s488.ffi).mlx.next) (nltC : ∀ i, PN (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s488.ffi).mlx i → i < (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s488.ffi).mlx.nnext) (itemsC : ∀ k v, (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s488.ffi).mlx.items.get k = some v → PN (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s488.ffi).mlx k) (tracedC : ∀ h o, (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s488.ffi).mlx.objs.get h = some o → ∀ i ∈ objTraces o, i < PRE_first_tail_x15_r0_body.P50.NL) (cl : SSt (· < 2191) PRE_first_tail_x15_r0_body.cx0_50.mlx) :
    Conv.MFoot PRE_first_tail_x15_r0_body.P50 2191 PRE_first_tail_x15_r0_body.kappa50 PRE_first_tail_x15_r0_body.kd50 PRE_first_tail_x15_r0_body.khinv50 PRE_first_tail_x15_r0_body.kninv50 (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s488.ffi).mlx PRE_first_tail_x15_r0_body.cx0_50.mlx PRE_first_tail_x15_r0_body.cx1_50.mlx (⟨19183, 16270, 2713907, 2191⟩ : Conv.Cnt) PRE_first_tail_x15_r0_body.clo50 PRE_first_tail_x15_r0_body.cln50 PRE_first_tail_x15_r0_body.cli50 PRE_first_tail_x15_r0_body.cwS50 PRE_first_tail_x15_r0_body.cnS50 PRE_first_tail_x15_r0_body.ciS50 :=
  ⟨rfl, rfl, rfl, PRE_first_tail_x15_r0_body.cnh050, PRE_first_tail_x15_r0_body.cnh150, PRE_first_tail_x15_r0_body.cnn050, PRE_first_tail_x15_r0_body.cnn150, PRE_first_tail_x15_r0_body.cplo50, PRE_first_tail_x15_r0_body.ccnt50, PRE_first_tail_x15_r0_body.cnband50, PRE_first_tail_x15_r0_body.chbelow50, PRE_first_tail_x15_r0_body.chren50, PRE_first_tail_x15_r0_body.cband50, PRE_first_tail_x15_r0_body.cnh1pos50, PRE_first_tail_x15_r0_body.cnren50, PRE_first_tail_x15_r0_body.cnlow50, PRE_first_tail_x15_r0_body.cabs0a50, PRE_first_tail_x15_r0_body.cabs0b50, PRE_first_tail_x15_r0_body.ctok150, PRE_first_tail_x15_r0_body.cpend50, PRE_first_tail_x15_r0_body.cerrh50, PRE_first_tail_x15_r0_body.cfiles50, PRE_first_tail_x15_r0_body.carch50, PRE_first_tail_x15_r0_body.csizes50, PRE_first_tail_x15_r0_body.cwired50, PRE_first_tail_x15_r0_body.cfix50, clean, PRE_first_tail_x15_r0_body.fcxn50, PRE_first_tail_x15_r0_body.fcnn50, hltC, nltC, itemsC, tracedC, cl, PRE_first_tail_x15_r0_body.fle050, PRE_first_tail_x15_r0_body.fnk50, PRE_first_tail_x15_r0_body.ckA50, PRE_first_tail_x15_r0_body.cobjsK50, PRE_first_tail_x15_r0_body.cnodesK50, PRE_first_tail_x15_r0_body.citemsK50, PRE_first_tail_x15_r0_body.f1A50, PRE_first_tail_x15_r0_body.f1O50, PRE_first_tail_x15_r0_body.f1N50, PRE_first_tail_x15_r0_body.f1I50, PRE_first_tail_x15_r0_body.fbd50, PRE_first_tail_x15_r0_body.fincW50, PRE_first_tail_x15_r0_body.fincI50, PRE_first_tail_x15_r0_body.fincN50, PRE_first_tail_x15_r0_body.flnF50, PRE_first_tail_x15_r0_body.fh50, PRE_first_tail_x15_r0_body.fo50, PRE_first_tail_x15_r0_body.fok50, PRE_first_tail_x15_r0_body.fnd50, PRE_first_tail_x15_r0_body.fp50, PRE_first_tail_x15_r0_body.fnord50, PRE_first_tail_x15_r0_body.fi50, PRE_first_tail_x15_r0_body.fii50⟩
theorem PRE_first_tail_x15_r0_body.cnshift50 (clean : Conv.NClean (⟨19183, 16270, 2713907, 2191⟩ : Conv.Cnt) (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s488.ffi).mlx) (hltC : ∀ h, PH (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s488.ffi).mlx h → h < (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s488.ffi).mlx.next) (nltC : ∀ i, PN (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s488.ffi).mlx i → i < (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s488.ffi).mlx.nnext) (itemsC : ∀ k v, (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s488.ffi).mlx.items.get k = some v → PN (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s488.ffi).mlx k) (tracedC : ∀ h o, (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s488.ffi).mlx.objs.get h = some o → ∀ i ∈ objTraces o, i < PRE_first_tail_x15_r0_body.P50.NL) (cl : SSt (· < 2191) PRE_first_tail_x15_r0_body.cx0_50.mlx) : NShift PRE_first_tail_x15_r0_body.P50 2191 PRE_first_tail_x15_r0_body.kappa50 PRE_first_tail_x15_r0_body.cx0_50 PRE_first_tail_x15_r0_body.cx1_50 :=
  Conv.nshift_of_foot (PRE_first_tail_x15_r0_body.cfoot50 clean hltC nltC itemsC tracedC cl) PRE_first_tail_x15_r0_body.chost50 (compact_a_eq PRE_first_tail_x15_r0_body.ckn050 PRE_first_tail_x15_r0_body.ckn150 PRE_first_tail_x15_r0_body.ckheap50 PRE_first_tail_x15_r0_body.ckpl50)

-- the observers: the layers' states at the call, the canonical and the merged state, their footprints and checks
noncomputable def PRE_first_tail_x15_r0_body.fxC_50 : PTrie Unit := (Host.Ts.Sim.Full.freedOf PRE_first_tail_x15_r0_body.s488.ffi).getD PTrie.nil
noncomputable def PRE_first_tail_x15_r0_body.krC_50 : Host.Load.Layers.KRec := (Host.Ts.Sim.Full.krecOf PRE_first_tail_x15_r0_body.s488.ffi).getD Host.Load.Layers.KRec.empty
kernel_rfl PRE_first_tail_x15_r0_body.ofxC_50 : (Host.Ts.Sim.Full.freedOf PRE_first_tail_x15_r0_body.s488.ffi) = some PRE_first_tail_x15_r0_body.fxC_50
kernel_rfl PRE_first_tail_x15_r0_body.okrC_50 : (Host.Ts.Sim.Full.krecOf PRE_first_tail_x15_r0_body.s488.ffi) = some PRE_first_tail_x15_r0_body.krC_50
noncomputable def PRE_first_tail_x15_r0_body.fx0_50 : PTrie Unit := (Host.Ts.Sim.Full.freedOf PRE_first_tail_x15_r0_body.s490.ffi).getD PTrie.nil
noncomputable def PRE_first_tail_x15_r0_body.kr0_50 : Host.Load.Layers.KRec := (Host.Ts.Sim.Full.krecOf PRE_first_tail_x15_r0_body.s490.ffi).getD Host.Load.Layers.KRec.empty
kernel_rfl PRE_first_tail_x15_r0_body.ofx0_50 : (Host.Ts.Sim.Full.freedOf PRE_first_tail_x15_r0_body.s490.ffi) = some PRE_first_tail_x15_r0_body.fx0_50
kernel_rfl PRE_first_tail_x15_r0_body.okr0_50 : (Host.Ts.Sim.Full.krecOf PRE_first_tail_x15_r0_body.s490.ffi) = some PRE_first_tail_x15_r0_body.kr0_50
noncomputable def PRE_first_tail_x15_r0_body.fx1_50 : PTrie Unit := (Host.Ts.Sim.Full.freedOf PRE_first_tail_x15_r0_body.s489.ffi).getD PTrie.nil
noncomputable def PRE_first_tail_x15_r0_body.kr1_50 : Host.Load.Layers.KRec := (Host.Ts.Sim.Full.krecOf PRE_first_tail_x15_r0_body.s489.ffi).getD Host.Load.Layers.KRec.empty
kernel_rfl PRE_first_tail_x15_r0_body.ofx1_50 : (Host.Ts.Sim.Full.freedOf PRE_first_tail_x15_r0_body.s489.ffi) = some PRE_first_tail_x15_r0_body.fx1_50
kernel_rfl PRE_first_tail_x15_r0_body.okr1_50 : (Host.Ts.Sim.Full.krecOf PRE_first_tail_x15_r0_body.s489.ffi) = some PRE_first_tail_x15_r0_body.kr1_50
kernel_rfl PRE_first_tail_x15_r0_body.ff050 : PRE_first_tail_x15_r0_body.fx0_50 = Stage.setAll PRE_first_tail_x15_r0_body.fxC_50 (PRE_first_tail_x15_r0_body.clo50.filterMap fun i => (PRE_first_tail_x15_r0_body.fx0_50.get i).map (i, ·))
kernel_rfl PRE_first_tail_x15_r0_body.ff150 : PRE_first_tail_x15_r0_body.fx1_50 = Stage.setAll PRE_first_tail_x15_r0_body.fxC_50 (PRE_first_tail_x15_r0_body.cwS50.filterMap fun i => (PRE_first_tail_x15_r0_body.fx1_50.get i).map (i, ·))
kernel_rfl PRE_first_tail_x15_r0_body.ffck50 : freedLB PRE_first_tail_x15_r0_body.kappa50 PRE_first_tail_x15_r0_body.cx0_50.mlx PRE_first_tail_x15_r0_body.fx0_50 PRE_first_tail_x15_r0_body.fx1_50 PRE_first_tail_x15_r0_body.clo50 = true
kernel_rfl PRE_first_tail_x15_r0_body.fkf050 : PRE_first_tail_x15_r0_body.kr0_50.flags = Stage.setAll PRE_first_tail_x15_r0_body.krC_50.flags (PRE_first_tail_x15_r0_body.clo50.filterMap fun i => (PRE_first_tail_x15_r0_body.kr0_50.flags.get i).map (i, ·))
kernel_rfl PRE_first_tail_x15_r0_body.fkt050 : PRE_first_tail_x15_r0_body.kr0_50.targs = Stage.setAll PRE_first_tail_x15_r0_body.krC_50.targs (PRE_first_tail_x15_r0_body.clo50.filterMap fun i => (PRE_first_tail_x15_r0_body.kr0_50.targs.get i).map (i, ·))
kernel_rfl PRE_first_tail_x15_r0_body.fkf150 : PRE_first_tail_x15_r0_body.kr1_50.flags = Stage.setAll PRE_first_tail_x15_r0_body.krC_50.flags (PRE_first_tail_x15_r0_body.cwS50.filterMap fun i => (PRE_first_tail_x15_r0_body.kr1_50.flags.get i).map (i, ·))
kernel_rfl PRE_first_tail_x15_r0_body.fkt150 : PRE_first_tail_x15_r0_body.kr1_50.targs = Stage.setAll PRE_first_tail_x15_r0_body.krC_50.targs (PRE_first_tail_x15_r0_body.cwS50.filterMap fun i => (PRE_first_tail_x15_r0_body.kr1_50.targs.get i).map (i, ·))
kernel_rfl PRE_first_tail_x15_r0_body.fkck50 : krecLB PRE_first_tail_x15_r0_body.kappa50 2191 PRE_first_tail_x15_r0_body.cx0_50.mlx PRE_first_tail_x15_r0_body.kr0_50 PRE_first_tail_x15_r0_body.kr1_50 PRE_first_tail_x15_r0_body.clo50 = true
kernel_rfl PRE_first_tail_x15_r0_body.fkn50 : Nat.ble 2191 2191 = true
-- the bridge and the pending traces' regions
kernel_rfl PRE_first_tail_x15_r0_body.cbridge50 : Host.Ts.Sim.Full.bridgeOf PRE_first_tail_x15_r0_body.s489.ffi = Host.Ts.Sim.Full.bridgeOf PRE_first_tail_x15_r0_body.s490.ffi
kernel_rfl PRE_first_tail_x15_r0_body.cpendR50 : pendRegB PRE_first_tail_x15_r0_body.kappa50 (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s490.ffi).mlx = true
kernel_rfl PRE_first_tail_x15_r0_body.cpendLe50 : Nat.ble (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s490.ffi).mlx.next (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s489.ffi).mlx.next = true
/-- **The compaction's native shift**, given the call's bookkeeping, its relation's facts (the model's and the
observers') and the canonical closedness. -/
theorem PRE_first_tail_x15_r0_body.cshift50 (clean : Conv.NClean (⟨19183, 16270, 2713907, 2191⟩ : Conv.Cnt) (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s488.ffi).mlx) (hltC : ∀ h, PH (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s488.ffi).mlx h → h < (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s488.ffi).mlx.next) (nltC : ∀ i, PN (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s488.ffi).mlx i → i < (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s488.ffi).mlx.nnext) (itemsC : ∀ k v, (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s488.ffi).mlx.items.get k = some v → PN (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s488.ffi).mlx k) (tracedC : ∀ h o, (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s488.ffi).mlx.objs.get h = some o → ∀ i ∈ objTraces o, i < PRE_first_tail_x15_r0_body.P50.NL) (cl : SSt (· < 2191) PRE_first_tail_x15_r0_body.cx0_50.mlx)
    (hobjC : ∀ h, PRE_first_tail_x15_r0_body.fxC_50.get h = some () → ((Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s488.ffi).mlx.objs.get h).isSome = true)
    (hfC : ∀ h, (PRE_first_tail_x15_r0_body.krC_50.flags.get h).isSome = true → ((Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s488.ffi).mlx.objs.get h).isSome = true)
    (htC : ∀ h, (PRE_first_tail_x15_r0_body.krC_50.targs.get h).isSome = true → ((Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s488.ffi).mlx.objs.get h).isSome = true)
    (hclC : ∀ h l, PRE_first_tail_x15_r0_body.krC_50.targs.get h = some l → Host.Ts.Sim.Full.STargs (· < (⟨19183, 16270, 2713907, 2191⟩ : Conv.Cnt).n) l) :
    Conv.FullShiftQ PRE_first_tail_x15_r0_body.P50 2191 PRE_first_tail_x15_r0_body.kappa50 PRE_first_tail_x15_r0_body.s490.ffi PRE_first_tail_x15_r0_body.s489.ffi :=
  ⟨PRE_first_tail_x15_r0_body.cnshift50 clean hltC nltC itemsC tracedC cl, PRE_first_tail_x15_r0_body.cqueue50, fun t ht => bSN_sound (List.all_eq_true.mp PRE_first_tail_x15_r0_body.ctokSupp50 t ht),
    PRE_first_tail_x15_r0_body.cbridge50,
    liveShift_foot (x0' := Host.Ts.Sim.Full.mlxOf PRE_first_tail_x15_r0_body.s490.ffi) (x1' := Host.Ts.Sim.Full.mlxOf PRE_first_tail_x15_r0_body.s489.ffi) (PRE_first_tail_x15_r0_body.cfoot50 clean hltC nltC itemsC tracedC cl) rfl PRE_first_tail_x15_r0_body.ofx0_50 PRE_first_tail_x15_r0_body.ofx1_50 hobjC PRE_first_tail_x15_r0_body.ff050 PRE_first_tail_x15_r0_body.ff150 PRE_first_tail_x15_r0_body.ffck50,
    kernShift_foot (x0' := Host.Ts.Sim.Full.mlxOf PRE_first_tail_x15_r0_body.s490.ffi) (x1' := Host.Ts.Sim.Full.mlxOf PRE_first_tail_x15_r0_body.s489.ffi) (PRE_first_tail_x15_r0_body.cfoot50 clean hltC nltC itemsC tracedC cl) rfl PRE_first_tail_x15_r0_body.okr0_50 PRE_first_tail_x15_r0_body.okr1_50 (Nat.le_of_ble_eq_true PRE_first_tail_x15_r0_body.fkn50) hfC htC hclC
      PRE_first_tail_x15_r0_body.fkf050 PRE_first_tail_x15_r0_body.fkt050 PRE_first_tail_x15_r0_body.fkf150 PRE_first_tail_x15_r0_body.fkt150 PRE_first_tail_x15_r0_body.fkck50,
    pendReg_of rfl PRE_first_tail_x15_r0_body.cnh050 PRE_first_tail_x15_r0_body.cnh150 (Nat.le_of_ble_eq_true PRE_first_tail_x15_r0_body.cpendLe50) PRE_first_tail_x15_r0_body.cpendR50⟩

end Host.Load.Run.Tpl
