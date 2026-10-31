import host.sim.template.a4pre_first_tail_x15_r0_body.SiteCl104
import host.sim.conv.CompactFull
import host.sim.template.FootGen
set_option Elab.async false
namespace Host.Load.Run.Tpl
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
open Host.Ts Host.Ts.Sim Host.Ts.Sim.Template

/-! The compaction's native shift at call site 104 from its footprint (`Conv.nshift_of_foot`), and the observers'
(`liveShift_foot`, `kernShift_foot`): `Conv.FullShiftQ` for `Conv.full_compactQ`, given the call's bookkeeping and its
relation's facts. -/

/-- The load parameters of the chain (band-free: its start's node counter as `NL` and `N0`). -/
def PRE_first_tail_x15_r0_body.Pc104 : LoadP := ⟨18151, 131072, 1099511627776, 15235, 15235, []⟩
/-- The site's band raised to the map's checked fixed-node prefix, including newly recorded closure traces. -/
def PRE_first_tail_x15_r0_body.P104 : LoadP := PRE_first_tail_x15_r0_body.Pc104.raise 17344
kernel_rfl PRE_first_tail_x15_r0_body.craise104 : Nat.ble PRE_first_tail_x15_r0_body.Pc104.N0 17344 = true
theorem PRE_first_tail_x15_r0_body.raised104 : Host.Ts.Sim.Full.Raised PRE_first_tail_x15_r0_body.Pc104 PRE_first_tail_x15_r0_body.P104 :=
  .inr ⟨17344, rfl, Nat.le_of_ble_eq_true PRE_first_tail_x15_r0_body.craise104, rfl⟩
noncomputable abbrev PRE_first_tail_x15_r0_body.cx0_104 : Host.Load.LSt := clearTokens (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s921.ffi)
noncomputable abbrev PRE_first_tail_x15_r0_body.cx1_104 : Host.Load.LSt := clearTokens (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s920.ffi)
def PRE_first_tail_x15_r0_body.khinv104 : PTrie Nat := Stage.setAll PTrie.nil []
def PRE_first_tail_x15_r0_body.kninv104 : PTrie Nat := Stage.setAll PTrie.nil []
/-- The stage's footprint: its written and fresh handles, fresh nodes, written and fresh items. -/
def PRE_first_tail_x15_r0_body.cwS104 : List Nat := []
def PRE_first_tail_x15_r0_body.cnS104 : List Nat := List.range' 17344 0
def PRE_first_tail_x15_r0_body.ciS104 : List Nat := [] ++ List.range' 17344 0

-- the small checks (`MChecks`'s)
kernel_rfl PRE_first_tail_x15_r0_body.cnh0104 : PRE_first_tail_x15_r0_body.kd104.nh0 = PRE_first_tail_x15_r0_body.cx0_104.mlx.next
kernel_rfl PRE_first_tail_x15_r0_body.cnh1104 : PRE_first_tail_x15_r0_body.kd104.nh1 = PRE_first_tail_x15_r0_body.cx1_104.mlx.next
kernel_rfl PRE_first_tail_x15_r0_body.cnn0104 : PRE_first_tail_x15_r0_body.kd104.nn0 = PRE_first_tail_x15_r0_body.cx0_104.mlx.nnext
kernel_rfl PRE_first_tail_x15_r0_body.cnn1104 : PRE_first_tail_x15_r0_body.kd104.nn1 = PRE_first_tail_x15_r0_body.cx1_104.mlx.nnext
kernel_rfl PRE_first_tail_x15_r0_body.cplo104 : (Nat.blt 0 PRE_first_tail_x15_r0_body.P104.lo && Nat.ble PRE_first_tail_x15_r0_body.P104.lo PRE_first_tail_x15_r0_body.cx0_104.mlx.next && Nat.ble PRE_first_tail_x15_r0_body.P104.lo RData.bigHi && Nat.ble RData.bigHi PRE_first_tail_x15_r0_body.P104.E) = true
kernel_rfl PRE_first_tail_x15_r0_body.ccnt104 : (Nat.ble PRE_first_tail_x15_r0_body.cx0_104.mlx.next PRE_first_tail_x15_r0_body.cx1_104.mlx.next && Nat.ble PRE_first_tail_x15_r0_body.cx0_104.mlx.nnext PRE_first_tail_x15_r0_body.cx1_104.mlx.nnext) = true
kernel_rfl PRE_first_tail_x15_r0_body.cnband104 : (Nat.blt 0 PRE_first_tail_x15_r0_body.P104.NL && Nat.ble PRE_first_tail_x15_r0_body.P104.NL PRE_first_tail_x15_r0_body.P104.N0 && Nat.ble PRE_first_tail_x15_r0_body.P104.N0 PRE_first_tail_x15_r0_body.cx0_104.mlx.nnext) = true
kernel_rfl PRE_first_tail_x15_r0_body.chbelow104 : PRE_first_tail_x15_r0_body.kd104.checkHndBelow = true
kernel_rfl PRE_first_tail_x15_r0_body.chren104 : checkRenG PRE_first_tail_x15_r0_body.kd104.hnd PRE_first_tail_x15_r0_body.khinv104 (phB PRE_first_tail_x15_r0_body.cx0_104.mlx) = true
kernel_rfl PRE_first_tail_x15_r0_body.cband104 : PRE_first_tail_x15_r0_body.kd104.checkBand PRE_first_tail_x15_r0_body.P104.lo = true
kernel_rfl PRE_first_tail_x15_r0_body.cnh1pos104 : Nat.blt 0 PRE_first_tail_x15_r0_body.kd104.nh1 = true
kernel_rfl PRE_first_tail_x15_r0_body.cnren104 : checkRenG PRE_first_tail_x15_r0_body.kd104.node PRE_first_tail_x15_r0_body.kninv104 (pnB PRE_first_tail_x15_r0_body.cx0_104.mlx) = true
kernel_rfl PRE_first_tail_x15_r0_body.cnlow104 : (PTrie.keysA PRE_first_tail_x15_r0_body.kd104.node).all (fun j => Nat.ble PRE_first_tail_x15_r0_body.P104.NL j && Nat.blt (PRE_first_tail_x15_r0_body.kd104.nodeF j) PRE_first_tail_x15_r0_body.cx1_104.mlx.nnext) = true
kernel_rfl PRE_first_tail_x15_r0_body.cabs0a104 : PRE_first_tail_x15_r0_body.cx0_104.mlx.arrs.get 0 = none
kernel_rfl PRE_first_tail_x15_r0_body.cabs0b104 : PRE_first_tail_x15_r0_body.cx0_104.mlx.objs.get 0 = none
kernel_rfl PRE_first_tail_x15_r0_body.ctok1104 : PRE_first_tail_x15_r0_body.cx1_104.mlx.tokens = []
kernel_rfl PRE_first_tail_x15_r0_body.cpend104 : PRE_first_tail_x15_r0_body.cx1_104.mlx.pending = PRE_first_tail_x15_r0_body.cx0_104.mlx.pending.map PRE_first_tail_x15_r0_body.kappa104.pend
kernel_rfl PRE_first_tail_x15_r0_body.cerrh104 : PRE_first_tail_x15_r0_body.cx1_104.mlx.errh = PRE_first_tail_x15_r0_body.cx0_104.mlx.errh.map PRE_first_tail_x15_r0_body.kappa104.arg
kernel_rfl PRE_first_tail_x15_r0_body.cfiles104 : PRE_first_tail_x15_r0_body.cx1_104.mlx.files = PRE_first_tail_x15_r0_body.cx0_104.mlx.files
kernel_rfl PRE_first_tail_x15_r0_body.carch104 : PRE_first_tail_x15_r0_body.cx1_104.mlx.arch = PRE_first_tail_x15_r0_body.cx0_104.mlx.arch
kernel_rfl PRE_first_tail_x15_r0_body.csizes104 : PRE_first_tail_x15_r0_body.cx1_104.mlx.deviceSizes = PRE_first_tail_x15_r0_body.cx0_104.mlx.deviceSizes
kernel_rfl PRE_first_tail_x15_r0_body.cwired104 : PRE_first_tail_x15_r0_body.cx1_104.mlx.wired = PRE_first_tail_x15_r0_body.cx0_104.mlx.wired
kernel_rfl PRE_first_tail_x15_r0_body.chost104 : PRE_first_tail_x15_r0_body.cx1_104.host = PRE_first_tail_x15_r0_body.cx0_104.host
-- the compaction map's addresses are `PRE_first_tail_x15_r0_body.kd104`'s
kernel_rfl PRE_first_tail_x15_r0_body.ckn0104 : PRE_first_tail_x15_r0_body.kd104.n0 = 2756096
kernel_rfl PRE_first_tail_x15_r0_body.ckn1104 : PRE_first_tail_x15_r0_body.kd104.n1 = 2756106
kernel_rfl PRE_first_tail_x15_r0_body.ckheap104 : (PTrie.keysA PRE_first_tail_x15_r0_body.kd104.heap).all (fun x => Nat.ble 2756095 x) = true
kernel_rfl PRE_first_tail_x15_r0_body.ckpl104 : (List.range 1).all (fun j => decide (PRE_first_tail_x15_r0_body.kd104.heap.get (2756095 + j) = nth? PRE_first_tail_x15_r0_body.pl104 j)) = true
-- the map fixes the call's names (`Conv.fixOld_compact`), the call's counters
kernel_rfl PRE_first_tail_x15_r0_body.fja104 : Nat.ble 2756095 2756095 = true
kernel_rfl PRE_first_tail_x15_r0_body.fn104 : Nat.ble 4501 4501 = true
kernel_rfl PRE_first_tail_x15_r0_body.fjaD104 : Nat.ble 2756095 PRE_first_tail_x15_r0_body.kd104.n0 = true
kernel_rfl PRE_first_tail_x15_r0_body.fxn104 : Nat.ble 20241 PRE_first_tail_x15_r0_body.kd104.nh0 = true
kernel_rfl PRE_first_tail_x15_r0_body.fnn104 : Nat.ble 17344 PRE_first_tail_x15_r0_body.kd104.nn0 = true
kernel_rfl PRE_first_tail_x15_r0_body.fxb104 : Nat.ble 20241 RData.bigHi = true
kernel_rfl PRE_first_tail_x15_r0_body.fheap104 : (PTrie.keysA PRE_first_tail_x15_r0_body.kd104.heap).all (Nat.ble (⟨20241, 17344, 2756095, 4501⟩ : Conv.Cnt).ja) = true
kernel_rfl PRE_first_tail_x15_r0_body.fhnd104 : (PTrie.keysA PRE_first_tail_x15_r0_body.kd104.hnd).all (Nat.ble (⟨20241, 17344, 2756095, 4501⟩ : Conv.Cnt).xn) = true
kernel_rfl PRE_first_tail_x15_r0_body.fnode104 : (PTrie.keysA PRE_first_tail_x15_r0_body.kd104.node).all (Nat.ble (⟨20241, 17344, 2756095, 4501⟩ : Conv.Cnt).nn) = true
/-- The compaction map fixes the call's names. -/
theorem PRE_first_tail_x15_r0_body.cfix104 : Conv.FixOld (⟨20241, 17344, 2756095, 4501⟩ : Conv.Cnt) PRE_first_tail_x15_r0_body.kappa104 :=
  Conv.fixOld_compact (Nat.le_of_ble_eq_true PRE_first_tail_x15_r0_body.fja104) (Nat.le_of_ble_eq_true PRE_first_tail_x15_r0_body.fn104) (Nat.le_of_ble_eq_true PRE_first_tail_x15_r0_body.fjaD104) (Nat.le_of_ble_eq_true PRE_first_tail_x15_r0_body.fxn104) (Nat.le_of_ble_eq_true PRE_first_tail_x15_r0_body.fnn104) (Nat.le_of_ble_eq_true PRE_first_tail_x15_r0_body.fxb104) PRE_first_tail_x15_r0_body.fheap104 PRE_first_tail_x15_r0_body.fhnd104 PRE_first_tail_x15_r0_body.fnode104
kernel_rfl PRE_first_tail_x15_r0_body.fcxn104 : (⟨20241, 17344, 2756095, 4501⟩ : Conv.Cnt).xn = (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s919.ffi).mlx.next
kernel_rfl PRE_first_tail_x15_r0_body.fcnn104 : (⟨20241, 17344, 2756095, 4501⟩ : Conv.Cnt).nn = (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s919.ffi).mlx.nnext
kernel_rfl PRE_first_tail_x15_r0_body.fle0104 : (Nat.ble (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s919.ffi).mlx.next PRE_first_tail_x15_r0_body.cx0_104.mlx.next && Nat.ble (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s919.ffi).mlx.nnext PRE_first_tail_x15_r0_body.cx0_104.mlx.nnext && Nat.ble (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s919.ffi).mlx.next RData.bigHi) = true
kernel_rfl PRE_first_tail_x15_r0_body.fnk104 : (PTrie.keysA PRE_first_tail_x15_r0_body.kd104.node).all (Nat.ble (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s919.ffi).mlx.nnext) = true
-- the merged state keeps the call's entries off the stage's footprint
kernel_rfl PRE_first_tail_x15_r0_body.f1A104 : PRE_first_tail_x15_r0_body.cx1_104.mlx.arrs = Stage.setAll (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s919.ffi).mlx.arrs (PRE_first_tail_x15_r0_body.cwS104.filterMap fun i => (PRE_first_tail_x15_r0_body.cx1_104.mlx.arrs.get i).map (i, ·))
kernel_rfl PRE_first_tail_x15_r0_body.f1O104 : PRE_first_tail_x15_r0_body.cx1_104.mlx.objs = Stage.setAll (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s919.ffi).mlx.objs (PRE_first_tail_x15_r0_body.cwS104.filterMap fun i => (PRE_first_tail_x15_r0_body.cx1_104.mlx.objs.get i).map (i, ·))
kernel_rfl PRE_first_tail_x15_r0_body.f1N104 : PRE_first_tail_x15_r0_body.cx1_104.mlx.nodes = Stage.setAll (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s919.ffi).mlx.nodes (PRE_first_tail_x15_r0_body.cnS104.filterMap fun i => (PRE_first_tail_x15_r0_body.cx1_104.mlx.nodes.get i).map (i, ·))
kernel_rfl PRE_first_tail_x15_r0_body.f1I104 : PRE_first_tail_x15_r0_body.cx1_104.mlx.items = Stage.setAll (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s919.ffi).mlx.items (PRE_first_tail_x15_r0_body.ciS104.filterMap fun i => (PRE_first_tail_x15_r0_body.cx1_104.mlx.items.get i).map (i, ·))
kernel_rfl PRE_first_tail_x15_r0_body.fbd104 : (PRE_first_tail_x15_r0_body.clo104 ++ PRE_first_tail_x15_r0_body.cln104 ++ PRE_first_tail_x15_r0_body.cli104 ++ PRE_first_tail_x15_r0_body.cwS104 ++ PRE_first_tail_x15_r0_body.cnS104 ++ PRE_first_tail_x15_r0_body.ciS104).all (fun i => Nat.blt (i / 4096) (4 ^ 31)) = true
kernel_rfl PRE_first_tail_x15_r0_body.fincW104 : PRE_first_tail_x15_r0_body.cwS104.all (fun h => !Nat.blt h (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s919.ffi).mlx.next || PRE_first_tail_x15_r0_body.clo104.contains h) = true
kernel_rfl PRE_first_tail_x15_r0_body.fincI104 : PRE_first_tail_x15_r0_body.ciS104.all (fun k => !Nat.blt k (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s919.ffi).mlx.nnext || PRE_first_tail_x15_r0_body.cli104.contains k) = true
kernel_rfl PRE_first_tail_x15_r0_body.fincN104 : PRE_first_tail_x15_r0_body.cnS104.all (Nat.ble (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s919.ffi).mlx.nnext) = true
kernel_rfl PRE_first_tail_x15_r0_body.flnF104 : PRE_first_tail_x15_r0_body.cln104.all (Nat.ble (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s919.ffi).mlx.nnext) = true
-- the checks over the changed lists
kernel_rfl PRE_first_tail_x15_r0_body.fh104 : PRE_first_tail_x15_r0_body.clo104.all (handleOK PRE_first_tail_x15_r0_body.kappa104 PRE_first_tail_x15_r0_body.P104.lo PRE_first_tail_x15_r0_body.cx0_104.mlx PRE_first_tail_x15_r0_body.cx1_104.mlx) = true
kernel_rfl PRE_first_tail_x15_r0_body.fo104 : PRE_first_tail_x15_r0_body.clo104.map (fun h => PRE_first_tail_x15_r0_body.cx1_104.mlx.objs.get (PRE_first_tail_x15_r0_body.kappa104.handle h)) = PRE_first_tail_x15_r0_body.clo104.map (fun h => (PRE_first_tail_x15_r0_body.cx0_104.mlx.objs.get h).map PRE_first_tail_x15_r0_body.kappa104.nobj)
kernel_rfl PRE_first_tail_x15_r0_body.fok104 : PRE_first_tail_x15_r0_body.clo104.all (objOK PRE_first_tail_x15_r0_body.kappa104 PRE_first_tail_x15_r0_body.P104.NL PRE_first_tail_x15_r0_body.cx0_104.mlx) = true
kernel_rfl PRE_first_tail_x15_r0_body.fnd104 : PRE_first_tail_x15_r0_body.cln104.all (nodeOKF PRE_first_tail_x15_r0_body.kappa104 PRE_first_tail_x15_r0_body.P104 PRE_first_tail_x15_r0_body.cx0_104.mlx PRE_first_tail_x15_r0_body.cx1_104.mlx) = true
kernel_rfl PRE_first_tail_x15_r0_body.fp104 : ((PRE_first_tail_x15_r0_body.cln104.filter (fullB PRE_first_tail_x15_r0_body.P104))).map (fun i => (PRE_first_tail_x15_r0_body.cx1_104.mlx.nodes.get (PRE_first_tail_x15_r0_body.kappa104.node i)).map Host.Mlx.Ffi.Node.prim) =
  ((PRE_first_tail_x15_r0_body.cln104.filter (fullB PRE_first_tail_x15_r0_body.P104))).map (fun i => (PRE_first_tail_x15_r0_body.cx0_104.mlx.nodes.get i).map fun nd => PRE_first_tail_x15_r0_body.kappa104.prim nd.prim)
kernel_rfl PRE_first_tail_x15_r0_body.fnordI104 : incrB PRE_first_tail_x15_r0_body.kd104.nodeF (List.range' 17344 0) = true
kernel_rfl PRE_first_tail_x15_r0_body.fnordK104 : (PTrie.keysA PRE_first_tail_x15_r0_body.kd104.node).all (fun k => Nat.ble 17344 k && Nat.blt k 17344) = true
kernel_rfl PRE_first_tail_x15_r0_body.fnordL104 : (PRE_first_tail_x15_r0_body.cln104.filter (Nat.ble PRE_first_tail_x15_r0_body.P104.N0)).all (fun i => Nat.ble i (PRE_first_tail_x15_r0_body.kd104.nodeF i) && (Nat.blt i 17344 || Nat.ble PRE_first_tail_x15_r0_body.kd104.nn0 i)) = true
theorem PRE_first_tail_x15_r0_body.fnord104 : (PRE_first_tail_x15_r0_body.cln104.filter (Nat.ble PRE_first_tail_x15_r0_body.P104.N0)).all (fun i => Nat.ble i (PRE_first_tail_x15_r0_body.kd104.nodeF i) &&
    (PTrie.keysA PRE_first_tail_x15_r0_body.kd104.node).all fun j => !Nat.blt j i || Nat.blt (PRE_first_tail_x15_r0_body.kd104.nodeF j) (PRE_first_tail_x15_r0_body.kd104.nodeF i)) = true :=
  cnord_of PRE_first_tail_x15_r0_body.cnlow104 PRE_first_tail_x15_r0_body.cnn1104 PRE_first_tail_x15_r0_body.fnordI104 PRE_first_tail_x15_r0_body.fnordK104 PRE_first_tail_x15_r0_body.fnordL104
kernel_rfl PRE_first_tail_x15_r0_body.fi104 : PRE_first_tail_x15_r0_body.cli104.all (pnB PRE_first_tail_x15_r0_body.cx0_104.mlx) = true
kernel_rfl PRE_first_tail_x15_r0_body.fii104 : PRE_first_tail_x15_r0_body.cli104.all (fun k => decide (PRE_first_tail_x15_r0_body.cx1_104.mlx.items.get (PRE_first_tail_x15_r0_body.kappa104.node k) = (PRE_first_tail_x15_r0_body.cx0_104.mlx.items.get k).map PRE_first_tail_x15_r0_body.kappa104.nv)) = true
/-- **The compaction's footprint.** -/
theorem PRE_first_tail_x15_r0_body.cfoot104 (clean : Conv.NClean (⟨20241, 17344, 2756095, 4501⟩ : Conv.Cnt) (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s919.ffi).mlx) (hltC : ∀ h, PH (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s919.ffi).mlx h → h < (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s919.ffi).mlx.next) (nltC : ∀ i, PN (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s919.ffi).mlx i → i < (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s919.ffi).mlx.nnext) (itemsC : ∀ k v, (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s919.ffi).mlx.items.get k = some v → PN (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s919.ffi).mlx k) (tracedC : ∀ h o, (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s919.ffi).mlx.objs.get h = some o → ∀ i ∈ objTraces o, i < PRE_first_tail_x15_r0_body.P104.NL) (cl : SSt (· < 4501) PRE_first_tail_x15_r0_body.cx0_104.mlx) :
    Conv.MFoot PRE_first_tail_x15_r0_body.P104 4501 PRE_first_tail_x15_r0_body.kappa104 PRE_first_tail_x15_r0_body.kd104 PRE_first_tail_x15_r0_body.khinv104 PRE_first_tail_x15_r0_body.kninv104 (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s919.ffi).mlx PRE_first_tail_x15_r0_body.cx0_104.mlx PRE_first_tail_x15_r0_body.cx1_104.mlx (⟨20241, 17344, 2756095, 4501⟩ : Conv.Cnt) PRE_first_tail_x15_r0_body.clo104 PRE_first_tail_x15_r0_body.cln104 PRE_first_tail_x15_r0_body.cli104 PRE_first_tail_x15_r0_body.cwS104 PRE_first_tail_x15_r0_body.cnS104 PRE_first_tail_x15_r0_body.ciS104 :=
  ⟨rfl, rfl, rfl, PRE_first_tail_x15_r0_body.cnh0104, PRE_first_tail_x15_r0_body.cnh1104, PRE_first_tail_x15_r0_body.cnn0104, PRE_first_tail_x15_r0_body.cnn1104, PRE_first_tail_x15_r0_body.cplo104, PRE_first_tail_x15_r0_body.ccnt104, PRE_first_tail_x15_r0_body.cnband104, PRE_first_tail_x15_r0_body.chbelow104, PRE_first_tail_x15_r0_body.chren104, PRE_first_tail_x15_r0_body.cband104, PRE_first_tail_x15_r0_body.cnh1pos104, PRE_first_tail_x15_r0_body.cnren104, PRE_first_tail_x15_r0_body.cnlow104, PRE_first_tail_x15_r0_body.cabs0a104, PRE_first_tail_x15_r0_body.cabs0b104, PRE_first_tail_x15_r0_body.ctok1104, PRE_first_tail_x15_r0_body.cpend104, PRE_first_tail_x15_r0_body.cerrh104, PRE_first_tail_x15_r0_body.cfiles104, PRE_first_tail_x15_r0_body.carch104, PRE_first_tail_x15_r0_body.csizes104, PRE_first_tail_x15_r0_body.cwired104, PRE_first_tail_x15_r0_body.cfix104, clean, PRE_first_tail_x15_r0_body.fcxn104, PRE_first_tail_x15_r0_body.fcnn104, hltC, nltC, itemsC, tracedC, cl, PRE_first_tail_x15_r0_body.fle0104, PRE_first_tail_x15_r0_body.fnk104, PRE_first_tail_x15_r0_body.ckA104, PRE_first_tail_x15_r0_body.cobjsK104, PRE_first_tail_x15_r0_body.cnodesK104, PRE_first_tail_x15_r0_body.citemsK104, PRE_first_tail_x15_r0_body.f1A104, PRE_first_tail_x15_r0_body.f1O104, PRE_first_tail_x15_r0_body.f1N104, PRE_first_tail_x15_r0_body.f1I104, PRE_first_tail_x15_r0_body.fbd104, PRE_first_tail_x15_r0_body.fincW104, PRE_first_tail_x15_r0_body.fincI104, PRE_first_tail_x15_r0_body.fincN104, PRE_first_tail_x15_r0_body.flnF104, PRE_first_tail_x15_r0_body.fh104, PRE_first_tail_x15_r0_body.fo104, PRE_first_tail_x15_r0_body.fok104, PRE_first_tail_x15_r0_body.fnd104, PRE_first_tail_x15_r0_body.fp104, PRE_first_tail_x15_r0_body.fnord104, PRE_first_tail_x15_r0_body.fi104, PRE_first_tail_x15_r0_body.fii104⟩
theorem PRE_first_tail_x15_r0_body.cnshift104 (clean : Conv.NClean (⟨20241, 17344, 2756095, 4501⟩ : Conv.Cnt) (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s919.ffi).mlx) (hltC : ∀ h, PH (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s919.ffi).mlx h → h < (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s919.ffi).mlx.next) (nltC : ∀ i, PN (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s919.ffi).mlx i → i < (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s919.ffi).mlx.nnext) (itemsC : ∀ k v, (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s919.ffi).mlx.items.get k = some v → PN (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s919.ffi).mlx k) (tracedC : ∀ h o, (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s919.ffi).mlx.objs.get h = some o → ∀ i ∈ objTraces o, i < PRE_first_tail_x15_r0_body.P104.NL) (cl : SSt (· < 4501) PRE_first_tail_x15_r0_body.cx0_104.mlx) : NShift PRE_first_tail_x15_r0_body.P104 4501 PRE_first_tail_x15_r0_body.kappa104 PRE_first_tail_x15_r0_body.cx0_104 PRE_first_tail_x15_r0_body.cx1_104 :=
  Conv.nshift_of_foot (PRE_first_tail_x15_r0_body.cfoot104 clean hltC nltC itemsC tracedC cl) PRE_first_tail_x15_r0_body.chost104 (compact_a_eq PRE_first_tail_x15_r0_body.ckn0104 PRE_first_tail_x15_r0_body.ckn1104 PRE_first_tail_x15_r0_body.ckheap104 PRE_first_tail_x15_r0_body.ckpl104)

-- the observers: the layers' states at the call, the canonical and the merged state, their footprints and checks
noncomputable def PRE_first_tail_x15_r0_body.fxC_104 : PTrie Unit := (Host.Ts.Sim.Full.freedOf PRE_first_tail_x15_r0_body.s919.ffi).getD PTrie.nil
noncomputable def PRE_first_tail_x15_r0_body.krC_104 : Host.Load.Layers.KRec := (Host.Ts.Sim.Full.krecOf PRE_first_tail_x15_r0_body.s919.ffi).getD Host.Load.Layers.KRec.empty
kernel_rfl PRE_first_tail_x15_r0_body.ofxC_104 : (Host.Ts.Sim.Full.freedOf PRE_first_tail_x15_r0_body.s919.ffi) = some PRE_first_tail_x15_r0_body.fxC_104
kernel_rfl PRE_first_tail_x15_r0_body.okrC_104 : (Host.Ts.Sim.Full.krecOf PRE_first_tail_x15_r0_body.s919.ffi) = some PRE_first_tail_x15_r0_body.krC_104
noncomputable def PRE_first_tail_x15_r0_body.fx0_104 : PTrie Unit := (Host.Ts.Sim.Full.freedOf PRE_first_tail_x15_r0_body.s921.ffi).getD PTrie.nil
noncomputable def PRE_first_tail_x15_r0_body.kr0_104 : Host.Load.Layers.KRec := (Host.Ts.Sim.Full.krecOf PRE_first_tail_x15_r0_body.s921.ffi).getD Host.Load.Layers.KRec.empty
kernel_rfl PRE_first_tail_x15_r0_body.ofx0_104 : (Host.Ts.Sim.Full.freedOf PRE_first_tail_x15_r0_body.s921.ffi) = some PRE_first_tail_x15_r0_body.fx0_104
kernel_rfl PRE_first_tail_x15_r0_body.okr0_104 : (Host.Ts.Sim.Full.krecOf PRE_first_tail_x15_r0_body.s921.ffi) = some PRE_first_tail_x15_r0_body.kr0_104
noncomputable def PRE_first_tail_x15_r0_body.fx1_104 : PTrie Unit := (Host.Ts.Sim.Full.freedOf PRE_first_tail_x15_r0_body.s920.ffi).getD PTrie.nil
noncomputable def PRE_first_tail_x15_r0_body.kr1_104 : Host.Load.Layers.KRec := (Host.Ts.Sim.Full.krecOf PRE_first_tail_x15_r0_body.s920.ffi).getD Host.Load.Layers.KRec.empty
kernel_rfl PRE_first_tail_x15_r0_body.ofx1_104 : (Host.Ts.Sim.Full.freedOf PRE_first_tail_x15_r0_body.s920.ffi) = some PRE_first_tail_x15_r0_body.fx1_104
kernel_rfl PRE_first_tail_x15_r0_body.okr1_104 : (Host.Ts.Sim.Full.krecOf PRE_first_tail_x15_r0_body.s920.ffi) = some PRE_first_tail_x15_r0_body.kr1_104
kernel_rfl PRE_first_tail_x15_r0_body.ff0104 : PRE_first_tail_x15_r0_body.fx0_104 = Stage.setAll PRE_first_tail_x15_r0_body.fxC_104 (PRE_first_tail_x15_r0_body.clo104.filterMap fun i => (PRE_first_tail_x15_r0_body.fx0_104.get i).map (i, ·))
kernel_rfl PRE_first_tail_x15_r0_body.ff1104 : PRE_first_tail_x15_r0_body.fx1_104 = Stage.setAll PRE_first_tail_x15_r0_body.fxC_104 (PRE_first_tail_x15_r0_body.cwS104.filterMap fun i => (PRE_first_tail_x15_r0_body.fx1_104.get i).map (i, ·))
kernel_rfl PRE_first_tail_x15_r0_body.ffck104 : freedLB PRE_first_tail_x15_r0_body.kappa104 PRE_first_tail_x15_r0_body.cx0_104.mlx PRE_first_tail_x15_r0_body.fx0_104 PRE_first_tail_x15_r0_body.fx1_104 PRE_first_tail_x15_r0_body.clo104 = true
kernel_rfl PRE_first_tail_x15_r0_body.fkf0104 : PRE_first_tail_x15_r0_body.kr0_104.flags = Stage.setAll PRE_first_tail_x15_r0_body.krC_104.flags (PRE_first_tail_x15_r0_body.clo104.filterMap fun i => (PRE_first_tail_x15_r0_body.kr0_104.flags.get i).map (i, ·))
kernel_rfl PRE_first_tail_x15_r0_body.fkt0104 : PRE_first_tail_x15_r0_body.kr0_104.targs = Stage.setAll PRE_first_tail_x15_r0_body.krC_104.targs (PRE_first_tail_x15_r0_body.clo104.filterMap fun i => (PRE_first_tail_x15_r0_body.kr0_104.targs.get i).map (i, ·))
kernel_rfl PRE_first_tail_x15_r0_body.fkf1104 : PRE_first_tail_x15_r0_body.kr1_104.flags = Stage.setAll PRE_first_tail_x15_r0_body.krC_104.flags (PRE_first_tail_x15_r0_body.cwS104.filterMap fun i => (PRE_first_tail_x15_r0_body.kr1_104.flags.get i).map (i, ·))
kernel_rfl PRE_first_tail_x15_r0_body.fkt1104 : PRE_first_tail_x15_r0_body.kr1_104.targs = Stage.setAll PRE_first_tail_x15_r0_body.krC_104.targs (PRE_first_tail_x15_r0_body.cwS104.filterMap fun i => (PRE_first_tail_x15_r0_body.kr1_104.targs.get i).map (i, ·))
kernel_rfl PRE_first_tail_x15_r0_body.fkck104 : krecLB PRE_first_tail_x15_r0_body.kappa104 4501 PRE_first_tail_x15_r0_body.cx0_104.mlx PRE_first_tail_x15_r0_body.kr0_104 PRE_first_tail_x15_r0_body.kr1_104 PRE_first_tail_x15_r0_body.clo104 = true
kernel_rfl PRE_first_tail_x15_r0_body.fkn104 : Nat.ble 4501 4501 = true
-- the bridge and the pending traces' regions
kernel_rfl PRE_first_tail_x15_r0_body.cbridge104 : Host.Ts.Sim.Full.bridgeOf PRE_first_tail_x15_r0_body.s920.ffi = Host.Ts.Sim.Full.bridgeOf PRE_first_tail_x15_r0_body.s921.ffi
kernel_rfl PRE_first_tail_x15_r0_body.cpendR104 : pendRegB PRE_first_tail_x15_r0_body.kappa104 (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s921.ffi).mlx = true
kernel_rfl PRE_first_tail_x15_r0_body.cpendLe104 : Nat.ble (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s921.ffi).mlx.next (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s920.ffi).mlx.next = true
/-- **The compaction's native shift**, given the call's bookkeeping, its relation's facts (the model's and the
observers') and the canonical closedness. -/
theorem PRE_first_tail_x15_r0_body.cshift104 (clean : Conv.NClean (⟨20241, 17344, 2756095, 4501⟩ : Conv.Cnt) (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s919.ffi).mlx) (hltC : ∀ h, PH (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s919.ffi).mlx h → h < (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s919.ffi).mlx.next) (nltC : ∀ i, PN (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s919.ffi).mlx i → i < (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s919.ffi).mlx.nnext) (itemsC : ∀ k v, (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s919.ffi).mlx.items.get k = some v → PN (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s919.ffi).mlx k) (tracedC : ∀ h o, (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s919.ffi).mlx.objs.get h = some o → ∀ i ∈ objTraces o, i < PRE_first_tail_x15_r0_body.P104.NL) (cl : SSt (· < 4501) PRE_first_tail_x15_r0_body.cx0_104.mlx)
    (hobjC : ∀ h, PRE_first_tail_x15_r0_body.fxC_104.get h = some () → ((Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s919.ffi).mlx.objs.get h).isSome = true)
    (hfC : ∀ h, (PRE_first_tail_x15_r0_body.krC_104.flags.get h).isSome = true → ((Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s919.ffi).mlx.objs.get h).isSome = true)
    (htC : ∀ h, (PRE_first_tail_x15_r0_body.krC_104.targs.get h).isSome = true → ((Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s919.ffi).mlx.objs.get h).isSome = true)
    (hclC : ∀ h l, PRE_first_tail_x15_r0_body.krC_104.targs.get h = some l → Host.Ts.Sim.Full.STargs (· < (⟨20241, 17344, 2756095, 4501⟩ : Conv.Cnt).n) l) :
    Conv.FullShiftQ PRE_first_tail_x15_r0_body.P104 4501 PRE_first_tail_x15_r0_body.kappa104 PRE_first_tail_x15_r0_body.s921.ffi PRE_first_tail_x15_r0_body.s920.ffi :=
  ⟨PRE_first_tail_x15_r0_body.cnshift104 clean hltC nltC itemsC tracedC cl, PRE_first_tail_x15_r0_body.cqueue104, fun t ht => bSN_sound (List.all_eq_true.mp PRE_first_tail_x15_r0_body.ctokSupp104 t ht),
    PRE_first_tail_x15_r0_body.cbridge104,
    liveShift_foot (x0' := Host.Ts.Sim.Full.mlxOf PRE_first_tail_x15_r0_body.s921.ffi) (x1' := Host.Ts.Sim.Full.mlxOf PRE_first_tail_x15_r0_body.s920.ffi) (PRE_first_tail_x15_r0_body.cfoot104 clean hltC nltC itemsC tracedC cl) rfl PRE_first_tail_x15_r0_body.ofx0_104 PRE_first_tail_x15_r0_body.ofx1_104 hobjC PRE_first_tail_x15_r0_body.ff0104 PRE_first_tail_x15_r0_body.ff1104 PRE_first_tail_x15_r0_body.ffck104,
    kernShift_foot (x0' := Host.Ts.Sim.Full.mlxOf PRE_first_tail_x15_r0_body.s921.ffi) (x1' := Host.Ts.Sim.Full.mlxOf PRE_first_tail_x15_r0_body.s920.ffi) (PRE_first_tail_x15_r0_body.cfoot104 clean hltC nltC itemsC tracedC cl) rfl PRE_first_tail_x15_r0_body.okr0_104 PRE_first_tail_x15_r0_body.okr1_104 (Nat.le_of_ble_eq_true PRE_first_tail_x15_r0_body.fkn104) hfC htC hclC
      PRE_first_tail_x15_r0_body.fkf0104 PRE_first_tail_x15_r0_body.fkt0104 PRE_first_tail_x15_r0_body.fkf1104 PRE_first_tail_x15_r0_body.fkt1104 PRE_first_tail_x15_r0_body.fkck104,
    pendReg_of rfl PRE_first_tail_x15_r0_body.cnh0104 PRE_first_tail_x15_r0_body.cnh1104 (Nat.le_of_ble_eq_true PRE_first_tail_x15_r0_body.cpendLe104) PRE_first_tail_x15_r0_body.cpendR104⟩

end Host.Load.Run.Tpl
