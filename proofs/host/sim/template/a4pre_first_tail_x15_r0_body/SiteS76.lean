import host.sim.template.a4pre_first_tail_x15_r0_body.SiteCl76
import host.sim.conv.CompactFull
import host.sim.template.FootGen
set_option Elab.async false
namespace Host.Load.Run.Tpl
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
open Host.Ts Host.Ts.Sim Host.Ts.Sim.Template

/-! The compaction's native shift at call site 76 from its footprint (`Conv.nshift_of_foot`), and the observers'
(`liveShift_foot`, `kernShift_foot`): `Conv.FullShiftQ` for `Conv.full_compactQ`, given the call's bookkeeping and its
relation's facts. -/

/-- The load parameters of the chain (band-free: its start's node counter as `NL` and `N0`). -/
def PRE_first_tail_x15_r0_body.Pc76 : LoadP := ⟨18151, 131072, 1099511627776, 15235, 15235, []⟩
/-- The site's band raised to the map's checked fixed-node prefix, including newly recorded closure traces. -/
def PRE_first_tail_x15_r0_body.P76 : LoadP := PRE_first_tail_x15_r0_body.Pc76.raise 16803
kernel_rfl PRE_first_tail_x15_r0_body.craise76 : Nat.ble PRE_first_tail_x15_r0_body.Pc76.N0 16803 = true
theorem PRE_first_tail_x15_r0_body.raised76 : Host.Ts.Sim.Full.Raised PRE_first_tail_x15_r0_body.Pc76 PRE_first_tail_x15_r0_body.P76 :=
  .inr ⟨16803, rfl, Nat.le_of_ble_eq_true PRE_first_tail_x15_r0_body.craise76, rfl⟩
noncomputable abbrev PRE_first_tail_x15_r0_body.cx0_76 : Host.Load.LSt := clearTokens (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s680.ffi)
noncomputable abbrev PRE_first_tail_x15_r0_body.cx1_76 : Host.Load.LSt := clearTokens (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s679.ffi)
def PRE_first_tail_x15_r0_body.khinv76 : PTrie Nat := Stage.setAll PTrie.nil []
def PRE_first_tail_x15_r0_body.kninv76 : PTrie Nat := Stage.setAll PTrie.nil []
/-- The stage's footprint: its written and fresh handles, fresh nodes, written and fresh items. -/
def PRE_first_tail_x15_r0_body.cwS76 : List Nat := []
def PRE_first_tail_x15_r0_body.cnS76 : List Nat := List.range' 16803 0
def PRE_first_tail_x15_r0_body.ciS76 : List Nat := [] ++ List.range' 16803 0

-- the small checks (`MChecks`'s)
kernel_rfl PRE_first_tail_x15_r0_body.cnh076 : PRE_first_tail_x15_r0_body.kd76.nh0 = PRE_first_tail_x15_r0_body.cx0_76.mlx.next
kernel_rfl PRE_first_tail_x15_r0_body.cnh176 : PRE_first_tail_x15_r0_body.kd76.nh1 = PRE_first_tail_x15_r0_body.cx1_76.mlx.next
kernel_rfl PRE_first_tail_x15_r0_body.cnn076 : PRE_first_tail_x15_r0_body.kd76.nn0 = PRE_first_tail_x15_r0_body.cx0_76.mlx.nnext
kernel_rfl PRE_first_tail_x15_r0_body.cnn176 : PRE_first_tail_x15_r0_body.kd76.nn1 = PRE_first_tail_x15_r0_body.cx1_76.mlx.nnext
kernel_rfl PRE_first_tail_x15_r0_body.cplo76 : (Nat.blt 0 PRE_first_tail_x15_r0_body.P76.lo && Nat.ble PRE_first_tail_x15_r0_body.P76.lo PRE_first_tail_x15_r0_body.cx0_76.mlx.next && Nat.ble PRE_first_tail_x15_r0_body.P76.lo RData.bigHi && Nat.ble RData.bigHi PRE_first_tail_x15_r0_body.P76.E) = true
kernel_rfl PRE_first_tail_x15_r0_body.ccnt76 : (Nat.ble PRE_first_tail_x15_r0_body.cx0_76.mlx.next PRE_first_tail_x15_r0_body.cx1_76.mlx.next && Nat.ble PRE_first_tail_x15_r0_body.cx0_76.mlx.nnext PRE_first_tail_x15_r0_body.cx1_76.mlx.nnext) = true
kernel_rfl PRE_first_tail_x15_r0_body.cnband76 : (Nat.blt 0 PRE_first_tail_x15_r0_body.P76.NL && Nat.ble PRE_first_tail_x15_r0_body.P76.NL PRE_first_tail_x15_r0_body.P76.N0 && Nat.ble PRE_first_tail_x15_r0_body.P76.N0 PRE_first_tail_x15_r0_body.cx0_76.mlx.nnext) = true
kernel_rfl PRE_first_tail_x15_r0_body.chbelow76 : PRE_first_tail_x15_r0_body.kd76.checkHndBelow = true
kernel_rfl PRE_first_tail_x15_r0_body.chren76 : checkRenG PRE_first_tail_x15_r0_body.kd76.hnd PRE_first_tail_x15_r0_body.khinv76 (phB PRE_first_tail_x15_r0_body.cx0_76.mlx) = true
kernel_rfl PRE_first_tail_x15_r0_body.cband76 : PRE_first_tail_x15_r0_body.kd76.checkBand PRE_first_tail_x15_r0_body.P76.lo = true
kernel_rfl PRE_first_tail_x15_r0_body.cnh1pos76 : Nat.blt 0 PRE_first_tail_x15_r0_body.kd76.nh1 = true
kernel_rfl PRE_first_tail_x15_r0_body.cnren76 : checkRenG PRE_first_tail_x15_r0_body.kd76.node PRE_first_tail_x15_r0_body.kninv76 (pnB PRE_first_tail_x15_r0_body.cx0_76.mlx) = true
kernel_rfl PRE_first_tail_x15_r0_body.cnlow76 : (PTrie.keysA PRE_first_tail_x15_r0_body.kd76.node).all (fun j => Nat.ble PRE_first_tail_x15_r0_body.P76.NL j && Nat.blt (PRE_first_tail_x15_r0_body.kd76.nodeF j) PRE_first_tail_x15_r0_body.cx1_76.mlx.nnext) = true
kernel_rfl PRE_first_tail_x15_r0_body.cabs0a76 : PRE_first_tail_x15_r0_body.cx0_76.mlx.arrs.get 0 = none
kernel_rfl PRE_first_tail_x15_r0_body.cabs0b76 : PRE_first_tail_x15_r0_body.cx0_76.mlx.objs.get 0 = none
kernel_rfl PRE_first_tail_x15_r0_body.ctok176 : PRE_first_tail_x15_r0_body.cx1_76.mlx.tokens = []
kernel_rfl PRE_first_tail_x15_r0_body.cpend76 : PRE_first_tail_x15_r0_body.cx1_76.mlx.pending = PRE_first_tail_x15_r0_body.cx0_76.mlx.pending.map PRE_first_tail_x15_r0_body.kappa76.pend
kernel_rfl PRE_first_tail_x15_r0_body.cerrh76 : PRE_first_tail_x15_r0_body.cx1_76.mlx.errh = PRE_first_tail_x15_r0_body.cx0_76.mlx.errh.map PRE_first_tail_x15_r0_body.kappa76.arg
kernel_rfl PRE_first_tail_x15_r0_body.cfiles76 : PRE_first_tail_x15_r0_body.cx1_76.mlx.files = PRE_first_tail_x15_r0_body.cx0_76.mlx.files
kernel_rfl PRE_first_tail_x15_r0_body.carch76 : PRE_first_tail_x15_r0_body.cx1_76.mlx.arch = PRE_first_tail_x15_r0_body.cx0_76.mlx.arch
kernel_rfl PRE_first_tail_x15_r0_body.csizes76 : PRE_first_tail_x15_r0_body.cx1_76.mlx.deviceSizes = PRE_first_tail_x15_r0_body.cx0_76.mlx.deviceSizes
kernel_rfl PRE_first_tail_x15_r0_body.cwired76 : PRE_first_tail_x15_r0_body.cx1_76.mlx.wired = PRE_first_tail_x15_r0_body.cx0_76.mlx.wired
kernel_rfl PRE_first_tail_x15_r0_body.chost76 : PRE_first_tail_x15_r0_body.cx1_76.host = PRE_first_tail_x15_r0_body.cx0_76.host
-- the compaction map's addresses are `PRE_first_tail_x15_r0_body.kd76`'s
kernel_rfl PRE_first_tail_x15_r0_body.ckn076 : PRE_first_tail_x15_r0_body.kd76.n0 = 2734711
kernel_rfl PRE_first_tail_x15_r0_body.ckn176 : PRE_first_tail_x15_r0_body.kd76.n1 = 2734713
kernel_rfl PRE_first_tail_x15_r0_body.ckheap76 : (PTrie.keysA PRE_first_tail_x15_r0_body.kd76.heap).all (fun x => Nat.ble 2734711 x) = true
kernel_rfl PRE_first_tail_x15_r0_body.ckpl76 : (List.range 0).all (fun j => decide (PRE_first_tail_x15_r0_body.kd76.heap.get (2734711 + j) = nth? PRE_first_tail_x15_r0_body.pl76 j)) = true
-- the map fixes the call's names (`Conv.fixOld_compact`), the call's counters
kernel_rfl PRE_first_tail_x15_r0_body.fja76 : Nat.ble 2734711 2734711 = true
kernel_rfl PRE_first_tail_x15_r0_body.fn76 : Nat.ble 3329 3329 = true
kernel_rfl PRE_first_tail_x15_r0_body.fjaD76 : Nat.ble 2734711 PRE_first_tail_x15_r0_body.kd76.n0 = true
kernel_rfl PRE_first_tail_x15_r0_body.fxn76 : Nat.ble 19705 PRE_first_tail_x15_r0_body.kd76.nh0 = true
kernel_rfl PRE_first_tail_x15_r0_body.fnn76 : Nat.ble 16803 PRE_first_tail_x15_r0_body.kd76.nn0 = true
kernel_rfl PRE_first_tail_x15_r0_body.fxb76 : Nat.ble 19705 RData.bigHi = true
kernel_rfl PRE_first_tail_x15_r0_body.fheap76 : (PTrie.keysA PRE_first_tail_x15_r0_body.kd76.heap).all (Nat.ble (⟨19705, 16803, 2734711, 3329⟩ : Conv.Cnt).ja) = true
kernel_rfl PRE_first_tail_x15_r0_body.fhnd76 : (PTrie.keysA PRE_first_tail_x15_r0_body.kd76.hnd).all (Nat.ble (⟨19705, 16803, 2734711, 3329⟩ : Conv.Cnt).xn) = true
kernel_rfl PRE_first_tail_x15_r0_body.fnode76 : (PTrie.keysA PRE_first_tail_x15_r0_body.kd76.node).all (Nat.ble (⟨19705, 16803, 2734711, 3329⟩ : Conv.Cnt).nn) = true
/-- The compaction map fixes the call's names. -/
theorem PRE_first_tail_x15_r0_body.cfix76 : Conv.FixOld (⟨19705, 16803, 2734711, 3329⟩ : Conv.Cnt) PRE_first_tail_x15_r0_body.kappa76 :=
  Conv.fixOld_compact (Nat.le_of_ble_eq_true PRE_first_tail_x15_r0_body.fja76) (Nat.le_of_ble_eq_true PRE_first_tail_x15_r0_body.fn76) (Nat.le_of_ble_eq_true PRE_first_tail_x15_r0_body.fjaD76) (Nat.le_of_ble_eq_true PRE_first_tail_x15_r0_body.fxn76) (Nat.le_of_ble_eq_true PRE_first_tail_x15_r0_body.fnn76) (Nat.le_of_ble_eq_true PRE_first_tail_x15_r0_body.fxb76) PRE_first_tail_x15_r0_body.fheap76 PRE_first_tail_x15_r0_body.fhnd76 PRE_first_tail_x15_r0_body.fnode76
kernel_rfl PRE_first_tail_x15_r0_body.fcxn76 : (⟨19705, 16803, 2734711, 3329⟩ : Conv.Cnt).xn = (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s678.ffi).mlx.next
kernel_rfl PRE_first_tail_x15_r0_body.fcnn76 : (⟨19705, 16803, 2734711, 3329⟩ : Conv.Cnt).nn = (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s678.ffi).mlx.nnext
kernel_rfl PRE_first_tail_x15_r0_body.fle076 : (Nat.ble (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s678.ffi).mlx.next PRE_first_tail_x15_r0_body.cx0_76.mlx.next && Nat.ble (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s678.ffi).mlx.nnext PRE_first_tail_x15_r0_body.cx0_76.mlx.nnext && Nat.ble (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s678.ffi).mlx.next RData.bigHi) = true
kernel_rfl PRE_first_tail_x15_r0_body.fnk76 : (PTrie.keysA PRE_first_tail_x15_r0_body.kd76.node).all (Nat.ble (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s678.ffi).mlx.nnext) = true
-- the merged state keeps the call's entries off the stage's footprint
kernel_rfl PRE_first_tail_x15_r0_body.f1A76 : PRE_first_tail_x15_r0_body.cx1_76.mlx.arrs = Stage.setAll (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s678.ffi).mlx.arrs (PRE_first_tail_x15_r0_body.cwS76.filterMap fun i => (PRE_first_tail_x15_r0_body.cx1_76.mlx.arrs.get i).map (i, ·))
kernel_rfl PRE_first_tail_x15_r0_body.f1O76 : PRE_first_tail_x15_r0_body.cx1_76.mlx.objs = Stage.setAll (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s678.ffi).mlx.objs (PRE_first_tail_x15_r0_body.cwS76.filterMap fun i => (PRE_first_tail_x15_r0_body.cx1_76.mlx.objs.get i).map (i, ·))
kernel_rfl PRE_first_tail_x15_r0_body.f1N76 : PRE_first_tail_x15_r0_body.cx1_76.mlx.nodes = Stage.setAll (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s678.ffi).mlx.nodes (PRE_first_tail_x15_r0_body.cnS76.filterMap fun i => (PRE_first_tail_x15_r0_body.cx1_76.mlx.nodes.get i).map (i, ·))
kernel_rfl PRE_first_tail_x15_r0_body.f1I76 : PRE_first_tail_x15_r0_body.cx1_76.mlx.items = Stage.setAll (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s678.ffi).mlx.items (PRE_first_tail_x15_r0_body.ciS76.filterMap fun i => (PRE_first_tail_x15_r0_body.cx1_76.mlx.items.get i).map (i, ·))
kernel_rfl PRE_first_tail_x15_r0_body.fbd76 : (PRE_first_tail_x15_r0_body.clo76 ++ PRE_first_tail_x15_r0_body.cln76 ++ PRE_first_tail_x15_r0_body.cli76 ++ PRE_first_tail_x15_r0_body.cwS76 ++ PRE_first_tail_x15_r0_body.cnS76 ++ PRE_first_tail_x15_r0_body.ciS76).all (fun i => Nat.blt (i / 4096) (4 ^ 31)) = true
kernel_rfl PRE_first_tail_x15_r0_body.fincW76 : PRE_first_tail_x15_r0_body.cwS76.all (fun h => !Nat.blt h (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s678.ffi).mlx.next || PRE_first_tail_x15_r0_body.clo76.contains h) = true
kernel_rfl PRE_first_tail_x15_r0_body.fincI76 : PRE_first_tail_x15_r0_body.ciS76.all (fun k => !Nat.blt k (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s678.ffi).mlx.nnext || PRE_first_tail_x15_r0_body.cli76.contains k) = true
kernel_rfl PRE_first_tail_x15_r0_body.fincN76 : PRE_first_tail_x15_r0_body.cnS76.all (Nat.ble (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s678.ffi).mlx.nnext) = true
kernel_rfl PRE_first_tail_x15_r0_body.flnF76 : PRE_first_tail_x15_r0_body.cln76.all (Nat.ble (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s678.ffi).mlx.nnext) = true
-- the checks over the changed lists
kernel_rfl PRE_first_tail_x15_r0_body.fh76 : PRE_first_tail_x15_r0_body.clo76.all (handleOK PRE_first_tail_x15_r0_body.kappa76 PRE_first_tail_x15_r0_body.P76.lo PRE_first_tail_x15_r0_body.cx0_76.mlx PRE_first_tail_x15_r0_body.cx1_76.mlx) = true
kernel_rfl PRE_first_tail_x15_r0_body.fo76 : PRE_first_tail_x15_r0_body.clo76.map (fun h => PRE_first_tail_x15_r0_body.cx1_76.mlx.objs.get (PRE_first_tail_x15_r0_body.kappa76.handle h)) = PRE_first_tail_x15_r0_body.clo76.map (fun h => (PRE_first_tail_x15_r0_body.cx0_76.mlx.objs.get h).map PRE_first_tail_x15_r0_body.kappa76.nobj)
kernel_rfl PRE_first_tail_x15_r0_body.fok76 : PRE_first_tail_x15_r0_body.clo76.all (objOK PRE_first_tail_x15_r0_body.kappa76 PRE_first_tail_x15_r0_body.P76.NL PRE_first_tail_x15_r0_body.cx0_76.mlx) = true
kernel_rfl PRE_first_tail_x15_r0_body.fnd76 : PRE_first_tail_x15_r0_body.cln76.all (nodeOKF PRE_first_tail_x15_r0_body.kappa76 PRE_first_tail_x15_r0_body.P76 PRE_first_tail_x15_r0_body.cx0_76.mlx PRE_first_tail_x15_r0_body.cx1_76.mlx) = true
kernel_rfl PRE_first_tail_x15_r0_body.fp76 : ((PRE_first_tail_x15_r0_body.cln76.filter (fullB PRE_first_tail_x15_r0_body.P76))).map (fun i => (PRE_first_tail_x15_r0_body.cx1_76.mlx.nodes.get (PRE_first_tail_x15_r0_body.kappa76.node i)).map Host.Mlx.Ffi.Node.prim) =
  ((PRE_first_tail_x15_r0_body.cln76.filter (fullB PRE_first_tail_x15_r0_body.P76))).map (fun i => (PRE_first_tail_x15_r0_body.cx0_76.mlx.nodes.get i).map fun nd => PRE_first_tail_x15_r0_body.kappa76.prim nd.prim)
kernel_rfl PRE_first_tail_x15_r0_body.fnordI76 : incrB PRE_first_tail_x15_r0_body.kd76.nodeF (List.range' 16803 0) = true
kernel_rfl PRE_first_tail_x15_r0_body.fnordK76 : (PTrie.keysA PRE_first_tail_x15_r0_body.kd76.node).all (fun k => Nat.ble 16803 k && Nat.blt k 16803) = true
kernel_rfl PRE_first_tail_x15_r0_body.fnordL76 : (PRE_first_tail_x15_r0_body.cln76.filter (Nat.ble PRE_first_tail_x15_r0_body.P76.N0)).all (fun i => Nat.ble i (PRE_first_tail_x15_r0_body.kd76.nodeF i) && (Nat.blt i 16803 || Nat.ble PRE_first_tail_x15_r0_body.kd76.nn0 i)) = true
theorem PRE_first_tail_x15_r0_body.fnord76 : (PRE_first_tail_x15_r0_body.cln76.filter (Nat.ble PRE_first_tail_x15_r0_body.P76.N0)).all (fun i => Nat.ble i (PRE_first_tail_x15_r0_body.kd76.nodeF i) &&
    (PTrie.keysA PRE_first_tail_x15_r0_body.kd76.node).all fun j => !Nat.blt j i || Nat.blt (PRE_first_tail_x15_r0_body.kd76.nodeF j) (PRE_first_tail_x15_r0_body.kd76.nodeF i)) = true :=
  cnord_of PRE_first_tail_x15_r0_body.cnlow76 PRE_first_tail_x15_r0_body.cnn176 PRE_first_tail_x15_r0_body.fnordI76 PRE_first_tail_x15_r0_body.fnordK76 PRE_first_tail_x15_r0_body.fnordL76
kernel_rfl PRE_first_tail_x15_r0_body.fi76 : PRE_first_tail_x15_r0_body.cli76.all (pnB PRE_first_tail_x15_r0_body.cx0_76.mlx) = true
kernel_rfl PRE_first_tail_x15_r0_body.fii76 : PRE_first_tail_x15_r0_body.cli76.all (fun k => decide (PRE_first_tail_x15_r0_body.cx1_76.mlx.items.get (PRE_first_tail_x15_r0_body.kappa76.node k) = (PRE_first_tail_x15_r0_body.cx0_76.mlx.items.get k).map PRE_first_tail_x15_r0_body.kappa76.nv)) = true
/-- **The compaction's footprint.** -/
theorem PRE_first_tail_x15_r0_body.cfoot76 (clean : Conv.NClean (⟨19705, 16803, 2734711, 3329⟩ : Conv.Cnt) (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s678.ffi).mlx) (hltC : ∀ h, PH (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s678.ffi).mlx h → h < (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s678.ffi).mlx.next) (nltC : ∀ i, PN (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s678.ffi).mlx i → i < (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s678.ffi).mlx.nnext) (itemsC : ∀ k v, (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s678.ffi).mlx.items.get k = some v → PN (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s678.ffi).mlx k) (tracedC : ∀ h o, (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s678.ffi).mlx.objs.get h = some o → ∀ i ∈ objTraces o, i < PRE_first_tail_x15_r0_body.P76.NL) (cl : SSt (· < 3329) PRE_first_tail_x15_r0_body.cx0_76.mlx) :
    Conv.MFoot PRE_first_tail_x15_r0_body.P76 3329 PRE_first_tail_x15_r0_body.kappa76 PRE_first_tail_x15_r0_body.kd76 PRE_first_tail_x15_r0_body.khinv76 PRE_first_tail_x15_r0_body.kninv76 (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s678.ffi).mlx PRE_first_tail_x15_r0_body.cx0_76.mlx PRE_first_tail_x15_r0_body.cx1_76.mlx (⟨19705, 16803, 2734711, 3329⟩ : Conv.Cnt) PRE_first_tail_x15_r0_body.clo76 PRE_first_tail_x15_r0_body.cln76 PRE_first_tail_x15_r0_body.cli76 PRE_first_tail_x15_r0_body.cwS76 PRE_first_tail_x15_r0_body.cnS76 PRE_first_tail_x15_r0_body.ciS76 :=
  ⟨rfl, rfl, rfl, PRE_first_tail_x15_r0_body.cnh076, PRE_first_tail_x15_r0_body.cnh176, PRE_first_tail_x15_r0_body.cnn076, PRE_first_tail_x15_r0_body.cnn176, PRE_first_tail_x15_r0_body.cplo76, PRE_first_tail_x15_r0_body.ccnt76, PRE_first_tail_x15_r0_body.cnband76, PRE_first_tail_x15_r0_body.chbelow76, PRE_first_tail_x15_r0_body.chren76, PRE_first_tail_x15_r0_body.cband76, PRE_first_tail_x15_r0_body.cnh1pos76, PRE_first_tail_x15_r0_body.cnren76, PRE_first_tail_x15_r0_body.cnlow76, PRE_first_tail_x15_r0_body.cabs0a76, PRE_first_tail_x15_r0_body.cabs0b76, PRE_first_tail_x15_r0_body.ctok176, PRE_first_tail_x15_r0_body.cpend76, PRE_first_tail_x15_r0_body.cerrh76, PRE_first_tail_x15_r0_body.cfiles76, PRE_first_tail_x15_r0_body.carch76, PRE_first_tail_x15_r0_body.csizes76, PRE_first_tail_x15_r0_body.cwired76, PRE_first_tail_x15_r0_body.cfix76, clean, PRE_first_tail_x15_r0_body.fcxn76, PRE_first_tail_x15_r0_body.fcnn76, hltC, nltC, itemsC, tracedC, cl, PRE_first_tail_x15_r0_body.fle076, PRE_first_tail_x15_r0_body.fnk76, PRE_first_tail_x15_r0_body.ckA76, PRE_first_tail_x15_r0_body.cobjsK76, PRE_first_tail_x15_r0_body.cnodesK76, PRE_first_tail_x15_r0_body.citemsK76, PRE_first_tail_x15_r0_body.f1A76, PRE_first_tail_x15_r0_body.f1O76, PRE_first_tail_x15_r0_body.f1N76, PRE_first_tail_x15_r0_body.f1I76, PRE_first_tail_x15_r0_body.fbd76, PRE_first_tail_x15_r0_body.fincW76, PRE_first_tail_x15_r0_body.fincI76, PRE_first_tail_x15_r0_body.fincN76, PRE_first_tail_x15_r0_body.flnF76, PRE_first_tail_x15_r0_body.fh76, PRE_first_tail_x15_r0_body.fo76, PRE_first_tail_x15_r0_body.fok76, PRE_first_tail_x15_r0_body.fnd76, PRE_first_tail_x15_r0_body.fp76, PRE_first_tail_x15_r0_body.fnord76, PRE_first_tail_x15_r0_body.fi76, PRE_first_tail_x15_r0_body.fii76⟩
theorem PRE_first_tail_x15_r0_body.cnshift76 (clean : Conv.NClean (⟨19705, 16803, 2734711, 3329⟩ : Conv.Cnt) (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s678.ffi).mlx) (hltC : ∀ h, PH (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s678.ffi).mlx h → h < (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s678.ffi).mlx.next) (nltC : ∀ i, PN (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s678.ffi).mlx i → i < (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s678.ffi).mlx.nnext) (itemsC : ∀ k v, (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s678.ffi).mlx.items.get k = some v → PN (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s678.ffi).mlx k) (tracedC : ∀ h o, (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s678.ffi).mlx.objs.get h = some o → ∀ i ∈ objTraces o, i < PRE_first_tail_x15_r0_body.P76.NL) (cl : SSt (· < 3329) PRE_first_tail_x15_r0_body.cx0_76.mlx) : NShift PRE_first_tail_x15_r0_body.P76 3329 PRE_first_tail_x15_r0_body.kappa76 PRE_first_tail_x15_r0_body.cx0_76 PRE_first_tail_x15_r0_body.cx1_76 :=
  Conv.nshift_of_foot (PRE_first_tail_x15_r0_body.cfoot76 clean hltC nltC itemsC tracedC cl) PRE_first_tail_x15_r0_body.chost76 (compact_a_eq PRE_first_tail_x15_r0_body.ckn076 PRE_first_tail_x15_r0_body.ckn176 PRE_first_tail_x15_r0_body.ckheap76 PRE_first_tail_x15_r0_body.ckpl76)

-- the observers: the layers' states at the call, the canonical and the merged state, their footprints and checks
noncomputable def PRE_first_tail_x15_r0_body.fxC_76 : PTrie Unit := (Host.Ts.Sim.Full.freedOf PRE_first_tail_x15_r0_body.s678.ffi).getD PTrie.nil
noncomputable def PRE_first_tail_x15_r0_body.krC_76 : Host.Load.Layers.KRec := (Host.Ts.Sim.Full.krecOf PRE_first_tail_x15_r0_body.s678.ffi).getD Host.Load.Layers.KRec.empty
kernel_rfl PRE_first_tail_x15_r0_body.ofxC_76 : (Host.Ts.Sim.Full.freedOf PRE_first_tail_x15_r0_body.s678.ffi) = some PRE_first_tail_x15_r0_body.fxC_76
kernel_rfl PRE_first_tail_x15_r0_body.okrC_76 : (Host.Ts.Sim.Full.krecOf PRE_first_tail_x15_r0_body.s678.ffi) = some PRE_first_tail_x15_r0_body.krC_76
noncomputable def PRE_first_tail_x15_r0_body.fx0_76 : PTrie Unit := (Host.Ts.Sim.Full.freedOf PRE_first_tail_x15_r0_body.s680.ffi).getD PTrie.nil
noncomputable def PRE_first_tail_x15_r0_body.kr0_76 : Host.Load.Layers.KRec := (Host.Ts.Sim.Full.krecOf PRE_first_tail_x15_r0_body.s680.ffi).getD Host.Load.Layers.KRec.empty
kernel_rfl PRE_first_tail_x15_r0_body.ofx0_76 : (Host.Ts.Sim.Full.freedOf PRE_first_tail_x15_r0_body.s680.ffi) = some PRE_first_tail_x15_r0_body.fx0_76
kernel_rfl PRE_first_tail_x15_r0_body.okr0_76 : (Host.Ts.Sim.Full.krecOf PRE_first_tail_x15_r0_body.s680.ffi) = some PRE_first_tail_x15_r0_body.kr0_76
noncomputable def PRE_first_tail_x15_r0_body.fx1_76 : PTrie Unit := (Host.Ts.Sim.Full.freedOf PRE_first_tail_x15_r0_body.s679.ffi).getD PTrie.nil
noncomputable def PRE_first_tail_x15_r0_body.kr1_76 : Host.Load.Layers.KRec := (Host.Ts.Sim.Full.krecOf PRE_first_tail_x15_r0_body.s679.ffi).getD Host.Load.Layers.KRec.empty
kernel_rfl PRE_first_tail_x15_r0_body.ofx1_76 : (Host.Ts.Sim.Full.freedOf PRE_first_tail_x15_r0_body.s679.ffi) = some PRE_first_tail_x15_r0_body.fx1_76
kernel_rfl PRE_first_tail_x15_r0_body.okr1_76 : (Host.Ts.Sim.Full.krecOf PRE_first_tail_x15_r0_body.s679.ffi) = some PRE_first_tail_x15_r0_body.kr1_76
kernel_rfl PRE_first_tail_x15_r0_body.ff076 : PRE_first_tail_x15_r0_body.fx0_76 = Stage.setAll PRE_first_tail_x15_r0_body.fxC_76 (PRE_first_tail_x15_r0_body.clo76.filterMap fun i => (PRE_first_tail_x15_r0_body.fx0_76.get i).map (i, ·))
kernel_rfl PRE_first_tail_x15_r0_body.ff176 : PRE_first_tail_x15_r0_body.fx1_76 = Stage.setAll PRE_first_tail_x15_r0_body.fxC_76 (PRE_first_tail_x15_r0_body.cwS76.filterMap fun i => (PRE_first_tail_x15_r0_body.fx1_76.get i).map (i, ·))
kernel_rfl PRE_first_tail_x15_r0_body.ffck76 : freedLB PRE_first_tail_x15_r0_body.kappa76 PRE_first_tail_x15_r0_body.cx0_76.mlx PRE_first_tail_x15_r0_body.fx0_76 PRE_first_tail_x15_r0_body.fx1_76 PRE_first_tail_x15_r0_body.clo76 = true
kernel_rfl PRE_first_tail_x15_r0_body.fkf076 : PRE_first_tail_x15_r0_body.kr0_76.flags = Stage.setAll PRE_first_tail_x15_r0_body.krC_76.flags (PRE_first_tail_x15_r0_body.clo76.filterMap fun i => (PRE_first_tail_x15_r0_body.kr0_76.flags.get i).map (i, ·))
kernel_rfl PRE_first_tail_x15_r0_body.fkt076 : PRE_first_tail_x15_r0_body.kr0_76.targs = Stage.setAll PRE_first_tail_x15_r0_body.krC_76.targs (PRE_first_tail_x15_r0_body.clo76.filterMap fun i => (PRE_first_tail_x15_r0_body.kr0_76.targs.get i).map (i, ·))
kernel_rfl PRE_first_tail_x15_r0_body.fkf176 : PRE_first_tail_x15_r0_body.kr1_76.flags = Stage.setAll PRE_first_tail_x15_r0_body.krC_76.flags (PRE_first_tail_x15_r0_body.cwS76.filterMap fun i => (PRE_first_tail_x15_r0_body.kr1_76.flags.get i).map (i, ·))
kernel_rfl PRE_first_tail_x15_r0_body.fkt176 : PRE_first_tail_x15_r0_body.kr1_76.targs = Stage.setAll PRE_first_tail_x15_r0_body.krC_76.targs (PRE_first_tail_x15_r0_body.cwS76.filterMap fun i => (PRE_first_tail_x15_r0_body.kr1_76.targs.get i).map (i, ·))
kernel_rfl PRE_first_tail_x15_r0_body.fkck76 : krecLB PRE_first_tail_x15_r0_body.kappa76 3329 PRE_first_tail_x15_r0_body.cx0_76.mlx PRE_first_tail_x15_r0_body.kr0_76 PRE_first_tail_x15_r0_body.kr1_76 PRE_first_tail_x15_r0_body.clo76 = true
kernel_rfl PRE_first_tail_x15_r0_body.fkn76 : Nat.ble 3329 3329 = true
-- the bridge and the pending traces' regions
kernel_rfl PRE_first_tail_x15_r0_body.cbridge76 : Host.Ts.Sim.Full.bridgeOf PRE_first_tail_x15_r0_body.s679.ffi = Host.Ts.Sim.Full.bridgeOf PRE_first_tail_x15_r0_body.s680.ffi
kernel_rfl PRE_first_tail_x15_r0_body.cpendR76 : pendRegB PRE_first_tail_x15_r0_body.kappa76 (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s680.ffi).mlx = true
kernel_rfl PRE_first_tail_x15_r0_body.cpendLe76 : Nat.ble (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s680.ffi).mlx.next (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s679.ffi).mlx.next = true
/-- **The compaction's native shift**, given the call's bookkeeping, its relation's facts (the model's and the
observers') and the canonical closedness. -/
theorem PRE_first_tail_x15_r0_body.cshift76 (clean : Conv.NClean (⟨19705, 16803, 2734711, 3329⟩ : Conv.Cnt) (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s678.ffi).mlx) (hltC : ∀ h, PH (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s678.ffi).mlx h → h < (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s678.ffi).mlx.next) (nltC : ∀ i, PN (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s678.ffi).mlx i → i < (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s678.ffi).mlx.nnext) (itemsC : ∀ k v, (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s678.ffi).mlx.items.get k = some v → PN (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s678.ffi).mlx k) (tracedC : ∀ h o, (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s678.ffi).mlx.objs.get h = some o → ∀ i ∈ objTraces o, i < PRE_first_tail_x15_r0_body.P76.NL) (cl : SSt (· < 3329) PRE_first_tail_x15_r0_body.cx0_76.mlx)
    (hobjC : ∀ h, PRE_first_tail_x15_r0_body.fxC_76.get h = some () → ((Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s678.ffi).mlx.objs.get h).isSome = true)
    (hfC : ∀ h, (PRE_first_tail_x15_r0_body.krC_76.flags.get h).isSome = true → ((Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s678.ffi).mlx.objs.get h).isSome = true)
    (htC : ∀ h, (PRE_first_tail_x15_r0_body.krC_76.targs.get h).isSome = true → ((Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s678.ffi).mlx.objs.get h).isSome = true)
    (hclC : ∀ h l, PRE_first_tail_x15_r0_body.krC_76.targs.get h = some l → Host.Ts.Sim.Full.STargs (· < (⟨19705, 16803, 2734711, 3329⟩ : Conv.Cnt).n) l) :
    Conv.FullShiftQ PRE_first_tail_x15_r0_body.P76 3329 PRE_first_tail_x15_r0_body.kappa76 PRE_first_tail_x15_r0_body.s680.ffi PRE_first_tail_x15_r0_body.s679.ffi :=
  ⟨PRE_first_tail_x15_r0_body.cnshift76 clean hltC nltC itemsC tracedC cl, PRE_first_tail_x15_r0_body.cqueue76, fun t ht => bSN_sound (List.all_eq_true.mp PRE_first_tail_x15_r0_body.ctokSupp76 t ht),
    PRE_first_tail_x15_r0_body.cbridge76,
    liveShift_foot (x0' := Host.Ts.Sim.Full.mlxOf PRE_first_tail_x15_r0_body.s680.ffi) (x1' := Host.Ts.Sim.Full.mlxOf PRE_first_tail_x15_r0_body.s679.ffi) (PRE_first_tail_x15_r0_body.cfoot76 clean hltC nltC itemsC tracedC cl) rfl PRE_first_tail_x15_r0_body.ofx0_76 PRE_first_tail_x15_r0_body.ofx1_76 hobjC PRE_first_tail_x15_r0_body.ff076 PRE_first_tail_x15_r0_body.ff176 PRE_first_tail_x15_r0_body.ffck76,
    kernShift_foot (x0' := Host.Ts.Sim.Full.mlxOf PRE_first_tail_x15_r0_body.s680.ffi) (x1' := Host.Ts.Sim.Full.mlxOf PRE_first_tail_x15_r0_body.s679.ffi) (PRE_first_tail_x15_r0_body.cfoot76 clean hltC nltC itemsC tracedC cl) rfl PRE_first_tail_x15_r0_body.okr0_76 PRE_first_tail_x15_r0_body.okr1_76 (Nat.le_of_ble_eq_true PRE_first_tail_x15_r0_body.fkn76) hfC htC hclC
      PRE_first_tail_x15_r0_body.fkf076 PRE_first_tail_x15_r0_body.fkt076 PRE_first_tail_x15_r0_body.fkf176 PRE_first_tail_x15_r0_body.fkt176 PRE_first_tail_x15_r0_body.fkck76,
    pendReg_of rfl PRE_first_tail_x15_r0_body.cnh076 PRE_first_tail_x15_r0_body.cnh176 (Nat.le_of_ble_eq_true PRE_first_tail_x15_r0_body.cpendLe76) PRE_first_tail_x15_r0_body.cpendR76⟩

end Host.Load.Run.Tpl
