import host.sim.template.a4pre_first_tail_x15_r0_body.SiteCl17
import host.sim.conv.CompactFull
import host.sim.template.FootGen
set_option Elab.async false
namespace Host.Load.Run.Tpl
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
open Host.Ts Host.Ts.Sim Host.Ts.Sim.Template

/-! The compaction's native shift at call site 17 from its footprint (`Conv.nshift_of_foot`), and the observers'
(`liveShift_foot`, `kernShift_foot`): `Conv.FullShiftQ` for `Conv.full_compactQ`, given the call's bookkeeping and its
relation's facts. -/

/-- The load parameters of the chain (band-free: its start's node counter as `NL` and `N0`). -/
def PRE_first_tail_x15_r0_body.Pc17 : LoadP := ⟨18151, 131072, 1099511627776, 15235, 15235, []⟩
/-- The site's band raised to the map's checked fixed-node prefix, including newly recorded closure traces. -/
def PRE_first_tail_x15_r0_body.P17 : LoadP := PRE_first_tail_x15_r0_body.Pc17.raise 15622
kernel_rfl PRE_first_tail_x15_r0_body.craise17 : Nat.ble PRE_first_tail_x15_r0_body.Pc17.N0 15622 = true
theorem PRE_first_tail_x15_r0_body.raised17 : Host.Ts.Sim.Full.Raised PRE_first_tail_x15_r0_body.Pc17 PRE_first_tail_x15_r0_body.P17 :=
  .inr ⟨15622, rfl, Nat.le_of_ble_eq_true PRE_first_tail_x15_r0_body.craise17, rfl⟩
noncomputable abbrev PRE_first_tail_x15_r0_body.cx0_17 : Host.Load.LSt := clearTokens (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s159.ffi)
noncomputable abbrev PRE_first_tail_x15_r0_body.cx1_17 : Host.Load.LSt := clearTokens (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s158.ffi)
def PRE_first_tail_x15_r0_body.khinv17 : PTrie Nat := Stage.setAll PTrie.nil []
def PRE_first_tail_x15_r0_body.kninv17 : PTrie Nat := Stage.setAll PTrie.nil []
/-- The stage's footprint: its written and fresh handles, fresh nodes, written and fresh items. -/
def PRE_first_tail_x15_r0_body.cwS17 : List Nat := []
def PRE_first_tail_x15_r0_body.cnS17 : List Nat := List.range' 15622 0
def PRE_first_tail_x15_r0_body.ciS17 : List Nat := [] ++ List.range' 15622 0

-- the small checks (`MChecks`'s)
kernel_rfl PRE_first_tail_x15_r0_body.cnh017 : PRE_first_tail_x15_r0_body.kd17.nh0 = PRE_first_tail_x15_r0_body.cx0_17.mlx.next
kernel_rfl PRE_first_tail_x15_r0_body.cnh117 : PRE_first_tail_x15_r0_body.kd17.nh1 = PRE_first_tail_x15_r0_body.cx1_17.mlx.next
kernel_rfl PRE_first_tail_x15_r0_body.cnn017 : PRE_first_tail_x15_r0_body.kd17.nn0 = PRE_first_tail_x15_r0_body.cx0_17.mlx.nnext
kernel_rfl PRE_first_tail_x15_r0_body.cnn117 : PRE_first_tail_x15_r0_body.kd17.nn1 = PRE_first_tail_x15_r0_body.cx1_17.mlx.nnext
kernel_rfl PRE_first_tail_x15_r0_body.cplo17 : (Nat.blt 0 PRE_first_tail_x15_r0_body.P17.lo && Nat.ble PRE_first_tail_x15_r0_body.P17.lo PRE_first_tail_x15_r0_body.cx0_17.mlx.next && Nat.ble PRE_first_tail_x15_r0_body.P17.lo RData.bigHi && Nat.ble RData.bigHi PRE_first_tail_x15_r0_body.P17.E) = true
kernel_rfl PRE_first_tail_x15_r0_body.ccnt17 : (Nat.ble PRE_first_tail_x15_r0_body.cx0_17.mlx.next PRE_first_tail_x15_r0_body.cx1_17.mlx.next && Nat.ble PRE_first_tail_x15_r0_body.cx0_17.mlx.nnext PRE_first_tail_x15_r0_body.cx1_17.mlx.nnext) = true
kernel_rfl PRE_first_tail_x15_r0_body.cnband17 : (Nat.blt 0 PRE_first_tail_x15_r0_body.P17.NL && Nat.ble PRE_first_tail_x15_r0_body.P17.NL PRE_first_tail_x15_r0_body.P17.N0 && Nat.ble PRE_first_tail_x15_r0_body.P17.N0 PRE_first_tail_x15_r0_body.cx0_17.mlx.nnext) = true
kernel_rfl PRE_first_tail_x15_r0_body.chbelow17 : PRE_first_tail_x15_r0_body.kd17.checkHndBelow = true
kernel_rfl PRE_first_tail_x15_r0_body.chren17 : checkRenG PRE_first_tail_x15_r0_body.kd17.hnd PRE_first_tail_x15_r0_body.khinv17 (phB PRE_first_tail_x15_r0_body.cx0_17.mlx) = true
kernel_rfl PRE_first_tail_x15_r0_body.cband17 : PRE_first_tail_x15_r0_body.kd17.checkBand PRE_first_tail_x15_r0_body.P17.lo = true
kernel_rfl PRE_first_tail_x15_r0_body.cnh1pos17 : Nat.blt 0 PRE_first_tail_x15_r0_body.kd17.nh1 = true
kernel_rfl PRE_first_tail_x15_r0_body.cnren17 : checkRenG PRE_first_tail_x15_r0_body.kd17.node PRE_first_tail_x15_r0_body.kninv17 (pnB PRE_first_tail_x15_r0_body.cx0_17.mlx) = true
kernel_rfl PRE_first_tail_x15_r0_body.cnlow17 : (PTrie.keysA PRE_first_tail_x15_r0_body.kd17.node).all (fun j => Nat.ble PRE_first_tail_x15_r0_body.P17.NL j && Nat.blt (PRE_first_tail_x15_r0_body.kd17.nodeF j) PRE_first_tail_x15_r0_body.cx1_17.mlx.nnext) = true
kernel_rfl PRE_first_tail_x15_r0_body.cabs0a17 : PRE_first_tail_x15_r0_body.cx0_17.mlx.arrs.get 0 = none
kernel_rfl PRE_first_tail_x15_r0_body.cabs0b17 : PRE_first_tail_x15_r0_body.cx0_17.mlx.objs.get 0 = none
kernel_rfl PRE_first_tail_x15_r0_body.ctok117 : PRE_first_tail_x15_r0_body.cx1_17.mlx.tokens = []
kernel_rfl PRE_first_tail_x15_r0_body.cpend17 : PRE_first_tail_x15_r0_body.cx1_17.mlx.pending = PRE_first_tail_x15_r0_body.cx0_17.mlx.pending.map PRE_first_tail_x15_r0_body.kappa17.pend
kernel_rfl PRE_first_tail_x15_r0_body.cerrh17 : PRE_first_tail_x15_r0_body.cx1_17.mlx.errh = PRE_first_tail_x15_r0_body.cx0_17.mlx.errh.map PRE_first_tail_x15_r0_body.kappa17.arg
kernel_rfl PRE_first_tail_x15_r0_body.cfiles17 : PRE_first_tail_x15_r0_body.cx1_17.mlx.files = PRE_first_tail_x15_r0_body.cx0_17.mlx.files
kernel_rfl PRE_first_tail_x15_r0_body.carch17 : PRE_first_tail_x15_r0_body.cx1_17.mlx.arch = PRE_first_tail_x15_r0_body.cx0_17.mlx.arch
kernel_rfl PRE_first_tail_x15_r0_body.csizes17 : PRE_first_tail_x15_r0_body.cx1_17.mlx.deviceSizes = PRE_first_tail_x15_r0_body.cx0_17.mlx.deviceSizes
kernel_rfl PRE_first_tail_x15_r0_body.cwired17 : PRE_first_tail_x15_r0_body.cx1_17.mlx.wired = PRE_first_tail_x15_r0_body.cx0_17.mlx.wired
kernel_rfl PRE_first_tail_x15_r0_body.chost17 : PRE_first_tail_x15_r0_body.cx1_17.host = PRE_first_tail_x15_r0_body.cx0_17.host
-- the compaction map's addresses are `PRE_first_tail_x15_r0_body.kd17`'s
kernel_rfl PRE_first_tail_x15_r0_body.ckn017 : PRE_first_tail_x15_r0_body.kd17.n0 = 2687916
kernel_rfl PRE_first_tail_x15_r0_body.ckn117 : PRE_first_tail_x15_r0_body.kd17.n1 = 2687926
kernel_rfl PRE_first_tail_x15_r0_body.ckheap17 : (PTrie.keysA PRE_first_tail_x15_r0_body.kd17.heap).all (fun x => Nat.ble 2687915 x) = true
kernel_rfl PRE_first_tail_x15_r0_body.ckpl17 : (List.range 1).all (fun j => decide (PRE_first_tail_x15_r0_body.kd17.heap.get (2687915 + j) = nth? PRE_first_tail_x15_r0_body.pl17 j)) = true
-- the map fixes the call's names (`Conv.fixOld_compact`), the call's counters
kernel_rfl PRE_first_tail_x15_r0_body.fja17 : Nat.ble 2687915 2687915 = true
kernel_rfl PRE_first_tail_x15_r0_body.fn17 : Nat.ble 781 781 = true
kernel_rfl PRE_first_tail_x15_r0_body.fjaD17 : Nat.ble 2687915 PRE_first_tail_x15_r0_body.kd17.n0 = true
kernel_rfl PRE_first_tail_x15_r0_body.fxn17 : Nat.ble 18532 PRE_first_tail_x15_r0_body.kd17.nh0 = true
kernel_rfl PRE_first_tail_x15_r0_body.fnn17 : Nat.ble 15622 PRE_first_tail_x15_r0_body.kd17.nn0 = true
kernel_rfl PRE_first_tail_x15_r0_body.fxb17 : Nat.ble 18532 RData.bigHi = true
kernel_rfl PRE_first_tail_x15_r0_body.fheap17 : (PTrie.keysA PRE_first_tail_x15_r0_body.kd17.heap).all (Nat.ble (⟨18532, 15622, 2687915, 781⟩ : Conv.Cnt).ja) = true
kernel_rfl PRE_first_tail_x15_r0_body.fhnd17 : (PTrie.keysA PRE_first_tail_x15_r0_body.kd17.hnd).all (Nat.ble (⟨18532, 15622, 2687915, 781⟩ : Conv.Cnt).xn) = true
kernel_rfl PRE_first_tail_x15_r0_body.fnode17 : (PTrie.keysA PRE_first_tail_x15_r0_body.kd17.node).all (Nat.ble (⟨18532, 15622, 2687915, 781⟩ : Conv.Cnt).nn) = true
/-- The compaction map fixes the call's names. -/
theorem PRE_first_tail_x15_r0_body.cfix17 : Conv.FixOld (⟨18532, 15622, 2687915, 781⟩ : Conv.Cnt) PRE_first_tail_x15_r0_body.kappa17 :=
  Conv.fixOld_compact (Nat.le_of_ble_eq_true PRE_first_tail_x15_r0_body.fja17) (Nat.le_of_ble_eq_true PRE_first_tail_x15_r0_body.fn17) (Nat.le_of_ble_eq_true PRE_first_tail_x15_r0_body.fjaD17) (Nat.le_of_ble_eq_true PRE_first_tail_x15_r0_body.fxn17) (Nat.le_of_ble_eq_true PRE_first_tail_x15_r0_body.fnn17) (Nat.le_of_ble_eq_true PRE_first_tail_x15_r0_body.fxb17) PRE_first_tail_x15_r0_body.fheap17 PRE_first_tail_x15_r0_body.fhnd17 PRE_first_tail_x15_r0_body.fnode17
kernel_rfl PRE_first_tail_x15_r0_body.fcxn17 : (⟨18532, 15622, 2687915, 781⟩ : Conv.Cnt).xn = (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s157.ffi).mlx.next
kernel_rfl PRE_first_tail_x15_r0_body.fcnn17 : (⟨18532, 15622, 2687915, 781⟩ : Conv.Cnt).nn = (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s157.ffi).mlx.nnext
kernel_rfl PRE_first_tail_x15_r0_body.fle017 : (Nat.ble (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s157.ffi).mlx.next PRE_first_tail_x15_r0_body.cx0_17.mlx.next && Nat.ble (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s157.ffi).mlx.nnext PRE_first_tail_x15_r0_body.cx0_17.mlx.nnext && Nat.ble (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s157.ffi).mlx.next RData.bigHi) = true
kernel_rfl PRE_first_tail_x15_r0_body.fnk17 : (PTrie.keysA PRE_first_tail_x15_r0_body.kd17.node).all (Nat.ble (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s157.ffi).mlx.nnext) = true
-- the merged state keeps the call's entries off the stage's footprint
kernel_rfl PRE_first_tail_x15_r0_body.f1A17 : PRE_first_tail_x15_r0_body.cx1_17.mlx.arrs = Stage.setAll (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s157.ffi).mlx.arrs (PRE_first_tail_x15_r0_body.cwS17.filterMap fun i => (PRE_first_tail_x15_r0_body.cx1_17.mlx.arrs.get i).map (i, ·))
kernel_rfl PRE_first_tail_x15_r0_body.f1O17 : PRE_first_tail_x15_r0_body.cx1_17.mlx.objs = Stage.setAll (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s157.ffi).mlx.objs (PRE_first_tail_x15_r0_body.cwS17.filterMap fun i => (PRE_first_tail_x15_r0_body.cx1_17.mlx.objs.get i).map (i, ·))
kernel_rfl PRE_first_tail_x15_r0_body.f1N17 : PRE_first_tail_x15_r0_body.cx1_17.mlx.nodes = Stage.setAll (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s157.ffi).mlx.nodes (PRE_first_tail_x15_r0_body.cnS17.filterMap fun i => (PRE_first_tail_x15_r0_body.cx1_17.mlx.nodes.get i).map (i, ·))
kernel_rfl PRE_first_tail_x15_r0_body.f1I17 : PRE_first_tail_x15_r0_body.cx1_17.mlx.items = Stage.setAll (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s157.ffi).mlx.items (PRE_first_tail_x15_r0_body.ciS17.filterMap fun i => (PRE_first_tail_x15_r0_body.cx1_17.mlx.items.get i).map (i, ·))
kernel_rfl PRE_first_tail_x15_r0_body.fbd17 : (PRE_first_tail_x15_r0_body.clo17 ++ PRE_first_tail_x15_r0_body.cln17 ++ PRE_first_tail_x15_r0_body.cli17 ++ PRE_first_tail_x15_r0_body.cwS17 ++ PRE_first_tail_x15_r0_body.cnS17 ++ PRE_first_tail_x15_r0_body.ciS17).all (fun i => Nat.blt (i / 4096) (4 ^ 31)) = true
kernel_rfl PRE_first_tail_x15_r0_body.fincW17 : PRE_first_tail_x15_r0_body.cwS17.all (fun h => !Nat.blt h (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s157.ffi).mlx.next || PRE_first_tail_x15_r0_body.clo17.contains h) = true
kernel_rfl PRE_first_tail_x15_r0_body.fincI17 : PRE_first_tail_x15_r0_body.ciS17.all (fun k => !Nat.blt k (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s157.ffi).mlx.nnext || PRE_first_tail_x15_r0_body.cli17.contains k) = true
kernel_rfl PRE_first_tail_x15_r0_body.fincN17 : PRE_first_tail_x15_r0_body.cnS17.all (Nat.ble (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s157.ffi).mlx.nnext) = true
kernel_rfl PRE_first_tail_x15_r0_body.flnF17 : PRE_first_tail_x15_r0_body.cln17.all (Nat.ble (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s157.ffi).mlx.nnext) = true
-- the checks over the changed lists
kernel_rfl PRE_first_tail_x15_r0_body.fh17 : PRE_first_tail_x15_r0_body.clo17.all (handleOK PRE_first_tail_x15_r0_body.kappa17 PRE_first_tail_x15_r0_body.P17.lo PRE_first_tail_x15_r0_body.cx0_17.mlx PRE_first_tail_x15_r0_body.cx1_17.mlx) = true
kernel_rfl PRE_first_tail_x15_r0_body.fo17 : PRE_first_tail_x15_r0_body.clo17.map (fun h => PRE_first_tail_x15_r0_body.cx1_17.mlx.objs.get (PRE_first_tail_x15_r0_body.kappa17.handle h)) = PRE_first_tail_x15_r0_body.clo17.map (fun h => (PRE_first_tail_x15_r0_body.cx0_17.mlx.objs.get h).map PRE_first_tail_x15_r0_body.kappa17.nobj)
kernel_rfl PRE_first_tail_x15_r0_body.fok17 : PRE_first_tail_x15_r0_body.clo17.all (objOK PRE_first_tail_x15_r0_body.kappa17 PRE_first_tail_x15_r0_body.P17.NL PRE_first_tail_x15_r0_body.cx0_17.mlx) = true
kernel_rfl PRE_first_tail_x15_r0_body.fnd17 : PRE_first_tail_x15_r0_body.cln17.all (nodeOKF PRE_first_tail_x15_r0_body.kappa17 PRE_first_tail_x15_r0_body.P17 PRE_first_tail_x15_r0_body.cx0_17.mlx PRE_first_tail_x15_r0_body.cx1_17.mlx) = true
kernel_rfl PRE_first_tail_x15_r0_body.fp17 : ((PRE_first_tail_x15_r0_body.cln17.filter (fullB PRE_first_tail_x15_r0_body.P17))).map (fun i => (PRE_first_tail_x15_r0_body.cx1_17.mlx.nodes.get (PRE_first_tail_x15_r0_body.kappa17.node i)).map Host.Mlx.Ffi.Node.prim) =
  ((PRE_first_tail_x15_r0_body.cln17.filter (fullB PRE_first_tail_x15_r0_body.P17))).map (fun i => (PRE_first_tail_x15_r0_body.cx0_17.mlx.nodes.get i).map fun nd => PRE_first_tail_x15_r0_body.kappa17.prim nd.prim)
kernel_rfl PRE_first_tail_x15_r0_body.fnordI17 : incrB PRE_first_tail_x15_r0_body.kd17.nodeF (List.range' 15622 0) = true
kernel_rfl PRE_first_tail_x15_r0_body.fnordK17 : (PTrie.keysA PRE_first_tail_x15_r0_body.kd17.node).all (fun k => Nat.ble 15622 k && Nat.blt k 15622) = true
kernel_rfl PRE_first_tail_x15_r0_body.fnordL17 : (PRE_first_tail_x15_r0_body.cln17.filter (Nat.ble PRE_first_tail_x15_r0_body.P17.N0)).all (fun i => Nat.ble i (PRE_first_tail_x15_r0_body.kd17.nodeF i) && (Nat.blt i 15622 || Nat.ble PRE_first_tail_x15_r0_body.kd17.nn0 i)) = true
theorem PRE_first_tail_x15_r0_body.fnord17 : (PRE_first_tail_x15_r0_body.cln17.filter (Nat.ble PRE_first_tail_x15_r0_body.P17.N0)).all (fun i => Nat.ble i (PRE_first_tail_x15_r0_body.kd17.nodeF i) &&
    (PTrie.keysA PRE_first_tail_x15_r0_body.kd17.node).all fun j => !Nat.blt j i || Nat.blt (PRE_first_tail_x15_r0_body.kd17.nodeF j) (PRE_first_tail_x15_r0_body.kd17.nodeF i)) = true :=
  cnord_of PRE_first_tail_x15_r0_body.cnlow17 PRE_first_tail_x15_r0_body.cnn117 PRE_first_tail_x15_r0_body.fnordI17 PRE_first_tail_x15_r0_body.fnordK17 PRE_first_tail_x15_r0_body.fnordL17
kernel_rfl PRE_first_tail_x15_r0_body.fi17 : PRE_first_tail_x15_r0_body.cli17.all (pnB PRE_first_tail_x15_r0_body.cx0_17.mlx) = true
kernel_rfl PRE_first_tail_x15_r0_body.fii17 : PRE_first_tail_x15_r0_body.cli17.all (fun k => decide (PRE_first_tail_x15_r0_body.cx1_17.mlx.items.get (PRE_first_tail_x15_r0_body.kappa17.node k) = (PRE_first_tail_x15_r0_body.cx0_17.mlx.items.get k).map PRE_first_tail_x15_r0_body.kappa17.nv)) = true
/-- **The compaction's footprint.** -/
theorem PRE_first_tail_x15_r0_body.cfoot17 (clean : Conv.NClean (⟨18532, 15622, 2687915, 781⟩ : Conv.Cnt) (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s157.ffi).mlx) (hltC : ∀ h, PH (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s157.ffi).mlx h → h < (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s157.ffi).mlx.next) (nltC : ∀ i, PN (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s157.ffi).mlx i → i < (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s157.ffi).mlx.nnext) (itemsC : ∀ k v, (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s157.ffi).mlx.items.get k = some v → PN (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s157.ffi).mlx k) (tracedC : ∀ h o, (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s157.ffi).mlx.objs.get h = some o → ∀ i ∈ objTraces o, i < PRE_first_tail_x15_r0_body.P17.NL) (cl : SSt (· < 781) PRE_first_tail_x15_r0_body.cx0_17.mlx) :
    Conv.MFoot PRE_first_tail_x15_r0_body.P17 781 PRE_first_tail_x15_r0_body.kappa17 PRE_first_tail_x15_r0_body.kd17 PRE_first_tail_x15_r0_body.khinv17 PRE_first_tail_x15_r0_body.kninv17 (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s157.ffi).mlx PRE_first_tail_x15_r0_body.cx0_17.mlx PRE_first_tail_x15_r0_body.cx1_17.mlx (⟨18532, 15622, 2687915, 781⟩ : Conv.Cnt) PRE_first_tail_x15_r0_body.clo17 PRE_first_tail_x15_r0_body.cln17 PRE_first_tail_x15_r0_body.cli17 PRE_first_tail_x15_r0_body.cwS17 PRE_first_tail_x15_r0_body.cnS17 PRE_first_tail_x15_r0_body.ciS17 :=
  ⟨rfl, rfl, rfl, PRE_first_tail_x15_r0_body.cnh017, PRE_first_tail_x15_r0_body.cnh117, PRE_first_tail_x15_r0_body.cnn017, PRE_first_tail_x15_r0_body.cnn117, PRE_first_tail_x15_r0_body.cplo17, PRE_first_tail_x15_r0_body.ccnt17, PRE_first_tail_x15_r0_body.cnband17, PRE_first_tail_x15_r0_body.chbelow17, PRE_first_tail_x15_r0_body.chren17, PRE_first_tail_x15_r0_body.cband17, PRE_first_tail_x15_r0_body.cnh1pos17, PRE_first_tail_x15_r0_body.cnren17, PRE_first_tail_x15_r0_body.cnlow17, PRE_first_tail_x15_r0_body.cabs0a17, PRE_first_tail_x15_r0_body.cabs0b17, PRE_first_tail_x15_r0_body.ctok117, PRE_first_tail_x15_r0_body.cpend17, PRE_first_tail_x15_r0_body.cerrh17, PRE_first_tail_x15_r0_body.cfiles17, PRE_first_tail_x15_r0_body.carch17, PRE_first_tail_x15_r0_body.csizes17, PRE_first_tail_x15_r0_body.cwired17, PRE_first_tail_x15_r0_body.cfix17, clean, PRE_first_tail_x15_r0_body.fcxn17, PRE_first_tail_x15_r0_body.fcnn17, hltC, nltC, itemsC, tracedC, cl, PRE_first_tail_x15_r0_body.fle017, PRE_first_tail_x15_r0_body.fnk17, PRE_first_tail_x15_r0_body.ckA17, PRE_first_tail_x15_r0_body.cobjsK17, PRE_first_tail_x15_r0_body.cnodesK17, PRE_first_tail_x15_r0_body.citemsK17, PRE_first_tail_x15_r0_body.f1A17, PRE_first_tail_x15_r0_body.f1O17, PRE_first_tail_x15_r0_body.f1N17, PRE_first_tail_x15_r0_body.f1I17, PRE_first_tail_x15_r0_body.fbd17, PRE_first_tail_x15_r0_body.fincW17, PRE_first_tail_x15_r0_body.fincI17, PRE_first_tail_x15_r0_body.fincN17, PRE_first_tail_x15_r0_body.flnF17, PRE_first_tail_x15_r0_body.fh17, PRE_first_tail_x15_r0_body.fo17, PRE_first_tail_x15_r0_body.fok17, PRE_first_tail_x15_r0_body.fnd17, PRE_first_tail_x15_r0_body.fp17, PRE_first_tail_x15_r0_body.fnord17, PRE_first_tail_x15_r0_body.fi17, PRE_first_tail_x15_r0_body.fii17⟩
theorem PRE_first_tail_x15_r0_body.cnshift17 (clean : Conv.NClean (⟨18532, 15622, 2687915, 781⟩ : Conv.Cnt) (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s157.ffi).mlx) (hltC : ∀ h, PH (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s157.ffi).mlx h → h < (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s157.ffi).mlx.next) (nltC : ∀ i, PN (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s157.ffi).mlx i → i < (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s157.ffi).mlx.nnext) (itemsC : ∀ k v, (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s157.ffi).mlx.items.get k = some v → PN (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s157.ffi).mlx k) (tracedC : ∀ h o, (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s157.ffi).mlx.objs.get h = some o → ∀ i ∈ objTraces o, i < PRE_first_tail_x15_r0_body.P17.NL) (cl : SSt (· < 781) PRE_first_tail_x15_r0_body.cx0_17.mlx) : NShift PRE_first_tail_x15_r0_body.P17 781 PRE_first_tail_x15_r0_body.kappa17 PRE_first_tail_x15_r0_body.cx0_17 PRE_first_tail_x15_r0_body.cx1_17 :=
  Conv.nshift_of_foot (PRE_first_tail_x15_r0_body.cfoot17 clean hltC nltC itemsC tracedC cl) PRE_first_tail_x15_r0_body.chost17 (compact_a_eq PRE_first_tail_x15_r0_body.ckn017 PRE_first_tail_x15_r0_body.ckn117 PRE_first_tail_x15_r0_body.ckheap17 PRE_first_tail_x15_r0_body.ckpl17)

-- the observers: the layers' states at the call, the canonical and the merged state, their footprints and checks
noncomputable def PRE_first_tail_x15_r0_body.fxC_17 : PTrie Unit := (Host.Ts.Sim.Full.freedOf PRE_first_tail_x15_r0_body.s157.ffi).getD PTrie.nil
noncomputable def PRE_first_tail_x15_r0_body.krC_17 : Host.Load.Layers.KRec := (Host.Ts.Sim.Full.krecOf PRE_first_tail_x15_r0_body.s157.ffi).getD Host.Load.Layers.KRec.empty
kernel_rfl PRE_first_tail_x15_r0_body.ofxC_17 : (Host.Ts.Sim.Full.freedOf PRE_first_tail_x15_r0_body.s157.ffi) = some PRE_first_tail_x15_r0_body.fxC_17
kernel_rfl PRE_first_tail_x15_r0_body.okrC_17 : (Host.Ts.Sim.Full.krecOf PRE_first_tail_x15_r0_body.s157.ffi) = some PRE_first_tail_x15_r0_body.krC_17
noncomputable def PRE_first_tail_x15_r0_body.fx0_17 : PTrie Unit := (Host.Ts.Sim.Full.freedOf PRE_first_tail_x15_r0_body.s159.ffi).getD PTrie.nil
noncomputable def PRE_first_tail_x15_r0_body.kr0_17 : Host.Load.Layers.KRec := (Host.Ts.Sim.Full.krecOf PRE_first_tail_x15_r0_body.s159.ffi).getD Host.Load.Layers.KRec.empty
kernel_rfl PRE_first_tail_x15_r0_body.ofx0_17 : (Host.Ts.Sim.Full.freedOf PRE_first_tail_x15_r0_body.s159.ffi) = some PRE_first_tail_x15_r0_body.fx0_17
kernel_rfl PRE_first_tail_x15_r0_body.okr0_17 : (Host.Ts.Sim.Full.krecOf PRE_first_tail_x15_r0_body.s159.ffi) = some PRE_first_tail_x15_r0_body.kr0_17
noncomputable def PRE_first_tail_x15_r0_body.fx1_17 : PTrie Unit := (Host.Ts.Sim.Full.freedOf PRE_first_tail_x15_r0_body.s158.ffi).getD PTrie.nil
noncomputable def PRE_first_tail_x15_r0_body.kr1_17 : Host.Load.Layers.KRec := (Host.Ts.Sim.Full.krecOf PRE_first_tail_x15_r0_body.s158.ffi).getD Host.Load.Layers.KRec.empty
kernel_rfl PRE_first_tail_x15_r0_body.ofx1_17 : (Host.Ts.Sim.Full.freedOf PRE_first_tail_x15_r0_body.s158.ffi) = some PRE_first_tail_x15_r0_body.fx1_17
kernel_rfl PRE_first_tail_x15_r0_body.okr1_17 : (Host.Ts.Sim.Full.krecOf PRE_first_tail_x15_r0_body.s158.ffi) = some PRE_first_tail_x15_r0_body.kr1_17
kernel_rfl PRE_first_tail_x15_r0_body.ff017 : PRE_first_tail_x15_r0_body.fx0_17 = Stage.setAll PRE_first_tail_x15_r0_body.fxC_17 (PRE_first_tail_x15_r0_body.clo17.filterMap fun i => (PRE_first_tail_x15_r0_body.fx0_17.get i).map (i, ·))
kernel_rfl PRE_first_tail_x15_r0_body.ff117 : PRE_first_tail_x15_r0_body.fx1_17 = Stage.setAll PRE_first_tail_x15_r0_body.fxC_17 (PRE_first_tail_x15_r0_body.cwS17.filterMap fun i => (PRE_first_tail_x15_r0_body.fx1_17.get i).map (i, ·))
kernel_rfl PRE_first_tail_x15_r0_body.ffck17 : freedLB PRE_first_tail_x15_r0_body.kappa17 PRE_first_tail_x15_r0_body.cx0_17.mlx PRE_first_tail_x15_r0_body.fx0_17 PRE_first_tail_x15_r0_body.fx1_17 PRE_first_tail_x15_r0_body.clo17 = true
kernel_rfl PRE_first_tail_x15_r0_body.fkf017 : PRE_first_tail_x15_r0_body.kr0_17.flags = Stage.setAll PRE_first_tail_x15_r0_body.krC_17.flags (PRE_first_tail_x15_r0_body.clo17.filterMap fun i => (PRE_first_tail_x15_r0_body.kr0_17.flags.get i).map (i, ·))
kernel_rfl PRE_first_tail_x15_r0_body.fkt017 : PRE_first_tail_x15_r0_body.kr0_17.targs = Stage.setAll PRE_first_tail_x15_r0_body.krC_17.targs (PRE_first_tail_x15_r0_body.clo17.filterMap fun i => (PRE_first_tail_x15_r0_body.kr0_17.targs.get i).map (i, ·))
kernel_rfl PRE_first_tail_x15_r0_body.fkf117 : PRE_first_tail_x15_r0_body.kr1_17.flags = Stage.setAll PRE_first_tail_x15_r0_body.krC_17.flags (PRE_first_tail_x15_r0_body.cwS17.filterMap fun i => (PRE_first_tail_x15_r0_body.kr1_17.flags.get i).map (i, ·))
kernel_rfl PRE_first_tail_x15_r0_body.fkt117 : PRE_first_tail_x15_r0_body.kr1_17.targs = Stage.setAll PRE_first_tail_x15_r0_body.krC_17.targs (PRE_first_tail_x15_r0_body.cwS17.filterMap fun i => (PRE_first_tail_x15_r0_body.kr1_17.targs.get i).map (i, ·))
kernel_rfl PRE_first_tail_x15_r0_body.fkck17 : krecLB PRE_first_tail_x15_r0_body.kappa17 781 PRE_first_tail_x15_r0_body.cx0_17.mlx PRE_first_tail_x15_r0_body.kr0_17 PRE_first_tail_x15_r0_body.kr1_17 PRE_first_tail_x15_r0_body.clo17 = true
kernel_rfl PRE_first_tail_x15_r0_body.fkn17 : Nat.ble 781 781 = true
-- the bridge and the pending traces' regions
kernel_rfl PRE_first_tail_x15_r0_body.cbridge17 : Host.Ts.Sim.Full.bridgeOf PRE_first_tail_x15_r0_body.s158.ffi = Host.Ts.Sim.Full.bridgeOf PRE_first_tail_x15_r0_body.s159.ffi
kernel_rfl PRE_first_tail_x15_r0_body.cpendR17 : pendRegB PRE_first_tail_x15_r0_body.kappa17 (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s159.ffi).mlx = true
kernel_rfl PRE_first_tail_x15_r0_body.cpendLe17 : Nat.ble (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s159.ffi).mlx.next (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s158.ffi).mlx.next = true
/-- **The compaction's native shift**, given the call's bookkeeping, its relation's facts (the model's and the
observers') and the canonical closedness. -/
theorem PRE_first_tail_x15_r0_body.cshift17 (clean : Conv.NClean (⟨18532, 15622, 2687915, 781⟩ : Conv.Cnt) (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s157.ffi).mlx) (hltC : ∀ h, PH (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s157.ffi).mlx h → h < (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s157.ffi).mlx.next) (nltC : ∀ i, PN (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s157.ffi).mlx i → i < (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s157.ffi).mlx.nnext) (itemsC : ∀ k v, (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s157.ffi).mlx.items.get k = some v → PN (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s157.ffi).mlx k) (tracedC : ∀ h o, (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s157.ffi).mlx.objs.get h = some o → ∀ i ∈ objTraces o, i < PRE_first_tail_x15_r0_body.P17.NL) (cl : SSt (· < 781) PRE_first_tail_x15_r0_body.cx0_17.mlx)
    (hobjC : ∀ h, PRE_first_tail_x15_r0_body.fxC_17.get h = some () → ((Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s157.ffi).mlx.objs.get h).isSome = true)
    (hfC : ∀ h, (PRE_first_tail_x15_r0_body.krC_17.flags.get h).isSome = true → ((Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s157.ffi).mlx.objs.get h).isSome = true)
    (htC : ∀ h, (PRE_first_tail_x15_r0_body.krC_17.targs.get h).isSome = true → ((Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s157.ffi).mlx.objs.get h).isSome = true)
    (hclC : ∀ h l, PRE_first_tail_x15_r0_body.krC_17.targs.get h = some l → Host.Ts.Sim.Full.STargs (· < (⟨18532, 15622, 2687915, 781⟩ : Conv.Cnt).n) l) :
    Conv.FullShiftQ PRE_first_tail_x15_r0_body.P17 781 PRE_first_tail_x15_r0_body.kappa17 PRE_first_tail_x15_r0_body.s159.ffi PRE_first_tail_x15_r0_body.s158.ffi :=
  ⟨PRE_first_tail_x15_r0_body.cnshift17 clean hltC nltC itemsC tracedC cl, PRE_first_tail_x15_r0_body.cqueue17, fun t ht => bSN_sound (List.all_eq_true.mp PRE_first_tail_x15_r0_body.ctokSupp17 t ht),
    PRE_first_tail_x15_r0_body.cbridge17,
    liveShift_foot (x0' := Host.Ts.Sim.Full.mlxOf PRE_first_tail_x15_r0_body.s159.ffi) (x1' := Host.Ts.Sim.Full.mlxOf PRE_first_tail_x15_r0_body.s158.ffi) (PRE_first_tail_x15_r0_body.cfoot17 clean hltC nltC itemsC tracedC cl) rfl PRE_first_tail_x15_r0_body.ofx0_17 PRE_first_tail_x15_r0_body.ofx1_17 hobjC PRE_first_tail_x15_r0_body.ff017 PRE_first_tail_x15_r0_body.ff117 PRE_first_tail_x15_r0_body.ffck17,
    kernShift_foot (x0' := Host.Ts.Sim.Full.mlxOf PRE_first_tail_x15_r0_body.s159.ffi) (x1' := Host.Ts.Sim.Full.mlxOf PRE_first_tail_x15_r0_body.s158.ffi) (PRE_first_tail_x15_r0_body.cfoot17 clean hltC nltC itemsC tracedC cl) rfl PRE_first_tail_x15_r0_body.okr0_17 PRE_first_tail_x15_r0_body.okr1_17 (Nat.le_of_ble_eq_true PRE_first_tail_x15_r0_body.fkn17) hfC htC hclC
      PRE_first_tail_x15_r0_body.fkf017 PRE_first_tail_x15_r0_body.fkt017 PRE_first_tail_x15_r0_body.fkf117 PRE_first_tail_x15_r0_body.fkt117 PRE_first_tail_x15_r0_body.fkck17,
    pendReg_of rfl PRE_first_tail_x15_r0_body.cnh017 PRE_first_tail_x15_r0_body.cnh117 (Nat.le_of_ble_eq_true PRE_first_tail_x15_r0_body.cpendLe17) PRE_first_tail_x15_r0_body.cpendR17⟩

end Host.Load.Run.Tpl
