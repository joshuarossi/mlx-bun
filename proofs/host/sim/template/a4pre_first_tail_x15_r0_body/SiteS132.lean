import host.sim.template.a4pre_first_tail_x15_r0_body.SiteCl132
import host.sim.conv.CompactFull
import host.sim.template.FootGen
set_option Elab.async false
namespace Host.Load.Run.Tpl
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
open Host.Ts Host.Ts.Sim Host.Ts.Sim.Template

/-! The compaction's native shift at call site 132 from its footprint (`Conv.nshift_of_foot`), and the observers'
(`liveShift_foot`, `kernShift_foot`): `Conv.FullShiftQ` for `Conv.full_compactQ`, given the call's bookkeeping and its
relation's facts. -/

/-- The load parameters of the chain (band-free: its start's node counter as `NL` and `N0`). -/
def PRE_first_tail_x15_r0_body.Pc132 : LoadP := ⟨18151, 131072, 1099511627776, 15235, 15235, []⟩
/-- The site's band raised to the map's checked fixed-node prefix, including newly recorded closure traces. -/
def PRE_first_tail_x15_r0_body.P132 : LoadP := PRE_first_tail_x15_r0_body.Pc132.raise 17912
kernel_rfl PRE_first_tail_x15_r0_body.craise132 : Nat.ble PRE_first_tail_x15_r0_body.Pc132.N0 17912 = true
theorem PRE_first_tail_x15_r0_body.raised132 : Host.Ts.Sim.Full.Raised PRE_first_tail_x15_r0_body.Pc132 PRE_first_tail_x15_r0_body.P132 :=
  .inr ⟨17912, rfl, Nat.le_of_ble_eq_true PRE_first_tail_x15_r0_body.craise132, rfl⟩
noncomputable abbrev PRE_first_tail_x15_r0_body.cx0_132 : Host.Load.LSt := clearTokens (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1283.ffi)
noncomputable abbrev PRE_first_tail_x15_r0_body.cx1_132 : Host.Load.LSt := clearTokens (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1282.ffi)
def PRE_first_tail_x15_r0_body.khinv132 : PTrie Nat := Stage.setAll PTrie.nil [(20838, 20812), (20816, 20813), (20839, 20814)]
def PRE_first_tail_x15_r0_body.kninv132 : PTrie Nat := Stage.setAll PTrie.nil [(17885, 17885), (17886, 17886), (17887, 17887), (17888, 17888), (17889, 17889), (17890, 17890), (17891, 17891), (17892, 17892), (17893, 17893), (17894, 17894), (17895, 17895), (17896, 17896), (17897, 17897), (17898, 17898), (17899, 17899), (17900, 17900), (17901, 17901), (17902, 17902), (17903, 17903), (17904, 17904), (17905, 17905), (17906, 17906), (17907, 17907), (17908, 17908), (17909, 17909), (17910, 17910), (17911, 17911)]
/-- The stage's footprint: its written and fresh handles, fresh nodes, written and fresh items. -/
def PRE_first_tail_x15_r0_body.cwS132 : List Nat := [20792, 20805, 20811, 20812, 20813, 20814, 20815, 20816, 20817, 20818, 20819, 20820, 20821, 20822, 20823, 20824, 20825, 20826, 20827, 20828, 20829, 20830, 20831, 20832, 20833, 20834, 20835, 20836, 20837, 20838, 20839]
def PRE_first_tail_x15_r0_body.cnS132 : List Nat := List.range' 17885 27
def PRE_first_tail_x15_r0_body.ciS132 : List Nat := [] ++ List.range' 17885 27

-- the small checks (`MChecks`'s)
kernel_rfl PRE_first_tail_x15_r0_body.cnh0132 : PRE_first_tail_x15_r0_body.kd132.nh0 = PRE_first_tail_x15_r0_body.cx0_132.mlx.next
kernel_rfl PRE_first_tail_x15_r0_body.cnh1132 : PRE_first_tail_x15_r0_body.kd132.nh1 = PRE_first_tail_x15_r0_body.cx1_132.mlx.next
kernel_rfl PRE_first_tail_x15_r0_body.cnn0132 : PRE_first_tail_x15_r0_body.kd132.nn0 = PRE_first_tail_x15_r0_body.cx0_132.mlx.nnext
kernel_rfl PRE_first_tail_x15_r0_body.cnn1132 : PRE_first_tail_x15_r0_body.kd132.nn1 = PRE_first_tail_x15_r0_body.cx1_132.mlx.nnext
kernel_rfl PRE_first_tail_x15_r0_body.cplo132 : (Nat.blt 0 PRE_first_tail_x15_r0_body.P132.lo && Nat.ble PRE_first_tail_x15_r0_body.P132.lo PRE_first_tail_x15_r0_body.cx0_132.mlx.next && Nat.ble PRE_first_tail_x15_r0_body.P132.lo RData.bigHi && Nat.ble RData.bigHi PRE_first_tail_x15_r0_body.P132.E) = true
kernel_rfl PRE_first_tail_x15_r0_body.ccnt132 : (Nat.ble PRE_first_tail_x15_r0_body.cx0_132.mlx.next PRE_first_tail_x15_r0_body.cx1_132.mlx.next && Nat.ble PRE_first_tail_x15_r0_body.cx0_132.mlx.nnext PRE_first_tail_x15_r0_body.cx1_132.mlx.nnext) = true
kernel_rfl PRE_first_tail_x15_r0_body.cnband132 : (Nat.blt 0 PRE_first_tail_x15_r0_body.P132.NL && Nat.ble PRE_first_tail_x15_r0_body.P132.NL PRE_first_tail_x15_r0_body.P132.N0 && Nat.ble PRE_first_tail_x15_r0_body.P132.N0 PRE_first_tail_x15_r0_body.cx0_132.mlx.nnext) = true
kernel_rfl PRE_first_tail_x15_r0_body.chbelow132 : PRE_first_tail_x15_r0_body.kd132.checkHndBelow = true
kernel_rfl PRE_first_tail_x15_r0_body.chren132 : checkRenG PRE_first_tail_x15_r0_body.kd132.hnd PRE_first_tail_x15_r0_body.khinv132 (phB PRE_first_tail_x15_r0_body.cx0_132.mlx) = true
kernel_rfl PRE_first_tail_x15_r0_body.cband132 : PRE_first_tail_x15_r0_body.kd132.checkBand PRE_first_tail_x15_r0_body.P132.lo = true
kernel_rfl PRE_first_tail_x15_r0_body.cnh1pos132 : Nat.blt 0 PRE_first_tail_x15_r0_body.kd132.nh1 = true
kernel_rfl PRE_first_tail_x15_r0_body.cnren132 : checkRenG PRE_first_tail_x15_r0_body.kd132.node PRE_first_tail_x15_r0_body.kninv132 (pnB PRE_first_tail_x15_r0_body.cx0_132.mlx) = true
kernel_rfl PRE_first_tail_x15_r0_body.cnlow132 : (PTrie.keysA PRE_first_tail_x15_r0_body.kd132.node).all (fun j => Nat.ble PRE_first_tail_x15_r0_body.P132.NL j && Nat.blt (PRE_first_tail_x15_r0_body.kd132.nodeF j) PRE_first_tail_x15_r0_body.cx1_132.mlx.nnext) = true
kernel_rfl PRE_first_tail_x15_r0_body.cabs0a132 : PRE_first_tail_x15_r0_body.cx0_132.mlx.arrs.get 0 = none
kernel_rfl PRE_first_tail_x15_r0_body.cabs0b132 : PRE_first_tail_x15_r0_body.cx0_132.mlx.objs.get 0 = none
kernel_rfl PRE_first_tail_x15_r0_body.ctok1132 : PRE_first_tail_x15_r0_body.cx1_132.mlx.tokens = []
kernel_rfl PRE_first_tail_x15_r0_body.cpend132 : PRE_first_tail_x15_r0_body.cx1_132.mlx.pending = PRE_first_tail_x15_r0_body.cx0_132.mlx.pending.map PRE_first_tail_x15_r0_body.kappa132.pend
kernel_rfl PRE_first_tail_x15_r0_body.cerrh132 : PRE_first_tail_x15_r0_body.cx1_132.mlx.errh = PRE_first_tail_x15_r0_body.cx0_132.mlx.errh.map PRE_first_tail_x15_r0_body.kappa132.arg
kernel_rfl PRE_first_tail_x15_r0_body.cfiles132 : PRE_first_tail_x15_r0_body.cx1_132.mlx.files = PRE_first_tail_x15_r0_body.cx0_132.mlx.files
kernel_rfl PRE_first_tail_x15_r0_body.carch132 : PRE_first_tail_x15_r0_body.cx1_132.mlx.arch = PRE_first_tail_x15_r0_body.cx0_132.mlx.arch
kernel_rfl PRE_first_tail_x15_r0_body.csizes132 : PRE_first_tail_x15_r0_body.cx1_132.mlx.deviceSizes = PRE_first_tail_x15_r0_body.cx0_132.mlx.deviceSizes
kernel_rfl PRE_first_tail_x15_r0_body.cwired132 : PRE_first_tail_x15_r0_body.cx1_132.mlx.wired = PRE_first_tail_x15_r0_body.cx0_132.mlx.wired
kernel_rfl PRE_first_tail_x15_r0_body.chost132 : PRE_first_tail_x15_r0_body.cx1_132.host = PRE_first_tail_x15_r0_body.cx0_132.host
-- the compaction map's addresses are `PRE_first_tail_x15_r0_body.kd132`'s
kernel_rfl PRE_first_tail_x15_r0_body.ckn0132 : PRE_first_tail_x15_r0_body.kd132.n0 = 2779041
kernel_rfl PRE_first_tail_x15_r0_body.ckn1132 : PRE_first_tail_x15_r0_body.kd132.n1 = 2780190
kernel_rfl PRE_first_tail_x15_r0_body.ckheap132 : (PTrie.keysA PRE_first_tail_x15_r0_body.kd132.heap).all (fun x => Nat.ble 2779035 x) = true
kernel_rfl PRE_first_tail_x15_r0_body.ckpl132 : (List.range 6).all (fun j => decide (PRE_first_tail_x15_r0_body.kd132.heap.get (2779035 + j) = nth? PRE_first_tail_x15_r0_body.pl132 j)) = true
-- the map fixes the call's names (`Conv.fixOld_compact`), the call's counters
kernel_rfl PRE_first_tail_x15_r0_body.fja132 : Nat.ble 2779035 2779035 = true
kernel_rfl PRE_first_tail_x15_r0_body.fn132 : Nat.ble 5726 5726 = true
kernel_rfl PRE_first_tail_x15_r0_body.fjaD132 : Nat.ble 2779035 PRE_first_tail_x15_r0_body.kd132.n0 = true
kernel_rfl PRE_first_tail_x15_r0_body.fxn132 : Nat.ble 20812 PRE_first_tail_x15_r0_body.kd132.nh0 = true
kernel_rfl PRE_first_tail_x15_r0_body.fnn132 : Nat.ble 17885 PRE_first_tail_x15_r0_body.kd132.nn0 = true
kernel_rfl PRE_first_tail_x15_r0_body.fxb132 : Nat.ble 20812 RData.bigHi = true
kernel_rfl PRE_first_tail_x15_r0_body.fheap132 : (PTrie.keysA PRE_first_tail_x15_r0_body.kd132.heap).all (Nat.ble (⟨20812, 17885, 2779035, 5726⟩ : Conv.Cnt).ja) = true
kernel_rfl PRE_first_tail_x15_r0_body.fhnd132 : (PTrie.keysA PRE_first_tail_x15_r0_body.kd132.hnd).all (Nat.ble (⟨20812, 17885, 2779035, 5726⟩ : Conv.Cnt).xn) = true
kernel_rfl PRE_first_tail_x15_r0_body.fnode132 : (PTrie.keysA PRE_first_tail_x15_r0_body.kd132.node).all (Nat.ble (⟨20812, 17885, 2779035, 5726⟩ : Conv.Cnt).nn) = true
/-- The compaction map fixes the call's names. -/
theorem PRE_first_tail_x15_r0_body.cfix132 : Conv.FixOld (⟨20812, 17885, 2779035, 5726⟩ : Conv.Cnt) PRE_first_tail_x15_r0_body.kappa132 :=
  Conv.fixOld_compact (Nat.le_of_ble_eq_true PRE_first_tail_x15_r0_body.fja132) (Nat.le_of_ble_eq_true PRE_first_tail_x15_r0_body.fn132) (Nat.le_of_ble_eq_true PRE_first_tail_x15_r0_body.fjaD132) (Nat.le_of_ble_eq_true PRE_first_tail_x15_r0_body.fxn132) (Nat.le_of_ble_eq_true PRE_first_tail_x15_r0_body.fnn132) (Nat.le_of_ble_eq_true PRE_first_tail_x15_r0_body.fxb132) PRE_first_tail_x15_r0_body.fheap132 PRE_first_tail_x15_r0_body.fhnd132 PRE_first_tail_x15_r0_body.fnode132
kernel_rfl PRE_first_tail_x15_r0_body.fcxn132 : (⟨20812, 17885, 2779035, 5726⟩ : Conv.Cnt).xn = (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1281.ffi).mlx.next
kernel_rfl PRE_first_tail_x15_r0_body.fcnn132 : (⟨20812, 17885, 2779035, 5726⟩ : Conv.Cnt).nn = (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1281.ffi).mlx.nnext
kernel_rfl PRE_first_tail_x15_r0_body.fle0132 : (Nat.ble (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1281.ffi).mlx.next PRE_first_tail_x15_r0_body.cx0_132.mlx.next && Nat.ble (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1281.ffi).mlx.nnext PRE_first_tail_x15_r0_body.cx0_132.mlx.nnext && Nat.ble (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1281.ffi).mlx.next RData.bigHi) = true
kernel_rfl PRE_first_tail_x15_r0_body.fnk132 : (PTrie.keysA PRE_first_tail_x15_r0_body.kd132.node).all (Nat.ble (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1281.ffi).mlx.nnext) = true
-- the merged state keeps the call's entries off the stage's footprint
kernel_rfl PRE_first_tail_x15_r0_body.f1A132 : PRE_first_tail_x15_r0_body.cx1_132.mlx.arrs = Stage.setAll (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1281.ffi).mlx.arrs (PRE_first_tail_x15_r0_body.cwS132.filterMap fun i => (PRE_first_tail_x15_r0_body.cx1_132.mlx.arrs.get i).map (i, ·))
kernel_rfl PRE_first_tail_x15_r0_body.f1O132 : PRE_first_tail_x15_r0_body.cx1_132.mlx.objs = Stage.setAll (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1281.ffi).mlx.objs (PRE_first_tail_x15_r0_body.cwS132.filterMap fun i => (PRE_first_tail_x15_r0_body.cx1_132.mlx.objs.get i).map (i, ·))
kernel_rfl PRE_first_tail_x15_r0_body.f1N132 : PRE_first_tail_x15_r0_body.cx1_132.mlx.nodes = Stage.setAll (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1281.ffi).mlx.nodes (PRE_first_tail_x15_r0_body.cnS132.filterMap fun i => (PRE_first_tail_x15_r0_body.cx1_132.mlx.nodes.get i).map (i, ·))
kernel_rfl PRE_first_tail_x15_r0_body.f1I132 : PRE_first_tail_x15_r0_body.cx1_132.mlx.items = Stage.setAll (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1281.ffi).mlx.items (PRE_first_tail_x15_r0_body.ciS132.filterMap fun i => (PRE_first_tail_x15_r0_body.cx1_132.mlx.items.get i).map (i, ·))
kernel_rfl PRE_first_tail_x15_r0_body.fbd132 : (PRE_first_tail_x15_r0_body.clo132 ++ PRE_first_tail_x15_r0_body.cln132 ++ PRE_first_tail_x15_r0_body.cli132 ++ PRE_first_tail_x15_r0_body.cwS132 ++ PRE_first_tail_x15_r0_body.cnS132 ++ PRE_first_tail_x15_r0_body.ciS132).all (fun i => Nat.blt (i / 4096) (4 ^ 31)) = true
kernel_rfl PRE_first_tail_x15_r0_body.fincW132 : PRE_first_tail_x15_r0_body.cwS132.all (fun h => !Nat.blt h (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1281.ffi).mlx.next || PRE_first_tail_x15_r0_body.clo132.contains h) = true
kernel_rfl PRE_first_tail_x15_r0_body.fincI132 : PRE_first_tail_x15_r0_body.ciS132.all (fun k => !Nat.blt k (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1281.ffi).mlx.nnext || PRE_first_tail_x15_r0_body.cli132.contains k) = true
kernel_rfl PRE_first_tail_x15_r0_body.fincN132 : PRE_first_tail_x15_r0_body.cnS132.all (Nat.ble (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1281.ffi).mlx.nnext) = true
kernel_rfl PRE_first_tail_x15_r0_body.flnF132 : PRE_first_tail_x15_r0_body.cln132.all (Nat.ble (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1281.ffi).mlx.nnext) = true
-- the checks over the changed lists
kernel_rfl PRE_first_tail_x15_r0_body.fh132 : PRE_first_tail_x15_r0_body.clo132.all (handleOK PRE_first_tail_x15_r0_body.kappa132 PRE_first_tail_x15_r0_body.P132.lo PRE_first_tail_x15_r0_body.cx0_132.mlx PRE_first_tail_x15_r0_body.cx1_132.mlx) = true
kernel_rfl PRE_first_tail_x15_r0_body.fo132 : PRE_first_tail_x15_r0_body.clo132.map (fun h => PRE_first_tail_x15_r0_body.cx1_132.mlx.objs.get (PRE_first_tail_x15_r0_body.kappa132.handle h)) = PRE_first_tail_x15_r0_body.clo132.map (fun h => (PRE_first_tail_x15_r0_body.cx0_132.mlx.objs.get h).map PRE_first_tail_x15_r0_body.kappa132.nobj)
kernel_rfl PRE_first_tail_x15_r0_body.fok132 : PRE_first_tail_x15_r0_body.clo132.all (objOK PRE_first_tail_x15_r0_body.kappa132 PRE_first_tail_x15_r0_body.P132.NL PRE_first_tail_x15_r0_body.cx0_132.mlx) = true
kernel_rfl PRE_first_tail_x15_r0_body.fnd132 : PRE_first_tail_x15_r0_body.cln132.all (nodeOKF PRE_first_tail_x15_r0_body.kappa132 PRE_first_tail_x15_r0_body.P132 PRE_first_tail_x15_r0_body.cx0_132.mlx PRE_first_tail_x15_r0_body.cx1_132.mlx) = true
kernel_rfl PRE_first_tail_x15_r0_body.fp132 : ((PRE_first_tail_x15_r0_body.cln132.filter (fullB PRE_first_tail_x15_r0_body.P132))).map (fun i => (PRE_first_tail_x15_r0_body.cx1_132.mlx.nodes.get (PRE_first_tail_x15_r0_body.kappa132.node i)).map Host.Mlx.Ffi.Node.prim) =
  ((PRE_first_tail_x15_r0_body.cln132.filter (fullB PRE_first_tail_x15_r0_body.P132))).map (fun i => (PRE_first_tail_x15_r0_body.cx0_132.mlx.nodes.get i).map fun nd => PRE_first_tail_x15_r0_body.kappa132.prim nd.prim)
kernel_rfl PRE_first_tail_x15_r0_body.fnordI132 : incrB PRE_first_tail_x15_r0_body.kd132.nodeF (List.range' 17885 27) = true
kernel_rfl PRE_first_tail_x15_r0_body.fnordK132 : (PTrie.keysA PRE_first_tail_x15_r0_body.kd132.node).all (fun k => Nat.ble 17885 k && Nat.blt k 17912) = true
kernel_rfl PRE_first_tail_x15_r0_body.fnordL132 : (PRE_first_tail_x15_r0_body.cln132.filter (Nat.ble PRE_first_tail_x15_r0_body.P132.N0)).all (fun i => Nat.ble i (PRE_first_tail_x15_r0_body.kd132.nodeF i) && (Nat.blt i 17912 || Nat.ble PRE_first_tail_x15_r0_body.kd132.nn0 i)) = true
theorem PRE_first_tail_x15_r0_body.fnord132 : (PRE_first_tail_x15_r0_body.cln132.filter (Nat.ble PRE_first_tail_x15_r0_body.P132.N0)).all (fun i => Nat.ble i (PRE_first_tail_x15_r0_body.kd132.nodeF i) &&
    (PTrie.keysA PRE_first_tail_x15_r0_body.kd132.node).all fun j => !Nat.blt j i || Nat.blt (PRE_first_tail_x15_r0_body.kd132.nodeF j) (PRE_first_tail_x15_r0_body.kd132.nodeF i)) = true :=
  cnord_of PRE_first_tail_x15_r0_body.cnlow132 PRE_first_tail_x15_r0_body.cnn1132 PRE_first_tail_x15_r0_body.fnordI132 PRE_first_tail_x15_r0_body.fnordK132 PRE_first_tail_x15_r0_body.fnordL132
kernel_rfl PRE_first_tail_x15_r0_body.fi132 : PRE_first_tail_x15_r0_body.cli132.all (pnB PRE_first_tail_x15_r0_body.cx0_132.mlx) = true
kernel_rfl PRE_first_tail_x15_r0_body.fii132 : PRE_first_tail_x15_r0_body.cli132.all (fun k => decide (PRE_first_tail_x15_r0_body.cx1_132.mlx.items.get (PRE_first_tail_x15_r0_body.kappa132.node k) = (PRE_first_tail_x15_r0_body.cx0_132.mlx.items.get k).map PRE_first_tail_x15_r0_body.kappa132.nv)) = true
/-- **The compaction's footprint.** -/
theorem PRE_first_tail_x15_r0_body.cfoot132 (clean : Conv.NClean (⟨20812, 17885, 2779035, 5726⟩ : Conv.Cnt) (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1281.ffi).mlx) (hltC : ∀ h, PH (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1281.ffi).mlx h → h < (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1281.ffi).mlx.next) (nltC : ∀ i, PN (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1281.ffi).mlx i → i < (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1281.ffi).mlx.nnext) (itemsC : ∀ k v, (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1281.ffi).mlx.items.get k = some v → PN (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1281.ffi).mlx k) (tracedC : ∀ h o, (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1281.ffi).mlx.objs.get h = some o → ∀ i ∈ objTraces o, i < PRE_first_tail_x15_r0_body.P132.NL) (cl : SSt (· < 5744) PRE_first_tail_x15_r0_body.cx0_132.mlx) :
    Conv.MFoot PRE_first_tail_x15_r0_body.P132 5744 PRE_first_tail_x15_r0_body.kappa132 PRE_first_tail_x15_r0_body.kd132 PRE_first_tail_x15_r0_body.khinv132 PRE_first_tail_x15_r0_body.kninv132 (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1281.ffi).mlx PRE_first_tail_x15_r0_body.cx0_132.mlx PRE_first_tail_x15_r0_body.cx1_132.mlx (⟨20812, 17885, 2779035, 5726⟩ : Conv.Cnt) PRE_first_tail_x15_r0_body.clo132 PRE_first_tail_x15_r0_body.cln132 PRE_first_tail_x15_r0_body.cli132 PRE_first_tail_x15_r0_body.cwS132 PRE_first_tail_x15_r0_body.cnS132 PRE_first_tail_x15_r0_body.ciS132 :=
  ⟨rfl, rfl, rfl, PRE_first_tail_x15_r0_body.cnh0132, PRE_first_tail_x15_r0_body.cnh1132, PRE_first_tail_x15_r0_body.cnn0132, PRE_first_tail_x15_r0_body.cnn1132, PRE_first_tail_x15_r0_body.cplo132, PRE_first_tail_x15_r0_body.ccnt132, PRE_first_tail_x15_r0_body.cnband132, PRE_first_tail_x15_r0_body.chbelow132, PRE_first_tail_x15_r0_body.chren132, PRE_first_tail_x15_r0_body.cband132, PRE_first_tail_x15_r0_body.cnh1pos132, PRE_first_tail_x15_r0_body.cnren132, PRE_first_tail_x15_r0_body.cnlow132, PRE_first_tail_x15_r0_body.cabs0a132, PRE_first_tail_x15_r0_body.cabs0b132, PRE_first_tail_x15_r0_body.ctok1132, PRE_first_tail_x15_r0_body.cpend132, PRE_first_tail_x15_r0_body.cerrh132, PRE_first_tail_x15_r0_body.cfiles132, PRE_first_tail_x15_r0_body.carch132, PRE_first_tail_x15_r0_body.csizes132, PRE_first_tail_x15_r0_body.cwired132, PRE_first_tail_x15_r0_body.cfix132, clean, PRE_first_tail_x15_r0_body.fcxn132, PRE_first_tail_x15_r0_body.fcnn132, hltC, nltC, itemsC, tracedC, cl, PRE_first_tail_x15_r0_body.fle0132, PRE_first_tail_x15_r0_body.fnk132, PRE_first_tail_x15_r0_body.ckA132, PRE_first_tail_x15_r0_body.cobjsK132, PRE_first_tail_x15_r0_body.cnodesK132, PRE_first_tail_x15_r0_body.citemsK132, PRE_first_tail_x15_r0_body.f1A132, PRE_first_tail_x15_r0_body.f1O132, PRE_first_tail_x15_r0_body.f1N132, PRE_first_tail_x15_r0_body.f1I132, PRE_first_tail_x15_r0_body.fbd132, PRE_first_tail_x15_r0_body.fincW132, PRE_first_tail_x15_r0_body.fincI132, PRE_first_tail_x15_r0_body.fincN132, PRE_first_tail_x15_r0_body.flnF132, PRE_first_tail_x15_r0_body.fh132, PRE_first_tail_x15_r0_body.fo132, PRE_first_tail_x15_r0_body.fok132, PRE_first_tail_x15_r0_body.fnd132, PRE_first_tail_x15_r0_body.fp132, PRE_first_tail_x15_r0_body.fnord132, PRE_first_tail_x15_r0_body.fi132, PRE_first_tail_x15_r0_body.fii132⟩
theorem PRE_first_tail_x15_r0_body.cnshift132 (clean : Conv.NClean (⟨20812, 17885, 2779035, 5726⟩ : Conv.Cnt) (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1281.ffi).mlx) (hltC : ∀ h, PH (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1281.ffi).mlx h → h < (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1281.ffi).mlx.next) (nltC : ∀ i, PN (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1281.ffi).mlx i → i < (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1281.ffi).mlx.nnext) (itemsC : ∀ k v, (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1281.ffi).mlx.items.get k = some v → PN (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1281.ffi).mlx k) (tracedC : ∀ h o, (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1281.ffi).mlx.objs.get h = some o → ∀ i ∈ objTraces o, i < PRE_first_tail_x15_r0_body.P132.NL) (cl : SSt (· < 5744) PRE_first_tail_x15_r0_body.cx0_132.mlx) : NShift PRE_first_tail_x15_r0_body.P132 5744 PRE_first_tail_x15_r0_body.kappa132 PRE_first_tail_x15_r0_body.cx0_132 PRE_first_tail_x15_r0_body.cx1_132 :=
  Conv.nshift_of_foot (PRE_first_tail_x15_r0_body.cfoot132 clean hltC nltC itemsC tracedC cl) PRE_first_tail_x15_r0_body.chost132 (compact_a_eq PRE_first_tail_x15_r0_body.ckn0132 PRE_first_tail_x15_r0_body.ckn1132 PRE_first_tail_x15_r0_body.ckheap132 PRE_first_tail_x15_r0_body.ckpl132)

-- the observers: the layers' states at the call, the canonical and the merged state, their footprints and checks
noncomputable def PRE_first_tail_x15_r0_body.fxC_132 : PTrie Unit := (Host.Ts.Sim.Full.freedOf PRE_first_tail_x15_r0_body.s1281.ffi).getD PTrie.nil
noncomputable def PRE_first_tail_x15_r0_body.krC_132 : Host.Load.Layers.KRec := (Host.Ts.Sim.Full.krecOf PRE_first_tail_x15_r0_body.s1281.ffi).getD Host.Load.Layers.KRec.empty
kernel_rfl PRE_first_tail_x15_r0_body.ofxC_132 : (Host.Ts.Sim.Full.freedOf PRE_first_tail_x15_r0_body.s1281.ffi) = some PRE_first_tail_x15_r0_body.fxC_132
kernel_rfl PRE_first_tail_x15_r0_body.okrC_132 : (Host.Ts.Sim.Full.krecOf PRE_first_tail_x15_r0_body.s1281.ffi) = some PRE_first_tail_x15_r0_body.krC_132
noncomputable def PRE_first_tail_x15_r0_body.fx0_132 : PTrie Unit := (Host.Ts.Sim.Full.freedOf PRE_first_tail_x15_r0_body.s1283.ffi).getD PTrie.nil
noncomputable def PRE_first_tail_x15_r0_body.kr0_132 : Host.Load.Layers.KRec := (Host.Ts.Sim.Full.krecOf PRE_first_tail_x15_r0_body.s1283.ffi).getD Host.Load.Layers.KRec.empty
kernel_rfl PRE_first_tail_x15_r0_body.ofx0_132 : (Host.Ts.Sim.Full.freedOf PRE_first_tail_x15_r0_body.s1283.ffi) = some PRE_first_tail_x15_r0_body.fx0_132
kernel_rfl PRE_first_tail_x15_r0_body.okr0_132 : (Host.Ts.Sim.Full.krecOf PRE_first_tail_x15_r0_body.s1283.ffi) = some PRE_first_tail_x15_r0_body.kr0_132
noncomputable def PRE_first_tail_x15_r0_body.fx1_132 : PTrie Unit := (Host.Ts.Sim.Full.freedOf PRE_first_tail_x15_r0_body.s1282.ffi).getD PTrie.nil
noncomputable def PRE_first_tail_x15_r0_body.kr1_132 : Host.Load.Layers.KRec := (Host.Ts.Sim.Full.krecOf PRE_first_tail_x15_r0_body.s1282.ffi).getD Host.Load.Layers.KRec.empty
kernel_rfl PRE_first_tail_x15_r0_body.ofx1_132 : (Host.Ts.Sim.Full.freedOf PRE_first_tail_x15_r0_body.s1282.ffi) = some PRE_first_tail_x15_r0_body.fx1_132
kernel_rfl PRE_first_tail_x15_r0_body.okr1_132 : (Host.Ts.Sim.Full.krecOf PRE_first_tail_x15_r0_body.s1282.ffi) = some PRE_first_tail_x15_r0_body.kr1_132
kernel_rfl PRE_first_tail_x15_r0_body.ff0132 : PRE_first_tail_x15_r0_body.fx0_132 = Stage.setAll PRE_first_tail_x15_r0_body.fxC_132 (PRE_first_tail_x15_r0_body.clo132.filterMap fun i => (PRE_first_tail_x15_r0_body.fx0_132.get i).map (i, ·))
kernel_rfl PRE_first_tail_x15_r0_body.ff1132 : PRE_first_tail_x15_r0_body.fx1_132 = Stage.setAll PRE_first_tail_x15_r0_body.fxC_132 (PRE_first_tail_x15_r0_body.cwS132.filterMap fun i => (PRE_first_tail_x15_r0_body.fx1_132.get i).map (i, ·))
kernel_rfl PRE_first_tail_x15_r0_body.ffck132 : freedLB PRE_first_tail_x15_r0_body.kappa132 PRE_first_tail_x15_r0_body.cx0_132.mlx PRE_first_tail_x15_r0_body.fx0_132 PRE_first_tail_x15_r0_body.fx1_132 PRE_first_tail_x15_r0_body.clo132 = true
kernel_rfl PRE_first_tail_x15_r0_body.fkf0132 : PRE_first_tail_x15_r0_body.kr0_132.flags = Stage.setAll PRE_first_tail_x15_r0_body.krC_132.flags (PRE_first_tail_x15_r0_body.clo132.filterMap fun i => (PRE_first_tail_x15_r0_body.kr0_132.flags.get i).map (i, ·))
kernel_rfl PRE_first_tail_x15_r0_body.fkt0132 : PRE_first_tail_x15_r0_body.kr0_132.targs = Stage.setAll PRE_first_tail_x15_r0_body.krC_132.targs (PRE_first_tail_x15_r0_body.clo132.filterMap fun i => (PRE_first_tail_x15_r0_body.kr0_132.targs.get i).map (i, ·))
kernel_rfl PRE_first_tail_x15_r0_body.fkf1132 : PRE_first_tail_x15_r0_body.kr1_132.flags = Stage.setAll PRE_first_tail_x15_r0_body.krC_132.flags (PRE_first_tail_x15_r0_body.cwS132.filterMap fun i => (PRE_first_tail_x15_r0_body.kr1_132.flags.get i).map (i, ·))
kernel_rfl PRE_first_tail_x15_r0_body.fkt1132 : PRE_first_tail_x15_r0_body.kr1_132.targs = Stage.setAll PRE_first_tail_x15_r0_body.krC_132.targs (PRE_first_tail_x15_r0_body.cwS132.filterMap fun i => (PRE_first_tail_x15_r0_body.kr1_132.targs.get i).map (i, ·))
kernel_rfl PRE_first_tail_x15_r0_body.fkck132 : krecLB PRE_first_tail_x15_r0_body.kappa132 5744 PRE_first_tail_x15_r0_body.cx0_132.mlx PRE_first_tail_x15_r0_body.kr0_132 PRE_first_tail_x15_r0_body.kr1_132 PRE_first_tail_x15_r0_body.clo132 = true
kernel_rfl PRE_first_tail_x15_r0_body.fkn132 : Nat.ble 5726 5744 = true
-- the bridge and the pending traces' regions
kernel_rfl PRE_first_tail_x15_r0_body.cbridge132 : Host.Ts.Sim.Full.bridgeOf PRE_first_tail_x15_r0_body.s1282.ffi = Host.Ts.Sim.Full.bridgeOf PRE_first_tail_x15_r0_body.s1283.ffi
kernel_rfl PRE_first_tail_x15_r0_body.cpendR132 : pendRegB PRE_first_tail_x15_r0_body.kappa132 (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1283.ffi).mlx = true
kernel_rfl PRE_first_tail_x15_r0_body.cpendLe132 : Nat.ble (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1283.ffi).mlx.next (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1282.ffi).mlx.next = true
/-- **The compaction's native shift**, given the call's bookkeeping, its relation's facts (the model's and the
observers') and the canonical closedness. -/
theorem PRE_first_tail_x15_r0_body.cshift132 (clean : Conv.NClean (⟨20812, 17885, 2779035, 5726⟩ : Conv.Cnt) (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1281.ffi).mlx) (hltC : ∀ h, PH (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1281.ffi).mlx h → h < (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1281.ffi).mlx.next) (nltC : ∀ i, PN (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1281.ffi).mlx i → i < (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1281.ffi).mlx.nnext) (itemsC : ∀ k v, (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1281.ffi).mlx.items.get k = some v → PN (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1281.ffi).mlx k) (tracedC : ∀ h o, (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1281.ffi).mlx.objs.get h = some o → ∀ i ∈ objTraces o, i < PRE_first_tail_x15_r0_body.P132.NL) (cl : SSt (· < 5744) PRE_first_tail_x15_r0_body.cx0_132.mlx)
    (hobjC : ∀ h, PRE_first_tail_x15_r0_body.fxC_132.get h = some () → ((Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1281.ffi).mlx.objs.get h).isSome = true)
    (hfC : ∀ h, (PRE_first_tail_x15_r0_body.krC_132.flags.get h).isSome = true → ((Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1281.ffi).mlx.objs.get h).isSome = true)
    (htC : ∀ h, (PRE_first_tail_x15_r0_body.krC_132.targs.get h).isSome = true → ((Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1281.ffi).mlx.objs.get h).isSome = true)
    (hclC : ∀ h l, PRE_first_tail_x15_r0_body.krC_132.targs.get h = some l → Host.Ts.Sim.Full.STargs (· < (⟨20812, 17885, 2779035, 5726⟩ : Conv.Cnt).n) l) :
    Conv.FullShiftQ PRE_first_tail_x15_r0_body.P132 5744 PRE_first_tail_x15_r0_body.kappa132 PRE_first_tail_x15_r0_body.s1283.ffi PRE_first_tail_x15_r0_body.s1282.ffi :=
  ⟨PRE_first_tail_x15_r0_body.cnshift132 clean hltC nltC itemsC tracedC cl, PRE_first_tail_x15_r0_body.cqueue132, fun t ht => bSN_sound (List.all_eq_true.mp PRE_first_tail_x15_r0_body.ctokSupp132 t ht),
    PRE_first_tail_x15_r0_body.cbridge132,
    liveShift_foot (x0' := Host.Ts.Sim.Full.mlxOf PRE_first_tail_x15_r0_body.s1283.ffi) (x1' := Host.Ts.Sim.Full.mlxOf PRE_first_tail_x15_r0_body.s1282.ffi) (PRE_first_tail_x15_r0_body.cfoot132 clean hltC nltC itemsC tracedC cl) rfl PRE_first_tail_x15_r0_body.ofx0_132 PRE_first_tail_x15_r0_body.ofx1_132 hobjC PRE_first_tail_x15_r0_body.ff0132 PRE_first_tail_x15_r0_body.ff1132 PRE_first_tail_x15_r0_body.ffck132,
    kernShift_foot (x0' := Host.Ts.Sim.Full.mlxOf PRE_first_tail_x15_r0_body.s1283.ffi) (x1' := Host.Ts.Sim.Full.mlxOf PRE_first_tail_x15_r0_body.s1282.ffi) (PRE_first_tail_x15_r0_body.cfoot132 clean hltC nltC itemsC tracedC cl) rfl PRE_first_tail_x15_r0_body.okr0_132 PRE_first_tail_x15_r0_body.okr1_132 (Nat.le_of_ble_eq_true PRE_first_tail_x15_r0_body.fkn132) hfC htC hclC
      PRE_first_tail_x15_r0_body.fkf0132 PRE_first_tail_x15_r0_body.fkt0132 PRE_first_tail_x15_r0_body.fkf1132 PRE_first_tail_x15_r0_body.fkt1132 PRE_first_tail_x15_r0_body.fkck132,
    pendReg_of rfl PRE_first_tail_x15_r0_body.cnh0132 PRE_first_tail_x15_r0_body.cnh1132 (Nat.le_of_ble_eq_true PRE_first_tail_x15_r0_body.cpendLe132) PRE_first_tail_x15_r0_body.cpendR132⟩

end Host.Load.Run.Tpl
