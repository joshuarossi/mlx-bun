import host.sim.template.a4pre_first_tail_x15_r0_body.SiteCl75
import host.sim.conv.CompactFull
import host.sim.template.FootGen
set_option Elab.async false
namespace Host.Load.Run.Tpl
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
open Host.Ts Host.Ts.Sim Host.Ts.Sim.Template

/-! The compaction's native shift at call site 75 from its footprint (`Conv.nshift_of_foot`), and the observers'
(`liveShift_foot`, `kernShift_foot`): `Conv.FullShiftQ` for `Conv.full_compactQ`, given the call's bookkeeping and its
relation's facts. -/

/-- The load parameters of the chain (band-free: its start's node counter as `NL` and `N0`). -/
def PRE_first_tail_x15_r0_body.Pc75 : LoadP := ⟨18151, 131072, 1099511627776, 15235, 15235, []⟩
/-- The site's band raised to the map's checked fixed-node prefix, including newly recorded closure traces. -/
def PRE_first_tail_x15_r0_body.P75 : LoadP := PRE_first_tail_x15_r0_body.Pc75.raise 16790
kernel_rfl PRE_first_tail_x15_r0_body.craise75 : Nat.ble PRE_first_tail_x15_r0_body.Pc75.N0 16790 = true
theorem PRE_first_tail_x15_r0_body.raised75 : Host.Ts.Sim.Full.Raised PRE_first_tail_x15_r0_body.Pc75 PRE_first_tail_x15_r0_body.P75 :=
  .inr ⟨16790, rfl, Nat.le_of_ble_eq_true PRE_first_tail_x15_r0_body.craise75, rfl⟩
noncomputable abbrev PRE_first_tail_x15_r0_body.cx0_75 : Host.Load.LSt := clearTokens (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s673.ffi)
noncomputable abbrev PRE_first_tail_x15_r0_body.cx1_75 : Host.Load.LSt := clearTokens (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s672.ffi)
def PRE_first_tail_x15_r0_body.khinv75 : PTrie Nat := Stage.setAll PTrie.nil [(19715, 19689), (19693, 19690), (19716, 19691)]
def PRE_first_tail_x15_r0_body.kninv75 : PTrie Nat := Stage.setAll PTrie.nil [(16763, 16763), (16764, 16764), (16765, 16765), (16766, 16766), (16767, 16767), (16768, 16768), (16769, 16769), (16770, 16770), (16771, 16771), (16772, 16772), (16773, 16773), (16774, 16774), (16775, 16775), (16776, 16776), (16777, 16777), (16778, 16778), (16779, 16779), (16780, 16780), (16781, 16781), (16782, 16782), (16783, 16783), (16784, 16784), (16785, 16785), (16786, 16786), (16787, 16787), (16788, 16788), (16789, 16789)]
/-- The stage's footprint: its written and fresh handles, fresh nodes, written and fresh items. -/
def PRE_first_tail_x15_r0_body.cwS75 : List Nat := [19669, 19682, 19688, 19689, 19690, 19691, 19692, 19693, 19694, 19695, 19696, 19697, 19698, 19699, 19700, 19701, 19702, 19703, 19704, 19705, 19706, 19707, 19708, 19709, 19710, 19711, 19712, 19713, 19714, 19715, 19716]
def PRE_first_tail_x15_r0_body.cnS75 : List Nat := List.range' 16763 27
def PRE_first_tail_x15_r0_body.ciS75 : List Nat := [] ++ List.range' 16763 27

-- the small checks (`MChecks`'s)
kernel_rfl PRE_first_tail_x15_r0_body.cnh075 : PRE_first_tail_x15_r0_body.kd75.nh0 = PRE_first_tail_x15_r0_body.cx0_75.mlx.next
kernel_rfl PRE_first_tail_x15_r0_body.cnh175 : PRE_first_tail_x15_r0_body.kd75.nh1 = PRE_first_tail_x15_r0_body.cx1_75.mlx.next
kernel_rfl PRE_first_tail_x15_r0_body.cnn075 : PRE_first_tail_x15_r0_body.kd75.nn0 = PRE_first_tail_x15_r0_body.cx0_75.mlx.nnext
kernel_rfl PRE_first_tail_x15_r0_body.cnn175 : PRE_first_tail_x15_r0_body.kd75.nn1 = PRE_first_tail_x15_r0_body.cx1_75.mlx.nnext
kernel_rfl PRE_first_tail_x15_r0_body.cplo75 : (Nat.blt 0 PRE_first_tail_x15_r0_body.P75.lo && Nat.ble PRE_first_tail_x15_r0_body.P75.lo PRE_first_tail_x15_r0_body.cx0_75.mlx.next && Nat.ble PRE_first_tail_x15_r0_body.P75.lo RData.bigHi && Nat.ble RData.bigHi PRE_first_tail_x15_r0_body.P75.E) = true
kernel_rfl PRE_first_tail_x15_r0_body.ccnt75 : (Nat.ble PRE_first_tail_x15_r0_body.cx0_75.mlx.next PRE_first_tail_x15_r0_body.cx1_75.mlx.next && Nat.ble PRE_first_tail_x15_r0_body.cx0_75.mlx.nnext PRE_first_tail_x15_r0_body.cx1_75.mlx.nnext) = true
kernel_rfl PRE_first_tail_x15_r0_body.cnband75 : (Nat.blt 0 PRE_first_tail_x15_r0_body.P75.NL && Nat.ble PRE_first_tail_x15_r0_body.P75.NL PRE_first_tail_x15_r0_body.P75.N0 && Nat.ble PRE_first_tail_x15_r0_body.P75.N0 PRE_first_tail_x15_r0_body.cx0_75.mlx.nnext) = true
kernel_rfl PRE_first_tail_x15_r0_body.chbelow75 : PRE_first_tail_x15_r0_body.kd75.checkHndBelow = true
kernel_rfl PRE_first_tail_x15_r0_body.chren75 : checkRenG PRE_first_tail_x15_r0_body.kd75.hnd PRE_first_tail_x15_r0_body.khinv75 (phB PRE_first_tail_x15_r0_body.cx0_75.mlx) = true
kernel_rfl PRE_first_tail_x15_r0_body.cband75 : PRE_first_tail_x15_r0_body.kd75.checkBand PRE_first_tail_x15_r0_body.P75.lo = true
kernel_rfl PRE_first_tail_x15_r0_body.cnh1pos75 : Nat.blt 0 PRE_first_tail_x15_r0_body.kd75.nh1 = true
kernel_rfl PRE_first_tail_x15_r0_body.cnren75 : checkRenG PRE_first_tail_x15_r0_body.kd75.node PRE_first_tail_x15_r0_body.kninv75 (pnB PRE_first_tail_x15_r0_body.cx0_75.mlx) = true
kernel_rfl PRE_first_tail_x15_r0_body.cnlow75 : (PTrie.keysA PRE_first_tail_x15_r0_body.kd75.node).all (fun j => Nat.ble PRE_first_tail_x15_r0_body.P75.NL j && Nat.blt (PRE_first_tail_x15_r0_body.kd75.nodeF j) PRE_first_tail_x15_r0_body.cx1_75.mlx.nnext) = true
kernel_rfl PRE_first_tail_x15_r0_body.cabs0a75 : PRE_first_tail_x15_r0_body.cx0_75.mlx.arrs.get 0 = none
kernel_rfl PRE_first_tail_x15_r0_body.cabs0b75 : PRE_first_tail_x15_r0_body.cx0_75.mlx.objs.get 0 = none
kernel_rfl PRE_first_tail_x15_r0_body.ctok175 : PRE_first_tail_x15_r0_body.cx1_75.mlx.tokens = []
kernel_rfl PRE_first_tail_x15_r0_body.cpend75 : PRE_first_tail_x15_r0_body.cx1_75.mlx.pending = PRE_first_tail_x15_r0_body.cx0_75.mlx.pending.map PRE_first_tail_x15_r0_body.kappa75.pend
kernel_rfl PRE_first_tail_x15_r0_body.cerrh75 : PRE_first_tail_x15_r0_body.cx1_75.mlx.errh = PRE_first_tail_x15_r0_body.cx0_75.mlx.errh.map PRE_first_tail_x15_r0_body.kappa75.arg
kernel_rfl PRE_first_tail_x15_r0_body.cfiles75 : PRE_first_tail_x15_r0_body.cx1_75.mlx.files = PRE_first_tail_x15_r0_body.cx0_75.mlx.files
kernel_rfl PRE_first_tail_x15_r0_body.carch75 : PRE_first_tail_x15_r0_body.cx1_75.mlx.arch = PRE_first_tail_x15_r0_body.cx0_75.mlx.arch
kernel_rfl PRE_first_tail_x15_r0_body.csizes75 : PRE_first_tail_x15_r0_body.cx1_75.mlx.deviceSizes = PRE_first_tail_x15_r0_body.cx0_75.mlx.deviceSizes
kernel_rfl PRE_first_tail_x15_r0_body.cwired75 : PRE_first_tail_x15_r0_body.cx1_75.mlx.wired = PRE_first_tail_x15_r0_body.cx0_75.mlx.wired
kernel_rfl PRE_first_tail_x15_r0_body.chost75 : PRE_first_tail_x15_r0_body.cx1_75.host = PRE_first_tail_x15_r0_body.cx0_75.host
-- the compaction map's addresses are `PRE_first_tail_x15_r0_body.kd75`'s
kernel_rfl PRE_first_tail_x15_r0_body.ckn075 : PRE_first_tail_x15_r0_body.kd75.n0 = 2734221
kernel_rfl PRE_first_tail_x15_r0_body.ckn175 : PRE_first_tail_x15_r0_body.kd75.n1 = 2735370
kernel_rfl PRE_first_tail_x15_r0_body.ckheap75 : (PTrie.keysA PRE_first_tail_x15_r0_body.kd75.heap).all (fun x => Nat.ble 2734215 x) = true
kernel_rfl PRE_first_tail_x15_r0_body.ckpl75 : (List.range 6).all (fun j => decide (PRE_first_tail_x15_r0_body.kd75.heap.get (2734215 + j) = nth? PRE_first_tail_x15_r0_body.pl75 j)) = true
-- the map fixes the call's names (`Conv.fixOld_compact`), the call's counters
kernel_rfl PRE_first_tail_x15_r0_body.fja75 : Nat.ble 2734215 2734215 = true
kernel_rfl PRE_first_tail_x15_r0_body.fn75 : Nat.ble 3290 3290 = true
kernel_rfl PRE_first_tail_x15_r0_body.fjaD75 : Nat.ble 2734215 PRE_first_tail_x15_r0_body.kd75.n0 = true
kernel_rfl PRE_first_tail_x15_r0_body.fxn75 : Nat.ble 19689 PRE_first_tail_x15_r0_body.kd75.nh0 = true
kernel_rfl PRE_first_tail_x15_r0_body.fnn75 : Nat.ble 16763 PRE_first_tail_x15_r0_body.kd75.nn0 = true
kernel_rfl PRE_first_tail_x15_r0_body.fxb75 : Nat.ble 19689 RData.bigHi = true
kernel_rfl PRE_first_tail_x15_r0_body.fheap75 : (PTrie.keysA PRE_first_tail_x15_r0_body.kd75.heap).all (Nat.ble (⟨19689, 16763, 2734215, 3290⟩ : Conv.Cnt).ja) = true
kernel_rfl PRE_first_tail_x15_r0_body.fhnd75 : (PTrie.keysA PRE_first_tail_x15_r0_body.kd75.hnd).all (Nat.ble (⟨19689, 16763, 2734215, 3290⟩ : Conv.Cnt).xn) = true
kernel_rfl PRE_first_tail_x15_r0_body.fnode75 : (PTrie.keysA PRE_first_tail_x15_r0_body.kd75.node).all (Nat.ble (⟨19689, 16763, 2734215, 3290⟩ : Conv.Cnt).nn) = true
/-- The compaction map fixes the call's names. -/
theorem PRE_first_tail_x15_r0_body.cfix75 : Conv.FixOld (⟨19689, 16763, 2734215, 3290⟩ : Conv.Cnt) PRE_first_tail_x15_r0_body.kappa75 :=
  Conv.fixOld_compact (Nat.le_of_ble_eq_true PRE_first_tail_x15_r0_body.fja75) (Nat.le_of_ble_eq_true PRE_first_tail_x15_r0_body.fn75) (Nat.le_of_ble_eq_true PRE_first_tail_x15_r0_body.fjaD75) (Nat.le_of_ble_eq_true PRE_first_tail_x15_r0_body.fxn75) (Nat.le_of_ble_eq_true PRE_first_tail_x15_r0_body.fnn75) (Nat.le_of_ble_eq_true PRE_first_tail_x15_r0_body.fxb75) PRE_first_tail_x15_r0_body.fheap75 PRE_first_tail_x15_r0_body.fhnd75 PRE_first_tail_x15_r0_body.fnode75
kernel_rfl PRE_first_tail_x15_r0_body.fcxn75 : (⟨19689, 16763, 2734215, 3290⟩ : Conv.Cnt).xn = (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s671.ffi).mlx.next
kernel_rfl PRE_first_tail_x15_r0_body.fcnn75 : (⟨19689, 16763, 2734215, 3290⟩ : Conv.Cnt).nn = (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s671.ffi).mlx.nnext
kernel_rfl PRE_first_tail_x15_r0_body.fle075 : (Nat.ble (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s671.ffi).mlx.next PRE_first_tail_x15_r0_body.cx0_75.mlx.next && Nat.ble (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s671.ffi).mlx.nnext PRE_first_tail_x15_r0_body.cx0_75.mlx.nnext && Nat.ble (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s671.ffi).mlx.next RData.bigHi) = true
kernel_rfl PRE_first_tail_x15_r0_body.fnk75 : (PTrie.keysA PRE_first_tail_x15_r0_body.kd75.node).all (Nat.ble (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s671.ffi).mlx.nnext) = true
-- the merged state keeps the call's entries off the stage's footprint
kernel_rfl PRE_first_tail_x15_r0_body.f1A75 : PRE_first_tail_x15_r0_body.cx1_75.mlx.arrs = Stage.setAll (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s671.ffi).mlx.arrs (PRE_first_tail_x15_r0_body.cwS75.filterMap fun i => (PRE_first_tail_x15_r0_body.cx1_75.mlx.arrs.get i).map (i, ·))
kernel_rfl PRE_first_tail_x15_r0_body.f1O75 : PRE_first_tail_x15_r0_body.cx1_75.mlx.objs = Stage.setAll (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s671.ffi).mlx.objs (PRE_first_tail_x15_r0_body.cwS75.filterMap fun i => (PRE_first_tail_x15_r0_body.cx1_75.mlx.objs.get i).map (i, ·))
kernel_rfl PRE_first_tail_x15_r0_body.f1N75 : PRE_first_tail_x15_r0_body.cx1_75.mlx.nodes = Stage.setAll (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s671.ffi).mlx.nodes (PRE_first_tail_x15_r0_body.cnS75.filterMap fun i => (PRE_first_tail_x15_r0_body.cx1_75.mlx.nodes.get i).map (i, ·))
kernel_rfl PRE_first_tail_x15_r0_body.f1I75 : PRE_first_tail_x15_r0_body.cx1_75.mlx.items = Stage.setAll (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s671.ffi).mlx.items (PRE_first_tail_x15_r0_body.ciS75.filterMap fun i => (PRE_first_tail_x15_r0_body.cx1_75.mlx.items.get i).map (i, ·))
kernel_rfl PRE_first_tail_x15_r0_body.fbd75 : (PRE_first_tail_x15_r0_body.clo75 ++ PRE_first_tail_x15_r0_body.cln75 ++ PRE_first_tail_x15_r0_body.cli75 ++ PRE_first_tail_x15_r0_body.cwS75 ++ PRE_first_tail_x15_r0_body.cnS75 ++ PRE_first_tail_x15_r0_body.ciS75).all (fun i => Nat.blt (i / 4096) (4 ^ 31)) = true
kernel_rfl PRE_first_tail_x15_r0_body.fincW75 : PRE_first_tail_x15_r0_body.cwS75.all (fun h => !Nat.blt h (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s671.ffi).mlx.next || PRE_first_tail_x15_r0_body.clo75.contains h) = true
kernel_rfl PRE_first_tail_x15_r0_body.fincI75 : PRE_first_tail_x15_r0_body.ciS75.all (fun k => !Nat.blt k (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s671.ffi).mlx.nnext || PRE_first_tail_x15_r0_body.cli75.contains k) = true
kernel_rfl PRE_first_tail_x15_r0_body.fincN75 : PRE_first_tail_x15_r0_body.cnS75.all (Nat.ble (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s671.ffi).mlx.nnext) = true
kernel_rfl PRE_first_tail_x15_r0_body.flnF75 : PRE_first_tail_x15_r0_body.cln75.all (Nat.ble (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s671.ffi).mlx.nnext) = true
-- the checks over the changed lists
kernel_rfl PRE_first_tail_x15_r0_body.fh75 : PRE_first_tail_x15_r0_body.clo75.all (handleOK PRE_first_tail_x15_r0_body.kappa75 PRE_first_tail_x15_r0_body.P75.lo PRE_first_tail_x15_r0_body.cx0_75.mlx PRE_first_tail_x15_r0_body.cx1_75.mlx) = true
kernel_rfl PRE_first_tail_x15_r0_body.fo75 : PRE_first_tail_x15_r0_body.clo75.map (fun h => PRE_first_tail_x15_r0_body.cx1_75.mlx.objs.get (PRE_first_tail_x15_r0_body.kappa75.handle h)) = PRE_first_tail_x15_r0_body.clo75.map (fun h => (PRE_first_tail_x15_r0_body.cx0_75.mlx.objs.get h).map PRE_first_tail_x15_r0_body.kappa75.nobj)
kernel_rfl PRE_first_tail_x15_r0_body.fok75 : PRE_first_tail_x15_r0_body.clo75.all (objOK PRE_first_tail_x15_r0_body.kappa75 PRE_first_tail_x15_r0_body.P75.NL PRE_first_tail_x15_r0_body.cx0_75.mlx) = true
kernel_rfl PRE_first_tail_x15_r0_body.fnd75 : PRE_first_tail_x15_r0_body.cln75.all (nodeOKF PRE_first_tail_x15_r0_body.kappa75 PRE_first_tail_x15_r0_body.P75 PRE_first_tail_x15_r0_body.cx0_75.mlx PRE_first_tail_x15_r0_body.cx1_75.mlx) = true
kernel_rfl PRE_first_tail_x15_r0_body.fp75 : ((PRE_first_tail_x15_r0_body.cln75.filter (fullB PRE_first_tail_x15_r0_body.P75))).map (fun i => (PRE_first_tail_x15_r0_body.cx1_75.mlx.nodes.get (PRE_first_tail_x15_r0_body.kappa75.node i)).map Host.Mlx.Ffi.Node.prim) =
  ((PRE_first_tail_x15_r0_body.cln75.filter (fullB PRE_first_tail_x15_r0_body.P75))).map (fun i => (PRE_first_tail_x15_r0_body.cx0_75.mlx.nodes.get i).map fun nd => PRE_first_tail_x15_r0_body.kappa75.prim nd.prim)
kernel_rfl PRE_first_tail_x15_r0_body.fnordI75 : incrB PRE_first_tail_x15_r0_body.kd75.nodeF (List.range' 16763 27) = true
kernel_rfl PRE_first_tail_x15_r0_body.fnordK75 : (PTrie.keysA PRE_first_tail_x15_r0_body.kd75.node).all (fun k => Nat.ble 16763 k && Nat.blt k 16790) = true
kernel_rfl PRE_first_tail_x15_r0_body.fnordL75 : (PRE_first_tail_x15_r0_body.cln75.filter (Nat.ble PRE_first_tail_x15_r0_body.P75.N0)).all (fun i => Nat.ble i (PRE_first_tail_x15_r0_body.kd75.nodeF i) && (Nat.blt i 16790 || Nat.ble PRE_first_tail_x15_r0_body.kd75.nn0 i)) = true
theorem PRE_first_tail_x15_r0_body.fnord75 : (PRE_first_tail_x15_r0_body.cln75.filter (Nat.ble PRE_first_tail_x15_r0_body.P75.N0)).all (fun i => Nat.ble i (PRE_first_tail_x15_r0_body.kd75.nodeF i) &&
    (PTrie.keysA PRE_first_tail_x15_r0_body.kd75.node).all fun j => !Nat.blt j i || Nat.blt (PRE_first_tail_x15_r0_body.kd75.nodeF j) (PRE_first_tail_x15_r0_body.kd75.nodeF i)) = true :=
  cnord_of PRE_first_tail_x15_r0_body.cnlow75 PRE_first_tail_x15_r0_body.cnn175 PRE_first_tail_x15_r0_body.fnordI75 PRE_first_tail_x15_r0_body.fnordK75 PRE_first_tail_x15_r0_body.fnordL75
kernel_rfl PRE_first_tail_x15_r0_body.fi75 : PRE_first_tail_x15_r0_body.cli75.all (pnB PRE_first_tail_x15_r0_body.cx0_75.mlx) = true
kernel_rfl PRE_first_tail_x15_r0_body.fii75 : PRE_first_tail_x15_r0_body.cli75.all (fun k => decide (PRE_first_tail_x15_r0_body.cx1_75.mlx.items.get (PRE_first_tail_x15_r0_body.kappa75.node k) = (PRE_first_tail_x15_r0_body.cx0_75.mlx.items.get k).map PRE_first_tail_x15_r0_body.kappa75.nv)) = true
/-- **The compaction's footprint.** -/
theorem PRE_first_tail_x15_r0_body.cfoot75 (clean : Conv.NClean (⟨19689, 16763, 2734215, 3290⟩ : Conv.Cnt) (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s671.ffi).mlx) (hltC : ∀ h, PH (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s671.ffi).mlx h → h < (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s671.ffi).mlx.next) (nltC : ∀ i, PN (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s671.ffi).mlx i → i < (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s671.ffi).mlx.nnext) (itemsC : ∀ k v, (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s671.ffi).mlx.items.get k = some v → PN (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s671.ffi).mlx k) (tracedC : ∀ h o, (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s671.ffi).mlx.objs.get h = some o → ∀ i ∈ objTraces o, i < PRE_first_tail_x15_r0_body.P75.NL) (cl : SSt (· < 3308) PRE_first_tail_x15_r0_body.cx0_75.mlx) :
    Conv.MFoot PRE_first_tail_x15_r0_body.P75 3308 PRE_first_tail_x15_r0_body.kappa75 PRE_first_tail_x15_r0_body.kd75 PRE_first_tail_x15_r0_body.khinv75 PRE_first_tail_x15_r0_body.kninv75 (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s671.ffi).mlx PRE_first_tail_x15_r0_body.cx0_75.mlx PRE_first_tail_x15_r0_body.cx1_75.mlx (⟨19689, 16763, 2734215, 3290⟩ : Conv.Cnt) PRE_first_tail_x15_r0_body.clo75 PRE_first_tail_x15_r0_body.cln75 PRE_first_tail_x15_r0_body.cli75 PRE_first_tail_x15_r0_body.cwS75 PRE_first_tail_x15_r0_body.cnS75 PRE_first_tail_x15_r0_body.ciS75 :=
  ⟨rfl, rfl, rfl, PRE_first_tail_x15_r0_body.cnh075, PRE_first_tail_x15_r0_body.cnh175, PRE_first_tail_x15_r0_body.cnn075, PRE_first_tail_x15_r0_body.cnn175, PRE_first_tail_x15_r0_body.cplo75, PRE_first_tail_x15_r0_body.ccnt75, PRE_first_tail_x15_r0_body.cnband75, PRE_first_tail_x15_r0_body.chbelow75, PRE_first_tail_x15_r0_body.chren75, PRE_first_tail_x15_r0_body.cband75, PRE_first_tail_x15_r0_body.cnh1pos75, PRE_first_tail_x15_r0_body.cnren75, PRE_first_tail_x15_r0_body.cnlow75, PRE_first_tail_x15_r0_body.cabs0a75, PRE_first_tail_x15_r0_body.cabs0b75, PRE_first_tail_x15_r0_body.ctok175, PRE_first_tail_x15_r0_body.cpend75, PRE_first_tail_x15_r0_body.cerrh75, PRE_first_tail_x15_r0_body.cfiles75, PRE_first_tail_x15_r0_body.carch75, PRE_first_tail_x15_r0_body.csizes75, PRE_first_tail_x15_r0_body.cwired75, PRE_first_tail_x15_r0_body.cfix75, clean, PRE_first_tail_x15_r0_body.fcxn75, PRE_first_tail_x15_r0_body.fcnn75, hltC, nltC, itemsC, tracedC, cl, PRE_first_tail_x15_r0_body.fle075, PRE_first_tail_x15_r0_body.fnk75, PRE_first_tail_x15_r0_body.ckA75, PRE_first_tail_x15_r0_body.cobjsK75, PRE_first_tail_x15_r0_body.cnodesK75, PRE_first_tail_x15_r0_body.citemsK75, PRE_first_tail_x15_r0_body.f1A75, PRE_first_tail_x15_r0_body.f1O75, PRE_first_tail_x15_r0_body.f1N75, PRE_first_tail_x15_r0_body.f1I75, PRE_first_tail_x15_r0_body.fbd75, PRE_first_tail_x15_r0_body.fincW75, PRE_first_tail_x15_r0_body.fincI75, PRE_first_tail_x15_r0_body.fincN75, PRE_first_tail_x15_r0_body.flnF75, PRE_first_tail_x15_r0_body.fh75, PRE_first_tail_x15_r0_body.fo75, PRE_first_tail_x15_r0_body.fok75, PRE_first_tail_x15_r0_body.fnd75, PRE_first_tail_x15_r0_body.fp75, PRE_first_tail_x15_r0_body.fnord75, PRE_first_tail_x15_r0_body.fi75, PRE_first_tail_x15_r0_body.fii75⟩
theorem PRE_first_tail_x15_r0_body.cnshift75 (clean : Conv.NClean (⟨19689, 16763, 2734215, 3290⟩ : Conv.Cnt) (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s671.ffi).mlx) (hltC : ∀ h, PH (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s671.ffi).mlx h → h < (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s671.ffi).mlx.next) (nltC : ∀ i, PN (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s671.ffi).mlx i → i < (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s671.ffi).mlx.nnext) (itemsC : ∀ k v, (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s671.ffi).mlx.items.get k = some v → PN (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s671.ffi).mlx k) (tracedC : ∀ h o, (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s671.ffi).mlx.objs.get h = some o → ∀ i ∈ objTraces o, i < PRE_first_tail_x15_r0_body.P75.NL) (cl : SSt (· < 3308) PRE_first_tail_x15_r0_body.cx0_75.mlx) : NShift PRE_first_tail_x15_r0_body.P75 3308 PRE_first_tail_x15_r0_body.kappa75 PRE_first_tail_x15_r0_body.cx0_75 PRE_first_tail_x15_r0_body.cx1_75 :=
  Conv.nshift_of_foot (PRE_first_tail_x15_r0_body.cfoot75 clean hltC nltC itemsC tracedC cl) PRE_first_tail_x15_r0_body.chost75 (compact_a_eq PRE_first_tail_x15_r0_body.ckn075 PRE_first_tail_x15_r0_body.ckn175 PRE_first_tail_x15_r0_body.ckheap75 PRE_first_tail_x15_r0_body.ckpl75)

-- the observers: the layers' states at the call, the canonical and the merged state, their footprints and checks
noncomputable def PRE_first_tail_x15_r0_body.fxC_75 : PTrie Unit := (Host.Ts.Sim.Full.freedOf PRE_first_tail_x15_r0_body.s671.ffi).getD PTrie.nil
noncomputable def PRE_first_tail_x15_r0_body.krC_75 : Host.Load.Layers.KRec := (Host.Ts.Sim.Full.krecOf PRE_first_tail_x15_r0_body.s671.ffi).getD Host.Load.Layers.KRec.empty
kernel_rfl PRE_first_tail_x15_r0_body.ofxC_75 : (Host.Ts.Sim.Full.freedOf PRE_first_tail_x15_r0_body.s671.ffi) = some PRE_first_tail_x15_r0_body.fxC_75
kernel_rfl PRE_first_tail_x15_r0_body.okrC_75 : (Host.Ts.Sim.Full.krecOf PRE_first_tail_x15_r0_body.s671.ffi) = some PRE_first_tail_x15_r0_body.krC_75
noncomputable def PRE_first_tail_x15_r0_body.fx0_75 : PTrie Unit := (Host.Ts.Sim.Full.freedOf PRE_first_tail_x15_r0_body.s673.ffi).getD PTrie.nil
noncomputable def PRE_first_tail_x15_r0_body.kr0_75 : Host.Load.Layers.KRec := (Host.Ts.Sim.Full.krecOf PRE_first_tail_x15_r0_body.s673.ffi).getD Host.Load.Layers.KRec.empty
kernel_rfl PRE_first_tail_x15_r0_body.ofx0_75 : (Host.Ts.Sim.Full.freedOf PRE_first_tail_x15_r0_body.s673.ffi) = some PRE_first_tail_x15_r0_body.fx0_75
kernel_rfl PRE_first_tail_x15_r0_body.okr0_75 : (Host.Ts.Sim.Full.krecOf PRE_first_tail_x15_r0_body.s673.ffi) = some PRE_first_tail_x15_r0_body.kr0_75
noncomputable def PRE_first_tail_x15_r0_body.fx1_75 : PTrie Unit := (Host.Ts.Sim.Full.freedOf PRE_first_tail_x15_r0_body.s672.ffi).getD PTrie.nil
noncomputable def PRE_first_tail_x15_r0_body.kr1_75 : Host.Load.Layers.KRec := (Host.Ts.Sim.Full.krecOf PRE_first_tail_x15_r0_body.s672.ffi).getD Host.Load.Layers.KRec.empty
kernel_rfl PRE_first_tail_x15_r0_body.ofx1_75 : (Host.Ts.Sim.Full.freedOf PRE_first_tail_x15_r0_body.s672.ffi) = some PRE_first_tail_x15_r0_body.fx1_75
kernel_rfl PRE_first_tail_x15_r0_body.okr1_75 : (Host.Ts.Sim.Full.krecOf PRE_first_tail_x15_r0_body.s672.ffi) = some PRE_first_tail_x15_r0_body.kr1_75
kernel_rfl PRE_first_tail_x15_r0_body.ff075 : PRE_first_tail_x15_r0_body.fx0_75 = Stage.setAll PRE_first_tail_x15_r0_body.fxC_75 (PRE_first_tail_x15_r0_body.clo75.filterMap fun i => (PRE_first_tail_x15_r0_body.fx0_75.get i).map (i, ·))
kernel_rfl PRE_first_tail_x15_r0_body.ff175 : PRE_first_tail_x15_r0_body.fx1_75 = Stage.setAll PRE_first_tail_x15_r0_body.fxC_75 (PRE_first_tail_x15_r0_body.cwS75.filterMap fun i => (PRE_first_tail_x15_r0_body.fx1_75.get i).map (i, ·))
kernel_rfl PRE_first_tail_x15_r0_body.ffck75 : freedLB PRE_first_tail_x15_r0_body.kappa75 PRE_first_tail_x15_r0_body.cx0_75.mlx PRE_first_tail_x15_r0_body.fx0_75 PRE_first_tail_x15_r0_body.fx1_75 PRE_first_tail_x15_r0_body.clo75 = true
kernel_rfl PRE_first_tail_x15_r0_body.fkf075 : PRE_first_tail_x15_r0_body.kr0_75.flags = Stage.setAll PRE_first_tail_x15_r0_body.krC_75.flags (PRE_first_tail_x15_r0_body.clo75.filterMap fun i => (PRE_first_tail_x15_r0_body.kr0_75.flags.get i).map (i, ·))
kernel_rfl PRE_first_tail_x15_r0_body.fkt075 : PRE_first_tail_x15_r0_body.kr0_75.targs = Stage.setAll PRE_first_tail_x15_r0_body.krC_75.targs (PRE_first_tail_x15_r0_body.clo75.filterMap fun i => (PRE_first_tail_x15_r0_body.kr0_75.targs.get i).map (i, ·))
kernel_rfl PRE_first_tail_x15_r0_body.fkf175 : PRE_first_tail_x15_r0_body.kr1_75.flags = Stage.setAll PRE_first_tail_x15_r0_body.krC_75.flags (PRE_first_tail_x15_r0_body.cwS75.filterMap fun i => (PRE_first_tail_x15_r0_body.kr1_75.flags.get i).map (i, ·))
kernel_rfl PRE_first_tail_x15_r0_body.fkt175 : PRE_first_tail_x15_r0_body.kr1_75.targs = Stage.setAll PRE_first_tail_x15_r0_body.krC_75.targs (PRE_first_tail_x15_r0_body.cwS75.filterMap fun i => (PRE_first_tail_x15_r0_body.kr1_75.targs.get i).map (i, ·))
kernel_rfl PRE_first_tail_x15_r0_body.fkck75 : krecLB PRE_first_tail_x15_r0_body.kappa75 3308 PRE_first_tail_x15_r0_body.cx0_75.mlx PRE_first_tail_x15_r0_body.kr0_75 PRE_first_tail_x15_r0_body.kr1_75 PRE_first_tail_x15_r0_body.clo75 = true
kernel_rfl PRE_first_tail_x15_r0_body.fkn75 : Nat.ble 3290 3308 = true
-- the bridge and the pending traces' regions
kernel_rfl PRE_first_tail_x15_r0_body.cbridge75 : Host.Ts.Sim.Full.bridgeOf PRE_first_tail_x15_r0_body.s672.ffi = Host.Ts.Sim.Full.bridgeOf PRE_first_tail_x15_r0_body.s673.ffi
kernel_rfl PRE_first_tail_x15_r0_body.cpendR75 : pendRegB PRE_first_tail_x15_r0_body.kappa75 (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s673.ffi).mlx = true
kernel_rfl PRE_first_tail_x15_r0_body.cpendLe75 : Nat.ble (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s673.ffi).mlx.next (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s672.ffi).mlx.next = true
/-- **The compaction's native shift**, given the call's bookkeeping, its relation's facts (the model's and the
observers') and the canonical closedness. -/
theorem PRE_first_tail_x15_r0_body.cshift75 (clean : Conv.NClean (⟨19689, 16763, 2734215, 3290⟩ : Conv.Cnt) (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s671.ffi).mlx) (hltC : ∀ h, PH (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s671.ffi).mlx h → h < (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s671.ffi).mlx.next) (nltC : ∀ i, PN (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s671.ffi).mlx i → i < (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s671.ffi).mlx.nnext) (itemsC : ∀ k v, (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s671.ffi).mlx.items.get k = some v → PN (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s671.ffi).mlx k) (tracedC : ∀ h o, (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s671.ffi).mlx.objs.get h = some o → ∀ i ∈ objTraces o, i < PRE_first_tail_x15_r0_body.P75.NL) (cl : SSt (· < 3308) PRE_first_tail_x15_r0_body.cx0_75.mlx)
    (hobjC : ∀ h, PRE_first_tail_x15_r0_body.fxC_75.get h = some () → ((Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s671.ffi).mlx.objs.get h).isSome = true)
    (hfC : ∀ h, (PRE_first_tail_x15_r0_body.krC_75.flags.get h).isSome = true → ((Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s671.ffi).mlx.objs.get h).isSome = true)
    (htC : ∀ h, (PRE_first_tail_x15_r0_body.krC_75.targs.get h).isSome = true → ((Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s671.ffi).mlx.objs.get h).isSome = true)
    (hclC : ∀ h l, PRE_first_tail_x15_r0_body.krC_75.targs.get h = some l → Host.Ts.Sim.Full.STargs (· < (⟨19689, 16763, 2734215, 3290⟩ : Conv.Cnt).n) l) :
    Conv.FullShiftQ PRE_first_tail_x15_r0_body.P75 3308 PRE_first_tail_x15_r0_body.kappa75 PRE_first_tail_x15_r0_body.s673.ffi PRE_first_tail_x15_r0_body.s672.ffi :=
  ⟨PRE_first_tail_x15_r0_body.cnshift75 clean hltC nltC itemsC tracedC cl, PRE_first_tail_x15_r0_body.cqueue75, fun t ht => bSN_sound (List.all_eq_true.mp PRE_first_tail_x15_r0_body.ctokSupp75 t ht),
    PRE_first_tail_x15_r0_body.cbridge75,
    liveShift_foot (x0' := Host.Ts.Sim.Full.mlxOf PRE_first_tail_x15_r0_body.s673.ffi) (x1' := Host.Ts.Sim.Full.mlxOf PRE_first_tail_x15_r0_body.s672.ffi) (PRE_first_tail_x15_r0_body.cfoot75 clean hltC nltC itemsC tracedC cl) rfl PRE_first_tail_x15_r0_body.ofx0_75 PRE_first_tail_x15_r0_body.ofx1_75 hobjC PRE_first_tail_x15_r0_body.ff075 PRE_first_tail_x15_r0_body.ff175 PRE_first_tail_x15_r0_body.ffck75,
    kernShift_foot (x0' := Host.Ts.Sim.Full.mlxOf PRE_first_tail_x15_r0_body.s673.ffi) (x1' := Host.Ts.Sim.Full.mlxOf PRE_first_tail_x15_r0_body.s672.ffi) (PRE_first_tail_x15_r0_body.cfoot75 clean hltC nltC itemsC tracedC cl) rfl PRE_first_tail_x15_r0_body.okr0_75 PRE_first_tail_x15_r0_body.okr1_75 (Nat.le_of_ble_eq_true PRE_first_tail_x15_r0_body.fkn75) hfC htC hclC
      PRE_first_tail_x15_r0_body.fkf075 PRE_first_tail_x15_r0_body.fkt075 PRE_first_tail_x15_r0_body.fkf175 PRE_first_tail_x15_r0_body.fkt175 PRE_first_tail_x15_r0_body.fkck75,
    pendReg_of rfl PRE_first_tail_x15_r0_body.cnh075 PRE_first_tail_x15_r0_body.cnh175 (Nat.le_of_ble_eq_true PRE_first_tail_x15_r0_body.cpendLe75) PRE_first_tail_x15_r0_body.cpendR75⟩

end Host.Load.Run.Tpl
