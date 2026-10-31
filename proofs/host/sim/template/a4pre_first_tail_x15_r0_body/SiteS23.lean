import host.sim.template.a4pre_first_tail_x15_r0_body.SiteCl23
import host.sim.conv.CompactFull
import host.sim.template.FootGen
set_option Elab.async false
namespace Host.Load.Run.Tpl
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
open Host.Ts Host.Ts.Sim Host.Ts.Sim.Template

/-! The compaction's native shift at call site 23 from its footprint (`Conv.nshift_of_foot`), and the observers'
(`liveShift_foot`, `kernShift_foot`): `Conv.FullShiftQ` for `Conv.full_compactQ`, given the call's bookkeeping and its
relation's facts. -/

/-- The load parameters of the chain (band-free: its start's node counter as `NL` and `N0`). -/
def PRE_first_tail_x15_r0_body.Pc23 : LoadP := ⟨18151, 131072, 1099511627776, 15235, 15235, []⟩
/-- The site's band raised to the map's checked fixed-node prefix, including newly recorded closure traces. -/
def PRE_first_tail_x15_r0_body.P23 : LoadP := PRE_first_tail_x15_r0_body.Pc23.raise 15733
kernel_rfl PRE_first_tail_x15_r0_body.craise23 : Nat.ble PRE_first_tail_x15_r0_body.Pc23.N0 15733 = true
theorem PRE_first_tail_x15_r0_body.raised23 : Host.Ts.Sim.Full.Raised PRE_first_tail_x15_r0_body.Pc23 PRE_first_tail_x15_r0_body.P23 :=
  .inr ⟨15733, rfl, Nat.le_of_ble_eq_true PRE_first_tail_x15_r0_body.craise23, rfl⟩
noncomputable abbrev PRE_first_tail_x15_r0_body.cx0_23 : Host.Load.LSt := clearTokens (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s210.ffi)
noncomputable abbrev PRE_first_tail_x15_r0_body.cx1_23 : Host.Load.LSt := clearTokens (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s209.ffi)
def PRE_first_tail_x15_r0_body.khinv23 : PTrie Nat := Stage.setAll PTrie.nil []
def PRE_first_tail_x15_r0_body.kninv23 : PTrie Nat := Stage.setAll PTrie.nil []
/-- The stage's footprint: its written and fresh handles, fresh nodes, written and fresh items. -/
def PRE_first_tail_x15_r0_body.cwS23 : List Nat := []
def PRE_first_tail_x15_r0_body.cnS23 : List Nat := List.range' 15733 0
def PRE_first_tail_x15_r0_body.ciS23 : List Nat := [] ++ List.range' 15733 0

-- the small checks (`MChecks`'s)
kernel_rfl PRE_first_tail_x15_r0_body.cnh023 : PRE_first_tail_x15_r0_body.kd23.nh0 = PRE_first_tail_x15_r0_body.cx0_23.mlx.next
kernel_rfl PRE_first_tail_x15_r0_body.cnh123 : PRE_first_tail_x15_r0_body.kd23.nh1 = PRE_first_tail_x15_r0_body.cx1_23.mlx.next
kernel_rfl PRE_first_tail_x15_r0_body.cnn023 : PRE_first_tail_x15_r0_body.kd23.nn0 = PRE_first_tail_x15_r0_body.cx0_23.mlx.nnext
kernel_rfl PRE_first_tail_x15_r0_body.cnn123 : PRE_first_tail_x15_r0_body.kd23.nn1 = PRE_first_tail_x15_r0_body.cx1_23.mlx.nnext
kernel_rfl PRE_first_tail_x15_r0_body.cplo23 : (Nat.blt 0 PRE_first_tail_x15_r0_body.P23.lo && Nat.ble PRE_first_tail_x15_r0_body.P23.lo PRE_first_tail_x15_r0_body.cx0_23.mlx.next && Nat.ble PRE_first_tail_x15_r0_body.P23.lo RData.bigHi && Nat.ble RData.bigHi PRE_first_tail_x15_r0_body.P23.E) = true
kernel_rfl PRE_first_tail_x15_r0_body.ccnt23 : (Nat.ble PRE_first_tail_x15_r0_body.cx0_23.mlx.next PRE_first_tail_x15_r0_body.cx1_23.mlx.next && Nat.ble PRE_first_tail_x15_r0_body.cx0_23.mlx.nnext PRE_first_tail_x15_r0_body.cx1_23.mlx.nnext) = true
kernel_rfl PRE_first_tail_x15_r0_body.cnband23 : (Nat.blt 0 PRE_first_tail_x15_r0_body.P23.NL && Nat.ble PRE_first_tail_x15_r0_body.P23.NL PRE_first_tail_x15_r0_body.P23.N0 && Nat.ble PRE_first_tail_x15_r0_body.P23.N0 PRE_first_tail_x15_r0_body.cx0_23.mlx.nnext) = true
kernel_rfl PRE_first_tail_x15_r0_body.chbelow23 : PRE_first_tail_x15_r0_body.kd23.checkHndBelow = true
kernel_rfl PRE_first_tail_x15_r0_body.chren23 : checkRenG PRE_first_tail_x15_r0_body.kd23.hnd PRE_first_tail_x15_r0_body.khinv23 (phB PRE_first_tail_x15_r0_body.cx0_23.mlx) = true
kernel_rfl PRE_first_tail_x15_r0_body.cband23 : PRE_first_tail_x15_r0_body.kd23.checkBand PRE_first_tail_x15_r0_body.P23.lo = true
kernel_rfl PRE_first_tail_x15_r0_body.cnh1pos23 : Nat.blt 0 PRE_first_tail_x15_r0_body.kd23.nh1 = true
kernel_rfl PRE_first_tail_x15_r0_body.cnren23 : checkRenG PRE_first_tail_x15_r0_body.kd23.node PRE_first_tail_x15_r0_body.kninv23 (pnB PRE_first_tail_x15_r0_body.cx0_23.mlx) = true
kernel_rfl PRE_first_tail_x15_r0_body.cnlow23 : (PTrie.keysA PRE_first_tail_x15_r0_body.kd23.node).all (fun j => Nat.ble PRE_first_tail_x15_r0_body.P23.NL j && Nat.blt (PRE_first_tail_x15_r0_body.kd23.nodeF j) PRE_first_tail_x15_r0_body.cx1_23.mlx.nnext) = true
kernel_rfl PRE_first_tail_x15_r0_body.cabs0a23 : PRE_first_tail_x15_r0_body.cx0_23.mlx.arrs.get 0 = none
kernel_rfl PRE_first_tail_x15_r0_body.cabs0b23 : PRE_first_tail_x15_r0_body.cx0_23.mlx.objs.get 0 = none
kernel_rfl PRE_first_tail_x15_r0_body.ctok123 : PRE_first_tail_x15_r0_body.cx1_23.mlx.tokens = []
kernel_rfl PRE_first_tail_x15_r0_body.cpend23 : PRE_first_tail_x15_r0_body.cx1_23.mlx.pending = PRE_first_tail_x15_r0_body.cx0_23.mlx.pending.map PRE_first_tail_x15_r0_body.kappa23.pend
kernel_rfl PRE_first_tail_x15_r0_body.cerrh23 : PRE_first_tail_x15_r0_body.cx1_23.mlx.errh = PRE_first_tail_x15_r0_body.cx0_23.mlx.errh.map PRE_first_tail_x15_r0_body.kappa23.arg
kernel_rfl PRE_first_tail_x15_r0_body.cfiles23 : PRE_first_tail_x15_r0_body.cx1_23.mlx.files = PRE_first_tail_x15_r0_body.cx0_23.mlx.files
kernel_rfl PRE_first_tail_x15_r0_body.carch23 : PRE_first_tail_x15_r0_body.cx1_23.mlx.arch = PRE_first_tail_x15_r0_body.cx0_23.mlx.arch
kernel_rfl PRE_first_tail_x15_r0_body.csizes23 : PRE_first_tail_x15_r0_body.cx1_23.mlx.deviceSizes = PRE_first_tail_x15_r0_body.cx0_23.mlx.deviceSizes
kernel_rfl PRE_first_tail_x15_r0_body.cwired23 : PRE_first_tail_x15_r0_body.cx1_23.mlx.wired = PRE_first_tail_x15_r0_body.cx0_23.mlx.wired
kernel_rfl PRE_first_tail_x15_r0_body.chost23 : PRE_first_tail_x15_r0_body.cx1_23.host = PRE_first_tail_x15_r0_body.cx0_23.host
-- the compaction map's addresses are `PRE_first_tail_x15_r0_body.kd23`'s
kernel_rfl PRE_first_tail_x15_r0_body.ckn023 : PRE_first_tail_x15_r0_body.kd23.n0 = 2692794
kernel_rfl PRE_first_tail_x15_r0_body.ckn123 : PRE_first_tail_x15_r0_body.kd23.n1 = 2692804
kernel_rfl PRE_first_tail_x15_r0_body.ckheap23 : (PTrie.keysA PRE_first_tail_x15_r0_body.kd23.heap).all (fun x => Nat.ble 2692793 x) = true
kernel_rfl PRE_first_tail_x15_r0_body.ckpl23 : (List.range 1).all (fun j => decide (PRE_first_tail_x15_r0_body.kd23.heap.get (2692793 + j) = nth? PRE_first_tail_x15_r0_body.pl23 j)) = true
-- the map fixes the call's names (`Conv.fixOld_compact`), the call's counters
kernel_rfl PRE_first_tail_x15_r0_body.fja23 : Nat.ble 2692793 2692793 = true
kernel_rfl PRE_first_tail_x15_r0_body.fn23 : Nat.ble 1036 1036 = true
kernel_rfl PRE_first_tail_x15_r0_body.fjaD23 : Nat.ble 2692793 PRE_first_tail_x15_r0_body.kd23.n0 = true
kernel_rfl PRE_first_tail_x15_r0_body.fxn23 : Nat.ble 18653 PRE_first_tail_x15_r0_body.kd23.nh0 = true
kernel_rfl PRE_first_tail_x15_r0_body.fnn23 : Nat.ble 15733 PRE_first_tail_x15_r0_body.kd23.nn0 = true
kernel_rfl PRE_first_tail_x15_r0_body.fxb23 : Nat.ble 18653 RData.bigHi = true
kernel_rfl PRE_first_tail_x15_r0_body.fheap23 : (PTrie.keysA PRE_first_tail_x15_r0_body.kd23.heap).all (Nat.ble (⟨18653, 15733, 2692793, 1036⟩ : Conv.Cnt).ja) = true
kernel_rfl PRE_first_tail_x15_r0_body.fhnd23 : (PTrie.keysA PRE_first_tail_x15_r0_body.kd23.hnd).all (Nat.ble (⟨18653, 15733, 2692793, 1036⟩ : Conv.Cnt).xn) = true
kernel_rfl PRE_first_tail_x15_r0_body.fnode23 : (PTrie.keysA PRE_first_tail_x15_r0_body.kd23.node).all (Nat.ble (⟨18653, 15733, 2692793, 1036⟩ : Conv.Cnt).nn) = true
/-- The compaction map fixes the call's names. -/
theorem PRE_first_tail_x15_r0_body.cfix23 : Conv.FixOld (⟨18653, 15733, 2692793, 1036⟩ : Conv.Cnt) PRE_first_tail_x15_r0_body.kappa23 :=
  Conv.fixOld_compact (Nat.le_of_ble_eq_true PRE_first_tail_x15_r0_body.fja23) (Nat.le_of_ble_eq_true PRE_first_tail_x15_r0_body.fn23) (Nat.le_of_ble_eq_true PRE_first_tail_x15_r0_body.fjaD23) (Nat.le_of_ble_eq_true PRE_first_tail_x15_r0_body.fxn23) (Nat.le_of_ble_eq_true PRE_first_tail_x15_r0_body.fnn23) (Nat.le_of_ble_eq_true PRE_first_tail_x15_r0_body.fxb23) PRE_first_tail_x15_r0_body.fheap23 PRE_first_tail_x15_r0_body.fhnd23 PRE_first_tail_x15_r0_body.fnode23
kernel_rfl PRE_first_tail_x15_r0_body.fcxn23 : (⟨18653, 15733, 2692793, 1036⟩ : Conv.Cnt).xn = (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s208.ffi).mlx.next
kernel_rfl PRE_first_tail_x15_r0_body.fcnn23 : (⟨18653, 15733, 2692793, 1036⟩ : Conv.Cnt).nn = (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s208.ffi).mlx.nnext
kernel_rfl PRE_first_tail_x15_r0_body.fle023 : (Nat.ble (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s208.ffi).mlx.next PRE_first_tail_x15_r0_body.cx0_23.mlx.next && Nat.ble (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s208.ffi).mlx.nnext PRE_first_tail_x15_r0_body.cx0_23.mlx.nnext && Nat.ble (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s208.ffi).mlx.next RData.bigHi) = true
kernel_rfl PRE_first_tail_x15_r0_body.fnk23 : (PTrie.keysA PRE_first_tail_x15_r0_body.kd23.node).all (Nat.ble (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s208.ffi).mlx.nnext) = true
-- the merged state keeps the call's entries off the stage's footprint
kernel_rfl PRE_first_tail_x15_r0_body.f1A23 : PRE_first_tail_x15_r0_body.cx1_23.mlx.arrs = Stage.setAll (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s208.ffi).mlx.arrs (PRE_first_tail_x15_r0_body.cwS23.filterMap fun i => (PRE_first_tail_x15_r0_body.cx1_23.mlx.arrs.get i).map (i, ·))
kernel_rfl PRE_first_tail_x15_r0_body.f1O23 : PRE_first_tail_x15_r0_body.cx1_23.mlx.objs = Stage.setAll (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s208.ffi).mlx.objs (PRE_first_tail_x15_r0_body.cwS23.filterMap fun i => (PRE_first_tail_x15_r0_body.cx1_23.mlx.objs.get i).map (i, ·))
kernel_rfl PRE_first_tail_x15_r0_body.f1N23 : PRE_first_tail_x15_r0_body.cx1_23.mlx.nodes = Stage.setAll (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s208.ffi).mlx.nodes (PRE_first_tail_x15_r0_body.cnS23.filterMap fun i => (PRE_first_tail_x15_r0_body.cx1_23.mlx.nodes.get i).map (i, ·))
kernel_rfl PRE_first_tail_x15_r0_body.f1I23 : PRE_first_tail_x15_r0_body.cx1_23.mlx.items = Stage.setAll (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s208.ffi).mlx.items (PRE_first_tail_x15_r0_body.ciS23.filterMap fun i => (PRE_first_tail_x15_r0_body.cx1_23.mlx.items.get i).map (i, ·))
kernel_rfl PRE_first_tail_x15_r0_body.fbd23 : (PRE_first_tail_x15_r0_body.clo23 ++ PRE_first_tail_x15_r0_body.cln23 ++ PRE_first_tail_x15_r0_body.cli23 ++ PRE_first_tail_x15_r0_body.cwS23 ++ PRE_first_tail_x15_r0_body.cnS23 ++ PRE_first_tail_x15_r0_body.ciS23).all (fun i => Nat.blt (i / 4096) (4 ^ 31)) = true
kernel_rfl PRE_first_tail_x15_r0_body.fincW23 : PRE_first_tail_x15_r0_body.cwS23.all (fun h => !Nat.blt h (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s208.ffi).mlx.next || PRE_first_tail_x15_r0_body.clo23.contains h) = true
kernel_rfl PRE_first_tail_x15_r0_body.fincI23 : PRE_first_tail_x15_r0_body.ciS23.all (fun k => !Nat.blt k (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s208.ffi).mlx.nnext || PRE_first_tail_x15_r0_body.cli23.contains k) = true
kernel_rfl PRE_first_tail_x15_r0_body.fincN23 : PRE_first_tail_x15_r0_body.cnS23.all (Nat.ble (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s208.ffi).mlx.nnext) = true
kernel_rfl PRE_first_tail_x15_r0_body.flnF23 : PRE_first_tail_x15_r0_body.cln23.all (Nat.ble (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s208.ffi).mlx.nnext) = true
-- the checks over the changed lists
kernel_rfl PRE_first_tail_x15_r0_body.fh23 : PRE_first_tail_x15_r0_body.clo23.all (handleOK PRE_first_tail_x15_r0_body.kappa23 PRE_first_tail_x15_r0_body.P23.lo PRE_first_tail_x15_r0_body.cx0_23.mlx PRE_first_tail_x15_r0_body.cx1_23.mlx) = true
kernel_rfl PRE_first_tail_x15_r0_body.fo23 : PRE_first_tail_x15_r0_body.clo23.map (fun h => PRE_first_tail_x15_r0_body.cx1_23.mlx.objs.get (PRE_first_tail_x15_r0_body.kappa23.handle h)) = PRE_first_tail_x15_r0_body.clo23.map (fun h => (PRE_first_tail_x15_r0_body.cx0_23.mlx.objs.get h).map PRE_first_tail_x15_r0_body.kappa23.nobj)
kernel_rfl PRE_first_tail_x15_r0_body.fok23 : PRE_first_tail_x15_r0_body.clo23.all (objOK PRE_first_tail_x15_r0_body.kappa23 PRE_first_tail_x15_r0_body.P23.NL PRE_first_tail_x15_r0_body.cx0_23.mlx) = true
kernel_rfl PRE_first_tail_x15_r0_body.fnd23 : PRE_first_tail_x15_r0_body.cln23.all (nodeOKF PRE_first_tail_x15_r0_body.kappa23 PRE_first_tail_x15_r0_body.P23 PRE_first_tail_x15_r0_body.cx0_23.mlx PRE_first_tail_x15_r0_body.cx1_23.mlx) = true
kernel_rfl PRE_first_tail_x15_r0_body.fp23 : ((PRE_first_tail_x15_r0_body.cln23.filter (fullB PRE_first_tail_x15_r0_body.P23))).map (fun i => (PRE_first_tail_x15_r0_body.cx1_23.mlx.nodes.get (PRE_first_tail_x15_r0_body.kappa23.node i)).map Host.Mlx.Ffi.Node.prim) =
  ((PRE_first_tail_x15_r0_body.cln23.filter (fullB PRE_first_tail_x15_r0_body.P23))).map (fun i => (PRE_first_tail_x15_r0_body.cx0_23.mlx.nodes.get i).map fun nd => PRE_first_tail_x15_r0_body.kappa23.prim nd.prim)
kernel_rfl PRE_first_tail_x15_r0_body.fnordI23 : incrB PRE_first_tail_x15_r0_body.kd23.nodeF (List.range' 15733 0) = true
kernel_rfl PRE_first_tail_x15_r0_body.fnordK23 : (PTrie.keysA PRE_first_tail_x15_r0_body.kd23.node).all (fun k => Nat.ble 15733 k && Nat.blt k 15733) = true
kernel_rfl PRE_first_tail_x15_r0_body.fnordL23 : (PRE_first_tail_x15_r0_body.cln23.filter (Nat.ble PRE_first_tail_x15_r0_body.P23.N0)).all (fun i => Nat.ble i (PRE_first_tail_x15_r0_body.kd23.nodeF i) && (Nat.blt i 15733 || Nat.ble PRE_first_tail_x15_r0_body.kd23.nn0 i)) = true
theorem PRE_first_tail_x15_r0_body.fnord23 : (PRE_first_tail_x15_r0_body.cln23.filter (Nat.ble PRE_first_tail_x15_r0_body.P23.N0)).all (fun i => Nat.ble i (PRE_first_tail_x15_r0_body.kd23.nodeF i) &&
    (PTrie.keysA PRE_first_tail_x15_r0_body.kd23.node).all fun j => !Nat.blt j i || Nat.blt (PRE_first_tail_x15_r0_body.kd23.nodeF j) (PRE_first_tail_x15_r0_body.kd23.nodeF i)) = true :=
  cnord_of PRE_first_tail_x15_r0_body.cnlow23 PRE_first_tail_x15_r0_body.cnn123 PRE_first_tail_x15_r0_body.fnordI23 PRE_first_tail_x15_r0_body.fnordK23 PRE_first_tail_x15_r0_body.fnordL23
kernel_rfl PRE_first_tail_x15_r0_body.fi23 : PRE_first_tail_x15_r0_body.cli23.all (pnB PRE_first_tail_x15_r0_body.cx0_23.mlx) = true
kernel_rfl PRE_first_tail_x15_r0_body.fii23 : PRE_first_tail_x15_r0_body.cli23.all (fun k => decide (PRE_first_tail_x15_r0_body.cx1_23.mlx.items.get (PRE_first_tail_x15_r0_body.kappa23.node k) = (PRE_first_tail_x15_r0_body.cx0_23.mlx.items.get k).map PRE_first_tail_x15_r0_body.kappa23.nv)) = true
/-- **The compaction's footprint.** -/
theorem PRE_first_tail_x15_r0_body.cfoot23 (clean : Conv.NClean (⟨18653, 15733, 2692793, 1036⟩ : Conv.Cnt) (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s208.ffi).mlx) (hltC : ∀ h, PH (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s208.ffi).mlx h → h < (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s208.ffi).mlx.next) (nltC : ∀ i, PN (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s208.ffi).mlx i → i < (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s208.ffi).mlx.nnext) (itemsC : ∀ k v, (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s208.ffi).mlx.items.get k = some v → PN (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s208.ffi).mlx k) (tracedC : ∀ h o, (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s208.ffi).mlx.objs.get h = some o → ∀ i ∈ objTraces o, i < PRE_first_tail_x15_r0_body.P23.NL) (cl : SSt (· < 1036) PRE_first_tail_x15_r0_body.cx0_23.mlx) :
    Conv.MFoot PRE_first_tail_x15_r0_body.P23 1036 PRE_first_tail_x15_r0_body.kappa23 PRE_first_tail_x15_r0_body.kd23 PRE_first_tail_x15_r0_body.khinv23 PRE_first_tail_x15_r0_body.kninv23 (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s208.ffi).mlx PRE_first_tail_x15_r0_body.cx0_23.mlx PRE_first_tail_x15_r0_body.cx1_23.mlx (⟨18653, 15733, 2692793, 1036⟩ : Conv.Cnt) PRE_first_tail_x15_r0_body.clo23 PRE_first_tail_x15_r0_body.cln23 PRE_first_tail_x15_r0_body.cli23 PRE_first_tail_x15_r0_body.cwS23 PRE_first_tail_x15_r0_body.cnS23 PRE_first_tail_x15_r0_body.ciS23 :=
  ⟨rfl, rfl, rfl, PRE_first_tail_x15_r0_body.cnh023, PRE_first_tail_x15_r0_body.cnh123, PRE_first_tail_x15_r0_body.cnn023, PRE_first_tail_x15_r0_body.cnn123, PRE_first_tail_x15_r0_body.cplo23, PRE_first_tail_x15_r0_body.ccnt23, PRE_first_tail_x15_r0_body.cnband23, PRE_first_tail_x15_r0_body.chbelow23, PRE_first_tail_x15_r0_body.chren23, PRE_first_tail_x15_r0_body.cband23, PRE_first_tail_x15_r0_body.cnh1pos23, PRE_first_tail_x15_r0_body.cnren23, PRE_first_tail_x15_r0_body.cnlow23, PRE_first_tail_x15_r0_body.cabs0a23, PRE_first_tail_x15_r0_body.cabs0b23, PRE_first_tail_x15_r0_body.ctok123, PRE_first_tail_x15_r0_body.cpend23, PRE_first_tail_x15_r0_body.cerrh23, PRE_first_tail_x15_r0_body.cfiles23, PRE_first_tail_x15_r0_body.carch23, PRE_first_tail_x15_r0_body.csizes23, PRE_first_tail_x15_r0_body.cwired23, PRE_first_tail_x15_r0_body.cfix23, clean, PRE_first_tail_x15_r0_body.fcxn23, PRE_first_tail_x15_r0_body.fcnn23, hltC, nltC, itemsC, tracedC, cl, PRE_first_tail_x15_r0_body.fle023, PRE_first_tail_x15_r0_body.fnk23, PRE_first_tail_x15_r0_body.ckA23, PRE_first_tail_x15_r0_body.cobjsK23, PRE_first_tail_x15_r0_body.cnodesK23, PRE_first_tail_x15_r0_body.citemsK23, PRE_first_tail_x15_r0_body.f1A23, PRE_first_tail_x15_r0_body.f1O23, PRE_first_tail_x15_r0_body.f1N23, PRE_first_tail_x15_r0_body.f1I23, PRE_first_tail_x15_r0_body.fbd23, PRE_first_tail_x15_r0_body.fincW23, PRE_first_tail_x15_r0_body.fincI23, PRE_first_tail_x15_r0_body.fincN23, PRE_first_tail_x15_r0_body.flnF23, PRE_first_tail_x15_r0_body.fh23, PRE_first_tail_x15_r0_body.fo23, PRE_first_tail_x15_r0_body.fok23, PRE_first_tail_x15_r0_body.fnd23, PRE_first_tail_x15_r0_body.fp23, PRE_first_tail_x15_r0_body.fnord23, PRE_first_tail_x15_r0_body.fi23, PRE_first_tail_x15_r0_body.fii23⟩
theorem PRE_first_tail_x15_r0_body.cnshift23 (clean : Conv.NClean (⟨18653, 15733, 2692793, 1036⟩ : Conv.Cnt) (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s208.ffi).mlx) (hltC : ∀ h, PH (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s208.ffi).mlx h → h < (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s208.ffi).mlx.next) (nltC : ∀ i, PN (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s208.ffi).mlx i → i < (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s208.ffi).mlx.nnext) (itemsC : ∀ k v, (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s208.ffi).mlx.items.get k = some v → PN (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s208.ffi).mlx k) (tracedC : ∀ h o, (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s208.ffi).mlx.objs.get h = some o → ∀ i ∈ objTraces o, i < PRE_first_tail_x15_r0_body.P23.NL) (cl : SSt (· < 1036) PRE_first_tail_x15_r0_body.cx0_23.mlx) : NShift PRE_first_tail_x15_r0_body.P23 1036 PRE_first_tail_x15_r0_body.kappa23 PRE_first_tail_x15_r0_body.cx0_23 PRE_first_tail_x15_r0_body.cx1_23 :=
  Conv.nshift_of_foot (PRE_first_tail_x15_r0_body.cfoot23 clean hltC nltC itemsC tracedC cl) PRE_first_tail_x15_r0_body.chost23 (compact_a_eq PRE_first_tail_x15_r0_body.ckn023 PRE_first_tail_x15_r0_body.ckn123 PRE_first_tail_x15_r0_body.ckheap23 PRE_first_tail_x15_r0_body.ckpl23)

-- the observers: the layers' states at the call, the canonical and the merged state, their footprints and checks
noncomputable def PRE_first_tail_x15_r0_body.fxC_23 : PTrie Unit := (Host.Ts.Sim.Full.freedOf PRE_first_tail_x15_r0_body.s208.ffi).getD PTrie.nil
noncomputable def PRE_first_tail_x15_r0_body.krC_23 : Host.Load.Layers.KRec := (Host.Ts.Sim.Full.krecOf PRE_first_tail_x15_r0_body.s208.ffi).getD Host.Load.Layers.KRec.empty
kernel_rfl PRE_first_tail_x15_r0_body.ofxC_23 : (Host.Ts.Sim.Full.freedOf PRE_first_tail_x15_r0_body.s208.ffi) = some PRE_first_tail_x15_r0_body.fxC_23
kernel_rfl PRE_first_tail_x15_r0_body.okrC_23 : (Host.Ts.Sim.Full.krecOf PRE_first_tail_x15_r0_body.s208.ffi) = some PRE_first_tail_x15_r0_body.krC_23
noncomputable def PRE_first_tail_x15_r0_body.fx0_23 : PTrie Unit := (Host.Ts.Sim.Full.freedOf PRE_first_tail_x15_r0_body.s210.ffi).getD PTrie.nil
noncomputable def PRE_first_tail_x15_r0_body.kr0_23 : Host.Load.Layers.KRec := (Host.Ts.Sim.Full.krecOf PRE_first_tail_x15_r0_body.s210.ffi).getD Host.Load.Layers.KRec.empty
kernel_rfl PRE_first_tail_x15_r0_body.ofx0_23 : (Host.Ts.Sim.Full.freedOf PRE_first_tail_x15_r0_body.s210.ffi) = some PRE_first_tail_x15_r0_body.fx0_23
kernel_rfl PRE_first_tail_x15_r0_body.okr0_23 : (Host.Ts.Sim.Full.krecOf PRE_first_tail_x15_r0_body.s210.ffi) = some PRE_first_tail_x15_r0_body.kr0_23
noncomputable def PRE_first_tail_x15_r0_body.fx1_23 : PTrie Unit := (Host.Ts.Sim.Full.freedOf PRE_first_tail_x15_r0_body.s209.ffi).getD PTrie.nil
noncomputable def PRE_first_tail_x15_r0_body.kr1_23 : Host.Load.Layers.KRec := (Host.Ts.Sim.Full.krecOf PRE_first_tail_x15_r0_body.s209.ffi).getD Host.Load.Layers.KRec.empty
kernel_rfl PRE_first_tail_x15_r0_body.ofx1_23 : (Host.Ts.Sim.Full.freedOf PRE_first_tail_x15_r0_body.s209.ffi) = some PRE_first_tail_x15_r0_body.fx1_23
kernel_rfl PRE_first_tail_x15_r0_body.okr1_23 : (Host.Ts.Sim.Full.krecOf PRE_first_tail_x15_r0_body.s209.ffi) = some PRE_first_tail_x15_r0_body.kr1_23
kernel_rfl PRE_first_tail_x15_r0_body.ff023 : PRE_first_tail_x15_r0_body.fx0_23 = Stage.setAll PRE_first_tail_x15_r0_body.fxC_23 (PRE_first_tail_x15_r0_body.clo23.filterMap fun i => (PRE_first_tail_x15_r0_body.fx0_23.get i).map (i, ·))
kernel_rfl PRE_first_tail_x15_r0_body.ff123 : PRE_first_tail_x15_r0_body.fx1_23 = Stage.setAll PRE_first_tail_x15_r0_body.fxC_23 (PRE_first_tail_x15_r0_body.cwS23.filterMap fun i => (PRE_first_tail_x15_r0_body.fx1_23.get i).map (i, ·))
kernel_rfl PRE_first_tail_x15_r0_body.ffck23 : freedLB PRE_first_tail_x15_r0_body.kappa23 PRE_first_tail_x15_r0_body.cx0_23.mlx PRE_first_tail_x15_r0_body.fx0_23 PRE_first_tail_x15_r0_body.fx1_23 PRE_first_tail_x15_r0_body.clo23 = true
kernel_rfl PRE_first_tail_x15_r0_body.fkf023 : PRE_first_tail_x15_r0_body.kr0_23.flags = Stage.setAll PRE_first_tail_x15_r0_body.krC_23.flags (PRE_first_tail_x15_r0_body.clo23.filterMap fun i => (PRE_first_tail_x15_r0_body.kr0_23.flags.get i).map (i, ·))
kernel_rfl PRE_first_tail_x15_r0_body.fkt023 : PRE_first_tail_x15_r0_body.kr0_23.targs = Stage.setAll PRE_first_tail_x15_r0_body.krC_23.targs (PRE_first_tail_x15_r0_body.clo23.filterMap fun i => (PRE_first_tail_x15_r0_body.kr0_23.targs.get i).map (i, ·))
kernel_rfl PRE_first_tail_x15_r0_body.fkf123 : PRE_first_tail_x15_r0_body.kr1_23.flags = Stage.setAll PRE_first_tail_x15_r0_body.krC_23.flags (PRE_first_tail_x15_r0_body.cwS23.filterMap fun i => (PRE_first_tail_x15_r0_body.kr1_23.flags.get i).map (i, ·))
kernel_rfl PRE_first_tail_x15_r0_body.fkt123 : PRE_first_tail_x15_r0_body.kr1_23.targs = Stage.setAll PRE_first_tail_x15_r0_body.krC_23.targs (PRE_first_tail_x15_r0_body.cwS23.filterMap fun i => (PRE_first_tail_x15_r0_body.kr1_23.targs.get i).map (i, ·))
kernel_rfl PRE_first_tail_x15_r0_body.fkck23 : krecLB PRE_first_tail_x15_r0_body.kappa23 1036 PRE_first_tail_x15_r0_body.cx0_23.mlx PRE_first_tail_x15_r0_body.kr0_23 PRE_first_tail_x15_r0_body.kr1_23 PRE_first_tail_x15_r0_body.clo23 = true
kernel_rfl PRE_first_tail_x15_r0_body.fkn23 : Nat.ble 1036 1036 = true
-- the bridge and the pending traces' regions
kernel_rfl PRE_first_tail_x15_r0_body.cbridge23 : Host.Ts.Sim.Full.bridgeOf PRE_first_tail_x15_r0_body.s209.ffi = Host.Ts.Sim.Full.bridgeOf PRE_first_tail_x15_r0_body.s210.ffi
kernel_rfl PRE_first_tail_x15_r0_body.cpendR23 : pendRegB PRE_first_tail_x15_r0_body.kappa23 (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s210.ffi).mlx = true
kernel_rfl PRE_first_tail_x15_r0_body.cpendLe23 : Nat.ble (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s210.ffi).mlx.next (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s209.ffi).mlx.next = true
/-- **The compaction's native shift**, given the call's bookkeeping, its relation's facts (the model's and the
observers') and the canonical closedness. -/
theorem PRE_first_tail_x15_r0_body.cshift23 (clean : Conv.NClean (⟨18653, 15733, 2692793, 1036⟩ : Conv.Cnt) (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s208.ffi).mlx) (hltC : ∀ h, PH (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s208.ffi).mlx h → h < (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s208.ffi).mlx.next) (nltC : ∀ i, PN (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s208.ffi).mlx i → i < (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s208.ffi).mlx.nnext) (itemsC : ∀ k v, (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s208.ffi).mlx.items.get k = some v → PN (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s208.ffi).mlx k) (tracedC : ∀ h o, (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s208.ffi).mlx.objs.get h = some o → ∀ i ∈ objTraces o, i < PRE_first_tail_x15_r0_body.P23.NL) (cl : SSt (· < 1036) PRE_first_tail_x15_r0_body.cx0_23.mlx)
    (hobjC : ∀ h, PRE_first_tail_x15_r0_body.fxC_23.get h = some () → ((Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s208.ffi).mlx.objs.get h).isSome = true)
    (hfC : ∀ h, (PRE_first_tail_x15_r0_body.krC_23.flags.get h).isSome = true → ((Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s208.ffi).mlx.objs.get h).isSome = true)
    (htC : ∀ h, (PRE_first_tail_x15_r0_body.krC_23.targs.get h).isSome = true → ((Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s208.ffi).mlx.objs.get h).isSome = true)
    (hclC : ∀ h l, PRE_first_tail_x15_r0_body.krC_23.targs.get h = some l → Host.Ts.Sim.Full.STargs (· < (⟨18653, 15733, 2692793, 1036⟩ : Conv.Cnt).n) l) :
    Conv.FullShiftQ PRE_first_tail_x15_r0_body.P23 1036 PRE_first_tail_x15_r0_body.kappa23 PRE_first_tail_x15_r0_body.s210.ffi PRE_first_tail_x15_r0_body.s209.ffi :=
  ⟨PRE_first_tail_x15_r0_body.cnshift23 clean hltC nltC itemsC tracedC cl, PRE_first_tail_x15_r0_body.cqueue23, fun t ht => bSN_sound (List.all_eq_true.mp PRE_first_tail_x15_r0_body.ctokSupp23 t ht),
    PRE_first_tail_x15_r0_body.cbridge23,
    liveShift_foot (x0' := Host.Ts.Sim.Full.mlxOf PRE_first_tail_x15_r0_body.s210.ffi) (x1' := Host.Ts.Sim.Full.mlxOf PRE_first_tail_x15_r0_body.s209.ffi) (PRE_first_tail_x15_r0_body.cfoot23 clean hltC nltC itemsC tracedC cl) rfl PRE_first_tail_x15_r0_body.ofx0_23 PRE_first_tail_x15_r0_body.ofx1_23 hobjC PRE_first_tail_x15_r0_body.ff023 PRE_first_tail_x15_r0_body.ff123 PRE_first_tail_x15_r0_body.ffck23,
    kernShift_foot (x0' := Host.Ts.Sim.Full.mlxOf PRE_first_tail_x15_r0_body.s210.ffi) (x1' := Host.Ts.Sim.Full.mlxOf PRE_first_tail_x15_r0_body.s209.ffi) (PRE_first_tail_x15_r0_body.cfoot23 clean hltC nltC itemsC tracedC cl) rfl PRE_first_tail_x15_r0_body.okr0_23 PRE_first_tail_x15_r0_body.okr1_23 (Nat.le_of_ble_eq_true PRE_first_tail_x15_r0_body.fkn23) hfC htC hclC
      PRE_first_tail_x15_r0_body.fkf023 PRE_first_tail_x15_r0_body.fkt023 PRE_first_tail_x15_r0_body.fkf123 PRE_first_tail_x15_r0_body.fkt123 PRE_first_tail_x15_r0_body.fkck23,
    pendReg_of rfl PRE_first_tail_x15_r0_body.cnh023 PRE_first_tail_x15_r0_body.cnh123 (Nat.le_of_ble_eq_true PRE_first_tail_x15_r0_body.cpendLe23) PRE_first_tail_x15_r0_body.cpendR23⟩

end Host.Load.Run.Tpl
