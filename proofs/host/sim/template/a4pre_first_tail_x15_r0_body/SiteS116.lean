import host.sim.template.a4pre_first_tail_x15_r0_body.SiteCl116
import host.sim.conv.CompactFull
import host.sim.template.FootGen
set_option Elab.async false
namespace Host.Load.Run.Tpl
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
open Host.Ts Host.Ts.Sim Host.Ts.Sim.Template

/-! The compaction's native shift at call site 116 from its footprint (`Conv.nshift_of_foot`), and the observers'
(`liveShift_foot`, `kernShift_foot`): `Conv.FullShiftQ` for `Conv.full_compactQ`, given the call's bookkeeping and its
relation's facts. -/

/-- The load parameters of the chain (band-free: its start's node counter as `NL` and `N0`). -/
def PRE_first_tail_x15_r0_body.Pc116 : LoadP := ⟨18151, 131072, 1099511627776, 15235, 15235, []⟩
/-- The site's band raised to the map's checked fixed-node prefix, including newly recorded closure traces. -/
def PRE_first_tail_x15_r0_body.P116 : LoadP := PRE_first_tail_x15_r0_body.Pc116.raise 17581
kernel_rfl PRE_first_tail_x15_r0_body.craise116 : Nat.ble PRE_first_tail_x15_r0_body.Pc116.N0 17581 = true
theorem PRE_first_tail_x15_r0_body.raised116 : Host.Ts.Sim.Full.Raised PRE_first_tail_x15_r0_body.Pc116 PRE_first_tail_x15_r0_body.P116 :=
  .inr ⟨17581, rfl, Nat.le_of_ble_eq_true PRE_first_tail_x15_r0_body.craise116, rfl⟩
noncomputable abbrev PRE_first_tail_x15_r0_body.cx0_116 : Host.Load.LSt := clearTokens (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1123.ffi)
noncomputable abbrev PRE_first_tail_x15_r0_body.cx1_116 : Host.Load.LSt := clearTokens (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1122.ffi)
def PRE_first_tail_x15_r0_body.khinv116 : PTrie Nat := Stage.setAll PTrie.nil []
def PRE_first_tail_x15_r0_body.kninv116 : PTrie Nat := Stage.setAll PTrie.nil []
/-- The stage's footprint: its written and fresh handles, fresh nodes, written and fresh items. -/
def PRE_first_tail_x15_r0_body.cwS116 : List Nat := []
def PRE_first_tail_x15_r0_body.cnS116 : List Nat := List.range' 17581 0
def PRE_first_tail_x15_r0_body.ciS116 : List Nat := [] ++ List.range' 17581 0

-- the small checks (`MChecks`'s)
kernel_rfl PRE_first_tail_x15_r0_body.cnh0116 : PRE_first_tail_x15_r0_body.kd116.nh0 = PRE_first_tail_x15_r0_body.cx0_116.mlx.next
kernel_rfl PRE_first_tail_x15_r0_body.cnh1116 : PRE_first_tail_x15_r0_body.kd116.nh1 = PRE_first_tail_x15_r0_body.cx1_116.mlx.next
kernel_rfl PRE_first_tail_x15_r0_body.cnn0116 : PRE_first_tail_x15_r0_body.kd116.nn0 = PRE_first_tail_x15_r0_body.cx0_116.mlx.nnext
kernel_rfl PRE_first_tail_x15_r0_body.cnn1116 : PRE_first_tail_x15_r0_body.kd116.nn1 = PRE_first_tail_x15_r0_body.cx1_116.mlx.nnext
kernel_rfl PRE_first_tail_x15_r0_body.cplo116 : (Nat.blt 0 PRE_first_tail_x15_r0_body.P116.lo && Nat.ble PRE_first_tail_x15_r0_body.P116.lo PRE_first_tail_x15_r0_body.cx0_116.mlx.next && Nat.ble PRE_first_tail_x15_r0_body.P116.lo RData.bigHi && Nat.ble RData.bigHi PRE_first_tail_x15_r0_body.P116.E) = true
kernel_rfl PRE_first_tail_x15_r0_body.ccnt116 : (Nat.ble PRE_first_tail_x15_r0_body.cx0_116.mlx.next PRE_first_tail_x15_r0_body.cx1_116.mlx.next && Nat.ble PRE_first_tail_x15_r0_body.cx0_116.mlx.nnext PRE_first_tail_x15_r0_body.cx1_116.mlx.nnext) = true
kernel_rfl PRE_first_tail_x15_r0_body.cnband116 : (Nat.blt 0 PRE_first_tail_x15_r0_body.P116.NL && Nat.ble PRE_first_tail_x15_r0_body.P116.NL PRE_first_tail_x15_r0_body.P116.N0 && Nat.ble PRE_first_tail_x15_r0_body.P116.N0 PRE_first_tail_x15_r0_body.cx0_116.mlx.nnext) = true
kernel_rfl PRE_first_tail_x15_r0_body.chbelow116 : PRE_first_tail_x15_r0_body.kd116.checkHndBelow = true
kernel_rfl PRE_first_tail_x15_r0_body.chren116 : checkRenG PRE_first_tail_x15_r0_body.kd116.hnd PRE_first_tail_x15_r0_body.khinv116 (phB PRE_first_tail_x15_r0_body.cx0_116.mlx) = true
kernel_rfl PRE_first_tail_x15_r0_body.cband116 : PRE_first_tail_x15_r0_body.kd116.checkBand PRE_first_tail_x15_r0_body.P116.lo = true
kernel_rfl PRE_first_tail_x15_r0_body.cnh1pos116 : Nat.blt 0 PRE_first_tail_x15_r0_body.kd116.nh1 = true
kernel_rfl PRE_first_tail_x15_r0_body.cnren116 : checkRenG PRE_first_tail_x15_r0_body.kd116.node PRE_first_tail_x15_r0_body.kninv116 (pnB PRE_first_tail_x15_r0_body.cx0_116.mlx) = true
kernel_rfl PRE_first_tail_x15_r0_body.cnlow116 : (PTrie.keysA PRE_first_tail_x15_r0_body.kd116.node).all (fun j => Nat.ble PRE_first_tail_x15_r0_body.P116.NL j && Nat.blt (PRE_first_tail_x15_r0_body.kd116.nodeF j) PRE_first_tail_x15_r0_body.cx1_116.mlx.nnext) = true
kernel_rfl PRE_first_tail_x15_r0_body.cabs0a116 : PRE_first_tail_x15_r0_body.cx0_116.mlx.arrs.get 0 = none
kernel_rfl PRE_first_tail_x15_r0_body.cabs0b116 : PRE_first_tail_x15_r0_body.cx0_116.mlx.objs.get 0 = none
kernel_rfl PRE_first_tail_x15_r0_body.ctok1116 : PRE_first_tail_x15_r0_body.cx1_116.mlx.tokens = []
kernel_rfl PRE_first_tail_x15_r0_body.cpend116 : PRE_first_tail_x15_r0_body.cx1_116.mlx.pending = PRE_first_tail_x15_r0_body.cx0_116.mlx.pending.map PRE_first_tail_x15_r0_body.kappa116.pend
kernel_rfl PRE_first_tail_x15_r0_body.cerrh116 : PRE_first_tail_x15_r0_body.cx1_116.mlx.errh = PRE_first_tail_x15_r0_body.cx0_116.mlx.errh.map PRE_first_tail_x15_r0_body.kappa116.arg
kernel_rfl PRE_first_tail_x15_r0_body.cfiles116 : PRE_first_tail_x15_r0_body.cx1_116.mlx.files = PRE_first_tail_x15_r0_body.cx0_116.mlx.files
kernel_rfl PRE_first_tail_x15_r0_body.carch116 : PRE_first_tail_x15_r0_body.cx1_116.mlx.arch = PRE_first_tail_x15_r0_body.cx0_116.mlx.arch
kernel_rfl PRE_first_tail_x15_r0_body.csizes116 : PRE_first_tail_x15_r0_body.cx1_116.mlx.deviceSizes = PRE_first_tail_x15_r0_body.cx0_116.mlx.deviceSizes
kernel_rfl PRE_first_tail_x15_r0_body.cwired116 : PRE_first_tail_x15_r0_body.cx1_116.mlx.wired = PRE_first_tail_x15_r0_body.cx0_116.mlx.wired
kernel_rfl PRE_first_tail_x15_r0_body.chost116 : PRE_first_tail_x15_r0_body.cx1_116.host = PRE_first_tail_x15_r0_body.cx0_116.host
-- the compaction map's addresses are `PRE_first_tail_x15_r0_body.kd116`'s
kernel_rfl PRE_first_tail_x15_r0_body.ckn0116 : PRE_first_tail_x15_r0_body.kd116.n0 = 2765508
kernel_rfl PRE_first_tail_x15_r0_body.ckn1116 : PRE_first_tail_x15_r0_body.kd116.n1 = 2765518
kernel_rfl PRE_first_tail_x15_r0_body.ckheap116 : (PTrie.keysA PRE_first_tail_x15_r0_body.kd116.heap).all (fun x => Nat.ble 2765507 x) = true
kernel_rfl PRE_first_tail_x15_r0_body.ckpl116 : (List.range 1).all (fun j => decide (PRE_first_tail_x15_r0_body.kd116.heap.get (2765507 + j) = nth? PRE_first_tail_x15_r0_body.pl116 j)) = true
-- the map fixes the call's names (`Conv.fixOld_compact`), the call's counters
kernel_rfl PRE_first_tail_x15_r0_body.fja116 : Nat.ble 2765507 2765507 = true
kernel_rfl PRE_first_tail_x15_r0_body.fn116 : Nat.ble 5014 5014 = true
kernel_rfl PRE_first_tail_x15_r0_body.fjaD116 : Nat.ble 2765507 PRE_first_tail_x15_r0_body.kd116.n0 = true
kernel_rfl PRE_first_tail_x15_r0_body.fxn116 : Nat.ble 20477 PRE_first_tail_x15_r0_body.kd116.nh0 = true
kernel_rfl PRE_first_tail_x15_r0_body.fnn116 : Nat.ble 17581 PRE_first_tail_x15_r0_body.kd116.nn0 = true
kernel_rfl PRE_first_tail_x15_r0_body.fxb116 : Nat.ble 20477 RData.bigHi = true
kernel_rfl PRE_first_tail_x15_r0_body.fheap116 : (PTrie.keysA PRE_first_tail_x15_r0_body.kd116.heap).all (Nat.ble (⟨20477, 17581, 2765507, 5014⟩ : Conv.Cnt).ja) = true
kernel_rfl PRE_first_tail_x15_r0_body.fhnd116 : (PTrie.keysA PRE_first_tail_x15_r0_body.kd116.hnd).all (Nat.ble (⟨20477, 17581, 2765507, 5014⟩ : Conv.Cnt).xn) = true
kernel_rfl PRE_first_tail_x15_r0_body.fnode116 : (PTrie.keysA PRE_first_tail_x15_r0_body.kd116.node).all (Nat.ble (⟨20477, 17581, 2765507, 5014⟩ : Conv.Cnt).nn) = true
/-- The compaction map fixes the call's names. -/
theorem PRE_first_tail_x15_r0_body.cfix116 : Conv.FixOld (⟨20477, 17581, 2765507, 5014⟩ : Conv.Cnt) PRE_first_tail_x15_r0_body.kappa116 :=
  Conv.fixOld_compact (Nat.le_of_ble_eq_true PRE_first_tail_x15_r0_body.fja116) (Nat.le_of_ble_eq_true PRE_first_tail_x15_r0_body.fn116) (Nat.le_of_ble_eq_true PRE_first_tail_x15_r0_body.fjaD116) (Nat.le_of_ble_eq_true PRE_first_tail_x15_r0_body.fxn116) (Nat.le_of_ble_eq_true PRE_first_tail_x15_r0_body.fnn116) (Nat.le_of_ble_eq_true PRE_first_tail_x15_r0_body.fxb116) PRE_first_tail_x15_r0_body.fheap116 PRE_first_tail_x15_r0_body.fhnd116 PRE_first_tail_x15_r0_body.fnode116
kernel_rfl PRE_first_tail_x15_r0_body.fcxn116 : (⟨20477, 17581, 2765507, 5014⟩ : Conv.Cnt).xn = (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1121.ffi).mlx.next
kernel_rfl PRE_first_tail_x15_r0_body.fcnn116 : (⟨20477, 17581, 2765507, 5014⟩ : Conv.Cnt).nn = (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1121.ffi).mlx.nnext
kernel_rfl PRE_first_tail_x15_r0_body.fle0116 : (Nat.ble (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1121.ffi).mlx.next PRE_first_tail_x15_r0_body.cx0_116.mlx.next && Nat.ble (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1121.ffi).mlx.nnext PRE_first_tail_x15_r0_body.cx0_116.mlx.nnext && Nat.ble (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1121.ffi).mlx.next RData.bigHi) = true
kernel_rfl PRE_first_tail_x15_r0_body.fnk116 : (PTrie.keysA PRE_first_tail_x15_r0_body.kd116.node).all (Nat.ble (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1121.ffi).mlx.nnext) = true
-- the merged state keeps the call's entries off the stage's footprint
kernel_rfl PRE_first_tail_x15_r0_body.f1A116 : PRE_first_tail_x15_r0_body.cx1_116.mlx.arrs = Stage.setAll (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1121.ffi).mlx.arrs (PRE_first_tail_x15_r0_body.cwS116.filterMap fun i => (PRE_first_tail_x15_r0_body.cx1_116.mlx.arrs.get i).map (i, ·))
kernel_rfl PRE_first_tail_x15_r0_body.f1O116 : PRE_first_tail_x15_r0_body.cx1_116.mlx.objs = Stage.setAll (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1121.ffi).mlx.objs (PRE_first_tail_x15_r0_body.cwS116.filterMap fun i => (PRE_first_tail_x15_r0_body.cx1_116.mlx.objs.get i).map (i, ·))
kernel_rfl PRE_first_tail_x15_r0_body.f1N116 : PRE_first_tail_x15_r0_body.cx1_116.mlx.nodes = Stage.setAll (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1121.ffi).mlx.nodes (PRE_first_tail_x15_r0_body.cnS116.filterMap fun i => (PRE_first_tail_x15_r0_body.cx1_116.mlx.nodes.get i).map (i, ·))
kernel_rfl PRE_first_tail_x15_r0_body.f1I116 : PRE_first_tail_x15_r0_body.cx1_116.mlx.items = Stage.setAll (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1121.ffi).mlx.items (PRE_first_tail_x15_r0_body.ciS116.filterMap fun i => (PRE_first_tail_x15_r0_body.cx1_116.mlx.items.get i).map (i, ·))
kernel_rfl PRE_first_tail_x15_r0_body.fbd116 : (PRE_first_tail_x15_r0_body.clo116 ++ PRE_first_tail_x15_r0_body.cln116 ++ PRE_first_tail_x15_r0_body.cli116 ++ PRE_first_tail_x15_r0_body.cwS116 ++ PRE_first_tail_x15_r0_body.cnS116 ++ PRE_first_tail_x15_r0_body.ciS116).all (fun i => Nat.blt (i / 4096) (4 ^ 31)) = true
kernel_rfl PRE_first_tail_x15_r0_body.fincW116 : PRE_first_tail_x15_r0_body.cwS116.all (fun h => !Nat.blt h (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1121.ffi).mlx.next || PRE_first_tail_x15_r0_body.clo116.contains h) = true
kernel_rfl PRE_first_tail_x15_r0_body.fincI116 : PRE_first_tail_x15_r0_body.ciS116.all (fun k => !Nat.blt k (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1121.ffi).mlx.nnext || PRE_first_tail_x15_r0_body.cli116.contains k) = true
kernel_rfl PRE_first_tail_x15_r0_body.fincN116 : PRE_first_tail_x15_r0_body.cnS116.all (Nat.ble (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1121.ffi).mlx.nnext) = true
kernel_rfl PRE_first_tail_x15_r0_body.flnF116 : PRE_first_tail_x15_r0_body.cln116.all (Nat.ble (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1121.ffi).mlx.nnext) = true
-- the checks over the changed lists
kernel_rfl PRE_first_tail_x15_r0_body.fh116 : PRE_first_tail_x15_r0_body.clo116.all (handleOK PRE_first_tail_x15_r0_body.kappa116 PRE_first_tail_x15_r0_body.P116.lo PRE_first_tail_x15_r0_body.cx0_116.mlx PRE_first_tail_x15_r0_body.cx1_116.mlx) = true
kernel_rfl PRE_first_tail_x15_r0_body.fo116 : PRE_first_tail_x15_r0_body.clo116.map (fun h => PRE_first_tail_x15_r0_body.cx1_116.mlx.objs.get (PRE_first_tail_x15_r0_body.kappa116.handle h)) = PRE_first_tail_x15_r0_body.clo116.map (fun h => (PRE_first_tail_x15_r0_body.cx0_116.mlx.objs.get h).map PRE_first_tail_x15_r0_body.kappa116.nobj)
kernel_rfl PRE_first_tail_x15_r0_body.fok116 : PRE_first_tail_x15_r0_body.clo116.all (objOK PRE_first_tail_x15_r0_body.kappa116 PRE_first_tail_x15_r0_body.P116.NL PRE_first_tail_x15_r0_body.cx0_116.mlx) = true
kernel_rfl PRE_first_tail_x15_r0_body.fnd116 : PRE_first_tail_x15_r0_body.cln116.all (nodeOKF PRE_first_tail_x15_r0_body.kappa116 PRE_first_tail_x15_r0_body.P116 PRE_first_tail_x15_r0_body.cx0_116.mlx PRE_first_tail_x15_r0_body.cx1_116.mlx) = true
kernel_rfl PRE_first_tail_x15_r0_body.fp116 : ((PRE_first_tail_x15_r0_body.cln116.filter (fullB PRE_first_tail_x15_r0_body.P116))).map (fun i => (PRE_first_tail_x15_r0_body.cx1_116.mlx.nodes.get (PRE_first_tail_x15_r0_body.kappa116.node i)).map Host.Mlx.Ffi.Node.prim) =
  ((PRE_first_tail_x15_r0_body.cln116.filter (fullB PRE_first_tail_x15_r0_body.P116))).map (fun i => (PRE_first_tail_x15_r0_body.cx0_116.mlx.nodes.get i).map fun nd => PRE_first_tail_x15_r0_body.kappa116.prim nd.prim)
kernel_rfl PRE_first_tail_x15_r0_body.fnordI116 : incrB PRE_first_tail_x15_r0_body.kd116.nodeF (List.range' 17581 0) = true
kernel_rfl PRE_first_tail_x15_r0_body.fnordK116 : (PTrie.keysA PRE_first_tail_x15_r0_body.kd116.node).all (fun k => Nat.ble 17581 k && Nat.blt k 17581) = true
kernel_rfl PRE_first_tail_x15_r0_body.fnordL116 : (PRE_first_tail_x15_r0_body.cln116.filter (Nat.ble PRE_first_tail_x15_r0_body.P116.N0)).all (fun i => Nat.ble i (PRE_first_tail_x15_r0_body.kd116.nodeF i) && (Nat.blt i 17581 || Nat.ble PRE_first_tail_x15_r0_body.kd116.nn0 i)) = true
theorem PRE_first_tail_x15_r0_body.fnord116 : (PRE_first_tail_x15_r0_body.cln116.filter (Nat.ble PRE_first_tail_x15_r0_body.P116.N0)).all (fun i => Nat.ble i (PRE_first_tail_x15_r0_body.kd116.nodeF i) &&
    (PTrie.keysA PRE_first_tail_x15_r0_body.kd116.node).all fun j => !Nat.blt j i || Nat.blt (PRE_first_tail_x15_r0_body.kd116.nodeF j) (PRE_first_tail_x15_r0_body.kd116.nodeF i)) = true :=
  cnord_of PRE_first_tail_x15_r0_body.cnlow116 PRE_first_tail_x15_r0_body.cnn1116 PRE_first_tail_x15_r0_body.fnordI116 PRE_first_tail_x15_r0_body.fnordK116 PRE_first_tail_x15_r0_body.fnordL116
kernel_rfl PRE_first_tail_x15_r0_body.fi116 : PRE_first_tail_x15_r0_body.cli116.all (pnB PRE_first_tail_x15_r0_body.cx0_116.mlx) = true
kernel_rfl PRE_first_tail_x15_r0_body.fii116 : PRE_first_tail_x15_r0_body.cli116.all (fun k => decide (PRE_first_tail_x15_r0_body.cx1_116.mlx.items.get (PRE_first_tail_x15_r0_body.kappa116.node k) = (PRE_first_tail_x15_r0_body.cx0_116.mlx.items.get k).map PRE_first_tail_x15_r0_body.kappa116.nv)) = true
/-- **The compaction's footprint.** -/
theorem PRE_first_tail_x15_r0_body.cfoot116 (clean : Conv.NClean (⟨20477, 17581, 2765507, 5014⟩ : Conv.Cnt) (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1121.ffi).mlx) (hltC : ∀ h, PH (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1121.ffi).mlx h → h < (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1121.ffi).mlx.next) (nltC : ∀ i, PN (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1121.ffi).mlx i → i < (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1121.ffi).mlx.nnext) (itemsC : ∀ k v, (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1121.ffi).mlx.items.get k = some v → PN (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1121.ffi).mlx k) (tracedC : ∀ h o, (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1121.ffi).mlx.objs.get h = some o → ∀ i ∈ objTraces o, i < PRE_first_tail_x15_r0_body.P116.NL) (cl : SSt (· < 5014) PRE_first_tail_x15_r0_body.cx0_116.mlx) :
    Conv.MFoot PRE_first_tail_x15_r0_body.P116 5014 PRE_first_tail_x15_r0_body.kappa116 PRE_first_tail_x15_r0_body.kd116 PRE_first_tail_x15_r0_body.khinv116 PRE_first_tail_x15_r0_body.kninv116 (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1121.ffi).mlx PRE_first_tail_x15_r0_body.cx0_116.mlx PRE_first_tail_x15_r0_body.cx1_116.mlx (⟨20477, 17581, 2765507, 5014⟩ : Conv.Cnt) PRE_first_tail_x15_r0_body.clo116 PRE_first_tail_x15_r0_body.cln116 PRE_first_tail_x15_r0_body.cli116 PRE_first_tail_x15_r0_body.cwS116 PRE_first_tail_x15_r0_body.cnS116 PRE_first_tail_x15_r0_body.ciS116 :=
  ⟨rfl, rfl, rfl, PRE_first_tail_x15_r0_body.cnh0116, PRE_first_tail_x15_r0_body.cnh1116, PRE_first_tail_x15_r0_body.cnn0116, PRE_first_tail_x15_r0_body.cnn1116, PRE_first_tail_x15_r0_body.cplo116, PRE_first_tail_x15_r0_body.ccnt116, PRE_first_tail_x15_r0_body.cnband116, PRE_first_tail_x15_r0_body.chbelow116, PRE_first_tail_x15_r0_body.chren116, PRE_first_tail_x15_r0_body.cband116, PRE_first_tail_x15_r0_body.cnh1pos116, PRE_first_tail_x15_r0_body.cnren116, PRE_first_tail_x15_r0_body.cnlow116, PRE_first_tail_x15_r0_body.cabs0a116, PRE_first_tail_x15_r0_body.cabs0b116, PRE_first_tail_x15_r0_body.ctok1116, PRE_first_tail_x15_r0_body.cpend116, PRE_first_tail_x15_r0_body.cerrh116, PRE_first_tail_x15_r0_body.cfiles116, PRE_first_tail_x15_r0_body.carch116, PRE_first_tail_x15_r0_body.csizes116, PRE_first_tail_x15_r0_body.cwired116, PRE_first_tail_x15_r0_body.cfix116, clean, PRE_first_tail_x15_r0_body.fcxn116, PRE_first_tail_x15_r0_body.fcnn116, hltC, nltC, itemsC, tracedC, cl, PRE_first_tail_x15_r0_body.fle0116, PRE_first_tail_x15_r0_body.fnk116, PRE_first_tail_x15_r0_body.ckA116, PRE_first_tail_x15_r0_body.cobjsK116, PRE_first_tail_x15_r0_body.cnodesK116, PRE_first_tail_x15_r0_body.citemsK116, PRE_first_tail_x15_r0_body.f1A116, PRE_first_tail_x15_r0_body.f1O116, PRE_first_tail_x15_r0_body.f1N116, PRE_first_tail_x15_r0_body.f1I116, PRE_first_tail_x15_r0_body.fbd116, PRE_first_tail_x15_r0_body.fincW116, PRE_first_tail_x15_r0_body.fincI116, PRE_first_tail_x15_r0_body.fincN116, PRE_first_tail_x15_r0_body.flnF116, PRE_first_tail_x15_r0_body.fh116, PRE_first_tail_x15_r0_body.fo116, PRE_first_tail_x15_r0_body.fok116, PRE_first_tail_x15_r0_body.fnd116, PRE_first_tail_x15_r0_body.fp116, PRE_first_tail_x15_r0_body.fnord116, PRE_first_tail_x15_r0_body.fi116, PRE_first_tail_x15_r0_body.fii116⟩
theorem PRE_first_tail_x15_r0_body.cnshift116 (clean : Conv.NClean (⟨20477, 17581, 2765507, 5014⟩ : Conv.Cnt) (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1121.ffi).mlx) (hltC : ∀ h, PH (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1121.ffi).mlx h → h < (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1121.ffi).mlx.next) (nltC : ∀ i, PN (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1121.ffi).mlx i → i < (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1121.ffi).mlx.nnext) (itemsC : ∀ k v, (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1121.ffi).mlx.items.get k = some v → PN (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1121.ffi).mlx k) (tracedC : ∀ h o, (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1121.ffi).mlx.objs.get h = some o → ∀ i ∈ objTraces o, i < PRE_first_tail_x15_r0_body.P116.NL) (cl : SSt (· < 5014) PRE_first_tail_x15_r0_body.cx0_116.mlx) : NShift PRE_first_tail_x15_r0_body.P116 5014 PRE_first_tail_x15_r0_body.kappa116 PRE_first_tail_x15_r0_body.cx0_116 PRE_first_tail_x15_r0_body.cx1_116 :=
  Conv.nshift_of_foot (PRE_first_tail_x15_r0_body.cfoot116 clean hltC nltC itemsC tracedC cl) PRE_first_tail_x15_r0_body.chost116 (compact_a_eq PRE_first_tail_x15_r0_body.ckn0116 PRE_first_tail_x15_r0_body.ckn1116 PRE_first_tail_x15_r0_body.ckheap116 PRE_first_tail_x15_r0_body.ckpl116)

-- the observers: the layers' states at the call, the canonical and the merged state, their footprints and checks
noncomputable def PRE_first_tail_x15_r0_body.fxC_116 : PTrie Unit := (Host.Ts.Sim.Full.freedOf PRE_first_tail_x15_r0_body.s1121.ffi).getD PTrie.nil
noncomputable def PRE_first_tail_x15_r0_body.krC_116 : Host.Load.Layers.KRec := (Host.Ts.Sim.Full.krecOf PRE_first_tail_x15_r0_body.s1121.ffi).getD Host.Load.Layers.KRec.empty
kernel_rfl PRE_first_tail_x15_r0_body.ofxC_116 : (Host.Ts.Sim.Full.freedOf PRE_first_tail_x15_r0_body.s1121.ffi) = some PRE_first_tail_x15_r0_body.fxC_116
kernel_rfl PRE_first_tail_x15_r0_body.okrC_116 : (Host.Ts.Sim.Full.krecOf PRE_first_tail_x15_r0_body.s1121.ffi) = some PRE_first_tail_x15_r0_body.krC_116
noncomputable def PRE_first_tail_x15_r0_body.fx0_116 : PTrie Unit := (Host.Ts.Sim.Full.freedOf PRE_first_tail_x15_r0_body.s1123.ffi).getD PTrie.nil
noncomputable def PRE_first_tail_x15_r0_body.kr0_116 : Host.Load.Layers.KRec := (Host.Ts.Sim.Full.krecOf PRE_first_tail_x15_r0_body.s1123.ffi).getD Host.Load.Layers.KRec.empty
kernel_rfl PRE_first_tail_x15_r0_body.ofx0_116 : (Host.Ts.Sim.Full.freedOf PRE_first_tail_x15_r0_body.s1123.ffi) = some PRE_first_tail_x15_r0_body.fx0_116
kernel_rfl PRE_first_tail_x15_r0_body.okr0_116 : (Host.Ts.Sim.Full.krecOf PRE_first_tail_x15_r0_body.s1123.ffi) = some PRE_first_tail_x15_r0_body.kr0_116
noncomputable def PRE_first_tail_x15_r0_body.fx1_116 : PTrie Unit := (Host.Ts.Sim.Full.freedOf PRE_first_tail_x15_r0_body.s1122.ffi).getD PTrie.nil
noncomputable def PRE_first_tail_x15_r0_body.kr1_116 : Host.Load.Layers.KRec := (Host.Ts.Sim.Full.krecOf PRE_first_tail_x15_r0_body.s1122.ffi).getD Host.Load.Layers.KRec.empty
kernel_rfl PRE_first_tail_x15_r0_body.ofx1_116 : (Host.Ts.Sim.Full.freedOf PRE_first_tail_x15_r0_body.s1122.ffi) = some PRE_first_tail_x15_r0_body.fx1_116
kernel_rfl PRE_first_tail_x15_r0_body.okr1_116 : (Host.Ts.Sim.Full.krecOf PRE_first_tail_x15_r0_body.s1122.ffi) = some PRE_first_tail_x15_r0_body.kr1_116
kernel_rfl PRE_first_tail_x15_r0_body.ff0116 : PRE_first_tail_x15_r0_body.fx0_116 = Stage.setAll PRE_first_tail_x15_r0_body.fxC_116 (PRE_first_tail_x15_r0_body.clo116.filterMap fun i => (PRE_first_tail_x15_r0_body.fx0_116.get i).map (i, ·))
kernel_rfl PRE_first_tail_x15_r0_body.ff1116 : PRE_first_tail_x15_r0_body.fx1_116 = Stage.setAll PRE_first_tail_x15_r0_body.fxC_116 (PRE_first_tail_x15_r0_body.cwS116.filterMap fun i => (PRE_first_tail_x15_r0_body.fx1_116.get i).map (i, ·))
kernel_rfl PRE_first_tail_x15_r0_body.ffck116 : freedLB PRE_first_tail_x15_r0_body.kappa116 PRE_first_tail_x15_r0_body.cx0_116.mlx PRE_first_tail_x15_r0_body.fx0_116 PRE_first_tail_x15_r0_body.fx1_116 PRE_first_tail_x15_r0_body.clo116 = true
kernel_rfl PRE_first_tail_x15_r0_body.fkf0116 : PRE_first_tail_x15_r0_body.kr0_116.flags = Stage.setAll PRE_first_tail_x15_r0_body.krC_116.flags (PRE_first_tail_x15_r0_body.clo116.filterMap fun i => (PRE_first_tail_x15_r0_body.kr0_116.flags.get i).map (i, ·))
kernel_rfl PRE_first_tail_x15_r0_body.fkt0116 : PRE_first_tail_x15_r0_body.kr0_116.targs = Stage.setAll PRE_first_tail_x15_r0_body.krC_116.targs (PRE_first_tail_x15_r0_body.clo116.filterMap fun i => (PRE_first_tail_x15_r0_body.kr0_116.targs.get i).map (i, ·))
kernel_rfl PRE_first_tail_x15_r0_body.fkf1116 : PRE_first_tail_x15_r0_body.kr1_116.flags = Stage.setAll PRE_first_tail_x15_r0_body.krC_116.flags (PRE_first_tail_x15_r0_body.cwS116.filterMap fun i => (PRE_first_tail_x15_r0_body.kr1_116.flags.get i).map (i, ·))
kernel_rfl PRE_first_tail_x15_r0_body.fkt1116 : PRE_first_tail_x15_r0_body.kr1_116.targs = Stage.setAll PRE_first_tail_x15_r0_body.krC_116.targs (PRE_first_tail_x15_r0_body.cwS116.filterMap fun i => (PRE_first_tail_x15_r0_body.kr1_116.targs.get i).map (i, ·))
kernel_rfl PRE_first_tail_x15_r0_body.fkck116 : krecLB PRE_first_tail_x15_r0_body.kappa116 5014 PRE_first_tail_x15_r0_body.cx0_116.mlx PRE_first_tail_x15_r0_body.kr0_116 PRE_first_tail_x15_r0_body.kr1_116 PRE_first_tail_x15_r0_body.clo116 = true
kernel_rfl PRE_first_tail_x15_r0_body.fkn116 : Nat.ble 5014 5014 = true
-- the bridge and the pending traces' regions
kernel_rfl PRE_first_tail_x15_r0_body.cbridge116 : Host.Ts.Sim.Full.bridgeOf PRE_first_tail_x15_r0_body.s1122.ffi = Host.Ts.Sim.Full.bridgeOf PRE_first_tail_x15_r0_body.s1123.ffi
kernel_rfl PRE_first_tail_x15_r0_body.cpendR116 : pendRegB PRE_first_tail_x15_r0_body.kappa116 (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1123.ffi).mlx = true
kernel_rfl PRE_first_tail_x15_r0_body.cpendLe116 : Nat.ble (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1123.ffi).mlx.next (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1122.ffi).mlx.next = true
/-- **The compaction's native shift**, given the call's bookkeeping, its relation's facts (the model's and the
observers') and the canonical closedness. -/
theorem PRE_first_tail_x15_r0_body.cshift116 (clean : Conv.NClean (⟨20477, 17581, 2765507, 5014⟩ : Conv.Cnt) (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1121.ffi).mlx) (hltC : ∀ h, PH (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1121.ffi).mlx h → h < (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1121.ffi).mlx.next) (nltC : ∀ i, PN (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1121.ffi).mlx i → i < (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1121.ffi).mlx.nnext) (itemsC : ∀ k v, (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1121.ffi).mlx.items.get k = some v → PN (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1121.ffi).mlx k) (tracedC : ∀ h o, (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1121.ffi).mlx.objs.get h = some o → ∀ i ∈ objTraces o, i < PRE_first_tail_x15_r0_body.P116.NL) (cl : SSt (· < 5014) PRE_first_tail_x15_r0_body.cx0_116.mlx)
    (hobjC : ∀ h, PRE_first_tail_x15_r0_body.fxC_116.get h = some () → ((Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1121.ffi).mlx.objs.get h).isSome = true)
    (hfC : ∀ h, (PRE_first_tail_x15_r0_body.krC_116.flags.get h).isSome = true → ((Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1121.ffi).mlx.objs.get h).isSome = true)
    (htC : ∀ h, (PRE_first_tail_x15_r0_body.krC_116.targs.get h).isSome = true → ((Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1121.ffi).mlx.objs.get h).isSome = true)
    (hclC : ∀ h l, PRE_first_tail_x15_r0_body.krC_116.targs.get h = some l → Host.Ts.Sim.Full.STargs (· < (⟨20477, 17581, 2765507, 5014⟩ : Conv.Cnt).n) l) :
    Conv.FullShiftQ PRE_first_tail_x15_r0_body.P116 5014 PRE_first_tail_x15_r0_body.kappa116 PRE_first_tail_x15_r0_body.s1123.ffi PRE_first_tail_x15_r0_body.s1122.ffi :=
  ⟨PRE_first_tail_x15_r0_body.cnshift116 clean hltC nltC itemsC tracedC cl, PRE_first_tail_x15_r0_body.cqueue116, fun t ht => bSN_sound (List.all_eq_true.mp PRE_first_tail_x15_r0_body.ctokSupp116 t ht),
    PRE_first_tail_x15_r0_body.cbridge116,
    liveShift_foot (x0' := Host.Ts.Sim.Full.mlxOf PRE_first_tail_x15_r0_body.s1123.ffi) (x1' := Host.Ts.Sim.Full.mlxOf PRE_first_tail_x15_r0_body.s1122.ffi) (PRE_first_tail_x15_r0_body.cfoot116 clean hltC nltC itemsC tracedC cl) rfl PRE_first_tail_x15_r0_body.ofx0_116 PRE_first_tail_x15_r0_body.ofx1_116 hobjC PRE_first_tail_x15_r0_body.ff0116 PRE_first_tail_x15_r0_body.ff1116 PRE_first_tail_x15_r0_body.ffck116,
    kernShift_foot (x0' := Host.Ts.Sim.Full.mlxOf PRE_first_tail_x15_r0_body.s1123.ffi) (x1' := Host.Ts.Sim.Full.mlxOf PRE_first_tail_x15_r0_body.s1122.ffi) (PRE_first_tail_x15_r0_body.cfoot116 clean hltC nltC itemsC tracedC cl) rfl PRE_first_tail_x15_r0_body.okr0_116 PRE_first_tail_x15_r0_body.okr1_116 (Nat.le_of_ble_eq_true PRE_first_tail_x15_r0_body.fkn116) hfC htC hclC
      PRE_first_tail_x15_r0_body.fkf0116 PRE_first_tail_x15_r0_body.fkt0116 PRE_first_tail_x15_r0_body.fkf1116 PRE_first_tail_x15_r0_body.fkt1116 PRE_first_tail_x15_r0_body.fkck116,
    pendReg_of rfl PRE_first_tail_x15_r0_body.cnh0116 PRE_first_tail_x15_r0_body.cnh1116 (Nat.le_of_ble_eq_true PRE_first_tail_x15_r0_body.cpendLe116) PRE_first_tail_x15_r0_body.cpendR116⟩

end Host.Load.Run.Tpl
