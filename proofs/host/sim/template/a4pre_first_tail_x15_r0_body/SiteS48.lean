import host.sim.template.a4pre_first_tail_x15_r0_body.SiteCl48
import host.sim.conv.CompactFull
import host.sim.template.FootGen
set_option Elab.async false
namespace Host.Load.Run.Tpl
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
open Host.Ts Host.Ts.Sim Host.Ts.Sim.Template

/-! The compaction's native shift at call site 48 from its footprint (`Conv.nshift_of_foot`), and the observers'
(`liveShift_foot`, `kernShift_foot`): `Conv.FullShiftQ` for `Conv.full_compactQ`, given the call's bookkeeping and its
relation's facts. -/

/-- The load parameters of the chain (band-free: its start's node counter as `NL` and `N0`). -/
def PRE_first_tail_x15_r0_body.Pc48 : LoadP := ⟨18151, 131072, 1099511627776, 15235, 15235, []⟩
/-- The site's band raised to the map's checked fixed-node prefix, including newly recorded closure traces. -/
def PRE_first_tail_x15_r0_body.P48 : LoadP := PRE_first_tail_x15_r0_body.Pc48.raise 16253
kernel_rfl PRE_first_tail_x15_r0_body.craise48 : Nat.ble PRE_first_tail_x15_r0_body.Pc48.N0 16253 = true
theorem PRE_first_tail_x15_r0_body.raised48 : Host.Ts.Sim.Full.Raised PRE_first_tail_x15_r0_body.Pc48 PRE_first_tail_x15_r0_body.P48 :=
  .inr ⟨16253, rfl, Nat.le_of_ble_eq_true PRE_first_tail_x15_r0_body.craise48, rfl⟩
noncomputable abbrev PRE_first_tail_x15_r0_body.cx0_48 : Host.Load.LSt := clearTokens (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s478.ffi)
noncomputable abbrev PRE_first_tail_x15_r0_body.cx1_48 : Host.Load.LSt := clearTokens (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s477.ffi)
def PRE_first_tail_x15_r0_body.khinv48 : PTrie Nat := Stage.setAll PTrie.nil [(19186, 19160), (19164, 19161), (19187, 19162)]
def PRE_first_tail_x15_r0_body.kninv48 : PTrie Nat := Stage.setAll PTrie.nil [(16226, 16226), (16227, 16227), (16228, 16228), (16229, 16229), (16230, 16230), (16231, 16231), (16232, 16232), (16233, 16233), (16234, 16234), (16235, 16235), (16236, 16236), (16237, 16237), (16238, 16238), (16239, 16239), (16240, 16240), (16241, 16241), (16242, 16242), (16243, 16243), (16244, 16244), (16245, 16245), (16246, 16246), (16247, 16247), (16248, 16248), (16249, 16249), (16250, 16250), (16251, 16251), (16252, 16252)]
/-- The stage's footprint: its written and fresh handles, fresh nodes, written and fresh items. -/
def PRE_first_tail_x15_r0_body.cwS48 : List Nat := [19140, 19153, 19159, 19160, 19161, 19162, 19163, 19164, 19165, 19166, 19167, 19168, 19169, 19170, 19171, 19172, 19173, 19174, 19175, 19176, 19177, 19178, 19179, 19180, 19181, 19182, 19183, 19184, 19185, 19186, 19187]
def PRE_first_tail_x15_r0_body.cnS48 : List Nat := List.range' 16226 27
def PRE_first_tail_x15_r0_body.ciS48 : List Nat := [] ++ List.range' 16226 27

-- the small checks (`MChecks`'s)
kernel_rfl PRE_first_tail_x15_r0_body.cnh048 : PRE_first_tail_x15_r0_body.kd48.nh0 = PRE_first_tail_x15_r0_body.cx0_48.mlx.next
kernel_rfl PRE_first_tail_x15_r0_body.cnh148 : PRE_first_tail_x15_r0_body.kd48.nh1 = PRE_first_tail_x15_r0_body.cx1_48.mlx.next
kernel_rfl PRE_first_tail_x15_r0_body.cnn048 : PRE_first_tail_x15_r0_body.kd48.nn0 = PRE_first_tail_x15_r0_body.cx0_48.mlx.nnext
kernel_rfl PRE_first_tail_x15_r0_body.cnn148 : PRE_first_tail_x15_r0_body.kd48.nn1 = PRE_first_tail_x15_r0_body.cx1_48.mlx.nnext
kernel_rfl PRE_first_tail_x15_r0_body.cplo48 : (Nat.blt 0 PRE_first_tail_x15_r0_body.P48.lo && Nat.ble PRE_first_tail_x15_r0_body.P48.lo PRE_first_tail_x15_r0_body.cx0_48.mlx.next && Nat.ble PRE_first_tail_x15_r0_body.P48.lo RData.bigHi && Nat.ble RData.bigHi PRE_first_tail_x15_r0_body.P48.E) = true
kernel_rfl PRE_first_tail_x15_r0_body.ccnt48 : (Nat.ble PRE_first_tail_x15_r0_body.cx0_48.mlx.next PRE_first_tail_x15_r0_body.cx1_48.mlx.next && Nat.ble PRE_first_tail_x15_r0_body.cx0_48.mlx.nnext PRE_first_tail_x15_r0_body.cx1_48.mlx.nnext) = true
kernel_rfl PRE_first_tail_x15_r0_body.cnband48 : (Nat.blt 0 PRE_first_tail_x15_r0_body.P48.NL && Nat.ble PRE_first_tail_x15_r0_body.P48.NL PRE_first_tail_x15_r0_body.P48.N0 && Nat.ble PRE_first_tail_x15_r0_body.P48.N0 PRE_first_tail_x15_r0_body.cx0_48.mlx.nnext) = true
kernel_rfl PRE_first_tail_x15_r0_body.chbelow48 : PRE_first_tail_x15_r0_body.kd48.checkHndBelow = true
kernel_rfl PRE_first_tail_x15_r0_body.chren48 : checkRenG PRE_first_tail_x15_r0_body.kd48.hnd PRE_first_tail_x15_r0_body.khinv48 (phB PRE_first_tail_x15_r0_body.cx0_48.mlx) = true
kernel_rfl PRE_first_tail_x15_r0_body.cband48 : PRE_first_tail_x15_r0_body.kd48.checkBand PRE_first_tail_x15_r0_body.P48.lo = true
kernel_rfl PRE_first_tail_x15_r0_body.cnh1pos48 : Nat.blt 0 PRE_first_tail_x15_r0_body.kd48.nh1 = true
kernel_rfl PRE_first_tail_x15_r0_body.cnren48 : checkRenG PRE_first_tail_x15_r0_body.kd48.node PRE_first_tail_x15_r0_body.kninv48 (pnB PRE_first_tail_x15_r0_body.cx0_48.mlx) = true
kernel_rfl PRE_first_tail_x15_r0_body.cnlow48 : (PTrie.keysA PRE_first_tail_x15_r0_body.kd48.node).all (fun j => Nat.ble PRE_first_tail_x15_r0_body.P48.NL j && Nat.blt (PRE_first_tail_x15_r0_body.kd48.nodeF j) PRE_first_tail_x15_r0_body.cx1_48.mlx.nnext) = true
kernel_rfl PRE_first_tail_x15_r0_body.cabs0a48 : PRE_first_tail_x15_r0_body.cx0_48.mlx.arrs.get 0 = none
kernel_rfl PRE_first_tail_x15_r0_body.cabs0b48 : PRE_first_tail_x15_r0_body.cx0_48.mlx.objs.get 0 = none
kernel_rfl PRE_first_tail_x15_r0_body.ctok148 : PRE_first_tail_x15_r0_body.cx1_48.mlx.tokens = []
kernel_rfl PRE_first_tail_x15_r0_body.cpend48 : PRE_first_tail_x15_r0_body.cx1_48.mlx.pending = PRE_first_tail_x15_r0_body.cx0_48.mlx.pending.map PRE_first_tail_x15_r0_body.kappa48.pend
kernel_rfl PRE_first_tail_x15_r0_body.cerrh48 : PRE_first_tail_x15_r0_body.cx1_48.mlx.errh = PRE_first_tail_x15_r0_body.cx0_48.mlx.errh.map PRE_first_tail_x15_r0_body.kappa48.arg
kernel_rfl PRE_first_tail_x15_r0_body.cfiles48 : PRE_first_tail_x15_r0_body.cx1_48.mlx.files = PRE_first_tail_x15_r0_body.cx0_48.mlx.files
kernel_rfl PRE_first_tail_x15_r0_body.carch48 : PRE_first_tail_x15_r0_body.cx1_48.mlx.arch = PRE_first_tail_x15_r0_body.cx0_48.mlx.arch
kernel_rfl PRE_first_tail_x15_r0_body.csizes48 : PRE_first_tail_x15_r0_body.cx1_48.mlx.deviceSizes = PRE_first_tail_x15_r0_body.cx0_48.mlx.deviceSizes
kernel_rfl PRE_first_tail_x15_r0_body.cwired48 : PRE_first_tail_x15_r0_body.cx1_48.mlx.wired = PRE_first_tail_x15_r0_body.cx0_48.mlx.wired
kernel_rfl PRE_first_tail_x15_r0_body.chost48 : PRE_first_tail_x15_r0_body.cx1_48.host = PRE_first_tail_x15_r0_body.cx0_48.host
-- the compaction map's addresses are `PRE_first_tail_x15_r0_body.kd48`'s
kernel_rfl PRE_first_tail_x15_r0_body.ckn048 : PRE_first_tail_x15_r0_body.kd48.n0 = 2713129
kernel_rfl PRE_first_tail_x15_r0_body.ckn148 : PRE_first_tail_x15_r0_body.kd48.n1 = 2714278
kernel_rfl PRE_first_tail_x15_r0_body.ckheap48 : (PTrie.keysA PRE_first_tail_x15_r0_body.kd48.heap).all (fun x => Nat.ble 2713123 x) = true
kernel_rfl PRE_first_tail_x15_r0_body.ckpl48 : (List.range 6).all (fun j => decide (PRE_first_tail_x15_r0_body.kd48.heap.get (2713123 + j) = nth? PRE_first_tail_x15_r0_body.pl48 j)) = true
-- the map fixes the call's names (`Conv.fixOld_compact`), the call's counters
kernel_rfl PRE_first_tail_x15_r0_body.fja48 : Nat.ble 2713123 2713123 = true
kernel_rfl PRE_first_tail_x15_r0_body.fn48 : Nat.ble 2135 2135 = true
kernel_rfl PRE_first_tail_x15_r0_body.fjaD48 : Nat.ble 2713123 PRE_first_tail_x15_r0_body.kd48.n0 = true
kernel_rfl PRE_first_tail_x15_r0_body.fxn48 : Nat.ble 19160 PRE_first_tail_x15_r0_body.kd48.nh0 = true
kernel_rfl PRE_first_tail_x15_r0_body.fnn48 : Nat.ble 16226 PRE_first_tail_x15_r0_body.kd48.nn0 = true
kernel_rfl PRE_first_tail_x15_r0_body.fxb48 : Nat.ble 19160 RData.bigHi = true
kernel_rfl PRE_first_tail_x15_r0_body.fheap48 : (PTrie.keysA PRE_first_tail_x15_r0_body.kd48.heap).all (Nat.ble (⟨19160, 16226, 2713123, 2135⟩ : Conv.Cnt).ja) = true
kernel_rfl PRE_first_tail_x15_r0_body.fhnd48 : (PTrie.keysA PRE_first_tail_x15_r0_body.kd48.hnd).all (Nat.ble (⟨19160, 16226, 2713123, 2135⟩ : Conv.Cnt).xn) = true
kernel_rfl PRE_first_tail_x15_r0_body.fnode48 : (PTrie.keysA PRE_first_tail_x15_r0_body.kd48.node).all (Nat.ble (⟨19160, 16226, 2713123, 2135⟩ : Conv.Cnt).nn) = true
/-- The compaction map fixes the call's names. -/
theorem PRE_first_tail_x15_r0_body.cfix48 : Conv.FixOld (⟨19160, 16226, 2713123, 2135⟩ : Conv.Cnt) PRE_first_tail_x15_r0_body.kappa48 :=
  Conv.fixOld_compact (Nat.le_of_ble_eq_true PRE_first_tail_x15_r0_body.fja48) (Nat.le_of_ble_eq_true PRE_first_tail_x15_r0_body.fn48) (Nat.le_of_ble_eq_true PRE_first_tail_x15_r0_body.fjaD48) (Nat.le_of_ble_eq_true PRE_first_tail_x15_r0_body.fxn48) (Nat.le_of_ble_eq_true PRE_first_tail_x15_r0_body.fnn48) (Nat.le_of_ble_eq_true PRE_first_tail_x15_r0_body.fxb48) PRE_first_tail_x15_r0_body.fheap48 PRE_first_tail_x15_r0_body.fhnd48 PRE_first_tail_x15_r0_body.fnode48
kernel_rfl PRE_first_tail_x15_r0_body.fcxn48 : (⟨19160, 16226, 2713123, 2135⟩ : Conv.Cnt).xn = (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s476.ffi).mlx.next
kernel_rfl PRE_first_tail_x15_r0_body.fcnn48 : (⟨19160, 16226, 2713123, 2135⟩ : Conv.Cnt).nn = (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s476.ffi).mlx.nnext
kernel_rfl PRE_first_tail_x15_r0_body.fle048 : (Nat.ble (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s476.ffi).mlx.next PRE_first_tail_x15_r0_body.cx0_48.mlx.next && Nat.ble (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s476.ffi).mlx.nnext PRE_first_tail_x15_r0_body.cx0_48.mlx.nnext && Nat.ble (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s476.ffi).mlx.next RData.bigHi) = true
kernel_rfl PRE_first_tail_x15_r0_body.fnk48 : (PTrie.keysA PRE_first_tail_x15_r0_body.kd48.node).all (Nat.ble (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s476.ffi).mlx.nnext) = true
-- the merged state keeps the call's entries off the stage's footprint
kernel_rfl PRE_first_tail_x15_r0_body.f1A48 : PRE_first_tail_x15_r0_body.cx1_48.mlx.arrs = Stage.setAll (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s476.ffi).mlx.arrs (PRE_first_tail_x15_r0_body.cwS48.filterMap fun i => (PRE_first_tail_x15_r0_body.cx1_48.mlx.arrs.get i).map (i, ·))
kernel_rfl PRE_first_tail_x15_r0_body.f1O48 : PRE_first_tail_x15_r0_body.cx1_48.mlx.objs = Stage.setAll (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s476.ffi).mlx.objs (PRE_first_tail_x15_r0_body.cwS48.filterMap fun i => (PRE_first_tail_x15_r0_body.cx1_48.mlx.objs.get i).map (i, ·))
kernel_rfl PRE_first_tail_x15_r0_body.f1N48 : PRE_first_tail_x15_r0_body.cx1_48.mlx.nodes = Stage.setAll (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s476.ffi).mlx.nodes (PRE_first_tail_x15_r0_body.cnS48.filterMap fun i => (PRE_first_tail_x15_r0_body.cx1_48.mlx.nodes.get i).map (i, ·))
kernel_rfl PRE_first_tail_x15_r0_body.f1I48 : PRE_first_tail_x15_r0_body.cx1_48.mlx.items = Stage.setAll (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s476.ffi).mlx.items (PRE_first_tail_x15_r0_body.ciS48.filterMap fun i => (PRE_first_tail_x15_r0_body.cx1_48.mlx.items.get i).map (i, ·))
kernel_rfl PRE_first_tail_x15_r0_body.fbd48 : (PRE_first_tail_x15_r0_body.clo48 ++ PRE_first_tail_x15_r0_body.cln48 ++ PRE_first_tail_x15_r0_body.cli48 ++ PRE_first_tail_x15_r0_body.cwS48 ++ PRE_first_tail_x15_r0_body.cnS48 ++ PRE_first_tail_x15_r0_body.ciS48).all (fun i => Nat.blt (i / 4096) (4 ^ 31)) = true
kernel_rfl PRE_first_tail_x15_r0_body.fincW48 : PRE_first_tail_x15_r0_body.cwS48.all (fun h => !Nat.blt h (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s476.ffi).mlx.next || PRE_first_tail_x15_r0_body.clo48.contains h) = true
kernel_rfl PRE_first_tail_x15_r0_body.fincI48 : PRE_first_tail_x15_r0_body.ciS48.all (fun k => !Nat.blt k (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s476.ffi).mlx.nnext || PRE_first_tail_x15_r0_body.cli48.contains k) = true
kernel_rfl PRE_first_tail_x15_r0_body.fincN48 : PRE_first_tail_x15_r0_body.cnS48.all (Nat.ble (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s476.ffi).mlx.nnext) = true
kernel_rfl PRE_first_tail_x15_r0_body.flnF48 : PRE_first_tail_x15_r0_body.cln48.all (Nat.ble (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s476.ffi).mlx.nnext) = true
-- the checks over the changed lists
kernel_rfl PRE_first_tail_x15_r0_body.fh48 : PRE_first_tail_x15_r0_body.clo48.all (handleOK PRE_first_tail_x15_r0_body.kappa48 PRE_first_tail_x15_r0_body.P48.lo PRE_first_tail_x15_r0_body.cx0_48.mlx PRE_first_tail_x15_r0_body.cx1_48.mlx) = true
kernel_rfl PRE_first_tail_x15_r0_body.fo48 : PRE_first_tail_x15_r0_body.clo48.map (fun h => PRE_first_tail_x15_r0_body.cx1_48.mlx.objs.get (PRE_first_tail_x15_r0_body.kappa48.handle h)) = PRE_first_tail_x15_r0_body.clo48.map (fun h => (PRE_first_tail_x15_r0_body.cx0_48.mlx.objs.get h).map PRE_first_tail_x15_r0_body.kappa48.nobj)
kernel_rfl PRE_first_tail_x15_r0_body.fok48 : PRE_first_tail_x15_r0_body.clo48.all (objOK PRE_first_tail_x15_r0_body.kappa48 PRE_first_tail_x15_r0_body.P48.NL PRE_first_tail_x15_r0_body.cx0_48.mlx) = true
kernel_rfl PRE_first_tail_x15_r0_body.fnd48 : PRE_first_tail_x15_r0_body.cln48.all (nodeOKF PRE_first_tail_x15_r0_body.kappa48 PRE_first_tail_x15_r0_body.P48 PRE_first_tail_x15_r0_body.cx0_48.mlx PRE_first_tail_x15_r0_body.cx1_48.mlx) = true
kernel_rfl PRE_first_tail_x15_r0_body.fp48 : ((PRE_first_tail_x15_r0_body.cln48.filter (fullB PRE_first_tail_x15_r0_body.P48))).map (fun i => (PRE_first_tail_x15_r0_body.cx1_48.mlx.nodes.get (PRE_first_tail_x15_r0_body.kappa48.node i)).map Host.Mlx.Ffi.Node.prim) =
  ((PRE_first_tail_x15_r0_body.cln48.filter (fullB PRE_first_tail_x15_r0_body.P48))).map (fun i => (PRE_first_tail_x15_r0_body.cx0_48.mlx.nodes.get i).map fun nd => PRE_first_tail_x15_r0_body.kappa48.prim nd.prim)
kernel_rfl PRE_first_tail_x15_r0_body.fnordI48 : incrB PRE_first_tail_x15_r0_body.kd48.nodeF (List.range' 16226 27) = true
kernel_rfl PRE_first_tail_x15_r0_body.fnordK48 : (PTrie.keysA PRE_first_tail_x15_r0_body.kd48.node).all (fun k => Nat.ble 16226 k && Nat.blt k 16253) = true
kernel_rfl PRE_first_tail_x15_r0_body.fnordL48 : (PRE_first_tail_x15_r0_body.cln48.filter (Nat.ble PRE_first_tail_x15_r0_body.P48.N0)).all (fun i => Nat.ble i (PRE_first_tail_x15_r0_body.kd48.nodeF i) && (Nat.blt i 16253 || Nat.ble PRE_first_tail_x15_r0_body.kd48.nn0 i)) = true
theorem PRE_first_tail_x15_r0_body.fnord48 : (PRE_first_tail_x15_r0_body.cln48.filter (Nat.ble PRE_first_tail_x15_r0_body.P48.N0)).all (fun i => Nat.ble i (PRE_first_tail_x15_r0_body.kd48.nodeF i) &&
    (PTrie.keysA PRE_first_tail_x15_r0_body.kd48.node).all fun j => !Nat.blt j i || Nat.blt (PRE_first_tail_x15_r0_body.kd48.nodeF j) (PRE_first_tail_x15_r0_body.kd48.nodeF i)) = true :=
  cnord_of PRE_first_tail_x15_r0_body.cnlow48 PRE_first_tail_x15_r0_body.cnn148 PRE_first_tail_x15_r0_body.fnordI48 PRE_first_tail_x15_r0_body.fnordK48 PRE_first_tail_x15_r0_body.fnordL48
kernel_rfl PRE_first_tail_x15_r0_body.fi48 : PRE_first_tail_x15_r0_body.cli48.all (pnB PRE_first_tail_x15_r0_body.cx0_48.mlx) = true
kernel_rfl PRE_first_tail_x15_r0_body.fii48 : PRE_first_tail_x15_r0_body.cli48.all (fun k => decide (PRE_first_tail_x15_r0_body.cx1_48.mlx.items.get (PRE_first_tail_x15_r0_body.kappa48.node k) = (PRE_first_tail_x15_r0_body.cx0_48.mlx.items.get k).map PRE_first_tail_x15_r0_body.kappa48.nv)) = true
/-- **The compaction's footprint.** -/
theorem PRE_first_tail_x15_r0_body.cfoot48 (clean : Conv.NClean (⟨19160, 16226, 2713123, 2135⟩ : Conv.Cnt) (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s476.ffi).mlx) (hltC : ∀ h, PH (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s476.ffi).mlx h → h < (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s476.ffi).mlx.next) (nltC : ∀ i, PN (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s476.ffi).mlx i → i < (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s476.ffi).mlx.nnext) (itemsC : ∀ k v, (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s476.ffi).mlx.items.get k = some v → PN (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s476.ffi).mlx k) (tracedC : ∀ h o, (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s476.ffi).mlx.objs.get h = some o → ∀ i ∈ objTraces o, i < PRE_first_tail_x15_r0_body.P48.NL) (cl : SSt (· < 2153) PRE_first_tail_x15_r0_body.cx0_48.mlx) :
    Conv.MFoot PRE_first_tail_x15_r0_body.P48 2153 PRE_first_tail_x15_r0_body.kappa48 PRE_first_tail_x15_r0_body.kd48 PRE_first_tail_x15_r0_body.khinv48 PRE_first_tail_x15_r0_body.kninv48 (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s476.ffi).mlx PRE_first_tail_x15_r0_body.cx0_48.mlx PRE_first_tail_x15_r0_body.cx1_48.mlx (⟨19160, 16226, 2713123, 2135⟩ : Conv.Cnt) PRE_first_tail_x15_r0_body.clo48 PRE_first_tail_x15_r0_body.cln48 PRE_first_tail_x15_r0_body.cli48 PRE_first_tail_x15_r0_body.cwS48 PRE_first_tail_x15_r0_body.cnS48 PRE_first_tail_x15_r0_body.ciS48 :=
  ⟨rfl, rfl, rfl, PRE_first_tail_x15_r0_body.cnh048, PRE_first_tail_x15_r0_body.cnh148, PRE_first_tail_x15_r0_body.cnn048, PRE_first_tail_x15_r0_body.cnn148, PRE_first_tail_x15_r0_body.cplo48, PRE_first_tail_x15_r0_body.ccnt48, PRE_first_tail_x15_r0_body.cnband48, PRE_first_tail_x15_r0_body.chbelow48, PRE_first_tail_x15_r0_body.chren48, PRE_first_tail_x15_r0_body.cband48, PRE_first_tail_x15_r0_body.cnh1pos48, PRE_first_tail_x15_r0_body.cnren48, PRE_first_tail_x15_r0_body.cnlow48, PRE_first_tail_x15_r0_body.cabs0a48, PRE_first_tail_x15_r0_body.cabs0b48, PRE_first_tail_x15_r0_body.ctok148, PRE_first_tail_x15_r0_body.cpend48, PRE_first_tail_x15_r0_body.cerrh48, PRE_first_tail_x15_r0_body.cfiles48, PRE_first_tail_x15_r0_body.carch48, PRE_first_tail_x15_r0_body.csizes48, PRE_first_tail_x15_r0_body.cwired48, PRE_first_tail_x15_r0_body.cfix48, clean, PRE_first_tail_x15_r0_body.fcxn48, PRE_first_tail_x15_r0_body.fcnn48, hltC, nltC, itemsC, tracedC, cl, PRE_first_tail_x15_r0_body.fle048, PRE_first_tail_x15_r0_body.fnk48, PRE_first_tail_x15_r0_body.ckA48, PRE_first_tail_x15_r0_body.cobjsK48, PRE_first_tail_x15_r0_body.cnodesK48, PRE_first_tail_x15_r0_body.citemsK48, PRE_first_tail_x15_r0_body.f1A48, PRE_first_tail_x15_r0_body.f1O48, PRE_first_tail_x15_r0_body.f1N48, PRE_first_tail_x15_r0_body.f1I48, PRE_first_tail_x15_r0_body.fbd48, PRE_first_tail_x15_r0_body.fincW48, PRE_first_tail_x15_r0_body.fincI48, PRE_first_tail_x15_r0_body.fincN48, PRE_first_tail_x15_r0_body.flnF48, PRE_first_tail_x15_r0_body.fh48, PRE_first_tail_x15_r0_body.fo48, PRE_first_tail_x15_r0_body.fok48, PRE_first_tail_x15_r0_body.fnd48, PRE_first_tail_x15_r0_body.fp48, PRE_first_tail_x15_r0_body.fnord48, PRE_first_tail_x15_r0_body.fi48, PRE_first_tail_x15_r0_body.fii48⟩
theorem PRE_first_tail_x15_r0_body.cnshift48 (clean : Conv.NClean (⟨19160, 16226, 2713123, 2135⟩ : Conv.Cnt) (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s476.ffi).mlx) (hltC : ∀ h, PH (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s476.ffi).mlx h → h < (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s476.ffi).mlx.next) (nltC : ∀ i, PN (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s476.ffi).mlx i → i < (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s476.ffi).mlx.nnext) (itemsC : ∀ k v, (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s476.ffi).mlx.items.get k = some v → PN (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s476.ffi).mlx k) (tracedC : ∀ h o, (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s476.ffi).mlx.objs.get h = some o → ∀ i ∈ objTraces o, i < PRE_first_tail_x15_r0_body.P48.NL) (cl : SSt (· < 2153) PRE_first_tail_x15_r0_body.cx0_48.mlx) : NShift PRE_first_tail_x15_r0_body.P48 2153 PRE_first_tail_x15_r0_body.kappa48 PRE_first_tail_x15_r0_body.cx0_48 PRE_first_tail_x15_r0_body.cx1_48 :=
  Conv.nshift_of_foot (PRE_first_tail_x15_r0_body.cfoot48 clean hltC nltC itemsC tracedC cl) PRE_first_tail_x15_r0_body.chost48 (compact_a_eq PRE_first_tail_x15_r0_body.ckn048 PRE_first_tail_x15_r0_body.ckn148 PRE_first_tail_x15_r0_body.ckheap48 PRE_first_tail_x15_r0_body.ckpl48)

-- the observers: the layers' states at the call, the canonical and the merged state, their footprints and checks
noncomputable def PRE_first_tail_x15_r0_body.fxC_48 : PTrie Unit := (Host.Ts.Sim.Full.freedOf PRE_first_tail_x15_r0_body.s476.ffi).getD PTrie.nil
noncomputable def PRE_first_tail_x15_r0_body.krC_48 : Host.Load.Layers.KRec := (Host.Ts.Sim.Full.krecOf PRE_first_tail_x15_r0_body.s476.ffi).getD Host.Load.Layers.KRec.empty
kernel_rfl PRE_first_tail_x15_r0_body.ofxC_48 : (Host.Ts.Sim.Full.freedOf PRE_first_tail_x15_r0_body.s476.ffi) = some PRE_first_tail_x15_r0_body.fxC_48
kernel_rfl PRE_first_tail_x15_r0_body.okrC_48 : (Host.Ts.Sim.Full.krecOf PRE_first_tail_x15_r0_body.s476.ffi) = some PRE_first_tail_x15_r0_body.krC_48
noncomputable def PRE_first_tail_x15_r0_body.fx0_48 : PTrie Unit := (Host.Ts.Sim.Full.freedOf PRE_first_tail_x15_r0_body.s478.ffi).getD PTrie.nil
noncomputable def PRE_first_tail_x15_r0_body.kr0_48 : Host.Load.Layers.KRec := (Host.Ts.Sim.Full.krecOf PRE_first_tail_x15_r0_body.s478.ffi).getD Host.Load.Layers.KRec.empty
kernel_rfl PRE_first_tail_x15_r0_body.ofx0_48 : (Host.Ts.Sim.Full.freedOf PRE_first_tail_x15_r0_body.s478.ffi) = some PRE_first_tail_x15_r0_body.fx0_48
kernel_rfl PRE_first_tail_x15_r0_body.okr0_48 : (Host.Ts.Sim.Full.krecOf PRE_first_tail_x15_r0_body.s478.ffi) = some PRE_first_tail_x15_r0_body.kr0_48
noncomputable def PRE_first_tail_x15_r0_body.fx1_48 : PTrie Unit := (Host.Ts.Sim.Full.freedOf PRE_first_tail_x15_r0_body.s477.ffi).getD PTrie.nil
noncomputable def PRE_first_tail_x15_r0_body.kr1_48 : Host.Load.Layers.KRec := (Host.Ts.Sim.Full.krecOf PRE_first_tail_x15_r0_body.s477.ffi).getD Host.Load.Layers.KRec.empty
kernel_rfl PRE_first_tail_x15_r0_body.ofx1_48 : (Host.Ts.Sim.Full.freedOf PRE_first_tail_x15_r0_body.s477.ffi) = some PRE_first_tail_x15_r0_body.fx1_48
kernel_rfl PRE_first_tail_x15_r0_body.okr1_48 : (Host.Ts.Sim.Full.krecOf PRE_first_tail_x15_r0_body.s477.ffi) = some PRE_first_tail_x15_r0_body.kr1_48
kernel_rfl PRE_first_tail_x15_r0_body.ff048 : PRE_first_tail_x15_r0_body.fx0_48 = Stage.setAll PRE_first_tail_x15_r0_body.fxC_48 (PRE_first_tail_x15_r0_body.clo48.filterMap fun i => (PRE_first_tail_x15_r0_body.fx0_48.get i).map (i, ·))
kernel_rfl PRE_first_tail_x15_r0_body.ff148 : PRE_first_tail_x15_r0_body.fx1_48 = Stage.setAll PRE_first_tail_x15_r0_body.fxC_48 (PRE_first_tail_x15_r0_body.cwS48.filterMap fun i => (PRE_first_tail_x15_r0_body.fx1_48.get i).map (i, ·))
kernel_rfl PRE_first_tail_x15_r0_body.ffck48 : freedLB PRE_first_tail_x15_r0_body.kappa48 PRE_first_tail_x15_r0_body.cx0_48.mlx PRE_first_tail_x15_r0_body.fx0_48 PRE_first_tail_x15_r0_body.fx1_48 PRE_first_tail_x15_r0_body.clo48 = true
kernel_rfl PRE_first_tail_x15_r0_body.fkf048 : PRE_first_tail_x15_r0_body.kr0_48.flags = Stage.setAll PRE_first_tail_x15_r0_body.krC_48.flags (PRE_first_tail_x15_r0_body.clo48.filterMap fun i => (PRE_first_tail_x15_r0_body.kr0_48.flags.get i).map (i, ·))
kernel_rfl PRE_first_tail_x15_r0_body.fkt048 : PRE_first_tail_x15_r0_body.kr0_48.targs = Stage.setAll PRE_first_tail_x15_r0_body.krC_48.targs (PRE_first_tail_x15_r0_body.clo48.filterMap fun i => (PRE_first_tail_x15_r0_body.kr0_48.targs.get i).map (i, ·))
kernel_rfl PRE_first_tail_x15_r0_body.fkf148 : PRE_first_tail_x15_r0_body.kr1_48.flags = Stage.setAll PRE_first_tail_x15_r0_body.krC_48.flags (PRE_first_tail_x15_r0_body.cwS48.filterMap fun i => (PRE_first_tail_x15_r0_body.kr1_48.flags.get i).map (i, ·))
kernel_rfl PRE_first_tail_x15_r0_body.fkt148 : PRE_first_tail_x15_r0_body.kr1_48.targs = Stage.setAll PRE_first_tail_x15_r0_body.krC_48.targs (PRE_first_tail_x15_r0_body.cwS48.filterMap fun i => (PRE_first_tail_x15_r0_body.kr1_48.targs.get i).map (i, ·))
kernel_rfl PRE_first_tail_x15_r0_body.fkck48 : krecLB PRE_first_tail_x15_r0_body.kappa48 2153 PRE_first_tail_x15_r0_body.cx0_48.mlx PRE_first_tail_x15_r0_body.kr0_48 PRE_first_tail_x15_r0_body.kr1_48 PRE_first_tail_x15_r0_body.clo48 = true
kernel_rfl PRE_first_tail_x15_r0_body.fkn48 : Nat.ble 2135 2153 = true
-- the bridge and the pending traces' regions
kernel_rfl PRE_first_tail_x15_r0_body.cbridge48 : Host.Ts.Sim.Full.bridgeOf PRE_first_tail_x15_r0_body.s477.ffi = Host.Ts.Sim.Full.bridgeOf PRE_first_tail_x15_r0_body.s478.ffi
kernel_rfl PRE_first_tail_x15_r0_body.cpendR48 : pendRegB PRE_first_tail_x15_r0_body.kappa48 (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s478.ffi).mlx = true
kernel_rfl PRE_first_tail_x15_r0_body.cpendLe48 : Nat.ble (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s478.ffi).mlx.next (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s477.ffi).mlx.next = true
/-- **The compaction's native shift**, given the call's bookkeeping, its relation's facts (the model's and the
observers') and the canonical closedness. -/
theorem PRE_first_tail_x15_r0_body.cshift48 (clean : Conv.NClean (⟨19160, 16226, 2713123, 2135⟩ : Conv.Cnt) (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s476.ffi).mlx) (hltC : ∀ h, PH (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s476.ffi).mlx h → h < (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s476.ffi).mlx.next) (nltC : ∀ i, PN (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s476.ffi).mlx i → i < (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s476.ffi).mlx.nnext) (itemsC : ∀ k v, (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s476.ffi).mlx.items.get k = some v → PN (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s476.ffi).mlx k) (tracedC : ∀ h o, (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s476.ffi).mlx.objs.get h = some o → ∀ i ∈ objTraces o, i < PRE_first_tail_x15_r0_body.P48.NL) (cl : SSt (· < 2153) PRE_first_tail_x15_r0_body.cx0_48.mlx)
    (hobjC : ∀ h, PRE_first_tail_x15_r0_body.fxC_48.get h = some () → ((Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s476.ffi).mlx.objs.get h).isSome = true)
    (hfC : ∀ h, (PRE_first_tail_x15_r0_body.krC_48.flags.get h).isSome = true → ((Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s476.ffi).mlx.objs.get h).isSome = true)
    (htC : ∀ h, (PRE_first_tail_x15_r0_body.krC_48.targs.get h).isSome = true → ((Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s476.ffi).mlx.objs.get h).isSome = true)
    (hclC : ∀ h l, PRE_first_tail_x15_r0_body.krC_48.targs.get h = some l → Host.Ts.Sim.Full.STargs (· < (⟨19160, 16226, 2713123, 2135⟩ : Conv.Cnt).n) l) :
    Conv.FullShiftQ PRE_first_tail_x15_r0_body.P48 2153 PRE_first_tail_x15_r0_body.kappa48 PRE_first_tail_x15_r0_body.s478.ffi PRE_first_tail_x15_r0_body.s477.ffi :=
  ⟨PRE_first_tail_x15_r0_body.cnshift48 clean hltC nltC itemsC tracedC cl, PRE_first_tail_x15_r0_body.cqueue48, fun t ht => bSN_sound (List.all_eq_true.mp PRE_first_tail_x15_r0_body.ctokSupp48 t ht),
    PRE_first_tail_x15_r0_body.cbridge48,
    liveShift_foot (x0' := Host.Ts.Sim.Full.mlxOf PRE_first_tail_x15_r0_body.s478.ffi) (x1' := Host.Ts.Sim.Full.mlxOf PRE_first_tail_x15_r0_body.s477.ffi) (PRE_first_tail_x15_r0_body.cfoot48 clean hltC nltC itemsC tracedC cl) rfl PRE_first_tail_x15_r0_body.ofx0_48 PRE_first_tail_x15_r0_body.ofx1_48 hobjC PRE_first_tail_x15_r0_body.ff048 PRE_first_tail_x15_r0_body.ff148 PRE_first_tail_x15_r0_body.ffck48,
    kernShift_foot (x0' := Host.Ts.Sim.Full.mlxOf PRE_first_tail_x15_r0_body.s478.ffi) (x1' := Host.Ts.Sim.Full.mlxOf PRE_first_tail_x15_r0_body.s477.ffi) (PRE_first_tail_x15_r0_body.cfoot48 clean hltC nltC itemsC tracedC cl) rfl PRE_first_tail_x15_r0_body.okr0_48 PRE_first_tail_x15_r0_body.okr1_48 (Nat.le_of_ble_eq_true PRE_first_tail_x15_r0_body.fkn48) hfC htC hclC
      PRE_first_tail_x15_r0_body.fkf048 PRE_first_tail_x15_r0_body.fkt048 PRE_first_tail_x15_r0_body.fkf148 PRE_first_tail_x15_r0_body.fkt148 PRE_first_tail_x15_r0_body.fkck48,
    pendReg_of rfl PRE_first_tail_x15_r0_body.cnh048 PRE_first_tail_x15_r0_body.cnh148 (Nat.le_of_ble_eq_true PRE_first_tail_x15_r0_body.cpendLe48) PRE_first_tail_x15_r0_body.cpendR48⟩

end Host.Load.Run.Tpl
