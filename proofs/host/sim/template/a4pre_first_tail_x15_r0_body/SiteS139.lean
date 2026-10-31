import host.sim.template.a4pre_first_tail_x15_r0_body.SiteCl139
import host.sim.conv.CompactFull
import host.sim.template.FootGen
set_option Elab.async false
namespace Host.Load.Run.Tpl
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
open Host.Ts Host.Ts.Sim Host.Ts.Sim.Template

/-! The compaction's native shift at call site 139 from its footprint (`Conv.nshift_of_foot`), and the observers'
(`liveShift_foot`, `kernShift_foot`): `Conv.FullShiftQ` for `Conv.full_compactQ`, given the call's bookkeeping and its
relation's facts. -/

/-- The load parameters of the chain (band-free: its start's node counter as `NL` and `N0`). -/
def PRE_first_tail_x15_r0_body.Pc139 : LoadP := ⟨18151, 131072, 1099511627776, 15235, 15235, []⟩
/-- The site's band raised to the map's checked fixed-node prefix, including newly recorded closure traces. -/
def PRE_first_tail_x15_r0_body.P139 : LoadP := PRE_first_tail_x15_r0_body.Pc139.raise 18051
kernel_rfl PRE_first_tail_x15_r0_body.craise139 : Nat.ble PRE_first_tail_x15_r0_body.Pc139.N0 18051 = true
theorem PRE_first_tail_x15_r0_body.raised139 : Host.Ts.Sim.Full.Raised PRE_first_tail_x15_r0_body.Pc139 PRE_first_tail_x15_r0_body.P139 :=
  .inr ⟨18051, rfl, Nat.le_of_ble_eq_true PRE_first_tail_x15_r0_body.craise139, rfl⟩
noncomputable abbrev PRE_first_tail_x15_r0_body.cx0_139 : Host.Load.LSt := clearTokens (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1349.ffi)
noncomputable abbrev PRE_first_tail_x15_r0_body.cx1_139 : Host.Load.LSt := clearTokens (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1348.ffi)
def PRE_first_tail_x15_r0_body.khinv139 : PTrie Nat := Stage.setAll PTrie.nil []
def PRE_first_tail_x15_r0_body.kninv139 : PTrie Nat := Stage.setAll PTrie.nil []
/-- The stage's footprint: its written and fresh handles, fresh nodes, written and fresh items. -/
def PRE_first_tail_x15_r0_body.cwS139 : List Nat := []
def PRE_first_tail_x15_r0_body.cnS139 : List Nat := List.range' 18051 0
def PRE_first_tail_x15_r0_body.ciS139 : List Nat := [] ++ List.range' 18051 0

-- the small checks (`MChecks`'s)
kernel_rfl PRE_first_tail_x15_r0_body.cnh0139 : PRE_first_tail_x15_r0_body.kd139.nh0 = PRE_first_tail_x15_r0_body.cx0_139.mlx.next
kernel_rfl PRE_first_tail_x15_r0_body.cnh1139 : PRE_first_tail_x15_r0_body.kd139.nh1 = PRE_first_tail_x15_r0_body.cx1_139.mlx.next
kernel_rfl PRE_first_tail_x15_r0_body.cnn0139 : PRE_first_tail_x15_r0_body.kd139.nn0 = PRE_first_tail_x15_r0_body.cx0_139.mlx.nnext
kernel_rfl PRE_first_tail_x15_r0_body.cnn1139 : PRE_first_tail_x15_r0_body.kd139.nn1 = PRE_first_tail_x15_r0_body.cx1_139.mlx.nnext
kernel_rfl PRE_first_tail_x15_r0_body.cplo139 : (Nat.blt 0 PRE_first_tail_x15_r0_body.P139.lo && Nat.ble PRE_first_tail_x15_r0_body.P139.lo PRE_first_tail_x15_r0_body.cx0_139.mlx.next && Nat.ble PRE_first_tail_x15_r0_body.P139.lo RData.bigHi && Nat.ble RData.bigHi PRE_first_tail_x15_r0_body.P139.E) = true
kernel_rfl PRE_first_tail_x15_r0_body.ccnt139 : (Nat.ble PRE_first_tail_x15_r0_body.cx0_139.mlx.next PRE_first_tail_x15_r0_body.cx1_139.mlx.next && Nat.ble PRE_first_tail_x15_r0_body.cx0_139.mlx.nnext PRE_first_tail_x15_r0_body.cx1_139.mlx.nnext) = true
kernel_rfl PRE_first_tail_x15_r0_body.cnband139 : (Nat.blt 0 PRE_first_tail_x15_r0_body.P139.NL && Nat.ble PRE_first_tail_x15_r0_body.P139.NL PRE_first_tail_x15_r0_body.P139.N0 && Nat.ble PRE_first_tail_x15_r0_body.P139.N0 PRE_first_tail_x15_r0_body.cx0_139.mlx.nnext) = true
kernel_rfl PRE_first_tail_x15_r0_body.chbelow139 : PRE_first_tail_x15_r0_body.kd139.checkHndBelow = true
kernel_rfl PRE_first_tail_x15_r0_body.chren139 : checkRenG PRE_first_tail_x15_r0_body.kd139.hnd PRE_first_tail_x15_r0_body.khinv139 (phB PRE_first_tail_x15_r0_body.cx0_139.mlx) = true
kernel_rfl PRE_first_tail_x15_r0_body.cband139 : PRE_first_tail_x15_r0_body.kd139.checkBand PRE_first_tail_x15_r0_body.P139.lo = true
kernel_rfl PRE_first_tail_x15_r0_body.cnh1pos139 : Nat.blt 0 PRE_first_tail_x15_r0_body.kd139.nh1 = true
kernel_rfl PRE_first_tail_x15_r0_body.cnren139 : checkRenG PRE_first_tail_x15_r0_body.kd139.node PRE_first_tail_x15_r0_body.kninv139 (pnB PRE_first_tail_x15_r0_body.cx0_139.mlx) = true
kernel_rfl PRE_first_tail_x15_r0_body.cnlow139 : (PTrie.keysA PRE_first_tail_x15_r0_body.kd139.node).all (fun j => Nat.ble PRE_first_tail_x15_r0_body.P139.NL j && Nat.blt (PRE_first_tail_x15_r0_body.kd139.nodeF j) PRE_first_tail_x15_r0_body.cx1_139.mlx.nnext) = true
kernel_rfl PRE_first_tail_x15_r0_body.cabs0a139 : PRE_first_tail_x15_r0_body.cx0_139.mlx.arrs.get 0 = none
kernel_rfl PRE_first_tail_x15_r0_body.cabs0b139 : PRE_first_tail_x15_r0_body.cx0_139.mlx.objs.get 0 = none
kernel_rfl PRE_first_tail_x15_r0_body.ctok1139 : PRE_first_tail_x15_r0_body.cx1_139.mlx.tokens = []
kernel_rfl PRE_first_tail_x15_r0_body.cpend139 : PRE_first_tail_x15_r0_body.cx1_139.mlx.pending = PRE_first_tail_x15_r0_body.cx0_139.mlx.pending.map PRE_first_tail_x15_r0_body.kappa139.pend
kernel_rfl PRE_first_tail_x15_r0_body.cerrh139 : PRE_first_tail_x15_r0_body.cx1_139.mlx.errh = PRE_first_tail_x15_r0_body.cx0_139.mlx.errh.map PRE_first_tail_x15_r0_body.kappa139.arg
kernel_rfl PRE_first_tail_x15_r0_body.cfiles139 : PRE_first_tail_x15_r0_body.cx1_139.mlx.files = PRE_first_tail_x15_r0_body.cx0_139.mlx.files
kernel_rfl PRE_first_tail_x15_r0_body.carch139 : PRE_first_tail_x15_r0_body.cx1_139.mlx.arch = PRE_first_tail_x15_r0_body.cx0_139.mlx.arch
kernel_rfl PRE_first_tail_x15_r0_body.csizes139 : PRE_first_tail_x15_r0_body.cx1_139.mlx.deviceSizes = PRE_first_tail_x15_r0_body.cx0_139.mlx.deviceSizes
kernel_rfl PRE_first_tail_x15_r0_body.cwired139 : PRE_first_tail_x15_r0_body.cx1_139.mlx.wired = PRE_first_tail_x15_r0_body.cx0_139.mlx.wired
kernel_rfl PRE_first_tail_x15_r0_body.chost139 : PRE_first_tail_x15_r0_body.cx1_139.host = PRE_first_tail_x15_r0_body.cx0_139.host
-- the compaction map's addresses are `PRE_first_tail_x15_r0_body.kd139`'s
kernel_rfl PRE_first_tail_x15_r0_body.ckn0139 : PRE_first_tail_x15_r0_body.kd139.n0 = 2784047
kernel_rfl PRE_first_tail_x15_r0_body.ckn1139 : PRE_first_tail_x15_r0_body.kd139.n1 = 2784049
kernel_rfl PRE_first_tail_x15_r0_body.ckheap139 : (PTrie.keysA PRE_first_tail_x15_r0_body.kd139.heap).all (fun x => Nat.ble 2784047 x) = true
kernel_rfl PRE_first_tail_x15_r0_body.ckpl139 : (List.range 0).all (fun j => decide (PRE_first_tail_x15_r0_body.kd139.heap.get (2784047 + j) = nth? PRE_first_tail_x15_r0_body.pl139 j)) = true
-- the map fixes the call's names (`Conv.fixOld_compact`), the call's counters
kernel_rfl PRE_first_tail_x15_r0_body.fja139 : Nat.ble 2784047 2784047 = true
kernel_rfl PRE_first_tail_x15_r0_body.fn139 : Nat.ble 6023 6023 = true
kernel_rfl PRE_first_tail_x15_r0_body.fjaD139 : Nat.ble 2784047 PRE_first_tail_x15_r0_body.kd139.n0 = true
kernel_rfl PRE_first_tail_x15_r0_body.fxn139 : Nat.ble 20942 PRE_first_tail_x15_r0_body.kd139.nh0 = true
kernel_rfl PRE_first_tail_x15_r0_body.fnn139 : Nat.ble 18051 PRE_first_tail_x15_r0_body.kd139.nn0 = true
kernel_rfl PRE_first_tail_x15_r0_body.fxb139 : Nat.ble 20942 RData.bigHi = true
kernel_rfl PRE_first_tail_x15_r0_body.fheap139 : (PTrie.keysA PRE_first_tail_x15_r0_body.kd139.heap).all (Nat.ble (⟨20942, 18051, 2784047, 6023⟩ : Conv.Cnt).ja) = true
kernel_rfl PRE_first_tail_x15_r0_body.fhnd139 : (PTrie.keysA PRE_first_tail_x15_r0_body.kd139.hnd).all (Nat.ble (⟨20942, 18051, 2784047, 6023⟩ : Conv.Cnt).xn) = true
kernel_rfl PRE_first_tail_x15_r0_body.fnode139 : (PTrie.keysA PRE_first_tail_x15_r0_body.kd139.node).all (Nat.ble (⟨20942, 18051, 2784047, 6023⟩ : Conv.Cnt).nn) = true
/-- The compaction map fixes the call's names. -/
theorem PRE_first_tail_x15_r0_body.cfix139 : Conv.FixOld (⟨20942, 18051, 2784047, 6023⟩ : Conv.Cnt) PRE_first_tail_x15_r0_body.kappa139 :=
  Conv.fixOld_compact (Nat.le_of_ble_eq_true PRE_first_tail_x15_r0_body.fja139) (Nat.le_of_ble_eq_true PRE_first_tail_x15_r0_body.fn139) (Nat.le_of_ble_eq_true PRE_first_tail_x15_r0_body.fjaD139) (Nat.le_of_ble_eq_true PRE_first_tail_x15_r0_body.fxn139) (Nat.le_of_ble_eq_true PRE_first_tail_x15_r0_body.fnn139) (Nat.le_of_ble_eq_true PRE_first_tail_x15_r0_body.fxb139) PRE_first_tail_x15_r0_body.fheap139 PRE_first_tail_x15_r0_body.fhnd139 PRE_first_tail_x15_r0_body.fnode139
kernel_rfl PRE_first_tail_x15_r0_body.fcxn139 : (⟨20942, 18051, 2784047, 6023⟩ : Conv.Cnt).xn = (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1347.ffi).mlx.next
kernel_rfl PRE_first_tail_x15_r0_body.fcnn139 : (⟨20942, 18051, 2784047, 6023⟩ : Conv.Cnt).nn = (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1347.ffi).mlx.nnext
kernel_rfl PRE_first_tail_x15_r0_body.fle0139 : (Nat.ble (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1347.ffi).mlx.next PRE_first_tail_x15_r0_body.cx0_139.mlx.next && Nat.ble (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1347.ffi).mlx.nnext PRE_first_tail_x15_r0_body.cx0_139.mlx.nnext && Nat.ble (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1347.ffi).mlx.next RData.bigHi) = true
kernel_rfl PRE_first_tail_x15_r0_body.fnk139 : (PTrie.keysA PRE_first_tail_x15_r0_body.kd139.node).all (Nat.ble (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1347.ffi).mlx.nnext) = true
-- the merged state keeps the call's entries off the stage's footprint
kernel_rfl PRE_first_tail_x15_r0_body.f1A139 : PRE_first_tail_x15_r0_body.cx1_139.mlx.arrs = Stage.setAll (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1347.ffi).mlx.arrs (PRE_first_tail_x15_r0_body.cwS139.filterMap fun i => (PRE_first_tail_x15_r0_body.cx1_139.mlx.arrs.get i).map (i, ·))
kernel_rfl PRE_first_tail_x15_r0_body.f1O139 : PRE_first_tail_x15_r0_body.cx1_139.mlx.objs = Stage.setAll (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1347.ffi).mlx.objs (PRE_first_tail_x15_r0_body.cwS139.filterMap fun i => (PRE_first_tail_x15_r0_body.cx1_139.mlx.objs.get i).map (i, ·))
kernel_rfl PRE_first_tail_x15_r0_body.f1N139 : PRE_first_tail_x15_r0_body.cx1_139.mlx.nodes = Stage.setAll (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1347.ffi).mlx.nodes (PRE_first_tail_x15_r0_body.cnS139.filterMap fun i => (PRE_first_tail_x15_r0_body.cx1_139.mlx.nodes.get i).map (i, ·))
kernel_rfl PRE_first_tail_x15_r0_body.f1I139 : PRE_first_tail_x15_r0_body.cx1_139.mlx.items = Stage.setAll (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1347.ffi).mlx.items (PRE_first_tail_x15_r0_body.ciS139.filterMap fun i => (PRE_first_tail_x15_r0_body.cx1_139.mlx.items.get i).map (i, ·))
kernel_rfl PRE_first_tail_x15_r0_body.fbd139 : (PRE_first_tail_x15_r0_body.clo139 ++ PRE_first_tail_x15_r0_body.cln139 ++ PRE_first_tail_x15_r0_body.cli139 ++ PRE_first_tail_x15_r0_body.cwS139 ++ PRE_first_tail_x15_r0_body.cnS139 ++ PRE_first_tail_x15_r0_body.ciS139).all (fun i => Nat.blt (i / 4096) (4 ^ 31)) = true
kernel_rfl PRE_first_tail_x15_r0_body.fincW139 : PRE_first_tail_x15_r0_body.cwS139.all (fun h => !Nat.blt h (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1347.ffi).mlx.next || PRE_first_tail_x15_r0_body.clo139.contains h) = true
kernel_rfl PRE_first_tail_x15_r0_body.fincI139 : PRE_first_tail_x15_r0_body.ciS139.all (fun k => !Nat.blt k (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1347.ffi).mlx.nnext || PRE_first_tail_x15_r0_body.cli139.contains k) = true
kernel_rfl PRE_first_tail_x15_r0_body.fincN139 : PRE_first_tail_x15_r0_body.cnS139.all (Nat.ble (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1347.ffi).mlx.nnext) = true
kernel_rfl PRE_first_tail_x15_r0_body.flnF139 : PRE_first_tail_x15_r0_body.cln139.all (Nat.ble (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1347.ffi).mlx.nnext) = true
-- the checks over the changed lists
kernel_rfl PRE_first_tail_x15_r0_body.fh139 : PRE_first_tail_x15_r0_body.clo139.all (handleOK PRE_first_tail_x15_r0_body.kappa139 PRE_first_tail_x15_r0_body.P139.lo PRE_first_tail_x15_r0_body.cx0_139.mlx PRE_first_tail_x15_r0_body.cx1_139.mlx) = true
kernel_rfl PRE_first_tail_x15_r0_body.fo139 : PRE_first_tail_x15_r0_body.clo139.map (fun h => PRE_first_tail_x15_r0_body.cx1_139.mlx.objs.get (PRE_first_tail_x15_r0_body.kappa139.handle h)) = PRE_first_tail_x15_r0_body.clo139.map (fun h => (PRE_first_tail_x15_r0_body.cx0_139.mlx.objs.get h).map PRE_first_tail_x15_r0_body.kappa139.nobj)
kernel_rfl PRE_first_tail_x15_r0_body.fok139 : PRE_first_tail_x15_r0_body.clo139.all (objOK PRE_first_tail_x15_r0_body.kappa139 PRE_first_tail_x15_r0_body.P139.NL PRE_first_tail_x15_r0_body.cx0_139.mlx) = true
kernel_rfl PRE_first_tail_x15_r0_body.fnd139 : PRE_first_tail_x15_r0_body.cln139.all (nodeOKF PRE_first_tail_x15_r0_body.kappa139 PRE_first_tail_x15_r0_body.P139 PRE_first_tail_x15_r0_body.cx0_139.mlx PRE_first_tail_x15_r0_body.cx1_139.mlx) = true
kernel_rfl PRE_first_tail_x15_r0_body.fp139 : ((PRE_first_tail_x15_r0_body.cln139.filter (fullB PRE_first_tail_x15_r0_body.P139))).map (fun i => (PRE_first_tail_x15_r0_body.cx1_139.mlx.nodes.get (PRE_first_tail_x15_r0_body.kappa139.node i)).map Host.Mlx.Ffi.Node.prim) =
  ((PRE_first_tail_x15_r0_body.cln139.filter (fullB PRE_first_tail_x15_r0_body.P139))).map (fun i => (PRE_first_tail_x15_r0_body.cx0_139.mlx.nodes.get i).map fun nd => PRE_first_tail_x15_r0_body.kappa139.prim nd.prim)
kernel_rfl PRE_first_tail_x15_r0_body.fnordI139 : incrB PRE_first_tail_x15_r0_body.kd139.nodeF (List.range' 18051 0) = true
kernel_rfl PRE_first_tail_x15_r0_body.fnordK139 : (PTrie.keysA PRE_first_tail_x15_r0_body.kd139.node).all (fun k => Nat.ble 18051 k && Nat.blt k 18051) = true
kernel_rfl PRE_first_tail_x15_r0_body.fnordL139 : (PRE_first_tail_x15_r0_body.cln139.filter (Nat.ble PRE_first_tail_x15_r0_body.P139.N0)).all (fun i => Nat.ble i (PRE_first_tail_x15_r0_body.kd139.nodeF i) && (Nat.blt i 18051 || Nat.ble PRE_first_tail_x15_r0_body.kd139.nn0 i)) = true
theorem PRE_first_tail_x15_r0_body.fnord139 : (PRE_first_tail_x15_r0_body.cln139.filter (Nat.ble PRE_first_tail_x15_r0_body.P139.N0)).all (fun i => Nat.ble i (PRE_first_tail_x15_r0_body.kd139.nodeF i) &&
    (PTrie.keysA PRE_first_tail_x15_r0_body.kd139.node).all fun j => !Nat.blt j i || Nat.blt (PRE_first_tail_x15_r0_body.kd139.nodeF j) (PRE_first_tail_x15_r0_body.kd139.nodeF i)) = true :=
  cnord_of PRE_first_tail_x15_r0_body.cnlow139 PRE_first_tail_x15_r0_body.cnn1139 PRE_first_tail_x15_r0_body.fnordI139 PRE_first_tail_x15_r0_body.fnordK139 PRE_first_tail_x15_r0_body.fnordL139
kernel_rfl PRE_first_tail_x15_r0_body.fi139 : PRE_first_tail_x15_r0_body.cli139.all (pnB PRE_first_tail_x15_r0_body.cx0_139.mlx) = true
kernel_rfl PRE_first_tail_x15_r0_body.fii139 : PRE_first_tail_x15_r0_body.cli139.all (fun k => decide (PRE_first_tail_x15_r0_body.cx1_139.mlx.items.get (PRE_first_tail_x15_r0_body.kappa139.node k) = (PRE_first_tail_x15_r0_body.cx0_139.mlx.items.get k).map PRE_first_tail_x15_r0_body.kappa139.nv)) = true
/-- **The compaction's footprint.** -/
theorem PRE_first_tail_x15_r0_body.cfoot139 (clean : Conv.NClean (⟨20942, 18051, 2784047, 6023⟩ : Conv.Cnt) (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1347.ffi).mlx) (hltC : ∀ h, PH (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1347.ffi).mlx h → h < (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1347.ffi).mlx.next) (nltC : ∀ i, PN (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1347.ffi).mlx i → i < (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1347.ffi).mlx.nnext) (itemsC : ∀ k v, (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1347.ffi).mlx.items.get k = some v → PN (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1347.ffi).mlx k) (tracedC : ∀ h o, (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1347.ffi).mlx.objs.get h = some o → ∀ i ∈ objTraces o, i < PRE_first_tail_x15_r0_body.P139.NL) (cl : SSt (· < 6023) PRE_first_tail_x15_r0_body.cx0_139.mlx) :
    Conv.MFoot PRE_first_tail_x15_r0_body.P139 6023 PRE_first_tail_x15_r0_body.kappa139 PRE_first_tail_x15_r0_body.kd139 PRE_first_tail_x15_r0_body.khinv139 PRE_first_tail_x15_r0_body.kninv139 (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1347.ffi).mlx PRE_first_tail_x15_r0_body.cx0_139.mlx PRE_first_tail_x15_r0_body.cx1_139.mlx (⟨20942, 18051, 2784047, 6023⟩ : Conv.Cnt) PRE_first_tail_x15_r0_body.clo139 PRE_first_tail_x15_r0_body.cln139 PRE_first_tail_x15_r0_body.cli139 PRE_first_tail_x15_r0_body.cwS139 PRE_first_tail_x15_r0_body.cnS139 PRE_first_tail_x15_r0_body.ciS139 :=
  ⟨rfl, rfl, rfl, PRE_first_tail_x15_r0_body.cnh0139, PRE_first_tail_x15_r0_body.cnh1139, PRE_first_tail_x15_r0_body.cnn0139, PRE_first_tail_x15_r0_body.cnn1139, PRE_first_tail_x15_r0_body.cplo139, PRE_first_tail_x15_r0_body.ccnt139, PRE_first_tail_x15_r0_body.cnband139, PRE_first_tail_x15_r0_body.chbelow139, PRE_first_tail_x15_r0_body.chren139, PRE_first_tail_x15_r0_body.cband139, PRE_first_tail_x15_r0_body.cnh1pos139, PRE_first_tail_x15_r0_body.cnren139, PRE_first_tail_x15_r0_body.cnlow139, PRE_first_tail_x15_r0_body.cabs0a139, PRE_first_tail_x15_r0_body.cabs0b139, PRE_first_tail_x15_r0_body.ctok1139, PRE_first_tail_x15_r0_body.cpend139, PRE_first_tail_x15_r0_body.cerrh139, PRE_first_tail_x15_r0_body.cfiles139, PRE_first_tail_x15_r0_body.carch139, PRE_first_tail_x15_r0_body.csizes139, PRE_first_tail_x15_r0_body.cwired139, PRE_first_tail_x15_r0_body.cfix139, clean, PRE_first_tail_x15_r0_body.fcxn139, PRE_first_tail_x15_r0_body.fcnn139, hltC, nltC, itemsC, tracedC, cl, PRE_first_tail_x15_r0_body.fle0139, PRE_first_tail_x15_r0_body.fnk139, PRE_first_tail_x15_r0_body.ckA139, PRE_first_tail_x15_r0_body.cobjsK139, PRE_first_tail_x15_r0_body.cnodesK139, PRE_first_tail_x15_r0_body.citemsK139, PRE_first_tail_x15_r0_body.f1A139, PRE_first_tail_x15_r0_body.f1O139, PRE_first_tail_x15_r0_body.f1N139, PRE_first_tail_x15_r0_body.f1I139, PRE_first_tail_x15_r0_body.fbd139, PRE_first_tail_x15_r0_body.fincW139, PRE_first_tail_x15_r0_body.fincI139, PRE_first_tail_x15_r0_body.fincN139, PRE_first_tail_x15_r0_body.flnF139, PRE_first_tail_x15_r0_body.fh139, PRE_first_tail_x15_r0_body.fo139, PRE_first_tail_x15_r0_body.fok139, PRE_first_tail_x15_r0_body.fnd139, PRE_first_tail_x15_r0_body.fp139, PRE_first_tail_x15_r0_body.fnord139, PRE_first_tail_x15_r0_body.fi139, PRE_first_tail_x15_r0_body.fii139⟩
theorem PRE_first_tail_x15_r0_body.cnshift139 (clean : Conv.NClean (⟨20942, 18051, 2784047, 6023⟩ : Conv.Cnt) (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1347.ffi).mlx) (hltC : ∀ h, PH (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1347.ffi).mlx h → h < (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1347.ffi).mlx.next) (nltC : ∀ i, PN (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1347.ffi).mlx i → i < (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1347.ffi).mlx.nnext) (itemsC : ∀ k v, (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1347.ffi).mlx.items.get k = some v → PN (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1347.ffi).mlx k) (tracedC : ∀ h o, (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1347.ffi).mlx.objs.get h = some o → ∀ i ∈ objTraces o, i < PRE_first_tail_x15_r0_body.P139.NL) (cl : SSt (· < 6023) PRE_first_tail_x15_r0_body.cx0_139.mlx) : NShift PRE_first_tail_x15_r0_body.P139 6023 PRE_first_tail_x15_r0_body.kappa139 PRE_first_tail_x15_r0_body.cx0_139 PRE_first_tail_x15_r0_body.cx1_139 :=
  Conv.nshift_of_foot (PRE_first_tail_x15_r0_body.cfoot139 clean hltC nltC itemsC tracedC cl) PRE_first_tail_x15_r0_body.chost139 (compact_a_eq PRE_first_tail_x15_r0_body.ckn0139 PRE_first_tail_x15_r0_body.ckn1139 PRE_first_tail_x15_r0_body.ckheap139 PRE_first_tail_x15_r0_body.ckpl139)

-- the observers: the layers' states at the call, the canonical and the merged state, their footprints and checks
noncomputable def PRE_first_tail_x15_r0_body.fxC_139 : PTrie Unit := (Host.Ts.Sim.Full.freedOf PRE_first_tail_x15_r0_body.s1347.ffi).getD PTrie.nil
noncomputable def PRE_first_tail_x15_r0_body.krC_139 : Host.Load.Layers.KRec := (Host.Ts.Sim.Full.krecOf PRE_first_tail_x15_r0_body.s1347.ffi).getD Host.Load.Layers.KRec.empty
kernel_rfl PRE_first_tail_x15_r0_body.ofxC_139 : (Host.Ts.Sim.Full.freedOf PRE_first_tail_x15_r0_body.s1347.ffi) = some PRE_first_tail_x15_r0_body.fxC_139
kernel_rfl PRE_first_tail_x15_r0_body.okrC_139 : (Host.Ts.Sim.Full.krecOf PRE_first_tail_x15_r0_body.s1347.ffi) = some PRE_first_tail_x15_r0_body.krC_139
noncomputable def PRE_first_tail_x15_r0_body.fx0_139 : PTrie Unit := (Host.Ts.Sim.Full.freedOf PRE_first_tail_x15_r0_body.s1349.ffi).getD PTrie.nil
noncomputable def PRE_first_tail_x15_r0_body.kr0_139 : Host.Load.Layers.KRec := (Host.Ts.Sim.Full.krecOf PRE_first_tail_x15_r0_body.s1349.ffi).getD Host.Load.Layers.KRec.empty
kernel_rfl PRE_first_tail_x15_r0_body.ofx0_139 : (Host.Ts.Sim.Full.freedOf PRE_first_tail_x15_r0_body.s1349.ffi) = some PRE_first_tail_x15_r0_body.fx0_139
kernel_rfl PRE_first_tail_x15_r0_body.okr0_139 : (Host.Ts.Sim.Full.krecOf PRE_first_tail_x15_r0_body.s1349.ffi) = some PRE_first_tail_x15_r0_body.kr0_139
noncomputable def PRE_first_tail_x15_r0_body.fx1_139 : PTrie Unit := (Host.Ts.Sim.Full.freedOf PRE_first_tail_x15_r0_body.s1348.ffi).getD PTrie.nil
noncomputable def PRE_first_tail_x15_r0_body.kr1_139 : Host.Load.Layers.KRec := (Host.Ts.Sim.Full.krecOf PRE_first_tail_x15_r0_body.s1348.ffi).getD Host.Load.Layers.KRec.empty
kernel_rfl PRE_first_tail_x15_r0_body.ofx1_139 : (Host.Ts.Sim.Full.freedOf PRE_first_tail_x15_r0_body.s1348.ffi) = some PRE_first_tail_x15_r0_body.fx1_139
kernel_rfl PRE_first_tail_x15_r0_body.okr1_139 : (Host.Ts.Sim.Full.krecOf PRE_first_tail_x15_r0_body.s1348.ffi) = some PRE_first_tail_x15_r0_body.kr1_139
kernel_rfl PRE_first_tail_x15_r0_body.ff0139 : PRE_first_tail_x15_r0_body.fx0_139 = Stage.setAll PRE_first_tail_x15_r0_body.fxC_139 (PRE_first_tail_x15_r0_body.clo139.filterMap fun i => (PRE_first_tail_x15_r0_body.fx0_139.get i).map (i, ·))
kernel_rfl PRE_first_tail_x15_r0_body.ff1139 : PRE_first_tail_x15_r0_body.fx1_139 = Stage.setAll PRE_first_tail_x15_r0_body.fxC_139 (PRE_first_tail_x15_r0_body.cwS139.filterMap fun i => (PRE_first_tail_x15_r0_body.fx1_139.get i).map (i, ·))
kernel_rfl PRE_first_tail_x15_r0_body.ffck139 : freedLB PRE_first_tail_x15_r0_body.kappa139 PRE_first_tail_x15_r0_body.cx0_139.mlx PRE_first_tail_x15_r0_body.fx0_139 PRE_first_tail_x15_r0_body.fx1_139 PRE_first_tail_x15_r0_body.clo139 = true
kernel_rfl PRE_first_tail_x15_r0_body.fkf0139 : PRE_first_tail_x15_r0_body.kr0_139.flags = Stage.setAll PRE_first_tail_x15_r0_body.krC_139.flags (PRE_first_tail_x15_r0_body.clo139.filterMap fun i => (PRE_first_tail_x15_r0_body.kr0_139.flags.get i).map (i, ·))
kernel_rfl PRE_first_tail_x15_r0_body.fkt0139 : PRE_first_tail_x15_r0_body.kr0_139.targs = Stage.setAll PRE_first_tail_x15_r0_body.krC_139.targs (PRE_first_tail_x15_r0_body.clo139.filterMap fun i => (PRE_first_tail_x15_r0_body.kr0_139.targs.get i).map (i, ·))
kernel_rfl PRE_first_tail_x15_r0_body.fkf1139 : PRE_first_tail_x15_r0_body.kr1_139.flags = Stage.setAll PRE_first_tail_x15_r0_body.krC_139.flags (PRE_first_tail_x15_r0_body.cwS139.filterMap fun i => (PRE_first_tail_x15_r0_body.kr1_139.flags.get i).map (i, ·))
kernel_rfl PRE_first_tail_x15_r0_body.fkt1139 : PRE_first_tail_x15_r0_body.kr1_139.targs = Stage.setAll PRE_first_tail_x15_r0_body.krC_139.targs (PRE_first_tail_x15_r0_body.cwS139.filterMap fun i => (PRE_first_tail_x15_r0_body.kr1_139.targs.get i).map (i, ·))
kernel_rfl PRE_first_tail_x15_r0_body.fkck139 : krecLB PRE_first_tail_x15_r0_body.kappa139 6023 PRE_first_tail_x15_r0_body.cx0_139.mlx PRE_first_tail_x15_r0_body.kr0_139 PRE_first_tail_x15_r0_body.kr1_139 PRE_first_tail_x15_r0_body.clo139 = true
kernel_rfl PRE_first_tail_x15_r0_body.fkn139 : Nat.ble 6023 6023 = true
-- the bridge and the pending traces' regions
kernel_rfl PRE_first_tail_x15_r0_body.cbridge139 : Host.Ts.Sim.Full.bridgeOf PRE_first_tail_x15_r0_body.s1348.ffi = Host.Ts.Sim.Full.bridgeOf PRE_first_tail_x15_r0_body.s1349.ffi
kernel_rfl PRE_first_tail_x15_r0_body.cpendR139 : pendRegB PRE_first_tail_x15_r0_body.kappa139 (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1349.ffi).mlx = true
kernel_rfl PRE_first_tail_x15_r0_body.cpendLe139 : Nat.ble (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1349.ffi).mlx.next (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1348.ffi).mlx.next = true
/-- **The compaction's native shift**, given the call's bookkeeping, its relation's facts (the model's and the
observers') and the canonical closedness. -/
theorem PRE_first_tail_x15_r0_body.cshift139 (clean : Conv.NClean (⟨20942, 18051, 2784047, 6023⟩ : Conv.Cnt) (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1347.ffi).mlx) (hltC : ∀ h, PH (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1347.ffi).mlx h → h < (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1347.ffi).mlx.next) (nltC : ∀ i, PN (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1347.ffi).mlx i → i < (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1347.ffi).mlx.nnext) (itemsC : ∀ k v, (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1347.ffi).mlx.items.get k = some v → PN (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1347.ffi).mlx k) (tracedC : ∀ h o, (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1347.ffi).mlx.objs.get h = some o → ∀ i ∈ objTraces o, i < PRE_first_tail_x15_r0_body.P139.NL) (cl : SSt (· < 6023) PRE_first_tail_x15_r0_body.cx0_139.mlx)
    (hobjC : ∀ h, PRE_first_tail_x15_r0_body.fxC_139.get h = some () → ((Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1347.ffi).mlx.objs.get h).isSome = true)
    (hfC : ∀ h, (PRE_first_tail_x15_r0_body.krC_139.flags.get h).isSome = true → ((Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1347.ffi).mlx.objs.get h).isSome = true)
    (htC : ∀ h, (PRE_first_tail_x15_r0_body.krC_139.targs.get h).isSome = true → ((Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1347.ffi).mlx.objs.get h).isSome = true)
    (hclC : ∀ h l, PRE_first_tail_x15_r0_body.krC_139.targs.get h = some l → Host.Ts.Sim.Full.STargs (· < (⟨20942, 18051, 2784047, 6023⟩ : Conv.Cnt).n) l) :
    Conv.FullShiftQ PRE_first_tail_x15_r0_body.P139 6023 PRE_first_tail_x15_r0_body.kappa139 PRE_first_tail_x15_r0_body.s1349.ffi PRE_first_tail_x15_r0_body.s1348.ffi :=
  ⟨PRE_first_tail_x15_r0_body.cnshift139 clean hltC nltC itemsC tracedC cl, PRE_first_tail_x15_r0_body.cqueue139, fun t ht => bSN_sound (List.all_eq_true.mp PRE_first_tail_x15_r0_body.ctokSupp139 t ht),
    PRE_first_tail_x15_r0_body.cbridge139,
    liveShift_foot (x0' := Host.Ts.Sim.Full.mlxOf PRE_first_tail_x15_r0_body.s1349.ffi) (x1' := Host.Ts.Sim.Full.mlxOf PRE_first_tail_x15_r0_body.s1348.ffi) (PRE_first_tail_x15_r0_body.cfoot139 clean hltC nltC itemsC tracedC cl) rfl PRE_first_tail_x15_r0_body.ofx0_139 PRE_first_tail_x15_r0_body.ofx1_139 hobjC PRE_first_tail_x15_r0_body.ff0139 PRE_first_tail_x15_r0_body.ff1139 PRE_first_tail_x15_r0_body.ffck139,
    kernShift_foot (x0' := Host.Ts.Sim.Full.mlxOf PRE_first_tail_x15_r0_body.s1349.ffi) (x1' := Host.Ts.Sim.Full.mlxOf PRE_first_tail_x15_r0_body.s1348.ffi) (PRE_first_tail_x15_r0_body.cfoot139 clean hltC nltC itemsC tracedC cl) rfl PRE_first_tail_x15_r0_body.okr0_139 PRE_first_tail_x15_r0_body.okr1_139 (Nat.le_of_ble_eq_true PRE_first_tail_x15_r0_body.fkn139) hfC htC hclC
      PRE_first_tail_x15_r0_body.fkf0139 PRE_first_tail_x15_r0_body.fkt0139 PRE_first_tail_x15_r0_body.fkf1139 PRE_first_tail_x15_r0_body.fkt1139 PRE_first_tail_x15_r0_body.fkck139,
    pendReg_of rfl PRE_first_tail_x15_r0_body.cnh0139 PRE_first_tail_x15_r0_body.cnh1139 (Nat.le_of_ble_eq_true PRE_first_tail_x15_r0_body.cpendLe139) PRE_first_tail_x15_r0_body.cpendR139⟩

end Host.Load.Run.Tpl
