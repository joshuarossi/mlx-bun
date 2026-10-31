import host.sim.template.a4pre_first_tail_x15_r0_body.SiteCl135
import host.sim.conv.CompactFull
import host.sim.template.FootGen
set_option Elab.async false
namespace Host.Load.Run.Tpl
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
open Host.Ts Host.Ts.Sim Host.Ts.Sim.Template

/-! The compaction's native shift at call site 135 from its footprint (`Conv.nshift_of_foot`), and the observers'
(`liveShift_foot`, `kernShift_foot`): `Conv.FullShiftQ` for `Conv.full_compactQ`, given the call's bookkeeping and its
relation's facts. -/

/-- The load parameters of the chain (band-free: its start's node counter as `NL` and `N0`). -/
def PRE_first_tail_x15_r0_body.Pc135 : LoadP := ⟨18151, 131072, 1099511627776, 15235, 15235, []⟩
/-- The site's band raised to the map's checked fixed-node prefix, including newly recorded closure traces. -/
def PRE_first_tail_x15_r0_body.P135 : LoadP := PRE_first_tail_x15_r0_body.Pc135.raise 17975
kernel_rfl PRE_first_tail_x15_r0_body.craise135 : Nat.ble PRE_first_tail_x15_r0_body.Pc135.N0 17975 = true
theorem PRE_first_tail_x15_r0_body.raised135 : Host.Ts.Sim.Full.Raised PRE_first_tail_x15_r0_body.Pc135 PRE_first_tail_x15_r0_body.P135 :=
  .inr ⟨17975, rfl, Nat.le_of_ble_eq_true PRE_first_tail_x15_r0_body.craise135, rfl⟩
noncomputable abbrev PRE_first_tail_x15_r0_body.cx0_135 : Host.Load.LSt := clearTokens (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1312.ffi)
noncomputable abbrev PRE_first_tail_x15_r0_body.cx1_135 : Host.Load.LSt := clearTokens (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1311.ffi)
def PRE_first_tail_x15_r0_body.khinv135 : PTrie Nat := Stage.setAll PTrie.nil [(20895, 20869), (20873, 20870), (20896, 20871)]
def PRE_first_tail_x15_r0_body.kninv135 : PTrie Nat := Stage.setAll PTrie.nil [(17948, 17948), (17949, 17949), (17950, 17950), (17951, 17951), (17952, 17952), (17953, 17953), (17954, 17954), (17955, 17955), (17956, 17956), (17957, 17957), (17958, 17958), (17959, 17959), (17960, 17960), (17961, 17961), (17962, 17962), (17963, 17963), (17964, 17964), (17965, 17965), (17966, 17966), (17967, 17967), (17968, 17968), (17969, 17969), (17970, 17970), (17971, 17971), (17972, 17972), (17973, 17973), (17974, 17974)]
/-- The stage's footprint: its written and fresh handles, fresh nodes, written and fresh items. -/
def PRE_first_tail_x15_r0_body.cwS135 : List Nat := [20849, 20862, 20868, 20869, 20870, 20871, 20872, 20873, 20874, 20875, 20876, 20877, 20878, 20879, 20880, 20881, 20882, 20883, 20884, 20885, 20886, 20887, 20888, 20889, 20890, 20891, 20892, 20893, 20894, 20895, 20896]
def PRE_first_tail_x15_r0_body.cnS135 : List Nat := List.range' 17948 27
def PRE_first_tail_x15_r0_body.ciS135 : List Nat := [] ++ List.range' 17948 27

-- the small checks (`MChecks`'s)
kernel_rfl PRE_first_tail_x15_r0_body.cnh0135 : PRE_first_tail_x15_r0_body.kd135.nh0 = PRE_first_tail_x15_r0_body.cx0_135.mlx.next
kernel_rfl PRE_first_tail_x15_r0_body.cnh1135 : PRE_first_tail_x15_r0_body.kd135.nh1 = PRE_first_tail_x15_r0_body.cx1_135.mlx.next
kernel_rfl PRE_first_tail_x15_r0_body.cnn0135 : PRE_first_tail_x15_r0_body.kd135.nn0 = PRE_first_tail_x15_r0_body.cx0_135.mlx.nnext
kernel_rfl PRE_first_tail_x15_r0_body.cnn1135 : PRE_first_tail_x15_r0_body.kd135.nn1 = PRE_first_tail_x15_r0_body.cx1_135.mlx.nnext
kernel_rfl PRE_first_tail_x15_r0_body.cplo135 : (Nat.blt 0 PRE_first_tail_x15_r0_body.P135.lo && Nat.ble PRE_first_tail_x15_r0_body.P135.lo PRE_first_tail_x15_r0_body.cx0_135.mlx.next && Nat.ble PRE_first_tail_x15_r0_body.P135.lo RData.bigHi && Nat.ble RData.bigHi PRE_first_tail_x15_r0_body.P135.E) = true
kernel_rfl PRE_first_tail_x15_r0_body.ccnt135 : (Nat.ble PRE_first_tail_x15_r0_body.cx0_135.mlx.next PRE_first_tail_x15_r0_body.cx1_135.mlx.next && Nat.ble PRE_first_tail_x15_r0_body.cx0_135.mlx.nnext PRE_first_tail_x15_r0_body.cx1_135.mlx.nnext) = true
kernel_rfl PRE_first_tail_x15_r0_body.cnband135 : (Nat.blt 0 PRE_first_tail_x15_r0_body.P135.NL && Nat.ble PRE_first_tail_x15_r0_body.P135.NL PRE_first_tail_x15_r0_body.P135.N0 && Nat.ble PRE_first_tail_x15_r0_body.P135.N0 PRE_first_tail_x15_r0_body.cx0_135.mlx.nnext) = true
kernel_rfl PRE_first_tail_x15_r0_body.chbelow135 : PRE_first_tail_x15_r0_body.kd135.checkHndBelow = true
kernel_rfl PRE_first_tail_x15_r0_body.chren135 : checkRenG PRE_first_tail_x15_r0_body.kd135.hnd PRE_first_tail_x15_r0_body.khinv135 (phB PRE_first_tail_x15_r0_body.cx0_135.mlx) = true
kernel_rfl PRE_first_tail_x15_r0_body.cband135 : PRE_first_tail_x15_r0_body.kd135.checkBand PRE_first_tail_x15_r0_body.P135.lo = true
kernel_rfl PRE_first_tail_x15_r0_body.cnh1pos135 : Nat.blt 0 PRE_first_tail_x15_r0_body.kd135.nh1 = true
kernel_rfl PRE_first_tail_x15_r0_body.cnren135 : checkRenG PRE_first_tail_x15_r0_body.kd135.node PRE_first_tail_x15_r0_body.kninv135 (pnB PRE_first_tail_x15_r0_body.cx0_135.mlx) = true
kernel_rfl PRE_first_tail_x15_r0_body.cnlow135 : (PTrie.keysA PRE_first_tail_x15_r0_body.kd135.node).all (fun j => Nat.ble PRE_first_tail_x15_r0_body.P135.NL j && Nat.blt (PRE_first_tail_x15_r0_body.kd135.nodeF j) PRE_first_tail_x15_r0_body.cx1_135.mlx.nnext) = true
kernel_rfl PRE_first_tail_x15_r0_body.cabs0a135 : PRE_first_tail_x15_r0_body.cx0_135.mlx.arrs.get 0 = none
kernel_rfl PRE_first_tail_x15_r0_body.cabs0b135 : PRE_first_tail_x15_r0_body.cx0_135.mlx.objs.get 0 = none
kernel_rfl PRE_first_tail_x15_r0_body.ctok1135 : PRE_first_tail_x15_r0_body.cx1_135.mlx.tokens = []
kernel_rfl PRE_first_tail_x15_r0_body.cpend135 : PRE_first_tail_x15_r0_body.cx1_135.mlx.pending = PRE_first_tail_x15_r0_body.cx0_135.mlx.pending.map PRE_first_tail_x15_r0_body.kappa135.pend
kernel_rfl PRE_first_tail_x15_r0_body.cerrh135 : PRE_first_tail_x15_r0_body.cx1_135.mlx.errh = PRE_first_tail_x15_r0_body.cx0_135.mlx.errh.map PRE_first_tail_x15_r0_body.kappa135.arg
kernel_rfl PRE_first_tail_x15_r0_body.cfiles135 : PRE_first_tail_x15_r0_body.cx1_135.mlx.files = PRE_first_tail_x15_r0_body.cx0_135.mlx.files
kernel_rfl PRE_first_tail_x15_r0_body.carch135 : PRE_first_tail_x15_r0_body.cx1_135.mlx.arch = PRE_first_tail_x15_r0_body.cx0_135.mlx.arch
kernel_rfl PRE_first_tail_x15_r0_body.csizes135 : PRE_first_tail_x15_r0_body.cx1_135.mlx.deviceSizes = PRE_first_tail_x15_r0_body.cx0_135.mlx.deviceSizes
kernel_rfl PRE_first_tail_x15_r0_body.cwired135 : PRE_first_tail_x15_r0_body.cx1_135.mlx.wired = PRE_first_tail_x15_r0_body.cx0_135.mlx.wired
kernel_rfl PRE_first_tail_x15_r0_body.chost135 : PRE_first_tail_x15_r0_body.cx1_135.host = PRE_first_tail_x15_r0_body.cx0_135.host
-- the compaction map's addresses are `PRE_first_tail_x15_r0_body.kd135`'s
kernel_rfl PRE_first_tail_x15_r0_body.ckn0135 : PRE_first_tail_x15_r0_body.kd135.n0 = 2781297
kernel_rfl PRE_first_tail_x15_r0_body.ckn1135 : PRE_first_tail_x15_r0_body.kd135.n1 = 2782446
kernel_rfl PRE_first_tail_x15_r0_body.ckheap135 : (PTrie.keysA PRE_first_tail_x15_r0_body.kd135.heap).all (fun x => Nat.ble 2781291 x) = true
kernel_rfl PRE_first_tail_x15_r0_body.ckpl135 : (List.range 6).all (fun j => decide (PRE_first_tail_x15_r0_body.kd135.heap.get (2781291 + j) = nth? PRE_first_tail_x15_r0_body.pl135 j)) = true
-- the map fixes the call's names (`Conv.fixOld_compact`), the call's counters
kernel_rfl PRE_first_tail_x15_r0_body.fja135 : Nat.ble 2781291 2781291 = true
kernel_rfl PRE_first_tail_x15_r0_body.fn135 : Nat.ble 5855 5855 = true
kernel_rfl PRE_first_tail_x15_r0_body.fjaD135 : Nat.ble 2781291 PRE_first_tail_x15_r0_body.kd135.n0 = true
kernel_rfl PRE_first_tail_x15_r0_body.fxn135 : Nat.ble 20869 PRE_first_tail_x15_r0_body.kd135.nh0 = true
kernel_rfl PRE_first_tail_x15_r0_body.fnn135 : Nat.ble 17948 PRE_first_tail_x15_r0_body.kd135.nn0 = true
kernel_rfl PRE_first_tail_x15_r0_body.fxb135 : Nat.ble 20869 RData.bigHi = true
kernel_rfl PRE_first_tail_x15_r0_body.fheap135 : (PTrie.keysA PRE_first_tail_x15_r0_body.kd135.heap).all (Nat.ble (⟨20869, 17948, 2781291, 5855⟩ : Conv.Cnt).ja) = true
kernel_rfl PRE_first_tail_x15_r0_body.fhnd135 : (PTrie.keysA PRE_first_tail_x15_r0_body.kd135.hnd).all (Nat.ble (⟨20869, 17948, 2781291, 5855⟩ : Conv.Cnt).xn) = true
kernel_rfl PRE_first_tail_x15_r0_body.fnode135 : (PTrie.keysA PRE_first_tail_x15_r0_body.kd135.node).all (Nat.ble (⟨20869, 17948, 2781291, 5855⟩ : Conv.Cnt).nn) = true
/-- The compaction map fixes the call's names. -/
theorem PRE_first_tail_x15_r0_body.cfix135 : Conv.FixOld (⟨20869, 17948, 2781291, 5855⟩ : Conv.Cnt) PRE_first_tail_x15_r0_body.kappa135 :=
  Conv.fixOld_compact (Nat.le_of_ble_eq_true PRE_first_tail_x15_r0_body.fja135) (Nat.le_of_ble_eq_true PRE_first_tail_x15_r0_body.fn135) (Nat.le_of_ble_eq_true PRE_first_tail_x15_r0_body.fjaD135) (Nat.le_of_ble_eq_true PRE_first_tail_x15_r0_body.fxn135) (Nat.le_of_ble_eq_true PRE_first_tail_x15_r0_body.fnn135) (Nat.le_of_ble_eq_true PRE_first_tail_x15_r0_body.fxb135) PRE_first_tail_x15_r0_body.fheap135 PRE_first_tail_x15_r0_body.fhnd135 PRE_first_tail_x15_r0_body.fnode135
kernel_rfl PRE_first_tail_x15_r0_body.fcxn135 : (⟨20869, 17948, 2781291, 5855⟩ : Conv.Cnt).xn = (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1310.ffi).mlx.next
kernel_rfl PRE_first_tail_x15_r0_body.fcnn135 : (⟨20869, 17948, 2781291, 5855⟩ : Conv.Cnt).nn = (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1310.ffi).mlx.nnext
kernel_rfl PRE_first_tail_x15_r0_body.fle0135 : (Nat.ble (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1310.ffi).mlx.next PRE_first_tail_x15_r0_body.cx0_135.mlx.next && Nat.ble (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1310.ffi).mlx.nnext PRE_first_tail_x15_r0_body.cx0_135.mlx.nnext && Nat.ble (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1310.ffi).mlx.next RData.bigHi) = true
kernel_rfl PRE_first_tail_x15_r0_body.fnk135 : (PTrie.keysA PRE_first_tail_x15_r0_body.kd135.node).all (Nat.ble (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1310.ffi).mlx.nnext) = true
-- the merged state keeps the call's entries off the stage's footprint
kernel_rfl PRE_first_tail_x15_r0_body.f1A135 : PRE_first_tail_x15_r0_body.cx1_135.mlx.arrs = Stage.setAll (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1310.ffi).mlx.arrs (PRE_first_tail_x15_r0_body.cwS135.filterMap fun i => (PRE_first_tail_x15_r0_body.cx1_135.mlx.arrs.get i).map (i, ·))
kernel_rfl PRE_first_tail_x15_r0_body.f1O135 : PRE_first_tail_x15_r0_body.cx1_135.mlx.objs = Stage.setAll (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1310.ffi).mlx.objs (PRE_first_tail_x15_r0_body.cwS135.filterMap fun i => (PRE_first_tail_x15_r0_body.cx1_135.mlx.objs.get i).map (i, ·))
kernel_rfl PRE_first_tail_x15_r0_body.f1N135 : PRE_first_tail_x15_r0_body.cx1_135.mlx.nodes = Stage.setAll (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1310.ffi).mlx.nodes (PRE_first_tail_x15_r0_body.cnS135.filterMap fun i => (PRE_first_tail_x15_r0_body.cx1_135.mlx.nodes.get i).map (i, ·))
kernel_rfl PRE_first_tail_x15_r0_body.f1I135 : PRE_first_tail_x15_r0_body.cx1_135.mlx.items = Stage.setAll (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1310.ffi).mlx.items (PRE_first_tail_x15_r0_body.ciS135.filterMap fun i => (PRE_first_tail_x15_r0_body.cx1_135.mlx.items.get i).map (i, ·))
kernel_rfl PRE_first_tail_x15_r0_body.fbd135 : (PRE_first_tail_x15_r0_body.clo135 ++ PRE_first_tail_x15_r0_body.cln135 ++ PRE_first_tail_x15_r0_body.cli135 ++ PRE_first_tail_x15_r0_body.cwS135 ++ PRE_first_tail_x15_r0_body.cnS135 ++ PRE_first_tail_x15_r0_body.ciS135).all (fun i => Nat.blt (i / 4096) (4 ^ 31)) = true
kernel_rfl PRE_first_tail_x15_r0_body.fincW135 : PRE_first_tail_x15_r0_body.cwS135.all (fun h => !Nat.blt h (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1310.ffi).mlx.next || PRE_first_tail_x15_r0_body.clo135.contains h) = true
kernel_rfl PRE_first_tail_x15_r0_body.fincI135 : PRE_first_tail_x15_r0_body.ciS135.all (fun k => !Nat.blt k (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1310.ffi).mlx.nnext || PRE_first_tail_x15_r0_body.cli135.contains k) = true
kernel_rfl PRE_first_tail_x15_r0_body.fincN135 : PRE_first_tail_x15_r0_body.cnS135.all (Nat.ble (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1310.ffi).mlx.nnext) = true
kernel_rfl PRE_first_tail_x15_r0_body.flnF135 : PRE_first_tail_x15_r0_body.cln135.all (Nat.ble (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1310.ffi).mlx.nnext) = true
-- the checks over the changed lists
kernel_rfl PRE_first_tail_x15_r0_body.fh135 : PRE_first_tail_x15_r0_body.clo135.all (handleOK PRE_first_tail_x15_r0_body.kappa135 PRE_first_tail_x15_r0_body.P135.lo PRE_first_tail_x15_r0_body.cx0_135.mlx PRE_first_tail_x15_r0_body.cx1_135.mlx) = true
kernel_rfl PRE_first_tail_x15_r0_body.fo135 : PRE_first_tail_x15_r0_body.clo135.map (fun h => PRE_first_tail_x15_r0_body.cx1_135.mlx.objs.get (PRE_first_tail_x15_r0_body.kappa135.handle h)) = PRE_first_tail_x15_r0_body.clo135.map (fun h => (PRE_first_tail_x15_r0_body.cx0_135.mlx.objs.get h).map PRE_first_tail_x15_r0_body.kappa135.nobj)
kernel_rfl PRE_first_tail_x15_r0_body.fok135 : PRE_first_tail_x15_r0_body.clo135.all (objOK PRE_first_tail_x15_r0_body.kappa135 PRE_first_tail_x15_r0_body.P135.NL PRE_first_tail_x15_r0_body.cx0_135.mlx) = true
kernel_rfl PRE_first_tail_x15_r0_body.fnd135 : PRE_first_tail_x15_r0_body.cln135.all (nodeOKF PRE_first_tail_x15_r0_body.kappa135 PRE_first_tail_x15_r0_body.P135 PRE_first_tail_x15_r0_body.cx0_135.mlx PRE_first_tail_x15_r0_body.cx1_135.mlx) = true
kernel_rfl PRE_first_tail_x15_r0_body.fp135 : ((PRE_first_tail_x15_r0_body.cln135.filter (fullB PRE_first_tail_x15_r0_body.P135))).map (fun i => (PRE_first_tail_x15_r0_body.cx1_135.mlx.nodes.get (PRE_first_tail_x15_r0_body.kappa135.node i)).map Host.Mlx.Ffi.Node.prim) =
  ((PRE_first_tail_x15_r0_body.cln135.filter (fullB PRE_first_tail_x15_r0_body.P135))).map (fun i => (PRE_first_tail_x15_r0_body.cx0_135.mlx.nodes.get i).map fun nd => PRE_first_tail_x15_r0_body.kappa135.prim nd.prim)
kernel_rfl PRE_first_tail_x15_r0_body.fnordI135 : incrB PRE_first_tail_x15_r0_body.kd135.nodeF (List.range' 17948 27) = true
kernel_rfl PRE_first_tail_x15_r0_body.fnordK135 : (PTrie.keysA PRE_first_tail_x15_r0_body.kd135.node).all (fun k => Nat.ble 17948 k && Nat.blt k 17975) = true
kernel_rfl PRE_first_tail_x15_r0_body.fnordL135 : (PRE_first_tail_x15_r0_body.cln135.filter (Nat.ble PRE_first_tail_x15_r0_body.P135.N0)).all (fun i => Nat.ble i (PRE_first_tail_x15_r0_body.kd135.nodeF i) && (Nat.blt i 17975 || Nat.ble PRE_first_tail_x15_r0_body.kd135.nn0 i)) = true
theorem PRE_first_tail_x15_r0_body.fnord135 : (PRE_first_tail_x15_r0_body.cln135.filter (Nat.ble PRE_first_tail_x15_r0_body.P135.N0)).all (fun i => Nat.ble i (PRE_first_tail_x15_r0_body.kd135.nodeF i) &&
    (PTrie.keysA PRE_first_tail_x15_r0_body.kd135.node).all fun j => !Nat.blt j i || Nat.blt (PRE_first_tail_x15_r0_body.kd135.nodeF j) (PRE_first_tail_x15_r0_body.kd135.nodeF i)) = true :=
  cnord_of PRE_first_tail_x15_r0_body.cnlow135 PRE_first_tail_x15_r0_body.cnn1135 PRE_first_tail_x15_r0_body.fnordI135 PRE_first_tail_x15_r0_body.fnordK135 PRE_first_tail_x15_r0_body.fnordL135
kernel_rfl PRE_first_tail_x15_r0_body.fi135 : PRE_first_tail_x15_r0_body.cli135.all (pnB PRE_first_tail_x15_r0_body.cx0_135.mlx) = true
kernel_rfl PRE_first_tail_x15_r0_body.fii135 : PRE_first_tail_x15_r0_body.cli135.all (fun k => decide (PRE_first_tail_x15_r0_body.cx1_135.mlx.items.get (PRE_first_tail_x15_r0_body.kappa135.node k) = (PRE_first_tail_x15_r0_body.cx0_135.mlx.items.get k).map PRE_first_tail_x15_r0_body.kappa135.nv)) = true
/-- **The compaction's footprint.** -/
theorem PRE_first_tail_x15_r0_body.cfoot135 (clean : Conv.NClean (⟨20869, 17948, 2781291, 5855⟩ : Conv.Cnt) (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1310.ffi).mlx) (hltC : ∀ h, PH (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1310.ffi).mlx h → h < (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1310.ffi).mlx.next) (nltC : ∀ i, PN (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1310.ffi).mlx i → i < (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1310.ffi).mlx.nnext) (itemsC : ∀ k v, (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1310.ffi).mlx.items.get k = some v → PN (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1310.ffi).mlx k) (tracedC : ∀ h o, (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1310.ffi).mlx.objs.get h = some o → ∀ i ∈ objTraces o, i < PRE_first_tail_x15_r0_body.P135.NL) (cl : SSt (· < 5873) PRE_first_tail_x15_r0_body.cx0_135.mlx) :
    Conv.MFoot PRE_first_tail_x15_r0_body.P135 5873 PRE_first_tail_x15_r0_body.kappa135 PRE_first_tail_x15_r0_body.kd135 PRE_first_tail_x15_r0_body.khinv135 PRE_first_tail_x15_r0_body.kninv135 (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1310.ffi).mlx PRE_first_tail_x15_r0_body.cx0_135.mlx PRE_first_tail_x15_r0_body.cx1_135.mlx (⟨20869, 17948, 2781291, 5855⟩ : Conv.Cnt) PRE_first_tail_x15_r0_body.clo135 PRE_first_tail_x15_r0_body.cln135 PRE_first_tail_x15_r0_body.cli135 PRE_first_tail_x15_r0_body.cwS135 PRE_first_tail_x15_r0_body.cnS135 PRE_first_tail_x15_r0_body.ciS135 :=
  ⟨rfl, rfl, rfl, PRE_first_tail_x15_r0_body.cnh0135, PRE_first_tail_x15_r0_body.cnh1135, PRE_first_tail_x15_r0_body.cnn0135, PRE_first_tail_x15_r0_body.cnn1135, PRE_first_tail_x15_r0_body.cplo135, PRE_first_tail_x15_r0_body.ccnt135, PRE_first_tail_x15_r0_body.cnband135, PRE_first_tail_x15_r0_body.chbelow135, PRE_first_tail_x15_r0_body.chren135, PRE_first_tail_x15_r0_body.cband135, PRE_first_tail_x15_r0_body.cnh1pos135, PRE_first_tail_x15_r0_body.cnren135, PRE_first_tail_x15_r0_body.cnlow135, PRE_first_tail_x15_r0_body.cabs0a135, PRE_first_tail_x15_r0_body.cabs0b135, PRE_first_tail_x15_r0_body.ctok1135, PRE_first_tail_x15_r0_body.cpend135, PRE_first_tail_x15_r0_body.cerrh135, PRE_first_tail_x15_r0_body.cfiles135, PRE_first_tail_x15_r0_body.carch135, PRE_first_tail_x15_r0_body.csizes135, PRE_first_tail_x15_r0_body.cwired135, PRE_first_tail_x15_r0_body.cfix135, clean, PRE_first_tail_x15_r0_body.fcxn135, PRE_first_tail_x15_r0_body.fcnn135, hltC, nltC, itemsC, tracedC, cl, PRE_first_tail_x15_r0_body.fle0135, PRE_first_tail_x15_r0_body.fnk135, PRE_first_tail_x15_r0_body.ckA135, PRE_first_tail_x15_r0_body.cobjsK135, PRE_first_tail_x15_r0_body.cnodesK135, PRE_first_tail_x15_r0_body.citemsK135, PRE_first_tail_x15_r0_body.f1A135, PRE_first_tail_x15_r0_body.f1O135, PRE_first_tail_x15_r0_body.f1N135, PRE_first_tail_x15_r0_body.f1I135, PRE_first_tail_x15_r0_body.fbd135, PRE_first_tail_x15_r0_body.fincW135, PRE_first_tail_x15_r0_body.fincI135, PRE_first_tail_x15_r0_body.fincN135, PRE_first_tail_x15_r0_body.flnF135, PRE_first_tail_x15_r0_body.fh135, PRE_first_tail_x15_r0_body.fo135, PRE_first_tail_x15_r0_body.fok135, PRE_first_tail_x15_r0_body.fnd135, PRE_first_tail_x15_r0_body.fp135, PRE_first_tail_x15_r0_body.fnord135, PRE_first_tail_x15_r0_body.fi135, PRE_first_tail_x15_r0_body.fii135⟩
theorem PRE_first_tail_x15_r0_body.cnshift135 (clean : Conv.NClean (⟨20869, 17948, 2781291, 5855⟩ : Conv.Cnt) (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1310.ffi).mlx) (hltC : ∀ h, PH (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1310.ffi).mlx h → h < (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1310.ffi).mlx.next) (nltC : ∀ i, PN (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1310.ffi).mlx i → i < (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1310.ffi).mlx.nnext) (itemsC : ∀ k v, (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1310.ffi).mlx.items.get k = some v → PN (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1310.ffi).mlx k) (tracedC : ∀ h o, (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1310.ffi).mlx.objs.get h = some o → ∀ i ∈ objTraces o, i < PRE_first_tail_x15_r0_body.P135.NL) (cl : SSt (· < 5873) PRE_first_tail_x15_r0_body.cx0_135.mlx) : NShift PRE_first_tail_x15_r0_body.P135 5873 PRE_first_tail_x15_r0_body.kappa135 PRE_first_tail_x15_r0_body.cx0_135 PRE_first_tail_x15_r0_body.cx1_135 :=
  Conv.nshift_of_foot (PRE_first_tail_x15_r0_body.cfoot135 clean hltC nltC itemsC tracedC cl) PRE_first_tail_x15_r0_body.chost135 (compact_a_eq PRE_first_tail_x15_r0_body.ckn0135 PRE_first_tail_x15_r0_body.ckn1135 PRE_first_tail_x15_r0_body.ckheap135 PRE_first_tail_x15_r0_body.ckpl135)

-- the observers: the layers' states at the call, the canonical and the merged state, their footprints and checks
noncomputable def PRE_first_tail_x15_r0_body.fxC_135 : PTrie Unit := (Host.Ts.Sim.Full.freedOf PRE_first_tail_x15_r0_body.s1310.ffi).getD PTrie.nil
noncomputable def PRE_first_tail_x15_r0_body.krC_135 : Host.Load.Layers.KRec := (Host.Ts.Sim.Full.krecOf PRE_first_tail_x15_r0_body.s1310.ffi).getD Host.Load.Layers.KRec.empty
kernel_rfl PRE_first_tail_x15_r0_body.ofxC_135 : (Host.Ts.Sim.Full.freedOf PRE_first_tail_x15_r0_body.s1310.ffi) = some PRE_first_tail_x15_r0_body.fxC_135
kernel_rfl PRE_first_tail_x15_r0_body.okrC_135 : (Host.Ts.Sim.Full.krecOf PRE_first_tail_x15_r0_body.s1310.ffi) = some PRE_first_tail_x15_r0_body.krC_135
noncomputable def PRE_first_tail_x15_r0_body.fx0_135 : PTrie Unit := (Host.Ts.Sim.Full.freedOf PRE_first_tail_x15_r0_body.s1312.ffi).getD PTrie.nil
noncomputable def PRE_first_tail_x15_r0_body.kr0_135 : Host.Load.Layers.KRec := (Host.Ts.Sim.Full.krecOf PRE_first_tail_x15_r0_body.s1312.ffi).getD Host.Load.Layers.KRec.empty
kernel_rfl PRE_first_tail_x15_r0_body.ofx0_135 : (Host.Ts.Sim.Full.freedOf PRE_first_tail_x15_r0_body.s1312.ffi) = some PRE_first_tail_x15_r0_body.fx0_135
kernel_rfl PRE_first_tail_x15_r0_body.okr0_135 : (Host.Ts.Sim.Full.krecOf PRE_first_tail_x15_r0_body.s1312.ffi) = some PRE_first_tail_x15_r0_body.kr0_135
noncomputable def PRE_first_tail_x15_r0_body.fx1_135 : PTrie Unit := (Host.Ts.Sim.Full.freedOf PRE_first_tail_x15_r0_body.s1311.ffi).getD PTrie.nil
noncomputable def PRE_first_tail_x15_r0_body.kr1_135 : Host.Load.Layers.KRec := (Host.Ts.Sim.Full.krecOf PRE_first_tail_x15_r0_body.s1311.ffi).getD Host.Load.Layers.KRec.empty
kernel_rfl PRE_first_tail_x15_r0_body.ofx1_135 : (Host.Ts.Sim.Full.freedOf PRE_first_tail_x15_r0_body.s1311.ffi) = some PRE_first_tail_x15_r0_body.fx1_135
kernel_rfl PRE_first_tail_x15_r0_body.okr1_135 : (Host.Ts.Sim.Full.krecOf PRE_first_tail_x15_r0_body.s1311.ffi) = some PRE_first_tail_x15_r0_body.kr1_135
kernel_rfl PRE_first_tail_x15_r0_body.ff0135 : PRE_first_tail_x15_r0_body.fx0_135 = Stage.setAll PRE_first_tail_x15_r0_body.fxC_135 (PRE_first_tail_x15_r0_body.clo135.filterMap fun i => (PRE_first_tail_x15_r0_body.fx0_135.get i).map (i, ·))
kernel_rfl PRE_first_tail_x15_r0_body.ff1135 : PRE_first_tail_x15_r0_body.fx1_135 = Stage.setAll PRE_first_tail_x15_r0_body.fxC_135 (PRE_first_tail_x15_r0_body.cwS135.filterMap fun i => (PRE_first_tail_x15_r0_body.fx1_135.get i).map (i, ·))
kernel_rfl PRE_first_tail_x15_r0_body.ffck135 : freedLB PRE_first_tail_x15_r0_body.kappa135 PRE_first_tail_x15_r0_body.cx0_135.mlx PRE_first_tail_x15_r0_body.fx0_135 PRE_first_tail_x15_r0_body.fx1_135 PRE_first_tail_x15_r0_body.clo135 = true
kernel_rfl PRE_first_tail_x15_r0_body.fkf0135 : PRE_first_tail_x15_r0_body.kr0_135.flags = Stage.setAll PRE_first_tail_x15_r0_body.krC_135.flags (PRE_first_tail_x15_r0_body.clo135.filterMap fun i => (PRE_first_tail_x15_r0_body.kr0_135.flags.get i).map (i, ·))
kernel_rfl PRE_first_tail_x15_r0_body.fkt0135 : PRE_first_tail_x15_r0_body.kr0_135.targs = Stage.setAll PRE_first_tail_x15_r0_body.krC_135.targs (PRE_first_tail_x15_r0_body.clo135.filterMap fun i => (PRE_first_tail_x15_r0_body.kr0_135.targs.get i).map (i, ·))
kernel_rfl PRE_first_tail_x15_r0_body.fkf1135 : PRE_first_tail_x15_r0_body.kr1_135.flags = Stage.setAll PRE_first_tail_x15_r0_body.krC_135.flags (PRE_first_tail_x15_r0_body.cwS135.filterMap fun i => (PRE_first_tail_x15_r0_body.kr1_135.flags.get i).map (i, ·))
kernel_rfl PRE_first_tail_x15_r0_body.fkt1135 : PRE_first_tail_x15_r0_body.kr1_135.targs = Stage.setAll PRE_first_tail_x15_r0_body.krC_135.targs (PRE_first_tail_x15_r0_body.cwS135.filterMap fun i => (PRE_first_tail_x15_r0_body.kr1_135.targs.get i).map (i, ·))
kernel_rfl PRE_first_tail_x15_r0_body.fkck135 : krecLB PRE_first_tail_x15_r0_body.kappa135 5873 PRE_first_tail_x15_r0_body.cx0_135.mlx PRE_first_tail_x15_r0_body.kr0_135 PRE_first_tail_x15_r0_body.kr1_135 PRE_first_tail_x15_r0_body.clo135 = true
kernel_rfl PRE_first_tail_x15_r0_body.fkn135 : Nat.ble 5855 5873 = true
-- the bridge and the pending traces' regions
kernel_rfl PRE_first_tail_x15_r0_body.cbridge135 : Host.Ts.Sim.Full.bridgeOf PRE_first_tail_x15_r0_body.s1311.ffi = Host.Ts.Sim.Full.bridgeOf PRE_first_tail_x15_r0_body.s1312.ffi
kernel_rfl PRE_first_tail_x15_r0_body.cpendR135 : pendRegB PRE_first_tail_x15_r0_body.kappa135 (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1312.ffi).mlx = true
kernel_rfl PRE_first_tail_x15_r0_body.cpendLe135 : Nat.ble (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1312.ffi).mlx.next (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1311.ffi).mlx.next = true
/-- **The compaction's native shift**, given the call's bookkeeping, its relation's facts (the model's and the
observers') and the canonical closedness. -/
theorem PRE_first_tail_x15_r0_body.cshift135 (clean : Conv.NClean (⟨20869, 17948, 2781291, 5855⟩ : Conv.Cnt) (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1310.ffi).mlx) (hltC : ∀ h, PH (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1310.ffi).mlx h → h < (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1310.ffi).mlx.next) (nltC : ∀ i, PN (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1310.ffi).mlx i → i < (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1310.ffi).mlx.nnext) (itemsC : ∀ k v, (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1310.ffi).mlx.items.get k = some v → PN (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1310.ffi).mlx k) (tracedC : ∀ h o, (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1310.ffi).mlx.objs.get h = some o → ∀ i ∈ objTraces o, i < PRE_first_tail_x15_r0_body.P135.NL) (cl : SSt (· < 5873) PRE_first_tail_x15_r0_body.cx0_135.mlx)
    (hobjC : ∀ h, PRE_first_tail_x15_r0_body.fxC_135.get h = some () → ((Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1310.ffi).mlx.objs.get h).isSome = true)
    (hfC : ∀ h, (PRE_first_tail_x15_r0_body.krC_135.flags.get h).isSome = true → ((Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1310.ffi).mlx.objs.get h).isSome = true)
    (htC : ∀ h, (PRE_first_tail_x15_r0_body.krC_135.targs.get h).isSome = true → ((Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1310.ffi).mlx.objs.get h).isSome = true)
    (hclC : ∀ h l, PRE_first_tail_x15_r0_body.krC_135.targs.get h = some l → Host.Ts.Sim.Full.STargs (· < (⟨20869, 17948, 2781291, 5855⟩ : Conv.Cnt).n) l) :
    Conv.FullShiftQ PRE_first_tail_x15_r0_body.P135 5873 PRE_first_tail_x15_r0_body.kappa135 PRE_first_tail_x15_r0_body.s1312.ffi PRE_first_tail_x15_r0_body.s1311.ffi :=
  ⟨PRE_first_tail_x15_r0_body.cnshift135 clean hltC nltC itemsC tracedC cl, PRE_first_tail_x15_r0_body.cqueue135, fun t ht => bSN_sound (List.all_eq_true.mp PRE_first_tail_x15_r0_body.ctokSupp135 t ht),
    PRE_first_tail_x15_r0_body.cbridge135,
    liveShift_foot (x0' := Host.Ts.Sim.Full.mlxOf PRE_first_tail_x15_r0_body.s1312.ffi) (x1' := Host.Ts.Sim.Full.mlxOf PRE_first_tail_x15_r0_body.s1311.ffi) (PRE_first_tail_x15_r0_body.cfoot135 clean hltC nltC itemsC tracedC cl) rfl PRE_first_tail_x15_r0_body.ofx0_135 PRE_first_tail_x15_r0_body.ofx1_135 hobjC PRE_first_tail_x15_r0_body.ff0135 PRE_first_tail_x15_r0_body.ff1135 PRE_first_tail_x15_r0_body.ffck135,
    kernShift_foot (x0' := Host.Ts.Sim.Full.mlxOf PRE_first_tail_x15_r0_body.s1312.ffi) (x1' := Host.Ts.Sim.Full.mlxOf PRE_first_tail_x15_r0_body.s1311.ffi) (PRE_first_tail_x15_r0_body.cfoot135 clean hltC nltC itemsC tracedC cl) rfl PRE_first_tail_x15_r0_body.okr0_135 PRE_first_tail_x15_r0_body.okr1_135 (Nat.le_of_ble_eq_true PRE_first_tail_x15_r0_body.fkn135) hfC htC hclC
      PRE_first_tail_x15_r0_body.fkf0135 PRE_first_tail_x15_r0_body.fkt0135 PRE_first_tail_x15_r0_body.fkf1135 PRE_first_tail_x15_r0_body.fkt1135 PRE_first_tail_x15_r0_body.fkck135,
    pendReg_of rfl PRE_first_tail_x15_r0_body.cnh0135 PRE_first_tail_x15_r0_body.cnh1135 (Nat.le_of_ble_eq_true PRE_first_tail_x15_r0_body.cpendLe135) PRE_first_tail_x15_r0_body.cpendR135⟩

end Host.Load.Run.Tpl
