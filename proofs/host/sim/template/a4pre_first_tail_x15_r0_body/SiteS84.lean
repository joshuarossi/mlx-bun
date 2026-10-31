import host.sim.template.a4pre_first_tail_x15_r0_body.SiteCl84
import host.sim.conv.CompactFull
import host.sim.template.FootGen
set_option Elab.async false
namespace Host.Load.Run.Tpl
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
open Host.Ts Host.Ts.Sim Host.Ts.Sim.Template

/-! The compaction's native shift at call site 84 from its footprint (`Conv.nshift_of_foot`), and the observers'
(`liveShift_foot`, `kernShift_foot`): `Conv.FullShiftQ` for `Conv.full_compactQ`, given the call's bookkeeping and its
relation's facts. -/

/-- The load parameters of the chain (band-free: its start's node counter as `NL` and `N0`). -/
def PRE_first_tail_x15_r0_body.Pc84 : LoadP := ⟨18151, 131072, 1099511627776, 15235, 15235, []⟩
/-- The site's band raised to the map's checked fixed-node prefix, including newly recorded closure traces. -/
def PRE_first_tail_x15_r0_body.P84 : LoadP := PRE_first_tail_x15_r0_body.Pc84.raise 16964
kernel_rfl PRE_first_tail_x15_r0_body.craise84 : Nat.ble PRE_first_tail_x15_r0_body.Pc84.N0 16964 = true
theorem PRE_first_tail_x15_r0_body.raised84 : Host.Ts.Sim.Full.Raised PRE_first_tail_x15_r0_body.Pc84 PRE_first_tail_x15_r0_body.P84 :=
  .inr ⟨16964, rfl, Nat.le_of_ble_eq_true PRE_first_tail_x15_r0_body.craise84, rfl⟩
noncomputable abbrev PRE_first_tail_x15_r0_body.cx0_84 : Host.Load.LSt := clearTokens (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s823.ffi)
noncomputable abbrev PRE_first_tail_x15_r0_body.cx1_84 : Host.Load.LSt := clearTokens (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s822.ffi)
def PRE_first_tail_x15_r0_body.khinv84 : PTrie Nat := Stage.setAll PTrie.nil [(19894, 19868), (19872, 19869), (19895, 19870)]
def PRE_first_tail_x15_r0_body.kninv84 : PTrie Nat := Stage.setAll PTrie.nil [(16937, 16937), (16938, 16938), (16939, 16939), (16940, 16940), (16941, 16941), (16942, 16942), (16943, 16943), (16944, 16944), (16945, 16945), (16946, 16946), (16947, 16947), (16948, 16948), (16949, 16949), (16950, 16950), (16951, 16951), (16952, 16952), (16953, 16953), (16954, 16954), (16955, 16955), (16956, 16956), (16957, 16957), (16958, 16958), (16959, 16959), (16960, 16960), (16961, 16961), (16962, 16962), (16963, 16963)]
/-- The stage's footprint: its written and fresh handles, fresh nodes, written and fresh items. -/
def PRE_first_tail_x15_r0_body.cwS84 : List Nat := [19848, 19861, 19867, 19868, 19869, 19870, 19871, 19872, 19873, 19874, 19875, 19876, 19877, 19878, 19879, 19880, 19881, 19882, 19883, 19884, 19885, 19886, 19887, 19888, 19889, 19890, 19891, 19892, 19893, 19894, 19895]
def PRE_first_tail_x15_r0_body.cnS84 : List Nat := List.range' 16937 27
def PRE_first_tail_x15_r0_body.ciS84 : List Nat := [] ++ List.range' 16937 27

-- the small checks (`MChecks`'s)
kernel_rfl PRE_first_tail_x15_r0_body.cnh084 : PRE_first_tail_x15_r0_body.kd84.nh0 = PRE_first_tail_x15_r0_body.cx0_84.mlx.next
kernel_rfl PRE_first_tail_x15_r0_body.cnh184 : PRE_first_tail_x15_r0_body.kd84.nh1 = PRE_first_tail_x15_r0_body.cx1_84.mlx.next
kernel_rfl PRE_first_tail_x15_r0_body.cnn084 : PRE_first_tail_x15_r0_body.kd84.nn0 = PRE_first_tail_x15_r0_body.cx0_84.mlx.nnext
kernel_rfl PRE_first_tail_x15_r0_body.cnn184 : PRE_first_tail_x15_r0_body.kd84.nn1 = PRE_first_tail_x15_r0_body.cx1_84.mlx.nnext
kernel_rfl PRE_first_tail_x15_r0_body.cplo84 : (Nat.blt 0 PRE_first_tail_x15_r0_body.P84.lo && Nat.ble PRE_first_tail_x15_r0_body.P84.lo PRE_first_tail_x15_r0_body.cx0_84.mlx.next && Nat.ble PRE_first_tail_x15_r0_body.P84.lo RData.bigHi && Nat.ble RData.bigHi PRE_first_tail_x15_r0_body.P84.E) = true
kernel_rfl PRE_first_tail_x15_r0_body.ccnt84 : (Nat.ble PRE_first_tail_x15_r0_body.cx0_84.mlx.next PRE_first_tail_x15_r0_body.cx1_84.mlx.next && Nat.ble PRE_first_tail_x15_r0_body.cx0_84.mlx.nnext PRE_first_tail_x15_r0_body.cx1_84.mlx.nnext) = true
kernel_rfl PRE_first_tail_x15_r0_body.cnband84 : (Nat.blt 0 PRE_first_tail_x15_r0_body.P84.NL && Nat.ble PRE_first_tail_x15_r0_body.P84.NL PRE_first_tail_x15_r0_body.P84.N0 && Nat.ble PRE_first_tail_x15_r0_body.P84.N0 PRE_first_tail_x15_r0_body.cx0_84.mlx.nnext) = true
kernel_rfl PRE_first_tail_x15_r0_body.chbelow84 : PRE_first_tail_x15_r0_body.kd84.checkHndBelow = true
kernel_rfl PRE_first_tail_x15_r0_body.chren84 : checkRenG PRE_first_tail_x15_r0_body.kd84.hnd PRE_first_tail_x15_r0_body.khinv84 (phB PRE_first_tail_x15_r0_body.cx0_84.mlx) = true
kernel_rfl PRE_first_tail_x15_r0_body.cband84 : PRE_first_tail_x15_r0_body.kd84.checkBand PRE_first_tail_x15_r0_body.P84.lo = true
kernel_rfl PRE_first_tail_x15_r0_body.cnh1pos84 : Nat.blt 0 PRE_first_tail_x15_r0_body.kd84.nh1 = true
kernel_rfl PRE_first_tail_x15_r0_body.cnren84 : checkRenG PRE_first_tail_x15_r0_body.kd84.node PRE_first_tail_x15_r0_body.kninv84 (pnB PRE_first_tail_x15_r0_body.cx0_84.mlx) = true
kernel_rfl PRE_first_tail_x15_r0_body.cnlow84 : (PTrie.keysA PRE_first_tail_x15_r0_body.kd84.node).all (fun j => Nat.ble PRE_first_tail_x15_r0_body.P84.NL j && Nat.blt (PRE_first_tail_x15_r0_body.kd84.nodeF j) PRE_first_tail_x15_r0_body.cx1_84.mlx.nnext) = true
kernel_rfl PRE_first_tail_x15_r0_body.cabs0a84 : PRE_first_tail_x15_r0_body.cx0_84.mlx.arrs.get 0 = none
kernel_rfl PRE_first_tail_x15_r0_body.cabs0b84 : PRE_first_tail_x15_r0_body.cx0_84.mlx.objs.get 0 = none
kernel_rfl PRE_first_tail_x15_r0_body.ctok184 : PRE_first_tail_x15_r0_body.cx1_84.mlx.tokens = []
kernel_rfl PRE_first_tail_x15_r0_body.cpend84 : PRE_first_tail_x15_r0_body.cx1_84.mlx.pending = PRE_first_tail_x15_r0_body.cx0_84.mlx.pending.map PRE_first_tail_x15_r0_body.kappa84.pend
kernel_rfl PRE_first_tail_x15_r0_body.cerrh84 : PRE_first_tail_x15_r0_body.cx1_84.mlx.errh = PRE_first_tail_x15_r0_body.cx0_84.mlx.errh.map PRE_first_tail_x15_r0_body.kappa84.arg
kernel_rfl PRE_first_tail_x15_r0_body.cfiles84 : PRE_first_tail_x15_r0_body.cx1_84.mlx.files = PRE_first_tail_x15_r0_body.cx0_84.mlx.files
kernel_rfl PRE_first_tail_x15_r0_body.carch84 : PRE_first_tail_x15_r0_body.cx1_84.mlx.arch = PRE_first_tail_x15_r0_body.cx0_84.mlx.arch
kernel_rfl PRE_first_tail_x15_r0_body.csizes84 : PRE_first_tail_x15_r0_body.cx1_84.mlx.deviceSizes = PRE_first_tail_x15_r0_body.cx0_84.mlx.deviceSizes
kernel_rfl PRE_first_tail_x15_r0_body.cwired84 : PRE_first_tail_x15_r0_body.cx1_84.mlx.wired = PRE_first_tail_x15_r0_body.cx0_84.mlx.wired
kernel_rfl PRE_first_tail_x15_r0_body.chost84 : PRE_first_tail_x15_r0_body.cx1_84.host = PRE_first_tail_x15_r0_body.cx0_84.host
-- the compaction map's addresses are `PRE_first_tail_x15_r0_body.kd84`'s
kernel_rfl PRE_first_tail_x15_r0_body.ckn084 : PRE_first_tail_x15_r0_body.kd84.n0 = 2741377
kernel_rfl PRE_first_tail_x15_r0_body.ckn184 : PRE_first_tail_x15_r0_body.kd84.n1 = 2742526
kernel_rfl PRE_first_tail_x15_r0_body.ckheap84 : (PTrie.keysA PRE_first_tail_x15_r0_body.kd84.heap).all (fun x => Nat.ble 2741371 x) = true
kernel_rfl PRE_first_tail_x15_r0_body.ckpl84 : (List.range 6).all (fun j => decide (PRE_first_tail_x15_r0_body.kd84.heap.get (2741371 + j) = nth? PRE_first_tail_x15_r0_body.pl84 j)) = true
-- the map fixes the call's names (`Conv.fixOld_compact`), the call's counters
kernel_rfl PRE_first_tail_x15_r0_body.fja84 : Nat.ble 2741371 2741371 = true
kernel_rfl PRE_first_tail_x15_r0_body.fn84 : Nat.ble 3674 3674 = true
kernel_rfl PRE_first_tail_x15_r0_body.fjaD84 : Nat.ble 2741371 PRE_first_tail_x15_r0_body.kd84.n0 = true
kernel_rfl PRE_first_tail_x15_r0_body.fxn84 : Nat.ble 19868 PRE_first_tail_x15_r0_body.kd84.nh0 = true
kernel_rfl PRE_first_tail_x15_r0_body.fnn84 : Nat.ble 16937 PRE_first_tail_x15_r0_body.kd84.nn0 = true
kernel_rfl PRE_first_tail_x15_r0_body.fxb84 : Nat.ble 19868 RData.bigHi = true
kernel_rfl PRE_first_tail_x15_r0_body.fheap84 : (PTrie.keysA PRE_first_tail_x15_r0_body.kd84.heap).all (Nat.ble (⟨19868, 16937, 2741371, 3674⟩ : Conv.Cnt).ja) = true
kernel_rfl PRE_first_tail_x15_r0_body.fhnd84 : (PTrie.keysA PRE_first_tail_x15_r0_body.kd84.hnd).all (Nat.ble (⟨19868, 16937, 2741371, 3674⟩ : Conv.Cnt).xn) = true
kernel_rfl PRE_first_tail_x15_r0_body.fnode84 : (PTrie.keysA PRE_first_tail_x15_r0_body.kd84.node).all (Nat.ble (⟨19868, 16937, 2741371, 3674⟩ : Conv.Cnt).nn) = true
/-- The compaction map fixes the call's names. -/
theorem PRE_first_tail_x15_r0_body.cfix84 : Conv.FixOld (⟨19868, 16937, 2741371, 3674⟩ : Conv.Cnt) PRE_first_tail_x15_r0_body.kappa84 :=
  Conv.fixOld_compact (Nat.le_of_ble_eq_true PRE_first_tail_x15_r0_body.fja84) (Nat.le_of_ble_eq_true PRE_first_tail_x15_r0_body.fn84) (Nat.le_of_ble_eq_true PRE_first_tail_x15_r0_body.fjaD84) (Nat.le_of_ble_eq_true PRE_first_tail_x15_r0_body.fxn84) (Nat.le_of_ble_eq_true PRE_first_tail_x15_r0_body.fnn84) (Nat.le_of_ble_eq_true PRE_first_tail_x15_r0_body.fxb84) PRE_first_tail_x15_r0_body.fheap84 PRE_first_tail_x15_r0_body.fhnd84 PRE_first_tail_x15_r0_body.fnode84
kernel_rfl PRE_first_tail_x15_r0_body.fcxn84 : (⟨19868, 16937, 2741371, 3674⟩ : Conv.Cnt).xn = (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s821.ffi).mlx.next
kernel_rfl PRE_first_tail_x15_r0_body.fcnn84 : (⟨19868, 16937, 2741371, 3674⟩ : Conv.Cnt).nn = (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s821.ffi).mlx.nnext
kernel_rfl PRE_first_tail_x15_r0_body.fle084 : (Nat.ble (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s821.ffi).mlx.next PRE_first_tail_x15_r0_body.cx0_84.mlx.next && Nat.ble (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s821.ffi).mlx.nnext PRE_first_tail_x15_r0_body.cx0_84.mlx.nnext && Nat.ble (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s821.ffi).mlx.next RData.bigHi) = true
kernel_rfl PRE_first_tail_x15_r0_body.fnk84 : (PTrie.keysA PRE_first_tail_x15_r0_body.kd84.node).all (Nat.ble (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s821.ffi).mlx.nnext) = true
-- the merged state keeps the call's entries off the stage's footprint
kernel_rfl PRE_first_tail_x15_r0_body.f1A84 : PRE_first_tail_x15_r0_body.cx1_84.mlx.arrs = Stage.setAll (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s821.ffi).mlx.arrs (PRE_first_tail_x15_r0_body.cwS84.filterMap fun i => (PRE_first_tail_x15_r0_body.cx1_84.mlx.arrs.get i).map (i, ·))
kernel_rfl PRE_first_tail_x15_r0_body.f1O84 : PRE_first_tail_x15_r0_body.cx1_84.mlx.objs = Stage.setAll (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s821.ffi).mlx.objs (PRE_first_tail_x15_r0_body.cwS84.filterMap fun i => (PRE_first_tail_x15_r0_body.cx1_84.mlx.objs.get i).map (i, ·))
kernel_rfl PRE_first_tail_x15_r0_body.f1N84 : PRE_first_tail_x15_r0_body.cx1_84.mlx.nodes = Stage.setAll (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s821.ffi).mlx.nodes (PRE_first_tail_x15_r0_body.cnS84.filterMap fun i => (PRE_first_tail_x15_r0_body.cx1_84.mlx.nodes.get i).map (i, ·))
kernel_rfl PRE_first_tail_x15_r0_body.f1I84 : PRE_first_tail_x15_r0_body.cx1_84.mlx.items = Stage.setAll (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s821.ffi).mlx.items (PRE_first_tail_x15_r0_body.ciS84.filterMap fun i => (PRE_first_tail_x15_r0_body.cx1_84.mlx.items.get i).map (i, ·))
kernel_rfl PRE_first_tail_x15_r0_body.fbd84 : (PRE_first_tail_x15_r0_body.clo84 ++ PRE_first_tail_x15_r0_body.cln84 ++ PRE_first_tail_x15_r0_body.cli84 ++ PRE_first_tail_x15_r0_body.cwS84 ++ PRE_first_tail_x15_r0_body.cnS84 ++ PRE_first_tail_x15_r0_body.ciS84).all (fun i => Nat.blt (i / 4096) (4 ^ 31)) = true
kernel_rfl PRE_first_tail_x15_r0_body.fincW84 : PRE_first_tail_x15_r0_body.cwS84.all (fun h => !Nat.blt h (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s821.ffi).mlx.next || PRE_first_tail_x15_r0_body.clo84.contains h) = true
kernel_rfl PRE_first_tail_x15_r0_body.fincI84 : PRE_first_tail_x15_r0_body.ciS84.all (fun k => !Nat.blt k (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s821.ffi).mlx.nnext || PRE_first_tail_x15_r0_body.cli84.contains k) = true
kernel_rfl PRE_first_tail_x15_r0_body.fincN84 : PRE_first_tail_x15_r0_body.cnS84.all (Nat.ble (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s821.ffi).mlx.nnext) = true
kernel_rfl PRE_first_tail_x15_r0_body.flnF84 : PRE_first_tail_x15_r0_body.cln84.all (Nat.ble (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s821.ffi).mlx.nnext) = true
-- the checks over the changed lists
kernel_rfl PRE_first_tail_x15_r0_body.fh84 : PRE_first_tail_x15_r0_body.clo84.all (handleOK PRE_first_tail_x15_r0_body.kappa84 PRE_first_tail_x15_r0_body.P84.lo PRE_first_tail_x15_r0_body.cx0_84.mlx PRE_first_tail_x15_r0_body.cx1_84.mlx) = true
kernel_rfl PRE_first_tail_x15_r0_body.fo84 : PRE_first_tail_x15_r0_body.clo84.map (fun h => PRE_first_tail_x15_r0_body.cx1_84.mlx.objs.get (PRE_first_tail_x15_r0_body.kappa84.handle h)) = PRE_first_tail_x15_r0_body.clo84.map (fun h => (PRE_first_tail_x15_r0_body.cx0_84.mlx.objs.get h).map PRE_first_tail_x15_r0_body.kappa84.nobj)
kernel_rfl PRE_first_tail_x15_r0_body.fok84 : PRE_first_tail_x15_r0_body.clo84.all (objOK PRE_first_tail_x15_r0_body.kappa84 PRE_first_tail_x15_r0_body.P84.NL PRE_first_tail_x15_r0_body.cx0_84.mlx) = true
kernel_rfl PRE_first_tail_x15_r0_body.fnd84 : PRE_first_tail_x15_r0_body.cln84.all (nodeOKF PRE_first_tail_x15_r0_body.kappa84 PRE_first_tail_x15_r0_body.P84 PRE_first_tail_x15_r0_body.cx0_84.mlx PRE_first_tail_x15_r0_body.cx1_84.mlx) = true
kernel_rfl PRE_first_tail_x15_r0_body.fp84 : ((PRE_first_tail_x15_r0_body.cln84.filter (fullB PRE_first_tail_x15_r0_body.P84))).map (fun i => (PRE_first_tail_x15_r0_body.cx1_84.mlx.nodes.get (PRE_first_tail_x15_r0_body.kappa84.node i)).map Host.Mlx.Ffi.Node.prim) =
  ((PRE_first_tail_x15_r0_body.cln84.filter (fullB PRE_first_tail_x15_r0_body.P84))).map (fun i => (PRE_first_tail_x15_r0_body.cx0_84.mlx.nodes.get i).map fun nd => PRE_first_tail_x15_r0_body.kappa84.prim nd.prim)
kernel_rfl PRE_first_tail_x15_r0_body.fnordI84 : incrB PRE_first_tail_x15_r0_body.kd84.nodeF (List.range' 16937 27) = true
kernel_rfl PRE_first_tail_x15_r0_body.fnordK84 : (PTrie.keysA PRE_first_tail_x15_r0_body.kd84.node).all (fun k => Nat.ble 16937 k && Nat.blt k 16964) = true
kernel_rfl PRE_first_tail_x15_r0_body.fnordL84 : (PRE_first_tail_x15_r0_body.cln84.filter (Nat.ble PRE_first_tail_x15_r0_body.P84.N0)).all (fun i => Nat.ble i (PRE_first_tail_x15_r0_body.kd84.nodeF i) && (Nat.blt i 16964 || Nat.ble PRE_first_tail_x15_r0_body.kd84.nn0 i)) = true
theorem PRE_first_tail_x15_r0_body.fnord84 : (PRE_first_tail_x15_r0_body.cln84.filter (Nat.ble PRE_first_tail_x15_r0_body.P84.N0)).all (fun i => Nat.ble i (PRE_first_tail_x15_r0_body.kd84.nodeF i) &&
    (PTrie.keysA PRE_first_tail_x15_r0_body.kd84.node).all fun j => !Nat.blt j i || Nat.blt (PRE_first_tail_x15_r0_body.kd84.nodeF j) (PRE_first_tail_x15_r0_body.kd84.nodeF i)) = true :=
  cnord_of PRE_first_tail_x15_r0_body.cnlow84 PRE_first_tail_x15_r0_body.cnn184 PRE_first_tail_x15_r0_body.fnordI84 PRE_first_tail_x15_r0_body.fnordK84 PRE_first_tail_x15_r0_body.fnordL84
kernel_rfl PRE_first_tail_x15_r0_body.fi84 : PRE_first_tail_x15_r0_body.cli84.all (pnB PRE_first_tail_x15_r0_body.cx0_84.mlx) = true
kernel_rfl PRE_first_tail_x15_r0_body.fii84 : PRE_first_tail_x15_r0_body.cli84.all (fun k => decide (PRE_first_tail_x15_r0_body.cx1_84.mlx.items.get (PRE_first_tail_x15_r0_body.kappa84.node k) = (PRE_first_tail_x15_r0_body.cx0_84.mlx.items.get k).map PRE_first_tail_x15_r0_body.kappa84.nv)) = true
/-- **The compaction's footprint.** -/
theorem PRE_first_tail_x15_r0_body.cfoot84 (clean : Conv.NClean (⟨19868, 16937, 2741371, 3674⟩ : Conv.Cnt) (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s821.ffi).mlx) (hltC : ∀ h, PH (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s821.ffi).mlx h → h < (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s821.ffi).mlx.next) (nltC : ∀ i, PN (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s821.ffi).mlx i → i < (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s821.ffi).mlx.nnext) (itemsC : ∀ k v, (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s821.ffi).mlx.items.get k = some v → PN (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s821.ffi).mlx k) (tracedC : ∀ h o, (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s821.ffi).mlx.objs.get h = some o → ∀ i ∈ objTraces o, i < PRE_first_tail_x15_r0_body.P84.NL) (cl : SSt (· < 3692) PRE_first_tail_x15_r0_body.cx0_84.mlx) :
    Conv.MFoot PRE_first_tail_x15_r0_body.P84 3692 PRE_first_tail_x15_r0_body.kappa84 PRE_first_tail_x15_r0_body.kd84 PRE_first_tail_x15_r0_body.khinv84 PRE_first_tail_x15_r0_body.kninv84 (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s821.ffi).mlx PRE_first_tail_x15_r0_body.cx0_84.mlx PRE_first_tail_x15_r0_body.cx1_84.mlx (⟨19868, 16937, 2741371, 3674⟩ : Conv.Cnt) PRE_first_tail_x15_r0_body.clo84 PRE_first_tail_x15_r0_body.cln84 PRE_first_tail_x15_r0_body.cli84 PRE_first_tail_x15_r0_body.cwS84 PRE_first_tail_x15_r0_body.cnS84 PRE_first_tail_x15_r0_body.ciS84 :=
  ⟨rfl, rfl, rfl, PRE_first_tail_x15_r0_body.cnh084, PRE_first_tail_x15_r0_body.cnh184, PRE_first_tail_x15_r0_body.cnn084, PRE_first_tail_x15_r0_body.cnn184, PRE_first_tail_x15_r0_body.cplo84, PRE_first_tail_x15_r0_body.ccnt84, PRE_first_tail_x15_r0_body.cnband84, PRE_first_tail_x15_r0_body.chbelow84, PRE_first_tail_x15_r0_body.chren84, PRE_first_tail_x15_r0_body.cband84, PRE_first_tail_x15_r0_body.cnh1pos84, PRE_first_tail_x15_r0_body.cnren84, PRE_first_tail_x15_r0_body.cnlow84, PRE_first_tail_x15_r0_body.cabs0a84, PRE_first_tail_x15_r0_body.cabs0b84, PRE_first_tail_x15_r0_body.ctok184, PRE_first_tail_x15_r0_body.cpend84, PRE_first_tail_x15_r0_body.cerrh84, PRE_first_tail_x15_r0_body.cfiles84, PRE_first_tail_x15_r0_body.carch84, PRE_first_tail_x15_r0_body.csizes84, PRE_first_tail_x15_r0_body.cwired84, PRE_first_tail_x15_r0_body.cfix84, clean, PRE_first_tail_x15_r0_body.fcxn84, PRE_first_tail_x15_r0_body.fcnn84, hltC, nltC, itemsC, tracedC, cl, PRE_first_tail_x15_r0_body.fle084, PRE_first_tail_x15_r0_body.fnk84, PRE_first_tail_x15_r0_body.ckA84, PRE_first_tail_x15_r0_body.cobjsK84, PRE_first_tail_x15_r0_body.cnodesK84, PRE_first_tail_x15_r0_body.citemsK84, PRE_first_tail_x15_r0_body.f1A84, PRE_first_tail_x15_r0_body.f1O84, PRE_first_tail_x15_r0_body.f1N84, PRE_first_tail_x15_r0_body.f1I84, PRE_first_tail_x15_r0_body.fbd84, PRE_first_tail_x15_r0_body.fincW84, PRE_first_tail_x15_r0_body.fincI84, PRE_first_tail_x15_r0_body.fincN84, PRE_first_tail_x15_r0_body.flnF84, PRE_first_tail_x15_r0_body.fh84, PRE_first_tail_x15_r0_body.fo84, PRE_first_tail_x15_r0_body.fok84, PRE_first_tail_x15_r0_body.fnd84, PRE_first_tail_x15_r0_body.fp84, PRE_first_tail_x15_r0_body.fnord84, PRE_first_tail_x15_r0_body.fi84, PRE_first_tail_x15_r0_body.fii84⟩
theorem PRE_first_tail_x15_r0_body.cnshift84 (clean : Conv.NClean (⟨19868, 16937, 2741371, 3674⟩ : Conv.Cnt) (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s821.ffi).mlx) (hltC : ∀ h, PH (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s821.ffi).mlx h → h < (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s821.ffi).mlx.next) (nltC : ∀ i, PN (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s821.ffi).mlx i → i < (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s821.ffi).mlx.nnext) (itemsC : ∀ k v, (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s821.ffi).mlx.items.get k = some v → PN (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s821.ffi).mlx k) (tracedC : ∀ h o, (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s821.ffi).mlx.objs.get h = some o → ∀ i ∈ objTraces o, i < PRE_first_tail_x15_r0_body.P84.NL) (cl : SSt (· < 3692) PRE_first_tail_x15_r0_body.cx0_84.mlx) : NShift PRE_first_tail_x15_r0_body.P84 3692 PRE_first_tail_x15_r0_body.kappa84 PRE_first_tail_x15_r0_body.cx0_84 PRE_first_tail_x15_r0_body.cx1_84 :=
  Conv.nshift_of_foot (PRE_first_tail_x15_r0_body.cfoot84 clean hltC nltC itemsC tracedC cl) PRE_first_tail_x15_r0_body.chost84 (compact_a_eq PRE_first_tail_x15_r0_body.ckn084 PRE_first_tail_x15_r0_body.ckn184 PRE_first_tail_x15_r0_body.ckheap84 PRE_first_tail_x15_r0_body.ckpl84)

-- the observers: the layers' states at the call, the canonical and the merged state, their footprints and checks
noncomputable def PRE_first_tail_x15_r0_body.fxC_84 : PTrie Unit := (Host.Ts.Sim.Full.freedOf PRE_first_tail_x15_r0_body.s821.ffi).getD PTrie.nil
noncomputable def PRE_first_tail_x15_r0_body.krC_84 : Host.Load.Layers.KRec := (Host.Ts.Sim.Full.krecOf PRE_first_tail_x15_r0_body.s821.ffi).getD Host.Load.Layers.KRec.empty
kernel_rfl PRE_first_tail_x15_r0_body.ofxC_84 : (Host.Ts.Sim.Full.freedOf PRE_first_tail_x15_r0_body.s821.ffi) = some PRE_first_tail_x15_r0_body.fxC_84
kernel_rfl PRE_first_tail_x15_r0_body.okrC_84 : (Host.Ts.Sim.Full.krecOf PRE_first_tail_x15_r0_body.s821.ffi) = some PRE_first_tail_x15_r0_body.krC_84
noncomputable def PRE_first_tail_x15_r0_body.fx0_84 : PTrie Unit := (Host.Ts.Sim.Full.freedOf PRE_first_tail_x15_r0_body.s823.ffi).getD PTrie.nil
noncomputable def PRE_first_tail_x15_r0_body.kr0_84 : Host.Load.Layers.KRec := (Host.Ts.Sim.Full.krecOf PRE_first_tail_x15_r0_body.s823.ffi).getD Host.Load.Layers.KRec.empty
kernel_rfl PRE_first_tail_x15_r0_body.ofx0_84 : (Host.Ts.Sim.Full.freedOf PRE_first_tail_x15_r0_body.s823.ffi) = some PRE_first_tail_x15_r0_body.fx0_84
kernel_rfl PRE_first_tail_x15_r0_body.okr0_84 : (Host.Ts.Sim.Full.krecOf PRE_first_tail_x15_r0_body.s823.ffi) = some PRE_first_tail_x15_r0_body.kr0_84
noncomputable def PRE_first_tail_x15_r0_body.fx1_84 : PTrie Unit := (Host.Ts.Sim.Full.freedOf PRE_first_tail_x15_r0_body.s822.ffi).getD PTrie.nil
noncomputable def PRE_first_tail_x15_r0_body.kr1_84 : Host.Load.Layers.KRec := (Host.Ts.Sim.Full.krecOf PRE_first_tail_x15_r0_body.s822.ffi).getD Host.Load.Layers.KRec.empty
kernel_rfl PRE_first_tail_x15_r0_body.ofx1_84 : (Host.Ts.Sim.Full.freedOf PRE_first_tail_x15_r0_body.s822.ffi) = some PRE_first_tail_x15_r0_body.fx1_84
kernel_rfl PRE_first_tail_x15_r0_body.okr1_84 : (Host.Ts.Sim.Full.krecOf PRE_first_tail_x15_r0_body.s822.ffi) = some PRE_first_tail_x15_r0_body.kr1_84
kernel_rfl PRE_first_tail_x15_r0_body.ff084 : PRE_first_tail_x15_r0_body.fx0_84 = Stage.setAll PRE_first_tail_x15_r0_body.fxC_84 (PRE_first_tail_x15_r0_body.clo84.filterMap fun i => (PRE_first_tail_x15_r0_body.fx0_84.get i).map (i, ·))
kernel_rfl PRE_first_tail_x15_r0_body.ff184 : PRE_first_tail_x15_r0_body.fx1_84 = Stage.setAll PRE_first_tail_x15_r0_body.fxC_84 (PRE_first_tail_x15_r0_body.cwS84.filterMap fun i => (PRE_first_tail_x15_r0_body.fx1_84.get i).map (i, ·))
kernel_rfl PRE_first_tail_x15_r0_body.ffck84 : freedLB PRE_first_tail_x15_r0_body.kappa84 PRE_first_tail_x15_r0_body.cx0_84.mlx PRE_first_tail_x15_r0_body.fx0_84 PRE_first_tail_x15_r0_body.fx1_84 PRE_first_tail_x15_r0_body.clo84 = true
kernel_rfl PRE_first_tail_x15_r0_body.fkf084 : PRE_first_tail_x15_r0_body.kr0_84.flags = Stage.setAll PRE_first_tail_x15_r0_body.krC_84.flags (PRE_first_tail_x15_r0_body.clo84.filterMap fun i => (PRE_first_tail_x15_r0_body.kr0_84.flags.get i).map (i, ·))
kernel_rfl PRE_first_tail_x15_r0_body.fkt084 : PRE_first_tail_x15_r0_body.kr0_84.targs = Stage.setAll PRE_first_tail_x15_r0_body.krC_84.targs (PRE_first_tail_x15_r0_body.clo84.filterMap fun i => (PRE_first_tail_x15_r0_body.kr0_84.targs.get i).map (i, ·))
kernel_rfl PRE_first_tail_x15_r0_body.fkf184 : PRE_first_tail_x15_r0_body.kr1_84.flags = Stage.setAll PRE_first_tail_x15_r0_body.krC_84.flags (PRE_first_tail_x15_r0_body.cwS84.filterMap fun i => (PRE_first_tail_x15_r0_body.kr1_84.flags.get i).map (i, ·))
kernel_rfl PRE_first_tail_x15_r0_body.fkt184 : PRE_first_tail_x15_r0_body.kr1_84.targs = Stage.setAll PRE_first_tail_x15_r0_body.krC_84.targs (PRE_first_tail_x15_r0_body.cwS84.filterMap fun i => (PRE_first_tail_x15_r0_body.kr1_84.targs.get i).map (i, ·))
kernel_rfl PRE_first_tail_x15_r0_body.fkck84 : krecLB PRE_first_tail_x15_r0_body.kappa84 3692 PRE_first_tail_x15_r0_body.cx0_84.mlx PRE_first_tail_x15_r0_body.kr0_84 PRE_first_tail_x15_r0_body.kr1_84 PRE_first_tail_x15_r0_body.clo84 = true
kernel_rfl PRE_first_tail_x15_r0_body.fkn84 : Nat.ble 3674 3692 = true
-- the bridge and the pending traces' regions
kernel_rfl PRE_first_tail_x15_r0_body.cbridge84 : Host.Ts.Sim.Full.bridgeOf PRE_first_tail_x15_r0_body.s822.ffi = Host.Ts.Sim.Full.bridgeOf PRE_first_tail_x15_r0_body.s823.ffi
kernel_rfl PRE_first_tail_x15_r0_body.cpendR84 : pendRegB PRE_first_tail_x15_r0_body.kappa84 (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s823.ffi).mlx = true
kernel_rfl PRE_first_tail_x15_r0_body.cpendLe84 : Nat.ble (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s823.ffi).mlx.next (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s822.ffi).mlx.next = true
/-- **The compaction's native shift**, given the call's bookkeeping, its relation's facts (the model's and the
observers') and the canonical closedness. -/
theorem PRE_first_tail_x15_r0_body.cshift84 (clean : Conv.NClean (⟨19868, 16937, 2741371, 3674⟩ : Conv.Cnt) (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s821.ffi).mlx) (hltC : ∀ h, PH (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s821.ffi).mlx h → h < (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s821.ffi).mlx.next) (nltC : ∀ i, PN (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s821.ffi).mlx i → i < (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s821.ffi).mlx.nnext) (itemsC : ∀ k v, (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s821.ffi).mlx.items.get k = some v → PN (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s821.ffi).mlx k) (tracedC : ∀ h o, (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s821.ffi).mlx.objs.get h = some o → ∀ i ∈ objTraces o, i < PRE_first_tail_x15_r0_body.P84.NL) (cl : SSt (· < 3692) PRE_first_tail_x15_r0_body.cx0_84.mlx)
    (hobjC : ∀ h, PRE_first_tail_x15_r0_body.fxC_84.get h = some () → ((Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s821.ffi).mlx.objs.get h).isSome = true)
    (hfC : ∀ h, (PRE_first_tail_x15_r0_body.krC_84.flags.get h).isSome = true → ((Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s821.ffi).mlx.objs.get h).isSome = true)
    (htC : ∀ h, (PRE_first_tail_x15_r0_body.krC_84.targs.get h).isSome = true → ((Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s821.ffi).mlx.objs.get h).isSome = true)
    (hclC : ∀ h l, PRE_first_tail_x15_r0_body.krC_84.targs.get h = some l → Host.Ts.Sim.Full.STargs (· < (⟨19868, 16937, 2741371, 3674⟩ : Conv.Cnt).n) l) :
    Conv.FullShiftQ PRE_first_tail_x15_r0_body.P84 3692 PRE_first_tail_x15_r0_body.kappa84 PRE_first_tail_x15_r0_body.s823.ffi PRE_first_tail_x15_r0_body.s822.ffi :=
  ⟨PRE_first_tail_x15_r0_body.cnshift84 clean hltC nltC itemsC tracedC cl, PRE_first_tail_x15_r0_body.cqueue84, fun t ht => bSN_sound (List.all_eq_true.mp PRE_first_tail_x15_r0_body.ctokSupp84 t ht),
    PRE_first_tail_x15_r0_body.cbridge84,
    liveShift_foot (x0' := Host.Ts.Sim.Full.mlxOf PRE_first_tail_x15_r0_body.s823.ffi) (x1' := Host.Ts.Sim.Full.mlxOf PRE_first_tail_x15_r0_body.s822.ffi) (PRE_first_tail_x15_r0_body.cfoot84 clean hltC nltC itemsC tracedC cl) rfl PRE_first_tail_x15_r0_body.ofx0_84 PRE_first_tail_x15_r0_body.ofx1_84 hobjC PRE_first_tail_x15_r0_body.ff084 PRE_first_tail_x15_r0_body.ff184 PRE_first_tail_x15_r0_body.ffck84,
    kernShift_foot (x0' := Host.Ts.Sim.Full.mlxOf PRE_first_tail_x15_r0_body.s823.ffi) (x1' := Host.Ts.Sim.Full.mlxOf PRE_first_tail_x15_r0_body.s822.ffi) (PRE_first_tail_x15_r0_body.cfoot84 clean hltC nltC itemsC tracedC cl) rfl PRE_first_tail_x15_r0_body.okr0_84 PRE_first_tail_x15_r0_body.okr1_84 (Nat.le_of_ble_eq_true PRE_first_tail_x15_r0_body.fkn84) hfC htC hclC
      PRE_first_tail_x15_r0_body.fkf084 PRE_first_tail_x15_r0_body.fkt084 PRE_first_tail_x15_r0_body.fkf184 PRE_first_tail_x15_r0_body.fkt184 PRE_first_tail_x15_r0_body.fkck84,
    pendReg_of rfl PRE_first_tail_x15_r0_body.cnh084 PRE_first_tail_x15_r0_body.cnh184 (Nat.le_of_ble_eq_true PRE_first_tail_x15_r0_body.cpendLe84) PRE_first_tail_x15_r0_body.cpendR84⟩

end Host.Load.Run.Tpl
