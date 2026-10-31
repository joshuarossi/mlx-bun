import host.sim.template.a4pre_first_tail_x15_r0_body.SiteCl174
import host.sim.conv.CompactFull
import host.sim.template.FootGen
set_option Elab.async false
namespace Host.Load.Run.Tpl
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
open Host.Ts Host.Ts.Sim Host.Ts.Sim.Template

/-! The compaction's native shift at call site 174 from its footprint (`Conv.nshift_of_foot`), and the observers'
(`liveShift_foot`, `kernShift_foot`): `Conv.FullShiftQ` for `Conv.full_compactQ`, given the call's bookkeeping and its
relation's facts. -/

/-- The load parameters of the chain (band-free: its start's node counter as `NL` and `N0`). -/
def PRE_first_tail_x15_r0_body.Pc174 : LoadP := ⟨18151, 131072, 1099511627776, 15235, 15235, []⟩
/-- The site's band raised to the map's checked fixed-node prefix, including newly recorded closure traces. -/
def PRE_first_tail_x15_r0_body.P174 : LoadP := PRE_first_tail_x15_r0_body.Pc174.raise 18749
kernel_rfl PRE_first_tail_x15_r0_body.craise174 : Nat.ble PRE_first_tail_x15_r0_body.Pc174.N0 18749 = true
theorem PRE_first_tail_x15_r0_body.raised174 : Host.Ts.Sim.Full.Raised PRE_first_tail_x15_r0_body.Pc174 PRE_first_tail_x15_r0_body.P174 :=
  .inr ⟨18749, rfl, Nat.le_of_ble_eq_true PRE_first_tail_x15_r0_body.craise174, rfl⟩
noncomputable abbrev PRE_first_tail_x15_r0_body.cx0_174 : Host.Load.LSt := clearTokens (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1686.ffi)
noncomputable abbrev PRE_first_tail_x15_r0_body.cx1_174 : Host.Load.LSt := clearTokens (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1685.ffi)
def PRE_first_tail_x15_r0_body.khinv174 : PTrie Nat := Stage.setAll PTrie.nil [(21660, 21634), (21638, 21635), (21661, 21636)]
def PRE_first_tail_x15_r0_body.kninv174 : PTrie Nat := Stage.setAll PTrie.nil [(18722, 18722), (18723, 18723), (18724, 18724), (18725, 18725), (18726, 18726), (18727, 18727), (18728, 18728), (18729, 18729), (18730, 18730), (18731, 18731), (18732, 18732), (18733, 18733), (18734, 18734), (18735, 18735), (18736, 18736), (18737, 18737), (18738, 18738), (18739, 18739), (18740, 18740), (18741, 18741), (18742, 18742), (18743, 18743), (18744, 18744), (18745, 18745), (18746, 18746), (18747, 18747), (18748, 18748)]
/-- The stage's footprint: its written and fresh handles, fresh nodes, written and fresh items. -/
def PRE_first_tail_x15_r0_body.cwS174 : List Nat := [21614, 21627, 21633, 21634, 21635, 21636, 21637, 21638, 21639, 21640, 21641, 21642, 21643, 21644, 21645, 21646, 21647, 21648, 21649, 21650, 21651, 21652, 21653, 21654, 21655, 21656, 21657, 21658, 21659, 21660, 21661]
def PRE_first_tail_x15_r0_body.cnS174 : List Nat := List.range' 18722 27
def PRE_first_tail_x15_r0_body.ciS174 : List Nat := [] ++ List.range' 18722 27

-- the small checks (`MChecks`'s)
kernel_rfl PRE_first_tail_x15_r0_body.cnh0174 : PRE_first_tail_x15_r0_body.kd174.nh0 = PRE_first_tail_x15_r0_body.cx0_174.mlx.next
kernel_rfl PRE_first_tail_x15_r0_body.cnh1174 : PRE_first_tail_x15_r0_body.kd174.nh1 = PRE_first_tail_x15_r0_body.cx1_174.mlx.next
kernel_rfl PRE_first_tail_x15_r0_body.cnn0174 : PRE_first_tail_x15_r0_body.kd174.nn0 = PRE_first_tail_x15_r0_body.cx0_174.mlx.nnext
kernel_rfl PRE_first_tail_x15_r0_body.cnn1174 : PRE_first_tail_x15_r0_body.kd174.nn1 = PRE_first_tail_x15_r0_body.cx1_174.mlx.nnext
kernel_rfl PRE_first_tail_x15_r0_body.cplo174 : (Nat.blt 0 PRE_first_tail_x15_r0_body.P174.lo && Nat.ble PRE_first_tail_x15_r0_body.P174.lo PRE_first_tail_x15_r0_body.cx0_174.mlx.next && Nat.ble PRE_first_tail_x15_r0_body.P174.lo RData.bigHi && Nat.ble RData.bigHi PRE_first_tail_x15_r0_body.P174.E) = true
kernel_rfl PRE_first_tail_x15_r0_body.ccnt174 : (Nat.ble PRE_first_tail_x15_r0_body.cx0_174.mlx.next PRE_first_tail_x15_r0_body.cx1_174.mlx.next && Nat.ble PRE_first_tail_x15_r0_body.cx0_174.mlx.nnext PRE_first_tail_x15_r0_body.cx1_174.mlx.nnext) = true
kernel_rfl PRE_first_tail_x15_r0_body.cnband174 : (Nat.blt 0 PRE_first_tail_x15_r0_body.P174.NL && Nat.ble PRE_first_tail_x15_r0_body.P174.NL PRE_first_tail_x15_r0_body.P174.N0 && Nat.ble PRE_first_tail_x15_r0_body.P174.N0 PRE_first_tail_x15_r0_body.cx0_174.mlx.nnext) = true
kernel_rfl PRE_first_tail_x15_r0_body.chbelow174 : PRE_first_tail_x15_r0_body.kd174.checkHndBelow = true
kernel_rfl PRE_first_tail_x15_r0_body.chren174 : checkRenG PRE_first_tail_x15_r0_body.kd174.hnd PRE_first_tail_x15_r0_body.khinv174 (phB PRE_first_tail_x15_r0_body.cx0_174.mlx) = true
kernel_rfl PRE_first_tail_x15_r0_body.cband174 : PRE_first_tail_x15_r0_body.kd174.checkBand PRE_first_tail_x15_r0_body.P174.lo = true
kernel_rfl PRE_first_tail_x15_r0_body.cnh1pos174 : Nat.blt 0 PRE_first_tail_x15_r0_body.kd174.nh1 = true
kernel_rfl PRE_first_tail_x15_r0_body.cnren174 : checkRenG PRE_first_tail_x15_r0_body.kd174.node PRE_first_tail_x15_r0_body.kninv174 (pnB PRE_first_tail_x15_r0_body.cx0_174.mlx) = true
kernel_rfl PRE_first_tail_x15_r0_body.cnlow174 : (PTrie.keysA PRE_first_tail_x15_r0_body.kd174.node).all (fun j => Nat.ble PRE_first_tail_x15_r0_body.P174.NL j && Nat.blt (PRE_first_tail_x15_r0_body.kd174.nodeF j) PRE_first_tail_x15_r0_body.cx1_174.mlx.nnext) = true
kernel_rfl PRE_first_tail_x15_r0_body.cabs0a174 : PRE_first_tail_x15_r0_body.cx0_174.mlx.arrs.get 0 = none
kernel_rfl PRE_first_tail_x15_r0_body.cabs0b174 : PRE_first_tail_x15_r0_body.cx0_174.mlx.objs.get 0 = none
kernel_rfl PRE_first_tail_x15_r0_body.ctok1174 : PRE_first_tail_x15_r0_body.cx1_174.mlx.tokens = []
kernel_rfl PRE_first_tail_x15_r0_body.cpend174 : PRE_first_tail_x15_r0_body.cx1_174.mlx.pending = PRE_first_tail_x15_r0_body.cx0_174.mlx.pending.map PRE_first_tail_x15_r0_body.kappa174.pend
kernel_rfl PRE_first_tail_x15_r0_body.cerrh174 : PRE_first_tail_x15_r0_body.cx1_174.mlx.errh = PRE_first_tail_x15_r0_body.cx0_174.mlx.errh.map PRE_first_tail_x15_r0_body.kappa174.arg
kernel_rfl PRE_first_tail_x15_r0_body.cfiles174 : PRE_first_tail_x15_r0_body.cx1_174.mlx.files = PRE_first_tail_x15_r0_body.cx0_174.mlx.files
kernel_rfl PRE_first_tail_x15_r0_body.carch174 : PRE_first_tail_x15_r0_body.cx1_174.mlx.arch = PRE_first_tail_x15_r0_body.cx0_174.mlx.arch
kernel_rfl PRE_first_tail_x15_r0_body.csizes174 : PRE_first_tail_x15_r0_body.cx1_174.mlx.deviceSizes = PRE_first_tail_x15_r0_body.cx0_174.mlx.deviceSizes
kernel_rfl PRE_first_tail_x15_r0_body.cwired174 : PRE_first_tail_x15_r0_body.cx1_174.mlx.wired = PRE_first_tail_x15_r0_body.cx0_174.mlx.wired
kernel_rfl PRE_first_tail_x15_r0_body.chost174 : PRE_first_tail_x15_r0_body.cx1_174.host = PRE_first_tail_x15_r0_body.cx0_174.host
-- the compaction map's addresses are `PRE_first_tail_x15_r0_body.kd174`'s
kernel_rfl PRE_first_tail_x15_r0_body.ckn0174 : PRE_first_tail_x15_r0_body.kd174.n0 = 2811825
kernel_rfl PRE_first_tail_x15_r0_body.ckn1174 : PRE_first_tail_x15_r0_body.kd174.n1 = 2812974
kernel_rfl PRE_first_tail_x15_r0_body.ckheap174 : (PTrie.keysA PRE_first_tail_x15_r0_body.kd174.heap).all (fun x => Nat.ble 2811819 x) = true
kernel_rfl PRE_first_tail_x15_r0_body.ckpl174 : (List.range 6).all (fun j => decide (PRE_first_tail_x15_r0_body.kd174.heap.get (2811819 + j) = nth? PRE_first_tail_x15_r0_body.pl174 j)) = true
-- the map fixes the call's names (`Conv.fixOld_compact`), the call's counters
kernel_rfl PRE_first_tail_x15_r0_body.fja174 : Nat.ble 2811819 2811819 = true
kernel_rfl PRE_first_tail_x15_r0_body.fn174 : Nat.ble 7523 7523 = true
kernel_rfl PRE_first_tail_x15_r0_body.fjaD174 : Nat.ble 2811819 PRE_first_tail_x15_r0_body.kd174.n0 = true
kernel_rfl PRE_first_tail_x15_r0_body.fxn174 : Nat.ble 21634 PRE_first_tail_x15_r0_body.kd174.nh0 = true
kernel_rfl PRE_first_tail_x15_r0_body.fnn174 : Nat.ble 18722 PRE_first_tail_x15_r0_body.kd174.nn0 = true
kernel_rfl PRE_first_tail_x15_r0_body.fxb174 : Nat.ble 21634 RData.bigHi = true
kernel_rfl PRE_first_tail_x15_r0_body.fheap174 : (PTrie.keysA PRE_first_tail_x15_r0_body.kd174.heap).all (Nat.ble (⟨21634, 18722, 2811819, 7523⟩ : Conv.Cnt).ja) = true
kernel_rfl PRE_first_tail_x15_r0_body.fhnd174 : (PTrie.keysA PRE_first_tail_x15_r0_body.kd174.hnd).all (Nat.ble (⟨21634, 18722, 2811819, 7523⟩ : Conv.Cnt).xn) = true
kernel_rfl PRE_first_tail_x15_r0_body.fnode174 : (PTrie.keysA PRE_first_tail_x15_r0_body.kd174.node).all (Nat.ble (⟨21634, 18722, 2811819, 7523⟩ : Conv.Cnt).nn) = true
/-- The compaction map fixes the call's names. -/
theorem PRE_first_tail_x15_r0_body.cfix174 : Conv.FixOld (⟨21634, 18722, 2811819, 7523⟩ : Conv.Cnt) PRE_first_tail_x15_r0_body.kappa174 :=
  Conv.fixOld_compact (Nat.le_of_ble_eq_true PRE_first_tail_x15_r0_body.fja174) (Nat.le_of_ble_eq_true PRE_first_tail_x15_r0_body.fn174) (Nat.le_of_ble_eq_true PRE_first_tail_x15_r0_body.fjaD174) (Nat.le_of_ble_eq_true PRE_first_tail_x15_r0_body.fxn174) (Nat.le_of_ble_eq_true PRE_first_tail_x15_r0_body.fnn174) (Nat.le_of_ble_eq_true PRE_first_tail_x15_r0_body.fxb174) PRE_first_tail_x15_r0_body.fheap174 PRE_first_tail_x15_r0_body.fhnd174 PRE_first_tail_x15_r0_body.fnode174
kernel_rfl PRE_first_tail_x15_r0_body.fcxn174 : (⟨21634, 18722, 2811819, 7523⟩ : Conv.Cnt).xn = (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1684.ffi).mlx.next
kernel_rfl PRE_first_tail_x15_r0_body.fcnn174 : (⟨21634, 18722, 2811819, 7523⟩ : Conv.Cnt).nn = (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1684.ffi).mlx.nnext
kernel_rfl PRE_first_tail_x15_r0_body.fle0174 : (Nat.ble (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1684.ffi).mlx.next PRE_first_tail_x15_r0_body.cx0_174.mlx.next && Nat.ble (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1684.ffi).mlx.nnext PRE_first_tail_x15_r0_body.cx0_174.mlx.nnext && Nat.ble (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1684.ffi).mlx.next RData.bigHi) = true
kernel_rfl PRE_first_tail_x15_r0_body.fnk174 : (PTrie.keysA PRE_first_tail_x15_r0_body.kd174.node).all (Nat.ble (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1684.ffi).mlx.nnext) = true
-- the merged state keeps the call's entries off the stage's footprint
kernel_rfl PRE_first_tail_x15_r0_body.f1A174 : PRE_first_tail_x15_r0_body.cx1_174.mlx.arrs = Stage.setAll (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1684.ffi).mlx.arrs (PRE_first_tail_x15_r0_body.cwS174.filterMap fun i => (PRE_first_tail_x15_r0_body.cx1_174.mlx.arrs.get i).map (i, ·))
kernel_rfl PRE_first_tail_x15_r0_body.f1O174 : PRE_first_tail_x15_r0_body.cx1_174.mlx.objs = Stage.setAll (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1684.ffi).mlx.objs (PRE_first_tail_x15_r0_body.cwS174.filterMap fun i => (PRE_first_tail_x15_r0_body.cx1_174.mlx.objs.get i).map (i, ·))
kernel_rfl PRE_first_tail_x15_r0_body.f1N174 : PRE_first_tail_x15_r0_body.cx1_174.mlx.nodes = Stage.setAll (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1684.ffi).mlx.nodes (PRE_first_tail_x15_r0_body.cnS174.filterMap fun i => (PRE_first_tail_x15_r0_body.cx1_174.mlx.nodes.get i).map (i, ·))
kernel_rfl PRE_first_tail_x15_r0_body.f1I174 : PRE_first_tail_x15_r0_body.cx1_174.mlx.items = Stage.setAll (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1684.ffi).mlx.items (PRE_first_tail_x15_r0_body.ciS174.filterMap fun i => (PRE_first_tail_x15_r0_body.cx1_174.mlx.items.get i).map (i, ·))
kernel_rfl PRE_first_tail_x15_r0_body.fbd174 : (PRE_first_tail_x15_r0_body.clo174 ++ PRE_first_tail_x15_r0_body.cln174 ++ PRE_first_tail_x15_r0_body.cli174 ++ PRE_first_tail_x15_r0_body.cwS174 ++ PRE_first_tail_x15_r0_body.cnS174 ++ PRE_first_tail_x15_r0_body.ciS174).all (fun i => Nat.blt (i / 4096) (4 ^ 31)) = true
kernel_rfl PRE_first_tail_x15_r0_body.fincW174 : PRE_first_tail_x15_r0_body.cwS174.all (fun h => !Nat.blt h (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1684.ffi).mlx.next || PRE_first_tail_x15_r0_body.clo174.contains h) = true
kernel_rfl PRE_first_tail_x15_r0_body.fincI174 : PRE_first_tail_x15_r0_body.ciS174.all (fun k => !Nat.blt k (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1684.ffi).mlx.nnext || PRE_first_tail_x15_r0_body.cli174.contains k) = true
kernel_rfl PRE_first_tail_x15_r0_body.fincN174 : PRE_first_tail_x15_r0_body.cnS174.all (Nat.ble (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1684.ffi).mlx.nnext) = true
kernel_rfl PRE_first_tail_x15_r0_body.flnF174 : PRE_first_tail_x15_r0_body.cln174.all (Nat.ble (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1684.ffi).mlx.nnext) = true
-- the checks over the changed lists
kernel_rfl PRE_first_tail_x15_r0_body.fh174 : PRE_first_tail_x15_r0_body.clo174.all (handleOK PRE_first_tail_x15_r0_body.kappa174 PRE_first_tail_x15_r0_body.P174.lo PRE_first_tail_x15_r0_body.cx0_174.mlx PRE_first_tail_x15_r0_body.cx1_174.mlx) = true
kernel_rfl PRE_first_tail_x15_r0_body.fo174 : PRE_first_tail_x15_r0_body.clo174.map (fun h => PRE_first_tail_x15_r0_body.cx1_174.mlx.objs.get (PRE_first_tail_x15_r0_body.kappa174.handle h)) = PRE_first_tail_x15_r0_body.clo174.map (fun h => (PRE_first_tail_x15_r0_body.cx0_174.mlx.objs.get h).map PRE_first_tail_x15_r0_body.kappa174.nobj)
kernel_rfl PRE_first_tail_x15_r0_body.fok174 : PRE_first_tail_x15_r0_body.clo174.all (objOK PRE_first_tail_x15_r0_body.kappa174 PRE_first_tail_x15_r0_body.P174.NL PRE_first_tail_x15_r0_body.cx0_174.mlx) = true
kernel_rfl PRE_first_tail_x15_r0_body.fnd174 : PRE_first_tail_x15_r0_body.cln174.all (nodeOKF PRE_first_tail_x15_r0_body.kappa174 PRE_first_tail_x15_r0_body.P174 PRE_first_tail_x15_r0_body.cx0_174.mlx PRE_first_tail_x15_r0_body.cx1_174.mlx) = true
kernel_rfl PRE_first_tail_x15_r0_body.fp174 : ((PRE_first_tail_x15_r0_body.cln174.filter (fullB PRE_first_tail_x15_r0_body.P174))).map (fun i => (PRE_first_tail_x15_r0_body.cx1_174.mlx.nodes.get (PRE_first_tail_x15_r0_body.kappa174.node i)).map Host.Mlx.Ffi.Node.prim) =
  ((PRE_first_tail_x15_r0_body.cln174.filter (fullB PRE_first_tail_x15_r0_body.P174))).map (fun i => (PRE_first_tail_x15_r0_body.cx0_174.mlx.nodes.get i).map fun nd => PRE_first_tail_x15_r0_body.kappa174.prim nd.prim)
kernel_rfl PRE_first_tail_x15_r0_body.fnordI174 : incrB PRE_first_tail_x15_r0_body.kd174.nodeF (List.range' 18722 27) = true
kernel_rfl PRE_first_tail_x15_r0_body.fnordK174 : (PTrie.keysA PRE_first_tail_x15_r0_body.kd174.node).all (fun k => Nat.ble 18722 k && Nat.blt k 18749) = true
kernel_rfl PRE_first_tail_x15_r0_body.fnordL174 : (PRE_first_tail_x15_r0_body.cln174.filter (Nat.ble PRE_first_tail_x15_r0_body.P174.N0)).all (fun i => Nat.ble i (PRE_first_tail_x15_r0_body.kd174.nodeF i) && (Nat.blt i 18749 || Nat.ble PRE_first_tail_x15_r0_body.kd174.nn0 i)) = true
theorem PRE_first_tail_x15_r0_body.fnord174 : (PRE_first_tail_x15_r0_body.cln174.filter (Nat.ble PRE_first_tail_x15_r0_body.P174.N0)).all (fun i => Nat.ble i (PRE_first_tail_x15_r0_body.kd174.nodeF i) &&
    (PTrie.keysA PRE_first_tail_x15_r0_body.kd174.node).all fun j => !Nat.blt j i || Nat.blt (PRE_first_tail_x15_r0_body.kd174.nodeF j) (PRE_first_tail_x15_r0_body.kd174.nodeF i)) = true :=
  cnord_of PRE_first_tail_x15_r0_body.cnlow174 PRE_first_tail_x15_r0_body.cnn1174 PRE_first_tail_x15_r0_body.fnordI174 PRE_first_tail_x15_r0_body.fnordK174 PRE_first_tail_x15_r0_body.fnordL174
kernel_rfl PRE_first_tail_x15_r0_body.fi174 : PRE_first_tail_x15_r0_body.cli174.all (pnB PRE_first_tail_x15_r0_body.cx0_174.mlx) = true
kernel_rfl PRE_first_tail_x15_r0_body.fii174 : PRE_first_tail_x15_r0_body.cli174.all (fun k => decide (PRE_first_tail_x15_r0_body.cx1_174.mlx.items.get (PRE_first_tail_x15_r0_body.kappa174.node k) = (PRE_first_tail_x15_r0_body.cx0_174.mlx.items.get k).map PRE_first_tail_x15_r0_body.kappa174.nv)) = true
/-- **The compaction's footprint.** -/
theorem PRE_first_tail_x15_r0_body.cfoot174 (clean : Conv.NClean (⟨21634, 18722, 2811819, 7523⟩ : Conv.Cnt) (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1684.ffi).mlx) (hltC : ∀ h, PH (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1684.ffi).mlx h → h < (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1684.ffi).mlx.next) (nltC : ∀ i, PN (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1684.ffi).mlx i → i < (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1684.ffi).mlx.nnext) (itemsC : ∀ k v, (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1684.ffi).mlx.items.get k = some v → PN (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1684.ffi).mlx k) (tracedC : ∀ h o, (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1684.ffi).mlx.objs.get h = some o → ∀ i ∈ objTraces o, i < PRE_first_tail_x15_r0_body.P174.NL) (cl : SSt (· < 7541) PRE_first_tail_x15_r0_body.cx0_174.mlx) :
    Conv.MFoot PRE_first_tail_x15_r0_body.P174 7541 PRE_first_tail_x15_r0_body.kappa174 PRE_first_tail_x15_r0_body.kd174 PRE_first_tail_x15_r0_body.khinv174 PRE_first_tail_x15_r0_body.kninv174 (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1684.ffi).mlx PRE_first_tail_x15_r0_body.cx0_174.mlx PRE_first_tail_x15_r0_body.cx1_174.mlx (⟨21634, 18722, 2811819, 7523⟩ : Conv.Cnt) PRE_first_tail_x15_r0_body.clo174 PRE_first_tail_x15_r0_body.cln174 PRE_first_tail_x15_r0_body.cli174 PRE_first_tail_x15_r0_body.cwS174 PRE_first_tail_x15_r0_body.cnS174 PRE_first_tail_x15_r0_body.ciS174 :=
  ⟨rfl, rfl, rfl, PRE_first_tail_x15_r0_body.cnh0174, PRE_first_tail_x15_r0_body.cnh1174, PRE_first_tail_x15_r0_body.cnn0174, PRE_first_tail_x15_r0_body.cnn1174, PRE_first_tail_x15_r0_body.cplo174, PRE_first_tail_x15_r0_body.ccnt174, PRE_first_tail_x15_r0_body.cnband174, PRE_first_tail_x15_r0_body.chbelow174, PRE_first_tail_x15_r0_body.chren174, PRE_first_tail_x15_r0_body.cband174, PRE_first_tail_x15_r0_body.cnh1pos174, PRE_first_tail_x15_r0_body.cnren174, PRE_first_tail_x15_r0_body.cnlow174, PRE_first_tail_x15_r0_body.cabs0a174, PRE_first_tail_x15_r0_body.cabs0b174, PRE_first_tail_x15_r0_body.ctok1174, PRE_first_tail_x15_r0_body.cpend174, PRE_first_tail_x15_r0_body.cerrh174, PRE_first_tail_x15_r0_body.cfiles174, PRE_first_tail_x15_r0_body.carch174, PRE_first_tail_x15_r0_body.csizes174, PRE_first_tail_x15_r0_body.cwired174, PRE_first_tail_x15_r0_body.cfix174, clean, PRE_first_tail_x15_r0_body.fcxn174, PRE_first_tail_x15_r0_body.fcnn174, hltC, nltC, itemsC, tracedC, cl, PRE_first_tail_x15_r0_body.fle0174, PRE_first_tail_x15_r0_body.fnk174, PRE_first_tail_x15_r0_body.ckA174, PRE_first_tail_x15_r0_body.cobjsK174, PRE_first_tail_x15_r0_body.cnodesK174, PRE_first_tail_x15_r0_body.citemsK174, PRE_first_tail_x15_r0_body.f1A174, PRE_first_tail_x15_r0_body.f1O174, PRE_first_tail_x15_r0_body.f1N174, PRE_first_tail_x15_r0_body.f1I174, PRE_first_tail_x15_r0_body.fbd174, PRE_first_tail_x15_r0_body.fincW174, PRE_first_tail_x15_r0_body.fincI174, PRE_first_tail_x15_r0_body.fincN174, PRE_first_tail_x15_r0_body.flnF174, PRE_first_tail_x15_r0_body.fh174, PRE_first_tail_x15_r0_body.fo174, PRE_first_tail_x15_r0_body.fok174, PRE_first_tail_x15_r0_body.fnd174, PRE_first_tail_x15_r0_body.fp174, PRE_first_tail_x15_r0_body.fnord174, PRE_first_tail_x15_r0_body.fi174, PRE_first_tail_x15_r0_body.fii174⟩
theorem PRE_first_tail_x15_r0_body.cnshift174 (clean : Conv.NClean (⟨21634, 18722, 2811819, 7523⟩ : Conv.Cnt) (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1684.ffi).mlx) (hltC : ∀ h, PH (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1684.ffi).mlx h → h < (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1684.ffi).mlx.next) (nltC : ∀ i, PN (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1684.ffi).mlx i → i < (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1684.ffi).mlx.nnext) (itemsC : ∀ k v, (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1684.ffi).mlx.items.get k = some v → PN (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1684.ffi).mlx k) (tracedC : ∀ h o, (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1684.ffi).mlx.objs.get h = some o → ∀ i ∈ objTraces o, i < PRE_first_tail_x15_r0_body.P174.NL) (cl : SSt (· < 7541) PRE_first_tail_x15_r0_body.cx0_174.mlx) : NShift PRE_first_tail_x15_r0_body.P174 7541 PRE_first_tail_x15_r0_body.kappa174 PRE_first_tail_x15_r0_body.cx0_174 PRE_first_tail_x15_r0_body.cx1_174 :=
  Conv.nshift_of_foot (PRE_first_tail_x15_r0_body.cfoot174 clean hltC nltC itemsC tracedC cl) PRE_first_tail_x15_r0_body.chost174 (compact_a_eq PRE_first_tail_x15_r0_body.ckn0174 PRE_first_tail_x15_r0_body.ckn1174 PRE_first_tail_x15_r0_body.ckheap174 PRE_first_tail_x15_r0_body.ckpl174)

-- the observers: the layers' states at the call, the canonical and the merged state, their footprints and checks
noncomputable def PRE_first_tail_x15_r0_body.fxC_174 : PTrie Unit := (Host.Ts.Sim.Full.freedOf PRE_first_tail_x15_r0_body.s1684.ffi).getD PTrie.nil
noncomputable def PRE_first_tail_x15_r0_body.krC_174 : Host.Load.Layers.KRec := (Host.Ts.Sim.Full.krecOf PRE_first_tail_x15_r0_body.s1684.ffi).getD Host.Load.Layers.KRec.empty
kernel_rfl PRE_first_tail_x15_r0_body.ofxC_174 : (Host.Ts.Sim.Full.freedOf PRE_first_tail_x15_r0_body.s1684.ffi) = some PRE_first_tail_x15_r0_body.fxC_174
kernel_rfl PRE_first_tail_x15_r0_body.okrC_174 : (Host.Ts.Sim.Full.krecOf PRE_first_tail_x15_r0_body.s1684.ffi) = some PRE_first_tail_x15_r0_body.krC_174
noncomputable def PRE_first_tail_x15_r0_body.fx0_174 : PTrie Unit := (Host.Ts.Sim.Full.freedOf PRE_first_tail_x15_r0_body.s1686.ffi).getD PTrie.nil
noncomputable def PRE_first_tail_x15_r0_body.kr0_174 : Host.Load.Layers.KRec := (Host.Ts.Sim.Full.krecOf PRE_first_tail_x15_r0_body.s1686.ffi).getD Host.Load.Layers.KRec.empty
kernel_rfl PRE_first_tail_x15_r0_body.ofx0_174 : (Host.Ts.Sim.Full.freedOf PRE_first_tail_x15_r0_body.s1686.ffi) = some PRE_first_tail_x15_r0_body.fx0_174
kernel_rfl PRE_first_tail_x15_r0_body.okr0_174 : (Host.Ts.Sim.Full.krecOf PRE_first_tail_x15_r0_body.s1686.ffi) = some PRE_first_tail_x15_r0_body.kr0_174
noncomputable def PRE_first_tail_x15_r0_body.fx1_174 : PTrie Unit := (Host.Ts.Sim.Full.freedOf PRE_first_tail_x15_r0_body.s1685.ffi).getD PTrie.nil
noncomputable def PRE_first_tail_x15_r0_body.kr1_174 : Host.Load.Layers.KRec := (Host.Ts.Sim.Full.krecOf PRE_first_tail_x15_r0_body.s1685.ffi).getD Host.Load.Layers.KRec.empty
kernel_rfl PRE_first_tail_x15_r0_body.ofx1_174 : (Host.Ts.Sim.Full.freedOf PRE_first_tail_x15_r0_body.s1685.ffi) = some PRE_first_tail_x15_r0_body.fx1_174
kernel_rfl PRE_first_tail_x15_r0_body.okr1_174 : (Host.Ts.Sim.Full.krecOf PRE_first_tail_x15_r0_body.s1685.ffi) = some PRE_first_tail_x15_r0_body.kr1_174
kernel_rfl PRE_first_tail_x15_r0_body.ff0174 : PRE_first_tail_x15_r0_body.fx0_174 = Stage.setAll PRE_first_tail_x15_r0_body.fxC_174 (PRE_first_tail_x15_r0_body.clo174.filterMap fun i => (PRE_first_tail_x15_r0_body.fx0_174.get i).map (i, ·))
kernel_rfl PRE_first_tail_x15_r0_body.ff1174 : PRE_first_tail_x15_r0_body.fx1_174 = Stage.setAll PRE_first_tail_x15_r0_body.fxC_174 (PRE_first_tail_x15_r0_body.cwS174.filterMap fun i => (PRE_first_tail_x15_r0_body.fx1_174.get i).map (i, ·))
kernel_rfl PRE_first_tail_x15_r0_body.ffck174 : freedLB PRE_first_tail_x15_r0_body.kappa174 PRE_first_tail_x15_r0_body.cx0_174.mlx PRE_first_tail_x15_r0_body.fx0_174 PRE_first_tail_x15_r0_body.fx1_174 PRE_first_tail_x15_r0_body.clo174 = true
kernel_rfl PRE_first_tail_x15_r0_body.fkf0174 : PRE_first_tail_x15_r0_body.kr0_174.flags = Stage.setAll PRE_first_tail_x15_r0_body.krC_174.flags (PRE_first_tail_x15_r0_body.clo174.filterMap fun i => (PRE_first_tail_x15_r0_body.kr0_174.flags.get i).map (i, ·))
kernel_rfl PRE_first_tail_x15_r0_body.fkt0174 : PRE_first_tail_x15_r0_body.kr0_174.targs = Stage.setAll PRE_first_tail_x15_r0_body.krC_174.targs (PRE_first_tail_x15_r0_body.clo174.filterMap fun i => (PRE_first_tail_x15_r0_body.kr0_174.targs.get i).map (i, ·))
kernel_rfl PRE_first_tail_x15_r0_body.fkf1174 : PRE_first_tail_x15_r0_body.kr1_174.flags = Stage.setAll PRE_first_tail_x15_r0_body.krC_174.flags (PRE_first_tail_x15_r0_body.cwS174.filterMap fun i => (PRE_first_tail_x15_r0_body.kr1_174.flags.get i).map (i, ·))
kernel_rfl PRE_first_tail_x15_r0_body.fkt1174 : PRE_first_tail_x15_r0_body.kr1_174.targs = Stage.setAll PRE_first_tail_x15_r0_body.krC_174.targs (PRE_first_tail_x15_r0_body.cwS174.filterMap fun i => (PRE_first_tail_x15_r0_body.kr1_174.targs.get i).map (i, ·))
kernel_rfl PRE_first_tail_x15_r0_body.fkck174 : krecLB PRE_first_tail_x15_r0_body.kappa174 7541 PRE_first_tail_x15_r0_body.cx0_174.mlx PRE_first_tail_x15_r0_body.kr0_174 PRE_first_tail_x15_r0_body.kr1_174 PRE_first_tail_x15_r0_body.clo174 = true
kernel_rfl PRE_first_tail_x15_r0_body.fkn174 : Nat.ble 7523 7541 = true
-- the bridge and the pending traces' regions
kernel_rfl PRE_first_tail_x15_r0_body.cbridge174 : Host.Ts.Sim.Full.bridgeOf PRE_first_tail_x15_r0_body.s1685.ffi = Host.Ts.Sim.Full.bridgeOf PRE_first_tail_x15_r0_body.s1686.ffi
kernel_rfl PRE_first_tail_x15_r0_body.cpendR174 : pendRegB PRE_first_tail_x15_r0_body.kappa174 (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1686.ffi).mlx = true
kernel_rfl PRE_first_tail_x15_r0_body.cpendLe174 : Nat.ble (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1686.ffi).mlx.next (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1685.ffi).mlx.next = true
/-- **The compaction's native shift**, given the call's bookkeeping, its relation's facts (the model's and the
observers') and the canonical closedness. -/
theorem PRE_first_tail_x15_r0_body.cshift174 (clean : Conv.NClean (⟨21634, 18722, 2811819, 7523⟩ : Conv.Cnt) (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1684.ffi).mlx) (hltC : ∀ h, PH (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1684.ffi).mlx h → h < (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1684.ffi).mlx.next) (nltC : ∀ i, PN (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1684.ffi).mlx i → i < (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1684.ffi).mlx.nnext) (itemsC : ∀ k v, (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1684.ffi).mlx.items.get k = some v → PN (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1684.ffi).mlx k) (tracedC : ∀ h o, (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1684.ffi).mlx.objs.get h = some o → ∀ i ∈ objTraces o, i < PRE_first_tail_x15_r0_body.P174.NL) (cl : SSt (· < 7541) PRE_first_tail_x15_r0_body.cx0_174.mlx)
    (hobjC : ∀ h, PRE_first_tail_x15_r0_body.fxC_174.get h = some () → ((Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1684.ffi).mlx.objs.get h).isSome = true)
    (hfC : ∀ h, (PRE_first_tail_x15_r0_body.krC_174.flags.get h).isSome = true → ((Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1684.ffi).mlx.objs.get h).isSome = true)
    (htC : ∀ h, (PRE_first_tail_x15_r0_body.krC_174.targs.get h).isSome = true → ((Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1684.ffi).mlx.objs.get h).isSome = true)
    (hclC : ∀ h l, PRE_first_tail_x15_r0_body.krC_174.targs.get h = some l → Host.Ts.Sim.Full.STargs (· < (⟨21634, 18722, 2811819, 7523⟩ : Conv.Cnt).n) l) :
    Conv.FullShiftQ PRE_first_tail_x15_r0_body.P174 7541 PRE_first_tail_x15_r0_body.kappa174 PRE_first_tail_x15_r0_body.s1686.ffi PRE_first_tail_x15_r0_body.s1685.ffi :=
  ⟨PRE_first_tail_x15_r0_body.cnshift174 clean hltC nltC itemsC tracedC cl, PRE_first_tail_x15_r0_body.cqueue174, fun t ht => bSN_sound (List.all_eq_true.mp PRE_first_tail_x15_r0_body.ctokSupp174 t ht),
    PRE_first_tail_x15_r0_body.cbridge174,
    liveShift_foot (x0' := Host.Ts.Sim.Full.mlxOf PRE_first_tail_x15_r0_body.s1686.ffi) (x1' := Host.Ts.Sim.Full.mlxOf PRE_first_tail_x15_r0_body.s1685.ffi) (PRE_first_tail_x15_r0_body.cfoot174 clean hltC nltC itemsC tracedC cl) rfl PRE_first_tail_x15_r0_body.ofx0_174 PRE_first_tail_x15_r0_body.ofx1_174 hobjC PRE_first_tail_x15_r0_body.ff0174 PRE_first_tail_x15_r0_body.ff1174 PRE_first_tail_x15_r0_body.ffck174,
    kernShift_foot (x0' := Host.Ts.Sim.Full.mlxOf PRE_first_tail_x15_r0_body.s1686.ffi) (x1' := Host.Ts.Sim.Full.mlxOf PRE_first_tail_x15_r0_body.s1685.ffi) (PRE_first_tail_x15_r0_body.cfoot174 clean hltC nltC itemsC tracedC cl) rfl PRE_first_tail_x15_r0_body.okr0_174 PRE_first_tail_x15_r0_body.okr1_174 (Nat.le_of_ble_eq_true PRE_first_tail_x15_r0_body.fkn174) hfC htC hclC
      PRE_first_tail_x15_r0_body.fkf0174 PRE_first_tail_x15_r0_body.fkt0174 PRE_first_tail_x15_r0_body.fkf1174 PRE_first_tail_x15_r0_body.fkt1174 PRE_first_tail_x15_r0_body.fkck174,
    pendReg_of rfl PRE_first_tail_x15_r0_body.cnh0174 PRE_first_tail_x15_r0_body.cnh1174 (Nat.le_of_ble_eq_true PRE_first_tail_x15_r0_body.cpendLe174) PRE_first_tail_x15_r0_body.cpendR174⟩

end Host.Load.Run.Tpl
