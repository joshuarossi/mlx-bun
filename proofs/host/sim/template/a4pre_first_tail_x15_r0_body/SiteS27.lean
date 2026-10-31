import host.sim.template.a4pre_first_tail_x15_r0_body.SiteCl27
import host.sim.conv.CompactFull
import host.sim.template.FootGen
set_option Elab.async false
namespace Host.Load.Run.Tpl
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
open Host.Ts Host.Ts.Sim Host.Ts.Sim.Template

/-! The compaction's native shift at call site 27 from its footprint (`Conv.nshift_of_foot`), and the observers'
(`liveShift_foot`, `kernShift_foot`): `Conv.FullShiftQ` for `Conv.full_compactQ`, given the call's bookkeeping and its
relation's facts. -/

/-- The load parameters of the chain (band-free: its start's node counter as `NL` and `N0`). -/
def PRE_first_tail_x15_r0_body.Pc27 : LoadP := ⟨18151, 131072, 1099511627776, 15235, 15235, []⟩
/-- The site's band raised to the map's checked fixed-node prefix, including newly recorded closure traces. -/
def PRE_first_tail_x15_r0_body.P27 : LoadP := PRE_first_tail_x15_r0_body.Pc27.raise 15842
kernel_rfl PRE_first_tail_x15_r0_body.craise27 : Nat.ble PRE_first_tail_x15_r0_body.Pc27.N0 15842 = true
theorem PRE_first_tail_x15_r0_body.raised27 : Host.Ts.Sim.Full.Raised PRE_first_tail_x15_r0_body.Pc27 PRE_first_tail_x15_r0_body.P27 :=
  .inr ⟨15842, rfl, Nat.le_of_ble_eq_true PRE_first_tail_x15_r0_body.craise27, rfl⟩
noncomputable abbrev PRE_first_tail_x15_r0_body.cx0_27 : Host.Load.LSt := clearTokens (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s253.ffi)
noncomputable abbrev PRE_first_tail_x15_r0_body.cx1_27 : Host.Load.LSt := clearTokens (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s252.ffi)
def PRE_first_tail_x15_r0_body.khinv27 : PTrie Nat := Stage.setAll PTrie.nil [(18771, 18745), (18749, 18746), (18772, 18747)]
def PRE_first_tail_x15_r0_body.kninv27 : PTrie Nat := Stage.setAll PTrie.nil [(15815, 15815), (15816, 15816), (15817, 15817), (15818, 15818), (15819, 15819), (15820, 15820), (15821, 15821), (15822, 15822), (15823, 15823), (15824, 15824), (15825, 15825), (15826, 15826), (15827, 15827), (15828, 15828), (15829, 15829), (15830, 15830), (15831, 15831), (15832, 15832), (15833, 15833), (15834, 15834), (15835, 15835), (15836, 15836), (15837, 15837), (15838, 15838), (15839, 15839), (15840, 15840), (15841, 15841)]
/-- The stage's footprint: its written and fresh handles, fresh nodes, written and fresh items. -/
def PRE_first_tail_x15_r0_body.cwS27 : List Nat := [18725, 18738, 18744, 18745, 18746, 18747, 18748, 18749, 18750, 18751, 18752, 18753, 18754, 18755, 18756, 18757, 18758, 18759, 18760, 18761, 18762, 18763, 18764, 18765, 18766, 18767, 18768, 18769, 18770, 18771, 18772]
def PRE_first_tail_x15_r0_body.cnS27 : List Nat := List.range' 15815 27
def PRE_first_tail_x15_r0_body.ciS27 : List Nat := [] ++ List.range' 15815 27

-- the small checks (`MChecks`'s)
kernel_rfl PRE_first_tail_x15_r0_body.cnh027 : PRE_first_tail_x15_r0_body.kd27.nh0 = PRE_first_tail_x15_r0_body.cx0_27.mlx.next
kernel_rfl PRE_first_tail_x15_r0_body.cnh127 : PRE_first_tail_x15_r0_body.kd27.nh1 = PRE_first_tail_x15_r0_body.cx1_27.mlx.next
kernel_rfl PRE_first_tail_x15_r0_body.cnn027 : PRE_first_tail_x15_r0_body.kd27.nn0 = PRE_first_tail_x15_r0_body.cx0_27.mlx.nnext
kernel_rfl PRE_first_tail_x15_r0_body.cnn127 : PRE_first_tail_x15_r0_body.kd27.nn1 = PRE_first_tail_x15_r0_body.cx1_27.mlx.nnext
kernel_rfl PRE_first_tail_x15_r0_body.cplo27 : (Nat.blt 0 PRE_first_tail_x15_r0_body.P27.lo && Nat.ble PRE_first_tail_x15_r0_body.P27.lo PRE_first_tail_x15_r0_body.cx0_27.mlx.next && Nat.ble PRE_first_tail_x15_r0_body.P27.lo RData.bigHi && Nat.ble RData.bigHi PRE_first_tail_x15_r0_body.P27.E) = true
kernel_rfl PRE_first_tail_x15_r0_body.ccnt27 : (Nat.ble PRE_first_tail_x15_r0_body.cx0_27.mlx.next PRE_first_tail_x15_r0_body.cx1_27.mlx.next && Nat.ble PRE_first_tail_x15_r0_body.cx0_27.mlx.nnext PRE_first_tail_x15_r0_body.cx1_27.mlx.nnext) = true
kernel_rfl PRE_first_tail_x15_r0_body.cnband27 : (Nat.blt 0 PRE_first_tail_x15_r0_body.P27.NL && Nat.ble PRE_first_tail_x15_r0_body.P27.NL PRE_first_tail_x15_r0_body.P27.N0 && Nat.ble PRE_first_tail_x15_r0_body.P27.N0 PRE_first_tail_x15_r0_body.cx0_27.mlx.nnext) = true
kernel_rfl PRE_first_tail_x15_r0_body.chbelow27 : PRE_first_tail_x15_r0_body.kd27.checkHndBelow = true
kernel_rfl PRE_first_tail_x15_r0_body.chren27 : checkRenG PRE_first_tail_x15_r0_body.kd27.hnd PRE_first_tail_x15_r0_body.khinv27 (phB PRE_first_tail_x15_r0_body.cx0_27.mlx) = true
kernel_rfl PRE_first_tail_x15_r0_body.cband27 : PRE_first_tail_x15_r0_body.kd27.checkBand PRE_first_tail_x15_r0_body.P27.lo = true
kernel_rfl PRE_first_tail_x15_r0_body.cnh1pos27 : Nat.blt 0 PRE_first_tail_x15_r0_body.kd27.nh1 = true
kernel_rfl PRE_first_tail_x15_r0_body.cnren27 : checkRenG PRE_first_tail_x15_r0_body.kd27.node PRE_first_tail_x15_r0_body.kninv27 (pnB PRE_first_tail_x15_r0_body.cx0_27.mlx) = true
kernel_rfl PRE_first_tail_x15_r0_body.cnlow27 : (PTrie.keysA PRE_first_tail_x15_r0_body.kd27.node).all (fun j => Nat.ble PRE_first_tail_x15_r0_body.P27.NL j && Nat.blt (PRE_first_tail_x15_r0_body.kd27.nodeF j) PRE_first_tail_x15_r0_body.cx1_27.mlx.nnext) = true
kernel_rfl PRE_first_tail_x15_r0_body.cabs0a27 : PRE_first_tail_x15_r0_body.cx0_27.mlx.arrs.get 0 = none
kernel_rfl PRE_first_tail_x15_r0_body.cabs0b27 : PRE_first_tail_x15_r0_body.cx0_27.mlx.objs.get 0 = none
kernel_rfl PRE_first_tail_x15_r0_body.ctok127 : PRE_first_tail_x15_r0_body.cx1_27.mlx.tokens = []
kernel_rfl PRE_first_tail_x15_r0_body.cpend27 : PRE_first_tail_x15_r0_body.cx1_27.mlx.pending = PRE_first_tail_x15_r0_body.cx0_27.mlx.pending.map PRE_first_tail_x15_r0_body.kappa27.pend
kernel_rfl PRE_first_tail_x15_r0_body.cerrh27 : PRE_first_tail_x15_r0_body.cx1_27.mlx.errh = PRE_first_tail_x15_r0_body.cx0_27.mlx.errh.map PRE_first_tail_x15_r0_body.kappa27.arg
kernel_rfl PRE_first_tail_x15_r0_body.cfiles27 : PRE_first_tail_x15_r0_body.cx1_27.mlx.files = PRE_first_tail_x15_r0_body.cx0_27.mlx.files
kernel_rfl PRE_first_tail_x15_r0_body.carch27 : PRE_first_tail_x15_r0_body.cx1_27.mlx.arch = PRE_first_tail_x15_r0_body.cx0_27.mlx.arch
kernel_rfl PRE_first_tail_x15_r0_body.csizes27 : PRE_first_tail_x15_r0_body.cx1_27.mlx.deviceSizes = PRE_first_tail_x15_r0_body.cx0_27.mlx.deviceSizes
kernel_rfl PRE_first_tail_x15_r0_body.cwired27 : PRE_first_tail_x15_r0_body.cx1_27.mlx.wired = PRE_first_tail_x15_r0_body.cx0_27.mlx.wired
kernel_rfl PRE_first_tail_x15_r0_body.chost27 : PRE_first_tail_x15_r0_body.cx1_27.host = PRE_first_tail_x15_r0_body.cx0_27.host
-- the compaction map's addresses are `PRE_first_tail_x15_r0_body.kd27`'s
kernel_rfl PRE_first_tail_x15_r0_body.ckn027 : PRE_first_tail_x15_r0_body.kd27.n0 = 2696549
kernel_rfl PRE_first_tail_x15_r0_body.ckn127 : PRE_first_tail_x15_r0_body.kd27.n1 = 2697698
kernel_rfl PRE_first_tail_x15_r0_body.ckheap27 : (PTrie.keysA PRE_first_tail_x15_r0_body.kd27.heap).all (fun x => Nat.ble 2696543 x) = true
kernel_rfl PRE_first_tail_x15_r0_body.ckpl27 : (List.range 6).all (fun j => decide (PRE_first_tail_x15_r0_body.kd27.heap.get (2696543 + j) = nth? PRE_first_tail_x15_r0_body.pl27 j)) = true
-- the map fixes the call's names (`Conv.fixOld_compact`), the call's counters
kernel_rfl PRE_first_tail_x15_r0_body.fja27 : Nat.ble 2696543 2696543 = true
kernel_rfl PRE_first_tail_x15_r0_body.fn27 : Nat.ble 1238 1238 = true
kernel_rfl PRE_first_tail_x15_r0_body.fjaD27 : Nat.ble 2696543 PRE_first_tail_x15_r0_body.kd27.n0 = true
kernel_rfl PRE_first_tail_x15_r0_body.fxn27 : Nat.ble 18745 PRE_first_tail_x15_r0_body.kd27.nh0 = true
kernel_rfl PRE_first_tail_x15_r0_body.fnn27 : Nat.ble 15815 PRE_first_tail_x15_r0_body.kd27.nn0 = true
kernel_rfl PRE_first_tail_x15_r0_body.fxb27 : Nat.ble 18745 RData.bigHi = true
kernel_rfl PRE_first_tail_x15_r0_body.fheap27 : (PTrie.keysA PRE_first_tail_x15_r0_body.kd27.heap).all (Nat.ble (⟨18745, 15815, 2696543, 1238⟩ : Conv.Cnt).ja) = true
kernel_rfl PRE_first_tail_x15_r0_body.fhnd27 : (PTrie.keysA PRE_first_tail_x15_r0_body.kd27.hnd).all (Nat.ble (⟨18745, 15815, 2696543, 1238⟩ : Conv.Cnt).xn) = true
kernel_rfl PRE_first_tail_x15_r0_body.fnode27 : (PTrie.keysA PRE_first_tail_x15_r0_body.kd27.node).all (Nat.ble (⟨18745, 15815, 2696543, 1238⟩ : Conv.Cnt).nn) = true
/-- The compaction map fixes the call's names. -/
theorem PRE_first_tail_x15_r0_body.cfix27 : Conv.FixOld (⟨18745, 15815, 2696543, 1238⟩ : Conv.Cnt) PRE_first_tail_x15_r0_body.kappa27 :=
  Conv.fixOld_compact (Nat.le_of_ble_eq_true PRE_first_tail_x15_r0_body.fja27) (Nat.le_of_ble_eq_true PRE_first_tail_x15_r0_body.fn27) (Nat.le_of_ble_eq_true PRE_first_tail_x15_r0_body.fjaD27) (Nat.le_of_ble_eq_true PRE_first_tail_x15_r0_body.fxn27) (Nat.le_of_ble_eq_true PRE_first_tail_x15_r0_body.fnn27) (Nat.le_of_ble_eq_true PRE_first_tail_x15_r0_body.fxb27) PRE_first_tail_x15_r0_body.fheap27 PRE_first_tail_x15_r0_body.fhnd27 PRE_first_tail_x15_r0_body.fnode27
kernel_rfl PRE_first_tail_x15_r0_body.fcxn27 : (⟨18745, 15815, 2696543, 1238⟩ : Conv.Cnt).xn = (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s251.ffi).mlx.next
kernel_rfl PRE_first_tail_x15_r0_body.fcnn27 : (⟨18745, 15815, 2696543, 1238⟩ : Conv.Cnt).nn = (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s251.ffi).mlx.nnext
kernel_rfl PRE_first_tail_x15_r0_body.fle027 : (Nat.ble (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s251.ffi).mlx.next PRE_first_tail_x15_r0_body.cx0_27.mlx.next && Nat.ble (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s251.ffi).mlx.nnext PRE_first_tail_x15_r0_body.cx0_27.mlx.nnext && Nat.ble (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s251.ffi).mlx.next RData.bigHi) = true
kernel_rfl PRE_first_tail_x15_r0_body.fnk27 : (PTrie.keysA PRE_first_tail_x15_r0_body.kd27.node).all (Nat.ble (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s251.ffi).mlx.nnext) = true
-- the merged state keeps the call's entries off the stage's footprint
kernel_rfl PRE_first_tail_x15_r0_body.f1A27 : PRE_first_tail_x15_r0_body.cx1_27.mlx.arrs = Stage.setAll (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s251.ffi).mlx.arrs (PRE_first_tail_x15_r0_body.cwS27.filterMap fun i => (PRE_first_tail_x15_r0_body.cx1_27.mlx.arrs.get i).map (i, ·))
kernel_rfl PRE_first_tail_x15_r0_body.f1O27 : PRE_first_tail_x15_r0_body.cx1_27.mlx.objs = Stage.setAll (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s251.ffi).mlx.objs (PRE_first_tail_x15_r0_body.cwS27.filterMap fun i => (PRE_first_tail_x15_r0_body.cx1_27.mlx.objs.get i).map (i, ·))
kernel_rfl PRE_first_tail_x15_r0_body.f1N27 : PRE_first_tail_x15_r0_body.cx1_27.mlx.nodes = Stage.setAll (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s251.ffi).mlx.nodes (PRE_first_tail_x15_r0_body.cnS27.filterMap fun i => (PRE_first_tail_x15_r0_body.cx1_27.mlx.nodes.get i).map (i, ·))
kernel_rfl PRE_first_tail_x15_r0_body.f1I27 : PRE_first_tail_x15_r0_body.cx1_27.mlx.items = Stage.setAll (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s251.ffi).mlx.items (PRE_first_tail_x15_r0_body.ciS27.filterMap fun i => (PRE_first_tail_x15_r0_body.cx1_27.mlx.items.get i).map (i, ·))
kernel_rfl PRE_first_tail_x15_r0_body.fbd27 : (PRE_first_tail_x15_r0_body.clo27 ++ PRE_first_tail_x15_r0_body.cln27 ++ PRE_first_tail_x15_r0_body.cli27 ++ PRE_first_tail_x15_r0_body.cwS27 ++ PRE_first_tail_x15_r0_body.cnS27 ++ PRE_first_tail_x15_r0_body.ciS27).all (fun i => Nat.blt (i / 4096) (4 ^ 31)) = true
kernel_rfl PRE_first_tail_x15_r0_body.fincW27 : PRE_first_tail_x15_r0_body.cwS27.all (fun h => !Nat.blt h (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s251.ffi).mlx.next || PRE_first_tail_x15_r0_body.clo27.contains h) = true
kernel_rfl PRE_first_tail_x15_r0_body.fincI27 : PRE_first_tail_x15_r0_body.ciS27.all (fun k => !Nat.blt k (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s251.ffi).mlx.nnext || PRE_first_tail_x15_r0_body.cli27.contains k) = true
kernel_rfl PRE_first_tail_x15_r0_body.fincN27 : PRE_first_tail_x15_r0_body.cnS27.all (Nat.ble (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s251.ffi).mlx.nnext) = true
kernel_rfl PRE_first_tail_x15_r0_body.flnF27 : PRE_first_tail_x15_r0_body.cln27.all (Nat.ble (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s251.ffi).mlx.nnext) = true
-- the checks over the changed lists
kernel_rfl PRE_first_tail_x15_r0_body.fh27 : PRE_first_tail_x15_r0_body.clo27.all (handleOK PRE_first_tail_x15_r0_body.kappa27 PRE_first_tail_x15_r0_body.P27.lo PRE_first_tail_x15_r0_body.cx0_27.mlx PRE_first_tail_x15_r0_body.cx1_27.mlx) = true
kernel_rfl PRE_first_tail_x15_r0_body.fo27 : PRE_first_tail_x15_r0_body.clo27.map (fun h => PRE_first_tail_x15_r0_body.cx1_27.mlx.objs.get (PRE_first_tail_x15_r0_body.kappa27.handle h)) = PRE_first_tail_x15_r0_body.clo27.map (fun h => (PRE_first_tail_x15_r0_body.cx0_27.mlx.objs.get h).map PRE_first_tail_x15_r0_body.kappa27.nobj)
kernel_rfl PRE_first_tail_x15_r0_body.fok27 : PRE_first_tail_x15_r0_body.clo27.all (objOK PRE_first_tail_x15_r0_body.kappa27 PRE_first_tail_x15_r0_body.P27.NL PRE_first_tail_x15_r0_body.cx0_27.mlx) = true
kernel_rfl PRE_first_tail_x15_r0_body.fnd27 : PRE_first_tail_x15_r0_body.cln27.all (nodeOKF PRE_first_tail_x15_r0_body.kappa27 PRE_first_tail_x15_r0_body.P27 PRE_first_tail_x15_r0_body.cx0_27.mlx PRE_first_tail_x15_r0_body.cx1_27.mlx) = true
kernel_rfl PRE_first_tail_x15_r0_body.fp27 : ((PRE_first_tail_x15_r0_body.cln27.filter (fullB PRE_first_tail_x15_r0_body.P27))).map (fun i => (PRE_first_tail_x15_r0_body.cx1_27.mlx.nodes.get (PRE_first_tail_x15_r0_body.kappa27.node i)).map Host.Mlx.Ffi.Node.prim) =
  ((PRE_first_tail_x15_r0_body.cln27.filter (fullB PRE_first_tail_x15_r0_body.P27))).map (fun i => (PRE_first_tail_x15_r0_body.cx0_27.mlx.nodes.get i).map fun nd => PRE_first_tail_x15_r0_body.kappa27.prim nd.prim)
kernel_rfl PRE_first_tail_x15_r0_body.fnordI27 : incrB PRE_first_tail_x15_r0_body.kd27.nodeF (List.range' 15815 27) = true
kernel_rfl PRE_first_tail_x15_r0_body.fnordK27 : (PTrie.keysA PRE_first_tail_x15_r0_body.kd27.node).all (fun k => Nat.ble 15815 k && Nat.blt k 15842) = true
kernel_rfl PRE_first_tail_x15_r0_body.fnordL27 : (PRE_first_tail_x15_r0_body.cln27.filter (Nat.ble PRE_first_tail_x15_r0_body.P27.N0)).all (fun i => Nat.ble i (PRE_first_tail_x15_r0_body.kd27.nodeF i) && (Nat.blt i 15842 || Nat.ble PRE_first_tail_x15_r0_body.kd27.nn0 i)) = true
theorem PRE_first_tail_x15_r0_body.fnord27 : (PRE_first_tail_x15_r0_body.cln27.filter (Nat.ble PRE_first_tail_x15_r0_body.P27.N0)).all (fun i => Nat.ble i (PRE_first_tail_x15_r0_body.kd27.nodeF i) &&
    (PTrie.keysA PRE_first_tail_x15_r0_body.kd27.node).all fun j => !Nat.blt j i || Nat.blt (PRE_first_tail_x15_r0_body.kd27.nodeF j) (PRE_first_tail_x15_r0_body.kd27.nodeF i)) = true :=
  cnord_of PRE_first_tail_x15_r0_body.cnlow27 PRE_first_tail_x15_r0_body.cnn127 PRE_first_tail_x15_r0_body.fnordI27 PRE_first_tail_x15_r0_body.fnordK27 PRE_first_tail_x15_r0_body.fnordL27
kernel_rfl PRE_first_tail_x15_r0_body.fi27 : PRE_first_tail_x15_r0_body.cli27.all (pnB PRE_first_tail_x15_r0_body.cx0_27.mlx) = true
kernel_rfl PRE_first_tail_x15_r0_body.fii27 : PRE_first_tail_x15_r0_body.cli27.all (fun k => decide (PRE_first_tail_x15_r0_body.cx1_27.mlx.items.get (PRE_first_tail_x15_r0_body.kappa27.node k) = (PRE_first_tail_x15_r0_body.cx0_27.mlx.items.get k).map PRE_first_tail_x15_r0_body.kappa27.nv)) = true
/-- **The compaction's footprint.** -/
theorem PRE_first_tail_x15_r0_body.cfoot27 (clean : Conv.NClean (⟨18745, 15815, 2696543, 1238⟩ : Conv.Cnt) (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s251.ffi).mlx) (hltC : ∀ h, PH (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s251.ffi).mlx h → h < (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s251.ffi).mlx.next) (nltC : ∀ i, PN (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s251.ffi).mlx i → i < (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s251.ffi).mlx.nnext) (itemsC : ∀ k v, (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s251.ffi).mlx.items.get k = some v → PN (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s251.ffi).mlx k) (tracedC : ∀ h o, (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s251.ffi).mlx.objs.get h = some o → ∀ i ∈ objTraces o, i < PRE_first_tail_x15_r0_body.P27.NL) (cl : SSt (· < 1256) PRE_first_tail_x15_r0_body.cx0_27.mlx) :
    Conv.MFoot PRE_first_tail_x15_r0_body.P27 1256 PRE_first_tail_x15_r0_body.kappa27 PRE_first_tail_x15_r0_body.kd27 PRE_first_tail_x15_r0_body.khinv27 PRE_first_tail_x15_r0_body.kninv27 (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s251.ffi).mlx PRE_first_tail_x15_r0_body.cx0_27.mlx PRE_first_tail_x15_r0_body.cx1_27.mlx (⟨18745, 15815, 2696543, 1238⟩ : Conv.Cnt) PRE_first_tail_x15_r0_body.clo27 PRE_first_tail_x15_r0_body.cln27 PRE_first_tail_x15_r0_body.cli27 PRE_first_tail_x15_r0_body.cwS27 PRE_first_tail_x15_r0_body.cnS27 PRE_first_tail_x15_r0_body.ciS27 :=
  ⟨rfl, rfl, rfl, PRE_first_tail_x15_r0_body.cnh027, PRE_first_tail_x15_r0_body.cnh127, PRE_first_tail_x15_r0_body.cnn027, PRE_first_tail_x15_r0_body.cnn127, PRE_first_tail_x15_r0_body.cplo27, PRE_first_tail_x15_r0_body.ccnt27, PRE_first_tail_x15_r0_body.cnband27, PRE_first_tail_x15_r0_body.chbelow27, PRE_first_tail_x15_r0_body.chren27, PRE_first_tail_x15_r0_body.cband27, PRE_first_tail_x15_r0_body.cnh1pos27, PRE_first_tail_x15_r0_body.cnren27, PRE_first_tail_x15_r0_body.cnlow27, PRE_first_tail_x15_r0_body.cabs0a27, PRE_first_tail_x15_r0_body.cabs0b27, PRE_first_tail_x15_r0_body.ctok127, PRE_first_tail_x15_r0_body.cpend27, PRE_first_tail_x15_r0_body.cerrh27, PRE_first_tail_x15_r0_body.cfiles27, PRE_first_tail_x15_r0_body.carch27, PRE_first_tail_x15_r0_body.csizes27, PRE_first_tail_x15_r0_body.cwired27, PRE_first_tail_x15_r0_body.cfix27, clean, PRE_first_tail_x15_r0_body.fcxn27, PRE_first_tail_x15_r0_body.fcnn27, hltC, nltC, itemsC, tracedC, cl, PRE_first_tail_x15_r0_body.fle027, PRE_first_tail_x15_r0_body.fnk27, PRE_first_tail_x15_r0_body.ckA27, PRE_first_tail_x15_r0_body.cobjsK27, PRE_first_tail_x15_r0_body.cnodesK27, PRE_first_tail_x15_r0_body.citemsK27, PRE_first_tail_x15_r0_body.f1A27, PRE_first_tail_x15_r0_body.f1O27, PRE_first_tail_x15_r0_body.f1N27, PRE_first_tail_x15_r0_body.f1I27, PRE_first_tail_x15_r0_body.fbd27, PRE_first_tail_x15_r0_body.fincW27, PRE_first_tail_x15_r0_body.fincI27, PRE_first_tail_x15_r0_body.fincN27, PRE_first_tail_x15_r0_body.flnF27, PRE_first_tail_x15_r0_body.fh27, PRE_first_tail_x15_r0_body.fo27, PRE_first_tail_x15_r0_body.fok27, PRE_first_tail_x15_r0_body.fnd27, PRE_first_tail_x15_r0_body.fp27, PRE_first_tail_x15_r0_body.fnord27, PRE_first_tail_x15_r0_body.fi27, PRE_first_tail_x15_r0_body.fii27⟩
theorem PRE_first_tail_x15_r0_body.cnshift27 (clean : Conv.NClean (⟨18745, 15815, 2696543, 1238⟩ : Conv.Cnt) (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s251.ffi).mlx) (hltC : ∀ h, PH (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s251.ffi).mlx h → h < (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s251.ffi).mlx.next) (nltC : ∀ i, PN (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s251.ffi).mlx i → i < (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s251.ffi).mlx.nnext) (itemsC : ∀ k v, (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s251.ffi).mlx.items.get k = some v → PN (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s251.ffi).mlx k) (tracedC : ∀ h o, (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s251.ffi).mlx.objs.get h = some o → ∀ i ∈ objTraces o, i < PRE_first_tail_x15_r0_body.P27.NL) (cl : SSt (· < 1256) PRE_first_tail_x15_r0_body.cx0_27.mlx) : NShift PRE_first_tail_x15_r0_body.P27 1256 PRE_first_tail_x15_r0_body.kappa27 PRE_first_tail_x15_r0_body.cx0_27 PRE_first_tail_x15_r0_body.cx1_27 :=
  Conv.nshift_of_foot (PRE_first_tail_x15_r0_body.cfoot27 clean hltC nltC itemsC tracedC cl) PRE_first_tail_x15_r0_body.chost27 (compact_a_eq PRE_first_tail_x15_r0_body.ckn027 PRE_first_tail_x15_r0_body.ckn127 PRE_first_tail_x15_r0_body.ckheap27 PRE_first_tail_x15_r0_body.ckpl27)

-- the observers: the layers' states at the call, the canonical and the merged state, their footprints and checks
noncomputable def PRE_first_tail_x15_r0_body.fxC_27 : PTrie Unit := (Host.Ts.Sim.Full.freedOf PRE_first_tail_x15_r0_body.s251.ffi).getD PTrie.nil
noncomputable def PRE_first_tail_x15_r0_body.krC_27 : Host.Load.Layers.KRec := (Host.Ts.Sim.Full.krecOf PRE_first_tail_x15_r0_body.s251.ffi).getD Host.Load.Layers.KRec.empty
kernel_rfl PRE_first_tail_x15_r0_body.ofxC_27 : (Host.Ts.Sim.Full.freedOf PRE_first_tail_x15_r0_body.s251.ffi) = some PRE_first_tail_x15_r0_body.fxC_27
kernel_rfl PRE_first_tail_x15_r0_body.okrC_27 : (Host.Ts.Sim.Full.krecOf PRE_first_tail_x15_r0_body.s251.ffi) = some PRE_first_tail_x15_r0_body.krC_27
noncomputable def PRE_first_tail_x15_r0_body.fx0_27 : PTrie Unit := (Host.Ts.Sim.Full.freedOf PRE_first_tail_x15_r0_body.s253.ffi).getD PTrie.nil
noncomputable def PRE_first_tail_x15_r0_body.kr0_27 : Host.Load.Layers.KRec := (Host.Ts.Sim.Full.krecOf PRE_first_tail_x15_r0_body.s253.ffi).getD Host.Load.Layers.KRec.empty
kernel_rfl PRE_first_tail_x15_r0_body.ofx0_27 : (Host.Ts.Sim.Full.freedOf PRE_first_tail_x15_r0_body.s253.ffi) = some PRE_first_tail_x15_r0_body.fx0_27
kernel_rfl PRE_first_tail_x15_r0_body.okr0_27 : (Host.Ts.Sim.Full.krecOf PRE_first_tail_x15_r0_body.s253.ffi) = some PRE_first_tail_x15_r0_body.kr0_27
noncomputable def PRE_first_tail_x15_r0_body.fx1_27 : PTrie Unit := (Host.Ts.Sim.Full.freedOf PRE_first_tail_x15_r0_body.s252.ffi).getD PTrie.nil
noncomputable def PRE_first_tail_x15_r0_body.kr1_27 : Host.Load.Layers.KRec := (Host.Ts.Sim.Full.krecOf PRE_first_tail_x15_r0_body.s252.ffi).getD Host.Load.Layers.KRec.empty
kernel_rfl PRE_first_tail_x15_r0_body.ofx1_27 : (Host.Ts.Sim.Full.freedOf PRE_first_tail_x15_r0_body.s252.ffi) = some PRE_first_tail_x15_r0_body.fx1_27
kernel_rfl PRE_first_tail_x15_r0_body.okr1_27 : (Host.Ts.Sim.Full.krecOf PRE_first_tail_x15_r0_body.s252.ffi) = some PRE_first_tail_x15_r0_body.kr1_27
kernel_rfl PRE_first_tail_x15_r0_body.ff027 : PRE_first_tail_x15_r0_body.fx0_27 = Stage.setAll PRE_first_tail_x15_r0_body.fxC_27 (PRE_first_tail_x15_r0_body.clo27.filterMap fun i => (PRE_first_tail_x15_r0_body.fx0_27.get i).map (i, ·))
kernel_rfl PRE_first_tail_x15_r0_body.ff127 : PRE_first_tail_x15_r0_body.fx1_27 = Stage.setAll PRE_first_tail_x15_r0_body.fxC_27 (PRE_first_tail_x15_r0_body.cwS27.filterMap fun i => (PRE_first_tail_x15_r0_body.fx1_27.get i).map (i, ·))
kernel_rfl PRE_first_tail_x15_r0_body.ffck27 : freedLB PRE_first_tail_x15_r0_body.kappa27 PRE_first_tail_x15_r0_body.cx0_27.mlx PRE_first_tail_x15_r0_body.fx0_27 PRE_first_tail_x15_r0_body.fx1_27 PRE_first_tail_x15_r0_body.clo27 = true
kernel_rfl PRE_first_tail_x15_r0_body.fkf027 : PRE_first_tail_x15_r0_body.kr0_27.flags = Stage.setAll PRE_first_tail_x15_r0_body.krC_27.flags (PRE_first_tail_x15_r0_body.clo27.filterMap fun i => (PRE_first_tail_x15_r0_body.kr0_27.flags.get i).map (i, ·))
kernel_rfl PRE_first_tail_x15_r0_body.fkt027 : PRE_first_tail_x15_r0_body.kr0_27.targs = Stage.setAll PRE_first_tail_x15_r0_body.krC_27.targs (PRE_first_tail_x15_r0_body.clo27.filterMap fun i => (PRE_first_tail_x15_r0_body.kr0_27.targs.get i).map (i, ·))
kernel_rfl PRE_first_tail_x15_r0_body.fkf127 : PRE_first_tail_x15_r0_body.kr1_27.flags = Stage.setAll PRE_first_tail_x15_r0_body.krC_27.flags (PRE_first_tail_x15_r0_body.cwS27.filterMap fun i => (PRE_first_tail_x15_r0_body.kr1_27.flags.get i).map (i, ·))
kernel_rfl PRE_first_tail_x15_r0_body.fkt127 : PRE_first_tail_x15_r0_body.kr1_27.targs = Stage.setAll PRE_first_tail_x15_r0_body.krC_27.targs (PRE_first_tail_x15_r0_body.cwS27.filterMap fun i => (PRE_first_tail_x15_r0_body.kr1_27.targs.get i).map (i, ·))
kernel_rfl PRE_first_tail_x15_r0_body.fkck27 : krecLB PRE_first_tail_x15_r0_body.kappa27 1256 PRE_first_tail_x15_r0_body.cx0_27.mlx PRE_first_tail_x15_r0_body.kr0_27 PRE_first_tail_x15_r0_body.kr1_27 PRE_first_tail_x15_r0_body.clo27 = true
kernel_rfl PRE_first_tail_x15_r0_body.fkn27 : Nat.ble 1238 1256 = true
-- the bridge and the pending traces' regions
kernel_rfl PRE_first_tail_x15_r0_body.cbridge27 : Host.Ts.Sim.Full.bridgeOf PRE_first_tail_x15_r0_body.s252.ffi = Host.Ts.Sim.Full.bridgeOf PRE_first_tail_x15_r0_body.s253.ffi
kernel_rfl PRE_first_tail_x15_r0_body.cpendR27 : pendRegB PRE_first_tail_x15_r0_body.kappa27 (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s253.ffi).mlx = true
kernel_rfl PRE_first_tail_x15_r0_body.cpendLe27 : Nat.ble (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s253.ffi).mlx.next (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s252.ffi).mlx.next = true
/-- **The compaction's native shift**, given the call's bookkeeping, its relation's facts (the model's and the
observers') and the canonical closedness. -/
theorem PRE_first_tail_x15_r0_body.cshift27 (clean : Conv.NClean (⟨18745, 15815, 2696543, 1238⟩ : Conv.Cnt) (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s251.ffi).mlx) (hltC : ∀ h, PH (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s251.ffi).mlx h → h < (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s251.ffi).mlx.next) (nltC : ∀ i, PN (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s251.ffi).mlx i → i < (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s251.ffi).mlx.nnext) (itemsC : ∀ k v, (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s251.ffi).mlx.items.get k = some v → PN (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s251.ffi).mlx k) (tracedC : ∀ h o, (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s251.ffi).mlx.objs.get h = some o → ∀ i ∈ objTraces o, i < PRE_first_tail_x15_r0_body.P27.NL) (cl : SSt (· < 1256) PRE_first_tail_x15_r0_body.cx0_27.mlx)
    (hobjC : ∀ h, PRE_first_tail_x15_r0_body.fxC_27.get h = some () → ((Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s251.ffi).mlx.objs.get h).isSome = true)
    (hfC : ∀ h, (PRE_first_tail_x15_r0_body.krC_27.flags.get h).isSome = true → ((Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s251.ffi).mlx.objs.get h).isSome = true)
    (htC : ∀ h, (PRE_first_tail_x15_r0_body.krC_27.targs.get h).isSome = true → ((Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s251.ffi).mlx.objs.get h).isSome = true)
    (hclC : ∀ h l, PRE_first_tail_x15_r0_body.krC_27.targs.get h = some l → Host.Ts.Sim.Full.STargs (· < (⟨18745, 15815, 2696543, 1238⟩ : Conv.Cnt).n) l) :
    Conv.FullShiftQ PRE_first_tail_x15_r0_body.P27 1256 PRE_first_tail_x15_r0_body.kappa27 PRE_first_tail_x15_r0_body.s253.ffi PRE_first_tail_x15_r0_body.s252.ffi :=
  ⟨PRE_first_tail_x15_r0_body.cnshift27 clean hltC nltC itemsC tracedC cl, PRE_first_tail_x15_r0_body.cqueue27, fun t ht => bSN_sound (List.all_eq_true.mp PRE_first_tail_x15_r0_body.ctokSupp27 t ht),
    PRE_first_tail_x15_r0_body.cbridge27,
    liveShift_foot (x0' := Host.Ts.Sim.Full.mlxOf PRE_first_tail_x15_r0_body.s253.ffi) (x1' := Host.Ts.Sim.Full.mlxOf PRE_first_tail_x15_r0_body.s252.ffi) (PRE_first_tail_x15_r0_body.cfoot27 clean hltC nltC itemsC tracedC cl) rfl PRE_first_tail_x15_r0_body.ofx0_27 PRE_first_tail_x15_r0_body.ofx1_27 hobjC PRE_first_tail_x15_r0_body.ff027 PRE_first_tail_x15_r0_body.ff127 PRE_first_tail_x15_r0_body.ffck27,
    kernShift_foot (x0' := Host.Ts.Sim.Full.mlxOf PRE_first_tail_x15_r0_body.s253.ffi) (x1' := Host.Ts.Sim.Full.mlxOf PRE_first_tail_x15_r0_body.s252.ffi) (PRE_first_tail_x15_r0_body.cfoot27 clean hltC nltC itemsC tracedC cl) rfl PRE_first_tail_x15_r0_body.okr0_27 PRE_first_tail_x15_r0_body.okr1_27 (Nat.le_of_ble_eq_true PRE_first_tail_x15_r0_body.fkn27) hfC htC hclC
      PRE_first_tail_x15_r0_body.fkf027 PRE_first_tail_x15_r0_body.fkt027 PRE_first_tail_x15_r0_body.fkf127 PRE_first_tail_x15_r0_body.fkt127 PRE_first_tail_x15_r0_body.fkck27,
    pendReg_of rfl PRE_first_tail_x15_r0_body.cnh027 PRE_first_tail_x15_r0_body.cnh127 (Nat.le_of_ble_eq_true PRE_first_tail_x15_r0_body.cpendLe27) PRE_first_tail_x15_r0_body.cpendR27⟩

end Host.Load.Run.Tpl
