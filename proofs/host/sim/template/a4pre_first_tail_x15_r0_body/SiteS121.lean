import host.sim.template.a4pre_first_tail_x15_r0_body.SiteCl121
import host.sim.conv.CompactFull
import host.sim.template.FootGen
set_option Elab.async false
namespace Host.Load.Run.Tpl
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
open Host.Ts Host.Ts.Sim Host.Ts.Sim.Template

/-! The compaction's native shift at call site 121 from its footprint (`Conv.nshift_of_foot`), and the observers'
(`liveShift_foot`, `kernShift_foot`): `Conv.FullShiftQ` for `Conv.full_compactQ`, given the call's bookkeeping and its
relation's facts. -/

/-- The load parameters of the chain (band-free: its start's node counter as `NL` and `N0`). -/
def PRE_first_tail_x15_r0_body.Pc121 : LoadP := ⟨18151, 131072, 1099511627776, 15235, 15235, []⟩
/-- The site's band raised to the map's checked fixed-node prefix, including newly recorded closure traces. -/
def PRE_first_tail_x15_r0_body.P121 : LoadP := PRE_first_tail_x15_r0_body.Pc121.raise 17688
kernel_rfl PRE_first_tail_x15_r0_body.craise121 : Nat.ble PRE_first_tail_x15_r0_body.Pc121.N0 17688 = true
theorem PRE_first_tail_x15_r0_body.raised121 : Host.Ts.Sim.Full.Raised PRE_first_tail_x15_r0_body.Pc121 PRE_first_tail_x15_r0_body.P121 :=
  .inr ⟨17688, rfl, Nat.le_of_ble_eq_true PRE_first_tail_x15_r0_body.craise121, rfl⟩
noncomputable abbrev PRE_first_tail_x15_r0_body.cx0_121 : Host.Load.LSt := clearTokens (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1073.ffi)
noncomputable abbrev PRE_first_tail_x15_r0_body.cx1_121 : Host.Load.LSt := clearTokens (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1072.ffi)
def PRE_first_tail_x15_r0_body.khinv121 : PTrie Nat := Stage.setAll PTrie.nil []
def PRE_first_tail_x15_r0_body.kninv121 : PTrie Nat := Stage.setAll PTrie.nil []
/-- The stage's footprint: its written and fresh handles, fresh nodes, written and fresh items. -/
def PRE_first_tail_x15_r0_body.cwS121 : List Nat := []
def PRE_first_tail_x15_r0_body.cnS121 : List Nat := List.range' 17688 0
def PRE_first_tail_x15_r0_body.ciS121 : List Nat := [] ++ List.range' 17688 0

-- the small checks (`MChecks`'s)
kernel_rfl PRE_first_tail_x15_r0_body.cnh0121 : PRE_first_tail_x15_r0_body.kd121.nh0 = PRE_first_tail_x15_r0_body.cx0_121.mlx.next
kernel_rfl PRE_first_tail_x15_r0_body.cnh1121 : PRE_first_tail_x15_r0_body.kd121.nh1 = PRE_first_tail_x15_r0_body.cx1_121.mlx.next
kernel_rfl PRE_first_tail_x15_r0_body.cnn0121 : PRE_first_tail_x15_r0_body.kd121.nn0 = PRE_first_tail_x15_r0_body.cx0_121.mlx.nnext
kernel_rfl PRE_first_tail_x15_r0_body.cnn1121 : PRE_first_tail_x15_r0_body.kd121.nn1 = PRE_first_tail_x15_r0_body.cx1_121.mlx.nnext
kernel_rfl PRE_first_tail_x15_r0_body.cplo121 : (Nat.blt 0 PRE_first_tail_x15_r0_body.P121.lo && Nat.ble PRE_first_tail_x15_r0_body.P121.lo PRE_first_tail_x15_r0_body.cx0_121.mlx.next && Nat.ble PRE_first_tail_x15_r0_body.P121.lo RData.bigHi && Nat.ble RData.bigHi PRE_first_tail_x15_r0_body.P121.E) = true
kernel_rfl PRE_first_tail_x15_r0_body.ccnt121 : (Nat.ble PRE_first_tail_x15_r0_body.cx0_121.mlx.next PRE_first_tail_x15_r0_body.cx1_121.mlx.next && Nat.ble PRE_first_tail_x15_r0_body.cx0_121.mlx.nnext PRE_first_tail_x15_r0_body.cx1_121.mlx.nnext) = true
kernel_rfl PRE_first_tail_x15_r0_body.cnband121 : (Nat.blt 0 PRE_first_tail_x15_r0_body.P121.NL && Nat.ble PRE_first_tail_x15_r0_body.P121.NL PRE_first_tail_x15_r0_body.P121.N0 && Nat.ble PRE_first_tail_x15_r0_body.P121.N0 PRE_first_tail_x15_r0_body.cx0_121.mlx.nnext) = true
kernel_rfl PRE_first_tail_x15_r0_body.chbelow121 : PRE_first_tail_x15_r0_body.kd121.checkHndBelow = true
kernel_rfl PRE_first_tail_x15_r0_body.chren121 : checkRenG PRE_first_tail_x15_r0_body.kd121.hnd PRE_first_tail_x15_r0_body.khinv121 (phB PRE_first_tail_x15_r0_body.cx0_121.mlx) = true
kernel_rfl PRE_first_tail_x15_r0_body.cband121 : PRE_first_tail_x15_r0_body.kd121.checkBand PRE_first_tail_x15_r0_body.P121.lo = true
kernel_rfl PRE_first_tail_x15_r0_body.cnh1pos121 : Nat.blt 0 PRE_first_tail_x15_r0_body.kd121.nh1 = true
kernel_rfl PRE_first_tail_x15_r0_body.cnren121 : checkRenG PRE_first_tail_x15_r0_body.kd121.node PRE_first_tail_x15_r0_body.kninv121 (pnB PRE_first_tail_x15_r0_body.cx0_121.mlx) = true
kernel_rfl PRE_first_tail_x15_r0_body.cnlow121 : (PTrie.keysA PRE_first_tail_x15_r0_body.kd121.node).all (fun j => Nat.ble PRE_first_tail_x15_r0_body.P121.NL j && Nat.blt (PRE_first_tail_x15_r0_body.kd121.nodeF j) PRE_first_tail_x15_r0_body.cx1_121.mlx.nnext) = true
kernel_rfl PRE_first_tail_x15_r0_body.cabs0a121 : PRE_first_tail_x15_r0_body.cx0_121.mlx.arrs.get 0 = none
kernel_rfl PRE_first_tail_x15_r0_body.cabs0b121 : PRE_first_tail_x15_r0_body.cx0_121.mlx.objs.get 0 = none
kernel_rfl PRE_first_tail_x15_r0_body.ctok1121 : PRE_first_tail_x15_r0_body.cx1_121.mlx.tokens = []
kernel_rfl PRE_first_tail_x15_r0_body.cpend121 : PRE_first_tail_x15_r0_body.cx1_121.mlx.pending = PRE_first_tail_x15_r0_body.cx0_121.mlx.pending.map PRE_first_tail_x15_r0_body.kappa121.pend
kernel_rfl PRE_first_tail_x15_r0_body.cerrh121 : PRE_first_tail_x15_r0_body.cx1_121.mlx.errh = PRE_first_tail_x15_r0_body.cx0_121.mlx.errh.map PRE_first_tail_x15_r0_body.kappa121.arg
kernel_rfl PRE_first_tail_x15_r0_body.cfiles121 : PRE_first_tail_x15_r0_body.cx1_121.mlx.files = PRE_first_tail_x15_r0_body.cx0_121.mlx.files
kernel_rfl PRE_first_tail_x15_r0_body.carch121 : PRE_first_tail_x15_r0_body.cx1_121.mlx.arch = PRE_first_tail_x15_r0_body.cx0_121.mlx.arch
kernel_rfl PRE_first_tail_x15_r0_body.csizes121 : PRE_first_tail_x15_r0_body.cx1_121.mlx.deviceSizes = PRE_first_tail_x15_r0_body.cx0_121.mlx.deviceSizes
kernel_rfl PRE_first_tail_x15_r0_body.cwired121 : PRE_first_tail_x15_r0_body.cx1_121.mlx.wired = PRE_first_tail_x15_r0_body.cx0_121.mlx.wired
kernel_rfl PRE_first_tail_x15_r0_body.chost121 : PRE_first_tail_x15_r0_body.cx1_121.host = PRE_first_tail_x15_r0_body.cx0_121.host
-- the compaction map's addresses are `PRE_first_tail_x15_r0_body.kd121`'s
kernel_rfl PRE_first_tail_x15_r0_body.ckn0121 : PRE_first_tail_x15_r0_body.kd121.n0 = 2770119
kernel_rfl PRE_first_tail_x15_r0_body.ckn1121 : PRE_first_tail_x15_r0_body.kd121.n1 = 2770121
kernel_rfl PRE_first_tail_x15_r0_body.ckheap121 : (PTrie.keysA PRE_first_tail_x15_r0_body.kd121.heap).all (fun x => Nat.ble 2770119 x) = true
kernel_rfl PRE_first_tail_x15_r0_body.ckpl121 : (List.range 0).all (fun j => decide (PRE_first_tail_x15_r0_body.kd121.heap.get (2770119 + j) = nth? PRE_first_tail_x15_r0_body.pl121 j)) = true
-- the map fixes the call's names (`Conv.fixOld_compact`), the call's counters
kernel_rfl PRE_first_tail_x15_r0_body.fja121 : Nat.ble 2770119 2770119 = true
kernel_rfl PRE_first_tail_x15_r0_body.fn121 : Nat.ble 5252 5252 = true
kernel_rfl PRE_first_tail_x15_r0_body.fjaD121 : Nat.ble 2770119 PRE_first_tail_x15_r0_body.kd121.n0 = true
kernel_rfl PRE_first_tail_x15_r0_body.fxn121 : Nat.ble 20592 PRE_first_tail_x15_r0_body.kd121.nh0 = true
kernel_rfl PRE_first_tail_x15_r0_body.fnn121 : Nat.ble 17688 PRE_first_tail_x15_r0_body.kd121.nn0 = true
kernel_rfl PRE_first_tail_x15_r0_body.fxb121 : Nat.ble 20592 RData.bigHi = true
kernel_rfl PRE_first_tail_x15_r0_body.fheap121 : (PTrie.keysA PRE_first_tail_x15_r0_body.kd121.heap).all (Nat.ble (⟨20592, 17688, 2770119, 5252⟩ : Conv.Cnt).ja) = true
kernel_rfl PRE_first_tail_x15_r0_body.fhnd121 : (PTrie.keysA PRE_first_tail_x15_r0_body.kd121.hnd).all (Nat.ble (⟨20592, 17688, 2770119, 5252⟩ : Conv.Cnt).xn) = true
kernel_rfl PRE_first_tail_x15_r0_body.fnode121 : (PTrie.keysA PRE_first_tail_x15_r0_body.kd121.node).all (Nat.ble (⟨20592, 17688, 2770119, 5252⟩ : Conv.Cnt).nn) = true
/-- The compaction map fixes the call's names. -/
theorem PRE_first_tail_x15_r0_body.cfix121 : Conv.FixOld (⟨20592, 17688, 2770119, 5252⟩ : Conv.Cnt) PRE_first_tail_x15_r0_body.kappa121 :=
  Conv.fixOld_compact (Nat.le_of_ble_eq_true PRE_first_tail_x15_r0_body.fja121) (Nat.le_of_ble_eq_true PRE_first_tail_x15_r0_body.fn121) (Nat.le_of_ble_eq_true PRE_first_tail_x15_r0_body.fjaD121) (Nat.le_of_ble_eq_true PRE_first_tail_x15_r0_body.fxn121) (Nat.le_of_ble_eq_true PRE_first_tail_x15_r0_body.fnn121) (Nat.le_of_ble_eq_true PRE_first_tail_x15_r0_body.fxb121) PRE_first_tail_x15_r0_body.fheap121 PRE_first_tail_x15_r0_body.fhnd121 PRE_first_tail_x15_r0_body.fnode121
kernel_rfl PRE_first_tail_x15_r0_body.fcxn121 : (⟨20592, 17688, 2770119, 5252⟩ : Conv.Cnt).xn = (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1071.ffi).mlx.next
kernel_rfl PRE_first_tail_x15_r0_body.fcnn121 : (⟨20592, 17688, 2770119, 5252⟩ : Conv.Cnt).nn = (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1071.ffi).mlx.nnext
kernel_rfl PRE_first_tail_x15_r0_body.fle0121 : (Nat.ble (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1071.ffi).mlx.next PRE_first_tail_x15_r0_body.cx0_121.mlx.next && Nat.ble (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1071.ffi).mlx.nnext PRE_first_tail_x15_r0_body.cx0_121.mlx.nnext && Nat.ble (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1071.ffi).mlx.next RData.bigHi) = true
kernel_rfl PRE_first_tail_x15_r0_body.fnk121 : (PTrie.keysA PRE_first_tail_x15_r0_body.kd121.node).all (Nat.ble (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1071.ffi).mlx.nnext) = true
-- the merged state keeps the call's entries off the stage's footprint
kernel_rfl PRE_first_tail_x15_r0_body.f1A121 : PRE_first_tail_x15_r0_body.cx1_121.mlx.arrs = Stage.setAll (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1071.ffi).mlx.arrs (PRE_first_tail_x15_r0_body.cwS121.filterMap fun i => (PRE_first_tail_x15_r0_body.cx1_121.mlx.arrs.get i).map (i, ·))
kernel_rfl PRE_first_tail_x15_r0_body.f1O121 : PRE_first_tail_x15_r0_body.cx1_121.mlx.objs = Stage.setAll (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1071.ffi).mlx.objs (PRE_first_tail_x15_r0_body.cwS121.filterMap fun i => (PRE_first_tail_x15_r0_body.cx1_121.mlx.objs.get i).map (i, ·))
kernel_rfl PRE_first_tail_x15_r0_body.f1N121 : PRE_first_tail_x15_r0_body.cx1_121.mlx.nodes = Stage.setAll (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1071.ffi).mlx.nodes (PRE_first_tail_x15_r0_body.cnS121.filterMap fun i => (PRE_first_tail_x15_r0_body.cx1_121.mlx.nodes.get i).map (i, ·))
kernel_rfl PRE_first_tail_x15_r0_body.f1I121 : PRE_first_tail_x15_r0_body.cx1_121.mlx.items = Stage.setAll (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1071.ffi).mlx.items (PRE_first_tail_x15_r0_body.ciS121.filterMap fun i => (PRE_first_tail_x15_r0_body.cx1_121.mlx.items.get i).map (i, ·))
kernel_rfl PRE_first_tail_x15_r0_body.fbd121 : (PRE_first_tail_x15_r0_body.clo121 ++ PRE_first_tail_x15_r0_body.cln121 ++ PRE_first_tail_x15_r0_body.cli121 ++ PRE_first_tail_x15_r0_body.cwS121 ++ PRE_first_tail_x15_r0_body.cnS121 ++ PRE_first_tail_x15_r0_body.ciS121).all (fun i => Nat.blt (i / 4096) (4 ^ 31)) = true
kernel_rfl PRE_first_tail_x15_r0_body.fincW121 : PRE_first_tail_x15_r0_body.cwS121.all (fun h => !Nat.blt h (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1071.ffi).mlx.next || PRE_first_tail_x15_r0_body.clo121.contains h) = true
kernel_rfl PRE_first_tail_x15_r0_body.fincI121 : PRE_first_tail_x15_r0_body.ciS121.all (fun k => !Nat.blt k (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1071.ffi).mlx.nnext || PRE_first_tail_x15_r0_body.cli121.contains k) = true
kernel_rfl PRE_first_tail_x15_r0_body.fincN121 : PRE_first_tail_x15_r0_body.cnS121.all (Nat.ble (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1071.ffi).mlx.nnext) = true
kernel_rfl PRE_first_tail_x15_r0_body.flnF121 : PRE_first_tail_x15_r0_body.cln121.all (Nat.ble (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1071.ffi).mlx.nnext) = true
-- the checks over the changed lists
kernel_rfl PRE_first_tail_x15_r0_body.fh121 : PRE_first_tail_x15_r0_body.clo121.all (handleOK PRE_first_tail_x15_r0_body.kappa121 PRE_first_tail_x15_r0_body.P121.lo PRE_first_tail_x15_r0_body.cx0_121.mlx PRE_first_tail_x15_r0_body.cx1_121.mlx) = true
kernel_rfl PRE_first_tail_x15_r0_body.fo121 : PRE_first_tail_x15_r0_body.clo121.map (fun h => PRE_first_tail_x15_r0_body.cx1_121.mlx.objs.get (PRE_first_tail_x15_r0_body.kappa121.handle h)) = PRE_first_tail_x15_r0_body.clo121.map (fun h => (PRE_first_tail_x15_r0_body.cx0_121.mlx.objs.get h).map PRE_first_tail_x15_r0_body.kappa121.nobj)
kernel_rfl PRE_first_tail_x15_r0_body.fok121 : PRE_first_tail_x15_r0_body.clo121.all (objOK PRE_first_tail_x15_r0_body.kappa121 PRE_first_tail_x15_r0_body.P121.NL PRE_first_tail_x15_r0_body.cx0_121.mlx) = true
kernel_rfl PRE_first_tail_x15_r0_body.fnd121 : PRE_first_tail_x15_r0_body.cln121.all (nodeOKF PRE_first_tail_x15_r0_body.kappa121 PRE_first_tail_x15_r0_body.P121 PRE_first_tail_x15_r0_body.cx0_121.mlx PRE_first_tail_x15_r0_body.cx1_121.mlx) = true
kernel_rfl PRE_first_tail_x15_r0_body.fp121 : ((PRE_first_tail_x15_r0_body.cln121.filter (fullB PRE_first_tail_x15_r0_body.P121))).map (fun i => (PRE_first_tail_x15_r0_body.cx1_121.mlx.nodes.get (PRE_first_tail_x15_r0_body.kappa121.node i)).map Host.Mlx.Ffi.Node.prim) =
  ((PRE_first_tail_x15_r0_body.cln121.filter (fullB PRE_first_tail_x15_r0_body.P121))).map (fun i => (PRE_first_tail_x15_r0_body.cx0_121.mlx.nodes.get i).map fun nd => PRE_first_tail_x15_r0_body.kappa121.prim nd.prim)
kernel_rfl PRE_first_tail_x15_r0_body.fnordI121 : incrB PRE_first_tail_x15_r0_body.kd121.nodeF (List.range' 17688 0) = true
kernel_rfl PRE_first_tail_x15_r0_body.fnordK121 : (PTrie.keysA PRE_first_tail_x15_r0_body.kd121.node).all (fun k => Nat.ble 17688 k && Nat.blt k 17688) = true
kernel_rfl PRE_first_tail_x15_r0_body.fnordL121 : (PRE_first_tail_x15_r0_body.cln121.filter (Nat.ble PRE_first_tail_x15_r0_body.P121.N0)).all (fun i => Nat.ble i (PRE_first_tail_x15_r0_body.kd121.nodeF i) && (Nat.blt i 17688 || Nat.ble PRE_first_tail_x15_r0_body.kd121.nn0 i)) = true
theorem PRE_first_tail_x15_r0_body.fnord121 : (PRE_first_tail_x15_r0_body.cln121.filter (Nat.ble PRE_first_tail_x15_r0_body.P121.N0)).all (fun i => Nat.ble i (PRE_first_tail_x15_r0_body.kd121.nodeF i) &&
    (PTrie.keysA PRE_first_tail_x15_r0_body.kd121.node).all fun j => !Nat.blt j i || Nat.blt (PRE_first_tail_x15_r0_body.kd121.nodeF j) (PRE_first_tail_x15_r0_body.kd121.nodeF i)) = true :=
  cnord_of PRE_first_tail_x15_r0_body.cnlow121 PRE_first_tail_x15_r0_body.cnn1121 PRE_first_tail_x15_r0_body.fnordI121 PRE_first_tail_x15_r0_body.fnordK121 PRE_first_tail_x15_r0_body.fnordL121
kernel_rfl PRE_first_tail_x15_r0_body.fi121 : PRE_first_tail_x15_r0_body.cli121.all (pnB PRE_first_tail_x15_r0_body.cx0_121.mlx) = true
kernel_rfl PRE_first_tail_x15_r0_body.fii121 : PRE_first_tail_x15_r0_body.cli121.all (fun k => decide (PRE_first_tail_x15_r0_body.cx1_121.mlx.items.get (PRE_first_tail_x15_r0_body.kappa121.node k) = (PRE_first_tail_x15_r0_body.cx0_121.mlx.items.get k).map PRE_first_tail_x15_r0_body.kappa121.nv)) = true
/-- **The compaction's footprint.** -/
theorem PRE_first_tail_x15_r0_body.cfoot121 (clean : Conv.NClean (⟨20592, 17688, 2770119, 5252⟩ : Conv.Cnt) (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1071.ffi).mlx) (hltC : ∀ h, PH (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1071.ffi).mlx h → h < (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1071.ffi).mlx.next) (nltC : ∀ i, PN (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1071.ffi).mlx i → i < (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1071.ffi).mlx.nnext) (itemsC : ∀ k v, (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1071.ffi).mlx.items.get k = some v → PN (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1071.ffi).mlx k) (tracedC : ∀ h o, (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1071.ffi).mlx.objs.get h = some o → ∀ i ∈ objTraces o, i < PRE_first_tail_x15_r0_body.P121.NL) (cl : SSt (· < 5252) PRE_first_tail_x15_r0_body.cx0_121.mlx) :
    Conv.MFoot PRE_first_tail_x15_r0_body.P121 5252 PRE_first_tail_x15_r0_body.kappa121 PRE_first_tail_x15_r0_body.kd121 PRE_first_tail_x15_r0_body.khinv121 PRE_first_tail_x15_r0_body.kninv121 (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1071.ffi).mlx PRE_first_tail_x15_r0_body.cx0_121.mlx PRE_first_tail_x15_r0_body.cx1_121.mlx (⟨20592, 17688, 2770119, 5252⟩ : Conv.Cnt) PRE_first_tail_x15_r0_body.clo121 PRE_first_tail_x15_r0_body.cln121 PRE_first_tail_x15_r0_body.cli121 PRE_first_tail_x15_r0_body.cwS121 PRE_first_tail_x15_r0_body.cnS121 PRE_first_tail_x15_r0_body.ciS121 :=
  ⟨rfl, rfl, rfl, PRE_first_tail_x15_r0_body.cnh0121, PRE_first_tail_x15_r0_body.cnh1121, PRE_first_tail_x15_r0_body.cnn0121, PRE_first_tail_x15_r0_body.cnn1121, PRE_first_tail_x15_r0_body.cplo121, PRE_first_tail_x15_r0_body.ccnt121, PRE_first_tail_x15_r0_body.cnband121, PRE_first_tail_x15_r0_body.chbelow121, PRE_first_tail_x15_r0_body.chren121, PRE_first_tail_x15_r0_body.cband121, PRE_first_tail_x15_r0_body.cnh1pos121, PRE_first_tail_x15_r0_body.cnren121, PRE_first_tail_x15_r0_body.cnlow121, PRE_first_tail_x15_r0_body.cabs0a121, PRE_first_tail_x15_r0_body.cabs0b121, PRE_first_tail_x15_r0_body.ctok1121, PRE_first_tail_x15_r0_body.cpend121, PRE_first_tail_x15_r0_body.cerrh121, PRE_first_tail_x15_r0_body.cfiles121, PRE_first_tail_x15_r0_body.carch121, PRE_first_tail_x15_r0_body.csizes121, PRE_first_tail_x15_r0_body.cwired121, PRE_first_tail_x15_r0_body.cfix121, clean, PRE_first_tail_x15_r0_body.fcxn121, PRE_first_tail_x15_r0_body.fcnn121, hltC, nltC, itemsC, tracedC, cl, PRE_first_tail_x15_r0_body.fle0121, PRE_first_tail_x15_r0_body.fnk121, PRE_first_tail_x15_r0_body.ckA121, PRE_first_tail_x15_r0_body.cobjsK121, PRE_first_tail_x15_r0_body.cnodesK121, PRE_first_tail_x15_r0_body.citemsK121, PRE_first_tail_x15_r0_body.f1A121, PRE_first_tail_x15_r0_body.f1O121, PRE_first_tail_x15_r0_body.f1N121, PRE_first_tail_x15_r0_body.f1I121, PRE_first_tail_x15_r0_body.fbd121, PRE_first_tail_x15_r0_body.fincW121, PRE_first_tail_x15_r0_body.fincI121, PRE_first_tail_x15_r0_body.fincN121, PRE_first_tail_x15_r0_body.flnF121, PRE_first_tail_x15_r0_body.fh121, PRE_first_tail_x15_r0_body.fo121, PRE_first_tail_x15_r0_body.fok121, PRE_first_tail_x15_r0_body.fnd121, PRE_first_tail_x15_r0_body.fp121, PRE_first_tail_x15_r0_body.fnord121, PRE_first_tail_x15_r0_body.fi121, PRE_first_tail_x15_r0_body.fii121⟩
theorem PRE_first_tail_x15_r0_body.cnshift121 (clean : Conv.NClean (⟨20592, 17688, 2770119, 5252⟩ : Conv.Cnt) (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1071.ffi).mlx) (hltC : ∀ h, PH (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1071.ffi).mlx h → h < (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1071.ffi).mlx.next) (nltC : ∀ i, PN (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1071.ffi).mlx i → i < (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1071.ffi).mlx.nnext) (itemsC : ∀ k v, (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1071.ffi).mlx.items.get k = some v → PN (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1071.ffi).mlx k) (tracedC : ∀ h o, (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1071.ffi).mlx.objs.get h = some o → ∀ i ∈ objTraces o, i < PRE_first_tail_x15_r0_body.P121.NL) (cl : SSt (· < 5252) PRE_first_tail_x15_r0_body.cx0_121.mlx) : NShift PRE_first_tail_x15_r0_body.P121 5252 PRE_first_tail_x15_r0_body.kappa121 PRE_first_tail_x15_r0_body.cx0_121 PRE_first_tail_x15_r0_body.cx1_121 :=
  Conv.nshift_of_foot (PRE_first_tail_x15_r0_body.cfoot121 clean hltC nltC itemsC tracedC cl) PRE_first_tail_x15_r0_body.chost121 (compact_a_eq PRE_first_tail_x15_r0_body.ckn0121 PRE_first_tail_x15_r0_body.ckn1121 PRE_first_tail_x15_r0_body.ckheap121 PRE_first_tail_x15_r0_body.ckpl121)

-- the observers: the layers' states at the call, the canonical and the merged state, their footprints and checks
noncomputable def PRE_first_tail_x15_r0_body.fxC_121 : PTrie Unit := (Host.Ts.Sim.Full.freedOf PRE_first_tail_x15_r0_body.s1071.ffi).getD PTrie.nil
noncomputable def PRE_first_tail_x15_r0_body.krC_121 : Host.Load.Layers.KRec := (Host.Ts.Sim.Full.krecOf PRE_first_tail_x15_r0_body.s1071.ffi).getD Host.Load.Layers.KRec.empty
kernel_rfl PRE_first_tail_x15_r0_body.ofxC_121 : (Host.Ts.Sim.Full.freedOf PRE_first_tail_x15_r0_body.s1071.ffi) = some PRE_first_tail_x15_r0_body.fxC_121
kernel_rfl PRE_first_tail_x15_r0_body.okrC_121 : (Host.Ts.Sim.Full.krecOf PRE_first_tail_x15_r0_body.s1071.ffi) = some PRE_first_tail_x15_r0_body.krC_121
noncomputable def PRE_first_tail_x15_r0_body.fx0_121 : PTrie Unit := (Host.Ts.Sim.Full.freedOf PRE_first_tail_x15_r0_body.s1073.ffi).getD PTrie.nil
noncomputable def PRE_first_tail_x15_r0_body.kr0_121 : Host.Load.Layers.KRec := (Host.Ts.Sim.Full.krecOf PRE_first_tail_x15_r0_body.s1073.ffi).getD Host.Load.Layers.KRec.empty
kernel_rfl PRE_first_tail_x15_r0_body.ofx0_121 : (Host.Ts.Sim.Full.freedOf PRE_first_tail_x15_r0_body.s1073.ffi) = some PRE_first_tail_x15_r0_body.fx0_121
kernel_rfl PRE_first_tail_x15_r0_body.okr0_121 : (Host.Ts.Sim.Full.krecOf PRE_first_tail_x15_r0_body.s1073.ffi) = some PRE_first_tail_x15_r0_body.kr0_121
noncomputable def PRE_first_tail_x15_r0_body.fx1_121 : PTrie Unit := (Host.Ts.Sim.Full.freedOf PRE_first_tail_x15_r0_body.s1072.ffi).getD PTrie.nil
noncomputable def PRE_first_tail_x15_r0_body.kr1_121 : Host.Load.Layers.KRec := (Host.Ts.Sim.Full.krecOf PRE_first_tail_x15_r0_body.s1072.ffi).getD Host.Load.Layers.KRec.empty
kernel_rfl PRE_first_tail_x15_r0_body.ofx1_121 : (Host.Ts.Sim.Full.freedOf PRE_first_tail_x15_r0_body.s1072.ffi) = some PRE_first_tail_x15_r0_body.fx1_121
kernel_rfl PRE_first_tail_x15_r0_body.okr1_121 : (Host.Ts.Sim.Full.krecOf PRE_first_tail_x15_r0_body.s1072.ffi) = some PRE_first_tail_x15_r0_body.kr1_121
kernel_rfl PRE_first_tail_x15_r0_body.ff0121 : PRE_first_tail_x15_r0_body.fx0_121 = Stage.setAll PRE_first_tail_x15_r0_body.fxC_121 (PRE_first_tail_x15_r0_body.clo121.filterMap fun i => (PRE_first_tail_x15_r0_body.fx0_121.get i).map (i, ·))
kernel_rfl PRE_first_tail_x15_r0_body.ff1121 : PRE_first_tail_x15_r0_body.fx1_121 = Stage.setAll PRE_first_tail_x15_r0_body.fxC_121 (PRE_first_tail_x15_r0_body.cwS121.filterMap fun i => (PRE_first_tail_x15_r0_body.fx1_121.get i).map (i, ·))
kernel_rfl PRE_first_tail_x15_r0_body.ffck121 : freedLB PRE_first_tail_x15_r0_body.kappa121 PRE_first_tail_x15_r0_body.cx0_121.mlx PRE_first_tail_x15_r0_body.fx0_121 PRE_first_tail_x15_r0_body.fx1_121 PRE_first_tail_x15_r0_body.clo121 = true
kernel_rfl PRE_first_tail_x15_r0_body.fkf0121 : PRE_first_tail_x15_r0_body.kr0_121.flags = Stage.setAll PRE_first_tail_x15_r0_body.krC_121.flags (PRE_first_tail_x15_r0_body.clo121.filterMap fun i => (PRE_first_tail_x15_r0_body.kr0_121.flags.get i).map (i, ·))
kernel_rfl PRE_first_tail_x15_r0_body.fkt0121 : PRE_first_tail_x15_r0_body.kr0_121.targs = Stage.setAll PRE_first_tail_x15_r0_body.krC_121.targs (PRE_first_tail_x15_r0_body.clo121.filterMap fun i => (PRE_first_tail_x15_r0_body.kr0_121.targs.get i).map (i, ·))
kernel_rfl PRE_first_tail_x15_r0_body.fkf1121 : PRE_first_tail_x15_r0_body.kr1_121.flags = Stage.setAll PRE_first_tail_x15_r0_body.krC_121.flags (PRE_first_tail_x15_r0_body.cwS121.filterMap fun i => (PRE_first_tail_x15_r0_body.kr1_121.flags.get i).map (i, ·))
kernel_rfl PRE_first_tail_x15_r0_body.fkt1121 : PRE_first_tail_x15_r0_body.kr1_121.targs = Stage.setAll PRE_first_tail_x15_r0_body.krC_121.targs (PRE_first_tail_x15_r0_body.cwS121.filterMap fun i => (PRE_first_tail_x15_r0_body.kr1_121.targs.get i).map (i, ·))
kernel_rfl PRE_first_tail_x15_r0_body.fkck121 : krecLB PRE_first_tail_x15_r0_body.kappa121 5252 PRE_first_tail_x15_r0_body.cx0_121.mlx PRE_first_tail_x15_r0_body.kr0_121 PRE_first_tail_x15_r0_body.kr1_121 PRE_first_tail_x15_r0_body.clo121 = true
kernel_rfl PRE_first_tail_x15_r0_body.fkn121 : Nat.ble 5252 5252 = true
-- the bridge and the pending traces' regions
kernel_rfl PRE_first_tail_x15_r0_body.cbridge121 : Host.Ts.Sim.Full.bridgeOf PRE_first_tail_x15_r0_body.s1072.ffi = Host.Ts.Sim.Full.bridgeOf PRE_first_tail_x15_r0_body.s1073.ffi
kernel_rfl PRE_first_tail_x15_r0_body.cpendR121 : pendRegB PRE_first_tail_x15_r0_body.kappa121 (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1073.ffi).mlx = true
kernel_rfl PRE_first_tail_x15_r0_body.cpendLe121 : Nat.ble (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1073.ffi).mlx.next (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1072.ffi).mlx.next = true
/-- **The compaction's native shift**, given the call's bookkeeping, its relation's facts (the model's and the
observers') and the canonical closedness. -/
theorem PRE_first_tail_x15_r0_body.cshift121 (clean : Conv.NClean (⟨20592, 17688, 2770119, 5252⟩ : Conv.Cnt) (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1071.ffi).mlx) (hltC : ∀ h, PH (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1071.ffi).mlx h → h < (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1071.ffi).mlx.next) (nltC : ∀ i, PN (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1071.ffi).mlx i → i < (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1071.ffi).mlx.nnext) (itemsC : ∀ k v, (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1071.ffi).mlx.items.get k = some v → PN (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1071.ffi).mlx k) (tracedC : ∀ h o, (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1071.ffi).mlx.objs.get h = some o → ∀ i ∈ objTraces o, i < PRE_first_tail_x15_r0_body.P121.NL) (cl : SSt (· < 5252) PRE_first_tail_x15_r0_body.cx0_121.mlx)
    (hobjC : ∀ h, PRE_first_tail_x15_r0_body.fxC_121.get h = some () → ((Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1071.ffi).mlx.objs.get h).isSome = true)
    (hfC : ∀ h, (PRE_first_tail_x15_r0_body.krC_121.flags.get h).isSome = true → ((Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1071.ffi).mlx.objs.get h).isSome = true)
    (htC : ∀ h, (PRE_first_tail_x15_r0_body.krC_121.targs.get h).isSome = true → ((Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1071.ffi).mlx.objs.get h).isSome = true)
    (hclC : ∀ h l, PRE_first_tail_x15_r0_body.krC_121.targs.get h = some l → Host.Ts.Sim.Full.STargs (· < (⟨20592, 17688, 2770119, 5252⟩ : Conv.Cnt).n) l) :
    Conv.FullShiftQ PRE_first_tail_x15_r0_body.P121 5252 PRE_first_tail_x15_r0_body.kappa121 PRE_first_tail_x15_r0_body.s1073.ffi PRE_first_tail_x15_r0_body.s1072.ffi :=
  ⟨PRE_first_tail_x15_r0_body.cnshift121 clean hltC nltC itemsC tracedC cl, PRE_first_tail_x15_r0_body.cqueue121, fun t ht => bSN_sound (List.all_eq_true.mp PRE_first_tail_x15_r0_body.ctokSupp121 t ht),
    PRE_first_tail_x15_r0_body.cbridge121,
    liveShift_foot (x0' := Host.Ts.Sim.Full.mlxOf PRE_first_tail_x15_r0_body.s1073.ffi) (x1' := Host.Ts.Sim.Full.mlxOf PRE_first_tail_x15_r0_body.s1072.ffi) (PRE_first_tail_x15_r0_body.cfoot121 clean hltC nltC itemsC tracedC cl) rfl PRE_first_tail_x15_r0_body.ofx0_121 PRE_first_tail_x15_r0_body.ofx1_121 hobjC PRE_first_tail_x15_r0_body.ff0121 PRE_first_tail_x15_r0_body.ff1121 PRE_first_tail_x15_r0_body.ffck121,
    kernShift_foot (x0' := Host.Ts.Sim.Full.mlxOf PRE_first_tail_x15_r0_body.s1073.ffi) (x1' := Host.Ts.Sim.Full.mlxOf PRE_first_tail_x15_r0_body.s1072.ffi) (PRE_first_tail_x15_r0_body.cfoot121 clean hltC nltC itemsC tracedC cl) rfl PRE_first_tail_x15_r0_body.okr0_121 PRE_first_tail_x15_r0_body.okr1_121 (Nat.le_of_ble_eq_true PRE_first_tail_x15_r0_body.fkn121) hfC htC hclC
      PRE_first_tail_x15_r0_body.fkf0121 PRE_first_tail_x15_r0_body.fkt0121 PRE_first_tail_x15_r0_body.fkf1121 PRE_first_tail_x15_r0_body.fkt1121 PRE_first_tail_x15_r0_body.fkck121,
    pendReg_of rfl PRE_first_tail_x15_r0_body.cnh0121 PRE_first_tail_x15_r0_body.cnh1121 (Nat.le_of_ble_eq_true PRE_first_tail_x15_r0_body.cpendLe121) PRE_first_tail_x15_r0_body.cpendR121⟩

end Host.Load.Run.Tpl
