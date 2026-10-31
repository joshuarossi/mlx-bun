import host.sim.template.a4pre_first_tail_x15_r0_body.SiteCl144
import host.sim.conv.CompactFull
import host.sim.template.FootGen
set_option Elab.async false
namespace Host.Load.Run.Tpl
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
open Host.Ts Host.Ts.Sim Host.Ts.Sim.Template

/-! The compaction's native shift at call site 144 from its footprint (`Conv.nshift_of_foot`), and the observers'
(`liveShift_foot`, `kernShift_foot`): `Conv.FullShiftQ` for `Conv.full_compactQ`, given the call's bookkeeping and its
relation's facts. -/

/-- The load parameters of the chain (band-free: its start's node counter as `NL` and `N0`). -/
def PRE_first_tail_x15_r0_body.Pc144 : LoadP := ⟨18151, 131072, 1099511627776, 15235, 15235, []⟩
/-- The site's band raised to the map's checked fixed-node prefix, including newly recorded closure traces. -/
def PRE_first_tail_x15_r0_body.P144 : LoadP := PRE_first_tail_x15_r0_body.Pc144.raise 18149
kernel_rfl PRE_first_tail_x15_r0_body.craise144 : Nat.ble PRE_first_tail_x15_r0_body.Pc144.N0 18149 = true
theorem PRE_first_tail_x15_r0_body.raised144 : Host.Ts.Sim.Full.Raised PRE_first_tail_x15_r0_body.Pc144 PRE_first_tail_x15_r0_body.P144 :=
  .inr ⟨18149, rfl, Nat.le_of_ble_eq_true PRE_first_tail_x15_r0_body.craise144, rfl⟩
noncomputable abbrev PRE_first_tail_x15_r0_body.cx0_144 : Host.Load.LSt := clearTokens (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1398.ffi)
noncomputable abbrev PRE_first_tail_x15_r0_body.cx1_144 : Host.Load.LSt := clearTokens (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1397.ffi)
def PRE_first_tail_x15_r0_body.khinv144 : PTrie Nat := Stage.setAll PTrie.nil [(21074, 21048), (21052, 21049), (21075, 21050)]
def PRE_first_tail_x15_r0_body.kninv144 : PTrie Nat := Stage.setAll PTrie.nil [(18122, 18122), (18123, 18123), (18124, 18124), (18125, 18125), (18126, 18126), (18127, 18127), (18128, 18128), (18129, 18129), (18130, 18130), (18131, 18131), (18132, 18132), (18133, 18133), (18134, 18134), (18135, 18135), (18136, 18136), (18137, 18137), (18138, 18138), (18139, 18139), (18140, 18140), (18141, 18141), (18142, 18142), (18143, 18143), (18144, 18144), (18145, 18145), (18146, 18146), (18147, 18147), (18148, 18148)]
/-- The stage's footprint: its written and fresh handles, fresh nodes, written and fresh items. -/
def PRE_first_tail_x15_r0_body.cwS144 : List Nat := [21028, 21041, 21047, 21048, 21049, 21050, 21051, 21052, 21053, 21054, 21055, 21056, 21057, 21058, 21059, 21060, 21061, 21062, 21063, 21064, 21065, 21066, 21067, 21068, 21069, 21070, 21071, 21072, 21073, 21074, 21075]
def PRE_first_tail_x15_r0_body.cnS144 : List Nat := List.range' 18122 27
def PRE_first_tail_x15_r0_body.ciS144 : List Nat := [] ++ List.range' 18122 27

-- the small checks (`MChecks`'s)
kernel_rfl PRE_first_tail_x15_r0_body.cnh0144 : PRE_first_tail_x15_r0_body.kd144.nh0 = PRE_first_tail_x15_r0_body.cx0_144.mlx.next
kernel_rfl PRE_first_tail_x15_r0_body.cnh1144 : PRE_first_tail_x15_r0_body.kd144.nh1 = PRE_first_tail_x15_r0_body.cx1_144.mlx.next
kernel_rfl PRE_first_tail_x15_r0_body.cnn0144 : PRE_first_tail_x15_r0_body.kd144.nn0 = PRE_first_tail_x15_r0_body.cx0_144.mlx.nnext
kernel_rfl PRE_first_tail_x15_r0_body.cnn1144 : PRE_first_tail_x15_r0_body.kd144.nn1 = PRE_first_tail_x15_r0_body.cx1_144.mlx.nnext
kernel_rfl PRE_first_tail_x15_r0_body.cplo144 : (Nat.blt 0 PRE_first_tail_x15_r0_body.P144.lo && Nat.ble PRE_first_tail_x15_r0_body.P144.lo PRE_first_tail_x15_r0_body.cx0_144.mlx.next && Nat.ble PRE_first_tail_x15_r0_body.P144.lo RData.bigHi && Nat.ble RData.bigHi PRE_first_tail_x15_r0_body.P144.E) = true
kernel_rfl PRE_first_tail_x15_r0_body.ccnt144 : (Nat.ble PRE_first_tail_x15_r0_body.cx0_144.mlx.next PRE_first_tail_x15_r0_body.cx1_144.mlx.next && Nat.ble PRE_first_tail_x15_r0_body.cx0_144.mlx.nnext PRE_first_tail_x15_r0_body.cx1_144.mlx.nnext) = true
kernel_rfl PRE_first_tail_x15_r0_body.cnband144 : (Nat.blt 0 PRE_first_tail_x15_r0_body.P144.NL && Nat.ble PRE_first_tail_x15_r0_body.P144.NL PRE_first_tail_x15_r0_body.P144.N0 && Nat.ble PRE_first_tail_x15_r0_body.P144.N0 PRE_first_tail_x15_r0_body.cx0_144.mlx.nnext) = true
kernel_rfl PRE_first_tail_x15_r0_body.chbelow144 : PRE_first_tail_x15_r0_body.kd144.checkHndBelow = true
kernel_rfl PRE_first_tail_x15_r0_body.chren144 : checkRenG PRE_first_tail_x15_r0_body.kd144.hnd PRE_first_tail_x15_r0_body.khinv144 (phB PRE_first_tail_x15_r0_body.cx0_144.mlx) = true
kernel_rfl PRE_first_tail_x15_r0_body.cband144 : PRE_first_tail_x15_r0_body.kd144.checkBand PRE_first_tail_x15_r0_body.P144.lo = true
kernel_rfl PRE_first_tail_x15_r0_body.cnh1pos144 : Nat.blt 0 PRE_first_tail_x15_r0_body.kd144.nh1 = true
kernel_rfl PRE_first_tail_x15_r0_body.cnren144 : checkRenG PRE_first_tail_x15_r0_body.kd144.node PRE_first_tail_x15_r0_body.kninv144 (pnB PRE_first_tail_x15_r0_body.cx0_144.mlx) = true
kernel_rfl PRE_first_tail_x15_r0_body.cnlow144 : (PTrie.keysA PRE_first_tail_x15_r0_body.kd144.node).all (fun j => Nat.ble PRE_first_tail_x15_r0_body.P144.NL j && Nat.blt (PRE_first_tail_x15_r0_body.kd144.nodeF j) PRE_first_tail_x15_r0_body.cx1_144.mlx.nnext) = true
kernel_rfl PRE_first_tail_x15_r0_body.cabs0a144 : PRE_first_tail_x15_r0_body.cx0_144.mlx.arrs.get 0 = none
kernel_rfl PRE_first_tail_x15_r0_body.cabs0b144 : PRE_first_tail_x15_r0_body.cx0_144.mlx.objs.get 0 = none
kernel_rfl PRE_first_tail_x15_r0_body.ctok1144 : PRE_first_tail_x15_r0_body.cx1_144.mlx.tokens = []
kernel_rfl PRE_first_tail_x15_r0_body.cpend144 : PRE_first_tail_x15_r0_body.cx1_144.mlx.pending = PRE_first_tail_x15_r0_body.cx0_144.mlx.pending.map PRE_first_tail_x15_r0_body.kappa144.pend
kernel_rfl PRE_first_tail_x15_r0_body.cerrh144 : PRE_first_tail_x15_r0_body.cx1_144.mlx.errh = PRE_first_tail_x15_r0_body.cx0_144.mlx.errh.map PRE_first_tail_x15_r0_body.kappa144.arg
kernel_rfl PRE_first_tail_x15_r0_body.cfiles144 : PRE_first_tail_x15_r0_body.cx1_144.mlx.files = PRE_first_tail_x15_r0_body.cx0_144.mlx.files
kernel_rfl PRE_first_tail_x15_r0_body.carch144 : PRE_first_tail_x15_r0_body.cx1_144.mlx.arch = PRE_first_tail_x15_r0_body.cx0_144.mlx.arch
kernel_rfl PRE_first_tail_x15_r0_body.csizes144 : PRE_first_tail_x15_r0_body.cx1_144.mlx.deviceSizes = PRE_first_tail_x15_r0_body.cx0_144.mlx.deviceSizes
kernel_rfl PRE_first_tail_x15_r0_body.cwired144 : PRE_first_tail_x15_r0_body.cx1_144.mlx.wired = PRE_first_tail_x15_r0_body.cx0_144.mlx.wired
kernel_rfl PRE_first_tail_x15_r0_body.chost144 : PRE_first_tail_x15_r0_body.cx1_144.host = PRE_first_tail_x15_r0_body.cx0_144.host
-- the compaction map's addresses are `PRE_first_tail_x15_r0_body.kd144`'s
kernel_rfl PRE_first_tail_x15_r0_body.ckn0144 : PRE_first_tail_x15_r0_body.kd144.n0 = 2788465
kernel_rfl PRE_first_tail_x15_r0_body.ckn1144 : PRE_first_tail_x15_r0_body.kd144.n1 = 2789614
kernel_rfl PRE_first_tail_x15_r0_body.ckheap144 : (PTrie.keysA PRE_first_tail_x15_r0_body.kd144.heap).all (fun x => Nat.ble 2788459 x) = true
kernel_rfl PRE_first_tail_x15_r0_body.ckpl144 : (List.range 6).all (fun j => decide (PRE_first_tail_x15_r0_body.kd144.heap.get (2788459 + j) = nth? PRE_first_tail_x15_r0_body.pl144 j)) = true
-- the map fixes the call's names (`Conv.fixOld_compact`), the call's counters
kernel_rfl PRE_first_tail_x15_r0_body.fja144 : Nat.ble 2788459 2788459 = true
kernel_rfl PRE_first_tail_x15_r0_body.fn144 : Nat.ble 6239 6239 = true
kernel_rfl PRE_first_tail_x15_r0_body.fjaD144 : Nat.ble 2788459 PRE_first_tail_x15_r0_body.kd144.n0 = true
kernel_rfl PRE_first_tail_x15_r0_body.fxn144 : Nat.ble 21048 PRE_first_tail_x15_r0_body.kd144.nh0 = true
kernel_rfl PRE_first_tail_x15_r0_body.fnn144 : Nat.ble 18122 PRE_first_tail_x15_r0_body.kd144.nn0 = true
kernel_rfl PRE_first_tail_x15_r0_body.fxb144 : Nat.ble 21048 RData.bigHi = true
kernel_rfl PRE_first_tail_x15_r0_body.fheap144 : (PTrie.keysA PRE_first_tail_x15_r0_body.kd144.heap).all (Nat.ble (⟨21048, 18122, 2788459, 6239⟩ : Conv.Cnt).ja) = true
kernel_rfl PRE_first_tail_x15_r0_body.fhnd144 : (PTrie.keysA PRE_first_tail_x15_r0_body.kd144.hnd).all (Nat.ble (⟨21048, 18122, 2788459, 6239⟩ : Conv.Cnt).xn) = true
kernel_rfl PRE_first_tail_x15_r0_body.fnode144 : (PTrie.keysA PRE_first_tail_x15_r0_body.kd144.node).all (Nat.ble (⟨21048, 18122, 2788459, 6239⟩ : Conv.Cnt).nn) = true
/-- The compaction map fixes the call's names. -/
theorem PRE_first_tail_x15_r0_body.cfix144 : Conv.FixOld (⟨21048, 18122, 2788459, 6239⟩ : Conv.Cnt) PRE_first_tail_x15_r0_body.kappa144 :=
  Conv.fixOld_compact (Nat.le_of_ble_eq_true PRE_first_tail_x15_r0_body.fja144) (Nat.le_of_ble_eq_true PRE_first_tail_x15_r0_body.fn144) (Nat.le_of_ble_eq_true PRE_first_tail_x15_r0_body.fjaD144) (Nat.le_of_ble_eq_true PRE_first_tail_x15_r0_body.fxn144) (Nat.le_of_ble_eq_true PRE_first_tail_x15_r0_body.fnn144) (Nat.le_of_ble_eq_true PRE_first_tail_x15_r0_body.fxb144) PRE_first_tail_x15_r0_body.fheap144 PRE_first_tail_x15_r0_body.fhnd144 PRE_first_tail_x15_r0_body.fnode144
kernel_rfl PRE_first_tail_x15_r0_body.fcxn144 : (⟨21048, 18122, 2788459, 6239⟩ : Conv.Cnt).xn = (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1396.ffi).mlx.next
kernel_rfl PRE_first_tail_x15_r0_body.fcnn144 : (⟨21048, 18122, 2788459, 6239⟩ : Conv.Cnt).nn = (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1396.ffi).mlx.nnext
kernel_rfl PRE_first_tail_x15_r0_body.fle0144 : (Nat.ble (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1396.ffi).mlx.next PRE_first_tail_x15_r0_body.cx0_144.mlx.next && Nat.ble (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1396.ffi).mlx.nnext PRE_first_tail_x15_r0_body.cx0_144.mlx.nnext && Nat.ble (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1396.ffi).mlx.next RData.bigHi) = true
kernel_rfl PRE_first_tail_x15_r0_body.fnk144 : (PTrie.keysA PRE_first_tail_x15_r0_body.kd144.node).all (Nat.ble (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1396.ffi).mlx.nnext) = true
-- the merged state keeps the call's entries off the stage's footprint
kernel_rfl PRE_first_tail_x15_r0_body.f1A144 : PRE_first_tail_x15_r0_body.cx1_144.mlx.arrs = Stage.setAll (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1396.ffi).mlx.arrs (PRE_first_tail_x15_r0_body.cwS144.filterMap fun i => (PRE_first_tail_x15_r0_body.cx1_144.mlx.arrs.get i).map (i, ·))
kernel_rfl PRE_first_tail_x15_r0_body.f1O144 : PRE_first_tail_x15_r0_body.cx1_144.mlx.objs = Stage.setAll (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1396.ffi).mlx.objs (PRE_first_tail_x15_r0_body.cwS144.filterMap fun i => (PRE_first_tail_x15_r0_body.cx1_144.mlx.objs.get i).map (i, ·))
kernel_rfl PRE_first_tail_x15_r0_body.f1N144 : PRE_first_tail_x15_r0_body.cx1_144.mlx.nodes = Stage.setAll (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1396.ffi).mlx.nodes (PRE_first_tail_x15_r0_body.cnS144.filterMap fun i => (PRE_first_tail_x15_r0_body.cx1_144.mlx.nodes.get i).map (i, ·))
kernel_rfl PRE_first_tail_x15_r0_body.f1I144 : PRE_first_tail_x15_r0_body.cx1_144.mlx.items = Stage.setAll (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1396.ffi).mlx.items (PRE_first_tail_x15_r0_body.ciS144.filterMap fun i => (PRE_first_tail_x15_r0_body.cx1_144.mlx.items.get i).map (i, ·))
kernel_rfl PRE_first_tail_x15_r0_body.fbd144 : (PRE_first_tail_x15_r0_body.clo144 ++ PRE_first_tail_x15_r0_body.cln144 ++ PRE_first_tail_x15_r0_body.cli144 ++ PRE_first_tail_x15_r0_body.cwS144 ++ PRE_first_tail_x15_r0_body.cnS144 ++ PRE_first_tail_x15_r0_body.ciS144).all (fun i => Nat.blt (i / 4096) (4 ^ 31)) = true
kernel_rfl PRE_first_tail_x15_r0_body.fincW144 : PRE_first_tail_x15_r0_body.cwS144.all (fun h => !Nat.blt h (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1396.ffi).mlx.next || PRE_first_tail_x15_r0_body.clo144.contains h) = true
kernel_rfl PRE_first_tail_x15_r0_body.fincI144 : PRE_first_tail_x15_r0_body.ciS144.all (fun k => !Nat.blt k (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1396.ffi).mlx.nnext || PRE_first_tail_x15_r0_body.cli144.contains k) = true
kernel_rfl PRE_first_tail_x15_r0_body.fincN144 : PRE_first_tail_x15_r0_body.cnS144.all (Nat.ble (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1396.ffi).mlx.nnext) = true
kernel_rfl PRE_first_tail_x15_r0_body.flnF144 : PRE_first_tail_x15_r0_body.cln144.all (Nat.ble (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1396.ffi).mlx.nnext) = true
-- the checks over the changed lists
kernel_rfl PRE_first_tail_x15_r0_body.fh144 : PRE_first_tail_x15_r0_body.clo144.all (handleOK PRE_first_tail_x15_r0_body.kappa144 PRE_first_tail_x15_r0_body.P144.lo PRE_first_tail_x15_r0_body.cx0_144.mlx PRE_first_tail_x15_r0_body.cx1_144.mlx) = true
kernel_rfl PRE_first_tail_x15_r0_body.fo144 : PRE_first_tail_x15_r0_body.clo144.map (fun h => PRE_first_tail_x15_r0_body.cx1_144.mlx.objs.get (PRE_first_tail_x15_r0_body.kappa144.handle h)) = PRE_first_tail_x15_r0_body.clo144.map (fun h => (PRE_first_tail_x15_r0_body.cx0_144.mlx.objs.get h).map PRE_first_tail_x15_r0_body.kappa144.nobj)
kernel_rfl PRE_first_tail_x15_r0_body.fok144 : PRE_first_tail_x15_r0_body.clo144.all (objOK PRE_first_tail_x15_r0_body.kappa144 PRE_first_tail_x15_r0_body.P144.NL PRE_first_tail_x15_r0_body.cx0_144.mlx) = true
kernel_rfl PRE_first_tail_x15_r0_body.fnd144 : PRE_first_tail_x15_r0_body.cln144.all (nodeOKF PRE_first_tail_x15_r0_body.kappa144 PRE_first_tail_x15_r0_body.P144 PRE_first_tail_x15_r0_body.cx0_144.mlx PRE_first_tail_x15_r0_body.cx1_144.mlx) = true
kernel_rfl PRE_first_tail_x15_r0_body.fp144 : ((PRE_first_tail_x15_r0_body.cln144.filter (fullB PRE_first_tail_x15_r0_body.P144))).map (fun i => (PRE_first_tail_x15_r0_body.cx1_144.mlx.nodes.get (PRE_first_tail_x15_r0_body.kappa144.node i)).map Host.Mlx.Ffi.Node.prim) =
  ((PRE_first_tail_x15_r0_body.cln144.filter (fullB PRE_first_tail_x15_r0_body.P144))).map (fun i => (PRE_first_tail_x15_r0_body.cx0_144.mlx.nodes.get i).map fun nd => PRE_first_tail_x15_r0_body.kappa144.prim nd.prim)
kernel_rfl PRE_first_tail_x15_r0_body.fnordI144 : incrB PRE_first_tail_x15_r0_body.kd144.nodeF (List.range' 18122 27) = true
kernel_rfl PRE_first_tail_x15_r0_body.fnordK144 : (PTrie.keysA PRE_first_tail_x15_r0_body.kd144.node).all (fun k => Nat.ble 18122 k && Nat.blt k 18149) = true
kernel_rfl PRE_first_tail_x15_r0_body.fnordL144 : (PRE_first_tail_x15_r0_body.cln144.filter (Nat.ble PRE_first_tail_x15_r0_body.P144.N0)).all (fun i => Nat.ble i (PRE_first_tail_x15_r0_body.kd144.nodeF i) && (Nat.blt i 18149 || Nat.ble PRE_first_tail_x15_r0_body.kd144.nn0 i)) = true
theorem PRE_first_tail_x15_r0_body.fnord144 : (PRE_first_tail_x15_r0_body.cln144.filter (Nat.ble PRE_first_tail_x15_r0_body.P144.N0)).all (fun i => Nat.ble i (PRE_first_tail_x15_r0_body.kd144.nodeF i) &&
    (PTrie.keysA PRE_first_tail_x15_r0_body.kd144.node).all fun j => !Nat.blt j i || Nat.blt (PRE_first_tail_x15_r0_body.kd144.nodeF j) (PRE_first_tail_x15_r0_body.kd144.nodeF i)) = true :=
  cnord_of PRE_first_tail_x15_r0_body.cnlow144 PRE_first_tail_x15_r0_body.cnn1144 PRE_first_tail_x15_r0_body.fnordI144 PRE_first_tail_x15_r0_body.fnordK144 PRE_first_tail_x15_r0_body.fnordL144
kernel_rfl PRE_first_tail_x15_r0_body.fi144 : PRE_first_tail_x15_r0_body.cli144.all (pnB PRE_first_tail_x15_r0_body.cx0_144.mlx) = true
kernel_rfl PRE_first_tail_x15_r0_body.fii144 : PRE_first_tail_x15_r0_body.cli144.all (fun k => decide (PRE_first_tail_x15_r0_body.cx1_144.mlx.items.get (PRE_first_tail_x15_r0_body.kappa144.node k) = (PRE_first_tail_x15_r0_body.cx0_144.mlx.items.get k).map PRE_first_tail_x15_r0_body.kappa144.nv)) = true
/-- **The compaction's footprint.** -/
theorem PRE_first_tail_x15_r0_body.cfoot144 (clean : Conv.NClean (⟨21048, 18122, 2788459, 6239⟩ : Conv.Cnt) (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1396.ffi).mlx) (hltC : ∀ h, PH (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1396.ffi).mlx h → h < (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1396.ffi).mlx.next) (nltC : ∀ i, PN (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1396.ffi).mlx i → i < (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1396.ffi).mlx.nnext) (itemsC : ∀ k v, (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1396.ffi).mlx.items.get k = some v → PN (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1396.ffi).mlx k) (tracedC : ∀ h o, (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1396.ffi).mlx.objs.get h = some o → ∀ i ∈ objTraces o, i < PRE_first_tail_x15_r0_body.P144.NL) (cl : SSt (· < 6257) PRE_first_tail_x15_r0_body.cx0_144.mlx) :
    Conv.MFoot PRE_first_tail_x15_r0_body.P144 6257 PRE_first_tail_x15_r0_body.kappa144 PRE_first_tail_x15_r0_body.kd144 PRE_first_tail_x15_r0_body.khinv144 PRE_first_tail_x15_r0_body.kninv144 (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1396.ffi).mlx PRE_first_tail_x15_r0_body.cx0_144.mlx PRE_first_tail_x15_r0_body.cx1_144.mlx (⟨21048, 18122, 2788459, 6239⟩ : Conv.Cnt) PRE_first_tail_x15_r0_body.clo144 PRE_first_tail_x15_r0_body.cln144 PRE_first_tail_x15_r0_body.cli144 PRE_first_tail_x15_r0_body.cwS144 PRE_first_tail_x15_r0_body.cnS144 PRE_first_tail_x15_r0_body.ciS144 :=
  ⟨rfl, rfl, rfl, PRE_first_tail_x15_r0_body.cnh0144, PRE_first_tail_x15_r0_body.cnh1144, PRE_first_tail_x15_r0_body.cnn0144, PRE_first_tail_x15_r0_body.cnn1144, PRE_first_tail_x15_r0_body.cplo144, PRE_first_tail_x15_r0_body.ccnt144, PRE_first_tail_x15_r0_body.cnband144, PRE_first_tail_x15_r0_body.chbelow144, PRE_first_tail_x15_r0_body.chren144, PRE_first_tail_x15_r0_body.cband144, PRE_first_tail_x15_r0_body.cnh1pos144, PRE_first_tail_x15_r0_body.cnren144, PRE_first_tail_x15_r0_body.cnlow144, PRE_first_tail_x15_r0_body.cabs0a144, PRE_first_tail_x15_r0_body.cabs0b144, PRE_first_tail_x15_r0_body.ctok1144, PRE_first_tail_x15_r0_body.cpend144, PRE_first_tail_x15_r0_body.cerrh144, PRE_first_tail_x15_r0_body.cfiles144, PRE_first_tail_x15_r0_body.carch144, PRE_first_tail_x15_r0_body.csizes144, PRE_first_tail_x15_r0_body.cwired144, PRE_first_tail_x15_r0_body.cfix144, clean, PRE_first_tail_x15_r0_body.fcxn144, PRE_first_tail_x15_r0_body.fcnn144, hltC, nltC, itemsC, tracedC, cl, PRE_first_tail_x15_r0_body.fle0144, PRE_first_tail_x15_r0_body.fnk144, PRE_first_tail_x15_r0_body.ckA144, PRE_first_tail_x15_r0_body.cobjsK144, PRE_first_tail_x15_r0_body.cnodesK144, PRE_first_tail_x15_r0_body.citemsK144, PRE_first_tail_x15_r0_body.f1A144, PRE_first_tail_x15_r0_body.f1O144, PRE_first_tail_x15_r0_body.f1N144, PRE_first_tail_x15_r0_body.f1I144, PRE_first_tail_x15_r0_body.fbd144, PRE_first_tail_x15_r0_body.fincW144, PRE_first_tail_x15_r0_body.fincI144, PRE_first_tail_x15_r0_body.fincN144, PRE_first_tail_x15_r0_body.flnF144, PRE_first_tail_x15_r0_body.fh144, PRE_first_tail_x15_r0_body.fo144, PRE_first_tail_x15_r0_body.fok144, PRE_first_tail_x15_r0_body.fnd144, PRE_first_tail_x15_r0_body.fp144, PRE_first_tail_x15_r0_body.fnord144, PRE_first_tail_x15_r0_body.fi144, PRE_first_tail_x15_r0_body.fii144⟩
theorem PRE_first_tail_x15_r0_body.cnshift144 (clean : Conv.NClean (⟨21048, 18122, 2788459, 6239⟩ : Conv.Cnt) (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1396.ffi).mlx) (hltC : ∀ h, PH (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1396.ffi).mlx h → h < (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1396.ffi).mlx.next) (nltC : ∀ i, PN (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1396.ffi).mlx i → i < (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1396.ffi).mlx.nnext) (itemsC : ∀ k v, (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1396.ffi).mlx.items.get k = some v → PN (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1396.ffi).mlx k) (tracedC : ∀ h o, (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1396.ffi).mlx.objs.get h = some o → ∀ i ∈ objTraces o, i < PRE_first_tail_x15_r0_body.P144.NL) (cl : SSt (· < 6257) PRE_first_tail_x15_r0_body.cx0_144.mlx) : NShift PRE_first_tail_x15_r0_body.P144 6257 PRE_first_tail_x15_r0_body.kappa144 PRE_first_tail_x15_r0_body.cx0_144 PRE_first_tail_x15_r0_body.cx1_144 :=
  Conv.nshift_of_foot (PRE_first_tail_x15_r0_body.cfoot144 clean hltC nltC itemsC tracedC cl) PRE_first_tail_x15_r0_body.chost144 (compact_a_eq PRE_first_tail_x15_r0_body.ckn0144 PRE_first_tail_x15_r0_body.ckn1144 PRE_first_tail_x15_r0_body.ckheap144 PRE_first_tail_x15_r0_body.ckpl144)

-- the observers: the layers' states at the call, the canonical and the merged state, their footprints and checks
noncomputable def PRE_first_tail_x15_r0_body.fxC_144 : PTrie Unit := (Host.Ts.Sim.Full.freedOf PRE_first_tail_x15_r0_body.s1396.ffi).getD PTrie.nil
noncomputable def PRE_first_tail_x15_r0_body.krC_144 : Host.Load.Layers.KRec := (Host.Ts.Sim.Full.krecOf PRE_first_tail_x15_r0_body.s1396.ffi).getD Host.Load.Layers.KRec.empty
kernel_rfl PRE_first_tail_x15_r0_body.ofxC_144 : (Host.Ts.Sim.Full.freedOf PRE_first_tail_x15_r0_body.s1396.ffi) = some PRE_first_tail_x15_r0_body.fxC_144
kernel_rfl PRE_first_tail_x15_r0_body.okrC_144 : (Host.Ts.Sim.Full.krecOf PRE_first_tail_x15_r0_body.s1396.ffi) = some PRE_first_tail_x15_r0_body.krC_144
noncomputable def PRE_first_tail_x15_r0_body.fx0_144 : PTrie Unit := (Host.Ts.Sim.Full.freedOf PRE_first_tail_x15_r0_body.s1398.ffi).getD PTrie.nil
noncomputable def PRE_first_tail_x15_r0_body.kr0_144 : Host.Load.Layers.KRec := (Host.Ts.Sim.Full.krecOf PRE_first_tail_x15_r0_body.s1398.ffi).getD Host.Load.Layers.KRec.empty
kernel_rfl PRE_first_tail_x15_r0_body.ofx0_144 : (Host.Ts.Sim.Full.freedOf PRE_first_tail_x15_r0_body.s1398.ffi) = some PRE_first_tail_x15_r0_body.fx0_144
kernel_rfl PRE_first_tail_x15_r0_body.okr0_144 : (Host.Ts.Sim.Full.krecOf PRE_first_tail_x15_r0_body.s1398.ffi) = some PRE_first_tail_x15_r0_body.kr0_144
noncomputable def PRE_first_tail_x15_r0_body.fx1_144 : PTrie Unit := (Host.Ts.Sim.Full.freedOf PRE_first_tail_x15_r0_body.s1397.ffi).getD PTrie.nil
noncomputable def PRE_first_tail_x15_r0_body.kr1_144 : Host.Load.Layers.KRec := (Host.Ts.Sim.Full.krecOf PRE_first_tail_x15_r0_body.s1397.ffi).getD Host.Load.Layers.KRec.empty
kernel_rfl PRE_first_tail_x15_r0_body.ofx1_144 : (Host.Ts.Sim.Full.freedOf PRE_first_tail_x15_r0_body.s1397.ffi) = some PRE_first_tail_x15_r0_body.fx1_144
kernel_rfl PRE_first_tail_x15_r0_body.okr1_144 : (Host.Ts.Sim.Full.krecOf PRE_first_tail_x15_r0_body.s1397.ffi) = some PRE_first_tail_x15_r0_body.kr1_144
kernel_rfl PRE_first_tail_x15_r0_body.ff0144 : PRE_first_tail_x15_r0_body.fx0_144 = Stage.setAll PRE_first_tail_x15_r0_body.fxC_144 (PRE_first_tail_x15_r0_body.clo144.filterMap fun i => (PRE_first_tail_x15_r0_body.fx0_144.get i).map (i, ·))
kernel_rfl PRE_first_tail_x15_r0_body.ff1144 : PRE_first_tail_x15_r0_body.fx1_144 = Stage.setAll PRE_first_tail_x15_r0_body.fxC_144 (PRE_first_tail_x15_r0_body.cwS144.filterMap fun i => (PRE_first_tail_x15_r0_body.fx1_144.get i).map (i, ·))
kernel_rfl PRE_first_tail_x15_r0_body.ffck144 : freedLB PRE_first_tail_x15_r0_body.kappa144 PRE_first_tail_x15_r0_body.cx0_144.mlx PRE_first_tail_x15_r0_body.fx0_144 PRE_first_tail_x15_r0_body.fx1_144 PRE_first_tail_x15_r0_body.clo144 = true
kernel_rfl PRE_first_tail_x15_r0_body.fkf0144 : PRE_first_tail_x15_r0_body.kr0_144.flags = Stage.setAll PRE_first_tail_x15_r0_body.krC_144.flags (PRE_first_tail_x15_r0_body.clo144.filterMap fun i => (PRE_first_tail_x15_r0_body.kr0_144.flags.get i).map (i, ·))
kernel_rfl PRE_first_tail_x15_r0_body.fkt0144 : PRE_first_tail_x15_r0_body.kr0_144.targs = Stage.setAll PRE_first_tail_x15_r0_body.krC_144.targs (PRE_first_tail_x15_r0_body.clo144.filterMap fun i => (PRE_first_tail_x15_r0_body.kr0_144.targs.get i).map (i, ·))
kernel_rfl PRE_first_tail_x15_r0_body.fkf1144 : PRE_first_tail_x15_r0_body.kr1_144.flags = Stage.setAll PRE_first_tail_x15_r0_body.krC_144.flags (PRE_first_tail_x15_r0_body.cwS144.filterMap fun i => (PRE_first_tail_x15_r0_body.kr1_144.flags.get i).map (i, ·))
kernel_rfl PRE_first_tail_x15_r0_body.fkt1144 : PRE_first_tail_x15_r0_body.kr1_144.targs = Stage.setAll PRE_first_tail_x15_r0_body.krC_144.targs (PRE_first_tail_x15_r0_body.cwS144.filterMap fun i => (PRE_first_tail_x15_r0_body.kr1_144.targs.get i).map (i, ·))
kernel_rfl PRE_first_tail_x15_r0_body.fkck144 : krecLB PRE_first_tail_x15_r0_body.kappa144 6257 PRE_first_tail_x15_r0_body.cx0_144.mlx PRE_first_tail_x15_r0_body.kr0_144 PRE_first_tail_x15_r0_body.kr1_144 PRE_first_tail_x15_r0_body.clo144 = true
kernel_rfl PRE_first_tail_x15_r0_body.fkn144 : Nat.ble 6239 6257 = true
-- the bridge and the pending traces' regions
kernel_rfl PRE_first_tail_x15_r0_body.cbridge144 : Host.Ts.Sim.Full.bridgeOf PRE_first_tail_x15_r0_body.s1397.ffi = Host.Ts.Sim.Full.bridgeOf PRE_first_tail_x15_r0_body.s1398.ffi
kernel_rfl PRE_first_tail_x15_r0_body.cpendR144 : pendRegB PRE_first_tail_x15_r0_body.kappa144 (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1398.ffi).mlx = true
kernel_rfl PRE_first_tail_x15_r0_body.cpendLe144 : Nat.ble (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1398.ffi).mlx.next (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1397.ffi).mlx.next = true
/-- **The compaction's native shift**, given the call's bookkeeping, its relation's facts (the model's and the
observers') and the canonical closedness. -/
theorem PRE_first_tail_x15_r0_body.cshift144 (clean : Conv.NClean (⟨21048, 18122, 2788459, 6239⟩ : Conv.Cnt) (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1396.ffi).mlx) (hltC : ∀ h, PH (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1396.ffi).mlx h → h < (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1396.ffi).mlx.next) (nltC : ∀ i, PN (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1396.ffi).mlx i → i < (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1396.ffi).mlx.nnext) (itemsC : ∀ k v, (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1396.ffi).mlx.items.get k = some v → PN (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1396.ffi).mlx k) (tracedC : ∀ h o, (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1396.ffi).mlx.objs.get h = some o → ∀ i ∈ objTraces o, i < PRE_first_tail_x15_r0_body.P144.NL) (cl : SSt (· < 6257) PRE_first_tail_x15_r0_body.cx0_144.mlx)
    (hobjC : ∀ h, PRE_first_tail_x15_r0_body.fxC_144.get h = some () → ((Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1396.ffi).mlx.objs.get h).isSome = true)
    (hfC : ∀ h, (PRE_first_tail_x15_r0_body.krC_144.flags.get h).isSome = true → ((Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1396.ffi).mlx.objs.get h).isSome = true)
    (htC : ∀ h, (PRE_first_tail_x15_r0_body.krC_144.targs.get h).isSome = true → ((Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1396.ffi).mlx.objs.get h).isSome = true)
    (hclC : ∀ h l, PRE_first_tail_x15_r0_body.krC_144.targs.get h = some l → Host.Ts.Sim.Full.STargs (· < (⟨21048, 18122, 2788459, 6239⟩ : Conv.Cnt).n) l) :
    Conv.FullShiftQ PRE_first_tail_x15_r0_body.P144 6257 PRE_first_tail_x15_r0_body.kappa144 PRE_first_tail_x15_r0_body.s1398.ffi PRE_first_tail_x15_r0_body.s1397.ffi :=
  ⟨PRE_first_tail_x15_r0_body.cnshift144 clean hltC nltC itemsC tracedC cl, PRE_first_tail_x15_r0_body.cqueue144, fun t ht => bSN_sound (List.all_eq_true.mp PRE_first_tail_x15_r0_body.ctokSupp144 t ht),
    PRE_first_tail_x15_r0_body.cbridge144,
    liveShift_foot (x0' := Host.Ts.Sim.Full.mlxOf PRE_first_tail_x15_r0_body.s1398.ffi) (x1' := Host.Ts.Sim.Full.mlxOf PRE_first_tail_x15_r0_body.s1397.ffi) (PRE_first_tail_x15_r0_body.cfoot144 clean hltC nltC itemsC tracedC cl) rfl PRE_first_tail_x15_r0_body.ofx0_144 PRE_first_tail_x15_r0_body.ofx1_144 hobjC PRE_first_tail_x15_r0_body.ff0144 PRE_first_tail_x15_r0_body.ff1144 PRE_first_tail_x15_r0_body.ffck144,
    kernShift_foot (x0' := Host.Ts.Sim.Full.mlxOf PRE_first_tail_x15_r0_body.s1398.ffi) (x1' := Host.Ts.Sim.Full.mlxOf PRE_first_tail_x15_r0_body.s1397.ffi) (PRE_first_tail_x15_r0_body.cfoot144 clean hltC nltC itemsC tracedC cl) rfl PRE_first_tail_x15_r0_body.okr0_144 PRE_first_tail_x15_r0_body.okr1_144 (Nat.le_of_ble_eq_true PRE_first_tail_x15_r0_body.fkn144) hfC htC hclC
      PRE_first_tail_x15_r0_body.fkf0144 PRE_first_tail_x15_r0_body.fkt0144 PRE_first_tail_x15_r0_body.fkf1144 PRE_first_tail_x15_r0_body.fkt1144 PRE_first_tail_x15_r0_body.fkck144,
    pendReg_of rfl PRE_first_tail_x15_r0_body.cnh0144 PRE_first_tail_x15_r0_body.cnh1144 (Nat.le_of_ble_eq_true PRE_first_tail_x15_r0_body.cpendLe144) PRE_first_tail_x15_r0_body.cpendR144⟩

end Host.Load.Run.Tpl
