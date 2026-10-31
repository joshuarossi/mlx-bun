import host.sim.template.a4pre_first_tail_x15_r0_body.SiteCl94
import host.sim.conv.CompactFull
import host.sim.template.FootGen
set_option Elab.async false
namespace Host.Load.Run.Tpl
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
open Host.Ts Host.Ts.Sim Host.Ts.Sim.Template

/-! The compaction's native shift at call site 94 from its footprint (`Conv.nshift_of_foot`), and the observers'
(`liveShift_foot`, `kernShift_foot`): `Conv.FullShiftQ` for `Conv.full_compactQ`, given the call's bookkeeping and its
relation's facts. -/

/-- The load parameters of the chain (band-free: its start's node counter as `NL` and `N0`). -/
def PRE_first_tail_x15_r0_body.Pc94 : LoadP := ⟨18151, 131072, 1099511627776, 15235, 15235, []⟩
/-- The site's band raised to the map's checked fixed-node prefix, including newly recorded closure traces. -/
def PRE_first_tail_x15_r0_body.P94 : LoadP := PRE_first_tail_x15_r0_body.Pc94.raise 17151
kernel_rfl PRE_first_tail_x15_r0_body.craise94 : Nat.ble PRE_first_tail_x15_r0_body.Pc94.N0 17151 = true
theorem PRE_first_tail_x15_r0_body.raised94 : Host.Ts.Sim.Full.Raised PRE_first_tail_x15_r0_body.Pc94 PRE_first_tail_x15_r0_body.P94 :=
  .inr ⟨17151, rfl, Nat.le_of_ble_eq_true PRE_first_tail_x15_r0_body.craise94, rfl⟩
noncomputable abbrev PRE_first_tail_x15_r0_body.cx0_94 : Host.Load.LSt := clearTokens (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s917.ffi)
noncomputable abbrev PRE_first_tail_x15_r0_body.cx1_94 : Host.Load.LSt := clearTokens (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s916.ffi)
def PRE_first_tail_x15_r0_body.khinv94 : PTrie Nat := Stage.setAll PTrie.nil []
def PRE_first_tail_x15_r0_body.kninv94 : PTrie Nat := Stage.setAll PTrie.nil []
/-- The stage's footprint: its written and fresh handles, fresh nodes, written and fresh items. -/
def PRE_first_tail_x15_r0_body.cwS94 : List Nat := []
def PRE_first_tail_x15_r0_body.cnS94 : List Nat := List.range' 17151 0
def PRE_first_tail_x15_r0_body.ciS94 : List Nat := [] ++ List.range' 17151 0

-- the small checks (`MChecks`'s)
kernel_rfl PRE_first_tail_x15_r0_body.cnh094 : PRE_first_tail_x15_r0_body.kd94.nh0 = PRE_first_tail_x15_r0_body.cx0_94.mlx.next
kernel_rfl PRE_first_tail_x15_r0_body.cnh194 : PRE_first_tail_x15_r0_body.kd94.nh1 = PRE_first_tail_x15_r0_body.cx1_94.mlx.next
kernel_rfl PRE_first_tail_x15_r0_body.cnn094 : PRE_first_tail_x15_r0_body.kd94.nn0 = PRE_first_tail_x15_r0_body.cx0_94.mlx.nnext
kernel_rfl PRE_first_tail_x15_r0_body.cnn194 : PRE_first_tail_x15_r0_body.kd94.nn1 = PRE_first_tail_x15_r0_body.cx1_94.mlx.nnext
kernel_rfl PRE_first_tail_x15_r0_body.cplo94 : (Nat.blt 0 PRE_first_tail_x15_r0_body.P94.lo && Nat.ble PRE_first_tail_x15_r0_body.P94.lo PRE_first_tail_x15_r0_body.cx0_94.mlx.next && Nat.ble PRE_first_tail_x15_r0_body.P94.lo RData.bigHi && Nat.ble RData.bigHi PRE_first_tail_x15_r0_body.P94.E) = true
kernel_rfl PRE_first_tail_x15_r0_body.ccnt94 : (Nat.ble PRE_first_tail_x15_r0_body.cx0_94.mlx.next PRE_first_tail_x15_r0_body.cx1_94.mlx.next && Nat.ble PRE_first_tail_x15_r0_body.cx0_94.mlx.nnext PRE_first_tail_x15_r0_body.cx1_94.mlx.nnext) = true
kernel_rfl PRE_first_tail_x15_r0_body.cnband94 : (Nat.blt 0 PRE_first_tail_x15_r0_body.P94.NL && Nat.ble PRE_first_tail_x15_r0_body.P94.NL PRE_first_tail_x15_r0_body.P94.N0 && Nat.ble PRE_first_tail_x15_r0_body.P94.N0 PRE_first_tail_x15_r0_body.cx0_94.mlx.nnext) = true
kernel_rfl PRE_first_tail_x15_r0_body.chbelow94 : PRE_first_tail_x15_r0_body.kd94.checkHndBelow = true
kernel_rfl PRE_first_tail_x15_r0_body.chren94 : checkRenG PRE_first_tail_x15_r0_body.kd94.hnd PRE_first_tail_x15_r0_body.khinv94 (phB PRE_first_tail_x15_r0_body.cx0_94.mlx) = true
kernel_rfl PRE_first_tail_x15_r0_body.cband94 : PRE_first_tail_x15_r0_body.kd94.checkBand PRE_first_tail_x15_r0_body.P94.lo = true
kernel_rfl PRE_first_tail_x15_r0_body.cnh1pos94 : Nat.blt 0 PRE_first_tail_x15_r0_body.kd94.nh1 = true
kernel_rfl PRE_first_tail_x15_r0_body.cnren94 : checkRenG PRE_first_tail_x15_r0_body.kd94.node PRE_first_tail_x15_r0_body.kninv94 (pnB PRE_first_tail_x15_r0_body.cx0_94.mlx) = true
kernel_rfl PRE_first_tail_x15_r0_body.cnlow94 : (PTrie.keysA PRE_first_tail_x15_r0_body.kd94.node).all (fun j => Nat.ble PRE_first_tail_x15_r0_body.P94.NL j && Nat.blt (PRE_first_tail_x15_r0_body.kd94.nodeF j) PRE_first_tail_x15_r0_body.cx1_94.mlx.nnext) = true
kernel_rfl PRE_first_tail_x15_r0_body.cabs0a94 : PRE_first_tail_x15_r0_body.cx0_94.mlx.arrs.get 0 = none
kernel_rfl PRE_first_tail_x15_r0_body.cabs0b94 : PRE_first_tail_x15_r0_body.cx0_94.mlx.objs.get 0 = none
kernel_rfl PRE_first_tail_x15_r0_body.ctok194 : PRE_first_tail_x15_r0_body.cx1_94.mlx.tokens = []
kernel_rfl PRE_first_tail_x15_r0_body.cpend94 : PRE_first_tail_x15_r0_body.cx1_94.mlx.pending = PRE_first_tail_x15_r0_body.cx0_94.mlx.pending.map PRE_first_tail_x15_r0_body.kappa94.pend
kernel_rfl PRE_first_tail_x15_r0_body.cerrh94 : PRE_first_tail_x15_r0_body.cx1_94.mlx.errh = PRE_first_tail_x15_r0_body.cx0_94.mlx.errh.map PRE_first_tail_x15_r0_body.kappa94.arg
kernel_rfl PRE_first_tail_x15_r0_body.cfiles94 : PRE_first_tail_x15_r0_body.cx1_94.mlx.files = PRE_first_tail_x15_r0_body.cx0_94.mlx.files
kernel_rfl PRE_first_tail_x15_r0_body.carch94 : PRE_first_tail_x15_r0_body.cx1_94.mlx.arch = PRE_first_tail_x15_r0_body.cx0_94.mlx.arch
kernel_rfl PRE_first_tail_x15_r0_body.csizes94 : PRE_first_tail_x15_r0_body.cx1_94.mlx.deviceSizes = PRE_first_tail_x15_r0_body.cx0_94.mlx.deviceSizes
kernel_rfl PRE_first_tail_x15_r0_body.cwired94 : PRE_first_tail_x15_r0_body.cx1_94.mlx.wired = PRE_first_tail_x15_r0_body.cx0_94.mlx.wired
kernel_rfl PRE_first_tail_x15_r0_body.chost94 : PRE_first_tail_x15_r0_body.cx1_94.host = PRE_first_tail_x15_r0_body.cx0_94.host
-- the compaction map's addresses are `PRE_first_tail_x15_r0_body.kd94`'s
kernel_rfl PRE_first_tail_x15_r0_body.ckn094 : PRE_first_tail_x15_r0_body.kd94.n0 = 2749005
kernel_rfl PRE_first_tail_x15_r0_body.ckn194 : PRE_first_tail_x15_r0_body.kd94.n1 = 2749007
kernel_rfl PRE_first_tail_x15_r0_body.ckheap94 : (PTrie.keysA PRE_first_tail_x15_r0_body.kd94.heap).all (fun x => Nat.ble 2749005 x) = true
kernel_rfl PRE_first_tail_x15_r0_body.ckpl94 : (List.range 0).all (fun j => decide (PRE_first_tail_x15_r0_body.kd94.heap.get (2749005 + j) = nth? PRE_first_tail_x15_r0_body.pl94 j)) = true
-- the map fixes the call's names (`Conv.fixOld_compact`), the call's counters
kernel_rfl PRE_first_tail_x15_r0_body.fja94 : Nat.ble 2749005 2749005 = true
kernel_rfl PRE_first_tail_x15_r0_body.fn94 : Nat.ble 4097 4097 = true
kernel_rfl PRE_first_tail_x15_r0_body.fjaD94 : Nat.ble 2749005 PRE_first_tail_x15_r0_body.kd94.n0 = true
kernel_rfl PRE_first_tail_x15_r0_body.fxn94 : Nat.ble 20062 PRE_first_tail_x15_r0_body.kd94.nh0 = true
kernel_rfl PRE_first_tail_x15_r0_body.fnn94 : Nat.ble 17151 PRE_first_tail_x15_r0_body.kd94.nn0 = true
kernel_rfl PRE_first_tail_x15_r0_body.fxb94 : Nat.ble 20062 RData.bigHi = true
kernel_rfl PRE_first_tail_x15_r0_body.fheap94 : (PTrie.keysA PRE_first_tail_x15_r0_body.kd94.heap).all (Nat.ble (⟨20062, 17151, 2749005, 4097⟩ : Conv.Cnt).ja) = true
kernel_rfl PRE_first_tail_x15_r0_body.fhnd94 : (PTrie.keysA PRE_first_tail_x15_r0_body.kd94.hnd).all (Nat.ble (⟨20062, 17151, 2749005, 4097⟩ : Conv.Cnt).xn) = true
kernel_rfl PRE_first_tail_x15_r0_body.fnode94 : (PTrie.keysA PRE_first_tail_x15_r0_body.kd94.node).all (Nat.ble (⟨20062, 17151, 2749005, 4097⟩ : Conv.Cnt).nn) = true
/-- The compaction map fixes the call's names. -/
theorem PRE_first_tail_x15_r0_body.cfix94 : Conv.FixOld (⟨20062, 17151, 2749005, 4097⟩ : Conv.Cnt) PRE_first_tail_x15_r0_body.kappa94 :=
  Conv.fixOld_compact (Nat.le_of_ble_eq_true PRE_first_tail_x15_r0_body.fja94) (Nat.le_of_ble_eq_true PRE_first_tail_x15_r0_body.fn94) (Nat.le_of_ble_eq_true PRE_first_tail_x15_r0_body.fjaD94) (Nat.le_of_ble_eq_true PRE_first_tail_x15_r0_body.fxn94) (Nat.le_of_ble_eq_true PRE_first_tail_x15_r0_body.fnn94) (Nat.le_of_ble_eq_true PRE_first_tail_x15_r0_body.fxb94) PRE_first_tail_x15_r0_body.fheap94 PRE_first_tail_x15_r0_body.fhnd94 PRE_first_tail_x15_r0_body.fnode94
kernel_rfl PRE_first_tail_x15_r0_body.fcxn94 : (⟨20062, 17151, 2749005, 4097⟩ : Conv.Cnt).xn = (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s915.ffi).mlx.next
kernel_rfl PRE_first_tail_x15_r0_body.fcnn94 : (⟨20062, 17151, 2749005, 4097⟩ : Conv.Cnt).nn = (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s915.ffi).mlx.nnext
kernel_rfl PRE_first_tail_x15_r0_body.fle094 : (Nat.ble (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s915.ffi).mlx.next PRE_first_tail_x15_r0_body.cx0_94.mlx.next && Nat.ble (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s915.ffi).mlx.nnext PRE_first_tail_x15_r0_body.cx0_94.mlx.nnext && Nat.ble (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s915.ffi).mlx.next RData.bigHi) = true
kernel_rfl PRE_first_tail_x15_r0_body.fnk94 : (PTrie.keysA PRE_first_tail_x15_r0_body.kd94.node).all (Nat.ble (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s915.ffi).mlx.nnext) = true
-- the merged state keeps the call's entries off the stage's footprint
kernel_rfl PRE_first_tail_x15_r0_body.f1A94 : PRE_first_tail_x15_r0_body.cx1_94.mlx.arrs = Stage.setAll (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s915.ffi).mlx.arrs (PRE_first_tail_x15_r0_body.cwS94.filterMap fun i => (PRE_first_tail_x15_r0_body.cx1_94.mlx.arrs.get i).map (i, ·))
kernel_rfl PRE_first_tail_x15_r0_body.f1O94 : PRE_first_tail_x15_r0_body.cx1_94.mlx.objs = Stage.setAll (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s915.ffi).mlx.objs (PRE_first_tail_x15_r0_body.cwS94.filterMap fun i => (PRE_first_tail_x15_r0_body.cx1_94.mlx.objs.get i).map (i, ·))
kernel_rfl PRE_first_tail_x15_r0_body.f1N94 : PRE_first_tail_x15_r0_body.cx1_94.mlx.nodes = Stage.setAll (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s915.ffi).mlx.nodes (PRE_first_tail_x15_r0_body.cnS94.filterMap fun i => (PRE_first_tail_x15_r0_body.cx1_94.mlx.nodes.get i).map (i, ·))
kernel_rfl PRE_first_tail_x15_r0_body.f1I94 : PRE_first_tail_x15_r0_body.cx1_94.mlx.items = Stage.setAll (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s915.ffi).mlx.items (PRE_first_tail_x15_r0_body.ciS94.filterMap fun i => (PRE_first_tail_x15_r0_body.cx1_94.mlx.items.get i).map (i, ·))
kernel_rfl PRE_first_tail_x15_r0_body.fbd94 : (PRE_first_tail_x15_r0_body.clo94 ++ PRE_first_tail_x15_r0_body.cln94 ++ PRE_first_tail_x15_r0_body.cli94 ++ PRE_first_tail_x15_r0_body.cwS94 ++ PRE_first_tail_x15_r0_body.cnS94 ++ PRE_first_tail_x15_r0_body.ciS94).all (fun i => Nat.blt (i / 4096) (4 ^ 31)) = true
kernel_rfl PRE_first_tail_x15_r0_body.fincW94 : PRE_first_tail_x15_r0_body.cwS94.all (fun h => !Nat.blt h (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s915.ffi).mlx.next || PRE_first_tail_x15_r0_body.clo94.contains h) = true
kernel_rfl PRE_first_tail_x15_r0_body.fincI94 : PRE_first_tail_x15_r0_body.ciS94.all (fun k => !Nat.blt k (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s915.ffi).mlx.nnext || PRE_first_tail_x15_r0_body.cli94.contains k) = true
kernel_rfl PRE_first_tail_x15_r0_body.fincN94 : PRE_first_tail_x15_r0_body.cnS94.all (Nat.ble (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s915.ffi).mlx.nnext) = true
kernel_rfl PRE_first_tail_x15_r0_body.flnF94 : PRE_first_tail_x15_r0_body.cln94.all (Nat.ble (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s915.ffi).mlx.nnext) = true
-- the checks over the changed lists
kernel_rfl PRE_first_tail_x15_r0_body.fh94 : PRE_first_tail_x15_r0_body.clo94.all (handleOK PRE_first_tail_x15_r0_body.kappa94 PRE_first_tail_x15_r0_body.P94.lo PRE_first_tail_x15_r0_body.cx0_94.mlx PRE_first_tail_x15_r0_body.cx1_94.mlx) = true
kernel_rfl PRE_first_tail_x15_r0_body.fo94 : PRE_first_tail_x15_r0_body.clo94.map (fun h => PRE_first_tail_x15_r0_body.cx1_94.mlx.objs.get (PRE_first_tail_x15_r0_body.kappa94.handle h)) = PRE_first_tail_x15_r0_body.clo94.map (fun h => (PRE_first_tail_x15_r0_body.cx0_94.mlx.objs.get h).map PRE_first_tail_x15_r0_body.kappa94.nobj)
kernel_rfl PRE_first_tail_x15_r0_body.fok94 : PRE_first_tail_x15_r0_body.clo94.all (objOK PRE_first_tail_x15_r0_body.kappa94 PRE_first_tail_x15_r0_body.P94.NL PRE_first_tail_x15_r0_body.cx0_94.mlx) = true
kernel_rfl PRE_first_tail_x15_r0_body.fnd94 : PRE_first_tail_x15_r0_body.cln94.all (nodeOKF PRE_first_tail_x15_r0_body.kappa94 PRE_first_tail_x15_r0_body.P94 PRE_first_tail_x15_r0_body.cx0_94.mlx PRE_first_tail_x15_r0_body.cx1_94.mlx) = true
kernel_rfl PRE_first_tail_x15_r0_body.fp94 : ((PRE_first_tail_x15_r0_body.cln94.filter (fullB PRE_first_tail_x15_r0_body.P94))).map (fun i => (PRE_first_tail_x15_r0_body.cx1_94.mlx.nodes.get (PRE_first_tail_x15_r0_body.kappa94.node i)).map Host.Mlx.Ffi.Node.prim) =
  ((PRE_first_tail_x15_r0_body.cln94.filter (fullB PRE_first_tail_x15_r0_body.P94))).map (fun i => (PRE_first_tail_x15_r0_body.cx0_94.mlx.nodes.get i).map fun nd => PRE_first_tail_x15_r0_body.kappa94.prim nd.prim)
kernel_rfl PRE_first_tail_x15_r0_body.fnordI94 : incrB PRE_first_tail_x15_r0_body.kd94.nodeF (List.range' 17151 0) = true
kernel_rfl PRE_first_tail_x15_r0_body.fnordK94 : (PTrie.keysA PRE_first_tail_x15_r0_body.kd94.node).all (fun k => Nat.ble 17151 k && Nat.blt k 17151) = true
kernel_rfl PRE_first_tail_x15_r0_body.fnordL94 : (PRE_first_tail_x15_r0_body.cln94.filter (Nat.ble PRE_first_tail_x15_r0_body.P94.N0)).all (fun i => Nat.ble i (PRE_first_tail_x15_r0_body.kd94.nodeF i) && (Nat.blt i 17151 || Nat.ble PRE_first_tail_x15_r0_body.kd94.nn0 i)) = true
theorem PRE_first_tail_x15_r0_body.fnord94 : (PRE_first_tail_x15_r0_body.cln94.filter (Nat.ble PRE_first_tail_x15_r0_body.P94.N0)).all (fun i => Nat.ble i (PRE_first_tail_x15_r0_body.kd94.nodeF i) &&
    (PTrie.keysA PRE_first_tail_x15_r0_body.kd94.node).all fun j => !Nat.blt j i || Nat.blt (PRE_first_tail_x15_r0_body.kd94.nodeF j) (PRE_first_tail_x15_r0_body.kd94.nodeF i)) = true :=
  cnord_of PRE_first_tail_x15_r0_body.cnlow94 PRE_first_tail_x15_r0_body.cnn194 PRE_first_tail_x15_r0_body.fnordI94 PRE_first_tail_x15_r0_body.fnordK94 PRE_first_tail_x15_r0_body.fnordL94
kernel_rfl PRE_first_tail_x15_r0_body.fi94 : PRE_first_tail_x15_r0_body.cli94.all (pnB PRE_first_tail_x15_r0_body.cx0_94.mlx) = true
kernel_rfl PRE_first_tail_x15_r0_body.fii94 : PRE_first_tail_x15_r0_body.cli94.all (fun k => decide (PRE_first_tail_x15_r0_body.cx1_94.mlx.items.get (PRE_first_tail_x15_r0_body.kappa94.node k) = (PRE_first_tail_x15_r0_body.cx0_94.mlx.items.get k).map PRE_first_tail_x15_r0_body.kappa94.nv)) = true
/-- **The compaction's footprint.** -/
theorem PRE_first_tail_x15_r0_body.cfoot94 (clean : Conv.NClean (⟨20062, 17151, 2749005, 4097⟩ : Conv.Cnt) (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s915.ffi).mlx) (hltC : ∀ h, PH (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s915.ffi).mlx h → h < (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s915.ffi).mlx.next) (nltC : ∀ i, PN (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s915.ffi).mlx i → i < (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s915.ffi).mlx.nnext) (itemsC : ∀ k v, (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s915.ffi).mlx.items.get k = some v → PN (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s915.ffi).mlx k) (tracedC : ∀ h o, (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s915.ffi).mlx.objs.get h = some o → ∀ i ∈ objTraces o, i < PRE_first_tail_x15_r0_body.P94.NL) (cl : SSt (· < 4097) PRE_first_tail_x15_r0_body.cx0_94.mlx) :
    Conv.MFoot PRE_first_tail_x15_r0_body.P94 4097 PRE_first_tail_x15_r0_body.kappa94 PRE_first_tail_x15_r0_body.kd94 PRE_first_tail_x15_r0_body.khinv94 PRE_first_tail_x15_r0_body.kninv94 (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s915.ffi).mlx PRE_first_tail_x15_r0_body.cx0_94.mlx PRE_first_tail_x15_r0_body.cx1_94.mlx (⟨20062, 17151, 2749005, 4097⟩ : Conv.Cnt) PRE_first_tail_x15_r0_body.clo94 PRE_first_tail_x15_r0_body.cln94 PRE_first_tail_x15_r0_body.cli94 PRE_first_tail_x15_r0_body.cwS94 PRE_first_tail_x15_r0_body.cnS94 PRE_first_tail_x15_r0_body.ciS94 :=
  ⟨rfl, rfl, rfl, PRE_first_tail_x15_r0_body.cnh094, PRE_first_tail_x15_r0_body.cnh194, PRE_first_tail_x15_r0_body.cnn094, PRE_first_tail_x15_r0_body.cnn194, PRE_first_tail_x15_r0_body.cplo94, PRE_first_tail_x15_r0_body.ccnt94, PRE_first_tail_x15_r0_body.cnband94, PRE_first_tail_x15_r0_body.chbelow94, PRE_first_tail_x15_r0_body.chren94, PRE_first_tail_x15_r0_body.cband94, PRE_first_tail_x15_r0_body.cnh1pos94, PRE_first_tail_x15_r0_body.cnren94, PRE_first_tail_x15_r0_body.cnlow94, PRE_first_tail_x15_r0_body.cabs0a94, PRE_first_tail_x15_r0_body.cabs0b94, PRE_first_tail_x15_r0_body.ctok194, PRE_first_tail_x15_r0_body.cpend94, PRE_first_tail_x15_r0_body.cerrh94, PRE_first_tail_x15_r0_body.cfiles94, PRE_first_tail_x15_r0_body.carch94, PRE_first_tail_x15_r0_body.csizes94, PRE_first_tail_x15_r0_body.cwired94, PRE_first_tail_x15_r0_body.cfix94, clean, PRE_first_tail_x15_r0_body.fcxn94, PRE_first_tail_x15_r0_body.fcnn94, hltC, nltC, itemsC, tracedC, cl, PRE_first_tail_x15_r0_body.fle094, PRE_first_tail_x15_r0_body.fnk94, PRE_first_tail_x15_r0_body.ckA94, PRE_first_tail_x15_r0_body.cobjsK94, PRE_first_tail_x15_r0_body.cnodesK94, PRE_first_tail_x15_r0_body.citemsK94, PRE_first_tail_x15_r0_body.f1A94, PRE_first_tail_x15_r0_body.f1O94, PRE_first_tail_x15_r0_body.f1N94, PRE_first_tail_x15_r0_body.f1I94, PRE_first_tail_x15_r0_body.fbd94, PRE_first_tail_x15_r0_body.fincW94, PRE_first_tail_x15_r0_body.fincI94, PRE_first_tail_x15_r0_body.fincN94, PRE_first_tail_x15_r0_body.flnF94, PRE_first_tail_x15_r0_body.fh94, PRE_first_tail_x15_r0_body.fo94, PRE_first_tail_x15_r0_body.fok94, PRE_first_tail_x15_r0_body.fnd94, PRE_first_tail_x15_r0_body.fp94, PRE_first_tail_x15_r0_body.fnord94, PRE_first_tail_x15_r0_body.fi94, PRE_first_tail_x15_r0_body.fii94⟩
theorem PRE_first_tail_x15_r0_body.cnshift94 (clean : Conv.NClean (⟨20062, 17151, 2749005, 4097⟩ : Conv.Cnt) (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s915.ffi).mlx) (hltC : ∀ h, PH (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s915.ffi).mlx h → h < (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s915.ffi).mlx.next) (nltC : ∀ i, PN (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s915.ffi).mlx i → i < (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s915.ffi).mlx.nnext) (itemsC : ∀ k v, (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s915.ffi).mlx.items.get k = some v → PN (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s915.ffi).mlx k) (tracedC : ∀ h o, (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s915.ffi).mlx.objs.get h = some o → ∀ i ∈ objTraces o, i < PRE_first_tail_x15_r0_body.P94.NL) (cl : SSt (· < 4097) PRE_first_tail_x15_r0_body.cx0_94.mlx) : NShift PRE_first_tail_x15_r0_body.P94 4097 PRE_first_tail_x15_r0_body.kappa94 PRE_first_tail_x15_r0_body.cx0_94 PRE_first_tail_x15_r0_body.cx1_94 :=
  Conv.nshift_of_foot (PRE_first_tail_x15_r0_body.cfoot94 clean hltC nltC itemsC tracedC cl) PRE_first_tail_x15_r0_body.chost94 (compact_a_eq PRE_first_tail_x15_r0_body.ckn094 PRE_first_tail_x15_r0_body.ckn194 PRE_first_tail_x15_r0_body.ckheap94 PRE_first_tail_x15_r0_body.ckpl94)

-- the observers: the layers' states at the call, the canonical and the merged state, their footprints and checks
noncomputable def PRE_first_tail_x15_r0_body.fxC_94 : PTrie Unit := (Host.Ts.Sim.Full.freedOf PRE_first_tail_x15_r0_body.s915.ffi).getD PTrie.nil
noncomputable def PRE_first_tail_x15_r0_body.krC_94 : Host.Load.Layers.KRec := (Host.Ts.Sim.Full.krecOf PRE_first_tail_x15_r0_body.s915.ffi).getD Host.Load.Layers.KRec.empty
kernel_rfl PRE_first_tail_x15_r0_body.ofxC_94 : (Host.Ts.Sim.Full.freedOf PRE_first_tail_x15_r0_body.s915.ffi) = some PRE_first_tail_x15_r0_body.fxC_94
kernel_rfl PRE_first_tail_x15_r0_body.okrC_94 : (Host.Ts.Sim.Full.krecOf PRE_first_tail_x15_r0_body.s915.ffi) = some PRE_first_tail_x15_r0_body.krC_94
noncomputable def PRE_first_tail_x15_r0_body.fx0_94 : PTrie Unit := (Host.Ts.Sim.Full.freedOf PRE_first_tail_x15_r0_body.s917.ffi).getD PTrie.nil
noncomputable def PRE_first_tail_x15_r0_body.kr0_94 : Host.Load.Layers.KRec := (Host.Ts.Sim.Full.krecOf PRE_first_tail_x15_r0_body.s917.ffi).getD Host.Load.Layers.KRec.empty
kernel_rfl PRE_first_tail_x15_r0_body.ofx0_94 : (Host.Ts.Sim.Full.freedOf PRE_first_tail_x15_r0_body.s917.ffi) = some PRE_first_tail_x15_r0_body.fx0_94
kernel_rfl PRE_first_tail_x15_r0_body.okr0_94 : (Host.Ts.Sim.Full.krecOf PRE_first_tail_x15_r0_body.s917.ffi) = some PRE_first_tail_x15_r0_body.kr0_94
noncomputable def PRE_first_tail_x15_r0_body.fx1_94 : PTrie Unit := (Host.Ts.Sim.Full.freedOf PRE_first_tail_x15_r0_body.s916.ffi).getD PTrie.nil
noncomputable def PRE_first_tail_x15_r0_body.kr1_94 : Host.Load.Layers.KRec := (Host.Ts.Sim.Full.krecOf PRE_first_tail_x15_r0_body.s916.ffi).getD Host.Load.Layers.KRec.empty
kernel_rfl PRE_first_tail_x15_r0_body.ofx1_94 : (Host.Ts.Sim.Full.freedOf PRE_first_tail_x15_r0_body.s916.ffi) = some PRE_first_tail_x15_r0_body.fx1_94
kernel_rfl PRE_first_tail_x15_r0_body.okr1_94 : (Host.Ts.Sim.Full.krecOf PRE_first_tail_x15_r0_body.s916.ffi) = some PRE_first_tail_x15_r0_body.kr1_94
kernel_rfl PRE_first_tail_x15_r0_body.ff094 : PRE_first_tail_x15_r0_body.fx0_94 = Stage.setAll PRE_first_tail_x15_r0_body.fxC_94 (PRE_first_tail_x15_r0_body.clo94.filterMap fun i => (PRE_first_tail_x15_r0_body.fx0_94.get i).map (i, ·))
kernel_rfl PRE_first_tail_x15_r0_body.ff194 : PRE_first_tail_x15_r0_body.fx1_94 = Stage.setAll PRE_first_tail_x15_r0_body.fxC_94 (PRE_first_tail_x15_r0_body.cwS94.filterMap fun i => (PRE_first_tail_x15_r0_body.fx1_94.get i).map (i, ·))
kernel_rfl PRE_first_tail_x15_r0_body.ffck94 : freedLB PRE_first_tail_x15_r0_body.kappa94 PRE_first_tail_x15_r0_body.cx0_94.mlx PRE_first_tail_x15_r0_body.fx0_94 PRE_first_tail_x15_r0_body.fx1_94 PRE_first_tail_x15_r0_body.clo94 = true
kernel_rfl PRE_first_tail_x15_r0_body.fkf094 : PRE_first_tail_x15_r0_body.kr0_94.flags = Stage.setAll PRE_first_tail_x15_r0_body.krC_94.flags (PRE_first_tail_x15_r0_body.clo94.filterMap fun i => (PRE_first_tail_x15_r0_body.kr0_94.flags.get i).map (i, ·))
kernel_rfl PRE_first_tail_x15_r0_body.fkt094 : PRE_first_tail_x15_r0_body.kr0_94.targs = Stage.setAll PRE_first_tail_x15_r0_body.krC_94.targs (PRE_first_tail_x15_r0_body.clo94.filterMap fun i => (PRE_first_tail_x15_r0_body.kr0_94.targs.get i).map (i, ·))
kernel_rfl PRE_first_tail_x15_r0_body.fkf194 : PRE_first_tail_x15_r0_body.kr1_94.flags = Stage.setAll PRE_first_tail_x15_r0_body.krC_94.flags (PRE_first_tail_x15_r0_body.cwS94.filterMap fun i => (PRE_first_tail_x15_r0_body.kr1_94.flags.get i).map (i, ·))
kernel_rfl PRE_first_tail_x15_r0_body.fkt194 : PRE_first_tail_x15_r0_body.kr1_94.targs = Stage.setAll PRE_first_tail_x15_r0_body.krC_94.targs (PRE_first_tail_x15_r0_body.cwS94.filterMap fun i => (PRE_first_tail_x15_r0_body.kr1_94.targs.get i).map (i, ·))
kernel_rfl PRE_first_tail_x15_r0_body.fkck94 : krecLB PRE_first_tail_x15_r0_body.kappa94 4097 PRE_first_tail_x15_r0_body.cx0_94.mlx PRE_first_tail_x15_r0_body.kr0_94 PRE_first_tail_x15_r0_body.kr1_94 PRE_first_tail_x15_r0_body.clo94 = true
kernel_rfl PRE_first_tail_x15_r0_body.fkn94 : Nat.ble 4097 4097 = true
-- the bridge and the pending traces' regions
kernel_rfl PRE_first_tail_x15_r0_body.cbridge94 : Host.Ts.Sim.Full.bridgeOf PRE_first_tail_x15_r0_body.s916.ffi = Host.Ts.Sim.Full.bridgeOf PRE_first_tail_x15_r0_body.s917.ffi
kernel_rfl PRE_first_tail_x15_r0_body.cpendR94 : pendRegB PRE_first_tail_x15_r0_body.kappa94 (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s917.ffi).mlx = true
kernel_rfl PRE_first_tail_x15_r0_body.cpendLe94 : Nat.ble (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s917.ffi).mlx.next (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s916.ffi).mlx.next = true
/-- **The compaction's native shift**, given the call's bookkeeping, its relation's facts (the model's and the
observers') and the canonical closedness. -/
theorem PRE_first_tail_x15_r0_body.cshift94 (clean : Conv.NClean (⟨20062, 17151, 2749005, 4097⟩ : Conv.Cnt) (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s915.ffi).mlx) (hltC : ∀ h, PH (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s915.ffi).mlx h → h < (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s915.ffi).mlx.next) (nltC : ∀ i, PN (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s915.ffi).mlx i → i < (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s915.ffi).mlx.nnext) (itemsC : ∀ k v, (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s915.ffi).mlx.items.get k = some v → PN (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s915.ffi).mlx k) (tracedC : ∀ h o, (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s915.ffi).mlx.objs.get h = some o → ∀ i ∈ objTraces o, i < PRE_first_tail_x15_r0_body.P94.NL) (cl : SSt (· < 4097) PRE_first_tail_x15_r0_body.cx0_94.mlx)
    (hobjC : ∀ h, PRE_first_tail_x15_r0_body.fxC_94.get h = some () → ((Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s915.ffi).mlx.objs.get h).isSome = true)
    (hfC : ∀ h, (PRE_first_tail_x15_r0_body.krC_94.flags.get h).isSome = true → ((Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s915.ffi).mlx.objs.get h).isSome = true)
    (htC : ∀ h, (PRE_first_tail_x15_r0_body.krC_94.targs.get h).isSome = true → ((Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s915.ffi).mlx.objs.get h).isSome = true)
    (hclC : ∀ h l, PRE_first_tail_x15_r0_body.krC_94.targs.get h = some l → Host.Ts.Sim.Full.STargs (· < (⟨20062, 17151, 2749005, 4097⟩ : Conv.Cnt).n) l) :
    Conv.FullShiftQ PRE_first_tail_x15_r0_body.P94 4097 PRE_first_tail_x15_r0_body.kappa94 PRE_first_tail_x15_r0_body.s917.ffi PRE_first_tail_x15_r0_body.s916.ffi :=
  ⟨PRE_first_tail_x15_r0_body.cnshift94 clean hltC nltC itemsC tracedC cl, PRE_first_tail_x15_r0_body.cqueue94, fun t ht => bSN_sound (List.all_eq_true.mp PRE_first_tail_x15_r0_body.ctokSupp94 t ht),
    PRE_first_tail_x15_r0_body.cbridge94,
    liveShift_foot (x0' := Host.Ts.Sim.Full.mlxOf PRE_first_tail_x15_r0_body.s917.ffi) (x1' := Host.Ts.Sim.Full.mlxOf PRE_first_tail_x15_r0_body.s916.ffi) (PRE_first_tail_x15_r0_body.cfoot94 clean hltC nltC itemsC tracedC cl) rfl PRE_first_tail_x15_r0_body.ofx0_94 PRE_first_tail_x15_r0_body.ofx1_94 hobjC PRE_first_tail_x15_r0_body.ff094 PRE_first_tail_x15_r0_body.ff194 PRE_first_tail_x15_r0_body.ffck94,
    kernShift_foot (x0' := Host.Ts.Sim.Full.mlxOf PRE_first_tail_x15_r0_body.s917.ffi) (x1' := Host.Ts.Sim.Full.mlxOf PRE_first_tail_x15_r0_body.s916.ffi) (PRE_first_tail_x15_r0_body.cfoot94 clean hltC nltC itemsC tracedC cl) rfl PRE_first_tail_x15_r0_body.okr0_94 PRE_first_tail_x15_r0_body.okr1_94 (Nat.le_of_ble_eq_true PRE_first_tail_x15_r0_body.fkn94) hfC htC hclC
      PRE_first_tail_x15_r0_body.fkf094 PRE_first_tail_x15_r0_body.fkt094 PRE_first_tail_x15_r0_body.fkf194 PRE_first_tail_x15_r0_body.fkt194 PRE_first_tail_x15_r0_body.fkck94,
    pendReg_of rfl PRE_first_tail_x15_r0_body.cnh094 PRE_first_tail_x15_r0_body.cnh194 (Nat.le_of_ble_eq_true PRE_first_tail_x15_r0_body.cpendLe94) PRE_first_tail_x15_r0_body.cpendR94⟩

end Host.Load.Run.Tpl
