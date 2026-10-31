import host.sim.template.a4pre_first_tail_x15_r0_body.SiteCl103
import host.sim.conv.CompactFull
import host.sim.template.FootGen
set_option Elab.async false
namespace Host.Load.Run.Tpl
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
open Host.Ts Host.Ts.Sim Host.Ts.Sim.Template

/-! The compaction's native shift at call site 103 from its footprint (`Conv.nshift_of_foot`), and the observers'
(`liveShift_foot`, `kernShift_foot`): `Conv.FullShiftQ` for `Conv.full_compactQ`, given the call's bookkeeping and its
relation's facts. -/

/-- The load parameters of the chain (band-free: its start's node counter as `NL` and `N0`). -/
def PRE_first_tail_x15_r0_body.Pc103 : LoadP := ⟨18151, 131072, 1099511627776, 15235, 15235, []⟩
/-- The site's band raised to the map's checked fixed-node prefix, including newly recorded closure traces. -/
def PRE_first_tail_x15_r0_body.P103 : LoadP := PRE_first_tail_x15_r0_body.Pc103.raise 17340
kernel_rfl PRE_first_tail_x15_r0_body.craise103 : Nat.ble PRE_first_tail_x15_r0_body.Pc103.N0 17340 = true
theorem PRE_first_tail_x15_r0_body.raised103 : Host.Ts.Sim.Full.Raised PRE_first_tail_x15_r0_body.Pc103 PRE_first_tail_x15_r0_body.P103 :=
  .inr ⟨17340, rfl, Nat.le_of_ble_eq_true PRE_first_tail_x15_r0_body.craise103, rfl⟩
noncomputable abbrev PRE_first_tail_x15_r0_body.cx0_103 : Host.Load.LSt := clearTokens (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s917.ffi)
noncomputable abbrev PRE_first_tail_x15_r0_body.cx1_103 : Host.Load.LSt := clearTokens (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s916.ffi)
def PRE_first_tail_x15_r0_body.khinv103 : PTrie Nat := Stage.setAll PTrie.nil []
def PRE_first_tail_x15_r0_body.kninv103 : PTrie Nat := Stage.setAll PTrie.nil []
/-- The stage's footprint: its written and fresh handles, fresh nodes, written and fresh items. -/
def PRE_first_tail_x15_r0_body.cwS103 : List Nat := []
def PRE_first_tail_x15_r0_body.cnS103 : List Nat := List.range' 17340 0
def PRE_first_tail_x15_r0_body.ciS103 : List Nat := [] ++ List.range' 17340 0

-- the small checks (`MChecks`'s)
kernel_rfl PRE_first_tail_x15_r0_body.cnh0103 : PRE_first_tail_x15_r0_body.kd103.nh0 = PRE_first_tail_x15_r0_body.cx0_103.mlx.next
kernel_rfl PRE_first_tail_x15_r0_body.cnh1103 : PRE_first_tail_x15_r0_body.kd103.nh1 = PRE_first_tail_x15_r0_body.cx1_103.mlx.next
kernel_rfl PRE_first_tail_x15_r0_body.cnn0103 : PRE_first_tail_x15_r0_body.kd103.nn0 = PRE_first_tail_x15_r0_body.cx0_103.mlx.nnext
kernel_rfl PRE_first_tail_x15_r0_body.cnn1103 : PRE_first_tail_x15_r0_body.kd103.nn1 = PRE_first_tail_x15_r0_body.cx1_103.mlx.nnext
kernel_rfl PRE_first_tail_x15_r0_body.cplo103 : (Nat.blt 0 PRE_first_tail_x15_r0_body.P103.lo && Nat.ble PRE_first_tail_x15_r0_body.P103.lo PRE_first_tail_x15_r0_body.cx0_103.mlx.next && Nat.ble PRE_first_tail_x15_r0_body.P103.lo RData.bigHi && Nat.ble RData.bigHi PRE_first_tail_x15_r0_body.P103.E) = true
kernel_rfl PRE_first_tail_x15_r0_body.ccnt103 : (Nat.ble PRE_first_tail_x15_r0_body.cx0_103.mlx.next PRE_first_tail_x15_r0_body.cx1_103.mlx.next && Nat.ble PRE_first_tail_x15_r0_body.cx0_103.mlx.nnext PRE_first_tail_x15_r0_body.cx1_103.mlx.nnext) = true
kernel_rfl PRE_first_tail_x15_r0_body.cnband103 : (Nat.blt 0 PRE_first_tail_x15_r0_body.P103.NL && Nat.ble PRE_first_tail_x15_r0_body.P103.NL PRE_first_tail_x15_r0_body.P103.N0 && Nat.ble PRE_first_tail_x15_r0_body.P103.N0 PRE_first_tail_x15_r0_body.cx0_103.mlx.nnext) = true
kernel_rfl PRE_first_tail_x15_r0_body.chbelow103 : PRE_first_tail_x15_r0_body.kd103.checkHndBelow = true
kernel_rfl PRE_first_tail_x15_r0_body.chren103 : checkRenG PRE_first_tail_x15_r0_body.kd103.hnd PRE_first_tail_x15_r0_body.khinv103 (phB PRE_first_tail_x15_r0_body.cx0_103.mlx) = true
kernel_rfl PRE_first_tail_x15_r0_body.cband103 : PRE_first_tail_x15_r0_body.kd103.checkBand PRE_first_tail_x15_r0_body.P103.lo = true
kernel_rfl PRE_first_tail_x15_r0_body.cnh1pos103 : Nat.blt 0 PRE_first_tail_x15_r0_body.kd103.nh1 = true
kernel_rfl PRE_first_tail_x15_r0_body.cnren103 : checkRenG PRE_first_tail_x15_r0_body.kd103.node PRE_first_tail_x15_r0_body.kninv103 (pnB PRE_first_tail_x15_r0_body.cx0_103.mlx) = true
kernel_rfl PRE_first_tail_x15_r0_body.cnlow103 : (PTrie.keysA PRE_first_tail_x15_r0_body.kd103.node).all (fun j => Nat.ble PRE_first_tail_x15_r0_body.P103.NL j && Nat.blt (PRE_first_tail_x15_r0_body.kd103.nodeF j) PRE_first_tail_x15_r0_body.cx1_103.mlx.nnext) = true
kernel_rfl PRE_first_tail_x15_r0_body.cabs0a103 : PRE_first_tail_x15_r0_body.cx0_103.mlx.arrs.get 0 = none
kernel_rfl PRE_first_tail_x15_r0_body.cabs0b103 : PRE_first_tail_x15_r0_body.cx0_103.mlx.objs.get 0 = none
kernel_rfl PRE_first_tail_x15_r0_body.ctok1103 : PRE_first_tail_x15_r0_body.cx1_103.mlx.tokens = []
kernel_rfl PRE_first_tail_x15_r0_body.cpend103 : PRE_first_tail_x15_r0_body.cx1_103.mlx.pending = PRE_first_tail_x15_r0_body.cx0_103.mlx.pending.map PRE_first_tail_x15_r0_body.kappa103.pend
kernel_rfl PRE_first_tail_x15_r0_body.cerrh103 : PRE_first_tail_x15_r0_body.cx1_103.mlx.errh = PRE_first_tail_x15_r0_body.cx0_103.mlx.errh.map PRE_first_tail_x15_r0_body.kappa103.arg
kernel_rfl PRE_first_tail_x15_r0_body.cfiles103 : PRE_first_tail_x15_r0_body.cx1_103.mlx.files = PRE_first_tail_x15_r0_body.cx0_103.mlx.files
kernel_rfl PRE_first_tail_x15_r0_body.carch103 : PRE_first_tail_x15_r0_body.cx1_103.mlx.arch = PRE_first_tail_x15_r0_body.cx0_103.mlx.arch
kernel_rfl PRE_first_tail_x15_r0_body.csizes103 : PRE_first_tail_x15_r0_body.cx1_103.mlx.deviceSizes = PRE_first_tail_x15_r0_body.cx0_103.mlx.deviceSizes
kernel_rfl PRE_first_tail_x15_r0_body.cwired103 : PRE_first_tail_x15_r0_body.cx1_103.mlx.wired = PRE_first_tail_x15_r0_body.cx0_103.mlx.wired
kernel_rfl PRE_first_tail_x15_r0_body.chost103 : PRE_first_tail_x15_r0_body.cx1_103.host = PRE_first_tail_x15_r0_body.cx0_103.host
-- the compaction map's addresses are `PRE_first_tail_x15_r0_body.kd103`'s
kernel_rfl PRE_first_tail_x15_r0_body.ckn0103 : PRE_first_tail_x15_r0_body.kd103.n0 = 2755807
kernel_rfl PRE_first_tail_x15_r0_body.ckn1103 : PRE_first_tail_x15_r0_body.kd103.n1 = 2755809
kernel_rfl PRE_first_tail_x15_r0_body.ckheap103 : (PTrie.keysA PRE_first_tail_x15_r0_body.kd103.heap).all (fun x => Nat.ble 2755807 x) = true
kernel_rfl PRE_first_tail_x15_r0_body.ckpl103 : (List.range 0).all (fun j => decide (PRE_first_tail_x15_r0_body.kd103.heap.get (2755807 + j) = nth? PRE_first_tail_x15_r0_body.pl103 j)) = true
-- the map fixes the call's names (`Conv.fixOld_compact`), the call's counters
kernel_rfl PRE_first_tail_x15_r0_body.fja103 : Nat.ble 2755807 2755807 = true
kernel_rfl PRE_first_tail_x15_r0_body.fn103 : Nat.ble 4484 4484 = true
kernel_rfl PRE_first_tail_x15_r0_body.fjaD103 : Nat.ble 2755807 PRE_first_tail_x15_r0_body.kd103.n0 = true
kernel_rfl PRE_first_tail_x15_r0_body.fxn103 : Nat.ble 20234 PRE_first_tail_x15_r0_body.kd103.nh0 = true
kernel_rfl PRE_first_tail_x15_r0_body.fnn103 : Nat.ble 17340 PRE_first_tail_x15_r0_body.kd103.nn0 = true
kernel_rfl PRE_first_tail_x15_r0_body.fxb103 : Nat.ble 20234 RData.bigHi = true
kernel_rfl PRE_first_tail_x15_r0_body.fheap103 : (PTrie.keysA PRE_first_tail_x15_r0_body.kd103.heap).all (Nat.ble (⟨20234, 17340, 2755807, 4484⟩ : Conv.Cnt).ja) = true
kernel_rfl PRE_first_tail_x15_r0_body.fhnd103 : (PTrie.keysA PRE_first_tail_x15_r0_body.kd103.hnd).all (Nat.ble (⟨20234, 17340, 2755807, 4484⟩ : Conv.Cnt).xn) = true
kernel_rfl PRE_first_tail_x15_r0_body.fnode103 : (PTrie.keysA PRE_first_tail_x15_r0_body.kd103.node).all (Nat.ble (⟨20234, 17340, 2755807, 4484⟩ : Conv.Cnt).nn) = true
/-- The compaction map fixes the call's names. -/
theorem PRE_first_tail_x15_r0_body.cfix103 : Conv.FixOld (⟨20234, 17340, 2755807, 4484⟩ : Conv.Cnt) PRE_first_tail_x15_r0_body.kappa103 :=
  Conv.fixOld_compact (Nat.le_of_ble_eq_true PRE_first_tail_x15_r0_body.fja103) (Nat.le_of_ble_eq_true PRE_first_tail_x15_r0_body.fn103) (Nat.le_of_ble_eq_true PRE_first_tail_x15_r0_body.fjaD103) (Nat.le_of_ble_eq_true PRE_first_tail_x15_r0_body.fxn103) (Nat.le_of_ble_eq_true PRE_first_tail_x15_r0_body.fnn103) (Nat.le_of_ble_eq_true PRE_first_tail_x15_r0_body.fxb103) PRE_first_tail_x15_r0_body.fheap103 PRE_first_tail_x15_r0_body.fhnd103 PRE_first_tail_x15_r0_body.fnode103
kernel_rfl PRE_first_tail_x15_r0_body.fcxn103 : (⟨20234, 17340, 2755807, 4484⟩ : Conv.Cnt).xn = (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s915.ffi).mlx.next
kernel_rfl PRE_first_tail_x15_r0_body.fcnn103 : (⟨20234, 17340, 2755807, 4484⟩ : Conv.Cnt).nn = (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s915.ffi).mlx.nnext
kernel_rfl PRE_first_tail_x15_r0_body.fle0103 : (Nat.ble (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s915.ffi).mlx.next PRE_first_tail_x15_r0_body.cx0_103.mlx.next && Nat.ble (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s915.ffi).mlx.nnext PRE_first_tail_x15_r0_body.cx0_103.mlx.nnext && Nat.ble (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s915.ffi).mlx.next RData.bigHi) = true
kernel_rfl PRE_first_tail_x15_r0_body.fnk103 : (PTrie.keysA PRE_first_tail_x15_r0_body.kd103.node).all (Nat.ble (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s915.ffi).mlx.nnext) = true
-- the merged state keeps the call's entries off the stage's footprint
kernel_rfl PRE_first_tail_x15_r0_body.f1A103 : PRE_first_tail_x15_r0_body.cx1_103.mlx.arrs = Stage.setAll (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s915.ffi).mlx.arrs (PRE_first_tail_x15_r0_body.cwS103.filterMap fun i => (PRE_first_tail_x15_r0_body.cx1_103.mlx.arrs.get i).map (i, ·))
kernel_rfl PRE_first_tail_x15_r0_body.f1O103 : PRE_first_tail_x15_r0_body.cx1_103.mlx.objs = Stage.setAll (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s915.ffi).mlx.objs (PRE_first_tail_x15_r0_body.cwS103.filterMap fun i => (PRE_first_tail_x15_r0_body.cx1_103.mlx.objs.get i).map (i, ·))
kernel_rfl PRE_first_tail_x15_r0_body.f1N103 : PRE_first_tail_x15_r0_body.cx1_103.mlx.nodes = Stage.setAll (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s915.ffi).mlx.nodes (PRE_first_tail_x15_r0_body.cnS103.filterMap fun i => (PRE_first_tail_x15_r0_body.cx1_103.mlx.nodes.get i).map (i, ·))
kernel_rfl PRE_first_tail_x15_r0_body.f1I103 : PRE_first_tail_x15_r0_body.cx1_103.mlx.items = Stage.setAll (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s915.ffi).mlx.items (PRE_first_tail_x15_r0_body.ciS103.filterMap fun i => (PRE_first_tail_x15_r0_body.cx1_103.mlx.items.get i).map (i, ·))
kernel_rfl PRE_first_tail_x15_r0_body.fbd103 : (PRE_first_tail_x15_r0_body.clo103 ++ PRE_first_tail_x15_r0_body.cln103 ++ PRE_first_tail_x15_r0_body.cli103 ++ PRE_first_tail_x15_r0_body.cwS103 ++ PRE_first_tail_x15_r0_body.cnS103 ++ PRE_first_tail_x15_r0_body.ciS103).all (fun i => Nat.blt (i / 4096) (4 ^ 31)) = true
kernel_rfl PRE_first_tail_x15_r0_body.fincW103 : PRE_first_tail_x15_r0_body.cwS103.all (fun h => !Nat.blt h (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s915.ffi).mlx.next || PRE_first_tail_x15_r0_body.clo103.contains h) = true
kernel_rfl PRE_first_tail_x15_r0_body.fincI103 : PRE_first_tail_x15_r0_body.ciS103.all (fun k => !Nat.blt k (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s915.ffi).mlx.nnext || PRE_first_tail_x15_r0_body.cli103.contains k) = true
kernel_rfl PRE_first_tail_x15_r0_body.fincN103 : PRE_first_tail_x15_r0_body.cnS103.all (Nat.ble (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s915.ffi).mlx.nnext) = true
kernel_rfl PRE_first_tail_x15_r0_body.flnF103 : PRE_first_tail_x15_r0_body.cln103.all (Nat.ble (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s915.ffi).mlx.nnext) = true
-- the checks over the changed lists
kernel_rfl PRE_first_tail_x15_r0_body.fh103 : PRE_first_tail_x15_r0_body.clo103.all (handleOK PRE_first_tail_x15_r0_body.kappa103 PRE_first_tail_x15_r0_body.P103.lo PRE_first_tail_x15_r0_body.cx0_103.mlx PRE_first_tail_x15_r0_body.cx1_103.mlx) = true
kernel_rfl PRE_first_tail_x15_r0_body.fo103 : PRE_first_tail_x15_r0_body.clo103.map (fun h => PRE_first_tail_x15_r0_body.cx1_103.mlx.objs.get (PRE_first_tail_x15_r0_body.kappa103.handle h)) = PRE_first_tail_x15_r0_body.clo103.map (fun h => (PRE_first_tail_x15_r0_body.cx0_103.mlx.objs.get h).map PRE_first_tail_x15_r0_body.kappa103.nobj)
kernel_rfl PRE_first_tail_x15_r0_body.fok103 : PRE_first_tail_x15_r0_body.clo103.all (objOK PRE_first_tail_x15_r0_body.kappa103 PRE_first_tail_x15_r0_body.P103.NL PRE_first_tail_x15_r0_body.cx0_103.mlx) = true
kernel_rfl PRE_first_tail_x15_r0_body.fnd103 : PRE_first_tail_x15_r0_body.cln103.all (nodeOKF PRE_first_tail_x15_r0_body.kappa103 PRE_first_tail_x15_r0_body.P103 PRE_first_tail_x15_r0_body.cx0_103.mlx PRE_first_tail_x15_r0_body.cx1_103.mlx) = true
kernel_rfl PRE_first_tail_x15_r0_body.fp103 : ((PRE_first_tail_x15_r0_body.cln103.filter (fullB PRE_first_tail_x15_r0_body.P103))).map (fun i => (PRE_first_tail_x15_r0_body.cx1_103.mlx.nodes.get (PRE_first_tail_x15_r0_body.kappa103.node i)).map Host.Mlx.Ffi.Node.prim) =
  ((PRE_first_tail_x15_r0_body.cln103.filter (fullB PRE_first_tail_x15_r0_body.P103))).map (fun i => (PRE_first_tail_x15_r0_body.cx0_103.mlx.nodes.get i).map fun nd => PRE_first_tail_x15_r0_body.kappa103.prim nd.prim)
kernel_rfl PRE_first_tail_x15_r0_body.fnordI103 : incrB PRE_first_tail_x15_r0_body.kd103.nodeF (List.range' 17340 0) = true
kernel_rfl PRE_first_tail_x15_r0_body.fnordK103 : (PTrie.keysA PRE_first_tail_x15_r0_body.kd103.node).all (fun k => Nat.ble 17340 k && Nat.blt k 17340) = true
kernel_rfl PRE_first_tail_x15_r0_body.fnordL103 : (PRE_first_tail_x15_r0_body.cln103.filter (Nat.ble PRE_first_tail_x15_r0_body.P103.N0)).all (fun i => Nat.ble i (PRE_first_tail_x15_r0_body.kd103.nodeF i) && (Nat.blt i 17340 || Nat.ble PRE_first_tail_x15_r0_body.kd103.nn0 i)) = true
theorem PRE_first_tail_x15_r0_body.fnord103 : (PRE_first_tail_x15_r0_body.cln103.filter (Nat.ble PRE_first_tail_x15_r0_body.P103.N0)).all (fun i => Nat.ble i (PRE_first_tail_x15_r0_body.kd103.nodeF i) &&
    (PTrie.keysA PRE_first_tail_x15_r0_body.kd103.node).all fun j => !Nat.blt j i || Nat.blt (PRE_first_tail_x15_r0_body.kd103.nodeF j) (PRE_first_tail_x15_r0_body.kd103.nodeF i)) = true :=
  cnord_of PRE_first_tail_x15_r0_body.cnlow103 PRE_first_tail_x15_r0_body.cnn1103 PRE_first_tail_x15_r0_body.fnordI103 PRE_first_tail_x15_r0_body.fnordK103 PRE_first_tail_x15_r0_body.fnordL103
kernel_rfl PRE_first_tail_x15_r0_body.fi103 : PRE_first_tail_x15_r0_body.cli103.all (pnB PRE_first_tail_x15_r0_body.cx0_103.mlx) = true
kernel_rfl PRE_first_tail_x15_r0_body.fii103 : PRE_first_tail_x15_r0_body.cli103.all (fun k => decide (PRE_first_tail_x15_r0_body.cx1_103.mlx.items.get (PRE_first_tail_x15_r0_body.kappa103.node k) = (PRE_first_tail_x15_r0_body.cx0_103.mlx.items.get k).map PRE_first_tail_x15_r0_body.kappa103.nv)) = true
/-- **The compaction's footprint.** -/
theorem PRE_first_tail_x15_r0_body.cfoot103 (clean : Conv.NClean (⟨20234, 17340, 2755807, 4484⟩ : Conv.Cnt) (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s915.ffi).mlx) (hltC : ∀ h, PH (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s915.ffi).mlx h → h < (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s915.ffi).mlx.next) (nltC : ∀ i, PN (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s915.ffi).mlx i → i < (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s915.ffi).mlx.nnext) (itemsC : ∀ k v, (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s915.ffi).mlx.items.get k = some v → PN (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s915.ffi).mlx k) (tracedC : ∀ h o, (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s915.ffi).mlx.objs.get h = some o → ∀ i ∈ objTraces o, i < PRE_first_tail_x15_r0_body.P103.NL) (cl : SSt (· < 4484) PRE_first_tail_x15_r0_body.cx0_103.mlx) :
    Conv.MFoot PRE_first_tail_x15_r0_body.P103 4484 PRE_first_tail_x15_r0_body.kappa103 PRE_first_tail_x15_r0_body.kd103 PRE_first_tail_x15_r0_body.khinv103 PRE_first_tail_x15_r0_body.kninv103 (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s915.ffi).mlx PRE_first_tail_x15_r0_body.cx0_103.mlx PRE_first_tail_x15_r0_body.cx1_103.mlx (⟨20234, 17340, 2755807, 4484⟩ : Conv.Cnt) PRE_first_tail_x15_r0_body.clo103 PRE_first_tail_x15_r0_body.cln103 PRE_first_tail_x15_r0_body.cli103 PRE_first_tail_x15_r0_body.cwS103 PRE_first_tail_x15_r0_body.cnS103 PRE_first_tail_x15_r0_body.ciS103 :=
  ⟨rfl, rfl, rfl, PRE_first_tail_x15_r0_body.cnh0103, PRE_first_tail_x15_r0_body.cnh1103, PRE_first_tail_x15_r0_body.cnn0103, PRE_first_tail_x15_r0_body.cnn1103, PRE_first_tail_x15_r0_body.cplo103, PRE_first_tail_x15_r0_body.ccnt103, PRE_first_tail_x15_r0_body.cnband103, PRE_first_tail_x15_r0_body.chbelow103, PRE_first_tail_x15_r0_body.chren103, PRE_first_tail_x15_r0_body.cband103, PRE_first_tail_x15_r0_body.cnh1pos103, PRE_first_tail_x15_r0_body.cnren103, PRE_first_tail_x15_r0_body.cnlow103, PRE_first_tail_x15_r0_body.cabs0a103, PRE_first_tail_x15_r0_body.cabs0b103, PRE_first_tail_x15_r0_body.ctok1103, PRE_first_tail_x15_r0_body.cpend103, PRE_first_tail_x15_r0_body.cerrh103, PRE_first_tail_x15_r0_body.cfiles103, PRE_first_tail_x15_r0_body.carch103, PRE_first_tail_x15_r0_body.csizes103, PRE_first_tail_x15_r0_body.cwired103, PRE_first_tail_x15_r0_body.cfix103, clean, PRE_first_tail_x15_r0_body.fcxn103, PRE_first_tail_x15_r0_body.fcnn103, hltC, nltC, itemsC, tracedC, cl, PRE_first_tail_x15_r0_body.fle0103, PRE_first_tail_x15_r0_body.fnk103, PRE_first_tail_x15_r0_body.ckA103, PRE_first_tail_x15_r0_body.cobjsK103, PRE_first_tail_x15_r0_body.cnodesK103, PRE_first_tail_x15_r0_body.citemsK103, PRE_first_tail_x15_r0_body.f1A103, PRE_first_tail_x15_r0_body.f1O103, PRE_first_tail_x15_r0_body.f1N103, PRE_first_tail_x15_r0_body.f1I103, PRE_first_tail_x15_r0_body.fbd103, PRE_first_tail_x15_r0_body.fincW103, PRE_first_tail_x15_r0_body.fincI103, PRE_first_tail_x15_r0_body.fincN103, PRE_first_tail_x15_r0_body.flnF103, PRE_first_tail_x15_r0_body.fh103, PRE_first_tail_x15_r0_body.fo103, PRE_first_tail_x15_r0_body.fok103, PRE_first_tail_x15_r0_body.fnd103, PRE_first_tail_x15_r0_body.fp103, PRE_first_tail_x15_r0_body.fnord103, PRE_first_tail_x15_r0_body.fi103, PRE_first_tail_x15_r0_body.fii103⟩
theorem PRE_first_tail_x15_r0_body.cnshift103 (clean : Conv.NClean (⟨20234, 17340, 2755807, 4484⟩ : Conv.Cnt) (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s915.ffi).mlx) (hltC : ∀ h, PH (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s915.ffi).mlx h → h < (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s915.ffi).mlx.next) (nltC : ∀ i, PN (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s915.ffi).mlx i → i < (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s915.ffi).mlx.nnext) (itemsC : ∀ k v, (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s915.ffi).mlx.items.get k = some v → PN (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s915.ffi).mlx k) (tracedC : ∀ h o, (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s915.ffi).mlx.objs.get h = some o → ∀ i ∈ objTraces o, i < PRE_first_tail_x15_r0_body.P103.NL) (cl : SSt (· < 4484) PRE_first_tail_x15_r0_body.cx0_103.mlx) : NShift PRE_first_tail_x15_r0_body.P103 4484 PRE_first_tail_x15_r0_body.kappa103 PRE_first_tail_x15_r0_body.cx0_103 PRE_first_tail_x15_r0_body.cx1_103 :=
  Conv.nshift_of_foot (PRE_first_tail_x15_r0_body.cfoot103 clean hltC nltC itemsC tracedC cl) PRE_first_tail_x15_r0_body.chost103 (compact_a_eq PRE_first_tail_x15_r0_body.ckn0103 PRE_first_tail_x15_r0_body.ckn1103 PRE_first_tail_x15_r0_body.ckheap103 PRE_first_tail_x15_r0_body.ckpl103)

-- the observers: the layers' states at the call, the canonical and the merged state, their footprints and checks
noncomputable def PRE_first_tail_x15_r0_body.fxC_103 : PTrie Unit := (Host.Ts.Sim.Full.freedOf PRE_first_tail_x15_r0_body.s915.ffi).getD PTrie.nil
noncomputable def PRE_first_tail_x15_r0_body.krC_103 : Host.Load.Layers.KRec := (Host.Ts.Sim.Full.krecOf PRE_first_tail_x15_r0_body.s915.ffi).getD Host.Load.Layers.KRec.empty
kernel_rfl PRE_first_tail_x15_r0_body.ofxC_103 : (Host.Ts.Sim.Full.freedOf PRE_first_tail_x15_r0_body.s915.ffi) = some PRE_first_tail_x15_r0_body.fxC_103
kernel_rfl PRE_first_tail_x15_r0_body.okrC_103 : (Host.Ts.Sim.Full.krecOf PRE_first_tail_x15_r0_body.s915.ffi) = some PRE_first_tail_x15_r0_body.krC_103
noncomputable def PRE_first_tail_x15_r0_body.fx0_103 : PTrie Unit := (Host.Ts.Sim.Full.freedOf PRE_first_tail_x15_r0_body.s917.ffi).getD PTrie.nil
noncomputable def PRE_first_tail_x15_r0_body.kr0_103 : Host.Load.Layers.KRec := (Host.Ts.Sim.Full.krecOf PRE_first_tail_x15_r0_body.s917.ffi).getD Host.Load.Layers.KRec.empty
kernel_rfl PRE_first_tail_x15_r0_body.ofx0_103 : (Host.Ts.Sim.Full.freedOf PRE_first_tail_x15_r0_body.s917.ffi) = some PRE_first_tail_x15_r0_body.fx0_103
kernel_rfl PRE_first_tail_x15_r0_body.okr0_103 : (Host.Ts.Sim.Full.krecOf PRE_first_tail_x15_r0_body.s917.ffi) = some PRE_first_tail_x15_r0_body.kr0_103
noncomputable def PRE_first_tail_x15_r0_body.fx1_103 : PTrie Unit := (Host.Ts.Sim.Full.freedOf PRE_first_tail_x15_r0_body.s916.ffi).getD PTrie.nil
noncomputable def PRE_first_tail_x15_r0_body.kr1_103 : Host.Load.Layers.KRec := (Host.Ts.Sim.Full.krecOf PRE_first_tail_x15_r0_body.s916.ffi).getD Host.Load.Layers.KRec.empty
kernel_rfl PRE_first_tail_x15_r0_body.ofx1_103 : (Host.Ts.Sim.Full.freedOf PRE_first_tail_x15_r0_body.s916.ffi) = some PRE_first_tail_x15_r0_body.fx1_103
kernel_rfl PRE_first_tail_x15_r0_body.okr1_103 : (Host.Ts.Sim.Full.krecOf PRE_first_tail_x15_r0_body.s916.ffi) = some PRE_first_tail_x15_r0_body.kr1_103
kernel_rfl PRE_first_tail_x15_r0_body.ff0103 : PRE_first_tail_x15_r0_body.fx0_103 = Stage.setAll PRE_first_tail_x15_r0_body.fxC_103 (PRE_first_tail_x15_r0_body.clo103.filterMap fun i => (PRE_first_tail_x15_r0_body.fx0_103.get i).map (i, ·))
kernel_rfl PRE_first_tail_x15_r0_body.ff1103 : PRE_first_tail_x15_r0_body.fx1_103 = Stage.setAll PRE_first_tail_x15_r0_body.fxC_103 (PRE_first_tail_x15_r0_body.cwS103.filterMap fun i => (PRE_first_tail_x15_r0_body.fx1_103.get i).map (i, ·))
kernel_rfl PRE_first_tail_x15_r0_body.ffck103 : freedLB PRE_first_tail_x15_r0_body.kappa103 PRE_first_tail_x15_r0_body.cx0_103.mlx PRE_first_tail_x15_r0_body.fx0_103 PRE_first_tail_x15_r0_body.fx1_103 PRE_first_tail_x15_r0_body.clo103 = true
kernel_rfl PRE_first_tail_x15_r0_body.fkf0103 : PRE_first_tail_x15_r0_body.kr0_103.flags = Stage.setAll PRE_first_tail_x15_r0_body.krC_103.flags (PRE_first_tail_x15_r0_body.clo103.filterMap fun i => (PRE_first_tail_x15_r0_body.kr0_103.flags.get i).map (i, ·))
kernel_rfl PRE_first_tail_x15_r0_body.fkt0103 : PRE_first_tail_x15_r0_body.kr0_103.targs = Stage.setAll PRE_first_tail_x15_r0_body.krC_103.targs (PRE_first_tail_x15_r0_body.clo103.filterMap fun i => (PRE_first_tail_x15_r0_body.kr0_103.targs.get i).map (i, ·))
kernel_rfl PRE_first_tail_x15_r0_body.fkf1103 : PRE_first_tail_x15_r0_body.kr1_103.flags = Stage.setAll PRE_first_tail_x15_r0_body.krC_103.flags (PRE_first_tail_x15_r0_body.cwS103.filterMap fun i => (PRE_first_tail_x15_r0_body.kr1_103.flags.get i).map (i, ·))
kernel_rfl PRE_first_tail_x15_r0_body.fkt1103 : PRE_first_tail_x15_r0_body.kr1_103.targs = Stage.setAll PRE_first_tail_x15_r0_body.krC_103.targs (PRE_first_tail_x15_r0_body.cwS103.filterMap fun i => (PRE_first_tail_x15_r0_body.kr1_103.targs.get i).map (i, ·))
kernel_rfl PRE_first_tail_x15_r0_body.fkck103 : krecLB PRE_first_tail_x15_r0_body.kappa103 4484 PRE_first_tail_x15_r0_body.cx0_103.mlx PRE_first_tail_x15_r0_body.kr0_103 PRE_first_tail_x15_r0_body.kr1_103 PRE_first_tail_x15_r0_body.clo103 = true
kernel_rfl PRE_first_tail_x15_r0_body.fkn103 : Nat.ble 4484 4484 = true
-- the bridge and the pending traces' regions
kernel_rfl PRE_first_tail_x15_r0_body.cbridge103 : Host.Ts.Sim.Full.bridgeOf PRE_first_tail_x15_r0_body.s916.ffi = Host.Ts.Sim.Full.bridgeOf PRE_first_tail_x15_r0_body.s917.ffi
kernel_rfl PRE_first_tail_x15_r0_body.cpendR103 : pendRegB PRE_first_tail_x15_r0_body.kappa103 (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s917.ffi).mlx = true
kernel_rfl PRE_first_tail_x15_r0_body.cpendLe103 : Nat.ble (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s917.ffi).mlx.next (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s916.ffi).mlx.next = true
/-- **The compaction's native shift**, given the call's bookkeeping, its relation's facts (the model's and the
observers') and the canonical closedness. -/
theorem PRE_first_tail_x15_r0_body.cshift103 (clean : Conv.NClean (⟨20234, 17340, 2755807, 4484⟩ : Conv.Cnt) (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s915.ffi).mlx) (hltC : ∀ h, PH (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s915.ffi).mlx h → h < (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s915.ffi).mlx.next) (nltC : ∀ i, PN (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s915.ffi).mlx i → i < (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s915.ffi).mlx.nnext) (itemsC : ∀ k v, (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s915.ffi).mlx.items.get k = some v → PN (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s915.ffi).mlx k) (tracedC : ∀ h o, (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s915.ffi).mlx.objs.get h = some o → ∀ i ∈ objTraces o, i < PRE_first_tail_x15_r0_body.P103.NL) (cl : SSt (· < 4484) PRE_first_tail_x15_r0_body.cx0_103.mlx)
    (hobjC : ∀ h, PRE_first_tail_x15_r0_body.fxC_103.get h = some () → ((Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s915.ffi).mlx.objs.get h).isSome = true)
    (hfC : ∀ h, (PRE_first_tail_x15_r0_body.krC_103.flags.get h).isSome = true → ((Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s915.ffi).mlx.objs.get h).isSome = true)
    (htC : ∀ h, (PRE_first_tail_x15_r0_body.krC_103.targs.get h).isSome = true → ((Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s915.ffi).mlx.objs.get h).isSome = true)
    (hclC : ∀ h l, PRE_first_tail_x15_r0_body.krC_103.targs.get h = some l → Host.Ts.Sim.Full.STargs (· < (⟨20234, 17340, 2755807, 4484⟩ : Conv.Cnt).n) l) :
    Conv.FullShiftQ PRE_first_tail_x15_r0_body.P103 4484 PRE_first_tail_x15_r0_body.kappa103 PRE_first_tail_x15_r0_body.s917.ffi PRE_first_tail_x15_r0_body.s916.ffi :=
  ⟨PRE_first_tail_x15_r0_body.cnshift103 clean hltC nltC itemsC tracedC cl, PRE_first_tail_x15_r0_body.cqueue103, fun t ht => bSN_sound (List.all_eq_true.mp PRE_first_tail_x15_r0_body.ctokSupp103 t ht),
    PRE_first_tail_x15_r0_body.cbridge103,
    liveShift_foot (x0' := Host.Ts.Sim.Full.mlxOf PRE_first_tail_x15_r0_body.s917.ffi) (x1' := Host.Ts.Sim.Full.mlxOf PRE_first_tail_x15_r0_body.s916.ffi) (PRE_first_tail_x15_r0_body.cfoot103 clean hltC nltC itemsC tracedC cl) rfl PRE_first_tail_x15_r0_body.ofx0_103 PRE_first_tail_x15_r0_body.ofx1_103 hobjC PRE_first_tail_x15_r0_body.ff0103 PRE_first_tail_x15_r0_body.ff1103 PRE_first_tail_x15_r0_body.ffck103,
    kernShift_foot (x0' := Host.Ts.Sim.Full.mlxOf PRE_first_tail_x15_r0_body.s917.ffi) (x1' := Host.Ts.Sim.Full.mlxOf PRE_first_tail_x15_r0_body.s916.ffi) (PRE_first_tail_x15_r0_body.cfoot103 clean hltC nltC itemsC tracedC cl) rfl PRE_first_tail_x15_r0_body.okr0_103 PRE_first_tail_x15_r0_body.okr1_103 (Nat.le_of_ble_eq_true PRE_first_tail_x15_r0_body.fkn103) hfC htC hclC
      PRE_first_tail_x15_r0_body.fkf0103 PRE_first_tail_x15_r0_body.fkt0103 PRE_first_tail_x15_r0_body.fkf1103 PRE_first_tail_x15_r0_body.fkt1103 PRE_first_tail_x15_r0_body.fkck103,
    pendReg_of rfl PRE_first_tail_x15_r0_body.cnh0103 PRE_first_tail_x15_r0_body.cnh1103 (Nat.le_of_ble_eq_true PRE_first_tail_x15_r0_body.cpendLe103) PRE_first_tail_x15_r0_body.cpendR103⟩

end Host.Load.Run.Tpl
