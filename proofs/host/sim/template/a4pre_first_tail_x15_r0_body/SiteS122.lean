import host.sim.template.a4pre_first_tail_x15_r0_body.SiteCl122
import host.sim.conv.CompactFull
import host.sim.template.FootGen
set_option Elab.async false
namespace Host.Load.Run.Tpl
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
open Host.Ts Host.Ts.Sim Host.Ts.Sim.Template

/-! The compaction's native shift at call site 122 from its footprint (`Conv.nshift_of_foot`), and the observers'
(`liveShift_foot`, `kernShift_foot`): `Conv.FullShiftQ` for `Conv.full_compactQ`, given the call's bookkeeping and its
relation's facts. -/

/-- The load parameters of the chain (band-free: its start's node counter as `NL` and `N0`). -/
def PRE_first_tail_x15_r0_body.Pc122 : LoadP := ⟨18151, 131072, 1099511627776, 15235, 15235, []⟩
/-- The site's band raised to the map's checked fixed-node prefix, including newly recorded closure traces. -/
def PRE_first_tail_x15_r0_body.P122 : LoadP := PRE_first_tail_x15_r0_body.Pc122.raise 17692
kernel_rfl PRE_first_tail_x15_r0_body.craise122 : Nat.ble PRE_first_tail_x15_r0_body.Pc122.N0 17692 = true
theorem PRE_first_tail_x15_r0_body.raised122 : Host.Ts.Sim.Full.Raised PRE_first_tail_x15_r0_body.Pc122 PRE_first_tail_x15_r0_body.P122 :=
  .inr ⟨17692, rfl, Nat.le_of_ble_eq_true PRE_first_tail_x15_r0_body.craise122, rfl⟩
noncomputable abbrev PRE_first_tail_x15_r0_body.cx0_122 : Host.Load.LSt := clearTokens (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1077.ffi)
noncomputable abbrev PRE_first_tail_x15_r0_body.cx1_122 : Host.Load.LSt := clearTokens (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1076.ffi)
def PRE_first_tail_x15_r0_body.khinv122 : PTrie Nat := Stage.setAll PTrie.nil []
def PRE_first_tail_x15_r0_body.kninv122 : PTrie Nat := Stage.setAll PTrie.nil []
/-- The stage's footprint: its written and fresh handles, fresh nodes, written and fresh items. -/
def PRE_first_tail_x15_r0_body.cwS122 : List Nat := []
def PRE_first_tail_x15_r0_body.cnS122 : List Nat := List.range' 17692 0
def PRE_first_tail_x15_r0_body.ciS122 : List Nat := [] ++ List.range' 17692 0

-- the small checks (`MChecks`'s)
kernel_rfl PRE_first_tail_x15_r0_body.cnh0122 : PRE_first_tail_x15_r0_body.kd122.nh0 = PRE_first_tail_x15_r0_body.cx0_122.mlx.next
kernel_rfl PRE_first_tail_x15_r0_body.cnh1122 : PRE_first_tail_x15_r0_body.kd122.nh1 = PRE_first_tail_x15_r0_body.cx1_122.mlx.next
kernel_rfl PRE_first_tail_x15_r0_body.cnn0122 : PRE_first_tail_x15_r0_body.kd122.nn0 = PRE_first_tail_x15_r0_body.cx0_122.mlx.nnext
kernel_rfl PRE_first_tail_x15_r0_body.cnn1122 : PRE_first_tail_x15_r0_body.kd122.nn1 = PRE_first_tail_x15_r0_body.cx1_122.mlx.nnext
kernel_rfl PRE_first_tail_x15_r0_body.cplo122 : (Nat.blt 0 PRE_first_tail_x15_r0_body.P122.lo && Nat.ble PRE_first_tail_x15_r0_body.P122.lo PRE_first_tail_x15_r0_body.cx0_122.mlx.next && Nat.ble PRE_first_tail_x15_r0_body.P122.lo RData.bigHi && Nat.ble RData.bigHi PRE_first_tail_x15_r0_body.P122.E) = true
kernel_rfl PRE_first_tail_x15_r0_body.ccnt122 : (Nat.ble PRE_first_tail_x15_r0_body.cx0_122.mlx.next PRE_first_tail_x15_r0_body.cx1_122.mlx.next && Nat.ble PRE_first_tail_x15_r0_body.cx0_122.mlx.nnext PRE_first_tail_x15_r0_body.cx1_122.mlx.nnext) = true
kernel_rfl PRE_first_tail_x15_r0_body.cnband122 : (Nat.blt 0 PRE_first_tail_x15_r0_body.P122.NL && Nat.ble PRE_first_tail_x15_r0_body.P122.NL PRE_first_tail_x15_r0_body.P122.N0 && Nat.ble PRE_first_tail_x15_r0_body.P122.N0 PRE_first_tail_x15_r0_body.cx0_122.mlx.nnext) = true
kernel_rfl PRE_first_tail_x15_r0_body.chbelow122 : PRE_first_tail_x15_r0_body.kd122.checkHndBelow = true
kernel_rfl PRE_first_tail_x15_r0_body.chren122 : checkRenG PRE_first_tail_x15_r0_body.kd122.hnd PRE_first_tail_x15_r0_body.khinv122 (phB PRE_first_tail_x15_r0_body.cx0_122.mlx) = true
kernel_rfl PRE_first_tail_x15_r0_body.cband122 : PRE_first_tail_x15_r0_body.kd122.checkBand PRE_first_tail_x15_r0_body.P122.lo = true
kernel_rfl PRE_first_tail_x15_r0_body.cnh1pos122 : Nat.blt 0 PRE_first_tail_x15_r0_body.kd122.nh1 = true
kernel_rfl PRE_first_tail_x15_r0_body.cnren122 : checkRenG PRE_first_tail_x15_r0_body.kd122.node PRE_first_tail_x15_r0_body.kninv122 (pnB PRE_first_tail_x15_r0_body.cx0_122.mlx) = true
kernel_rfl PRE_first_tail_x15_r0_body.cnlow122 : (PTrie.keysA PRE_first_tail_x15_r0_body.kd122.node).all (fun j => Nat.ble PRE_first_tail_x15_r0_body.P122.NL j && Nat.blt (PRE_first_tail_x15_r0_body.kd122.nodeF j) PRE_first_tail_x15_r0_body.cx1_122.mlx.nnext) = true
kernel_rfl PRE_first_tail_x15_r0_body.cabs0a122 : PRE_first_tail_x15_r0_body.cx0_122.mlx.arrs.get 0 = none
kernel_rfl PRE_first_tail_x15_r0_body.cabs0b122 : PRE_first_tail_x15_r0_body.cx0_122.mlx.objs.get 0 = none
kernel_rfl PRE_first_tail_x15_r0_body.ctok1122 : PRE_first_tail_x15_r0_body.cx1_122.mlx.tokens = []
kernel_rfl PRE_first_tail_x15_r0_body.cpend122 : PRE_first_tail_x15_r0_body.cx1_122.mlx.pending = PRE_first_tail_x15_r0_body.cx0_122.mlx.pending.map PRE_first_tail_x15_r0_body.kappa122.pend
kernel_rfl PRE_first_tail_x15_r0_body.cerrh122 : PRE_first_tail_x15_r0_body.cx1_122.mlx.errh = PRE_first_tail_x15_r0_body.cx0_122.mlx.errh.map PRE_first_tail_x15_r0_body.kappa122.arg
kernel_rfl PRE_first_tail_x15_r0_body.cfiles122 : PRE_first_tail_x15_r0_body.cx1_122.mlx.files = PRE_first_tail_x15_r0_body.cx0_122.mlx.files
kernel_rfl PRE_first_tail_x15_r0_body.carch122 : PRE_first_tail_x15_r0_body.cx1_122.mlx.arch = PRE_first_tail_x15_r0_body.cx0_122.mlx.arch
kernel_rfl PRE_first_tail_x15_r0_body.csizes122 : PRE_first_tail_x15_r0_body.cx1_122.mlx.deviceSizes = PRE_first_tail_x15_r0_body.cx0_122.mlx.deviceSizes
kernel_rfl PRE_first_tail_x15_r0_body.cwired122 : PRE_first_tail_x15_r0_body.cx1_122.mlx.wired = PRE_first_tail_x15_r0_body.cx0_122.mlx.wired
kernel_rfl PRE_first_tail_x15_r0_body.chost122 : PRE_first_tail_x15_r0_body.cx1_122.host = PRE_first_tail_x15_r0_body.cx0_122.host
-- the compaction map's addresses are `PRE_first_tail_x15_r0_body.kd122`'s
kernel_rfl PRE_first_tail_x15_r0_body.ckn0122 : PRE_first_tail_x15_r0_body.kd122.n0 = 2770408
kernel_rfl PRE_first_tail_x15_r0_body.ckn1122 : PRE_first_tail_x15_r0_body.kd122.n1 = 2770418
kernel_rfl PRE_first_tail_x15_r0_body.ckheap122 : (PTrie.keysA PRE_first_tail_x15_r0_body.kd122.heap).all (fun x => Nat.ble 2770407 x) = true
kernel_rfl PRE_first_tail_x15_r0_body.ckpl122 : (List.range 1).all (fun j => decide (PRE_first_tail_x15_r0_body.kd122.heap.get (2770407 + j) = nth? PRE_first_tail_x15_r0_body.pl122 j)) = true
-- the map fixes the call's names (`Conv.fixOld_compact`), the call's counters
kernel_rfl PRE_first_tail_x15_r0_body.fja122 : Nat.ble 2770407 2770407 = true
kernel_rfl PRE_first_tail_x15_r0_body.fn122 : Nat.ble 5269 5269 = true
kernel_rfl PRE_first_tail_x15_r0_body.fjaD122 : Nat.ble 2770407 PRE_first_tail_x15_r0_body.kd122.n0 = true
kernel_rfl PRE_first_tail_x15_r0_body.fxn122 : Nat.ble 20599 PRE_first_tail_x15_r0_body.kd122.nh0 = true
kernel_rfl PRE_first_tail_x15_r0_body.fnn122 : Nat.ble 17692 PRE_first_tail_x15_r0_body.kd122.nn0 = true
kernel_rfl PRE_first_tail_x15_r0_body.fxb122 : Nat.ble 20599 RData.bigHi = true
kernel_rfl PRE_first_tail_x15_r0_body.fheap122 : (PTrie.keysA PRE_first_tail_x15_r0_body.kd122.heap).all (Nat.ble (⟨20599, 17692, 2770407, 5269⟩ : Conv.Cnt).ja) = true
kernel_rfl PRE_first_tail_x15_r0_body.fhnd122 : (PTrie.keysA PRE_first_tail_x15_r0_body.kd122.hnd).all (Nat.ble (⟨20599, 17692, 2770407, 5269⟩ : Conv.Cnt).xn) = true
kernel_rfl PRE_first_tail_x15_r0_body.fnode122 : (PTrie.keysA PRE_first_tail_x15_r0_body.kd122.node).all (Nat.ble (⟨20599, 17692, 2770407, 5269⟩ : Conv.Cnt).nn) = true
/-- The compaction map fixes the call's names. -/
theorem PRE_first_tail_x15_r0_body.cfix122 : Conv.FixOld (⟨20599, 17692, 2770407, 5269⟩ : Conv.Cnt) PRE_first_tail_x15_r0_body.kappa122 :=
  Conv.fixOld_compact (Nat.le_of_ble_eq_true PRE_first_tail_x15_r0_body.fja122) (Nat.le_of_ble_eq_true PRE_first_tail_x15_r0_body.fn122) (Nat.le_of_ble_eq_true PRE_first_tail_x15_r0_body.fjaD122) (Nat.le_of_ble_eq_true PRE_first_tail_x15_r0_body.fxn122) (Nat.le_of_ble_eq_true PRE_first_tail_x15_r0_body.fnn122) (Nat.le_of_ble_eq_true PRE_first_tail_x15_r0_body.fxb122) PRE_first_tail_x15_r0_body.fheap122 PRE_first_tail_x15_r0_body.fhnd122 PRE_first_tail_x15_r0_body.fnode122
kernel_rfl PRE_first_tail_x15_r0_body.fcxn122 : (⟨20599, 17692, 2770407, 5269⟩ : Conv.Cnt).xn = (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1075.ffi).mlx.next
kernel_rfl PRE_first_tail_x15_r0_body.fcnn122 : (⟨20599, 17692, 2770407, 5269⟩ : Conv.Cnt).nn = (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1075.ffi).mlx.nnext
kernel_rfl PRE_first_tail_x15_r0_body.fle0122 : (Nat.ble (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1075.ffi).mlx.next PRE_first_tail_x15_r0_body.cx0_122.mlx.next && Nat.ble (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1075.ffi).mlx.nnext PRE_first_tail_x15_r0_body.cx0_122.mlx.nnext && Nat.ble (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1075.ffi).mlx.next RData.bigHi) = true
kernel_rfl PRE_first_tail_x15_r0_body.fnk122 : (PTrie.keysA PRE_first_tail_x15_r0_body.kd122.node).all (Nat.ble (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1075.ffi).mlx.nnext) = true
-- the merged state keeps the call's entries off the stage's footprint
kernel_rfl PRE_first_tail_x15_r0_body.f1A122 : PRE_first_tail_x15_r0_body.cx1_122.mlx.arrs = Stage.setAll (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1075.ffi).mlx.arrs (PRE_first_tail_x15_r0_body.cwS122.filterMap fun i => (PRE_first_tail_x15_r0_body.cx1_122.mlx.arrs.get i).map (i, ·))
kernel_rfl PRE_first_tail_x15_r0_body.f1O122 : PRE_first_tail_x15_r0_body.cx1_122.mlx.objs = Stage.setAll (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1075.ffi).mlx.objs (PRE_first_tail_x15_r0_body.cwS122.filterMap fun i => (PRE_first_tail_x15_r0_body.cx1_122.mlx.objs.get i).map (i, ·))
kernel_rfl PRE_first_tail_x15_r0_body.f1N122 : PRE_first_tail_x15_r0_body.cx1_122.mlx.nodes = Stage.setAll (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1075.ffi).mlx.nodes (PRE_first_tail_x15_r0_body.cnS122.filterMap fun i => (PRE_first_tail_x15_r0_body.cx1_122.mlx.nodes.get i).map (i, ·))
kernel_rfl PRE_first_tail_x15_r0_body.f1I122 : PRE_first_tail_x15_r0_body.cx1_122.mlx.items = Stage.setAll (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1075.ffi).mlx.items (PRE_first_tail_x15_r0_body.ciS122.filterMap fun i => (PRE_first_tail_x15_r0_body.cx1_122.mlx.items.get i).map (i, ·))
kernel_rfl PRE_first_tail_x15_r0_body.fbd122 : (PRE_first_tail_x15_r0_body.clo122 ++ PRE_first_tail_x15_r0_body.cln122 ++ PRE_first_tail_x15_r0_body.cli122 ++ PRE_first_tail_x15_r0_body.cwS122 ++ PRE_first_tail_x15_r0_body.cnS122 ++ PRE_first_tail_x15_r0_body.ciS122).all (fun i => Nat.blt (i / 4096) (4 ^ 31)) = true
kernel_rfl PRE_first_tail_x15_r0_body.fincW122 : PRE_first_tail_x15_r0_body.cwS122.all (fun h => !Nat.blt h (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1075.ffi).mlx.next || PRE_first_tail_x15_r0_body.clo122.contains h) = true
kernel_rfl PRE_first_tail_x15_r0_body.fincI122 : PRE_first_tail_x15_r0_body.ciS122.all (fun k => !Nat.blt k (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1075.ffi).mlx.nnext || PRE_first_tail_x15_r0_body.cli122.contains k) = true
kernel_rfl PRE_first_tail_x15_r0_body.fincN122 : PRE_first_tail_x15_r0_body.cnS122.all (Nat.ble (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1075.ffi).mlx.nnext) = true
kernel_rfl PRE_first_tail_x15_r0_body.flnF122 : PRE_first_tail_x15_r0_body.cln122.all (Nat.ble (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1075.ffi).mlx.nnext) = true
-- the checks over the changed lists
kernel_rfl PRE_first_tail_x15_r0_body.fh122 : PRE_first_tail_x15_r0_body.clo122.all (handleOK PRE_first_tail_x15_r0_body.kappa122 PRE_first_tail_x15_r0_body.P122.lo PRE_first_tail_x15_r0_body.cx0_122.mlx PRE_first_tail_x15_r0_body.cx1_122.mlx) = true
kernel_rfl PRE_first_tail_x15_r0_body.fo122 : PRE_first_tail_x15_r0_body.clo122.map (fun h => PRE_first_tail_x15_r0_body.cx1_122.mlx.objs.get (PRE_first_tail_x15_r0_body.kappa122.handle h)) = PRE_first_tail_x15_r0_body.clo122.map (fun h => (PRE_first_tail_x15_r0_body.cx0_122.mlx.objs.get h).map PRE_first_tail_x15_r0_body.kappa122.nobj)
kernel_rfl PRE_first_tail_x15_r0_body.fok122 : PRE_first_tail_x15_r0_body.clo122.all (objOK PRE_first_tail_x15_r0_body.kappa122 PRE_first_tail_x15_r0_body.P122.NL PRE_first_tail_x15_r0_body.cx0_122.mlx) = true
kernel_rfl PRE_first_tail_x15_r0_body.fnd122 : PRE_first_tail_x15_r0_body.cln122.all (nodeOKF PRE_first_tail_x15_r0_body.kappa122 PRE_first_tail_x15_r0_body.P122 PRE_first_tail_x15_r0_body.cx0_122.mlx PRE_first_tail_x15_r0_body.cx1_122.mlx) = true
kernel_rfl PRE_first_tail_x15_r0_body.fp122 : ((PRE_first_tail_x15_r0_body.cln122.filter (fullB PRE_first_tail_x15_r0_body.P122))).map (fun i => (PRE_first_tail_x15_r0_body.cx1_122.mlx.nodes.get (PRE_first_tail_x15_r0_body.kappa122.node i)).map Host.Mlx.Ffi.Node.prim) =
  ((PRE_first_tail_x15_r0_body.cln122.filter (fullB PRE_first_tail_x15_r0_body.P122))).map (fun i => (PRE_first_tail_x15_r0_body.cx0_122.mlx.nodes.get i).map fun nd => PRE_first_tail_x15_r0_body.kappa122.prim nd.prim)
kernel_rfl PRE_first_tail_x15_r0_body.fnordI122 : incrB PRE_first_tail_x15_r0_body.kd122.nodeF (List.range' 17692 0) = true
kernel_rfl PRE_first_tail_x15_r0_body.fnordK122 : (PTrie.keysA PRE_first_tail_x15_r0_body.kd122.node).all (fun k => Nat.ble 17692 k && Nat.blt k 17692) = true
kernel_rfl PRE_first_tail_x15_r0_body.fnordL122 : (PRE_first_tail_x15_r0_body.cln122.filter (Nat.ble PRE_first_tail_x15_r0_body.P122.N0)).all (fun i => Nat.ble i (PRE_first_tail_x15_r0_body.kd122.nodeF i) && (Nat.blt i 17692 || Nat.ble PRE_first_tail_x15_r0_body.kd122.nn0 i)) = true
theorem PRE_first_tail_x15_r0_body.fnord122 : (PRE_first_tail_x15_r0_body.cln122.filter (Nat.ble PRE_first_tail_x15_r0_body.P122.N0)).all (fun i => Nat.ble i (PRE_first_tail_x15_r0_body.kd122.nodeF i) &&
    (PTrie.keysA PRE_first_tail_x15_r0_body.kd122.node).all fun j => !Nat.blt j i || Nat.blt (PRE_first_tail_x15_r0_body.kd122.nodeF j) (PRE_first_tail_x15_r0_body.kd122.nodeF i)) = true :=
  cnord_of PRE_first_tail_x15_r0_body.cnlow122 PRE_first_tail_x15_r0_body.cnn1122 PRE_first_tail_x15_r0_body.fnordI122 PRE_first_tail_x15_r0_body.fnordK122 PRE_first_tail_x15_r0_body.fnordL122
kernel_rfl PRE_first_tail_x15_r0_body.fi122 : PRE_first_tail_x15_r0_body.cli122.all (pnB PRE_first_tail_x15_r0_body.cx0_122.mlx) = true
kernel_rfl PRE_first_tail_x15_r0_body.fii122 : PRE_first_tail_x15_r0_body.cli122.all (fun k => decide (PRE_first_tail_x15_r0_body.cx1_122.mlx.items.get (PRE_first_tail_x15_r0_body.kappa122.node k) = (PRE_first_tail_x15_r0_body.cx0_122.mlx.items.get k).map PRE_first_tail_x15_r0_body.kappa122.nv)) = true
/-- **The compaction's footprint.** -/
theorem PRE_first_tail_x15_r0_body.cfoot122 (clean : Conv.NClean (⟨20599, 17692, 2770407, 5269⟩ : Conv.Cnt) (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1075.ffi).mlx) (hltC : ∀ h, PH (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1075.ffi).mlx h → h < (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1075.ffi).mlx.next) (nltC : ∀ i, PN (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1075.ffi).mlx i → i < (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1075.ffi).mlx.nnext) (itemsC : ∀ k v, (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1075.ffi).mlx.items.get k = some v → PN (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1075.ffi).mlx k) (tracedC : ∀ h o, (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1075.ffi).mlx.objs.get h = some o → ∀ i ∈ objTraces o, i < PRE_first_tail_x15_r0_body.P122.NL) (cl : SSt (· < 5269) PRE_first_tail_x15_r0_body.cx0_122.mlx) :
    Conv.MFoot PRE_first_tail_x15_r0_body.P122 5269 PRE_first_tail_x15_r0_body.kappa122 PRE_first_tail_x15_r0_body.kd122 PRE_first_tail_x15_r0_body.khinv122 PRE_first_tail_x15_r0_body.kninv122 (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1075.ffi).mlx PRE_first_tail_x15_r0_body.cx0_122.mlx PRE_first_tail_x15_r0_body.cx1_122.mlx (⟨20599, 17692, 2770407, 5269⟩ : Conv.Cnt) PRE_first_tail_x15_r0_body.clo122 PRE_first_tail_x15_r0_body.cln122 PRE_first_tail_x15_r0_body.cli122 PRE_first_tail_x15_r0_body.cwS122 PRE_first_tail_x15_r0_body.cnS122 PRE_first_tail_x15_r0_body.ciS122 :=
  ⟨rfl, rfl, rfl, PRE_first_tail_x15_r0_body.cnh0122, PRE_first_tail_x15_r0_body.cnh1122, PRE_first_tail_x15_r0_body.cnn0122, PRE_first_tail_x15_r0_body.cnn1122, PRE_first_tail_x15_r0_body.cplo122, PRE_first_tail_x15_r0_body.ccnt122, PRE_first_tail_x15_r0_body.cnband122, PRE_first_tail_x15_r0_body.chbelow122, PRE_first_tail_x15_r0_body.chren122, PRE_first_tail_x15_r0_body.cband122, PRE_first_tail_x15_r0_body.cnh1pos122, PRE_first_tail_x15_r0_body.cnren122, PRE_first_tail_x15_r0_body.cnlow122, PRE_first_tail_x15_r0_body.cabs0a122, PRE_first_tail_x15_r0_body.cabs0b122, PRE_first_tail_x15_r0_body.ctok1122, PRE_first_tail_x15_r0_body.cpend122, PRE_first_tail_x15_r0_body.cerrh122, PRE_first_tail_x15_r0_body.cfiles122, PRE_first_tail_x15_r0_body.carch122, PRE_first_tail_x15_r0_body.csizes122, PRE_first_tail_x15_r0_body.cwired122, PRE_first_tail_x15_r0_body.cfix122, clean, PRE_first_tail_x15_r0_body.fcxn122, PRE_first_tail_x15_r0_body.fcnn122, hltC, nltC, itemsC, tracedC, cl, PRE_first_tail_x15_r0_body.fle0122, PRE_first_tail_x15_r0_body.fnk122, PRE_first_tail_x15_r0_body.ckA122, PRE_first_tail_x15_r0_body.cobjsK122, PRE_first_tail_x15_r0_body.cnodesK122, PRE_first_tail_x15_r0_body.citemsK122, PRE_first_tail_x15_r0_body.f1A122, PRE_first_tail_x15_r0_body.f1O122, PRE_first_tail_x15_r0_body.f1N122, PRE_first_tail_x15_r0_body.f1I122, PRE_first_tail_x15_r0_body.fbd122, PRE_first_tail_x15_r0_body.fincW122, PRE_first_tail_x15_r0_body.fincI122, PRE_first_tail_x15_r0_body.fincN122, PRE_first_tail_x15_r0_body.flnF122, PRE_first_tail_x15_r0_body.fh122, PRE_first_tail_x15_r0_body.fo122, PRE_first_tail_x15_r0_body.fok122, PRE_first_tail_x15_r0_body.fnd122, PRE_first_tail_x15_r0_body.fp122, PRE_first_tail_x15_r0_body.fnord122, PRE_first_tail_x15_r0_body.fi122, PRE_first_tail_x15_r0_body.fii122⟩
theorem PRE_first_tail_x15_r0_body.cnshift122 (clean : Conv.NClean (⟨20599, 17692, 2770407, 5269⟩ : Conv.Cnt) (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1075.ffi).mlx) (hltC : ∀ h, PH (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1075.ffi).mlx h → h < (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1075.ffi).mlx.next) (nltC : ∀ i, PN (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1075.ffi).mlx i → i < (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1075.ffi).mlx.nnext) (itemsC : ∀ k v, (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1075.ffi).mlx.items.get k = some v → PN (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1075.ffi).mlx k) (tracedC : ∀ h o, (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1075.ffi).mlx.objs.get h = some o → ∀ i ∈ objTraces o, i < PRE_first_tail_x15_r0_body.P122.NL) (cl : SSt (· < 5269) PRE_first_tail_x15_r0_body.cx0_122.mlx) : NShift PRE_first_tail_x15_r0_body.P122 5269 PRE_first_tail_x15_r0_body.kappa122 PRE_first_tail_x15_r0_body.cx0_122 PRE_first_tail_x15_r0_body.cx1_122 :=
  Conv.nshift_of_foot (PRE_first_tail_x15_r0_body.cfoot122 clean hltC nltC itemsC tracedC cl) PRE_first_tail_x15_r0_body.chost122 (compact_a_eq PRE_first_tail_x15_r0_body.ckn0122 PRE_first_tail_x15_r0_body.ckn1122 PRE_first_tail_x15_r0_body.ckheap122 PRE_first_tail_x15_r0_body.ckpl122)

-- the observers: the layers' states at the call, the canonical and the merged state, their footprints and checks
noncomputable def PRE_first_tail_x15_r0_body.fxC_122 : PTrie Unit := (Host.Ts.Sim.Full.freedOf PRE_first_tail_x15_r0_body.s1075.ffi).getD PTrie.nil
noncomputable def PRE_first_tail_x15_r0_body.krC_122 : Host.Load.Layers.KRec := (Host.Ts.Sim.Full.krecOf PRE_first_tail_x15_r0_body.s1075.ffi).getD Host.Load.Layers.KRec.empty
kernel_rfl PRE_first_tail_x15_r0_body.ofxC_122 : (Host.Ts.Sim.Full.freedOf PRE_first_tail_x15_r0_body.s1075.ffi) = some PRE_first_tail_x15_r0_body.fxC_122
kernel_rfl PRE_first_tail_x15_r0_body.okrC_122 : (Host.Ts.Sim.Full.krecOf PRE_first_tail_x15_r0_body.s1075.ffi) = some PRE_first_tail_x15_r0_body.krC_122
noncomputable def PRE_first_tail_x15_r0_body.fx0_122 : PTrie Unit := (Host.Ts.Sim.Full.freedOf PRE_first_tail_x15_r0_body.s1077.ffi).getD PTrie.nil
noncomputable def PRE_first_tail_x15_r0_body.kr0_122 : Host.Load.Layers.KRec := (Host.Ts.Sim.Full.krecOf PRE_first_tail_x15_r0_body.s1077.ffi).getD Host.Load.Layers.KRec.empty
kernel_rfl PRE_first_tail_x15_r0_body.ofx0_122 : (Host.Ts.Sim.Full.freedOf PRE_first_tail_x15_r0_body.s1077.ffi) = some PRE_first_tail_x15_r0_body.fx0_122
kernel_rfl PRE_first_tail_x15_r0_body.okr0_122 : (Host.Ts.Sim.Full.krecOf PRE_first_tail_x15_r0_body.s1077.ffi) = some PRE_first_tail_x15_r0_body.kr0_122
noncomputable def PRE_first_tail_x15_r0_body.fx1_122 : PTrie Unit := (Host.Ts.Sim.Full.freedOf PRE_first_tail_x15_r0_body.s1076.ffi).getD PTrie.nil
noncomputable def PRE_first_tail_x15_r0_body.kr1_122 : Host.Load.Layers.KRec := (Host.Ts.Sim.Full.krecOf PRE_first_tail_x15_r0_body.s1076.ffi).getD Host.Load.Layers.KRec.empty
kernel_rfl PRE_first_tail_x15_r0_body.ofx1_122 : (Host.Ts.Sim.Full.freedOf PRE_first_tail_x15_r0_body.s1076.ffi) = some PRE_first_tail_x15_r0_body.fx1_122
kernel_rfl PRE_first_tail_x15_r0_body.okr1_122 : (Host.Ts.Sim.Full.krecOf PRE_first_tail_x15_r0_body.s1076.ffi) = some PRE_first_tail_x15_r0_body.kr1_122
kernel_rfl PRE_first_tail_x15_r0_body.ff0122 : PRE_first_tail_x15_r0_body.fx0_122 = Stage.setAll PRE_first_tail_x15_r0_body.fxC_122 (PRE_first_tail_x15_r0_body.clo122.filterMap fun i => (PRE_first_tail_x15_r0_body.fx0_122.get i).map (i, ·))
kernel_rfl PRE_first_tail_x15_r0_body.ff1122 : PRE_first_tail_x15_r0_body.fx1_122 = Stage.setAll PRE_first_tail_x15_r0_body.fxC_122 (PRE_first_tail_x15_r0_body.cwS122.filterMap fun i => (PRE_first_tail_x15_r0_body.fx1_122.get i).map (i, ·))
kernel_rfl PRE_first_tail_x15_r0_body.ffck122 : freedLB PRE_first_tail_x15_r0_body.kappa122 PRE_first_tail_x15_r0_body.cx0_122.mlx PRE_first_tail_x15_r0_body.fx0_122 PRE_first_tail_x15_r0_body.fx1_122 PRE_first_tail_x15_r0_body.clo122 = true
kernel_rfl PRE_first_tail_x15_r0_body.fkf0122 : PRE_first_tail_x15_r0_body.kr0_122.flags = Stage.setAll PRE_first_tail_x15_r0_body.krC_122.flags (PRE_first_tail_x15_r0_body.clo122.filterMap fun i => (PRE_first_tail_x15_r0_body.kr0_122.flags.get i).map (i, ·))
kernel_rfl PRE_first_tail_x15_r0_body.fkt0122 : PRE_first_tail_x15_r0_body.kr0_122.targs = Stage.setAll PRE_first_tail_x15_r0_body.krC_122.targs (PRE_first_tail_x15_r0_body.clo122.filterMap fun i => (PRE_first_tail_x15_r0_body.kr0_122.targs.get i).map (i, ·))
kernel_rfl PRE_first_tail_x15_r0_body.fkf1122 : PRE_first_tail_x15_r0_body.kr1_122.flags = Stage.setAll PRE_first_tail_x15_r0_body.krC_122.flags (PRE_first_tail_x15_r0_body.cwS122.filterMap fun i => (PRE_first_tail_x15_r0_body.kr1_122.flags.get i).map (i, ·))
kernel_rfl PRE_first_tail_x15_r0_body.fkt1122 : PRE_first_tail_x15_r0_body.kr1_122.targs = Stage.setAll PRE_first_tail_x15_r0_body.krC_122.targs (PRE_first_tail_x15_r0_body.cwS122.filterMap fun i => (PRE_first_tail_x15_r0_body.kr1_122.targs.get i).map (i, ·))
kernel_rfl PRE_first_tail_x15_r0_body.fkck122 : krecLB PRE_first_tail_x15_r0_body.kappa122 5269 PRE_first_tail_x15_r0_body.cx0_122.mlx PRE_first_tail_x15_r0_body.kr0_122 PRE_first_tail_x15_r0_body.kr1_122 PRE_first_tail_x15_r0_body.clo122 = true
kernel_rfl PRE_first_tail_x15_r0_body.fkn122 : Nat.ble 5269 5269 = true
-- the bridge and the pending traces' regions
kernel_rfl PRE_first_tail_x15_r0_body.cbridge122 : Host.Ts.Sim.Full.bridgeOf PRE_first_tail_x15_r0_body.s1076.ffi = Host.Ts.Sim.Full.bridgeOf PRE_first_tail_x15_r0_body.s1077.ffi
kernel_rfl PRE_first_tail_x15_r0_body.cpendR122 : pendRegB PRE_first_tail_x15_r0_body.kappa122 (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1077.ffi).mlx = true
kernel_rfl PRE_first_tail_x15_r0_body.cpendLe122 : Nat.ble (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1077.ffi).mlx.next (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1076.ffi).mlx.next = true
/-- **The compaction's native shift**, given the call's bookkeeping, its relation's facts (the model's and the
observers') and the canonical closedness. -/
theorem PRE_first_tail_x15_r0_body.cshift122 (clean : Conv.NClean (⟨20599, 17692, 2770407, 5269⟩ : Conv.Cnt) (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1075.ffi).mlx) (hltC : ∀ h, PH (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1075.ffi).mlx h → h < (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1075.ffi).mlx.next) (nltC : ∀ i, PN (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1075.ffi).mlx i → i < (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1075.ffi).mlx.nnext) (itemsC : ∀ k v, (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1075.ffi).mlx.items.get k = some v → PN (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1075.ffi).mlx k) (tracedC : ∀ h o, (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1075.ffi).mlx.objs.get h = some o → ∀ i ∈ objTraces o, i < PRE_first_tail_x15_r0_body.P122.NL) (cl : SSt (· < 5269) PRE_first_tail_x15_r0_body.cx0_122.mlx)
    (hobjC : ∀ h, PRE_first_tail_x15_r0_body.fxC_122.get h = some () → ((Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1075.ffi).mlx.objs.get h).isSome = true)
    (hfC : ∀ h, (PRE_first_tail_x15_r0_body.krC_122.flags.get h).isSome = true → ((Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1075.ffi).mlx.objs.get h).isSome = true)
    (htC : ∀ h, (PRE_first_tail_x15_r0_body.krC_122.targs.get h).isSome = true → ((Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1075.ffi).mlx.objs.get h).isSome = true)
    (hclC : ∀ h l, PRE_first_tail_x15_r0_body.krC_122.targs.get h = some l → Host.Ts.Sim.Full.STargs (· < (⟨20599, 17692, 2770407, 5269⟩ : Conv.Cnt).n) l) :
    Conv.FullShiftQ PRE_first_tail_x15_r0_body.P122 5269 PRE_first_tail_x15_r0_body.kappa122 PRE_first_tail_x15_r0_body.s1077.ffi PRE_first_tail_x15_r0_body.s1076.ffi :=
  ⟨PRE_first_tail_x15_r0_body.cnshift122 clean hltC nltC itemsC tracedC cl, PRE_first_tail_x15_r0_body.cqueue122, fun t ht => bSN_sound (List.all_eq_true.mp PRE_first_tail_x15_r0_body.ctokSupp122 t ht),
    PRE_first_tail_x15_r0_body.cbridge122,
    liveShift_foot (x0' := Host.Ts.Sim.Full.mlxOf PRE_first_tail_x15_r0_body.s1077.ffi) (x1' := Host.Ts.Sim.Full.mlxOf PRE_first_tail_x15_r0_body.s1076.ffi) (PRE_first_tail_x15_r0_body.cfoot122 clean hltC nltC itemsC tracedC cl) rfl PRE_first_tail_x15_r0_body.ofx0_122 PRE_first_tail_x15_r0_body.ofx1_122 hobjC PRE_first_tail_x15_r0_body.ff0122 PRE_first_tail_x15_r0_body.ff1122 PRE_first_tail_x15_r0_body.ffck122,
    kernShift_foot (x0' := Host.Ts.Sim.Full.mlxOf PRE_first_tail_x15_r0_body.s1077.ffi) (x1' := Host.Ts.Sim.Full.mlxOf PRE_first_tail_x15_r0_body.s1076.ffi) (PRE_first_tail_x15_r0_body.cfoot122 clean hltC nltC itemsC tracedC cl) rfl PRE_first_tail_x15_r0_body.okr0_122 PRE_first_tail_x15_r0_body.okr1_122 (Nat.le_of_ble_eq_true PRE_first_tail_x15_r0_body.fkn122) hfC htC hclC
      PRE_first_tail_x15_r0_body.fkf0122 PRE_first_tail_x15_r0_body.fkt0122 PRE_first_tail_x15_r0_body.fkf1122 PRE_first_tail_x15_r0_body.fkt1122 PRE_first_tail_x15_r0_body.fkck122,
    pendReg_of rfl PRE_first_tail_x15_r0_body.cnh0122 PRE_first_tail_x15_r0_body.cnh1122 (Nat.le_of_ble_eq_true PRE_first_tail_x15_r0_body.cpendLe122) PRE_first_tail_x15_r0_body.cpendR122⟩

end Host.Load.Run.Tpl
