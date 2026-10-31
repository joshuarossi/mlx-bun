import host.sim.template.a4pre_first_tail_x15_r0_body.SiteCl146
import host.sim.conv.CompactFull
import host.sim.template.FootGen
set_option Elab.async false
namespace Host.Load.Run.Tpl
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
open Host.Ts Host.Ts.Sim Host.Ts.Sim.Template

/-! The compaction's native shift at call site 146 from its footprint (`Conv.nshift_of_foot`), and the observers'
(`liveShift_foot`, `kernShift_foot`): `Conv.FullShiftQ` for `Conv.full_compactQ`, given the call's bookkeeping and its
relation's facts. -/

/-- The load parameters of the chain (band-free: its start's node counter as `NL` and `N0`). -/
def PRE_first_tail_x15_r0_body.Pc146 : LoadP := ⟨18151, 131072, 1099511627776, 15235, 15235, []⟩
/-- The site's band raised to the map's checked fixed-node prefix, including newly recorded closure traces. -/
def PRE_first_tail_x15_r0_body.P146 : LoadP := PRE_first_tail_x15_r0_body.Pc146.raise 18166
kernel_rfl PRE_first_tail_x15_r0_body.craise146 : Nat.ble PRE_first_tail_x15_r0_body.Pc146.N0 18166 = true
theorem PRE_first_tail_x15_r0_body.raised146 : Host.Ts.Sim.Full.Raised PRE_first_tail_x15_r0_body.Pc146 PRE_first_tail_x15_r0_body.P146 :=
  .inr ⟨18166, rfl, Nat.le_of_ble_eq_true PRE_first_tail_x15_r0_body.craise146, rfl⟩
noncomputable abbrev PRE_first_tail_x15_r0_body.cx0_146 : Host.Load.LSt := clearTokens (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1287.ffi)
noncomputable abbrev PRE_first_tail_x15_r0_body.cx1_146 : Host.Load.LSt := clearTokens (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1286.ffi)
def PRE_first_tail_x15_r0_body.khinv146 : PTrie Nat := Stage.setAll PTrie.nil []
def PRE_first_tail_x15_r0_body.kninv146 : PTrie Nat := Stage.setAll PTrie.nil []
/-- The stage's footprint: its written and fresh handles, fresh nodes, written and fresh items. -/
def PRE_first_tail_x15_r0_body.cwS146 : List Nat := []
def PRE_first_tail_x15_r0_body.cnS146 : List Nat := List.range' 18166 0
def PRE_first_tail_x15_r0_body.ciS146 : List Nat := [] ++ List.range' 18166 0

-- the small checks (`MChecks`'s)
kernel_rfl PRE_first_tail_x15_r0_body.cnh0146 : PRE_first_tail_x15_r0_body.kd146.nh0 = PRE_first_tail_x15_r0_body.cx0_146.mlx.next
kernel_rfl PRE_first_tail_x15_r0_body.cnh1146 : PRE_first_tail_x15_r0_body.kd146.nh1 = PRE_first_tail_x15_r0_body.cx1_146.mlx.next
kernel_rfl PRE_first_tail_x15_r0_body.cnn0146 : PRE_first_tail_x15_r0_body.kd146.nn0 = PRE_first_tail_x15_r0_body.cx0_146.mlx.nnext
kernel_rfl PRE_first_tail_x15_r0_body.cnn1146 : PRE_first_tail_x15_r0_body.kd146.nn1 = PRE_first_tail_x15_r0_body.cx1_146.mlx.nnext
kernel_rfl PRE_first_tail_x15_r0_body.cplo146 : (Nat.blt 0 PRE_first_tail_x15_r0_body.P146.lo && Nat.ble PRE_first_tail_x15_r0_body.P146.lo PRE_first_tail_x15_r0_body.cx0_146.mlx.next && Nat.ble PRE_first_tail_x15_r0_body.P146.lo RData.bigHi && Nat.ble RData.bigHi PRE_first_tail_x15_r0_body.P146.E) = true
kernel_rfl PRE_first_tail_x15_r0_body.ccnt146 : (Nat.ble PRE_first_tail_x15_r0_body.cx0_146.mlx.next PRE_first_tail_x15_r0_body.cx1_146.mlx.next && Nat.ble PRE_first_tail_x15_r0_body.cx0_146.mlx.nnext PRE_first_tail_x15_r0_body.cx1_146.mlx.nnext) = true
kernel_rfl PRE_first_tail_x15_r0_body.cnband146 : (Nat.blt 0 PRE_first_tail_x15_r0_body.P146.NL && Nat.ble PRE_first_tail_x15_r0_body.P146.NL PRE_first_tail_x15_r0_body.P146.N0 && Nat.ble PRE_first_tail_x15_r0_body.P146.N0 PRE_first_tail_x15_r0_body.cx0_146.mlx.nnext) = true
kernel_rfl PRE_first_tail_x15_r0_body.chbelow146 : PRE_first_tail_x15_r0_body.kd146.checkHndBelow = true
kernel_rfl PRE_first_tail_x15_r0_body.chren146 : checkRenG PRE_first_tail_x15_r0_body.kd146.hnd PRE_first_tail_x15_r0_body.khinv146 (phB PRE_first_tail_x15_r0_body.cx0_146.mlx) = true
kernel_rfl PRE_first_tail_x15_r0_body.cband146 : PRE_first_tail_x15_r0_body.kd146.checkBand PRE_first_tail_x15_r0_body.P146.lo = true
kernel_rfl PRE_first_tail_x15_r0_body.cnh1pos146 : Nat.blt 0 PRE_first_tail_x15_r0_body.kd146.nh1 = true
kernel_rfl PRE_first_tail_x15_r0_body.cnren146 : checkRenG PRE_first_tail_x15_r0_body.kd146.node PRE_first_tail_x15_r0_body.kninv146 (pnB PRE_first_tail_x15_r0_body.cx0_146.mlx) = true
kernel_rfl PRE_first_tail_x15_r0_body.cnlow146 : (PTrie.keysA PRE_first_tail_x15_r0_body.kd146.node).all (fun j => Nat.ble PRE_first_tail_x15_r0_body.P146.NL j && Nat.blt (PRE_first_tail_x15_r0_body.kd146.nodeF j) PRE_first_tail_x15_r0_body.cx1_146.mlx.nnext) = true
kernel_rfl PRE_first_tail_x15_r0_body.cabs0a146 : PRE_first_tail_x15_r0_body.cx0_146.mlx.arrs.get 0 = none
kernel_rfl PRE_first_tail_x15_r0_body.cabs0b146 : PRE_first_tail_x15_r0_body.cx0_146.mlx.objs.get 0 = none
kernel_rfl PRE_first_tail_x15_r0_body.ctok1146 : PRE_first_tail_x15_r0_body.cx1_146.mlx.tokens = []
kernel_rfl PRE_first_tail_x15_r0_body.cpend146 : PRE_first_tail_x15_r0_body.cx1_146.mlx.pending = PRE_first_tail_x15_r0_body.cx0_146.mlx.pending.map PRE_first_tail_x15_r0_body.kappa146.pend
kernel_rfl PRE_first_tail_x15_r0_body.cerrh146 : PRE_first_tail_x15_r0_body.cx1_146.mlx.errh = PRE_first_tail_x15_r0_body.cx0_146.mlx.errh.map PRE_first_tail_x15_r0_body.kappa146.arg
kernel_rfl PRE_first_tail_x15_r0_body.cfiles146 : PRE_first_tail_x15_r0_body.cx1_146.mlx.files = PRE_first_tail_x15_r0_body.cx0_146.mlx.files
kernel_rfl PRE_first_tail_x15_r0_body.carch146 : PRE_first_tail_x15_r0_body.cx1_146.mlx.arch = PRE_first_tail_x15_r0_body.cx0_146.mlx.arch
kernel_rfl PRE_first_tail_x15_r0_body.csizes146 : PRE_first_tail_x15_r0_body.cx1_146.mlx.deviceSizes = PRE_first_tail_x15_r0_body.cx0_146.mlx.deviceSizes
kernel_rfl PRE_first_tail_x15_r0_body.cwired146 : PRE_first_tail_x15_r0_body.cx1_146.mlx.wired = PRE_first_tail_x15_r0_body.cx0_146.mlx.wired
kernel_rfl PRE_first_tail_x15_r0_body.chost146 : PRE_first_tail_x15_r0_body.cx1_146.host = PRE_first_tail_x15_r0_body.cx0_146.host
-- the compaction map's addresses are `PRE_first_tail_x15_r0_body.kd146`'s
kernel_rfl PRE_first_tail_x15_r0_body.ckn0146 : PRE_first_tail_x15_r0_body.kd146.n0 = 2789244
kernel_rfl PRE_first_tail_x15_r0_body.ckn1146 : PRE_first_tail_x15_r0_body.kd146.n1 = 2789263
kernel_rfl PRE_first_tail_x15_r0_body.ckheap146 : (PTrie.keysA PRE_first_tail_x15_r0_body.kd146.heap).all (fun x => Nat.ble 2789243 x) = true
kernel_rfl PRE_first_tail_x15_r0_body.ckpl146 : (List.range 1).all (fun j => decide (PRE_first_tail_x15_r0_body.kd146.heap.get (2789243 + j) = nth? PRE_first_tail_x15_r0_body.pl146 j)) = true
-- the map fixes the call's names (`Conv.fixOld_compact`), the call's counters
kernel_rfl PRE_first_tail_x15_r0_body.fja146 : Nat.ble 2789243 2789243 = true
kernel_rfl PRE_first_tail_x15_r0_body.fn146 : Nat.ble 6295 6295 = true
kernel_rfl PRE_first_tail_x15_r0_body.fjaD146 : Nat.ble 2789243 PRE_first_tail_x15_r0_body.kd146.n0 = true
kernel_rfl PRE_first_tail_x15_r0_body.fxn146 : Nat.ble 21071 PRE_first_tail_x15_r0_body.kd146.nh0 = true
kernel_rfl PRE_first_tail_x15_r0_body.fnn146 : Nat.ble 18166 PRE_first_tail_x15_r0_body.kd146.nn0 = true
kernel_rfl PRE_first_tail_x15_r0_body.fxb146 : Nat.ble 21071 RData.bigHi = true
kernel_rfl PRE_first_tail_x15_r0_body.fheap146 : (PTrie.keysA PRE_first_tail_x15_r0_body.kd146.heap).all (Nat.ble (⟨21071, 18166, 2789243, 6295⟩ : Conv.Cnt).ja) = true
kernel_rfl PRE_first_tail_x15_r0_body.fhnd146 : (PTrie.keysA PRE_first_tail_x15_r0_body.kd146.hnd).all (Nat.ble (⟨21071, 18166, 2789243, 6295⟩ : Conv.Cnt).xn) = true
kernel_rfl PRE_first_tail_x15_r0_body.fnode146 : (PTrie.keysA PRE_first_tail_x15_r0_body.kd146.node).all (Nat.ble (⟨21071, 18166, 2789243, 6295⟩ : Conv.Cnt).nn) = true
/-- The compaction map fixes the call's names. -/
theorem PRE_first_tail_x15_r0_body.cfix146 : Conv.FixOld (⟨21071, 18166, 2789243, 6295⟩ : Conv.Cnt) PRE_first_tail_x15_r0_body.kappa146 :=
  Conv.fixOld_compact (Nat.le_of_ble_eq_true PRE_first_tail_x15_r0_body.fja146) (Nat.le_of_ble_eq_true PRE_first_tail_x15_r0_body.fn146) (Nat.le_of_ble_eq_true PRE_first_tail_x15_r0_body.fjaD146) (Nat.le_of_ble_eq_true PRE_first_tail_x15_r0_body.fxn146) (Nat.le_of_ble_eq_true PRE_first_tail_x15_r0_body.fnn146) (Nat.le_of_ble_eq_true PRE_first_tail_x15_r0_body.fxb146) PRE_first_tail_x15_r0_body.fheap146 PRE_first_tail_x15_r0_body.fhnd146 PRE_first_tail_x15_r0_body.fnode146
kernel_rfl PRE_first_tail_x15_r0_body.fcxn146 : (⟨21071, 18166, 2789243, 6295⟩ : Conv.Cnt).xn = (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1285.ffi).mlx.next
kernel_rfl PRE_first_tail_x15_r0_body.fcnn146 : (⟨21071, 18166, 2789243, 6295⟩ : Conv.Cnt).nn = (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1285.ffi).mlx.nnext
kernel_rfl PRE_first_tail_x15_r0_body.fle0146 : (Nat.ble (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1285.ffi).mlx.next PRE_first_tail_x15_r0_body.cx0_146.mlx.next && Nat.ble (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1285.ffi).mlx.nnext PRE_first_tail_x15_r0_body.cx0_146.mlx.nnext && Nat.ble (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1285.ffi).mlx.next RData.bigHi) = true
kernel_rfl PRE_first_tail_x15_r0_body.fnk146 : (PTrie.keysA PRE_first_tail_x15_r0_body.kd146.node).all (Nat.ble (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1285.ffi).mlx.nnext) = true
-- the merged state keeps the call's entries off the stage's footprint
kernel_rfl PRE_first_tail_x15_r0_body.f1A146 : PRE_first_tail_x15_r0_body.cx1_146.mlx.arrs = Stage.setAll (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1285.ffi).mlx.arrs (PRE_first_tail_x15_r0_body.cwS146.filterMap fun i => (PRE_first_tail_x15_r0_body.cx1_146.mlx.arrs.get i).map (i, ·))
kernel_rfl PRE_first_tail_x15_r0_body.f1O146 : PRE_first_tail_x15_r0_body.cx1_146.mlx.objs = Stage.setAll (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1285.ffi).mlx.objs (PRE_first_tail_x15_r0_body.cwS146.filterMap fun i => (PRE_first_tail_x15_r0_body.cx1_146.mlx.objs.get i).map (i, ·))
kernel_rfl PRE_first_tail_x15_r0_body.f1N146 : PRE_first_tail_x15_r0_body.cx1_146.mlx.nodes = Stage.setAll (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1285.ffi).mlx.nodes (PRE_first_tail_x15_r0_body.cnS146.filterMap fun i => (PRE_first_tail_x15_r0_body.cx1_146.mlx.nodes.get i).map (i, ·))
kernel_rfl PRE_first_tail_x15_r0_body.f1I146 : PRE_first_tail_x15_r0_body.cx1_146.mlx.items = Stage.setAll (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1285.ffi).mlx.items (PRE_first_tail_x15_r0_body.ciS146.filterMap fun i => (PRE_first_tail_x15_r0_body.cx1_146.mlx.items.get i).map (i, ·))
kernel_rfl PRE_first_tail_x15_r0_body.fbd146 : (PRE_first_tail_x15_r0_body.clo146 ++ PRE_first_tail_x15_r0_body.cln146 ++ PRE_first_tail_x15_r0_body.cli146 ++ PRE_first_tail_x15_r0_body.cwS146 ++ PRE_first_tail_x15_r0_body.cnS146 ++ PRE_first_tail_x15_r0_body.ciS146).all (fun i => Nat.blt (i / 4096) (4 ^ 31)) = true
kernel_rfl PRE_first_tail_x15_r0_body.fincW146 : PRE_first_tail_x15_r0_body.cwS146.all (fun h => !Nat.blt h (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1285.ffi).mlx.next || PRE_first_tail_x15_r0_body.clo146.contains h) = true
kernel_rfl PRE_first_tail_x15_r0_body.fincI146 : PRE_first_tail_x15_r0_body.ciS146.all (fun k => !Nat.blt k (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1285.ffi).mlx.nnext || PRE_first_tail_x15_r0_body.cli146.contains k) = true
kernel_rfl PRE_first_tail_x15_r0_body.fincN146 : PRE_first_tail_x15_r0_body.cnS146.all (Nat.ble (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1285.ffi).mlx.nnext) = true
kernel_rfl PRE_first_tail_x15_r0_body.flnF146 : PRE_first_tail_x15_r0_body.cln146.all (Nat.ble (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1285.ffi).mlx.nnext) = true
-- the checks over the changed lists
kernel_rfl PRE_first_tail_x15_r0_body.fh146 : PRE_first_tail_x15_r0_body.clo146.all (handleOK PRE_first_tail_x15_r0_body.kappa146 PRE_first_tail_x15_r0_body.P146.lo PRE_first_tail_x15_r0_body.cx0_146.mlx PRE_first_tail_x15_r0_body.cx1_146.mlx) = true
kernel_rfl PRE_first_tail_x15_r0_body.fo146 : PRE_first_tail_x15_r0_body.clo146.map (fun h => PRE_first_tail_x15_r0_body.cx1_146.mlx.objs.get (PRE_first_tail_x15_r0_body.kappa146.handle h)) = PRE_first_tail_x15_r0_body.clo146.map (fun h => (PRE_first_tail_x15_r0_body.cx0_146.mlx.objs.get h).map PRE_first_tail_x15_r0_body.kappa146.nobj)
kernel_rfl PRE_first_tail_x15_r0_body.fok146 : PRE_first_tail_x15_r0_body.clo146.all (objOK PRE_first_tail_x15_r0_body.kappa146 PRE_first_tail_x15_r0_body.P146.NL PRE_first_tail_x15_r0_body.cx0_146.mlx) = true
kernel_rfl PRE_first_tail_x15_r0_body.fnd146 : PRE_first_tail_x15_r0_body.cln146.all (nodeOKF PRE_first_tail_x15_r0_body.kappa146 PRE_first_tail_x15_r0_body.P146 PRE_first_tail_x15_r0_body.cx0_146.mlx PRE_first_tail_x15_r0_body.cx1_146.mlx) = true
kernel_rfl PRE_first_tail_x15_r0_body.fp146 : ((PRE_first_tail_x15_r0_body.cln146.filter (fullB PRE_first_tail_x15_r0_body.P146))).map (fun i => (PRE_first_tail_x15_r0_body.cx1_146.mlx.nodes.get (PRE_first_tail_x15_r0_body.kappa146.node i)).map Host.Mlx.Ffi.Node.prim) =
  ((PRE_first_tail_x15_r0_body.cln146.filter (fullB PRE_first_tail_x15_r0_body.P146))).map (fun i => (PRE_first_tail_x15_r0_body.cx0_146.mlx.nodes.get i).map fun nd => PRE_first_tail_x15_r0_body.kappa146.prim nd.prim)
kernel_rfl PRE_first_tail_x15_r0_body.fnordI146 : incrB PRE_first_tail_x15_r0_body.kd146.nodeF (List.range' 18166 0) = true
kernel_rfl PRE_first_tail_x15_r0_body.fnordK146 : (PTrie.keysA PRE_first_tail_x15_r0_body.kd146.node).all (fun k => Nat.ble 18166 k && Nat.blt k 18166) = true
kernel_rfl PRE_first_tail_x15_r0_body.fnordL146 : (PRE_first_tail_x15_r0_body.cln146.filter (Nat.ble PRE_first_tail_x15_r0_body.P146.N0)).all (fun i => Nat.ble i (PRE_first_tail_x15_r0_body.kd146.nodeF i) && (Nat.blt i 18166 || Nat.ble PRE_first_tail_x15_r0_body.kd146.nn0 i)) = true
theorem PRE_first_tail_x15_r0_body.fnord146 : (PRE_first_tail_x15_r0_body.cln146.filter (Nat.ble PRE_first_tail_x15_r0_body.P146.N0)).all (fun i => Nat.ble i (PRE_first_tail_x15_r0_body.kd146.nodeF i) &&
    (PTrie.keysA PRE_first_tail_x15_r0_body.kd146.node).all fun j => !Nat.blt j i || Nat.blt (PRE_first_tail_x15_r0_body.kd146.nodeF j) (PRE_first_tail_x15_r0_body.kd146.nodeF i)) = true :=
  cnord_of PRE_first_tail_x15_r0_body.cnlow146 PRE_first_tail_x15_r0_body.cnn1146 PRE_first_tail_x15_r0_body.fnordI146 PRE_first_tail_x15_r0_body.fnordK146 PRE_first_tail_x15_r0_body.fnordL146
kernel_rfl PRE_first_tail_x15_r0_body.fi146 : PRE_first_tail_x15_r0_body.cli146.all (pnB PRE_first_tail_x15_r0_body.cx0_146.mlx) = true
kernel_rfl PRE_first_tail_x15_r0_body.fii146 : PRE_first_tail_x15_r0_body.cli146.all (fun k => decide (PRE_first_tail_x15_r0_body.cx1_146.mlx.items.get (PRE_first_tail_x15_r0_body.kappa146.node k) = (PRE_first_tail_x15_r0_body.cx0_146.mlx.items.get k).map PRE_first_tail_x15_r0_body.kappa146.nv)) = true
/-- **The compaction's footprint.** -/
theorem PRE_first_tail_x15_r0_body.cfoot146 (clean : Conv.NClean (⟨21071, 18166, 2789243, 6295⟩ : Conv.Cnt) (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1285.ffi).mlx) (hltC : ∀ h, PH (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1285.ffi).mlx h → h < (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1285.ffi).mlx.next) (nltC : ∀ i, PN (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1285.ffi).mlx i → i < (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1285.ffi).mlx.nnext) (itemsC : ∀ k v, (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1285.ffi).mlx.items.get k = some v → PN (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1285.ffi).mlx k) (tracedC : ∀ h o, (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1285.ffi).mlx.objs.get h = some o → ∀ i ∈ objTraces o, i < PRE_first_tail_x15_r0_body.P146.NL) (cl : SSt (· < 6295) PRE_first_tail_x15_r0_body.cx0_146.mlx) :
    Conv.MFoot PRE_first_tail_x15_r0_body.P146 6295 PRE_first_tail_x15_r0_body.kappa146 PRE_first_tail_x15_r0_body.kd146 PRE_first_tail_x15_r0_body.khinv146 PRE_first_tail_x15_r0_body.kninv146 (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1285.ffi).mlx PRE_first_tail_x15_r0_body.cx0_146.mlx PRE_first_tail_x15_r0_body.cx1_146.mlx (⟨21071, 18166, 2789243, 6295⟩ : Conv.Cnt) PRE_first_tail_x15_r0_body.clo146 PRE_first_tail_x15_r0_body.cln146 PRE_first_tail_x15_r0_body.cli146 PRE_first_tail_x15_r0_body.cwS146 PRE_first_tail_x15_r0_body.cnS146 PRE_first_tail_x15_r0_body.ciS146 :=
  ⟨rfl, rfl, rfl, PRE_first_tail_x15_r0_body.cnh0146, PRE_first_tail_x15_r0_body.cnh1146, PRE_first_tail_x15_r0_body.cnn0146, PRE_first_tail_x15_r0_body.cnn1146, PRE_first_tail_x15_r0_body.cplo146, PRE_first_tail_x15_r0_body.ccnt146, PRE_first_tail_x15_r0_body.cnband146, PRE_first_tail_x15_r0_body.chbelow146, PRE_first_tail_x15_r0_body.chren146, PRE_first_tail_x15_r0_body.cband146, PRE_first_tail_x15_r0_body.cnh1pos146, PRE_first_tail_x15_r0_body.cnren146, PRE_first_tail_x15_r0_body.cnlow146, PRE_first_tail_x15_r0_body.cabs0a146, PRE_first_tail_x15_r0_body.cabs0b146, PRE_first_tail_x15_r0_body.ctok1146, PRE_first_tail_x15_r0_body.cpend146, PRE_first_tail_x15_r0_body.cerrh146, PRE_first_tail_x15_r0_body.cfiles146, PRE_first_tail_x15_r0_body.carch146, PRE_first_tail_x15_r0_body.csizes146, PRE_first_tail_x15_r0_body.cwired146, PRE_first_tail_x15_r0_body.cfix146, clean, PRE_first_tail_x15_r0_body.fcxn146, PRE_first_tail_x15_r0_body.fcnn146, hltC, nltC, itemsC, tracedC, cl, PRE_first_tail_x15_r0_body.fle0146, PRE_first_tail_x15_r0_body.fnk146, PRE_first_tail_x15_r0_body.ckA146, PRE_first_tail_x15_r0_body.cobjsK146, PRE_first_tail_x15_r0_body.cnodesK146, PRE_first_tail_x15_r0_body.citemsK146, PRE_first_tail_x15_r0_body.f1A146, PRE_first_tail_x15_r0_body.f1O146, PRE_first_tail_x15_r0_body.f1N146, PRE_first_tail_x15_r0_body.f1I146, PRE_first_tail_x15_r0_body.fbd146, PRE_first_tail_x15_r0_body.fincW146, PRE_first_tail_x15_r0_body.fincI146, PRE_first_tail_x15_r0_body.fincN146, PRE_first_tail_x15_r0_body.flnF146, PRE_first_tail_x15_r0_body.fh146, PRE_first_tail_x15_r0_body.fo146, PRE_first_tail_x15_r0_body.fok146, PRE_first_tail_x15_r0_body.fnd146, PRE_first_tail_x15_r0_body.fp146, PRE_first_tail_x15_r0_body.fnord146, PRE_first_tail_x15_r0_body.fi146, PRE_first_tail_x15_r0_body.fii146⟩
theorem PRE_first_tail_x15_r0_body.cnshift146 (clean : Conv.NClean (⟨21071, 18166, 2789243, 6295⟩ : Conv.Cnt) (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1285.ffi).mlx) (hltC : ∀ h, PH (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1285.ffi).mlx h → h < (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1285.ffi).mlx.next) (nltC : ∀ i, PN (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1285.ffi).mlx i → i < (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1285.ffi).mlx.nnext) (itemsC : ∀ k v, (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1285.ffi).mlx.items.get k = some v → PN (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1285.ffi).mlx k) (tracedC : ∀ h o, (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1285.ffi).mlx.objs.get h = some o → ∀ i ∈ objTraces o, i < PRE_first_tail_x15_r0_body.P146.NL) (cl : SSt (· < 6295) PRE_first_tail_x15_r0_body.cx0_146.mlx) : NShift PRE_first_tail_x15_r0_body.P146 6295 PRE_first_tail_x15_r0_body.kappa146 PRE_first_tail_x15_r0_body.cx0_146 PRE_first_tail_x15_r0_body.cx1_146 :=
  Conv.nshift_of_foot (PRE_first_tail_x15_r0_body.cfoot146 clean hltC nltC itemsC tracedC cl) PRE_first_tail_x15_r0_body.chost146 (compact_a_eq PRE_first_tail_x15_r0_body.ckn0146 PRE_first_tail_x15_r0_body.ckn1146 PRE_first_tail_x15_r0_body.ckheap146 PRE_first_tail_x15_r0_body.ckpl146)

-- the observers: the layers' states at the call, the canonical and the merged state, their footprints and checks
noncomputable def PRE_first_tail_x15_r0_body.fxC_146 : PTrie Unit := (Host.Ts.Sim.Full.freedOf PRE_first_tail_x15_r0_body.s1285.ffi).getD PTrie.nil
noncomputable def PRE_first_tail_x15_r0_body.krC_146 : Host.Load.Layers.KRec := (Host.Ts.Sim.Full.krecOf PRE_first_tail_x15_r0_body.s1285.ffi).getD Host.Load.Layers.KRec.empty
kernel_rfl PRE_first_tail_x15_r0_body.ofxC_146 : (Host.Ts.Sim.Full.freedOf PRE_first_tail_x15_r0_body.s1285.ffi) = some PRE_first_tail_x15_r0_body.fxC_146
kernel_rfl PRE_first_tail_x15_r0_body.okrC_146 : (Host.Ts.Sim.Full.krecOf PRE_first_tail_x15_r0_body.s1285.ffi) = some PRE_first_tail_x15_r0_body.krC_146
noncomputable def PRE_first_tail_x15_r0_body.fx0_146 : PTrie Unit := (Host.Ts.Sim.Full.freedOf PRE_first_tail_x15_r0_body.s1287.ffi).getD PTrie.nil
noncomputable def PRE_first_tail_x15_r0_body.kr0_146 : Host.Load.Layers.KRec := (Host.Ts.Sim.Full.krecOf PRE_first_tail_x15_r0_body.s1287.ffi).getD Host.Load.Layers.KRec.empty
kernel_rfl PRE_first_tail_x15_r0_body.ofx0_146 : (Host.Ts.Sim.Full.freedOf PRE_first_tail_x15_r0_body.s1287.ffi) = some PRE_first_tail_x15_r0_body.fx0_146
kernel_rfl PRE_first_tail_x15_r0_body.okr0_146 : (Host.Ts.Sim.Full.krecOf PRE_first_tail_x15_r0_body.s1287.ffi) = some PRE_first_tail_x15_r0_body.kr0_146
noncomputable def PRE_first_tail_x15_r0_body.fx1_146 : PTrie Unit := (Host.Ts.Sim.Full.freedOf PRE_first_tail_x15_r0_body.s1286.ffi).getD PTrie.nil
noncomputable def PRE_first_tail_x15_r0_body.kr1_146 : Host.Load.Layers.KRec := (Host.Ts.Sim.Full.krecOf PRE_first_tail_x15_r0_body.s1286.ffi).getD Host.Load.Layers.KRec.empty
kernel_rfl PRE_first_tail_x15_r0_body.ofx1_146 : (Host.Ts.Sim.Full.freedOf PRE_first_tail_x15_r0_body.s1286.ffi) = some PRE_first_tail_x15_r0_body.fx1_146
kernel_rfl PRE_first_tail_x15_r0_body.okr1_146 : (Host.Ts.Sim.Full.krecOf PRE_first_tail_x15_r0_body.s1286.ffi) = some PRE_first_tail_x15_r0_body.kr1_146
kernel_rfl PRE_first_tail_x15_r0_body.ff0146 : PRE_first_tail_x15_r0_body.fx0_146 = Stage.setAll PRE_first_tail_x15_r0_body.fxC_146 (PRE_first_tail_x15_r0_body.clo146.filterMap fun i => (PRE_first_tail_x15_r0_body.fx0_146.get i).map (i, ·))
kernel_rfl PRE_first_tail_x15_r0_body.ff1146 : PRE_first_tail_x15_r0_body.fx1_146 = Stage.setAll PRE_first_tail_x15_r0_body.fxC_146 (PRE_first_tail_x15_r0_body.cwS146.filterMap fun i => (PRE_first_tail_x15_r0_body.fx1_146.get i).map (i, ·))
kernel_rfl PRE_first_tail_x15_r0_body.ffck146 : freedLB PRE_first_tail_x15_r0_body.kappa146 PRE_first_tail_x15_r0_body.cx0_146.mlx PRE_first_tail_x15_r0_body.fx0_146 PRE_first_tail_x15_r0_body.fx1_146 PRE_first_tail_x15_r0_body.clo146 = true
kernel_rfl PRE_first_tail_x15_r0_body.fkf0146 : PRE_first_tail_x15_r0_body.kr0_146.flags = Stage.setAll PRE_first_tail_x15_r0_body.krC_146.flags (PRE_first_tail_x15_r0_body.clo146.filterMap fun i => (PRE_first_tail_x15_r0_body.kr0_146.flags.get i).map (i, ·))
kernel_rfl PRE_first_tail_x15_r0_body.fkt0146 : PRE_first_tail_x15_r0_body.kr0_146.targs = Stage.setAll PRE_first_tail_x15_r0_body.krC_146.targs (PRE_first_tail_x15_r0_body.clo146.filterMap fun i => (PRE_first_tail_x15_r0_body.kr0_146.targs.get i).map (i, ·))
kernel_rfl PRE_first_tail_x15_r0_body.fkf1146 : PRE_first_tail_x15_r0_body.kr1_146.flags = Stage.setAll PRE_first_tail_x15_r0_body.krC_146.flags (PRE_first_tail_x15_r0_body.cwS146.filterMap fun i => (PRE_first_tail_x15_r0_body.kr1_146.flags.get i).map (i, ·))
kernel_rfl PRE_first_tail_x15_r0_body.fkt1146 : PRE_first_tail_x15_r0_body.kr1_146.targs = Stage.setAll PRE_first_tail_x15_r0_body.krC_146.targs (PRE_first_tail_x15_r0_body.cwS146.filterMap fun i => (PRE_first_tail_x15_r0_body.kr1_146.targs.get i).map (i, ·))
kernel_rfl PRE_first_tail_x15_r0_body.fkck146 : krecLB PRE_first_tail_x15_r0_body.kappa146 6295 PRE_first_tail_x15_r0_body.cx0_146.mlx PRE_first_tail_x15_r0_body.kr0_146 PRE_first_tail_x15_r0_body.kr1_146 PRE_first_tail_x15_r0_body.clo146 = true
kernel_rfl PRE_first_tail_x15_r0_body.fkn146 : Nat.ble 6295 6295 = true
-- the bridge and the pending traces' regions
kernel_rfl PRE_first_tail_x15_r0_body.cbridge146 : Host.Ts.Sim.Full.bridgeOf PRE_first_tail_x15_r0_body.s1286.ffi = Host.Ts.Sim.Full.bridgeOf PRE_first_tail_x15_r0_body.s1287.ffi
kernel_rfl PRE_first_tail_x15_r0_body.cpendR146 : pendRegB PRE_first_tail_x15_r0_body.kappa146 (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1287.ffi).mlx = true
kernel_rfl PRE_first_tail_x15_r0_body.cpendLe146 : Nat.ble (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1287.ffi).mlx.next (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1286.ffi).mlx.next = true
/-- **The compaction's native shift**, given the call's bookkeeping, its relation's facts (the model's and the
observers') and the canonical closedness. -/
theorem PRE_first_tail_x15_r0_body.cshift146 (clean : Conv.NClean (⟨21071, 18166, 2789243, 6295⟩ : Conv.Cnt) (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1285.ffi).mlx) (hltC : ∀ h, PH (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1285.ffi).mlx h → h < (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1285.ffi).mlx.next) (nltC : ∀ i, PN (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1285.ffi).mlx i → i < (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1285.ffi).mlx.nnext) (itemsC : ∀ k v, (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1285.ffi).mlx.items.get k = some v → PN (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1285.ffi).mlx k) (tracedC : ∀ h o, (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1285.ffi).mlx.objs.get h = some o → ∀ i ∈ objTraces o, i < PRE_first_tail_x15_r0_body.P146.NL) (cl : SSt (· < 6295) PRE_first_tail_x15_r0_body.cx0_146.mlx)
    (hobjC : ∀ h, PRE_first_tail_x15_r0_body.fxC_146.get h = some () → ((Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1285.ffi).mlx.objs.get h).isSome = true)
    (hfC : ∀ h, (PRE_first_tail_x15_r0_body.krC_146.flags.get h).isSome = true → ((Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1285.ffi).mlx.objs.get h).isSome = true)
    (htC : ∀ h, (PRE_first_tail_x15_r0_body.krC_146.targs.get h).isSome = true → ((Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1285.ffi).mlx.objs.get h).isSome = true)
    (hclC : ∀ h l, PRE_first_tail_x15_r0_body.krC_146.targs.get h = some l → Host.Ts.Sim.Full.STargs (· < (⟨21071, 18166, 2789243, 6295⟩ : Conv.Cnt).n) l) :
    Conv.FullShiftQ PRE_first_tail_x15_r0_body.P146 6295 PRE_first_tail_x15_r0_body.kappa146 PRE_first_tail_x15_r0_body.s1287.ffi PRE_first_tail_x15_r0_body.s1286.ffi :=
  ⟨PRE_first_tail_x15_r0_body.cnshift146 clean hltC nltC itemsC tracedC cl, PRE_first_tail_x15_r0_body.cqueue146, fun t ht => bSN_sound (List.all_eq_true.mp PRE_first_tail_x15_r0_body.ctokSupp146 t ht),
    PRE_first_tail_x15_r0_body.cbridge146,
    liveShift_foot (x0' := Host.Ts.Sim.Full.mlxOf PRE_first_tail_x15_r0_body.s1287.ffi) (x1' := Host.Ts.Sim.Full.mlxOf PRE_first_tail_x15_r0_body.s1286.ffi) (PRE_first_tail_x15_r0_body.cfoot146 clean hltC nltC itemsC tracedC cl) rfl PRE_first_tail_x15_r0_body.ofx0_146 PRE_first_tail_x15_r0_body.ofx1_146 hobjC PRE_first_tail_x15_r0_body.ff0146 PRE_first_tail_x15_r0_body.ff1146 PRE_first_tail_x15_r0_body.ffck146,
    kernShift_foot (x0' := Host.Ts.Sim.Full.mlxOf PRE_first_tail_x15_r0_body.s1287.ffi) (x1' := Host.Ts.Sim.Full.mlxOf PRE_first_tail_x15_r0_body.s1286.ffi) (PRE_first_tail_x15_r0_body.cfoot146 clean hltC nltC itemsC tracedC cl) rfl PRE_first_tail_x15_r0_body.okr0_146 PRE_first_tail_x15_r0_body.okr1_146 (Nat.le_of_ble_eq_true PRE_first_tail_x15_r0_body.fkn146) hfC htC hclC
      PRE_first_tail_x15_r0_body.fkf0146 PRE_first_tail_x15_r0_body.fkt0146 PRE_first_tail_x15_r0_body.fkf1146 PRE_first_tail_x15_r0_body.fkt1146 PRE_first_tail_x15_r0_body.fkck146,
    pendReg_of rfl PRE_first_tail_x15_r0_body.cnh0146 PRE_first_tail_x15_r0_body.cnh1146 (Nat.le_of_ble_eq_true PRE_first_tail_x15_r0_body.cpendLe146) PRE_first_tail_x15_r0_body.cpendR146⟩

end Host.Load.Run.Tpl
