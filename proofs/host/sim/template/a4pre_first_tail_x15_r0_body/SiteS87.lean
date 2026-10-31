import host.sim.template.a4pre_first_tail_x15_r0_body.SiteCl87
import host.sim.conv.CompactFull
import host.sim.template.FootGen
set_option Elab.async false
namespace Host.Load.Run.Tpl
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
open Host.Ts Host.Ts.Sim Host.Ts.Sim.Template

/-! The compaction's native shift at call site 87 from its footprint (`Conv.nshift_of_foot`), and the observers'
(`liveShift_foot`, `kernShift_foot`): `Conv.FullShiftQ` for `Conv.full_compactQ`, given the call's bookkeeping and its
relation's facts. -/

/-- The load parameters of the chain (band-free: its start's node counter as `NL` and `N0`). -/
def PRE_first_tail_x15_r0_body.Pc87 : LoadP := ⟨18151, 131072, 1099511627776, 15235, 15235, []⟩
/-- The site's band raised to the map's checked fixed-node prefix, including newly recorded closure traces. -/
def PRE_first_tail_x15_r0_body.P87 : LoadP := PRE_first_tail_x15_r0_body.Pc87.raise 17027
kernel_rfl PRE_first_tail_x15_r0_body.craise87 : Nat.ble PRE_first_tail_x15_r0_body.Pc87.N0 17027 = true
theorem PRE_first_tail_x15_r0_body.raised87 : Host.Ts.Sim.Full.Raised PRE_first_tail_x15_r0_body.Pc87 PRE_first_tail_x15_r0_body.P87 :=
  .inr ⟨17027, rfl, Nat.le_of_ble_eq_true PRE_first_tail_x15_r0_body.craise87, rfl⟩
noncomputable abbrev PRE_first_tail_x15_r0_body.cx0_87 : Host.Load.LSt := clearTokens (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s852.ffi)
noncomputable abbrev PRE_first_tail_x15_r0_body.cx1_87 : Host.Load.LSt := clearTokens (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s851.ffi)
def PRE_first_tail_x15_r0_body.khinv87 : PTrie Nat := Stage.setAll PTrie.nil [(19951, 19925), (19929, 19926), (19952, 19927)]
def PRE_first_tail_x15_r0_body.kninv87 : PTrie Nat := Stage.setAll PTrie.nil [(17000, 17000), (17001, 17001), (17002, 17002), (17003, 17003), (17004, 17004), (17005, 17005), (17006, 17006), (17007, 17007), (17008, 17008), (17009, 17009), (17010, 17010), (17011, 17011), (17012, 17012), (17013, 17013), (17014, 17014), (17015, 17015), (17016, 17016), (17017, 17017), (17018, 17018), (17019, 17019), (17020, 17020), (17021, 17021), (17022, 17022), (17023, 17023), (17024, 17024), (17025, 17025), (17026, 17026)]
/-- The stage's footprint: its written and fresh handles, fresh nodes, written and fresh items. -/
def PRE_first_tail_x15_r0_body.cwS87 : List Nat := [19905, 19918, 19924, 19925, 19926, 19927, 19928, 19929, 19930, 19931, 19932, 19933, 19934, 19935, 19936, 19937, 19938, 19939, 19940, 19941, 19942, 19943, 19944, 19945, 19946, 19947, 19948, 19949, 19950, 19951, 19952]
def PRE_first_tail_x15_r0_body.cnS87 : List Nat := List.range' 17000 27
def PRE_first_tail_x15_r0_body.ciS87 : List Nat := [] ++ List.range' 17000 27

-- the small checks (`MChecks`'s)
kernel_rfl PRE_first_tail_x15_r0_body.cnh087 : PRE_first_tail_x15_r0_body.kd87.nh0 = PRE_first_tail_x15_r0_body.cx0_87.mlx.next
kernel_rfl PRE_first_tail_x15_r0_body.cnh187 : PRE_first_tail_x15_r0_body.kd87.nh1 = PRE_first_tail_x15_r0_body.cx1_87.mlx.next
kernel_rfl PRE_first_tail_x15_r0_body.cnn087 : PRE_first_tail_x15_r0_body.kd87.nn0 = PRE_first_tail_x15_r0_body.cx0_87.mlx.nnext
kernel_rfl PRE_first_tail_x15_r0_body.cnn187 : PRE_first_tail_x15_r0_body.kd87.nn1 = PRE_first_tail_x15_r0_body.cx1_87.mlx.nnext
kernel_rfl PRE_first_tail_x15_r0_body.cplo87 : (Nat.blt 0 PRE_first_tail_x15_r0_body.P87.lo && Nat.ble PRE_first_tail_x15_r0_body.P87.lo PRE_first_tail_x15_r0_body.cx0_87.mlx.next && Nat.ble PRE_first_tail_x15_r0_body.P87.lo RData.bigHi && Nat.ble RData.bigHi PRE_first_tail_x15_r0_body.P87.E) = true
kernel_rfl PRE_first_tail_x15_r0_body.ccnt87 : (Nat.ble PRE_first_tail_x15_r0_body.cx0_87.mlx.next PRE_first_tail_x15_r0_body.cx1_87.mlx.next && Nat.ble PRE_first_tail_x15_r0_body.cx0_87.mlx.nnext PRE_first_tail_x15_r0_body.cx1_87.mlx.nnext) = true
kernel_rfl PRE_first_tail_x15_r0_body.cnband87 : (Nat.blt 0 PRE_first_tail_x15_r0_body.P87.NL && Nat.ble PRE_first_tail_x15_r0_body.P87.NL PRE_first_tail_x15_r0_body.P87.N0 && Nat.ble PRE_first_tail_x15_r0_body.P87.N0 PRE_first_tail_x15_r0_body.cx0_87.mlx.nnext) = true
kernel_rfl PRE_first_tail_x15_r0_body.chbelow87 : PRE_first_tail_x15_r0_body.kd87.checkHndBelow = true
kernel_rfl PRE_first_tail_x15_r0_body.chren87 : checkRenG PRE_first_tail_x15_r0_body.kd87.hnd PRE_first_tail_x15_r0_body.khinv87 (phB PRE_first_tail_x15_r0_body.cx0_87.mlx) = true
kernel_rfl PRE_first_tail_x15_r0_body.cband87 : PRE_first_tail_x15_r0_body.kd87.checkBand PRE_first_tail_x15_r0_body.P87.lo = true
kernel_rfl PRE_first_tail_x15_r0_body.cnh1pos87 : Nat.blt 0 PRE_first_tail_x15_r0_body.kd87.nh1 = true
kernel_rfl PRE_first_tail_x15_r0_body.cnren87 : checkRenG PRE_first_tail_x15_r0_body.kd87.node PRE_first_tail_x15_r0_body.kninv87 (pnB PRE_first_tail_x15_r0_body.cx0_87.mlx) = true
kernel_rfl PRE_first_tail_x15_r0_body.cnlow87 : (PTrie.keysA PRE_first_tail_x15_r0_body.kd87.node).all (fun j => Nat.ble PRE_first_tail_x15_r0_body.P87.NL j && Nat.blt (PRE_first_tail_x15_r0_body.kd87.nodeF j) PRE_first_tail_x15_r0_body.cx1_87.mlx.nnext) = true
kernel_rfl PRE_first_tail_x15_r0_body.cabs0a87 : PRE_first_tail_x15_r0_body.cx0_87.mlx.arrs.get 0 = none
kernel_rfl PRE_first_tail_x15_r0_body.cabs0b87 : PRE_first_tail_x15_r0_body.cx0_87.mlx.objs.get 0 = none
kernel_rfl PRE_first_tail_x15_r0_body.ctok187 : PRE_first_tail_x15_r0_body.cx1_87.mlx.tokens = []
kernel_rfl PRE_first_tail_x15_r0_body.cpend87 : PRE_first_tail_x15_r0_body.cx1_87.mlx.pending = PRE_first_tail_x15_r0_body.cx0_87.mlx.pending.map PRE_first_tail_x15_r0_body.kappa87.pend
kernel_rfl PRE_first_tail_x15_r0_body.cerrh87 : PRE_first_tail_x15_r0_body.cx1_87.mlx.errh = PRE_first_tail_x15_r0_body.cx0_87.mlx.errh.map PRE_first_tail_x15_r0_body.kappa87.arg
kernel_rfl PRE_first_tail_x15_r0_body.cfiles87 : PRE_first_tail_x15_r0_body.cx1_87.mlx.files = PRE_first_tail_x15_r0_body.cx0_87.mlx.files
kernel_rfl PRE_first_tail_x15_r0_body.carch87 : PRE_first_tail_x15_r0_body.cx1_87.mlx.arch = PRE_first_tail_x15_r0_body.cx0_87.mlx.arch
kernel_rfl PRE_first_tail_x15_r0_body.csizes87 : PRE_first_tail_x15_r0_body.cx1_87.mlx.deviceSizes = PRE_first_tail_x15_r0_body.cx0_87.mlx.deviceSizes
kernel_rfl PRE_first_tail_x15_r0_body.cwired87 : PRE_first_tail_x15_r0_body.cx1_87.mlx.wired = PRE_first_tail_x15_r0_body.cx0_87.mlx.wired
kernel_rfl PRE_first_tail_x15_r0_body.chost87 : PRE_first_tail_x15_r0_body.cx1_87.host = PRE_first_tail_x15_r0_body.cx0_87.host
-- the compaction map's addresses are `PRE_first_tail_x15_r0_body.kd87`'s
kernel_rfl PRE_first_tail_x15_r0_body.ckn087 : PRE_first_tail_x15_r0_body.kd87.n0 = 2743633
kernel_rfl PRE_first_tail_x15_r0_body.ckn187 : PRE_first_tail_x15_r0_body.kd87.n1 = 2744782
kernel_rfl PRE_first_tail_x15_r0_body.ckheap87 : (PTrie.keysA PRE_first_tail_x15_r0_body.kd87.heap).all (fun x => Nat.ble 2743627 x) = true
kernel_rfl PRE_first_tail_x15_r0_body.ckpl87 : (List.range 6).all (fun j => decide (PRE_first_tail_x15_r0_body.kd87.heap.get (2743627 + j) = nth? PRE_first_tail_x15_r0_body.pl87 j)) = true
-- the map fixes the call's names (`Conv.fixOld_compact`), the call's counters
kernel_rfl PRE_first_tail_x15_r0_body.fja87 : Nat.ble 2743627 2743627 = true
kernel_rfl PRE_first_tail_x15_r0_body.fn87 : Nat.ble 3803 3803 = true
kernel_rfl PRE_first_tail_x15_r0_body.fjaD87 : Nat.ble 2743627 PRE_first_tail_x15_r0_body.kd87.n0 = true
kernel_rfl PRE_first_tail_x15_r0_body.fxn87 : Nat.ble 19925 PRE_first_tail_x15_r0_body.kd87.nh0 = true
kernel_rfl PRE_first_tail_x15_r0_body.fnn87 : Nat.ble 17000 PRE_first_tail_x15_r0_body.kd87.nn0 = true
kernel_rfl PRE_first_tail_x15_r0_body.fxb87 : Nat.ble 19925 RData.bigHi = true
kernel_rfl PRE_first_tail_x15_r0_body.fheap87 : (PTrie.keysA PRE_first_tail_x15_r0_body.kd87.heap).all (Nat.ble (⟨19925, 17000, 2743627, 3803⟩ : Conv.Cnt).ja) = true
kernel_rfl PRE_first_tail_x15_r0_body.fhnd87 : (PTrie.keysA PRE_first_tail_x15_r0_body.kd87.hnd).all (Nat.ble (⟨19925, 17000, 2743627, 3803⟩ : Conv.Cnt).xn) = true
kernel_rfl PRE_first_tail_x15_r0_body.fnode87 : (PTrie.keysA PRE_first_tail_x15_r0_body.kd87.node).all (Nat.ble (⟨19925, 17000, 2743627, 3803⟩ : Conv.Cnt).nn) = true
/-- The compaction map fixes the call's names. -/
theorem PRE_first_tail_x15_r0_body.cfix87 : Conv.FixOld (⟨19925, 17000, 2743627, 3803⟩ : Conv.Cnt) PRE_first_tail_x15_r0_body.kappa87 :=
  Conv.fixOld_compact (Nat.le_of_ble_eq_true PRE_first_tail_x15_r0_body.fja87) (Nat.le_of_ble_eq_true PRE_first_tail_x15_r0_body.fn87) (Nat.le_of_ble_eq_true PRE_first_tail_x15_r0_body.fjaD87) (Nat.le_of_ble_eq_true PRE_first_tail_x15_r0_body.fxn87) (Nat.le_of_ble_eq_true PRE_first_tail_x15_r0_body.fnn87) (Nat.le_of_ble_eq_true PRE_first_tail_x15_r0_body.fxb87) PRE_first_tail_x15_r0_body.fheap87 PRE_first_tail_x15_r0_body.fhnd87 PRE_first_tail_x15_r0_body.fnode87
kernel_rfl PRE_first_tail_x15_r0_body.fcxn87 : (⟨19925, 17000, 2743627, 3803⟩ : Conv.Cnt).xn = (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s850.ffi).mlx.next
kernel_rfl PRE_first_tail_x15_r0_body.fcnn87 : (⟨19925, 17000, 2743627, 3803⟩ : Conv.Cnt).nn = (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s850.ffi).mlx.nnext
kernel_rfl PRE_first_tail_x15_r0_body.fle087 : (Nat.ble (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s850.ffi).mlx.next PRE_first_tail_x15_r0_body.cx0_87.mlx.next && Nat.ble (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s850.ffi).mlx.nnext PRE_first_tail_x15_r0_body.cx0_87.mlx.nnext && Nat.ble (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s850.ffi).mlx.next RData.bigHi) = true
kernel_rfl PRE_first_tail_x15_r0_body.fnk87 : (PTrie.keysA PRE_first_tail_x15_r0_body.kd87.node).all (Nat.ble (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s850.ffi).mlx.nnext) = true
-- the merged state keeps the call's entries off the stage's footprint
kernel_rfl PRE_first_tail_x15_r0_body.f1A87 : PRE_first_tail_x15_r0_body.cx1_87.mlx.arrs = Stage.setAll (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s850.ffi).mlx.arrs (PRE_first_tail_x15_r0_body.cwS87.filterMap fun i => (PRE_first_tail_x15_r0_body.cx1_87.mlx.arrs.get i).map (i, ·))
kernel_rfl PRE_first_tail_x15_r0_body.f1O87 : PRE_first_tail_x15_r0_body.cx1_87.mlx.objs = Stage.setAll (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s850.ffi).mlx.objs (PRE_first_tail_x15_r0_body.cwS87.filterMap fun i => (PRE_first_tail_x15_r0_body.cx1_87.mlx.objs.get i).map (i, ·))
kernel_rfl PRE_first_tail_x15_r0_body.f1N87 : PRE_first_tail_x15_r0_body.cx1_87.mlx.nodes = Stage.setAll (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s850.ffi).mlx.nodes (PRE_first_tail_x15_r0_body.cnS87.filterMap fun i => (PRE_first_tail_x15_r0_body.cx1_87.mlx.nodes.get i).map (i, ·))
kernel_rfl PRE_first_tail_x15_r0_body.f1I87 : PRE_first_tail_x15_r0_body.cx1_87.mlx.items = Stage.setAll (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s850.ffi).mlx.items (PRE_first_tail_x15_r0_body.ciS87.filterMap fun i => (PRE_first_tail_x15_r0_body.cx1_87.mlx.items.get i).map (i, ·))
kernel_rfl PRE_first_tail_x15_r0_body.fbd87 : (PRE_first_tail_x15_r0_body.clo87 ++ PRE_first_tail_x15_r0_body.cln87 ++ PRE_first_tail_x15_r0_body.cli87 ++ PRE_first_tail_x15_r0_body.cwS87 ++ PRE_first_tail_x15_r0_body.cnS87 ++ PRE_first_tail_x15_r0_body.ciS87).all (fun i => Nat.blt (i / 4096) (4 ^ 31)) = true
kernel_rfl PRE_first_tail_x15_r0_body.fincW87 : PRE_first_tail_x15_r0_body.cwS87.all (fun h => !Nat.blt h (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s850.ffi).mlx.next || PRE_first_tail_x15_r0_body.clo87.contains h) = true
kernel_rfl PRE_first_tail_x15_r0_body.fincI87 : PRE_first_tail_x15_r0_body.ciS87.all (fun k => !Nat.blt k (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s850.ffi).mlx.nnext || PRE_first_tail_x15_r0_body.cli87.contains k) = true
kernel_rfl PRE_first_tail_x15_r0_body.fincN87 : PRE_first_tail_x15_r0_body.cnS87.all (Nat.ble (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s850.ffi).mlx.nnext) = true
kernel_rfl PRE_first_tail_x15_r0_body.flnF87 : PRE_first_tail_x15_r0_body.cln87.all (Nat.ble (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s850.ffi).mlx.nnext) = true
-- the checks over the changed lists
kernel_rfl PRE_first_tail_x15_r0_body.fh87 : PRE_first_tail_x15_r0_body.clo87.all (handleOK PRE_first_tail_x15_r0_body.kappa87 PRE_first_tail_x15_r0_body.P87.lo PRE_first_tail_x15_r0_body.cx0_87.mlx PRE_first_tail_x15_r0_body.cx1_87.mlx) = true
kernel_rfl PRE_first_tail_x15_r0_body.fo87 : PRE_first_tail_x15_r0_body.clo87.map (fun h => PRE_first_tail_x15_r0_body.cx1_87.mlx.objs.get (PRE_first_tail_x15_r0_body.kappa87.handle h)) = PRE_first_tail_x15_r0_body.clo87.map (fun h => (PRE_first_tail_x15_r0_body.cx0_87.mlx.objs.get h).map PRE_first_tail_x15_r0_body.kappa87.nobj)
kernel_rfl PRE_first_tail_x15_r0_body.fok87 : PRE_first_tail_x15_r0_body.clo87.all (objOK PRE_first_tail_x15_r0_body.kappa87 PRE_first_tail_x15_r0_body.P87.NL PRE_first_tail_x15_r0_body.cx0_87.mlx) = true
kernel_rfl PRE_first_tail_x15_r0_body.fnd87 : PRE_first_tail_x15_r0_body.cln87.all (nodeOKF PRE_first_tail_x15_r0_body.kappa87 PRE_first_tail_x15_r0_body.P87 PRE_first_tail_x15_r0_body.cx0_87.mlx PRE_first_tail_x15_r0_body.cx1_87.mlx) = true
kernel_rfl PRE_first_tail_x15_r0_body.fp87 : ((PRE_first_tail_x15_r0_body.cln87.filter (fullB PRE_first_tail_x15_r0_body.P87))).map (fun i => (PRE_first_tail_x15_r0_body.cx1_87.mlx.nodes.get (PRE_first_tail_x15_r0_body.kappa87.node i)).map Host.Mlx.Ffi.Node.prim) =
  ((PRE_first_tail_x15_r0_body.cln87.filter (fullB PRE_first_tail_x15_r0_body.P87))).map (fun i => (PRE_first_tail_x15_r0_body.cx0_87.mlx.nodes.get i).map fun nd => PRE_first_tail_x15_r0_body.kappa87.prim nd.prim)
kernel_rfl PRE_first_tail_x15_r0_body.fnordI87 : incrB PRE_first_tail_x15_r0_body.kd87.nodeF (List.range' 17000 27) = true
kernel_rfl PRE_first_tail_x15_r0_body.fnordK87 : (PTrie.keysA PRE_first_tail_x15_r0_body.kd87.node).all (fun k => Nat.ble 17000 k && Nat.blt k 17027) = true
kernel_rfl PRE_first_tail_x15_r0_body.fnordL87 : (PRE_first_tail_x15_r0_body.cln87.filter (Nat.ble PRE_first_tail_x15_r0_body.P87.N0)).all (fun i => Nat.ble i (PRE_first_tail_x15_r0_body.kd87.nodeF i) && (Nat.blt i 17027 || Nat.ble PRE_first_tail_x15_r0_body.kd87.nn0 i)) = true
theorem PRE_first_tail_x15_r0_body.fnord87 : (PRE_first_tail_x15_r0_body.cln87.filter (Nat.ble PRE_first_tail_x15_r0_body.P87.N0)).all (fun i => Nat.ble i (PRE_first_tail_x15_r0_body.kd87.nodeF i) &&
    (PTrie.keysA PRE_first_tail_x15_r0_body.kd87.node).all fun j => !Nat.blt j i || Nat.blt (PRE_first_tail_x15_r0_body.kd87.nodeF j) (PRE_first_tail_x15_r0_body.kd87.nodeF i)) = true :=
  cnord_of PRE_first_tail_x15_r0_body.cnlow87 PRE_first_tail_x15_r0_body.cnn187 PRE_first_tail_x15_r0_body.fnordI87 PRE_first_tail_x15_r0_body.fnordK87 PRE_first_tail_x15_r0_body.fnordL87
kernel_rfl PRE_first_tail_x15_r0_body.fi87 : PRE_first_tail_x15_r0_body.cli87.all (pnB PRE_first_tail_x15_r0_body.cx0_87.mlx) = true
kernel_rfl PRE_first_tail_x15_r0_body.fii87 : PRE_first_tail_x15_r0_body.cli87.all (fun k => decide (PRE_first_tail_x15_r0_body.cx1_87.mlx.items.get (PRE_first_tail_x15_r0_body.kappa87.node k) = (PRE_first_tail_x15_r0_body.cx0_87.mlx.items.get k).map PRE_first_tail_x15_r0_body.kappa87.nv)) = true
/-- **The compaction's footprint.** -/
theorem PRE_first_tail_x15_r0_body.cfoot87 (clean : Conv.NClean (⟨19925, 17000, 2743627, 3803⟩ : Conv.Cnt) (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s850.ffi).mlx) (hltC : ∀ h, PH (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s850.ffi).mlx h → h < (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s850.ffi).mlx.next) (nltC : ∀ i, PN (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s850.ffi).mlx i → i < (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s850.ffi).mlx.nnext) (itemsC : ∀ k v, (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s850.ffi).mlx.items.get k = some v → PN (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s850.ffi).mlx k) (tracedC : ∀ h o, (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s850.ffi).mlx.objs.get h = some o → ∀ i ∈ objTraces o, i < PRE_first_tail_x15_r0_body.P87.NL) (cl : SSt (· < 3821) PRE_first_tail_x15_r0_body.cx0_87.mlx) :
    Conv.MFoot PRE_first_tail_x15_r0_body.P87 3821 PRE_first_tail_x15_r0_body.kappa87 PRE_first_tail_x15_r0_body.kd87 PRE_first_tail_x15_r0_body.khinv87 PRE_first_tail_x15_r0_body.kninv87 (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s850.ffi).mlx PRE_first_tail_x15_r0_body.cx0_87.mlx PRE_first_tail_x15_r0_body.cx1_87.mlx (⟨19925, 17000, 2743627, 3803⟩ : Conv.Cnt) PRE_first_tail_x15_r0_body.clo87 PRE_first_tail_x15_r0_body.cln87 PRE_first_tail_x15_r0_body.cli87 PRE_first_tail_x15_r0_body.cwS87 PRE_first_tail_x15_r0_body.cnS87 PRE_first_tail_x15_r0_body.ciS87 :=
  ⟨rfl, rfl, rfl, PRE_first_tail_x15_r0_body.cnh087, PRE_first_tail_x15_r0_body.cnh187, PRE_first_tail_x15_r0_body.cnn087, PRE_first_tail_x15_r0_body.cnn187, PRE_first_tail_x15_r0_body.cplo87, PRE_first_tail_x15_r0_body.ccnt87, PRE_first_tail_x15_r0_body.cnband87, PRE_first_tail_x15_r0_body.chbelow87, PRE_first_tail_x15_r0_body.chren87, PRE_first_tail_x15_r0_body.cband87, PRE_first_tail_x15_r0_body.cnh1pos87, PRE_first_tail_x15_r0_body.cnren87, PRE_first_tail_x15_r0_body.cnlow87, PRE_first_tail_x15_r0_body.cabs0a87, PRE_first_tail_x15_r0_body.cabs0b87, PRE_first_tail_x15_r0_body.ctok187, PRE_first_tail_x15_r0_body.cpend87, PRE_first_tail_x15_r0_body.cerrh87, PRE_first_tail_x15_r0_body.cfiles87, PRE_first_tail_x15_r0_body.carch87, PRE_first_tail_x15_r0_body.csizes87, PRE_first_tail_x15_r0_body.cwired87, PRE_first_tail_x15_r0_body.cfix87, clean, PRE_first_tail_x15_r0_body.fcxn87, PRE_first_tail_x15_r0_body.fcnn87, hltC, nltC, itemsC, tracedC, cl, PRE_first_tail_x15_r0_body.fle087, PRE_first_tail_x15_r0_body.fnk87, PRE_first_tail_x15_r0_body.ckA87, PRE_first_tail_x15_r0_body.cobjsK87, PRE_first_tail_x15_r0_body.cnodesK87, PRE_first_tail_x15_r0_body.citemsK87, PRE_first_tail_x15_r0_body.f1A87, PRE_first_tail_x15_r0_body.f1O87, PRE_first_tail_x15_r0_body.f1N87, PRE_first_tail_x15_r0_body.f1I87, PRE_first_tail_x15_r0_body.fbd87, PRE_first_tail_x15_r0_body.fincW87, PRE_first_tail_x15_r0_body.fincI87, PRE_first_tail_x15_r0_body.fincN87, PRE_first_tail_x15_r0_body.flnF87, PRE_first_tail_x15_r0_body.fh87, PRE_first_tail_x15_r0_body.fo87, PRE_first_tail_x15_r0_body.fok87, PRE_first_tail_x15_r0_body.fnd87, PRE_first_tail_x15_r0_body.fp87, PRE_first_tail_x15_r0_body.fnord87, PRE_first_tail_x15_r0_body.fi87, PRE_first_tail_x15_r0_body.fii87⟩
theorem PRE_first_tail_x15_r0_body.cnshift87 (clean : Conv.NClean (⟨19925, 17000, 2743627, 3803⟩ : Conv.Cnt) (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s850.ffi).mlx) (hltC : ∀ h, PH (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s850.ffi).mlx h → h < (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s850.ffi).mlx.next) (nltC : ∀ i, PN (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s850.ffi).mlx i → i < (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s850.ffi).mlx.nnext) (itemsC : ∀ k v, (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s850.ffi).mlx.items.get k = some v → PN (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s850.ffi).mlx k) (tracedC : ∀ h o, (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s850.ffi).mlx.objs.get h = some o → ∀ i ∈ objTraces o, i < PRE_first_tail_x15_r0_body.P87.NL) (cl : SSt (· < 3821) PRE_first_tail_x15_r0_body.cx0_87.mlx) : NShift PRE_first_tail_x15_r0_body.P87 3821 PRE_first_tail_x15_r0_body.kappa87 PRE_first_tail_x15_r0_body.cx0_87 PRE_first_tail_x15_r0_body.cx1_87 :=
  Conv.nshift_of_foot (PRE_first_tail_x15_r0_body.cfoot87 clean hltC nltC itemsC tracedC cl) PRE_first_tail_x15_r0_body.chost87 (compact_a_eq PRE_first_tail_x15_r0_body.ckn087 PRE_first_tail_x15_r0_body.ckn187 PRE_first_tail_x15_r0_body.ckheap87 PRE_first_tail_x15_r0_body.ckpl87)

-- the observers: the layers' states at the call, the canonical and the merged state, their footprints and checks
noncomputable def PRE_first_tail_x15_r0_body.fxC_87 : PTrie Unit := (Host.Ts.Sim.Full.freedOf PRE_first_tail_x15_r0_body.s850.ffi).getD PTrie.nil
noncomputable def PRE_first_tail_x15_r0_body.krC_87 : Host.Load.Layers.KRec := (Host.Ts.Sim.Full.krecOf PRE_first_tail_x15_r0_body.s850.ffi).getD Host.Load.Layers.KRec.empty
kernel_rfl PRE_first_tail_x15_r0_body.ofxC_87 : (Host.Ts.Sim.Full.freedOf PRE_first_tail_x15_r0_body.s850.ffi) = some PRE_first_tail_x15_r0_body.fxC_87
kernel_rfl PRE_first_tail_x15_r0_body.okrC_87 : (Host.Ts.Sim.Full.krecOf PRE_first_tail_x15_r0_body.s850.ffi) = some PRE_first_tail_x15_r0_body.krC_87
noncomputable def PRE_first_tail_x15_r0_body.fx0_87 : PTrie Unit := (Host.Ts.Sim.Full.freedOf PRE_first_tail_x15_r0_body.s852.ffi).getD PTrie.nil
noncomputable def PRE_first_tail_x15_r0_body.kr0_87 : Host.Load.Layers.KRec := (Host.Ts.Sim.Full.krecOf PRE_first_tail_x15_r0_body.s852.ffi).getD Host.Load.Layers.KRec.empty
kernel_rfl PRE_first_tail_x15_r0_body.ofx0_87 : (Host.Ts.Sim.Full.freedOf PRE_first_tail_x15_r0_body.s852.ffi) = some PRE_first_tail_x15_r0_body.fx0_87
kernel_rfl PRE_first_tail_x15_r0_body.okr0_87 : (Host.Ts.Sim.Full.krecOf PRE_first_tail_x15_r0_body.s852.ffi) = some PRE_first_tail_x15_r0_body.kr0_87
noncomputable def PRE_first_tail_x15_r0_body.fx1_87 : PTrie Unit := (Host.Ts.Sim.Full.freedOf PRE_first_tail_x15_r0_body.s851.ffi).getD PTrie.nil
noncomputable def PRE_first_tail_x15_r0_body.kr1_87 : Host.Load.Layers.KRec := (Host.Ts.Sim.Full.krecOf PRE_first_tail_x15_r0_body.s851.ffi).getD Host.Load.Layers.KRec.empty
kernel_rfl PRE_first_tail_x15_r0_body.ofx1_87 : (Host.Ts.Sim.Full.freedOf PRE_first_tail_x15_r0_body.s851.ffi) = some PRE_first_tail_x15_r0_body.fx1_87
kernel_rfl PRE_first_tail_x15_r0_body.okr1_87 : (Host.Ts.Sim.Full.krecOf PRE_first_tail_x15_r0_body.s851.ffi) = some PRE_first_tail_x15_r0_body.kr1_87
kernel_rfl PRE_first_tail_x15_r0_body.ff087 : PRE_first_tail_x15_r0_body.fx0_87 = Stage.setAll PRE_first_tail_x15_r0_body.fxC_87 (PRE_first_tail_x15_r0_body.clo87.filterMap fun i => (PRE_first_tail_x15_r0_body.fx0_87.get i).map (i, ·))
kernel_rfl PRE_first_tail_x15_r0_body.ff187 : PRE_first_tail_x15_r0_body.fx1_87 = Stage.setAll PRE_first_tail_x15_r0_body.fxC_87 (PRE_first_tail_x15_r0_body.cwS87.filterMap fun i => (PRE_first_tail_x15_r0_body.fx1_87.get i).map (i, ·))
kernel_rfl PRE_first_tail_x15_r0_body.ffck87 : freedLB PRE_first_tail_x15_r0_body.kappa87 PRE_first_tail_x15_r0_body.cx0_87.mlx PRE_first_tail_x15_r0_body.fx0_87 PRE_first_tail_x15_r0_body.fx1_87 PRE_first_tail_x15_r0_body.clo87 = true
kernel_rfl PRE_first_tail_x15_r0_body.fkf087 : PRE_first_tail_x15_r0_body.kr0_87.flags = Stage.setAll PRE_first_tail_x15_r0_body.krC_87.flags (PRE_first_tail_x15_r0_body.clo87.filterMap fun i => (PRE_first_tail_x15_r0_body.kr0_87.flags.get i).map (i, ·))
kernel_rfl PRE_first_tail_x15_r0_body.fkt087 : PRE_first_tail_x15_r0_body.kr0_87.targs = Stage.setAll PRE_first_tail_x15_r0_body.krC_87.targs (PRE_first_tail_x15_r0_body.clo87.filterMap fun i => (PRE_first_tail_x15_r0_body.kr0_87.targs.get i).map (i, ·))
kernel_rfl PRE_first_tail_x15_r0_body.fkf187 : PRE_first_tail_x15_r0_body.kr1_87.flags = Stage.setAll PRE_first_tail_x15_r0_body.krC_87.flags (PRE_first_tail_x15_r0_body.cwS87.filterMap fun i => (PRE_first_tail_x15_r0_body.kr1_87.flags.get i).map (i, ·))
kernel_rfl PRE_first_tail_x15_r0_body.fkt187 : PRE_first_tail_x15_r0_body.kr1_87.targs = Stage.setAll PRE_first_tail_x15_r0_body.krC_87.targs (PRE_first_tail_x15_r0_body.cwS87.filterMap fun i => (PRE_first_tail_x15_r0_body.kr1_87.targs.get i).map (i, ·))
kernel_rfl PRE_first_tail_x15_r0_body.fkck87 : krecLB PRE_first_tail_x15_r0_body.kappa87 3821 PRE_first_tail_x15_r0_body.cx0_87.mlx PRE_first_tail_x15_r0_body.kr0_87 PRE_first_tail_x15_r0_body.kr1_87 PRE_first_tail_x15_r0_body.clo87 = true
kernel_rfl PRE_first_tail_x15_r0_body.fkn87 : Nat.ble 3803 3821 = true
-- the bridge and the pending traces' regions
kernel_rfl PRE_first_tail_x15_r0_body.cbridge87 : Host.Ts.Sim.Full.bridgeOf PRE_first_tail_x15_r0_body.s851.ffi = Host.Ts.Sim.Full.bridgeOf PRE_first_tail_x15_r0_body.s852.ffi
kernel_rfl PRE_first_tail_x15_r0_body.cpendR87 : pendRegB PRE_first_tail_x15_r0_body.kappa87 (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s852.ffi).mlx = true
kernel_rfl PRE_first_tail_x15_r0_body.cpendLe87 : Nat.ble (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s852.ffi).mlx.next (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s851.ffi).mlx.next = true
/-- **The compaction's native shift**, given the call's bookkeeping, its relation's facts (the model's and the
observers') and the canonical closedness. -/
theorem PRE_first_tail_x15_r0_body.cshift87 (clean : Conv.NClean (⟨19925, 17000, 2743627, 3803⟩ : Conv.Cnt) (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s850.ffi).mlx) (hltC : ∀ h, PH (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s850.ffi).mlx h → h < (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s850.ffi).mlx.next) (nltC : ∀ i, PN (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s850.ffi).mlx i → i < (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s850.ffi).mlx.nnext) (itemsC : ∀ k v, (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s850.ffi).mlx.items.get k = some v → PN (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s850.ffi).mlx k) (tracedC : ∀ h o, (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s850.ffi).mlx.objs.get h = some o → ∀ i ∈ objTraces o, i < PRE_first_tail_x15_r0_body.P87.NL) (cl : SSt (· < 3821) PRE_first_tail_x15_r0_body.cx0_87.mlx)
    (hobjC : ∀ h, PRE_first_tail_x15_r0_body.fxC_87.get h = some () → ((Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s850.ffi).mlx.objs.get h).isSome = true)
    (hfC : ∀ h, (PRE_first_tail_x15_r0_body.krC_87.flags.get h).isSome = true → ((Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s850.ffi).mlx.objs.get h).isSome = true)
    (htC : ∀ h, (PRE_first_tail_x15_r0_body.krC_87.targs.get h).isSome = true → ((Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s850.ffi).mlx.objs.get h).isSome = true)
    (hclC : ∀ h l, PRE_first_tail_x15_r0_body.krC_87.targs.get h = some l → Host.Ts.Sim.Full.STargs (· < (⟨19925, 17000, 2743627, 3803⟩ : Conv.Cnt).n) l) :
    Conv.FullShiftQ PRE_first_tail_x15_r0_body.P87 3821 PRE_first_tail_x15_r0_body.kappa87 PRE_first_tail_x15_r0_body.s852.ffi PRE_first_tail_x15_r0_body.s851.ffi :=
  ⟨PRE_first_tail_x15_r0_body.cnshift87 clean hltC nltC itemsC tracedC cl, PRE_first_tail_x15_r0_body.cqueue87, fun t ht => bSN_sound (List.all_eq_true.mp PRE_first_tail_x15_r0_body.ctokSupp87 t ht),
    PRE_first_tail_x15_r0_body.cbridge87,
    liveShift_foot (x0' := Host.Ts.Sim.Full.mlxOf PRE_first_tail_x15_r0_body.s852.ffi) (x1' := Host.Ts.Sim.Full.mlxOf PRE_first_tail_x15_r0_body.s851.ffi) (PRE_first_tail_x15_r0_body.cfoot87 clean hltC nltC itemsC tracedC cl) rfl PRE_first_tail_x15_r0_body.ofx0_87 PRE_first_tail_x15_r0_body.ofx1_87 hobjC PRE_first_tail_x15_r0_body.ff087 PRE_first_tail_x15_r0_body.ff187 PRE_first_tail_x15_r0_body.ffck87,
    kernShift_foot (x0' := Host.Ts.Sim.Full.mlxOf PRE_first_tail_x15_r0_body.s852.ffi) (x1' := Host.Ts.Sim.Full.mlxOf PRE_first_tail_x15_r0_body.s851.ffi) (PRE_first_tail_x15_r0_body.cfoot87 clean hltC nltC itemsC tracedC cl) rfl PRE_first_tail_x15_r0_body.okr0_87 PRE_first_tail_x15_r0_body.okr1_87 (Nat.le_of_ble_eq_true PRE_first_tail_x15_r0_body.fkn87) hfC htC hclC
      PRE_first_tail_x15_r0_body.fkf087 PRE_first_tail_x15_r0_body.fkt087 PRE_first_tail_x15_r0_body.fkf187 PRE_first_tail_x15_r0_body.fkt187 PRE_first_tail_x15_r0_body.fkck87,
    pendReg_of rfl PRE_first_tail_x15_r0_body.cnh087 PRE_first_tail_x15_r0_body.cnh187 (Nat.le_of_ble_eq_true PRE_first_tail_x15_r0_body.cpendLe87) PRE_first_tail_x15_r0_body.cpendR87⟩

end Host.Load.Run.Tpl
