import host.sim.template.a4pre_first_tail_x15_r0_body.SiteCl123
import host.sim.conv.CompactFull
import host.sim.template.FootGen
set_option Elab.async false
namespace Host.Load.Run.Tpl
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
open Host.Ts Host.Ts.Sim Host.Ts.Sim.Template

/-! The compaction's native shift at call site 123 from its footprint (`Conv.nshift_of_foot`), and the observers'
(`liveShift_foot`, `kernShift_foot`): `Conv.FullShiftQ` for `Conv.full_compactQ`, given the call's bookkeeping and its
relation's facts. -/

/-- The load parameters of the chain (band-free: its start's node counter as `NL` and `N0`). -/
def PRE_first_tail_x15_r0_body.Pc123 : LoadP := ⟨18151, 131072, 1099511627776, 15235, 15235, []⟩
/-- The site's band raised to the map's checked fixed-node prefix, including newly recorded closure traces. -/
def PRE_first_tail_x15_r0_body.P123 : LoadP := PRE_first_tail_x15_r0_body.Pc123.raise 17738
kernel_rfl PRE_first_tail_x15_r0_body.craise123 : Nat.ble PRE_first_tail_x15_r0_body.Pc123.N0 17738 = true
theorem PRE_first_tail_x15_r0_body.raised123 : Host.Ts.Sim.Full.Raised PRE_first_tail_x15_r0_body.Pc123 PRE_first_tail_x15_r0_body.P123 :=
  .inr ⟨17738, rfl, Nat.le_of_ble_eq_true PRE_first_tail_x15_r0_body.craise123, rfl⟩
noncomputable abbrev PRE_first_tail_x15_r0_body.cx0_123 : Host.Load.LSt := clearTokens (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1197.ffi)
noncomputable abbrev PRE_first_tail_x15_r0_body.cx1_123 : Host.Load.LSt := clearTokens (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1196.ffi)
def PRE_first_tail_x15_r0_body.khinv123 : PTrie Nat := Stage.setAll PTrie.nil [(20659, 20633), (20637, 20634), (20660, 20635)]
def PRE_first_tail_x15_r0_body.kninv123 : PTrie Nat := Stage.setAll PTrie.nil [(17711, 17711), (17712, 17712), (17713, 17713), (17714, 17714), (17715, 17715), (17716, 17716), (17717, 17717), (17718, 17718), (17719, 17719), (17720, 17720), (17721, 17721), (17722, 17722), (17723, 17723), (17724, 17724), (17725, 17725), (17726, 17726), (17727, 17727), (17728, 17728), (17729, 17729), (17730, 17730), (17731, 17731), (17732, 17732), (17733, 17733), (17734, 17734), (17735, 17735), (17736, 17736), (17737, 17737)]
/-- The stage's footprint: its written and fresh handles, fresh nodes, written and fresh items. -/
def PRE_first_tail_x15_r0_body.cwS123 : List Nat := [20613, 20626, 20632, 20633, 20634, 20635, 20636, 20637, 20638, 20639, 20640, 20641, 20642, 20643, 20644, 20645, 20646, 20647, 20648, 20649, 20650, 20651, 20652, 20653, 20654, 20655, 20656, 20657, 20658, 20659, 20660]
def PRE_first_tail_x15_r0_body.cnS123 : List Nat := List.range' 17711 27
def PRE_first_tail_x15_r0_body.ciS123 : List Nat := [] ++ List.range' 17711 27

-- the small checks (`MChecks`'s)
kernel_rfl PRE_first_tail_x15_r0_body.cnh0123 : PRE_first_tail_x15_r0_body.kd123.nh0 = PRE_first_tail_x15_r0_body.cx0_123.mlx.next
kernel_rfl PRE_first_tail_x15_r0_body.cnh1123 : PRE_first_tail_x15_r0_body.kd123.nh1 = PRE_first_tail_x15_r0_body.cx1_123.mlx.next
kernel_rfl PRE_first_tail_x15_r0_body.cnn0123 : PRE_first_tail_x15_r0_body.kd123.nn0 = PRE_first_tail_x15_r0_body.cx0_123.mlx.nnext
kernel_rfl PRE_first_tail_x15_r0_body.cnn1123 : PRE_first_tail_x15_r0_body.kd123.nn1 = PRE_first_tail_x15_r0_body.cx1_123.mlx.nnext
kernel_rfl PRE_first_tail_x15_r0_body.cplo123 : (Nat.blt 0 PRE_first_tail_x15_r0_body.P123.lo && Nat.ble PRE_first_tail_x15_r0_body.P123.lo PRE_first_tail_x15_r0_body.cx0_123.mlx.next && Nat.ble PRE_first_tail_x15_r0_body.P123.lo RData.bigHi && Nat.ble RData.bigHi PRE_first_tail_x15_r0_body.P123.E) = true
kernel_rfl PRE_first_tail_x15_r0_body.ccnt123 : (Nat.ble PRE_first_tail_x15_r0_body.cx0_123.mlx.next PRE_first_tail_x15_r0_body.cx1_123.mlx.next && Nat.ble PRE_first_tail_x15_r0_body.cx0_123.mlx.nnext PRE_first_tail_x15_r0_body.cx1_123.mlx.nnext) = true
kernel_rfl PRE_first_tail_x15_r0_body.cnband123 : (Nat.blt 0 PRE_first_tail_x15_r0_body.P123.NL && Nat.ble PRE_first_tail_x15_r0_body.P123.NL PRE_first_tail_x15_r0_body.P123.N0 && Nat.ble PRE_first_tail_x15_r0_body.P123.N0 PRE_first_tail_x15_r0_body.cx0_123.mlx.nnext) = true
kernel_rfl PRE_first_tail_x15_r0_body.chbelow123 : PRE_first_tail_x15_r0_body.kd123.checkHndBelow = true
kernel_rfl PRE_first_tail_x15_r0_body.chren123 : checkRenG PRE_first_tail_x15_r0_body.kd123.hnd PRE_first_tail_x15_r0_body.khinv123 (phB PRE_first_tail_x15_r0_body.cx0_123.mlx) = true
kernel_rfl PRE_first_tail_x15_r0_body.cband123 : PRE_first_tail_x15_r0_body.kd123.checkBand PRE_first_tail_x15_r0_body.P123.lo = true
kernel_rfl PRE_first_tail_x15_r0_body.cnh1pos123 : Nat.blt 0 PRE_first_tail_x15_r0_body.kd123.nh1 = true
kernel_rfl PRE_first_tail_x15_r0_body.cnren123 : checkRenG PRE_first_tail_x15_r0_body.kd123.node PRE_first_tail_x15_r0_body.kninv123 (pnB PRE_first_tail_x15_r0_body.cx0_123.mlx) = true
kernel_rfl PRE_first_tail_x15_r0_body.cnlow123 : (PTrie.keysA PRE_first_tail_x15_r0_body.kd123.node).all (fun j => Nat.ble PRE_first_tail_x15_r0_body.P123.NL j && Nat.blt (PRE_first_tail_x15_r0_body.kd123.nodeF j) PRE_first_tail_x15_r0_body.cx1_123.mlx.nnext) = true
kernel_rfl PRE_first_tail_x15_r0_body.cabs0a123 : PRE_first_tail_x15_r0_body.cx0_123.mlx.arrs.get 0 = none
kernel_rfl PRE_first_tail_x15_r0_body.cabs0b123 : PRE_first_tail_x15_r0_body.cx0_123.mlx.objs.get 0 = none
kernel_rfl PRE_first_tail_x15_r0_body.ctok1123 : PRE_first_tail_x15_r0_body.cx1_123.mlx.tokens = []
kernel_rfl PRE_first_tail_x15_r0_body.cpend123 : PRE_first_tail_x15_r0_body.cx1_123.mlx.pending = PRE_first_tail_x15_r0_body.cx0_123.mlx.pending.map PRE_first_tail_x15_r0_body.kappa123.pend
kernel_rfl PRE_first_tail_x15_r0_body.cerrh123 : PRE_first_tail_x15_r0_body.cx1_123.mlx.errh = PRE_first_tail_x15_r0_body.cx0_123.mlx.errh.map PRE_first_tail_x15_r0_body.kappa123.arg
kernel_rfl PRE_first_tail_x15_r0_body.cfiles123 : PRE_first_tail_x15_r0_body.cx1_123.mlx.files = PRE_first_tail_x15_r0_body.cx0_123.mlx.files
kernel_rfl PRE_first_tail_x15_r0_body.carch123 : PRE_first_tail_x15_r0_body.cx1_123.mlx.arch = PRE_first_tail_x15_r0_body.cx0_123.mlx.arch
kernel_rfl PRE_first_tail_x15_r0_body.csizes123 : PRE_first_tail_x15_r0_body.cx1_123.mlx.deviceSizes = PRE_first_tail_x15_r0_body.cx0_123.mlx.deviceSizes
kernel_rfl PRE_first_tail_x15_r0_body.cwired123 : PRE_first_tail_x15_r0_body.cx1_123.mlx.wired = PRE_first_tail_x15_r0_body.cx0_123.mlx.wired
kernel_rfl PRE_first_tail_x15_r0_body.chost123 : PRE_first_tail_x15_r0_body.cx1_123.host = PRE_first_tail_x15_r0_body.cx0_123.host
-- the compaction map's addresses are `PRE_first_tail_x15_r0_body.kd123`'s
kernel_rfl PRE_first_tail_x15_r0_body.ckn0123 : PRE_first_tail_x15_r0_body.kd123.n0 = 2771885
kernel_rfl PRE_first_tail_x15_r0_body.ckn1123 : PRE_first_tail_x15_r0_body.kd123.n1 = 2773034
kernel_rfl PRE_first_tail_x15_r0_body.ckheap123 : (PTrie.keysA PRE_first_tail_x15_r0_body.kd123.heap).all (fun x => Nat.ble 2771879 x) = true
kernel_rfl PRE_first_tail_x15_r0_body.ckpl123 : (List.range 6).all (fun j => decide (PRE_first_tail_x15_r0_body.kd123.heap.get (2771879 + j) = nth? PRE_first_tail_x15_r0_body.pl123 j)) = true
-- the map fixes the call's names (`Conv.fixOld_compact`), the call's counters
kernel_rfl PRE_first_tail_x15_r0_body.fja123 : Nat.ble 2771879 2771879 = true
kernel_rfl PRE_first_tail_x15_r0_body.fn123 : Nat.ble 5342 5342 = true
kernel_rfl PRE_first_tail_x15_r0_body.fjaD123 : Nat.ble 2771879 PRE_first_tail_x15_r0_body.kd123.n0 = true
kernel_rfl PRE_first_tail_x15_r0_body.fxn123 : Nat.ble 20633 PRE_first_tail_x15_r0_body.kd123.nh0 = true
kernel_rfl PRE_first_tail_x15_r0_body.fnn123 : Nat.ble 17711 PRE_first_tail_x15_r0_body.kd123.nn0 = true
kernel_rfl PRE_first_tail_x15_r0_body.fxb123 : Nat.ble 20633 RData.bigHi = true
kernel_rfl PRE_first_tail_x15_r0_body.fheap123 : (PTrie.keysA PRE_first_tail_x15_r0_body.kd123.heap).all (Nat.ble (⟨20633, 17711, 2771879, 5342⟩ : Conv.Cnt).ja) = true
kernel_rfl PRE_first_tail_x15_r0_body.fhnd123 : (PTrie.keysA PRE_first_tail_x15_r0_body.kd123.hnd).all (Nat.ble (⟨20633, 17711, 2771879, 5342⟩ : Conv.Cnt).xn) = true
kernel_rfl PRE_first_tail_x15_r0_body.fnode123 : (PTrie.keysA PRE_first_tail_x15_r0_body.kd123.node).all (Nat.ble (⟨20633, 17711, 2771879, 5342⟩ : Conv.Cnt).nn) = true
/-- The compaction map fixes the call's names. -/
theorem PRE_first_tail_x15_r0_body.cfix123 : Conv.FixOld (⟨20633, 17711, 2771879, 5342⟩ : Conv.Cnt) PRE_first_tail_x15_r0_body.kappa123 :=
  Conv.fixOld_compact (Nat.le_of_ble_eq_true PRE_first_tail_x15_r0_body.fja123) (Nat.le_of_ble_eq_true PRE_first_tail_x15_r0_body.fn123) (Nat.le_of_ble_eq_true PRE_first_tail_x15_r0_body.fjaD123) (Nat.le_of_ble_eq_true PRE_first_tail_x15_r0_body.fxn123) (Nat.le_of_ble_eq_true PRE_first_tail_x15_r0_body.fnn123) (Nat.le_of_ble_eq_true PRE_first_tail_x15_r0_body.fxb123) PRE_first_tail_x15_r0_body.fheap123 PRE_first_tail_x15_r0_body.fhnd123 PRE_first_tail_x15_r0_body.fnode123
kernel_rfl PRE_first_tail_x15_r0_body.fcxn123 : (⟨20633, 17711, 2771879, 5342⟩ : Conv.Cnt).xn = (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1195.ffi).mlx.next
kernel_rfl PRE_first_tail_x15_r0_body.fcnn123 : (⟨20633, 17711, 2771879, 5342⟩ : Conv.Cnt).nn = (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1195.ffi).mlx.nnext
kernel_rfl PRE_first_tail_x15_r0_body.fle0123 : (Nat.ble (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1195.ffi).mlx.next PRE_first_tail_x15_r0_body.cx0_123.mlx.next && Nat.ble (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1195.ffi).mlx.nnext PRE_first_tail_x15_r0_body.cx0_123.mlx.nnext && Nat.ble (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1195.ffi).mlx.next RData.bigHi) = true
kernel_rfl PRE_first_tail_x15_r0_body.fnk123 : (PTrie.keysA PRE_first_tail_x15_r0_body.kd123.node).all (Nat.ble (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1195.ffi).mlx.nnext) = true
-- the merged state keeps the call's entries off the stage's footprint
kernel_rfl PRE_first_tail_x15_r0_body.f1A123 : PRE_first_tail_x15_r0_body.cx1_123.mlx.arrs = Stage.setAll (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1195.ffi).mlx.arrs (PRE_first_tail_x15_r0_body.cwS123.filterMap fun i => (PRE_first_tail_x15_r0_body.cx1_123.mlx.arrs.get i).map (i, ·))
kernel_rfl PRE_first_tail_x15_r0_body.f1O123 : PRE_first_tail_x15_r0_body.cx1_123.mlx.objs = Stage.setAll (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1195.ffi).mlx.objs (PRE_first_tail_x15_r0_body.cwS123.filterMap fun i => (PRE_first_tail_x15_r0_body.cx1_123.mlx.objs.get i).map (i, ·))
kernel_rfl PRE_first_tail_x15_r0_body.f1N123 : PRE_first_tail_x15_r0_body.cx1_123.mlx.nodes = Stage.setAll (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1195.ffi).mlx.nodes (PRE_first_tail_x15_r0_body.cnS123.filterMap fun i => (PRE_first_tail_x15_r0_body.cx1_123.mlx.nodes.get i).map (i, ·))
kernel_rfl PRE_first_tail_x15_r0_body.f1I123 : PRE_first_tail_x15_r0_body.cx1_123.mlx.items = Stage.setAll (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1195.ffi).mlx.items (PRE_first_tail_x15_r0_body.ciS123.filterMap fun i => (PRE_first_tail_x15_r0_body.cx1_123.mlx.items.get i).map (i, ·))
kernel_rfl PRE_first_tail_x15_r0_body.fbd123 : (PRE_first_tail_x15_r0_body.clo123 ++ PRE_first_tail_x15_r0_body.cln123 ++ PRE_first_tail_x15_r0_body.cli123 ++ PRE_first_tail_x15_r0_body.cwS123 ++ PRE_first_tail_x15_r0_body.cnS123 ++ PRE_first_tail_x15_r0_body.ciS123).all (fun i => Nat.blt (i / 4096) (4 ^ 31)) = true
kernel_rfl PRE_first_tail_x15_r0_body.fincW123 : PRE_first_tail_x15_r0_body.cwS123.all (fun h => !Nat.blt h (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1195.ffi).mlx.next || PRE_first_tail_x15_r0_body.clo123.contains h) = true
kernel_rfl PRE_first_tail_x15_r0_body.fincI123 : PRE_first_tail_x15_r0_body.ciS123.all (fun k => !Nat.blt k (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1195.ffi).mlx.nnext || PRE_first_tail_x15_r0_body.cli123.contains k) = true
kernel_rfl PRE_first_tail_x15_r0_body.fincN123 : PRE_first_tail_x15_r0_body.cnS123.all (Nat.ble (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1195.ffi).mlx.nnext) = true
kernel_rfl PRE_first_tail_x15_r0_body.flnF123 : PRE_first_tail_x15_r0_body.cln123.all (Nat.ble (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1195.ffi).mlx.nnext) = true
-- the checks over the changed lists
kernel_rfl PRE_first_tail_x15_r0_body.fh123 : PRE_first_tail_x15_r0_body.clo123.all (handleOK PRE_first_tail_x15_r0_body.kappa123 PRE_first_tail_x15_r0_body.P123.lo PRE_first_tail_x15_r0_body.cx0_123.mlx PRE_first_tail_x15_r0_body.cx1_123.mlx) = true
kernel_rfl PRE_first_tail_x15_r0_body.fo123 : PRE_first_tail_x15_r0_body.clo123.map (fun h => PRE_first_tail_x15_r0_body.cx1_123.mlx.objs.get (PRE_first_tail_x15_r0_body.kappa123.handle h)) = PRE_first_tail_x15_r0_body.clo123.map (fun h => (PRE_first_tail_x15_r0_body.cx0_123.mlx.objs.get h).map PRE_first_tail_x15_r0_body.kappa123.nobj)
kernel_rfl PRE_first_tail_x15_r0_body.fok123 : PRE_first_tail_x15_r0_body.clo123.all (objOK PRE_first_tail_x15_r0_body.kappa123 PRE_first_tail_x15_r0_body.P123.NL PRE_first_tail_x15_r0_body.cx0_123.mlx) = true
kernel_rfl PRE_first_tail_x15_r0_body.fnd123 : PRE_first_tail_x15_r0_body.cln123.all (nodeOKF PRE_first_tail_x15_r0_body.kappa123 PRE_first_tail_x15_r0_body.P123 PRE_first_tail_x15_r0_body.cx0_123.mlx PRE_first_tail_x15_r0_body.cx1_123.mlx) = true
kernel_rfl PRE_first_tail_x15_r0_body.fp123 : ((PRE_first_tail_x15_r0_body.cln123.filter (fullB PRE_first_tail_x15_r0_body.P123))).map (fun i => (PRE_first_tail_x15_r0_body.cx1_123.mlx.nodes.get (PRE_first_tail_x15_r0_body.kappa123.node i)).map Host.Mlx.Ffi.Node.prim) =
  ((PRE_first_tail_x15_r0_body.cln123.filter (fullB PRE_first_tail_x15_r0_body.P123))).map (fun i => (PRE_first_tail_x15_r0_body.cx0_123.mlx.nodes.get i).map fun nd => PRE_first_tail_x15_r0_body.kappa123.prim nd.prim)
kernel_rfl PRE_first_tail_x15_r0_body.fnordI123 : incrB PRE_first_tail_x15_r0_body.kd123.nodeF (List.range' 17711 27) = true
kernel_rfl PRE_first_tail_x15_r0_body.fnordK123 : (PTrie.keysA PRE_first_tail_x15_r0_body.kd123.node).all (fun k => Nat.ble 17711 k && Nat.blt k 17738) = true
kernel_rfl PRE_first_tail_x15_r0_body.fnordL123 : (PRE_first_tail_x15_r0_body.cln123.filter (Nat.ble PRE_first_tail_x15_r0_body.P123.N0)).all (fun i => Nat.ble i (PRE_first_tail_x15_r0_body.kd123.nodeF i) && (Nat.blt i 17738 || Nat.ble PRE_first_tail_x15_r0_body.kd123.nn0 i)) = true
theorem PRE_first_tail_x15_r0_body.fnord123 : (PRE_first_tail_x15_r0_body.cln123.filter (Nat.ble PRE_first_tail_x15_r0_body.P123.N0)).all (fun i => Nat.ble i (PRE_first_tail_x15_r0_body.kd123.nodeF i) &&
    (PTrie.keysA PRE_first_tail_x15_r0_body.kd123.node).all fun j => !Nat.blt j i || Nat.blt (PRE_first_tail_x15_r0_body.kd123.nodeF j) (PRE_first_tail_x15_r0_body.kd123.nodeF i)) = true :=
  cnord_of PRE_first_tail_x15_r0_body.cnlow123 PRE_first_tail_x15_r0_body.cnn1123 PRE_first_tail_x15_r0_body.fnordI123 PRE_first_tail_x15_r0_body.fnordK123 PRE_first_tail_x15_r0_body.fnordL123
kernel_rfl PRE_first_tail_x15_r0_body.fi123 : PRE_first_tail_x15_r0_body.cli123.all (pnB PRE_first_tail_x15_r0_body.cx0_123.mlx) = true
kernel_rfl PRE_first_tail_x15_r0_body.fii123 : PRE_first_tail_x15_r0_body.cli123.all (fun k => decide (PRE_first_tail_x15_r0_body.cx1_123.mlx.items.get (PRE_first_tail_x15_r0_body.kappa123.node k) = (PRE_first_tail_x15_r0_body.cx0_123.mlx.items.get k).map PRE_first_tail_x15_r0_body.kappa123.nv)) = true
/-- **The compaction's footprint.** -/
theorem PRE_first_tail_x15_r0_body.cfoot123 (clean : Conv.NClean (⟨20633, 17711, 2771879, 5342⟩ : Conv.Cnt) (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1195.ffi).mlx) (hltC : ∀ h, PH (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1195.ffi).mlx h → h < (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1195.ffi).mlx.next) (nltC : ∀ i, PN (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1195.ffi).mlx i → i < (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1195.ffi).mlx.nnext) (itemsC : ∀ k v, (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1195.ffi).mlx.items.get k = some v → PN (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1195.ffi).mlx k) (tracedC : ∀ h o, (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1195.ffi).mlx.objs.get h = some o → ∀ i ∈ objTraces o, i < PRE_first_tail_x15_r0_body.P123.NL) (cl : SSt (· < 5360) PRE_first_tail_x15_r0_body.cx0_123.mlx) :
    Conv.MFoot PRE_first_tail_x15_r0_body.P123 5360 PRE_first_tail_x15_r0_body.kappa123 PRE_first_tail_x15_r0_body.kd123 PRE_first_tail_x15_r0_body.khinv123 PRE_first_tail_x15_r0_body.kninv123 (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1195.ffi).mlx PRE_first_tail_x15_r0_body.cx0_123.mlx PRE_first_tail_x15_r0_body.cx1_123.mlx (⟨20633, 17711, 2771879, 5342⟩ : Conv.Cnt) PRE_first_tail_x15_r0_body.clo123 PRE_first_tail_x15_r0_body.cln123 PRE_first_tail_x15_r0_body.cli123 PRE_first_tail_x15_r0_body.cwS123 PRE_first_tail_x15_r0_body.cnS123 PRE_first_tail_x15_r0_body.ciS123 :=
  ⟨rfl, rfl, rfl, PRE_first_tail_x15_r0_body.cnh0123, PRE_first_tail_x15_r0_body.cnh1123, PRE_first_tail_x15_r0_body.cnn0123, PRE_first_tail_x15_r0_body.cnn1123, PRE_first_tail_x15_r0_body.cplo123, PRE_first_tail_x15_r0_body.ccnt123, PRE_first_tail_x15_r0_body.cnband123, PRE_first_tail_x15_r0_body.chbelow123, PRE_first_tail_x15_r0_body.chren123, PRE_first_tail_x15_r0_body.cband123, PRE_first_tail_x15_r0_body.cnh1pos123, PRE_first_tail_x15_r0_body.cnren123, PRE_first_tail_x15_r0_body.cnlow123, PRE_first_tail_x15_r0_body.cabs0a123, PRE_first_tail_x15_r0_body.cabs0b123, PRE_first_tail_x15_r0_body.ctok1123, PRE_first_tail_x15_r0_body.cpend123, PRE_first_tail_x15_r0_body.cerrh123, PRE_first_tail_x15_r0_body.cfiles123, PRE_first_tail_x15_r0_body.carch123, PRE_first_tail_x15_r0_body.csizes123, PRE_first_tail_x15_r0_body.cwired123, PRE_first_tail_x15_r0_body.cfix123, clean, PRE_first_tail_x15_r0_body.fcxn123, PRE_first_tail_x15_r0_body.fcnn123, hltC, nltC, itemsC, tracedC, cl, PRE_first_tail_x15_r0_body.fle0123, PRE_first_tail_x15_r0_body.fnk123, PRE_first_tail_x15_r0_body.ckA123, PRE_first_tail_x15_r0_body.cobjsK123, PRE_first_tail_x15_r0_body.cnodesK123, PRE_first_tail_x15_r0_body.citemsK123, PRE_first_tail_x15_r0_body.f1A123, PRE_first_tail_x15_r0_body.f1O123, PRE_first_tail_x15_r0_body.f1N123, PRE_first_tail_x15_r0_body.f1I123, PRE_first_tail_x15_r0_body.fbd123, PRE_first_tail_x15_r0_body.fincW123, PRE_first_tail_x15_r0_body.fincI123, PRE_first_tail_x15_r0_body.fincN123, PRE_first_tail_x15_r0_body.flnF123, PRE_first_tail_x15_r0_body.fh123, PRE_first_tail_x15_r0_body.fo123, PRE_first_tail_x15_r0_body.fok123, PRE_first_tail_x15_r0_body.fnd123, PRE_first_tail_x15_r0_body.fp123, PRE_first_tail_x15_r0_body.fnord123, PRE_first_tail_x15_r0_body.fi123, PRE_first_tail_x15_r0_body.fii123⟩
theorem PRE_first_tail_x15_r0_body.cnshift123 (clean : Conv.NClean (⟨20633, 17711, 2771879, 5342⟩ : Conv.Cnt) (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1195.ffi).mlx) (hltC : ∀ h, PH (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1195.ffi).mlx h → h < (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1195.ffi).mlx.next) (nltC : ∀ i, PN (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1195.ffi).mlx i → i < (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1195.ffi).mlx.nnext) (itemsC : ∀ k v, (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1195.ffi).mlx.items.get k = some v → PN (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1195.ffi).mlx k) (tracedC : ∀ h o, (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1195.ffi).mlx.objs.get h = some o → ∀ i ∈ objTraces o, i < PRE_first_tail_x15_r0_body.P123.NL) (cl : SSt (· < 5360) PRE_first_tail_x15_r0_body.cx0_123.mlx) : NShift PRE_first_tail_x15_r0_body.P123 5360 PRE_first_tail_x15_r0_body.kappa123 PRE_first_tail_x15_r0_body.cx0_123 PRE_first_tail_x15_r0_body.cx1_123 :=
  Conv.nshift_of_foot (PRE_first_tail_x15_r0_body.cfoot123 clean hltC nltC itemsC tracedC cl) PRE_first_tail_x15_r0_body.chost123 (compact_a_eq PRE_first_tail_x15_r0_body.ckn0123 PRE_first_tail_x15_r0_body.ckn1123 PRE_first_tail_x15_r0_body.ckheap123 PRE_first_tail_x15_r0_body.ckpl123)

-- the observers: the layers' states at the call, the canonical and the merged state, their footprints and checks
noncomputable def PRE_first_tail_x15_r0_body.fxC_123 : PTrie Unit := (Host.Ts.Sim.Full.freedOf PRE_first_tail_x15_r0_body.s1195.ffi).getD PTrie.nil
noncomputable def PRE_first_tail_x15_r0_body.krC_123 : Host.Load.Layers.KRec := (Host.Ts.Sim.Full.krecOf PRE_first_tail_x15_r0_body.s1195.ffi).getD Host.Load.Layers.KRec.empty
kernel_rfl PRE_first_tail_x15_r0_body.ofxC_123 : (Host.Ts.Sim.Full.freedOf PRE_first_tail_x15_r0_body.s1195.ffi) = some PRE_first_tail_x15_r0_body.fxC_123
kernel_rfl PRE_first_tail_x15_r0_body.okrC_123 : (Host.Ts.Sim.Full.krecOf PRE_first_tail_x15_r0_body.s1195.ffi) = some PRE_first_tail_x15_r0_body.krC_123
noncomputable def PRE_first_tail_x15_r0_body.fx0_123 : PTrie Unit := (Host.Ts.Sim.Full.freedOf PRE_first_tail_x15_r0_body.s1197.ffi).getD PTrie.nil
noncomputable def PRE_first_tail_x15_r0_body.kr0_123 : Host.Load.Layers.KRec := (Host.Ts.Sim.Full.krecOf PRE_first_tail_x15_r0_body.s1197.ffi).getD Host.Load.Layers.KRec.empty
kernel_rfl PRE_first_tail_x15_r0_body.ofx0_123 : (Host.Ts.Sim.Full.freedOf PRE_first_tail_x15_r0_body.s1197.ffi) = some PRE_first_tail_x15_r0_body.fx0_123
kernel_rfl PRE_first_tail_x15_r0_body.okr0_123 : (Host.Ts.Sim.Full.krecOf PRE_first_tail_x15_r0_body.s1197.ffi) = some PRE_first_tail_x15_r0_body.kr0_123
noncomputable def PRE_first_tail_x15_r0_body.fx1_123 : PTrie Unit := (Host.Ts.Sim.Full.freedOf PRE_first_tail_x15_r0_body.s1196.ffi).getD PTrie.nil
noncomputable def PRE_first_tail_x15_r0_body.kr1_123 : Host.Load.Layers.KRec := (Host.Ts.Sim.Full.krecOf PRE_first_tail_x15_r0_body.s1196.ffi).getD Host.Load.Layers.KRec.empty
kernel_rfl PRE_first_tail_x15_r0_body.ofx1_123 : (Host.Ts.Sim.Full.freedOf PRE_first_tail_x15_r0_body.s1196.ffi) = some PRE_first_tail_x15_r0_body.fx1_123
kernel_rfl PRE_first_tail_x15_r0_body.okr1_123 : (Host.Ts.Sim.Full.krecOf PRE_first_tail_x15_r0_body.s1196.ffi) = some PRE_first_tail_x15_r0_body.kr1_123
kernel_rfl PRE_first_tail_x15_r0_body.ff0123 : PRE_first_tail_x15_r0_body.fx0_123 = Stage.setAll PRE_first_tail_x15_r0_body.fxC_123 (PRE_first_tail_x15_r0_body.clo123.filterMap fun i => (PRE_first_tail_x15_r0_body.fx0_123.get i).map (i, ·))
kernel_rfl PRE_first_tail_x15_r0_body.ff1123 : PRE_first_tail_x15_r0_body.fx1_123 = Stage.setAll PRE_first_tail_x15_r0_body.fxC_123 (PRE_first_tail_x15_r0_body.cwS123.filterMap fun i => (PRE_first_tail_x15_r0_body.fx1_123.get i).map (i, ·))
kernel_rfl PRE_first_tail_x15_r0_body.ffck123 : freedLB PRE_first_tail_x15_r0_body.kappa123 PRE_first_tail_x15_r0_body.cx0_123.mlx PRE_first_tail_x15_r0_body.fx0_123 PRE_first_tail_x15_r0_body.fx1_123 PRE_first_tail_x15_r0_body.clo123 = true
kernel_rfl PRE_first_tail_x15_r0_body.fkf0123 : PRE_first_tail_x15_r0_body.kr0_123.flags = Stage.setAll PRE_first_tail_x15_r0_body.krC_123.flags (PRE_first_tail_x15_r0_body.clo123.filterMap fun i => (PRE_first_tail_x15_r0_body.kr0_123.flags.get i).map (i, ·))
kernel_rfl PRE_first_tail_x15_r0_body.fkt0123 : PRE_first_tail_x15_r0_body.kr0_123.targs = Stage.setAll PRE_first_tail_x15_r0_body.krC_123.targs (PRE_first_tail_x15_r0_body.clo123.filterMap fun i => (PRE_first_tail_x15_r0_body.kr0_123.targs.get i).map (i, ·))
kernel_rfl PRE_first_tail_x15_r0_body.fkf1123 : PRE_first_tail_x15_r0_body.kr1_123.flags = Stage.setAll PRE_first_tail_x15_r0_body.krC_123.flags (PRE_first_tail_x15_r0_body.cwS123.filterMap fun i => (PRE_first_tail_x15_r0_body.kr1_123.flags.get i).map (i, ·))
kernel_rfl PRE_first_tail_x15_r0_body.fkt1123 : PRE_first_tail_x15_r0_body.kr1_123.targs = Stage.setAll PRE_first_tail_x15_r0_body.krC_123.targs (PRE_first_tail_x15_r0_body.cwS123.filterMap fun i => (PRE_first_tail_x15_r0_body.kr1_123.targs.get i).map (i, ·))
kernel_rfl PRE_first_tail_x15_r0_body.fkck123 : krecLB PRE_first_tail_x15_r0_body.kappa123 5360 PRE_first_tail_x15_r0_body.cx0_123.mlx PRE_first_tail_x15_r0_body.kr0_123 PRE_first_tail_x15_r0_body.kr1_123 PRE_first_tail_x15_r0_body.clo123 = true
kernel_rfl PRE_first_tail_x15_r0_body.fkn123 : Nat.ble 5342 5360 = true
-- the bridge and the pending traces' regions
kernel_rfl PRE_first_tail_x15_r0_body.cbridge123 : Host.Ts.Sim.Full.bridgeOf PRE_first_tail_x15_r0_body.s1196.ffi = Host.Ts.Sim.Full.bridgeOf PRE_first_tail_x15_r0_body.s1197.ffi
kernel_rfl PRE_first_tail_x15_r0_body.cpendR123 : pendRegB PRE_first_tail_x15_r0_body.kappa123 (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1197.ffi).mlx = true
kernel_rfl PRE_first_tail_x15_r0_body.cpendLe123 : Nat.ble (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1197.ffi).mlx.next (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1196.ffi).mlx.next = true
/-- **The compaction's native shift**, given the call's bookkeeping, its relation's facts (the model's and the
observers') and the canonical closedness. -/
theorem PRE_first_tail_x15_r0_body.cshift123 (clean : Conv.NClean (⟨20633, 17711, 2771879, 5342⟩ : Conv.Cnt) (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1195.ffi).mlx) (hltC : ∀ h, PH (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1195.ffi).mlx h → h < (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1195.ffi).mlx.next) (nltC : ∀ i, PN (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1195.ffi).mlx i → i < (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1195.ffi).mlx.nnext) (itemsC : ∀ k v, (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1195.ffi).mlx.items.get k = some v → PN (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1195.ffi).mlx k) (tracedC : ∀ h o, (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1195.ffi).mlx.objs.get h = some o → ∀ i ∈ objTraces o, i < PRE_first_tail_x15_r0_body.P123.NL) (cl : SSt (· < 5360) PRE_first_tail_x15_r0_body.cx0_123.mlx)
    (hobjC : ∀ h, PRE_first_tail_x15_r0_body.fxC_123.get h = some () → ((Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1195.ffi).mlx.objs.get h).isSome = true)
    (hfC : ∀ h, (PRE_first_tail_x15_r0_body.krC_123.flags.get h).isSome = true → ((Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1195.ffi).mlx.objs.get h).isSome = true)
    (htC : ∀ h, (PRE_first_tail_x15_r0_body.krC_123.targs.get h).isSome = true → ((Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1195.ffi).mlx.objs.get h).isSome = true)
    (hclC : ∀ h l, PRE_first_tail_x15_r0_body.krC_123.targs.get h = some l → Host.Ts.Sim.Full.STargs (· < (⟨20633, 17711, 2771879, 5342⟩ : Conv.Cnt).n) l) :
    Conv.FullShiftQ PRE_first_tail_x15_r0_body.P123 5360 PRE_first_tail_x15_r0_body.kappa123 PRE_first_tail_x15_r0_body.s1197.ffi PRE_first_tail_x15_r0_body.s1196.ffi :=
  ⟨PRE_first_tail_x15_r0_body.cnshift123 clean hltC nltC itemsC tracedC cl, PRE_first_tail_x15_r0_body.cqueue123, fun t ht => bSN_sound (List.all_eq_true.mp PRE_first_tail_x15_r0_body.ctokSupp123 t ht),
    PRE_first_tail_x15_r0_body.cbridge123,
    liveShift_foot (x0' := Host.Ts.Sim.Full.mlxOf PRE_first_tail_x15_r0_body.s1197.ffi) (x1' := Host.Ts.Sim.Full.mlxOf PRE_first_tail_x15_r0_body.s1196.ffi) (PRE_first_tail_x15_r0_body.cfoot123 clean hltC nltC itemsC tracedC cl) rfl PRE_first_tail_x15_r0_body.ofx0_123 PRE_first_tail_x15_r0_body.ofx1_123 hobjC PRE_first_tail_x15_r0_body.ff0123 PRE_first_tail_x15_r0_body.ff1123 PRE_first_tail_x15_r0_body.ffck123,
    kernShift_foot (x0' := Host.Ts.Sim.Full.mlxOf PRE_first_tail_x15_r0_body.s1197.ffi) (x1' := Host.Ts.Sim.Full.mlxOf PRE_first_tail_x15_r0_body.s1196.ffi) (PRE_first_tail_x15_r0_body.cfoot123 clean hltC nltC itemsC tracedC cl) rfl PRE_first_tail_x15_r0_body.okr0_123 PRE_first_tail_x15_r0_body.okr1_123 (Nat.le_of_ble_eq_true PRE_first_tail_x15_r0_body.fkn123) hfC htC hclC
      PRE_first_tail_x15_r0_body.fkf0123 PRE_first_tail_x15_r0_body.fkt0123 PRE_first_tail_x15_r0_body.fkf1123 PRE_first_tail_x15_r0_body.fkt1123 PRE_first_tail_x15_r0_body.fkck123,
    pendReg_of rfl PRE_first_tail_x15_r0_body.cnh0123 PRE_first_tail_x15_r0_body.cnh1123 (Nat.le_of_ble_eq_true PRE_first_tail_x15_r0_body.cpendLe123) PRE_first_tail_x15_r0_body.cpendR123⟩

end Host.Load.Run.Tpl
