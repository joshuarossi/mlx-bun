import host.sim.template.a4pre_first_tail_x15_r0_body.SiteCl30
import host.sim.conv.CompactFull
import host.sim.template.FootGen
set_option Elab.async false
namespace Host.Load.Run.Tpl
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
open Host.Ts Host.Ts.Sim Host.Ts.Sim.Template

/-! The compaction's native shift at call site 30 from its footprint (`Conv.nshift_of_foot`), and the observers'
(`liveShift_foot`, `kernShift_foot`): `Conv.FullShiftQ` for `Conv.full_compactQ`, given the call's bookkeeping and its
relation's facts. -/

/-- The load parameters of the chain (band-free: its start's node counter as `NL` and `N0`). -/
def PRE_first_tail_x15_r0_body.Pc30 : LoadP := ⟨18151, 131072, 1099511627776, 15235, 15235, []⟩
/-- The site's band raised to the map's checked fixed-node prefix, including newly recorded closure traces. -/
def PRE_first_tail_x15_r0_body.P30 : LoadP := PRE_first_tail_x15_r0_body.Pc30.raise 15905
kernel_rfl PRE_first_tail_x15_r0_body.craise30 : Nat.ble PRE_first_tail_x15_r0_body.Pc30.N0 15905 = true
theorem PRE_first_tail_x15_r0_body.raised30 : Host.Ts.Sim.Full.Raised PRE_first_tail_x15_r0_body.Pc30 PRE_first_tail_x15_r0_body.P30 :=
  .inr ⟨15905, rfl, Nat.le_of_ble_eq_true PRE_first_tail_x15_r0_body.craise30, rfl⟩
noncomputable abbrev PRE_first_tail_x15_r0_body.cx0_30 : Host.Load.LSt := clearTokens (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s306.ffi)
noncomputable abbrev PRE_first_tail_x15_r0_body.cx1_30 : Host.Load.LSt := clearTokens (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s305.ffi)
def PRE_first_tail_x15_r0_body.khinv30 : PTrie Nat := Stage.setAll PTrie.nil [(18828, 18802), (18806, 18803), (18829, 18804)]
def PRE_first_tail_x15_r0_body.kninv30 : PTrie Nat := Stage.setAll PTrie.nil [(15878, 15878), (15879, 15879), (15880, 15880), (15881, 15881), (15882, 15882), (15883, 15883), (15884, 15884), (15885, 15885), (15886, 15886), (15887, 15887), (15888, 15888), (15889, 15889), (15890, 15890), (15891, 15891), (15892, 15892), (15893, 15893), (15894, 15894), (15895, 15895), (15896, 15896), (15897, 15897), (15898, 15898), (15899, 15899), (15900, 15900), (15901, 15901), (15902, 15902), (15903, 15903), (15904, 15904)]
/-- The stage's footprint: its written and fresh handles, fresh nodes, written and fresh items. -/
def PRE_first_tail_x15_r0_body.cwS30 : List Nat := [18782, 18795, 18801, 18802, 18803, 18804, 18805, 18806, 18807, 18808, 18809, 18810, 18811, 18812, 18813, 18814, 18815, 18816, 18817, 18818, 18819, 18820, 18821, 18822, 18823, 18824, 18825, 18826, 18827, 18828, 18829]
def PRE_first_tail_x15_r0_body.cnS30 : List Nat := List.range' 15878 27
def PRE_first_tail_x15_r0_body.ciS30 : List Nat := [] ++ List.range' 15878 27

-- the small checks (`MChecks`'s)
kernel_rfl PRE_first_tail_x15_r0_body.cnh030 : PRE_first_tail_x15_r0_body.kd30.nh0 = PRE_first_tail_x15_r0_body.cx0_30.mlx.next
kernel_rfl PRE_first_tail_x15_r0_body.cnh130 : PRE_first_tail_x15_r0_body.kd30.nh1 = PRE_first_tail_x15_r0_body.cx1_30.mlx.next
kernel_rfl PRE_first_tail_x15_r0_body.cnn030 : PRE_first_tail_x15_r0_body.kd30.nn0 = PRE_first_tail_x15_r0_body.cx0_30.mlx.nnext
kernel_rfl PRE_first_tail_x15_r0_body.cnn130 : PRE_first_tail_x15_r0_body.kd30.nn1 = PRE_first_tail_x15_r0_body.cx1_30.mlx.nnext
kernel_rfl PRE_first_tail_x15_r0_body.cplo30 : (Nat.blt 0 PRE_first_tail_x15_r0_body.P30.lo && Nat.ble PRE_first_tail_x15_r0_body.P30.lo PRE_first_tail_x15_r0_body.cx0_30.mlx.next && Nat.ble PRE_first_tail_x15_r0_body.P30.lo RData.bigHi && Nat.ble RData.bigHi PRE_first_tail_x15_r0_body.P30.E) = true
kernel_rfl PRE_first_tail_x15_r0_body.ccnt30 : (Nat.ble PRE_first_tail_x15_r0_body.cx0_30.mlx.next PRE_first_tail_x15_r0_body.cx1_30.mlx.next && Nat.ble PRE_first_tail_x15_r0_body.cx0_30.mlx.nnext PRE_first_tail_x15_r0_body.cx1_30.mlx.nnext) = true
kernel_rfl PRE_first_tail_x15_r0_body.cnband30 : (Nat.blt 0 PRE_first_tail_x15_r0_body.P30.NL && Nat.ble PRE_first_tail_x15_r0_body.P30.NL PRE_first_tail_x15_r0_body.P30.N0 && Nat.ble PRE_first_tail_x15_r0_body.P30.N0 PRE_first_tail_x15_r0_body.cx0_30.mlx.nnext) = true
kernel_rfl PRE_first_tail_x15_r0_body.chbelow30 : PRE_first_tail_x15_r0_body.kd30.checkHndBelow = true
kernel_rfl PRE_first_tail_x15_r0_body.chren30 : checkRenG PRE_first_tail_x15_r0_body.kd30.hnd PRE_first_tail_x15_r0_body.khinv30 (phB PRE_first_tail_x15_r0_body.cx0_30.mlx) = true
kernel_rfl PRE_first_tail_x15_r0_body.cband30 : PRE_first_tail_x15_r0_body.kd30.checkBand PRE_first_tail_x15_r0_body.P30.lo = true
kernel_rfl PRE_first_tail_x15_r0_body.cnh1pos30 : Nat.blt 0 PRE_first_tail_x15_r0_body.kd30.nh1 = true
kernel_rfl PRE_first_tail_x15_r0_body.cnren30 : checkRenG PRE_first_tail_x15_r0_body.kd30.node PRE_first_tail_x15_r0_body.kninv30 (pnB PRE_first_tail_x15_r0_body.cx0_30.mlx) = true
kernel_rfl PRE_first_tail_x15_r0_body.cnlow30 : (PTrie.keysA PRE_first_tail_x15_r0_body.kd30.node).all (fun j => Nat.ble PRE_first_tail_x15_r0_body.P30.NL j && Nat.blt (PRE_first_tail_x15_r0_body.kd30.nodeF j) PRE_first_tail_x15_r0_body.cx1_30.mlx.nnext) = true
kernel_rfl PRE_first_tail_x15_r0_body.cabs0a30 : PRE_first_tail_x15_r0_body.cx0_30.mlx.arrs.get 0 = none
kernel_rfl PRE_first_tail_x15_r0_body.cabs0b30 : PRE_first_tail_x15_r0_body.cx0_30.mlx.objs.get 0 = none
kernel_rfl PRE_first_tail_x15_r0_body.ctok130 : PRE_first_tail_x15_r0_body.cx1_30.mlx.tokens = []
kernel_rfl PRE_first_tail_x15_r0_body.cpend30 : PRE_first_tail_x15_r0_body.cx1_30.mlx.pending = PRE_first_tail_x15_r0_body.cx0_30.mlx.pending.map PRE_first_tail_x15_r0_body.kappa30.pend
kernel_rfl PRE_first_tail_x15_r0_body.cerrh30 : PRE_first_tail_x15_r0_body.cx1_30.mlx.errh = PRE_first_tail_x15_r0_body.cx0_30.mlx.errh.map PRE_first_tail_x15_r0_body.kappa30.arg
kernel_rfl PRE_first_tail_x15_r0_body.cfiles30 : PRE_first_tail_x15_r0_body.cx1_30.mlx.files = PRE_first_tail_x15_r0_body.cx0_30.mlx.files
kernel_rfl PRE_first_tail_x15_r0_body.carch30 : PRE_first_tail_x15_r0_body.cx1_30.mlx.arch = PRE_first_tail_x15_r0_body.cx0_30.mlx.arch
kernel_rfl PRE_first_tail_x15_r0_body.csizes30 : PRE_first_tail_x15_r0_body.cx1_30.mlx.deviceSizes = PRE_first_tail_x15_r0_body.cx0_30.mlx.deviceSizes
kernel_rfl PRE_first_tail_x15_r0_body.cwired30 : PRE_first_tail_x15_r0_body.cx1_30.mlx.wired = PRE_first_tail_x15_r0_body.cx0_30.mlx.wired
kernel_rfl PRE_first_tail_x15_r0_body.chost30 : PRE_first_tail_x15_r0_body.cx1_30.host = PRE_first_tail_x15_r0_body.cx0_30.host
-- the compaction map's addresses are `PRE_first_tail_x15_r0_body.kd30`'s
kernel_rfl PRE_first_tail_x15_r0_body.ckn030 : PRE_first_tail_x15_r0_body.kd30.n0 = 2698805
kernel_rfl PRE_first_tail_x15_r0_body.ckn130 : PRE_first_tail_x15_r0_body.kd30.n1 = 2699954
kernel_rfl PRE_first_tail_x15_r0_body.ckheap30 : (PTrie.keysA PRE_first_tail_x15_r0_body.kd30.heap).all (fun x => Nat.ble 2698799 x) = true
kernel_rfl PRE_first_tail_x15_r0_body.ckpl30 : (List.range 6).all (fun j => decide (PRE_first_tail_x15_r0_body.kd30.heap.get (2698799 + j) = nth? PRE_first_tail_x15_r0_body.pl30 j)) = true
-- the map fixes the call's names (`Conv.fixOld_compact`), the call's counters
kernel_rfl PRE_first_tail_x15_r0_body.fja30 : Nat.ble 2698799 2698799 = true
kernel_rfl PRE_first_tail_x15_r0_body.fn30 : Nat.ble 1367 1367 = true
kernel_rfl PRE_first_tail_x15_r0_body.fjaD30 : Nat.ble 2698799 PRE_first_tail_x15_r0_body.kd30.n0 = true
kernel_rfl PRE_first_tail_x15_r0_body.fxn30 : Nat.ble 18802 PRE_first_tail_x15_r0_body.kd30.nh0 = true
kernel_rfl PRE_first_tail_x15_r0_body.fnn30 : Nat.ble 15878 PRE_first_tail_x15_r0_body.kd30.nn0 = true
kernel_rfl PRE_first_tail_x15_r0_body.fxb30 : Nat.ble 18802 RData.bigHi = true
kernel_rfl PRE_first_tail_x15_r0_body.fheap30 : (PTrie.keysA PRE_first_tail_x15_r0_body.kd30.heap).all (Nat.ble (⟨18802, 15878, 2698799, 1367⟩ : Conv.Cnt).ja) = true
kernel_rfl PRE_first_tail_x15_r0_body.fhnd30 : (PTrie.keysA PRE_first_tail_x15_r0_body.kd30.hnd).all (Nat.ble (⟨18802, 15878, 2698799, 1367⟩ : Conv.Cnt).xn) = true
kernel_rfl PRE_first_tail_x15_r0_body.fnode30 : (PTrie.keysA PRE_first_tail_x15_r0_body.kd30.node).all (Nat.ble (⟨18802, 15878, 2698799, 1367⟩ : Conv.Cnt).nn) = true
/-- The compaction map fixes the call's names. -/
theorem PRE_first_tail_x15_r0_body.cfix30 : Conv.FixOld (⟨18802, 15878, 2698799, 1367⟩ : Conv.Cnt) PRE_first_tail_x15_r0_body.kappa30 :=
  Conv.fixOld_compact (Nat.le_of_ble_eq_true PRE_first_tail_x15_r0_body.fja30) (Nat.le_of_ble_eq_true PRE_first_tail_x15_r0_body.fn30) (Nat.le_of_ble_eq_true PRE_first_tail_x15_r0_body.fjaD30) (Nat.le_of_ble_eq_true PRE_first_tail_x15_r0_body.fxn30) (Nat.le_of_ble_eq_true PRE_first_tail_x15_r0_body.fnn30) (Nat.le_of_ble_eq_true PRE_first_tail_x15_r0_body.fxb30) PRE_first_tail_x15_r0_body.fheap30 PRE_first_tail_x15_r0_body.fhnd30 PRE_first_tail_x15_r0_body.fnode30
kernel_rfl PRE_first_tail_x15_r0_body.fcxn30 : (⟨18802, 15878, 2698799, 1367⟩ : Conv.Cnt).xn = (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s304.ffi).mlx.next
kernel_rfl PRE_first_tail_x15_r0_body.fcnn30 : (⟨18802, 15878, 2698799, 1367⟩ : Conv.Cnt).nn = (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s304.ffi).mlx.nnext
kernel_rfl PRE_first_tail_x15_r0_body.fle030 : (Nat.ble (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s304.ffi).mlx.next PRE_first_tail_x15_r0_body.cx0_30.mlx.next && Nat.ble (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s304.ffi).mlx.nnext PRE_first_tail_x15_r0_body.cx0_30.mlx.nnext && Nat.ble (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s304.ffi).mlx.next RData.bigHi) = true
kernel_rfl PRE_first_tail_x15_r0_body.fnk30 : (PTrie.keysA PRE_first_tail_x15_r0_body.kd30.node).all (Nat.ble (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s304.ffi).mlx.nnext) = true
-- the merged state keeps the call's entries off the stage's footprint
kernel_rfl PRE_first_tail_x15_r0_body.f1A30 : PRE_first_tail_x15_r0_body.cx1_30.mlx.arrs = Stage.setAll (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s304.ffi).mlx.arrs (PRE_first_tail_x15_r0_body.cwS30.filterMap fun i => (PRE_first_tail_x15_r0_body.cx1_30.mlx.arrs.get i).map (i, ·))
kernel_rfl PRE_first_tail_x15_r0_body.f1O30 : PRE_first_tail_x15_r0_body.cx1_30.mlx.objs = Stage.setAll (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s304.ffi).mlx.objs (PRE_first_tail_x15_r0_body.cwS30.filterMap fun i => (PRE_first_tail_x15_r0_body.cx1_30.mlx.objs.get i).map (i, ·))
kernel_rfl PRE_first_tail_x15_r0_body.f1N30 : PRE_first_tail_x15_r0_body.cx1_30.mlx.nodes = Stage.setAll (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s304.ffi).mlx.nodes (PRE_first_tail_x15_r0_body.cnS30.filterMap fun i => (PRE_first_tail_x15_r0_body.cx1_30.mlx.nodes.get i).map (i, ·))
kernel_rfl PRE_first_tail_x15_r0_body.f1I30 : PRE_first_tail_x15_r0_body.cx1_30.mlx.items = Stage.setAll (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s304.ffi).mlx.items (PRE_first_tail_x15_r0_body.ciS30.filterMap fun i => (PRE_first_tail_x15_r0_body.cx1_30.mlx.items.get i).map (i, ·))
kernel_rfl PRE_first_tail_x15_r0_body.fbd30 : (PRE_first_tail_x15_r0_body.clo30 ++ PRE_first_tail_x15_r0_body.cln30 ++ PRE_first_tail_x15_r0_body.cli30 ++ PRE_first_tail_x15_r0_body.cwS30 ++ PRE_first_tail_x15_r0_body.cnS30 ++ PRE_first_tail_x15_r0_body.ciS30).all (fun i => Nat.blt (i / 4096) (4 ^ 31)) = true
kernel_rfl PRE_first_tail_x15_r0_body.fincW30 : PRE_first_tail_x15_r0_body.cwS30.all (fun h => !Nat.blt h (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s304.ffi).mlx.next || PRE_first_tail_x15_r0_body.clo30.contains h) = true
kernel_rfl PRE_first_tail_x15_r0_body.fincI30 : PRE_first_tail_x15_r0_body.ciS30.all (fun k => !Nat.blt k (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s304.ffi).mlx.nnext || PRE_first_tail_x15_r0_body.cli30.contains k) = true
kernel_rfl PRE_first_tail_x15_r0_body.fincN30 : PRE_first_tail_x15_r0_body.cnS30.all (Nat.ble (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s304.ffi).mlx.nnext) = true
kernel_rfl PRE_first_tail_x15_r0_body.flnF30 : PRE_first_tail_x15_r0_body.cln30.all (Nat.ble (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s304.ffi).mlx.nnext) = true
-- the checks over the changed lists
kernel_rfl PRE_first_tail_x15_r0_body.fh30 : PRE_first_tail_x15_r0_body.clo30.all (handleOK PRE_first_tail_x15_r0_body.kappa30 PRE_first_tail_x15_r0_body.P30.lo PRE_first_tail_x15_r0_body.cx0_30.mlx PRE_first_tail_x15_r0_body.cx1_30.mlx) = true
kernel_rfl PRE_first_tail_x15_r0_body.fo30 : PRE_first_tail_x15_r0_body.clo30.map (fun h => PRE_first_tail_x15_r0_body.cx1_30.mlx.objs.get (PRE_first_tail_x15_r0_body.kappa30.handle h)) = PRE_first_tail_x15_r0_body.clo30.map (fun h => (PRE_first_tail_x15_r0_body.cx0_30.mlx.objs.get h).map PRE_first_tail_x15_r0_body.kappa30.nobj)
kernel_rfl PRE_first_tail_x15_r0_body.fok30 : PRE_first_tail_x15_r0_body.clo30.all (objOK PRE_first_tail_x15_r0_body.kappa30 PRE_first_tail_x15_r0_body.P30.NL PRE_first_tail_x15_r0_body.cx0_30.mlx) = true
kernel_rfl PRE_first_tail_x15_r0_body.fnd30 : PRE_first_tail_x15_r0_body.cln30.all (nodeOKF PRE_first_tail_x15_r0_body.kappa30 PRE_first_tail_x15_r0_body.P30 PRE_first_tail_x15_r0_body.cx0_30.mlx PRE_first_tail_x15_r0_body.cx1_30.mlx) = true
kernel_rfl PRE_first_tail_x15_r0_body.fp30 : ((PRE_first_tail_x15_r0_body.cln30.filter (fullB PRE_first_tail_x15_r0_body.P30))).map (fun i => (PRE_first_tail_x15_r0_body.cx1_30.mlx.nodes.get (PRE_first_tail_x15_r0_body.kappa30.node i)).map Host.Mlx.Ffi.Node.prim) =
  ((PRE_first_tail_x15_r0_body.cln30.filter (fullB PRE_first_tail_x15_r0_body.P30))).map (fun i => (PRE_first_tail_x15_r0_body.cx0_30.mlx.nodes.get i).map fun nd => PRE_first_tail_x15_r0_body.kappa30.prim nd.prim)
kernel_rfl PRE_first_tail_x15_r0_body.fnordI30 : incrB PRE_first_tail_x15_r0_body.kd30.nodeF (List.range' 15878 27) = true
kernel_rfl PRE_first_tail_x15_r0_body.fnordK30 : (PTrie.keysA PRE_first_tail_x15_r0_body.kd30.node).all (fun k => Nat.ble 15878 k && Nat.blt k 15905) = true
kernel_rfl PRE_first_tail_x15_r0_body.fnordL30 : (PRE_first_tail_x15_r0_body.cln30.filter (Nat.ble PRE_first_tail_x15_r0_body.P30.N0)).all (fun i => Nat.ble i (PRE_first_tail_x15_r0_body.kd30.nodeF i) && (Nat.blt i 15905 || Nat.ble PRE_first_tail_x15_r0_body.kd30.nn0 i)) = true
theorem PRE_first_tail_x15_r0_body.fnord30 : (PRE_first_tail_x15_r0_body.cln30.filter (Nat.ble PRE_first_tail_x15_r0_body.P30.N0)).all (fun i => Nat.ble i (PRE_first_tail_x15_r0_body.kd30.nodeF i) &&
    (PTrie.keysA PRE_first_tail_x15_r0_body.kd30.node).all fun j => !Nat.blt j i || Nat.blt (PRE_first_tail_x15_r0_body.kd30.nodeF j) (PRE_first_tail_x15_r0_body.kd30.nodeF i)) = true :=
  cnord_of PRE_first_tail_x15_r0_body.cnlow30 PRE_first_tail_x15_r0_body.cnn130 PRE_first_tail_x15_r0_body.fnordI30 PRE_first_tail_x15_r0_body.fnordK30 PRE_first_tail_x15_r0_body.fnordL30
kernel_rfl PRE_first_tail_x15_r0_body.fi30 : PRE_first_tail_x15_r0_body.cli30.all (pnB PRE_first_tail_x15_r0_body.cx0_30.mlx) = true
kernel_rfl PRE_first_tail_x15_r0_body.fii30 : PRE_first_tail_x15_r0_body.cli30.all (fun k => decide (PRE_first_tail_x15_r0_body.cx1_30.mlx.items.get (PRE_first_tail_x15_r0_body.kappa30.node k) = (PRE_first_tail_x15_r0_body.cx0_30.mlx.items.get k).map PRE_first_tail_x15_r0_body.kappa30.nv)) = true
/-- **The compaction's footprint.** -/
theorem PRE_first_tail_x15_r0_body.cfoot30 (clean : Conv.NClean (⟨18802, 15878, 2698799, 1367⟩ : Conv.Cnt) (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s304.ffi).mlx) (hltC : ∀ h, PH (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s304.ffi).mlx h → h < (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s304.ffi).mlx.next) (nltC : ∀ i, PN (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s304.ffi).mlx i → i < (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s304.ffi).mlx.nnext) (itemsC : ∀ k v, (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s304.ffi).mlx.items.get k = some v → PN (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s304.ffi).mlx k) (tracedC : ∀ h o, (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s304.ffi).mlx.objs.get h = some o → ∀ i ∈ objTraces o, i < PRE_first_tail_x15_r0_body.P30.NL) (cl : SSt (· < 1385) PRE_first_tail_x15_r0_body.cx0_30.mlx) :
    Conv.MFoot PRE_first_tail_x15_r0_body.P30 1385 PRE_first_tail_x15_r0_body.kappa30 PRE_first_tail_x15_r0_body.kd30 PRE_first_tail_x15_r0_body.khinv30 PRE_first_tail_x15_r0_body.kninv30 (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s304.ffi).mlx PRE_first_tail_x15_r0_body.cx0_30.mlx PRE_first_tail_x15_r0_body.cx1_30.mlx (⟨18802, 15878, 2698799, 1367⟩ : Conv.Cnt) PRE_first_tail_x15_r0_body.clo30 PRE_first_tail_x15_r0_body.cln30 PRE_first_tail_x15_r0_body.cli30 PRE_first_tail_x15_r0_body.cwS30 PRE_first_tail_x15_r0_body.cnS30 PRE_first_tail_x15_r0_body.ciS30 :=
  ⟨rfl, rfl, rfl, PRE_first_tail_x15_r0_body.cnh030, PRE_first_tail_x15_r0_body.cnh130, PRE_first_tail_x15_r0_body.cnn030, PRE_first_tail_x15_r0_body.cnn130, PRE_first_tail_x15_r0_body.cplo30, PRE_first_tail_x15_r0_body.ccnt30, PRE_first_tail_x15_r0_body.cnband30, PRE_first_tail_x15_r0_body.chbelow30, PRE_first_tail_x15_r0_body.chren30, PRE_first_tail_x15_r0_body.cband30, PRE_first_tail_x15_r0_body.cnh1pos30, PRE_first_tail_x15_r0_body.cnren30, PRE_first_tail_x15_r0_body.cnlow30, PRE_first_tail_x15_r0_body.cabs0a30, PRE_first_tail_x15_r0_body.cabs0b30, PRE_first_tail_x15_r0_body.ctok130, PRE_first_tail_x15_r0_body.cpend30, PRE_first_tail_x15_r0_body.cerrh30, PRE_first_tail_x15_r0_body.cfiles30, PRE_first_tail_x15_r0_body.carch30, PRE_first_tail_x15_r0_body.csizes30, PRE_first_tail_x15_r0_body.cwired30, PRE_first_tail_x15_r0_body.cfix30, clean, PRE_first_tail_x15_r0_body.fcxn30, PRE_first_tail_x15_r0_body.fcnn30, hltC, nltC, itemsC, tracedC, cl, PRE_first_tail_x15_r0_body.fle030, PRE_first_tail_x15_r0_body.fnk30, PRE_first_tail_x15_r0_body.ckA30, PRE_first_tail_x15_r0_body.cobjsK30, PRE_first_tail_x15_r0_body.cnodesK30, PRE_first_tail_x15_r0_body.citemsK30, PRE_first_tail_x15_r0_body.f1A30, PRE_first_tail_x15_r0_body.f1O30, PRE_first_tail_x15_r0_body.f1N30, PRE_first_tail_x15_r0_body.f1I30, PRE_first_tail_x15_r0_body.fbd30, PRE_first_tail_x15_r0_body.fincW30, PRE_first_tail_x15_r0_body.fincI30, PRE_first_tail_x15_r0_body.fincN30, PRE_first_tail_x15_r0_body.flnF30, PRE_first_tail_x15_r0_body.fh30, PRE_first_tail_x15_r0_body.fo30, PRE_first_tail_x15_r0_body.fok30, PRE_first_tail_x15_r0_body.fnd30, PRE_first_tail_x15_r0_body.fp30, PRE_first_tail_x15_r0_body.fnord30, PRE_first_tail_x15_r0_body.fi30, PRE_first_tail_x15_r0_body.fii30⟩
theorem PRE_first_tail_x15_r0_body.cnshift30 (clean : Conv.NClean (⟨18802, 15878, 2698799, 1367⟩ : Conv.Cnt) (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s304.ffi).mlx) (hltC : ∀ h, PH (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s304.ffi).mlx h → h < (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s304.ffi).mlx.next) (nltC : ∀ i, PN (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s304.ffi).mlx i → i < (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s304.ffi).mlx.nnext) (itemsC : ∀ k v, (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s304.ffi).mlx.items.get k = some v → PN (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s304.ffi).mlx k) (tracedC : ∀ h o, (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s304.ffi).mlx.objs.get h = some o → ∀ i ∈ objTraces o, i < PRE_first_tail_x15_r0_body.P30.NL) (cl : SSt (· < 1385) PRE_first_tail_x15_r0_body.cx0_30.mlx) : NShift PRE_first_tail_x15_r0_body.P30 1385 PRE_first_tail_x15_r0_body.kappa30 PRE_first_tail_x15_r0_body.cx0_30 PRE_first_tail_x15_r0_body.cx1_30 :=
  Conv.nshift_of_foot (PRE_first_tail_x15_r0_body.cfoot30 clean hltC nltC itemsC tracedC cl) PRE_first_tail_x15_r0_body.chost30 (compact_a_eq PRE_first_tail_x15_r0_body.ckn030 PRE_first_tail_x15_r0_body.ckn130 PRE_first_tail_x15_r0_body.ckheap30 PRE_first_tail_x15_r0_body.ckpl30)

-- the observers: the layers' states at the call, the canonical and the merged state, their footprints and checks
noncomputable def PRE_first_tail_x15_r0_body.fxC_30 : PTrie Unit := (Host.Ts.Sim.Full.freedOf PRE_first_tail_x15_r0_body.s304.ffi).getD PTrie.nil
noncomputable def PRE_first_tail_x15_r0_body.krC_30 : Host.Load.Layers.KRec := (Host.Ts.Sim.Full.krecOf PRE_first_tail_x15_r0_body.s304.ffi).getD Host.Load.Layers.KRec.empty
kernel_rfl PRE_first_tail_x15_r0_body.ofxC_30 : (Host.Ts.Sim.Full.freedOf PRE_first_tail_x15_r0_body.s304.ffi) = some PRE_first_tail_x15_r0_body.fxC_30
kernel_rfl PRE_first_tail_x15_r0_body.okrC_30 : (Host.Ts.Sim.Full.krecOf PRE_first_tail_x15_r0_body.s304.ffi) = some PRE_first_tail_x15_r0_body.krC_30
noncomputable def PRE_first_tail_x15_r0_body.fx0_30 : PTrie Unit := (Host.Ts.Sim.Full.freedOf PRE_first_tail_x15_r0_body.s306.ffi).getD PTrie.nil
noncomputable def PRE_first_tail_x15_r0_body.kr0_30 : Host.Load.Layers.KRec := (Host.Ts.Sim.Full.krecOf PRE_first_tail_x15_r0_body.s306.ffi).getD Host.Load.Layers.KRec.empty
kernel_rfl PRE_first_tail_x15_r0_body.ofx0_30 : (Host.Ts.Sim.Full.freedOf PRE_first_tail_x15_r0_body.s306.ffi) = some PRE_first_tail_x15_r0_body.fx0_30
kernel_rfl PRE_first_tail_x15_r0_body.okr0_30 : (Host.Ts.Sim.Full.krecOf PRE_first_tail_x15_r0_body.s306.ffi) = some PRE_first_tail_x15_r0_body.kr0_30
noncomputable def PRE_first_tail_x15_r0_body.fx1_30 : PTrie Unit := (Host.Ts.Sim.Full.freedOf PRE_first_tail_x15_r0_body.s305.ffi).getD PTrie.nil
noncomputable def PRE_first_tail_x15_r0_body.kr1_30 : Host.Load.Layers.KRec := (Host.Ts.Sim.Full.krecOf PRE_first_tail_x15_r0_body.s305.ffi).getD Host.Load.Layers.KRec.empty
kernel_rfl PRE_first_tail_x15_r0_body.ofx1_30 : (Host.Ts.Sim.Full.freedOf PRE_first_tail_x15_r0_body.s305.ffi) = some PRE_first_tail_x15_r0_body.fx1_30
kernel_rfl PRE_first_tail_x15_r0_body.okr1_30 : (Host.Ts.Sim.Full.krecOf PRE_first_tail_x15_r0_body.s305.ffi) = some PRE_first_tail_x15_r0_body.kr1_30
kernel_rfl PRE_first_tail_x15_r0_body.ff030 : PRE_first_tail_x15_r0_body.fx0_30 = Stage.setAll PRE_first_tail_x15_r0_body.fxC_30 (PRE_first_tail_x15_r0_body.clo30.filterMap fun i => (PRE_first_tail_x15_r0_body.fx0_30.get i).map (i, ·))
kernel_rfl PRE_first_tail_x15_r0_body.ff130 : PRE_first_tail_x15_r0_body.fx1_30 = Stage.setAll PRE_first_tail_x15_r0_body.fxC_30 (PRE_first_tail_x15_r0_body.cwS30.filterMap fun i => (PRE_first_tail_x15_r0_body.fx1_30.get i).map (i, ·))
kernel_rfl PRE_first_tail_x15_r0_body.ffck30 : freedLB PRE_first_tail_x15_r0_body.kappa30 PRE_first_tail_x15_r0_body.cx0_30.mlx PRE_first_tail_x15_r0_body.fx0_30 PRE_first_tail_x15_r0_body.fx1_30 PRE_first_tail_x15_r0_body.clo30 = true
kernel_rfl PRE_first_tail_x15_r0_body.fkf030 : PRE_first_tail_x15_r0_body.kr0_30.flags = Stage.setAll PRE_first_tail_x15_r0_body.krC_30.flags (PRE_first_tail_x15_r0_body.clo30.filterMap fun i => (PRE_first_tail_x15_r0_body.kr0_30.flags.get i).map (i, ·))
kernel_rfl PRE_first_tail_x15_r0_body.fkt030 : PRE_first_tail_x15_r0_body.kr0_30.targs = Stage.setAll PRE_first_tail_x15_r0_body.krC_30.targs (PRE_first_tail_x15_r0_body.clo30.filterMap fun i => (PRE_first_tail_x15_r0_body.kr0_30.targs.get i).map (i, ·))
kernel_rfl PRE_first_tail_x15_r0_body.fkf130 : PRE_first_tail_x15_r0_body.kr1_30.flags = Stage.setAll PRE_first_tail_x15_r0_body.krC_30.flags (PRE_first_tail_x15_r0_body.cwS30.filterMap fun i => (PRE_first_tail_x15_r0_body.kr1_30.flags.get i).map (i, ·))
kernel_rfl PRE_first_tail_x15_r0_body.fkt130 : PRE_first_tail_x15_r0_body.kr1_30.targs = Stage.setAll PRE_first_tail_x15_r0_body.krC_30.targs (PRE_first_tail_x15_r0_body.cwS30.filterMap fun i => (PRE_first_tail_x15_r0_body.kr1_30.targs.get i).map (i, ·))
kernel_rfl PRE_first_tail_x15_r0_body.fkck30 : krecLB PRE_first_tail_x15_r0_body.kappa30 1385 PRE_first_tail_x15_r0_body.cx0_30.mlx PRE_first_tail_x15_r0_body.kr0_30 PRE_first_tail_x15_r0_body.kr1_30 PRE_first_tail_x15_r0_body.clo30 = true
kernel_rfl PRE_first_tail_x15_r0_body.fkn30 : Nat.ble 1367 1385 = true
-- the bridge and the pending traces' regions
kernel_rfl PRE_first_tail_x15_r0_body.cbridge30 : Host.Ts.Sim.Full.bridgeOf PRE_first_tail_x15_r0_body.s305.ffi = Host.Ts.Sim.Full.bridgeOf PRE_first_tail_x15_r0_body.s306.ffi
kernel_rfl PRE_first_tail_x15_r0_body.cpendR30 : pendRegB PRE_first_tail_x15_r0_body.kappa30 (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s306.ffi).mlx = true
kernel_rfl PRE_first_tail_x15_r0_body.cpendLe30 : Nat.ble (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s306.ffi).mlx.next (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s305.ffi).mlx.next = true
/-- **The compaction's native shift**, given the call's bookkeeping, its relation's facts (the model's and the
observers') and the canonical closedness. -/
theorem PRE_first_tail_x15_r0_body.cshift30 (clean : Conv.NClean (⟨18802, 15878, 2698799, 1367⟩ : Conv.Cnt) (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s304.ffi).mlx) (hltC : ∀ h, PH (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s304.ffi).mlx h → h < (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s304.ffi).mlx.next) (nltC : ∀ i, PN (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s304.ffi).mlx i → i < (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s304.ffi).mlx.nnext) (itemsC : ∀ k v, (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s304.ffi).mlx.items.get k = some v → PN (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s304.ffi).mlx k) (tracedC : ∀ h o, (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s304.ffi).mlx.objs.get h = some o → ∀ i ∈ objTraces o, i < PRE_first_tail_x15_r0_body.P30.NL) (cl : SSt (· < 1385) PRE_first_tail_x15_r0_body.cx0_30.mlx)
    (hobjC : ∀ h, PRE_first_tail_x15_r0_body.fxC_30.get h = some () → ((Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s304.ffi).mlx.objs.get h).isSome = true)
    (hfC : ∀ h, (PRE_first_tail_x15_r0_body.krC_30.flags.get h).isSome = true → ((Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s304.ffi).mlx.objs.get h).isSome = true)
    (htC : ∀ h, (PRE_first_tail_x15_r0_body.krC_30.targs.get h).isSome = true → ((Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s304.ffi).mlx.objs.get h).isSome = true)
    (hclC : ∀ h l, PRE_first_tail_x15_r0_body.krC_30.targs.get h = some l → Host.Ts.Sim.Full.STargs (· < (⟨18802, 15878, 2698799, 1367⟩ : Conv.Cnt).n) l) :
    Conv.FullShiftQ PRE_first_tail_x15_r0_body.P30 1385 PRE_first_tail_x15_r0_body.kappa30 PRE_first_tail_x15_r0_body.s306.ffi PRE_first_tail_x15_r0_body.s305.ffi :=
  ⟨PRE_first_tail_x15_r0_body.cnshift30 clean hltC nltC itemsC tracedC cl, PRE_first_tail_x15_r0_body.cqueue30, fun t ht => bSN_sound (List.all_eq_true.mp PRE_first_tail_x15_r0_body.ctokSupp30 t ht),
    PRE_first_tail_x15_r0_body.cbridge30,
    liveShift_foot (x0' := Host.Ts.Sim.Full.mlxOf PRE_first_tail_x15_r0_body.s306.ffi) (x1' := Host.Ts.Sim.Full.mlxOf PRE_first_tail_x15_r0_body.s305.ffi) (PRE_first_tail_x15_r0_body.cfoot30 clean hltC nltC itemsC tracedC cl) rfl PRE_first_tail_x15_r0_body.ofx0_30 PRE_first_tail_x15_r0_body.ofx1_30 hobjC PRE_first_tail_x15_r0_body.ff030 PRE_first_tail_x15_r0_body.ff130 PRE_first_tail_x15_r0_body.ffck30,
    kernShift_foot (x0' := Host.Ts.Sim.Full.mlxOf PRE_first_tail_x15_r0_body.s306.ffi) (x1' := Host.Ts.Sim.Full.mlxOf PRE_first_tail_x15_r0_body.s305.ffi) (PRE_first_tail_x15_r0_body.cfoot30 clean hltC nltC itemsC tracedC cl) rfl PRE_first_tail_x15_r0_body.okr0_30 PRE_first_tail_x15_r0_body.okr1_30 (Nat.le_of_ble_eq_true PRE_first_tail_x15_r0_body.fkn30) hfC htC hclC
      PRE_first_tail_x15_r0_body.fkf030 PRE_first_tail_x15_r0_body.fkt030 PRE_first_tail_x15_r0_body.fkf130 PRE_first_tail_x15_r0_body.fkt130 PRE_first_tail_x15_r0_body.fkck30,
    pendReg_of rfl PRE_first_tail_x15_r0_body.cnh030 PRE_first_tail_x15_r0_body.cnh130 (Nat.le_of_ble_eq_true PRE_first_tail_x15_r0_body.cpendLe30) PRE_first_tail_x15_r0_body.cpendR30⟩

end Host.Load.Run.Tpl
