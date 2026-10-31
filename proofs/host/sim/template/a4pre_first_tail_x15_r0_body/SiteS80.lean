import host.sim.template.a4pre_first_tail_x15_r0_body.SiteCl80
import host.sim.conv.CompactFull
import host.sim.template.FootGen
set_option Elab.async false
namespace Host.Load.Run.Tpl
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
open Host.Ts Host.Ts.Sim Host.Ts.Sim.Template

/-! The compaction's native shift at call site 80 from its footprint (`Conv.nshift_of_foot`), and the observers'
(`liveShift_foot`, `kernShift_foot`): `Conv.FullShiftQ` for `Conv.full_compactQ`, given the call's bookkeeping and its
relation's facts. -/

/-- The load parameters of the chain (band-free: its start's node counter as `NL` and `N0`). -/
def PRE_first_tail_x15_r0_body.Pc80 : LoadP := ⟨18151, 131072, 1099511627776, 15235, 15235, []⟩
/-- The site's band raised to the map's checked fixed-node prefix, including newly recorded closure traces. -/
def PRE_first_tail_x15_r0_body.P80 : LoadP := PRE_first_tail_x15_r0_body.Pc80.raise 16870
kernel_rfl PRE_first_tail_x15_r0_body.craise80 : Nat.ble PRE_first_tail_x15_r0_body.Pc80.N0 16870 = true
theorem PRE_first_tail_x15_r0_body.raised80 : Host.Ts.Sim.Full.Raised PRE_first_tail_x15_r0_body.Pc80 PRE_first_tail_x15_r0_body.P80 :=
  .inr ⟨16870, rfl, Nat.le_of_ble_eq_true PRE_first_tail_x15_r0_body.craise80, rfl⟩
noncomputable abbrev PRE_first_tail_x15_r0_body.cx0_80 : Host.Load.LSt := clearTokens (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s778.ffi)
noncomputable abbrev PRE_first_tail_x15_r0_body.cx1_80 : Host.Load.LSt := clearTokens (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s777.ffi)
def PRE_first_tail_x15_r0_body.khinv80 : PTrie Nat := Stage.setAll PTrie.nil []
def PRE_first_tail_x15_r0_body.kninv80 : PTrie Nat := Stage.setAll PTrie.nil []
/-- The stage's footprint: its written and fresh handles, fresh nodes, written and fresh items. -/
def PRE_first_tail_x15_r0_body.cwS80 : List Nat := []
def PRE_first_tail_x15_r0_body.cnS80 : List Nat := List.range' 16870 0
def PRE_first_tail_x15_r0_body.ciS80 : List Nat := [] ++ List.range' 16870 0

-- the small checks (`MChecks`'s)
kernel_rfl PRE_first_tail_x15_r0_body.cnh080 : PRE_first_tail_x15_r0_body.kd80.nh0 = PRE_first_tail_x15_r0_body.cx0_80.mlx.next
kernel_rfl PRE_first_tail_x15_r0_body.cnh180 : PRE_first_tail_x15_r0_body.kd80.nh1 = PRE_first_tail_x15_r0_body.cx1_80.mlx.next
kernel_rfl PRE_first_tail_x15_r0_body.cnn080 : PRE_first_tail_x15_r0_body.kd80.nn0 = PRE_first_tail_x15_r0_body.cx0_80.mlx.nnext
kernel_rfl PRE_first_tail_x15_r0_body.cnn180 : PRE_first_tail_x15_r0_body.kd80.nn1 = PRE_first_tail_x15_r0_body.cx1_80.mlx.nnext
kernel_rfl PRE_first_tail_x15_r0_body.cplo80 : (Nat.blt 0 PRE_first_tail_x15_r0_body.P80.lo && Nat.ble PRE_first_tail_x15_r0_body.P80.lo PRE_first_tail_x15_r0_body.cx0_80.mlx.next && Nat.ble PRE_first_tail_x15_r0_body.P80.lo RData.bigHi && Nat.ble RData.bigHi PRE_first_tail_x15_r0_body.P80.E) = true
kernel_rfl PRE_first_tail_x15_r0_body.ccnt80 : (Nat.ble PRE_first_tail_x15_r0_body.cx0_80.mlx.next PRE_first_tail_x15_r0_body.cx1_80.mlx.next && Nat.ble PRE_first_tail_x15_r0_body.cx0_80.mlx.nnext PRE_first_tail_x15_r0_body.cx1_80.mlx.nnext) = true
kernel_rfl PRE_first_tail_x15_r0_body.cnband80 : (Nat.blt 0 PRE_first_tail_x15_r0_body.P80.NL && Nat.ble PRE_first_tail_x15_r0_body.P80.NL PRE_first_tail_x15_r0_body.P80.N0 && Nat.ble PRE_first_tail_x15_r0_body.P80.N0 PRE_first_tail_x15_r0_body.cx0_80.mlx.nnext) = true
kernel_rfl PRE_first_tail_x15_r0_body.chbelow80 : PRE_first_tail_x15_r0_body.kd80.checkHndBelow = true
kernel_rfl PRE_first_tail_x15_r0_body.chren80 : checkRenG PRE_first_tail_x15_r0_body.kd80.hnd PRE_first_tail_x15_r0_body.khinv80 (phB PRE_first_tail_x15_r0_body.cx0_80.mlx) = true
kernel_rfl PRE_first_tail_x15_r0_body.cband80 : PRE_first_tail_x15_r0_body.kd80.checkBand PRE_first_tail_x15_r0_body.P80.lo = true
kernel_rfl PRE_first_tail_x15_r0_body.cnh1pos80 : Nat.blt 0 PRE_first_tail_x15_r0_body.kd80.nh1 = true
kernel_rfl PRE_first_tail_x15_r0_body.cnren80 : checkRenG PRE_first_tail_x15_r0_body.kd80.node PRE_first_tail_x15_r0_body.kninv80 (pnB PRE_first_tail_x15_r0_body.cx0_80.mlx) = true
kernel_rfl PRE_first_tail_x15_r0_body.cnlow80 : (PTrie.keysA PRE_first_tail_x15_r0_body.kd80.node).all (fun j => Nat.ble PRE_first_tail_x15_r0_body.P80.NL j && Nat.blt (PRE_first_tail_x15_r0_body.kd80.nodeF j) PRE_first_tail_x15_r0_body.cx1_80.mlx.nnext) = true
kernel_rfl PRE_first_tail_x15_r0_body.cabs0a80 : PRE_first_tail_x15_r0_body.cx0_80.mlx.arrs.get 0 = none
kernel_rfl PRE_first_tail_x15_r0_body.cabs0b80 : PRE_first_tail_x15_r0_body.cx0_80.mlx.objs.get 0 = none
kernel_rfl PRE_first_tail_x15_r0_body.ctok180 : PRE_first_tail_x15_r0_body.cx1_80.mlx.tokens = []
kernel_rfl PRE_first_tail_x15_r0_body.cpend80 : PRE_first_tail_x15_r0_body.cx1_80.mlx.pending = PRE_first_tail_x15_r0_body.cx0_80.mlx.pending.map PRE_first_tail_x15_r0_body.kappa80.pend
kernel_rfl PRE_first_tail_x15_r0_body.cerrh80 : PRE_first_tail_x15_r0_body.cx1_80.mlx.errh = PRE_first_tail_x15_r0_body.cx0_80.mlx.errh.map PRE_first_tail_x15_r0_body.kappa80.arg
kernel_rfl PRE_first_tail_x15_r0_body.cfiles80 : PRE_first_tail_x15_r0_body.cx1_80.mlx.files = PRE_first_tail_x15_r0_body.cx0_80.mlx.files
kernel_rfl PRE_first_tail_x15_r0_body.carch80 : PRE_first_tail_x15_r0_body.cx1_80.mlx.arch = PRE_first_tail_x15_r0_body.cx0_80.mlx.arch
kernel_rfl PRE_first_tail_x15_r0_body.csizes80 : PRE_first_tail_x15_r0_body.cx1_80.mlx.deviceSizes = PRE_first_tail_x15_r0_body.cx0_80.mlx.deviceSizes
kernel_rfl PRE_first_tail_x15_r0_body.cwired80 : PRE_first_tail_x15_r0_body.cx1_80.mlx.wired = PRE_first_tail_x15_r0_body.cx0_80.mlx.wired
kernel_rfl PRE_first_tail_x15_r0_body.chost80 : PRE_first_tail_x15_r0_body.cx1_80.host = PRE_first_tail_x15_r0_body.cx0_80.host
-- the compaction map's addresses are `PRE_first_tail_x15_r0_body.kd80`'s
kernel_rfl PRE_first_tail_x15_r0_body.ckn080 : PRE_first_tail_x15_r0_body.kd80.n0 = 2737256
kernel_rfl PRE_first_tail_x15_r0_body.ckn180 : PRE_first_tail_x15_r0_body.kd80.n1 = 2737266
kernel_rfl PRE_first_tail_x15_r0_body.ckheap80 : (PTrie.keysA PRE_first_tail_x15_r0_body.kd80.heap).all (fun x => Nat.ble 2737255 x) = true
kernel_rfl PRE_first_tail_x15_r0_body.ckpl80 : (List.range 1).all (fun j => decide (PRE_first_tail_x15_r0_body.kd80.heap.get (2737255 + j) = nth? PRE_first_tail_x15_r0_body.pl80 j)) = true
-- the map fixes the call's names (`Conv.fixOld_compact`), the call's counters
kernel_rfl PRE_first_tail_x15_r0_body.fja80 : Nat.ble 2737255 2737255 = true
kernel_rfl PRE_first_tail_x15_r0_body.fn80 : Nat.ble 3475 3475 = true
kernel_rfl PRE_first_tail_x15_r0_body.fjaD80 : Nat.ble 2737255 PRE_first_tail_x15_r0_body.kd80.n0 = true
kernel_rfl PRE_first_tail_x15_r0_body.fxn80 : Nat.ble 19769 PRE_first_tail_x15_r0_body.kd80.nh0 = true
kernel_rfl PRE_first_tail_x15_r0_body.fnn80 : Nat.ble 16870 PRE_first_tail_x15_r0_body.kd80.nn0 = true
kernel_rfl PRE_first_tail_x15_r0_body.fxb80 : Nat.ble 19769 RData.bigHi = true
kernel_rfl PRE_first_tail_x15_r0_body.fheap80 : (PTrie.keysA PRE_first_tail_x15_r0_body.kd80.heap).all (Nat.ble (⟨19769, 16870, 2737255, 3475⟩ : Conv.Cnt).ja) = true
kernel_rfl PRE_first_tail_x15_r0_body.fhnd80 : (PTrie.keysA PRE_first_tail_x15_r0_body.kd80.hnd).all (Nat.ble (⟨19769, 16870, 2737255, 3475⟩ : Conv.Cnt).xn) = true
kernel_rfl PRE_first_tail_x15_r0_body.fnode80 : (PTrie.keysA PRE_first_tail_x15_r0_body.kd80.node).all (Nat.ble (⟨19769, 16870, 2737255, 3475⟩ : Conv.Cnt).nn) = true
/-- The compaction map fixes the call's names. -/
theorem PRE_first_tail_x15_r0_body.cfix80 : Conv.FixOld (⟨19769, 16870, 2737255, 3475⟩ : Conv.Cnt) PRE_first_tail_x15_r0_body.kappa80 :=
  Conv.fixOld_compact (Nat.le_of_ble_eq_true PRE_first_tail_x15_r0_body.fja80) (Nat.le_of_ble_eq_true PRE_first_tail_x15_r0_body.fn80) (Nat.le_of_ble_eq_true PRE_first_tail_x15_r0_body.fjaD80) (Nat.le_of_ble_eq_true PRE_first_tail_x15_r0_body.fxn80) (Nat.le_of_ble_eq_true PRE_first_tail_x15_r0_body.fnn80) (Nat.le_of_ble_eq_true PRE_first_tail_x15_r0_body.fxb80) PRE_first_tail_x15_r0_body.fheap80 PRE_first_tail_x15_r0_body.fhnd80 PRE_first_tail_x15_r0_body.fnode80
kernel_rfl PRE_first_tail_x15_r0_body.fcxn80 : (⟨19769, 16870, 2737255, 3475⟩ : Conv.Cnt).xn = (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s776.ffi).mlx.next
kernel_rfl PRE_first_tail_x15_r0_body.fcnn80 : (⟨19769, 16870, 2737255, 3475⟩ : Conv.Cnt).nn = (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s776.ffi).mlx.nnext
kernel_rfl PRE_first_tail_x15_r0_body.fle080 : (Nat.ble (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s776.ffi).mlx.next PRE_first_tail_x15_r0_body.cx0_80.mlx.next && Nat.ble (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s776.ffi).mlx.nnext PRE_first_tail_x15_r0_body.cx0_80.mlx.nnext && Nat.ble (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s776.ffi).mlx.next RData.bigHi) = true
kernel_rfl PRE_first_tail_x15_r0_body.fnk80 : (PTrie.keysA PRE_first_tail_x15_r0_body.kd80.node).all (Nat.ble (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s776.ffi).mlx.nnext) = true
-- the merged state keeps the call's entries off the stage's footprint
kernel_rfl PRE_first_tail_x15_r0_body.f1A80 : PRE_first_tail_x15_r0_body.cx1_80.mlx.arrs = Stage.setAll (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s776.ffi).mlx.arrs (PRE_first_tail_x15_r0_body.cwS80.filterMap fun i => (PRE_first_tail_x15_r0_body.cx1_80.mlx.arrs.get i).map (i, ·))
kernel_rfl PRE_first_tail_x15_r0_body.f1O80 : PRE_first_tail_x15_r0_body.cx1_80.mlx.objs = Stage.setAll (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s776.ffi).mlx.objs (PRE_first_tail_x15_r0_body.cwS80.filterMap fun i => (PRE_first_tail_x15_r0_body.cx1_80.mlx.objs.get i).map (i, ·))
kernel_rfl PRE_first_tail_x15_r0_body.f1N80 : PRE_first_tail_x15_r0_body.cx1_80.mlx.nodes = Stage.setAll (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s776.ffi).mlx.nodes (PRE_first_tail_x15_r0_body.cnS80.filterMap fun i => (PRE_first_tail_x15_r0_body.cx1_80.mlx.nodes.get i).map (i, ·))
kernel_rfl PRE_first_tail_x15_r0_body.f1I80 : PRE_first_tail_x15_r0_body.cx1_80.mlx.items = Stage.setAll (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s776.ffi).mlx.items (PRE_first_tail_x15_r0_body.ciS80.filterMap fun i => (PRE_first_tail_x15_r0_body.cx1_80.mlx.items.get i).map (i, ·))
kernel_rfl PRE_first_tail_x15_r0_body.fbd80 : (PRE_first_tail_x15_r0_body.clo80 ++ PRE_first_tail_x15_r0_body.cln80 ++ PRE_first_tail_x15_r0_body.cli80 ++ PRE_first_tail_x15_r0_body.cwS80 ++ PRE_first_tail_x15_r0_body.cnS80 ++ PRE_first_tail_x15_r0_body.ciS80).all (fun i => Nat.blt (i / 4096) (4 ^ 31)) = true
kernel_rfl PRE_first_tail_x15_r0_body.fincW80 : PRE_first_tail_x15_r0_body.cwS80.all (fun h => !Nat.blt h (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s776.ffi).mlx.next || PRE_first_tail_x15_r0_body.clo80.contains h) = true
kernel_rfl PRE_first_tail_x15_r0_body.fincI80 : PRE_first_tail_x15_r0_body.ciS80.all (fun k => !Nat.blt k (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s776.ffi).mlx.nnext || PRE_first_tail_x15_r0_body.cli80.contains k) = true
kernel_rfl PRE_first_tail_x15_r0_body.fincN80 : PRE_first_tail_x15_r0_body.cnS80.all (Nat.ble (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s776.ffi).mlx.nnext) = true
kernel_rfl PRE_first_tail_x15_r0_body.flnF80 : PRE_first_tail_x15_r0_body.cln80.all (Nat.ble (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s776.ffi).mlx.nnext) = true
-- the checks over the changed lists
kernel_rfl PRE_first_tail_x15_r0_body.fh80 : PRE_first_tail_x15_r0_body.clo80.all (handleOK PRE_first_tail_x15_r0_body.kappa80 PRE_first_tail_x15_r0_body.P80.lo PRE_first_tail_x15_r0_body.cx0_80.mlx PRE_first_tail_x15_r0_body.cx1_80.mlx) = true
kernel_rfl PRE_first_tail_x15_r0_body.fo80 : PRE_first_tail_x15_r0_body.clo80.map (fun h => PRE_first_tail_x15_r0_body.cx1_80.mlx.objs.get (PRE_first_tail_x15_r0_body.kappa80.handle h)) = PRE_first_tail_x15_r0_body.clo80.map (fun h => (PRE_first_tail_x15_r0_body.cx0_80.mlx.objs.get h).map PRE_first_tail_x15_r0_body.kappa80.nobj)
kernel_rfl PRE_first_tail_x15_r0_body.fok80 : PRE_first_tail_x15_r0_body.clo80.all (objOK PRE_first_tail_x15_r0_body.kappa80 PRE_first_tail_x15_r0_body.P80.NL PRE_first_tail_x15_r0_body.cx0_80.mlx) = true
kernel_rfl PRE_first_tail_x15_r0_body.fnd80 : PRE_first_tail_x15_r0_body.cln80.all (nodeOKF PRE_first_tail_x15_r0_body.kappa80 PRE_first_tail_x15_r0_body.P80 PRE_first_tail_x15_r0_body.cx0_80.mlx PRE_first_tail_x15_r0_body.cx1_80.mlx) = true
kernel_rfl PRE_first_tail_x15_r0_body.fp80 : ((PRE_first_tail_x15_r0_body.cln80.filter (fullB PRE_first_tail_x15_r0_body.P80))).map (fun i => (PRE_first_tail_x15_r0_body.cx1_80.mlx.nodes.get (PRE_first_tail_x15_r0_body.kappa80.node i)).map Host.Mlx.Ffi.Node.prim) =
  ((PRE_first_tail_x15_r0_body.cln80.filter (fullB PRE_first_tail_x15_r0_body.P80))).map (fun i => (PRE_first_tail_x15_r0_body.cx0_80.mlx.nodes.get i).map fun nd => PRE_first_tail_x15_r0_body.kappa80.prim nd.prim)
kernel_rfl PRE_first_tail_x15_r0_body.fnordI80 : incrB PRE_first_tail_x15_r0_body.kd80.nodeF (List.range' 16870 0) = true
kernel_rfl PRE_first_tail_x15_r0_body.fnordK80 : (PTrie.keysA PRE_first_tail_x15_r0_body.kd80.node).all (fun k => Nat.ble 16870 k && Nat.blt k 16870) = true
kernel_rfl PRE_first_tail_x15_r0_body.fnordL80 : (PRE_first_tail_x15_r0_body.cln80.filter (Nat.ble PRE_first_tail_x15_r0_body.P80.N0)).all (fun i => Nat.ble i (PRE_first_tail_x15_r0_body.kd80.nodeF i) && (Nat.blt i 16870 || Nat.ble PRE_first_tail_x15_r0_body.kd80.nn0 i)) = true
theorem PRE_first_tail_x15_r0_body.fnord80 : (PRE_first_tail_x15_r0_body.cln80.filter (Nat.ble PRE_first_tail_x15_r0_body.P80.N0)).all (fun i => Nat.ble i (PRE_first_tail_x15_r0_body.kd80.nodeF i) &&
    (PTrie.keysA PRE_first_tail_x15_r0_body.kd80.node).all fun j => !Nat.blt j i || Nat.blt (PRE_first_tail_x15_r0_body.kd80.nodeF j) (PRE_first_tail_x15_r0_body.kd80.nodeF i)) = true :=
  cnord_of PRE_first_tail_x15_r0_body.cnlow80 PRE_first_tail_x15_r0_body.cnn180 PRE_first_tail_x15_r0_body.fnordI80 PRE_first_tail_x15_r0_body.fnordK80 PRE_first_tail_x15_r0_body.fnordL80
kernel_rfl PRE_first_tail_x15_r0_body.fi80 : PRE_first_tail_x15_r0_body.cli80.all (pnB PRE_first_tail_x15_r0_body.cx0_80.mlx) = true
kernel_rfl PRE_first_tail_x15_r0_body.fii80 : PRE_first_tail_x15_r0_body.cli80.all (fun k => decide (PRE_first_tail_x15_r0_body.cx1_80.mlx.items.get (PRE_first_tail_x15_r0_body.kappa80.node k) = (PRE_first_tail_x15_r0_body.cx0_80.mlx.items.get k).map PRE_first_tail_x15_r0_body.kappa80.nv)) = true
/-- **The compaction's footprint.** -/
theorem PRE_first_tail_x15_r0_body.cfoot80 (clean : Conv.NClean (⟨19769, 16870, 2737255, 3475⟩ : Conv.Cnt) (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s776.ffi).mlx) (hltC : ∀ h, PH (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s776.ffi).mlx h → h < (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s776.ffi).mlx.next) (nltC : ∀ i, PN (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s776.ffi).mlx i → i < (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s776.ffi).mlx.nnext) (itemsC : ∀ k v, (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s776.ffi).mlx.items.get k = some v → PN (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s776.ffi).mlx k) (tracedC : ∀ h o, (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s776.ffi).mlx.objs.get h = some o → ∀ i ∈ objTraces o, i < PRE_first_tail_x15_r0_body.P80.NL) (cl : SSt (· < 3475) PRE_first_tail_x15_r0_body.cx0_80.mlx) :
    Conv.MFoot PRE_first_tail_x15_r0_body.P80 3475 PRE_first_tail_x15_r0_body.kappa80 PRE_first_tail_x15_r0_body.kd80 PRE_first_tail_x15_r0_body.khinv80 PRE_first_tail_x15_r0_body.kninv80 (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s776.ffi).mlx PRE_first_tail_x15_r0_body.cx0_80.mlx PRE_first_tail_x15_r0_body.cx1_80.mlx (⟨19769, 16870, 2737255, 3475⟩ : Conv.Cnt) PRE_first_tail_x15_r0_body.clo80 PRE_first_tail_x15_r0_body.cln80 PRE_first_tail_x15_r0_body.cli80 PRE_first_tail_x15_r0_body.cwS80 PRE_first_tail_x15_r0_body.cnS80 PRE_first_tail_x15_r0_body.ciS80 :=
  ⟨rfl, rfl, rfl, PRE_first_tail_x15_r0_body.cnh080, PRE_first_tail_x15_r0_body.cnh180, PRE_first_tail_x15_r0_body.cnn080, PRE_first_tail_x15_r0_body.cnn180, PRE_first_tail_x15_r0_body.cplo80, PRE_first_tail_x15_r0_body.ccnt80, PRE_first_tail_x15_r0_body.cnband80, PRE_first_tail_x15_r0_body.chbelow80, PRE_first_tail_x15_r0_body.chren80, PRE_first_tail_x15_r0_body.cband80, PRE_first_tail_x15_r0_body.cnh1pos80, PRE_first_tail_x15_r0_body.cnren80, PRE_first_tail_x15_r0_body.cnlow80, PRE_first_tail_x15_r0_body.cabs0a80, PRE_first_tail_x15_r0_body.cabs0b80, PRE_first_tail_x15_r0_body.ctok180, PRE_first_tail_x15_r0_body.cpend80, PRE_first_tail_x15_r0_body.cerrh80, PRE_first_tail_x15_r0_body.cfiles80, PRE_first_tail_x15_r0_body.carch80, PRE_first_tail_x15_r0_body.csizes80, PRE_first_tail_x15_r0_body.cwired80, PRE_first_tail_x15_r0_body.cfix80, clean, PRE_first_tail_x15_r0_body.fcxn80, PRE_first_tail_x15_r0_body.fcnn80, hltC, nltC, itemsC, tracedC, cl, PRE_first_tail_x15_r0_body.fle080, PRE_first_tail_x15_r0_body.fnk80, PRE_first_tail_x15_r0_body.ckA80, PRE_first_tail_x15_r0_body.cobjsK80, PRE_first_tail_x15_r0_body.cnodesK80, PRE_first_tail_x15_r0_body.citemsK80, PRE_first_tail_x15_r0_body.f1A80, PRE_first_tail_x15_r0_body.f1O80, PRE_first_tail_x15_r0_body.f1N80, PRE_first_tail_x15_r0_body.f1I80, PRE_first_tail_x15_r0_body.fbd80, PRE_first_tail_x15_r0_body.fincW80, PRE_first_tail_x15_r0_body.fincI80, PRE_first_tail_x15_r0_body.fincN80, PRE_first_tail_x15_r0_body.flnF80, PRE_first_tail_x15_r0_body.fh80, PRE_first_tail_x15_r0_body.fo80, PRE_first_tail_x15_r0_body.fok80, PRE_first_tail_x15_r0_body.fnd80, PRE_first_tail_x15_r0_body.fp80, PRE_first_tail_x15_r0_body.fnord80, PRE_first_tail_x15_r0_body.fi80, PRE_first_tail_x15_r0_body.fii80⟩
theorem PRE_first_tail_x15_r0_body.cnshift80 (clean : Conv.NClean (⟨19769, 16870, 2737255, 3475⟩ : Conv.Cnt) (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s776.ffi).mlx) (hltC : ∀ h, PH (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s776.ffi).mlx h → h < (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s776.ffi).mlx.next) (nltC : ∀ i, PN (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s776.ffi).mlx i → i < (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s776.ffi).mlx.nnext) (itemsC : ∀ k v, (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s776.ffi).mlx.items.get k = some v → PN (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s776.ffi).mlx k) (tracedC : ∀ h o, (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s776.ffi).mlx.objs.get h = some o → ∀ i ∈ objTraces o, i < PRE_first_tail_x15_r0_body.P80.NL) (cl : SSt (· < 3475) PRE_first_tail_x15_r0_body.cx0_80.mlx) : NShift PRE_first_tail_x15_r0_body.P80 3475 PRE_first_tail_x15_r0_body.kappa80 PRE_first_tail_x15_r0_body.cx0_80 PRE_first_tail_x15_r0_body.cx1_80 :=
  Conv.nshift_of_foot (PRE_first_tail_x15_r0_body.cfoot80 clean hltC nltC itemsC tracedC cl) PRE_first_tail_x15_r0_body.chost80 (compact_a_eq PRE_first_tail_x15_r0_body.ckn080 PRE_first_tail_x15_r0_body.ckn180 PRE_first_tail_x15_r0_body.ckheap80 PRE_first_tail_x15_r0_body.ckpl80)

-- the observers: the layers' states at the call, the canonical and the merged state, their footprints and checks
noncomputable def PRE_first_tail_x15_r0_body.fxC_80 : PTrie Unit := (Host.Ts.Sim.Full.freedOf PRE_first_tail_x15_r0_body.s776.ffi).getD PTrie.nil
noncomputable def PRE_first_tail_x15_r0_body.krC_80 : Host.Load.Layers.KRec := (Host.Ts.Sim.Full.krecOf PRE_first_tail_x15_r0_body.s776.ffi).getD Host.Load.Layers.KRec.empty
kernel_rfl PRE_first_tail_x15_r0_body.ofxC_80 : (Host.Ts.Sim.Full.freedOf PRE_first_tail_x15_r0_body.s776.ffi) = some PRE_first_tail_x15_r0_body.fxC_80
kernel_rfl PRE_first_tail_x15_r0_body.okrC_80 : (Host.Ts.Sim.Full.krecOf PRE_first_tail_x15_r0_body.s776.ffi) = some PRE_first_tail_x15_r0_body.krC_80
noncomputable def PRE_first_tail_x15_r0_body.fx0_80 : PTrie Unit := (Host.Ts.Sim.Full.freedOf PRE_first_tail_x15_r0_body.s778.ffi).getD PTrie.nil
noncomputable def PRE_first_tail_x15_r0_body.kr0_80 : Host.Load.Layers.KRec := (Host.Ts.Sim.Full.krecOf PRE_first_tail_x15_r0_body.s778.ffi).getD Host.Load.Layers.KRec.empty
kernel_rfl PRE_first_tail_x15_r0_body.ofx0_80 : (Host.Ts.Sim.Full.freedOf PRE_first_tail_x15_r0_body.s778.ffi) = some PRE_first_tail_x15_r0_body.fx0_80
kernel_rfl PRE_first_tail_x15_r0_body.okr0_80 : (Host.Ts.Sim.Full.krecOf PRE_first_tail_x15_r0_body.s778.ffi) = some PRE_first_tail_x15_r0_body.kr0_80
noncomputable def PRE_first_tail_x15_r0_body.fx1_80 : PTrie Unit := (Host.Ts.Sim.Full.freedOf PRE_first_tail_x15_r0_body.s777.ffi).getD PTrie.nil
noncomputable def PRE_first_tail_x15_r0_body.kr1_80 : Host.Load.Layers.KRec := (Host.Ts.Sim.Full.krecOf PRE_first_tail_x15_r0_body.s777.ffi).getD Host.Load.Layers.KRec.empty
kernel_rfl PRE_first_tail_x15_r0_body.ofx1_80 : (Host.Ts.Sim.Full.freedOf PRE_first_tail_x15_r0_body.s777.ffi) = some PRE_first_tail_x15_r0_body.fx1_80
kernel_rfl PRE_first_tail_x15_r0_body.okr1_80 : (Host.Ts.Sim.Full.krecOf PRE_first_tail_x15_r0_body.s777.ffi) = some PRE_first_tail_x15_r0_body.kr1_80
kernel_rfl PRE_first_tail_x15_r0_body.ff080 : PRE_first_tail_x15_r0_body.fx0_80 = Stage.setAll PRE_first_tail_x15_r0_body.fxC_80 (PRE_first_tail_x15_r0_body.clo80.filterMap fun i => (PRE_first_tail_x15_r0_body.fx0_80.get i).map (i, ·))
kernel_rfl PRE_first_tail_x15_r0_body.ff180 : PRE_first_tail_x15_r0_body.fx1_80 = Stage.setAll PRE_first_tail_x15_r0_body.fxC_80 (PRE_first_tail_x15_r0_body.cwS80.filterMap fun i => (PRE_first_tail_x15_r0_body.fx1_80.get i).map (i, ·))
kernel_rfl PRE_first_tail_x15_r0_body.ffck80 : freedLB PRE_first_tail_x15_r0_body.kappa80 PRE_first_tail_x15_r0_body.cx0_80.mlx PRE_first_tail_x15_r0_body.fx0_80 PRE_first_tail_x15_r0_body.fx1_80 PRE_first_tail_x15_r0_body.clo80 = true
kernel_rfl PRE_first_tail_x15_r0_body.fkf080 : PRE_first_tail_x15_r0_body.kr0_80.flags = Stage.setAll PRE_first_tail_x15_r0_body.krC_80.flags (PRE_first_tail_x15_r0_body.clo80.filterMap fun i => (PRE_first_tail_x15_r0_body.kr0_80.flags.get i).map (i, ·))
kernel_rfl PRE_first_tail_x15_r0_body.fkt080 : PRE_first_tail_x15_r0_body.kr0_80.targs = Stage.setAll PRE_first_tail_x15_r0_body.krC_80.targs (PRE_first_tail_x15_r0_body.clo80.filterMap fun i => (PRE_first_tail_x15_r0_body.kr0_80.targs.get i).map (i, ·))
kernel_rfl PRE_first_tail_x15_r0_body.fkf180 : PRE_first_tail_x15_r0_body.kr1_80.flags = Stage.setAll PRE_first_tail_x15_r0_body.krC_80.flags (PRE_first_tail_x15_r0_body.cwS80.filterMap fun i => (PRE_first_tail_x15_r0_body.kr1_80.flags.get i).map (i, ·))
kernel_rfl PRE_first_tail_x15_r0_body.fkt180 : PRE_first_tail_x15_r0_body.kr1_80.targs = Stage.setAll PRE_first_tail_x15_r0_body.krC_80.targs (PRE_first_tail_x15_r0_body.cwS80.filterMap fun i => (PRE_first_tail_x15_r0_body.kr1_80.targs.get i).map (i, ·))
kernel_rfl PRE_first_tail_x15_r0_body.fkck80 : krecLB PRE_first_tail_x15_r0_body.kappa80 3475 PRE_first_tail_x15_r0_body.cx0_80.mlx PRE_first_tail_x15_r0_body.kr0_80 PRE_first_tail_x15_r0_body.kr1_80 PRE_first_tail_x15_r0_body.clo80 = true
kernel_rfl PRE_first_tail_x15_r0_body.fkn80 : Nat.ble 3475 3475 = true
-- the bridge and the pending traces' regions
kernel_rfl PRE_first_tail_x15_r0_body.cbridge80 : Host.Ts.Sim.Full.bridgeOf PRE_first_tail_x15_r0_body.s777.ffi = Host.Ts.Sim.Full.bridgeOf PRE_first_tail_x15_r0_body.s778.ffi
kernel_rfl PRE_first_tail_x15_r0_body.cpendR80 : pendRegB PRE_first_tail_x15_r0_body.kappa80 (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s778.ffi).mlx = true
kernel_rfl PRE_first_tail_x15_r0_body.cpendLe80 : Nat.ble (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s778.ffi).mlx.next (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s777.ffi).mlx.next = true
/-- **The compaction's native shift**, given the call's bookkeeping, its relation's facts (the model's and the
observers') and the canonical closedness. -/
theorem PRE_first_tail_x15_r0_body.cshift80 (clean : Conv.NClean (⟨19769, 16870, 2737255, 3475⟩ : Conv.Cnt) (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s776.ffi).mlx) (hltC : ∀ h, PH (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s776.ffi).mlx h → h < (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s776.ffi).mlx.next) (nltC : ∀ i, PN (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s776.ffi).mlx i → i < (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s776.ffi).mlx.nnext) (itemsC : ∀ k v, (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s776.ffi).mlx.items.get k = some v → PN (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s776.ffi).mlx k) (tracedC : ∀ h o, (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s776.ffi).mlx.objs.get h = some o → ∀ i ∈ objTraces o, i < PRE_first_tail_x15_r0_body.P80.NL) (cl : SSt (· < 3475) PRE_first_tail_x15_r0_body.cx0_80.mlx)
    (hobjC : ∀ h, PRE_first_tail_x15_r0_body.fxC_80.get h = some () → ((Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s776.ffi).mlx.objs.get h).isSome = true)
    (hfC : ∀ h, (PRE_first_tail_x15_r0_body.krC_80.flags.get h).isSome = true → ((Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s776.ffi).mlx.objs.get h).isSome = true)
    (htC : ∀ h, (PRE_first_tail_x15_r0_body.krC_80.targs.get h).isSome = true → ((Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s776.ffi).mlx.objs.get h).isSome = true)
    (hclC : ∀ h l, PRE_first_tail_x15_r0_body.krC_80.targs.get h = some l → Host.Ts.Sim.Full.STargs (· < (⟨19769, 16870, 2737255, 3475⟩ : Conv.Cnt).n) l) :
    Conv.FullShiftQ PRE_first_tail_x15_r0_body.P80 3475 PRE_first_tail_x15_r0_body.kappa80 PRE_first_tail_x15_r0_body.s778.ffi PRE_first_tail_x15_r0_body.s777.ffi :=
  ⟨PRE_first_tail_x15_r0_body.cnshift80 clean hltC nltC itemsC tracedC cl, PRE_first_tail_x15_r0_body.cqueue80, fun t ht => bSN_sound (List.all_eq_true.mp PRE_first_tail_x15_r0_body.ctokSupp80 t ht),
    PRE_first_tail_x15_r0_body.cbridge80,
    liveShift_foot (x0' := Host.Ts.Sim.Full.mlxOf PRE_first_tail_x15_r0_body.s778.ffi) (x1' := Host.Ts.Sim.Full.mlxOf PRE_first_tail_x15_r0_body.s777.ffi) (PRE_first_tail_x15_r0_body.cfoot80 clean hltC nltC itemsC tracedC cl) rfl PRE_first_tail_x15_r0_body.ofx0_80 PRE_first_tail_x15_r0_body.ofx1_80 hobjC PRE_first_tail_x15_r0_body.ff080 PRE_first_tail_x15_r0_body.ff180 PRE_first_tail_x15_r0_body.ffck80,
    kernShift_foot (x0' := Host.Ts.Sim.Full.mlxOf PRE_first_tail_x15_r0_body.s778.ffi) (x1' := Host.Ts.Sim.Full.mlxOf PRE_first_tail_x15_r0_body.s777.ffi) (PRE_first_tail_x15_r0_body.cfoot80 clean hltC nltC itemsC tracedC cl) rfl PRE_first_tail_x15_r0_body.okr0_80 PRE_first_tail_x15_r0_body.okr1_80 (Nat.le_of_ble_eq_true PRE_first_tail_x15_r0_body.fkn80) hfC htC hclC
      PRE_first_tail_x15_r0_body.fkf080 PRE_first_tail_x15_r0_body.fkt080 PRE_first_tail_x15_r0_body.fkf180 PRE_first_tail_x15_r0_body.fkt180 PRE_first_tail_x15_r0_body.fkck80,
    pendReg_of rfl PRE_first_tail_x15_r0_body.cnh080 PRE_first_tail_x15_r0_body.cnh180 (Nat.le_of_ble_eq_true PRE_first_tail_x15_r0_body.cpendLe80) PRE_first_tail_x15_r0_body.cpendR80⟩

end Host.Load.Run.Tpl
