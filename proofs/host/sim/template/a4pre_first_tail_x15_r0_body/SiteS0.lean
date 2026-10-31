import host.sim.template.a4pre_first_tail_x15_r0_body.SiteCl0
import host.sim.conv.CompactFull
import host.sim.template.FootGen
set_option Elab.async false
namespace Host.Load.Run.Tpl
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
open Host.Ts Host.Ts.Sim Host.Ts.Sim.Template

/-! The compaction's native shift at call site 0 from its footprint (`Conv.nshift_of_foot`), and the observers'
(`liveShift_foot`, `kernShift_foot`): `Conv.FullShiftQ` for `Conv.full_compactQ`, given the call's bookkeeping and its
relation's facts. -/

/-- The load parameters of the chain (band-free: its start's node counter as `NL` and `N0`). -/
def PRE_first_tail_x15_r0_body.Pc0 : LoadP := ⟨18151, 131072, 1099511627776, 15235, 15235, []⟩
/-- The site's band raised to the map's checked fixed-node prefix, including newly recorded closure traces. -/
def PRE_first_tail_x15_r0_body.P0 : LoadP := PRE_first_tail_x15_r0_body.Pc0.raise 15296
kernel_rfl PRE_first_tail_x15_r0_body.craise0 : Nat.ble PRE_first_tail_x15_r0_body.Pc0.N0 15296 = true
theorem PRE_first_tail_x15_r0_body.raised0 : Host.Ts.Sim.Full.Raised PRE_first_tail_x15_r0_body.Pc0 PRE_first_tail_x15_r0_body.P0 :=
  .inr ⟨15296, rfl, Nat.le_of_ble_eq_true PRE_first_tail_x15_r0_body.craise0, rfl⟩
noncomputable abbrev PRE_first_tail_x15_r0_body.cx0_0 : Host.Load.LSt := clearTokens (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s16.ffi)
noncomputable abbrev PRE_first_tail_x15_r0_body.cx1_0 : Host.Load.LSt := clearTokens (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s15.ffi)
def PRE_first_tail_x15_r0_body.khinv0 : PTrie Nat := Stage.setAll PTrie.nil [(18241, 18189), (18193, 18190), (18237, 18191), (18216, 18192), (18197, 18193), (18194, 18194), (18242, 18195), (18195, 18196)]
def PRE_first_tail_x15_r0_body.kninv0 : PTrie Nat := Stage.setAll PTrie.nil [(15254, 15254), (15255, 15255), (15256, 15256), (15257, 15257), (15258, 15258), (15259, 15259), (15260, 15260), (15261, 15261), (15262, 15262), (15263, 15263), (15264, 15264), (15265, 15265), (15266, 15266), (15267, 15267), (15268, 15268), (15269, 15269), (15270, 15270), (15271, 15271), (15272, 15272), (15273, 15273), (15274, 15274), (15275, 15275), (15276, 15276), (15277, 15277), (15278, 15278), (15279, 15279), (15280, 15280), (15281, 15281), (15282, 15282), (15283, 15283), (15284, 15284), (15285, 15285), (15286, 15286), (15287, 15287), (15288, 15288), (15289, 15289), (15290, 15290), (15291, 15291), (15292, 15292), (15293, 15293), (15294, 15294), (15295, 15295)]
/-- The stage's footprint: its written and fresh handles, fresh nodes, written and fresh items. -/
def PRE_first_tail_x15_r0_body.cwS0 : List Nat := [18169, 18182, 18188, 18189, 18190, 18191, 18192, 18193, 18194, 18195, 18196, 18197, 18198, 18199, 18200, 18202, 18203, 18204, 18205, 18206, 18207, 18208, 18209, 18210, 18211, 18212, 18213, 18214, 18215, 18216, 18217, 18218, 18219, 18221, 18222, 18223, 18224, 18225, 18226, 18227, 18228, 18229, 18230, 18231, 18232, 18233, 18234, 18235, 18236, 18237, 18238, 18239, 18240, 18241, 18242]
def PRE_first_tail_x15_r0_body.cnS0 : List Nat := List.range' 15254 42
def PRE_first_tail_x15_r0_body.ciS0 : List Nat := [] ++ List.range' 15254 42

-- the small checks (`MChecks`'s)
kernel_rfl PRE_first_tail_x15_r0_body.cnh00 : PRE_first_tail_x15_r0_body.kd0.nh0 = PRE_first_tail_x15_r0_body.cx0_0.mlx.next
kernel_rfl PRE_first_tail_x15_r0_body.cnh10 : PRE_first_tail_x15_r0_body.kd0.nh1 = PRE_first_tail_x15_r0_body.cx1_0.mlx.next
kernel_rfl PRE_first_tail_x15_r0_body.cnn00 : PRE_first_tail_x15_r0_body.kd0.nn0 = PRE_first_tail_x15_r0_body.cx0_0.mlx.nnext
kernel_rfl PRE_first_tail_x15_r0_body.cnn10 : PRE_first_tail_x15_r0_body.kd0.nn1 = PRE_first_tail_x15_r0_body.cx1_0.mlx.nnext
kernel_rfl PRE_first_tail_x15_r0_body.cplo0 : (Nat.blt 0 PRE_first_tail_x15_r0_body.P0.lo && Nat.ble PRE_first_tail_x15_r0_body.P0.lo PRE_first_tail_x15_r0_body.cx0_0.mlx.next && Nat.ble PRE_first_tail_x15_r0_body.P0.lo RData.bigHi && Nat.ble RData.bigHi PRE_first_tail_x15_r0_body.P0.E) = true
kernel_rfl PRE_first_tail_x15_r0_body.ccnt0 : (Nat.ble PRE_first_tail_x15_r0_body.cx0_0.mlx.next PRE_first_tail_x15_r0_body.cx1_0.mlx.next && Nat.ble PRE_first_tail_x15_r0_body.cx0_0.mlx.nnext PRE_first_tail_x15_r0_body.cx1_0.mlx.nnext) = true
kernel_rfl PRE_first_tail_x15_r0_body.cnband0 : (Nat.blt 0 PRE_first_tail_x15_r0_body.P0.NL && Nat.ble PRE_first_tail_x15_r0_body.P0.NL PRE_first_tail_x15_r0_body.P0.N0 && Nat.ble PRE_first_tail_x15_r0_body.P0.N0 PRE_first_tail_x15_r0_body.cx0_0.mlx.nnext) = true
kernel_rfl PRE_first_tail_x15_r0_body.chbelow0 : PRE_first_tail_x15_r0_body.kd0.checkHndBelow = true
kernel_rfl PRE_first_tail_x15_r0_body.chren0 : checkRenG PRE_first_tail_x15_r0_body.kd0.hnd PRE_first_tail_x15_r0_body.khinv0 (phB PRE_first_tail_x15_r0_body.cx0_0.mlx) = true
kernel_rfl PRE_first_tail_x15_r0_body.cband0 : PRE_first_tail_x15_r0_body.kd0.checkBand PRE_first_tail_x15_r0_body.P0.lo = true
kernel_rfl PRE_first_tail_x15_r0_body.cnh1pos0 : Nat.blt 0 PRE_first_tail_x15_r0_body.kd0.nh1 = true
kernel_rfl PRE_first_tail_x15_r0_body.cnren0 : checkRenG PRE_first_tail_x15_r0_body.kd0.node PRE_first_tail_x15_r0_body.kninv0 (pnB PRE_first_tail_x15_r0_body.cx0_0.mlx) = true
kernel_rfl PRE_first_tail_x15_r0_body.cnlow0 : (PTrie.keysA PRE_first_tail_x15_r0_body.kd0.node).all (fun j => Nat.ble PRE_first_tail_x15_r0_body.P0.NL j && Nat.blt (PRE_first_tail_x15_r0_body.kd0.nodeF j) PRE_first_tail_x15_r0_body.cx1_0.mlx.nnext) = true
kernel_rfl PRE_first_tail_x15_r0_body.cabs0a0 : PRE_first_tail_x15_r0_body.cx0_0.mlx.arrs.get 0 = none
kernel_rfl PRE_first_tail_x15_r0_body.cabs0b0 : PRE_first_tail_x15_r0_body.cx0_0.mlx.objs.get 0 = none
kernel_rfl PRE_first_tail_x15_r0_body.ctok10 : PRE_first_tail_x15_r0_body.cx1_0.mlx.tokens = []
kernel_rfl PRE_first_tail_x15_r0_body.cpend0 : PRE_first_tail_x15_r0_body.cx1_0.mlx.pending = PRE_first_tail_x15_r0_body.cx0_0.mlx.pending.map PRE_first_tail_x15_r0_body.kappa0.pend
kernel_rfl PRE_first_tail_x15_r0_body.cerrh0 : PRE_first_tail_x15_r0_body.cx1_0.mlx.errh = PRE_first_tail_x15_r0_body.cx0_0.mlx.errh.map PRE_first_tail_x15_r0_body.kappa0.arg
kernel_rfl PRE_first_tail_x15_r0_body.cfiles0 : PRE_first_tail_x15_r0_body.cx1_0.mlx.files = PRE_first_tail_x15_r0_body.cx0_0.mlx.files
kernel_rfl PRE_first_tail_x15_r0_body.carch0 : PRE_first_tail_x15_r0_body.cx1_0.mlx.arch = PRE_first_tail_x15_r0_body.cx0_0.mlx.arch
kernel_rfl PRE_first_tail_x15_r0_body.csizes0 : PRE_first_tail_x15_r0_body.cx1_0.mlx.deviceSizes = PRE_first_tail_x15_r0_body.cx0_0.mlx.deviceSizes
kernel_rfl PRE_first_tail_x15_r0_body.cwired0 : PRE_first_tail_x15_r0_body.cx1_0.mlx.wired = PRE_first_tail_x15_r0_body.cx0_0.mlx.wired
kernel_rfl PRE_first_tail_x15_r0_body.chost0 : PRE_first_tail_x15_r0_body.cx1_0.host = PRE_first_tail_x15_r0_body.cx0_0.host
-- the compaction map's addresses are `PRE_first_tail_x15_r0_body.kd0`'s
kernel_rfl PRE_first_tail_x15_r0_body.ckn00 : PRE_first_tail_x15_r0_body.kd0.n0 = 2674920
kernel_rfl PRE_first_tail_x15_r0_body.ckn10 : PRE_first_tail_x15_r0_body.kd0.n1 = 2676612
kernel_rfl PRE_first_tail_x15_r0_body.ckheap0 : (PTrie.keysA PRE_first_tail_x15_r0_body.kd0.heap).all (fun x => Nat.ble 2674897 x) = true
kernel_rfl PRE_first_tail_x15_r0_body.ckpl0 : (List.range 23).all (fun j => decide (PRE_first_tail_x15_r0_body.kd0.heap.get (2674897 + j) = nth? PRE_first_tail_x15_r0_body.pl0 j)) = true
-- the map fixes the call's names (`Conv.fixOld_compact`), the call's counters
kernel_rfl PRE_first_tail_x15_r0_body.fja0 : Nat.ble 2674897 2674897 = true
kernel_rfl PRE_first_tail_x15_r0_body.fn0 : Nat.ble 83 83 = true
kernel_rfl PRE_first_tail_x15_r0_body.fjaD0 : Nat.ble 2674897 PRE_first_tail_x15_r0_body.kd0.n0 = true
kernel_rfl PRE_first_tail_x15_r0_body.fxn0 : Nat.ble 18189 PRE_first_tail_x15_r0_body.kd0.nh0 = true
kernel_rfl PRE_first_tail_x15_r0_body.fnn0 : Nat.ble 15254 PRE_first_tail_x15_r0_body.kd0.nn0 = true
kernel_rfl PRE_first_tail_x15_r0_body.fxb0 : Nat.ble 18189 RData.bigHi = true
kernel_rfl PRE_first_tail_x15_r0_body.fheap0 : (PTrie.keysA PRE_first_tail_x15_r0_body.kd0.heap).all (Nat.ble (⟨18189, 15254, 2674897, 83⟩ : Conv.Cnt).ja) = true
kernel_rfl PRE_first_tail_x15_r0_body.fhnd0 : (PTrie.keysA PRE_first_tail_x15_r0_body.kd0.hnd).all (Nat.ble (⟨18189, 15254, 2674897, 83⟩ : Conv.Cnt).xn) = true
kernel_rfl PRE_first_tail_x15_r0_body.fnode0 : (PTrie.keysA PRE_first_tail_x15_r0_body.kd0.node).all (Nat.ble (⟨18189, 15254, 2674897, 83⟩ : Conv.Cnt).nn) = true
/-- The compaction map fixes the call's names. -/
theorem PRE_first_tail_x15_r0_body.cfix0 : Conv.FixOld (⟨18189, 15254, 2674897, 83⟩ : Conv.Cnt) PRE_first_tail_x15_r0_body.kappa0 :=
  Conv.fixOld_compact (Nat.le_of_ble_eq_true PRE_first_tail_x15_r0_body.fja0) (Nat.le_of_ble_eq_true PRE_first_tail_x15_r0_body.fn0) (Nat.le_of_ble_eq_true PRE_first_tail_x15_r0_body.fjaD0) (Nat.le_of_ble_eq_true PRE_first_tail_x15_r0_body.fxn0) (Nat.le_of_ble_eq_true PRE_first_tail_x15_r0_body.fnn0) (Nat.le_of_ble_eq_true PRE_first_tail_x15_r0_body.fxb0) PRE_first_tail_x15_r0_body.fheap0 PRE_first_tail_x15_r0_body.fhnd0 PRE_first_tail_x15_r0_body.fnode0
kernel_rfl PRE_first_tail_x15_r0_body.fcxn0 : (⟨18189, 15254, 2674897, 83⟩ : Conv.Cnt).xn = (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s14.ffi).mlx.next
kernel_rfl PRE_first_tail_x15_r0_body.fcnn0 : (⟨18189, 15254, 2674897, 83⟩ : Conv.Cnt).nn = (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s14.ffi).mlx.nnext
kernel_rfl PRE_first_tail_x15_r0_body.fle00 : (Nat.ble (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s14.ffi).mlx.next PRE_first_tail_x15_r0_body.cx0_0.mlx.next && Nat.ble (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s14.ffi).mlx.nnext PRE_first_tail_x15_r0_body.cx0_0.mlx.nnext && Nat.ble (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s14.ffi).mlx.next RData.bigHi) = true
kernel_rfl PRE_first_tail_x15_r0_body.fnk0 : (PTrie.keysA PRE_first_tail_x15_r0_body.kd0.node).all (Nat.ble (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s14.ffi).mlx.nnext) = true
-- the merged state keeps the call's entries off the stage's footprint
kernel_rfl PRE_first_tail_x15_r0_body.f1A0 : PRE_first_tail_x15_r0_body.cx1_0.mlx.arrs = Stage.setAll (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s14.ffi).mlx.arrs (PRE_first_tail_x15_r0_body.cwS0.filterMap fun i => (PRE_first_tail_x15_r0_body.cx1_0.mlx.arrs.get i).map (i, ·))
kernel_rfl PRE_first_tail_x15_r0_body.f1O0 : PRE_first_tail_x15_r0_body.cx1_0.mlx.objs = Stage.setAll (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s14.ffi).mlx.objs (PRE_first_tail_x15_r0_body.cwS0.filterMap fun i => (PRE_first_tail_x15_r0_body.cx1_0.mlx.objs.get i).map (i, ·))
kernel_rfl PRE_first_tail_x15_r0_body.f1N0 : PRE_first_tail_x15_r0_body.cx1_0.mlx.nodes = Stage.setAll (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s14.ffi).mlx.nodes (PRE_first_tail_x15_r0_body.cnS0.filterMap fun i => (PRE_first_tail_x15_r0_body.cx1_0.mlx.nodes.get i).map (i, ·))
kernel_rfl PRE_first_tail_x15_r0_body.f1I0 : PRE_first_tail_x15_r0_body.cx1_0.mlx.items = Stage.setAll (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s14.ffi).mlx.items (PRE_first_tail_x15_r0_body.ciS0.filterMap fun i => (PRE_first_tail_x15_r0_body.cx1_0.mlx.items.get i).map (i, ·))
kernel_rfl PRE_first_tail_x15_r0_body.fbd0 : (PRE_first_tail_x15_r0_body.clo0 ++ PRE_first_tail_x15_r0_body.cln0 ++ PRE_first_tail_x15_r0_body.cli0 ++ PRE_first_tail_x15_r0_body.cwS0 ++ PRE_first_tail_x15_r0_body.cnS0 ++ PRE_first_tail_x15_r0_body.ciS0).all (fun i => Nat.blt (i / 4096) (4 ^ 31)) = true
kernel_rfl PRE_first_tail_x15_r0_body.fincW0 : PRE_first_tail_x15_r0_body.cwS0.all (fun h => !Nat.blt h (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s14.ffi).mlx.next || PRE_first_tail_x15_r0_body.clo0.contains h) = true
kernel_rfl PRE_first_tail_x15_r0_body.fincI0 : PRE_first_tail_x15_r0_body.ciS0.all (fun k => !Nat.blt k (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s14.ffi).mlx.nnext || PRE_first_tail_x15_r0_body.cli0.contains k) = true
kernel_rfl PRE_first_tail_x15_r0_body.fincN0 : PRE_first_tail_x15_r0_body.cnS0.all (Nat.ble (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s14.ffi).mlx.nnext) = true
kernel_rfl PRE_first_tail_x15_r0_body.flnF0 : PRE_first_tail_x15_r0_body.cln0.all (Nat.ble (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s14.ffi).mlx.nnext) = true
-- the checks over the changed lists
kernel_rfl PRE_first_tail_x15_r0_body.fh0 : PRE_first_tail_x15_r0_body.clo0.all (handleOK PRE_first_tail_x15_r0_body.kappa0 PRE_first_tail_x15_r0_body.P0.lo PRE_first_tail_x15_r0_body.cx0_0.mlx PRE_first_tail_x15_r0_body.cx1_0.mlx) = true
kernel_rfl PRE_first_tail_x15_r0_body.fo0 : PRE_first_tail_x15_r0_body.clo0.map (fun h => PRE_first_tail_x15_r0_body.cx1_0.mlx.objs.get (PRE_first_tail_x15_r0_body.kappa0.handle h)) = PRE_first_tail_x15_r0_body.clo0.map (fun h => (PRE_first_tail_x15_r0_body.cx0_0.mlx.objs.get h).map PRE_first_tail_x15_r0_body.kappa0.nobj)
kernel_rfl PRE_first_tail_x15_r0_body.fok0 : PRE_first_tail_x15_r0_body.clo0.all (objOK PRE_first_tail_x15_r0_body.kappa0 PRE_first_tail_x15_r0_body.P0.NL PRE_first_tail_x15_r0_body.cx0_0.mlx) = true
kernel_rfl PRE_first_tail_x15_r0_body.fnd0 : PRE_first_tail_x15_r0_body.cln0.all (nodeOKF PRE_first_tail_x15_r0_body.kappa0 PRE_first_tail_x15_r0_body.P0 PRE_first_tail_x15_r0_body.cx0_0.mlx PRE_first_tail_x15_r0_body.cx1_0.mlx) = true
kernel_rfl PRE_first_tail_x15_r0_body.fp0 : ((PRE_first_tail_x15_r0_body.cln0.filter (fullB PRE_first_tail_x15_r0_body.P0))).map (fun i => (PRE_first_tail_x15_r0_body.cx1_0.mlx.nodes.get (PRE_first_tail_x15_r0_body.kappa0.node i)).map Host.Mlx.Ffi.Node.prim) =
  ((PRE_first_tail_x15_r0_body.cln0.filter (fullB PRE_first_tail_x15_r0_body.P0))).map (fun i => (PRE_first_tail_x15_r0_body.cx0_0.mlx.nodes.get i).map fun nd => PRE_first_tail_x15_r0_body.kappa0.prim nd.prim)
kernel_rfl PRE_first_tail_x15_r0_body.fnordI0 : incrB PRE_first_tail_x15_r0_body.kd0.nodeF (List.range' 15254 42) = true
kernel_rfl PRE_first_tail_x15_r0_body.fnordK0 : (PTrie.keysA PRE_first_tail_x15_r0_body.kd0.node).all (fun k => Nat.ble 15254 k && Nat.blt k 15296) = true
kernel_rfl PRE_first_tail_x15_r0_body.fnordL0 : (PRE_first_tail_x15_r0_body.cln0.filter (Nat.ble PRE_first_tail_x15_r0_body.P0.N0)).all (fun i => Nat.ble i (PRE_first_tail_x15_r0_body.kd0.nodeF i) && (Nat.blt i 15296 || Nat.ble PRE_first_tail_x15_r0_body.kd0.nn0 i)) = true
theorem PRE_first_tail_x15_r0_body.fnord0 : (PRE_first_tail_x15_r0_body.cln0.filter (Nat.ble PRE_first_tail_x15_r0_body.P0.N0)).all (fun i => Nat.ble i (PRE_first_tail_x15_r0_body.kd0.nodeF i) &&
    (PTrie.keysA PRE_first_tail_x15_r0_body.kd0.node).all fun j => !Nat.blt j i || Nat.blt (PRE_first_tail_x15_r0_body.kd0.nodeF j) (PRE_first_tail_x15_r0_body.kd0.nodeF i)) = true :=
  cnord_of PRE_first_tail_x15_r0_body.cnlow0 PRE_first_tail_x15_r0_body.cnn10 PRE_first_tail_x15_r0_body.fnordI0 PRE_first_tail_x15_r0_body.fnordK0 PRE_first_tail_x15_r0_body.fnordL0
kernel_rfl PRE_first_tail_x15_r0_body.fi0 : PRE_first_tail_x15_r0_body.cli0.all (pnB PRE_first_tail_x15_r0_body.cx0_0.mlx) = true
kernel_rfl PRE_first_tail_x15_r0_body.fii0 : PRE_first_tail_x15_r0_body.cli0.all (fun k => decide (PRE_first_tail_x15_r0_body.cx1_0.mlx.items.get (PRE_first_tail_x15_r0_body.kappa0.node k) = (PRE_first_tail_x15_r0_body.cx0_0.mlx.items.get k).map PRE_first_tail_x15_r0_body.kappa0.nv)) = true
/-- **The compaction's footprint.** -/
theorem PRE_first_tail_x15_r0_body.cfoot0 (clean : Conv.NClean (⟨18189, 15254, 2674897, 83⟩ : Conv.Cnt) (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s14.ffi).mlx) (hltC : ∀ h, PH (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s14.ffi).mlx h → h < (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s14.ffi).mlx.next) (nltC : ∀ i, PN (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s14.ffi).mlx i → i < (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s14.ffi).mlx.nnext) (itemsC : ∀ k v, (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s14.ffi).mlx.items.get k = some v → PN (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s14.ffi).mlx k) (tracedC : ∀ h o, (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s14.ffi).mlx.objs.get h = some o → ∀ i ∈ objTraces o, i < PRE_first_tail_x15_r0_body.P0.NL) (cl : SSt (· < 101) PRE_first_tail_x15_r0_body.cx0_0.mlx) :
    Conv.MFoot PRE_first_tail_x15_r0_body.P0 101 PRE_first_tail_x15_r0_body.kappa0 PRE_first_tail_x15_r0_body.kd0 PRE_first_tail_x15_r0_body.khinv0 PRE_first_tail_x15_r0_body.kninv0 (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s14.ffi).mlx PRE_first_tail_x15_r0_body.cx0_0.mlx PRE_first_tail_x15_r0_body.cx1_0.mlx (⟨18189, 15254, 2674897, 83⟩ : Conv.Cnt) PRE_first_tail_x15_r0_body.clo0 PRE_first_tail_x15_r0_body.cln0 PRE_first_tail_x15_r0_body.cli0 PRE_first_tail_x15_r0_body.cwS0 PRE_first_tail_x15_r0_body.cnS0 PRE_first_tail_x15_r0_body.ciS0 :=
  ⟨rfl, rfl, rfl, PRE_first_tail_x15_r0_body.cnh00, PRE_first_tail_x15_r0_body.cnh10, PRE_first_tail_x15_r0_body.cnn00, PRE_first_tail_x15_r0_body.cnn10, PRE_first_tail_x15_r0_body.cplo0, PRE_first_tail_x15_r0_body.ccnt0, PRE_first_tail_x15_r0_body.cnband0, PRE_first_tail_x15_r0_body.chbelow0, PRE_first_tail_x15_r0_body.chren0, PRE_first_tail_x15_r0_body.cband0, PRE_first_tail_x15_r0_body.cnh1pos0, PRE_first_tail_x15_r0_body.cnren0, PRE_first_tail_x15_r0_body.cnlow0, PRE_first_tail_x15_r0_body.cabs0a0, PRE_first_tail_x15_r0_body.cabs0b0, PRE_first_tail_x15_r0_body.ctok10, PRE_first_tail_x15_r0_body.cpend0, PRE_first_tail_x15_r0_body.cerrh0, PRE_first_tail_x15_r0_body.cfiles0, PRE_first_tail_x15_r0_body.carch0, PRE_first_tail_x15_r0_body.csizes0, PRE_first_tail_x15_r0_body.cwired0, PRE_first_tail_x15_r0_body.cfix0, clean, PRE_first_tail_x15_r0_body.fcxn0, PRE_first_tail_x15_r0_body.fcnn0, hltC, nltC, itemsC, tracedC, cl, PRE_first_tail_x15_r0_body.fle00, PRE_first_tail_x15_r0_body.fnk0, PRE_first_tail_x15_r0_body.ckA0, PRE_first_tail_x15_r0_body.cobjsK0, PRE_first_tail_x15_r0_body.cnodesK0, PRE_first_tail_x15_r0_body.citemsK0, PRE_first_tail_x15_r0_body.f1A0, PRE_first_tail_x15_r0_body.f1O0, PRE_first_tail_x15_r0_body.f1N0, PRE_first_tail_x15_r0_body.f1I0, PRE_first_tail_x15_r0_body.fbd0, PRE_first_tail_x15_r0_body.fincW0, PRE_first_tail_x15_r0_body.fincI0, PRE_first_tail_x15_r0_body.fincN0, PRE_first_tail_x15_r0_body.flnF0, PRE_first_tail_x15_r0_body.fh0, PRE_first_tail_x15_r0_body.fo0, PRE_first_tail_x15_r0_body.fok0, PRE_first_tail_x15_r0_body.fnd0, PRE_first_tail_x15_r0_body.fp0, PRE_first_tail_x15_r0_body.fnord0, PRE_first_tail_x15_r0_body.fi0, PRE_first_tail_x15_r0_body.fii0⟩
theorem PRE_first_tail_x15_r0_body.cnshift0 (clean : Conv.NClean (⟨18189, 15254, 2674897, 83⟩ : Conv.Cnt) (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s14.ffi).mlx) (hltC : ∀ h, PH (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s14.ffi).mlx h → h < (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s14.ffi).mlx.next) (nltC : ∀ i, PN (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s14.ffi).mlx i → i < (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s14.ffi).mlx.nnext) (itemsC : ∀ k v, (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s14.ffi).mlx.items.get k = some v → PN (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s14.ffi).mlx k) (tracedC : ∀ h o, (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s14.ffi).mlx.objs.get h = some o → ∀ i ∈ objTraces o, i < PRE_first_tail_x15_r0_body.P0.NL) (cl : SSt (· < 101) PRE_first_tail_x15_r0_body.cx0_0.mlx) : NShift PRE_first_tail_x15_r0_body.P0 101 PRE_first_tail_x15_r0_body.kappa0 PRE_first_tail_x15_r0_body.cx0_0 PRE_first_tail_x15_r0_body.cx1_0 :=
  Conv.nshift_of_foot (PRE_first_tail_x15_r0_body.cfoot0 clean hltC nltC itemsC tracedC cl) PRE_first_tail_x15_r0_body.chost0 (compact_a_eq PRE_first_tail_x15_r0_body.ckn00 PRE_first_tail_x15_r0_body.ckn10 PRE_first_tail_x15_r0_body.ckheap0 PRE_first_tail_x15_r0_body.ckpl0)

-- the observers: the layers' states at the call, the canonical and the merged state, their footprints and checks
noncomputable def PRE_first_tail_x15_r0_body.fxC_0 : PTrie Unit := (Host.Ts.Sim.Full.freedOf PRE_first_tail_x15_r0_body.s14.ffi).getD PTrie.nil
noncomputable def PRE_first_tail_x15_r0_body.krC_0 : Host.Load.Layers.KRec := (Host.Ts.Sim.Full.krecOf PRE_first_tail_x15_r0_body.s14.ffi).getD Host.Load.Layers.KRec.empty
kernel_rfl PRE_first_tail_x15_r0_body.ofxC_0 : (Host.Ts.Sim.Full.freedOf PRE_first_tail_x15_r0_body.s14.ffi) = some PRE_first_tail_x15_r0_body.fxC_0
kernel_rfl PRE_first_tail_x15_r0_body.okrC_0 : (Host.Ts.Sim.Full.krecOf PRE_first_tail_x15_r0_body.s14.ffi) = some PRE_first_tail_x15_r0_body.krC_0
noncomputable def PRE_first_tail_x15_r0_body.fx0_0 : PTrie Unit := (Host.Ts.Sim.Full.freedOf PRE_first_tail_x15_r0_body.s16.ffi).getD PTrie.nil
noncomputable def PRE_first_tail_x15_r0_body.kr0_0 : Host.Load.Layers.KRec := (Host.Ts.Sim.Full.krecOf PRE_first_tail_x15_r0_body.s16.ffi).getD Host.Load.Layers.KRec.empty
kernel_rfl PRE_first_tail_x15_r0_body.ofx0_0 : (Host.Ts.Sim.Full.freedOf PRE_first_tail_x15_r0_body.s16.ffi) = some PRE_first_tail_x15_r0_body.fx0_0
kernel_rfl PRE_first_tail_x15_r0_body.okr0_0 : (Host.Ts.Sim.Full.krecOf PRE_first_tail_x15_r0_body.s16.ffi) = some PRE_first_tail_x15_r0_body.kr0_0
noncomputable def PRE_first_tail_x15_r0_body.fx1_0 : PTrie Unit := (Host.Ts.Sim.Full.freedOf PRE_first_tail_x15_r0_body.s15.ffi).getD PTrie.nil
noncomputable def PRE_first_tail_x15_r0_body.kr1_0 : Host.Load.Layers.KRec := (Host.Ts.Sim.Full.krecOf PRE_first_tail_x15_r0_body.s15.ffi).getD Host.Load.Layers.KRec.empty
kernel_rfl PRE_first_tail_x15_r0_body.ofx1_0 : (Host.Ts.Sim.Full.freedOf PRE_first_tail_x15_r0_body.s15.ffi) = some PRE_first_tail_x15_r0_body.fx1_0
kernel_rfl PRE_first_tail_x15_r0_body.okr1_0 : (Host.Ts.Sim.Full.krecOf PRE_first_tail_x15_r0_body.s15.ffi) = some PRE_first_tail_x15_r0_body.kr1_0
kernel_rfl PRE_first_tail_x15_r0_body.ff00 : PRE_first_tail_x15_r0_body.fx0_0 = Stage.setAll PRE_first_tail_x15_r0_body.fxC_0 (PRE_first_tail_x15_r0_body.clo0.filterMap fun i => (PRE_first_tail_x15_r0_body.fx0_0.get i).map (i, ·))
kernel_rfl PRE_first_tail_x15_r0_body.ff10 : PRE_first_tail_x15_r0_body.fx1_0 = Stage.setAll PRE_first_tail_x15_r0_body.fxC_0 (PRE_first_tail_x15_r0_body.cwS0.filterMap fun i => (PRE_first_tail_x15_r0_body.fx1_0.get i).map (i, ·))
kernel_rfl PRE_first_tail_x15_r0_body.ffck0 : freedLB PRE_first_tail_x15_r0_body.kappa0 PRE_first_tail_x15_r0_body.cx0_0.mlx PRE_first_tail_x15_r0_body.fx0_0 PRE_first_tail_x15_r0_body.fx1_0 PRE_first_tail_x15_r0_body.clo0 = true
kernel_rfl PRE_first_tail_x15_r0_body.fkf00 : PRE_first_tail_x15_r0_body.kr0_0.flags = Stage.setAll PRE_first_tail_x15_r0_body.krC_0.flags (PRE_first_tail_x15_r0_body.clo0.filterMap fun i => (PRE_first_tail_x15_r0_body.kr0_0.flags.get i).map (i, ·))
kernel_rfl PRE_first_tail_x15_r0_body.fkt00 : PRE_first_tail_x15_r0_body.kr0_0.targs = Stage.setAll PRE_first_tail_x15_r0_body.krC_0.targs (PRE_first_tail_x15_r0_body.clo0.filterMap fun i => (PRE_first_tail_x15_r0_body.kr0_0.targs.get i).map (i, ·))
kernel_rfl PRE_first_tail_x15_r0_body.fkf10 : PRE_first_tail_x15_r0_body.kr1_0.flags = Stage.setAll PRE_first_tail_x15_r0_body.krC_0.flags (PRE_first_tail_x15_r0_body.cwS0.filterMap fun i => (PRE_first_tail_x15_r0_body.kr1_0.flags.get i).map (i, ·))
kernel_rfl PRE_first_tail_x15_r0_body.fkt10 : PRE_first_tail_x15_r0_body.kr1_0.targs = Stage.setAll PRE_first_tail_x15_r0_body.krC_0.targs (PRE_first_tail_x15_r0_body.cwS0.filterMap fun i => (PRE_first_tail_x15_r0_body.kr1_0.targs.get i).map (i, ·))
kernel_rfl PRE_first_tail_x15_r0_body.fkck0 : krecLB PRE_first_tail_x15_r0_body.kappa0 101 PRE_first_tail_x15_r0_body.cx0_0.mlx PRE_first_tail_x15_r0_body.kr0_0 PRE_first_tail_x15_r0_body.kr1_0 PRE_first_tail_x15_r0_body.clo0 = true
kernel_rfl PRE_first_tail_x15_r0_body.fkn0 : Nat.ble 83 101 = true
-- the bridge and the pending traces' regions
kernel_rfl PRE_first_tail_x15_r0_body.cbridge0 : Host.Ts.Sim.Full.bridgeOf PRE_first_tail_x15_r0_body.s15.ffi = Host.Ts.Sim.Full.bridgeOf PRE_first_tail_x15_r0_body.s16.ffi
kernel_rfl PRE_first_tail_x15_r0_body.cpendR0 : pendRegB PRE_first_tail_x15_r0_body.kappa0 (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s16.ffi).mlx = true
kernel_rfl PRE_first_tail_x15_r0_body.cpendLe0 : Nat.ble (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s16.ffi).mlx.next (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s15.ffi).mlx.next = true
/-- **The compaction's native shift**, given the call's bookkeeping, its relation's facts (the model's and the
observers') and the canonical closedness. -/
theorem PRE_first_tail_x15_r0_body.cshift0 (clean : Conv.NClean (⟨18189, 15254, 2674897, 83⟩ : Conv.Cnt) (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s14.ffi).mlx) (hltC : ∀ h, PH (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s14.ffi).mlx h → h < (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s14.ffi).mlx.next) (nltC : ∀ i, PN (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s14.ffi).mlx i → i < (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s14.ffi).mlx.nnext) (itemsC : ∀ k v, (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s14.ffi).mlx.items.get k = some v → PN (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s14.ffi).mlx k) (tracedC : ∀ h o, (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s14.ffi).mlx.objs.get h = some o → ∀ i ∈ objTraces o, i < PRE_first_tail_x15_r0_body.P0.NL) (cl : SSt (· < 101) PRE_first_tail_x15_r0_body.cx0_0.mlx)
    (hobjC : ∀ h, PRE_first_tail_x15_r0_body.fxC_0.get h = some () → ((Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s14.ffi).mlx.objs.get h).isSome = true)
    (hfC : ∀ h, (PRE_first_tail_x15_r0_body.krC_0.flags.get h).isSome = true → ((Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s14.ffi).mlx.objs.get h).isSome = true)
    (htC : ∀ h, (PRE_first_tail_x15_r0_body.krC_0.targs.get h).isSome = true → ((Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s14.ffi).mlx.objs.get h).isSome = true)
    (hclC : ∀ h l, PRE_first_tail_x15_r0_body.krC_0.targs.get h = some l → Host.Ts.Sim.Full.STargs (· < (⟨18189, 15254, 2674897, 83⟩ : Conv.Cnt).n) l) :
    Conv.FullShiftQ PRE_first_tail_x15_r0_body.P0 101 PRE_first_tail_x15_r0_body.kappa0 PRE_first_tail_x15_r0_body.s16.ffi PRE_first_tail_x15_r0_body.s15.ffi :=
  ⟨PRE_first_tail_x15_r0_body.cnshift0 clean hltC nltC itemsC tracedC cl, PRE_first_tail_x15_r0_body.cqueue0, fun t ht => bSN_sound (List.all_eq_true.mp PRE_first_tail_x15_r0_body.ctokSupp0 t ht),
    PRE_first_tail_x15_r0_body.cbridge0,
    liveShift_foot (x0' := Host.Ts.Sim.Full.mlxOf PRE_first_tail_x15_r0_body.s16.ffi) (x1' := Host.Ts.Sim.Full.mlxOf PRE_first_tail_x15_r0_body.s15.ffi) (PRE_first_tail_x15_r0_body.cfoot0 clean hltC nltC itemsC tracedC cl) rfl PRE_first_tail_x15_r0_body.ofx0_0 PRE_first_tail_x15_r0_body.ofx1_0 hobjC PRE_first_tail_x15_r0_body.ff00 PRE_first_tail_x15_r0_body.ff10 PRE_first_tail_x15_r0_body.ffck0,
    kernShift_foot (x0' := Host.Ts.Sim.Full.mlxOf PRE_first_tail_x15_r0_body.s16.ffi) (x1' := Host.Ts.Sim.Full.mlxOf PRE_first_tail_x15_r0_body.s15.ffi) (PRE_first_tail_x15_r0_body.cfoot0 clean hltC nltC itemsC tracedC cl) rfl PRE_first_tail_x15_r0_body.okr0_0 PRE_first_tail_x15_r0_body.okr1_0 (Nat.le_of_ble_eq_true PRE_first_tail_x15_r0_body.fkn0) hfC htC hclC
      PRE_first_tail_x15_r0_body.fkf00 PRE_first_tail_x15_r0_body.fkt00 PRE_first_tail_x15_r0_body.fkf10 PRE_first_tail_x15_r0_body.fkt10 PRE_first_tail_x15_r0_body.fkck0,
    pendReg_of rfl PRE_first_tail_x15_r0_body.cnh00 PRE_first_tail_x15_r0_body.cnh10 (Nat.le_of_ble_eq_true PRE_first_tail_x15_r0_body.cpendLe0) PRE_first_tail_x15_r0_body.cpendR0⟩

end Host.Load.Run.Tpl
