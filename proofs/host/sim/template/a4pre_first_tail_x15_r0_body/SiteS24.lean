import host.sim.template.a4pre_first_tail_x15_r0_body.SiteCl24
import host.sim.conv.CompactFull
import host.sim.template.FootGen
set_option Elab.async false
namespace Host.Load.Run.Tpl
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
open Host.Ts Host.Ts.Sim Host.Ts.Sim.Template

/-! The compaction's native shift at call site 24 from its footprint (`Conv.nshift_of_foot`), and the observers'
(`liveShift_foot`, `kernShift_foot`): `Conv.FullShiftQ` for `Conv.full_compactQ`, given the call's bookkeeping and its
relation's facts. -/

/-- The load parameters of the chain (band-free: its start's node counter as `NL` and `N0`). -/
def PRE_first_tail_x15_r0_body.Pc24 : LoadP := ⟨18151, 131072, 1099511627776, 15235, 15235, []⟩
/-- The site's band raised to the map's checked fixed-node prefix, including newly recorded closure traces. -/
def PRE_first_tail_x15_r0_body.P24 : LoadP := PRE_first_tail_x15_r0_body.Pc24.raise 15779
kernel_rfl PRE_first_tail_x15_r0_body.craise24 : Nat.ble PRE_first_tail_x15_r0_body.Pc24.N0 15779 = true
theorem PRE_first_tail_x15_r0_body.raised24 : Host.Ts.Sim.Full.Raised PRE_first_tail_x15_r0_body.Pc24 PRE_first_tail_x15_r0_body.P24 :=
  .inr ⟨15779, rfl, Nat.le_of_ble_eq_true PRE_first_tail_x15_r0_body.craise24, rfl⟩
noncomputable abbrev PRE_first_tail_x15_r0_body.cx0_24 : Host.Load.LSt := clearTokens (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s248.ffi)
noncomputable abbrev PRE_first_tail_x15_r0_body.cx1_24 : Host.Load.LSt := clearTokens (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s247.ffi)
def PRE_first_tail_x15_r0_body.khinv24 : PTrie Nat := Stage.setAll PTrie.nil [(18714, 18688), (18692, 18689), (18715, 18690)]
def PRE_first_tail_x15_r0_body.kninv24 : PTrie Nat := Stage.setAll PTrie.nil [(15752, 15752), (15753, 15753), (15754, 15754), (15755, 15755), (15756, 15756), (15757, 15757), (15758, 15758), (15759, 15759), (15760, 15760), (15761, 15761), (15762, 15762), (15763, 15763), (15764, 15764), (15765, 15765), (15766, 15766), (15767, 15767), (15768, 15768), (15769, 15769), (15770, 15770), (15771, 15771), (15772, 15772), (15773, 15773), (15774, 15774), (15775, 15775), (15776, 15776), (15777, 15777), (15778, 15778)]
/-- The stage's footprint: its written and fresh handles, fresh nodes, written and fresh items. -/
def PRE_first_tail_x15_r0_body.cwS24 : List Nat := [18668, 18681, 18687, 18688, 18689, 18690, 18691, 18692, 18693, 18694, 18695, 18696, 18697, 18698, 18699, 18700, 18701, 18702, 18703, 18704, 18705, 18706, 18707, 18708, 18709, 18710, 18711, 18712, 18713, 18714, 18715]
def PRE_first_tail_x15_r0_body.cnS24 : List Nat := List.range' 15752 27
def PRE_first_tail_x15_r0_body.ciS24 : List Nat := [] ++ List.range' 15752 27

-- the small checks (`MChecks`'s)
kernel_rfl PRE_first_tail_x15_r0_body.cnh024 : PRE_first_tail_x15_r0_body.kd24.nh0 = PRE_first_tail_x15_r0_body.cx0_24.mlx.next
kernel_rfl PRE_first_tail_x15_r0_body.cnh124 : PRE_first_tail_x15_r0_body.kd24.nh1 = PRE_first_tail_x15_r0_body.cx1_24.mlx.next
kernel_rfl PRE_first_tail_x15_r0_body.cnn024 : PRE_first_tail_x15_r0_body.kd24.nn0 = PRE_first_tail_x15_r0_body.cx0_24.mlx.nnext
kernel_rfl PRE_first_tail_x15_r0_body.cnn124 : PRE_first_tail_x15_r0_body.kd24.nn1 = PRE_first_tail_x15_r0_body.cx1_24.mlx.nnext
kernel_rfl PRE_first_tail_x15_r0_body.cplo24 : (Nat.blt 0 PRE_first_tail_x15_r0_body.P24.lo && Nat.ble PRE_first_tail_x15_r0_body.P24.lo PRE_first_tail_x15_r0_body.cx0_24.mlx.next && Nat.ble PRE_first_tail_x15_r0_body.P24.lo RData.bigHi && Nat.ble RData.bigHi PRE_first_tail_x15_r0_body.P24.E) = true
kernel_rfl PRE_first_tail_x15_r0_body.ccnt24 : (Nat.ble PRE_first_tail_x15_r0_body.cx0_24.mlx.next PRE_first_tail_x15_r0_body.cx1_24.mlx.next && Nat.ble PRE_first_tail_x15_r0_body.cx0_24.mlx.nnext PRE_first_tail_x15_r0_body.cx1_24.mlx.nnext) = true
kernel_rfl PRE_first_tail_x15_r0_body.cnband24 : (Nat.blt 0 PRE_first_tail_x15_r0_body.P24.NL && Nat.ble PRE_first_tail_x15_r0_body.P24.NL PRE_first_tail_x15_r0_body.P24.N0 && Nat.ble PRE_first_tail_x15_r0_body.P24.N0 PRE_first_tail_x15_r0_body.cx0_24.mlx.nnext) = true
kernel_rfl PRE_first_tail_x15_r0_body.chbelow24 : PRE_first_tail_x15_r0_body.kd24.checkHndBelow = true
kernel_rfl PRE_first_tail_x15_r0_body.chren24 : checkRenG PRE_first_tail_x15_r0_body.kd24.hnd PRE_first_tail_x15_r0_body.khinv24 (phB PRE_first_tail_x15_r0_body.cx0_24.mlx) = true
kernel_rfl PRE_first_tail_x15_r0_body.cband24 : PRE_first_tail_x15_r0_body.kd24.checkBand PRE_first_tail_x15_r0_body.P24.lo = true
kernel_rfl PRE_first_tail_x15_r0_body.cnh1pos24 : Nat.blt 0 PRE_first_tail_x15_r0_body.kd24.nh1 = true
kernel_rfl PRE_first_tail_x15_r0_body.cnren24 : checkRenG PRE_first_tail_x15_r0_body.kd24.node PRE_first_tail_x15_r0_body.kninv24 (pnB PRE_first_tail_x15_r0_body.cx0_24.mlx) = true
kernel_rfl PRE_first_tail_x15_r0_body.cnlow24 : (PTrie.keysA PRE_first_tail_x15_r0_body.kd24.node).all (fun j => Nat.ble PRE_first_tail_x15_r0_body.P24.NL j && Nat.blt (PRE_first_tail_x15_r0_body.kd24.nodeF j) PRE_first_tail_x15_r0_body.cx1_24.mlx.nnext) = true
kernel_rfl PRE_first_tail_x15_r0_body.cabs0a24 : PRE_first_tail_x15_r0_body.cx0_24.mlx.arrs.get 0 = none
kernel_rfl PRE_first_tail_x15_r0_body.cabs0b24 : PRE_first_tail_x15_r0_body.cx0_24.mlx.objs.get 0 = none
kernel_rfl PRE_first_tail_x15_r0_body.ctok124 : PRE_first_tail_x15_r0_body.cx1_24.mlx.tokens = []
kernel_rfl PRE_first_tail_x15_r0_body.cpend24 : PRE_first_tail_x15_r0_body.cx1_24.mlx.pending = PRE_first_tail_x15_r0_body.cx0_24.mlx.pending.map PRE_first_tail_x15_r0_body.kappa24.pend
kernel_rfl PRE_first_tail_x15_r0_body.cerrh24 : PRE_first_tail_x15_r0_body.cx1_24.mlx.errh = PRE_first_tail_x15_r0_body.cx0_24.mlx.errh.map PRE_first_tail_x15_r0_body.kappa24.arg
kernel_rfl PRE_first_tail_x15_r0_body.cfiles24 : PRE_first_tail_x15_r0_body.cx1_24.mlx.files = PRE_first_tail_x15_r0_body.cx0_24.mlx.files
kernel_rfl PRE_first_tail_x15_r0_body.carch24 : PRE_first_tail_x15_r0_body.cx1_24.mlx.arch = PRE_first_tail_x15_r0_body.cx0_24.mlx.arch
kernel_rfl PRE_first_tail_x15_r0_body.csizes24 : PRE_first_tail_x15_r0_body.cx1_24.mlx.deviceSizes = PRE_first_tail_x15_r0_body.cx0_24.mlx.deviceSizes
kernel_rfl PRE_first_tail_x15_r0_body.cwired24 : PRE_first_tail_x15_r0_body.cx1_24.mlx.wired = PRE_first_tail_x15_r0_body.cx0_24.mlx.wired
kernel_rfl PRE_first_tail_x15_r0_body.chost24 : PRE_first_tail_x15_r0_body.cx1_24.host = PRE_first_tail_x15_r0_body.cx0_24.host
-- the compaction map's addresses are `PRE_first_tail_x15_r0_body.kd24`'s
kernel_rfl PRE_first_tail_x15_r0_body.ckn024 : PRE_first_tail_x15_r0_body.kd24.n0 = 2694293
kernel_rfl PRE_first_tail_x15_r0_body.ckn124 : PRE_first_tail_x15_r0_body.kd24.n1 = 2695442
kernel_rfl PRE_first_tail_x15_r0_body.ckheap24 : (PTrie.keysA PRE_first_tail_x15_r0_body.kd24.heap).all (fun x => Nat.ble 2694287 x) = true
kernel_rfl PRE_first_tail_x15_r0_body.ckpl24 : (List.range 6).all (fun j => decide (PRE_first_tail_x15_r0_body.kd24.heap.get (2694287 + j) = nth? PRE_first_tail_x15_r0_body.pl24 j)) = true
-- the map fixes the call's names (`Conv.fixOld_compact`), the call's counters
kernel_rfl PRE_first_tail_x15_r0_body.fja24 : Nat.ble 2694287 2694287 = true
kernel_rfl PRE_first_tail_x15_r0_body.fn24 : Nat.ble 1109 1109 = true
kernel_rfl PRE_first_tail_x15_r0_body.fjaD24 : Nat.ble 2694287 PRE_first_tail_x15_r0_body.kd24.n0 = true
kernel_rfl PRE_first_tail_x15_r0_body.fxn24 : Nat.ble 18688 PRE_first_tail_x15_r0_body.kd24.nh0 = true
kernel_rfl PRE_first_tail_x15_r0_body.fnn24 : Nat.ble 15752 PRE_first_tail_x15_r0_body.kd24.nn0 = true
kernel_rfl PRE_first_tail_x15_r0_body.fxb24 : Nat.ble 18688 RData.bigHi = true
kernel_rfl PRE_first_tail_x15_r0_body.fheap24 : (PTrie.keysA PRE_first_tail_x15_r0_body.kd24.heap).all (Nat.ble (⟨18688, 15752, 2694287, 1109⟩ : Conv.Cnt).ja) = true
kernel_rfl PRE_first_tail_x15_r0_body.fhnd24 : (PTrie.keysA PRE_first_tail_x15_r0_body.kd24.hnd).all (Nat.ble (⟨18688, 15752, 2694287, 1109⟩ : Conv.Cnt).xn) = true
kernel_rfl PRE_first_tail_x15_r0_body.fnode24 : (PTrie.keysA PRE_first_tail_x15_r0_body.kd24.node).all (Nat.ble (⟨18688, 15752, 2694287, 1109⟩ : Conv.Cnt).nn) = true
/-- The compaction map fixes the call's names. -/
theorem PRE_first_tail_x15_r0_body.cfix24 : Conv.FixOld (⟨18688, 15752, 2694287, 1109⟩ : Conv.Cnt) PRE_first_tail_x15_r0_body.kappa24 :=
  Conv.fixOld_compact (Nat.le_of_ble_eq_true PRE_first_tail_x15_r0_body.fja24) (Nat.le_of_ble_eq_true PRE_first_tail_x15_r0_body.fn24) (Nat.le_of_ble_eq_true PRE_first_tail_x15_r0_body.fjaD24) (Nat.le_of_ble_eq_true PRE_first_tail_x15_r0_body.fxn24) (Nat.le_of_ble_eq_true PRE_first_tail_x15_r0_body.fnn24) (Nat.le_of_ble_eq_true PRE_first_tail_x15_r0_body.fxb24) PRE_first_tail_x15_r0_body.fheap24 PRE_first_tail_x15_r0_body.fhnd24 PRE_first_tail_x15_r0_body.fnode24
kernel_rfl PRE_first_tail_x15_r0_body.fcxn24 : (⟨18688, 15752, 2694287, 1109⟩ : Conv.Cnt).xn = (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s246.ffi).mlx.next
kernel_rfl PRE_first_tail_x15_r0_body.fcnn24 : (⟨18688, 15752, 2694287, 1109⟩ : Conv.Cnt).nn = (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s246.ffi).mlx.nnext
kernel_rfl PRE_first_tail_x15_r0_body.fle024 : (Nat.ble (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s246.ffi).mlx.next PRE_first_tail_x15_r0_body.cx0_24.mlx.next && Nat.ble (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s246.ffi).mlx.nnext PRE_first_tail_x15_r0_body.cx0_24.mlx.nnext && Nat.ble (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s246.ffi).mlx.next RData.bigHi) = true
kernel_rfl PRE_first_tail_x15_r0_body.fnk24 : (PTrie.keysA PRE_first_tail_x15_r0_body.kd24.node).all (Nat.ble (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s246.ffi).mlx.nnext) = true
-- the merged state keeps the call's entries off the stage's footprint
kernel_rfl PRE_first_tail_x15_r0_body.f1A24 : PRE_first_tail_x15_r0_body.cx1_24.mlx.arrs = Stage.setAll (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s246.ffi).mlx.arrs (PRE_first_tail_x15_r0_body.cwS24.filterMap fun i => (PRE_first_tail_x15_r0_body.cx1_24.mlx.arrs.get i).map (i, ·))
kernel_rfl PRE_first_tail_x15_r0_body.f1O24 : PRE_first_tail_x15_r0_body.cx1_24.mlx.objs = Stage.setAll (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s246.ffi).mlx.objs (PRE_first_tail_x15_r0_body.cwS24.filterMap fun i => (PRE_first_tail_x15_r0_body.cx1_24.mlx.objs.get i).map (i, ·))
kernel_rfl PRE_first_tail_x15_r0_body.f1N24 : PRE_first_tail_x15_r0_body.cx1_24.mlx.nodes = Stage.setAll (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s246.ffi).mlx.nodes (PRE_first_tail_x15_r0_body.cnS24.filterMap fun i => (PRE_first_tail_x15_r0_body.cx1_24.mlx.nodes.get i).map (i, ·))
kernel_rfl PRE_first_tail_x15_r0_body.f1I24 : PRE_first_tail_x15_r0_body.cx1_24.mlx.items = Stage.setAll (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s246.ffi).mlx.items (PRE_first_tail_x15_r0_body.ciS24.filterMap fun i => (PRE_first_tail_x15_r0_body.cx1_24.mlx.items.get i).map (i, ·))
kernel_rfl PRE_first_tail_x15_r0_body.fbd24 : (PRE_first_tail_x15_r0_body.clo24 ++ PRE_first_tail_x15_r0_body.cln24 ++ PRE_first_tail_x15_r0_body.cli24 ++ PRE_first_tail_x15_r0_body.cwS24 ++ PRE_first_tail_x15_r0_body.cnS24 ++ PRE_first_tail_x15_r0_body.ciS24).all (fun i => Nat.blt (i / 4096) (4 ^ 31)) = true
kernel_rfl PRE_first_tail_x15_r0_body.fincW24 : PRE_first_tail_x15_r0_body.cwS24.all (fun h => !Nat.blt h (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s246.ffi).mlx.next || PRE_first_tail_x15_r0_body.clo24.contains h) = true
kernel_rfl PRE_first_tail_x15_r0_body.fincI24 : PRE_first_tail_x15_r0_body.ciS24.all (fun k => !Nat.blt k (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s246.ffi).mlx.nnext || PRE_first_tail_x15_r0_body.cli24.contains k) = true
kernel_rfl PRE_first_tail_x15_r0_body.fincN24 : PRE_first_tail_x15_r0_body.cnS24.all (Nat.ble (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s246.ffi).mlx.nnext) = true
kernel_rfl PRE_first_tail_x15_r0_body.flnF24 : PRE_first_tail_x15_r0_body.cln24.all (Nat.ble (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s246.ffi).mlx.nnext) = true
-- the checks over the changed lists
kernel_rfl PRE_first_tail_x15_r0_body.fh24 : PRE_first_tail_x15_r0_body.clo24.all (handleOK PRE_first_tail_x15_r0_body.kappa24 PRE_first_tail_x15_r0_body.P24.lo PRE_first_tail_x15_r0_body.cx0_24.mlx PRE_first_tail_x15_r0_body.cx1_24.mlx) = true
kernel_rfl PRE_first_tail_x15_r0_body.fo24 : PRE_first_tail_x15_r0_body.clo24.map (fun h => PRE_first_tail_x15_r0_body.cx1_24.mlx.objs.get (PRE_first_tail_x15_r0_body.kappa24.handle h)) = PRE_first_tail_x15_r0_body.clo24.map (fun h => (PRE_first_tail_x15_r0_body.cx0_24.mlx.objs.get h).map PRE_first_tail_x15_r0_body.kappa24.nobj)
kernel_rfl PRE_first_tail_x15_r0_body.fok24 : PRE_first_tail_x15_r0_body.clo24.all (objOK PRE_first_tail_x15_r0_body.kappa24 PRE_first_tail_x15_r0_body.P24.NL PRE_first_tail_x15_r0_body.cx0_24.mlx) = true
kernel_rfl PRE_first_tail_x15_r0_body.fnd24 : PRE_first_tail_x15_r0_body.cln24.all (nodeOKF PRE_first_tail_x15_r0_body.kappa24 PRE_first_tail_x15_r0_body.P24 PRE_first_tail_x15_r0_body.cx0_24.mlx PRE_first_tail_x15_r0_body.cx1_24.mlx) = true
kernel_rfl PRE_first_tail_x15_r0_body.fp24 : ((PRE_first_tail_x15_r0_body.cln24.filter (fullB PRE_first_tail_x15_r0_body.P24))).map (fun i => (PRE_first_tail_x15_r0_body.cx1_24.mlx.nodes.get (PRE_first_tail_x15_r0_body.kappa24.node i)).map Host.Mlx.Ffi.Node.prim) =
  ((PRE_first_tail_x15_r0_body.cln24.filter (fullB PRE_first_tail_x15_r0_body.P24))).map (fun i => (PRE_first_tail_x15_r0_body.cx0_24.mlx.nodes.get i).map fun nd => PRE_first_tail_x15_r0_body.kappa24.prim nd.prim)
kernel_rfl PRE_first_tail_x15_r0_body.fnordI24 : incrB PRE_first_tail_x15_r0_body.kd24.nodeF (List.range' 15752 27) = true
kernel_rfl PRE_first_tail_x15_r0_body.fnordK24 : (PTrie.keysA PRE_first_tail_x15_r0_body.kd24.node).all (fun k => Nat.ble 15752 k && Nat.blt k 15779) = true
kernel_rfl PRE_first_tail_x15_r0_body.fnordL24 : (PRE_first_tail_x15_r0_body.cln24.filter (Nat.ble PRE_first_tail_x15_r0_body.P24.N0)).all (fun i => Nat.ble i (PRE_first_tail_x15_r0_body.kd24.nodeF i) && (Nat.blt i 15779 || Nat.ble PRE_first_tail_x15_r0_body.kd24.nn0 i)) = true
theorem PRE_first_tail_x15_r0_body.fnord24 : (PRE_first_tail_x15_r0_body.cln24.filter (Nat.ble PRE_first_tail_x15_r0_body.P24.N0)).all (fun i => Nat.ble i (PRE_first_tail_x15_r0_body.kd24.nodeF i) &&
    (PTrie.keysA PRE_first_tail_x15_r0_body.kd24.node).all fun j => !Nat.blt j i || Nat.blt (PRE_first_tail_x15_r0_body.kd24.nodeF j) (PRE_first_tail_x15_r0_body.kd24.nodeF i)) = true :=
  cnord_of PRE_first_tail_x15_r0_body.cnlow24 PRE_first_tail_x15_r0_body.cnn124 PRE_first_tail_x15_r0_body.fnordI24 PRE_first_tail_x15_r0_body.fnordK24 PRE_first_tail_x15_r0_body.fnordL24
kernel_rfl PRE_first_tail_x15_r0_body.fi24 : PRE_first_tail_x15_r0_body.cli24.all (pnB PRE_first_tail_x15_r0_body.cx0_24.mlx) = true
kernel_rfl PRE_first_tail_x15_r0_body.fii24 : PRE_first_tail_x15_r0_body.cli24.all (fun k => decide (PRE_first_tail_x15_r0_body.cx1_24.mlx.items.get (PRE_first_tail_x15_r0_body.kappa24.node k) = (PRE_first_tail_x15_r0_body.cx0_24.mlx.items.get k).map PRE_first_tail_x15_r0_body.kappa24.nv)) = true
/-- **The compaction's footprint.** -/
theorem PRE_first_tail_x15_r0_body.cfoot24 (clean : Conv.NClean (⟨18688, 15752, 2694287, 1109⟩ : Conv.Cnt) (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s246.ffi).mlx) (hltC : ∀ h, PH (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s246.ffi).mlx h → h < (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s246.ffi).mlx.next) (nltC : ∀ i, PN (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s246.ffi).mlx i → i < (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s246.ffi).mlx.nnext) (itemsC : ∀ k v, (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s246.ffi).mlx.items.get k = some v → PN (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s246.ffi).mlx k) (tracedC : ∀ h o, (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s246.ffi).mlx.objs.get h = some o → ∀ i ∈ objTraces o, i < PRE_first_tail_x15_r0_body.P24.NL) (cl : SSt (· < 1127) PRE_first_tail_x15_r0_body.cx0_24.mlx) :
    Conv.MFoot PRE_first_tail_x15_r0_body.P24 1127 PRE_first_tail_x15_r0_body.kappa24 PRE_first_tail_x15_r0_body.kd24 PRE_first_tail_x15_r0_body.khinv24 PRE_first_tail_x15_r0_body.kninv24 (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s246.ffi).mlx PRE_first_tail_x15_r0_body.cx0_24.mlx PRE_first_tail_x15_r0_body.cx1_24.mlx (⟨18688, 15752, 2694287, 1109⟩ : Conv.Cnt) PRE_first_tail_x15_r0_body.clo24 PRE_first_tail_x15_r0_body.cln24 PRE_first_tail_x15_r0_body.cli24 PRE_first_tail_x15_r0_body.cwS24 PRE_first_tail_x15_r0_body.cnS24 PRE_first_tail_x15_r0_body.ciS24 :=
  ⟨rfl, rfl, rfl, PRE_first_tail_x15_r0_body.cnh024, PRE_first_tail_x15_r0_body.cnh124, PRE_first_tail_x15_r0_body.cnn024, PRE_first_tail_x15_r0_body.cnn124, PRE_first_tail_x15_r0_body.cplo24, PRE_first_tail_x15_r0_body.ccnt24, PRE_first_tail_x15_r0_body.cnband24, PRE_first_tail_x15_r0_body.chbelow24, PRE_first_tail_x15_r0_body.chren24, PRE_first_tail_x15_r0_body.cband24, PRE_first_tail_x15_r0_body.cnh1pos24, PRE_first_tail_x15_r0_body.cnren24, PRE_first_tail_x15_r0_body.cnlow24, PRE_first_tail_x15_r0_body.cabs0a24, PRE_first_tail_x15_r0_body.cabs0b24, PRE_first_tail_x15_r0_body.ctok124, PRE_first_tail_x15_r0_body.cpend24, PRE_first_tail_x15_r0_body.cerrh24, PRE_first_tail_x15_r0_body.cfiles24, PRE_first_tail_x15_r0_body.carch24, PRE_first_tail_x15_r0_body.csizes24, PRE_first_tail_x15_r0_body.cwired24, PRE_first_tail_x15_r0_body.cfix24, clean, PRE_first_tail_x15_r0_body.fcxn24, PRE_first_tail_x15_r0_body.fcnn24, hltC, nltC, itemsC, tracedC, cl, PRE_first_tail_x15_r0_body.fle024, PRE_first_tail_x15_r0_body.fnk24, PRE_first_tail_x15_r0_body.ckA24, PRE_first_tail_x15_r0_body.cobjsK24, PRE_first_tail_x15_r0_body.cnodesK24, PRE_first_tail_x15_r0_body.citemsK24, PRE_first_tail_x15_r0_body.f1A24, PRE_first_tail_x15_r0_body.f1O24, PRE_first_tail_x15_r0_body.f1N24, PRE_first_tail_x15_r0_body.f1I24, PRE_first_tail_x15_r0_body.fbd24, PRE_first_tail_x15_r0_body.fincW24, PRE_first_tail_x15_r0_body.fincI24, PRE_first_tail_x15_r0_body.fincN24, PRE_first_tail_x15_r0_body.flnF24, PRE_first_tail_x15_r0_body.fh24, PRE_first_tail_x15_r0_body.fo24, PRE_first_tail_x15_r0_body.fok24, PRE_first_tail_x15_r0_body.fnd24, PRE_first_tail_x15_r0_body.fp24, PRE_first_tail_x15_r0_body.fnord24, PRE_first_tail_x15_r0_body.fi24, PRE_first_tail_x15_r0_body.fii24⟩
theorem PRE_first_tail_x15_r0_body.cnshift24 (clean : Conv.NClean (⟨18688, 15752, 2694287, 1109⟩ : Conv.Cnt) (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s246.ffi).mlx) (hltC : ∀ h, PH (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s246.ffi).mlx h → h < (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s246.ffi).mlx.next) (nltC : ∀ i, PN (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s246.ffi).mlx i → i < (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s246.ffi).mlx.nnext) (itemsC : ∀ k v, (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s246.ffi).mlx.items.get k = some v → PN (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s246.ffi).mlx k) (tracedC : ∀ h o, (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s246.ffi).mlx.objs.get h = some o → ∀ i ∈ objTraces o, i < PRE_first_tail_x15_r0_body.P24.NL) (cl : SSt (· < 1127) PRE_first_tail_x15_r0_body.cx0_24.mlx) : NShift PRE_first_tail_x15_r0_body.P24 1127 PRE_first_tail_x15_r0_body.kappa24 PRE_first_tail_x15_r0_body.cx0_24 PRE_first_tail_x15_r0_body.cx1_24 :=
  Conv.nshift_of_foot (PRE_first_tail_x15_r0_body.cfoot24 clean hltC nltC itemsC tracedC cl) PRE_first_tail_x15_r0_body.chost24 (compact_a_eq PRE_first_tail_x15_r0_body.ckn024 PRE_first_tail_x15_r0_body.ckn124 PRE_first_tail_x15_r0_body.ckheap24 PRE_first_tail_x15_r0_body.ckpl24)

-- the observers: the layers' states at the call, the canonical and the merged state, their footprints and checks
noncomputable def PRE_first_tail_x15_r0_body.fxC_24 : PTrie Unit := (Host.Ts.Sim.Full.freedOf PRE_first_tail_x15_r0_body.s246.ffi).getD PTrie.nil
noncomputable def PRE_first_tail_x15_r0_body.krC_24 : Host.Load.Layers.KRec := (Host.Ts.Sim.Full.krecOf PRE_first_tail_x15_r0_body.s246.ffi).getD Host.Load.Layers.KRec.empty
kernel_rfl PRE_first_tail_x15_r0_body.ofxC_24 : (Host.Ts.Sim.Full.freedOf PRE_first_tail_x15_r0_body.s246.ffi) = some PRE_first_tail_x15_r0_body.fxC_24
kernel_rfl PRE_first_tail_x15_r0_body.okrC_24 : (Host.Ts.Sim.Full.krecOf PRE_first_tail_x15_r0_body.s246.ffi) = some PRE_first_tail_x15_r0_body.krC_24
noncomputable def PRE_first_tail_x15_r0_body.fx0_24 : PTrie Unit := (Host.Ts.Sim.Full.freedOf PRE_first_tail_x15_r0_body.s248.ffi).getD PTrie.nil
noncomputable def PRE_first_tail_x15_r0_body.kr0_24 : Host.Load.Layers.KRec := (Host.Ts.Sim.Full.krecOf PRE_first_tail_x15_r0_body.s248.ffi).getD Host.Load.Layers.KRec.empty
kernel_rfl PRE_first_tail_x15_r0_body.ofx0_24 : (Host.Ts.Sim.Full.freedOf PRE_first_tail_x15_r0_body.s248.ffi) = some PRE_first_tail_x15_r0_body.fx0_24
kernel_rfl PRE_first_tail_x15_r0_body.okr0_24 : (Host.Ts.Sim.Full.krecOf PRE_first_tail_x15_r0_body.s248.ffi) = some PRE_first_tail_x15_r0_body.kr0_24
noncomputable def PRE_first_tail_x15_r0_body.fx1_24 : PTrie Unit := (Host.Ts.Sim.Full.freedOf PRE_first_tail_x15_r0_body.s247.ffi).getD PTrie.nil
noncomputable def PRE_first_tail_x15_r0_body.kr1_24 : Host.Load.Layers.KRec := (Host.Ts.Sim.Full.krecOf PRE_first_tail_x15_r0_body.s247.ffi).getD Host.Load.Layers.KRec.empty
kernel_rfl PRE_first_tail_x15_r0_body.ofx1_24 : (Host.Ts.Sim.Full.freedOf PRE_first_tail_x15_r0_body.s247.ffi) = some PRE_first_tail_x15_r0_body.fx1_24
kernel_rfl PRE_first_tail_x15_r0_body.okr1_24 : (Host.Ts.Sim.Full.krecOf PRE_first_tail_x15_r0_body.s247.ffi) = some PRE_first_tail_x15_r0_body.kr1_24
kernel_rfl PRE_first_tail_x15_r0_body.ff024 : PRE_first_tail_x15_r0_body.fx0_24 = Stage.setAll PRE_first_tail_x15_r0_body.fxC_24 (PRE_first_tail_x15_r0_body.clo24.filterMap fun i => (PRE_first_tail_x15_r0_body.fx0_24.get i).map (i, ·))
kernel_rfl PRE_first_tail_x15_r0_body.ff124 : PRE_first_tail_x15_r0_body.fx1_24 = Stage.setAll PRE_first_tail_x15_r0_body.fxC_24 (PRE_first_tail_x15_r0_body.cwS24.filterMap fun i => (PRE_first_tail_x15_r0_body.fx1_24.get i).map (i, ·))
kernel_rfl PRE_first_tail_x15_r0_body.ffck24 : freedLB PRE_first_tail_x15_r0_body.kappa24 PRE_first_tail_x15_r0_body.cx0_24.mlx PRE_first_tail_x15_r0_body.fx0_24 PRE_first_tail_x15_r0_body.fx1_24 PRE_first_tail_x15_r0_body.clo24 = true
kernel_rfl PRE_first_tail_x15_r0_body.fkf024 : PRE_first_tail_x15_r0_body.kr0_24.flags = Stage.setAll PRE_first_tail_x15_r0_body.krC_24.flags (PRE_first_tail_x15_r0_body.clo24.filterMap fun i => (PRE_first_tail_x15_r0_body.kr0_24.flags.get i).map (i, ·))
kernel_rfl PRE_first_tail_x15_r0_body.fkt024 : PRE_first_tail_x15_r0_body.kr0_24.targs = Stage.setAll PRE_first_tail_x15_r0_body.krC_24.targs (PRE_first_tail_x15_r0_body.clo24.filterMap fun i => (PRE_first_tail_x15_r0_body.kr0_24.targs.get i).map (i, ·))
kernel_rfl PRE_first_tail_x15_r0_body.fkf124 : PRE_first_tail_x15_r0_body.kr1_24.flags = Stage.setAll PRE_first_tail_x15_r0_body.krC_24.flags (PRE_first_tail_x15_r0_body.cwS24.filterMap fun i => (PRE_first_tail_x15_r0_body.kr1_24.flags.get i).map (i, ·))
kernel_rfl PRE_first_tail_x15_r0_body.fkt124 : PRE_first_tail_x15_r0_body.kr1_24.targs = Stage.setAll PRE_first_tail_x15_r0_body.krC_24.targs (PRE_first_tail_x15_r0_body.cwS24.filterMap fun i => (PRE_first_tail_x15_r0_body.kr1_24.targs.get i).map (i, ·))
kernel_rfl PRE_first_tail_x15_r0_body.fkck24 : krecLB PRE_first_tail_x15_r0_body.kappa24 1127 PRE_first_tail_x15_r0_body.cx0_24.mlx PRE_first_tail_x15_r0_body.kr0_24 PRE_first_tail_x15_r0_body.kr1_24 PRE_first_tail_x15_r0_body.clo24 = true
kernel_rfl PRE_first_tail_x15_r0_body.fkn24 : Nat.ble 1109 1127 = true
-- the bridge and the pending traces' regions
kernel_rfl PRE_first_tail_x15_r0_body.cbridge24 : Host.Ts.Sim.Full.bridgeOf PRE_first_tail_x15_r0_body.s247.ffi = Host.Ts.Sim.Full.bridgeOf PRE_first_tail_x15_r0_body.s248.ffi
kernel_rfl PRE_first_tail_x15_r0_body.cpendR24 : pendRegB PRE_first_tail_x15_r0_body.kappa24 (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s248.ffi).mlx = true
kernel_rfl PRE_first_tail_x15_r0_body.cpendLe24 : Nat.ble (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s248.ffi).mlx.next (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s247.ffi).mlx.next = true
/-- **The compaction's native shift**, given the call's bookkeeping, its relation's facts (the model's and the
observers') and the canonical closedness. -/
theorem PRE_first_tail_x15_r0_body.cshift24 (clean : Conv.NClean (⟨18688, 15752, 2694287, 1109⟩ : Conv.Cnt) (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s246.ffi).mlx) (hltC : ∀ h, PH (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s246.ffi).mlx h → h < (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s246.ffi).mlx.next) (nltC : ∀ i, PN (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s246.ffi).mlx i → i < (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s246.ffi).mlx.nnext) (itemsC : ∀ k v, (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s246.ffi).mlx.items.get k = some v → PN (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s246.ffi).mlx k) (tracedC : ∀ h o, (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s246.ffi).mlx.objs.get h = some o → ∀ i ∈ objTraces o, i < PRE_first_tail_x15_r0_body.P24.NL) (cl : SSt (· < 1127) PRE_first_tail_x15_r0_body.cx0_24.mlx)
    (hobjC : ∀ h, PRE_first_tail_x15_r0_body.fxC_24.get h = some () → ((Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s246.ffi).mlx.objs.get h).isSome = true)
    (hfC : ∀ h, (PRE_first_tail_x15_r0_body.krC_24.flags.get h).isSome = true → ((Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s246.ffi).mlx.objs.get h).isSome = true)
    (htC : ∀ h, (PRE_first_tail_x15_r0_body.krC_24.targs.get h).isSome = true → ((Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s246.ffi).mlx.objs.get h).isSome = true)
    (hclC : ∀ h l, PRE_first_tail_x15_r0_body.krC_24.targs.get h = some l → Host.Ts.Sim.Full.STargs (· < (⟨18688, 15752, 2694287, 1109⟩ : Conv.Cnt).n) l) :
    Conv.FullShiftQ PRE_first_tail_x15_r0_body.P24 1127 PRE_first_tail_x15_r0_body.kappa24 PRE_first_tail_x15_r0_body.s248.ffi PRE_first_tail_x15_r0_body.s247.ffi :=
  ⟨PRE_first_tail_x15_r0_body.cnshift24 clean hltC nltC itemsC tracedC cl, PRE_first_tail_x15_r0_body.cqueue24, fun t ht => bSN_sound (List.all_eq_true.mp PRE_first_tail_x15_r0_body.ctokSupp24 t ht),
    PRE_first_tail_x15_r0_body.cbridge24,
    liveShift_foot (x0' := Host.Ts.Sim.Full.mlxOf PRE_first_tail_x15_r0_body.s248.ffi) (x1' := Host.Ts.Sim.Full.mlxOf PRE_first_tail_x15_r0_body.s247.ffi) (PRE_first_tail_x15_r0_body.cfoot24 clean hltC nltC itemsC tracedC cl) rfl PRE_first_tail_x15_r0_body.ofx0_24 PRE_first_tail_x15_r0_body.ofx1_24 hobjC PRE_first_tail_x15_r0_body.ff024 PRE_first_tail_x15_r0_body.ff124 PRE_first_tail_x15_r0_body.ffck24,
    kernShift_foot (x0' := Host.Ts.Sim.Full.mlxOf PRE_first_tail_x15_r0_body.s248.ffi) (x1' := Host.Ts.Sim.Full.mlxOf PRE_first_tail_x15_r0_body.s247.ffi) (PRE_first_tail_x15_r0_body.cfoot24 clean hltC nltC itemsC tracedC cl) rfl PRE_first_tail_x15_r0_body.okr0_24 PRE_first_tail_x15_r0_body.okr1_24 (Nat.le_of_ble_eq_true PRE_first_tail_x15_r0_body.fkn24) hfC htC hclC
      PRE_first_tail_x15_r0_body.fkf024 PRE_first_tail_x15_r0_body.fkt024 PRE_first_tail_x15_r0_body.fkf124 PRE_first_tail_x15_r0_body.fkt124 PRE_first_tail_x15_r0_body.fkck24,
    pendReg_of rfl PRE_first_tail_x15_r0_body.cnh024 PRE_first_tail_x15_r0_body.cnh124 (Nat.le_of_ble_eq_true PRE_first_tail_x15_r0_body.cpendLe24) PRE_first_tail_x15_r0_body.cpendR24⟩

end Host.Load.Run.Tpl
