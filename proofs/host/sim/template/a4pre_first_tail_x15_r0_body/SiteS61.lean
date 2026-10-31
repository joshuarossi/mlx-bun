import host.sim.template.a4pre_first_tail_x15_r0_body.SiteCl61
import host.sim.conv.CompactFull
import host.sim.template.FootGen
set_option Elab.async false
namespace Host.Load.Run.Tpl
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
open Host.Ts Host.Ts.Sim Host.Ts.Sim.Template

/-! The compaction's native shift at call site 61 from its footprint (`Conv.nshift_of_foot`), and the observers'
(`liveShift_foot`, `kernShift_foot`): `Conv.FullShiftQ` for `Conv.full_compactQ`, given the call's bookkeeping and its
relation's facts. -/

/-- The load parameters of the chain (band-free: its start's node counter as `NL` and `N0`). -/
def PRE_first_tail_x15_r0_body.Pc61 : LoadP := ⟨18151, 131072, 1099511627776, 15235, 15235, []⟩
/-- The site's band raised to the map's checked fixed-node prefix, including newly recorded closure traces. -/
def PRE_first_tail_x15_r0_body.P61 : LoadP := PRE_first_tail_x15_r0_body.Pc61.raise 16503
kernel_rfl PRE_first_tail_x15_r0_body.craise61 : Nat.ble PRE_first_tail_x15_r0_body.Pc61.N0 16503 = true
theorem PRE_first_tail_x15_r0_body.raised61 : Host.Ts.Sim.Full.Raised PRE_first_tail_x15_r0_body.Pc61 PRE_first_tail_x15_r0_body.P61 :=
  .inr ⟨16503, rfl, Nat.le_of_ble_eq_true PRE_first_tail_x15_r0_body.craise61, rfl⟩
noncomputable abbrev PRE_first_tail_x15_r0_body.cx0_61 : Host.Load.LSt := clearTokens (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s601.ffi)
noncomputable abbrev PRE_first_tail_x15_r0_body.cx1_61 : Host.Load.LSt := clearTokens (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s600.ffi)
def PRE_first_tail_x15_r0_body.khinv61 : PTrie Nat := Stage.setAll PTrie.nil []
def PRE_first_tail_x15_r0_body.kninv61 : PTrie Nat := Stage.setAll PTrie.nil []
/-- The stage's footprint: its written and fresh handles, fresh nodes, written and fresh items. -/
def PRE_first_tail_x15_r0_body.cwS61 : List Nat := []
def PRE_first_tail_x15_r0_body.cnS61 : List Nat := List.range' 16503 0
def PRE_first_tail_x15_r0_body.ciS61 : List Nat := [] ++ List.range' 16503 0

-- the small checks (`MChecks`'s)
kernel_rfl PRE_first_tail_x15_r0_body.cnh061 : PRE_first_tail_x15_r0_body.kd61.nh0 = PRE_first_tail_x15_r0_body.cx0_61.mlx.next
kernel_rfl PRE_first_tail_x15_r0_body.cnh161 : PRE_first_tail_x15_r0_body.kd61.nh1 = PRE_first_tail_x15_r0_body.cx1_61.mlx.next
kernel_rfl PRE_first_tail_x15_r0_body.cnn061 : PRE_first_tail_x15_r0_body.kd61.nn0 = PRE_first_tail_x15_r0_body.cx0_61.mlx.nnext
kernel_rfl PRE_first_tail_x15_r0_body.cnn161 : PRE_first_tail_x15_r0_body.kd61.nn1 = PRE_first_tail_x15_r0_body.cx1_61.mlx.nnext
kernel_rfl PRE_first_tail_x15_r0_body.cplo61 : (Nat.blt 0 PRE_first_tail_x15_r0_body.P61.lo && Nat.ble PRE_first_tail_x15_r0_body.P61.lo PRE_first_tail_x15_r0_body.cx0_61.mlx.next && Nat.ble PRE_first_tail_x15_r0_body.P61.lo RData.bigHi && Nat.ble RData.bigHi PRE_first_tail_x15_r0_body.P61.E) = true
kernel_rfl PRE_first_tail_x15_r0_body.ccnt61 : (Nat.ble PRE_first_tail_x15_r0_body.cx0_61.mlx.next PRE_first_tail_x15_r0_body.cx1_61.mlx.next && Nat.ble PRE_first_tail_x15_r0_body.cx0_61.mlx.nnext PRE_first_tail_x15_r0_body.cx1_61.mlx.nnext) = true
kernel_rfl PRE_first_tail_x15_r0_body.cnband61 : (Nat.blt 0 PRE_first_tail_x15_r0_body.P61.NL && Nat.ble PRE_first_tail_x15_r0_body.P61.NL PRE_first_tail_x15_r0_body.P61.N0 && Nat.ble PRE_first_tail_x15_r0_body.P61.N0 PRE_first_tail_x15_r0_body.cx0_61.mlx.nnext) = true
kernel_rfl PRE_first_tail_x15_r0_body.chbelow61 : PRE_first_tail_x15_r0_body.kd61.checkHndBelow = true
kernel_rfl PRE_first_tail_x15_r0_body.chren61 : checkRenG PRE_first_tail_x15_r0_body.kd61.hnd PRE_first_tail_x15_r0_body.khinv61 (phB PRE_first_tail_x15_r0_body.cx0_61.mlx) = true
kernel_rfl PRE_first_tail_x15_r0_body.cband61 : PRE_first_tail_x15_r0_body.kd61.checkBand PRE_first_tail_x15_r0_body.P61.lo = true
kernel_rfl PRE_first_tail_x15_r0_body.cnh1pos61 : Nat.blt 0 PRE_first_tail_x15_r0_body.kd61.nh1 = true
kernel_rfl PRE_first_tail_x15_r0_body.cnren61 : checkRenG PRE_first_tail_x15_r0_body.kd61.node PRE_first_tail_x15_r0_body.kninv61 (pnB PRE_first_tail_x15_r0_body.cx0_61.mlx) = true
kernel_rfl PRE_first_tail_x15_r0_body.cnlow61 : (PTrie.keysA PRE_first_tail_x15_r0_body.kd61.node).all (fun j => Nat.ble PRE_first_tail_x15_r0_body.P61.NL j && Nat.blt (PRE_first_tail_x15_r0_body.kd61.nodeF j) PRE_first_tail_x15_r0_body.cx1_61.mlx.nnext) = true
kernel_rfl PRE_first_tail_x15_r0_body.cabs0a61 : PRE_first_tail_x15_r0_body.cx0_61.mlx.arrs.get 0 = none
kernel_rfl PRE_first_tail_x15_r0_body.cabs0b61 : PRE_first_tail_x15_r0_body.cx0_61.mlx.objs.get 0 = none
kernel_rfl PRE_first_tail_x15_r0_body.ctok161 : PRE_first_tail_x15_r0_body.cx1_61.mlx.tokens = []
kernel_rfl PRE_first_tail_x15_r0_body.cpend61 : PRE_first_tail_x15_r0_body.cx1_61.mlx.pending = PRE_first_tail_x15_r0_body.cx0_61.mlx.pending.map PRE_first_tail_x15_r0_body.kappa61.pend
kernel_rfl PRE_first_tail_x15_r0_body.cerrh61 : PRE_first_tail_x15_r0_body.cx1_61.mlx.errh = PRE_first_tail_x15_r0_body.cx0_61.mlx.errh.map PRE_first_tail_x15_r0_body.kappa61.arg
kernel_rfl PRE_first_tail_x15_r0_body.cfiles61 : PRE_first_tail_x15_r0_body.cx1_61.mlx.files = PRE_first_tail_x15_r0_body.cx0_61.mlx.files
kernel_rfl PRE_first_tail_x15_r0_body.carch61 : PRE_first_tail_x15_r0_body.cx1_61.mlx.arch = PRE_first_tail_x15_r0_body.cx0_61.mlx.arch
kernel_rfl PRE_first_tail_x15_r0_body.csizes61 : PRE_first_tail_x15_r0_body.cx1_61.mlx.deviceSizes = PRE_first_tail_x15_r0_body.cx0_61.mlx.deviceSizes
kernel_rfl PRE_first_tail_x15_r0_body.cwired61 : PRE_first_tail_x15_r0_body.cx1_61.mlx.wired = PRE_first_tail_x15_r0_body.cx0_61.mlx.wired
kernel_rfl PRE_first_tail_x15_r0_body.chost61 : PRE_first_tail_x15_r0_body.cx1_61.host = PRE_first_tail_x15_r0_body.cx0_61.host
-- the compaction map's addresses are `PRE_first_tail_x15_r0_body.kd61`'s
kernel_rfl PRE_first_tail_x15_r0_body.ckn061 : PRE_first_tail_x15_r0_body.kd61.n0 = 2723043
kernel_rfl PRE_first_tail_x15_r0_body.ckn161 : PRE_first_tail_x15_r0_body.kd61.n1 = 2723045
kernel_rfl PRE_first_tail_x15_r0_body.ckheap61 : (PTrie.keysA PRE_first_tail_x15_r0_body.kd61.heap).all (fun x => Nat.ble 2723043 x) = true
kernel_rfl PRE_first_tail_x15_r0_body.ckpl61 : (List.range 0).all (fun j => decide (PRE_first_tail_x15_r0_body.kd61.heap.get (2723043 + j) = nth? PRE_first_tail_x15_r0_body.pl61 j)) = true
-- the map fixes the call's names (`Conv.fixOld_compact`), the call's counters
kernel_rfl PRE_first_tail_x15_r0_body.fja61 : Nat.ble 2723043 2723043 = true
kernel_rfl PRE_first_tail_x15_r0_body.fn61 : Nat.ble 2687 2687 = true
kernel_rfl PRE_first_tail_x15_r0_body.fjaD61 : Nat.ble 2723043 PRE_first_tail_x15_r0_body.kd61.n0 = true
kernel_rfl PRE_first_tail_x15_r0_body.fxn61 : Nat.ble 19412 PRE_first_tail_x15_r0_body.kd61.nh0 = true
kernel_rfl PRE_first_tail_x15_r0_body.fnn61 : Nat.ble 16503 PRE_first_tail_x15_r0_body.kd61.nn0 = true
kernel_rfl PRE_first_tail_x15_r0_body.fxb61 : Nat.ble 19412 RData.bigHi = true
kernel_rfl PRE_first_tail_x15_r0_body.fheap61 : (PTrie.keysA PRE_first_tail_x15_r0_body.kd61.heap).all (Nat.ble (⟨19412, 16503, 2723043, 2687⟩ : Conv.Cnt).ja) = true
kernel_rfl PRE_first_tail_x15_r0_body.fhnd61 : (PTrie.keysA PRE_first_tail_x15_r0_body.kd61.hnd).all (Nat.ble (⟨19412, 16503, 2723043, 2687⟩ : Conv.Cnt).xn) = true
kernel_rfl PRE_first_tail_x15_r0_body.fnode61 : (PTrie.keysA PRE_first_tail_x15_r0_body.kd61.node).all (Nat.ble (⟨19412, 16503, 2723043, 2687⟩ : Conv.Cnt).nn) = true
/-- The compaction map fixes the call's names. -/
theorem PRE_first_tail_x15_r0_body.cfix61 : Conv.FixOld (⟨19412, 16503, 2723043, 2687⟩ : Conv.Cnt) PRE_first_tail_x15_r0_body.kappa61 :=
  Conv.fixOld_compact (Nat.le_of_ble_eq_true PRE_first_tail_x15_r0_body.fja61) (Nat.le_of_ble_eq_true PRE_first_tail_x15_r0_body.fn61) (Nat.le_of_ble_eq_true PRE_first_tail_x15_r0_body.fjaD61) (Nat.le_of_ble_eq_true PRE_first_tail_x15_r0_body.fxn61) (Nat.le_of_ble_eq_true PRE_first_tail_x15_r0_body.fnn61) (Nat.le_of_ble_eq_true PRE_first_tail_x15_r0_body.fxb61) PRE_first_tail_x15_r0_body.fheap61 PRE_first_tail_x15_r0_body.fhnd61 PRE_first_tail_x15_r0_body.fnode61
kernel_rfl PRE_first_tail_x15_r0_body.fcxn61 : (⟨19412, 16503, 2723043, 2687⟩ : Conv.Cnt).xn = (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s599.ffi).mlx.next
kernel_rfl PRE_first_tail_x15_r0_body.fcnn61 : (⟨19412, 16503, 2723043, 2687⟩ : Conv.Cnt).nn = (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s599.ffi).mlx.nnext
kernel_rfl PRE_first_tail_x15_r0_body.fle061 : (Nat.ble (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s599.ffi).mlx.next PRE_first_tail_x15_r0_body.cx0_61.mlx.next && Nat.ble (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s599.ffi).mlx.nnext PRE_first_tail_x15_r0_body.cx0_61.mlx.nnext && Nat.ble (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s599.ffi).mlx.next RData.bigHi) = true
kernel_rfl PRE_first_tail_x15_r0_body.fnk61 : (PTrie.keysA PRE_first_tail_x15_r0_body.kd61.node).all (Nat.ble (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s599.ffi).mlx.nnext) = true
-- the merged state keeps the call's entries off the stage's footprint
kernel_rfl PRE_first_tail_x15_r0_body.f1A61 : PRE_first_tail_x15_r0_body.cx1_61.mlx.arrs = Stage.setAll (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s599.ffi).mlx.arrs (PRE_first_tail_x15_r0_body.cwS61.filterMap fun i => (PRE_first_tail_x15_r0_body.cx1_61.mlx.arrs.get i).map (i, ·))
kernel_rfl PRE_first_tail_x15_r0_body.f1O61 : PRE_first_tail_x15_r0_body.cx1_61.mlx.objs = Stage.setAll (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s599.ffi).mlx.objs (PRE_first_tail_x15_r0_body.cwS61.filterMap fun i => (PRE_first_tail_x15_r0_body.cx1_61.mlx.objs.get i).map (i, ·))
kernel_rfl PRE_first_tail_x15_r0_body.f1N61 : PRE_first_tail_x15_r0_body.cx1_61.mlx.nodes = Stage.setAll (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s599.ffi).mlx.nodes (PRE_first_tail_x15_r0_body.cnS61.filterMap fun i => (PRE_first_tail_x15_r0_body.cx1_61.mlx.nodes.get i).map (i, ·))
kernel_rfl PRE_first_tail_x15_r0_body.f1I61 : PRE_first_tail_x15_r0_body.cx1_61.mlx.items = Stage.setAll (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s599.ffi).mlx.items (PRE_first_tail_x15_r0_body.ciS61.filterMap fun i => (PRE_first_tail_x15_r0_body.cx1_61.mlx.items.get i).map (i, ·))
kernel_rfl PRE_first_tail_x15_r0_body.fbd61 : (PRE_first_tail_x15_r0_body.clo61 ++ PRE_first_tail_x15_r0_body.cln61 ++ PRE_first_tail_x15_r0_body.cli61 ++ PRE_first_tail_x15_r0_body.cwS61 ++ PRE_first_tail_x15_r0_body.cnS61 ++ PRE_first_tail_x15_r0_body.ciS61).all (fun i => Nat.blt (i / 4096) (4 ^ 31)) = true
kernel_rfl PRE_first_tail_x15_r0_body.fincW61 : PRE_first_tail_x15_r0_body.cwS61.all (fun h => !Nat.blt h (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s599.ffi).mlx.next || PRE_first_tail_x15_r0_body.clo61.contains h) = true
kernel_rfl PRE_first_tail_x15_r0_body.fincI61 : PRE_first_tail_x15_r0_body.ciS61.all (fun k => !Nat.blt k (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s599.ffi).mlx.nnext || PRE_first_tail_x15_r0_body.cli61.contains k) = true
kernel_rfl PRE_first_tail_x15_r0_body.fincN61 : PRE_first_tail_x15_r0_body.cnS61.all (Nat.ble (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s599.ffi).mlx.nnext) = true
kernel_rfl PRE_first_tail_x15_r0_body.flnF61 : PRE_first_tail_x15_r0_body.cln61.all (Nat.ble (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s599.ffi).mlx.nnext) = true
-- the checks over the changed lists
kernel_rfl PRE_first_tail_x15_r0_body.fh61 : PRE_first_tail_x15_r0_body.clo61.all (handleOK PRE_first_tail_x15_r0_body.kappa61 PRE_first_tail_x15_r0_body.P61.lo PRE_first_tail_x15_r0_body.cx0_61.mlx PRE_first_tail_x15_r0_body.cx1_61.mlx) = true
kernel_rfl PRE_first_tail_x15_r0_body.fo61 : PRE_first_tail_x15_r0_body.clo61.map (fun h => PRE_first_tail_x15_r0_body.cx1_61.mlx.objs.get (PRE_first_tail_x15_r0_body.kappa61.handle h)) = PRE_first_tail_x15_r0_body.clo61.map (fun h => (PRE_first_tail_x15_r0_body.cx0_61.mlx.objs.get h).map PRE_first_tail_x15_r0_body.kappa61.nobj)
kernel_rfl PRE_first_tail_x15_r0_body.fok61 : PRE_first_tail_x15_r0_body.clo61.all (objOK PRE_first_tail_x15_r0_body.kappa61 PRE_first_tail_x15_r0_body.P61.NL PRE_first_tail_x15_r0_body.cx0_61.mlx) = true
kernel_rfl PRE_first_tail_x15_r0_body.fnd61 : PRE_first_tail_x15_r0_body.cln61.all (nodeOKF PRE_first_tail_x15_r0_body.kappa61 PRE_first_tail_x15_r0_body.P61 PRE_first_tail_x15_r0_body.cx0_61.mlx PRE_first_tail_x15_r0_body.cx1_61.mlx) = true
kernel_rfl PRE_first_tail_x15_r0_body.fp61 : ((PRE_first_tail_x15_r0_body.cln61.filter (fullB PRE_first_tail_x15_r0_body.P61))).map (fun i => (PRE_first_tail_x15_r0_body.cx1_61.mlx.nodes.get (PRE_first_tail_x15_r0_body.kappa61.node i)).map Host.Mlx.Ffi.Node.prim) =
  ((PRE_first_tail_x15_r0_body.cln61.filter (fullB PRE_first_tail_x15_r0_body.P61))).map (fun i => (PRE_first_tail_x15_r0_body.cx0_61.mlx.nodes.get i).map fun nd => PRE_first_tail_x15_r0_body.kappa61.prim nd.prim)
kernel_rfl PRE_first_tail_x15_r0_body.fnordI61 : incrB PRE_first_tail_x15_r0_body.kd61.nodeF (List.range' 16503 0) = true
kernel_rfl PRE_first_tail_x15_r0_body.fnordK61 : (PTrie.keysA PRE_first_tail_x15_r0_body.kd61.node).all (fun k => Nat.ble 16503 k && Nat.blt k 16503) = true
kernel_rfl PRE_first_tail_x15_r0_body.fnordL61 : (PRE_first_tail_x15_r0_body.cln61.filter (Nat.ble PRE_first_tail_x15_r0_body.P61.N0)).all (fun i => Nat.ble i (PRE_first_tail_x15_r0_body.kd61.nodeF i) && (Nat.blt i 16503 || Nat.ble PRE_first_tail_x15_r0_body.kd61.nn0 i)) = true
theorem PRE_first_tail_x15_r0_body.fnord61 : (PRE_first_tail_x15_r0_body.cln61.filter (Nat.ble PRE_first_tail_x15_r0_body.P61.N0)).all (fun i => Nat.ble i (PRE_first_tail_x15_r0_body.kd61.nodeF i) &&
    (PTrie.keysA PRE_first_tail_x15_r0_body.kd61.node).all fun j => !Nat.blt j i || Nat.blt (PRE_first_tail_x15_r0_body.kd61.nodeF j) (PRE_first_tail_x15_r0_body.kd61.nodeF i)) = true :=
  cnord_of PRE_first_tail_x15_r0_body.cnlow61 PRE_first_tail_x15_r0_body.cnn161 PRE_first_tail_x15_r0_body.fnordI61 PRE_first_tail_x15_r0_body.fnordK61 PRE_first_tail_x15_r0_body.fnordL61
kernel_rfl PRE_first_tail_x15_r0_body.fi61 : PRE_first_tail_x15_r0_body.cli61.all (pnB PRE_first_tail_x15_r0_body.cx0_61.mlx) = true
kernel_rfl PRE_first_tail_x15_r0_body.fii61 : PRE_first_tail_x15_r0_body.cli61.all (fun k => decide (PRE_first_tail_x15_r0_body.cx1_61.mlx.items.get (PRE_first_tail_x15_r0_body.kappa61.node k) = (PRE_first_tail_x15_r0_body.cx0_61.mlx.items.get k).map PRE_first_tail_x15_r0_body.kappa61.nv)) = true
/-- **The compaction's footprint.** -/
theorem PRE_first_tail_x15_r0_body.cfoot61 (clean : Conv.NClean (⟨19412, 16503, 2723043, 2687⟩ : Conv.Cnt) (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s599.ffi).mlx) (hltC : ∀ h, PH (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s599.ffi).mlx h → h < (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s599.ffi).mlx.next) (nltC : ∀ i, PN (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s599.ffi).mlx i → i < (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s599.ffi).mlx.nnext) (itemsC : ∀ k v, (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s599.ffi).mlx.items.get k = some v → PN (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s599.ffi).mlx k) (tracedC : ∀ h o, (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s599.ffi).mlx.objs.get h = some o → ∀ i ∈ objTraces o, i < PRE_first_tail_x15_r0_body.P61.NL) (cl : SSt (· < 2687) PRE_first_tail_x15_r0_body.cx0_61.mlx) :
    Conv.MFoot PRE_first_tail_x15_r0_body.P61 2687 PRE_first_tail_x15_r0_body.kappa61 PRE_first_tail_x15_r0_body.kd61 PRE_first_tail_x15_r0_body.khinv61 PRE_first_tail_x15_r0_body.kninv61 (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s599.ffi).mlx PRE_first_tail_x15_r0_body.cx0_61.mlx PRE_first_tail_x15_r0_body.cx1_61.mlx (⟨19412, 16503, 2723043, 2687⟩ : Conv.Cnt) PRE_first_tail_x15_r0_body.clo61 PRE_first_tail_x15_r0_body.cln61 PRE_first_tail_x15_r0_body.cli61 PRE_first_tail_x15_r0_body.cwS61 PRE_first_tail_x15_r0_body.cnS61 PRE_first_tail_x15_r0_body.ciS61 :=
  ⟨rfl, rfl, rfl, PRE_first_tail_x15_r0_body.cnh061, PRE_first_tail_x15_r0_body.cnh161, PRE_first_tail_x15_r0_body.cnn061, PRE_first_tail_x15_r0_body.cnn161, PRE_first_tail_x15_r0_body.cplo61, PRE_first_tail_x15_r0_body.ccnt61, PRE_first_tail_x15_r0_body.cnband61, PRE_first_tail_x15_r0_body.chbelow61, PRE_first_tail_x15_r0_body.chren61, PRE_first_tail_x15_r0_body.cband61, PRE_first_tail_x15_r0_body.cnh1pos61, PRE_first_tail_x15_r0_body.cnren61, PRE_first_tail_x15_r0_body.cnlow61, PRE_first_tail_x15_r0_body.cabs0a61, PRE_first_tail_x15_r0_body.cabs0b61, PRE_first_tail_x15_r0_body.ctok161, PRE_first_tail_x15_r0_body.cpend61, PRE_first_tail_x15_r0_body.cerrh61, PRE_first_tail_x15_r0_body.cfiles61, PRE_first_tail_x15_r0_body.carch61, PRE_first_tail_x15_r0_body.csizes61, PRE_first_tail_x15_r0_body.cwired61, PRE_first_tail_x15_r0_body.cfix61, clean, PRE_first_tail_x15_r0_body.fcxn61, PRE_first_tail_x15_r0_body.fcnn61, hltC, nltC, itemsC, tracedC, cl, PRE_first_tail_x15_r0_body.fle061, PRE_first_tail_x15_r0_body.fnk61, PRE_first_tail_x15_r0_body.ckA61, PRE_first_tail_x15_r0_body.cobjsK61, PRE_first_tail_x15_r0_body.cnodesK61, PRE_first_tail_x15_r0_body.citemsK61, PRE_first_tail_x15_r0_body.f1A61, PRE_first_tail_x15_r0_body.f1O61, PRE_first_tail_x15_r0_body.f1N61, PRE_first_tail_x15_r0_body.f1I61, PRE_first_tail_x15_r0_body.fbd61, PRE_first_tail_x15_r0_body.fincW61, PRE_first_tail_x15_r0_body.fincI61, PRE_first_tail_x15_r0_body.fincN61, PRE_first_tail_x15_r0_body.flnF61, PRE_first_tail_x15_r0_body.fh61, PRE_first_tail_x15_r0_body.fo61, PRE_first_tail_x15_r0_body.fok61, PRE_first_tail_x15_r0_body.fnd61, PRE_first_tail_x15_r0_body.fp61, PRE_first_tail_x15_r0_body.fnord61, PRE_first_tail_x15_r0_body.fi61, PRE_first_tail_x15_r0_body.fii61⟩
theorem PRE_first_tail_x15_r0_body.cnshift61 (clean : Conv.NClean (⟨19412, 16503, 2723043, 2687⟩ : Conv.Cnt) (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s599.ffi).mlx) (hltC : ∀ h, PH (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s599.ffi).mlx h → h < (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s599.ffi).mlx.next) (nltC : ∀ i, PN (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s599.ffi).mlx i → i < (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s599.ffi).mlx.nnext) (itemsC : ∀ k v, (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s599.ffi).mlx.items.get k = some v → PN (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s599.ffi).mlx k) (tracedC : ∀ h o, (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s599.ffi).mlx.objs.get h = some o → ∀ i ∈ objTraces o, i < PRE_first_tail_x15_r0_body.P61.NL) (cl : SSt (· < 2687) PRE_first_tail_x15_r0_body.cx0_61.mlx) : NShift PRE_first_tail_x15_r0_body.P61 2687 PRE_first_tail_x15_r0_body.kappa61 PRE_first_tail_x15_r0_body.cx0_61 PRE_first_tail_x15_r0_body.cx1_61 :=
  Conv.nshift_of_foot (PRE_first_tail_x15_r0_body.cfoot61 clean hltC nltC itemsC tracedC cl) PRE_first_tail_x15_r0_body.chost61 (compact_a_eq PRE_first_tail_x15_r0_body.ckn061 PRE_first_tail_x15_r0_body.ckn161 PRE_first_tail_x15_r0_body.ckheap61 PRE_first_tail_x15_r0_body.ckpl61)

-- the observers: the layers' states at the call, the canonical and the merged state, their footprints and checks
noncomputable def PRE_first_tail_x15_r0_body.fxC_61 : PTrie Unit := (Host.Ts.Sim.Full.freedOf PRE_first_tail_x15_r0_body.s599.ffi).getD PTrie.nil
noncomputable def PRE_first_tail_x15_r0_body.krC_61 : Host.Load.Layers.KRec := (Host.Ts.Sim.Full.krecOf PRE_first_tail_x15_r0_body.s599.ffi).getD Host.Load.Layers.KRec.empty
kernel_rfl PRE_first_tail_x15_r0_body.ofxC_61 : (Host.Ts.Sim.Full.freedOf PRE_first_tail_x15_r0_body.s599.ffi) = some PRE_first_tail_x15_r0_body.fxC_61
kernel_rfl PRE_first_tail_x15_r0_body.okrC_61 : (Host.Ts.Sim.Full.krecOf PRE_first_tail_x15_r0_body.s599.ffi) = some PRE_first_tail_x15_r0_body.krC_61
noncomputable def PRE_first_tail_x15_r0_body.fx0_61 : PTrie Unit := (Host.Ts.Sim.Full.freedOf PRE_first_tail_x15_r0_body.s601.ffi).getD PTrie.nil
noncomputable def PRE_first_tail_x15_r0_body.kr0_61 : Host.Load.Layers.KRec := (Host.Ts.Sim.Full.krecOf PRE_first_tail_x15_r0_body.s601.ffi).getD Host.Load.Layers.KRec.empty
kernel_rfl PRE_first_tail_x15_r0_body.ofx0_61 : (Host.Ts.Sim.Full.freedOf PRE_first_tail_x15_r0_body.s601.ffi) = some PRE_first_tail_x15_r0_body.fx0_61
kernel_rfl PRE_first_tail_x15_r0_body.okr0_61 : (Host.Ts.Sim.Full.krecOf PRE_first_tail_x15_r0_body.s601.ffi) = some PRE_first_tail_x15_r0_body.kr0_61
noncomputable def PRE_first_tail_x15_r0_body.fx1_61 : PTrie Unit := (Host.Ts.Sim.Full.freedOf PRE_first_tail_x15_r0_body.s600.ffi).getD PTrie.nil
noncomputable def PRE_first_tail_x15_r0_body.kr1_61 : Host.Load.Layers.KRec := (Host.Ts.Sim.Full.krecOf PRE_first_tail_x15_r0_body.s600.ffi).getD Host.Load.Layers.KRec.empty
kernel_rfl PRE_first_tail_x15_r0_body.ofx1_61 : (Host.Ts.Sim.Full.freedOf PRE_first_tail_x15_r0_body.s600.ffi) = some PRE_first_tail_x15_r0_body.fx1_61
kernel_rfl PRE_first_tail_x15_r0_body.okr1_61 : (Host.Ts.Sim.Full.krecOf PRE_first_tail_x15_r0_body.s600.ffi) = some PRE_first_tail_x15_r0_body.kr1_61
kernel_rfl PRE_first_tail_x15_r0_body.ff061 : PRE_first_tail_x15_r0_body.fx0_61 = Stage.setAll PRE_first_tail_x15_r0_body.fxC_61 (PRE_first_tail_x15_r0_body.clo61.filterMap fun i => (PRE_first_tail_x15_r0_body.fx0_61.get i).map (i, ·))
kernel_rfl PRE_first_tail_x15_r0_body.ff161 : PRE_first_tail_x15_r0_body.fx1_61 = Stage.setAll PRE_first_tail_x15_r0_body.fxC_61 (PRE_first_tail_x15_r0_body.cwS61.filterMap fun i => (PRE_first_tail_x15_r0_body.fx1_61.get i).map (i, ·))
kernel_rfl PRE_first_tail_x15_r0_body.ffck61 : freedLB PRE_first_tail_x15_r0_body.kappa61 PRE_first_tail_x15_r0_body.cx0_61.mlx PRE_first_tail_x15_r0_body.fx0_61 PRE_first_tail_x15_r0_body.fx1_61 PRE_first_tail_x15_r0_body.clo61 = true
kernel_rfl PRE_first_tail_x15_r0_body.fkf061 : PRE_first_tail_x15_r0_body.kr0_61.flags = Stage.setAll PRE_first_tail_x15_r0_body.krC_61.flags (PRE_first_tail_x15_r0_body.clo61.filterMap fun i => (PRE_first_tail_x15_r0_body.kr0_61.flags.get i).map (i, ·))
kernel_rfl PRE_first_tail_x15_r0_body.fkt061 : PRE_first_tail_x15_r0_body.kr0_61.targs = Stage.setAll PRE_first_tail_x15_r0_body.krC_61.targs (PRE_first_tail_x15_r0_body.clo61.filterMap fun i => (PRE_first_tail_x15_r0_body.kr0_61.targs.get i).map (i, ·))
kernel_rfl PRE_first_tail_x15_r0_body.fkf161 : PRE_first_tail_x15_r0_body.kr1_61.flags = Stage.setAll PRE_first_tail_x15_r0_body.krC_61.flags (PRE_first_tail_x15_r0_body.cwS61.filterMap fun i => (PRE_first_tail_x15_r0_body.kr1_61.flags.get i).map (i, ·))
kernel_rfl PRE_first_tail_x15_r0_body.fkt161 : PRE_first_tail_x15_r0_body.kr1_61.targs = Stage.setAll PRE_first_tail_x15_r0_body.krC_61.targs (PRE_first_tail_x15_r0_body.cwS61.filterMap fun i => (PRE_first_tail_x15_r0_body.kr1_61.targs.get i).map (i, ·))
kernel_rfl PRE_first_tail_x15_r0_body.fkck61 : krecLB PRE_first_tail_x15_r0_body.kappa61 2687 PRE_first_tail_x15_r0_body.cx0_61.mlx PRE_first_tail_x15_r0_body.kr0_61 PRE_first_tail_x15_r0_body.kr1_61 PRE_first_tail_x15_r0_body.clo61 = true
kernel_rfl PRE_first_tail_x15_r0_body.fkn61 : Nat.ble 2687 2687 = true
-- the bridge and the pending traces' regions
kernel_rfl PRE_first_tail_x15_r0_body.cbridge61 : Host.Ts.Sim.Full.bridgeOf PRE_first_tail_x15_r0_body.s600.ffi = Host.Ts.Sim.Full.bridgeOf PRE_first_tail_x15_r0_body.s601.ffi
kernel_rfl PRE_first_tail_x15_r0_body.cpendR61 : pendRegB PRE_first_tail_x15_r0_body.kappa61 (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s601.ffi).mlx = true
kernel_rfl PRE_first_tail_x15_r0_body.cpendLe61 : Nat.ble (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s601.ffi).mlx.next (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s600.ffi).mlx.next = true
/-- **The compaction's native shift**, given the call's bookkeeping, its relation's facts (the model's and the
observers') and the canonical closedness. -/
theorem PRE_first_tail_x15_r0_body.cshift61 (clean : Conv.NClean (⟨19412, 16503, 2723043, 2687⟩ : Conv.Cnt) (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s599.ffi).mlx) (hltC : ∀ h, PH (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s599.ffi).mlx h → h < (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s599.ffi).mlx.next) (nltC : ∀ i, PN (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s599.ffi).mlx i → i < (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s599.ffi).mlx.nnext) (itemsC : ∀ k v, (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s599.ffi).mlx.items.get k = some v → PN (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s599.ffi).mlx k) (tracedC : ∀ h o, (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s599.ffi).mlx.objs.get h = some o → ∀ i ∈ objTraces o, i < PRE_first_tail_x15_r0_body.P61.NL) (cl : SSt (· < 2687) PRE_first_tail_x15_r0_body.cx0_61.mlx)
    (hobjC : ∀ h, PRE_first_tail_x15_r0_body.fxC_61.get h = some () → ((Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s599.ffi).mlx.objs.get h).isSome = true)
    (hfC : ∀ h, (PRE_first_tail_x15_r0_body.krC_61.flags.get h).isSome = true → ((Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s599.ffi).mlx.objs.get h).isSome = true)
    (htC : ∀ h, (PRE_first_tail_x15_r0_body.krC_61.targs.get h).isSome = true → ((Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s599.ffi).mlx.objs.get h).isSome = true)
    (hclC : ∀ h l, PRE_first_tail_x15_r0_body.krC_61.targs.get h = some l → Host.Ts.Sim.Full.STargs (· < (⟨19412, 16503, 2723043, 2687⟩ : Conv.Cnt).n) l) :
    Conv.FullShiftQ PRE_first_tail_x15_r0_body.P61 2687 PRE_first_tail_x15_r0_body.kappa61 PRE_first_tail_x15_r0_body.s601.ffi PRE_first_tail_x15_r0_body.s600.ffi :=
  ⟨PRE_first_tail_x15_r0_body.cnshift61 clean hltC nltC itemsC tracedC cl, PRE_first_tail_x15_r0_body.cqueue61, fun t ht => bSN_sound (List.all_eq_true.mp PRE_first_tail_x15_r0_body.ctokSupp61 t ht),
    PRE_first_tail_x15_r0_body.cbridge61,
    liveShift_foot (x0' := Host.Ts.Sim.Full.mlxOf PRE_first_tail_x15_r0_body.s601.ffi) (x1' := Host.Ts.Sim.Full.mlxOf PRE_first_tail_x15_r0_body.s600.ffi) (PRE_first_tail_x15_r0_body.cfoot61 clean hltC nltC itemsC tracedC cl) rfl PRE_first_tail_x15_r0_body.ofx0_61 PRE_first_tail_x15_r0_body.ofx1_61 hobjC PRE_first_tail_x15_r0_body.ff061 PRE_first_tail_x15_r0_body.ff161 PRE_first_tail_x15_r0_body.ffck61,
    kernShift_foot (x0' := Host.Ts.Sim.Full.mlxOf PRE_first_tail_x15_r0_body.s601.ffi) (x1' := Host.Ts.Sim.Full.mlxOf PRE_first_tail_x15_r0_body.s600.ffi) (PRE_first_tail_x15_r0_body.cfoot61 clean hltC nltC itemsC tracedC cl) rfl PRE_first_tail_x15_r0_body.okr0_61 PRE_first_tail_x15_r0_body.okr1_61 (Nat.le_of_ble_eq_true PRE_first_tail_x15_r0_body.fkn61) hfC htC hclC
      PRE_first_tail_x15_r0_body.fkf061 PRE_first_tail_x15_r0_body.fkt061 PRE_first_tail_x15_r0_body.fkf161 PRE_first_tail_x15_r0_body.fkt161 PRE_first_tail_x15_r0_body.fkck61,
    pendReg_of rfl PRE_first_tail_x15_r0_body.cnh061 PRE_first_tail_x15_r0_body.cnh161 (Nat.le_of_ble_eq_true PRE_first_tail_x15_r0_body.cpendLe61) PRE_first_tail_x15_r0_body.cpendR61⟩

end Host.Load.Run.Tpl
