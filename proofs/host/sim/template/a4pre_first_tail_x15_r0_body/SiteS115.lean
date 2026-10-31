import host.sim.template.a4pre_first_tail_x15_r0_body.SiteCl115
import host.sim.conv.CompactFull
import host.sim.template.FootGen
set_option Elab.async false
namespace Host.Load.Run.Tpl
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
open Host.Ts Host.Ts.Sim Host.Ts.Sim.Template

/-! The compaction's native shift at call site 115 from its footprint (`Conv.nshift_of_foot`), and the observers'
(`liveShift_foot`, `kernShift_foot`): `Conv.FullShiftQ` for `Conv.full_compactQ`, given the call's bookkeeping and its
relation's facts. -/

/-- The load parameters of the chain (band-free: its start's node counter as `NL` and `N0`). -/
def PRE_first_tail_x15_r0_body.Pc115 : LoadP := ⟨18151, 131072, 1099511627776, 15235, 15235, []⟩
/-- The site's band raised to the map's checked fixed-node prefix, including newly recorded closure traces. -/
def PRE_first_tail_x15_r0_body.P115 : LoadP := PRE_first_tail_x15_r0_body.Pc115.raise 17577
kernel_rfl PRE_first_tail_x15_r0_body.craise115 : Nat.ble PRE_first_tail_x15_r0_body.Pc115.N0 17577 = true
theorem PRE_first_tail_x15_r0_body.raised115 : Host.Ts.Sim.Full.Raised PRE_first_tail_x15_r0_body.Pc115 PRE_first_tail_x15_r0_body.P115 :=
  .inr ⟨17577, rfl, Nat.le_of_ble_eq_true PRE_first_tail_x15_r0_body.craise115, rfl⟩
noncomputable abbrev PRE_first_tail_x15_r0_body.cx0_115 : Host.Load.LSt := clearTokens (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1119.ffi)
noncomputable abbrev PRE_first_tail_x15_r0_body.cx1_115 : Host.Load.LSt := clearTokens (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1118.ffi)
def PRE_first_tail_x15_r0_body.khinv115 : PTrie Nat := Stage.setAll PTrie.nil []
def PRE_first_tail_x15_r0_body.kninv115 : PTrie Nat := Stage.setAll PTrie.nil []
/-- The stage's footprint: its written and fresh handles, fresh nodes, written and fresh items. -/
def PRE_first_tail_x15_r0_body.cwS115 : List Nat := []
def PRE_first_tail_x15_r0_body.cnS115 : List Nat := List.range' 17577 0
def PRE_first_tail_x15_r0_body.ciS115 : List Nat := [] ++ List.range' 17577 0

-- the small checks (`MChecks`'s)
kernel_rfl PRE_first_tail_x15_r0_body.cnh0115 : PRE_first_tail_x15_r0_body.kd115.nh0 = PRE_first_tail_x15_r0_body.cx0_115.mlx.next
kernel_rfl PRE_first_tail_x15_r0_body.cnh1115 : PRE_first_tail_x15_r0_body.kd115.nh1 = PRE_first_tail_x15_r0_body.cx1_115.mlx.next
kernel_rfl PRE_first_tail_x15_r0_body.cnn0115 : PRE_first_tail_x15_r0_body.kd115.nn0 = PRE_first_tail_x15_r0_body.cx0_115.mlx.nnext
kernel_rfl PRE_first_tail_x15_r0_body.cnn1115 : PRE_first_tail_x15_r0_body.kd115.nn1 = PRE_first_tail_x15_r0_body.cx1_115.mlx.nnext
kernel_rfl PRE_first_tail_x15_r0_body.cplo115 : (Nat.blt 0 PRE_first_tail_x15_r0_body.P115.lo && Nat.ble PRE_first_tail_x15_r0_body.P115.lo PRE_first_tail_x15_r0_body.cx0_115.mlx.next && Nat.ble PRE_first_tail_x15_r0_body.P115.lo RData.bigHi && Nat.ble RData.bigHi PRE_first_tail_x15_r0_body.P115.E) = true
kernel_rfl PRE_first_tail_x15_r0_body.ccnt115 : (Nat.ble PRE_first_tail_x15_r0_body.cx0_115.mlx.next PRE_first_tail_x15_r0_body.cx1_115.mlx.next && Nat.ble PRE_first_tail_x15_r0_body.cx0_115.mlx.nnext PRE_first_tail_x15_r0_body.cx1_115.mlx.nnext) = true
kernel_rfl PRE_first_tail_x15_r0_body.cnband115 : (Nat.blt 0 PRE_first_tail_x15_r0_body.P115.NL && Nat.ble PRE_first_tail_x15_r0_body.P115.NL PRE_first_tail_x15_r0_body.P115.N0 && Nat.ble PRE_first_tail_x15_r0_body.P115.N0 PRE_first_tail_x15_r0_body.cx0_115.mlx.nnext) = true
kernel_rfl PRE_first_tail_x15_r0_body.chbelow115 : PRE_first_tail_x15_r0_body.kd115.checkHndBelow = true
kernel_rfl PRE_first_tail_x15_r0_body.chren115 : checkRenG PRE_first_tail_x15_r0_body.kd115.hnd PRE_first_tail_x15_r0_body.khinv115 (phB PRE_first_tail_x15_r0_body.cx0_115.mlx) = true
kernel_rfl PRE_first_tail_x15_r0_body.cband115 : PRE_first_tail_x15_r0_body.kd115.checkBand PRE_first_tail_x15_r0_body.P115.lo = true
kernel_rfl PRE_first_tail_x15_r0_body.cnh1pos115 : Nat.blt 0 PRE_first_tail_x15_r0_body.kd115.nh1 = true
kernel_rfl PRE_first_tail_x15_r0_body.cnren115 : checkRenG PRE_first_tail_x15_r0_body.kd115.node PRE_first_tail_x15_r0_body.kninv115 (pnB PRE_first_tail_x15_r0_body.cx0_115.mlx) = true
kernel_rfl PRE_first_tail_x15_r0_body.cnlow115 : (PTrie.keysA PRE_first_tail_x15_r0_body.kd115.node).all (fun j => Nat.ble PRE_first_tail_x15_r0_body.P115.NL j && Nat.blt (PRE_first_tail_x15_r0_body.kd115.nodeF j) PRE_first_tail_x15_r0_body.cx1_115.mlx.nnext) = true
kernel_rfl PRE_first_tail_x15_r0_body.cabs0a115 : PRE_first_tail_x15_r0_body.cx0_115.mlx.arrs.get 0 = none
kernel_rfl PRE_first_tail_x15_r0_body.cabs0b115 : PRE_first_tail_x15_r0_body.cx0_115.mlx.objs.get 0 = none
kernel_rfl PRE_first_tail_x15_r0_body.ctok1115 : PRE_first_tail_x15_r0_body.cx1_115.mlx.tokens = []
kernel_rfl PRE_first_tail_x15_r0_body.cpend115 : PRE_first_tail_x15_r0_body.cx1_115.mlx.pending = PRE_first_tail_x15_r0_body.cx0_115.mlx.pending.map PRE_first_tail_x15_r0_body.kappa115.pend
kernel_rfl PRE_first_tail_x15_r0_body.cerrh115 : PRE_first_tail_x15_r0_body.cx1_115.mlx.errh = PRE_first_tail_x15_r0_body.cx0_115.mlx.errh.map PRE_first_tail_x15_r0_body.kappa115.arg
kernel_rfl PRE_first_tail_x15_r0_body.cfiles115 : PRE_first_tail_x15_r0_body.cx1_115.mlx.files = PRE_first_tail_x15_r0_body.cx0_115.mlx.files
kernel_rfl PRE_first_tail_x15_r0_body.carch115 : PRE_first_tail_x15_r0_body.cx1_115.mlx.arch = PRE_first_tail_x15_r0_body.cx0_115.mlx.arch
kernel_rfl PRE_first_tail_x15_r0_body.csizes115 : PRE_first_tail_x15_r0_body.cx1_115.mlx.deviceSizes = PRE_first_tail_x15_r0_body.cx0_115.mlx.deviceSizes
kernel_rfl PRE_first_tail_x15_r0_body.cwired115 : PRE_first_tail_x15_r0_body.cx1_115.mlx.wired = PRE_first_tail_x15_r0_body.cx0_115.mlx.wired
kernel_rfl PRE_first_tail_x15_r0_body.chost115 : PRE_first_tail_x15_r0_body.cx1_115.host = PRE_first_tail_x15_r0_body.cx0_115.host
-- the compaction map's addresses are `PRE_first_tail_x15_r0_body.kd115`'s
kernel_rfl PRE_first_tail_x15_r0_body.ckn0115 : PRE_first_tail_x15_r0_body.kd115.n0 = 2765219
kernel_rfl PRE_first_tail_x15_r0_body.ckn1115 : PRE_first_tail_x15_r0_body.kd115.n1 = 2765221
kernel_rfl PRE_first_tail_x15_r0_body.ckheap115 : (PTrie.keysA PRE_first_tail_x15_r0_body.kd115.heap).all (fun x => Nat.ble 2765219 x) = true
kernel_rfl PRE_first_tail_x15_r0_body.ckpl115 : (List.range 0).all (fun j => decide (PRE_first_tail_x15_r0_body.kd115.heap.get (2765219 + j) = nth? PRE_first_tail_x15_r0_body.pl115 j)) = true
-- the map fixes the call's names (`Conv.fixOld_compact`), the call's counters
kernel_rfl PRE_first_tail_x15_r0_body.fja115 : Nat.ble 2765219 2765219 = true
kernel_rfl PRE_first_tail_x15_r0_body.fn115 : Nat.ble 4997 4997 = true
kernel_rfl PRE_first_tail_x15_r0_body.fjaD115 : Nat.ble 2765219 PRE_first_tail_x15_r0_body.kd115.n0 = true
kernel_rfl PRE_first_tail_x15_r0_body.fxn115 : Nat.ble 20470 PRE_first_tail_x15_r0_body.kd115.nh0 = true
kernel_rfl PRE_first_tail_x15_r0_body.fnn115 : Nat.ble 17577 PRE_first_tail_x15_r0_body.kd115.nn0 = true
kernel_rfl PRE_first_tail_x15_r0_body.fxb115 : Nat.ble 20470 RData.bigHi = true
kernel_rfl PRE_first_tail_x15_r0_body.fheap115 : (PTrie.keysA PRE_first_tail_x15_r0_body.kd115.heap).all (Nat.ble (⟨20470, 17577, 2765219, 4997⟩ : Conv.Cnt).ja) = true
kernel_rfl PRE_first_tail_x15_r0_body.fhnd115 : (PTrie.keysA PRE_first_tail_x15_r0_body.kd115.hnd).all (Nat.ble (⟨20470, 17577, 2765219, 4997⟩ : Conv.Cnt).xn) = true
kernel_rfl PRE_first_tail_x15_r0_body.fnode115 : (PTrie.keysA PRE_first_tail_x15_r0_body.kd115.node).all (Nat.ble (⟨20470, 17577, 2765219, 4997⟩ : Conv.Cnt).nn) = true
/-- The compaction map fixes the call's names. -/
theorem PRE_first_tail_x15_r0_body.cfix115 : Conv.FixOld (⟨20470, 17577, 2765219, 4997⟩ : Conv.Cnt) PRE_first_tail_x15_r0_body.kappa115 :=
  Conv.fixOld_compact (Nat.le_of_ble_eq_true PRE_first_tail_x15_r0_body.fja115) (Nat.le_of_ble_eq_true PRE_first_tail_x15_r0_body.fn115) (Nat.le_of_ble_eq_true PRE_first_tail_x15_r0_body.fjaD115) (Nat.le_of_ble_eq_true PRE_first_tail_x15_r0_body.fxn115) (Nat.le_of_ble_eq_true PRE_first_tail_x15_r0_body.fnn115) (Nat.le_of_ble_eq_true PRE_first_tail_x15_r0_body.fxb115) PRE_first_tail_x15_r0_body.fheap115 PRE_first_tail_x15_r0_body.fhnd115 PRE_first_tail_x15_r0_body.fnode115
kernel_rfl PRE_first_tail_x15_r0_body.fcxn115 : (⟨20470, 17577, 2765219, 4997⟩ : Conv.Cnt).xn = (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1117.ffi).mlx.next
kernel_rfl PRE_first_tail_x15_r0_body.fcnn115 : (⟨20470, 17577, 2765219, 4997⟩ : Conv.Cnt).nn = (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1117.ffi).mlx.nnext
kernel_rfl PRE_first_tail_x15_r0_body.fle0115 : (Nat.ble (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1117.ffi).mlx.next PRE_first_tail_x15_r0_body.cx0_115.mlx.next && Nat.ble (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1117.ffi).mlx.nnext PRE_first_tail_x15_r0_body.cx0_115.mlx.nnext && Nat.ble (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1117.ffi).mlx.next RData.bigHi) = true
kernel_rfl PRE_first_tail_x15_r0_body.fnk115 : (PTrie.keysA PRE_first_tail_x15_r0_body.kd115.node).all (Nat.ble (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1117.ffi).mlx.nnext) = true
-- the merged state keeps the call's entries off the stage's footprint
kernel_rfl PRE_first_tail_x15_r0_body.f1A115 : PRE_first_tail_x15_r0_body.cx1_115.mlx.arrs = Stage.setAll (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1117.ffi).mlx.arrs (PRE_first_tail_x15_r0_body.cwS115.filterMap fun i => (PRE_first_tail_x15_r0_body.cx1_115.mlx.arrs.get i).map (i, ·))
kernel_rfl PRE_first_tail_x15_r0_body.f1O115 : PRE_first_tail_x15_r0_body.cx1_115.mlx.objs = Stage.setAll (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1117.ffi).mlx.objs (PRE_first_tail_x15_r0_body.cwS115.filterMap fun i => (PRE_first_tail_x15_r0_body.cx1_115.mlx.objs.get i).map (i, ·))
kernel_rfl PRE_first_tail_x15_r0_body.f1N115 : PRE_first_tail_x15_r0_body.cx1_115.mlx.nodes = Stage.setAll (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1117.ffi).mlx.nodes (PRE_first_tail_x15_r0_body.cnS115.filterMap fun i => (PRE_first_tail_x15_r0_body.cx1_115.mlx.nodes.get i).map (i, ·))
kernel_rfl PRE_first_tail_x15_r0_body.f1I115 : PRE_first_tail_x15_r0_body.cx1_115.mlx.items = Stage.setAll (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1117.ffi).mlx.items (PRE_first_tail_x15_r0_body.ciS115.filterMap fun i => (PRE_first_tail_x15_r0_body.cx1_115.mlx.items.get i).map (i, ·))
kernel_rfl PRE_first_tail_x15_r0_body.fbd115 : (PRE_first_tail_x15_r0_body.clo115 ++ PRE_first_tail_x15_r0_body.cln115 ++ PRE_first_tail_x15_r0_body.cli115 ++ PRE_first_tail_x15_r0_body.cwS115 ++ PRE_first_tail_x15_r0_body.cnS115 ++ PRE_first_tail_x15_r0_body.ciS115).all (fun i => Nat.blt (i / 4096) (4 ^ 31)) = true
kernel_rfl PRE_first_tail_x15_r0_body.fincW115 : PRE_first_tail_x15_r0_body.cwS115.all (fun h => !Nat.blt h (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1117.ffi).mlx.next || PRE_first_tail_x15_r0_body.clo115.contains h) = true
kernel_rfl PRE_first_tail_x15_r0_body.fincI115 : PRE_first_tail_x15_r0_body.ciS115.all (fun k => !Nat.blt k (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1117.ffi).mlx.nnext || PRE_first_tail_x15_r0_body.cli115.contains k) = true
kernel_rfl PRE_first_tail_x15_r0_body.fincN115 : PRE_first_tail_x15_r0_body.cnS115.all (Nat.ble (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1117.ffi).mlx.nnext) = true
kernel_rfl PRE_first_tail_x15_r0_body.flnF115 : PRE_first_tail_x15_r0_body.cln115.all (Nat.ble (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1117.ffi).mlx.nnext) = true
-- the checks over the changed lists
kernel_rfl PRE_first_tail_x15_r0_body.fh115 : PRE_first_tail_x15_r0_body.clo115.all (handleOK PRE_first_tail_x15_r0_body.kappa115 PRE_first_tail_x15_r0_body.P115.lo PRE_first_tail_x15_r0_body.cx0_115.mlx PRE_first_tail_x15_r0_body.cx1_115.mlx) = true
kernel_rfl PRE_first_tail_x15_r0_body.fo115 : PRE_first_tail_x15_r0_body.clo115.map (fun h => PRE_first_tail_x15_r0_body.cx1_115.mlx.objs.get (PRE_first_tail_x15_r0_body.kappa115.handle h)) = PRE_first_tail_x15_r0_body.clo115.map (fun h => (PRE_first_tail_x15_r0_body.cx0_115.mlx.objs.get h).map PRE_first_tail_x15_r0_body.kappa115.nobj)
kernel_rfl PRE_first_tail_x15_r0_body.fok115 : PRE_first_tail_x15_r0_body.clo115.all (objOK PRE_first_tail_x15_r0_body.kappa115 PRE_first_tail_x15_r0_body.P115.NL PRE_first_tail_x15_r0_body.cx0_115.mlx) = true
kernel_rfl PRE_first_tail_x15_r0_body.fnd115 : PRE_first_tail_x15_r0_body.cln115.all (nodeOKF PRE_first_tail_x15_r0_body.kappa115 PRE_first_tail_x15_r0_body.P115 PRE_first_tail_x15_r0_body.cx0_115.mlx PRE_first_tail_x15_r0_body.cx1_115.mlx) = true
kernel_rfl PRE_first_tail_x15_r0_body.fp115 : ((PRE_first_tail_x15_r0_body.cln115.filter (fullB PRE_first_tail_x15_r0_body.P115))).map (fun i => (PRE_first_tail_x15_r0_body.cx1_115.mlx.nodes.get (PRE_first_tail_x15_r0_body.kappa115.node i)).map Host.Mlx.Ffi.Node.prim) =
  ((PRE_first_tail_x15_r0_body.cln115.filter (fullB PRE_first_tail_x15_r0_body.P115))).map (fun i => (PRE_first_tail_x15_r0_body.cx0_115.mlx.nodes.get i).map fun nd => PRE_first_tail_x15_r0_body.kappa115.prim nd.prim)
kernel_rfl PRE_first_tail_x15_r0_body.fnordI115 : incrB PRE_first_tail_x15_r0_body.kd115.nodeF (List.range' 17577 0) = true
kernel_rfl PRE_first_tail_x15_r0_body.fnordK115 : (PTrie.keysA PRE_first_tail_x15_r0_body.kd115.node).all (fun k => Nat.ble 17577 k && Nat.blt k 17577) = true
kernel_rfl PRE_first_tail_x15_r0_body.fnordL115 : (PRE_first_tail_x15_r0_body.cln115.filter (Nat.ble PRE_first_tail_x15_r0_body.P115.N0)).all (fun i => Nat.ble i (PRE_first_tail_x15_r0_body.kd115.nodeF i) && (Nat.blt i 17577 || Nat.ble PRE_first_tail_x15_r0_body.kd115.nn0 i)) = true
theorem PRE_first_tail_x15_r0_body.fnord115 : (PRE_first_tail_x15_r0_body.cln115.filter (Nat.ble PRE_first_tail_x15_r0_body.P115.N0)).all (fun i => Nat.ble i (PRE_first_tail_x15_r0_body.kd115.nodeF i) &&
    (PTrie.keysA PRE_first_tail_x15_r0_body.kd115.node).all fun j => !Nat.blt j i || Nat.blt (PRE_first_tail_x15_r0_body.kd115.nodeF j) (PRE_first_tail_x15_r0_body.kd115.nodeF i)) = true :=
  cnord_of PRE_first_tail_x15_r0_body.cnlow115 PRE_first_tail_x15_r0_body.cnn1115 PRE_first_tail_x15_r0_body.fnordI115 PRE_first_tail_x15_r0_body.fnordK115 PRE_first_tail_x15_r0_body.fnordL115
kernel_rfl PRE_first_tail_x15_r0_body.fi115 : PRE_first_tail_x15_r0_body.cli115.all (pnB PRE_first_tail_x15_r0_body.cx0_115.mlx) = true
kernel_rfl PRE_first_tail_x15_r0_body.fii115 : PRE_first_tail_x15_r0_body.cli115.all (fun k => decide (PRE_first_tail_x15_r0_body.cx1_115.mlx.items.get (PRE_first_tail_x15_r0_body.kappa115.node k) = (PRE_first_tail_x15_r0_body.cx0_115.mlx.items.get k).map PRE_first_tail_x15_r0_body.kappa115.nv)) = true
/-- **The compaction's footprint.** -/
theorem PRE_first_tail_x15_r0_body.cfoot115 (clean : Conv.NClean (⟨20470, 17577, 2765219, 4997⟩ : Conv.Cnt) (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1117.ffi).mlx) (hltC : ∀ h, PH (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1117.ffi).mlx h → h < (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1117.ffi).mlx.next) (nltC : ∀ i, PN (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1117.ffi).mlx i → i < (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1117.ffi).mlx.nnext) (itemsC : ∀ k v, (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1117.ffi).mlx.items.get k = some v → PN (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1117.ffi).mlx k) (tracedC : ∀ h o, (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1117.ffi).mlx.objs.get h = some o → ∀ i ∈ objTraces o, i < PRE_first_tail_x15_r0_body.P115.NL) (cl : SSt (· < 4997) PRE_first_tail_x15_r0_body.cx0_115.mlx) :
    Conv.MFoot PRE_first_tail_x15_r0_body.P115 4997 PRE_first_tail_x15_r0_body.kappa115 PRE_first_tail_x15_r0_body.kd115 PRE_first_tail_x15_r0_body.khinv115 PRE_first_tail_x15_r0_body.kninv115 (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1117.ffi).mlx PRE_first_tail_x15_r0_body.cx0_115.mlx PRE_first_tail_x15_r0_body.cx1_115.mlx (⟨20470, 17577, 2765219, 4997⟩ : Conv.Cnt) PRE_first_tail_x15_r0_body.clo115 PRE_first_tail_x15_r0_body.cln115 PRE_first_tail_x15_r0_body.cli115 PRE_first_tail_x15_r0_body.cwS115 PRE_first_tail_x15_r0_body.cnS115 PRE_first_tail_x15_r0_body.ciS115 :=
  ⟨rfl, rfl, rfl, PRE_first_tail_x15_r0_body.cnh0115, PRE_first_tail_x15_r0_body.cnh1115, PRE_first_tail_x15_r0_body.cnn0115, PRE_first_tail_x15_r0_body.cnn1115, PRE_first_tail_x15_r0_body.cplo115, PRE_first_tail_x15_r0_body.ccnt115, PRE_first_tail_x15_r0_body.cnband115, PRE_first_tail_x15_r0_body.chbelow115, PRE_first_tail_x15_r0_body.chren115, PRE_first_tail_x15_r0_body.cband115, PRE_first_tail_x15_r0_body.cnh1pos115, PRE_first_tail_x15_r0_body.cnren115, PRE_first_tail_x15_r0_body.cnlow115, PRE_first_tail_x15_r0_body.cabs0a115, PRE_first_tail_x15_r0_body.cabs0b115, PRE_first_tail_x15_r0_body.ctok1115, PRE_first_tail_x15_r0_body.cpend115, PRE_first_tail_x15_r0_body.cerrh115, PRE_first_tail_x15_r0_body.cfiles115, PRE_first_tail_x15_r0_body.carch115, PRE_first_tail_x15_r0_body.csizes115, PRE_first_tail_x15_r0_body.cwired115, PRE_first_tail_x15_r0_body.cfix115, clean, PRE_first_tail_x15_r0_body.fcxn115, PRE_first_tail_x15_r0_body.fcnn115, hltC, nltC, itemsC, tracedC, cl, PRE_first_tail_x15_r0_body.fle0115, PRE_first_tail_x15_r0_body.fnk115, PRE_first_tail_x15_r0_body.ckA115, PRE_first_tail_x15_r0_body.cobjsK115, PRE_first_tail_x15_r0_body.cnodesK115, PRE_first_tail_x15_r0_body.citemsK115, PRE_first_tail_x15_r0_body.f1A115, PRE_first_tail_x15_r0_body.f1O115, PRE_first_tail_x15_r0_body.f1N115, PRE_first_tail_x15_r0_body.f1I115, PRE_first_tail_x15_r0_body.fbd115, PRE_first_tail_x15_r0_body.fincW115, PRE_first_tail_x15_r0_body.fincI115, PRE_first_tail_x15_r0_body.fincN115, PRE_first_tail_x15_r0_body.flnF115, PRE_first_tail_x15_r0_body.fh115, PRE_first_tail_x15_r0_body.fo115, PRE_first_tail_x15_r0_body.fok115, PRE_first_tail_x15_r0_body.fnd115, PRE_first_tail_x15_r0_body.fp115, PRE_first_tail_x15_r0_body.fnord115, PRE_first_tail_x15_r0_body.fi115, PRE_first_tail_x15_r0_body.fii115⟩
theorem PRE_first_tail_x15_r0_body.cnshift115 (clean : Conv.NClean (⟨20470, 17577, 2765219, 4997⟩ : Conv.Cnt) (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1117.ffi).mlx) (hltC : ∀ h, PH (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1117.ffi).mlx h → h < (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1117.ffi).mlx.next) (nltC : ∀ i, PN (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1117.ffi).mlx i → i < (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1117.ffi).mlx.nnext) (itemsC : ∀ k v, (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1117.ffi).mlx.items.get k = some v → PN (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1117.ffi).mlx k) (tracedC : ∀ h o, (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1117.ffi).mlx.objs.get h = some o → ∀ i ∈ objTraces o, i < PRE_first_tail_x15_r0_body.P115.NL) (cl : SSt (· < 4997) PRE_first_tail_x15_r0_body.cx0_115.mlx) : NShift PRE_first_tail_x15_r0_body.P115 4997 PRE_first_tail_x15_r0_body.kappa115 PRE_first_tail_x15_r0_body.cx0_115 PRE_first_tail_x15_r0_body.cx1_115 :=
  Conv.nshift_of_foot (PRE_first_tail_x15_r0_body.cfoot115 clean hltC nltC itemsC tracedC cl) PRE_first_tail_x15_r0_body.chost115 (compact_a_eq PRE_first_tail_x15_r0_body.ckn0115 PRE_first_tail_x15_r0_body.ckn1115 PRE_first_tail_x15_r0_body.ckheap115 PRE_first_tail_x15_r0_body.ckpl115)

-- the observers: the layers' states at the call, the canonical and the merged state, their footprints and checks
noncomputable def PRE_first_tail_x15_r0_body.fxC_115 : PTrie Unit := (Host.Ts.Sim.Full.freedOf PRE_first_tail_x15_r0_body.s1117.ffi).getD PTrie.nil
noncomputable def PRE_first_tail_x15_r0_body.krC_115 : Host.Load.Layers.KRec := (Host.Ts.Sim.Full.krecOf PRE_first_tail_x15_r0_body.s1117.ffi).getD Host.Load.Layers.KRec.empty
kernel_rfl PRE_first_tail_x15_r0_body.ofxC_115 : (Host.Ts.Sim.Full.freedOf PRE_first_tail_x15_r0_body.s1117.ffi) = some PRE_first_tail_x15_r0_body.fxC_115
kernel_rfl PRE_first_tail_x15_r0_body.okrC_115 : (Host.Ts.Sim.Full.krecOf PRE_first_tail_x15_r0_body.s1117.ffi) = some PRE_first_tail_x15_r0_body.krC_115
noncomputable def PRE_first_tail_x15_r0_body.fx0_115 : PTrie Unit := (Host.Ts.Sim.Full.freedOf PRE_first_tail_x15_r0_body.s1119.ffi).getD PTrie.nil
noncomputable def PRE_first_tail_x15_r0_body.kr0_115 : Host.Load.Layers.KRec := (Host.Ts.Sim.Full.krecOf PRE_first_tail_x15_r0_body.s1119.ffi).getD Host.Load.Layers.KRec.empty
kernel_rfl PRE_first_tail_x15_r0_body.ofx0_115 : (Host.Ts.Sim.Full.freedOf PRE_first_tail_x15_r0_body.s1119.ffi) = some PRE_first_tail_x15_r0_body.fx0_115
kernel_rfl PRE_first_tail_x15_r0_body.okr0_115 : (Host.Ts.Sim.Full.krecOf PRE_first_tail_x15_r0_body.s1119.ffi) = some PRE_first_tail_x15_r0_body.kr0_115
noncomputable def PRE_first_tail_x15_r0_body.fx1_115 : PTrie Unit := (Host.Ts.Sim.Full.freedOf PRE_first_tail_x15_r0_body.s1118.ffi).getD PTrie.nil
noncomputable def PRE_first_tail_x15_r0_body.kr1_115 : Host.Load.Layers.KRec := (Host.Ts.Sim.Full.krecOf PRE_first_tail_x15_r0_body.s1118.ffi).getD Host.Load.Layers.KRec.empty
kernel_rfl PRE_first_tail_x15_r0_body.ofx1_115 : (Host.Ts.Sim.Full.freedOf PRE_first_tail_x15_r0_body.s1118.ffi) = some PRE_first_tail_x15_r0_body.fx1_115
kernel_rfl PRE_first_tail_x15_r0_body.okr1_115 : (Host.Ts.Sim.Full.krecOf PRE_first_tail_x15_r0_body.s1118.ffi) = some PRE_first_tail_x15_r0_body.kr1_115
kernel_rfl PRE_first_tail_x15_r0_body.ff0115 : PRE_first_tail_x15_r0_body.fx0_115 = Stage.setAll PRE_first_tail_x15_r0_body.fxC_115 (PRE_first_tail_x15_r0_body.clo115.filterMap fun i => (PRE_first_tail_x15_r0_body.fx0_115.get i).map (i, ·))
kernel_rfl PRE_first_tail_x15_r0_body.ff1115 : PRE_first_tail_x15_r0_body.fx1_115 = Stage.setAll PRE_first_tail_x15_r0_body.fxC_115 (PRE_first_tail_x15_r0_body.cwS115.filterMap fun i => (PRE_first_tail_x15_r0_body.fx1_115.get i).map (i, ·))
kernel_rfl PRE_first_tail_x15_r0_body.ffck115 : freedLB PRE_first_tail_x15_r0_body.kappa115 PRE_first_tail_x15_r0_body.cx0_115.mlx PRE_first_tail_x15_r0_body.fx0_115 PRE_first_tail_x15_r0_body.fx1_115 PRE_first_tail_x15_r0_body.clo115 = true
kernel_rfl PRE_first_tail_x15_r0_body.fkf0115 : PRE_first_tail_x15_r0_body.kr0_115.flags = Stage.setAll PRE_first_tail_x15_r0_body.krC_115.flags (PRE_first_tail_x15_r0_body.clo115.filterMap fun i => (PRE_first_tail_x15_r0_body.kr0_115.flags.get i).map (i, ·))
kernel_rfl PRE_first_tail_x15_r0_body.fkt0115 : PRE_first_tail_x15_r0_body.kr0_115.targs = Stage.setAll PRE_first_tail_x15_r0_body.krC_115.targs (PRE_first_tail_x15_r0_body.clo115.filterMap fun i => (PRE_first_tail_x15_r0_body.kr0_115.targs.get i).map (i, ·))
kernel_rfl PRE_first_tail_x15_r0_body.fkf1115 : PRE_first_tail_x15_r0_body.kr1_115.flags = Stage.setAll PRE_first_tail_x15_r0_body.krC_115.flags (PRE_first_tail_x15_r0_body.cwS115.filterMap fun i => (PRE_first_tail_x15_r0_body.kr1_115.flags.get i).map (i, ·))
kernel_rfl PRE_first_tail_x15_r0_body.fkt1115 : PRE_first_tail_x15_r0_body.kr1_115.targs = Stage.setAll PRE_first_tail_x15_r0_body.krC_115.targs (PRE_first_tail_x15_r0_body.cwS115.filterMap fun i => (PRE_first_tail_x15_r0_body.kr1_115.targs.get i).map (i, ·))
kernel_rfl PRE_first_tail_x15_r0_body.fkck115 : krecLB PRE_first_tail_x15_r0_body.kappa115 4997 PRE_first_tail_x15_r0_body.cx0_115.mlx PRE_first_tail_x15_r0_body.kr0_115 PRE_first_tail_x15_r0_body.kr1_115 PRE_first_tail_x15_r0_body.clo115 = true
kernel_rfl PRE_first_tail_x15_r0_body.fkn115 : Nat.ble 4997 4997 = true
-- the bridge and the pending traces' regions
kernel_rfl PRE_first_tail_x15_r0_body.cbridge115 : Host.Ts.Sim.Full.bridgeOf PRE_first_tail_x15_r0_body.s1118.ffi = Host.Ts.Sim.Full.bridgeOf PRE_first_tail_x15_r0_body.s1119.ffi
kernel_rfl PRE_first_tail_x15_r0_body.cpendR115 : pendRegB PRE_first_tail_x15_r0_body.kappa115 (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1119.ffi).mlx = true
kernel_rfl PRE_first_tail_x15_r0_body.cpendLe115 : Nat.ble (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1119.ffi).mlx.next (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1118.ffi).mlx.next = true
/-- **The compaction's native shift**, given the call's bookkeeping, its relation's facts (the model's and the
observers') and the canonical closedness. -/
theorem PRE_first_tail_x15_r0_body.cshift115 (clean : Conv.NClean (⟨20470, 17577, 2765219, 4997⟩ : Conv.Cnt) (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1117.ffi).mlx) (hltC : ∀ h, PH (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1117.ffi).mlx h → h < (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1117.ffi).mlx.next) (nltC : ∀ i, PN (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1117.ffi).mlx i → i < (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1117.ffi).mlx.nnext) (itemsC : ∀ k v, (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1117.ffi).mlx.items.get k = some v → PN (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1117.ffi).mlx k) (tracedC : ∀ h o, (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1117.ffi).mlx.objs.get h = some o → ∀ i ∈ objTraces o, i < PRE_first_tail_x15_r0_body.P115.NL) (cl : SSt (· < 4997) PRE_first_tail_x15_r0_body.cx0_115.mlx)
    (hobjC : ∀ h, PRE_first_tail_x15_r0_body.fxC_115.get h = some () → ((Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1117.ffi).mlx.objs.get h).isSome = true)
    (hfC : ∀ h, (PRE_first_tail_x15_r0_body.krC_115.flags.get h).isSome = true → ((Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1117.ffi).mlx.objs.get h).isSome = true)
    (htC : ∀ h, (PRE_first_tail_x15_r0_body.krC_115.targs.get h).isSome = true → ((Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1117.ffi).mlx.objs.get h).isSome = true)
    (hclC : ∀ h l, PRE_first_tail_x15_r0_body.krC_115.targs.get h = some l → Host.Ts.Sim.Full.STargs (· < (⟨20470, 17577, 2765219, 4997⟩ : Conv.Cnt).n) l) :
    Conv.FullShiftQ PRE_first_tail_x15_r0_body.P115 4997 PRE_first_tail_x15_r0_body.kappa115 PRE_first_tail_x15_r0_body.s1119.ffi PRE_first_tail_x15_r0_body.s1118.ffi :=
  ⟨PRE_first_tail_x15_r0_body.cnshift115 clean hltC nltC itemsC tracedC cl, PRE_first_tail_x15_r0_body.cqueue115, fun t ht => bSN_sound (List.all_eq_true.mp PRE_first_tail_x15_r0_body.ctokSupp115 t ht),
    PRE_first_tail_x15_r0_body.cbridge115,
    liveShift_foot (x0' := Host.Ts.Sim.Full.mlxOf PRE_first_tail_x15_r0_body.s1119.ffi) (x1' := Host.Ts.Sim.Full.mlxOf PRE_first_tail_x15_r0_body.s1118.ffi) (PRE_first_tail_x15_r0_body.cfoot115 clean hltC nltC itemsC tracedC cl) rfl PRE_first_tail_x15_r0_body.ofx0_115 PRE_first_tail_x15_r0_body.ofx1_115 hobjC PRE_first_tail_x15_r0_body.ff0115 PRE_first_tail_x15_r0_body.ff1115 PRE_first_tail_x15_r0_body.ffck115,
    kernShift_foot (x0' := Host.Ts.Sim.Full.mlxOf PRE_first_tail_x15_r0_body.s1119.ffi) (x1' := Host.Ts.Sim.Full.mlxOf PRE_first_tail_x15_r0_body.s1118.ffi) (PRE_first_tail_x15_r0_body.cfoot115 clean hltC nltC itemsC tracedC cl) rfl PRE_first_tail_x15_r0_body.okr0_115 PRE_first_tail_x15_r0_body.okr1_115 (Nat.le_of_ble_eq_true PRE_first_tail_x15_r0_body.fkn115) hfC htC hclC
      PRE_first_tail_x15_r0_body.fkf0115 PRE_first_tail_x15_r0_body.fkt0115 PRE_first_tail_x15_r0_body.fkf1115 PRE_first_tail_x15_r0_body.fkt1115 PRE_first_tail_x15_r0_body.fkck115,
    pendReg_of rfl PRE_first_tail_x15_r0_body.cnh0115 PRE_first_tail_x15_r0_body.cnh1115 (Nat.le_of_ble_eq_true PRE_first_tail_x15_r0_body.cpendLe115) PRE_first_tail_x15_r0_body.cpendR115⟩

end Host.Load.Run.Tpl
