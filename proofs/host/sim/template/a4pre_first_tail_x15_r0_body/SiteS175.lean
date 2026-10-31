import host.sim.template.a4pre_first_tail_x15_r0_body.SiteCl175
import host.sim.conv.CompactFull
import host.sim.template.FootGen
set_option Elab.async false
namespace Host.Load.Run.Tpl
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
open Host.Ts Host.Ts.Sim Host.Ts.Sim.Template

/-! The compaction's native shift at call site 175 from its footprint (`Conv.nshift_of_foot`), and the observers'
(`liveShift_foot`, `kernShift_foot`): `Conv.FullShiftQ` for `Conv.full_compactQ`, given the call's bookkeeping and its
relation's facts. -/

/-- The load parameters of the chain (band-free: its start's node counter as `NL` and `N0`). -/
def PRE_first_tail_x15_r0_body.Pc175 : LoadP := ⟨18151, 131072, 1099511627776, 15235, 15235, []⟩
/-- The site's band raised to the map's checked fixed-node prefix, including newly recorded closure traces. -/
def PRE_first_tail_x15_r0_body.P175 : LoadP := PRE_first_tail_x15_r0_body.Pc175.raise 18762
kernel_rfl PRE_first_tail_x15_r0_body.craise175 : Nat.ble PRE_first_tail_x15_r0_body.Pc175.N0 18762 = true
theorem PRE_first_tail_x15_r0_body.raised175 : Host.Ts.Sim.Full.Raised PRE_first_tail_x15_r0_body.Pc175 PRE_first_tail_x15_r0_body.P175 :=
  .inr ⟨18762, rfl, Nat.le_of_ble_eq_true PRE_first_tail_x15_r0_body.craise175, rfl⟩
noncomputable abbrev PRE_first_tail_x15_r0_body.cx0_175 : Host.Load.LSt := clearTokens (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1547.ffi)
noncomputable abbrev PRE_first_tail_x15_r0_body.cx1_175 : Host.Load.LSt := clearTokens (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1546.ffi)
def PRE_first_tail_x15_r0_body.khinv175 : PTrie Nat := Stage.setAll PTrie.nil []
def PRE_first_tail_x15_r0_body.kninv175 : PTrie Nat := Stage.setAll PTrie.nil []
/-- The stage's footprint: its written and fresh handles, fresh nodes, written and fresh items. -/
def PRE_first_tail_x15_r0_body.cwS175 : List Nat := []
def PRE_first_tail_x15_r0_body.cnS175 : List Nat := List.range' 18762 0
def PRE_first_tail_x15_r0_body.ciS175 : List Nat := [] ++ List.range' 18762 0

-- the small checks (`MChecks`'s)
kernel_rfl PRE_first_tail_x15_r0_body.cnh0175 : PRE_first_tail_x15_r0_body.kd175.nh0 = PRE_first_tail_x15_r0_body.cx0_175.mlx.next
kernel_rfl PRE_first_tail_x15_r0_body.cnh1175 : PRE_first_tail_x15_r0_body.kd175.nh1 = PRE_first_tail_x15_r0_body.cx1_175.mlx.next
kernel_rfl PRE_first_tail_x15_r0_body.cnn0175 : PRE_first_tail_x15_r0_body.kd175.nn0 = PRE_first_tail_x15_r0_body.cx0_175.mlx.nnext
kernel_rfl PRE_first_tail_x15_r0_body.cnn1175 : PRE_first_tail_x15_r0_body.kd175.nn1 = PRE_first_tail_x15_r0_body.cx1_175.mlx.nnext
kernel_rfl PRE_first_tail_x15_r0_body.cplo175 : (Nat.blt 0 PRE_first_tail_x15_r0_body.P175.lo && Nat.ble PRE_first_tail_x15_r0_body.P175.lo PRE_first_tail_x15_r0_body.cx0_175.mlx.next && Nat.ble PRE_first_tail_x15_r0_body.P175.lo RData.bigHi && Nat.ble RData.bigHi PRE_first_tail_x15_r0_body.P175.E) = true
kernel_rfl PRE_first_tail_x15_r0_body.ccnt175 : (Nat.ble PRE_first_tail_x15_r0_body.cx0_175.mlx.next PRE_first_tail_x15_r0_body.cx1_175.mlx.next && Nat.ble PRE_first_tail_x15_r0_body.cx0_175.mlx.nnext PRE_first_tail_x15_r0_body.cx1_175.mlx.nnext) = true
kernel_rfl PRE_first_tail_x15_r0_body.cnband175 : (Nat.blt 0 PRE_first_tail_x15_r0_body.P175.NL && Nat.ble PRE_first_tail_x15_r0_body.P175.NL PRE_first_tail_x15_r0_body.P175.N0 && Nat.ble PRE_first_tail_x15_r0_body.P175.N0 PRE_first_tail_x15_r0_body.cx0_175.mlx.nnext) = true
kernel_rfl PRE_first_tail_x15_r0_body.chbelow175 : PRE_first_tail_x15_r0_body.kd175.checkHndBelow = true
kernel_rfl PRE_first_tail_x15_r0_body.chren175 : checkRenG PRE_first_tail_x15_r0_body.kd175.hnd PRE_first_tail_x15_r0_body.khinv175 (phB PRE_first_tail_x15_r0_body.cx0_175.mlx) = true
kernel_rfl PRE_first_tail_x15_r0_body.cband175 : PRE_first_tail_x15_r0_body.kd175.checkBand PRE_first_tail_x15_r0_body.P175.lo = true
kernel_rfl PRE_first_tail_x15_r0_body.cnh1pos175 : Nat.blt 0 PRE_first_tail_x15_r0_body.kd175.nh1 = true
kernel_rfl PRE_first_tail_x15_r0_body.cnren175 : checkRenG PRE_first_tail_x15_r0_body.kd175.node PRE_first_tail_x15_r0_body.kninv175 (pnB PRE_first_tail_x15_r0_body.cx0_175.mlx) = true
kernel_rfl PRE_first_tail_x15_r0_body.cnlow175 : (PTrie.keysA PRE_first_tail_x15_r0_body.kd175.node).all (fun j => Nat.ble PRE_first_tail_x15_r0_body.P175.NL j && Nat.blt (PRE_first_tail_x15_r0_body.kd175.nodeF j) PRE_first_tail_x15_r0_body.cx1_175.mlx.nnext) = true
kernel_rfl PRE_first_tail_x15_r0_body.cabs0a175 : PRE_first_tail_x15_r0_body.cx0_175.mlx.arrs.get 0 = none
kernel_rfl PRE_first_tail_x15_r0_body.cabs0b175 : PRE_first_tail_x15_r0_body.cx0_175.mlx.objs.get 0 = none
kernel_rfl PRE_first_tail_x15_r0_body.ctok1175 : PRE_first_tail_x15_r0_body.cx1_175.mlx.tokens = []
kernel_rfl PRE_first_tail_x15_r0_body.cpend175 : PRE_first_tail_x15_r0_body.cx1_175.mlx.pending = PRE_first_tail_x15_r0_body.cx0_175.mlx.pending.map PRE_first_tail_x15_r0_body.kappa175.pend
kernel_rfl PRE_first_tail_x15_r0_body.cerrh175 : PRE_first_tail_x15_r0_body.cx1_175.mlx.errh = PRE_first_tail_x15_r0_body.cx0_175.mlx.errh.map PRE_first_tail_x15_r0_body.kappa175.arg
kernel_rfl PRE_first_tail_x15_r0_body.cfiles175 : PRE_first_tail_x15_r0_body.cx1_175.mlx.files = PRE_first_tail_x15_r0_body.cx0_175.mlx.files
kernel_rfl PRE_first_tail_x15_r0_body.carch175 : PRE_first_tail_x15_r0_body.cx1_175.mlx.arch = PRE_first_tail_x15_r0_body.cx0_175.mlx.arch
kernel_rfl PRE_first_tail_x15_r0_body.csizes175 : PRE_first_tail_x15_r0_body.cx1_175.mlx.deviceSizes = PRE_first_tail_x15_r0_body.cx0_175.mlx.deviceSizes
kernel_rfl PRE_first_tail_x15_r0_body.cwired175 : PRE_first_tail_x15_r0_body.cx1_175.mlx.wired = PRE_first_tail_x15_r0_body.cx0_175.mlx.wired
kernel_rfl PRE_first_tail_x15_r0_body.chost175 : PRE_first_tail_x15_r0_body.cx1_175.host = PRE_first_tail_x15_r0_body.cx0_175.host
-- the compaction map's addresses are `PRE_first_tail_x15_r0_body.kd175`'s
kernel_rfl PRE_first_tail_x15_r0_body.ckn0175 : PRE_first_tail_x15_r0_body.kd175.n0 = 2812315
kernel_rfl PRE_first_tail_x15_r0_body.ckn1175 : PRE_first_tail_x15_r0_body.kd175.n1 = 2812317
kernel_rfl PRE_first_tail_x15_r0_body.ckheap175 : (PTrie.keysA PRE_first_tail_x15_r0_body.kd175.heap).all (fun x => Nat.ble 2812315 x) = true
kernel_rfl PRE_first_tail_x15_r0_body.ckpl175 : (List.range 0).all (fun j => decide (PRE_first_tail_x15_r0_body.kd175.heap.get (2812315 + j) = nth? PRE_first_tail_x15_r0_body.pl175 j)) = true
-- the map fixes the call's names (`Conv.fixOld_compact`), the call's counters
kernel_rfl PRE_first_tail_x15_r0_body.fja175 : Nat.ble 2812315 2812315 = true
kernel_rfl PRE_first_tail_x15_r0_body.fn175 : Nat.ble 7562 7562 = true
kernel_rfl PRE_first_tail_x15_r0_body.fjaD175 : Nat.ble 2812315 PRE_first_tail_x15_r0_body.kd175.n0 = true
kernel_rfl PRE_first_tail_x15_r0_body.fxn175 : Nat.ble 21650 PRE_first_tail_x15_r0_body.kd175.nh0 = true
kernel_rfl PRE_first_tail_x15_r0_body.fnn175 : Nat.ble 18762 PRE_first_tail_x15_r0_body.kd175.nn0 = true
kernel_rfl PRE_first_tail_x15_r0_body.fxb175 : Nat.ble 21650 RData.bigHi = true
kernel_rfl PRE_first_tail_x15_r0_body.fheap175 : (PTrie.keysA PRE_first_tail_x15_r0_body.kd175.heap).all (Nat.ble (⟨21650, 18762, 2812315, 7562⟩ : Conv.Cnt).ja) = true
kernel_rfl PRE_first_tail_x15_r0_body.fhnd175 : (PTrie.keysA PRE_first_tail_x15_r0_body.kd175.hnd).all (Nat.ble (⟨21650, 18762, 2812315, 7562⟩ : Conv.Cnt).xn) = true
kernel_rfl PRE_first_tail_x15_r0_body.fnode175 : (PTrie.keysA PRE_first_tail_x15_r0_body.kd175.node).all (Nat.ble (⟨21650, 18762, 2812315, 7562⟩ : Conv.Cnt).nn) = true
/-- The compaction map fixes the call's names. -/
theorem PRE_first_tail_x15_r0_body.cfix175 : Conv.FixOld (⟨21650, 18762, 2812315, 7562⟩ : Conv.Cnt) PRE_first_tail_x15_r0_body.kappa175 :=
  Conv.fixOld_compact (Nat.le_of_ble_eq_true PRE_first_tail_x15_r0_body.fja175) (Nat.le_of_ble_eq_true PRE_first_tail_x15_r0_body.fn175) (Nat.le_of_ble_eq_true PRE_first_tail_x15_r0_body.fjaD175) (Nat.le_of_ble_eq_true PRE_first_tail_x15_r0_body.fxn175) (Nat.le_of_ble_eq_true PRE_first_tail_x15_r0_body.fnn175) (Nat.le_of_ble_eq_true PRE_first_tail_x15_r0_body.fxb175) PRE_first_tail_x15_r0_body.fheap175 PRE_first_tail_x15_r0_body.fhnd175 PRE_first_tail_x15_r0_body.fnode175
kernel_rfl PRE_first_tail_x15_r0_body.fcxn175 : (⟨21650, 18762, 2812315, 7562⟩ : Conv.Cnt).xn = (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1545.ffi).mlx.next
kernel_rfl PRE_first_tail_x15_r0_body.fcnn175 : (⟨21650, 18762, 2812315, 7562⟩ : Conv.Cnt).nn = (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1545.ffi).mlx.nnext
kernel_rfl PRE_first_tail_x15_r0_body.fle0175 : (Nat.ble (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1545.ffi).mlx.next PRE_first_tail_x15_r0_body.cx0_175.mlx.next && Nat.ble (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1545.ffi).mlx.nnext PRE_first_tail_x15_r0_body.cx0_175.mlx.nnext && Nat.ble (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1545.ffi).mlx.next RData.bigHi) = true
kernel_rfl PRE_first_tail_x15_r0_body.fnk175 : (PTrie.keysA PRE_first_tail_x15_r0_body.kd175.node).all (Nat.ble (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1545.ffi).mlx.nnext) = true
-- the merged state keeps the call's entries off the stage's footprint
kernel_rfl PRE_first_tail_x15_r0_body.f1A175 : PRE_first_tail_x15_r0_body.cx1_175.mlx.arrs = Stage.setAll (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1545.ffi).mlx.arrs (PRE_first_tail_x15_r0_body.cwS175.filterMap fun i => (PRE_first_tail_x15_r0_body.cx1_175.mlx.arrs.get i).map (i, ·))
kernel_rfl PRE_first_tail_x15_r0_body.f1O175 : PRE_first_tail_x15_r0_body.cx1_175.mlx.objs = Stage.setAll (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1545.ffi).mlx.objs (PRE_first_tail_x15_r0_body.cwS175.filterMap fun i => (PRE_first_tail_x15_r0_body.cx1_175.mlx.objs.get i).map (i, ·))
kernel_rfl PRE_first_tail_x15_r0_body.f1N175 : PRE_first_tail_x15_r0_body.cx1_175.mlx.nodes = Stage.setAll (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1545.ffi).mlx.nodes (PRE_first_tail_x15_r0_body.cnS175.filterMap fun i => (PRE_first_tail_x15_r0_body.cx1_175.mlx.nodes.get i).map (i, ·))
kernel_rfl PRE_first_tail_x15_r0_body.f1I175 : PRE_first_tail_x15_r0_body.cx1_175.mlx.items = Stage.setAll (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1545.ffi).mlx.items (PRE_first_tail_x15_r0_body.ciS175.filterMap fun i => (PRE_first_tail_x15_r0_body.cx1_175.mlx.items.get i).map (i, ·))
kernel_rfl PRE_first_tail_x15_r0_body.fbd175 : (PRE_first_tail_x15_r0_body.clo175 ++ PRE_first_tail_x15_r0_body.cln175 ++ PRE_first_tail_x15_r0_body.cli175 ++ PRE_first_tail_x15_r0_body.cwS175 ++ PRE_first_tail_x15_r0_body.cnS175 ++ PRE_first_tail_x15_r0_body.ciS175).all (fun i => Nat.blt (i / 4096) (4 ^ 31)) = true
kernel_rfl PRE_first_tail_x15_r0_body.fincW175 : PRE_first_tail_x15_r0_body.cwS175.all (fun h => !Nat.blt h (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1545.ffi).mlx.next || PRE_first_tail_x15_r0_body.clo175.contains h) = true
kernel_rfl PRE_first_tail_x15_r0_body.fincI175 : PRE_first_tail_x15_r0_body.ciS175.all (fun k => !Nat.blt k (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1545.ffi).mlx.nnext || PRE_first_tail_x15_r0_body.cli175.contains k) = true
kernel_rfl PRE_first_tail_x15_r0_body.fincN175 : PRE_first_tail_x15_r0_body.cnS175.all (Nat.ble (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1545.ffi).mlx.nnext) = true
kernel_rfl PRE_first_tail_x15_r0_body.flnF175 : PRE_first_tail_x15_r0_body.cln175.all (Nat.ble (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1545.ffi).mlx.nnext) = true
-- the checks over the changed lists
kernel_rfl PRE_first_tail_x15_r0_body.fh175 : PRE_first_tail_x15_r0_body.clo175.all (handleOK PRE_first_tail_x15_r0_body.kappa175 PRE_first_tail_x15_r0_body.P175.lo PRE_first_tail_x15_r0_body.cx0_175.mlx PRE_first_tail_x15_r0_body.cx1_175.mlx) = true
kernel_rfl PRE_first_tail_x15_r0_body.fo175 : PRE_first_tail_x15_r0_body.clo175.map (fun h => PRE_first_tail_x15_r0_body.cx1_175.mlx.objs.get (PRE_first_tail_x15_r0_body.kappa175.handle h)) = PRE_first_tail_x15_r0_body.clo175.map (fun h => (PRE_first_tail_x15_r0_body.cx0_175.mlx.objs.get h).map PRE_first_tail_x15_r0_body.kappa175.nobj)
kernel_rfl PRE_first_tail_x15_r0_body.fok175 : PRE_first_tail_x15_r0_body.clo175.all (objOK PRE_first_tail_x15_r0_body.kappa175 PRE_first_tail_x15_r0_body.P175.NL PRE_first_tail_x15_r0_body.cx0_175.mlx) = true
kernel_rfl PRE_first_tail_x15_r0_body.fnd175 : PRE_first_tail_x15_r0_body.cln175.all (nodeOKF PRE_first_tail_x15_r0_body.kappa175 PRE_first_tail_x15_r0_body.P175 PRE_first_tail_x15_r0_body.cx0_175.mlx PRE_first_tail_x15_r0_body.cx1_175.mlx) = true
kernel_rfl PRE_first_tail_x15_r0_body.fp175 : ((PRE_first_tail_x15_r0_body.cln175.filter (fullB PRE_first_tail_x15_r0_body.P175))).map (fun i => (PRE_first_tail_x15_r0_body.cx1_175.mlx.nodes.get (PRE_first_tail_x15_r0_body.kappa175.node i)).map Host.Mlx.Ffi.Node.prim) =
  ((PRE_first_tail_x15_r0_body.cln175.filter (fullB PRE_first_tail_x15_r0_body.P175))).map (fun i => (PRE_first_tail_x15_r0_body.cx0_175.mlx.nodes.get i).map fun nd => PRE_first_tail_x15_r0_body.kappa175.prim nd.prim)
kernel_rfl PRE_first_tail_x15_r0_body.fnordI175 : incrB PRE_first_tail_x15_r0_body.kd175.nodeF (List.range' 18762 0) = true
kernel_rfl PRE_first_tail_x15_r0_body.fnordK175 : (PTrie.keysA PRE_first_tail_x15_r0_body.kd175.node).all (fun k => Nat.ble 18762 k && Nat.blt k 18762) = true
kernel_rfl PRE_first_tail_x15_r0_body.fnordL175 : (PRE_first_tail_x15_r0_body.cln175.filter (Nat.ble PRE_first_tail_x15_r0_body.P175.N0)).all (fun i => Nat.ble i (PRE_first_tail_x15_r0_body.kd175.nodeF i) && (Nat.blt i 18762 || Nat.ble PRE_first_tail_x15_r0_body.kd175.nn0 i)) = true
theorem PRE_first_tail_x15_r0_body.fnord175 : (PRE_first_tail_x15_r0_body.cln175.filter (Nat.ble PRE_first_tail_x15_r0_body.P175.N0)).all (fun i => Nat.ble i (PRE_first_tail_x15_r0_body.kd175.nodeF i) &&
    (PTrie.keysA PRE_first_tail_x15_r0_body.kd175.node).all fun j => !Nat.blt j i || Nat.blt (PRE_first_tail_x15_r0_body.kd175.nodeF j) (PRE_first_tail_x15_r0_body.kd175.nodeF i)) = true :=
  cnord_of PRE_first_tail_x15_r0_body.cnlow175 PRE_first_tail_x15_r0_body.cnn1175 PRE_first_tail_x15_r0_body.fnordI175 PRE_first_tail_x15_r0_body.fnordK175 PRE_first_tail_x15_r0_body.fnordL175
kernel_rfl PRE_first_tail_x15_r0_body.fi175 : PRE_first_tail_x15_r0_body.cli175.all (pnB PRE_first_tail_x15_r0_body.cx0_175.mlx) = true
kernel_rfl PRE_first_tail_x15_r0_body.fii175 : PRE_first_tail_x15_r0_body.cli175.all (fun k => decide (PRE_first_tail_x15_r0_body.cx1_175.mlx.items.get (PRE_first_tail_x15_r0_body.kappa175.node k) = (PRE_first_tail_x15_r0_body.cx0_175.mlx.items.get k).map PRE_first_tail_x15_r0_body.kappa175.nv)) = true
/-- **The compaction's footprint.** -/
theorem PRE_first_tail_x15_r0_body.cfoot175 (clean : Conv.NClean (⟨21650, 18762, 2812315, 7562⟩ : Conv.Cnt) (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1545.ffi).mlx) (hltC : ∀ h, PH (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1545.ffi).mlx h → h < (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1545.ffi).mlx.next) (nltC : ∀ i, PN (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1545.ffi).mlx i → i < (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1545.ffi).mlx.nnext) (itemsC : ∀ k v, (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1545.ffi).mlx.items.get k = some v → PN (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1545.ffi).mlx k) (tracedC : ∀ h o, (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1545.ffi).mlx.objs.get h = some o → ∀ i ∈ objTraces o, i < PRE_first_tail_x15_r0_body.P175.NL) (cl : SSt (· < 7562) PRE_first_tail_x15_r0_body.cx0_175.mlx) :
    Conv.MFoot PRE_first_tail_x15_r0_body.P175 7562 PRE_first_tail_x15_r0_body.kappa175 PRE_first_tail_x15_r0_body.kd175 PRE_first_tail_x15_r0_body.khinv175 PRE_first_tail_x15_r0_body.kninv175 (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1545.ffi).mlx PRE_first_tail_x15_r0_body.cx0_175.mlx PRE_first_tail_x15_r0_body.cx1_175.mlx (⟨21650, 18762, 2812315, 7562⟩ : Conv.Cnt) PRE_first_tail_x15_r0_body.clo175 PRE_first_tail_x15_r0_body.cln175 PRE_first_tail_x15_r0_body.cli175 PRE_first_tail_x15_r0_body.cwS175 PRE_first_tail_x15_r0_body.cnS175 PRE_first_tail_x15_r0_body.ciS175 :=
  ⟨rfl, rfl, rfl, PRE_first_tail_x15_r0_body.cnh0175, PRE_first_tail_x15_r0_body.cnh1175, PRE_first_tail_x15_r0_body.cnn0175, PRE_first_tail_x15_r0_body.cnn1175, PRE_first_tail_x15_r0_body.cplo175, PRE_first_tail_x15_r0_body.ccnt175, PRE_first_tail_x15_r0_body.cnband175, PRE_first_tail_x15_r0_body.chbelow175, PRE_first_tail_x15_r0_body.chren175, PRE_first_tail_x15_r0_body.cband175, PRE_first_tail_x15_r0_body.cnh1pos175, PRE_first_tail_x15_r0_body.cnren175, PRE_first_tail_x15_r0_body.cnlow175, PRE_first_tail_x15_r0_body.cabs0a175, PRE_first_tail_x15_r0_body.cabs0b175, PRE_first_tail_x15_r0_body.ctok1175, PRE_first_tail_x15_r0_body.cpend175, PRE_first_tail_x15_r0_body.cerrh175, PRE_first_tail_x15_r0_body.cfiles175, PRE_first_tail_x15_r0_body.carch175, PRE_first_tail_x15_r0_body.csizes175, PRE_first_tail_x15_r0_body.cwired175, PRE_first_tail_x15_r0_body.cfix175, clean, PRE_first_tail_x15_r0_body.fcxn175, PRE_first_tail_x15_r0_body.fcnn175, hltC, nltC, itemsC, tracedC, cl, PRE_first_tail_x15_r0_body.fle0175, PRE_first_tail_x15_r0_body.fnk175, PRE_first_tail_x15_r0_body.ckA175, PRE_first_tail_x15_r0_body.cobjsK175, PRE_first_tail_x15_r0_body.cnodesK175, PRE_first_tail_x15_r0_body.citemsK175, PRE_first_tail_x15_r0_body.f1A175, PRE_first_tail_x15_r0_body.f1O175, PRE_first_tail_x15_r0_body.f1N175, PRE_first_tail_x15_r0_body.f1I175, PRE_first_tail_x15_r0_body.fbd175, PRE_first_tail_x15_r0_body.fincW175, PRE_first_tail_x15_r0_body.fincI175, PRE_first_tail_x15_r0_body.fincN175, PRE_first_tail_x15_r0_body.flnF175, PRE_first_tail_x15_r0_body.fh175, PRE_first_tail_x15_r0_body.fo175, PRE_first_tail_x15_r0_body.fok175, PRE_first_tail_x15_r0_body.fnd175, PRE_first_tail_x15_r0_body.fp175, PRE_first_tail_x15_r0_body.fnord175, PRE_first_tail_x15_r0_body.fi175, PRE_first_tail_x15_r0_body.fii175⟩
theorem PRE_first_tail_x15_r0_body.cnshift175 (clean : Conv.NClean (⟨21650, 18762, 2812315, 7562⟩ : Conv.Cnt) (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1545.ffi).mlx) (hltC : ∀ h, PH (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1545.ffi).mlx h → h < (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1545.ffi).mlx.next) (nltC : ∀ i, PN (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1545.ffi).mlx i → i < (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1545.ffi).mlx.nnext) (itemsC : ∀ k v, (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1545.ffi).mlx.items.get k = some v → PN (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1545.ffi).mlx k) (tracedC : ∀ h o, (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1545.ffi).mlx.objs.get h = some o → ∀ i ∈ objTraces o, i < PRE_first_tail_x15_r0_body.P175.NL) (cl : SSt (· < 7562) PRE_first_tail_x15_r0_body.cx0_175.mlx) : NShift PRE_first_tail_x15_r0_body.P175 7562 PRE_first_tail_x15_r0_body.kappa175 PRE_first_tail_x15_r0_body.cx0_175 PRE_first_tail_x15_r0_body.cx1_175 :=
  Conv.nshift_of_foot (PRE_first_tail_x15_r0_body.cfoot175 clean hltC nltC itemsC tracedC cl) PRE_first_tail_x15_r0_body.chost175 (compact_a_eq PRE_first_tail_x15_r0_body.ckn0175 PRE_first_tail_x15_r0_body.ckn1175 PRE_first_tail_x15_r0_body.ckheap175 PRE_first_tail_x15_r0_body.ckpl175)

-- the observers: the layers' states at the call, the canonical and the merged state, their footprints and checks
noncomputable def PRE_first_tail_x15_r0_body.fxC_175 : PTrie Unit := (Host.Ts.Sim.Full.freedOf PRE_first_tail_x15_r0_body.s1545.ffi).getD PTrie.nil
noncomputable def PRE_first_tail_x15_r0_body.krC_175 : Host.Load.Layers.KRec := (Host.Ts.Sim.Full.krecOf PRE_first_tail_x15_r0_body.s1545.ffi).getD Host.Load.Layers.KRec.empty
kernel_rfl PRE_first_tail_x15_r0_body.ofxC_175 : (Host.Ts.Sim.Full.freedOf PRE_first_tail_x15_r0_body.s1545.ffi) = some PRE_first_tail_x15_r0_body.fxC_175
kernel_rfl PRE_first_tail_x15_r0_body.okrC_175 : (Host.Ts.Sim.Full.krecOf PRE_first_tail_x15_r0_body.s1545.ffi) = some PRE_first_tail_x15_r0_body.krC_175
noncomputable def PRE_first_tail_x15_r0_body.fx0_175 : PTrie Unit := (Host.Ts.Sim.Full.freedOf PRE_first_tail_x15_r0_body.s1547.ffi).getD PTrie.nil
noncomputable def PRE_first_tail_x15_r0_body.kr0_175 : Host.Load.Layers.KRec := (Host.Ts.Sim.Full.krecOf PRE_first_tail_x15_r0_body.s1547.ffi).getD Host.Load.Layers.KRec.empty
kernel_rfl PRE_first_tail_x15_r0_body.ofx0_175 : (Host.Ts.Sim.Full.freedOf PRE_first_tail_x15_r0_body.s1547.ffi) = some PRE_first_tail_x15_r0_body.fx0_175
kernel_rfl PRE_first_tail_x15_r0_body.okr0_175 : (Host.Ts.Sim.Full.krecOf PRE_first_tail_x15_r0_body.s1547.ffi) = some PRE_first_tail_x15_r0_body.kr0_175
noncomputable def PRE_first_tail_x15_r0_body.fx1_175 : PTrie Unit := (Host.Ts.Sim.Full.freedOf PRE_first_tail_x15_r0_body.s1546.ffi).getD PTrie.nil
noncomputable def PRE_first_tail_x15_r0_body.kr1_175 : Host.Load.Layers.KRec := (Host.Ts.Sim.Full.krecOf PRE_first_tail_x15_r0_body.s1546.ffi).getD Host.Load.Layers.KRec.empty
kernel_rfl PRE_first_tail_x15_r0_body.ofx1_175 : (Host.Ts.Sim.Full.freedOf PRE_first_tail_x15_r0_body.s1546.ffi) = some PRE_first_tail_x15_r0_body.fx1_175
kernel_rfl PRE_first_tail_x15_r0_body.okr1_175 : (Host.Ts.Sim.Full.krecOf PRE_first_tail_x15_r0_body.s1546.ffi) = some PRE_first_tail_x15_r0_body.kr1_175
kernel_rfl PRE_first_tail_x15_r0_body.ff0175 : PRE_first_tail_x15_r0_body.fx0_175 = Stage.setAll PRE_first_tail_x15_r0_body.fxC_175 (PRE_first_tail_x15_r0_body.clo175.filterMap fun i => (PRE_first_tail_x15_r0_body.fx0_175.get i).map (i, ·))
kernel_rfl PRE_first_tail_x15_r0_body.ff1175 : PRE_first_tail_x15_r0_body.fx1_175 = Stage.setAll PRE_first_tail_x15_r0_body.fxC_175 (PRE_first_tail_x15_r0_body.cwS175.filterMap fun i => (PRE_first_tail_x15_r0_body.fx1_175.get i).map (i, ·))
kernel_rfl PRE_first_tail_x15_r0_body.ffck175 : freedLB PRE_first_tail_x15_r0_body.kappa175 PRE_first_tail_x15_r0_body.cx0_175.mlx PRE_first_tail_x15_r0_body.fx0_175 PRE_first_tail_x15_r0_body.fx1_175 PRE_first_tail_x15_r0_body.clo175 = true
kernel_rfl PRE_first_tail_x15_r0_body.fkf0175 : PRE_first_tail_x15_r0_body.kr0_175.flags = Stage.setAll PRE_first_tail_x15_r0_body.krC_175.flags (PRE_first_tail_x15_r0_body.clo175.filterMap fun i => (PRE_first_tail_x15_r0_body.kr0_175.flags.get i).map (i, ·))
kernel_rfl PRE_first_tail_x15_r0_body.fkt0175 : PRE_first_tail_x15_r0_body.kr0_175.targs = Stage.setAll PRE_first_tail_x15_r0_body.krC_175.targs (PRE_first_tail_x15_r0_body.clo175.filterMap fun i => (PRE_first_tail_x15_r0_body.kr0_175.targs.get i).map (i, ·))
kernel_rfl PRE_first_tail_x15_r0_body.fkf1175 : PRE_first_tail_x15_r0_body.kr1_175.flags = Stage.setAll PRE_first_tail_x15_r0_body.krC_175.flags (PRE_first_tail_x15_r0_body.cwS175.filterMap fun i => (PRE_first_tail_x15_r0_body.kr1_175.flags.get i).map (i, ·))
kernel_rfl PRE_first_tail_x15_r0_body.fkt1175 : PRE_first_tail_x15_r0_body.kr1_175.targs = Stage.setAll PRE_first_tail_x15_r0_body.krC_175.targs (PRE_first_tail_x15_r0_body.cwS175.filterMap fun i => (PRE_first_tail_x15_r0_body.kr1_175.targs.get i).map (i, ·))
kernel_rfl PRE_first_tail_x15_r0_body.fkck175 : krecLB PRE_first_tail_x15_r0_body.kappa175 7562 PRE_first_tail_x15_r0_body.cx0_175.mlx PRE_first_tail_x15_r0_body.kr0_175 PRE_first_tail_x15_r0_body.kr1_175 PRE_first_tail_x15_r0_body.clo175 = true
kernel_rfl PRE_first_tail_x15_r0_body.fkn175 : Nat.ble 7562 7562 = true
-- the bridge and the pending traces' regions
kernel_rfl PRE_first_tail_x15_r0_body.cbridge175 : Host.Ts.Sim.Full.bridgeOf PRE_first_tail_x15_r0_body.s1546.ffi = Host.Ts.Sim.Full.bridgeOf PRE_first_tail_x15_r0_body.s1547.ffi
kernel_rfl PRE_first_tail_x15_r0_body.cpendR175 : pendRegB PRE_first_tail_x15_r0_body.kappa175 (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1547.ffi).mlx = true
kernel_rfl PRE_first_tail_x15_r0_body.cpendLe175 : Nat.ble (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1547.ffi).mlx.next (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1546.ffi).mlx.next = true
/-- **The compaction's native shift**, given the call's bookkeeping, its relation's facts (the model's and the
observers') and the canonical closedness. -/
theorem PRE_first_tail_x15_r0_body.cshift175 (clean : Conv.NClean (⟨21650, 18762, 2812315, 7562⟩ : Conv.Cnt) (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1545.ffi).mlx) (hltC : ∀ h, PH (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1545.ffi).mlx h → h < (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1545.ffi).mlx.next) (nltC : ∀ i, PN (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1545.ffi).mlx i → i < (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1545.ffi).mlx.nnext) (itemsC : ∀ k v, (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1545.ffi).mlx.items.get k = some v → PN (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1545.ffi).mlx k) (tracedC : ∀ h o, (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1545.ffi).mlx.objs.get h = some o → ∀ i ∈ objTraces o, i < PRE_first_tail_x15_r0_body.P175.NL) (cl : SSt (· < 7562) PRE_first_tail_x15_r0_body.cx0_175.mlx)
    (hobjC : ∀ h, PRE_first_tail_x15_r0_body.fxC_175.get h = some () → ((Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1545.ffi).mlx.objs.get h).isSome = true)
    (hfC : ∀ h, (PRE_first_tail_x15_r0_body.krC_175.flags.get h).isSome = true → ((Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1545.ffi).mlx.objs.get h).isSome = true)
    (htC : ∀ h, (PRE_first_tail_x15_r0_body.krC_175.targs.get h).isSome = true → ((Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1545.ffi).mlx.objs.get h).isSome = true)
    (hclC : ∀ h l, PRE_first_tail_x15_r0_body.krC_175.targs.get h = some l → Host.Ts.Sim.Full.STargs (· < (⟨21650, 18762, 2812315, 7562⟩ : Conv.Cnt).n) l) :
    Conv.FullShiftQ PRE_first_tail_x15_r0_body.P175 7562 PRE_first_tail_x15_r0_body.kappa175 PRE_first_tail_x15_r0_body.s1547.ffi PRE_first_tail_x15_r0_body.s1546.ffi :=
  ⟨PRE_first_tail_x15_r0_body.cnshift175 clean hltC nltC itemsC tracedC cl, PRE_first_tail_x15_r0_body.cqueue175, fun t ht => bSN_sound (List.all_eq_true.mp PRE_first_tail_x15_r0_body.ctokSupp175 t ht),
    PRE_first_tail_x15_r0_body.cbridge175,
    liveShift_foot (x0' := Host.Ts.Sim.Full.mlxOf PRE_first_tail_x15_r0_body.s1547.ffi) (x1' := Host.Ts.Sim.Full.mlxOf PRE_first_tail_x15_r0_body.s1546.ffi) (PRE_first_tail_x15_r0_body.cfoot175 clean hltC nltC itemsC tracedC cl) rfl PRE_first_tail_x15_r0_body.ofx0_175 PRE_first_tail_x15_r0_body.ofx1_175 hobjC PRE_first_tail_x15_r0_body.ff0175 PRE_first_tail_x15_r0_body.ff1175 PRE_first_tail_x15_r0_body.ffck175,
    kernShift_foot (x0' := Host.Ts.Sim.Full.mlxOf PRE_first_tail_x15_r0_body.s1547.ffi) (x1' := Host.Ts.Sim.Full.mlxOf PRE_first_tail_x15_r0_body.s1546.ffi) (PRE_first_tail_x15_r0_body.cfoot175 clean hltC nltC itemsC tracedC cl) rfl PRE_first_tail_x15_r0_body.okr0_175 PRE_first_tail_x15_r0_body.okr1_175 (Nat.le_of_ble_eq_true PRE_first_tail_x15_r0_body.fkn175) hfC htC hclC
      PRE_first_tail_x15_r0_body.fkf0175 PRE_first_tail_x15_r0_body.fkt0175 PRE_first_tail_x15_r0_body.fkf1175 PRE_first_tail_x15_r0_body.fkt1175 PRE_first_tail_x15_r0_body.fkck175,
    pendReg_of rfl PRE_first_tail_x15_r0_body.cnh0175 PRE_first_tail_x15_r0_body.cnh1175 (Nat.le_of_ble_eq_true PRE_first_tail_x15_r0_body.cpendLe175) PRE_first_tail_x15_r0_body.cpendR175⟩

end Host.Load.Run.Tpl
