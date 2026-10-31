import host.sim.template.a4pre_first_tail_x15_r0_body.SiteCl153
import host.sim.conv.CompactFull
import host.sim.template.FootGen
set_option Elab.async false
namespace Host.Load.Run.Tpl
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
open Host.Ts Host.Ts.Sim Host.Ts.Sim.Template

/-! The compaction's native shift at call site 153 from its footprint (`Conv.nshift_of_foot`), and the observers'
(`liveShift_foot`, `kernShift_foot`): `Conv.FullShiftQ` for `Conv.full_compactQ`, given the call's bookkeeping and its
relation's facts. -/

/-- The load parameters of the chain (band-free: its start's node counter as `NL` and `N0`). -/
def PRE_first_tail_x15_r0_body.Pc153 : LoadP := ⟨18151, 131072, 1099511627776, 15235, 15235, []⟩
/-- The site's band raised to the map's checked fixed-node prefix, including newly recorded closure traces. -/
def PRE_first_tail_x15_r0_body.P153 : LoadP := PRE_first_tail_x15_r0_body.Pc153.raise 18326
kernel_rfl PRE_first_tail_x15_r0_body.craise153 : Nat.ble PRE_first_tail_x15_r0_body.Pc153.N0 18326 = true
theorem PRE_first_tail_x15_r0_body.raised153 : Host.Ts.Sim.Full.Raised PRE_first_tail_x15_r0_body.Pc153 PRE_first_tail_x15_r0_body.P153 :=
  .inr ⟨18326, rfl, Nat.le_of_ble_eq_true PRE_first_tail_x15_r0_body.craise153, rfl⟩
noncomputable abbrev PRE_first_tail_x15_r0_body.cx0_153 : Host.Load.LSt := clearTokens (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1484.ffi)
noncomputable abbrev PRE_first_tail_x15_r0_body.cx1_153 : Host.Load.LSt := clearTokens (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1483.ffi)
def PRE_first_tail_x15_r0_body.khinv153 : PTrie Nat := Stage.setAll PTrie.nil [(21227, 21225), (21228, 21226), (21230, 21227), (21229, 21228)]
def PRE_first_tail_x15_r0_body.kninv153 : PTrie Nat := Stage.setAll PTrie.nil [(18320, 18320), (18321, 18321), (18322, 18322), (18323, 18323), (18324, 18324), (18325, 18325)]
/-- The stage's footprint: its written and fresh handles, fresh nodes, written and fresh items. -/
def PRE_first_tail_x15_r0_body.cwS153 : List Nat := [21225, 21226, 21227, 21228, 21229, 21230]
def PRE_first_tail_x15_r0_body.cnS153 : List Nat := List.range' 18320 6
def PRE_first_tail_x15_r0_body.ciS153 : List Nat := [] ++ List.range' 18320 6

-- the small checks (`MChecks`'s)
kernel_rfl PRE_first_tail_x15_r0_body.cnh0153 : PRE_first_tail_x15_r0_body.kd153.nh0 = PRE_first_tail_x15_r0_body.cx0_153.mlx.next
kernel_rfl PRE_first_tail_x15_r0_body.cnh1153 : PRE_first_tail_x15_r0_body.kd153.nh1 = PRE_first_tail_x15_r0_body.cx1_153.mlx.next
kernel_rfl PRE_first_tail_x15_r0_body.cnn0153 : PRE_first_tail_x15_r0_body.kd153.nn0 = PRE_first_tail_x15_r0_body.cx0_153.mlx.nnext
kernel_rfl PRE_first_tail_x15_r0_body.cnn1153 : PRE_first_tail_x15_r0_body.kd153.nn1 = PRE_first_tail_x15_r0_body.cx1_153.mlx.nnext
kernel_rfl PRE_first_tail_x15_r0_body.cplo153 : (Nat.blt 0 PRE_first_tail_x15_r0_body.P153.lo && Nat.ble PRE_first_tail_x15_r0_body.P153.lo PRE_first_tail_x15_r0_body.cx0_153.mlx.next && Nat.ble PRE_first_tail_x15_r0_body.P153.lo RData.bigHi && Nat.ble RData.bigHi PRE_first_tail_x15_r0_body.P153.E) = true
kernel_rfl PRE_first_tail_x15_r0_body.ccnt153 : (Nat.ble PRE_first_tail_x15_r0_body.cx0_153.mlx.next PRE_first_tail_x15_r0_body.cx1_153.mlx.next && Nat.ble PRE_first_tail_x15_r0_body.cx0_153.mlx.nnext PRE_first_tail_x15_r0_body.cx1_153.mlx.nnext) = true
kernel_rfl PRE_first_tail_x15_r0_body.cnband153 : (Nat.blt 0 PRE_first_tail_x15_r0_body.P153.NL && Nat.ble PRE_first_tail_x15_r0_body.P153.NL PRE_first_tail_x15_r0_body.P153.N0 && Nat.ble PRE_first_tail_x15_r0_body.P153.N0 PRE_first_tail_x15_r0_body.cx0_153.mlx.nnext) = true
kernel_rfl PRE_first_tail_x15_r0_body.chbelow153 : PRE_first_tail_x15_r0_body.kd153.checkHndBelow = true
kernel_rfl PRE_first_tail_x15_r0_body.chren153 : checkRenG PRE_first_tail_x15_r0_body.kd153.hnd PRE_first_tail_x15_r0_body.khinv153 (phB PRE_first_tail_x15_r0_body.cx0_153.mlx) = true
kernel_rfl PRE_first_tail_x15_r0_body.cband153 : PRE_first_tail_x15_r0_body.kd153.checkBand PRE_first_tail_x15_r0_body.P153.lo = true
kernel_rfl PRE_first_tail_x15_r0_body.cnh1pos153 : Nat.blt 0 PRE_first_tail_x15_r0_body.kd153.nh1 = true
kernel_rfl PRE_first_tail_x15_r0_body.cnren153 : checkRenG PRE_first_tail_x15_r0_body.kd153.node PRE_first_tail_x15_r0_body.kninv153 (pnB PRE_first_tail_x15_r0_body.cx0_153.mlx) = true
kernel_rfl PRE_first_tail_x15_r0_body.cnlow153 : (PTrie.keysA PRE_first_tail_x15_r0_body.kd153.node).all (fun j => Nat.ble PRE_first_tail_x15_r0_body.P153.NL j && Nat.blt (PRE_first_tail_x15_r0_body.kd153.nodeF j) PRE_first_tail_x15_r0_body.cx1_153.mlx.nnext) = true
kernel_rfl PRE_first_tail_x15_r0_body.cabs0a153 : PRE_first_tail_x15_r0_body.cx0_153.mlx.arrs.get 0 = none
kernel_rfl PRE_first_tail_x15_r0_body.cabs0b153 : PRE_first_tail_x15_r0_body.cx0_153.mlx.objs.get 0 = none
kernel_rfl PRE_first_tail_x15_r0_body.ctok1153 : PRE_first_tail_x15_r0_body.cx1_153.mlx.tokens = []
kernel_rfl PRE_first_tail_x15_r0_body.cpend153 : PRE_first_tail_x15_r0_body.cx1_153.mlx.pending = PRE_first_tail_x15_r0_body.cx0_153.mlx.pending.map PRE_first_tail_x15_r0_body.kappa153.pend
kernel_rfl PRE_first_tail_x15_r0_body.cerrh153 : PRE_first_tail_x15_r0_body.cx1_153.mlx.errh = PRE_first_tail_x15_r0_body.cx0_153.mlx.errh.map PRE_first_tail_x15_r0_body.kappa153.arg
kernel_rfl PRE_first_tail_x15_r0_body.cfiles153 : PRE_first_tail_x15_r0_body.cx1_153.mlx.files = PRE_first_tail_x15_r0_body.cx0_153.mlx.files
kernel_rfl PRE_first_tail_x15_r0_body.carch153 : PRE_first_tail_x15_r0_body.cx1_153.mlx.arch = PRE_first_tail_x15_r0_body.cx0_153.mlx.arch
kernel_rfl PRE_first_tail_x15_r0_body.csizes153 : PRE_first_tail_x15_r0_body.cx1_153.mlx.deviceSizes = PRE_first_tail_x15_r0_body.cx0_153.mlx.deviceSizes
kernel_rfl PRE_first_tail_x15_r0_body.cwired153 : PRE_first_tail_x15_r0_body.cx1_153.mlx.wired = PRE_first_tail_x15_r0_body.cx0_153.mlx.wired
kernel_rfl PRE_first_tail_x15_r0_body.chost153 : PRE_first_tail_x15_r0_body.cx1_153.host = PRE_first_tail_x15_r0_body.cx0_153.host
-- the compaction map's addresses are `PRE_first_tail_x15_r0_body.kd153`'s
kernel_rfl PRE_first_tail_x15_r0_body.ckn0153 : PRE_first_tail_x15_r0_body.kd153.n0 = 2795515
kernel_rfl PRE_first_tail_x15_r0_body.ckn1153 : PRE_first_tail_x15_r0_body.kd153.n1 = 2795865
kernel_rfl PRE_first_tail_x15_r0_body.ckheap153 : (PTrie.keysA PRE_first_tail_x15_r0_body.kd153.heap).all (fun x => Nat.ble 2795500 x) = true
kernel_rfl PRE_first_tail_x15_r0_body.ckpl153 : (List.range 15).all (fun j => decide (PRE_first_tail_x15_r0_body.kd153.heap.get (2795500 + j) = nth? PRE_first_tail_x15_r0_body.pl153 j)) = true
-- the map fixes the call's names (`Conv.fixOld_compact`), the call's counters
kernel_rfl PRE_first_tail_x15_r0_body.fja153 : Nat.ble 2795500 2795500 = true
kernel_rfl PRE_first_tail_x15_r0_body.fn153 : Nat.ble 6630 6630 = true
kernel_rfl PRE_first_tail_x15_r0_body.fjaD153 : Nat.ble 2795500 PRE_first_tail_x15_r0_body.kd153.n0 = true
kernel_rfl PRE_first_tail_x15_r0_body.fxn153 : Nat.ble 21225 PRE_first_tail_x15_r0_body.kd153.nh0 = true
kernel_rfl PRE_first_tail_x15_r0_body.fnn153 : Nat.ble 18320 PRE_first_tail_x15_r0_body.kd153.nn0 = true
kernel_rfl PRE_first_tail_x15_r0_body.fxb153 : Nat.ble 21225 RData.bigHi = true
kernel_rfl PRE_first_tail_x15_r0_body.fheap153 : (PTrie.keysA PRE_first_tail_x15_r0_body.kd153.heap).all (Nat.ble (⟨21225, 18320, 2795500, 6630⟩ : Conv.Cnt).ja) = true
kernel_rfl PRE_first_tail_x15_r0_body.fhnd153 : (PTrie.keysA PRE_first_tail_x15_r0_body.kd153.hnd).all (Nat.ble (⟨21225, 18320, 2795500, 6630⟩ : Conv.Cnt).xn) = true
kernel_rfl PRE_first_tail_x15_r0_body.fnode153 : (PTrie.keysA PRE_first_tail_x15_r0_body.kd153.node).all (Nat.ble (⟨21225, 18320, 2795500, 6630⟩ : Conv.Cnt).nn) = true
/-- The compaction map fixes the call's names. -/
theorem PRE_first_tail_x15_r0_body.cfix153 : Conv.FixOld (⟨21225, 18320, 2795500, 6630⟩ : Conv.Cnt) PRE_first_tail_x15_r0_body.kappa153 :=
  Conv.fixOld_compact (Nat.le_of_ble_eq_true PRE_first_tail_x15_r0_body.fja153) (Nat.le_of_ble_eq_true PRE_first_tail_x15_r0_body.fn153) (Nat.le_of_ble_eq_true PRE_first_tail_x15_r0_body.fjaD153) (Nat.le_of_ble_eq_true PRE_first_tail_x15_r0_body.fxn153) (Nat.le_of_ble_eq_true PRE_first_tail_x15_r0_body.fnn153) (Nat.le_of_ble_eq_true PRE_first_tail_x15_r0_body.fxb153) PRE_first_tail_x15_r0_body.fheap153 PRE_first_tail_x15_r0_body.fhnd153 PRE_first_tail_x15_r0_body.fnode153
kernel_rfl PRE_first_tail_x15_r0_body.fcxn153 : (⟨21225, 18320, 2795500, 6630⟩ : Conv.Cnt).xn = (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1482.ffi).mlx.next
kernel_rfl PRE_first_tail_x15_r0_body.fcnn153 : (⟨21225, 18320, 2795500, 6630⟩ : Conv.Cnt).nn = (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1482.ffi).mlx.nnext
kernel_rfl PRE_first_tail_x15_r0_body.fle0153 : (Nat.ble (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1482.ffi).mlx.next PRE_first_tail_x15_r0_body.cx0_153.mlx.next && Nat.ble (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1482.ffi).mlx.nnext PRE_first_tail_x15_r0_body.cx0_153.mlx.nnext && Nat.ble (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1482.ffi).mlx.next RData.bigHi) = true
kernel_rfl PRE_first_tail_x15_r0_body.fnk153 : (PTrie.keysA PRE_first_tail_x15_r0_body.kd153.node).all (Nat.ble (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1482.ffi).mlx.nnext) = true
-- the merged state keeps the call's entries off the stage's footprint
kernel_rfl PRE_first_tail_x15_r0_body.f1A153 : PRE_first_tail_x15_r0_body.cx1_153.mlx.arrs = Stage.setAll (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1482.ffi).mlx.arrs (PRE_first_tail_x15_r0_body.cwS153.filterMap fun i => (PRE_first_tail_x15_r0_body.cx1_153.mlx.arrs.get i).map (i, ·))
kernel_rfl PRE_first_tail_x15_r0_body.f1O153 : PRE_first_tail_x15_r0_body.cx1_153.mlx.objs = Stage.setAll (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1482.ffi).mlx.objs (PRE_first_tail_x15_r0_body.cwS153.filterMap fun i => (PRE_first_tail_x15_r0_body.cx1_153.mlx.objs.get i).map (i, ·))
kernel_rfl PRE_first_tail_x15_r0_body.f1N153 : PRE_first_tail_x15_r0_body.cx1_153.mlx.nodes = Stage.setAll (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1482.ffi).mlx.nodes (PRE_first_tail_x15_r0_body.cnS153.filterMap fun i => (PRE_first_tail_x15_r0_body.cx1_153.mlx.nodes.get i).map (i, ·))
kernel_rfl PRE_first_tail_x15_r0_body.f1I153 : PRE_first_tail_x15_r0_body.cx1_153.mlx.items = Stage.setAll (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1482.ffi).mlx.items (PRE_first_tail_x15_r0_body.ciS153.filterMap fun i => (PRE_first_tail_x15_r0_body.cx1_153.mlx.items.get i).map (i, ·))
kernel_rfl PRE_first_tail_x15_r0_body.fbd153 : (PRE_first_tail_x15_r0_body.clo153 ++ PRE_first_tail_x15_r0_body.cln153 ++ PRE_first_tail_x15_r0_body.cli153 ++ PRE_first_tail_x15_r0_body.cwS153 ++ PRE_first_tail_x15_r0_body.cnS153 ++ PRE_first_tail_x15_r0_body.ciS153).all (fun i => Nat.blt (i / 4096) (4 ^ 31)) = true
kernel_rfl PRE_first_tail_x15_r0_body.fincW153 : PRE_first_tail_x15_r0_body.cwS153.all (fun h => !Nat.blt h (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1482.ffi).mlx.next || PRE_first_tail_x15_r0_body.clo153.contains h) = true
kernel_rfl PRE_first_tail_x15_r0_body.fincI153 : PRE_first_tail_x15_r0_body.ciS153.all (fun k => !Nat.blt k (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1482.ffi).mlx.nnext || PRE_first_tail_x15_r0_body.cli153.contains k) = true
kernel_rfl PRE_first_tail_x15_r0_body.fincN153 : PRE_first_tail_x15_r0_body.cnS153.all (Nat.ble (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1482.ffi).mlx.nnext) = true
kernel_rfl PRE_first_tail_x15_r0_body.flnF153 : PRE_first_tail_x15_r0_body.cln153.all (Nat.ble (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1482.ffi).mlx.nnext) = true
-- the checks over the changed lists
kernel_rfl PRE_first_tail_x15_r0_body.fh153 : PRE_first_tail_x15_r0_body.clo153.all (handleOK PRE_first_tail_x15_r0_body.kappa153 PRE_first_tail_x15_r0_body.P153.lo PRE_first_tail_x15_r0_body.cx0_153.mlx PRE_first_tail_x15_r0_body.cx1_153.mlx) = true
kernel_rfl PRE_first_tail_x15_r0_body.fo153 : PRE_first_tail_x15_r0_body.clo153.map (fun h => PRE_first_tail_x15_r0_body.cx1_153.mlx.objs.get (PRE_first_tail_x15_r0_body.kappa153.handle h)) = PRE_first_tail_x15_r0_body.clo153.map (fun h => (PRE_first_tail_x15_r0_body.cx0_153.mlx.objs.get h).map PRE_first_tail_x15_r0_body.kappa153.nobj)
kernel_rfl PRE_first_tail_x15_r0_body.fok153 : PRE_first_tail_x15_r0_body.clo153.all (objOK PRE_first_tail_x15_r0_body.kappa153 PRE_first_tail_x15_r0_body.P153.NL PRE_first_tail_x15_r0_body.cx0_153.mlx) = true
kernel_rfl PRE_first_tail_x15_r0_body.fnd153 : PRE_first_tail_x15_r0_body.cln153.all (nodeOKF PRE_first_tail_x15_r0_body.kappa153 PRE_first_tail_x15_r0_body.P153 PRE_first_tail_x15_r0_body.cx0_153.mlx PRE_first_tail_x15_r0_body.cx1_153.mlx) = true
kernel_rfl PRE_first_tail_x15_r0_body.fp153 : ((PRE_first_tail_x15_r0_body.cln153.filter (fullB PRE_first_tail_x15_r0_body.P153))).map (fun i => (PRE_first_tail_x15_r0_body.cx1_153.mlx.nodes.get (PRE_first_tail_x15_r0_body.kappa153.node i)).map Host.Mlx.Ffi.Node.prim) =
  ((PRE_first_tail_x15_r0_body.cln153.filter (fullB PRE_first_tail_x15_r0_body.P153))).map (fun i => (PRE_first_tail_x15_r0_body.cx0_153.mlx.nodes.get i).map fun nd => PRE_first_tail_x15_r0_body.kappa153.prim nd.prim)
kernel_rfl PRE_first_tail_x15_r0_body.fnordI153 : incrB PRE_first_tail_x15_r0_body.kd153.nodeF (List.range' 18320 6) = true
kernel_rfl PRE_first_tail_x15_r0_body.fnordK153 : (PTrie.keysA PRE_first_tail_x15_r0_body.kd153.node).all (fun k => Nat.ble 18320 k && Nat.blt k 18326) = true
kernel_rfl PRE_first_tail_x15_r0_body.fnordL153 : (PRE_first_tail_x15_r0_body.cln153.filter (Nat.ble PRE_first_tail_x15_r0_body.P153.N0)).all (fun i => Nat.ble i (PRE_first_tail_x15_r0_body.kd153.nodeF i) && (Nat.blt i 18326 || Nat.ble PRE_first_tail_x15_r0_body.kd153.nn0 i)) = true
theorem PRE_first_tail_x15_r0_body.fnord153 : (PRE_first_tail_x15_r0_body.cln153.filter (Nat.ble PRE_first_tail_x15_r0_body.P153.N0)).all (fun i => Nat.ble i (PRE_first_tail_x15_r0_body.kd153.nodeF i) &&
    (PTrie.keysA PRE_first_tail_x15_r0_body.kd153.node).all fun j => !Nat.blt j i || Nat.blt (PRE_first_tail_x15_r0_body.kd153.nodeF j) (PRE_first_tail_x15_r0_body.kd153.nodeF i)) = true :=
  cnord_of PRE_first_tail_x15_r0_body.cnlow153 PRE_first_tail_x15_r0_body.cnn1153 PRE_first_tail_x15_r0_body.fnordI153 PRE_first_tail_x15_r0_body.fnordK153 PRE_first_tail_x15_r0_body.fnordL153
kernel_rfl PRE_first_tail_x15_r0_body.fi153 : PRE_first_tail_x15_r0_body.cli153.all (pnB PRE_first_tail_x15_r0_body.cx0_153.mlx) = true
kernel_rfl PRE_first_tail_x15_r0_body.fii153 : PRE_first_tail_x15_r0_body.cli153.all (fun k => decide (PRE_first_tail_x15_r0_body.cx1_153.mlx.items.get (PRE_first_tail_x15_r0_body.kappa153.node k) = (PRE_first_tail_x15_r0_body.cx0_153.mlx.items.get k).map PRE_first_tail_x15_r0_body.kappa153.nv)) = true
/-- **The compaction's footprint.** -/
theorem PRE_first_tail_x15_r0_body.cfoot153 (clean : Conv.NClean (⟨21225, 18320, 2795500, 6630⟩ : Conv.Cnt) (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1482.ffi).mlx) (hltC : ∀ h, PH (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1482.ffi).mlx h → h < (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1482.ffi).mlx.next) (nltC : ∀ i, PN (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1482.ffi).mlx i → i < (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1482.ffi).mlx.nnext) (itemsC : ∀ k v, (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1482.ffi).mlx.items.get k = some v → PN (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1482.ffi).mlx k) (tracedC : ∀ h o, (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1482.ffi).mlx.objs.get h = some o → ∀ i ∈ objTraces o, i < PRE_first_tail_x15_r0_body.P153.NL) (cl : SSt (· < 6639) PRE_first_tail_x15_r0_body.cx0_153.mlx) :
    Conv.MFoot PRE_first_tail_x15_r0_body.P153 6639 PRE_first_tail_x15_r0_body.kappa153 PRE_first_tail_x15_r0_body.kd153 PRE_first_tail_x15_r0_body.khinv153 PRE_first_tail_x15_r0_body.kninv153 (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1482.ffi).mlx PRE_first_tail_x15_r0_body.cx0_153.mlx PRE_first_tail_x15_r0_body.cx1_153.mlx (⟨21225, 18320, 2795500, 6630⟩ : Conv.Cnt) PRE_first_tail_x15_r0_body.clo153 PRE_first_tail_x15_r0_body.cln153 PRE_first_tail_x15_r0_body.cli153 PRE_first_tail_x15_r0_body.cwS153 PRE_first_tail_x15_r0_body.cnS153 PRE_first_tail_x15_r0_body.ciS153 :=
  ⟨rfl, rfl, rfl, PRE_first_tail_x15_r0_body.cnh0153, PRE_first_tail_x15_r0_body.cnh1153, PRE_first_tail_x15_r0_body.cnn0153, PRE_first_tail_x15_r0_body.cnn1153, PRE_first_tail_x15_r0_body.cplo153, PRE_first_tail_x15_r0_body.ccnt153, PRE_first_tail_x15_r0_body.cnband153, PRE_first_tail_x15_r0_body.chbelow153, PRE_first_tail_x15_r0_body.chren153, PRE_first_tail_x15_r0_body.cband153, PRE_first_tail_x15_r0_body.cnh1pos153, PRE_first_tail_x15_r0_body.cnren153, PRE_first_tail_x15_r0_body.cnlow153, PRE_first_tail_x15_r0_body.cabs0a153, PRE_first_tail_x15_r0_body.cabs0b153, PRE_first_tail_x15_r0_body.ctok1153, PRE_first_tail_x15_r0_body.cpend153, PRE_first_tail_x15_r0_body.cerrh153, PRE_first_tail_x15_r0_body.cfiles153, PRE_first_tail_x15_r0_body.carch153, PRE_first_tail_x15_r0_body.csizes153, PRE_first_tail_x15_r0_body.cwired153, PRE_first_tail_x15_r0_body.cfix153, clean, PRE_first_tail_x15_r0_body.fcxn153, PRE_first_tail_x15_r0_body.fcnn153, hltC, nltC, itemsC, tracedC, cl, PRE_first_tail_x15_r0_body.fle0153, PRE_first_tail_x15_r0_body.fnk153, PRE_first_tail_x15_r0_body.ckA153, PRE_first_tail_x15_r0_body.cobjsK153, PRE_first_tail_x15_r0_body.cnodesK153, PRE_first_tail_x15_r0_body.citemsK153, PRE_first_tail_x15_r0_body.f1A153, PRE_first_tail_x15_r0_body.f1O153, PRE_first_tail_x15_r0_body.f1N153, PRE_first_tail_x15_r0_body.f1I153, PRE_first_tail_x15_r0_body.fbd153, PRE_first_tail_x15_r0_body.fincW153, PRE_first_tail_x15_r0_body.fincI153, PRE_first_tail_x15_r0_body.fincN153, PRE_first_tail_x15_r0_body.flnF153, PRE_first_tail_x15_r0_body.fh153, PRE_first_tail_x15_r0_body.fo153, PRE_first_tail_x15_r0_body.fok153, PRE_first_tail_x15_r0_body.fnd153, PRE_first_tail_x15_r0_body.fp153, PRE_first_tail_x15_r0_body.fnord153, PRE_first_tail_x15_r0_body.fi153, PRE_first_tail_x15_r0_body.fii153⟩
theorem PRE_first_tail_x15_r0_body.cnshift153 (clean : Conv.NClean (⟨21225, 18320, 2795500, 6630⟩ : Conv.Cnt) (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1482.ffi).mlx) (hltC : ∀ h, PH (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1482.ffi).mlx h → h < (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1482.ffi).mlx.next) (nltC : ∀ i, PN (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1482.ffi).mlx i → i < (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1482.ffi).mlx.nnext) (itemsC : ∀ k v, (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1482.ffi).mlx.items.get k = some v → PN (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1482.ffi).mlx k) (tracedC : ∀ h o, (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1482.ffi).mlx.objs.get h = some o → ∀ i ∈ objTraces o, i < PRE_first_tail_x15_r0_body.P153.NL) (cl : SSt (· < 6639) PRE_first_tail_x15_r0_body.cx0_153.mlx) : NShift PRE_first_tail_x15_r0_body.P153 6639 PRE_first_tail_x15_r0_body.kappa153 PRE_first_tail_x15_r0_body.cx0_153 PRE_first_tail_x15_r0_body.cx1_153 :=
  Conv.nshift_of_foot (PRE_first_tail_x15_r0_body.cfoot153 clean hltC nltC itemsC tracedC cl) PRE_first_tail_x15_r0_body.chost153 (compact_a_eq PRE_first_tail_x15_r0_body.ckn0153 PRE_first_tail_x15_r0_body.ckn1153 PRE_first_tail_x15_r0_body.ckheap153 PRE_first_tail_x15_r0_body.ckpl153)

-- the observers: the layers' states at the call, the canonical and the merged state, their footprints and checks
noncomputable def PRE_first_tail_x15_r0_body.fxC_153 : PTrie Unit := (Host.Ts.Sim.Full.freedOf PRE_first_tail_x15_r0_body.s1482.ffi).getD PTrie.nil
noncomputable def PRE_first_tail_x15_r0_body.krC_153 : Host.Load.Layers.KRec := (Host.Ts.Sim.Full.krecOf PRE_first_tail_x15_r0_body.s1482.ffi).getD Host.Load.Layers.KRec.empty
kernel_rfl PRE_first_tail_x15_r0_body.ofxC_153 : (Host.Ts.Sim.Full.freedOf PRE_first_tail_x15_r0_body.s1482.ffi) = some PRE_first_tail_x15_r0_body.fxC_153
kernel_rfl PRE_first_tail_x15_r0_body.okrC_153 : (Host.Ts.Sim.Full.krecOf PRE_first_tail_x15_r0_body.s1482.ffi) = some PRE_first_tail_x15_r0_body.krC_153
noncomputable def PRE_first_tail_x15_r0_body.fx0_153 : PTrie Unit := (Host.Ts.Sim.Full.freedOf PRE_first_tail_x15_r0_body.s1484.ffi).getD PTrie.nil
noncomputable def PRE_first_tail_x15_r0_body.kr0_153 : Host.Load.Layers.KRec := (Host.Ts.Sim.Full.krecOf PRE_first_tail_x15_r0_body.s1484.ffi).getD Host.Load.Layers.KRec.empty
kernel_rfl PRE_first_tail_x15_r0_body.ofx0_153 : (Host.Ts.Sim.Full.freedOf PRE_first_tail_x15_r0_body.s1484.ffi) = some PRE_first_tail_x15_r0_body.fx0_153
kernel_rfl PRE_first_tail_x15_r0_body.okr0_153 : (Host.Ts.Sim.Full.krecOf PRE_first_tail_x15_r0_body.s1484.ffi) = some PRE_first_tail_x15_r0_body.kr0_153
noncomputable def PRE_first_tail_x15_r0_body.fx1_153 : PTrie Unit := (Host.Ts.Sim.Full.freedOf PRE_first_tail_x15_r0_body.s1483.ffi).getD PTrie.nil
noncomputable def PRE_first_tail_x15_r0_body.kr1_153 : Host.Load.Layers.KRec := (Host.Ts.Sim.Full.krecOf PRE_first_tail_x15_r0_body.s1483.ffi).getD Host.Load.Layers.KRec.empty
kernel_rfl PRE_first_tail_x15_r0_body.ofx1_153 : (Host.Ts.Sim.Full.freedOf PRE_first_tail_x15_r0_body.s1483.ffi) = some PRE_first_tail_x15_r0_body.fx1_153
kernel_rfl PRE_first_tail_x15_r0_body.okr1_153 : (Host.Ts.Sim.Full.krecOf PRE_first_tail_x15_r0_body.s1483.ffi) = some PRE_first_tail_x15_r0_body.kr1_153
kernel_rfl PRE_first_tail_x15_r0_body.ff0153 : PRE_first_tail_x15_r0_body.fx0_153 = Stage.setAll PRE_first_tail_x15_r0_body.fxC_153 (PRE_first_tail_x15_r0_body.clo153.filterMap fun i => (PRE_first_tail_x15_r0_body.fx0_153.get i).map (i, ·))
kernel_rfl PRE_first_tail_x15_r0_body.ff1153 : PRE_first_tail_x15_r0_body.fx1_153 = Stage.setAll PRE_first_tail_x15_r0_body.fxC_153 (PRE_first_tail_x15_r0_body.cwS153.filterMap fun i => (PRE_first_tail_x15_r0_body.fx1_153.get i).map (i, ·))
kernel_rfl PRE_first_tail_x15_r0_body.ffck153 : freedLB PRE_first_tail_x15_r0_body.kappa153 PRE_first_tail_x15_r0_body.cx0_153.mlx PRE_first_tail_x15_r0_body.fx0_153 PRE_first_tail_x15_r0_body.fx1_153 PRE_first_tail_x15_r0_body.clo153 = true
kernel_rfl PRE_first_tail_x15_r0_body.fkf0153 : PRE_first_tail_x15_r0_body.kr0_153.flags = Stage.setAll PRE_first_tail_x15_r0_body.krC_153.flags (PRE_first_tail_x15_r0_body.clo153.filterMap fun i => (PRE_first_tail_x15_r0_body.kr0_153.flags.get i).map (i, ·))
kernel_rfl PRE_first_tail_x15_r0_body.fkt0153 : PRE_first_tail_x15_r0_body.kr0_153.targs = Stage.setAll PRE_first_tail_x15_r0_body.krC_153.targs (PRE_first_tail_x15_r0_body.clo153.filterMap fun i => (PRE_first_tail_x15_r0_body.kr0_153.targs.get i).map (i, ·))
kernel_rfl PRE_first_tail_x15_r0_body.fkf1153 : PRE_first_tail_x15_r0_body.kr1_153.flags = Stage.setAll PRE_first_tail_x15_r0_body.krC_153.flags (PRE_first_tail_x15_r0_body.cwS153.filterMap fun i => (PRE_first_tail_x15_r0_body.kr1_153.flags.get i).map (i, ·))
kernel_rfl PRE_first_tail_x15_r0_body.fkt1153 : PRE_first_tail_x15_r0_body.kr1_153.targs = Stage.setAll PRE_first_tail_x15_r0_body.krC_153.targs (PRE_first_tail_x15_r0_body.cwS153.filterMap fun i => (PRE_first_tail_x15_r0_body.kr1_153.targs.get i).map (i, ·))
kernel_rfl PRE_first_tail_x15_r0_body.fkck153 : krecLB PRE_first_tail_x15_r0_body.kappa153 6639 PRE_first_tail_x15_r0_body.cx0_153.mlx PRE_first_tail_x15_r0_body.kr0_153 PRE_first_tail_x15_r0_body.kr1_153 PRE_first_tail_x15_r0_body.clo153 = true
kernel_rfl PRE_first_tail_x15_r0_body.fkn153 : Nat.ble 6630 6639 = true
-- the bridge and the pending traces' regions
kernel_rfl PRE_first_tail_x15_r0_body.cbridge153 : Host.Ts.Sim.Full.bridgeOf PRE_first_tail_x15_r0_body.s1483.ffi = Host.Ts.Sim.Full.bridgeOf PRE_first_tail_x15_r0_body.s1484.ffi
kernel_rfl PRE_first_tail_x15_r0_body.cpendR153 : pendRegB PRE_first_tail_x15_r0_body.kappa153 (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1484.ffi).mlx = true
kernel_rfl PRE_first_tail_x15_r0_body.cpendLe153 : Nat.ble (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1484.ffi).mlx.next (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1483.ffi).mlx.next = true
/-- **The compaction's native shift**, given the call's bookkeeping, its relation's facts (the model's and the
observers') and the canonical closedness. -/
theorem PRE_first_tail_x15_r0_body.cshift153 (clean : Conv.NClean (⟨21225, 18320, 2795500, 6630⟩ : Conv.Cnt) (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1482.ffi).mlx) (hltC : ∀ h, PH (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1482.ffi).mlx h → h < (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1482.ffi).mlx.next) (nltC : ∀ i, PN (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1482.ffi).mlx i → i < (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1482.ffi).mlx.nnext) (itemsC : ∀ k v, (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1482.ffi).mlx.items.get k = some v → PN (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1482.ffi).mlx k) (tracedC : ∀ h o, (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1482.ffi).mlx.objs.get h = some o → ∀ i ∈ objTraces o, i < PRE_first_tail_x15_r0_body.P153.NL) (cl : SSt (· < 6639) PRE_first_tail_x15_r0_body.cx0_153.mlx)
    (hobjC : ∀ h, PRE_first_tail_x15_r0_body.fxC_153.get h = some () → ((Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1482.ffi).mlx.objs.get h).isSome = true)
    (hfC : ∀ h, (PRE_first_tail_x15_r0_body.krC_153.flags.get h).isSome = true → ((Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1482.ffi).mlx.objs.get h).isSome = true)
    (htC : ∀ h, (PRE_first_tail_x15_r0_body.krC_153.targs.get h).isSome = true → ((Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1482.ffi).mlx.objs.get h).isSome = true)
    (hclC : ∀ h l, PRE_first_tail_x15_r0_body.krC_153.targs.get h = some l → Host.Ts.Sim.Full.STargs (· < (⟨21225, 18320, 2795500, 6630⟩ : Conv.Cnt).n) l) :
    Conv.FullShiftQ PRE_first_tail_x15_r0_body.P153 6639 PRE_first_tail_x15_r0_body.kappa153 PRE_first_tail_x15_r0_body.s1484.ffi PRE_first_tail_x15_r0_body.s1483.ffi :=
  ⟨PRE_first_tail_x15_r0_body.cnshift153 clean hltC nltC itemsC tracedC cl, PRE_first_tail_x15_r0_body.cqueue153, fun t ht => bSN_sound (List.all_eq_true.mp PRE_first_tail_x15_r0_body.ctokSupp153 t ht),
    PRE_first_tail_x15_r0_body.cbridge153,
    liveShift_foot (x0' := Host.Ts.Sim.Full.mlxOf PRE_first_tail_x15_r0_body.s1484.ffi) (x1' := Host.Ts.Sim.Full.mlxOf PRE_first_tail_x15_r0_body.s1483.ffi) (PRE_first_tail_x15_r0_body.cfoot153 clean hltC nltC itemsC tracedC cl) rfl PRE_first_tail_x15_r0_body.ofx0_153 PRE_first_tail_x15_r0_body.ofx1_153 hobjC PRE_first_tail_x15_r0_body.ff0153 PRE_first_tail_x15_r0_body.ff1153 PRE_first_tail_x15_r0_body.ffck153,
    kernShift_foot (x0' := Host.Ts.Sim.Full.mlxOf PRE_first_tail_x15_r0_body.s1484.ffi) (x1' := Host.Ts.Sim.Full.mlxOf PRE_first_tail_x15_r0_body.s1483.ffi) (PRE_first_tail_x15_r0_body.cfoot153 clean hltC nltC itemsC tracedC cl) rfl PRE_first_tail_x15_r0_body.okr0_153 PRE_first_tail_x15_r0_body.okr1_153 (Nat.le_of_ble_eq_true PRE_first_tail_x15_r0_body.fkn153) hfC htC hclC
      PRE_first_tail_x15_r0_body.fkf0153 PRE_first_tail_x15_r0_body.fkt0153 PRE_first_tail_x15_r0_body.fkf1153 PRE_first_tail_x15_r0_body.fkt1153 PRE_first_tail_x15_r0_body.fkck153,
    pendReg_of rfl PRE_first_tail_x15_r0_body.cnh0153 PRE_first_tail_x15_r0_body.cnh1153 (Nat.le_of_ble_eq_true PRE_first_tail_x15_r0_body.cpendLe153) PRE_first_tail_x15_r0_body.cpendR153⟩

end Host.Load.Run.Tpl
