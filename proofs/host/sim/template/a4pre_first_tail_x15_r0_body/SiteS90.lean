import host.sim.template.a4pre_first_tail_x15_r0_body.SiteCl90
import host.sim.conv.CompactFull
import host.sim.template.FootGen
set_option Elab.async false
namespace Host.Load.Run.Tpl
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
open Host.Ts Host.Ts.Sim Host.Ts.Sim.Template

/-! The compaction's native shift at call site 90 from its footprint (`Conv.nshift_of_foot`), and the observers'
(`liveShift_foot`, `kernShift_foot`): `Conv.FullShiftQ` for `Conv.full_compactQ`, given the call's bookkeeping and its
relation's facts. -/

/-- The load parameters of the chain (band-free: its start's node counter as `NL` and `N0`). -/
def PRE_first_tail_x15_r0_body.Pc90 : LoadP := ⟨18151, 131072, 1099511627776, 15235, 15235, []⟩
/-- The site's band raised to the map's checked fixed-node prefix, including newly recorded closure traces. -/
def PRE_first_tail_x15_r0_body.P90 : LoadP := PRE_first_tail_x15_r0_body.Pc90.raise 17090
kernel_rfl PRE_first_tail_x15_r0_body.craise90 : Nat.ble PRE_first_tail_x15_r0_body.Pc90.N0 17090 = true
theorem PRE_first_tail_x15_r0_body.raised90 : Host.Ts.Sim.Full.Raised PRE_first_tail_x15_r0_body.Pc90 PRE_first_tail_x15_r0_body.P90 :=
  .inr ⟨17090, rfl, Nat.le_of_ble_eq_true PRE_first_tail_x15_r0_body.craise90, rfl⟩
noncomputable abbrev PRE_first_tail_x15_r0_body.cx0_90 : Host.Load.LSt := clearTokens (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s805.ffi)
noncomputable abbrev PRE_first_tail_x15_r0_body.cx1_90 : Host.Load.LSt := clearTokens (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s804.ffi)
def PRE_first_tail_x15_r0_body.khinv90 : PTrie Nat := Stage.setAll PTrie.nil [(20008, 19982), (19986, 19983), (20009, 19984)]
def PRE_first_tail_x15_r0_body.kninv90 : PTrie Nat := Stage.setAll PTrie.nil [(17063, 17063), (17064, 17064), (17065, 17065), (17066, 17066), (17067, 17067), (17068, 17068), (17069, 17069), (17070, 17070), (17071, 17071), (17072, 17072), (17073, 17073), (17074, 17074), (17075, 17075), (17076, 17076), (17077, 17077), (17078, 17078), (17079, 17079), (17080, 17080), (17081, 17081), (17082, 17082), (17083, 17083), (17084, 17084), (17085, 17085), (17086, 17086), (17087, 17087), (17088, 17088), (17089, 17089)]
/-- The stage's footprint: its written and fresh handles, fresh nodes, written and fresh items. -/
def PRE_first_tail_x15_r0_body.cwS90 : List Nat := [19962, 19975, 19981, 19982, 19983, 19984, 19985, 19986, 19987, 19988, 19989, 19990, 19991, 19992, 19993, 19994, 19995, 19996, 19997, 19998, 19999, 20000, 20001, 20002, 20003, 20004, 20005, 20006, 20007, 20008, 20009]
def PRE_first_tail_x15_r0_body.cnS90 : List Nat := List.range' 17063 27
def PRE_first_tail_x15_r0_body.ciS90 : List Nat := [] ++ List.range' 17063 27

-- the small checks (`MChecks`'s)
kernel_rfl PRE_first_tail_x15_r0_body.cnh090 : PRE_first_tail_x15_r0_body.kd90.nh0 = PRE_first_tail_x15_r0_body.cx0_90.mlx.next
kernel_rfl PRE_first_tail_x15_r0_body.cnh190 : PRE_first_tail_x15_r0_body.kd90.nh1 = PRE_first_tail_x15_r0_body.cx1_90.mlx.next
kernel_rfl PRE_first_tail_x15_r0_body.cnn090 : PRE_first_tail_x15_r0_body.kd90.nn0 = PRE_first_tail_x15_r0_body.cx0_90.mlx.nnext
kernel_rfl PRE_first_tail_x15_r0_body.cnn190 : PRE_first_tail_x15_r0_body.kd90.nn1 = PRE_first_tail_x15_r0_body.cx1_90.mlx.nnext
kernel_rfl PRE_first_tail_x15_r0_body.cplo90 : (Nat.blt 0 PRE_first_tail_x15_r0_body.P90.lo && Nat.ble PRE_first_tail_x15_r0_body.P90.lo PRE_first_tail_x15_r0_body.cx0_90.mlx.next && Nat.ble PRE_first_tail_x15_r0_body.P90.lo RData.bigHi && Nat.ble RData.bigHi PRE_first_tail_x15_r0_body.P90.E) = true
kernel_rfl PRE_first_tail_x15_r0_body.ccnt90 : (Nat.ble PRE_first_tail_x15_r0_body.cx0_90.mlx.next PRE_first_tail_x15_r0_body.cx1_90.mlx.next && Nat.ble PRE_first_tail_x15_r0_body.cx0_90.mlx.nnext PRE_first_tail_x15_r0_body.cx1_90.mlx.nnext) = true
kernel_rfl PRE_first_tail_x15_r0_body.cnband90 : (Nat.blt 0 PRE_first_tail_x15_r0_body.P90.NL && Nat.ble PRE_first_tail_x15_r0_body.P90.NL PRE_first_tail_x15_r0_body.P90.N0 && Nat.ble PRE_first_tail_x15_r0_body.P90.N0 PRE_first_tail_x15_r0_body.cx0_90.mlx.nnext) = true
kernel_rfl PRE_first_tail_x15_r0_body.chbelow90 : PRE_first_tail_x15_r0_body.kd90.checkHndBelow = true
kernel_rfl PRE_first_tail_x15_r0_body.chren90 : checkRenG PRE_first_tail_x15_r0_body.kd90.hnd PRE_first_tail_x15_r0_body.khinv90 (phB PRE_first_tail_x15_r0_body.cx0_90.mlx) = true
kernel_rfl PRE_first_tail_x15_r0_body.cband90 : PRE_first_tail_x15_r0_body.kd90.checkBand PRE_first_tail_x15_r0_body.P90.lo = true
kernel_rfl PRE_first_tail_x15_r0_body.cnh1pos90 : Nat.blt 0 PRE_first_tail_x15_r0_body.kd90.nh1 = true
kernel_rfl PRE_first_tail_x15_r0_body.cnren90 : checkRenG PRE_first_tail_x15_r0_body.kd90.node PRE_first_tail_x15_r0_body.kninv90 (pnB PRE_first_tail_x15_r0_body.cx0_90.mlx) = true
kernel_rfl PRE_first_tail_x15_r0_body.cnlow90 : (PTrie.keysA PRE_first_tail_x15_r0_body.kd90.node).all (fun j => Nat.ble PRE_first_tail_x15_r0_body.P90.NL j && Nat.blt (PRE_first_tail_x15_r0_body.kd90.nodeF j) PRE_first_tail_x15_r0_body.cx1_90.mlx.nnext) = true
kernel_rfl PRE_first_tail_x15_r0_body.cabs0a90 : PRE_first_tail_x15_r0_body.cx0_90.mlx.arrs.get 0 = none
kernel_rfl PRE_first_tail_x15_r0_body.cabs0b90 : PRE_first_tail_x15_r0_body.cx0_90.mlx.objs.get 0 = none
kernel_rfl PRE_first_tail_x15_r0_body.ctok190 : PRE_first_tail_x15_r0_body.cx1_90.mlx.tokens = []
kernel_rfl PRE_first_tail_x15_r0_body.cpend90 : PRE_first_tail_x15_r0_body.cx1_90.mlx.pending = PRE_first_tail_x15_r0_body.cx0_90.mlx.pending.map PRE_first_tail_x15_r0_body.kappa90.pend
kernel_rfl PRE_first_tail_x15_r0_body.cerrh90 : PRE_first_tail_x15_r0_body.cx1_90.mlx.errh = PRE_first_tail_x15_r0_body.cx0_90.mlx.errh.map PRE_first_tail_x15_r0_body.kappa90.arg
kernel_rfl PRE_first_tail_x15_r0_body.cfiles90 : PRE_first_tail_x15_r0_body.cx1_90.mlx.files = PRE_first_tail_x15_r0_body.cx0_90.mlx.files
kernel_rfl PRE_first_tail_x15_r0_body.carch90 : PRE_first_tail_x15_r0_body.cx1_90.mlx.arch = PRE_first_tail_x15_r0_body.cx0_90.mlx.arch
kernel_rfl PRE_first_tail_x15_r0_body.csizes90 : PRE_first_tail_x15_r0_body.cx1_90.mlx.deviceSizes = PRE_first_tail_x15_r0_body.cx0_90.mlx.deviceSizes
kernel_rfl PRE_first_tail_x15_r0_body.cwired90 : PRE_first_tail_x15_r0_body.cx1_90.mlx.wired = PRE_first_tail_x15_r0_body.cx0_90.mlx.wired
kernel_rfl PRE_first_tail_x15_r0_body.chost90 : PRE_first_tail_x15_r0_body.cx1_90.host = PRE_first_tail_x15_r0_body.cx0_90.host
-- the compaction map's addresses are `PRE_first_tail_x15_r0_body.kd90`'s
kernel_rfl PRE_first_tail_x15_r0_body.ckn090 : PRE_first_tail_x15_r0_body.kd90.n0 = 2745893
kernel_rfl PRE_first_tail_x15_r0_body.ckn190 : PRE_first_tail_x15_r0_body.kd90.n1 = 2747042
kernel_rfl PRE_first_tail_x15_r0_body.ckheap90 : (PTrie.keysA PRE_first_tail_x15_r0_body.kd90.heap).all (fun x => Nat.ble 2745887 x) = true
kernel_rfl PRE_first_tail_x15_r0_body.ckpl90 : (List.range 6).all (fun j => decide (PRE_first_tail_x15_r0_body.kd90.heap.get (2745887 + j) = nth? PRE_first_tail_x15_r0_body.pl90 j)) = true
-- the map fixes the call's names (`Conv.fixOld_compact`), the call's counters
kernel_rfl PRE_first_tail_x15_r0_body.fja90 : Nat.ble 2745887 2745887 = true
kernel_rfl PRE_first_tail_x15_r0_body.fn90 : Nat.ble 3932 3932 = true
kernel_rfl PRE_first_tail_x15_r0_body.fjaD90 : Nat.ble 2745887 PRE_first_tail_x15_r0_body.kd90.n0 = true
kernel_rfl PRE_first_tail_x15_r0_body.fxn90 : Nat.ble 19982 PRE_first_tail_x15_r0_body.kd90.nh0 = true
kernel_rfl PRE_first_tail_x15_r0_body.fnn90 : Nat.ble 17063 PRE_first_tail_x15_r0_body.kd90.nn0 = true
kernel_rfl PRE_first_tail_x15_r0_body.fxb90 : Nat.ble 19982 RData.bigHi = true
kernel_rfl PRE_first_tail_x15_r0_body.fheap90 : (PTrie.keysA PRE_first_tail_x15_r0_body.kd90.heap).all (Nat.ble (⟨19982, 17063, 2745887, 3932⟩ : Conv.Cnt).ja) = true
kernel_rfl PRE_first_tail_x15_r0_body.fhnd90 : (PTrie.keysA PRE_first_tail_x15_r0_body.kd90.hnd).all (Nat.ble (⟨19982, 17063, 2745887, 3932⟩ : Conv.Cnt).xn) = true
kernel_rfl PRE_first_tail_x15_r0_body.fnode90 : (PTrie.keysA PRE_first_tail_x15_r0_body.kd90.node).all (Nat.ble (⟨19982, 17063, 2745887, 3932⟩ : Conv.Cnt).nn) = true
/-- The compaction map fixes the call's names. -/
theorem PRE_first_tail_x15_r0_body.cfix90 : Conv.FixOld (⟨19982, 17063, 2745887, 3932⟩ : Conv.Cnt) PRE_first_tail_x15_r0_body.kappa90 :=
  Conv.fixOld_compact (Nat.le_of_ble_eq_true PRE_first_tail_x15_r0_body.fja90) (Nat.le_of_ble_eq_true PRE_first_tail_x15_r0_body.fn90) (Nat.le_of_ble_eq_true PRE_first_tail_x15_r0_body.fjaD90) (Nat.le_of_ble_eq_true PRE_first_tail_x15_r0_body.fxn90) (Nat.le_of_ble_eq_true PRE_first_tail_x15_r0_body.fnn90) (Nat.le_of_ble_eq_true PRE_first_tail_x15_r0_body.fxb90) PRE_first_tail_x15_r0_body.fheap90 PRE_first_tail_x15_r0_body.fhnd90 PRE_first_tail_x15_r0_body.fnode90
kernel_rfl PRE_first_tail_x15_r0_body.fcxn90 : (⟨19982, 17063, 2745887, 3932⟩ : Conv.Cnt).xn = (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s803.ffi).mlx.next
kernel_rfl PRE_first_tail_x15_r0_body.fcnn90 : (⟨19982, 17063, 2745887, 3932⟩ : Conv.Cnt).nn = (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s803.ffi).mlx.nnext
kernel_rfl PRE_first_tail_x15_r0_body.fle090 : (Nat.ble (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s803.ffi).mlx.next PRE_first_tail_x15_r0_body.cx0_90.mlx.next && Nat.ble (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s803.ffi).mlx.nnext PRE_first_tail_x15_r0_body.cx0_90.mlx.nnext && Nat.ble (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s803.ffi).mlx.next RData.bigHi) = true
kernel_rfl PRE_first_tail_x15_r0_body.fnk90 : (PTrie.keysA PRE_first_tail_x15_r0_body.kd90.node).all (Nat.ble (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s803.ffi).mlx.nnext) = true
-- the merged state keeps the call's entries off the stage's footprint
kernel_rfl PRE_first_tail_x15_r0_body.f1A90 : PRE_first_tail_x15_r0_body.cx1_90.mlx.arrs = Stage.setAll (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s803.ffi).mlx.arrs (PRE_first_tail_x15_r0_body.cwS90.filterMap fun i => (PRE_first_tail_x15_r0_body.cx1_90.mlx.arrs.get i).map (i, ·))
kernel_rfl PRE_first_tail_x15_r0_body.f1O90 : PRE_first_tail_x15_r0_body.cx1_90.mlx.objs = Stage.setAll (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s803.ffi).mlx.objs (PRE_first_tail_x15_r0_body.cwS90.filterMap fun i => (PRE_first_tail_x15_r0_body.cx1_90.mlx.objs.get i).map (i, ·))
kernel_rfl PRE_first_tail_x15_r0_body.f1N90 : PRE_first_tail_x15_r0_body.cx1_90.mlx.nodes = Stage.setAll (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s803.ffi).mlx.nodes (PRE_first_tail_x15_r0_body.cnS90.filterMap fun i => (PRE_first_tail_x15_r0_body.cx1_90.mlx.nodes.get i).map (i, ·))
kernel_rfl PRE_first_tail_x15_r0_body.f1I90 : PRE_first_tail_x15_r0_body.cx1_90.mlx.items = Stage.setAll (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s803.ffi).mlx.items (PRE_first_tail_x15_r0_body.ciS90.filterMap fun i => (PRE_first_tail_x15_r0_body.cx1_90.mlx.items.get i).map (i, ·))
kernel_rfl PRE_first_tail_x15_r0_body.fbd90 : (PRE_first_tail_x15_r0_body.clo90 ++ PRE_first_tail_x15_r0_body.cln90 ++ PRE_first_tail_x15_r0_body.cli90 ++ PRE_first_tail_x15_r0_body.cwS90 ++ PRE_first_tail_x15_r0_body.cnS90 ++ PRE_first_tail_x15_r0_body.ciS90).all (fun i => Nat.blt (i / 4096) (4 ^ 31)) = true
kernel_rfl PRE_first_tail_x15_r0_body.fincW90 : PRE_first_tail_x15_r0_body.cwS90.all (fun h => !Nat.blt h (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s803.ffi).mlx.next || PRE_first_tail_x15_r0_body.clo90.contains h) = true
kernel_rfl PRE_first_tail_x15_r0_body.fincI90 : PRE_first_tail_x15_r0_body.ciS90.all (fun k => !Nat.blt k (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s803.ffi).mlx.nnext || PRE_first_tail_x15_r0_body.cli90.contains k) = true
kernel_rfl PRE_first_tail_x15_r0_body.fincN90 : PRE_first_tail_x15_r0_body.cnS90.all (Nat.ble (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s803.ffi).mlx.nnext) = true
kernel_rfl PRE_first_tail_x15_r0_body.flnF90 : PRE_first_tail_x15_r0_body.cln90.all (Nat.ble (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s803.ffi).mlx.nnext) = true
-- the checks over the changed lists
kernel_rfl PRE_first_tail_x15_r0_body.fh90 : PRE_first_tail_x15_r0_body.clo90.all (handleOK PRE_first_tail_x15_r0_body.kappa90 PRE_first_tail_x15_r0_body.P90.lo PRE_first_tail_x15_r0_body.cx0_90.mlx PRE_first_tail_x15_r0_body.cx1_90.mlx) = true
kernel_rfl PRE_first_tail_x15_r0_body.fo90 : PRE_first_tail_x15_r0_body.clo90.map (fun h => PRE_first_tail_x15_r0_body.cx1_90.mlx.objs.get (PRE_first_tail_x15_r0_body.kappa90.handle h)) = PRE_first_tail_x15_r0_body.clo90.map (fun h => (PRE_first_tail_x15_r0_body.cx0_90.mlx.objs.get h).map PRE_first_tail_x15_r0_body.kappa90.nobj)
kernel_rfl PRE_first_tail_x15_r0_body.fok90 : PRE_first_tail_x15_r0_body.clo90.all (objOK PRE_first_tail_x15_r0_body.kappa90 PRE_first_tail_x15_r0_body.P90.NL PRE_first_tail_x15_r0_body.cx0_90.mlx) = true
kernel_rfl PRE_first_tail_x15_r0_body.fnd90 : PRE_first_tail_x15_r0_body.cln90.all (nodeOKF PRE_first_tail_x15_r0_body.kappa90 PRE_first_tail_x15_r0_body.P90 PRE_first_tail_x15_r0_body.cx0_90.mlx PRE_first_tail_x15_r0_body.cx1_90.mlx) = true
kernel_rfl PRE_first_tail_x15_r0_body.fp90 : ((PRE_first_tail_x15_r0_body.cln90.filter (fullB PRE_first_tail_x15_r0_body.P90))).map (fun i => (PRE_first_tail_x15_r0_body.cx1_90.mlx.nodes.get (PRE_first_tail_x15_r0_body.kappa90.node i)).map Host.Mlx.Ffi.Node.prim) =
  ((PRE_first_tail_x15_r0_body.cln90.filter (fullB PRE_first_tail_x15_r0_body.P90))).map (fun i => (PRE_first_tail_x15_r0_body.cx0_90.mlx.nodes.get i).map fun nd => PRE_first_tail_x15_r0_body.kappa90.prim nd.prim)
kernel_rfl PRE_first_tail_x15_r0_body.fnordI90 : incrB PRE_first_tail_x15_r0_body.kd90.nodeF (List.range' 17063 27) = true
kernel_rfl PRE_first_tail_x15_r0_body.fnordK90 : (PTrie.keysA PRE_first_tail_x15_r0_body.kd90.node).all (fun k => Nat.ble 17063 k && Nat.blt k 17090) = true
kernel_rfl PRE_first_tail_x15_r0_body.fnordL90 : (PRE_first_tail_x15_r0_body.cln90.filter (Nat.ble PRE_first_tail_x15_r0_body.P90.N0)).all (fun i => Nat.ble i (PRE_first_tail_x15_r0_body.kd90.nodeF i) && (Nat.blt i 17090 || Nat.ble PRE_first_tail_x15_r0_body.kd90.nn0 i)) = true
theorem PRE_first_tail_x15_r0_body.fnord90 : (PRE_first_tail_x15_r0_body.cln90.filter (Nat.ble PRE_first_tail_x15_r0_body.P90.N0)).all (fun i => Nat.ble i (PRE_first_tail_x15_r0_body.kd90.nodeF i) &&
    (PTrie.keysA PRE_first_tail_x15_r0_body.kd90.node).all fun j => !Nat.blt j i || Nat.blt (PRE_first_tail_x15_r0_body.kd90.nodeF j) (PRE_first_tail_x15_r0_body.kd90.nodeF i)) = true :=
  cnord_of PRE_first_tail_x15_r0_body.cnlow90 PRE_first_tail_x15_r0_body.cnn190 PRE_first_tail_x15_r0_body.fnordI90 PRE_first_tail_x15_r0_body.fnordK90 PRE_first_tail_x15_r0_body.fnordL90
kernel_rfl PRE_first_tail_x15_r0_body.fi90 : PRE_first_tail_x15_r0_body.cli90.all (pnB PRE_first_tail_x15_r0_body.cx0_90.mlx) = true
kernel_rfl PRE_first_tail_x15_r0_body.fii90 : PRE_first_tail_x15_r0_body.cli90.all (fun k => decide (PRE_first_tail_x15_r0_body.cx1_90.mlx.items.get (PRE_first_tail_x15_r0_body.kappa90.node k) = (PRE_first_tail_x15_r0_body.cx0_90.mlx.items.get k).map PRE_first_tail_x15_r0_body.kappa90.nv)) = true
/-- **The compaction's footprint.** -/
theorem PRE_first_tail_x15_r0_body.cfoot90 (clean : Conv.NClean (⟨19982, 17063, 2745887, 3932⟩ : Conv.Cnt) (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s803.ffi).mlx) (hltC : ∀ h, PH (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s803.ffi).mlx h → h < (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s803.ffi).mlx.next) (nltC : ∀ i, PN (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s803.ffi).mlx i → i < (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s803.ffi).mlx.nnext) (itemsC : ∀ k v, (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s803.ffi).mlx.items.get k = some v → PN (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s803.ffi).mlx k) (tracedC : ∀ h o, (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s803.ffi).mlx.objs.get h = some o → ∀ i ∈ objTraces o, i < PRE_first_tail_x15_r0_body.P90.NL) (cl : SSt (· < 3950) PRE_first_tail_x15_r0_body.cx0_90.mlx) :
    Conv.MFoot PRE_first_tail_x15_r0_body.P90 3950 PRE_first_tail_x15_r0_body.kappa90 PRE_first_tail_x15_r0_body.kd90 PRE_first_tail_x15_r0_body.khinv90 PRE_first_tail_x15_r0_body.kninv90 (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s803.ffi).mlx PRE_first_tail_x15_r0_body.cx0_90.mlx PRE_first_tail_x15_r0_body.cx1_90.mlx (⟨19982, 17063, 2745887, 3932⟩ : Conv.Cnt) PRE_first_tail_x15_r0_body.clo90 PRE_first_tail_x15_r0_body.cln90 PRE_first_tail_x15_r0_body.cli90 PRE_first_tail_x15_r0_body.cwS90 PRE_first_tail_x15_r0_body.cnS90 PRE_first_tail_x15_r0_body.ciS90 :=
  ⟨rfl, rfl, rfl, PRE_first_tail_x15_r0_body.cnh090, PRE_first_tail_x15_r0_body.cnh190, PRE_first_tail_x15_r0_body.cnn090, PRE_first_tail_x15_r0_body.cnn190, PRE_first_tail_x15_r0_body.cplo90, PRE_first_tail_x15_r0_body.ccnt90, PRE_first_tail_x15_r0_body.cnband90, PRE_first_tail_x15_r0_body.chbelow90, PRE_first_tail_x15_r0_body.chren90, PRE_first_tail_x15_r0_body.cband90, PRE_first_tail_x15_r0_body.cnh1pos90, PRE_first_tail_x15_r0_body.cnren90, PRE_first_tail_x15_r0_body.cnlow90, PRE_first_tail_x15_r0_body.cabs0a90, PRE_first_tail_x15_r0_body.cabs0b90, PRE_first_tail_x15_r0_body.ctok190, PRE_first_tail_x15_r0_body.cpend90, PRE_first_tail_x15_r0_body.cerrh90, PRE_first_tail_x15_r0_body.cfiles90, PRE_first_tail_x15_r0_body.carch90, PRE_first_tail_x15_r0_body.csizes90, PRE_first_tail_x15_r0_body.cwired90, PRE_first_tail_x15_r0_body.cfix90, clean, PRE_first_tail_x15_r0_body.fcxn90, PRE_first_tail_x15_r0_body.fcnn90, hltC, nltC, itemsC, tracedC, cl, PRE_first_tail_x15_r0_body.fle090, PRE_first_tail_x15_r0_body.fnk90, PRE_first_tail_x15_r0_body.ckA90, PRE_first_tail_x15_r0_body.cobjsK90, PRE_first_tail_x15_r0_body.cnodesK90, PRE_first_tail_x15_r0_body.citemsK90, PRE_first_tail_x15_r0_body.f1A90, PRE_first_tail_x15_r0_body.f1O90, PRE_first_tail_x15_r0_body.f1N90, PRE_first_tail_x15_r0_body.f1I90, PRE_first_tail_x15_r0_body.fbd90, PRE_first_tail_x15_r0_body.fincW90, PRE_first_tail_x15_r0_body.fincI90, PRE_first_tail_x15_r0_body.fincN90, PRE_first_tail_x15_r0_body.flnF90, PRE_first_tail_x15_r0_body.fh90, PRE_first_tail_x15_r0_body.fo90, PRE_first_tail_x15_r0_body.fok90, PRE_first_tail_x15_r0_body.fnd90, PRE_first_tail_x15_r0_body.fp90, PRE_first_tail_x15_r0_body.fnord90, PRE_first_tail_x15_r0_body.fi90, PRE_first_tail_x15_r0_body.fii90⟩
theorem PRE_first_tail_x15_r0_body.cnshift90 (clean : Conv.NClean (⟨19982, 17063, 2745887, 3932⟩ : Conv.Cnt) (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s803.ffi).mlx) (hltC : ∀ h, PH (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s803.ffi).mlx h → h < (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s803.ffi).mlx.next) (nltC : ∀ i, PN (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s803.ffi).mlx i → i < (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s803.ffi).mlx.nnext) (itemsC : ∀ k v, (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s803.ffi).mlx.items.get k = some v → PN (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s803.ffi).mlx k) (tracedC : ∀ h o, (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s803.ffi).mlx.objs.get h = some o → ∀ i ∈ objTraces o, i < PRE_first_tail_x15_r0_body.P90.NL) (cl : SSt (· < 3950) PRE_first_tail_x15_r0_body.cx0_90.mlx) : NShift PRE_first_tail_x15_r0_body.P90 3950 PRE_first_tail_x15_r0_body.kappa90 PRE_first_tail_x15_r0_body.cx0_90 PRE_first_tail_x15_r0_body.cx1_90 :=
  Conv.nshift_of_foot (PRE_first_tail_x15_r0_body.cfoot90 clean hltC nltC itemsC tracedC cl) PRE_first_tail_x15_r0_body.chost90 (compact_a_eq PRE_first_tail_x15_r0_body.ckn090 PRE_first_tail_x15_r0_body.ckn190 PRE_first_tail_x15_r0_body.ckheap90 PRE_first_tail_x15_r0_body.ckpl90)

-- the observers: the layers' states at the call, the canonical and the merged state, their footprints and checks
noncomputable def PRE_first_tail_x15_r0_body.fxC_90 : PTrie Unit := (Host.Ts.Sim.Full.freedOf PRE_first_tail_x15_r0_body.s803.ffi).getD PTrie.nil
noncomputable def PRE_first_tail_x15_r0_body.krC_90 : Host.Load.Layers.KRec := (Host.Ts.Sim.Full.krecOf PRE_first_tail_x15_r0_body.s803.ffi).getD Host.Load.Layers.KRec.empty
kernel_rfl PRE_first_tail_x15_r0_body.ofxC_90 : (Host.Ts.Sim.Full.freedOf PRE_first_tail_x15_r0_body.s803.ffi) = some PRE_first_tail_x15_r0_body.fxC_90
kernel_rfl PRE_first_tail_x15_r0_body.okrC_90 : (Host.Ts.Sim.Full.krecOf PRE_first_tail_x15_r0_body.s803.ffi) = some PRE_first_tail_x15_r0_body.krC_90
noncomputable def PRE_first_tail_x15_r0_body.fx0_90 : PTrie Unit := (Host.Ts.Sim.Full.freedOf PRE_first_tail_x15_r0_body.s805.ffi).getD PTrie.nil
noncomputable def PRE_first_tail_x15_r0_body.kr0_90 : Host.Load.Layers.KRec := (Host.Ts.Sim.Full.krecOf PRE_first_tail_x15_r0_body.s805.ffi).getD Host.Load.Layers.KRec.empty
kernel_rfl PRE_first_tail_x15_r0_body.ofx0_90 : (Host.Ts.Sim.Full.freedOf PRE_first_tail_x15_r0_body.s805.ffi) = some PRE_first_tail_x15_r0_body.fx0_90
kernel_rfl PRE_first_tail_x15_r0_body.okr0_90 : (Host.Ts.Sim.Full.krecOf PRE_first_tail_x15_r0_body.s805.ffi) = some PRE_first_tail_x15_r0_body.kr0_90
noncomputable def PRE_first_tail_x15_r0_body.fx1_90 : PTrie Unit := (Host.Ts.Sim.Full.freedOf PRE_first_tail_x15_r0_body.s804.ffi).getD PTrie.nil
noncomputable def PRE_first_tail_x15_r0_body.kr1_90 : Host.Load.Layers.KRec := (Host.Ts.Sim.Full.krecOf PRE_first_tail_x15_r0_body.s804.ffi).getD Host.Load.Layers.KRec.empty
kernel_rfl PRE_first_tail_x15_r0_body.ofx1_90 : (Host.Ts.Sim.Full.freedOf PRE_first_tail_x15_r0_body.s804.ffi) = some PRE_first_tail_x15_r0_body.fx1_90
kernel_rfl PRE_first_tail_x15_r0_body.okr1_90 : (Host.Ts.Sim.Full.krecOf PRE_first_tail_x15_r0_body.s804.ffi) = some PRE_first_tail_x15_r0_body.kr1_90
kernel_rfl PRE_first_tail_x15_r0_body.ff090 : PRE_first_tail_x15_r0_body.fx0_90 = Stage.setAll PRE_first_tail_x15_r0_body.fxC_90 (PRE_first_tail_x15_r0_body.clo90.filterMap fun i => (PRE_first_tail_x15_r0_body.fx0_90.get i).map (i, ·))
kernel_rfl PRE_first_tail_x15_r0_body.ff190 : PRE_first_tail_x15_r0_body.fx1_90 = Stage.setAll PRE_first_tail_x15_r0_body.fxC_90 (PRE_first_tail_x15_r0_body.cwS90.filterMap fun i => (PRE_first_tail_x15_r0_body.fx1_90.get i).map (i, ·))
kernel_rfl PRE_first_tail_x15_r0_body.ffck90 : freedLB PRE_first_tail_x15_r0_body.kappa90 PRE_first_tail_x15_r0_body.cx0_90.mlx PRE_first_tail_x15_r0_body.fx0_90 PRE_first_tail_x15_r0_body.fx1_90 PRE_first_tail_x15_r0_body.clo90 = true
kernel_rfl PRE_first_tail_x15_r0_body.fkf090 : PRE_first_tail_x15_r0_body.kr0_90.flags = Stage.setAll PRE_first_tail_x15_r0_body.krC_90.flags (PRE_first_tail_x15_r0_body.clo90.filterMap fun i => (PRE_first_tail_x15_r0_body.kr0_90.flags.get i).map (i, ·))
kernel_rfl PRE_first_tail_x15_r0_body.fkt090 : PRE_first_tail_x15_r0_body.kr0_90.targs = Stage.setAll PRE_first_tail_x15_r0_body.krC_90.targs (PRE_first_tail_x15_r0_body.clo90.filterMap fun i => (PRE_first_tail_x15_r0_body.kr0_90.targs.get i).map (i, ·))
kernel_rfl PRE_first_tail_x15_r0_body.fkf190 : PRE_first_tail_x15_r0_body.kr1_90.flags = Stage.setAll PRE_first_tail_x15_r0_body.krC_90.flags (PRE_first_tail_x15_r0_body.cwS90.filterMap fun i => (PRE_first_tail_x15_r0_body.kr1_90.flags.get i).map (i, ·))
kernel_rfl PRE_first_tail_x15_r0_body.fkt190 : PRE_first_tail_x15_r0_body.kr1_90.targs = Stage.setAll PRE_first_tail_x15_r0_body.krC_90.targs (PRE_first_tail_x15_r0_body.cwS90.filterMap fun i => (PRE_first_tail_x15_r0_body.kr1_90.targs.get i).map (i, ·))
kernel_rfl PRE_first_tail_x15_r0_body.fkck90 : krecLB PRE_first_tail_x15_r0_body.kappa90 3950 PRE_first_tail_x15_r0_body.cx0_90.mlx PRE_first_tail_x15_r0_body.kr0_90 PRE_first_tail_x15_r0_body.kr1_90 PRE_first_tail_x15_r0_body.clo90 = true
kernel_rfl PRE_first_tail_x15_r0_body.fkn90 : Nat.ble 3932 3950 = true
-- the bridge and the pending traces' regions
kernel_rfl PRE_first_tail_x15_r0_body.cbridge90 : Host.Ts.Sim.Full.bridgeOf PRE_first_tail_x15_r0_body.s804.ffi = Host.Ts.Sim.Full.bridgeOf PRE_first_tail_x15_r0_body.s805.ffi
kernel_rfl PRE_first_tail_x15_r0_body.cpendR90 : pendRegB PRE_first_tail_x15_r0_body.kappa90 (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s805.ffi).mlx = true
kernel_rfl PRE_first_tail_x15_r0_body.cpendLe90 : Nat.ble (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s805.ffi).mlx.next (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s804.ffi).mlx.next = true
/-- **The compaction's native shift**, given the call's bookkeeping, its relation's facts (the model's and the
observers') and the canonical closedness. -/
theorem PRE_first_tail_x15_r0_body.cshift90 (clean : Conv.NClean (⟨19982, 17063, 2745887, 3932⟩ : Conv.Cnt) (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s803.ffi).mlx) (hltC : ∀ h, PH (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s803.ffi).mlx h → h < (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s803.ffi).mlx.next) (nltC : ∀ i, PN (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s803.ffi).mlx i → i < (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s803.ffi).mlx.nnext) (itemsC : ∀ k v, (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s803.ffi).mlx.items.get k = some v → PN (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s803.ffi).mlx k) (tracedC : ∀ h o, (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s803.ffi).mlx.objs.get h = some o → ∀ i ∈ objTraces o, i < PRE_first_tail_x15_r0_body.P90.NL) (cl : SSt (· < 3950) PRE_first_tail_x15_r0_body.cx0_90.mlx)
    (hobjC : ∀ h, PRE_first_tail_x15_r0_body.fxC_90.get h = some () → ((Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s803.ffi).mlx.objs.get h).isSome = true)
    (hfC : ∀ h, (PRE_first_tail_x15_r0_body.krC_90.flags.get h).isSome = true → ((Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s803.ffi).mlx.objs.get h).isSome = true)
    (htC : ∀ h, (PRE_first_tail_x15_r0_body.krC_90.targs.get h).isSome = true → ((Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s803.ffi).mlx.objs.get h).isSome = true)
    (hclC : ∀ h l, PRE_first_tail_x15_r0_body.krC_90.targs.get h = some l → Host.Ts.Sim.Full.STargs (· < (⟨19982, 17063, 2745887, 3932⟩ : Conv.Cnt).n) l) :
    Conv.FullShiftQ PRE_first_tail_x15_r0_body.P90 3950 PRE_first_tail_x15_r0_body.kappa90 PRE_first_tail_x15_r0_body.s805.ffi PRE_first_tail_x15_r0_body.s804.ffi :=
  ⟨PRE_first_tail_x15_r0_body.cnshift90 clean hltC nltC itemsC tracedC cl, PRE_first_tail_x15_r0_body.cqueue90, fun t ht => bSN_sound (List.all_eq_true.mp PRE_first_tail_x15_r0_body.ctokSupp90 t ht),
    PRE_first_tail_x15_r0_body.cbridge90,
    liveShift_foot (x0' := Host.Ts.Sim.Full.mlxOf PRE_first_tail_x15_r0_body.s805.ffi) (x1' := Host.Ts.Sim.Full.mlxOf PRE_first_tail_x15_r0_body.s804.ffi) (PRE_first_tail_x15_r0_body.cfoot90 clean hltC nltC itemsC tracedC cl) rfl PRE_first_tail_x15_r0_body.ofx0_90 PRE_first_tail_x15_r0_body.ofx1_90 hobjC PRE_first_tail_x15_r0_body.ff090 PRE_first_tail_x15_r0_body.ff190 PRE_first_tail_x15_r0_body.ffck90,
    kernShift_foot (x0' := Host.Ts.Sim.Full.mlxOf PRE_first_tail_x15_r0_body.s805.ffi) (x1' := Host.Ts.Sim.Full.mlxOf PRE_first_tail_x15_r0_body.s804.ffi) (PRE_first_tail_x15_r0_body.cfoot90 clean hltC nltC itemsC tracedC cl) rfl PRE_first_tail_x15_r0_body.okr0_90 PRE_first_tail_x15_r0_body.okr1_90 (Nat.le_of_ble_eq_true PRE_first_tail_x15_r0_body.fkn90) hfC htC hclC
      PRE_first_tail_x15_r0_body.fkf090 PRE_first_tail_x15_r0_body.fkt090 PRE_first_tail_x15_r0_body.fkf190 PRE_first_tail_x15_r0_body.fkt190 PRE_first_tail_x15_r0_body.fkck90,
    pendReg_of rfl PRE_first_tail_x15_r0_body.cnh090 PRE_first_tail_x15_r0_body.cnh190 (Nat.le_of_ble_eq_true PRE_first_tail_x15_r0_body.cpendLe90) PRE_first_tail_x15_r0_body.cpendR90⟩

end Host.Load.Run.Tpl
