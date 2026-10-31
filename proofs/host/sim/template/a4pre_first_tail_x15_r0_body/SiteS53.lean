import host.sim.template.a4pre_first_tail_x15_r0_body.SiteCl53
import host.sim.conv.CompactFull
import host.sim.template.FootGen
set_option Elab.async false
namespace Host.Load.Run.Tpl
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
open Host.Ts Host.Ts.Sim Host.Ts.Sim.Template

/-! The compaction's native shift at call site 53 from its footprint (`Conv.nshift_of_foot`), and the observers'
(`liveShift_foot`, `kernShift_foot`): `Conv.FullShiftQ` for `Conv.full_compactQ`, given the call's bookkeeping and its
relation's facts. -/

/-- The load parameters of the chain (band-free: its start's node counter as `NL` and `N0`). -/
def PRE_first_tail_x15_r0_body.Pc53 : LoadP := ⟨18151, 131072, 1099511627776, 15235, 15235, []⟩
/-- The site's band raised to the map's checked fixed-node prefix, including newly recorded closure traces. -/
def PRE_first_tail_x15_r0_body.P53 : LoadP := PRE_first_tail_x15_r0_body.Pc53.raise 16333
kernel_rfl PRE_first_tail_x15_r0_body.craise53 : Nat.ble PRE_first_tail_x15_r0_body.Pc53.N0 16333 = true
theorem PRE_first_tail_x15_r0_body.raised53 : Host.Ts.Sim.Full.Raised PRE_first_tail_x15_r0_body.Pc53 PRE_first_tail_x15_r0_body.P53 :=
  .inr ⟨16333, rfl, Nat.le_of_ble_eq_true PRE_first_tail_x15_r0_body.craise53, rfl⟩
noncomputable abbrev PRE_first_tail_x15_r0_body.cx0_53 : Host.Load.LSt := clearTokens (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s474.ffi)
noncomputable abbrev PRE_first_tail_x15_r0_body.cx1_53 : Host.Load.LSt := clearTokens (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s473.ffi)
def PRE_first_tail_x15_r0_body.khinv53 : PTrie Nat := Stage.setAll PTrie.nil []
def PRE_first_tail_x15_r0_body.kninv53 : PTrie Nat := Stage.setAll PTrie.nil []
/-- The stage's footprint: its written and fresh handles, fresh nodes, written and fresh items. -/
def PRE_first_tail_x15_r0_body.cwS53 : List Nat := []
def PRE_first_tail_x15_r0_body.cnS53 : List Nat := List.range' 16333 0
def PRE_first_tail_x15_r0_body.ciS53 : List Nat := [] ++ List.range' 16333 0

-- the small checks (`MChecks`'s)
kernel_rfl PRE_first_tail_x15_r0_body.cnh053 : PRE_first_tail_x15_r0_body.kd53.nh0 = PRE_first_tail_x15_r0_body.cx0_53.mlx.next
kernel_rfl PRE_first_tail_x15_r0_body.cnh153 : PRE_first_tail_x15_r0_body.kd53.nh1 = PRE_first_tail_x15_r0_body.cx1_53.mlx.next
kernel_rfl PRE_first_tail_x15_r0_body.cnn053 : PRE_first_tail_x15_r0_body.kd53.nn0 = PRE_first_tail_x15_r0_body.cx0_53.mlx.nnext
kernel_rfl PRE_first_tail_x15_r0_body.cnn153 : PRE_first_tail_x15_r0_body.kd53.nn1 = PRE_first_tail_x15_r0_body.cx1_53.mlx.nnext
kernel_rfl PRE_first_tail_x15_r0_body.cplo53 : (Nat.blt 0 PRE_first_tail_x15_r0_body.P53.lo && Nat.ble PRE_first_tail_x15_r0_body.P53.lo PRE_first_tail_x15_r0_body.cx0_53.mlx.next && Nat.ble PRE_first_tail_x15_r0_body.P53.lo RData.bigHi && Nat.ble RData.bigHi PRE_first_tail_x15_r0_body.P53.E) = true
kernel_rfl PRE_first_tail_x15_r0_body.ccnt53 : (Nat.ble PRE_first_tail_x15_r0_body.cx0_53.mlx.next PRE_first_tail_x15_r0_body.cx1_53.mlx.next && Nat.ble PRE_first_tail_x15_r0_body.cx0_53.mlx.nnext PRE_first_tail_x15_r0_body.cx1_53.mlx.nnext) = true
kernel_rfl PRE_first_tail_x15_r0_body.cnband53 : (Nat.blt 0 PRE_first_tail_x15_r0_body.P53.NL && Nat.ble PRE_first_tail_x15_r0_body.P53.NL PRE_first_tail_x15_r0_body.P53.N0 && Nat.ble PRE_first_tail_x15_r0_body.P53.N0 PRE_first_tail_x15_r0_body.cx0_53.mlx.nnext) = true
kernel_rfl PRE_first_tail_x15_r0_body.chbelow53 : PRE_first_tail_x15_r0_body.kd53.checkHndBelow = true
kernel_rfl PRE_first_tail_x15_r0_body.chren53 : checkRenG PRE_first_tail_x15_r0_body.kd53.hnd PRE_first_tail_x15_r0_body.khinv53 (phB PRE_first_tail_x15_r0_body.cx0_53.mlx) = true
kernel_rfl PRE_first_tail_x15_r0_body.cband53 : PRE_first_tail_x15_r0_body.kd53.checkBand PRE_first_tail_x15_r0_body.P53.lo = true
kernel_rfl PRE_first_tail_x15_r0_body.cnh1pos53 : Nat.blt 0 PRE_first_tail_x15_r0_body.kd53.nh1 = true
kernel_rfl PRE_first_tail_x15_r0_body.cnren53 : checkRenG PRE_first_tail_x15_r0_body.kd53.node PRE_first_tail_x15_r0_body.kninv53 (pnB PRE_first_tail_x15_r0_body.cx0_53.mlx) = true
kernel_rfl PRE_first_tail_x15_r0_body.cnlow53 : (PTrie.keysA PRE_first_tail_x15_r0_body.kd53.node).all (fun j => Nat.ble PRE_first_tail_x15_r0_body.P53.NL j && Nat.blt (PRE_first_tail_x15_r0_body.kd53.nodeF j) PRE_first_tail_x15_r0_body.cx1_53.mlx.nnext) = true
kernel_rfl PRE_first_tail_x15_r0_body.cabs0a53 : PRE_first_tail_x15_r0_body.cx0_53.mlx.arrs.get 0 = none
kernel_rfl PRE_first_tail_x15_r0_body.cabs0b53 : PRE_first_tail_x15_r0_body.cx0_53.mlx.objs.get 0 = none
kernel_rfl PRE_first_tail_x15_r0_body.ctok153 : PRE_first_tail_x15_r0_body.cx1_53.mlx.tokens = []
kernel_rfl PRE_first_tail_x15_r0_body.cpend53 : PRE_first_tail_x15_r0_body.cx1_53.mlx.pending = PRE_first_tail_x15_r0_body.cx0_53.mlx.pending.map PRE_first_tail_x15_r0_body.kappa53.pend
kernel_rfl PRE_first_tail_x15_r0_body.cerrh53 : PRE_first_tail_x15_r0_body.cx1_53.mlx.errh = PRE_first_tail_x15_r0_body.cx0_53.mlx.errh.map PRE_first_tail_x15_r0_body.kappa53.arg
kernel_rfl PRE_first_tail_x15_r0_body.cfiles53 : PRE_first_tail_x15_r0_body.cx1_53.mlx.files = PRE_first_tail_x15_r0_body.cx0_53.mlx.files
kernel_rfl PRE_first_tail_x15_r0_body.carch53 : PRE_first_tail_x15_r0_body.cx1_53.mlx.arch = PRE_first_tail_x15_r0_body.cx0_53.mlx.arch
kernel_rfl PRE_first_tail_x15_r0_body.csizes53 : PRE_first_tail_x15_r0_body.cx1_53.mlx.deviceSizes = PRE_first_tail_x15_r0_body.cx0_53.mlx.deviceSizes
kernel_rfl PRE_first_tail_x15_r0_body.cwired53 : PRE_first_tail_x15_r0_body.cx1_53.mlx.wired = PRE_first_tail_x15_r0_body.cx0_53.mlx.wired
kernel_rfl PRE_first_tail_x15_r0_body.chost53 : PRE_first_tail_x15_r0_body.cx1_53.host = PRE_first_tail_x15_r0_body.cx0_53.host
-- the compaction map's addresses are `PRE_first_tail_x15_r0_body.kd53`'s
kernel_rfl PRE_first_tail_x15_r0_body.ckn053 : PRE_first_tail_x15_r0_body.kd53.n0 = 2716168
kernel_rfl PRE_first_tail_x15_r0_body.ckn153 : PRE_first_tail_x15_r0_body.kd53.n1 = 2716187
kernel_rfl PRE_first_tail_x15_r0_body.ckheap53 : (PTrie.keysA PRE_first_tail_x15_r0_body.kd53.heap).all (fun x => Nat.ble 2716167 x) = true
kernel_rfl PRE_first_tail_x15_r0_body.ckpl53 : (List.range 1).all (fun j => decide (PRE_first_tail_x15_r0_body.kd53.heap.get (2716167 + j) = nth? PRE_first_tail_x15_r0_body.pl53 j)) = true
-- the map fixes the call's names (`Conv.fixOld_compact`), the call's counters
kernel_rfl PRE_first_tail_x15_r0_body.fja53 : Nat.ble 2716167 2716167 = true
kernel_rfl PRE_first_tail_x15_r0_body.fn53 : Nat.ble 2320 2320 = true
kernel_rfl PRE_first_tail_x15_r0_body.fjaD53 : Nat.ble 2716167 PRE_first_tail_x15_r0_body.kd53.n0 = true
kernel_rfl PRE_first_tail_x15_r0_body.fxn53 : Nat.ble 19240 PRE_first_tail_x15_r0_body.kd53.nh0 = true
kernel_rfl PRE_first_tail_x15_r0_body.fnn53 : Nat.ble 16333 PRE_first_tail_x15_r0_body.kd53.nn0 = true
kernel_rfl PRE_first_tail_x15_r0_body.fxb53 : Nat.ble 19240 RData.bigHi = true
kernel_rfl PRE_first_tail_x15_r0_body.fheap53 : (PTrie.keysA PRE_first_tail_x15_r0_body.kd53.heap).all (Nat.ble (⟨19240, 16333, 2716167, 2320⟩ : Conv.Cnt).ja) = true
kernel_rfl PRE_first_tail_x15_r0_body.fhnd53 : (PTrie.keysA PRE_first_tail_x15_r0_body.kd53.hnd).all (Nat.ble (⟨19240, 16333, 2716167, 2320⟩ : Conv.Cnt).xn) = true
kernel_rfl PRE_first_tail_x15_r0_body.fnode53 : (PTrie.keysA PRE_first_tail_x15_r0_body.kd53.node).all (Nat.ble (⟨19240, 16333, 2716167, 2320⟩ : Conv.Cnt).nn) = true
/-- The compaction map fixes the call's names. -/
theorem PRE_first_tail_x15_r0_body.cfix53 : Conv.FixOld (⟨19240, 16333, 2716167, 2320⟩ : Conv.Cnt) PRE_first_tail_x15_r0_body.kappa53 :=
  Conv.fixOld_compact (Nat.le_of_ble_eq_true PRE_first_tail_x15_r0_body.fja53) (Nat.le_of_ble_eq_true PRE_first_tail_x15_r0_body.fn53) (Nat.le_of_ble_eq_true PRE_first_tail_x15_r0_body.fjaD53) (Nat.le_of_ble_eq_true PRE_first_tail_x15_r0_body.fxn53) (Nat.le_of_ble_eq_true PRE_first_tail_x15_r0_body.fnn53) (Nat.le_of_ble_eq_true PRE_first_tail_x15_r0_body.fxb53) PRE_first_tail_x15_r0_body.fheap53 PRE_first_tail_x15_r0_body.fhnd53 PRE_first_tail_x15_r0_body.fnode53
kernel_rfl PRE_first_tail_x15_r0_body.fcxn53 : (⟨19240, 16333, 2716167, 2320⟩ : Conv.Cnt).xn = (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s472.ffi).mlx.next
kernel_rfl PRE_first_tail_x15_r0_body.fcnn53 : (⟨19240, 16333, 2716167, 2320⟩ : Conv.Cnt).nn = (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s472.ffi).mlx.nnext
kernel_rfl PRE_first_tail_x15_r0_body.fle053 : (Nat.ble (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s472.ffi).mlx.next PRE_first_tail_x15_r0_body.cx0_53.mlx.next && Nat.ble (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s472.ffi).mlx.nnext PRE_first_tail_x15_r0_body.cx0_53.mlx.nnext && Nat.ble (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s472.ffi).mlx.next RData.bigHi) = true
kernel_rfl PRE_first_tail_x15_r0_body.fnk53 : (PTrie.keysA PRE_first_tail_x15_r0_body.kd53.node).all (Nat.ble (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s472.ffi).mlx.nnext) = true
-- the merged state keeps the call's entries off the stage's footprint
kernel_rfl PRE_first_tail_x15_r0_body.f1A53 : PRE_first_tail_x15_r0_body.cx1_53.mlx.arrs = Stage.setAll (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s472.ffi).mlx.arrs (PRE_first_tail_x15_r0_body.cwS53.filterMap fun i => (PRE_first_tail_x15_r0_body.cx1_53.mlx.arrs.get i).map (i, ·))
kernel_rfl PRE_first_tail_x15_r0_body.f1O53 : PRE_first_tail_x15_r0_body.cx1_53.mlx.objs = Stage.setAll (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s472.ffi).mlx.objs (PRE_first_tail_x15_r0_body.cwS53.filterMap fun i => (PRE_first_tail_x15_r0_body.cx1_53.mlx.objs.get i).map (i, ·))
kernel_rfl PRE_first_tail_x15_r0_body.f1N53 : PRE_first_tail_x15_r0_body.cx1_53.mlx.nodes = Stage.setAll (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s472.ffi).mlx.nodes (PRE_first_tail_x15_r0_body.cnS53.filterMap fun i => (PRE_first_tail_x15_r0_body.cx1_53.mlx.nodes.get i).map (i, ·))
kernel_rfl PRE_first_tail_x15_r0_body.f1I53 : PRE_first_tail_x15_r0_body.cx1_53.mlx.items = Stage.setAll (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s472.ffi).mlx.items (PRE_first_tail_x15_r0_body.ciS53.filterMap fun i => (PRE_first_tail_x15_r0_body.cx1_53.mlx.items.get i).map (i, ·))
kernel_rfl PRE_first_tail_x15_r0_body.fbd53 : (PRE_first_tail_x15_r0_body.clo53 ++ PRE_first_tail_x15_r0_body.cln53 ++ PRE_first_tail_x15_r0_body.cli53 ++ PRE_first_tail_x15_r0_body.cwS53 ++ PRE_first_tail_x15_r0_body.cnS53 ++ PRE_first_tail_x15_r0_body.ciS53).all (fun i => Nat.blt (i / 4096) (4 ^ 31)) = true
kernel_rfl PRE_first_tail_x15_r0_body.fincW53 : PRE_first_tail_x15_r0_body.cwS53.all (fun h => !Nat.blt h (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s472.ffi).mlx.next || PRE_first_tail_x15_r0_body.clo53.contains h) = true
kernel_rfl PRE_first_tail_x15_r0_body.fincI53 : PRE_first_tail_x15_r0_body.ciS53.all (fun k => !Nat.blt k (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s472.ffi).mlx.nnext || PRE_first_tail_x15_r0_body.cli53.contains k) = true
kernel_rfl PRE_first_tail_x15_r0_body.fincN53 : PRE_first_tail_x15_r0_body.cnS53.all (Nat.ble (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s472.ffi).mlx.nnext) = true
kernel_rfl PRE_first_tail_x15_r0_body.flnF53 : PRE_first_tail_x15_r0_body.cln53.all (Nat.ble (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s472.ffi).mlx.nnext) = true
-- the checks over the changed lists
kernel_rfl PRE_first_tail_x15_r0_body.fh53 : PRE_first_tail_x15_r0_body.clo53.all (handleOK PRE_first_tail_x15_r0_body.kappa53 PRE_first_tail_x15_r0_body.P53.lo PRE_first_tail_x15_r0_body.cx0_53.mlx PRE_first_tail_x15_r0_body.cx1_53.mlx) = true
kernel_rfl PRE_first_tail_x15_r0_body.fo53 : PRE_first_tail_x15_r0_body.clo53.map (fun h => PRE_first_tail_x15_r0_body.cx1_53.mlx.objs.get (PRE_first_tail_x15_r0_body.kappa53.handle h)) = PRE_first_tail_x15_r0_body.clo53.map (fun h => (PRE_first_tail_x15_r0_body.cx0_53.mlx.objs.get h).map PRE_first_tail_x15_r0_body.kappa53.nobj)
kernel_rfl PRE_first_tail_x15_r0_body.fok53 : PRE_first_tail_x15_r0_body.clo53.all (objOK PRE_first_tail_x15_r0_body.kappa53 PRE_first_tail_x15_r0_body.P53.NL PRE_first_tail_x15_r0_body.cx0_53.mlx) = true
kernel_rfl PRE_first_tail_x15_r0_body.fnd53 : PRE_first_tail_x15_r0_body.cln53.all (nodeOKF PRE_first_tail_x15_r0_body.kappa53 PRE_first_tail_x15_r0_body.P53 PRE_first_tail_x15_r0_body.cx0_53.mlx PRE_first_tail_x15_r0_body.cx1_53.mlx) = true
kernel_rfl PRE_first_tail_x15_r0_body.fp53 : ((PRE_first_tail_x15_r0_body.cln53.filter (fullB PRE_first_tail_x15_r0_body.P53))).map (fun i => (PRE_first_tail_x15_r0_body.cx1_53.mlx.nodes.get (PRE_first_tail_x15_r0_body.kappa53.node i)).map Host.Mlx.Ffi.Node.prim) =
  ((PRE_first_tail_x15_r0_body.cln53.filter (fullB PRE_first_tail_x15_r0_body.P53))).map (fun i => (PRE_first_tail_x15_r0_body.cx0_53.mlx.nodes.get i).map fun nd => PRE_first_tail_x15_r0_body.kappa53.prim nd.prim)
kernel_rfl PRE_first_tail_x15_r0_body.fnordI53 : incrB PRE_first_tail_x15_r0_body.kd53.nodeF (List.range' 16333 0) = true
kernel_rfl PRE_first_tail_x15_r0_body.fnordK53 : (PTrie.keysA PRE_first_tail_x15_r0_body.kd53.node).all (fun k => Nat.ble 16333 k && Nat.blt k 16333) = true
kernel_rfl PRE_first_tail_x15_r0_body.fnordL53 : (PRE_first_tail_x15_r0_body.cln53.filter (Nat.ble PRE_first_tail_x15_r0_body.P53.N0)).all (fun i => Nat.ble i (PRE_first_tail_x15_r0_body.kd53.nodeF i) && (Nat.blt i 16333 || Nat.ble PRE_first_tail_x15_r0_body.kd53.nn0 i)) = true
theorem PRE_first_tail_x15_r0_body.fnord53 : (PRE_first_tail_x15_r0_body.cln53.filter (Nat.ble PRE_first_tail_x15_r0_body.P53.N0)).all (fun i => Nat.ble i (PRE_first_tail_x15_r0_body.kd53.nodeF i) &&
    (PTrie.keysA PRE_first_tail_x15_r0_body.kd53.node).all fun j => !Nat.blt j i || Nat.blt (PRE_first_tail_x15_r0_body.kd53.nodeF j) (PRE_first_tail_x15_r0_body.kd53.nodeF i)) = true :=
  cnord_of PRE_first_tail_x15_r0_body.cnlow53 PRE_first_tail_x15_r0_body.cnn153 PRE_first_tail_x15_r0_body.fnordI53 PRE_first_tail_x15_r0_body.fnordK53 PRE_first_tail_x15_r0_body.fnordL53
kernel_rfl PRE_first_tail_x15_r0_body.fi53 : PRE_first_tail_x15_r0_body.cli53.all (pnB PRE_first_tail_x15_r0_body.cx0_53.mlx) = true
kernel_rfl PRE_first_tail_x15_r0_body.fii53 : PRE_first_tail_x15_r0_body.cli53.all (fun k => decide (PRE_first_tail_x15_r0_body.cx1_53.mlx.items.get (PRE_first_tail_x15_r0_body.kappa53.node k) = (PRE_first_tail_x15_r0_body.cx0_53.mlx.items.get k).map PRE_first_tail_x15_r0_body.kappa53.nv)) = true
/-- **The compaction's footprint.** -/
theorem PRE_first_tail_x15_r0_body.cfoot53 (clean : Conv.NClean (⟨19240, 16333, 2716167, 2320⟩ : Conv.Cnt) (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s472.ffi).mlx) (hltC : ∀ h, PH (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s472.ffi).mlx h → h < (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s472.ffi).mlx.next) (nltC : ∀ i, PN (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s472.ffi).mlx i → i < (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s472.ffi).mlx.nnext) (itemsC : ∀ k v, (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s472.ffi).mlx.items.get k = some v → PN (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s472.ffi).mlx k) (tracedC : ∀ h o, (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s472.ffi).mlx.objs.get h = some o → ∀ i ∈ objTraces o, i < PRE_first_tail_x15_r0_body.P53.NL) (cl : SSt (· < 2320) PRE_first_tail_x15_r0_body.cx0_53.mlx) :
    Conv.MFoot PRE_first_tail_x15_r0_body.P53 2320 PRE_first_tail_x15_r0_body.kappa53 PRE_first_tail_x15_r0_body.kd53 PRE_first_tail_x15_r0_body.khinv53 PRE_first_tail_x15_r0_body.kninv53 (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s472.ffi).mlx PRE_first_tail_x15_r0_body.cx0_53.mlx PRE_first_tail_x15_r0_body.cx1_53.mlx (⟨19240, 16333, 2716167, 2320⟩ : Conv.Cnt) PRE_first_tail_x15_r0_body.clo53 PRE_first_tail_x15_r0_body.cln53 PRE_first_tail_x15_r0_body.cli53 PRE_first_tail_x15_r0_body.cwS53 PRE_first_tail_x15_r0_body.cnS53 PRE_first_tail_x15_r0_body.ciS53 :=
  ⟨rfl, rfl, rfl, PRE_first_tail_x15_r0_body.cnh053, PRE_first_tail_x15_r0_body.cnh153, PRE_first_tail_x15_r0_body.cnn053, PRE_first_tail_x15_r0_body.cnn153, PRE_first_tail_x15_r0_body.cplo53, PRE_first_tail_x15_r0_body.ccnt53, PRE_first_tail_x15_r0_body.cnband53, PRE_first_tail_x15_r0_body.chbelow53, PRE_first_tail_x15_r0_body.chren53, PRE_first_tail_x15_r0_body.cband53, PRE_first_tail_x15_r0_body.cnh1pos53, PRE_first_tail_x15_r0_body.cnren53, PRE_first_tail_x15_r0_body.cnlow53, PRE_first_tail_x15_r0_body.cabs0a53, PRE_first_tail_x15_r0_body.cabs0b53, PRE_first_tail_x15_r0_body.ctok153, PRE_first_tail_x15_r0_body.cpend53, PRE_first_tail_x15_r0_body.cerrh53, PRE_first_tail_x15_r0_body.cfiles53, PRE_first_tail_x15_r0_body.carch53, PRE_first_tail_x15_r0_body.csizes53, PRE_first_tail_x15_r0_body.cwired53, PRE_first_tail_x15_r0_body.cfix53, clean, PRE_first_tail_x15_r0_body.fcxn53, PRE_first_tail_x15_r0_body.fcnn53, hltC, nltC, itemsC, tracedC, cl, PRE_first_tail_x15_r0_body.fle053, PRE_first_tail_x15_r0_body.fnk53, PRE_first_tail_x15_r0_body.ckA53, PRE_first_tail_x15_r0_body.cobjsK53, PRE_first_tail_x15_r0_body.cnodesK53, PRE_first_tail_x15_r0_body.citemsK53, PRE_first_tail_x15_r0_body.f1A53, PRE_first_tail_x15_r0_body.f1O53, PRE_first_tail_x15_r0_body.f1N53, PRE_first_tail_x15_r0_body.f1I53, PRE_first_tail_x15_r0_body.fbd53, PRE_first_tail_x15_r0_body.fincW53, PRE_first_tail_x15_r0_body.fincI53, PRE_first_tail_x15_r0_body.fincN53, PRE_first_tail_x15_r0_body.flnF53, PRE_first_tail_x15_r0_body.fh53, PRE_first_tail_x15_r0_body.fo53, PRE_first_tail_x15_r0_body.fok53, PRE_first_tail_x15_r0_body.fnd53, PRE_first_tail_x15_r0_body.fp53, PRE_first_tail_x15_r0_body.fnord53, PRE_first_tail_x15_r0_body.fi53, PRE_first_tail_x15_r0_body.fii53⟩
theorem PRE_first_tail_x15_r0_body.cnshift53 (clean : Conv.NClean (⟨19240, 16333, 2716167, 2320⟩ : Conv.Cnt) (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s472.ffi).mlx) (hltC : ∀ h, PH (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s472.ffi).mlx h → h < (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s472.ffi).mlx.next) (nltC : ∀ i, PN (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s472.ffi).mlx i → i < (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s472.ffi).mlx.nnext) (itemsC : ∀ k v, (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s472.ffi).mlx.items.get k = some v → PN (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s472.ffi).mlx k) (tracedC : ∀ h o, (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s472.ffi).mlx.objs.get h = some o → ∀ i ∈ objTraces o, i < PRE_first_tail_x15_r0_body.P53.NL) (cl : SSt (· < 2320) PRE_first_tail_x15_r0_body.cx0_53.mlx) : NShift PRE_first_tail_x15_r0_body.P53 2320 PRE_first_tail_x15_r0_body.kappa53 PRE_first_tail_x15_r0_body.cx0_53 PRE_first_tail_x15_r0_body.cx1_53 :=
  Conv.nshift_of_foot (PRE_first_tail_x15_r0_body.cfoot53 clean hltC nltC itemsC tracedC cl) PRE_first_tail_x15_r0_body.chost53 (compact_a_eq PRE_first_tail_x15_r0_body.ckn053 PRE_first_tail_x15_r0_body.ckn153 PRE_first_tail_x15_r0_body.ckheap53 PRE_first_tail_x15_r0_body.ckpl53)

-- the observers: the layers' states at the call, the canonical and the merged state, their footprints and checks
noncomputable def PRE_first_tail_x15_r0_body.fxC_53 : PTrie Unit := (Host.Ts.Sim.Full.freedOf PRE_first_tail_x15_r0_body.s472.ffi).getD PTrie.nil
noncomputable def PRE_first_tail_x15_r0_body.krC_53 : Host.Load.Layers.KRec := (Host.Ts.Sim.Full.krecOf PRE_first_tail_x15_r0_body.s472.ffi).getD Host.Load.Layers.KRec.empty
kernel_rfl PRE_first_tail_x15_r0_body.ofxC_53 : (Host.Ts.Sim.Full.freedOf PRE_first_tail_x15_r0_body.s472.ffi) = some PRE_first_tail_x15_r0_body.fxC_53
kernel_rfl PRE_first_tail_x15_r0_body.okrC_53 : (Host.Ts.Sim.Full.krecOf PRE_first_tail_x15_r0_body.s472.ffi) = some PRE_first_tail_x15_r0_body.krC_53
noncomputable def PRE_first_tail_x15_r0_body.fx0_53 : PTrie Unit := (Host.Ts.Sim.Full.freedOf PRE_first_tail_x15_r0_body.s474.ffi).getD PTrie.nil
noncomputable def PRE_first_tail_x15_r0_body.kr0_53 : Host.Load.Layers.KRec := (Host.Ts.Sim.Full.krecOf PRE_first_tail_x15_r0_body.s474.ffi).getD Host.Load.Layers.KRec.empty
kernel_rfl PRE_first_tail_x15_r0_body.ofx0_53 : (Host.Ts.Sim.Full.freedOf PRE_first_tail_x15_r0_body.s474.ffi) = some PRE_first_tail_x15_r0_body.fx0_53
kernel_rfl PRE_first_tail_x15_r0_body.okr0_53 : (Host.Ts.Sim.Full.krecOf PRE_first_tail_x15_r0_body.s474.ffi) = some PRE_first_tail_x15_r0_body.kr0_53
noncomputable def PRE_first_tail_x15_r0_body.fx1_53 : PTrie Unit := (Host.Ts.Sim.Full.freedOf PRE_first_tail_x15_r0_body.s473.ffi).getD PTrie.nil
noncomputable def PRE_first_tail_x15_r0_body.kr1_53 : Host.Load.Layers.KRec := (Host.Ts.Sim.Full.krecOf PRE_first_tail_x15_r0_body.s473.ffi).getD Host.Load.Layers.KRec.empty
kernel_rfl PRE_first_tail_x15_r0_body.ofx1_53 : (Host.Ts.Sim.Full.freedOf PRE_first_tail_x15_r0_body.s473.ffi) = some PRE_first_tail_x15_r0_body.fx1_53
kernel_rfl PRE_first_tail_x15_r0_body.okr1_53 : (Host.Ts.Sim.Full.krecOf PRE_first_tail_x15_r0_body.s473.ffi) = some PRE_first_tail_x15_r0_body.kr1_53
kernel_rfl PRE_first_tail_x15_r0_body.ff053 : PRE_first_tail_x15_r0_body.fx0_53 = Stage.setAll PRE_first_tail_x15_r0_body.fxC_53 (PRE_first_tail_x15_r0_body.clo53.filterMap fun i => (PRE_first_tail_x15_r0_body.fx0_53.get i).map (i, ·))
kernel_rfl PRE_first_tail_x15_r0_body.ff153 : PRE_first_tail_x15_r0_body.fx1_53 = Stage.setAll PRE_first_tail_x15_r0_body.fxC_53 (PRE_first_tail_x15_r0_body.cwS53.filterMap fun i => (PRE_first_tail_x15_r0_body.fx1_53.get i).map (i, ·))
kernel_rfl PRE_first_tail_x15_r0_body.ffck53 : freedLB PRE_first_tail_x15_r0_body.kappa53 PRE_first_tail_x15_r0_body.cx0_53.mlx PRE_first_tail_x15_r0_body.fx0_53 PRE_first_tail_x15_r0_body.fx1_53 PRE_first_tail_x15_r0_body.clo53 = true
kernel_rfl PRE_first_tail_x15_r0_body.fkf053 : PRE_first_tail_x15_r0_body.kr0_53.flags = Stage.setAll PRE_first_tail_x15_r0_body.krC_53.flags (PRE_first_tail_x15_r0_body.clo53.filterMap fun i => (PRE_first_tail_x15_r0_body.kr0_53.flags.get i).map (i, ·))
kernel_rfl PRE_first_tail_x15_r0_body.fkt053 : PRE_first_tail_x15_r0_body.kr0_53.targs = Stage.setAll PRE_first_tail_x15_r0_body.krC_53.targs (PRE_first_tail_x15_r0_body.clo53.filterMap fun i => (PRE_first_tail_x15_r0_body.kr0_53.targs.get i).map (i, ·))
kernel_rfl PRE_first_tail_x15_r0_body.fkf153 : PRE_first_tail_x15_r0_body.kr1_53.flags = Stage.setAll PRE_first_tail_x15_r0_body.krC_53.flags (PRE_first_tail_x15_r0_body.cwS53.filterMap fun i => (PRE_first_tail_x15_r0_body.kr1_53.flags.get i).map (i, ·))
kernel_rfl PRE_first_tail_x15_r0_body.fkt153 : PRE_first_tail_x15_r0_body.kr1_53.targs = Stage.setAll PRE_first_tail_x15_r0_body.krC_53.targs (PRE_first_tail_x15_r0_body.cwS53.filterMap fun i => (PRE_first_tail_x15_r0_body.kr1_53.targs.get i).map (i, ·))
kernel_rfl PRE_first_tail_x15_r0_body.fkck53 : krecLB PRE_first_tail_x15_r0_body.kappa53 2320 PRE_first_tail_x15_r0_body.cx0_53.mlx PRE_first_tail_x15_r0_body.kr0_53 PRE_first_tail_x15_r0_body.kr1_53 PRE_first_tail_x15_r0_body.clo53 = true
kernel_rfl PRE_first_tail_x15_r0_body.fkn53 : Nat.ble 2320 2320 = true
-- the bridge and the pending traces' regions
kernel_rfl PRE_first_tail_x15_r0_body.cbridge53 : Host.Ts.Sim.Full.bridgeOf PRE_first_tail_x15_r0_body.s473.ffi = Host.Ts.Sim.Full.bridgeOf PRE_first_tail_x15_r0_body.s474.ffi
kernel_rfl PRE_first_tail_x15_r0_body.cpendR53 : pendRegB PRE_first_tail_x15_r0_body.kappa53 (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s474.ffi).mlx = true
kernel_rfl PRE_first_tail_x15_r0_body.cpendLe53 : Nat.ble (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s474.ffi).mlx.next (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s473.ffi).mlx.next = true
/-- **The compaction's native shift**, given the call's bookkeeping, its relation's facts (the model's and the
observers') and the canonical closedness. -/
theorem PRE_first_tail_x15_r0_body.cshift53 (clean : Conv.NClean (⟨19240, 16333, 2716167, 2320⟩ : Conv.Cnt) (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s472.ffi).mlx) (hltC : ∀ h, PH (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s472.ffi).mlx h → h < (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s472.ffi).mlx.next) (nltC : ∀ i, PN (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s472.ffi).mlx i → i < (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s472.ffi).mlx.nnext) (itemsC : ∀ k v, (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s472.ffi).mlx.items.get k = some v → PN (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s472.ffi).mlx k) (tracedC : ∀ h o, (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s472.ffi).mlx.objs.get h = some o → ∀ i ∈ objTraces o, i < PRE_first_tail_x15_r0_body.P53.NL) (cl : SSt (· < 2320) PRE_first_tail_x15_r0_body.cx0_53.mlx)
    (hobjC : ∀ h, PRE_first_tail_x15_r0_body.fxC_53.get h = some () → ((Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s472.ffi).mlx.objs.get h).isSome = true)
    (hfC : ∀ h, (PRE_first_tail_x15_r0_body.krC_53.flags.get h).isSome = true → ((Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s472.ffi).mlx.objs.get h).isSome = true)
    (htC : ∀ h, (PRE_first_tail_x15_r0_body.krC_53.targs.get h).isSome = true → ((Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s472.ffi).mlx.objs.get h).isSome = true)
    (hclC : ∀ h l, PRE_first_tail_x15_r0_body.krC_53.targs.get h = some l → Host.Ts.Sim.Full.STargs (· < (⟨19240, 16333, 2716167, 2320⟩ : Conv.Cnt).n) l) :
    Conv.FullShiftQ PRE_first_tail_x15_r0_body.P53 2320 PRE_first_tail_x15_r0_body.kappa53 PRE_first_tail_x15_r0_body.s474.ffi PRE_first_tail_x15_r0_body.s473.ffi :=
  ⟨PRE_first_tail_x15_r0_body.cnshift53 clean hltC nltC itemsC tracedC cl, PRE_first_tail_x15_r0_body.cqueue53, fun t ht => bSN_sound (List.all_eq_true.mp PRE_first_tail_x15_r0_body.ctokSupp53 t ht),
    PRE_first_tail_x15_r0_body.cbridge53,
    liveShift_foot (x0' := Host.Ts.Sim.Full.mlxOf PRE_first_tail_x15_r0_body.s474.ffi) (x1' := Host.Ts.Sim.Full.mlxOf PRE_first_tail_x15_r0_body.s473.ffi) (PRE_first_tail_x15_r0_body.cfoot53 clean hltC nltC itemsC tracedC cl) rfl PRE_first_tail_x15_r0_body.ofx0_53 PRE_first_tail_x15_r0_body.ofx1_53 hobjC PRE_first_tail_x15_r0_body.ff053 PRE_first_tail_x15_r0_body.ff153 PRE_first_tail_x15_r0_body.ffck53,
    kernShift_foot (x0' := Host.Ts.Sim.Full.mlxOf PRE_first_tail_x15_r0_body.s474.ffi) (x1' := Host.Ts.Sim.Full.mlxOf PRE_first_tail_x15_r0_body.s473.ffi) (PRE_first_tail_x15_r0_body.cfoot53 clean hltC nltC itemsC tracedC cl) rfl PRE_first_tail_x15_r0_body.okr0_53 PRE_first_tail_x15_r0_body.okr1_53 (Nat.le_of_ble_eq_true PRE_first_tail_x15_r0_body.fkn53) hfC htC hclC
      PRE_first_tail_x15_r0_body.fkf053 PRE_first_tail_x15_r0_body.fkt053 PRE_first_tail_x15_r0_body.fkf153 PRE_first_tail_x15_r0_body.fkt153 PRE_first_tail_x15_r0_body.fkck53,
    pendReg_of rfl PRE_first_tail_x15_r0_body.cnh053 PRE_first_tail_x15_r0_body.cnh153 (Nat.le_of_ble_eq_true PRE_first_tail_x15_r0_body.cpendLe53) PRE_first_tail_x15_r0_body.cpendR53⟩

end Host.Load.Run.Tpl
