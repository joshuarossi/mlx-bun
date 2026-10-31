import host.sim.template.a4pre_first_tail_x15_r0_body.SiteCl46
import host.sim.conv.CompactFull
import host.sim.template.FootGen
set_option Elab.async false
namespace Host.Load.Run.Tpl
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
open Host.Ts Host.Ts.Sim Host.Ts.Sim.Template

/-! The compaction's native shift at call site 46 from its footprint (`Conv.nshift_of_foot`), and the observers'
(`liveShift_foot`, `kernShift_foot`): `Conv.FullShiftQ` for `Conv.full_compactQ`, given the call's bookkeeping and its
relation's facts. -/

/-- The load parameters of the chain (band-free: its start's node counter as `NL` and `N0`). -/
def PRE_first_tail_x15_r0_body.Pc46 : LoadP := ⟨18151, 131072, 1099511627776, 15235, 15235, []⟩
/-- The site's band raised to the map's checked fixed-node prefix, including newly recorded closure traces. -/
def PRE_first_tail_x15_r0_body.P46 : LoadP := PRE_first_tail_x15_r0_body.Pc46.raise 16203
kernel_rfl PRE_first_tail_x15_r0_body.craise46 : Nat.ble PRE_first_tail_x15_r0_body.Pc46.N0 16203 = true
theorem PRE_first_tail_x15_r0_body.raised46 : Host.Ts.Sim.Full.Raised PRE_first_tail_x15_r0_body.Pc46 PRE_first_tail_x15_r0_body.P46 :=
  .inr ⟨16203, rfl, Nat.le_of_ble_eq_true PRE_first_tail_x15_r0_body.craise46, rfl⟩
noncomputable abbrev PRE_first_tail_x15_r0_body.cx0_46 : Host.Load.LSt := clearTokens (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s457.ffi)
noncomputable abbrev PRE_first_tail_x15_r0_body.cx1_46 : Host.Load.LSt := clearTokens (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s456.ffi)
def PRE_first_tail_x15_r0_body.khinv46 : PTrie Nat := Stage.setAll PTrie.nil []
def PRE_first_tail_x15_r0_body.kninv46 : PTrie Nat := Stage.setAll PTrie.nil []
/-- The stage's footprint: its written and fresh handles, fresh nodes, written and fresh items. -/
def PRE_first_tail_x15_r0_body.cwS46 : List Nat := []
def PRE_first_tail_x15_r0_body.cnS46 : List Nat := List.range' 16203 0
def PRE_first_tail_x15_r0_body.ciS46 : List Nat := [] ++ List.range' 16203 0

-- the small checks (`MChecks`'s)
kernel_rfl PRE_first_tail_x15_r0_body.cnh046 : PRE_first_tail_x15_r0_body.kd46.nh0 = PRE_first_tail_x15_r0_body.cx0_46.mlx.next
kernel_rfl PRE_first_tail_x15_r0_body.cnh146 : PRE_first_tail_x15_r0_body.kd46.nh1 = PRE_first_tail_x15_r0_body.cx1_46.mlx.next
kernel_rfl PRE_first_tail_x15_r0_body.cnn046 : PRE_first_tail_x15_r0_body.kd46.nn0 = PRE_first_tail_x15_r0_body.cx0_46.mlx.nnext
kernel_rfl PRE_first_tail_x15_r0_body.cnn146 : PRE_first_tail_x15_r0_body.kd46.nn1 = PRE_first_tail_x15_r0_body.cx1_46.mlx.nnext
kernel_rfl PRE_first_tail_x15_r0_body.cplo46 : (Nat.blt 0 PRE_first_tail_x15_r0_body.P46.lo && Nat.ble PRE_first_tail_x15_r0_body.P46.lo PRE_first_tail_x15_r0_body.cx0_46.mlx.next && Nat.ble PRE_first_tail_x15_r0_body.P46.lo RData.bigHi && Nat.ble RData.bigHi PRE_first_tail_x15_r0_body.P46.E) = true
kernel_rfl PRE_first_tail_x15_r0_body.ccnt46 : (Nat.ble PRE_first_tail_x15_r0_body.cx0_46.mlx.next PRE_first_tail_x15_r0_body.cx1_46.mlx.next && Nat.ble PRE_first_tail_x15_r0_body.cx0_46.mlx.nnext PRE_first_tail_x15_r0_body.cx1_46.mlx.nnext) = true
kernel_rfl PRE_first_tail_x15_r0_body.cnband46 : (Nat.blt 0 PRE_first_tail_x15_r0_body.P46.NL && Nat.ble PRE_first_tail_x15_r0_body.P46.NL PRE_first_tail_x15_r0_body.P46.N0 && Nat.ble PRE_first_tail_x15_r0_body.P46.N0 PRE_first_tail_x15_r0_body.cx0_46.mlx.nnext) = true
kernel_rfl PRE_first_tail_x15_r0_body.chbelow46 : PRE_first_tail_x15_r0_body.kd46.checkHndBelow = true
kernel_rfl PRE_first_tail_x15_r0_body.chren46 : checkRenG PRE_first_tail_x15_r0_body.kd46.hnd PRE_first_tail_x15_r0_body.khinv46 (phB PRE_first_tail_x15_r0_body.cx0_46.mlx) = true
kernel_rfl PRE_first_tail_x15_r0_body.cband46 : PRE_first_tail_x15_r0_body.kd46.checkBand PRE_first_tail_x15_r0_body.P46.lo = true
kernel_rfl PRE_first_tail_x15_r0_body.cnh1pos46 : Nat.blt 0 PRE_first_tail_x15_r0_body.kd46.nh1 = true
kernel_rfl PRE_first_tail_x15_r0_body.cnren46 : checkRenG PRE_first_tail_x15_r0_body.kd46.node PRE_first_tail_x15_r0_body.kninv46 (pnB PRE_first_tail_x15_r0_body.cx0_46.mlx) = true
kernel_rfl PRE_first_tail_x15_r0_body.cnlow46 : (PTrie.keysA PRE_first_tail_x15_r0_body.kd46.node).all (fun j => Nat.ble PRE_first_tail_x15_r0_body.P46.NL j && Nat.blt (PRE_first_tail_x15_r0_body.kd46.nodeF j) PRE_first_tail_x15_r0_body.cx1_46.mlx.nnext) = true
kernel_rfl PRE_first_tail_x15_r0_body.cabs0a46 : PRE_first_tail_x15_r0_body.cx0_46.mlx.arrs.get 0 = none
kernel_rfl PRE_first_tail_x15_r0_body.cabs0b46 : PRE_first_tail_x15_r0_body.cx0_46.mlx.objs.get 0 = none
kernel_rfl PRE_first_tail_x15_r0_body.ctok146 : PRE_first_tail_x15_r0_body.cx1_46.mlx.tokens = []
kernel_rfl PRE_first_tail_x15_r0_body.cpend46 : PRE_first_tail_x15_r0_body.cx1_46.mlx.pending = PRE_first_tail_x15_r0_body.cx0_46.mlx.pending.map PRE_first_tail_x15_r0_body.kappa46.pend
kernel_rfl PRE_first_tail_x15_r0_body.cerrh46 : PRE_first_tail_x15_r0_body.cx1_46.mlx.errh = PRE_first_tail_x15_r0_body.cx0_46.mlx.errh.map PRE_first_tail_x15_r0_body.kappa46.arg
kernel_rfl PRE_first_tail_x15_r0_body.cfiles46 : PRE_first_tail_x15_r0_body.cx1_46.mlx.files = PRE_first_tail_x15_r0_body.cx0_46.mlx.files
kernel_rfl PRE_first_tail_x15_r0_body.carch46 : PRE_first_tail_x15_r0_body.cx1_46.mlx.arch = PRE_first_tail_x15_r0_body.cx0_46.mlx.arch
kernel_rfl PRE_first_tail_x15_r0_body.csizes46 : PRE_first_tail_x15_r0_body.cx1_46.mlx.deviceSizes = PRE_first_tail_x15_r0_body.cx0_46.mlx.deviceSizes
kernel_rfl PRE_first_tail_x15_r0_body.cwired46 : PRE_first_tail_x15_r0_body.cx1_46.mlx.wired = PRE_first_tail_x15_r0_body.cx0_46.mlx.wired
kernel_rfl PRE_first_tail_x15_r0_body.chost46 : PRE_first_tail_x15_r0_body.cx1_46.host = PRE_first_tail_x15_r0_body.cx0_46.host
-- the compaction map's addresses are `PRE_first_tail_x15_r0_body.kd46`'s
kernel_rfl PRE_first_tail_x15_r0_body.ckn046 : PRE_first_tail_x15_r0_body.kd46.n0 = 2711337
kernel_rfl PRE_first_tail_x15_r0_body.ckn146 : PRE_first_tail_x15_r0_body.kd46.n1 = 2711339
kernel_rfl PRE_first_tail_x15_r0_body.ckheap46 : (PTrie.keysA PRE_first_tail_x15_r0_body.kd46.heap).all (fun x => Nat.ble 2711337 x) = true
kernel_rfl PRE_first_tail_x15_r0_body.ckpl46 : (List.range 0).all (fun j => decide (PRE_first_tail_x15_r0_body.kd46.heap.get (2711337 + j) = nth? PRE_first_tail_x15_r0_body.pl46 j)) = true
-- the map fixes the call's names (`Conv.fixOld_compact`), the call's counters
kernel_rfl PRE_first_tail_x15_r0_body.fja46 : Nat.ble 2711337 2711337 = true
kernel_rfl PRE_first_tail_x15_r0_body.fn46 : Nat.ble 2045 2045 = true
kernel_rfl PRE_first_tail_x15_r0_body.fjaD46 : Nat.ble 2711337 PRE_first_tail_x15_r0_body.kd46.n0 = true
kernel_rfl PRE_first_tail_x15_r0_body.fxn46 : Nat.ble 19118 PRE_first_tail_x15_r0_body.kd46.nh0 = true
kernel_rfl PRE_first_tail_x15_r0_body.fnn46 : Nat.ble 16203 PRE_first_tail_x15_r0_body.kd46.nn0 = true
kernel_rfl PRE_first_tail_x15_r0_body.fxb46 : Nat.ble 19118 RData.bigHi = true
kernel_rfl PRE_first_tail_x15_r0_body.fheap46 : (PTrie.keysA PRE_first_tail_x15_r0_body.kd46.heap).all (Nat.ble (⟨19118, 16203, 2711337, 2045⟩ : Conv.Cnt).ja) = true
kernel_rfl PRE_first_tail_x15_r0_body.fhnd46 : (PTrie.keysA PRE_first_tail_x15_r0_body.kd46.hnd).all (Nat.ble (⟨19118, 16203, 2711337, 2045⟩ : Conv.Cnt).xn) = true
kernel_rfl PRE_first_tail_x15_r0_body.fnode46 : (PTrie.keysA PRE_first_tail_x15_r0_body.kd46.node).all (Nat.ble (⟨19118, 16203, 2711337, 2045⟩ : Conv.Cnt).nn) = true
/-- The compaction map fixes the call's names. -/
theorem PRE_first_tail_x15_r0_body.cfix46 : Conv.FixOld (⟨19118, 16203, 2711337, 2045⟩ : Conv.Cnt) PRE_first_tail_x15_r0_body.kappa46 :=
  Conv.fixOld_compact (Nat.le_of_ble_eq_true PRE_first_tail_x15_r0_body.fja46) (Nat.le_of_ble_eq_true PRE_first_tail_x15_r0_body.fn46) (Nat.le_of_ble_eq_true PRE_first_tail_x15_r0_body.fjaD46) (Nat.le_of_ble_eq_true PRE_first_tail_x15_r0_body.fxn46) (Nat.le_of_ble_eq_true PRE_first_tail_x15_r0_body.fnn46) (Nat.le_of_ble_eq_true PRE_first_tail_x15_r0_body.fxb46) PRE_first_tail_x15_r0_body.fheap46 PRE_first_tail_x15_r0_body.fhnd46 PRE_first_tail_x15_r0_body.fnode46
kernel_rfl PRE_first_tail_x15_r0_body.fcxn46 : (⟨19118, 16203, 2711337, 2045⟩ : Conv.Cnt).xn = (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s455.ffi).mlx.next
kernel_rfl PRE_first_tail_x15_r0_body.fcnn46 : (⟨19118, 16203, 2711337, 2045⟩ : Conv.Cnt).nn = (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s455.ffi).mlx.nnext
kernel_rfl PRE_first_tail_x15_r0_body.fle046 : (Nat.ble (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s455.ffi).mlx.next PRE_first_tail_x15_r0_body.cx0_46.mlx.next && Nat.ble (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s455.ffi).mlx.nnext PRE_first_tail_x15_r0_body.cx0_46.mlx.nnext && Nat.ble (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s455.ffi).mlx.next RData.bigHi) = true
kernel_rfl PRE_first_tail_x15_r0_body.fnk46 : (PTrie.keysA PRE_first_tail_x15_r0_body.kd46.node).all (Nat.ble (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s455.ffi).mlx.nnext) = true
-- the merged state keeps the call's entries off the stage's footprint
kernel_rfl PRE_first_tail_x15_r0_body.f1A46 : PRE_first_tail_x15_r0_body.cx1_46.mlx.arrs = Stage.setAll (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s455.ffi).mlx.arrs (PRE_first_tail_x15_r0_body.cwS46.filterMap fun i => (PRE_first_tail_x15_r0_body.cx1_46.mlx.arrs.get i).map (i, ·))
kernel_rfl PRE_first_tail_x15_r0_body.f1O46 : PRE_first_tail_x15_r0_body.cx1_46.mlx.objs = Stage.setAll (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s455.ffi).mlx.objs (PRE_first_tail_x15_r0_body.cwS46.filterMap fun i => (PRE_first_tail_x15_r0_body.cx1_46.mlx.objs.get i).map (i, ·))
kernel_rfl PRE_first_tail_x15_r0_body.f1N46 : PRE_first_tail_x15_r0_body.cx1_46.mlx.nodes = Stage.setAll (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s455.ffi).mlx.nodes (PRE_first_tail_x15_r0_body.cnS46.filterMap fun i => (PRE_first_tail_x15_r0_body.cx1_46.mlx.nodes.get i).map (i, ·))
kernel_rfl PRE_first_tail_x15_r0_body.f1I46 : PRE_first_tail_x15_r0_body.cx1_46.mlx.items = Stage.setAll (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s455.ffi).mlx.items (PRE_first_tail_x15_r0_body.ciS46.filterMap fun i => (PRE_first_tail_x15_r0_body.cx1_46.mlx.items.get i).map (i, ·))
kernel_rfl PRE_first_tail_x15_r0_body.fbd46 : (PRE_first_tail_x15_r0_body.clo46 ++ PRE_first_tail_x15_r0_body.cln46 ++ PRE_first_tail_x15_r0_body.cli46 ++ PRE_first_tail_x15_r0_body.cwS46 ++ PRE_first_tail_x15_r0_body.cnS46 ++ PRE_first_tail_x15_r0_body.ciS46).all (fun i => Nat.blt (i / 4096) (4 ^ 31)) = true
kernel_rfl PRE_first_tail_x15_r0_body.fincW46 : PRE_first_tail_x15_r0_body.cwS46.all (fun h => !Nat.blt h (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s455.ffi).mlx.next || PRE_first_tail_x15_r0_body.clo46.contains h) = true
kernel_rfl PRE_first_tail_x15_r0_body.fincI46 : PRE_first_tail_x15_r0_body.ciS46.all (fun k => !Nat.blt k (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s455.ffi).mlx.nnext || PRE_first_tail_x15_r0_body.cli46.contains k) = true
kernel_rfl PRE_first_tail_x15_r0_body.fincN46 : PRE_first_tail_x15_r0_body.cnS46.all (Nat.ble (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s455.ffi).mlx.nnext) = true
kernel_rfl PRE_first_tail_x15_r0_body.flnF46 : PRE_first_tail_x15_r0_body.cln46.all (Nat.ble (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s455.ffi).mlx.nnext) = true
-- the checks over the changed lists
kernel_rfl PRE_first_tail_x15_r0_body.fh46 : PRE_first_tail_x15_r0_body.clo46.all (handleOK PRE_first_tail_x15_r0_body.kappa46 PRE_first_tail_x15_r0_body.P46.lo PRE_first_tail_x15_r0_body.cx0_46.mlx PRE_first_tail_x15_r0_body.cx1_46.mlx) = true
kernel_rfl PRE_first_tail_x15_r0_body.fo46 : PRE_first_tail_x15_r0_body.clo46.map (fun h => PRE_first_tail_x15_r0_body.cx1_46.mlx.objs.get (PRE_first_tail_x15_r0_body.kappa46.handle h)) = PRE_first_tail_x15_r0_body.clo46.map (fun h => (PRE_first_tail_x15_r0_body.cx0_46.mlx.objs.get h).map PRE_first_tail_x15_r0_body.kappa46.nobj)
kernel_rfl PRE_first_tail_x15_r0_body.fok46 : PRE_first_tail_x15_r0_body.clo46.all (objOK PRE_first_tail_x15_r0_body.kappa46 PRE_first_tail_x15_r0_body.P46.NL PRE_first_tail_x15_r0_body.cx0_46.mlx) = true
kernel_rfl PRE_first_tail_x15_r0_body.fnd46 : PRE_first_tail_x15_r0_body.cln46.all (nodeOKF PRE_first_tail_x15_r0_body.kappa46 PRE_first_tail_x15_r0_body.P46 PRE_first_tail_x15_r0_body.cx0_46.mlx PRE_first_tail_x15_r0_body.cx1_46.mlx) = true
kernel_rfl PRE_first_tail_x15_r0_body.fp46 : ((PRE_first_tail_x15_r0_body.cln46.filter (fullB PRE_first_tail_x15_r0_body.P46))).map (fun i => (PRE_first_tail_x15_r0_body.cx1_46.mlx.nodes.get (PRE_first_tail_x15_r0_body.kappa46.node i)).map Host.Mlx.Ffi.Node.prim) =
  ((PRE_first_tail_x15_r0_body.cln46.filter (fullB PRE_first_tail_x15_r0_body.P46))).map (fun i => (PRE_first_tail_x15_r0_body.cx0_46.mlx.nodes.get i).map fun nd => PRE_first_tail_x15_r0_body.kappa46.prim nd.prim)
kernel_rfl PRE_first_tail_x15_r0_body.fnordI46 : incrB PRE_first_tail_x15_r0_body.kd46.nodeF (List.range' 16203 0) = true
kernel_rfl PRE_first_tail_x15_r0_body.fnordK46 : (PTrie.keysA PRE_first_tail_x15_r0_body.kd46.node).all (fun k => Nat.ble 16203 k && Nat.blt k 16203) = true
kernel_rfl PRE_first_tail_x15_r0_body.fnordL46 : (PRE_first_tail_x15_r0_body.cln46.filter (Nat.ble PRE_first_tail_x15_r0_body.P46.N0)).all (fun i => Nat.ble i (PRE_first_tail_x15_r0_body.kd46.nodeF i) && (Nat.blt i 16203 || Nat.ble PRE_first_tail_x15_r0_body.kd46.nn0 i)) = true
theorem PRE_first_tail_x15_r0_body.fnord46 : (PRE_first_tail_x15_r0_body.cln46.filter (Nat.ble PRE_first_tail_x15_r0_body.P46.N0)).all (fun i => Nat.ble i (PRE_first_tail_x15_r0_body.kd46.nodeF i) &&
    (PTrie.keysA PRE_first_tail_x15_r0_body.kd46.node).all fun j => !Nat.blt j i || Nat.blt (PRE_first_tail_x15_r0_body.kd46.nodeF j) (PRE_first_tail_x15_r0_body.kd46.nodeF i)) = true :=
  cnord_of PRE_first_tail_x15_r0_body.cnlow46 PRE_first_tail_x15_r0_body.cnn146 PRE_first_tail_x15_r0_body.fnordI46 PRE_first_tail_x15_r0_body.fnordK46 PRE_first_tail_x15_r0_body.fnordL46
kernel_rfl PRE_first_tail_x15_r0_body.fi46 : PRE_first_tail_x15_r0_body.cli46.all (pnB PRE_first_tail_x15_r0_body.cx0_46.mlx) = true
kernel_rfl PRE_first_tail_x15_r0_body.fii46 : PRE_first_tail_x15_r0_body.cli46.all (fun k => decide (PRE_first_tail_x15_r0_body.cx1_46.mlx.items.get (PRE_first_tail_x15_r0_body.kappa46.node k) = (PRE_first_tail_x15_r0_body.cx0_46.mlx.items.get k).map PRE_first_tail_x15_r0_body.kappa46.nv)) = true
/-- **The compaction's footprint.** -/
theorem PRE_first_tail_x15_r0_body.cfoot46 (clean : Conv.NClean (⟨19118, 16203, 2711337, 2045⟩ : Conv.Cnt) (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s455.ffi).mlx) (hltC : ∀ h, PH (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s455.ffi).mlx h → h < (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s455.ffi).mlx.next) (nltC : ∀ i, PN (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s455.ffi).mlx i → i < (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s455.ffi).mlx.nnext) (itemsC : ∀ k v, (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s455.ffi).mlx.items.get k = some v → PN (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s455.ffi).mlx k) (tracedC : ∀ h o, (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s455.ffi).mlx.objs.get h = some o → ∀ i ∈ objTraces o, i < PRE_first_tail_x15_r0_body.P46.NL) (cl : SSt (· < 2045) PRE_first_tail_x15_r0_body.cx0_46.mlx) :
    Conv.MFoot PRE_first_tail_x15_r0_body.P46 2045 PRE_first_tail_x15_r0_body.kappa46 PRE_first_tail_x15_r0_body.kd46 PRE_first_tail_x15_r0_body.khinv46 PRE_first_tail_x15_r0_body.kninv46 (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s455.ffi).mlx PRE_first_tail_x15_r0_body.cx0_46.mlx PRE_first_tail_x15_r0_body.cx1_46.mlx (⟨19118, 16203, 2711337, 2045⟩ : Conv.Cnt) PRE_first_tail_x15_r0_body.clo46 PRE_first_tail_x15_r0_body.cln46 PRE_first_tail_x15_r0_body.cli46 PRE_first_tail_x15_r0_body.cwS46 PRE_first_tail_x15_r0_body.cnS46 PRE_first_tail_x15_r0_body.ciS46 :=
  ⟨rfl, rfl, rfl, PRE_first_tail_x15_r0_body.cnh046, PRE_first_tail_x15_r0_body.cnh146, PRE_first_tail_x15_r0_body.cnn046, PRE_first_tail_x15_r0_body.cnn146, PRE_first_tail_x15_r0_body.cplo46, PRE_first_tail_x15_r0_body.ccnt46, PRE_first_tail_x15_r0_body.cnband46, PRE_first_tail_x15_r0_body.chbelow46, PRE_first_tail_x15_r0_body.chren46, PRE_first_tail_x15_r0_body.cband46, PRE_first_tail_x15_r0_body.cnh1pos46, PRE_first_tail_x15_r0_body.cnren46, PRE_first_tail_x15_r0_body.cnlow46, PRE_first_tail_x15_r0_body.cabs0a46, PRE_first_tail_x15_r0_body.cabs0b46, PRE_first_tail_x15_r0_body.ctok146, PRE_first_tail_x15_r0_body.cpend46, PRE_first_tail_x15_r0_body.cerrh46, PRE_first_tail_x15_r0_body.cfiles46, PRE_first_tail_x15_r0_body.carch46, PRE_first_tail_x15_r0_body.csizes46, PRE_first_tail_x15_r0_body.cwired46, PRE_first_tail_x15_r0_body.cfix46, clean, PRE_first_tail_x15_r0_body.fcxn46, PRE_first_tail_x15_r0_body.fcnn46, hltC, nltC, itemsC, tracedC, cl, PRE_first_tail_x15_r0_body.fle046, PRE_first_tail_x15_r0_body.fnk46, PRE_first_tail_x15_r0_body.ckA46, PRE_first_tail_x15_r0_body.cobjsK46, PRE_first_tail_x15_r0_body.cnodesK46, PRE_first_tail_x15_r0_body.citemsK46, PRE_first_tail_x15_r0_body.f1A46, PRE_first_tail_x15_r0_body.f1O46, PRE_first_tail_x15_r0_body.f1N46, PRE_first_tail_x15_r0_body.f1I46, PRE_first_tail_x15_r0_body.fbd46, PRE_first_tail_x15_r0_body.fincW46, PRE_first_tail_x15_r0_body.fincI46, PRE_first_tail_x15_r0_body.fincN46, PRE_first_tail_x15_r0_body.flnF46, PRE_first_tail_x15_r0_body.fh46, PRE_first_tail_x15_r0_body.fo46, PRE_first_tail_x15_r0_body.fok46, PRE_first_tail_x15_r0_body.fnd46, PRE_first_tail_x15_r0_body.fp46, PRE_first_tail_x15_r0_body.fnord46, PRE_first_tail_x15_r0_body.fi46, PRE_first_tail_x15_r0_body.fii46⟩
theorem PRE_first_tail_x15_r0_body.cnshift46 (clean : Conv.NClean (⟨19118, 16203, 2711337, 2045⟩ : Conv.Cnt) (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s455.ffi).mlx) (hltC : ∀ h, PH (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s455.ffi).mlx h → h < (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s455.ffi).mlx.next) (nltC : ∀ i, PN (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s455.ffi).mlx i → i < (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s455.ffi).mlx.nnext) (itemsC : ∀ k v, (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s455.ffi).mlx.items.get k = some v → PN (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s455.ffi).mlx k) (tracedC : ∀ h o, (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s455.ffi).mlx.objs.get h = some o → ∀ i ∈ objTraces o, i < PRE_first_tail_x15_r0_body.P46.NL) (cl : SSt (· < 2045) PRE_first_tail_x15_r0_body.cx0_46.mlx) : NShift PRE_first_tail_x15_r0_body.P46 2045 PRE_first_tail_x15_r0_body.kappa46 PRE_first_tail_x15_r0_body.cx0_46 PRE_first_tail_x15_r0_body.cx1_46 :=
  Conv.nshift_of_foot (PRE_first_tail_x15_r0_body.cfoot46 clean hltC nltC itemsC tracedC cl) PRE_first_tail_x15_r0_body.chost46 (compact_a_eq PRE_first_tail_x15_r0_body.ckn046 PRE_first_tail_x15_r0_body.ckn146 PRE_first_tail_x15_r0_body.ckheap46 PRE_first_tail_x15_r0_body.ckpl46)

-- the observers: the layers' states at the call, the canonical and the merged state, their footprints and checks
noncomputable def PRE_first_tail_x15_r0_body.fxC_46 : PTrie Unit := (Host.Ts.Sim.Full.freedOf PRE_first_tail_x15_r0_body.s455.ffi).getD PTrie.nil
noncomputable def PRE_first_tail_x15_r0_body.krC_46 : Host.Load.Layers.KRec := (Host.Ts.Sim.Full.krecOf PRE_first_tail_x15_r0_body.s455.ffi).getD Host.Load.Layers.KRec.empty
kernel_rfl PRE_first_tail_x15_r0_body.ofxC_46 : (Host.Ts.Sim.Full.freedOf PRE_first_tail_x15_r0_body.s455.ffi) = some PRE_first_tail_x15_r0_body.fxC_46
kernel_rfl PRE_first_tail_x15_r0_body.okrC_46 : (Host.Ts.Sim.Full.krecOf PRE_first_tail_x15_r0_body.s455.ffi) = some PRE_first_tail_x15_r0_body.krC_46
noncomputable def PRE_first_tail_x15_r0_body.fx0_46 : PTrie Unit := (Host.Ts.Sim.Full.freedOf PRE_first_tail_x15_r0_body.s457.ffi).getD PTrie.nil
noncomputable def PRE_first_tail_x15_r0_body.kr0_46 : Host.Load.Layers.KRec := (Host.Ts.Sim.Full.krecOf PRE_first_tail_x15_r0_body.s457.ffi).getD Host.Load.Layers.KRec.empty
kernel_rfl PRE_first_tail_x15_r0_body.ofx0_46 : (Host.Ts.Sim.Full.freedOf PRE_first_tail_x15_r0_body.s457.ffi) = some PRE_first_tail_x15_r0_body.fx0_46
kernel_rfl PRE_first_tail_x15_r0_body.okr0_46 : (Host.Ts.Sim.Full.krecOf PRE_first_tail_x15_r0_body.s457.ffi) = some PRE_first_tail_x15_r0_body.kr0_46
noncomputable def PRE_first_tail_x15_r0_body.fx1_46 : PTrie Unit := (Host.Ts.Sim.Full.freedOf PRE_first_tail_x15_r0_body.s456.ffi).getD PTrie.nil
noncomputable def PRE_first_tail_x15_r0_body.kr1_46 : Host.Load.Layers.KRec := (Host.Ts.Sim.Full.krecOf PRE_first_tail_x15_r0_body.s456.ffi).getD Host.Load.Layers.KRec.empty
kernel_rfl PRE_first_tail_x15_r0_body.ofx1_46 : (Host.Ts.Sim.Full.freedOf PRE_first_tail_x15_r0_body.s456.ffi) = some PRE_first_tail_x15_r0_body.fx1_46
kernel_rfl PRE_first_tail_x15_r0_body.okr1_46 : (Host.Ts.Sim.Full.krecOf PRE_first_tail_x15_r0_body.s456.ffi) = some PRE_first_tail_x15_r0_body.kr1_46
kernel_rfl PRE_first_tail_x15_r0_body.ff046 : PRE_first_tail_x15_r0_body.fx0_46 = Stage.setAll PRE_first_tail_x15_r0_body.fxC_46 (PRE_first_tail_x15_r0_body.clo46.filterMap fun i => (PRE_first_tail_x15_r0_body.fx0_46.get i).map (i, ·))
kernel_rfl PRE_first_tail_x15_r0_body.ff146 : PRE_first_tail_x15_r0_body.fx1_46 = Stage.setAll PRE_first_tail_x15_r0_body.fxC_46 (PRE_first_tail_x15_r0_body.cwS46.filterMap fun i => (PRE_first_tail_x15_r0_body.fx1_46.get i).map (i, ·))
kernel_rfl PRE_first_tail_x15_r0_body.ffck46 : freedLB PRE_first_tail_x15_r0_body.kappa46 PRE_first_tail_x15_r0_body.cx0_46.mlx PRE_first_tail_x15_r0_body.fx0_46 PRE_first_tail_x15_r0_body.fx1_46 PRE_first_tail_x15_r0_body.clo46 = true
kernel_rfl PRE_first_tail_x15_r0_body.fkf046 : PRE_first_tail_x15_r0_body.kr0_46.flags = Stage.setAll PRE_first_tail_x15_r0_body.krC_46.flags (PRE_first_tail_x15_r0_body.clo46.filterMap fun i => (PRE_first_tail_x15_r0_body.kr0_46.flags.get i).map (i, ·))
kernel_rfl PRE_first_tail_x15_r0_body.fkt046 : PRE_first_tail_x15_r0_body.kr0_46.targs = Stage.setAll PRE_first_tail_x15_r0_body.krC_46.targs (PRE_first_tail_x15_r0_body.clo46.filterMap fun i => (PRE_first_tail_x15_r0_body.kr0_46.targs.get i).map (i, ·))
kernel_rfl PRE_first_tail_x15_r0_body.fkf146 : PRE_first_tail_x15_r0_body.kr1_46.flags = Stage.setAll PRE_first_tail_x15_r0_body.krC_46.flags (PRE_first_tail_x15_r0_body.cwS46.filterMap fun i => (PRE_first_tail_x15_r0_body.kr1_46.flags.get i).map (i, ·))
kernel_rfl PRE_first_tail_x15_r0_body.fkt146 : PRE_first_tail_x15_r0_body.kr1_46.targs = Stage.setAll PRE_first_tail_x15_r0_body.krC_46.targs (PRE_first_tail_x15_r0_body.cwS46.filterMap fun i => (PRE_first_tail_x15_r0_body.kr1_46.targs.get i).map (i, ·))
kernel_rfl PRE_first_tail_x15_r0_body.fkck46 : krecLB PRE_first_tail_x15_r0_body.kappa46 2045 PRE_first_tail_x15_r0_body.cx0_46.mlx PRE_first_tail_x15_r0_body.kr0_46 PRE_first_tail_x15_r0_body.kr1_46 PRE_first_tail_x15_r0_body.clo46 = true
kernel_rfl PRE_first_tail_x15_r0_body.fkn46 : Nat.ble 2045 2045 = true
-- the bridge and the pending traces' regions
kernel_rfl PRE_first_tail_x15_r0_body.cbridge46 : Host.Ts.Sim.Full.bridgeOf PRE_first_tail_x15_r0_body.s456.ffi = Host.Ts.Sim.Full.bridgeOf PRE_first_tail_x15_r0_body.s457.ffi
kernel_rfl PRE_first_tail_x15_r0_body.cpendR46 : pendRegB PRE_first_tail_x15_r0_body.kappa46 (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s457.ffi).mlx = true
kernel_rfl PRE_first_tail_x15_r0_body.cpendLe46 : Nat.ble (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s457.ffi).mlx.next (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s456.ffi).mlx.next = true
/-- **The compaction's native shift**, given the call's bookkeeping, its relation's facts (the model's and the
observers') and the canonical closedness. -/
theorem PRE_first_tail_x15_r0_body.cshift46 (clean : Conv.NClean (⟨19118, 16203, 2711337, 2045⟩ : Conv.Cnt) (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s455.ffi).mlx) (hltC : ∀ h, PH (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s455.ffi).mlx h → h < (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s455.ffi).mlx.next) (nltC : ∀ i, PN (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s455.ffi).mlx i → i < (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s455.ffi).mlx.nnext) (itemsC : ∀ k v, (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s455.ffi).mlx.items.get k = some v → PN (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s455.ffi).mlx k) (tracedC : ∀ h o, (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s455.ffi).mlx.objs.get h = some o → ∀ i ∈ objTraces o, i < PRE_first_tail_x15_r0_body.P46.NL) (cl : SSt (· < 2045) PRE_first_tail_x15_r0_body.cx0_46.mlx)
    (hobjC : ∀ h, PRE_first_tail_x15_r0_body.fxC_46.get h = some () → ((Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s455.ffi).mlx.objs.get h).isSome = true)
    (hfC : ∀ h, (PRE_first_tail_x15_r0_body.krC_46.flags.get h).isSome = true → ((Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s455.ffi).mlx.objs.get h).isSome = true)
    (htC : ∀ h, (PRE_first_tail_x15_r0_body.krC_46.targs.get h).isSome = true → ((Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s455.ffi).mlx.objs.get h).isSome = true)
    (hclC : ∀ h l, PRE_first_tail_x15_r0_body.krC_46.targs.get h = some l → Host.Ts.Sim.Full.STargs (· < (⟨19118, 16203, 2711337, 2045⟩ : Conv.Cnt).n) l) :
    Conv.FullShiftQ PRE_first_tail_x15_r0_body.P46 2045 PRE_first_tail_x15_r0_body.kappa46 PRE_first_tail_x15_r0_body.s457.ffi PRE_first_tail_x15_r0_body.s456.ffi :=
  ⟨PRE_first_tail_x15_r0_body.cnshift46 clean hltC nltC itemsC tracedC cl, PRE_first_tail_x15_r0_body.cqueue46, fun t ht => bSN_sound (List.all_eq_true.mp PRE_first_tail_x15_r0_body.ctokSupp46 t ht),
    PRE_first_tail_x15_r0_body.cbridge46,
    liveShift_foot (x0' := Host.Ts.Sim.Full.mlxOf PRE_first_tail_x15_r0_body.s457.ffi) (x1' := Host.Ts.Sim.Full.mlxOf PRE_first_tail_x15_r0_body.s456.ffi) (PRE_first_tail_x15_r0_body.cfoot46 clean hltC nltC itemsC tracedC cl) rfl PRE_first_tail_x15_r0_body.ofx0_46 PRE_first_tail_x15_r0_body.ofx1_46 hobjC PRE_first_tail_x15_r0_body.ff046 PRE_first_tail_x15_r0_body.ff146 PRE_first_tail_x15_r0_body.ffck46,
    kernShift_foot (x0' := Host.Ts.Sim.Full.mlxOf PRE_first_tail_x15_r0_body.s457.ffi) (x1' := Host.Ts.Sim.Full.mlxOf PRE_first_tail_x15_r0_body.s456.ffi) (PRE_first_tail_x15_r0_body.cfoot46 clean hltC nltC itemsC tracedC cl) rfl PRE_first_tail_x15_r0_body.okr0_46 PRE_first_tail_x15_r0_body.okr1_46 (Nat.le_of_ble_eq_true PRE_first_tail_x15_r0_body.fkn46) hfC htC hclC
      PRE_first_tail_x15_r0_body.fkf046 PRE_first_tail_x15_r0_body.fkt046 PRE_first_tail_x15_r0_body.fkf146 PRE_first_tail_x15_r0_body.fkt146 PRE_first_tail_x15_r0_body.fkck46,
    pendReg_of rfl PRE_first_tail_x15_r0_body.cnh046 PRE_first_tail_x15_r0_body.cnh146 (Nat.le_of_ble_eq_true PRE_first_tail_x15_r0_body.cpendLe46) PRE_first_tail_x15_r0_body.cpendR46⟩

end Host.Load.Run.Tpl
