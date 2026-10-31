import host.sim.template.a4pre_first_tail_x15_r0_body.SiteCl118
import host.sim.conv.CompactFull
import host.sim.template.FootGen
set_option Elab.async false
namespace Host.Load.Run.Tpl
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
open Host.Ts Host.Ts.Sim Host.Ts.Sim.Template

/-! The compaction's native shift at call site 118 from its footprint (`Conv.nshift_of_foot`), and the observers'
(`liveShift_foot`, `kernShift_foot`): `Conv.FullShiftQ` for `Conv.full_compactQ`, given the call's bookkeeping and its
relation's facts. -/

/-- The load parameters of the chain (band-free: its start's node counter as `NL` and `N0`). -/
def PRE_first_tail_x15_r0_body.Pc118 : LoadP := ⟨18151, 131072, 1099511627776, 15235, 15235, []⟩
/-- The site's band raised to the map's checked fixed-node prefix, including newly recorded closure traces. -/
def PRE_first_tail_x15_r0_body.P118 : LoadP := PRE_first_tail_x15_r0_body.Pc118.raise 17625
kernel_rfl PRE_first_tail_x15_r0_body.craise118 : Nat.ble PRE_first_tail_x15_r0_body.Pc118.N0 17625 = true
theorem PRE_first_tail_x15_r0_body.raised118 : Host.Ts.Sim.Full.Raised PRE_first_tail_x15_r0_body.Pc118 PRE_first_tail_x15_r0_body.P118 :=
  .inr ⟨17625, rfl, Nat.le_of_ble_eq_true PRE_first_tail_x15_r0_body.craise118, rfl⟩
noncomputable abbrev PRE_first_tail_x15_r0_body.cx0_118 : Host.Load.LSt := clearTokens (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1147.ffi)
noncomputable abbrev PRE_first_tail_x15_r0_body.cx1_118 : Host.Load.LSt := clearTokens (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1146.ffi)
def PRE_first_tail_x15_r0_body.khinv118 : PTrie Nat := Stage.setAll PTrie.nil []
def PRE_first_tail_x15_r0_body.kninv118 : PTrie Nat := Stage.setAll PTrie.nil []
/-- The stage's footprint: its written and fresh handles, fresh nodes, written and fresh items. -/
def PRE_first_tail_x15_r0_body.cwS118 : List Nat := []
def PRE_first_tail_x15_r0_body.cnS118 : List Nat := List.range' 17625 0
def PRE_first_tail_x15_r0_body.ciS118 : List Nat := [] ++ List.range' 17625 0

-- the small checks (`MChecks`'s)
kernel_rfl PRE_first_tail_x15_r0_body.cnh0118 : PRE_first_tail_x15_r0_body.kd118.nh0 = PRE_first_tail_x15_r0_body.cx0_118.mlx.next
kernel_rfl PRE_first_tail_x15_r0_body.cnh1118 : PRE_first_tail_x15_r0_body.kd118.nh1 = PRE_first_tail_x15_r0_body.cx1_118.mlx.next
kernel_rfl PRE_first_tail_x15_r0_body.cnn0118 : PRE_first_tail_x15_r0_body.kd118.nn0 = PRE_first_tail_x15_r0_body.cx0_118.mlx.nnext
kernel_rfl PRE_first_tail_x15_r0_body.cnn1118 : PRE_first_tail_x15_r0_body.kd118.nn1 = PRE_first_tail_x15_r0_body.cx1_118.mlx.nnext
kernel_rfl PRE_first_tail_x15_r0_body.cplo118 : (Nat.blt 0 PRE_first_tail_x15_r0_body.P118.lo && Nat.ble PRE_first_tail_x15_r0_body.P118.lo PRE_first_tail_x15_r0_body.cx0_118.mlx.next && Nat.ble PRE_first_tail_x15_r0_body.P118.lo RData.bigHi && Nat.ble RData.bigHi PRE_first_tail_x15_r0_body.P118.E) = true
kernel_rfl PRE_first_tail_x15_r0_body.ccnt118 : (Nat.ble PRE_first_tail_x15_r0_body.cx0_118.mlx.next PRE_first_tail_x15_r0_body.cx1_118.mlx.next && Nat.ble PRE_first_tail_x15_r0_body.cx0_118.mlx.nnext PRE_first_tail_x15_r0_body.cx1_118.mlx.nnext) = true
kernel_rfl PRE_first_tail_x15_r0_body.cnband118 : (Nat.blt 0 PRE_first_tail_x15_r0_body.P118.NL && Nat.ble PRE_first_tail_x15_r0_body.P118.NL PRE_first_tail_x15_r0_body.P118.N0 && Nat.ble PRE_first_tail_x15_r0_body.P118.N0 PRE_first_tail_x15_r0_body.cx0_118.mlx.nnext) = true
kernel_rfl PRE_first_tail_x15_r0_body.chbelow118 : PRE_first_tail_x15_r0_body.kd118.checkHndBelow = true
kernel_rfl PRE_first_tail_x15_r0_body.chren118 : checkRenG PRE_first_tail_x15_r0_body.kd118.hnd PRE_first_tail_x15_r0_body.khinv118 (phB PRE_first_tail_x15_r0_body.cx0_118.mlx) = true
kernel_rfl PRE_first_tail_x15_r0_body.cband118 : PRE_first_tail_x15_r0_body.kd118.checkBand PRE_first_tail_x15_r0_body.P118.lo = true
kernel_rfl PRE_first_tail_x15_r0_body.cnh1pos118 : Nat.blt 0 PRE_first_tail_x15_r0_body.kd118.nh1 = true
kernel_rfl PRE_first_tail_x15_r0_body.cnren118 : checkRenG PRE_first_tail_x15_r0_body.kd118.node PRE_first_tail_x15_r0_body.kninv118 (pnB PRE_first_tail_x15_r0_body.cx0_118.mlx) = true
kernel_rfl PRE_first_tail_x15_r0_body.cnlow118 : (PTrie.keysA PRE_first_tail_x15_r0_body.kd118.node).all (fun j => Nat.ble PRE_first_tail_x15_r0_body.P118.NL j && Nat.blt (PRE_first_tail_x15_r0_body.kd118.nodeF j) PRE_first_tail_x15_r0_body.cx1_118.mlx.nnext) = true
kernel_rfl PRE_first_tail_x15_r0_body.cabs0a118 : PRE_first_tail_x15_r0_body.cx0_118.mlx.arrs.get 0 = none
kernel_rfl PRE_first_tail_x15_r0_body.cabs0b118 : PRE_first_tail_x15_r0_body.cx0_118.mlx.objs.get 0 = none
kernel_rfl PRE_first_tail_x15_r0_body.ctok1118 : PRE_first_tail_x15_r0_body.cx1_118.mlx.tokens = []
kernel_rfl PRE_first_tail_x15_r0_body.cpend118 : PRE_first_tail_x15_r0_body.cx1_118.mlx.pending = PRE_first_tail_x15_r0_body.cx0_118.mlx.pending.map PRE_first_tail_x15_r0_body.kappa118.pend
kernel_rfl PRE_first_tail_x15_r0_body.cerrh118 : PRE_first_tail_x15_r0_body.cx1_118.mlx.errh = PRE_first_tail_x15_r0_body.cx0_118.mlx.errh.map PRE_first_tail_x15_r0_body.kappa118.arg
kernel_rfl PRE_first_tail_x15_r0_body.cfiles118 : PRE_first_tail_x15_r0_body.cx1_118.mlx.files = PRE_first_tail_x15_r0_body.cx0_118.mlx.files
kernel_rfl PRE_first_tail_x15_r0_body.carch118 : PRE_first_tail_x15_r0_body.cx1_118.mlx.arch = PRE_first_tail_x15_r0_body.cx0_118.mlx.arch
kernel_rfl PRE_first_tail_x15_r0_body.csizes118 : PRE_first_tail_x15_r0_body.cx1_118.mlx.deviceSizes = PRE_first_tail_x15_r0_body.cx0_118.mlx.deviceSizes
kernel_rfl PRE_first_tail_x15_r0_body.cwired118 : PRE_first_tail_x15_r0_body.cx1_118.mlx.wired = PRE_first_tail_x15_r0_body.cx0_118.mlx.wired
kernel_rfl PRE_first_tail_x15_r0_body.chost118 : PRE_first_tail_x15_r0_body.cx1_118.host = PRE_first_tail_x15_r0_body.cx0_118.host
-- the compaction map's addresses are `PRE_first_tail_x15_r0_body.kd118`'s
kernel_rfl PRE_first_tail_x15_r0_body.ckn0118 : PRE_first_tail_x15_r0_body.kd118.n0 = 2767841
kernel_rfl PRE_first_tail_x15_r0_body.ckn1118 : PRE_first_tail_x15_r0_body.kd118.n1 = 2767843
kernel_rfl PRE_first_tail_x15_r0_body.ckheap118 : (PTrie.keysA PRE_first_tail_x15_r0_body.kd118.heap).all (fun x => Nat.ble 2767841 x) = true
kernel_rfl PRE_first_tail_x15_r0_body.ckpl118 : (List.range 0).all (fun j => decide (PRE_first_tail_x15_r0_body.kd118.heap.get (2767841 + j) = nth? PRE_first_tail_x15_r0_body.pl118 j)) = true
-- the map fixes the call's names (`Conv.fixOld_compact`), the call's counters
kernel_rfl PRE_first_tail_x15_r0_body.fja118 : Nat.ble 2767841 2767841 = true
kernel_rfl PRE_first_tail_x15_r0_body.fn118 : Nat.ble 5123 5123 = true
kernel_rfl PRE_first_tail_x15_r0_body.fjaD118 : Nat.ble 2767841 PRE_first_tail_x15_r0_body.kd118.n0 = true
kernel_rfl PRE_first_tail_x15_r0_body.fxn118 : Nat.ble 20534 PRE_first_tail_x15_r0_body.kd118.nh0 = true
kernel_rfl PRE_first_tail_x15_r0_body.fnn118 : Nat.ble 17625 PRE_first_tail_x15_r0_body.kd118.nn0 = true
kernel_rfl PRE_first_tail_x15_r0_body.fxb118 : Nat.ble 20534 RData.bigHi = true
kernel_rfl PRE_first_tail_x15_r0_body.fheap118 : (PTrie.keysA PRE_first_tail_x15_r0_body.kd118.heap).all (Nat.ble (⟨20534, 17625, 2767841, 5123⟩ : Conv.Cnt).ja) = true
kernel_rfl PRE_first_tail_x15_r0_body.fhnd118 : (PTrie.keysA PRE_first_tail_x15_r0_body.kd118.hnd).all (Nat.ble (⟨20534, 17625, 2767841, 5123⟩ : Conv.Cnt).xn) = true
kernel_rfl PRE_first_tail_x15_r0_body.fnode118 : (PTrie.keysA PRE_first_tail_x15_r0_body.kd118.node).all (Nat.ble (⟨20534, 17625, 2767841, 5123⟩ : Conv.Cnt).nn) = true
/-- The compaction map fixes the call's names. -/
theorem PRE_first_tail_x15_r0_body.cfix118 : Conv.FixOld (⟨20534, 17625, 2767841, 5123⟩ : Conv.Cnt) PRE_first_tail_x15_r0_body.kappa118 :=
  Conv.fixOld_compact (Nat.le_of_ble_eq_true PRE_first_tail_x15_r0_body.fja118) (Nat.le_of_ble_eq_true PRE_first_tail_x15_r0_body.fn118) (Nat.le_of_ble_eq_true PRE_first_tail_x15_r0_body.fjaD118) (Nat.le_of_ble_eq_true PRE_first_tail_x15_r0_body.fxn118) (Nat.le_of_ble_eq_true PRE_first_tail_x15_r0_body.fnn118) (Nat.le_of_ble_eq_true PRE_first_tail_x15_r0_body.fxb118) PRE_first_tail_x15_r0_body.fheap118 PRE_first_tail_x15_r0_body.fhnd118 PRE_first_tail_x15_r0_body.fnode118
kernel_rfl PRE_first_tail_x15_r0_body.fcxn118 : (⟨20534, 17625, 2767841, 5123⟩ : Conv.Cnt).xn = (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1145.ffi).mlx.next
kernel_rfl PRE_first_tail_x15_r0_body.fcnn118 : (⟨20534, 17625, 2767841, 5123⟩ : Conv.Cnt).nn = (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1145.ffi).mlx.nnext
kernel_rfl PRE_first_tail_x15_r0_body.fle0118 : (Nat.ble (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1145.ffi).mlx.next PRE_first_tail_x15_r0_body.cx0_118.mlx.next && Nat.ble (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1145.ffi).mlx.nnext PRE_first_tail_x15_r0_body.cx0_118.mlx.nnext && Nat.ble (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1145.ffi).mlx.next RData.bigHi) = true
kernel_rfl PRE_first_tail_x15_r0_body.fnk118 : (PTrie.keysA PRE_first_tail_x15_r0_body.kd118.node).all (Nat.ble (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1145.ffi).mlx.nnext) = true
-- the merged state keeps the call's entries off the stage's footprint
kernel_rfl PRE_first_tail_x15_r0_body.f1A118 : PRE_first_tail_x15_r0_body.cx1_118.mlx.arrs = Stage.setAll (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1145.ffi).mlx.arrs (PRE_first_tail_x15_r0_body.cwS118.filterMap fun i => (PRE_first_tail_x15_r0_body.cx1_118.mlx.arrs.get i).map (i, ·))
kernel_rfl PRE_first_tail_x15_r0_body.f1O118 : PRE_first_tail_x15_r0_body.cx1_118.mlx.objs = Stage.setAll (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1145.ffi).mlx.objs (PRE_first_tail_x15_r0_body.cwS118.filterMap fun i => (PRE_first_tail_x15_r0_body.cx1_118.mlx.objs.get i).map (i, ·))
kernel_rfl PRE_first_tail_x15_r0_body.f1N118 : PRE_first_tail_x15_r0_body.cx1_118.mlx.nodes = Stage.setAll (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1145.ffi).mlx.nodes (PRE_first_tail_x15_r0_body.cnS118.filterMap fun i => (PRE_first_tail_x15_r0_body.cx1_118.mlx.nodes.get i).map (i, ·))
kernel_rfl PRE_first_tail_x15_r0_body.f1I118 : PRE_first_tail_x15_r0_body.cx1_118.mlx.items = Stage.setAll (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1145.ffi).mlx.items (PRE_first_tail_x15_r0_body.ciS118.filterMap fun i => (PRE_first_tail_x15_r0_body.cx1_118.mlx.items.get i).map (i, ·))
kernel_rfl PRE_first_tail_x15_r0_body.fbd118 : (PRE_first_tail_x15_r0_body.clo118 ++ PRE_first_tail_x15_r0_body.cln118 ++ PRE_first_tail_x15_r0_body.cli118 ++ PRE_first_tail_x15_r0_body.cwS118 ++ PRE_first_tail_x15_r0_body.cnS118 ++ PRE_first_tail_x15_r0_body.ciS118).all (fun i => Nat.blt (i / 4096) (4 ^ 31)) = true
kernel_rfl PRE_first_tail_x15_r0_body.fincW118 : PRE_first_tail_x15_r0_body.cwS118.all (fun h => !Nat.blt h (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1145.ffi).mlx.next || PRE_first_tail_x15_r0_body.clo118.contains h) = true
kernel_rfl PRE_first_tail_x15_r0_body.fincI118 : PRE_first_tail_x15_r0_body.ciS118.all (fun k => !Nat.blt k (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1145.ffi).mlx.nnext || PRE_first_tail_x15_r0_body.cli118.contains k) = true
kernel_rfl PRE_first_tail_x15_r0_body.fincN118 : PRE_first_tail_x15_r0_body.cnS118.all (Nat.ble (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1145.ffi).mlx.nnext) = true
kernel_rfl PRE_first_tail_x15_r0_body.flnF118 : PRE_first_tail_x15_r0_body.cln118.all (Nat.ble (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1145.ffi).mlx.nnext) = true
-- the checks over the changed lists
kernel_rfl PRE_first_tail_x15_r0_body.fh118 : PRE_first_tail_x15_r0_body.clo118.all (handleOK PRE_first_tail_x15_r0_body.kappa118 PRE_first_tail_x15_r0_body.P118.lo PRE_first_tail_x15_r0_body.cx0_118.mlx PRE_first_tail_x15_r0_body.cx1_118.mlx) = true
kernel_rfl PRE_first_tail_x15_r0_body.fo118 : PRE_first_tail_x15_r0_body.clo118.map (fun h => PRE_first_tail_x15_r0_body.cx1_118.mlx.objs.get (PRE_first_tail_x15_r0_body.kappa118.handle h)) = PRE_first_tail_x15_r0_body.clo118.map (fun h => (PRE_first_tail_x15_r0_body.cx0_118.mlx.objs.get h).map PRE_first_tail_x15_r0_body.kappa118.nobj)
kernel_rfl PRE_first_tail_x15_r0_body.fok118 : PRE_first_tail_x15_r0_body.clo118.all (objOK PRE_first_tail_x15_r0_body.kappa118 PRE_first_tail_x15_r0_body.P118.NL PRE_first_tail_x15_r0_body.cx0_118.mlx) = true
kernel_rfl PRE_first_tail_x15_r0_body.fnd118 : PRE_first_tail_x15_r0_body.cln118.all (nodeOKF PRE_first_tail_x15_r0_body.kappa118 PRE_first_tail_x15_r0_body.P118 PRE_first_tail_x15_r0_body.cx0_118.mlx PRE_first_tail_x15_r0_body.cx1_118.mlx) = true
kernel_rfl PRE_first_tail_x15_r0_body.fp118 : ((PRE_first_tail_x15_r0_body.cln118.filter (fullB PRE_first_tail_x15_r0_body.P118))).map (fun i => (PRE_first_tail_x15_r0_body.cx1_118.mlx.nodes.get (PRE_first_tail_x15_r0_body.kappa118.node i)).map Host.Mlx.Ffi.Node.prim) =
  ((PRE_first_tail_x15_r0_body.cln118.filter (fullB PRE_first_tail_x15_r0_body.P118))).map (fun i => (PRE_first_tail_x15_r0_body.cx0_118.mlx.nodes.get i).map fun nd => PRE_first_tail_x15_r0_body.kappa118.prim nd.prim)
kernel_rfl PRE_first_tail_x15_r0_body.fnordI118 : incrB PRE_first_tail_x15_r0_body.kd118.nodeF (List.range' 17625 0) = true
kernel_rfl PRE_first_tail_x15_r0_body.fnordK118 : (PTrie.keysA PRE_first_tail_x15_r0_body.kd118.node).all (fun k => Nat.ble 17625 k && Nat.blt k 17625) = true
kernel_rfl PRE_first_tail_x15_r0_body.fnordL118 : (PRE_first_tail_x15_r0_body.cln118.filter (Nat.ble PRE_first_tail_x15_r0_body.P118.N0)).all (fun i => Nat.ble i (PRE_first_tail_x15_r0_body.kd118.nodeF i) && (Nat.blt i 17625 || Nat.ble PRE_first_tail_x15_r0_body.kd118.nn0 i)) = true
theorem PRE_first_tail_x15_r0_body.fnord118 : (PRE_first_tail_x15_r0_body.cln118.filter (Nat.ble PRE_first_tail_x15_r0_body.P118.N0)).all (fun i => Nat.ble i (PRE_first_tail_x15_r0_body.kd118.nodeF i) &&
    (PTrie.keysA PRE_first_tail_x15_r0_body.kd118.node).all fun j => !Nat.blt j i || Nat.blt (PRE_first_tail_x15_r0_body.kd118.nodeF j) (PRE_first_tail_x15_r0_body.kd118.nodeF i)) = true :=
  cnord_of PRE_first_tail_x15_r0_body.cnlow118 PRE_first_tail_x15_r0_body.cnn1118 PRE_first_tail_x15_r0_body.fnordI118 PRE_first_tail_x15_r0_body.fnordK118 PRE_first_tail_x15_r0_body.fnordL118
kernel_rfl PRE_first_tail_x15_r0_body.fi118 : PRE_first_tail_x15_r0_body.cli118.all (pnB PRE_first_tail_x15_r0_body.cx0_118.mlx) = true
kernel_rfl PRE_first_tail_x15_r0_body.fii118 : PRE_first_tail_x15_r0_body.cli118.all (fun k => decide (PRE_first_tail_x15_r0_body.cx1_118.mlx.items.get (PRE_first_tail_x15_r0_body.kappa118.node k) = (PRE_first_tail_x15_r0_body.cx0_118.mlx.items.get k).map PRE_first_tail_x15_r0_body.kappa118.nv)) = true
/-- **The compaction's footprint.** -/
theorem PRE_first_tail_x15_r0_body.cfoot118 (clean : Conv.NClean (⟨20534, 17625, 2767841, 5123⟩ : Conv.Cnt) (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1145.ffi).mlx) (hltC : ∀ h, PH (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1145.ffi).mlx h → h < (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1145.ffi).mlx.next) (nltC : ∀ i, PN (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1145.ffi).mlx i → i < (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1145.ffi).mlx.nnext) (itemsC : ∀ k v, (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1145.ffi).mlx.items.get k = some v → PN (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1145.ffi).mlx k) (tracedC : ∀ h o, (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1145.ffi).mlx.objs.get h = some o → ∀ i ∈ objTraces o, i < PRE_first_tail_x15_r0_body.P118.NL) (cl : SSt (· < 5123) PRE_first_tail_x15_r0_body.cx0_118.mlx) :
    Conv.MFoot PRE_first_tail_x15_r0_body.P118 5123 PRE_first_tail_x15_r0_body.kappa118 PRE_first_tail_x15_r0_body.kd118 PRE_first_tail_x15_r0_body.khinv118 PRE_first_tail_x15_r0_body.kninv118 (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1145.ffi).mlx PRE_first_tail_x15_r0_body.cx0_118.mlx PRE_first_tail_x15_r0_body.cx1_118.mlx (⟨20534, 17625, 2767841, 5123⟩ : Conv.Cnt) PRE_first_tail_x15_r0_body.clo118 PRE_first_tail_x15_r0_body.cln118 PRE_first_tail_x15_r0_body.cli118 PRE_first_tail_x15_r0_body.cwS118 PRE_first_tail_x15_r0_body.cnS118 PRE_first_tail_x15_r0_body.ciS118 :=
  ⟨rfl, rfl, rfl, PRE_first_tail_x15_r0_body.cnh0118, PRE_first_tail_x15_r0_body.cnh1118, PRE_first_tail_x15_r0_body.cnn0118, PRE_first_tail_x15_r0_body.cnn1118, PRE_first_tail_x15_r0_body.cplo118, PRE_first_tail_x15_r0_body.ccnt118, PRE_first_tail_x15_r0_body.cnband118, PRE_first_tail_x15_r0_body.chbelow118, PRE_first_tail_x15_r0_body.chren118, PRE_first_tail_x15_r0_body.cband118, PRE_first_tail_x15_r0_body.cnh1pos118, PRE_first_tail_x15_r0_body.cnren118, PRE_first_tail_x15_r0_body.cnlow118, PRE_first_tail_x15_r0_body.cabs0a118, PRE_first_tail_x15_r0_body.cabs0b118, PRE_first_tail_x15_r0_body.ctok1118, PRE_first_tail_x15_r0_body.cpend118, PRE_first_tail_x15_r0_body.cerrh118, PRE_first_tail_x15_r0_body.cfiles118, PRE_first_tail_x15_r0_body.carch118, PRE_first_tail_x15_r0_body.csizes118, PRE_first_tail_x15_r0_body.cwired118, PRE_first_tail_x15_r0_body.cfix118, clean, PRE_first_tail_x15_r0_body.fcxn118, PRE_first_tail_x15_r0_body.fcnn118, hltC, nltC, itemsC, tracedC, cl, PRE_first_tail_x15_r0_body.fle0118, PRE_first_tail_x15_r0_body.fnk118, PRE_first_tail_x15_r0_body.ckA118, PRE_first_tail_x15_r0_body.cobjsK118, PRE_first_tail_x15_r0_body.cnodesK118, PRE_first_tail_x15_r0_body.citemsK118, PRE_first_tail_x15_r0_body.f1A118, PRE_first_tail_x15_r0_body.f1O118, PRE_first_tail_x15_r0_body.f1N118, PRE_first_tail_x15_r0_body.f1I118, PRE_first_tail_x15_r0_body.fbd118, PRE_first_tail_x15_r0_body.fincW118, PRE_first_tail_x15_r0_body.fincI118, PRE_first_tail_x15_r0_body.fincN118, PRE_first_tail_x15_r0_body.flnF118, PRE_first_tail_x15_r0_body.fh118, PRE_first_tail_x15_r0_body.fo118, PRE_first_tail_x15_r0_body.fok118, PRE_first_tail_x15_r0_body.fnd118, PRE_first_tail_x15_r0_body.fp118, PRE_first_tail_x15_r0_body.fnord118, PRE_first_tail_x15_r0_body.fi118, PRE_first_tail_x15_r0_body.fii118⟩
theorem PRE_first_tail_x15_r0_body.cnshift118 (clean : Conv.NClean (⟨20534, 17625, 2767841, 5123⟩ : Conv.Cnt) (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1145.ffi).mlx) (hltC : ∀ h, PH (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1145.ffi).mlx h → h < (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1145.ffi).mlx.next) (nltC : ∀ i, PN (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1145.ffi).mlx i → i < (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1145.ffi).mlx.nnext) (itemsC : ∀ k v, (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1145.ffi).mlx.items.get k = some v → PN (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1145.ffi).mlx k) (tracedC : ∀ h o, (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1145.ffi).mlx.objs.get h = some o → ∀ i ∈ objTraces o, i < PRE_first_tail_x15_r0_body.P118.NL) (cl : SSt (· < 5123) PRE_first_tail_x15_r0_body.cx0_118.mlx) : NShift PRE_first_tail_x15_r0_body.P118 5123 PRE_first_tail_x15_r0_body.kappa118 PRE_first_tail_x15_r0_body.cx0_118 PRE_first_tail_x15_r0_body.cx1_118 :=
  Conv.nshift_of_foot (PRE_first_tail_x15_r0_body.cfoot118 clean hltC nltC itemsC tracedC cl) PRE_first_tail_x15_r0_body.chost118 (compact_a_eq PRE_first_tail_x15_r0_body.ckn0118 PRE_first_tail_x15_r0_body.ckn1118 PRE_first_tail_x15_r0_body.ckheap118 PRE_first_tail_x15_r0_body.ckpl118)

-- the observers: the layers' states at the call, the canonical and the merged state, their footprints and checks
noncomputable def PRE_first_tail_x15_r0_body.fxC_118 : PTrie Unit := (Host.Ts.Sim.Full.freedOf PRE_first_tail_x15_r0_body.s1145.ffi).getD PTrie.nil
noncomputable def PRE_first_tail_x15_r0_body.krC_118 : Host.Load.Layers.KRec := (Host.Ts.Sim.Full.krecOf PRE_first_tail_x15_r0_body.s1145.ffi).getD Host.Load.Layers.KRec.empty
kernel_rfl PRE_first_tail_x15_r0_body.ofxC_118 : (Host.Ts.Sim.Full.freedOf PRE_first_tail_x15_r0_body.s1145.ffi) = some PRE_first_tail_x15_r0_body.fxC_118
kernel_rfl PRE_first_tail_x15_r0_body.okrC_118 : (Host.Ts.Sim.Full.krecOf PRE_first_tail_x15_r0_body.s1145.ffi) = some PRE_first_tail_x15_r0_body.krC_118
noncomputable def PRE_first_tail_x15_r0_body.fx0_118 : PTrie Unit := (Host.Ts.Sim.Full.freedOf PRE_first_tail_x15_r0_body.s1147.ffi).getD PTrie.nil
noncomputable def PRE_first_tail_x15_r0_body.kr0_118 : Host.Load.Layers.KRec := (Host.Ts.Sim.Full.krecOf PRE_first_tail_x15_r0_body.s1147.ffi).getD Host.Load.Layers.KRec.empty
kernel_rfl PRE_first_tail_x15_r0_body.ofx0_118 : (Host.Ts.Sim.Full.freedOf PRE_first_tail_x15_r0_body.s1147.ffi) = some PRE_first_tail_x15_r0_body.fx0_118
kernel_rfl PRE_first_tail_x15_r0_body.okr0_118 : (Host.Ts.Sim.Full.krecOf PRE_first_tail_x15_r0_body.s1147.ffi) = some PRE_first_tail_x15_r0_body.kr0_118
noncomputable def PRE_first_tail_x15_r0_body.fx1_118 : PTrie Unit := (Host.Ts.Sim.Full.freedOf PRE_first_tail_x15_r0_body.s1146.ffi).getD PTrie.nil
noncomputable def PRE_first_tail_x15_r0_body.kr1_118 : Host.Load.Layers.KRec := (Host.Ts.Sim.Full.krecOf PRE_first_tail_x15_r0_body.s1146.ffi).getD Host.Load.Layers.KRec.empty
kernel_rfl PRE_first_tail_x15_r0_body.ofx1_118 : (Host.Ts.Sim.Full.freedOf PRE_first_tail_x15_r0_body.s1146.ffi) = some PRE_first_tail_x15_r0_body.fx1_118
kernel_rfl PRE_first_tail_x15_r0_body.okr1_118 : (Host.Ts.Sim.Full.krecOf PRE_first_tail_x15_r0_body.s1146.ffi) = some PRE_first_tail_x15_r0_body.kr1_118
kernel_rfl PRE_first_tail_x15_r0_body.ff0118 : PRE_first_tail_x15_r0_body.fx0_118 = Stage.setAll PRE_first_tail_x15_r0_body.fxC_118 (PRE_first_tail_x15_r0_body.clo118.filterMap fun i => (PRE_first_tail_x15_r0_body.fx0_118.get i).map (i, ·))
kernel_rfl PRE_first_tail_x15_r0_body.ff1118 : PRE_first_tail_x15_r0_body.fx1_118 = Stage.setAll PRE_first_tail_x15_r0_body.fxC_118 (PRE_first_tail_x15_r0_body.cwS118.filterMap fun i => (PRE_first_tail_x15_r0_body.fx1_118.get i).map (i, ·))
kernel_rfl PRE_first_tail_x15_r0_body.ffck118 : freedLB PRE_first_tail_x15_r0_body.kappa118 PRE_first_tail_x15_r0_body.cx0_118.mlx PRE_first_tail_x15_r0_body.fx0_118 PRE_first_tail_x15_r0_body.fx1_118 PRE_first_tail_x15_r0_body.clo118 = true
kernel_rfl PRE_first_tail_x15_r0_body.fkf0118 : PRE_first_tail_x15_r0_body.kr0_118.flags = Stage.setAll PRE_first_tail_x15_r0_body.krC_118.flags (PRE_first_tail_x15_r0_body.clo118.filterMap fun i => (PRE_first_tail_x15_r0_body.kr0_118.flags.get i).map (i, ·))
kernel_rfl PRE_first_tail_x15_r0_body.fkt0118 : PRE_first_tail_x15_r0_body.kr0_118.targs = Stage.setAll PRE_first_tail_x15_r0_body.krC_118.targs (PRE_first_tail_x15_r0_body.clo118.filterMap fun i => (PRE_first_tail_x15_r0_body.kr0_118.targs.get i).map (i, ·))
kernel_rfl PRE_first_tail_x15_r0_body.fkf1118 : PRE_first_tail_x15_r0_body.kr1_118.flags = Stage.setAll PRE_first_tail_x15_r0_body.krC_118.flags (PRE_first_tail_x15_r0_body.cwS118.filterMap fun i => (PRE_first_tail_x15_r0_body.kr1_118.flags.get i).map (i, ·))
kernel_rfl PRE_first_tail_x15_r0_body.fkt1118 : PRE_first_tail_x15_r0_body.kr1_118.targs = Stage.setAll PRE_first_tail_x15_r0_body.krC_118.targs (PRE_first_tail_x15_r0_body.cwS118.filterMap fun i => (PRE_first_tail_x15_r0_body.kr1_118.targs.get i).map (i, ·))
kernel_rfl PRE_first_tail_x15_r0_body.fkck118 : krecLB PRE_first_tail_x15_r0_body.kappa118 5123 PRE_first_tail_x15_r0_body.cx0_118.mlx PRE_first_tail_x15_r0_body.kr0_118 PRE_first_tail_x15_r0_body.kr1_118 PRE_first_tail_x15_r0_body.clo118 = true
kernel_rfl PRE_first_tail_x15_r0_body.fkn118 : Nat.ble 5123 5123 = true
-- the bridge and the pending traces' regions
kernel_rfl PRE_first_tail_x15_r0_body.cbridge118 : Host.Ts.Sim.Full.bridgeOf PRE_first_tail_x15_r0_body.s1146.ffi = Host.Ts.Sim.Full.bridgeOf PRE_first_tail_x15_r0_body.s1147.ffi
kernel_rfl PRE_first_tail_x15_r0_body.cpendR118 : pendRegB PRE_first_tail_x15_r0_body.kappa118 (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1147.ffi).mlx = true
kernel_rfl PRE_first_tail_x15_r0_body.cpendLe118 : Nat.ble (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1147.ffi).mlx.next (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1146.ffi).mlx.next = true
/-- **The compaction's native shift**, given the call's bookkeeping, its relation's facts (the model's and the
observers') and the canonical closedness. -/
theorem PRE_first_tail_x15_r0_body.cshift118 (clean : Conv.NClean (⟨20534, 17625, 2767841, 5123⟩ : Conv.Cnt) (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1145.ffi).mlx) (hltC : ∀ h, PH (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1145.ffi).mlx h → h < (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1145.ffi).mlx.next) (nltC : ∀ i, PN (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1145.ffi).mlx i → i < (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1145.ffi).mlx.nnext) (itemsC : ∀ k v, (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1145.ffi).mlx.items.get k = some v → PN (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1145.ffi).mlx k) (tracedC : ∀ h o, (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1145.ffi).mlx.objs.get h = some o → ∀ i ∈ objTraces o, i < PRE_first_tail_x15_r0_body.P118.NL) (cl : SSt (· < 5123) PRE_first_tail_x15_r0_body.cx0_118.mlx)
    (hobjC : ∀ h, PRE_first_tail_x15_r0_body.fxC_118.get h = some () → ((Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1145.ffi).mlx.objs.get h).isSome = true)
    (hfC : ∀ h, (PRE_first_tail_x15_r0_body.krC_118.flags.get h).isSome = true → ((Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1145.ffi).mlx.objs.get h).isSome = true)
    (htC : ∀ h, (PRE_first_tail_x15_r0_body.krC_118.targs.get h).isSome = true → ((Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1145.ffi).mlx.objs.get h).isSome = true)
    (hclC : ∀ h l, PRE_first_tail_x15_r0_body.krC_118.targs.get h = some l → Host.Ts.Sim.Full.STargs (· < (⟨20534, 17625, 2767841, 5123⟩ : Conv.Cnt).n) l) :
    Conv.FullShiftQ PRE_first_tail_x15_r0_body.P118 5123 PRE_first_tail_x15_r0_body.kappa118 PRE_first_tail_x15_r0_body.s1147.ffi PRE_first_tail_x15_r0_body.s1146.ffi :=
  ⟨PRE_first_tail_x15_r0_body.cnshift118 clean hltC nltC itemsC tracedC cl, PRE_first_tail_x15_r0_body.cqueue118, fun t ht => bSN_sound (List.all_eq_true.mp PRE_first_tail_x15_r0_body.ctokSupp118 t ht),
    PRE_first_tail_x15_r0_body.cbridge118,
    liveShift_foot (x0' := Host.Ts.Sim.Full.mlxOf PRE_first_tail_x15_r0_body.s1147.ffi) (x1' := Host.Ts.Sim.Full.mlxOf PRE_first_tail_x15_r0_body.s1146.ffi) (PRE_first_tail_x15_r0_body.cfoot118 clean hltC nltC itemsC tracedC cl) rfl PRE_first_tail_x15_r0_body.ofx0_118 PRE_first_tail_x15_r0_body.ofx1_118 hobjC PRE_first_tail_x15_r0_body.ff0118 PRE_first_tail_x15_r0_body.ff1118 PRE_first_tail_x15_r0_body.ffck118,
    kernShift_foot (x0' := Host.Ts.Sim.Full.mlxOf PRE_first_tail_x15_r0_body.s1147.ffi) (x1' := Host.Ts.Sim.Full.mlxOf PRE_first_tail_x15_r0_body.s1146.ffi) (PRE_first_tail_x15_r0_body.cfoot118 clean hltC nltC itemsC tracedC cl) rfl PRE_first_tail_x15_r0_body.okr0_118 PRE_first_tail_x15_r0_body.okr1_118 (Nat.le_of_ble_eq_true PRE_first_tail_x15_r0_body.fkn118) hfC htC hclC
      PRE_first_tail_x15_r0_body.fkf0118 PRE_first_tail_x15_r0_body.fkt0118 PRE_first_tail_x15_r0_body.fkf1118 PRE_first_tail_x15_r0_body.fkt1118 PRE_first_tail_x15_r0_body.fkck118,
    pendReg_of rfl PRE_first_tail_x15_r0_body.cnh0118 PRE_first_tail_x15_r0_body.cnh1118 (Nat.le_of_ble_eq_true PRE_first_tail_x15_r0_body.cpendLe118) PRE_first_tail_x15_r0_body.cpendR118⟩

end Host.Load.Run.Tpl
