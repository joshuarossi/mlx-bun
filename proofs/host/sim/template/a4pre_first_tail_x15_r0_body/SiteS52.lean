import host.sim.template.a4pre_first_tail_x15_r0_body.SiteCl52
import host.sim.conv.CompactFull
import host.sim.template.FootGen
set_option Elab.async false
namespace Host.Load.Run.Tpl
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
open Host.Ts Host.Ts.Sim Host.Ts.Sim.Template

/-! The compaction's native shift at call site 52 from its footprint (`Conv.nshift_of_foot`), and the observers'
(`liveShift_foot`, `kernShift_foot`): `Conv.FullShiftQ` for `Conv.full_compactQ`, given the call's bookkeeping and its
relation's facts. -/

/-- The load parameters of the chain (band-free: its start's node counter as `NL` and `N0`). -/
def PRE_first_tail_x15_r0_body.Pc52 : LoadP := ⟨18151, 131072, 1099511627776, 15235, 15235, []⟩
/-- The site's band raised to the map's checked fixed-node prefix, including newly recorded closure traces. -/
def PRE_first_tail_x15_r0_body.P52 : LoadP := PRE_first_tail_x15_r0_body.Pc52.raise 16329
kernel_rfl PRE_first_tail_x15_r0_body.craise52 : Nat.ble PRE_first_tail_x15_r0_body.Pc52.N0 16329 = true
theorem PRE_first_tail_x15_r0_body.raised52 : Host.Ts.Sim.Full.Raised PRE_first_tail_x15_r0_body.Pc52 PRE_first_tail_x15_r0_body.P52 :=
  .inr ⟨16329, rfl, Nat.le_of_ble_eq_true PRE_first_tail_x15_r0_body.craise52, rfl⟩
noncomputable abbrev PRE_first_tail_x15_r0_body.cx0_52 : Host.Load.LSt := clearTokens (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s515.ffi)
noncomputable abbrev PRE_first_tail_x15_r0_body.cx1_52 : Host.Load.LSt := clearTokens (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s514.ffi)
def PRE_first_tail_x15_r0_body.khinv52 : PTrie Nat := Stage.setAll PTrie.nil []
def PRE_first_tail_x15_r0_body.kninv52 : PTrie Nat := Stage.setAll PTrie.nil []
/-- The stage's footprint: its written and fresh handles, fresh nodes, written and fresh items. -/
def PRE_first_tail_x15_r0_body.cwS52 : List Nat := []
def PRE_first_tail_x15_r0_body.cnS52 : List Nat := List.range' 16329 0
def PRE_first_tail_x15_r0_body.ciS52 : List Nat := [] ++ List.range' 16329 0

-- the small checks (`MChecks`'s)
kernel_rfl PRE_first_tail_x15_r0_body.cnh052 : PRE_first_tail_x15_r0_body.kd52.nh0 = PRE_first_tail_x15_r0_body.cx0_52.mlx.next
kernel_rfl PRE_first_tail_x15_r0_body.cnh152 : PRE_first_tail_x15_r0_body.kd52.nh1 = PRE_first_tail_x15_r0_body.cx1_52.mlx.next
kernel_rfl PRE_first_tail_x15_r0_body.cnn052 : PRE_first_tail_x15_r0_body.kd52.nn0 = PRE_first_tail_x15_r0_body.cx0_52.mlx.nnext
kernel_rfl PRE_first_tail_x15_r0_body.cnn152 : PRE_first_tail_x15_r0_body.kd52.nn1 = PRE_first_tail_x15_r0_body.cx1_52.mlx.nnext
kernel_rfl PRE_first_tail_x15_r0_body.cplo52 : (Nat.blt 0 PRE_first_tail_x15_r0_body.P52.lo && Nat.ble PRE_first_tail_x15_r0_body.P52.lo PRE_first_tail_x15_r0_body.cx0_52.mlx.next && Nat.ble PRE_first_tail_x15_r0_body.P52.lo RData.bigHi && Nat.ble RData.bigHi PRE_first_tail_x15_r0_body.P52.E) = true
kernel_rfl PRE_first_tail_x15_r0_body.ccnt52 : (Nat.ble PRE_first_tail_x15_r0_body.cx0_52.mlx.next PRE_first_tail_x15_r0_body.cx1_52.mlx.next && Nat.ble PRE_first_tail_x15_r0_body.cx0_52.mlx.nnext PRE_first_tail_x15_r0_body.cx1_52.mlx.nnext) = true
kernel_rfl PRE_first_tail_x15_r0_body.cnband52 : (Nat.blt 0 PRE_first_tail_x15_r0_body.P52.NL && Nat.ble PRE_first_tail_x15_r0_body.P52.NL PRE_first_tail_x15_r0_body.P52.N0 && Nat.ble PRE_first_tail_x15_r0_body.P52.N0 PRE_first_tail_x15_r0_body.cx0_52.mlx.nnext) = true
kernel_rfl PRE_first_tail_x15_r0_body.chbelow52 : PRE_first_tail_x15_r0_body.kd52.checkHndBelow = true
kernel_rfl PRE_first_tail_x15_r0_body.chren52 : checkRenG PRE_first_tail_x15_r0_body.kd52.hnd PRE_first_tail_x15_r0_body.khinv52 (phB PRE_first_tail_x15_r0_body.cx0_52.mlx) = true
kernel_rfl PRE_first_tail_x15_r0_body.cband52 : PRE_first_tail_x15_r0_body.kd52.checkBand PRE_first_tail_x15_r0_body.P52.lo = true
kernel_rfl PRE_first_tail_x15_r0_body.cnh1pos52 : Nat.blt 0 PRE_first_tail_x15_r0_body.kd52.nh1 = true
kernel_rfl PRE_first_tail_x15_r0_body.cnren52 : checkRenG PRE_first_tail_x15_r0_body.kd52.node PRE_first_tail_x15_r0_body.kninv52 (pnB PRE_first_tail_x15_r0_body.cx0_52.mlx) = true
kernel_rfl PRE_first_tail_x15_r0_body.cnlow52 : (PTrie.keysA PRE_first_tail_x15_r0_body.kd52.node).all (fun j => Nat.ble PRE_first_tail_x15_r0_body.P52.NL j && Nat.blt (PRE_first_tail_x15_r0_body.kd52.nodeF j) PRE_first_tail_x15_r0_body.cx1_52.mlx.nnext) = true
kernel_rfl PRE_first_tail_x15_r0_body.cabs0a52 : PRE_first_tail_x15_r0_body.cx0_52.mlx.arrs.get 0 = none
kernel_rfl PRE_first_tail_x15_r0_body.cabs0b52 : PRE_first_tail_x15_r0_body.cx0_52.mlx.objs.get 0 = none
kernel_rfl PRE_first_tail_x15_r0_body.ctok152 : PRE_first_tail_x15_r0_body.cx1_52.mlx.tokens = []
kernel_rfl PRE_first_tail_x15_r0_body.cpend52 : PRE_first_tail_x15_r0_body.cx1_52.mlx.pending = PRE_first_tail_x15_r0_body.cx0_52.mlx.pending.map PRE_first_tail_x15_r0_body.kappa52.pend
kernel_rfl PRE_first_tail_x15_r0_body.cerrh52 : PRE_first_tail_x15_r0_body.cx1_52.mlx.errh = PRE_first_tail_x15_r0_body.cx0_52.mlx.errh.map PRE_first_tail_x15_r0_body.kappa52.arg
kernel_rfl PRE_first_tail_x15_r0_body.cfiles52 : PRE_first_tail_x15_r0_body.cx1_52.mlx.files = PRE_first_tail_x15_r0_body.cx0_52.mlx.files
kernel_rfl PRE_first_tail_x15_r0_body.carch52 : PRE_first_tail_x15_r0_body.cx1_52.mlx.arch = PRE_first_tail_x15_r0_body.cx0_52.mlx.arch
kernel_rfl PRE_first_tail_x15_r0_body.csizes52 : PRE_first_tail_x15_r0_body.cx1_52.mlx.deviceSizes = PRE_first_tail_x15_r0_body.cx0_52.mlx.deviceSizes
kernel_rfl PRE_first_tail_x15_r0_body.cwired52 : PRE_first_tail_x15_r0_body.cx1_52.mlx.wired = PRE_first_tail_x15_r0_body.cx0_52.mlx.wired
kernel_rfl PRE_first_tail_x15_r0_body.chost52 : PRE_first_tail_x15_r0_body.cx1_52.host = PRE_first_tail_x15_r0_body.cx0_52.host
-- the compaction map's addresses are `PRE_first_tail_x15_r0_body.kd52`'s
kernel_rfl PRE_first_tail_x15_r0_body.ckn052 : PRE_first_tail_x15_r0_body.kd52.n0 = 2715879
kernel_rfl PRE_first_tail_x15_r0_body.ckn152 : PRE_first_tail_x15_r0_body.kd52.n1 = 2715881
kernel_rfl PRE_first_tail_x15_r0_body.ckheap52 : (PTrie.keysA PRE_first_tail_x15_r0_body.kd52.heap).all (fun x => Nat.ble 2715879 x) = true
kernel_rfl PRE_first_tail_x15_r0_body.ckpl52 : (List.range 0).all (fun j => decide (PRE_first_tail_x15_r0_body.kd52.heap.get (2715879 + j) = nth? PRE_first_tail_x15_r0_body.pl52 j)) = true
-- the map fixes the call's names (`Conv.fixOld_compact`), the call's counters
kernel_rfl PRE_first_tail_x15_r0_body.fja52 : Nat.ble 2715879 2715879 = true
kernel_rfl PRE_first_tail_x15_r0_body.fn52 : Nat.ble 2303 2303 = true
kernel_rfl PRE_first_tail_x15_r0_body.fjaD52 : Nat.ble 2715879 PRE_first_tail_x15_r0_body.kd52.n0 = true
kernel_rfl PRE_first_tail_x15_r0_body.fxn52 : Nat.ble 19233 PRE_first_tail_x15_r0_body.kd52.nh0 = true
kernel_rfl PRE_first_tail_x15_r0_body.fnn52 : Nat.ble 16329 PRE_first_tail_x15_r0_body.kd52.nn0 = true
kernel_rfl PRE_first_tail_x15_r0_body.fxb52 : Nat.ble 19233 RData.bigHi = true
kernel_rfl PRE_first_tail_x15_r0_body.fheap52 : (PTrie.keysA PRE_first_tail_x15_r0_body.kd52.heap).all (Nat.ble (⟨19233, 16329, 2715879, 2303⟩ : Conv.Cnt).ja) = true
kernel_rfl PRE_first_tail_x15_r0_body.fhnd52 : (PTrie.keysA PRE_first_tail_x15_r0_body.kd52.hnd).all (Nat.ble (⟨19233, 16329, 2715879, 2303⟩ : Conv.Cnt).xn) = true
kernel_rfl PRE_first_tail_x15_r0_body.fnode52 : (PTrie.keysA PRE_first_tail_x15_r0_body.kd52.node).all (Nat.ble (⟨19233, 16329, 2715879, 2303⟩ : Conv.Cnt).nn) = true
/-- The compaction map fixes the call's names. -/
theorem PRE_first_tail_x15_r0_body.cfix52 : Conv.FixOld (⟨19233, 16329, 2715879, 2303⟩ : Conv.Cnt) PRE_first_tail_x15_r0_body.kappa52 :=
  Conv.fixOld_compact (Nat.le_of_ble_eq_true PRE_first_tail_x15_r0_body.fja52) (Nat.le_of_ble_eq_true PRE_first_tail_x15_r0_body.fn52) (Nat.le_of_ble_eq_true PRE_first_tail_x15_r0_body.fjaD52) (Nat.le_of_ble_eq_true PRE_first_tail_x15_r0_body.fxn52) (Nat.le_of_ble_eq_true PRE_first_tail_x15_r0_body.fnn52) (Nat.le_of_ble_eq_true PRE_first_tail_x15_r0_body.fxb52) PRE_first_tail_x15_r0_body.fheap52 PRE_first_tail_x15_r0_body.fhnd52 PRE_first_tail_x15_r0_body.fnode52
kernel_rfl PRE_first_tail_x15_r0_body.fcxn52 : (⟨19233, 16329, 2715879, 2303⟩ : Conv.Cnt).xn = (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s513.ffi).mlx.next
kernel_rfl PRE_first_tail_x15_r0_body.fcnn52 : (⟨19233, 16329, 2715879, 2303⟩ : Conv.Cnt).nn = (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s513.ffi).mlx.nnext
kernel_rfl PRE_first_tail_x15_r0_body.fle052 : (Nat.ble (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s513.ffi).mlx.next PRE_first_tail_x15_r0_body.cx0_52.mlx.next && Nat.ble (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s513.ffi).mlx.nnext PRE_first_tail_x15_r0_body.cx0_52.mlx.nnext && Nat.ble (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s513.ffi).mlx.next RData.bigHi) = true
kernel_rfl PRE_first_tail_x15_r0_body.fnk52 : (PTrie.keysA PRE_first_tail_x15_r0_body.kd52.node).all (Nat.ble (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s513.ffi).mlx.nnext) = true
-- the merged state keeps the call's entries off the stage's footprint
kernel_rfl PRE_first_tail_x15_r0_body.f1A52 : PRE_first_tail_x15_r0_body.cx1_52.mlx.arrs = Stage.setAll (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s513.ffi).mlx.arrs (PRE_first_tail_x15_r0_body.cwS52.filterMap fun i => (PRE_first_tail_x15_r0_body.cx1_52.mlx.arrs.get i).map (i, ·))
kernel_rfl PRE_first_tail_x15_r0_body.f1O52 : PRE_first_tail_x15_r0_body.cx1_52.mlx.objs = Stage.setAll (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s513.ffi).mlx.objs (PRE_first_tail_x15_r0_body.cwS52.filterMap fun i => (PRE_first_tail_x15_r0_body.cx1_52.mlx.objs.get i).map (i, ·))
kernel_rfl PRE_first_tail_x15_r0_body.f1N52 : PRE_first_tail_x15_r0_body.cx1_52.mlx.nodes = Stage.setAll (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s513.ffi).mlx.nodes (PRE_first_tail_x15_r0_body.cnS52.filterMap fun i => (PRE_first_tail_x15_r0_body.cx1_52.mlx.nodes.get i).map (i, ·))
kernel_rfl PRE_first_tail_x15_r0_body.f1I52 : PRE_first_tail_x15_r0_body.cx1_52.mlx.items = Stage.setAll (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s513.ffi).mlx.items (PRE_first_tail_x15_r0_body.ciS52.filterMap fun i => (PRE_first_tail_x15_r0_body.cx1_52.mlx.items.get i).map (i, ·))
kernel_rfl PRE_first_tail_x15_r0_body.fbd52 : (PRE_first_tail_x15_r0_body.clo52 ++ PRE_first_tail_x15_r0_body.cln52 ++ PRE_first_tail_x15_r0_body.cli52 ++ PRE_first_tail_x15_r0_body.cwS52 ++ PRE_first_tail_x15_r0_body.cnS52 ++ PRE_first_tail_x15_r0_body.ciS52).all (fun i => Nat.blt (i / 4096) (4 ^ 31)) = true
kernel_rfl PRE_first_tail_x15_r0_body.fincW52 : PRE_first_tail_x15_r0_body.cwS52.all (fun h => !Nat.blt h (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s513.ffi).mlx.next || PRE_first_tail_x15_r0_body.clo52.contains h) = true
kernel_rfl PRE_first_tail_x15_r0_body.fincI52 : PRE_first_tail_x15_r0_body.ciS52.all (fun k => !Nat.blt k (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s513.ffi).mlx.nnext || PRE_first_tail_x15_r0_body.cli52.contains k) = true
kernel_rfl PRE_first_tail_x15_r0_body.fincN52 : PRE_first_tail_x15_r0_body.cnS52.all (Nat.ble (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s513.ffi).mlx.nnext) = true
kernel_rfl PRE_first_tail_x15_r0_body.flnF52 : PRE_first_tail_x15_r0_body.cln52.all (Nat.ble (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s513.ffi).mlx.nnext) = true
-- the checks over the changed lists
kernel_rfl PRE_first_tail_x15_r0_body.fh52 : PRE_first_tail_x15_r0_body.clo52.all (handleOK PRE_first_tail_x15_r0_body.kappa52 PRE_first_tail_x15_r0_body.P52.lo PRE_first_tail_x15_r0_body.cx0_52.mlx PRE_first_tail_x15_r0_body.cx1_52.mlx) = true
kernel_rfl PRE_first_tail_x15_r0_body.fo52 : PRE_first_tail_x15_r0_body.clo52.map (fun h => PRE_first_tail_x15_r0_body.cx1_52.mlx.objs.get (PRE_first_tail_x15_r0_body.kappa52.handle h)) = PRE_first_tail_x15_r0_body.clo52.map (fun h => (PRE_first_tail_x15_r0_body.cx0_52.mlx.objs.get h).map PRE_first_tail_x15_r0_body.kappa52.nobj)
kernel_rfl PRE_first_tail_x15_r0_body.fok52 : PRE_first_tail_x15_r0_body.clo52.all (objOK PRE_first_tail_x15_r0_body.kappa52 PRE_first_tail_x15_r0_body.P52.NL PRE_first_tail_x15_r0_body.cx0_52.mlx) = true
kernel_rfl PRE_first_tail_x15_r0_body.fnd52 : PRE_first_tail_x15_r0_body.cln52.all (nodeOKF PRE_first_tail_x15_r0_body.kappa52 PRE_first_tail_x15_r0_body.P52 PRE_first_tail_x15_r0_body.cx0_52.mlx PRE_first_tail_x15_r0_body.cx1_52.mlx) = true
kernel_rfl PRE_first_tail_x15_r0_body.fp52 : ((PRE_first_tail_x15_r0_body.cln52.filter (fullB PRE_first_tail_x15_r0_body.P52))).map (fun i => (PRE_first_tail_x15_r0_body.cx1_52.mlx.nodes.get (PRE_first_tail_x15_r0_body.kappa52.node i)).map Host.Mlx.Ffi.Node.prim) =
  ((PRE_first_tail_x15_r0_body.cln52.filter (fullB PRE_first_tail_x15_r0_body.P52))).map (fun i => (PRE_first_tail_x15_r0_body.cx0_52.mlx.nodes.get i).map fun nd => PRE_first_tail_x15_r0_body.kappa52.prim nd.prim)
kernel_rfl PRE_first_tail_x15_r0_body.fnordI52 : incrB PRE_first_tail_x15_r0_body.kd52.nodeF (List.range' 16329 0) = true
kernel_rfl PRE_first_tail_x15_r0_body.fnordK52 : (PTrie.keysA PRE_first_tail_x15_r0_body.kd52.node).all (fun k => Nat.ble 16329 k && Nat.blt k 16329) = true
kernel_rfl PRE_first_tail_x15_r0_body.fnordL52 : (PRE_first_tail_x15_r0_body.cln52.filter (Nat.ble PRE_first_tail_x15_r0_body.P52.N0)).all (fun i => Nat.ble i (PRE_first_tail_x15_r0_body.kd52.nodeF i) && (Nat.blt i 16329 || Nat.ble PRE_first_tail_x15_r0_body.kd52.nn0 i)) = true
theorem PRE_first_tail_x15_r0_body.fnord52 : (PRE_first_tail_x15_r0_body.cln52.filter (Nat.ble PRE_first_tail_x15_r0_body.P52.N0)).all (fun i => Nat.ble i (PRE_first_tail_x15_r0_body.kd52.nodeF i) &&
    (PTrie.keysA PRE_first_tail_x15_r0_body.kd52.node).all fun j => !Nat.blt j i || Nat.blt (PRE_first_tail_x15_r0_body.kd52.nodeF j) (PRE_first_tail_x15_r0_body.kd52.nodeF i)) = true :=
  cnord_of PRE_first_tail_x15_r0_body.cnlow52 PRE_first_tail_x15_r0_body.cnn152 PRE_first_tail_x15_r0_body.fnordI52 PRE_first_tail_x15_r0_body.fnordK52 PRE_first_tail_x15_r0_body.fnordL52
kernel_rfl PRE_first_tail_x15_r0_body.fi52 : PRE_first_tail_x15_r0_body.cli52.all (pnB PRE_first_tail_x15_r0_body.cx0_52.mlx) = true
kernel_rfl PRE_first_tail_x15_r0_body.fii52 : PRE_first_tail_x15_r0_body.cli52.all (fun k => decide (PRE_first_tail_x15_r0_body.cx1_52.mlx.items.get (PRE_first_tail_x15_r0_body.kappa52.node k) = (PRE_first_tail_x15_r0_body.cx0_52.mlx.items.get k).map PRE_first_tail_x15_r0_body.kappa52.nv)) = true
/-- **The compaction's footprint.** -/
theorem PRE_first_tail_x15_r0_body.cfoot52 (clean : Conv.NClean (⟨19233, 16329, 2715879, 2303⟩ : Conv.Cnt) (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s513.ffi).mlx) (hltC : ∀ h, PH (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s513.ffi).mlx h → h < (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s513.ffi).mlx.next) (nltC : ∀ i, PN (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s513.ffi).mlx i → i < (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s513.ffi).mlx.nnext) (itemsC : ∀ k v, (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s513.ffi).mlx.items.get k = some v → PN (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s513.ffi).mlx k) (tracedC : ∀ h o, (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s513.ffi).mlx.objs.get h = some o → ∀ i ∈ objTraces o, i < PRE_first_tail_x15_r0_body.P52.NL) (cl : SSt (· < 2303) PRE_first_tail_x15_r0_body.cx0_52.mlx) :
    Conv.MFoot PRE_first_tail_x15_r0_body.P52 2303 PRE_first_tail_x15_r0_body.kappa52 PRE_first_tail_x15_r0_body.kd52 PRE_first_tail_x15_r0_body.khinv52 PRE_first_tail_x15_r0_body.kninv52 (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s513.ffi).mlx PRE_first_tail_x15_r0_body.cx0_52.mlx PRE_first_tail_x15_r0_body.cx1_52.mlx (⟨19233, 16329, 2715879, 2303⟩ : Conv.Cnt) PRE_first_tail_x15_r0_body.clo52 PRE_first_tail_x15_r0_body.cln52 PRE_first_tail_x15_r0_body.cli52 PRE_first_tail_x15_r0_body.cwS52 PRE_first_tail_x15_r0_body.cnS52 PRE_first_tail_x15_r0_body.ciS52 :=
  ⟨rfl, rfl, rfl, PRE_first_tail_x15_r0_body.cnh052, PRE_first_tail_x15_r0_body.cnh152, PRE_first_tail_x15_r0_body.cnn052, PRE_first_tail_x15_r0_body.cnn152, PRE_first_tail_x15_r0_body.cplo52, PRE_first_tail_x15_r0_body.ccnt52, PRE_first_tail_x15_r0_body.cnband52, PRE_first_tail_x15_r0_body.chbelow52, PRE_first_tail_x15_r0_body.chren52, PRE_first_tail_x15_r0_body.cband52, PRE_first_tail_x15_r0_body.cnh1pos52, PRE_first_tail_x15_r0_body.cnren52, PRE_first_tail_x15_r0_body.cnlow52, PRE_first_tail_x15_r0_body.cabs0a52, PRE_first_tail_x15_r0_body.cabs0b52, PRE_first_tail_x15_r0_body.ctok152, PRE_first_tail_x15_r0_body.cpend52, PRE_first_tail_x15_r0_body.cerrh52, PRE_first_tail_x15_r0_body.cfiles52, PRE_first_tail_x15_r0_body.carch52, PRE_first_tail_x15_r0_body.csizes52, PRE_first_tail_x15_r0_body.cwired52, PRE_first_tail_x15_r0_body.cfix52, clean, PRE_first_tail_x15_r0_body.fcxn52, PRE_first_tail_x15_r0_body.fcnn52, hltC, nltC, itemsC, tracedC, cl, PRE_first_tail_x15_r0_body.fle052, PRE_first_tail_x15_r0_body.fnk52, PRE_first_tail_x15_r0_body.ckA52, PRE_first_tail_x15_r0_body.cobjsK52, PRE_first_tail_x15_r0_body.cnodesK52, PRE_first_tail_x15_r0_body.citemsK52, PRE_first_tail_x15_r0_body.f1A52, PRE_first_tail_x15_r0_body.f1O52, PRE_first_tail_x15_r0_body.f1N52, PRE_first_tail_x15_r0_body.f1I52, PRE_first_tail_x15_r0_body.fbd52, PRE_first_tail_x15_r0_body.fincW52, PRE_first_tail_x15_r0_body.fincI52, PRE_first_tail_x15_r0_body.fincN52, PRE_first_tail_x15_r0_body.flnF52, PRE_first_tail_x15_r0_body.fh52, PRE_first_tail_x15_r0_body.fo52, PRE_first_tail_x15_r0_body.fok52, PRE_first_tail_x15_r0_body.fnd52, PRE_first_tail_x15_r0_body.fp52, PRE_first_tail_x15_r0_body.fnord52, PRE_first_tail_x15_r0_body.fi52, PRE_first_tail_x15_r0_body.fii52⟩
theorem PRE_first_tail_x15_r0_body.cnshift52 (clean : Conv.NClean (⟨19233, 16329, 2715879, 2303⟩ : Conv.Cnt) (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s513.ffi).mlx) (hltC : ∀ h, PH (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s513.ffi).mlx h → h < (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s513.ffi).mlx.next) (nltC : ∀ i, PN (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s513.ffi).mlx i → i < (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s513.ffi).mlx.nnext) (itemsC : ∀ k v, (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s513.ffi).mlx.items.get k = some v → PN (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s513.ffi).mlx k) (tracedC : ∀ h o, (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s513.ffi).mlx.objs.get h = some o → ∀ i ∈ objTraces o, i < PRE_first_tail_x15_r0_body.P52.NL) (cl : SSt (· < 2303) PRE_first_tail_x15_r0_body.cx0_52.mlx) : NShift PRE_first_tail_x15_r0_body.P52 2303 PRE_first_tail_x15_r0_body.kappa52 PRE_first_tail_x15_r0_body.cx0_52 PRE_first_tail_x15_r0_body.cx1_52 :=
  Conv.nshift_of_foot (PRE_first_tail_x15_r0_body.cfoot52 clean hltC nltC itemsC tracedC cl) PRE_first_tail_x15_r0_body.chost52 (compact_a_eq PRE_first_tail_x15_r0_body.ckn052 PRE_first_tail_x15_r0_body.ckn152 PRE_first_tail_x15_r0_body.ckheap52 PRE_first_tail_x15_r0_body.ckpl52)

-- the observers: the layers' states at the call, the canonical and the merged state, their footprints and checks
noncomputable def PRE_first_tail_x15_r0_body.fxC_52 : PTrie Unit := (Host.Ts.Sim.Full.freedOf PRE_first_tail_x15_r0_body.s513.ffi).getD PTrie.nil
noncomputable def PRE_first_tail_x15_r0_body.krC_52 : Host.Load.Layers.KRec := (Host.Ts.Sim.Full.krecOf PRE_first_tail_x15_r0_body.s513.ffi).getD Host.Load.Layers.KRec.empty
kernel_rfl PRE_first_tail_x15_r0_body.ofxC_52 : (Host.Ts.Sim.Full.freedOf PRE_first_tail_x15_r0_body.s513.ffi) = some PRE_first_tail_x15_r0_body.fxC_52
kernel_rfl PRE_first_tail_x15_r0_body.okrC_52 : (Host.Ts.Sim.Full.krecOf PRE_first_tail_x15_r0_body.s513.ffi) = some PRE_first_tail_x15_r0_body.krC_52
noncomputable def PRE_first_tail_x15_r0_body.fx0_52 : PTrie Unit := (Host.Ts.Sim.Full.freedOf PRE_first_tail_x15_r0_body.s515.ffi).getD PTrie.nil
noncomputable def PRE_first_tail_x15_r0_body.kr0_52 : Host.Load.Layers.KRec := (Host.Ts.Sim.Full.krecOf PRE_first_tail_x15_r0_body.s515.ffi).getD Host.Load.Layers.KRec.empty
kernel_rfl PRE_first_tail_x15_r0_body.ofx0_52 : (Host.Ts.Sim.Full.freedOf PRE_first_tail_x15_r0_body.s515.ffi) = some PRE_first_tail_x15_r0_body.fx0_52
kernel_rfl PRE_first_tail_x15_r0_body.okr0_52 : (Host.Ts.Sim.Full.krecOf PRE_first_tail_x15_r0_body.s515.ffi) = some PRE_first_tail_x15_r0_body.kr0_52
noncomputable def PRE_first_tail_x15_r0_body.fx1_52 : PTrie Unit := (Host.Ts.Sim.Full.freedOf PRE_first_tail_x15_r0_body.s514.ffi).getD PTrie.nil
noncomputable def PRE_first_tail_x15_r0_body.kr1_52 : Host.Load.Layers.KRec := (Host.Ts.Sim.Full.krecOf PRE_first_tail_x15_r0_body.s514.ffi).getD Host.Load.Layers.KRec.empty
kernel_rfl PRE_first_tail_x15_r0_body.ofx1_52 : (Host.Ts.Sim.Full.freedOf PRE_first_tail_x15_r0_body.s514.ffi) = some PRE_first_tail_x15_r0_body.fx1_52
kernel_rfl PRE_first_tail_x15_r0_body.okr1_52 : (Host.Ts.Sim.Full.krecOf PRE_first_tail_x15_r0_body.s514.ffi) = some PRE_first_tail_x15_r0_body.kr1_52
kernel_rfl PRE_first_tail_x15_r0_body.ff052 : PRE_first_tail_x15_r0_body.fx0_52 = Stage.setAll PRE_first_tail_x15_r0_body.fxC_52 (PRE_first_tail_x15_r0_body.clo52.filterMap fun i => (PRE_first_tail_x15_r0_body.fx0_52.get i).map (i, ·))
kernel_rfl PRE_first_tail_x15_r0_body.ff152 : PRE_first_tail_x15_r0_body.fx1_52 = Stage.setAll PRE_first_tail_x15_r0_body.fxC_52 (PRE_first_tail_x15_r0_body.cwS52.filterMap fun i => (PRE_first_tail_x15_r0_body.fx1_52.get i).map (i, ·))
kernel_rfl PRE_first_tail_x15_r0_body.ffck52 : freedLB PRE_first_tail_x15_r0_body.kappa52 PRE_first_tail_x15_r0_body.cx0_52.mlx PRE_first_tail_x15_r0_body.fx0_52 PRE_first_tail_x15_r0_body.fx1_52 PRE_first_tail_x15_r0_body.clo52 = true
kernel_rfl PRE_first_tail_x15_r0_body.fkf052 : PRE_first_tail_x15_r0_body.kr0_52.flags = Stage.setAll PRE_first_tail_x15_r0_body.krC_52.flags (PRE_first_tail_x15_r0_body.clo52.filterMap fun i => (PRE_first_tail_x15_r0_body.kr0_52.flags.get i).map (i, ·))
kernel_rfl PRE_first_tail_x15_r0_body.fkt052 : PRE_first_tail_x15_r0_body.kr0_52.targs = Stage.setAll PRE_first_tail_x15_r0_body.krC_52.targs (PRE_first_tail_x15_r0_body.clo52.filterMap fun i => (PRE_first_tail_x15_r0_body.kr0_52.targs.get i).map (i, ·))
kernel_rfl PRE_first_tail_x15_r0_body.fkf152 : PRE_first_tail_x15_r0_body.kr1_52.flags = Stage.setAll PRE_first_tail_x15_r0_body.krC_52.flags (PRE_first_tail_x15_r0_body.cwS52.filterMap fun i => (PRE_first_tail_x15_r0_body.kr1_52.flags.get i).map (i, ·))
kernel_rfl PRE_first_tail_x15_r0_body.fkt152 : PRE_first_tail_x15_r0_body.kr1_52.targs = Stage.setAll PRE_first_tail_x15_r0_body.krC_52.targs (PRE_first_tail_x15_r0_body.cwS52.filterMap fun i => (PRE_first_tail_x15_r0_body.kr1_52.targs.get i).map (i, ·))
kernel_rfl PRE_first_tail_x15_r0_body.fkck52 : krecLB PRE_first_tail_x15_r0_body.kappa52 2303 PRE_first_tail_x15_r0_body.cx0_52.mlx PRE_first_tail_x15_r0_body.kr0_52 PRE_first_tail_x15_r0_body.kr1_52 PRE_first_tail_x15_r0_body.clo52 = true
kernel_rfl PRE_first_tail_x15_r0_body.fkn52 : Nat.ble 2303 2303 = true
-- the bridge and the pending traces' regions
kernel_rfl PRE_first_tail_x15_r0_body.cbridge52 : Host.Ts.Sim.Full.bridgeOf PRE_first_tail_x15_r0_body.s514.ffi = Host.Ts.Sim.Full.bridgeOf PRE_first_tail_x15_r0_body.s515.ffi
kernel_rfl PRE_first_tail_x15_r0_body.cpendR52 : pendRegB PRE_first_tail_x15_r0_body.kappa52 (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s515.ffi).mlx = true
kernel_rfl PRE_first_tail_x15_r0_body.cpendLe52 : Nat.ble (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s515.ffi).mlx.next (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s514.ffi).mlx.next = true
/-- **The compaction's native shift**, given the call's bookkeeping, its relation's facts (the model's and the
observers') and the canonical closedness. -/
theorem PRE_first_tail_x15_r0_body.cshift52 (clean : Conv.NClean (⟨19233, 16329, 2715879, 2303⟩ : Conv.Cnt) (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s513.ffi).mlx) (hltC : ∀ h, PH (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s513.ffi).mlx h → h < (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s513.ffi).mlx.next) (nltC : ∀ i, PN (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s513.ffi).mlx i → i < (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s513.ffi).mlx.nnext) (itemsC : ∀ k v, (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s513.ffi).mlx.items.get k = some v → PN (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s513.ffi).mlx k) (tracedC : ∀ h o, (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s513.ffi).mlx.objs.get h = some o → ∀ i ∈ objTraces o, i < PRE_first_tail_x15_r0_body.P52.NL) (cl : SSt (· < 2303) PRE_first_tail_x15_r0_body.cx0_52.mlx)
    (hobjC : ∀ h, PRE_first_tail_x15_r0_body.fxC_52.get h = some () → ((Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s513.ffi).mlx.objs.get h).isSome = true)
    (hfC : ∀ h, (PRE_first_tail_x15_r0_body.krC_52.flags.get h).isSome = true → ((Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s513.ffi).mlx.objs.get h).isSome = true)
    (htC : ∀ h, (PRE_first_tail_x15_r0_body.krC_52.targs.get h).isSome = true → ((Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s513.ffi).mlx.objs.get h).isSome = true)
    (hclC : ∀ h l, PRE_first_tail_x15_r0_body.krC_52.targs.get h = some l → Host.Ts.Sim.Full.STargs (· < (⟨19233, 16329, 2715879, 2303⟩ : Conv.Cnt).n) l) :
    Conv.FullShiftQ PRE_first_tail_x15_r0_body.P52 2303 PRE_first_tail_x15_r0_body.kappa52 PRE_first_tail_x15_r0_body.s515.ffi PRE_first_tail_x15_r0_body.s514.ffi :=
  ⟨PRE_first_tail_x15_r0_body.cnshift52 clean hltC nltC itemsC tracedC cl, PRE_first_tail_x15_r0_body.cqueue52, fun t ht => bSN_sound (List.all_eq_true.mp PRE_first_tail_x15_r0_body.ctokSupp52 t ht),
    PRE_first_tail_x15_r0_body.cbridge52,
    liveShift_foot (x0' := Host.Ts.Sim.Full.mlxOf PRE_first_tail_x15_r0_body.s515.ffi) (x1' := Host.Ts.Sim.Full.mlxOf PRE_first_tail_x15_r0_body.s514.ffi) (PRE_first_tail_x15_r0_body.cfoot52 clean hltC nltC itemsC tracedC cl) rfl PRE_first_tail_x15_r0_body.ofx0_52 PRE_first_tail_x15_r0_body.ofx1_52 hobjC PRE_first_tail_x15_r0_body.ff052 PRE_first_tail_x15_r0_body.ff152 PRE_first_tail_x15_r0_body.ffck52,
    kernShift_foot (x0' := Host.Ts.Sim.Full.mlxOf PRE_first_tail_x15_r0_body.s515.ffi) (x1' := Host.Ts.Sim.Full.mlxOf PRE_first_tail_x15_r0_body.s514.ffi) (PRE_first_tail_x15_r0_body.cfoot52 clean hltC nltC itemsC tracedC cl) rfl PRE_first_tail_x15_r0_body.okr0_52 PRE_first_tail_x15_r0_body.okr1_52 (Nat.le_of_ble_eq_true PRE_first_tail_x15_r0_body.fkn52) hfC htC hclC
      PRE_first_tail_x15_r0_body.fkf052 PRE_first_tail_x15_r0_body.fkt052 PRE_first_tail_x15_r0_body.fkf152 PRE_first_tail_x15_r0_body.fkt152 PRE_first_tail_x15_r0_body.fkck52,
    pendReg_of rfl PRE_first_tail_x15_r0_body.cnh052 PRE_first_tail_x15_r0_body.cnh152 (Nat.le_of_ble_eq_true PRE_first_tail_x15_r0_body.cpendLe52) PRE_first_tail_x15_r0_body.cpendR52⟩

end Host.Load.Run.Tpl
