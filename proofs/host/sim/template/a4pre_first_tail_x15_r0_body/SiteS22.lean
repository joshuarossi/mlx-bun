import host.sim.template.a4pre_first_tail_x15_r0_body.SiteCl22
import host.sim.conv.CompactFull
import host.sim.template.FootGen
set_option Elab.async false
namespace Host.Load.Run.Tpl
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
open Host.Ts Host.Ts.Sim Host.Ts.Sim.Template

/-! The compaction's native shift at call site 22 from its footprint (`Conv.nshift_of_foot`), and the observers'
(`liveShift_foot`, `kernShift_foot`): `Conv.FullShiftQ` for `Conv.full_compactQ`, given the call's bookkeeping and its
relation's facts. -/

/-- The load parameters of the chain (band-free: its start's node counter as `NL` and `N0`). -/
def PRE_first_tail_x15_r0_body.Pc22 : LoadP := ⟨18151, 131072, 1099511627776, 15235, 15235, []⟩
/-- The site's band raised to the map's checked fixed-node prefix, including newly recorded closure traces. -/
def PRE_first_tail_x15_r0_body.P22 : LoadP := PRE_first_tail_x15_r0_body.Pc22.raise 15729
kernel_rfl PRE_first_tail_x15_r0_body.craise22 : Nat.ble PRE_first_tail_x15_r0_body.Pc22.N0 15729 = true
theorem PRE_first_tail_x15_r0_body.raised22 : Host.Ts.Sim.Full.Raised PRE_first_tail_x15_r0_body.Pc22 PRE_first_tail_x15_r0_body.P22 :=
  .inr ⟨15729, rfl, Nat.le_of_ble_eq_true PRE_first_tail_x15_r0_body.craise22, rfl⟩
noncomputable abbrev PRE_first_tail_x15_r0_body.cx0_22 : Host.Load.LSt := clearTokens (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s206.ffi)
noncomputable abbrev PRE_first_tail_x15_r0_body.cx1_22 : Host.Load.LSt := clearTokens (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s205.ffi)
def PRE_first_tail_x15_r0_body.khinv22 : PTrie Nat := Stage.setAll PTrie.nil []
def PRE_first_tail_x15_r0_body.kninv22 : PTrie Nat := Stage.setAll PTrie.nil []
/-- The stage's footprint: its written and fresh handles, fresh nodes, written and fresh items. -/
def PRE_first_tail_x15_r0_body.cwS22 : List Nat := []
def PRE_first_tail_x15_r0_body.cnS22 : List Nat := List.range' 15729 0
def PRE_first_tail_x15_r0_body.ciS22 : List Nat := [] ++ List.range' 15729 0

-- the small checks (`MChecks`'s)
kernel_rfl PRE_first_tail_x15_r0_body.cnh022 : PRE_first_tail_x15_r0_body.kd22.nh0 = PRE_first_tail_x15_r0_body.cx0_22.mlx.next
kernel_rfl PRE_first_tail_x15_r0_body.cnh122 : PRE_first_tail_x15_r0_body.kd22.nh1 = PRE_first_tail_x15_r0_body.cx1_22.mlx.next
kernel_rfl PRE_first_tail_x15_r0_body.cnn022 : PRE_first_tail_x15_r0_body.kd22.nn0 = PRE_first_tail_x15_r0_body.cx0_22.mlx.nnext
kernel_rfl PRE_first_tail_x15_r0_body.cnn122 : PRE_first_tail_x15_r0_body.kd22.nn1 = PRE_first_tail_x15_r0_body.cx1_22.mlx.nnext
kernel_rfl PRE_first_tail_x15_r0_body.cplo22 : (Nat.blt 0 PRE_first_tail_x15_r0_body.P22.lo && Nat.ble PRE_first_tail_x15_r0_body.P22.lo PRE_first_tail_x15_r0_body.cx0_22.mlx.next && Nat.ble PRE_first_tail_x15_r0_body.P22.lo RData.bigHi && Nat.ble RData.bigHi PRE_first_tail_x15_r0_body.P22.E) = true
kernel_rfl PRE_first_tail_x15_r0_body.ccnt22 : (Nat.ble PRE_first_tail_x15_r0_body.cx0_22.mlx.next PRE_first_tail_x15_r0_body.cx1_22.mlx.next && Nat.ble PRE_first_tail_x15_r0_body.cx0_22.mlx.nnext PRE_first_tail_x15_r0_body.cx1_22.mlx.nnext) = true
kernel_rfl PRE_first_tail_x15_r0_body.cnband22 : (Nat.blt 0 PRE_first_tail_x15_r0_body.P22.NL && Nat.ble PRE_first_tail_x15_r0_body.P22.NL PRE_first_tail_x15_r0_body.P22.N0 && Nat.ble PRE_first_tail_x15_r0_body.P22.N0 PRE_first_tail_x15_r0_body.cx0_22.mlx.nnext) = true
kernel_rfl PRE_first_tail_x15_r0_body.chbelow22 : PRE_first_tail_x15_r0_body.kd22.checkHndBelow = true
kernel_rfl PRE_first_tail_x15_r0_body.chren22 : checkRenG PRE_first_tail_x15_r0_body.kd22.hnd PRE_first_tail_x15_r0_body.khinv22 (phB PRE_first_tail_x15_r0_body.cx0_22.mlx) = true
kernel_rfl PRE_first_tail_x15_r0_body.cband22 : PRE_first_tail_x15_r0_body.kd22.checkBand PRE_first_tail_x15_r0_body.P22.lo = true
kernel_rfl PRE_first_tail_x15_r0_body.cnh1pos22 : Nat.blt 0 PRE_first_tail_x15_r0_body.kd22.nh1 = true
kernel_rfl PRE_first_tail_x15_r0_body.cnren22 : checkRenG PRE_first_tail_x15_r0_body.kd22.node PRE_first_tail_x15_r0_body.kninv22 (pnB PRE_first_tail_x15_r0_body.cx0_22.mlx) = true
kernel_rfl PRE_first_tail_x15_r0_body.cnlow22 : (PTrie.keysA PRE_first_tail_x15_r0_body.kd22.node).all (fun j => Nat.ble PRE_first_tail_x15_r0_body.P22.NL j && Nat.blt (PRE_first_tail_x15_r0_body.kd22.nodeF j) PRE_first_tail_x15_r0_body.cx1_22.mlx.nnext) = true
kernel_rfl PRE_first_tail_x15_r0_body.cabs0a22 : PRE_first_tail_x15_r0_body.cx0_22.mlx.arrs.get 0 = none
kernel_rfl PRE_first_tail_x15_r0_body.cabs0b22 : PRE_first_tail_x15_r0_body.cx0_22.mlx.objs.get 0 = none
kernel_rfl PRE_first_tail_x15_r0_body.ctok122 : PRE_first_tail_x15_r0_body.cx1_22.mlx.tokens = []
kernel_rfl PRE_first_tail_x15_r0_body.cpend22 : PRE_first_tail_x15_r0_body.cx1_22.mlx.pending = PRE_first_tail_x15_r0_body.cx0_22.mlx.pending.map PRE_first_tail_x15_r0_body.kappa22.pend
kernel_rfl PRE_first_tail_x15_r0_body.cerrh22 : PRE_first_tail_x15_r0_body.cx1_22.mlx.errh = PRE_first_tail_x15_r0_body.cx0_22.mlx.errh.map PRE_first_tail_x15_r0_body.kappa22.arg
kernel_rfl PRE_first_tail_x15_r0_body.cfiles22 : PRE_first_tail_x15_r0_body.cx1_22.mlx.files = PRE_first_tail_x15_r0_body.cx0_22.mlx.files
kernel_rfl PRE_first_tail_x15_r0_body.carch22 : PRE_first_tail_x15_r0_body.cx1_22.mlx.arch = PRE_first_tail_x15_r0_body.cx0_22.mlx.arch
kernel_rfl PRE_first_tail_x15_r0_body.csizes22 : PRE_first_tail_x15_r0_body.cx1_22.mlx.deviceSizes = PRE_first_tail_x15_r0_body.cx0_22.mlx.deviceSizes
kernel_rfl PRE_first_tail_x15_r0_body.cwired22 : PRE_first_tail_x15_r0_body.cx1_22.mlx.wired = PRE_first_tail_x15_r0_body.cx0_22.mlx.wired
kernel_rfl PRE_first_tail_x15_r0_body.chost22 : PRE_first_tail_x15_r0_body.cx1_22.host = PRE_first_tail_x15_r0_body.cx0_22.host
-- the compaction map's addresses are `PRE_first_tail_x15_r0_body.kd22`'s
kernel_rfl PRE_first_tail_x15_r0_body.ckn022 : PRE_first_tail_x15_r0_body.kd22.n0 = 2692505
kernel_rfl PRE_first_tail_x15_r0_body.ckn122 : PRE_first_tail_x15_r0_body.kd22.n1 = 2692507
kernel_rfl PRE_first_tail_x15_r0_body.ckheap22 : (PTrie.keysA PRE_first_tail_x15_r0_body.kd22.heap).all (fun x => Nat.ble 2692505 x) = true
kernel_rfl PRE_first_tail_x15_r0_body.ckpl22 : (List.range 0).all (fun j => decide (PRE_first_tail_x15_r0_body.kd22.heap.get (2692505 + j) = nth? PRE_first_tail_x15_r0_body.pl22 j)) = true
-- the map fixes the call's names (`Conv.fixOld_compact`), the call's counters
kernel_rfl PRE_first_tail_x15_r0_body.fja22 : Nat.ble 2692505 2692505 = true
kernel_rfl PRE_first_tail_x15_r0_body.fn22 : Nat.ble 1019 1019 = true
kernel_rfl PRE_first_tail_x15_r0_body.fjaD22 : Nat.ble 2692505 PRE_first_tail_x15_r0_body.kd22.n0 = true
kernel_rfl PRE_first_tail_x15_r0_body.fxn22 : Nat.ble 18646 PRE_first_tail_x15_r0_body.kd22.nh0 = true
kernel_rfl PRE_first_tail_x15_r0_body.fnn22 : Nat.ble 15729 PRE_first_tail_x15_r0_body.kd22.nn0 = true
kernel_rfl PRE_first_tail_x15_r0_body.fxb22 : Nat.ble 18646 RData.bigHi = true
kernel_rfl PRE_first_tail_x15_r0_body.fheap22 : (PTrie.keysA PRE_first_tail_x15_r0_body.kd22.heap).all (Nat.ble (⟨18646, 15729, 2692505, 1019⟩ : Conv.Cnt).ja) = true
kernel_rfl PRE_first_tail_x15_r0_body.fhnd22 : (PTrie.keysA PRE_first_tail_x15_r0_body.kd22.hnd).all (Nat.ble (⟨18646, 15729, 2692505, 1019⟩ : Conv.Cnt).xn) = true
kernel_rfl PRE_first_tail_x15_r0_body.fnode22 : (PTrie.keysA PRE_first_tail_x15_r0_body.kd22.node).all (Nat.ble (⟨18646, 15729, 2692505, 1019⟩ : Conv.Cnt).nn) = true
/-- The compaction map fixes the call's names. -/
theorem PRE_first_tail_x15_r0_body.cfix22 : Conv.FixOld (⟨18646, 15729, 2692505, 1019⟩ : Conv.Cnt) PRE_first_tail_x15_r0_body.kappa22 :=
  Conv.fixOld_compact (Nat.le_of_ble_eq_true PRE_first_tail_x15_r0_body.fja22) (Nat.le_of_ble_eq_true PRE_first_tail_x15_r0_body.fn22) (Nat.le_of_ble_eq_true PRE_first_tail_x15_r0_body.fjaD22) (Nat.le_of_ble_eq_true PRE_first_tail_x15_r0_body.fxn22) (Nat.le_of_ble_eq_true PRE_first_tail_x15_r0_body.fnn22) (Nat.le_of_ble_eq_true PRE_first_tail_x15_r0_body.fxb22) PRE_first_tail_x15_r0_body.fheap22 PRE_first_tail_x15_r0_body.fhnd22 PRE_first_tail_x15_r0_body.fnode22
kernel_rfl PRE_first_tail_x15_r0_body.fcxn22 : (⟨18646, 15729, 2692505, 1019⟩ : Conv.Cnt).xn = (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s204.ffi).mlx.next
kernel_rfl PRE_first_tail_x15_r0_body.fcnn22 : (⟨18646, 15729, 2692505, 1019⟩ : Conv.Cnt).nn = (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s204.ffi).mlx.nnext
kernel_rfl PRE_first_tail_x15_r0_body.fle022 : (Nat.ble (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s204.ffi).mlx.next PRE_first_tail_x15_r0_body.cx0_22.mlx.next && Nat.ble (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s204.ffi).mlx.nnext PRE_first_tail_x15_r0_body.cx0_22.mlx.nnext && Nat.ble (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s204.ffi).mlx.next RData.bigHi) = true
kernel_rfl PRE_first_tail_x15_r0_body.fnk22 : (PTrie.keysA PRE_first_tail_x15_r0_body.kd22.node).all (Nat.ble (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s204.ffi).mlx.nnext) = true
-- the merged state keeps the call's entries off the stage's footprint
kernel_rfl PRE_first_tail_x15_r0_body.f1A22 : PRE_first_tail_x15_r0_body.cx1_22.mlx.arrs = Stage.setAll (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s204.ffi).mlx.arrs (PRE_first_tail_x15_r0_body.cwS22.filterMap fun i => (PRE_first_tail_x15_r0_body.cx1_22.mlx.arrs.get i).map (i, ·))
kernel_rfl PRE_first_tail_x15_r0_body.f1O22 : PRE_first_tail_x15_r0_body.cx1_22.mlx.objs = Stage.setAll (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s204.ffi).mlx.objs (PRE_first_tail_x15_r0_body.cwS22.filterMap fun i => (PRE_first_tail_x15_r0_body.cx1_22.mlx.objs.get i).map (i, ·))
kernel_rfl PRE_first_tail_x15_r0_body.f1N22 : PRE_first_tail_x15_r0_body.cx1_22.mlx.nodes = Stage.setAll (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s204.ffi).mlx.nodes (PRE_first_tail_x15_r0_body.cnS22.filterMap fun i => (PRE_first_tail_x15_r0_body.cx1_22.mlx.nodes.get i).map (i, ·))
kernel_rfl PRE_first_tail_x15_r0_body.f1I22 : PRE_first_tail_x15_r0_body.cx1_22.mlx.items = Stage.setAll (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s204.ffi).mlx.items (PRE_first_tail_x15_r0_body.ciS22.filterMap fun i => (PRE_first_tail_x15_r0_body.cx1_22.mlx.items.get i).map (i, ·))
kernel_rfl PRE_first_tail_x15_r0_body.fbd22 : (PRE_first_tail_x15_r0_body.clo22 ++ PRE_first_tail_x15_r0_body.cln22 ++ PRE_first_tail_x15_r0_body.cli22 ++ PRE_first_tail_x15_r0_body.cwS22 ++ PRE_first_tail_x15_r0_body.cnS22 ++ PRE_first_tail_x15_r0_body.ciS22).all (fun i => Nat.blt (i / 4096) (4 ^ 31)) = true
kernel_rfl PRE_first_tail_x15_r0_body.fincW22 : PRE_first_tail_x15_r0_body.cwS22.all (fun h => !Nat.blt h (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s204.ffi).mlx.next || PRE_first_tail_x15_r0_body.clo22.contains h) = true
kernel_rfl PRE_first_tail_x15_r0_body.fincI22 : PRE_first_tail_x15_r0_body.ciS22.all (fun k => !Nat.blt k (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s204.ffi).mlx.nnext || PRE_first_tail_x15_r0_body.cli22.contains k) = true
kernel_rfl PRE_first_tail_x15_r0_body.fincN22 : PRE_first_tail_x15_r0_body.cnS22.all (Nat.ble (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s204.ffi).mlx.nnext) = true
kernel_rfl PRE_first_tail_x15_r0_body.flnF22 : PRE_first_tail_x15_r0_body.cln22.all (Nat.ble (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s204.ffi).mlx.nnext) = true
-- the checks over the changed lists
kernel_rfl PRE_first_tail_x15_r0_body.fh22 : PRE_first_tail_x15_r0_body.clo22.all (handleOK PRE_first_tail_x15_r0_body.kappa22 PRE_first_tail_x15_r0_body.P22.lo PRE_first_tail_x15_r0_body.cx0_22.mlx PRE_first_tail_x15_r0_body.cx1_22.mlx) = true
kernel_rfl PRE_first_tail_x15_r0_body.fo22 : PRE_first_tail_x15_r0_body.clo22.map (fun h => PRE_first_tail_x15_r0_body.cx1_22.mlx.objs.get (PRE_first_tail_x15_r0_body.kappa22.handle h)) = PRE_first_tail_x15_r0_body.clo22.map (fun h => (PRE_first_tail_x15_r0_body.cx0_22.mlx.objs.get h).map PRE_first_tail_x15_r0_body.kappa22.nobj)
kernel_rfl PRE_first_tail_x15_r0_body.fok22 : PRE_first_tail_x15_r0_body.clo22.all (objOK PRE_first_tail_x15_r0_body.kappa22 PRE_first_tail_x15_r0_body.P22.NL PRE_first_tail_x15_r0_body.cx0_22.mlx) = true
kernel_rfl PRE_first_tail_x15_r0_body.fnd22 : PRE_first_tail_x15_r0_body.cln22.all (nodeOKF PRE_first_tail_x15_r0_body.kappa22 PRE_first_tail_x15_r0_body.P22 PRE_first_tail_x15_r0_body.cx0_22.mlx PRE_first_tail_x15_r0_body.cx1_22.mlx) = true
kernel_rfl PRE_first_tail_x15_r0_body.fp22 : ((PRE_first_tail_x15_r0_body.cln22.filter (fullB PRE_first_tail_x15_r0_body.P22))).map (fun i => (PRE_first_tail_x15_r0_body.cx1_22.mlx.nodes.get (PRE_first_tail_x15_r0_body.kappa22.node i)).map Host.Mlx.Ffi.Node.prim) =
  ((PRE_first_tail_x15_r0_body.cln22.filter (fullB PRE_first_tail_x15_r0_body.P22))).map (fun i => (PRE_first_tail_x15_r0_body.cx0_22.mlx.nodes.get i).map fun nd => PRE_first_tail_x15_r0_body.kappa22.prim nd.prim)
kernel_rfl PRE_first_tail_x15_r0_body.fnordI22 : incrB PRE_first_tail_x15_r0_body.kd22.nodeF (List.range' 15729 0) = true
kernel_rfl PRE_first_tail_x15_r0_body.fnordK22 : (PTrie.keysA PRE_first_tail_x15_r0_body.kd22.node).all (fun k => Nat.ble 15729 k && Nat.blt k 15729) = true
kernel_rfl PRE_first_tail_x15_r0_body.fnordL22 : (PRE_first_tail_x15_r0_body.cln22.filter (Nat.ble PRE_first_tail_x15_r0_body.P22.N0)).all (fun i => Nat.ble i (PRE_first_tail_x15_r0_body.kd22.nodeF i) && (Nat.blt i 15729 || Nat.ble PRE_first_tail_x15_r0_body.kd22.nn0 i)) = true
theorem PRE_first_tail_x15_r0_body.fnord22 : (PRE_first_tail_x15_r0_body.cln22.filter (Nat.ble PRE_first_tail_x15_r0_body.P22.N0)).all (fun i => Nat.ble i (PRE_first_tail_x15_r0_body.kd22.nodeF i) &&
    (PTrie.keysA PRE_first_tail_x15_r0_body.kd22.node).all fun j => !Nat.blt j i || Nat.blt (PRE_first_tail_x15_r0_body.kd22.nodeF j) (PRE_first_tail_x15_r0_body.kd22.nodeF i)) = true :=
  cnord_of PRE_first_tail_x15_r0_body.cnlow22 PRE_first_tail_x15_r0_body.cnn122 PRE_first_tail_x15_r0_body.fnordI22 PRE_first_tail_x15_r0_body.fnordK22 PRE_first_tail_x15_r0_body.fnordL22
kernel_rfl PRE_first_tail_x15_r0_body.fi22 : PRE_first_tail_x15_r0_body.cli22.all (pnB PRE_first_tail_x15_r0_body.cx0_22.mlx) = true
kernel_rfl PRE_first_tail_x15_r0_body.fii22 : PRE_first_tail_x15_r0_body.cli22.all (fun k => decide (PRE_first_tail_x15_r0_body.cx1_22.mlx.items.get (PRE_first_tail_x15_r0_body.kappa22.node k) = (PRE_first_tail_x15_r0_body.cx0_22.mlx.items.get k).map PRE_first_tail_x15_r0_body.kappa22.nv)) = true
/-- **The compaction's footprint.** -/
theorem PRE_first_tail_x15_r0_body.cfoot22 (clean : Conv.NClean (⟨18646, 15729, 2692505, 1019⟩ : Conv.Cnt) (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s204.ffi).mlx) (hltC : ∀ h, PH (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s204.ffi).mlx h → h < (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s204.ffi).mlx.next) (nltC : ∀ i, PN (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s204.ffi).mlx i → i < (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s204.ffi).mlx.nnext) (itemsC : ∀ k v, (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s204.ffi).mlx.items.get k = some v → PN (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s204.ffi).mlx k) (tracedC : ∀ h o, (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s204.ffi).mlx.objs.get h = some o → ∀ i ∈ objTraces o, i < PRE_first_tail_x15_r0_body.P22.NL) (cl : SSt (· < 1019) PRE_first_tail_x15_r0_body.cx0_22.mlx) :
    Conv.MFoot PRE_first_tail_x15_r0_body.P22 1019 PRE_first_tail_x15_r0_body.kappa22 PRE_first_tail_x15_r0_body.kd22 PRE_first_tail_x15_r0_body.khinv22 PRE_first_tail_x15_r0_body.kninv22 (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s204.ffi).mlx PRE_first_tail_x15_r0_body.cx0_22.mlx PRE_first_tail_x15_r0_body.cx1_22.mlx (⟨18646, 15729, 2692505, 1019⟩ : Conv.Cnt) PRE_first_tail_x15_r0_body.clo22 PRE_first_tail_x15_r0_body.cln22 PRE_first_tail_x15_r0_body.cli22 PRE_first_tail_x15_r0_body.cwS22 PRE_first_tail_x15_r0_body.cnS22 PRE_first_tail_x15_r0_body.ciS22 :=
  ⟨rfl, rfl, rfl, PRE_first_tail_x15_r0_body.cnh022, PRE_first_tail_x15_r0_body.cnh122, PRE_first_tail_x15_r0_body.cnn022, PRE_first_tail_x15_r0_body.cnn122, PRE_first_tail_x15_r0_body.cplo22, PRE_first_tail_x15_r0_body.ccnt22, PRE_first_tail_x15_r0_body.cnband22, PRE_first_tail_x15_r0_body.chbelow22, PRE_first_tail_x15_r0_body.chren22, PRE_first_tail_x15_r0_body.cband22, PRE_first_tail_x15_r0_body.cnh1pos22, PRE_first_tail_x15_r0_body.cnren22, PRE_first_tail_x15_r0_body.cnlow22, PRE_first_tail_x15_r0_body.cabs0a22, PRE_first_tail_x15_r0_body.cabs0b22, PRE_first_tail_x15_r0_body.ctok122, PRE_first_tail_x15_r0_body.cpend22, PRE_first_tail_x15_r0_body.cerrh22, PRE_first_tail_x15_r0_body.cfiles22, PRE_first_tail_x15_r0_body.carch22, PRE_first_tail_x15_r0_body.csizes22, PRE_first_tail_x15_r0_body.cwired22, PRE_first_tail_x15_r0_body.cfix22, clean, PRE_first_tail_x15_r0_body.fcxn22, PRE_first_tail_x15_r0_body.fcnn22, hltC, nltC, itemsC, tracedC, cl, PRE_first_tail_x15_r0_body.fle022, PRE_first_tail_x15_r0_body.fnk22, PRE_first_tail_x15_r0_body.ckA22, PRE_first_tail_x15_r0_body.cobjsK22, PRE_first_tail_x15_r0_body.cnodesK22, PRE_first_tail_x15_r0_body.citemsK22, PRE_first_tail_x15_r0_body.f1A22, PRE_first_tail_x15_r0_body.f1O22, PRE_first_tail_x15_r0_body.f1N22, PRE_first_tail_x15_r0_body.f1I22, PRE_first_tail_x15_r0_body.fbd22, PRE_first_tail_x15_r0_body.fincW22, PRE_first_tail_x15_r0_body.fincI22, PRE_first_tail_x15_r0_body.fincN22, PRE_first_tail_x15_r0_body.flnF22, PRE_first_tail_x15_r0_body.fh22, PRE_first_tail_x15_r0_body.fo22, PRE_first_tail_x15_r0_body.fok22, PRE_first_tail_x15_r0_body.fnd22, PRE_first_tail_x15_r0_body.fp22, PRE_first_tail_x15_r0_body.fnord22, PRE_first_tail_x15_r0_body.fi22, PRE_first_tail_x15_r0_body.fii22⟩
theorem PRE_first_tail_x15_r0_body.cnshift22 (clean : Conv.NClean (⟨18646, 15729, 2692505, 1019⟩ : Conv.Cnt) (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s204.ffi).mlx) (hltC : ∀ h, PH (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s204.ffi).mlx h → h < (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s204.ffi).mlx.next) (nltC : ∀ i, PN (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s204.ffi).mlx i → i < (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s204.ffi).mlx.nnext) (itemsC : ∀ k v, (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s204.ffi).mlx.items.get k = some v → PN (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s204.ffi).mlx k) (tracedC : ∀ h o, (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s204.ffi).mlx.objs.get h = some o → ∀ i ∈ objTraces o, i < PRE_first_tail_x15_r0_body.P22.NL) (cl : SSt (· < 1019) PRE_first_tail_x15_r0_body.cx0_22.mlx) : NShift PRE_first_tail_x15_r0_body.P22 1019 PRE_first_tail_x15_r0_body.kappa22 PRE_first_tail_x15_r0_body.cx0_22 PRE_first_tail_x15_r0_body.cx1_22 :=
  Conv.nshift_of_foot (PRE_first_tail_x15_r0_body.cfoot22 clean hltC nltC itemsC tracedC cl) PRE_first_tail_x15_r0_body.chost22 (compact_a_eq PRE_first_tail_x15_r0_body.ckn022 PRE_first_tail_x15_r0_body.ckn122 PRE_first_tail_x15_r0_body.ckheap22 PRE_first_tail_x15_r0_body.ckpl22)

-- the observers: the layers' states at the call, the canonical and the merged state, their footprints and checks
noncomputable def PRE_first_tail_x15_r0_body.fxC_22 : PTrie Unit := (Host.Ts.Sim.Full.freedOf PRE_first_tail_x15_r0_body.s204.ffi).getD PTrie.nil
noncomputable def PRE_first_tail_x15_r0_body.krC_22 : Host.Load.Layers.KRec := (Host.Ts.Sim.Full.krecOf PRE_first_tail_x15_r0_body.s204.ffi).getD Host.Load.Layers.KRec.empty
kernel_rfl PRE_first_tail_x15_r0_body.ofxC_22 : (Host.Ts.Sim.Full.freedOf PRE_first_tail_x15_r0_body.s204.ffi) = some PRE_first_tail_x15_r0_body.fxC_22
kernel_rfl PRE_first_tail_x15_r0_body.okrC_22 : (Host.Ts.Sim.Full.krecOf PRE_first_tail_x15_r0_body.s204.ffi) = some PRE_first_tail_x15_r0_body.krC_22
noncomputable def PRE_first_tail_x15_r0_body.fx0_22 : PTrie Unit := (Host.Ts.Sim.Full.freedOf PRE_first_tail_x15_r0_body.s206.ffi).getD PTrie.nil
noncomputable def PRE_first_tail_x15_r0_body.kr0_22 : Host.Load.Layers.KRec := (Host.Ts.Sim.Full.krecOf PRE_first_tail_x15_r0_body.s206.ffi).getD Host.Load.Layers.KRec.empty
kernel_rfl PRE_first_tail_x15_r0_body.ofx0_22 : (Host.Ts.Sim.Full.freedOf PRE_first_tail_x15_r0_body.s206.ffi) = some PRE_first_tail_x15_r0_body.fx0_22
kernel_rfl PRE_first_tail_x15_r0_body.okr0_22 : (Host.Ts.Sim.Full.krecOf PRE_first_tail_x15_r0_body.s206.ffi) = some PRE_first_tail_x15_r0_body.kr0_22
noncomputable def PRE_first_tail_x15_r0_body.fx1_22 : PTrie Unit := (Host.Ts.Sim.Full.freedOf PRE_first_tail_x15_r0_body.s205.ffi).getD PTrie.nil
noncomputable def PRE_first_tail_x15_r0_body.kr1_22 : Host.Load.Layers.KRec := (Host.Ts.Sim.Full.krecOf PRE_first_tail_x15_r0_body.s205.ffi).getD Host.Load.Layers.KRec.empty
kernel_rfl PRE_first_tail_x15_r0_body.ofx1_22 : (Host.Ts.Sim.Full.freedOf PRE_first_tail_x15_r0_body.s205.ffi) = some PRE_first_tail_x15_r0_body.fx1_22
kernel_rfl PRE_first_tail_x15_r0_body.okr1_22 : (Host.Ts.Sim.Full.krecOf PRE_first_tail_x15_r0_body.s205.ffi) = some PRE_first_tail_x15_r0_body.kr1_22
kernel_rfl PRE_first_tail_x15_r0_body.ff022 : PRE_first_tail_x15_r0_body.fx0_22 = Stage.setAll PRE_first_tail_x15_r0_body.fxC_22 (PRE_first_tail_x15_r0_body.clo22.filterMap fun i => (PRE_first_tail_x15_r0_body.fx0_22.get i).map (i, ·))
kernel_rfl PRE_first_tail_x15_r0_body.ff122 : PRE_first_tail_x15_r0_body.fx1_22 = Stage.setAll PRE_first_tail_x15_r0_body.fxC_22 (PRE_first_tail_x15_r0_body.cwS22.filterMap fun i => (PRE_first_tail_x15_r0_body.fx1_22.get i).map (i, ·))
kernel_rfl PRE_first_tail_x15_r0_body.ffck22 : freedLB PRE_first_tail_x15_r0_body.kappa22 PRE_first_tail_x15_r0_body.cx0_22.mlx PRE_first_tail_x15_r0_body.fx0_22 PRE_first_tail_x15_r0_body.fx1_22 PRE_first_tail_x15_r0_body.clo22 = true
kernel_rfl PRE_first_tail_x15_r0_body.fkf022 : PRE_first_tail_x15_r0_body.kr0_22.flags = Stage.setAll PRE_first_tail_x15_r0_body.krC_22.flags (PRE_first_tail_x15_r0_body.clo22.filterMap fun i => (PRE_first_tail_x15_r0_body.kr0_22.flags.get i).map (i, ·))
kernel_rfl PRE_first_tail_x15_r0_body.fkt022 : PRE_first_tail_x15_r0_body.kr0_22.targs = Stage.setAll PRE_first_tail_x15_r0_body.krC_22.targs (PRE_first_tail_x15_r0_body.clo22.filterMap fun i => (PRE_first_tail_x15_r0_body.kr0_22.targs.get i).map (i, ·))
kernel_rfl PRE_first_tail_x15_r0_body.fkf122 : PRE_first_tail_x15_r0_body.kr1_22.flags = Stage.setAll PRE_first_tail_x15_r0_body.krC_22.flags (PRE_first_tail_x15_r0_body.cwS22.filterMap fun i => (PRE_first_tail_x15_r0_body.kr1_22.flags.get i).map (i, ·))
kernel_rfl PRE_first_tail_x15_r0_body.fkt122 : PRE_first_tail_x15_r0_body.kr1_22.targs = Stage.setAll PRE_first_tail_x15_r0_body.krC_22.targs (PRE_first_tail_x15_r0_body.cwS22.filterMap fun i => (PRE_first_tail_x15_r0_body.kr1_22.targs.get i).map (i, ·))
kernel_rfl PRE_first_tail_x15_r0_body.fkck22 : krecLB PRE_first_tail_x15_r0_body.kappa22 1019 PRE_first_tail_x15_r0_body.cx0_22.mlx PRE_first_tail_x15_r0_body.kr0_22 PRE_first_tail_x15_r0_body.kr1_22 PRE_first_tail_x15_r0_body.clo22 = true
kernel_rfl PRE_first_tail_x15_r0_body.fkn22 : Nat.ble 1019 1019 = true
-- the bridge and the pending traces' regions
kernel_rfl PRE_first_tail_x15_r0_body.cbridge22 : Host.Ts.Sim.Full.bridgeOf PRE_first_tail_x15_r0_body.s205.ffi = Host.Ts.Sim.Full.bridgeOf PRE_first_tail_x15_r0_body.s206.ffi
kernel_rfl PRE_first_tail_x15_r0_body.cpendR22 : pendRegB PRE_first_tail_x15_r0_body.kappa22 (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s206.ffi).mlx = true
kernel_rfl PRE_first_tail_x15_r0_body.cpendLe22 : Nat.ble (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s206.ffi).mlx.next (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s205.ffi).mlx.next = true
/-- **The compaction's native shift**, given the call's bookkeeping, its relation's facts (the model's and the
observers') and the canonical closedness. -/
theorem PRE_first_tail_x15_r0_body.cshift22 (clean : Conv.NClean (⟨18646, 15729, 2692505, 1019⟩ : Conv.Cnt) (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s204.ffi).mlx) (hltC : ∀ h, PH (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s204.ffi).mlx h → h < (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s204.ffi).mlx.next) (nltC : ∀ i, PN (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s204.ffi).mlx i → i < (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s204.ffi).mlx.nnext) (itemsC : ∀ k v, (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s204.ffi).mlx.items.get k = some v → PN (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s204.ffi).mlx k) (tracedC : ∀ h o, (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s204.ffi).mlx.objs.get h = some o → ∀ i ∈ objTraces o, i < PRE_first_tail_x15_r0_body.P22.NL) (cl : SSt (· < 1019) PRE_first_tail_x15_r0_body.cx0_22.mlx)
    (hobjC : ∀ h, PRE_first_tail_x15_r0_body.fxC_22.get h = some () → ((Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s204.ffi).mlx.objs.get h).isSome = true)
    (hfC : ∀ h, (PRE_first_tail_x15_r0_body.krC_22.flags.get h).isSome = true → ((Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s204.ffi).mlx.objs.get h).isSome = true)
    (htC : ∀ h, (PRE_first_tail_x15_r0_body.krC_22.targs.get h).isSome = true → ((Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s204.ffi).mlx.objs.get h).isSome = true)
    (hclC : ∀ h l, PRE_first_tail_x15_r0_body.krC_22.targs.get h = some l → Host.Ts.Sim.Full.STargs (· < (⟨18646, 15729, 2692505, 1019⟩ : Conv.Cnt).n) l) :
    Conv.FullShiftQ PRE_first_tail_x15_r0_body.P22 1019 PRE_first_tail_x15_r0_body.kappa22 PRE_first_tail_x15_r0_body.s206.ffi PRE_first_tail_x15_r0_body.s205.ffi :=
  ⟨PRE_first_tail_x15_r0_body.cnshift22 clean hltC nltC itemsC tracedC cl, PRE_first_tail_x15_r0_body.cqueue22, fun t ht => bSN_sound (List.all_eq_true.mp PRE_first_tail_x15_r0_body.ctokSupp22 t ht),
    PRE_first_tail_x15_r0_body.cbridge22,
    liveShift_foot (x0' := Host.Ts.Sim.Full.mlxOf PRE_first_tail_x15_r0_body.s206.ffi) (x1' := Host.Ts.Sim.Full.mlxOf PRE_first_tail_x15_r0_body.s205.ffi) (PRE_first_tail_x15_r0_body.cfoot22 clean hltC nltC itemsC tracedC cl) rfl PRE_first_tail_x15_r0_body.ofx0_22 PRE_first_tail_x15_r0_body.ofx1_22 hobjC PRE_first_tail_x15_r0_body.ff022 PRE_first_tail_x15_r0_body.ff122 PRE_first_tail_x15_r0_body.ffck22,
    kernShift_foot (x0' := Host.Ts.Sim.Full.mlxOf PRE_first_tail_x15_r0_body.s206.ffi) (x1' := Host.Ts.Sim.Full.mlxOf PRE_first_tail_x15_r0_body.s205.ffi) (PRE_first_tail_x15_r0_body.cfoot22 clean hltC nltC itemsC tracedC cl) rfl PRE_first_tail_x15_r0_body.okr0_22 PRE_first_tail_x15_r0_body.okr1_22 (Nat.le_of_ble_eq_true PRE_first_tail_x15_r0_body.fkn22) hfC htC hclC
      PRE_first_tail_x15_r0_body.fkf022 PRE_first_tail_x15_r0_body.fkt022 PRE_first_tail_x15_r0_body.fkf122 PRE_first_tail_x15_r0_body.fkt122 PRE_first_tail_x15_r0_body.fkck22,
    pendReg_of rfl PRE_first_tail_x15_r0_body.cnh022 PRE_first_tail_x15_r0_body.cnh122 (Nat.le_of_ble_eq_true PRE_first_tail_x15_r0_body.cpendLe22) PRE_first_tail_x15_r0_body.cpendR22⟩

end Host.Load.Run.Tpl
