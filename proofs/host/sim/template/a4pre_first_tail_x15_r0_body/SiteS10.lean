import host.sim.template.a4pre_first_tail_x15_r0_body.SiteCl10
import host.sim.conv.CompactFull
import host.sim.template.FootGen
set_option Elab.async false
namespace Host.Load.Run.Tpl
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
open Host.Ts Host.Ts.Sim Host.Ts.Sim.Template

/-! The compaction's native shift at call site 10 from its footprint (`Conv.nshift_of_foot`), and the observers'
(`liveShift_foot`, `kernShift_foot`): `Conv.FullShiftQ` for `Conv.full_compactQ`, given the call's bookkeeping and its
relation's facts. -/

/-- The load parameters of the chain (band-free: its start's node counter as `NL` and `N0`). -/
def PRE_first_tail_x15_r0_body.Pc10 : LoadP := ⟨18151, 131072, 1099511627776, 15235, 15235, []⟩
/-- The site's band raised to the map's checked fixed-node prefix, including newly recorded closure traces. -/
def PRE_first_tail_x15_r0_body.P10 : LoadP := PRE_first_tail_x15_r0_body.Pc10.raise 15492
kernel_rfl PRE_first_tail_x15_r0_body.craise10 : Nat.ble PRE_first_tail_x15_r0_body.Pc10.N0 15492 = true
theorem PRE_first_tail_x15_r0_body.raised10 : Host.Ts.Sim.Full.Raised PRE_first_tail_x15_r0_body.Pc10 PRE_first_tail_x15_r0_body.P10 :=
  .inr ⟨15492, rfl, Nat.le_of_ble_eq_true PRE_first_tail_x15_r0_body.craise10, rfl⟩
noncomputable abbrev PRE_first_tail_x15_r0_body.cx0_10 : Host.Load.LSt := clearTokens (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s112.ffi)
noncomputable abbrev PRE_first_tail_x15_r0_body.cx1_10 : Host.Load.LSt := clearTokens (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s111.ffi)
def PRE_first_tail_x15_r0_body.khinv10 : PTrie Nat := Stage.setAll PTrie.nil []
def PRE_first_tail_x15_r0_body.kninv10 : PTrie Nat := Stage.setAll PTrie.nil []
/-- The stage's footprint: its written and fresh handles, fresh nodes, written and fresh items. -/
def PRE_first_tail_x15_r0_body.cwS10 : List Nat := []
def PRE_first_tail_x15_r0_body.cnS10 : List Nat := List.range' 15492 0
def PRE_first_tail_x15_r0_body.ciS10 : List Nat := [] ++ List.range' 15492 0

-- the small checks (`MChecks`'s)
kernel_rfl PRE_first_tail_x15_r0_body.cnh010 : PRE_first_tail_x15_r0_body.kd10.nh0 = PRE_first_tail_x15_r0_body.cx0_10.mlx.next
kernel_rfl PRE_first_tail_x15_r0_body.cnh110 : PRE_first_tail_x15_r0_body.kd10.nh1 = PRE_first_tail_x15_r0_body.cx1_10.mlx.next
kernel_rfl PRE_first_tail_x15_r0_body.cnn010 : PRE_first_tail_x15_r0_body.kd10.nn0 = PRE_first_tail_x15_r0_body.cx0_10.mlx.nnext
kernel_rfl PRE_first_tail_x15_r0_body.cnn110 : PRE_first_tail_x15_r0_body.kd10.nn1 = PRE_first_tail_x15_r0_body.cx1_10.mlx.nnext
kernel_rfl PRE_first_tail_x15_r0_body.cplo10 : (Nat.blt 0 PRE_first_tail_x15_r0_body.P10.lo && Nat.ble PRE_first_tail_x15_r0_body.P10.lo PRE_first_tail_x15_r0_body.cx0_10.mlx.next && Nat.ble PRE_first_tail_x15_r0_body.P10.lo RData.bigHi && Nat.ble RData.bigHi PRE_first_tail_x15_r0_body.P10.E) = true
kernel_rfl PRE_first_tail_x15_r0_body.ccnt10 : (Nat.ble PRE_first_tail_x15_r0_body.cx0_10.mlx.next PRE_first_tail_x15_r0_body.cx1_10.mlx.next && Nat.ble PRE_first_tail_x15_r0_body.cx0_10.mlx.nnext PRE_first_tail_x15_r0_body.cx1_10.mlx.nnext) = true
kernel_rfl PRE_first_tail_x15_r0_body.cnband10 : (Nat.blt 0 PRE_first_tail_x15_r0_body.P10.NL && Nat.ble PRE_first_tail_x15_r0_body.P10.NL PRE_first_tail_x15_r0_body.P10.N0 && Nat.ble PRE_first_tail_x15_r0_body.P10.N0 PRE_first_tail_x15_r0_body.cx0_10.mlx.nnext) = true
kernel_rfl PRE_first_tail_x15_r0_body.chbelow10 : PRE_first_tail_x15_r0_body.kd10.checkHndBelow = true
kernel_rfl PRE_first_tail_x15_r0_body.chren10 : checkRenG PRE_first_tail_x15_r0_body.kd10.hnd PRE_first_tail_x15_r0_body.khinv10 (phB PRE_first_tail_x15_r0_body.cx0_10.mlx) = true
kernel_rfl PRE_first_tail_x15_r0_body.cband10 : PRE_first_tail_x15_r0_body.kd10.checkBand PRE_first_tail_x15_r0_body.P10.lo = true
kernel_rfl PRE_first_tail_x15_r0_body.cnh1pos10 : Nat.blt 0 PRE_first_tail_x15_r0_body.kd10.nh1 = true
kernel_rfl PRE_first_tail_x15_r0_body.cnren10 : checkRenG PRE_first_tail_x15_r0_body.kd10.node PRE_first_tail_x15_r0_body.kninv10 (pnB PRE_first_tail_x15_r0_body.cx0_10.mlx) = true
kernel_rfl PRE_first_tail_x15_r0_body.cnlow10 : (PTrie.keysA PRE_first_tail_x15_r0_body.kd10.node).all (fun j => Nat.ble PRE_first_tail_x15_r0_body.P10.NL j && Nat.blt (PRE_first_tail_x15_r0_body.kd10.nodeF j) PRE_first_tail_x15_r0_body.cx1_10.mlx.nnext) = true
kernel_rfl PRE_first_tail_x15_r0_body.cabs0a10 : PRE_first_tail_x15_r0_body.cx0_10.mlx.arrs.get 0 = none
kernel_rfl PRE_first_tail_x15_r0_body.cabs0b10 : PRE_first_tail_x15_r0_body.cx0_10.mlx.objs.get 0 = none
kernel_rfl PRE_first_tail_x15_r0_body.ctok110 : PRE_first_tail_x15_r0_body.cx1_10.mlx.tokens = []
kernel_rfl PRE_first_tail_x15_r0_body.cpend10 : PRE_first_tail_x15_r0_body.cx1_10.mlx.pending = PRE_first_tail_x15_r0_body.cx0_10.mlx.pending.map PRE_first_tail_x15_r0_body.kappa10.pend
kernel_rfl PRE_first_tail_x15_r0_body.cerrh10 : PRE_first_tail_x15_r0_body.cx1_10.mlx.errh = PRE_first_tail_x15_r0_body.cx0_10.mlx.errh.map PRE_first_tail_x15_r0_body.kappa10.arg
kernel_rfl PRE_first_tail_x15_r0_body.cfiles10 : PRE_first_tail_x15_r0_body.cx1_10.mlx.files = PRE_first_tail_x15_r0_body.cx0_10.mlx.files
kernel_rfl PRE_first_tail_x15_r0_body.carch10 : PRE_first_tail_x15_r0_body.cx1_10.mlx.arch = PRE_first_tail_x15_r0_body.cx0_10.mlx.arch
kernel_rfl PRE_first_tail_x15_r0_body.csizes10 : PRE_first_tail_x15_r0_body.cx1_10.mlx.deviceSizes = PRE_first_tail_x15_r0_body.cx0_10.mlx.deviceSizes
kernel_rfl PRE_first_tail_x15_r0_body.cwired10 : PRE_first_tail_x15_r0_body.cx1_10.mlx.wired = PRE_first_tail_x15_r0_body.cx0_10.mlx.wired
kernel_rfl PRE_first_tail_x15_r0_body.chost10 : PRE_first_tail_x15_r0_body.cx1_10.host = PRE_first_tail_x15_r0_body.cx0_10.host
-- the compaction map's addresses are `PRE_first_tail_x15_r0_body.kd10`'s
kernel_rfl PRE_first_tail_x15_r0_body.ckn010 : PRE_first_tail_x15_r0_body.kd10.n0 = 2683093
kernel_rfl PRE_first_tail_x15_r0_body.ckn110 : PRE_first_tail_x15_r0_body.kd10.n1 = 2683095
kernel_rfl PRE_first_tail_x15_r0_body.ckheap10 : (PTrie.keysA PRE_first_tail_x15_r0_body.kd10.heap).all (fun x => Nat.ble 2683093 x) = true
kernel_rfl PRE_first_tail_x15_r0_body.ckpl10 : (List.range 0).all (fun j => decide (PRE_first_tail_x15_r0_body.kd10.heap.get (2683093 + j) = nth? PRE_first_tail_x15_r0_body.pl10 j)) = true
-- the map fixes the call's names (`Conv.fixOld_compact`), the call's counters
kernel_rfl PRE_first_tail_x15_r0_body.fja10 : Nat.ble 2683093 2683093 = true
kernel_rfl PRE_first_tail_x15_r0_body.fn10 : Nat.ble 506 506 = true
kernel_rfl PRE_first_tail_x15_r0_body.fjaD10 : Nat.ble 2683093 PRE_first_tail_x15_r0_body.kd10.n0 = true
kernel_rfl PRE_first_tail_x15_r0_body.fxn10 : Nat.ble 18410 PRE_first_tail_x15_r0_body.kd10.nh0 = true
kernel_rfl PRE_first_tail_x15_r0_body.fnn10 : Nat.ble 15492 PRE_first_tail_x15_r0_body.kd10.nn0 = true
kernel_rfl PRE_first_tail_x15_r0_body.fxb10 : Nat.ble 18410 RData.bigHi = true
kernel_rfl PRE_first_tail_x15_r0_body.fheap10 : (PTrie.keysA PRE_first_tail_x15_r0_body.kd10.heap).all (Nat.ble (⟨18410, 15492, 2683093, 506⟩ : Conv.Cnt).ja) = true
kernel_rfl PRE_first_tail_x15_r0_body.fhnd10 : (PTrie.keysA PRE_first_tail_x15_r0_body.kd10.hnd).all (Nat.ble (⟨18410, 15492, 2683093, 506⟩ : Conv.Cnt).xn) = true
kernel_rfl PRE_first_tail_x15_r0_body.fnode10 : (PTrie.keysA PRE_first_tail_x15_r0_body.kd10.node).all (Nat.ble (⟨18410, 15492, 2683093, 506⟩ : Conv.Cnt).nn) = true
/-- The compaction map fixes the call's names. -/
theorem PRE_first_tail_x15_r0_body.cfix10 : Conv.FixOld (⟨18410, 15492, 2683093, 506⟩ : Conv.Cnt) PRE_first_tail_x15_r0_body.kappa10 :=
  Conv.fixOld_compact (Nat.le_of_ble_eq_true PRE_first_tail_x15_r0_body.fja10) (Nat.le_of_ble_eq_true PRE_first_tail_x15_r0_body.fn10) (Nat.le_of_ble_eq_true PRE_first_tail_x15_r0_body.fjaD10) (Nat.le_of_ble_eq_true PRE_first_tail_x15_r0_body.fxn10) (Nat.le_of_ble_eq_true PRE_first_tail_x15_r0_body.fnn10) (Nat.le_of_ble_eq_true PRE_first_tail_x15_r0_body.fxb10) PRE_first_tail_x15_r0_body.fheap10 PRE_first_tail_x15_r0_body.fhnd10 PRE_first_tail_x15_r0_body.fnode10
kernel_rfl PRE_first_tail_x15_r0_body.fcxn10 : (⟨18410, 15492, 2683093, 506⟩ : Conv.Cnt).xn = (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s110.ffi).mlx.next
kernel_rfl PRE_first_tail_x15_r0_body.fcnn10 : (⟨18410, 15492, 2683093, 506⟩ : Conv.Cnt).nn = (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s110.ffi).mlx.nnext
kernel_rfl PRE_first_tail_x15_r0_body.fle010 : (Nat.ble (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s110.ffi).mlx.next PRE_first_tail_x15_r0_body.cx0_10.mlx.next && Nat.ble (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s110.ffi).mlx.nnext PRE_first_tail_x15_r0_body.cx0_10.mlx.nnext && Nat.ble (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s110.ffi).mlx.next RData.bigHi) = true
kernel_rfl PRE_first_tail_x15_r0_body.fnk10 : (PTrie.keysA PRE_first_tail_x15_r0_body.kd10.node).all (Nat.ble (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s110.ffi).mlx.nnext) = true
-- the merged state keeps the call's entries off the stage's footprint
kernel_rfl PRE_first_tail_x15_r0_body.f1A10 : PRE_first_tail_x15_r0_body.cx1_10.mlx.arrs = Stage.setAll (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s110.ffi).mlx.arrs (PRE_first_tail_x15_r0_body.cwS10.filterMap fun i => (PRE_first_tail_x15_r0_body.cx1_10.mlx.arrs.get i).map (i, ·))
kernel_rfl PRE_first_tail_x15_r0_body.f1O10 : PRE_first_tail_x15_r0_body.cx1_10.mlx.objs = Stage.setAll (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s110.ffi).mlx.objs (PRE_first_tail_x15_r0_body.cwS10.filterMap fun i => (PRE_first_tail_x15_r0_body.cx1_10.mlx.objs.get i).map (i, ·))
kernel_rfl PRE_first_tail_x15_r0_body.f1N10 : PRE_first_tail_x15_r0_body.cx1_10.mlx.nodes = Stage.setAll (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s110.ffi).mlx.nodes (PRE_first_tail_x15_r0_body.cnS10.filterMap fun i => (PRE_first_tail_x15_r0_body.cx1_10.mlx.nodes.get i).map (i, ·))
kernel_rfl PRE_first_tail_x15_r0_body.f1I10 : PRE_first_tail_x15_r0_body.cx1_10.mlx.items = Stage.setAll (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s110.ffi).mlx.items (PRE_first_tail_x15_r0_body.ciS10.filterMap fun i => (PRE_first_tail_x15_r0_body.cx1_10.mlx.items.get i).map (i, ·))
kernel_rfl PRE_first_tail_x15_r0_body.fbd10 : (PRE_first_tail_x15_r0_body.clo10 ++ PRE_first_tail_x15_r0_body.cln10 ++ PRE_first_tail_x15_r0_body.cli10 ++ PRE_first_tail_x15_r0_body.cwS10 ++ PRE_first_tail_x15_r0_body.cnS10 ++ PRE_first_tail_x15_r0_body.ciS10).all (fun i => Nat.blt (i / 4096) (4 ^ 31)) = true
kernel_rfl PRE_first_tail_x15_r0_body.fincW10 : PRE_first_tail_x15_r0_body.cwS10.all (fun h => !Nat.blt h (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s110.ffi).mlx.next || PRE_first_tail_x15_r0_body.clo10.contains h) = true
kernel_rfl PRE_first_tail_x15_r0_body.fincI10 : PRE_first_tail_x15_r0_body.ciS10.all (fun k => !Nat.blt k (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s110.ffi).mlx.nnext || PRE_first_tail_x15_r0_body.cli10.contains k) = true
kernel_rfl PRE_first_tail_x15_r0_body.fincN10 : PRE_first_tail_x15_r0_body.cnS10.all (Nat.ble (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s110.ffi).mlx.nnext) = true
kernel_rfl PRE_first_tail_x15_r0_body.flnF10 : PRE_first_tail_x15_r0_body.cln10.all (Nat.ble (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s110.ffi).mlx.nnext) = true
-- the checks over the changed lists
kernel_rfl PRE_first_tail_x15_r0_body.fh10 : PRE_first_tail_x15_r0_body.clo10.all (handleOK PRE_first_tail_x15_r0_body.kappa10 PRE_first_tail_x15_r0_body.P10.lo PRE_first_tail_x15_r0_body.cx0_10.mlx PRE_first_tail_x15_r0_body.cx1_10.mlx) = true
kernel_rfl PRE_first_tail_x15_r0_body.fo10 : PRE_first_tail_x15_r0_body.clo10.map (fun h => PRE_first_tail_x15_r0_body.cx1_10.mlx.objs.get (PRE_first_tail_x15_r0_body.kappa10.handle h)) = PRE_first_tail_x15_r0_body.clo10.map (fun h => (PRE_first_tail_x15_r0_body.cx0_10.mlx.objs.get h).map PRE_first_tail_x15_r0_body.kappa10.nobj)
kernel_rfl PRE_first_tail_x15_r0_body.fok10 : PRE_first_tail_x15_r0_body.clo10.all (objOK PRE_first_tail_x15_r0_body.kappa10 PRE_first_tail_x15_r0_body.P10.NL PRE_first_tail_x15_r0_body.cx0_10.mlx) = true
kernel_rfl PRE_first_tail_x15_r0_body.fnd10 : PRE_first_tail_x15_r0_body.cln10.all (nodeOKF PRE_first_tail_x15_r0_body.kappa10 PRE_first_tail_x15_r0_body.P10 PRE_first_tail_x15_r0_body.cx0_10.mlx PRE_first_tail_x15_r0_body.cx1_10.mlx) = true
kernel_rfl PRE_first_tail_x15_r0_body.fp10 : ((PRE_first_tail_x15_r0_body.cln10.filter (fullB PRE_first_tail_x15_r0_body.P10))).map (fun i => (PRE_first_tail_x15_r0_body.cx1_10.mlx.nodes.get (PRE_first_tail_x15_r0_body.kappa10.node i)).map Host.Mlx.Ffi.Node.prim) =
  ((PRE_first_tail_x15_r0_body.cln10.filter (fullB PRE_first_tail_x15_r0_body.P10))).map (fun i => (PRE_first_tail_x15_r0_body.cx0_10.mlx.nodes.get i).map fun nd => PRE_first_tail_x15_r0_body.kappa10.prim nd.prim)
kernel_rfl PRE_first_tail_x15_r0_body.fnordI10 : incrB PRE_first_tail_x15_r0_body.kd10.nodeF (List.range' 15492 0) = true
kernel_rfl PRE_first_tail_x15_r0_body.fnordK10 : (PTrie.keysA PRE_first_tail_x15_r0_body.kd10.node).all (fun k => Nat.ble 15492 k && Nat.blt k 15492) = true
kernel_rfl PRE_first_tail_x15_r0_body.fnordL10 : (PRE_first_tail_x15_r0_body.cln10.filter (Nat.ble PRE_first_tail_x15_r0_body.P10.N0)).all (fun i => Nat.ble i (PRE_first_tail_x15_r0_body.kd10.nodeF i) && (Nat.blt i 15492 || Nat.ble PRE_first_tail_x15_r0_body.kd10.nn0 i)) = true
theorem PRE_first_tail_x15_r0_body.fnord10 : (PRE_first_tail_x15_r0_body.cln10.filter (Nat.ble PRE_first_tail_x15_r0_body.P10.N0)).all (fun i => Nat.ble i (PRE_first_tail_x15_r0_body.kd10.nodeF i) &&
    (PTrie.keysA PRE_first_tail_x15_r0_body.kd10.node).all fun j => !Nat.blt j i || Nat.blt (PRE_first_tail_x15_r0_body.kd10.nodeF j) (PRE_first_tail_x15_r0_body.kd10.nodeF i)) = true :=
  cnord_of PRE_first_tail_x15_r0_body.cnlow10 PRE_first_tail_x15_r0_body.cnn110 PRE_first_tail_x15_r0_body.fnordI10 PRE_first_tail_x15_r0_body.fnordK10 PRE_first_tail_x15_r0_body.fnordL10
kernel_rfl PRE_first_tail_x15_r0_body.fi10 : PRE_first_tail_x15_r0_body.cli10.all (pnB PRE_first_tail_x15_r0_body.cx0_10.mlx) = true
kernel_rfl PRE_first_tail_x15_r0_body.fii10 : PRE_first_tail_x15_r0_body.cli10.all (fun k => decide (PRE_first_tail_x15_r0_body.cx1_10.mlx.items.get (PRE_first_tail_x15_r0_body.kappa10.node k) = (PRE_first_tail_x15_r0_body.cx0_10.mlx.items.get k).map PRE_first_tail_x15_r0_body.kappa10.nv)) = true
/-- **The compaction's footprint.** -/
theorem PRE_first_tail_x15_r0_body.cfoot10 (clean : Conv.NClean (⟨18410, 15492, 2683093, 506⟩ : Conv.Cnt) (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s110.ffi).mlx) (hltC : ∀ h, PH (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s110.ffi).mlx h → h < (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s110.ffi).mlx.next) (nltC : ∀ i, PN (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s110.ffi).mlx i → i < (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s110.ffi).mlx.nnext) (itemsC : ∀ k v, (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s110.ffi).mlx.items.get k = some v → PN (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s110.ffi).mlx k) (tracedC : ∀ h o, (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s110.ffi).mlx.objs.get h = some o → ∀ i ∈ objTraces o, i < PRE_first_tail_x15_r0_body.P10.NL) (cl : SSt (· < 506) PRE_first_tail_x15_r0_body.cx0_10.mlx) :
    Conv.MFoot PRE_first_tail_x15_r0_body.P10 506 PRE_first_tail_x15_r0_body.kappa10 PRE_first_tail_x15_r0_body.kd10 PRE_first_tail_x15_r0_body.khinv10 PRE_first_tail_x15_r0_body.kninv10 (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s110.ffi).mlx PRE_first_tail_x15_r0_body.cx0_10.mlx PRE_first_tail_x15_r0_body.cx1_10.mlx (⟨18410, 15492, 2683093, 506⟩ : Conv.Cnt) PRE_first_tail_x15_r0_body.clo10 PRE_first_tail_x15_r0_body.cln10 PRE_first_tail_x15_r0_body.cli10 PRE_first_tail_x15_r0_body.cwS10 PRE_first_tail_x15_r0_body.cnS10 PRE_first_tail_x15_r0_body.ciS10 :=
  ⟨rfl, rfl, rfl, PRE_first_tail_x15_r0_body.cnh010, PRE_first_tail_x15_r0_body.cnh110, PRE_first_tail_x15_r0_body.cnn010, PRE_first_tail_x15_r0_body.cnn110, PRE_first_tail_x15_r0_body.cplo10, PRE_first_tail_x15_r0_body.ccnt10, PRE_first_tail_x15_r0_body.cnband10, PRE_first_tail_x15_r0_body.chbelow10, PRE_first_tail_x15_r0_body.chren10, PRE_first_tail_x15_r0_body.cband10, PRE_first_tail_x15_r0_body.cnh1pos10, PRE_first_tail_x15_r0_body.cnren10, PRE_first_tail_x15_r0_body.cnlow10, PRE_first_tail_x15_r0_body.cabs0a10, PRE_first_tail_x15_r0_body.cabs0b10, PRE_first_tail_x15_r0_body.ctok110, PRE_first_tail_x15_r0_body.cpend10, PRE_first_tail_x15_r0_body.cerrh10, PRE_first_tail_x15_r0_body.cfiles10, PRE_first_tail_x15_r0_body.carch10, PRE_first_tail_x15_r0_body.csizes10, PRE_first_tail_x15_r0_body.cwired10, PRE_first_tail_x15_r0_body.cfix10, clean, PRE_first_tail_x15_r0_body.fcxn10, PRE_first_tail_x15_r0_body.fcnn10, hltC, nltC, itemsC, tracedC, cl, PRE_first_tail_x15_r0_body.fle010, PRE_first_tail_x15_r0_body.fnk10, PRE_first_tail_x15_r0_body.ckA10, PRE_first_tail_x15_r0_body.cobjsK10, PRE_first_tail_x15_r0_body.cnodesK10, PRE_first_tail_x15_r0_body.citemsK10, PRE_first_tail_x15_r0_body.f1A10, PRE_first_tail_x15_r0_body.f1O10, PRE_first_tail_x15_r0_body.f1N10, PRE_first_tail_x15_r0_body.f1I10, PRE_first_tail_x15_r0_body.fbd10, PRE_first_tail_x15_r0_body.fincW10, PRE_first_tail_x15_r0_body.fincI10, PRE_first_tail_x15_r0_body.fincN10, PRE_first_tail_x15_r0_body.flnF10, PRE_first_tail_x15_r0_body.fh10, PRE_first_tail_x15_r0_body.fo10, PRE_first_tail_x15_r0_body.fok10, PRE_first_tail_x15_r0_body.fnd10, PRE_first_tail_x15_r0_body.fp10, PRE_first_tail_x15_r0_body.fnord10, PRE_first_tail_x15_r0_body.fi10, PRE_first_tail_x15_r0_body.fii10⟩
theorem PRE_first_tail_x15_r0_body.cnshift10 (clean : Conv.NClean (⟨18410, 15492, 2683093, 506⟩ : Conv.Cnt) (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s110.ffi).mlx) (hltC : ∀ h, PH (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s110.ffi).mlx h → h < (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s110.ffi).mlx.next) (nltC : ∀ i, PN (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s110.ffi).mlx i → i < (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s110.ffi).mlx.nnext) (itemsC : ∀ k v, (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s110.ffi).mlx.items.get k = some v → PN (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s110.ffi).mlx k) (tracedC : ∀ h o, (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s110.ffi).mlx.objs.get h = some o → ∀ i ∈ objTraces o, i < PRE_first_tail_x15_r0_body.P10.NL) (cl : SSt (· < 506) PRE_first_tail_x15_r0_body.cx0_10.mlx) : NShift PRE_first_tail_x15_r0_body.P10 506 PRE_first_tail_x15_r0_body.kappa10 PRE_first_tail_x15_r0_body.cx0_10 PRE_first_tail_x15_r0_body.cx1_10 :=
  Conv.nshift_of_foot (PRE_first_tail_x15_r0_body.cfoot10 clean hltC nltC itemsC tracedC cl) PRE_first_tail_x15_r0_body.chost10 (compact_a_eq PRE_first_tail_x15_r0_body.ckn010 PRE_first_tail_x15_r0_body.ckn110 PRE_first_tail_x15_r0_body.ckheap10 PRE_first_tail_x15_r0_body.ckpl10)

-- the observers: the layers' states at the call, the canonical and the merged state, their footprints and checks
noncomputable def PRE_first_tail_x15_r0_body.fxC_10 : PTrie Unit := (Host.Ts.Sim.Full.freedOf PRE_first_tail_x15_r0_body.s110.ffi).getD PTrie.nil
noncomputable def PRE_first_tail_x15_r0_body.krC_10 : Host.Load.Layers.KRec := (Host.Ts.Sim.Full.krecOf PRE_first_tail_x15_r0_body.s110.ffi).getD Host.Load.Layers.KRec.empty
kernel_rfl PRE_first_tail_x15_r0_body.ofxC_10 : (Host.Ts.Sim.Full.freedOf PRE_first_tail_x15_r0_body.s110.ffi) = some PRE_first_tail_x15_r0_body.fxC_10
kernel_rfl PRE_first_tail_x15_r0_body.okrC_10 : (Host.Ts.Sim.Full.krecOf PRE_first_tail_x15_r0_body.s110.ffi) = some PRE_first_tail_x15_r0_body.krC_10
noncomputable def PRE_first_tail_x15_r0_body.fx0_10 : PTrie Unit := (Host.Ts.Sim.Full.freedOf PRE_first_tail_x15_r0_body.s112.ffi).getD PTrie.nil
noncomputable def PRE_first_tail_x15_r0_body.kr0_10 : Host.Load.Layers.KRec := (Host.Ts.Sim.Full.krecOf PRE_first_tail_x15_r0_body.s112.ffi).getD Host.Load.Layers.KRec.empty
kernel_rfl PRE_first_tail_x15_r0_body.ofx0_10 : (Host.Ts.Sim.Full.freedOf PRE_first_tail_x15_r0_body.s112.ffi) = some PRE_first_tail_x15_r0_body.fx0_10
kernel_rfl PRE_first_tail_x15_r0_body.okr0_10 : (Host.Ts.Sim.Full.krecOf PRE_first_tail_x15_r0_body.s112.ffi) = some PRE_first_tail_x15_r0_body.kr0_10
noncomputable def PRE_first_tail_x15_r0_body.fx1_10 : PTrie Unit := (Host.Ts.Sim.Full.freedOf PRE_first_tail_x15_r0_body.s111.ffi).getD PTrie.nil
noncomputable def PRE_first_tail_x15_r0_body.kr1_10 : Host.Load.Layers.KRec := (Host.Ts.Sim.Full.krecOf PRE_first_tail_x15_r0_body.s111.ffi).getD Host.Load.Layers.KRec.empty
kernel_rfl PRE_first_tail_x15_r0_body.ofx1_10 : (Host.Ts.Sim.Full.freedOf PRE_first_tail_x15_r0_body.s111.ffi) = some PRE_first_tail_x15_r0_body.fx1_10
kernel_rfl PRE_first_tail_x15_r0_body.okr1_10 : (Host.Ts.Sim.Full.krecOf PRE_first_tail_x15_r0_body.s111.ffi) = some PRE_first_tail_x15_r0_body.kr1_10
kernel_rfl PRE_first_tail_x15_r0_body.ff010 : PRE_first_tail_x15_r0_body.fx0_10 = Stage.setAll PRE_first_tail_x15_r0_body.fxC_10 (PRE_first_tail_x15_r0_body.clo10.filterMap fun i => (PRE_first_tail_x15_r0_body.fx0_10.get i).map (i, ·))
kernel_rfl PRE_first_tail_x15_r0_body.ff110 : PRE_first_tail_x15_r0_body.fx1_10 = Stage.setAll PRE_first_tail_x15_r0_body.fxC_10 (PRE_first_tail_x15_r0_body.cwS10.filterMap fun i => (PRE_first_tail_x15_r0_body.fx1_10.get i).map (i, ·))
kernel_rfl PRE_first_tail_x15_r0_body.ffck10 : freedLB PRE_first_tail_x15_r0_body.kappa10 PRE_first_tail_x15_r0_body.cx0_10.mlx PRE_first_tail_x15_r0_body.fx0_10 PRE_first_tail_x15_r0_body.fx1_10 PRE_first_tail_x15_r0_body.clo10 = true
kernel_rfl PRE_first_tail_x15_r0_body.fkf010 : PRE_first_tail_x15_r0_body.kr0_10.flags = Stage.setAll PRE_first_tail_x15_r0_body.krC_10.flags (PRE_first_tail_x15_r0_body.clo10.filterMap fun i => (PRE_first_tail_x15_r0_body.kr0_10.flags.get i).map (i, ·))
kernel_rfl PRE_first_tail_x15_r0_body.fkt010 : PRE_first_tail_x15_r0_body.kr0_10.targs = Stage.setAll PRE_first_tail_x15_r0_body.krC_10.targs (PRE_first_tail_x15_r0_body.clo10.filterMap fun i => (PRE_first_tail_x15_r0_body.kr0_10.targs.get i).map (i, ·))
kernel_rfl PRE_first_tail_x15_r0_body.fkf110 : PRE_first_tail_x15_r0_body.kr1_10.flags = Stage.setAll PRE_first_tail_x15_r0_body.krC_10.flags (PRE_first_tail_x15_r0_body.cwS10.filterMap fun i => (PRE_first_tail_x15_r0_body.kr1_10.flags.get i).map (i, ·))
kernel_rfl PRE_first_tail_x15_r0_body.fkt110 : PRE_first_tail_x15_r0_body.kr1_10.targs = Stage.setAll PRE_first_tail_x15_r0_body.krC_10.targs (PRE_first_tail_x15_r0_body.cwS10.filterMap fun i => (PRE_first_tail_x15_r0_body.kr1_10.targs.get i).map (i, ·))
kernel_rfl PRE_first_tail_x15_r0_body.fkck10 : krecLB PRE_first_tail_x15_r0_body.kappa10 506 PRE_first_tail_x15_r0_body.cx0_10.mlx PRE_first_tail_x15_r0_body.kr0_10 PRE_first_tail_x15_r0_body.kr1_10 PRE_first_tail_x15_r0_body.clo10 = true
kernel_rfl PRE_first_tail_x15_r0_body.fkn10 : Nat.ble 506 506 = true
-- the bridge and the pending traces' regions
kernel_rfl PRE_first_tail_x15_r0_body.cbridge10 : Host.Ts.Sim.Full.bridgeOf PRE_first_tail_x15_r0_body.s111.ffi = Host.Ts.Sim.Full.bridgeOf PRE_first_tail_x15_r0_body.s112.ffi
kernel_rfl PRE_first_tail_x15_r0_body.cpendR10 : pendRegB PRE_first_tail_x15_r0_body.kappa10 (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s112.ffi).mlx = true
kernel_rfl PRE_first_tail_x15_r0_body.cpendLe10 : Nat.ble (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s112.ffi).mlx.next (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s111.ffi).mlx.next = true
/-- **The compaction's native shift**, given the call's bookkeeping, its relation's facts (the model's and the
observers') and the canonical closedness. -/
theorem PRE_first_tail_x15_r0_body.cshift10 (clean : Conv.NClean (⟨18410, 15492, 2683093, 506⟩ : Conv.Cnt) (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s110.ffi).mlx) (hltC : ∀ h, PH (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s110.ffi).mlx h → h < (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s110.ffi).mlx.next) (nltC : ∀ i, PN (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s110.ffi).mlx i → i < (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s110.ffi).mlx.nnext) (itemsC : ∀ k v, (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s110.ffi).mlx.items.get k = some v → PN (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s110.ffi).mlx k) (tracedC : ∀ h o, (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s110.ffi).mlx.objs.get h = some o → ∀ i ∈ objTraces o, i < PRE_first_tail_x15_r0_body.P10.NL) (cl : SSt (· < 506) PRE_first_tail_x15_r0_body.cx0_10.mlx)
    (hobjC : ∀ h, PRE_first_tail_x15_r0_body.fxC_10.get h = some () → ((Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s110.ffi).mlx.objs.get h).isSome = true)
    (hfC : ∀ h, (PRE_first_tail_x15_r0_body.krC_10.flags.get h).isSome = true → ((Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s110.ffi).mlx.objs.get h).isSome = true)
    (htC : ∀ h, (PRE_first_tail_x15_r0_body.krC_10.targs.get h).isSome = true → ((Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s110.ffi).mlx.objs.get h).isSome = true)
    (hclC : ∀ h l, PRE_first_tail_x15_r0_body.krC_10.targs.get h = some l → Host.Ts.Sim.Full.STargs (· < (⟨18410, 15492, 2683093, 506⟩ : Conv.Cnt).n) l) :
    Conv.FullShiftQ PRE_first_tail_x15_r0_body.P10 506 PRE_first_tail_x15_r0_body.kappa10 PRE_first_tail_x15_r0_body.s112.ffi PRE_first_tail_x15_r0_body.s111.ffi :=
  ⟨PRE_first_tail_x15_r0_body.cnshift10 clean hltC nltC itemsC tracedC cl, PRE_first_tail_x15_r0_body.cqueue10, fun t ht => bSN_sound (List.all_eq_true.mp PRE_first_tail_x15_r0_body.ctokSupp10 t ht),
    PRE_first_tail_x15_r0_body.cbridge10,
    liveShift_foot (x0' := Host.Ts.Sim.Full.mlxOf PRE_first_tail_x15_r0_body.s112.ffi) (x1' := Host.Ts.Sim.Full.mlxOf PRE_first_tail_x15_r0_body.s111.ffi) (PRE_first_tail_x15_r0_body.cfoot10 clean hltC nltC itemsC tracedC cl) rfl PRE_first_tail_x15_r0_body.ofx0_10 PRE_first_tail_x15_r0_body.ofx1_10 hobjC PRE_first_tail_x15_r0_body.ff010 PRE_first_tail_x15_r0_body.ff110 PRE_first_tail_x15_r0_body.ffck10,
    kernShift_foot (x0' := Host.Ts.Sim.Full.mlxOf PRE_first_tail_x15_r0_body.s112.ffi) (x1' := Host.Ts.Sim.Full.mlxOf PRE_first_tail_x15_r0_body.s111.ffi) (PRE_first_tail_x15_r0_body.cfoot10 clean hltC nltC itemsC tracedC cl) rfl PRE_first_tail_x15_r0_body.okr0_10 PRE_first_tail_x15_r0_body.okr1_10 (Nat.le_of_ble_eq_true PRE_first_tail_x15_r0_body.fkn10) hfC htC hclC
      PRE_first_tail_x15_r0_body.fkf010 PRE_first_tail_x15_r0_body.fkt010 PRE_first_tail_x15_r0_body.fkf110 PRE_first_tail_x15_r0_body.fkt110 PRE_first_tail_x15_r0_body.fkck10,
    pendReg_of rfl PRE_first_tail_x15_r0_body.cnh010 PRE_first_tail_x15_r0_body.cnh110 (Nat.le_of_ble_eq_true PRE_first_tail_x15_r0_body.cpendLe10) PRE_first_tail_x15_r0_body.cpendR10⟩

end Host.Load.Run.Tpl
