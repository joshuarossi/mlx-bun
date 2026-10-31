import host.sim.template.a4pre_first_tail_x15_r0_body.SiteCl176
import host.sim.conv.CompactFull
import host.sim.template.FootGen
set_option Elab.async false
namespace Host.Load.Run.Tpl
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
open Host.Ts Host.Ts.Sim Host.Ts.Sim.Template

/-! The compaction's native shift at call site 176 from its footprint (`Conv.nshift_of_foot`), and the observers'
(`liveShift_foot`, `kernShift_foot`): `Conv.FullShiftQ` for `Conv.full_compactQ`, given the call's bookkeeping and its
relation's facts. -/

/-- The load parameters of the chain (band-free: its start's node counter as `NL` and `N0`). -/
def PRE_first_tail_x15_r0_body.Pc176 : LoadP := ⟨18151, 131072, 1099511627776, 15235, 15235, []⟩
/-- The site's band raised to the map's checked fixed-node prefix, including newly recorded closure traces. -/
def PRE_first_tail_x15_r0_body.P176 : LoadP := PRE_first_tail_x15_r0_body.Pc176.raise 18766
kernel_rfl PRE_first_tail_x15_r0_body.craise176 : Nat.ble PRE_first_tail_x15_r0_body.Pc176.N0 18766 = true
theorem PRE_first_tail_x15_r0_body.raised176 : Host.Ts.Sim.Full.Raised PRE_first_tail_x15_r0_body.Pc176 PRE_first_tail_x15_r0_body.P176 :=
  .inr ⟨18766, rfl, Nat.le_of_ble_eq_true PRE_first_tail_x15_r0_body.craise176, rfl⟩
noncomputable abbrev PRE_first_tail_x15_r0_body.cx0_176 : Host.Load.LSt := clearTokens (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1698.ffi)
noncomputable abbrev PRE_first_tail_x15_r0_body.cx1_176 : Host.Load.LSt := clearTokens (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1697.ffi)
def PRE_first_tail_x15_r0_body.khinv176 : PTrie Nat := Stage.setAll PTrie.nil []
def PRE_first_tail_x15_r0_body.kninv176 : PTrie Nat := Stage.setAll PTrie.nil []
/-- The stage's footprint: its written and fresh handles, fresh nodes, written and fresh items. -/
def PRE_first_tail_x15_r0_body.cwS176 : List Nat := []
def PRE_first_tail_x15_r0_body.cnS176 : List Nat := List.range' 18766 0
def PRE_first_tail_x15_r0_body.ciS176 : List Nat := [] ++ List.range' 18766 0

-- the small checks (`MChecks`'s)
kernel_rfl PRE_first_tail_x15_r0_body.cnh0176 : PRE_first_tail_x15_r0_body.kd176.nh0 = PRE_first_tail_x15_r0_body.cx0_176.mlx.next
kernel_rfl PRE_first_tail_x15_r0_body.cnh1176 : PRE_first_tail_x15_r0_body.kd176.nh1 = PRE_first_tail_x15_r0_body.cx1_176.mlx.next
kernel_rfl PRE_first_tail_x15_r0_body.cnn0176 : PRE_first_tail_x15_r0_body.kd176.nn0 = PRE_first_tail_x15_r0_body.cx0_176.mlx.nnext
kernel_rfl PRE_first_tail_x15_r0_body.cnn1176 : PRE_first_tail_x15_r0_body.kd176.nn1 = PRE_first_tail_x15_r0_body.cx1_176.mlx.nnext
kernel_rfl PRE_first_tail_x15_r0_body.cplo176 : (Nat.blt 0 PRE_first_tail_x15_r0_body.P176.lo && Nat.ble PRE_first_tail_x15_r0_body.P176.lo PRE_first_tail_x15_r0_body.cx0_176.mlx.next && Nat.ble PRE_first_tail_x15_r0_body.P176.lo RData.bigHi && Nat.ble RData.bigHi PRE_first_tail_x15_r0_body.P176.E) = true
kernel_rfl PRE_first_tail_x15_r0_body.ccnt176 : (Nat.ble PRE_first_tail_x15_r0_body.cx0_176.mlx.next PRE_first_tail_x15_r0_body.cx1_176.mlx.next && Nat.ble PRE_first_tail_x15_r0_body.cx0_176.mlx.nnext PRE_first_tail_x15_r0_body.cx1_176.mlx.nnext) = true
kernel_rfl PRE_first_tail_x15_r0_body.cnband176 : (Nat.blt 0 PRE_first_tail_x15_r0_body.P176.NL && Nat.ble PRE_first_tail_x15_r0_body.P176.NL PRE_first_tail_x15_r0_body.P176.N0 && Nat.ble PRE_first_tail_x15_r0_body.P176.N0 PRE_first_tail_x15_r0_body.cx0_176.mlx.nnext) = true
kernel_rfl PRE_first_tail_x15_r0_body.chbelow176 : PRE_first_tail_x15_r0_body.kd176.checkHndBelow = true
kernel_rfl PRE_first_tail_x15_r0_body.chren176 : checkRenG PRE_first_tail_x15_r0_body.kd176.hnd PRE_first_tail_x15_r0_body.khinv176 (phB PRE_first_tail_x15_r0_body.cx0_176.mlx) = true
kernel_rfl PRE_first_tail_x15_r0_body.cband176 : PRE_first_tail_x15_r0_body.kd176.checkBand PRE_first_tail_x15_r0_body.P176.lo = true
kernel_rfl PRE_first_tail_x15_r0_body.cnh1pos176 : Nat.blt 0 PRE_first_tail_x15_r0_body.kd176.nh1 = true
kernel_rfl PRE_first_tail_x15_r0_body.cnren176 : checkRenG PRE_first_tail_x15_r0_body.kd176.node PRE_first_tail_x15_r0_body.kninv176 (pnB PRE_first_tail_x15_r0_body.cx0_176.mlx) = true
kernel_rfl PRE_first_tail_x15_r0_body.cnlow176 : (PTrie.keysA PRE_first_tail_x15_r0_body.kd176.node).all (fun j => Nat.ble PRE_first_tail_x15_r0_body.P176.NL j && Nat.blt (PRE_first_tail_x15_r0_body.kd176.nodeF j) PRE_first_tail_x15_r0_body.cx1_176.mlx.nnext) = true
kernel_rfl PRE_first_tail_x15_r0_body.cabs0a176 : PRE_first_tail_x15_r0_body.cx0_176.mlx.arrs.get 0 = none
kernel_rfl PRE_first_tail_x15_r0_body.cabs0b176 : PRE_first_tail_x15_r0_body.cx0_176.mlx.objs.get 0 = none
kernel_rfl PRE_first_tail_x15_r0_body.ctok1176 : PRE_first_tail_x15_r0_body.cx1_176.mlx.tokens = []
kernel_rfl PRE_first_tail_x15_r0_body.cpend176 : PRE_first_tail_x15_r0_body.cx1_176.mlx.pending = PRE_first_tail_x15_r0_body.cx0_176.mlx.pending.map PRE_first_tail_x15_r0_body.kappa176.pend
kernel_rfl PRE_first_tail_x15_r0_body.cerrh176 : PRE_first_tail_x15_r0_body.cx1_176.mlx.errh = PRE_first_tail_x15_r0_body.cx0_176.mlx.errh.map PRE_first_tail_x15_r0_body.kappa176.arg
kernel_rfl PRE_first_tail_x15_r0_body.cfiles176 : PRE_first_tail_x15_r0_body.cx1_176.mlx.files = PRE_first_tail_x15_r0_body.cx0_176.mlx.files
kernel_rfl PRE_first_tail_x15_r0_body.carch176 : PRE_first_tail_x15_r0_body.cx1_176.mlx.arch = PRE_first_tail_x15_r0_body.cx0_176.mlx.arch
kernel_rfl PRE_first_tail_x15_r0_body.csizes176 : PRE_first_tail_x15_r0_body.cx1_176.mlx.deviceSizes = PRE_first_tail_x15_r0_body.cx0_176.mlx.deviceSizes
kernel_rfl PRE_first_tail_x15_r0_body.cwired176 : PRE_first_tail_x15_r0_body.cx1_176.mlx.wired = PRE_first_tail_x15_r0_body.cx0_176.mlx.wired
kernel_rfl PRE_first_tail_x15_r0_body.chost176 : PRE_first_tail_x15_r0_body.cx1_176.host = PRE_first_tail_x15_r0_body.cx0_176.host
-- the compaction map's addresses are `PRE_first_tail_x15_r0_body.kd176`'s
kernel_rfl PRE_first_tail_x15_r0_body.ckn0176 : PRE_first_tail_x15_r0_body.kd176.n0 = 2812604
kernel_rfl PRE_first_tail_x15_r0_body.ckn1176 : PRE_first_tail_x15_r0_body.kd176.n1 = 2812623
kernel_rfl PRE_first_tail_x15_r0_body.ckheap176 : (PTrie.keysA PRE_first_tail_x15_r0_body.kd176.heap).all (fun x => Nat.ble 2812603 x) = true
kernel_rfl PRE_first_tail_x15_r0_body.ckpl176 : (List.range 1).all (fun j => decide (PRE_first_tail_x15_r0_body.kd176.heap.get (2812603 + j) = nth? PRE_first_tail_x15_r0_body.pl176 j)) = true
-- the map fixes the call's names (`Conv.fixOld_compact`), the call's counters
kernel_rfl PRE_first_tail_x15_r0_body.fja176 : Nat.ble 2812603 2812603 = true
kernel_rfl PRE_first_tail_x15_r0_body.fn176 : Nat.ble 7579 7579 = true
kernel_rfl PRE_first_tail_x15_r0_body.fjaD176 : Nat.ble 2812603 PRE_first_tail_x15_r0_body.kd176.n0 = true
kernel_rfl PRE_first_tail_x15_r0_body.fxn176 : Nat.ble 21657 PRE_first_tail_x15_r0_body.kd176.nh0 = true
kernel_rfl PRE_first_tail_x15_r0_body.fnn176 : Nat.ble 18766 PRE_first_tail_x15_r0_body.kd176.nn0 = true
kernel_rfl PRE_first_tail_x15_r0_body.fxb176 : Nat.ble 21657 RData.bigHi = true
kernel_rfl PRE_first_tail_x15_r0_body.fheap176 : (PTrie.keysA PRE_first_tail_x15_r0_body.kd176.heap).all (Nat.ble (⟨21657, 18766, 2812603, 7579⟩ : Conv.Cnt).ja) = true
kernel_rfl PRE_first_tail_x15_r0_body.fhnd176 : (PTrie.keysA PRE_first_tail_x15_r0_body.kd176.hnd).all (Nat.ble (⟨21657, 18766, 2812603, 7579⟩ : Conv.Cnt).xn) = true
kernel_rfl PRE_first_tail_x15_r0_body.fnode176 : (PTrie.keysA PRE_first_tail_x15_r0_body.kd176.node).all (Nat.ble (⟨21657, 18766, 2812603, 7579⟩ : Conv.Cnt).nn) = true
/-- The compaction map fixes the call's names. -/
theorem PRE_first_tail_x15_r0_body.cfix176 : Conv.FixOld (⟨21657, 18766, 2812603, 7579⟩ : Conv.Cnt) PRE_first_tail_x15_r0_body.kappa176 :=
  Conv.fixOld_compact (Nat.le_of_ble_eq_true PRE_first_tail_x15_r0_body.fja176) (Nat.le_of_ble_eq_true PRE_first_tail_x15_r0_body.fn176) (Nat.le_of_ble_eq_true PRE_first_tail_x15_r0_body.fjaD176) (Nat.le_of_ble_eq_true PRE_first_tail_x15_r0_body.fxn176) (Nat.le_of_ble_eq_true PRE_first_tail_x15_r0_body.fnn176) (Nat.le_of_ble_eq_true PRE_first_tail_x15_r0_body.fxb176) PRE_first_tail_x15_r0_body.fheap176 PRE_first_tail_x15_r0_body.fhnd176 PRE_first_tail_x15_r0_body.fnode176
kernel_rfl PRE_first_tail_x15_r0_body.fcxn176 : (⟨21657, 18766, 2812603, 7579⟩ : Conv.Cnt).xn = (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1696.ffi).mlx.next
kernel_rfl PRE_first_tail_x15_r0_body.fcnn176 : (⟨21657, 18766, 2812603, 7579⟩ : Conv.Cnt).nn = (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1696.ffi).mlx.nnext
kernel_rfl PRE_first_tail_x15_r0_body.fle0176 : (Nat.ble (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1696.ffi).mlx.next PRE_first_tail_x15_r0_body.cx0_176.mlx.next && Nat.ble (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1696.ffi).mlx.nnext PRE_first_tail_x15_r0_body.cx0_176.mlx.nnext && Nat.ble (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1696.ffi).mlx.next RData.bigHi) = true
kernel_rfl PRE_first_tail_x15_r0_body.fnk176 : (PTrie.keysA PRE_first_tail_x15_r0_body.kd176.node).all (Nat.ble (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1696.ffi).mlx.nnext) = true
-- the merged state keeps the call's entries off the stage's footprint
kernel_rfl PRE_first_tail_x15_r0_body.f1A176 : PRE_first_tail_x15_r0_body.cx1_176.mlx.arrs = Stage.setAll (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1696.ffi).mlx.arrs (PRE_first_tail_x15_r0_body.cwS176.filterMap fun i => (PRE_first_tail_x15_r0_body.cx1_176.mlx.arrs.get i).map (i, ·))
kernel_rfl PRE_first_tail_x15_r0_body.f1O176 : PRE_first_tail_x15_r0_body.cx1_176.mlx.objs = Stage.setAll (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1696.ffi).mlx.objs (PRE_first_tail_x15_r0_body.cwS176.filterMap fun i => (PRE_first_tail_x15_r0_body.cx1_176.mlx.objs.get i).map (i, ·))
kernel_rfl PRE_first_tail_x15_r0_body.f1N176 : PRE_first_tail_x15_r0_body.cx1_176.mlx.nodes = Stage.setAll (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1696.ffi).mlx.nodes (PRE_first_tail_x15_r0_body.cnS176.filterMap fun i => (PRE_first_tail_x15_r0_body.cx1_176.mlx.nodes.get i).map (i, ·))
kernel_rfl PRE_first_tail_x15_r0_body.f1I176 : PRE_first_tail_x15_r0_body.cx1_176.mlx.items = Stage.setAll (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1696.ffi).mlx.items (PRE_first_tail_x15_r0_body.ciS176.filterMap fun i => (PRE_first_tail_x15_r0_body.cx1_176.mlx.items.get i).map (i, ·))
kernel_rfl PRE_first_tail_x15_r0_body.fbd176 : (PRE_first_tail_x15_r0_body.clo176 ++ PRE_first_tail_x15_r0_body.cln176 ++ PRE_first_tail_x15_r0_body.cli176 ++ PRE_first_tail_x15_r0_body.cwS176 ++ PRE_first_tail_x15_r0_body.cnS176 ++ PRE_first_tail_x15_r0_body.ciS176).all (fun i => Nat.blt (i / 4096) (4 ^ 31)) = true
kernel_rfl PRE_first_tail_x15_r0_body.fincW176 : PRE_first_tail_x15_r0_body.cwS176.all (fun h => !Nat.blt h (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1696.ffi).mlx.next || PRE_first_tail_x15_r0_body.clo176.contains h) = true
kernel_rfl PRE_first_tail_x15_r0_body.fincI176 : PRE_first_tail_x15_r0_body.ciS176.all (fun k => !Nat.blt k (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1696.ffi).mlx.nnext || PRE_first_tail_x15_r0_body.cli176.contains k) = true
kernel_rfl PRE_first_tail_x15_r0_body.fincN176 : PRE_first_tail_x15_r0_body.cnS176.all (Nat.ble (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1696.ffi).mlx.nnext) = true
kernel_rfl PRE_first_tail_x15_r0_body.flnF176 : PRE_first_tail_x15_r0_body.cln176.all (Nat.ble (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1696.ffi).mlx.nnext) = true
-- the checks over the changed lists
kernel_rfl PRE_first_tail_x15_r0_body.fh176 : PRE_first_tail_x15_r0_body.clo176.all (handleOK PRE_first_tail_x15_r0_body.kappa176 PRE_first_tail_x15_r0_body.P176.lo PRE_first_tail_x15_r0_body.cx0_176.mlx PRE_first_tail_x15_r0_body.cx1_176.mlx) = true
kernel_rfl PRE_first_tail_x15_r0_body.fo176 : PRE_first_tail_x15_r0_body.clo176.map (fun h => PRE_first_tail_x15_r0_body.cx1_176.mlx.objs.get (PRE_first_tail_x15_r0_body.kappa176.handle h)) = PRE_first_tail_x15_r0_body.clo176.map (fun h => (PRE_first_tail_x15_r0_body.cx0_176.mlx.objs.get h).map PRE_first_tail_x15_r0_body.kappa176.nobj)
kernel_rfl PRE_first_tail_x15_r0_body.fok176 : PRE_first_tail_x15_r0_body.clo176.all (objOK PRE_first_tail_x15_r0_body.kappa176 PRE_first_tail_x15_r0_body.P176.NL PRE_first_tail_x15_r0_body.cx0_176.mlx) = true
kernel_rfl PRE_first_tail_x15_r0_body.fnd176 : PRE_first_tail_x15_r0_body.cln176.all (nodeOKF PRE_first_tail_x15_r0_body.kappa176 PRE_first_tail_x15_r0_body.P176 PRE_first_tail_x15_r0_body.cx0_176.mlx PRE_first_tail_x15_r0_body.cx1_176.mlx) = true
kernel_rfl PRE_first_tail_x15_r0_body.fp176 : ((PRE_first_tail_x15_r0_body.cln176.filter (fullB PRE_first_tail_x15_r0_body.P176))).map (fun i => (PRE_first_tail_x15_r0_body.cx1_176.mlx.nodes.get (PRE_first_tail_x15_r0_body.kappa176.node i)).map Host.Mlx.Ffi.Node.prim) =
  ((PRE_first_tail_x15_r0_body.cln176.filter (fullB PRE_first_tail_x15_r0_body.P176))).map (fun i => (PRE_first_tail_x15_r0_body.cx0_176.mlx.nodes.get i).map fun nd => PRE_first_tail_x15_r0_body.kappa176.prim nd.prim)
kernel_rfl PRE_first_tail_x15_r0_body.fnordI176 : incrB PRE_first_tail_x15_r0_body.kd176.nodeF (List.range' 18766 0) = true
kernel_rfl PRE_first_tail_x15_r0_body.fnordK176 : (PTrie.keysA PRE_first_tail_x15_r0_body.kd176.node).all (fun k => Nat.ble 18766 k && Nat.blt k 18766) = true
kernel_rfl PRE_first_tail_x15_r0_body.fnordL176 : (PRE_first_tail_x15_r0_body.cln176.filter (Nat.ble PRE_first_tail_x15_r0_body.P176.N0)).all (fun i => Nat.ble i (PRE_first_tail_x15_r0_body.kd176.nodeF i) && (Nat.blt i 18766 || Nat.ble PRE_first_tail_x15_r0_body.kd176.nn0 i)) = true
theorem PRE_first_tail_x15_r0_body.fnord176 : (PRE_first_tail_x15_r0_body.cln176.filter (Nat.ble PRE_first_tail_x15_r0_body.P176.N0)).all (fun i => Nat.ble i (PRE_first_tail_x15_r0_body.kd176.nodeF i) &&
    (PTrie.keysA PRE_first_tail_x15_r0_body.kd176.node).all fun j => !Nat.blt j i || Nat.blt (PRE_first_tail_x15_r0_body.kd176.nodeF j) (PRE_first_tail_x15_r0_body.kd176.nodeF i)) = true :=
  cnord_of PRE_first_tail_x15_r0_body.cnlow176 PRE_first_tail_x15_r0_body.cnn1176 PRE_first_tail_x15_r0_body.fnordI176 PRE_first_tail_x15_r0_body.fnordK176 PRE_first_tail_x15_r0_body.fnordL176
kernel_rfl PRE_first_tail_x15_r0_body.fi176 : PRE_first_tail_x15_r0_body.cli176.all (pnB PRE_first_tail_x15_r0_body.cx0_176.mlx) = true
kernel_rfl PRE_first_tail_x15_r0_body.fii176 : PRE_first_tail_x15_r0_body.cli176.all (fun k => decide (PRE_first_tail_x15_r0_body.cx1_176.mlx.items.get (PRE_first_tail_x15_r0_body.kappa176.node k) = (PRE_first_tail_x15_r0_body.cx0_176.mlx.items.get k).map PRE_first_tail_x15_r0_body.kappa176.nv)) = true
/-- **The compaction's footprint.** -/
theorem PRE_first_tail_x15_r0_body.cfoot176 (clean : Conv.NClean (⟨21657, 18766, 2812603, 7579⟩ : Conv.Cnt) (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1696.ffi).mlx) (hltC : ∀ h, PH (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1696.ffi).mlx h → h < (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1696.ffi).mlx.next) (nltC : ∀ i, PN (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1696.ffi).mlx i → i < (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1696.ffi).mlx.nnext) (itemsC : ∀ k v, (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1696.ffi).mlx.items.get k = some v → PN (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1696.ffi).mlx k) (tracedC : ∀ h o, (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1696.ffi).mlx.objs.get h = some o → ∀ i ∈ objTraces o, i < PRE_first_tail_x15_r0_body.P176.NL) (cl : SSt (· < 7579) PRE_first_tail_x15_r0_body.cx0_176.mlx) :
    Conv.MFoot PRE_first_tail_x15_r0_body.P176 7579 PRE_first_tail_x15_r0_body.kappa176 PRE_first_tail_x15_r0_body.kd176 PRE_first_tail_x15_r0_body.khinv176 PRE_first_tail_x15_r0_body.kninv176 (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1696.ffi).mlx PRE_first_tail_x15_r0_body.cx0_176.mlx PRE_first_tail_x15_r0_body.cx1_176.mlx (⟨21657, 18766, 2812603, 7579⟩ : Conv.Cnt) PRE_first_tail_x15_r0_body.clo176 PRE_first_tail_x15_r0_body.cln176 PRE_first_tail_x15_r0_body.cli176 PRE_first_tail_x15_r0_body.cwS176 PRE_first_tail_x15_r0_body.cnS176 PRE_first_tail_x15_r0_body.ciS176 :=
  ⟨rfl, rfl, rfl, PRE_first_tail_x15_r0_body.cnh0176, PRE_first_tail_x15_r0_body.cnh1176, PRE_first_tail_x15_r0_body.cnn0176, PRE_first_tail_x15_r0_body.cnn1176, PRE_first_tail_x15_r0_body.cplo176, PRE_first_tail_x15_r0_body.ccnt176, PRE_first_tail_x15_r0_body.cnband176, PRE_first_tail_x15_r0_body.chbelow176, PRE_first_tail_x15_r0_body.chren176, PRE_first_tail_x15_r0_body.cband176, PRE_first_tail_x15_r0_body.cnh1pos176, PRE_first_tail_x15_r0_body.cnren176, PRE_first_tail_x15_r0_body.cnlow176, PRE_first_tail_x15_r0_body.cabs0a176, PRE_first_tail_x15_r0_body.cabs0b176, PRE_first_tail_x15_r0_body.ctok1176, PRE_first_tail_x15_r0_body.cpend176, PRE_first_tail_x15_r0_body.cerrh176, PRE_first_tail_x15_r0_body.cfiles176, PRE_first_tail_x15_r0_body.carch176, PRE_first_tail_x15_r0_body.csizes176, PRE_first_tail_x15_r0_body.cwired176, PRE_first_tail_x15_r0_body.cfix176, clean, PRE_first_tail_x15_r0_body.fcxn176, PRE_first_tail_x15_r0_body.fcnn176, hltC, nltC, itemsC, tracedC, cl, PRE_first_tail_x15_r0_body.fle0176, PRE_first_tail_x15_r0_body.fnk176, PRE_first_tail_x15_r0_body.ckA176, PRE_first_tail_x15_r0_body.cobjsK176, PRE_first_tail_x15_r0_body.cnodesK176, PRE_first_tail_x15_r0_body.citemsK176, PRE_first_tail_x15_r0_body.f1A176, PRE_first_tail_x15_r0_body.f1O176, PRE_first_tail_x15_r0_body.f1N176, PRE_first_tail_x15_r0_body.f1I176, PRE_first_tail_x15_r0_body.fbd176, PRE_first_tail_x15_r0_body.fincW176, PRE_first_tail_x15_r0_body.fincI176, PRE_first_tail_x15_r0_body.fincN176, PRE_first_tail_x15_r0_body.flnF176, PRE_first_tail_x15_r0_body.fh176, PRE_first_tail_x15_r0_body.fo176, PRE_first_tail_x15_r0_body.fok176, PRE_first_tail_x15_r0_body.fnd176, PRE_first_tail_x15_r0_body.fp176, PRE_first_tail_x15_r0_body.fnord176, PRE_first_tail_x15_r0_body.fi176, PRE_first_tail_x15_r0_body.fii176⟩
theorem PRE_first_tail_x15_r0_body.cnshift176 (clean : Conv.NClean (⟨21657, 18766, 2812603, 7579⟩ : Conv.Cnt) (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1696.ffi).mlx) (hltC : ∀ h, PH (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1696.ffi).mlx h → h < (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1696.ffi).mlx.next) (nltC : ∀ i, PN (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1696.ffi).mlx i → i < (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1696.ffi).mlx.nnext) (itemsC : ∀ k v, (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1696.ffi).mlx.items.get k = some v → PN (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1696.ffi).mlx k) (tracedC : ∀ h o, (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1696.ffi).mlx.objs.get h = some o → ∀ i ∈ objTraces o, i < PRE_first_tail_x15_r0_body.P176.NL) (cl : SSt (· < 7579) PRE_first_tail_x15_r0_body.cx0_176.mlx) : NShift PRE_first_tail_x15_r0_body.P176 7579 PRE_first_tail_x15_r0_body.kappa176 PRE_first_tail_x15_r0_body.cx0_176 PRE_first_tail_x15_r0_body.cx1_176 :=
  Conv.nshift_of_foot (PRE_first_tail_x15_r0_body.cfoot176 clean hltC nltC itemsC tracedC cl) PRE_first_tail_x15_r0_body.chost176 (compact_a_eq PRE_first_tail_x15_r0_body.ckn0176 PRE_first_tail_x15_r0_body.ckn1176 PRE_first_tail_x15_r0_body.ckheap176 PRE_first_tail_x15_r0_body.ckpl176)

-- the observers: the layers' states at the call, the canonical and the merged state, their footprints and checks
noncomputable def PRE_first_tail_x15_r0_body.fxC_176 : PTrie Unit := (Host.Ts.Sim.Full.freedOf PRE_first_tail_x15_r0_body.s1696.ffi).getD PTrie.nil
noncomputable def PRE_first_tail_x15_r0_body.krC_176 : Host.Load.Layers.KRec := (Host.Ts.Sim.Full.krecOf PRE_first_tail_x15_r0_body.s1696.ffi).getD Host.Load.Layers.KRec.empty
kernel_rfl PRE_first_tail_x15_r0_body.ofxC_176 : (Host.Ts.Sim.Full.freedOf PRE_first_tail_x15_r0_body.s1696.ffi) = some PRE_first_tail_x15_r0_body.fxC_176
kernel_rfl PRE_first_tail_x15_r0_body.okrC_176 : (Host.Ts.Sim.Full.krecOf PRE_first_tail_x15_r0_body.s1696.ffi) = some PRE_first_tail_x15_r0_body.krC_176
noncomputable def PRE_first_tail_x15_r0_body.fx0_176 : PTrie Unit := (Host.Ts.Sim.Full.freedOf PRE_first_tail_x15_r0_body.s1698.ffi).getD PTrie.nil
noncomputable def PRE_first_tail_x15_r0_body.kr0_176 : Host.Load.Layers.KRec := (Host.Ts.Sim.Full.krecOf PRE_first_tail_x15_r0_body.s1698.ffi).getD Host.Load.Layers.KRec.empty
kernel_rfl PRE_first_tail_x15_r0_body.ofx0_176 : (Host.Ts.Sim.Full.freedOf PRE_first_tail_x15_r0_body.s1698.ffi) = some PRE_first_tail_x15_r0_body.fx0_176
kernel_rfl PRE_first_tail_x15_r0_body.okr0_176 : (Host.Ts.Sim.Full.krecOf PRE_first_tail_x15_r0_body.s1698.ffi) = some PRE_first_tail_x15_r0_body.kr0_176
noncomputable def PRE_first_tail_x15_r0_body.fx1_176 : PTrie Unit := (Host.Ts.Sim.Full.freedOf PRE_first_tail_x15_r0_body.s1697.ffi).getD PTrie.nil
noncomputable def PRE_first_tail_x15_r0_body.kr1_176 : Host.Load.Layers.KRec := (Host.Ts.Sim.Full.krecOf PRE_first_tail_x15_r0_body.s1697.ffi).getD Host.Load.Layers.KRec.empty
kernel_rfl PRE_first_tail_x15_r0_body.ofx1_176 : (Host.Ts.Sim.Full.freedOf PRE_first_tail_x15_r0_body.s1697.ffi) = some PRE_first_tail_x15_r0_body.fx1_176
kernel_rfl PRE_first_tail_x15_r0_body.okr1_176 : (Host.Ts.Sim.Full.krecOf PRE_first_tail_x15_r0_body.s1697.ffi) = some PRE_first_tail_x15_r0_body.kr1_176
kernel_rfl PRE_first_tail_x15_r0_body.ff0176 : PRE_first_tail_x15_r0_body.fx0_176 = Stage.setAll PRE_first_tail_x15_r0_body.fxC_176 (PRE_first_tail_x15_r0_body.clo176.filterMap fun i => (PRE_first_tail_x15_r0_body.fx0_176.get i).map (i, ·))
kernel_rfl PRE_first_tail_x15_r0_body.ff1176 : PRE_first_tail_x15_r0_body.fx1_176 = Stage.setAll PRE_first_tail_x15_r0_body.fxC_176 (PRE_first_tail_x15_r0_body.cwS176.filterMap fun i => (PRE_first_tail_x15_r0_body.fx1_176.get i).map (i, ·))
kernel_rfl PRE_first_tail_x15_r0_body.ffck176 : freedLB PRE_first_tail_x15_r0_body.kappa176 PRE_first_tail_x15_r0_body.cx0_176.mlx PRE_first_tail_x15_r0_body.fx0_176 PRE_first_tail_x15_r0_body.fx1_176 PRE_first_tail_x15_r0_body.clo176 = true
kernel_rfl PRE_first_tail_x15_r0_body.fkf0176 : PRE_first_tail_x15_r0_body.kr0_176.flags = Stage.setAll PRE_first_tail_x15_r0_body.krC_176.flags (PRE_first_tail_x15_r0_body.clo176.filterMap fun i => (PRE_first_tail_x15_r0_body.kr0_176.flags.get i).map (i, ·))
kernel_rfl PRE_first_tail_x15_r0_body.fkt0176 : PRE_first_tail_x15_r0_body.kr0_176.targs = Stage.setAll PRE_first_tail_x15_r0_body.krC_176.targs (PRE_first_tail_x15_r0_body.clo176.filterMap fun i => (PRE_first_tail_x15_r0_body.kr0_176.targs.get i).map (i, ·))
kernel_rfl PRE_first_tail_x15_r0_body.fkf1176 : PRE_first_tail_x15_r0_body.kr1_176.flags = Stage.setAll PRE_first_tail_x15_r0_body.krC_176.flags (PRE_first_tail_x15_r0_body.cwS176.filterMap fun i => (PRE_first_tail_x15_r0_body.kr1_176.flags.get i).map (i, ·))
kernel_rfl PRE_first_tail_x15_r0_body.fkt1176 : PRE_first_tail_x15_r0_body.kr1_176.targs = Stage.setAll PRE_first_tail_x15_r0_body.krC_176.targs (PRE_first_tail_x15_r0_body.cwS176.filterMap fun i => (PRE_first_tail_x15_r0_body.kr1_176.targs.get i).map (i, ·))
kernel_rfl PRE_first_tail_x15_r0_body.fkck176 : krecLB PRE_first_tail_x15_r0_body.kappa176 7579 PRE_first_tail_x15_r0_body.cx0_176.mlx PRE_first_tail_x15_r0_body.kr0_176 PRE_first_tail_x15_r0_body.kr1_176 PRE_first_tail_x15_r0_body.clo176 = true
kernel_rfl PRE_first_tail_x15_r0_body.fkn176 : Nat.ble 7579 7579 = true
-- the bridge and the pending traces' regions
kernel_rfl PRE_first_tail_x15_r0_body.cbridge176 : Host.Ts.Sim.Full.bridgeOf PRE_first_tail_x15_r0_body.s1697.ffi = Host.Ts.Sim.Full.bridgeOf PRE_first_tail_x15_r0_body.s1698.ffi
kernel_rfl PRE_first_tail_x15_r0_body.cpendR176 : pendRegB PRE_first_tail_x15_r0_body.kappa176 (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1698.ffi).mlx = true
kernel_rfl PRE_first_tail_x15_r0_body.cpendLe176 : Nat.ble (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1698.ffi).mlx.next (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1697.ffi).mlx.next = true
/-- **The compaction's native shift**, given the call's bookkeeping, its relation's facts (the model's and the
observers') and the canonical closedness. -/
theorem PRE_first_tail_x15_r0_body.cshift176 (clean : Conv.NClean (⟨21657, 18766, 2812603, 7579⟩ : Conv.Cnt) (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1696.ffi).mlx) (hltC : ∀ h, PH (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1696.ffi).mlx h → h < (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1696.ffi).mlx.next) (nltC : ∀ i, PN (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1696.ffi).mlx i → i < (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1696.ffi).mlx.nnext) (itemsC : ∀ k v, (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1696.ffi).mlx.items.get k = some v → PN (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1696.ffi).mlx k) (tracedC : ∀ h o, (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1696.ffi).mlx.objs.get h = some o → ∀ i ∈ objTraces o, i < PRE_first_tail_x15_r0_body.P176.NL) (cl : SSt (· < 7579) PRE_first_tail_x15_r0_body.cx0_176.mlx)
    (hobjC : ∀ h, PRE_first_tail_x15_r0_body.fxC_176.get h = some () → ((Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1696.ffi).mlx.objs.get h).isSome = true)
    (hfC : ∀ h, (PRE_first_tail_x15_r0_body.krC_176.flags.get h).isSome = true → ((Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1696.ffi).mlx.objs.get h).isSome = true)
    (htC : ∀ h, (PRE_first_tail_x15_r0_body.krC_176.targs.get h).isSome = true → ((Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1696.ffi).mlx.objs.get h).isSome = true)
    (hclC : ∀ h l, PRE_first_tail_x15_r0_body.krC_176.targs.get h = some l → Host.Ts.Sim.Full.STargs (· < (⟨21657, 18766, 2812603, 7579⟩ : Conv.Cnt).n) l) :
    Conv.FullShiftQ PRE_first_tail_x15_r0_body.P176 7579 PRE_first_tail_x15_r0_body.kappa176 PRE_first_tail_x15_r0_body.s1698.ffi PRE_first_tail_x15_r0_body.s1697.ffi :=
  ⟨PRE_first_tail_x15_r0_body.cnshift176 clean hltC nltC itemsC tracedC cl, PRE_first_tail_x15_r0_body.cqueue176, fun t ht => bSN_sound (List.all_eq_true.mp PRE_first_tail_x15_r0_body.ctokSupp176 t ht),
    PRE_first_tail_x15_r0_body.cbridge176,
    liveShift_foot (x0' := Host.Ts.Sim.Full.mlxOf PRE_first_tail_x15_r0_body.s1698.ffi) (x1' := Host.Ts.Sim.Full.mlxOf PRE_first_tail_x15_r0_body.s1697.ffi) (PRE_first_tail_x15_r0_body.cfoot176 clean hltC nltC itemsC tracedC cl) rfl PRE_first_tail_x15_r0_body.ofx0_176 PRE_first_tail_x15_r0_body.ofx1_176 hobjC PRE_first_tail_x15_r0_body.ff0176 PRE_first_tail_x15_r0_body.ff1176 PRE_first_tail_x15_r0_body.ffck176,
    kernShift_foot (x0' := Host.Ts.Sim.Full.mlxOf PRE_first_tail_x15_r0_body.s1698.ffi) (x1' := Host.Ts.Sim.Full.mlxOf PRE_first_tail_x15_r0_body.s1697.ffi) (PRE_first_tail_x15_r0_body.cfoot176 clean hltC nltC itemsC tracedC cl) rfl PRE_first_tail_x15_r0_body.okr0_176 PRE_first_tail_x15_r0_body.okr1_176 (Nat.le_of_ble_eq_true PRE_first_tail_x15_r0_body.fkn176) hfC htC hclC
      PRE_first_tail_x15_r0_body.fkf0176 PRE_first_tail_x15_r0_body.fkt0176 PRE_first_tail_x15_r0_body.fkf1176 PRE_first_tail_x15_r0_body.fkt1176 PRE_first_tail_x15_r0_body.fkck176,
    pendReg_of rfl PRE_first_tail_x15_r0_body.cnh0176 PRE_first_tail_x15_r0_body.cnh1176 (Nat.le_of_ble_eq_true PRE_first_tail_x15_r0_body.cpendLe176) PRE_first_tail_x15_r0_body.cpendR176⟩

end Host.Load.Run.Tpl
