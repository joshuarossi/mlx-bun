import host.sim.template.a4pre_first_tail_x15_r0_body.SiteCl130
import host.sim.conv.CompactFull
import host.sim.template.FootGen
set_option Elab.async false
namespace Host.Load.Run.Tpl
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
open Host.Ts Host.Ts.Sim Host.Ts.Sim.Template

/-! The compaction's native shift at call site 130 from its footprint (`Conv.nshift_of_foot`), and the observers'
(`liveShift_foot`, `kernShift_foot`): `Conv.FullShiftQ` for `Conv.full_compactQ`, given the call's bookkeeping and its
relation's facts. -/

/-- The load parameters of the chain (band-free: its start's node counter as `NL` and `N0`). -/
def PRE_first_tail_x15_r0_body.Pc130 : LoadP := ⟨18151, 131072, 1099511627776, 15235, 15235, []⟩
/-- The site's band raised to the map's checked fixed-node prefix, including newly recorded closure traces. -/
def PRE_first_tail_x15_r0_body.P130 : LoadP := PRE_first_tail_x15_r0_body.Pc130.raise 17862
kernel_rfl PRE_first_tail_x15_r0_body.craise130 : Nat.ble PRE_first_tail_x15_r0_body.Pc130.N0 17862 = true
theorem PRE_first_tail_x15_r0_body.raised130 : Host.Ts.Sim.Full.Raised PRE_first_tail_x15_r0_body.Pc130 PRE_first_tail_x15_r0_body.P130 :=
  .inr ⟨17862, rfl, Nat.le_of_ble_eq_true PRE_first_tail_x15_r0_body.craise130, rfl⟩
noncomputable abbrev PRE_first_tail_x15_r0_body.cx0_130 : Host.Load.LSt := clearTokens (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1262.ffi)
noncomputable abbrev PRE_first_tail_x15_r0_body.cx1_130 : Host.Load.LSt := clearTokens (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1261.ffi)
def PRE_first_tail_x15_r0_body.khinv130 : PTrie Nat := Stage.setAll PTrie.nil []
def PRE_first_tail_x15_r0_body.kninv130 : PTrie Nat := Stage.setAll PTrie.nil []
/-- The stage's footprint: its written and fresh handles, fresh nodes, written and fresh items. -/
def PRE_first_tail_x15_r0_body.cwS130 : List Nat := []
def PRE_first_tail_x15_r0_body.cnS130 : List Nat := List.range' 17862 0
def PRE_first_tail_x15_r0_body.ciS130 : List Nat := [] ++ List.range' 17862 0

-- the small checks (`MChecks`'s)
kernel_rfl PRE_first_tail_x15_r0_body.cnh0130 : PRE_first_tail_x15_r0_body.kd130.nh0 = PRE_first_tail_x15_r0_body.cx0_130.mlx.next
kernel_rfl PRE_first_tail_x15_r0_body.cnh1130 : PRE_first_tail_x15_r0_body.kd130.nh1 = PRE_first_tail_x15_r0_body.cx1_130.mlx.next
kernel_rfl PRE_first_tail_x15_r0_body.cnn0130 : PRE_first_tail_x15_r0_body.kd130.nn0 = PRE_first_tail_x15_r0_body.cx0_130.mlx.nnext
kernel_rfl PRE_first_tail_x15_r0_body.cnn1130 : PRE_first_tail_x15_r0_body.kd130.nn1 = PRE_first_tail_x15_r0_body.cx1_130.mlx.nnext
kernel_rfl PRE_first_tail_x15_r0_body.cplo130 : (Nat.blt 0 PRE_first_tail_x15_r0_body.P130.lo && Nat.ble PRE_first_tail_x15_r0_body.P130.lo PRE_first_tail_x15_r0_body.cx0_130.mlx.next && Nat.ble PRE_first_tail_x15_r0_body.P130.lo RData.bigHi && Nat.ble RData.bigHi PRE_first_tail_x15_r0_body.P130.E) = true
kernel_rfl PRE_first_tail_x15_r0_body.ccnt130 : (Nat.ble PRE_first_tail_x15_r0_body.cx0_130.mlx.next PRE_first_tail_x15_r0_body.cx1_130.mlx.next && Nat.ble PRE_first_tail_x15_r0_body.cx0_130.mlx.nnext PRE_first_tail_x15_r0_body.cx1_130.mlx.nnext) = true
kernel_rfl PRE_first_tail_x15_r0_body.cnband130 : (Nat.blt 0 PRE_first_tail_x15_r0_body.P130.NL && Nat.ble PRE_first_tail_x15_r0_body.P130.NL PRE_first_tail_x15_r0_body.P130.N0 && Nat.ble PRE_first_tail_x15_r0_body.P130.N0 PRE_first_tail_x15_r0_body.cx0_130.mlx.nnext) = true
kernel_rfl PRE_first_tail_x15_r0_body.chbelow130 : PRE_first_tail_x15_r0_body.kd130.checkHndBelow = true
kernel_rfl PRE_first_tail_x15_r0_body.chren130 : checkRenG PRE_first_tail_x15_r0_body.kd130.hnd PRE_first_tail_x15_r0_body.khinv130 (phB PRE_first_tail_x15_r0_body.cx0_130.mlx) = true
kernel_rfl PRE_first_tail_x15_r0_body.cband130 : PRE_first_tail_x15_r0_body.kd130.checkBand PRE_first_tail_x15_r0_body.P130.lo = true
kernel_rfl PRE_first_tail_x15_r0_body.cnh1pos130 : Nat.blt 0 PRE_first_tail_x15_r0_body.kd130.nh1 = true
kernel_rfl PRE_first_tail_x15_r0_body.cnren130 : checkRenG PRE_first_tail_x15_r0_body.kd130.node PRE_first_tail_x15_r0_body.kninv130 (pnB PRE_first_tail_x15_r0_body.cx0_130.mlx) = true
kernel_rfl PRE_first_tail_x15_r0_body.cnlow130 : (PTrie.keysA PRE_first_tail_x15_r0_body.kd130.node).all (fun j => Nat.ble PRE_first_tail_x15_r0_body.P130.NL j && Nat.blt (PRE_first_tail_x15_r0_body.kd130.nodeF j) PRE_first_tail_x15_r0_body.cx1_130.mlx.nnext) = true
kernel_rfl PRE_first_tail_x15_r0_body.cabs0a130 : PRE_first_tail_x15_r0_body.cx0_130.mlx.arrs.get 0 = none
kernel_rfl PRE_first_tail_x15_r0_body.cabs0b130 : PRE_first_tail_x15_r0_body.cx0_130.mlx.objs.get 0 = none
kernel_rfl PRE_first_tail_x15_r0_body.ctok1130 : PRE_first_tail_x15_r0_body.cx1_130.mlx.tokens = []
kernel_rfl PRE_first_tail_x15_r0_body.cpend130 : PRE_first_tail_x15_r0_body.cx1_130.mlx.pending = PRE_first_tail_x15_r0_body.cx0_130.mlx.pending.map PRE_first_tail_x15_r0_body.kappa130.pend
kernel_rfl PRE_first_tail_x15_r0_body.cerrh130 : PRE_first_tail_x15_r0_body.cx1_130.mlx.errh = PRE_first_tail_x15_r0_body.cx0_130.mlx.errh.map PRE_first_tail_x15_r0_body.kappa130.arg
kernel_rfl PRE_first_tail_x15_r0_body.cfiles130 : PRE_first_tail_x15_r0_body.cx1_130.mlx.files = PRE_first_tail_x15_r0_body.cx0_130.mlx.files
kernel_rfl PRE_first_tail_x15_r0_body.carch130 : PRE_first_tail_x15_r0_body.cx1_130.mlx.arch = PRE_first_tail_x15_r0_body.cx0_130.mlx.arch
kernel_rfl PRE_first_tail_x15_r0_body.csizes130 : PRE_first_tail_x15_r0_body.cx1_130.mlx.deviceSizes = PRE_first_tail_x15_r0_body.cx0_130.mlx.deviceSizes
kernel_rfl PRE_first_tail_x15_r0_body.cwired130 : PRE_first_tail_x15_r0_body.cx1_130.mlx.wired = PRE_first_tail_x15_r0_body.cx0_130.mlx.wired
kernel_rfl PRE_first_tail_x15_r0_body.chost130 : PRE_first_tail_x15_r0_body.cx1_130.host = PRE_first_tail_x15_r0_body.cx0_130.host
-- the compaction map's addresses are `PRE_first_tail_x15_r0_body.kd130`'s
kernel_rfl PRE_first_tail_x15_r0_body.ckn0130 : PRE_first_tail_x15_r0_body.kd130.n0 = 2777253
kernel_rfl PRE_first_tail_x15_r0_body.ckn1130 : PRE_first_tail_x15_r0_body.kd130.n1 = 2777255
kernel_rfl PRE_first_tail_x15_r0_body.ckheap130 : (PTrie.keysA PRE_first_tail_x15_r0_body.kd130.heap).all (fun x => Nat.ble 2777253 x) = true
kernel_rfl PRE_first_tail_x15_r0_body.ckpl130 : (List.range 0).all (fun j => decide (PRE_first_tail_x15_r0_body.kd130.heap.get (2777253 + j) = nth? PRE_first_tail_x15_r0_body.pl130 j)) = true
-- the map fixes the call's names (`Conv.fixOld_compact`), the call's counters
kernel_rfl PRE_first_tail_x15_r0_body.fja130 : Nat.ble 2777253 2777253 = true
kernel_rfl PRE_first_tail_x15_r0_body.fn130 : Nat.ble 5636 5636 = true
kernel_rfl PRE_first_tail_x15_r0_body.fjaD130 : Nat.ble 2777253 PRE_first_tail_x15_r0_body.kd130.n0 = true
kernel_rfl PRE_first_tail_x15_r0_body.fxn130 : Nat.ble 20770 PRE_first_tail_x15_r0_body.kd130.nh0 = true
kernel_rfl PRE_first_tail_x15_r0_body.fnn130 : Nat.ble 17862 PRE_first_tail_x15_r0_body.kd130.nn0 = true
kernel_rfl PRE_first_tail_x15_r0_body.fxb130 : Nat.ble 20770 RData.bigHi = true
kernel_rfl PRE_first_tail_x15_r0_body.fheap130 : (PTrie.keysA PRE_first_tail_x15_r0_body.kd130.heap).all (Nat.ble (⟨20770, 17862, 2777253, 5636⟩ : Conv.Cnt).ja) = true
kernel_rfl PRE_first_tail_x15_r0_body.fhnd130 : (PTrie.keysA PRE_first_tail_x15_r0_body.kd130.hnd).all (Nat.ble (⟨20770, 17862, 2777253, 5636⟩ : Conv.Cnt).xn) = true
kernel_rfl PRE_first_tail_x15_r0_body.fnode130 : (PTrie.keysA PRE_first_tail_x15_r0_body.kd130.node).all (Nat.ble (⟨20770, 17862, 2777253, 5636⟩ : Conv.Cnt).nn) = true
/-- The compaction map fixes the call's names. -/
theorem PRE_first_tail_x15_r0_body.cfix130 : Conv.FixOld (⟨20770, 17862, 2777253, 5636⟩ : Conv.Cnt) PRE_first_tail_x15_r0_body.kappa130 :=
  Conv.fixOld_compact (Nat.le_of_ble_eq_true PRE_first_tail_x15_r0_body.fja130) (Nat.le_of_ble_eq_true PRE_first_tail_x15_r0_body.fn130) (Nat.le_of_ble_eq_true PRE_first_tail_x15_r0_body.fjaD130) (Nat.le_of_ble_eq_true PRE_first_tail_x15_r0_body.fxn130) (Nat.le_of_ble_eq_true PRE_first_tail_x15_r0_body.fnn130) (Nat.le_of_ble_eq_true PRE_first_tail_x15_r0_body.fxb130) PRE_first_tail_x15_r0_body.fheap130 PRE_first_tail_x15_r0_body.fhnd130 PRE_first_tail_x15_r0_body.fnode130
kernel_rfl PRE_first_tail_x15_r0_body.fcxn130 : (⟨20770, 17862, 2777253, 5636⟩ : Conv.Cnt).xn = (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1260.ffi).mlx.next
kernel_rfl PRE_first_tail_x15_r0_body.fcnn130 : (⟨20770, 17862, 2777253, 5636⟩ : Conv.Cnt).nn = (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1260.ffi).mlx.nnext
kernel_rfl PRE_first_tail_x15_r0_body.fle0130 : (Nat.ble (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1260.ffi).mlx.next PRE_first_tail_x15_r0_body.cx0_130.mlx.next && Nat.ble (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1260.ffi).mlx.nnext PRE_first_tail_x15_r0_body.cx0_130.mlx.nnext && Nat.ble (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1260.ffi).mlx.next RData.bigHi) = true
kernel_rfl PRE_first_tail_x15_r0_body.fnk130 : (PTrie.keysA PRE_first_tail_x15_r0_body.kd130.node).all (Nat.ble (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1260.ffi).mlx.nnext) = true
-- the merged state keeps the call's entries off the stage's footprint
kernel_rfl PRE_first_tail_x15_r0_body.f1A130 : PRE_first_tail_x15_r0_body.cx1_130.mlx.arrs = Stage.setAll (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1260.ffi).mlx.arrs (PRE_first_tail_x15_r0_body.cwS130.filterMap fun i => (PRE_first_tail_x15_r0_body.cx1_130.mlx.arrs.get i).map (i, ·))
kernel_rfl PRE_first_tail_x15_r0_body.f1O130 : PRE_first_tail_x15_r0_body.cx1_130.mlx.objs = Stage.setAll (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1260.ffi).mlx.objs (PRE_first_tail_x15_r0_body.cwS130.filterMap fun i => (PRE_first_tail_x15_r0_body.cx1_130.mlx.objs.get i).map (i, ·))
kernel_rfl PRE_first_tail_x15_r0_body.f1N130 : PRE_first_tail_x15_r0_body.cx1_130.mlx.nodes = Stage.setAll (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1260.ffi).mlx.nodes (PRE_first_tail_x15_r0_body.cnS130.filterMap fun i => (PRE_first_tail_x15_r0_body.cx1_130.mlx.nodes.get i).map (i, ·))
kernel_rfl PRE_first_tail_x15_r0_body.f1I130 : PRE_first_tail_x15_r0_body.cx1_130.mlx.items = Stage.setAll (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1260.ffi).mlx.items (PRE_first_tail_x15_r0_body.ciS130.filterMap fun i => (PRE_first_tail_x15_r0_body.cx1_130.mlx.items.get i).map (i, ·))
kernel_rfl PRE_first_tail_x15_r0_body.fbd130 : (PRE_first_tail_x15_r0_body.clo130 ++ PRE_first_tail_x15_r0_body.cln130 ++ PRE_first_tail_x15_r0_body.cli130 ++ PRE_first_tail_x15_r0_body.cwS130 ++ PRE_first_tail_x15_r0_body.cnS130 ++ PRE_first_tail_x15_r0_body.ciS130).all (fun i => Nat.blt (i / 4096) (4 ^ 31)) = true
kernel_rfl PRE_first_tail_x15_r0_body.fincW130 : PRE_first_tail_x15_r0_body.cwS130.all (fun h => !Nat.blt h (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1260.ffi).mlx.next || PRE_first_tail_x15_r0_body.clo130.contains h) = true
kernel_rfl PRE_first_tail_x15_r0_body.fincI130 : PRE_first_tail_x15_r0_body.ciS130.all (fun k => !Nat.blt k (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1260.ffi).mlx.nnext || PRE_first_tail_x15_r0_body.cli130.contains k) = true
kernel_rfl PRE_first_tail_x15_r0_body.fincN130 : PRE_first_tail_x15_r0_body.cnS130.all (Nat.ble (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1260.ffi).mlx.nnext) = true
kernel_rfl PRE_first_tail_x15_r0_body.flnF130 : PRE_first_tail_x15_r0_body.cln130.all (Nat.ble (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1260.ffi).mlx.nnext) = true
-- the checks over the changed lists
kernel_rfl PRE_first_tail_x15_r0_body.fh130 : PRE_first_tail_x15_r0_body.clo130.all (handleOK PRE_first_tail_x15_r0_body.kappa130 PRE_first_tail_x15_r0_body.P130.lo PRE_first_tail_x15_r0_body.cx0_130.mlx PRE_first_tail_x15_r0_body.cx1_130.mlx) = true
kernel_rfl PRE_first_tail_x15_r0_body.fo130 : PRE_first_tail_x15_r0_body.clo130.map (fun h => PRE_first_tail_x15_r0_body.cx1_130.mlx.objs.get (PRE_first_tail_x15_r0_body.kappa130.handle h)) = PRE_first_tail_x15_r0_body.clo130.map (fun h => (PRE_first_tail_x15_r0_body.cx0_130.mlx.objs.get h).map PRE_first_tail_x15_r0_body.kappa130.nobj)
kernel_rfl PRE_first_tail_x15_r0_body.fok130 : PRE_first_tail_x15_r0_body.clo130.all (objOK PRE_first_tail_x15_r0_body.kappa130 PRE_first_tail_x15_r0_body.P130.NL PRE_first_tail_x15_r0_body.cx0_130.mlx) = true
kernel_rfl PRE_first_tail_x15_r0_body.fnd130 : PRE_first_tail_x15_r0_body.cln130.all (nodeOKF PRE_first_tail_x15_r0_body.kappa130 PRE_first_tail_x15_r0_body.P130 PRE_first_tail_x15_r0_body.cx0_130.mlx PRE_first_tail_x15_r0_body.cx1_130.mlx) = true
kernel_rfl PRE_first_tail_x15_r0_body.fp130 : ((PRE_first_tail_x15_r0_body.cln130.filter (fullB PRE_first_tail_x15_r0_body.P130))).map (fun i => (PRE_first_tail_x15_r0_body.cx1_130.mlx.nodes.get (PRE_first_tail_x15_r0_body.kappa130.node i)).map Host.Mlx.Ffi.Node.prim) =
  ((PRE_first_tail_x15_r0_body.cln130.filter (fullB PRE_first_tail_x15_r0_body.P130))).map (fun i => (PRE_first_tail_x15_r0_body.cx0_130.mlx.nodes.get i).map fun nd => PRE_first_tail_x15_r0_body.kappa130.prim nd.prim)
kernel_rfl PRE_first_tail_x15_r0_body.fnordI130 : incrB PRE_first_tail_x15_r0_body.kd130.nodeF (List.range' 17862 0) = true
kernel_rfl PRE_first_tail_x15_r0_body.fnordK130 : (PTrie.keysA PRE_first_tail_x15_r0_body.kd130.node).all (fun k => Nat.ble 17862 k && Nat.blt k 17862) = true
kernel_rfl PRE_first_tail_x15_r0_body.fnordL130 : (PRE_first_tail_x15_r0_body.cln130.filter (Nat.ble PRE_first_tail_x15_r0_body.P130.N0)).all (fun i => Nat.ble i (PRE_first_tail_x15_r0_body.kd130.nodeF i) && (Nat.blt i 17862 || Nat.ble PRE_first_tail_x15_r0_body.kd130.nn0 i)) = true
theorem PRE_first_tail_x15_r0_body.fnord130 : (PRE_first_tail_x15_r0_body.cln130.filter (Nat.ble PRE_first_tail_x15_r0_body.P130.N0)).all (fun i => Nat.ble i (PRE_first_tail_x15_r0_body.kd130.nodeF i) &&
    (PTrie.keysA PRE_first_tail_x15_r0_body.kd130.node).all fun j => !Nat.blt j i || Nat.blt (PRE_first_tail_x15_r0_body.kd130.nodeF j) (PRE_first_tail_x15_r0_body.kd130.nodeF i)) = true :=
  cnord_of PRE_first_tail_x15_r0_body.cnlow130 PRE_first_tail_x15_r0_body.cnn1130 PRE_first_tail_x15_r0_body.fnordI130 PRE_first_tail_x15_r0_body.fnordK130 PRE_first_tail_x15_r0_body.fnordL130
kernel_rfl PRE_first_tail_x15_r0_body.fi130 : PRE_first_tail_x15_r0_body.cli130.all (pnB PRE_first_tail_x15_r0_body.cx0_130.mlx) = true
kernel_rfl PRE_first_tail_x15_r0_body.fii130 : PRE_first_tail_x15_r0_body.cli130.all (fun k => decide (PRE_first_tail_x15_r0_body.cx1_130.mlx.items.get (PRE_first_tail_x15_r0_body.kappa130.node k) = (PRE_first_tail_x15_r0_body.cx0_130.mlx.items.get k).map PRE_first_tail_x15_r0_body.kappa130.nv)) = true
/-- **The compaction's footprint.** -/
theorem PRE_first_tail_x15_r0_body.cfoot130 (clean : Conv.NClean (⟨20770, 17862, 2777253, 5636⟩ : Conv.Cnt) (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1260.ffi).mlx) (hltC : ∀ h, PH (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1260.ffi).mlx h → h < (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1260.ffi).mlx.next) (nltC : ∀ i, PN (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1260.ffi).mlx i → i < (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1260.ffi).mlx.nnext) (itemsC : ∀ k v, (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1260.ffi).mlx.items.get k = some v → PN (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1260.ffi).mlx k) (tracedC : ∀ h o, (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1260.ffi).mlx.objs.get h = some o → ∀ i ∈ objTraces o, i < PRE_first_tail_x15_r0_body.P130.NL) (cl : SSt (· < 5636) PRE_first_tail_x15_r0_body.cx0_130.mlx) :
    Conv.MFoot PRE_first_tail_x15_r0_body.P130 5636 PRE_first_tail_x15_r0_body.kappa130 PRE_first_tail_x15_r0_body.kd130 PRE_first_tail_x15_r0_body.khinv130 PRE_first_tail_x15_r0_body.kninv130 (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1260.ffi).mlx PRE_first_tail_x15_r0_body.cx0_130.mlx PRE_first_tail_x15_r0_body.cx1_130.mlx (⟨20770, 17862, 2777253, 5636⟩ : Conv.Cnt) PRE_first_tail_x15_r0_body.clo130 PRE_first_tail_x15_r0_body.cln130 PRE_first_tail_x15_r0_body.cli130 PRE_first_tail_x15_r0_body.cwS130 PRE_first_tail_x15_r0_body.cnS130 PRE_first_tail_x15_r0_body.ciS130 :=
  ⟨rfl, rfl, rfl, PRE_first_tail_x15_r0_body.cnh0130, PRE_first_tail_x15_r0_body.cnh1130, PRE_first_tail_x15_r0_body.cnn0130, PRE_first_tail_x15_r0_body.cnn1130, PRE_first_tail_x15_r0_body.cplo130, PRE_first_tail_x15_r0_body.ccnt130, PRE_first_tail_x15_r0_body.cnband130, PRE_first_tail_x15_r0_body.chbelow130, PRE_first_tail_x15_r0_body.chren130, PRE_first_tail_x15_r0_body.cband130, PRE_first_tail_x15_r0_body.cnh1pos130, PRE_first_tail_x15_r0_body.cnren130, PRE_first_tail_x15_r0_body.cnlow130, PRE_first_tail_x15_r0_body.cabs0a130, PRE_first_tail_x15_r0_body.cabs0b130, PRE_first_tail_x15_r0_body.ctok1130, PRE_first_tail_x15_r0_body.cpend130, PRE_first_tail_x15_r0_body.cerrh130, PRE_first_tail_x15_r0_body.cfiles130, PRE_first_tail_x15_r0_body.carch130, PRE_first_tail_x15_r0_body.csizes130, PRE_first_tail_x15_r0_body.cwired130, PRE_first_tail_x15_r0_body.cfix130, clean, PRE_first_tail_x15_r0_body.fcxn130, PRE_first_tail_x15_r0_body.fcnn130, hltC, nltC, itemsC, tracedC, cl, PRE_first_tail_x15_r0_body.fle0130, PRE_first_tail_x15_r0_body.fnk130, PRE_first_tail_x15_r0_body.ckA130, PRE_first_tail_x15_r0_body.cobjsK130, PRE_first_tail_x15_r0_body.cnodesK130, PRE_first_tail_x15_r0_body.citemsK130, PRE_first_tail_x15_r0_body.f1A130, PRE_first_tail_x15_r0_body.f1O130, PRE_first_tail_x15_r0_body.f1N130, PRE_first_tail_x15_r0_body.f1I130, PRE_first_tail_x15_r0_body.fbd130, PRE_first_tail_x15_r0_body.fincW130, PRE_first_tail_x15_r0_body.fincI130, PRE_first_tail_x15_r0_body.fincN130, PRE_first_tail_x15_r0_body.flnF130, PRE_first_tail_x15_r0_body.fh130, PRE_first_tail_x15_r0_body.fo130, PRE_first_tail_x15_r0_body.fok130, PRE_first_tail_x15_r0_body.fnd130, PRE_first_tail_x15_r0_body.fp130, PRE_first_tail_x15_r0_body.fnord130, PRE_first_tail_x15_r0_body.fi130, PRE_first_tail_x15_r0_body.fii130⟩
theorem PRE_first_tail_x15_r0_body.cnshift130 (clean : Conv.NClean (⟨20770, 17862, 2777253, 5636⟩ : Conv.Cnt) (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1260.ffi).mlx) (hltC : ∀ h, PH (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1260.ffi).mlx h → h < (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1260.ffi).mlx.next) (nltC : ∀ i, PN (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1260.ffi).mlx i → i < (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1260.ffi).mlx.nnext) (itemsC : ∀ k v, (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1260.ffi).mlx.items.get k = some v → PN (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1260.ffi).mlx k) (tracedC : ∀ h o, (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1260.ffi).mlx.objs.get h = some o → ∀ i ∈ objTraces o, i < PRE_first_tail_x15_r0_body.P130.NL) (cl : SSt (· < 5636) PRE_first_tail_x15_r0_body.cx0_130.mlx) : NShift PRE_first_tail_x15_r0_body.P130 5636 PRE_first_tail_x15_r0_body.kappa130 PRE_first_tail_x15_r0_body.cx0_130 PRE_first_tail_x15_r0_body.cx1_130 :=
  Conv.nshift_of_foot (PRE_first_tail_x15_r0_body.cfoot130 clean hltC nltC itemsC tracedC cl) PRE_first_tail_x15_r0_body.chost130 (compact_a_eq PRE_first_tail_x15_r0_body.ckn0130 PRE_first_tail_x15_r0_body.ckn1130 PRE_first_tail_x15_r0_body.ckheap130 PRE_first_tail_x15_r0_body.ckpl130)

-- the observers: the layers' states at the call, the canonical and the merged state, their footprints and checks
noncomputable def PRE_first_tail_x15_r0_body.fxC_130 : PTrie Unit := (Host.Ts.Sim.Full.freedOf PRE_first_tail_x15_r0_body.s1260.ffi).getD PTrie.nil
noncomputable def PRE_first_tail_x15_r0_body.krC_130 : Host.Load.Layers.KRec := (Host.Ts.Sim.Full.krecOf PRE_first_tail_x15_r0_body.s1260.ffi).getD Host.Load.Layers.KRec.empty
kernel_rfl PRE_first_tail_x15_r0_body.ofxC_130 : (Host.Ts.Sim.Full.freedOf PRE_first_tail_x15_r0_body.s1260.ffi) = some PRE_first_tail_x15_r0_body.fxC_130
kernel_rfl PRE_first_tail_x15_r0_body.okrC_130 : (Host.Ts.Sim.Full.krecOf PRE_first_tail_x15_r0_body.s1260.ffi) = some PRE_first_tail_x15_r0_body.krC_130
noncomputable def PRE_first_tail_x15_r0_body.fx0_130 : PTrie Unit := (Host.Ts.Sim.Full.freedOf PRE_first_tail_x15_r0_body.s1262.ffi).getD PTrie.nil
noncomputable def PRE_first_tail_x15_r0_body.kr0_130 : Host.Load.Layers.KRec := (Host.Ts.Sim.Full.krecOf PRE_first_tail_x15_r0_body.s1262.ffi).getD Host.Load.Layers.KRec.empty
kernel_rfl PRE_first_tail_x15_r0_body.ofx0_130 : (Host.Ts.Sim.Full.freedOf PRE_first_tail_x15_r0_body.s1262.ffi) = some PRE_first_tail_x15_r0_body.fx0_130
kernel_rfl PRE_first_tail_x15_r0_body.okr0_130 : (Host.Ts.Sim.Full.krecOf PRE_first_tail_x15_r0_body.s1262.ffi) = some PRE_first_tail_x15_r0_body.kr0_130
noncomputable def PRE_first_tail_x15_r0_body.fx1_130 : PTrie Unit := (Host.Ts.Sim.Full.freedOf PRE_first_tail_x15_r0_body.s1261.ffi).getD PTrie.nil
noncomputable def PRE_first_tail_x15_r0_body.kr1_130 : Host.Load.Layers.KRec := (Host.Ts.Sim.Full.krecOf PRE_first_tail_x15_r0_body.s1261.ffi).getD Host.Load.Layers.KRec.empty
kernel_rfl PRE_first_tail_x15_r0_body.ofx1_130 : (Host.Ts.Sim.Full.freedOf PRE_first_tail_x15_r0_body.s1261.ffi) = some PRE_first_tail_x15_r0_body.fx1_130
kernel_rfl PRE_first_tail_x15_r0_body.okr1_130 : (Host.Ts.Sim.Full.krecOf PRE_first_tail_x15_r0_body.s1261.ffi) = some PRE_first_tail_x15_r0_body.kr1_130
kernel_rfl PRE_first_tail_x15_r0_body.ff0130 : PRE_first_tail_x15_r0_body.fx0_130 = Stage.setAll PRE_first_tail_x15_r0_body.fxC_130 (PRE_first_tail_x15_r0_body.clo130.filterMap fun i => (PRE_first_tail_x15_r0_body.fx0_130.get i).map (i, ·))
kernel_rfl PRE_first_tail_x15_r0_body.ff1130 : PRE_first_tail_x15_r0_body.fx1_130 = Stage.setAll PRE_first_tail_x15_r0_body.fxC_130 (PRE_first_tail_x15_r0_body.cwS130.filterMap fun i => (PRE_first_tail_x15_r0_body.fx1_130.get i).map (i, ·))
kernel_rfl PRE_first_tail_x15_r0_body.ffck130 : freedLB PRE_first_tail_x15_r0_body.kappa130 PRE_first_tail_x15_r0_body.cx0_130.mlx PRE_first_tail_x15_r0_body.fx0_130 PRE_first_tail_x15_r0_body.fx1_130 PRE_first_tail_x15_r0_body.clo130 = true
kernel_rfl PRE_first_tail_x15_r0_body.fkf0130 : PRE_first_tail_x15_r0_body.kr0_130.flags = Stage.setAll PRE_first_tail_x15_r0_body.krC_130.flags (PRE_first_tail_x15_r0_body.clo130.filterMap fun i => (PRE_first_tail_x15_r0_body.kr0_130.flags.get i).map (i, ·))
kernel_rfl PRE_first_tail_x15_r0_body.fkt0130 : PRE_first_tail_x15_r0_body.kr0_130.targs = Stage.setAll PRE_first_tail_x15_r0_body.krC_130.targs (PRE_first_tail_x15_r0_body.clo130.filterMap fun i => (PRE_first_tail_x15_r0_body.kr0_130.targs.get i).map (i, ·))
kernel_rfl PRE_first_tail_x15_r0_body.fkf1130 : PRE_first_tail_x15_r0_body.kr1_130.flags = Stage.setAll PRE_first_tail_x15_r0_body.krC_130.flags (PRE_first_tail_x15_r0_body.cwS130.filterMap fun i => (PRE_first_tail_x15_r0_body.kr1_130.flags.get i).map (i, ·))
kernel_rfl PRE_first_tail_x15_r0_body.fkt1130 : PRE_first_tail_x15_r0_body.kr1_130.targs = Stage.setAll PRE_first_tail_x15_r0_body.krC_130.targs (PRE_first_tail_x15_r0_body.cwS130.filterMap fun i => (PRE_first_tail_x15_r0_body.kr1_130.targs.get i).map (i, ·))
kernel_rfl PRE_first_tail_x15_r0_body.fkck130 : krecLB PRE_first_tail_x15_r0_body.kappa130 5636 PRE_first_tail_x15_r0_body.cx0_130.mlx PRE_first_tail_x15_r0_body.kr0_130 PRE_first_tail_x15_r0_body.kr1_130 PRE_first_tail_x15_r0_body.clo130 = true
kernel_rfl PRE_first_tail_x15_r0_body.fkn130 : Nat.ble 5636 5636 = true
-- the bridge and the pending traces' regions
kernel_rfl PRE_first_tail_x15_r0_body.cbridge130 : Host.Ts.Sim.Full.bridgeOf PRE_first_tail_x15_r0_body.s1261.ffi = Host.Ts.Sim.Full.bridgeOf PRE_first_tail_x15_r0_body.s1262.ffi
kernel_rfl PRE_first_tail_x15_r0_body.cpendR130 : pendRegB PRE_first_tail_x15_r0_body.kappa130 (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1262.ffi).mlx = true
kernel_rfl PRE_first_tail_x15_r0_body.cpendLe130 : Nat.ble (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1262.ffi).mlx.next (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1261.ffi).mlx.next = true
/-- **The compaction's native shift**, given the call's bookkeeping, its relation's facts (the model's and the
observers') and the canonical closedness. -/
theorem PRE_first_tail_x15_r0_body.cshift130 (clean : Conv.NClean (⟨20770, 17862, 2777253, 5636⟩ : Conv.Cnt) (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1260.ffi).mlx) (hltC : ∀ h, PH (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1260.ffi).mlx h → h < (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1260.ffi).mlx.next) (nltC : ∀ i, PN (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1260.ffi).mlx i → i < (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1260.ffi).mlx.nnext) (itemsC : ∀ k v, (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1260.ffi).mlx.items.get k = some v → PN (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1260.ffi).mlx k) (tracedC : ∀ h o, (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1260.ffi).mlx.objs.get h = some o → ∀ i ∈ objTraces o, i < PRE_first_tail_x15_r0_body.P130.NL) (cl : SSt (· < 5636) PRE_first_tail_x15_r0_body.cx0_130.mlx)
    (hobjC : ∀ h, PRE_first_tail_x15_r0_body.fxC_130.get h = some () → ((Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1260.ffi).mlx.objs.get h).isSome = true)
    (hfC : ∀ h, (PRE_first_tail_x15_r0_body.krC_130.flags.get h).isSome = true → ((Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1260.ffi).mlx.objs.get h).isSome = true)
    (htC : ∀ h, (PRE_first_tail_x15_r0_body.krC_130.targs.get h).isSome = true → ((Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1260.ffi).mlx.objs.get h).isSome = true)
    (hclC : ∀ h l, PRE_first_tail_x15_r0_body.krC_130.targs.get h = some l → Host.Ts.Sim.Full.STargs (· < (⟨20770, 17862, 2777253, 5636⟩ : Conv.Cnt).n) l) :
    Conv.FullShiftQ PRE_first_tail_x15_r0_body.P130 5636 PRE_first_tail_x15_r0_body.kappa130 PRE_first_tail_x15_r0_body.s1262.ffi PRE_first_tail_x15_r0_body.s1261.ffi :=
  ⟨PRE_first_tail_x15_r0_body.cnshift130 clean hltC nltC itemsC tracedC cl, PRE_first_tail_x15_r0_body.cqueue130, fun t ht => bSN_sound (List.all_eq_true.mp PRE_first_tail_x15_r0_body.ctokSupp130 t ht),
    PRE_first_tail_x15_r0_body.cbridge130,
    liveShift_foot (x0' := Host.Ts.Sim.Full.mlxOf PRE_first_tail_x15_r0_body.s1262.ffi) (x1' := Host.Ts.Sim.Full.mlxOf PRE_first_tail_x15_r0_body.s1261.ffi) (PRE_first_tail_x15_r0_body.cfoot130 clean hltC nltC itemsC tracedC cl) rfl PRE_first_tail_x15_r0_body.ofx0_130 PRE_first_tail_x15_r0_body.ofx1_130 hobjC PRE_first_tail_x15_r0_body.ff0130 PRE_first_tail_x15_r0_body.ff1130 PRE_first_tail_x15_r0_body.ffck130,
    kernShift_foot (x0' := Host.Ts.Sim.Full.mlxOf PRE_first_tail_x15_r0_body.s1262.ffi) (x1' := Host.Ts.Sim.Full.mlxOf PRE_first_tail_x15_r0_body.s1261.ffi) (PRE_first_tail_x15_r0_body.cfoot130 clean hltC nltC itemsC tracedC cl) rfl PRE_first_tail_x15_r0_body.okr0_130 PRE_first_tail_x15_r0_body.okr1_130 (Nat.le_of_ble_eq_true PRE_first_tail_x15_r0_body.fkn130) hfC htC hclC
      PRE_first_tail_x15_r0_body.fkf0130 PRE_first_tail_x15_r0_body.fkt0130 PRE_first_tail_x15_r0_body.fkf1130 PRE_first_tail_x15_r0_body.fkt1130 PRE_first_tail_x15_r0_body.fkck130,
    pendReg_of rfl PRE_first_tail_x15_r0_body.cnh0130 PRE_first_tail_x15_r0_body.cnh1130 (Nat.le_of_ble_eq_true PRE_first_tail_x15_r0_body.cpendLe130) PRE_first_tail_x15_r0_body.cpendR130⟩

end Host.Load.Run.Tpl
