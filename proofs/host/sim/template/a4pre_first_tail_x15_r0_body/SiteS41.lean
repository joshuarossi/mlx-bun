import host.sim.template.a4pre_first_tail_x15_r0_body.SiteCl41
import host.sim.conv.CompactFull
import host.sim.template.FootGen
set_option Elab.async false
namespace Host.Load.Run.Tpl
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
open Host.Ts Host.Ts.Sim Host.Ts.Sim.Template

/-! The compaction's native shift at call site 41 from its footprint (`Conv.nshift_of_foot`), and the observers'
(`liveShift_foot`, `kernShift_foot`): `Conv.FullShiftQ` for `Conv.full_compactQ`, given the call's bookkeeping and its
relation's facts. -/

/-- The load parameters of the chain (band-free: its start's node counter as `NL` and `N0`). -/
def PRE_first_tail_x15_r0_body.Pc41 : LoadP := ⟨18151, 131072, 1099511627776, 15235, 15235, []⟩
/-- The site's band raised to the map's checked fixed-node prefix, including newly recorded closure traces. -/
def PRE_first_tail_x15_r0_body.P41 : LoadP := PRE_first_tail_x15_r0_body.Pc41.raise 16096
kernel_rfl PRE_first_tail_x15_r0_body.craise41 : Nat.ble PRE_first_tail_x15_r0_body.Pc41.N0 16096 = true
theorem PRE_first_tail_x15_r0_body.raised41 : Host.Ts.Sim.Full.Raised PRE_first_tail_x15_r0_body.Pc41 PRE_first_tail_x15_r0_body.P41 :=
  .inr ⟨16096, rfl, Nat.le_of_ble_eq_true PRE_first_tail_x15_r0_body.craise41, rfl⟩
noncomputable abbrev PRE_first_tail_x15_r0_body.cx0_41 : Host.Load.LSt := clearTokens (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s404.ffi)
noncomputable abbrev PRE_first_tail_x15_r0_body.cx1_41 : Host.Load.LSt := clearTokens (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s403.ffi)
def PRE_first_tail_x15_r0_body.khinv41 : PTrie Nat := Stage.setAll PTrie.nil []
def PRE_first_tail_x15_r0_body.kninv41 : PTrie Nat := Stage.setAll PTrie.nil []
/-- The stage's footprint: its written and fresh handles, fresh nodes, written and fresh items. -/
def PRE_first_tail_x15_r0_body.cwS41 : List Nat := []
def PRE_first_tail_x15_r0_body.cnS41 : List Nat := List.range' 16096 0
def PRE_first_tail_x15_r0_body.ciS41 : List Nat := [] ++ List.range' 16096 0

-- the small checks (`MChecks`'s)
kernel_rfl PRE_first_tail_x15_r0_body.cnh041 : PRE_first_tail_x15_r0_body.kd41.nh0 = PRE_first_tail_x15_r0_body.cx0_41.mlx.next
kernel_rfl PRE_first_tail_x15_r0_body.cnh141 : PRE_first_tail_x15_r0_body.kd41.nh1 = PRE_first_tail_x15_r0_body.cx1_41.mlx.next
kernel_rfl PRE_first_tail_x15_r0_body.cnn041 : PRE_first_tail_x15_r0_body.kd41.nn0 = PRE_first_tail_x15_r0_body.cx0_41.mlx.nnext
kernel_rfl PRE_first_tail_x15_r0_body.cnn141 : PRE_first_tail_x15_r0_body.kd41.nn1 = PRE_first_tail_x15_r0_body.cx1_41.mlx.nnext
kernel_rfl PRE_first_tail_x15_r0_body.cplo41 : (Nat.blt 0 PRE_first_tail_x15_r0_body.P41.lo && Nat.ble PRE_first_tail_x15_r0_body.P41.lo PRE_first_tail_x15_r0_body.cx0_41.mlx.next && Nat.ble PRE_first_tail_x15_r0_body.P41.lo RData.bigHi && Nat.ble RData.bigHi PRE_first_tail_x15_r0_body.P41.E) = true
kernel_rfl PRE_first_tail_x15_r0_body.ccnt41 : (Nat.ble PRE_first_tail_x15_r0_body.cx0_41.mlx.next PRE_first_tail_x15_r0_body.cx1_41.mlx.next && Nat.ble PRE_first_tail_x15_r0_body.cx0_41.mlx.nnext PRE_first_tail_x15_r0_body.cx1_41.mlx.nnext) = true
kernel_rfl PRE_first_tail_x15_r0_body.cnband41 : (Nat.blt 0 PRE_first_tail_x15_r0_body.P41.NL && Nat.ble PRE_first_tail_x15_r0_body.P41.NL PRE_first_tail_x15_r0_body.P41.N0 && Nat.ble PRE_first_tail_x15_r0_body.P41.N0 PRE_first_tail_x15_r0_body.cx0_41.mlx.nnext) = true
kernel_rfl PRE_first_tail_x15_r0_body.chbelow41 : PRE_first_tail_x15_r0_body.kd41.checkHndBelow = true
kernel_rfl PRE_first_tail_x15_r0_body.chren41 : checkRenG PRE_first_tail_x15_r0_body.kd41.hnd PRE_first_tail_x15_r0_body.khinv41 (phB PRE_first_tail_x15_r0_body.cx0_41.mlx) = true
kernel_rfl PRE_first_tail_x15_r0_body.cband41 : PRE_first_tail_x15_r0_body.kd41.checkBand PRE_first_tail_x15_r0_body.P41.lo = true
kernel_rfl PRE_first_tail_x15_r0_body.cnh1pos41 : Nat.blt 0 PRE_first_tail_x15_r0_body.kd41.nh1 = true
kernel_rfl PRE_first_tail_x15_r0_body.cnren41 : checkRenG PRE_first_tail_x15_r0_body.kd41.node PRE_first_tail_x15_r0_body.kninv41 (pnB PRE_first_tail_x15_r0_body.cx0_41.mlx) = true
kernel_rfl PRE_first_tail_x15_r0_body.cnlow41 : (PTrie.keysA PRE_first_tail_x15_r0_body.kd41.node).all (fun j => Nat.ble PRE_first_tail_x15_r0_body.P41.NL j && Nat.blt (PRE_first_tail_x15_r0_body.kd41.nodeF j) PRE_first_tail_x15_r0_body.cx1_41.mlx.nnext) = true
kernel_rfl PRE_first_tail_x15_r0_body.cabs0a41 : PRE_first_tail_x15_r0_body.cx0_41.mlx.arrs.get 0 = none
kernel_rfl PRE_first_tail_x15_r0_body.cabs0b41 : PRE_first_tail_x15_r0_body.cx0_41.mlx.objs.get 0 = none
kernel_rfl PRE_first_tail_x15_r0_body.ctok141 : PRE_first_tail_x15_r0_body.cx1_41.mlx.tokens = []
kernel_rfl PRE_first_tail_x15_r0_body.cpend41 : PRE_first_tail_x15_r0_body.cx1_41.mlx.pending = PRE_first_tail_x15_r0_body.cx0_41.mlx.pending.map PRE_first_tail_x15_r0_body.kappa41.pend
kernel_rfl PRE_first_tail_x15_r0_body.cerrh41 : PRE_first_tail_x15_r0_body.cx1_41.mlx.errh = PRE_first_tail_x15_r0_body.cx0_41.mlx.errh.map PRE_first_tail_x15_r0_body.kappa41.arg
kernel_rfl PRE_first_tail_x15_r0_body.cfiles41 : PRE_first_tail_x15_r0_body.cx1_41.mlx.files = PRE_first_tail_x15_r0_body.cx0_41.mlx.files
kernel_rfl PRE_first_tail_x15_r0_body.carch41 : PRE_first_tail_x15_r0_body.cx1_41.mlx.arch = PRE_first_tail_x15_r0_body.cx0_41.mlx.arch
kernel_rfl PRE_first_tail_x15_r0_body.csizes41 : PRE_first_tail_x15_r0_body.cx1_41.mlx.deviceSizes = PRE_first_tail_x15_r0_body.cx0_41.mlx.deviceSizes
kernel_rfl PRE_first_tail_x15_r0_body.cwired41 : PRE_first_tail_x15_r0_body.cx1_41.mlx.wired = PRE_first_tail_x15_r0_body.cx0_41.mlx.wired
kernel_rfl PRE_first_tail_x15_r0_body.chost41 : PRE_first_tail_x15_r0_body.cx1_41.host = PRE_first_tail_x15_r0_body.cx0_41.host
-- the compaction map's addresses are `PRE_first_tail_x15_r0_body.kd41`'s
kernel_rfl PRE_first_tail_x15_r0_body.ckn041 : PRE_first_tail_x15_r0_body.kd41.n0 = 2706744
kernel_rfl PRE_first_tail_x15_r0_body.ckn141 : PRE_first_tail_x15_r0_body.kd41.n1 = 2706763
kernel_rfl PRE_first_tail_x15_r0_body.ckheap41 : (PTrie.keysA PRE_first_tail_x15_r0_body.kd41.heap).all (fun x => Nat.ble 2706743 x) = true
kernel_rfl PRE_first_tail_x15_r0_body.ckpl41 : (List.range 1).all (fun j => decide (PRE_first_tail_x15_r0_body.kd41.heap.get (2706743 + j) = nth? PRE_first_tail_x15_r0_body.pl41 j)) = true
-- the map fixes the call's names (`Conv.fixOld_compact`), the call's counters
kernel_rfl PRE_first_tail_x15_r0_body.fja41 : Nat.ble 2706743 2706743 = true
kernel_rfl PRE_first_tail_x15_r0_body.fn41 : Nat.ble 1807 1807 = true
kernel_rfl PRE_first_tail_x15_r0_body.fjaD41 : Nat.ble 2706743 PRE_first_tail_x15_r0_body.kd41.n0 = true
kernel_rfl PRE_first_tail_x15_r0_body.fxn41 : Nat.ble 19004 PRE_first_tail_x15_r0_body.kd41.nh0 = true
kernel_rfl PRE_first_tail_x15_r0_body.fnn41 : Nat.ble 16096 PRE_first_tail_x15_r0_body.kd41.nn0 = true
kernel_rfl PRE_first_tail_x15_r0_body.fxb41 : Nat.ble 19004 RData.bigHi = true
kernel_rfl PRE_first_tail_x15_r0_body.fheap41 : (PTrie.keysA PRE_first_tail_x15_r0_body.kd41.heap).all (Nat.ble (⟨19004, 16096, 2706743, 1807⟩ : Conv.Cnt).ja) = true
kernel_rfl PRE_first_tail_x15_r0_body.fhnd41 : (PTrie.keysA PRE_first_tail_x15_r0_body.kd41.hnd).all (Nat.ble (⟨19004, 16096, 2706743, 1807⟩ : Conv.Cnt).xn) = true
kernel_rfl PRE_first_tail_x15_r0_body.fnode41 : (PTrie.keysA PRE_first_tail_x15_r0_body.kd41.node).all (Nat.ble (⟨19004, 16096, 2706743, 1807⟩ : Conv.Cnt).nn) = true
/-- The compaction map fixes the call's names. -/
theorem PRE_first_tail_x15_r0_body.cfix41 : Conv.FixOld (⟨19004, 16096, 2706743, 1807⟩ : Conv.Cnt) PRE_first_tail_x15_r0_body.kappa41 :=
  Conv.fixOld_compact (Nat.le_of_ble_eq_true PRE_first_tail_x15_r0_body.fja41) (Nat.le_of_ble_eq_true PRE_first_tail_x15_r0_body.fn41) (Nat.le_of_ble_eq_true PRE_first_tail_x15_r0_body.fjaD41) (Nat.le_of_ble_eq_true PRE_first_tail_x15_r0_body.fxn41) (Nat.le_of_ble_eq_true PRE_first_tail_x15_r0_body.fnn41) (Nat.le_of_ble_eq_true PRE_first_tail_x15_r0_body.fxb41) PRE_first_tail_x15_r0_body.fheap41 PRE_first_tail_x15_r0_body.fhnd41 PRE_first_tail_x15_r0_body.fnode41
kernel_rfl PRE_first_tail_x15_r0_body.fcxn41 : (⟨19004, 16096, 2706743, 1807⟩ : Conv.Cnt).xn = (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s402.ffi).mlx.next
kernel_rfl PRE_first_tail_x15_r0_body.fcnn41 : (⟨19004, 16096, 2706743, 1807⟩ : Conv.Cnt).nn = (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s402.ffi).mlx.nnext
kernel_rfl PRE_first_tail_x15_r0_body.fle041 : (Nat.ble (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s402.ffi).mlx.next PRE_first_tail_x15_r0_body.cx0_41.mlx.next && Nat.ble (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s402.ffi).mlx.nnext PRE_first_tail_x15_r0_body.cx0_41.mlx.nnext && Nat.ble (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s402.ffi).mlx.next RData.bigHi) = true
kernel_rfl PRE_first_tail_x15_r0_body.fnk41 : (PTrie.keysA PRE_first_tail_x15_r0_body.kd41.node).all (Nat.ble (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s402.ffi).mlx.nnext) = true
-- the merged state keeps the call's entries off the stage's footprint
kernel_rfl PRE_first_tail_x15_r0_body.f1A41 : PRE_first_tail_x15_r0_body.cx1_41.mlx.arrs = Stage.setAll (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s402.ffi).mlx.arrs (PRE_first_tail_x15_r0_body.cwS41.filterMap fun i => (PRE_first_tail_x15_r0_body.cx1_41.mlx.arrs.get i).map (i, ·))
kernel_rfl PRE_first_tail_x15_r0_body.f1O41 : PRE_first_tail_x15_r0_body.cx1_41.mlx.objs = Stage.setAll (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s402.ffi).mlx.objs (PRE_first_tail_x15_r0_body.cwS41.filterMap fun i => (PRE_first_tail_x15_r0_body.cx1_41.mlx.objs.get i).map (i, ·))
kernel_rfl PRE_first_tail_x15_r0_body.f1N41 : PRE_first_tail_x15_r0_body.cx1_41.mlx.nodes = Stage.setAll (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s402.ffi).mlx.nodes (PRE_first_tail_x15_r0_body.cnS41.filterMap fun i => (PRE_first_tail_x15_r0_body.cx1_41.mlx.nodes.get i).map (i, ·))
kernel_rfl PRE_first_tail_x15_r0_body.f1I41 : PRE_first_tail_x15_r0_body.cx1_41.mlx.items = Stage.setAll (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s402.ffi).mlx.items (PRE_first_tail_x15_r0_body.ciS41.filterMap fun i => (PRE_first_tail_x15_r0_body.cx1_41.mlx.items.get i).map (i, ·))
kernel_rfl PRE_first_tail_x15_r0_body.fbd41 : (PRE_first_tail_x15_r0_body.clo41 ++ PRE_first_tail_x15_r0_body.cln41 ++ PRE_first_tail_x15_r0_body.cli41 ++ PRE_first_tail_x15_r0_body.cwS41 ++ PRE_first_tail_x15_r0_body.cnS41 ++ PRE_first_tail_x15_r0_body.ciS41).all (fun i => Nat.blt (i / 4096) (4 ^ 31)) = true
kernel_rfl PRE_first_tail_x15_r0_body.fincW41 : PRE_first_tail_x15_r0_body.cwS41.all (fun h => !Nat.blt h (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s402.ffi).mlx.next || PRE_first_tail_x15_r0_body.clo41.contains h) = true
kernel_rfl PRE_first_tail_x15_r0_body.fincI41 : PRE_first_tail_x15_r0_body.ciS41.all (fun k => !Nat.blt k (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s402.ffi).mlx.nnext || PRE_first_tail_x15_r0_body.cli41.contains k) = true
kernel_rfl PRE_first_tail_x15_r0_body.fincN41 : PRE_first_tail_x15_r0_body.cnS41.all (Nat.ble (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s402.ffi).mlx.nnext) = true
kernel_rfl PRE_first_tail_x15_r0_body.flnF41 : PRE_first_tail_x15_r0_body.cln41.all (Nat.ble (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s402.ffi).mlx.nnext) = true
-- the checks over the changed lists
kernel_rfl PRE_first_tail_x15_r0_body.fh41 : PRE_first_tail_x15_r0_body.clo41.all (handleOK PRE_first_tail_x15_r0_body.kappa41 PRE_first_tail_x15_r0_body.P41.lo PRE_first_tail_x15_r0_body.cx0_41.mlx PRE_first_tail_x15_r0_body.cx1_41.mlx) = true
kernel_rfl PRE_first_tail_x15_r0_body.fo41 : PRE_first_tail_x15_r0_body.clo41.map (fun h => PRE_first_tail_x15_r0_body.cx1_41.mlx.objs.get (PRE_first_tail_x15_r0_body.kappa41.handle h)) = PRE_first_tail_x15_r0_body.clo41.map (fun h => (PRE_first_tail_x15_r0_body.cx0_41.mlx.objs.get h).map PRE_first_tail_x15_r0_body.kappa41.nobj)
kernel_rfl PRE_first_tail_x15_r0_body.fok41 : PRE_first_tail_x15_r0_body.clo41.all (objOK PRE_first_tail_x15_r0_body.kappa41 PRE_first_tail_x15_r0_body.P41.NL PRE_first_tail_x15_r0_body.cx0_41.mlx) = true
kernel_rfl PRE_first_tail_x15_r0_body.fnd41 : PRE_first_tail_x15_r0_body.cln41.all (nodeOKF PRE_first_tail_x15_r0_body.kappa41 PRE_first_tail_x15_r0_body.P41 PRE_first_tail_x15_r0_body.cx0_41.mlx PRE_first_tail_x15_r0_body.cx1_41.mlx) = true
kernel_rfl PRE_first_tail_x15_r0_body.fp41 : ((PRE_first_tail_x15_r0_body.cln41.filter (fullB PRE_first_tail_x15_r0_body.P41))).map (fun i => (PRE_first_tail_x15_r0_body.cx1_41.mlx.nodes.get (PRE_first_tail_x15_r0_body.kappa41.node i)).map Host.Mlx.Ffi.Node.prim) =
  ((PRE_first_tail_x15_r0_body.cln41.filter (fullB PRE_first_tail_x15_r0_body.P41))).map (fun i => (PRE_first_tail_x15_r0_body.cx0_41.mlx.nodes.get i).map fun nd => PRE_first_tail_x15_r0_body.kappa41.prim nd.prim)
kernel_rfl PRE_first_tail_x15_r0_body.fnordI41 : incrB PRE_first_tail_x15_r0_body.kd41.nodeF (List.range' 16096 0) = true
kernel_rfl PRE_first_tail_x15_r0_body.fnordK41 : (PTrie.keysA PRE_first_tail_x15_r0_body.kd41.node).all (fun k => Nat.ble 16096 k && Nat.blt k 16096) = true
kernel_rfl PRE_first_tail_x15_r0_body.fnordL41 : (PRE_first_tail_x15_r0_body.cln41.filter (Nat.ble PRE_first_tail_x15_r0_body.P41.N0)).all (fun i => Nat.ble i (PRE_first_tail_x15_r0_body.kd41.nodeF i) && (Nat.blt i 16096 || Nat.ble PRE_first_tail_x15_r0_body.kd41.nn0 i)) = true
theorem PRE_first_tail_x15_r0_body.fnord41 : (PRE_first_tail_x15_r0_body.cln41.filter (Nat.ble PRE_first_tail_x15_r0_body.P41.N0)).all (fun i => Nat.ble i (PRE_first_tail_x15_r0_body.kd41.nodeF i) &&
    (PTrie.keysA PRE_first_tail_x15_r0_body.kd41.node).all fun j => !Nat.blt j i || Nat.blt (PRE_first_tail_x15_r0_body.kd41.nodeF j) (PRE_first_tail_x15_r0_body.kd41.nodeF i)) = true :=
  cnord_of PRE_first_tail_x15_r0_body.cnlow41 PRE_first_tail_x15_r0_body.cnn141 PRE_first_tail_x15_r0_body.fnordI41 PRE_first_tail_x15_r0_body.fnordK41 PRE_first_tail_x15_r0_body.fnordL41
kernel_rfl PRE_first_tail_x15_r0_body.fi41 : PRE_first_tail_x15_r0_body.cli41.all (pnB PRE_first_tail_x15_r0_body.cx0_41.mlx) = true
kernel_rfl PRE_first_tail_x15_r0_body.fii41 : PRE_first_tail_x15_r0_body.cli41.all (fun k => decide (PRE_first_tail_x15_r0_body.cx1_41.mlx.items.get (PRE_first_tail_x15_r0_body.kappa41.node k) = (PRE_first_tail_x15_r0_body.cx0_41.mlx.items.get k).map PRE_first_tail_x15_r0_body.kappa41.nv)) = true
/-- **The compaction's footprint.** -/
theorem PRE_first_tail_x15_r0_body.cfoot41 (clean : Conv.NClean (⟨19004, 16096, 2706743, 1807⟩ : Conv.Cnt) (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s402.ffi).mlx) (hltC : ∀ h, PH (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s402.ffi).mlx h → h < (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s402.ffi).mlx.next) (nltC : ∀ i, PN (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s402.ffi).mlx i → i < (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s402.ffi).mlx.nnext) (itemsC : ∀ k v, (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s402.ffi).mlx.items.get k = some v → PN (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s402.ffi).mlx k) (tracedC : ∀ h o, (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s402.ffi).mlx.objs.get h = some o → ∀ i ∈ objTraces o, i < PRE_first_tail_x15_r0_body.P41.NL) (cl : SSt (· < 1807) PRE_first_tail_x15_r0_body.cx0_41.mlx) :
    Conv.MFoot PRE_first_tail_x15_r0_body.P41 1807 PRE_first_tail_x15_r0_body.kappa41 PRE_first_tail_x15_r0_body.kd41 PRE_first_tail_x15_r0_body.khinv41 PRE_first_tail_x15_r0_body.kninv41 (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s402.ffi).mlx PRE_first_tail_x15_r0_body.cx0_41.mlx PRE_first_tail_x15_r0_body.cx1_41.mlx (⟨19004, 16096, 2706743, 1807⟩ : Conv.Cnt) PRE_first_tail_x15_r0_body.clo41 PRE_first_tail_x15_r0_body.cln41 PRE_first_tail_x15_r0_body.cli41 PRE_first_tail_x15_r0_body.cwS41 PRE_first_tail_x15_r0_body.cnS41 PRE_first_tail_x15_r0_body.ciS41 :=
  ⟨rfl, rfl, rfl, PRE_first_tail_x15_r0_body.cnh041, PRE_first_tail_x15_r0_body.cnh141, PRE_first_tail_x15_r0_body.cnn041, PRE_first_tail_x15_r0_body.cnn141, PRE_first_tail_x15_r0_body.cplo41, PRE_first_tail_x15_r0_body.ccnt41, PRE_first_tail_x15_r0_body.cnband41, PRE_first_tail_x15_r0_body.chbelow41, PRE_first_tail_x15_r0_body.chren41, PRE_first_tail_x15_r0_body.cband41, PRE_first_tail_x15_r0_body.cnh1pos41, PRE_first_tail_x15_r0_body.cnren41, PRE_first_tail_x15_r0_body.cnlow41, PRE_first_tail_x15_r0_body.cabs0a41, PRE_first_tail_x15_r0_body.cabs0b41, PRE_first_tail_x15_r0_body.ctok141, PRE_first_tail_x15_r0_body.cpend41, PRE_first_tail_x15_r0_body.cerrh41, PRE_first_tail_x15_r0_body.cfiles41, PRE_first_tail_x15_r0_body.carch41, PRE_first_tail_x15_r0_body.csizes41, PRE_first_tail_x15_r0_body.cwired41, PRE_first_tail_x15_r0_body.cfix41, clean, PRE_first_tail_x15_r0_body.fcxn41, PRE_first_tail_x15_r0_body.fcnn41, hltC, nltC, itemsC, tracedC, cl, PRE_first_tail_x15_r0_body.fle041, PRE_first_tail_x15_r0_body.fnk41, PRE_first_tail_x15_r0_body.ckA41, PRE_first_tail_x15_r0_body.cobjsK41, PRE_first_tail_x15_r0_body.cnodesK41, PRE_first_tail_x15_r0_body.citemsK41, PRE_first_tail_x15_r0_body.f1A41, PRE_first_tail_x15_r0_body.f1O41, PRE_first_tail_x15_r0_body.f1N41, PRE_first_tail_x15_r0_body.f1I41, PRE_first_tail_x15_r0_body.fbd41, PRE_first_tail_x15_r0_body.fincW41, PRE_first_tail_x15_r0_body.fincI41, PRE_first_tail_x15_r0_body.fincN41, PRE_first_tail_x15_r0_body.flnF41, PRE_first_tail_x15_r0_body.fh41, PRE_first_tail_x15_r0_body.fo41, PRE_first_tail_x15_r0_body.fok41, PRE_first_tail_x15_r0_body.fnd41, PRE_first_tail_x15_r0_body.fp41, PRE_first_tail_x15_r0_body.fnord41, PRE_first_tail_x15_r0_body.fi41, PRE_first_tail_x15_r0_body.fii41⟩
theorem PRE_first_tail_x15_r0_body.cnshift41 (clean : Conv.NClean (⟨19004, 16096, 2706743, 1807⟩ : Conv.Cnt) (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s402.ffi).mlx) (hltC : ∀ h, PH (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s402.ffi).mlx h → h < (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s402.ffi).mlx.next) (nltC : ∀ i, PN (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s402.ffi).mlx i → i < (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s402.ffi).mlx.nnext) (itemsC : ∀ k v, (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s402.ffi).mlx.items.get k = some v → PN (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s402.ffi).mlx k) (tracedC : ∀ h o, (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s402.ffi).mlx.objs.get h = some o → ∀ i ∈ objTraces o, i < PRE_first_tail_x15_r0_body.P41.NL) (cl : SSt (· < 1807) PRE_first_tail_x15_r0_body.cx0_41.mlx) : NShift PRE_first_tail_x15_r0_body.P41 1807 PRE_first_tail_x15_r0_body.kappa41 PRE_first_tail_x15_r0_body.cx0_41 PRE_first_tail_x15_r0_body.cx1_41 :=
  Conv.nshift_of_foot (PRE_first_tail_x15_r0_body.cfoot41 clean hltC nltC itemsC tracedC cl) PRE_first_tail_x15_r0_body.chost41 (compact_a_eq PRE_first_tail_x15_r0_body.ckn041 PRE_first_tail_x15_r0_body.ckn141 PRE_first_tail_x15_r0_body.ckheap41 PRE_first_tail_x15_r0_body.ckpl41)

-- the observers: the layers' states at the call, the canonical and the merged state, their footprints and checks
noncomputable def PRE_first_tail_x15_r0_body.fxC_41 : PTrie Unit := (Host.Ts.Sim.Full.freedOf PRE_first_tail_x15_r0_body.s402.ffi).getD PTrie.nil
noncomputable def PRE_first_tail_x15_r0_body.krC_41 : Host.Load.Layers.KRec := (Host.Ts.Sim.Full.krecOf PRE_first_tail_x15_r0_body.s402.ffi).getD Host.Load.Layers.KRec.empty
kernel_rfl PRE_first_tail_x15_r0_body.ofxC_41 : (Host.Ts.Sim.Full.freedOf PRE_first_tail_x15_r0_body.s402.ffi) = some PRE_first_tail_x15_r0_body.fxC_41
kernel_rfl PRE_first_tail_x15_r0_body.okrC_41 : (Host.Ts.Sim.Full.krecOf PRE_first_tail_x15_r0_body.s402.ffi) = some PRE_first_tail_x15_r0_body.krC_41
noncomputable def PRE_first_tail_x15_r0_body.fx0_41 : PTrie Unit := (Host.Ts.Sim.Full.freedOf PRE_first_tail_x15_r0_body.s404.ffi).getD PTrie.nil
noncomputable def PRE_first_tail_x15_r0_body.kr0_41 : Host.Load.Layers.KRec := (Host.Ts.Sim.Full.krecOf PRE_first_tail_x15_r0_body.s404.ffi).getD Host.Load.Layers.KRec.empty
kernel_rfl PRE_first_tail_x15_r0_body.ofx0_41 : (Host.Ts.Sim.Full.freedOf PRE_first_tail_x15_r0_body.s404.ffi) = some PRE_first_tail_x15_r0_body.fx0_41
kernel_rfl PRE_first_tail_x15_r0_body.okr0_41 : (Host.Ts.Sim.Full.krecOf PRE_first_tail_x15_r0_body.s404.ffi) = some PRE_first_tail_x15_r0_body.kr0_41
noncomputable def PRE_first_tail_x15_r0_body.fx1_41 : PTrie Unit := (Host.Ts.Sim.Full.freedOf PRE_first_tail_x15_r0_body.s403.ffi).getD PTrie.nil
noncomputable def PRE_first_tail_x15_r0_body.kr1_41 : Host.Load.Layers.KRec := (Host.Ts.Sim.Full.krecOf PRE_first_tail_x15_r0_body.s403.ffi).getD Host.Load.Layers.KRec.empty
kernel_rfl PRE_first_tail_x15_r0_body.ofx1_41 : (Host.Ts.Sim.Full.freedOf PRE_first_tail_x15_r0_body.s403.ffi) = some PRE_first_tail_x15_r0_body.fx1_41
kernel_rfl PRE_first_tail_x15_r0_body.okr1_41 : (Host.Ts.Sim.Full.krecOf PRE_first_tail_x15_r0_body.s403.ffi) = some PRE_first_tail_x15_r0_body.kr1_41
kernel_rfl PRE_first_tail_x15_r0_body.ff041 : PRE_first_tail_x15_r0_body.fx0_41 = Stage.setAll PRE_first_tail_x15_r0_body.fxC_41 (PRE_first_tail_x15_r0_body.clo41.filterMap fun i => (PRE_first_tail_x15_r0_body.fx0_41.get i).map (i, ·))
kernel_rfl PRE_first_tail_x15_r0_body.ff141 : PRE_first_tail_x15_r0_body.fx1_41 = Stage.setAll PRE_first_tail_x15_r0_body.fxC_41 (PRE_first_tail_x15_r0_body.cwS41.filterMap fun i => (PRE_first_tail_x15_r0_body.fx1_41.get i).map (i, ·))
kernel_rfl PRE_first_tail_x15_r0_body.ffck41 : freedLB PRE_first_tail_x15_r0_body.kappa41 PRE_first_tail_x15_r0_body.cx0_41.mlx PRE_first_tail_x15_r0_body.fx0_41 PRE_first_tail_x15_r0_body.fx1_41 PRE_first_tail_x15_r0_body.clo41 = true
kernel_rfl PRE_first_tail_x15_r0_body.fkf041 : PRE_first_tail_x15_r0_body.kr0_41.flags = Stage.setAll PRE_first_tail_x15_r0_body.krC_41.flags (PRE_first_tail_x15_r0_body.clo41.filterMap fun i => (PRE_first_tail_x15_r0_body.kr0_41.flags.get i).map (i, ·))
kernel_rfl PRE_first_tail_x15_r0_body.fkt041 : PRE_first_tail_x15_r0_body.kr0_41.targs = Stage.setAll PRE_first_tail_x15_r0_body.krC_41.targs (PRE_first_tail_x15_r0_body.clo41.filterMap fun i => (PRE_first_tail_x15_r0_body.kr0_41.targs.get i).map (i, ·))
kernel_rfl PRE_first_tail_x15_r0_body.fkf141 : PRE_first_tail_x15_r0_body.kr1_41.flags = Stage.setAll PRE_first_tail_x15_r0_body.krC_41.flags (PRE_first_tail_x15_r0_body.cwS41.filterMap fun i => (PRE_first_tail_x15_r0_body.kr1_41.flags.get i).map (i, ·))
kernel_rfl PRE_first_tail_x15_r0_body.fkt141 : PRE_first_tail_x15_r0_body.kr1_41.targs = Stage.setAll PRE_first_tail_x15_r0_body.krC_41.targs (PRE_first_tail_x15_r0_body.cwS41.filterMap fun i => (PRE_first_tail_x15_r0_body.kr1_41.targs.get i).map (i, ·))
kernel_rfl PRE_first_tail_x15_r0_body.fkck41 : krecLB PRE_first_tail_x15_r0_body.kappa41 1807 PRE_first_tail_x15_r0_body.cx0_41.mlx PRE_first_tail_x15_r0_body.kr0_41 PRE_first_tail_x15_r0_body.kr1_41 PRE_first_tail_x15_r0_body.clo41 = true
kernel_rfl PRE_first_tail_x15_r0_body.fkn41 : Nat.ble 1807 1807 = true
-- the bridge and the pending traces' regions
kernel_rfl PRE_first_tail_x15_r0_body.cbridge41 : Host.Ts.Sim.Full.bridgeOf PRE_first_tail_x15_r0_body.s403.ffi = Host.Ts.Sim.Full.bridgeOf PRE_first_tail_x15_r0_body.s404.ffi
kernel_rfl PRE_first_tail_x15_r0_body.cpendR41 : pendRegB PRE_first_tail_x15_r0_body.kappa41 (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s404.ffi).mlx = true
kernel_rfl PRE_first_tail_x15_r0_body.cpendLe41 : Nat.ble (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s404.ffi).mlx.next (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s403.ffi).mlx.next = true
/-- **The compaction's native shift**, given the call's bookkeeping, its relation's facts (the model's and the
observers') and the canonical closedness. -/
theorem PRE_first_tail_x15_r0_body.cshift41 (clean : Conv.NClean (⟨19004, 16096, 2706743, 1807⟩ : Conv.Cnt) (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s402.ffi).mlx) (hltC : ∀ h, PH (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s402.ffi).mlx h → h < (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s402.ffi).mlx.next) (nltC : ∀ i, PN (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s402.ffi).mlx i → i < (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s402.ffi).mlx.nnext) (itemsC : ∀ k v, (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s402.ffi).mlx.items.get k = some v → PN (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s402.ffi).mlx k) (tracedC : ∀ h o, (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s402.ffi).mlx.objs.get h = some o → ∀ i ∈ objTraces o, i < PRE_first_tail_x15_r0_body.P41.NL) (cl : SSt (· < 1807) PRE_first_tail_x15_r0_body.cx0_41.mlx)
    (hobjC : ∀ h, PRE_first_tail_x15_r0_body.fxC_41.get h = some () → ((Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s402.ffi).mlx.objs.get h).isSome = true)
    (hfC : ∀ h, (PRE_first_tail_x15_r0_body.krC_41.flags.get h).isSome = true → ((Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s402.ffi).mlx.objs.get h).isSome = true)
    (htC : ∀ h, (PRE_first_tail_x15_r0_body.krC_41.targs.get h).isSome = true → ((Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s402.ffi).mlx.objs.get h).isSome = true)
    (hclC : ∀ h l, PRE_first_tail_x15_r0_body.krC_41.targs.get h = some l → Host.Ts.Sim.Full.STargs (· < (⟨19004, 16096, 2706743, 1807⟩ : Conv.Cnt).n) l) :
    Conv.FullShiftQ PRE_first_tail_x15_r0_body.P41 1807 PRE_first_tail_x15_r0_body.kappa41 PRE_first_tail_x15_r0_body.s404.ffi PRE_first_tail_x15_r0_body.s403.ffi :=
  ⟨PRE_first_tail_x15_r0_body.cnshift41 clean hltC nltC itemsC tracedC cl, PRE_first_tail_x15_r0_body.cqueue41, fun t ht => bSN_sound (List.all_eq_true.mp PRE_first_tail_x15_r0_body.ctokSupp41 t ht),
    PRE_first_tail_x15_r0_body.cbridge41,
    liveShift_foot (x0' := Host.Ts.Sim.Full.mlxOf PRE_first_tail_x15_r0_body.s404.ffi) (x1' := Host.Ts.Sim.Full.mlxOf PRE_first_tail_x15_r0_body.s403.ffi) (PRE_first_tail_x15_r0_body.cfoot41 clean hltC nltC itemsC tracedC cl) rfl PRE_first_tail_x15_r0_body.ofx0_41 PRE_first_tail_x15_r0_body.ofx1_41 hobjC PRE_first_tail_x15_r0_body.ff041 PRE_first_tail_x15_r0_body.ff141 PRE_first_tail_x15_r0_body.ffck41,
    kernShift_foot (x0' := Host.Ts.Sim.Full.mlxOf PRE_first_tail_x15_r0_body.s404.ffi) (x1' := Host.Ts.Sim.Full.mlxOf PRE_first_tail_x15_r0_body.s403.ffi) (PRE_first_tail_x15_r0_body.cfoot41 clean hltC nltC itemsC tracedC cl) rfl PRE_first_tail_x15_r0_body.okr0_41 PRE_first_tail_x15_r0_body.okr1_41 (Nat.le_of_ble_eq_true PRE_first_tail_x15_r0_body.fkn41) hfC htC hclC
      PRE_first_tail_x15_r0_body.fkf041 PRE_first_tail_x15_r0_body.fkt041 PRE_first_tail_x15_r0_body.fkf141 PRE_first_tail_x15_r0_body.fkt141 PRE_first_tail_x15_r0_body.fkck41,
    pendReg_of rfl PRE_first_tail_x15_r0_body.cnh041 PRE_first_tail_x15_r0_body.cnh141 (Nat.le_of_ble_eq_true PRE_first_tail_x15_r0_body.cpendLe41) PRE_first_tail_x15_r0_body.cpendR41⟩

end Host.Load.Run.Tpl
