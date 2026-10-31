import host.sim.template.a4pre_first_tail_x15_r0_body.SiteCl126
import host.sim.conv.CompactFull
import host.sim.template.FootGen
set_option Elab.async false
namespace Host.Load.Run.Tpl
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
open Host.Ts Host.Ts.Sim Host.Ts.Sim.Template

/-! The compaction's native shift at call site 126 from its footprint (`Conv.nshift_of_foot`), and the observers'
(`liveShift_foot`, `kernShift_foot`): `Conv.FullShiftQ` for `Conv.full_compactQ`, given the call's bookkeeping and its
relation's facts. -/

/-- The load parameters of the chain (band-free: its start's node counter as `NL` and `N0`). -/
def PRE_first_tail_x15_r0_body.Pc126 : LoadP := ⟨18151, 131072, 1099511627776, 15235, 15235, []⟩
/-- The site's band raised to the map's checked fixed-node prefix, including newly recorded closure traces. -/
def PRE_first_tail_x15_r0_body.P126 : LoadP := PRE_first_tail_x15_r0_body.Pc126.raise 17801
kernel_rfl PRE_first_tail_x15_r0_body.craise126 : Nat.ble PRE_first_tail_x15_r0_body.Pc126.N0 17801 = true
theorem PRE_first_tail_x15_r0_body.raised126 : Host.Ts.Sim.Full.Raised PRE_first_tail_x15_r0_body.Pc126 PRE_first_tail_x15_r0_body.P126 :=
  .inr ⟨17801, rfl, Nat.le_of_ble_eq_true PRE_first_tail_x15_r0_body.craise126, rfl⟩
noncomputable abbrev PRE_first_tail_x15_r0_body.cx0_126 : Host.Load.LSt := clearTokens (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1120.ffi)
noncomputable abbrev PRE_first_tail_x15_r0_body.cx1_126 : Host.Load.LSt := clearTokens (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1119.ffi)
def PRE_first_tail_x15_r0_body.khinv126 : PTrie Nat := Stage.setAll PTrie.nil [(20716, 20690), (20694, 20691), (20717, 20692)]
def PRE_first_tail_x15_r0_body.kninv126 : PTrie Nat := Stage.setAll PTrie.nil [(17774, 17774), (17775, 17775), (17776, 17776), (17777, 17777), (17778, 17778), (17779, 17779), (17780, 17780), (17781, 17781), (17782, 17782), (17783, 17783), (17784, 17784), (17785, 17785), (17786, 17786), (17787, 17787), (17788, 17788), (17789, 17789), (17790, 17790), (17791, 17791), (17792, 17792), (17793, 17793), (17794, 17794), (17795, 17795), (17796, 17796), (17797, 17797), (17798, 17798), (17799, 17799), (17800, 17800)]
/-- The stage's footprint: its written and fresh handles, fresh nodes, written and fresh items. -/
def PRE_first_tail_x15_r0_body.cwS126 : List Nat := [20670, 20683, 20689, 20690, 20691, 20692, 20693, 20694, 20695, 20696, 20697, 20698, 20699, 20700, 20701, 20702, 20703, 20704, 20705, 20706, 20707, 20708, 20709, 20710, 20711, 20712, 20713, 20714, 20715, 20716, 20717]
def PRE_first_tail_x15_r0_body.cnS126 : List Nat := List.range' 17774 27
def PRE_first_tail_x15_r0_body.ciS126 : List Nat := [] ++ List.range' 17774 27

-- the small checks (`MChecks`'s)
kernel_rfl PRE_first_tail_x15_r0_body.cnh0126 : PRE_first_tail_x15_r0_body.kd126.nh0 = PRE_first_tail_x15_r0_body.cx0_126.mlx.next
kernel_rfl PRE_first_tail_x15_r0_body.cnh1126 : PRE_first_tail_x15_r0_body.kd126.nh1 = PRE_first_tail_x15_r0_body.cx1_126.mlx.next
kernel_rfl PRE_first_tail_x15_r0_body.cnn0126 : PRE_first_tail_x15_r0_body.kd126.nn0 = PRE_first_tail_x15_r0_body.cx0_126.mlx.nnext
kernel_rfl PRE_first_tail_x15_r0_body.cnn1126 : PRE_first_tail_x15_r0_body.kd126.nn1 = PRE_first_tail_x15_r0_body.cx1_126.mlx.nnext
kernel_rfl PRE_first_tail_x15_r0_body.cplo126 : (Nat.blt 0 PRE_first_tail_x15_r0_body.P126.lo && Nat.ble PRE_first_tail_x15_r0_body.P126.lo PRE_first_tail_x15_r0_body.cx0_126.mlx.next && Nat.ble PRE_first_tail_x15_r0_body.P126.lo RData.bigHi && Nat.ble RData.bigHi PRE_first_tail_x15_r0_body.P126.E) = true
kernel_rfl PRE_first_tail_x15_r0_body.ccnt126 : (Nat.ble PRE_first_tail_x15_r0_body.cx0_126.mlx.next PRE_first_tail_x15_r0_body.cx1_126.mlx.next && Nat.ble PRE_first_tail_x15_r0_body.cx0_126.mlx.nnext PRE_first_tail_x15_r0_body.cx1_126.mlx.nnext) = true
kernel_rfl PRE_first_tail_x15_r0_body.cnband126 : (Nat.blt 0 PRE_first_tail_x15_r0_body.P126.NL && Nat.ble PRE_first_tail_x15_r0_body.P126.NL PRE_first_tail_x15_r0_body.P126.N0 && Nat.ble PRE_first_tail_x15_r0_body.P126.N0 PRE_first_tail_x15_r0_body.cx0_126.mlx.nnext) = true
kernel_rfl PRE_first_tail_x15_r0_body.chbelow126 : PRE_first_tail_x15_r0_body.kd126.checkHndBelow = true
kernel_rfl PRE_first_tail_x15_r0_body.chren126 : checkRenG PRE_first_tail_x15_r0_body.kd126.hnd PRE_first_tail_x15_r0_body.khinv126 (phB PRE_first_tail_x15_r0_body.cx0_126.mlx) = true
kernel_rfl PRE_first_tail_x15_r0_body.cband126 : PRE_first_tail_x15_r0_body.kd126.checkBand PRE_first_tail_x15_r0_body.P126.lo = true
kernel_rfl PRE_first_tail_x15_r0_body.cnh1pos126 : Nat.blt 0 PRE_first_tail_x15_r0_body.kd126.nh1 = true
kernel_rfl PRE_first_tail_x15_r0_body.cnren126 : checkRenG PRE_first_tail_x15_r0_body.kd126.node PRE_first_tail_x15_r0_body.kninv126 (pnB PRE_first_tail_x15_r0_body.cx0_126.mlx) = true
kernel_rfl PRE_first_tail_x15_r0_body.cnlow126 : (PTrie.keysA PRE_first_tail_x15_r0_body.kd126.node).all (fun j => Nat.ble PRE_first_tail_x15_r0_body.P126.NL j && Nat.blt (PRE_first_tail_x15_r0_body.kd126.nodeF j) PRE_first_tail_x15_r0_body.cx1_126.mlx.nnext) = true
kernel_rfl PRE_first_tail_x15_r0_body.cabs0a126 : PRE_first_tail_x15_r0_body.cx0_126.mlx.arrs.get 0 = none
kernel_rfl PRE_first_tail_x15_r0_body.cabs0b126 : PRE_first_tail_x15_r0_body.cx0_126.mlx.objs.get 0 = none
kernel_rfl PRE_first_tail_x15_r0_body.ctok1126 : PRE_first_tail_x15_r0_body.cx1_126.mlx.tokens = []
kernel_rfl PRE_first_tail_x15_r0_body.cpend126 : PRE_first_tail_x15_r0_body.cx1_126.mlx.pending = PRE_first_tail_x15_r0_body.cx0_126.mlx.pending.map PRE_first_tail_x15_r0_body.kappa126.pend
kernel_rfl PRE_first_tail_x15_r0_body.cerrh126 : PRE_first_tail_x15_r0_body.cx1_126.mlx.errh = PRE_first_tail_x15_r0_body.cx0_126.mlx.errh.map PRE_first_tail_x15_r0_body.kappa126.arg
kernel_rfl PRE_first_tail_x15_r0_body.cfiles126 : PRE_first_tail_x15_r0_body.cx1_126.mlx.files = PRE_first_tail_x15_r0_body.cx0_126.mlx.files
kernel_rfl PRE_first_tail_x15_r0_body.carch126 : PRE_first_tail_x15_r0_body.cx1_126.mlx.arch = PRE_first_tail_x15_r0_body.cx0_126.mlx.arch
kernel_rfl PRE_first_tail_x15_r0_body.csizes126 : PRE_first_tail_x15_r0_body.cx1_126.mlx.deviceSizes = PRE_first_tail_x15_r0_body.cx0_126.mlx.deviceSizes
kernel_rfl PRE_first_tail_x15_r0_body.cwired126 : PRE_first_tail_x15_r0_body.cx1_126.mlx.wired = PRE_first_tail_x15_r0_body.cx0_126.mlx.wired
kernel_rfl PRE_first_tail_x15_r0_body.chost126 : PRE_first_tail_x15_r0_body.cx1_126.host = PRE_first_tail_x15_r0_body.cx0_126.host
-- the compaction map's addresses are `PRE_first_tail_x15_r0_body.kd126`'s
kernel_rfl PRE_first_tail_x15_r0_body.ckn0126 : PRE_first_tail_x15_r0_body.kd126.n0 = 2774141
kernel_rfl PRE_first_tail_x15_r0_body.ckn1126 : PRE_first_tail_x15_r0_body.kd126.n1 = 2775290
kernel_rfl PRE_first_tail_x15_r0_body.ckheap126 : (PTrie.keysA PRE_first_tail_x15_r0_body.kd126.heap).all (fun x => Nat.ble 2774135 x) = true
kernel_rfl PRE_first_tail_x15_r0_body.ckpl126 : (List.range 6).all (fun j => decide (PRE_first_tail_x15_r0_body.kd126.heap.get (2774135 + j) = nth? PRE_first_tail_x15_r0_body.pl126 j)) = true
-- the map fixes the call's names (`Conv.fixOld_compact`), the call's counters
kernel_rfl PRE_first_tail_x15_r0_body.fja126 : Nat.ble 2774135 2774135 = true
kernel_rfl PRE_first_tail_x15_r0_body.fn126 : Nat.ble 5471 5471 = true
kernel_rfl PRE_first_tail_x15_r0_body.fjaD126 : Nat.ble 2774135 PRE_first_tail_x15_r0_body.kd126.n0 = true
kernel_rfl PRE_first_tail_x15_r0_body.fxn126 : Nat.ble 20690 PRE_first_tail_x15_r0_body.kd126.nh0 = true
kernel_rfl PRE_first_tail_x15_r0_body.fnn126 : Nat.ble 17774 PRE_first_tail_x15_r0_body.kd126.nn0 = true
kernel_rfl PRE_first_tail_x15_r0_body.fxb126 : Nat.ble 20690 RData.bigHi = true
kernel_rfl PRE_first_tail_x15_r0_body.fheap126 : (PTrie.keysA PRE_first_tail_x15_r0_body.kd126.heap).all (Nat.ble (⟨20690, 17774, 2774135, 5471⟩ : Conv.Cnt).ja) = true
kernel_rfl PRE_first_tail_x15_r0_body.fhnd126 : (PTrie.keysA PRE_first_tail_x15_r0_body.kd126.hnd).all (Nat.ble (⟨20690, 17774, 2774135, 5471⟩ : Conv.Cnt).xn) = true
kernel_rfl PRE_first_tail_x15_r0_body.fnode126 : (PTrie.keysA PRE_first_tail_x15_r0_body.kd126.node).all (Nat.ble (⟨20690, 17774, 2774135, 5471⟩ : Conv.Cnt).nn) = true
/-- The compaction map fixes the call's names. -/
theorem PRE_first_tail_x15_r0_body.cfix126 : Conv.FixOld (⟨20690, 17774, 2774135, 5471⟩ : Conv.Cnt) PRE_first_tail_x15_r0_body.kappa126 :=
  Conv.fixOld_compact (Nat.le_of_ble_eq_true PRE_first_tail_x15_r0_body.fja126) (Nat.le_of_ble_eq_true PRE_first_tail_x15_r0_body.fn126) (Nat.le_of_ble_eq_true PRE_first_tail_x15_r0_body.fjaD126) (Nat.le_of_ble_eq_true PRE_first_tail_x15_r0_body.fxn126) (Nat.le_of_ble_eq_true PRE_first_tail_x15_r0_body.fnn126) (Nat.le_of_ble_eq_true PRE_first_tail_x15_r0_body.fxb126) PRE_first_tail_x15_r0_body.fheap126 PRE_first_tail_x15_r0_body.fhnd126 PRE_first_tail_x15_r0_body.fnode126
kernel_rfl PRE_first_tail_x15_r0_body.fcxn126 : (⟨20690, 17774, 2774135, 5471⟩ : Conv.Cnt).xn = (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1118.ffi).mlx.next
kernel_rfl PRE_first_tail_x15_r0_body.fcnn126 : (⟨20690, 17774, 2774135, 5471⟩ : Conv.Cnt).nn = (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1118.ffi).mlx.nnext
kernel_rfl PRE_first_tail_x15_r0_body.fle0126 : (Nat.ble (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1118.ffi).mlx.next PRE_first_tail_x15_r0_body.cx0_126.mlx.next && Nat.ble (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1118.ffi).mlx.nnext PRE_first_tail_x15_r0_body.cx0_126.mlx.nnext && Nat.ble (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1118.ffi).mlx.next RData.bigHi) = true
kernel_rfl PRE_first_tail_x15_r0_body.fnk126 : (PTrie.keysA PRE_first_tail_x15_r0_body.kd126.node).all (Nat.ble (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1118.ffi).mlx.nnext) = true
-- the merged state keeps the call's entries off the stage's footprint
kernel_rfl PRE_first_tail_x15_r0_body.f1A126 : PRE_first_tail_x15_r0_body.cx1_126.mlx.arrs = Stage.setAll (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1118.ffi).mlx.arrs (PRE_first_tail_x15_r0_body.cwS126.filterMap fun i => (PRE_first_tail_x15_r0_body.cx1_126.mlx.arrs.get i).map (i, ·))
kernel_rfl PRE_first_tail_x15_r0_body.f1O126 : PRE_first_tail_x15_r0_body.cx1_126.mlx.objs = Stage.setAll (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1118.ffi).mlx.objs (PRE_first_tail_x15_r0_body.cwS126.filterMap fun i => (PRE_first_tail_x15_r0_body.cx1_126.mlx.objs.get i).map (i, ·))
kernel_rfl PRE_first_tail_x15_r0_body.f1N126 : PRE_first_tail_x15_r0_body.cx1_126.mlx.nodes = Stage.setAll (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1118.ffi).mlx.nodes (PRE_first_tail_x15_r0_body.cnS126.filterMap fun i => (PRE_first_tail_x15_r0_body.cx1_126.mlx.nodes.get i).map (i, ·))
kernel_rfl PRE_first_tail_x15_r0_body.f1I126 : PRE_first_tail_x15_r0_body.cx1_126.mlx.items = Stage.setAll (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1118.ffi).mlx.items (PRE_first_tail_x15_r0_body.ciS126.filterMap fun i => (PRE_first_tail_x15_r0_body.cx1_126.mlx.items.get i).map (i, ·))
kernel_rfl PRE_first_tail_x15_r0_body.fbd126 : (PRE_first_tail_x15_r0_body.clo126 ++ PRE_first_tail_x15_r0_body.cln126 ++ PRE_first_tail_x15_r0_body.cli126 ++ PRE_first_tail_x15_r0_body.cwS126 ++ PRE_first_tail_x15_r0_body.cnS126 ++ PRE_first_tail_x15_r0_body.ciS126).all (fun i => Nat.blt (i / 4096) (4 ^ 31)) = true
kernel_rfl PRE_first_tail_x15_r0_body.fincW126 : PRE_first_tail_x15_r0_body.cwS126.all (fun h => !Nat.blt h (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1118.ffi).mlx.next || PRE_first_tail_x15_r0_body.clo126.contains h) = true
kernel_rfl PRE_first_tail_x15_r0_body.fincI126 : PRE_first_tail_x15_r0_body.ciS126.all (fun k => !Nat.blt k (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1118.ffi).mlx.nnext || PRE_first_tail_x15_r0_body.cli126.contains k) = true
kernel_rfl PRE_first_tail_x15_r0_body.fincN126 : PRE_first_tail_x15_r0_body.cnS126.all (Nat.ble (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1118.ffi).mlx.nnext) = true
kernel_rfl PRE_first_tail_x15_r0_body.flnF126 : PRE_first_tail_x15_r0_body.cln126.all (Nat.ble (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1118.ffi).mlx.nnext) = true
-- the checks over the changed lists
kernel_rfl PRE_first_tail_x15_r0_body.fh126 : PRE_first_tail_x15_r0_body.clo126.all (handleOK PRE_first_tail_x15_r0_body.kappa126 PRE_first_tail_x15_r0_body.P126.lo PRE_first_tail_x15_r0_body.cx0_126.mlx PRE_first_tail_x15_r0_body.cx1_126.mlx) = true
kernel_rfl PRE_first_tail_x15_r0_body.fo126 : PRE_first_tail_x15_r0_body.clo126.map (fun h => PRE_first_tail_x15_r0_body.cx1_126.mlx.objs.get (PRE_first_tail_x15_r0_body.kappa126.handle h)) = PRE_first_tail_x15_r0_body.clo126.map (fun h => (PRE_first_tail_x15_r0_body.cx0_126.mlx.objs.get h).map PRE_first_tail_x15_r0_body.kappa126.nobj)
kernel_rfl PRE_first_tail_x15_r0_body.fok126 : PRE_first_tail_x15_r0_body.clo126.all (objOK PRE_first_tail_x15_r0_body.kappa126 PRE_first_tail_x15_r0_body.P126.NL PRE_first_tail_x15_r0_body.cx0_126.mlx) = true
kernel_rfl PRE_first_tail_x15_r0_body.fnd126 : PRE_first_tail_x15_r0_body.cln126.all (nodeOKF PRE_first_tail_x15_r0_body.kappa126 PRE_first_tail_x15_r0_body.P126 PRE_first_tail_x15_r0_body.cx0_126.mlx PRE_first_tail_x15_r0_body.cx1_126.mlx) = true
kernel_rfl PRE_first_tail_x15_r0_body.fp126 : ((PRE_first_tail_x15_r0_body.cln126.filter (fullB PRE_first_tail_x15_r0_body.P126))).map (fun i => (PRE_first_tail_x15_r0_body.cx1_126.mlx.nodes.get (PRE_first_tail_x15_r0_body.kappa126.node i)).map Host.Mlx.Ffi.Node.prim) =
  ((PRE_first_tail_x15_r0_body.cln126.filter (fullB PRE_first_tail_x15_r0_body.P126))).map (fun i => (PRE_first_tail_x15_r0_body.cx0_126.mlx.nodes.get i).map fun nd => PRE_first_tail_x15_r0_body.kappa126.prim nd.prim)
kernel_rfl PRE_first_tail_x15_r0_body.fnordI126 : incrB PRE_first_tail_x15_r0_body.kd126.nodeF (List.range' 17774 27) = true
kernel_rfl PRE_first_tail_x15_r0_body.fnordK126 : (PTrie.keysA PRE_first_tail_x15_r0_body.kd126.node).all (fun k => Nat.ble 17774 k && Nat.blt k 17801) = true
kernel_rfl PRE_first_tail_x15_r0_body.fnordL126 : (PRE_first_tail_x15_r0_body.cln126.filter (Nat.ble PRE_first_tail_x15_r0_body.P126.N0)).all (fun i => Nat.ble i (PRE_first_tail_x15_r0_body.kd126.nodeF i) && (Nat.blt i 17801 || Nat.ble PRE_first_tail_x15_r0_body.kd126.nn0 i)) = true
theorem PRE_first_tail_x15_r0_body.fnord126 : (PRE_first_tail_x15_r0_body.cln126.filter (Nat.ble PRE_first_tail_x15_r0_body.P126.N0)).all (fun i => Nat.ble i (PRE_first_tail_x15_r0_body.kd126.nodeF i) &&
    (PTrie.keysA PRE_first_tail_x15_r0_body.kd126.node).all fun j => !Nat.blt j i || Nat.blt (PRE_first_tail_x15_r0_body.kd126.nodeF j) (PRE_first_tail_x15_r0_body.kd126.nodeF i)) = true :=
  cnord_of PRE_first_tail_x15_r0_body.cnlow126 PRE_first_tail_x15_r0_body.cnn1126 PRE_first_tail_x15_r0_body.fnordI126 PRE_first_tail_x15_r0_body.fnordK126 PRE_first_tail_x15_r0_body.fnordL126
kernel_rfl PRE_first_tail_x15_r0_body.fi126 : PRE_first_tail_x15_r0_body.cli126.all (pnB PRE_first_tail_x15_r0_body.cx0_126.mlx) = true
kernel_rfl PRE_first_tail_x15_r0_body.fii126 : PRE_first_tail_x15_r0_body.cli126.all (fun k => decide (PRE_first_tail_x15_r0_body.cx1_126.mlx.items.get (PRE_first_tail_x15_r0_body.kappa126.node k) = (PRE_first_tail_x15_r0_body.cx0_126.mlx.items.get k).map PRE_first_tail_x15_r0_body.kappa126.nv)) = true
/-- **The compaction's footprint.** -/
theorem PRE_first_tail_x15_r0_body.cfoot126 (clean : Conv.NClean (⟨20690, 17774, 2774135, 5471⟩ : Conv.Cnt) (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1118.ffi).mlx) (hltC : ∀ h, PH (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1118.ffi).mlx h → h < (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1118.ffi).mlx.next) (nltC : ∀ i, PN (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1118.ffi).mlx i → i < (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1118.ffi).mlx.nnext) (itemsC : ∀ k v, (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1118.ffi).mlx.items.get k = some v → PN (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1118.ffi).mlx k) (tracedC : ∀ h o, (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1118.ffi).mlx.objs.get h = some o → ∀ i ∈ objTraces o, i < PRE_first_tail_x15_r0_body.P126.NL) (cl : SSt (· < 5489) PRE_first_tail_x15_r0_body.cx0_126.mlx) :
    Conv.MFoot PRE_first_tail_x15_r0_body.P126 5489 PRE_first_tail_x15_r0_body.kappa126 PRE_first_tail_x15_r0_body.kd126 PRE_first_tail_x15_r0_body.khinv126 PRE_first_tail_x15_r0_body.kninv126 (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1118.ffi).mlx PRE_first_tail_x15_r0_body.cx0_126.mlx PRE_first_tail_x15_r0_body.cx1_126.mlx (⟨20690, 17774, 2774135, 5471⟩ : Conv.Cnt) PRE_first_tail_x15_r0_body.clo126 PRE_first_tail_x15_r0_body.cln126 PRE_first_tail_x15_r0_body.cli126 PRE_first_tail_x15_r0_body.cwS126 PRE_first_tail_x15_r0_body.cnS126 PRE_first_tail_x15_r0_body.ciS126 :=
  ⟨rfl, rfl, rfl, PRE_first_tail_x15_r0_body.cnh0126, PRE_first_tail_x15_r0_body.cnh1126, PRE_first_tail_x15_r0_body.cnn0126, PRE_first_tail_x15_r0_body.cnn1126, PRE_first_tail_x15_r0_body.cplo126, PRE_first_tail_x15_r0_body.ccnt126, PRE_first_tail_x15_r0_body.cnband126, PRE_first_tail_x15_r0_body.chbelow126, PRE_first_tail_x15_r0_body.chren126, PRE_first_tail_x15_r0_body.cband126, PRE_first_tail_x15_r0_body.cnh1pos126, PRE_first_tail_x15_r0_body.cnren126, PRE_first_tail_x15_r0_body.cnlow126, PRE_first_tail_x15_r0_body.cabs0a126, PRE_first_tail_x15_r0_body.cabs0b126, PRE_first_tail_x15_r0_body.ctok1126, PRE_first_tail_x15_r0_body.cpend126, PRE_first_tail_x15_r0_body.cerrh126, PRE_first_tail_x15_r0_body.cfiles126, PRE_first_tail_x15_r0_body.carch126, PRE_first_tail_x15_r0_body.csizes126, PRE_first_tail_x15_r0_body.cwired126, PRE_first_tail_x15_r0_body.cfix126, clean, PRE_first_tail_x15_r0_body.fcxn126, PRE_first_tail_x15_r0_body.fcnn126, hltC, nltC, itemsC, tracedC, cl, PRE_first_tail_x15_r0_body.fle0126, PRE_first_tail_x15_r0_body.fnk126, PRE_first_tail_x15_r0_body.ckA126, PRE_first_tail_x15_r0_body.cobjsK126, PRE_first_tail_x15_r0_body.cnodesK126, PRE_first_tail_x15_r0_body.citemsK126, PRE_first_tail_x15_r0_body.f1A126, PRE_first_tail_x15_r0_body.f1O126, PRE_first_tail_x15_r0_body.f1N126, PRE_first_tail_x15_r0_body.f1I126, PRE_first_tail_x15_r0_body.fbd126, PRE_first_tail_x15_r0_body.fincW126, PRE_first_tail_x15_r0_body.fincI126, PRE_first_tail_x15_r0_body.fincN126, PRE_first_tail_x15_r0_body.flnF126, PRE_first_tail_x15_r0_body.fh126, PRE_first_tail_x15_r0_body.fo126, PRE_first_tail_x15_r0_body.fok126, PRE_first_tail_x15_r0_body.fnd126, PRE_first_tail_x15_r0_body.fp126, PRE_first_tail_x15_r0_body.fnord126, PRE_first_tail_x15_r0_body.fi126, PRE_first_tail_x15_r0_body.fii126⟩
theorem PRE_first_tail_x15_r0_body.cnshift126 (clean : Conv.NClean (⟨20690, 17774, 2774135, 5471⟩ : Conv.Cnt) (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1118.ffi).mlx) (hltC : ∀ h, PH (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1118.ffi).mlx h → h < (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1118.ffi).mlx.next) (nltC : ∀ i, PN (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1118.ffi).mlx i → i < (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1118.ffi).mlx.nnext) (itemsC : ∀ k v, (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1118.ffi).mlx.items.get k = some v → PN (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1118.ffi).mlx k) (tracedC : ∀ h o, (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1118.ffi).mlx.objs.get h = some o → ∀ i ∈ objTraces o, i < PRE_first_tail_x15_r0_body.P126.NL) (cl : SSt (· < 5489) PRE_first_tail_x15_r0_body.cx0_126.mlx) : NShift PRE_first_tail_x15_r0_body.P126 5489 PRE_first_tail_x15_r0_body.kappa126 PRE_first_tail_x15_r0_body.cx0_126 PRE_first_tail_x15_r0_body.cx1_126 :=
  Conv.nshift_of_foot (PRE_first_tail_x15_r0_body.cfoot126 clean hltC nltC itemsC tracedC cl) PRE_first_tail_x15_r0_body.chost126 (compact_a_eq PRE_first_tail_x15_r0_body.ckn0126 PRE_first_tail_x15_r0_body.ckn1126 PRE_first_tail_x15_r0_body.ckheap126 PRE_first_tail_x15_r0_body.ckpl126)

-- the observers: the layers' states at the call, the canonical and the merged state, their footprints and checks
noncomputable def PRE_first_tail_x15_r0_body.fxC_126 : PTrie Unit := (Host.Ts.Sim.Full.freedOf PRE_first_tail_x15_r0_body.s1118.ffi).getD PTrie.nil
noncomputable def PRE_first_tail_x15_r0_body.krC_126 : Host.Load.Layers.KRec := (Host.Ts.Sim.Full.krecOf PRE_first_tail_x15_r0_body.s1118.ffi).getD Host.Load.Layers.KRec.empty
kernel_rfl PRE_first_tail_x15_r0_body.ofxC_126 : (Host.Ts.Sim.Full.freedOf PRE_first_tail_x15_r0_body.s1118.ffi) = some PRE_first_tail_x15_r0_body.fxC_126
kernel_rfl PRE_first_tail_x15_r0_body.okrC_126 : (Host.Ts.Sim.Full.krecOf PRE_first_tail_x15_r0_body.s1118.ffi) = some PRE_first_tail_x15_r0_body.krC_126
noncomputable def PRE_first_tail_x15_r0_body.fx0_126 : PTrie Unit := (Host.Ts.Sim.Full.freedOf PRE_first_tail_x15_r0_body.s1120.ffi).getD PTrie.nil
noncomputable def PRE_first_tail_x15_r0_body.kr0_126 : Host.Load.Layers.KRec := (Host.Ts.Sim.Full.krecOf PRE_first_tail_x15_r0_body.s1120.ffi).getD Host.Load.Layers.KRec.empty
kernel_rfl PRE_first_tail_x15_r0_body.ofx0_126 : (Host.Ts.Sim.Full.freedOf PRE_first_tail_x15_r0_body.s1120.ffi) = some PRE_first_tail_x15_r0_body.fx0_126
kernel_rfl PRE_first_tail_x15_r0_body.okr0_126 : (Host.Ts.Sim.Full.krecOf PRE_first_tail_x15_r0_body.s1120.ffi) = some PRE_first_tail_x15_r0_body.kr0_126
noncomputable def PRE_first_tail_x15_r0_body.fx1_126 : PTrie Unit := (Host.Ts.Sim.Full.freedOf PRE_first_tail_x15_r0_body.s1119.ffi).getD PTrie.nil
noncomputable def PRE_first_tail_x15_r0_body.kr1_126 : Host.Load.Layers.KRec := (Host.Ts.Sim.Full.krecOf PRE_first_tail_x15_r0_body.s1119.ffi).getD Host.Load.Layers.KRec.empty
kernel_rfl PRE_first_tail_x15_r0_body.ofx1_126 : (Host.Ts.Sim.Full.freedOf PRE_first_tail_x15_r0_body.s1119.ffi) = some PRE_first_tail_x15_r0_body.fx1_126
kernel_rfl PRE_first_tail_x15_r0_body.okr1_126 : (Host.Ts.Sim.Full.krecOf PRE_first_tail_x15_r0_body.s1119.ffi) = some PRE_first_tail_x15_r0_body.kr1_126
kernel_rfl PRE_first_tail_x15_r0_body.ff0126 : PRE_first_tail_x15_r0_body.fx0_126 = Stage.setAll PRE_first_tail_x15_r0_body.fxC_126 (PRE_first_tail_x15_r0_body.clo126.filterMap fun i => (PRE_first_tail_x15_r0_body.fx0_126.get i).map (i, ·))
kernel_rfl PRE_first_tail_x15_r0_body.ff1126 : PRE_first_tail_x15_r0_body.fx1_126 = Stage.setAll PRE_first_tail_x15_r0_body.fxC_126 (PRE_first_tail_x15_r0_body.cwS126.filterMap fun i => (PRE_first_tail_x15_r0_body.fx1_126.get i).map (i, ·))
kernel_rfl PRE_first_tail_x15_r0_body.ffck126 : freedLB PRE_first_tail_x15_r0_body.kappa126 PRE_first_tail_x15_r0_body.cx0_126.mlx PRE_first_tail_x15_r0_body.fx0_126 PRE_first_tail_x15_r0_body.fx1_126 PRE_first_tail_x15_r0_body.clo126 = true
kernel_rfl PRE_first_tail_x15_r0_body.fkf0126 : PRE_first_tail_x15_r0_body.kr0_126.flags = Stage.setAll PRE_first_tail_x15_r0_body.krC_126.flags (PRE_first_tail_x15_r0_body.clo126.filterMap fun i => (PRE_first_tail_x15_r0_body.kr0_126.flags.get i).map (i, ·))
kernel_rfl PRE_first_tail_x15_r0_body.fkt0126 : PRE_first_tail_x15_r0_body.kr0_126.targs = Stage.setAll PRE_first_tail_x15_r0_body.krC_126.targs (PRE_first_tail_x15_r0_body.clo126.filterMap fun i => (PRE_first_tail_x15_r0_body.kr0_126.targs.get i).map (i, ·))
kernel_rfl PRE_first_tail_x15_r0_body.fkf1126 : PRE_first_tail_x15_r0_body.kr1_126.flags = Stage.setAll PRE_first_tail_x15_r0_body.krC_126.flags (PRE_first_tail_x15_r0_body.cwS126.filterMap fun i => (PRE_first_tail_x15_r0_body.kr1_126.flags.get i).map (i, ·))
kernel_rfl PRE_first_tail_x15_r0_body.fkt1126 : PRE_first_tail_x15_r0_body.kr1_126.targs = Stage.setAll PRE_first_tail_x15_r0_body.krC_126.targs (PRE_first_tail_x15_r0_body.cwS126.filterMap fun i => (PRE_first_tail_x15_r0_body.kr1_126.targs.get i).map (i, ·))
kernel_rfl PRE_first_tail_x15_r0_body.fkck126 : krecLB PRE_first_tail_x15_r0_body.kappa126 5489 PRE_first_tail_x15_r0_body.cx0_126.mlx PRE_first_tail_x15_r0_body.kr0_126 PRE_first_tail_x15_r0_body.kr1_126 PRE_first_tail_x15_r0_body.clo126 = true
kernel_rfl PRE_first_tail_x15_r0_body.fkn126 : Nat.ble 5471 5489 = true
-- the bridge and the pending traces' regions
kernel_rfl PRE_first_tail_x15_r0_body.cbridge126 : Host.Ts.Sim.Full.bridgeOf PRE_first_tail_x15_r0_body.s1119.ffi = Host.Ts.Sim.Full.bridgeOf PRE_first_tail_x15_r0_body.s1120.ffi
kernel_rfl PRE_first_tail_x15_r0_body.cpendR126 : pendRegB PRE_first_tail_x15_r0_body.kappa126 (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1120.ffi).mlx = true
kernel_rfl PRE_first_tail_x15_r0_body.cpendLe126 : Nat.ble (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1120.ffi).mlx.next (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1119.ffi).mlx.next = true
/-- **The compaction's native shift**, given the call's bookkeeping, its relation's facts (the model's and the
observers') and the canonical closedness. -/
theorem PRE_first_tail_x15_r0_body.cshift126 (clean : Conv.NClean (⟨20690, 17774, 2774135, 5471⟩ : Conv.Cnt) (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1118.ffi).mlx) (hltC : ∀ h, PH (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1118.ffi).mlx h → h < (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1118.ffi).mlx.next) (nltC : ∀ i, PN (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1118.ffi).mlx i → i < (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1118.ffi).mlx.nnext) (itemsC : ∀ k v, (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1118.ffi).mlx.items.get k = some v → PN (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1118.ffi).mlx k) (tracedC : ∀ h o, (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1118.ffi).mlx.objs.get h = some o → ∀ i ∈ objTraces o, i < PRE_first_tail_x15_r0_body.P126.NL) (cl : SSt (· < 5489) PRE_first_tail_x15_r0_body.cx0_126.mlx)
    (hobjC : ∀ h, PRE_first_tail_x15_r0_body.fxC_126.get h = some () → ((Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1118.ffi).mlx.objs.get h).isSome = true)
    (hfC : ∀ h, (PRE_first_tail_x15_r0_body.krC_126.flags.get h).isSome = true → ((Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1118.ffi).mlx.objs.get h).isSome = true)
    (htC : ∀ h, (PRE_first_tail_x15_r0_body.krC_126.targs.get h).isSome = true → ((Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1118.ffi).mlx.objs.get h).isSome = true)
    (hclC : ∀ h l, PRE_first_tail_x15_r0_body.krC_126.targs.get h = some l → Host.Ts.Sim.Full.STargs (· < (⟨20690, 17774, 2774135, 5471⟩ : Conv.Cnt).n) l) :
    Conv.FullShiftQ PRE_first_tail_x15_r0_body.P126 5489 PRE_first_tail_x15_r0_body.kappa126 PRE_first_tail_x15_r0_body.s1120.ffi PRE_first_tail_x15_r0_body.s1119.ffi :=
  ⟨PRE_first_tail_x15_r0_body.cnshift126 clean hltC nltC itemsC tracedC cl, PRE_first_tail_x15_r0_body.cqueue126, fun t ht => bSN_sound (List.all_eq_true.mp PRE_first_tail_x15_r0_body.ctokSupp126 t ht),
    PRE_first_tail_x15_r0_body.cbridge126,
    liveShift_foot (x0' := Host.Ts.Sim.Full.mlxOf PRE_first_tail_x15_r0_body.s1120.ffi) (x1' := Host.Ts.Sim.Full.mlxOf PRE_first_tail_x15_r0_body.s1119.ffi) (PRE_first_tail_x15_r0_body.cfoot126 clean hltC nltC itemsC tracedC cl) rfl PRE_first_tail_x15_r0_body.ofx0_126 PRE_first_tail_x15_r0_body.ofx1_126 hobjC PRE_first_tail_x15_r0_body.ff0126 PRE_first_tail_x15_r0_body.ff1126 PRE_first_tail_x15_r0_body.ffck126,
    kernShift_foot (x0' := Host.Ts.Sim.Full.mlxOf PRE_first_tail_x15_r0_body.s1120.ffi) (x1' := Host.Ts.Sim.Full.mlxOf PRE_first_tail_x15_r0_body.s1119.ffi) (PRE_first_tail_x15_r0_body.cfoot126 clean hltC nltC itemsC tracedC cl) rfl PRE_first_tail_x15_r0_body.okr0_126 PRE_first_tail_x15_r0_body.okr1_126 (Nat.le_of_ble_eq_true PRE_first_tail_x15_r0_body.fkn126) hfC htC hclC
      PRE_first_tail_x15_r0_body.fkf0126 PRE_first_tail_x15_r0_body.fkt0126 PRE_first_tail_x15_r0_body.fkf1126 PRE_first_tail_x15_r0_body.fkt1126 PRE_first_tail_x15_r0_body.fkck126,
    pendReg_of rfl PRE_first_tail_x15_r0_body.cnh0126 PRE_first_tail_x15_r0_body.cnh1126 (Nat.le_of_ble_eq_true PRE_first_tail_x15_r0_body.cpendLe126) PRE_first_tail_x15_r0_body.cpendR126⟩

end Host.Load.Run.Tpl
