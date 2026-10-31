import host.sim.template.a4pre_first_tail_x15_r0_body.SiteCl78
import host.sim.conv.CompactFull
import host.sim.template.FootGen
set_option Elab.async false
namespace Host.Load.Run.Tpl
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
open Host.Ts Host.Ts.Sim Host.Ts.Sim.Template

/-! The compaction's native shift at call site 78 from its footprint (`Conv.nshift_of_foot`), and the observers'
(`liveShift_foot`, `kernShift_foot`): `Conv.FullShiftQ` for `Conv.full_compactQ`, given the call's bookkeeping and its
relation's facts. -/

/-- The load parameters of the chain (band-free: its start's node counter as `NL` and `N0`). -/
def PRE_first_tail_x15_r0_body.Pc78 : LoadP := ⟨18151, 131072, 1099511627776, 15235, 15235, []⟩
/-- The site's band raised to the map's checked fixed-node prefix, including newly recorded closure traces. -/
def PRE_first_tail_x15_r0_body.P78 : LoadP := PRE_first_tail_x15_r0_body.Pc78.raise 16853
kernel_rfl PRE_first_tail_x15_r0_body.craise78 : Nat.ble PRE_first_tail_x15_r0_body.Pc78.N0 16853 = true
theorem PRE_first_tail_x15_r0_body.raised78 : Host.Ts.Sim.Full.Raised PRE_first_tail_x15_r0_body.Pc78 PRE_first_tail_x15_r0_body.P78 :=
  .inr ⟨16853, rfl, Nat.le_of_ble_eq_true PRE_first_tail_x15_r0_body.craise78, rfl⟩
noncomputable abbrev PRE_first_tail_x15_r0_body.cx0_78 : Host.Load.LSt := clearTokens (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s700.ffi)
noncomputable abbrev PRE_first_tail_x15_r0_body.cx1_78 : Host.Load.LSt := clearTokens (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s699.ffi)
def PRE_first_tail_x15_r0_body.khinv78 : PTrie Nat := Stage.setAll PTrie.nil [(19772, 19746), (19750, 19747), (19773, 19748)]
def PRE_first_tail_x15_r0_body.kninv78 : PTrie Nat := Stage.setAll PTrie.nil [(16826, 16826), (16827, 16827), (16828, 16828), (16829, 16829), (16830, 16830), (16831, 16831), (16832, 16832), (16833, 16833), (16834, 16834), (16835, 16835), (16836, 16836), (16837, 16837), (16838, 16838), (16839, 16839), (16840, 16840), (16841, 16841), (16842, 16842), (16843, 16843), (16844, 16844), (16845, 16845), (16846, 16846), (16847, 16847), (16848, 16848), (16849, 16849), (16850, 16850), (16851, 16851), (16852, 16852)]
/-- The stage's footprint: its written and fresh handles, fresh nodes, written and fresh items. -/
def PRE_first_tail_x15_r0_body.cwS78 : List Nat := [19726, 19739, 19745, 19746, 19747, 19748, 19749, 19750, 19751, 19752, 19753, 19754, 19755, 19756, 19757, 19758, 19759, 19760, 19761, 19762, 19763, 19764, 19765, 19766, 19767, 19768, 19769, 19770, 19771, 19772, 19773]
def PRE_first_tail_x15_r0_body.cnS78 : List Nat := List.range' 16826 27
def PRE_first_tail_x15_r0_body.ciS78 : List Nat := [] ++ List.range' 16826 27

-- the small checks (`MChecks`'s)
kernel_rfl PRE_first_tail_x15_r0_body.cnh078 : PRE_first_tail_x15_r0_body.kd78.nh0 = PRE_first_tail_x15_r0_body.cx0_78.mlx.next
kernel_rfl PRE_first_tail_x15_r0_body.cnh178 : PRE_first_tail_x15_r0_body.kd78.nh1 = PRE_first_tail_x15_r0_body.cx1_78.mlx.next
kernel_rfl PRE_first_tail_x15_r0_body.cnn078 : PRE_first_tail_x15_r0_body.kd78.nn0 = PRE_first_tail_x15_r0_body.cx0_78.mlx.nnext
kernel_rfl PRE_first_tail_x15_r0_body.cnn178 : PRE_first_tail_x15_r0_body.kd78.nn1 = PRE_first_tail_x15_r0_body.cx1_78.mlx.nnext
kernel_rfl PRE_first_tail_x15_r0_body.cplo78 : (Nat.blt 0 PRE_first_tail_x15_r0_body.P78.lo && Nat.ble PRE_first_tail_x15_r0_body.P78.lo PRE_first_tail_x15_r0_body.cx0_78.mlx.next && Nat.ble PRE_first_tail_x15_r0_body.P78.lo RData.bigHi && Nat.ble RData.bigHi PRE_first_tail_x15_r0_body.P78.E) = true
kernel_rfl PRE_first_tail_x15_r0_body.ccnt78 : (Nat.ble PRE_first_tail_x15_r0_body.cx0_78.mlx.next PRE_first_tail_x15_r0_body.cx1_78.mlx.next && Nat.ble PRE_first_tail_x15_r0_body.cx0_78.mlx.nnext PRE_first_tail_x15_r0_body.cx1_78.mlx.nnext) = true
kernel_rfl PRE_first_tail_x15_r0_body.cnband78 : (Nat.blt 0 PRE_first_tail_x15_r0_body.P78.NL && Nat.ble PRE_first_tail_x15_r0_body.P78.NL PRE_first_tail_x15_r0_body.P78.N0 && Nat.ble PRE_first_tail_x15_r0_body.P78.N0 PRE_first_tail_x15_r0_body.cx0_78.mlx.nnext) = true
kernel_rfl PRE_first_tail_x15_r0_body.chbelow78 : PRE_first_tail_x15_r0_body.kd78.checkHndBelow = true
kernel_rfl PRE_first_tail_x15_r0_body.chren78 : checkRenG PRE_first_tail_x15_r0_body.kd78.hnd PRE_first_tail_x15_r0_body.khinv78 (phB PRE_first_tail_x15_r0_body.cx0_78.mlx) = true
kernel_rfl PRE_first_tail_x15_r0_body.cband78 : PRE_first_tail_x15_r0_body.kd78.checkBand PRE_first_tail_x15_r0_body.P78.lo = true
kernel_rfl PRE_first_tail_x15_r0_body.cnh1pos78 : Nat.blt 0 PRE_first_tail_x15_r0_body.kd78.nh1 = true
kernel_rfl PRE_first_tail_x15_r0_body.cnren78 : checkRenG PRE_first_tail_x15_r0_body.kd78.node PRE_first_tail_x15_r0_body.kninv78 (pnB PRE_first_tail_x15_r0_body.cx0_78.mlx) = true
kernel_rfl PRE_first_tail_x15_r0_body.cnlow78 : (PTrie.keysA PRE_first_tail_x15_r0_body.kd78.node).all (fun j => Nat.ble PRE_first_tail_x15_r0_body.P78.NL j && Nat.blt (PRE_first_tail_x15_r0_body.kd78.nodeF j) PRE_first_tail_x15_r0_body.cx1_78.mlx.nnext) = true
kernel_rfl PRE_first_tail_x15_r0_body.cabs0a78 : PRE_first_tail_x15_r0_body.cx0_78.mlx.arrs.get 0 = none
kernel_rfl PRE_first_tail_x15_r0_body.cabs0b78 : PRE_first_tail_x15_r0_body.cx0_78.mlx.objs.get 0 = none
kernel_rfl PRE_first_tail_x15_r0_body.ctok178 : PRE_first_tail_x15_r0_body.cx1_78.mlx.tokens = []
kernel_rfl PRE_first_tail_x15_r0_body.cpend78 : PRE_first_tail_x15_r0_body.cx1_78.mlx.pending = PRE_first_tail_x15_r0_body.cx0_78.mlx.pending.map PRE_first_tail_x15_r0_body.kappa78.pend
kernel_rfl PRE_first_tail_x15_r0_body.cerrh78 : PRE_first_tail_x15_r0_body.cx1_78.mlx.errh = PRE_first_tail_x15_r0_body.cx0_78.mlx.errh.map PRE_first_tail_x15_r0_body.kappa78.arg
kernel_rfl PRE_first_tail_x15_r0_body.cfiles78 : PRE_first_tail_x15_r0_body.cx1_78.mlx.files = PRE_first_tail_x15_r0_body.cx0_78.mlx.files
kernel_rfl PRE_first_tail_x15_r0_body.carch78 : PRE_first_tail_x15_r0_body.cx1_78.mlx.arch = PRE_first_tail_x15_r0_body.cx0_78.mlx.arch
kernel_rfl PRE_first_tail_x15_r0_body.csizes78 : PRE_first_tail_x15_r0_body.cx1_78.mlx.deviceSizes = PRE_first_tail_x15_r0_body.cx0_78.mlx.deviceSizes
kernel_rfl PRE_first_tail_x15_r0_body.cwired78 : PRE_first_tail_x15_r0_body.cx1_78.mlx.wired = PRE_first_tail_x15_r0_body.cx0_78.mlx.wired
kernel_rfl PRE_first_tail_x15_r0_body.chost78 : PRE_first_tail_x15_r0_body.cx1_78.host = PRE_first_tail_x15_r0_body.cx0_78.host
-- the compaction map's addresses are `PRE_first_tail_x15_r0_body.kd78`'s
kernel_rfl PRE_first_tail_x15_r0_body.ckn078 : PRE_first_tail_x15_r0_body.kd78.n0 = 2736477
kernel_rfl PRE_first_tail_x15_r0_body.ckn178 : PRE_first_tail_x15_r0_body.kd78.n1 = 2737626
kernel_rfl PRE_first_tail_x15_r0_body.ckheap78 : (PTrie.keysA PRE_first_tail_x15_r0_body.kd78.heap).all (fun x => Nat.ble 2736471 x) = true
kernel_rfl PRE_first_tail_x15_r0_body.ckpl78 : (List.range 6).all (fun j => decide (PRE_first_tail_x15_r0_body.kd78.heap.get (2736471 + j) = nth? PRE_first_tail_x15_r0_body.pl78 j)) = true
-- the map fixes the call's names (`Conv.fixOld_compact`), the call's counters
kernel_rfl PRE_first_tail_x15_r0_body.fja78 : Nat.ble 2736471 2736471 = true
kernel_rfl PRE_first_tail_x15_r0_body.fn78 : Nat.ble 3419 3419 = true
kernel_rfl PRE_first_tail_x15_r0_body.fjaD78 : Nat.ble 2736471 PRE_first_tail_x15_r0_body.kd78.n0 = true
kernel_rfl PRE_first_tail_x15_r0_body.fxn78 : Nat.ble 19746 PRE_first_tail_x15_r0_body.kd78.nh0 = true
kernel_rfl PRE_first_tail_x15_r0_body.fnn78 : Nat.ble 16826 PRE_first_tail_x15_r0_body.kd78.nn0 = true
kernel_rfl PRE_first_tail_x15_r0_body.fxb78 : Nat.ble 19746 RData.bigHi = true
kernel_rfl PRE_first_tail_x15_r0_body.fheap78 : (PTrie.keysA PRE_first_tail_x15_r0_body.kd78.heap).all (Nat.ble (⟨19746, 16826, 2736471, 3419⟩ : Conv.Cnt).ja) = true
kernel_rfl PRE_first_tail_x15_r0_body.fhnd78 : (PTrie.keysA PRE_first_tail_x15_r0_body.kd78.hnd).all (Nat.ble (⟨19746, 16826, 2736471, 3419⟩ : Conv.Cnt).xn) = true
kernel_rfl PRE_first_tail_x15_r0_body.fnode78 : (PTrie.keysA PRE_first_tail_x15_r0_body.kd78.node).all (Nat.ble (⟨19746, 16826, 2736471, 3419⟩ : Conv.Cnt).nn) = true
/-- The compaction map fixes the call's names. -/
theorem PRE_first_tail_x15_r0_body.cfix78 : Conv.FixOld (⟨19746, 16826, 2736471, 3419⟩ : Conv.Cnt) PRE_first_tail_x15_r0_body.kappa78 :=
  Conv.fixOld_compact (Nat.le_of_ble_eq_true PRE_first_tail_x15_r0_body.fja78) (Nat.le_of_ble_eq_true PRE_first_tail_x15_r0_body.fn78) (Nat.le_of_ble_eq_true PRE_first_tail_x15_r0_body.fjaD78) (Nat.le_of_ble_eq_true PRE_first_tail_x15_r0_body.fxn78) (Nat.le_of_ble_eq_true PRE_first_tail_x15_r0_body.fnn78) (Nat.le_of_ble_eq_true PRE_first_tail_x15_r0_body.fxb78) PRE_first_tail_x15_r0_body.fheap78 PRE_first_tail_x15_r0_body.fhnd78 PRE_first_tail_x15_r0_body.fnode78
kernel_rfl PRE_first_tail_x15_r0_body.fcxn78 : (⟨19746, 16826, 2736471, 3419⟩ : Conv.Cnt).xn = (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s698.ffi).mlx.next
kernel_rfl PRE_first_tail_x15_r0_body.fcnn78 : (⟨19746, 16826, 2736471, 3419⟩ : Conv.Cnt).nn = (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s698.ffi).mlx.nnext
kernel_rfl PRE_first_tail_x15_r0_body.fle078 : (Nat.ble (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s698.ffi).mlx.next PRE_first_tail_x15_r0_body.cx0_78.mlx.next && Nat.ble (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s698.ffi).mlx.nnext PRE_first_tail_x15_r0_body.cx0_78.mlx.nnext && Nat.ble (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s698.ffi).mlx.next RData.bigHi) = true
kernel_rfl PRE_first_tail_x15_r0_body.fnk78 : (PTrie.keysA PRE_first_tail_x15_r0_body.kd78.node).all (Nat.ble (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s698.ffi).mlx.nnext) = true
-- the merged state keeps the call's entries off the stage's footprint
kernel_rfl PRE_first_tail_x15_r0_body.f1A78 : PRE_first_tail_x15_r0_body.cx1_78.mlx.arrs = Stage.setAll (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s698.ffi).mlx.arrs (PRE_first_tail_x15_r0_body.cwS78.filterMap fun i => (PRE_first_tail_x15_r0_body.cx1_78.mlx.arrs.get i).map (i, ·))
kernel_rfl PRE_first_tail_x15_r0_body.f1O78 : PRE_first_tail_x15_r0_body.cx1_78.mlx.objs = Stage.setAll (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s698.ffi).mlx.objs (PRE_first_tail_x15_r0_body.cwS78.filterMap fun i => (PRE_first_tail_x15_r0_body.cx1_78.mlx.objs.get i).map (i, ·))
kernel_rfl PRE_first_tail_x15_r0_body.f1N78 : PRE_first_tail_x15_r0_body.cx1_78.mlx.nodes = Stage.setAll (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s698.ffi).mlx.nodes (PRE_first_tail_x15_r0_body.cnS78.filterMap fun i => (PRE_first_tail_x15_r0_body.cx1_78.mlx.nodes.get i).map (i, ·))
kernel_rfl PRE_first_tail_x15_r0_body.f1I78 : PRE_first_tail_x15_r0_body.cx1_78.mlx.items = Stage.setAll (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s698.ffi).mlx.items (PRE_first_tail_x15_r0_body.ciS78.filterMap fun i => (PRE_first_tail_x15_r0_body.cx1_78.mlx.items.get i).map (i, ·))
kernel_rfl PRE_first_tail_x15_r0_body.fbd78 : (PRE_first_tail_x15_r0_body.clo78 ++ PRE_first_tail_x15_r0_body.cln78 ++ PRE_first_tail_x15_r0_body.cli78 ++ PRE_first_tail_x15_r0_body.cwS78 ++ PRE_first_tail_x15_r0_body.cnS78 ++ PRE_first_tail_x15_r0_body.ciS78).all (fun i => Nat.blt (i / 4096) (4 ^ 31)) = true
kernel_rfl PRE_first_tail_x15_r0_body.fincW78 : PRE_first_tail_x15_r0_body.cwS78.all (fun h => !Nat.blt h (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s698.ffi).mlx.next || PRE_first_tail_x15_r0_body.clo78.contains h) = true
kernel_rfl PRE_first_tail_x15_r0_body.fincI78 : PRE_first_tail_x15_r0_body.ciS78.all (fun k => !Nat.blt k (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s698.ffi).mlx.nnext || PRE_first_tail_x15_r0_body.cli78.contains k) = true
kernel_rfl PRE_first_tail_x15_r0_body.fincN78 : PRE_first_tail_x15_r0_body.cnS78.all (Nat.ble (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s698.ffi).mlx.nnext) = true
kernel_rfl PRE_first_tail_x15_r0_body.flnF78 : PRE_first_tail_x15_r0_body.cln78.all (Nat.ble (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s698.ffi).mlx.nnext) = true
-- the checks over the changed lists
kernel_rfl PRE_first_tail_x15_r0_body.fh78 : PRE_first_tail_x15_r0_body.clo78.all (handleOK PRE_first_tail_x15_r0_body.kappa78 PRE_first_tail_x15_r0_body.P78.lo PRE_first_tail_x15_r0_body.cx0_78.mlx PRE_first_tail_x15_r0_body.cx1_78.mlx) = true
kernel_rfl PRE_first_tail_x15_r0_body.fo78 : PRE_first_tail_x15_r0_body.clo78.map (fun h => PRE_first_tail_x15_r0_body.cx1_78.mlx.objs.get (PRE_first_tail_x15_r0_body.kappa78.handle h)) = PRE_first_tail_x15_r0_body.clo78.map (fun h => (PRE_first_tail_x15_r0_body.cx0_78.mlx.objs.get h).map PRE_first_tail_x15_r0_body.kappa78.nobj)
kernel_rfl PRE_first_tail_x15_r0_body.fok78 : PRE_first_tail_x15_r0_body.clo78.all (objOK PRE_first_tail_x15_r0_body.kappa78 PRE_first_tail_x15_r0_body.P78.NL PRE_first_tail_x15_r0_body.cx0_78.mlx) = true
kernel_rfl PRE_first_tail_x15_r0_body.fnd78 : PRE_first_tail_x15_r0_body.cln78.all (nodeOKF PRE_first_tail_x15_r0_body.kappa78 PRE_first_tail_x15_r0_body.P78 PRE_first_tail_x15_r0_body.cx0_78.mlx PRE_first_tail_x15_r0_body.cx1_78.mlx) = true
kernel_rfl PRE_first_tail_x15_r0_body.fp78 : ((PRE_first_tail_x15_r0_body.cln78.filter (fullB PRE_first_tail_x15_r0_body.P78))).map (fun i => (PRE_first_tail_x15_r0_body.cx1_78.mlx.nodes.get (PRE_first_tail_x15_r0_body.kappa78.node i)).map Host.Mlx.Ffi.Node.prim) =
  ((PRE_first_tail_x15_r0_body.cln78.filter (fullB PRE_first_tail_x15_r0_body.P78))).map (fun i => (PRE_first_tail_x15_r0_body.cx0_78.mlx.nodes.get i).map fun nd => PRE_first_tail_x15_r0_body.kappa78.prim nd.prim)
kernel_rfl PRE_first_tail_x15_r0_body.fnordI78 : incrB PRE_first_tail_x15_r0_body.kd78.nodeF (List.range' 16826 27) = true
kernel_rfl PRE_first_tail_x15_r0_body.fnordK78 : (PTrie.keysA PRE_first_tail_x15_r0_body.kd78.node).all (fun k => Nat.ble 16826 k && Nat.blt k 16853) = true
kernel_rfl PRE_first_tail_x15_r0_body.fnordL78 : (PRE_first_tail_x15_r0_body.cln78.filter (Nat.ble PRE_first_tail_x15_r0_body.P78.N0)).all (fun i => Nat.ble i (PRE_first_tail_x15_r0_body.kd78.nodeF i) && (Nat.blt i 16853 || Nat.ble PRE_first_tail_x15_r0_body.kd78.nn0 i)) = true
theorem PRE_first_tail_x15_r0_body.fnord78 : (PRE_first_tail_x15_r0_body.cln78.filter (Nat.ble PRE_first_tail_x15_r0_body.P78.N0)).all (fun i => Nat.ble i (PRE_first_tail_x15_r0_body.kd78.nodeF i) &&
    (PTrie.keysA PRE_first_tail_x15_r0_body.kd78.node).all fun j => !Nat.blt j i || Nat.blt (PRE_first_tail_x15_r0_body.kd78.nodeF j) (PRE_first_tail_x15_r0_body.kd78.nodeF i)) = true :=
  cnord_of PRE_first_tail_x15_r0_body.cnlow78 PRE_first_tail_x15_r0_body.cnn178 PRE_first_tail_x15_r0_body.fnordI78 PRE_first_tail_x15_r0_body.fnordK78 PRE_first_tail_x15_r0_body.fnordL78
kernel_rfl PRE_first_tail_x15_r0_body.fi78 : PRE_first_tail_x15_r0_body.cli78.all (pnB PRE_first_tail_x15_r0_body.cx0_78.mlx) = true
kernel_rfl PRE_first_tail_x15_r0_body.fii78 : PRE_first_tail_x15_r0_body.cli78.all (fun k => decide (PRE_first_tail_x15_r0_body.cx1_78.mlx.items.get (PRE_first_tail_x15_r0_body.kappa78.node k) = (PRE_first_tail_x15_r0_body.cx0_78.mlx.items.get k).map PRE_first_tail_x15_r0_body.kappa78.nv)) = true
/-- **The compaction's footprint.** -/
theorem PRE_first_tail_x15_r0_body.cfoot78 (clean : Conv.NClean (⟨19746, 16826, 2736471, 3419⟩ : Conv.Cnt) (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s698.ffi).mlx) (hltC : ∀ h, PH (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s698.ffi).mlx h → h < (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s698.ffi).mlx.next) (nltC : ∀ i, PN (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s698.ffi).mlx i → i < (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s698.ffi).mlx.nnext) (itemsC : ∀ k v, (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s698.ffi).mlx.items.get k = some v → PN (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s698.ffi).mlx k) (tracedC : ∀ h o, (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s698.ffi).mlx.objs.get h = some o → ∀ i ∈ objTraces o, i < PRE_first_tail_x15_r0_body.P78.NL) (cl : SSt (· < 3437) PRE_first_tail_x15_r0_body.cx0_78.mlx) :
    Conv.MFoot PRE_first_tail_x15_r0_body.P78 3437 PRE_first_tail_x15_r0_body.kappa78 PRE_first_tail_x15_r0_body.kd78 PRE_first_tail_x15_r0_body.khinv78 PRE_first_tail_x15_r0_body.kninv78 (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s698.ffi).mlx PRE_first_tail_x15_r0_body.cx0_78.mlx PRE_first_tail_x15_r0_body.cx1_78.mlx (⟨19746, 16826, 2736471, 3419⟩ : Conv.Cnt) PRE_first_tail_x15_r0_body.clo78 PRE_first_tail_x15_r0_body.cln78 PRE_first_tail_x15_r0_body.cli78 PRE_first_tail_x15_r0_body.cwS78 PRE_first_tail_x15_r0_body.cnS78 PRE_first_tail_x15_r0_body.ciS78 :=
  ⟨rfl, rfl, rfl, PRE_first_tail_x15_r0_body.cnh078, PRE_first_tail_x15_r0_body.cnh178, PRE_first_tail_x15_r0_body.cnn078, PRE_first_tail_x15_r0_body.cnn178, PRE_first_tail_x15_r0_body.cplo78, PRE_first_tail_x15_r0_body.ccnt78, PRE_first_tail_x15_r0_body.cnband78, PRE_first_tail_x15_r0_body.chbelow78, PRE_first_tail_x15_r0_body.chren78, PRE_first_tail_x15_r0_body.cband78, PRE_first_tail_x15_r0_body.cnh1pos78, PRE_first_tail_x15_r0_body.cnren78, PRE_first_tail_x15_r0_body.cnlow78, PRE_first_tail_x15_r0_body.cabs0a78, PRE_first_tail_x15_r0_body.cabs0b78, PRE_first_tail_x15_r0_body.ctok178, PRE_first_tail_x15_r0_body.cpend78, PRE_first_tail_x15_r0_body.cerrh78, PRE_first_tail_x15_r0_body.cfiles78, PRE_first_tail_x15_r0_body.carch78, PRE_first_tail_x15_r0_body.csizes78, PRE_first_tail_x15_r0_body.cwired78, PRE_first_tail_x15_r0_body.cfix78, clean, PRE_first_tail_x15_r0_body.fcxn78, PRE_first_tail_x15_r0_body.fcnn78, hltC, nltC, itemsC, tracedC, cl, PRE_first_tail_x15_r0_body.fle078, PRE_first_tail_x15_r0_body.fnk78, PRE_first_tail_x15_r0_body.ckA78, PRE_first_tail_x15_r0_body.cobjsK78, PRE_first_tail_x15_r0_body.cnodesK78, PRE_first_tail_x15_r0_body.citemsK78, PRE_first_tail_x15_r0_body.f1A78, PRE_first_tail_x15_r0_body.f1O78, PRE_first_tail_x15_r0_body.f1N78, PRE_first_tail_x15_r0_body.f1I78, PRE_first_tail_x15_r0_body.fbd78, PRE_first_tail_x15_r0_body.fincW78, PRE_first_tail_x15_r0_body.fincI78, PRE_first_tail_x15_r0_body.fincN78, PRE_first_tail_x15_r0_body.flnF78, PRE_first_tail_x15_r0_body.fh78, PRE_first_tail_x15_r0_body.fo78, PRE_first_tail_x15_r0_body.fok78, PRE_first_tail_x15_r0_body.fnd78, PRE_first_tail_x15_r0_body.fp78, PRE_first_tail_x15_r0_body.fnord78, PRE_first_tail_x15_r0_body.fi78, PRE_first_tail_x15_r0_body.fii78⟩
theorem PRE_first_tail_x15_r0_body.cnshift78 (clean : Conv.NClean (⟨19746, 16826, 2736471, 3419⟩ : Conv.Cnt) (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s698.ffi).mlx) (hltC : ∀ h, PH (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s698.ffi).mlx h → h < (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s698.ffi).mlx.next) (nltC : ∀ i, PN (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s698.ffi).mlx i → i < (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s698.ffi).mlx.nnext) (itemsC : ∀ k v, (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s698.ffi).mlx.items.get k = some v → PN (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s698.ffi).mlx k) (tracedC : ∀ h o, (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s698.ffi).mlx.objs.get h = some o → ∀ i ∈ objTraces o, i < PRE_first_tail_x15_r0_body.P78.NL) (cl : SSt (· < 3437) PRE_first_tail_x15_r0_body.cx0_78.mlx) : NShift PRE_first_tail_x15_r0_body.P78 3437 PRE_first_tail_x15_r0_body.kappa78 PRE_first_tail_x15_r0_body.cx0_78 PRE_first_tail_x15_r0_body.cx1_78 :=
  Conv.nshift_of_foot (PRE_first_tail_x15_r0_body.cfoot78 clean hltC nltC itemsC tracedC cl) PRE_first_tail_x15_r0_body.chost78 (compact_a_eq PRE_first_tail_x15_r0_body.ckn078 PRE_first_tail_x15_r0_body.ckn178 PRE_first_tail_x15_r0_body.ckheap78 PRE_first_tail_x15_r0_body.ckpl78)

-- the observers: the layers' states at the call, the canonical and the merged state, their footprints and checks
noncomputable def PRE_first_tail_x15_r0_body.fxC_78 : PTrie Unit := (Host.Ts.Sim.Full.freedOf PRE_first_tail_x15_r0_body.s698.ffi).getD PTrie.nil
noncomputable def PRE_first_tail_x15_r0_body.krC_78 : Host.Load.Layers.KRec := (Host.Ts.Sim.Full.krecOf PRE_first_tail_x15_r0_body.s698.ffi).getD Host.Load.Layers.KRec.empty
kernel_rfl PRE_first_tail_x15_r0_body.ofxC_78 : (Host.Ts.Sim.Full.freedOf PRE_first_tail_x15_r0_body.s698.ffi) = some PRE_first_tail_x15_r0_body.fxC_78
kernel_rfl PRE_first_tail_x15_r0_body.okrC_78 : (Host.Ts.Sim.Full.krecOf PRE_first_tail_x15_r0_body.s698.ffi) = some PRE_first_tail_x15_r0_body.krC_78
noncomputable def PRE_first_tail_x15_r0_body.fx0_78 : PTrie Unit := (Host.Ts.Sim.Full.freedOf PRE_first_tail_x15_r0_body.s700.ffi).getD PTrie.nil
noncomputable def PRE_first_tail_x15_r0_body.kr0_78 : Host.Load.Layers.KRec := (Host.Ts.Sim.Full.krecOf PRE_first_tail_x15_r0_body.s700.ffi).getD Host.Load.Layers.KRec.empty
kernel_rfl PRE_first_tail_x15_r0_body.ofx0_78 : (Host.Ts.Sim.Full.freedOf PRE_first_tail_x15_r0_body.s700.ffi) = some PRE_first_tail_x15_r0_body.fx0_78
kernel_rfl PRE_first_tail_x15_r0_body.okr0_78 : (Host.Ts.Sim.Full.krecOf PRE_first_tail_x15_r0_body.s700.ffi) = some PRE_first_tail_x15_r0_body.kr0_78
noncomputable def PRE_first_tail_x15_r0_body.fx1_78 : PTrie Unit := (Host.Ts.Sim.Full.freedOf PRE_first_tail_x15_r0_body.s699.ffi).getD PTrie.nil
noncomputable def PRE_first_tail_x15_r0_body.kr1_78 : Host.Load.Layers.KRec := (Host.Ts.Sim.Full.krecOf PRE_first_tail_x15_r0_body.s699.ffi).getD Host.Load.Layers.KRec.empty
kernel_rfl PRE_first_tail_x15_r0_body.ofx1_78 : (Host.Ts.Sim.Full.freedOf PRE_first_tail_x15_r0_body.s699.ffi) = some PRE_first_tail_x15_r0_body.fx1_78
kernel_rfl PRE_first_tail_x15_r0_body.okr1_78 : (Host.Ts.Sim.Full.krecOf PRE_first_tail_x15_r0_body.s699.ffi) = some PRE_first_tail_x15_r0_body.kr1_78
kernel_rfl PRE_first_tail_x15_r0_body.ff078 : PRE_first_tail_x15_r0_body.fx0_78 = Stage.setAll PRE_first_tail_x15_r0_body.fxC_78 (PRE_first_tail_x15_r0_body.clo78.filterMap fun i => (PRE_first_tail_x15_r0_body.fx0_78.get i).map (i, ·))
kernel_rfl PRE_first_tail_x15_r0_body.ff178 : PRE_first_tail_x15_r0_body.fx1_78 = Stage.setAll PRE_first_tail_x15_r0_body.fxC_78 (PRE_first_tail_x15_r0_body.cwS78.filterMap fun i => (PRE_first_tail_x15_r0_body.fx1_78.get i).map (i, ·))
kernel_rfl PRE_first_tail_x15_r0_body.ffck78 : freedLB PRE_first_tail_x15_r0_body.kappa78 PRE_first_tail_x15_r0_body.cx0_78.mlx PRE_first_tail_x15_r0_body.fx0_78 PRE_first_tail_x15_r0_body.fx1_78 PRE_first_tail_x15_r0_body.clo78 = true
kernel_rfl PRE_first_tail_x15_r0_body.fkf078 : PRE_first_tail_x15_r0_body.kr0_78.flags = Stage.setAll PRE_first_tail_x15_r0_body.krC_78.flags (PRE_first_tail_x15_r0_body.clo78.filterMap fun i => (PRE_first_tail_x15_r0_body.kr0_78.flags.get i).map (i, ·))
kernel_rfl PRE_first_tail_x15_r0_body.fkt078 : PRE_first_tail_x15_r0_body.kr0_78.targs = Stage.setAll PRE_first_tail_x15_r0_body.krC_78.targs (PRE_first_tail_x15_r0_body.clo78.filterMap fun i => (PRE_first_tail_x15_r0_body.kr0_78.targs.get i).map (i, ·))
kernel_rfl PRE_first_tail_x15_r0_body.fkf178 : PRE_first_tail_x15_r0_body.kr1_78.flags = Stage.setAll PRE_first_tail_x15_r0_body.krC_78.flags (PRE_first_tail_x15_r0_body.cwS78.filterMap fun i => (PRE_first_tail_x15_r0_body.kr1_78.flags.get i).map (i, ·))
kernel_rfl PRE_first_tail_x15_r0_body.fkt178 : PRE_first_tail_x15_r0_body.kr1_78.targs = Stage.setAll PRE_first_tail_x15_r0_body.krC_78.targs (PRE_first_tail_x15_r0_body.cwS78.filterMap fun i => (PRE_first_tail_x15_r0_body.kr1_78.targs.get i).map (i, ·))
kernel_rfl PRE_first_tail_x15_r0_body.fkck78 : krecLB PRE_first_tail_x15_r0_body.kappa78 3437 PRE_first_tail_x15_r0_body.cx0_78.mlx PRE_first_tail_x15_r0_body.kr0_78 PRE_first_tail_x15_r0_body.kr1_78 PRE_first_tail_x15_r0_body.clo78 = true
kernel_rfl PRE_first_tail_x15_r0_body.fkn78 : Nat.ble 3419 3437 = true
-- the bridge and the pending traces' regions
kernel_rfl PRE_first_tail_x15_r0_body.cbridge78 : Host.Ts.Sim.Full.bridgeOf PRE_first_tail_x15_r0_body.s699.ffi = Host.Ts.Sim.Full.bridgeOf PRE_first_tail_x15_r0_body.s700.ffi
kernel_rfl PRE_first_tail_x15_r0_body.cpendR78 : pendRegB PRE_first_tail_x15_r0_body.kappa78 (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s700.ffi).mlx = true
kernel_rfl PRE_first_tail_x15_r0_body.cpendLe78 : Nat.ble (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s700.ffi).mlx.next (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s699.ffi).mlx.next = true
/-- **The compaction's native shift**, given the call's bookkeeping, its relation's facts (the model's and the
observers') and the canonical closedness. -/
theorem PRE_first_tail_x15_r0_body.cshift78 (clean : Conv.NClean (⟨19746, 16826, 2736471, 3419⟩ : Conv.Cnt) (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s698.ffi).mlx) (hltC : ∀ h, PH (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s698.ffi).mlx h → h < (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s698.ffi).mlx.next) (nltC : ∀ i, PN (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s698.ffi).mlx i → i < (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s698.ffi).mlx.nnext) (itemsC : ∀ k v, (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s698.ffi).mlx.items.get k = some v → PN (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s698.ffi).mlx k) (tracedC : ∀ h o, (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s698.ffi).mlx.objs.get h = some o → ∀ i ∈ objTraces o, i < PRE_first_tail_x15_r0_body.P78.NL) (cl : SSt (· < 3437) PRE_first_tail_x15_r0_body.cx0_78.mlx)
    (hobjC : ∀ h, PRE_first_tail_x15_r0_body.fxC_78.get h = some () → ((Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s698.ffi).mlx.objs.get h).isSome = true)
    (hfC : ∀ h, (PRE_first_tail_x15_r0_body.krC_78.flags.get h).isSome = true → ((Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s698.ffi).mlx.objs.get h).isSome = true)
    (htC : ∀ h, (PRE_first_tail_x15_r0_body.krC_78.targs.get h).isSome = true → ((Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s698.ffi).mlx.objs.get h).isSome = true)
    (hclC : ∀ h l, PRE_first_tail_x15_r0_body.krC_78.targs.get h = some l → Host.Ts.Sim.Full.STargs (· < (⟨19746, 16826, 2736471, 3419⟩ : Conv.Cnt).n) l) :
    Conv.FullShiftQ PRE_first_tail_x15_r0_body.P78 3437 PRE_first_tail_x15_r0_body.kappa78 PRE_first_tail_x15_r0_body.s700.ffi PRE_first_tail_x15_r0_body.s699.ffi :=
  ⟨PRE_first_tail_x15_r0_body.cnshift78 clean hltC nltC itemsC tracedC cl, PRE_first_tail_x15_r0_body.cqueue78, fun t ht => bSN_sound (List.all_eq_true.mp PRE_first_tail_x15_r0_body.ctokSupp78 t ht),
    PRE_first_tail_x15_r0_body.cbridge78,
    liveShift_foot (x0' := Host.Ts.Sim.Full.mlxOf PRE_first_tail_x15_r0_body.s700.ffi) (x1' := Host.Ts.Sim.Full.mlxOf PRE_first_tail_x15_r0_body.s699.ffi) (PRE_first_tail_x15_r0_body.cfoot78 clean hltC nltC itemsC tracedC cl) rfl PRE_first_tail_x15_r0_body.ofx0_78 PRE_first_tail_x15_r0_body.ofx1_78 hobjC PRE_first_tail_x15_r0_body.ff078 PRE_first_tail_x15_r0_body.ff178 PRE_first_tail_x15_r0_body.ffck78,
    kernShift_foot (x0' := Host.Ts.Sim.Full.mlxOf PRE_first_tail_x15_r0_body.s700.ffi) (x1' := Host.Ts.Sim.Full.mlxOf PRE_first_tail_x15_r0_body.s699.ffi) (PRE_first_tail_x15_r0_body.cfoot78 clean hltC nltC itemsC tracedC cl) rfl PRE_first_tail_x15_r0_body.okr0_78 PRE_first_tail_x15_r0_body.okr1_78 (Nat.le_of_ble_eq_true PRE_first_tail_x15_r0_body.fkn78) hfC htC hclC
      PRE_first_tail_x15_r0_body.fkf078 PRE_first_tail_x15_r0_body.fkt078 PRE_first_tail_x15_r0_body.fkf178 PRE_first_tail_x15_r0_body.fkt178 PRE_first_tail_x15_r0_body.fkck78,
    pendReg_of rfl PRE_first_tail_x15_r0_body.cnh078 PRE_first_tail_x15_r0_body.cnh178 (Nat.le_of_ble_eq_true PRE_first_tail_x15_r0_body.cpendLe78) PRE_first_tail_x15_r0_body.cpendR78⟩

end Host.Load.Run.Tpl
