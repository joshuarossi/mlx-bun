import host.sim.template.a4pre_first_tail_x15_r0_body.SiteCl125
import host.sim.conv.CompactFull
import host.sim.template.FootGen
set_option Elab.async false
namespace Host.Load.Run.Tpl
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
open Host.Ts Host.Ts.Sim Host.Ts.Sim.Template

/-! The compaction's native shift at call site 125 from its footprint (`Conv.nshift_of_foot`), and the observers'
(`liveShift_foot`, `kernShift_foot`): `Conv.FullShiftQ` for `Conv.full_compactQ`, given the call's bookkeeping and its
relation's facts. -/

/-- The load parameters of the chain (band-free: its start's node counter as `NL` and `N0`). -/
def PRE_first_tail_x15_r0_body.Pc125 : LoadP := ⟨18151, 131072, 1099511627776, 15235, 15235, []⟩
/-- The site's band raised to the map's checked fixed-node prefix, including newly recorded closure traces. -/
def PRE_first_tail_x15_r0_body.P125 : LoadP := PRE_first_tail_x15_r0_body.Pc125.raise 17755
kernel_rfl PRE_first_tail_x15_r0_body.craise125 : Nat.ble PRE_first_tail_x15_r0_body.Pc125.N0 17755 = true
theorem PRE_first_tail_x15_r0_body.raised125 : Host.Ts.Sim.Full.Raised PRE_first_tail_x15_r0_body.Pc125 PRE_first_tail_x15_r0_body.P125 :=
  .inr ⟨17755, rfl, Nat.le_of_ble_eq_true PRE_first_tail_x15_r0_body.craise125, rfl⟩
noncomputable abbrev PRE_first_tail_x15_r0_body.cx0_125 : Host.Load.LSt := clearTokens (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1209.ffi)
noncomputable abbrev PRE_first_tail_x15_r0_body.cx1_125 : Host.Load.LSt := clearTokens (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1208.ffi)
def PRE_first_tail_x15_r0_body.khinv125 : PTrie Nat := Stage.setAll PTrie.nil []
def PRE_first_tail_x15_r0_body.kninv125 : PTrie Nat := Stage.setAll PTrie.nil []
/-- The stage's footprint: its written and fresh handles, fresh nodes, written and fresh items. -/
def PRE_first_tail_x15_r0_body.cwS125 : List Nat := []
def PRE_first_tail_x15_r0_body.cnS125 : List Nat := List.range' 17755 0
def PRE_first_tail_x15_r0_body.ciS125 : List Nat := [] ++ List.range' 17755 0

-- the small checks (`MChecks`'s)
kernel_rfl PRE_first_tail_x15_r0_body.cnh0125 : PRE_first_tail_x15_r0_body.kd125.nh0 = PRE_first_tail_x15_r0_body.cx0_125.mlx.next
kernel_rfl PRE_first_tail_x15_r0_body.cnh1125 : PRE_first_tail_x15_r0_body.kd125.nh1 = PRE_first_tail_x15_r0_body.cx1_125.mlx.next
kernel_rfl PRE_first_tail_x15_r0_body.cnn0125 : PRE_first_tail_x15_r0_body.kd125.nn0 = PRE_first_tail_x15_r0_body.cx0_125.mlx.nnext
kernel_rfl PRE_first_tail_x15_r0_body.cnn1125 : PRE_first_tail_x15_r0_body.kd125.nn1 = PRE_first_tail_x15_r0_body.cx1_125.mlx.nnext
kernel_rfl PRE_first_tail_x15_r0_body.cplo125 : (Nat.blt 0 PRE_first_tail_x15_r0_body.P125.lo && Nat.ble PRE_first_tail_x15_r0_body.P125.lo PRE_first_tail_x15_r0_body.cx0_125.mlx.next && Nat.ble PRE_first_tail_x15_r0_body.P125.lo RData.bigHi && Nat.ble RData.bigHi PRE_first_tail_x15_r0_body.P125.E) = true
kernel_rfl PRE_first_tail_x15_r0_body.ccnt125 : (Nat.ble PRE_first_tail_x15_r0_body.cx0_125.mlx.next PRE_first_tail_x15_r0_body.cx1_125.mlx.next && Nat.ble PRE_first_tail_x15_r0_body.cx0_125.mlx.nnext PRE_first_tail_x15_r0_body.cx1_125.mlx.nnext) = true
kernel_rfl PRE_first_tail_x15_r0_body.cnband125 : (Nat.blt 0 PRE_first_tail_x15_r0_body.P125.NL && Nat.ble PRE_first_tail_x15_r0_body.P125.NL PRE_first_tail_x15_r0_body.P125.N0 && Nat.ble PRE_first_tail_x15_r0_body.P125.N0 PRE_first_tail_x15_r0_body.cx0_125.mlx.nnext) = true
kernel_rfl PRE_first_tail_x15_r0_body.chbelow125 : PRE_first_tail_x15_r0_body.kd125.checkHndBelow = true
kernel_rfl PRE_first_tail_x15_r0_body.chren125 : checkRenG PRE_first_tail_x15_r0_body.kd125.hnd PRE_first_tail_x15_r0_body.khinv125 (phB PRE_first_tail_x15_r0_body.cx0_125.mlx) = true
kernel_rfl PRE_first_tail_x15_r0_body.cband125 : PRE_first_tail_x15_r0_body.kd125.checkBand PRE_first_tail_x15_r0_body.P125.lo = true
kernel_rfl PRE_first_tail_x15_r0_body.cnh1pos125 : Nat.blt 0 PRE_first_tail_x15_r0_body.kd125.nh1 = true
kernel_rfl PRE_first_tail_x15_r0_body.cnren125 : checkRenG PRE_first_tail_x15_r0_body.kd125.node PRE_first_tail_x15_r0_body.kninv125 (pnB PRE_first_tail_x15_r0_body.cx0_125.mlx) = true
kernel_rfl PRE_first_tail_x15_r0_body.cnlow125 : (PTrie.keysA PRE_first_tail_x15_r0_body.kd125.node).all (fun j => Nat.ble PRE_first_tail_x15_r0_body.P125.NL j && Nat.blt (PRE_first_tail_x15_r0_body.kd125.nodeF j) PRE_first_tail_x15_r0_body.cx1_125.mlx.nnext) = true
kernel_rfl PRE_first_tail_x15_r0_body.cabs0a125 : PRE_first_tail_x15_r0_body.cx0_125.mlx.arrs.get 0 = none
kernel_rfl PRE_first_tail_x15_r0_body.cabs0b125 : PRE_first_tail_x15_r0_body.cx0_125.mlx.objs.get 0 = none
kernel_rfl PRE_first_tail_x15_r0_body.ctok1125 : PRE_first_tail_x15_r0_body.cx1_125.mlx.tokens = []
kernel_rfl PRE_first_tail_x15_r0_body.cpend125 : PRE_first_tail_x15_r0_body.cx1_125.mlx.pending = PRE_first_tail_x15_r0_body.cx0_125.mlx.pending.map PRE_first_tail_x15_r0_body.kappa125.pend
kernel_rfl PRE_first_tail_x15_r0_body.cerrh125 : PRE_first_tail_x15_r0_body.cx1_125.mlx.errh = PRE_first_tail_x15_r0_body.cx0_125.mlx.errh.map PRE_first_tail_x15_r0_body.kappa125.arg
kernel_rfl PRE_first_tail_x15_r0_body.cfiles125 : PRE_first_tail_x15_r0_body.cx1_125.mlx.files = PRE_first_tail_x15_r0_body.cx0_125.mlx.files
kernel_rfl PRE_first_tail_x15_r0_body.carch125 : PRE_first_tail_x15_r0_body.cx1_125.mlx.arch = PRE_first_tail_x15_r0_body.cx0_125.mlx.arch
kernel_rfl PRE_first_tail_x15_r0_body.csizes125 : PRE_first_tail_x15_r0_body.cx1_125.mlx.deviceSizes = PRE_first_tail_x15_r0_body.cx0_125.mlx.deviceSizes
kernel_rfl PRE_first_tail_x15_r0_body.cwired125 : PRE_first_tail_x15_r0_body.cx1_125.mlx.wired = PRE_first_tail_x15_r0_body.cx0_125.mlx.wired
kernel_rfl PRE_first_tail_x15_r0_body.chost125 : PRE_first_tail_x15_r0_body.cx1_125.host = PRE_first_tail_x15_r0_body.cx0_125.host
-- the compaction map's addresses are `PRE_first_tail_x15_r0_body.kd125`'s
kernel_rfl PRE_first_tail_x15_r0_body.ckn0125 : PRE_first_tail_x15_r0_body.kd125.n0 = 2772664
kernel_rfl PRE_first_tail_x15_r0_body.ckn1125 : PRE_first_tail_x15_r0_body.kd125.n1 = 2772674
kernel_rfl PRE_first_tail_x15_r0_body.ckheap125 : (PTrie.keysA PRE_first_tail_x15_r0_body.kd125.heap).all (fun x => Nat.ble 2772663 x) = true
kernel_rfl PRE_first_tail_x15_r0_body.ckpl125 : (List.range 1).all (fun j => decide (PRE_first_tail_x15_r0_body.kd125.heap.get (2772663 + j) = nth? PRE_first_tail_x15_r0_body.pl125 j)) = true
-- the map fixes the call's names (`Conv.fixOld_compact`), the call's counters
kernel_rfl PRE_first_tail_x15_r0_body.fja125 : Nat.ble 2772663 2772663 = true
kernel_rfl PRE_first_tail_x15_r0_body.fn125 : Nat.ble 5398 5398 = true
kernel_rfl PRE_first_tail_x15_r0_body.fjaD125 : Nat.ble 2772663 PRE_first_tail_x15_r0_body.kd125.n0 = true
kernel_rfl PRE_first_tail_x15_r0_body.fxn125 : Nat.ble 20656 PRE_first_tail_x15_r0_body.kd125.nh0 = true
kernel_rfl PRE_first_tail_x15_r0_body.fnn125 : Nat.ble 17755 PRE_first_tail_x15_r0_body.kd125.nn0 = true
kernel_rfl PRE_first_tail_x15_r0_body.fxb125 : Nat.ble 20656 RData.bigHi = true
kernel_rfl PRE_first_tail_x15_r0_body.fheap125 : (PTrie.keysA PRE_first_tail_x15_r0_body.kd125.heap).all (Nat.ble (⟨20656, 17755, 2772663, 5398⟩ : Conv.Cnt).ja) = true
kernel_rfl PRE_first_tail_x15_r0_body.fhnd125 : (PTrie.keysA PRE_first_tail_x15_r0_body.kd125.hnd).all (Nat.ble (⟨20656, 17755, 2772663, 5398⟩ : Conv.Cnt).xn) = true
kernel_rfl PRE_first_tail_x15_r0_body.fnode125 : (PTrie.keysA PRE_first_tail_x15_r0_body.kd125.node).all (Nat.ble (⟨20656, 17755, 2772663, 5398⟩ : Conv.Cnt).nn) = true
/-- The compaction map fixes the call's names. -/
theorem PRE_first_tail_x15_r0_body.cfix125 : Conv.FixOld (⟨20656, 17755, 2772663, 5398⟩ : Conv.Cnt) PRE_first_tail_x15_r0_body.kappa125 :=
  Conv.fixOld_compact (Nat.le_of_ble_eq_true PRE_first_tail_x15_r0_body.fja125) (Nat.le_of_ble_eq_true PRE_first_tail_x15_r0_body.fn125) (Nat.le_of_ble_eq_true PRE_first_tail_x15_r0_body.fjaD125) (Nat.le_of_ble_eq_true PRE_first_tail_x15_r0_body.fxn125) (Nat.le_of_ble_eq_true PRE_first_tail_x15_r0_body.fnn125) (Nat.le_of_ble_eq_true PRE_first_tail_x15_r0_body.fxb125) PRE_first_tail_x15_r0_body.fheap125 PRE_first_tail_x15_r0_body.fhnd125 PRE_first_tail_x15_r0_body.fnode125
kernel_rfl PRE_first_tail_x15_r0_body.fcxn125 : (⟨20656, 17755, 2772663, 5398⟩ : Conv.Cnt).xn = (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1207.ffi).mlx.next
kernel_rfl PRE_first_tail_x15_r0_body.fcnn125 : (⟨20656, 17755, 2772663, 5398⟩ : Conv.Cnt).nn = (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1207.ffi).mlx.nnext
kernel_rfl PRE_first_tail_x15_r0_body.fle0125 : (Nat.ble (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1207.ffi).mlx.next PRE_first_tail_x15_r0_body.cx0_125.mlx.next && Nat.ble (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1207.ffi).mlx.nnext PRE_first_tail_x15_r0_body.cx0_125.mlx.nnext && Nat.ble (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1207.ffi).mlx.next RData.bigHi) = true
kernel_rfl PRE_first_tail_x15_r0_body.fnk125 : (PTrie.keysA PRE_first_tail_x15_r0_body.kd125.node).all (Nat.ble (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1207.ffi).mlx.nnext) = true
-- the merged state keeps the call's entries off the stage's footprint
kernel_rfl PRE_first_tail_x15_r0_body.f1A125 : PRE_first_tail_x15_r0_body.cx1_125.mlx.arrs = Stage.setAll (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1207.ffi).mlx.arrs (PRE_first_tail_x15_r0_body.cwS125.filterMap fun i => (PRE_first_tail_x15_r0_body.cx1_125.mlx.arrs.get i).map (i, ·))
kernel_rfl PRE_first_tail_x15_r0_body.f1O125 : PRE_first_tail_x15_r0_body.cx1_125.mlx.objs = Stage.setAll (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1207.ffi).mlx.objs (PRE_first_tail_x15_r0_body.cwS125.filterMap fun i => (PRE_first_tail_x15_r0_body.cx1_125.mlx.objs.get i).map (i, ·))
kernel_rfl PRE_first_tail_x15_r0_body.f1N125 : PRE_first_tail_x15_r0_body.cx1_125.mlx.nodes = Stage.setAll (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1207.ffi).mlx.nodes (PRE_first_tail_x15_r0_body.cnS125.filterMap fun i => (PRE_first_tail_x15_r0_body.cx1_125.mlx.nodes.get i).map (i, ·))
kernel_rfl PRE_first_tail_x15_r0_body.f1I125 : PRE_first_tail_x15_r0_body.cx1_125.mlx.items = Stage.setAll (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1207.ffi).mlx.items (PRE_first_tail_x15_r0_body.ciS125.filterMap fun i => (PRE_first_tail_x15_r0_body.cx1_125.mlx.items.get i).map (i, ·))
kernel_rfl PRE_first_tail_x15_r0_body.fbd125 : (PRE_first_tail_x15_r0_body.clo125 ++ PRE_first_tail_x15_r0_body.cln125 ++ PRE_first_tail_x15_r0_body.cli125 ++ PRE_first_tail_x15_r0_body.cwS125 ++ PRE_first_tail_x15_r0_body.cnS125 ++ PRE_first_tail_x15_r0_body.ciS125).all (fun i => Nat.blt (i / 4096) (4 ^ 31)) = true
kernel_rfl PRE_first_tail_x15_r0_body.fincW125 : PRE_first_tail_x15_r0_body.cwS125.all (fun h => !Nat.blt h (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1207.ffi).mlx.next || PRE_first_tail_x15_r0_body.clo125.contains h) = true
kernel_rfl PRE_first_tail_x15_r0_body.fincI125 : PRE_first_tail_x15_r0_body.ciS125.all (fun k => !Nat.blt k (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1207.ffi).mlx.nnext || PRE_first_tail_x15_r0_body.cli125.contains k) = true
kernel_rfl PRE_first_tail_x15_r0_body.fincN125 : PRE_first_tail_x15_r0_body.cnS125.all (Nat.ble (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1207.ffi).mlx.nnext) = true
kernel_rfl PRE_first_tail_x15_r0_body.flnF125 : PRE_first_tail_x15_r0_body.cln125.all (Nat.ble (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1207.ffi).mlx.nnext) = true
-- the checks over the changed lists
kernel_rfl PRE_first_tail_x15_r0_body.fh125 : PRE_first_tail_x15_r0_body.clo125.all (handleOK PRE_first_tail_x15_r0_body.kappa125 PRE_first_tail_x15_r0_body.P125.lo PRE_first_tail_x15_r0_body.cx0_125.mlx PRE_first_tail_x15_r0_body.cx1_125.mlx) = true
kernel_rfl PRE_first_tail_x15_r0_body.fo125 : PRE_first_tail_x15_r0_body.clo125.map (fun h => PRE_first_tail_x15_r0_body.cx1_125.mlx.objs.get (PRE_first_tail_x15_r0_body.kappa125.handle h)) = PRE_first_tail_x15_r0_body.clo125.map (fun h => (PRE_first_tail_x15_r0_body.cx0_125.mlx.objs.get h).map PRE_first_tail_x15_r0_body.kappa125.nobj)
kernel_rfl PRE_first_tail_x15_r0_body.fok125 : PRE_first_tail_x15_r0_body.clo125.all (objOK PRE_first_tail_x15_r0_body.kappa125 PRE_first_tail_x15_r0_body.P125.NL PRE_first_tail_x15_r0_body.cx0_125.mlx) = true
kernel_rfl PRE_first_tail_x15_r0_body.fnd125 : PRE_first_tail_x15_r0_body.cln125.all (nodeOKF PRE_first_tail_x15_r0_body.kappa125 PRE_first_tail_x15_r0_body.P125 PRE_first_tail_x15_r0_body.cx0_125.mlx PRE_first_tail_x15_r0_body.cx1_125.mlx) = true
kernel_rfl PRE_first_tail_x15_r0_body.fp125 : ((PRE_first_tail_x15_r0_body.cln125.filter (fullB PRE_first_tail_x15_r0_body.P125))).map (fun i => (PRE_first_tail_x15_r0_body.cx1_125.mlx.nodes.get (PRE_first_tail_x15_r0_body.kappa125.node i)).map Host.Mlx.Ffi.Node.prim) =
  ((PRE_first_tail_x15_r0_body.cln125.filter (fullB PRE_first_tail_x15_r0_body.P125))).map (fun i => (PRE_first_tail_x15_r0_body.cx0_125.mlx.nodes.get i).map fun nd => PRE_first_tail_x15_r0_body.kappa125.prim nd.prim)
kernel_rfl PRE_first_tail_x15_r0_body.fnordI125 : incrB PRE_first_tail_x15_r0_body.kd125.nodeF (List.range' 17755 0) = true
kernel_rfl PRE_first_tail_x15_r0_body.fnordK125 : (PTrie.keysA PRE_first_tail_x15_r0_body.kd125.node).all (fun k => Nat.ble 17755 k && Nat.blt k 17755) = true
kernel_rfl PRE_first_tail_x15_r0_body.fnordL125 : (PRE_first_tail_x15_r0_body.cln125.filter (Nat.ble PRE_first_tail_x15_r0_body.P125.N0)).all (fun i => Nat.ble i (PRE_first_tail_x15_r0_body.kd125.nodeF i) && (Nat.blt i 17755 || Nat.ble PRE_first_tail_x15_r0_body.kd125.nn0 i)) = true
theorem PRE_first_tail_x15_r0_body.fnord125 : (PRE_first_tail_x15_r0_body.cln125.filter (Nat.ble PRE_first_tail_x15_r0_body.P125.N0)).all (fun i => Nat.ble i (PRE_first_tail_x15_r0_body.kd125.nodeF i) &&
    (PTrie.keysA PRE_first_tail_x15_r0_body.kd125.node).all fun j => !Nat.blt j i || Nat.blt (PRE_first_tail_x15_r0_body.kd125.nodeF j) (PRE_first_tail_x15_r0_body.kd125.nodeF i)) = true :=
  cnord_of PRE_first_tail_x15_r0_body.cnlow125 PRE_first_tail_x15_r0_body.cnn1125 PRE_first_tail_x15_r0_body.fnordI125 PRE_first_tail_x15_r0_body.fnordK125 PRE_first_tail_x15_r0_body.fnordL125
kernel_rfl PRE_first_tail_x15_r0_body.fi125 : PRE_first_tail_x15_r0_body.cli125.all (pnB PRE_first_tail_x15_r0_body.cx0_125.mlx) = true
kernel_rfl PRE_first_tail_x15_r0_body.fii125 : PRE_first_tail_x15_r0_body.cli125.all (fun k => decide (PRE_first_tail_x15_r0_body.cx1_125.mlx.items.get (PRE_first_tail_x15_r0_body.kappa125.node k) = (PRE_first_tail_x15_r0_body.cx0_125.mlx.items.get k).map PRE_first_tail_x15_r0_body.kappa125.nv)) = true
/-- **The compaction's footprint.** -/
theorem PRE_first_tail_x15_r0_body.cfoot125 (clean : Conv.NClean (⟨20656, 17755, 2772663, 5398⟩ : Conv.Cnt) (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1207.ffi).mlx) (hltC : ∀ h, PH (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1207.ffi).mlx h → h < (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1207.ffi).mlx.next) (nltC : ∀ i, PN (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1207.ffi).mlx i → i < (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1207.ffi).mlx.nnext) (itemsC : ∀ k v, (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1207.ffi).mlx.items.get k = some v → PN (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1207.ffi).mlx k) (tracedC : ∀ h o, (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1207.ffi).mlx.objs.get h = some o → ∀ i ∈ objTraces o, i < PRE_first_tail_x15_r0_body.P125.NL) (cl : SSt (· < 5398) PRE_first_tail_x15_r0_body.cx0_125.mlx) :
    Conv.MFoot PRE_first_tail_x15_r0_body.P125 5398 PRE_first_tail_x15_r0_body.kappa125 PRE_first_tail_x15_r0_body.kd125 PRE_first_tail_x15_r0_body.khinv125 PRE_first_tail_x15_r0_body.kninv125 (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1207.ffi).mlx PRE_first_tail_x15_r0_body.cx0_125.mlx PRE_first_tail_x15_r0_body.cx1_125.mlx (⟨20656, 17755, 2772663, 5398⟩ : Conv.Cnt) PRE_first_tail_x15_r0_body.clo125 PRE_first_tail_x15_r0_body.cln125 PRE_first_tail_x15_r0_body.cli125 PRE_first_tail_x15_r0_body.cwS125 PRE_first_tail_x15_r0_body.cnS125 PRE_first_tail_x15_r0_body.ciS125 :=
  ⟨rfl, rfl, rfl, PRE_first_tail_x15_r0_body.cnh0125, PRE_first_tail_x15_r0_body.cnh1125, PRE_first_tail_x15_r0_body.cnn0125, PRE_first_tail_x15_r0_body.cnn1125, PRE_first_tail_x15_r0_body.cplo125, PRE_first_tail_x15_r0_body.ccnt125, PRE_first_tail_x15_r0_body.cnband125, PRE_first_tail_x15_r0_body.chbelow125, PRE_first_tail_x15_r0_body.chren125, PRE_first_tail_x15_r0_body.cband125, PRE_first_tail_x15_r0_body.cnh1pos125, PRE_first_tail_x15_r0_body.cnren125, PRE_first_tail_x15_r0_body.cnlow125, PRE_first_tail_x15_r0_body.cabs0a125, PRE_first_tail_x15_r0_body.cabs0b125, PRE_first_tail_x15_r0_body.ctok1125, PRE_first_tail_x15_r0_body.cpend125, PRE_first_tail_x15_r0_body.cerrh125, PRE_first_tail_x15_r0_body.cfiles125, PRE_first_tail_x15_r0_body.carch125, PRE_first_tail_x15_r0_body.csizes125, PRE_first_tail_x15_r0_body.cwired125, PRE_first_tail_x15_r0_body.cfix125, clean, PRE_first_tail_x15_r0_body.fcxn125, PRE_first_tail_x15_r0_body.fcnn125, hltC, nltC, itemsC, tracedC, cl, PRE_first_tail_x15_r0_body.fle0125, PRE_first_tail_x15_r0_body.fnk125, PRE_first_tail_x15_r0_body.ckA125, PRE_first_tail_x15_r0_body.cobjsK125, PRE_first_tail_x15_r0_body.cnodesK125, PRE_first_tail_x15_r0_body.citemsK125, PRE_first_tail_x15_r0_body.f1A125, PRE_first_tail_x15_r0_body.f1O125, PRE_first_tail_x15_r0_body.f1N125, PRE_first_tail_x15_r0_body.f1I125, PRE_first_tail_x15_r0_body.fbd125, PRE_first_tail_x15_r0_body.fincW125, PRE_first_tail_x15_r0_body.fincI125, PRE_first_tail_x15_r0_body.fincN125, PRE_first_tail_x15_r0_body.flnF125, PRE_first_tail_x15_r0_body.fh125, PRE_first_tail_x15_r0_body.fo125, PRE_first_tail_x15_r0_body.fok125, PRE_first_tail_x15_r0_body.fnd125, PRE_first_tail_x15_r0_body.fp125, PRE_first_tail_x15_r0_body.fnord125, PRE_first_tail_x15_r0_body.fi125, PRE_first_tail_x15_r0_body.fii125⟩
theorem PRE_first_tail_x15_r0_body.cnshift125 (clean : Conv.NClean (⟨20656, 17755, 2772663, 5398⟩ : Conv.Cnt) (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1207.ffi).mlx) (hltC : ∀ h, PH (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1207.ffi).mlx h → h < (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1207.ffi).mlx.next) (nltC : ∀ i, PN (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1207.ffi).mlx i → i < (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1207.ffi).mlx.nnext) (itemsC : ∀ k v, (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1207.ffi).mlx.items.get k = some v → PN (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1207.ffi).mlx k) (tracedC : ∀ h o, (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1207.ffi).mlx.objs.get h = some o → ∀ i ∈ objTraces o, i < PRE_first_tail_x15_r0_body.P125.NL) (cl : SSt (· < 5398) PRE_first_tail_x15_r0_body.cx0_125.mlx) : NShift PRE_first_tail_x15_r0_body.P125 5398 PRE_first_tail_x15_r0_body.kappa125 PRE_first_tail_x15_r0_body.cx0_125 PRE_first_tail_x15_r0_body.cx1_125 :=
  Conv.nshift_of_foot (PRE_first_tail_x15_r0_body.cfoot125 clean hltC nltC itemsC tracedC cl) PRE_first_tail_x15_r0_body.chost125 (compact_a_eq PRE_first_tail_x15_r0_body.ckn0125 PRE_first_tail_x15_r0_body.ckn1125 PRE_first_tail_x15_r0_body.ckheap125 PRE_first_tail_x15_r0_body.ckpl125)

-- the observers: the layers' states at the call, the canonical and the merged state, their footprints and checks
noncomputable def PRE_first_tail_x15_r0_body.fxC_125 : PTrie Unit := (Host.Ts.Sim.Full.freedOf PRE_first_tail_x15_r0_body.s1207.ffi).getD PTrie.nil
noncomputable def PRE_first_tail_x15_r0_body.krC_125 : Host.Load.Layers.KRec := (Host.Ts.Sim.Full.krecOf PRE_first_tail_x15_r0_body.s1207.ffi).getD Host.Load.Layers.KRec.empty
kernel_rfl PRE_first_tail_x15_r0_body.ofxC_125 : (Host.Ts.Sim.Full.freedOf PRE_first_tail_x15_r0_body.s1207.ffi) = some PRE_first_tail_x15_r0_body.fxC_125
kernel_rfl PRE_first_tail_x15_r0_body.okrC_125 : (Host.Ts.Sim.Full.krecOf PRE_first_tail_x15_r0_body.s1207.ffi) = some PRE_first_tail_x15_r0_body.krC_125
noncomputable def PRE_first_tail_x15_r0_body.fx0_125 : PTrie Unit := (Host.Ts.Sim.Full.freedOf PRE_first_tail_x15_r0_body.s1209.ffi).getD PTrie.nil
noncomputable def PRE_first_tail_x15_r0_body.kr0_125 : Host.Load.Layers.KRec := (Host.Ts.Sim.Full.krecOf PRE_first_tail_x15_r0_body.s1209.ffi).getD Host.Load.Layers.KRec.empty
kernel_rfl PRE_first_tail_x15_r0_body.ofx0_125 : (Host.Ts.Sim.Full.freedOf PRE_first_tail_x15_r0_body.s1209.ffi) = some PRE_first_tail_x15_r0_body.fx0_125
kernel_rfl PRE_first_tail_x15_r0_body.okr0_125 : (Host.Ts.Sim.Full.krecOf PRE_first_tail_x15_r0_body.s1209.ffi) = some PRE_first_tail_x15_r0_body.kr0_125
noncomputable def PRE_first_tail_x15_r0_body.fx1_125 : PTrie Unit := (Host.Ts.Sim.Full.freedOf PRE_first_tail_x15_r0_body.s1208.ffi).getD PTrie.nil
noncomputable def PRE_first_tail_x15_r0_body.kr1_125 : Host.Load.Layers.KRec := (Host.Ts.Sim.Full.krecOf PRE_first_tail_x15_r0_body.s1208.ffi).getD Host.Load.Layers.KRec.empty
kernel_rfl PRE_first_tail_x15_r0_body.ofx1_125 : (Host.Ts.Sim.Full.freedOf PRE_first_tail_x15_r0_body.s1208.ffi) = some PRE_first_tail_x15_r0_body.fx1_125
kernel_rfl PRE_first_tail_x15_r0_body.okr1_125 : (Host.Ts.Sim.Full.krecOf PRE_first_tail_x15_r0_body.s1208.ffi) = some PRE_first_tail_x15_r0_body.kr1_125
kernel_rfl PRE_first_tail_x15_r0_body.ff0125 : PRE_first_tail_x15_r0_body.fx0_125 = Stage.setAll PRE_first_tail_x15_r0_body.fxC_125 (PRE_first_tail_x15_r0_body.clo125.filterMap fun i => (PRE_first_tail_x15_r0_body.fx0_125.get i).map (i, ·))
kernel_rfl PRE_first_tail_x15_r0_body.ff1125 : PRE_first_tail_x15_r0_body.fx1_125 = Stage.setAll PRE_first_tail_x15_r0_body.fxC_125 (PRE_first_tail_x15_r0_body.cwS125.filterMap fun i => (PRE_first_tail_x15_r0_body.fx1_125.get i).map (i, ·))
kernel_rfl PRE_first_tail_x15_r0_body.ffck125 : freedLB PRE_first_tail_x15_r0_body.kappa125 PRE_first_tail_x15_r0_body.cx0_125.mlx PRE_first_tail_x15_r0_body.fx0_125 PRE_first_tail_x15_r0_body.fx1_125 PRE_first_tail_x15_r0_body.clo125 = true
kernel_rfl PRE_first_tail_x15_r0_body.fkf0125 : PRE_first_tail_x15_r0_body.kr0_125.flags = Stage.setAll PRE_first_tail_x15_r0_body.krC_125.flags (PRE_first_tail_x15_r0_body.clo125.filterMap fun i => (PRE_first_tail_x15_r0_body.kr0_125.flags.get i).map (i, ·))
kernel_rfl PRE_first_tail_x15_r0_body.fkt0125 : PRE_first_tail_x15_r0_body.kr0_125.targs = Stage.setAll PRE_first_tail_x15_r0_body.krC_125.targs (PRE_first_tail_x15_r0_body.clo125.filterMap fun i => (PRE_first_tail_x15_r0_body.kr0_125.targs.get i).map (i, ·))
kernel_rfl PRE_first_tail_x15_r0_body.fkf1125 : PRE_first_tail_x15_r0_body.kr1_125.flags = Stage.setAll PRE_first_tail_x15_r0_body.krC_125.flags (PRE_first_tail_x15_r0_body.cwS125.filterMap fun i => (PRE_first_tail_x15_r0_body.kr1_125.flags.get i).map (i, ·))
kernel_rfl PRE_first_tail_x15_r0_body.fkt1125 : PRE_first_tail_x15_r0_body.kr1_125.targs = Stage.setAll PRE_first_tail_x15_r0_body.krC_125.targs (PRE_first_tail_x15_r0_body.cwS125.filterMap fun i => (PRE_first_tail_x15_r0_body.kr1_125.targs.get i).map (i, ·))
kernel_rfl PRE_first_tail_x15_r0_body.fkck125 : krecLB PRE_first_tail_x15_r0_body.kappa125 5398 PRE_first_tail_x15_r0_body.cx0_125.mlx PRE_first_tail_x15_r0_body.kr0_125 PRE_first_tail_x15_r0_body.kr1_125 PRE_first_tail_x15_r0_body.clo125 = true
kernel_rfl PRE_first_tail_x15_r0_body.fkn125 : Nat.ble 5398 5398 = true
-- the bridge and the pending traces' regions
kernel_rfl PRE_first_tail_x15_r0_body.cbridge125 : Host.Ts.Sim.Full.bridgeOf PRE_first_tail_x15_r0_body.s1208.ffi = Host.Ts.Sim.Full.bridgeOf PRE_first_tail_x15_r0_body.s1209.ffi
kernel_rfl PRE_first_tail_x15_r0_body.cpendR125 : pendRegB PRE_first_tail_x15_r0_body.kappa125 (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1209.ffi).mlx = true
kernel_rfl PRE_first_tail_x15_r0_body.cpendLe125 : Nat.ble (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1209.ffi).mlx.next (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1208.ffi).mlx.next = true
/-- **The compaction's native shift**, given the call's bookkeeping, its relation's facts (the model's and the
observers') and the canonical closedness. -/
theorem PRE_first_tail_x15_r0_body.cshift125 (clean : Conv.NClean (⟨20656, 17755, 2772663, 5398⟩ : Conv.Cnt) (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1207.ffi).mlx) (hltC : ∀ h, PH (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1207.ffi).mlx h → h < (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1207.ffi).mlx.next) (nltC : ∀ i, PN (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1207.ffi).mlx i → i < (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1207.ffi).mlx.nnext) (itemsC : ∀ k v, (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1207.ffi).mlx.items.get k = some v → PN (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1207.ffi).mlx k) (tracedC : ∀ h o, (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1207.ffi).mlx.objs.get h = some o → ∀ i ∈ objTraces o, i < PRE_first_tail_x15_r0_body.P125.NL) (cl : SSt (· < 5398) PRE_first_tail_x15_r0_body.cx0_125.mlx)
    (hobjC : ∀ h, PRE_first_tail_x15_r0_body.fxC_125.get h = some () → ((Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1207.ffi).mlx.objs.get h).isSome = true)
    (hfC : ∀ h, (PRE_first_tail_x15_r0_body.krC_125.flags.get h).isSome = true → ((Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1207.ffi).mlx.objs.get h).isSome = true)
    (htC : ∀ h, (PRE_first_tail_x15_r0_body.krC_125.targs.get h).isSome = true → ((Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1207.ffi).mlx.objs.get h).isSome = true)
    (hclC : ∀ h l, PRE_first_tail_x15_r0_body.krC_125.targs.get h = some l → Host.Ts.Sim.Full.STargs (· < (⟨20656, 17755, 2772663, 5398⟩ : Conv.Cnt).n) l) :
    Conv.FullShiftQ PRE_first_tail_x15_r0_body.P125 5398 PRE_first_tail_x15_r0_body.kappa125 PRE_first_tail_x15_r0_body.s1209.ffi PRE_first_tail_x15_r0_body.s1208.ffi :=
  ⟨PRE_first_tail_x15_r0_body.cnshift125 clean hltC nltC itemsC tracedC cl, PRE_first_tail_x15_r0_body.cqueue125, fun t ht => bSN_sound (List.all_eq_true.mp PRE_first_tail_x15_r0_body.ctokSupp125 t ht),
    PRE_first_tail_x15_r0_body.cbridge125,
    liveShift_foot (x0' := Host.Ts.Sim.Full.mlxOf PRE_first_tail_x15_r0_body.s1209.ffi) (x1' := Host.Ts.Sim.Full.mlxOf PRE_first_tail_x15_r0_body.s1208.ffi) (PRE_first_tail_x15_r0_body.cfoot125 clean hltC nltC itemsC tracedC cl) rfl PRE_first_tail_x15_r0_body.ofx0_125 PRE_first_tail_x15_r0_body.ofx1_125 hobjC PRE_first_tail_x15_r0_body.ff0125 PRE_first_tail_x15_r0_body.ff1125 PRE_first_tail_x15_r0_body.ffck125,
    kernShift_foot (x0' := Host.Ts.Sim.Full.mlxOf PRE_first_tail_x15_r0_body.s1209.ffi) (x1' := Host.Ts.Sim.Full.mlxOf PRE_first_tail_x15_r0_body.s1208.ffi) (PRE_first_tail_x15_r0_body.cfoot125 clean hltC nltC itemsC tracedC cl) rfl PRE_first_tail_x15_r0_body.okr0_125 PRE_first_tail_x15_r0_body.okr1_125 (Nat.le_of_ble_eq_true PRE_first_tail_x15_r0_body.fkn125) hfC htC hclC
      PRE_first_tail_x15_r0_body.fkf0125 PRE_first_tail_x15_r0_body.fkt0125 PRE_first_tail_x15_r0_body.fkf1125 PRE_first_tail_x15_r0_body.fkt1125 PRE_first_tail_x15_r0_body.fkck125,
    pendReg_of rfl PRE_first_tail_x15_r0_body.cnh0125 PRE_first_tail_x15_r0_body.cnh1125 (Nat.le_of_ble_eq_true PRE_first_tail_x15_r0_body.cpendLe125) PRE_first_tail_x15_r0_body.cpendR125⟩

end Host.Load.Run.Tpl
