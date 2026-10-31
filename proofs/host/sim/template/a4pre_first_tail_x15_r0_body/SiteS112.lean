import host.sim.template.a4pre_first_tail_x15_r0_body.SiteCl112
import host.sim.conv.CompactFull
import host.sim.template.FootGen
set_option Elab.async false
namespace Host.Load.Run.Tpl
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
open Host.Ts Host.Ts.Sim Host.Ts.Sim.Template

/-! The compaction's native shift at call site 112 from its footprint (`Conv.nshift_of_foot`), and the observers'
(`liveShift_foot`, `kernShift_foot`): `Conv.FullShiftQ` for `Conv.full_compactQ`, given the call's bookkeeping and its
relation's facts. -/

/-- The load parameters of the chain (band-free: its start's node counter as `NL` and `N0`). -/
def PRE_first_tail_x15_r0_body.Pc112 : LoadP := ⟨18151, 131072, 1099511627776, 15235, 15235, []⟩
/-- The site's band raised to the map's checked fixed-node prefix, including newly recorded closure traces. -/
def PRE_first_tail_x15_r0_body.P112 : LoadP := PRE_first_tail_x15_r0_body.Pc112.raise 17514
kernel_rfl PRE_first_tail_x15_r0_body.craise112 : Nat.ble PRE_first_tail_x15_r0_body.Pc112.N0 17514 = true
theorem PRE_first_tail_x15_r0_body.raised112 : Host.Ts.Sim.Full.Raised PRE_first_tail_x15_r0_body.Pc112 PRE_first_tail_x15_r0_body.P112 :=
  .inr ⟨17514, rfl, Nat.le_of_ble_eq_true PRE_first_tail_x15_r0_body.craise112, rfl⟩
noncomputable abbrev PRE_first_tail_x15_r0_body.cx0_112 : Host.Load.LSt := clearTokens (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1090.ffi)
noncomputable abbrev PRE_first_tail_x15_r0_body.cx1_112 : Host.Load.LSt := clearTokens (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1089.ffi)
def PRE_first_tail_x15_r0_body.khinv112 : PTrie Nat := Stage.setAll PTrie.nil []
def PRE_first_tail_x15_r0_body.kninv112 : PTrie Nat := Stage.setAll PTrie.nil []
/-- The stage's footprint: its written and fresh handles, fresh nodes, written and fresh items. -/
def PRE_first_tail_x15_r0_body.cwS112 : List Nat := []
def PRE_first_tail_x15_r0_body.cnS112 : List Nat := List.range' 17514 0
def PRE_first_tail_x15_r0_body.ciS112 : List Nat := [] ++ List.range' 17514 0

-- the small checks (`MChecks`'s)
kernel_rfl PRE_first_tail_x15_r0_body.cnh0112 : PRE_first_tail_x15_r0_body.kd112.nh0 = PRE_first_tail_x15_r0_body.cx0_112.mlx.next
kernel_rfl PRE_first_tail_x15_r0_body.cnh1112 : PRE_first_tail_x15_r0_body.kd112.nh1 = PRE_first_tail_x15_r0_body.cx1_112.mlx.next
kernel_rfl PRE_first_tail_x15_r0_body.cnn0112 : PRE_first_tail_x15_r0_body.kd112.nn0 = PRE_first_tail_x15_r0_body.cx0_112.mlx.nnext
kernel_rfl PRE_first_tail_x15_r0_body.cnn1112 : PRE_first_tail_x15_r0_body.kd112.nn1 = PRE_first_tail_x15_r0_body.cx1_112.mlx.nnext
kernel_rfl PRE_first_tail_x15_r0_body.cplo112 : (Nat.blt 0 PRE_first_tail_x15_r0_body.P112.lo && Nat.ble PRE_first_tail_x15_r0_body.P112.lo PRE_first_tail_x15_r0_body.cx0_112.mlx.next && Nat.ble PRE_first_tail_x15_r0_body.P112.lo RData.bigHi && Nat.ble RData.bigHi PRE_first_tail_x15_r0_body.P112.E) = true
kernel_rfl PRE_first_tail_x15_r0_body.ccnt112 : (Nat.ble PRE_first_tail_x15_r0_body.cx0_112.mlx.next PRE_first_tail_x15_r0_body.cx1_112.mlx.next && Nat.ble PRE_first_tail_x15_r0_body.cx0_112.mlx.nnext PRE_first_tail_x15_r0_body.cx1_112.mlx.nnext) = true
kernel_rfl PRE_first_tail_x15_r0_body.cnband112 : (Nat.blt 0 PRE_first_tail_x15_r0_body.P112.NL && Nat.ble PRE_first_tail_x15_r0_body.P112.NL PRE_first_tail_x15_r0_body.P112.N0 && Nat.ble PRE_first_tail_x15_r0_body.P112.N0 PRE_first_tail_x15_r0_body.cx0_112.mlx.nnext) = true
kernel_rfl PRE_first_tail_x15_r0_body.chbelow112 : PRE_first_tail_x15_r0_body.kd112.checkHndBelow = true
kernel_rfl PRE_first_tail_x15_r0_body.chren112 : checkRenG PRE_first_tail_x15_r0_body.kd112.hnd PRE_first_tail_x15_r0_body.khinv112 (phB PRE_first_tail_x15_r0_body.cx0_112.mlx) = true
kernel_rfl PRE_first_tail_x15_r0_body.cband112 : PRE_first_tail_x15_r0_body.kd112.checkBand PRE_first_tail_x15_r0_body.P112.lo = true
kernel_rfl PRE_first_tail_x15_r0_body.cnh1pos112 : Nat.blt 0 PRE_first_tail_x15_r0_body.kd112.nh1 = true
kernel_rfl PRE_first_tail_x15_r0_body.cnren112 : checkRenG PRE_first_tail_x15_r0_body.kd112.node PRE_first_tail_x15_r0_body.kninv112 (pnB PRE_first_tail_x15_r0_body.cx0_112.mlx) = true
kernel_rfl PRE_first_tail_x15_r0_body.cnlow112 : (PTrie.keysA PRE_first_tail_x15_r0_body.kd112.node).all (fun j => Nat.ble PRE_first_tail_x15_r0_body.P112.NL j && Nat.blt (PRE_first_tail_x15_r0_body.kd112.nodeF j) PRE_first_tail_x15_r0_body.cx1_112.mlx.nnext) = true
kernel_rfl PRE_first_tail_x15_r0_body.cabs0a112 : PRE_first_tail_x15_r0_body.cx0_112.mlx.arrs.get 0 = none
kernel_rfl PRE_first_tail_x15_r0_body.cabs0b112 : PRE_first_tail_x15_r0_body.cx0_112.mlx.objs.get 0 = none
kernel_rfl PRE_first_tail_x15_r0_body.ctok1112 : PRE_first_tail_x15_r0_body.cx1_112.mlx.tokens = []
kernel_rfl PRE_first_tail_x15_r0_body.cpend112 : PRE_first_tail_x15_r0_body.cx1_112.mlx.pending = PRE_first_tail_x15_r0_body.cx0_112.mlx.pending.map PRE_first_tail_x15_r0_body.kappa112.pend
kernel_rfl PRE_first_tail_x15_r0_body.cerrh112 : PRE_first_tail_x15_r0_body.cx1_112.mlx.errh = PRE_first_tail_x15_r0_body.cx0_112.mlx.errh.map PRE_first_tail_x15_r0_body.kappa112.arg
kernel_rfl PRE_first_tail_x15_r0_body.cfiles112 : PRE_first_tail_x15_r0_body.cx1_112.mlx.files = PRE_first_tail_x15_r0_body.cx0_112.mlx.files
kernel_rfl PRE_first_tail_x15_r0_body.carch112 : PRE_first_tail_x15_r0_body.cx1_112.mlx.arch = PRE_first_tail_x15_r0_body.cx0_112.mlx.arch
kernel_rfl PRE_first_tail_x15_r0_body.csizes112 : PRE_first_tail_x15_r0_body.cx1_112.mlx.deviceSizes = PRE_first_tail_x15_r0_body.cx0_112.mlx.deviceSizes
kernel_rfl PRE_first_tail_x15_r0_body.cwired112 : PRE_first_tail_x15_r0_body.cx1_112.mlx.wired = PRE_first_tail_x15_r0_body.cx0_112.mlx.wired
kernel_rfl PRE_first_tail_x15_r0_body.chost112 : PRE_first_tail_x15_r0_body.cx1_112.host = PRE_first_tail_x15_r0_body.cx0_112.host
-- the compaction map's addresses are `PRE_first_tail_x15_r0_body.kd112`'s
kernel_rfl PRE_first_tail_x15_r0_body.ckn0112 : PRE_first_tail_x15_r0_body.kd112.n0 = 2762963
kernel_rfl PRE_first_tail_x15_r0_body.ckn1112 : PRE_first_tail_x15_r0_body.kd112.n1 = 2762965
kernel_rfl PRE_first_tail_x15_r0_body.ckheap112 : (PTrie.keysA PRE_first_tail_x15_r0_body.kd112.heap).all (fun x => Nat.ble 2762963 x) = true
kernel_rfl PRE_first_tail_x15_r0_body.ckpl112 : (List.range 0).all (fun j => decide (PRE_first_tail_x15_r0_body.kd112.heap.get (2762963 + j) = nth? PRE_first_tail_x15_r0_body.pl112 j)) = true
-- the map fixes the call's names (`Conv.fixOld_compact`), the call's counters
kernel_rfl PRE_first_tail_x15_r0_body.fja112 : Nat.ble 2762963 2762963 = true
kernel_rfl PRE_first_tail_x15_r0_body.fn112 : Nat.ble 4868 4868 = true
kernel_rfl PRE_first_tail_x15_r0_body.fjaD112 : Nat.ble 2762963 PRE_first_tail_x15_r0_body.kd112.n0 = true
kernel_rfl PRE_first_tail_x15_r0_body.fxn112 : Nat.ble 20413 PRE_first_tail_x15_r0_body.kd112.nh0 = true
kernel_rfl PRE_first_tail_x15_r0_body.fnn112 : Nat.ble 17514 PRE_first_tail_x15_r0_body.kd112.nn0 = true
kernel_rfl PRE_first_tail_x15_r0_body.fxb112 : Nat.ble 20413 RData.bigHi = true
kernel_rfl PRE_first_tail_x15_r0_body.fheap112 : (PTrie.keysA PRE_first_tail_x15_r0_body.kd112.heap).all (Nat.ble (⟨20413, 17514, 2762963, 4868⟩ : Conv.Cnt).ja) = true
kernel_rfl PRE_first_tail_x15_r0_body.fhnd112 : (PTrie.keysA PRE_first_tail_x15_r0_body.kd112.hnd).all (Nat.ble (⟨20413, 17514, 2762963, 4868⟩ : Conv.Cnt).xn) = true
kernel_rfl PRE_first_tail_x15_r0_body.fnode112 : (PTrie.keysA PRE_first_tail_x15_r0_body.kd112.node).all (Nat.ble (⟨20413, 17514, 2762963, 4868⟩ : Conv.Cnt).nn) = true
/-- The compaction map fixes the call's names. -/
theorem PRE_first_tail_x15_r0_body.cfix112 : Conv.FixOld (⟨20413, 17514, 2762963, 4868⟩ : Conv.Cnt) PRE_first_tail_x15_r0_body.kappa112 :=
  Conv.fixOld_compact (Nat.le_of_ble_eq_true PRE_first_tail_x15_r0_body.fja112) (Nat.le_of_ble_eq_true PRE_first_tail_x15_r0_body.fn112) (Nat.le_of_ble_eq_true PRE_first_tail_x15_r0_body.fjaD112) (Nat.le_of_ble_eq_true PRE_first_tail_x15_r0_body.fxn112) (Nat.le_of_ble_eq_true PRE_first_tail_x15_r0_body.fnn112) (Nat.le_of_ble_eq_true PRE_first_tail_x15_r0_body.fxb112) PRE_first_tail_x15_r0_body.fheap112 PRE_first_tail_x15_r0_body.fhnd112 PRE_first_tail_x15_r0_body.fnode112
kernel_rfl PRE_first_tail_x15_r0_body.fcxn112 : (⟨20413, 17514, 2762963, 4868⟩ : Conv.Cnt).xn = (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1088.ffi).mlx.next
kernel_rfl PRE_first_tail_x15_r0_body.fcnn112 : (⟨20413, 17514, 2762963, 4868⟩ : Conv.Cnt).nn = (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1088.ffi).mlx.nnext
kernel_rfl PRE_first_tail_x15_r0_body.fle0112 : (Nat.ble (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1088.ffi).mlx.next PRE_first_tail_x15_r0_body.cx0_112.mlx.next && Nat.ble (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1088.ffi).mlx.nnext PRE_first_tail_x15_r0_body.cx0_112.mlx.nnext && Nat.ble (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1088.ffi).mlx.next RData.bigHi) = true
kernel_rfl PRE_first_tail_x15_r0_body.fnk112 : (PTrie.keysA PRE_first_tail_x15_r0_body.kd112.node).all (Nat.ble (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1088.ffi).mlx.nnext) = true
-- the merged state keeps the call's entries off the stage's footprint
kernel_rfl PRE_first_tail_x15_r0_body.f1A112 : PRE_first_tail_x15_r0_body.cx1_112.mlx.arrs = Stage.setAll (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1088.ffi).mlx.arrs (PRE_first_tail_x15_r0_body.cwS112.filterMap fun i => (PRE_first_tail_x15_r0_body.cx1_112.mlx.arrs.get i).map (i, ·))
kernel_rfl PRE_first_tail_x15_r0_body.f1O112 : PRE_first_tail_x15_r0_body.cx1_112.mlx.objs = Stage.setAll (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1088.ffi).mlx.objs (PRE_first_tail_x15_r0_body.cwS112.filterMap fun i => (PRE_first_tail_x15_r0_body.cx1_112.mlx.objs.get i).map (i, ·))
kernel_rfl PRE_first_tail_x15_r0_body.f1N112 : PRE_first_tail_x15_r0_body.cx1_112.mlx.nodes = Stage.setAll (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1088.ffi).mlx.nodes (PRE_first_tail_x15_r0_body.cnS112.filterMap fun i => (PRE_first_tail_x15_r0_body.cx1_112.mlx.nodes.get i).map (i, ·))
kernel_rfl PRE_first_tail_x15_r0_body.f1I112 : PRE_first_tail_x15_r0_body.cx1_112.mlx.items = Stage.setAll (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1088.ffi).mlx.items (PRE_first_tail_x15_r0_body.ciS112.filterMap fun i => (PRE_first_tail_x15_r0_body.cx1_112.mlx.items.get i).map (i, ·))
kernel_rfl PRE_first_tail_x15_r0_body.fbd112 : (PRE_first_tail_x15_r0_body.clo112 ++ PRE_first_tail_x15_r0_body.cln112 ++ PRE_first_tail_x15_r0_body.cli112 ++ PRE_first_tail_x15_r0_body.cwS112 ++ PRE_first_tail_x15_r0_body.cnS112 ++ PRE_first_tail_x15_r0_body.ciS112).all (fun i => Nat.blt (i / 4096) (4 ^ 31)) = true
kernel_rfl PRE_first_tail_x15_r0_body.fincW112 : PRE_first_tail_x15_r0_body.cwS112.all (fun h => !Nat.blt h (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1088.ffi).mlx.next || PRE_first_tail_x15_r0_body.clo112.contains h) = true
kernel_rfl PRE_first_tail_x15_r0_body.fincI112 : PRE_first_tail_x15_r0_body.ciS112.all (fun k => !Nat.blt k (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1088.ffi).mlx.nnext || PRE_first_tail_x15_r0_body.cli112.contains k) = true
kernel_rfl PRE_first_tail_x15_r0_body.fincN112 : PRE_first_tail_x15_r0_body.cnS112.all (Nat.ble (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1088.ffi).mlx.nnext) = true
kernel_rfl PRE_first_tail_x15_r0_body.flnF112 : PRE_first_tail_x15_r0_body.cln112.all (Nat.ble (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1088.ffi).mlx.nnext) = true
-- the checks over the changed lists
kernel_rfl PRE_first_tail_x15_r0_body.fh112 : PRE_first_tail_x15_r0_body.clo112.all (handleOK PRE_first_tail_x15_r0_body.kappa112 PRE_first_tail_x15_r0_body.P112.lo PRE_first_tail_x15_r0_body.cx0_112.mlx PRE_first_tail_x15_r0_body.cx1_112.mlx) = true
kernel_rfl PRE_first_tail_x15_r0_body.fo112 : PRE_first_tail_x15_r0_body.clo112.map (fun h => PRE_first_tail_x15_r0_body.cx1_112.mlx.objs.get (PRE_first_tail_x15_r0_body.kappa112.handle h)) = PRE_first_tail_x15_r0_body.clo112.map (fun h => (PRE_first_tail_x15_r0_body.cx0_112.mlx.objs.get h).map PRE_first_tail_x15_r0_body.kappa112.nobj)
kernel_rfl PRE_first_tail_x15_r0_body.fok112 : PRE_first_tail_x15_r0_body.clo112.all (objOK PRE_first_tail_x15_r0_body.kappa112 PRE_first_tail_x15_r0_body.P112.NL PRE_first_tail_x15_r0_body.cx0_112.mlx) = true
kernel_rfl PRE_first_tail_x15_r0_body.fnd112 : PRE_first_tail_x15_r0_body.cln112.all (nodeOKF PRE_first_tail_x15_r0_body.kappa112 PRE_first_tail_x15_r0_body.P112 PRE_first_tail_x15_r0_body.cx0_112.mlx PRE_first_tail_x15_r0_body.cx1_112.mlx) = true
kernel_rfl PRE_first_tail_x15_r0_body.fp112 : ((PRE_first_tail_x15_r0_body.cln112.filter (fullB PRE_first_tail_x15_r0_body.P112))).map (fun i => (PRE_first_tail_x15_r0_body.cx1_112.mlx.nodes.get (PRE_first_tail_x15_r0_body.kappa112.node i)).map Host.Mlx.Ffi.Node.prim) =
  ((PRE_first_tail_x15_r0_body.cln112.filter (fullB PRE_first_tail_x15_r0_body.P112))).map (fun i => (PRE_first_tail_x15_r0_body.cx0_112.mlx.nodes.get i).map fun nd => PRE_first_tail_x15_r0_body.kappa112.prim nd.prim)
kernel_rfl PRE_first_tail_x15_r0_body.fnordI112 : incrB PRE_first_tail_x15_r0_body.kd112.nodeF (List.range' 17514 0) = true
kernel_rfl PRE_first_tail_x15_r0_body.fnordK112 : (PTrie.keysA PRE_first_tail_x15_r0_body.kd112.node).all (fun k => Nat.ble 17514 k && Nat.blt k 17514) = true
kernel_rfl PRE_first_tail_x15_r0_body.fnordL112 : (PRE_first_tail_x15_r0_body.cln112.filter (Nat.ble PRE_first_tail_x15_r0_body.P112.N0)).all (fun i => Nat.ble i (PRE_first_tail_x15_r0_body.kd112.nodeF i) && (Nat.blt i 17514 || Nat.ble PRE_first_tail_x15_r0_body.kd112.nn0 i)) = true
theorem PRE_first_tail_x15_r0_body.fnord112 : (PRE_first_tail_x15_r0_body.cln112.filter (Nat.ble PRE_first_tail_x15_r0_body.P112.N0)).all (fun i => Nat.ble i (PRE_first_tail_x15_r0_body.kd112.nodeF i) &&
    (PTrie.keysA PRE_first_tail_x15_r0_body.kd112.node).all fun j => !Nat.blt j i || Nat.blt (PRE_first_tail_x15_r0_body.kd112.nodeF j) (PRE_first_tail_x15_r0_body.kd112.nodeF i)) = true :=
  cnord_of PRE_first_tail_x15_r0_body.cnlow112 PRE_first_tail_x15_r0_body.cnn1112 PRE_first_tail_x15_r0_body.fnordI112 PRE_first_tail_x15_r0_body.fnordK112 PRE_first_tail_x15_r0_body.fnordL112
kernel_rfl PRE_first_tail_x15_r0_body.fi112 : PRE_first_tail_x15_r0_body.cli112.all (pnB PRE_first_tail_x15_r0_body.cx0_112.mlx) = true
kernel_rfl PRE_first_tail_x15_r0_body.fii112 : PRE_first_tail_x15_r0_body.cli112.all (fun k => decide (PRE_first_tail_x15_r0_body.cx1_112.mlx.items.get (PRE_first_tail_x15_r0_body.kappa112.node k) = (PRE_first_tail_x15_r0_body.cx0_112.mlx.items.get k).map PRE_first_tail_x15_r0_body.kappa112.nv)) = true
/-- **The compaction's footprint.** -/
theorem PRE_first_tail_x15_r0_body.cfoot112 (clean : Conv.NClean (⟨20413, 17514, 2762963, 4868⟩ : Conv.Cnt) (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1088.ffi).mlx) (hltC : ∀ h, PH (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1088.ffi).mlx h → h < (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1088.ffi).mlx.next) (nltC : ∀ i, PN (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1088.ffi).mlx i → i < (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1088.ffi).mlx.nnext) (itemsC : ∀ k v, (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1088.ffi).mlx.items.get k = some v → PN (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1088.ffi).mlx k) (tracedC : ∀ h o, (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1088.ffi).mlx.objs.get h = some o → ∀ i ∈ objTraces o, i < PRE_first_tail_x15_r0_body.P112.NL) (cl : SSt (· < 4868) PRE_first_tail_x15_r0_body.cx0_112.mlx) :
    Conv.MFoot PRE_first_tail_x15_r0_body.P112 4868 PRE_first_tail_x15_r0_body.kappa112 PRE_first_tail_x15_r0_body.kd112 PRE_first_tail_x15_r0_body.khinv112 PRE_first_tail_x15_r0_body.kninv112 (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1088.ffi).mlx PRE_first_tail_x15_r0_body.cx0_112.mlx PRE_first_tail_x15_r0_body.cx1_112.mlx (⟨20413, 17514, 2762963, 4868⟩ : Conv.Cnt) PRE_first_tail_x15_r0_body.clo112 PRE_first_tail_x15_r0_body.cln112 PRE_first_tail_x15_r0_body.cli112 PRE_first_tail_x15_r0_body.cwS112 PRE_first_tail_x15_r0_body.cnS112 PRE_first_tail_x15_r0_body.ciS112 :=
  ⟨rfl, rfl, rfl, PRE_first_tail_x15_r0_body.cnh0112, PRE_first_tail_x15_r0_body.cnh1112, PRE_first_tail_x15_r0_body.cnn0112, PRE_first_tail_x15_r0_body.cnn1112, PRE_first_tail_x15_r0_body.cplo112, PRE_first_tail_x15_r0_body.ccnt112, PRE_first_tail_x15_r0_body.cnband112, PRE_first_tail_x15_r0_body.chbelow112, PRE_first_tail_x15_r0_body.chren112, PRE_first_tail_x15_r0_body.cband112, PRE_first_tail_x15_r0_body.cnh1pos112, PRE_first_tail_x15_r0_body.cnren112, PRE_first_tail_x15_r0_body.cnlow112, PRE_first_tail_x15_r0_body.cabs0a112, PRE_first_tail_x15_r0_body.cabs0b112, PRE_first_tail_x15_r0_body.ctok1112, PRE_first_tail_x15_r0_body.cpend112, PRE_first_tail_x15_r0_body.cerrh112, PRE_first_tail_x15_r0_body.cfiles112, PRE_first_tail_x15_r0_body.carch112, PRE_first_tail_x15_r0_body.csizes112, PRE_first_tail_x15_r0_body.cwired112, PRE_first_tail_x15_r0_body.cfix112, clean, PRE_first_tail_x15_r0_body.fcxn112, PRE_first_tail_x15_r0_body.fcnn112, hltC, nltC, itemsC, tracedC, cl, PRE_first_tail_x15_r0_body.fle0112, PRE_first_tail_x15_r0_body.fnk112, PRE_first_tail_x15_r0_body.ckA112, PRE_first_tail_x15_r0_body.cobjsK112, PRE_first_tail_x15_r0_body.cnodesK112, PRE_first_tail_x15_r0_body.citemsK112, PRE_first_tail_x15_r0_body.f1A112, PRE_first_tail_x15_r0_body.f1O112, PRE_first_tail_x15_r0_body.f1N112, PRE_first_tail_x15_r0_body.f1I112, PRE_first_tail_x15_r0_body.fbd112, PRE_first_tail_x15_r0_body.fincW112, PRE_first_tail_x15_r0_body.fincI112, PRE_first_tail_x15_r0_body.fincN112, PRE_first_tail_x15_r0_body.flnF112, PRE_first_tail_x15_r0_body.fh112, PRE_first_tail_x15_r0_body.fo112, PRE_first_tail_x15_r0_body.fok112, PRE_first_tail_x15_r0_body.fnd112, PRE_first_tail_x15_r0_body.fp112, PRE_first_tail_x15_r0_body.fnord112, PRE_first_tail_x15_r0_body.fi112, PRE_first_tail_x15_r0_body.fii112⟩
theorem PRE_first_tail_x15_r0_body.cnshift112 (clean : Conv.NClean (⟨20413, 17514, 2762963, 4868⟩ : Conv.Cnt) (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1088.ffi).mlx) (hltC : ∀ h, PH (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1088.ffi).mlx h → h < (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1088.ffi).mlx.next) (nltC : ∀ i, PN (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1088.ffi).mlx i → i < (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1088.ffi).mlx.nnext) (itemsC : ∀ k v, (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1088.ffi).mlx.items.get k = some v → PN (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1088.ffi).mlx k) (tracedC : ∀ h o, (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1088.ffi).mlx.objs.get h = some o → ∀ i ∈ objTraces o, i < PRE_first_tail_x15_r0_body.P112.NL) (cl : SSt (· < 4868) PRE_first_tail_x15_r0_body.cx0_112.mlx) : NShift PRE_first_tail_x15_r0_body.P112 4868 PRE_first_tail_x15_r0_body.kappa112 PRE_first_tail_x15_r0_body.cx0_112 PRE_first_tail_x15_r0_body.cx1_112 :=
  Conv.nshift_of_foot (PRE_first_tail_x15_r0_body.cfoot112 clean hltC nltC itemsC tracedC cl) PRE_first_tail_x15_r0_body.chost112 (compact_a_eq PRE_first_tail_x15_r0_body.ckn0112 PRE_first_tail_x15_r0_body.ckn1112 PRE_first_tail_x15_r0_body.ckheap112 PRE_first_tail_x15_r0_body.ckpl112)

-- the observers: the layers' states at the call, the canonical and the merged state, their footprints and checks
noncomputable def PRE_first_tail_x15_r0_body.fxC_112 : PTrie Unit := (Host.Ts.Sim.Full.freedOf PRE_first_tail_x15_r0_body.s1088.ffi).getD PTrie.nil
noncomputable def PRE_first_tail_x15_r0_body.krC_112 : Host.Load.Layers.KRec := (Host.Ts.Sim.Full.krecOf PRE_first_tail_x15_r0_body.s1088.ffi).getD Host.Load.Layers.KRec.empty
kernel_rfl PRE_first_tail_x15_r0_body.ofxC_112 : (Host.Ts.Sim.Full.freedOf PRE_first_tail_x15_r0_body.s1088.ffi) = some PRE_first_tail_x15_r0_body.fxC_112
kernel_rfl PRE_first_tail_x15_r0_body.okrC_112 : (Host.Ts.Sim.Full.krecOf PRE_first_tail_x15_r0_body.s1088.ffi) = some PRE_first_tail_x15_r0_body.krC_112
noncomputable def PRE_first_tail_x15_r0_body.fx0_112 : PTrie Unit := (Host.Ts.Sim.Full.freedOf PRE_first_tail_x15_r0_body.s1090.ffi).getD PTrie.nil
noncomputable def PRE_first_tail_x15_r0_body.kr0_112 : Host.Load.Layers.KRec := (Host.Ts.Sim.Full.krecOf PRE_first_tail_x15_r0_body.s1090.ffi).getD Host.Load.Layers.KRec.empty
kernel_rfl PRE_first_tail_x15_r0_body.ofx0_112 : (Host.Ts.Sim.Full.freedOf PRE_first_tail_x15_r0_body.s1090.ffi) = some PRE_first_tail_x15_r0_body.fx0_112
kernel_rfl PRE_first_tail_x15_r0_body.okr0_112 : (Host.Ts.Sim.Full.krecOf PRE_first_tail_x15_r0_body.s1090.ffi) = some PRE_first_tail_x15_r0_body.kr0_112
noncomputable def PRE_first_tail_x15_r0_body.fx1_112 : PTrie Unit := (Host.Ts.Sim.Full.freedOf PRE_first_tail_x15_r0_body.s1089.ffi).getD PTrie.nil
noncomputable def PRE_first_tail_x15_r0_body.kr1_112 : Host.Load.Layers.KRec := (Host.Ts.Sim.Full.krecOf PRE_first_tail_x15_r0_body.s1089.ffi).getD Host.Load.Layers.KRec.empty
kernel_rfl PRE_first_tail_x15_r0_body.ofx1_112 : (Host.Ts.Sim.Full.freedOf PRE_first_tail_x15_r0_body.s1089.ffi) = some PRE_first_tail_x15_r0_body.fx1_112
kernel_rfl PRE_first_tail_x15_r0_body.okr1_112 : (Host.Ts.Sim.Full.krecOf PRE_first_tail_x15_r0_body.s1089.ffi) = some PRE_first_tail_x15_r0_body.kr1_112
kernel_rfl PRE_first_tail_x15_r0_body.ff0112 : PRE_first_tail_x15_r0_body.fx0_112 = Stage.setAll PRE_first_tail_x15_r0_body.fxC_112 (PRE_first_tail_x15_r0_body.clo112.filterMap fun i => (PRE_first_tail_x15_r0_body.fx0_112.get i).map (i, ·))
kernel_rfl PRE_first_tail_x15_r0_body.ff1112 : PRE_first_tail_x15_r0_body.fx1_112 = Stage.setAll PRE_first_tail_x15_r0_body.fxC_112 (PRE_first_tail_x15_r0_body.cwS112.filterMap fun i => (PRE_first_tail_x15_r0_body.fx1_112.get i).map (i, ·))
kernel_rfl PRE_first_tail_x15_r0_body.ffck112 : freedLB PRE_first_tail_x15_r0_body.kappa112 PRE_first_tail_x15_r0_body.cx0_112.mlx PRE_first_tail_x15_r0_body.fx0_112 PRE_first_tail_x15_r0_body.fx1_112 PRE_first_tail_x15_r0_body.clo112 = true
kernel_rfl PRE_first_tail_x15_r0_body.fkf0112 : PRE_first_tail_x15_r0_body.kr0_112.flags = Stage.setAll PRE_first_tail_x15_r0_body.krC_112.flags (PRE_first_tail_x15_r0_body.clo112.filterMap fun i => (PRE_first_tail_x15_r0_body.kr0_112.flags.get i).map (i, ·))
kernel_rfl PRE_first_tail_x15_r0_body.fkt0112 : PRE_first_tail_x15_r0_body.kr0_112.targs = Stage.setAll PRE_first_tail_x15_r0_body.krC_112.targs (PRE_first_tail_x15_r0_body.clo112.filterMap fun i => (PRE_first_tail_x15_r0_body.kr0_112.targs.get i).map (i, ·))
kernel_rfl PRE_first_tail_x15_r0_body.fkf1112 : PRE_first_tail_x15_r0_body.kr1_112.flags = Stage.setAll PRE_first_tail_x15_r0_body.krC_112.flags (PRE_first_tail_x15_r0_body.cwS112.filterMap fun i => (PRE_first_tail_x15_r0_body.kr1_112.flags.get i).map (i, ·))
kernel_rfl PRE_first_tail_x15_r0_body.fkt1112 : PRE_first_tail_x15_r0_body.kr1_112.targs = Stage.setAll PRE_first_tail_x15_r0_body.krC_112.targs (PRE_first_tail_x15_r0_body.cwS112.filterMap fun i => (PRE_first_tail_x15_r0_body.kr1_112.targs.get i).map (i, ·))
kernel_rfl PRE_first_tail_x15_r0_body.fkck112 : krecLB PRE_first_tail_x15_r0_body.kappa112 4868 PRE_first_tail_x15_r0_body.cx0_112.mlx PRE_first_tail_x15_r0_body.kr0_112 PRE_first_tail_x15_r0_body.kr1_112 PRE_first_tail_x15_r0_body.clo112 = true
kernel_rfl PRE_first_tail_x15_r0_body.fkn112 : Nat.ble 4868 4868 = true
-- the bridge and the pending traces' regions
kernel_rfl PRE_first_tail_x15_r0_body.cbridge112 : Host.Ts.Sim.Full.bridgeOf PRE_first_tail_x15_r0_body.s1089.ffi = Host.Ts.Sim.Full.bridgeOf PRE_first_tail_x15_r0_body.s1090.ffi
kernel_rfl PRE_first_tail_x15_r0_body.cpendR112 : pendRegB PRE_first_tail_x15_r0_body.kappa112 (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1090.ffi).mlx = true
kernel_rfl PRE_first_tail_x15_r0_body.cpendLe112 : Nat.ble (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1090.ffi).mlx.next (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1089.ffi).mlx.next = true
/-- **The compaction's native shift**, given the call's bookkeeping, its relation's facts (the model's and the
observers') and the canonical closedness. -/
theorem PRE_first_tail_x15_r0_body.cshift112 (clean : Conv.NClean (⟨20413, 17514, 2762963, 4868⟩ : Conv.Cnt) (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1088.ffi).mlx) (hltC : ∀ h, PH (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1088.ffi).mlx h → h < (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1088.ffi).mlx.next) (nltC : ∀ i, PN (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1088.ffi).mlx i → i < (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1088.ffi).mlx.nnext) (itemsC : ∀ k v, (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1088.ffi).mlx.items.get k = some v → PN (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1088.ffi).mlx k) (tracedC : ∀ h o, (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1088.ffi).mlx.objs.get h = some o → ∀ i ∈ objTraces o, i < PRE_first_tail_x15_r0_body.P112.NL) (cl : SSt (· < 4868) PRE_first_tail_x15_r0_body.cx0_112.mlx)
    (hobjC : ∀ h, PRE_first_tail_x15_r0_body.fxC_112.get h = some () → ((Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1088.ffi).mlx.objs.get h).isSome = true)
    (hfC : ∀ h, (PRE_first_tail_x15_r0_body.krC_112.flags.get h).isSome = true → ((Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1088.ffi).mlx.objs.get h).isSome = true)
    (htC : ∀ h, (PRE_first_tail_x15_r0_body.krC_112.targs.get h).isSome = true → ((Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1088.ffi).mlx.objs.get h).isSome = true)
    (hclC : ∀ h l, PRE_first_tail_x15_r0_body.krC_112.targs.get h = some l → Host.Ts.Sim.Full.STargs (· < (⟨20413, 17514, 2762963, 4868⟩ : Conv.Cnt).n) l) :
    Conv.FullShiftQ PRE_first_tail_x15_r0_body.P112 4868 PRE_first_tail_x15_r0_body.kappa112 PRE_first_tail_x15_r0_body.s1090.ffi PRE_first_tail_x15_r0_body.s1089.ffi :=
  ⟨PRE_first_tail_x15_r0_body.cnshift112 clean hltC nltC itemsC tracedC cl, PRE_first_tail_x15_r0_body.cqueue112, fun t ht => bSN_sound (List.all_eq_true.mp PRE_first_tail_x15_r0_body.ctokSupp112 t ht),
    PRE_first_tail_x15_r0_body.cbridge112,
    liveShift_foot (x0' := Host.Ts.Sim.Full.mlxOf PRE_first_tail_x15_r0_body.s1090.ffi) (x1' := Host.Ts.Sim.Full.mlxOf PRE_first_tail_x15_r0_body.s1089.ffi) (PRE_first_tail_x15_r0_body.cfoot112 clean hltC nltC itemsC tracedC cl) rfl PRE_first_tail_x15_r0_body.ofx0_112 PRE_first_tail_x15_r0_body.ofx1_112 hobjC PRE_first_tail_x15_r0_body.ff0112 PRE_first_tail_x15_r0_body.ff1112 PRE_first_tail_x15_r0_body.ffck112,
    kernShift_foot (x0' := Host.Ts.Sim.Full.mlxOf PRE_first_tail_x15_r0_body.s1090.ffi) (x1' := Host.Ts.Sim.Full.mlxOf PRE_first_tail_x15_r0_body.s1089.ffi) (PRE_first_tail_x15_r0_body.cfoot112 clean hltC nltC itemsC tracedC cl) rfl PRE_first_tail_x15_r0_body.okr0_112 PRE_first_tail_x15_r0_body.okr1_112 (Nat.le_of_ble_eq_true PRE_first_tail_x15_r0_body.fkn112) hfC htC hclC
      PRE_first_tail_x15_r0_body.fkf0112 PRE_first_tail_x15_r0_body.fkt0112 PRE_first_tail_x15_r0_body.fkf1112 PRE_first_tail_x15_r0_body.fkt1112 PRE_first_tail_x15_r0_body.fkck112,
    pendReg_of rfl PRE_first_tail_x15_r0_body.cnh0112 PRE_first_tail_x15_r0_body.cnh1112 (Nat.le_of_ble_eq_true PRE_first_tail_x15_r0_body.cpendLe112) PRE_first_tail_x15_r0_body.cpendR112⟩

end Host.Load.Run.Tpl
