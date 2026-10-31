import host.sim.template.a4pre_first_tail_x15_r0_body.SiteCl106
import host.sim.conv.CompactFull
import host.sim.template.FootGen
set_option Elab.async false
namespace Host.Load.Run.Tpl
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
open Host.Ts Host.Ts.Sim Host.Ts.Sim.Template

/-! The compaction's native shift at call site 106 from its footprint (`Conv.nshift_of_foot`), and the observers'
(`liveShift_foot`, `kernShift_foot`): `Conv.FullShiftQ` for `Conv.full_compactQ`, given the call's bookkeeping and its
relation's facts. -/

/-- The load parameters of the chain (band-free: its start's node counter as `NL` and `N0`). -/
def PRE_first_tail_x15_r0_body.Pc106 : LoadP := ⟨18151, 131072, 1099511627776, 15235, 15235, []⟩
/-- The site's band raised to the map's checked fixed-node prefix, including newly recorded closure traces. -/
def PRE_first_tail_x15_r0_body.P106 : LoadP := PRE_first_tail_x15_r0_body.Pc106.raise 17388
kernel_rfl PRE_first_tail_x15_r0_body.craise106 : Nat.ble PRE_first_tail_x15_r0_body.Pc106.N0 17388 = true
theorem PRE_first_tail_x15_r0_body.raised106 : Host.Ts.Sim.Full.Raised PRE_first_tail_x15_r0_body.Pc106 PRE_first_tail_x15_r0_body.P106 :=
  .inr ⟨17388, rfl, Nat.le_of_ble_eq_true PRE_first_tail_x15_r0_body.craise106, rfl⟩
noncomputable abbrev PRE_first_tail_x15_r0_body.cx0_106 : Host.Load.LSt := clearTokens (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s941.ffi)
noncomputable abbrev PRE_first_tail_x15_r0_body.cx1_106 : Host.Load.LSt := clearTokens (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s940.ffi)
def PRE_first_tail_x15_r0_body.khinv106 : PTrie Nat := Stage.setAll PTrie.nil []
def PRE_first_tail_x15_r0_body.kninv106 : PTrie Nat := Stage.setAll PTrie.nil []
/-- The stage's footprint: its written and fresh handles, fresh nodes, written and fresh items. -/
def PRE_first_tail_x15_r0_body.cwS106 : List Nat := []
def PRE_first_tail_x15_r0_body.cnS106 : List Nat := List.range' 17388 0
def PRE_first_tail_x15_r0_body.ciS106 : List Nat := [] ++ List.range' 17388 0

-- the small checks (`MChecks`'s)
kernel_rfl PRE_first_tail_x15_r0_body.cnh0106 : PRE_first_tail_x15_r0_body.kd106.nh0 = PRE_first_tail_x15_r0_body.cx0_106.mlx.next
kernel_rfl PRE_first_tail_x15_r0_body.cnh1106 : PRE_first_tail_x15_r0_body.kd106.nh1 = PRE_first_tail_x15_r0_body.cx1_106.mlx.next
kernel_rfl PRE_first_tail_x15_r0_body.cnn0106 : PRE_first_tail_x15_r0_body.kd106.nn0 = PRE_first_tail_x15_r0_body.cx0_106.mlx.nnext
kernel_rfl PRE_first_tail_x15_r0_body.cnn1106 : PRE_first_tail_x15_r0_body.kd106.nn1 = PRE_first_tail_x15_r0_body.cx1_106.mlx.nnext
kernel_rfl PRE_first_tail_x15_r0_body.cplo106 : (Nat.blt 0 PRE_first_tail_x15_r0_body.P106.lo && Nat.ble PRE_first_tail_x15_r0_body.P106.lo PRE_first_tail_x15_r0_body.cx0_106.mlx.next && Nat.ble PRE_first_tail_x15_r0_body.P106.lo RData.bigHi && Nat.ble RData.bigHi PRE_first_tail_x15_r0_body.P106.E) = true
kernel_rfl PRE_first_tail_x15_r0_body.ccnt106 : (Nat.ble PRE_first_tail_x15_r0_body.cx0_106.mlx.next PRE_first_tail_x15_r0_body.cx1_106.mlx.next && Nat.ble PRE_first_tail_x15_r0_body.cx0_106.mlx.nnext PRE_first_tail_x15_r0_body.cx1_106.mlx.nnext) = true
kernel_rfl PRE_first_tail_x15_r0_body.cnband106 : (Nat.blt 0 PRE_first_tail_x15_r0_body.P106.NL && Nat.ble PRE_first_tail_x15_r0_body.P106.NL PRE_first_tail_x15_r0_body.P106.N0 && Nat.ble PRE_first_tail_x15_r0_body.P106.N0 PRE_first_tail_x15_r0_body.cx0_106.mlx.nnext) = true
kernel_rfl PRE_first_tail_x15_r0_body.chbelow106 : PRE_first_tail_x15_r0_body.kd106.checkHndBelow = true
kernel_rfl PRE_first_tail_x15_r0_body.chren106 : checkRenG PRE_first_tail_x15_r0_body.kd106.hnd PRE_first_tail_x15_r0_body.khinv106 (phB PRE_first_tail_x15_r0_body.cx0_106.mlx) = true
kernel_rfl PRE_first_tail_x15_r0_body.cband106 : PRE_first_tail_x15_r0_body.kd106.checkBand PRE_first_tail_x15_r0_body.P106.lo = true
kernel_rfl PRE_first_tail_x15_r0_body.cnh1pos106 : Nat.blt 0 PRE_first_tail_x15_r0_body.kd106.nh1 = true
kernel_rfl PRE_first_tail_x15_r0_body.cnren106 : checkRenG PRE_first_tail_x15_r0_body.kd106.node PRE_first_tail_x15_r0_body.kninv106 (pnB PRE_first_tail_x15_r0_body.cx0_106.mlx) = true
kernel_rfl PRE_first_tail_x15_r0_body.cnlow106 : (PTrie.keysA PRE_first_tail_x15_r0_body.kd106.node).all (fun j => Nat.ble PRE_first_tail_x15_r0_body.P106.NL j && Nat.blt (PRE_first_tail_x15_r0_body.kd106.nodeF j) PRE_first_tail_x15_r0_body.cx1_106.mlx.nnext) = true
kernel_rfl PRE_first_tail_x15_r0_body.cabs0a106 : PRE_first_tail_x15_r0_body.cx0_106.mlx.arrs.get 0 = none
kernel_rfl PRE_first_tail_x15_r0_body.cabs0b106 : PRE_first_tail_x15_r0_body.cx0_106.mlx.objs.get 0 = none
kernel_rfl PRE_first_tail_x15_r0_body.ctok1106 : PRE_first_tail_x15_r0_body.cx1_106.mlx.tokens = []
kernel_rfl PRE_first_tail_x15_r0_body.cpend106 : PRE_first_tail_x15_r0_body.cx1_106.mlx.pending = PRE_first_tail_x15_r0_body.cx0_106.mlx.pending.map PRE_first_tail_x15_r0_body.kappa106.pend
kernel_rfl PRE_first_tail_x15_r0_body.cerrh106 : PRE_first_tail_x15_r0_body.cx1_106.mlx.errh = PRE_first_tail_x15_r0_body.cx0_106.mlx.errh.map PRE_first_tail_x15_r0_body.kappa106.arg
kernel_rfl PRE_first_tail_x15_r0_body.cfiles106 : PRE_first_tail_x15_r0_body.cx1_106.mlx.files = PRE_first_tail_x15_r0_body.cx0_106.mlx.files
kernel_rfl PRE_first_tail_x15_r0_body.carch106 : PRE_first_tail_x15_r0_body.cx1_106.mlx.arch = PRE_first_tail_x15_r0_body.cx0_106.mlx.arch
kernel_rfl PRE_first_tail_x15_r0_body.csizes106 : PRE_first_tail_x15_r0_body.cx1_106.mlx.deviceSizes = PRE_first_tail_x15_r0_body.cx0_106.mlx.deviceSizes
kernel_rfl PRE_first_tail_x15_r0_body.cwired106 : PRE_first_tail_x15_r0_body.cx1_106.mlx.wired = PRE_first_tail_x15_r0_body.cx0_106.mlx.wired
kernel_rfl PRE_first_tail_x15_r0_body.chost106 : PRE_first_tail_x15_r0_body.cx1_106.host = PRE_first_tail_x15_r0_body.cx0_106.host
-- the compaction map's addresses are `PRE_first_tail_x15_r0_body.kd106`'s
kernel_rfl PRE_first_tail_x15_r0_body.ckn0106 : PRE_first_tail_x15_r0_body.kd106.n0 = 2758429
kernel_rfl PRE_first_tail_x15_r0_body.ckn1106 : PRE_first_tail_x15_r0_body.kd106.n1 = 2758431
kernel_rfl PRE_first_tail_x15_r0_body.ckheap106 : (PTrie.keysA PRE_first_tail_x15_r0_body.kd106.heap).all (fun x => Nat.ble 2758429 x) = true
kernel_rfl PRE_first_tail_x15_r0_body.ckpl106 : (List.range 0).all (fun j => decide (PRE_first_tail_x15_r0_body.kd106.heap.get (2758429 + j) = nth? PRE_first_tail_x15_r0_body.pl106 j)) = true
-- the map fixes the call's names (`Conv.fixOld_compact`), the call's counters
kernel_rfl PRE_first_tail_x15_r0_body.fja106 : Nat.ble 2758429 2758429 = true
kernel_rfl PRE_first_tail_x15_r0_body.fn106 : Nat.ble 4610 4610 = true
kernel_rfl PRE_first_tail_x15_r0_body.fjaD106 : Nat.ble 2758429 PRE_first_tail_x15_r0_body.kd106.n0 = true
kernel_rfl PRE_first_tail_x15_r0_body.fxn106 : Nat.ble 20298 PRE_first_tail_x15_r0_body.kd106.nh0 = true
kernel_rfl PRE_first_tail_x15_r0_body.fnn106 : Nat.ble 17388 PRE_first_tail_x15_r0_body.kd106.nn0 = true
kernel_rfl PRE_first_tail_x15_r0_body.fxb106 : Nat.ble 20298 RData.bigHi = true
kernel_rfl PRE_first_tail_x15_r0_body.fheap106 : (PTrie.keysA PRE_first_tail_x15_r0_body.kd106.heap).all (Nat.ble (⟨20298, 17388, 2758429, 4610⟩ : Conv.Cnt).ja) = true
kernel_rfl PRE_first_tail_x15_r0_body.fhnd106 : (PTrie.keysA PRE_first_tail_x15_r0_body.kd106.hnd).all (Nat.ble (⟨20298, 17388, 2758429, 4610⟩ : Conv.Cnt).xn) = true
kernel_rfl PRE_first_tail_x15_r0_body.fnode106 : (PTrie.keysA PRE_first_tail_x15_r0_body.kd106.node).all (Nat.ble (⟨20298, 17388, 2758429, 4610⟩ : Conv.Cnt).nn) = true
/-- The compaction map fixes the call's names. -/
theorem PRE_first_tail_x15_r0_body.cfix106 : Conv.FixOld (⟨20298, 17388, 2758429, 4610⟩ : Conv.Cnt) PRE_first_tail_x15_r0_body.kappa106 :=
  Conv.fixOld_compact (Nat.le_of_ble_eq_true PRE_first_tail_x15_r0_body.fja106) (Nat.le_of_ble_eq_true PRE_first_tail_x15_r0_body.fn106) (Nat.le_of_ble_eq_true PRE_first_tail_x15_r0_body.fjaD106) (Nat.le_of_ble_eq_true PRE_first_tail_x15_r0_body.fxn106) (Nat.le_of_ble_eq_true PRE_first_tail_x15_r0_body.fnn106) (Nat.le_of_ble_eq_true PRE_first_tail_x15_r0_body.fxb106) PRE_first_tail_x15_r0_body.fheap106 PRE_first_tail_x15_r0_body.fhnd106 PRE_first_tail_x15_r0_body.fnode106
kernel_rfl PRE_first_tail_x15_r0_body.fcxn106 : (⟨20298, 17388, 2758429, 4610⟩ : Conv.Cnt).xn = (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s939.ffi).mlx.next
kernel_rfl PRE_first_tail_x15_r0_body.fcnn106 : (⟨20298, 17388, 2758429, 4610⟩ : Conv.Cnt).nn = (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s939.ffi).mlx.nnext
kernel_rfl PRE_first_tail_x15_r0_body.fle0106 : (Nat.ble (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s939.ffi).mlx.next PRE_first_tail_x15_r0_body.cx0_106.mlx.next && Nat.ble (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s939.ffi).mlx.nnext PRE_first_tail_x15_r0_body.cx0_106.mlx.nnext && Nat.ble (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s939.ffi).mlx.next RData.bigHi) = true
kernel_rfl PRE_first_tail_x15_r0_body.fnk106 : (PTrie.keysA PRE_first_tail_x15_r0_body.kd106.node).all (Nat.ble (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s939.ffi).mlx.nnext) = true
-- the merged state keeps the call's entries off the stage's footprint
kernel_rfl PRE_first_tail_x15_r0_body.f1A106 : PRE_first_tail_x15_r0_body.cx1_106.mlx.arrs = Stage.setAll (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s939.ffi).mlx.arrs (PRE_first_tail_x15_r0_body.cwS106.filterMap fun i => (PRE_first_tail_x15_r0_body.cx1_106.mlx.arrs.get i).map (i, ·))
kernel_rfl PRE_first_tail_x15_r0_body.f1O106 : PRE_first_tail_x15_r0_body.cx1_106.mlx.objs = Stage.setAll (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s939.ffi).mlx.objs (PRE_first_tail_x15_r0_body.cwS106.filterMap fun i => (PRE_first_tail_x15_r0_body.cx1_106.mlx.objs.get i).map (i, ·))
kernel_rfl PRE_first_tail_x15_r0_body.f1N106 : PRE_first_tail_x15_r0_body.cx1_106.mlx.nodes = Stage.setAll (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s939.ffi).mlx.nodes (PRE_first_tail_x15_r0_body.cnS106.filterMap fun i => (PRE_first_tail_x15_r0_body.cx1_106.mlx.nodes.get i).map (i, ·))
kernel_rfl PRE_first_tail_x15_r0_body.f1I106 : PRE_first_tail_x15_r0_body.cx1_106.mlx.items = Stage.setAll (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s939.ffi).mlx.items (PRE_first_tail_x15_r0_body.ciS106.filterMap fun i => (PRE_first_tail_x15_r0_body.cx1_106.mlx.items.get i).map (i, ·))
kernel_rfl PRE_first_tail_x15_r0_body.fbd106 : (PRE_first_tail_x15_r0_body.clo106 ++ PRE_first_tail_x15_r0_body.cln106 ++ PRE_first_tail_x15_r0_body.cli106 ++ PRE_first_tail_x15_r0_body.cwS106 ++ PRE_first_tail_x15_r0_body.cnS106 ++ PRE_first_tail_x15_r0_body.ciS106).all (fun i => Nat.blt (i / 4096) (4 ^ 31)) = true
kernel_rfl PRE_first_tail_x15_r0_body.fincW106 : PRE_first_tail_x15_r0_body.cwS106.all (fun h => !Nat.blt h (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s939.ffi).mlx.next || PRE_first_tail_x15_r0_body.clo106.contains h) = true
kernel_rfl PRE_first_tail_x15_r0_body.fincI106 : PRE_first_tail_x15_r0_body.ciS106.all (fun k => !Nat.blt k (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s939.ffi).mlx.nnext || PRE_first_tail_x15_r0_body.cli106.contains k) = true
kernel_rfl PRE_first_tail_x15_r0_body.fincN106 : PRE_first_tail_x15_r0_body.cnS106.all (Nat.ble (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s939.ffi).mlx.nnext) = true
kernel_rfl PRE_first_tail_x15_r0_body.flnF106 : PRE_first_tail_x15_r0_body.cln106.all (Nat.ble (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s939.ffi).mlx.nnext) = true
-- the checks over the changed lists
kernel_rfl PRE_first_tail_x15_r0_body.fh106 : PRE_first_tail_x15_r0_body.clo106.all (handleOK PRE_first_tail_x15_r0_body.kappa106 PRE_first_tail_x15_r0_body.P106.lo PRE_first_tail_x15_r0_body.cx0_106.mlx PRE_first_tail_x15_r0_body.cx1_106.mlx) = true
kernel_rfl PRE_first_tail_x15_r0_body.fo106 : PRE_first_tail_x15_r0_body.clo106.map (fun h => PRE_first_tail_x15_r0_body.cx1_106.mlx.objs.get (PRE_first_tail_x15_r0_body.kappa106.handle h)) = PRE_first_tail_x15_r0_body.clo106.map (fun h => (PRE_first_tail_x15_r0_body.cx0_106.mlx.objs.get h).map PRE_first_tail_x15_r0_body.kappa106.nobj)
kernel_rfl PRE_first_tail_x15_r0_body.fok106 : PRE_first_tail_x15_r0_body.clo106.all (objOK PRE_first_tail_x15_r0_body.kappa106 PRE_first_tail_x15_r0_body.P106.NL PRE_first_tail_x15_r0_body.cx0_106.mlx) = true
kernel_rfl PRE_first_tail_x15_r0_body.fnd106 : PRE_first_tail_x15_r0_body.cln106.all (nodeOKF PRE_first_tail_x15_r0_body.kappa106 PRE_first_tail_x15_r0_body.P106 PRE_first_tail_x15_r0_body.cx0_106.mlx PRE_first_tail_x15_r0_body.cx1_106.mlx) = true
kernel_rfl PRE_first_tail_x15_r0_body.fp106 : ((PRE_first_tail_x15_r0_body.cln106.filter (fullB PRE_first_tail_x15_r0_body.P106))).map (fun i => (PRE_first_tail_x15_r0_body.cx1_106.mlx.nodes.get (PRE_first_tail_x15_r0_body.kappa106.node i)).map Host.Mlx.Ffi.Node.prim) =
  ((PRE_first_tail_x15_r0_body.cln106.filter (fullB PRE_first_tail_x15_r0_body.P106))).map (fun i => (PRE_first_tail_x15_r0_body.cx0_106.mlx.nodes.get i).map fun nd => PRE_first_tail_x15_r0_body.kappa106.prim nd.prim)
kernel_rfl PRE_first_tail_x15_r0_body.fnordI106 : incrB PRE_first_tail_x15_r0_body.kd106.nodeF (List.range' 17388 0) = true
kernel_rfl PRE_first_tail_x15_r0_body.fnordK106 : (PTrie.keysA PRE_first_tail_x15_r0_body.kd106.node).all (fun k => Nat.ble 17388 k && Nat.blt k 17388) = true
kernel_rfl PRE_first_tail_x15_r0_body.fnordL106 : (PRE_first_tail_x15_r0_body.cln106.filter (Nat.ble PRE_first_tail_x15_r0_body.P106.N0)).all (fun i => Nat.ble i (PRE_first_tail_x15_r0_body.kd106.nodeF i) && (Nat.blt i 17388 || Nat.ble PRE_first_tail_x15_r0_body.kd106.nn0 i)) = true
theorem PRE_first_tail_x15_r0_body.fnord106 : (PRE_first_tail_x15_r0_body.cln106.filter (Nat.ble PRE_first_tail_x15_r0_body.P106.N0)).all (fun i => Nat.ble i (PRE_first_tail_x15_r0_body.kd106.nodeF i) &&
    (PTrie.keysA PRE_first_tail_x15_r0_body.kd106.node).all fun j => !Nat.blt j i || Nat.blt (PRE_first_tail_x15_r0_body.kd106.nodeF j) (PRE_first_tail_x15_r0_body.kd106.nodeF i)) = true :=
  cnord_of PRE_first_tail_x15_r0_body.cnlow106 PRE_first_tail_x15_r0_body.cnn1106 PRE_first_tail_x15_r0_body.fnordI106 PRE_first_tail_x15_r0_body.fnordK106 PRE_first_tail_x15_r0_body.fnordL106
kernel_rfl PRE_first_tail_x15_r0_body.fi106 : PRE_first_tail_x15_r0_body.cli106.all (pnB PRE_first_tail_x15_r0_body.cx0_106.mlx) = true
kernel_rfl PRE_first_tail_x15_r0_body.fii106 : PRE_first_tail_x15_r0_body.cli106.all (fun k => decide (PRE_first_tail_x15_r0_body.cx1_106.mlx.items.get (PRE_first_tail_x15_r0_body.kappa106.node k) = (PRE_first_tail_x15_r0_body.cx0_106.mlx.items.get k).map PRE_first_tail_x15_r0_body.kappa106.nv)) = true
/-- **The compaction's footprint.** -/
theorem PRE_first_tail_x15_r0_body.cfoot106 (clean : Conv.NClean (⟨20298, 17388, 2758429, 4610⟩ : Conv.Cnt) (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s939.ffi).mlx) (hltC : ∀ h, PH (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s939.ffi).mlx h → h < (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s939.ffi).mlx.next) (nltC : ∀ i, PN (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s939.ffi).mlx i → i < (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s939.ffi).mlx.nnext) (itemsC : ∀ k v, (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s939.ffi).mlx.items.get k = some v → PN (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s939.ffi).mlx k) (tracedC : ∀ h o, (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s939.ffi).mlx.objs.get h = some o → ∀ i ∈ objTraces o, i < PRE_first_tail_x15_r0_body.P106.NL) (cl : SSt (· < 4610) PRE_first_tail_x15_r0_body.cx0_106.mlx) :
    Conv.MFoot PRE_first_tail_x15_r0_body.P106 4610 PRE_first_tail_x15_r0_body.kappa106 PRE_first_tail_x15_r0_body.kd106 PRE_first_tail_x15_r0_body.khinv106 PRE_first_tail_x15_r0_body.kninv106 (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s939.ffi).mlx PRE_first_tail_x15_r0_body.cx0_106.mlx PRE_first_tail_x15_r0_body.cx1_106.mlx (⟨20298, 17388, 2758429, 4610⟩ : Conv.Cnt) PRE_first_tail_x15_r0_body.clo106 PRE_first_tail_x15_r0_body.cln106 PRE_first_tail_x15_r0_body.cli106 PRE_first_tail_x15_r0_body.cwS106 PRE_first_tail_x15_r0_body.cnS106 PRE_first_tail_x15_r0_body.ciS106 :=
  ⟨rfl, rfl, rfl, PRE_first_tail_x15_r0_body.cnh0106, PRE_first_tail_x15_r0_body.cnh1106, PRE_first_tail_x15_r0_body.cnn0106, PRE_first_tail_x15_r0_body.cnn1106, PRE_first_tail_x15_r0_body.cplo106, PRE_first_tail_x15_r0_body.ccnt106, PRE_first_tail_x15_r0_body.cnband106, PRE_first_tail_x15_r0_body.chbelow106, PRE_first_tail_x15_r0_body.chren106, PRE_first_tail_x15_r0_body.cband106, PRE_first_tail_x15_r0_body.cnh1pos106, PRE_first_tail_x15_r0_body.cnren106, PRE_first_tail_x15_r0_body.cnlow106, PRE_first_tail_x15_r0_body.cabs0a106, PRE_first_tail_x15_r0_body.cabs0b106, PRE_first_tail_x15_r0_body.ctok1106, PRE_first_tail_x15_r0_body.cpend106, PRE_first_tail_x15_r0_body.cerrh106, PRE_first_tail_x15_r0_body.cfiles106, PRE_first_tail_x15_r0_body.carch106, PRE_first_tail_x15_r0_body.csizes106, PRE_first_tail_x15_r0_body.cwired106, PRE_first_tail_x15_r0_body.cfix106, clean, PRE_first_tail_x15_r0_body.fcxn106, PRE_first_tail_x15_r0_body.fcnn106, hltC, nltC, itemsC, tracedC, cl, PRE_first_tail_x15_r0_body.fle0106, PRE_first_tail_x15_r0_body.fnk106, PRE_first_tail_x15_r0_body.ckA106, PRE_first_tail_x15_r0_body.cobjsK106, PRE_first_tail_x15_r0_body.cnodesK106, PRE_first_tail_x15_r0_body.citemsK106, PRE_first_tail_x15_r0_body.f1A106, PRE_first_tail_x15_r0_body.f1O106, PRE_first_tail_x15_r0_body.f1N106, PRE_first_tail_x15_r0_body.f1I106, PRE_first_tail_x15_r0_body.fbd106, PRE_first_tail_x15_r0_body.fincW106, PRE_first_tail_x15_r0_body.fincI106, PRE_first_tail_x15_r0_body.fincN106, PRE_first_tail_x15_r0_body.flnF106, PRE_first_tail_x15_r0_body.fh106, PRE_first_tail_x15_r0_body.fo106, PRE_first_tail_x15_r0_body.fok106, PRE_first_tail_x15_r0_body.fnd106, PRE_first_tail_x15_r0_body.fp106, PRE_first_tail_x15_r0_body.fnord106, PRE_first_tail_x15_r0_body.fi106, PRE_first_tail_x15_r0_body.fii106⟩
theorem PRE_first_tail_x15_r0_body.cnshift106 (clean : Conv.NClean (⟨20298, 17388, 2758429, 4610⟩ : Conv.Cnt) (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s939.ffi).mlx) (hltC : ∀ h, PH (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s939.ffi).mlx h → h < (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s939.ffi).mlx.next) (nltC : ∀ i, PN (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s939.ffi).mlx i → i < (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s939.ffi).mlx.nnext) (itemsC : ∀ k v, (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s939.ffi).mlx.items.get k = some v → PN (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s939.ffi).mlx k) (tracedC : ∀ h o, (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s939.ffi).mlx.objs.get h = some o → ∀ i ∈ objTraces o, i < PRE_first_tail_x15_r0_body.P106.NL) (cl : SSt (· < 4610) PRE_first_tail_x15_r0_body.cx0_106.mlx) : NShift PRE_first_tail_x15_r0_body.P106 4610 PRE_first_tail_x15_r0_body.kappa106 PRE_first_tail_x15_r0_body.cx0_106 PRE_first_tail_x15_r0_body.cx1_106 :=
  Conv.nshift_of_foot (PRE_first_tail_x15_r0_body.cfoot106 clean hltC nltC itemsC tracedC cl) PRE_first_tail_x15_r0_body.chost106 (compact_a_eq PRE_first_tail_x15_r0_body.ckn0106 PRE_first_tail_x15_r0_body.ckn1106 PRE_first_tail_x15_r0_body.ckheap106 PRE_first_tail_x15_r0_body.ckpl106)

-- the observers: the layers' states at the call, the canonical and the merged state, their footprints and checks
noncomputable def PRE_first_tail_x15_r0_body.fxC_106 : PTrie Unit := (Host.Ts.Sim.Full.freedOf PRE_first_tail_x15_r0_body.s939.ffi).getD PTrie.nil
noncomputable def PRE_first_tail_x15_r0_body.krC_106 : Host.Load.Layers.KRec := (Host.Ts.Sim.Full.krecOf PRE_first_tail_x15_r0_body.s939.ffi).getD Host.Load.Layers.KRec.empty
kernel_rfl PRE_first_tail_x15_r0_body.ofxC_106 : (Host.Ts.Sim.Full.freedOf PRE_first_tail_x15_r0_body.s939.ffi) = some PRE_first_tail_x15_r0_body.fxC_106
kernel_rfl PRE_first_tail_x15_r0_body.okrC_106 : (Host.Ts.Sim.Full.krecOf PRE_first_tail_x15_r0_body.s939.ffi) = some PRE_first_tail_x15_r0_body.krC_106
noncomputable def PRE_first_tail_x15_r0_body.fx0_106 : PTrie Unit := (Host.Ts.Sim.Full.freedOf PRE_first_tail_x15_r0_body.s941.ffi).getD PTrie.nil
noncomputable def PRE_first_tail_x15_r0_body.kr0_106 : Host.Load.Layers.KRec := (Host.Ts.Sim.Full.krecOf PRE_first_tail_x15_r0_body.s941.ffi).getD Host.Load.Layers.KRec.empty
kernel_rfl PRE_first_tail_x15_r0_body.ofx0_106 : (Host.Ts.Sim.Full.freedOf PRE_first_tail_x15_r0_body.s941.ffi) = some PRE_first_tail_x15_r0_body.fx0_106
kernel_rfl PRE_first_tail_x15_r0_body.okr0_106 : (Host.Ts.Sim.Full.krecOf PRE_first_tail_x15_r0_body.s941.ffi) = some PRE_first_tail_x15_r0_body.kr0_106
noncomputable def PRE_first_tail_x15_r0_body.fx1_106 : PTrie Unit := (Host.Ts.Sim.Full.freedOf PRE_first_tail_x15_r0_body.s940.ffi).getD PTrie.nil
noncomputable def PRE_first_tail_x15_r0_body.kr1_106 : Host.Load.Layers.KRec := (Host.Ts.Sim.Full.krecOf PRE_first_tail_x15_r0_body.s940.ffi).getD Host.Load.Layers.KRec.empty
kernel_rfl PRE_first_tail_x15_r0_body.ofx1_106 : (Host.Ts.Sim.Full.freedOf PRE_first_tail_x15_r0_body.s940.ffi) = some PRE_first_tail_x15_r0_body.fx1_106
kernel_rfl PRE_first_tail_x15_r0_body.okr1_106 : (Host.Ts.Sim.Full.krecOf PRE_first_tail_x15_r0_body.s940.ffi) = some PRE_first_tail_x15_r0_body.kr1_106
kernel_rfl PRE_first_tail_x15_r0_body.ff0106 : PRE_first_tail_x15_r0_body.fx0_106 = Stage.setAll PRE_first_tail_x15_r0_body.fxC_106 (PRE_first_tail_x15_r0_body.clo106.filterMap fun i => (PRE_first_tail_x15_r0_body.fx0_106.get i).map (i, ·))
kernel_rfl PRE_first_tail_x15_r0_body.ff1106 : PRE_first_tail_x15_r0_body.fx1_106 = Stage.setAll PRE_first_tail_x15_r0_body.fxC_106 (PRE_first_tail_x15_r0_body.cwS106.filterMap fun i => (PRE_first_tail_x15_r0_body.fx1_106.get i).map (i, ·))
kernel_rfl PRE_first_tail_x15_r0_body.ffck106 : freedLB PRE_first_tail_x15_r0_body.kappa106 PRE_first_tail_x15_r0_body.cx0_106.mlx PRE_first_tail_x15_r0_body.fx0_106 PRE_first_tail_x15_r0_body.fx1_106 PRE_first_tail_x15_r0_body.clo106 = true
kernel_rfl PRE_first_tail_x15_r0_body.fkf0106 : PRE_first_tail_x15_r0_body.kr0_106.flags = Stage.setAll PRE_first_tail_x15_r0_body.krC_106.flags (PRE_first_tail_x15_r0_body.clo106.filterMap fun i => (PRE_first_tail_x15_r0_body.kr0_106.flags.get i).map (i, ·))
kernel_rfl PRE_first_tail_x15_r0_body.fkt0106 : PRE_first_tail_x15_r0_body.kr0_106.targs = Stage.setAll PRE_first_tail_x15_r0_body.krC_106.targs (PRE_first_tail_x15_r0_body.clo106.filterMap fun i => (PRE_first_tail_x15_r0_body.kr0_106.targs.get i).map (i, ·))
kernel_rfl PRE_first_tail_x15_r0_body.fkf1106 : PRE_first_tail_x15_r0_body.kr1_106.flags = Stage.setAll PRE_first_tail_x15_r0_body.krC_106.flags (PRE_first_tail_x15_r0_body.cwS106.filterMap fun i => (PRE_first_tail_x15_r0_body.kr1_106.flags.get i).map (i, ·))
kernel_rfl PRE_first_tail_x15_r0_body.fkt1106 : PRE_first_tail_x15_r0_body.kr1_106.targs = Stage.setAll PRE_first_tail_x15_r0_body.krC_106.targs (PRE_first_tail_x15_r0_body.cwS106.filterMap fun i => (PRE_first_tail_x15_r0_body.kr1_106.targs.get i).map (i, ·))
kernel_rfl PRE_first_tail_x15_r0_body.fkck106 : krecLB PRE_first_tail_x15_r0_body.kappa106 4610 PRE_first_tail_x15_r0_body.cx0_106.mlx PRE_first_tail_x15_r0_body.kr0_106 PRE_first_tail_x15_r0_body.kr1_106 PRE_first_tail_x15_r0_body.clo106 = true
kernel_rfl PRE_first_tail_x15_r0_body.fkn106 : Nat.ble 4610 4610 = true
-- the bridge and the pending traces' regions
kernel_rfl PRE_first_tail_x15_r0_body.cbridge106 : Host.Ts.Sim.Full.bridgeOf PRE_first_tail_x15_r0_body.s940.ffi = Host.Ts.Sim.Full.bridgeOf PRE_first_tail_x15_r0_body.s941.ffi
kernel_rfl PRE_first_tail_x15_r0_body.cpendR106 : pendRegB PRE_first_tail_x15_r0_body.kappa106 (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s941.ffi).mlx = true
kernel_rfl PRE_first_tail_x15_r0_body.cpendLe106 : Nat.ble (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s941.ffi).mlx.next (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s940.ffi).mlx.next = true
/-- **The compaction's native shift**, given the call's bookkeeping, its relation's facts (the model's and the
observers') and the canonical closedness. -/
theorem PRE_first_tail_x15_r0_body.cshift106 (clean : Conv.NClean (⟨20298, 17388, 2758429, 4610⟩ : Conv.Cnt) (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s939.ffi).mlx) (hltC : ∀ h, PH (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s939.ffi).mlx h → h < (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s939.ffi).mlx.next) (nltC : ∀ i, PN (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s939.ffi).mlx i → i < (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s939.ffi).mlx.nnext) (itemsC : ∀ k v, (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s939.ffi).mlx.items.get k = some v → PN (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s939.ffi).mlx k) (tracedC : ∀ h o, (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s939.ffi).mlx.objs.get h = some o → ∀ i ∈ objTraces o, i < PRE_first_tail_x15_r0_body.P106.NL) (cl : SSt (· < 4610) PRE_first_tail_x15_r0_body.cx0_106.mlx)
    (hobjC : ∀ h, PRE_first_tail_x15_r0_body.fxC_106.get h = some () → ((Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s939.ffi).mlx.objs.get h).isSome = true)
    (hfC : ∀ h, (PRE_first_tail_x15_r0_body.krC_106.flags.get h).isSome = true → ((Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s939.ffi).mlx.objs.get h).isSome = true)
    (htC : ∀ h, (PRE_first_tail_x15_r0_body.krC_106.targs.get h).isSome = true → ((Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s939.ffi).mlx.objs.get h).isSome = true)
    (hclC : ∀ h l, PRE_first_tail_x15_r0_body.krC_106.targs.get h = some l → Host.Ts.Sim.Full.STargs (· < (⟨20298, 17388, 2758429, 4610⟩ : Conv.Cnt).n) l) :
    Conv.FullShiftQ PRE_first_tail_x15_r0_body.P106 4610 PRE_first_tail_x15_r0_body.kappa106 PRE_first_tail_x15_r0_body.s941.ffi PRE_first_tail_x15_r0_body.s940.ffi :=
  ⟨PRE_first_tail_x15_r0_body.cnshift106 clean hltC nltC itemsC tracedC cl, PRE_first_tail_x15_r0_body.cqueue106, fun t ht => bSN_sound (List.all_eq_true.mp PRE_first_tail_x15_r0_body.ctokSupp106 t ht),
    PRE_first_tail_x15_r0_body.cbridge106,
    liveShift_foot (x0' := Host.Ts.Sim.Full.mlxOf PRE_first_tail_x15_r0_body.s941.ffi) (x1' := Host.Ts.Sim.Full.mlxOf PRE_first_tail_x15_r0_body.s940.ffi) (PRE_first_tail_x15_r0_body.cfoot106 clean hltC nltC itemsC tracedC cl) rfl PRE_first_tail_x15_r0_body.ofx0_106 PRE_first_tail_x15_r0_body.ofx1_106 hobjC PRE_first_tail_x15_r0_body.ff0106 PRE_first_tail_x15_r0_body.ff1106 PRE_first_tail_x15_r0_body.ffck106,
    kernShift_foot (x0' := Host.Ts.Sim.Full.mlxOf PRE_first_tail_x15_r0_body.s941.ffi) (x1' := Host.Ts.Sim.Full.mlxOf PRE_first_tail_x15_r0_body.s940.ffi) (PRE_first_tail_x15_r0_body.cfoot106 clean hltC nltC itemsC tracedC cl) rfl PRE_first_tail_x15_r0_body.okr0_106 PRE_first_tail_x15_r0_body.okr1_106 (Nat.le_of_ble_eq_true PRE_first_tail_x15_r0_body.fkn106) hfC htC hclC
      PRE_first_tail_x15_r0_body.fkf0106 PRE_first_tail_x15_r0_body.fkt0106 PRE_first_tail_x15_r0_body.fkf1106 PRE_first_tail_x15_r0_body.fkt1106 PRE_first_tail_x15_r0_body.fkck106,
    pendReg_of rfl PRE_first_tail_x15_r0_body.cnh0106 PRE_first_tail_x15_r0_body.cnh1106 (Nat.le_of_ble_eq_true PRE_first_tail_x15_r0_body.cpendLe106) PRE_first_tail_x15_r0_body.cpendR106⟩

end Host.Load.Run.Tpl
