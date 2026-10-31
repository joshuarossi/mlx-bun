import host.sim.template.a4pre_first_tail_x15_r0_body.SiteCl180
import host.sim.conv.CompactFull
import host.sim.template.FootGen
set_option Elab.async false
namespace Host.Load.Run.Tpl
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
open Host.Ts Host.Ts.Sim Host.Ts.Sim.Template

/-! The compaction's native shift at call site 180 from its footprint (`Conv.nshift_of_foot`), and the observers'
(`liveShift_foot`, `kernShift_foot`): `Conv.FullShiftQ` for `Conv.full_compactQ`, given the call's bookkeeping and its
relation's facts. -/

/-- The load parameters of the chain (band-free: its start's node counter as `NL` and `N0`). -/
def PRE_first_tail_x15_r0_body.Pc180 : LoadP := ⟨18151, 131072, 1099511627776, 15235, 15235, []⟩
/-- The site's band raised to the map's checked fixed-node prefix, including newly recorded closure traces. -/
def PRE_first_tail_x15_r0_body.P180 : LoadP := PRE_first_tail_x15_r0_body.Pc180.raise 18860
kernel_rfl PRE_first_tail_x15_r0_body.craise180 : Nat.ble PRE_first_tail_x15_r0_body.Pc180.N0 18860 = true
theorem PRE_first_tail_x15_r0_body.raised180 : Host.Ts.Sim.Full.Raised PRE_first_tail_x15_r0_body.Pc180 PRE_first_tail_x15_r0_body.P180 :=
  .inr ⟨18860, rfl, Nat.le_of_ble_eq_true PRE_first_tail_x15_r0_body.craise180, rfl⟩
noncomputable abbrev PRE_first_tail_x15_r0_body.cx0_180 : Host.Load.LSt := clearTokens (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1743.ffi)
noncomputable abbrev PRE_first_tail_x15_r0_body.cx1_180 : Host.Load.LSt := clearTokens (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1742.ffi)
def PRE_first_tail_x15_r0_body.khinv180 : PTrie Nat := Stage.setAll PTrie.nil [(21782, 21756), (21760, 21757), (21783, 21758)]
def PRE_first_tail_x15_r0_body.kninv180 : PTrie Nat := Stage.setAll PTrie.nil [(18833, 18833), (18834, 18834), (18835, 18835), (18836, 18836), (18837, 18837), (18838, 18838), (18839, 18839), (18840, 18840), (18841, 18841), (18842, 18842), (18843, 18843), (18844, 18844), (18845, 18845), (18846, 18846), (18847, 18847), (18848, 18848), (18849, 18849), (18850, 18850), (18851, 18851), (18852, 18852), (18853, 18853), (18854, 18854), (18855, 18855), (18856, 18856), (18857, 18857), (18858, 18858), (18859, 18859)]
/-- The stage's footprint: its written and fresh handles, fresh nodes, written and fresh items. -/
def PRE_first_tail_x15_r0_body.cwS180 : List Nat := [21736, 21749, 21755, 21756, 21757, 21758, 21759, 21760, 21761, 21762, 21763, 21764, 21765, 21766, 21767, 21768, 21769, 21770, 21771, 21772, 21773, 21774, 21775, 21776, 21777, 21778, 21779, 21780, 21781, 21782, 21783]
def PRE_first_tail_x15_r0_body.cnS180 : List Nat := List.range' 18833 27
def PRE_first_tail_x15_r0_body.ciS180 : List Nat := [] ++ List.range' 18833 27

-- the small checks (`MChecks`'s)
kernel_rfl PRE_first_tail_x15_r0_body.cnh0180 : PRE_first_tail_x15_r0_body.kd180.nh0 = PRE_first_tail_x15_r0_body.cx0_180.mlx.next
kernel_rfl PRE_first_tail_x15_r0_body.cnh1180 : PRE_first_tail_x15_r0_body.kd180.nh1 = PRE_first_tail_x15_r0_body.cx1_180.mlx.next
kernel_rfl PRE_first_tail_x15_r0_body.cnn0180 : PRE_first_tail_x15_r0_body.kd180.nn0 = PRE_first_tail_x15_r0_body.cx0_180.mlx.nnext
kernel_rfl PRE_first_tail_x15_r0_body.cnn1180 : PRE_first_tail_x15_r0_body.kd180.nn1 = PRE_first_tail_x15_r0_body.cx1_180.mlx.nnext
kernel_rfl PRE_first_tail_x15_r0_body.cplo180 : (Nat.blt 0 PRE_first_tail_x15_r0_body.P180.lo && Nat.ble PRE_first_tail_x15_r0_body.P180.lo PRE_first_tail_x15_r0_body.cx0_180.mlx.next && Nat.ble PRE_first_tail_x15_r0_body.P180.lo RData.bigHi && Nat.ble RData.bigHi PRE_first_tail_x15_r0_body.P180.E) = true
kernel_rfl PRE_first_tail_x15_r0_body.ccnt180 : (Nat.ble PRE_first_tail_x15_r0_body.cx0_180.mlx.next PRE_first_tail_x15_r0_body.cx1_180.mlx.next && Nat.ble PRE_first_tail_x15_r0_body.cx0_180.mlx.nnext PRE_first_tail_x15_r0_body.cx1_180.mlx.nnext) = true
kernel_rfl PRE_first_tail_x15_r0_body.cnband180 : (Nat.blt 0 PRE_first_tail_x15_r0_body.P180.NL && Nat.ble PRE_first_tail_x15_r0_body.P180.NL PRE_first_tail_x15_r0_body.P180.N0 && Nat.ble PRE_first_tail_x15_r0_body.P180.N0 PRE_first_tail_x15_r0_body.cx0_180.mlx.nnext) = true
kernel_rfl PRE_first_tail_x15_r0_body.chbelow180 : PRE_first_tail_x15_r0_body.kd180.checkHndBelow = true
kernel_rfl PRE_first_tail_x15_r0_body.chren180 : checkRenG PRE_first_tail_x15_r0_body.kd180.hnd PRE_first_tail_x15_r0_body.khinv180 (phB PRE_first_tail_x15_r0_body.cx0_180.mlx) = true
kernel_rfl PRE_first_tail_x15_r0_body.cband180 : PRE_first_tail_x15_r0_body.kd180.checkBand PRE_first_tail_x15_r0_body.P180.lo = true
kernel_rfl PRE_first_tail_x15_r0_body.cnh1pos180 : Nat.blt 0 PRE_first_tail_x15_r0_body.kd180.nh1 = true
kernel_rfl PRE_first_tail_x15_r0_body.cnren180 : checkRenG PRE_first_tail_x15_r0_body.kd180.node PRE_first_tail_x15_r0_body.kninv180 (pnB PRE_first_tail_x15_r0_body.cx0_180.mlx) = true
kernel_rfl PRE_first_tail_x15_r0_body.cnlow180 : (PTrie.keysA PRE_first_tail_x15_r0_body.kd180.node).all (fun j => Nat.ble PRE_first_tail_x15_r0_body.P180.NL j && Nat.blt (PRE_first_tail_x15_r0_body.kd180.nodeF j) PRE_first_tail_x15_r0_body.cx1_180.mlx.nnext) = true
kernel_rfl PRE_first_tail_x15_r0_body.cabs0a180 : PRE_first_tail_x15_r0_body.cx0_180.mlx.arrs.get 0 = none
kernel_rfl PRE_first_tail_x15_r0_body.cabs0b180 : PRE_first_tail_x15_r0_body.cx0_180.mlx.objs.get 0 = none
kernel_rfl PRE_first_tail_x15_r0_body.ctok1180 : PRE_first_tail_x15_r0_body.cx1_180.mlx.tokens = []
kernel_rfl PRE_first_tail_x15_r0_body.cpend180 : PRE_first_tail_x15_r0_body.cx1_180.mlx.pending = PRE_first_tail_x15_r0_body.cx0_180.mlx.pending.map PRE_first_tail_x15_r0_body.kappa180.pend
kernel_rfl PRE_first_tail_x15_r0_body.cerrh180 : PRE_first_tail_x15_r0_body.cx1_180.mlx.errh = PRE_first_tail_x15_r0_body.cx0_180.mlx.errh.map PRE_first_tail_x15_r0_body.kappa180.arg
kernel_rfl PRE_first_tail_x15_r0_body.cfiles180 : PRE_first_tail_x15_r0_body.cx1_180.mlx.files = PRE_first_tail_x15_r0_body.cx0_180.mlx.files
kernel_rfl PRE_first_tail_x15_r0_body.carch180 : PRE_first_tail_x15_r0_body.cx1_180.mlx.arch = PRE_first_tail_x15_r0_body.cx0_180.mlx.arch
kernel_rfl PRE_first_tail_x15_r0_body.csizes180 : PRE_first_tail_x15_r0_body.cx1_180.mlx.deviceSizes = PRE_first_tail_x15_r0_body.cx0_180.mlx.deviceSizes
kernel_rfl PRE_first_tail_x15_r0_body.cwired180 : PRE_first_tail_x15_r0_body.cx1_180.mlx.wired = PRE_first_tail_x15_r0_body.cx0_180.mlx.wired
kernel_rfl PRE_first_tail_x15_r0_body.chost180 : PRE_first_tail_x15_r0_body.cx1_180.host = PRE_first_tail_x15_r0_body.cx0_180.host
-- the compaction map's addresses are `PRE_first_tail_x15_r0_body.kd180`'s
kernel_rfl PRE_first_tail_x15_r0_body.ckn0180 : PRE_first_tail_x15_r0_body.kd180.n0 = 2816733
kernel_rfl PRE_first_tail_x15_r0_body.ckn1180 : PRE_first_tail_x15_r0_body.kd180.n1 = 2817882
kernel_rfl PRE_first_tail_x15_r0_body.ckheap180 : (PTrie.keysA PRE_first_tail_x15_r0_body.kd180.heap).all (fun x => Nat.ble 2816727 x) = true
kernel_rfl PRE_first_tail_x15_r0_body.ckpl180 : (List.range 6).all (fun j => decide (PRE_first_tail_x15_r0_body.kd180.heap.get (2816727 + j) = nth? PRE_first_tail_x15_r0_body.pl180 j)) = true
-- the map fixes the call's names (`Conv.fixOld_compact`), the call's counters
kernel_rfl PRE_first_tail_x15_r0_body.fja180 : Nat.ble 2816727 2816727 = true
kernel_rfl PRE_first_tail_x15_r0_body.fn180 : Nat.ble 7778 7778 = true
kernel_rfl PRE_first_tail_x15_r0_body.fjaD180 : Nat.ble 2816727 PRE_first_tail_x15_r0_body.kd180.n0 = true
kernel_rfl PRE_first_tail_x15_r0_body.fxn180 : Nat.ble 21756 PRE_first_tail_x15_r0_body.kd180.nh0 = true
kernel_rfl PRE_first_tail_x15_r0_body.fnn180 : Nat.ble 18833 PRE_first_tail_x15_r0_body.kd180.nn0 = true
kernel_rfl PRE_first_tail_x15_r0_body.fxb180 : Nat.ble 21756 RData.bigHi = true
kernel_rfl PRE_first_tail_x15_r0_body.fheap180 : (PTrie.keysA PRE_first_tail_x15_r0_body.kd180.heap).all (Nat.ble (⟨21756, 18833, 2816727, 7778⟩ : Conv.Cnt).ja) = true
kernel_rfl PRE_first_tail_x15_r0_body.fhnd180 : (PTrie.keysA PRE_first_tail_x15_r0_body.kd180.hnd).all (Nat.ble (⟨21756, 18833, 2816727, 7778⟩ : Conv.Cnt).xn) = true
kernel_rfl PRE_first_tail_x15_r0_body.fnode180 : (PTrie.keysA PRE_first_tail_x15_r0_body.kd180.node).all (Nat.ble (⟨21756, 18833, 2816727, 7778⟩ : Conv.Cnt).nn) = true
/-- The compaction map fixes the call's names. -/
theorem PRE_first_tail_x15_r0_body.cfix180 : Conv.FixOld (⟨21756, 18833, 2816727, 7778⟩ : Conv.Cnt) PRE_first_tail_x15_r0_body.kappa180 :=
  Conv.fixOld_compact (Nat.le_of_ble_eq_true PRE_first_tail_x15_r0_body.fja180) (Nat.le_of_ble_eq_true PRE_first_tail_x15_r0_body.fn180) (Nat.le_of_ble_eq_true PRE_first_tail_x15_r0_body.fjaD180) (Nat.le_of_ble_eq_true PRE_first_tail_x15_r0_body.fxn180) (Nat.le_of_ble_eq_true PRE_first_tail_x15_r0_body.fnn180) (Nat.le_of_ble_eq_true PRE_first_tail_x15_r0_body.fxb180) PRE_first_tail_x15_r0_body.fheap180 PRE_first_tail_x15_r0_body.fhnd180 PRE_first_tail_x15_r0_body.fnode180
kernel_rfl PRE_first_tail_x15_r0_body.fcxn180 : (⟨21756, 18833, 2816727, 7778⟩ : Conv.Cnt).xn = (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1741.ffi).mlx.next
kernel_rfl PRE_first_tail_x15_r0_body.fcnn180 : (⟨21756, 18833, 2816727, 7778⟩ : Conv.Cnt).nn = (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1741.ffi).mlx.nnext
kernel_rfl PRE_first_tail_x15_r0_body.fle0180 : (Nat.ble (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1741.ffi).mlx.next PRE_first_tail_x15_r0_body.cx0_180.mlx.next && Nat.ble (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1741.ffi).mlx.nnext PRE_first_tail_x15_r0_body.cx0_180.mlx.nnext && Nat.ble (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1741.ffi).mlx.next RData.bigHi) = true
kernel_rfl PRE_first_tail_x15_r0_body.fnk180 : (PTrie.keysA PRE_first_tail_x15_r0_body.kd180.node).all (Nat.ble (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1741.ffi).mlx.nnext) = true
-- the merged state keeps the call's entries off the stage's footprint
kernel_rfl PRE_first_tail_x15_r0_body.f1A180 : PRE_first_tail_x15_r0_body.cx1_180.mlx.arrs = Stage.setAll (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1741.ffi).mlx.arrs (PRE_first_tail_x15_r0_body.cwS180.filterMap fun i => (PRE_first_tail_x15_r0_body.cx1_180.mlx.arrs.get i).map (i, ·))
kernel_rfl PRE_first_tail_x15_r0_body.f1O180 : PRE_first_tail_x15_r0_body.cx1_180.mlx.objs = Stage.setAll (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1741.ffi).mlx.objs (PRE_first_tail_x15_r0_body.cwS180.filterMap fun i => (PRE_first_tail_x15_r0_body.cx1_180.mlx.objs.get i).map (i, ·))
kernel_rfl PRE_first_tail_x15_r0_body.f1N180 : PRE_first_tail_x15_r0_body.cx1_180.mlx.nodes = Stage.setAll (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1741.ffi).mlx.nodes (PRE_first_tail_x15_r0_body.cnS180.filterMap fun i => (PRE_first_tail_x15_r0_body.cx1_180.mlx.nodes.get i).map (i, ·))
kernel_rfl PRE_first_tail_x15_r0_body.f1I180 : PRE_first_tail_x15_r0_body.cx1_180.mlx.items = Stage.setAll (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1741.ffi).mlx.items (PRE_first_tail_x15_r0_body.ciS180.filterMap fun i => (PRE_first_tail_x15_r0_body.cx1_180.mlx.items.get i).map (i, ·))
kernel_rfl PRE_first_tail_x15_r0_body.fbd180 : (PRE_first_tail_x15_r0_body.clo180 ++ PRE_first_tail_x15_r0_body.cln180 ++ PRE_first_tail_x15_r0_body.cli180 ++ PRE_first_tail_x15_r0_body.cwS180 ++ PRE_first_tail_x15_r0_body.cnS180 ++ PRE_first_tail_x15_r0_body.ciS180).all (fun i => Nat.blt (i / 4096) (4 ^ 31)) = true
kernel_rfl PRE_first_tail_x15_r0_body.fincW180 : PRE_first_tail_x15_r0_body.cwS180.all (fun h => !Nat.blt h (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1741.ffi).mlx.next || PRE_first_tail_x15_r0_body.clo180.contains h) = true
kernel_rfl PRE_first_tail_x15_r0_body.fincI180 : PRE_first_tail_x15_r0_body.ciS180.all (fun k => !Nat.blt k (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1741.ffi).mlx.nnext || PRE_first_tail_x15_r0_body.cli180.contains k) = true
kernel_rfl PRE_first_tail_x15_r0_body.fincN180 : PRE_first_tail_x15_r0_body.cnS180.all (Nat.ble (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1741.ffi).mlx.nnext) = true
kernel_rfl PRE_first_tail_x15_r0_body.flnF180 : PRE_first_tail_x15_r0_body.cln180.all (Nat.ble (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1741.ffi).mlx.nnext) = true
-- the checks over the changed lists
kernel_rfl PRE_first_tail_x15_r0_body.fh180 : PRE_first_tail_x15_r0_body.clo180.all (handleOK PRE_first_tail_x15_r0_body.kappa180 PRE_first_tail_x15_r0_body.P180.lo PRE_first_tail_x15_r0_body.cx0_180.mlx PRE_first_tail_x15_r0_body.cx1_180.mlx) = true
kernel_rfl PRE_first_tail_x15_r0_body.fo180 : PRE_first_tail_x15_r0_body.clo180.map (fun h => PRE_first_tail_x15_r0_body.cx1_180.mlx.objs.get (PRE_first_tail_x15_r0_body.kappa180.handle h)) = PRE_first_tail_x15_r0_body.clo180.map (fun h => (PRE_first_tail_x15_r0_body.cx0_180.mlx.objs.get h).map PRE_first_tail_x15_r0_body.kappa180.nobj)
kernel_rfl PRE_first_tail_x15_r0_body.fok180 : PRE_first_tail_x15_r0_body.clo180.all (objOK PRE_first_tail_x15_r0_body.kappa180 PRE_first_tail_x15_r0_body.P180.NL PRE_first_tail_x15_r0_body.cx0_180.mlx) = true
kernel_rfl PRE_first_tail_x15_r0_body.fnd180 : PRE_first_tail_x15_r0_body.cln180.all (nodeOKF PRE_first_tail_x15_r0_body.kappa180 PRE_first_tail_x15_r0_body.P180 PRE_first_tail_x15_r0_body.cx0_180.mlx PRE_first_tail_x15_r0_body.cx1_180.mlx) = true
kernel_rfl PRE_first_tail_x15_r0_body.fp180 : ((PRE_first_tail_x15_r0_body.cln180.filter (fullB PRE_first_tail_x15_r0_body.P180))).map (fun i => (PRE_first_tail_x15_r0_body.cx1_180.mlx.nodes.get (PRE_first_tail_x15_r0_body.kappa180.node i)).map Host.Mlx.Ffi.Node.prim) =
  ((PRE_first_tail_x15_r0_body.cln180.filter (fullB PRE_first_tail_x15_r0_body.P180))).map (fun i => (PRE_first_tail_x15_r0_body.cx0_180.mlx.nodes.get i).map fun nd => PRE_first_tail_x15_r0_body.kappa180.prim nd.prim)
kernel_rfl PRE_first_tail_x15_r0_body.fnordI180 : incrB PRE_first_tail_x15_r0_body.kd180.nodeF (List.range' 18833 27) = true
kernel_rfl PRE_first_tail_x15_r0_body.fnordK180 : (PTrie.keysA PRE_first_tail_x15_r0_body.kd180.node).all (fun k => Nat.ble 18833 k && Nat.blt k 18860) = true
kernel_rfl PRE_first_tail_x15_r0_body.fnordL180 : (PRE_first_tail_x15_r0_body.cln180.filter (Nat.ble PRE_first_tail_x15_r0_body.P180.N0)).all (fun i => Nat.ble i (PRE_first_tail_x15_r0_body.kd180.nodeF i) && (Nat.blt i 18860 || Nat.ble PRE_first_tail_x15_r0_body.kd180.nn0 i)) = true
theorem PRE_first_tail_x15_r0_body.fnord180 : (PRE_first_tail_x15_r0_body.cln180.filter (Nat.ble PRE_first_tail_x15_r0_body.P180.N0)).all (fun i => Nat.ble i (PRE_first_tail_x15_r0_body.kd180.nodeF i) &&
    (PTrie.keysA PRE_first_tail_x15_r0_body.kd180.node).all fun j => !Nat.blt j i || Nat.blt (PRE_first_tail_x15_r0_body.kd180.nodeF j) (PRE_first_tail_x15_r0_body.kd180.nodeF i)) = true :=
  cnord_of PRE_first_tail_x15_r0_body.cnlow180 PRE_first_tail_x15_r0_body.cnn1180 PRE_first_tail_x15_r0_body.fnordI180 PRE_first_tail_x15_r0_body.fnordK180 PRE_first_tail_x15_r0_body.fnordL180
kernel_rfl PRE_first_tail_x15_r0_body.fi180 : PRE_first_tail_x15_r0_body.cli180.all (pnB PRE_first_tail_x15_r0_body.cx0_180.mlx) = true
kernel_rfl PRE_first_tail_x15_r0_body.fii180 : PRE_first_tail_x15_r0_body.cli180.all (fun k => decide (PRE_first_tail_x15_r0_body.cx1_180.mlx.items.get (PRE_first_tail_x15_r0_body.kappa180.node k) = (PRE_first_tail_x15_r0_body.cx0_180.mlx.items.get k).map PRE_first_tail_x15_r0_body.kappa180.nv)) = true
/-- **The compaction's footprint.** -/
theorem PRE_first_tail_x15_r0_body.cfoot180 (clean : Conv.NClean (⟨21756, 18833, 2816727, 7778⟩ : Conv.Cnt) (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1741.ffi).mlx) (hltC : ∀ h, PH (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1741.ffi).mlx h → h < (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1741.ffi).mlx.next) (nltC : ∀ i, PN (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1741.ffi).mlx i → i < (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1741.ffi).mlx.nnext) (itemsC : ∀ k v, (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1741.ffi).mlx.items.get k = some v → PN (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1741.ffi).mlx k) (tracedC : ∀ h o, (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1741.ffi).mlx.objs.get h = some o → ∀ i ∈ objTraces o, i < PRE_first_tail_x15_r0_body.P180.NL) (cl : SSt (· < 7796) PRE_first_tail_x15_r0_body.cx0_180.mlx) :
    Conv.MFoot PRE_first_tail_x15_r0_body.P180 7796 PRE_first_tail_x15_r0_body.kappa180 PRE_first_tail_x15_r0_body.kd180 PRE_first_tail_x15_r0_body.khinv180 PRE_first_tail_x15_r0_body.kninv180 (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1741.ffi).mlx PRE_first_tail_x15_r0_body.cx0_180.mlx PRE_first_tail_x15_r0_body.cx1_180.mlx (⟨21756, 18833, 2816727, 7778⟩ : Conv.Cnt) PRE_first_tail_x15_r0_body.clo180 PRE_first_tail_x15_r0_body.cln180 PRE_first_tail_x15_r0_body.cli180 PRE_first_tail_x15_r0_body.cwS180 PRE_first_tail_x15_r0_body.cnS180 PRE_first_tail_x15_r0_body.ciS180 :=
  ⟨rfl, rfl, rfl, PRE_first_tail_x15_r0_body.cnh0180, PRE_first_tail_x15_r0_body.cnh1180, PRE_first_tail_x15_r0_body.cnn0180, PRE_first_tail_x15_r0_body.cnn1180, PRE_first_tail_x15_r0_body.cplo180, PRE_first_tail_x15_r0_body.ccnt180, PRE_first_tail_x15_r0_body.cnband180, PRE_first_tail_x15_r0_body.chbelow180, PRE_first_tail_x15_r0_body.chren180, PRE_first_tail_x15_r0_body.cband180, PRE_first_tail_x15_r0_body.cnh1pos180, PRE_first_tail_x15_r0_body.cnren180, PRE_first_tail_x15_r0_body.cnlow180, PRE_first_tail_x15_r0_body.cabs0a180, PRE_first_tail_x15_r0_body.cabs0b180, PRE_first_tail_x15_r0_body.ctok1180, PRE_first_tail_x15_r0_body.cpend180, PRE_first_tail_x15_r0_body.cerrh180, PRE_first_tail_x15_r0_body.cfiles180, PRE_first_tail_x15_r0_body.carch180, PRE_first_tail_x15_r0_body.csizes180, PRE_first_tail_x15_r0_body.cwired180, PRE_first_tail_x15_r0_body.cfix180, clean, PRE_first_tail_x15_r0_body.fcxn180, PRE_first_tail_x15_r0_body.fcnn180, hltC, nltC, itemsC, tracedC, cl, PRE_first_tail_x15_r0_body.fle0180, PRE_first_tail_x15_r0_body.fnk180, PRE_first_tail_x15_r0_body.ckA180, PRE_first_tail_x15_r0_body.cobjsK180, PRE_first_tail_x15_r0_body.cnodesK180, PRE_first_tail_x15_r0_body.citemsK180, PRE_first_tail_x15_r0_body.f1A180, PRE_first_tail_x15_r0_body.f1O180, PRE_first_tail_x15_r0_body.f1N180, PRE_first_tail_x15_r0_body.f1I180, PRE_first_tail_x15_r0_body.fbd180, PRE_first_tail_x15_r0_body.fincW180, PRE_first_tail_x15_r0_body.fincI180, PRE_first_tail_x15_r0_body.fincN180, PRE_first_tail_x15_r0_body.flnF180, PRE_first_tail_x15_r0_body.fh180, PRE_first_tail_x15_r0_body.fo180, PRE_first_tail_x15_r0_body.fok180, PRE_first_tail_x15_r0_body.fnd180, PRE_first_tail_x15_r0_body.fp180, PRE_first_tail_x15_r0_body.fnord180, PRE_first_tail_x15_r0_body.fi180, PRE_first_tail_x15_r0_body.fii180⟩
theorem PRE_first_tail_x15_r0_body.cnshift180 (clean : Conv.NClean (⟨21756, 18833, 2816727, 7778⟩ : Conv.Cnt) (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1741.ffi).mlx) (hltC : ∀ h, PH (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1741.ffi).mlx h → h < (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1741.ffi).mlx.next) (nltC : ∀ i, PN (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1741.ffi).mlx i → i < (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1741.ffi).mlx.nnext) (itemsC : ∀ k v, (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1741.ffi).mlx.items.get k = some v → PN (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1741.ffi).mlx k) (tracedC : ∀ h o, (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1741.ffi).mlx.objs.get h = some o → ∀ i ∈ objTraces o, i < PRE_first_tail_x15_r0_body.P180.NL) (cl : SSt (· < 7796) PRE_first_tail_x15_r0_body.cx0_180.mlx) : NShift PRE_first_tail_x15_r0_body.P180 7796 PRE_first_tail_x15_r0_body.kappa180 PRE_first_tail_x15_r0_body.cx0_180 PRE_first_tail_x15_r0_body.cx1_180 :=
  Conv.nshift_of_foot (PRE_first_tail_x15_r0_body.cfoot180 clean hltC nltC itemsC tracedC cl) PRE_first_tail_x15_r0_body.chost180 (compact_a_eq PRE_first_tail_x15_r0_body.ckn0180 PRE_first_tail_x15_r0_body.ckn1180 PRE_first_tail_x15_r0_body.ckheap180 PRE_first_tail_x15_r0_body.ckpl180)

-- the observers: the layers' states at the call, the canonical and the merged state, their footprints and checks
noncomputable def PRE_first_tail_x15_r0_body.fxC_180 : PTrie Unit := (Host.Ts.Sim.Full.freedOf PRE_first_tail_x15_r0_body.s1741.ffi).getD PTrie.nil
noncomputable def PRE_first_tail_x15_r0_body.krC_180 : Host.Load.Layers.KRec := (Host.Ts.Sim.Full.krecOf PRE_first_tail_x15_r0_body.s1741.ffi).getD Host.Load.Layers.KRec.empty
kernel_rfl PRE_first_tail_x15_r0_body.ofxC_180 : (Host.Ts.Sim.Full.freedOf PRE_first_tail_x15_r0_body.s1741.ffi) = some PRE_first_tail_x15_r0_body.fxC_180
kernel_rfl PRE_first_tail_x15_r0_body.okrC_180 : (Host.Ts.Sim.Full.krecOf PRE_first_tail_x15_r0_body.s1741.ffi) = some PRE_first_tail_x15_r0_body.krC_180
noncomputable def PRE_first_tail_x15_r0_body.fx0_180 : PTrie Unit := (Host.Ts.Sim.Full.freedOf PRE_first_tail_x15_r0_body.s1743.ffi).getD PTrie.nil
noncomputable def PRE_first_tail_x15_r0_body.kr0_180 : Host.Load.Layers.KRec := (Host.Ts.Sim.Full.krecOf PRE_first_tail_x15_r0_body.s1743.ffi).getD Host.Load.Layers.KRec.empty
kernel_rfl PRE_first_tail_x15_r0_body.ofx0_180 : (Host.Ts.Sim.Full.freedOf PRE_first_tail_x15_r0_body.s1743.ffi) = some PRE_first_tail_x15_r0_body.fx0_180
kernel_rfl PRE_first_tail_x15_r0_body.okr0_180 : (Host.Ts.Sim.Full.krecOf PRE_first_tail_x15_r0_body.s1743.ffi) = some PRE_first_tail_x15_r0_body.kr0_180
noncomputable def PRE_first_tail_x15_r0_body.fx1_180 : PTrie Unit := (Host.Ts.Sim.Full.freedOf PRE_first_tail_x15_r0_body.s1742.ffi).getD PTrie.nil
noncomputable def PRE_first_tail_x15_r0_body.kr1_180 : Host.Load.Layers.KRec := (Host.Ts.Sim.Full.krecOf PRE_first_tail_x15_r0_body.s1742.ffi).getD Host.Load.Layers.KRec.empty
kernel_rfl PRE_first_tail_x15_r0_body.ofx1_180 : (Host.Ts.Sim.Full.freedOf PRE_first_tail_x15_r0_body.s1742.ffi) = some PRE_first_tail_x15_r0_body.fx1_180
kernel_rfl PRE_first_tail_x15_r0_body.okr1_180 : (Host.Ts.Sim.Full.krecOf PRE_first_tail_x15_r0_body.s1742.ffi) = some PRE_first_tail_x15_r0_body.kr1_180
kernel_rfl PRE_first_tail_x15_r0_body.ff0180 : PRE_first_tail_x15_r0_body.fx0_180 = Stage.setAll PRE_first_tail_x15_r0_body.fxC_180 (PRE_first_tail_x15_r0_body.clo180.filterMap fun i => (PRE_first_tail_x15_r0_body.fx0_180.get i).map (i, ·))
kernel_rfl PRE_first_tail_x15_r0_body.ff1180 : PRE_first_tail_x15_r0_body.fx1_180 = Stage.setAll PRE_first_tail_x15_r0_body.fxC_180 (PRE_first_tail_x15_r0_body.cwS180.filterMap fun i => (PRE_first_tail_x15_r0_body.fx1_180.get i).map (i, ·))
kernel_rfl PRE_first_tail_x15_r0_body.ffck180 : freedLB PRE_first_tail_x15_r0_body.kappa180 PRE_first_tail_x15_r0_body.cx0_180.mlx PRE_first_tail_x15_r0_body.fx0_180 PRE_first_tail_x15_r0_body.fx1_180 PRE_first_tail_x15_r0_body.clo180 = true
kernel_rfl PRE_first_tail_x15_r0_body.fkf0180 : PRE_first_tail_x15_r0_body.kr0_180.flags = Stage.setAll PRE_first_tail_x15_r0_body.krC_180.flags (PRE_first_tail_x15_r0_body.clo180.filterMap fun i => (PRE_first_tail_x15_r0_body.kr0_180.flags.get i).map (i, ·))
kernel_rfl PRE_first_tail_x15_r0_body.fkt0180 : PRE_first_tail_x15_r0_body.kr0_180.targs = Stage.setAll PRE_first_tail_x15_r0_body.krC_180.targs (PRE_first_tail_x15_r0_body.clo180.filterMap fun i => (PRE_first_tail_x15_r0_body.kr0_180.targs.get i).map (i, ·))
kernel_rfl PRE_first_tail_x15_r0_body.fkf1180 : PRE_first_tail_x15_r0_body.kr1_180.flags = Stage.setAll PRE_first_tail_x15_r0_body.krC_180.flags (PRE_first_tail_x15_r0_body.cwS180.filterMap fun i => (PRE_first_tail_x15_r0_body.kr1_180.flags.get i).map (i, ·))
kernel_rfl PRE_first_tail_x15_r0_body.fkt1180 : PRE_first_tail_x15_r0_body.kr1_180.targs = Stage.setAll PRE_first_tail_x15_r0_body.krC_180.targs (PRE_first_tail_x15_r0_body.cwS180.filterMap fun i => (PRE_first_tail_x15_r0_body.kr1_180.targs.get i).map (i, ·))
kernel_rfl PRE_first_tail_x15_r0_body.fkck180 : krecLB PRE_first_tail_x15_r0_body.kappa180 7796 PRE_first_tail_x15_r0_body.cx0_180.mlx PRE_first_tail_x15_r0_body.kr0_180 PRE_first_tail_x15_r0_body.kr1_180 PRE_first_tail_x15_r0_body.clo180 = true
kernel_rfl PRE_first_tail_x15_r0_body.fkn180 : Nat.ble 7778 7796 = true
-- the bridge and the pending traces' regions
kernel_rfl PRE_first_tail_x15_r0_body.cbridge180 : Host.Ts.Sim.Full.bridgeOf PRE_first_tail_x15_r0_body.s1742.ffi = Host.Ts.Sim.Full.bridgeOf PRE_first_tail_x15_r0_body.s1743.ffi
kernel_rfl PRE_first_tail_x15_r0_body.cpendR180 : pendRegB PRE_first_tail_x15_r0_body.kappa180 (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1743.ffi).mlx = true
kernel_rfl PRE_first_tail_x15_r0_body.cpendLe180 : Nat.ble (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1743.ffi).mlx.next (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1742.ffi).mlx.next = true
/-- **The compaction's native shift**, given the call's bookkeeping, its relation's facts (the model's and the
observers') and the canonical closedness. -/
theorem PRE_first_tail_x15_r0_body.cshift180 (clean : Conv.NClean (⟨21756, 18833, 2816727, 7778⟩ : Conv.Cnt) (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1741.ffi).mlx) (hltC : ∀ h, PH (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1741.ffi).mlx h → h < (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1741.ffi).mlx.next) (nltC : ∀ i, PN (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1741.ffi).mlx i → i < (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1741.ffi).mlx.nnext) (itemsC : ∀ k v, (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1741.ffi).mlx.items.get k = some v → PN (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1741.ffi).mlx k) (tracedC : ∀ h o, (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1741.ffi).mlx.objs.get h = some o → ∀ i ∈ objTraces o, i < PRE_first_tail_x15_r0_body.P180.NL) (cl : SSt (· < 7796) PRE_first_tail_x15_r0_body.cx0_180.mlx)
    (hobjC : ∀ h, PRE_first_tail_x15_r0_body.fxC_180.get h = some () → ((Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1741.ffi).mlx.objs.get h).isSome = true)
    (hfC : ∀ h, (PRE_first_tail_x15_r0_body.krC_180.flags.get h).isSome = true → ((Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1741.ffi).mlx.objs.get h).isSome = true)
    (htC : ∀ h, (PRE_first_tail_x15_r0_body.krC_180.targs.get h).isSome = true → ((Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1741.ffi).mlx.objs.get h).isSome = true)
    (hclC : ∀ h l, PRE_first_tail_x15_r0_body.krC_180.targs.get h = some l → Host.Ts.Sim.Full.STargs (· < (⟨21756, 18833, 2816727, 7778⟩ : Conv.Cnt).n) l) :
    Conv.FullShiftQ PRE_first_tail_x15_r0_body.P180 7796 PRE_first_tail_x15_r0_body.kappa180 PRE_first_tail_x15_r0_body.s1743.ffi PRE_first_tail_x15_r0_body.s1742.ffi :=
  ⟨PRE_first_tail_x15_r0_body.cnshift180 clean hltC nltC itemsC tracedC cl, PRE_first_tail_x15_r0_body.cqueue180, fun t ht => bSN_sound (List.all_eq_true.mp PRE_first_tail_x15_r0_body.ctokSupp180 t ht),
    PRE_first_tail_x15_r0_body.cbridge180,
    liveShift_foot (x0' := Host.Ts.Sim.Full.mlxOf PRE_first_tail_x15_r0_body.s1743.ffi) (x1' := Host.Ts.Sim.Full.mlxOf PRE_first_tail_x15_r0_body.s1742.ffi) (PRE_first_tail_x15_r0_body.cfoot180 clean hltC nltC itemsC tracedC cl) rfl PRE_first_tail_x15_r0_body.ofx0_180 PRE_first_tail_x15_r0_body.ofx1_180 hobjC PRE_first_tail_x15_r0_body.ff0180 PRE_first_tail_x15_r0_body.ff1180 PRE_first_tail_x15_r0_body.ffck180,
    kernShift_foot (x0' := Host.Ts.Sim.Full.mlxOf PRE_first_tail_x15_r0_body.s1743.ffi) (x1' := Host.Ts.Sim.Full.mlxOf PRE_first_tail_x15_r0_body.s1742.ffi) (PRE_first_tail_x15_r0_body.cfoot180 clean hltC nltC itemsC tracedC cl) rfl PRE_first_tail_x15_r0_body.okr0_180 PRE_first_tail_x15_r0_body.okr1_180 (Nat.le_of_ble_eq_true PRE_first_tail_x15_r0_body.fkn180) hfC htC hclC
      PRE_first_tail_x15_r0_body.fkf0180 PRE_first_tail_x15_r0_body.fkt0180 PRE_first_tail_x15_r0_body.fkf1180 PRE_first_tail_x15_r0_body.fkt1180 PRE_first_tail_x15_r0_body.fkck180,
    pendReg_of rfl PRE_first_tail_x15_r0_body.cnh0180 PRE_first_tail_x15_r0_body.cnh1180 (Nat.le_of_ble_eq_true PRE_first_tail_x15_r0_body.cpendLe180) PRE_first_tail_x15_r0_body.cpendR180⟩

end Host.Load.Run.Tpl
