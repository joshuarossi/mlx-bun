import host.sim.template.a4pre_first_tail_x15_r0_body.SiteCl179
import host.sim.conv.CompactFull
import host.sim.template.FootGen
set_option Elab.async false
namespace Host.Load.Run.Tpl
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
open Host.Ts Host.Ts.Sim Host.Ts.Sim.Template

/-! The compaction's native shift at call site 179 from its footprint (`Conv.nshift_of_foot`), and the observers'
(`liveShift_foot`, `kernShift_foot`): `Conv.FullShiftQ` for `Conv.full_compactQ`, given the call's bookkeeping and its
relation's facts. -/

/-- The load parameters of the chain (band-free: its start's node counter as `NL` and `N0`). -/
def PRE_first_tail_x15_r0_body.Pc179 : LoadP := ⟨18151, 131072, 1099511627776, 15235, 15235, []⟩
/-- The site's band raised to the map's checked fixed-node prefix, including newly recorded closure traces. -/
def PRE_first_tail_x15_r0_body.P179 : LoadP := PRE_first_tail_x15_r0_body.Pc179.raise 18814
kernel_rfl PRE_first_tail_x15_r0_body.craise179 : Nat.ble PRE_first_tail_x15_r0_body.Pc179.N0 18814 = true
theorem PRE_first_tail_x15_r0_body.raised179 : Host.Ts.Sim.Full.Raised PRE_first_tail_x15_r0_body.Pc179 PRE_first_tail_x15_r0_body.P179 :=
  .inr ⟨18814, rfl, Nat.le_of_ble_eq_true PRE_first_tail_x15_r0_body.craise179, rfl⟩
noncomputable abbrev PRE_first_tail_x15_r0_body.cx0_179 : Host.Load.LSt := clearTokens (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1575.ffi)
noncomputable abbrev PRE_first_tail_x15_r0_body.cx1_179 : Host.Load.LSt := clearTokens (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1574.ffi)
def PRE_first_tail_x15_r0_body.khinv179 : PTrie Nat := Stage.setAll PTrie.nil []
def PRE_first_tail_x15_r0_body.kninv179 : PTrie Nat := Stage.setAll PTrie.nil []
/-- The stage's footprint: its written and fresh handles, fresh nodes, written and fresh items. -/
def PRE_first_tail_x15_r0_body.cwS179 : List Nat := []
def PRE_first_tail_x15_r0_body.cnS179 : List Nat := List.range' 18814 0
def PRE_first_tail_x15_r0_body.ciS179 : List Nat := [] ++ List.range' 18814 0

-- the small checks (`MChecks`'s)
kernel_rfl PRE_first_tail_x15_r0_body.cnh0179 : PRE_first_tail_x15_r0_body.kd179.nh0 = PRE_first_tail_x15_r0_body.cx0_179.mlx.next
kernel_rfl PRE_first_tail_x15_r0_body.cnh1179 : PRE_first_tail_x15_r0_body.kd179.nh1 = PRE_first_tail_x15_r0_body.cx1_179.mlx.next
kernel_rfl PRE_first_tail_x15_r0_body.cnn0179 : PRE_first_tail_x15_r0_body.kd179.nn0 = PRE_first_tail_x15_r0_body.cx0_179.mlx.nnext
kernel_rfl PRE_first_tail_x15_r0_body.cnn1179 : PRE_first_tail_x15_r0_body.kd179.nn1 = PRE_first_tail_x15_r0_body.cx1_179.mlx.nnext
kernel_rfl PRE_first_tail_x15_r0_body.cplo179 : (Nat.blt 0 PRE_first_tail_x15_r0_body.P179.lo && Nat.ble PRE_first_tail_x15_r0_body.P179.lo PRE_first_tail_x15_r0_body.cx0_179.mlx.next && Nat.ble PRE_first_tail_x15_r0_body.P179.lo RData.bigHi && Nat.ble RData.bigHi PRE_first_tail_x15_r0_body.P179.E) = true
kernel_rfl PRE_first_tail_x15_r0_body.ccnt179 : (Nat.ble PRE_first_tail_x15_r0_body.cx0_179.mlx.next PRE_first_tail_x15_r0_body.cx1_179.mlx.next && Nat.ble PRE_first_tail_x15_r0_body.cx0_179.mlx.nnext PRE_first_tail_x15_r0_body.cx1_179.mlx.nnext) = true
kernel_rfl PRE_first_tail_x15_r0_body.cnband179 : (Nat.blt 0 PRE_first_tail_x15_r0_body.P179.NL && Nat.ble PRE_first_tail_x15_r0_body.P179.NL PRE_first_tail_x15_r0_body.P179.N0 && Nat.ble PRE_first_tail_x15_r0_body.P179.N0 PRE_first_tail_x15_r0_body.cx0_179.mlx.nnext) = true
kernel_rfl PRE_first_tail_x15_r0_body.chbelow179 : PRE_first_tail_x15_r0_body.kd179.checkHndBelow = true
kernel_rfl PRE_first_tail_x15_r0_body.chren179 : checkRenG PRE_first_tail_x15_r0_body.kd179.hnd PRE_first_tail_x15_r0_body.khinv179 (phB PRE_first_tail_x15_r0_body.cx0_179.mlx) = true
kernel_rfl PRE_first_tail_x15_r0_body.cband179 : PRE_first_tail_x15_r0_body.kd179.checkBand PRE_first_tail_x15_r0_body.P179.lo = true
kernel_rfl PRE_first_tail_x15_r0_body.cnh1pos179 : Nat.blt 0 PRE_first_tail_x15_r0_body.kd179.nh1 = true
kernel_rfl PRE_first_tail_x15_r0_body.cnren179 : checkRenG PRE_first_tail_x15_r0_body.kd179.node PRE_first_tail_x15_r0_body.kninv179 (pnB PRE_first_tail_x15_r0_body.cx0_179.mlx) = true
kernel_rfl PRE_first_tail_x15_r0_body.cnlow179 : (PTrie.keysA PRE_first_tail_x15_r0_body.kd179.node).all (fun j => Nat.ble PRE_first_tail_x15_r0_body.P179.NL j && Nat.blt (PRE_first_tail_x15_r0_body.kd179.nodeF j) PRE_first_tail_x15_r0_body.cx1_179.mlx.nnext) = true
kernel_rfl PRE_first_tail_x15_r0_body.cabs0a179 : PRE_first_tail_x15_r0_body.cx0_179.mlx.arrs.get 0 = none
kernel_rfl PRE_first_tail_x15_r0_body.cabs0b179 : PRE_first_tail_x15_r0_body.cx0_179.mlx.objs.get 0 = none
kernel_rfl PRE_first_tail_x15_r0_body.ctok1179 : PRE_first_tail_x15_r0_body.cx1_179.mlx.tokens = []
kernel_rfl PRE_first_tail_x15_r0_body.cpend179 : PRE_first_tail_x15_r0_body.cx1_179.mlx.pending = PRE_first_tail_x15_r0_body.cx0_179.mlx.pending.map PRE_first_tail_x15_r0_body.kappa179.pend
kernel_rfl PRE_first_tail_x15_r0_body.cerrh179 : PRE_first_tail_x15_r0_body.cx1_179.mlx.errh = PRE_first_tail_x15_r0_body.cx0_179.mlx.errh.map PRE_first_tail_x15_r0_body.kappa179.arg
kernel_rfl PRE_first_tail_x15_r0_body.cfiles179 : PRE_first_tail_x15_r0_body.cx1_179.mlx.files = PRE_first_tail_x15_r0_body.cx0_179.mlx.files
kernel_rfl PRE_first_tail_x15_r0_body.carch179 : PRE_first_tail_x15_r0_body.cx1_179.mlx.arch = PRE_first_tail_x15_r0_body.cx0_179.mlx.arch
kernel_rfl PRE_first_tail_x15_r0_body.csizes179 : PRE_first_tail_x15_r0_body.cx1_179.mlx.deviceSizes = PRE_first_tail_x15_r0_body.cx0_179.mlx.deviceSizes
kernel_rfl PRE_first_tail_x15_r0_body.cwired179 : PRE_first_tail_x15_r0_body.cx1_179.mlx.wired = PRE_first_tail_x15_r0_body.cx0_179.mlx.wired
kernel_rfl PRE_first_tail_x15_r0_body.chost179 : PRE_first_tail_x15_r0_body.cx1_179.host = PRE_first_tail_x15_r0_body.cx0_179.host
-- the compaction map's addresses are `PRE_first_tail_x15_r0_body.kd179`'s
kernel_rfl PRE_first_tail_x15_r0_body.ckn0179 : PRE_first_tail_x15_r0_body.kd179.n0 = 2815230
kernel_rfl PRE_first_tail_x15_r0_body.ckn1179 : PRE_first_tail_x15_r0_body.kd179.n1 = 2815249
kernel_rfl PRE_first_tail_x15_r0_body.ckheap179 : (PTrie.keysA PRE_first_tail_x15_r0_body.kd179.heap).all (fun x => Nat.ble 2815229 x) = true
kernel_rfl PRE_first_tail_x15_r0_body.ckpl179 : (List.range 1).all (fun j => decide (PRE_first_tail_x15_r0_body.kd179.heap.get (2815229 + j) = nth? PRE_first_tail_x15_r0_body.pl179 j)) = true
-- the map fixes the call's names (`Conv.fixOld_compact`), the call's counters
kernel_rfl PRE_first_tail_x15_r0_body.fja179 : Nat.ble 2815229 2815229 = true
kernel_rfl PRE_first_tail_x15_r0_body.fn179 : Nat.ble 7705 7705 = true
kernel_rfl PRE_first_tail_x15_r0_body.fjaD179 : Nat.ble 2815229 PRE_first_tail_x15_r0_body.kd179.n0 = true
kernel_rfl PRE_first_tail_x15_r0_body.fxn179 : Nat.ble 21721 PRE_first_tail_x15_r0_body.kd179.nh0 = true
kernel_rfl PRE_first_tail_x15_r0_body.fnn179 : Nat.ble 18814 PRE_first_tail_x15_r0_body.kd179.nn0 = true
kernel_rfl PRE_first_tail_x15_r0_body.fxb179 : Nat.ble 21721 RData.bigHi = true
kernel_rfl PRE_first_tail_x15_r0_body.fheap179 : (PTrie.keysA PRE_first_tail_x15_r0_body.kd179.heap).all (Nat.ble (⟨21721, 18814, 2815229, 7705⟩ : Conv.Cnt).ja) = true
kernel_rfl PRE_first_tail_x15_r0_body.fhnd179 : (PTrie.keysA PRE_first_tail_x15_r0_body.kd179.hnd).all (Nat.ble (⟨21721, 18814, 2815229, 7705⟩ : Conv.Cnt).xn) = true
kernel_rfl PRE_first_tail_x15_r0_body.fnode179 : (PTrie.keysA PRE_first_tail_x15_r0_body.kd179.node).all (Nat.ble (⟨21721, 18814, 2815229, 7705⟩ : Conv.Cnt).nn) = true
/-- The compaction map fixes the call's names. -/
theorem PRE_first_tail_x15_r0_body.cfix179 : Conv.FixOld (⟨21721, 18814, 2815229, 7705⟩ : Conv.Cnt) PRE_first_tail_x15_r0_body.kappa179 :=
  Conv.fixOld_compact (Nat.le_of_ble_eq_true PRE_first_tail_x15_r0_body.fja179) (Nat.le_of_ble_eq_true PRE_first_tail_x15_r0_body.fn179) (Nat.le_of_ble_eq_true PRE_first_tail_x15_r0_body.fjaD179) (Nat.le_of_ble_eq_true PRE_first_tail_x15_r0_body.fxn179) (Nat.le_of_ble_eq_true PRE_first_tail_x15_r0_body.fnn179) (Nat.le_of_ble_eq_true PRE_first_tail_x15_r0_body.fxb179) PRE_first_tail_x15_r0_body.fheap179 PRE_first_tail_x15_r0_body.fhnd179 PRE_first_tail_x15_r0_body.fnode179
kernel_rfl PRE_first_tail_x15_r0_body.fcxn179 : (⟨21721, 18814, 2815229, 7705⟩ : Conv.Cnt).xn = (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1573.ffi).mlx.next
kernel_rfl PRE_first_tail_x15_r0_body.fcnn179 : (⟨21721, 18814, 2815229, 7705⟩ : Conv.Cnt).nn = (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1573.ffi).mlx.nnext
kernel_rfl PRE_first_tail_x15_r0_body.fle0179 : (Nat.ble (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1573.ffi).mlx.next PRE_first_tail_x15_r0_body.cx0_179.mlx.next && Nat.ble (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1573.ffi).mlx.nnext PRE_first_tail_x15_r0_body.cx0_179.mlx.nnext && Nat.ble (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1573.ffi).mlx.next RData.bigHi) = true
kernel_rfl PRE_first_tail_x15_r0_body.fnk179 : (PTrie.keysA PRE_first_tail_x15_r0_body.kd179.node).all (Nat.ble (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1573.ffi).mlx.nnext) = true
-- the merged state keeps the call's entries off the stage's footprint
kernel_rfl PRE_first_tail_x15_r0_body.f1A179 : PRE_first_tail_x15_r0_body.cx1_179.mlx.arrs = Stage.setAll (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1573.ffi).mlx.arrs (PRE_first_tail_x15_r0_body.cwS179.filterMap fun i => (PRE_first_tail_x15_r0_body.cx1_179.mlx.arrs.get i).map (i, ·))
kernel_rfl PRE_first_tail_x15_r0_body.f1O179 : PRE_first_tail_x15_r0_body.cx1_179.mlx.objs = Stage.setAll (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1573.ffi).mlx.objs (PRE_first_tail_x15_r0_body.cwS179.filterMap fun i => (PRE_first_tail_x15_r0_body.cx1_179.mlx.objs.get i).map (i, ·))
kernel_rfl PRE_first_tail_x15_r0_body.f1N179 : PRE_first_tail_x15_r0_body.cx1_179.mlx.nodes = Stage.setAll (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1573.ffi).mlx.nodes (PRE_first_tail_x15_r0_body.cnS179.filterMap fun i => (PRE_first_tail_x15_r0_body.cx1_179.mlx.nodes.get i).map (i, ·))
kernel_rfl PRE_first_tail_x15_r0_body.f1I179 : PRE_first_tail_x15_r0_body.cx1_179.mlx.items = Stage.setAll (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1573.ffi).mlx.items (PRE_first_tail_x15_r0_body.ciS179.filterMap fun i => (PRE_first_tail_x15_r0_body.cx1_179.mlx.items.get i).map (i, ·))
kernel_rfl PRE_first_tail_x15_r0_body.fbd179 : (PRE_first_tail_x15_r0_body.clo179 ++ PRE_first_tail_x15_r0_body.cln179 ++ PRE_first_tail_x15_r0_body.cli179 ++ PRE_first_tail_x15_r0_body.cwS179 ++ PRE_first_tail_x15_r0_body.cnS179 ++ PRE_first_tail_x15_r0_body.ciS179).all (fun i => Nat.blt (i / 4096) (4 ^ 31)) = true
kernel_rfl PRE_first_tail_x15_r0_body.fincW179 : PRE_first_tail_x15_r0_body.cwS179.all (fun h => !Nat.blt h (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1573.ffi).mlx.next || PRE_first_tail_x15_r0_body.clo179.contains h) = true
kernel_rfl PRE_first_tail_x15_r0_body.fincI179 : PRE_first_tail_x15_r0_body.ciS179.all (fun k => !Nat.blt k (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1573.ffi).mlx.nnext || PRE_first_tail_x15_r0_body.cli179.contains k) = true
kernel_rfl PRE_first_tail_x15_r0_body.fincN179 : PRE_first_tail_x15_r0_body.cnS179.all (Nat.ble (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1573.ffi).mlx.nnext) = true
kernel_rfl PRE_first_tail_x15_r0_body.flnF179 : PRE_first_tail_x15_r0_body.cln179.all (Nat.ble (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1573.ffi).mlx.nnext) = true
-- the checks over the changed lists
kernel_rfl PRE_first_tail_x15_r0_body.fh179 : PRE_first_tail_x15_r0_body.clo179.all (handleOK PRE_first_tail_x15_r0_body.kappa179 PRE_first_tail_x15_r0_body.P179.lo PRE_first_tail_x15_r0_body.cx0_179.mlx PRE_first_tail_x15_r0_body.cx1_179.mlx) = true
kernel_rfl PRE_first_tail_x15_r0_body.fo179 : PRE_first_tail_x15_r0_body.clo179.map (fun h => PRE_first_tail_x15_r0_body.cx1_179.mlx.objs.get (PRE_first_tail_x15_r0_body.kappa179.handle h)) = PRE_first_tail_x15_r0_body.clo179.map (fun h => (PRE_first_tail_x15_r0_body.cx0_179.mlx.objs.get h).map PRE_first_tail_x15_r0_body.kappa179.nobj)
kernel_rfl PRE_first_tail_x15_r0_body.fok179 : PRE_first_tail_x15_r0_body.clo179.all (objOK PRE_first_tail_x15_r0_body.kappa179 PRE_first_tail_x15_r0_body.P179.NL PRE_first_tail_x15_r0_body.cx0_179.mlx) = true
kernel_rfl PRE_first_tail_x15_r0_body.fnd179 : PRE_first_tail_x15_r0_body.cln179.all (nodeOKF PRE_first_tail_x15_r0_body.kappa179 PRE_first_tail_x15_r0_body.P179 PRE_first_tail_x15_r0_body.cx0_179.mlx PRE_first_tail_x15_r0_body.cx1_179.mlx) = true
kernel_rfl PRE_first_tail_x15_r0_body.fp179 : ((PRE_first_tail_x15_r0_body.cln179.filter (fullB PRE_first_tail_x15_r0_body.P179))).map (fun i => (PRE_first_tail_x15_r0_body.cx1_179.mlx.nodes.get (PRE_first_tail_x15_r0_body.kappa179.node i)).map Host.Mlx.Ffi.Node.prim) =
  ((PRE_first_tail_x15_r0_body.cln179.filter (fullB PRE_first_tail_x15_r0_body.P179))).map (fun i => (PRE_first_tail_x15_r0_body.cx0_179.mlx.nodes.get i).map fun nd => PRE_first_tail_x15_r0_body.kappa179.prim nd.prim)
kernel_rfl PRE_first_tail_x15_r0_body.fnordI179 : incrB PRE_first_tail_x15_r0_body.kd179.nodeF (List.range' 18814 0) = true
kernel_rfl PRE_first_tail_x15_r0_body.fnordK179 : (PTrie.keysA PRE_first_tail_x15_r0_body.kd179.node).all (fun k => Nat.ble 18814 k && Nat.blt k 18814) = true
kernel_rfl PRE_first_tail_x15_r0_body.fnordL179 : (PRE_first_tail_x15_r0_body.cln179.filter (Nat.ble PRE_first_tail_x15_r0_body.P179.N0)).all (fun i => Nat.ble i (PRE_first_tail_x15_r0_body.kd179.nodeF i) && (Nat.blt i 18814 || Nat.ble PRE_first_tail_x15_r0_body.kd179.nn0 i)) = true
theorem PRE_first_tail_x15_r0_body.fnord179 : (PRE_first_tail_x15_r0_body.cln179.filter (Nat.ble PRE_first_tail_x15_r0_body.P179.N0)).all (fun i => Nat.ble i (PRE_first_tail_x15_r0_body.kd179.nodeF i) &&
    (PTrie.keysA PRE_first_tail_x15_r0_body.kd179.node).all fun j => !Nat.blt j i || Nat.blt (PRE_first_tail_x15_r0_body.kd179.nodeF j) (PRE_first_tail_x15_r0_body.kd179.nodeF i)) = true :=
  cnord_of PRE_first_tail_x15_r0_body.cnlow179 PRE_first_tail_x15_r0_body.cnn1179 PRE_first_tail_x15_r0_body.fnordI179 PRE_first_tail_x15_r0_body.fnordK179 PRE_first_tail_x15_r0_body.fnordL179
kernel_rfl PRE_first_tail_x15_r0_body.fi179 : PRE_first_tail_x15_r0_body.cli179.all (pnB PRE_first_tail_x15_r0_body.cx0_179.mlx) = true
kernel_rfl PRE_first_tail_x15_r0_body.fii179 : PRE_first_tail_x15_r0_body.cli179.all (fun k => decide (PRE_first_tail_x15_r0_body.cx1_179.mlx.items.get (PRE_first_tail_x15_r0_body.kappa179.node k) = (PRE_first_tail_x15_r0_body.cx0_179.mlx.items.get k).map PRE_first_tail_x15_r0_body.kappa179.nv)) = true
/-- **The compaction's footprint.** -/
theorem PRE_first_tail_x15_r0_body.cfoot179 (clean : Conv.NClean (⟨21721, 18814, 2815229, 7705⟩ : Conv.Cnt) (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1573.ffi).mlx) (hltC : ∀ h, PH (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1573.ffi).mlx h → h < (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1573.ffi).mlx.next) (nltC : ∀ i, PN (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1573.ffi).mlx i → i < (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1573.ffi).mlx.nnext) (itemsC : ∀ k v, (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1573.ffi).mlx.items.get k = some v → PN (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1573.ffi).mlx k) (tracedC : ∀ h o, (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1573.ffi).mlx.objs.get h = some o → ∀ i ∈ objTraces o, i < PRE_first_tail_x15_r0_body.P179.NL) (cl : SSt (· < 7705) PRE_first_tail_x15_r0_body.cx0_179.mlx) :
    Conv.MFoot PRE_first_tail_x15_r0_body.P179 7705 PRE_first_tail_x15_r0_body.kappa179 PRE_first_tail_x15_r0_body.kd179 PRE_first_tail_x15_r0_body.khinv179 PRE_first_tail_x15_r0_body.kninv179 (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1573.ffi).mlx PRE_first_tail_x15_r0_body.cx0_179.mlx PRE_first_tail_x15_r0_body.cx1_179.mlx (⟨21721, 18814, 2815229, 7705⟩ : Conv.Cnt) PRE_first_tail_x15_r0_body.clo179 PRE_first_tail_x15_r0_body.cln179 PRE_first_tail_x15_r0_body.cli179 PRE_first_tail_x15_r0_body.cwS179 PRE_first_tail_x15_r0_body.cnS179 PRE_first_tail_x15_r0_body.ciS179 :=
  ⟨rfl, rfl, rfl, PRE_first_tail_x15_r0_body.cnh0179, PRE_first_tail_x15_r0_body.cnh1179, PRE_first_tail_x15_r0_body.cnn0179, PRE_first_tail_x15_r0_body.cnn1179, PRE_first_tail_x15_r0_body.cplo179, PRE_first_tail_x15_r0_body.ccnt179, PRE_first_tail_x15_r0_body.cnband179, PRE_first_tail_x15_r0_body.chbelow179, PRE_first_tail_x15_r0_body.chren179, PRE_first_tail_x15_r0_body.cband179, PRE_first_tail_x15_r0_body.cnh1pos179, PRE_first_tail_x15_r0_body.cnren179, PRE_first_tail_x15_r0_body.cnlow179, PRE_first_tail_x15_r0_body.cabs0a179, PRE_first_tail_x15_r0_body.cabs0b179, PRE_first_tail_x15_r0_body.ctok1179, PRE_first_tail_x15_r0_body.cpend179, PRE_first_tail_x15_r0_body.cerrh179, PRE_first_tail_x15_r0_body.cfiles179, PRE_first_tail_x15_r0_body.carch179, PRE_first_tail_x15_r0_body.csizes179, PRE_first_tail_x15_r0_body.cwired179, PRE_first_tail_x15_r0_body.cfix179, clean, PRE_first_tail_x15_r0_body.fcxn179, PRE_first_tail_x15_r0_body.fcnn179, hltC, nltC, itemsC, tracedC, cl, PRE_first_tail_x15_r0_body.fle0179, PRE_first_tail_x15_r0_body.fnk179, PRE_first_tail_x15_r0_body.ckA179, PRE_first_tail_x15_r0_body.cobjsK179, PRE_first_tail_x15_r0_body.cnodesK179, PRE_first_tail_x15_r0_body.citemsK179, PRE_first_tail_x15_r0_body.f1A179, PRE_first_tail_x15_r0_body.f1O179, PRE_first_tail_x15_r0_body.f1N179, PRE_first_tail_x15_r0_body.f1I179, PRE_first_tail_x15_r0_body.fbd179, PRE_first_tail_x15_r0_body.fincW179, PRE_first_tail_x15_r0_body.fincI179, PRE_first_tail_x15_r0_body.fincN179, PRE_first_tail_x15_r0_body.flnF179, PRE_first_tail_x15_r0_body.fh179, PRE_first_tail_x15_r0_body.fo179, PRE_first_tail_x15_r0_body.fok179, PRE_first_tail_x15_r0_body.fnd179, PRE_first_tail_x15_r0_body.fp179, PRE_first_tail_x15_r0_body.fnord179, PRE_first_tail_x15_r0_body.fi179, PRE_first_tail_x15_r0_body.fii179⟩
theorem PRE_first_tail_x15_r0_body.cnshift179 (clean : Conv.NClean (⟨21721, 18814, 2815229, 7705⟩ : Conv.Cnt) (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1573.ffi).mlx) (hltC : ∀ h, PH (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1573.ffi).mlx h → h < (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1573.ffi).mlx.next) (nltC : ∀ i, PN (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1573.ffi).mlx i → i < (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1573.ffi).mlx.nnext) (itemsC : ∀ k v, (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1573.ffi).mlx.items.get k = some v → PN (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1573.ffi).mlx k) (tracedC : ∀ h o, (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1573.ffi).mlx.objs.get h = some o → ∀ i ∈ objTraces o, i < PRE_first_tail_x15_r0_body.P179.NL) (cl : SSt (· < 7705) PRE_first_tail_x15_r0_body.cx0_179.mlx) : NShift PRE_first_tail_x15_r0_body.P179 7705 PRE_first_tail_x15_r0_body.kappa179 PRE_first_tail_x15_r0_body.cx0_179 PRE_first_tail_x15_r0_body.cx1_179 :=
  Conv.nshift_of_foot (PRE_first_tail_x15_r0_body.cfoot179 clean hltC nltC itemsC tracedC cl) PRE_first_tail_x15_r0_body.chost179 (compact_a_eq PRE_first_tail_x15_r0_body.ckn0179 PRE_first_tail_x15_r0_body.ckn1179 PRE_first_tail_x15_r0_body.ckheap179 PRE_first_tail_x15_r0_body.ckpl179)

-- the observers: the layers' states at the call, the canonical and the merged state, their footprints and checks
noncomputable def PRE_first_tail_x15_r0_body.fxC_179 : PTrie Unit := (Host.Ts.Sim.Full.freedOf PRE_first_tail_x15_r0_body.s1573.ffi).getD PTrie.nil
noncomputable def PRE_first_tail_x15_r0_body.krC_179 : Host.Load.Layers.KRec := (Host.Ts.Sim.Full.krecOf PRE_first_tail_x15_r0_body.s1573.ffi).getD Host.Load.Layers.KRec.empty
kernel_rfl PRE_first_tail_x15_r0_body.ofxC_179 : (Host.Ts.Sim.Full.freedOf PRE_first_tail_x15_r0_body.s1573.ffi) = some PRE_first_tail_x15_r0_body.fxC_179
kernel_rfl PRE_first_tail_x15_r0_body.okrC_179 : (Host.Ts.Sim.Full.krecOf PRE_first_tail_x15_r0_body.s1573.ffi) = some PRE_first_tail_x15_r0_body.krC_179
noncomputable def PRE_first_tail_x15_r0_body.fx0_179 : PTrie Unit := (Host.Ts.Sim.Full.freedOf PRE_first_tail_x15_r0_body.s1575.ffi).getD PTrie.nil
noncomputable def PRE_first_tail_x15_r0_body.kr0_179 : Host.Load.Layers.KRec := (Host.Ts.Sim.Full.krecOf PRE_first_tail_x15_r0_body.s1575.ffi).getD Host.Load.Layers.KRec.empty
kernel_rfl PRE_first_tail_x15_r0_body.ofx0_179 : (Host.Ts.Sim.Full.freedOf PRE_first_tail_x15_r0_body.s1575.ffi) = some PRE_first_tail_x15_r0_body.fx0_179
kernel_rfl PRE_first_tail_x15_r0_body.okr0_179 : (Host.Ts.Sim.Full.krecOf PRE_first_tail_x15_r0_body.s1575.ffi) = some PRE_first_tail_x15_r0_body.kr0_179
noncomputable def PRE_first_tail_x15_r0_body.fx1_179 : PTrie Unit := (Host.Ts.Sim.Full.freedOf PRE_first_tail_x15_r0_body.s1574.ffi).getD PTrie.nil
noncomputable def PRE_first_tail_x15_r0_body.kr1_179 : Host.Load.Layers.KRec := (Host.Ts.Sim.Full.krecOf PRE_first_tail_x15_r0_body.s1574.ffi).getD Host.Load.Layers.KRec.empty
kernel_rfl PRE_first_tail_x15_r0_body.ofx1_179 : (Host.Ts.Sim.Full.freedOf PRE_first_tail_x15_r0_body.s1574.ffi) = some PRE_first_tail_x15_r0_body.fx1_179
kernel_rfl PRE_first_tail_x15_r0_body.okr1_179 : (Host.Ts.Sim.Full.krecOf PRE_first_tail_x15_r0_body.s1574.ffi) = some PRE_first_tail_x15_r0_body.kr1_179
kernel_rfl PRE_first_tail_x15_r0_body.ff0179 : PRE_first_tail_x15_r0_body.fx0_179 = Stage.setAll PRE_first_tail_x15_r0_body.fxC_179 (PRE_first_tail_x15_r0_body.clo179.filterMap fun i => (PRE_first_tail_x15_r0_body.fx0_179.get i).map (i, ·))
kernel_rfl PRE_first_tail_x15_r0_body.ff1179 : PRE_first_tail_x15_r0_body.fx1_179 = Stage.setAll PRE_first_tail_x15_r0_body.fxC_179 (PRE_first_tail_x15_r0_body.cwS179.filterMap fun i => (PRE_first_tail_x15_r0_body.fx1_179.get i).map (i, ·))
kernel_rfl PRE_first_tail_x15_r0_body.ffck179 : freedLB PRE_first_tail_x15_r0_body.kappa179 PRE_first_tail_x15_r0_body.cx0_179.mlx PRE_first_tail_x15_r0_body.fx0_179 PRE_first_tail_x15_r0_body.fx1_179 PRE_first_tail_x15_r0_body.clo179 = true
kernel_rfl PRE_first_tail_x15_r0_body.fkf0179 : PRE_first_tail_x15_r0_body.kr0_179.flags = Stage.setAll PRE_first_tail_x15_r0_body.krC_179.flags (PRE_first_tail_x15_r0_body.clo179.filterMap fun i => (PRE_first_tail_x15_r0_body.kr0_179.flags.get i).map (i, ·))
kernel_rfl PRE_first_tail_x15_r0_body.fkt0179 : PRE_first_tail_x15_r0_body.kr0_179.targs = Stage.setAll PRE_first_tail_x15_r0_body.krC_179.targs (PRE_first_tail_x15_r0_body.clo179.filterMap fun i => (PRE_first_tail_x15_r0_body.kr0_179.targs.get i).map (i, ·))
kernel_rfl PRE_first_tail_x15_r0_body.fkf1179 : PRE_first_tail_x15_r0_body.kr1_179.flags = Stage.setAll PRE_first_tail_x15_r0_body.krC_179.flags (PRE_first_tail_x15_r0_body.cwS179.filterMap fun i => (PRE_first_tail_x15_r0_body.kr1_179.flags.get i).map (i, ·))
kernel_rfl PRE_first_tail_x15_r0_body.fkt1179 : PRE_first_tail_x15_r0_body.kr1_179.targs = Stage.setAll PRE_first_tail_x15_r0_body.krC_179.targs (PRE_first_tail_x15_r0_body.cwS179.filterMap fun i => (PRE_first_tail_x15_r0_body.kr1_179.targs.get i).map (i, ·))
kernel_rfl PRE_first_tail_x15_r0_body.fkck179 : krecLB PRE_first_tail_x15_r0_body.kappa179 7705 PRE_first_tail_x15_r0_body.cx0_179.mlx PRE_first_tail_x15_r0_body.kr0_179 PRE_first_tail_x15_r0_body.kr1_179 PRE_first_tail_x15_r0_body.clo179 = true
kernel_rfl PRE_first_tail_x15_r0_body.fkn179 : Nat.ble 7705 7705 = true
-- the bridge and the pending traces' regions
kernel_rfl PRE_first_tail_x15_r0_body.cbridge179 : Host.Ts.Sim.Full.bridgeOf PRE_first_tail_x15_r0_body.s1574.ffi = Host.Ts.Sim.Full.bridgeOf PRE_first_tail_x15_r0_body.s1575.ffi
kernel_rfl PRE_first_tail_x15_r0_body.cpendR179 : pendRegB PRE_first_tail_x15_r0_body.kappa179 (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1575.ffi).mlx = true
kernel_rfl PRE_first_tail_x15_r0_body.cpendLe179 : Nat.ble (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1575.ffi).mlx.next (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1574.ffi).mlx.next = true
/-- **The compaction's native shift**, given the call's bookkeeping, its relation's facts (the model's and the
observers') and the canonical closedness. -/
theorem PRE_first_tail_x15_r0_body.cshift179 (clean : Conv.NClean (⟨21721, 18814, 2815229, 7705⟩ : Conv.Cnt) (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1573.ffi).mlx) (hltC : ∀ h, PH (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1573.ffi).mlx h → h < (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1573.ffi).mlx.next) (nltC : ∀ i, PN (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1573.ffi).mlx i → i < (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1573.ffi).mlx.nnext) (itemsC : ∀ k v, (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1573.ffi).mlx.items.get k = some v → PN (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1573.ffi).mlx k) (tracedC : ∀ h o, (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1573.ffi).mlx.objs.get h = some o → ∀ i ∈ objTraces o, i < PRE_first_tail_x15_r0_body.P179.NL) (cl : SSt (· < 7705) PRE_first_tail_x15_r0_body.cx0_179.mlx)
    (hobjC : ∀ h, PRE_first_tail_x15_r0_body.fxC_179.get h = some () → ((Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1573.ffi).mlx.objs.get h).isSome = true)
    (hfC : ∀ h, (PRE_first_tail_x15_r0_body.krC_179.flags.get h).isSome = true → ((Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1573.ffi).mlx.objs.get h).isSome = true)
    (htC : ∀ h, (PRE_first_tail_x15_r0_body.krC_179.targs.get h).isSome = true → ((Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1573.ffi).mlx.objs.get h).isSome = true)
    (hclC : ∀ h l, PRE_first_tail_x15_r0_body.krC_179.targs.get h = some l → Host.Ts.Sim.Full.STargs (· < (⟨21721, 18814, 2815229, 7705⟩ : Conv.Cnt).n) l) :
    Conv.FullShiftQ PRE_first_tail_x15_r0_body.P179 7705 PRE_first_tail_x15_r0_body.kappa179 PRE_first_tail_x15_r0_body.s1575.ffi PRE_first_tail_x15_r0_body.s1574.ffi :=
  ⟨PRE_first_tail_x15_r0_body.cnshift179 clean hltC nltC itemsC tracedC cl, PRE_first_tail_x15_r0_body.cqueue179, fun t ht => bSN_sound (List.all_eq_true.mp PRE_first_tail_x15_r0_body.ctokSupp179 t ht),
    PRE_first_tail_x15_r0_body.cbridge179,
    liveShift_foot (x0' := Host.Ts.Sim.Full.mlxOf PRE_first_tail_x15_r0_body.s1575.ffi) (x1' := Host.Ts.Sim.Full.mlxOf PRE_first_tail_x15_r0_body.s1574.ffi) (PRE_first_tail_x15_r0_body.cfoot179 clean hltC nltC itemsC tracedC cl) rfl PRE_first_tail_x15_r0_body.ofx0_179 PRE_first_tail_x15_r0_body.ofx1_179 hobjC PRE_first_tail_x15_r0_body.ff0179 PRE_first_tail_x15_r0_body.ff1179 PRE_first_tail_x15_r0_body.ffck179,
    kernShift_foot (x0' := Host.Ts.Sim.Full.mlxOf PRE_first_tail_x15_r0_body.s1575.ffi) (x1' := Host.Ts.Sim.Full.mlxOf PRE_first_tail_x15_r0_body.s1574.ffi) (PRE_first_tail_x15_r0_body.cfoot179 clean hltC nltC itemsC tracedC cl) rfl PRE_first_tail_x15_r0_body.okr0_179 PRE_first_tail_x15_r0_body.okr1_179 (Nat.le_of_ble_eq_true PRE_first_tail_x15_r0_body.fkn179) hfC htC hclC
      PRE_first_tail_x15_r0_body.fkf0179 PRE_first_tail_x15_r0_body.fkt0179 PRE_first_tail_x15_r0_body.fkf1179 PRE_first_tail_x15_r0_body.fkt1179 PRE_first_tail_x15_r0_body.fkck179,
    pendReg_of rfl PRE_first_tail_x15_r0_body.cnh0179 PRE_first_tail_x15_r0_body.cnh1179 (Nat.le_of_ble_eq_true PRE_first_tail_x15_r0_body.cpendLe179) PRE_first_tail_x15_r0_body.cpendR179⟩

end Host.Load.Run.Tpl
