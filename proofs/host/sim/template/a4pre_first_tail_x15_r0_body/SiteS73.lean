import host.sim.template.a4pre_first_tail_x15_r0_body.SiteCl73
import host.sim.conv.CompactFull
import host.sim.template.FootGen
set_option Elab.async false
namespace Host.Load.Run.Tpl
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
open Host.Ts Host.Ts.Sim Host.Ts.Sim.Template

/-! The compaction's native shift at call site 73 from its footprint (`Conv.nshift_of_foot`), and the observers'
(`liveShift_foot`, `kernShift_foot`): `Conv.FullShiftQ` for `Conv.full_compactQ`, given the call's bookkeeping and its
relation's facts. -/

/-- The load parameters of the chain (band-free: its start's node counter as `NL` and `N0`). -/
def PRE_first_tail_x15_r0_body.Pc73 : LoadP := ⟨18151, 131072, 1099511627776, 15235, 15235, []⟩
/-- The site's band raised to the map's checked fixed-node prefix, including newly recorded closure traces. -/
def PRE_first_tail_x15_r0_body.P73 : LoadP := PRE_first_tail_x15_r0_body.Pc73.raise 16740
kernel_rfl PRE_first_tail_x15_r0_body.craise73 : Nat.ble PRE_first_tail_x15_r0_body.Pc73.N0 16740 = true
theorem PRE_first_tail_x15_r0_body.raised73 : Host.Ts.Sim.Full.Raised PRE_first_tail_x15_r0_body.Pc73 PRE_first_tail_x15_r0_body.P73 :=
  .inr ⟨16740, rfl, Nat.le_of_ble_eq_true PRE_first_tail_x15_r0_body.craise73, rfl⟩
noncomputable abbrev PRE_first_tail_x15_r0_body.cx0_73 : Host.Load.LSt := clearTokens (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s653.ffi)
noncomputable abbrev PRE_first_tail_x15_r0_body.cx1_73 : Host.Load.LSt := clearTokens (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s652.ffi)
def PRE_first_tail_x15_r0_body.khinv73 : PTrie Nat := Stage.setAll PTrie.nil []
def PRE_first_tail_x15_r0_body.kninv73 : PTrie Nat := Stage.setAll PTrie.nil []
/-- The stage's footprint: its written and fresh handles, fresh nodes, written and fresh items. -/
def PRE_first_tail_x15_r0_body.cwS73 : List Nat := []
def PRE_first_tail_x15_r0_body.cnS73 : List Nat := List.range' 16740 0
def PRE_first_tail_x15_r0_body.ciS73 : List Nat := [] ++ List.range' 16740 0

-- the small checks (`MChecks`'s)
kernel_rfl PRE_first_tail_x15_r0_body.cnh073 : PRE_first_tail_x15_r0_body.kd73.nh0 = PRE_first_tail_x15_r0_body.cx0_73.mlx.next
kernel_rfl PRE_first_tail_x15_r0_body.cnh173 : PRE_first_tail_x15_r0_body.kd73.nh1 = PRE_first_tail_x15_r0_body.cx1_73.mlx.next
kernel_rfl PRE_first_tail_x15_r0_body.cnn073 : PRE_first_tail_x15_r0_body.kd73.nn0 = PRE_first_tail_x15_r0_body.cx0_73.mlx.nnext
kernel_rfl PRE_first_tail_x15_r0_body.cnn173 : PRE_first_tail_x15_r0_body.kd73.nn1 = PRE_first_tail_x15_r0_body.cx1_73.mlx.nnext
kernel_rfl PRE_first_tail_x15_r0_body.cplo73 : (Nat.blt 0 PRE_first_tail_x15_r0_body.P73.lo && Nat.ble PRE_first_tail_x15_r0_body.P73.lo PRE_first_tail_x15_r0_body.cx0_73.mlx.next && Nat.ble PRE_first_tail_x15_r0_body.P73.lo RData.bigHi && Nat.ble RData.bigHi PRE_first_tail_x15_r0_body.P73.E) = true
kernel_rfl PRE_first_tail_x15_r0_body.ccnt73 : (Nat.ble PRE_first_tail_x15_r0_body.cx0_73.mlx.next PRE_first_tail_x15_r0_body.cx1_73.mlx.next && Nat.ble PRE_first_tail_x15_r0_body.cx0_73.mlx.nnext PRE_first_tail_x15_r0_body.cx1_73.mlx.nnext) = true
kernel_rfl PRE_first_tail_x15_r0_body.cnband73 : (Nat.blt 0 PRE_first_tail_x15_r0_body.P73.NL && Nat.ble PRE_first_tail_x15_r0_body.P73.NL PRE_first_tail_x15_r0_body.P73.N0 && Nat.ble PRE_first_tail_x15_r0_body.P73.N0 PRE_first_tail_x15_r0_body.cx0_73.mlx.nnext) = true
kernel_rfl PRE_first_tail_x15_r0_body.chbelow73 : PRE_first_tail_x15_r0_body.kd73.checkHndBelow = true
kernel_rfl PRE_first_tail_x15_r0_body.chren73 : checkRenG PRE_first_tail_x15_r0_body.kd73.hnd PRE_first_tail_x15_r0_body.khinv73 (phB PRE_first_tail_x15_r0_body.cx0_73.mlx) = true
kernel_rfl PRE_first_tail_x15_r0_body.cband73 : PRE_first_tail_x15_r0_body.kd73.checkBand PRE_first_tail_x15_r0_body.P73.lo = true
kernel_rfl PRE_first_tail_x15_r0_body.cnh1pos73 : Nat.blt 0 PRE_first_tail_x15_r0_body.kd73.nh1 = true
kernel_rfl PRE_first_tail_x15_r0_body.cnren73 : checkRenG PRE_first_tail_x15_r0_body.kd73.node PRE_first_tail_x15_r0_body.kninv73 (pnB PRE_first_tail_x15_r0_body.cx0_73.mlx) = true
kernel_rfl PRE_first_tail_x15_r0_body.cnlow73 : (PTrie.keysA PRE_first_tail_x15_r0_body.kd73.node).all (fun j => Nat.ble PRE_first_tail_x15_r0_body.P73.NL j && Nat.blt (PRE_first_tail_x15_r0_body.kd73.nodeF j) PRE_first_tail_x15_r0_body.cx1_73.mlx.nnext) = true
kernel_rfl PRE_first_tail_x15_r0_body.cabs0a73 : PRE_first_tail_x15_r0_body.cx0_73.mlx.arrs.get 0 = none
kernel_rfl PRE_first_tail_x15_r0_body.cabs0b73 : PRE_first_tail_x15_r0_body.cx0_73.mlx.objs.get 0 = none
kernel_rfl PRE_first_tail_x15_r0_body.ctok173 : PRE_first_tail_x15_r0_body.cx1_73.mlx.tokens = []
kernel_rfl PRE_first_tail_x15_r0_body.cpend73 : PRE_first_tail_x15_r0_body.cx1_73.mlx.pending = PRE_first_tail_x15_r0_body.cx0_73.mlx.pending.map PRE_first_tail_x15_r0_body.kappa73.pend
kernel_rfl PRE_first_tail_x15_r0_body.cerrh73 : PRE_first_tail_x15_r0_body.cx1_73.mlx.errh = PRE_first_tail_x15_r0_body.cx0_73.mlx.errh.map PRE_first_tail_x15_r0_body.kappa73.arg
kernel_rfl PRE_first_tail_x15_r0_body.cfiles73 : PRE_first_tail_x15_r0_body.cx1_73.mlx.files = PRE_first_tail_x15_r0_body.cx0_73.mlx.files
kernel_rfl PRE_first_tail_x15_r0_body.carch73 : PRE_first_tail_x15_r0_body.cx1_73.mlx.arch = PRE_first_tail_x15_r0_body.cx0_73.mlx.arch
kernel_rfl PRE_first_tail_x15_r0_body.csizes73 : PRE_first_tail_x15_r0_body.cx1_73.mlx.deviceSizes = PRE_first_tail_x15_r0_body.cx0_73.mlx.deviceSizes
kernel_rfl PRE_first_tail_x15_r0_body.cwired73 : PRE_first_tail_x15_r0_body.cx1_73.mlx.wired = PRE_first_tail_x15_r0_body.cx0_73.mlx.wired
kernel_rfl PRE_first_tail_x15_r0_body.chost73 : PRE_first_tail_x15_r0_body.cx1_73.host = PRE_first_tail_x15_r0_body.cx0_73.host
-- the compaction map's addresses are `PRE_first_tail_x15_r0_body.kd73`'s
kernel_rfl PRE_first_tail_x15_r0_body.ckn073 : PRE_first_tail_x15_r0_body.kd73.n0 = 2732455
kernel_rfl PRE_first_tail_x15_r0_body.ckn173 : PRE_first_tail_x15_r0_body.kd73.n1 = 2732457
kernel_rfl PRE_first_tail_x15_r0_body.ckheap73 : (PTrie.keysA PRE_first_tail_x15_r0_body.kd73.heap).all (fun x => Nat.ble 2732455 x) = true
kernel_rfl PRE_first_tail_x15_r0_body.ckpl73 : (List.range 0).all (fun j => decide (PRE_first_tail_x15_r0_body.kd73.heap.get (2732455 + j) = nth? PRE_first_tail_x15_r0_body.pl73 j)) = true
-- the map fixes the call's names (`Conv.fixOld_compact`), the call's counters
kernel_rfl PRE_first_tail_x15_r0_body.fja73 : Nat.ble 2732455 2732455 = true
kernel_rfl PRE_first_tail_x15_r0_body.fn73 : Nat.ble 3200 3200 = true
kernel_rfl PRE_first_tail_x15_r0_body.fjaD73 : Nat.ble 2732455 PRE_first_tail_x15_r0_body.kd73.n0 = true
kernel_rfl PRE_first_tail_x15_r0_body.fxn73 : Nat.ble 19648 PRE_first_tail_x15_r0_body.kd73.nh0 = true
kernel_rfl PRE_first_tail_x15_r0_body.fnn73 : Nat.ble 16740 PRE_first_tail_x15_r0_body.kd73.nn0 = true
kernel_rfl PRE_first_tail_x15_r0_body.fxb73 : Nat.ble 19648 RData.bigHi = true
kernel_rfl PRE_first_tail_x15_r0_body.fheap73 : (PTrie.keysA PRE_first_tail_x15_r0_body.kd73.heap).all (Nat.ble (⟨19648, 16740, 2732455, 3200⟩ : Conv.Cnt).ja) = true
kernel_rfl PRE_first_tail_x15_r0_body.fhnd73 : (PTrie.keysA PRE_first_tail_x15_r0_body.kd73.hnd).all (Nat.ble (⟨19648, 16740, 2732455, 3200⟩ : Conv.Cnt).xn) = true
kernel_rfl PRE_first_tail_x15_r0_body.fnode73 : (PTrie.keysA PRE_first_tail_x15_r0_body.kd73.node).all (Nat.ble (⟨19648, 16740, 2732455, 3200⟩ : Conv.Cnt).nn) = true
/-- The compaction map fixes the call's names. -/
theorem PRE_first_tail_x15_r0_body.cfix73 : Conv.FixOld (⟨19648, 16740, 2732455, 3200⟩ : Conv.Cnt) PRE_first_tail_x15_r0_body.kappa73 :=
  Conv.fixOld_compact (Nat.le_of_ble_eq_true PRE_first_tail_x15_r0_body.fja73) (Nat.le_of_ble_eq_true PRE_first_tail_x15_r0_body.fn73) (Nat.le_of_ble_eq_true PRE_first_tail_x15_r0_body.fjaD73) (Nat.le_of_ble_eq_true PRE_first_tail_x15_r0_body.fxn73) (Nat.le_of_ble_eq_true PRE_first_tail_x15_r0_body.fnn73) (Nat.le_of_ble_eq_true PRE_first_tail_x15_r0_body.fxb73) PRE_first_tail_x15_r0_body.fheap73 PRE_first_tail_x15_r0_body.fhnd73 PRE_first_tail_x15_r0_body.fnode73
kernel_rfl PRE_first_tail_x15_r0_body.fcxn73 : (⟨19648, 16740, 2732455, 3200⟩ : Conv.Cnt).xn = (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s651.ffi).mlx.next
kernel_rfl PRE_first_tail_x15_r0_body.fcnn73 : (⟨19648, 16740, 2732455, 3200⟩ : Conv.Cnt).nn = (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s651.ffi).mlx.nnext
kernel_rfl PRE_first_tail_x15_r0_body.fle073 : (Nat.ble (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s651.ffi).mlx.next PRE_first_tail_x15_r0_body.cx0_73.mlx.next && Nat.ble (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s651.ffi).mlx.nnext PRE_first_tail_x15_r0_body.cx0_73.mlx.nnext && Nat.ble (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s651.ffi).mlx.next RData.bigHi) = true
kernel_rfl PRE_first_tail_x15_r0_body.fnk73 : (PTrie.keysA PRE_first_tail_x15_r0_body.kd73.node).all (Nat.ble (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s651.ffi).mlx.nnext) = true
-- the merged state keeps the call's entries off the stage's footprint
kernel_rfl PRE_first_tail_x15_r0_body.f1A73 : PRE_first_tail_x15_r0_body.cx1_73.mlx.arrs = Stage.setAll (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s651.ffi).mlx.arrs (PRE_first_tail_x15_r0_body.cwS73.filterMap fun i => (PRE_first_tail_x15_r0_body.cx1_73.mlx.arrs.get i).map (i, ·))
kernel_rfl PRE_first_tail_x15_r0_body.f1O73 : PRE_first_tail_x15_r0_body.cx1_73.mlx.objs = Stage.setAll (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s651.ffi).mlx.objs (PRE_first_tail_x15_r0_body.cwS73.filterMap fun i => (PRE_first_tail_x15_r0_body.cx1_73.mlx.objs.get i).map (i, ·))
kernel_rfl PRE_first_tail_x15_r0_body.f1N73 : PRE_first_tail_x15_r0_body.cx1_73.mlx.nodes = Stage.setAll (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s651.ffi).mlx.nodes (PRE_first_tail_x15_r0_body.cnS73.filterMap fun i => (PRE_first_tail_x15_r0_body.cx1_73.mlx.nodes.get i).map (i, ·))
kernel_rfl PRE_first_tail_x15_r0_body.f1I73 : PRE_first_tail_x15_r0_body.cx1_73.mlx.items = Stage.setAll (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s651.ffi).mlx.items (PRE_first_tail_x15_r0_body.ciS73.filterMap fun i => (PRE_first_tail_x15_r0_body.cx1_73.mlx.items.get i).map (i, ·))
kernel_rfl PRE_first_tail_x15_r0_body.fbd73 : (PRE_first_tail_x15_r0_body.clo73 ++ PRE_first_tail_x15_r0_body.cln73 ++ PRE_first_tail_x15_r0_body.cli73 ++ PRE_first_tail_x15_r0_body.cwS73 ++ PRE_first_tail_x15_r0_body.cnS73 ++ PRE_first_tail_x15_r0_body.ciS73).all (fun i => Nat.blt (i / 4096) (4 ^ 31)) = true
kernel_rfl PRE_first_tail_x15_r0_body.fincW73 : PRE_first_tail_x15_r0_body.cwS73.all (fun h => !Nat.blt h (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s651.ffi).mlx.next || PRE_first_tail_x15_r0_body.clo73.contains h) = true
kernel_rfl PRE_first_tail_x15_r0_body.fincI73 : PRE_first_tail_x15_r0_body.ciS73.all (fun k => !Nat.blt k (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s651.ffi).mlx.nnext || PRE_first_tail_x15_r0_body.cli73.contains k) = true
kernel_rfl PRE_first_tail_x15_r0_body.fincN73 : PRE_first_tail_x15_r0_body.cnS73.all (Nat.ble (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s651.ffi).mlx.nnext) = true
kernel_rfl PRE_first_tail_x15_r0_body.flnF73 : PRE_first_tail_x15_r0_body.cln73.all (Nat.ble (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s651.ffi).mlx.nnext) = true
-- the checks over the changed lists
kernel_rfl PRE_first_tail_x15_r0_body.fh73 : PRE_first_tail_x15_r0_body.clo73.all (handleOK PRE_first_tail_x15_r0_body.kappa73 PRE_first_tail_x15_r0_body.P73.lo PRE_first_tail_x15_r0_body.cx0_73.mlx PRE_first_tail_x15_r0_body.cx1_73.mlx) = true
kernel_rfl PRE_first_tail_x15_r0_body.fo73 : PRE_first_tail_x15_r0_body.clo73.map (fun h => PRE_first_tail_x15_r0_body.cx1_73.mlx.objs.get (PRE_first_tail_x15_r0_body.kappa73.handle h)) = PRE_first_tail_x15_r0_body.clo73.map (fun h => (PRE_first_tail_x15_r0_body.cx0_73.mlx.objs.get h).map PRE_first_tail_x15_r0_body.kappa73.nobj)
kernel_rfl PRE_first_tail_x15_r0_body.fok73 : PRE_first_tail_x15_r0_body.clo73.all (objOK PRE_first_tail_x15_r0_body.kappa73 PRE_first_tail_x15_r0_body.P73.NL PRE_first_tail_x15_r0_body.cx0_73.mlx) = true
kernel_rfl PRE_first_tail_x15_r0_body.fnd73 : PRE_first_tail_x15_r0_body.cln73.all (nodeOKF PRE_first_tail_x15_r0_body.kappa73 PRE_first_tail_x15_r0_body.P73 PRE_first_tail_x15_r0_body.cx0_73.mlx PRE_first_tail_x15_r0_body.cx1_73.mlx) = true
kernel_rfl PRE_first_tail_x15_r0_body.fp73 : ((PRE_first_tail_x15_r0_body.cln73.filter (fullB PRE_first_tail_x15_r0_body.P73))).map (fun i => (PRE_first_tail_x15_r0_body.cx1_73.mlx.nodes.get (PRE_first_tail_x15_r0_body.kappa73.node i)).map Host.Mlx.Ffi.Node.prim) =
  ((PRE_first_tail_x15_r0_body.cln73.filter (fullB PRE_first_tail_x15_r0_body.P73))).map (fun i => (PRE_first_tail_x15_r0_body.cx0_73.mlx.nodes.get i).map fun nd => PRE_first_tail_x15_r0_body.kappa73.prim nd.prim)
kernel_rfl PRE_first_tail_x15_r0_body.fnordI73 : incrB PRE_first_tail_x15_r0_body.kd73.nodeF (List.range' 16740 0) = true
kernel_rfl PRE_first_tail_x15_r0_body.fnordK73 : (PTrie.keysA PRE_first_tail_x15_r0_body.kd73.node).all (fun k => Nat.ble 16740 k && Nat.blt k 16740) = true
kernel_rfl PRE_first_tail_x15_r0_body.fnordL73 : (PRE_first_tail_x15_r0_body.cln73.filter (Nat.ble PRE_first_tail_x15_r0_body.P73.N0)).all (fun i => Nat.ble i (PRE_first_tail_x15_r0_body.kd73.nodeF i) && (Nat.blt i 16740 || Nat.ble PRE_first_tail_x15_r0_body.kd73.nn0 i)) = true
theorem PRE_first_tail_x15_r0_body.fnord73 : (PRE_first_tail_x15_r0_body.cln73.filter (Nat.ble PRE_first_tail_x15_r0_body.P73.N0)).all (fun i => Nat.ble i (PRE_first_tail_x15_r0_body.kd73.nodeF i) &&
    (PTrie.keysA PRE_first_tail_x15_r0_body.kd73.node).all fun j => !Nat.blt j i || Nat.blt (PRE_first_tail_x15_r0_body.kd73.nodeF j) (PRE_first_tail_x15_r0_body.kd73.nodeF i)) = true :=
  cnord_of PRE_first_tail_x15_r0_body.cnlow73 PRE_first_tail_x15_r0_body.cnn173 PRE_first_tail_x15_r0_body.fnordI73 PRE_first_tail_x15_r0_body.fnordK73 PRE_first_tail_x15_r0_body.fnordL73
kernel_rfl PRE_first_tail_x15_r0_body.fi73 : PRE_first_tail_x15_r0_body.cli73.all (pnB PRE_first_tail_x15_r0_body.cx0_73.mlx) = true
kernel_rfl PRE_first_tail_x15_r0_body.fii73 : PRE_first_tail_x15_r0_body.cli73.all (fun k => decide (PRE_first_tail_x15_r0_body.cx1_73.mlx.items.get (PRE_first_tail_x15_r0_body.kappa73.node k) = (PRE_first_tail_x15_r0_body.cx0_73.mlx.items.get k).map PRE_first_tail_x15_r0_body.kappa73.nv)) = true
/-- **The compaction's footprint.** -/
theorem PRE_first_tail_x15_r0_body.cfoot73 (clean : Conv.NClean (⟨19648, 16740, 2732455, 3200⟩ : Conv.Cnt) (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s651.ffi).mlx) (hltC : ∀ h, PH (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s651.ffi).mlx h → h < (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s651.ffi).mlx.next) (nltC : ∀ i, PN (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s651.ffi).mlx i → i < (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s651.ffi).mlx.nnext) (itemsC : ∀ k v, (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s651.ffi).mlx.items.get k = some v → PN (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s651.ffi).mlx k) (tracedC : ∀ h o, (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s651.ffi).mlx.objs.get h = some o → ∀ i ∈ objTraces o, i < PRE_first_tail_x15_r0_body.P73.NL) (cl : SSt (· < 3200) PRE_first_tail_x15_r0_body.cx0_73.mlx) :
    Conv.MFoot PRE_first_tail_x15_r0_body.P73 3200 PRE_first_tail_x15_r0_body.kappa73 PRE_first_tail_x15_r0_body.kd73 PRE_first_tail_x15_r0_body.khinv73 PRE_first_tail_x15_r0_body.kninv73 (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s651.ffi).mlx PRE_first_tail_x15_r0_body.cx0_73.mlx PRE_first_tail_x15_r0_body.cx1_73.mlx (⟨19648, 16740, 2732455, 3200⟩ : Conv.Cnt) PRE_first_tail_x15_r0_body.clo73 PRE_first_tail_x15_r0_body.cln73 PRE_first_tail_x15_r0_body.cli73 PRE_first_tail_x15_r0_body.cwS73 PRE_first_tail_x15_r0_body.cnS73 PRE_first_tail_x15_r0_body.ciS73 :=
  ⟨rfl, rfl, rfl, PRE_first_tail_x15_r0_body.cnh073, PRE_first_tail_x15_r0_body.cnh173, PRE_first_tail_x15_r0_body.cnn073, PRE_first_tail_x15_r0_body.cnn173, PRE_first_tail_x15_r0_body.cplo73, PRE_first_tail_x15_r0_body.ccnt73, PRE_first_tail_x15_r0_body.cnband73, PRE_first_tail_x15_r0_body.chbelow73, PRE_first_tail_x15_r0_body.chren73, PRE_first_tail_x15_r0_body.cband73, PRE_first_tail_x15_r0_body.cnh1pos73, PRE_first_tail_x15_r0_body.cnren73, PRE_first_tail_x15_r0_body.cnlow73, PRE_first_tail_x15_r0_body.cabs0a73, PRE_first_tail_x15_r0_body.cabs0b73, PRE_first_tail_x15_r0_body.ctok173, PRE_first_tail_x15_r0_body.cpend73, PRE_first_tail_x15_r0_body.cerrh73, PRE_first_tail_x15_r0_body.cfiles73, PRE_first_tail_x15_r0_body.carch73, PRE_first_tail_x15_r0_body.csizes73, PRE_first_tail_x15_r0_body.cwired73, PRE_first_tail_x15_r0_body.cfix73, clean, PRE_first_tail_x15_r0_body.fcxn73, PRE_first_tail_x15_r0_body.fcnn73, hltC, nltC, itemsC, tracedC, cl, PRE_first_tail_x15_r0_body.fle073, PRE_first_tail_x15_r0_body.fnk73, PRE_first_tail_x15_r0_body.ckA73, PRE_first_tail_x15_r0_body.cobjsK73, PRE_first_tail_x15_r0_body.cnodesK73, PRE_first_tail_x15_r0_body.citemsK73, PRE_first_tail_x15_r0_body.f1A73, PRE_first_tail_x15_r0_body.f1O73, PRE_first_tail_x15_r0_body.f1N73, PRE_first_tail_x15_r0_body.f1I73, PRE_first_tail_x15_r0_body.fbd73, PRE_first_tail_x15_r0_body.fincW73, PRE_first_tail_x15_r0_body.fincI73, PRE_first_tail_x15_r0_body.fincN73, PRE_first_tail_x15_r0_body.flnF73, PRE_first_tail_x15_r0_body.fh73, PRE_first_tail_x15_r0_body.fo73, PRE_first_tail_x15_r0_body.fok73, PRE_first_tail_x15_r0_body.fnd73, PRE_first_tail_x15_r0_body.fp73, PRE_first_tail_x15_r0_body.fnord73, PRE_first_tail_x15_r0_body.fi73, PRE_first_tail_x15_r0_body.fii73⟩
theorem PRE_first_tail_x15_r0_body.cnshift73 (clean : Conv.NClean (⟨19648, 16740, 2732455, 3200⟩ : Conv.Cnt) (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s651.ffi).mlx) (hltC : ∀ h, PH (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s651.ffi).mlx h → h < (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s651.ffi).mlx.next) (nltC : ∀ i, PN (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s651.ffi).mlx i → i < (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s651.ffi).mlx.nnext) (itemsC : ∀ k v, (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s651.ffi).mlx.items.get k = some v → PN (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s651.ffi).mlx k) (tracedC : ∀ h o, (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s651.ffi).mlx.objs.get h = some o → ∀ i ∈ objTraces o, i < PRE_first_tail_x15_r0_body.P73.NL) (cl : SSt (· < 3200) PRE_first_tail_x15_r0_body.cx0_73.mlx) : NShift PRE_first_tail_x15_r0_body.P73 3200 PRE_first_tail_x15_r0_body.kappa73 PRE_first_tail_x15_r0_body.cx0_73 PRE_first_tail_x15_r0_body.cx1_73 :=
  Conv.nshift_of_foot (PRE_first_tail_x15_r0_body.cfoot73 clean hltC nltC itemsC tracedC cl) PRE_first_tail_x15_r0_body.chost73 (compact_a_eq PRE_first_tail_x15_r0_body.ckn073 PRE_first_tail_x15_r0_body.ckn173 PRE_first_tail_x15_r0_body.ckheap73 PRE_first_tail_x15_r0_body.ckpl73)

-- the observers: the layers' states at the call, the canonical and the merged state, their footprints and checks
noncomputable def PRE_first_tail_x15_r0_body.fxC_73 : PTrie Unit := (Host.Ts.Sim.Full.freedOf PRE_first_tail_x15_r0_body.s651.ffi).getD PTrie.nil
noncomputable def PRE_first_tail_x15_r0_body.krC_73 : Host.Load.Layers.KRec := (Host.Ts.Sim.Full.krecOf PRE_first_tail_x15_r0_body.s651.ffi).getD Host.Load.Layers.KRec.empty
kernel_rfl PRE_first_tail_x15_r0_body.ofxC_73 : (Host.Ts.Sim.Full.freedOf PRE_first_tail_x15_r0_body.s651.ffi) = some PRE_first_tail_x15_r0_body.fxC_73
kernel_rfl PRE_first_tail_x15_r0_body.okrC_73 : (Host.Ts.Sim.Full.krecOf PRE_first_tail_x15_r0_body.s651.ffi) = some PRE_first_tail_x15_r0_body.krC_73
noncomputable def PRE_first_tail_x15_r0_body.fx0_73 : PTrie Unit := (Host.Ts.Sim.Full.freedOf PRE_first_tail_x15_r0_body.s653.ffi).getD PTrie.nil
noncomputable def PRE_first_tail_x15_r0_body.kr0_73 : Host.Load.Layers.KRec := (Host.Ts.Sim.Full.krecOf PRE_first_tail_x15_r0_body.s653.ffi).getD Host.Load.Layers.KRec.empty
kernel_rfl PRE_first_tail_x15_r0_body.ofx0_73 : (Host.Ts.Sim.Full.freedOf PRE_first_tail_x15_r0_body.s653.ffi) = some PRE_first_tail_x15_r0_body.fx0_73
kernel_rfl PRE_first_tail_x15_r0_body.okr0_73 : (Host.Ts.Sim.Full.krecOf PRE_first_tail_x15_r0_body.s653.ffi) = some PRE_first_tail_x15_r0_body.kr0_73
noncomputable def PRE_first_tail_x15_r0_body.fx1_73 : PTrie Unit := (Host.Ts.Sim.Full.freedOf PRE_first_tail_x15_r0_body.s652.ffi).getD PTrie.nil
noncomputable def PRE_first_tail_x15_r0_body.kr1_73 : Host.Load.Layers.KRec := (Host.Ts.Sim.Full.krecOf PRE_first_tail_x15_r0_body.s652.ffi).getD Host.Load.Layers.KRec.empty
kernel_rfl PRE_first_tail_x15_r0_body.ofx1_73 : (Host.Ts.Sim.Full.freedOf PRE_first_tail_x15_r0_body.s652.ffi) = some PRE_first_tail_x15_r0_body.fx1_73
kernel_rfl PRE_first_tail_x15_r0_body.okr1_73 : (Host.Ts.Sim.Full.krecOf PRE_first_tail_x15_r0_body.s652.ffi) = some PRE_first_tail_x15_r0_body.kr1_73
kernel_rfl PRE_first_tail_x15_r0_body.ff073 : PRE_first_tail_x15_r0_body.fx0_73 = Stage.setAll PRE_first_tail_x15_r0_body.fxC_73 (PRE_first_tail_x15_r0_body.clo73.filterMap fun i => (PRE_first_tail_x15_r0_body.fx0_73.get i).map (i, ·))
kernel_rfl PRE_first_tail_x15_r0_body.ff173 : PRE_first_tail_x15_r0_body.fx1_73 = Stage.setAll PRE_first_tail_x15_r0_body.fxC_73 (PRE_first_tail_x15_r0_body.cwS73.filterMap fun i => (PRE_first_tail_x15_r0_body.fx1_73.get i).map (i, ·))
kernel_rfl PRE_first_tail_x15_r0_body.ffck73 : freedLB PRE_first_tail_x15_r0_body.kappa73 PRE_first_tail_x15_r0_body.cx0_73.mlx PRE_first_tail_x15_r0_body.fx0_73 PRE_first_tail_x15_r0_body.fx1_73 PRE_first_tail_x15_r0_body.clo73 = true
kernel_rfl PRE_first_tail_x15_r0_body.fkf073 : PRE_first_tail_x15_r0_body.kr0_73.flags = Stage.setAll PRE_first_tail_x15_r0_body.krC_73.flags (PRE_first_tail_x15_r0_body.clo73.filterMap fun i => (PRE_first_tail_x15_r0_body.kr0_73.flags.get i).map (i, ·))
kernel_rfl PRE_first_tail_x15_r0_body.fkt073 : PRE_first_tail_x15_r0_body.kr0_73.targs = Stage.setAll PRE_first_tail_x15_r0_body.krC_73.targs (PRE_first_tail_x15_r0_body.clo73.filterMap fun i => (PRE_first_tail_x15_r0_body.kr0_73.targs.get i).map (i, ·))
kernel_rfl PRE_first_tail_x15_r0_body.fkf173 : PRE_first_tail_x15_r0_body.kr1_73.flags = Stage.setAll PRE_first_tail_x15_r0_body.krC_73.flags (PRE_first_tail_x15_r0_body.cwS73.filterMap fun i => (PRE_first_tail_x15_r0_body.kr1_73.flags.get i).map (i, ·))
kernel_rfl PRE_first_tail_x15_r0_body.fkt173 : PRE_first_tail_x15_r0_body.kr1_73.targs = Stage.setAll PRE_first_tail_x15_r0_body.krC_73.targs (PRE_first_tail_x15_r0_body.cwS73.filterMap fun i => (PRE_first_tail_x15_r0_body.kr1_73.targs.get i).map (i, ·))
kernel_rfl PRE_first_tail_x15_r0_body.fkck73 : krecLB PRE_first_tail_x15_r0_body.kappa73 3200 PRE_first_tail_x15_r0_body.cx0_73.mlx PRE_first_tail_x15_r0_body.kr0_73 PRE_first_tail_x15_r0_body.kr1_73 PRE_first_tail_x15_r0_body.clo73 = true
kernel_rfl PRE_first_tail_x15_r0_body.fkn73 : Nat.ble 3200 3200 = true
-- the bridge and the pending traces' regions
kernel_rfl PRE_first_tail_x15_r0_body.cbridge73 : Host.Ts.Sim.Full.bridgeOf PRE_first_tail_x15_r0_body.s652.ffi = Host.Ts.Sim.Full.bridgeOf PRE_first_tail_x15_r0_body.s653.ffi
kernel_rfl PRE_first_tail_x15_r0_body.cpendR73 : pendRegB PRE_first_tail_x15_r0_body.kappa73 (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s653.ffi).mlx = true
kernel_rfl PRE_first_tail_x15_r0_body.cpendLe73 : Nat.ble (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s653.ffi).mlx.next (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s652.ffi).mlx.next = true
/-- **The compaction's native shift**, given the call's bookkeeping, its relation's facts (the model's and the
observers') and the canonical closedness. -/
theorem PRE_first_tail_x15_r0_body.cshift73 (clean : Conv.NClean (⟨19648, 16740, 2732455, 3200⟩ : Conv.Cnt) (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s651.ffi).mlx) (hltC : ∀ h, PH (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s651.ffi).mlx h → h < (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s651.ffi).mlx.next) (nltC : ∀ i, PN (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s651.ffi).mlx i → i < (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s651.ffi).mlx.nnext) (itemsC : ∀ k v, (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s651.ffi).mlx.items.get k = some v → PN (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s651.ffi).mlx k) (tracedC : ∀ h o, (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s651.ffi).mlx.objs.get h = some o → ∀ i ∈ objTraces o, i < PRE_first_tail_x15_r0_body.P73.NL) (cl : SSt (· < 3200) PRE_first_tail_x15_r0_body.cx0_73.mlx)
    (hobjC : ∀ h, PRE_first_tail_x15_r0_body.fxC_73.get h = some () → ((Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s651.ffi).mlx.objs.get h).isSome = true)
    (hfC : ∀ h, (PRE_first_tail_x15_r0_body.krC_73.flags.get h).isSome = true → ((Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s651.ffi).mlx.objs.get h).isSome = true)
    (htC : ∀ h, (PRE_first_tail_x15_r0_body.krC_73.targs.get h).isSome = true → ((Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s651.ffi).mlx.objs.get h).isSome = true)
    (hclC : ∀ h l, PRE_first_tail_x15_r0_body.krC_73.targs.get h = some l → Host.Ts.Sim.Full.STargs (· < (⟨19648, 16740, 2732455, 3200⟩ : Conv.Cnt).n) l) :
    Conv.FullShiftQ PRE_first_tail_x15_r0_body.P73 3200 PRE_first_tail_x15_r0_body.kappa73 PRE_first_tail_x15_r0_body.s653.ffi PRE_first_tail_x15_r0_body.s652.ffi :=
  ⟨PRE_first_tail_x15_r0_body.cnshift73 clean hltC nltC itemsC tracedC cl, PRE_first_tail_x15_r0_body.cqueue73, fun t ht => bSN_sound (List.all_eq_true.mp PRE_first_tail_x15_r0_body.ctokSupp73 t ht),
    PRE_first_tail_x15_r0_body.cbridge73,
    liveShift_foot (x0' := Host.Ts.Sim.Full.mlxOf PRE_first_tail_x15_r0_body.s653.ffi) (x1' := Host.Ts.Sim.Full.mlxOf PRE_first_tail_x15_r0_body.s652.ffi) (PRE_first_tail_x15_r0_body.cfoot73 clean hltC nltC itemsC tracedC cl) rfl PRE_first_tail_x15_r0_body.ofx0_73 PRE_first_tail_x15_r0_body.ofx1_73 hobjC PRE_first_tail_x15_r0_body.ff073 PRE_first_tail_x15_r0_body.ff173 PRE_first_tail_x15_r0_body.ffck73,
    kernShift_foot (x0' := Host.Ts.Sim.Full.mlxOf PRE_first_tail_x15_r0_body.s653.ffi) (x1' := Host.Ts.Sim.Full.mlxOf PRE_first_tail_x15_r0_body.s652.ffi) (PRE_first_tail_x15_r0_body.cfoot73 clean hltC nltC itemsC tracedC cl) rfl PRE_first_tail_x15_r0_body.okr0_73 PRE_first_tail_x15_r0_body.okr1_73 (Nat.le_of_ble_eq_true PRE_first_tail_x15_r0_body.fkn73) hfC htC hclC
      PRE_first_tail_x15_r0_body.fkf073 PRE_first_tail_x15_r0_body.fkt073 PRE_first_tail_x15_r0_body.fkf173 PRE_first_tail_x15_r0_body.fkt173 PRE_first_tail_x15_r0_body.fkck73,
    pendReg_of rfl PRE_first_tail_x15_r0_body.cnh073 PRE_first_tail_x15_r0_body.cnh173 (Nat.le_of_ble_eq_true PRE_first_tail_x15_r0_body.cpendLe73) PRE_first_tail_x15_r0_body.cpendR73⟩

end Host.Load.Run.Tpl
