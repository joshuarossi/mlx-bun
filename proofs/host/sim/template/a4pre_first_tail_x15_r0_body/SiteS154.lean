import host.sim.template.a4pre_first_tail_x15_r0_body.SiteCl154
import host.sim.conv.CompactFull
import host.sim.template.FootGen
set_option Elab.async false
namespace Host.Load.Run.Tpl
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
open Host.Ts Host.Ts.Sim Host.Ts.Sim.Template

/-! The compaction's native shift at call site 154 from its footprint (`Conv.nshift_of_foot`), and the observers'
(`liveShift_foot`, `kernShift_foot`): `Conv.FullShiftQ` for `Conv.full_compactQ`, given the call's bookkeeping and its
relation's facts. -/

/-- The load parameters of the chain (band-free: its start's node counter as `NL` and `N0`). -/
def PRE_first_tail_x15_r0_body.Pc154 : LoadP := ⟨18151, 131072, 1099511627776, 15235, 15235, []⟩
/-- The site's band raised to the map's checked fixed-node prefix, including newly recorded closure traces. -/
def PRE_first_tail_x15_r0_body.P154 : LoadP := PRE_first_tail_x15_r0_body.Pc154.raise 18336
kernel_rfl PRE_first_tail_x15_r0_body.craise154 : Nat.ble PRE_first_tail_x15_r0_body.Pc154.N0 18336 = true
theorem PRE_first_tail_x15_r0_body.raised154 : Host.Ts.Sim.Full.Raised PRE_first_tail_x15_r0_body.Pc154 PRE_first_tail_x15_r0_body.P154 :=
  .inr ⟨18336, rfl, Nat.le_of_ble_eq_true PRE_first_tail_x15_r0_body.craise154, rfl⟩
noncomputable abbrev PRE_first_tail_x15_r0_body.cx0_154 : Host.Load.LSt := clearTokens (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1492.ffi)
noncomputable abbrev PRE_first_tail_x15_r0_body.cx1_154 : Host.Load.LSt := clearTokens (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1491.ffi)
def PRE_first_tail_x15_r0_body.khinv154 : PTrie Nat := Stage.setAll PTrie.nil []
def PRE_first_tail_x15_r0_body.kninv154 : PTrie Nat := Stage.setAll PTrie.nil []
/-- The stage's footprint: its written and fresh handles, fresh nodes, written and fresh items. -/
def PRE_first_tail_x15_r0_body.cwS154 : List Nat := []
def PRE_first_tail_x15_r0_body.cnS154 : List Nat := List.range' 18336 0
def PRE_first_tail_x15_r0_body.ciS154 : List Nat := [] ++ List.range' 18336 0

-- the small checks (`MChecks`'s)
kernel_rfl PRE_first_tail_x15_r0_body.cnh0154 : PRE_first_tail_x15_r0_body.kd154.nh0 = PRE_first_tail_x15_r0_body.cx0_154.mlx.next
kernel_rfl PRE_first_tail_x15_r0_body.cnh1154 : PRE_first_tail_x15_r0_body.kd154.nh1 = PRE_first_tail_x15_r0_body.cx1_154.mlx.next
kernel_rfl PRE_first_tail_x15_r0_body.cnn0154 : PRE_first_tail_x15_r0_body.kd154.nn0 = PRE_first_tail_x15_r0_body.cx0_154.mlx.nnext
kernel_rfl PRE_first_tail_x15_r0_body.cnn1154 : PRE_first_tail_x15_r0_body.kd154.nn1 = PRE_first_tail_x15_r0_body.cx1_154.mlx.nnext
kernel_rfl PRE_first_tail_x15_r0_body.cplo154 : (Nat.blt 0 PRE_first_tail_x15_r0_body.P154.lo && Nat.ble PRE_first_tail_x15_r0_body.P154.lo PRE_first_tail_x15_r0_body.cx0_154.mlx.next && Nat.ble PRE_first_tail_x15_r0_body.P154.lo RData.bigHi && Nat.ble RData.bigHi PRE_first_tail_x15_r0_body.P154.E) = true
kernel_rfl PRE_first_tail_x15_r0_body.ccnt154 : (Nat.ble PRE_first_tail_x15_r0_body.cx0_154.mlx.next PRE_first_tail_x15_r0_body.cx1_154.mlx.next && Nat.ble PRE_first_tail_x15_r0_body.cx0_154.mlx.nnext PRE_first_tail_x15_r0_body.cx1_154.mlx.nnext) = true
kernel_rfl PRE_first_tail_x15_r0_body.cnband154 : (Nat.blt 0 PRE_first_tail_x15_r0_body.P154.NL && Nat.ble PRE_first_tail_x15_r0_body.P154.NL PRE_first_tail_x15_r0_body.P154.N0 && Nat.ble PRE_first_tail_x15_r0_body.P154.N0 PRE_first_tail_x15_r0_body.cx0_154.mlx.nnext) = true
kernel_rfl PRE_first_tail_x15_r0_body.chbelow154 : PRE_first_tail_x15_r0_body.kd154.checkHndBelow = true
kernel_rfl PRE_first_tail_x15_r0_body.chren154 : checkRenG PRE_first_tail_x15_r0_body.kd154.hnd PRE_first_tail_x15_r0_body.khinv154 (phB PRE_first_tail_x15_r0_body.cx0_154.mlx) = true
kernel_rfl PRE_first_tail_x15_r0_body.cband154 : PRE_first_tail_x15_r0_body.kd154.checkBand PRE_first_tail_x15_r0_body.P154.lo = true
kernel_rfl PRE_first_tail_x15_r0_body.cnh1pos154 : Nat.blt 0 PRE_first_tail_x15_r0_body.kd154.nh1 = true
kernel_rfl PRE_first_tail_x15_r0_body.cnren154 : checkRenG PRE_first_tail_x15_r0_body.kd154.node PRE_first_tail_x15_r0_body.kninv154 (pnB PRE_first_tail_x15_r0_body.cx0_154.mlx) = true
kernel_rfl PRE_first_tail_x15_r0_body.cnlow154 : (PTrie.keysA PRE_first_tail_x15_r0_body.kd154.node).all (fun j => Nat.ble PRE_first_tail_x15_r0_body.P154.NL j && Nat.blt (PRE_first_tail_x15_r0_body.kd154.nodeF j) PRE_first_tail_x15_r0_body.cx1_154.mlx.nnext) = true
kernel_rfl PRE_first_tail_x15_r0_body.cabs0a154 : PRE_first_tail_x15_r0_body.cx0_154.mlx.arrs.get 0 = none
kernel_rfl PRE_first_tail_x15_r0_body.cabs0b154 : PRE_first_tail_x15_r0_body.cx0_154.mlx.objs.get 0 = none
kernel_rfl PRE_first_tail_x15_r0_body.ctok1154 : PRE_first_tail_x15_r0_body.cx1_154.mlx.tokens = []
kernel_rfl PRE_first_tail_x15_r0_body.cpend154 : PRE_first_tail_x15_r0_body.cx1_154.mlx.pending = PRE_first_tail_x15_r0_body.cx0_154.mlx.pending.map PRE_first_tail_x15_r0_body.kappa154.pend
kernel_rfl PRE_first_tail_x15_r0_body.cerrh154 : PRE_first_tail_x15_r0_body.cx1_154.mlx.errh = PRE_first_tail_x15_r0_body.cx0_154.mlx.errh.map PRE_first_tail_x15_r0_body.kappa154.arg
kernel_rfl PRE_first_tail_x15_r0_body.cfiles154 : PRE_first_tail_x15_r0_body.cx1_154.mlx.files = PRE_first_tail_x15_r0_body.cx0_154.mlx.files
kernel_rfl PRE_first_tail_x15_r0_body.carch154 : PRE_first_tail_x15_r0_body.cx1_154.mlx.arch = PRE_first_tail_x15_r0_body.cx0_154.mlx.arch
kernel_rfl PRE_first_tail_x15_r0_body.csizes154 : PRE_first_tail_x15_r0_body.cx1_154.mlx.deviceSizes = PRE_first_tail_x15_r0_body.cx0_154.mlx.deviceSizes
kernel_rfl PRE_first_tail_x15_r0_body.cwired154 : PRE_first_tail_x15_r0_body.cx1_154.mlx.wired = PRE_first_tail_x15_r0_body.cx0_154.mlx.wired
kernel_rfl PRE_first_tail_x15_r0_body.chost154 : PRE_first_tail_x15_r0_body.cx1_154.host = PRE_first_tail_x15_r0_body.cx0_154.host
-- the compaction map's addresses are `PRE_first_tail_x15_r0_body.kd154`'s
kernel_rfl PRE_first_tail_x15_r0_body.ckn0154 : PRE_first_tail_x15_r0_body.kd154.n0 = 2796097
kernel_rfl PRE_first_tail_x15_r0_body.ckn1154 : PRE_first_tail_x15_r0_body.kd154.n1 = 2796099
kernel_rfl PRE_first_tail_x15_r0_body.ckheap154 : (PTrie.keysA PRE_first_tail_x15_r0_body.kd154.heap).all (fun x => Nat.ble 2796097 x) = true
kernel_rfl PRE_first_tail_x15_r0_body.ckpl154 : (List.range 0).all (fun j => decide (PRE_first_tail_x15_r0_body.kd154.heap.get (2796097 + j) = nth? PRE_first_tail_x15_r0_body.pl154 j)) = true
-- the map fixes the call's names (`Conv.fixOld_compact`), the call's counters
kernel_rfl PRE_first_tail_x15_r0_body.fja154 : Nat.ble 2796097 2796097 = true
kernel_rfl PRE_first_tail_x15_r0_body.fn154 : Nat.ble 6662 6662 = true
kernel_rfl PRE_first_tail_x15_r0_body.fjaD154 : Nat.ble 2796097 PRE_first_tail_x15_r0_body.kd154.n0 = true
kernel_rfl PRE_first_tail_x15_r0_body.fxn154 : Nat.ble 21242 PRE_first_tail_x15_r0_body.kd154.nh0 = true
kernel_rfl PRE_first_tail_x15_r0_body.fnn154 : Nat.ble 18336 PRE_first_tail_x15_r0_body.kd154.nn0 = true
kernel_rfl PRE_first_tail_x15_r0_body.fxb154 : Nat.ble 21242 RData.bigHi = true
kernel_rfl PRE_first_tail_x15_r0_body.fheap154 : (PTrie.keysA PRE_first_tail_x15_r0_body.kd154.heap).all (Nat.ble (⟨21242, 18336, 2796097, 6662⟩ : Conv.Cnt).ja) = true
kernel_rfl PRE_first_tail_x15_r0_body.fhnd154 : (PTrie.keysA PRE_first_tail_x15_r0_body.kd154.hnd).all (Nat.ble (⟨21242, 18336, 2796097, 6662⟩ : Conv.Cnt).xn) = true
kernel_rfl PRE_first_tail_x15_r0_body.fnode154 : (PTrie.keysA PRE_first_tail_x15_r0_body.kd154.node).all (Nat.ble (⟨21242, 18336, 2796097, 6662⟩ : Conv.Cnt).nn) = true
/-- The compaction map fixes the call's names. -/
theorem PRE_first_tail_x15_r0_body.cfix154 : Conv.FixOld (⟨21242, 18336, 2796097, 6662⟩ : Conv.Cnt) PRE_first_tail_x15_r0_body.kappa154 :=
  Conv.fixOld_compact (Nat.le_of_ble_eq_true PRE_first_tail_x15_r0_body.fja154) (Nat.le_of_ble_eq_true PRE_first_tail_x15_r0_body.fn154) (Nat.le_of_ble_eq_true PRE_first_tail_x15_r0_body.fjaD154) (Nat.le_of_ble_eq_true PRE_first_tail_x15_r0_body.fxn154) (Nat.le_of_ble_eq_true PRE_first_tail_x15_r0_body.fnn154) (Nat.le_of_ble_eq_true PRE_first_tail_x15_r0_body.fxb154) PRE_first_tail_x15_r0_body.fheap154 PRE_first_tail_x15_r0_body.fhnd154 PRE_first_tail_x15_r0_body.fnode154
kernel_rfl PRE_first_tail_x15_r0_body.fcxn154 : (⟨21242, 18336, 2796097, 6662⟩ : Conv.Cnt).xn = (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1490.ffi).mlx.next
kernel_rfl PRE_first_tail_x15_r0_body.fcnn154 : (⟨21242, 18336, 2796097, 6662⟩ : Conv.Cnt).nn = (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1490.ffi).mlx.nnext
kernel_rfl PRE_first_tail_x15_r0_body.fle0154 : (Nat.ble (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1490.ffi).mlx.next PRE_first_tail_x15_r0_body.cx0_154.mlx.next && Nat.ble (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1490.ffi).mlx.nnext PRE_first_tail_x15_r0_body.cx0_154.mlx.nnext && Nat.ble (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1490.ffi).mlx.next RData.bigHi) = true
kernel_rfl PRE_first_tail_x15_r0_body.fnk154 : (PTrie.keysA PRE_first_tail_x15_r0_body.kd154.node).all (Nat.ble (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1490.ffi).mlx.nnext) = true
-- the merged state keeps the call's entries off the stage's footprint
kernel_rfl PRE_first_tail_x15_r0_body.f1A154 : PRE_first_tail_x15_r0_body.cx1_154.mlx.arrs = Stage.setAll (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1490.ffi).mlx.arrs (PRE_first_tail_x15_r0_body.cwS154.filterMap fun i => (PRE_first_tail_x15_r0_body.cx1_154.mlx.arrs.get i).map (i, ·))
kernel_rfl PRE_first_tail_x15_r0_body.f1O154 : PRE_first_tail_x15_r0_body.cx1_154.mlx.objs = Stage.setAll (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1490.ffi).mlx.objs (PRE_first_tail_x15_r0_body.cwS154.filterMap fun i => (PRE_first_tail_x15_r0_body.cx1_154.mlx.objs.get i).map (i, ·))
kernel_rfl PRE_first_tail_x15_r0_body.f1N154 : PRE_first_tail_x15_r0_body.cx1_154.mlx.nodes = Stage.setAll (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1490.ffi).mlx.nodes (PRE_first_tail_x15_r0_body.cnS154.filterMap fun i => (PRE_first_tail_x15_r0_body.cx1_154.mlx.nodes.get i).map (i, ·))
kernel_rfl PRE_first_tail_x15_r0_body.f1I154 : PRE_first_tail_x15_r0_body.cx1_154.mlx.items = Stage.setAll (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1490.ffi).mlx.items (PRE_first_tail_x15_r0_body.ciS154.filterMap fun i => (PRE_first_tail_x15_r0_body.cx1_154.mlx.items.get i).map (i, ·))
kernel_rfl PRE_first_tail_x15_r0_body.fbd154 : (PRE_first_tail_x15_r0_body.clo154 ++ PRE_first_tail_x15_r0_body.cln154 ++ PRE_first_tail_x15_r0_body.cli154 ++ PRE_first_tail_x15_r0_body.cwS154 ++ PRE_first_tail_x15_r0_body.cnS154 ++ PRE_first_tail_x15_r0_body.ciS154).all (fun i => Nat.blt (i / 4096) (4 ^ 31)) = true
kernel_rfl PRE_first_tail_x15_r0_body.fincW154 : PRE_first_tail_x15_r0_body.cwS154.all (fun h => !Nat.blt h (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1490.ffi).mlx.next || PRE_first_tail_x15_r0_body.clo154.contains h) = true
kernel_rfl PRE_first_tail_x15_r0_body.fincI154 : PRE_first_tail_x15_r0_body.ciS154.all (fun k => !Nat.blt k (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1490.ffi).mlx.nnext || PRE_first_tail_x15_r0_body.cli154.contains k) = true
kernel_rfl PRE_first_tail_x15_r0_body.fincN154 : PRE_first_tail_x15_r0_body.cnS154.all (Nat.ble (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1490.ffi).mlx.nnext) = true
kernel_rfl PRE_first_tail_x15_r0_body.flnF154 : PRE_first_tail_x15_r0_body.cln154.all (Nat.ble (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1490.ffi).mlx.nnext) = true
-- the checks over the changed lists
kernel_rfl PRE_first_tail_x15_r0_body.fh154 : PRE_first_tail_x15_r0_body.clo154.all (handleOK PRE_first_tail_x15_r0_body.kappa154 PRE_first_tail_x15_r0_body.P154.lo PRE_first_tail_x15_r0_body.cx0_154.mlx PRE_first_tail_x15_r0_body.cx1_154.mlx) = true
kernel_rfl PRE_first_tail_x15_r0_body.fo154 : PRE_first_tail_x15_r0_body.clo154.map (fun h => PRE_first_tail_x15_r0_body.cx1_154.mlx.objs.get (PRE_first_tail_x15_r0_body.kappa154.handle h)) = PRE_first_tail_x15_r0_body.clo154.map (fun h => (PRE_first_tail_x15_r0_body.cx0_154.mlx.objs.get h).map PRE_first_tail_x15_r0_body.kappa154.nobj)
kernel_rfl PRE_first_tail_x15_r0_body.fok154 : PRE_first_tail_x15_r0_body.clo154.all (objOK PRE_first_tail_x15_r0_body.kappa154 PRE_first_tail_x15_r0_body.P154.NL PRE_first_tail_x15_r0_body.cx0_154.mlx) = true
kernel_rfl PRE_first_tail_x15_r0_body.fnd154 : PRE_first_tail_x15_r0_body.cln154.all (nodeOKF PRE_first_tail_x15_r0_body.kappa154 PRE_first_tail_x15_r0_body.P154 PRE_first_tail_x15_r0_body.cx0_154.mlx PRE_first_tail_x15_r0_body.cx1_154.mlx) = true
kernel_rfl PRE_first_tail_x15_r0_body.fp154 : ((PRE_first_tail_x15_r0_body.cln154.filter (fullB PRE_first_tail_x15_r0_body.P154))).map (fun i => (PRE_first_tail_x15_r0_body.cx1_154.mlx.nodes.get (PRE_first_tail_x15_r0_body.kappa154.node i)).map Host.Mlx.Ffi.Node.prim) =
  ((PRE_first_tail_x15_r0_body.cln154.filter (fullB PRE_first_tail_x15_r0_body.P154))).map (fun i => (PRE_first_tail_x15_r0_body.cx0_154.mlx.nodes.get i).map fun nd => PRE_first_tail_x15_r0_body.kappa154.prim nd.prim)
kernel_rfl PRE_first_tail_x15_r0_body.fnordI154 : incrB PRE_first_tail_x15_r0_body.kd154.nodeF (List.range' 18336 0) = true
kernel_rfl PRE_first_tail_x15_r0_body.fnordK154 : (PTrie.keysA PRE_first_tail_x15_r0_body.kd154.node).all (fun k => Nat.ble 18336 k && Nat.blt k 18336) = true
kernel_rfl PRE_first_tail_x15_r0_body.fnordL154 : (PRE_first_tail_x15_r0_body.cln154.filter (Nat.ble PRE_first_tail_x15_r0_body.P154.N0)).all (fun i => Nat.ble i (PRE_first_tail_x15_r0_body.kd154.nodeF i) && (Nat.blt i 18336 || Nat.ble PRE_first_tail_x15_r0_body.kd154.nn0 i)) = true
theorem PRE_first_tail_x15_r0_body.fnord154 : (PRE_first_tail_x15_r0_body.cln154.filter (Nat.ble PRE_first_tail_x15_r0_body.P154.N0)).all (fun i => Nat.ble i (PRE_first_tail_x15_r0_body.kd154.nodeF i) &&
    (PTrie.keysA PRE_first_tail_x15_r0_body.kd154.node).all fun j => !Nat.blt j i || Nat.blt (PRE_first_tail_x15_r0_body.kd154.nodeF j) (PRE_first_tail_x15_r0_body.kd154.nodeF i)) = true :=
  cnord_of PRE_first_tail_x15_r0_body.cnlow154 PRE_first_tail_x15_r0_body.cnn1154 PRE_first_tail_x15_r0_body.fnordI154 PRE_first_tail_x15_r0_body.fnordK154 PRE_first_tail_x15_r0_body.fnordL154
kernel_rfl PRE_first_tail_x15_r0_body.fi154 : PRE_first_tail_x15_r0_body.cli154.all (pnB PRE_first_tail_x15_r0_body.cx0_154.mlx) = true
kernel_rfl PRE_first_tail_x15_r0_body.fii154 : PRE_first_tail_x15_r0_body.cli154.all (fun k => decide (PRE_first_tail_x15_r0_body.cx1_154.mlx.items.get (PRE_first_tail_x15_r0_body.kappa154.node k) = (PRE_first_tail_x15_r0_body.cx0_154.mlx.items.get k).map PRE_first_tail_x15_r0_body.kappa154.nv)) = true
/-- **The compaction's footprint.** -/
theorem PRE_first_tail_x15_r0_body.cfoot154 (clean : Conv.NClean (⟨21242, 18336, 2796097, 6662⟩ : Conv.Cnt) (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1490.ffi).mlx) (hltC : ∀ h, PH (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1490.ffi).mlx h → h < (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1490.ffi).mlx.next) (nltC : ∀ i, PN (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1490.ffi).mlx i → i < (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1490.ffi).mlx.nnext) (itemsC : ∀ k v, (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1490.ffi).mlx.items.get k = some v → PN (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1490.ffi).mlx k) (tracedC : ∀ h o, (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1490.ffi).mlx.objs.get h = some o → ∀ i ∈ objTraces o, i < PRE_first_tail_x15_r0_body.P154.NL) (cl : SSt (· < 6662) PRE_first_tail_x15_r0_body.cx0_154.mlx) :
    Conv.MFoot PRE_first_tail_x15_r0_body.P154 6662 PRE_first_tail_x15_r0_body.kappa154 PRE_first_tail_x15_r0_body.kd154 PRE_first_tail_x15_r0_body.khinv154 PRE_first_tail_x15_r0_body.kninv154 (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1490.ffi).mlx PRE_first_tail_x15_r0_body.cx0_154.mlx PRE_first_tail_x15_r0_body.cx1_154.mlx (⟨21242, 18336, 2796097, 6662⟩ : Conv.Cnt) PRE_first_tail_x15_r0_body.clo154 PRE_first_tail_x15_r0_body.cln154 PRE_first_tail_x15_r0_body.cli154 PRE_first_tail_x15_r0_body.cwS154 PRE_first_tail_x15_r0_body.cnS154 PRE_first_tail_x15_r0_body.ciS154 :=
  ⟨rfl, rfl, rfl, PRE_first_tail_x15_r0_body.cnh0154, PRE_first_tail_x15_r0_body.cnh1154, PRE_first_tail_x15_r0_body.cnn0154, PRE_first_tail_x15_r0_body.cnn1154, PRE_first_tail_x15_r0_body.cplo154, PRE_first_tail_x15_r0_body.ccnt154, PRE_first_tail_x15_r0_body.cnband154, PRE_first_tail_x15_r0_body.chbelow154, PRE_first_tail_x15_r0_body.chren154, PRE_first_tail_x15_r0_body.cband154, PRE_first_tail_x15_r0_body.cnh1pos154, PRE_first_tail_x15_r0_body.cnren154, PRE_first_tail_x15_r0_body.cnlow154, PRE_first_tail_x15_r0_body.cabs0a154, PRE_first_tail_x15_r0_body.cabs0b154, PRE_first_tail_x15_r0_body.ctok1154, PRE_first_tail_x15_r0_body.cpend154, PRE_first_tail_x15_r0_body.cerrh154, PRE_first_tail_x15_r0_body.cfiles154, PRE_first_tail_x15_r0_body.carch154, PRE_first_tail_x15_r0_body.csizes154, PRE_first_tail_x15_r0_body.cwired154, PRE_first_tail_x15_r0_body.cfix154, clean, PRE_first_tail_x15_r0_body.fcxn154, PRE_first_tail_x15_r0_body.fcnn154, hltC, nltC, itemsC, tracedC, cl, PRE_first_tail_x15_r0_body.fle0154, PRE_first_tail_x15_r0_body.fnk154, PRE_first_tail_x15_r0_body.ckA154, PRE_first_tail_x15_r0_body.cobjsK154, PRE_first_tail_x15_r0_body.cnodesK154, PRE_first_tail_x15_r0_body.citemsK154, PRE_first_tail_x15_r0_body.f1A154, PRE_first_tail_x15_r0_body.f1O154, PRE_first_tail_x15_r0_body.f1N154, PRE_first_tail_x15_r0_body.f1I154, PRE_first_tail_x15_r0_body.fbd154, PRE_first_tail_x15_r0_body.fincW154, PRE_first_tail_x15_r0_body.fincI154, PRE_first_tail_x15_r0_body.fincN154, PRE_first_tail_x15_r0_body.flnF154, PRE_first_tail_x15_r0_body.fh154, PRE_first_tail_x15_r0_body.fo154, PRE_first_tail_x15_r0_body.fok154, PRE_first_tail_x15_r0_body.fnd154, PRE_first_tail_x15_r0_body.fp154, PRE_first_tail_x15_r0_body.fnord154, PRE_first_tail_x15_r0_body.fi154, PRE_first_tail_x15_r0_body.fii154⟩
theorem PRE_first_tail_x15_r0_body.cnshift154 (clean : Conv.NClean (⟨21242, 18336, 2796097, 6662⟩ : Conv.Cnt) (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1490.ffi).mlx) (hltC : ∀ h, PH (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1490.ffi).mlx h → h < (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1490.ffi).mlx.next) (nltC : ∀ i, PN (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1490.ffi).mlx i → i < (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1490.ffi).mlx.nnext) (itemsC : ∀ k v, (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1490.ffi).mlx.items.get k = some v → PN (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1490.ffi).mlx k) (tracedC : ∀ h o, (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1490.ffi).mlx.objs.get h = some o → ∀ i ∈ objTraces o, i < PRE_first_tail_x15_r0_body.P154.NL) (cl : SSt (· < 6662) PRE_first_tail_x15_r0_body.cx0_154.mlx) : NShift PRE_first_tail_x15_r0_body.P154 6662 PRE_first_tail_x15_r0_body.kappa154 PRE_first_tail_x15_r0_body.cx0_154 PRE_first_tail_x15_r0_body.cx1_154 :=
  Conv.nshift_of_foot (PRE_first_tail_x15_r0_body.cfoot154 clean hltC nltC itemsC tracedC cl) PRE_first_tail_x15_r0_body.chost154 (compact_a_eq PRE_first_tail_x15_r0_body.ckn0154 PRE_first_tail_x15_r0_body.ckn1154 PRE_first_tail_x15_r0_body.ckheap154 PRE_first_tail_x15_r0_body.ckpl154)

-- the observers: the layers' states at the call, the canonical and the merged state, their footprints and checks
noncomputable def PRE_first_tail_x15_r0_body.fxC_154 : PTrie Unit := (Host.Ts.Sim.Full.freedOf PRE_first_tail_x15_r0_body.s1490.ffi).getD PTrie.nil
noncomputable def PRE_first_tail_x15_r0_body.krC_154 : Host.Load.Layers.KRec := (Host.Ts.Sim.Full.krecOf PRE_first_tail_x15_r0_body.s1490.ffi).getD Host.Load.Layers.KRec.empty
kernel_rfl PRE_first_tail_x15_r0_body.ofxC_154 : (Host.Ts.Sim.Full.freedOf PRE_first_tail_x15_r0_body.s1490.ffi) = some PRE_first_tail_x15_r0_body.fxC_154
kernel_rfl PRE_first_tail_x15_r0_body.okrC_154 : (Host.Ts.Sim.Full.krecOf PRE_first_tail_x15_r0_body.s1490.ffi) = some PRE_first_tail_x15_r0_body.krC_154
noncomputable def PRE_first_tail_x15_r0_body.fx0_154 : PTrie Unit := (Host.Ts.Sim.Full.freedOf PRE_first_tail_x15_r0_body.s1492.ffi).getD PTrie.nil
noncomputable def PRE_first_tail_x15_r0_body.kr0_154 : Host.Load.Layers.KRec := (Host.Ts.Sim.Full.krecOf PRE_first_tail_x15_r0_body.s1492.ffi).getD Host.Load.Layers.KRec.empty
kernel_rfl PRE_first_tail_x15_r0_body.ofx0_154 : (Host.Ts.Sim.Full.freedOf PRE_first_tail_x15_r0_body.s1492.ffi) = some PRE_first_tail_x15_r0_body.fx0_154
kernel_rfl PRE_first_tail_x15_r0_body.okr0_154 : (Host.Ts.Sim.Full.krecOf PRE_first_tail_x15_r0_body.s1492.ffi) = some PRE_first_tail_x15_r0_body.kr0_154
noncomputable def PRE_first_tail_x15_r0_body.fx1_154 : PTrie Unit := (Host.Ts.Sim.Full.freedOf PRE_first_tail_x15_r0_body.s1491.ffi).getD PTrie.nil
noncomputable def PRE_first_tail_x15_r0_body.kr1_154 : Host.Load.Layers.KRec := (Host.Ts.Sim.Full.krecOf PRE_first_tail_x15_r0_body.s1491.ffi).getD Host.Load.Layers.KRec.empty
kernel_rfl PRE_first_tail_x15_r0_body.ofx1_154 : (Host.Ts.Sim.Full.freedOf PRE_first_tail_x15_r0_body.s1491.ffi) = some PRE_first_tail_x15_r0_body.fx1_154
kernel_rfl PRE_first_tail_x15_r0_body.okr1_154 : (Host.Ts.Sim.Full.krecOf PRE_first_tail_x15_r0_body.s1491.ffi) = some PRE_first_tail_x15_r0_body.kr1_154
kernel_rfl PRE_first_tail_x15_r0_body.ff0154 : PRE_first_tail_x15_r0_body.fx0_154 = Stage.setAll PRE_first_tail_x15_r0_body.fxC_154 (PRE_first_tail_x15_r0_body.clo154.filterMap fun i => (PRE_first_tail_x15_r0_body.fx0_154.get i).map (i, ·))
kernel_rfl PRE_first_tail_x15_r0_body.ff1154 : PRE_first_tail_x15_r0_body.fx1_154 = Stage.setAll PRE_first_tail_x15_r0_body.fxC_154 (PRE_first_tail_x15_r0_body.cwS154.filterMap fun i => (PRE_first_tail_x15_r0_body.fx1_154.get i).map (i, ·))
kernel_rfl PRE_first_tail_x15_r0_body.ffck154 : freedLB PRE_first_tail_x15_r0_body.kappa154 PRE_first_tail_x15_r0_body.cx0_154.mlx PRE_first_tail_x15_r0_body.fx0_154 PRE_first_tail_x15_r0_body.fx1_154 PRE_first_tail_x15_r0_body.clo154 = true
kernel_rfl PRE_first_tail_x15_r0_body.fkf0154 : PRE_first_tail_x15_r0_body.kr0_154.flags = Stage.setAll PRE_first_tail_x15_r0_body.krC_154.flags (PRE_first_tail_x15_r0_body.clo154.filterMap fun i => (PRE_first_tail_x15_r0_body.kr0_154.flags.get i).map (i, ·))
kernel_rfl PRE_first_tail_x15_r0_body.fkt0154 : PRE_first_tail_x15_r0_body.kr0_154.targs = Stage.setAll PRE_first_tail_x15_r0_body.krC_154.targs (PRE_first_tail_x15_r0_body.clo154.filterMap fun i => (PRE_first_tail_x15_r0_body.kr0_154.targs.get i).map (i, ·))
kernel_rfl PRE_first_tail_x15_r0_body.fkf1154 : PRE_first_tail_x15_r0_body.kr1_154.flags = Stage.setAll PRE_first_tail_x15_r0_body.krC_154.flags (PRE_first_tail_x15_r0_body.cwS154.filterMap fun i => (PRE_first_tail_x15_r0_body.kr1_154.flags.get i).map (i, ·))
kernel_rfl PRE_first_tail_x15_r0_body.fkt1154 : PRE_first_tail_x15_r0_body.kr1_154.targs = Stage.setAll PRE_first_tail_x15_r0_body.krC_154.targs (PRE_first_tail_x15_r0_body.cwS154.filterMap fun i => (PRE_first_tail_x15_r0_body.kr1_154.targs.get i).map (i, ·))
kernel_rfl PRE_first_tail_x15_r0_body.fkck154 : krecLB PRE_first_tail_x15_r0_body.kappa154 6662 PRE_first_tail_x15_r0_body.cx0_154.mlx PRE_first_tail_x15_r0_body.kr0_154 PRE_first_tail_x15_r0_body.kr1_154 PRE_first_tail_x15_r0_body.clo154 = true
kernel_rfl PRE_first_tail_x15_r0_body.fkn154 : Nat.ble 6662 6662 = true
-- the bridge and the pending traces' regions
kernel_rfl PRE_first_tail_x15_r0_body.cbridge154 : Host.Ts.Sim.Full.bridgeOf PRE_first_tail_x15_r0_body.s1491.ffi = Host.Ts.Sim.Full.bridgeOf PRE_first_tail_x15_r0_body.s1492.ffi
kernel_rfl PRE_first_tail_x15_r0_body.cpendR154 : pendRegB PRE_first_tail_x15_r0_body.kappa154 (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1492.ffi).mlx = true
kernel_rfl PRE_first_tail_x15_r0_body.cpendLe154 : Nat.ble (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1492.ffi).mlx.next (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1491.ffi).mlx.next = true
/-- **The compaction's native shift**, given the call's bookkeeping, its relation's facts (the model's and the
observers') and the canonical closedness. -/
theorem PRE_first_tail_x15_r0_body.cshift154 (clean : Conv.NClean (⟨21242, 18336, 2796097, 6662⟩ : Conv.Cnt) (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1490.ffi).mlx) (hltC : ∀ h, PH (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1490.ffi).mlx h → h < (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1490.ffi).mlx.next) (nltC : ∀ i, PN (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1490.ffi).mlx i → i < (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1490.ffi).mlx.nnext) (itemsC : ∀ k v, (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1490.ffi).mlx.items.get k = some v → PN (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1490.ffi).mlx k) (tracedC : ∀ h o, (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1490.ffi).mlx.objs.get h = some o → ∀ i ∈ objTraces o, i < PRE_first_tail_x15_r0_body.P154.NL) (cl : SSt (· < 6662) PRE_first_tail_x15_r0_body.cx0_154.mlx)
    (hobjC : ∀ h, PRE_first_tail_x15_r0_body.fxC_154.get h = some () → ((Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1490.ffi).mlx.objs.get h).isSome = true)
    (hfC : ∀ h, (PRE_first_tail_x15_r0_body.krC_154.flags.get h).isSome = true → ((Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1490.ffi).mlx.objs.get h).isSome = true)
    (htC : ∀ h, (PRE_first_tail_x15_r0_body.krC_154.targs.get h).isSome = true → ((Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1490.ffi).mlx.objs.get h).isSome = true)
    (hclC : ∀ h l, PRE_first_tail_x15_r0_body.krC_154.targs.get h = some l → Host.Ts.Sim.Full.STargs (· < (⟨21242, 18336, 2796097, 6662⟩ : Conv.Cnt).n) l) :
    Conv.FullShiftQ PRE_first_tail_x15_r0_body.P154 6662 PRE_first_tail_x15_r0_body.kappa154 PRE_first_tail_x15_r0_body.s1492.ffi PRE_first_tail_x15_r0_body.s1491.ffi :=
  ⟨PRE_first_tail_x15_r0_body.cnshift154 clean hltC nltC itemsC tracedC cl, PRE_first_tail_x15_r0_body.cqueue154, fun t ht => bSN_sound (List.all_eq_true.mp PRE_first_tail_x15_r0_body.ctokSupp154 t ht),
    PRE_first_tail_x15_r0_body.cbridge154,
    liveShift_foot (x0' := Host.Ts.Sim.Full.mlxOf PRE_first_tail_x15_r0_body.s1492.ffi) (x1' := Host.Ts.Sim.Full.mlxOf PRE_first_tail_x15_r0_body.s1491.ffi) (PRE_first_tail_x15_r0_body.cfoot154 clean hltC nltC itemsC tracedC cl) rfl PRE_first_tail_x15_r0_body.ofx0_154 PRE_first_tail_x15_r0_body.ofx1_154 hobjC PRE_first_tail_x15_r0_body.ff0154 PRE_first_tail_x15_r0_body.ff1154 PRE_first_tail_x15_r0_body.ffck154,
    kernShift_foot (x0' := Host.Ts.Sim.Full.mlxOf PRE_first_tail_x15_r0_body.s1492.ffi) (x1' := Host.Ts.Sim.Full.mlxOf PRE_first_tail_x15_r0_body.s1491.ffi) (PRE_first_tail_x15_r0_body.cfoot154 clean hltC nltC itemsC tracedC cl) rfl PRE_first_tail_x15_r0_body.okr0_154 PRE_first_tail_x15_r0_body.okr1_154 (Nat.le_of_ble_eq_true PRE_first_tail_x15_r0_body.fkn154) hfC htC hclC
      PRE_first_tail_x15_r0_body.fkf0154 PRE_first_tail_x15_r0_body.fkt0154 PRE_first_tail_x15_r0_body.fkf1154 PRE_first_tail_x15_r0_body.fkt1154 PRE_first_tail_x15_r0_body.fkck154,
    pendReg_of rfl PRE_first_tail_x15_r0_body.cnh0154 PRE_first_tail_x15_r0_body.cnh1154 (Nat.le_of_ble_eq_true PRE_first_tail_x15_r0_body.cpendLe154) PRE_first_tail_x15_r0_body.cpendR154⟩

end Host.Load.Run.Tpl
