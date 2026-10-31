import host.sim.template.a4pre_first_tail_x15_r0_body.SiteCl68
import host.sim.conv.CompactFull
import host.sim.template.FootGen
set_option Elab.async false
namespace Host.Load.Run.Tpl
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
open Host.Ts Host.Ts.Sim Host.Ts.Sim.Template

/-! The compaction's native shift at call site 68 from its footprint (`Conv.nshift_of_foot`), and the observers'
(`liveShift_foot`, `kernShift_foot`): `Conv.FullShiftQ` for `Conv.full_compactQ`, given the call's bookkeeping and its
relation's facts. -/

/-- The load parameters of the chain (band-free: its start's node counter as `NL` and `N0`). -/
def PRE_first_tail_x15_r0_body.Pc68 : LoadP := ⟨18151, 131072, 1099511627776, 15235, 15235, []⟩
/-- The site's band raised to the map's checked fixed-node prefix, including newly recorded closure traces. -/
def PRE_first_tail_x15_r0_body.P68 : LoadP := PRE_first_tail_x15_r0_body.Pc68.raise 16633
kernel_rfl PRE_first_tail_x15_r0_body.craise68 : Nat.ble PRE_first_tail_x15_r0_body.Pc68.N0 16633 = true
theorem PRE_first_tail_x15_r0_body.raised68 : Host.Ts.Sim.Full.Raised PRE_first_tail_x15_r0_body.Pc68 PRE_first_tail_x15_r0_body.P68 :=
  .inr ⟨16633, rfl, Nat.le_of_ble_eq_true PRE_first_tail_x15_r0_body.craise68, rfl⟩
noncomputable abbrev PRE_first_tail_x15_r0_body.cx0_68 : Host.Load.LSt := clearTokens (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s663.ffi)
noncomputable abbrev PRE_first_tail_x15_r0_body.cx1_68 : Host.Load.LSt := clearTokens (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s662.ffi)
def PRE_first_tail_x15_r0_body.khinv68 : PTrie Nat := Stage.setAll PTrie.nil []
def PRE_first_tail_x15_r0_body.kninv68 : PTrie Nat := Stage.setAll PTrie.nil []
/-- The stage's footprint: its written and fresh handles, fresh nodes, written and fresh items. -/
def PRE_first_tail_x15_r0_body.cwS68 : List Nat := []
def PRE_first_tail_x15_r0_body.cnS68 : List Nat := List.range' 16633 0
def PRE_first_tail_x15_r0_body.ciS68 : List Nat := [] ++ List.range' 16633 0

-- the small checks (`MChecks`'s)
kernel_rfl PRE_first_tail_x15_r0_body.cnh068 : PRE_first_tail_x15_r0_body.kd68.nh0 = PRE_first_tail_x15_r0_body.cx0_68.mlx.next
kernel_rfl PRE_first_tail_x15_r0_body.cnh168 : PRE_first_tail_x15_r0_body.kd68.nh1 = PRE_first_tail_x15_r0_body.cx1_68.mlx.next
kernel_rfl PRE_first_tail_x15_r0_body.cnn068 : PRE_first_tail_x15_r0_body.kd68.nn0 = PRE_first_tail_x15_r0_body.cx0_68.mlx.nnext
kernel_rfl PRE_first_tail_x15_r0_body.cnn168 : PRE_first_tail_x15_r0_body.kd68.nn1 = PRE_first_tail_x15_r0_body.cx1_68.mlx.nnext
kernel_rfl PRE_first_tail_x15_r0_body.cplo68 : (Nat.blt 0 PRE_first_tail_x15_r0_body.P68.lo && Nat.ble PRE_first_tail_x15_r0_body.P68.lo PRE_first_tail_x15_r0_body.cx0_68.mlx.next && Nat.ble PRE_first_tail_x15_r0_body.P68.lo RData.bigHi && Nat.ble RData.bigHi PRE_first_tail_x15_r0_body.P68.E) = true
kernel_rfl PRE_first_tail_x15_r0_body.ccnt68 : (Nat.ble PRE_first_tail_x15_r0_body.cx0_68.mlx.next PRE_first_tail_x15_r0_body.cx1_68.mlx.next && Nat.ble PRE_first_tail_x15_r0_body.cx0_68.mlx.nnext PRE_first_tail_x15_r0_body.cx1_68.mlx.nnext) = true
kernel_rfl PRE_first_tail_x15_r0_body.cnband68 : (Nat.blt 0 PRE_first_tail_x15_r0_body.P68.NL && Nat.ble PRE_first_tail_x15_r0_body.P68.NL PRE_first_tail_x15_r0_body.P68.N0 && Nat.ble PRE_first_tail_x15_r0_body.P68.N0 PRE_first_tail_x15_r0_body.cx0_68.mlx.nnext) = true
kernel_rfl PRE_first_tail_x15_r0_body.chbelow68 : PRE_first_tail_x15_r0_body.kd68.checkHndBelow = true
kernel_rfl PRE_first_tail_x15_r0_body.chren68 : checkRenG PRE_first_tail_x15_r0_body.kd68.hnd PRE_first_tail_x15_r0_body.khinv68 (phB PRE_first_tail_x15_r0_body.cx0_68.mlx) = true
kernel_rfl PRE_first_tail_x15_r0_body.cband68 : PRE_first_tail_x15_r0_body.kd68.checkBand PRE_first_tail_x15_r0_body.P68.lo = true
kernel_rfl PRE_first_tail_x15_r0_body.cnh1pos68 : Nat.blt 0 PRE_first_tail_x15_r0_body.kd68.nh1 = true
kernel_rfl PRE_first_tail_x15_r0_body.cnren68 : checkRenG PRE_first_tail_x15_r0_body.kd68.node PRE_first_tail_x15_r0_body.kninv68 (pnB PRE_first_tail_x15_r0_body.cx0_68.mlx) = true
kernel_rfl PRE_first_tail_x15_r0_body.cnlow68 : (PTrie.keysA PRE_first_tail_x15_r0_body.kd68.node).all (fun j => Nat.ble PRE_first_tail_x15_r0_body.P68.NL j && Nat.blt (PRE_first_tail_x15_r0_body.kd68.nodeF j) PRE_first_tail_x15_r0_body.cx1_68.mlx.nnext) = true
kernel_rfl PRE_first_tail_x15_r0_body.cabs0a68 : PRE_first_tail_x15_r0_body.cx0_68.mlx.arrs.get 0 = none
kernel_rfl PRE_first_tail_x15_r0_body.cabs0b68 : PRE_first_tail_x15_r0_body.cx0_68.mlx.objs.get 0 = none
kernel_rfl PRE_first_tail_x15_r0_body.ctok168 : PRE_first_tail_x15_r0_body.cx1_68.mlx.tokens = []
kernel_rfl PRE_first_tail_x15_r0_body.cpend68 : PRE_first_tail_x15_r0_body.cx1_68.mlx.pending = PRE_first_tail_x15_r0_body.cx0_68.mlx.pending.map PRE_first_tail_x15_r0_body.kappa68.pend
kernel_rfl PRE_first_tail_x15_r0_body.cerrh68 : PRE_first_tail_x15_r0_body.cx1_68.mlx.errh = PRE_first_tail_x15_r0_body.cx0_68.mlx.errh.map PRE_first_tail_x15_r0_body.kappa68.arg
kernel_rfl PRE_first_tail_x15_r0_body.cfiles68 : PRE_first_tail_x15_r0_body.cx1_68.mlx.files = PRE_first_tail_x15_r0_body.cx0_68.mlx.files
kernel_rfl PRE_first_tail_x15_r0_body.carch68 : PRE_first_tail_x15_r0_body.cx1_68.mlx.arch = PRE_first_tail_x15_r0_body.cx0_68.mlx.arch
kernel_rfl PRE_first_tail_x15_r0_body.csizes68 : PRE_first_tail_x15_r0_body.cx1_68.mlx.deviceSizes = PRE_first_tail_x15_r0_body.cx0_68.mlx.deviceSizes
kernel_rfl PRE_first_tail_x15_r0_body.cwired68 : PRE_first_tail_x15_r0_body.cx1_68.mlx.wired = PRE_first_tail_x15_r0_body.cx0_68.mlx.wired
kernel_rfl PRE_first_tail_x15_r0_body.chost68 : PRE_first_tail_x15_r0_body.cx1_68.host = PRE_first_tail_x15_r0_body.cx0_68.host
-- the compaction map's addresses are `PRE_first_tail_x15_r0_body.kd68`'s
kernel_rfl PRE_first_tail_x15_r0_body.ckn068 : PRE_first_tail_x15_r0_body.kd68.n0 = 2727844
kernel_rfl PRE_first_tail_x15_r0_body.ckn168 : PRE_first_tail_x15_r0_body.kd68.n1 = 2727854
kernel_rfl PRE_first_tail_x15_r0_body.ckheap68 : (PTrie.keysA PRE_first_tail_x15_r0_body.kd68.heap).all (fun x => Nat.ble 2727843 x) = true
kernel_rfl PRE_first_tail_x15_r0_body.ckpl68 : (List.range 1).all (fun j => decide (PRE_first_tail_x15_r0_body.kd68.heap.get (2727843 + j) = nth? PRE_first_tail_x15_r0_body.pl68 j)) = true
-- the map fixes the call's names (`Conv.fixOld_compact`), the call's counters
kernel_rfl PRE_first_tail_x15_r0_body.fja68 : Nat.ble 2727843 2727843 = true
kernel_rfl PRE_first_tail_x15_r0_body.fn68 : Nat.ble 2962 2962 = true
kernel_rfl PRE_first_tail_x15_r0_body.fjaD68 : Nat.ble 2727843 PRE_first_tail_x15_r0_body.kd68.n0 = true
kernel_rfl PRE_first_tail_x15_r0_body.fxn68 : Nat.ble 19533 PRE_first_tail_x15_r0_body.kd68.nh0 = true
kernel_rfl PRE_first_tail_x15_r0_body.fnn68 : Nat.ble 16633 PRE_first_tail_x15_r0_body.kd68.nn0 = true
kernel_rfl PRE_first_tail_x15_r0_body.fxb68 : Nat.ble 19533 RData.bigHi = true
kernel_rfl PRE_first_tail_x15_r0_body.fheap68 : (PTrie.keysA PRE_first_tail_x15_r0_body.kd68.heap).all (Nat.ble (⟨19533, 16633, 2727843, 2962⟩ : Conv.Cnt).ja) = true
kernel_rfl PRE_first_tail_x15_r0_body.fhnd68 : (PTrie.keysA PRE_first_tail_x15_r0_body.kd68.hnd).all (Nat.ble (⟨19533, 16633, 2727843, 2962⟩ : Conv.Cnt).xn) = true
kernel_rfl PRE_first_tail_x15_r0_body.fnode68 : (PTrie.keysA PRE_first_tail_x15_r0_body.kd68.node).all (Nat.ble (⟨19533, 16633, 2727843, 2962⟩ : Conv.Cnt).nn) = true
/-- The compaction map fixes the call's names. -/
theorem PRE_first_tail_x15_r0_body.cfix68 : Conv.FixOld (⟨19533, 16633, 2727843, 2962⟩ : Conv.Cnt) PRE_first_tail_x15_r0_body.kappa68 :=
  Conv.fixOld_compact (Nat.le_of_ble_eq_true PRE_first_tail_x15_r0_body.fja68) (Nat.le_of_ble_eq_true PRE_first_tail_x15_r0_body.fn68) (Nat.le_of_ble_eq_true PRE_first_tail_x15_r0_body.fjaD68) (Nat.le_of_ble_eq_true PRE_first_tail_x15_r0_body.fxn68) (Nat.le_of_ble_eq_true PRE_first_tail_x15_r0_body.fnn68) (Nat.le_of_ble_eq_true PRE_first_tail_x15_r0_body.fxb68) PRE_first_tail_x15_r0_body.fheap68 PRE_first_tail_x15_r0_body.fhnd68 PRE_first_tail_x15_r0_body.fnode68
kernel_rfl PRE_first_tail_x15_r0_body.fcxn68 : (⟨19533, 16633, 2727843, 2962⟩ : Conv.Cnt).xn = (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s661.ffi).mlx.next
kernel_rfl PRE_first_tail_x15_r0_body.fcnn68 : (⟨19533, 16633, 2727843, 2962⟩ : Conv.Cnt).nn = (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s661.ffi).mlx.nnext
kernel_rfl PRE_first_tail_x15_r0_body.fle068 : (Nat.ble (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s661.ffi).mlx.next PRE_first_tail_x15_r0_body.cx0_68.mlx.next && Nat.ble (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s661.ffi).mlx.nnext PRE_first_tail_x15_r0_body.cx0_68.mlx.nnext && Nat.ble (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s661.ffi).mlx.next RData.bigHi) = true
kernel_rfl PRE_first_tail_x15_r0_body.fnk68 : (PTrie.keysA PRE_first_tail_x15_r0_body.kd68.node).all (Nat.ble (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s661.ffi).mlx.nnext) = true
-- the merged state keeps the call's entries off the stage's footprint
kernel_rfl PRE_first_tail_x15_r0_body.f1A68 : PRE_first_tail_x15_r0_body.cx1_68.mlx.arrs = Stage.setAll (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s661.ffi).mlx.arrs (PRE_first_tail_x15_r0_body.cwS68.filterMap fun i => (PRE_first_tail_x15_r0_body.cx1_68.mlx.arrs.get i).map (i, ·))
kernel_rfl PRE_first_tail_x15_r0_body.f1O68 : PRE_first_tail_x15_r0_body.cx1_68.mlx.objs = Stage.setAll (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s661.ffi).mlx.objs (PRE_first_tail_x15_r0_body.cwS68.filterMap fun i => (PRE_first_tail_x15_r0_body.cx1_68.mlx.objs.get i).map (i, ·))
kernel_rfl PRE_first_tail_x15_r0_body.f1N68 : PRE_first_tail_x15_r0_body.cx1_68.mlx.nodes = Stage.setAll (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s661.ffi).mlx.nodes (PRE_first_tail_x15_r0_body.cnS68.filterMap fun i => (PRE_first_tail_x15_r0_body.cx1_68.mlx.nodes.get i).map (i, ·))
kernel_rfl PRE_first_tail_x15_r0_body.f1I68 : PRE_first_tail_x15_r0_body.cx1_68.mlx.items = Stage.setAll (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s661.ffi).mlx.items (PRE_first_tail_x15_r0_body.ciS68.filterMap fun i => (PRE_first_tail_x15_r0_body.cx1_68.mlx.items.get i).map (i, ·))
kernel_rfl PRE_first_tail_x15_r0_body.fbd68 : (PRE_first_tail_x15_r0_body.clo68 ++ PRE_first_tail_x15_r0_body.cln68 ++ PRE_first_tail_x15_r0_body.cli68 ++ PRE_first_tail_x15_r0_body.cwS68 ++ PRE_first_tail_x15_r0_body.cnS68 ++ PRE_first_tail_x15_r0_body.ciS68).all (fun i => Nat.blt (i / 4096) (4 ^ 31)) = true
kernel_rfl PRE_first_tail_x15_r0_body.fincW68 : PRE_first_tail_x15_r0_body.cwS68.all (fun h => !Nat.blt h (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s661.ffi).mlx.next || PRE_first_tail_x15_r0_body.clo68.contains h) = true
kernel_rfl PRE_first_tail_x15_r0_body.fincI68 : PRE_first_tail_x15_r0_body.ciS68.all (fun k => !Nat.blt k (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s661.ffi).mlx.nnext || PRE_first_tail_x15_r0_body.cli68.contains k) = true
kernel_rfl PRE_first_tail_x15_r0_body.fincN68 : PRE_first_tail_x15_r0_body.cnS68.all (Nat.ble (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s661.ffi).mlx.nnext) = true
kernel_rfl PRE_first_tail_x15_r0_body.flnF68 : PRE_first_tail_x15_r0_body.cln68.all (Nat.ble (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s661.ffi).mlx.nnext) = true
-- the checks over the changed lists
kernel_rfl PRE_first_tail_x15_r0_body.fh68 : PRE_first_tail_x15_r0_body.clo68.all (handleOK PRE_first_tail_x15_r0_body.kappa68 PRE_first_tail_x15_r0_body.P68.lo PRE_first_tail_x15_r0_body.cx0_68.mlx PRE_first_tail_x15_r0_body.cx1_68.mlx) = true
kernel_rfl PRE_first_tail_x15_r0_body.fo68 : PRE_first_tail_x15_r0_body.clo68.map (fun h => PRE_first_tail_x15_r0_body.cx1_68.mlx.objs.get (PRE_first_tail_x15_r0_body.kappa68.handle h)) = PRE_first_tail_x15_r0_body.clo68.map (fun h => (PRE_first_tail_x15_r0_body.cx0_68.mlx.objs.get h).map PRE_first_tail_x15_r0_body.kappa68.nobj)
kernel_rfl PRE_first_tail_x15_r0_body.fok68 : PRE_first_tail_x15_r0_body.clo68.all (objOK PRE_first_tail_x15_r0_body.kappa68 PRE_first_tail_x15_r0_body.P68.NL PRE_first_tail_x15_r0_body.cx0_68.mlx) = true
kernel_rfl PRE_first_tail_x15_r0_body.fnd68 : PRE_first_tail_x15_r0_body.cln68.all (nodeOKF PRE_first_tail_x15_r0_body.kappa68 PRE_first_tail_x15_r0_body.P68 PRE_first_tail_x15_r0_body.cx0_68.mlx PRE_first_tail_x15_r0_body.cx1_68.mlx) = true
kernel_rfl PRE_first_tail_x15_r0_body.fp68 : ((PRE_first_tail_x15_r0_body.cln68.filter (fullB PRE_first_tail_x15_r0_body.P68))).map (fun i => (PRE_first_tail_x15_r0_body.cx1_68.mlx.nodes.get (PRE_first_tail_x15_r0_body.kappa68.node i)).map Host.Mlx.Ffi.Node.prim) =
  ((PRE_first_tail_x15_r0_body.cln68.filter (fullB PRE_first_tail_x15_r0_body.P68))).map (fun i => (PRE_first_tail_x15_r0_body.cx0_68.mlx.nodes.get i).map fun nd => PRE_first_tail_x15_r0_body.kappa68.prim nd.prim)
kernel_rfl PRE_first_tail_x15_r0_body.fnordI68 : incrB PRE_first_tail_x15_r0_body.kd68.nodeF (List.range' 16633 0) = true
kernel_rfl PRE_first_tail_x15_r0_body.fnordK68 : (PTrie.keysA PRE_first_tail_x15_r0_body.kd68.node).all (fun k => Nat.ble 16633 k && Nat.blt k 16633) = true
kernel_rfl PRE_first_tail_x15_r0_body.fnordL68 : (PRE_first_tail_x15_r0_body.cln68.filter (Nat.ble PRE_first_tail_x15_r0_body.P68.N0)).all (fun i => Nat.ble i (PRE_first_tail_x15_r0_body.kd68.nodeF i) && (Nat.blt i 16633 || Nat.ble PRE_first_tail_x15_r0_body.kd68.nn0 i)) = true
theorem PRE_first_tail_x15_r0_body.fnord68 : (PRE_first_tail_x15_r0_body.cln68.filter (Nat.ble PRE_first_tail_x15_r0_body.P68.N0)).all (fun i => Nat.ble i (PRE_first_tail_x15_r0_body.kd68.nodeF i) &&
    (PTrie.keysA PRE_first_tail_x15_r0_body.kd68.node).all fun j => !Nat.blt j i || Nat.blt (PRE_first_tail_x15_r0_body.kd68.nodeF j) (PRE_first_tail_x15_r0_body.kd68.nodeF i)) = true :=
  cnord_of PRE_first_tail_x15_r0_body.cnlow68 PRE_first_tail_x15_r0_body.cnn168 PRE_first_tail_x15_r0_body.fnordI68 PRE_first_tail_x15_r0_body.fnordK68 PRE_first_tail_x15_r0_body.fnordL68
kernel_rfl PRE_first_tail_x15_r0_body.fi68 : PRE_first_tail_x15_r0_body.cli68.all (pnB PRE_first_tail_x15_r0_body.cx0_68.mlx) = true
kernel_rfl PRE_first_tail_x15_r0_body.fii68 : PRE_first_tail_x15_r0_body.cli68.all (fun k => decide (PRE_first_tail_x15_r0_body.cx1_68.mlx.items.get (PRE_first_tail_x15_r0_body.kappa68.node k) = (PRE_first_tail_x15_r0_body.cx0_68.mlx.items.get k).map PRE_first_tail_x15_r0_body.kappa68.nv)) = true
/-- **The compaction's footprint.** -/
theorem PRE_first_tail_x15_r0_body.cfoot68 (clean : Conv.NClean (⟨19533, 16633, 2727843, 2962⟩ : Conv.Cnt) (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s661.ffi).mlx) (hltC : ∀ h, PH (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s661.ffi).mlx h → h < (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s661.ffi).mlx.next) (nltC : ∀ i, PN (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s661.ffi).mlx i → i < (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s661.ffi).mlx.nnext) (itemsC : ∀ k v, (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s661.ffi).mlx.items.get k = some v → PN (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s661.ffi).mlx k) (tracedC : ∀ h o, (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s661.ffi).mlx.objs.get h = some o → ∀ i ∈ objTraces o, i < PRE_first_tail_x15_r0_body.P68.NL) (cl : SSt (· < 2962) PRE_first_tail_x15_r0_body.cx0_68.mlx) :
    Conv.MFoot PRE_first_tail_x15_r0_body.P68 2962 PRE_first_tail_x15_r0_body.kappa68 PRE_first_tail_x15_r0_body.kd68 PRE_first_tail_x15_r0_body.khinv68 PRE_first_tail_x15_r0_body.kninv68 (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s661.ffi).mlx PRE_first_tail_x15_r0_body.cx0_68.mlx PRE_first_tail_x15_r0_body.cx1_68.mlx (⟨19533, 16633, 2727843, 2962⟩ : Conv.Cnt) PRE_first_tail_x15_r0_body.clo68 PRE_first_tail_x15_r0_body.cln68 PRE_first_tail_x15_r0_body.cli68 PRE_first_tail_x15_r0_body.cwS68 PRE_first_tail_x15_r0_body.cnS68 PRE_first_tail_x15_r0_body.ciS68 :=
  ⟨rfl, rfl, rfl, PRE_first_tail_x15_r0_body.cnh068, PRE_first_tail_x15_r0_body.cnh168, PRE_first_tail_x15_r0_body.cnn068, PRE_first_tail_x15_r0_body.cnn168, PRE_first_tail_x15_r0_body.cplo68, PRE_first_tail_x15_r0_body.ccnt68, PRE_first_tail_x15_r0_body.cnband68, PRE_first_tail_x15_r0_body.chbelow68, PRE_first_tail_x15_r0_body.chren68, PRE_first_tail_x15_r0_body.cband68, PRE_first_tail_x15_r0_body.cnh1pos68, PRE_first_tail_x15_r0_body.cnren68, PRE_first_tail_x15_r0_body.cnlow68, PRE_first_tail_x15_r0_body.cabs0a68, PRE_first_tail_x15_r0_body.cabs0b68, PRE_first_tail_x15_r0_body.ctok168, PRE_first_tail_x15_r0_body.cpend68, PRE_first_tail_x15_r0_body.cerrh68, PRE_first_tail_x15_r0_body.cfiles68, PRE_first_tail_x15_r0_body.carch68, PRE_first_tail_x15_r0_body.csizes68, PRE_first_tail_x15_r0_body.cwired68, PRE_first_tail_x15_r0_body.cfix68, clean, PRE_first_tail_x15_r0_body.fcxn68, PRE_first_tail_x15_r0_body.fcnn68, hltC, nltC, itemsC, tracedC, cl, PRE_first_tail_x15_r0_body.fle068, PRE_first_tail_x15_r0_body.fnk68, PRE_first_tail_x15_r0_body.ckA68, PRE_first_tail_x15_r0_body.cobjsK68, PRE_first_tail_x15_r0_body.cnodesK68, PRE_first_tail_x15_r0_body.citemsK68, PRE_first_tail_x15_r0_body.f1A68, PRE_first_tail_x15_r0_body.f1O68, PRE_first_tail_x15_r0_body.f1N68, PRE_first_tail_x15_r0_body.f1I68, PRE_first_tail_x15_r0_body.fbd68, PRE_first_tail_x15_r0_body.fincW68, PRE_first_tail_x15_r0_body.fincI68, PRE_first_tail_x15_r0_body.fincN68, PRE_first_tail_x15_r0_body.flnF68, PRE_first_tail_x15_r0_body.fh68, PRE_first_tail_x15_r0_body.fo68, PRE_first_tail_x15_r0_body.fok68, PRE_first_tail_x15_r0_body.fnd68, PRE_first_tail_x15_r0_body.fp68, PRE_first_tail_x15_r0_body.fnord68, PRE_first_tail_x15_r0_body.fi68, PRE_first_tail_x15_r0_body.fii68⟩
theorem PRE_first_tail_x15_r0_body.cnshift68 (clean : Conv.NClean (⟨19533, 16633, 2727843, 2962⟩ : Conv.Cnt) (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s661.ffi).mlx) (hltC : ∀ h, PH (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s661.ffi).mlx h → h < (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s661.ffi).mlx.next) (nltC : ∀ i, PN (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s661.ffi).mlx i → i < (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s661.ffi).mlx.nnext) (itemsC : ∀ k v, (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s661.ffi).mlx.items.get k = some v → PN (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s661.ffi).mlx k) (tracedC : ∀ h o, (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s661.ffi).mlx.objs.get h = some o → ∀ i ∈ objTraces o, i < PRE_first_tail_x15_r0_body.P68.NL) (cl : SSt (· < 2962) PRE_first_tail_x15_r0_body.cx0_68.mlx) : NShift PRE_first_tail_x15_r0_body.P68 2962 PRE_first_tail_x15_r0_body.kappa68 PRE_first_tail_x15_r0_body.cx0_68 PRE_first_tail_x15_r0_body.cx1_68 :=
  Conv.nshift_of_foot (PRE_first_tail_x15_r0_body.cfoot68 clean hltC nltC itemsC tracedC cl) PRE_first_tail_x15_r0_body.chost68 (compact_a_eq PRE_first_tail_x15_r0_body.ckn068 PRE_first_tail_x15_r0_body.ckn168 PRE_first_tail_x15_r0_body.ckheap68 PRE_first_tail_x15_r0_body.ckpl68)

-- the observers: the layers' states at the call, the canonical and the merged state, their footprints and checks
noncomputable def PRE_first_tail_x15_r0_body.fxC_68 : PTrie Unit := (Host.Ts.Sim.Full.freedOf PRE_first_tail_x15_r0_body.s661.ffi).getD PTrie.nil
noncomputable def PRE_first_tail_x15_r0_body.krC_68 : Host.Load.Layers.KRec := (Host.Ts.Sim.Full.krecOf PRE_first_tail_x15_r0_body.s661.ffi).getD Host.Load.Layers.KRec.empty
kernel_rfl PRE_first_tail_x15_r0_body.ofxC_68 : (Host.Ts.Sim.Full.freedOf PRE_first_tail_x15_r0_body.s661.ffi) = some PRE_first_tail_x15_r0_body.fxC_68
kernel_rfl PRE_first_tail_x15_r0_body.okrC_68 : (Host.Ts.Sim.Full.krecOf PRE_first_tail_x15_r0_body.s661.ffi) = some PRE_first_tail_x15_r0_body.krC_68
noncomputable def PRE_first_tail_x15_r0_body.fx0_68 : PTrie Unit := (Host.Ts.Sim.Full.freedOf PRE_first_tail_x15_r0_body.s663.ffi).getD PTrie.nil
noncomputable def PRE_first_tail_x15_r0_body.kr0_68 : Host.Load.Layers.KRec := (Host.Ts.Sim.Full.krecOf PRE_first_tail_x15_r0_body.s663.ffi).getD Host.Load.Layers.KRec.empty
kernel_rfl PRE_first_tail_x15_r0_body.ofx0_68 : (Host.Ts.Sim.Full.freedOf PRE_first_tail_x15_r0_body.s663.ffi) = some PRE_first_tail_x15_r0_body.fx0_68
kernel_rfl PRE_first_tail_x15_r0_body.okr0_68 : (Host.Ts.Sim.Full.krecOf PRE_first_tail_x15_r0_body.s663.ffi) = some PRE_first_tail_x15_r0_body.kr0_68
noncomputable def PRE_first_tail_x15_r0_body.fx1_68 : PTrie Unit := (Host.Ts.Sim.Full.freedOf PRE_first_tail_x15_r0_body.s662.ffi).getD PTrie.nil
noncomputable def PRE_first_tail_x15_r0_body.kr1_68 : Host.Load.Layers.KRec := (Host.Ts.Sim.Full.krecOf PRE_first_tail_x15_r0_body.s662.ffi).getD Host.Load.Layers.KRec.empty
kernel_rfl PRE_first_tail_x15_r0_body.ofx1_68 : (Host.Ts.Sim.Full.freedOf PRE_first_tail_x15_r0_body.s662.ffi) = some PRE_first_tail_x15_r0_body.fx1_68
kernel_rfl PRE_first_tail_x15_r0_body.okr1_68 : (Host.Ts.Sim.Full.krecOf PRE_first_tail_x15_r0_body.s662.ffi) = some PRE_first_tail_x15_r0_body.kr1_68
kernel_rfl PRE_first_tail_x15_r0_body.ff068 : PRE_first_tail_x15_r0_body.fx0_68 = Stage.setAll PRE_first_tail_x15_r0_body.fxC_68 (PRE_first_tail_x15_r0_body.clo68.filterMap fun i => (PRE_first_tail_x15_r0_body.fx0_68.get i).map (i, ·))
kernel_rfl PRE_first_tail_x15_r0_body.ff168 : PRE_first_tail_x15_r0_body.fx1_68 = Stage.setAll PRE_first_tail_x15_r0_body.fxC_68 (PRE_first_tail_x15_r0_body.cwS68.filterMap fun i => (PRE_first_tail_x15_r0_body.fx1_68.get i).map (i, ·))
kernel_rfl PRE_first_tail_x15_r0_body.ffck68 : freedLB PRE_first_tail_x15_r0_body.kappa68 PRE_first_tail_x15_r0_body.cx0_68.mlx PRE_first_tail_x15_r0_body.fx0_68 PRE_first_tail_x15_r0_body.fx1_68 PRE_first_tail_x15_r0_body.clo68 = true
kernel_rfl PRE_first_tail_x15_r0_body.fkf068 : PRE_first_tail_x15_r0_body.kr0_68.flags = Stage.setAll PRE_first_tail_x15_r0_body.krC_68.flags (PRE_first_tail_x15_r0_body.clo68.filterMap fun i => (PRE_first_tail_x15_r0_body.kr0_68.flags.get i).map (i, ·))
kernel_rfl PRE_first_tail_x15_r0_body.fkt068 : PRE_first_tail_x15_r0_body.kr0_68.targs = Stage.setAll PRE_first_tail_x15_r0_body.krC_68.targs (PRE_first_tail_x15_r0_body.clo68.filterMap fun i => (PRE_first_tail_x15_r0_body.kr0_68.targs.get i).map (i, ·))
kernel_rfl PRE_first_tail_x15_r0_body.fkf168 : PRE_first_tail_x15_r0_body.kr1_68.flags = Stage.setAll PRE_first_tail_x15_r0_body.krC_68.flags (PRE_first_tail_x15_r0_body.cwS68.filterMap fun i => (PRE_first_tail_x15_r0_body.kr1_68.flags.get i).map (i, ·))
kernel_rfl PRE_first_tail_x15_r0_body.fkt168 : PRE_first_tail_x15_r0_body.kr1_68.targs = Stage.setAll PRE_first_tail_x15_r0_body.krC_68.targs (PRE_first_tail_x15_r0_body.cwS68.filterMap fun i => (PRE_first_tail_x15_r0_body.kr1_68.targs.get i).map (i, ·))
kernel_rfl PRE_first_tail_x15_r0_body.fkck68 : krecLB PRE_first_tail_x15_r0_body.kappa68 2962 PRE_first_tail_x15_r0_body.cx0_68.mlx PRE_first_tail_x15_r0_body.kr0_68 PRE_first_tail_x15_r0_body.kr1_68 PRE_first_tail_x15_r0_body.clo68 = true
kernel_rfl PRE_first_tail_x15_r0_body.fkn68 : Nat.ble 2962 2962 = true
-- the bridge and the pending traces' regions
kernel_rfl PRE_first_tail_x15_r0_body.cbridge68 : Host.Ts.Sim.Full.bridgeOf PRE_first_tail_x15_r0_body.s662.ffi = Host.Ts.Sim.Full.bridgeOf PRE_first_tail_x15_r0_body.s663.ffi
kernel_rfl PRE_first_tail_x15_r0_body.cpendR68 : pendRegB PRE_first_tail_x15_r0_body.kappa68 (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s663.ffi).mlx = true
kernel_rfl PRE_first_tail_x15_r0_body.cpendLe68 : Nat.ble (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s663.ffi).mlx.next (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s662.ffi).mlx.next = true
/-- **The compaction's native shift**, given the call's bookkeeping, its relation's facts (the model's and the
observers') and the canonical closedness. -/
theorem PRE_first_tail_x15_r0_body.cshift68 (clean : Conv.NClean (⟨19533, 16633, 2727843, 2962⟩ : Conv.Cnt) (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s661.ffi).mlx) (hltC : ∀ h, PH (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s661.ffi).mlx h → h < (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s661.ffi).mlx.next) (nltC : ∀ i, PN (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s661.ffi).mlx i → i < (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s661.ffi).mlx.nnext) (itemsC : ∀ k v, (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s661.ffi).mlx.items.get k = some v → PN (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s661.ffi).mlx k) (tracedC : ∀ h o, (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s661.ffi).mlx.objs.get h = some o → ∀ i ∈ objTraces o, i < PRE_first_tail_x15_r0_body.P68.NL) (cl : SSt (· < 2962) PRE_first_tail_x15_r0_body.cx0_68.mlx)
    (hobjC : ∀ h, PRE_first_tail_x15_r0_body.fxC_68.get h = some () → ((Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s661.ffi).mlx.objs.get h).isSome = true)
    (hfC : ∀ h, (PRE_first_tail_x15_r0_body.krC_68.flags.get h).isSome = true → ((Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s661.ffi).mlx.objs.get h).isSome = true)
    (htC : ∀ h, (PRE_first_tail_x15_r0_body.krC_68.targs.get h).isSome = true → ((Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s661.ffi).mlx.objs.get h).isSome = true)
    (hclC : ∀ h l, PRE_first_tail_x15_r0_body.krC_68.targs.get h = some l → Host.Ts.Sim.Full.STargs (· < (⟨19533, 16633, 2727843, 2962⟩ : Conv.Cnt).n) l) :
    Conv.FullShiftQ PRE_first_tail_x15_r0_body.P68 2962 PRE_first_tail_x15_r0_body.kappa68 PRE_first_tail_x15_r0_body.s663.ffi PRE_first_tail_x15_r0_body.s662.ffi :=
  ⟨PRE_first_tail_x15_r0_body.cnshift68 clean hltC nltC itemsC tracedC cl, PRE_first_tail_x15_r0_body.cqueue68, fun t ht => bSN_sound (List.all_eq_true.mp PRE_first_tail_x15_r0_body.ctokSupp68 t ht),
    PRE_first_tail_x15_r0_body.cbridge68,
    liveShift_foot (x0' := Host.Ts.Sim.Full.mlxOf PRE_first_tail_x15_r0_body.s663.ffi) (x1' := Host.Ts.Sim.Full.mlxOf PRE_first_tail_x15_r0_body.s662.ffi) (PRE_first_tail_x15_r0_body.cfoot68 clean hltC nltC itemsC tracedC cl) rfl PRE_first_tail_x15_r0_body.ofx0_68 PRE_first_tail_x15_r0_body.ofx1_68 hobjC PRE_first_tail_x15_r0_body.ff068 PRE_first_tail_x15_r0_body.ff168 PRE_first_tail_x15_r0_body.ffck68,
    kernShift_foot (x0' := Host.Ts.Sim.Full.mlxOf PRE_first_tail_x15_r0_body.s663.ffi) (x1' := Host.Ts.Sim.Full.mlxOf PRE_first_tail_x15_r0_body.s662.ffi) (PRE_first_tail_x15_r0_body.cfoot68 clean hltC nltC itemsC tracedC cl) rfl PRE_first_tail_x15_r0_body.okr0_68 PRE_first_tail_x15_r0_body.okr1_68 (Nat.le_of_ble_eq_true PRE_first_tail_x15_r0_body.fkn68) hfC htC hclC
      PRE_first_tail_x15_r0_body.fkf068 PRE_first_tail_x15_r0_body.fkt068 PRE_first_tail_x15_r0_body.fkf168 PRE_first_tail_x15_r0_body.fkt168 PRE_first_tail_x15_r0_body.fkck68,
    pendReg_of rfl PRE_first_tail_x15_r0_body.cnh068 PRE_first_tail_x15_r0_body.cnh168 (Nat.le_of_ble_eq_true PRE_first_tail_x15_r0_body.cpendLe68) PRE_first_tail_x15_r0_body.cpendR68⟩

end Host.Load.Run.Tpl
