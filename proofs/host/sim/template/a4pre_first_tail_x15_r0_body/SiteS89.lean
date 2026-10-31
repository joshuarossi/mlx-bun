import host.sim.template.a4pre_first_tail_x15_r0_body.SiteCl89
import host.sim.conv.CompactFull
import host.sim.template.FootGen
set_option Elab.async false
namespace Host.Load.Run.Tpl
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
open Host.Ts Host.Ts.Sim Host.Ts.Sim.Template

/-! The compaction's native shift at call site 89 from its footprint (`Conv.nshift_of_foot`), and the observers'
(`liveShift_foot`, `kernShift_foot`): `Conv.FullShiftQ` for `Conv.full_compactQ`, given the call's bookkeeping and its
relation's facts. -/

/-- The load parameters of the chain (band-free: its start's node counter as `NL` and `N0`). -/
def PRE_first_tail_x15_r0_body.Pc89 : LoadP := ⟨18151, 131072, 1099511627776, 15235, 15235, []⟩
/-- The site's band raised to the map's checked fixed-node prefix, including newly recorded closure traces. -/
def PRE_first_tail_x15_r0_body.P89 : LoadP := PRE_first_tail_x15_r0_body.Pc89.raise 17044
kernel_rfl PRE_first_tail_x15_r0_body.craise89 : Nat.ble PRE_first_tail_x15_r0_body.Pc89.N0 17044 = true
theorem PRE_first_tail_x15_r0_body.raised89 : Host.Ts.Sim.Full.Raised PRE_first_tail_x15_r0_body.Pc89 PRE_first_tail_x15_r0_body.P89 :=
  .inr ⟨17044, rfl, Nat.le_of_ble_eq_true PRE_first_tail_x15_r0_body.craise89, rfl⟩
noncomputable abbrev PRE_first_tail_x15_r0_body.cx0_89 : Host.Load.LSt := clearTokens (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s864.ffi)
noncomputable abbrev PRE_first_tail_x15_r0_body.cx1_89 : Host.Load.LSt := clearTokens (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s863.ffi)
def PRE_first_tail_x15_r0_body.khinv89 : PTrie Nat := Stage.setAll PTrie.nil []
def PRE_first_tail_x15_r0_body.kninv89 : PTrie Nat := Stage.setAll PTrie.nil []
/-- The stage's footprint: its written and fresh handles, fresh nodes, written and fresh items. -/
def PRE_first_tail_x15_r0_body.cwS89 : List Nat := []
def PRE_first_tail_x15_r0_body.cnS89 : List Nat := List.range' 17044 0
def PRE_first_tail_x15_r0_body.ciS89 : List Nat := [] ++ List.range' 17044 0

-- the small checks (`MChecks`'s)
kernel_rfl PRE_first_tail_x15_r0_body.cnh089 : PRE_first_tail_x15_r0_body.kd89.nh0 = PRE_first_tail_x15_r0_body.cx0_89.mlx.next
kernel_rfl PRE_first_tail_x15_r0_body.cnh189 : PRE_first_tail_x15_r0_body.kd89.nh1 = PRE_first_tail_x15_r0_body.cx1_89.mlx.next
kernel_rfl PRE_first_tail_x15_r0_body.cnn089 : PRE_first_tail_x15_r0_body.kd89.nn0 = PRE_first_tail_x15_r0_body.cx0_89.mlx.nnext
kernel_rfl PRE_first_tail_x15_r0_body.cnn189 : PRE_first_tail_x15_r0_body.kd89.nn1 = PRE_first_tail_x15_r0_body.cx1_89.mlx.nnext
kernel_rfl PRE_first_tail_x15_r0_body.cplo89 : (Nat.blt 0 PRE_first_tail_x15_r0_body.P89.lo && Nat.ble PRE_first_tail_x15_r0_body.P89.lo PRE_first_tail_x15_r0_body.cx0_89.mlx.next && Nat.ble PRE_first_tail_x15_r0_body.P89.lo RData.bigHi && Nat.ble RData.bigHi PRE_first_tail_x15_r0_body.P89.E) = true
kernel_rfl PRE_first_tail_x15_r0_body.ccnt89 : (Nat.ble PRE_first_tail_x15_r0_body.cx0_89.mlx.next PRE_first_tail_x15_r0_body.cx1_89.mlx.next && Nat.ble PRE_first_tail_x15_r0_body.cx0_89.mlx.nnext PRE_first_tail_x15_r0_body.cx1_89.mlx.nnext) = true
kernel_rfl PRE_first_tail_x15_r0_body.cnband89 : (Nat.blt 0 PRE_first_tail_x15_r0_body.P89.NL && Nat.ble PRE_first_tail_x15_r0_body.P89.NL PRE_first_tail_x15_r0_body.P89.N0 && Nat.ble PRE_first_tail_x15_r0_body.P89.N0 PRE_first_tail_x15_r0_body.cx0_89.mlx.nnext) = true
kernel_rfl PRE_first_tail_x15_r0_body.chbelow89 : PRE_first_tail_x15_r0_body.kd89.checkHndBelow = true
kernel_rfl PRE_first_tail_x15_r0_body.chren89 : checkRenG PRE_first_tail_x15_r0_body.kd89.hnd PRE_first_tail_x15_r0_body.khinv89 (phB PRE_first_tail_x15_r0_body.cx0_89.mlx) = true
kernel_rfl PRE_first_tail_x15_r0_body.cband89 : PRE_first_tail_x15_r0_body.kd89.checkBand PRE_first_tail_x15_r0_body.P89.lo = true
kernel_rfl PRE_first_tail_x15_r0_body.cnh1pos89 : Nat.blt 0 PRE_first_tail_x15_r0_body.kd89.nh1 = true
kernel_rfl PRE_first_tail_x15_r0_body.cnren89 : checkRenG PRE_first_tail_x15_r0_body.kd89.node PRE_first_tail_x15_r0_body.kninv89 (pnB PRE_first_tail_x15_r0_body.cx0_89.mlx) = true
kernel_rfl PRE_first_tail_x15_r0_body.cnlow89 : (PTrie.keysA PRE_first_tail_x15_r0_body.kd89.node).all (fun j => Nat.ble PRE_first_tail_x15_r0_body.P89.NL j && Nat.blt (PRE_first_tail_x15_r0_body.kd89.nodeF j) PRE_first_tail_x15_r0_body.cx1_89.mlx.nnext) = true
kernel_rfl PRE_first_tail_x15_r0_body.cabs0a89 : PRE_first_tail_x15_r0_body.cx0_89.mlx.arrs.get 0 = none
kernel_rfl PRE_first_tail_x15_r0_body.cabs0b89 : PRE_first_tail_x15_r0_body.cx0_89.mlx.objs.get 0 = none
kernel_rfl PRE_first_tail_x15_r0_body.ctok189 : PRE_first_tail_x15_r0_body.cx1_89.mlx.tokens = []
kernel_rfl PRE_first_tail_x15_r0_body.cpend89 : PRE_first_tail_x15_r0_body.cx1_89.mlx.pending = PRE_first_tail_x15_r0_body.cx0_89.mlx.pending.map PRE_first_tail_x15_r0_body.kappa89.pend
kernel_rfl PRE_first_tail_x15_r0_body.cerrh89 : PRE_first_tail_x15_r0_body.cx1_89.mlx.errh = PRE_first_tail_x15_r0_body.cx0_89.mlx.errh.map PRE_first_tail_x15_r0_body.kappa89.arg
kernel_rfl PRE_first_tail_x15_r0_body.cfiles89 : PRE_first_tail_x15_r0_body.cx1_89.mlx.files = PRE_first_tail_x15_r0_body.cx0_89.mlx.files
kernel_rfl PRE_first_tail_x15_r0_body.carch89 : PRE_first_tail_x15_r0_body.cx1_89.mlx.arch = PRE_first_tail_x15_r0_body.cx0_89.mlx.arch
kernel_rfl PRE_first_tail_x15_r0_body.csizes89 : PRE_first_tail_x15_r0_body.cx1_89.mlx.deviceSizes = PRE_first_tail_x15_r0_body.cx0_89.mlx.deviceSizes
kernel_rfl PRE_first_tail_x15_r0_body.cwired89 : PRE_first_tail_x15_r0_body.cx1_89.mlx.wired = PRE_first_tail_x15_r0_body.cx0_89.mlx.wired
kernel_rfl PRE_first_tail_x15_r0_body.chost89 : PRE_first_tail_x15_r0_body.cx1_89.host = PRE_first_tail_x15_r0_body.cx0_89.host
-- the compaction map's addresses are `PRE_first_tail_x15_r0_body.kd89`'s
kernel_rfl PRE_first_tail_x15_r0_body.ckn089 : PRE_first_tail_x15_r0_body.kd89.n0 = 2744412
kernel_rfl PRE_first_tail_x15_r0_body.ckn189 : PRE_first_tail_x15_r0_body.kd89.n1 = 2744431
kernel_rfl PRE_first_tail_x15_r0_body.ckheap89 : (PTrie.keysA PRE_first_tail_x15_r0_body.kd89.heap).all (fun x => Nat.ble 2744411 x) = true
kernel_rfl PRE_first_tail_x15_r0_body.ckpl89 : (List.range 1).all (fun j => decide (PRE_first_tail_x15_r0_body.kd89.heap.get (2744411 + j) = nth? PRE_first_tail_x15_r0_body.pl89 j)) = true
-- the map fixes the call's names (`Conv.fixOld_compact`), the call's counters
kernel_rfl PRE_first_tail_x15_r0_body.fja89 : Nat.ble 2744411 2744411 = true
kernel_rfl PRE_first_tail_x15_r0_body.fn89 : Nat.ble 3859 3859 = true
kernel_rfl PRE_first_tail_x15_r0_body.fjaD89 : Nat.ble 2744411 PRE_first_tail_x15_r0_body.kd89.n0 = true
kernel_rfl PRE_first_tail_x15_r0_body.fxn89 : Nat.ble 19948 PRE_first_tail_x15_r0_body.kd89.nh0 = true
kernel_rfl PRE_first_tail_x15_r0_body.fnn89 : Nat.ble 17044 PRE_first_tail_x15_r0_body.kd89.nn0 = true
kernel_rfl PRE_first_tail_x15_r0_body.fxb89 : Nat.ble 19948 RData.bigHi = true
kernel_rfl PRE_first_tail_x15_r0_body.fheap89 : (PTrie.keysA PRE_first_tail_x15_r0_body.kd89.heap).all (Nat.ble (⟨19948, 17044, 2744411, 3859⟩ : Conv.Cnt).ja) = true
kernel_rfl PRE_first_tail_x15_r0_body.fhnd89 : (PTrie.keysA PRE_first_tail_x15_r0_body.kd89.hnd).all (Nat.ble (⟨19948, 17044, 2744411, 3859⟩ : Conv.Cnt).xn) = true
kernel_rfl PRE_first_tail_x15_r0_body.fnode89 : (PTrie.keysA PRE_first_tail_x15_r0_body.kd89.node).all (Nat.ble (⟨19948, 17044, 2744411, 3859⟩ : Conv.Cnt).nn) = true
/-- The compaction map fixes the call's names. -/
theorem PRE_first_tail_x15_r0_body.cfix89 : Conv.FixOld (⟨19948, 17044, 2744411, 3859⟩ : Conv.Cnt) PRE_first_tail_x15_r0_body.kappa89 :=
  Conv.fixOld_compact (Nat.le_of_ble_eq_true PRE_first_tail_x15_r0_body.fja89) (Nat.le_of_ble_eq_true PRE_first_tail_x15_r0_body.fn89) (Nat.le_of_ble_eq_true PRE_first_tail_x15_r0_body.fjaD89) (Nat.le_of_ble_eq_true PRE_first_tail_x15_r0_body.fxn89) (Nat.le_of_ble_eq_true PRE_first_tail_x15_r0_body.fnn89) (Nat.le_of_ble_eq_true PRE_first_tail_x15_r0_body.fxb89) PRE_first_tail_x15_r0_body.fheap89 PRE_first_tail_x15_r0_body.fhnd89 PRE_first_tail_x15_r0_body.fnode89
kernel_rfl PRE_first_tail_x15_r0_body.fcxn89 : (⟨19948, 17044, 2744411, 3859⟩ : Conv.Cnt).xn = (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s862.ffi).mlx.next
kernel_rfl PRE_first_tail_x15_r0_body.fcnn89 : (⟨19948, 17044, 2744411, 3859⟩ : Conv.Cnt).nn = (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s862.ffi).mlx.nnext
kernel_rfl PRE_first_tail_x15_r0_body.fle089 : (Nat.ble (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s862.ffi).mlx.next PRE_first_tail_x15_r0_body.cx0_89.mlx.next && Nat.ble (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s862.ffi).mlx.nnext PRE_first_tail_x15_r0_body.cx0_89.mlx.nnext && Nat.ble (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s862.ffi).mlx.next RData.bigHi) = true
kernel_rfl PRE_first_tail_x15_r0_body.fnk89 : (PTrie.keysA PRE_first_tail_x15_r0_body.kd89.node).all (Nat.ble (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s862.ffi).mlx.nnext) = true
-- the merged state keeps the call's entries off the stage's footprint
kernel_rfl PRE_first_tail_x15_r0_body.f1A89 : PRE_first_tail_x15_r0_body.cx1_89.mlx.arrs = Stage.setAll (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s862.ffi).mlx.arrs (PRE_first_tail_x15_r0_body.cwS89.filterMap fun i => (PRE_first_tail_x15_r0_body.cx1_89.mlx.arrs.get i).map (i, ·))
kernel_rfl PRE_first_tail_x15_r0_body.f1O89 : PRE_first_tail_x15_r0_body.cx1_89.mlx.objs = Stage.setAll (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s862.ffi).mlx.objs (PRE_first_tail_x15_r0_body.cwS89.filterMap fun i => (PRE_first_tail_x15_r0_body.cx1_89.mlx.objs.get i).map (i, ·))
kernel_rfl PRE_first_tail_x15_r0_body.f1N89 : PRE_first_tail_x15_r0_body.cx1_89.mlx.nodes = Stage.setAll (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s862.ffi).mlx.nodes (PRE_first_tail_x15_r0_body.cnS89.filterMap fun i => (PRE_first_tail_x15_r0_body.cx1_89.mlx.nodes.get i).map (i, ·))
kernel_rfl PRE_first_tail_x15_r0_body.f1I89 : PRE_first_tail_x15_r0_body.cx1_89.mlx.items = Stage.setAll (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s862.ffi).mlx.items (PRE_first_tail_x15_r0_body.ciS89.filterMap fun i => (PRE_first_tail_x15_r0_body.cx1_89.mlx.items.get i).map (i, ·))
kernel_rfl PRE_first_tail_x15_r0_body.fbd89 : (PRE_first_tail_x15_r0_body.clo89 ++ PRE_first_tail_x15_r0_body.cln89 ++ PRE_first_tail_x15_r0_body.cli89 ++ PRE_first_tail_x15_r0_body.cwS89 ++ PRE_first_tail_x15_r0_body.cnS89 ++ PRE_first_tail_x15_r0_body.ciS89).all (fun i => Nat.blt (i / 4096) (4 ^ 31)) = true
kernel_rfl PRE_first_tail_x15_r0_body.fincW89 : PRE_first_tail_x15_r0_body.cwS89.all (fun h => !Nat.blt h (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s862.ffi).mlx.next || PRE_first_tail_x15_r0_body.clo89.contains h) = true
kernel_rfl PRE_first_tail_x15_r0_body.fincI89 : PRE_first_tail_x15_r0_body.ciS89.all (fun k => !Nat.blt k (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s862.ffi).mlx.nnext || PRE_first_tail_x15_r0_body.cli89.contains k) = true
kernel_rfl PRE_first_tail_x15_r0_body.fincN89 : PRE_first_tail_x15_r0_body.cnS89.all (Nat.ble (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s862.ffi).mlx.nnext) = true
kernel_rfl PRE_first_tail_x15_r0_body.flnF89 : PRE_first_tail_x15_r0_body.cln89.all (Nat.ble (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s862.ffi).mlx.nnext) = true
-- the checks over the changed lists
kernel_rfl PRE_first_tail_x15_r0_body.fh89 : PRE_first_tail_x15_r0_body.clo89.all (handleOK PRE_first_tail_x15_r0_body.kappa89 PRE_first_tail_x15_r0_body.P89.lo PRE_first_tail_x15_r0_body.cx0_89.mlx PRE_first_tail_x15_r0_body.cx1_89.mlx) = true
kernel_rfl PRE_first_tail_x15_r0_body.fo89 : PRE_first_tail_x15_r0_body.clo89.map (fun h => PRE_first_tail_x15_r0_body.cx1_89.mlx.objs.get (PRE_first_tail_x15_r0_body.kappa89.handle h)) = PRE_first_tail_x15_r0_body.clo89.map (fun h => (PRE_first_tail_x15_r0_body.cx0_89.mlx.objs.get h).map PRE_first_tail_x15_r0_body.kappa89.nobj)
kernel_rfl PRE_first_tail_x15_r0_body.fok89 : PRE_first_tail_x15_r0_body.clo89.all (objOK PRE_first_tail_x15_r0_body.kappa89 PRE_first_tail_x15_r0_body.P89.NL PRE_first_tail_x15_r0_body.cx0_89.mlx) = true
kernel_rfl PRE_first_tail_x15_r0_body.fnd89 : PRE_first_tail_x15_r0_body.cln89.all (nodeOKF PRE_first_tail_x15_r0_body.kappa89 PRE_first_tail_x15_r0_body.P89 PRE_first_tail_x15_r0_body.cx0_89.mlx PRE_first_tail_x15_r0_body.cx1_89.mlx) = true
kernel_rfl PRE_first_tail_x15_r0_body.fp89 : ((PRE_first_tail_x15_r0_body.cln89.filter (fullB PRE_first_tail_x15_r0_body.P89))).map (fun i => (PRE_first_tail_x15_r0_body.cx1_89.mlx.nodes.get (PRE_first_tail_x15_r0_body.kappa89.node i)).map Host.Mlx.Ffi.Node.prim) =
  ((PRE_first_tail_x15_r0_body.cln89.filter (fullB PRE_first_tail_x15_r0_body.P89))).map (fun i => (PRE_first_tail_x15_r0_body.cx0_89.mlx.nodes.get i).map fun nd => PRE_first_tail_x15_r0_body.kappa89.prim nd.prim)
kernel_rfl PRE_first_tail_x15_r0_body.fnordI89 : incrB PRE_first_tail_x15_r0_body.kd89.nodeF (List.range' 17044 0) = true
kernel_rfl PRE_first_tail_x15_r0_body.fnordK89 : (PTrie.keysA PRE_first_tail_x15_r0_body.kd89.node).all (fun k => Nat.ble 17044 k && Nat.blt k 17044) = true
kernel_rfl PRE_first_tail_x15_r0_body.fnordL89 : (PRE_first_tail_x15_r0_body.cln89.filter (Nat.ble PRE_first_tail_x15_r0_body.P89.N0)).all (fun i => Nat.ble i (PRE_first_tail_x15_r0_body.kd89.nodeF i) && (Nat.blt i 17044 || Nat.ble PRE_first_tail_x15_r0_body.kd89.nn0 i)) = true
theorem PRE_first_tail_x15_r0_body.fnord89 : (PRE_first_tail_x15_r0_body.cln89.filter (Nat.ble PRE_first_tail_x15_r0_body.P89.N0)).all (fun i => Nat.ble i (PRE_first_tail_x15_r0_body.kd89.nodeF i) &&
    (PTrie.keysA PRE_first_tail_x15_r0_body.kd89.node).all fun j => !Nat.blt j i || Nat.blt (PRE_first_tail_x15_r0_body.kd89.nodeF j) (PRE_first_tail_x15_r0_body.kd89.nodeF i)) = true :=
  cnord_of PRE_first_tail_x15_r0_body.cnlow89 PRE_first_tail_x15_r0_body.cnn189 PRE_first_tail_x15_r0_body.fnordI89 PRE_first_tail_x15_r0_body.fnordK89 PRE_first_tail_x15_r0_body.fnordL89
kernel_rfl PRE_first_tail_x15_r0_body.fi89 : PRE_first_tail_x15_r0_body.cli89.all (pnB PRE_first_tail_x15_r0_body.cx0_89.mlx) = true
kernel_rfl PRE_first_tail_x15_r0_body.fii89 : PRE_first_tail_x15_r0_body.cli89.all (fun k => decide (PRE_first_tail_x15_r0_body.cx1_89.mlx.items.get (PRE_first_tail_x15_r0_body.kappa89.node k) = (PRE_first_tail_x15_r0_body.cx0_89.mlx.items.get k).map PRE_first_tail_x15_r0_body.kappa89.nv)) = true
/-- **The compaction's footprint.** -/
theorem PRE_first_tail_x15_r0_body.cfoot89 (clean : Conv.NClean (⟨19948, 17044, 2744411, 3859⟩ : Conv.Cnt) (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s862.ffi).mlx) (hltC : ∀ h, PH (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s862.ffi).mlx h → h < (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s862.ffi).mlx.next) (nltC : ∀ i, PN (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s862.ffi).mlx i → i < (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s862.ffi).mlx.nnext) (itemsC : ∀ k v, (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s862.ffi).mlx.items.get k = some v → PN (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s862.ffi).mlx k) (tracedC : ∀ h o, (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s862.ffi).mlx.objs.get h = some o → ∀ i ∈ objTraces o, i < PRE_first_tail_x15_r0_body.P89.NL) (cl : SSt (· < 3859) PRE_first_tail_x15_r0_body.cx0_89.mlx) :
    Conv.MFoot PRE_first_tail_x15_r0_body.P89 3859 PRE_first_tail_x15_r0_body.kappa89 PRE_first_tail_x15_r0_body.kd89 PRE_first_tail_x15_r0_body.khinv89 PRE_first_tail_x15_r0_body.kninv89 (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s862.ffi).mlx PRE_first_tail_x15_r0_body.cx0_89.mlx PRE_first_tail_x15_r0_body.cx1_89.mlx (⟨19948, 17044, 2744411, 3859⟩ : Conv.Cnt) PRE_first_tail_x15_r0_body.clo89 PRE_first_tail_x15_r0_body.cln89 PRE_first_tail_x15_r0_body.cli89 PRE_first_tail_x15_r0_body.cwS89 PRE_first_tail_x15_r0_body.cnS89 PRE_first_tail_x15_r0_body.ciS89 :=
  ⟨rfl, rfl, rfl, PRE_first_tail_x15_r0_body.cnh089, PRE_first_tail_x15_r0_body.cnh189, PRE_first_tail_x15_r0_body.cnn089, PRE_first_tail_x15_r0_body.cnn189, PRE_first_tail_x15_r0_body.cplo89, PRE_first_tail_x15_r0_body.ccnt89, PRE_first_tail_x15_r0_body.cnband89, PRE_first_tail_x15_r0_body.chbelow89, PRE_first_tail_x15_r0_body.chren89, PRE_first_tail_x15_r0_body.cband89, PRE_first_tail_x15_r0_body.cnh1pos89, PRE_first_tail_x15_r0_body.cnren89, PRE_first_tail_x15_r0_body.cnlow89, PRE_first_tail_x15_r0_body.cabs0a89, PRE_first_tail_x15_r0_body.cabs0b89, PRE_first_tail_x15_r0_body.ctok189, PRE_first_tail_x15_r0_body.cpend89, PRE_first_tail_x15_r0_body.cerrh89, PRE_first_tail_x15_r0_body.cfiles89, PRE_first_tail_x15_r0_body.carch89, PRE_first_tail_x15_r0_body.csizes89, PRE_first_tail_x15_r0_body.cwired89, PRE_first_tail_x15_r0_body.cfix89, clean, PRE_first_tail_x15_r0_body.fcxn89, PRE_first_tail_x15_r0_body.fcnn89, hltC, nltC, itemsC, tracedC, cl, PRE_first_tail_x15_r0_body.fle089, PRE_first_tail_x15_r0_body.fnk89, PRE_first_tail_x15_r0_body.ckA89, PRE_first_tail_x15_r0_body.cobjsK89, PRE_first_tail_x15_r0_body.cnodesK89, PRE_first_tail_x15_r0_body.citemsK89, PRE_first_tail_x15_r0_body.f1A89, PRE_first_tail_x15_r0_body.f1O89, PRE_first_tail_x15_r0_body.f1N89, PRE_first_tail_x15_r0_body.f1I89, PRE_first_tail_x15_r0_body.fbd89, PRE_first_tail_x15_r0_body.fincW89, PRE_first_tail_x15_r0_body.fincI89, PRE_first_tail_x15_r0_body.fincN89, PRE_first_tail_x15_r0_body.flnF89, PRE_first_tail_x15_r0_body.fh89, PRE_first_tail_x15_r0_body.fo89, PRE_first_tail_x15_r0_body.fok89, PRE_first_tail_x15_r0_body.fnd89, PRE_first_tail_x15_r0_body.fp89, PRE_first_tail_x15_r0_body.fnord89, PRE_first_tail_x15_r0_body.fi89, PRE_first_tail_x15_r0_body.fii89⟩
theorem PRE_first_tail_x15_r0_body.cnshift89 (clean : Conv.NClean (⟨19948, 17044, 2744411, 3859⟩ : Conv.Cnt) (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s862.ffi).mlx) (hltC : ∀ h, PH (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s862.ffi).mlx h → h < (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s862.ffi).mlx.next) (nltC : ∀ i, PN (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s862.ffi).mlx i → i < (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s862.ffi).mlx.nnext) (itemsC : ∀ k v, (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s862.ffi).mlx.items.get k = some v → PN (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s862.ffi).mlx k) (tracedC : ∀ h o, (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s862.ffi).mlx.objs.get h = some o → ∀ i ∈ objTraces o, i < PRE_first_tail_x15_r0_body.P89.NL) (cl : SSt (· < 3859) PRE_first_tail_x15_r0_body.cx0_89.mlx) : NShift PRE_first_tail_x15_r0_body.P89 3859 PRE_first_tail_x15_r0_body.kappa89 PRE_first_tail_x15_r0_body.cx0_89 PRE_first_tail_x15_r0_body.cx1_89 :=
  Conv.nshift_of_foot (PRE_first_tail_x15_r0_body.cfoot89 clean hltC nltC itemsC tracedC cl) PRE_first_tail_x15_r0_body.chost89 (compact_a_eq PRE_first_tail_x15_r0_body.ckn089 PRE_first_tail_x15_r0_body.ckn189 PRE_first_tail_x15_r0_body.ckheap89 PRE_first_tail_x15_r0_body.ckpl89)

-- the observers: the layers' states at the call, the canonical and the merged state, their footprints and checks
noncomputable def PRE_first_tail_x15_r0_body.fxC_89 : PTrie Unit := (Host.Ts.Sim.Full.freedOf PRE_first_tail_x15_r0_body.s862.ffi).getD PTrie.nil
noncomputable def PRE_first_tail_x15_r0_body.krC_89 : Host.Load.Layers.KRec := (Host.Ts.Sim.Full.krecOf PRE_first_tail_x15_r0_body.s862.ffi).getD Host.Load.Layers.KRec.empty
kernel_rfl PRE_first_tail_x15_r0_body.ofxC_89 : (Host.Ts.Sim.Full.freedOf PRE_first_tail_x15_r0_body.s862.ffi) = some PRE_first_tail_x15_r0_body.fxC_89
kernel_rfl PRE_first_tail_x15_r0_body.okrC_89 : (Host.Ts.Sim.Full.krecOf PRE_first_tail_x15_r0_body.s862.ffi) = some PRE_first_tail_x15_r0_body.krC_89
noncomputable def PRE_first_tail_x15_r0_body.fx0_89 : PTrie Unit := (Host.Ts.Sim.Full.freedOf PRE_first_tail_x15_r0_body.s864.ffi).getD PTrie.nil
noncomputable def PRE_first_tail_x15_r0_body.kr0_89 : Host.Load.Layers.KRec := (Host.Ts.Sim.Full.krecOf PRE_first_tail_x15_r0_body.s864.ffi).getD Host.Load.Layers.KRec.empty
kernel_rfl PRE_first_tail_x15_r0_body.ofx0_89 : (Host.Ts.Sim.Full.freedOf PRE_first_tail_x15_r0_body.s864.ffi) = some PRE_first_tail_x15_r0_body.fx0_89
kernel_rfl PRE_first_tail_x15_r0_body.okr0_89 : (Host.Ts.Sim.Full.krecOf PRE_first_tail_x15_r0_body.s864.ffi) = some PRE_first_tail_x15_r0_body.kr0_89
noncomputable def PRE_first_tail_x15_r0_body.fx1_89 : PTrie Unit := (Host.Ts.Sim.Full.freedOf PRE_first_tail_x15_r0_body.s863.ffi).getD PTrie.nil
noncomputable def PRE_first_tail_x15_r0_body.kr1_89 : Host.Load.Layers.KRec := (Host.Ts.Sim.Full.krecOf PRE_first_tail_x15_r0_body.s863.ffi).getD Host.Load.Layers.KRec.empty
kernel_rfl PRE_first_tail_x15_r0_body.ofx1_89 : (Host.Ts.Sim.Full.freedOf PRE_first_tail_x15_r0_body.s863.ffi) = some PRE_first_tail_x15_r0_body.fx1_89
kernel_rfl PRE_first_tail_x15_r0_body.okr1_89 : (Host.Ts.Sim.Full.krecOf PRE_first_tail_x15_r0_body.s863.ffi) = some PRE_first_tail_x15_r0_body.kr1_89
kernel_rfl PRE_first_tail_x15_r0_body.ff089 : PRE_first_tail_x15_r0_body.fx0_89 = Stage.setAll PRE_first_tail_x15_r0_body.fxC_89 (PRE_first_tail_x15_r0_body.clo89.filterMap fun i => (PRE_first_tail_x15_r0_body.fx0_89.get i).map (i, ·))
kernel_rfl PRE_first_tail_x15_r0_body.ff189 : PRE_first_tail_x15_r0_body.fx1_89 = Stage.setAll PRE_first_tail_x15_r0_body.fxC_89 (PRE_first_tail_x15_r0_body.cwS89.filterMap fun i => (PRE_first_tail_x15_r0_body.fx1_89.get i).map (i, ·))
kernel_rfl PRE_first_tail_x15_r0_body.ffck89 : freedLB PRE_first_tail_x15_r0_body.kappa89 PRE_first_tail_x15_r0_body.cx0_89.mlx PRE_first_tail_x15_r0_body.fx0_89 PRE_first_tail_x15_r0_body.fx1_89 PRE_first_tail_x15_r0_body.clo89 = true
kernel_rfl PRE_first_tail_x15_r0_body.fkf089 : PRE_first_tail_x15_r0_body.kr0_89.flags = Stage.setAll PRE_first_tail_x15_r0_body.krC_89.flags (PRE_first_tail_x15_r0_body.clo89.filterMap fun i => (PRE_first_tail_x15_r0_body.kr0_89.flags.get i).map (i, ·))
kernel_rfl PRE_first_tail_x15_r0_body.fkt089 : PRE_first_tail_x15_r0_body.kr0_89.targs = Stage.setAll PRE_first_tail_x15_r0_body.krC_89.targs (PRE_first_tail_x15_r0_body.clo89.filterMap fun i => (PRE_first_tail_x15_r0_body.kr0_89.targs.get i).map (i, ·))
kernel_rfl PRE_first_tail_x15_r0_body.fkf189 : PRE_first_tail_x15_r0_body.kr1_89.flags = Stage.setAll PRE_first_tail_x15_r0_body.krC_89.flags (PRE_first_tail_x15_r0_body.cwS89.filterMap fun i => (PRE_first_tail_x15_r0_body.kr1_89.flags.get i).map (i, ·))
kernel_rfl PRE_first_tail_x15_r0_body.fkt189 : PRE_first_tail_x15_r0_body.kr1_89.targs = Stage.setAll PRE_first_tail_x15_r0_body.krC_89.targs (PRE_first_tail_x15_r0_body.cwS89.filterMap fun i => (PRE_first_tail_x15_r0_body.kr1_89.targs.get i).map (i, ·))
kernel_rfl PRE_first_tail_x15_r0_body.fkck89 : krecLB PRE_first_tail_x15_r0_body.kappa89 3859 PRE_first_tail_x15_r0_body.cx0_89.mlx PRE_first_tail_x15_r0_body.kr0_89 PRE_first_tail_x15_r0_body.kr1_89 PRE_first_tail_x15_r0_body.clo89 = true
kernel_rfl PRE_first_tail_x15_r0_body.fkn89 : Nat.ble 3859 3859 = true
-- the bridge and the pending traces' regions
kernel_rfl PRE_first_tail_x15_r0_body.cbridge89 : Host.Ts.Sim.Full.bridgeOf PRE_first_tail_x15_r0_body.s863.ffi = Host.Ts.Sim.Full.bridgeOf PRE_first_tail_x15_r0_body.s864.ffi
kernel_rfl PRE_first_tail_x15_r0_body.cpendR89 : pendRegB PRE_first_tail_x15_r0_body.kappa89 (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s864.ffi).mlx = true
kernel_rfl PRE_first_tail_x15_r0_body.cpendLe89 : Nat.ble (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s864.ffi).mlx.next (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s863.ffi).mlx.next = true
/-- **The compaction's native shift**, given the call's bookkeeping, its relation's facts (the model's and the
observers') and the canonical closedness. -/
theorem PRE_first_tail_x15_r0_body.cshift89 (clean : Conv.NClean (⟨19948, 17044, 2744411, 3859⟩ : Conv.Cnt) (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s862.ffi).mlx) (hltC : ∀ h, PH (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s862.ffi).mlx h → h < (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s862.ffi).mlx.next) (nltC : ∀ i, PN (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s862.ffi).mlx i → i < (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s862.ffi).mlx.nnext) (itemsC : ∀ k v, (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s862.ffi).mlx.items.get k = some v → PN (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s862.ffi).mlx k) (tracedC : ∀ h o, (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s862.ffi).mlx.objs.get h = some o → ∀ i ∈ objTraces o, i < PRE_first_tail_x15_r0_body.P89.NL) (cl : SSt (· < 3859) PRE_first_tail_x15_r0_body.cx0_89.mlx)
    (hobjC : ∀ h, PRE_first_tail_x15_r0_body.fxC_89.get h = some () → ((Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s862.ffi).mlx.objs.get h).isSome = true)
    (hfC : ∀ h, (PRE_first_tail_x15_r0_body.krC_89.flags.get h).isSome = true → ((Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s862.ffi).mlx.objs.get h).isSome = true)
    (htC : ∀ h, (PRE_first_tail_x15_r0_body.krC_89.targs.get h).isSome = true → ((Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s862.ffi).mlx.objs.get h).isSome = true)
    (hclC : ∀ h l, PRE_first_tail_x15_r0_body.krC_89.targs.get h = some l → Host.Ts.Sim.Full.STargs (· < (⟨19948, 17044, 2744411, 3859⟩ : Conv.Cnt).n) l) :
    Conv.FullShiftQ PRE_first_tail_x15_r0_body.P89 3859 PRE_first_tail_x15_r0_body.kappa89 PRE_first_tail_x15_r0_body.s864.ffi PRE_first_tail_x15_r0_body.s863.ffi :=
  ⟨PRE_first_tail_x15_r0_body.cnshift89 clean hltC nltC itemsC tracedC cl, PRE_first_tail_x15_r0_body.cqueue89, fun t ht => bSN_sound (List.all_eq_true.mp PRE_first_tail_x15_r0_body.ctokSupp89 t ht),
    PRE_first_tail_x15_r0_body.cbridge89,
    liveShift_foot (x0' := Host.Ts.Sim.Full.mlxOf PRE_first_tail_x15_r0_body.s864.ffi) (x1' := Host.Ts.Sim.Full.mlxOf PRE_first_tail_x15_r0_body.s863.ffi) (PRE_first_tail_x15_r0_body.cfoot89 clean hltC nltC itemsC tracedC cl) rfl PRE_first_tail_x15_r0_body.ofx0_89 PRE_first_tail_x15_r0_body.ofx1_89 hobjC PRE_first_tail_x15_r0_body.ff089 PRE_first_tail_x15_r0_body.ff189 PRE_first_tail_x15_r0_body.ffck89,
    kernShift_foot (x0' := Host.Ts.Sim.Full.mlxOf PRE_first_tail_x15_r0_body.s864.ffi) (x1' := Host.Ts.Sim.Full.mlxOf PRE_first_tail_x15_r0_body.s863.ffi) (PRE_first_tail_x15_r0_body.cfoot89 clean hltC nltC itemsC tracedC cl) rfl PRE_first_tail_x15_r0_body.okr0_89 PRE_first_tail_x15_r0_body.okr1_89 (Nat.le_of_ble_eq_true PRE_first_tail_x15_r0_body.fkn89) hfC htC hclC
      PRE_first_tail_x15_r0_body.fkf089 PRE_first_tail_x15_r0_body.fkt089 PRE_first_tail_x15_r0_body.fkf189 PRE_first_tail_x15_r0_body.fkt189 PRE_first_tail_x15_r0_body.fkck89,
    pendReg_of rfl PRE_first_tail_x15_r0_body.cnh089 PRE_first_tail_x15_r0_body.cnh189 (Nat.le_of_ble_eq_true PRE_first_tail_x15_r0_body.cpendLe89) PRE_first_tail_x15_r0_body.cpendR89⟩

end Host.Load.Run.Tpl
