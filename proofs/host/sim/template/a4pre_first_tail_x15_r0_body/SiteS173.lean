import host.sim.template.a4pre_first_tail_x15_r0_body.SiteCl173
import host.sim.conv.CompactFull
import host.sim.template.FootGen
set_option Elab.async false
namespace Host.Load.Run.Tpl
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
open Host.Ts Host.Ts.Sim Host.Ts.Sim.Template

/-! The compaction's native shift at call site 173 from its footprint (`Conv.nshift_of_foot`), and the observers'
(`liveShift_foot`, `kernShift_foot`): `Conv.FullShiftQ` for `Conv.full_compactQ`, given the call's bookkeeping and its
relation's facts. -/

/-- The load parameters of the chain (band-free: its start's node counter as `NL` and `N0`). -/
def PRE_first_tail_x15_r0_body.Pc173 : LoadP := ⟨18151, 131072, 1099511627776, 15235, 15235, []⟩
/-- The site's band raised to the map's checked fixed-node prefix, including newly recorded closure traces. -/
def PRE_first_tail_x15_r0_body.P173 : LoadP := PRE_first_tail_x15_r0_body.Pc173.raise 18703
kernel_rfl PRE_first_tail_x15_r0_body.craise173 : Nat.ble PRE_first_tail_x15_r0_body.Pc173.N0 18703 = true
theorem PRE_first_tail_x15_r0_body.raised173 : Host.Ts.Sim.Full.Raised PRE_first_tail_x15_r0_body.Pc173 PRE_first_tail_x15_r0_body.P173 :=
  .inr ⟨18703, rfl, Nat.le_of_ble_eq_true PRE_first_tail_x15_r0_body.craise173, rfl⟩
noncomputable abbrev PRE_first_tail_x15_r0_body.cx0_173 : Host.Load.LSt := clearTokens (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1524.ffi)
noncomputable abbrev PRE_first_tail_x15_r0_body.cx1_173 : Host.Load.LSt := clearTokens (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1523.ffi)
def PRE_first_tail_x15_r0_body.khinv173 : PTrie Nat := Stage.setAll PTrie.nil []
def PRE_first_tail_x15_r0_body.kninv173 : PTrie Nat := Stage.setAll PTrie.nil []
/-- The stage's footprint: its written and fresh handles, fresh nodes, written and fresh items. -/
def PRE_first_tail_x15_r0_body.cwS173 : List Nat := []
def PRE_first_tail_x15_r0_body.cnS173 : List Nat := List.range' 18703 0
def PRE_first_tail_x15_r0_body.ciS173 : List Nat := [] ++ List.range' 18703 0

-- the small checks (`MChecks`'s)
kernel_rfl PRE_first_tail_x15_r0_body.cnh0173 : PRE_first_tail_x15_r0_body.kd173.nh0 = PRE_first_tail_x15_r0_body.cx0_173.mlx.next
kernel_rfl PRE_first_tail_x15_r0_body.cnh1173 : PRE_first_tail_x15_r0_body.kd173.nh1 = PRE_first_tail_x15_r0_body.cx1_173.mlx.next
kernel_rfl PRE_first_tail_x15_r0_body.cnn0173 : PRE_first_tail_x15_r0_body.kd173.nn0 = PRE_first_tail_x15_r0_body.cx0_173.mlx.nnext
kernel_rfl PRE_first_tail_x15_r0_body.cnn1173 : PRE_first_tail_x15_r0_body.kd173.nn1 = PRE_first_tail_x15_r0_body.cx1_173.mlx.nnext
kernel_rfl PRE_first_tail_x15_r0_body.cplo173 : (Nat.blt 0 PRE_first_tail_x15_r0_body.P173.lo && Nat.ble PRE_first_tail_x15_r0_body.P173.lo PRE_first_tail_x15_r0_body.cx0_173.mlx.next && Nat.ble PRE_first_tail_x15_r0_body.P173.lo RData.bigHi && Nat.ble RData.bigHi PRE_first_tail_x15_r0_body.P173.E) = true
kernel_rfl PRE_first_tail_x15_r0_body.ccnt173 : (Nat.ble PRE_first_tail_x15_r0_body.cx0_173.mlx.next PRE_first_tail_x15_r0_body.cx1_173.mlx.next && Nat.ble PRE_first_tail_x15_r0_body.cx0_173.mlx.nnext PRE_first_tail_x15_r0_body.cx1_173.mlx.nnext) = true
kernel_rfl PRE_first_tail_x15_r0_body.cnband173 : (Nat.blt 0 PRE_first_tail_x15_r0_body.P173.NL && Nat.ble PRE_first_tail_x15_r0_body.P173.NL PRE_first_tail_x15_r0_body.P173.N0 && Nat.ble PRE_first_tail_x15_r0_body.P173.N0 PRE_first_tail_x15_r0_body.cx0_173.mlx.nnext) = true
kernel_rfl PRE_first_tail_x15_r0_body.chbelow173 : PRE_first_tail_x15_r0_body.kd173.checkHndBelow = true
kernel_rfl PRE_first_tail_x15_r0_body.chren173 : checkRenG PRE_first_tail_x15_r0_body.kd173.hnd PRE_first_tail_x15_r0_body.khinv173 (phB PRE_first_tail_x15_r0_body.cx0_173.mlx) = true
kernel_rfl PRE_first_tail_x15_r0_body.cband173 : PRE_first_tail_x15_r0_body.kd173.checkBand PRE_first_tail_x15_r0_body.P173.lo = true
kernel_rfl PRE_first_tail_x15_r0_body.cnh1pos173 : Nat.blt 0 PRE_first_tail_x15_r0_body.kd173.nh1 = true
kernel_rfl PRE_first_tail_x15_r0_body.cnren173 : checkRenG PRE_first_tail_x15_r0_body.kd173.node PRE_first_tail_x15_r0_body.kninv173 (pnB PRE_first_tail_x15_r0_body.cx0_173.mlx) = true
kernel_rfl PRE_first_tail_x15_r0_body.cnlow173 : (PTrie.keysA PRE_first_tail_x15_r0_body.kd173.node).all (fun j => Nat.ble PRE_first_tail_x15_r0_body.P173.NL j && Nat.blt (PRE_first_tail_x15_r0_body.kd173.nodeF j) PRE_first_tail_x15_r0_body.cx1_173.mlx.nnext) = true
kernel_rfl PRE_first_tail_x15_r0_body.cabs0a173 : PRE_first_tail_x15_r0_body.cx0_173.mlx.arrs.get 0 = none
kernel_rfl PRE_first_tail_x15_r0_body.cabs0b173 : PRE_first_tail_x15_r0_body.cx0_173.mlx.objs.get 0 = none
kernel_rfl PRE_first_tail_x15_r0_body.ctok1173 : PRE_first_tail_x15_r0_body.cx1_173.mlx.tokens = []
kernel_rfl PRE_first_tail_x15_r0_body.cpend173 : PRE_first_tail_x15_r0_body.cx1_173.mlx.pending = PRE_first_tail_x15_r0_body.cx0_173.mlx.pending.map PRE_first_tail_x15_r0_body.kappa173.pend
kernel_rfl PRE_first_tail_x15_r0_body.cerrh173 : PRE_first_tail_x15_r0_body.cx1_173.mlx.errh = PRE_first_tail_x15_r0_body.cx0_173.mlx.errh.map PRE_first_tail_x15_r0_body.kappa173.arg
kernel_rfl PRE_first_tail_x15_r0_body.cfiles173 : PRE_first_tail_x15_r0_body.cx1_173.mlx.files = PRE_first_tail_x15_r0_body.cx0_173.mlx.files
kernel_rfl PRE_first_tail_x15_r0_body.carch173 : PRE_first_tail_x15_r0_body.cx1_173.mlx.arch = PRE_first_tail_x15_r0_body.cx0_173.mlx.arch
kernel_rfl PRE_first_tail_x15_r0_body.csizes173 : PRE_first_tail_x15_r0_body.cx1_173.mlx.deviceSizes = PRE_first_tail_x15_r0_body.cx0_173.mlx.deviceSizes
kernel_rfl PRE_first_tail_x15_r0_body.cwired173 : PRE_first_tail_x15_r0_body.cx1_173.mlx.wired = PRE_first_tail_x15_r0_body.cx0_173.mlx.wired
kernel_rfl PRE_first_tail_x15_r0_body.chost173 : PRE_first_tail_x15_r0_body.cx1_173.host = PRE_first_tail_x15_r0_body.cx0_173.host
-- the compaction map's addresses are `PRE_first_tail_x15_r0_body.kd173`'s
kernel_rfl PRE_first_tail_x15_r0_body.ckn0173 : PRE_first_tail_x15_r0_body.kd173.n0 = 2810344
kernel_rfl PRE_first_tail_x15_r0_body.ckn1173 : PRE_first_tail_x15_r0_body.kd173.n1 = 2810363
kernel_rfl PRE_first_tail_x15_r0_body.ckheap173 : (PTrie.keysA PRE_first_tail_x15_r0_body.kd173.heap).all (fun x => Nat.ble 2810343 x) = true
kernel_rfl PRE_first_tail_x15_r0_body.ckpl173 : (List.range 1).all (fun j => decide (PRE_first_tail_x15_r0_body.kd173.heap.get (2810343 + j) = nth? PRE_first_tail_x15_r0_body.pl173 j)) = true
-- the map fixes the call's names (`Conv.fixOld_compact`), the call's counters
kernel_rfl PRE_first_tail_x15_r0_body.fja173 : Nat.ble 2810343 2810343 = true
kernel_rfl PRE_first_tail_x15_r0_body.fn173 : Nat.ble 7450 7450 = true
kernel_rfl PRE_first_tail_x15_r0_body.fjaD173 : Nat.ble 2810343 PRE_first_tail_x15_r0_body.kd173.n0 = true
kernel_rfl PRE_first_tail_x15_r0_body.fxn173 : Nat.ble 21600 PRE_first_tail_x15_r0_body.kd173.nh0 = true
kernel_rfl PRE_first_tail_x15_r0_body.fnn173 : Nat.ble 18703 PRE_first_tail_x15_r0_body.kd173.nn0 = true
kernel_rfl PRE_first_tail_x15_r0_body.fxb173 : Nat.ble 21600 RData.bigHi = true
kernel_rfl PRE_first_tail_x15_r0_body.fheap173 : (PTrie.keysA PRE_first_tail_x15_r0_body.kd173.heap).all (Nat.ble (⟨21600, 18703, 2810343, 7450⟩ : Conv.Cnt).ja) = true
kernel_rfl PRE_first_tail_x15_r0_body.fhnd173 : (PTrie.keysA PRE_first_tail_x15_r0_body.kd173.hnd).all (Nat.ble (⟨21600, 18703, 2810343, 7450⟩ : Conv.Cnt).xn) = true
kernel_rfl PRE_first_tail_x15_r0_body.fnode173 : (PTrie.keysA PRE_first_tail_x15_r0_body.kd173.node).all (Nat.ble (⟨21600, 18703, 2810343, 7450⟩ : Conv.Cnt).nn) = true
/-- The compaction map fixes the call's names. -/
theorem PRE_first_tail_x15_r0_body.cfix173 : Conv.FixOld (⟨21600, 18703, 2810343, 7450⟩ : Conv.Cnt) PRE_first_tail_x15_r0_body.kappa173 :=
  Conv.fixOld_compact (Nat.le_of_ble_eq_true PRE_first_tail_x15_r0_body.fja173) (Nat.le_of_ble_eq_true PRE_first_tail_x15_r0_body.fn173) (Nat.le_of_ble_eq_true PRE_first_tail_x15_r0_body.fjaD173) (Nat.le_of_ble_eq_true PRE_first_tail_x15_r0_body.fxn173) (Nat.le_of_ble_eq_true PRE_first_tail_x15_r0_body.fnn173) (Nat.le_of_ble_eq_true PRE_first_tail_x15_r0_body.fxb173) PRE_first_tail_x15_r0_body.fheap173 PRE_first_tail_x15_r0_body.fhnd173 PRE_first_tail_x15_r0_body.fnode173
kernel_rfl PRE_first_tail_x15_r0_body.fcxn173 : (⟨21600, 18703, 2810343, 7450⟩ : Conv.Cnt).xn = (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1522.ffi).mlx.next
kernel_rfl PRE_first_tail_x15_r0_body.fcnn173 : (⟨21600, 18703, 2810343, 7450⟩ : Conv.Cnt).nn = (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1522.ffi).mlx.nnext
kernel_rfl PRE_first_tail_x15_r0_body.fle0173 : (Nat.ble (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1522.ffi).mlx.next PRE_first_tail_x15_r0_body.cx0_173.mlx.next && Nat.ble (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1522.ffi).mlx.nnext PRE_first_tail_x15_r0_body.cx0_173.mlx.nnext && Nat.ble (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1522.ffi).mlx.next RData.bigHi) = true
kernel_rfl PRE_first_tail_x15_r0_body.fnk173 : (PTrie.keysA PRE_first_tail_x15_r0_body.kd173.node).all (Nat.ble (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1522.ffi).mlx.nnext) = true
-- the merged state keeps the call's entries off the stage's footprint
kernel_rfl PRE_first_tail_x15_r0_body.f1A173 : PRE_first_tail_x15_r0_body.cx1_173.mlx.arrs = Stage.setAll (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1522.ffi).mlx.arrs (PRE_first_tail_x15_r0_body.cwS173.filterMap fun i => (PRE_first_tail_x15_r0_body.cx1_173.mlx.arrs.get i).map (i, ·))
kernel_rfl PRE_first_tail_x15_r0_body.f1O173 : PRE_first_tail_x15_r0_body.cx1_173.mlx.objs = Stage.setAll (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1522.ffi).mlx.objs (PRE_first_tail_x15_r0_body.cwS173.filterMap fun i => (PRE_first_tail_x15_r0_body.cx1_173.mlx.objs.get i).map (i, ·))
kernel_rfl PRE_first_tail_x15_r0_body.f1N173 : PRE_first_tail_x15_r0_body.cx1_173.mlx.nodes = Stage.setAll (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1522.ffi).mlx.nodes (PRE_first_tail_x15_r0_body.cnS173.filterMap fun i => (PRE_first_tail_x15_r0_body.cx1_173.mlx.nodes.get i).map (i, ·))
kernel_rfl PRE_first_tail_x15_r0_body.f1I173 : PRE_first_tail_x15_r0_body.cx1_173.mlx.items = Stage.setAll (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1522.ffi).mlx.items (PRE_first_tail_x15_r0_body.ciS173.filterMap fun i => (PRE_first_tail_x15_r0_body.cx1_173.mlx.items.get i).map (i, ·))
kernel_rfl PRE_first_tail_x15_r0_body.fbd173 : (PRE_first_tail_x15_r0_body.clo173 ++ PRE_first_tail_x15_r0_body.cln173 ++ PRE_first_tail_x15_r0_body.cli173 ++ PRE_first_tail_x15_r0_body.cwS173 ++ PRE_first_tail_x15_r0_body.cnS173 ++ PRE_first_tail_x15_r0_body.ciS173).all (fun i => Nat.blt (i / 4096) (4 ^ 31)) = true
kernel_rfl PRE_first_tail_x15_r0_body.fincW173 : PRE_first_tail_x15_r0_body.cwS173.all (fun h => !Nat.blt h (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1522.ffi).mlx.next || PRE_first_tail_x15_r0_body.clo173.contains h) = true
kernel_rfl PRE_first_tail_x15_r0_body.fincI173 : PRE_first_tail_x15_r0_body.ciS173.all (fun k => !Nat.blt k (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1522.ffi).mlx.nnext || PRE_first_tail_x15_r0_body.cli173.contains k) = true
kernel_rfl PRE_first_tail_x15_r0_body.fincN173 : PRE_first_tail_x15_r0_body.cnS173.all (Nat.ble (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1522.ffi).mlx.nnext) = true
kernel_rfl PRE_first_tail_x15_r0_body.flnF173 : PRE_first_tail_x15_r0_body.cln173.all (Nat.ble (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1522.ffi).mlx.nnext) = true
-- the checks over the changed lists
kernel_rfl PRE_first_tail_x15_r0_body.fh173 : PRE_first_tail_x15_r0_body.clo173.all (handleOK PRE_first_tail_x15_r0_body.kappa173 PRE_first_tail_x15_r0_body.P173.lo PRE_first_tail_x15_r0_body.cx0_173.mlx PRE_first_tail_x15_r0_body.cx1_173.mlx) = true
kernel_rfl PRE_first_tail_x15_r0_body.fo173 : PRE_first_tail_x15_r0_body.clo173.map (fun h => PRE_first_tail_x15_r0_body.cx1_173.mlx.objs.get (PRE_first_tail_x15_r0_body.kappa173.handle h)) = PRE_first_tail_x15_r0_body.clo173.map (fun h => (PRE_first_tail_x15_r0_body.cx0_173.mlx.objs.get h).map PRE_first_tail_x15_r0_body.kappa173.nobj)
kernel_rfl PRE_first_tail_x15_r0_body.fok173 : PRE_first_tail_x15_r0_body.clo173.all (objOK PRE_first_tail_x15_r0_body.kappa173 PRE_first_tail_x15_r0_body.P173.NL PRE_first_tail_x15_r0_body.cx0_173.mlx) = true
kernel_rfl PRE_first_tail_x15_r0_body.fnd173 : PRE_first_tail_x15_r0_body.cln173.all (nodeOKF PRE_first_tail_x15_r0_body.kappa173 PRE_first_tail_x15_r0_body.P173 PRE_first_tail_x15_r0_body.cx0_173.mlx PRE_first_tail_x15_r0_body.cx1_173.mlx) = true
kernel_rfl PRE_first_tail_x15_r0_body.fp173 : ((PRE_first_tail_x15_r0_body.cln173.filter (fullB PRE_first_tail_x15_r0_body.P173))).map (fun i => (PRE_first_tail_x15_r0_body.cx1_173.mlx.nodes.get (PRE_first_tail_x15_r0_body.kappa173.node i)).map Host.Mlx.Ffi.Node.prim) =
  ((PRE_first_tail_x15_r0_body.cln173.filter (fullB PRE_first_tail_x15_r0_body.P173))).map (fun i => (PRE_first_tail_x15_r0_body.cx0_173.mlx.nodes.get i).map fun nd => PRE_first_tail_x15_r0_body.kappa173.prim nd.prim)
kernel_rfl PRE_first_tail_x15_r0_body.fnordI173 : incrB PRE_first_tail_x15_r0_body.kd173.nodeF (List.range' 18703 0) = true
kernel_rfl PRE_first_tail_x15_r0_body.fnordK173 : (PTrie.keysA PRE_first_tail_x15_r0_body.kd173.node).all (fun k => Nat.ble 18703 k && Nat.blt k 18703) = true
kernel_rfl PRE_first_tail_x15_r0_body.fnordL173 : (PRE_first_tail_x15_r0_body.cln173.filter (Nat.ble PRE_first_tail_x15_r0_body.P173.N0)).all (fun i => Nat.ble i (PRE_first_tail_x15_r0_body.kd173.nodeF i) && (Nat.blt i 18703 || Nat.ble PRE_first_tail_x15_r0_body.kd173.nn0 i)) = true
theorem PRE_first_tail_x15_r0_body.fnord173 : (PRE_first_tail_x15_r0_body.cln173.filter (Nat.ble PRE_first_tail_x15_r0_body.P173.N0)).all (fun i => Nat.ble i (PRE_first_tail_x15_r0_body.kd173.nodeF i) &&
    (PTrie.keysA PRE_first_tail_x15_r0_body.kd173.node).all fun j => !Nat.blt j i || Nat.blt (PRE_first_tail_x15_r0_body.kd173.nodeF j) (PRE_first_tail_x15_r0_body.kd173.nodeF i)) = true :=
  cnord_of PRE_first_tail_x15_r0_body.cnlow173 PRE_first_tail_x15_r0_body.cnn1173 PRE_first_tail_x15_r0_body.fnordI173 PRE_first_tail_x15_r0_body.fnordK173 PRE_first_tail_x15_r0_body.fnordL173
kernel_rfl PRE_first_tail_x15_r0_body.fi173 : PRE_first_tail_x15_r0_body.cli173.all (pnB PRE_first_tail_x15_r0_body.cx0_173.mlx) = true
kernel_rfl PRE_first_tail_x15_r0_body.fii173 : PRE_first_tail_x15_r0_body.cli173.all (fun k => decide (PRE_first_tail_x15_r0_body.cx1_173.mlx.items.get (PRE_first_tail_x15_r0_body.kappa173.node k) = (PRE_first_tail_x15_r0_body.cx0_173.mlx.items.get k).map PRE_first_tail_x15_r0_body.kappa173.nv)) = true
/-- **The compaction's footprint.** -/
theorem PRE_first_tail_x15_r0_body.cfoot173 (clean : Conv.NClean (⟨21600, 18703, 2810343, 7450⟩ : Conv.Cnt) (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1522.ffi).mlx) (hltC : ∀ h, PH (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1522.ffi).mlx h → h < (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1522.ffi).mlx.next) (nltC : ∀ i, PN (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1522.ffi).mlx i → i < (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1522.ffi).mlx.nnext) (itemsC : ∀ k v, (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1522.ffi).mlx.items.get k = some v → PN (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1522.ffi).mlx k) (tracedC : ∀ h o, (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1522.ffi).mlx.objs.get h = some o → ∀ i ∈ objTraces o, i < PRE_first_tail_x15_r0_body.P173.NL) (cl : SSt (· < 7450) PRE_first_tail_x15_r0_body.cx0_173.mlx) :
    Conv.MFoot PRE_first_tail_x15_r0_body.P173 7450 PRE_first_tail_x15_r0_body.kappa173 PRE_first_tail_x15_r0_body.kd173 PRE_first_tail_x15_r0_body.khinv173 PRE_first_tail_x15_r0_body.kninv173 (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1522.ffi).mlx PRE_first_tail_x15_r0_body.cx0_173.mlx PRE_first_tail_x15_r0_body.cx1_173.mlx (⟨21600, 18703, 2810343, 7450⟩ : Conv.Cnt) PRE_first_tail_x15_r0_body.clo173 PRE_first_tail_x15_r0_body.cln173 PRE_first_tail_x15_r0_body.cli173 PRE_first_tail_x15_r0_body.cwS173 PRE_first_tail_x15_r0_body.cnS173 PRE_first_tail_x15_r0_body.ciS173 :=
  ⟨rfl, rfl, rfl, PRE_first_tail_x15_r0_body.cnh0173, PRE_first_tail_x15_r0_body.cnh1173, PRE_first_tail_x15_r0_body.cnn0173, PRE_first_tail_x15_r0_body.cnn1173, PRE_first_tail_x15_r0_body.cplo173, PRE_first_tail_x15_r0_body.ccnt173, PRE_first_tail_x15_r0_body.cnband173, PRE_first_tail_x15_r0_body.chbelow173, PRE_first_tail_x15_r0_body.chren173, PRE_first_tail_x15_r0_body.cband173, PRE_first_tail_x15_r0_body.cnh1pos173, PRE_first_tail_x15_r0_body.cnren173, PRE_first_tail_x15_r0_body.cnlow173, PRE_first_tail_x15_r0_body.cabs0a173, PRE_first_tail_x15_r0_body.cabs0b173, PRE_first_tail_x15_r0_body.ctok1173, PRE_first_tail_x15_r0_body.cpend173, PRE_first_tail_x15_r0_body.cerrh173, PRE_first_tail_x15_r0_body.cfiles173, PRE_first_tail_x15_r0_body.carch173, PRE_first_tail_x15_r0_body.csizes173, PRE_first_tail_x15_r0_body.cwired173, PRE_first_tail_x15_r0_body.cfix173, clean, PRE_first_tail_x15_r0_body.fcxn173, PRE_first_tail_x15_r0_body.fcnn173, hltC, nltC, itemsC, tracedC, cl, PRE_first_tail_x15_r0_body.fle0173, PRE_first_tail_x15_r0_body.fnk173, PRE_first_tail_x15_r0_body.ckA173, PRE_first_tail_x15_r0_body.cobjsK173, PRE_first_tail_x15_r0_body.cnodesK173, PRE_first_tail_x15_r0_body.citemsK173, PRE_first_tail_x15_r0_body.f1A173, PRE_first_tail_x15_r0_body.f1O173, PRE_first_tail_x15_r0_body.f1N173, PRE_first_tail_x15_r0_body.f1I173, PRE_first_tail_x15_r0_body.fbd173, PRE_first_tail_x15_r0_body.fincW173, PRE_first_tail_x15_r0_body.fincI173, PRE_first_tail_x15_r0_body.fincN173, PRE_first_tail_x15_r0_body.flnF173, PRE_first_tail_x15_r0_body.fh173, PRE_first_tail_x15_r0_body.fo173, PRE_first_tail_x15_r0_body.fok173, PRE_first_tail_x15_r0_body.fnd173, PRE_first_tail_x15_r0_body.fp173, PRE_first_tail_x15_r0_body.fnord173, PRE_first_tail_x15_r0_body.fi173, PRE_first_tail_x15_r0_body.fii173⟩
theorem PRE_first_tail_x15_r0_body.cnshift173 (clean : Conv.NClean (⟨21600, 18703, 2810343, 7450⟩ : Conv.Cnt) (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1522.ffi).mlx) (hltC : ∀ h, PH (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1522.ffi).mlx h → h < (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1522.ffi).mlx.next) (nltC : ∀ i, PN (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1522.ffi).mlx i → i < (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1522.ffi).mlx.nnext) (itemsC : ∀ k v, (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1522.ffi).mlx.items.get k = some v → PN (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1522.ffi).mlx k) (tracedC : ∀ h o, (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1522.ffi).mlx.objs.get h = some o → ∀ i ∈ objTraces o, i < PRE_first_tail_x15_r0_body.P173.NL) (cl : SSt (· < 7450) PRE_first_tail_x15_r0_body.cx0_173.mlx) : NShift PRE_first_tail_x15_r0_body.P173 7450 PRE_first_tail_x15_r0_body.kappa173 PRE_first_tail_x15_r0_body.cx0_173 PRE_first_tail_x15_r0_body.cx1_173 :=
  Conv.nshift_of_foot (PRE_first_tail_x15_r0_body.cfoot173 clean hltC nltC itemsC tracedC cl) PRE_first_tail_x15_r0_body.chost173 (compact_a_eq PRE_first_tail_x15_r0_body.ckn0173 PRE_first_tail_x15_r0_body.ckn1173 PRE_first_tail_x15_r0_body.ckheap173 PRE_first_tail_x15_r0_body.ckpl173)

-- the observers: the layers' states at the call, the canonical and the merged state, their footprints and checks
noncomputable def PRE_first_tail_x15_r0_body.fxC_173 : PTrie Unit := (Host.Ts.Sim.Full.freedOf PRE_first_tail_x15_r0_body.s1522.ffi).getD PTrie.nil
noncomputable def PRE_first_tail_x15_r0_body.krC_173 : Host.Load.Layers.KRec := (Host.Ts.Sim.Full.krecOf PRE_first_tail_x15_r0_body.s1522.ffi).getD Host.Load.Layers.KRec.empty
kernel_rfl PRE_first_tail_x15_r0_body.ofxC_173 : (Host.Ts.Sim.Full.freedOf PRE_first_tail_x15_r0_body.s1522.ffi) = some PRE_first_tail_x15_r0_body.fxC_173
kernel_rfl PRE_first_tail_x15_r0_body.okrC_173 : (Host.Ts.Sim.Full.krecOf PRE_first_tail_x15_r0_body.s1522.ffi) = some PRE_first_tail_x15_r0_body.krC_173
noncomputable def PRE_first_tail_x15_r0_body.fx0_173 : PTrie Unit := (Host.Ts.Sim.Full.freedOf PRE_first_tail_x15_r0_body.s1524.ffi).getD PTrie.nil
noncomputable def PRE_first_tail_x15_r0_body.kr0_173 : Host.Load.Layers.KRec := (Host.Ts.Sim.Full.krecOf PRE_first_tail_x15_r0_body.s1524.ffi).getD Host.Load.Layers.KRec.empty
kernel_rfl PRE_first_tail_x15_r0_body.ofx0_173 : (Host.Ts.Sim.Full.freedOf PRE_first_tail_x15_r0_body.s1524.ffi) = some PRE_first_tail_x15_r0_body.fx0_173
kernel_rfl PRE_first_tail_x15_r0_body.okr0_173 : (Host.Ts.Sim.Full.krecOf PRE_first_tail_x15_r0_body.s1524.ffi) = some PRE_first_tail_x15_r0_body.kr0_173
noncomputable def PRE_first_tail_x15_r0_body.fx1_173 : PTrie Unit := (Host.Ts.Sim.Full.freedOf PRE_first_tail_x15_r0_body.s1523.ffi).getD PTrie.nil
noncomputable def PRE_first_tail_x15_r0_body.kr1_173 : Host.Load.Layers.KRec := (Host.Ts.Sim.Full.krecOf PRE_first_tail_x15_r0_body.s1523.ffi).getD Host.Load.Layers.KRec.empty
kernel_rfl PRE_first_tail_x15_r0_body.ofx1_173 : (Host.Ts.Sim.Full.freedOf PRE_first_tail_x15_r0_body.s1523.ffi) = some PRE_first_tail_x15_r0_body.fx1_173
kernel_rfl PRE_first_tail_x15_r0_body.okr1_173 : (Host.Ts.Sim.Full.krecOf PRE_first_tail_x15_r0_body.s1523.ffi) = some PRE_first_tail_x15_r0_body.kr1_173
kernel_rfl PRE_first_tail_x15_r0_body.ff0173 : PRE_first_tail_x15_r0_body.fx0_173 = Stage.setAll PRE_first_tail_x15_r0_body.fxC_173 (PRE_first_tail_x15_r0_body.clo173.filterMap fun i => (PRE_first_tail_x15_r0_body.fx0_173.get i).map (i, ·))
kernel_rfl PRE_first_tail_x15_r0_body.ff1173 : PRE_first_tail_x15_r0_body.fx1_173 = Stage.setAll PRE_first_tail_x15_r0_body.fxC_173 (PRE_first_tail_x15_r0_body.cwS173.filterMap fun i => (PRE_first_tail_x15_r0_body.fx1_173.get i).map (i, ·))
kernel_rfl PRE_first_tail_x15_r0_body.ffck173 : freedLB PRE_first_tail_x15_r0_body.kappa173 PRE_first_tail_x15_r0_body.cx0_173.mlx PRE_first_tail_x15_r0_body.fx0_173 PRE_first_tail_x15_r0_body.fx1_173 PRE_first_tail_x15_r0_body.clo173 = true
kernel_rfl PRE_first_tail_x15_r0_body.fkf0173 : PRE_first_tail_x15_r0_body.kr0_173.flags = Stage.setAll PRE_first_tail_x15_r0_body.krC_173.flags (PRE_first_tail_x15_r0_body.clo173.filterMap fun i => (PRE_first_tail_x15_r0_body.kr0_173.flags.get i).map (i, ·))
kernel_rfl PRE_first_tail_x15_r0_body.fkt0173 : PRE_first_tail_x15_r0_body.kr0_173.targs = Stage.setAll PRE_first_tail_x15_r0_body.krC_173.targs (PRE_first_tail_x15_r0_body.clo173.filterMap fun i => (PRE_first_tail_x15_r0_body.kr0_173.targs.get i).map (i, ·))
kernel_rfl PRE_first_tail_x15_r0_body.fkf1173 : PRE_first_tail_x15_r0_body.kr1_173.flags = Stage.setAll PRE_first_tail_x15_r0_body.krC_173.flags (PRE_first_tail_x15_r0_body.cwS173.filterMap fun i => (PRE_first_tail_x15_r0_body.kr1_173.flags.get i).map (i, ·))
kernel_rfl PRE_first_tail_x15_r0_body.fkt1173 : PRE_first_tail_x15_r0_body.kr1_173.targs = Stage.setAll PRE_first_tail_x15_r0_body.krC_173.targs (PRE_first_tail_x15_r0_body.cwS173.filterMap fun i => (PRE_first_tail_x15_r0_body.kr1_173.targs.get i).map (i, ·))
kernel_rfl PRE_first_tail_x15_r0_body.fkck173 : krecLB PRE_first_tail_x15_r0_body.kappa173 7450 PRE_first_tail_x15_r0_body.cx0_173.mlx PRE_first_tail_x15_r0_body.kr0_173 PRE_first_tail_x15_r0_body.kr1_173 PRE_first_tail_x15_r0_body.clo173 = true
kernel_rfl PRE_first_tail_x15_r0_body.fkn173 : Nat.ble 7450 7450 = true
-- the bridge and the pending traces' regions
kernel_rfl PRE_first_tail_x15_r0_body.cbridge173 : Host.Ts.Sim.Full.bridgeOf PRE_first_tail_x15_r0_body.s1523.ffi = Host.Ts.Sim.Full.bridgeOf PRE_first_tail_x15_r0_body.s1524.ffi
kernel_rfl PRE_first_tail_x15_r0_body.cpendR173 : pendRegB PRE_first_tail_x15_r0_body.kappa173 (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1524.ffi).mlx = true
kernel_rfl PRE_first_tail_x15_r0_body.cpendLe173 : Nat.ble (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1524.ffi).mlx.next (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1523.ffi).mlx.next = true
/-- **The compaction's native shift**, given the call's bookkeeping, its relation's facts (the model's and the
observers') and the canonical closedness. -/
theorem PRE_first_tail_x15_r0_body.cshift173 (clean : Conv.NClean (⟨21600, 18703, 2810343, 7450⟩ : Conv.Cnt) (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1522.ffi).mlx) (hltC : ∀ h, PH (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1522.ffi).mlx h → h < (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1522.ffi).mlx.next) (nltC : ∀ i, PN (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1522.ffi).mlx i → i < (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1522.ffi).mlx.nnext) (itemsC : ∀ k v, (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1522.ffi).mlx.items.get k = some v → PN (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1522.ffi).mlx k) (tracedC : ∀ h o, (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1522.ffi).mlx.objs.get h = some o → ∀ i ∈ objTraces o, i < PRE_first_tail_x15_r0_body.P173.NL) (cl : SSt (· < 7450) PRE_first_tail_x15_r0_body.cx0_173.mlx)
    (hobjC : ∀ h, PRE_first_tail_x15_r0_body.fxC_173.get h = some () → ((Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1522.ffi).mlx.objs.get h).isSome = true)
    (hfC : ∀ h, (PRE_first_tail_x15_r0_body.krC_173.flags.get h).isSome = true → ((Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1522.ffi).mlx.objs.get h).isSome = true)
    (htC : ∀ h, (PRE_first_tail_x15_r0_body.krC_173.targs.get h).isSome = true → ((Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1522.ffi).mlx.objs.get h).isSome = true)
    (hclC : ∀ h l, PRE_first_tail_x15_r0_body.krC_173.targs.get h = some l → Host.Ts.Sim.Full.STargs (· < (⟨21600, 18703, 2810343, 7450⟩ : Conv.Cnt).n) l) :
    Conv.FullShiftQ PRE_first_tail_x15_r0_body.P173 7450 PRE_first_tail_x15_r0_body.kappa173 PRE_first_tail_x15_r0_body.s1524.ffi PRE_first_tail_x15_r0_body.s1523.ffi :=
  ⟨PRE_first_tail_x15_r0_body.cnshift173 clean hltC nltC itemsC tracedC cl, PRE_first_tail_x15_r0_body.cqueue173, fun t ht => bSN_sound (List.all_eq_true.mp PRE_first_tail_x15_r0_body.ctokSupp173 t ht),
    PRE_first_tail_x15_r0_body.cbridge173,
    liveShift_foot (x0' := Host.Ts.Sim.Full.mlxOf PRE_first_tail_x15_r0_body.s1524.ffi) (x1' := Host.Ts.Sim.Full.mlxOf PRE_first_tail_x15_r0_body.s1523.ffi) (PRE_first_tail_x15_r0_body.cfoot173 clean hltC nltC itemsC tracedC cl) rfl PRE_first_tail_x15_r0_body.ofx0_173 PRE_first_tail_x15_r0_body.ofx1_173 hobjC PRE_first_tail_x15_r0_body.ff0173 PRE_first_tail_x15_r0_body.ff1173 PRE_first_tail_x15_r0_body.ffck173,
    kernShift_foot (x0' := Host.Ts.Sim.Full.mlxOf PRE_first_tail_x15_r0_body.s1524.ffi) (x1' := Host.Ts.Sim.Full.mlxOf PRE_first_tail_x15_r0_body.s1523.ffi) (PRE_first_tail_x15_r0_body.cfoot173 clean hltC nltC itemsC tracedC cl) rfl PRE_first_tail_x15_r0_body.okr0_173 PRE_first_tail_x15_r0_body.okr1_173 (Nat.le_of_ble_eq_true PRE_first_tail_x15_r0_body.fkn173) hfC htC hclC
      PRE_first_tail_x15_r0_body.fkf0173 PRE_first_tail_x15_r0_body.fkt0173 PRE_first_tail_x15_r0_body.fkf1173 PRE_first_tail_x15_r0_body.fkt1173 PRE_first_tail_x15_r0_body.fkck173,
    pendReg_of rfl PRE_first_tail_x15_r0_body.cnh0173 PRE_first_tail_x15_r0_body.cnh1173 (Nat.le_of_ble_eq_true PRE_first_tail_x15_r0_body.cpendLe173) PRE_first_tail_x15_r0_body.cpendR173⟩

end Host.Load.Run.Tpl
