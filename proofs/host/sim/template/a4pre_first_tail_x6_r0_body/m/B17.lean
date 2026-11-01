import host.sim.template.a4pre_first_tail_x6_r0_body.m.B16
import host.sim.conv.CompactFull
import host.sim.template.FootGen
import host.sim.template.a4pre_first_tail_x6_r0_body.States
import host.sim.template.a4pre_first_tail_x6_r0_body.m.B00
import host.sim.conv.MergeSt
import host.sim.conv.Fresh
import host.sim.conv.CallPieces
import host.sim.stage.Mlx
import host.sim.template.NShiftOf
import host.sim.template.FullShiftGen
import host.sim.template.CallGen
import host.sim.template.EndGen
import host.sim.conv.CompactShift
import host.sim.template.Check
import host.sim.BigFreeP
import host.sim.template.BootEq
import host.sim.StageRel
import host.sim.compose.a4b.VWFramesDefs
import host.sim.template.FullOk
import host.sim.template.FastOk
import host.sim.Chunk
import host.sim.conv.Compact
import host.sim.native.RebigR
import host.sim.template.Sigma
import host.sim.template.NShiftGen
import host.sim.conv.Closed
import host.sim.conv.NClean

section -- SiteS10
set_option Elab.async false
namespace Host.Load.Run.Tpl
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
open Host.Ts Host.Ts.Sim Host.Ts.Sim.Template

/-! The compaction's native shift at call site 10 from its footprint (`Conv.nshift_of_foot`), and the observers'
(`liveShift_foot`, `kernShift_foot`): `Conv.FullShiftQ` for `Conv.full_compactQ`, given the call's bookkeeping and its
relation's facts. -/

/-- The load parameters of the chain (band-free: its start's node counter as `NL` and `N0`). -/
def PRE_first_tail_x6_r0_body.Pc10 : LoadP := ⟨18151, 131072, 1099511627776, 15235, 15235, []⟩
/-- The site's band raised to the map's checked fixed-node prefix, including newly recorded closure traces. -/
def PRE_first_tail_x6_r0_body.P10 : LoadP := PRE_first_tail_x6_r0_body.Pc10.raise 15492
kernel_rfl PRE_first_tail_x6_r0_body.craise10 : Nat.ble PRE_first_tail_x6_r0_body.Pc10.N0 15492 = true
theorem PRE_first_tail_x6_r0_body.raised10 : Host.Ts.Sim.Full.Raised PRE_first_tail_x6_r0_body.Pc10 PRE_first_tail_x6_r0_body.P10 :=
  .inr ⟨15492, rfl, Nat.le_of_ble_eq_true PRE_first_tail_x6_r0_body.craise10, rfl⟩
noncomputable abbrev PRE_first_tail_x6_r0_body.cx0_10 : Host.Load.LSt := clearTokens (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.s112.ffi)
noncomputable abbrev PRE_first_tail_x6_r0_body.cx1_10 : Host.Load.LSt := clearTokens (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.s111.ffi)
def PRE_first_tail_x6_r0_body.khinv10 : PTrie Nat := Stage.setAll PTrie.nil []
def PRE_first_tail_x6_r0_body.kninv10 : PTrie Nat := Stage.setAll PTrie.nil []
/-- The stage's footprint: its written and fresh handles, fresh nodes, written and fresh items. -/
def PRE_first_tail_x6_r0_body.cwS10 : List Nat := []
def PRE_first_tail_x6_r0_body.cnS10 : List Nat := List.range' 15492 0
def PRE_first_tail_x6_r0_body.ciS10 : List Nat := [] ++ List.range' 15492 0

-- the small checks (`MChecks`'s)
kernel_rfl PRE_first_tail_x6_r0_body.cnh010 : PRE_first_tail_x6_r0_body.kd10.nh0 = PRE_first_tail_x6_r0_body.cx0_10.mlx.next
kernel_rfl PRE_first_tail_x6_r0_body.cnh110 : PRE_first_tail_x6_r0_body.kd10.nh1 = PRE_first_tail_x6_r0_body.cx1_10.mlx.next
kernel_rfl PRE_first_tail_x6_r0_body.cnn010 : PRE_first_tail_x6_r0_body.kd10.nn0 = PRE_first_tail_x6_r0_body.cx0_10.mlx.nnext
kernel_rfl PRE_first_tail_x6_r0_body.cnn110 : PRE_first_tail_x6_r0_body.kd10.nn1 = PRE_first_tail_x6_r0_body.cx1_10.mlx.nnext
kernel_rfl PRE_first_tail_x6_r0_body.cplo10 : (Nat.blt 0 PRE_first_tail_x6_r0_body.P10.lo && Nat.ble PRE_first_tail_x6_r0_body.P10.lo PRE_first_tail_x6_r0_body.cx0_10.mlx.next && Nat.ble PRE_first_tail_x6_r0_body.P10.lo RData.bigHi && Nat.ble RData.bigHi PRE_first_tail_x6_r0_body.P10.E) = true
kernel_rfl PRE_first_tail_x6_r0_body.ccnt10 : (Nat.ble PRE_first_tail_x6_r0_body.cx0_10.mlx.next PRE_first_tail_x6_r0_body.cx1_10.mlx.next && Nat.ble PRE_first_tail_x6_r0_body.cx0_10.mlx.nnext PRE_first_tail_x6_r0_body.cx1_10.mlx.nnext) = true
kernel_rfl PRE_first_tail_x6_r0_body.cnband10 : (Nat.blt 0 PRE_first_tail_x6_r0_body.P10.NL && Nat.ble PRE_first_tail_x6_r0_body.P10.NL PRE_first_tail_x6_r0_body.P10.N0 && Nat.ble PRE_first_tail_x6_r0_body.P10.N0 PRE_first_tail_x6_r0_body.cx0_10.mlx.nnext) = true
kernel_rfl PRE_first_tail_x6_r0_body.chbelow10 : PRE_first_tail_x6_r0_body.kd10.checkHndBelow = true
kernel_rfl PRE_first_tail_x6_r0_body.chren10 : checkRenG PRE_first_tail_x6_r0_body.kd10.hnd PRE_first_tail_x6_r0_body.khinv10 (phB PRE_first_tail_x6_r0_body.cx0_10.mlx) = true
kernel_rfl PRE_first_tail_x6_r0_body.cband10 : PRE_first_tail_x6_r0_body.kd10.checkBand PRE_first_tail_x6_r0_body.P10.lo = true
kernel_rfl PRE_first_tail_x6_r0_body.cnh1pos10 : Nat.blt 0 PRE_first_tail_x6_r0_body.kd10.nh1 = true
kernel_rfl PRE_first_tail_x6_r0_body.cnren10 : checkRenG PRE_first_tail_x6_r0_body.kd10.node PRE_first_tail_x6_r0_body.kninv10 (pnB PRE_first_tail_x6_r0_body.cx0_10.mlx) = true
kernel_rfl PRE_first_tail_x6_r0_body.cnlow10 : (PTrie.keysA PRE_first_tail_x6_r0_body.kd10.node).all (fun j => Nat.ble PRE_first_tail_x6_r0_body.P10.NL j && Nat.blt (PRE_first_tail_x6_r0_body.kd10.nodeF j) PRE_first_tail_x6_r0_body.cx1_10.mlx.nnext) = true
kernel_rfl PRE_first_tail_x6_r0_body.cabs0a10 : PRE_first_tail_x6_r0_body.cx0_10.mlx.arrs.get 0 = none
kernel_rfl PRE_first_tail_x6_r0_body.cabs0b10 : PRE_first_tail_x6_r0_body.cx0_10.mlx.objs.get 0 = none
kernel_rfl PRE_first_tail_x6_r0_body.ctok110 : PRE_first_tail_x6_r0_body.cx1_10.mlx.tokens = []
kernel_rfl PRE_first_tail_x6_r0_body.cpend10 : PRE_first_tail_x6_r0_body.cx1_10.mlx.pending = PRE_first_tail_x6_r0_body.cx0_10.mlx.pending.map PRE_first_tail_x6_r0_body.kappa10.pend
kernel_rfl PRE_first_tail_x6_r0_body.cerrh10 : PRE_first_tail_x6_r0_body.cx1_10.mlx.errh = PRE_first_tail_x6_r0_body.cx0_10.mlx.errh.map PRE_first_tail_x6_r0_body.kappa10.arg
kernel_rfl PRE_first_tail_x6_r0_body.cfiles10 : PRE_first_tail_x6_r0_body.cx1_10.mlx.files = PRE_first_tail_x6_r0_body.cx0_10.mlx.files
kernel_rfl PRE_first_tail_x6_r0_body.carch10 : PRE_first_tail_x6_r0_body.cx1_10.mlx.arch = PRE_first_tail_x6_r0_body.cx0_10.mlx.arch
kernel_rfl PRE_first_tail_x6_r0_body.csizes10 : PRE_first_tail_x6_r0_body.cx1_10.mlx.deviceSizes = PRE_first_tail_x6_r0_body.cx0_10.mlx.deviceSizes
kernel_rfl PRE_first_tail_x6_r0_body.cwired10 : PRE_first_tail_x6_r0_body.cx1_10.mlx.wired = PRE_first_tail_x6_r0_body.cx0_10.mlx.wired
kernel_rfl PRE_first_tail_x6_r0_body.chost10 : PRE_first_tail_x6_r0_body.cx1_10.host = PRE_first_tail_x6_r0_body.cx0_10.host
-- the compaction map's addresses are `PRE_first_tail_x6_r0_body.kd10`'s
kernel_rfl PRE_first_tail_x6_r0_body.ckn010 : PRE_first_tail_x6_r0_body.kd10.n0 = 2683093
kernel_rfl PRE_first_tail_x6_r0_body.ckn110 : PRE_first_tail_x6_r0_body.kd10.n1 = 2683095
kernel_rfl PRE_first_tail_x6_r0_body.ckheap10 : (PTrie.keysA PRE_first_tail_x6_r0_body.kd10.heap).all (fun x => Nat.ble 2683093 x) = true
kernel_rfl PRE_first_tail_x6_r0_body.ckpl10 : (List.range 0).all (fun j => decide (PRE_first_tail_x6_r0_body.kd10.heap.get (2683093 + j) = nth? PRE_first_tail_x6_r0_body.pl10 j)) = true
-- the map fixes the call's names (`Conv.fixOld_compact`), the call's counters
kernel_rfl PRE_first_tail_x6_r0_body.fja10 : Nat.ble 2683093 2683093 = true
kernel_rfl PRE_first_tail_x6_r0_body.fn10 : Nat.ble 506 506 = true
kernel_rfl PRE_first_tail_x6_r0_body.fjaD10 : Nat.ble 2683093 PRE_first_tail_x6_r0_body.kd10.n0 = true
kernel_rfl PRE_first_tail_x6_r0_body.fxn10 : Nat.ble 18410 PRE_first_tail_x6_r0_body.kd10.nh0 = true
kernel_rfl PRE_first_tail_x6_r0_body.fnn10 : Nat.ble 15492 PRE_first_tail_x6_r0_body.kd10.nn0 = true
kernel_rfl PRE_first_tail_x6_r0_body.fxb10 : Nat.ble 18410 RData.bigHi = true
kernel_rfl PRE_first_tail_x6_r0_body.fheap10 : (PTrie.keysA PRE_first_tail_x6_r0_body.kd10.heap).all (Nat.ble (⟨18410, 15492, 2683093, 506⟩ : Conv.Cnt).ja) = true
kernel_rfl PRE_first_tail_x6_r0_body.fhnd10 : (PTrie.keysA PRE_first_tail_x6_r0_body.kd10.hnd).all (Nat.ble (⟨18410, 15492, 2683093, 506⟩ : Conv.Cnt).xn) = true
kernel_rfl PRE_first_tail_x6_r0_body.fnode10 : (PTrie.keysA PRE_first_tail_x6_r0_body.kd10.node).all (Nat.ble (⟨18410, 15492, 2683093, 506⟩ : Conv.Cnt).nn) = true
/-- The compaction map fixes the call's names. -/
theorem PRE_first_tail_x6_r0_body.cfix10 : Conv.FixOld (⟨18410, 15492, 2683093, 506⟩ : Conv.Cnt) PRE_first_tail_x6_r0_body.kappa10 :=
  Conv.fixOld_compact (Nat.le_of_ble_eq_true PRE_first_tail_x6_r0_body.fja10) (Nat.le_of_ble_eq_true PRE_first_tail_x6_r0_body.fn10) (Nat.le_of_ble_eq_true PRE_first_tail_x6_r0_body.fjaD10) (Nat.le_of_ble_eq_true PRE_first_tail_x6_r0_body.fxn10) (Nat.le_of_ble_eq_true PRE_first_tail_x6_r0_body.fnn10) (Nat.le_of_ble_eq_true PRE_first_tail_x6_r0_body.fxb10) PRE_first_tail_x6_r0_body.fheap10 PRE_first_tail_x6_r0_body.fhnd10 PRE_first_tail_x6_r0_body.fnode10
kernel_rfl PRE_first_tail_x6_r0_body.fcxn10 : (⟨18410, 15492, 2683093, 506⟩ : Conv.Cnt).xn = (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.s110.ffi).mlx.next
kernel_rfl PRE_first_tail_x6_r0_body.fcnn10 : (⟨18410, 15492, 2683093, 506⟩ : Conv.Cnt).nn = (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.s110.ffi).mlx.nnext
kernel_rfl PRE_first_tail_x6_r0_body.fle010 : (Nat.ble (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.s110.ffi).mlx.next PRE_first_tail_x6_r0_body.cx0_10.mlx.next && Nat.ble (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.s110.ffi).mlx.nnext PRE_first_tail_x6_r0_body.cx0_10.mlx.nnext && Nat.ble (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.s110.ffi).mlx.next RData.bigHi) = true
kernel_rfl PRE_first_tail_x6_r0_body.fnk10 : (PTrie.keysA PRE_first_tail_x6_r0_body.kd10.node).all (Nat.ble (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.s110.ffi).mlx.nnext) = true
-- the merged state keeps the call's entries off the stage's footprint
kernel_rfl PRE_first_tail_x6_r0_body.f1A10 : PRE_first_tail_x6_r0_body.cx1_10.mlx.arrs = Stage.setAll (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.s110.ffi).mlx.arrs (PRE_first_tail_x6_r0_body.cwS10.filterMap fun i => (PRE_first_tail_x6_r0_body.cx1_10.mlx.arrs.get i).map (i, ·))
kernel_rfl PRE_first_tail_x6_r0_body.f1O10 : PRE_first_tail_x6_r0_body.cx1_10.mlx.objs = Stage.setAll (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.s110.ffi).mlx.objs (PRE_first_tail_x6_r0_body.cwS10.filterMap fun i => (PRE_first_tail_x6_r0_body.cx1_10.mlx.objs.get i).map (i, ·))
kernel_rfl PRE_first_tail_x6_r0_body.f1N10 : PRE_first_tail_x6_r0_body.cx1_10.mlx.nodes = Stage.setAll (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.s110.ffi).mlx.nodes (PRE_first_tail_x6_r0_body.cnS10.filterMap fun i => (PRE_first_tail_x6_r0_body.cx1_10.mlx.nodes.get i).map (i, ·))
kernel_rfl PRE_first_tail_x6_r0_body.f1I10 : PRE_first_tail_x6_r0_body.cx1_10.mlx.items = Stage.setAll (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.s110.ffi).mlx.items (PRE_first_tail_x6_r0_body.ciS10.filterMap fun i => (PRE_first_tail_x6_r0_body.cx1_10.mlx.items.get i).map (i, ·))
kernel_rfl PRE_first_tail_x6_r0_body.fbd10 : (PRE_first_tail_x6_r0_body.clo10 ++ PRE_first_tail_x6_r0_body.cln10 ++ PRE_first_tail_x6_r0_body.cli10 ++ PRE_first_tail_x6_r0_body.cwS10 ++ PRE_first_tail_x6_r0_body.cnS10 ++ PRE_first_tail_x6_r0_body.ciS10).all (fun i => Nat.blt (i / 4096) (4 ^ 31)) = true
kernel_rfl PRE_first_tail_x6_r0_body.fincW10 : PRE_first_tail_x6_r0_body.cwS10.all (fun h => !Nat.blt h (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.s110.ffi).mlx.next || PRE_first_tail_x6_r0_body.clo10.contains h) = true
kernel_rfl PRE_first_tail_x6_r0_body.fincI10 : PRE_first_tail_x6_r0_body.ciS10.all (fun k => !Nat.blt k (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.s110.ffi).mlx.nnext || PRE_first_tail_x6_r0_body.cli10.contains k) = true
kernel_rfl PRE_first_tail_x6_r0_body.fincN10 : PRE_first_tail_x6_r0_body.cnS10.all (Nat.ble (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.s110.ffi).mlx.nnext) = true
kernel_rfl PRE_first_tail_x6_r0_body.flnF10 : PRE_first_tail_x6_r0_body.cln10.all (Nat.ble (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.s110.ffi).mlx.nnext) = true
-- the checks over the changed lists
kernel_rfl PRE_first_tail_x6_r0_body.fh10 : PRE_first_tail_x6_r0_body.clo10.all (handleOK PRE_first_tail_x6_r0_body.kappa10 PRE_first_tail_x6_r0_body.P10.lo PRE_first_tail_x6_r0_body.cx0_10.mlx PRE_first_tail_x6_r0_body.cx1_10.mlx) = true
kernel_rfl PRE_first_tail_x6_r0_body.fo10 : PRE_first_tail_x6_r0_body.clo10.map (fun h => PRE_first_tail_x6_r0_body.cx1_10.mlx.objs.get (PRE_first_tail_x6_r0_body.kappa10.handle h)) = PRE_first_tail_x6_r0_body.clo10.map (fun h => (PRE_first_tail_x6_r0_body.cx0_10.mlx.objs.get h).map PRE_first_tail_x6_r0_body.kappa10.nobj)
kernel_rfl PRE_first_tail_x6_r0_body.fok10 : PRE_first_tail_x6_r0_body.clo10.all (objOK PRE_first_tail_x6_r0_body.kappa10 PRE_first_tail_x6_r0_body.P10.NL PRE_first_tail_x6_r0_body.cx0_10.mlx) = true
kernel_rfl PRE_first_tail_x6_r0_body.fnd10 : PRE_first_tail_x6_r0_body.cln10.all (nodeOKF PRE_first_tail_x6_r0_body.kappa10 PRE_first_tail_x6_r0_body.P10 PRE_first_tail_x6_r0_body.cx0_10.mlx PRE_first_tail_x6_r0_body.cx1_10.mlx) = true
kernel_rfl PRE_first_tail_x6_r0_body.fp10 : ((PRE_first_tail_x6_r0_body.cln10.filter (fullB PRE_first_tail_x6_r0_body.P10))).map (fun i => (PRE_first_tail_x6_r0_body.cx1_10.mlx.nodes.get (PRE_first_tail_x6_r0_body.kappa10.node i)).map Host.Mlx.Ffi.Node.prim) =
  ((PRE_first_tail_x6_r0_body.cln10.filter (fullB PRE_first_tail_x6_r0_body.P10))).map (fun i => (PRE_first_tail_x6_r0_body.cx0_10.mlx.nodes.get i).map fun nd => PRE_first_tail_x6_r0_body.kappa10.prim nd.prim)
kernel_rfl PRE_first_tail_x6_r0_body.fnordI10 : incrB PRE_first_tail_x6_r0_body.kd10.nodeF (List.range' 15492 0) = true
kernel_rfl PRE_first_tail_x6_r0_body.fnordK10 : (PTrie.keysA PRE_first_tail_x6_r0_body.kd10.node).all (fun k => Nat.ble 15492 k && Nat.blt k 15492) = true
kernel_rfl PRE_first_tail_x6_r0_body.fnordL10 : (PRE_first_tail_x6_r0_body.cln10.filter (Nat.ble PRE_first_tail_x6_r0_body.P10.N0)).all (fun i => Nat.ble i (PRE_first_tail_x6_r0_body.kd10.nodeF i) && (Nat.blt i 15492 || Nat.ble PRE_first_tail_x6_r0_body.kd10.nn0 i)) = true
theorem PRE_first_tail_x6_r0_body.fnord10 : (PRE_first_tail_x6_r0_body.cln10.filter (Nat.ble PRE_first_tail_x6_r0_body.P10.N0)).all (fun i => Nat.ble i (PRE_first_tail_x6_r0_body.kd10.nodeF i) &&
    (PTrie.keysA PRE_first_tail_x6_r0_body.kd10.node).all fun j => !Nat.blt j i || Nat.blt (PRE_first_tail_x6_r0_body.kd10.nodeF j) (PRE_first_tail_x6_r0_body.kd10.nodeF i)) = true :=
  cnord_of PRE_first_tail_x6_r0_body.cnlow10 PRE_first_tail_x6_r0_body.cnn110 PRE_first_tail_x6_r0_body.fnordI10 PRE_first_tail_x6_r0_body.fnordK10 PRE_first_tail_x6_r0_body.fnordL10
kernel_rfl PRE_first_tail_x6_r0_body.fi10 : PRE_first_tail_x6_r0_body.cli10.all (pnB PRE_first_tail_x6_r0_body.cx0_10.mlx) = true
kernel_rfl PRE_first_tail_x6_r0_body.fii10 : PRE_first_tail_x6_r0_body.cli10.all (fun k => decide (PRE_first_tail_x6_r0_body.cx1_10.mlx.items.get (PRE_first_tail_x6_r0_body.kappa10.node k) = (PRE_first_tail_x6_r0_body.cx0_10.mlx.items.get k).map PRE_first_tail_x6_r0_body.kappa10.nv)) = true
/-- **The compaction's footprint.** -/
theorem PRE_first_tail_x6_r0_body.cfoot10 (clean : Conv.NClean (⟨18410, 15492, 2683093, 506⟩ : Conv.Cnt) (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.s110.ffi).mlx) (hltC : ∀ h, PH (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.s110.ffi).mlx h → h < (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.s110.ffi).mlx.next) (nltC : ∀ i, PN (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.s110.ffi).mlx i → i < (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.s110.ffi).mlx.nnext) (itemsC : ∀ k v, (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.s110.ffi).mlx.items.get k = some v → PN (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.s110.ffi).mlx k) (tracedC : ∀ h o, (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.s110.ffi).mlx.objs.get h = some o → ∀ i ∈ objTraces o, i < PRE_first_tail_x6_r0_body.P10.NL) (cl : SSt (· < 506) PRE_first_tail_x6_r0_body.cx0_10.mlx) :
    Conv.MFoot PRE_first_tail_x6_r0_body.P10 506 PRE_first_tail_x6_r0_body.kappa10 PRE_first_tail_x6_r0_body.kd10 PRE_first_tail_x6_r0_body.khinv10 PRE_first_tail_x6_r0_body.kninv10 (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.s110.ffi).mlx PRE_first_tail_x6_r0_body.cx0_10.mlx PRE_first_tail_x6_r0_body.cx1_10.mlx (⟨18410, 15492, 2683093, 506⟩ : Conv.Cnt) PRE_first_tail_x6_r0_body.clo10 PRE_first_tail_x6_r0_body.cln10 PRE_first_tail_x6_r0_body.cli10 PRE_first_tail_x6_r0_body.cwS10 PRE_first_tail_x6_r0_body.cnS10 PRE_first_tail_x6_r0_body.ciS10 :=
  ⟨rfl, rfl, rfl, PRE_first_tail_x6_r0_body.cnh010, PRE_first_tail_x6_r0_body.cnh110, PRE_first_tail_x6_r0_body.cnn010, PRE_first_tail_x6_r0_body.cnn110, PRE_first_tail_x6_r0_body.cplo10, PRE_first_tail_x6_r0_body.ccnt10, PRE_first_tail_x6_r0_body.cnband10, PRE_first_tail_x6_r0_body.chbelow10, PRE_first_tail_x6_r0_body.chren10, PRE_first_tail_x6_r0_body.cband10, PRE_first_tail_x6_r0_body.cnh1pos10, PRE_first_tail_x6_r0_body.cnren10, PRE_first_tail_x6_r0_body.cnlow10, PRE_first_tail_x6_r0_body.cabs0a10, PRE_first_tail_x6_r0_body.cabs0b10, PRE_first_tail_x6_r0_body.ctok110, PRE_first_tail_x6_r0_body.cpend10, PRE_first_tail_x6_r0_body.cerrh10, PRE_first_tail_x6_r0_body.cfiles10, PRE_first_tail_x6_r0_body.carch10, PRE_first_tail_x6_r0_body.csizes10, PRE_first_tail_x6_r0_body.cwired10, PRE_first_tail_x6_r0_body.cfix10, clean, PRE_first_tail_x6_r0_body.fcxn10, PRE_first_tail_x6_r0_body.fcnn10, hltC, nltC, itemsC, tracedC, cl, PRE_first_tail_x6_r0_body.fle010, PRE_first_tail_x6_r0_body.fnk10, PRE_first_tail_x6_r0_body.ckA10, PRE_first_tail_x6_r0_body.cobjsK10, PRE_first_tail_x6_r0_body.cnodesK10, PRE_first_tail_x6_r0_body.citemsK10, PRE_first_tail_x6_r0_body.f1A10, PRE_first_tail_x6_r0_body.f1O10, PRE_first_tail_x6_r0_body.f1N10, PRE_first_tail_x6_r0_body.f1I10, PRE_first_tail_x6_r0_body.fbd10, PRE_first_tail_x6_r0_body.fincW10, PRE_first_tail_x6_r0_body.fincI10, PRE_first_tail_x6_r0_body.fincN10, PRE_first_tail_x6_r0_body.flnF10, PRE_first_tail_x6_r0_body.fh10, PRE_first_tail_x6_r0_body.fo10, PRE_first_tail_x6_r0_body.fok10, PRE_first_tail_x6_r0_body.fnd10, PRE_first_tail_x6_r0_body.fp10, PRE_first_tail_x6_r0_body.fnord10, PRE_first_tail_x6_r0_body.fi10, PRE_first_tail_x6_r0_body.fii10⟩
theorem PRE_first_tail_x6_r0_body.cnshift10 (clean : Conv.NClean (⟨18410, 15492, 2683093, 506⟩ : Conv.Cnt) (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.s110.ffi).mlx) (hltC : ∀ h, PH (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.s110.ffi).mlx h → h < (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.s110.ffi).mlx.next) (nltC : ∀ i, PN (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.s110.ffi).mlx i → i < (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.s110.ffi).mlx.nnext) (itemsC : ∀ k v, (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.s110.ffi).mlx.items.get k = some v → PN (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.s110.ffi).mlx k) (tracedC : ∀ h o, (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.s110.ffi).mlx.objs.get h = some o → ∀ i ∈ objTraces o, i < PRE_first_tail_x6_r0_body.P10.NL) (cl : SSt (· < 506) PRE_first_tail_x6_r0_body.cx0_10.mlx) : NShift PRE_first_tail_x6_r0_body.P10 506 PRE_first_tail_x6_r0_body.kappa10 PRE_first_tail_x6_r0_body.cx0_10 PRE_first_tail_x6_r0_body.cx1_10 :=
  Conv.nshift_of_foot (PRE_first_tail_x6_r0_body.cfoot10 clean hltC nltC itemsC tracedC cl) PRE_first_tail_x6_r0_body.chost10 (compact_a_eq PRE_first_tail_x6_r0_body.ckn010 PRE_first_tail_x6_r0_body.ckn110 PRE_first_tail_x6_r0_body.ckheap10 PRE_first_tail_x6_r0_body.ckpl10)

-- the observers: the layers' states at the call, the canonical and the merged state, their footprints and checks
noncomputable def PRE_first_tail_x6_r0_body.fxC_10 : PTrie Unit := (Host.Ts.Sim.Full.freedOf PRE_first_tail_x6_r0_body.s110.ffi).getD PTrie.nil
noncomputable def PRE_first_tail_x6_r0_body.krC_10 : Host.Load.Layers.KRec := (Host.Ts.Sim.Full.krecOf PRE_first_tail_x6_r0_body.s110.ffi).getD Host.Load.Layers.KRec.empty
kernel_rfl PRE_first_tail_x6_r0_body.ofxC_10 : (Host.Ts.Sim.Full.freedOf PRE_first_tail_x6_r0_body.s110.ffi) = some PRE_first_tail_x6_r0_body.fxC_10
kernel_rfl PRE_first_tail_x6_r0_body.okrC_10 : (Host.Ts.Sim.Full.krecOf PRE_first_tail_x6_r0_body.s110.ffi) = some PRE_first_tail_x6_r0_body.krC_10
noncomputable def PRE_first_tail_x6_r0_body.fx0_10 : PTrie Unit := (Host.Ts.Sim.Full.freedOf PRE_first_tail_x6_r0_body.s112.ffi).getD PTrie.nil
noncomputable def PRE_first_tail_x6_r0_body.kr0_10 : Host.Load.Layers.KRec := (Host.Ts.Sim.Full.krecOf PRE_first_tail_x6_r0_body.s112.ffi).getD Host.Load.Layers.KRec.empty
kernel_rfl PRE_first_tail_x6_r0_body.ofx0_10 : (Host.Ts.Sim.Full.freedOf PRE_first_tail_x6_r0_body.s112.ffi) = some PRE_first_tail_x6_r0_body.fx0_10
kernel_rfl PRE_first_tail_x6_r0_body.okr0_10 : (Host.Ts.Sim.Full.krecOf PRE_first_tail_x6_r0_body.s112.ffi) = some PRE_first_tail_x6_r0_body.kr0_10
noncomputable def PRE_first_tail_x6_r0_body.fx1_10 : PTrie Unit := (Host.Ts.Sim.Full.freedOf PRE_first_tail_x6_r0_body.s111.ffi).getD PTrie.nil
noncomputable def PRE_first_tail_x6_r0_body.kr1_10 : Host.Load.Layers.KRec := (Host.Ts.Sim.Full.krecOf PRE_first_tail_x6_r0_body.s111.ffi).getD Host.Load.Layers.KRec.empty
kernel_rfl PRE_first_tail_x6_r0_body.ofx1_10 : (Host.Ts.Sim.Full.freedOf PRE_first_tail_x6_r0_body.s111.ffi) = some PRE_first_tail_x6_r0_body.fx1_10
kernel_rfl PRE_first_tail_x6_r0_body.okr1_10 : (Host.Ts.Sim.Full.krecOf PRE_first_tail_x6_r0_body.s111.ffi) = some PRE_first_tail_x6_r0_body.kr1_10
kernel_rfl PRE_first_tail_x6_r0_body.ff010 : PRE_first_tail_x6_r0_body.fx0_10 = Stage.setAll PRE_first_tail_x6_r0_body.fxC_10 (PRE_first_tail_x6_r0_body.clo10.filterMap fun i => (PRE_first_tail_x6_r0_body.fx0_10.get i).map (i, ·))
kernel_rfl PRE_first_tail_x6_r0_body.ff110 : PRE_first_tail_x6_r0_body.fx1_10 = Stage.setAll PRE_first_tail_x6_r0_body.fxC_10 (PRE_first_tail_x6_r0_body.cwS10.filterMap fun i => (PRE_first_tail_x6_r0_body.fx1_10.get i).map (i, ·))
kernel_rfl PRE_first_tail_x6_r0_body.ffck10 : freedLB PRE_first_tail_x6_r0_body.kappa10 PRE_first_tail_x6_r0_body.cx0_10.mlx PRE_first_tail_x6_r0_body.fx0_10 PRE_first_tail_x6_r0_body.fx1_10 PRE_first_tail_x6_r0_body.clo10 = true
kernel_rfl PRE_first_tail_x6_r0_body.fkf010 : PRE_first_tail_x6_r0_body.kr0_10.flags = Stage.setAll PRE_first_tail_x6_r0_body.krC_10.flags (PRE_first_tail_x6_r0_body.clo10.filterMap fun i => (PRE_first_tail_x6_r0_body.kr0_10.flags.get i).map (i, ·))
kernel_rfl PRE_first_tail_x6_r0_body.fkt010 : PRE_first_tail_x6_r0_body.kr0_10.targs = Stage.setAll PRE_first_tail_x6_r0_body.krC_10.targs (PRE_first_tail_x6_r0_body.clo10.filterMap fun i => (PRE_first_tail_x6_r0_body.kr0_10.targs.get i).map (i, ·))
kernel_rfl PRE_first_tail_x6_r0_body.fkf110 : PRE_first_tail_x6_r0_body.kr1_10.flags = Stage.setAll PRE_first_tail_x6_r0_body.krC_10.flags (PRE_first_tail_x6_r0_body.cwS10.filterMap fun i => (PRE_first_tail_x6_r0_body.kr1_10.flags.get i).map (i, ·))
kernel_rfl PRE_first_tail_x6_r0_body.fkt110 : PRE_first_tail_x6_r0_body.kr1_10.targs = Stage.setAll PRE_first_tail_x6_r0_body.krC_10.targs (PRE_first_tail_x6_r0_body.cwS10.filterMap fun i => (PRE_first_tail_x6_r0_body.kr1_10.targs.get i).map (i, ·))
kernel_rfl PRE_first_tail_x6_r0_body.fkck10 : krecLB PRE_first_tail_x6_r0_body.kappa10 506 PRE_first_tail_x6_r0_body.cx0_10.mlx PRE_first_tail_x6_r0_body.kr0_10 PRE_first_tail_x6_r0_body.kr1_10 PRE_first_tail_x6_r0_body.clo10 = true
kernel_rfl PRE_first_tail_x6_r0_body.fkn10 : Nat.ble 506 506 = true
-- the bridge and the pending traces' regions
kernel_rfl PRE_first_tail_x6_r0_body.cbridge10 : Host.Ts.Sim.Full.bridgeOf PRE_first_tail_x6_r0_body.s111.ffi = Host.Ts.Sim.Full.bridgeOf PRE_first_tail_x6_r0_body.s112.ffi
kernel_rfl PRE_first_tail_x6_r0_body.cpendR10 : pendRegB PRE_first_tail_x6_r0_body.kappa10 (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.s112.ffi).mlx = true
kernel_rfl PRE_first_tail_x6_r0_body.cpendLe10 : Nat.ble (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.s112.ffi).mlx.next (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.s111.ffi).mlx.next = true
/-- **The compaction's native shift**, given the call's bookkeeping, its relation's facts (the model's and the
observers') and the canonical closedness. -/
theorem PRE_first_tail_x6_r0_body.cshift10 (clean : Conv.NClean (⟨18410, 15492, 2683093, 506⟩ : Conv.Cnt) (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.s110.ffi).mlx) (hltC : ∀ h, PH (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.s110.ffi).mlx h → h < (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.s110.ffi).mlx.next) (nltC : ∀ i, PN (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.s110.ffi).mlx i → i < (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.s110.ffi).mlx.nnext) (itemsC : ∀ k v, (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.s110.ffi).mlx.items.get k = some v → PN (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.s110.ffi).mlx k) (tracedC : ∀ h o, (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.s110.ffi).mlx.objs.get h = some o → ∀ i ∈ objTraces o, i < PRE_first_tail_x6_r0_body.P10.NL) (cl : SSt (· < 506) PRE_first_tail_x6_r0_body.cx0_10.mlx)
    (hobjC : ∀ h, PRE_first_tail_x6_r0_body.fxC_10.get h = some () → ((Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.s110.ffi).mlx.objs.get h).isSome = true)
    (hfC : ∀ h, (PRE_first_tail_x6_r0_body.krC_10.flags.get h).isSome = true → ((Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.s110.ffi).mlx.objs.get h).isSome = true)
    (htC : ∀ h, (PRE_first_tail_x6_r0_body.krC_10.targs.get h).isSome = true → ((Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.s110.ffi).mlx.objs.get h).isSome = true)
    (hclC : ∀ h l, PRE_first_tail_x6_r0_body.krC_10.targs.get h = some l → Host.Ts.Sim.Full.STargs (· < (⟨18410, 15492, 2683093, 506⟩ : Conv.Cnt).n) l) :
    Conv.FullShiftQ PRE_first_tail_x6_r0_body.P10 506 PRE_first_tail_x6_r0_body.kappa10 PRE_first_tail_x6_r0_body.s112.ffi PRE_first_tail_x6_r0_body.s111.ffi :=
  ⟨PRE_first_tail_x6_r0_body.cnshift10 clean hltC nltC itemsC tracedC cl, PRE_first_tail_x6_r0_body.cqueue10, fun t ht => bSN_sound (List.all_eq_true.mp PRE_first_tail_x6_r0_body.ctokSupp10 t ht),
    PRE_first_tail_x6_r0_body.cbridge10,
    liveShift_foot (x0' := Host.Ts.Sim.Full.mlxOf PRE_first_tail_x6_r0_body.s112.ffi) (x1' := Host.Ts.Sim.Full.mlxOf PRE_first_tail_x6_r0_body.s111.ffi) (PRE_first_tail_x6_r0_body.cfoot10 clean hltC nltC itemsC tracedC cl) rfl PRE_first_tail_x6_r0_body.ofx0_10 PRE_first_tail_x6_r0_body.ofx1_10 hobjC PRE_first_tail_x6_r0_body.ff010 PRE_first_tail_x6_r0_body.ff110 PRE_first_tail_x6_r0_body.ffck10,
    kernShift_foot (x0' := Host.Ts.Sim.Full.mlxOf PRE_first_tail_x6_r0_body.s112.ffi) (x1' := Host.Ts.Sim.Full.mlxOf PRE_first_tail_x6_r0_body.s111.ffi) (PRE_first_tail_x6_r0_body.cfoot10 clean hltC nltC itemsC tracedC cl) rfl PRE_first_tail_x6_r0_body.okr0_10 PRE_first_tail_x6_r0_body.okr1_10 (Nat.le_of_ble_eq_true PRE_first_tail_x6_r0_body.fkn10) hfC htC hclC
      PRE_first_tail_x6_r0_body.fkf010 PRE_first_tail_x6_r0_body.fkt010 PRE_first_tail_x6_r0_body.fkf110 PRE_first_tail_x6_r0_body.fkt110 PRE_first_tail_x6_r0_body.fkck10,
    pendReg_of rfl PRE_first_tail_x6_r0_body.cnh010 PRE_first_tail_x6_r0_body.cnh110 (Nat.le_of_ble_eq_true PRE_first_tail_x6_r0_body.cpendLe10) PRE_first_tail_x6_r0_body.cpendR10⟩

end Host.Load.Run.Tpl
end

section -- st10/H0
set_option Elab.async false
namespace Host.Load.Run.Tpl
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
host_stream_state PRE_first_tail_x6_r0_body.st10 0
host_stream_state PRE_first_tail_x6_r0_body.st10 1
host_stream_state PRE_first_tail_x6_r0_body.st10 2
end Host.Load.Run.Tpl
end

section -- Site10
set_option Elab.async false
namespace Host.Load.Run.Tpl
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
open Host.Ts Host.Ts.Sim Host.Ts.Sim.Template

/-! Call site 10 of chain `PRE_first_tail_x6_r0_body`: `rowBlocks__g10__g11` (`rowBlocks`), the call state `PRE_first_tail_x6_r0_body.s110`, the merged state `PRE_first_tail_x6_r0_body.s111`,
the site template `PRE_first_tail_x6_r0_body.st10` (σ = `Map.id`, θ the identity at its own site), the canonical state `PRE_first_tail_x6_r0_body.s112`: the merge.
The footprint's facts are in `SiteF10`, the compaction's in `SiteC10`, `SiteK10`, `SiteNa10`, `SiteNb10`. -/

kernel_rfl PRE_first_tail_x6_r0_body.iso10 : PRE_first_tail_x6_r0_body.st10.s0 = { PRE_first_tail_x6_r0_body.s110 with stack := [] }
/-- The caller's frames at the call. -/
noncomputable def PRE_first_tail_x6_r0_body.rs10 : List Frame := PRE_first_tail_x6_r0_body.s110.stack
kernel_rfl PRE_first_tail_x6_r0_body.n0_10 : PRE_first_tail_x6_r0_body.S110.tab.length = 506
kernel_rfl PRE_first_tail_x6_r0_body.tab0_10 : PRE_first_tail_x6_r0_body.st10.S0.tab = PRE_first_tail_x6_r0_body.S110.tab

/-- The fresh variables of the stage's results. -/
def PRE_first_tail_x6_r0_body.ws10 : List Nat := [1194, 1195]
kernel_rfl PRE_first_tail_x6_r0_body.fresh10 : (PRE_first_tail_x6_r0_body.S110.tab.all fun e => PRE_first_tail_x6_r0_body.ws10.all fun v => e.noVar v) &&
    (PRE_first_tail_x6_r0_body.S110.oracle.all fun q => PRE_first_tail_x6_r0_body.ws10.all fun v => q.noVar v) = true
kernel_rfl PRE_first_tail_x6_r0_body.mergeTab10 : PRE_first_tail_x6_r0_body.S111.tab = PRE_first_tail_x6_r0_body.S110.tab ++ Conv.resTab PRE_first_tail_x6_r0_body.ws10
kernel_rfl PRE_first_tail_x6_r0_body.mergeLen10 : PRE_first_tail_x6_r0_body.st10.S2.tab.length - PRE_first_tail_x6_r0_body.st10.S0.tab.length = 2

-- The merged state: the instance's return state with the caller's frames (`PRE_first_tail_x6_r0_body.merged10`, `merged_relB`).
kernel_rfl PRE_first_tail_x6_r0_body.mheap10 : PRE_first_tail_x6_r0_body.s111.heap = PRE_first_tail_x6_r0_body.st10.s2.heap
kernel_rfl PRE_first_tail_x6_r0_body.mnext10 : PRE_first_tail_x6_r0_body.s111.next = PRE_first_tail_x6_r0_body.st10.s2.next
kernel_rfl PRE_first_tail_x6_r0_body.mctl10 : PRE_first_tail_x6_r0_body.s111.ctl = PRE_first_tail_x6_r0_body.st10.s2.ctl
kernel_rfl PRE_first_tail_x6_r0_body.mstack10 : PRE_first_tail_x6_r0_body.s111.stack = PRE_first_tail_x6_r0_body.st10.s2.stack ++ PRE_first_tail_x6_r0_body.s110.stack
kernel_rfl PRE_first_tail_x6_r0_body.mjobs10 : PRE_first_tail_x6_r0_body.s111.jobs = PRE_first_tail_x6_r0_body.st10.s2.jobs
kernel_rfl PRE_first_tail_x6_r0_body.mffi10 : PRE_first_tail_x6_r0_body.s111.ffi = PRE_first_tail_x6_r0_body.st10.s2.ffi
kernel_rfl PRE_first_tail_x6_r0_body.mtrace10 : PRE_first_tail_x6_r0_body.s111.trace = PRE_first_tail_x6_r0_body.st10.s2.trace
kernel_rfl PRE_first_tail_x6_r0_body.mstores10 : PRE_first_tail_x6_r0_body.s111.stores = PRE_first_tail_x6_r0_body.st10.s2.stores

end Host.Load.Run.Tpl
end

section -- SiteD10
set_option Elab.async false
namespace Host.Load.Run.Tpl
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
open Host.Ts Host.Ts.Sim Host.Ts.Sim.Template

/-! The canonical results at call site 10 of chain `PRE_first_tail_x6_r0_body`: their values in the instance's end table, the references past
the call's table, the canonical variables apart from the stage's. -/

kernel_rfl PRE_first_tail_x6_r0_body.cderived10 : PRE_first_tail_x6_r0_body.nr10.map (fun r => nth? PRE_first_tail_x6_r0_body.st10.S2.tab r) =
  []
kernel_rfl PRE_first_tail_x6_r0_body.cnrLo10 : PRE_first_tail_x6_r0_body.nr10.all (Nat.ble 506) = true
kernel_rfl PRE_first_tail_x6_r0_body.cwsDisj10 : PRE_first_tail_x6_r0_body.cws10.all (fun c => !PRE_first_tail_x6_r0_body.ws10.contains c) = true
/-- The compaction's substitution: the canonical variables to their merged values, the stage's other fresh variables
to `0` (`Conv.compactθZ`). -/
noncomputable def PRE_first_tail_x6_r0_body.cthetaZ10 : Nat → SymE := Conv.compactθZ PRE_first_tail_x6_r0_body.cws10 PRE_first_tail_x6_r0_body.crs10 PRE_first_tail_x6_r0_body.ws10

end Host.Load.Run.Tpl
end

section -- st10/Foot
set_option Elab.async false
namespace Host.Load.Run.Tpl
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
open Host.Ts Host.Ts.Sim Host.Ts.Sim.Stage Host.Ts.Sim.Template

/-! The footprint of stage `PRE_first_tail_x6_r0_body.st10`'s site template (`Conv.StageFoot`, `Conv.NFoot`): every entry of the return
state other than the written and fresh ones is the start's (kernel evaluation of the equalities). -/

/-- The written heap ranges below the start's counter. -/
def PRE_first_tail_x6_r0_body.st10.wrR : List (Nat × Nat) := []
/-- The written and fresh entries of the return state. -/
noncomputable def PRE_first_tail_x6_r0_body.st10.wrE : List (Nat × Host.Ts.HObj) :=
  rangesOf PRE_first_tail_x6_r0_body.st10.s2.heap PRE_first_tail_x6_r0_body.st10.wrR ++ freshOf PRE_first_tail_x6_r0_body.st10.s2.heap PRE_first_tail_x6_r0_body.st10.s0.next PRE_first_tail_x6_r0_body.st10.s2.next
noncomputable def PRE_first_tail_x6_r0_body.st10.wr : List Nat := PRE_first_tail_x6_r0_body.st10.wrE.map (·.1)

kernel_rfl PRE_first_tail_x6_r0_body.st10.heapFoot : PRE_first_tail_x6_r0_body.st10.s2.heap = setAll PRE_first_tail_x6_r0_body.st10.s0.heap PRE_first_tail_x6_r0_body.st10.wrE
kernel_rfl PRE_first_tail_x6_r0_body.st10.grows_check : Nat.ble PRE_first_tail_x6_r0_body.st10.s0.next PRE_first_tail_x6_r0_body.st10.s2.next = true
theorem PRE_first_tail_x6_r0_body.st10.grows : PRE_first_tail_x6_r0_body.st10.s0.next ≤ PRE_first_tail_x6_r0_body.st10.s2.next := Nat.le_of_ble_eq_true PRE_first_tail_x6_r0_body.st10.grows_check

/-- The written and fresh handles; the written readback items of old nodes. -/
def PRE_first_tail_x6_r0_body.st10.wh : List Nat := []
def PRE_first_tail_x6_r0_body.st10.wi : List Nat := []

kernel_rfl PRE_first_tail_x6_r0_body.st10.arrsFoot : (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.st10.s2.ffi).mlx.arrs = setAll (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.st10.s0.ffi).mlx.arrs (PRE_first_tail_x6_r0_body.st10.wh.filterMap fun h => ((Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.st10.s2.ffi).mlx.arrs.get h).map (h, ·))
kernel_rfl PRE_first_tail_x6_r0_body.st10.objsFoot : (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.st10.s2.ffi).mlx.objs = setAll (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.st10.s0.ffi).mlx.objs (PRE_first_tail_x6_r0_body.st10.wh.filterMap fun h => ((Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.st10.s2.ffi).mlx.objs.get h).map (h, ·))
kernel_rfl PRE_first_tail_x6_r0_body.st10.nodesFoot : (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.st10.s2.ffi).mlx.nodes = setAll (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.st10.s0.ffi).mlx.nodes (freshOf (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.st10.s2.ffi).mlx.nodes (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.st10.s0.ffi).mlx.nnext (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.st10.s2.ffi).mlx.nnext)
kernel_rfl PRE_first_tail_x6_r0_body.st10.itemsFoot : (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.st10.s2.ffi).mlx.items = setAll (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.st10.s0.ffi).mlx.items ((PRE_first_tail_x6_r0_body.st10.wi.filterMap fun i => ((Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.st10.s2.ffi).mlx.items.get i).map (i, ·)) ++
    freshOf (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.st10.s2.ffi).mlx.items (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.st10.s0.ffi).mlx.nnext (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.st10.s2.ffi).mlx.nnext)
kernel_rfl PRE_first_tail_x6_r0_body.st10.counters : (Nat.ble (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.st10.s0.ffi).mlx.next (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.st10.s2.ffi).mlx.next && Nat.ble (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.st10.s0.ffi).mlx.nnext (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.st10.s2.ffi).mlx.nnext) = true

end Host.Load.Run.Tpl
end

section -- SiteF10
set_option Elab.async false
namespace Host.Load.Run.Tpl
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
open Host.Ts Host.Ts.Sim Host.Ts.Sim.Template

/-! Call site 10 of chain `PRE_first_tail_x6_r0_body`: `Conv.site_merge`'s footprint facts. -/

kernel_rfl PRE_first_tail_x6_r0_body.wrNodupB10 : nodupT PRE_first_tail_x6_r0_body.st10.wr PTrie.nil = true
theorem PRE_first_tail_x6_r0_body.wrNodup10 : PRE_first_tail_x6_r0_body.st10.wr.Nodup := (nodupT_sound PRE_first_tail_x6_r0_body.wrNodupB10).2
kernel_rfl PRE_first_tail_x6_r0_body.wrBoundB10 : PRE_first_tail_x6_r0_body.st10.wr.all (fun b => Nat.blt (b / 4096) (4 ^ 31)) = true
theorem PRE_first_tail_x6_r0_body.wrBound10 : ∀ b ∈ PRE_first_tail_x6_r0_body.st10.wr, b / 4096 < 4 ^ 31 := fun b hb => Nat.blt_eq.mp (List.all_eq_true.mp PRE_first_tail_x6_r0_body.wrBoundB10 b hb)
noncomputable def PRE_first_tail_x6_r0_body.trFr10 := PRE_first_tail_x6_r0_body.st10.s2.trace.take 0
kernel_rfl PRE_first_tail_x6_r0_body.traceEq10 : PRE_first_tail_x6_r0_body.st10.s2.trace = PRE_first_tail_x6_r0_body.trFr10 ++ PRE_first_tail_x6_r0_body.st10.s0.trace
theorem PRE_first_tail_x6_r0_body.trace10 : ∃ fr, PRE_first_tail_x6_r0_body.st10.s2.trace = fr ++ PRE_first_tail_x6_r0_body.st10.s0.trace := ⟨_, PRE_first_tail_x6_r0_body.traceEq10⟩

-- the caller's wide frames at the instance's start (`Conv.isolateW`'s `W0` under `Map.id`) and their `WFix`
def PRE_first_tail_x6_r0_body.wide10 : List (Nat × WFrame) := [(4910, .memo [])]
kernel_rfl PRE_first_tail_x6_r0_body.wfixB10 : (PRE_first_tail_x6_r0_body.wide10.all fun p => wfixB Map.id (presentB PRE_first_tail_x6_r0_body.st10.s0) p.2) = true
theorem PRE_first_tail_x6_r0_body.wfix10 : ∀ p ∈ PRE_first_tail_x6_r0_body.wide10, WFix Map.id (Present PRE_first_tail_x6_r0_body.st10.s0) p.2 :=
  fun p hp => wfix_of (List.all_eq_true.mp PRE_first_tail_x6_r0_body.wfixB10 p hp)

end Host.Load.Run.Tpl
end

section -- SiteL10
set_option Elab.async false
namespace Host.Load.Run.Tpl
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
open Host.Ts Host.Ts.Sim Host.Ts.Sim.Template

/-! The call link's facts at call site 10 of chain `PRE_first_tail_x6_r0_body`: the instance's start server, its footprint (`Conv.StageFoot`), the
merged state `PRE_first_tail_x6_r0_body.s111`'s framed arrays as the chain start's extended (`arrExt_of`, `numRefs_of`). -/

kernel_rfl PRE_first_tail_x6_r0_body.srvO10 : PRE_first_tail_x6_r0_body.st10.S0.oracle = PRE_first_tail_x6_r0_body.st10.OR
kernel_rfl PRE_first_tail_x6_r0_body.wr0B10 : PRE_first_tail_x6_r0_body.st10.wr.all (fun b => !Nat.blt b PRE_first_tail_x6_r0_body.st10.s0.next || (PRE_first_tail_x6_r0_body.st10.s0.heap.get b).isSome) = true
theorem PRE_first_tail_x6_r0_body.stFoot10 : Conv.StageFoot PRE_first_tail_x6_r0_body.st10.wr PRE_first_tail_x6_r0_body.st10.s0 PRE_first_tail_x6_r0_body.st10.s2 :=
  stageFoot_of PRE_first_tail_x6_r0_body.st10.heapFoot PRE_first_tail_x6_r0_body.wrNodup10 PRE_first_tail_x6_r0_body.wrBound10 PRE_first_tail_x6_r0_body.wr0B10 PRE_first_tail_x6_r0_body.st10.grows

/-- **The relation at the merged state** from the relation at the merge (`Conv.site_merge`'s; `merged_relB`). -/
theorem PRE_first_tail_x6_r0_body.merged10 {FR : Map → Nat → PRE_first_tail_x6_r0_body.st10.F.S → PRE_first_tail_x6_r0_body.st10.F.S → Prop} {W : Nat → Option WFrame} {stk : List Frame} {M : Map}
    {ν : Nat → F64} {K : Host.Ts.Sim.Ctx} {S : SSrv} {t : St PRE_first_tail_x6_r0_body.st10.F.S} {C : CSrv} {n0 : Nat}
    (h : RelB PRE_first_tail_x6_r0_body.st10.F FR W stk M ν K (Conv.mergeSt Map.id (Map.id.res n0 n0) PRE_first_tail_x6_r0_body.rs10 PRE_first_tail_x6_r0_body.st10.wr PRE_first_tail_x6_r0_body.s110 PRE_first_tail_x6_r0_body.st10.s2 PRE_first_tail_x6_r0_body.st10.s0
      PRE_first_tail_x6_r0_body.st10.s2.ffi) S t C) : RelB PRE_first_tail_x6_r0_body.st10.F FR W stk M ν K PRE_first_tail_x6_r0_body.s111 S t C :=
  merged_relB PRE_first_tail_x6_r0_body.iso10 PRE_first_tail_x6_r0_body.stFoot10 PRE_first_tail_x6_r0_body.wrNodup10 PRE_first_tail_x6_r0_body.wrBound10 PRE_first_tail_x6_r0_body.trace10 PRE_first_tail_x6_r0_body.mheap10
    PRE_first_tail_x6_r0_body.mnext10 PRE_first_tail_x6_r0_body.mctl10 PRE_first_tail_x6_r0_body.mstack10 PRE_first_tail_x6_r0_body.mjobs10 PRE_first_tail_x6_r0_body.mffi10 PRE_first_tail_x6_r0_body.mtrace10 PRE_first_tail_x6_r0_body.mstores10 h

def PRE_first_tail_x6_r0_body.arrEl10_2665 : List Val := []
kernel_rfl PRE_first_tail_x6_r0_body.arrE10_2665 : arrOf PRE_first_tail_x6_r0_body.s111 2665 = arrOf PRE_first_tail_x6_r0_body.s0 2665 ++ PRE_first_tail_x6_r0_body.arrEl10_2665
kernel_rfl PRE_first_tail_x6_r0_body.arrA10_2665 : isArrB PRE_first_tail_x6_r0_body.s111 2665 = true
theorem PRE_first_tail_x6_r0_body.arr10_2665 : ∃ o, PRE_first_tail_x6_r0_body.s111.heap.get 2665 = some (.obj o) ∧ o.kind = .array (arrOf PRE_first_tail_x6_r0_body.s0 2665 ++ PRE_first_tail_x6_r0_body.arrEl10_2665) :=
  arrExt_of PRE_first_tail_x6_r0_body.arrE10_2665 PRE_first_tail_x6_r0_body.arrA10_2665
kernel_rfl PRE_first_tail_x6_r0_body.arrN10_2665 : numRefsB PRE_first_tail_x6_r0_body.S0.tab.length PRE_first_tail_x6_r0_body.arrEl10_2665 = true
theorem PRE_first_tail_x6_r0_body.arrR10_2665 : Prefill.NumRefs PRE_first_tail_x6_r0_body.S0.tab.length PRE_first_tail_x6_r0_body.arrEl10_2665 := numRefs_of PRE_first_tail_x6_r0_body.arrN10_2665

def PRE_first_tail_x6_r0_body.arrEl10_2673467 : List Val := []
kernel_rfl PRE_first_tail_x6_r0_body.arrE10_2673467 : arrOf PRE_first_tail_x6_r0_body.s111 2673467 = arrOf PRE_first_tail_x6_r0_body.s0 2673467 ++ PRE_first_tail_x6_r0_body.arrEl10_2673467
kernel_rfl PRE_first_tail_x6_r0_body.arrA10_2673467 : isArrB PRE_first_tail_x6_r0_body.s111 2673467 = true
theorem PRE_first_tail_x6_r0_body.arr10_2673467 : ∃ o, PRE_first_tail_x6_r0_body.s111.heap.get 2673467 = some (.obj o) ∧ o.kind = .array (arrOf PRE_first_tail_x6_r0_body.s0 2673467 ++ PRE_first_tail_x6_r0_body.arrEl10_2673467) :=
  arrExt_of PRE_first_tail_x6_r0_body.arrE10_2673467 PRE_first_tail_x6_r0_body.arrA10_2673467
kernel_rfl PRE_first_tail_x6_r0_body.arrN10_2673467 : numRefsB PRE_first_tail_x6_r0_body.S0.tab.length PRE_first_tail_x6_r0_body.arrEl10_2673467 = true
theorem PRE_first_tail_x6_r0_body.arrR10_2673467 : Prefill.NumRefs PRE_first_tail_x6_r0_body.S0.tab.length PRE_first_tail_x6_r0_body.arrEl10_2673467 := numRefs_of PRE_first_tail_x6_r0_body.arrN10_2673467

kernel_rfl PRE_first_tail_x6_r0_body.w4910k10 : isArrB PRE_first_tail_x6_r0_body.s111 4910 = false
theorem PRE_first_tail_x6_r0_body.keep10 (q : List Val) : Host.Ts.Sim.Prefill.KeepsAtW (framesP PRE_first_tail_x6_r0_body.s0 q) PRE_first_tail_x6_r0_body.s111 := by
  intro a pre pre' hx o es ho hk
  unfold framesP at hx
  simp only at hx
  cases h1 : Nat.beq a 2665
  · cases h2 : Nat.beq a 4910
    · rw [h1, h2] at hx; cases hx
    · have := Nat.eq_of_beq_eq_true h2; subst this
      rw [h1, h2] at hx; cases hx
      exact (notArr_of PRE_first_tail_x6_r0_body.w4910k10 ho hk).elim
  · have := Nat.eq_of_beq_eq_true h1; subst this
    rw [h1] at hx; cases hx
    obtain ⟨o', ho', hk'⟩ := PRE_first_tail_x6_r0_body.arr10_2665
    rw [ho] at ho'; cases ho'
    rw [hk'] at hk; cases hk
    simp [PRE_first_tail_x6_r0_body.arrEl10_2665]

end Host.Load.Run.Tpl
end

section -- SiteZ10
set_option Elab.async false
namespace Host.Load.Run.Tpl
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
open Host.Ts Host.Ts.Sim Host.Ts.Sim.Template

/-! The compaction's state shift at call site 10 of chain `PRE_first_tail_x6_r0_body` (`Conv.compact_shift`): the call `PRE_first_tail_x6_r0_body.s110`, the merged
state `PRE_first_tail_x6_r0_body.s111`, the canonical state `PRE_first_tail_x6_r0_body.s112`; its frames [2665,2673467,2673472,2673473] (kept arrays [2665,2673467]). -/

-- the map's places and counters
kernel_rfl PRE_first_tail_x6_r0_body.zpl10 : PRE_first_tail_x6_r0_body.pl10.all (Nat.ble PRE_first_tail_x6_r0_body.s110.next) = true
kernel_rfl PRE_first_tail_x6_r0_body.zplnd10 : nodupT PRE_first_tail_x6_r0_body.pl10 PTrie.nil = true
kernel_rfl PRE_first_tail_x6_r0_body.zn110 : Nat.ble PRE_first_tail_x6_r0_body.s110.next 2683095 = true
kernel_rfl PRE_first_tail_x6_r0_body.zfirst10 : Nat.ble aFirst PRE_first_tail_x6_r0_body.s110.next = true
kernel_rfl PRE_first_tail_x6_r0_body.zscn10 : PRE_first_tail_x6_r0_body.s112.next = PRE_first_tail_x6_r0_body.s110.next + PRE_first_tail_x6_r0_body.pl10.length
kernel_rfl PRE_first_tail_x6_r0_body.zsmn10 : PRE_first_tail_x6_r0_body.s111.next = 2683095
kernel_rfl PRE_first_tail_x6_r0_body.zgrow10 : Nat.ble PRE_first_tail_x6_r0_body.s112.next PRE_first_tail_x6_r0_body.s111.next = true
-- the tables
kernel_rfl PRE_first_tail_x6_r0_body.zfresh10 : PRE_first_tail_x6_r0_body.S110.tab.all (fun e => PRE_first_tail_x6_r0_body.cws10.all fun v => e.noVar v) = true
kernel_rfl PRE_first_tail_x6_r0_body.zcnd10 : nodupT PRE_first_tail_x6_r0_body.cws10 PTrie.nil = true
kernel_rfl PRE_first_tail_x6_r0_body.znrHi10 : PRE_first_tail_x6_r0_body.nr10.all (fun r => Nat.blt r PRE_first_tail_x6_r0_body.S111.tab.length) = true
-- the frames: every framed address below the call's counter; the kept arrays the chain start's, extended in the merged state
kernel_rfl PRE_first_tail_x6_r0_body.zfrlt10 : [2665, 2673467, 2673472, 2673473].all (fun a => Nat.blt a PRE_first_tail_x6_r0_body.s110.next) = true
kernel_rfl PRE_first_tail_x6_r0_body.zg10_2665 : PRE_first_tail_x6_r0_body.s112.heap.get 2665 = some (.obj (objOf PRE_first_tail_x6_r0_body.s112 2665))
kernel_rfl PRE_first_tail_x6_r0_body.zk10_2665 : (objOf PRE_first_tail_x6_r0_body.s112 2665).kind = .array (arrOf PRE_first_tail_x6_r0_body.s0 2665)
kernel_rfl PRE_first_tail_x6_r0_body.zm10_2665 : PRE_first_tail_x6_r0_body.s111.heap.get 2665 = some (.obj { PRE_first_tail_x6_r0_body.kappa10.obj (objOf PRE_first_tail_x6_r0_body.s112 2665) with
  kind := .array (arrOf PRE_first_tail_x6_r0_body.s0 2665 ++ (arrOf PRE_first_tail_x6_r0_body.s111 2665).drop (arrOf PRE_first_tail_x6_r0_body.s0 2665).length) })
kernel_rfl PRE_first_tail_x6_r0_body.zg10_2673467 : PRE_first_tail_x6_r0_body.s112.heap.get 2673467 = some (.obj (objOf PRE_first_tail_x6_r0_body.s112 2673467))
kernel_rfl PRE_first_tail_x6_r0_body.zk10_2673467 : (objOf PRE_first_tail_x6_r0_body.s112 2673467).kind = .array (arrOf PRE_first_tail_x6_r0_body.s0 2673467)
kernel_rfl PRE_first_tail_x6_r0_body.zm10_2673467 : PRE_first_tail_x6_r0_body.s111.heap.get 2673467 = some (.obj { PRE_first_tail_x6_r0_body.kappa10.obj (objOf PRE_first_tail_x6_r0_body.s112 2673467) with
  kind := .array (arrOf PRE_first_tail_x6_r0_body.s0 2673467 ++ (arrOf PRE_first_tail_x6_r0_body.s111 2673467).drop (arrOf PRE_first_tail_x6_r0_body.s0 2673467).length) })
kernel_rfl PRE_first_tail_x6_r0_body.zw10_4910 : (PRE_first_tail_x6_r0_body.s112.heap.get 4910).isSome = true
kernel_rfl PRE_first_tail_x6_r0_body.zw10_2673472 : (PRE_first_tail_x6_r0_body.s112.heap.get 2673472).isSome = true
kernel_rfl PRE_first_tail_x6_r0_body.zw10_2673473 : (PRE_first_tail_x6_r0_body.s112.heap.get 2673473).isSome = true
-- the heap: the changed list in range, holding the stage's written and fresh addresses; the canonical side's image
kernel_rfl PRE_first_tail_x6_r0_body.zclbd10 : PRE_first_tail_x6_r0_body.cl10.all (fun b => Nat.blt (b / 4096) (4 ^ 31)) = true
kernel_rfl PRE_first_tail_x6_r0_body.zwr10 : PRE_first_tail_x6_r0_body.st10.wr.all (fun b => !Nat.blt b PRE_first_tail_x6_r0_body.s110.next || PRE_first_tail_x6_r0_body.cl10.contains b) = true
def PRE_first_tail_x6_r0_body.zl10 : List Nat := PRE_first_tail_x6_r0_body.cl10.filter fun a => !(List.contains [2665, 2673467] a)
kernel_rfl PRE_first_tail_x6_r0_body.zimgE10 : PRE_first_tail_x6_r0_body.zl10.map (fun a => PRE_first_tail_x6_r0_body.s111.heap.get (PRE_first_tail_x6_r0_body.kappa10.a a)) = PRE_first_tail_x6_r0_body.zl10.map (fun a => (PRE_first_tail_x6_r0_body.s112.heap.get a).map PRE_first_tail_x6_r0_body.kappa10.hobj)
theorem PRE_first_tail_x6_r0_body.zimg10 : HeapImg PRE_first_tail_x6_r0_body.kappa10 PRE_first_tail_x6_r0_body.s112 PRE_first_tail_x6_r0_body.s111 PRE_first_tail_x6_r0_body.zl10 := PRE_first_tail_x6_r0_body.zimgE10
-- the roots and their supports
kernel_rfl PRE_first_tail_x6_r0_body.zctl10 : PRE_first_tail_x6_r0_body.s111.ctl = PRE_first_tail_x6_r0_body.kappa10.ctl PRE_first_tail_x6_r0_body.s112.ctl
kernel_rfl PRE_first_tail_x6_r0_body.zstack10 : PRE_first_tail_x6_r0_body.s111.stack = PRE_first_tail_x6_r0_body.s112.stack.map PRE_first_tail_x6_r0_body.kappa10.frame
kernel_rfl PRE_first_tail_x6_r0_body.zjobs10 : PRE_first_tail_x6_r0_body.s111.jobs = PRE_first_tail_x6_r0_body.s112.jobs.map PRE_first_tail_x6_r0_body.kappa10.job
kernel_rfl PRE_first_tail_x6_r0_body.zstores10 : PRE_first_tail_x6_r0_body.s111.stores = PRE_first_tail_x6_r0_body.kappa10.stores PRE_first_tail_x6_r0_body.s112.stores
kernel_rfl PRE_first_tail_x6_r0_body.zroots10 : checkRootsSupp PRE_first_tail_x6_r0_body.s112 506 = true
kernel_rfl PRE_first_tail_x6_r0_body.znC10 : PRE_first_tail_x6_r0_body.S110.tab.length + PRE_first_tail_x6_r0_body.cws10.length = 506
-- the map as `Conv.compact_shift` states it (the call's counters for the literals)
kernel_rfl PRE_first_tail_x6_r0_body.zkap10 : PRE_first_tail_x6_r0_body.kappa10 = Conv.Map.compact PRE_first_tail_x6_r0_body.s110.next 2683095 PRE_first_tail_x6_r0_body.S110.tab.length PRE_first_tail_x6_r0_body.pl10 (PRE_first_tail_x6_r0_body.nr10.map NumV.ref) PRE_first_tail_x6_r0_body.kd10.big
  PRE_first_tail_x6_r0_body.kd10.region PRE_first_tail_x6_r0_body.kd10.nodeF
-- the bridge inactive at the canonical state (`Conv.FullShiftQ.toX`; the merged state's bridge is the canonical's: cbridge)
theorem PRE_first_tail_x6_r0_body.zbin10 : (Host.Ts.Sim.Full.bridgeOf PRE_first_tail_x6_r0_body.s112.ffi).active = false := (Host.Load.Boot.replay_active Host.Load.Run.Prompt.P.oblog2818)
-- the JS bookkeeping's step (`Conv.JClean.step` over the changed list) and the canonical roots' bigint freedom
kernel_rfl PRE_first_tail_x6_r0_body.zjc10 : Conv.jcleanListB (⟨18410, 15492, 2683093, 506⟩ : Conv.Cnt) PRE_first_tail_x6_r0_body.s112 PRE_first_tail_x6_r0_body.cl10 = true
kernel_rfl PRE_first_tail_x6_r0_body.zrootsB10 : noBigRootsP (fun i => !Conv.oldBigB (⟨18410, 15492, 2683093, 506⟩ : Conv.Cnt) i) PRE_first_tail_x6_r0_body.s112.trace PRE_first_tail_x6_r0_body.s112 = true
kernel_rfl PRE_first_tail_x6_r0_body.zhm10 : Nat.ble (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.s0.ffi).mlx.nnext 15492 = true
theorem PRE_first_tail_x6_r0_body.cjcl10 (h : Conv.JClean (⟨18410, 15492, 2683093, 506⟩ : Conv.Cnt) PRE_first_tail_x6_r0_body.s110) : Conv.JClean (⟨18410, 15492, 2683093, 506⟩ : Conv.Cnt) PRE_first_tail_x6_r0_body.s112 :=
  Conv.JClean.step h (Conv.Cnt.le_of_leB PRE_first_tail_x6_r0_body.cle10)
    (Conv.heap_off_setAll PRE_first_tail_x6_r0_body.cheap10 fun a ha => Nat.blt_eq.mp (List.all_eq_true.mp PRE_first_tail_x6_r0_body.zclbd10 a ha)) PRE_first_tail_x6_r0_body.zjc10

end Host.Load.Run.Tpl
end

section -- st10/TypedLast
set_option Elab.async false
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
namespace Host.Load.Run.Tpl
open Host.Ts Host.Ts.Sim Host.Ts.Sim.Template

boot_rfl PRE_first_tail_x6_r0_body.st10.bodyLast from PRE_first_tail_x6_r0_body.st10.s1 to PRE_first_tail_x6_r0_body.st10.s2 :
  interpS (step PRE_first_tail_x6_r0_body.st10.F PRE_first_tail_x6_r0_body.st10.s1).run PRE_first_tail_x6_r0_body.st10.S1 = some (PRE_first_tail_x6_r0_body.st10.s2, PRE_first_tail_x6_r0_body.st10.S2)
kernel_rfl PRE_first_tail_x6_r0_body.st10.bodyHalt : isHalt PRE_first_tail_x6_r0_body.st10.s1.ctl = false
kernel_rfl PRE_first_tail_x6_r0_body.st10.bodyTopCheck : noBlockTop PRE_first_tail_x6_r0_body.st10.s2.stack = true

end Host.Load.Run.Tpl
end

section -- st10/TypedOk
set_option Elab.async false
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
namespace Host.Load.Run.Tpl
open Host.Ts Host.Ts.Sim Host.Ts.Sim.Template

noncomputable def PRE_first_tail_x6_r0_body.st10.bodyOkL (bytes : List Byte) (rows : Nat) : St PRE_first_tail_x6_r0_body.st10.F.S → SSrv → Bool :=
  okLocal (Host.Ts.Sim.Compose.VWFrames.bodyOk bytes rows)

noncomputable def PRE_first_tail_x6_r0_body.st10.bodyOkLN (bytes : List Byte) (rows : Nat) : St PRE_first_tail_x6_r0_body.st10.F.S → FSrv → Bool :=
  okLocalN (Host.Ts.Sim.Compose.VWFrames.bodyOkN bytes rows)

theorem PRE_first_tail_x6_r0_body.st10.bodyOkLN_ok (bytes : List Byte) (rows : Nat) (s : St PRE_first_tail_x6_r0_body.st10.F.S) (c : FSrv) (h : c.Wf) :
    PRE_first_tail_x6_r0_body.st10.bodyOkLN bytes rows s c = PRE_first_tail_x6_r0_body.st10.bodyOkL bytes rows s c.toS :=
  okLocalN_ok (Host.Ts.Sim.Compose.VWFrames.bodyOkN_ok bytes rows) s c h

kernel_rfl PRE_first_tail_x6_r0_body.st10.bodyAccepted0 :
  (fun (bytes : List Byte) (rows : Nat) => PRE_first_tail_x6_r0_body.st10.bodyOkL bytes rows PRE_first_tail_x6_r0_body.st10.s0 PRE_first_tail_x6_r0_body.st10.S0) = fun _ _ => true

kernel_rfl PRE_first_tail_x6_r0_body.st10.bodyAccepted1 :
  (fun (bytes : List Byte) (rows : Nat) => PRE_first_tail_x6_r0_body.st10.bodyOkL bytes rows PRE_first_tail_x6_r0_body.st10.s1 PRE_first_tail_x6_r0_body.st10.S1) = fun _ _ => true

end Host.Load.Run.Tpl
end

section -- st10/TypedK0
set_option Elab.async false
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
namespace Host.Load.Run.Tpl
open Host.Ts Host.Ts.Sim Host.Ts.Sim.Template

boot_rfl PRE_first_tail_x6_r0_body.st10.bodyK0F from PRE_first_tail_x6_r0_body.st10.s0 to PRE_first_tail_x6_r0_body.st10.s1 :
  (fun (bytes : List Byte) (rows : Nat) => runOkS PRE_first_tail_x6_r0_body.st10.F (PRE_first_tail_x6_r0_body.st10.bodyOkLN bytes rows)
    ((nth? PRE_first_tail_x6_r0_body.st10.ks 0).getD 0) PRE_first_tail_x6_r0_body.st10.s0 PRE_first_tail_x6_r0_body.st10.S0) = fun _ _ => some (PRE_first_tail_x6_r0_body.st10.s1, PRE_first_tail_x6_r0_body.st10.S1)
theorem PRE_first_tail_x6_r0_body.st10.bodyK0 :
  (fun (bytes : List Byte) (rows : Nat) => runOk PRE_first_tail_x6_r0_body.st10.F (PRE_first_tail_x6_r0_body.st10.bodyOkL bytes rows)
    ((nth? PRE_first_tail_x6_r0_body.st10.ks 0).getD 0) PRE_first_tail_x6_r0_body.st10.s0 PRE_first_tail_x6_r0_body.st10.S0) = fun _ _ => some (PRE_first_tail_x6_r0_body.st10.s1, PRE_first_tail_x6_r0_body.st10.S1) :=
  runOk_fun_of_runOkS PRE_first_tail_x6_r0_body.st10.bodyOkLN_ok PRE_first_tail_x6_r0_body.st10.bodyK0F
end Host.Load.Run.Tpl
end

section -- st10/TypedTpl
set_option Elab.async false
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
namespace Host.Load.Run.Tpl
open Host.Ts Host.Ts.Sim Host.Ts.Sim.Template

theorem PRE_first_tail_x6_r0_body.st10.bodyRun (bytes : List Byte) (rows : Nat) :
    runOk PRE_first_tail_x6_r0_body.st10.F (PRE_first_tail_x6_r0_body.st10.bodyOkL bytes rows) 27 PRE_first_tail_x6_r0_body.st10.s0 PRE_first_tail_x6_r0_body.st10.S0 = some (PRE_first_tail_x6_r0_body.st10.s1, PRE_first_tail_x6_r0_body.st10.S1) :=
  (congrFun (congrFun PRE_first_tail_x6_r0_body.st10.bodyK0 bytes) rows)

theorem PRE_first_tail_x6_r0_body.st10.bodyLocal (bytes : List Byte) (rows : Nat) : ∀ s S, PRE_first_tail_x6_r0_body.st10.bodyOkL bytes rows s S = true → Disp.localB s = true := okLocal_localB

noncomputable def PRE_first_tail_x6_r0_body.st10.bodyTpl (bytes : List Byte) (rows : Nat) : Host.Ts.Sim.Stage.StageTpl PRE_first_tail_x6_r0_body.st10.F (PRE_first_tail_x6_r0_body.st10.bodyOkL bytes rows) where
  s0 := PRE_first_tail_x6_r0_body.st10.s0
  S0 := PRE_first_tail_x6_r0_body.st10.S0
  s1 := PRE_first_tail_x6_r0_body.st10.s1
  S1 := PRE_first_tail_x6_r0_body.st10.S1
  s2 := PRE_first_tail_x6_r0_body.st10.s2
  S2 := PRE_first_tail_x6_r0_body.st10.S2
  n := 27
  ok0 := congrFun (congrFun PRE_first_tail_x6_r0_body.st10.bodyAccepted0 bytes) rows
  run := PRE_first_tail_x6_r0_body.st10.bodyRun bytes rows
  ok1 := congrFun (congrFun PRE_first_tail_x6_r0_body.st10.bodyAccepted1 bytes) rows
  halt := PRE_first_tail_x6_r0_body.st10.bodyHalt
  last := PRE_first_tail_x6_r0_body.st10.bodyLast
  top := noBlockTop_sound PRE_first_tail_x6_r0_body.st10.bodyTopCheck
end Host.Load.Run.Tpl
end

section -- SiteC11
set_option Elab.async false
namespace Host.Load.Run.Tpl
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
open Host.Ts Host.Ts.Sim Host.Ts.Sim.Template

/-! The compaction after the merge at call site 11 of chain `PRE_first_tail_x6_r0_body` (`Conv.compact`, `Conv.full_compactQ`): the canonical
state `PRE_first_tail_x6_r0_body.s116` (the stage's results at canonical places, its trace the call's) under `PRE_first_tail_x6_r0_body.kappa11` into the merged state
`PRE_first_tail_x6_r0_body.s115`. -/

def PRE_first_tail_x6_r0_body.pl11 : List Nat := [2683391]
def PRE_first_tail_x6_r0_body.nr11 : List Nat := []
/-- The native part of the compaction map (canonical → merged handles and nodes: its `big`, `region`, `nodeF`). -/
def PRE_first_tail_x6_r0_body.kd11 : RData :=
  ⟨2683382, 2683392, Stage.setAll PTrie.nil [(2683381, 2683391)], Stage.setAll PTrie.nil [],
   18417, 18417, 15496, 15496, Stage.setAll PTrie.nil [],
   Stage.setAll PTrie.nil []⟩
/-- **The compaction map.** -/
noncomputable def PRE_first_tail_x6_r0_body.kappa11 : Map :=
  Conv.Map.compact 2683381 2683392 523 PRE_first_tail_x6_r0_body.pl11 (PRE_first_tail_x6_r0_body.nr11.map NumV.ref) PRE_first_tail_x6_r0_body.kd11.big
    PRE_first_tail_x6_r0_body.kd11.region PRE_first_tail_x6_r0_body.kd11.nodeF
/-- The canonical result variables and their images, the merged state's entries (`Conv.compactθ`). -/
def PRE_first_tail_x6_r0_body.cws11 : List Nat := []
noncomputable def PRE_first_tail_x6_r0_body.crs11 : List SymE := PRE_first_tail_x6_r0_body.nr11.map fun r => (nth? PRE_first_tail_x6_r0_body.S115.tab r).getD (.var 0)
noncomputable def PRE_first_tail_x6_r0_body.ctheta11 : Nat → SymE := Conv.compactθ PRE_first_tail_x6_r0_body.cws11 PRE_first_tail_x6_r0_body.crs11
/-- The call's entries the stage wrote (renamed in the canonical state with the results). -/
def PRE_first_tail_x6_r0_body.wrB11 : List Nat := [2665, 2673467]

kernel_rfl PRE_first_tail_x6_r0_body.ctab11 : PRE_first_tail_x6_r0_body.S116.tab = PRE_first_tail_x6_r0_body.S114.tab ++ PRE_first_tail_x6_r0_body.cws11.map SymE.var
kernel_rfl PRE_first_tail_x6_r0_body.ctrace11 : PRE_first_tail_x6_r0_body.s116.trace = PRE_first_tail_x6_r0_body.s114.trace
kernel_rfl PRE_first_tail_x6_r0_body.cnext11 : PRE_first_tail_x6_r0_body.s116.next = 2683382
kernel_rfl PRE_first_tail_x6_r0_body.ccounters11 : ((Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.s116.ffi).mlx.next, (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.s116.ffi).mlx.nnext) = (18417, 15496)
-- the merged state's readback queue, carried to the canonical state (`Conv.FullShiftQ.tokens`, `tokSupp`)
kernel_rfl PRE_first_tail_x6_r0_body.cqueue11 : (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.s115.ffi).mlx.tokens = (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.s116.ffi).mlx.tokens.map PRE_first_tail_x6_r0_body.kappa11.nv
kernel_rfl PRE_first_tail_x6_r0_body.ctokSupp11 : (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.s116.ffi).mlx.tokens.all (bSN 523) = true
-- the written and the result entries carry no bigint of the canonical fresh band [next, E) and no fresh region
kernel_rfl PRE_first_tail_x6_r0_body.cclean11 : Conv.cleanListB 18417 131072 (fun r => Nat.ble 73668 r) PRE_first_tail_x6_r0_body.s116
    (PRE_first_tail_x6_r0_body.wrB11 ++ (List.range 1).map (2683381 + ·)) = true
kernel_rfl PRE_first_tail_x6_r0_body.cbigs11 : bigsOutB 18417 131072 (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.s116.ffi).mlx = true

end Host.Load.Run.Tpl
end

section -- SiteK11
set_option Elab.async false
namespace Host.Load.Run.Tpl
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
open Host.Ts Host.Ts.Sim Host.Ts.Sim.Template

/-! The canonical state's closedness from the call's (`Conv.closed_of_callB`, `Conv.sst_of_callB`): it keeps the call's entries
off the written and the result ones (`PRE_first_tail_x6_r0_body.cl11`; natively the written and result handles, the result nodes, the written
and result items), and those are checked. -/

def PRE_first_tail_x6_r0_body.cl11 : List Nat := [2665, 2673467, 2683381]
def PRE_first_tail_x6_r0_body.clo11 : List Nat := []
def PRE_first_tail_x6_r0_body.cln11 : List Nat := []
def PRE_first_tail_x6_r0_body.cli11 : List Nat := []
kernel_rfl PRE_first_tail_x6_r0_body.cheap11 : PRE_first_tail_x6_r0_body.s116.heap = Stage.setAll PRE_first_tail_x6_r0_body.s114.heap (PRE_first_tail_x6_r0_body.cl11.filterMap fun a => (PRE_first_tail_x6_r0_body.s116.heap.get a).map (a, ·))
kernel_rfl PRE_first_tail_x6_r0_body.cnextLe11 : Nat.ble PRE_first_tail_x6_r0_body.s114.next PRE_first_tail_x6_r0_body.s116.next = true
kernel_rfl PRE_first_tail_x6_r0_body.ckeepP11 : Conv.keptPresentB PRE_first_tail_x6_r0_body.s114 PRE_first_tail_x6_r0_body.s116 PRE_first_tail_x6_r0_body.cl11 = true
kernel_rfl PRE_first_tail_x6_r0_body.csupp11 : Conv.suppListB PRE_first_tail_x6_r0_body.s116 523 PRE_first_tail_x6_r0_body.cl11 = true
kernel_rfl PRE_first_tail_x6_r0_body.cbound11 : Conv.boundListB PRE_first_tail_x6_r0_body.s116 PRE_first_tail_x6_r0_body.cl11 = true
kernel_rfl PRE_first_tail_x6_r0_body.cnodesK11 : (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.s116.ffi).mlx.nodes = Stage.setAll (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.s114.ffi).mlx.nodes (PRE_first_tail_x6_r0_body.cln11.filterMap fun i => ((Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.s116.ffi).mlx.nodes.get i).map (i, ·))
kernel_rfl PRE_first_tail_x6_r0_body.cobjsK11 : (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.s116.ffi).mlx.objs = Stage.setAll (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.s114.ffi).mlx.objs (PRE_first_tail_x6_r0_body.clo11.filterMap fun i => ((Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.s116.ffi).mlx.objs.get i).map (i, ·))
kernel_rfl PRE_first_tail_x6_r0_body.citemsK11 : (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.s116.ffi).mlx.items = Stage.setAll (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.s114.ffi).mlx.items (PRE_first_tail_x6_r0_body.cli11.filterMap fun i => ((Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.s116.ffi).mlx.items.get i).map (i, ·))
kernel_rfl PRE_first_tail_x6_r0_body.csst11 : Conv.sstListB 523 (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.s116.ffi).mlx PRE_first_tail_x6_r0_body.cln11 PRE_first_tail_x6_r0_body.clo11 PRE_first_tail_x6_r0_body.cli11 = true

end Host.Load.Run.Tpl
end

section -- SiteCl11
set_option Elab.async false
namespace Host.Load.Run.Tpl
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
open Host.Ts Host.Ts.Sim Host.Ts.Sim.Template

kernel_rfl PRE_first_tail_x6_r0_body.ckA11 : (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.s116.ffi).mlx.arrs = Stage.setAll (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.s114.ffi).mlx.arrs (PRE_first_tail_x6_r0_body.clo11.filterMap fun i => ((Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.s116.ffi).mlx.arrs.get i).map (i, ·))
kernel_rfl PRE_first_tail_x6_r0_body.cbd11 : (PRE_first_tail_x6_r0_body.clo11 ++ PRE_first_tail_x6_r0_body.cln11 ++ PRE_first_tail_x6_r0_body.cli11).all (fun i => Nat.blt (i / 4096) (4 ^ 31)) = true
kernel_rfl PRE_first_tail_x6_r0_body.cle11 : Conv.Cnt.leB (⟨18417, 15496, 2683381, 523⟩ : Conv.Cnt) (⟨18417, 15496, 2683382, 523⟩ : Conv.Cnt) = true
kernel_rfl PRE_first_tail_x6_r0_body.cck11 : Conv.ncleanListB (⟨18417, 15496, 2683382, 523⟩ : Conv.Cnt) (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.s116.ffi).mlx PRE_first_tail_x6_r0_body.clo11 PRE_first_tail_x6_r0_body.cln11 PRE_first_tail_x6_r0_body.cli11 = true
theorem PRE_first_tail_x6_r0_body.cncl11 (h : Conv.NClean (⟨18417, 15496, 2683381, 523⟩ : Conv.Cnt) (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.s114.ffi).mlx) : Conv.NClean (⟨18417, 15496, 2683382, 523⟩ : Conv.Cnt) (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.s116.ffi).mlx :=
  Conv.NClean.stepKeep h PRE_first_tail_x6_r0_body.cle11 PRE_first_tail_x6_r0_body.ckA11 PRE_first_tail_x6_r0_body.cobjsK11 PRE_first_tail_x6_r0_body.cnodesK11 PRE_first_tail_x6_r0_body.citemsK11 PRE_first_tail_x6_r0_body.cbd11 PRE_first_tail_x6_r0_body.cck11

end Host.Load.Run.Tpl
end

section -- SiteS11
set_option Elab.async false
namespace Host.Load.Run.Tpl
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
open Host.Ts Host.Ts.Sim Host.Ts.Sim.Template

/-! The compaction's native shift at call site 11 from its footprint (`Conv.nshift_of_foot`), and the observers'
(`liveShift_foot`, `kernShift_foot`): `Conv.FullShiftQ` for `Conv.full_compactQ`, given the call's bookkeeping and its
relation's facts. -/

/-- The load parameters of the chain (band-free: its start's node counter as `NL` and `N0`). -/
def PRE_first_tail_x6_r0_body.Pc11 : LoadP := ⟨18151, 131072, 1099511627776, 15235, 15235, []⟩
/-- The site's band raised to the map's checked fixed-node prefix, including newly recorded closure traces. -/
def PRE_first_tail_x6_r0_body.P11 : LoadP := PRE_first_tail_x6_r0_body.Pc11.raise 15496
kernel_rfl PRE_first_tail_x6_r0_body.craise11 : Nat.ble PRE_first_tail_x6_r0_body.Pc11.N0 15496 = true
theorem PRE_first_tail_x6_r0_body.raised11 : Host.Ts.Sim.Full.Raised PRE_first_tail_x6_r0_body.Pc11 PRE_first_tail_x6_r0_body.P11 :=
  .inr ⟨15496, rfl, Nat.le_of_ble_eq_true PRE_first_tail_x6_r0_body.craise11, rfl⟩
noncomputable abbrev PRE_first_tail_x6_r0_body.cx0_11 : Host.Load.LSt := clearTokens (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.s116.ffi)
noncomputable abbrev PRE_first_tail_x6_r0_body.cx1_11 : Host.Load.LSt := clearTokens (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.s115.ffi)
def PRE_first_tail_x6_r0_body.khinv11 : PTrie Nat := Stage.setAll PTrie.nil []
def PRE_first_tail_x6_r0_body.kninv11 : PTrie Nat := Stage.setAll PTrie.nil []
/-- The stage's footprint: its written and fresh handles, fresh nodes, written and fresh items. -/
def PRE_first_tail_x6_r0_body.cwS11 : List Nat := []
def PRE_first_tail_x6_r0_body.cnS11 : List Nat := List.range' 15496 0
def PRE_first_tail_x6_r0_body.ciS11 : List Nat := [] ++ List.range' 15496 0

-- the small checks (`MChecks`'s)
kernel_rfl PRE_first_tail_x6_r0_body.cnh011 : PRE_first_tail_x6_r0_body.kd11.nh0 = PRE_first_tail_x6_r0_body.cx0_11.mlx.next
kernel_rfl PRE_first_tail_x6_r0_body.cnh111 : PRE_first_tail_x6_r0_body.kd11.nh1 = PRE_first_tail_x6_r0_body.cx1_11.mlx.next
kernel_rfl PRE_first_tail_x6_r0_body.cnn011 : PRE_first_tail_x6_r0_body.kd11.nn0 = PRE_first_tail_x6_r0_body.cx0_11.mlx.nnext
kernel_rfl PRE_first_tail_x6_r0_body.cnn111 : PRE_first_tail_x6_r0_body.kd11.nn1 = PRE_first_tail_x6_r0_body.cx1_11.mlx.nnext
kernel_rfl PRE_first_tail_x6_r0_body.cplo11 : (Nat.blt 0 PRE_first_tail_x6_r0_body.P11.lo && Nat.ble PRE_first_tail_x6_r0_body.P11.lo PRE_first_tail_x6_r0_body.cx0_11.mlx.next && Nat.ble PRE_first_tail_x6_r0_body.P11.lo RData.bigHi && Nat.ble RData.bigHi PRE_first_tail_x6_r0_body.P11.E) = true
kernel_rfl PRE_first_tail_x6_r0_body.ccnt11 : (Nat.ble PRE_first_tail_x6_r0_body.cx0_11.mlx.next PRE_first_tail_x6_r0_body.cx1_11.mlx.next && Nat.ble PRE_first_tail_x6_r0_body.cx0_11.mlx.nnext PRE_first_tail_x6_r0_body.cx1_11.mlx.nnext) = true
kernel_rfl PRE_first_tail_x6_r0_body.cnband11 : (Nat.blt 0 PRE_first_tail_x6_r0_body.P11.NL && Nat.ble PRE_first_tail_x6_r0_body.P11.NL PRE_first_tail_x6_r0_body.P11.N0 && Nat.ble PRE_first_tail_x6_r0_body.P11.N0 PRE_first_tail_x6_r0_body.cx0_11.mlx.nnext) = true
kernel_rfl PRE_first_tail_x6_r0_body.chbelow11 : PRE_first_tail_x6_r0_body.kd11.checkHndBelow = true
kernel_rfl PRE_first_tail_x6_r0_body.chren11 : checkRenG PRE_first_tail_x6_r0_body.kd11.hnd PRE_first_tail_x6_r0_body.khinv11 (phB PRE_first_tail_x6_r0_body.cx0_11.mlx) = true
kernel_rfl PRE_first_tail_x6_r0_body.cband11 : PRE_first_tail_x6_r0_body.kd11.checkBand PRE_first_tail_x6_r0_body.P11.lo = true
kernel_rfl PRE_first_tail_x6_r0_body.cnh1pos11 : Nat.blt 0 PRE_first_tail_x6_r0_body.kd11.nh1 = true
kernel_rfl PRE_first_tail_x6_r0_body.cnren11 : checkRenG PRE_first_tail_x6_r0_body.kd11.node PRE_first_tail_x6_r0_body.kninv11 (pnB PRE_first_tail_x6_r0_body.cx0_11.mlx) = true
kernel_rfl PRE_first_tail_x6_r0_body.cnlow11 : (PTrie.keysA PRE_first_tail_x6_r0_body.kd11.node).all (fun j => Nat.ble PRE_first_tail_x6_r0_body.P11.NL j && Nat.blt (PRE_first_tail_x6_r0_body.kd11.nodeF j) PRE_first_tail_x6_r0_body.cx1_11.mlx.nnext) = true
kernel_rfl PRE_first_tail_x6_r0_body.cabs0a11 : PRE_first_tail_x6_r0_body.cx0_11.mlx.arrs.get 0 = none
kernel_rfl PRE_first_tail_x6_r0_body.cabs0b11 : PRE_first_tail_x6_r0_body.cx0_11.mlx.objs.get 0 = none
kernel_rfl PRE_first_tail_x6_r0_body.ctok111 : PRE_first_tail_x6_r0_body.cx1_11.mlx.tokens = []
kernel_rfl PRE_first_tail_x6_r0_body.cpend11 : PRE_first_tail_x6_r0_body.cx1_11.mlx.pending = PRE_first_tail_x6_r0_body.cx0_11.mlx.pending.map PRE_first_tail_x6_r0_body.kappa11.pend
kernel_rfl PRE_first_tail_x6_r0_body.cerrh11 : PRE_first_tail_x6_r0_body.cx1_11.mlx.errh = PRE_first_tail_x6_r0_body.cx0_11.mlx.errh.map PRE_first_tail_x6_r0_body.kappa11.arg
kernel_rfl PRE_first_tail_x6_r0_body.cfiles11 : PRE_first_tail_x6_r0_body.cx1_11.mlx.files = PRE_first_tail_x6_r0_body.cx0_11.mlx.files
kernel_rfl PRE_first_tail_x6_r0_body.carch11 : PRE_first_tail_x6_r0_body.cx1_11.mlx.arch = PRE_first_tail_x6_r0_body.cx0_11.mlx.arch
kernel_rfl PRE_first_tail_x6_r0_body.csizes11 : PRE_first_tail_x6_r0_body.cx1_11.mlx.deviceSizes = PRE_first_tail_x6_r0_body.cx0_11.mlx.deviceSizes
kernel_rfl PRE_first_tail_x6_r0_body.cwired11 : PRE_first_tail_x6_r0_body.cx1_11.mlx.wired = PRE_first_tail_x6_r0_body.cx0_11.mlx.wired
kernel_rfl PRE_first_tail_x6_r0_body.chost11 : PRE_first_tail_x6_r0_body.cx1_11.host = PRE_first_tail_x6_r0_body.cx0_11.host
-- the compaction map's addresses are `PRE_first_tail_x6_r0_body.kd11`'s
kernel_rfl PRE_first_tail_x6_r0_body.ckn011 : PRE_first_tail_x6_r0_body.kd11.n0 = 2683382
kernel_rfl PRE_first_tail_x6_r0_body.ckn111 : PRE_first_tail_x6_r0_body.kd11.n1 = 2683392
kernel_rfl PRE_first_tail_x6_r0_body.ckheap11 : (PTrie.keysA PRE_first_tail_x6_r0_body.kd11.heap).all (fun x => Nat.ble 2683381 x) = true
kernel_rfl PRE_first_tail_x6_r0_body.ckpl11 : (List.range 1).all (fun j => decide (PRE_first_tail_x6_r0_body.kd11.heap.get (2683381 + j) = nth? PRE_first_tail_x6_r0_body.pl11 j)) = true
-- the map fixes the call's names (`Conv.fixOld_compact`), the call's counters
kernel_rfl PRE_first_tail_x6_r0_body.fja11 : Nat.ble 2683381 2683381 = true
kernel_rfl PRE_first_tail_x6_r0_body.fn11 : Nat.ble 523 523 = true
kernel_rfl PRE_first_tail_x6_r0_body.fjaD11 : Nat.ble 2683381 PRE_first_tail_x6_r0_body.kd11.n0 = true
kernel_rfl PRE_first_tail_x6_r0_body.fxn11 : Nat.ble 18417 PRE_first_tail_x6_r0_body.kd11.nh0 = true
kernel_rfl PRE_first_tail_x6_r0_body.fnn11 : Nat.ble 15496 PRE_first_tail_x6_r0_body.kd11.nn0 = true
kernel_rfl PRE_first_tail_x6_r0_body.fxb11 : Nat.ble 18417 RData.bigHi = true
kernel_rfl PRE_first_tail_x6_r0_body.fheap11 : (PTrie.keysA PRE_first_tail_x6_r0_body.kd11.heap).all (Nat.ble (⟨18417, 15496, 2683381, 523⟩ : Conv.Cnt).ja) = true
kernel_rfl PRE_first_tail_x6_r0_body.fhnd11 : (PTrie.keysA PRE_first_tail_x6_r0_body.kd11.hnd).all (Nat.ble (⟨18417, 15496, 2683381, 523⟩ : Conv.Cnt).xn) = true
kernel_rfl PRE_first_tail_x6_r0_body.fnode11 : (PTrie.keysA PRE_first_tail_x6_r0_body.kd11.node).all (Nat.ble (⟨18417, 15496, 2683381, 523⟩ : Conv.Cnt).nn) = true
/-- The compaction map fixes the call's names. -/
theorem PRE_first_tail_x6_r0_body.cfix11 : Conv.FixOld (⟨18417, 15496, 2683381, 523⟩ : Conv.Cnt) PRE_first_tail_x6_r0_body.kappa11 :=
  Conv.fixOld_compact (Nat.le_of_ble_eq_true PRE_first_tail_x6_r0_body.fja11) (Nat.le_of_ble_eq_true PRE_first_tail_x6_r0_body.fn11) (Nat.le_of_ble_eq_true PRE_first_tail_x6_r0_body.fjaD11) (Nat.le_of_ble_eq_true PRE_first_tail_x6_r0_body.fxn11) (Nat.le_of_ble_eq_true PRE_first_tail_x6_r0_body.fnn11) (Nat.le_of_ble_eq_true PRE_first_tail_x6_r0_body.fxb11) PRE_first_tail_x6_r0_body.fheap11 PRE_first_tail_x6_r0_body.fhnd11 PRE_first_tail_x6_r0_body.fnode11
kernel_rfl PRE_first_tail_x6_r0_body.fcxn11 : (⟨18417, 15496, 2683381, 523⟩ : Conv.Cnt).xn = (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.s114.ffi).mlx.next
kernel_rfl PRE_first_tail_x6_r0_body.fcnn11 : (⟨18417, 15496, 2683381, 523⟩ : Conv.Cnt).nn = (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.s114.ffi).mlx.nnext
kernel_rfl PRE_first_tail_x6_r0_body.fle011 : (Nat.ble (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.s114.ffi).mlx.next PRE_first_tail_x6_r0_body.cx0_11.mlx.next && Nat.ble (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.s114.ffi).mlx.nnext PRE_first_tail_x6_r0_body.cx0_11.mlx.nnext && Nat.ble (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.s114.ffi).mlx.next RData.bigHi) = true
kernel_rfl PRE_first_tail_x6_r0_body.fnk11 : (PTrie.keysA PRE_first_tail_x6_r0_body.kd11.node).all (Nat.ble (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.s114.ffi).mlx.nnext) = true
-- the merged state keeps the call's entries off the stage's footprint
kernel_rfl PRE_first_tail_x6_r0_body.f1A11 : PRE_first_tail_x6_r0_body.cx1_11.mlx.arrs = Stage.setAll (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.s114.ffi).mlx.arrs (PRE_first_tail_x6_r0_body.cwS11.filterMap fun i => (PRE_first_tail_x6_r0_body.cx1_11.mlx.arrs.get i).map (i, ·))
kernel_rfl PRE_first_tail_x6_r0_body.f1O11 : PRE_first_tail_x6_r0_body.cx1_11.mlx.objs = Stage.setAll (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.s114.ffi).mlx.objs (PRE_first_tail_x6_r0_body.cwS11.filterMap fun i => (PRE_first_tail_x6_r0_body.cx1_11.mlx.objs.get i).map (i, ·))
kernel_rfl PRE_first_tail_x6_r0_body.f1N11 : PRE_first_tail_x6_r0_body.cx1_11.mlx.nodes = Stage.setAll (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.s114.ffi).mlx.nodes (PRE_first_tail_x6_r0_body.cnS11.filterMap fun i => (PRE_first_tail_x6_r0_body.cx1_11.mlx.nodes.get i).map (i, ·))
kernel_rfl PRE_first_tail_x6_r0_body.f1I11 : PRE_first_tail_x6_r0_body.cx1_11.mlx.items = Stage.setAll (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.s114.ffi).mlx.items (PRE_first_tail_x6_r0_body.ciS11.filterMap fun i => (PRE_first_tail_x6_r0_body.cx1_11.mlx.items.get i).map (i, ·))
kernel_rfl PRE_first_tail_x6_r0_body.fbd11 : (PRE_first_tail_x6_r0_body.clo11 ++ PRE_first_tail_x6_r0_body.cln11 ++ PRE_first_tail_x6_r0_body.cli11 ++ PRE_first_tail_x6_r0_body.cwS11 ++ PRE_first_tail_x6_r0_body.cnS11 ++ PRE_first_tail_x6_r0_body.ciS11).all (fun i => Nat.blt (i / 4096) (4 ^ 31)) = true
kernel_rfl PRE_first_tail_x6_r0_body.fincW11 : PRE_first_tail_x6_r0_body.cwS11.all (fun h => !Nat.blt h (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.s114.ffi).mlx.next || PRE_first_tail_x6_r0_body.clo11.contains h) = true
kernel_rfl PRE_first_tail_x6_r0_body.fincI11 : PRE_first_tail_x6_r0_body.ciS11.all (fun k => !Nat.blt k (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.s114.ffi).mlx.nnext || PRE_first_tail_x6_r0_body.cli11.contains k) = true
kernel_rfl PRE_first_tail_x6_r0_body.fincN11 : PRE_first_tail_x6_r0_body.cnS11.all (Nat.ble (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.s114.ffi).mlx.nnext) = true
kernel_rfl PRE_first_tail_x6_r0_body.flnF11 : PRE_first_tail_x6_r0_body.cln11.all (Nat.ble (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.s114.ffi).mlx.nnext) = true
-- the checks over the changed lists
kernel_rfl PRE_first_tail_x6_r0_body.fh11 : PRE_first_tail_x6_r0_body.clo11.all (handleOK PRE_first_tail_x6_r0_body.kappa11 PRE_first_tail_x6_r0_body.P11.lo PRE_first_tail_x6_r0_body.cx0_11.mlx PRE_first_tail_x6_r0_body.cx1_11.mlx) = true
kernel_rfl PRE_first_tail_x6_r0_body.fo11 : PRE_first_tail_x6_r0_body.clo11.map (fun h => PRE_first_tail_x6_r0_body.cx1_11.mlx.objs.get (PRE_first_tail_x6_r0_body.kappa11.handle h)) = PRE_first_tail_x6_r0_body.clo11.map (fun h => (PRE_first_tail_x6_r0_body.cx0_11.mlx.objs.get h).map PRE_first_tail_x6_r0_body.kappa11.nobj)
kernel_rfl PRE_first_tail_x6_r0_body.fok11 : PRE_first_tail_x6_r0_body.clo11.all (objOK PRE_first_tail_x6_r0_body.kappa11 PRE_first_tail_x6_r0_body.P11.NL PRE_first_tail_x6_r0_body.cx0_11.mlx) = true
kernel_rfl PRE_first_tail_x6_r0_body.fnd11 : PRE_first_tail_x6_r0_body.cln11.all (nodeOKF PRE_first_tail_x6_r0_body.kappa11 PRE_first_tail_x6_r0_body.P11 PRE_first_tail_x6_r0_body.cx0_11.mlx PRE_first_tail_x6_r0_body.cx1_11.mlx) = true
kernel_rfl PRE_first_tail_x6_r0_body.fp11 : ((PRE_first_tail_x6_r0_body.cln11.filter (fullB PRE_first_tail_x6_r0_body.P11))).map (fun i => (PRE_first_tail_x6_r0_body.cx1_11.mlx.nodes.get (PRE_first_tail_x6_r0_body.kappa11.node i)).map Host.Mlx.Ffi.Node.prim) =
  ((PRE_first_tail_x6_r0_body.cln11.filter (fullB PRE_first_tail_x6_r0_body.P11))).map (fun i => (PRE_first_tail_x6_r0_body.cx0_11.mlx.nodes.get i).map fun nd => PRE_first_tail_x6_r0_body.kappa11.prim nd.prim)
kernel_rfl PRE_first_tail_x6_r0_body.fnordI11 : incrB PRE_first_tail_x6_r0_body.kd11.nodeF (List.range' 15496 0) = true
kernel_rfl PRE_first_tail_x6_r0_body.fnordK11 : (PTrie.keysA PRE_first_tail_x6_r0_body.kd11.node).all (fun k => Nat.ble 15496 k && Nat.blt k 15496) = true
kernel_rfl PRE_first_tail_x6_r0_body.fnordL11 : (PRE_first_tail_x6_r0_body.cln11.filter (Nat.ble PRE_first_tail_x6_r0_body.P11.N0)).all (fun i => Nat.ble i (PRE_first_tail_x6_r0_body.kd11.nodeF i) && (Nat.blt i 15496 || Nat.ble PRE_first_tail_x6_r0_body.kd11.nn0 i)) = true
theorem PRE_first_tail_x6_r0_body.fnord11 : (PRE_first_tail_x6_r0_body.cln11.filter (Nat.ble PRE_first_tail_x6_r0_body.P11.N0)).all (fun i => Nat.ble i (PRE_first_tail_x6_r0_body.kd11.nodeF i) &&
    (PTrie.keysA PRE_first_tail_x6_r0_body.kd11.node).all fun j => !Nat.blt j i || Nat.blt (PRE_first_tail_x6_r0_body.kd11.nodeF j) (PRE_first_tail_x6_r0_body.kd11.nodeF i)) = true :=
  cnord_of PRE_first_tail_x6_r0_body.cnlow11 PRE_first_tail_x6_r0_body.cnn111 PRE_first_tail_x6_r0_body.fnordI11 PRE_first_tail_x6_r0_body.fnordK11 PRE_first_tail_x6_r0_body.fnordL11
kernel_rfl PRE_first_tail_x6_r0_body.fi11 : PRE_first_tail_x6_r0_body.cli11.all (pnB PRE_first_tail_x6_r0_body.cx0_11.mlx) = true
kernel_rfl PRE_first_tail_x6_r0_body.fii11 : PRE_first_tail_x6_r0_body.cli11.all (fun k => decide (PRE_first_tail_x6_r0_body.cx1_11.mlx.items.get (PRE_first_tail_x6_r0_body.kappa11.node k) = (PRE_first_tail_x6_r0_body.cx0_11.mlx.items.get k).map PRE_first_tail_x6_r0_body.kappa11.nv)) = true
/-- **The compaction's footprint.** -/
theorem PRE_first_tail_x6_r0_body.cfoot11 (clean : Conv.NClean (⟨18417, 15496, 2683381, 523⟩ : Conv.Cnt) (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.s114.ffi).mlx) (hltC : ∀ h, PH (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.s114.ffi).mlx h → h < (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.s114.ffi).mlx.next) (nltC : ∀ i, PN (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.s114.ffi).mlx i → i < (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.s114.ffi).mlx.nnext) (itemsC : ∀ k v, (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.s114.ffi).mlx.items.get k = some v → PN (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.s114.ffi).mlx k) (tracedC : ∀ h o, (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.s114.ffi).mlx.objs.get h = some o → ∀ i ∈ objTraces o, i < PRE_first_tail_x6_r0_body.P11.NL) (cl : SSt (· < 523) PRE_first_tail_x6_r0_body.cx0_11.mlx) :
    Conv.MFoot PRE_first_tail_x6_r0_body.P11 523 PRE_first_tail_x6_r0_body.kappa11 PRE_first_tail_x6_r0_body.kd11 PRE_first_tail_x6_r0_body.khinv11 PRE_first_tail_x6_r0_body.kninv11 (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.s114.ffi).mlx PRE_first_tail_x6_r0_body.cx0_11.mlx PRE_first_tail_x6_r0_body.cx1_11.mlx (⟨18417, 15496, 2683381, 523⟩ : Conv.Cnt) PRE_first_tail_x6_r0_body.clo11 PRE_first_tail_x6_r0_body.cln11 PRE_first_tail_x6_r0_body.cli11 PRE_first_tail_x6_r0_body.cwS11 PRE_first_tail_x6_r0_body.cnS11 PRE_first_tail_x6_r0_body.ciS11 :=
  ⟨rfl, rfl, rfl, PRE_first_tail_x6_r0_body.cnh011, PRE_first_tail_x6_r0_body.cnh111, PRE_first_tail_x6_r0_body.cnn011, PRE_first_tail_x6_r0_body.cnn111, PRE_first_tail_x6_r0_body.cplo11, PRE_first_tail_x6_r0_body.ccnt11, PRE_first_tail_x6_r0_body.cnband11, PRE_first_tail_x6_r0_body.chbelow11, PRE_first_tail_x6_r0_body.chren11, PRE_first_tail_x6_r0_body.cband11, PRE_first_tail_x6_r0_body.cnh1pos11, PRE_first_tail_x6_r0_body.cnren11, PRE_first_tail_x6_r0_body.cnlow11, PRE_first_tail_x6_r0_body.cabs0a11, PRE_first_tail_x6_r0_body.cabs0b11, PRE_first_tail_x6_r0_body.ctok111, PRE_first_tail_x6_r0_body.cpend11, PRE_first_tail_x6_r0_body.cerrh11, PRE_first_tail_x6_r0_body.cfiles11, PRE_first_tail_x6_r0_body.carch11, PRE_first_tail_x6_r0_body.csizes11, PRE_first_tail_x6_r0_body.cwired11, PRE_first_tail_x6_r0_body.cfix11, clean, PRE_first_tail_x6_r0_body.fcxn11, PRE_first_tail_x6_r0_body.fcnn11, hltC, nltC, itemsC, tracedC, cl, PRE_first_tail_x6_r0_body.fle011, PRE_first_tail_x6_r0_body.fnk11, PRE_first_tail_x6_r0_body.ckA11, PRE_first_tail_x6_r0_body.cobjsK11, PRE_first_tail_x6_r0_body.cnodesK11, PRE_first_tail_x6_r0_body.citemsK11, PRE_first_tail_x6_r0_body.f1A11, PRE_first_tail_x6_r0_body.f1O11, PRE_first_tail_x6_r0_body.f1N11, PRE_first_tail_x6_r0_body.f1I11, PRE_first_tail_x6_r0_body.fbd11, PRE_first_tail_x6_r0_body.fincW11, PRE_first_tail_x6_r0_body.fincI11, PRE_first_tail_x6_r0_body.fincN11, PRE_first_tail_x6_r0_body.flnF11, PRE_first_tail_x6_r0_body.fh11, PRE_first_tail_x6_r0_body.fo11, PRE_first_tail_x6_r0_body.fok11, PRE_first_tail_x6_r0_body.fnd11, PRE_first_tail_x6_r0_body.fp11, PRE_first_tail_x6_r0_body.fnord11, PRE_first_tail_x6_r0_body.fi11, PRE_first_tail_x6_r0_body.fii11⟩
theorem PRE_first_tail_x6_r0_body.cnshift11 (clean : Conv.NClean (⟨18417, 15496, 2683381, 523⟩ : Conv.Cnt) (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.s114.ffi).mlx) (hltC : ∀ h, PH (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.s114.ffi).mlx h → h < (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.s114.ffi).mlx.next) (nltC : ∀ i, PN (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.s114.ffi).mlx i → i < (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.s114.ffi).mlx.nnext) (itemsC : ∀ k v, (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.s114.ffi).mlx.items.get k = some v → PN (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.s114.ffi).mlx k) (tracedC : ∀ h o, (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.s114.ffi).mlx.objs.get h = some o → ∀ i ∈ objTraces o, i < PRE_first_tail_x6_r0_body.P11.NL) (cl : SSt (· < 523) PRE_first_tail_x6_r0_body.cx0_11.mlx) : NShift PRE_first_tail_x6_r0_body.P11 523 PRE_first_tail_x6_r0_body.kappa11 PRE_first_tail_x6_r0_body.cx0_11 PRE_first_tail_x6_r0_body.cx1_11 :=
  Conv.nshift_of_foot (PRE_first_tail_x6_r0_body.cfoot11 clean hltC nltC itemsC tracedC cl) PRE_first_tail_x6_r0_body.chost11 (compact_a_eq PRE_first_tail_x6_r0_body.ckn011 PRE_first_tail_x6_r0_body.ckn111 PRE_first_tail_x6_r0_body.ckheap11 PRE_first_tail_x6_r0_body.ckpl11)

-- the observers: the layers' states at the call, the canonical and the merged state, their footprints and checks
noncomputable def PRE_first_tail_x6_r0_body.fxC_11 : PTrie Unit := (Host.Ts.Sim.Full.freedOf PRE_first_tail_x6_r0_body.s114.ffi).getD PTrie.nil
noncomputable def PRE_first_tail_x6_r0_body.krC_11 : Host.Load.Layers.KRec := (Host.Ts.Sim.Full.krecOf PRE_first_tail_x6_r0_body.s114.ffi).getD Host.Load.Layers.KRec.empty
kernel_rfl PRE_first_tail_x6_r0_body.ofxC_11 : (Host.Ts.Sim.Full.freedOf PRE_first_tail_x6_r0_body.s114.ffi) = some PRE_first_tail_x6_r0_body.fxC_11
kernel_rfl PRE_first_tail_x6_r0_body.okrC_11 : (Host.Ts.Sim.Full.krecOf PRE_first_tail_x6_r0_body.s114.ffi) = some PRE_first_tail_x6_r0_body.krC_11
noncomputable def PRE_first_tail_x6_r0_body.fx0_11 : PTrie Unit := (Host.Ts.Sim.Full.freedOf PRE_first_tail_x6_r0_body.s116.ffi).getD PTrie.nil
noncomputable def PRE_first_tail_x6_r0_body.kr0_11 : Host.Load.Layers.KRec := (Host.Ts.Sim.Full.krecOf PRE_first_tail_x6_r0_body.s116.ffi).getD Host.Load.Layers.KRec.empty
kernel_rfl PRE_first_tail_x6_r0_body.ofx0_11 : (Host.Ts.Sim.Full.freedOf PRE_first_tail_x6_r0_body.s116.ffi) = some PRE_first_tail_x6_r0_body.fx0_11
kernel_rfl PRE_first_tail_x6_r0_body.okr0_11 : (Host.Ts.Sim.Full.krecOf PRE_first_tail_x6_r0_body.s116.ffi) = some PRE_first_tail_x6_r0_body.kr0_11
noncomputable def PRE_first_tail_x6_r0_body.fx1_11 : PTrie Unit := (Host.Ts.Sim.Full.freedOf PRE_first_tail_x6_r0_body.s115.ffi).getD PTrie.nil
noncomputable def PRE_first_tail_x6_r0_body.kr1_11 : Host.Load.Layers.KRec := (Host.Ts.Sim.Full.krecOf PRE_first_tail_x6_r0_body.s115.ffi).getD Host.Load.Layers.KRec.empty
kernel_rfl PRE_first_tail_x6_r0_body.ofx1_11 : (Host.Ts.Sim.Full.freedOf PRE_first_tail_x6_r0_body.s115.ffi) = some PRE_first_tail_x6_r0_body.fx1_11
kernel_rfl PRE_first_tail_x6_r0_body.okr1_11 : (Host.Ts.Sim.Full.krecOf PRE_first_tail_x6_r0_body.s115.ffi) = some PRE_first_tail_x6_r0_body.kr1_11
kernel_rfl PRE_first_tail_x6_r0_body.ff011 : PRE_first_tail_x6_r0_body.fx0_11 = Stage.setAll PRE_first_tail_x6_r0_body.fxC_11 (PRE_first_tail_x6_r0_body.clo11.filterMap fun i => (PRE_first_tail_x6_r0_body.fx0_11.get i).map (i, ·))
kernel_rfl PRE_first_tail_x6_r0_body.ff111 : PRE_first_tail_x6_r0_body.fx1_11 = Stage.setAll PRE_first_tail_x6_r0_body.fxC_11 (PRE_first_tail_x6_r0_body.cwS11.filterMap fun i => (PRE_first_tail_x6_r0_body.fx1_11.get i).map (i, ·))
kernel_rfl PRE_first_tail_x6_r0_body.ffck11 : freedLB PRE_first_tail_x6_r0_body.kappa11 PRE_first_tail_x6_r0_body.cx0_11.mlx PRE_first_tail_x6_r0_body.fx0_11 PRE_first_tail_x6_r0_body.fx1_11 PRE_first_tail_x6_r0_body.clo11 = true
kernel_rfl PRE_first_tail_x6_r0_body.fkf011 : PRE_first_tail_x6_r0_body.kr0_11.flags = Stage.setAll PRE_first_tail_x6_r0_body.krC_11.flags (PRE_first_tail_x6_r0_body.clo11.filterMap fun i => (PRE_first_tail_x6_r0_body.kr0_11.flags.get i).map (i, ·))
kernel_rfl PRE_first_tail_x6_r0_body.fkt011 : PRE_first_tail_x6_r0_body.kr0_11.targs = Stage.setAll PRE_first_tail_x6_r0_body.krC_11.targs (PRE_first_tail_x6_r0_body.clo11.filterMap fun i => (PRE_first_tail_x6_r0_body.kr0_11.targs.get i).map (i, ·))
kernel_rfl PRE_first_tail_x6_r0_body.fkf111 : PRE_first_tail_x6_r0_body.kr1_11.flags = Stage.setAll PRE_first_tail_x6_r0_body.krC_11.flags (PRE_first_tail_x6_r0_body.cwS11.filterMap fun i => (PRE_first_tail_x6_r0_body.kr1_11.flags.get i).map (i, ·))
kernel_rfl PRE_first_tail_x6_r0_body.fkt111 : PRE_first_tail_x6_r0_body.kr1_11.targs = Stage.setAll PRE_first_tail_x6_r0_body.krC_11.targs (PRE_first_tail_x6_r0_body.cwS11.filterMap fun i => (PRE_first_tail_x6_r0_body.kr1_11.targs.get i).map (i, ·))
kernel_rfl PRE_first_tail_x6_r0_body.fkck11 : krecLB PRE_first_tail_x6_r0_body.kappa11 523 PRE_first_tail_x6_r0_body.cx0_11.mlx PRE_first_tail_x6_r0_body.kr0_11 PRE_first_tail_x6_r0_body.kr1_11 PRE_first_tail_x6_r0_body.clo11 = true
kernel_rfl PRE_first_tail_x6_r0_body.fkn11 : Nat.ble 523 523 = true
-- the bridge and the pending traces' regions
kernel_rfl PRE_first_tail_x6_r0_body.cbridge11 : Host.Ts.Sim.Full.bridgeOf PRE_first_tail_x6_r0_body.s115.ffi = Host.Ts.Sim.Full.bridgeOf PRE_first_tail_x6_r0_body.s116.ffi
kernel_rfl PRE_first_tail_x6_r0_body.cpendR11 : pendRegB PRE_first_tail_x6_r0_body.kappa11 (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.s116.ffi).mlx = true
kernel_rfl PRE_first_tail_x6_r0_body.cpendLe11 : Nat.ble (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.s116.ffi).mlx.next (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.s115.ffi).mlx.next = true
/-- **The compaction's native shift**, given the call's bookkeeping, its relation's facts (the model's and the
observers') and the canonical closedness. -/
theorem PRE_first_tail_x6_r0_body.cshift11 (clean : Conv.NClean (⟨18417, 15496, 2683381, 523⟩ : Conv.Cnt) (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.s114.ffi).mlx) (hltC : ∀ h, PH (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.s114.ffi).mlx h → h < (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.s114.ffi).mlx.next) (nltC : ∀ i, PN (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.s114.ffi).mlx i → i < (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.s114.ffi).mlx.nnext) (itemsC : ∀ k v, (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.s114.ffi).mlx.items.get k = some v → PN (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.s114.ffi).mlx k) (tracedC : ∀ h o, (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.s114.ffi).mlx.objs.get h = some o → ∀ i ∈ objTraces o, i < PRE_first_tail_x6_r0_body.P11.NL) (cl : SSt (· < 523) PRE_first_tail_x6_r0_body.cx0_11.mlx)
    (hobjC : ∀ h, PRE_first_tail_x6_r0_body.fxC_11.get h = some () → ((Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.s114.ffi).mlx.objs.get h).isSome = true)
    (hfC : ∀ h, (PRE_first_tail_x6_r0_body.krC_11.flags.get h).isSome = true → ((Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.s114.ffi).mlx.objs.get h).isSome = true)
    (htC : ∀ h, (PRE_first_tail_x6_r0_body.krC_11.targs.get h).isSome = true → ((Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.s114.ffi).mlx.objs.get h).isSome = true)
    (hclC : ∀ h l, PRE_first_tail_x6_r0_body.krC_11.targs.get h = some l → Host.Ts.Sim.Full.STargs (· < (⟨18417, 15496, 2683381, 523⟩ : Conv.Cnt).n) l) :
    Conv.FullShiftQ PRE_first_tail_x6_r0_body.P11 523 PRE_first_tail_x6_r0_body.kappa11 PRE_first_tail_x6_r0_body.s116.ffi PRE_first_tail_x6_r0_body.s115.ffi :=
  ⟨PRE_first_tail_x6_r0_body.cnshift11 clean hltC nltC itemsC tracedC cl, PRE_first_tail_x6_r0_body.cqueue11, fun t ht => bSN_sound (List.all_eq_true.mp PRE_first_tail_x6_r0_body.ctokSupp11 t ht),
    PRE_first_tail_x6_r0_body.cbridge11,
    liveShift_foot (x0' := Host.Ts.Sim.Full.mlxOf PRE_first_tail_x6_r0_body.s116.ffi) (x1' := Host.Ts.Sim.Full.mlxOf PRE_first_tail_x6_r0_body.s115.ffi) (PRE_first_tail_x6_r0_body.cfoot11 clean hltC nltC itemsC tracedC cl) rfl PRE_first_tail_x6_r0_body.ofx0_11 PRE_first_tail_x6_r0_body.ofx1_11 hobjC PRE_first_tail_x6_r0_body.ff011 PRE_first_tail_x6_r0_body.ff111 PRE_first_tail_x6_r0_body.ffck11,
    kernShift_foot (x0' := Host.Ts.Sim.Full.mlxOf PRE_first_tail_x6_r0_body.s116.ffi) (x1' := Host.Ts.Sim.Full.mlxOf PRE_first_tail_x6_r0_body.s115.ffi) (PRE_first_tail_x6_r0_body.cfoot11 clean hltC nltC itemsC tracedC cl) rfl PRE_first_tail_x6_r0_body.okr0_11 PRE_first_tail_x6_r0_body.okr1_11 (Nat.le_of_ble_eq_true PRE_first_tail_x6_r0_body.fkn11) hfC htC hclC
      PRE_first_tail_x6_r0_body.fkf011 PRE_first_tail_x6_r0_body.fkt011 PRE_first_tail_x6_r0_body.fkf111 PRE_first_tail_x6_r0_body.fkt111 PRE_first_tail_x6_r0_body.fkck11,
    pendReg_of rfl PRE_first_tail_x6_r0_body.cnh011 PRE_first_tail_x6_r0_body.cnh111 (Nat.le_of_ble_eq_true PRE_first_tail_x6_r0_body.cpendLe11) PRE_first_tail_x6_r0_body.cpendR11⟩

end Host.Load.Run.Tpl
end

section -- st11/H0
set_option Elab.async false
namespace Host.Load.Run.Tpl
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
host_stream_state PRE_first_tail_x6_r0_body.st11 0
host_stream_state PRE_first_tail_x6_r0_body.st11 1
host_stream_state PRE_first_tail_x6_r0_body.st11 2
end Host.Load.Run.Tpl
end

section -- Site11
set_option Elab.async false
namespace Host.Load.Run.Tpl
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
open Host.Ts Host.Ts.Sim Host.Ts.Sim.Template

/-! Call site 11 of chain `PRE_first_tail_x6_r0_body`: `plan__g11__g12` (`plan`), the call state `PRE_first_tail_x6_r0_body.s114`, the merged state `PRE_first_tail_x6_r0_body.s115`,
the site template `PRE_first_tail_x6_r0_body.st11` (σ = `Map.id`, θ the identity at its own site), the canonical state `PRE_first_tail_x6_r0_body.s116`: the merge.
The footprint's facts are in `SiteF11`, the compaction's in `SiteC11`, `SiteK11`, `SiteNa11`, `SiteNb11`. -/

kernel_rfl PRE_first_tail_x6_r0_body.iso11 : PRE_first_tail_x6_r0_body.st11.s0 = { PRE_first_tail_x6_r0_body.s114 with stack := [] }
/-- The caller's frames at the call. -/
noncomputable def PRE_first_tail_x6_r0_body.rs11 : List Frame := PRE_first_tail_x6_r0_body.s114.stack
kernel_rfl PRE_first_tail_x6_r0_body.n0_11 : PRE_first_tail_x6_r0_body.S114.tab.length = 523
kernel_rfl PRE_first_tail_x6_r0_body.tab0_11 : PRE_first_tail_x6_r0_body.st11.S0.tab = PRE_first_tail_x6_r0_body.S114.tab

/-- The fresh variables of the stage's results. -/
def PRE_first_tail_x6_r0_body.ws11 : List Nat := [1196, 1197, 1198]
kernel_rfl PRE_first_tail_x6_r0_body.fresh11 : (PRE_first_tail_x6_r0_body.S114.tab.all fun e => PRE_first_tail_x6_r0_body.ws11.all fun v => e.noVar v) &&
    (PRE_first_tail_x6_r0_body.S114.oracle.all fun q => PRE_first_tail_x6_r0_body.ws11.all fun v => q.noVar v) = true
kernel_rfl PRE_first_tail_x6_r0_body.mergeTab11 : PRE_first_tail_x6_r0_body.S115.tab = PRE_first_tail_x6_r0_body.S114.tab ++ Conv.resTab PRE_first_tail_x6_r0_body.ws11
kernel_rfl PRE_first_tail_x6_r0_body.mergeLen11 : PRE_first_tail_x6_r0_body.st11.S2.tab.length - PRE_first_tail_x6_r0_body.st11.S0.tab.length = 3

-- The merged state: the instance's return state with the caller's frames (`PRE_first_tail_x6_r0_body.merged11`, `merged_relB`).
kernel_rfl PRE_first_tail_x6_r0_body.mheap11 : PRE_first_tail_x6_r0_body.s115.heap = PRE_first_tail_x6_r0_body.st11.s2.heap
kernel_rfl PRE_first_tail_x6_r0_body.mnext11 : PRE_first_tail_x6_r0_body.s115.next = PRE_first_tail_x6_r0_body.st11.s2.next
kernel_rfl PRE_first_tail_x6_r0_body.mctl11 : PRE_first_tail_x6_r0_body.s115.ctl = PRE_first_tail_x6_r0_body.st11.s2.ctl
kernel_rfl PRE_first_tail_x6_r0_body.mstack11 : PRE_first_tail_x6_r0_body.s115.stack = PRE_first_tail_x6_r0_body.st11.s2.stack ++ PRE_first_tail_x6_r0_body.s114.stack
kernel_rfl PRE_first_tail_x6_r0_body.mjobs11 : PRE_first_tail_x6_r0_body.s115.jobs = PRE_first_tail_x6_r0_body.st11.s2.jobs
kernel_rfl PRE_first_tail_x6_r0_body.mffi11 : PRE_first_tail_x6_r0_body.s115.ffi = PRE_first_tail_x6_r0_body.st11.s2.ffi
kernel_rfl PRE_first_tail_x6_r0_body.mtrace11 : PRE_first_tail_x6_r0_body.s115.trace = PRE_first_tail_x6_r0_body.st11.s2.trace
kernel_rfl PRE_first_tail_x6_r0_body.mstores11 : PRE_first_tail_x6_r0_body.s115.stores = PRE_first_tail_x6_r0_body.st11.s2.stores

end Host.Load.Run.Tpl
end

section -- SiteD11
set_option Elab.async false
namespace Host.Load.Run.Tpl
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
open Host.Ts Host.Ts.Sim Host.Ts.Sim.Template

/-! The canonical results at call site 11 of chain `PRE_first_tail_x6_r0_body`: their values in the instance's end table, the references past
the call's table, the canonical variables apart from the stage's. -/

kernel_rfl PRE_first_tail_x6_r0_body.cderived11 : PRE_first_tail_x6_r0_body.nr11.map (fun r => nth? PRE_first_tail_x6_r0_body.st11.S2.tab r) =
  []
kernel_rfl PRE_first_tail_x6_r0_body.cnrLo11 : PRE_first_tail_x6_r0_body.nr11.all (Nat.ble 523) = true
kernel_rfl PRE_first_tail_x6_r0_body.cwsDisj11 : PRE_first_tail_x6_r0_body.cws11.all (fun c => !PRE_first_tail_x6_r0_body.ws11.contains c) = true
/-- The compaction's substitution: the canonical variables to their merged values, the stage's other fresh variables
to `0` (`Conv.compactθZ`). -/
noncomputable def PRE_first_tail_x6_r0_body.cthetaZ11 : Nat → SymE := Conv.compactθZ PRE_first_tail_x6_r0_body.cws11 PRE_first_tail_x6_r0_body.crs11 PRE_first_tail_x6_r0_body.ws11

end Host.Load.Run.Tpl
end

section -- st11/Foot
set_option Elab.async false
namespace Host.Load.Run.Tpl
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
open Host.Ts Host.Ts.Sim Host.Ts.Sim.Stage Host.Ts.Sim.Template

/-! The footprint of stage `PRE_first_tail_x6_r0_body.st11`'s site template (`Conv.StageFoot`, `Conv.NFoot`): every entry of the return
state other than the written and fresh ones is the start's (kernel evaluation of the equalities). -/

/-- The written heap ranges below the start's counter. -/
def PRE_first_tail_x6_r0_body.st11.wrR : List (Nat × Nat) := []
/-- The written and fresh entries of the return state. -/
noncomputable def PRE_first_tail_x6_r0_body.st11.wrE : List (Nat × Host.Ts.HObj) :=
  rangesOf PRE_first_tail_x6_r0_body.st11.s2.heap PRE_first_tail_x6_r0_body.st11.wrR ++ freshOf PRE_first_tail_x6_r0_body.st11.s2.heap PRE_first_tail_x6_r0_body.st11.s0.next PRE_first_tail_x6_r0_body.st11.s2.next
noncomputable def PRE_first_tail_x6_r0_body.st11.wr : List Nat := PRE_first_tail_x6_r0_body.st11.wrE.map (·.1)

kernel_rfl PRE_first_tail_x6_r0_body.st11.heapFoot : PRE_first_tail_x6_r0_body.st11.s2.heap = setAll PRE_first_tail_x6_r0_body.st11.s0.heap PRE_first_tail_x6_r0_body.st11.wrE
kernel_rfl PRE_first_tail_x6_r0_body.st11.grows_check : Nat.ble PRE_first_tail_x6_r0_body.st11.s0.next PRE_first_tail_x6_r0_body.st11.s2.next = true
theorem PRE_first_tail_x6_r0_body.st11.grows : PRE_first_tail_x6_r0_body.st11.s0.next ≤ PRE_first_tail_x6_r0_body.st11.s2.next := Nat.le_of_ble_eq_true PRE_first_tail_x6_r0_body.st11.grows_check

/-- The written and fresh handles; the written readback items of old nodes. -/
def PRE_first_tail_x6_r0_body.st11.wh : List Nat := []
def PRE_first_tail_x6_r0_body.st11.wi : List Nat := []

kernel_rfl PRE_first_tail_x6_r0_body.st11.arrsFoot : (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.st11.s2.ffi).mlx.arrs = setAll (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.st11.s0.ffi).mlx.arrs (PRE_first_tail_x6_r0_body.st11.wh.filterMap fun h => ((Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.st11.s2.ffi).mlx.arrs.get h).map (h, ·))
kernel_rfl PRE_first_tail_x6_r0_body.st11.objsFoot : (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.st11.s2.ffi).mlx.objs = setAll (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.st11.s0.ffi).mlx.objs (PRE_first_tail_x6_r0_body.st11.wh.filterMap fun h => ((Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.st11.s2.ffi).mlx.objs.get h).map (h, ·))
kernel_rfl PRE_first_tail_x6_r0_body.st11.nodesFoot : (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.st11.s2.ffi).mlx.nodes = setAll (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.st11.s0.ffi).mlx.nodes (freshOf (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.st11.s2.ffi).mlx.nodes (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.st11.s0.ffi).mlx.nnext (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.st11.s2.ffi).mlx.nnext)
kernel_rfl PRE_first_tail_x6_r0_body.st11.itemsFoot : (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.st11.s2.ffi).mlx.items = setAll (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.st11.s0.ffi).mlx.items ((PRE_first_tail_x6_r0_body.st11.wi.filterMap fun i => ((Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.st11.s2.ffi).mlx.items.get i).map (i, ·)) ++
    freshOf (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.st11.s2.ffi).mlx.items (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.st11.s0.ffi).mlx.nnext (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.st11.s2.ffi).mlx.nnext)
kernel_rfl PRE_first_tail_x6_r0_body.st11.counters : (Nat.ble (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.st11.s0.ffi).mlx.next (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.st11.s2.ffi).mlx.next && Nat.ble (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.st11.s0.ffi).mlx.nnext (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.st11.s2.ffi).mlx.nnext) = true

end Host.Load.Run.Tpl
end

section -- SiteF11
set_option Elab.async false
namespace Host.Load.Run.Tpl
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
open Host.Ts Host.Ts.Sim Host.Ts.Sim.Template

/-! Call site 11 of chain `PRE_first_tail_x6_r0_body`: `Conv.site_merge`'s footprint facts. -/

kernel_rfl PRE_first_tail_x6_r0_body.wrNodupB11 : nodupT PRE_first_tail_x6_r0_body.st11.wr PTrie.nil = true
theorem PRE_first_tail_x6_r0_body.wrNodup11 : PRE_first_tail_x6_r0_body.st11.wr.Nodup := (nodupT_sound PRE_first_tail_x6_r0_body.wrNodupB11).2
kernel_rfl PRE_first_tail_x6_r0_body.wrBoundB11 : PRE_first_tail_x6_r0_body.st11.wr.all (fun b => Nat.blt (b / 4096) (4 ^ 31)) = true
theorem PRE_first_tail_x6_r0_body.wrBound11 : ∀ b ∈ PRE_first_tail_x6_r0_body.st11.wr, b / 4096 < 4 ^ 31 := fun b hb => Nat.blt_eq.mp (List.all_eq_true.mp PRE_first_tail_x6_r0_body.wrBoundB11 b hb)
noncomputable def PRE_first_tail_x6_r0_body.trFr11 := PRE_first_tail_x6_r0_body.st11.s2.trace.take 0
kernel_rfl PRE_first_tail_x6_r0_body.traceEq11 : PRE_first_tail_x6_r0_body.st11.s2.trace = PRE_first_tail_x6_r0_body.trFr11 ++ PRE_first_tail_x6_r0_body.st11.s0.trace
theorem PRE_first_tail_x6_r0_body.trace11 : ∃ fr, PRE_first_tail_x6_r0_body.st11.s2.trace = fr ++ PRE_first_tail_x6_r0_body.st11.s0.trace := ⟨_, PRE_first_tail_x6_r0_body.traceEq11⟩

-- the caller's wide frames at the instance's start (`Conv.isolateW`'s `W0` under `Map.id`) and their `WFix`
def PRE_first_tail_x6_r0_body.wide11 : List (Nat × WFrame) := [(4910, .memo [])]
kernel_rfl PRE_first_tail_x6_r0_body.wfixB11 : (PRE_first_tail_x6_r0_body.wide11.all fun p => wfixB Map.id (presentB PRE_first_tail_x6_r0_body.st11.s0) p.2) = true
theorem PRE_first_tail_x6_r0_body.wfix11 : ∀ p ∈ PRE_first_tail_x6_r0_body.wide11, WFix Map.id (Present PRE_first_tail_x6_r0_body.st11.s0) p.2 :=
  fun p hp => wfix_of (List.all_eq_true.mp PRE_first_tail_x6_r0_body.wfixB11 p hp)

end Host.Load.Run.Tpl
end

section -- SiteL11
set_option Elab.async false
namespace Host.Load.Run.Tpl
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
open Host.Ts Host.Ts.Sim Host.Ts.Sim.Template

/-! The call link's facts at call site 11 of chain `PRE_first_tail_x6_r0_body`: the instance's start server, its footprint (`Conv.StageFoot`), the
merged state `PRE_first_tail_x6_r0_body.s115`'s framed arrays as the chain start's extended (`arrExt_of`, `numRefs_of`). -/

kernel_rfl PRE_first_tail_x6_r0_body.srvO11 : PRE_first_tail_x6_r0_body.st11.S0.oracle = PRE_first_tail_x6_r0_body.st11.OR
kernel_rfl PRE_first_tail_x6_r0_body.wr0B11 : PRE_first_tail_x6_r0_body.st11.wr.all (fun b => !Nat.blt b PRE_first_tail_x6_r0_body.st11.s0.next || (PRE_first_tail_x6_r0_body.st11.s0.heap.get b).isSome) = true
theorem PRE_first_tail_x6_r0_body.stFoot11 : Conv.StageFoot PRE_first_tail_x6_r0_body.st11.wr PRE_first_tail_x6_r0_body.st11.s0 PRE_first_tail_x6_r0_body.st11.s2 :=
  stageFoot_of PRE_first_tail_x6_r0_body.st11.heapFoot PRE_first_tail_x6_r0_body.wrNodup11 PRE_first_tail_x6_r0_body.wrBound11 PRE_first_tail_x6_r0_body.wr0B11 PRE_first_tail_x6_r0_body.st11.grows

/-- **The relation at the merged state** from the relation at the merge (`Conv.site_merge`'s; `merged_relB`). -/
theorem PRE_first_tail_x6_r0_body.merged11 {FR : Map → Nat → PRE_first_tail_x6_r0_body.st11.F.S → PRE_first_tail_x6_r0_body.st11.F.S → Prop} {W : Nat → Option WFrame} {stk : List Frame} {M : Map}
    {ν : Nat → F64} {K : Host.Ts.Sim.Ctx} {S : SSrv} {t : St PRE_first_tail_x6_r0_body.st11.F.S} {C : CSrv} {n0 : Nat}
    (h : RelB PRE_first_tail_x6_r0_body.st11.F FR W stk M ν K (Conv.mergeSt Map.id (Map.id.res n0 n0) PRE_first_tail_x6_r0_body.rs11 PRE_first_tail_x6_r0_body.st11.wr PRE_first_tail_x6_r0_body.s114 PRE_first_tail_x6_r0_body.st11.s2 PRE_first_tail_x6_r0_body.st11.s0
      PRE_first_tail_x6_r0_body.st11.s2.ffi) S t C) : RelB PRE_first_tail_x6_r0_body.st11.F FR W stk M ν K PRE_first_tail_x6_r0_body.s115 S t C :=
  merged_relB PRE_first_tail_x6_r0_body.iso11 PRE_first_tail_x6_r0_body.stFoot11 PRE_first_tail_x6_r0_body.wrNodup11 PRE_first_tail_x6_r0_body.wrBound11 PRE_first_tail_x6_r0_body.trace11 PRE_first_tail_x6_r0_body.mheap11
    PRE_first_tail_x6_r0_body.mnext11 PRE_first_tail_x6_r0_body.mctl11 PRE_first_tail_x6_r0_body.mstack11 PRE_first_tail_x6_r0_body.mjobs11 PRE_first_tail_x6_r0_body.mffi11 PRE_first_tail_x6_r0_body.mtrace11 PRE_first_tail_x6_r0_body.mstores11 h

def PRE_first_tail_x6_r0_body.arrEl11_2665 : List Val := []
kernel_rfl PRE_first_tail_x6_r0_body.arrE11_2665 : arrOf PRE_first_tail_x6_r0_body.s115 2665 = arrOf PRE_first_tail_x6_r0_body.s0 2665 ++ PRE_first_tail_x6_r0_body.arrEl11_2665
kernel_rfl PRE_first_tail_x6_r0_body.arrA11_2665 : isArrB PRE_first_tail_x6_r0_body.s115 2665 = true
theorem PRE_first_tail_x6_r0_body.arr11_2665 : ∃ o, PRE_first_tail_x6_r0_body.s115.heap.get 2665 = some (.obj o) ∧ o.kind = .array (arrOf PRE_first_tail_x6_r0_body.s0 2665 ++ PRE_first_tail_x6_r0_body.arrEl11_2665) :=
  arrExt_of PRE_first_tail_x6_r0_body.arrE11_2665 PRE_first_tail_x6_r0_body.arrA11_2665
kernel_rfl PRE_first_tail_x6_r0_body.arrN11_2665 : numRefsB PRE_first_tail_x6_r0_body.S0.tab.length PRE_first_tail_x6_r0_body.arrEl11_2665 = true
theorem PRE_first_tail_x6_r0_body.arrR11_2665 : Prefill.NumRefs PRE_first_tail_x6_r0_body.S0.tab.length PRE_first_tail_x6_r0_body.arrEl11_2665 := numRefs_of PRE_first_tail_x6_r0_body.arrN11_2665

def PRE_first_tail_x6_r0_body.arrEl11_2673467 : List Val := []
kernel_rfl PRE_first_tail_x6_r0_body.arrE11_2673467 : arrOf PRE_first_tail_x6_r0_body.s115 2673467 = arrOf PRE_first_tail_x6_r0_body.s0 2673467 ++ PRE_first_tail_x6_r0_body.arrEl11_2673467
kernel_rfl PRE_first_tail_x6_r0_body.arrA11_2673467 : isArrB PRE_first_tail_x6_r0_body.s115 2673467 = true
theorem PRE_first_tail_x6_r0_body.arr11_2673467 : ∃ o, PRE_first_tail_x6_r0_body.s115.heap.get 2673467 = some (.obj o) ∧ o.kind = .array (arrOf PRE_first_tail_x6_r0_body.s0 2673467 ++ PRE_first_tail_x6_r0_body.arrEl11_2673467) :=
  arrExt_of PRE_first_tail_x6_r0_body.arrE11_2673467 PRE_first_tail_x6_r0_body.arrA11_2673467
kernel_rfl PRE_first_tail_x6_r0_body.arrN11_2673467 : numRefsB PRE_first_tail_x6_r0_body.S0.tab.length PRE_first_tail_x6_r0_body.arrEl11_2673467 = true
theorem PRE_first_tail_x6_r0_body.arrR11_2673467 : Prefill.NumRefs PRE_first_tail_x6_r0_body.S0.tab.length PRE_first_tail_x6_r0_body.arrEl11_2673467 := numRefs_of PRE_first_tail_x6_r0_body.arrN11_2673467

kernel_rfl PRE_first_tail_x6_r0_body.w4910k11 : isArrB PRE_first_tail_x6_r0_body.s115 4910 = false
theorem PRE_first_tail_x6_r0_body.keep11 (q : List Val) : Host.Ts.Sim.Prefill.KeepsAtW (framesP PRE_first_tail_x6_r0_body.s0 q) PRE_first_tail_x6_r0_body.s115 := by
  intro a pre pre' hx o es ho hk
  unfold framesP at hx
  simp only at hx
  cases h1 : Nat.beq a 2665
  · cases h2 : Nat.beq a 4910
    · rw [h1, h2] at hx; cases hx
    · have := Nat.eq_of_beq_eq_true h2; subst this
      rw [h1, h2] at hx; cases hx
      exact (notArr_of PRE_first_tail_x6_r0_body.w4910k11 ho hk).elim
  · have := Nat.eq_of_beq_eq_true h1; subst this
    rw [h1] at hx; cases hx
    obtain ⟨o', ho', hk'⟩ := PRE_first_tail_x6_r0_body.arr11_2665
    rw [ho] at ho'; cases ho'
    rw [hk'] at hk; cases hk
    simp [PRE_first_tail_x6_r0_body.arrEl11_2665]

end Host.Load.Run.Tpl
end

section -- SiteZ11
set_option Elab.async false
namespace Host.Load.Run.Tpl
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
open Host.Ts Host.Ts.Sim Host.Ts.Sim.Template

/-! The compaction's state shift at call site 11 of chain `PRE_first_tail_x6_r0_body` (`Conv.compact_shift`): the call `PRE_first_tail_x6_r0_body.s114`, the merged
state `PRE_first_tail_x6_r0_body.s115`, the canonical state `PRE_first_tail_x6_r0_body.s116`; its frames [2665,2673467,2673472,2673473] (kept arrays [2665,2673467]). -/

-- the map's places and counters
kernel_rfl PRE_first_tail_x6_r0_body.zpl11 : PRE_first_tail_x6_r0_body.pl11.all (Nat.ble PRE_first_tail_x6_r0_body.s114.next) = true
kernel_rfl PRE_first_tail_x6_r0_body.zplnd11 : nodupT PRE_first_tail_x6_r0_body.pl11 PTrie.nil = true
kernel_rfl PRE_first_tail_x6_r0_body.zn111 : Nat.ble PRE_first_tail_x6_r0_body.s114.next 2683392 = true
kernel_rfl PRE_first_tail_x6_r0_body.zfirst11 : Nat.ble aFirst PRE_first_tail_x6_r0_body.s114.next = true
kernel_rfl PRE_first_tail_x6_r0_body.zscn11 : PRE_first_tail_x6_r0_body.s116.next = PRE_first_tail_x6_r0_body.s114.next + PRE_first_tail_x6_r0_body.pl11.length
kernel_rfl PRE_first_tail_x6_r0_body.zsmn11 : PRE_first_tail_x6_r0_body.s115.next = 2683392
kernel_rfl PRE_first_tail_x6_r0_body.zgrow11 : Nat.ble PRE_first_tail_x6_r0_body.s116.next PRE_first_tail_x6_r0_body.s115.next = true
-- the tables
kernel_rfl PRE_first_tail_x6_r0_body.zfresh11 : PRE_first_tail_x6_r0_body.S114.tab.all (fun e => PRE_first_tail_x6_r0_body.cws11.all fun v => e.noVar v) = true
kernel_rfl PRE_first_tail_x6_r0_body.zcnd11 : nodupT PRE_first_tail_x6_r0_body.cws11 PTrie.nil = true
kernel_rfl PRE_first_tail_x6_r0_body.znrHi11 : PRE_first_tail_x6_r0_body.nr11.all (fun r => Nat.blt r PRE_first_tail_x6_r0_body.S115.tab.length) = true
-- the frames: every framed address below the call's counter; the kept arrays the chain start's, extended in the merged state
kernel_rfl PRE_first_tail_x6_r0_body.zfrlt11 : [2665, 2673467, 2673472, 2673473].all (fun a => Nat.blt a PRE_first_tail_x6_r0_body.s114.next) = true
kernel_rfl PRE_first_tail_x6_r0_body.zg11_2665 : PRE_first_tail_x6_r0_body.s116.heap.get 2665 = some (.obj (objOf PRE_first_tail_x6_r0_body.s116 2665))
kernel_rfl PRE_first_tail_x6_r0_body.zk11_2665 : (objOf PRE_first_tail_x6_r0_body.s116 2665).kind = .array (arrOf PRE_first_tail_x6_r0_body.s0 2665)
kernel_rfl PRE_first_tail_x6_r0_body.zm11_2665 : PRE_first_tail_x6_r0_body.s115.heap.get 2665 = some (.obj { PRE_first_tail_x6_r0_body.kappa11.obj (objOf PRE_first_tail_x6_r0_body.s116 2665) with
  kind := .array (arrOf PRE_first_tail_x6_r0_body.s0 2665 ++ (arrOf PRE_first_tail_x6_r0_body.s115 2665).drop (arrOf PRE_first_tail_x6_r0_body.s0 2665).length) })
kernel_rfl PRE_first_tail_x6_r0_body.zg11_2673467 : PRE_first_tail_x6_r0_body.s116.heap.get 2673467 = some (.obj (objOf PRE_first_tail_x6_r0_body.s116 2673467))
kernel_rfl PRE_first_tail_x6_r0_body.zk11_2673467 : (objOf PRE_first_tail_x6_r0_body.s116 2673467).kind = .array (arrOf PRE_first_tail_x6_r0_body.s0 2673467)
kernel_rfl PRE_first_tail_x6_r0_body.zm11_2673467 : PRE_first_tail_x6_r0_body.s115.heap.get 2673467 = some (.obj { PRE_first_tail_x6_r0_body.kappa11.obj (objOf PRE_first_tail_x6_r0_body.s116 2673467) with
  kind := .array (arrOf PRE_first_tail_x6_r0_body.s0 2673467 ++ (arrOf PRE_first_tail_x6_r0_body.s115 2673467).drop (arrOf PRE_first_tail_x6_r0_body.s0 2673467).length) })
kernel_rfl PRE_first_tail_x6_r0_body.zw11_4910 : (PRE_first_tail_x6_r0_body.s116.heap.get 4910).isSome = true
kernel_rfl PRE_first_tail_x6_r0_body.zw11_2673472 : (PRE_first_tail_x6_r0_body.s116.heap.get 2673472).isSome = true
kernel_rfl PRE_first_tail_x6_r0_body.zw11_2673473 : (PRE_first_tail_x6_r0_body.s116.heap.get 2673473).isSome = true
-- the heap: the changed list in range, holding the stage's written and fresh addresses; the canonical side's image
kernel_rfl PRE_first_tail_x6_r0_body.zclbd11 : PRE_first_tail_x6_r0_body.cl11.all (fun b => Nat.blt (b / 4096) (4 ^ 31)) = true
kernel_rfl PRE_first_tail_x6_r0_body.zwr11 : PRE_first_tail_x6_r0_body.st11.wr.all (fun b => !Nat.blt b PRE_first_tail_x6_r0_body.s114.next || PRE_first_tail_x6_r0_body.cl11.contains b) = true
def PRE_first_tail_x6_r0_body.zl11 : List Nat := PRE_first_tail_x6_r0_body.cl11.filter fun a => !(List.contains [2665, 2673467] a)
kernel_rfl PRE_first_tail_x6_r0_body.zimgE11 : PRE_first_tail_x6_r0_body.zl11.map (fun a => PRE_first_tail_x6_r0_body.s115.heap.get (PRE_first_tail_x6_r0_body.kappa11.a a)) = PRE_first_tail_x6_r0_body.zl11.map (fun a => (PRE_first_tail_x6_r0_body.s116.heap.get a).map PRE_first_tail_x6_r0_body.kappa11.hobj)
theorem PRE_first_tail_x6_r0_body.zimg11 : HeapImg PRE_first_tail_x6_r0_body.kappa11 PRE_first_tail_x6_r0_body.s116 PRE_first_tail_x6_r0_body.s115 PRE_first_tail_x6_r0_body.zl11 := PRE_first_tail_x6_r0_body.zimgE11
-- the roots and their supports
kernel_rfl PRE_first_tail_x6_r0_body.zctl11 : PRE_first_tail_x6_r0_body.s115.ctl = PRE_first_tail_x6_r0_body.kappa11.ctl PRE_first_tail_x6_r0_body.s116.ctl
kernel_rfl PRE_first_tail_x6_r0_body.zstack11 : PRE_first_tail_x6_r0_body.s115.stack = PRE_first_tail_x6_r0_body.s116.stack.map PRE_first_tail_x6_r0_body.kappa11.frame
kernel_rfl PRE_first_tail_x6_r0_body.zjobs11 : PRE_first_tail_x6_r0_body.s115.jobs = PRE_first_tail_x6_r0_body.s116.jobs.map PRE_first_tail_x6_r0_body.kappa11.job
kernel_rfl PRE_first_tail_x6_r0_body.zstores11 : PRE_first_tail_x6_r0_body.s115.stores = PRE_first_tail_x6_r0_body.kappa11.stores PRE_first_tail_x6_r0_body.s116.stores
kernel_rfl PRE_first_tail_x6_r0_body.zroots11 : checkRootsSupp PRE_first_tail_x6_r0_body.s116 523 = true
kernel_rfl PRE_first_tail_x6_r0_body.znC11 : PRE_first_tail_x6_r0_body.S114.tab.length + PRE_first_tail_x6_r0_body.cws11.length = 523
-- the map as `Conv.compact_shift` states it (the call's counters for the literals)
kernel_rfl PRE_first_tail_x6_r0_body.zkap11 : PRE_first_tail_x6_r0_body.kappa11 = Conv.Map.compact PRE_first_tail_x6_r0_body.s114.next 2683392 PRE_first_tail_x6_r0_body.S114.tab.length PRE_first_tail_x6_r0_body.pl11 (PRE_first_tail_x6_r0_body.nr11.map NumV.ref) PRE_first_tail_x6_r0_body.kd11.big
  PRE_first_tail_x6_r0_body.kd11.region PRE_first_tail_x6_r0_body.kd11.nodeF
-- the bridge inactive at the canonical state (`Conv.FullShiftQ.toX`; the merged state's bridge is the canonical's: cbridge)
theorem PRE_first_tail_x6_r0_body.zbin11 : (Host.Ts.Sim.Full.bridgeOf PRE_first_tail_x6_r0_body.s116.ffi).active = false := (Host.Load.Boot.replay_active Host.Load.Run.Prompt.P.oblog2818)
-- the JS bookkeeping's step (`Conv.JClean.step` over the changed list) and the canonical roots' bigint freedom
kernel_rfl PRE_first_tail_x6_r0_body.zjc11 : Conv.jcleanListB (⟨18417, 15496, 2683382, 523⟩ : Conv.Cnt) PRE_first_tail_x6_r0_body.s116 PRE_first_tail_x6_r0_body.cl11 = true
kernel_rfl PRE_first_tail_x6_r0_body.zrootsB11 : noBigRootsP (fun i => !Conv.oldBigB (⟨18417, 15496, 2683382, 523⟩ : Conv.Cnt) i) PRE_first_tail_x6_r0_body.s116.trace PRE_first_tail_x6_r0_body.s116 = true
kernel_rfl PRE_first_tail_x6_r0_body.zhm11 : Nat.ble (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.s0.ffi).mlx.nnext 15496 = true
theorem PRE_first_tail_x6_r0_body.cjcl11 (h : Conv.JClean (⟨18417, 15496, 2683381, 523⟩ : Conv.Cnt) PRE_first_tail_x6_r0_body.s114) : Conv.JClean (⟨18417, 15496, 2683382, 523⟩ : Conv.Cnt) PRE_first_tail_x6_r0_body.s116 :=
  Conv.JClean.step h (Conv.Cnt.le_of_leB PRE_first_tail_x6_r0_body.cle11)
    (Conv.heap_off_setAll PRE_first_tail_x6_r0_body.cheap11 fun a ha => Nat.blt_eq.mp (List.all_eq_true.mp PRE_first_tail_x6_r0_body.zclbd11 a ha)) PRE_first_tail_x6_r0_body.zjc11

end Host.Load.Run.Tpl
end

section -- st11/TypedLast
set_option Elab.async false
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
namespace Host.Load.Run.Tpl
open Host.Ts Host.Ts.Sim Host.Ts.Sim.Template

boot_rfl PRE_first_tail_x6_r0_body.st11.bodyLast from PRE_first_tail_x6_r0_body.st11.s1 to PRE_first_tail_x6_r0_body.st11.s2 :
  interpS (step PRE_first_tail_x6_r0_body.st11.F PRE_first_tail_x6_r0_body.st11.s1).run PRE_first_tail_x6_r0_body.st11.S1 = some (PRE_first_tail_x6_r0_body.st11.s2, PRE_first_tail_x6_r0_body.st11.S2)
kernel_rfl PRE_first_tail_x6_r0_body.st11.bodyHalt : isHalt PRE_first_tail_x6_r0_body.st11.s1.ctl = false
kernel_rfl PRE_first_tail_x6_r0_body.st11.bodyTopCheck : noBlockTop PRE_first_tail_x6_r0_body.st11.s2.stack = true

end Host.Load.Run.Tpl
end

section -- st11/TypedOk
set_option Elab.async false
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
namespace Host.Load.Run.Tpl
open Host.Ts Host.Ts.Sim Host.Ts.Sim.Template

noncomputable def PRE_first_tail_x6_r0_body.st11.bodyOkL (bytes : List Byte) (rows : Nat) : St PRE_first_tail_x6_r0_body.st11.F.S → SSrv → Bool :=
  okLocal (Host.Ts.Sim.Compose.VWFrames.bodyOk bytes rows)

noncomputable def PRE_first_tail_x6_r0_body.st11.bodyOkLN (bytes : List Byte) (rows : Nat) : St PRE_first_tail_x6_r0_body.st11.F.S → FSrv → Bool :=
  okLocalN (Host.Ts.Sim.Compose.VWFrames.bodyOkN bytes rows)

theorem PRE_first_tail_x6_r0_body.st11.bodyOkLN_ok (bytes : List Byte) (rows : Nat) (s : St PRE_first_tail_x6_r0_body.st11.F.S) (c : FSrv) (h : c.Wf) :
    PRE_first_tail_x6_r0_body.st11.bodyOkLN bytes rows s c = PRE_first_tail_x6_r0_body.st11.bodyOkL bytes rows s c.toS :=
  okLocalN_ok (Host.Ts.Sim.Compose.VWFrames.bodyOkN_ok bytes rows) s c h

kernel_rfl PRE_first_tail_x6_r0_body.st11.bodyAccepted0 :
  (fun (bytes : List Byte) (rows : Nat) => PRE_first_tail_x6_r0_body.st11.bodyOkL bytes rows PRE_first_tail_x6_r0_body.st11.s0 PRE_first_tail_x6_r0_body.st11.S0) = fun _ _ => true

kernel_rfl PRE_first_tail_x6_r0_body.st11.bodyAccepted1 :
  (fun (bytes : List Byte) (rows : Nat) => PRE_first_tail_x6_r0_body.st11.bodyOkL bytes rows PRE_first_tail_x6_r0_body.st11.s1 PRE_first_tail_x6_r0_body.st11.S1) = fun _ _ => true

end Host.Load.Run.Tpl
end

section -- st11/TypedK0
set_option Elab.async false
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
namespace Host.Load.Run.Tpl
open Host.Ts Host.Ts.Sim Host.Ts.Sim.Template

boot_rfl PRE_first_tail_x6_r0_body.st11.bodyK0F from PRE_first_tail_x6_r0_body.st11.s0 to PRE_first_tail_x6_r0_body.st11.s1 :
  (fun (bytes : List Byte) (rows : Nat) => runOkS PRE_first_tail_x6_r0_body.st11.F (PRE_first_tail_x6_r0_body.st11.bodyOkLN bytes rows)
    ((nth? PRE_first_tail_x6_r0_body.st11.ks 0).getD 0) PRE_first_tail_x6_r0_body.st11.s0 PRE_first_tail_x6_r0_body.st11.S0) = fun _ _ => some (PRE_first_tail_x6_r0_body.st11.s1, PRE_first_tail_x6_r0_body.st11.S1)
theorem PRE_first_tail_x6_r0_body.st11.bodyK0 :
  (fun (bytes : List Byte) (rows : Nat) => runOk PRE_first_tail_x6_r0_body.st11.F (PRE_first_tail_x6_r0_body.st11.bodyOkL bytes rows)
    ((nth? PRE_first_tail_x6_r0_body.st11.ks 0).getD 0) PRE_first_tail_x6_r0_body.st11.s0 PRE_first_tail_x6_r0_body.st11.S0) = fun _ _ => some (PRE_first_tail_x6_r0_body.st11.s1, PRE_first_tail_x6_r0_body.st11.S1) :=
  runOk_fun_of_runOkS PRE_first_tail_x6_r0_body.st11.bodyOkLN_ok PRE_first_tail_x6_r0_body.st11.bodyK0F
end Host.Load.Run.Tpl
end

section -- st11/TypedTpl
set_option Elab.async false
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
namespace Host.Load.Run.Tpl
open Host.Ts Host.Ts.Sim Host.Ts.Sim.Template

theorem PRE_first_tail_x6_r0_body.st11.bodyRun (bytes : List Byte) (rows : Nat) :
    runOk PRE_first_tail_x6_r0_body.st11.F (PRE_first_tail_x6_r0_body.st11.bodyOkL bytes rows) 98 PRE_first_tail_x6_r0_body.st11.s0 PRE_first_tail_x6_r0_body.st11.S0 = some (PRE_first_tail_x6_r0_body.st11.s1, PRE_first_tail_x6_r0_body.st11.S1) :=
  (congrFun (congrFun PRE_first_tail_x6_r0_body.st11.bodyK0 bytes) rows)

theorem PRE_first_tail_x6_r0_body.st11.bodyLocal (bytes : List Byte) (rows : Nat) : ∀ s S, PRE_first_tail_x6_r0_body.st11.bodyOkL bytes rows s S = true → Disp.localB s = true := okLocal_localB

noncomputable def PRE_first_tail_x6_r0_body.st11.bodyTpl (bytes : List Byte) (rows : Nat) : Host.Ts.Sim.Stage.StageTpl PRE_first_tail_x6_r0_body.st11.F (PRE_first_tail_x6_r0_body.st11.bodyOkL bytes rows) where
  s0 := PRE_first_tail_x6_r0_body.st11.s0
  S0 := PRE_first_tail_x6_r0_body.st11.S0
  s1 := PRE_first_tail_x6_r0_body.st11.s1
  S1 := PRE_first_tail_x6_r0_body.st11.S1
  s2 := PRE_first_tail_x6_r0_body.st11.s2
  S2 := PRE_first_tail_x6_r0_body.st11.S2
  n := 98
  ok0 := congrFun (congrFun PRE_first_tail_x6_r0_body.st11.bodyAccepted0 bytes) rows
  run := PRE_first_tail_x6_r0_body.st11.bodyRun bytes rows
  ok1 := congrFun (congrFun PRE_first_tail_x6_r0_body.st11.bodyAccepted1 bytes) rows
  halt := PRE_first_tail_x6_r0_body.st11.bodyHalt
  last := PRE_first_tail_x6_r0_body.st11.bodyLast
  top := noBlockTop_sound PRE_first_tail_x6_r0_body.st11.bodyTopCheck
end Host.Load.Run.Tpl
end

section -- SiteC12
set_option Elab.async false
namespace Host.Load.Run.Tpl
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
open Host.Ts Host.Ts.Sim Host.Ts.Sim.Template

/-! The compaction after the merge at call site 12 of chain `PRE_first_tail_x6_r0_body` (`Conv.compact`, `Conv.full_compactQ`): the canonical
state `PRE_first_tail_x6_r0_body.s133` (the stage's results at canonical places, its trace the call's) under `PRE_first_tail_x6_r0_body.kappa12` into the merged state
`PRE_first_tail_x6_r0_body.s132`. -/

def PRE_first_tail_x6_r0_body.pl12 : List Nat := [2685987, 2685162, 2685993, 2685989, 2685164, 2685995]
def PRE_first_tail_x6_r0_body.nr12 : List Nat := [626, 625, 601, 609, 614, 619, 624, 598, 599, 600, 607, 608, 596, 603, 604, 605, 606, 602]
/-- The native part of the compaction map (canonical → merged handles and nodes: its `big`, `region`, `nodeF`). -/
def PRE_first_tail_x6_r0_body.kd12 : RData :=
  ⟨2684881, 2686030, Stage.setAll PTrie.nil [(2684875, 2685987), (2684876, 2685162), (2684877, 2685993), (2684878, 2685989), (2684879, 2685164), (2684880, 2685995)], Stage.setAll PTrie.nil [(18452, 18478), (18453, 18456), (18454, 18479)],
   18455, 18480, 15542, 15542, Stage.setAll PTrie.nil [],
   Stage.setAll PTrie.nil [(596, .ref 626), (597, .ref 625), (598, .ref 601), (599, .ref 609), (600, .ref 614), (601, .ref 619), (602, .ref 624), (603, .ref 598), (604, .ref 599), (605, .ref 600), (606, .ref 607), (607, .ref 608), (608, .ref 596), (609, .ref 603), (610, .ref 604), (611, .ref 605), (612, .ref 606), (613, .ref 602)]⟩
/-- **The compaction map.** -/
noncomputable def PRE_first_tail_x6_r0_body.kappa12 : Map :=
  Conv.Map.compact 2684875 2686030 596 PRE_first_tail_x6_r0_body.pl12 (PRE_first_tail_x6_r0_body.nr12.map NumV.ref) PRE_first_tail_x6_r0_body.kd12.big
    PRE_first_tail_x6_r0_body.kd12.region PRE_first_tail_x6_r0_body.kd12.nodeF
/-- The canonical result variables and their images, the merged state's entries (`Conv.compactθ`). -/
def PRE_first_tail_x6_r0_body.cws12 : List Nat := [1230, 1231, 1232, 1233, 1234, 1235, 1236, 1237, 1238, 1239, 1240, 1241, 1242, 1243, 1244, 1245, 1246, 1247]
noncomputable def PRE_first_tail_x6_r0_body.crs12 : List SymE := PRE_first_tail_x6_r0_body.nr12.map fun r => (nth? PRE_first_tail_x6_r0_body.S132.tab r).getD (.var 0)
noncomputable def PRE_first_tail_x6_r0_body.ctheta12 : Nat → SymE := Conv.compactθ PRE_first_tail_x6_r0_body.cws12 PRE_first_tail_x6_r0_body.crs12
/-- The call's entries the stage wrote (renamed in the canonical state with the results). -/
def PRE_first_tail_x6_r0_body.wrB12 : List Nat := [2665, 2672331, 2673467, 2684049, 2684594, 2684850]

kernel_rfl PRE_first_tail_x6_r0_body.ctab12 : PRE_first_tail_x6_r0_body.S133.tab = PRE_first_tail_x6_r0_body.S131.tab ++ PRE_first_tail_x6_r0_body.cws12.map SymE.var
kernel_rfl PRE_first_tail_x6_r0_body.ctrace12 : PRE_first_tail_x6_r0_body.s133.trace = PRE_first_tail_x6_r0_body.s131.trace
kernel_rfl PRE_first_tail_x6_r0_body.cnext12 : PRE_first_tail_x6_r0_body.s133.next = 2684881
kernel_rfl PRE_first_tail_x6_r0_body.ccounters12 : ((Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.s133.ffi).mlx.next, (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.s133.ffi).mlx.nnext) = (18455, 15542)
-- the merged state's readback queue, carried to the canonical state (`Conv.FullShiftQ.tokens`, `tokSupp`)
kernel_rfl PRE_first_tail_x6_r0_body.cqueue12 : (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.s132.ffi).mlx.tokens = (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.s133.ffi).mlx.tokens.map PRE_first_tail_x6_r0_body.kappa12.nv
kernel_rfl PRE_first_tail_x6_r0_body.ctokSupp12 : (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.s133.ffi).mlx.tokens.all (bSN 614) = true
-- the written and the result entries carry no bigint of the canonical fresh band [next, E) and no fresh region
kernel_rfl PRE_first_tail_x6_r0_body.cclean12 : Conv.cleanListB 18455 131072 (fun r => Nat.ble 73820 r) PRE_first_tail_x6_r0_body.s133
    (PRE_first_tail_x6_r0_body.wrB12 ++ (List.range 6).map (2684875 + ·)) = true
kernel_rfl PRE_first_tail_x6_r0_body.cbigs12 : bigsOutB 18455 131072 (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.s133.ffi).mlx = true

end Host.Load.Run.Tpl
end

section -- SiteK12
set_option Elab.async false
namespace Host.Load.Run.Tpl
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
open Host.Ts Host.Ts.Sim Host.Ts.Sim.Template

/-! The canonical state's closedness from the call's (`Conv.closed_of_callB`, `Conv.sst_of_callB`): it keeps the call's entries
off the written and the result ones (`PRE_first_tail_x6_r0_body.cl12`; natively the written and result handles, the result nodes, the written
and result items), and those are checked. -/

def PRE_first_tail_x6_r0_body.cl12 : List Nat := [2665, 2672331, 2673467, 2684049, 2684594, 2684850, 2684875, 2684876, 2684877, 2684878, 2684879, 2684880]
def PRE_first_tail_x6_r0_body.clo12 : List Nat := [18432, 18445, 18451, 18452, 18453, 18454]
def PRE_first_tail_x6_r0_body.cln12 : List Nat := [15515, 15516, 15517, 15518, 15519, 15520, 15521, 15522, 15523, 15524, 15525, 15526, 15527, 15528, 15529, 15530, 15531, 15532, 15533, 15534, 15535, 15536, 15537, 15538, 15539, 15540, 15541]
def PRE_first_tail_x6_r0_body.cli12 : List Nat := [15515, 15516, 15517, 15518, 15519, 15520, 15521, 15522, 15523, 15524, 15525, 15526, 15527, 15528, 15529, 15530, 15531, 15532, 15533, 15534, 15535, 15536, 15537, 15538, 15539, 15540, 15541]
kernel_rfl PRE_first_tail_x6_r0_body.cheap12 : PRE_first_tail_x6_r0_body.s133.heap = Stage.setAll PRE_first_tail_x6_r0_body.s131.heap (PRE_first_tail_x6_r0_body.cl12.filterMap fun a => (PRE_first_tail_x6_r0_body.s133.heap.get a).map (a, ·))
kernel_rfl PRE_first_tail_x6_r0_body.cnextLe12 : Nat.ble PRE_first_tail_x6_r0_body.s131.next PRE_first_tail_x6_r0_body.s133.next = true
kernel_rfl PRE_first_tail_x6_r0_body.ckeepP12 : Conv.keptPresentB PRE_first_tail_x6_r0_body.s131 PRE_first_tail_x6_r0_body.s133 PRE_first_tail_x6_r0_body.cl12 = true
kernel_rfl PRE_first_tail_x6_r0_body.csupp12 : Conv.suppListB PRE_first_tail_x6_r0_body.s133 614 PRE_first_tail_x6_r0_body.cl12 = true
kernel_rfl PRE_first_tail_x6_r0_body.cbound12 : Conv.boundListB PRE_first_tail_x6_r0_body.s133 PRE_first_tail_x6_r0_body.cl12 = true
kernel_rfl PRE_first_tail_x6_r0_body.cnodesK12 : (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.s133.ffi).mlx.nodes = Stage.setAll (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.s131.ffi).mlx.nodes (PRE_first_tail_x6_r0_body.cln12.filterMap fun i => ((Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.s133.ffi).mlx.nodes.get i).map (i, ·))
kernel_rfl PRE_first_tail_x6_r0_body.cobjsK12 : (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.s133.ffi).mlx.objs = Stage.setAll (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.s131.ffi).mlx.objs (PRE_first_tail_x6_r0_body.clo12.filterMap fun i => ((Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.s133.ffi).mlx.objs.get i).map (i, ·))
kernel_rfl PRE_first_tail_x6_r0_body.citemsK12 : (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.s133.ffi).mlx.items = Stage.setAll (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.s131.ffi).mlx.items (PRE_first_tail_x6_r0_body.cli12.filterMap fun i => ((Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.s133.ffi).mlx.items.get i).map (i, ·))
kernel_rfl PRE_first_tail_x6_r0_body.csst12 : Conv.sstListB 614 (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.s133.ffi).mlx PRE_first_tail_x6_r0_body.cln12 PRE_first_tail_x6_r0_body.clo12 PRE_first_tail_x6_r0_body.cli12 = true

end Host.Load.Run.Tpl
end

section -- SiteCl12
set_option Elab.async false
namespace Host.Load.Run.Tpl
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
open Host.Ts Host.Ts.Sim Host.Ts.Sim.Template

kernel_rfl PRE_first_tail_x6_r0_body.ckA12 : (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.s133.ffi).mlx.arrs = Stage.setAll (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.s131.ffi).mlx.arrs (PRE_first_tail_x6_r0_body.clo12.filterMap fun i => ((Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.s133.ffi).mlx.arrs.get i).map (i, ·))
kernel_rfl PRE_first_tail_x6_r0_body.cbd12 : (PRE_first_tail_x6_r0_body.clo12 ++ PRE_first_tail_x6_r0_body.cln12 ++ PRE_first_tail_x6_r0_body.cli12).all (fun i => Nat.blt (i / 4096) (4 ^ 31)) = true
kernel_rfl PRE_first_tail_x6_r0_body.cle12 : Conv.Cnt.leB (⟨18452, 15515, 2684875, 596⟩ : Conv.Cnt) (⟨18455, 15542, 2684881, 614⟩ : Conv.Cnt) = true
kernel_rfl PRE_first_tail_x6_r0_body.cck12 : Conv.ncleanListB (⟨18455, 15542, 2684881, 614⟩ : Conv.Cnt) (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.s133.ffi).mlx PRE_first_tail_x6_r0_body.clo12 PRE_first_tail_x6_r0_body.cln12 PRE_first_tail_x6_r0_body.cli12 = true
theorem PRE_first_tail_x6_r0_body.cncl12 (h : Conv.NClean (⟨18452, 15515, 2684875, 596⟩ : Conv.Cnt) (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.s131.ffi).mlx) : Conv.NClean (⟨18455, 15542, 2684881, 614⟩ : Conv.Cnt) (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.s133.ffi).mlx :=
  Conv.NClean.stepKeep h PRE_first_tail_x6_r0_body.cle12 PRE_first_tail_x6_r0_body.ckA12 PRE_first_tail_x6_r0_body.cobjsK12 PRE_first_tail_x6_r0_body.cnodesK12 PRE_first_tail_x6_r0_body.citemsK12 PRE_first_tail_x6_r0_body.cbd12 PRE_first_tail_x6_r0_body.cck12

end Host.Load.Run.Tpl
end

section -- SiteS12
set_option Elab.async false
namespace Host.Load.Run.Tpl
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
open Host.Ts Host.Ts.Sim Host.Ts.Sim.Template

/-! The compaction's native shift at call site 12 from its footprint (`Conv.nshift_of_foot`), and the observers'
(`liveShift_foot`, `kernShift_foot`): `Conv.FullShiftQ` for `Conv.full_compactQ`, given the call's bookkeeping and its
relation's facts. -/

/-- The load parameters of the chain (band-free: its start's node counter as `NL` and `N0`). -/
def PRE_first_tail_x6_r0_body.Pc12 : LoadP := ⟨18151, 131072, 1099511627776, 15235, 15235, []⟩
/-- The site's band raised to the map's checked fixed-node prefix, including newly recorded closure traces. -/
def PRE_first_tail_x6_r0_body.P12 : LoadP := PRE_first_tail_x6_r0_body.Pc12.raise 15542
kernel_rfl PRE_first_tail_x6_r0_body.craise12 : Nat.ble PRE_first_tail_x6_r0_body.Pc12.N0 15542 = true
theorem PRE_first_tail_x6_r0_body.raised12 : Host.Ts.Sim.Full.Raised PRE_first_tail_x6_r0_body.Pc12 PRE_first_tail_x6_r0_body.P12 :=
  .inr ⟨15542, rfl, Nat.le_of_ble_eq_true PRE_first_tail_x6_r0_body.craise12, rfl⟩
noncomputable abbrev PRE_first_tail_x6_r0_body.cx0_12 : Host.Load.LSt := clearTokens (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.s133.ffi)
noncomputable abbrev PRE_first_tail_x6_r0_body.cx1_12 : Host.Load.LSt := clearTokens (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.s132.ffi)
def PRE_first_tail_x6_r0_body.khinv12 : PTrie Nat := Stage.setAll PTrie.nil [(18478, 18452), (18456, 18453), (18479, 18454)]
def PRE_first_tail_x6_r0_body.kninv12 : PTrie Nat := Stage.setAll PTrie.nil [(15515, 15515), (15516, 15516), (15517, 15517), (15518, 15518), (15519, 15519), (15520, 15520), (15521, 15521), (15522, 15522), (15523, 15523), (15524, 15524), (15525, 15525), (15526, 15526), (15527, 15527), (15528, 15528), (15529, 15529), (15530, 15530), (15531, 15531), (15532, 15532), (15533, 15533), (15534, 15534), (15535, 15535), (15536, 15536), (15537, 15537), (15538, 15538), (15539, 15539), (15540, 15540), (15541, 15541)]
/-- The stage's footprint: its written and fresh handles, fresh nodes, written and fresh items. -/
def PRE_first_tail_x6_r0_body.cwS12 : List Nat := [18432, 18445, 18451, 18452, 18453, 18454, 18455, 18456, 18457, 18458, 18459, 18460, 18461, 18462, 18463, 18464, 18465, 18466, 18467, 18468, 18469, 18470, 18471, 18472, 18473, 18474, 18475, 18476, 18477, 18478, 18479]
def PRE_first_tail_x6_r0_body.cnS12 : List Nat := List.range' 15515 27
def PRE_first_tail_x6_r0_body.ciS12 : List Nat := [] ++ List.range' 15515 27

-- the small checks (`MChecks`'s)
kernel_rfl PRE_first_tail_x6_r0_body.cnh012 : PRE_first_tail_x6_r0_body.kd12.nh0 = PRE_first_tail_x6_r0_body.cx0_12.mlx.next
kernel_rfl PRE_first_tail_x6_r0_body.cnh112 : PRE_first_tail_x6_r0_body.kd12.nh1 = PRE_first_tail_x6_r0_body.cx1_12.mlx.next
kernel_rfl PRE_first_tail_x6_r0_body.cnn012 : PRE_first_tail_x6_r0_body.kd12.nn0 = PRE_first_tail_x6_r0_body.cx0_12.mlx.nnext
kernel_rfl PRE_first_tail_x6_r0_body.cnn112 : PRE_first_tail_x6_r0_body.kd12.nn1 = PRE_first_tail_x6_r0_body.cx1_12.mlx.nnext
kernel_rfl PRE_first_tail_x6_r0_body.cplo12 : (Nat.blt 0 PRE_first_tail_x6_r0_body.P12.lo && Nat.ble PRE_first_tail_x6_r0_body.P12.lo PRE_first_tail_x6_r0_body.cx0_12.mlx.next && Nat.ble PRE_first_tail_x6_r0_body.P12.lo RData.bigHi && Nat.ble RData.bigHi PRE_first_tail_x6_r0_body.P12.E) = true
kernel_rfl PRE_first_tail_x6_r0_body.ccnt12 : (Nat.ble PRE_first_tail_x6_r0_body.cx0_12.mlx.next PRE_first_tail_x6_r0_body.cx1_12.mlx.next && Nat.ble PRE_first_tail_x6_r0_body.cx0_12.mlx.nnext PRE_first_tail_x6_r0_body.cx1_12.mlx.nnext) = true
kernel_rfl PRE_first_tail_x6_r0_body.cnband12 : (Nat.blt 0 PRE_first_tail_x6_r0_body.P12.NL && Nat.ble PRE_first_tail_x6_r0_body.P12.NL PRE_first_tail_x6_r0_body.P12.N0 && Nat.ble PRE_first_tail_x6_r0_body.P12.N0 PRE_first_tail_x6_r0_body.cx0_12.mlx.nnext) = true
kernel_rfl PRE_first_tail_x6_r0_body.chbelow12 : PRE_first_tail_x6_r0_body.kd12.checkHndBelow = true
kernel_rfl PRE_first_tail_x6_r0_body.chren12 : checkRenG PRE_first_tail_x6_r0_body.kd12.hnd PRE_first_tail_x6_r0_body.khinv12 (phB PRE_first_tail_x6_r0_body.cx0_12.mlx) = true
kernel_rfl PRE_first_tail_x6_r0_body.cband12 : PRE_first_tail_x6_r0_body.kd12.checkBand PRE_first_tail_x6_r0_body.P12.lo = true
kernel_rfl PRE_first_tail_x6_r0_body.cnh1pos12 : Nat.blt 0 PRE_first_tail_x6_r0_body.kd12.nh1 = true
kernel_rfl PRE_first_tail_x6_r0_body.cnren12 : checkRenG PRE_first_tail_x6_r0_body.kd12.node PRE_first_tail_x6_r0_body.kninv12 (pnB PRE_first_tail_x6_r0_body.cx0_12.mlx) = true
kernel_rfl PRE_first_tail_x6_r0_body.cnlow12 : (PTrie.keysA PRE_first_tail_x6_r0_body.kd12.node).all (fun j => Nat.ble PRE_first_tail_x6_r0_body.P12.NL j && Nat.blt (PRE_first_tail_x6_r0_body.kd12.nodeF j) PRE_first_tail_x6_r0_body.cx1_12.mlx.nnext) = true
kernel_rfl PRE_first_tail_x6_r0_body.cabs0a12 : PRE_first_tail_x6_r0_body.cx0_12.mlx.arrs.get 0 = none
kernel_rfl PRE_first_tail_x6_r0_body.cabs0b12 : PRE_first_tail_x6_r0_body.cx0_12.mlx.objs.get 0 = none
kernel_rfl PRE_first_tail_x6_r0_body.ctok112 : PRE_first_tail_x6_r0_body.cx1_12.mlx.tokens = []
kernel_rfl PRE_first_tail_x6_r0_body.cpend12 : PRE_first_tail_x6_r0_body.cx1_12.mlx.pending = PRE_first_tail_x6_r0_body.cx0_12.mlx.pending.map PRE_first_tail_x6_r0_body.kappa12.pend
kernel_rfl PRE_first_tail_x6_r0_body.cerrh12 : PRE_first_tail_x6_r0_body.cx1_12.mlx.errh = PRE_first_tail_x6_r0_body.cx0_12.mlx.errh.map PRE_first_tail_x6_r0_body.kappa12.arg
kernel_rfl PRE_first_tail_x6_r0_body.cfiles12 : PRE_first_tail_x6_r0_body.cx1_12.mlx.files = PRE_first_tail_x6_r0_body.cx0_12.mlx.files
kernel_rfl PRE_first_tail_x6_r0_body.carch12 : PRE_first_tail_x6_r0_body.cx1_12.mlx.arch = PRE_first_tail_x6_r0_body.cx0_12.mlx.arch
kernel_rfl PRE_first_tail_x6_r0_body.csizes12 : PRE_first_tail_x6_r0_body.cx1_12.mlx.deviceSizes = PRE_first_tail_x6_r0_body.cx0_12.mlx.deviceSizes
kernel_rfl PRE_first_tail_x6_r0_body.cwired12 : PRE_first_tail_x6_r0_body.cx1_12.mlx.wired = PRE_first_tail_x6_r0_body.cx0_12.mlx.wired
kernel_rfl PRE_first_tail_x6_r0_body.chost12 : PRE_first_tail_x6_r0_body.cx1_12.host = PRE_first_tail_x6_r0_body.cx0_12.host
-- the compaction map's addresses are `PRE_first_tail_x6_r0_body.kd12`'s
kernel_rfl PRE_first_tail_x6_r0_body.ckn012 : PRE_first_tail_x6_r0_body.kd12.n0 = 2684881
kernel_rfl PRE_first_tail_x6_r0_body.ckn112 : PRE_first_tail_x6_r0_body.kd12.n1 = 2686030
kernel_rfl PRE_first_tail_x6_r0_body.ckheap12 : (PTrie.keysA PRE_first_tail_x6_r0_body.kd12.heap).all (fun x => Nat.ble 2684875 x) = true
kernel_rfl PRE_first_tail_x6_r0_body.ckpl12 : (List.range 6).all (fun j => decide (PRE_first_tail_x6_r0_body.kd12.heap.get (2684875 + j) = nth? PRE_first_tail_x6_r0_body.pl12 j)) = true
-- the map fixes the call's names (`Conv.fixOld_compact`), the call's counters
kernel_rfl PRE_first_tail_x6_r0_body.fja12 : Nat.ble 2684875 2684875 = true
kernel_rfl PRE_first_tail_x6_r0_body.fn12 : Nat.ble 596 596 = true
kernel_rfl PRE_first_tail_x6_r0_body.fjaD12 : Nat.ble 2684875 PRE_first_tail_x6_r0_body.kd12.n0 = true
kernel_rfl PRE_first_tail_x6_r0_body.fxn12 : Nat.ble 18452 PRE_first_tail_x6_r0_body.kd12.nh0 = true
kernel_rfl PRE_first_tail_x6_r0_body.fnn12 : Nat.ble 15515 PRE_first_tail_x6_r0_body.kd12.nn0 = true
kernel_rfl PRE_first_tail_x6_r0_body.fxb12 : Nat.ble 18452 RData.bigHi = true
kernel_rfl PRE_first_tail_x6_r0_body.fheap12 : (PTrie.keysA PRE_first_tail_x6_r0_body.kd12.heap).all (Nat.ble (⟨18452, 15515, 2684875, 596⟩ : Conv.Cnt).ja) = true
kernel_rfl PRE_first_tail_x6_r0_body.fhnd12 : (PTrie.keysA PRE_first_tail_x6_r0_body.kd12.hnd).all (Nat.ble (⟨18452, 15515, 2684875, 596⟩ : Conv.Cnt).xn) = true
kernel_rfl PRE_first_tail_x6_r0_body.fnode12 : (PTrie.keysA PRE_first_tail_x6_r0_body.kd12.node).all (Nat.ble (⟨18452, 15515, 2684875, 596⟩ : Conv.Cnt).nn) = true
/-- The compaction map fixes the call's names. -/
theorem PRE_first_tail_x6_r0_body.cfix12 : Conv.FixOld (⟨18452, 15515, 2684875, 596⟩ : Conv.Cnt) PRE_first_tail_x6_r0_body.kappa12 :=
  Conv.fixOld_compact (Nat.le_of_ble_eq_true PRE_first_tail_x6_r0_body.fja12) (Nat.le_of_ble_eq_true PRE_first_tail_x6_r0_body.fn12) (Nat.le_of_ble_eq_true PRE_first_tail_x6_r0_body.fjaD12) (Nat.le_of_ble_eq_true PRE_first_tail_x6_r0_body.fxn12) (Nat.le_of_ble_eq_true PRE_first_tail_x6_r0_body.fnn12) (Nat.le_of_ble_eq_true PRE_first_tail_x6_r0_body.fxb12) PRE_first_tail_x6_r0_body.fheap12 PRE_first_tail_x6_r0_body.fhnd12 PRE_first_tail_x6_r0_body.fnode12
kernel_rfl PRE_first_tail_x6_r0_body.fcxn12 : (⟨18452, 15515, 2684875, 596⟩ : Conv.Cnt).xn = (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.s131.ffi).mlx.next
kernel_rfl PRE_first_tail_x6_r0_body.fcnn12 : (⟨18452, 15515, 2684875, 596⟩ : Conv.Cnt).nn = (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.s131.ffi).mlx.nnext
kernel_rfl PRE_first_tail_x6_r0_body.fle012 : (Nat.ble (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.s131.ffi).mlx.next PRE_first_tail_x6_r0_body.cx0_12.mlx.next && Nat.ble (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.s131.ffi).mlx.nnext PRE_first_tail_x6_r0_body.cx0_12.mlx.nnext && Nat.ble (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.s131.ffi).mlx.next RData.bigHi) = true
kernel_rfl PRE_first_tail_x6_r0_body.fnk12 : (PTrie.keysA PRE_first_tail_x6_r0_body.kd12.node).all (Nat.ble (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.s131.ffi).mlx.nnext) = true
-- the merged state keeps the call's entries off the stage's footprint
kernel_rfl PRE_first_tail_x6_r0_body.f1A12 : PRE_first_tail_x6_r0_body.cx1_12.mlx.arrs = Stage.setAll (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.s131.ffi).mlx.arrs (PRE_first_tail_x6_r0_body.cwS12.filterMap fun i => (PRE_first_tail_x6_r0_body.cx1_12.mlx.arrs.get i).map (i, ·))
kernel_rfl PRE_first_tail_x6_r0_body.f1O12 : PRE_first_tail_x6_r0_body.cx1_12.mlx.objs = Stage.setAll (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.s131.ffi).mlx.objs (PRE_first_tail_x6_r0_body.cwS12.filterMap fun i => (PRE_first_tail_x6_r0_body.cx1_12.mlx.objs.get i).map (i, ·))
kernel_rfl PRE_first_tail_x6_r0_body.f1N12 : PRE_first_tail_x6_r0_body.cx1_12.mlx.nodes = Stage.setAll (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.s131.ffi).mlx.nodes (PRE_first_tail_x6_r0_body.cnS12.filterMap fun i => (PRE_first_tail_x6_r0_body.cx1_12.mlx.nodes.get i).map (i, ·))
kernel_rfl PRE_first_tail_x6_r0_body.f1I12 : PRE_first_tail_x6_r0_body.cx1_12.mlx.items = Stage.setAll (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.s131.ffi).mlx.items (PRE_first_tail_x6_r0_body.ciS12.filterMap fun i => (PRE_first_tail_x6_r0_body.cx1_12.mlx.items.get i).map (i, ·))
kernel_rfl PRE_first_tail_x6_r0_body.fbd12 : (PRE_first_tail_x6_r0_body.clo12 ++ PRE_first_tail_x6_r0_body.cln12 ++ PRE_first_tail_x6_r0_body.cli12 ++ PRE_first_tail_x6_r0_body.cwS12 ++ PRE_first_tail_x6_r0_body.cnS12 ++ PRE_first_tail_x6_r0_body.ciS12).all (fun i => Nat.blt (i / 4096) (4 ^ 31)) = true
kernel_rfl PRE_first_tail_x6_r0_body.fincW12 : PRE_first_tail_x6_r0_body.cwS12.all (fun h => !Nat.blt h (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.s131.ffi).mlx.next || PRE_first_tail_x6_r0_body.clo12.contains h) = true
kernel_rfl PRE_first_tail_x6_r0_body.fincI12 : PRE_first_tail_x6_r0_body.ciS12.all (fun k => !Nat.blt k (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.s131.ffi).mlx.nnext || PRE_first_tail_x6_r0_body.cli12.contains k) = true
kernel_rfl PRE_first_tail_x6_r0_body.fincN12 : PRE_first_tail_x6_r0_body.cnS12.all (Nat.ble (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.s131.ffi).mlx.nnext) = true
kernel_rfl PRE_first_tail_x6_r0_body.flnF12 : PRE_first_tail_x6_r0_body.cln12.all (Nat.ble (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.s131.ffi).mlx.nnext) = true
-- the checks over the changed lists
kernel_rfl PRE_first_tail_x6_r0_body.fh12 : PRE_first_tail_x6_r0_body.clo12.all (handleOK PRE_first_tail_x6_r0_body.kappa12 PRE_first_tail_x6_r0_body.P12.lo PRE_first_tail_x6_r0_body.cx0_12.mlx PRE_first_tail_x6_r0_body.cx1_12.mlx) = true
kernel_rfl PRE_first_tail_x6_r0_body.fo12 : PRE_first_tail_x6_r0_body.clo12.map (fun h => PRE_first_tail_x6_r0_body.cx1_12.mlx.objs.get (PRE_first_tail_x6_r0_body.kappa12.handle h)) = PRE_first_tail_x6_r0_body.clo12.map (fun h => (PRE_first_tail_x6_r0_body.cx0_12.mlx.objs.get h).map PRE_first_tail_x6_r0_body.kappa12.nobj)
kernel_rfl PRE_first_tail_x6_r0_body.fok12 : PRE_first_tail_x6_r0_body.clo12.all (objOK PRE_first_tail_x6_r0_body.kappa12 PRE_first_tail_x6_r0_body.P12.NL PRE_first_tail_x6_r0_body.cx0_12.mlx) = true
kernel_rfl PRE_first_tail_x6_r0_body.fnd12 : PRE_first_tail_x6_r0_body.cln12.all (nodeOKF PRE_first_tail_x6_r0_body.kappa12 PRE_first_tail_x6_r0_body.P12 PRE_first_tail_x6_r0_body.cx0_12.mlx PRE_first_tail_x6_r0_body.cx1_12.mlx) = true
kernel_rfl PRE_first_tail_x6_r0_body.fp12 : ((PRE_first_tail_x6_r0_body.cln12.filter (fullB PRE_first_tail_x6_r0_body.P12))).map (fun i => (PRE_first_tail_x6_r0_body.cx1_12.mlx.nodes.get (PRE_first_tail_x6_r0_body.kappa12.node i)).map Host.Mlx.Ffi.Node.prim) =
  ((PRE_first_tail_x6_r0_body.cln12.filter (fullB PRE_first_tail_x6_r0_body.P12))).map (fun i => (PRE_first_tail_x6_r0_body.cx0_12.mlx.nodes.get i).map fun nd => PRE_first_tail_x6_r0_body.kappa12.prim nd.prim)
kernel_rfl PRE_first_tail_x6_r0_body.fnordI12 : incrB PRE_first_tail_x6_r0_body.kd12.nodeF (List.range' 15515 27) = true
kernel_rfl PRE_first_tail_x6_r0_body.fnordK12 : (PTrie.keysA PRE_first_tail_x6_r0_body.kd12.node).all (fun k => Nat.ble 15515 k && Nat.blt k 15542) = true
kernel_rfl PRE_first_tail_x6_r0_body.fnordL12 : (PRE_first_tail_x6_r0_body.cln12.filter (Nat.ble PRE_first_tail_x6_r0_body.P12.N0)).all (fun i => Nat.ble i (PRE_first_tail_x6_r0_body.kd12.nodeF i) && (Nat.blt i 15542 || Nat.ble PRE_first_tail_x6_r0_body.kd12.nn0 i)) = true
theorem PRE_first_tail_x6_r0_body.fnord12 : (PRE_first_tail_x6_r0_body.cln12.filter (Nat.ble PRE_first_tail_x6_r0_body.P12.N0)).all (fun i => Nat.ble i (PRE_first_tail_x6_r0_body.kd12.nodeF i) &&
    (PTrie.keysA PRE_first_tail_x6_r0_body.kd12.node).all fun j => !Nat.blt j i || Nat.blt (PRE_first_tail_x6_r0_body.kd12.nodeF j) (PRE_first_tail_x6_r0_body.kd12.nodeF i)) = true :=
  cnord_of PRE_first_tail_x6_r0_body.cnlow12 PRE_first_tail_x6_r0_body.cnn112 PRE_first_tail_x6_r0_body.fnordI12 PRE_first_tail_x6_r0_body.fnordK12 PRE_first_tail_x6_r0_body.fnordL12
kernel_rfl PRE_first_tail_x6_r0_body.fi12 : PRE_first_tail_x6_r0_body.cli12.all (pnB PRE_first_tail_x6_r0_body.cx0_12.mlx) = true
kernel_rfl PRE_first_tail_x6_r0_body.fii12 : PRE_first_tail_x6_r0_body.cli12.all (fun k => decide (PRE_first_tail_x6_r0_body.cx1_12.mlx.items.get (PRE_first_tail_x6_r0_body.kappa12.node k) = (PRE_first_tail_x6_r0_body.cx0_12.mlx.items.get k).map PRE_first_tail_x6_r0_body.kappa12.nv)) = true
/-- **The compaction's footprint.** -/
theorem PRE_first_tail_x6_r0_body.cfoot12 (clean : Conv.NClean (⟨18452, 15515, 2684875, 596⟩ : Conv.Cnt) (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.s131.ffi).mlx) (hltC : ∀ h, PH (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.s131.ffi).mlx h → h < (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.s131.ffi).mlx.next) (nltC : ∀ i, PN (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.s131.ffi).mlx i → i < (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.s131.ffi).mlx.nnext) (itemsC : ∀ k v, (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.s131.ffi).mlx.items.get k = some v → PN (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.s131.ffi).mlx k) (tracedC : ∀ h o, (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.s131.ffi).mlx.objs.get h = some o → ∀ i ∈ objTraces o, i < PRE_first_tail_x6_r0_body.P12.NL) (cl : SSt (· < 614) PRE_first_tail_x6_r0_body.cx0_12.mlx) :
    Conv.MFoot PRE_first_tail_x6_r0_body.P12 614 PRE_first_tail_x6_r0_body.kappa12 PRE_first_tail_x6_r0_body.kd12 PRE_first_tail_x6_r0_body.khinv12 PRE_first_tail_x6_r0_body.kninv12 (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.s131.ffi).mlx PRE_first_tail_x6_r0_body.cx0_12.mlx PRE_first_tail_x6_r0_body.cx1_12.mlx (⟨18452, 15515, 2684875, 596⟩ : Conv.Cnt) PRE_first_tail_x6_r0_body.clo12 PRE_first_tail_x6_r0_body.cln12 PRE_first_tail_x6_r0_body.cli12 PRE_first_tail_x6_r0_body.cwS12 PRE_first_tail_x6_r0_body.cnS12 PRE_first_tail_x6_r0_body.ciS12 :=
  ⟨rfl, rfl, rfl, PRE_first_tail_x6_r0_body.cnh012, PRE_first_tail_x6_r0_body.cnh112, PRE_first_tail_x6_r0_body.cnn012, PRE_first_tail_x6_r0_body.cnn112, PRE_first_tail_x6_r0_body.cplo12, PRE_first_tail_x6_r0_body.ccnt12, PRE_first_tail_x6_r0_body.cnband12, PRE_first_tail_x6_r0_body.chbelow12, PRE_first_tail_x6_r0_body.chren12, PRE_first_tail_x6_r0_body.cband12, PRE_first_tail_x6_r0_body.cnh1pos12, PRE_first_tail_x6_r0_body.cnren12, PRE_first_tail_x6_r0_body.cnlow12, PRE_first_tail_x6_r0_body.cabs0a12, PRE_first_tail_x6_r0_body.cabs0b12, PRE_first_tail_x6_r0_body.ctok112, PRE_first_tail_x6_r0_body.cpend12, PRE_first_tail_x6_r0_body.cerrh12, PRE_first_tail_x6_r0_body.cfiles12, PRE_first_tail_x6_r0_body.carch12, PRE_first_tail_x6_r0_body.csizes12, PRE_first_tail_x6_r0_body.cwired12, PRE_first_tail_x6_r0_body.cfix12, clean, PRE_first_tail_x6_r0_body.fcxn12, PRE_first_tail_x6_r0_body.fcnn12, hltC, nltC, itemsC, tracedC, cl, PRE_first_tail_x6_r0_body.fle012, PRE_first_tail_x6_r0_body.fnk12, PRE_first_tail_x6_r0_body.ckA12, PRE_first_tail_x6_r0_body.cobjsK12, PRE_first_tail_x6_r0_body.cnodesK12, PRE_first_tail_x6_r0_body.citemsK12, PRE_first_tail_x6_r0_body.f1A12, PRE_first_tail_x6_r0_body.f1O12, PRE_first_tail_x6_r0_body.f1N12, PRE_first_tail_x6_r0_body.f1I12, PRE_first_tail_x6_r0_body.fbd12, PRE_first_tail_x6_r0_body.fincW12, PRE_first_tail_x6_r0_body.fincI12, PRE_first_tail_x6_r0_body.fincN12, PRE_first_tail_x6_r0_body.flnF12, PRE_first_tail_x6_r0_body.fh12, PRE_first_tail_x6_r0_body.fo12, PRE_first_tail_x6_r0_body.fok12, PRE_first_tail_x6_r0_body.fnd12, PRE_first_tail_x6_r0_body.fp12, PRE_first_tail_x6_r0_body.fnord12, PRE_first_tail_x6_r0_body.fi12, PRE_first_tail_x6_r0_body.fii12⟩
theorem PRE_first_tail_x6_r0_body.cnshift12 (clean : Conv.NClean (⟨18452, 15515, 2684875, 596⟩ : Conv.Cnt) (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.s131.ffi).mlx) (hltC : ∀ h, PH (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.s131.ffi).mlx h → h < (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.s131.ffi).mlx.next) (nltC : ∀ i, PN (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.s131.ffi).mlx i → i < (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.s131.ffi).mlx.nnext) (itemsC : ∀ k v, (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.s131.ffi).mlx.items.get k = some v → PN (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.s131.ffi).mlx k) (tracedC : ∀ h o, (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.s131.ffi).mlx.objs.get h = some o → ∀ i ∈ objTraces o, i < PRE_first_tail_x6_r0_body.P12.NL) (cl : SSt (· < 614) PRE_first_tail_x6_r0_body.cx0_12.mlx) : NShift PRE_first_tail_x6_r0_body.P12 614 PRE_first_tail_x6_r0_body.kappa12 PRE_first_tail_x6_r0_body.cx0_12 PRE_first_tail_x6_r0_body.cx1_12 :=
  Conv.nshift_of_foot (PRE_first_tail_x6_r0_body.cfoot12 clean hltC nltC itemsC tracedC cl) PRE_first_tail_x6_r0_body.chost12 (compact_a_eq PRE_first_tail_x6_r0_body.ckn012 PRE_first_tail_x6_r0_body.ckn112 PRE_first_tail_x6_r0_body.ckheap12 PRE_first_tail_x6_r0_body.ckpl12)

-- the observers: the layers' states at the call, the canonical and the merged state, their footprints and checks
noncomputable def PRE_first_tail_x6_r0_body.fxC_12 : PTrie Unit := (Host.Ts.Sim.Full.freedOf PRE_first_tail_x6_r0_body.s131.ffi).getD PTrie.nil
noncomputable def PRE_first_tail_x6_r0_body.krC_12 : Host.Load.Layers.KRec := (Host.Ts.Sim.Full.krecOf PRE_first_tail_x6_r0_body.s131.ffi).getD Host.Load.Layers.KRec.empty
kernel_rfl PRE_first_tail_x6_r0_body.ofxC_12 : (Host.Ts.Sim.Full.freedOf PRE_first_tail_x6_r0_body.s131.ffi) = some PRE_first_tail_x6_r0_body.fxC_12
kernel_rfl PRE_first_tail_x6_r0_body.okrC_12 : (Host.Ts.Sim.Full.krecOf PRE_first_tail_x6_r0_body.s131.ffi) = some PRE_first_tail_x6_r0_body.krC_12
noncomputable def PRE_first_tail_x6_r0_body.fx0_12 : PTrie Unit := (Host.Ts.Sim.Full.freedOf PRE_first_tail_x6_r0_body.s133.ffi).getD PTrie.nil
noncomputable def PRE_first_tail_x6_r0_body.kr0_12 : Host.Load.Layers.KRec := (Host.Ts.Sim.Full.krecOf PRE_first_tail_x6_r0_body.s133.ffi).getD Host.Load.Layers.KRec.empty
kernel_rfl PRE_first_tail_x6_r0_body.ofx0_12 : (Host.Ts.Sim.Full.freedOf PRE_first_tail_x6_r0_body.s133.ffi) = some PRE_first_tail_x6_r0_body.fx0_12
kernel_rfl PRE_first_tail_x6_r0_body.okr0_12 : (Host.Ts.Sim.Full.krecOf PRE_first_tail_x6_r0_body.s133.ffi) = some PRE_first_tail_x6_r0_body.kr0_12
noncomputable def PRE_first_tail_x6_r0_body.fx1_12 : PTrie Unit := (Host.Ts.Sim.Full.freedOf PRE_first_tail_x6_r0_body.s132.ffi).getD PTrie.nil
noncomputable def PRE_first_tail_x6_r0_body.kr1_12 : Host.Load.Layers.KRec := (Host.Ts.Sim.Full.krecOf PRE_first_tail_x6_r0_body.s132.ffi).getD Host.Load.Layers.KRec.empty
kernel_rfl PRE_first_tail_x6_r0_body.ofx1_12 : (Host.Ts.Sim.Full.freedOf PRE_first_tail_x6_r0_body.s132.ffi) = some PRE_first_tail_x6_r0_body.fx1_12
kernel_rfl PRE_first_tail_x6_r0_body.okr1_12 : (Host.Ts.Sim.Full.krecOf PRE_first_tail_x6_r0_body.s132.ffi) = some PRE_first_tail_x6_r0_body.kr1_12
kernel_rfl PRE_first_tail_x6_r0_body.ff012 : PRE_first_tail_x6_r0_body.fx0_12 = Stage.setAll PRE_first_tail_x6_r0_body.fxC_12 (PRE_first_tail_x6_r0_body.clo12.filterMap fun i => (PRE_first_tail_x6_r0_body.fx0_12.get i).map (i, ·))
kernel_rfl PRE_first_tail_x6_r0_body.ff112 : PRE_first_tail_x6_r0_body.fx1_12 = Stage.setAll PRE_first_tail_x6_r0_body.fxC_12 (PRE_first_tail_x6_r0_body.cwS12.filterMap fun i => (PRE_first_tail_x6_r0_body.fx1_12.get i).map (i, ·))
kernel_rfl PRE_first_tail_x6_r0_body.ffck12 : freedLB PRE_first_tail_x6_r0_body.kappa12 PRE_first_tail_x6_r0_body.cx0_12.mlx PRE_first_tail_x6_r0_body.fx0_12 PRE_first_tail_x6_r0_body.fx1_12 PRE_first_tail_x6_r0_body.clo12 = true
kernel_rfl PRE_first_tail_x6_r0_body.fkf012 : PRE_first_tail_x6_r0_body.kr0_12.flags = Stage.setAll PRE_first_tail_x6_r0_body.krC_12.flags (PRE_first_tail_x6_r0_body.clo12.filterMap fun i => (PRE_first_tail_x6_r0_body.kr0_12.flags.get i).map (i, ·))
kernel_rfl PRE_first_tail_x6_r0_body.fkt012 : PRE_first_tail_x6_r0_body.kr0_12.targs = Stage.setAll PRE_first_tail_x6_r0_body.krC_12.targs (PRE_first_tail_x6_r0_body.clo12.filterMap fun i => (PRE_first_tail_x6_r0_body.kr0_12.targs.get i).map (i, ·))
kernel_rfl PRE_first_tail_x6_r0_body.fkf112 : PRE_first_tail_x6_r0_body.kr1_12.flags = Stage.setAll PRE_first_tail_x6_r0_body.krC_12.flags (PRE_first_tail_x6_r0_body.cwS12.filterMap fun i => (PRE_first_tail_x6_r0_body.kr1_12.flags.get i).map (i, ·))
kernel_rfl PRE_first_tail_x6_r0_body.fkt112 : PRE_first_tail_x6_r0_body.kr1_12.targs = Stage.setAll PRE_first_tail_x6_r0_body.krC_12.targs (PRE_first_tail_x6_r0_body.cwS12.filterMap fun i => (PRE_first_tail_x6_r0_body.kr1_12.targs.get i).map (i, ·))
kernel_rfl PRE_first_tail_x6_r0_body.fkck12 : krecLB PRE_first_tail_x6_r0_body.kappa12 614 PRE_first_tail_x6_r0_body.cx0_12.mlx PRE_first_tail_x6_r0_body.kr0_12 PRE_first_tail_x6_r0_body.kr1_12 PRE_first_tail_x6_r0_body.clo12 = true
kernel_rfl PRE_first_tail_x6_r0_body.fkn12 : Nat.ble 596 614 = true
-- the bridge and the pending traces' regions
kernel_rfl PRE_first_tail_x6_r0_body.cbridge12 : Host.Ts.Sim.Full.bridgeOf PRE_first_tail_x6_r0_body.s132.ffi = Host.Ts.Sim.Full.bridgeOf PRE_first_tail_x6_r0_body.s133.ffi
kernel_rfl PRE_first_tail_x6_r0_body.cpendR12 : pendRegB PRE_first_tail_x6_r0_body.kappa12 (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.s133.ffi).mlx = true
kernel_rfl PRE_first_tail_x6_r0_body.cpendLe12 : Nat.ble (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.s133.ffi).mlx.next (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.s132.ffi).mlx.next = true
/-- **The compaction's native shift**, given the call's bookkeeping, its relation's facts (the model's and the
observers') and the canonical closedness. -/
theorem PRE_first_tail_x6_r0_body.cshift12 (clean : Conv.NClean (⟨18452, 15515, 2684875, 596⟩ : Conv.Cnt) (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.s131.ffi).mlx) (hltC : ∀ h, PH (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.s131.ffi).mlx h → h < (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.s131.ffi).mlx.next) (nltC : ∀ i, PN (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.s131.ffi).mlx i → i < (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.s131.ffi).mlx.nnext) (itemsC : ∀ k v, (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.s131.ffi).mlx.items.get k = some v → PN (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.s131.ffi).mlx k) (tracedC : ∀ h o, (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.s131.ffi).mlx.objs.get h = some o → ∀ i ∈ objTraces o, i < PRE_first_tail_x6_r0_body.P12.NL) (cl : SSt (· < 614) PRE_first_tail_x6_r0_body.cx0_12.mlx)
    (hobjC : ∀ h, PRE_first_tail_x6_r0_body.fxC_12.get h = some () → ((Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.s131.ffi).mlx.objs.get h).isSome = true)
    (hfC : ∀ h, (PRE_first_tail_x6_r0_body.krC_12.flags.get h).isSome = true → ((Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.s131.ffi).mlx.objs.get h).isSome = true)
    (htC : ∀ h, (PRE_first_tail_x6_r0_body.krC_12.targs.get h).isSome = true → ((Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.s131.ffi).mlx.objs.get h).isSome = true)
    (hclC : ∀ h l, PRE_first_tail_x6_r0_body.krC_12.targs.get h = some l → Host.Ts.Sim.Full.STargs (· < (⟨18452, 15515, 2684875, 596⟩ : Conv.Cnt).n) l) :
    Conv.FullShiftQ PRE_first_tail_x6_r0_body.P12 614 PRE_first_tail_x6_r0_body.kappa12 PRE_first_tail_x6_r0_body.s133.ffi PRE_first_tail_x6_r0_body.s132.ffi :=
  ⟨PRE_first_tail_x6_r0_body.cnshift12 clean hltC nltC itemsC tracedC cl, PRE_first_tail_x6_r0_body.cqueue12, fun t ht => bSN_sound (List.all_eq_true.mp PRE_first_tail_x6_r0_body.ctokSupp12 t ht),
    PRE_first_tail_x6_r0_body.cbridge12,
    liveShift_foot (x0' := Host.Ts.Sim.Full.mlxOf PRE_first_tail_x6_r0_body.s133.ffi) (x1' := Host.Ts.Sim.Full.mlxOf PRE_first_tail_x6_r0_body.s132.ffi) (PRE_first_tail_x6_r0_body.cfoot12 clean hltC nltC itemsC tracedC cl) rfl PRE_first_tail_x6_r0_body.ofx0_12 PRE_first_tail_x6_r0_body.ofx1_12 hobjC PRE_first_tail_x6_r0_body.ff012 PRE_first_tail_x6_r0_body.ff112 PRE_first_tail_x6_r0_body.ffck12,
    kernShift_foot (x0' := Host.Ts.Sim.Full.mlxOf PRE_first_tail_x6_r0_body.s133.ffi) (x1' := Host.Ts.Sim.Full.mlxOf PRE_first_tail_x6_r0_body.s132.ffi) (PRE_first_tail_x6_r0_body.cfoot12 clean hltC nltC itemsC tracedC cl) rfl PRE_first_tail_x6_r0_body.okr0_12 PRE_first_tail_x6_r0_body.okr1_12 (Nat.le_of_ble_eq_true PRE_first_tail_x6_r0_body.fkn12) hfC htC hclC
      PRE_first_tail_x6_r0_body.fkf012 PRE_first_tail_x6_r0_body.fkt012 PRE_first_tail_x6_r0_body.fkf112 PRE_first_tail_x6_r0_body.fkt112 PRE_first_tail_x6_r0_body.fkck12,
    pendReg_of rfl PRE_first_tail_x6_r0_body.cnh012 PRE_first_tail_x6_r0_body.cnh112 (Nat.le_of_ble_eq_true PRE_first_tail_x6_r0_body.cpendLe12) PRE_first_tail_x6_r0_body.cpendR12⟩

end Host.Load.Run.Tpl
end

section -- st12/H0
set_option Elab.async false
namespace Host.Load.Run.Tpl
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
host_stream_state PRE_first_tail_x6_r0_body.st12 0
host_stream_state PRE_first_tail_x6_r0_body.st12 1
host_stream_state PRE_first_tail_x6_r0_body.st12 2
host_stream_state PRE_first_tail_x6_r0_body.st12 3
host_stream_state PRE_first_tail_x6_r0_body.st12 4
host_stream_state PRE_first_tail_x6_r0_body.st12 5
end Host.Load.Run.Tpl
end

section -- Site12
set_option Elab.async false
namespace Host.Load.Run.Tpl
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
open Host.Ts Host.Ts.Sim Host.Ts.Sim.Template

/-! Call site 12 of chain `PRE_first_tail_x6_r0_body`: `ssmW__g12__g13` (`recurWindow`), the call state `PRE_first_tail_x6_r0_body.s131`, the merged state `PRE_first_tail_x6_r0_body.s132`,
the site template `PRE_first_tail_x6_r0_body.st12` (σ = `Map.id`, θ the identity at its own site), the canonical state `PRE_first_tail_x6_r0_body.s133`: the merge.
The footprint's facts are in `SiteF12`, the compaction's in `SiteC12`, `SiteK12`, `SiteNa12`, `SiteNb12`. -/

kernel_rfl PRE_first_tail_x6_r0_body.iso12 : PRE_first_tail_x6_r0_body.st12.s0 = { PRE_first_tail_x6_r0_body.s131 with stack := [] }
/-- The caller's frames at the call. -/
noncomputable def PRE_first_tail_x6_r0_body.rs12 : List Frame := PRE_first_tail_x6_r0_body.s131.stack
kernel_rfl PRE_first_tail_x6_r0_body.n0_12 : PRE_first_tail_x6_r0_body.S131.tab.length = 596
kernel_rfl PRE_first_tail_x6_r0_body.tab0_12 : PRE_first_tail_x6_r0_body.st12.S0.tab = PRE_first_tail_x6_r0_body.S131.tab

/-- The fresh variables of the stage's results. -/
def PRE_first_tail_x6_r0_body.ws12 : List Nat := [1199, 1200, 1201, 1202, 1203, 1204, 1205, 1206, 1207, 1208, 1209, 1210, 1211, 1212, 1213, 1214, 1215, 1216, 1217, 1218, 1219, 1220, 1221, 1222, 1223, 1224, 1225, 1226, 1227, 1228, 1229]
kernel_rfl PRE_first_tail_x6_r0_body.fresh12 : (PRE_first_tail_x6_r0_body.S131.tab.all fun e => PRE_first_tail_x6_r0_body.ws12.all fun v => e.noVar v) &&
    (PRE_first_tail_x6_r0_body.S131.oracle.all fun q => PRE_first_tail_x6_r0_body.ws12.all fun v => q.noVar v) = true
kernel_rfl PRE_first_tail_x6_r0_body.mergeTab12 : PRE_first_tail_x6_r0_body.S132.tab = PRE_first_tail_x6_r0_body.S131.tab ++ Conv.resTab PRE_first_tail_x6_r0_body.ws12
kernel_rfl PRE_first_tail_x6_r0_body.mergeLen12 : PRE_first_tail_x6_r0_body.st12.S5.tab.length - PRE_first_tail_x6_r0_body.st12.S0.tab.length = 31

-- The merged state: the instance's return state with the caller's frames (`PRE_first_tail_x6_r0_body.merged12`, `merged_relB`).
kernel_rfl PRE_first_tail_x6_r0_body.mheap12 : PRE_first_tail_x6_r0_body.s132.heap = PRE_first_tail_x6_r0_body.st12.s5.heap
kernel_rfl PRE_first_tail_x6_r0_body.mnext12 : PRE_first_tail_x6_r0_body.s132.next = PRE_first_tail_x6_r0_body.st12.s5.next
kernel_rfl PRE_first_tail_x6_r0_body.mctl12 : PRE_first_tail_x6_r0_body.s132.ctl = PRE_first_tail_x6_r0_body.st12.s5.ctl
kernel_rfl PRE_first_tail_x6_r0_body.mstack12 : PRE_first_tail_x6_r0_body.s132.stack = PRE_first_tail_x6_r0_body.st12.s5.stack ++ PRE_first_tail_x6_r0_body.s131.stack
kernel_rfl PRE_first_tail_x6_r0_body.mjobs12 : PRE_first_tail_x6_r0_body.s132.jobs = PRE_first_tail_x6_r0_body.st12.s5.jobs
kernel_rfl PRE_first_tail_x6_r0_body.mffi12 : PRE_first_tail_x6_r0_body.s132.ffi = PRE_first_tail_x6_r0_body.st12.s5.ffi
kernel_rfl PRE_first_tail_x6_r0_body.mtrace12 : PRE_first_tail_x6_r0_body.s132.trace = PRE_first_tail_x6_r0_body.st12.s5.trace
kernel_rfl PRE_first_tail_x6_r0_body.mstores12 : PRE_first_tail_x6_r0_body.s132.stores = PRE_first_tail_x6_r0_body.st12.s5.stores

end Host.Load.Run.Tpl
end

section -- SiteD12
set_option Elab.async false
namespace Host.Load.Run.Tpl
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
open Host.Ts Host.Ts.Sim Host.Ts.Sim.Template

/-! The canonical results at call site 12 of chain `PRE_first_tail_x6_r0_body`: their values in the instance's end table, the references past
the call's table, the canonical variables apart from the stage's. -/

kernel_rfl PRE_first_tail_x6_r0_body.cderived12 : PRE_first_tail_x6_r0_body.nr12.map (fun r => nth? PRE_first_tail_x6_r0_body.st12.S5.tab r) =
  [some (SymE.bin .add (SymE.lit (F64.zero false)) (SymE.un .int32 (SymE.un .int32 (SymE.var 10)))),
   some (SymE.un .int32 (SymE.un .int32 (SymE.bin .sub (SymE.bin .add (SymE.lit (F64.fin false 3 (0))) (SymE.un .int32 (SymE.un .int32 (SymE.var 10)))) (SymE.lit (F64.fin false 3 (0)))))),
   some (SymE.un .int32 (SymE.bin .sub (SymE.bin .add (SymE.lit (F64.fin false 3 (0))) (SymE.un .int32 (SymE.un .int32 (SymE.var 10)))) (SymE.un .int32 (SymE.un .int32 (SymE.un .int32 (SymE.var 10)))))),
   some (SymE.un .int32 (SymE.bin .sub (SymE.bin .add (SymE.lit (F64.fin false 3 (0))) (SymE.un .int32 (SymE.un .int32 (SymE.var 10)))) (SymE.lit (F64.fin false 3 (0))))),
   some (SymE.un .int32 (SymE.bin .sub (SymE.bin .add (SymE.lit (F64.fin false 3 (0))) (SymE.un .int32 (SymE.un .int32 (SymE.var 10)))) (SymE.lit (F64.fin false 3 (0))))),
   some (SymE.un .int32 (SymE.bin .sub (SymE.bin .add (SymE.lit (F64.fin false 3 (0))) (SymE.un .int32 (SymE.un .int32 (SymE.var 10)))) (SymE.lit (F64.fin false 3 (0))))),
   some (SymE.un .int32 (SymE.un .int32 (SymE.bin .sub (SymE.bin .add (SymE.lit (F64.fin false 3 (0))) (SymE.un .int32 (SymE.un .int32 (SymE.var 10)))) (SymE.lit (F64.fin false 3 (0)))))),
   some (SymE.un .int32 (SymE.un .int32 (SymE.un .int32 (SymE.var 10)))),
   some (SymE.un .int32 (SymE.bin .add (SymE.un .int32 (SymE.un .int32 (SymE.var 10))) (SymE.lit (F64.fin false 3 (0))))),
   some (SymE.bin .sub (SymE.bin .add (SymE.lit (F64.fin false 3 (0))) (SymE.un .int32 (SymE.un .int32 (SymE.var 10)))) (SymE.un .int32 (SymE.un .int32 (SymE.un .int32 (SymE.var 10))))),
   some (SymE.un .int32 (SymE.bin .sub (SymE.bin .add (SymE.lit (F64.fin false 3 (0))) (SymE.un .int32 (SymE.un .int32 (SymE.var 10)))) (SymE.lit (F64.fin false 3 (0))))),
   some (SymE.bin .sub (SymE.bin .sub (SymE.bin .add (SymE.lit (F64.fin false 3 (0))) (SymE.un .int32 (SymE.un .int32 (SymE.var 10)))) (SymE.lit (F64.fin false 3 (0)))) (SymE.lit (F64.zero false))),
   some (SymE.bin .add (SymE.lit (F64.fin false 3 (0))) (SymE.un .int32 (SymE.un .int32 (SymE.var 10)))),
   some (SymE.un .int32 (SymE.bin .sub (SymE.bin .add (SymE.lit (F64.fin false 3 (0))) (SymE.un .int32 (SymE.un .int32 (SymE.var 10)))) (SymE.lit (F64.fin false 3 (0))))),
   some (SymE.bin .sub (SymE.bin .sub (SymE.bin .add (SymE.lit (F64.fin false 3 (0))) (SymE.un .int32 (SymE.un .int32 (SymE.var 10)))) (SymE.lit (F64.fin false 3 (0)))) (SymE.lit (F64.zero false))),
   some (SymE.un .int32 (SymE.bin .sub (SymE.bin .add (SymE.lit (F64.fin false 3 (0))) (SymE.un .int32 (SymE.un .int32 (SymE.var 10)))) (SymE.lit (F64.fin false 3 (0))))),
   some (SymE.bin .sub (SymE.bin .sub (SymE.bin .add (SymE.lit (F64.fin false 3 (0))) (SymE.un .int32 (SymE.un .int32 (SymE.var 10)))) (SymE.lit (F64.fin false 3 (0)))) (SymE.lit (F64.zero false))),
   some (SymE.bin .sub (SymE.bin .add (SymE.lit (F64.fin false 3 (0))) (SymE.un .int32 (SymE.un .int32 (SymE.var 10)))) (SymE.lit (F64.fin false 3 (0))))]
kernel_rfl PRE_first_tail_x6_r0_body.cnrLo12 : PRE_first_tail_x6_r0_body.nr12.all (Nat.ble 596) = true
kernel_rfl PRE_first_tail_x6_r0_body.cwsDisj12 : PRE_first_tail_x6_r0_body.cws12.all (fun c => !PRE_first_tail_x6_r0_body.ws12.contains c) = true
/-- The compaction's substitution: the canonical variables to their merged values, the stage's other fresh variables
to `0` (`Conv.compactθZ`). -/
noncomputable def PRE_first_tail_x6_r0_body.cthetaZ12 : Nat → SymE := Conv.compactθZ PRE_first_tail_x6_r0_body.cws12 PRE_first_tail_x6_r0_body.crs12 PRE_first_tail_x6_r0_body.ws12

end Host.Load.Run.Tpl
end

section -- st12/Foot
set_option Elab.async false
namespace Host.Load.Run.Tpl
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
open Host.Ts Host.Ts.Sim Host.Ts.Sim.Stage Host.Ts.Sim.Template

/-! The footprint of stage `PRE_first_tail_x6_r0_body.st12`'s site template (`Conv.StageFoot`, `Conv.NFoot`): every entry of the return
state other than the written and fresh ones is the start's (kernel evaluation of the equalities). -/

/-- The written heap ranges below the start's counter. -/
def PRE_first_tail_x6_r0_body.st12.wrR : List (Nat × Nat) := [(2672331, 2672332), (2684049, 2684050), (2684594, 2684595), (2684850, 2684851)]
/-- The written and fresh entries of the return state. -/
noncomputable def PRE_first_tail_x6_r0_body.st12.wrE : List (Nat × Host.Ts.HObj) :=
  rangesOf PRE_first_tail_x6_r0_body.st12.s5.heap PRE_first_tail_x6_r0_body.st12.wrR ++ freshOf PRE_first_tail_x6_r0_body.st12.s5.heap PRE_first_tail_x6_r0_body.st12.s0.next PRE_first_tail_x6_r0_body.st12.s5.next
noncomputable def PRE_first_tail_x6_r0_body.st12.wr : List Nat := PRE_first_tail_x6_r0_body.st12.wrE.map (·.1)

kernel_rfl PRE_first_tail_x6_r0_body.st12.heapFoot : PRE_first_tail_x6_r0_body.st12.s5.heap = setAll PRE_first_tail_x6_r0_body.st12.s0.heap PRE_first_tail_x6_r0_body.st12.wrE
kernel_rfl PRE_first_tail_x6_r0_body.st12.grows_check : Nat.ble PRE_first_tail_x6_r0_body.st12.s0.next PRE_first_tail_x6_r0_body.st12.s5.next = true
theorem PRE_first_tail_x6_r0_body.st12.grows : PRE_first_tail_x6_r0_body.st12.s0.next ≤ PRE_first_tail_x6_r0_body.st12.s5.next := Nat.le_of_ble_eq_true PRE_first_tail_x6_r0_body.st12.grows_check

/-- The written and fresh handles; the written readback items of old nodes. -/
def PRE_first_tail_x6_r0_body.st12.wh : List Nat := [18432, 18445, 18451, 18452, 18453, 18454, 18455, 18456, 18457, 18458, 18459, 18460, 18461, 18462, 18463, 18464, 18465, 18466, 18467, 18468, 18469, 18470, 18471, 18472, 18473, 18474, 18475, 18476, 18477, 18478, 18479]
def PRE_first_tail_x6_r0_body.st12.wi : List Nat := []

kernel_rfl PRE_first_tail_x6_r0_body.st12.arrsFoot : (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.st12.s5.ffi).mlx.arrs = setAll (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.st12.s0.ffi).mlx.arrs (PRE_first_tail_x6_r0_body.st12.wh.filterMap fun h => ((Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.st12.s5.ffi).mlx.arrs.get h).map (h, ·))
kernel_rfl PRE_first_tail_x6_r0_body.st12.objsFoot : (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.st12.s5.ffi).mlx.objs = setAll (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.st12.s0.ffi).mlx.objs (PRE_first_tail_x6_r0_body.st12.wh.filterMap fun h => ((Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.st12.s5.ffi).mlx.objs.get h).map (h, ·))
kernel_rfl PRE_first_tail_x6_r0_body.st12.nodesFoot : (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.st12.s5.ffi).mlx.nodes = setAll (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.st12.s0.ffi).mlx.nodes (freshOf (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.st12.s5.ffi).mlx.nodes (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.st12.s0.ffi).mlx.nnext (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.st12.s5.ffi).mlx.nnext)
kernel_rfl PRE_first_tail_x6_r0_body.st12.itemsFoot : (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.st12.s5.ffi).mlx.items = setAll (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.st12.s0.ffi).mlx.items ((PRE_first_tail_x6_r0_body.st12.wi.filterMap fun i => ((Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.st12.s5.ffi).mlx.items.get i).map (i, ·)) ++
    freshOf (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.st12.s5.ffi).mlx.items (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.st12.s0.ffi).mlx.nnext (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.st12.s5.ffi).mlx.nnext)
kernel_rfl PRE_first_tail_x6_r0_body.st12.counters : (Nat.ble (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.st12.s0.ffi).mlx.next (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.st12.s5.ffi).mlx.next && Nat.ble (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.st12.s0.ffi).mlx.nnext (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.st12.s5.ffi).mlx.nnext) = true

end Host.Load.Run.Tpl
end

section -- SiteF12
set_option Elab.async false
namespace Host.Load.Run.Tpl
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
open Host.Ts Host.Ts.Sim Host.Ts.Sim.Template

/-! Call site 12 of chain `PRE_first_tail_x6_r0_body`: `Conv.site_merge`'s footprint facts. -/

kernel_rfl PRE_first_tail_x6_r0_body.wrNodupB12 : nodupT PRE_first_tail_x6_r0_body.st12.wr PTrie.nil = true
theorem PRE_first_tail_x6_r0_body.wrNodup12 : PRE_first_tail_x6_r0_body.st12.wr.Nodup := (nodupT_sound PRE_first_tail_x6_r0_body.wrNodupB12).2
kernel_rfl PRE_first_tail_x6_r0_body.wrBoundB12 : PRE_first_tail_x6_r0_body.st12.wr.all (fun b => Nat.blt (b / 4096) (4 ^ 31)) = true
theorem PRE_first_tail_x6_r0_body.wrBound12 : ∀ b ∈ PRE_first_tail_x6_r0_body.st12.wr, b / 4096 < 4 ^ 31 := fun b hb => Nat.blt_eq.mp (List.all_eq_true.mp PRE_first_tail_x6_r0_body.wrBoundB12 b hb)
noncomputable def PRE_first_tail_x6_r0_body.trFr12 := PRE_first_tail_x6_r0_body.st12.s5.trace.take 120
kernel_rfl PRE_first_tail_x6_r0_body.traceEq12 : PRE_first_tail_x6_r0_body.st12.s5.trace = PRE_first_tail_x6_r0_body.trFr12 ++ PRE_first_tail_x6_r0_body.st12.s0.trace
theorem PRE_first_tail_x6_r0_body.trace12 : ∃ fr, PRE_first_tail_x6_r0_body.st12.s5.trace = fr ++ PRE_first_tail_x6_r0_body.st12.s0.trace := ⟨_, PRE_first_tail_x6_r0_body.traceEq12⟩

-- the caller's wide frames at the instance's start (`Conv.isolateW`'s `W0` under `Map.id`) and their `WFix`
def PRE_first_tail_x6_r0_body.wide12 : List (Nat × WFrame) := [(4910, .memo [])]
kernel_rfl PRE_first_tail_x6_r0_body.wfixB12 : (PRE_first_tail_x6_r0_body.wide12.all fun p => wfixB Map.id (presentB PRE_first_tail_x6_r0_body.st12.s0) p.2) = true
theorem PRE_first_tail_x6_r0_body.wfix12 : ∀ p ∈ PRE_first_tail_x6_r0_body.wide12, WFix Map.id (Present PRE_first_tail_x6_r0_body.st12.s0) p.2 :=
  fun p hp => wfix_of (List.all_eq_true.mp PRE_first_tail_x6_r0_body.wfixB12 p hp)

end Host.Load.Run.Tpl
end

section -- SiteL12
set_option Elab.async false
namespace Host.Load.Run.Tpl
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
open Host.Ts Host.Ts.Sim Host.Ts.Sim.Template

/-! The call link's facts at call site 12 of chain `PRE_first_tail_x6_r0_body`: the instance's start server, its footprint (`Conv.StageFoot`), the
merged state `PRE_first_tail_x6_r0_body.s132`'s framed arrays as the chain start's extended (`arrExt_of`, `numRefs_of`). -/

kernel_rfl PRE_first_tail_x6_r0_body.srvO12 : PRE_first_tail_x6_r0_body.st12.S0.oracle = PRE_first_tail_x6_r0_body.st12.OR
kernel_rfl PRE_first_tail_x6_r0_body.wr0B12 : PRE_first_tail_x6_r0_body.st12.wr.all (fun b => !Nat.blt b PRE_first_tail_x6_r0_body.st12.s0.next || (PRE_first_tail_x6_r0_body.st12.s0.heap.get b).isSome) = true
theorem PRE_first_tail_x6_r0_body.stFoot12 : Conv.StageFoot PRE_first_tail_x6_r0_body.st12.wr PRE_first_tail_x6_r0_body.st12.s0 PRE_first_tail_x6_r0_body.st12.s5 :=
  stageFoot_of PRE_first_tail_x6_r0_body.st12.heapFoot PRE_first_tail_x6_r0_body.wrNodup12 PRE_first_tail_x6_r0_body.wrBound12 PRE_first_tail_x6_r0_body.wr0B12 PRE_first_tail_x6_r0_body.st12.grows

/-- **The relation at the merged state** from the relation at the merge (`Conv.site_merge`'s; `merged_relB`). -/
theorem PRE_first_tail_x6_r0_body.merged12 {FR : Map → Nat → PRE_first_tail_x6_r0_body.st12.F.S → PRE_first_tail_x6_r0_body.st12.F.S → Prop} {W : Nat → Option WFrame} {stk : List Frame} {M : Map}
    {ν : Nat → F64} {K : Host.Ts.Sim.Ctx} {S : SSrv} {t : St PRE_first_tail_x6_r0_body.st12.F.S} {C : CSrv} {n0 : Nat}
    (h : RelB PRE_first_tail_x6_r0_body.st12.F FR W stk M ν K (Conv.mergeSt Map.id (Map.id.res n0 n0) PRE_first_tail_x6_r0_body.rs12 PRE_first_tail_x6_r0_body.st12.wr PRE_first_tail_x6_r0_body.s131 PRE_first_tail_x6_r0_body.st12.s5 PRE_first_tail_x6_r0_body.st12.s0
      PRE_first_tail_x6_r0_body.st12.s5.ffi) S t C) : RelB PRE_first_tail_x6_r0_body.st12.F FR W stk M ν K PRE_first_tail_x6_r0_body.s132 S t C :=
  merged_relB PRE_first_tail_x6_r0_body.iso12 PRE_first_tail_x6_r0_body.stFoot12 PRE_first_tail_x6_r0_body.wrNodup12 PRE_first_tail_x6_r0_body.wrBound12 PRE_first_tail_x6_r0_body.trace12 PRE_first_tail_x6_r0_body.mheap12
    PRE_first_tail_x6_r0_body.mnext12 PRE_first_tail_x6_r0_body.mctl12 PRE_first_tail_x6_r0_body.mstack12 PRE_first_tail_x6_r0_body.mjobs12 PRE_first_tail_x6_r0_body.mffi12 PRE_first_tail_x6_r0_body.mtrace12 PRE_first_tail_x6_r0_body.mstores12 h

def PRE_first_tail_x6_r0_body.arrEl12_2665 : List Val := []
kernel_rfl PRE_first_tail_x6_r0_body.arrE12_2665 : arrOf PRE_first_tail_x6_r0_body.s132 2665 = arrOf PRE_first_tail_x6_r0_body.s0 2665 ++ PRE_first_tail_x6_r0_body.arrEl12_2665
kernel_rfl PRE_first_tail_x6_r0_body.arrA12_2665 : isArrB PRE_first_tail_x6_r0_body.s132 2665 = true
theorem PRE_first_tail_x6_r0_body.arr12_2665 : ∃ o, PRE_first_tail_x6_r0_body.s132.heap.get 2665 = some (.obj o) ∧ o.kind = .array (arrOf PRE_first_tail_x6_r0_body.s0 2665 ++ PRE_first_tail_x6_r0_body.arrEl12_2665) :=
  arrExt_of PRE_first_tail_x6_r0_body.arrE12_2665 PRE_first_tail_x6_r0_body.arrA12_2665
kernel_rfl PRE_first_tail_x6_r0_body.arrN12_2665 : numRefsB PRE_first_tail_x6_r0_body.S0.tab.length PRE_first_tail_x6_r0_body.arrEl12_2665 = true
theorem PRE_first_tail_x6_r0_body.arrR12_2665 : Prefill.NumRefs PRE_first_tail_x6_r0_body.S0.tab.length PRE_first_tail_x6_r0_body.arrEl12_2665 := numRefs_of PRE_first_tail_x6_r0_body.arrN12_2665

def PRE_first_tail_x6_r0_body.arrEl12_2673467 : List Val := []
kernel_rfl PRE_first_tail_x6_r0_body.arrE12_2673467 : arrOf PRE_first_tail_x6_r0_body.s132 2673467 = arrOf PRE_first_tail_x6_r0_body.s0 2673467 ++ PRE_first_tail_x6_r0_body.arrEl12_2673467
kernel_rfl PRE_first_tail_x6_r0_body.arrA12_2673467 : isArrB PRE_first_tail_x6_r0_body.s132 2673467 = true
theorem PRE_first_tail_x6_r0_body.arr12_2673467 : ∃ o, PRE_first_tail_x6_r0_body.s132.heap.get 2673467 = some (.obj o) ∧ o.kind = .array (arrOf PRE_first_tail_x6_r0_body.s0 2673467 ++ PRE_first_tail_x6_r0_body.arrEl12_2673467) :=
  arrExt_of PRE_first_tail_x6_r0_body.arrE12_2673467 PRE_first_tail_x6_r0_body.arrA12_2673467
kernel_rfl PRE_first_tail_x6_r0_body.arrN12_2673467 : numRefsB PRE_first_tail_x6_r0_body.S0.tab.length PRE_first_tail_x6_r0_body.arrEl12_2673467 = true
theorem PRE_first_tail_x6_r0_body.arrR12_2673467 : Prefill.NumRefs PRE_first_tail_x6_r0_body.S0.tab.length PRE_first_tail_x6_r0_body.arrEl12_2673467 := numRefs_of PRE_first_tail_x6_r0_body.arrN12_2673467

kernel_rfl PRE_first_tail_x6_r0_body.w4910k12 : isArrB PRE_first_tail_x6_r0_body.s132 4910 = false
theorem PRE_first_tail_x6_r0_body.keep12 (q : List Val) : Host.Ts.Sim.Prefill.KeepsAtW (framesP PRE_first_tail_x6_r0_body.s0 q) PRE_first_tail_x6_r0_body.s132 := by
  intro a pre pre' hx o es ho hk
  unfold framesP at hx
  simp only at hx
  cases h1 : Nat.beq a 2665
  · cases h2 : Nat.beq a 4910
    · rw [h1, h2] at hx; cases hx
    · have := Nat.eq_of_beq_eq_true h2; subst this
      rw [h1, h2] at hx; cases hx
      exact (notArr_of PRE_first_tail_x6_r0_body.w4910k12 ho hk).elim
  · have := Nat.eq_of_beq_eq_true h1; subst this
    rw [h1] at hx; cases hx
    obtain ⟨o', ho', hk'⟩ := PRE_first_tail_x6_r0_body.arr12_2665
    rw [ho] at ho'; cases ho'
    rw [hk'] at hk; cases hk
    simp [PRE_first_tail_x6_r0_body.arrEl12_2665]

end Host.Load.Run.Tpl
end

section -- SiteZ12
set_option Elab.async false
namespace Host.Load.Run.Tpl
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
open Host.Ts Host.Ts.Sim Host.Ts.Sim.Template

/-! The compaction's state shift at call site 12 of chain `PRE_first_tail_x6_r0_body` (`Conv.compact_shift`): the call `PRE_first_tail_x6_r0_body.s131`, the merged
state `PRE_first_tail_x6_r0_body.s132`, the canonical state `PRE_first_tail_x6_r0_body.s133`; its frames [2665,2673467,2673472,2673473] (kept arrays [2665,2673467]). -/

-- the map's places and counters
kernel_rfl PRE_first_tail_x6_r0_body.zpl12 : PRE_first_tail_x6_r0_body.pl12.all (Nat.ble PRE_first_tail_x6_r0_body.s131.next) = true
kernel_rfl PRE_first_tail_x6_r0_body.zplnd12 : nodupT PRE_first_tail_x6_r0_body.pl12 PTrie.nil = true
kernel_rfl PRE_first_tail_x6_r0_body.zn112 : Nat.ble PRE_first_tail_x6_r0_body.s131.next 2686030 = true
kernel_rfl PRE_first_tail_x6_r0_body.zfirst12 : Nat.ble aFirst PRE_first_tail_x6_r0_body.s131.next = true
kernel_rfl PRE_first_tail_x6_r0_body.zscn12 : PRE_first_tail_x6_r0_body.s133.next = PRE_first_tail_x6_r0_body.s131.next + PRE_first_tail_x6_r0_body.pl12.length
kernel_rfl PRE_first_tail_x6_r0_body.zsmn12 : PRE_first_tail_x6_r0_body.s132.next = 2686030
kernel_rfl PRE_first_tail_x6_r0_body.zgrow12 : Nat.ble PRE_first_tail_x6_r0_body.s133.next PRE_first_tail_x6_r0_body.s132.next = true
-- the tables
kernel_rfl PRE_first_tail_x6_r0_body.zfresh12 : PRE_first_tail_x6_r0_body.S131.tab.all (fun e => PRE_first_tail_x6_r0_body.cws12.all fun v => e.noVar v) = true
kernel_rfl PRE_first_tail_x6_r0_body.zcnd12 : nodupT PRE_first_tail_x6_r0_body.cws12 PTrie.nil = true
kernel_rfl PRE_first_tail_x6_r0_body.znrHi12 : PRE_first_tail_x6_r0_body.nr12.all (fun r => Nat.blt r PRE_first_tail_x6_r0_body.S132.tab.length) = true
-- the frames: every framed address below the call's counter; the kept arrays the chain start's, extended in the merged state
kernel_rfl PRE_first_tail_x6_r0_body.zfrlt12 : [2665, 2673467, 2673472, 2673473].all (fun a => Nat.blt a PRE_first_tail_x6_r0_body.s131.next) = true
kernel_rfl PRE_first_tail_x6_r0_body.zg12_2665 : PRE_first_tail_x6_r0_body.s133.heap.get 2665 = some (.obj (objOf PRE_first_tail_x6_r0_body.s133 2665))
kernel_rfl PRE_first_tail_x6_r0_body.zk12_2665 : (objOf PRE_first_tail_x6_r0_body.s133 2665).kind = .array (arrOf PRE_first_tail_x6_r0_body.s0 2665)
kernel_rfl PRE_first_tail_x6_r0_body.zm12_2665 : PRE_first_tail_x6_r0_body.s132.heap.get 2665 = some (.obj { PRE_first_tail_x6_r0_body.kappa12.obj (objOf PRE_first_tail_x6_r0_body.s133 2665) with
  kind := .array (arrOf PRE_first_tail_x6_r0_body.s0 2665 ++ (arrOf PRE_first_tail_x6_r0_body.s132 2665).drop (arrOf PRE_first_tail_x6_r0_body.s0 2665).length) })
kernel_rfl PRE_first_tail_x6_r0_body.zg12_2673467 : PRE_first_tail_x6_r0_body.s133.heap.get 2673467 = some (.obj (objOf PRE_first_tail_x6_r0_body.s133 2673467))
kernel_rfl PRE_first_tail_x6_r0_body.zk12_2673467 : (objOf PRE_first_tail_x6_r0_body.s133 2673467).kind = .array (arrOf PRE_first_tail_x6_r0_body.s0 2673467)
kernel_rfl PRE_first_tail_x6_r0_body.zm12_2673467 : PRE_first_tail_x6_r0_body.s132.heap.get 2673467 = some (.obj { PRE_first_tail_x6_r0_body.kappa12.obj (objOf PRE_first_tail_x6_r0_body.s133 2673467) with
  kind := .array (arrOf PRE_first_tail_x6_r0_body.s0 2673467 ++ (arrOf PRE_first_tail_x6_r0_body.s132 2673467).drop (arrOf PRE_first_tail_x6_r0_body.s0 2673467).length) })
kernel_rfl PRE_first_tail_x6_r0_body.zw12_4910 : (PRE_first_tail_x6_r0_body.s133.heap.get 4910).isSome = true
kernel_rfl PRE_first_tail_x6_r0_body.zw12_2673472 : (PRE_first_tail_x6_r0_body.s133.heap.get 2673472).isSome = true
kernel_rfl PRE_first_tail_x6_r0_body.zw12_2673473 : (PRE_first_tail_x6_r0_body.s133.heap.get 2673473).isSome = true
-- the heap: the changed list in range, holding the stage's written and fresh addresses; the canonical side's image
kernel_rfl PRE_first_tail_x6_r0_body.zclbd12 : PRE_first_tail_x6_r0_body.cl12.all (fun b => Nat.blt (b / 4096) (4 ^ 31)) = true
kernel_rfl PRE_first_tail_x6_r0_body.zwr12 : PRE_first_tail_x6_r0_body.st12.wr.all (fun b => !Nat.blt b PRE_first_tail_x6_r0_body.s131.next || PRE_first_tail_x6_r0_body.cl12.contains b) = true
def PRE_first_tail_x6_r0_body.zl12 : List Nat := PRE_first_tail_x6_r0_body.cl12.filter fun a => !(List.contains [2665, 2673467] a)
kernel_rfl PRE_first_tail_x6_r0_body.zimgE12 : PRE_first_tail_x6_r0_body.zl12.map (fun a => PRE_first_tail_x6_r0_body.s132.heap.get (PRE_first_tail_x6_r0_body.kappa12.a a)) = PRE_first_tail_x6_r0_body.zl12.map (fun a => (PRE_first_tail_x6_r0_body.s133.heap.get a).map PRE_first_tail_x6_r0_body.kappa12.hobj)
theorem PRE_first_tail_x6_r0_body.zimg12 : HeapImg PRE_first_tail_x6_r0_body.kappa12 PRE_first_tail_x6_r0_body.s133 PRE_first_tail_x6_r0_body.s132 PRE_first_tail_x6_r0_body.zl12 := PRE_first_tail_x6_r0_body.zimgE12
-- the roots and their supports
kernel_rfl PRE_first_tail_x6_r0_body.zctl12 : PRE_first_tail_x6_r0_body.s132.ctl = PRE_first_tail_x6_r0_body.kappa12.ctl PRE_first_tail_x6_r0_body.s133.ctl
kernel_rfl PRE_first_tail_x6_r0_body.zstack12 : PRE_first_tail_x6_r0_body.s132.stack = PRE_first_tail_x6_r0_body.s133.stack.map PRE_first_tail_x6_r0_body.kappa12.frame
kernel_rfl PRE_first_tail_x6_r0_body.zjobs12 : PRE_first_tail_x6_r0_body.s132.jobs = PRE_first_tail_x6_r0_body.s133.jobs.map PRE_first_tail_x6_r0_body.kappa12.job
kernel_rfl PRE_first_tail_x6_r0_body.zstores12 : PRE_first_tail_x6_r0_body.s132.stores = PRE_first_tail_x6_r0_body.kappa12.stores PRE_first_tail_x6_r0_body.s133.stores
kernel_rfl PRE_first_tail_x6_r0_body.zroots12 : checkRootsSupp PRE_first_tail_x6_r0_body.s133 614 = true
kernel_rfl PRE_first_tail_x6_r0_body.znC12 : PRE_first_tail_x6_r0_body.S131.tab.length + PRE_first_tail_x6_r0_body.cws12.length = 614
-- the map as `Conv.compact_shift` states it (the call's counters for the literals)
kernel_rfl PRE_first_tail_x6_r0_body.zkap12 : PRE_first_tail_x6_r0_body.kappa12 = Conv.Map.compact PRE_first_tail_x6_r0_body.s131.next 2686030 PRE_first_tail_x6_r0_body.S131.tab.length PRE_first_tail_x6_r0_body.pl12 (PRE_first_tail_x6_r0_body.nr12.map NumV.ref) PRE_first_tail_x6_r0_body.kd12.big
  PRE_first_tail_x6_r0_body.kd12.region PRE_first_tail_x6_r0_body.kd12.nodeF
-- the bridge inactive at the canonical state (`Conv.FullShiftQ.toX`; the merged state's bridge is the canonical's: cbridge)
theorem PRE_first_tail_x6_r0_body.zbin12 : (Host.Ts.Sim.Full.bridgeOf PRE_first_tail_x6_r0_body.s133.ffi).active = false := (Host.Load.Boot.replay_active Host.Load.Run.Prompt.P.oblog2818)
-- the JS bookkeeping's step (`Conv.JClean.step` over the changed list) and the canonical roots' bigint freedom
kernel_rfl PRE_first_tail_x6_r0_body.zjc12 : Conv.jcleanListB (⟨18455, 15542, 2684881, 614⟩ : Conv.Cnt) PRE_first_tail_x6_r0_body.s133 PRE_first_tail_x6_r0_body.cl12 = true
kernel_rfl PRE_first_tail_x6_r0_body.zrootsB12 : noBigRootsP (fun i => !Conv.oldBigB (⟨18455, 15542, 2684881, 614⟩ : Conv.Cnt) i) PRE_first_tail_x6_r0_body.s133.trace PRE_first_tail_x6_r0_body.s133 = true
kernel_rfl PRE_first_tail_x6_r0_body.zhm12 : Nat.ble (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.s0.ffi).mlx.nnext 15515 = true
theorem PRE_first_tail_x6_r0_body.cjcl12 (h : Conv.JClean (⟨18452, 15515, 2684875, 596⟩ : Conv.Cnt) PRE_first_tail_x6_r0_body.s131) : Conv.JClean (⟨18455, 15542, 2684881, 614⟩ : Conv.Cnt) PRE_first_tail_x6_r0_body.s133 :=
  Conv.JClean.step h (Conv.Cnt.le_of_leB PRE_first_tail_x6_r0_body.cle12)
    (Conv.heap_off_setAll PRE_first_tail_x6_r0_body.cheap12 fun a ha => Nat.blt_eq.mp (List.all_eq_true.mp PRE_first_tail_x6_r0_body.zclbd12 a ha)) PRE_first_tail_x6_r0_body.zjc12

end Host.Load.Run.Tpl
end

section -- st12/TypedLast
set_option Elab.async false
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
namespace Host.Load.Run.Tpl
open Host.Ts Host.Ts.Sim Host.Ts.Sim.Template

boot_rfl PRE_first_tail_x6_r0_body.st12.bodyLast from PRE_first_tail_x6_r0_body.st12.s4 to PRE_first_tail_x6_r0_body.st12.s5 :
  interpS (step PRE_first_tail_x6_r0_body.st12.F PRE_first_tail_x6_r0_body.st12.s4).run PRE_first_tail_x6_r0_body.st12.S4 = some (PRE_first_tail_x6_r0_body.st12.s5, PRE_first_tail_x6_r0_body.st12.S5)
kernel_rfl PRE_first_tail_x6_r0_body.st12.bodyHalt : isHalt PRE_first_tail_x6_r0_body.st12.s4.ctl = false
kernel_rfl PRE_first_tail_x6_r0_body.st12.bodyTopCheck : noBlockTop PRE_first_tail_x6_r0_body.st12.s5.stack = true

end Host.Load.Run.Tpl
end

section -- st12/TypedOk
set_option Elab.async false
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
namespace Host.Load.Run.Tpl
open Host.Ts Host.Ts.Sim Host.Ts.Sim.Template

noncomputable def PRE_first_tail_x6_r0_body.st12.bodyOkL (bytes : List Byte) (rows : Nat) : St PRE_first_tail_x6_r0_body.st12.F.S → SSrv → Bool :=
  okLocal (Host.Ts.Sim.Compose.VWFrames.bodyOk bytes rows)

noncomputable def PRE_first_tail_x6_r0_body.st12.bodyOkLN (bytes : List Byte) (rows : Nat) : St PRE_first_tail_x6_r0_body.st12.F.S → FSrv → Bool :=
  okLocalN (Host.Ts.Sim.Compose.VWFrames.bodyOkN bytes rows)

theorem PRE_first_tail_x6_r0_body.st12.bodyOkLN_ok (bytes : List Byte) (rows : Nat) (s : St PRE_first_tail_x6_r0_body.st12.F.S) (c : FSrv) (h : c.Wf) :
    PRE_first_tail_x6_r0_body.st12.bodyOkLN bytes rows s c = PRE_first_tail_x6_r0_body.st12.bodyOkL bytes rows s c.toS :=
  okLocalN_ok (Host.Ts.Sim.Compose.VWFrames.bodyOkN_ok bytes rows) s c h

kernel_rfl PRE_first_tail_x6_r0_body.st12.bodyAccepted0 :
  (fun (bytes : List Byte) (rows : Nat) => PRE_first_tail_x6_r0_body.st12.bodyOkL bytes rows PRE_first_tail_x6_r0_body.st12.s0 PRE_first_tail_x6_r0_body.st12.S0) = fun _ _ => true

kernel_rfl PRE_first_tail_x6_r0_body.st12.bodyAccepted1 :
  (fun (bytes : List Byte) (rows : Nat) => PRE_first_tail_x6_r0_body.st12.bodyOkL bytes rows PRE_first_tail_x6_r0_body.st12.s4 PRE_first_tail_x6_r0_body.st12.S4) = fun _ _ => true

end Host.Load.Run.Tpl
end

section -- st12/TypedK0
set_option Elab.async false
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
namespace Host.Load.Run.Tpl
open Host.Ts Host.Ts.Sim Host.Ts.Sim.Template

boot_rfl PRE_first_tail_x6_r0_body.st12.bodyK0F from PRE_first_tail_x6_r0_body.st12.s0 to PRE_first_tail_x6_r0_body.st12.s1 :
  (fun (bytes : List Byte) (rows : Nat) => runOkS PRE_first_tail_x6_r0_body.st12.F (PRE_first_tail_x6_r0_body.st12.bodyOkLN bytes rows)
    ((nth? PRE_first_tail_x6_r0_body.st12.ks 0).getD 0) PRE_first_tail_x6_r0_body.st12.s0 PRE_first_tail_x6_r0_body.st12.S0) = fun _ _ => some (PRE_first_tail_x6_r0_body.st12.s1, PRE_first_tail_x6_r0_body.st12.S1)
theorem PRE_first_tail_x6_r0_body.st12.bodyK0 :
  (fun (bytes : List Byte) (rows : Nat) => runOk PRE_first_tail_x6_r0_body.st12.F (PRE_first_tail_x6_r0_body.st12.bodyOkL bytes rows)
    ((nth? PRE_first_tail_x6_r0_body.st12.ks 0).getD 0) PRE_first_tail_x6_r0_body.st12.s0 PRE_first_tail_x6_r0_body.st12.S0) = fun _ _ => some (PRE_first_tail_x6_r0_body.st12.s1, PRE_first_tail_x6_r0_body.st12.S1) :=
  runOk_fun_of_runOkS PRE_first_tail_x6_r0_body.st12.bodyOkLN_ok PRE_first_tail_x6_r0_body.st12.bodyK0F
end Host.Load.Run.Tpl
end

section -- st12/TypedK1
set_option Elab.async false
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
namespace Host.Load.Run.Tpl
open Host.Ts Host.Ts.Sim Host.Ts.Sim.Template

boot_rfl PRE_first_tail_x6_r0_body.st12.bodyK1F from PRE_first_tail_x6_r0_body.st12.s1 to PRE_first_tail_x6_r0_body.st12.s2 :
  (fun (bytes : List Byte) (rows : Nat) => runOkS PRE_first_tail_x6_r0_body.st12.F (PRE_first_tail_x6_r0_body.st12.bodyOkLN bytes rows)
    ((nth? PRE_first_tail_x6_r0_body.st12.ks 1).getD 0) PRE_first_tail_x6_r0_body.st12.s1 PRE_first_tail_x6_r0_body.st12.S1) = fun _ _ => some (PRE_first_tail_x6_r0_body.st12.s2, PRE_first_tail_x6_r0_body.st12.S2)
theorem PRE_first_tail_x6_r0_body.st12.bodyK1 :
  (fun (bytes : List Byte) (rows : Nat) => runOk PRE_first_tail_x6_r0_body.st12.F (PRE_first_tail_x6_r0_body.st12.bodyOkL bytes rows)
    ((nth? PRE_first_tail_x6_r0_body.st12.ks 1).getD 0) PRE_first_tail_x6_r0_body.st12.s1 PRE_first_tail_x6_r0_body.st12.S1) = fun _ _ => some (PRE_first_tail_x6_r0_body.st12.s2, PRE_first_tail_x6_r0_body.st12.S2) :=
  runOk_fun_of_runOkS PRE_first_tail_x6_r0_body.st12.bodyOkLN_ok PRE_first_tail_x6_r0_body.st12.bodyK1F
end Host.Load.Run.Tpl
end

section -- st12/TypedK2
set_option Elab.async false
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
namespace Host.Load.Run.Tpl
open Host.Ts Host.Ts.Sim Host.Ts.Sim.Template

boot_rfl PRE_first_tail_x6_r0_body.st12.bodyK2F from PRE_first_tail_x6_r0_body.st12.s2 to PRE_first_tail_x6_r0_body.st12.s3 :
  (fun (bytes : List Byte) (rows : Nat) => runOkS PRE_first_tail_x6_r0_body.st12.F (PRE_first_tail_x6_r0_body.st12.bodyOkLN bytes rows)
    ((nth? PRE_first_tail_x6_r0_body.st12.ks 2).getD 0) PRE_first_tail_x6_r0_body.st12.s2 PRE_first_tail_x6_r0_body.st12.S2) = fun _ _ => some (PRE_first_tail_x6_r0_body.st12.s3, PRE_first_tail_x6_r0_body.st12.S3)
theorem PRE_first_tail_x6_r0_body.st12.bodyK2 :
  (fun (bytes : List Byte) (rows : Nat) => runOk PRE_first_tail_x6_r0_body.st12.F (PRE_first_tail_x6_r0_body.st12.bodyOkL bytes rows)
    ((nth? PRE_first_tail_x6_r0_body.st12.ks 2).getD 0) PRE_first_tail_x6_r0_body.st12.s2 PRE_first_tail_x6_r0_body.st12.S2) = fun _ _ => some (PRE_first_tail_x6_r0_body.st12.s3, PRE_first_tail_x6_r0_body.st12.S3) :=
  runOk_fun_of_runOkS PRE_first_tail_x6_r0_body.st12.bodyOkLN_ok PRE_first_tail_x6_r0_body.st12.bodyK2F
end Host.Load.Run.Tpl
end

section -- st12/TypedK3
set_option Elab.async false
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
namespace Host.Load.Run.Tpl
open Host.Ts Host.Ts.Sim Host.Ts.Sim.Template

boot_rfl PRE_first_tail_x6_r0_body.st12.bodyK3F from PRE_first_tail_x6_r0_body.st12.s3 to PRE_first_tail_x6_r0_body.st12.s4 :
  (fun (bytes : List Byte) (rows : Nat) => runOkS PRE_first_tail_x6_r0_body.st12.F (PRE_first_tail_x6_r0_body.st12.bodyOkLN bytes rows)
    ((nth? PRE_first_tail_x6_r0_body.st12.ks 3).getD 0) PRE_first_tail_x6_r0_body.st12.s3 PRE_first_tail_x6_r0_body.st12.S3) = fun _ _ => some (PRE_first_tail_x6_r0_body.st12.s4, PRE_first_tail_x6_r0_body.st12.S4)
theorem PRE_first_tail_x6_r0_body.st12.bodyK3 :
  (fun (bytes : List Byte) (rows : Nat) => runOk PRE_first_tail_x6_r0_body.st12.F (PRE_first_tail_x6_r0_body.st12.bodyOkL bytes rows)
    ((nth? PRE_first_tail_x6_r0_body.st12.ks 3).getD 0) PRE_first_tail_x6_r0_body.st12.s3 PRE_first_tail_x6_r0_body.st12.S3) = fun _ _ => some (PRE_first_tail_x6_r0_body.st12.s4, PRE_first_tail_x6_r0_body.st12.S4) :=
  runOk_fun_of_runOkS PRE_first_tail_x6_r0_body.st12.bodyOkLN_ok PRE_first_tail_x6_r0_body.st12.bodyK3F
end Host.Load.Run.Tpl
end

section -- st12/TypedTpl
set_option Elab.async false
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
namespace Host.Load.Run.Tpl
open Host.Ts Host.Ts.Sim Host.Ts.Sim.Template

theorem PRE_first_tail_x6_r0_body.st12.bodyRun (bytes : List Byte) (rows : Nat) :
    runOk PRE_first_tail_x6_r0_body.st12.F (PRE_first_tail_x6_r0_body.st12.bodyOkL bytes rows) 11334 PRE_first_tail_x6_r0_body.st12.s0 PRE_first_tail_x6_r0_body.st12.S0 = some (PRE_first_tail_x6_r0_body.st12.s4, PRE_first_tail_x6_r0_body.st12.S4) :=
  runOk_trans PRE_first_tail_x6_r0_body.st12.F (PRE_first_tail_x6_r0_body.st12.bodyOkL bytes rows) ((((nth? PRE_first_tail_x6_r0_body.st12.ks 0).getD 0) + ((nth? PRE_first_tail_x6_r0_body.st12.ks 1).getD 0)) + ((nth? PRE_first_tail_x6_r0_body.st12.ks 2).getD 0)) ((nth? PRE_first_tail_x6_r0_body.st12.ks 3).getD 0) PRE_first_tail_x6_r0_body.st12.s0 PRE_first_tail_x6_r0_body.st12.s3 PRE_first_tail_x6_r0_body.st12.s4 PRE_first_tail_x6_r0_body.st12.S0 PRE_first_tail_x6_r0_body.st12.S3 PRE_first_tail_x6_r0_body.st12.S4 (runOk_trans PRE_first_tail_x6_r0_body.st12.F (PRE_first_tail_x6_r0_body.st12.bodyOkL bytes rows) (((nth? PRE_first_tail_x6_r0_body.st12.ks 0).getD 0) + ((nth? PRE_first_tail_x6_r0_body.st12.ks 1).getD 0)) ((nth? PRE_first_tail_x6_r0_body.st12.ks 2).getD 0) PRE_first_tail_x6_r0_body.st12.s0 PRE_first_tail_x6_r0_body.st12.s2 PRE_first_tail_x6_r0_body.st12.s3 PRE_first_tail_x6_r0_body.st12.S0 PRE_first_tail_x6_r0_body.st12.S2 PRE_first_tail_x6_r0_body.st12.S3 (runOk_trans PRE_first_tail_x6_r0_body.st12.F (PRE_first_tail_x6_r0_body.st12.bodyOkL bytes rows) ((nth? PRE_first_tail_x6_r0_body.st12.ks 0).getD 0) ((nth? PRE_first_tail_x6_r0_body.st12.ks 1).getD 0) PRE_first_tail_x6_r0_body.st12.s0 PRE_first_tail_x6_r0_body.st12.s1 PRE_first_tail_x6_r0_body.st12.s2 PRE_first_tail_x6_r0_body.st12.S0 PRE_first_tail_x6_r0_body.st12.S1 PRE_first_tail_x6_r0_body.st12.S2 ((congrFun (congrFun PRE_first_tail_x6_r0_body.st12.bodyK0 bytes) rows)) (congrFun (congrFun PRE_first_tail_x6_r0_body.st12.bodyK1 bytes) rows)) (congrFun (congrFun PRE_first_tail_x6_r0_body.st12.bodyK2 bytes) rows)) (congrFun (congrFun PRE_first_tail_x6_r0_body.st12.bodyK3 bytes) rows)

theorem PRE_first_tail_x6_r0_body.st12.bodyLocal (bytes : List Byte) (rows : Nat) : ∀ s S, PRE_first_tail_x6_r0_body.st12.bodyOkL bytes rows s S = true → Disp.localB s = true := okLocal_localB

noncomputable def PRE_first_tail_x6_r0_body.st12.bodyTpl (bytes : List Byte) (rows : Nat) : Host.Ts.Sim.Stage.StageTpl PRE_first_tail_x6_r0_body.st12.F (PRE_first_tail_x6_r0_body.st12.bodyOkL bytes rows) where
  s0 := PRE_first_tail_x6_r0_body.st12.s0
  S0 := PRE_first_tail_x6_r0_body.st12.S0
  s1 := PRE_first_tail_x6_r0_body.st12.s4
  S1 := PRE_first_tail_x6_r0_body.st12.S4
  s2 := PRE_first_tail_x6_r0_body.st12.s5
  S2 := PRE_first_tail_x6_r0_body.st12.S5
  n := 11334
  ok0 := congrFun (congrFun PRE_first_tail_x6_r0_body.st12.bodyAccepted0 bytes) rows
  run := PRE_first_tail_x6_r0_body.st12.bodyRun bytes rows
  ok1 := congrFun (congrFun PRE_first_tail_x6_r0_body.st12.bodyAccepted1 bytes) rows
  halt := PRE_first_tail_x6_r0_body.st12.bodyHalt
  last := PRE_first_tail_x6_r0_body.st12.bodyLast
  top := noBlockTop_sound PRE_first_tail_x6_r0_body.st12.bodyTopCheck
end Host.Load.Run.Tpl
end

section -- SiteC13
set_option Elab.async false
namespace Host.Load.Run.Tpl
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
open Host.Ts Host.Ts.Sim Host.Ts.Sim.Template

/-! The compaction after the merge at call site 13 of chain `PRE_first_tail_x6_r0_body` (`Conv.compact`, `Conv.full_compactQ`): the canonical
state `PRE_first_tail_x6_r0_body.s141` (the stage's results at canonical places, its trace the call's) under `PRE_first_tail_x6_r0_body.kappa13` into the merged state
`PRE_first_tail_x6_r0_body.s140`. -/

def PRE_first_tail_x6_r0_body.pl13 : List Nat := []
def PRE_first_tail_x6_r0_body.nr13 : List Nat := []
/-- The native part of the compaction map (canonical → merged handles and nodes: its `big`, `region`, `nodeF`). -/
def PRE_first_tail_x6_r0_body.kd13 : RData :=
  ⟨2685371, 2685373, Stage.setAll PTrie.nil [], Stage.setAll PTrie.nil [],
   18468, 18468, 15555, 15555, Stage.setAll PTrie.nil [],
   Stage.setAll PTrie.nil []⟩
/-- **The compaction map.** -/
noncomputable def PRE_first_tail_x6_r0_body.kappa13 : Map :=
  Conv.Map.compact 2685371 2685373 635 PRE_first_tail_x6_r0_body.pl13 (PRE_first_tail_x6_r0_body.nr13.map NumV.ref) PRE_first_tail_x6_r0_body.kd13.big
    PRE_first_tail_x6_r0_body.kd13.region PRE_first_tail_x6_r0_body.kd13.nodeF
/-- The canonical result variables and their images, the merged state's entries (`Conv.compactθ`). -/
def PRE_first_tail_x6_r0_body.cws13 : List Nat := []
noncomputable def PRE_first_tail_x6_r0_body.crs13 : List SymE := PRE_first_tail_x6_r0_body.nr13.map fun r => (nth? PRE_first_tail_x6_r0_body.S140.tab r).getD (.var 0)
noncomputable def PRE_first_tail_x6_r0_body.ctheta13 : Nat → SymE := Conv.compactθ PRE_first_tail_x6_r0_body.cws13 PRE_first_tail_x6_r0_body.crs13
/-- The call's entries the stage wrote (renamed in the canonical state with the results). -/
def PRE_first_tail_x6_r0_body.wrB13 : List Nat := [2665, 2673467]

kernel_rfl PRE_first_tail_x6_r0_body.ctab13 : PRE_first_tail_x6_r0_body.S141.tab = PRE_first_tail_x6_r0_body.S139.tab ++ PRE_first_tail_x6_r0_body.cws13.map SymE.var
kernel_rfl PRE_first_tail_x6_r0_body.ctrace13 : PRE_first_tail_x6_r0_body.s141.trace = PRE_first_tail_x6_r0_body.s139.trace
kernel_rfl PRE_first_tail_x6_r0_body.cnext13 : PRE_first_tail_x6_r0_body.s141.next = 2685371
kernel_rfl PRE_first_tail_x6_r0_body.ccounters13 : ((Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.s141.ffi).mlx.next, (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.s141.ffi).mlx.nnext) = (18468, 15555)
-- the merged state's readback queue, carried to the canonical state (`Conv.FullShiftQ.tokens`, `tokSupp`)
kernel_rfl PRE_first_tail_x6_r0_body.cqueue13 : (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.s140.ffi).mlx.tokens = (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.s141.ffi).mlx.tokens.map PRE_first_tail_x6_r0_body.kappa13.nv
kernel_rfl PRE_first_tail_x6_r0_body.ctokSupp13 : (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.s141.ffi).mlx.tokens.all (bSN 635) = true
-- the written and the result entries carry no bigint of the canonical fresh band [next, E) and no fresh region
kernel_rfl PRE_first_tail_x6_r0_body.cclean13 : Conv.cleanListB 18468 131072 (fun r => Nat.ble 73872 r) PRE_first_tail_x6_r0_body.s141
    (PRE_first_tail_x6_r0_body.wrB13 ++ (List.range 0).map (2685371 + ·)) = true
kernel_rfl PRE_first_tail_x6_r0_body.cbigs13 : bigsOutB 18468 131072 (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.s141.ffi).mlx = true

end Host.Load.Run.Tpl
end

section -- SiteK13
set_option Elab.async false
namespace Host.Load.Run.Tpl
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
open Host.Ts Host.Ts.Sim Host.Ts.Sim.Template

/-! The canonical state's closedness from the call's (`Conv.closed_of_callB`, `Conv.sst_of_callB`): it keeps the call's entries
off the written and the result ones (`PRE_first_tail_x6_r0_body.cl13`; natively the written and result handles, the result nodes, the written
and result items), and those are checked. -/

def PRE_first_tail_x6_r0_body.cl13 : List Nat := [2665, 2673467]
def PRE_first_tail_x6_r0_body.clo13 : List Nat := []
def PRE_first_tail_x6_r0_body.cln13 : List Nat := []
def PRE_first_tail_x6_r0_body.cli13 : List Nat := []
kernel_rfl PRE_first_tail_x6_r0_body.cheap13 : PRE_first_tail_x6_r0_body.s141.heap = Stage.setAll PRE_first_tail_x6_r0_body.s139.heap (PRE_first_tail_x6_r0_body.cl13.filterMap fun a => (PRE_first_tail_x6_r0_body.s141.heap.get a).map (a, ·))
kernel_rfl PRE_first_tail_x6_r0_body.cnextLe13 : Nat.ble PRE_first_tail_x6_r0_body.s139.next PRE_first_tail_x6_r0_body.s141.next = true
kernel_rfl PRE_first_tail_x6_r0_body.ckeepP13 : Conv.keptPresentB PRE_first_tail_x6_r0_body.s139 PRE_first_tail_x6_r0_body.s141 PRE_first_tail_x6_r0_body.cl13 = true
kernel_rfl PRE_first_tail_x6_r0_body.csupp13 : Conv.suppListB PRE_first_tail_x6_r0_body.s141 635 PRE_first_tail_x6_r0_body.cl13 = true
kernel_rfl PRE_first_tail_x6_r0_body.cbound13 : Conv.boundListB PRE_first_tail_x6_r0_body.s141 PRE_first_tail_x6_r0_body.cl13 = true
kernel_rfl PRE_first_tail_x6_r0_body.cnodesK13 : (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.s141.ffi).mlx.nodes = Stage.setAll (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.s139.ffi).mlx.nodes (PRE_first_tail_x6_r0_body.cln13.filterMap fun i => ((Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.s141.ffi).mlx.nodes.get i).map (i, ·))
kernel_rfl PRE_first_tail_x6_r0_body.cobjsK13 : (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.s141.ffi).mlx.objs = Stage.setAll (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.s139.ffi).mlx.objs (PRE_first_tail_x6_r0_body.clo13.filterMap fun i => ((Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.s141.ffi).mlx.objs.get i).map (i, ·))
kernel_rfl PRE_first_tail_x6_r0_body.citemsK13 : (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.s141.ffi).mlx.items = Stage.setAll (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.s139.ffi).mlx.items (PRE_first_tail_x6_r0_body.cli13.filterMap fun i => ((Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.s141.ffi).mlx.items.get i).map (i, ·))
kernel_rfl PRE_first_tail_x6_r0_body.csst13 : Conv.sstListB 635 (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.s141.ffi).mlx PRE_first_tail_x6_r0_body.cln13 PRE_first_tail_x6_r0_body.clo13 PRE_first_tail_x6_r0_body.cli13 = true

end Host.Load.Run.Tpl
end

section -- SiteCl13
set_option Elab.async false
namespace Host.Load.Run.Tpl
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
open Host.Ts Host.Ts.Sim Host.Ts.Sim.Template

kernel_rfl PRE_first_tail_x6_r0_body.ckA13 : (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.s141.ffi).mlx.arrs = Stage.setAll (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.s139.ffi).mlx.arrs (PRE_first_tail_x6_r0_body.clo13.filterMap fun i => ((Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.s141.ffi).mlx.arrs.get i).map (i, ·))
kernel_rfl PRE_first_tail_x6_r0_body.cbd13 : (PRE_first_tail_x6_r0_body.clo13 ++ PRE_first_tail_x6_r0_body.cln13 ++ PRE_first_tail_x6_r0_body.cli13).all (fun i => Nat.blt (i / 4096) (4 ^ 31)) = true
kernel_rfl PRE_first_tail_x6_r0_body.cle13 : Conv.Cnt.leB (⟨18468, 15555, 2685371, 635⟩ : Conv.Cnt) (⟨18468, 15555, 2685371, 635⟩ : Conv.Cnt) = true
kernel_rfl PRE_first_tail_x6_r0_body.cck13 : Conv.ncleanListB (⟨18468, 15555, 2685371, 635⟩ : Conv.Cnt) (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.s141.ffi).mlx PRE_first_tail_x6_r0_body.clo13 PRE_first_tail_x6_r0_body.cln13 PRE_first_tail_x6_r0_body.cli13 = true
theorem PRE_first_tail_x6_r0_body.cncl13 (h : Conv.NClean (⟨18468, 15555, 2685371, 635⟩ : Conv.Cnt) (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.s139.ffi).mlx) : Conv.NClean (⟨18468, 15555, 2685371, 635⟩ : Conv.Cnt) (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.s141.ffi).mlx :=
  Conv.NClean.stepKeep h PRE_first_tail_x6_r0_body.cle13 PRE_first_tail_x6_r0_body.ckA13 PRE_first_tail_x6_r0_body.cobjsK13 PRE_first_tail_x6_r0_body.cnodesK13 PRE_first_tail_x6_r0_body.citemsK13 PRE_first_tail_x6_r0_body.cbd13 PRE_first_tail_x6_r0_body.cck13

end Host.Load.Run.Tpl
end

section -- SiteS13
set_option Elab.async false
namespace Host.Load.Run.Tpl
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
open Host.Ts Host.Ts.Sim Host.Ts.Sim.Template

/-! The compaction's native shift at call site 13 from its footprint (`Conv.nshift_of_foot`), and the observers'
(`liveShift_foot`, `kernShift_foot`): `Conv.FullShiftQ` for `Conv.full_compactQ`, given the call's bookkeeping and its
relation's facts. -/

/-- The load parameters of the chain (band-free: its start's node counter as `NL` and `N0`). -/
def PRE_first_tail_x6_r0_body.Pc13 : LoadP := ⟨18151, 131072, 1099511627776, 15235, 15235, []⟩
/-- The site's band raised to the map's checked fixed-node prefix, including newly recorded closure traces. -/
def PRE_first_tail_x6_r0_body.P13 : LoadP := PRE_first_tail_x6_r0_body.Pc13.raise 15555
kernel_rfl PRE_first_tail_x6_r0_body.craise13 : Nat.ble PRE_first_tail_x6_r0_body.Pc13.N0 15555 = true
theorem PRE_first_tail_x6_r0_body.raised13 : Host.Ts.Sim.Full.Raised PRE_first_tail_x6_r0_body.Pc13 PRE_first_tail_x6_r0_body.P13 :=
  .inr ⟨15555, rfl, Nat.le_of_ble_eq_true PRE_first_tail_x6_r0_body.craise13, rfl⟩
noncomputable abbrev PRE_first_tail_x6_r0_body.cx0_13 : Host.Load.LSt := clearTokens (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.s141.ffi)
noncomputable abbrev PRE_first_tail_x6_r0_body.cx1_13 : Host.Load.LSt := clearTokens (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.s140.ffi)
def PRE_first_tail_x6_r0_body.khinv13 : PTrie Nat := Stage.setAll PTrie.nil []
def PRE_first_tail_x6_r0_body.kninv13 : PTrie Nat := Stage.setAll PTrie.nil []
/-- The stage's footprint: its written and fresh handles, fresh nodes, written and fresh items. -/
def PRE_first_tail_x6_r0_body.cwS13 : List Nat := []
def PRE_first_tail_x6_r0_body.cnS13 : List Nat := List.range' 15555 0
def PRE_first_tail_x6_r0_body.ciS13 : List Nat := [] ++ List.range' 15555 0

-- the small checks (`MChecks`'s)
kernel_rfl PRE_first_tail_x6_r0_body.cnh013 : PRE_first_tail_x6_r0_body.kd13.nh0 = PRE_first_tail_x6_r0_body.cx0_13.mlx.next
kernel_rfl PRE_first_tail_x6_r0_body.cnh113 : PRE_first_tail_x6_r0_body.kd13.nh1 = PRE_first_tail_x6_r0_body.cx1_13.mlx.next
kernel_rfl PRE_first_tail_x6_r0_body.cnn013 : PRE_first_tail_x6_r0_body.kd13.nn0 = PRE_first_tail_x6_r0_body.cx0_13.mlx.nnext
kernel_rfl PRE_first_tail_x6_r0_body.cnn113 : PRE_first_tail_x6_r0_body.kd13.nn1 = PRE_first_tail_x6_r0_body.cx1_13.mlx.nnext
kernel_rfl PRE_first_tail_x6_r0_body.cplo13 : (Nat.blt 0 PRE_first_tail_x6_r0_body.P13.lo && Nat.ble PRE_first_tail_x6_r0_body.P13.lo PRE_first_tail_x6_r0_body.cx0_13.mlx.next && Nat.ble PRE_first_tail_x6_r0_body.P13.lo RData.bigHi && Nat.ble RData.bigHi PRE_first_tail_x6_r0_body.P13.E) = true
kernel_rfl PRE_first_tail_x6_r0_body.ccnt13 : (Nat.ble PRE_first_tail_x6_r0_body.cx0_13.mlx.next PRE_first_tail_x6_r0_body.cx1_13.mlx.next && Nat.ble PRE_first_tail_x6_r0_body.cx0_13.mlx.nnext PRE_first_tail_x6_r0_body.cx1_13.mlx.nnext) = true
kernel_rfl PRE_first_tail_x6_r0_body.cnband13 : (Nat.blt 0 PRE_first_tail_x6_r0_body.P13.NL && Nat.ble PRE_first_tail_x6_r0_body.P13.NL PRE_first_tail_x6_r0_body.P13.N0 && Nat.ble PRE_first_tail_x6_r0_body.P13.N0 PRE_first_tail_x6_r0_body.cx0_13.mlx.nnext) = true
kernel_rfl PRE_first_tail_x6_r0_body.chbelow13 : PRE_first_tail_x6_r0_body.kd13.checkHndBelow = true
kernel_rfl PRE_first_tail_x6_r0_body.chren13 : checkRenG PRE_first_tail_x6_r0_body.kd13.hnd PRE_first_tail_x6_r0_body.khinv13 (phB PRE_first_tail_x6_r0_body.cx0_13.mlx) = true
kernel_rfl PRE_first_tail_x6_r0_body.cband13 : PRE_first_tail_x6_r0_body.kd13.checkBand PRE_first_tail_x6_r0_body.P13.lo = true
kernel_rfl PRE_first_tail_x6_r0_body.cnh1pos13 : Nat.blt 0 PRE_first_tail_x6_r0_body.kd13.nh1 = true
kernel_rfl PRE_first_tail_x6_r0_body.cnren13 : checkRenG PRE_first_tail_x6_r0_body.kd13.node PRE_first_tail_x6_r0_body.kninv13 (pnB PRE_first_tail_x6_r0_body.cx0_13.mlx) = true
kernel_rfl PRE_first_tail_x6_r0_body.cnlow13 : (PTrie.keysA PRE_first_tail_x6_r0_body.kd13.node).all (fun j => Nat.ble PRE_first_tail_x6_r0_body.P13.NL j && Nat.blt (PRE_first_tail_x6_r0_body.kd13.nodeF j) PRE_first_tail_x6_r0_body.cx1_13.mlx.nnext) = true
kernel_rfl PRE_first_tail_x6_r0_body.cabs0a13 : PRE_first_tail_x6_r0_body.cx0_13.mlx.arrs.get 0 = none
kernel_rfl PRE_first_tail_x6_r0_body.cabs0b13 : PRE_first_tail_x6_r0_body.cx0_13.mlx.objs.get 0 = none
kernel_rfl PRE_first_tail_x6_r0_body.ctok113 : PRE_first_tail_x6_r0_body.cx1_13.mlx.tokens = []
kernel_rfl PRE_first_tail_x6_r0_body.cpend13 : PRE_first_tail_x6_r0_body.cx1_13.mlx.pending = PRE_first_tail_x6_r0_body.cx0_13.mlx.pending.map PRE_first_tail_x6_r0_body.kappa13.pend
kernel_rfl PRE_first_tail_x6_r0_body.cerrh13 : PRE_first_tail_x6_r0_body.cx1_13.mlx.errh = PRE_first_tail_x6_r0_body.cx0_13.mlx.errh.map PRE_first_tail_x6_r0_body.kappa13.arg
kernel_rfl PRE_first_tail_x6_r0_body.cfiles13 : PRE_first_tail_x6_r0_body.cx1_13.mlx.files = PRE_first_tail_x6_r0_body.cx0_13.mlx.files
kernel_rfl PRE_first_tail_x6_r0_body.carch13 : PRE_first_tail_x6_r0_body.cx1_13.mlx.arch = PRE_first_tail_x6_r0_body.cx0_13.mlx.arch
kernel_rfl PRE_first_tail_x6_r0_body.csizes13 : PRE_first_tail_x6_r0_body.cx1_13.mlx.deviceSizes = PRE_first_tail_x6_r0_body.cx0_13.mlx.deviceSizes
kernel_rfl PRE_first_tail_x6_r0_body.cwired13 : PRE_first_tail_x6_r0_body.cx1_13.mlx.wired = PRE_first_tail_x6_r0_body.cx0_13.mlx.wired
kernel_rfl PRE_first_tail_x6_r0_body.chost13 : PRE_first_tail_x6_r0_body.cx1_13.host = PRE_first_tail_x6_r0_body.cx0_13.host
-- the compaction map's addresses are `PRE_first_tail_x6_r0_body.kd13`'s
kernel_rfl PRE_first_tail_x6_r0_body.ckn013 : PRE_first_tail_x6_r0_body.kd13.n0 = 2685371
kernel_rfl PRE_first_tail_x6_r0_body.ckn113 : PRE_first_tail_x6_r0_body.kd13.n1 = 2685373
kernel_rfl PRE_first_tail_x6_r0_body.ckheap13 : (PTrie.keysA PRE_first_tail_x6_r0_body.kd13.heap).all (fun x => Nat.ble 2685371 x) = true
kernel_rfl PRE_first_tail_x6_r0_body.ckpl13 : (List.range 0).all (fun j => decide (PRE_first_tail_x6_r0_body.kd13.heap.get (2685371 + j) = nth? PRE_first_tail_x6_r0_body.pl13 j)) = true
-- the map fixes the call's names (`Conv.fixOld_compact`), the call's counters
kernel_rfl PRE_first_tail_x6_r0_body.fja13 : Nat.ble 2685371 2685371 = true
kernel_rfl PRE_first_tail_x6_r0_body.fn13 : Nat.ble 635 635 = true
kernel_rfl PRE_first_tail_x6_r0_body.fjaD13 : Nat.ble 2685371 PRE_first_tail_x6_r0_body.kd13.n0 = true
kernel_rfl PRE_first_tail_x6_r0_body.fxn13 : Nat.ble 18468 PRE_first_tail_x6_r0_body.kd13.nh0 = true
kernel_rfl PRE_first_tail_x6_r0_body.fnn13 : Nat.ble 15555 PRE_first_tail_x6_r0_body.kd13.nn0 = true
kernel_rfl PRE_first_tail_x6_r0_body.fxb13 : Nat.ble 18468 RData.bigHi = true
kernel_rfl PRE_first_tail_x6_r0_body.fheap13 : (PTrie.keysA PRE_first_tail_x6_r0_body.kd13.heap).all (Nat.ble (⟨18468, 15555, 2685371, 635⟩ : Conv.Cnt).ja) = true
kernel_rfl PRE_first_tail_x6_r0_body.fhnd13 : (PTrie.keysA PRE_first_tail_x6_r0_body.kd13.hnd).all (Nat.ble (⟨18468, 15555, 2685371, 635⟩ : Conv.Cnt).xn) = true
kernel_rfl PRE_first_tail_x6_r0_body.fnode13 : (PTrie.keysA PRE_first_tail_x6_r0_body.kd13.node).all (Nat.ble (⟨18468, 15555, 2685371, 635⟩ : Conv.Cnt).nn) = true
/-- The compaction map fixes the call's names. -/
theorem PRE_first_tail_x6_r0_body.cfix13 : Conv.FixOld (⟨18468, 15555, 2685371, 635⟩ : Conv.Cnt) PRE_first_tail_x6_r0_body.kappa13 :=
  Conv.fixOld_compact (Nat.le_of_ble_eq_true PRE_first_tail_x6_r0_body.fja13) (Nat.le_of_ble_eq_true PRE_first_tail_x6_r0_body.fn13) (Nat.le_of_ble_eq_true PRE_first_tail_x6_r0_body.fjaD13) (Nat.le_of_ble_eq_true PRE_first_tail_x6_r0_body.fxn13) (Nat.le_of_ble_eq_true PRE_first_tail_x6_r0_body.fnn13) (Nat.le_of_ble_eq_true PRE_first_tail_x6_r0_body.fxb13) PRE_first_tail_x6_r0_body.fheap13 PRE_first_tail_x6_r0_body.fhnd13 PRE_first_tail_x6_r0_body.fnode13
kernel_rfl PRE_first_tail_x6_r0_body.fcxn13 : (⟨18468, 15555, 2685371, 635⟩ : Conv.Cnt).xn = (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.s139.ffi).mlx.next
kernel_rfl PRE_first_tail_x6_r0_body.fcnn13 : (⟨18468, 15555, 2685371, 635⟩ : Conv.Cnt).nn = (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.s139.ffi).mlx.nnext
kernel_rfl PRE_first_tail_x6_r0_body.fle013 : (Nat.ble (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.s139.ffi).mlx.next PRE_first_tail_x6_r0_body.cx0_13.mlx.next && Nat.ble (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.s139.ffi).mlx.nnext PRE_first_tail_x6_r0_body.cx0_13.mlx.nnext && Nat.ble (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.s139.ffi).mlx.next RData.bigHi) = true
kernel_rfl PRE_first_tail_x6_r0_body.fnk13 : (PTrie.keysA PRE_first_tail_x6_r0_body.kd13.node).all (Nat.ble (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.s139.ffi).mlx.nnext) = true
-- the merged state keeps the call's entries off the stage's footprint
kernel_rfl PRE_first_tail_x6_r0_body.f1A13 : PRE_first_tail_x6_r0_body.cx1_13.mlx.arrs = Stage.setAll (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.s139.ffi).mlx.arrs (PRE_first_tail_x6_r0_body.cwS13.filterMap fun i => (PRE_first_tail_x6_r0_body.cx1_13.mlx.arrs.get i).map (i, ·))
kernel_rfl PRE_first_tail_x6_r0_body.f1O13 : PRE_first_tail_x6_r0_body.cx1_13.mlx.objs = Stage.setAll (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.s139.ffi).mlx.objs (PRE_first_tail_x6_r0_body.cwS13.filterMap fun i => (PRE_first_tail_x6_r0_body.cx1_13.mlx.objs.get i).map (i, ·))
kernel_rfl PRE_first_tail_x6_r0_body.f1N13 : PRE_first_tail_x6_r0_body.cx1_13.mlx.nodes = Stage.setAll (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.s139.ffi).mlx.nodes (PRE_first_tail_x6_r0_body.cnS13.filterMap fun i => (PRE_first_tail_x6_r0_body.cx1_13.mlx.nodes.get i).map (i, ·))
kernel_rfl PRE_first_tail_x6_r0_body.f1I13 : PRE_first_tail_x6_r0_body.cx1_13.mlx.items = Stage.setAll (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.s139.ffi).mlx.items (PRE_first_tail_x6_r0_body.ciS13.filterMap fun i => (PRE_first_tail_x6_r0_body.cx1_13.mlx.items.get i).map (i, ·))
kernel_rfl PRE_first_tail_x6_r0_body.fbd13 : (PRE_first_tail_x6_r0_body.clo13 ++ PRE_first_tail_x6_r0_body.cln13 ++ PRE_first_tail_x6_r0_body.cli13 ++ PRE_first_tail_x6_r0_body.cwS13 ++ PRE_first_tail_x6_r0_body.cnS13 ++ PRE_first_tail_x6_r0_body.ciS13).all (fun i => Nat.blt (i / 4096) (4 ^ 31)) = true
kernel_rfl PRE_first_tail_x6_r0_body.fincW13 : PRE_first_tail_x6_r0_body.cwS13.all (fun h => !Nat.blt h (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.s139.ffi).mlx.next || PRE_first_tail_x6_r0_body.clo13.contains h) = true
kernel_rfl PRE_first_tail_x6_r0_body.fincI13 : PRE_first_tail_x6_r0_body.ciS13.all (fun k => !Nat.blt k (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.s139.ffi).mlx.nnext || PRE_first_tail_x6_r0_body.cli13.contains k) = true
kernel_rfl PRE_first_tail_x6_r0_body.fincN13 : PRE_first_tail_x6_r0_body.cnS13.all (Nat.ble (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.s139.ffi).mlx.nnext) = true
kernel_rfl PRE_first_tail_x6_r0_body.flnF13 : PRE_first_tail_x6_r0_body.cln13.all (Nat.ble (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.s139.ffi).mlx.nnext) = true
-- the checks over the changed lists
kernel_rfl PRE_first_tail_x6_r0_body.fh13 : PRE_first_tail_x6_r0_body.clo13.all (handleOK PRE_first_tail_x6_r0_body.kappa13 PRE_first_tail_x6_r0_body.P13.lo PRE_first_tail_x6_r0_body.cx0_13.mlx PRE_first_tail_x6_r0_body.cx1_13.mlx) = true
kernel_rfl PRE_first_tail_x6_r0_body.fo13 : PRE_first_tail_x6_r0_body.clo13.map (fun h => PRE_first_tail_x6_r0_body.cx1_13.mlx.objs.get (PRE_first_tail_x6_r0_body.kappa13.handle h)) = PRE_first_tail_x6_r0_body.clo13.map (fun h => (PRE_first_tail_x6_r0_body.cx0_13.mlx.objs.get h).map PRE_first_tail_x6_r0_body.kappa13.nobj)
kernel_rfl PRE_first_tail_x6_r0_body.fok13 : PRE_first_tail_x6_r0_body.clo13.all (objOK PRE_first_tail_x6_r0_body.kappa13 PRE_first_tail_x6_r0_body.P13.NL PRE_first_tail_x6_r0_body.cx0_13.mlx) = true
kernel_rfl PRE_first_tail_x6_r0_body.fnd13 : PRE_first_tail_x6_r0_body.cln13.all (nodeOKF PRE_first_tail_x6_r0_body.kappa13 PRE_first_tail_x6_r0_body.P13 PRE_first_tail_x6_r0_body.cx0_13.mlx PRE_first_tail_x6_r0_body.cx1_13.mlx) = true
kernel_rfl PRE_first_tail_x6_r0_body.fp13 : ((PRE_first_tail_x6_r0_body.cln13.filter (fullB PRE_first_tail_x6_r0_body.P13))).map (fun i => (PRE_first_tail_x6_r0_body.cx1_13.mlx.nodes.get (PRE_first_tail_x6_r0_body.kappa13.node i)).map Host.Mlx.Ffi.Node.prim) =
  ((PRE_first_tail_x6_r0_body.cln13.filter (fullB PRE_first_tail_x6_r0_body.P13))).map (fun i => (PRE_first_tail_x6_r0_body.cx0_13.mlx.nodes.get i).map fun nd => PRE_first_tail_x6_r0_body.kappa13.prim nd.prim)
kernel_rfl PRE_first_tail_x6_r0_body.fnordI13 : incrB PRE_first_tail_x6_r0_body.kd13.nodeF (List.range' 15555 0) = true
kernel_rfl PRE_first_tail_x6_r0_body.fnordK13 : (PTrie.keysA PRE_first_tail_x6_r0_body.kd13.node).all (fun k => Nat.ble 15555 k && Nat.blt k 15555) = true
kernel_rfl PRE_first_tail_x6_r0_body.fnordL13 : (PRE_first_tail_x6_r0_body.cln13.filter (Nat.ble PRE_first_tail_x6_r0_body.P13.N0)).all (fun i => Nat.ble i (PRE_first_tail_x6_r0_body.kd13.nodeF i) && (Nat.blt i 15555 || Nat.ble PRE_first_tail_x6_r0_body.kd13.nn0 i)) = true
theorem PRE_first_tail_x6_r0_body.fnord13 : (PRE_first_tail_x6_r0_body.cln13.filter (Nat.ble PRE_first_tail_x6_r0_body.P13.N0)).all (fun i => Nat.ble i (PRE_first_tail_x6_r0_body.kd13.nodeF i) &&
    (PTrie.keysA PRE_first_tail_x6_r0_body.kd13.node).all fun j => !Nat.blt j i || Nat.blt (PRE_first_tail_x6_r0_body.kd13.nodeF j) (PRE_first_tail_x6_r0_body.kd13.nodeF i)) = true :=
  cnord_of PRE_first_tail_x6_r0_body.cnlow13 PRE_first_tail_x6_r0_body.cnn113 PRE_first_tail_x6_r0_body.fnordI13 PRE_first_tail_x6_r0_body.fnordK13 PRE_first_tail_x6_r0_body.fnordL13
kernel_rfl PRE_first_tail_x6_r0_body.fi13 : PRE_first_tail_x6_r0_body.cli13.all (pnB PRE_first_tail_x6_r0_body.cx0_13.mlx) = true
kernel_rfl PRE_first_tail_x6_r0_body.fii13 : PRE_first_tail_x6_r0_body.cli13.all (fun k => decide (PRE_first_tail_x6_r0_body.cx1_13.mlx.items.get (PRE_first_tail_x6_r0_body.kappa13.node k) = (PRE_first_tail_x6_r0_body.cx0_13.mlx.items.get k).map PRE_first_tail_x6_r0_body.kappa13.nv)) = true
/-- **The compaction's footprint.** -/
theorem PRE_first_tail_x6_r0_body.cfoot13 (clean : Conv.NClean (⟨18468, 15555, 2685371, 635⟩ : Conv.Cnt) (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.s139.ffi).mlx) (hltC : ∀ h, PH (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.s139.ffi).mlx h → h < (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.s139.ffi).mlx.next) (nltC : ∀ i, PN (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.s139.ffi).mlx i → i < (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.s139.ffi).mlx.nnext) (itemsC : ∀ k v, (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.s139.ffi).mlx.items.get k = some v → PN (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.s139.ffi).mlx k) (tracedC : ∀ h o, (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.s139.ffi).mlx.objs.get h = some o → ∀ i ∈ objTraces o, i < PRE_first_tail_x6_r0_body.P13.NL) (cl : SSt (· < 635) PRE_first_tail_x6_r0_body.cx0_13.mlx) :
    Conv.MFoot PRE_first_tail_x6_r0_body.P13 635 PRE_first_tail_x6_r0_body.kappa13 PRE_first_tail_x6_r0_body.kd13 PRE_first_tail_x6_r0_body.khinv13 PRE_first_tail_x6_r0_body.kninv13 (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.s139.ffi).mlx PRE_first_tail_x6_r0_body.cx0_13.mlx PRE_first_tail_x6_r0_body.cx1_13.mlx (⟨18468, 15555, 2685371, 635⟩ : Conv.Cnt) PRE_first_tail_x6_r0_body.clo13 PRE_first_tail_x6_r0_body.cln13 PRE_first_tail_x6_r0_body.cli13 PRE_first_tail_x6_r0_body.cwS13 PRE_first_tail_x6_r0_body.cnS13 PRE_first_tail_x6_r0_body.ciS13 :=
  ⟨rfl, rfl, rfl, PRE_first_tail_x6_r0_body.cnh013, PRE_first_tail_x6_r0_body.cnh113, PRE_first_tail_x6_r0_body.cnn013, PRE_first_tail_x6_r0_body.cnn113, PRE_first_tail_x6_r0_body.cplo13, PRE_first_tail_x6_r0_body.ccnt13, PRE_first_tail_x6_r0_body.cnband13, PRE_first_tail_x6_r0_body.chbelow13, PRE_first_tail_x6_r0_body.chren13, PRE_first_tail_x6_r0_body.cband13, PRE_first_tail_x6_r0_body.cnh1pos13, PRE_first_tail_x6_r0_body.cnren13, PRE_first_tail_x6_r0_body.cnlow13, PRE_first_tail_x6_r0_body.cabs0a13, PRE_first_tail_x6_r0_body.cabs0b13, PRE_first_tail_x6_r0_body.ctok113, PRE_first_tail_x6_r0_body.cpend13, PRE_first_tail_x6_r0_body.cerrh13, PRE_first_tail_x6_r0_body.cfiles13, PRE_first_tail_x6_r0_body.carch13, PRE_first_tail_x6_r0_body.csizes13, PRE_first_tail_x6_r0_body.cwired13, PRE_first_tail_x6_r0_body.cfix13, clean, PRE_first_tail_x6_r0_body.fcxn13, PRE_first_tail_x6_r0_body.fcnn13, hltC, nltC, itemsC, tracedC, cl, PRE_first_tail_x6_r0_body.fle013, PRE_first_tail_x6_r0_body.fnk13, PRE_first_tail_x6_r0_body.ckA13, PRE_first_tail_x6_r0_body.cobjsK13, PRE_first_tail_x6_r0_body.cnodesK13, PRE_first_tail_x6_r0_body.citemsK13, PRE_first_tail_x6_r0_body.f1A13, PRE_first_tail_x6_r0_body.f1O13, PRE_first_tail_x6_r0_body.f1N13, PRE_first_tail_x6_r0_body.f1I13, PRE_first_tail_x6_r0_body.fbd13, PRE_first_tail_x6_r0_body.fincW13, PRE_first_tail_x6_r0_body.fincI13, PRE_first_tail_x6_r0_body.fincN13, PRE_first_tail_x6_r0_body.flnF13, PRE_first_tail_x6_r0_body.fh13, PRE_first_tail_x6_r0_body.fo13, PRE_first_tail_x6_r0_body.fok13, PRE_first_tail_x6_r0_body.fnd13, PRE_first_tail_x6_r0_body.fp13, PRE_first_tail_x6_r0_body.fnord13, PRE_first_tail_x6_r0_body.fi13, PRE_first_tail_x6_r0_body.fii13⟩
theorem PRE_first_tail_x6_r0_body.cnshift13 (clean : Conv.NClean (⟨18468, 15555, 2685371, 635⟩ : Conv.Cnt) (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.s139.ffi).mlx) (hltC : ∀ h, PH (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.s139.ffi).mlx h → h < (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.s139.ffi).mlx.next) (nltC : ∀ i, PN (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.s139.ffi).mlx i → i < (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.s139.ffi).mlx.nnext) (itemsC : ∀ k v, (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.s139.ffi).mlx.items.get k = some v → PN (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.s139.ffi).mlx k) (tracedC : ∀ h o, (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.s139.ffi).mlx.objs.get h = some o → ∀ i ∈ objTraces o, i < PRE_first_tail_x6_r0_body.P13.NL) (cl : SSt (· < 635) PRE_first_tail_x6_r0_body.cx0_13.mlx) : NShift PRE_first_tail_x6_r0_body.P13 635 PRE_first_tail_x6_r0_body.kappa13 PRE_first_tail_x6_r0_body.cx0_13 PRE_first_tail_x6_r0_body.cx1_13 :=
  Conv.nshift_of_foot (PRE_first_tail_x6_r0_body.cfoot13 clean hltC nltC itemsC tracedC cl) PRE_first_tail_x6_r0_body.chost13 (compact_a_eq PRE_first_tail_x6_r0_body.ckn013 PRE_first_tail_x6_r0_body.ckn113 PRE_first_tail_x6_r0_body.ckheap13 PRE_first_tail_x6_r0_body.ckpl13)

-- the observers: the layers' states at the call, the canonical and the merged state, their footprints and checks
noncomputable def PRE_first_tail_x6_r0_body.fxC_13 : PTrie Unit := (Host.Ts.Sim.Full.freedOf PRE_first_tail_x6_r0_body.s139.ffi).getD PTrie.nil
noncomputable def PRE_first_tail_x6_r0_body.krC_13 : Host.Load.Layers.KRec := (Host.Ts.Sim.Full.krecOf PRE_first_tail_x6_r0_body.s139.ffi).getD Host.Load.Layers.KRec.empty
kernel_rfl PRE_first_tail_x6_r0_body.ofxC_13 : (Host.Ts.Sim.Full.freedOf PRE_first_tail_x6_r0_body.s139.ffi) = some PRE_first_tail_x6_r0_body.fxC_13
kernel_rfl PRE_first_tail_x6_r0_body.okrC_13 : (Host.Ts.Sim.Full.krecOf PRE_first_tail_x6_r0_body.s139.ffi) = some PRE_first_tail_x6_r0_body.krC_13
noncomputable def PRE_first_tail_x6_r0_body.fx0_13 : PTrie Unit := (Host.Ts.Sim.Full.freedOf PRE_first_tail_x6_r0_body.s141.ffi).getD PTrie.nil
noncomputable def PRE_first_tail_x6_r0_body.kr0_13 : Host.Load.Layers.KRec := (Host.Ts.Sim.Full.krecOf PRE_first_tail_x6_r0_body.s141.ffi).getD Host.Load.Layers.KRec.empty
kernel_rfl PRE_first_tail_x6_r0_body.ofx0_13 : (Host.Ts.Sim.Full.freedOf PRE_first_tail_x6_r0_body.s141.ffi) = some PRE_first_tail_x6_r0_body.fx0_13
kernel_rfl PRE_first_tail_x6_r0_body.okr0_13 : (Host.Ts.Sim.Full.krecOf PRE_first_tail_x6_r0_body.s141.ffi) = some PRE_first_tail_x6_r0_body.kr0_13
noncomputable def PRE_first_tail_x6_r0_body.fx1_13 : PTrie Unit := (Host.Ts.Sim.Full.freedOf PRE_first_tail_x6_r0_body.s140.ffi).getD PTrie.nil
noncomputable def PRE_first_tail_x6_r0_body.kr1_13 : Host.Load.Layers.KRec := (Host.Ts.Sim.Full.krecOf PRE_first_tail_x6_r0_body.s140.ffi).getD Host.Load.Layers.KRec.empty
kernel_rfl PRE_first_tail_x6_r0_body.ofx1_13 : (Host.Ts.Sim.Full.freedOf PRE_first_tail_x6_r0_body.s140.ffi) = some PRE_first_tail_x6_r0_body.fx1_13
kernel_rfl PRE_first_tail_x6_r0_body.okr1_13 : (Host.Ts.Sim.Full.krecOf PRE_first_tail_x6_r0_body.s140.ffi) = some PRE_first_tail_x6_r0_body.kr1_13
kernel_rfl PRE_first_tail_x6_r0_body.ff013 : PRE_first_tail_x6_r0_body.fx0_13 = Stage.setAll PRE_first_tail_x6_r0_body.fxC_13 (PRE_first_tail_x6_r0_body.clo13.filterMap fun i => (PRE_first_tail_x6_r0_body.fx0_13.get i).map (i, ·))
kernel_rfl PRE_first_tail_x6_r0_body.ff113 : PRE_first_tail_x6_r0_body.fx1_13 = Stage.setAll PRE_first_tail_x6_r0_body.fxC_13 (PRE_first_tail_x6_r0_body.cwS13.filterMap fun i => (PRE_first_tail_x6_r0_body.fx1_13.get i).map (i, ·))
kernel_rfl PRE_first_tail_x6_r0_body.ffck13 : freedLB PRE_first_tail_x6_r0_body.kappa13 PRE_first_tail_x6_r0_body.cx0_13.mlx PRE_first_tail_x6_r0_body.fx0_13 PRE_first_tail_x6_r0_body.fx1_13 PRE_first_tail_x6_r0_body.clo13 = true
kernel_rfl PRE_first_tail_x6_r0_body.fkf013 : PRE_first_tail_x6_r0_body.kr0_13.flags = Stage.setAll PRE_first_tail_x6_r0_body.krC_13.flags (PRE_first_tail_x6_r0_body.clo13.filterMap fun i => (PRE_first_tail_x6_r0_body.kr0_13.flags.get i).map (i, ·))
kernel_rfl PRE_first_tail_x6_r0_body.fkt013 : PRE_first_tail_x6_r0_body.kr0_13.targs = Stage.setAll PRE_first_tail_x6_r0_body.krC_13.targs (PRE_first_tail_x6_r0_body.clo13.filterMap fun i => (PRE_first_tail_x6_r0_body.kr0_13.targs.get i).map (i, ·))
kernel_rfl PRE_first_tail_x6_r0_body.fkf113 : PRE_first_tail_x6_r0_body.kr1_13.flags = Stage.setAll PRE_first_tail_x6_r0_body.krC_13.flags (PRE_first_tail_x6_r0_body.cwS13.filterMap fun i => (PRE_first_tail_x6_r0_body.kr1_13.flags.get i).map (i, ·))
kernel_rfl PRE_first_tail_x6_r0_body.fkt113 : PRE_first_tail_x6_r0_body.kr1_13.targs = Stage.setAll PRE_first_tail_x6_r0_body.krC_13.targs (PRE_first_tail_x6_r0_body.cwS13.filterMap fun i => (PRE_first_tail_x6_r0_body.kr1_13.targs.get i).map (i, ·))
kernel_rfl PRE_first_tail_x6_r0_body.fkck13 : krecLB PRE_first_tail_x6_r0_body.kappa13 635 PRE_first_tail_x6_r0_body.cx0_13.mlx PRE_first_tail_x6_r0_body.kr0_13 PRE_first_tail_x6_r0_body.kr1_13 PRE_first_tail_x6_r0_body.clo13 = true
kernel_rfl PRE_first_tail_x6_r0_body.fkn13 : Nat.ble 635 635 = true
-- the bridge and the pending traces' regions
kernel_rfl PRE_first_tail_x6_r0_body.cbridge13 : Host.Ts.Sim.Full.bridgeOf PRE_first_tail_x6_r0_body.s140.ffi = Host.Ts.Sim.Full.bridgeOf PRE_first_tail_x6_r0_body.s141.ffi
kernel_rfl PRE_first_tail_x6_r0_body.cpendR13 : pendRegB PRE_first_tail_x6_r0_body.kappa13 (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.s141.ffi).mlx = true
kernel_rfl PRE_first_tail_x6_r0_body.cpendLe13 : Nat.ble (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.s141.ffi).mlx.next (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.s140.ffi).mlx.next = true
/-- **The compaction's native shift**, given the call's bookkeeping, its relation's facts (the model's and the
observers') and the canonical closedness. -/
theorem PRE_first_tail_x6_r0_body.cshift13 (clean : Conv.NClean (⟨18468, 15555, 2685371, 635⟩ : Conv.Cnt) (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.s139.ffi).mlx) (hltC : ∀ h, PH (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.s139.ffi).mlx h → h < (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.s139.ffi).mlx.next) (nltC : ∀ i, PN (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.s139.ffi).mlx i → i < (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.s139.ffi).mlx.nnext) (itemsC : ∀ k v, (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.s139.ffi).mlx.items.get k = some v → PN (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.s139.ffi).mlx k) (tracedC : ∀ h o, (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.s139.ffi).mlx.objs.get h = some o → ∀ i ∈ objTraces o, i < PRE_first_tail_x6_r0_body.P13.NL) (cl : SSt (· < 635) PRE_first_tail_x6_r0_body.cx0_13.mlx)
    (hobjC : ∀ h, PRE_first_tail_x6_r0_body.fxC_13.get h = some () → ((Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.s139.ffi).mlx.objs.get h).isSome = true)
    (hfC : ∀ h, (PRE_first_tail_x6_r0_body.krC_13.flags.get h).isSome = true → ((Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.s139.ffi).mlx.objs.get h).isSome = true)
    (htC : ∀ h, (PRE_first_tail_x6_r0_body.krC_13.targs.get h).isSome = true → ((Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.s139.ffi).mlx.objs.get h).isSome = true)
    (hclC : ∀ h l, PRE_first_tail_x6_r0_body.krC_13.targs.get h = some l → Host.Ts.Sim.Full.STargs (· < (⟨18468, 15555, 2685371, 635⟩ : Conv.Cnt).n) l) :
    Conv.FullShiftQ PRE_first_tail_x6_r0_body.P13 635 PRE_first_tail_x6_r0_body.kappa13 PRE_first_tail_x6_r0_body.s141.ffi PRE_first_tail_x6_r0_body.s140.ffi :=
  ⟨PRE_first_tail_x6_r0_body.cnshift13 clean hltC nltC itemsC tracedC cl, PRE_first_tail_x6_r0_body.cqueue13, fun t ht => bSN_sound (List.all_eq_true.mp PRE_first_tail_x6_r0_body.ctokSupp13 t ht),
    PRE_first_tail_x6_r0_body.cbridge13,
    liveShift_foot (x0' := Host.Ts.Sim.Full.mlxOf PRE_first_tail_x6_r0_body.s141.ffi) (x1' := Host.Ts.Sim.Full.mlxOf PRE_first_tail_x6_r0_body.s140.ffi) (PRE_first_tail_x6_r0_body.cfoot13 clean hltC nltC itemsC tracedC cl) rfl PRE_first_tail_x6_r0_body.ofx0_13 PRE_first_tail_x6_r0_body.ofx1_13 hobjC PRE_first_tail_x6_r0_body.ff013 PRE_first_tail_x6_r0_body.ff113 PRE_first_tail_x6_r0_body.ffck13,
    kernShift_foot (x0' := Host.Ts.Sim.Full.mlxOf PRE_first_tail_x6_r0_body.s141.ffi) (x1' := Host.Ts.Sim.Full.mlxOf PRE_first_tail_x6_r0_body.s140.ffi) (PRE_first_tail_x6_r0_body.cfoot13 clean hltC nltC itemsC tracedC cl) rfl PRE_first_tail_x6_r0_body.okr0_13 PRE_first_tail_x6_r0_body.okr1_13 (Nat.le_of_ble_eq_true PRE_first_tail_x6_r0_body.fkn13) hfC htC hclC
      PRE_first_tail_x6_r0_body.fkf013 PRE_first_tail_x6_r0_body.fkt013 PRE_first_tail_x6_r0_body.fkf113 PRE_first_tail_x6_r0_body.fkt113 PRE_first_tail_x6_r0_body.fkck13,
    pendReg_of rfl PRE_first_tail_x6_r0_body.cnh013 PRE_first_tail_x6_r0_body.cnh113 (Nat.le_of_ble_eq_true PRE_first_tail_x6_r0_body.cpendLe13) PRE_first_tail_x6_r0_body.cpendR13⟩

end Host.Load.Run.Tpl
end

section -- st13/H0
set_option Elab.async false
namespace Host.Load.Run.Tpl
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
host_stream_state PRE_first_tail_x6_r0_body.st13 0
host_stream_state PRE_first_tail_x6_r0_body.st13 1
host_stream_state PRE_first_tail_x6_r0_body.st13 2
end Host.Load.Run.Tpl
end

section -- Site13
set_option Elab.async false
namespace Host.Load.Run.Tpl
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
open Host.Ts Host.Ts.Sim Host.Ts.Sim.Template

/-! Call site 13 of chain `PRE_first_tail_x6_r0_body`: `rowBlocks__g13__g14` (`rowBlocks`), the call state `PRE_first_tail_x6_r0_body.s139`, the merged state `PRE_first_tail_x6_r0_body.s140`,
the site template `PRE_first_tail_x6_r0_body.st13` (σ = `Map.id`, θ the identity at its own site), the canonical state `PRE_first_tail_x6_r0_body.s141`: the merge.
The footprint's facts are in `SiteF13`, the compaction's in `SiteC13`, `SiteK13`, `SiteNa13`, `SiteNb13`. -/

kernel_rfl PRE_first_tail_x6_r0_body.iso13 : PRE_first_tail_x6_r0_body.st13.s0 = { PRE_first_tail_x6_r0_body.s139 with stack := [] }
/-- The caller's frames at the call. -/
noncomputable def PRE_first_tail_x6_r0_body.rs13 : List Frame := PRE_first_tail_x6_r0_body.s139.stack
kernel_rfl PRE_first_tail_x6_r0_body.n0_13 : PRE_first_tail_x6_r0_body.S139.tab.length = 635
kernel_rfl PRE_first_tail_x6_r0_body.tab0_13 : PRE_first_tail_x6_r0_body.st13.S0.tab = PRE_first_tail_x6_r0_body.S139.tab

/-- The fresh variables of the stage's results. -/
def PRE_first_tail_x6_r0_body.ws13 : List Nat := [1248, 1249]
kernel_rfl PRE_first_tail_x6_r0_body.fresh13 : (PRE_first_tail_x6_r0_body.S139.tab.all fun e => PRE_first_tail_x6_r0_body.ws13.all fun v => e.noVar v) &&
    (PRE_first_tail_x6_r0_body.S139.oracle.all fun q => PRE_first_tail_x6_r0_body.ws13.all fun v => q.noVar v) = true
kernel_rfl PRE_first_tail_x6_r0_body.mergeTab13 : PRE_first_tail_x6_r0_body.S140.tab = PRE_first_tail_x6_r0_body.S139.tab ++ Conv.resTab PRE_first_tail_x6_r0_body.ws13
kernel_rfl PRE_first_tail_x6_r0_body.mergeLen13 : PRE_first_tail_x6_r0_body.st13.S2.tab.length - PRE_first_tail_x6_r0_body.st13.S0.tab.length = 2

-- The merged state: the instance's return state with the caller's frames (`PRE_first_tail_x6_r0_body.merged13`, `merged_relB`).
kernel_rfl PRE_first_tail_x6_r0_body.mheap13 : PRE_first_tail_x6_r0_body.s140.heap = PRE_first_tail_x6_r0_body.st13.s2.heap
kernel_rfl PRE_first_tail_x6_r0_body.mnext13 : PRE_first_tail_x6_r0_body.s140.next = PRE_first_tail_x6_r0_body.st13.s2.next
kernel_rfl PRE_first_tail_x6_r0_body.mctl13 : PRE_first_tail_x6_r0_body.s140.ctl = PRE_first_tail_x6_r0_body.st13.s2.ctl
kernel_rfl PRE_first_tail_x6_r0_body.mstack13 : PRE_first_tail_x6_r0_body.s140.stack = PRE_first_tail_x6_r0_body.st13.s2.stack ++ PRE_first_tail_x6_r0_body.s139.stack
kernel_rfl PRE_first_tail_x6_r0_body.mjobs13 : PRE_first_tail_x6_r0_body.s140.jobs = PRE_first_tail_x6_r0_body.st13.s2.jobs
kernel_rfl PRE_first_tail_x6_r0_body.mffi13 : PRE_first_tail_x6_r0_body.s140.ffi = PRE_first_tail_x6_r0_body.st13.s2.ffi
kernel_rfl PRE_first_tail_x6_r0_body.mtrace13 : PRE_first_tail_x6_r0_body.s140.trace = PRE_first_tail_x6_r0_body.st13.s2.trace
kernel_rfl PRE_first_tail_x6_r0_body.mstores13 : PRE_first_tail_x6_r0_body.s140.stores = PRE_first_tail_x6_r0_body.st13.s2.stores

end Host.Load.Run.Tpl
end

section -- SiteD13
set_option Elab.async false
namespace Host.Load.Run.Tpl
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
open Host.Ts Host.Ts.Sim Host.Ts.Sim.Template

/-! The canonical results at call site 13 of chain `PRE_first_tail_x6_r0_body`: their values in the instance's end table, the references past
the call's table, the canonical variables apart from the stage's. -/

kernel_rfl PRE_first_tail_x6_r0_body.cderived13 : PRE_first_tail_x6_r0_body.nr13.map (fun r => nth? PRE_first_tail_x6_r0_body.st13.S2.tab r) =
  []
kernel_rfl PRE_first_tail_x6_r0_body.cnrLo13 : PRE_first_tail_x6_r0_body.nr13.all (Nat.ble 635) = true
kernel_rfl PRE_first_tail_x6_r0_body.cwsDisj13 : PRE_first_tail_x6_r0_body.cws13.all (fun c => !PRE_first_tail_x6_r0_body.ws13.contains c) = true
/-- The compaction's substitution: the canonical variables to their merged values, the stage's other fresh variables
to `0` (`Conv.compactθZ`). -/
noncomputable def PRE_first_tail_x6_r0_body.cthetaZ13 : Nat → SymE := Conv.compactθZ PRE_first_tail_x6_r0_body.cws13 PRE_first_tail_x6_r0_body.crs13 PRE_first_tail_x6_r0_body.ws13

end Host.Load.Run.Tpl
end

section -- st13/Foot
set_option Elab.async false
namespace Host.Load.Run.Tpl
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
open Host.Ts Host.Ts.Sim Host.Ts.Sim.Stage Host.Ts.Sim.Template

/-! The footprint of stage `PRE_first_tail_x6_r0_body.st13`'s site template (`Conv.StageFoot`, `Conv.NFoot`): every entry of the return
state other than the written and fresh ones is the start's (kernel evaluation of the equalities). -/

/-- The written heap ranges below the start's counter. -/
def PRE_first_tail_x6_r0_body.st13.wrR : List (Nat × Nat) := []
/-- The written and fresh entries of the return state. -/
noncomputable def PRE_first_tail_x6_r0_body.st13.wrE : List (Nat × Host.Ts.HObj) :=
  rangesOf PRE_first_tail_x6_r0_body.st13.s2.heap PRE_first_tail_x6_r0_body.st13.wrR ++ freshOf PRE_first_tail_x6_r0_body.st13.s2.heap PRE_first_tail_x6_r0_body.st13.s0.next PRE_first_tail_x6_r0_body.st13.s2.next
noncomputable def PRE_first_tail_x6_r0_body.st13.wr : List Nat := PRE_first_tail_x6_r0_body.st13.wrE.map (·.1)

kernel_rfl PRE_first_tail_x6_r0_body.st13.heapFoot : PRE_first_tail_x6_r0_body.st13.s2.heap = setAll PRE_first_tail_x6_r0_body.st13.s0.heap PRE_first_tail_x6_r0_body.st13.wrE
kernel_rfl PRE_first_tail_x6_r0_body.st13.grows_check : Nat.ble PRE_first_tail_x6_r0_body.st13.s0.next PRE_first_tail_x6_r0_body.st13.s2.next = true
theorem PRE_first_tail_x6_r0_body.st13.grows : PRE_first_tail_x6_r0_body.st13.s0.next ≤ PRE_first_tail_x6_r0_body.st13.s2.next := Nat.le_of_ble_eq_true PRE_first_tail_x6_r0_body.st13.grows_check

/-- The written and fresh handles; the written readback items of old nodes. -/
def PRE_first_tail_x6_r0_body.st13.wh : List Nat := []
def PRE_first_tail_x6_r0_body.st13.wi : List Nat := []

kernel_rfl PRE_first_tail_x6_r0_body.st13.arrsFoot : (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.st13.s2.ffi).mlx.arrs = setAll (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.st13.s0.ffi).mlx.arrs (PRE_first_tail_x6_r0_body.st13.wh.filterMap fun h => ((Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.st13.s2.ffi).mlx.arrs.get h).map (h, ·))
kernel_rfl PRE_first_tail_x6_r0_body.st13.objsFoot : (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.st13.s2.ffi).mlx.objs = setAll (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.st13.s0.ffi).mlx.objs (PRE_first_tail_x6_r0_body.st13.wh.filterMap fun h => ((Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.st13.s2.ffi).mlx.objs.get h).map (h, ·))
kernel_rfl PRE_first_tail_x6_r0_body.st13.nodesFoot : (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.st13.s2.ffi).mlx.nodes = setAll (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.st13.s0.ffi).mlx.nodes (freshOf (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.st13.s2.ffi).mlx.nodes (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.st13.s0.ffi).mlx.nnext (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.st13.s2.ffi).mlx.nnext)
kernel_rfl PRE_first_tail_x6_r0_body.st13.itemsFoot : (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.st13.s2.ffi).mlx.items = setAll (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.st13.s0.ffi).mlx.items ((PRE_first_tail_x6_r0_body.st13.wi.filterMap fun i => ((Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.st13.s2.ffi).mlx.items.get i).map (i, ·)) ++
    freshOf (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.st13.s2.ffi).mlx.items (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.st13.s0.ffi).mlx.nnext (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.st13.s2.ffi).mlx.nnext)
kernel_rfl PRE_first_tail_x6_r0_body.st13.counters : (Nat.ble (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.st13.s0.ffi).mlx.next (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.st13.s2.ffi).mlx.next && Nat.ble (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.st13.s0.ffi).mlx.nnext (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.st13.s2.ffi).mlx.nnext) = true

end Host.Load.Run.Tpl
end

section -- SiteF13
set_option Elab.async false
namespace Host.Load.Run.Tpl
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
open Host.Ts Host.Ts.Sim Host.Ts.Sim.Template

/-! Call site 13 of chain `PRE_first_tail_x6_r0_body`: `Conv.site_merge`'s footprint facts. -/

kernel_rfl PRE_first_tail_x6_r0_body.wrNodupB13 : nodupT PRE_first_tail_x6_r0_body.st13.wr PTrie.nil = true
theorem PRE_first_tail_x6_r0_body.wrNodup13 : PRE_first_tail_x6_r0_body.st13.wr.Nodup := (nodupT_sound PRE_first_tail_x6_r0_body.wrNodupB13).2
kernel_rfl PRE_first_tail_x6_r0_body.wrBoundB13 : PRE_first_tail_x6_r0_body.st13.wr.all (fun b => Nat.blt (b / 4096) (4 ^ 31)) = true
theorem PRE_first_tail_x6_r0_body.wrBound13 : ∀ b ∈ PRE_first_tail_x6_r0_body.st13.wr, b / 4096 < 4 ^ 31 := fun b hb => Nat.blt_eq.mp (List.all_eq_true.mp PRE_first_tail_x6_r0_body.wrBoundB13 b hb)
noncomputable def PRE_first_tail_x6_r0_body.trFr13 := PRE_first_tail_x6_r0_body.st13.s2.trace.take 0
kernel_rfl PRE_first_tail_x6_r0_body.traceEq13 : PRE_first_tail_x6_r0_body.st13.s2.trace = PRE_first_tail_x6_r0_body.trFr13 ++ PRE_first_tail_x6_r0_body.st13.s0.trace
theorem PRE_first_tail_x6_r0_body.trace13 : ∃ fr, PRE_first_tail_x6_r0_body.st13.s2.trace = fr ++ PRE_first_tail_x6_r0_body.st13.s0.trace := ⟨_, PRE_first_tail_x6_r0_body.traceEq13⟩

-- the caller's wide frames at the instance's start (`Conv.isolateW`'s `W0` under `Map.id`) and their `WFix`
def PRE_first_tail_x6_r0_body.wide13 : List (Nat × WFrame) := [(4910, .memo [])]
kernel_rfl PRE_first_tail_x6_r0_body.wfixB13 : (PRE_first_tail_x6_r0_body.wide13.all fun p => wfixB Map.id (presentB PRE_first_tail_x6_r0_body.st13.s0) p.2) = true
theorem PRE_first_tail_x6_r0_body.wfix13 : ∀ p ∈ PRE_first_tail_x6_r0_body.wide13, WFix Map.id (Present PRE_first_tail_x6_r0_body.st13.s0) p.2 :=
  fun p hp => wfix_of (List.all_eq_true.mp PRE_first_tail_x6_r0_body.wfixB13 p hp)

end Host.Load.Run.Tpl
end

section -- SiteL13
set_option Elab.async false
namespace Host.Load.Run.Tpl
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
open Host.Ts Host.Ts.Sim Host.Ts.Sim.Template

/-! The call link's facts at call site 13 of chain `PRE_first_tail_x6_r0_body`: the instance's start server, its footprint (`Conv.StageFoot`), the
merged state `PRE_first_tail_x6_r0_body.s140`'s framed arrays as the chain start's extended (`arrExt_of`, `numRefs_of`). -/

kernel_rfl PRE_first_tail_x6_r0_body.srvO13 : PRE_first_tail_x6_r0_body.st13.S0.oracle = PRE_first_tail_x6_r0_body.st13.OR
kernel_rfl PRE_first_tail_x6_r0_body.wr0B13 : PRE_first_tail_x6_r0_body.st13.wr.all (fun b => !Nat.blt b PRE_first_tail_x6_r0_body.st13.s0.next || (PRE_first_tail_x6_r0_body.st13.s0.heap.get b).isSome) = true
theorem PRE_first_tail_x6_r0_body.stFoot13 : Conv.StageFoot PRE_first_tail_x6_r0_body.st13.wr PRE_first_tail_x6_r0_body.st13.s0 PRE_first_tail_x6_r0_body.st13.s2 :=
  stageFoot_of PRE_first_tail_x6_r0_body.st13.heapFoot PRE_first_tail_x6_r0_body.wrNodup13 PRE_first_tail_x6_r0_body.wrBound13 PRE_first_tail_x6_r0_body.wr0B13 PRE_first_tail_x6_r0_body.st13.grows

/-- **The relation at the merged state** from the relation at the merge (`Conv.site_merge`'s; `merged_relB`). -/
theorem PRE_first_tail_x6_r0_body.merged13 {FR : Map → Nat → PRE_first_tail_x6_r0_body.st13.F.S → PRE_first_tail_x6_r0_body.st13.F.S → Prop} {W : Nat → Option WFrame} {stk : List Frame} {M : Map}
    {ν : Nat → F64} {K : Host.Ts.Sim.Ctx} {S : SSrv} {t : St PRE_first_tail_x6_r0_body.st13.F.S} {C : CSrv} {n0 : Nat}
    (h : RelB PRE_first_tail_x6_r0_body.st13.F FR W stk M ν K (Conv.mergeSt Map.id (Map.id.res n0 n0) PRE_first_tail_x6_r0_body.rs13 PRE_first_tail_x6_r0_body.st13.wr PRE_first_tail_x6_r0_body.s139 PRE_first_tail_x6_r0_body.st13.s2 PRE_first_tail_x6_r0_body.st13.s0
      PRE_first_tail_x6_r0_body.st13.s2.ffi) S t C) : RelB PRE_first_tail_x6_r0_body.st13.F FR W stk M ν K PRE_first_tail_x6_r0_body.s140 S t C :=
  merged_relB PRE_first_tail_x6_r0_body.iso13 PRE_first_tail_x6_r0_body.stFoot13 PRE_first_tail_x6_r0_body.wrNodup13 PRE_first_tail_x6_r0_body.wrBound13 PRE_first_tail_x6_r0_body.trace13 PRE_first_tail_x6_r0_body.mheap13
    PRE_first_tail_x6_r0_body.mnext13 PRE_first_tail_x6_r0_body.mctl13 PRE_first_tail_x6_r0_body.mstack13 PRE_first_tail_x6_r0_body.mjobs13 PRE_first_tail_x6_r0_body.mffi13 PRE_first_tail_x6_r0_body.mtrace13 PRE_first_tail_x6_r0_body.mstores13 h

def PRE_first_tail_x6_r0_body.arrEl13_2665 : List Val := []
kernel_rfl PRE_first_tail_x6_r0_body.arrE13_2665 : arrOf PRE_first_tail_x6_r0_body.s140 2665 = arrOf PRE_first_tail_x6_r0_body.s0 2665 ++ PRE_first_tail_x6_r0_body.arrEl13_2665
kernel_rfl PRE_first_tail_x6_r0_body.arrA13_2665 : isArrB PRE_first_tail_x6_r0_body.s140 2665 = true
theorem PRE_first_tail_x6_r0_body.arr13_2665 : ∃ o, PRE_first_tail_x6_r0_body.s140.heap.get 2665 = some (.obj o) ∧ o.kind = .array (arrOf PRE_first_tail_x6_r0_body.s0 2665 ++ PRE_first_tail_x6_r0_body.arrEl13_2665) :=
  arrExt_of PRE_first_tail_x6_r0_body.arrE13_2665 PRE_first_tail_x6_r0_body.arrA13_2665
kernel_rfl PRE_first_tail_x6_r0_body.arrN13_2665 : numRefsB PRE_first_tail_x6_r0_body.S0.tab.length PRE_first_tail_x6_r0_body.arrEl13_2665 = true
theorem PRE_first_tail_x6_r0_body.arrR13_2665 : Prefill.NumRefs PRE_first_tail_x6_r0_body.S0.tab.length PRE_first_tail_x6_r0_body.arrEl13_2665 := numRefs_of PRE_first_tail_x6_r0_body.arrN13_2665

def PRE_first_tail_x6_r0_body.arrEl13_2673467 : List Val := []
kernel_rfl PRE_first_tail_x6_r0_body.arrE13_2673467 : arrOf PRE_first_tail_x6_r0_body.s140 2673467 = arrOf PRE_first_tail_x6_r0_body.s0 2673467 ++ PRE_first_tail_x6_r0_body.arrEl13_2673467
kernel_rfl PRE_first_tail_x6_r0_body.arrA13_2673467 : isArrB PRE_first_tail_x6_r0_body.s140 2673467 = true
theorem PRE_first_tail_x6_r0_body.arr13_2673467 : ∃ o, PRE_first_tail_x6_r0_body.s140.heap.get 2673467 = some (.obj o) ∧ o.kind = .array (arrOf PRE_first_tail_x6_r0_body.s0 2673467 ++ PRE_first_tail_x6_r0_body.arrEl13_2673467) :=
  arrExt_of PRE_first_tail_x6_r0_body.arrE13_2673467 PRE_first_tail_x6_r0_body.arrA13_2673467
kernel_rfl PRE_first_tail_x6_r0_body.arrN13_2673467 : numRefsB PRE_first_tail_x6_r0_body.S0.tab.length PRE_first_tail_x6_r0_body.arrEl13_2673467 = true
theorem PRE_first_tail_x6_r0_body.arrR13_2673467 : Prefill.NumRefs PRE_first_tail_x6_r0_body.S0.tab.length PRE_first_tail_x6_r0_body.arrEl13_2673467 := numRefs_of PRE_first_tail_x6_r0_body.arrN13_2673467

kernel_rfl PRE_first_tail_x6_r0_body.w4910k13 : isArrB PRE_first_tail_x6_r0_body.s140 4910 = false
theorem PRE_first_tail_x6_r0_body.keep13 (q : List Val) : Host.Ts.Sim.Prefill.KeepsAtW (framesP PRE_first_tail_x6_r0_body.s0 q) PRE_first_tail_x6_r0_body.s140 := by
  intro a pre pre' hx o es ho hk
  unfold framesP at hx
  simp only at hx
  cases h1 : Nat.beq a 2665
  · cases h2 : Nat.beq a 4910
    · rw [h1, h2] at hx; cases hx
    · have := Nat.eq_of_beq_eq_true h2; subst this
      rw [h1, h2] at hx; cases hx
      exact (notArr_of PRE_first_tail_x6_r0_body.w4910k13 ho hk).elim
  · have := Nat.eq_of_beq_eq_true h1; subst this
    rw [h1] at hx; cases hx
    obtain ⟨o', ho', hk'⟩ := PRE_first_tail_x6_r0_body.arr13_2665
    rw [ho] at ho'; cases ho'
    rw [hk'] at hk; cases hk
    simp [PRE_first_tail_x6_r0_body.arrEl13_2665]

end Host.Load.Run.Tpl
end

section -- SiteZ13
set_option Elab.async false
namespace Host.Load.Run.Tpl
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
open Host.Ts Host.Ts.Sim Host.Ts.Sim.Template

/-! The compaction's state shift at call site 13 of chain `PRE_first_tail_x6_r0_body` (`Conv.compact_shift`): the call `PRE_first_tail_x6_r0_body.s139`, the merged
state `PRE_first_tail_x6_r0_body.s140`, the canonical state `PRE_first_tail_x6_r0_body.s141`; its frames [2665,2673467,2673472,2673473] (kept arrays [2665,2673467]). -/

-- the map's places and counters
kernel_rfl PRE_first_tail_x6_r0_body.zpl13 : PRE_first_tail_x6_r0_body.pl13.all (Nat.ble PRE_first_tail_x6_r0_body.s139.next) = true
kernel_rfl PRE_first_tail_x6_r0_body.zplnd13 : nodupT PRE_first_tail_x6_r0_body.pl13 PTrie.nil = true
kernel_rfl PRE_first_tail_x6_r0_body.zn113 : Nat.ble PRE_first_tail_x6_r0_body.s139.next 2685373 = true
kernel_rfl PRE_first_tail_x6_r0_body.zfirst13 : Nat.ble aFirst PRE_first_tail_x6_r0_body.s139.next = true
kernel_rfl PRE_first_tail_x6_r0_body.zscn13 : PRE_first_tail_x6_r0_body.s141.next = PRE_first_tail_x6_r0_body.s139.next + PRE_first_tail_x6_r0_body.pl13.length
kernel_rfl PRE_first_tail_x6_r0_body.zsmn13 : PRE_first_tail_x6_r0_body.s140.next = 2685373
kernel_rfl PRE_first_tail_x6_r0_body.zgrow13 : Nat.ble PRE_first_tail_x6_r0_body.s141.next PRE_first_tail_x6_r0_body.s140.next = true
-- the tables
kernel_rfl PRE_first_tail_x6_r0_body.zfresh13 : PRE_first_tail_x6_r0_body.S139.tab.all (fun e => PRE_first_tail_x6_r0_body.cws13.all fun v => e.noVar v) = true
kernel_rfl PRE_first_tail_x6_r0_body.zcnd13 : nodupT PRE_first_tail_x6_r0_body.cws13 PTrie.nil = true
kernel_rfl PRE_first_tail_x6_r0_body.znrHi13 : PRE_first_tail_x6_r0_body.nr13.all (fun r => Nat.blt r PRE_first_tail_x6_r0_body.S140.tab.length) = true
-- the frames: every framed address below the call's counter; the kept arrays the chain start's, extended in the merged state
kernel_rfl PRE_first_tail_x6_r0_body.zfrlt13 : [2665, 2673467, 2673472, 2673473].all (fun a => Nat.blt a PRE_first_tail_x6_r0_body.s139.next) = true
kernel_rfl PRE_first_tail_x6_r0_body.zg13_2665 : PRE_first_tail_x6_r0_body.s141.heap.get 2665 = some (.obj (objOf PRE_first_tail_x6_r0_body.s141 2665))
kernel_rfl PRE_first_tail_x6_r0_body.zk13_2665 : (objOf PRE_first_tail_x6_r0_body.s141 2665).kind = .array (arrOf PRE_first_tail_x6_r0_body.s0 2665)
kernel_rfl PRE_first_tail_x6_r0_body.zm13_2665 : PRE_first_tail_x6_r0_body.s140.heap.get 2665 = some (.obj { PRE_first_tail_x6_r0_body.kappa13.obj (objOf PRE_first_tail_x6_r0_body.s141 2665) with
  kind := .array (arrOf PRE_first_tail_x6_r0_body.s0 2665 ++ (arrOf PRE_first_tail_x6_r0_body.s140 2665).drop (arrOf PRE_first_tail_x6_r0_body.s0 2665).length) })
kernel_rfl PRE_first_tail_x6_r0_body.zg13_2673467 : PRE_first_tail_x6_r0_body.s141.heap.get 2673467 = some (.obj (objOf PRE_first_tail_x6_r0_body.s141 2673467))
kernel_rfl PRE_first_tail_x6_r0_body.zk13_2673467 : (objOf PRE_first_tail_x6_r0_body.s141 2673467).kind = .array (arrOf PRE_first_tail_x6_r0_body.s0 2673467)
kernel_rfl PRE_first_tail_x6_r0_body.zm13_2673467 : PRE_first_tail_x6_r0_body.s140.heap.get 2673467 = some (.obj { PRE_first_tail_x6_r0_body.kappa13.obj (objOf PRE_first_tail_x6_r0_body.s141 2673467) with
  kind := .array (arrOf PRE_first_tail_x6_r0_body.s0 2673467 ++ (arrOf PRE_first_tail_x6_r0_body.s140 2673467).drop (arrOf PRE_first_tail_x6_r0_body.s0 2673467).length) })
kernel_rfl PRE_first_tail_x6_r0_body.zw13_4910 : (PRE_first_tail_x6_r0_body.s141.heap.get 4910).isSome = true
kernel_rfl PRE_first_tail_x6_r0_body.zw13_2673472 : (PRE_first_tail_x6_r0_body.s141.heap.get 2673472).isSome = true
kernel_rfl PRE_first_tail_x6_r0_body.zw13_2673473 : (PRE_first_tail_x6_r0_body.s141.heap.get 2673473).isSome = true
-- the heap: the changed list in range, holding the stage's written and fresh addresses; the canonical side's image
kernel_rfl PRE_first_tail_x6_r0_body.zclbd13 : PRE_first_tail_x6_r0_body.cl13.all (fun b => Nat.blt (b / 4096) (4 ^ 31)) = true
kernel_rfl PRE_first_tail_x6_r0_body.zwr13 : PRE_first_tail_x6_r0_body.st13.wr.all (fun b => !Nat.blt b PRE_first_tail_x6_r0_body.s139.next || PRE_first_tail_x6_r0_body.cl13.contains b) = true
def PRE_first_tail_x6_r0_body.zl13 : List Nat := PRE_first_tail_x6_r0_body.cl13.filter fun a => !(List.contains [2665, 2673467] a)
kernel_rfl PRE_first_tail_x6_r0_body.zimgE13 : PRE_first_tail_x6_r0_body.zl13.map (fun a => PRE_first_tail_x6_r0_body.s140.heap.get (PRE_first_tail_x6_r0_body.kappa13.a a)) = PRE_first_tail_x6_r0_body.zl13.map (fun a => (PRE_first_tail_x6_r0_body.s141.heap.get a).map PRE_first_tail_x6_r0_body.kappa13.hobj)
theorem PRE_first_tail_x6_r0_body.zimg13 : HeapImg PRE_first_tail_x6_r0_body.kappa13 PRE_first_tail_x6_r0_body.s141 PRE_first_tail_x6_r0_body.s140 PRE_first_tail_x6_r0_body.zl13 := PRE_first_tail_x6_r0_body.zimgE13
-- the roots and their supports
kernel_rfl PRE_first_tail_x6_r0_body.zctl13 : PRE_first_tail_x6_r0_body.s140.ctl = PRE_first_tail_x6_r0_body.kappa13.ctl PRE_first_tail_x6_r0_body.s141.ctl
kernel_rfl PRE_first_tail_x6_r0_body.zstack13 : PRE_first_tail_x6_r0_body.s140.stack = PRE_first_tail_x6_r0_body.s141.stack.map PRE_first_tail_x6_r0_body.kappa13.frame
kernel_rfl PRE_first_tail_x6_r0_body.zjobs13 : PRE_first_tail_x6_r0_body.s140.jobs = PRE_first_tail_x6_r0_body.s141.jobs.map PRE_first_tail_x6_r0_body.kappa13.job
kernel_rfl PRE_first_tail_x6_r0_body.zstores13 : PRE_first_tail_x6_r0_body.s140.stores = PRE_first_tail_x6_r0_body.kappa13.stores PRE_first_tail_x6_r0_body.s141.stores
kernel_rfl PRE_first_tail_x6_r0_body.zroots13 : checkRootsSupp PRE_first_tail_x6_r0_body.s141 635 = true
kernel_rfl PRE_first_tail_x6_r0_body.znC13 : PRE_first_tail_x6_r0_body.S139.tab.length + PRE_first_tail_x6_r0_body.cws13.length = 635
-- the map as `Conv.compact_shift` states it (the call's counters for the literals)
kernel_rfl PRE_first_tail_x6_r0_body.zkap13 : PRE_first_tail_x6_r0_body.kappa13 = Conv.Map.compact PRE_first_tail_x6_r0_body.s139.next 2685373 PRE_first_tail_x6_r0_body.S139.tab.length PRE_first_tail_x6_r0_body.pl13 (PRE_first_tail_x6_r0_body.nr13.map NumV.ref) PRE_first_tail_x6_r0_body.kd13.big
  PRE_first_tail_x6_r0_body.kd13.region PRE_first_tail_x6_r0_body.kd13.nodeF
-- the bridge inactive at the canonical state (`Conv.FullShiftQ.toX`; the merged state's bridge is the canonical's: cbridge)
theorem PRE_first_tail_x6_r0_body.zbin13 : (Host.Ts.Sim.Full.bridgeOf PRE_first_tail_x6_r0_body.s141.ffi).active = false := (Host.Load.Boot.replay_active Host.Load.Run.Prompt.P.oblog2818)
-- the JS bookkeeping's step (`Conv.JClean.step` over the changed list) and the canonical roots' bigint freedom
kernel_rfl PRE_first_tail_x6_r0_body.zjc13 : Conv.jcleanListB (⟨18468, 15555, 2685371, 635⟩ : Conv.Cnt) PRE_first_tail_x6_r0_body.s141 PRE_first_tail_x6_r0_body.cl13 = true
kernel_rfl PRE_first_tail_x6_r0_body.zrootsB13 : noBigRootsP (fun i => !Conv.oldBigB (⟨18468, 15555, 2685371, 635⟩ : Conv.Cnt) i) PRE_first_tail_x6_r0_body.s141.trace PRE_first_tail_x6_r0_body.s141 = true
kernel_rfl PRE_first_tail_x6_r0_body.zhm13 : Nat.ble (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.s0.ffi).mlx.nnext 15555 = true
theorem PRE_first_tail_x6_r0_body.cjcl13 (h : Conv.JClean (⟨18468, 15555, 2685371, 635⟩ : Conv.Cnt) PRE_first_tail_x6_r0_body.s139) : Conv.JClean (⟨18468, 15555, 2685371, 635⟩ : Conv.Cnt) PRE_first_tail_x6_r0_body.s141 :=
  Conv.JClean.step h (Conv.Cnt.le_of_leB PRE_first_tail_x6_r0_body.cle13)
    (Conv.heap_off_setAll PRE_first_tail_x6_r0_body.cheap13 fun a ha => Nat.blt_eq.mp (List.all_eq_true.mp PRE_first_tail_x6_r0_body.zclbd13 a ha)) PRE_first_tail_x6_r0_body.zjc13

end Host.Load.Run.Tpl
end

section -- st13/TypedLast
set_option Elab.async false
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
namespace Host.Load.Run.Tpl
open Host.Ts Host.Ts.Sim Host.Ts.Sim.Template

boot_rfl PRE_first_tail_x6_r0_body.st13.bodyLast from PRE_first_tail_x6_r0_body.st13.s1 to PRE_first_tail_x6_r0_body.st13.s2 :
  interpS (step PRE_first_tail_x6_r0_body.st13.F PRE_first_tail_x6_r0_body.st13.s1).run PRE_first_tail_x6_r0_body.st13.S1 = some (PRE_first_tail_x6_r0_body.st13.s2, PRE_first_tail_x6_r0_body.st13.S2)
kernel_rfl PRE_first_tail_x6_r0_body.st13.bodyHalt : isHalt PRE_first_tail_x6_r0_body.st13.s1.ctl = false
kernel_rfl PRE_first_tail_x6_r0_body.st13.bodyTopCheck : noBlockTop PRE_first_tail_x6_r0_body.st13.s2.stack = true

end Host.Load.Run.Tpl
end

section -- st13/TypedOk
set_option Elab.async false
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
namespace Host.Load.Run.Tpl
open Host.Ts Host.Ts.Sim Host.Ts.Sim.Template

noncomputable def PRE_first_tail_x6_r0_body.st13.bodyOkL (bytes : List Byte) (rows : Nat) : St PRE_first_tail_x6_r0_body.st13.F.S → SSrv → Bool :=
  okLocal (Host.Ts.Sim.Compose.VWFrames.bodyOk bytes rows)

noncomputable def PRE_first_tail_x6_r0_body.st13.bodyOkLN (bytes : List Byte) (rows : Nat) : St PRE_first_tail_x6_r0_body.st13.F.S → FSrv → Bool :=
  okLocalN (Host.Ts.Sim.Compose.VWFrames.bodyOkN bytes rows)

theorem PRE_first_tail_x6_r0_body.st13.bodyOkLN_ok (bytes : List Byte) (rows : Nat) (s : St PRE_first_tail_x6_r0_body.st13.F.S) (c : FSrv) (h : c.Wf) :
    PRE_first_tail_x6_r0_body.st13.bodyOkLN bytes rows s c = PRE_first_tail_x6_r0_body.st13.bodyOkL bytes rows s c.toS :=
  okLocalN_ok (Host.Ts.Sim.Compose.VWFrames.bodyOkN_ok bytes rows) s c h

kernel_rfl PRE_first_tail_x6_r0_body.st13.bodyAccepted0 :
  (fun (bytes : List Byte) (rows : Nat) => PRE_first_tail_x6_r0_body.st13.bodyOkL bytes rows PRE_first_tail_x6_r0_body.st13.s0 PRE_first_tail_x6_r0_body.st13.S0) = fun _ _ => true

kernel_rfl PRE_first_tail_x6_r0_body.st13.bodyAccepted1 :
  (fun (bytes : List Byte) (rows : Nat) => PRE_first_tail_x6_r0_body.st13.bodyOkL bytes rows PRE_first_tail_x6_r0_body.st13.s1 PRE_first_tail_x6_r0_body.st13.S1) = fun _ _ => true

end Host.Load.Run.Tpl
end

section -- st13/TypedK0
set_option Elab.async false
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
namespace Host.Load.Run.Tpl
open Host.Ts Host.Ts.Sim Host.Ts.Sim.Template

boot_rfl PRE_first_tail_x6_r0_body.st13.bodyK0F from PRE_first_tail_x6_r0_body.st13.s0 to PRE_first_tail_x6_r0_body.st13.s1 :
  (fun (bytes : List Byte) (rows : Nat) => runOkS PRE_first_tail_x6_r0_body.st13.F (PRE_first_tail_x6_r0_body.st13.bodyOkLN bytes rows)
    ((nth? PRE_first_tail_x6_r0_body.st13.ks 0).getD 0) PRE_first_tail_x6_r0_body.st13.s0 PRE_first_tail_x6_r0_body.st13.S0) = fun _ _ => some (PRE_first_tail_x6_r0_body.st13.s1, PRE_first_tail_x6_r0_body.st13.S1)
theorem PRE_first_tail_x6_r0_body.st13.bodyK0 :
  (fun (bytes : List Byte) (rows : Nat) => runOk PRE_first_tail_x6_r0_body.st13.F (PRE_first_tail_x6_r0_body.st13.bodyOkL bytes rows)
    ((nth? PRE_first_tail_x6_r0_body.st13.ks 0).getD 0) PRE_first_tail_x6_r0_body.st13.s0 PRE_first_tail_x6_r0_body.st13.S0) = fun _ _ => some (PRE_first_tail_x6_r0_body.st13.s1, PRE_first_tail_x6_r0_body.st13.S1) :=
  runOk_fun_of_runOkS PRE_first_tail_x6_r0_body.st13.bodyOkLN_ok PRE_first_tail_x6_r0_body.st13.bodyK0F
end Host.Load.Run.Tpl
end

section -- st13/TypedTpl
set_option Elab.async false
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
namespace Host.Load.Run.Tpl
open Host.Ts Host.Ts.Sim Host.Ts.Sim.Template

theorem PRE_first_tail_x6_r0_body.st13.bodyRun (bytes : List Byte) (rows : Nat) :
    runOk PRE_first_tail_x6_r0_body.st13.F (PRE_first_tail_x6_r0_body.st13.bodyOkL bytes rows) 27 PRE_first_tail_x6_r0_body.st13.s0 PRE_first_tail_x6_r0_body.st13.S0 = some (PRE_first_tail_x6_r0_body.st13.s1, PRE_first_tail_x6_r0_body.st13.S1) :=
  (congrFun (congrFun PRE_first_tail_x6_r0_body.st13.bodyK0 bytes) rows)

theorem PRE_first_tail_x6_r0_body.st13.bodyLocal (bytes : List Byte) (rows : Nat) : ∀ s S, PRE_first_tail_x6_r0_body.st13.bodyOkL bytes rows s S = true → Disp.localB s = true := okLocal_localB

noncomputable def PRE_first_tail_x6_r0_body.st13.bodyTpl (bytes : List Byte) (rows : Nat) : Host.Ts.Sim.Stage.StageTpl PRE_first_tail_x6_r0_body.st13.F (PRE_first_tail_x6_r0_body.st13.bodyOkL bytes rows) where
  s0 := PRE_first_tail_x6_r0_body.st13.s0
  S0 := PRE_first_tail_x6_r0_body.st13.S0
  s1 := PRE_first_tail_x6_r0_body.st13.s1
  S1 := PRE_first_tail_x6_r0_body.st13.S1
  s2 := PRE_first_tail_x6_r0_body.st13.s2
  S2 := PRE_first_tail_x6_r0_body.st13.S2
  n := 27
  ok0 := congrFun (congrFun PRE_first_tail_x6_r0_body.st13.bodyAccepted0 bytes) rows
  run := PRE_first_tail_x6_r0_body.st13.bodyRun bytes rows
  ok1 := congrFun (congrFun PRE_first_tail_x6_r0_body.st13.bodyAccepted1 bytes) rows
  halt := PRE_first_tail_x6_r0_body.st13.bodyHalt
  last := PRE_first_tail_x6_r0_body.st13.bodyLast
  top := noBlockTop_sound PRE_first_tail_x6_r0_body.st13.bodyTopCheck
end Host.Load.Run.Tpl
end

section -- SiteC14
set_option Elab.async false
namespace Host.Load.Run.Tpl
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
open Host.Ts Host.Ts.Sim Host.Ts.Sim.Template

/-! The compaction after the merge at call site 14 of chain `PRE_first_tail_x6_r0_body` (`Conv.compact`, `Conv.full_compactQ`): the canonical
state `PRE_first_tail_x6_r0_body.s145` (the stage's results at canonical places, its trace the call's) under `PRE_first_tail_x6_r0_body.kappa14` into the merged state
`PRE_first_tail_x6_r0_body.s144`. -/

def PRE_first_tail_x6_r0_body.pl14 : List Nat := [2685669]
def PRE_first_tail_x6_r0_body.nr14 : List Nat := []
/-- The native part of the compaction map (canonical → merged handles and nodes: its `big`, `region`, `nodeF`). -/
def PRE_first_tail_x6_r0_body.kd14 : RData :=
  ⟨2685660, 2685670, Stage.setAll PTrie.nil [(2685659, 2685669)], Stage.setAll PTrie.nil [],
   18475, 18475, 15559, 15559, Stage.setAll PTrie.nil [],
   Stage.setAll PTrie.nil []⟩
/-- **The compaction map.** -/
noncomputable def PRE_first_tail_x6_r0_body.kappa14 : Map :=
  Conv.Map.compact 2685659 2685670 652 PRE_first_tail_x6_r0_body.pl14 (PRE_first_tail_x6_r0_body.nr14.map NumV.ref) PRE_first_tail_x6_r0_body.kd14.big
    PRE_first_tail_x6_r0_body.kd14.region PRE_first_tail_x6_r0_body.kd14.nodeF
/-- The canonical result variables and their images, the merged state's entries (`Conv.compactθ`). -/
def PRE_first_tail_x6_r0_body.cws14 : List Nat := []
noncomputable def PRE_first_tail_x6_r0_body.crs14 : List SymE := PRE_first_tail_x6_r0_body.nr14.map fun r => (nth? PRE_first_tail_x6_r0_body.S144.tab r).getD (.var 0)
noncomputable def PRE_first_tail_x6_r0_body.ctheta14 : Nat → SymE := Conv.compactθ PRE_first_tail_x6_r0_body.cws14 PRE_first_tail_x6_r0_body.crs14
/-- The call's entries the stage wrote (renamed in the canonical state with the results). -/
def PRE_first_tail_x6_r0_body.wrB14 : List Nat := [2665, 2673467]

kernel_rfl PRE_first_tail_x6_r0_body.ctab14 : PRE_first_tail_x6_r0_body.S145.tab = PRE_first_tail_x6_r0_body.S143.tab ++ PRE_first_tail_x6_r0_body.cws14.map SymE.var
kernel_rfl PRE_first_tail_x6_r0_body.ctrace14 : PRE_first_tail_x6_r0_body.s145.trace = PRE_first_tail_x6_r0_body.s143.trace
kernel_rfl PRE_first_tail_x6_r0_body.cnext14 : PRE_first_tail_x6_r0_body.s145.next = 2685660
kernel_rfl PRE_first_tail_x6_r0_body.ccounters14 : ((Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.s145.ffi).mlx.next, (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.s145.ffi).mlx.nnext) = (18475, 15559)
-- the merged state's readback queue, carried to the canonical state (`Conv.FullShiftQ.tokens`, `tokSupp`)
kernel_rfl PRE_first_tail_x6_r0_body.cqueue14 : (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.s144.ffi).mlx.tokens = (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.s145.ffi).mlx.tokens.map PRE_first_tail_x6_r0_body.kappa14.nv
kernel_rfl PRE_first_tail_x6_r0_body.ctokSupp14 : (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.s145.ffi).mlx.tokens.all (bSN 652) = true
-- the written and the result entries carry no bigint of the canonical fresh band [next, E) and no fresh region
kernel_rfl PRE_first_tail_x6_r0_body.cclean14 : Conv.cleanListB 18475 131072 (fun r => Nat.ble 73900 r) PRE_first_tail_x6_r0_body.s145
    (PRE_first_tail_x6_r0_body.wrB14 ++ (List.range 1).map (2685659 + ·)) = true
kernel_rfl PRE_first_tail_x6_r0_body.cbigs14 : bigsOutB 18475 131072 (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.s145.ffi).mlx = true

end Host.Load.Run.Tpl
end

section -- SiteK14
set_option Elab.async false
namespace Host.Load.Run.Tpl
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
open Host.Ts Host.Ts.Sim Host.Ts.Sim.Template

/-! The canonical state's closedness from the call's (`Conv.closed_of_callB`, `Conv.sst_of_callB`): it keeps the call's entries
off the written and the result ones (`PRE_first_tail_x6_r0_body.cl14`; natively the written and result handles, the result nodes, the written
and result items), and those are checked. -/

def PRE_first_tail_x6_r0_body.cl14 : List Nat := [2665, 2673467, 2685659]
def PRE_first_tail_x6_r0_body.clo14 : List Nat := []
def PRE_first_tail_x6_r0_body.cln14 : List Nat := []
def PRE_first_tail_x6_r0_body.cli14 : List Nat := []
kernel_rfl PRE_first_tail_x6_r0_body.cheap14 : PRE_first_tail_x6_r0_body.s145.heap = Stage.setAll PRE_first_tail_x6_r0_body.s143.heap (PRE_first_tail_x6_r0_body.cl14.filterMap fun a => (PRE_first_tail_x6_r0_body.s145.heap.get a).map (a, ·))
kernel_rfl PRE_first_tail_x6_r0_body.cnextLe14 : Nat.ble PRE_first_tail_x6_r0_body.s143.next PRE_first_tail_x6_r0_body.s145.next = true
kernel_rfl PRE_first_tail_x6_r0_body.ckeepP14 : Conv.keptPresentB PRE_first_tail_x6_r0_body.s143 PRE_first_tail_x6_r0_body.s145 PRE_first_tail_x6_r0_body.cl14 = true
kernel_rfl PRE_first_tail_x6_r0_body.csupp14 : Conv.suppListB PRE_first_tail_x6_r0_body.s145 652 PRE_first_tail_x6_r0_body.cl14 = true
kernel_rfl PRE_first_tail_x6_r0_body.cbound14 : Conv.boundListB PRE_first_tail_x6_r0_body.s145 PRE_first_tail_x6_r0_body.cl14 = true
kernel_rfl PRE_first_tail_x6_r0_body.cnodesK14 : (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.s145.ffi).mlx.nodes = Stage.setAll (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.s143.ffi).mlx.nodes (PRE_first_tail_x6_r0_body.cln14.filterMap fun i => ((Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.s145.ffi).mlx.nodes.get i).map (i, ·))
kernel_rfl PRE_first_tail_x6_r0_body.cobjsK14 : (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.s145.ffi).mlx.objs = Stage.setAll (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.s143.ffi).mlx.objs (PRE_first_tail_x6_r0_body.clo14.filterMap fun i => ((Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.s145.ffi).mlx.objs.get i).map (i, ·))
kernel_rfl PRE_first_tail_x6_r0_body.citemsK14 : (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.s145.ffi).mlx.items = Stage.setAll (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.s143.ffi).mlx.items (PRE_first_tail_x6_r0_body.cli14.filterMap fun i => ((Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.s145.ffi).mlx.items.get i).map (i, ·))
kernel_rfl PRE_first_tail_x6_r0_body.csst14 : Conv.sstListB 652 (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.s145.ffi).mlx PRE_first_tail_x6_r0_body.cln14 PRE_first_tail_x6_r0_body.clo14 PRE_first_tail_x6_r0_body.cli14 = true

end Host.Load.Run.Tpl
end

section -- SiteCl14
set_option Elab.async false
namespace Host.Load.Run.Tpl
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
open Host.Ts Host.Ts.Sim Host.Ts.Sim.Template

kernel_rfl PRE_first_tail_x6_r0_body.ckA14 : (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.s145.ffi).mlx.arrs = Stage.setAll (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.s143.ffi).mlx.arrs (PRE_first_tail_x6_r0_body.clo14.filterMap fun i => ((Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.s145.ffi).mlx.arrs.get i).map (i, ·))
kernel_rfl PRE_first_tail_x6_r0_body.cbd14 : (PRE_first_tail_x6_r0_body.clo14 ++ PRE_first_tail_x6_r0_body.cln14 ++ PRE_first_tail_x6_r0_body.cli14).all (fun i => Nat.blt (i / 4096) (4 ^ 31)) = true
kernel_rfl PRE_first_tail_x6_r0_body.cle14 : Conv.Cnt.leB (⟨18475, 15559, 2685659, 652⟩ : Conv.Cnt) (⟨18475, 15559, 2685660, 652⟩ : Conv.Cnt) = true
kernel_rfl PRE_first_tail_x6_r0_body.cck14 : Conv.ncleanListB (⟨18475, 15559, 2685660, 652⟩ : Conv.Cnt) (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.s145.ffi).mlx PRE_first_tail_x6_r0_body.clo14 PRE_first_tail_x6_r0_body.cln14 PRE_first_tail_x6_r0_body.cli14 = true
theorem PRE_first_tail_x6_r0_body.cncl14 (h : Conv.NClean (⟨18475, 15559, 2685659, 652⟩ : Conv.Cnt) (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.s143.ffi).mlx) : Conv.NClean (⟨18475, 15559, 2685660, 652⟩ : Conv.Cnt) (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.s145.ffi).mlx :=
  Conv.NClean.stepKeep h PRE_first_tail_x6_r0_body.cle14 PRE_first_tail_x6_r0_body.ckA14 PRE_first_tail_x6_r0_body.cobjsK14 PRE_first_tail_x6_r0_body.cnodesK14 PRE_first_tail_x6_r0_body.citemsK14 PRE_first_tail_x6_r0_body.cbd14 PRE_first_tail_x6_r0_body.cck14

end Host.Load.Run.Tpl
end

section -- SiteS14
set_option Elab.async false
namespace Host.Load.Run.Tpl
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
open Host.Ts Host.Ts.Sim Host.Ts.Sim.Template

/-! The compaction's native shift at call site 14 from its footprint (`Conv.nshift_of_foot`), and the observers'
(`liveShift_foot`, `kernShift_foot`): `Conv.FullShiftQ` for `Conv.full_compactQ`, given the call's bookkeeping and its
relation's facts. -/

/-- The load parameters of the chain (band-free: its start's node counter as `NL` and `N0`). -/
def PRE_first_tail_x6_r0_body.Pc14 : LoadP := ⟨18151, 131072, 1099511627776, 15235, 15235, []⟩
/-- The site's band raised to the map's checked fixed-node prefix, including newly recorded closure traces. -/
def PRE_first_tail_x6_r0_body.P14 : LoadP := PRE_first_tail_x6_r0_body.Pc14.raise 15559
kernel_rfl PRE_first_tail_x6_r0_body.craise14 : Nat.ble PRE_first_tail_x6_r0_body.Pc14.N0 15559 = true
theorem PRE_first_tail_x6_r0_body.raised14 : Host.Ts.Sim.Full.Raised PRE_first_tail_x6_r0_body.Pc14 PRE_first_tail_x6_r0_body.P14 :=
  .inr ⟨15559, rfl, Nat.le_of_ble_eq_true PRE_first_tail_x6_r0_body.craise14, rfl⟩
noncomputable abbrev PRE_first_tail_x6_r0_body.cx0_14 : Host.Load.LSt := clearTokens (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.s145.ffi)
noncomputable abbrev PRE_first_tail_x6_r0_body.cx1_14 : Host.Load.LSt := clearTokens (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.s144.ffi)
def PRE_first_tail_x6_r0_body.khinv14 : PTrie Nat := Stage.setAll PTrie.nil []
def PRE_first_tail_x6_r0_body.kninv14 : PTrie Nat := Stage.setAll PTrie.nil []
/-- The stage's footprint: its written and fresh handles, fresh nodes, written and fresh items. -/
def PRE_first_tail_x6_r0_body.cwS14 : List Nat := []
def PRE_first_tail_x6_r0_body.cnS14 : List Nat := List.range' 15559 0
def PRE_first_tail_x6_r0_body.ciS14 : List Nat := [] ++ List.range' 15559 0

-- the small checks (`MChecks`'s)
kernel_rfl PRE_first_tail_x6_r0_body.cnh014 : PRE_first_tail_x6_r0_body.kd14.nh0 = PRE_first_tail_x6_r0_body.cx0_14.mlx.next
kernel_rfl PRE_first_tail_x6_r0_body.cnh114 : PRE_first_tail_x6_r0_body.kd14.nh1 = PRE_first_tail_x6_r0_body.cx1_14.mlx.next
kernel_rfl PRE_first_tail_x6_r0_body.cnn014 : PRE_first_tail_x6_r0_body.kd14.nn0 = PRE_first_tail_x6_r0_body.cx0_14.mlx.nnext
kernel_rfl PRE_first_tail_x6_r0_body.cnn114 : PRE_first_tail_x6_r0_body.kd14.nn1 = PRE_first_tail_x6_r0_body.cx1_14.mlx.nnext
kernel_rfl PRE_first_tail_x6_r0_body.cplo14 : (Nat.blt 0 PRE_first_tail_x6_r0_body.P14.lo && Nat.ble PRE_first_tail_x6_r0_body.P14.lo PRE_first_tail_x6_r0_body.cx0_14.mlx.next && Nat.ble PRE_first_tail_x6_r0_body.P14.lo RData.bigHi && Nat.ble RData.bigHi PRE_first_tail_x6_r0_body.P14.E) = true
kernel_rfl PRE_first_tail_x6_r0_body.ccnt14 : (Nat.ble PRE_first_tail_x6_r0_body.cx0_14.mlx.next PRE_first_tail_x6_r0_body.cx1_14.mlx.next && Nat.ble PRE_first_tail_x6_r0_body.cx0_14.mlx.nnext PRE_first_tail_x6_r0_body.cx1_14.mlx.nnext) = true
kernel_rfl PRE_first_tail_x6_r0_body.cnband14 : (Nat.blt 0 PRE_first_tail_x6_r0_body.P14.NL && Nat.ble PRE_first_tail_x6_r0_body.P14.NL PRE_first_tail_x6_r0_body.P14.N0 && Nat.ble PRE_first_tail_x6_r0_body.P14.N0 PRE_first_tail_x6_r0_body.cx0_14.mlx.nnext) = true
kernel_rfl PRE_first_tail_x6_r0_body.chbelow14 : PRE_first_tail_x6_r0_body.kd14.checkHndBelow = true
kernel_rfl PRE_first_tail_x6_r0_body.chren14 : checkRenG PRE_first_tail_x6_r0_body.kd14.hnd PRE_first_tail_x6_r0_body.khinv14 (phB PRE_first_tail_x6_r0_body.cx0_14.mlx) = true
kernel_rfl PRE_first_tail_x6_r0_body.cband14 : PRE_first_tail_x6_r0_body.kd14.checkBand PRE_first_tail_x6_r0_body.P14.lo = true
kernel_rfl PRE_first_tail_x6_r0_body.cnh1pos14 : Nat.blt 0 PRE_first_tail_x6_r0_body.kd14.nh1 = true
kernel_rfl PRE_first_tail_x6_r0_body.cnren14 : checkRenG PRE_first_tail_x6_r0_body.kd14.node PRE_first_tail_x6_r0_body.kninv14 (pnB PRE_first_tail_x6_r0_body.cx0_14.mlx) = true
kernel_rfl PRE_first_tail_x6_r0_body.cnlow14 : (PTrie.keysA PRE_first_tail_x6_r0_body.kd14.node).all (fun j => Nat.ble PRE_first_tail_x6_r0_body.P14.NL j && Nat.blt (PRE_first_tail_x6_r0_body.kd14.nodeF j) PRE_first_tail_x6_r0_body.cx1_14.mlx.nnext) = true
kernel_rfl PRE_first_tail_x6_r0_body.cabs0a14 : PRE_first_tail_x6_r0_body.cx0_14.mlx.arrs.get 0 = none
kernel_rfl PRE_first_tail_x6_r0_body.cabs0b14 : PRE_first_tail_x6_r0_body.cx0_14.mlx.objs.get 0 = none
kernel_rfl PRE_first_tail_x6_r0_body.ctok114 : PRE_first_tail_x6_r0_body.cx1_14.mlx.tokens = []
kernel_rfl PRE_first_tail_x6_r0_body.cpend14 : PRE_first_tail_x6_r0_body.cx1_14.mlx.pending = PRE_first_tail_x6_r0_body.cx0_14.mlx.pending.map PRE_first_tail_x6_r0_body.kappa14.pend
kernel_rfl PRE_first_tail_x6_r0_body.cerrh14 : PRE_first_tail_x6_r0_body.cx1_14.mlx.errh = PRE_first_tail_x6_r0_body.cx0_14.mlx.errh.map PRE_first_tail_x6_r0_body.kappa14.arg
kernel_rfl PRE_first_tail_x6_r0_body.cfiles14 : PRE_first_tail_x6_r0_body.cx1_14.mlx.files = PRE_first_tail_x6_r0_body.cx0_14.mlx.files
kernel_rfl PRE_first_tail_x6_r0_body.carch14 : PRE_first_tail_x6_r0_body.cx1_14.mlx.arch = PRE_first_tail_x6_r0_body.cx0_14.mlx.arch
kernel_rfl PRE_first_tail_x6_r0_body.csizes14 : PRE_first_tail_x6_r0_body.cx1_14.mlx.deviceSizes = PRE_first_tail_x6_r0_body.cx0_14.mlx.deviceSizes
kernel_rfl PRE_first_tail_x6_r0_body.cwired14 : PRE_first_tail_x6_r0_body.cx1_14.mlx.wired = PRE_first_tail_x6_r0_body.cx0_14.mlx.wired
kernel_rfl PRE_first_tail_x6_r0_body.chost14 : PRE_first_tail_x6_r0_body.cx1_14.host = PRE_first_tail_x6_r0_body.cx0_14.host
-- the compaction map's addresses are `PRE_first_tail_x6_r0_body.kd14`'s
kernel_rfl PRE_first_tail_x6_r0_body.ckn014 : PRE_first_tail_x6_r0_body.kd14.n0 = 2685660
kernel_rfl PRE_first_tail_x6_r0_body.ckn114 : PRE_first_tail_x6_r0_body.kd14.n1 = 2685670
kernel_rfl PRE_first_tail_x6_r0_body.ckheap14 : (PTrie.keysA PRE_first_tail_x6_r0_body.kd14.heap).all (fun x => Nat.ble 2685659 x) = true
kernel_rfl PRE_first_tail_x6_r0_body.ckpl14 : (List.range 1).all (fun j => decide (PRE_first_tail_x6_r0_body.kd14.heap.get (2685659 + j) = nth? PRE_first_tail_x6_r0_body.pl14 j)) = true
-- the map fixes the call's names (`Conv.fixOld_compact`), the call's counters
kernel_rfl PRE_first_tail_x6_r0_body.fja14 : Nat.ble 2685659 2685659 = true
kernel_rfl PRE_first_tail_x6_r0_body.fn14 : Nat.ble 652 652 = true
kernel_rfl PRE_first_tail_x6_r0_body.fjaD14 : Nat.ble 2685659 PRE_first_tail_x6_r0_body.kd14.n0 = true
kernel_rfl PRE_first_tail_x6_r0_body.fxn14 : Nat.ble 18475 PRE_first_tail_x6_r0_body.kd14.nh0 = true
kernel_rfl PRE_first_tail_x6_r0_body.fnn14 : Nat.ble 15559 PRE_first_tail_x6_r0_body.kd14.nn0 = true
kernel_rfl PRE_first_tail_x6_r0_body.fxb14 : Nat.ble 18475 RData.bigHi = true
kernel_rfl PRE_first_tail_x6_r0_body.fheap14 : (PTrie.keysA PRE_first_tail_x6_r0_body.kd14.heap).all (Nat.ble (⟨18475, 15559, 2685659, 652⟩ : Conv.Cnt).ja) = true
kernel_rfl PRE_first_tail_x6_r0_body.fhnd14 : (PTrie.keysA PRE_first_tail_x6_r0_body.kd14.hnd).all (Nat.ble (⟨18475, 15559, 2685659, 652⟩ : Conv.Cnt).xn) = true
kernel_rfl PRE_first_tail_x6_r0_body.fnode14 : (PTrie.keysA PRE_first_tail_x6_r0_body.kd14.node).all (Nat.ble (⟨18475, 15559, 2685659, 652⟩ : Conv.Cnt).nn) = true
/-- The compaction map fixes the call's names. -/
theorem PRE_first_tail_x6_r0_body.cfix14 : Conv.FixOld (⟨18475, 15559, 2685659, 652⟩ : Conv.Cnt) PRE_first_tail_x6_r0_body.kappa14 :=
  Conv.fixOld_compact (Nat.le_of_ble_eq_true PRE_first_tail_x6_r0_body.fja14) (Nat.le_of_ble_eq_true PRE_first_tail_x6_r0_body.fn14) (Nat.le_of_ble_eq_true PRE_first_tail_x6_r0_body.fjaD14) (Nat.le_of_ble_eq_true PRE_first_tail_x6_r0_body.fxn14) (Nat.le_of_ble_eq_true PRE_first_tail_x6_r0_body.fnn14) (Nat.le_of_ble_eq_true PRE_first_tail_x6_r0_body.fxb14) PRE_first_tail_x6_r0_body.fheap14 PRE_first_tail_x6_r0_body.fhnd14 PRE_first_tail_x6_r0_body.fnode14
kernel_rfl PRE_first_tail_x6_r0_body.fcxn14 : (⟨18475, 15559, 2685659, 652⟩ : Conv.Cnt).xn = (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.s143.ffi).mlx.next
kernel_rfl PRE_first_tail_x6_r0_body.fcnn14 : (⟨18475, 15559, 2685659, 652⟩ : Conv.Cnt).nn = (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.s143.ffi).mlx.nnext
kernel_rfl PRE_first_tail_x6_r0_body.fle014 : (Nat.ble (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.s143.ffi).mlx.next PRE_first_tail_x6_r0_body.cx0_14.mlx.next && Nat.ble (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.s143.ffi).mlx.nnext PRE_first_tail_x6_r0_body.cx0_14.mlx.nnext && Nat.ble (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.s143.ffi).mlx.next RData.bigHi) = true
kernel_rfl PRE_first_tail_x6_r0_body.fnk14 : (PTrie.keysA PRE_first_tail_x6_r0_body.kd14.node).all (Nat.ble (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.s143.ffi).mlx.nnext) = true
-- the merged state keeps the call's entries off the stage's footprint
kernel_rfl PRE_first_tail_x6_r0_body.f1A14 : PRE_first_tail_x6_r0_body.cx1_14.mlx.arrs = Stage.setAll (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.s143.ffi).mlx.arrs (PRE_first_tail_x6_r0_body.cwS14.filterMap fun i => (PRE_first_tail_x6_r0_body.cx1_14.mlx.arrs.get i).map (i, ·))
kernel_rfl PRE_first_tail_x6_r0_body.f1O14 : PRE_first_tail_x6_r0_body.cx1_14.mlx.objs = Stage.setAll (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.s143.ffi).mlx.objs (PRE_first_tail_x6_r0_body.cwS14.filterMap fun i => (PRE_first_tail_x6_r0_body.cx1_14.mlx.objs.get i).map (i, ·))
kernel_rfl PRE_first_tail_x6_r0_body.f1N14 : PRE_first_tail_x6_r0_body.cx1_14.mlx.nodes = Stage.setAll (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.s143.ffi).mlx.nodes (PRE_first_tail_x6_r0_body.cnS14.filterMap fun i => (PRE_first_tail_x6_r0_body.cx1_14.mlx.nodes.get i).map (i, ·))
kernel_rfl PRE_first_tail_x6_r0_body.f1I14 : PRE_first_tail_x6_r0_body.cx1_14.mlx.items = Stage.setAll (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.s143.ffi).mlx.items (PRE_first_tail_x6_r0_body.ciS14.filterMap fun i => (PRE_first_tail_x6_r0_body.cx1_14.mlx.items.get i).map (i, ·))
kernel_rfl PRE_first_tail_x6_r0_body.fbd14 : (PRE_first_tail_x6_r0_body.clo14 ++ PRE_first_tail_x6_r0_body.cln14 ++ PRE_first_tail_x6_r0_body.cli14 ++ PRE_first_tail_x6_r0_body.cwS14 ++ PRE_first_tail_x6_r0_body.cnS14 ++ PRE_first_tail_x6_r0_body.ciS14).all (fun i => Nat.blt (i / 4096) (4 ^ 31)) = true
kernel_rfl PRE_first_tail_x6_r0_body.fincW14 : PRE_first_tail_x6_r0_body.cwS14.all (fun h => !Nat.blt h (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.s143.ffi).mlx.next || PRE_first_tail_x6_r0_body.clo14.contains h) = true
kernel_rfl PRE_first_tail_x6_r0_body.fincI14 : PRE_first_tail_x6_r0_body.ciS14.all (fun k => !Nat.blt k (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.s143.ffi).mlx.nnext || PRE_first_tail_x6_r0_body.cli14.contains k) = true
kernel_rfl PRE_first_tail_x6_r0_body.fincN14 : PRE_first_tail_x6_r0_body.cnS14.all (Nat.ble (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.s143.ffi).mlx.nnext) = true
kernel_rfl PRE_first_tail_x6_r0_body.flnF14 : PRE_first_tail_x6_r0_body.cln14.all (Nat.ble (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.s143.ffi).mlx.nnext) = true
-- the checks over the changed lists
kernel_rfl PRE_first_tail_x6_r0_body.fh14 : PRE_first_tail_x6_r0_body.clo14.all (handleOK PRE_first_tail_x6_r0_body.kappa14 PRE_first_tail_x6_r0_body.P14.lo PRE_first_tail_x6_r0_body.cx0_14.mlx PRE_first_tail_x6_r0_body.cx1_14.mlx) = true
kernel_rfl PRE_first_tail_x6_r0_body.fo14 : PRE_first_tail_x6_r0_body.clo14.map (fun h => PRE_first_tail_x6_r0_body.cx1_14.mlx.objs.get (PRE_first_tail_x6_r0_body.kappa14.handle h)) = PRE_first_tail_x6_r0_body.clo14.map (fun h => (PRE_first_tail_x6_r0_body.cx0_14.mlx.objs.get h).map PRE_first_tail_x6_r0_body.kappa14.nobj)
kernel_rfl PRE_first_tail_x6_r0_body.fok14 : PRE_first_tail_x6_r0_body.clo14.all (objOK PRE_first_tail_x6_r0_body.kappa14 PRE_first_tail_x6_r0_body.P14.NL PRE_first_tail_x6_r0_body.cx0_14.mlx) = true
kernel_rfl PRE_first_tail_x6_r0_body.fnd14 : PRE_first_tail_x6_r0_body.cln14.all (nodeOKF PRE_first_tail_x6_r0_body.kappa14 PRE_first_tail_x6_r0_body.P14 PRE_first_tail_x6_r0_body.cx0_14.mlx PRE_first_tail_x6_r0_body.cx1_14.mlx) = true
kernel_rfl PRE_first_tail_x6_r0_body.fp14 : ((PRE_first_tail_x6_r0_body.cln14.filter (fullB PRE_first_tail_x6_r0_body.P14))).map (fun i => (PRE_first_tail_x6_r0_body.cx1_14.mlx.nodes.get (PRE_first_tail_x6_r0_body.kappa14.node i)).map Host.Mlx.Ffi.Node.prim) =
  ((PRE_first_tail_x6_r0_body.cln14.filter (fullB PRE_first_tail_x6_r0_body.P14))).map (fun i => (PRE_first_tail_x6_r0_body.cx0_14.mlx.nodes.get i).map fun nd => PRE_first_tail_x6_r0_body.kappa14.prim nd.prim)
kernel_rfl PRE_first_tail_x6_r0_body.fnordI14 : incrB PRE_first_tail_x6_r0_body.kd14.nodeF (List.range' 15559 0) = true
kernel_rfl PRE_first_tail_x6_r0_body.fnordK14 : (PTrie.keysA PRE_first_tail_x6_r0_body.kd14.node).all (fun k => Nat.ble 15559 k && Nat.blt k 15559) = true
kernel_rfl PRE_first_tail_x6_r0_body.fnordL14 : (PRE_first_tail_x6_r0_body.cln14.filter (Nat.ble PRE_first_tail_x6_r0_body.P14.N0)).all (fun i => Nat.ble i (PRE_first_tail_x6_r0_body.kd14.nodeF i) && (Nat.blt i 15559 || Nat.ble PRE_first_tail_x6_r0_body.kd14.nn0 i)) = true
theorem PRE_first_tail_x6_r0_body.fnord14 : (PRE_first_tail_x6_r0_body.cln14.filter (Nat.ble PRE_first_tail_x6_r0_body.P14.N0)).all (fun i => Nat.ble i (PRE_first_tail_x6_r0_body.kd14.nodeF i) &&
    (PTrie.keysA PRE_first_tail_x6_r0_body.kd14.node).all fun j => !Nat.blt j i || Nat.blt (PRE_first_tail_x6_r0_body.kd14.nodeF j) (PRE_first_tail_x6_r0_body.kd14.nodeF i)) = true :=
  cnord_of PRE_first_tail_x6_r0_body.cnlow14 PRE_first_tail_x6_r0_body.cnn114 PRE_first_tail_x6_r0_body.fnordI14 PRE_first_tail_x6_r0_body.fnordK14 PRE_first_tail_x6_r0_body.fnordL14
kernel_rfl PRE_first_tail_x6_r0_body.fi14 : PRE_first_tail_x6_r0_body.cli14.all (pnB PRE_first_tail_x6_r0_body.cx0_14.mlx) = true
kernel_rfl PRE_first_tail_x6_r0_body.fii14 : PRE_first_tail_x6_r0_body.cli14.all (fun k => decide (PRE_first_tail_x6_r0_body.cx1_14.mlx.items.get (PRE_first_tail_x6_r0_body.kappa14.node k) = (PRE_first_tail_x6_r0_body.cx0_14.mlx.items.get k).map PRE_first_tail_x6_r0_body.kappa14.nv)) = true
/-- **The compaction's footprint.** -/
theorem PRE_first_tail_x6_r0_body.cfoot14 (clean : Conv.NClean (⟨18475, 15559, 2685659, 652⟩ : Conv.Cnt) (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.s143.ffi).mlx) (hltC : ∀ h, PH (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.s143.ffi).mlx h → h < (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.s143.ffi).mlx.next) (nltC : ∀ i, PN (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.s143.ffi).mlx i → i < (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.s143.ffi).mlx.nnext) (itemsC : ∀ k v, (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.s143.ffi).mlx.items.get k = some v → PN (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.s143.ffi).mlx k) (tracedC : ∀ h o, (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.s143.ffi).mlx.objs.get h = some o → ∀ i ∈ objTraces o, i < PRE_first_tail_x6_r0_body.P14.NL) (cl : SSt (· < 652) PRE_first_tail_x6_r0_body.cx0_14.mlx) :
    Conv.MFoot PRE_first_tail_x6_r0_body.P14 652 PRE_first_tail_x6_r0_body.kappa14 PRE_first_tail_x6_r0_body.kd14 PRE_first_tail_x6_r0_body.khinv14 PRE_first_tail_x6_r0_body.kninv14 (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.s143.ffi).mlx PRE_first_tail_x6_r0_body.cx0_14.mlx PRE_first_tail_x6_r0_body.cx1_14.mlx (⟨18475, 15559, 2685659, 652⟩ : Conv.Cnt) PRE_first_tail_x6_r0_body.clo14 PRE_first_tail_x6_r0_body.cln14 PRE_first_tail_x6_r0_body.cli14 PRE_first_tail_x6_r0_body.cwS14 PRE_first_tail_x6_r0_body.cnS14 PRE_first_tail_x6_r0_body.ciS14 :=
  ⟨rfl, rfl, rfl, PRE_first_tail_x6_r0_body.cnh014, PRE_first_tail_x6_r0_body.cnh114, PRE_first_tail_x6_r0_body.cnn014, PRE_first_tail_x6_r0_body.cnn114, PRE_first_tail_x6_r0_body.cplo14, PRE_first_tail_x6_r0_body.ccnt14, PRE_first_tail_x6_r0_body.cnband14, PRE_first_tail_x6_r0_body.chbelow14, PRE_first_tail_x6_r0_body.chren14, PRE_first_tail_x6_r0_body.cband14, PRE_first_tail_x6_r0_body.cnh1pos14, PRE_first_tail_x6_r0_body.cnren14, PRE_first_tail_x6_r0_body.cnlow14, PRE_first_tail_x6_r0_body.cabs0a14, PRE_first_tail_x6_r0_body.cabs0b14, PRE_first_tail_x6_r0_body.ctok114, PRE_first_tail_x6_r0_body.cpend14, PRE_first_tail_x6_r0_body.cerrh14, PRE_first_tail_x6_r0_body.cfiles14, PRE_first_tail_x6_r0_body.carch14, PRE_first_tail_x6_r0_body.csizes14, PRE_first_tail_x6_r0_body.cwired14, PRE_first_tail_x6_r0_body.cfix14, clean, PRE_first_tail_x6_r0_body.fcxn14, PRE_first_tail_x6_r0_body.fcnn14, hltC, nltC, itemsC, tracedC, cl, PRE_first_tail_x6_r0_body.fle014, PRE_first_tail_x6_r0_body.fnk14, PRE_first_tail_x6_r0_body.ckA14, PRE_first_tail_x6_r0_body.cobjsK14, PRE_first_tail_x6_r0_body.cnodesK14, PRE_first_tail_x6_r0_body.citemsK14, PRE_first_tail_x6_r0_body.f1A14, PRE_first_tail_x6_r0_body.f1O14, PRE_first_tail_x6_r0_body.f1N14, PRE_first_tail_x6_r0_body.f1I14, PRE_first_tail_x6_r0_body.fbd14, PRE_first_tail_x6_r0_body.fincW14, PRE_first_tail_x6_r0_body.fincI14, PRE_first_tail_x6_r0_body.fincN14, PRE_first_tail_x6_r0_body.flnF14, PRE_first_tail_x6_r0_body.fh14, PRE_first_tail_x6_r0_body.fo14, PRE_first_tail_x6_r0_body.fok14, PRE_first_tail_x6_r0_body.fnd14, PRE_first_tail_x6_r0_body.fp14, PRE_first_tail_x6_r0_body.fnord14, PRE_first_tail_x6_r0_body.fi14, PRE_first_tail_x6_r0_body.fii14⟩
theorem PRE_first_tail_x6_r0_body.cnshift14 (clean : Conv.NClean (⟨18475, 15559, 2685659, 652⟩ : Conv.Cnt) (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.s143.ffi).mlx) (hltC : ∀ h, PH (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.s143.ffi).mlx h → h < (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.s143.ffi).mlx.next) (nltC : ∀ i, PN (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.s143.ffi).mlx i → i < (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.s143.ffi).mlx.nnext) (itemsC : ∀ k v, (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.s143.ffi).mlx.items.get k = some v → PN (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.s143.ffi).mlx k) (tracedC : ∀ h o, (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.s143.ffi).mlx.objs.get h = some o → ∀ i ∈ objTraces o, i < PRE_first_tail_x6_r0_body.P14.NL) (cl : SSt (· < 652) PRE_first_tail_x6_r0_body.cx0_14.mlx) : NShift PRE_first_tail_x6_r0_body.P14 652 PRE_first_tail_x6_r0_body.kappa14 PRE_first_tail_x6_r0_body.cx0_14 PRE_first_tail_x6_r0_body.cx1_14 :=
  Conv.nshift_of_foot (PRE_first_tail_x6_r0_body.cfoot14 clean hltC nltC itemsC tracedC cl) PRE_first_tail_x6_r0_body.chost14 (compact_a_eq PRE_first_tail_x6_r0_body.ckn014 PRE_first_tail_x6_r0_body.ckn114 PRE_first_tail_x6_r0_body.ckheap14 PRE_first_tail_x6_r0_body.ckpl14)

-- the observers: the layers' states at the call, the canonical and the merged state, their footprints and checks
noncomputable def PRE_first_tail_x6_r0_body.fxC_14 : PTrie Unit := (Host.Ts.Sim.Full.freedOf PRE_first_tail_x6_r0_body.s143.ffi).getD PTrie.nil
noncomputable def PRE_first_tail_x6_r0_body.krC_14 : Host.Load.Layers.KRec := (Host.Ts.Sim.Full.krecOf PRE_first_tail_x6_r0_body.s143.ffi).getD Host.Load.Layers.KRec.empty
kernel_rfl PRE_first_tail_x6_r0_body.ofxC_14 : (Host.Ts.Sim.Full.freedOf PRE_first_tail_x6_r0_body.s143.ffi) = some PRE_first_tail_x6_r0_body.fxC_14
kernel_rfl PRE_first_tail_x6_r0_body.okrC_14 : (Host.Ts.Sim.Full.krecOf PRE_first_tail_x6_r0_body.s143.ffi) = some PRE_first_tail_x6_r0_body.krC_14
noncomputable def PRE_first_tail_x6_r0_body.fx0_14 : PTrie Unit := (Host.Ts.Sim.Full.freedOf PRE_first_tail_x6_r0_body.s145.ffi).getD PTrie.nil
noncomputable def PRE_first_tail_x6_r0_body.kr0_14 : Host.Load.Layers.KRec := (Host.Ts.Sim.Full.krecOf PRE_first_tail_x6_r0_body.s145.ffi).getD Host.Load.Layers.KRec.empty
kernel_rfl PRE_first_tail_x6_r0_body.ofx0_14 : (Host.Ts.Sim.Full.freedOf PRE_first_tail_x6_r0_body.s145.ffi) = some PRE_first_tail_x6_r0_body.fx0_14
kernel_rfl PRE_first_tail_x6_r0_body.okr0_14 : (Host.Ts.Sim.Full.krecOf PRE_first_tail_x6_r0_body.s145.ffi) = some PRE_first_tail_x6_r0_body.kr0_14
noncomputable def PRE_first_tail_x6_r0_body.fx1_14 : PTrie Unit := (Host.Ts.Sim.Full.freedOf PRE_first_tail_x6_r0_body.s144.ffi).getD PTrie.nil
noncomputable def PRE_first_tail_x6_r0_body.kr1_14 : Host.Load.Layers.KRec := (Host.Ts.Sim.Full.krecOf PRE_first_tail_x6_r0_body.s144.ffi).getD Host.Load.Layers.KRec.empty
kernel_rfl PRE_first_tail_x6_r0_body.ofx1_14 : (Host.Ts.Sim.Full.freedOf PRE_first_tail_x6_r0_body.s144.ffi) = some PRE_first_tail_x6_r0_body.fx1_14
kernel_rfl PRE_first_tail_x6_r0_body.okr1_14 : (Host.Ts.Sim.Full.krecOf PRE_first_tail_x6_r0_body.s144.ffi) = some PRE_first_tail_x6_r0_body.kr1_14
kernel_rfl PRE_first_tail_x6_r0_body.ff014 : PRE_first_tail_x6_r0_body.fx0_14 = Stage.setAll PRE_first_tail_x6_r0_body.fxC_14 (PRE_first_tail_x6_r0_body.clo14.filterMap fun i => (PRE_first_tail_x6_r0_body.fx0_14.get i).map (i, ·))
kernel_rfl PRE_first_tail_x6_r0_body.ff114 : PRE_first_tail_x6_r0_body.fx1_14 = Stage.setAll PRE_first_tail_x6_r0_body.fxC_14 (PRE_first_tail_x6_r0_body.cwS14.filterMap fun i => (PRE_first_tail_x6_r0_body.fx1_14.get i).map (i, ·))
kernel_rfl PRE_first_tail_x6_r0_body.ffck14 : freedLB PRE_first_tail_x6_r0_body.kappa14 PRE_first_tail_x6_r0_body.cx0_14.mlx PRE_first_tail_x6_r0_body.fx0_14 PRE_first_tail_x6_r0_body.fx1_14 PRE_first_tail_x6_r0_body.clo14 = true
kernel_rfl PRE_first_tail_x6_r0_body.fkf014 : PRE_first_tail_x6_r0_body.kr0_14.flags = Stage.setAll PRE_first_tail_x6_r0_body.krC_14.flags (PRE_first_tail_x6_r0_body.clo14.filterMap fun i => (PRE_first_tail_x6_r0_body.kr0_14.flags.get i).map (i, ·))
kernel_rfl PRE_first_tail_x6_r0_body.fkt014 : PRE_first_tail_x6_r0_body.kr0_14.targs = Stage.setAll PRE_first_tail_x6_r0_body.krC_14.targs (PRE_first_tail_x6_r0_body.clo14.filterMap fun i => (PRE_first_tail_x6_r0_body.kr0_14.targs.get i).map (i, ·))
kernel_rfl PRE_first_tail_x6_r0_body.fkf114 : PRE_first_tail_x6_r0_body.kr1_14.flags = Stage.setAll PRE_first_tail_x6_r0_body.krC_14.flags (PRE_first_tail_x6_r0_body.cwS14.filterMap fun i => (PRE_first_tail_x6_r0_body.kr1_14.flags.get i).map (i, ·))
kernel_rfl PRE_first_tail_x6_r0_body.fkt114 : PRE_first_tail_x6_r0_body.kr1_14.targs = Stage.setAll PRE_first_tail_x6_r0_body.krC_14.targs (PRE_first_tail_x6_r0_body.cwS14.filterMap fun i => (PRE_first_tail_x6_r0_body.kr1_14.targs.get i).map (i, ·))
kernel_rfl PRE_first_tail_x6_r0_body.fkck14 : krecLB PRE_first_tail_x6_r0_body.kappa14 652 PRE_first_tail_x6_r0_body.cx0_14.mlx PRE_first_tail_x6_r0_body.kr0_14 PRE_first_tail_x6_r0_body.kr1_14 PRE_first_tail_x6_r0_body.clo14 = true
kernel_rfl PRE_first_tail_x6_r0_body.fkn14 : Nat.ble 652 652 = true
-- the bridge and the pending traces' regions
kernel_rfl PRE_first_tail_x6_r0_body.cbridge14 : Host.Ts.Sim.Full.bridgeOf PRE_first_tail_x6_r0_body.s144.ffi = Host.Ts.Sim.Full.bridgeOf PRE_first_tail_x6_r0_body.s145.ffi
kernel_rfl PRE_first_tail_x6_r0_body.cpendR14 : pendRegB PRE_first_tail_x6_r0_body.kappa14 (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.s145.ffi).mlx = true
kernel_rfl PRE_first_tail_x6_r0_body.cpendLe14 : Nat.ble (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.s145.ffi).mlx.next (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.s144.ffi).mlx.next = true
/-- **The compaction's native shift**, given the call's bookkeeping, its relation's facts (the model's and the
observers') and the canonical closedness. -/
theorem PRE_first_tail_x6_r0_body.cshift14 (clean : Conv.NClean (⟨18475, 15559, 2685659, 652⟩ : Conv.Cnt) (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.s143.ffi).mlx) (hltC : ∀ h, PH (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.s143.ffi).mlx h → h < (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.s143.ffi).mlx.next) (nltC : ∀ i, PN (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.s143.ffi).mlx i → i < (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.s143.ffi).mlx.nnext) (itemsC : ∀ k v, (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.s143.ffi).mlx.items.get k = some v → PN (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.s143.ffi).mlx k) (tracedC : ∀ h o, (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.s143.ffi).mlx.objs.get h = some o → ∀ i ∈ objTraces o, i < PRE_first_tail_x6_r0_body.P14.NL) (cl : SSt (· < 652) PRE_first_tail_x6_r0_body.cx0_14.mlx)
    (hobjC : ∀ h, PRE_first_tail_x6_r0_body.fxC_14.get h = some () → ((Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.s143.ffi).mlx.objs.get h).isSome = true)
    (hfC : ∀ h, (PRE_first_tail_x6_r0_body.krC_14.flags.get h).isSome = true → ((Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.s143.ffi).mlx.objs.get h).isSome = true)
    (htC : ∀ h, (PRE_first_tail_x6_r0_body.krC_14.targs.get h).isSome = true → ((Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.s143.ffi).mlx.objs.get h).isSome = true)
    (hclC : ∀ h l, PRE_first_tail_x6_r0_body.krC_14.targs.get h = some l → Host.Ts.Sim.Full.STargs (· < (⟨18475, 15559, 2685659, 652⟩ : Conv.Cnt).n) l) :
    Conv.FullShiftQ PRE_first_tail_x6_r0_body.P14 652 PRE_first_tail_x6_r0_body.kappa14 PRE_first_tail_x6_r0_body.s145.ffi PRE_first_tail_x6_r0_body.s144.ffi :=
  ⟨PRE_first_tail_x6_r0_body.cnshift14 clean hltC nltC itemsC tracedC cl, PRE_first_tail_x6_r0_body.cqueue14, fun t ht => bSN_sound (List.all_eq_true.mp PRE_first_tail_x6_r0_body.ctokSupp14 t ht),
    PRE_first_tail_x6_r0_body.cbridge14,
    liveShift_foot (x0' := Host.Ts.Sim.Full.mlxOf PRE_first_tail_x6_r0_body.s145.ffi) (x1' := Host.Ts.Sim.Full.mlxOf PRE_first_tail_x6_r0_body.s144.ffi) (PRE_first_tail_x6_r0_body.cfoot14 clean hltC nltC itemsC tracedC cl) rfl PRE_first_tail_x6_r0_body.ofx0_14 PRE_first_tail_x6_r0_body.ofx1_14 hobjC PRE_first_tail_x6_r0_body.ff014 PRE_first_tail_x6_r0_body.ff114 PRE_first_tail_x6_r0_body.ffck14,
    kernShift_foot (x0' := Host.Ts.Sim.Full.mlxOf PRE_first_tail_x6_r0_body.s145.ffi) (x1' := Host.Ts.Sim.Full.mlxOf PRE_first_tail_x6_r0_body.s144.ffi) (PRE_first_tail_x6_r0_body.cfoot14 clean hltC nltC itemsC tracedC cl) rfl PRE_first_tail_x6_r0_body.okr0_14 PRE_first_tail_x6_r0_body.okr1_14 (Nat.le_of_ble_eq_true PRE_first_tail_x6_r0_body.fkn14) hfC htC hclC
      PRE_first_tail_x6_r0_body.fkf014 PRE_first_tail_x6_r0_body.fkt014 PRE_first_tail_x6_r0_body.fkf114 PRE_first_tail_x6_r0_body.fkt114 PRE_first_tail_x6_r0_body.fkck14,
    pendReg_of rfl PRE_first_tail_x6_r0_body.cnh014 PRE_first_tail_x6_r0_body.cnh114 (Nat.le_of_ble_eq_true PRE_first_tail_x6_r0_body.cpendLe14) PRE_first_tail_x6_r0_body.cpendR14⟩

end Host.Load.Run.Tpl
end

section -- st14/H0
set_option Elab.async false
namespace Host.Load.Run.Tpl
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
host_stream_state PRE_first_tail_x6_r0_body.st14 0
host_stream_state PRE_first_tail_x6_r0_body.st14 1
host_stream_state PRE_first_tail_x6_r0_body.st14 2
end Host.Load.Run.Tpl
end

section -- Site14
set_option Elab.async false
namespace Host.Load.Run.Tpl
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
open Host.Ts Host.Ts.Sim Host.Ts.Sim.Template

/-! Call site 14 of chain `PRE_first_tail_x6_r0_body`: `plan__g14__g15` (`plan`), the call state `PRE_first_tail_x6_r0_body.s143`, the merged state `PRE_first_tail_x6_r0_body.s144`,
the site template `PRE_first_tail_x6_r0_body.st14` (σ = `Map.id`, θ the identity at its own site), the canonical state `PRE_first_tail_x6_r0_body.s145`: the merge.
The footprint's facts are in `SiteF14`, the compaction's in `SiteC14`, `SiteK14`, `SiteNa14`, `SiteNb14`. -/

kernel_rfl PRE_first_tail_x6_r0_body.iso14 : PRE_first_tail_x6_r0_body.st14.s0 = { PRE_first_tail_x6_r0_body.s143 with stack := [] }
/-- The caller's frames at the call. -/
noncomputable def PRE_first_tail_x6_r0_body.rs14 : List Frame := PRE_first_tail_x6_r0_body.s143.stack
kernel_rfl PRE_first_tail_x6_r0_body.n0_14 : PRE_first_tail_x6_r0_body.S143.tab.length = 652
kernel_rfl PRE_first_tail_x6_r0_body.tab0_14 : PRE_first_tail_x6_r0_body.st14.S0.tab = PRE_first_tail_x6_r0_body.S143.tab

/-- The fresh variables of the stage's results. -/
def PRE_first_tail_x6_r0_body.ws14 : List Nat := [1250, 1251, 1252]
kernel_rfl PRE_first_tail_x6_r0_body.fresh14 : (PRE_first_tail_x6_r0_body.S143.tab.all fun e => PRE_first_tail_x6_r0_body.ws14.all fun v => e.noVar v) &&
    (PRE_first_tail_x6_r0_body.S143.oracle.all fun q => PRE_first_tail_x6_r0_body.ws14.all fun v => q.noVar v) = true
kernel_rfl PRE_first_tail_x6_r0_body.mergeTab14 : PRE_first_tail_x6_r0_body.S144.tab = PRE_first_tail_x6_r0_body.S143.tab ++ Conv.resTab PRE_first_tail_x6_r0_body.ws14
kernel_rfl PRE_first_tail_x6_r0_body.mergeLen14 : PRE_first_tail_x6_r0_body.st14.S2.tab.length - PRE_first_tail_x6_r0_body.st14.S0.tab.length = 3

-- The merged state: the instance's return state with the caller's frames (`PRE_first_tail_x6_r0_body.merged14`, `merged_relB`).
kernel_rfl PRE_first_tail_x6_r0_body.mheap14 : PRE_first_tail_x6_r0_body.s144.heap = PRE_first_tail_x6_r0_body.st14.s2.heap
kernel_rfl PRE_first_tail_x6_r0_body.mnext14 : PRE_first_tail_x6_r0_body.s144.next = PRE_first_tail_x6_r0_body.st14.s2.next
kernel_rfl PRE_first_tail_x6_r0_body.mctl14 : PRE_first_tail_x6_r0_body.s144.ctl = PRE_first_tail_x6_r0_body.st14.s2.ctl
kernel_rfl PRE_first_tail_x6_r0_body.mstack14 : PRE_first_tail_x6_r0_body.s144.stack = PRE_first_tail_x6_r0_body.st14.s2.stack ++ PRE_first_tail_x6_r0_body.s143.stack
kernel_rfl PRE_first_tail_x6_r0_body.mjobs14 : PRE_first_tail_x6_r0_body.s144.jobs = PRE_first_tail_x6_r0_body.st14.s2.jobs
kernel_rfl PRE_first_tail_x6_r0_body.mffi14 : PRE_first_tail_x6_r0_body.s144.ffi = PRE_first_tail_x6_r0_body.st14.s2.ffi
kernel_rfl PRE_first_tail_x6_r0_body.mtrace14 : PRE_first_tail_x6_r0_body.s144.trace = PRE_first_tail_x6_r0_body.st14.s2.trace
kernel_rfl PRE_first_tail_x6_r0_body.mstores14 : PRE_first_tail_x6_r0_body.s144.stores = PRE_first_tail_x6_r0_body.st14.s2.stores

end Host.Load.Run.Tpl
end

section -- SiteD14
set_option Elab.async false
namespace Host.Load.Run.Tpl
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
open Host.Ts Host.Ts.Sim Host.Ts.Sim.Template

/-! The canonical results at call site 14 of chain `PRE_first_tail_x6_r0_body`: their values in the instance's end table, the references past
the call's table, the canonical variables apart from the stage's. -/

kernel_rfl PRE_first_tail_x6_r0_body.cderived14 : PRE_first_tail_x6_r0_body.nr14.map (fun r => nth? PRE_first_tail_x6_r0_body.st14.S2.tab r) =
  []
kernel_rfl PRE_first_tail_x6_r0_body.cnrLo14 : PRE_first_tail_x6_r0_body.nr14.all (Nat.ble 652) = true
kernel_rfl PRE_first_tail_x6_r0_body.cwsDisj14 : PRE_first_tail_x6_r0_body.cws14.all (fun c => !PRE_first_tail_x6_r0_body.ws14.contains c) = true
/-- The compaction's substitution: the canonical variables to their merged values, the stage's other fresh variables
to `0` (`Conv.compactθZ`). -/
noncomputable def PRE_first_tail_x6_r0_body.cthetaZ14 : Nat → SymE := Conv.compactθZ PRE_first_tail_x6_r0_body.cws14 PRE_first_tail_x6_r0_body.crs14 PRE_first_tail_x6_r0_body.ws14

end Host.Load.Run.Tpl
end

section -- st14/Foot
set_option Elab.async false
namespace Host.Load.Run.Tpl
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
open Host.Ts Host.Ts.Sim Host.Ts.Sim.Stage Host.Ts.Sim.Template

/-! The footprint of stage `PRE_first_tail_x6_r0_body.st14`'s site template (`Conv.StageFoot`, `Conv.NFoot`): every entry of the return
state other than the written and fresh ones is the start's (kernel evaluation of the equalities). -/

/-- The written heap ranges below the start's counter. -/
def PRE_first_tail_x6_r0_body.st14.wrR : List (Nat × Nat) := []
/-- The written and fresh entries of the return state. -/
noncomputable def PRE_first_tail_x6_r0_body.st14.wrE : List (Nat × Host.Ts.HObj) :=
  rangesOf PRE_first_tail_x6_r0_body.st14.s2.heap PRE_first_tail_x6_r0_body.st14.wrR ++ freshOf PRE_first_tail_x6_r0_body.st14.s2.heap PRE_first_tail_x6_r0_body.st14.s0.next PRE_first_tail_x6_r0_body.st14.s2.next
noncomputable def PRE_first_tail_x6_r0_body.st14.wr : List Nat := PRE_first_tail_x6_r0_body.st14.wrE.map (·.1)

kernel_rfl PRE_first_tail_x6_r0_body.st14.heapFoot : PRE_first_tail_x6_r0_body.st14.s2.heap = setAll PRE_first_tail_x6_r0_body.st14.s0.heap PRE_first_tail_x6_r0_body.st14.wrE
kernel_rfl PRE_first_tail_x6_r0_body.st14.grows_check : Nat.ble PRE_first_tail_x6_r0_body.st14.s0.next PRE_first_tail_x6_r0_body.st14.s2.next = true
theorem PRE_first_tail_x6_r0_body.st14.grows : PRE_first_tail_x6_r0_body.st14.s0.next ≤ PRE_first_tail_x6_r0_body.st14.s2.next := Nat.le_of_ble_eq_true PRE_first_tail_x6_r0_body.st14.grows_check

/-- The written and fresh handles; the written readback items of old nodes. -/
def PRE_first_tail_x6_r0_body.st14.wh : List Nat := []
def PRE_first_tail_x6_r0_body.st14.wi : List Nat := []

kernel_rfl PRE_first_tail_x6_r0_body.st14.arrsFoot : (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.st14.s2.ffi).mlx.arrs = setAll (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.st14.s0.ffi).mlx.arrs (PRE_first_tail_x6_r0_body.st14.wh.filterMap fun h => ((Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.st14.s2.ffi).mlx.arrs.get h).map (h, ·))
kernel_rfl PRE_first_tail_x6_r0_body.st14.objsFoot : (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.st14.s2.ffi).mlx.objs = setAll (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.st14.s0.ffi).mlx.objs (PRE_first_tail_x6_r0_body.st14.wh.filterMap fun h => ((Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.st14.s2.ffi).mlx.objs.get h).map (h, ·))
kernel_rfl PRE_first_tail_x6_r0_body.st14.nodesFoot : (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.st14.s2.ffi).mlx.nodes = setAll (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.st14.s0.ffi).mlx.nodes (freshOf (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.st14.s2.ffi).mlx.nodes (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.st14.s0.ffi).mlx.nnext (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.st14.s2.ffi).mlx.nnext)
kernel_rfl PRE_first_tail_x6_r0_body.st14.itemsFoot : (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.st14.s2.ffi).mlx.items = setAll (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.st14.s0.ffi).mlx.items ((PRE_first_tail_x6_r0_body.st14.wi.filterMap fun i => ((Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.st14.s2.ffi).mlx.items.get i).map (i, ·)) ++
    freshOf (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.st14.s2.ffi).mlx.items (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.st14.s0.ffi).mlx.nnext (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.st14.s2.ffi).mlx.nnext)
kernel_rfl PRE_first_tail_x6_r0_body.st14.counters : (Nat.ble (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.st14.s0.ffi).mlx.next (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.st14.s2.ffi).mlx.next && Nat.ble (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.st14.s0.ffi).mlx.nnext (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.st14.s2.ffi).mlx.nnext) = true

end Host.Load.Run.Tpl
end

section -- SiteF14
set_option Elab.async false
namespace Host.Load.Run.Tpl
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
open Host.Ts Host.Ts.Sim Host.Ts.Sim.Template

/-! Call site 14 of chain `PRE_first_tail_x6_r0_body`: `Conv.site_merge`'s footprint facts. -/

kernel_rfl PRE_first_tail_x6_r0_body.wrNodupB14 : nodupT PRE_first_tail_x6_r0_body.st14.wr PTrie.nil = true
theorem PRE_first_tail_x6_r0_body.wrNodup14 : PRE_first_tail_x6_r0_body.st14.wr.Nodup := (nodupT_sound PRE_first_tail_x6_r0_body.wrNodupB14).2
kernel_rfl PRE_first_tail_x6_r0_body.wrBoundB14 : PRE_first_tail_x6_r0_body.st14.wr.all (fun b => Nat.blt (b / 4096) (4 ^ 31)) = true
theorem PRE_first_tail_x6_r0_body.wrBound14 : ∀ b ∈ PRE_first_tail_x6_r0_body.st14.wr, b / 4096 < 4 ^ 31 := fun b hb => Nat.blt_eq.mp (List.all_eq_true.mp PRE_first_tail_x6_r0_body.wrBoundB14 b hb)
noncomputable def PRE_first_tail_x6_r0_body.trFr14 := PRE_first_tail_x6_r0_body.st14.s2.trace.take 0
kernel_rfl PRE_first_tail_x6_r0_body.traceEq14 : PRE_first_tail_x6_r0_body.st14.s2.trace = PRE_first_tail_x6_r0_body.trFr14 ++ PRE_first_tail_x6_r0_body.st14.s0.trace
theorem PRE_first_tail_x6_r0_body.trace14 : ∃ fr, PRE_first_tail_x6_r0_body.st14.s2.trace = fr ++ PRE_first_tail_x6_r0_body.st14.s0.trace := ⟨_, PRE_first_tail_x6_r0_body.traceEq14⟩

-- the caller's wide frames at the instance's start (`Conv.isolateW`'s `W0` under `Map.id`) and their `WFix`
def PRE_first_tail_x6_r0_body.wide14 : List (Nat × WFrame) := [(4910, .memo [])]
kernel_rfl PRE_first_tail_x6_r0_body.wfixB14 : (PRE_first_tail_x6_r0_body.wide14.all fun p => wfixB Map.id (presentB PRE_first_tail_x6_r0_body.st14.s0) p.2) = true
theorem PRE_first_tail_x6_r0_body.wfix14 : ∀ p ∈ PRE_first_tail_x6_r0_body.wide14, WFix Map.id (Present PRE_first_tail_x6_r0_body.st14.s0) p.2 :=
  fun p hp => wfix_of (List.all_eq_true.mp PRE_first_tail_x6_r0_body.wfixB14 p hp)

end Host.Load.Run.Tpl
end

section -- SiteL14
set_option Elab.async false
namespace Host.Load.Run.Tpl
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
open Host.Ts Host.Ts.Sim Host.Ts.Sim.Template

/-! The call link's facts at call site 14 of chain `PRE_first_tail_x6_r0_body`: the instance's start server, its footprint (`Conv.StageFoot`), the
merged state `PRE_first_tail_x6_r0_body.s144`'s framed arrays as the chain start's extended (`arrExt_of`, `numRefs_of`). -/

kernel_rfl PRE_first_tail_x6_r0_body.srvO14 : PRE_first_tail_x6_r0_body.st14.S0.oracle = PRE_first_tail_x6_r0_body.st14.OR
kernel_rfl PRE_first_tail_x6_r0_body.wr0B14 : PRE_first_tail_x6_r0_body.st14.wr.all (fun b => !Nat.blt b PRE_first_tail_x6_r0_body.st14.s0.next || (PRE_first_tail_x6_r0_body.st14.s0.heap.get b).isSome) = true
theorem PRE_first_tail_x6_r0_body.stFoot14 : Conv.StageFoot PRE_first_tail_x6_r0_body.st14.wr PRE_first_tail_x6_r0_body.st14.s0 PRE_first_tail_x6_r0_body.st14.s2 :=
  stageFoot_of PRE_first_tail_x6_r0_body.st14.heapFoot PRE_first_tail_x6_r0_body.wrNodup14 PRE_first_tail_x6_r0_body.wrBound14 PRE_first_tail_x6_r0_body.wr0B14 PRE_first_tail_x6_r0_body.st14.grows

/-- **The relation at the merged state** from the relation at the merge (`Conv.site_merge`'s; `merged_relB`). -/
theorem PRE_first_tail_x6_r0_body.merged14 {FR : Map → Nat → PRE_first_tail_x6_r0_body.st14.F.S → PRE_first_tail_x6_r0_body.st14.F.S → Prop} {W : Nat → Option WFrame} {stk : List Frame} {M : Map}
    {ν : Nat → F64} {K : Host.Ts.Sim.Ctx} {S : SSrv} {t : St PRE_first_tail_x6_r0_body.st14.F.S} {C : CSrv} {n0 : Nat}
    (h : RelB PRE_first_tail_x6_r0_body.st14.F FR W stk M ν K (Conv.mergeSt Map.id (Map.id.res n0 n0) PRE_first_tail_x6_r0_body.rs14 PRE_first_tail_x6_r0_body.st14.wr PRE_first_tail_x6_r0_body.s143 PRE_first_tail_x6_r0_body.st14.s2 PRE_first_tail_x6_r0_body.st14.s0
      PRE_first_tail_x6_r0_body.st14.s2.ffi) S t C) : RelB PRE_first_tail_x6_r0_body.st14.F FR W stk M ν K PRE_first_tail_x6_r0_body.s144 S t C :=
  merged_relB PRE_first_tail_x6_r0_body.iso14 PRE_first_tail_x6_r0_body.stFoot14 PRE_first_tail_x6_r0_body.wrNodup14 PRE_first_tail_x6_r0_body.wrBound14 PRE_first_tail_x6_r0_body.trace14 PRE_first_tail_x6_r0_body.mheap14
    PRE_first_tail_x6_r0_body.mnext14 PRE_first_tail_x6_r0_body.mctl14 PRE_first_tail_x6_r0_body.mstack14 PRE_first_tail_x6_r0_body.mjobs14 PRE_first_tail_x6_r0_body.mffi14 PRE_first_tail_x6_r0_body.mtrace14 PRE_first_tail_x6_r0_body.mstores14 h

def PRE_first_tail_x6_r0_body.arrEl14_2665 : List Val := []
kernel_rfl PRE_first_tail_x6_r0_body.arrE14_2665 : arrOf PRE_first_tail_x6_r0_body.s144 2665 = arrOf PRE_first_tail_x6_r0_body.s0 2665 ++ PRE_first_tail_x6_r0_body.arrEl14_2665
kernel_rfl PRE_first_tail_x6_r0_body.arrA14_2665 : isArrB PRE_first_tail_x6_r0_body.s144 2665 = true
theorem PRE_first_tail_x6_r0_body.arr14_2665 : ∃ o, PRE_first_tail_x6_r0_body.s144.heap.get 2665 = some (.obj o) ∧ o.kind = .array (arrOf PRE_first_tail_x6_r0_body.s0 2665 ++ PRE_first_tail_x6_r0_body.arrEl14_2665) :=
  arrExt_of PRE_first_tail_x6_r0_body.arrE14_2665 PRE_first_tail_x6_r0_body.arrA14_2665
kernel_rfl PRE_first_tail_x6_r0_body.arrN14_2665 : numRefsB PRE_first_tail_x6_r0_body.S0.tab.length PRE_first_tail_x6_r0_body.arrEl14_2665 = true
theorem PRE_first_tail_x6_r0_body.arrR14_2665 : Prefill.NumRefs PRE_first_tail_x6_r0_body.S0.tab.length PRE_first_tail_x6_r0_body.arrEl14_2665 := numRefs_of PRE_first_tail_x6_r0_body.arrN14_2665

def PRE_first_tail_x6_r0_body.arrEl14_2673467 : List Val := []
kernel_rfl PRE_first_tail_x6_r0_body.arrE14_2673467 : arrOf PRE_first_tail_x6_r0_body.s144 2673467 = arrOf PRE_first_tail_x6_r0_body.s0 2673467 ++ PRE_first_tail_x6_r0_body.arrEl14_2673467
kernel_rfl PRE_first_tail_x6_r0_body.arrA14_2673467 : isArrB PRE_first_tail_x6_r0_body.s144 2673467 = true
theorem PRE_first_tail_x6_r0_body.arr14_2673467 : ∃ o, PRE_first_tail_x6_r0_body.s144.heap.get 2673467 = some (.obj o) ∧ o.kind = .array (arrOf PRE_first_tail_x6_r0_body.s0 2673467 ++ PRE_first_tail_x6_r0_body.arrEl14_2673467) :=
  arrExt_of PRE_first_tail_x6_r0_body.arrE14_2673467 PRE_first_tail_x6_r0_body.arrA14_2673467
kernel_rfl PRE_first_tail_x6_r0_body.arrN14_2673467 : numRefsB PRE_first_tail_x6_r0_body.S0.tab.length PRE_first_tail_x6_r0_body.arrEl14_2673467 = true
theorem PRE_first_tail_x6_r0_body.arrR14_2673467 : Prefill.NumRefs PRE_first_tail_x6_r0_body.S0.tab.length PRE_first_tail_x6_r0_body.arrEl14_2673467 := numRefs_of PRE_first_tail_x6_r0_body.arrN14_2673467

kernel_rfl PRE_first_tail_x6_r0_body.w4910k14 : isArrB PRE_first_tail_x6_r0_body.s144 4910 = false
theorem PRE_first_tail_x6_r0_body.keep14 (q : List Val) : Host.Ts.Sim.Prefill.KeepsAtW (framesP PRE_first_tail_x6_r0_body.s0 q) PRE_first_tail_x6_r0_body.s144 := by
  intro a pre pre' hx o es ho hk
  unfold framesP at hx
  simp only at hx
  cases h1 : Nat.beq a 2665
  · cases h2 : Nat.beq a 4910
    · rw [h1, h2] at hx; cases hx
    · have := Nat.eq_of_beq_eq_true h2; subst this
      rw [h1, h2] at hx; cases hx
      exact (notArr_of PRE_first_tail_x6_r0_body.w4910k14 ho hk).elim
  · have := Nat.eq_of_beq_eq_true h1; subst this
    rw [h1] at hx; cases hx
    obtain ⟨o', ho', hk'⟩ := PRE_first_tail_x6_r0_body.arr14_2665
    rw [ho] at ho'; cases ho'
    rw [hk'] at hk; cases hk
    simp [PRE_first_tail_x6_r0_body.arrEl14_2665]

end Host.Load.Run.Tpl
end

section -- SiteZ14
set_option Elab.async false
namespace Host.Load.Run.Tpl
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
open Host.Ts Host.Ts.Sim Host.Ts.Sim.Template

/-! The compaction's state shift at call site 14 of chain `PRE_first_tail_x6_r0_body` (`Conv.compact_shift`): the call `PRE_first_tail_x6_r0_body.s143`, the merged
state `PRE_first_tail_x6_r0_body.s144`, the canonical state `PRE_first_tail_x6_r0_body.s145`; its frames [2665,2673467,2673472,2673473] (kept arrays [2665,2673467]). -/

-- the map's places and counters
kernel_rfl PRE_first_tail_x6_r0_body.zpl14 : PRE_first_tail_x6_r0_body.pl14.all (Nat.ble PRE_first_tail_x6_r0_body.s143.next) = true
kernel_rfl PRE_first_tail_x6_r0_body.zplnd14 : nodupT PRE_first_tail_x6_r0_body.pl14 PTrie.nil = true
kernel_rfl PRE_first_tail_x6_r0_body.zn114 : Nat.ble PRE_first_tail_x6_r0_body.s143.next 2685670 = true
kernel_rfl PRE_first_tail_x6_r0_body.zfirst14 : Nat.ble aFirst PRE_first_tail_x6_r0_body.s143.next = true
kernel_rfl PRE_first_tail_x6_r0_body.zscn14 : PRE_first_tail_x6_r0_body.s145.next = PRE_first_tail_x6_r0_body.s143.next + PRE_first_tail_x6_r0_body.pl14.length
kernel_rfl PRE_first_tail_x6_r0_body.zsmn14 : PRE_first_tail_x6_r0_body.s144.next = 2685670
kernel_rfl PRE_first_tail_x6_r0_body.zgrow14 : Nat.ble PRE_first_tail_x6_r0_body.s145.next PRE_first_tail_x6_r0_body.s144.next = true
-- the tables
kernel_rfl PRE_first_tail_x6_r0_body.zfresh14 : PRE_first_tail_x6_r0_body.S143.tab.all (fun e => PRE_first_tail_x6_r0_body.cws14.all fun v => e.noVar v) = true
kernel_rfl PRE_first_tail_x6_r0_body.zcnd14 : nodupT PRE_first_tail_x6_r0_body.cws14 PTrie.nil = true
kernel_rfl PRE_first_tail_x6_r0_body.znrHi14 : PRE_first_tail_x6_r0_body.nr14.all (fun r => Nat.blt r PRE_first_tail_x6_r0_body.S144.tab.length) = true
-- the frames: every framed address below the call's counter; the kept arrays the chain start's, extended in the merged state
kernel_rfl PRE_first_tail_x6_r0_body.zfrlt14 : [2665, 2673467, 2673472, 2673473].all (fun a => Nat.blt a PRE_first_tail_x6_r0_body.s143.next) = true
kernel_rfl PRE_first_tail_x6_r0_body.zg14_2665 : PRE_first_tail_x6_r0_body.s145.heap.get 2665 = some (.obj (objOf PRE_first_tail_x6_r0_body.s145 2665))
kernel_rfl PRE_first_tail_x6_r0_body.zk14_2665 : (objOf PRE_first_tail_x6_r0_body.s145 2665).kind = .array (arrOf PRE_first_tail_x6_r0_body.s0 2665)
kernel_rfl PRE_first_tail_x6_r0_body.zm14_2665 : PRE_first_tail_x6_r0_body.s144.heap.get 2665 = some (.obj { PRE_first_tail_x6_r0_body.kappa14.obj (objOf PRE_first_tail_x6_r0_body.s145 2665) with
  kind := .array (arrOf PRE_first_tail_x6_r0_body.s0 2665 ++ (arrOf PRE_first_tail_x6_r0_body.s144 2665).drop (arrOf PRE_first_tail_x6_r0_body.s0 2665).length) })
kernel_rfl PRE_first_tail_x6_r0_body.zg14_2673467 : PRE_first_tail_x6_r0_body.s145.heap.get 2673467 = some (.obj (objOf PRE_first_tail_x6_r0_body.s145 2673467))
kernel_rfl PRE_first_tail_x6_r0_body.zk14_2673467 : (objOf PRE_first_tail_x6_r0_body.s145 2673467).kind = .array (arrOf PRE_first_tail_x6_r0_body.s0 2673467)
kernel_rfl PRE_first_tail_x6_r0_body.zm14_2673467 : PRE_first_tail_x6_r0_body.s144.heap.get 2673467 = some (.obj { PRE_first_tail_x6_r0_body.kappa14.obj (objOf PRE_first_tail_x6_r0_body.s145 2673467) with
  kind := .array (arrOf PRE_first_tail_x6_r0_body.s0 2673467 ++ (arrOf PRE_first_tail_x6_r0_body.s144 2673467).drop (arrOf PRE_first_tail_x6_r0_body.s0 2673467).length) })
kernel_rfl PRE_first_tail_x6_r0_body.zw14_4910 : (PRE_first_tail_x6_r0_body.s145.heap.get 4910).isSome = true
kernel_rfl PRE_first_tail_x6_r0_body.zw14_2673472 : (PRE_first_tail_x6_r0_body.s145.heap.get 2673472).isSome = true
kernel_rfl PRE_first_tail_x6_r0_body.zw14_2673473 : (PRE_first_tail_x6_r0_body.s145.heap.get 2673473).isSome = true
-- the heap: the changed list in range, holding the stage's written and fresh addresses; the canonical side's image
kernel_rfl PRE_first_tail_x6_r0_body.zclbd14 : PRE_first_tail_x6_r0_body.cl14.all (fun b => Nat.blt (b / 4096) (4 ^ 31)) = true
kernel_rfl PRE_first_tail_x6_r0_body.zwr14 : PRE_first_tail_x6_r0_body.st14.wr.all (fun b => !Nat.blt b PRE_first_tail_x6_r0_body.s143.next || PRE_first_tail_x6_r0_body.cl14.contains b) = true
def PRE_first_tail_x6_r0_body.zl14 : List Nat := PRE_first_tail_x6_r0_body.cl14.filter fun a => !(List.contains [2665, 2673467] a)
kernel_rfl PRE_first_tail_x6_r0_body.zimgE14 : PRE_first_tail_x6_r0_body.zl14.map (fun a => PRE_first_tail_x6_r0_body.s144.heap.get (PRE_first_tail_x6_r0_body.kappa14.a a)) = PRE_first_tail_x6_r0_body.zl14.map (fun a => (PRE_first_tail_x6_r0_body.s145.heap.get a).map PRE_first_tail_x6_r0_body.kappa14.hobj)
theorem PRE_first_tail_x6_r0_body.zimg14 : HeapImg PRE_first_tail_x6_r0_body.kappa14 PRE_first_tail_x6_r0_body.s145 PRE_first_tail_x6_r0_body.s144 PRE_first_tail_x6_r0_body.zl14 := PRE_first_tail_x6_r0_body.zimgE14
-- the roots and their supports
kernel_rfl PRE_first_tail_x6_r0_body.zctl14 : PRE_first_tail_x6_r0_body.s144.ctl = PRE_first_tail_x6_r0_body.kappa14.ctl PRE_first_tail_x6_r0_body.s145.ctl
kernel_rfl PRE_first_tail_x6_r0_body.zstack14 : PRE_first_tail_x6_r0_body.s144.stack = PRE_first_tail_x6_r0_body.s145.stack.map PRE_first_tail_x6_r0_body.kappa14.frame
kernel_rfl PRE_first_tail_x6_r0_body.zjobs14 : PRE_first_tail_x6_r0_body.s144.jobs = PRE_first_tail_x6_r0_body.s145.jobs.map PRE_first_tail_x6_r0_body.kappa14.job
kernel_rfl PRE_first_tail_x6_r0_body.zstores14 : PRE_first_tail_x6_r0_body.s144.stores = PRE_first_tail_x6_r0_body.kappa14.stores PRE_first_tail_x6_r0_body.s145.stores
kernel_rfl PRE_first_tail_x6_r0_body.zroots14 : checkRootsSupp PRE_first_tail_x6_r0_body.s145 652 = true
kernel_rfl PRE_first_tail_x6_r0_body.znC14 : PRE_first_tail_x6_r0_body.S143.tab.length + PRE_first_tail_x6_r0_body.cws14.length = 652
-- the map as `Conv.compact_shift` states it (the call's counters for the literals)
kernel_rfl PRE_first_tail_x6_r0_body.zkap14 : PRE_first_tail_x6_r0_body.kappa14 = Conv.Map.compact PRE_first_tail_x6_r0_body.s143.next 2685670 PRE_first_tail_x6_r0_body.S143.tab.length PRE_first_tail_x6_r0_body.pl14 (PRE_first_tail_x6_r0_body.nr14.map NumV.ref) PRE_first_tail_x6_r0_body.kd14.big
  PRE_first_tail_x6_r0_body.kd14.region PRE_first_tail_x6_r0_body.kd14.nodeF
-- the bridge inactive at the canonical state (`Conv.FullShiftQ.toX`; the merged state's bridge is the canonical's: cbridge)
theorem PRE_first_tail_x6_r0_body.zbin14 : (Host.Ts.Sim.Full.bridgeOf PRE_first_tail_x6_r0_body.s145.ffi).active = false := (Host.Load.Boot.replay_active Host.Load.Run.Prompt.P.oblog2818)
-- the JS bookkeeping's step (`Conv.JClean.step` over the changed list) and the canonical roots' bigint freedom
kernel_rfl PRE_first_tail_x6_r0_body.zjc14 : Conv.jcleanListB (⟨18475, 15559, 2685660, 652⟩ : Conv.Cnt) PRE_first_tail_x6_r0_body.s145 PRE_first_tail_x6_r0_body.cl14 = true
kernel_rfl PRE_first_tail_x6_r0_body.zrootsB14 : noBigRootsP (fun i => !Conv.oldBigB (⟨18475, 15559, 2685660, 652⟩ : Conv.Cnt) i) PRE_first_tail_x6_r0_body.s145.trace PRE_first_tail_x6_r0_body.s145 = true
kernel_rfl PRE_first_tail_x6_r0_body.zhm14 : Nat.ble (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.s0.ffi).mlx.nnext 15559 = true
theorem PRE_first_tail_x6_r0_body.cjcl14 (h : Conv.JClean (⟨18475, 15559, 2685659, 652⟩ : Conv.Cnt) PRE_first_tail_x6_r0_body.s143) : Conv.JClean (⟨18475, 15559, 2685660, 652⟩ : Conv.Cnt) PRE_first_tail_x6_r0_body.s145 :=
  Conv.JClean.step h (Conv.Cnt.le_of_leB PRE_first_tail_x6_r0_body.cle14)
    (Conv.heap_off_setAll PRE_first_tail_x6_r0_body.cheap14 fun a ha => Nat.blt_eq.mp (List.all_eq_true.mp PRE_first_tail_x6_r0_body.zclbd14 a ha)) PRE_first_tail_x6_r0_body.zjc14

end Host.Load.Run.Tpl
end

section -- st14/TypedLast
set_option Elab.async false
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
namespace Host.Load.Run.Tpl
open Host.Ts Host.Ts.Sim Host.Ts.Sim.Template

boot_rfl PRE_first_tail_x6_r0_body.st14.bodyLast from PRE_first_tail_x6_r0_body.st14.s1 to PRE_first_tail_x6_r0_body.st14.s2 :
  interpS (step PRE_first_tail_x6_r0_body.st14.F PRE_first_tail_x6_r0_body.st14.s1).run PRE_first_tail_x6_r0_body.st14.S1 = some (PRE_first_tail_x6_r0_body.st14.s2, PRE_first_tail_x6_r0_body.st14.S2)
kernel_rfl PRE_first_tail_x6_r0_body.st14.bodyHalt : isHalt PRE_first_tail_x6_r0_body.st14.s1.ctl = false
kernel_rfl PRE_first_tail_x6_r0_body.st14.bodyTopCheck : noBlockTop PRE_first_tail_x6_r0_body.st14.s2.stack = true

end Host.Load.Run.Tpl
end

section -- st14/TypedOk
set_option Elab.async false
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
namespace Host.Load.Run.Tpl
open Host.Ts Host.Ts.Sim Host.Ts.Sim.Template

noncomputable def PRE_first_tail_x6_r0_body.st14.bodyOkL (bytes : List Byte) (rows : Nat) : St PRE_first_tail_x6_r0_body.st14.F.S → SSrv → Bool :=
  okLocal (Host.Ts.Sim.Compose.VWFrames.bodyOk bytes rows)

noncomputable def PRE_first_tail_x6_r0_body.st14.bodyOkLN (bytes : List Byte) (rows : Nat) : St PRE_first_tail_x6_r0_body.st14.F.S → FSrv → Bool :=
  okLocalN (Host.Ts.Sim.Compose.VWFrames.bodyOkN bytes rows)

theorem PRE_first_tail_x6_r0_body.st14.bodyOkLN_ok (bytes : List Byte) (rows : Nat) (s : St PRE_first_tail_x6_r0_body.st14.F.S) (c : FSrv) (h : c.Wf) :
    PRE_first_tail_x6_r0_body.st14.bodyOkLN bytes rows s c = PRE_first_tail_x6_r0_body.st14.bodyOkL bytes rows s c.toS :=
  okLocalN_ok (Host.Ts.Sim.Compose.VWFrames.bodyOkN_ok bytes rows) s c h

kernel_rfl PRE_first_tail_x6_r0_body.st14.bodyAccepted0 :
  (fun (bytes : List Byte) (rows : Nat) => PRE_first_tail_x6_r0_body.st14.bodyOkL bytes rows PRE_first_tail_x6_r0_body.st14.s0 PRE_first_tail_x6_r0_body.st14.S0) = fun _ _ => true

kernel_rfl PRE_first_tail_x6_r0_body.st14.bodyAccepted1 :
  (fun (bytes : List Byte) (rows : Nat) => PRE_first_tail_x6_r0_body.st14.bodyOkL bytes rows PRE_first_tail_x6_r0_body.st14.s1 PRE_first_tail_x6_r0_body.st14.S1) = fun _ _ => true

end Host.Load.Run.Tpl
end

section -- st14/TypedK0
set_option Elab.async false
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
namespace Host.Load.Run.Tpl
open Host.Ts Host.Ts.Sim Host.Ts.Sim.Template

boot_rfl PRE_first_tail_x6_r0_body.st14.bodyK0F from PRE_first_tail_x6_r0_body.st14.s0 to PRE_first_tail_x6_r0_body.st14.s1 :
  (fun (bytes : List Byte) (rows : Nat) => runOkS PRE_first_tail_x6_r0_body.st14.F (PRE_first_tail_x6_r0_body.st14.bodyOkLN bytes rows)
    ((nth? PRE_first_tail_x6_r0_body.st14.ks 0).getD 0) PRE_first_tail_x6_r0_body.st14.s0 PRE_first_tail_x6_r0_body.st14.S0) = fun _ _ => some (PRE_first_tail_x6_r0_body.st14.s1, PRE_first_tail_x6_r0_body.st14.S1)
theorem PRE_first_tail_x6_r0_body.st14.bodyK0 :
  (fun (bytes : List Byte) (rows : Nat) => runOk PRE_first_tail_x6_r0_body.st14.F (PRE_first_tail_x6_r0_body.st14.bodyOkL bytes rows)
    ((nth? PRE_first_tail_x6_r0_body.st14.ks 0).getD 0) PRE_first_tail_x6_r0_body.st14.s0 PRE_first_tail_x6_r0_body.st14.S0) = fun _ _ => some (PRE_first_tail_x6_r0_body.st14.s1, PRE_first_tail_x6_r0_body.st14.S1) :=
  runOk_fun_of_runOkS PRE_first_tail_x6_r0_body.st14.bodyOkLN_ok PRE_first_tail_x6_r0_body.st14.bodyK0F
end Host.Load.Run.Tpl
end

section -- st14/TypedTpl
set_option Elab.async false
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
namespace Host.Load.Run.Tpl
open Host.Ts Host.Ts.Sim Host.Ts.Sim.Template

theorem PRE_first_tail_x6_r0_body.st14.bodyRun (bytes : List Byte) (rows : Nat) :
    runOk PRE_first_tail_x6_r0_body.st14.F (PRE_first_tail_x6_r0_body.st14.bodyOkL bytes rows) 98 PRE_first_tail_x6_r0_body.st14.s0 PRE_first_tail_x6_r0_body.st14.S0 = some (PRE_first_tail_x6_r0_body.st14.s1, PRE_first_tail_x6_r0_body.st14.S1) :=
  (congrFun (congrFun PRE_first_tail_x6_r0_body.st14.bodyK0 bytes) rows)

theorem PRE_first_tail_x6_r0_body.st14.bodyLocal (bytes : List Byte) (rows : Nat) : ∀ s S, PRE_first_tail_x6_r0_body.st14.bodyOkL bytes rows s S = true → Disp.localB s = true := okLocal_localB

noncomputable def PRE_first_tail_x6_r0_body.st14.bodyTpl (bytes : List Byte) (rows : Nat) : Host.Ts.Sim.Stage.StageTpl PRE_first_tail_x6_r0_body.st14.F (PRE_first_tail_x6_r0_body.st14.bodyOkL bytes rows) where
  s0 := PRE_first_tail_x6_r0_body.st14.s0
  S0 := PRE_first_tail_x6_r0_body.st14.S0
  s1 := PRE_first_tail_x6_r0_body.st14.s1
  S1 := PRE_first_tail_x6_r0_body.st14.S1
  s2 := PRE_first_tail_x6_r0_body.st14.s2
  S2 := PRE_first_tail_x6_r0_body.st14.S2
  n := 98
  ok0 := congrFun (congrFun PRE_first_tail_x6_r0_body.st14.bodyAccepted0 bytes) rows
  run := PRE_first_tail_x6_r0_body.st14.bodyRun bytes rows
  ok1 := congrFun (congrFun PRE_first_tail_x6_r0_body.st14.bodyAccepted1 bytes) rows
  halt := PRE_first_tail_x6_r0_body.st14.bodyHalt
  last := PRE_first_tail_x6_r0_body.st14.bodyLast
  top := noBlockTop_sound PRE_first_tail_x6_r0_body.st14.bodyTopCheck
end Host.Load.Run.Tpl
end

section -- SiteC15
set_option Elab.async false
namespace Host.Load.Run.Tpl
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
open Host.Ts Host.Ts.Sim Host.Ts.Sim.Template

/-! The compaction after the merge at call site 15 of chain `PRE_first_tail_x6_r0_body` (`Conv.compact`, `Conv.full_compactQ`): the canonical
state `PRE_first_tail_x6_r0_body.s162` (the stage's results at canonical places, its trace the call's) under `PRE_first_tail_x6_r0_body.kappa15` into the merged state
`PRE_first_tail_x6_r0_body.s161`. -/

def PRE_first_tail_x6_r0_body.pl15 : List Nat := [2688243, 2687418, 2688249, 2688245, 2687420, 2688251]
def PRE_first_tail_x6_r0_body.nr15 : List Nat := [755, 754, 730, 738, 743, 748, 753, 727, 728, 729, 736, 737, 725, 732, 733, 734, 735, 731]
/-- The native part of the compaction map (canonical → merged handles and nodes: its `big`, `region`, `nodeF`). -/
def PRE_first_tail_x6_r0_body.kd15 : RData :=
  ⟨2687137, 2688286, Stage.setAll PTrie.nil [(2687131, 2688243), (2687132, 2687418), (2687133, 2688249), (2687134, 2688245), (2687135, 2687420), (2687136, 2688251)], Stage.setAll PTrie.nil [(18509, 18535), (18510, 18513), (18511, 18536)],
   18512, 18537, 15605, 15605, Stage.setAll PTrie.nil [],
   Stage.setAll PTrie.nil [(725, .ref 755), (726, .ref 754), (727, .ref 730), (728, .ref 738), (729, .ref 743), (730, .ref 748), (731, .ref 753), (732, .ref 727), (733, .ref 728), (734, .ref 729), (735, .ref 736), (736, .ref 737), (737, .ref 725), (738, .ref 732), (739, .ref 733), (740, .ref 734), (741, .ref 735), (742, .ref 731)]⟩
/-- **The compaction map.** -/
noncomputable def PRE_first_tail_x6_r0_body.kappa15 : Map :=
  Conv.Map.compact 2687131 2688286 725 PRE_first_tail_x6_r0_body.pl15 (PRE_first_tail_x6_r0_body.nr15.map NumV.ref) PRE_first_tail_x6_r0_body.kd15.big
    PRE_first_tail_x6_r0_body.kd15.region PRE_first_tail_x6_r0_body.kd15.nodeF
/-- The canonical result variables and their images, the merged state's entries (`Conv.compactθ`). -/
def PRE_first_tail_x6_r0_body.cws15 : List Nat := [1284, 1285, 1286, 1287, 1288, 1289, 1290, 1291, 1292, 1293, 1294, 1295, 1296, 1297, 1298, 1299, 1300, 1301]
noncomputable def PRE_first_tail_x6_r0_body.crs15 : List SymE := PRE_first_tail_x6_r0_body.nr15.map fun r => (nth? PRE_first_tail_x6_r0_body.S161.tab r).getD (.var 0)
noncomputable def PRE_first_tail_x6_r0_body.ctheta15 : Nat → SymE := Conv.compactθ PRE_first_tail_x6_r0_body.cws15 PRE_first_tail_x6_r0_body.crs15
/-- The call's entries the stage wrote (renamed in the canonical state with the results). -/
def PRE_first_tail_x6_r0_body.wrB15 : List Nat := [2665, 2672336, 2673467, 2686305, 2686850, 2687106]

kernel_rfl PRE_first_tail_x6_r0_body.ctab15 : PRE_first_tail_x6_r0_body.S162.tab = PRE_first_tail_x6_r0_body.S160.tab ++ PRE_first_tail_x6_r0_body.cws15.map SymE.var
kernel_rfl PRE_first_tail_x6_r0_body.ctrace15 : PRE_first_tail_x6_r0_body.s162.trace = PRE_first_tail_x6_r0_body.s160.trace
kernel_rfl PRE_first_tail_x6_r0_body.cnext15 : PRE_first_tail_x6_r0_body.s162.next = 2687137
kernel_rfl PRE_first_tail_x6_r0_body.ccounters15 : ((Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.s162.ffi).mlx.next, (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.s162.ffi).mlx.nnext) = (18512, 15605)
-- the merged state's readback queue, carried to the canonical state (`Conv.FullShiftQ.tokens`, `tokSupp`)
kernel_rfl PRE_first_tail_x6_r0_body.cqueue15 : (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.s161.ffi).mlx.tokens = (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.s162.ffi).mlx.tokens.map PRE_first_tail_x6_r0_body.kappa15.nv
kernel_rfl PRE_first_tail_x6_r0_body.ctokSupp15 : (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.s162.ffi).mlx.tokens.all (bSN 743) = true
-- the written and the result entries carry no bigint of the canonical fresh band [next, E) and no fresh region
kernel_rfl PRE_first_tail_x6_r0_body.cclean15 : Conv.cleanListB 18512 131072 (fun r => Nat.ble 74048 r) PRE_first_tail_x6_r0_body.s162
    (PRE_first_tail_x6_r0_body.wrB15 ++ (List.range 6).map (2687131 + ·)) = true
kernel_rfl PRE_first_tail_x6_r0_body.cbigs15 : bigsOutB 18512 131072 (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.s162.ffi).mlx = true

end Host.Load.Run.Tpl
end

section -- SiteK15
set_option Elab.async false
namespace Host.Load.Run.Tpl
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
open Host.Ts Host.Ts.Sim Host.Ts.Sim.Template

/-! The canonical state's closedness from the call's (`Conv.closed_of_callB`, `Conv.sst_of_callB`): it keeps the call's entries
off the written and the result ones (`PRE_first_tail_x6_r0_body.cl15`; natively the written and result handles, the result nodes, the written
and result items), and those are checked. -/

def PRE_first_tail_x6_r0_body.cl15 : List Nat := [2665, 2672336, 2673467, 2686305, 2686850, 2687106, 2687131, 2687132, 2687133, 2687134, 2687135, 2687136]
def PRE_first_tail_x6_r0_body.clo15 : List Nat := [18489, 18502, 18508, 18509, 18510, 18511]
def PRE_first_tail_x6_r0_body.cln15 : List Nat := [15578, 15579, 15580, 15581, 15582, 15583, 15584, 15585, 15586, 15587, 15588, 15589, 15590, 15591, 15592, 15593, 15594, 15595, 15596, 15597, 15598, 15599, 15600, 15601, 15602, 15603, 15604]
def PRE_first_tail_x6_r0_body.cli15 : List Nat := [15578, 15579, 15580, 15581, 15582, 15583, 15584, 15585, 15586, 15587, 15588, 15589, 15590, 15591, 15592, 15593, 15594, 15595, 15596, 15597, 15598, 15599, 15600, 15601, 15602, 15603, 15604]
kernel_rfl PRE_first_tail_x6_r0_body.cheap15 : PRE_first_tail_x6_r0_body.s162.heap = Stage.setAll PRE_first_tail_x6_r0_body.s160.heap (PRE_first_tail_x6_r0_body.cl15.filterMap fun a => (PRE_first_tail_x6_r0_body.s162.heap.get a).map (a, ·))
kernel_rfl PRE_first_tail_x6_r0_body.cnextLe15 : Nat.ble PRE_first_tail_x6_r0_body.s160.next PRE_first_tail_x6_r0_body.s162.next = true
kernel_rfl PRE_first_tail_x6_r0_body.ckeepP15 : Conv.keptPresentB PRE_first_tail_x6_r0_body.s160 PRE_first_tail_x6_r0_body.s162 PRE_first_tail_x6_r0_body.cl15 = true
kernel_rfl PRE_first_tail_x6_r0_body.csupp15 : Conv.suppListB PRE_first_tail_x6_r0_body.s162 743 PRE_first_tail_x6_r0_body.cl15 = true
kernel_rfl PRE_first_tail_x6_r0_body.cbound15 : Conv.boundListB PRE_first_tail_x6_r0_body.s162 PRE_first_tail_x6_r0_body.cl15 = true
kernel_rfl PRE_first_tail_x6_r0_body.cnodesK15 : (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.s162.ffi).mlx.nodes = Stage.setAll (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.s160.ffi).mlx.nodes (PRE_first_tail_x6_r0_body.cln15.filterMap fun i => ((Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.s162.ffi).mlx.nodes.get i).map (i, ·))
kernel_rfl PRE_first_tail_x6_r0_body.cobjsK15 : (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.s162.ffi).mlx.objs = Stage.setAll (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.s160.ffi).mlx.objs (PRE_first_tail_x6_r0_body.clo15.filterMap fun i => ((Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.s162.ffi).mlx.objs.get i).map (i, ·))
kernel_rfl PRE_first_tail_x6_r0_body.citemsK15 : (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.s162.ffi).mlx.items = Stage.setAll (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.s160.ffi).mlx.items (PRE_first_tail_x6_r0_body.cli15.filterMap fun i => ((Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.s162.ffi).mlx.items.get i).map (i, ·))
kernel_rfl PRE_first_tail_x6_r0_body.csst15 : Conv.sstListB 743 (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.s162.ffi).mlx PRE_first_tail_x6_r0_body.cln15 PRE_first_tail_x6_r0_body.clo15 PRE_first_tail_x6_r0_body.cli15 = true

end Host.Load.Run.Tpl
end

section -- SiteCl15
set_option Elab.async false
namespace Host.Load.Run.Tpl
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
open Host.Ts Host.Ts.Sim Host.Ts.Sim.Template

kernel_rfl PRE_first_tail_x6_r0_body.ckA15 : (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.s162.ffi).mlx.arrs = Stage.setAll (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.s160.ffi).mlx.arrs (PRE_first_tail_x6_r0_body.clo15.filterMap fun i => ((Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.s162.ffi).mlx.arrs.get i).map (i, ·))
kernel_rfl PRE_first_tail_x6_r0_body.cbd15 : (PRE_first_tail_x6_r0_body.clo15 ++ PRE_first_tail_x6_r0_body.cln15 ++ PRE_first_tail_x6_r0_body.cli15).all (fun i => Nat.blt (i / 4096) (4 ^ 31)) = true
kernel_rfl PRE_first_tail_x6_r0_body.cle15 : Conv.Cnt.leB (⟨18509, 15578, 2687131, 725⟩ : Conv.Cnt) (⟨18512, 15605, 2687137, 743⟩ : Conv.Cnt) = true
kernel_rfl PRE_first_tail_x6_r0_body.cck15 : Conv.ncleanListB (⟨18512, 15605, 2687137, 743⟩ : Conv.Cnt) (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.s162.ffi).mlx PRE_first_tail_x6_r0_body.clo15 PRE_first_tail_x6_r0_body.cln15 PRE_first_tail_x6_r0_body.cli15 = true
theorem PRE_first_tail_x6_r0_body.cncl15 (h : Conv.NClean (⟨18509, 15578, 2687131, 725⟩ : Conv.Cnt) (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.s160.ffi).mlx) : Conv.NClean (⟨18512, 15605, 2687137, 743⟩ : Conv.Cnt) (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.s162.ffi).mlx :=
  Conv.NClean.stepKeep h PRE_first_tail_x6_r0_body.cle15 PRE_first_tail_x6_r0_body.ckA15 PRE_first_tail_x6_r0_body.cobjsK15 PRE_first_tail_x6_r0_body.cnodesK15 PRE_first_tail_x6_r0_body.citemsK15 PRE_first_tail_x6_r0_body.cbd15 PRE_first_tail_x6_r0_body.cck15

end Host.Load.Run.Tpl
end

section -- SiteS15
set_option Elab.async false
namespace Host.Load.Run.Tpl
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
open Host.Ts Host.Ts.Sim Host.Ts.Sim.Template

/-! The compaction's native shift at call site 15 from its footprint (`Conv.nshift_of_foot`), and the observers'
(`liveShift_foot`, `kernShift_foot`): `Conv.FullShiftQ` for `Conv.full_compactQ`, given the call's bookkeeping and its
relation's facts. -/

/-- The load parameters of the chain (band-free: its start's node counter as `NL` and `N0`). -/
def PRE_first_tail_x6_r0_body.Pc15 : LoadP := ⟨18151, 131072, 1099511627776, 15235, 15235, []⟩
/-- The site's band raised to the map's checked fixed-node prefix, including newly recorded closure traces. -/
def PRE_first_tail_x6_r0_body.P15 : LoadP := PRE_first_tail_x6_r0_body.Pc15.raise 15605
kernel_rfl PRE_first_tail_x6_r0_body.craise15 : Nat.ble PRE_first_tail_x6_r0_body.Pc15.N0 15605 = true
theorem PRE_first_tail_x6_r0_body.raised15 : Host.Ts.Sim.Full.Raised PRE_first_tail_x6_r0_body.Pc15 PRE_first_tail_x6_r0_body.P15 :=
  .inr ⟨15605, rfl, Nat.le_of_ble_eq_true PRE_first_tail_x6_r0_body.craise15, rfl⟩
noncomputable abbrev PRE_first_tail_x6_r0_body.cx0_15 : Host.Load.LSt := clearTokens (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.s162.ffi)
noncomputable abbrev PRE_first_tail_x6_r0_body.cx1_15 : Host.Load.LSt := clearTokens (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.s161.ffi)
def PRE_first_tail_x6_r0_body.khinv15 : PTrie Nat := Stage.setAll PTrie.nil [(18535, 18509), (18513, 18510), (18536, 18511)]
def PRE_first_tail_x6_r0_body.kninv15 : PTrie Nat := Stage.setAll PTrie.nil [(15578, 15578), (15579, 15579), (15580, 15580), (15581, 15581), (15582, 15582), (15583, 15583), (15584, 15584), (15585, 15585), (15586, 15586), (15587, 15587), (15588, 15588), (15589, 15589), (15590, 15590), (15591, 15591), (15592, 15592), (15593, 15593), (15594, 15594), (15595, 15595), (15596, 15596), (15597, 15597), (15598, 15598), (15599, 15599), (15600, 15600), (15601, 15601), (15602, 15602), (15603, 15603), (15604, 15604)]
/-- The stage's footprint: its written and fresh handles, fresh nodes, written and fresh items. -/
def PRE_first_tail_x6_r0_body.cwS15 : List Nat := [18489, 18502, 18508, 18509, 18510, 18511, 18512, 18513, 18514, 18515, 18516, 18517, 18518, 18519, 18520, 18521, 18522, 18523, 18524, 18525, 18526, 18527, 18528, 18529, 18530, 18531, 18532, 18533, 18534, 18535, 18536]
def PRE_first_tail_x6_r0_body.cnS15 : List Nat := List.range' 15578 27
def PRE_first_tail_x6_r0_body.ciS15 : List Nat := [] ++ List.range' 15578 27

-- the small checks (`MChecks`'s)
kernel_rfl PRE_first_tail_x6_r0_body.cnh015 : PRE_first_tail_x6_r0_body.kd15.nh0 = PRE_first_tail_x6_r0_body.cx0_15.mlx.next
kernel_rfl PRE_first_tail_x6_r0_body.cnh115 : PRE_first_tail_x6_r0_body.kd15.nh1 = PRE_first_tail_x6_r0_body.cx1_15.mlx.next
kernel_rfl PRE_first_tail_x6_r0_body.cnn015 : PRE_first_tail_x6_r0_body.kd15.nn0 = PRE_first_tail_x6_r0_body.cx0_15.mlx.nnext
kernel_rfl PRE_first_tail_x6_r0_body.cnn115 : PRE_first_tail_x6_r0_body.kd15.nn1 = PRE_first_tail_x6_r0_body.cx1_15.mlx.nnext
kernel_rfl PRE_first_tail_x6_r0_body.cplo15 : (Nat.blt 0 PRE_first_tail_x6_r0_body.P15.lo && Nat.ble PRE_first_tail_x6_r0_body.P15.lo PRE_first_tail_x6_r0_body.cx0_15.mlx.next && Nat.ble PRE_first_tail_x6_r0_body.P15.lo RData.bigHi && Nat.ble RData.bigHi PRE_first_tail_x6_r0_body.P15.E) = true
kernel_rfl PRE_first_tail_x6_r0_body.ccnt15 : (Nat.ble PRE_first_tail_x6_r0_body.cx0_15.mlx.next PRE_first_tail_x6_r0_body.cx1_15.mlx.next && Nat.ble PRE_first_tail_x6_r0_body.cx0_15.mlx.nnext PRE_first_tail_x6_r0_body.cx1_15.mlx.nnext) = true
kernel_rfl PRE_first_tail_x6_r0_body.cnband15 : (Nat.blt 0 PRE_first_tail_x6_r0_body.P15.NL && Nat.ble PRE_first_tail_x6_r0_body.P15.NL PRE_first_tail_x6_r0_body.P15.N0 && Nat.ble PRE_first_tail_x6_r0_body.P15.N0 PRE_first_tail_x6_r0_body.cx0_15.mlx.nnext) = true
kernel_rfl PRE_first_tail_x6_r0_body.chbelow15 : PRE_first_tail_x6_r0_body.kd15.checkHndBelow = true
kernel_rfl PRE_first_tail_x6_r0_body.chren15 : checkRenG PRE_first_tail_x6_r0_body.kd15.hnd PRE_first_tail_x6_r0_body.khinv15 (phB PRE_first_tail_x6_r0_body.cx0_15.mlx) = true
kernel_rfl PRE_first_tail_x6_r0_body.cband15 : PRE_first_tail_x6_r0_body.kd15.checkBand PRE_first_tail_x6_r0_body.P15.lo = true
kernel_rfl PRE_first_tail_x6_r0_body.cnh1pos15 : Nat.blt 0 PRE_first_tail_x6_r0_body.kd15.nh1 = true
kernel_rfl PRE_first_tail_x6_r0_body.cnren15 : checkRenG PRE_first_tail_x6_r0_body.kd15.node PRE_first_tail_x6_r0_body.kninv15 (pnB PRE_first_tail_x6_r0_body.cx0_15.mlx) = true
kernel_rfl PRE_first_tail_x6_r0_body.cnlow15 : (PTrie.keysA PRE_first_tail_x6_r0_body.kd15.node).all (fun j => Nat.ble PRE_first_tail_x6_r0_body.P15.NL j && Nat.blt (PRE_first_tail_x6_r0_body.kd15.nodeF j) PRE_first_tail_x6_r0_body.cx1_15.mlx.nnext) = true
kernel_rfl PRE_first_tail_x6_r0_body.cabs0a15 : PRE_first_tail_x6_r0_body.cx0_15.mlx.arrs.get 0 = none
kernel_rfl PRE_first_tail_x6_r0_body.cabs0b15 : PRE_first_tail_x6_r0_body.cx0_15.mlx.objs.get 0 = none
kernel_rfl PRE_first_tail_x6_r0_body.ctok115 : PRE_first_tail_x6_r0_body.cx1_15.mlx.tokens = []
kernel_rfl PRE_first_tail_x6_r0_body.cpend15 : PRE_first_tail_x6_r0_body.cx1_15.mlx.pending = PRE_first_tail_x6_r0_body.cx0_15.mlx.pending.map PRE_first_tail_x6_r0_body.kappa15.pend
kernel_rfl PRE_first_tail_x6_r0_body.cerrh15 : PRE_first_tail_x6_r0_body.cx1_15.mlx.errh = PRE_first_tail_x6_r0_body.cx0_15.mlx.errh.map PRE_first_tail_x6_r0_body.kappa15.arg
kernel_rfl PRE_first_tail_x6_r0_body.cfiles15 : PRE_first_tail_x6_r0_body.cx1_15.mlx.files = PRE_first_tail_x6_r0_body.cx0_15.mlx.files
kernel_rfl PRE_first_tail_x6_r0_body.carch15 : PRE_first_tail_x6_r0_body.cx1_15.mlx.arch = PRE_first_tail_x6_r0_body.cx0_15.mlx.arch
kernel_rfl PRE_first_tail_x6_r0_body.csizes15 : PRE_first_tail_x6_r0_body.cx1_15.mlx.deviceSizes = PRE_first_tail_x6_r0_body.cx0_15.mlx.deviceSizes
kernel_rfl PRE_first_tail_x6_r0_body.cwired15 : PRE_first_tail_x6_r0_body.cx1_15.mlx.wired = PRE_first_tail_x6_r0_body.cx0_15.mlx.wired
kernel_rfl PRE_first_tail_x6_r0_body.chost15 : PRE_first_tail_x6_r0_body.cx1_15.host = PRE_first_tail_x6_r0_body.cx0_15.host
-- the compaction map's addresses are `PRE_first_tail_x6_r0_body.kd15`'s
kernel_rfl PRE_first_tail_x6_r0_body.ckn015 : PRE_first_tail_x6_r0_body.kd15.n0 = 2687137
kernel_rfl PRE_first_tail_x6_r0_body.ckn115 : PRE_first_tail_x6_r0_body.kd15.n1 = 2688286
kernel_rfl PRE_first_tail_x6_r0_body.ckheap15 : (PTrie.keysA PRE_first_tail_x6_r0_body.kd15.heap).all (fun x => Nat.ble 2687131 x) = true
kernel_rfl PRE_first_tail_x6_r0_body.ckpl15 : (List.range 6).all (fun j => decide (PRE_first_tail_x6_r0_body.kd15.heap.get (2687131 + j) = nth? PRE_first_tail_x6_r0_body.pl15 j)) = true
-- the map fixes the call's names (`Conv.fixOld_compact`), the call's counters
kernel_rfl PRE_first_tail_x6_r0_body.fja15 : Nat.ble 2687131 2687131 = true
kernel_rfl PRE_first_tail_x6_r0_body.fn15 : Nat.ble 725 725 = true
kernel_rfl PRE_first_tail_x6_r0_body.fjaD15 : Nat.ble 2687131 PRE_first_tail_x6_r0_body.kd15.n0 = true
kernel_rfl PRE_first_tail_x6_r0_body.fxn15 : Nat.ble 18509 PRE_first_tail_x6_r0_body.kd15.nh0 = true
kernel_rfl PRE_first_tail_x6_r0_body.fnn15 : Nat.ble 15578 PRE_first_tail_x6_r0_body.kd15.nn0 = true
kernel_rfl PRE_first_tail_x6_r0_body.fxb15 : Nat.ble 18509 RData.bigHi = true
kernel_rfl PRE_first_tail_x6_r0_body.fheap15 : (PTrie.keysA PRE_first_tail_x6_r0_body.kd15.heap).all (Nat.ble (⟨18509, 15578, 2687131, 725⟩ : Conv.Cnt).ja) = true
kernel_rfl PRE_first_tail_x6_r0_body.fhnd15 : (PTrie.keysA PRE_first_tail_x6_r0_body.kd15.hnd).all (Nat.ble (⟨18509, 15578, 2687131, 725⟩ : Conv.Cnt).xn) = true
kernel_rfl PRE_first_tail_x6_r0_body.fnode15 : (PTrie.keysA PRE_first_tail_x6_r0_body.kd15.node).all (Nat.ble (⟨18509, 15578, 2687131, 725⟩ : Conv.Cnt).nn) = true
/-- The compaction map fixes the call's names. -/
theorem PRE_first_tail_x6_r0_body.cfix15 : Conv.FixOld (⟨18509, 15578, 2687131, 725⟩ : Conv.Cnt) PRE_first_tail_x6_r0_body.kappa15 :=
  Conv.fixOld_compact (Nat.le_of_ble_eq_true PRE_first_tail_x6_r0_body.fja15) (Nat.le_of_ble_eq_true PRE_first_tail_x6_r0_body.fn15) (Nat.le_of_ble_eq_true PRE_first_tail_x6_r0_body.fjaD15) (Nat.le_of_ble_eq_true PRE_first_tail_x6_r0_body.fxn15) (Nat.le_of_ble_eq_true PRE_first_tail_x6_r0_body.fnn15) (Nat.le_of_ble_eq_true PRE_first_tail_x6_r0_body.fxb15) PRE_first_tail_x6_r0_body.fheap15 PRE_first_tail_x6_r0_body.fhnd15 PRE_first_tail_x6_r0_body.fnode15
kernel_rfl PRE_first_tail_x6_r0_body.fcxn15 : (⟨18509, 15578, 2687131, 725⟩ : Conv.Cnt).xn = (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.s160.ffi).mlx.next
kernel_rfl PRE_first_tail_x6_r0_body.fcnn15 : (⟨18509, 15578, 2687131, 725⟩ : Conv.Cnt).nn = (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.s160.ffi).mlx.nnext
kernel_rfl PRE_first_tail_x6_r0_body.fle015 : (Nat.ble (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.s160.ffi).mlx.next PRE_first_tail_x6_r0_body.cx0_15.mlx.next && Nat.ble (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.s160.ffi).mlx.nnext PRE_first_tail_x6_r0_body.cx0_15.mlx.nnext && Nat.ble (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.s160.ffi).mlx.next RData.bigHi) = true
kernel_rfl PRE_first_tail_x6_r0_body.fnk15 : (PTrie.keysA PRE_first_tail_x6_r0_body.kd15.node).all (Nat.ble (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.s160.ffi).mlx.nnext) = true
-- the merged state keeps the call's entries off the stage's footprint
kernel_rfl PRE_first_tail_x6_r0_body.f1A15 : PRE_first_tail_x6_r0_body.cx1_15.mlx.arrs = Stage.setAll (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.s160.ffi).mlx.arrs (PRE_first_tail_x6_r0_body.cwS15.filterMap fun i => (PRE_first_tail_x6_r0_body.cx1_15.mlx.arrs.get i).map (i, ·))
kernel_rfl PRE_first_tail_x6_r0_body.f1O15 : PRE_first_tail_x6_r0_body.cx1_15.mlx.objs = Stage.setAll (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.s160.ffi).mlx.objs (PRE_first_tail_x6_r0_body.cwS15.filterMap fun i => (PRE_first_tail_x6_r0_body.cx1_15.mlx.objs.get i).map (i, ·))
kernel_rfl PRE_first_tail_x6_r0_body.f1N15 : PRE_first_tail_x6_r0_body.cx1_15.mlx.nodes = Stage.setAll (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.s160.ffi).mlx.nodes (PRE_first_tail_x6_r0_body.cnS15.filterMap fun i => (PRE_first_tail_x6_r0_body.cx1_15.mlx.nodes.get i).map (i, ·))
kernel_rfl PRE_first_tail_x6_r0_body.f1I15 : PRE_first_tail_x6_r0_body.cx1_15.mlx.items = Stage.setAll (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.s160.ffi).mlx.items (PRE_first_tail_x6_r0_body.ciS15.filterMap fun i => (PRE_first_tail_x6_r0_body.cx1_15.mlx.items.get i).map (i, ·))
kernel_rfl PRE_first_tail_x6_r0_body.fbd15 : (PRE_first_tail_x6_r0_body.clo15 ++ PRE_first_tail_x6_r0_body.cln15 ++ PRE_first_tail_x6_r0_body.cli15 ++ PRE_first_tail_x6_r0_body.cwS15 ++ PRE_first_tail_x6_r0_body.cnS15 ++ PRE_first_tail_x6_r0_body.ciS15).all (fun i => Nat.blt (i / 4096) (4 ^ 31)) = true
kernel_rfl PRE_first_tail_x6_r0_body.fincW15 : PRE_first_tail_x6_r0_body.cwS15.all (fun h => !Nat.blt h (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.s160.ffi).mlx.next || PRE_first_tail_x6_r0_body.clo15.contains h) = true
kernel_rfl PRE_first_tail_x6_r0_body.fincI15 : PRE_first_tail_x6_r0_body.ciS15.all (fun k => !Nat.blt k (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.s160.ffi).mlx.nnext || PRE_first_tail_x6_r0_body.cli15.contains k) = true
kernel_rfl PRE_first_tail_x6_r0_body.fincN15 : PRE_first_tail_x6_r0_body.cnS15.all (Nat.ble (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.s160.ffi).mlx.nnext) = true
kernel_rfl PRE_first_tail_x6_r0_body.flnF15 : PRE_first_tail_x6_r0_body.cln15.all (Nat.ble (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.s160.ffi).mlx.nnext) = true
-- the checks over the changed lists
kernel_rfl PRE_first_tail_x6_r0_body.fh15 : PRE_first_tail_x6_r0_body.clo15.all (handleOK PRE_first_tail_x6_r0_body.kappa15 PRE_first_tail_x6_r0_body.P15.lo PRE_first_tail_x6_r0_body.cx0_15.mlx PRE_first_tail_x6_r0_body.cx1_15.mlx) = true
kernel_rfl PRE_first_tail_x6_r0_body.fo15 : PRE_first_tail_x6_r0_body.clo15.map (fun h => PRE_first_tail_x6_r0_body.cx1_15.mlx.objs.get (PRE_first_tail_x6_r0_body.kappa15.handle h)) = PRE_first_tail_x6_r0_body.clo15.map (fun h => (PRE_first_tail_x6_r0_body.cx0_15.mlx.objs.get h).map PRE_first_tail_x6_r0_body.kappa15.nobj)
kernel_rfl PRE_first_tail_x6_r0_body.fok15 : PRE_first_tail_x6_r0_body.clo15.all (objOK PRE_first_tail_x6_r0_body.kappa15 PRE_first_tail_x6_r0_body.P15.NL PRE_first_tail_x6_r0_body.cx0_15.mlx) = true
kernel_rfl PRE_first_tail_x6_r0_body.fnd15 : PRE_first_tail_x6_r0_body.cln15.all (nodeOKF PRE_first_tail_x6_r0_body.kappa15 PRE_first_tail_x6_r0_body.P15 PRE_first_tail_x6_r0_body.cx0_15.mlx PRE_first_tail_x6_r0_body.cx1_15.mlx) = true
kernel_rfl PRE_first_tail_x6_r0_body.fp15 : ((PRE_first_tail_x6_r0_body.cln15.filter (fullB PRE_first_tail_x6_r0_body.P15))).map (fun i => (PRE_first_tail_x6_r0_body.cx1_15.mlx.nodes.get (PRE_first_tail_x6_r0_body.kappa15.node i)).map Host.Mlx.Ffi.Node.prim) =
  ((PRE_first_tail_x6_r0_body.cln15.filter (fullB PRE_first_tail_x6_r0_body.P15))).map (fun i => (PRE_first_tail_x6_r0_body.cx0_15.mlx.nodes.get i).map fun nd => PRE_first_tail_x6_r0_body.kappa15.prim nd.prim)
kernel_rfl PRE_first_tail_x6_r0_body.fnordI15 : incrB PRE_first_tail_x6_r0_body.kd15.nodeF (List.range' 15578 27) = true
kernel_rfl PRE_first_tail_x6_r0_body.fnordK15 : (PTrie.keysA PRE_first_tail_x6_r0_body.kd15.node).all (fun k => Nat.ble 15578 k && Nat.blt k 15605) = true
kernel_rfl PRE_first_tail_x6_r0_body.fnordL15 : (PRE_first_tail_x6_r0_body.cln15.filter (Nat.ble PRE_first_tail_x6_r0_body.P15.N0)).all (fun i => Nat.ble i (PRE_first_tail_x6_r0_body.kd15.nodeF i) && (Nat.blt i 15605 || Nat.ble PRE_first_tail_x6_r0_body.kd15.nn0 i)) = true
theorem PRE_first_tail_x6_r0_body.fnord15 : (PRE_first_tail_x6_r0_body.cln15.filter (Nat.ble PRE_first_tail_x6_r0_body.P15.N0)).all (fun i => Nat.ble i (PRE_first_tail_x6_r0_body.kd15.nodeF i) &&
    (PTrie.keysA PRE_first_tail_x6_r0_body.kd15.node).all fun j => !Nat.blt j i || Nat.blt (PRE_first_tail_x6_r0_body.kd15.nodeF j) (PRE_first_tail_x6_r0_body.kd15.nodeF i)) = true :=
  cnord_of PRE_first_tail_x6_r0_body.cnlow15 PRE_first_tail_x6_r0_body.cnn115 PRE_first_tail_x6_r0_body.fnordI15 PRE_first_tail_x6_r0_body.fnordK15 PRE_first_tail_x6_r0_body.fnordL15
kernel_rfl PRE_first_tail_x6_r0_body.fi15 : PRE_first_tail_x6_r0_body.cli15.all (pnB PRE_first_tail_x6_r0_body.cx0_15.mlx) = true
kernel_rfl PRE_first_tail_x6_r0_body.fii15 : PRE_first_tail_x6_r0_body.cli15.all (fun k => decide (PRE_first_tail_x6_r0_body.cx1_15.mlx.items.get (PRE_first_tail_x6_r0_body.kappa15.node k) = (PRE_first_tail_x6_r0_body.cx0_15.mlx.items.get k).map PRE_first_tail_x6_r0_body.kappa15.nv)) = true
/-- **The compaction's footprint.** -/
theorem PRE_first_tail_x6_r0_body.cfoot15 (clean : Conv.NClean (⟨18509, 15578, 2687131, 725⟩ : Conv.Cnt) (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.s160.ffi).mlx) (hltC : ∀ h, PH (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.s160.ffi).mlx h → h < (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.s160.ffi).mlx.next) (nltC : ∀ i, PN (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.s160.ffi).mlx i → i < (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.s160.ffi).mlx.nnext) (itemsC : ∀ k v, (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.s160.ffi).mlx.items.get k = some v → PN (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.s160.ffi).mlx k) (tracedC : ∀ h o, (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.s160.ffi).mlx.objs.get h = some o → ∀ i ∈ objTraces o, i < PRE_first_tail_x6_r0_body.P15.NL) (cl : SSt (· < 743) PRE_first_tail_x6_r0_body.cx0_15.mlx) :
    Conv.MFoot PRE_first_tail_x6_r0_body.P15 743 PRE_first_tail_x6_r0_body.kappa15 PRE_first_tail_x6_r0_body.kd15 PRE_first_tail_x6_r0_body.khinv15 PRE_first_tail_x6_r0_body.kninv15 (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.s160.ffi).mlx PRE_first_tail_x6_r0_body.cx0_15.mlx PRE_first_tail_x6_r0_body.cx1_15.mlx (⟨18509, 15578, 2687131, 725⟩ : Conv.Cnt) PRE_first_tail_x6_r0_body.clo15 PRE_first_tail_x6_r0_body.cln15 PRE_first_tail_x6_r0_body.cli15 PRE_first_tail_x6_r0_body.cwS15 PRE_first_tail_x6_r0_body.cnS15 PRE_first_tail_x6_r0_body.ciS15 :=
  ⟨rfl, rfl, rfl, PRE_first_tail_x6_r0_body.cnh015, PRE_first_tail_x6_r0_body.cnh115, PRE_first_tail_x6_r0_body.cnn015, PRE_first_tail_x6_r0_body.cnn115, PRE_first_tail_x6_r0_body.cplo15, PRE_first_tail_x6_r0_body.ccnt15, PRE_first_tail_x6_r0_body.cnband15, PRE_first_tail_x6_r0_body.chbelow15, PRE_first_tail_x6_r0_body.chren15, PRE_first_tail_x6_r0_body.cband15, PRE_first_tail_x6_r0_body.cnh1pos15, PRE_first_tail_x6_r0_body.cnren15, PRE_first_tail_x6_r0_body.cnlow15, PRE_first_tail_x6_r0_body.cabs0a15, PRE_first_tail_x6_r0_body.cabs0b15, PRE_first_tail_x6_r0_body.ctok115, PRE_first_tail_x6_r0_body.cpend15, PRE_first_tail_x6_r0_body.cerrh15, PRE_first_tail_x6_r0_body.cfiles15, PRE_first_tail_x6_r0_body.carch15, PRE_first_tail_x6_r0_body.csizes15, PRE_first_tail_x6_r0_body.cwired15, PRE_first_tail_x6_r0_body.cfix15, clean, PRE_first_tail_x6_r0_body.fcxn15, PRE_first_tail_x6_r0_body.fcnn15, hltC, nltC, itemsC, tracedC, cl, PRE_first_tail_x6_r0_body.fle015, PRE_first_tail_x6_r0_body.fnk15, PRE_first_tail_x6_r0_body.ckA15, PRE_first_tail_x6_r0_body.cobjsK15, PRE_first_tail_x6_r0_body.cnodesK15, PRE_first_tail_x6_r0_body.citemsK15, PRE_first_tail_x6_r0_body.f1A15, PRE_first_tail_x6_r0_body.f1O15, PRE_first_tail_x6_r0_body.f1N15, PRE_first_tail_x6_r0_body.f1I15, PRE_first_tail_x6_r0_body.fbd15, PRE_first_tail_x6_r0_body.fincW15, PRE_first_tail_x6_r0_body.fincI15, PRE_first_tail_x6_r0_body.fincN15, PRE_first_tail_x6_r0_body.flnF15, PRE_first_tail_x6_r0_body.fh15, PRE_first_tail_x6_r0_body.fo15, PRE_first_tail_x6_r0_body.fok15, PRE_first_tail_x6_r0_body.fnd15, PRE_first_tail_x6_r0_body.fp15, PRE_first_tail_x6_r0_body.fnord15, PRE_first_tail_x6_r0_body.fi15, PRE_first_tail_x6_r0_body.fii15⟩
theorem PRE_first_tail_x6_r0_body.cnshift15 (clean : Conv.NClean (⟨18509, 15578, 2687131, 725⟩ : Conv.Cnt) (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.s160.ffi).mlx) (hltC : ∀ h, PH (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.s160.ffi).mlx h → h < (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.s160.ffi).mlx.next) (nltC : ∀ i, PN (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.s160.ffi).mlx i → i < (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.s160.ffi).mlx.nnext) (itemsC : ∀ k v, (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.s160.ffi).mlx.items.get k = some v → PN (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.s160.ffi).mlx k) (tracedC : ∀ h o, (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.s160.ffi).mlx.objs.get h = some o → ∀ i ∈ objTraces o, i < PRE_first_tail_x6_r0_body.P15.NL) (cl : SSt (· < 743) PRE_first_tail_x6_r0_body.cx0_15.mlx) : NShift PRE_first_tail_x6_r0_body.P15 743 PRE_first_tail_x6_r0_body.kappa15 PRE_first_tail_x6_r0_body.cx0_15 PRE_first_tail_x6_r0_body.cx1_15 :=
  Conv.nshift_of_foot (PRE_first_tail_x6_r0_body.cfoot15 clean hltC nltC itemsC tracedC cl) PRE_first_tail_x6_r0_body.chost15 (compact_a_eq PRE_first_tail_x6_r0_body.ckn015 PRE_first_tail_x6_r0_body.ckn115 PRE_first_tail_x6_r0_body.ckheap15 PRE_first_tail_x6_r0_body.ckpl15)

-- the observers: the layers' states at the call, the canonical and the merged state, their footprints and checks
noncomputable def PRE_first_tail_x6_r0_body.fxC_15 : PTrie Unit := (Host.Ts.Sim.Full.freedOf PRE_first_tail_x6_r0_body.s160.ffi).getD PTrie.nil
noncomputable def PRE_first_tail_x6_r0_body.krC_15 : Host.Load.Layers.KRec := (Host.Ts.Sim.Full.krecOf PRE_first_tail_x6_r0_body.s160.ffi).getD Host.Load.Layers.KRec.empty
kernel_rfl PRE_first_tail_x6_r0_body.ofxC_15 : (Host.Ts.Sim.Full.freedOf PRE_first_tail_x6_r0_body.s160.ffi) = some PRE_first_tail_x6_r0_body.fxC_15
kernel_rfl PRE_first_tail_x6_r0_body.okrC_15 : (Host.Ts.Sim.Full.krecOf PRE_first_tail_x6_r0_body.s160.ffi) = some PRE_first_tail_x6_r0_body.krC_15
noncomputable def PRE_first_tail_x6_r0_body.fx0_15 : PTrie Unit := (Host.Ts.Sim.Full.freedOf PRE_first_tail_x6_r0_body.s162.ffi).getD PTrie.nil
noncomputable def PRE_first_tail_x6_r0_body.kr0_15 : Host.Load.Layers.KRec := (Host.Ts.Sim.Full.krecOf PRE_first_tail_x6_r0_body.s162.ffi).getD Host.Load.Layers.KRec.empty
kernel_rfl PRE_first_tail_x6_r0_body.ofx0_15 : (Host.Ts.Sim.Full.freedOf PRE_first_tail_x6_r0_body.s162.ffi) = some PRE_first_tail_x6_r0_body.fx0_15
kernel_rfl PRE_first_tail_x6_r0_body.okr0_15 : (Host.Ts.Sim.Full.krecOf PRE_first_tail_x6_r0_body.s162.ffi) = some PRE_first_tail_x6_r0_body.kr0_15
noncomputable def PRE_first_tail_x6_r0_body.fx1_15 : PTrie Unit := (Host.Ts.Sim.Full.freedOf PRE_first_tail_x6_r0_body.s161.ffi).getD PTrie.nil
noncomputable def PRE_first_tail_x6_r0_body.kr1_15 : Host.Load.Layers.KRec := (Host.Ts.Sim.Full.krecOf PRE_first_tail_x6_r0_body.s161.ffi).getD Host.Load.Layers.KRec.empty
kernel_rfl PRE_first_tail_x6_r0_body.ofx1_15 : (Host.Ts.Sim.Full.freedOf PRE_first_tail_x6_r0_body.s161.ffi) = some PRE_first_tail_x6_r0_body.fx1_15
kernel_rfl PRE_first_tail_x6_r0_body.okr1_15 : (Host.Ts.Sim.Full.krecOf PRE_first_tail_x6_r0_body.s161.ffi) = some PRE_first_tail_x6_r0_body.kr1_15
kernel_rfl PRE_first_tail_x6_r0_body.ff015 : PRE_first_tail_x6_r0_body.fx0_15 = Stage.setAll PRE_first_tail_x6_r0_body.fxC_15 (PRE_first_tail_x6_r0_body.clo15.filterMap fun i => (PRE_first_tail_x6_r0_body.fx0_15.get i).map (i, ·))
kernel_rfl PRE_first_tail_x6_r0_body.ff115 : PRE_first_tail_x6_r0_body.fx1_15 = Stage.setAll PRE_first_tail_x6_r0_body.fxC_15 (PRE_first_tail_x6_r0_body.cwS15.filterMap fun i => (PRE_first_tail_x6_r0_body.fx1_15.get i).map (i, ·))
kernel_rfl PRE_first_tail_x6_r0_body.ffck15 : freedLB PRE_first_tail_x6_r0_body.kappa15 PRE_first_tail_x6_r0_body.cx0_15.mlx PRE_first_tail_x6_r0_body.fx0_15 PRE_first_tail_x6_r0_body.fx1_15 PRE_first_tail_x6_r0_body.clo15 = true
kernel_rfl PRE_first_tail_x6_r0_body.fkf015 : PRE_first_tail_x6_r0_body.kr0_15.flags = Stage.setAll PRE_first_tail_x6_r0_body.krC_15.flags (PRE_first_tail_x6_r0_body.clo15.filterMap fun i => (PRE_first_tail_x6_r0_body.kr0_15.flags.get i).map (i, ·))
kernel_rfl PRE_first_tail_x6_r0_body.fkt015 : PRE_first_tail_x6_r0_body.kr0_15.targs = Stage.setAll PRE_first_tail_x6_r0_body.krC_15.targs (PRE_first_tail_x6_r0_body.clo15.filterMap fun i => (PRE_first_tail_x6_r0_body.kr0_15.targs.get i).map (i, ·))
kernel_rfl PRE_first_tail_x6_r0_body.fkf115 : PRE_first_tail_x6_r0_body.kr1_15.flags = Stage.setAll PRE_first_tail_x6_r0_body.krC_15.flags (PRE_first_tail_x6_r0_body.cwS15.filterMap fun i => (PRE_first_tail_x6_r0_body.kr1_15.flags.get i).map (i, ·))
kernel_rfl PRE_first_tail_x6_r0_body.fkt115 : PRE_first_tail_x6_r0_body.kr1_15.targs = Stage.setAll PRE_first_tail_x6_r0_body.krC_15.targs (PRE_first_tail_x6_r0_body.cwS15.filterMap fun i => (PRE_first_tail_x6_r0_body.kr1_15.targs.get i).map (i, ·))
kernel_rfl PRE_first_tail_x6_r0_body.fkck15 : krecLB PRE_first_tail_x6_r0_body.kappa15 743 PRE_first_tail_x6_r0_body.cx0_15.mlx PRE_first_tail_x6_r0_body.kr0_15 PRE_first_tail_x6_r0_body.kr1_15 PRE_first_tail_x6_r0_body.clo15 = true
kernel_rfl PRE_first_tail_x6_r0_body.fkn15 : Nat.ble 725 743 = true
-- the bridge and the pending traces' regions
kernel_rfl PRE_first_tail_x6_r0_body.cbridge15 : Host.Ts.Sim.Full.bridgeOf PRE_first_tail_x6_r0_body.s161.ffi = Host.Ts.Sim.Full.bridgeOf PRE_first_tail_x6_r0_body.s162.ffi
kernel_rfl PRE_first_tail_x6_r0_body.cpendR15 : pendRegB PRE_first_tail_x6_r0_body.kappa15 (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.s162.ffi).mlx = true
kernel_rfl PRE_first_tail_x6_r0_body.cpendLe15 : Nat.ble (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.s162.ffi).mlx.next (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.s161.ffi).mlx.next = true
/-- **The compaction's native shift**, given the call's bookkeeping, its relation's facts (the model's and the
observers') and the canonical closedness. -/
theorem PRE_first_tail_x6_r0_body.cshift15 (clean : Conv.NClean (⟨18509, 15578, 2687131, 725⟩ : Conv.Cnt) (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.s160.ffi).mlx) (hltC : ∀ h, PH (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.s160.ffi).mlx h → h < (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.s160.ffi).mlx.next) (nltC : ∀ i, PN (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.s160.ffi).mlx i → i < (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.s160.ffi).mlx.nnext) (itemsC : ∀ k v, (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.s160.ffi).mlx.items.get k = some v → PN (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.s160.ffi).mlx k) (tracedC : ∀ h o, (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.s160.ffi).mlx.objs.get h = some o → ∀ i ∈ objTraces o, i < PRE_first_tail_x6_r0_body.P15.NL) (cl : SSt (· < 743) PRE_first_tail_x6_r0_body.cx0_15.mlx)
    (hobjC : ∀ h, PRE_first_tail_x6_r0_body.fxC_15.get h = some () → ((Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.s160.ffi).mlx.objs.get h).isSome = true)
    (hfC : ∀ h, (PRE_first_tail_x6_r0_body.krC_15.flags.get h).isSome = true → ((Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.s160.ffi).mlx.objs.get h).isSome = true)
    (htC : ∀ h, (PRE_first_tail_x6_r0_body.krC_15.targs.get h).isSome = true → ((Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.s160.ffi).mlx.objs.get h).isSome = true)
    (hclC : ∀ h l, PRE_first_tail_x6_r0_body.krC_15.targs.get h = some l → Host.Ts.Sim.Full.STargs (· < (⟨18509, 15578, 2687131, 725⟩ : Conv.Cnt).n) l) :
    Conv.FullShiftQ PRE_first_tail_x6_r0_body.P15 743 PRE_first_tail_x6_r0_body.kappa15 PRE_first_tail_x6_r0_body.s162.ffi PRE_first_tail_x6_r0_body.s161.ffi :=
  ⟨PRE_first_tail_x6_r0_body.cnshift15 clean hltC nltC itemsC tracedC cl, PRE_first_tail_x6_r0_body.cqueue15, fun t ht => bSN_sound (List.all_eq_true.mp PRE_first_tail_x6_r0_body.ctokSupp15 t ht),
    PRE_first_tail_x6_r0_body.cbridge15,
    liveShift_foot (x0' := Host.Ts.Sim.Full.mlxOf PRE_first_tail_x6_r0_body.s162.ffi) (x1' := Host.Ts.Sim.Full.mlxOf PRE_first_tail_x6_r0_body.s161.ffi) (PRE_first_tail_x6_r0_body.cfoot15 clean hltC nltC itemsC tracedC cl) rfl PRE_first_tail_x6_r0_body.ofx0_15 PRE_first_tail_x6_r0_body.ofx1_15 hobjC PRE_first_tail_x6_r0_body.ff015 PRE_first_tail_x6_r0_body.ff115 PRE_first_tail_x6_r0_body.ffck15,
    kernShift_foot (x0' := Host.Ts.Sim.Full.mlxOf PRE_first_tail_x6_r0_body.s162.ffi) (x1' := Host.Ts.Sim.Full.mlxOf PRE_first_tail_x6_r0_body.s161.ffi) (PRE_first_tail_x6_r0_body.cfoot15 clean hltC nltC itemsC tracedC cl) rfl PRE_first_tail_x6_r0_body.okr0_15 PRE_first_tail_x6_r0_body.okr1_15 (Nat.le_of_ble_eq_true PRE_first_tail_x6_r0_body.fkn15) hfC htC hclC
      PRE_first_tail_x6_r0_body.fkf015 PRE_first_tail_x6_r0_body.fkt015 PRE_first_tail_x6_r0_body.fkf115 PRE_first_tail_x6_r0_body.fkt115 PRE_first_tail_x6_r0_body.fkck15,
    pendReg_of rfl PRE_first_tail_x6_r0_body.cnh015 PRE_first_tail_x6_r0_body.cnh115 (Nat.le_of_ble_eq_true PRE_first_tail_x6_r0_body.cpendLe15) PRE_first_tail_x6_r0_body.cpendR15⟩

end Host.Load.Run.Tpl
end

section -- st15/H0
set_option Elab.async false
namespace Host.Load.Run.Tpl
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
host_stream_state PRE_first_tail_x6_r0_body.st15 0
host_stream_state PRE_first_tail_x6_r0_body.st15 1
host_stream_state PRE_first_tail_x6_r0_body.st15 2
host_stream_state PRE_first_tail_x6_r0_body.st15 3
host_stream_state PRE_first_tail_x6_r0_body.st15 4
host_stream_state PRE_first_tail_x6_r0_body.st15 5
end Host.Load.Run.Tpl
end

section -- Site15
set_option Elab.async false
namespace Host.Load.Run.Tpl
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
open Host.Ts Host.Ts.Sim Host.Ts.Sim.Template

/-! Call site 15 of chain `PRE_first_tail_x6_r0_body`: `ssmW__g15__g16` (`recurWindow`), the call state `PRE_first_tail_x6_r0_body.s160`, the merged state `PRE_first_tail_x6_r0_body.s161`,
the site template `PRE_first_tail_x6_r0_body.st15` (σ = `Map.id`, θ the identity at its own site), the canonical state `PRE_first_tail_x6_r0_body.s162`: the merge.
The footprint's facts are in `SiteF15`, the compaction's in `SiteC15`, `SiteK15`, `SiteNa15`, `SiteNb15`. -/

kernel_rfl PRE_first_tail_x6_r0_body.iso15 : PRE_first_tail_x6_r0_body.st15.s0 = { PRE_first_tail_x6_r0_body.s160 with stack := [] }
/-- The caller's frames at the call. -/
noncomputable def PRE_first_tail_x6_r0_body.rs15 : List Frame := PRE_first_tail_x6_r0_body.s160.stack
kernel_rfl PRE_first_tail_x6_r0_body.n0_15 : PRE_first_tail_x6_r0_body.S160.tab.length = 725
kernel_rfl PRE_first_tail_x6_r0_body.tab0_15 : PRE_first_tail_x6_r0_body.st15.S0.tab = PRE_first_tail_x6_r0_body.S160.tab

/-- The fresh variables of the stage's results. -/
def PRE_first_tail_x6_r0_body.ws15 : List Nat := [1253, 1254, 1255, 1256, 1257, 1258, 1259, 1260, 1261, 1262, 1263, 1264, 1265, 1266, 1267, 1268, 1269, 1270, 1271, 1272, 1273, 1274, 1275, 1276, 1277, 1278, 1279, 1280, 1281, 1282, 1283]
kernel_rfl PRE_first_tail_x6_r0_body.fresh15 : (PRE_first_tail_x6_r0_body.S160.tab.all fun e => PRE_first_tail_x6_r0_body.ws15.all fun v => e.noVar v) &&
    (PRE_first_tail_x6_r0_body.S160.oracle.all fun q => PRE_first_tail_x6_r0_body.ws15.all fun v => q.noVar v) = true
kernel_rfl PRE_first_tail_x6_r0_body.mergeTab15 : PRE_first_tail_x6_r0_body.S161.tab = PRE_first_tail_x6_r0_body.S160.tab ++ Conv.resTab PRE_first_tail_x6_r0_body.ws15
kernel_rfl PRE_first_tail_x6_r0_body.mergeLen15 : PRE_first_tail_x6_r0_body.st15.S5.tab.length - PRE_first_tail_x6_r0_body.st15.S0.tab.length = 31

-- The merged state: the instance's return state with the caller's frames (`PRE_first_tail_x6_r0_body.merged15`, `merged_relB`).
kernel_rfl PRE_first_tail_x6_r0_body.mheap15 : PRE_first_tail_x6_r0_body.s161.heap = PRE_first_tail_x6_r0_body.st15.s5.heap
kernel_rfl PRE_first_tail_x6_r0_body.mnext15 : PRE_first_tail_x6_r0_body.s161.next = PRE_first_tail_x6_r0_body.st15.s5.next
kernel_rfl PRE_first_tail_x6_r0_body.mctl15 : PRE_first_tail_x6_r0_body.s161.ctl = PRE_first_tail_x6_r0_body.st15.s5.ctl
kernel_rfl PRE_first_tail_x6_r0_body.mstack15 : PRE_first_tail_x6_r0_body.s161.stack = PRE_first_tail_x6_r0_body.st15.s5.stack ++ PRE_first_tail_x6_r0_body.s160.stack
kernel_rfl PRE_first_tail_x6_r0_body.mjobs15 : PRE_first_tail_x6_r0_body.s161.jobs = PRE_first_tail_x6_r0_body.st15.s5.jobs
kernel_rfl PRE_first_tail_x6_r0_body.mffi15 : PRE_first_tail_x6_r0_body.s161.ffi = PRE_first_tail_x6_r0_body.st15.s5.ffi
kernel_rfl PRE_first_tail_x6_r0_body.mtrace15 : PRE_first_tail_x6_r0_body.s161.trace = PRE_first_tail_x6_r0_body.st15.s5.trace
kernel_rfl PRE_first_tail_x6_r0_body.mstores15 : PRE_first_tail_x6_r0_body.s161.stores = PRE_first_tail_x6_r0_body.st15.s5.stores

end Host.Load.Run.Tpl
end

section -- SiteD15
set_option Elab.async false
namespace Host.Load.Run.Tpl
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
open Host.Ts Host.Ts.Sim Host.Ts.Sim.Template

/-! The canonical results at call site 15 of chain `PRE_first_tail_x6_r0_body`: their values in the instance's end table, the references past
the call's table, the canonical variables apart from the stage's. -/

kernel_rfl PRE_first_tail_x6_r0_body.cderived15 : PRE_first_tail_x6_r0_body.nr15.map (fun r => nth? PRE_first_tail_x6_r0_body.st15.S5.tab r) =
  [some (SymE.bin .add (SymE.lit (F64.zero false)) (SymE.un .int32 (SymE.un .int32 (SymE.var 10)))),
   some (SymE.un .int32 (SymE.un .int32 (SymE.bin .sub (SymE.bin .add (SymE.lit (F64.fin false 3 (0))) (SymE.un .int32 (SymE.un .int32 (SymE.var 10)))) (SymE.lit (F64.fin false 3 (0)))))),
   some (SymE.un .int32 (SymE.bin .sub (SymE.bin .add (SymE.lit (F64.fin false 3 (0))) (SymE.un .int32 (SymE.un .int32 (SymE.var 10)))) (SymE.un .int32 (SymE.un .int32 (SymE.un .int32 (SymE.var 10)))))),
   some (SymE.un .int32 (SymE.bin .sub (SymE.bin .add (SymE.lit (F64.fin false 3 (0))) (SymE.un .int32 (SymE.un .int32 (SymE.var 10)))) (SymE.lit (F64.fin false 3 (0))))),
   some (SymE.un .int32 (SymE.bin .sub (SymE.bin .add (SymE.lit (F64.fin false 3 (0))) (SymE.un .int32 (SymE.un .int32 (SymE.var 10)))) (SymE.lit (F64.fin false 3 (0))))),
   some (SymE.un .int32 (SymE.bin .sub (SymE.bin .add (SymE.lit (F64.fin false 3 (0))) (SymE.un .int32 (SymE.un .int32 (SymE.var 10)))) (SymE.lit (F64.fin false 3 (0))))),
   some (SymE.un .int32 (SymE.un .int32 (SymE.bin .sub (SymE.bin .add (SymE.lit (F64.fin false 3 (0))) (SymE.un .int32 (SymE.un .int32 (SymE.var 10)))) (SymE.lit (F64.fin false 3 (0)))))),
   some (SymE.un .int32 (SymE.un .int32 (SymE.un .int32 (SymE.var 10)))),
   some (SymE.un .int32 (SymE.bin .add (SymE.un .int32 (SymE.un .int32 (SymE.var 10))) (SymE.lit (F64.fin false 3 (0))))),
   some (SymE.bin .sub (SymE.bin .add (SymE.lit (F64.fin false 3 (0))) (SymE.un .int32 (SymE.un .int32 (SymE.var 10)))) (SymE.un .int32 (SymE.un .int32 (SymE.un .int32 (SymE.var 10))))),
   some (SymE.un .int32 (SymE.bin .sub (SymE.bin .add (SymE.lit (F64.fin false 3 (0))) (SymE.un .int32 (SymE.un .int32 (SymE.var 10)))) (SymE.lit (F64.fin false 3 (0))))),
   some (SymE.bin .sub (SymE.bin .sub (SymE.bin .add (SymE.lit (F64.fin false 3 (0))) (SymE.un .int32 (SymE.un .int32 (SymE.var 10)))) (SymE.lit (F64.fin false 3 (0)))) (SymE.lit (F64.zero false))),
   some (SymE.bin .add (SymE.lit (F64.fin false 3 (0))) (SymE.un .int32 (SymE.un .int32 (SymE.var 10)))),
   some (SymE.un .int32 (SymE.bin .sub (SymE.bin .add (SymE.lit (F64.fin false 3 (0))) (SymE.un .int32 (SymE.un .int32 (SymE.var 10)))) (SymE.lit (F64.fin false 3 (0))))),
   some (SymE.bin .sub (SymE.bin .sub (SymE.bin .add (SymE.lit (F64.fin false 3 (0))) (SymE.un .int32 (SymE.un .int32 (SymE.var 10)))) (SymE.lit (F64.fin false 3 (0)))) (SymE.lit (F64.zero false))),
   some (SymE.un .int32 (SymE.bin .sub (SymE.bin .add (SymE.lit (F64.fin false 3 (0))) (SymE.un .int32 (SymE.un .int32 (SymE.var 10)))) (SymE.lit (F64.fin false 3 (0))))),
   some (SymE.bin .sub (SymE.bin .sub (SymE.bin .add (SymE.lit (F64.fin false 3 (0))) (SymE.un .int32 (SymE.un .int32 (SymE.var 10)))) (SymE.lit (F64.fin false 3 (0)))) (SymE.lit (F64.zero false))),
   some (SymE.bin .sub (SymE.bin .add (SymE.lit (F64.fin false 3 (0))) (SymE.un .int32 (SymE.un .int32 (SymE.var 10)))) (SymE.lit (F64.fin false 3 (0))))]
kernel_rfl PRE_first_tail_x6_r0_body.cnrLo15 : PRE_first_tail_x6_r0_body.nr15.all (Nat.ble 725) = true
kernel_rfl PRE_first_tail_x6_r0_body.cwsDisj15 : PRE_first_tail_x6_r0_body.cws15.all (fun c => !PRE_first_tail_x6_r0_body.ws15.contains c) = true
/-- The compaction's substitution: the canonical variables to their merged values, the stage's other fresh variables
to `0` (`Conv.compactθZ`). -/
noncomputable def PRE_first_tail_x6_r0_body.cthetaZ15 : Nat → SymE := Conv.compactθZ PRE_first_tail_x6_r0_body.cws15 PRE_first_tail_x6_r0_body.crs15 PRE_first_tail_x6_r0_body.ws15

end Host.Load.Run.Tpl
end

section -- st15/Foot
set_option Elab.async false
namespace Host.Load.Run.Tpl
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
open Host.Ts Host.Ts.Sim Host.Ts.Sim.Stage Host.Ts.Sim.Template

/-! The footprint of stage `PRE_first_tail_x6_r0_body.st15`'s site template (`Conv.StageFoot`, `Conv.NFoot`): every entry of the return
state other than the written and fresh ones is the start's (kernel evaluation of the equalities). -/

/-- The written heap ranges below the start's counter. -/
def PRE_first_tail_x6_r0_body.st15.wrR : List (Nat × Nat) := [(2672336, 2672337), (2686305, 2686306), (2686850, 2686851), (2687106, 2687107)]
/-- The written and fresh entries of the return state. -/
noncomputable def PRE_first_tail_x6_r0_body.st15.wrE : List (Nat × Host.Ts.HObj) :=
  rangesOf PRE_first_tail_x6_r0_body.st15.s5.heap PRE_first_tail_x6_r0_body.st15.wrR ++ freshOf PRE_first_tail_x6_r0_body.st15.s5.heap PRE_first_tail_x6_r0_body.st15.s0.next PRE_first_tail_x6_r0_body.st15.s5.next
noncomputable def PRE_first_tail_x6_r0_body.st15.wr : List Nat := PRE_first_tail_x6_r0_body.st15.wrE.map (·.1)

kernel_rfl PRE_first_tail_x6_r0_body.st15.heapFoot : PRE_first_tail_x6_r0_body.st15.s5.heap = setAll PRE_first_tail_x6_r0_body.st15.s0.heap PRE_first_tail_x6_r0_body.st15.wrE
kernel_rfl PRE_first_tail_x6_r0_body.st15.grows_check : Nat.ble PRE_first_tail_x6_r0_body.st15.s0.next PRE_first_tail_x6_r0_body.st15.s5.next = true
theorem PRE_first_tail_x6_r0_body.st15.grows : PRE_first_tail_x6_r0_body.st15.s0.next ≤ PRE_first_tail_x6_r0_body.st15.s5.next := Nat.le_of_ble_eq_true PRE_first_tail_x6_r0_body.st15.grows_check

/-- The written and fresh handles; the written readback items of old nodes. -/
def PRE_first_tail_x6_r0_body.st15.wh : List Nat := [18489, 18502, 18508, 18509, 18510, 18511, 18512, 18513, 18514, 18515, 18516, 18517, 18518, 18519, 18520, 18521, 18522, 18523, 18524, 18525, 18526, 18527, 18528, 18529, 18530, 18531, 18532, 18533, 18534, 18535, 18536]
def PRE_first_tail_x6_r0_body.st15.wi : List Nat := []

kernel_rfl PRE_first_tail_x6_r0_body.st15.arrsFoot : (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.st15.s5.ffi).mlx.arrs = setAll (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.st15.s0.ffi).mlx.arrs (PRE_first_tail_x6_r0_body.st15.wh.filterMap fun h => ((Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.st15.s5.ffi).mlx.arrs.get h).map (h, ·))
kernel_rfl PRE_first_tail_x6_r0_body.st15.objsFoot : (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.st15.s5.ffi).mlx.objs = setAll (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.st15.s0.ffi).mlx.objs (PRE_first_tail_x6_r0_body.st15.wh.filterMap fun h => ((Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.st15.s5.ffi).mlx.objs.get h).map (h, ·))
kernel_rfl PRE_first_tail_x6_r0_body.st15.nodesFoot : (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.st15.s5.ffi).mlx.nodes = setAll (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.st15.s0.ffi).mlx.nodes (freshOf (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.st15.s5.ffi).mlx.nodes (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.st15.s0.ffi).mlx.nnext (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.st15.s5.ffi).mlx.nnext)
kernel_rfl PRE_first_tail_x6_r0_body.st15.itemsFoot : (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.st15.s5.ffi).mlx.items = setAll (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.st15.s0.ffi).mlx.items ((PRE_first_tail_x6_r0_body.st15.wi.filterMap fun i => ((Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.st15.s5.ffi).mlx.items.get i).map (i, ·)) ++
    freshOf (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.st15.s5.ffi).mlx.items (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.st15.s0.ffi).mlx.nnext (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.st15.s5.ffi).mlx.nnext)
kernel_rfl PRE_first_tail_x6_r0_body.st15.counters : (Nat.ble (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.st15.s0.ffi).mlx.next (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.st15.s5.ffi).mlx.next && Nat.ble (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.st15.s0.ffi).mlx.nnext (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.st15.s5.ffi).mlx.nnext) = true

end Host.Load.Run.Tpl
end

section -- SiteF15
set_option Elab.async false
namespace Host.Load.Run.Tpl
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
open Host.Ts Host.Ts.Sim Host.Ts.Sim.Template

/-! Call site 15 of chain `PRE_first_tail_x6_r0_body`: `Conv.site_merge`'s footprint facts. -/

kernel_rfl PRE_first_tail_x6_r0_body.wrNodupB15 : nodupT PRE_first_tail_x6_r0_body.st15.wr PTrie.nil = true
theorem PRE_first_tail_x6_r0_body.wrNodup15 : PRE_first_tail_x6_r0_body.st15.wr.Nodup := (nodupT_sound PRE_first_tail_x6_r0_body.wrNodupB15).2
kernel_rfl PRE_first_tail_x6_r0_body.wrBoundB15 : PRE_first_tail_x6_r0_body.st15.wr.all (fun b => Nat.blt (b / 4096) (4 ^ 31)) = true
theorem PRE_first_tail_x6_r0_body.wrBound15 : ∀ b ∈ PRE_first_tail_x6_r0_body.st15.wr, b / 4096 < 4 ^ 31 := fun b hb => Nat.blt_eq.mp (List.all_eq_true.mp PRE_first_tail_x6_r0_body.wrBoundB15 b hb)
noncomputable def PRE_first_tail_x6_r0_body.trFr15 := PRE_first_tail_x6_r0_body.st15.s5.trace.take 120
kernel_rfl PRE_first_tail_x6_r0_body.traceEq15 : PRE_first_tail_x6_r0_body.st15.s5.trace = PRE_first_tail_x6_r0_body.trFr15 ++ PRE_first_tail_x6_r0_body.st15.s0.trace
theorem PRE_first_tail_x6_r0_body.trace15 : ∃ fr, PRE_first_tail_x6_r0_body.st15.s5.trace = fr ++ PRE_first_tail_x6_r0_body.st15.s0.trace := ⟨_, PRE_first_tail_x6_r0_body.traceEq15⟩

-- the caller's wide frames at the instance's start (`Conv.isolateW`'s `W0` under `Map.id`) and their `WFix`
def PRE_first_tail_x6_r0_body.wide15 : List (Nat × WFrame) := [(4910, .memo [])]
kernel_rfl PRE_first_tail_x6_r0_body.wfixB15 : (PRE_first_tail_x6_r0_body.wide15.all fun p => wfixB Map.id (presentB PRE_first_tail_x6_r0_body.st15.s0) p.2) = true
theorem PRE_first_tail_x6_r0_body.wfix15 : ∀ p ∈ PRE_first_tail_x6_r0_body.wide15, WFix Map.id (Present PRE_first_tail_x6_r0_body.st15.s0) p.2 :=
  fun p hp => wfix_of (List.all_eq_true.mp PRE_first_tail_x6_r0_body.wfixB15 p hp)

end Host.Load.Run.Tpl
end

section -- SiteL15
set_option Elab.async false
namespace Host.Load.Run.Tpl
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
open Host.Ts Host.Ts.Sim Host.Ts.Sim.Template

/-! The call link's facts at call site 15 of chain `PRE_first_tail_x6_r0_body`: the instance's start server, its footprint (`Conv.StageFoot`), the
merged state `PRE_first_tail_x6_r0_body.s161`'s framed arrays as the chain start's extended (`arrExt_of`, `numRefs_of`). -/

kernel_rfl PRE_first_tail_x6_r0_body.srvO15 : PRE_first_tail_x6_r0_body.st15.S0.oracle = PRE_first_tail_x6_r0_body.st15.OR
kernel_rfl PRE_first_tail_x6_r0_body.wr0B15 : PRE_first_tail_x6_r0_body.st15.wr.all (fun b => !Nat.blt b PRE_first_tail_x6_r0_body.st15.s0.next || (PRE_first_tail_x6_r0_body.st15.s0.heap.get b).isSome) = true
theorem PRE_first_tail_x6_r0_body.stFoot15 : Conv.StageFoot PRE_first_tail_x6_r0_body.st15.wr PRE_first_tail_x6_r0_body.st15.s0 PRE_first_tail_x6_r0_body.st15.s5 :=
  stageFoot_of PRE_first_tail_x6_r0_body.st15.heapFoot PRE_first_tail_x6_r0_body.wrNodup15 PRE_first_tail_x6_r0_body.wrBound15 PRE_first_tail_x6_r0_body.wr0B15 PRE_first_tail_x6_r0_body.st15.grows

/-- **The relation at the merged state** from the relation at the merge (`Conv.site_merge`'s; `merged_relB`). -/
theorem PRE_first_tail_x6_r0_body.merged15 {FR : Map → Nat → PRE_first_tail_x6_r0_body.st15.F.S → PRE_first_tail_x6_r0_body.st15.F.S → Prop} {W : Nat → Option WFrame} {stk : List Frame} {M : Map}
    {ν : Nat → F64} {K : Host.Ts.Sim.Ctx} {S : SSrv} {t : St PRE_first_tail_x6_r0_body.st15.F.S} {C : CSrv} {n0 : Nat}
    (h : RelB PRE_first_tail_x6_r0_body.st15.F FR W stk M ν K (Conv.mergeSt Map.id (Map.id.res n0 n0) PRE_first_tail_x6_r0_body.rs15 PRE_first_tail_x6_r0_body.st15.wr PRE_first_tail_x6_r0_body.s160 PRE_first_tail_x6_r0_body.st15.s5 PRE_first_tail_x6_r0_body.st15.s0
      PRE_first_tail_x6_r0_body.st15.s5.ffi) S t C) : RelB PRE_first_tail_x6_r0_body.st15.F FR W stk M ν K PRE_first_tail_x6_r0_body.s161 S t C :=
  merged_relB PRE_first_tail_x6_r0_body.iso15 PRE_first_tail_x6_r0_body.stFoot15 PRE_first_tail_x6_r0_body.wrNodup15 PRE_first_tail_x6_r0_body.wrBound15 PRE_first_tail_x6_r0_body.trace15 PRE_first_tail_x6_r0_body.mheap15
    PRE_first_tail_x6_r0_body.mnext15 PRE_first_tail_x6_r0_body.mctl15 PRE_first_tail_x6_r0_body.mstack15 PRE_first_tail_x6_r0_body.mjobs15 PRE_first_tail_x6_r0_body.mffi15 PRE_first_tail_x6_r0_body.mtrace15 PRE_first_tail_x6_r0_body.mstores15 h

def PRE_first_tail_x6_r0_body.arrEl15_2665 : List Val := []
kernel_rfl PRE_first_tail_x6_r0_body.arrE15_2665 : arrOf PRE_first_tail_x6_r0_body.s161 2665 = arrOf PRE_first_tail_x6_r0_body.s0 2665 ++ PRE_first_tail_x6_r0_body.arrEl15_2665
kernel_rfl PRE_first_tail_x6_r0_body.arrA15_2665 : isArrB PRE_first_tail_x6_r0_body.s161 2665 = true
theorem PRE_first_tail_x6_r0_body.arr15_2665 : ∃ o, PRE_first_tail_x6_r0_body.s161.heap.get 2665 = some (.obj o) ∧ o.kind = .array (arrOf PRE_first_tail_x6_r0_body.s0 2665 ++ PRE_first_tail_x6_r0_body.arrEl15_2665) :=
  arrExt_of PRE_first_tail_x6_r0_body.arrE15_2665 PRE_first_tail_x6_r0_body.arrA15_2665
kernel_rfl PRE_first_tail_x6_r0_body.arrN15_2665 : numRefsB PRE_first_tail_x6_r0_body.S0.tab.length PRE_first_tail_x6_r0_body.arrEl15_2665 = true
theorem PRE_first_tail_x6_r0_body.arrR15_2665 : Prefill.NumRefs PRE_first_tail_x6_r0_body.S0.tab.length PRE_first_tail_x6_r0_body.arrEl15_2665 := numRefs_of PRE_first_tail_x6_r0_body.arrN15_2665

def PRE_first_tail_x6_r0_body.arrEl15_2673467 : List Val := []
kernel_rfl PRE_first_tail_x6_r0_body.arrE15_2673467 : arrOf PRE_first_tail_x6_r0_body.s161 2673467 = arrOf PRE_first_tail_x6_r0_body.s0 2673467 ++ PRE_first_tail_x6_r0_body.arrEl15_2673467
kernel_rfl PRE_first_tail_x6_r0_body.arrA15_2673467 : isArrB PRE_first_tail_x6_r0_body.s161 2673467 = true
theorem PRE_first_tail_x6_r0_body.arr15_2673467 : ∃ o, PRE_first_tail_x6_r0_body.s161.heap.get 2673467 = some (.obj o) ∧ o.kind = .array (arrOf PRE_first_tail_x6_r0_body.s0 2673467 ++ PRE_first_tail_x6_r0_body.arrEl15_2673467) :=
  arrExt_of PRE_first_tail_x6_r0_body.arrE15_2673467 PRE_first_tail_x6_r0_body.arrA15_2673467
kernel_rfl PRE_first_tail_x6_r0_body.arrN15_2673467 : numRefsB PRE_first_tail_x6_r0_body.S0.tab.length PRE_first_tail_x6_r0_body.arrEl15_2673467 = true
theorem PRE_first_tail_x6_r0_body.arrR15_2673467 : Prefill.NumRefs PRE_first_tail_x6_r0_body.S0.tab.length PRE_first_tail_x6_r0_body.arrEl15_2673467 := numRefs_of PRE_first_tail_x6_r0_body.arrN15_2673467

kernel_rfl PRE_first_tail_x6_r0_body.w4910k15 : isArrB PRE_first_tail_x6_r0_body.s161 4910 = false
theorem PRE_first_tail_x6_r0_body.keep15 (q : List Val) : Host.Ts.Sim.Prefill.KeepsAtW (framesP PRE_first_tail_x6_r0_body.s0 q) PRE_first_tail_x6_r0_body.s161 := by
  intro a pre pre' hx o es ho hk
  unfold framesP at hx
  simp only at hx
  cases h1 : Nat.beq a 2665
  · cases h2 : Nat.beq a 4910
    · rw [h1, h2] at hx; cases hx
    · have := Nat.eq_of_beq_eq_true h2; subst this
      rw [h1, h2] at hx; cases hx
      exact (notArr_of PRE_first_tail_x6_r0_body.w4910k15 ho hk).elim
  · have := Nat.eq_of_beq_eq_true h1; subst this
    rw [h1] at hx; cases hx
    obtain ⟨o', ho', hk'⟩ := PRE_first_tail_x6_r0_body.arr15_2665
    rw [ho] at ho'; cases ho'
    rw [hk'] at hk; cases hk
    simp [PRE_first_tail_x6_r0_body.arrEl15_2665]

end Host.Load.Run.Tpl
end

section -- SiteZ15
set_option Elab.async false
namespace Host.Load.Run.Tpl
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
open Host.Ts Host.Ts.Sim Host.Ts.Sim.Template

/-! The compaction's state shift at call site 15 of chain `PRE_first_tail_x6_r0_body` (`Conv.compact_shift`): the call `PRE_first_tail_x6_r0_body.s160`, the merged
state `PRE_first_tail_x6_r0_body.s161`, the canonical state `PRE_first_tail_x6_r0_body.s162`; its frames [2665,2673467,2673472,2673473] (kept arrays [2665,2673467]). -/

-- the map's places and counters
kernel_rfl PRE_first_tail_x6_r0_body.zpl15 : PRE_first_tail_x6_r0_body.pl15.all (Nat.ble PRE_first_tail_x6_r0_body.s160.next) = true
kernel_rfl PRE_first_tail_x6_r0_body.zplnd15 : nodupT PRE_first_tail_x6_r0_body.pl15 PTrie.nil = true
kernel_rfl PRE_first_tail_x6_r0_body.zn115 : Nat.ble PRE_first_tail_x6_r0_body.s160.next 2688286 = true
kernel_rfl PRE_first_tail_x6_r0_body.zfirst15 : Nat.ble aFirst PRE_first_tail_x6_r0_body.s160.next = true
kernel_rfl PRE_first_tail_x6_r0_body.zscn15 : PRE_first_tail_x6_r0_body.s162.next = PRE_first_tail_x6_r0_body.s160.next + PRE_first_tail_x6_r0_body.pl15.length
kernel_rfl PRE_first_tail_x6_r0_body.zsmn15 : PRE_first_tail_x6_r0_body.s161.next = 2688286
kernel_rfl PRE_first_tail_x6_r0_body.zgrow15 : Nat.ble PRE_first_tail_x6_r0_body.s162.next PRE_first_tail_x6_r0_body.s161.next = true
-- the tables
kernel_rfl PRE_first_tail_x6_r0_body.zfresh15 : PRE_first_tail_x6_r0_body.S160.tab.all (fun e => PRE_first_tail_x6_r0_body.cws15.all fun v => e.noVar v) = true
kernel_rfl PRE_first_tail_x6_r0_body.zcnd15 : nodupT PRE_first_tail_x6_r0_body.cws15 PTrie.nil = true
kernel_rfl PRE_first_tail_x6_r0_body.znrHi15 : PRE_first_tail_x6_r0_body.nr15.all (fun r => Nat.blt r PRE_first_tail_x6_r0_body.S161.tab.length) = true
-- the frames: every framed address below the call's counter; the kept arrays the chain start's, extended in the merged state
kernel_rfl PRE_first_tail_x6_r0_body.zfrlt15 : [2665, 2673467, 2673472, 2673473].all (fun a => Nat.blt a PRE_first_tail_x6_r0_body.s160.next) = true
kernel_rfl PRE_first_tail_x6_r0_body.zg15_2665 : PRE_first_tail_x6_r0_body.s162.heap.get 2665 = some (.obj (objOf PRE_first_tail_x6_r0_body.s162 2665))
kernel_rfl PRE_first_tail_x6_r0_body.zk15_2665 : (objOf PRE_first_tail_x6_r0_body.s162 2665).kind = .array (arrOf PRE_first_tail_x6_r0_body.s0 2665)
kernel_rfl PRE_first_tail_x6_r0_body.zm15_2665 : PRE_first_tail_x6_r0_body.s161.heap.get 2665 = some (.obj { PRE_first_tail_x6_r0_body.kappa15.obj (objOf PRE_first_tail_x6_r0_body.s162 2665) with
  kind := .array (arrOf PRE_first_tail_x6_r0_body.s0 2665 ++ (arrOf PRE_first_tail_x6_r0_body.s161 2665).drop (arrOf PRE_first_tail_x6_r0_body.s0 2665).length) })
kernel_rfl PRE_first_tail_x6_r0_body.zg15_2673467 : PRE_first_tail_x6_r0_body.s162.heap.get 2673467 = some (.obj (objOf PRE_first_tail_x6_r0_body.s162 2673467))
kernel_rfl PRE_first_tail_x6_r0_body.zk15_2673467 : (objOf PRE_first_tail_x6_r0_body.s162 2673467).kind = .array (arrOf PRE_first_tail_x6_r0_body.s0 2673467)
kernel_rfl PRE_first_tail_x6_r0_body.zm15_2673467 : PRE_first_tail_x6_r0_body.s161.heap.get 2673467 = some (.obj { PRE_first_tail_x6_r0_body.kappa15.obj (objOf PRE_first_tail_x6_r0_body.s162 2673467) with
  kind := .array (arrOf PRE_first_tail_x6_r0_body.s0 2673467 ++ (arrOf PRE_first_tail_x6_r0_body.s161 2673467).drop (arrOf PRE_first_tail_x6_r0_body.s0 2673467).length) })
kernel_rfl PRE_first_tail_x6_r0_body.zw15_4910 : (PRE_first_tail_x6_r0_body.s162.heap.get 4910).isSome = true
kernel_rfl PRE_first_tail_x6_r0_body.zw15_2673472 : (PRE_first_tail_x6_r0_body.s162.heap.get 2673472).isSome = true
kernel_rfl PRE_first_tail_x6_r0_body.zw15_2673473 : (PRE_first_tail_x6_r0_body.s162.heap.get 2673473).isSome = true
-- the heap: the changed list in range, holding the stage's written and fresh addresses; the canonical side's image
kernel_rfl PRE_first_tail_x6_r0_body.zclbd15 : PRE_first_tail_x6_r0_body.cl15.all (fun b => Nat.blt (b / 4096) (4 ^ 31)) = true
kernel_rfl PRE_first_tail_x6_r0_body.zwr15 : PRE_first_tail_x6_r0_body.st15.wr.all (fun b => !Nat.blt b PRE_first_tail_x6_r0_body.s160.next || PRE_first_tail_x6_r0_body.cl15.contains b) = true
def PRE_first_tail_x6_r0_body.zl15 : List Nat := PRE_first_tail_x6_r0_body.cl15.filter fun a => !(List.contains [2665, 2673467] a)
kernel_rfl PRE_first_tail_x6_r0_body.zimgE15 : PRE_first_tail_x6_r0_body.zl15.map (fun a => PRE_first_tail_x6_r0_body.s161.heap.get (PRE_first_tail_x6_r0_body.kappa15.a a)) = PRE_first_tail_x6_r0_body.zl15.map (fun a => (PRE_first_tail_x6_r0_body.s162.heap.get a).map PRE_first_tail_x6_r0_body.kappa15.hobj)
theorem PRE_first_tail_x6_r0_body.zimg15 : HeapImg PRE_first_tail_x6_r0_body.kappa15 PRE_first_tail_x6_r0_body.s162 PRE_first_tail_x6_r0_body.s161 PRE_first_tail_x6_r0_body.zl15 := PRE_first_tail_x6_r0_body.zimgE15
-- the roots and their supports
kernel_rfl PRE_first_tail_x6_r0_body.zctl15 : PRE_first_tail_x6_r0_body.s161.ctl = PRE_first_tail_x6_r0_body.kappa15.ctl PRE_first_tail_x6_r0_body.s162.ctl
kernel_rfl PRE_first_tail_x6_r0_body.zstack15 : PRE_first_tail_x6_r0_body.s161.stack = PRE_first_tail_x6_r0_body.s162.stack.map PRE_first_tail_x6_r0_body.kappa15.frame
kernel_rfl PRE_first_tail_x6_r0_body.zjobs15 : PRE_first_tail_x6_r0_body.s161.jobs = PRE_first_tail_x6_r0_body.s162.jobs.map PRE_first_tail_x6_r0_body.kappa15.job
kernel_rfl PRE_first_tail_x6_r0_body.zstores15 : PRE_first_tail_x6_r0_body.s161.stores = PRE_first_tail_x6_r0_body.kappa15.stores PRE_first_tail_x6_r0_body.s162.stores
kernel_rfl PRE_first_tail_x6_r0_body.zroots15 : checkRootsSupp PRE_first_tail_x6_r0_body.s162 743 = true
kernel_rfl PRE_first_tail_x6_r0_body.znC15 : PRE_first_tail_x6_r0_body.S160.tab.length + PRE_first_tail_x6_r0_body.cws15.length = 743
-- the map as `Conv.compact_shift` states it (the call's counters for the literals)
kernel_rfl PRE_first_tail_x6_r0_body.zkap15 : PRE_first_tail_x6_r0_body.kappa15 = Conv.Map.compact PRE_first_tail_x6_r0_body.s160.next 2688286 PRE_first_tail_x6_r0_body.S160.tab.length PRE_first_tail_x6_r0_body.pl15 (PRE_first_tail_x6_r0_body.nr15.map NumV.ref) PRE_first_tail_x6_r0_body.kd15.big
  PRE_first_tail_x6_r0_body.kd15.region PRE_first_tail_x6_r0_body.kd15.nodeF
-- the bridge inactive at the canonical state (`Conv.FullShiftQ.toX`; the merged state's bridge is the canonical's: cbridge)
theorem PRE_first_tail_x6_r0_body.zbin15 : (Host.Ts.Sim.Full.bridgeOf PRE_first_tail_x6_r0_body.s162.ffi).active = false := (Host.Load.Boot.replay_active Host.Load.Run.Prompt.P.oblog2818)
-- the JS bookkeeping's step (`Conv.JClean.step` over the changed list) and the canonical roots' bigint freedom
kernel_rfl PRE_first_tail_x6_r0_body.zjc15 : Conv.jcleanListB (⟨18512, 15605, 2687137, 743⟩ : Conv.Cnt) PRE_first_tail_x6_r0_body.s162 PRE_first_tail_x6_r0_body.cl15 = true
kernel_rfl PRE_first_tail_x6_r0_body.zrootsB15 : noBigRootsP (fun i => !Conv.oldBigB (⟨18512, 15605, 2687137, 743⟩ : Conv.Cnt) i) PRE_first_tail_x6_r0_body.s162.trace PRE_first_tail_x6_r0_body.s162 = true
kernel_rfl PRE_first_tail_x6_r0_body.zhm15 : Nat.ble (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.s0.ffi).mlx.nnext 15578 = true
theorem PRE_first_tail_x6_r0_body.cjcl15 (h : Conv.JClean (⟨18509, 15578, 2687131, 725⟩ : Conv.Cnt) PRE_first_tail_x6_r0_body.s160) : Conv.JClean (⟨18512, 15605, 2687137, 743⟩ : Conv.Cnt) PRE_first_tail_x6_r0_body.s162 :=
  Conv.JClean.step h (Conv.Cnt.le_of_leB PRE_first_tail_x6_r0_body.cle15)
    (Conv.heap_off_setAll PRE_first_tail_x6_r0_body.cheap15 fun a ha => Nat.blt_eq.mp (List.all_eq_true.mp PRE_first_tail_x6_r0_body.zclbd15 a ha)) PRE_first_tail_x6_r0_body.zjc15

end Host.Load.Run.Tpl
end

section -- st15/TypedLast
set_option Elab.async false
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
namespace Host.Load.Run.Tpl
open Host.Ts Host.Ts.Sim Host.Ts.Sim.Template

boot_rfl PRE_first_tail_x6_r0_body.st15.bodyLast from PRE_first_tail_x6_r0_body.st15.s4 to PRE_first_tail_x6_r0_body.st15.s5 :
  interpS (step PRE_first_tail_x6_r0_body.st15.F PRE_first_tail_x6_r0_body.st15.s4).run PRE_first_tail_x6_r0_body.st15.S4 = some (PRE_first_tail_x6_r0_body.st15.s5, PRE_first_tail_x6_r0_body.st15.S5)
kernel_rfl PRE_first_tail_x6_r0_body.st15.bodyHalt : isHalt PRE_first_tail_x6_r0_body.st15.s4.ctl = false
kernel_rfl PRE_first_tail_x6_r0_body.st15.bodyTopCheck : noBlockTop PRE_first_tail_x6_r0_body.st15.s5.stack = true

end Host.Load.Run.Tpl
end

section -- st15/TypedOk
set_option Elab.async false
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
namespace Host.Load.Run.Tpl
open Host.Ts Host.Ts.Sim Host.Ts.Sim.Template

noncomputable def PRE_first_tail_x6_r0_body.st15.bodyOkL (bytes : List Byte) (rows : Nat) : St PRE_first_tail_x6_r0_body.st15.F.S → SSrv → Bool :=
  okLocal (Host.Ts.Sim.Compose.VWFrames.bodyOk bytes rows)

noncomputable def PRE_first_tail_x6_r0_body.st15.bodyOkLN (bytes : List Byte) (rows : Nat) : St PRE_first_tail_x6_r0_body.st15.F.S → FSrv → Bool :=
  okLocalN (Host.Ts.Sim.Compose.VWFrames.bodyOkN bytes rows)

theorem PRE_first_tail_x6_r0_body.st15.bodyOkLN_ok (bytes : List Byte) (rows : Nat) (s : St PRE_first_tail_x6_r0_body.st15.F.S) (c : FSrv) (h : c.Wf) :
    PRE_first_tail_x6_r0_body.st15.bodyOkLN bytes rows s c = PRE_first_tail_x6_r0_body.st15.bodyOkL bytes rows s c.toS :=
  okLocalN_ok (Host.Ts.Sim.Compose.VWFrames.bodyOkN_ok bytes rows) s c h

kernel_rfl PRE_first_tail_x6_r0_body.st15.bodyAccepted0 :
  (fun (bytes : List Byte) (rows : Nat) => PRE_first_tail_x6_r0_body.st15.bodyOkL bytes rows PRE_first_tail_x6_r0_body.st15.s0 PRE_first_tail_x6_r0_body.st15.S0) = fun _ _ => true

kernel_rfl PRE_first_tail_x6_r0_body.st15.bodyAccepted1 :
  (fun (bytes : List Byte) (rows : Nat) => PRE_first_tail_x6_r0_body.st15.bodyOkL bytes rows PRE_first_tail_x6_r0_body.st15.s4 PRE_first_tail_x6_r0_body.st15.S4) = fun _ _ => true

end Host.Load.Run.Tpl
end

section -- st15/TypedK0
set_option Elab.async false
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
namespace Host.Load.Run.Tpl
open Host.Ts Host.Ts.Sim Host.Ts.Sim.Template

boot_rfl PRE_first_tail_x6_r0_body.st15.bodyK0F from PRE_first_tail_x6_r0_body.st15.s0 to PRE_first_tail_x6_r0_body.st15.s1 :
  (fun (bytes : List Byte) (rows : Nat) => runOkS PRE_first_tail_x6_r0_body.st15.F (PRE_first_tail_x6_r0_body.st15.bodyOkLN bytes rows)
    ((nth? PRE_first_tail_x6_r0_body.st15.ks 0).getD 0) PRE_first_tail_x6_r0_body.st15.s0 PRE_first_tail_x6_r0_body.st15.S0) = fun _ _ => some (PRE_first_tail_x6_r0_body.st15.s1, PRE_first_tail_x6_r0_body.st15.S1)
theorem PRE_first_tail_x6_r0_body.st15.bodyK0 :
  (fun (bytes : List Byte) (rows : Nat) => runOk PRE_first_tail_x6_r0_body.st15.F (PRE_first_tail_x6_r0_body.st15.bodyOkL bytes rows)
    ((nth? PRE_first_tail_x6_r0_body.st15.ks 0).getD 0) PRE_first_tail_x6_r0_body.st15.s0 PRE_first_tail_x6_r0_body.st15.S0) = fun _ _ => some (PRE_first_tail_x6_r0_body.st15.s1, PRE_first_tail_x6_r0_body.st15.S1) :=
  runOk_fun_of_runOkS PRE_first_tail_x6_r0_body.st15.bodyOkLN_ok PRE_first_tail_x6_r0_body.st15.bodyK0F
end Host.Load.Run.Tpl
end

section -- st15/TypedK1
set_option Elab.async false
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
namespace Host.Load.Run.Tpl
open Host.Ts Host.Ts.Sim Host.Ts.Sim.Template

boot_rfl PRE_first_tail_x6_r0_body.st15.bodyK1F from PRE_first_tail_x6_r0_body.st15.s1 to PRE_first_tail_x6_r0_body.st15.s2 :
  (fun (bytes : List Byte) (rows : Nat) => runOkS PRE_first_tail_x6_r0_body.st15.F (PRE_first_tail_x6_r0_body.st15.bodyOkLN bytes rows)
    ((nth? PRE_first_tail_x6_r0_body.st15.ks 1).getD 0) PRE_first_tail_x6_r0_body.st15.s1 PRE_first_tail_x6_r0_body.st15.S1) = fun _ _ => some (PRE_first_tail_x6_r0_body.st15.s2, PRE_first_tail_x6_r0_body.st15.S2)
theorem PRE_first_tail_x6_r0_body.st15.bodyK1 :
  (fun (bytes : List Byte) (rows : Nat) => runOk PRE_first_tail_x6_r0_body.st15.F (PRE_first_tail_x6_r0_body.st15.bodyOkL bytes rows)
    ((nth? PRE_first_tail_x6_r0_body.st15.ks 1).getD 0) PRE_first_tail_x6_r0_body.st15.s1 PRE_first_tail_x6_r0_body.st15.S1) = fun _ _ => some (PRE_first_tail_x6_r0_body.st15.s2, PRE_first_tail_x6_r0_body.st15.S2) :=
  runOk_fun_of_runOkS PRE_first_tail_x6_r0_body.st15.bodyOkLN_ok PRE_first_tail_x6_r0_body.st15.bodyK1F
end Host.Load.Run.Tpl
end

section -- st15/TypedK2
set_option Elab.async false
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
namespace Host.Load.Run.Tpl
open Host.Ts Host.Ts.Sim Host.Ts.Sim.Template

boot_rfl PRE_first_tail_x6_r0_body.st15.bodyK2F from PRE_first_tail_x6_r0_body.st15.s2 to PRE_first_tail_x6_r0_body.st15.s3 :
  (fun (bytes : List Byte) (rows : Nat) => runOkS PRE_first_tail_x6_r0_body.st15.F (PRE_first_tail_x6_r0_body.st15.bodyOkLN bytes rows)
    ((nth? PRE_first_tail_x6_r0_body.st15.ks 2).getD 0) PRE_first_tail_x6_r0_body.st15.s2 PRE_first_tail_x6_r0_body.st15.S2) = fun _ _ => some (PRE_first_tail_x6_r0_body.st15.s3, PRE_first_tail_x6_r0_body.st15.S3)
theorem PRE_first_tail_x6_r0_body.st15.bodyK2 :
  (fun (bytes : List Byte) (rows : Nat) => runOk PRE_first_tail_x6_r0_body.st15.F (PRE_first_tail_x6_r0_body.st15.bodyOkL bytes rows)
    ((nth? PRE_first_tail_x6_r0_body.st15.ks 2).getD 0) PRE_first_tail_x6_r0_body.st15.s2 PRE_first_tail_x6_r0_body.st15.S2) = fun _ _ => some (PRE_first_tail_x6_r0_body.st15.s3, PRE_first_tail_x6_r0_body.st15.S3) :=
  runOk_fun_of_runOkS PRE_first_tail_x6_r0_body.st15.bodyOkLN_ok PRE_first_tail_x6_r0_body.st15.bodyK2F
end Host.Load.Run.Tpl
end

section -- st15/TypedK3
set_option Elab.async false
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
namespace Host.Load.Run.Tpl
open Host.Ts Host.Ts.Sim Host.Ts.Sim.Template

boot_rfl PRE_first_tail_x6_r0_body.st15.bodyK3F from PRE_first_tail_x6_r0_body.st15.s3 to PRE_first_tail_x6_r0_body.st15.s4 :
  (fun (bytes : List Byte) (rows : Nat) => runOkS PRE_first_tail_x6_r0_body.st15.F (PRE_first_tail_x6_r0_body.st15.bodyOkLN bytes rows)
    ((nth? PRE_first_tail_x6_r0_body.st15.ks 3).getD 0) PRE_first_tail_x6_r0_body.st15.s3 PRE_first_tail_x6_r0_body.st15.S3) = fun _ _ => some (PRE_first_tail_x6_r0_body.st15.s4, PRE_first_tail_x6_r0_body.st15.S4)
theorem PRE_first_tail_x6_r0_body.st15.bodyK3 :
  (fun (bytes : List Byte) (rows : Nat) => runOk PRE_first_tail_x6_r0_body.st15.F (PRE_first_tail_x6_r0_body.st15.bodyOkL bytes rows)
    ((nth? PRE_first_tail_x6_r0_body.st15.ks 3).getD 0) PRE_first_tail_x6_r0_body.st15.s3 PRE_first_tail_x6_r0_body.st15.S3) = fun _ _ => some (PRE_first_tail_x6_r0_body.st15.s4, PRE_first_tail_x6_r0_body.st15.S4) :=
  runOk_fun_of_runOkS PRE_first_tail_x6_r0_body.st15.bodyOkLN_ok PRE_first_tail_x6_r0_body.st15.bodyK3F
end Host.Load.Run.Tpl
end

section -- st15/TypedTpl
set_option Elab.async false
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
namespace Host.Load.Run.Tpl
open Host.Ts Host.Ts.Sim Host.Ts.Sim.Template

theorem PRE_first_tail_x6_r0_body.st15.bodyRun (bytes : List Byte) (rows : Nat) :
    runOk PRE_first_tail_x6_r0_body.st15.F (PRE_first_tail_x6_r0_body.st15.bodyOkL bytes rows) 11334 PRE_first_tail_x6_r0_body.st15.s0 PRE_first_tail_x6_r0_body.st15.S0 = some (PRE_first_tail_x6_r0_body.st15.s4, PRE_first_tail_x6_r0_body.st15.S4) :=
  runOk_trans PRE_first_tail_x6_r0_body.st15.F (PRE_first_tail_x6_r0_body.st15.bodyOkL bytes rows) ((((nth? PRE_first_tail_x6_r0_body.st15.ks 0).getD 0) + ((nth? PRE_first_tail_x6_r0_body.st15.ks 1).getD 0)) + ((nth? PRE_first_tail_x6_r0_body.st15.ks 2).getD 0)) ((nth? PRE_first_tail_x6_r0_body.st15.ks 3).getD 0) PRE_first_tail_x6_r0_body.st15.s0 PRE_first_tail_x6_r0_body.st15.s3 PRE_first_tail_x6_r0_body.st15.s4 PRE_first_tail_x6_r0_body.st15.S0 PRE_first_tail_x6_r0_body.st15.S3 PRE_first_tail_x6_r0_body.st15.S4 (runOk_trans PRE_first_tail_x6_r0_body.st15.F (PRE_first_tail_x6_r0_body.st15.bodyOkL bytes rows) (((nth? PRE_first_tail_x6_r0_body.st15.ks 0).getD 0) + ((nth? PRE_first_tail_x6_r0_body.st15.ks 1).getD 0)) ((nth? PRE_first_tail_x6_r0_body.st15.ks 2).getD 0) PRE_first_tail_x6_r0_body.st15.s0 PRE_first_tail_x6_r0_body.st15.s2 PRE_first_tail_x6_r0_body.st15.s3 PRE_first_tail_x6_r0_body.st15.S0 PRE_first_tail_x6_r0_body.st15.S2 PRE_first_tail_x6_r0_body.st15.S3 (runOk_trans PRE_first_tail_x6_r0_body.st15.F (PRE_first_tail_x6_r0_body.st15.bodyOkL bytes rows) ((nth? PRE_first_tail_x6_r0_body.st15.ks 0).getD 0) ((nth? PRE_first_tail_x6_r0_body.st15.ks 1).getD 0) PRE_first_tail_x6_r0_body.st15.s0 PRE_first_tail_x6_r0_body.st15.s1 PRE_first_tail_x6_r0_body.st15.s2 PRE_first_tail_x6_r0_body.st15.S0 PRE_first_tail_x6_r0_body.st15.S1 PRE_first_tail_x6_r0_body.st15.S2 ((congrFun (congrFun PRE_first_tail_x6_r0_body.st15.bodyK0 bytes) rows)) (congrFun (congrFun PRE_first_tail_x6_r0_body.st15.bodyK1 bytes) rows)) (congrFun (congrFun PRE_first_tail_x6_r0_body.st15.bodyK2 bytes) rows)) (congrFun (congrFun PRE_first_tail_x6_r0_body.st15.bodyK3 bytes) rows)

theorem PRE_first_tail_x6_r0_body.st15.bodyLocal (bytes : List Byte) (rows : Nat) : ∀ s S, PRE_first_tail_x6_r0_body.st15.bodyOkL bytes rows s S = true → Disp.localB s = true := okLocal_localB

noncomputable def PRE_first_tail_x6_r0_body.st15.bodyTpl (bytes : List Byte) (rows : Nat) : Host.Ts.Sim.Stage.StageTpl PRE_first_tail_x6_r0_body.st15.F (PRE_first_tail_x6_r0_body.st15.bodyOkL bytes rows) where
  s0 := PRE_first_tail_x6_r0_body.st15.s0
  S0 := PRE_first_tail_x6_r0_body.st15.S0
  s1 := PRE_first_tail_x6_r0_body.st15.s4
  S1 := PRE_first_tail_x6_r0_body.st15.S4
  s2 := PRE_first_tail_x6_r0_body.st15.s5
  S2 := PRE_first_tail_x6_r0_body.st15.S5
  n := 11334
  ok0 := congrFun (congrFun PRE_first_tail_x6_r0_body.st15.bodyAccepted0 bytes) rows
  run := PRE_first_tail_x6_r0_body.st15.bodyRun bytes rows
  ok1 := congrFun (congrFun PRE_first_tail_x6_r0_body.st15.bodyAccepted1 bytes) rows
  halt := PRE_first_tail_x6_r0_body.st15.bodyHalt
  last := PRE_first_tail_x6_r0_body.st15.bodyLast
  top := noBlockTop_sound PRE_first_tail_x6_r0_body.st15.bodyTopCheck
end Host.Load.Run.Tpl
end

section -- SiteC16
set_option Elab.async false
namespace Host.Load.Run.Tpl
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
open Host.Ts Host.Ts.Sim Host.Ts.Sim.Template

/-! The compaction after the merge at call site 16 of chain `PRE_first_tail_x6_r0_body` (`Conv.compact`, `Conv.full_compactQ`): the canonical
state `PRE_first_tail_x6_r0_body.s170` (the stage's results at canonical places, its trace the call's) under `PRE_first_tail_x6_r0_body.kappa16` into the merged state
`PRE_first_tail_x6_r0_body.s169`. -/

def PRE_first_tail_x6_r0_body.pl16 : List Nat := []
def PRE_first_tail_x6_r0_body.nr16 : List Nat := []
/-- The native part of the compaction map (canonical → merged handles and nodes: its `big`, `region`, `nodeF`). -/
def PRE_first_tail_x6_r0_body.kd16 : RData :=
  ⟨2687627, 2687629, Stage.setAll PTrie.nil [], Stage.setAll PTrie.nil [],
   18525, 18525, 15618, 15618, Stage.setAll PTrie.nil [],
   Stage.setAll PTrie.nil []⟩
/-- **The compaction map.** -/
noncomputable def PRE_first_tail_x6_r0_body.kappa16 : Map :=
  Conv.Map.compact 2687627 2687629 764 PRE_first_tail_x6_r0_body.pl16 (PRE_first_tail_x6_r0_body.nr16.map NumV.ref) PRE_first_tail_x6_r0_body.kd16.big
    PRE_first_tail_x6_r0_body.kd16.region PRE_first_tail_x6_r0_body.kd16.nodeF
/-- The canonical result variables and their images, the merged state's entries (`Conv.compactθ`). -/
def PRE_first_tail_x6_r0_body.cws16 : List Nat := []
noncomputable def PRE_first_tail_x6_r0_body.crs16 : List SymE := PRE_first_tail_x6_r0_body.nr16.map fun r => (nth? PRE_first_tail_x6_r0_body.S169.tab r).getD (.var 0)
noncomputable def PRE_first_tail_x6_r0_body.ctheta16 : Nat → SymE := Conv.compactθ PRE_first_tail_x6_r0_body.cws16 PRE_first_tail_x6_r0_body.crs16
/-- The call's entries the stage wrote (renamed in the canonical state with the results). -/
def PRE_first_tail_x6_r0_body.wrB16 : List Nat := [2665, 2673467]

kernel_rfl PRE_first_tail_x6_r0_body.ctab16 : PRE_first_tail_x6_r0_body.S170.tab = PRE_first_tail_x6_r0_body.S168.tab ++ PRE_first_tail_x6_r0_body.cws16.map SymE.var
kernel_rfl PRE_first_tail_x6_r0_body.ctrace16 : PRE_first_tail_x6_r0_body.s170.trace = PRE_first_tail_x6_r0_body.s168.trace
kernel_rfl PRE_first_tail_x6_r0_body.cnext16 : PRE_first_tail_x6_r0_body.s170.next = 2687627
kernel_rfl PRE_first_tail_x6_r0_body.ccounters16 : ((Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.s170.ffi).mlx.next, (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.s170.ffi).mlx.nnext) = (18525, 15618)
-- the merged state's readback queue, carried to the canonical state (`Conv.FullShiftQ.tokens`, `tokSupp`)
kernel_rfl PRE_first_tail_x6_r0_body.cqueue16 : (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.s169.ffi).mlx.tokens = (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.s170.ffi).mlx.tokens.map PRE_first_tail_x6_r0_body.kappa16.nv
kernel_rfl PRE_first_tail_x6_r0_body.ctokSupp16 : (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.s170.ffi).mlx.tokens.all (bSN 764) = true
-- the written and the result entries carry no bigint of the canonical fresh band [next, E) and no fresh region
kernel_rfl PRE_first_tail_x6_r0_body.cclean16 : Conv.cleanListB 18525 131072 (fun r => Nat.ble 74100 r) PRE_first_tail_x6_r0_body.s170
    (PRE_first_tail_x6_r0_body.wrB16 ++ (List.range 0).map (2687627 + ·)) = true
kernel_rfl PRE_first_tail_x6_r0_body.cbigs16 : bigsOutB 18525 131072 (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.s170.ffi).mlx = true

end Host.Load.Run.Tpl
end

section -- SiteK16
set_option Elab.async false
namespace Host.Load.Run.Tpl
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
open Host.Ts Host.Ts.Sim Host.Ts.Sim.Template

/-! The canonical state's closedness from the call's (`Conv.closed_of_callB`, `Conv.sst_of_callB`): it keeps the call's entries
off the written and the result ones (`PRE_first_tail_x6_r0_body.cl16`; natively the written and result handles, the result nodes, the written
and result items), and those are checked. -/

def PRE_first_tail_x6_r0_body.cl16 : List Nat := [2665, 2673467]
def PRE_first_tail_x6_r0_body.clo16 : List Nat := []
def PRE_first_tail_x6_r0_body.cln16 : List Nat := []
def PRE_first_tail_x6_r0_body.cli16 : List Nat := []
kernel_rfl PRE_first_tail_x6_r0_body.cheap16 : PRE_first_tail_x6_r0_body.s170.heap = Stage.setAll PRE_first_tail_x6_r0_body.s168.heap (PRE_first_tail_x6_r0_body.cl16.filterMap fun a => (PRE_first_tail_x6_r0_body.s170.heap.get a).map (a, ·))
kernel_rfl PRE_first_tail_x6_r0_body.cnextLe16 : Nat.ble PRE_first_tail_x6_r0_body.s168.next PRE_first_tail_x6_r0_body.s170.next = true
kernel_rfl PRE_first_tail_x6_r0_body.ckeepP16 : Conv.keptPresentB PRE_first_tail_x6_r0_body.s168 PRE_first_tail_x6_r0_body.s170 PRE_first_tail_x6_r0_body.cl16 = true
kernel_rfl PRE_first_tail_x6_r0_body.csupp16 : Conv.suppListB PRE_first_tail_x6_r0_body.s170 764 PRE_first_tail_x6_r0_body.cl16 = true
kernel_rfl PRE_first_tail_x6_r0_body.cbound16 : Conv.boundListB PRE_first_tail_x6_r0_body.s170 PRE_first_tail_x6_r0_body.cl16 = true
kernel_rfl PRE_first_tail_x6_r0_body.cnodesK16 : (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.s170.ffi).mlx.nodes = Stage.setAll (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.s168.ffi).mlx.nodes (PRE_first_tail_x6_r0_body.cln16.filterMap fun i => ((Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.s170.ffi).mlx.nodes.get i).map (i, ·))
kernel_rfl PRE_first_tail_x6_r0_body.cobjsK16 : (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.s170.ffi).mlx.objs = Stage.setAll (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.s168.ffi).mlx.objs (PRE_first_tail_x6_r0_body.clo16.filterMap fun i => ((Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.s170.ffi).mlx.objs.get i).map (i, ·))
kernel_rfl PRE_first_tail_x6_r0_body.citemsK16 : (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.s170.ffi).mlx.items = Stage.setAll (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.s168.ffi).mlx.items (PRE_first_tail_x6_r0_body.cli16.filterMap fun i => ((Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.s170.ffi).mlx.items.get i).map (i, ·))
kernel_rfl PRE_first_tail_x6_r0_body.csst16 : Conv.sstListB 764 (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.s170.ffi).mlx PRE_first_tail_x6_r0_body.cln16 PRE_first_tail_x6_r0_body.clo16 PRE_first_tail_x6_r0_body.cli16 = true

end Host.Load.Run.Tpl
end

section -- SiteCl16
set_option Elab.async false
namespace Host.Load.Run.Tpl
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
open Host.Ts Host.Ts.Sim Host.Ts.Sim.Template

kernel_rfl PRE_first_tail_x6_r0_body.ckA16 : (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.s170.ffi).mlx.arrs = Stage.setAll (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.s168.ffi).mlx.arrs (PRE_first_tail_x6_r0_body.clo16.filterMap fun i => ((Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.s170.ffi).mlx.arrs.get i).map (i, ·))
kernel_rfl PRE_first_tail_x6_r0_body.cbd16 : (PRE_first_tail_x6_r0_body.clo16 ++ PRE_first_tail_x6_r0_body.cln16 ++ PRE_first_tail_x6_r0_body.cli16).all (fun i => Nat.blt (i / 4096) (4 ^ 31)) = true
kernel_rfl PRE_first_tail_x6_r0_body.cle16 : Conv.Cnt.leB (⟨18525, 15618, 2687627, 764⟩ : Conv.Cnt) (⟨18525, 15618, 2687627, 764⟩ : Conv.Cnt) = true
kernel_rfl PRE_first_tail_x6_r0_body.cck16 : Conv.ncleanListB (⟨18525, 15618, 2687627, 764⟩ : Conv.Cnt) (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.s170.ffi).mlx PRE_first_tail_x6_r0_body.clo16 PRE_first_tail_x6_r0_body.cln16 PRE_first_tail_x6_r0_body.cli16 = true
theorem PRE_first_tail_x6_r0_body.cncl16 (h : Conv.NClean (⟨18525, 15618, 2687627, 764⟩ : Conv.Cnt) (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.s168.ffi).mlx) : Conv.NClean (⟨18525, 15618, 2687627, 764⟩ : Conv.Cnt) (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.s170.ffi).mlx :=
  Conv.NClean.stepKeep h PRE_first_tail_x6_r0_body.cle16 PRE_first_tail_x6_r0_body.ckA16 PRE_first_tail_x6_r0_body.cobjsK16 PRE_first_tail_x6_r0_body.cnodesK16 PRE_first_tail_x6_r0_body.citemsK16 PRE_first_tail_x6_r0_body.cbd16 PRE_first_tail_x6_r0_body.cck16

end Host.Load.Run.Tpl
end

section -- SiteS16
set_option Elab.async false
namespace Host.Load.Run.Tpl
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
open Host.Ts Host.Ts.Sim Host.Ts.Sim.Template

/-! The compaction's native shift at call site 16 from its footprint (`Conv.nshift_of_foot`), and the observers'
(`liveShift_foot`, `kernShift_foot`): `Conv.FullShiftQ` for `Conv.full_compactQ`, given the call's bookkeeping and its
relation's facts. -/

/-- The load parameters of the chain (band-free: its start's node counter as `NL` and `N0`). -/
def PRE_first_tail_x6_r0_body.Pc16 : LoadP := ⟨18151, 131072, 1099511627776, 15235, 15235, []⟩
/-- The site's band raised to the map's checked fixed-node prefix, including newly recorded closure traces. -/
def PRE_first_tail_x6_r0_body.P16 : LoadP := PRE_first_tail_x6_r0_body.Pc16.raise 15618
kernel_rfl PRE_first_tail_x6_r0_body.craise16 : Nat.ble PRE_first_tail_x6_r0_body.Pc16.N0 15618 = true
theorem PRE_first_tail_x6_r0_body.raised16 : Host.Ts.Sim.Full.Raised PRE_first_tail_x6_r0_body.Pc16 PRE_first_tail_x6_r0_body.P16 :=
  .inr ⟨15618, rfl, Nat.le_of_ble_eq_true PRE_first_tail_x6_r0_body.craise16, rfl⟩
noncomputable abbrev PRE_first_tail_x6_r0_body.cx0_16 : Host.Load.LSt := clearTokens (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.s170.ffi)
noncomputable abbrev PRE_first_tail_x6_r0_body.cx1_16 : Host.Load.LSt := clearTokens (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.s169.ffi)
def PRE_first_tail_x6_r0_body.khinv16 : PTrie Nat := Stage.setAll PTrie.nil []
def PRE_first_tail_x6_r0_body.kninv16 : PTrie Nat := Stage.setAll PTrie.nil []
/-- The stage's footprint: its written and fresh handles, fresh nodes, written and fresh items. -/
def PRE_first_tail_x6_r0_body.cwS16 : List Nat := []
def PRE_first_tail_x6_r0_body.cnS16 : List Nat := List.range' 15618 0
def PRE_first_tail_x6_r0_body.ciS16 : List Nat := [] ++ List.range' 15618 0

-- the small checks (`MChecks`'s)
kernel_rfl PRE_first_tail_x6_r0_body.cnh016 : PRE_first_tail_x6_r0_body.kd16.nh0 = PRE_first_tail_x6_r0_body.cx0_16.mlx.next
kernel_rfl PRE_first_tail_x6_r0_body.cnh116 : PRE_first_tail_x6_r0_body.kd16.nh1 = PRE_first_tail_x6_r0_body.cx1_16.mlx.next
kernel_rfl PRE_first_tail_x6_r0_body.cnn016 : PRE_first_tail_x6_r0_body.kd16.nn0 = PRE_first_tail_x6_r0_body.cx0_16.mlx.nnext
kernel_rfl PRE_first_tail_x6_r0_body.cnn116 : PRE_first_tail_x6_r0_body.kd16.nn1 = PRE_first_tail_x6_r0_body.cx1_16.mlx.nnext
kernel_rfl PRE_first_tail_x6_r0_body.cplo16 : (Nat.blt 0 PRE_first_tail_x6_r0_body.P16.lo && Nat.ble PRE_first_tail_x6_r0_body.P16.lo PRE_first_tail_x6_r0_body.cx0_16.mlx.next && Nat.ble PRE_first_tail_x6_r0_body.P16.lo RData.bigHi && Nat.ble RData.bigHi PRE_first_tail_x6_r0_body.P16.E) = true
kernel_rfl PRE_first_tail_x6_r0_body.ccnt16 : (Nat.ble PRE_first_tail_x6_r0_body.cx0_16.mlx.next PRE_first_tail_x6_r0_body.cx1_16.mlx.next && Nat.ble PRE_first_tail_x6_r0_body.cx0_16.mlx.nnext PRE_first_tail_x6_r0_body.cx1_16.mlx.nnext) = true
kernel_rfl PRE_first_tail_x6_r0_body.cnband16 : (Nat.blt 0 PRE_first_tail_x6_r0_body.P16.NL && Nat.ble PRE_first_tail_x6_r0_body.P16.NL PRE_first_tail_x6_r0_body.P16.N0 && Nat.ble PRE_first_tail_x6_r0_body.P16.N0 PRE_first_tail_x6_r0_body.cx0_16.mlx.nnext) = true
kernel_rfl PRE_first_tail_x6_r0_body.chbelow16 : PRE_first_tail_x6_r0_body.kd16.checkHndBelow = true
kernel_rfl PRE_first_tail_x6_r0_body.chren16 : checkRenG PRE_first_tail_x6_r0_body.kd16.hnd PRE_first_tail_x6_r0_body.khinv16 (phB PRE_first_tail_x6_r0_body.cx0_16.mlx) = true
kernel_rfl PRE_first_tail_x6_r0_body.cband16 : PRE_first_tail_x6_r0_body.kd16.checkBand PRE_first_tail_x6_r0_body.P16.lo = true
kernel_rfl PRE_first_tail_x6_r0_body.cnh1pos16 : Nat.blt 0 PRE_first_tail_x6_r0_body.kd16.nh1 = true
kernel_rfl PRE_first_tail_x6_r0_body.cnren16 : checkRenG PRE_first_tail_x6_r0_body.kd16.node PRE_first_tail_x6_r0_body.kninv16 (pnB PRE_first_tail_x6_r0_body.cx0_16.mlx) = true
kernel_rfl PRE_first_tail_x6_r0_body.cnlow16 : (PTrie.keysA PRE_first_tail_x6_r0_body.kd16.node).all (fun j => Nat.ble PRE_first_tail_x6_r0_body.P16.NL j && Nat.blt (PRE_first_tail_x6_r0_body.kd16.nodeF j) PRE_first_tail_x6_r0_body.cx1_16.mlx.nnext) = true
kernel_rfl PRE_first_tail_x6_r0_body.cabs0a16 : PRE_first_tail_x6_r0_body.cx0_16.mlx.arrs.get 0 = none
kernel_rfl PRE_first_tail_x6_r0_body.cabs0b16 : PRE_first_tail_x6_r0_body.cx0_16.mlx.objs.get 0 = none
kernel_rfl PRE_first_tail_x6_r0_body.ctok116 : PRE_first_tail_x6_r0_body.cx1_16.mlx.tokens = []
kernel_rfl PRE_first_tail_x6_r0_body.cpend16 : PRE_first_tail_x6_r0_body.cx1_16.mlx.pending = PRE_first_tail_x6_r0_body.cx0_16.mlx.pending.map PRE_first_tail_x6_r0_body.kappa16.pend
kernel_rfl PRE_first_tail_x6_r0_body.cerrh16 : PRE_first_tail_x6_r0_body.cx1_16.mlx.errh = PRE_first_tail_x6_r0_body.cx0_16.mlx.errh.map PRE_first_tail_x6_r0_body.kappa16.arg
kernel_rfl PRE_first_tail_x6_r0_body.cfiles16 : PRE_first_tail_x6_r0_body.cx1_16.mlx.files = PRE_first_tail_x6_r0_body.cx0_16.mlx.files
kernel_rfl PRE_first_tail_x6_r0_body.carch16 : PRE_first_tail_x6_r0_body.cx1_16.mlx.arch = PRE_first_tail_x6_r0_body.cx0_16.mlx.arch
kernel_rfl PRE_first_tail_x6_r0_body.csizes16 : PRE_first_tail_x6_r0_body.cx1_16.mlx.deviceSizes = PRE_first_tail_x6_r0_body.cx0_16.mlx.deviceSizes
kernel_rfl PRE_first_tail_x6_r0_body.cwired16 : PRE_first_tail_x6_r0_body.cx1_16.mlx.wired = PRE_first_tail_x6_r0_body.cx0_16.mlx.wired
kernel_rfl PRE_first_tail_x6_r0_body.chost16 : PRE_first_tail_x6_r0_body.cx1_16.host = PRE_first_tail_x6_r0_body.cx0_16.host
-- the compaction map's addresses are `PRE_first_tail_x6_r0_body.kd16`'s
kernel_rfl PRE_first_tail_x6_r0_body.ckn016 : PRE_first_tail_x6_r0_body.kd16.n0 = 2687627
kernel_rfl PRE_first_tail_x6_r0_body.ckn116 : PRE_first_tail_x6_r0_body.kd16.n1 = 2687629
kernel_rfl PRE_first_tail_x6_r0_body.ckheap16 : (PTrie.keysA PRE_first_tail_x6_r0_body.kd16.heap).all (fun x => Nat.ble 2687627 x) = true
kernel_rfl PRE_first_tail_x6_r0_body.ckpl16 : (List.range 0).all (fun j => decide (PRE_first_tail_x6_r0_body.kd16.heap.get (2687627 + j) = nth? PRE_first_tail_x6_r0_body.pl16 j)) = true
-- the map fixes the call's names (`Conv.fixOld_compact`), the call's counters
kernel_rfl PRE_first_tail_x6_r0_body.fja16 : Nat.ble 2687627 2687627 = true
kernel_rfl PRE_first_tail_x6_r0_body.fn16 : Nat.ble 764 764 = true
kernel_rfl PRE_first_tail_x6_r0_body.fjaD16 : Nat.ble 2687627 PRE_first_tail_x6_r0_body.kd16.n0 = true
kernel_rfl PRE_first_tail_x6_r0_body.fxn16 : Nat.ble 18525 PRE_first_tail_x6_r0_body.kd16.nh0 = true
kernel_rfl PRE_first_tail_x6_r0_body.fnn16 : Nat.ble 15618 PRE_first_tail_x6_r0_body.kd16.nn0 = true
kernel_rfl PRE_first_tail_x6_r0_body.fxb16 : Nat.ble 18525 RData.bigHi = true
kernel_rfl PRE_first_tail_x6_r0_body.fheap16 : (PTrie.keysA PRE_first_tail_x6_r0_body.kd16.heap).all (Nat.ble (⟨18525, 15618, 2687627, 764⟩ : Conv.Cnt).ja) = true
kernel_rfl PRE_first_tail_x6_r0_body.fhnd16 : (PTrie.keysA PRE_first_tail_x6_r0_body.kd16.hnd).all (Nat.ble (⟨18525, 15618, 2687627, 764⟩ : Conv.Cnt).xn) = true
kernel_rfl PRE_first_tail_x6_r0_body.fnode16 : (PTrie.keysA PRE_first_tail_x6_r0_body.kd16.node).all (Nat.ble (⟨18525, 15618, 2687627, 764⟩ : Conv.Cnt).nn) = true
/-- The compaction map fixes the call's names. -/
theorem PRE_first_tail_x6_r0_body.cfix16 : Conv.FixOld (⟨18525, 15618, 2687627, 764⟩ : Conv.Cnt) PRE_first_tail_x6_r0_body.kappa16 :=
  Conv.fixOld_compact (Nat.le_of_ble_eq_true PRE_first_tail_x6_r0_body.fja16) (Nat.le_of_ble_eq_true PRE_first_tail_x6_r0_body.fn16) (Nat.le_of_ble_eq_true PRE_first_tail_x6_r0_body.fjaD16) (Nat.le_of_ble_eq_true PRE_first_tail_x6_r0_body.fxn16) (Nat.le_of_ble_eq_true PRE_first_tail_x6_r0_body.fnn16) (Nat.le_of_ble_eq_true PRE_first_tail_x6_r0_body.fxb16) PRE_first_tail_x6_r0_body.fheap16 PRE_first_tail_x6_r0_body.fhnd16 PRE_first_tail_x6_r0_body.fnode16
kernel_rfl PRE_first_tail_x6_r0_body.fcxn16 : (⟨18525, 15618, 2687627, 764⟩ : Conv.Cnt).xn = (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.s168.ffi).mlx.next
kernel_rfl PRE_first_tail_x6_r0_body.fcnn16 : (⟨18525, 15618, 2687627, 764⟩ : Conv.Cnt).nn = (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.s168.ffi).mlx.nnext
kernel_rfl PRE_first_tail_x6_r0_body.fle016 : (Nat.ble (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.s168.ffi).mlx.next PRE_first_tail_x6_r0_body.cx0_16.mlx.next && Nat.ble (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.s168.ffi).mlx.nnext PRE_first_tail_x6_r0_body.cx0_16.mlx.nnext && Nat.ble (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.s168.ffi).mlx.next RData.bigHi) = true
kernel_rfl PRE_first_tail_x6_r0_body.fnk16 : (PTrie.keysA PRE_first_tail_x6_r0_body.kd16.node).all (Nat.ble (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.s168.ffi).mlx.nnext) = true
-- the merged state keeps the call's entries off the stage's footprint
kernel_rfl PRE_first_tail_x6_r0_body.f1A16 : PRE_first_tail_x6_r0_body.cx1_16.mlx.arrs = Stage.setAll (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.s168.ffi).mlx.arrs (PRE_first_tail_x6_r0_body.cwS16.filterMap fun i => (PRE_first_tail_x6_r0_body.cx1_16.mlx.arrs.get i).map (i, ·))
kernel_rfl PRE_first_tail_x6_r0_body.f1O16 : PRE_first_tail_x6_r0_body.cx1_16.mlx.objs = Stage.setAll (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.s168.ffi).mlx.objs (PRE_first_tail_x6_r0_body.cwS16.filterMap fun i => (PRE_first_tail_x6_r0_body.cx1_16.mlx.objs.get i).map (i, ·))
kernel_rfl PRE_first_tail_x6_r0_body.f1N16 : PRE_first_tail_x6_r0_body.cx1_16.mlx.nodes = Stage.setAll (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.s168.ffi).mlx.nodes (PRE_first_tail_x6_r0_body.cnS16.filterMap fun i => (PRE_first_tail_x6_r0_body.cx1_16.mlx.nodes.get i).map (i, ·))
kernel_rfl PRE_first_tail_x6_r0_body.f1I16 : PRE_first_tail_x6_r0_body.cx1_16.mlx.items = Stage.setAll (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.s168.ffi).mlx.items (PRE_first_tail_x6_r0_body.ciS16.filterMap fun i => (PRE_first_tail_x6_r0_body.cx1_16.mlx.items.get i).map (i, ·))
kernel_rfl PRE_first_tail_x6_r0_body.fbd16 : (PRE_first_tail_x6_r0_body.clo16 ++ PRE_first_tail_x6_r0_body.cln16 ++ PRE_first_tail_x6_r0_body.cli16 ++ PRE_first_tail_x6_r0_body.cwS16 ++ PRE_first_tail_x6_r0_body.cnS16 ++ PRE_first_tail_x6_r0_body.ciS16).all (fun i => Nat.blt (i / 4096) (4 ^ 31)) = true
kernel_rfl PRE_first_tail_x6_r0_body.fincW16 : PRE_first_tail_x6_r0_body.cwS16.all (fun h => !Nat.blt h (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.s168.ffi).mlx.next || PRE_first_tail_x6_r0_body.clo16.contains h) = true
kernel_rfl PRE_first_tail_x6_r0_body.fincI16 : PRE_first_tail_x6_r0_body.ciS16.all (fun k => !Nat.blt k (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.s168.ffi).mlx.nnext || PRE_first_tail_x6_r0_body.cli16.contains k) = true
kernel_rfl PRE_first_tail_x6_r0_body.fincN16 : PRE_first_tail_x6_r0_body.cnS16.all (Nat.ble (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.s168.ffi).mlx.nnext) = true
kernel_rfl PRE_first_tail_x6_r0_body.flnF16 : PRE_first_tail_x6_r0_body.cln16.all (Nat.ble (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.s168.ffi).mlx.nnext) = true
-- the checks over the changed lists
kernel_rfl PRE_first_tail_x6_r0_body.fh16 : PRE_first_tail_x6_r0_body.clo16.all (handleOK PRE_first_tail_x6_r0_body.kappa16 PRE_first_tail_x6_r0_body.P16.lo PRE_first_tail_x6_r0_body.cx0_16.mlx PRE_first_tail_x6_r0_body.cx1_16.mlx) = true
kernel_rfl PRE_first_tail_x6_r0_body.fo16 : PRE_first_tail_x6_r0_body.clo16.map (fun h => PRE_first_tail_x6_r0_body.cx1_16.mlx.objs.get (PRE_first_tail_x6_r0_body.kappa16.handle h)) = PRE_first_tail_x6_r0_body.clo16.map (fun h => (PRE_first_tail_x6_r0_body.cx0_16.mlx.objs.get h).map PRE_first_tail_x6_r0_body.kappa16.nobj)
kernel_rfl PRE_first_tail_x6_r0_body.fok16 : PRE_first_tail_x6_r0_body.clo16.all (objOK PRE_first_tail_x6_r0_body.kappa16 PRE_first_tail_x6_r0_body.P16.NL PRE_first_tail_x6_r0_body.cx0_16.mlx) = true
kernel_rfl PRE_first_tail_x6_r0_body.fnd16 : PRE_first_tail_x6_r0_body.cln16.all (nodeOKF PRE_first_tail_x6_r0_body.kappa16 PRE_first_tail_x6_r0_body.P16 PRE_first_tail_x6_r0_body.cx0_16.mlx PRE_first_tail_x6_r0_body.cx1_16.mlx) = true
kernel_rfl PRE_first_tail_x6_r0_body.fp16 : ((PRE_first_tail_x6_r0_body.cln16.filter (fullB PRE_first_tail_x6_r0_body.P16))).map (fun i => (PRE_first_tail_x6_r0_body.cx1_16.mlx.nodes.get (PRE_first_tail_x6_r0_body.kappa16.node i)).map Host.Mlx.Ffi.Node.prim) =
  ((PRE_first_tail_x6_r0_body.cln16.filter (fullB PRE_first_tail_x6_r0_body.P16))).map (fun i => (PRE_first_tail_x6_r0_body.cx0_16.mlx.nodes.get i).map fun nd => PRE_first_tail_x6_r0_body.kappa16.prim nd.prim)
kernel_rfl PRE_first_tail_x6_r0_body.fnordI16 : incrB PRE_first_tail_x6_r0_body.kd16.nodeF (List.range' 15618 0) = true
kernel_rfl PRE_first_tail_x6_r0_body.fnordK16 : (PTrie.keysA PRE_first_tail_x6_r0_body.kd16.node).all (fun k => Nat.ble 15618 k && Nat.blt k 15618) = true
kernel_rfl PRE_first_tail_x6_r0_body.fnordL16 : (PRE_first_tail_x6_r0_body.cln16.filter (Nat.ble PRE_first_tail_x6_r0_body.P16.N0)).all (fun i => Nat.ble i (PRE_first_tail_x6_r0_body.kd16.nodeF i) && (Nat.blt i 15618 || Nat.ble PRE_first_tail_x6_r0_body.kd16.nn0 i)) = true
theorem PRE_first_tail_x6_r0_body.fnord16 : (PRE_first_tail_x6_r0_body.cln16.filter (Nat.ble PRE_first_tail_x6_r0_body.P16.N0)).all (fun i => Nat.ble i (PRE_first_tail_x6_r0_body.kd16.nodeF i) &&
    (PTrie.keysA PRE_first_tail_x6_r0_body.kd16.node).all fun j => !Nat.blt j i || Nat.blt (PRE_first_tail_x6_r0_body.kd16.nodeF j) (PRE_first_tail_x6_r0_body.kd16.nodeF i)) = true :=
  cnord_of PRE_first_tail_x6_r0_body.cnlow16 PRE_first_tail_x6_r0_body.cnn116 PRE_first_tail_x6_r0_body.fnordI16 PRE_first_tail_x6_r0_body.fnordK16 PRE_first_tail_x6_r0_body.fnordL16
kernel_rfl PRE_first_tail_x6_r0_body.fi16 : PRE_first_tail_x6_r0_body.cli16.all (pnB PRE_first_tail_x6_r0_body.cx0_16.mlx) = true
kernel_rfl PRE_first_tail_x6_r0_body.fii16 : PRE_first_tail_x6_r0_body.cli16.all (fun k => decide (PRE_first_tail_x6_r0_body.cx1_16.mlx.items.get (PRE_first_tail_x6_r0_body.kappa16.node k) = (PRE_first_tail_x6_r0_body.cx0_16.mlx.items.get k).map PRE_first_tail_x6_r0_body.kappa16.nv)) = true
/-- **The compaction's footprint.** -/
theorem PRE_first_tail_x6_r0_body.cfoot16 (clean : Conv.NClean (⟨18525, 15618, 2687627, 764⟩ : Conv.Cnt) (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.s168.ffi).mlx) (hltC : ∀ h, PH (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.s168.ffi).mlx h → h < (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.s168.ffi).mlx.next) (nltC : ∀ i, PN (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.s168.ffi).mlx i → i < (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.s168.ffi).mlx.nnext) (itemsC : ∀ k v, (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.s168.ffi).mlx.items.get k = some v → PN (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.s168.ffi).mlx k) (tracedC : ∀ h o, (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.s168.ffi).mlx.objs.get h = some o → ∀ i ∈ objTraces o, i < PRE_first_tail_x6_r0_body.P16.NL) (cl : SSt (· < 764) PRE_first_tail_x6_r0_body.cx0_16.mlx) :
    Conv.MFoot PRE_first_tail_x6_r0_body.P16 764 PRE_first_tail_x6_r0_body.kappa16 PRE_first_tail_x6_r0_body.kd16 PRE_first_tail_x6_r0_body.khinv16 PRE_first_tail_x6_r0_body.kninv16 (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.s168.ffi).mlx PRE_first_tail_x6_r0_body.cx0_16.mlx PRE_first_tail_x6_r0_body.cx1_16.mlx (⟨18525, 15618, 2687627, 764⟩ : Conv.Cnt) PRE_first_tail_x6_r0_body.clo16 PRE_first_tail_x6_r0_body.cln16 PRE_first_tail_x6_r0_body.cli16 PRE_first_tail_x6_r0_body.cwS16 PRE_first_tail_x6_r0_body.cnS16 PRE_first_tail_x6_r0_body.ciS16 :=
  ⟨rfl, rfl, rfl, PRE_first_tail_x6_r0_body.cnh016, PRE_first_tail_x6_r0_body.cnh116, PRE_first_tail_x6_r0_body.cnn016, PRE_first_tail_x6_r0_body.cnn116, PRE_first_tail_x6_r0_body.cplo16, PRE_first_tail_x6_r0_body.ccnt16, PRE_first_tail_x6_r0_body.cnband16, PRE_first_tail_x6_r0_body.chbelow16, PRE_first_tail_x6_r0_body.chren16, PRE_first_tail_x6_r0_body.cband16, PRE_first_tail_x6_r0_body.cnh1pos16, PRE_first_tail_x6_r0_body.cnren16, PRE_first_tail_x6_r0_body.cnlow16, PRE_first_tail_x6_r0_body.cabs0a16, PRE_first_tail_x6_r0_body.cabs0b16, PRE_first_tail_x6_r0_body.ctok116, PRE_first_tail_x6_r0_body.cpend16, PRE_first_tail_x6_r0_body.cerrh16, PRE_first_tail_x6_r0_body.cfiles16, PRE_first_tail_x6_r0_body.carch16, PRE_first_tail_x6_r0_body.csizes16, PRE_first_tail_x6_r0_body.cwired16, PRE_first_tail_x6_r0_body.cfix16, clean, PRE_first_tail_x6_r0_body.fcxn16, PRE_first_tail_x6_r0_body.fcnn16, hltC, nltC, itemsC, tracedC, cl, PRE_first_tail_x6_r0_body.fle016, PRE_first_tail_x6_r0_body.fnk16, PRE_first_tail_x6_r0_body.ckA16, PRE_first_tail_x6_r0_body.cobjsK16, PRE_first_tail_x6_r0_body.cnodesK16, PRE_first_tail_x6_r0_body.citemsK16, PRE_first_tail_x6_r0_body.f1A16, PRE_first_tail_x6_r0_body.f1O16, PRE_first_tail_x6_r0_body.f1N16, PRE_first_tail_x6_r0_body.f1I16, PRE_first_tail_x6_r0_body.fbd16, PRE_first_tail_x6_r0_body.fincW16, PRE_first_tail_x6_r0_body.fincI16, PRE_first_tail_x6_r0_body.fincN16, PRE_first_tail_x6_r0_body.flnF16, PRE_first_tail_x6_r0_body.fh16, PRE_first_tail_x6_r0_body.fo16, PRE_first_tail_x6_r0_body.fok16, PRE_first_tail_x6_r0_body.fnd16, PRE_first_tail_x6_r0_body.fp16, PRE_first_tail_x6_r0_body.fnord16, PRE_first_tail_x6_r0_body.fi16, PRE_first_tail_x6_r0_body.fii16⟩
theorem PRE_first_tail_x6_r0_body.cnshift16 (clean : Conv.NClean (⟨18525, 15618, 2687627, 764⟩ : Conv.Cnt) (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.s168.ffi).mlx) (hltC : ∀ h, PH (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.s168.ffi).mlx h → h < (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.s168.ffi).mlx.next) (nltC : ∀ i, PN (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.s168.ffi).mlx i → i < (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.s168.ffi).mlx.nnext) (itemsC : ∀ k v, (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.s168.ffi).mlx.items.get k = some v → PN (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.s168.ffi).mlx k) (tracedC : ∀ h o, (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.s168.ffi).mlx.objs.get h = some o → ∀ i ∈ objTraces o, i < PRE_first_tail_x6_r0_body.P16.NL) (cl : SSt (· < 764) PRE_first_tail_x6_r0_body.cx0_16.mlx) : NShift PRE_first_tail_x6_r0_body.P16 764 PRE_first_tail_x6_r0_body.kappa16 PRE_first_tail_x6_r0_body.cx0_16 PRE_first_tail_x6_r0_body.cx1_16 :=
  Conv.nshift_of_foot (PRE_first_tail_x6_r0_body.cfoot16 clean hltC nltC itemsC tracedC cl) PRE_first_tail_x6_r0_body.chost16 (compact_a_eq PRE_first_tail_x6_r0_body.ckn016 PRE_first_tail_x6_r0_body.ckn116 PRE_first_tail_x6_r0_body.ckheap16 PRE_first_tail_x6_r0_body.ckpl16)

-- the observers: the layers' states at the call, the canonical and the merged state, their footprints and checks
noncomputable def PRE_first_tail_x6_r0_body.fxC_16 : PTrie Unit := (Host.Ts.Sim.Full.freedOf PRE_first_tail_x6_r0_body.s168.ffi).getD PTrie.nil
noncomputable def PRE_first_tail_x6_r0_body.krC_16 : Host.Load.Layers.KRec := (Host.Ts.Sim.Full.krecOf PRE_first_tail_x6_r0_body.s168.ffi).getD Host.Load.Layers.KRec.empty
kernel_rfl PRE_first_tail_x6_r0_body.ofxC_16 : (Host.Ts.Sim.Full.freedOf PRE_first_tail_x6_r0_body.s168.ffi) = some PRE_first_tail_x6_r0_body.fxC_16
kernel_rfl PRE_first_tail_x6_r0_body.okrC_16 : (Host.Ts.Sim.Full.krecOf PRE_first_tail_x6_r0_body.s168.ffi) = some PRE_first_tail_x6_r0_body.krC_16
noncomputable def PRE_first_tail_x6_r0_body.fx0_16 : PTrie Unit := (Host.Ts.Sim.Full.freedOf PRE_first_tail_x6_r0_body.s170.ffi).getD PTrie.nil
noncomputable def PRE_first_tail_x6_r0_body.kr0_16 : Host.Load.Layers.KRec := (Host.Ts.Sim.Full.krecOf PRE_first_tail_x6_r0_body.s170.ffi).getD Host.Load.Layers.KRec.empty
kernel_rfl PRE_first_tail_x6_r0_body.ofx0_16 : (Host.Ts.Sim.Full.freedOf PRE_first_tail_x6_r0_body.s170.ffi) = some PRE_first_tail_x6_r0_body.fx0_16
kernel_rfl PRE_first_tail_x6_r0_body.okr0_16 : (Host.Ts.Sim.Full.krecOf PRE_first_tail_x6_r0_body.s170.ffi) = some PRE_first_tail_x6_r0_body.kr0_16
noncomputable def PRE_first_tail_x6_r0_body.fx1_16 : PTrie Unit := (Host.Ts.Sim.Full.freedOf PRE_first_tail_x6_r0_body.s169.ffi).getD PTrie.nil
noncomputable def PRE_first_tail_x6_r0_body.kr1_16 : Host.Load.Layers.KRec := (Host.Ts.Sim.Full.krecOf PRE_first_tail_x6_r0_body.s169.ffi).getD Host.Load.Layers.KRec.empty
kernel_rfl PRE_first_tail_x6_r0_body.ofx1_16 : (Host.Ts.Sim.Full.freedOf PRE_first_tail_x6_r0_body.s169.ffi) = some PRE_first_tail_x6_r0_body.fx1_16
kernel_rfl PRE_first_tail_x6_r0_body.okr1_16 : (Host.Ts.Sim.Full.krecOf PRE_first_tail_x6_r0_body.s169.ffi) = some PRE_first_tail_x6_r0_body.kr1_16
kernel_rfl PRE_first_tail_x6_r0_body.ff016 : PRE_first_tail_x6_r0_body.fx0_16 = Stage.setAll PRE_first_tail_x6_r0_body.fxC_16 (PRE_first_tail_x6_r0_body.clo16.filterMap fun i => (PRE_first_tail_x6_r0_body.fx0_16.get i).map (i, ·))
kernel_rfl PRE_first_tail_x6_r0_body.ff116 : PRE_first_tail_x6_r0_body.fx1_16 = Stage.setAll PRE_first_tail_x6_r0_body.fxC_16 (PRE_first_tail_x6_r0_body.cwS16.filterMap fun i => (PRE_first_tail_x6_r0_body.fx1_16.get i).map (i, ·))
kernel_rfl PRE_first_tail_x6_r0_body.ffck16 : freedLB PRE_first_tail_x6_r0_body.kappa16 PRE_first_tail_x6_r0_body.cx0_16.mlx PRE_first_tail_x6_r0_body.fx0_16 PRE_first_tail_x6_r0_body.fx1_16 PRE_first_tail_x6_r0_body.clo16 = true
kernel_rfl PRE_first_tail_x6_r0_body.fkf016 : PRE_first_tail_x6_r0_body.kr0_16.flags = Stage.setAll PRE_first_tail_x6_r0_body.krC_16.flags (PRE_first_tail_x6_r0_body.clo16.filterMap fun i => (PRE_first_tail_x6_r0_body.kr0_16.flags.get i).map (i, ·))
kernel_rfl PRE_first_tail_x6_r0_body.fkt016 : PRE_first_tail_x6_r0_body.kr0_16.targs = Stage.setAll PRE_first_tail_x6_r0_body.krC_16.targs (PRE_first_tail_x6_r0_body.clo16.filterMap fun i => (PRE_first_tail_x6_r0_body.kr0_16.targs.get i).map (i, ·))
kernel_rfl PRE_first_tail_x6_r0_body.fkf116 : PRE_first_tail_x6_r0_body.kr1_16.flags = Stage.setAll PRE_first_tail_x6_r0_body.krC_16.flags (PRE_first_tail_x6_r0_body.cwS16.filterMap fun i => (PRE_first_tail_x6_r0_body.kr1_16.flags.get i).map (i, ·))
kernel_rfl PRE_first_tail_x6_r0_body.fkt116 : PRE_first_tail_x6_r0_body.kr1_16.targs = Stage.setAll PRE_first_tail_x6_r0_body.krC_16.targs (PRE_first_tail_x6_r0_body.cwS16.filterMap fun i => (PRE_first_tail_x6_r0_body.kr1_16.targs.get i).map (i, ·))
kernel_rfl PRE_first_tail_x6_r0_body.fkck16 : krecLB PRE_first_tail_x6_r0_body.kappa16 764 PRE_first_tail_x6_r0_body.cx0_16.mlx PRE_first_tail_x6_r0_body.kr0_16 PRE_first_tail_x6_r0_body.kr1_16 PRE_first_tail_x6_r0_body.clo16 = true
kernel_rfl PRE_first_tail_x6_r0_body.fkn16 : Nat.ble 764 764 = true
-- the bridge and the pending traces' regions
kernel_rfl PRE_first_tail_x6_r0_body.cbridge16 : Host.Ts.Sim.Full.bridgeOf PRE_first_tail_x6_r0_body.s169.ffi = Host.Ts.Sim.Full.bridgeOf PRE_first_tail_x6_r0_body.s170.ffi
kernel_rfl PRE_first_tail_x6_r0_body.cpendR16 : pendRegB PRE_first_tail_x6_r0_body.kappa16 (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.s170.ffi).mlx = true
kernel_rfl PRE_first_tail_x6_r0_body.cpendLe16 : Nat.ble (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.s170.ffi).mlx.next (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.s169.ffi).mlx.next = true
/-- **The compaction's native shift**, given the call's bookkeeping, its relation's facts (the model's and the
observers') and the canonical closedness. -/
theorem PRE_first_tail_x6_r0_body.cshift16 (clean : Conv.NClean (⟨18525, 15618, 2687627, 764⟩ : Conv.Cnt) (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.s168.ffi).mlx) (hltC : ∀ h, PH (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.s168.ffi).mlx h → h < (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.s168.ffi).mlx.next) (nltC : ∀ i, PN (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.s168.ffi).mlx i → i < (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.s168.ffi).mlx.nnext) (itemsC : ∀ k v, (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.s168.ffi).mlx.items.get k = some v → PN (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.s168.ffi).mlx k) (tracedC : ∀ h o, (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.s168.ffi).mlx.objs.get h = some o → ∀ i ∈ objTraces o, i < PRE_first_tail_x6_r0_body.P16.NL) (cl : SSt (· < 764) PRE_first_tail_x6_r0_body.cx0_16.mlx)
    (hobjC : ∀ h, PRE_first_tail_x6_r0_body.fxC_16.get h = some () → ((Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.s168.ffi).mlx.objs.get h).isSome = true)
    (hfC : ∀ h, (PRE_first_tail_x6_r0_body.krC_16.flags.get h).isSome = true → ((Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.s168.ffi).mlx.objs.get h).isSome = true)
    (htC : ∀ h, (PRE_first_tail_x6_r0_body.krC_16.targs.get h).isSome = true → ((Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.s168.ffi).mlx.objs.get h).isSome = true)
    (hclC : ∀ h l, PRE_first_tail_x6_r0_body.krC_16.targs.get h = some l → Host.Ts.Sim.Full.STargs (· < (⟨18525, 15618, 2687627, 764⟩ : Conv.Cnt).n) l) :
    Conv.FullShiftQ PRE_first_tail_x6_r0_body.P16 764 PRE_first_tail_x6_r0_body.kappa16 PRE_first_tail_x6_r0_body.s170.ffi PRE_first_tail_x6_r0_body.s169.ffi :=
  ⟨PRE_first_tail_x6_r0_body.cnshift16 clean hltC nltC itemsC tracedC cl, PRE_first_tail_x6_r0_body.cqueue16, fun t ht => bSN_sound (List.all_eq_true.mp PRE_first_tail_x6_r0_body.ctokSupp16 t ht),
    PRE_first_tail_x6_r0_body.cbridge16,
    liveShift_foot (x0' := Host.Ts.Sim.Full.mlxOf PRE_first_tail_x6_r0_body.s170.ffi) (x1' := Host.Ts.Sim.Full.mlxOf PRE_first_tail_x6_r0_body.s169.ffi) (PRE_first_tail_x6_r0_body.cfoot16 clean hltC nltC itemsC tracedC cl) rfl PRE_first_tail_x6_r0_body.ofx0_16 PRE_first_tail_x6_r0_body.ofx1_16 hobjC PRE_first_tail_x6_r0_body.ff016 PRE_first_tail_x6_r0_body.ff116 PRE_first_tail_x6_r0_body.ffck16,
    kernShift_foot (x0' := Host.Ts.Sim.Full.mlxOf PRE_first_tail_x6_r0_body.s170.ffi) (x1' := Host.Ts.Sim.Full.mlxOf PRE_first_tail_x6_r0_body.s169.ffi) (PRE_first_tail_x6_r0_body.cfoot16 clean hltC nltC itemsC tracedC cl) rfl PRE_first_tail_x6_r0_body.okr0_16 PRE_first_tail_x6_r0_body.okr1_16 (Nat.le_of_ble_eq_true PRE_first_tail_x6_r0_body.fkn16) hfC htC hclC
      PRE_first_tail_x6_r0_body.fkf016 PRE_first_tail_x6_r0_body.fkt016 PRE_first_tail_x6_r0_body.fkf116 PRE_first_tail_x6_r0_body.fkt116 PRE_first_tail_x6_r0_body.fkck16,
    pendReg_of rfl PRE_first_tail_x6_r0_body.cnh016 PRE_first_tail_x6_r0_body.cnh116 (Nat.le_of_ble_eq_true PRE_first_tail_x6_r0_body.cpendLe16) PRE_first_tail_x6_r0_body.cpendR16⟩

end Host.Load.Run.Tpl
end

section -- st16/H0
set_option Elab.async false
namespace Host.Load.Run.Tpl
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
host_stream_state PRE_first_tail_x6_r0_body.st16 0
host_stream_state PRE_first_tail_x6_r0_body.st16 1
host_stream_state PRE_first_tail_x6_r0_body.st16 2
end Host.Load.Run.Tpl
end

section -- Site16
set_option Elab.async false
namespace Host.Load.Run.Tpl
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
open Host.Ts Host.Ts.Sim Host.Ts.Sim.Template

/-! Call site 16 of chain `PRE_first_tail_x6_r0_body`: `rowBlocks__g16__g17` (`rowBlocks`), the call state `PRE_first_tail_x6_r0_body.s168`, the merged state `PRE_first_tail_x6_r0_body.s169`,
the site template `PRE_first_tail_x6_r0_body.st16` (σ = `Map.id`, θ the identity at its own site), the canonical state `PRE_first_tail_x6_r0_body.s170`: the merge.
The footprint's facts are in `SiteF16`, the compaction's in `SiteC16`, `SiteK16`, `SiteNa16`, `SiteNb16`. -/

kernel_rfl PRE_first_tail_x6_r0_body.iso16 : PRE_first_tail_x6_r0_body.st16.s0 = { PRE_first_tail_x6_r0_body.s168 with stack := [] }
/-- The caller's frames at the call. -/
noncomputable def PRE_first_tail_x6_r0_body.rs16 : List Frame := PRE_first_tail_x6_r0_body.s168.stack
kernel_rfl PRE_first_tail_x6_r0_body.n0_16 : PRE_first_tail_x6_r0_body.S168.tab.length = 764
kernel_rfl PRE_first_tail_x6_r0_body.tab0_16 : PRE_first_tail_x6_r0_body.st16.S0.tab = PRE_first_tail_x6_r0_body.S168.tab

/-- The fresh variables of the stage's results. -/
def PRE_first_tail_x6_r0_body.ws16 : List Nat := [1302, 1303]
kernel_rfl PRE_first_tail_x6_r0_body.fresh16 : (PRE_first_tail_x6_r0_body.S168.tab.all fun e => PRE_first_tail_x6_r0_body.ws16.all fun v => e.noVar v) &&
    (PRE_first_tail_x6_r0_body.S168.oracle.all fun q => PRE_first_tail_x6_r0_body.ws16.all fun v => q.noVar v) = true
kernel_rfl PRE_first_tail_x6_r0_body.mergeTab16 : PRE_first_tail_x6_r0_body.S169.tab = PRE_first_tail_x6_r0_body.S168.tab ++ Conv.resTab PRE_first_tail_x6_r0_body.ws16
kernel_rfl PRE_first_tail_x6_r0_body.mergeLen16 : PRE_first_tail_x6_r0_body.st16.S2.tab.length - PRE_first_tail_x6_r0_body.st16.S0.tab.length = 2

-- The merged state: the instance's return state with the caller's frames (`PRE_first_tail_x6_r0_body.merged16`, `merged_relB`).
kernel_rfl PRE_first_tail_x6_r0_body.mheap16 : PRE_first_tail_x6_r0_body.s169.heap = PRE_first_tail_x6_r0_body.st16.s2.heap
kernel_rfl PRE_first_tail_x6_r0_body.mnext16 : PRE_first_tail_x6_r0_body.s169.next = PRE_first_tail_x6_r0_body.st16.s2.next
kernel_rfl PRE_first_tail_x6_r0_body.mctl16 : PRE_first_tail_x6_r0_body.s169.ctl = PRE_first_tail_x6_r0_body.st16.s2.ctl
kernel_rfl PRE_first_tail_x6_r0_body.mstack16 : PRE_first_tail_x6_r0_body.s169.stack = PRE_first_tail_x6_r0_body.st16.s2.stack ++ PRE_first_tail_x6_r0_body.s168.stack
kernel_rfl PRE_first_tail_x6_r0_body.mjobs16 : PRE_first_tail_x6_r0_body.s169.jobs = PRE_first_tail_x6_r0_body.st16.s2.jobs
kernel_rfl PRE_first_tail_x6_r0_body.mffi16 : PRE_first_tail_x6_r0_body.s169.ffi = PRE_first_tail_x6_r0_body.st16.s2.ffi
kernel_rfl PRE_first_tail_x6_r0_body.mtrace16 : PRE_first_tail_x6_r0_body.s169.trace = PRE_first_tail_x6_r0_body.st16.s2.trace
kernel_rfl PRE_first_tail_x6_r0_body.mstores16 : PRE_first_tail_x6_r0_body.s169.stores = PRE_first_tail_x6_r0_body.st16.s2.stores

end Host.Load.Run.Tpl
end

section -- SiteD16
set_option Elab.async false
namespace Host.Load.Run.Tpl
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
open Host.Ts Host.Ts.Sim Host.Ts.Sim.Template

/-! The canonical results at call site 16 of chain `PRE_first_tail_x6_r0_body`: their values in the instance's end table, the references past
the call's table, the canonical variables apart from the stage's. -/

kernel_rfl PRE_first_tail_x6_r0_body.cderived16 : PRE_first_tail_x6_r0_body.nr16.map (fun r => nth? PRE_first_tail_x6_r0_body.st16.S2.tab r) =
  []
kernel_rfl PRE_first_tail_x6_r0_body.cnrLo16 : PRE_first_tail_x6_r0_body.nr16.all (Nat.ble 764) = true
kernel_rfl PRE_first_tail_x6_r0_body.cwsDisj16 : PRE_first_tail_x6_r0_body.cws16.all (fun c => !PRE_first_tail_x6_r0_body.ws16.contains c) = true
/-- The compaction's substitution: the canonical variables to their merged values, the stage's other fresh variables
to `0` (`Conv.compactθZ`). -/
noncomputable def PRE_first_tail_x6_r0_body.cthetaZ16 : Nat → SymE := Conv.compactθZ PRE_first_tail_x6_r0_body.cws16 PRE_first_tail_x6_r0_body.crs16 PRE_first_tail_x6_r0_body.ws16

end Host.Load.Run.Tpl
end

section -- st16/Foot
set_option Elab.async false
namespace Host.Load.Run.Tpl
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
open Host.Ts Host.Ts.Sim Host.Ts.Sim.Stage Host.Ts.Sim.Template

/-! The footprint of stage `PRE_first_tail_x6_r0_body.st16`'s site template (`Conv.StageFoot`, `Conv.NFoot`): every entry of the return
state other than the written and fresh ones is the start's (kernel evaluation of the equalities). -/

/-- The written heap ranges below the start's counter. -/
def PRE_first_tail_x6_r0_body.st16.wrR : List (Nat × Nat) := []
/-- The written and fresh entries of the return state. -/
noncomputable def PRE_first_tail_x6_r0_body.st16.wrE : List (Nat × Host.Ts.HObj) :=
  rangesOf PRE_first_tail_x6_r0_body.st16.s2.heap PRE_first_tail_x6_r0_body.st16.wrR ++ freshOf PRE_first_tail_x6_r0_body.st16.s2.heap PRE_first_tail_x6_r0_body.st16.s0.next PRE_first_tail_x6_r0_body.st16.s2.next
noncomputable def PRE_first_tail_x6_r0_body.st16.wr : List Nat := PRE_first_tail_x6_r0_body.st16.wrE.map (·.1)

kernel_rfl PRE_first_tail_x6_r0_body.st16.heapFoot : PRE_first_tail_x6_r0_body.st16.s2.heap = setAll PRE_first_tail_x6_r0_body.st16.s0.heap PRE_first_tail_x6_r0_body.st16.wrE
kernel_rfl PRE_first_tail_x6_r0_body.st16.grows_check : Nat.ble PRE_first_tail_x6_r0_body.st16.s0.next PRE_first_tail_x6_r0_body.st16.s2.next = true
theorem PRE_first_tail_x6_r0_body.st16.grows : PRE_first_tail_x6_r0_body.st16.s0.next ≤ PRE_first_tail_x6_r0_body.st16.s2.next := Nat.le_of_ble_eq_true PRE_first_tail_x6_r0_body.st16.grows_check

/-- The written and fresh handles; the written readback items of old nodes. -/
def PRE_first_tail_x6_r0_body.st16.wh : List Nat := []
def PRE_first_tail_x6_r0_body.st16.wi : List Nat := []

kernel_rfl PRE_first_tail_x6_r0_body.st16.arrsFoot : (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.st16.s2.ffi).mlx.arrs = setAll (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.st16.s0.ffi).mlx.arrs (PRE_first_tail_x6_r0_body.st16.wh.filterMap fun h => ((Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.st16.s2.ffi).mlx.arrs.get h).map (h, ·))
kernel_rfl PRE_first_tail_x6_r0_body.st16.objsFoot : (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.st16.s2.ffi).mlx.objs = setAll (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.st16.s0.ffi).mlx.objs (PRE_first_tail_x6_r0_body.st16.wh.filterMap fun h => ((Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.st16.s2.ffi).mlx.objs.get h).map (h, ·))
kernel_rfl PRE_first_tail_x6_r0_body.st16.nodesFoot : (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.st16.s2.ffi).mlx.nodes = setAll (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.st16.s0.ffi).mlx.nodes (freshOf (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.st16.s2.ffi).mlx.nodes (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.st16.s0.ffi).mlx.nnext (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.st16.s2.ffi).mlx.nnext)
kernel_rfl PRE_first_tail_x6_r0_body.st16.itemsFoot : (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.st16.s2.ffi).mlx.items = setAll (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.st16.s0.ffi).mlx.items ((PRE_first_tail_x6_r0_body.st16.wi.filterMap fun i => ((Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.st16.s2.ffi).mlx.items.get i).map (i, ·)) ++
    freshOf (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.st16.s2.ffi).mlx.items (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.st16.s0.ffi).mlx.nnext (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.st16.s2.ffi).mlx.nnext)
kernel_rfl PRE_first_tail_x6_r0_body.st16.counters : (Nat.ble (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.st16.s0.ffi).mlx.next (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.st16.s2.ffi).mlx.next && Nat.ble (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.st16.s0.ffi).mlx.nnext (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.st16.s2.ffi).mlx.nnext) = true

end Host.Load.Run.Tpl
end

section -- SiteF16
set_option Elab.async false
namespace Host.Load.Run.Tpl
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
open Host.Ts Host.Ts.Sim Host.Ts.Sim.Template

/-! Call site 16 of chain `PRE_first_tail_x6_r0_body`: `Conv.site_merge`'s footprint facts. -/

kernel_rfl PRE_first_tail_x6_r0_body.wrNodupB16 : nodupT PRE_first_tail_x6_r0_body.st16.wr PTrie.nil = true
theorem PRE_first_tail_x6_r0_body.wrNodup16 : PRE_first_tail_x6_r0_body.st16.wr.Nodup := (nodupT_sound PRE_first_tail_x6_r0_body.wrNodupB16).2
kernel_rfl PRE_first_tail_x6_r0_body.wrBoundB16 : PRE_first_tail_x6_r0_body.st16.wr.all (fun b => Nat.blt (b / 4096) (4 ^ 31)) = true
theorem PRE_first_tail_x6_r0_body.wrBound16 : ∀ b ∈ PRE_first_tail_x6_r0_body.st16.wr, b / 4096 < 4 ^ 31 := fun b hb => Nat.blt_eq.mp (List.all_eq_true.mp PRE_first_tail_x6_r0_body.wrBoundB16 b hb)
noncomputable def PRE_first_tail_x6_r0_body.trFr16 := PRE_first_tail_x6_r0_body.st16.s2.trace.take 0
kernel_rfl PRE_first_tail_x6_r0_body.traceEq16 : PRE_first_tail_x6_r0_body.st16.s2.trace = PRE_first_tail_x6_r0_body.trFr16 ++ PRE_first_tail_x6_r0_body.st16.s0.trace
theorem PRE_first_tail_x6_r0_body.trace16 : ∃ fr, PRE_first_tail_x6_r0_body.st16.s2.trace = fr ++ PRE_first_tail_x6_r0_body.st16.s0.trace := ⟨_, PRE_first_tail_x6_r0_body.traceEq16⟩

-- the caller's wide frames at the instance's start (`Conv.isolateW`'s `W0` under `Map.id`) and their `WFix`
def PRE_first_tail_x6_r0_body.wide16 : List (Nat × WFrame) := [(4910, .memo [])]
kernel_rfl PRE_first_tail_x6_r0_body.wfixB16 : (PRE_first_tail_x6_r0_body.wide16.all fun p => wfixB Map.id (presentB PRE_first_tail_x6_r0_body.st16.s0) p.2) = true
theorem PRE_first_tail_x6_r0_body.wfix16 : ∀ p ∈ PRE_first_tail_x6_r0_body.wide16, WFix Map.id (Present PRE_first_tail_x6_r0_body.st16.s0) p.2 :=
  fun p hp => wfix_of (List.all_eq_true.mp PRE_first_tail_x6_r0_body.wfixB16 p hp)

end Host.Load.Run.Tpl
end

section -- SiteL16
set_option Elab.async false
namespace Host.Load.Run.Tpl
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
open Host.Ts Host.Ts.Sim Host.Ts.Sim.Template

/-! The call link's facts at call site 16 of chain `PRE_first_tail_x6_r0_body`: the instance's start server, its footprint (`Conv.StageFoot`), the
merged state `PRE_first_tail_x6_r0_body.s169`'s framed arrays as the chain start's extended (`arrExt_of`, `numRefs_of`). -/

kernel_rfl PRE_first_tail_x6_r0_body.srvO16 : PRE_first_tail_x6_r0_body.st16.S0.oracle = PRE_first_tail_x6_r0_body.st16.OR
kernel_rfl PRE_first_tail_x6_r0_body.wr0B16 : PRE_first_tail_x6_r0_body.st16.wr.all (fun b => !Nat.blt b PRE_first_tail_x6_r0_body.st16.s0.next || (PRE_first_tail_x6_r0_body.st16.s0.heap.get b).isSome) = true
theorem PRE_first_tail_x6_r0_body.stFoot16 : Conv.StageFoot PRE_first_tail_x6_r0_body.st16.wr PRE_first_tail_x6_r0_body.st16.s0 PRE_first_tail_x6_r0_body.st16.s2 :=
  stageFoot_of PRE_first_tail_x6_r0_body.st16.heapFoot PRE_first_tail_x6_r0_body.wrNodup16 PRE_first_tail_x6_r0_body.wrBound16 PRE_first_tail_x6_r0_body.wr0B16 PRE_first_tail_x6_r0_body.st16.grows

/-- **The relation at the merged state** from the relation at the merge (`Conv.site_merge`'s; `merged_relB`). -/
theorem PRE_first_tail_x6_r0_body.merged16 {FR : Map → Nat → PRE_first_tail_x6_r0_body.st16.F.S → PRE_first_tail_x6_r0_body.st16.F.S → Prop} {W : Nat → Option WFrame} {stk : List Frame} {M : Map}
    {ν : Nat → F64} {K : Host.Ts.Sim.Ctx} {S : SSrv} {t : St PRE_first_tail_x6_r0_body.st16.F.S} {C : CSrv} {n0 : Nat}
    (h : RelB PRE_first_tail_x6_r0_body.st16.F FR W stk M ν K (Conv.mergeSt Map.id (Map.id.res n0 n0) PRE_first_tail_x6_r0_body.rs16 PRE_first_tail_x6_r0_body.st16.wr PRE_first_tail_x6_r0_body.s168 PRE_first_tail_x6_r0_body.st16.s2 PRE_first_tail_x6_r0_body.st16.s0
      PRE_first_tail_x6_r0_body.st16.s2.ffi) S t C) : RelB PRE_first_tail_x6_r0_body.st16.F FR W stk M ν K PRE_first_tail_x6_r0_body.s169 S t C :=
  merged_relB PRE_first_tail_x6_r0_body.iso16 PRE_first_tail_x6_r0_body.stFoot16 PRE_first_tail_x6_r0_body.wrNodup16 PRE_first_tail_x6_r0_body.wrBound16 PRE_first_tail_x6_r0_body.trace16 PRE_first_tail_x6_r0_body.mheap16
    PRE_first_tail_x6_r0_body.mnext16 PRE_first_tail_x6_r0_body.mctl16 PRE_first_tail_x6_r0_body.mstack16 PRE_first_tail_x6_r0_body.mjobs16 PRE_first_tail_x6_r0_body.mffi16 PRE_first_tail_x6_r0_body.mtrace16 PRE_first_tail_x6_r0_body.mstores16 h

def PRE_first_tail_x6_r0_body.arrEl16_2665 : List Val := []
kernel_rfl PRE_first_tail_x6_r0_body.arrE16_2665 : arrOf PRE_first_tail_x6_r0_body.s169 2665 = arrOf PRE_first_tail_x6_r0_body.s0 2665 ++ PRE_first_tail_x6_r0_body.arrEl16_2665
kernel_rfl PRE_first_tail_x6_r0_body.arrA16_2665 : isArrB PRE_first_tail_x6_r0_body.s169 2665 = true
theorem PRE_first_tail_x6_r0_body.arr16_2665 : ∃ o, PRE_first_tail_x6_r0_body.s169.heap.get 2665 = some (.obj o) ∧ o.kind = .array (arrOf PRE_first_tail_x6_r0_body.s0 2665 ++ PRE_first_tail_x6_r0_body.arrEl16_2665) :=
  arrExt_of PRE_first_tail_x6_r0_body.arrE16_2665 PRE_first_tail_x6_r0_body.arrA16_2665
kernel_rfl PRE_first_tail_x6_r0_body.arrN16_2665 : numRefsB PRE_first_tail_x6_r0_body.S0.tab.length PRE_first_tail_x6_r0_body.arrEl16_2665 = true
theorem PRE_first_tail_x6_r0_body.arrR16_2665 : Prefill.NumRefs PRE_first_tail_x6_r0_body.S0.tab.length PRE_first_tail_x6_r0_body.arrEl16_2665 := numRefs_of PRE_first_tail_x6_r0_body.arrN16_2665

def PRE_first_tail_x6_r0_body.arrEl16_2673467 : List Val := []
kernel_rfl PRE_first_tail_x6_r0_body.arrE16_2673467 : arrOf PRE_first_tail_x6_r0_body.s169 2673467 = arrOf PRE_first_tail_x6_r0_body.s0 2673467 ++ PRE_first_tail_x6_r0_body.arrEl16_2673467
kernel_rfl PRE_first_tail_x6_r0_body.arrA16_2673467 : isArrB PRE_first_tail_x6_r0_body.s169 2673467 = true
theorem PRE_first_tail_x6_r0_body.arr16_2673467 : ∃ o, PRE_first_tail_x6_r0_body.s169.heap.get 2673467 = some (.obj o) ∧ o.kind = .array (arrOf PRE_first_tail_x6_r0_body.s0 2673467 ++ PRE_first_tail_x6_r0_body.arrEl16_2673467) :=
  arrExt_of PRE_first_tail_x6_r0_body.arrE16_2673467 PRE_first_tail_x6_r0_body.arrA16_2673467
kernel_rfl PRE_first_tail_x6_r0_body.arrN16_2673467 : numRefsB PRE_first_tail_x6_r0_body.S0.tab.length PRE_first_tail_x6_r0_body.arrEl16_2673467 = true
theorem PRE_first_tail_x6_r0_body.arrR16_2673467 : Prefill.NumRefs PRE_first_tail_x6_r0_body.S0.tab.length PRE_first_tail_x6_r0_body.arrEl16_2673467 := numRefs_of PRE_first_tail_x6_r0_body.arrN16_2673467

kernel_rfl PRE_first_tail_x6_r0_body.w4910k16 : isArrB PRE_first_tail_x6_r0_body.s169 4910 = false
theorem PRE_first_tail_x6_r0_body.keep16 (q : List Val) : Host.Ts.Sim.Prefill.KeepsAtW (framesP PRE_first_tail_x6_r0_body.s0 q) PRE_first_tail_x6_r0_body.s169 := by
  intro a pre pre' hx o es ho hk
  unfold framesP at hx
  simp only at hx
  cases h1 : Nat.beq a 2665
  · cases h2 : Nat.beq a 4910
    · rw [h1, h2] at hx; cases hx
    · have := Nat.eq_of_beq_eq_true h2; subst this
      rw [h1, h2] at hx; cases hx
      exact (notArr_of PRE_first_tail_x6_r0_body.w4910k16 ho hk).elim
  · have := Nat.eq_of_beq_eq_true h1; subst this
    rw [h1] at hx; cases hx
    obtain ⟨o', ho', hk'⟩ := PRE_first_tail_x6_r0_body.arr16_2665
    rw [ho] at ho'; cases ho'
    rw [hk'] at hk; cases hk
    simp [PRE_first_tail_x6_r0_body.arrEl16_2665]

end Host.Load.Run.Tpl
end

section -- SiteZ16
set_option Elab.async false
namespace Host.Load.Run.Tpl
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
open Host.Ts Host.Ts.Sim Host.Ts.Sim.Template

/-! The compaction's state shift at call site 16 of chain `PRE_first_tail_x6_r0_body` (`Conv.compact_shift`): the call `PRE_first_tail_x6_r0_body.s168`, the merged
state `PRE_first_tail_x6_r0_body.s169`, the canonical state `PRE_first_tail_x6_r0_body.s170`; its frames [2665,2673467,2673472,2673473] (kept arrays [2665,2673467]). -/

-- the map's places and counters
kernel_rfl PRE_first_tail_x6_r0_body.zpl16 : PRE_first_tail_x6_r0_body.pl16.all (Nat.ble PRE_first_tail_x6_r0_body.s168.next) = true
kernel_rfl PRE_first_tail_x6_r0_body.zplnd16 : nodupT PRE_first_tail_x6_r0_body.pl16 PTrie.nil = true
kernel_rfl PRE_first_tail_x6_r0_body.zn116 : Nat.ble PRE_first_tail_x6_r0_body.s168.next 2687629 = true
kernel_rfl PRE_first_tail_x6_r0_body.zfirst16 : Nat.ble aFirst PRE_first_tail_x6_r0_body.s168.next = true
kernel_rfl PRE_first_tail_x6_r0_body.zscn16 : PRE_first_tail_x6_r0_body.s170.next = PRE_first_tail_x6_r0_body.s168.next + PRE_first_tail_x6_r0_body.pl16.length
kernel_rfl PRE_first_tail_x6_r0_body.zsmn16 : PRE_first_tail_x6_r0_body.s169.next = 2687629
kernel_rfl PRE_first_tail_x6_r0_body.zgrow16 : Nat.ble PRE_first_tail_x6_r0_body.s170.next PRE_first_tail_x6_r0_body.s169.next = true
-- the tables
kernel_rfl PRE_first_tail_x6_r0_body.zfresh16 : PRE_first_tail_x6_r0_body.S168.tab.all (fun e => PRE_first_tail_x6_r0_body.cws16.all fun v => e.noVar v) = true
kernel_rfl PRE_first_tail_x6_r0_body.zcnd16 : nodupT PRE_first_tail_x6_r0_body.cws16 PTrie.nil = true
kernel_rfl PRE_first_tail_x6_r0_body.znrHi16 : PRE_first_tail_x6_r0_body.nr16.all (fun r => Nat.blt r PRE_first_tail_x6_r0_body.S169.tab.length) = true
-- the frames: every framed address below the call's counter; the kept arrays the chain start's, extended in the merged state
kernel_rfl PRE_first_tail_x6_r0_body.zfrlt16 : [2665, 2673467, 2673472, 2673473].all (fun a => Nat.blt a PRE_first_tail_x6_r0_body.s168.next) = true
kernel_rfl PRE_first_tail_x6_r0_body.zg16_2665 : PRE_first_tail_x6_r0_body.s170.heap.get 2665 = some (.obj (objOf PRE_first_tail_x6_r0_body.s170 2665))
kernel_rfl PRE_first_tail_x6_r0_body.zk16_2665 : (objOf PRE_first_tail_x6_r0_body.s170 2665).kind = .array (arrOf PRE_first_tail_x6_r0_body.s0 2665)
kernel_rfl PRE_first_tail_x6_r0_body.zm16_2665 : PRE_first_tail_x6_r0_body.s169.heap.get 2665 = some (.obj { PRE_first_tail_x6_r0_body.kappa16.obj (objOf PRE_first_tail_x6_r0_body.s170 2665) with
  kind := .array (arrOf PRE_first_tail_x6_r0_body.s0 2665 ++ (arrOf PRE_first_tail_x6_r0_body.s169 2665).drop (arrOf PRE_first_tail_x6_r0_body.s0 2665).length) })
kernel_rfl PRE_first_tail_x6_r0_body.zg16_2673467 : PRE_first_tail_x6_r0_body.s170.heap.get 2673467 = some (.obj (objOf PRE_first_tail_x6_r0_body.s170 2673467))
kernel_rfl PRE_first_tail_x6_r0_body.zk16_2673467 : (objOf PRE_first_tail_x6_r0_body.s170 2673467).kind = .array (arrOf PRE_first_tail_x6_r0_body.s0 2673467)
kernel_rfl PRE_first_tail_x6_r0_body.zm16_2673467 : PRE_first_tail_x6_r0_body.s169.heap.get 2673467 = some (.obj { PRE_first_tail_x6_r0_body.kappa16.obj (objOf PRE_first_tail_x6_r0_body.s170 2673467) with
  kind := .array (arrOf PRE_first_tail_x6_r0_body.s0 2673467 ++ (arrOf PRE_first_tail_x6_r0_body.s169 2673467).drop (arrOf PRE_first_tail_x6_r0_body.s0 2673467).length) })
kernel_rfl PRE_first_tail_x6_r0_body.zw16_4910 : (PRE_first_tail_x6_r0_body.s170.heap.get 4910).isSome = true
kernel_rfl PRE_first_tail_x6_r0_body.zw16_2673472 : (PRE_first_tail_x6_r0_body.s170.heap.get 2673472).isSome = true
kernel_rfl PRE_first_tail_x6_r0_body.zw16_2673473 : (PRE_first_tail_x6_r0_body.s170.heap.get 2673473).isSome = true
-- the heap: the changed list in range, holding the stage's written and fresh addresses; the canonical side's image
kernel_rfl PRE_first_tail_x6_r0_body.zclbd16 : PRE_first_tail_x6_r0_body.cl16.all (fun b => Nat.blt (b / 4096) (4 ^ 31)) = true
kernel_rfl PRE_first_tail_x6_r0_body.zwr16 : PRE_first_tail_x6_r0_body.st16.wr.all (fun b => !Nat.blt b PRE_first_tail_x6_r0_body.s168.next || PRE_first_tail_x6_r0_body.cl16.contains b) = true
def PRE_first_tail_x6_r0_body.zl16 : List Nat := PRE_first_tail_x6_r0_body.cl16.filter fun a => !(List.contains [2665, 2673467] a)
kernel_rfl PRE_first_tail_x6_r0_body.zimgE16 : PRE_first_tail_x6_r0_body.zl16.map (fun a => PRE_first_tail_x6_r0_body.s169.heap.get (PRE_first_tail_x6_r0_body.kappa16.a a)) = PRE_first_tail_x6_r0_body.zl16.map (fun a => (PRE_first_tail_x6_r0_body.s170.heap.get a).map PRE_first_tail_x6_r0_body.kappa16.hobj)
theorem PRE_first_tail_x6_r0_body.zimg16 : HeapImg PRE_first_tail_x6_r0_body.kappa16 PRE_first_tail_x6_r0_body.s170 PRE_first_tail_x6_r0_body.s169 PRE_first_tail_x6_r0_body.zl16 := PRE_first_tail_x6_r0_body.zimgE16
-- the roots and their supports
kernel_rfl PRE_first_tail_x6_r0_body.zctl16 : PRE_first_tail_x6_r0_body.s169.ctl = PRE_first_tail_x6_r0_body.kappa16.ctl PRE_first_tail_x6_r0_body.s170.ctl
kernel_rfl PRE_first_tail_x6_r0_body.zstack16 : PRE_first_tail_x6_r0_body.s169.stack = PRE_first_tail_x6_r0_body.s170.stack.map PRE_first_tail_x6_r0_body.kappa16.frame
kernel_rfl PRE_first_tail_x6_r0_body.zjobs16 : PRE_first_tail_x6_r0_body.s169.jobs = PRE_first_tail_x6_r0_body.s170.jobs.map PRE_first_tail_x6_r0_body.kappa16.job
kernel_rfl PRE_first_tail_x6_r0_body.zstores16 : PRE_first_tail_x6_r0_body.s169.stores = PRE_first_tail_x6_r0_body.kappa16.stores PRE_first_tail_x6_r0_body.s170.stores
kernel_rfl PRE_first_tail_x6_r0_body.zroots16 : checkRootsSupp PRE_first_tail_x6_r0_body.s170 764 = true
kernel_rfl PRE_first_tail_x6_r0_body.znC16 : PRE_first_tail_x6_r0_body.S168.tab.length + PRE_first_tail_x6_r0_body.cws16.length = 764
-- the map as `Conv.compact_shift` states it (the call's counters for the literals)
kernel_rfl PRE_first_tail_x6_r0_body.zkap16 : PRE_first_tail_x6_r0_body.kappa16 = Conv.Map.compact PRE_first_tail_x6_r0_body.s168.next 2687629 PRE_first_tail_x6_r0_body.S168.tab.length PRE_first_tail_x6_r0_body.pl16 (PRE_first_tail_x6_r0_body.nr16.map NumV.ref) PRE_first_tail_x6_r0_body.kd16.big
  PRE_first_tail_x6_r0_body.kd16.region PRE_first_tail_x6_r0_body.kd16.nodeF
-- the bridge inactive at the canonical state (`Conv.FullShiftQ.toX`; the merged state's bridge is the canonical's: cbridge)
theorem PRE_first_tail_x6_r0_body.zbin16 : (Host.Ts.Sim.Full.bridgeOf PRE_first_tail_x6_r0_body.s170.ffi).active = false := (Host.Load.Boot.replay_active Host.Load.Run.Prompt.P.oblog2818)
-- the JS bookkeeping's step (`Conv.JClean.step` over the changed list) and the canonical roots' bigint freedom
kernel_rfl PRE_first_tail_x6_r0_body.zjc16 : Conv.jcleanListB (⟨18525, 15618, 2687627, 764⟩ : Conv.Cnt) PRE_first_tail_x6_r0_body.s170 PRE_first_tail_x6_r0_body.cl16 = true
kernel_rfl PRE_first_tail_x6_r0_body.zrootsB16 : noBigRootsP (fun i => !Conv.oldBigB (⟨18525, 15618, 2687627, 764⟩ : Conv.Cnt) i) PRE_first_tail_x6_r0_body.s170.trace PRE_first_tail_x6_r0_body.s170 = true
kernel_rfl PRE_first_tail_x6_r0_body.zhm16 : Nat.ble (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.s0.ffi).mlx.nnext 15618 = true
theorem PRE_first_tail_x6_r0_body.cjcl16 (h : Conv.JClean (⟨18525, 15618, 2687627, 764⟩ : Conv.Cnt) PRE_first_tail_x6_r0_body.s168) : Conv.JClean (⟨18525, 15618, 2687627, 764⟩ : Conv.Cnt) PRE_first_tail_x6_r0_body.s170 :=
  Conv.JClean.step h (Conv.Cnt.le_of_leB PRE_first_tail_x6_r0_body.cle16)
    (Conv.heap_off_setAll PRE_first_tail_x6_r0_body.cheap16 fun a ha => Nat.blt_eq.mp (List.all_eq_true.mp PRE_first_tail_x6_r0_body.zclbd16 a ha)) PRE_first_tail_x6_r0_body.zjc16

end Host.Load.Run.Tpl
end

section -- st16/TypedLast
set_option Elab.async false
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
namespace Host.Load.Run.Tpl
open Host.Ts Host.Ts.Sim Host.Ts.Sim.Template

boot_rfl PRE_first_tail_x6_r0_body.st16.bodyLast from PRE_first_tail_x6_r0_body.st16.s1 to PRE_first_tail_x6_r0_body.st16.s2 :
  interpS (step PRE_first_tail_x6_r0_body.st16.F PRE_first_tail_x6_r0_body.st16.s1).run PRE_first_tail_x6_r0_body.st16.S1 = some (PRE_first_tail_x6_r0_body.st16.s2, PRE_first_tail_x6_r0_body.st16.S2)
kernel_rfl PRE_first_tail_x6_r0_body.st16.bodyHalt : isHalt PRE_first_tail_x6_r0_body.st16.s1.ctl = false
kernel_rfl PRE_first_tail_x6_r0_body.st16.bodyTopCheck : noBlockTop PRE_first_tail_x6_r0_body.st16.s2.stack = true

end Host.Load.Run.Tpl
end

section -- st16/TypedOk
set_option Elab.async false
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
namespace Host.Load.Run.Tpl
open Host.Ts Host.Ts.Sim Host.Ts.Sim.Template

noncomputable def PRE_first_tail_x6_r0_body.st16.bodyOkL (bytes : List Byte) (rows : Nat) : St PRE_first_tail_x6_r0_body.st16.F.S → SSrv → Bool :=
  okLocal (Host.Ts.Sim.Compose.VWFrames.bodyOk bytes rows)

noncomputable def PRE_first_tail_x6_r0_body.st16.bodyOkLN (bytes : List Byte) (rows : Nat) : St PRE_first_tail_x6_r0_body.st16.F.S → FSrv → Bool :=
  okLocalN (Host.Ts.Sim.Compose.VWFrames.bodyOkN bytes rows)

theorem PRE_first_tail_x6_r0_body.st16.bodyOkLN_ok (bytes : List Byte) (rows : Nat) (s : St PRE_first_tail_x6_r0_body.st16.F.S) (c : FSrv) (h : c.Wf) :
    PRE_first_tail_x6_r0_body.st16.bodyOkLN bytes rows s c = PRE_first_tail_x6_r0_body.st16.bodyOkL bytes rows s c.toS :=
  okLocalN_ok (Host.Ts.Sim.Compose.VWFrames.bodyOkN_ok bytes rows) s c h

kernel_rfl PRE_first_tail_x6_r0_body.st16.bodyAccepted0 :
  (fun (bytes : List Byte) (rows : Nat) => PRE_first_tail_x6_r0_body.st16.bodyOkL bytes rows PRE_first_tail_x6_r0_body.st16.s0 PRE_first_tail_x6_r0_body.st16.S0) = fun _ _ => true

kernel_rfl PRE_first_tail_x6_r0_body.st16.bodyAccepted1 :
  (fun (bytes : List Byte) (rows : Nat) => PRE_first_tail_x6_r0_body.st16.bodyOkL bytes rows PRE_first_tail_x6_r0_body.st16.s1 PRE_first_tail_x6_r0_body.st16.S1) = fun _ _ => true

end Host.Load.Run.Tpl
end

section -- st16/TypedK0
set_option Elab.async false
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
namespace Host.Load.Run.Tpl
open Host.Ts Host.Ts.Sim Host.Ts.Sim.Template

boot_rfl PRE_first_tail_x6_r0_body.st16.bodyK0F from PRE_first_tail_x6_r0_body.st16.s0 to PRE_first_tail_x6_r0_body.st16.s1 :
  (fun (bytes : List Byte) (rows : Nat) => runOkS PRE_first_tail_x6_r0_body.st16.F (PRE_first_tail_x6_r0_body.st16.bodyOkLN bytes rows)
    ((nth? PRE_first_tail_x6_r0_body.st16.ks 0).getD 0) PRE_first_tail_x6_r0_body.st16.s0 PRE_first_tail_x6_r0_body.st16.S0) = fun _ _ => some (PRE_first_tail_x6_r0_body.st16.s1, PRE_first_tail_x6_r0_body.st16.S1)
theorem PRE_first_tail_x6_r0_body.st16.bodyK0 :
  (fun (bytes : List Byte) (rows : Nat) => runOk PRE_first_tail_x6_r0_body.st16.F (PRE_first_tail_x6_r0_body.st16.bodyOkL bytes rows)
    ((nth? PRE_first_tail_x6_r0_body.st16.ks 0).getD 0) PRE_first_tail_x6_r0_body.st16.s0 PRE_first_tail_x6_r0_body.st16.S0) = fun _ _ => some (PRE_first_tail_x6_r0_body.st16.s1, PRE_first_tail_x6_r0_body.st16.S1) :=
  runOk_fun_of_runOkS PRE_first_tail_x6_r0_body.st16.bodyOkLN_ok PRE_first_tail_x6_r0_body.st16.bodyK0F
end Host.Load.Run.Tpl
end

section -- st16/TypedTpl
set_option Elab.async false
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
namespace Host.Load.Run.Tpl
open Host.Ts Host.Ts.Sim Host.Ts.Sim.Template

theorem PRE_first_tail_x6_r0_body.st16.bodyRun (bytes : List Byte) (rows : Nat) :
    runOk PRE_first_tail_x6_r0_body.st16.F (PRE_first_tail_x6_r0_body.st16.bodyOkL bytes rows) 27 PRE_first_tail_x6_r0_body.st16.s0 PRE_first_tail_x6_r0_body.st16.S0 = some (PRE_first_tail_x6_r0_body.st16.s1, PRE_first_tail_x6_r0_body.st16.S1) :=
  (congrFun (congrFun PRE_first_tail_x6_r0_body.st16.bodyK0 bytes) rows)

theorem PRE_first_tail_x6_r0_body.st16.bodyLocal (bytes : List Byte) (rows : Nat) : ∀ s S, PRE_first_tail_x6_r0_body.st16.bodyOkL bytes rows s S = true → Disp.localB s = true := okLocal_localB

noncomputable def PRE_first_tail_x6_r0_body.st16.bodyTpl (bytes : List Byte) (rows : Nat) : Host.Ts.Sim.Stage.StageTpl PRE_first_tail_x6_r0_body.st16.F (PRE_first_tail_x6_r0_body.st16.bodyOkL bytes rows) where
  s0 := PRE_first_tail_x6_r0_body.st16.s0
  S0 := PRE_first_tail_x6_r0_body.st16.S0
  s1 := PRE_first_tail_x6_r0_body.st16.s1
  S1 := PRE_first_tail_x6_r0_body.st16.S1
  s2 := PRE_first_tail_x6_r0_body.st16.s2
  S2 := PRE_first_tail_x6_r0_body.st16.S2
  n := 27
  ok0 := congrFun (congrFun PRE_first_tail_x6_r0_body.st16.bodyAccepted0 bytes) rows
  run := PRE_first_tail_x6_r0_body.st16.bodyRun bytes rows
  ok1 := congrFun (congrFun PRE_first_tail_x6_r0_body.st16.bodyAccepted1 bytes) rows
  halt := PRE_first_tail_x6_r0_body.st16.bodyHalt
  last := PRE_first_tail_x6_r0_body.st16.bodyLast
  top := noBlockTop_sound PRE_first_tail_x6_r0_body.st16.bodyTopCheck
end Host.Load.Run.Tpl
end

section -- SiteC17
set_option Elab.async false
namespace Host.Load.Run.Tpl
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
open Host.Ts Host.Ts.Sim Host.Ts.Sim.Template

/-! The compaction after the merge at call site 17 of chain `PRE_first_tail_x6_r0_body` (`Conv.compact`, `Conv.full_compactQ`): the canonical
state `PRE_first_tail_x6_r0_body.s174` (the stage's results at canonical places, its trace the call's) under `PRE_first_tail_x6_r0_body.kappa17` into the merged state
`PRE_first_tail_x6_r0_body.s173`. -/

def PRE_first_tail_x6_r0_body.pl17 : List Nat := [2687925]
def PRE_first_tail_x6_r0_body.nr17 : List Nat := []
/-- The native part of the compaction map (canonical → merged handles and nodes: its `big`, `region`, `nodeF`). -/
def PRE_first_tail_x6_r0_body.kd17 : RData :=
  ⟨2687916, 2687926, Stage.setAll PTrie.nil [(2687915, 2687925)], Stage.setAll PTrie.nil [],
   18532, 18532, 15622, 15622, Stage.setAll PTrie.nil [],
   Stage.setAll PTrie.nil []⟩
/-- **The compaction map.** -/
noncomputable def PRE_first_tail_x6_r0_body.kappa17 : Map :=
  Conv.Map.compact 2687915 2687926 781 PRE_first_tail_x6_r0_body.pl17 (PRE_first_tail_x6_r0_body.nr17.map NumV.ref) PRE_first_tail_x6_r0_body.kd17.big
    PRE_first_tail_x6_r0_body.kd17.region PRE_first_tail_x6_r0_body.kd17.nodeF
/-- The canonical result variables and their images, the merged state's entries (`Conv.compactθ`). -/
def PRE_first_tail_x6_r0_body.cws17 : List Nat := []
noncomputable def PRE_first_tail_x6_r0_body.crs17 : List SymE := PRE_first_tail_x6_r0_body.nr17.map fun r => (nth? PRE_first_tail_x6_r0_body.S173.tab r).getD (.var 0)
noncomputable def PRE_first_tail_x6_r0_body.ctheta17 : Nat → SymE := Conv.compactθ PRE_first_tail_x6_r0_body.cws17 PRE_first_tail_x6_r0_body.crs17
/-- The call's entries the stage wrote (renamed in the canonical state with the results). -/
def PRE_first_tail_x6_r0_body.wrB17 : List Nat := [2665, 2673467]

kernel_rfl PRE_first_tail_x6_r0_body.ctab17 : PRE_first_tail_x6_r0_body.S174.tab = PRE_first_tail_x6_r0_body.S172.tab ++ PRE_first_tail_x6_r0_body.cws17.map SymE.var
kernel_rfl PRE_first_tail_x6_r0_body.ctrace17 : PRE_first_tail_x6_r0_body.s174.trace = PRE_first_tail_x6_r0_body.s172.trace
kernel_rfl PRE_first_tail_x6_r0_body.cnext17 : PRE_first_tail_x6_r0_body.s174.next = 2687916
kernel_rfl PRE_first_tail_x6_r0_body.ccounters17 : ((Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.s174.ffi).mlx.next, (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.s174.ffi).mlx.nnext) = (18532, 15622)
-- the merged state's readback queue, carried to the canonical state (`Conv.FullShiftQ.tokens`, `tokSupp`)
kernel_rfl PRE_first_tail_x6_r0_body.cqueue17 : (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.s173.ffi).mlx.tokens = (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.s174.ffi).mlx.tokens.map PRE_first_tail_x6_r0_body.kappa17.nv
kernel_rfl PRE_first_tail_x6_r0_body.ctokSupp17 : (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.s174.ffi).mlx.tokens.all (bSN 781) = true
-- the written and the result entries carry no bigint of the canonical fresh band [next, E) and no fresh region
kernel_rfl PRE_first_tail_x6_r0_body.cclean17 : Conv.cleanListB 18532 131072 (fun r => Nat.ble 74128 r) PRE_first_tail_x6_r0_body.s174
    (PRE_first_tail_x6_r0_body.wrB17 ++ (List.range 1).map (2687915 + ·)) = true
kernel_rfl PRE_first_tail_x6_r0_body.cbigs17 : bigsOutB 18532 131072 (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.s174.ffi).mlx = true

end Host.Load.Run.Tpl
end

section -- SiteK17
set_option Elab.async false
namespace Host.Load.Run.Tpl
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
open Host.Ts Host.Ts.Sim Host.Ts.Sim.Template

/-! The canonical state's closedness from the call's (`Conv.closed_of_callB`, `Conv.sst_of_callB`): it keeps the call's entries
off the written and the result ones (`PRE_first_tail_x6_r0_body.cl17`; natively the written and result handles, the result nodes, the written
and result items), and those are checked. -/

def PRE_first_tail_x6_r0_body.cl17 : List Nat := [2665, 2673467, 2687915]
def PRE_first_tail_x6_r0_body.clo17 : List Nat := []
def PRE_first_tail_x6_r0_body.cln17 : List Nat := []
def PRE_first_tail_x6_r0_body.cli17 : List Nat := []
kernel_rfl PRE_first_tail_x6_r0_body.cheap17 : PRE_first_tail_x6_r0_body.s174.heap = Stage.setAll PRE_first_tail_x6_r0_body.s172.heap (PRE_first_tail_x6_r0_body.cl17.filterMap fun a => (PRE_first_tail_x6_r0_body.s174.heap.get a).map (a, ·))
kernel_rfl PRE_first_tail_x6_r0_body.cnextLe17 : Nat.ble PRE_first_tail_x6_r0_body.s172.next PRE_first_tail_x6_r0_body.s174.next = true
kernel_rfl PRE_first_tail_x6_r0_body.ckeepP17 : Conv.keptPresentB PRE_first_tail_x6_r0_body.s172 PRE_first_tail_x6_r0_body.s174 PRE_first_tail_x6_r0_body.cl17 = true
kernel_rfl PRE_first_tail_x6_r0_body.csupp17 : Conv.suppListB PRE_first_tail_x6_r0_body.s174 781 PRE_first_tail_x6_r0_body.cl17 = true
kernel_rfl PRE_first_tail_x6_r0_body.cbound17 : Conv.boundListB PRE_first_tail_x6_r0_body.s174 PRE_first_tail_x6_r0_body.cl17 = true
kernel_rfl PRE_first_tail_x6_r0_body.cnodesK17 : (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.s174.ffi).mlx.nodes = Stage.setAll (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.s172.ffi).mlx.nodes (PRE_first_tail_x6_r0_body.cln17.filterMap fun i => ((Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.s174.ffi).mlx.nodes.get i).map (i, ·))
kernel_rfl PRE_first_tail_x6_r0_body.cobjsK17 : (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.s174.ffi).mlx.objs = Stage.setAll (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.s172.ffi).mlx.objs (PRE_first_tail_x6_r0_body.clo17.filterMap fun i => ((Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.s174.ffi).mlx.objs.get i).map (i, ·))
kernel_rfl PRE_first_tail_x6_r0_body.citemsK17 : (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.s174.ffi).mlx.items = Stage.setAll (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.s172.ffi).mlx.items (PRE_first_tail_x6_r0_body.cli17.filterMap fun i => ((Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.s174.ffi).mlx.items.get i).map (i, ·))
kernel_rfl PRE_first_tail_x6_r0_body.csst17 : Conv.sstListB 781 (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.s174.ffi).mlx PRE_first_tail_x6_r0_body.cln17 PRE_first_tail_x6_r0_body.clo17 PRE_first_tail_x6_r0_body.cli17 = true

end Host.Load.Run.Tpl
end

section -- SiteCl17
set_option Elab.async false
namespace Host.Load.Run.Tpl
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
open Host.Ts Host.Ts.Sim Host.Ts.Sim.Template

kernel_rfl PRE_first_tail_x6_r0_body.ckA17 : (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.s174.ffi).mlx.arrs = Stage.setAll (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.s172.ffi).mlx.arrs (PRE_first_tail_x6_r0_body.clo17.filterMap fun i => ((Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.s174.ffi).mlx.arrs.get i).map (i, ·))
kernel_rfl PRE_first_tail_x6_r0_body.cbd17 : (PRE_first_tail_x6_r0_body.clo17 ++ PRE_first_tail_x6_r0_body.cln17 ++ PRE_first_tail_x6_r0_body.cli17).all (fun i => Nat.blt (i / 4096) (4 ^ 31)) = true
kernel_rfl PRE_first_tail_x6_r0_body.cle17 : Conv.Cnt.leB (⟨18532, 15622, 2687915, 781⟩ : Conv.Cnt) (⟨18532, 15622, 2687916, 781⟩ : Conv.Cnt) = true
kernel_rfl PRE_first_tail_x6_r0_body.cck17 : Conv.ncleanListB (⟨18532, 15622, 2687916, 781⟩ : Conv.Cnt) (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.s174.ffi).mlx PRE_first_tail_x6_r0_body.clo17 PRE_first_tail_x6_r0_body.cln17 PRE_first_tail_x6_r0_body.cli17 = true
theorem PRE_first_tail_x6_r0_body.cncl17 (h : Conv.NClean (⟨18532, 15622, 2687915, 781⟩ : Conv.Cnt) (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.s172.ffi).mlx) : Conv.NClean (⟨18532, 15622, 2687916, 781⟩ : Conv.Cnt) (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.s174.ffi).mlx :=
  Conv.NClean.stepKeep h PRE_first_tail_x6_r0_body.cle17 PRE_first_tail_x6_r0_body.ckA17 PRE_first_tail_x6_r0_body.cobjsK17 PRE_first_tail_x6_r0_body.cnodesK17 PRE_first_tail_x6_r0_body.citemsK17 PRE_first_tail_x6_r0_body.cbd17 PRE_first_tail_x6_r0_body.cck17

end Host.Load.Run.Tpl
end

section -- SiteS17
set_option Elab.async false
namespace Host.Load.Run.Tpl
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
open Host.Ts Host.Ts.Sim Host.Ts.Sim.Template

/-! The compaction's native shift at call site 17 from its footprint (`Conv.nshift_of_foot`), and the observers'
(`liveShift_foot`, `kernShift_foot`): `Conv.FullShiftQ` for `Conv.full_compactQ`, given the call's bookkeeping and its
relation's facts. -/

/-- The load parameters of the chain (band-free: its start's node counter as `NL` and `N0`). -/
def PRE_first_tail_x6_r0_body.Pc17 : LoadP := ⟨18151, 131072, 1099511627776, 15235, 15235, []⟩
/-- The site's band raised to the map's checked fixed-node prefix, including newly recorded closure traces. -/
def PRE_first_tail_x6_r0_body.P17 : LoadP := PRE_first_tail_x6_r0_body.Pc17.raise 15622
kernel_rfl PRE_first_tail_x6_r0_body.craise17 : Nat.ble PRE_first_tail_x6_r0_body.Pc17.N0 15622 = true
theorem PRE_first_tail_x6_r0_body.raised17 : Host.Ts.Sim.Full.Raised PRE_first_tail_x6_r0_body.Pc17 PRE_first_tail_x6_r0_body.P17 :=
  .inr ⟨15622, rfl, Nat.le_of_ble_eq_true PRE_first_tail_x6_r0_body.craise17, rfl⟩
noncomputable abbrev PRE_first_tail_x6_r0_body.cx0_17 : Host.Load.LSt := clearTokens (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.s174.ffi)
noncomputable abbrev PRE_first_tail_x6_r0_body.cx1_17 : Host.Load.LSt := clearTokens (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.s173.ffi)
def PRE_first_tail_x6_r0_body.khinv17 : PTrie Nat := Stage.setAll PTrie.nil []
def PRE_first_tail_x6_r0_body.kninv17 : PTrie Nat := Stage.setAll PTrie.nil []
/-- The stage's footprint: its written and fresh handles, fresh nodes, written and fresh items. -/
def PRE_first_tail_x6_r0_body.cwS17 : List Nat := []
def PRE_first_tail_x6_r0_body.cnS17 : List Nat := List.range' 15622 0
def PRE_first_tail_x6_r0_body.ciS17 : List Nat := [] ++ List.range' 15622 0

-- the small checks (`MChecks`'s)
kernel_rfl PRE_first_tail_x6_r0_body.cnh017 : PRE_first_tail_x6_r0_body.kd17.nh0 = PRE_first_tail_x6_r0_body.cx0_17.mlx.next
kernel_rfl PRE_first_tail_x6_r0_body.cnh117 : PRE_first_tail_x6_r0_body.kd17.nh1 = PRE_first_tail_x6_r0_body.cx1_17.mlx.next
kernel_rfl PRE_first_tail_x6_r0_body.cnn017 : PRE_first_tail_x6_r0_body.kd17.nn0 = PRE_first_tail_x6_r0_body.cx0_17.mlx.nnext
kernel_rfl PRE_first_tail_x6_r0_body.cnn117 : PRE_first_tail_x6_r0_body.kd17.nn1 = PRE_first_tail_x6_r0_body.cx1_17.mlx.nnext
kernel_rfl PRE_first_tail_x6_r0_body.cplo17 : (Nat.blt 0 PRE_first_tail_x6_r0_body.P17.lo && Nat.ble PRE_first_tail_x6_r0_body.P17.lo PRE_first_tail_x6_r0_body.cx0_17.mlx.next && Nat.ble PRE_first_tail_x6_r0_body.P17.lo RData.bigHi && Nat.ble RData.bigHi PRE_first_tail_x6_r0_body.P17.E) = true
kernel_rfl PRE_first_tail_x6_r0_body.ccnt17 : (Nat.ble PRE_first_tail_x6_r0_body.cx0_17.mlx.next PRE_first_tail_x6_r0_body.cx1_17.mlx.next && Nat.ble PRE_first_tail_x6_r0_body.cx0_17.mlx.nnext PRE_first_tail_x6_r0_body.cx1_17.mlx.nnext) = true
kernel_rfl PRE_first_tail_x6_r0_body.cnband17 : (Nat.blt 0 PRE_first_tail_x6_r0_body.P17.NL && Nat.ble PRE_first_tail_x6_r0_body.P17.NL PRE_first_tail_x6_r0_body.P17.N0 && Nat.ble PRE_first_tail_x6_r0_body.P17.N0 PRE_first_tail_x6_r0_body.cx0_17.mlx.nnext) = true
kernel_rfl PRE_first_tail_x6_r0_body.chbelow17 : PRE_first_tail_x6_r0_body.kd17.checkHndBelow = true
kernel_rfl PRE_first_tail_x6_r0_body.chren17 : checkRenG PRE_first_tail_x6_r0_body.kd17.hnd PRE_first_tail_x6_r0_body.khinv17 (phB PRE_first_tail_x6_r0_body.cx0_17.mlx) = true
kernel_rfl PRE_first_tail_x6_r0_body.cband17 : PRE_first_tail_x6_r0_body.kd17.checkBand PRE_first_tail_x6_r0_body.P17.lo = true
kernel_rfl PRE_first_tail_x6_r0_body.cnh1pos17 : Nat.blt 0 PRE_first_tail_x6_r0_body.kd17.nh1 = true
kernel_rfl PRE_first_tail_x6_r0_body.cnren17 : checkRenG PRE_first_tail_x6_r0_body.kd17.node PRE_first_tail_x6_r0_body.kninv17 (pnB PRE_first_tail_x6_r0_body.cx0_17.mlx) = true
kernel_rfl PRE_first_tail_x6_r0_body.cnlow17 : (PTrie.keysA PRE_first_tail_x6_r0_body.kd17.node).all (fun j => Nat.ble PRE_first_tail_x6_r0_body.P17.NL j && Nat.blt (PRE_first_tail_x6_r0_body.kd17.nodeF j) PRE_first_tail_x6_r0_body.cx1_17.mlx.nnext) = true
kernel_rfl PRE_first_tail_x6_r0_body.cabs0a17 : PRE_first_tail_x6_r0_body.cx0_17.mlx.arrs.get 0 = none
kernel_rfl PRE_first_tail_x6_r0_body.cabs0b17 : PRE_first_tail_x6_r0_body.cx0_17.mlx.objs.get 0 = none
kernel_rfl PRE_first_tail_x6_r0_body.ctok117 : PRE_first_tail_x6_r0_body.cx1_17.mlx.tokens = []
kernel_rfl PRE_first_tail_x6_r0_body.cpend17 : PRE_first_tail_x6_r0_body.cx1_17.mlx.pending = PRE_first_tail_x6_r0_body.cx0_17.mlx.pending.map PRE_first_tail_x6_r0_body.kappa17.pend
kernel_rfl PRE_first_tail_x6_r0_body.cerrh17 : PRE_first_tail_x6_r0_body.cx1_17.mlx.errh = PRE_first_tail_x6_r0_body.cx0_17.mlx.errh.map PRE_first_tail_x6_r0_body.kappa17.arg
kernel_rfl PRE_first_tail_x6_r0_body.cfiles17 : PRE_first_tail_x6_r0_body.cx1_17.mlx.files = PRE_first_tail_x6_r0_body.cx0_17.mlx.files
kernel_rfl PRE_first_tail_x6_r0_body.carch17 : PRE_first_tail_x6_r0_body.cx1_17.mlx.arch = PRE_first_tail_x6_r0_body.cx0_17.mlx.arch
kernel_rfl PRE_first_tail_x6_r0_body.csizes17 : PRE_first_tail_x6_r0_body.cx1_17.mlx.deviceSizes = PRE_first_tail_x6_r0_body.cx0_17.mlx.deviceSizes
kernel_rfl PRE_first_tail_x6_r0_body.cwired17 : PRE_first_tail_x6_r0_body.cx1_17.mlx.wired = PRE_first_tail_x6_r0_body.cx0_17.mlx.wired
kernel_rfl PRE_first_tail_x6_r0_body.chost17 : PRE_first_tail_x6_r0_body.cx1_17.host = PRE_first_tail_x6_r0_body.cx0_17.host
-- the compaction map's addresses are `PRE_first_tail_x6_r0_body.kd17`'s
kernel_rfl PRE_first_tail_x6_r0_body.ckn017 : PRE_first_tail_x6_r0_body.kd17.n0 = 2687916
kernel_rfl PRE_first_tail_x6_r0_body.ckn117 : PRE_first_tail_x6_r0_body.kd17.n1 = 2687926
kernel_rfl PRE_first_tail_x6_r0_body.ckheap17 : (PTrie.keysA PRE_first_tail_x6_r0_body.kd17.heap).all (fun x => Nat.ble 2687915 x) = true
kernel_rfl PRE_first_tail_x6_r0_body.ckpl17 : (List.range 1).all (fun j => decide (PRE_first_tail_x6_r0_body.kd17.heap.get (2687915 + j) = nth? PRE_first_tail_x6_r0_body.pl17 j)) = true
-- the map fixes the call's names (`Conv.fixOld_compact`), the call's counters
kernel_rfl PRE_first_tail_x6_r0_body.fja17 : Nat.ble 2687915 2687915 = true
kernel_rfl PRE_first_tail_x6_r0_body.fn17 : Nat.ble 781 781 = true
kernel_rfl PRE_first_tail_x6_r0_body.fjaD17 : Nat.ble 2687915 PRE_first_tail_x6_r0_body.kd17.n0 = true
kernel_rfl PRE_first_tail_x6_r0_body.fxn17 : Nat.ble 18532 PRE_first_tail_x6_r0_body.kd17.nh0 = true
kernel_rfl PRE_first_tail_x6_r0_body.fnn17 : Nat.ble 15622 PRE_first_tail_x6_r0_body.kd17.nn0 = true
kernel_rfl PRE_first_tail_x6_r0_body.fxb17 : Nat.ble 18532 RData.bigHi = true
kernel_rfl PRE_first_tail_x6_r0_body.fheap17 : (PTrie.keysA PRE_first_tail_x6_r0_body.kd17.heap).all (Nat.ble (⟨18532, 15622, 2687915, 781⟩ : Conv.Cnt).ja) = true
kernel_rfl PRE_first_tail_x6_r0_body.fhnd17 : (PTrie.keysA PRE_first_tail_x6_r0_body.kd17.hnd).all (Nat.ble (⟨18532, 15622, 2687915, 781⟩ : Conv.Cnt).xn) = true
kernel_rfl PRE_first_tail_x6_r0_body.fnode17 : (PTrie.keysA PRE_first_tail_x6_r0_body.kd17.node).all (Nat.ble (⟨18532, 15622, 2687915, 781⟩ : Conv.Cnt).nn) = true
/-- The compaction map fixes the call's names. -/
theorem PRE_first_tail_x6_r0_body.cfix17 : Conv.FixOld (⟨18532, 15622, 2687915, 781⟩ : Conv.Cnt) PRE_first_tail_x6_r0_body.kappa17 :=
  Conv.fixOld_compact (Nat.le_of_ble_eq_true PRE_first_tail_x6_r0_body.fja17) (Nat.le_of_ble_eq_true PRE_first_tail_x6_r0_body.fn17) (Nat.le_of_ble_eq_true PRE_first_tail_x6_r0_body.fjaD17) (Nat.le_of_ble_eq_true PRE_first_tail_x6_r0_body.fxn17) (Nat.le_of_ble_eq_true PRE_first_tail_x6_r0_body.fnn17) (Nat.le_of_ble_eq_true PRE_first_tail_x6_r0_body.fxb17) PRE_first_tail_x6_r0_body.fheap17 PRE_first_tail_x6_r0_body.fhnd17 PRE_first_tail_x6_r0_body.fnode17
kernel_rfl PRE_first_tail_x6_r0_body.fcxn17 : (⟨18532, 15622, 2687915, 781⟩ : Conv.Cnt).xn = (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.s172.ffi).mlx.next
kernel_rfl PRE_first_tail_x6_r0_body.fcnn17 : (⟨18532, 15622, 2687915, 781⟩ : Conv.Cnt).nn = (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.s172.ffi).mlx.nnext
kernel_rfl PRE_first_tail_x6_r0_body.fle017 : (Nat.ble (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.s172.ffi).mlx.next PRE_first_tail_x6_r0_body.cx0_17.mlx.next && Nat.ble (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.s172.ffi).mlx.nnext PRE_first_tail_x6_r0_body.cx0_17.mlx.nnext && Nat.ble (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.s172.ffi).mlx.next RData.bigHi) = true
kernel_rfl PRE_first_tail_x6_r0_body.fnk17 : (PTrie.keysA PRE_first_tail_x6_r0_body.kd17.node).all (Nat.ble (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.s172.ffi).mlx.nnext) = true
-- the merged state keeps the call's entries off the stage's footprint
kernel_rfl PRE_first_tail_x6_r0_body.f1A17 : PRE_first_tail_x6_r0_body.cx1_17.mlx.arrs = Stage.setAll (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.s172.ffi).mlx.arrs (PRE_first_tail_x6_r0_body.cwS17.filterMap fun i => (PRE_first_tail_x6_r0_body.cx1_17.mlx.arrs.get i).map (i, ·))
kernel_rfl PRE_first_tail_x6_r0_body.f1O17 : PRE_first_tail_x6_r0_body.cx1_17.mlx.objs = Stage.setAll (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.s172.ffi).mlx.objs (PRE_first_tail_x6_r0_body.cwS17.filterMap fun i => (PRE_first_tail_x6_r0_body.cx1_17.mlx.objs.get i).map (i, ·))
kernel_rfl PRE_first_tail_x6_r0_body.f1N17 : PRE_first_tail_x6_r0_body.cx1_17.mlx.nodes = Stage.setAll (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.s172.ffi).mlx.nodes (PRE_first_tail_x6_r0_body.cnS17.filterMap fun i => (PRE_first_tail_x6_r0_body.cx1_17.mlx.nodes.get i).map (i, ·))
kernel_rfl PRE_first_tail_x6_r0_body.f1I17 : PRE_first_tail_x6_r0_body.cx1_17.mlx.items = Stage.setAll (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.s172.ffi).mlx.items (PRE_first_tail_x6_r0_body.ciS17.filterMap fun i => (PRE_first_tail_x6_r0_body.cx1_17.mlx.items.get i).map (i, ·))
kernel_rfl PRE_first_tail_x6_r0_body.fbd17 : (PRE_first_tail_x6_r0_body.clo17 ++ PRE_first_tail_x6_r0_body.cln17 ++ PRE_first_tail_x6_r0_body.cli17 ++ PRE_first_tail_x6_r0_body.cwS17 ++ PRE_first_tail_x6_r0_body.cnS17 ++ PRE_first_tail_x6_r0_body.ciS17).all (fun i => Nat.blt (i / 4096) (4 ^ 31)) = true
kernel_rfl PRE_first_tail_x6_r0_body.fincW17 : PRE_first_tail_x6_r0_body.cwS17.all (fun h => !Nat.blt h (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.s172.ffi).mlx.next || PRE_first_tail_x6_r0_body.clo17.contains h) = true
kernel_rfl PRE_first_tail_x6_r0_body.fincI17 : PRE_first_tail_x6_r0_body.ciS17.all (fun k => !Nat.blt k (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.s172.ffi).mlx.nnext || PRE_first_tail_x6_r0_body.cli17.contains k) = true
kernel_rfl PRE_first_tail_x6_r0_body.fincN17 : PRE_first_tail_x6_r0_body.cnS17.all (Nat.ble (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.s172.ffi).mlx.nnext) = true
kernel_rfl PRE_first_tail_x6_r0_body.flnF17 : PRE_first_tail_x6_r0_body.cln17.all (Nat.ble (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.s172.ffi).mlx.nnext) = true
-- the checks over the changed lists
kernel_rfl PRE_first_tail_x6_r0_body.fh17 : PRE_first_tail_x6_r0_body.clo17.all (handleOK PRE_first_tail_x6_r0_body.kappa17 PRE_first_tail_x6_r0_body.P17.lo PRE_first_tail_x6_r0_body.cx0_17.mlx PRE_first_tail_x6_r0_body.cx1_17.mlx) = true
kernel_rfl PRE_first_tail_x6_r0_body.fo17 : PRE_first_tail_x6_r0_body.clo17.map (fun h => PRE_first_tail_x6_r0_body.cx1_17.mlx.objs.get (PRE_first_tail_x6_r0_body.kappa17.handle h)) = PRE_first_tail_x6_r0_body.clo17.map (fun h => (PRE_first_tail_x6_r0_body.cx0_17.mlx.objs.get h).map PRE_first_tail_x6_r0_body.kappa17.nobj)
kernel_rfl PRE_first_tail_x6_r0_body.fok17 : PRE_first_tail_x6_r0_body.clo17.all (objOK PRE_first_tail_x6_r0_body.kappa17 PRE_first_tail_x6_r0_body.P17.NL PRE_first_tail_x6_r0_body.cx0_17.mlx) = true
kernel_rfl PRE_first_tail_x6_r0_body.fnd17 : PRE_first_tail_x6_r0_body.cln17.all (nodeOKF PRE_first_tail_x6_r0_body.kappa17 PRE_first_tail_x6_r0_body.P17 PRE_first_tail_x6_r0_body.cx0_17.mlx PRE_first_tail_x6_r0_body.cx1_17.mlx) = true
kernel_rfl PRE_first_tail_x6_r0_body.fp17 : ((PRE_first_tail_x6_r0_body.cln17.filter (fullB PRE_first_tail_x6_r0_body.P17))).map (fun i => (PRE_first_tail_x6_r0_body.cx1_17.mlx.nodes.get (PRE_first_tail_x6_r0_body.kappa17.node i)).map Host.Mlx.Ffi.Node.prim) =
  ((PRE_first_tail_x6_r0_body.cln17.filter (fullB PRE_first_tail_x6_r0_body.P17))).map (fun i => (PRE_first_tail_x6_r0_body.cx0_17.mlx.nodes.get i).map fun nd => PRE_first_tail_x6_r0_body.kappa17.prim nd.prim)
kernel_rfl PRE_first_tail_x6_r0_body.fnordI17 : incrB PRE_first_tail_x6_r0_body.kd17.nodeF (List.range' 15622 0) = true
kernel_rfl PRE_first_tail_x6_r0_body.fnordK17 : (PTrie.keysA PRE_first_tail_x6_r0_body.kd17.node).all (fun k => Nat.ble 15622 k && Nat.blt k 15622) = true
kernel_rfl PRE_first_tail_x6_r0_body.fnordL17 : (PRE_first_tail_x6_r0_body.cln17.filter (Nat.ble PRE_first_tail_x6_r0_body.P17.N0)).all (fun i => Nat.ble i (PRE_first_tail_x6_r0_body.kd17.nodeF i) && (Nat.blt i 15622 || Nat.ble PRE_first_tail_x6_r0_body.kd17.nn0 i)) = true
theorem PRE_first_tail_x6_r0_body.fnord17 : (PRE_first_tail_x6_r0_body.cln17.filter (Nat.ble PRE_first_tail_x6_r0_body.P17.N0)).all (fun i => Nat.ble i (PRE_first_tail_x6_r0_body.kd17.nodeF i) &&
    (PTrie.keysA PRE_first_tail_x6_r0_body.kd17.node).all fun j => !Nat.blt j i || Nat.blt (PRE_first_tail_x6_r0_body.kd17.nodeF j) (PRE_first_tail_x6_r0_body.kd17.nodeF i)) = true :=
  cnord_of PRE_first_tail_x6_r0_body.cnlow17 PRE_first_tail_x6_r0_body.cnn117 PRE_first_tail_x6_r0_body.fnordI17 PRE_first_tail_x6_r0_body.fnordK17 PRE_first_tail_x6_r0_body.fnordL17
kernel_rfl PRE_first_tail_x6_r0_body.fi17 : PRE_first_tail_x6_r0_body.cli17.all (pnB PRE_first_tail_x6_r0_body.cx0_17.mlx) = true
kernel_rfl PRE_first_tail_x6_r0_body.fii17 : PRE_first_tail_x6_r0_body.cli17.all (fun k => decide (PRE_first_tail_x6_r0_body.cx1_17.mlx.items.get (PRE_first_tail_x6_r0_body.kappa17.node k) = (PRE_first_tail_x6_r0_body.cx0_17.mlx.items.get k).map PRE_first_tail_x6_r0_body.kappa17.nv)) = true
/-- **The compaction's footprint.** -/
theorem PRE_first_tail_x6_r0_body.cfoot17 (clean : Conv.NClean (⟨18532, 15622, 2687915, 781⟩ : Conv.Cnt) (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.s172.ffi).mlx) (hltC : ∀ h, PH (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.s172.ffi).mlx h → h < (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.s172.ffi).mlx.next) (nltC : ∀ i, PN (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.s172.ffi).mlx i → i < (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.s172.ffi).mlx.nnext) (itemsC : ∀ k v, (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.s172.ffi).mlx.items.get k = some v → PN (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.s172.ffi).mlx k) (tracedC : ∀ h o, (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.s172.ffi).mlx.objs.get h = some o → ∀ i ∈ objTraces o, i < PRE_first_tail_x6_r0_body.P17.NL) (cl : SSt (· < 781) PRE_first_tail_x6_r0_body.cx0_17.mlx) :
    Conv.MFoot PRE_first_tail_x6_r0_body.P17 781 PRE_first_tail_x6_r0_body.kappa17 PRE_first_tail_x6_r0_body.kd17 PRE_first_tail_x6_r0_body.khinv17 PRE_first_tail_x6_r0_body.kninv17 (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.s172.ffi).mlx PRE_first_tail_x6_r0_body.cx0_17.mlx PRE_first_tail_x6_r0_body.cx1_17.mlx (⟨18532, 15622, 2687915, 781⟩ : Conv.Cnt) PRE_first_tail_x6_r0_body.clo17 PRE_first_tail_x6_r0_body.cln17 PRE_first_tail_x6_r0_body.cli17 PRE_first_tail_x6_r0_body.cwS17 PRE_first_tail_x6_r0_body.cnS17 PRE_first_tail_x6_r0_body.ciS17 :=
  ⟨rfl, rfl, rfl, PRE_first_tail_x6_r0_body.cnh017, PRE_first_tail_x6_r0_body.cnh117, PRE_first_tail_x6_r0_body.cnn017, PRE_first_tail_x6_r0_body.cnn117, PRE_first_tail_x6_r0_body.cplo17, PRE_first_tail_x6_r0_body.ccnt17, PRE_first_tail_x6_r0_body.cnband17, PRE_first_tail_x6_r0_body.chbelow17, PRE_first_tail_x6_r0_body.chren17, PRE_first_tail_x6_r0_body.cband17, PRE_first_tail_x6_r0_body.cnh1pos17, PRE_first_tail_x6_r0_body.cnren17, PRE_first_tail_x6_r0_body.cnlow17, PRE_first_tail_x6_r0_body.cabs0a17, PRE_first_tail_x6_r0_body.cabs0b17, PRE_first_tail_x6_r0_body.ctok117, PRE_first_tail_x6_r0_body.cpend17, PRE_first_tail_x6_r0_body.cerrh17, PRE_first_tail_x6_r0_body.cfiles17, PRE_first_tail_x6_r0_body.carch17, PRE_first_tail_x6_r0_body.csizes17, PRE_first_tail_x6_r0_body.cwired17, PRE_first_tail_x6_r0_body.cfix17, clean, PRE_first_tail_x6_r0_body.fcxn17, PRE_first_tail_x6_r0_body.fcnn17, hltC, nltC, itemsC, tracedC, cl, PRE_first_tail_x6_r0_body.fle017, PRE_first_tail_x6_r0_body.fnk17, PRE_first_tail_x6_r0_body.ckA17, PRE_first_tail_x6_r0_body.cobjsK17, PRE_first_tail_x6_r0_body.cnodesK17, PRE_first_tail_x6_r0_body.citemsK17, PRE_first_tail_x6_r0_body.f1A17, PRE_first_tail_x6_r0_body.f1O17, PRE_first_tail_x6_r0_body.f1N17, PRE_first_tail_x6_r0_body.f1I17, PRE_first_tail_x6_r0_body.fbd17, PRE_first_tail_x6_r0_body.fincW17, PRE_first_tail_x6_r0_body.fincI17, PRE_first_tail_x6_r0_body.fincN17, PRE_first_tail_x6_r0_body.flnF17, PRE_first_tail_x6_r0_body.fh17, PRE_first_tail_x6_r0_body.fo17, PRE_first_tail_x6_r0_body.fok17, PRE_first_tail_x6_r0_body.fnd17, PRE_first_tail_x6_r0_body.fp17, PRE_first_tail_x6_r0_body.fnord17, PRE_first_tail_x6_r0_body.fi17, PRE_first_tail_x6_r0_body.fii17⟩
theorem PRE_first_tail_x6_r0_body.cnshift17 (clean : Conv.NClean (⟨18532, 15622, 2687915, 781⟩ : Conv.Cnt) (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.s172.ffi).mlx) (hltC : ∀ h, PH (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.s172.ffi).mlx h → h < (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.s172.ffi).mlx.next) (nltC : ∀ i, PN (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.s172.ffi).mlx i → i < (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.s172.ffi).mlx.nnext) (itemsC : ∀ k v, (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.s172.ffi).mlx.items.get k = some v → PN (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.s172.ffi).mlx k) (tracedC : ∀ h o, (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.s172.ffi).mlx.objs.get h = some o → ∀ i ∈ objTraces o, i < PRE_first_tail_x6_r0_body.P17.NL) (cl : SSt (· < 781) PRE_first_tail_x6_r0_body.cx0_17.mlx) : NShift PRE_first_tail_x6_r0_body.P17 781 PRE_first_tail_x6_r0_body.kappa17 PRE_first_tail_x6_r0_body.cx0_17 PRE_first_tail_x6_r0_body.cx1_17 :=
  Conv.nshift_of_foot (PRE_first_tail_x6_r0_body.cfoot17 clean hltC nltC itemsC tracedC cl) PRE_first_tail_x6_r0_body.chost17 (compact_a_eq PRE_first_tail_x6_r0_body.ckn017 PRE_first_tail_x6_r0_body.ckn117 PRE_first_tail_x6_r0_body.ckheap17 PRE_first_tail_x6_r0_body.ckpl17)

-- the observers: the layers' states at the call, the canonical and the merged state, their footprints and checks
noncomputable def PRE_first_tail_x6_r0_body.fxC_17 : PTrie Unit := (Host.Ts.Sim.Full.freedOf PRE_first_tail_x6_r0_body.s172.ffi).getD PTrie.nil
noncomputable def PRE_first_tail_x6_r0_body.krC_17 : Host.Load.Layers.KRec := (Host.Ts.Sim.Full.krecOf PRE_first_tail_x6_r0_body.s172.ffi).getD Host.Load.Layers.KRec.empty
kernel_rfl PRE_first_tail_x6_r0_body.ofxC_17 : (Host.Ts.Sim.Full.freedOf PRE_first_tail_x6_r0_body.s172.ffi) = some PRE_first_tail_x6_r0_body.fxC_17
kernel_rfl PRE_first_tail_x6_r0_body.okrC_17 : (Host.Ts.Sim.Full.krecOf PRE_first_tail_x6_r0_body.s172.ffi) = some PRE_first_tail_x6_r0_body.krC_17
noncomputable def PRE_first_tail_x6_r0_body.fx0_17 : PTrie Unit := (Host.Ts.Sim.Full.freedOf PRE_first_tail_x6_r0_body.s174.ffi).getD PTrie.nil
noncomputable def PRE_first_tail_x6_r0_body.kr0_17 : Host.Load.Layers.KRec := (Host.Ts.Sim.Full.krecOf PRE_first_tail_x6_r0_body.s174.ffi).getD Host.Load.Layers.KRec.empty
kernel_rfl PRE_first_tail_x6_r0_body.ofx0_17 : (Host.Ts.Sim.Full.freedOf PRE_first_tail_x6_r0_body.s174.ffi) = some PRE_first_tail_x6_r0_body.fx0_17
kernel_rfl PRE_first_tail_x6_r0_body.okr0_17 : (Host.Ts.Sim.Full.krecOf PRE_first_tail_x6_r0_body.s174.ffi) = some PRE_first_tail_x6_r0_body.kr0_17
noncomputable def PRE_first_tail_x6_r0_body.fx1_17 : PTrie Unit := (Host.Ts.Sim.Full.freedOf PRE_first_tail_x6_r0_body.s173.ffi).getD PTrie.nil
noncomputable def PRE_first_tail_x6_r0_body.kr1_17 : Host.Load.Layers.KRec := (Host.Ts.Sim.Full.krecOf PRE_first_tail_x6_r0_body.s173.ffi).getD Host.Load.Layers.KRec.empty
kernel_rfl PRE_first_tail_x6_r0_body.ofx1_17 : (Host.Ts.Sim.Full.freedOf PRE_first_tail_x6_r0_body.s173.ffi) = some PRE_first_tail_x6_r0_body.fx1_17
kernel_rfl PRE_first_tail_x6_r0_body.okr1_17 : (Host.Ts.Sim.Full.krecOf PRE_first_tail_x6_r0_body.s173.ffi) = some PRE_first_tail_x6_r0_body.kr1_17
kernel_rfl PRE_first_tail_x6_r0_body.ff017 : PRE_first_tail_x6_r0_body.fx0_17 = Stage.setAll PRE_first_tail_x6_r0_body.fxC_17 (PRE_first_tail_x6_r0_body.clo17.filterMap fun i => (PRE_first_tail_x6_r0_body.fx0_17.get i).map (i, ·))
kernel_rfl PRE_first_tail_x6_r0_body.ff117 : PRE_first_tail_x6_r0_body.fx1_17 = Stage.setAll PRE_first_tail_x6_r0_body.fxC_17 (PRE_first_tail_x6_r0_body.cwS17.filterMap fun i => (PRE_first_tail_x6_r0_body.fx1_17.get i).map (i, ·))
kernel_rfl PRE_first_tail_x6_r0_body.ffck17 : freedLB PRE_first_tail_x6_r0_body.kappa17 PRE_first_tail_x6_r0_body.cx0_17.mlx PRE_first_tail_x6_r0_body.fx0_17 PRE_first_tail_x6_r0_body.fx1_17 PRE_first_tail_x6_r0_body.clo17 = true
kernel_rfl PRE_first_tail_x6_r0_body.fkf017 : PRE_first_tail_x6_r0_body.kr0_17.flags = Stage.setAll PRE_first_tail_x6_r0_body.krC_17.flags (PRE_first_tail_x6_r0_body.clo17.filterMap fun i => (PRE_first_tail_x6_r0_body.kr0_17.flags.get i).map (i, ·))
kernel_rfl PRE_first_tail_x6_r0_body.fkt017 : PRE_first_tail_x6_r0_body.kr0_17.targs = Stage.setAll PRE_first_tail_x6_r0_body.krC_17.targs (PRE_first_tail_x6_r0_body.clo17.filterMap fun i => (PRE_first_tail_x6_r0_body.kr0_17.targs.get i).map (i, ·))
kernel_rfl PRE_first_tail_x6_r0_body.fkf117 : PRE_first_tail_x6_r0_body.kr1_17.flags = Stage.setAll PRE_first_tail_x6_r0_body.krC_17.flags (PRE_first_tail_x6_r0_body.cwS17.filterMap fun i => (PRE_first_tail_x6_r0_body.kr1_17.flags.get i).map (i, ·))
kernel_rfl PRE_first_tail_x6_r0_body.fkt117 : PRE_first_tail_x6_r0_body.kr1_17.targs = Stage.setAll PRE_first_tail_x6_r0_body.krC_17.targs (PRE_first_tail_x6_r0_body.cwS17.filterMap fun i => (PRE_first_tail_x6_r0_body.kr1_17.targs.get i).map (i, ·))
kernel_rfl PRE_first_tail_x6_r0_body.fkck17 : krecLB PRE_first_tail_x6_r0_body.kappa17 781 PRE_first_tail_x6_r0_body.cx0_17.mlx PRE_first_tail_x6_r0_body.kr0_17 PRE_first_tail_x6_r0_body.kr1_17 PRE_first_tail_x6_r0_body.clo17 = true
kernel_rfl PRE_first_tail_x6_r0_body.fkn17 : Nat.ble 781 781 = true
-- the bridge and the pending traces' regions
kernel_rfl PRE_first_tail_x6_r0_body.cbridge17 : Host.Ts.Sim.Full.bridgeOf PRE_first_tail_x6_r0_body.s173.ffi = Host.Ts.Sim.Full.bridgeOf PRE_first_tail_x6_r0_body.s174.ffi
kernel_rfl PRE_first_tail_x6_r0_body.cpendR17 : pendRegB PRE_first_tail_x6_r0_body.kappa17 (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.s174.ffi).mlx = true
kernel_rfl PRE_first_tail_x6_r0_body.cpendLe17 : Nat.ble (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.s174.ffi).mlx.next (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.s173.ffi).mlx.next = true
/-- **The compaction's native shift**, given the call's bookkeeping, its relation's facts (the model's and the
observers') and the canonical closedness. -/
theorem PRE_first_tail_x6_r0_body.cshift17 (clean : Conv.NClean (⟨18532, 15622, 2687915, 781⟩ : Conv.Cnt) (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.s172.ffi).mlx) (hltC : ∀ h, PH (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.s172.ffi).mlx h → h < (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.s172.ffi).mlx.next) (nltC : ∀ i, PN (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.s172.ffi).mlx i → i < (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.s172.ffi).mlx.nnext) (itemsC : ∀ k v, (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.s172.ffi).mlx.items.get k = some v → PN (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.s172.ffi).mlx k) (tracedC : ∀ h o, (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.s172.ffi).mlx.objs.get h = some o → ∀ i ∈ objTraces o, i < PRE_first_tail_x6_r0_body.P17.NL) (cl : SSt (· < 781) PRE_first_tail_x6_r0_body.cx0_17.mlx)
    (hobjC : ∀ h, PRE_first_tail_x6_r0_body.fxC_17.get h = some () → ((Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.s172.ffi).mlx.objs.get h).isSome = true)
    (hfC : ∀ h, (PRE_first_tail_x6_r0_body.krC_17.flags.get h).isSome = true → ((Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.s172.ffi).mlx.objs.get h).isSome = true)
    (htC : ∀ h, (PRE_first_tail_x6_r0_body.krC_17.targs.get h).isSome = true → ((Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.s172.ffi).mlx.objs.get h).isSome = true)
    (hclC : ∀ h l, PRE_first_tail_x6_r0_body.krC_17.targs.get h = some l → Host.Ts.Sim.Full.STargs (· < (⟨18532, 15622, 2687915, 781⟩ : Conv.Cnt).n) l) :
    Conv.FullShiftQ PRE_first_tail_x6_r0_body.P17 781 PRE_first_tail_x6_r0_body.kappa17 PRE_first_tail_x6_r0_body.s174.ffi PRE_first_tail_x6_r0_body.s173.ffi :=
  ⟨PRE_first_tail_x6_r0_body.cnshift17 clean hltC nltC itemsC tracedC cl, PRE_first_tail_x6_r0_body.cqueue17, fun t ht => bSN_sound (List.all_eq_true.mp PRE_first_tail_x6_r0_body.ctokSupp17 t ht),
    PRE_first_tail_x6_r0_body.cbridge17,
    liveShift_foot (x0' := Host.Ts.Sim.Full.mlxOf PRE_first_tail_x6_r0_body.s174.ffi) (x1' := Host.Ts.Sim.Full.mlxOf PRE_first_tail_x6_r0_body.s173.ffi) (PRE_first_tail_x6_r0_body.cfoot17 clean hltC nltC itemsC tracedC cl) rfl PRE_first_tail_x6_r0_body.ofx0_17 PRE_first_tail_x6_r0_body.ofx1_17 hobjC PRE_first_tail_x6_r0_body.ff017 PRE_first_tail_x6_r0_body.ff117 PRE_first_tail_x6_r0_body.ffck17,
    kernShift_foot (x0' := Host.Ts.Sim.Full.mlxOf PRE_first_tail_x6_r0_body.s174.ffi) (x1' := Host.Ts.Sim.Full.mlxOf PRE_first_tail_x6_r0_body.s173.ffi) (PRE_first_tail_x6_r0_body.cfoot17 clean hltC nltC itemsC tracedC cl) rfl PRE_first_tail_x6_r0_body.okr0_17 PRE_first_tail_x6_r0_body.okr1_17 (Nat.le_of_ble_eq_true PRE_first_tail_x6_r0_body.fkn17) hfC htC hclC
      PRE_first_tail_x6_r0_body.fkf017 PRE_first_tail_x6_r0_body.fkt017 PRE_first_tail_x6_r0_body.fkf117 PRE_first_tail_x6_r0_body.fkt117 PRE_first_tail_x6_r0_body.fkck17,
    pendReg_of rfl PRE_first_tail_x6_r0_body.cnh017 PRE_first_tail_x6_r0_body.cnh117 (Nat.le_of_ble_eq_true PRE_first_tail_x6_r0_body.cpendLe17) PRE_first_tail_x6_r0_body.cpendR17⟩

end Host.Load.Run.Tpl
end

section -- st17/H0
set_option Elab.async false
namespace Host.Load.Run.Tpl
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
host_stream_state PRE_first_tail_x6_r0_body.st17 0
host_stream_state PRE_first_tail_x6_r0_body.st17 1
host_stream_state PRE_first_tail_x6_r0_body.st17 2
end Host.Load.Run.Tpl
end

section -- Site17
set_option Elab.async false
namespace Host.Load.Run.Tpl
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
open Host.Ts Host.Ts.Sim Host.Ts.Sim.Template

/-! Call site 17 of chain `PRE_first_tail_x6_r0_body`: `plan__g17__g18` (`plan`), the call state `PRE_first_tail_x6_r0_body.s172`, the merged state `PRE_first_tail_x6_r0_body.s173`,
the site template `PRE_first_tail_x6_r0_body.st17` (σ = `Map.id`, θ the identity at its own site), the canonical state `PRE_first_tail_x6_r0_body.s174`: the merge.
The footprint's facts are in `SiteF17`, the compaction's in `SiteC17`, `SiteK17`, `SiteNa17`, `SiteNb17`. -/

kernel_rfl PRE_first_tail_x6_r0_body.iso17 : PRE_first_tail_x6_r0_body.st17.s0 = { PRE_first_tail_x6_r0_body.s172 with stack := [] }
/-- The caller's frames at the call. -/
noncomputable def PRE_first_tail_x6_r0_body.rs17 : List Frame := PRE_first_tail_x6_r0_body.s172.stack
kernel_rfl PRE_first_tail_x6_r0_body.n0_17 : PRE_first_tail_x6_r0_body.S172.tab.length = 781
kernel_rfl PRE_first_tail_x6_r0_body.tab0_17 : PRE_first_tail_x6_r0_body.st17.S0.tab = PRE_first_tail_x6_r0_body.S172.tab

/-- The fresh variables of the stage's results. -/
def PRE_first_tail_x6_r0_body.ws17 : List Nat := [1304, 1305, 1306]
kernel_rfl PRE_first_tail_x6_r0_body.fresh17 : (PRE_first_tail_x6_r0_body.S172.tab.all fun e => PRE_first_tail_x6_r0_body.ws17.all fun v => e.noVar v) &&
    (PRE_first_tail_x6_r0_body.S172.oracle.all fun q => PRE_first_tail_x6_r0_body.ws17.all fun v => q.noVar v) = true
kernel_rfl PRE_first_tail_x6_r0_body.mergeTab17 : PRE_first_tail_x6_r0_body.S173.tab = PRE_first_tail_x6_r0_body.S172.tab ++ Conv.resTab PRE_first_tail_x6_r0_body.ws17
kernel_rfl PRE_first_tail_x6_r0_body.mergeLen17 : PRE_first_tail_x6_r0_body.st17.S2.tab.length - PRE_first_tail_x6_r0_body.st17.S0.tab.length = 3

-- The merged state: the instance's return state with the caller's frames (`PRE_first_tail_x6_r0_body.merged17`, `merged_relB`).
kernel_rfl PRE_first_tail_x6_r0_body.mheap17 : PRE_first_tail_x6_r0_body.s173.heap = PRE_first_tail_x6_r0_body.st17.s2.heap
kernel_rfl PRE_first_tail_x6_r0_body.mnext17 : PRE_first_tail_x6_r0_body.s173.next = PRE_first_tail_x6_r0_body.st17.s2.next
kernel_rfl PRE_first_tail_x6_r0_body.mctl17 : PRE_first_tail_x6_r0_body.s173.ctl = PRE_first_tail_x6_r0_body.st17.s2.ctl
kernel_rfl PRE_first_tail_x6_r0_body.mstack17 : PRE_first_tail_x6_r0_body.s173.stack = PRE_first_tail_x6_r0_body.st17.s2.stack ++ PRE_first_tail_x6_r0_body.s172.stack
kernel_rfl PRE_first_tail_x6_r0_body.mjobs17 : PRE_first_tail_x6_r0_body.s173.jobs = PRE_first_tail_x6_r0_body.st17.s2.jobs
kernel_rfl PRE_first_tail_x6_r0_body.mffi17 : PRE_first_tail_x6_r0_body.s173.ffi = PRE_first_tail_x6_r0_body.st17.s2.ffi
kernel_rfl PRE_first_tail_x6_r0_body.mtrace17 : PRE_first_tail_x6_r0_body.s173.trace = PRE_first_tail_x6_r0_body.st17.s2.trace
kernel_rfl PRE_first_tail_x6_r0_body.mstores17 : PRE_first_tail_x6_r0_body.s173.stores = PRE_first_tail_x6_r0_body.st17.s2.stores

end Host.Load.Run.Tpl
end

section -- SiteD17
set_option Elab.async false
namespace Host.Load.Run.Tpl
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
open Host.Ts Host.Ts.Sim Host.Ts.Sim.Template

/-! The canonical results at call site 17 of chain `PRE_first_tail_x6_r0_body`: their values in the instance's end table, the references past
the call's table, the canonical variables apart from the stage's. -/

kernel_rfl PRE_first_tail_x6_r0_body.cderived17 : PRE_first_tail_x6_r0_body.nr17.map (fun r => nth? PRE_first_tail_x6_r0_body.st17.S2.tab r) =
  []
kernel_rfl PRE_first_tail_x6_r0_body.cnrLo17 : PRE_first_tail_x6_r0_body.nr17.all (Nat.ble 781) = true
kernel_rfl PRE_first_tail_x6_r0_body.cwsDisj17 : PRE_first_tail_x6_r0_body.cws17.all (fun c => !PRE_first_tail_x6_r0_body.ws17.contains c) = true
/-- The compaction's substitution: the canonical variables to their merged values, the stage's other fresh variables
to `0` (`Conv.compactθZ`). -/
noncomputable def PRE_first_tail_x6_r0_body.cthetaZ17 : Nat → SymE := Conv.compactθZ PRE_first_tail_x6_r0_body.cws17 PRE_first_tail_x6_r0_body.crs17 PRE_first_tail_x6_r0_body.ws17

end Host.Load.Run.Tpl
end

section -- st17/Foot
set_option Elab.async false
namespace Host.Load.Run.Tpl
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
open Host.Ts Host.Ts.Sim Host.Ts.Sim.Stage Host.Ts.Sim.Template

/-! The footprint of stage `PRE_first_tail_x6_r0_body.st17`'s site template (`Conv.StageFoot`, `Conv.NFoot`): every entry of the return
state other than the written and fresh ones is the start's (kernel evaluation of the equalities). -/

/-- The written heap ranges below the start's counter. -/
def PRE_first_tail_x6_r0_body.st17.wrR : List (Nat × Nat) := []
/-- The written and fresh entries of the return state. -/
noncomputable def PRE_first_tail_x6_r0_body.st17.wrE : List (Nat × Host.Ts.HObj) :=
  rangesOf PRE_first_tail_x6_r0_body.st17.s2.heap PRE_first_tail_x6_r0_body.st17.wrR ++ freshOf PRE_first_tail_x6_r0_body.st17.s2.heap PRE_first_tail_x6_r0_body.st17.s0.next PRE_first_tail_x6_r0_body.st17.s2.next
noncomputable def PRE_first_tail_x6_r0_body.st17.wr : List Nat := PRE_first_tail_x6_r0_body.st17.wrE.map (·.1)

kernel_rfl PRE_first_tail_x6_r0_body.st17.heapFoot : PRE_first_tail_x6_r0_body.st17.s2.heap = setAll PRE_first_tail_x6_r0_body.st17.s0.heap PRE_first_tail_x6_r0_body.st17.wrE
kernel_rfl PRE_first_tail_x6_r0_body.st17.grows_check : Nat.ble PRE_first_tail_x6_r0_body.st17.s0.next PRE_first_tail_x6_r0_body.st17.s2.next = true
theorem PRE_first_tail_x6_r0_body.st17.grows : PRE_first_tail_x6_r0_body.st17.s0.next ≤ PRE_first_tail_x6_r0_body.st17.s2.next := Nat.le_of_ble_eq_true PRE_first_tail_x6_r0_body.st17.grows_check

/-- The written and fresh handles; the written readback items of old nodes. -/
def PRE_first_tail_x6_r0_body.st17.wh : List Nat := []
def PRE_first_tail_x6_r0_body.st17.wi : List Nat := []

kernel_rfl PRE_first_tail_x6_r0_body.st17.arrsFoot : (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.st17.s2.ffi).mlx.arrs = setAll (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.st17.s0.ffi).mlx.arrs (PRE_first_tail_x6_r0_body.st17.wh.filterMap fun h => ((Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.st17.s2.ffi).mlx.arrs.get h).map (h, ·))
kernel_rfl PRE_first_tail_x6_r0_body.st17.objsFoot : (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.st17.s2.ffi).mlx.objs = setAll (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.st17.s0.ffi).mlx.objs (PRE_first_tail_x6_r0_body.st17.wh.filterMap fun h => ((Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.st17.s2.ffi).mlx.objs.get h).map (h, ·))
kernel_rfl PRE_first_tail_x6_r0_body.st17.nodesFoot : (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.st17.s2.ffi).mlx.nodes = setAll (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.st17.s0.ffi).mlx.nodes (freshOf (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.st17.s2.ffi).mlx.nodes (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.st17.s0.ffi).mlx.nnext (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.st17.s2.ffi).mlx.nnext)
kernel_rfl PRE_first_tail_x6_r0_body.st17.itemsFoot : (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.st17.s2.ffi).mlx.items = setAll (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.st17.s0.ffi).mlx.items ((PRE_first_tail_x6_r0_body.st17.wi.filterMap fun i => ((Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.st17.s2.ffi).mlx.items.get i).map (i, ·)) ++
    freshOf (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.st17.s2.ffi).mlx.items (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.st17.s0.ffi).mlx.nnext (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.st17.s2.ffi).mlx.nnext)
kernel_rfl PRE_first_tail_x6_r0_body.st17.counters : (Nat.ble (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.st17.s0.ffi).mlx.next (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.st17.s2.ffi).mlx.next && Nat.ble (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.st17.s0.ffi).mlx.nnext (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.st17.s2.ffi).mlx.nnext) = true

end Host.Load.Run.Tpl
end

section -- SiteF17
set_option Elab.async false
namespace Host.Load.Run.Tpl
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
open Host.Ts Host.Ts.Sim Host.Ts.Sim.Template

/-! Call site 17 of chain `PRE_first_tail_x6_r0_body`: `Conv.site_merge`'s footprint facts. -/

kernel_rfl PRE_first_tail_x6_r0_body.wrNodupB17 : nodupT PRE_first_tail_x6_r0_body.st17.wr PTrie.nil = true
theorem PRE_first_tail_x6_r0_body.wrNodup17 : PRE_first_tail_x6_r0_body.st17.wr.Nodup := (nodupT_sound PRE_first_tail_x6_r0_body.wrNodupB17).2
kernel_rfl PRE_first_tail_x6_r0_body.wrBoundB17 : PRE_first_tail_x6_r0_body.st17.wr.all (fun b => Nat.blt (b / 4096) (4 ^ 31)) = true
theorem PRE_first_tail_x6_r0_body.wrBound17 : ∀ b ∈ PRE_first_tail_x6_r0_body.st17.wr, b / 4096 < 4 ^ 31 := fun b hb => Nat.blt_eq.mp (List.all_eq_true.mp PRE_first_tail_x6_r0_body.wrBoundB17 b hb)
noncomputable def PRE_first_tail_x6_r0_body.trFr17 := PRE_first_tail_x6_r0_body.st17.s2.trace.take 0
kernel_rfl PRE_first_tail_x6_r0_body.traceEq17 : PRE_first_tail_x6_r0_body.st17.s2.trace = PRE_first_tail_x6_r0_body.trFr17 ++ PRE_first_tail_x6_r0_body.st17.s0.trace
theorem PRE_first_tail_x6_r0_body.trace17 : ∃ fr, PRE_first_tail_x6_r0_body.st17.s2.trace = fr ++ PRE_first_tail_x6_r0_body.st17.s0.trace := ⟨_, PRE_first_tail_x6_r0_body.traceEq17⟩

-- the caller's wide frames at the instance's start (`Conv.isolateW`'s `W0` under `Map.id`) and their `WFix`
def PRE_first_tail_x6_r0_body.wide17 : List (Nat × WFrame) := [(4910, .memo [])]
kernel_rfl PRE_first_tail_x6_r0_body.wfixB17 : (PRE_first_tail_x6_r0_body.wide17.all fun p => wfixB Map.id (presentB PRE_first_tail_x6_r0_body.st17.s0) p.2) = true
theorem PRE_first_tail_x6_r0_body.wfix17 : ∀ p ∈ PRE_first_tail_x6_r0_body.wide17, WFix Map.id (Present PRE_first_tail_x6_r0_body.st17.s0) p.2 :=
  fun p hp => wfix_of (List.all_eq_true.mp PRE_first_tail_x6_r0_body.wfixB17 p hp)

end Host.Load.Run.Tpl
end

section -- SiteL17
set_option Elab.async false
namespace Host.Load.Run.Tpl
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
open Host.Ts Host.Ts.Sim Host.Ts.Sim.Template

/-! The call link's facts at call site 17 of chain `PRE_first_tail_x6_r0_body`: the instance's start server, its footprint (`Conv.StageFoot`), the
merged state `PRE_first_tail_x6_r0_body.s173`'s framed arrays as the chain start's extended (`arrExt_of`, `numRefs_of`). -/

kernel_rfl PRE_first_tail_x6_r0_body.srvO17 : PRE_first_tail_x6_r0_body.st17.S0.oracle = PRE_first_tail_x6_r0_body.st17.OR
kernel_rfl PRE_first_tail_x6_r0_body.wr0B17 : PRE_first_tail_x6_r0_body.st17.wr.all (fun b => !Nat.blt b PRE_first_tail_x6_r0_body.st17.s0.next || (PRE_first_tail_x6_r0_body.st17.s0.heap.get b).isSome) = true
theorem PRE_first_tail_x6_r0_body.stFoot17 : Conv.StageFoot PRE_first_tail_x6_r0_body.st17.wr PRE_first_tail_x6_r0_body.st17.s0 PRE_first_tail_x6_r0_body.st17.s2 :=
  stageFoot_of PRE_first_tail_x6_r0_body.st17.heapFoot PRE_first_tail_x6_r0_body.wrNodup17 PRE_first_tail_x6_r0_body.wrBound17 PRE_first_tail_x6_r0_body.wr0B17 PRE_first_tail_x6_r0_body.st17.grows

/-- **The relation at the merged state** from the relation at the merge (`Conv.site_merge`'s; `merged_relB`). -/
theorem PRE_first_tail_x6_r0_body.merged17 {FR : Map → Nat → PRE_first_tail_x6_r0_body.st17.F.S → PRE_first_tail_x6_r0_body.st17.F.S → Prop} {W : Nat → Option WFrame} {stk : List Frame} {M : Map}
    {ν : Nat → F64} {K : Host.Ts.Sim.Ctx} {S : SSrv} {t : St PRE_first_tail_x6_r0_body.st17.F.S} {C : CSrv} {n0 : Nat}
    (h : RelB PRE_first_tail_x6_r0_body.st17.F FR W stk M ν K (Conv.mergeSt Map.id (Map.id.res n0 n0) PRE_first_tail_x6_r0_body.rs17 PRE_first_tail_x6_r0_body.st17.wr PRE_first_tail_x6_r0_body.s172 PRE_first_tail_x6_r0_body.st17.s2 PRE_first_tail_x6_r0_body.st17.s0
      PRE_first_tail_x6_r0_body.st17.s2.ffi) S t C) : RelB PRE_first_tail_x6_r0_body.st17.F FR W stk M ν K PRE_first_tail_x6_r0_body.s173 S t C :=
  merged_relB PRE_first_tail_x6_r0_body.iso17 PRE_first_tail_x6_r0_body.stFoot17 PRE_first_tail_x6_r0_body.wrNodup17 PRE_first_tail_x6_r0_body.wrBound17 PRE_first_tail_x6_r0_body.trace17 PRE_first_tail_x6_r0_body.mheap17
    PRE_first_tail_x6_r0_body.mnext17 PRE_first_tail_x6_r0_body.mctl17 PRE_first_tail_x6_r0_body.mstack17 PRE_first_tail_x6_r0_body.mjobs17 PRE_first_tail_x6_r0_body.mffi17 PRE_first_tail_x6_r0_body.mtrace17 PRE_first_tail_x6_r0_body.mstores17 h

def PRE_first_tail_x6_r0_body.arrEl17_2665 : List Val := []
kernel_rfl PRE_first_tail_x6_r0_body.arrE17_2665 : arrOf PRE_first_tail_x6_r0_body.s173 2665 = arrOf PRE_first_tail_x6_r0_body.s0 2665 ++ PRE_first_tail_x6_r0_body.arrEl17_2665
kernel_rfl PRE_first_tail_x6_r0_body.arrA17_2665 : isArrB PRE_first_tail_x6_r0_body.s173 2665 = true
theorem PRE_first_tail_x6_r0_body.arr17_2665 : ∃ o, PRE_first_tail_x6_r0_body.s173.heap.get 2665 = some (.obj o) ∧ o.kind = .array (arrOf PRE_first_tail_x6_r0_body.s0 2665 ++ PRE_first_tail_x6_r0_body.arrEl17_2665) :=
  arrExt_of PRE_first_tail_x6_r0_body.arrE17_2665 PRE_first_tail_x6_r0_body.arrA17_2665
kernel_rfl PRE_first_tail_x6_r0_body.arrN17_2665 : numRefsB PRE_first_tail_x6_r0_body.S0.tab.length PRE_first_tail_x6_r0_body.arrEl17_2665 = true
theorem PRE_first_tail_x6_r0_body.arrR17_2665 : Prefill.NumRefs PRE_first_tail_x6_r0_body.S0.tab.length PRE_first_tail_x6_r0_body.arrEl17_2665 := numRefs_of PRE_first_tail_x6_r0_body.arrN17_2665

def PRE_first_tail_x6_r0_body.arrEl17_2673467 : List Val := []
kernel_rfl PRE_first_tail_x6_r0_body.arrE17_2673467 : arrOf PRE_first_tail_x6_r0_body.s173 2673467 = arrOf PRE_first_tail_x6_r0_body.s0 2673467 ++ PRE_first_tail_x6_r0_body.arrEl17_2673467
kernel_rfl PRE_first_tail_x6_r0_body.arrA17_2673467 : isArrB PRE_first_tail_x6_r0_body.s173 2673467 = true
theorem PRE_first_tail_x6_r0_body.arr17_2673467 : ∃ o, PRE_first_tail_x6_r0_body.s173.heap.get 2673467 = some (.obj o) ∧ o.kind = .array (arrOf PRE_first_tail_x6_r0_body.s0 2673467 ++ PRE_first_tail_x6_r0_body.arrEl17_2673467) :=
  arrExt_of PRE_first_tail_x6_r0_body.arrE17_2673467 PRE_first_tail_x6_r0_body.arrA17_2673467
kernel_rfl PRE_first_tail_x6_r0_body.arrN17_2673467 : numRefsB PRE_first_tail_x6_r0_body.S0.tab.length PRE_first_tail_x6_r0_body.arrEl17_2673467 = true
theorem PRE_first_tail_x6_r0_body.arrR17_2673467 : Prefill.NumRefs PRE_first_tail_x6_r0_body.S0.tab.length PRE_first_tail_x6_r0_body.arrEl17_2673467 := numRefs_of PRE_first_tail_x6_r0_body.arrN17_2673467

kernel_rfl PRE_first_tail_x6_r0_body.w4910k17 : isArrB PRE_first_tail_x6_r0_body.s173 4910 = false
theorem PRE_first_tail_x6_r0_body.keep17 (q : List Val) : Host.Ts.Sim.Prefill.KeepsAtW (framesP PRE_first_tail_x6_r0_body.s0 q) PRE_first_tail_x6_r0_body.s173 := by
  intro a pre pre' hx o es ho hk
  unfold framesP at hx
  simp only at hx
  cases h1 : Nat.beq a 2665
  · cases h2 : Nat.beq a 4910
    · rw [h1, h2] at hx; cases hx
    · have := Nat.eq_of_beq_eq_true h2; subst this
      rw [h1, h2] at hx; cases hx
      exact (notArr_of PRE_first_tail_x6_r0_body.w4910k17 ho hk).elim
  · have := Nat.eq_of_beq_eq_true h1; subst this
    rw [h1] at hx; cases hx
    obtain ⟨o', ho', hk'⟩ := PRE_first_tail_x6_r0_body.arr17_2665
    rw [ho] at ho'; cases ho'
    rw [hk'] at hk; cases hk
    simp [PRE_first_tail_x6_r0_body.arrEl17_2665]

end Host.Load.Run.Tpl
end

section -- SiteZ17
set_option Elab.async false
namespace Host.Load.Run.Tpl
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
open Host.Ts Host.Ts.Sim Host.Ts.Sim.Template

/-! The compaction's state shift at call site 17 of chain `PRE_first_tail_x6_r0_body` (`Conv.compact_shift`): the call `PRE_first_tail_x6_r0_body.s172`, the merged
state `PRE_first_tail_x6_r0_body.s173`, the canonical state `PRE_first_tail_x6_r0_body.s174`; its frames [2665,2673467,2673472,2673473] (kept arrays [2665,2673467]). -/

-- the map's places and counters
kernel_rfl PRE_first_tail_x6_r0_body.zpl17 : PRE_first_tail_x6_r0_body.pl17.all (Nat.ble PRE_first_tail_x6_r0_body.s172.next) = true
kernel_rfl PRE_first_tail_x6_r0_body.zplnd17 : nodupT PRE_first_tail_x6_r0_body.pl17 PTrie.nil = true
kernel_rfl PRE_first_tail_x6_r0_body.zn117 : Nat.ble PRE_first_tail_x6_r0_body.s172.next 2687926 = true
kernel_rfl PRE_first_tail_x6_r0_body.zfirst17 : Nat.ble aFirst PRE_first_tail_x6_r0_body.s172.next = true
kernel_rfl PRE_first_tail_x6_r0_body.zscn17 : PRE_first_tail_x6_r0_body.s174.next = PRE_first_tail_x6_r0_body.s172.next + PRE_first_tail_x6_r0_body.pl17.length
kernel_rfl PRE_first_tail_x6_r0_body.zsmn17 : PRE_first_tail_x6_r0_body.s173.next = 2687926
kernel_rfl PRE_first_tail_x6_r0_body.zgrow17 : Nat.ble PRE_first_tail_x6_r0_body.s174.next PRE_first_tail_x6_r0_body.s173.next = true
-- the tables
kernel_rfl PRE_first_tail_x6_r0_body.zfresh17 : PRE_first_tail_x6_r0_body.S172.tab.all (fun e => PRE_first_tail_x6_r0_body.cws17.all fun v => e.noVar v) = true
kernel_rfl PRE_first_tail_x6_r0_body.zcnd17 : nodupT PRE_first_tail_x6_r0_body.cws17 PTrie.nil = true
kernel_rfl PRE_first_tail_x6_r0_body.znrHi17 : PRE_first_tail_x6_r0_body.nr17.all (fun r => Nat.blt r PRE_first_tail_x6_r0_body.S173.tab.length) = true
-- the frames: every framed address below the call's counter; the kept arrays the chain start's, extended in the merged state
kernel_rfl PRE_first_tail_x6_r0_body.zfrlt17 : [2665, 2673467, 2673472, 2673473].all (fun a => Nat.blt a PRE_first_tail_x6_r0_body.s172.next) = true
kernel_rfl PRE_first_tail_x6_r0_body.zg17_2665 : PRE_first_tail_x6_r0_body.s174.heap.get 2665 = some (.obj (objOf PRE_first_tail_x6_r0_body.s174 2665))
kernel_rfl PRE_first_tail_x6_r0_body.zk17_2665 : (objOf PRE_first_tail_x6_r0_body.s174 2665).kind = .array (arrOf PRE_first_tail_x6_r0_body.s0 2665)
kernel_rfl PRE_first_tail_x6_r0_body.zm17_2665 : PRE_first_tail_x6_r0_body.s173.heap.get 2665 = some (.obj { PRE_first_tail_x6_r0_body.kappa17.obj (objOf PRE_first_tail_x6_r0_body.s174 2665) with
  kind := .array (arrOf PRE_first_tail_x6_r0_body.s0 2665 ++ (arrOf PRE_first_tail_x6_r0_body.s173 2665).drop (arrOf PRE_first_tail_x6_r0_body.s0 2665).length) })
kernel_rfl PRE_first_tail_x6_r0_body.zg17_2673467 : PRE_first_tail_x6_r0_body.s174.heap.get 2673467 = some (.obj (objOf PRE_first_tail_x6_r0_body.s174 2673467))
kernel_rfl PRE_first_tail_x6_r0_body.zk17_2673467 : (objOf PRE_first_tail_x6_r0_body.s174 2673467).kind = .array (arrOf PRE_first_tail_x6_r0_body.s0 2673467)
kernel_rfl PRE_first_tail_x6_r0_body.zm17_2673467 : PRE_first_tail_x6_r0_body.s173.heap.get 2673467 = some (.obj { PRE_first_tail_x6_r0_body.kappa17.obj (objOf PRE_first_tail_x6_r0_body.s174 2673467) with
  kind := .array (arrOf PRE_first_tail_x6_r0_body.s0 2673467 ++ (arrOf PRE_first_tail_x6_r0_body.s173 2673467).drop (arrOf PRE_first_tail_x6_r0_body.s0 2673467).length) })
kernel_rfl PRE_first_tail_x6_r0_body.zw17_4910 : (PRE_first_tail_x6_r0_body.s174.heap.get 4910).isSome = true
kernel_rfl PRE_first_tail_x6_r0_body.zw17_2673472 : (PRE_first_tail_x6_r0_body.s174.heap.get 2673472).isSome = true
kernel_rfl PRE_first_tail_x6_r0_body.zw17_2673473 : (PRE_first_tail_x6_r0_body.s174.heap.get 2673473).isSome = true
-- the heap: the changed list in range, holding the stage's written and fresh addresses; the canonical side's image
kernel_rfl PRE_first_tail_x6_r0_body.zclbd17 : PRE_first_tail_x6_r0_body.cl17.all (fun b => Nat.blt (b / 4096) (4 ^ 31)) = true
kernel_rfl PRE_first_tail_x6_r0_body.zwr17 : PRE_first_tail_x6_r0_body.st17.wr.all (fun b => !Nat.blt b PRE_first_tail_x6_r0_body.s172.next || PRE_first_tail_x6_r0_body.cl17.contains b) = true
def PRE_first_tail_x6_r0_body.zl17 : List Nat := PRE_first_tail_x6_r0_body.cl17.filter fun a => !(List.contains [2665, 2673467] a)
kernel_rfl PRE_first_tail_x6_r0_body.zimgE17 : PRE_first_tail_x6_r0_body.zl17.map (fun a => PRE_first_tail_x6_r0_body.s173.heap.get (PRE_first_tail_x6_r0_body.kappa17.a a)) = PRE_first_tail_x6_r0_body.zl17.map (fun a => (PRE_first_tail_x6_r0_body.s174.heap.get a).map PRE_first_tail_x6_r0_body.kappa17.hobj)
theorem PRE_first_tail_x6_r0_body.zimg17 : HeapImg PRE_first_tail_x6_r0_body.kappa17 PRE_first_tail_x6_r0_body.s174 PRE_first_tail_x6_r0_body.s173 PRE_first_tail_x6_r0_body.zl17 := PRE_first_tail_x6_r0_body.zimgE17
-- the roots and their supports
kernel_rfl PRE_first_tail_x6_r0_body.zctl17 : PRE_first_tail_x6_r0_body.s173.ctl = PRE_first_tail_x6_r0_body.kappa17.ctl PRE_first_tail_x6_r0_body.s174.ctl
kernel_rfl PRE_first_tail_x6_r0_body.zstack17 : PRE_first_tail_x6_r0_body.s173.stack = PRE_first_tail_x6_r0_body.s174.stack.map PRE_first_tail_x6_r0_body.kappa17.frame
kernel_rfl PRE_first_tail_x6_r0_body.zjobs17 : PRE_first_tail_x6_r0_body.s173.jobs = PRE_first_tail_x6_r0_body.s174.jobs.map PRE_first_tail_x6_r0_body.kappa17.job
kernel_rfl PRE_first_tail_x6_r0_body.zstores17 : PRE_first_tail_x6_r0_body.s173.stores = PRE_first_tail_x6_r0_body.kappa17.stores PRE_first_tail_x6_r0_body.s174.stores
kernel_rfl PRE_first_tail_x6_r0_body.zroots17 : checkRootsSupp PRE_first_tail_x6_r0_body.s174 781 = true
kernel_rfl PRE_first_tail_x6_r0_body.znC17 : PRE_first_tail_x6_r0_body.S172.tab.length + PRE_first_tail_x6_r0_body.cws17.length = 781
-- the map as `Conv.compact_shift` states it (the call's counters for the literals)
kernel_rfl PRE_first_tail_x6_r0_body.zkap17 : PRE_first_tail_x6_r0_body.kappa17 = Conv.Map.compact PRE_first_tail_x6_r0_body.s172.next 2687926 PRE_first_tail_x6_r0_body.S172.tab.length PRE_first_tail_x6_r0_body.pl17 (PRE_first_tail_x6_r0_body.nr17.map NumV.ref) PRE_first_tail_x6_r0_body.kd17.big
  PRE_first_tail_x6_r0_body.kd17.region PRE_first_tail_x6_r0_body.kd17.nodeF
-- the bridge inactive at the canonical state (`Conv.FullShiftQ.toX`; the merged state's bridge is the canonical's: cbridge)
theorem PRE_first_tail_x6_r0_body.zbin17 : (Host.Ts.Sim.Full.bridgeOf PRE_first_tail_x6_r0_body.s174.ffi).active = false := (Host.Load.Boot.replay_active Host.Load.Run.Prompt.P.oblog2818)
-- the JS bookkeeping's step (`Conv.JClean.step` over the changed list) and the canonical roots' bigint freedom
kernel_rfl PRE_first_tail_x6_r0_body.zjc17 : Conv.jcleanListB (⟨18532, 15622, 2687916, 781⟩ : Conv.Cnt) PRE_first_tail_x6_r0_body.s174 PRE_first_tail_x6_r0_body.cl17 = true
kernel_rfl PRE_first_tail_x6_r0_body.zrootsB17 : noBigRootsP (fun i => !Conv.oldBigB (⟨18532, 15622, 2687916, 781⟩ : Conv.Cnt) i) PRE_first_tail_x6_r0_body.s174.trace PRE_first_tail_x6_r0_body.s174 = true
kernel_rfl PRE_first_tail_x6_r0_body.zhm17 : Nat.ble (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.s0.ffi).mlx.nnext 15622 = true
theorem PRE_first_tail_x6_r0_body.cjcl17 (h : Conv.JClean (⟨18532, 15622, 2687915, 781⟩ : Conv.Cnt) PRE_first_tail_x6_r0_body.s172) : Conv.JClean (⟨18532, 15622, 2687916, 781⟩ : Conv.Cnt) PRE_first_tail_x6_r0_body.s174 :=
  Conv.JClean.step h (Conv.Cnt.le_of_leB PRE_first_tail_x6_r0_body.cle17)
    (Conv.heap_off_setAll PRE_first_tail_x6_r0_body.cheap17 fun a ha => Nat.blt_eq.mp (List.all_eq_true.mp PRE_first_tail_x6_r0_body.zclbd17 a ha)) PRE_first_tail_x6_r0_body.zjc17

end Host.Load.Run.Tpl
end

section -- st17/TypedLast
set_option Elab.async false
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
namespace Host.Load.Run.Tpl
open Host.Ts Host.Ts.Sim Host.Ts.Sim.Template

boot_rfl PRE_first_tail_x6_r0_body.st17.bodyLast from PRE_first_tail_x6_r0_body.st17.s1 to PRE_first_tail_x6_r0_body.st17.s2 :
  interpS (step PRE_first_tail_x6_r0_body.st17.F PRE_first_tail_x6_r0_body.st17.s1).run PRE_first_tail_x6_r0_body.st17.S1 = some (PRE_first_tail_x6_r0_body.st17.s2, PRE_first_tail_x6_r0_body.st17.S2)
kernel_rfl PRE_first_tail_x6_r0_body.st17.bodyHalt : isHalt PRE_first_tail_x6_r0_body.st17.s1.ctl = false
kernel_rfl PRE_first_tail_x6_r0_body.st17.bodyTopCheck : noBlockTop PRE_first_tail_x6_r0_body.st17.s2.stack = true

end Host.Load.Run.Tpl
end

section -- st17/TypedOk
set_option Elab.async false
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
namespace Host.Load.Run.Tpl
open Host.Ts Host.Ts.Sim Host.Ts.Sim.Template

noncomputable def PRE_first_tail_x6_r0_body.st17.bodyOkL (bytes : List Byte) (rows : Nat) : St PRE_first_tail_x6_r0_body.st17.F.S → SSrv → Bool :=
  okLocal (Host.Ts.Sim.Compose.VWFrames.bodyOk bytes rows)

noncomputable def PRE_first_tail_x6_r0_body.st17.bodyOkLN (bytes : List Byte) (rows : Nat) : St PRE_first_tail_x6_r0_body.st17.F.S → FSrv → Bool :=
  okLocalN (Host.Ts.Sim.Compose.VWFrames.bodyOkN bytes rows)

theorem PRE_first_tail_x6_r0_body.st17.bodyOkLN_ok (bytes : List Byte) (rows : Nat) (s : St PRE_first_tail_x6_r0_body.st17.F.S) (c : FSrv) (h : c.Wf) :
    PRE_first_tail_x6_r0_body.st17.bodyOkLN bytes rows s c = PRE_first_tail_x6_r0_body.st17.bodyOkL bytes rows s c.toS :=
  okLocalN_ok (Host.Ts.Sim.Compose.VWFrames.bodyOkN_ok bytes rows) s c h

kernel_rfl PRE_first_tail_x6_r0_body.st17.bodyAccepted0 :
  (fun (bytes : List Byte) (rows : Nat) => PRE_first_tail_x6_r0_body.st17.bodyOkL bytes rows PRE_first_tail_x6_r0_body.st17.s0 PRE_first_tail_x6_r0_body.st17.S0) = fun _ _ => true

kernel_rfl PRE_first_tail_x6_r0_body.st17.bodyAccepted1 :
  (fun (bytes : List Byte) (rows : Nat) => PRE_first_tail_x6_r0_body.st17.bodyOkL bytes rows PRE_first_tail_x6_r0_body.st17.s1 PRE_first_tail_x6_r0_body.st17.S1) = fun _ _ => true

end Host.Load.Run.Tpl
end

section -- st17/TypedK0
set_option Elab.async false
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
namespace Host.Load.Run.Tpl
open Host.Ts Host.Ts.Sim Host.Ts.Sim.Template

boot_rfl PRE_first_tail_x6_r0_body.st17.bodyK0F from PRE_first_tail_x6_r0_body.st17.s0 to PRE_first_tail_x6_r0_body.st17.s1 :
  (fun (bytes : List Byte) (rows : Nat) => runOkS PRE_first_tail_x6_r0_body.st17.F (PRE_first_tail_x6_r0_body.st17.bodyOkLN bytes rows)
    ((nth? PRE_first_tail_x6_r0_body.st17.ks 0).getD 0) PRE_first_tail_x6_r0_body.st17.s0 PRE_first_tail_x6_r0_body.st17.S0) = fun _ _ => some (PRE_first_tail_x6_r0_body.st17.s1, PRE_first_tail_x6_r0_body.st17.S1)
theorem PRE_first_tail_x6_r0_body.st17.bodyK0 :
  (fun (bytes : List Byte) (rows : Nat) => runOk PRE_first_tail_x6_r0_body.st17.F (PRE_first_tail_x6_r0_body.st17.bodyOkL bytes rows)
    ((nth? PRE_first_tail_x6_r0_body.st17.ks 0).getD 0) PRE_first_tail_x6_r0_body.st17.s0 PRE_first_tail_x6_r0_body.st17.S0) = fun _ _ => some (PRE_first_tail_x6_r0_body.st17.s1, PRE_first_tail_x6_r0_body.st17.S1) :=
  runOk_fun_of_runOkS PRE_first_tail_x6_r0_body.st17.bodyOkLN_ok PRE_first_tail_x6_r0_body.st17.bodyK0F
end Host.Load.Run.Tpl
end

section -- st17/TypedTpl
set_option Elab.async false
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
namespace Host.Load.Run.Tpl
open Host.Ts Host.Ts.Sim Host.Ts.Sim.Template

theorem PRE_first_tail_x6_r0_body.st17.bodyRun (bytes : List Byte) (rows : Nat) :
    runOk PRE_first_tail_x6_r0_body.st17.F (PRE_first_tail_x6_r0_body.st17.bodyOkL bytes rows) 98 PRE_first_tail_x6_r0_body.st17.s0 PRE_first_tail_x6_r0_body.st17.S0 = some (PRE_first_tail_x6_r0_body.st17.s1, PRE_first_tail_x6_r0_body.st17.S1) :=
  (congrFun (congrFun PRE_first_tail_x6_r0_body.st17.bodyK0 bytes) rows)

theorem PRE_first_tail_x6_r0_body.st17.bodyLocal (bytes : List Byte) (rows : Nat) : ∀ s S, PRE_first_tail_x6_r0_body.st17.bodyOkL bytes rows s S = true → Disp.localB s = true := okLocal_localB

noncomputable def PRE_first_tail_x6_r0_body.st17.bodyTpl (bytes : List Byte) (rows : Nat) : Host.Ts.Sim.Stage.StageTpl PRE_first_tail_x6_r0_body.st17.F (PRE_first_tail_x6_r0_body.st17.bodyOkL bytes rows) where
  s0 := PRE_first_tail_x6_r0_body.st17.s0
  S0 := PRE_first_tail_x6_r0_body.st17.S0
  s1 := PRE_first_tail_x6_r0_body.st17.s1
  S1 := PRE_first_tail_x6_r0_body.st17.S1
  s2 := PRE_first_tail_x6_r0_body.st17.s2
  S2 := PRE_first_tail_x6_r0_body.st17.S2
  n := 98
  ok0 := congrFun (congrFun PRE_first_tail_x6_r0_body.st17.bodyAccepted0 bytes) rows
  run := PRE_first_tail_x6_r0_body.st17.bodyRun bytes rows
  ok1 := congrFun (congrFun PRE_first_tail_x6_r0_body.st17.bodyAccepted1 bytes) rows
  halt := PRE_first_tail_x6_r0_body.st17.bodyHalt
  last := PRE_first_tail_x6_r0_body.st17.bodyLast
  top := noBlockTop_sound PRE_first_tail_x6_r0_body.st17.bodyTopCheck
end Host.Load.Run.Tpl
end

section -- SiteC18
set_option Elab.async false
namespace Host.Load.Run.Tpl
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
open Host.Ts Host.Ts.Sim Host.Ts.Sim.Template

/-! The compaction after the merge at call site 18 of chain `PRE_first_tail_x6_r0_body` (`Conv.compact`, `Conv.full_compactQ`): the canonical
state `PRE_first_tail_x6_r0_body.s191` (the stage's results at canonical places, its trace the call's) under `PRE_first_tail_x6_r0_body.kappa18` into the merged state
`PRE_first_tail_x6_r0_body.s190`. -/

def PRE_first_tail_x6_r0_body.pl18 : List Nat := [2690499, 2689674, 2690505, 2690501, 2689676, 2690507]
def PRE_first_tail_x6_r0_body.nr18 : List Nat := [884, 883, 859, 867, 872, 877, 882, 856, 857, 858, 865, 866, 854, 861, 862, 863, 864, 860]
/-- The native part of the compaction map (canonical → merged handles and nodes: its `big`, `region`, `nodeF`). -/
def PRE_first_tail_x6_r0_body.kd18 : RData :=
  ⟨2689393, 2690542, Stage.setAll PTrie.nil [(2689387, 2690499), (2689388, 2689674), (2689389, 2690505), (2689390, 2690501), (2689391, 2689676), (2689392, 2690507)], Stage.setAll PTrie.nil [(18566, 18592), (18567, 18570), (18568, 18593)],
   18569, 18594, 15668, 15668, Stage.setAll PTrie.nil [],
   Stage.setAll PTrie.nil [(854, .ref 884), (855, .ref 883), (856, .ref 859), (857, .ref 867), (858, .ref 872), (859, .ref 877), (860, .ref 882), (861, .ref 856), (862, .ref 857), (863, .ref 858), (864, .ref 865), (865, .ref 866), (866, .ref 854), (867, .ref 861), (868, .ref 862), (869, .ref 863), (870, .ref 864), (871, .ref 860)]⟩
/-- **The compaction map.** -/
noncomputable def PRE_first_tail_x6_r0_body.kappa18 : Map :=
  Conv.Map.compact 2689387 2690542 854 PRE_first_tail_x6_r0_body.pl18 (PRE_first_tail_x6_r0_body.nr18.map NumV.ref) PRE_first_tail_x6_r0_body.kd18.big
    PRE_first_tail_x6_r0_body.kd18.region PRE_first_tail_x6_r0_body.kd18.nodeF
/-- The canonical result variables and their images, the merged state's entries (`Conv.compactθ`). -/
def PRE_first_tail_x6_r0_body.cws18 : List Nat := [1338, 1339, 1340, 1341, 1342, 1343, 1344, 1345, 1346, 1347, 1348, 1349, 1350, 1351, 1352, 1353, 1354, 1355]
noncomputable def PRE_first_tail_x6_r0_body.crs18 : List SymE := PRE_first_tail_x6_r0_body.nr18.map fun r => (nth? PRE_first_tail_x6_r0_body.S190.tab r).getD (.var 0)
noncomputable def PRE_first_tail_x6_r0_body.ctheta18 : Nat → SymE := Conv.compactθ PRE_first_tail_x6_r0_body.cws18 PRE_first_tail_x6_r0_body.crs18
/-- The call's entries the stage wrote (renamed in the canonical state with the results). -/
def PRE_first_tail_x6_r0_body.wrB18 : List Nat := [2665, 2672341, 2673467, 2688561, 2689106, 2689362]

kernel_rfl PRE_first_tail_x6_r0_body.ctab18 : PRE_first_tail_x6_r0_body.S191.tab = PRE_first_tail_x6_r0_body.S189.tab ++ PRE_first_tail_x6_r0_body.cws18.map SymE.var
kernel_rfl PRE_first_tail_x6_r0_body.ctrace18 : PRE_first_tail_x6_r0_body.s191.trace = PRE_first_tail_x6_r0_body.s189.trace
kernel_rfl PRE_first_tail_x6_r0_body.cnext18 : PRE_first_tail_x6_r0_body.s191.next = 2689393
kernel_rfl PRE_first_tail_x6_r0_body.ccounters18 : ((Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.s191.ffi).mlx.next, (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.s191.ffi).mlx.nnext) = (18569, 15668)
-- the merged state's readback queue, carried to the canonical state (`Conv.FullShiftQ.tokens`, `tokSupp`)
kernel_rfl PRE_first_tail_x6_r0_body.cqueue18 : (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.s190.ffi).mlx.tokens = (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.s191.ffi).mlx.tokens.map PRE_first_tail_x6_r0_body.kappa18.nv
kernel_rfl PRE_first_tail_x6_r0_body.ctokSupp18 : (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.s191.ffi).mlx.tokens.all (bSN 872) = true
-- the written and the result entries carry no bigint of the canonical fresh band [next, E) and no fresh region
kernel_rfl PRE_first_tail_x6_r0_body.cclean18 : Conv.cleanListB 18569 131072 (fun r => Nat.ble 74276 r) PRE_first_tail_x6_r0_body.s191
    (PRE_first_tail_x6_r0_body.wrB18 ++ (List.range 6).map (2689387 + ·)) = true
kernel_rfl PRE_first_tail_x6_r0_body.cbigs18 : bigsOutB 18569 131072 (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.s191.ffi).mlx = true

end Host.Load.Run.Tpl
end

section -- SiteK18
set_option Elab.async false
namespace Host.Load.Run.Tpl
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
open Host.Ts Host.Ts.Sim Host.Ts.Sim.Template

/-! The canonical state's closedness from the call's (`Conv.closed_of_callB`, `Conv.sst_of_callB`): it keeps the call's entries
off the written and the result ones (`PRE_first_tail_x6_r0_body.cl18`; natively the written and result handles, the result nodes, the written
and result items), and those are checked. -/

def PRE_first_tail_x6_r0_body.cl18 : List Nat := [2665, 2672341, 2673467, 2688561, 2689106, 2689362, 2689387, 2689388, 2689389, 2689390, 2689391, 2689392]
def PRE_first_tail_x6_r0_body.clo18 : List Nat := [18546, 18559, 18565, 18566, 18567, 18568]
def PRE_first_tail_x6_r0_body.cln18 : List Nat := [15641, 15642, 15643, 15644, 15645, 15646, 15647, 15648, 15649, 15650, 15651, 15652, 15653, 15654, 15655, 15656, 15657, 15658, 15659, 15660, 15661, 15662, 15663, 15664, 15665, 15666, 15667]
def PRE_first_tail_x6_r0_body.cli18 : List Nat := [15641, 15642, 15643, 15644, 15645, 15646, 15647, 15648, 15649, 15650, 15651, 15652, 15653, 15654, 15655, 15656, 15657, 15658, 15659, 15660, 15661, 15662, 15663, 15664, 15665, 15666, 15667]
kernel_rfl PRE_first_tail_x6_r0_body.cheap18 : PRE_first_tail_x6_r0_body.s191.heap = Stage.setAll PRE_first_tail_x6_r0_body.s189.heap (PRE_first_tail_x6_r0_body.cl18.filterMap fun a => (PRE_first_tail_x6_r0_body.s191.heap.get a).map (a, ·))
kernel_rfl PRE_first_tail_x6_r0_body.cnextLe18 : Nat.ble PRE_first_tail_x6_r0_body.s189.next PRE_first_tail_x6_r0_body.s191.next = true
kernel_rfl PRE_first_tail_x6_r0_body.ckeepP18 : Conv.keptPresentB PRE_first_tail_x6_r0_body.s189 PRE_first_tail_x6_r0_body.s191 PRE_first_tail_x6_r0_body.cl18 = true
kernel_rfl PRE_first_tail_x6_r0_body.csupp18 : Conv.suppListB PRE_first_tail_x6_r0_body.s191 872 PRE_first_tail_x6_r0_body.cl18 = true
kernel_rfl PRE_first_tail_x6_r0_body.cbound18 : Conv.boundListB PRE_first_tail_x6_r0_body.s191 PRE_first_tail_x6_r0_body.cl18 = true
kernel_rfl PRE_first_tail_x6_r0_body.cnodesK18 : (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.s191.ffi).mlx.nodes = Stage.setAll (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.s189.ffi).mlx.nodes (PRE_first_tail_x6_r0_body.cln18.filterMap fun i => ((Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.s191.ffi).mlx.nodes.get i).map (i, ·))
kernel_rfl PRE_first_tail_x6_r0_body.cobjsK18 : (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.s191.ffi).mlx.objs = Stage.setAll (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.s189.ffi).mlx.objs (PRE_first_tail_x6_r0_body.clo18.filterMap fun i => ((Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.s191.ffi).mlx.objs.get i).map (i, ·))
kernel_rfl PRE_first_tail_x6_r0_body.citemsK18 : (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.s191.ffi).mlx.items = Stage.setAll (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.s189.ffi).mlx.items (PRE_first_tail_x6_r0_body.cli18.filterMap fun i => ((Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.s191.ffi).mlx.items.get i).map (i, ·))
kernel_rfl PRE_first_tail_x6_r0_body.csst18 : Conv.sstListB 872 (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.s191.ffi).mlx PRE_first_tail_x6_r0_body.cln18 PRE_first_tail_x6_r0_body.clo18 PRE_first_tail_x6_r0_body.cli18 = true

end Host.Load.Run.Tpl
end

section -- SiteCl18
set_option Elab.async false
namespace Host.Load.Run.Tpl
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
open Host.Ts Host.Ts.Sim Host.Ts.Sim.Template

kernel_rfl PRE_first_tail_x6_r0_body.ckA18 : (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.s191.ffi).mlx.arrs = Stage.setAll (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.s189.ffi).mlx.arrs (PRE_first_tail_x6_r0_body.clo18.filterMap fun i => ((Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.s191.ffi).mlx.arrs.get i).map (i, ·))
kernel_rfl PRE_first_tail_x6_r0_body.cbd18 : (PRE_first_tail_x6_r0_body.clo18 ++ PRE_first_tail_x6_r0_body.cln18 ++ PRE_first_tail_x6_r0_body.cli18).all (fun i => Nat.blt (i / 4096) (4 ^ 31)) = true
kernel_rfl PRE_first_tail_x6_r0_body.cle18 : Conv.Cnt.leB (⟨18566, 15641, 2689387, 854⟩ : Conv.Cnt) (⟨18569, 15668, 2689393, 872⟩ : Conv.Cnt) = true
kernel_rfl PRE_first_tail_x6_r0_body.cck18 : Conv.ncleanListB (⟨18569, 15668, 2689393, 872⟩ : Conv.Cnt) (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.s191.ffi).mlx PRE_first_tail_x6_r0_body.clo18 PRE_first_tail_x6_r0_body.cln18 PRE_first_tail_x6_r0_body.cli18 = true
theorem PRE_first_tail_x6_r0_body.cncl18 (h : Conv.NClean (⟨18566, 15641, 2689387, 854⟩ : Conv.Cnt) (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.s189.ffi).mlx) : Conv.NClean (⟨18569, 15668, 2689393, 872⟩ : Conv.Cnt) (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.s191.ffi).mlx :=
  Conv.NClean.stepKeep h PRE_first_tail_x6_r0_body.cle18 PRE_first_tail_x6_r0_body.ckA18 PRE_first_tail_x6_r0_body.cobjsK18 PRE_first_tail_x6_r0_body.cnodesK18 PRE_first_tail_x6_r0_body.citemsK18 PRE_first_tail_x6_r0_body.cbd18 PRE_first_tail_x6_r0_body.cck18

end Host.Load.Run.Tpl
end

section -- SiteS18
set_option Elab.async false
namespace Host.Load.Run.Tpl
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
open Host.Ts Host.Ts.Sim Host.Ts.Sim.Template

/-! The compaction's native shift at call site 18 from its footprint (`Conv.nshift_of_foot`), and the observers'
(`liveShift_foot`, `kernShift_foot`): `Conv.FullShiftQ` for `Conv.full_compactQ`, given the call's bookkeeping and its
relation's facts. -/

/-- The load parameters of the chain (band-free: its start's node counter as `NL` and `N0`). -/
def PRE_first_tail_x6_r0_body.Pc18 : LoadP := ⟨18151, 131072, 1099511627776, 15235, 15235, []⟩
/-- The site's band raised to the map's checked fixed-node prefix, including newly recorded closure traces. -/
def PRE_first_tail_x6_r0_body.P18 : LoadP := PRE_first_tail_x6_r0_body.Pc18.raise 15668
kernel_rfl PRE_first_tail_x6_r0_body.craise18 : Nat.ble PRE_first_tail_x6_r0_body.Pc18.N0 15668 = true
theorem PRE_first_tail_x6_r0_body.raised18 : Host.Ts.Sim.Full.Raised PRE_first_tail_x6_r0_body.Pc18 PRE_first_tail_x6_r0_body.P18 :=
  .inr ⟨15668, rfl, Nat.le_of_ble_eq_true PRE_first_tail_x6_r0_body.craise18, rfl⟩
noncomputable abbrev PRE_first_tail_x6_r0_body.cx0_18 : Host.Load.LSt := clearTokens (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.s191.ffi)
noncomputable abbrev PRE_first_tail_x6_r0_body.cx1_18 : Host.Load.LSt := clearTokens (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.s190.ffi)
def PRE_first_tail_x6_r0_body.khinv18 : PTrie Nat := Stage.setAll PTrie.nil [(18592, 18566), (18570, 18567), (18593, 18568)]
def PRE_first_tail_x6_r0_body.kninv18 : PTrie Nat := Stage.setAll PTrie.nil [(15641, 15641), (15642, 15642), (15643, 15643), (15644, 15644), (15645, 15645), (15646, 15646), (15647, 15647), (15648, 15648), (15649, 15649), (15650, 15650), (15651, 15651), (15652, 15652), (15653, 15653), (15654, 15654), (15655, 15655), (15656, 15656), (15657, 15657), (15658, 15658), (15659, 15659), (15660, 15660), (15661, 15661), (15662, 15662), (15663, 15663), (15664, 15664), (15665, 15665), (15666, 15666), (15667, 15667)]
/-- The stage's footprint: its written and fresh handles, fresh nodes, written and fresh items. -/
def PRE_first_tail_x6_r0_body.cwS18 : List Nat := [18546, 18559, 18565, 18566, 18567, 18568, 18569, 18570, 18571, 18572, 18573, 18574, 18575, 18576, 18577, 18578, 18579, 18580, 18581, 18582, 18583, 18584, 18585, 18586, 18587, 18588, 18589, 18590, 18591, 18592, 18593]
def PRE_first_tail_x6_r0_body.cnS18 : List Nat := List.range' 15641 27
def PRE_first_tail_x6_r0_body.ciS18 : List Nat := [] ++ List.range' 15641 27

-- the small checks (`MChecks`'s)
kernel_rfl PRE_first_tail_x6_r0_body.cnh018 : PRE_first_tail_x6_r0_body.kd18.nh0 = PRE_first_tail_x6_r0_body.cx0_18.mlx.next
kernel_rfl PRE_first_tail_x6_r0_body.cnh118 : PRE_first_tail_x6_r0_body.kd18.nh1 = PRE_first_tail_x6_r0_body.cx1_18.mlx.next
kernel_rfl PRE_first_tail_x6_r0_body.cnn018 : PRE_first_tail_x6_r0_body.kd18.nn0 = PRE_first_tail_x6_r0_body.cx0_18.mlx.nnext
kernel_rfl PRE_first_tail_x6_r0_body.cnn118 : PRE_first_tail_x6_r0_body.kd18.nn1 = PRE_first_tail_x6_r0_body.cx1_18.mlx.nnext
kernel_rfl PRE_first_tail_x6_r0_body.cplo18 : (Nat.blt 0 PRE_first_tail_x6_r0_body.P18.lo && Nat.ble PRE_first_tail_x6_r0_body.P18.lo PRE_first_tail_x6_r0_body.cx0_18.mlx.next && Nat.ble PRE_first_tail_x6_r0_body.P18.lo RData.bigHi && Nat.ble RData.bigHi PRE_first_tail_x6_r0_body.P18.E) = true
kernel_rfl PRE_first_tail_x6_r0_body.ccnt18 : (Nat.ble PRE_first_tail_x6_r0_body.cx0_18.mlx.next PRE_first_tail_x6_r0_body.cx1_18.mlx.next && Nat.ble PRE_first_tail_x6_r0_body.cx0_18.mlx.nnext PRE_first_tail_x6_r0_body.cx1_18.mlx.nnext) = true
kernel_rfl PRE_first_tail_x6_r0_body.cnband18 : (Nat.blt 0 PRE_first_tail_x6_r0_body.P18.NL && Nat.ble PRE_first_tail_x6_r0_body.P18.NL PRE_first_tail_x6_r0_body.P18.N0 && Nat.ble PRE_first_tail_x6_r0_body.P18.N0 PRE_first_tail_x6_r0_body.cx0_18.mlx.nnext) = true
kernel_rfl PRE_first_tail_x6_r0_body.chbelow18 : PRE_first_tail_x6_r0_body.kd18.checkHndBelow = true
kernel_rfl PRE_first_tail_x6_r0_body.chren18 : checkRenG PRE_first_tail_x6_r0_body.kd18.hnd PRE_first_tail_x6_r0_body.khinv18 (phB PRE_first_tail_x6_r0_body.cx0_18.mlx) = true
kernel_rfl PRE_first_tail_x6_r0_body.cband18 : PRE_first_tail_x6_r0_body.kd18.checkBand PRE_first_tail_x6_r0_body.P18.lo = true
kernel_rfl PRE_first_tail_x6_r0_body.cnh1pos18 : Nat.blt 0 PRE_first_tail_x6_r0_body.kd18.nh1 = true
kernel_rfl PRE_first_tail_x6_r0_body.cnren18 : checkRenG PRE_first_tail_x6_r0_body.kd18.node PRE_first_tail_x6_r0_body.kninv18 (pnB PRE_first_tail_x6_r0_body.cx0_18.mlx) = true
kernel_rfl PRE_first_tail_x6_r0_body.cnlow18 : (PTrie.keysA PRE_first_tail_x6_r0_body.kd18.node).all (fun j => Nat.ble PRE_first_tail_x6_r0_body.P18.NL j && Nat.blt (PRE_first_tail_x6_r0_body.kd18.nodeF j) PRE_first_tail_x6_r0_body.cx1_18.mlx.nnext) = true
kernel_rfl PRE_first_tail_x6_r0_body.cabs0a18 : PRE_first_tail_x6_r0_body.cx0_18.mlx.arrs.get 0 = none
kernel_rfl PRE_first_tail_x6_r0_body.cabs0b18 : PRE_first_tail_x6_r0_body.cx0_18.mlx.objs.get 0 = none
kernel_rfl PRE_first_tail_x6_r0_body.ctok118 : PRE_first_tail_x6_r0_body.cx1_18.mlx.tokens = []
kernel_rfl PRE_first_tail_x6_r0_body.cpend18 : PRE_first_tail_x6_r0_body.cx1_18.mlx.pending = PRE_first_tail_x6_r0_body.cx0_18.mlx.pending.map PRE_first_tail_x6_r0_body.kappa18.pend
kernel_rfl PRE_first_tail_x6_r0_body.cerrh18 : PRE_first_tail_x6_r0_body.cx1_18.mlx.errh = PRE_first_tail_x6_r0_body.cx0_18.mlx.errh.map PRE_first_tail_x6_r0_body.kappa18.arg
kernel_rfl PRE_first_tail_x6_r0_body.cfiles18 : PRE_first_tail_x6_r0_body.cx1_18.mlx.files = PRE_first_tail_x6_r0_body.cx0_18.mlx.files
kernel_rfl PRE_first_tail_x6_r0_body.carch18 : PRE_first_tail_x6_r0_body.cx1_18.mlx.arch = PRE_first_tail_x6_r0_body.cx0_18.mlx.arch
kernel_rfl PRE_first_tail_x6_r0_body.csizes18 : PRE_first_tail_x6_r0_body.cx1_18.mlx.deviceSizes = PRE_first_tail_x6_r0_body.cx0_18.mlx.deviceSizes
kernel_rfl PRE_first_tail_x6_r0_body.cwired18 : PRE_first_tail_x6_r0_body.cx1_18.mlx.wired = PRE_first_tail_x6_r0_body.cx0_18.mlx.wired
kernel_rfl PRE_first_tail_x6_r0_body.chost18 : PRE_first_tail_x6_r0_body.cx1_18.host = PRE_first_tail_x6_r0_body.cx0_18.host
-- the compaction map's addresses are `PRE_first_tail_x6_r0_body.kd18`'s
kernel_rfl PRE_first_tail_x6_r0_body.ckn018 : PRE_first_tail_x6_r0_body.kd18.n0 = 2689393
kernel_rfl PRE_first_tail_x6_r0_body.ckn118 : PRE_first_tail_x6_r0_body.kd18.n1 = 2690542
kernel_rfl PRE_first_tail_x6_r0_body.ckheap18 : (PTrie.keysA PRE_first_tail_x6_r0_body.kd18.heap).all (fun x => Nat.ble 2689387 x) = true
kernel_rfl PRE_first_tail_x6_r0_body.ckpl18 : (List.range 6).all (fun j => decide (PRE_first_tail_x6_r0_body.kd18.heap.get (2689387 + j) = nth? PRE_first_tail_x6_r0_body.pl18 j)) = true
-- the map fixes the call's names (`Conv.fixOld_compact`), the call's counters
kernel_rfl PRE_first_tail_x6_r0_body.fja18 : Nat.ble 2689387 2689387 = true
kernel_rfl PRE_first_tail_x6_r0_body.fn18 : Nat.ble 854 854 = true
kernel_rfl PRE_first_tail_x6_r0_body.fjaD18 : Nat.ble 2689387 PRE_first_tail_x6_r0_body.kd18.n0 = true
kernel_rfl PRE_first_tail_x6_r0_body.fxn18 : Nat.ble 18566 PRE_first_tail_x6_r0_body.kd18.nh0 = true
kernel_rfl PRE_first_tail_x6_r0_body.fnn18 : Nat.ble 15641 PRE_first_tail_x6_r0_body.kd18.nn0 = true
kernel_rfl PRE_first_tail_x6_r0_body.fxb18 : Nat.ble 18566 RData.bigHi = true
kernel_rfl PRE_first_tail_x6_r0_body.fheap18 : (PTrie.keysA PRE_first_tail_x6_r0_body.kd18.heap).all (Nat.ble (⟨18566, 15641, 2689387, 854⟩ : Conv.Cnt).ja) = true
kernel_rfl PRE_first_tail_x6_r0_body.fhnd18 : (PTrie.keysA PRE_first_tail_x6_r0_body.kd18.hnd).all (Nat.ble (⟨18566, 15641, 2689387, 854⟩ : Conv.Cnt).xn) = true
kernel_rfl PRE_first_tail_x6_r0_body.fnode18 : (PTrie.keysA PRE_first_tail_x6_r0_body.kd18.node).all (Nat.ble (⟨18566, 15641, 2689387, 854⟩ : Conv.Cnt).nn) = true
/-- The compaction map fixes the call's names. -/
theorem PRE_first_tail_x6_r0_body.cfix18 : Conv.FixOld (⟨18566, 15641, 2689387, 854⟩ : Conv.Cnt) PRE_first_tail_x6_r0_body.kappa18 :=
  Conv.fixOld_compact (Nat.le_of_ble_eq_true PRE_first_tail_x6_r0_body.fja18) (Nat.le_of_ble_eq_true PRE_first_tail_x6_r0_body.fn18) (Nat.le_of_ble_eq_true PRE_first_tail_x6_r0_body.fjaD18) (Nat.le_of_ble_eq_true PRE_first_tail_x6_r0_body.fxn18) (Nat.le_of_ble_eq_true PRE_first_tail_x6_r0_body.fnn18) (Nat.le_of_ble_eq_true PRE_first_tail_x6_r0_body.fxb18) PRE_first_tail_x6_r0_body.fheap18 PRE_first_tail_x6_r0_body.fhnd18 PRE_first_tail_x6_r0_body.fnode18
kernel_rfl PRE_first_tail_x6_r0_body.fcxn18 : (⟨18566, 15641, 2689387, 854⟩ : Conv.Cnt).xn = (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.s189.ffi).mlx.next
kernel_rfl PRE_first_tail_x6_r0_body.fcnn18 : (⟨18566, 15641, 2689387, 854⟩ : Conv.Cnt).nn = (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.s189.ffi).mlx.nnext
kernel_rfl PRE_first_tail_x6_r0_body.fle018 : (Nat.ble (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.s189.ffi).mlx.next PRE_first_tail_x6_r0_body.cx0_18.mlx.next && Nat.ble (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.s189.ffi).mlx.nnext PRE_first_tail_x6_r0_body.cx0_18.mlx.nnext && Nat.ble (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.s189.ffi).mlx.next RData.bigHi) = true
kernel_rfl PRE_first_tail_x6_r0_body.fnk18 : (PTrie.keysA PRE_first_tail_x6_r0_body.kd18.node).all (Nat.ble (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.s189.ffi).mlx.nnext) = true
-- the merged state keeps the call's entries off the stage's footprint
kernel_rfl PRE_first_tail_x6_r0_body.f1A18 : PRE_first_tail_x6_r0_body.cx1_18.mlx.arrs = Stage.setAll (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.s189.ffi).mlx.arrs (PRE_first_tail_x6_r0_body.cwS18.filterMap fun i => (PRE_first_tail_x6_r0_body.cx1_18.mlx.arrs.get i).map (i, ·))
kernel_rfl PRE_first_tail_x6_r0_body.f1O18 : PRE_first_tail_x6_r0_body.cx1_18.mlx.objs = Stage.setAll (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.s189.ffi).mlx.objs (PRE_first_tail_x6_r0_body.cwS18.filterMap fun i => (PRE_first_tail_x6_r0_body.cx1_18.mlx.objs.get i).map (i, ·))
kernel_rfl PRE_first_tail_x6_r0_body.f1N18 : PRE_first_tail_x6_r0_body.cx1_18.mlx.nodes = Stage.setAll (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.s189.ffi).mlx.nodes (PRE_first_tail_x6_r0_body.cnS18.filterMap fun i => (PRE_first_tail_x6_r0_body.cx1_18.mlx.nodes.get i).map (i, ·))
kernel_rfl PRE_first_tail_x6_r0_body.f1I18 : PRE_first_tail_x6_r0_body.cx1_18.mlx.items = Stage.setAll (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.s189.ffi).mlx.items (PRE_first_tail_x6_r0_body.ciS18.filterMap fun i => (PRE_first_tail_x6_r0_body.cx1_18.mlx.items.get i).map (i, ·))
kernel_rfl PRE_first_tail_x6_r0_body.fbd18 : (PRE_first_tail_x6_r0_body.clo18 ++ PRE_first_tail_x6_r0_body.cln18 ++ PRE_first_tail_x6_r0_body.cli18 ++ PRE_first_tail_x6_r0_body.cwS18 ++ PRE_first_tail_x6_r0_body.cnS18 ++ PRE_first_tail_x6_r0_body.ciS18).all (fun i => Nat.blt (i / 4096) (4 ^ 31)) = true
kernel_rfl PRE_first_tail_x6_r0_body.fincW18 : PRE_first_tail_x6_r0_body.cwS18.all (fun h => !Nat.blt h (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.s189.ffi).mlx.next || PRE_first_tail_x6_r0_body.clo18.contains h) = true
kernel_rfl PRE_first_tail_x6_r0_body.fincI18 : PRE_first_tail_x6_r0_body.ciS18.all (fun k => !Nat.blt k (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.s189.ffi).mlx.nnext || PRE_first_tail_x6_r0_body.cli18.contains k) = true
kernel_rfl PRE_first_tail_x6_r0_body.fincN18 : PRE_first_tail_x6_r0_body.cnS18.all (Nat.ble (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.s189.ffi).mlx.nnext) = true
kernel_rfl PRE_first_tail_x6_r0_body.flnF18 : PRE_first_tail_x6_r0_body.cln18.all (Nat.ble (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.s189.ffi).mlx.nnext) = true
-- the checks over the changed lists
kernel_rfl PRE_first_tail_x6_r0_body.fh18 : PRE_first_tail_x6_r0_body.clo18.all (handleOK PRE_first_tail_x6_r0_body.kappa18 PRE_first_tail_x6_r0_body.P18.lo PRE_first_tail_x6_r0_body.cx0_18.mlx PRE_first_tail_x6_r0_body.cx1_18.mlx) = true
kernel_rfl PRE_first_tail_x6_r0_body.fo18 : PRE_first_tail_x6_r0_body.clo18.map (fun h => PRE_first_tail_x6_r0_body.cx1_18.mlx.objs.get (PRE_first_tail_x6_r0_body.kappa18.handle h)) = PRE_first_tail_x6_r0_body.clo18.map (fun h => (PRE_first_tail_x6_r0_body.cx0_18.mlx.objs.get h).map PRE_first_tail_x6_r0_body.kappa18.nobj)
kernel_rfl PRE_first_tail_x6_r0_body.fok18 : PRE_first_tail_x6_r0_body.clo18.all (objOK PRE_first_tail_x6_r0_body.kappa18 PRE_first_tail_x6_r0_body.P18.NL PRE_first_tail_x6_r0_body.cx0_18.mlx) = true
kernel_rfl PRE_first_tail_x6_r0_body.fnd18 : PRE_first_tail_x6_r0_body.cln18.all (nodeOKF PRE_first_tail_x6_r0_body.kappa18 PRE_first_tail_x6_r0_body.P18 PRE_first_tail_x6_r0_body.cx0_18.mlx PRE_first_tail_x6_r0_body.cx1_18.mlx) = true
kernel_rfl PRE_first_tail_x6_r0_body.fp18 : ((PRE_first_tail_x6_r0_body.cln18.filter (fullB PRE_first_tail_x6_r0_body.P18))).map (fun i => (PRE_first_tail_x6_r0_body.cx1_18.mlx.nodes.get (PRE_first_tail_x6_r0_body.kappa18.node i)).map Host.Mlx.Ffi.Node.prim) =
  ((PRE_first_tail_x6_r0_body.cln18.filter (fullB PRE_first_tail_x6_r0_body.P18))).map (fun i => (PRE_first_tail_x6_r0_body.cx0_18.mlx.nodes.get i).map fun nd => PRE_first_tail_x6_r0_body.kappa18.prim nd.prim)
kernel_rfl PRE_first_tail_x6_r0_body.fnordI18 : incrB PRE_first_tail_x6_r0_body.kd18.nodeF (List.range' 15641 27) = true
kernel_rfl PRE_first_tail_x6_r0_body.fnordK18 : (PTrie.keysA PRE_first_tail_x6_r0_body.kd18.node).all (fun k => Nat.ble 15641 k && Nat.blt k 15668) = true
kernel_rfl PRE_first_tail_x6_r0_body.fnordL18 : (PRE_first_tail_x6_r0_body.cln18.filter (Nat.ble PRE_first_tail_x6_r0_body.P18.N0)).all (fun i => Nat.ble i (PRE_first_tail_x6_r0_body.kd18.nodeF i) && (Nat.blt i 15668 || Nat.ble PRE_first_tail_x6_r0_body.kd18.nn0 i)) = true
theorem PRE_first_tail_x6_r0_body.fnord18 : (PRE_first_tail_x6_r0_body.cln18.filter (Nat.ble PRE_first_tail_x6_r0_body.P18.N0)).all (fun i => Nat.ble i (PRE_first_tail_x6_r0_body.kd18.nodeF i) &&
    (PTrie.keysA PRE_first_tail_x6_r0_body.kd18.node).all fun j => !Nat.blt j i || Nat.blt (PRE_first_tail_x6_r0_body.kd18.nodeF j) (PRE_first_tail_x6_r0_body.kd18.nodeF i)) = true :=
  cnord_of PRE_first_tail_x6_r0_body.cnlow18 PRE_first_tail_x6_r0_body.cnn118 PRE_first_tail_x6_r0_body.fnordI18 PRE_first_tail_x6_r0_body.fnordK18 PRE_first_tail_x6_r0_body.fnordL18
kernel_rfl PRE_first_tail_x6_r0_body.fi18 : PRE_first_tail_x6_r0_body.cli18.all (pnB PRE_first_tail_x6_r0_body.cx0_18.mlx) = true
kernel_rfl PRE_first_tail_x6_r0_body.fii18 : PRE_first_tail_x6_r0_body.cli18.all (fun k => decide (PRE_first_tail_x6_r0_body.cx1_18.mlx.items.get (PRE_first_tail_x6_r0_body.kappa18.node k) = (PRE_first_tail_x6_r0_body.cx0_18.mlx.items.get k).map PRE_first_tail_x6_r0_body.kappa18.nv)) = true
/-- **The compaction's footprint.** -/
theorem PRE_first_tail_x6_r0_body.cfoot18 (clean : Conv.NClean (⟨18566, 15641, 2689387, 854⟩ : Conv.Cnt) (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.s189.ffi).mlx) (hltC : ∀ h, PH (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.s189.ffi).mlx h → h < (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.s189.ffi).mlx.next) (nltC : ∀ i, PN (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.s189.ffi).mlx i → i < (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.s189.ffi).mlx.nnext) (itemsC : ∀ k v, (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.s189.ffi).mlx.items.get k = some v → PN (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.s189.ffi).mlx k) (tracedC : ∀ h o, (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.s189.ffi).mlx.objs.get h = some o → ∀ i ∈ objTraces o, i < PRE_first_tail_x6_r0_body.P18.NL) (cl : SSt (· < 872) PRE_first_tail_x6_r0_body.cx0_18.mlx) :
    Conv.MFoot PRE_first_tail_x6_r0_body.P18 872 PRE_first_tail_x6_r0_body.kappa18 PRE_first_tail_x6_r0_body.kd18 PRE_first_tail_x6_r0_body.khinv18 PRE_first_tail_x6_r0_body.kninv18 (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.s189.ffi).mlx PRE_first_tail_x6_r0_body.cx0_18.mlx PRE_first_tail_x6_r0_body.cx1_18.mlx (⟨18566, 15641, 2689387, 854⟩ : Conv.Cnt) PRE_first_tail_x6_r0_body.clo18 PRE_first_tail_x6_r0_body.cln18 PRE_first_tail_x6_r0_body.cli18 PRE_first_tail_x6_r0_body.cwS18 PRE_first_tail_x6_r0_body.cnS18 PRE_first_tail_x6_r0_body.ciS18 :=
  ⟨rfl, rfl, rfl, PRE_first_tail_x6_r0_body.cnh018, PRE_first_tail_x6_r0_body.cnh118, PRE_first_tail_x6_r0_body.cnn018, PRE_first_tail_x6_r0_body.cnn118, PRE_first_tail_x6_r0_body.cplo18, PRE_first_tail_x6_r0_body.ccnt18, PRE_first_tail_x6_r0_body.cnband18, PRE_first_tail_x6_r0_body.chbelow18, PRE_first_tail_x6_r0_body.chren18, PRE_first_tail_x6_r0_body.cband18, PRE_first_tail_x6_r0_body.cnh1pos18, PRE_first_tail_x6_r0_body.cnren18, PRE_first_tail_x6_r0_body.cnlow18, PRE_first_tail_x6_r0_body.cabs0a18, PRE_first_tail_x6_r0_body.cabs0b18, PRE_first_tail_x6_r0_body.ctok118, PRE_first_tail_x6_r0_body.cpend18, PRE_first_tail_x6_r0_body.cerrh18, PRE_first_tail_x6_r0_body.cfiles18, PRE_first_tail_x6_r0_body.carch18, PRE_first_tail_x6_r0_body.csizes18, PRE_first_tail_x6_r0_body.cwired18, PRE_first_tail_x6_r0_body.cfix18, clean, PRE_first_tail_x6_r0_body.fcxn18, PRE_first_tail_x6_r0_body.fcnn18, hltC, nltC, itemsC, tracedC, cl, PRE_first_tail_x6_r0_body.fle018, PRE_first_tail_x6_r0_body.fnk18, PRE_first_tail_x6_r0_body.ckA18, PRE_first_tail_x6_r0_body.cobjsK18, PRE_first_tail_x6_r0_body.cnodesK18, PRE_first_tail_x6_r0_body.citemsK18, PRE_first_tail_x6_r0_body.f1A18, PRE_first_tail_x6_r0_body.f1O18, PRE_first_tail_x6_r0_body.f1N18, PRE_first_tail_x6_r0_body.f1I18, PRE_first_tail_x6_r0_body.fbd18, PRE_first_tail_x6_r0_body.fincW18, PRE_first_tail_x6_r0_body.fincI18, PRE_first_tail_x6_r0_body.fincN18, PRE_first_tail_x6_r0_body.flnF18, PRE_first_tail_x6_r0_body.fh18, PRE_first_tail_x6_r0_body.fo18, PRE_first_tail_x6_r0_body.fok18, PRE_first_tail_x6_r0_body.fnd18, PRE_first_tail_x6_r0_body.fp18, PRE_first_tail_x6_r0_body.fnord18, PRE_first_tail_x6_r0_body.fi18, PRE_first_tail_x6_r0_body.fii18⟩
theorem PRE_first_tail_x6_r0_body.cnshift18 (clean : Conv.NClean (⟨18566, 15641, 2689387, 854⟩ : Conv.Cnt) (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.s189.ffi).mlx) (hltC : ∀ h, PH (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.s189.ffi).mlx h → h < (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.s189.ffi).mlx.next) (nltC : ∀ i, PN (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.s189.ffi).mlx i → i < (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.s189.ffi).mlx.nnext) (itemsC : ∀ k v, (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.s189.ffi).mlx.items.get k = some v → PN (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.s189.ffi).mlx k) (tracedC : ∀ h o, (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.s189.ffi).mlx.objs.get h = some o → ∀ i ∈ objTraces o, i < PRE_first_tail_x6_r0_body.P18.NL) (cl : SSt (· < 872) PRE_first_tail_x6_r0_body.cx0_18.mlx) : NShift PRE_first_tail_x6_r0_body.P18 872 PRE_first_tail_x6_r0_body.kappa18 PRE_first_tail_x6_r0_body.cx0_18 PRE_first_tail_x6_r0_body.cx1_18 :=
  Conv.nshift_of_foot (PRE_first_tail_x6_r0_body.cfoot18 clean hltC nltC itemsC tracedC cl) PRE_first_tail_x6_r0_body.chost18 (compact_a_eq PRE_first_tail_x6_r0_body.ckn018 PRE_first_tail_x6_r0_body.ckn118 PRE_first_tail_x6_r0_body.ckheap18 PRE_first_tail_x6_r0_body.ckpl18)

-- the observers: the layers' states at the call, the canonical and the merged state, their footprints and checks
noncomputable def PRE_first_tail_x6_r0_body.fxC_18 : PTrie Unit := (Host.Ts.Sim.Full.freedOf PRE_first_tail_x6_r0_body.s189.ffi).getD PTrie.nil
noncomputable def PRE_first_tail_x6_r0_body.krC_18 : Host.Load.Layers.KRec := (Host.Ts.Sim.Full.krecOf PRE_first_tail_x6_r0_body.s189.ffi).getD Host.Load.Layers.KRec.empty
kernel_rfl PRE_first_tail_x6_r0_body.ofxC_18 : (Host.Ts.Sim.Full.freedOf PRE_first_tail_x6_r0_body.s189.ffi) = some PRE_first_tail_x6_r0_body.fxC_18
kernel_rfl PRE_first_tail_x6_r0_body.okrC_18 : (Host.Ts.Sim.Full.krecOf PRE_first_tail_x6_r0_body.s189.ffi) = some PRE_first_tail_x6_r0_body.krC_18
noncomputable def PRE_first_tail_x6_r0_body.fx0_18 : PTrie Unit := (Host.Ts.Sim.Full.freedOf PRE_first_tail_x6_r0_body.s191.ffi).getD PTrie.nil
noncomputable def PRE_first_tail_x6_r0_body.kr0_18 : Host.Load.Layers.KRec := (Host.Ts.Sim.Full.krecOf PRE_first_tail_x6_r0_body.s191.ffi).getD Host.Load.Layers.KRec.empty
kernel_rfl PRE_first_tail_x6_r0_body.ofx0_18 : (Host.Ts.Sim.Full.freedOf PRE_first_tail_x6_r0_body.s191.ffi) = some PRE_first_tail_x6_r0_body.fx0_18
kernel_rfl PRE_first_tail_x6_r0_body.okr0_18 : (Host.Ts.Sim.Full.krecOf PRE_first_tail_x6_r0_body.s191.ffi) = some PRE_first_tail_x6_r0_body.kr0_18
noncomputable def PRE_first_tail_x6_r0_body.fx1_18 : PTrie Unit := (Host.Ts.Sim.Full.freedOf PRE_first_tail_x6_r0_body.s190.ffi).getD PTrie.nil
noncomputable def PRE_first_tail_x6_r0_body.kr1_18 : Host.Load.Layers.KRec := (Host.Ts.Sim.Full.krecOf PRE_first_tail_x6_r0_body.s190.ffi).getD Host.Load.Layers.KRec.empty
kernel_rfl PRE_first_tail_x6_r0_body.ofx1_18 : (Host.Ts.Sim.Full.freedOf PRE_first_tail_x6_r0_body.s190.ffi) = some PRE_first_tail_x6_r0_body.fx1_18
kernel_rfl PRE_first_tail_x6_r0_body.okr1_18 : (Host.Ts.Sim.Full.krecOf PRE_first_tail_x6_r0_body.s190.ffi) = some PRE_first_tail_x6_r0_body.kr1_18
kernel_rfl PRE_first_tail_x6_r0_body.ff018 : PRE_first_tail_x6_r0_body.fx0_18 = Stage.setAll PRE_first_tail_x6_r0_body.fxC_18 (PRE_first_tail_x6_r0_body.clo18.filterMap fun i => (PRE_first_tail_x6_r0_body.fx0_18.get i).map (i, ·))
kernel_rfl PRE_first_tail_x6_r0_body.ff118 : PRE_first_tail_x6_r0_body.fx1_18 = Stage.setAll PRE_first_tail_x6_r0_body.fxC_18 (PRE_first_tail_x6_r0_body.cwS18.filterMap fun i => (PRE_first_tail_x6_r0_body.fx1_18.get i).map (i, ·))
kernel_rfl PRE_first_tail_x6_r0_body.ffck18 : freedLB PRE_first_tail_x6_r0_body.kappa18 PRE_first_tail_x6_r0_body.cx0_18.mlx PRE_first_tail_x6_r0_body.fx0_18 PRE_first_tail_x6_r0_body.fx1_18 PRE_first_tail_x6_r0_body.clo18 = true
kernel_rfl PRE_first_tail_x6_r0_body.fkf018 : PRE_first_tail_x6_r0_body.kr0_18.flags = Stage.setAll PRE_first_tail_x6_r0_body.krC_18.flags (PRE_first_tail_x6_r0_body.clo18.filterMap fun i => (PRE_first_tail_x6_r0_body.kr0_18.flags.get i).map (i, ·))
kernel_rfl PRE_first_tail_x6_r0_body.fkt018 : PRE_first_tail_x6_r0_body.kr0_18.targs = Stage.setAll PRE_first_tail_x6_r0_body.krC_18.targs (PRE_first_tail_x6_r0_body.clo18.filterMap fun i => (PRE_first_tail_x6_r0_body.kr0_18.targs.get i).map (i, ·))
kernel_rfl PRE_first_tail_x6_r0_body.fkf118 : PRE_first_tail_x6_r0_body.kr1_18.flags = Stage.setAll PRE_first_tail_x6_r0_body.krC_18.flags (PRE_first_tail_x6_r0_body.cwS18.filterMap fun i => (PRE_first_tail_x6_r0_body.kr1_18.flags.get i).map (i, ·))
kernel_rfl PRE_first_tail_x6_r0_body.fkt118 : PRE_first_tail_x6_r0_body.kr1_18.targs = Stage.setAll PRE_first_tail_x6_r0_body.krC_18.targs (PRE_first_tail_x6_r0_body.cwS18.filterMap fun i => (PRE_first_tail_x6_r0_body.kr1_18.targs.get i).map (i, ·))
kernel_rfl PRE_first_tail_x6_r0_body.fkck18 : krecLB PRE_first_tail_x6_r0_body.kappa18 872 PRE_first_tail_x6_r0_body.cx0_18.mlx PRE_first_tail_x6_r0_body.kr0_18 PRE_first_tail_x6_r0_body.kr1_18 PRE_first_tail_x6_r0_body.clo18 = true
kernel_rfl PRE_first_tail_x6_r0_body.fkn18 : Nat.ble 854 872 = true
-- the bridge and the pending traces' regions
kernel_rfl PRE_first_tail_x6_r0_body.cbridge18 : Host.Ts.Sim.Full.bridgeOf PRE_first_tail_x6_r0_body.s190.ffi = Host.Ts.Sim.Full.bridgeOf PRE_first_tail_x6_r0_body.s191.ffi
kernel_rfl PRE_first_tail_x6_r0_body.cpendR18 : pendRegB PRE_first_tail_x6_r0_body.kappa18 (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.s191.ffi).mlx = true
kernel_rfl PRE_first_tail_x6_r0_body.cpendLe18 : Nat.ble (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.s191.ffi).mlx.next (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.s190.ffi).mlx.next = true
/-- **The compaction's native shift**, given the call's bookkeeping, its relation's facts (the model's and the
observers') and the canonical closedness. -/
theorem PRE_first_tail_x6_r0_body.cshift18 (clean : Conv.NClean (⟨18566, 15641, 2689387, 854⟩ : Conv.Cnt) (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.s189.ffi).mlx) (hltC : ∀ h, PH (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.s189.ffi).mlx h → h < (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.s189.ffi).mlx.next) (nltC : ∀ i, PN (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.s189.ffi).mlx i → i < (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.s189.ffi).mlx.nnext) (itemsC : ∀ k v, (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.s189.ffi).mlx.items.get k = some v → PN (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.s189.ffi).mlx k) (tracedC : ∀ h o, (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.s189.ffi).mlx.objs.get h = some o → ∀ i ∈ objTraces o, i < PRE_first_tail_x6_r0_body.P18.NL) (cl : SSt (· < 872) PRE_first_tail_x6_r0_body.cx0_18.mlx)
    (hobjC : ∀ h, PRE_first_tail_x6_r0_body.fxC_18.get h = some () → ((Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.s189.ffi).mlx.objs.get h).isSome = true)
    (hfC : ∀ h, (PRE_first_tail_x6_r0_body.krC_18.flags.get h).isSome = true → ((Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.s189.ffi).mlx.objs.get h).isSome = true)
    (htC : ∀ h, (PRE_first_tail_x6_r0_body.krC_18.targs.get h).isSome = true → ((Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.s189.ffi).mlx.objs.get h).isSome = true)
    (hclC : ∀ h l, PRE_first_tail_x6_r0_body.krC_18.targs.get h = some l → Host.Ts.Sim.Full.STargs (· < (⟨18566, 15641, 2689387, 854⟩ : Conv.Cnt).n) l) :
    Conv.FullShiftQ PRE_first_tail_x6_r0_body.P18 872 PRE_first_tail_x6_r0_body.kappa18 PRE_first_tail_x6_r0_body.s191.ffi PRE_first_tail_x6_r0_body.s190.ffi :=
  ⟨PRE_first_tail_x6_r0_body.cnshift18 clean hltC nltC itemsC tracedC cl, PRE_first_tail_x6_r0_body.cqueue18, fun t ht => bSN_sound (List.all_eq_true.mp PRE_first_tail_x6_r0_body.ctokSupp18 t ht),
    PRE_first_tail_x6_r0_body.cbridge18,
    liveShift_foot (x0' := Host.Ts.Sim.Full.mlxOf PRE_first_tail_x6_r0_body.s191.ffi) (x1' := Host.Ts.Sim.Full.mlxOf PRE_first_tail_x6_r0_body.s190.ffi) (PRE_first_tail_x6_r0_body.cfoot18 clean hltC nltC itemsC tracedC cl) rfl PRE_first_tail_x6_r0_body.ofx0_18 PRE_first_tail_x6_r0_body.ofx1_18 hobjC PRE_first_tail_x6_r0_body.ff018 PRE_first_tail_x6_r0_body.ff118 PRE_first_tail_x6_r0_body.ffck18,
    kernShift_foot (x0' := Host.Ts.Sim.Full.mlxOf PRE_first_tail_x6_r0_body.s191.ffi) (x1' := Host.Ts.Sim.Full.mlxOf PRE_first_tail_x6_r0_body.s190.ffi) (PRE_first_tail_x6_r0_body.cfoot18 clean hltC nltC itemsC tracedC cl) rfl PRE_first_tail_x6_r0_body.okr0_18 PRE_first_tail_x6_r0_body.okr1_18 (Nat.le_of_ble_eq_true PRE_first_tail_x6_r0_body.fkn18) hfC htC hclC
      PRE_first_tail_x6_r0_body.fkf018 PRE_first_tail_x6_r0_body.fkt018 PRE_first_tail_x6_r0_body.fkf118 PRE_first_tail_x6_r0_body.fkt118 PRE_first_tail_x6_r0_body.fkck18,
    pendReg_of rfl PRE_first_tail_x6_r0_body.cnh018 PRE_first_tail_x6_r0_body.cnh118 (Nat.le_of_ble_eq_true PRE_first_tail_x6_r0_body.cpendLe18) PRE_first_tail_x6_r0_body.cpendR18⟩

end Host.Load.Run.Tpl
end

section -- st18/H0
set_option Elab.async false
namespace Host.Load.Run.Tpl
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
host_stream_state PRE_first_tail_x6_r0_body.st18 0
host_stream_state PRE_first_tail_x6_r0_body.st18 1
host_stream_state PRE_first_tail_x6_r0_body.st18 2
host_stream_state PRE_first_tail_x6_r0_body.st18 3
host_stream_state PRE_first_tail_x6_r0_body.st18 4
host_stream_state PRE_first_tail_x6_r0_body.st18 5
end Host.Load.Run.Tpl
end

section -- Site18
set_option Elab.async false
namespace Host.Load.Run.Tpl
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
open Host.Ts Host.Ts.Sim Host.Ts.Sim.Template

/-! Call site 18 of chain `PRE_first_tail_x6_r0_body`: `ssmW__g18__g19` (`recurWindow`), the call state `PRE_first_tail_x6_r0_body.s189`, the merged state `PRE_first_tail_x6_r0_body.s190`,
the site template `PRE_first_tail_x6_r0_body.st18` (σ = `Map.id`, θ the identity at its own site), the canonical state `PRE_first_tail_x6_r0_body.s191`: the merge.
The footprint's facts are in `SiteF18`, the compaction's in `SiteC18`, `SiteK18`, `SiteNa18`, `SiteNb18`. -/

kernel_rfl PRE_first_tail_x6_r0_body.iso18 : PRE_first_tail_x6_r0_body.st18.s0 = { PRE_first_tail_x6_r0_body.s189 with stack := [] }
/-- The caller's frames at the call. -/
noncomputable def PRE_first_tail_x6_r0_body.rs18 : List Frame := PRE_first_tail_x6_r0_body.s189.stack
kernel_rfl PRE_first_tail_x6_r0_body.n0_18 : PRE_first_tail_x6_r0_body.S189.tab.length = 854
kernel_rfl PRE_first_tail_x6_r0_body.tab0_18 : PRE_first_tail_x6_r0_body.st18.S0.tab = PRE_first_tail_x6_r0_body.S189.tab

/-- The fresh variables of the stage's results. -/
def PRE_first_tail_x6_r0_body.ws18 : List Nat := [1307, 1308, 1309, 1310, 1311, 1312, 1313, 1314, 1315, 1316, 1317, 1318, 1319, 1320, 1321, 1322, 1323, 1324, 1325, 1326, 1327, 1328, 1329, 1330, 1331, 1332, 1333, 1334, 1335, 1336, 1337]
kernel_rfl PRE_first_tail_x6_r0_body.fresh18 : (PRE_first_tail_x6_r0_body.S189.tab.all fun e => PRE_first_tail_x6_r0_body.ws18.all fun v => e.noVar v) &&
    (PRE_first_tail_x6_r0_body.S189.oracle.all fun q => PRE_first_tail_x6_r0_body.ws18.all fun v => q.noVar v) = true
kernel_rfl PRE_first_tail_x6_r0_body.mergeTab18 : PRE_first_tail_x6_r0_body.S190.tab = PRE_first_tail_x6_r0_body.S189.tab ++ Conv.resTab PRE_first_tail_x6_r0_body.ws18
kernel_rfl PRE_first_tail_x6_r0_body.mergeLen18 : PRE_first_tail_x6_r0_body.st18.S5.tab.length - PRE_first_tail_x6_r0_body.st18.S0.tab.length = 31

-- The merged state: the instance's return state with the caller's frames (`PRE_first_tail_x6_r0_body.merged18`, `merged_relB`).
kernel_rfl PRE_first_tail_x6_r0_body.mheap18 : PRE_first_tail_x6_r0_body.s190.heap = PRE_first_tail_x6_r0_body.st18.s5.heap
kernel_rfl PRE_first_tail_x6_r0_body.mnext18 : PRE_first_tail_x6_r0_body.s190.next = PRE_first_tail_x6_r0_body.st18.s5.next
kernel_rfl PRE_first_tail_x6_r0_body.mctl18 : PRE_first_tail_x6_r0_body.s190.ctl = PRE_first_tail_x6_r0_body.st18.s5.ctl
kernel_rfl PRE_first_tail_x6_r0_body.mstack18 : PRE_first_tail_x6_r0_body.s190.stack = PRE_first_tail_x6_r0_body.st18.s5.stack ++ PRE_first_tail_x6_r0_body.s189.stack
kernel_rfl PRE_first_tail_x6_r0_body.mjobs18 : PRE_first_tail_x6_r0_body.s190.jobs = PRE_first_tail_x6_r0_body.st18.s5.jobs
kernel_rfl PRE_first_tail_x6_r0_body.mffi18 : PRE_first_tail_x6_r0_body.s190.ffi = PRE_first_tail_x6_r0_body.st18.s5.ffi
kernel_rfl PRE_first_tail_x6_r0_body.mtrace18 : PRE_first_tail_x6_r0_body.s190.trace = PRE_first_tail_x6_r0_body.st18.s5.trace
kernel_rfl PRE_first_tail_x6_r0_body.mstores18 : PRE_first_tail_x6_r0_body.s190.stores = PRE_first_tail_x6_r0_body.st18.s5.stores

end Host.Load.Run.Tpl
end

section -- SiteD18
set_option Elab.async false
namespace Host.Load.Run.Tpl
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
open Host.Ts Host.Ts.Sim Host.Ts.Sim.Template

/-! The canonical results at call site 18 of chain `PRE_first_tail_x6_r0_body`: their values in the instance's end table, the references past
the call's table, the canonical variables apart from the stage's. -/

kernel_rfl PRE_first_tail_x6_r0_body.cderived18 : PRE_first_tail_x6_r0_body.nr18.map (fun r => nth? PRE_first_tail_x6_r0_body.st18.S5.tab r) =
  [some (SymE.bin .add (SymE.lit (F64.zero false)) (SymE.un .int32 (SymE.un .int32 (SymE.var 10)))),
   some (SymE.un .int32 (SymE.un .int32 (SymE.bin .sub (SymE.bin .add (SymE.lit (F64.fin false 3 (0))) (SymE.un .int32 (SymE.un .int32 (SymE.var 10)))) (SymE.lit (F64.fin false 3 (0)))))),
   some (SymE.un .int32 (SymE.bin .sub (SymE.bin .add (SymE.lit (F64.fin false 3 (0))) (SymE.un .int32 (SymE.un .int32 (SymE.var 10)))) (SymE.un .int32 (SymE.un .int32 (SymE.un .int32 (SymE.var 10)))))),
   some (SymE.un .int32 (SymE.bin .sub (SymE.bin .add (SymE.lit (F64.fin false 3 (0))) (SymE.un .int32 (SymE.un .int32 (SymE.var 10)))) (SymE.lit (F64.fin false 3 (0))))),
   some (SymE.un .int32 (SymE.bin .sub (SymE.bin .add (SymE.lit (F64.fin false 3 (0))) (SymE.un .int32 (SymE.un .int32 (SymE.var 10)))) (SymE.lit (F64.fin false 3 (0))))),
   some (SymE.un .int32 (SymE.bin .sub (SymE.bin .add (SymE.lit (F64.fin false 3 (0))) (SymE.un .int32 (SymE.un .int32 (SymE.var 10)))) (SymE.lit (F64.fin false 3 (0))))),
   some (SymE.un .int32 (SymE.un .int32 (SymE.bin .sub (SymE.bin .add (SymE.lit (F64.fin false 3 (0))) (SymE.un .int32 (SymE.un .int32 (SymE.var 10)))) (SymE.lit (F64.fin false 3 (0)))))),
   some (SymE.un .int32 (SymE.un .int32 (SymE.un .int32 (SymE.var 10)))),
   some (SymE.un .int32 (SymE.bin .add (SymE.un .int32 (SymE.un .int32 (SymE.var 10))) (SymE.lit (F64.fin false 3 (0))))),
   some (SymE.bin .sub (SymE.bin .add (SymE.lit (F64.fin false 3 (0))) (SymE.un .int32 (SymE.un .int32 (SymE.var 10)))) (SymE.un .int32 (SymE.un .int32 (SymE.un .int32 (SymE.var 10))))),
   some (SymE.un .int32 (SymE.bin .sub (SymE.bin .add (SymE.lit (F64.fin false 3 (0))) (SymE.un .int32 (SymE.un .int32 (SymE.var 10)))) (SymE.lit (F64.fin false 3 (0))))),
   some (SymE.bin .sub (SymE.bin .sub (SymE.bin .add (SymE.lit (F64.fin false 3 (0))) (SymE.un .int32 (SymE.un .int32 (SymE.var 10)))) (SymE.lit (F64.fin false 3 (0)))) (SymE.lit (F64.zero false))),
   some (SymE.bin .add (SymE.lit (F64.fin false 3 (0))) (SymE.un .int32 (SymE.un .int32 (SymE.var 10)))),
   some (SymE.un .int32 (SymE.bin .sub (SymE.bin .add (SymE.lit (F64.fin false 3 (0))) (SymE.un .int32 (SymE.un .int32 (SymE.var 10)))) (SymE.lit (F64.fin false 3 (0))))),
   some (SymE.bin .sub (SymE.bin .sub (SymE.bin .add (SymE.lit (F64.fin false 3 (0))) (SymE.un .int32 (SymE.un .int32 (SymE.var 10)))) (SymE.lit (F64.fin false 3 (0)))) (SymE.lit (F64.zero false))),
   some (SymE.un .int32 (SymE.bin .sub (SymE.bin .add (SymE.lit (F64.fin false 3 (0))) (SymE.un .int32 (SymE.un .int32 (SymE.var 10)))) (SymE.lit (F64.fin false 3 (0))))),
   some (SymE.bin .sub (SymE.bin .sub (SymE.bin .add (SymE.lit (F64.fin false 3 (0))) (SymE.un .int32 (SymE.un .int32 (SymE.var 10)))) (SymE.lit (F64.fin false 3 (0)))) (SymE.lit (F64.zero false))),
   some (SymE.bin .sub (SymE.bin .add (SymE.lit (F64.fin false 3 (0))) (SymE.un .int32 (SymE.un .int32 (SymE.var 10)))) (SymE.lit (F64.fin false 3 (0))))]
kernel_rfl PRE_first_tail_x6_r0_body.cnrLo18 : PRE_first_tail_x6_r0_body.nr18.all (Nat.ble 854) = true
kernel_rfl PRE_first_tail_x6_r0_body.cwsDisj18 : PRE_first_tail_x6_r0_body.cws18.all (fun c => !PRE_first_tail_x6_r0_body.ws18.contains c) = true
/-- The compaction's substitution: the canonical variables to their merged values, the stage's other fresh variables
to `0` (`Conv.compactθZ`). -/
noncomputable def PRE_first_tail_x6_r0_body.cthetaZ18 : Nat → SymE := Conv.compactθZ PRE_first_tail_x6_r0_body.cws18 PRE_first_tail_x6_r0_body.crs18 PRE_first_tail_x6_r0_body.ws18

end Host.Load.Run.Tpl
end

section -- st18/Foot
set_option Elab.async false
namespace Host.Load.Run.Tpl
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
open Host.Ts Host.Ts.Sim Host.Ts.Sim.Stage Host.Ts.Sim.Template

/-! The footprint of stage `PRE_first_tail_x6_r0_body.st18`'s site template (`Conv.StageFoot`, `Conv.NFoot`): every entry of the return
state other than the written and fresh ones is the start's (kernel evaluation of the equalities). -/

/-- The written heap ranges below the start's counter. -/
def PRE_first_tail_x6_r0_body.st18.wrR : List (Nat × Nat) := [(2672341, 2672342), (2688561, 2688562), (2689106, 2689107), (2689362, 2689363)]
/-- The written and fresh entries of the return state. -/
noncomputable def PRE_first_tail_x6_r0_body.st18.wrE : List (Nat × Host.Ts.HObj) :=
  rangesOf PRE_first_tail_x6_r0_body.st18.s5.heap PRE_first_tail_x6_r0_body.st18.wrR ++ freshOf PRE_first_tail_x6_r0_body.st18.s5.heap PRE_first_tail_x6_r0_body.st18.s0.next PRE_first_tail_x6_r0_body.st18.s5.next
noncomputable def PRE_first_tail_x6_r0_body.st18.wr : List Nat := PRE_first_tail_x6_r0_body.st18.wrE.map (·.1)

kernel_rfl PRE_first_tail_x6_r0_body.st18.heapFoot : PRE_first_tail_x6_r0_body.st18.s5.heap = setAll PRE_first_tail_x6_r0_body.st18.s0.heap PRE_first_tail_x6_r0_body.st18.wrE
kernel_rfl PRE_first_tail_x6_r0_body.st18.grows_check : Nat.ble PRE_first_tail_x6_r0_body.st18.s0.next PRE_first_tail_x6_r0_body.st18.s5.next = true
theorem PRE_first_tail_x6_r0_body.st18.grows : PRE_first_tail_x6_r0_body.st18.s0.next ≤ PRE_first_tail_x6_r0_body.st18.s5.next := Nat.le_of_ble_eq_true PRE_first_tail_x6_r0_body.st18.grows_check

/-- The written and fresh handles; the written readback items of old nodes. -/
def PRE_first_tail_x6_r0_body.st18.wh : List Nat := [18546, 18559, 18565, 18566, 18567, 18568, 18569, 18570, 18571, 18572, 18573, 18574, 18575, 18576, 18577, 18578, 18579, 18580, 18581, 18582, 18583, 18584, 18585, 18586, 18587, 18588, 18589, 18590, 18591, 18592, 18593]
def PRE_first_tail_x6_r0_body.st18.wi : List Nat := []

kernel_rfl PRE_first_tail_x6_r0_body.st18.arrsFoot : (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.st18.s5.ffi).mlx.arrs = setAll (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.st18.s0.ffi).mlx.arrs (PRE_first_tail_x6_r0_body.st18.wh.filterMap fun h => ((Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.st18.s5.ffi).mlx.arrs.get h).map (h, ·))
kernel_rfl PRE_first_tail_x6_r0_body.st18.objsFoot : (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.st18.s5.ffi).mlx.objs = setAll (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.st18.s0.ffi).mlx.objs (PRE_first_tail_x6_r0_body.st18.wh.filterMap fun h => ((Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.st18.s5.ffi).mlx.objs.get h).map (h, ·))
kernel_rfl PRE_first_tail_x6_r0_body.st18.nodesFoot : (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.st18.s5.ffi).mlx.nodes = setAll (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.st18.s0.ffi).mlx.nodes (freshOf (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.st18.s5.ffi).mlx.nodes (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.st18.s0.ffi).mlx.nnext (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.st18.s5.ffi).mlx.nnext)
kernel_rfl PRE_first_tail_x6_r0_body.st18.itemsFoot : (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.st18.s5.ffi).mlx.items = setAll (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.st18.s0.ffi).mlx.items ((PRE_first_tail_x6_r0_body.st18.wi.filterMap fun i => ((Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.st18.s5.ffi).mlx.items.get i).map (i, ·)) ++
    freshOf (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.st18.s5.ffi).mlx.items (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.st18.s0.ffi).mlx.nnext (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.st18.s5.ffi).mlx.nnext)
kernel_rfl PRE_first_tail_x6_r0_body.st18.counters : (Nat.ble (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.st18.s0.ffi).mlx.next (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.st18.s5.ffi).mlx.next && Nat.ble (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.st18.s0.ffi).mlx.nnext (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.st18.s5.ffi).mlx.nnext) = true

end Host.Load.Run.Tpl
end

section -- SiteF18
set_option Elab.async false
namespace Host.Load.Run.Tpl
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
open Host.Ts Host.Ts.Sim Host.Ts.Sim.Template

/-! Call site 18 of chain `PRE_first_tail_x6_r0_body`: `Conv.site_merge`'s footprint facts. -/

kernel_rfl PRE_first_tail_x6_r0_body.wrNodupB18 : nodupT PRE_first_tail_x6_r0_body.st18.wr PTrie.nil = true
theorem PRE_first_tail_x6_r0_body.wrNodup18 : PRE_first_tail_x6_r0_body.st18.wr.Nodup := (nodupT_sound PRE_first_tail_x6_r0_body.wrNodupB18).2
kernel_rfl PRE_first_tail_x6_r0_body.wrBoundB18 : PRE_first_tail_x6_r0_body.st18.wr.all (fun b => Nat.blt (b / 4096) (4 ^ 31)) = true
theorem PRE_first_tail_x6_r0_body.wrBound18 : ∀ b ∈ PRE_first_tail_x6_r0_body.st18.wr, b / 4096 < 4 ^ 31 := fun b hb => Nat.blt_eq.mp (List.all_eq_true.mp PRE_first_tail_x6_r0_body.wrBoundB18 b hb)
noncomputable def PRE_first_tail_x6_r0_body.trFr18 := PRE_first_tail_x6_r0_body.st18.s5.trace.take 120
kernel_rfl PRE_first_tail_x6_r0_body.traceEq18 : PRE_first_tail_x6_r0_body.st18.s5.trace = PRE_first_tail_x6_r0_body.trFr18 ++ PRE_first_tail_x6_r0_body.st18.s0.trace
theorem PRE_first_tail_x6_r0_body.trace18 : ∃ fr, PRE_first_tail_x6_r0_body.st18.s5.trace = fr ++ PRE_first_tail_x6_r0_body.st18.s0.trace := ⟨_, PRE_first_tail_x6_r0_body.traceEq18⟩

-- the caller's wide frames at the instance's start (`Conv.isolateW`'s `W0` under `Map.id`) and their `WFix`
def PRE_first_tail_x6_r0_body.wide18 : List (Nat × WFrame) := [(4910, .memo [])]
kernel_rfl PRE_first_tail_x6_r0_body.wfixB18 : (PRE_first_tail_x6_r0_body.wide18.all fun p => wfixB Map.id (presentB PRE_first_tail_x6_r0_body.st18.s0) p.2) = true
theorem PRE_first_tail_x6_r0_body.wfix18 : ∀ p ∈ PRE_first_tail_x6_r0_body.wide18, WFix Map.id (Present PRE_first_tail_x6_r0_body.st18.s0) p.2 :=
  fun p hp => wfix_of (List.all_eq_true.mp PRE_first_tail_x6_r0_body.wfixB18 p hp)

end Host.Load.Run.Tpl
end

section -- SiteL18
set_option Elab.async false
namespace Host.Load.Run.Tpl
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
open Host.Ts Host.Ts.Sim Host.Ts.Sim.Template

/-! The call link's facts at call site 18 of chain `PRE_first_tail_x6_r0_body`: the instance's start server, its footprint (`Conv.StageFoot`), the
merged state `PRE_first_tail_x6_r0_body.s190`'s framed arrays as the chain start's extended (`arrExt_of`, `numRefs_of`). -/

kernel_rfl PRE_first_tail_x6_r0_body.srvO18 : PRE_first_tail_x6_r0_body.st18.S0.oracle = PRE_first_tail_x6_r0_body.st18.OR
kernel_rfl PRE_first_tail_x6_r0_body.wr0B18 : PRE_first_tail_x6_r0_body.st18.wr.all (fun b => !Nat.blt b PRE_first_tail_x6_r0_body.st18.s0.next || (PRE_first_tail_x6_r0_body.st18.s0.heap.get b).isSome) = true
theorem PRE_first_tail_x6_r0_body.stFoot18 : Conv.StageFoot PRE_first_tail_x6_r0_body.st18.wr PRE_first_tail_x6_r0_body.st18.s0 PRE_first_tail_x6_r0_body.st18.s5 :=
  stageFoot_of PRE_first_tail_x6_r0_body.st18.heapFoot PRE_first_tail_x6_r0_body.wrNodup18 PRE_first_tail_x6_r0_body.wrBound18 PRE_first_tail_x6_r0_body.wr0B18 PRE_first_tail_x6_r0_body.st18.grows

/-- **The relation at the merged state** from the relation at the merge (`Conv.site_merge`'s; `merged_relB`). -/
theorem PRE_first_tail_x6_r0_body.merged18 {FR : Map → Nat → PRE_first_tail_x6_r0_body.st18.F.S → PRE_first_tail_x6_r0_body.st18.F.S → Prop} {W : Nat → Option WFrame} {stk : List Frame} {M : Map}
    {ν : Nat → F64} {K : Host.Ts.Sim.Ctx} {S : SSrv} {t : St PRE_first_tail_x6_r0_body.st18.F.S} {C : CSrv} {n0 : Nat}
    (h : RelB PRE_first_tail_x6_r0_body.st18.F FR W stk M ν K (Conv.mergeSt Map.id (Map.id.res n0 n0) PRE_first_tail_x6_r0_body.rs18 PRE_first_tail_x6_r0_body.st18.wr PRE_first_tail_x6_r0_body.s189 PRE_first_tail_x6_r0_body.st18.s5 PRE_first_tail_x6_r0_body.st18.s0
      PRE_first_tail_x6_r0_body.st18.s5.ffi) S t C) : RelB PRE_first_tail_x6_r0_body.st18.F FR W stk M ν K PRE_first_tail_x6_r0_body.s190 S t C :=
  merged_relB PRE_first_tail_x6_r0_body.iso18 PRE_first_tail_x6_r0_body.stFoot18 PRE_first_tail_x6_r0_body.wrNodup18 PRE_first_tail_x6_r0_body.wrBound18 PRE_first_tail_x6_r0_body.trace18 PRE_first_tail_x6_r0_body.mheap18
    PRE_first_tail_x6_r0_body.mnext18 PRE_first_tail_x6_r0_body.mctl18 PRE_first_tail_x6_r0_body.mstack18 PRE_first_tail_x6_r0_body.mjobs18 PRE_first_tail_x6_r0_body.mffi18 PRE_first_tail_x6_r0_body.mtrace18 PRE_first_tail_x6_r0_body.mstores18 h

def PRE_first_tail_x6_r0_body.arrEl18_2665 : List Val := []
kernel_rfl PRE_first_tail_x6_r0_body.arrE18_2665 : arrOf PRE_first_tail_x6_r0_body.s190 2665 = arrOf PRE_first_tail_x6_r0_body.s0 2665 ++ PRE_first_tail_x6_r0_body.arrEl18_2665
kernel_rfl PRE_first_tail_x6_r0_body.arrA18_2665 : isArrB PRE_first_tail_x6_r0_body.s190 2665 = true
theorem PRE_first_tail_x6_r0_body.arr18_2665 : ∃ o, PRE_first_tail_x6_r0_body.s190.heap.get 2665 = some (.obj o) ∧ o.kind = .array (arrOf PRE_first_tail_x6_r0_body.s0 2665 ++ PRE_first_tail_x6_r0_body.arrEl18_2665) :=
  arrExt_of PRE_first_tail_x6_r0_body.arrE18_2665 PRE_first_tail_x6_r0_body.arrA18_2665
kernel_rfl PRE_first_tail_x6_r0_body.arrN18_2665 : numRefsB PRE_first_tail_x6_r0_body.S0.tab.length PRE_first_tail_x6_r0_body.arrEl18_2665 = true
theorem PRE_first_tail_x6_r0_body.arrR18_2665 : Prefill.NumRefs PRE_first_tail_x6_r0_body.S0.tab.length PRE_first_tail_x6_r0_body.arrEl18_2665 := numRefs_of PRE_first_tail_x6_r0_body.arrN18_2665

def PRE_first_tail_x6_r0_body.arrEl18_2673467 : List Val := []
kernel_rfl PRE_first_tail_x6_r0_body.arrE18_2673467 : arrOf PRE_first_tail_x6_r0_body.s190 2673467 = arrOf PRE_first_tail_x6_r0_body.s0 2673467 ++ PRE_first_tail_x6_r0_body.arrEl18_2673467
kernel_rfl PRE_first_tail_x6_r0_body.arrA18_2673467 : isArrB PRE_first_tail_x6_r0_body.s190 2673467 = true
theorem PRE_first_tail_x6_r0_body.arr18_2673467 : ∃ o, PRE_first_tail_x6_r0_body.s190.heap.get 2673467 = some (.obj o) ∧ o.kind = .array (arrOf PRE_first_tail_x6_r0_body.s0 2673467 ++ PRE_first_tail_x6_r0_body.arrEl18_2673467) :=
  arrExt_of PRE_first_tail_x6_r0_body.arrE18_2673467 PRE_first_tail_x6_r0_body.arrA18_2673467
kernel_rfl PRE_first_tail_x6_r0_body.arrN18_2673467 : numRefsB PRE_first_tail_x6_r0_body.S0.tab.length PRE_first_tail_x6_r0_body.arrEl18_2673467 = true
theorem PRE_first_tail_x6_r0_body.arrR18_2673467 : Prefill.NumRefs PRE_first_tail_x6_r0_body.S0.tab.length PRE_first_tail_x6_r0_body.arrEl18_2673467 := numRefs_of PRE_first_tail_x6_r0_body.arrN18_2673467

kernel_rfl PRE_first_tail_x6_r0_body.w4910k18 : isArrB PRE_first_tail_x6_r0_body.s190 4910 = false
theorem PRE_first_tail_x6_r0_body.keep18 (q : List Val) : Host.Ts.Sim.Prefill.KeepsAtW (framesP PRE_first_tail_x6_r0_body.s0 q) PRE_first_tail_x6_r0_body.s190 := by
  intro a pre pre' hx o es ho hk
  unfold framesP at hx
  simp only at hx
  cases h1 : Nat.beq a 2665
  · cases h2 : Nat.beq a 4910
    · rw [h1, h2] at hx; cases hx
    · have := Nat.eq_of_beq_eq_true h2; subst this
      rw [h1, h2] at hx; cases hx
      exact (notArr_of PRE_first_tail_x6_r0_body.w4910k18 ho hk).elim
  · have := Nat.eq_of_beq_eq_true h1; subst this
    rw [h1] at hx; cases hx
    obtain ⟨o', ho', hk'⟩ := PRE_first_tail_x6_r0_body.arr18_2665
    rw [ho] at ho'; cases ho'
    rw [hk'] at hk; cases hk
    simp [PRE_first_tail_x6_r0_body.arrEl18_2665]

end Host.Load.Run.Tpl
end

section -- SiteZ18
set_option Elab.async false
namespace Host.Load.Run.Tpl
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
open Host.Ts Host.Ts.Sim Host.Ts.Sim.Template

/-! The compaction's state shift at call site 18 of chain `PRE_first_tail_x6_r0_body` (`Conv.compact_shift`): the call `PRE_first_tail_x6_r0_body.s189`, the merged
state `PRE_first_tail_x6_r0_body.s190`, the canonical state `PRE_first_tail_x6_r0_body.s191`; its frames [2665,2673467,2673472,2673473] (kept arrays [2665,2673467]). -/

-- the map's places and counters
kernel_rfl PRE_first_tail_x6_r0_body.zpl18 : PRE_first_tail_x6_r0_body.pl18.all (Nat.ble PRE_first_tail_x6_r0_body.s189.next) = true
kernel_rfl PRE_first_tail_x6_r0_body.zplnd18 : nodupT PRE_first_tail_x6_r0_body.pl18 PTrie.nil = true
kernel_rfl PRE_first_tail_x6_r0_body.zn118 : Nat.ble PRE_first_tail_x6_r0_body.s189.next 2690542 = true
kernel_rfl PRE_first_tail_x6_r0_body.zfirst18 : Nat.ble aFirst PRE_first_tail_x6_r0_body.s189.next = true
kernel_rfl PRE_first_tail_x6_r0_body.zscn18 : PRE_first_tail_x6_r0_body.s191.next = PRE_first_tail_x6_r0_body.s189.next + PRE_first_tail_x6_r0_body.pl18.length
kernel_rfl PRE_first_tail_x6_r0_body.zsmn18 : PRE_first_tail_x6_r0_body.s190.next = 2690542
kernel_rfl PRE_first_tail_x6_r0_body.zgrow18 : Nat.ble PRE_first_tail_x6_r0_body.s191.next PRE_first_tail_x6_r0_body.s190.next = true
-- the tables
kernel_rfl PRE_first_tail_x6_r0_body.zfresh18 : PRE_first_tail_x6_r0_body.S189.tab.all (fun e => PRE_first_tail_x6_r0_body.cws18.all fun v => e.noVar v) = true
kernel_rfl PRE_first_tail_x6_r0_body.zcnd18 : nodupT PRE_first_tail_x6_r0_body.cws18 PTrie.nil = true
kernel_rfl PRE_first_tail_x6_r0_body.znrHi18 : PRE_first_tail_x6_r0_body.nr18.all (fun r => Nat.blt r PRE_first_tail_x6_r0_body.S190.tab.length) = true
-- the frames: every framed address below the call's counter; the kept arrays the chain start's, extended in the merged state
kernel_rfl PRE_first_tail_x6_r0_body.zfrlt18 : [2665, 2673467, 2673472, 2673473].all (fun a => Nat.blt a PRE_first_tail_x6_r0_body.s189.next) = true
kernel_rfl PRE_first_tail_x6_r0_body.zg18_2665 : PRE_first_tail_x6_r0_body.s191.heap.get 2665 = some (.obj (objOf PRE_first_tail_x6_r0_body.s191 2665))
kernel_rfl PRE_first_tail_x6_r0_body.zk18_2665 : (objOf PRE_first_tail_x6_r0_body.s191 2665).kind = .array (arrOf PRE_first_tail_x6_r0_body.s0 2665)
kernel_rfl PRE_first_tail_x6_r0_body.zm18_2665 : PRE_first_tail_x6_r0_body.s190.heap.get 2665 = some (.obj { PRE_first_tail_x6_r0_body.kappa18.obj (objOf PRE_first_tail_x6_r0_body.s191 2665) with
  kind := .array (arrOf PRE_first_tail_x6_r0_body.s0 2665 ++ (arrOf PRE_first_tail_x6_r0_body.s190 2665).drop (arrOf PRE_first_tail_x6_r0_body.s0 2665).length) })
kernel_rfl PRE_first_tail_x6_r0_body.zg18_2673467 : PRE_first_tail_x6_r0_body.s191.heap.get 2673467 = some (.obj (objOf PRE_first_tail_x6_r0_body.s191 2673467))
kernel_rfl PRE_first_tail_x6_r0_body.zk18_2673467 : (objOf PRE_first_tail_x6_r0_body.s191 2673467).kind = .array (arrOf PRE_first_tail_x6_r0_body.s0 2673467)
kernel_rfl PRE_first_tail_x6_r0_body.zm18_2673467 : PRE_first_tail_x6_r0_body.s190.heap.get 2673467 = some (.obj { PRE_first_tail_x6_r0_body.kappa18.obj (objOf PRE_first_tail_x6_r0_body.s191 2673467) with
  kind := .array (arrOf PRE_first_tail_x6_r0_body.s0 2673467 ++ (arrOf PRE_first_tail_x6_r0_body.s190 2673467).drop (arrOf PRE_first_tail_x6_r0_body.s0 2673467).length) })
kernel_rfl PRE_first_tail_x6_r0_body.zw18_4910 : (PRE_first_tail_x6_r0_body.s191.heap.get 4910).isSome = true
kernel_rfl PRE_first_tail_x6_r0_body.zw18_2673472 : (PRE_first_tail_x6_r0_body.s191.heap.get 2673472).isSome = true
kernel_rfl PRE_first_tail_x6_r0_body.zw18_2673473 : (PRE_first_tail_x6_r0_body.s191.heap.get 2673473).isSome = true
-- the heap: the changed list in range, holding the stage's written and fresh addresses; the canonical side's image
kernel_rfl PRE_first_tail_x6_r0_body.zclbd18 : PRE_first_tail_x6_r0_body.cl18.all (fun b => Nat.blt (b / 4096) (4 ^ 31)) = true
kernel_rfl PRE_first_tail_x6_r0_body.zwr18 : PRE_first_tail_x6_r0_body.st18.wr.all (fun b => !Nat.blt b PRE_first_tail_x6_r0_body.s189.next || PRE_first_tail_x6_r0_body.cl18.contains b) = true
def PRE_first_tail_x6_r0_body.zl18 : List Nat := PRE_first_tail_x6_r0_body.cl18.filter fun a => !(List.contains [2665, 2673467] a)
kernel_rfl PRE_first_tail_x6_r0_body.zimgE18 : PRE_first_tail_x6_r0_body.zl18.map (fun a => PRE_first_tail_x6_r0_body.s190.heap.get (PRE_first_tail_x6_r0_body.kappa18.a a)) = PRE_first_tail_x6_r0_body.zl18.map (fun a => (PRE_first_tail_x6_r0_body.s191.heap.get a).map PRE_first_tail_x6_r0_body.kappa18.hobj)
theorem PRE_first_tail_x6_r0_body.zimg18 : HeapImg PRE_first_tail_x6_r0_body.kappa18 PRE_first_tail_x6_r0_body.s191 PRE_first_tail_x6_r0_body.s190 PRE_first_tail_x6_r0_body.zl18 := PRE_first_tail_x6_r0_body.zimgE18
-- the roots and their supports
kernel_rfl PRE_first_tail_x6_r0_body.zctl18 : PRE_first_tail_x6_r0_body.s190.ctl = PRE_first_tail_x6_r0_body.kappa18.ctl PRE_first_tail_x6_r0_body.s191.ctl
kernel_rfl PRE_first_tail_x6_r0_body.zstack18 : PRE_first_tail_x6_r0_body.s190.stack = PRE_first_tail_x6_r0_body.s191.stack.map PRE_first_tail_x6_r0_body.kappa18.frame
kernel_rfl PRE_first_tail_x6_r0_body.zjobs18 : PRE_first_tail_x6_r0_body.s190.jobs = PRE_first_tail_x6_r0_body.s191.jobs.map PRE_first_tail_x6_r0_body.kappa18.job
kernel_rfl PRE_first_tail_x6_r0_body.zstores18 : PRE_first_tail_x6_r0_body.s190.stores = PRE_first_tail_x6_r0_body.kappa18.stores PRE_first_tail_x6_r0_body.s191.stores
kernel_rfl PRE_first_tail_x6_r0_body.zroots18 : checkRootsSupp PRE_first_tail_x6_r0_body.s191 872 = true
kernel_rfl PRE_first_tail_x6_r0_body.znC18 : PRE_first_tail_x6_r0_body.S189.tab.length + PRE_first_tail_x6_r0_body.cws18.length = 872
-- the map as `Conv.compact_shift` states it (the call's counters for the literals)
kernel_rfl PRE_first_tail_x6_r0_body.zkap18 : PRE_first_tail_x6_r0_body.kappa18 = Conv.Map.compact PRE_first_tail_x6_r0_body.s189.next 2690542 PRE_first_tail_x6_r0_body.S189.tab.length PRE_first_tail_x6_r0_body.pl18 (PRE_first_tail_x6_r0_body.nr18.map NumV.ref) PRE_first_tail_x6_r0_body.kd18.big
  PRE_first_tail_x6_r0_body.kd18.region PRE_first_tail_x6_r0_body.kd18.nodeF
-- the bridge inactive at the canonical state (`Conv.FullShiftQ.toX`; the merged state's bridge is the canonical's: cbridge)
theorem PRE_first_tail_x6_r0_body.zbin18 : (Host.Ts.Sim.Full.bridgeOf PRE_first_tail_x6_r0_body.s191.ffi).active = false := (Host.Load.Boot.replay_active Host.Load.Run.Prompt.P.oblog2818)
-- the JS bookkeeping's step (`Conv.JClean.step` over the changed list) and the canonical roots' bigint freedom
kernel_rfl PRE_first_tail_x6_r0_body.zjc18 : Conv.jcleanListB (⟨18569, 15668, 2689393, 872⟩ : Conv.Cnt) PRE_first_tail_x6_r0_body.s191 PRE_first_tail_x6_r0_body.cl18 = true
kernel_rfl PRE_first_tail_x6_r0_body.zrootsB18 : noBigRootsP (fun i => !Conv.oldBigB (⟨18569, 15668, 2689393, 872⟩ : Conv.Cnt) i) PRE_first_tail_x6_r0_body.s191.trace PRE_first_tail_x6_r0_body.s191 = true
kernel_rfl PRE_first_tail_x6_r0_body.zhm18 : Nat.ble (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.s0.ffi).mlx.nnext 15641 = true
theorem PRE_first_tail_x6_r0_body.cjcl18 (h : Conv.JClean (⟨18566, 15641, 2689387, 854⟩ : Conv.Cnt) PRE_first_tail_x6_r0_body.s189) : Conv.JClean (⟨18569, 15668, 2689393, 872⟩ : Conv.Cnt) PRE_first_tail_x6_r0_body.s191 :=
  Conv.JClean.step h (Conv.Cnt.le_of_leB PRE_first_tail_x6_r0_body.cle18)
    (Conv.heap_off_setAll PRE_first_tail_x6_r0_body.cheap18 fun a ha => Nat.blt_eq.mp (List.all_eq_true.mp PRE_first_tail_x6_r0_body.zclbd18 a ha)) PRE_first_tail_x6_r0_body.zjc18

end Host.Load.Run.Tpl
end

section -- st18/TypedLast
set_option Elab.async false
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
namespace Host.Load.Run.Tpl
open Host.Ts Host.Ts.Sim Host.Ts.Sim.Template

boot_rfl PRE_first_tail_x6_r0_body.st18.bodyLast from PRE_first_tail_x6_r0_body.st18.s4 to PRE_first_tail_x6_r0_body.st18.s5 :
  interpS (step PRE_first_tail_x6_r0_body.st18.F PRE_first_tail_x6_r0_body.st18.s4).run PRE_first_tail_x6_r0_body.st18.S4 = some (PRE_first_tail_x6_r0_body.st18.s5, PRE_first_tail_x6_r0_body.st18.S5)
kernel_rfl PRE_first_tail_x6_r0_body.st18.bodyHalt : isHalt PRE_first_tail_x6_r0_body.st18.s4.ctl = false
kernel_rfl PRE_first_tail_x6_r0_body.st18.bodyTopCheck : noBlockTop PRE_first_tail_x6_r0_body.st18.s5.stack = true

end Host.Load.Run.Tpl
end

section -- st18/TypedOk
set_option Elab.async false
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
namespace Host.Load.Run.Tpl
open Host.Ts Host.Ts.Sim Host.Ts.Sim.Template

noncomputable def PRE_first_tail_x6_r0_body.st18.bodyOkL (bytes : List Byte) (rows : Nat) : St PRE_first_tail_x6_r0_body.st18.F.S → SSrv → Bool :=
  okLocal (Host.Ts.Sim.Compose.VWFrames.bodyOk bytes rows)

noncomputable def PRE_first_tail_x6_r0_body.st18.bodyOkLN (bytes : List Byte) (rows : Nat) : St PRE_first_tail_x6_r0_body.st18.F.S → FSrv → Bool :=
  okLocalN (Host.Ts.Sim.Compose.VWFrames.bodyOkN bytes rows)

theorem PRE_first_tail_x6_r0_body.st18.bodyOkLN_ok (bytes : List Byte) (rows : Nat) (s : St PRE_first_tail_x6_r0_body.st18.F.S) (c : FSrv) (h : c.Wf) :
    PRE_first_tail_x6_r0_body.st18.bodyOkLN bytes rows s c = PRE_first_tail_x6_r0_body.st18.bodyOkL bytes rows s c.toS :=
  okLocalN_ok (Host.Ts.Sim.Compose.VWFrames.bodyOkN_ok bytes rows) s c h

kernel_rfl PRE_first_tail_x6_r0_body.st18.bodyAccepted0 :
  (fun (bytes : List Byte) (rows : Nat) => PRE_first_tail_x6_r0_body.st18.bodyOkL bytes rows PRE_first_tail_x6_r0_body.st18.s0 PRE_first_tail_x6_r0_body.st18.S0) = fun _ _ => true

kernel_rfl PRE_first_tail_x6_r0_body.st18.bodyAccepted1 :
  (fun (bytes : List Byte) (rows : Nat) => PRE_first_tail_x6_r0_body.st18.bodyOkL bytes rows PRE_first_tail_x6_r0_body.st18.s4 PRE_first_tail_x6_r0_body.st18.S4) = fun _ _ => true

end Host.Load.Run.Tpl
end

section -- st18/TypedK0
set_option Elab.async false
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
namespace Host.Load.Run.Tpl
open Host.Ts Host.Ts.Sim Host.Ts.Sim.Template

boot_rfl PRE_first_tail_x6_r0_body.st18.bodyK0F from PRE_first_tail_x6_r0_body.st18.s0 to PRE_first_tail_x6_r0_body.st18.s1 :
  (fun (bytes : List Byte) (rows : Nat) => runOkS PRE_first_tail_x6_r0_body.st18.F (PRE_first_tail_x6_r0_body.st18.bodyOkLN bytes rows)
    ((nth? PRE_first_tail_x6_r0_body.st18.ks 0).getD 0) PRE_first_tail_x6_r0_body.st18.s0 PRE_first_tail_x6_r0_body.st18.S0) = fun _ _ => some (PRE_first_tail_x6_r0_body.st18.s1, PRE_first_tail_x6_r0_body.st18.S1)
theorem PRE_first_tail_x6_r0_body.st18.bodyK0 :
  (fun (bytes : List Byte) (rows : Nat) => runOk PRE_first_tail_x6_r0_body.st18.F (PRE_first_tail_x6_r0_body.st18.bodyOkL bytes rows)
    ((nth? PRE_first_tail_x6_r0_body.st18.ks 0).getD 0) PRE_first_tail_x6_r0_body.st18.s0 PRE_first_tail_x6_r0_body.st18.S0) = fun _ _ => some (PRE_first_tail_x6_r0_body.st18.s1, PRE_first_tail_x6_r0_body.st18.S1) :=
  runOk_fun_of_runOkS PRE_first_tail_x6_r0_body.st18.bodyOkLN_ok PRE_first_tail_x6_r0_body.st18.bodyK0F
end Host.Load.Run.Tpl
end

section -- st18/TypedK1
set_option Elab.async false
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
namespace Host.Load.Run.Tpl
open Host.Ts Host.Ts.Sim Host.Ts.Sim.Template

boot_rfl PRE_first_tail_x6_r0_body.st18.bodyK1F from PRE_first_tail_x6_r0_body.st18.s1 to PRE_first_tail_x6_r0_body.st18.s2 :
  (fun (bytes : List Byte) (rows : Nat) => runOkS PRE_first_tail_x6_r0_body.st18.F (PRE_first_tail_x6_r0_body.st18.bodyOkLN bytes rows)
    ((nth? PRE_first_tail_x6_r0_body.st18.ks 1).getD 0) PRE_first_tail_x6_r0_body.st18.s1 PRE_first_tail_x6_r0_body.st18.S1) = fun _ _ => some (PRE_first_tail_x6_r0_body.st18.s2, PRE_first_tail_x6_r0_body.st18.S2)
theorem PRE_first_tail_x6_r0_body.st18.bodyK1 :
  (fun (bytes : List Byte) (rows : Nat) => runOk PRE_first_tail_x6_r0_body.st18.F (PRE_first_tail_x6_r0_body.st18.bodyOkL bytes rows)
    ((nth? PRE_first_tail_x6_r0_body.st18.ks 1).getD 0) PRE_first_tail_x6_r0_body.st18.s1 PRE_first_tail_x6_r0_body.st18.S1) = fun _ _ => some (PRE_first_tail_x6_r0_body.st18.s2, PRE_first_tail_x6_r0_body.st18.S2) :=
  runOk_fun_of_runOkS PRE_first_tail_x6_r0_body.st18.bodyOkLN_ok PRE_first_tail_x6_r0_body.st18.bodyK1F
end Host.Load.Run.Tpl
end

section -- st18/TypedK2
set_option Elab.async false
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
namespace Host.Load.Run.Tpl
open Host.Ts Host.Ts.Sim Host.Ts.Sim.Template

boot_rfl PRE_first_tail_x6_r0_body.st18.bodyK2F from PRE_first_tail_x6_r0_body.st18.s2 to PRE_first_tail_x6_r0_body.st18.s3 :
  (fun (bytes : List Byte) (rows : Nat) => runOkS PRE_first_tail_x6_r0_body.st18.F (PRE_first_tail_x6_r0_body.st18.bodyOkLN bytes rows)
    ((nth? PRE_first_tail_x6_r0_body.st18.ks 2).getD 0) PRE_first_tail_x6_r0_body.st18.s2 PRE_first_tail_x6_r0_body.st18.S2) = fun _ _ => some (PRE_first_tail_x6_r0_body.st18.s3, PRE_first_tail_x6_r0_body.st18.S3)
theorem PRE_first_tail_x6_r0_body.st18.bodyK2 :
  (fun (bytes : List Byte) (rows : Nat) => runOk PRE_first_tail_x6_r0_body.st18.F (PRE_first_tail_x6_r0_body.st18.bodyOkL bytes rows)
    ((nth? PRE_first_tail_x6_r0_body.st18.ks 2).getD 0) PRE_first_tail_x6_r0_body.st18.s2 PRE_first_tail_x6_r0_body.st18.S2) = fun _ _ => some (PRE_first_tail_x6_r0_body.st18.s3, PRE_first_tail_x6_r0_body.st18.S3) :=
  runOk_fun_of_runOkS PRE_first_tail_x6_r0_body.st18.bodyOkLN_ok PRE_first_tail_x6_r0_body.st18.bodyK2F
end Host.Load.Run.Tpl
end

section -- st18/TypedK3
set_option Elab.async false
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
namespace Host.Load.Run.Tpl
open Host.Ts Host.Ts.Sim Host.Ts.Sim.Template

boot_rfl PRE_first_tail_x6_r0_body.st18.bodyK3F from PRE_first_tail_x6_r0_body.st18.s3 to PRE_first_tail_x6_r0_body.st18.s4 :
  (fun (bytes : List Byte) (rows : Nat) => runOkS PRE_first_tail_x6_r0_body.st18.F (PRE_first_tail_x6_r0_body.st18.bodyOkLN bytes rows)
    ((nth? PRE_first_tail_x6_r0_body.st18.ks 3).getD 0) PRE_first_tail_x6_r0_body.st18.s3 PRE_first_tail_x6_r0_body.st18.S3) = fun _ _ => some (PRE_first_tail_x6_r0_body.st18.s4, PRE_first_tail_x6_r0_body.st18.S4)
theorem PRE_first_tail_x6_r0_body.st18.bodyK3 :
  (fun (bytes : List Byte) (rows : Nat) => runOk PRE_first_tail_x6_r0_body.st18.F (PRE_first_tail_x6_r0_body.st18.bodyOkL bytes rows)
    ((nth? PRE_first_tail_x6_r0_body.st18.ks 3).getD 0) PRE_first_tail_x6_r0_body.st18.s3 PRE_first_tail_x6_r0_body.st18.S3) = fun _ _ => some (PRE_first_tail_x6_r0_body.st18.s4, PRE_first_tail_x6_r0_body.st18.S4) :=
  runOk_fun_of_runOkS PRE_first_tail_x6_r0_body.st18.bodyOkLN_ok PRE_first_tail_x6_r0_body.st18.bodyK3F
end Host.Load.Run.Tpl
end

section -- st18/TypedTpl
set_option Elab.async false
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
namespace Host.Load.Run.Tpl
open Host.Ts Host.Ts.Sim Host.Ts.Sim.Template

theorem PRE_first_tail_x6_r0_body.st18.bodyRun (bytes : List Byte) (rows : Nat) :
    runOk PRE_first_tail_x6_r0_body.st18.F (PRE_first_tail_x6_r0_body.st18.bodyOkL bytes rows) 11334 PRE_first_tail_x6_r0_body.st18.s0 PRE_first_tail_x6_r0_body.st18.S0 = some (PRE_first_tail_x6_r0_body.st18.s4, PRE_first_tail_x6_r0_body.st18.S4) :=
  runOk_trans PRE_first_tail_x6_r0_body.st18.F (PRE_first_tail_x6_r0_body.st18.bodyOkL bytes rows) ((((nth? PRE_first_tail_x6_r0_body.st18.ks 0).getD 0) + ((nth? PRE_first_tail_x6_r0_body.st18.ks 1).getD 0)) + ((nth? PRE_first_tail_x6_r0_body.st18.ks 2).getD 0)) ((nth? PRE_first_tail_x6_r0_body.st18.ks 3).getD 0) PRE_first_tail_x6_r0_body.st18.s0 PRE_first_tail_x6_r0_body.st18.s3 PRE_first_tail_x6_r0_body.st18.s4 PRE_first_tail_x6_r0_body.st18.S0 PRE_first_tail_x6_r0_body.st18.S3 PRE_first_tail_x6_r0_body.st18.S4 (runOk_trans PRE_first_tail_x6_r0_body.st18.F (PRE_first_tail_x6_r0_body.st18.bodyOkL bytes rows) (((nth? PRE_first_tail_x6_r0_body.st18.ks 0).getD 0) + ((nth? PRE_first_tail_x6_r0_body.st18.ks 1).getD 0)) ((nth? PRE_first_tail_x6_r0_body.st18.ks 2).getD 0) PRE_first_tail_x6_r0_body.st18.s0 PRE_first_tail_x6_r0_body.st18.s2 PRE_first_tail_x6_r0_body.st18.s3 PRE_first_tail_x6_r0_body.st18.S0 PRE_first_tail_x6_r0_body.st18.S2 PRE_first_tail_x6_r0_body.st18.S3 (runOk_trans PRE_first_tail_x6_r0_body.st18.F (PRE_first_tail_x6_r0_body.st18.bodyOkL bytes rows) ((nth? PRE_first_tail_x6_r0_body.st18.ks 0).getD 0) ((nth? PRE_first_tail_x6_r0_body.st18.ks 1).getD 0) PRE_first_tail_x6_r0_body.st18.s0 PRE_first_tail_x6_r0_body.st18.s1 PRE_first_tail_x6_r0_body.st18.s2 PRE_first_tail_x6_r0_body.st18.S0 PRE_first_tail_x6_r0_body.st18.S1 PRE_first_tail_x6_r0_body.st18.S2 ((congrFun (congrFun PRE_first_tail_x6_r0_body.st18.bodyK0 bytes) rows)) (congrFun (congrFun PRE_first_tail_x6_r0_body.st18.bodyK1 bytes) rows)) (congrFun (congrFun PRE_first_tail_x6_r0_body.st18.bodyK2 bytes) rows)) (congrFun (congrFun PRE_first_tail_x6_r0_body.st18.bodyK3 bytes) rows)

theorem PRE_first_tail_x6_r0_body.st18.bodyLocal (bytes : List Byte) (rows : Nat) : ∀ s S, PRE_first_tail_x6_r0_body.st18.bodyOkL bytes rows s S = true → Disp.localB s = true := okLocal_localB

noncomputable def PRE_first_tail_x6_r0_body.st18.bodyTpl (bytes : List Byte) (rows : Nat) : Host.Ts.Sim.Stage.StageTpl PRE_first_tail_x6_r0_body.st18.F (PRE_first_tail_x6_r0_body.st18.bodyOkL bytes rows) where
  s0 := PRE_first_tail_x6_r0_body.st18.s0
  S0 := PRE_first_tail_x6_r0_body.st18.S0
  s1 := PRE_first_tail_x6_r0_body.st18.s4
  S1 := PRE_first_tail_x6_r0_body.st18.S4
  s2 := PRE_first_tail_x6_r0_body.st18.s5
  S2 := PRE_first_tail_x6_r0_body.st18.S5
  n := 11334
  ok0 := congrFun (congrFun PRE_first_tail_x6_r0_body.st18.bodyAccepted0 bytes) rows
  run := PRE_first_tail_x6_r0_body.st18.bodyRun bytes rows
  ok1 := congrFun (congrFun PRE_first_tail_x6_r0_body.st18.bodyAccepted1 bytes) rows
  halt := PRE_first_tail_x6_r0_body.st18.bodyHalt
  last := PRE_first_tail_x6_r0_body.st18.bodyLast
  top := noBlockTop_sound PRE_first_tail_x6_r0_body.st18.bodyTopCheck
end Host.Load.Run.Tpl
end

section -- SiteC19
set_option Elab.async false
namespace Host.Load.Run.Tpl
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
open Host.Ts Host.Ts.Sim Host.Ts.Sim.Template

/-! The compaction after the merge at call site 19 of chain `PRE_first_tail_x6_r0_body` (`Conv.compact`, `Conv.full_compactQ`): the canonical
state `PRE_first_tail_x6_r0_body.s199` (the stage's results at canonical places, its trace the call's) under `PRE_first_tail_x6_r0_body.kappa19` into the merged state
`PRE_first_tail_x6_r0_body.s198`. -/

def PRE_first_tail_x6_r0_body.pl19 : List Nat := []
def PRE_first_tail_x6_r0_body.nr19 : List Nat := []
/-- The native part of the compaction map (canonical → merged handles and nodes: its `big`, `region`, `nodeF`). -/
def PRE_first_tail_x6_r0_body.kd19 : RData :=
  ⟨2689883, 2689885, Stage.setAll PTrie.nil [], Stage.setAll PTrie.nil [],
   18582, 18582, 15681, 15681, Stage.setAll PTrie.nil [],
   Stage.setAll PTrie.nil []⟩
/-- **The compaction map.** -/
noncomputable def PRE_first_tail_x6_r0_body.kappa19 : Map :=
  Conv.Map.compact 2689883 2689885 893 PRE_first_tail_x6_r0_body.pl19 (PRE_first_tail_x6_r0_body.nr19.map NumV.ref) PRE_first_tail_x6_r0_body.kd19.big
    PRE_first_tail_x6_r0_body.kd19.region PRE_first_tail_x6_r0_body.kd19.nodeF
/-- The canonical result variables and their images, the merged state's entries (`Conv.compactθ`). -/
def PRE_first_tail_x6_r0_body.cws19 : List Nat := []
noncomputable def PRE_first_tail_x6_r0_body.crs19 : List SymE := PRE_first_tail_x6_r0_body.nr19.map fun r => (nth? PRE_first_tail_x6_r0_body.S198.tab r).getD (.var 0)
noncomputable def PRE_first_tail_x6_r0_body.ctheta19 : Nat → SymE := Conv.compactθ PRE_first_tail_x6_r0_body.cws19 PRE_first_tail_x6_r0_body.crs19
/-- The call's entries the stage wrote (renamed in the canonical state with the results). -/
def PRE_first_tail_x6_r0_body.wrB19 : List Nat := [2665, 2673467]

kernel_rfl PRE_first_tail_x6_r0_body.ctab19 : PRE_first_tail_x6_r0_body.S199.tab = PRE_first_tail_x6_r0_body.S197.tab ++ PRE_first_tail_x6_r0_body.cws19.map SymE.var
kernel_rfl PRE_first_tail_x6_r0_body.ctrace19 : PRE_first_tail_x6_r0_body.s199.trace = PRE_first_tail_x6_r0_body.s197.trace
kernel_rfl PRE_first_tail_x6_r0_body.cnext19 : PRE_first_tail_x6_r0_body.s199.next = 2689883
kernel_rfl PRE_first_tail_x6_r0_body.ccounters19 : ((Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.s199.ffi).mlx.next, (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.s199.ffi).mlx.nnext) = (18582, 15681)
-- the merged state's readback queue, carried to the canonical state (`Conv.FullShiftQ.tokens`, `tokSupp`)
kernel_rfl PRE_first_tail_x6_r0_body.cqueue19 : (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.s198.ffi).mlx.tokens = (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.s199.ffi).mlx.tokens.map PRE_first_tail_x6_r0_body.kappa19.nv
kernel_rfl PRE_first_tail_x6_r0_body.ctokSupp19 : (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.s199.ffi).mlx.tokens.all (bSN 893) = true
-- the written and the result entries carry no bigint of the canonical fresh band [next, E) and no fresh region
kernel_rfl PRE_first_tail_x6_r0_body.cclean19 : Conv.cleanListB 18582 131072 (fun r => Nat.ble 74328 r) PRE_first_tail_x6_r0_body.s199
    (PRE_first_tail_x6_r0_body.wrB19 ++ (List.range 0).map (2689883 + ·)) = true
kernel_rfl PRE_first_tail_x6_r0_body.cbigs19 : bigsOutB 18582 131072 (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.s199.ffi).mlx = true

end Host.Load.Run.Tpl
end

section -- SiteK19
set_option Elab.async false
namespace Host.Load.Run.Tpl
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
open Host.Ts Host.Ts.Sim Host.Ts.Sim.Template

/-! The canonical state's closedness from the call's (`Conv.closed_of_callB`, `Conv.sst_of_callB`): it keeps the call's entries
off the written and the result ones (`PRE_first_tail_x6_r0_body.cl19`; natively the written and result handles, the result nodes, the written
and result items), and those are checked. -/

def PRE_first_tail_x6_r0_body.cl19 : List Nat := [2665, 2673467]
def PRE_first_tail_x6_r0_body.clo19 : List Nat := []
def PRE_first_tail_x6_r0_body.cln19 : List Nat := []
def PRE_first_tail_x6_r0_body.cli19 : List Nat := []
kernel_rfl PRE_first_tail_x6_r0_body.cheap19 : PRE_first_tail_x6_r0_body.s199.heap = Stage.setAll PRE_first_tail_x6_r0_body.s197.heap (PRE_first_tail_x6_r0_body.cl19.filterMap fun a => (PRE_first_tail_x6_r0_body.s199.heap.get a).map (a, ·))
kernel_rfl PRE_first_tail_x6_r0_body.cnextLe19 : Nat.ble PRE_first_tail_x6_r0_body.s197.next PRE_first_tail_x6_r0_body.s199.next = true
kernel_rfl PRE_first_tail_x6_r0_body.ckeepP19 : Conv.keptPresentB PRE_first_tail_x6_r0_body.s197 PRE_first_tail_x6_r0_body.s199 PRE_first_tail_x6_r0_body.cl19 = true
kernel_rfl PRE_first_tail_x6_r0_body.csupp19 : Conv.suppListB PRE_first_tail_x6_r0_body.s199 893 PRE_first_tail_x6_r0_body.cl19 = true
kernel_rfl PRE_first_tail_x6_r0_body.cbound19 : Conv.boundListB PRE_first_tail_x6_r0_body.s199 PRE_first_tail_x6_r0_body.cl19 = true
kernel_rfl PRE_first_tail_x6_r0_body.cnodesK19 : (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.s199.ffi).mlx.nodes = Stage.setAll (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.s197.ffi).mlx.nodes (PRE_first_tail_x6_r0_body.cln19.filterMap fun i => ((Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.s199.ffi).mlx.nodes.get i).map (i, ·))
kernel_rfl PRE_first_tail_x6_r0_body.cobjsK19 : (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.s199.ffi).mlx.objs = Stage.setAll (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.s197.ffi).mlx.objs (PRE_first_tail_x6_r0_body.clo19.filterMap fun i => ((Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.s199.ffi).mlx.objs.get i).map (i, ·))
kernel_rfl PRE_first_tail_x6_r0_body.citemsK19 : (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.s199.ffi).mlx.items = Stage.setAll (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.s197.ffi).mlx.items (PRE_first_tail_x6_r0_body.cli19.filterMap fun i => ((Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.s199.ffi).mlx.items.get i).map (i, ·))
kernel_rfl PRE_first_tail_x6_r0_body.csst19 : Conv.sstListB 893 (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.s199.ffi).mlx PRE_first_tail_x6_r0_body.cln19 PRE_first_tail_x6_r0_body.clo19 PRE_first_tail_x6_r0_body.cli19 = true

end Host.Load.Run.Tpl
end

section -- SiteCl19
set_option Elab.async false
namespace Host.Load.Run.Tpl
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
open Host.Ts Host.Ts.Sim Host.Ts.Sim.Template

kernel_rfl PRE_first_tail_x6_r0_body.ckA19 : (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.s199.ffi).mlx.arrs = Stage.setAll (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.s197.ffi).mlx.arrs (PRE_first_tail_x6_r0_body.clo19.filterMap fun i => ((Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.s199.ffi).mlx.arrs.get i).map (i, ·))
kernel_rfl PRE_first_tail_x6_r0_body.cbd19 : (PRE_first_tail_x6_r0_body.clo19 ++ PRE_first_tail_x6_r0_body.cln19 ++ PRE_first_tail_x6_r0_body.cli19).all (fun i => Nat.blt (i / 4096) (4 ^ 31)) = true
kernel_rfl PRE_first_tail_x6_r0_body.cle19 : Conv.Cnt.leB (⟨18582, 15681, 2689883, 893⟩ : Conv.Cnt) (⟨18582, 15681, 2689883, 893⟩ : Conv.Cnt) = true
kernel_rfl PRE_first_tail_x6_r0_body.cck19 : Conv.ncleanListB (⟨18582, 15681, 2689883, 893⟩ : Conv.Cnt) (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.s199.ffi).mlx PRE_first_tail_x6_r0_body.clo19 PRE_first_tail_x6_r0_body.cln19 PRE_first_tail_x6_r0_body.cli19 = true
theorem PRE_first_tail_x6_r0_body.cncl19 (h : Conv.NClean (⟨18582, 15681, 2689883, 893⟩ : Conv.Cnt) (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.s197.ffi).mlx) : Conv.NClean (⟨18582, 15681, 2689883, 893⟩ : Conv.Cnt) (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.s199.ffi).mlx :=
  Conv.NClean.stepKeep h PRE_first_tail_x6_r0_body.cle19 PRE_first_tail_x6_r0_body.ckA19 PRE_first_tail_x6_r0_body.cobjsK19 PRE_first_tail_x6_r0_body.cnodesK19 PRE_first_tail_x6_r0_body.citemsK19 PRE_first_tail_x6_r0_body.cbd19 PRE_first_tail_x6_r0_body.cck19

end Host.Load.Run.Tpl
end

section -- SiteS19
set_option Elab.async false
namespace Host.Load.Run.Tpl
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
open Host.Ts Host.Ts.Sim Host.Ts.Sim.Template

/-! The compaction's native shift at call site 19 from its footprint (`Conv.nshift_of_foot`), and the observers'
(`liveShift_foot`, `kernShift_foot`): `Conv.FullShiftQ` for `Conv.full_compactQ`, given the call's bookkeeping and its
relation's facts. -/

/-- The load parameters of the chain (band-free: its start's node counter as `NL` and `N0`). -/
def PRE_first_tail_x6_r0_body.Pc19 : LoadP := ⟨18151, 131072, 1099511627776, 15235, 15235, []⟩
/-- The site's band raised to the map's checked fixed-node prefix, including newly recorded closure traces. -/
def PRE_first_tail_x6_r0_body.P19 : LoadP := PRE_first_tail_x6_r0_body.Pc19.raise 15681
kernel_rfl PRE_first_tail_x6_r0_body.craise19 : Nat.ble PRE_first_tail_x6_r0_body.Pc19.N0 15681 = true
theorem PRE_first_tail_x6_r0_body.raised19 : Host.Ts.Sim.Full.Raised PRE_first_tail_x6_r0_body.Pc19 PRE_first_tail_x6_r0_body.P19 :=
  .inr ⟨15681, rfl, Nat.le_of_ble_eq_true PRE_first_tail_x6_r0_body.craise19, rfl⟩
noncomputable abbrev PRE_first_tail_x6_r0_body.cx0_19 : Host.Load.LSt := clearTokens (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.s199.ffi)
noncomputable abbrev PRE_first_tail_x6_r0_body.cx1_19 : Host.Load.LSt := clearTokens (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.s198.ffi)
def PRE_first_tail_x6_r0_body.khinv19 : PTrie Nat := Stage.setAll PTrie.nil []
def PRE_first_tail_x6_r0_body.kninv19 : PTrie Nat := Stage.setAll PTrie.nil []
/-- The stage's footprint: its written and fresh handles, fresh nodes, written and fresh items. -/
def PRE_first_tail_x6_r0_body.cwS19 : List Nat := []
def PRE_first_tail_x6_r0_body.cnS19 : List Nat := List.range' 15681 0
def PRE_first_tail_x6_r0_body.ciS19 : List Nat := [] ++ List.range' 15681 0

-- the small checks (`MChecks`'s)
kernel_rfl PRE_first_tail_x6_r0_body.cnh019 : PRE_first_tail_x6_r0_body.kd19.nh0 = PRE_first_tail_x6_r0_body.cx0_19.mlx.next
kernel_rfl PRE_first_tail_x6_r0_body.cnh119 : PRE_first_tail_x6_r0_body.kd19.nh1 = PRE_first_tail_x6_r0_body.cx1_19.mlx.next
kernel_rfl PRE_first_tail_x6_r0_body.cnn019 : PRE_first_tail_x6_r0_body.kd19.nn0 = PRE_first_tail_x6_r0_body.cx0_19.mlx.nnext
kernel_rfl PRE_first_tail_x6_r0_body.cnn119 : PRE_first_tail_x6_r0_body.kd19.nn1 = PRE_first_tail_x6_r0_body.cx1_19.mlx.nnext
kernel_rfl PRE_first_tail_x6_r0_body.cplo19 : (Nat.blt 0 PRE_first_tail_x6_r0_body.P19.lo && Nat.ble PRE_first_tail_x6_r0_body.P19.lo PRE_first_tail_x6_r0_body.cx0_19.mlx.next && Nat.ble PRE_first_tail_x6_r0_body.P19.lo RData.bigHi && Nat.ble RData.bigHi PRE_first_tail_x6_r0_body.P19.E) = true
kernel_rfl PRE_first_tail_x6_r0_body.ccnt19 : (Nat.ble PRE_first_tail_x6_r0_body.cx0_19.mlx.next PRE_first_tail_x6_r0_body.cx1_19.mlx.next && Nat.ble PRE_first_tail_x6_r0_body.cx0_19.mlx.nnext PRE_first_tail_x6_r0_body.cx1_19.mlx.nnext) = true
kernel_rfl PRE_first_tail_x6_r0_body.cnband19 : (Nat.blt 0 PRE_first_tail_x6_r0_body.P19.NL && Nat.ble PRE_first_tail_x6_r0_body.P19.NL PRE_first_tail_x6_r0_body.P19.N0 && Nat.ble PRE_first_tail_x6_r0_body.P19.N0 PRE_first_tail_x6_r0_body.cx0_19.mlx.nnext) = true
kernel_rfl PRE_first_tail_x6_r0_body.chbelow19 : PRE_first_tail_x6_r0_body.kd19.checkHndBelow = true
kernel_rfl PRE_first_tail_x6_r0_body.chren19 : checkRenG PRE_first_tail_x6_r0_body.kd19.hnd PRE_first_tail_x6_r0_body.khinv19 (phB PRE_first_tail_x6_r0_body.cx0_19.mlx) = true
kernel_rfl PRE_first_tail_x6_r0_body.cband19 : PRE_first_tail_x6_r0_body.kd19.checkBand PRE_first_tail_x6_r0_body.P19.lo = true
kernel_rfl PRE_first_tail_x6_r0_body.cnh1pos19 : Nat.blt 0 PRE_first_tail_x6_r0_body.kd19.nh1 = true
kernel_rfl PRE_first_tail_x6_r0_body.cnren19 : checkRenG PRE_first_tail_x6_r0_body.kd19.node PRE_first_tail_x6_r0_body.kninv19 (pnB PRE_first_tail_x6_r0_body.cx0_19.mlx) = true
kernel_rfl PRE_first_tail_x6_r0_body.cnlow19 : (PTrie.keysA PRE_first_tail_x6_r0_body.kd19.node).all (fun j => Nat.ble PRE_first_tail_x6_r0_body.P19.NL j && Nat.blt (PRE_first_tail_x6_r0_body.kd19.nodeF j) PRE_first_tail_x6_r0_body.cx1_19.mlx.nnext) = true
kernel_rfl PRE_first_tail_x6_r0_body.cabs0a19 : PRE_first_tail_x6_r0_body.cx0_19.mlx.arrs.get 0 = none
kernel_rfl PRE_first_tail_x6_r0_body.cabs0b19 : PRE_first_tail_x6_r0_body.cx0_19.mlx.objs.get 0 = none
kernel_rfl PRE_first_tail_x6_r0_body.ctok119 : PRE_first_tail_x6_r0_body.cx1_19.mlx.tokens = []
kernel_rfl PRE_first_tail_x6_r0_body.cpend19 : PRE_first_tail_x6_r0_body.cx1_19.mlx.pending = PRE_first_tail_x6_r0_body.cx0_19.mlx.pending.map PRE_first_tail_x6_r0_body.kappa19.pend
kernel_rfl PRE_first_tail_x6_r0_body.cerrh19 : PRE_first_tail_x6_r0_body.cx1_19.mlx.errh = PRE_first_tail_x6_r0_body.cx0_19.mlx.errh.map PRE_first_tail_x6_r0_body.kappa19.arg
kernel_rfl PRE_first_tail_x6_r0_body.cfiles19 : PRE_first_tail_x6_r0_body.cx1_19.mlx.files = PRE_first_tail_x6_r0_body.cx0_19.mlx.files
kernel_rfl PRE_first_tail_x6_r0_body.carch19 : PRE_first_tail_x6_r0_body.cx1_19.mlx.arch = PRE_first_tail_x6_r0_body.cx0_19.mlx.arch
kernel_rfl PRE_first_tail_x6_r0_body.csizes19 : PRE_first_tail_x6_r0_body.cx1_19.mlx.deviceSizes = PRE_first_tail_x6_r0_body.cx0_19.mlx.deviceSizes
kernel_rfl PRE_first_tail_x6_r0_body.cwired19 : PRE_first_tail_x6_r0_body.cx1_19.mlx.wired = PRE_first_tail_x6_r0_body.cx0_19.mlx.wired
kernel_rfl PRE_first_tail_x6_r0_body.chost19 : PRE_first_tail_x6_r0_body.cx1_19.host = PRE_first_tail_x6_r0_body.cx0_19.host
-- the compaction map's addresses are `PRE_first_tail_x6_r0_body.kd19`'s
kernel_rfl PRE_first_tail_x6_r0_body.ckn019 : PRE_first_tail_x6_r0_body.kd19.n0 = 2689883
kernel_rfl PRE_first_tail_x6_r0_body.ckn119 : PRE_first_tail_x6_r0_body.kd19.n1 = 2689885
kernel_rfl PRE_first_tail_x6_r0_body.ckheap19 : (PTrie.keysA PRE_first_tail_x6_r0_body.kd19.heap).all (fun x => Nat.ble 2689883 x) = true
kernel_rfl PRE_first_tail_x6_r0_body.ckpl19 : (List.range 0).all (fun j => decide (PRE_first_tail_x6_r0_body.kd19.heap.get (2689883 + j) = nth? PRE_first_tail_x6_r0_body.pl19 j)) = true
-- the map fixes the call's names (`Conv.fixOld_compact`), the call's counters
kernel_rfl PRE_first_tail_x6_r0_body.fja19 : Nat.ble 2689883 2689883 = true
kernel_rfl PRE_first_tail_x6_r0_body.fn19 : Nat.ble 893 893 = true
kernel_rfl PRE_first_tail_x6_r0_body.fjaD19 : Nat.ble 2689883 PRE_first_tail_x6_r0_body.kd19.n0 = true
kernel_rfl PRE_first_tail_x6_r0_body.fxn19 : Nat.ble 18582 PRE_first_tail_x6_r0_body.kd19.nh0 = true
kernel_rfl PRE_first_tail_x6_r0_body.fnn19 : Nat.ble 15681 PRE_first_tail_x6_r0_body.kd19.nn0 = true
kernel_rfl PRE_first_tail_x6_r0_body.fxb19 : Nat.ble 18582 RData.bigHi = true
kernel_rfl PRE_first_tail_x6_r0_body.fheap19 : (PTrie.keysA PRE_first_tail_x6_r0_body.kd19.heap).all (Nat.ble (⟨18582, 15681, 2689883, 893⟩ : Conv.Cnt).ja) = true
kernel_rfl PRE_first_tail_x6_r0_body.fhnd19 : (PTrie.keysA PRE_first_tail_x6_r0_body.kd19.hnd).all (Nat.ble (⟨18582, 15681, 2689883, 893⟩ : Conv.Cnt).xn) = true
kernel_rfl PRE_first_tail_x6_r0_body.fnode19 : (PTrie.keysA PRE_first_tail_x6_r0_body.kd19.node).all (Nat.ble (⟨18582, 15681, 2689883, 893⟩ : Conv.Cnt).nn) = true
/-- The compaction map fixes the call's names. -/
theorem PRE_first_tail_x6_r0_body.cfix19 : Conv.FixOld (⟨18582, 15681, 2689883, 893⟩ : Conv.Cnt) PRE_first_tail_x6_r0_body.kappa19 :=
  Conv.fixOld_compact (Nat.le_of_ble_eq_true PRE_first_tail_x6_r0_body.fja19) (Nat.le_of_ble_eq_true PRE_first_tail_x6_r0_body.fn19) (Nat.le_of_ble_eq_true PRE_first_tail_x6_r0_body.fjaD19) (Nat.le_of_ble_eq_true PRE_first_tail_x6_r0_body.fxn19) (Nat.le_of_ble_eq_true PRE_first_tail_x6_r0_body.fnn19) (Nat.le_of_ble_eq_true PRE_first_tail_x6_r0_body.fxb19) PRE_first_tail_x6_r0_body.fheap19 PRE_first_tail_x6_r0_body.fhnd19 PRE_first_tail_x6_r0_body.fnode19
kernel_rfl PRE_first_tail_x6_r0_body.fcxn19 : (⟨18582, 15681, 2689883, 893⟩ : Conv.Cnt).xn = (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.s197.ffi).mlx.next
kernel_rfl PRE_first_tail_x6_r0_body.fcnn19 : (⟨18582, 15681, 2689883, 893⟩ : Conv.Cnt).nn = (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.s197.ffi).mlx.nnext
kernel_rfl PRE_first_tail_x6_r0_body.fle019 : (Nat.ble (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.s197.ffi).mlx.next PRE_first_tail_x6_r0_body.cx0_19.mlx.next && Nat.ble (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.s197.ffi).mlx.nnext PRE_first_tail_x6_r0_body.cx0_19.mlx.nnext && Nat.ble (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.s197.ffi).mlx.next RData.bigHi) = true
kernel_rfl PRE_first_tail_x6_r0_body.fnk19 : (PTrie.keysA PRE_first_tail_x6_r0_body.kd19.node).all (Nat.ble (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.s197.ffi).mlx.nnext) = true
-- the merged state keeps the call's entries off the stage's footprint
kernel_rfl PRE_first_tail_x6_r0_body.f1A19 : PRE_first_tail_x6_r0_body.cx1_19.mlx.arrs = Stage.setAll (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.s197.ffi).mlx.arrs (PRE_first_tail_x6_r0_body.cwS19.filterMap fun i => (PRE_first_tail_x6_r0_body.cx1_19.mlx.arrs.get i).map (i, ·))
kernel_rfl PRE_first_tail_x6_r0_body.f1O19 : PRE_first_tail_x6_r0_body.cx1_19.mlx.objs = Stage.setAll (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.s197.ffi).mlx.objs (PRE_first_tail_x6_r0_body.cwS19.filterMap fun i => (PRE_first_tail_x6_r0_body.cx1_19.mlx.objs.get i).map (i, ·))
kernel_rfl PRE_first_tail_x6_r0_body.f1N19 : PRE_first_tail_x6_r0_body.cx1_19.mlx.nodes = Stage.setAll (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.s197.ffi).mlx.nodes (PRE_first_tail_x6_r0_body.cnS19.filterMap fun i => (PRE_first_tail_x6_r0_body.cx1_19.mlx.nodes.get i).map (i, ·))
kernel_rfl PRE_first_tail_x6_r0_body.f1I19 : PRE_first_tail_x6_r0_body.cx1_19.mlx.items = Stage.setAll (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.s197.ffi).mlx.items (PRE_first_tail_x6_r0_body.ciS19.filterMap fun i => (PRE_first_tail_x6_r0_body.cx1_19.mlx.items.get i).map (i, ·))
kernel_rfl PRE_first_tail_x6_r0_body.fbd19 : (PRE_first_tail_x6_r0_body.clo19 ++ PRE_first_tail_x6_r0_body.cln19 ++ PRE_first_tail_x6_r0_body.cli19 ++ PRE_first_tail_x6_r0_body.cwS19 ++ PRE_first_tail_x6_r0_body.cnS19 ++ PRE_first_tail_x6_r0_body.ciS19).all (fun i => Nat.blt (i / 4096) (4 ^ 31)) = true
kernel_rfl PRE_first_tail_x6_r0_body.fincW19 : PRE_first_tail_x6_r0_body.cwS19.all (fun h => !Nat.blt h (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.s197.ffi).mlx.next || PRE_first_tail_x6_r0_body.clo19.contains h) = true
kernel_rfl PRE_first_tail_x6_r0_body.fincI19 : PRE_first_tail_x6_r0_body.ciS19.all (fun k => !Nat.blt k (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.s197.ffi).mlx.nnext || PRE_first_tail_x6_r0_body.cli19.contains k) = true
kernel_rfl PRE_first_tail_x6_r0_body.fincN19 : PRE_first_tail_x6_r0_body.cnS19.all (Nat.ble (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.s197.ffi).mlx.nnext) = true
kernel_rfl PRE_first_tail_x6_r0_body.flnF19 : PRE_first_tail_x6_r0_body.cln19.all (Nat.ble (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.s197.ffi).mlx.nnext) = true
-- the checks over the changed lists
kernel_rfl PRE_first_tail_x6_r0_body.fh19 : PRE_first_tail_x6_r0_body.clo19.all (handleOK PRE_first_tail_x6_r0_body.kappa19 PRE_first_tail_x6_r0_body.P19.lo PRE_first_tail_x6_r0_body.cx0_19.mlx PRE_first_tail_x6_r0_body.cx1_19.mlx) = true
kernel_rfl PRE_first_tail_x6_r0_body.fo19 : PRE_first_tail_x6_r0_body.clo19.map (fun h => PRE_first_tail_x6_r0_body.cx1_19.mlx.objs.get (PRE_first_tail_x6_r0_body.kappa19.handle h)) = PRE_first_tail_x6_r0_body.clo19.map (fun h => (PRE_first_tail_x6_r0_body.cx0_19.mlx.objs.get h).map PRE_first_tail_x6_r0_body.kappa19.nobj)
kernel_rfl PRE_first_tail_x6_r0_body.fok19 : PRE_first_tail_x6_r0_body.clo19.all (objOK PRE_first_tail_x6_r0_body.kappa19 PRE_first_tail_x6_r0_body.P19.NL PRE_first_tail_x6_r0_body.cx0_19.mlx) = true
kernel_rfl PRE_first_tail_x6_r0_body.fnd19 : PRE_first_tail_x6_r0_body.cln19.all (nodeOKF PRE_first_tail_x6_r0_body.kappa19 PRE_first_tail_x6_r0_body.P19 PRE_first_tail_x6_r0_body.cx0_19.mlx PRE_first_tail_x6_r0_body.cx1_19.mlx) = true
kernel_rfl PRE_first_tail_x6_r0_body.fp19 : ((PRE_first_tail_x6_r0_body.cln19.filter (fullB PRE_first_tail_x6_r0_body.P19))).map (fun i => (PRE_first_tail_x6_r0_body.cx1_19.mlx.nodes.get (PRE_first_tail_x6_r0_body.kappa19.node i)).map Host.Mlx.Ffi.Node.prim) =
  ((PRE_first_tail_x6_r0_body.cln19.filter (fullB PRE_first_tail_x6_r0_body.P19))).map (fun i => (PRE_first_tail_x6_r0_body.cx0_19.mlx.nodes.get i).map fun nd => PRE_first_tail_x6_r0_body.kappa19.prim nd.prim)
kernel_rfl PRE_first_tail_x6_r0_body.fnordI19 : incrB PRE_first_tail_x6_r0_body.kd19.nodeF (List.range' 15681 0) = true
kernel_rfl PRE_first_tail_x6_r0_body.fnordK19 : (PTrie.keysA PRE_first_tail_x6_r0_body.kd19.node).all (fun k => Nat.ble 15681 k && Nat.blt k 15681) = true
kernel_rfl PRE_first_tail_x6_r0_body.fnordL19 : (PRE_first_tail_x6_r0_body.cln19.filter (Nat.ble PRE_first_tail_x6_r0_body.P19.N0)).all (fun i => Nat.ble i (PRE_first_tail_x6_r0_body.kd19.nodeF i) && (Nat.blt i 15681 || Nat.ble PRE_first_tail_x6_r0_body.kd19.nn0 i)) = true
theorem PRE_first_tail_x6_r0_body.fnord19 : (PRE_first_tail_x6_r0_body.cln19.filter (Nat.ble PRE_first_tail_x6_r0_body.P19.N0)).all (fun i => Nat.ble i (PRE_first_tail_x6_r0_body.kd19.nodeF i) &&
    (PTrie.keysA PRE_first_tail_x6_r0_body.kd19.node).all fun j => !Nat.blt j i || Nat.blt (PRE_first_tail_x6_r0_body.kd19.nodeF j) (PRE_first_tail_x6_r0_body.kd19.nodeF i)) = true :=
  cnord_of PRE_first_tail_x6_r0_body.cnlow19 PRE_first_tail_x6_r0_body.cnn119 PRE_first_tail_x6_r0_body.fnordI19 PRE_first_tail_x6_r0_body.fnordK19 PRE_first_tail_x6_r0_body.fnordL19
kernel_rfl PRE_first_tail_x6_r0_body.fi19 : PRE_first_tail_x6_r0_body.cli19.all (pnB PRE_first_tail_x6_r0_body.cx0_19.mlx) = true
kernel_rfl PRE_first_tail_x6_r0_body.fii19 : PRE_first_tail_x6_r0_body.cli19.all (fun k => decide (PRE_first_tail_x6_r0_body.cx1_19.mlx.items.get (PRE_first_tail_x6_r0_body.kappa19.node k) = (PRE_first_tail_x6_r0_body.cx0_19.mlx.items.get k).map PRE_first_tail_x6_r0_body.kappa19.nv)) = true
/-- **The compaction's footprint.** -/
theorem PRE_first_tail_x6_r0_body.cfoot19 (clean : Conv.NClean (⟨18582, 15681, 2689883, 893⟩ : Conv.Cnt) (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.s197.ffi).mlx) (hltC : ∀ h, PH (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.s197.ffi).mlx h → h < (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.s197.ffi).mlx.next) (nltC : ∀ i, PN (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.s197.ffi).mlx i → i < (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.s197.ffi).mlx.nnext) (itemsC : ∀ k v, (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.s197.ffi).mlx.items.get k = some v → PN (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.s197.ffi).mlx k) (tracedC : ∀ h o, (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.s197.ffi).mlx.objs.get h = some o → ∀ i ∈ objTraces o, i < PRE_first_tail_x6_r0_body.P19.NL) (cl : SSt (· < 893) PRE_first_tail_x6_r0_body.cx0_19.mlx) :
    Conv.MFoot PRE_first_tail_x6_r0_body.P19 893 PRE_first_tail_x6_r0_body.kappa19 PRE_first_tail_x6_r0_body.kd19 PRE_first_tail_x6_r0_body.khinv19 PRE_first_tail_x6_r0_body.kninv19 (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.s197.ffi).mlx PRE_first_tail_x6_r0_body.cx0_19.mlx PRE_first_tail_x6_r0_body.cx1_19.mlx (⟨18582, 15681, 2689883, 893⟩ : Conv.Cnt) PRE_first_tail_x6_r0_body.clo19 PRE_first_tail_x6_r0_body.cln19 PRE_first_tail_x6_r0_body.cli19 PRE_first_tail_x6_r0_body.cwS19 PRE_first_tail_x6_r0_body.cnS19 PRE_first_tail_x6_r0_body.ciS19 :=
  ⟨rfl, rfl, rfl, PRE_first_tail_x6_r0_body.cnh019, PRE_first_tail_x6_r0_body.cnh119, PRE_first_tail_x6_r0_body.cnn019, PRE_first_tail_x6_r0_body.cnn119, PRE_first_tail_x6_r0_body.cplo19, PRE_first_tail_x6_r0_body.ccnt19, PRE_first_tail_x6_r0_body.cnband19, PRE_first_tail_x6_r0_body.chbelow19, PRE_first_tail_x6_r0_body.chren19, PRE_first_tail_x6_r0_body.cband19, PRE_first_tail_x6_r0_body.cnh1pos19, PRE_first_tail_x6_r0_body.cnren19, PRE_first_tail_x6_r0_body.cnlow19, PRE_first_tail_x6_r0_body.cabs0a19, PRE_first_tail_x6_r0_body.cabs0b19, PRE_first_tail_x6_r0_body.ctok119, PRE_first_tail_x6_r0_body.cpend19, PRE_first_tail_x6_r0_body.cerrh19, PRE_first_tail_x6_r0_body.cfiles19, PRE_first_tail_x6_r0_body.carch19, PRE_first_tail_x6_r0_body.csizes19, PRE_first_tail_x6_r0_body.cwired19, PRE_first_tail_x6_r0_body.cfix19, clean, PRE_first_tail_x6_r0_body.fcxn19, PRE_first_tail_x6_r0_body.fcnn19, hltC, nltC, itemsC, tracedC, cl, PRE_first_tail_x6_r0_body.fle019, PRE_first_tail_x6_r0_body.fnk19, PRE_first_tail_x6_r0_body.ckA19, PRE_first_tail_x6_r0_body.cobjsK19, PRE_first_tail_x6_r0_body.cnodesK19, PRE_first_tail_x6_r0_body.citemsK19, PRE_first_tail_x6_r0_body.f1A19, PRE_first_tail_x6_r0_body.f1O19, PRE_first_tail_x6_r0_body.f1N19, PRE_first_tail_x6_r0_body.f1I19, PRE_first_tail_x6_r0_body.fbd19, PRE_first_tail_x6_r0_body.fincW19, PRE_first_tail_x6_r0_body.fincI19, PRE_first_tail_x6_r0_body.fincN19, PRE_first_tail_x6_r0_body.flnF19, PRE_first_tail_x6_r0_body.fh19, PRE_first_tail_x6_r0_body.fo19, PRE_first_tail_x6_r0_body.fok19, PRE_first_tail_x6_r0_body.fnd19, PRE_first_tail_x6_r0_body.fp19, PRE_first_tail_x6_r0_body.fnord19, PRE_first_tail_x6_r0_body.fi19, PRE_first_tail_x6_r0_body.fii19⟩
theorem PRE_first_tail_x6_r0_body.cnshift19 (clean : Conv.NClean (⟨18582, 15681, 2689883, 893⟩ : Conv.Cnt) (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.s197.ffi).mlx) (hltC : ∀ h, PH (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.s197.ffi).mlx h → h < (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.s197.ffi).mlx.next) (nltC : ∀ i, PN (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.s197.ffi).mlx i → i < (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.s197.ffi).mlx.nnext) (itemsC : ∀ k v, (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.s197.ffi).mlx.items.get k = some v → PN (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.s197.ffi).mlx k) (tracedC : ∀ h o, (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.s197.ffi).mlx.objs.get h = some o → ∀ i ∈ objTraces o, i < PRE_first_tail_x6_r0_body.P19.NL) (cl : SSt (· < 893) PRE_first_tail_x6_r0_body.cx0_19.mlx) : NShift PRE_first_tail_x6_r0_body.P19 893 PRE_first_tail_x6_r0_body.kappa19 PRE_first_tail_x6_r0_body.cx0_19 PRE_first_tail_x6_r0_body.cx1_19 :=
  Conv.nshift_of_foot (PRE_first_tail_x6_r0_body.cfoot19 clean hltC nltC itemsC tracedC cl) PRE_first_tail_x6_r0_body.chost19 (compact_a_eq PRE_first_tail_x6_r0_body.ckn019 PRE_first_tail_x6_r0_body.ckn119 PRE_first_tail_x6_r0_body.ckheap19 PRE_first_tail_x6_r0_body.ckpl19)

-- the observers: the layers' states at the call, the canonical and the merged state, their footprints and checks
noncomputable def PRE_first_tail_x6_r0_body.fxC_19 : PTrie Unit := (Host.Ts.Sim.Full.freedOf PRE_first_tail_x6_r0_body.s197.ffi).getD PTrie.nil
noncomputable def PRE_first_tail_x6_r0_body.krC_19 : Host.Load.Layers.KRec := (Host.Ts.Sim.Full.krecOf PRE_first_tail_x6_r0_body.s197.ffi).getD Host.Load.Layers.KRec.empty
kernel_rfl PRE_first_tail_x6_r0_body.ofxC_19 : (Host.Ts.Sim.Full.freedOf PRE_first_tail_x6_r0_body.s197.ffi) = some PRE_first_tail_x6_r0_body.fxC_19
kernel_rfl PRE_first_tail_x6_r0_body.okrC_19 : (Host.Ts.Sim.Full.krecOf PRE_first_tail_x6_r0_body.s197.ffi) = some PRE_first_tail_x6_r0_body.krC_19
noncomputable def PRE_first_tail_x6_r0_body.fx0_19 : PTrie Unit := (Host.Ts.Sim.Full.freedOf PRE_first_tail_x6_r0_body.s199.ffi).getD PTrie.nil
noncomputable def PRE_first_tail_x6_r0_body.kr0_19 : Host.Load.Layers.KRec := (Host.Ts.Sim.Full.krecOf PRE_first_tail_x6_r0_body.s199.ffi).getD Host.Load.Layers.KRec.empty
kernel_rfl PRE_first_tail_x6_r0_body.ofx0_19 : (Host.Ts.Sim.Full.freedOf PRE_first_tail_x6_r0_body.s199.ffi) = some PRE_first_tail_x6_r0_body.fx0_19
kernel_rfl PRE_first_tail_x6_r0_body.okr0_19 : (Host.Ts.Sim.Full.krecOf PRE_first_tail_x6_r0_body.s199.ffi) = some PRE_first_tail_x6_r0_body.kr0_19
noncomputable def PRE_first_tail_x6_r0_body.fx1_19 : PTrie Unit := (Host.Ts.Sim.Full.freedOf PRE_first_tail_x6_r0_body.s198.ffi).getD PTrie.nil
noncomputable def PRE_first_tail_x6_r0_body.kr1_19 : Host.Load.Layers.KRec := (Host.Ts.Sim.Full.krecOf PRE_first_tail_x6_r0_body.s198.ffi).getD Host.Load.Layers.KRec.empty
kernel_rfl PRE_first_tail_x6_r0_body.ofx1_19 : (Host.Ts.Sim.Full.freedOf PRE_first_tail_x6_r0_body.s198.ffi) = some PRE_first_tail_x6_r0_body.fx1_19
kernel_rfl PRE_first_tail_x6_r0_body.okr1_19 : (Host.Ts.Sim.Full.krecOf PRE_first_tail_x6_r0_body.s198.ffi) = some PRE_first_tail_x6_r0_body.kr1_19
kernel_rfl PRE_first_tail_x6_r0_body.ff019 : PRE_first_tail_x6_r0_body.fx0_19 = Stage.setAll PRE_first_tail_x6_r0_body.fxC_19 (PRE_first_tail_x6_r0_body.clo19.filterMap fun i => (PRE_first_tail_x6_r0_body.fx0_19.get i).map (i, ·))
kernel_rfl PRE_first_tail_x6_r0_body.ff119 : PRE_first_tail_x6_r0_body.fx1_19 = Stage.setAll PRE_first_tail_x6_r0_body.fxC_19 (PRE_first_tail_x6_r0_body.cwS19.filterMap fun i => (PRE_first_tail_x6_r0_body.fx1_19.get i).map (i, ·))
kernel_rfl PRE_first_tail_x6_r0_body.ffck19 : freedLB PRE_first_tail_x6_r0_body.kappa19 PRE_first_tail_x6_r0_body.cx0_19.mlx PRE_first_tail_x6_r0_body.fx0_19 PRE_first_tail_x6_r0_body.fx1_19 PRE_first_tail_x6_r0_body.clo19 = true
kernel_rfl PRE_first_tail_x6_r0_body.fkf019 : PRE_first_tail_x6_r0_body.kr0_19.flags = Stage.setAll PRE_first_tail_x6_r0_body.krC_19.flags (PRE_first_tail_x6_r0_body.clo19.filterMap fun i => (PRE_first_tail_x6_r0_body.kr0_19.flags.get i).map (i, ·))
kernel_rfl PRE_first_tail_x6_r0_body.fkt019 : PRE_first_tail_x6_r0_body.kr0_19.targs = Stage.setAll PRE_first_tail_x6_r0_body.krC_19.targs (PRE_first_tail_x6_r0_body.clo19.filterMap fun i => (PRE_first_tail_x6_r0_body.kr0_19.targs.get i).map (i, ·))
kernel_rfl PRE_first_tail_x6_r0_body.fkf119 : PRE_first_tail_x6_r0_body.kr1_19.flags = Stage.setAll PRE_first_tail_x6_r0_body.krC_19.flags (PRE_first_tail_x6_r0_body.cwS19.filterMap fun i => (PRE_first_tail_x6_r0_body.kr1_19.flags.get i).map (i, ·))
kernel_rfl PRE_first_tail_x6_r0_body.fkt119 : PRE_first_tail_x6_r0_body.kr1_19.targs = Stage.setAll PRE_first_tail_x6_r0_body.krC_19.targs (PRE_first_tail_x6_r0_body.cwS19.filterMap fun i => (PRE_first_tail_x6_r0_body.kr1_19.targs.get i).map (i, ·))
kernel_rfl PRE_first_tail_x6_r0_body.fkck19 : krecLB PRE_first_tail_x6_r0_body.kappa19 893 PRE_first_tail_x6_r0_body.cx0_19.mlx PRE_first_tail_x6_r0_body.kr0_19 PRE_first_tail_x6_r0_body.kr1_19 PRE_first_tail_x6_r0_body.clo19 = true
kernel_rfl PRE_first_tail_x6_r0_body.fkn19 : Nat.ble 893 893 = true
-- the bridge and the pending traces' regions
kernel_rfl PRE_first_tail_x6_r0_body.cbridge19 : Host.Ts.Sim.Full.bridgeOf PRE_first_tail_x6_r0_body.s198.ffi = Host.Ts.Sim.Full.bridgeOf PRE_first_tail_x6_r0_body.s199.ffi
kernel_rfl PRE_first_tail_x6_r0_body.cpendR19 : pendRegB PRE_first_tail_x6_r0_body.kappa19 (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.s199.ffi).mlx = true
kernel_rfl PRE_first_tail_x6_r0_body.cpendLe19 : Nat.ble (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.s199.ffi).mlx.next (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.s198.ffi).mlx.next = true
/-- **The compaction's native shift**, given the call's bookkeeping, its relation's facts (the model's and the
observers') and the canonical closedness. -/
theorem PRE_first_tail_x6_r0_body.cshift19 (clean : Conv.NClean (⟨18582, 15681, 2689883, 893⟩ : Conv.Cnt) (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.s197.ffi).mlx) (hltC : ∀ h, PH (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.s197.ffi).mlx h → h < (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.s197.ffi).mlx.next) (nltC : ∀ i, PN (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.s197.ffi).mlx i → i < (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.s197.ffi).mlx.nnext) (itemsC : ∀ k v, (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.s197.ffi).mlx.items.get k = some v → PN (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.s197.ffi).mlx k) (tracedC : ∀ h o, (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.s197.ffi).mlx.objs.get h = some o → ∀ i ∈ objTraces o, i < PRE_first_tail_x6_r0_body.P19.NL) (cl : SSt (· < 893) PRE_first_tail_x6_r0_body.cx0_19.mlx)
    (hobjC : ∀ h, PRE_first_tail_x6_r0_body.fxC_19.get h = some () → ((Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.s197.ffi).mlx.objs.get h).isSome = true)
    (hfC : ∀ h, (PRE_first_tail_x6_r0_body.krC_19.flags.get h).isSome = true → ((Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.s197.ffi).mlx.objs.get h).isSome = true)
    (htC : ∀ h, (PRE_first_tail_x6_r0_body.krC_19.targs.get h).isSome = true → ((Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.s197.ffi).mlx.objs.get h).isSome = true)
    (hclC : ∀ h l, PRE_first_tail_x6_r0_body.krC_19.targs.get h = some l → Host.Ts.Sim.Full.STargs (· < (⟨18582, 15681, 2689883, 893⟩ : Conv.Cnt).n) l) :
    Conv.FullShiftQ PRE_first_tail_x6_r0_body.P19 893 PRE_first_tail_x6_r0_body.kappa19 PRE_first_tail_x6_r0_body.s199.ffi PRE_first_tail_x6_r0_body.s198.ffi :=
  ⟨PRE_first_tail_x6_r0_body.cnshift19 clean hltC nltC itemsC tracedC cl, PRE_first_tail_x6_r0_body.cqueue19, fun t ht => bSN_sound (List.all_eq_true.mp PRE_first_tail_x6_r0_body.ctokSupp19 t ht),
    PRE_first_tail_x6_r0_body.cbridge19,
    liveShift_foot (x0' := Host.Ts.Sim.Full.mlxOf PRE_first_tail_x6_r0_body.s199.ffi) (x1' := Host.Ts.Sim.Full.mlxOf PRE_first_tail_x6_r0_body.s198.ffi) (PRE_first_tail_x6_r0_body.cfoot19 clean hltC nltC itemsC tracedC cl) rfl PRE_first_tail_x6_r0_body.ofx0_19 PRE_first_tail_x6_r0_body.ofx1_19 hobjC PRE_first_tail_x6_r0_body.ff019 PRE_first_tail_x6_r0_body.ff119 PRE_first_tail_x6_r0_body.ffck19,
    kernShift_foot (x0' := Host.Ts.Sim.Full.mlxOf PRE_first_tail_x6_r0_body.s199.ffi) (x1' := Host.Ts.Sim.Full.mlxOf PRE_first_tail_x6_r0_body.s198.ffi) (PRE_first_tail_x6_r0_body.cfoot19 clean hltC nltC itemsC tracedC cl) rfl PRE_first_tail_x6_r0_body.okr0_19 PRE_first_tail_x6_r0_body.okr1_19 (Nat.le_of_ble_eq_true PRE_first_tail_x6_r0_body.fkn19) hfC htC hclC
      PRE_first_tail_x6_r0_body.fkf019 PRE_first_tail_x6_r0_body.fkt019 PRE_first_tail_x6_r0_body.fkf119 PRE_first_tail_x6_r0_body.fkt119 PRE_first_tail_x6_r0_body.fkck19,
    pendReg_of rfl PRE_first_tail_x6_r0_body.cnh019 PRE_first_tail_x6_r0_body.cnh119 (Nat.le_of_ble_eq_true PRE_first_tail_x6_r0_body.cpendLe19) PRE_first_tail_x6_r0_body.cpendR19⟩

end Host.Load.Run.Tpl
end

section -- st19/H0
set_option Elab.async false
namespace Host.Load.Run.Tpl
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
host_stream_state PRE_first_tail_x6_r0_body.st19 0
host_stream_state PRE_first_tail_x6_r0_body.st19 1
host_stream_state PRE_first_tail_x6_r0_body.st19 2
end Host.Load.Run.Tpl
end

section -- Site19
set_option Elab.async false
namespace Host.Load.Run.Tpl
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
open Host.Ts Host.Ts.Sim Host.Ts.Sim.Template

/-! Call site 19 of chain `PRE_first_tail_x6_r0_body`: `rowBlocks__g19__g20` (`rowBlocks`), the call state `PRE_first_tail_x6_r0_body.s197`, the merged state `PRE_first_tail_x6_r0_body.s198`,
the site template `PRE_first_tail_x6_r0_body.st19` (σ = `Map.id`, θ the identity at its own site), the canonical state `PRE_first_tail_x6_r0_body.s199`: the merge.
The footprint's facts are in `SiteF19`, the compaction's in `SiteC19`, `SiteK19`, `SiteNa19`, `SiteNb19`. -/

kernel_rfl PRE_first_tail_x6_r0_body.iso19 : PRE_first_tail_x6_r0_body.st19.s0 = { PRE_first_tail_x6_r0_body.s197 with stack := [] }
/-- The caller's frames at the call. -/
noncomputable def PRE_first_tail_x6_r0_body.rs19 : List Frame := PRE_first_tail_x6_r0_body.s197.stack
kernel_rfl PRE_first_tail_x6_r0_body.n0_19 : PRE_first_tail_x6_r0_body.S197.tab.length = 893
kernel_rfl PRE_first_tail_x6_r0_body.tab0_19 : PRE_first_tail_x6_r0_body.st19.S0.tab = PRE_first_tail_x6_r0_body.S197.tab

/-- The fresh variables of the stage's results. -/
def PRE_first_tail_x6_r0_body.ws19 : List Nat := [1356, 1357]
kernel_rfl PRE_first_tail_x6_r0_body.fresh19 : (PRE_first_tail_x6_r0_body.S197.tab.all fun e => PRE_first_tail_x6_r0_body.ws19.all fun v => e.noVar v) &&
    (PRE_first_tail_x6_r0_body.S197.oracle.all fun q => PRE_first_tail_x6_r0_body.ws19.all fun v => q.noVar v) = true
kernel_rfl PRE_first_tail_x6_r0_body.mergeTab19 : PRE_first_tail_x6_r0_body.S198.tab = PRE_first_tail_x6_r0_body.S197.tab ++ Conv.resTab PRE_first_tail_x6_r0_body.ws19
kernel_rfl PRE_first_tail_x6_r0_body.mergeLen19 : PRE_first_tail_x6_r0_body.st19.S2.tab.length - PRE_first_tail_x6_r0_body.st19.S0.tab.length = 2

-- The merged state: the instance's return state with the caller's frames (`PRE_first_tail_x6_r0_body.merged19`, `merged_relB`).
kernel_rfl PRE_first_tail_x6_r0_body.mheap19 : PRE_first_tail_x6_r0_body.s198.heap = PRE_first_tail_x6_r0_body.st19.s2.heap
kernel_rfl PRE_first_tail_x6_r0_body.mnext19 : PRE_first_tail_x6_r0_body.s198.next = PRE_first_tail_x6_r0_body.st19.s2.next
kernel_rfl PRE_first_tail_x6_r0_body.mctl19 : PRE_first_tail_x6_r0_body.s198.ctl = PRE_first_tail_x6_r0_body.st19.s2.ctl
kernel_rfl PRE_first_tail_x6_r0_body.mstack19 : PRE_first_tail_x6_r0_body.s198.stack = PRE_first_tail_x6_r0_body.st19.s2.stack ++ PRE_first_tail_x6_r0_body.s197.stack
kernel_rfl PRE_first_tail_x6_r0_body.mjobs19 : PRE_first_tail_x6_r0_body.s198.jobs = PRE_first_tail_x6_r0_body.st19.s2.jobs
kernel_rfl PRE_first_tail_x6_r0_body.mffi19 : PRE_first_tail_x6_r0_body.s198.ffi = PRE_first_tail_x6_r0_body.st19.s2.ffi
kernel_rfl PRE_first_tail_x6_r0_body.mtrace19 : PRE_first_tail_x6_r0_body.s198.trace = PRE_first_tail_x6_r0_body.st19.s2.trace
kernel_rfl PRE_first_tail_x6_r0_body.mstores19 : PRE_first_tail_x6_r0_body.s198.stores = PRE_first_tail_x6_r0_body.st19.s2.stores

end Host.Load.Run.Tpl
end

section -- SiteD19
set_option Elab.async false
namespace Host.Load.Run.Tpl
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
open Host.Ts Host.Ts.Sim Host.Ts.Sim.Template

/-! The canonical results at call site 19 of chain `PRE_first_tail_x6_r0_body`: their values in the instance's end table, the references past
the call's table, the canonical variables apart from the stage's. -/

kernel_rfl PRE_first_tail_x6_r0_body.cderived19 : PRE_first_tail_x6_r0_body.nr19.map (fun r => nth? PRE_first_tail_x6_r0_body.st19.S2.tab r) =
  []
kernel_rfl PRE_first_tail_x6_r0_body.cnrLo19 : PRE_first_tail_x6_r0_body.nr19.all (Nat.ble 893) = true
kernel_rfl PRE_first_tail_x6_r0_body.cwsDisj19 : PRE_first_tail_x6_r0_body.cws19.all (fun c => !PRE_first_tail_x6_r0_body.ws19.contains c) = true
/-- The compaction's substitution: the canonical variables to their merged values, the stage's other fresh variables
to `0` (`Conv.compactθZ`). -/
noncomputable def PRE_first_tail_x6_r0_body.cthetaZ19 : Nat → SymE := Conv.compactθZ PRE_first_tail_x6_r0_body.cws19 PRE_first_tail_x6_r0_body.crs19 PRE_first_tail_x6_r0_body.ws19

end Host.Load.Run.Tpl
end

section -- st19/Foot
set_option Elab.async false
namespace Host.Load.Run.Tpl
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
open Host.Ts Host.Ts.Sim Host.Ts.Sim.Stage Host.Ts.Sim.Template

/-! The footprint of stage `PRE_first_tail_x6_r0_body.st19`'s site template (`Conv.StageFoot`, `Conv.NFoot`): every entry of the return
state other than the written and fresh ones is the start's (kernel evaluation of the equalities). -/

/-- The written heap ranges below the start's counter. -/
def PRE_first_tail_x6_r0_body.st19.wrR : List (Nat × Nat) := []
/-- The written and fresh entries of the return state. -/
noncomputable def PRE_first_tail_x6_r0_body.st19.wrE : List (Nat × Host.Ts.HObj) :=
  rangesOf PRE_first_tail_x6_r0_body.st19.s2.heap PRE_first_tail_x6_r0_body.st19.wrR ++ freshOf PRE_first_tail_x6_r0_body.st19.s2.heap PRE_first_tail_x6_r0_body.st19.s0.next PRE_first_tail_x6_r0_body.st19.s2.next
noncomputable def PRE_first_tail_x6_r0_body.st19.wr : List Nat := PRE_first_tail_x6_r0_body.st19.wrE.map (·.1)

kernel_rfl PRE_first_tail_x6_r0_body.st19.heapFoot : PRE_first_tail_x6_r0_body.st19.s2.heap = setAll PRE_first_tail_x6_r0_body.st19.s0.heap PRE_first_tail_x6_r0_body.st19.wrE
kernel_rfl PRE_first_tail_x6_r0_body.st19.grows_check : Nat.ble PRE_first_tail_x6_r0_body.st19.s0.next PRE_first_tail_x6_r0_body.st19.s2.next = true
theorem PRE_first_tail_x6_r0_body.st19.grows : PRE_first_tail_x6_r0_body.st19.s0.next ≤ PRE_first_tail_x6_r0_body.st19.s2.next := Nat.le_of_ble_eq_true PRE_first_tail_x6_r0_body.st19.grows_check

/-- The written and fresh handles; the written readback items of old nodes. -/
def PRE_first_tail_x6_r0_body.st19.wh : List Nat := []
def PRE_first_tail_x6_r0_body.st19.wi : List Nat := []

kernel_rfl PRE_first_tail_x6_r0_body.st19.arrsFoot : (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.st19.s2.ffi).mlx.arrs = setAll (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.st19.s0.ffi).mlx.arrs (PRE_first_tail_x6_r0_body.st19.wh.filterMap fun h => ((Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.st19.s2.ffi).mlx.arrs.get h).map (h, ·))
kernel_rfl PRE_first_tail_x6_r0_body.st19.objsFoot : (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.st19.s2.ffi).mlx.objs = setAll (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.st19.s0.ffi).mlx.objs (PRE_first_tail_x6_r0_body.st19.wh.filterMap fun h => ((Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.st19.s2.ffi).mlx.objs.get h).map (h, ·))
kernel_rfl PRE_first_tail_x6_r0_body.st19.nodesFoot : (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.st19.s2.ffi).mlx.nodes = setAll (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.st19.s0.ffi).mlx.nodes (freshOf (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.st19.s2.ffi).mlx.nodes (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.st19.s0.ffi).mlx.nnext (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.st19.s2.ffi).mlx.nnext)
kernel_rfl PRE_first_tail_x6_r0_body.st19.itemsFoot : (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.st19.s2.ffi).mlx.items = setAll (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.st19.s0.ffi).mlx.items ((PRE_first_tail_x6_r0_body.st19.wi.filterMap fun i => ((Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.st19.s2.ffi).mlx.items.get i).map (i, ·)) ++
    freshOf (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.st19.s2.ffi).mlx.items (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.st19.s0.ffi).mlx.nnext (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.st19.s2.ffi).mlx.nnext)
kernel_rfl PRE_first_tail_x6_r0_body.st19.counters : (Nat.ble (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.st19.s0.ffi).mlx.next (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.st19.s2.ffi).mlx.next && Nat.ble (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.st19.s0.ffi).mlx.nnext (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.st19.s2.ffi).mlx.nnext) = true

end Host.Load.Run.Tpl
end

section -- SiteF19
set_option Elab.async false
namespace Host.Load.Run.Tpl
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
open Host.Ts Host.Ts.Sim Host.Ts.Sim.Template

/-! Call site 19 of chain `PRE_first_tail_x6_r0_body`: `Conv.site_merge`'s footprint facts. -/

kernel_rfl PRE_first_tail_x6_r0_body.wrNodupB19 : nodupT PRE_first_tail_x6_r0_body.st19.wr PTrie.nil = true
theorem PRE_first_tail_x6_r0_body.wrNodup19 : PRE_first_tail_x6_r0_body.st19.wr.Nodup := (nodupT_sound PRE_first_tail_x6_r0_body.wrNodupB19).2
kernel_rfl PRE_first_tail_x6_r0_body.wrBoundB19 : PRE_first_tail_x6_r0_body.st19.wr.all (fun b => Nat.blt (b / 4096) (4 ^ 31)) = true
theorem PRE_first_tail_x6_r0_body.wrBound19 : ∀ b ∈ PRE_first_tail_x6_r0_body.st19.wr, b / 4096 < 4 ^ 31 := fun b hb => Nat.blt_eq.mp (List.all_eq_true.mp PRE_first_tail_x6_r0_body.wrBoundB19 b hb)
noncomputable def PRE_first_tail_x6_r0_body.trFr19 := PRE_first_tail_x6_r0_body.st19.s2.trace.take 0
kernel_rfl PRE_first_tail_x6_r0_body.traceEq19 : PRE_first_tail_x6_r0_body.st19.s2.trace = PRE_first_tail_x6_r0_body.trFr19 ++ PRE_first_tail_x6_r0_body.st19.s0.trace
theorem PRE_first_tail_x6_r0_body.trace19 : ∃ fr, PRE_first_tail_x6_r0_body.st19.s2.trace = fr ++ PRE_first_tail_x6_r0_body.st19.s0.trace := ⟨_, PRE_first_tail_x6_r0_body.traceEq19⟩

-- the caller's wide frames at the instance's start (`Conv.isolateW`'s `W0` under `Map.id`) and their `WFix`
def PRE_first_tail_x6_r0_body.wide19 : List (Nat × WFrame) := [(4910, .memo [])]
kernel_rfl PRE_first_tail_x6_r0_body.wfixB19 : (PRE_first_tail_x6_r0_body.wide19.all fun p => wfixB Map.id (presentB PRE_first_tail_x6_r0_body.st19.s0) p.2) = true
theorem PRE_first_tail_x6_r0_body.wfix19 : ∀ p ∈ PRE_first_tail_x6_r0_body.wide19, WFix Map.id (Present PRE_first_tail_x6_r0_body.st19.s0) p.2 :=
  fun p hp => wfix_of (List.all_eq_true.mp PRE_first_tail_x6_r0_body.wfixB19 p hp)

end Host.Load.Run.Tpl
end

section -- SiteL19
set_option Elab.async false
namespace Host.Load.Run.Tpl
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
open Host.Ts Host.Ts.Sim Host.Ts.Sim.Template

/-! The call link's facts at call site 19 of chain `PRE_first_tail_x6_r0_body`: the instance's start server, its footprint (`Conv.StageFoot`), the
merged state `PRE_first_tail_x6_r0_body.s198`'s framed arrays as the chain start's extended (`arrExt_of`, `numRefs_of`). -/

kernel_rfl PRE_first_tail_x6_r0_body.srvO19 : PRE_first_tail_x6_r0_body.st19.S0.oracle = PRE_first_tail_x6_r0_body.st19.OR
kernel_rfl PRE_first_tail_x6_r0_body.wr0B19 : PRE_first_tail_x6_r0_body.st19.wr.all (fun b => !Nat.blt b PRE_first_tail_x6_r0_body.st19.s0.next || (PRE_first_tail_x6_r0_body.st19.s0.heap.get b).isSome) = true
theorem PRE_first_tail_x6_r0_body.stFoot19 : Conv.StageFoot PRE_first_tail_x6_r0_body.st19.wr PRE_first_tail_x6_r0_body.st19.s0 PRE_first_tail_x6_r0_body.st19.s2 :=
  stageFoot_of PRE_first_tail_x6_r0_body.st19.heapFoot PRE_first_tail_x6_r0_body.wrNodup19 PRE_first_tail_x6_r0_body.wrBound19 PRE_first_tail_x6_r0_body.wr0B19 PRE_first_tail_x6_r0_body.st19.grows

/-- **The relation at the merged state** from the relation at the merge (`Conv.site_merge`'s; `merged_relB`). -/
theorem PRE_first_tail_x6_r0_body.merged19 {FR : Map → Nat → PRE_first_tail_x6_r0_body.st19.F.S → PRE_first_tail_x6_r0_body.st19.F.S → Prop} {W : Nat → Option WFrame} {stk : List Frame} {M : Map}
    {ν : Nat → F64} {K : Host.Ts.Sim.Ctx} {S : SSrv} {t : St PRE_first_tail_x6_r0_body.st19.F.S} {C : CSrv} {n0 : Nat}
    (h : RelB PRE_first_tail_x6_r0_body.st19.F FR W stk M ν K (Conv.mergeSt Map.id (Map.id.res n0 n0) PRE_first_tail_x6_r0_body.rs19 PRE_first_tail_x6_r0_body.st19.wr PRE_first_tail_x6_r0_body.s197 PRE_first_tail_x6_r0_body.st19.s2 PRE_first_tail_x6_r0_body.st19.s0
      PRE_first_tail_x6_r0_body.st19.s2.ffi) S t C) : RelB PRE_first_tail_x6_r0_body.st19.F FR W stk M ν K PRE_first_tail_x6_r0_body.s198 S t C :=
  merged_relB PRE_first_tail_x6_r0_body.iso19 PRE_first_tail_x6_r0_body.stFoot19 PRE_first_tail_x6_r0_body.wrNodup19 PRE_first_tail_x6_r0_body.wrBound19 PRE_first_tail_x6_r0_body.trace19 PRE_first_tail_x6_r0_body.mheap19
    PRE_first_tail_x6_r0_body.mnext19 PRE_first_tail_x6_r0_body.mctl19 PRE_first_tail_x6_r0_body.mstack19 PRE_first_tail_x6_r0_body.mjobs19 PRE_first_tail_x6_r0_body.mffi19 PRE_first_tail_x6_r0_body.mtrace19 PRE_first_tail_x6_r0_body.mstores19 h

def PRE_first_tail_x6_r0_body.arrEl19_2665 : List Val := []
kernel_rfl PRE_first_tail_x6_r0_body.arrE19_2665 : arrOf PRE_first_tail_x6_r0_body.s198 2665 = arrOf PRE_first_tail_x6_r0_body.s0 2665 ++ PRE_first_tail_x6_r0_body.arrEl19_2665
kernel_rfl PRE_first_tail_x6_r0_body.arrA19_2665 : isArrB PRE_first_tail_x6_r0_body.s198 2665 = true
theorem PRE_first_tail_x6_r0_body.arr19_2665 : ∃ o, PRE_first_tail_x6_r0_body.s198.heap.get 2665 = some (.obj o) ∧ o.kind = .array (arrOf PRE_first_tail_x6_r0_body.s0 2665 ++ PRE_first_tail_x6_r0_body.arrEl19_2665) :=
  arrExt_of PRE_first_tail_x6_r0_body.arrE19_2665 PRE_first_tail_x6_r0_body.arrA19_2665
kernel_rfl PRE_first_tail_x6_r0_body.arrN19_2665 : numRefsB PRE_first_tail_x6_r0_body.S0.tab.length PRE_first_tail_x6_r0_body.arrEl19_2665 = true
theorem PRE_first_tail_x6_r0_body.arrR19_2665 : Prefill.NumRefs PRE_first_tail_x6_r0_body.S0.tab.length PRE_first_tail_x6_r0_body.arrEl19_2665 := numRefs_of PRE_first_tail_x6_r0_body.arrN19_2665

def PRE_first_tail_x6_r0_body.arrEl19_2673467 : List Val := []
kernel_rfl PRE_first_tail_x6_r0_body.arrE19_2673467 : arrOf PRE_first_tail_x6_r0_body.s198 2673467 = arrOf PRE_first_tail_x6_r0_body.s0 2673467 ++ PRE_first_tail_x6_r0_body.arrEl19_2673467
kernel_rfl PRE_first_tail_x6_r0_body.arrA19_2673467 : isArrB PRE_first_tail_x6_r0_body.s198 2673467 = true
theorem PRE_first_tail_x6_r0_body.arr19_2673467 : ∃ o, PRE_first_tail_x6_r0_body.s198.heap.get 2673467 = some (.obj o) ∧ o.kind = .array (arrOf PRE_first_tail_x6_r0_body.s0 2673467 ++ PRE_first_tail_x6_r0_body.arrEl19_2673467) :=
  arrExt_of PRE_first_tail_x6_r0_body.arrE19_2673467 PRE_first_tail_x6_r0_body.arrA19_2673467
kernel_rfl PRE_first_tail_x6_r0_body.arrN19_2673467 : numRefsB PRE_first_tail_x6_r0_body.S0.tab.length PRE_first_tail_x6_r0_body.arrEl19_2673467 = true
theorem PRE_first_tail_x6_r0_body.arrR19_2673467 : Prefill.NumRefs PRE_first_tail_x6_r0_body.S0.tab.length PRE_first_tail_x6_r0_body.arrEl19_2673467 := numRefs_of PRE_first_tail_x6_r0_body.arrN19_2673467

kernel_rfl PRE_first_tail_x6_r0_body.w4910k19 : isArrB PRE_first_tail_x6_r0_body.s198 4910 = false
theorem PRE_first_tail_x6_r0_body.keep19 (q : List Val) : Host.Ts.Sim.Prefill.KeepsAtW (framesP PRE_first_tail_x6_r0_body.s0 q) PRE_first_tail_x6_r0_body.s198 := by
  intro a pre pre' hx o es ho hk
  unfold framesP at hx
  simp only at hx
  cases h1 : Nat.beq a 2665
  · cases h2 : Nat.beq a 4910
    · rw [h1, h2] at hx; cases hx
    · have := Nat.eq_of_beq_eq_true h2; subst this
      rw [h1, h2] at hx; cases hx
      exact (notArr_of PRE_first_tail_x6_r0_body.w4910k19 ho hk).elim
  · have := Nat.eq_of_beq_eq_true h1; subst this
    rw [h1] at hx; cases hx
    obtain ⟨o', ho', hk'⟩ := PRE_first_tail_x6_r0_body.arr19_2665
    rw [ho] at ho'; cases ho'
    rw [hk'] at hk; cases hk
    simp [PRE_first_tail_x6_r0_body.arrEl19_2665]

end Host.Load.Run.Tpl
end

section -- SiteZ19
set_option Elab.async false
namespace Host.Load.Run.Tpl
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
open Host.Ts Host.Ts.Sim Host.Ts.Sim.Template

/-! The compaction's state shift at call site 19 of chain `PRE_first_tail_x6_r0_body` (`Conv.compact_shift`): the call `PRE_first_tail_x6_r0_body.s197`, the merged
state `PRE_first_tail_x6_r0_body.s198`, the canonical state `PRE_first_tail_x6_r0_body.s199`; its frames [2665,2673467,2673472,2673473] (kept arrays [2665,2673467]). -/

-- the map's places and counters
kernel_rfl PRE_first_tail_x6_r0_body.zpl19 : PRE_first_tail_x6_r0_body.pl19.all (Nat.ble PRE_first_tail_x6_r0_body.s197.next) = true
kernel_rfl PRE_first_tail_x6_r0_body.zplnd19 : nodupT PRE_first_tail_x6_r0_body.pl19 PTrie.nil = true
kernel_rfl PRE_first_tail_x6_r0_body.zn119 : Nat.ble PRE_first_tail_x6_r0_body.s197.next 2689885 = true
kernel_rfl PRE_first_tail_x6_r0_body.zfirst19 : Nat.ble aFirst PRE_first_tail_x6_r0_body.s197.next = true
kernel_rfl PRE_first_tail_x6_r0_body.zscn19 : PRE_first_tail_x6_r0_body.s199.next = PRE_first_tail_x6_r0_body.s197.next + PRE_first_tail_x6_r0_body.pl19.length
kernel_rfl PRE_first_tail_x6_r0_body.zsmn19 : PRE_first_tail_x6_r0_body.s198.next = 2689885
kernel_rfl PRE_first_tail_x6_r0_body.zgrow19 : Nat.ble PRE_first_tail_x6_r0_body.s199.next PRE_first_tail_x6_r0_body.s198.next = true
-- the tables
kernel_rfl PRE_first_tail_x6_r0_body.zfresh19 : PRE_first_tail_x6_r0_body.S197.tab.all (fun e => PRE_first_tail_x6_r0_body.cws19.all fun v => e.noVar v) = true
kernel_rfl PRE_first_tail_x6_r0_body.zcnd19 : nodupT PRE_first_tail_x6_r0_body.cws19 PTrie.nil = true
kernel_rfl PRE_first_tail_x6_r0_body.znrHi19 : PRE_first_tail_x6_r0_body.nr19.all (fun r => Nat.blt r PRE_first_tail_x6_r0_body.S198.tab.length) = true
-- the frames: every framed address below the call's counter; the kept arrays the chain start's, extended in the merged state
kernel_rfl PRE_first_tail_x6_r0_body.zfrlt19 : [2665, 2673467, 2673472, 2673473].all (fun a => Nat.blt a PRE_first_tail_x6_r0_body.s197.next) = true
kernel_rfl PRE_first_tail_x6_r0_body.zg19_2665 : PRE_first_tail_x6_r0_body.s199.heap.get 2665 = some (.obj (objOf PRE_first_tail_x6_r0_body.s199 2665))
kernel_rfl PRE_first_tail_x6_r0_body.zk19_2665 : (objOf PRE_first_tail_x6_r0_body.s199 2665).kind = .array (arrOf PRE_first_tail_x6_r0_body.s0 2665)
kernel_rfl PRE_first_tail_x6_r0_body.zm19_2665 : PRE_first_tail_x6_r0_body.s198.heap.get 2665 = some (.obj { PRE_first_tail_x6_r0_body.kappa19.obj (objOf PRE_first_tail_x6_r0_body.s199 2665) with
  kind := .array (arrOf PRE_first_tail_x6_r0_body.s0 2665 ++ (arrOf PRE_first_tail_x6_r0_body.s198 2665).drop (arrOf PRE_first_tail_x6_r0_body.s0 2665).length) })
kernel_rfl PRE_first_tail_x6_r0_body.zg19_2673467 : PRE_first_tail_x6_r0_body.s199.heap.get 2673467 = some (.obj (objOf PRE_first_tail_x6_r0_body.s199 2673467))
kernel_rfl PRE_first_tail_x6_r0_body.zk19_2673467 : (objOf PRE_first_tail_x6_r0_body.s199 2673467).kind = .array (arrOf PRE_first_tail_x6_r0_body.s0 2673467)
kernel_rfl PRE_first_tail_x6_r0_body.zm19_2673467 : PRE_first_tail_x6_r0_body.s198.heap.get 2673467 = some (.obj { PRE_first_tail_x6_r0_body.kappa19.obj (objOf PRE_first_tail_x6_r0_body.s199 2673467) with
  kind := .array (arrOf PRE_first_tail_x6_r0_body.s0 2673467 ++ (arrOf PRE_first_tail_x6_r0_body.s198 2673467).drop (arrOf PRE_first_tail_x6_r0_body.s0 2673467).length) })
kernel_rfl PRE_first_tail_x6_r0_body.zw19_4910 : (PRE_first_tail_x6_r0_body.s199.heap.get 4910).isSome = true
kernel_rfl PRE_first_tail_x6_r0_body.zw19_2673472 : (PRE_first_tail_x6_r0_body.s199.heap.get 2673472).isSome = true
kernel_rfl PRE_first_tail_x6_r0_body.zw19_2673473 : (PRE_first_tail_x6_r0_body.s199.heap.get 2673473).isSome = true
-- the heap: the changed list in range, holding the stage's written and fresh addresses; the canonical side's image
kernel_rfl PRE_first_tail_x6_r0_body.zclbd19 : PRE_first_tail_x6_r0_body.cl19.all (fun b => Nat.blt (b / 4096) (4 ^ 31)) = true
kernel_rfl PRE_first_tail_x6_r0_body.zwr19 : PRE_first_tail_x6_r0_body.st19.wr.all (fun b => !Nat.blt b PRE_first_tail_x6_r0_body.s197.next || PRE_first_tail_x6_r0_body.cl19.contains b) = true
def PRE_first_tail_x6_r0_body.zl19 : List Nat := PRE_first_tail_x6_r0_body.cl19.filter fun a => !(List.contains [2665, 2673467] a)
kernel_rfl PRE_first_tail_x6_r0_body.zimgE19 : PRE_first_tail_x6_r0_body.zl19.map (fun a => PRE_first_tail_x6_r0_body.s198.heap.get (PRE_first_tail_x6_r0_body.kappa19.a a)) = PRE_first_tail_x6_r0_body.zl19.map (fun a => (PRE_first_tail_x6_r0_body.s199.heap.get a).map PRE_first_tail_x6_r0_body.kappa19.hobj)
theorem PRE_first_tail_x6_r0_body.zimg19 : HeapImg PRE_first_tail_x6_r0_body.kappa19 PRE_first_tail_x6_r0_body.s199 PRE_first_tail_x6_r0_body.s198 PRE_first_tail_x6_r0_body.zl19 := PRE_first_tail_x6_r0_body.zimgE19
-- the roots and their supports
kernel_rfl PRE_first_tail_x6_r0_body.zctl19 : PRE_first_tail_x6_r0_body.s198.ctl = PRE_first_tail_x6_r0_body.kappa19.ctl PRE_first_tail_x6_r0_body.s199.ctl
kernel_rfl PRE_first_tail_x6_r0_body.zstack19 : PRE_first_tail_x6_r0_body.s198.stack = PRE_first_tail_x6_r0_body.s199.stack.map PRE_first_tail_x6_r0_body.kappa19.frame
kernel_rfl PRE_first_tail_x6_r0_body.zjobs19 : PRE_first_tail_x6_r0_body.s198.jobs = PRE_first_tail_x6_r0_body.s199.jobs.map PRE_first_tail_x6_r0_body.kappa19.job
kernel_rfl PRE_first_tail_x6_r0_body.zstores19 : PRE_first_tail_x6_r0_body.s198.stores = PRE_first_tail_x6_r0_body.kappa19.stores PRE_first_tail_x6_r0_body.s199.stores
kernel_rfl PRE_first_tail_x6_r0_body.zroots19 : checkRootsSupp PRE_first_tail_x6_r0_body.s199 893 = true
kernel_rfl PRE_first_tail_x6_r0_body.znC19 : PRE_first_tail_x6_r0_body.S197.tab.length + PRE_first_tail_x6_r0_body.cws19.length = 893
-- the map as `Conv.compact_shift` states it (the call's counters for the literals)
kernel_rfl PRE_first_tail_x6_r0_body.zkap19 : PRE_first_tail_x6_r0_body.kappa19 = Conv.Map.compact PRE_first_tail_x6_r0_body.s197.next 2689885 PRE_first_tail_x6_r0_body.S197.tab.length PRE_first_tail_x6_r0_body.pl19 (PRE_first_tail_x6_r0_body.nr19.map NumV.ref) PRE_first_tail_x6_r0_body.kd19.big
  PRE_first_tail_x6_r0_body.kd19.region PRE_first_tail_x6_r0_body.kd19.nodeF
-- the bridge inactive at the canonical state (`Conv.FullShiftQ.toX`; the merged state's bridge is the canonical's: cbridge)
theorem PRE_first_tail_x6_r0_body.zbin19 : (Host.Ts.Sim.Full.bridgeOf PRE_first_tail_x6_r0_body.s199.ffi).active = false := (Host.Load.Boot.replay_active Host.Load.Run.Prompt.P.oblog2818)
-- the JS bookkeeping's step (`Conv.JClean.step` over the changed list) and the canonical roots' bigint freedom
kernel_rfl PRE_first_tail_x6_r0_body.zjc19 : Conv.jcleanListB (⟨18582, 15681, 2689883, 893⟩ : Conv.Cnt) PRE_first_tail_x6_r0_body.s199 PRE_first_tail_x6_r0_body.cl19 = true
kernel_rfl PRE_first_tail_x6_r0_body.zrootsB19 : noBigRootsP (fun i => !Conv.oldBigB (⟨18582, 15681, 2689883, 893⟩ : Conv.Cnt) i) PRE_first_tail_x6_r0_body.s199.trace PRE_first_tail_x6_r0_body.s199 = true
kernel_rfl PRE_first_tail_x6_r0_body.zhm19 : Nat.ble (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.s0.ffi).mlx.nnext 15681 = true
theorem PRE_first_tail_x6_r0_body.cjcl19 (h : Conv.JClean (⟨18582, 15681, 2689883, 893⟩ : Conv.Cnt) PRE_first_tail_x6_r0_body.s197) : Conv.JClean (⟨18582, 15681, 2689883, 893⟩ : Conv.Cnt) PRE_first_tail_x6_r0_body.s199 :=
  Conv.JClean.step h (Conv.Cnt.le_of_leB PRE_first_tail_x6_r0_body.cle19)
    (Conv.heap_off_setAll PRE_first_tail_x6_r0_body.cheap19 fun a ha => Nat.blt_eq.mp (List.all_eq_true.mp PRE_first_tail_x6_r0_body.zclbd19 a ha)) PRE_first_tail_x6_r0_body.zjc19

end Host.Load.Run.Tpl
end

section -- st19/TypedLast
set_option Elab.async false
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
namespace Host.Load.Run.Tpl
open Host.Ts Host.Ts.Sim Host.Ts.Sim.Template

boot_rfl PRE_first_tail_x6_r0_body.st19.bodyLast from PRE_first_tail_x6_r0_body.st19.s1 to PRE_first_tail_x6_r0_body.st19.s2 :
  interpS (step PRE_first_tail_x6_r0_body.st19.F PRE_first_tail_x6_r0_body.st19.s1).run PRE_first_tail_x6_r0_body.st19.S1 = some (PRE_first_tail_x6_r0_body.st19.s2, PRE_first_tail_x6_r0_body.st19.S2)
kernel_rfl PRE_first_tail_x6_r0_body.st19.bodyHalt : isHalt PRE_first_tail_x6_r0_body.st19.s1.ctl = false
kernel_rfl PRE_first_tail_x6_r0_body.st19.bodyTopCheck : noBlockTop PRE_first_tail_x6_r0_body.st19.s2.stack = true

end Host.Load.Run.Tpl
end

section -- st19/TypedOk
set_option Elab.async false
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
namespace Host.Load.Run.Tpl
open Host.Ts Host.Ts.Sim Host.Ts.Sim.Template

noncomputable def PRE_first_tail_x6_r0_body.st19.bodyOkL (bytes : List Byte) (rows : Nat) : St PRE_first_tail_x6_r0_body.st19.F.S → SSrv → Bool :=
  okLocal (Host.Ts.Sim.Compose.VWFrames.bodyOk bytes rows)

noncomputable def PRE_first_tail_x6_r0_body.st19.bodyOkLN (bytes : List Byte) (rows : Nat) : St PRE_first_tail_x6_r0_body.st19.F.S → FSrv → Bool :=
  okLocalN (Host.Ts.Sim.Compose.VWFrames.bodyOkN bytes rows)

theorem PRE_first_tail_x6_r0_body.st19.bodyOkLN_ok (bytes : List Byte) (rows : Nat) (s : St PRE_first_tail_x6_r0_body.st19.F.S) (c : FSrv) (h : c.Wf) :
    PRE_first_tail_x6_r0_body.st19.bodyOkLN bytes rows s c = PRE_first_tail_x6_r0_body.st19.bodyOkL bytes rows s c.toS :=
  okLocalN_ok (Host.Ts.Sim.Compose.VWFrames.bodyOkN_ok bytes rows) s c h

kernel_rfl PRE_first_tail_x6_r0_body.st19.bodyAccepted0 :
  (fun (bytes : List Byte) (rows : Nat) => PRE_first_tail_x6_r0_body.st19.bodyOkL bytes rows PRE_first_tail_x6_r0_body.st19.s0 PRE_first_tail_x6_r0_body.st19.S0) = fun _ _ => true

kernel_rfl PRE_first_tail_x6_r0_body.st19.bodyAccepted1 :
  (fun (bytes : List Byte) (rows : Nat) => PRE_first_tail_x6_r0_body.st19.bodyOkL bytes rows PRE_first_tail_x6_r0_body.st19.s1 PRE_first_tail_x6_r0_body.st19.S1) = fun _ _ => true

end Host.Load.Run.Tpl
end

section -- st19/TypedK0
set_option Elab.async false
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
namespace Host.Load.Run.Tpl
open Host.Ts Host.Ts.Sim Host.Ts.Sim.Template

boot_rfl PRE_first_tail_x6_r0_body.st19.bodyK0F from PRE_first_tail_x6_r0_body.st19.s0 to PRE_first_tail_x6_r0_body.st19.s1 :
  (fun (bytes : List Byte) (rows : Nat) => runOkS PRE_first_tail_x6_r0_body.st19.F (PRE_first_tail_x6_r0_body.st19.bodyOkLN bytes rows)
    ((nth? PRE_first_tail_x6_r0_body.st19.ks 0).getD 0) PRE_first_tail_x6_r0_body.st19.s0 PRE_first_tail_x6_r0_body.st19.S0) = fun _ _ => some (PRE_first_tail_x6_r0_body.st19.s1, PRE_first_tail_x6_r0_body.st19.S1)
theorem PRE_first_tail_x6_r0_body.st19.bodyK0 :
  (fun (bytes : List Byte) (rows : Nat) => runOk PRE_first_tail_x6_r0_body.st19.F (PRE_first_tail_x6_r0_body.st19.bodyOkL bytes rows)
    ((nth? PRE_first_tail_x6_r0_body.st19.ks 0).getD 0) PRE_first_tail_x6_r0_body.st19.s0 PRE_first_tail_x6_r0_body.st19.S0) = fun _ _ => some (PRE_first_tail_x6_r0_body.st19.s1, PRE_first_tail_x6_r0_body.st19.S1) :=
  runOk_fun_of_runOkS PRE_first_tail_x6_r0_body.st19.bodyOkLN_ok PRE_first_tail_x6_r0_body.st19.bodyK0F
end Host.Load.Run.Tpl
end

section -- st19/TypedTpl
set_option Elab.async false
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
namespace Host.Load.Run.Tpl
open Host.Ts Host.Ts.Sim Host.Ts.Sim.Template

theorem PRE_first_tail_x6_r0_body.st19.bodyRun (bytes : List Byte) (rows : Nat) :
    runOk PRE_first_tail_x6_r0_body.st19.F (PRE_first_tail_x6_r0_body.st19.bodyOkL bytes rows) 27 PRE_first_tail_x6_r0_body.st19.s0 PRE_first_tail_x6_r0_body.st19.S0 = some (PRE_first_tail_x6_r0_body.st19.s1, PRE_first_tail_x6_r0_body.st19.S1) :=
  (congrFun (congrFun PRE_first_tail_x6_r0_body.st19.bodyK0 bytes) rows)

theorem PRE_first_tail_x6_r0_body.st19.bodyLocal (bytes : List Byte) (rows : Nat) : ∀ s S, PRE_first_tail_x6_r0_body.st19.bodyOkL bytes rows s S = true → Disp.localB s = true := okLocal_localB

noncomputable def PRE_first_tail_x6_r0_body.st19.bodyTpl (bytes : List Byte) (rows : Nat) : Host.Ts.Sim.Stage.StageTpl PRE_first_tail_x6_r0_body.st19.F (PRE_first_tail_x6_r0_body.st19.bodyOkL bytes rows) where
  s0 := PRE_first_tail_x6_r0_body.st19.s0
  S0 := PRE_first_tail_x6_r0_body.st19.S0
  s1 := PRE_first_tail_x6_r0_body.st19.s1
  S1 := PRE_first_tail_x6_r0_body.st19.S1
  s2 := PRE_first_tail_x6_r0_body.st19.s2
  S2 := PRE_first_tail_x6_r0_body.st19.S2
  n := 27
  ok0 := congrFun (congrFun PRE_first_tail_x6_r0_body.st19.bodyAccepted0 bytes) rows
  run := PRE_first_tail_x6_r0_body.st19.bodyRun bytes rows
  ok1 := congrFun (congrFun PRE_first_tail_x6_r0_body.st19.bodyAccepted1 bytes) rows
  halt := PRE_first_tail_x6_r0_body.st19.bodyHalt
  last := PRE_first_tail_x6_r0_body.st19.bodyLast
  top := noBlockTop_sound PRE_first_tail_x6_r0_body.st19.bodyTopCheck
end Host.Load.Run.Tpl
end

section -- SiteC20
set_option Elab.async false
namespace Host.Load.Run.Tpl
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
open Host.Ts Host.Ts.Sim Host.Ts.Sim.Template

/-! The compaction after the merge at call site 20 of chain `PRE_first_tail_x6_r0_body` (`Conv.compact`, `Conv.full_compactQ`): the canonical
state `PRE_first_tail_x6_r0_body.s203` (the stage's results at canonical places, its trace the call's) under `PRE_first_tail_x6_r0_body.kappa20` into the merged state
`PRE_first_tail_x6_r0_body.s202`. -/

def PRE_first_tail_x6_r0_body.pl20 : List Nat := [2690181]
def PRE_first_tail_x6_r0_body.nr20 : List Nat := []
/-- The native part of the compaction map (canonical → merged handles and nodes: its `big`, `region`, `nodeF`). -/
def PRE_first_tail_x6_r0_body.kd20 : RData :=
  ⟨2690172, 2690182, Stage.setAll PTrie.nil [(2690171, 2690181)], Stage.setAll PTrie.nil [],
   18589, 18589, 15685, 15685, Stage.setAll PTrie.nil [],
   Stage.setAll PTrie.nil []⟩
/-- **The compaction map.** -/
noncomputable def PRE_first_tail_x6_r0_body.kappa20 : Map :=
  Conv.Map.compact 2690171 2690182 910 PRE_first_tail_x6_r0_body.pl20 (PRE_first_tail_x6_r0_body.nr20.map NumV.ref) PRE_first_tail_x6_r0_body.kd20.big
    PRE_first_tail_x6_r0_body.kd20.region PRE_first_tail_x6_r0_body.kd20.nodeF
/-- The canonical result variables and their images, the merged state's entries (`Conv.compactθ`). -/
def PRE_first_tail_x6_r0_body.cws20 : List Nat := []
noncomputable def PRE_first_tail_x6_r0_body.crs20 : List SymE := PRE_first_tail_x6_r0_body.nr20.map fun r => (nth? PRE_first_tail_x6_r0_body.S202.tab r).getD (.var 0)
noncomputable def PRE_first_tail_x6_r0_body.ctheta20 : Nat → SymE := Conv.compactθ PRE_first_tail_x6_r0_body.cws20 PRE_first_tail_x6_r0_body.crs20
/-- The call's entries the stage wrote (renamed in the canonical state with the results). -/
def PRE_first_tail_x6_r0_body.wrB20 : List Nat := [2665, 2673467]

kernel_rfl PRE_first_tail_x6_r0_body.ctab20 : PRE_first_tail_x6_r0_body.S203.tab = PRE_first_tail_x6_r0_body.S201.tab ++ PRE_first_tail_x6_r0_body.cws20.map SymE.var
kernel_rfl PRE_first_tail_x6_r0_body.ctrace20 : PRE_first_tail_x6_r0_body.s203.trace = PRE_first_tail_x6_r0_body.s201.trace
kernel_rfl PRE_first_tail_x6_r0_body.cnext20 : PRE_first_tail_x6_r0_body.s203.next = 2690172
kernel_rfl PRE_first_tail_x6_r0_body.ccounters20 : ((Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.s203.ffi).mlx.next, (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.s203.ffi).mlx.nnext) = (18589, 15685)
-- the merged state's readback queue, carried to the canonical state (`Conv.FullShiftQ.tokens`, `tokSupp`)
kernel_rfl PRE_first_tail_x6_r0_body.cqueue20 : (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.s202.ffi).mlx.tokens = (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.s203.ffi).mlx.tokens.map PRE_first_tail_x6_r0_body.kappa20.nv
kernel_rfl PRE_first_tail_x6_r0_body.ctokSupp20 : (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.s203.ffi).mlx.tokens.all (bSN 910) = true
-- the written and the result entries carry no bigint of the canonical fresh band [next, E) and no fresh region
kernel_rfl PRE_first_tail_x6_r0_body.cclean20 : Conv.cleanListB 18589 131072 (fun r => Nat.ble 74356 r) PRE_first_tail_x6_r0_body.s203
    (PRE_first_tail_x6_r0_body.wrB20 ++ (List.range 1).map (2690171 + ·)) = true
kernel_rfl PRE_first_tail_x6_r0_body.cbigs20 : bigsOutB 18589 131072 (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.s203.ffi).mlx = true

end Host.Load.Run.Tpl
end

section -- SiteK20
set_option Elab.async false
namespace Host.Load.Run.Tpl
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
open Host.Ts Host.Ts.Sim Host.Ts.Sim.Template

/-! The canonical state's closedness from the call's (`Conv.closed_of_callB`, `Conv.sst_of_callB`): it keeps the call's entries
off the written and the result ones (`PRE_first_tail_x6_r0_body.cl20`; natively the written and result handles, the result nodes, the written
and result items), and those are checked. -/

def PRE_first_tail_x6_r0_body.cl20 : List Nat := [2665, 2673467, 2690171]
def PRE_first_tail_x6_r0_body.clo20 : List Nat := []
def PRE_first_tail_x6_r0_body.cln20 : List Nat := []
def PRE_first_tail_x6_r0_body.cli20 : List Nat := []
kernel_rfl PRE_first_tail_x6_r0_body.cheap20 : PRE_first_tail_x6_r0_body.s203.heap = Stage.setAll PRE_first_tail_x6_r0_body.s201.heap (PRE_first_tail_x6_r0_body.cl20.filterMap fun a => (PRE_first_tail_x6_r0_body.s203.heap.get a).map (a, ·))
kernel_rfl PRE_first_tail_x6_r0_body.cnextLe20 : Nat.ble PRE_first_tail_x6_r0_body.s201.next PRE_first_tail_x6_r0_body.s203.next = true
kernel_rfl PRE_first_tail_x6_r0_body.ckeepP20 : Conv.keptPresentB PRE_first_tail_x6_r0_body.s201 PRE_first_tail_x6_r0_body.s203 PRE_first_tail_x6_r0_body.cl20 = true
kernel_rfl PRE_first_tail_x6_r0_body.csupp20 : Conv.suppListB PRE_first_tail_x6_r0_body.s203 910 PRE_first_tail_x6_r0_body.cl20 = true
kernel_rfl PRE_first_tail_x6_r0_body.cbound20 : Conv.boundListB PRE_first_tail_x6_r0_body.s203 PRE_first_tail_x6_r0_body.cl20 = true
kernel_rfl PRE_first_tail_x6_r0_body.cnodesK20 : (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.s203.ffi).mlx.nodes = Stage.setAll (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.s201.ffi).mlx.nodes (PRE_first_tail_x6_r0_body.cln20.filterMap fun i => ((Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.s203.ffi).mlx.nodes.get i).map (i, ·))
kernel_rfl PRE_first_tail_x6_r0_body.cobjsK20 : (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.s203.ffi).mlx.objs = Stage.setAll (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.s201.ffi).mlx.objs (PRE_first_tail_x6_r0_body.clo20.filterMap fun i => ((Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.s203.ffi).mlx.objs.get i).map (i, ·))
kernel_rfl PRE_first_tail_x6_r0_body.citemsK20 : (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.s203.ffi).mlx.items = Stage.setAll (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.s201.ffi).mlx.items (PRE_first_tail_x6_r0_body.cli20.filterMap fun i => ((Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.s203.ffi).mlx.items.get i).map (i, ·))
kernel_rfl PRE_first_tail_x6_r0_body.csst20 : Conv.sstListB 910 (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.s203.ffi).mlx PRE_first_tail_x6_r0_body.cln20 PRE_first_tail_x6_r0_body.clo20 PRE_first_tail_x6_r0_body.cli20 = true

end Host.Load.Run.Tpl
end

section -- SiteCl20
set_option Elab.async false
namespace Host.Load.Run.Tpl
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
open Host.Ts Host.Ts.Sim Host.Ts.Sim.Template

kernel_rfl PRE_first_tail_x6_r0_body.ckA20 : (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.s203.ffi).mlx.arrs = Stage.setAll (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.s201.ffi).mlx.arrs (PRE_first_tail_x6_r0_body.clo20.filterMap fun i => ((Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.s203.ffi).mlx.arrs.get i).map (i, ·))
kernel_rfl PRE_first_tail_x6_r0_body.cbd20 : (PRE_first_tail_x6_r0_body.clo20 ++ PRE_first_tail_x6_r0_body.cln20 ++ PRE_first_tail_x6_r0_body.cli20).all (fun i => Nat.blt (i / 4096) (4 ^ 31)) = true
kernel_rfl PRE_first_tail_x6_r0_body.cle20 : Conv.Cnt.leB (⟨18589, 15685, 2690171, 910⟩ : Conv.Cnt) (⟨18589, 15685, 2690172, 910⟩ : Conv.Cnt) = true
kernel_rfl PRE_first_tail_x6_r0_body.cck20 : Conv.ncleanListB (⟨18589, 15685, 2690172, 910⟩ : Conv.Cnt) (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.s203.ffi).mlx PRE_first_tail_x6_r0_body.clo20 PRE_first_tail_x6_r0_body.cln20 PRE_first_tail_x6_r0_body.cli20 = true
theorem PRE_first_tail_x6_r0_body.cncl20 (h : Conv.NClean (⟨18589, 15685, 2690171, 910⟩ : Conv.Cnt) (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.s201.ffi).mlx) : Conv.NClean (⟨18589, 15685, 2690172, 910⟩ : Conv.Cnt) (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.s203.ffi).mlx :=
  Conv.NClean.stepKeep h PRE_first_tail_x6_r0_body.cle20 PRE_first_tail_x6_r0_body.ckA20 PRE_first_tail_x6_r0_body.cobjsK20 PRE_first_tail_x6_r0_body.cnodesK20 PRE_first_tail_x6_r0_body.citemsK20 PRE_first_tail_x6_r0_body.cbd20 PRE_first_tail_x6_r0_body.cck20

end Host.Load.Run.Tpl
end

section -- SiteS20
set_option Elab.async false
namespace Host.Load.Run.Tpl
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
open Host.Ts Host.Ts.Sim Host.Ts.Sim.Template

/-! The compaction's native shift at call site 20 from its footprint (`Conv.nshift_of_foot`), and the observers'
(`liveShift_foot`, `kernShift_foot`): `Conv.FullShiftQ` for `Conv.full_compactQ`, given the call's bookkeeping and its
relation's facts. -/

/-- The load parameters of the chain (band-free: its start's node counter as `NL` and `N0`). -/
def PRE_first_tail_x6_r0_body.Pc20 : LoadP := ⟨18151, 131072, 1099511627776, 15235, 15235, []⟩
/-- The site's band raised to the map's checked fixed-node prefix, including newly recorded closure traces. -/
def PRE_first_tail_x6_r0_body.P20 : LoadP := PRE_first_tail_x6_r0_body.Pc20.raise 15685
kernel_rfl PRE_first_tail_x6_r0_body.craise20 : Nat.ble PRE_first_tail_x6_r0_body.Pc20.N0 15685 = true
theorem PRE_first_tail_x6_r0_body.raised20 : Host.Ts.Sim.Full.Raised PRE_first_tail_x6_r0_body.Pc20 PRE_first_tail_x6_r0_body.P20 :=
  .inr ⟨15685, rfl, Nat.le_of_ble_eq_true PRE_first_tail_x6_r0_body.craise20, rfl⟩
noncomputable abbrev PRE_first_tail_x6_r0_body.cx0_20 : Host.Load.LSt := clearTokens (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.s203.ffi)
noncomputable abbrev PRE_first_tail_x6_r0_body.cx1_20 : Host.Load.LSt := clearTokens (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.s202.ffi)
def PRE_first_tail_x6_r0_body.khinv20 : PTrie Nat := Stage.setAll PTrie.nil []
def PRE_first_tail_x6_r0_body.kninv20 : PTrie Nat := Stage.setAll PTrie.nil []
/-- The stage's footprint: its written and fresh handles, fresh nodes, written and fresh items. -/
def PRE_first_tail_x6_r0_body.cwS20 : List Nat := []
def PRE_first_tail_x6_r0_body.cnS20 : List Nat := List.range' 15685 0
def PRE_first_tail_x6_r0_body.ciS20 : List Nat := [] ++ List.range' 15685 0

-- the small checks (`MChecks`'s)
kernel_rfl PRE_first_tail_x6_r0_body.cnh020 : PRE_first_tail_x6_r0_body.kd20.nh0 = PRE_first_tail_x6_r0_body.cx0_20.mlx.next
kernel_rfl PRE_first_tail_x6_r0_body.cnh120 : PRE_first_tail_x6_r0_body.kd20.nh1 = PRE_first_tail_x6_r0_body.cx1_20.mlx.next
kernel_rfl PRE_first_tail_x6_r0_body.cnn020 : PRE_first_tail_x6_r0_body.kd20.nn0 = PRE_first_tail_x6_r0_body.cx0_20.mlx.nnext
kernel_rfl PRE_first_tail_x6_r0_body.cnn120 : PRE_first_tail_x6_r0_body.kd20.nn1 = PRE_first_tail_x6_r0_body.cx1_20.mlx.nnext
kernel_rfl PRE_first_tail_x6_r0_body.cplo20 : (Nat.blt 0 PRE_first_tail_x6_r0_body.P20.lo && Nat.ble PRE_first_tail_x6_r0_body.P20.lo PRE_first_tail_x6_r0_body.cx0_20.mlx.next && Nat.ble PRE_first_tail_x6_r0_body.P20.lo RData.bigHi && Nat.ble RData.bigHi PRE_first_tail_x6_r0_body.P20.E) = true
kernel_rfl PRE_first_tail_x6_r0_body.ccnt20 : (Nat.ble PRE_first_tail_x6_r0_body.cx0_20.mlx.next PRE_first_tail_x6_r0_body.cx1_20.mlx.next && Nat.ble PRE_first_tail_x6_r0_body.cx0_20.mlx.nnext PRE_first_tail_x6_r0_body.cx1_20.mlx.nnext) = true
kernel_rfl PRE_first_tail_x6_r0_body.cnband20 : (Nat.blt 0 PRE_first_tail_x6_r0_body.P20.NL && Nat.ble PRE_first_tail_x6_r0_body.P20.NL PRE_first_tail_x6_r0_body.P20.N0 && Nat.ble PRE_first_tail_x6_r0_body.P20.N0 PRE_first_tail_x6_r0_body.cx0_20.mlx.nnext) = true
kernel_rfl PRE_first_tail_x6_r0_body.chbelow20 : PRE_first_tail_x6_r0_body.kd20.checkHndBelow = true
kernel_rfl PRE_first_tail_x6_r0_body.chren20 : checkRenG PRE_first_tail_x6_r0_body.kd20.hnd PRE_first_tail_x6_r0_body.khinv20 (phB PRE_first_tail_x6_r0_body.cx0_20.mlx) = true
kernel_rfl PRE_first_tail_x6_r0_body.cband20 : PRE_first_tail_x6_r0_body.kd20.checkBand PRE_first_tail_x6_r0_body.P20.lo = true
kernel_rfl PRE_first_tail_x6_r0_body.cnh1pos20 : Nat.blt 0 PRE_first_tail_x6_r0_body.kd20.nh1 = true
kernel_rfl PRE_first_tail_x6_r0_body.cnren20 : checkRenG PRE_first_tail_x6_r0_body.kd20.node PRE_first_tail_x6_r0_body.kninv20 (pnB PRE_first_tail_x6_r0_body.cx0_20.mlx) = true
kernel_rfl PRE_first_tail_x6_r0_body.cnlow20 : (PTrie.keysA PRE_first_tail_x6_r0_body.kd20.node).all (fun j => Nat.ble PRE_first_tail_x6_r0_body.P20.NL j && Nat.blt (PRE_first_tail_x6_r0_body.kd20.nodeF j) PRE_first_tail_x6_r0_body.cx1_20.mlx.nnext) = true
kernel_rfl PRE_first_tail_x6_r0_body.cabs0a20 : PRE_first_tail_x6_r0_body.cx0_20.mlx.arrs.get 0 = none
kernel_rfl PRE_first_tail_x6_r0_body.cabs0b20 : PRE_first_tail_x6_r0_body.cx0_20.mlx.objs.get 0 = none
kernel_rfl PRE_first_tail_x6_r0_body.ctok120 : PRE_first_tail_x6_r0_body.cx1_20.mlx.tokens = []
kernel_rfl PRE_first_tail_x6_r0_body.cpend20 : PRE_first_tail_x6_r0_body.cx1_20.mlx.pending = PRE_first_tail_x6_r0_body.cx0_20.mlx.pending.map PRE_first_tail_x6_r0_body.kappa20.pend
kernel_rfl PRE_first_tail_x6_r0_body.cerrh20 : PRE_first_tail_x6_r0_body.cx1_20.mlx.errh = PRE_first_tail_x6_r0_body.cx0_20.mlx.errh.map PRE_first_tail_x6_r0_body.kappa20.arg
kernel_rfl PRE_first_tail_x6_r0_body.cfiles20 : PRE_first_tail_x6_r0_body.cx1_20.mlx.files = PRE_first_tail_x6_r0_body.cx0_20.mlx.files
kernel_rfl PRE_first_tail_x6_r0_body.carch20 : PRE_first_tail_x6_r0_body.cx1_20.mlx.arch = PRE_first_tail_x6_r0_body.cx0_20.mlx.arch
kernel_rfl PRE_first_tail_x6_r0_body.csizes20 : PRE_first_tail_x6_r0_body.cx1_20.mlx.deviceSizes = PRE_first_tail_x6_r0_body.cx0_20.mlx.deviceSizes
kernel_rfl PRE_first_tail_x6_r0_body.cwired20 : PRE_first_tail_x6_r0_body.cx1_20.mlx.wired = PRE_first_tail_x6_r0_body.cx0_20.mlx.wired
kernel_rfl PRE_first_tail_x6_r0_body.chost20 : PRE_first_tail_x6_r0_body.cx1_20.host = PRE_first_tail_x6_r0_body.cx0_20.host
-- the compaction map's addresses are `PRE_first_tail_x6_r0_body.kd20`'s
kernel_rfl PRE_first_tail_x6_r0_body.ckn020 : PRE_first_tail_x6_r0_body.kd20.n0 = 2690172
kernel_rfl PRE_first_tail_x6_r0_body.ckn120 : PRE_first_tail_x6_r0_body.kd20.n1 = 2690182
kernel_rfl PRE_first_tail_x6_r0_body.ckheap20 : (PTrie.keysA PRE_first_tail_x6_r0_body.kd20.heap).all (fun x => Nat.ble 2690171 x) = true
kernel_rfl PRE_first_tail_x6_r0_body.ckpl20 : (List.range 1).all (fun j => decide (PRE_first_tail_x6_r0_body.kd20.heap.get (2690171 + j) = nth? PRE_first_tail_x6_r0_body.pl20 j)) = true
-- the map fixes the call's names (`Conv.fixOld_compact`), the call's counters
kernel_rfl PRE_first_tail_x6_r0_body.fja20 : Nat.ble 2690171 2690171 = true
kernel_rfl PRE_first_tail_x6_r0_body.fn20 : Nat.ble 910 910 = true
kernel_rfl PRE_first_tail_x6_r0_body.fjaD20 : Nat.ble 2690171 PRE_first_tail_x6_r0_body.kd20.n0 = true
kernel_rfl PRE_first_tail_x6_r0_body.fxn20 : Nat.ble 18589 PRE_first_tail_x6_r0_body.kd20.nh0 = true
kernel_rfl PRE_first_tail_x6_r0_body.fnn20 : Nat.ble 15685 PRE_first_tail_x6_r0_body.kd20.nn0 = true
kernel_rfl PRE_first_tail_x6_r0_body.fxb20 : Nat.ble 18589 RData.bigHi = true
kernel_rfl PRE_first_tail_x6_r0_body.fheap20 : (PTrie.keysA PRE_first_tail_x6_r0_body.kd20.heap).all (Nat.ble (⟨18589, 15685, 2690171, 910⟩ : Conv.Cnt).ja) = true
kernel_rfl PRE_first_tail_x6_r0_body.fhnd20 : (PTrie.keysA PRE_first_tail_x6_r0_body.kd20.hnd).all (Nat.ble (⟨18589, 15685, 2690171, 910⟩ : Conv.Cnt).xn) = true
kernel_rfl PRE_first_tail_x6_r0_body.fnode20 : (PTrie.keysA PRE_first_tail_x6_r0_body.kd20.node).all (Nat.ble (⟨18589, 15685, 2690171, 910⟩ : Conv.Cnt).nn) = true
/-- The compaction map fixes the call's names. -/
theorem PRE_first_tail_x6_r0_body.cfix20 : Conv.FixOld (⟨18589, 15685, 2690171, 910⟩ : Conv.Cnt) PRE_first_tail_x6_r0_body.kappa20 :=
  Conv.fixOld_compact (Nat.le_of_ble_eq_true PRE_first_tail_x6_r0_body.fja20) (Nat.le_of_ble_eq_true PRE_first_tail_x6_r0_body.fn20) (Nat.le_of_ble_eq_true PRE_first_tail_x6_r0_body.fjaD20) (Nat.le_of_ble_eq_true PRE_first_tail_x6_r0_body.fxn20) (Nat.le_of_ble_eq_true PRE_first_tail_x6_r0_body.fnn20) (Nat.le_of_ble_eq_true PRE_first_tail_x6_r0_body.fxb20) PRE_first_tail_x6_r0_body.fheap20 PRE_first_tail_x6_r0_body.fhnd20 PRE_first_tail_x6_r0_body.fnode20
kernel_rfl PRE_first_tail_x6_r0_body.fcxn20 : (⟨18589, 15685, 2690171, 910⟩ : Conv.Cnt).xn = (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.s201.ffi).mlx.next
kernel_rfl PRE_first_tail_x6_r0_body.fcnn20 : (⟨18589, 15685, 2690171, 910⟩ : Conv.Cnt).nn = (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.s201.ffi).mlx.nnext
kernel_rfl PRE_first_tail_x6_r0_body.fle020 : (Nat.ble (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.s201.ffi).mlx.next PRE_first_tail_x6_r0_body.cx0_20.mlx.next && Nat.ble (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.s201.ffi).mlx.nnext PRE_first_tail_x6_r0_body.cx0_20.mlx.nnext && Nat.ble (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.s201.ffi).mlx.next RData.bigHi) = true
kernel_rfl PRE_first_tail_x6_r0_body.fnk20 : (PTrie.keysA PRE_first_tail_x6_r0_body.kd20.node).all (Nat.ble (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.s201.ffi).mlx.nnext) = true
-- the merged state keeps the call's entries off the stage's footprint
kernel_rfl PRE_first_tail_x6_r0_body.f1A20 : PRE_first_tail_x6_r0_body.cx1_20.mlx.arrs = Stage.setAll (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.s201.ffi).mlx.arrs (PRE_first_tail_x6_r0_body.cwS20.filterMap fun i => (PRE_first_tail_x6_r0_body.cx1_20.mlx.arrs.get i).map (i, ·))
kernel_rfl PRE_first_tail_x6_r0_body.f1O20 : PRE_first_tail_x6_r0_body.cx1_20.mlx.objs = Stage.setAll (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.s201.ffi).mlx.objs (PRE_first_tail_x6_r0_body.cwS20.filterMap fun i => (PRE_first_tail_x6_r0_body.cx1_20.mlx.objs.get i).map (i, ·))
kernel_rfl PRE_first_tail_x6_r0_body.f1N20 : PRE_first_tail_x6_r0_body.cx1_20.mlx.nodes = Stage.setAll (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.s201.ffi).mlx.nodes (PRE_first_tail_x6_r0_body.cnS20.filterMap fun i => (PRE_first_tail_x6_r0_body.cx1_20.mlx.nodes.get i).map (i, ·))
kernel_rfl PRE_first_tail_x6_r0_body.f1I20 : PRE_first_tail_x6_r0_body.cx1_20.mlx.items = Stage.setAll (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.s201.ffi).mlx.items (PRE_first_tail_x6_r0_body.ciS20.filterMap fun i => (PRE_first_tail_x6_r0_body.cx1_20.mlx.items.get i).map (i, ·))
kernel_rfl PRE_first_tail_x6_r0_body.fbd20 : (PRE_first_tail_x6_r0_body.clo20 ++ PRE_first_tail_x6_r0_body.cln20 ++ PRE_first_tail_x6_r0_body.cli20 ++ PRE_first_tail_x6_r0_body.cwS20 ++ PRE_first_tail_x6_r0_body.cnS20 ++ PRE_first_tail_x6_r0_body.ciS20).all (fun i => Nat.blt (i / 4096) (4 ^ 31)) = true
kernel_rfl PRE_first_tail_x6_r0_body.fincW20 : PRE_first_tail_x6_r0_body.cwS20.all (fun h => !Nat.blt h (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.s201.ffi).mlx.next || PRE_first_tail_x6_r0_body.clo20.contains h) = true
kernel_rfl PRE_first_tail_x6_r0_body.fincI20 : PRE_first_tail_x6_r0_body.ciS20.all (fun k => !Nat.blt k (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.s201.ffi).mlx.nnext || PRE_first_tail_x6_r0_body.cli20.contains k) = true
kernel_rfl PRE_first_tail_x6_r0_body.fincN20 : PRE_first_tail_x6_r0_body.cnS20.all (Nat.ble (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.s201.ffi).mlx.nnext) = true
kernel_rfl PRE_first_tail_x6_r0_body.flnF20 : PRE_first_tail_x6_r0_body.cln20.all (Nat.ble (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.s201.ffi).mlx.nnext) = true
-- the checks over the changed lists
kernel_rfl PRE_first_tail_x6_r0_body.fh20 : PRE_first_tail_x6_r0_body.clo20.all (handleOK PRE_first_tail_x6_r0_body.kappa20 PRE_first_tail_x6_r0_body.P20.lo PRE_first_tail_x6_r0_body.cx0_20.mlx PRE_first_tail_x6_r0_body.cx1_20.mlx) = true
kernel_rfl PRE_first_tail_x6_r0_body.fo20 : PRE_first_tail_x6_r0_body.clo20.map (fun h => PRE_first_tail_x6_r0_body.cx1_20.mlx.objs.get (PRE_first_tail_x6_r0_body.kappa20.handle h)) = PRE_first_tail_x6_r0_body.clo20.map (fun h => (PRE_first_tail_x6_r0_body.cx0_20.mlx.objs.get h).map PRE_first_tail_x6_r0_body.kappa20.nobj)
kernel_rfl PRE_first_tail_x6_r0_body.fok20 : PRE_first_tail_x6_r0_body.clo20.all (objOK PRE_first_tail_x6_r0_body.kappa20 PRE_first_tail_x6_r0_body.P20.NL PRE_first_tail_x6_r0_body.cx0_20.mlx) = true
kernel_rfl PRE_first_tail_x6_r0_body.fnd20 : PRE_first_tail_x6_r0_body.cln20.all (nodeOKF PRE_first_tail_x6_r0_body.kappa20 PRE_first_tail_x6_r0_body.P20 PRE_first_tail_x6_r0_body.cx0_20.mlx PRE_first_tail_x6_r0_body.cx1_20.mlx) = true
kernel_rfl PRE_first_tail_x6_r0_body.fp20 : ((PRE_first_tail_x6_r0_body.cln20.filter (fullB PRE_first_tail_x6_r0_body.P20))).map (fun i => (PRE_first_tail_x6_r0_body.cx1_20.mlx.nodes.get (PRE_first_tail_x6_r0_body.kappa20.node i)).map Host.Mlx.Ffi.Node.prim) =
  ((PRE_first_tail_x6_r0_body.cln20.filter (fullB PRE_first_tail_x6_r0_body.P20))).map (fun i => (PRE_first_tail_x6_r0_body.cx0_20.mlx.nodes.get i).map fun nd => PRE_first_tail_x6_r0_body.kappa20.prim nd.prim)
kernel_rfl PRE_first_tail_x6_r0_body.fnordI20 : incrB PRE_first_tail_x6_r0_body.kd20.nodeF (List.range' 15685 0) = true
kernel_rfl PRE_first_tail_x6_r0_body.fnordK20 : (PTrie.keysA PRE_first_tail_x6_r0_body.kd20.node).all (fun k => Nat.ble 15685 k && Nat.blt k 15685) = true
kernel_rfl PRE_first_tail_x6_r0_body.fnordL20 : (PRE_first_tail_x6_r0_body.cln20.filter (Nat.ble PRE_first_tail_x6_r0_body.P20.N0)).all (fun i => Nat.ble i (PRE_first_tail_x6_r0_body.kd20.nodeF i) && (Nat.blt i 15685 || Nat.ble PRE_first_tail_x6_r0_body.kd20.nn0 i)) = true
theorem PRE_first_tail_x6_r0_body.fnord20 : (PRE_first_tail_x6_r0_body.cln20.filter (Nat.ble PRE_first_tail_x6_r0_body.P20.N0)).all (fun i => Nat.ble i (PRE_first_tail_x6_r0_body.kd20.nodeF i) &&
    (PTrie.keysA PRE_first_tail_x6_r0_body.kd20.node).all fun j => !Nat.blt j i || Nat.blt (PRE_first_tail_x6_r0_body.kd20.nodeF j) (PRE_first_tail_x6_r0_body.kd20.nodeF i)) = true :=
  cnord_of PRE_first_tail_x6_r0_body.cnlow20 PRE_first_tail_x6_r0_body.cnn120 PRE_first_tail_x6_r0_body.fnordI20 PRE_first_tail_x6_r0_body.fnordK20 PRE_first_tail_x6_r0_body.fnordL20
kernel_rfl PRE_first_tail_x6_r0_body.fi20 : PRE_first_tail_x6_r0_body.cli20.all (pnB PRE_first_tail_x6_r0_body.cx0_20.mlx) = true
kernel_rfl PRE_first_tail_x6_r0_body.fii20 : PRE_first_tail_x6_r0_body.cli20.all (fun k => decide (PRE_first_tail_x6_r0_body.cx1_20.mlx.items.get (PRE_first_tail_x6_r0_body.kappa20.node k) = (PRE_first_tail_x6_r0_body.cx0_20.mlx.items.get k).map PRE_first_tail_x6_r0_body.kappa20.nv)) = true
/-- **The compaction's footprint.** -/
theorem PRE_first_tail_x6_r0_body.cfoot20 (clean : Conv.NClean (⟨18589, 15685, 2690171, 910⟩ : Conv.Cnt) (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.s201.ffi).mlx) (hltC : ∀ h, PH (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.s201.ffi).mlx h → h < (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.s201.ffi).mlx.next) (nltC : ∀ i, PN (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.s201.ffi).mlx i → i < (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.s201.ffi).mlx.nnext) (itemsC : ∀ k v, (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.s201.ffi).mlx.items.get k = some v → PN (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.s201.ffi).mlx k) (tracedC : ∀ h o, (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.s201.ffi).mlx.objs.get h = some o → ∀ i ∈ objTraces o, i < PRE_first_tail_x6_r0_body.P20.NL) (cl : SSt (· < 910) PRE_first_tail_x6_r0_body.cx0_20.mlx) :
    Conv.MFoot PRE_first_tail_x6_r0_body.P20 910 PRE_first_tail_x6_r0_body.kappa20 PRE_first_tail_x6_r0_body.kd20 PRE_first_tail_x6_r0_body.khinv20 PRE_first_tail_x6_r0_body.kninv20 (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.s201.ffi).mlx PRE_first_tail_x6_r0_body.cx0_20.mlx PRE_first_tail_x6_r0_body.cx1_20.mlx (⟨18589, 15685, 2690171, 910⟩ : Conv.Cnt) PRE_first_tail_x6_r0_body.clo20 PRE_first_tail_x6_r0_body.cln20 PRE_first_tail_x6_r0_body.cli20 PRE_first_tail_x6_r0_body.cwS20 PRE_first_tail_x6_r0_body.cnS20 PRE_first_tail_x6_r0_body.ciS20 :=
  ⟨rfl, rfl, rfl, PRE_first_tail_x6_r0_body.cnh020, PRE_first_tail_x6_r0_body.cnh120, PRE_first_tail_x6_r0_body.cnn020, PRE_first_tail_x6_r0_body.cnn120, PRE_first_tail_x6_r0_body.cplo20, PRE_first_tail_x6_r0_body.ccnt20, PRE_first_tail_x6_r0_body.cnband20, PRE_first_tail_x6_r0_body.chbelow20, PRE_first_tail_x6_r0_body.chren20, PRE_first_tail_x6_r0_body.cband20, PRE_first_tail_x6_r0_body.cnh1pos20, PRE_first_tail_x6_r0_body.cnren20, PRE_first_tail_x6_r0_body.cnlow20, PRE_first_tail_x6_r0_body.cabs0a20, PRE_first_tail_x6_r0_body.cabs0b20, PRE_first_tail_x6_r0_body.ctok120, PRE_first_tail_x6_r0_body.cpend20, PRE_first_tail_x6_r0_body.cerrh20, PRE_first_tail_x6_r0_body.cfiles20, PRE_first_tail_x6_r0_body.carch20, PRE_first_tail_x6_r0_body.csizes20, PRE_first_tail_x6_r0_body.cwired20, PRE_first_tail_x6_r0_body.cfix20, clean, PRE_first_tail_x6_r0_body.fcxn20, PRE_first_tail_x6_r0_body.fcnn20, hltC, nltC, itemsC, tracedC, cl, PRE_first_tail_x6_r0_body.fle020, PRE_first_tail_x6_r0_body.fnk20, PRE_first_tail_x6_r0_body.ckA20, PRE_first_tail_x6_r0_body.cobjsK20, PRE_first_tail_x6_r0_body.cnodesK20, PRE_first_tail_x6_r0_body.citemsK20, PRE_first_tail_x6_r0_body.f1A20, PRE_first_tail_x6_r0_body.f1O20, PRE_first_tail_x6_r0_body.f1N20, PRE_first_tail_x6_r0_body.f1I20, PRE_first_tail_x6_r0_body.fbd20, PRE_first_tail_x6_r0_body.fincW20, PRE_first_tail_x6_r0_body.fincI20, PRE_first_tail_x6_r0_body.fincN20, PRE_first_tail_x6_r0_body.flnF20, PRE_first_tail_x6_r0_body.fh20, PRE_first_tail_x6_r0_body.fo20, PRE_first_tail_x6_r0_body.fok20, PRE_first_tail_x6_r0_body.fnd20, PRE_first_tail_x6_r0_body.fp20, PRE_first_tail_x6_r0_body.fnord20, PRE_first_tail_x6_r0_body.fi20, PRE_first_tail_x6_r0_body.fii20⟩
theorem PRE_first_tail_x6_r0_body.cnshift20 (clean : Conv.NClean (⟨18589, 15685, 2690171, 910⟩ : Conv.Cnt) (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.s201.ffi).mlx) (hltC : ∀ h, PH (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.s201.ffi).mlx h → h < (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.s201.ffi).mlx.next) (nltC : ∀ i, PN (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.s201.ffi).mlx i → i < (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.s201.ffi).mlx.nnext) (itemsC : ∀ k v, (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.s201.ffi).mlx.items.get k = some v → PN (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.s201.ffi).mlx k) (tracedC : ∀ h o, (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.s201.ffi).mlx.objs.get h = some o → ∀ i ∈ objTraces o, i < PRE_first_tail_x6_r0_body.P20.NL) (cl : SSt (· < 910) PRE_first_tail_x6_r0_body.cx0_20.mlx) : NShift PRE_first_tail_x6_r0_body.P20 910 PRE_first_tail_x6_r0_body.kappa20 PRE_first_tail_x6_r0_body.cx0_20 PRE_first_tail_x6_r0_body.cx1_20 :=
  Conv.nshift_of_foot (PRE_first_tail_x6_r0_body.cfoot20 clean hltC nltC itemsC tracedC cl) PRE_first_tail_x6_r0_body.chost20 (compact_a_eq PRE_first_tail_x6_r0_body.ckn020 PRE_first_tail_x6_r0_body.ckn120 PRE_first_tail_x6_r0_body.ckheap20 PRE_first_tail_x6_r0_body.ckpl20)

-- the observers: the layers' states at the call, the canonical and the merged state, their footprints and checks
noncomputable def PRE_first_tail_x6_r0_body.fxC_20 : PTrie Unit := (Host.Ts.Sim.Full.freedOf PRE_first_tail_x6_r0_body.s201.ffi).getD PTrie.nil
noncomputable def PRE_first_tail_x6_r0_body.krC_20 : Host.Load.Layers.KRec := (Host.Ts.Sim.Full.krecOf PRE_first_tail_x6_r0_body.s201.ffi).getD Host.Load.Layers.KRec.empty
kernel_rfl PRE_first_tail_x6_r0_body.ofxC_20 : (Host.Ts.Sim.Full.freedOf PRE_first_tail_x6_r0_body.s201.ffi) = some PRE_first_tail_x6_r0_body.fxC_20
kernel_rfl PRE_first_tail_x6_r0_body.okrC_20 : (Host.Ts.Sim.Full.krecOf PRE_first_tail_x6_r0_body.s201.ffi) = some PRE_first_tail_x6_r0_body.krC_20
noncomputable def PRE_first_tail_x6_r0_body.fx0_20 : PTrie Unit := (Host.Ts.Sim.Full.freedOf PRE_first_tail_x6_r0_body.s203.ffi).getD PTrie.nil
noncomputable def PRE_first_tail_x6_r0_body.kr0_20 : Host.Load.Layers.KRec := (Host.Ts.Sim.Full.krecOf PRE_first_tail_x6_r0_body.s203.ffi).getD Host.Load.Layers.KRec.empty
kernel_rfl PRE_first_tail_x6_r0_body.ofx0_20 : (Host.Ts.Sim.Full.freedOf PRE_first_tail_x6_r0_body.s203.ffi) = some PRE_first_tail_x6_r0_body.fx0_20
kernel_rfl PRE_first_tail_x6_r0_body.okr0_20 : (Host.Ts.Sim.Full.krecOf PRE_first_tail_x6_r0_body.s203.ffi) = some PRE_first_tail_x6_r0_body.kr0_20
noncomputable def PRE_first_tail_x6_r0_body.fx1_20 : PTrie Unit := (Host.Ts.Sim.Full.freedOf PRE_first_tail_x6_r0_body.s202.ffi).getD PTrie.nil
noncomputable def PRE_first_tail_x6_r0_body.kr1_20 : Host.Load.Layers.KRec := (Host.Ts.Sim.Full.krecOf PRE_first_tail_x6_r0_body.s202.ffi).getD Host.Load.Layers.KRec.empty
kernel_rfl PRE_first_tail_x6_r0_body.ofx1_20 : (Host.Ts.Sim.Full.freedOf PRE_first_tail_x6_r0_body.s202.ffi) = some PRE_first_tail_x6_r0_body.fx1_20
kernel_rfl PRE_first_tail_x6_r0_body.okr1_20 : (Host.Ts.Sim.Full.krecOf PRE_first_tail_x6_r0_body.s202.ffi) = some PRE_first_tail_x6_r0_body.kr1_20
kernel_rfl PRE_first_tail_x6_r0_body.ff020 : PRE_first_tail_x6_r0_body.fx0_20 = Stage.setAll PRE_first_tail_x6_r0_body.fxC_20 (PRE_first_tail_x6_r0_body.clo20.filterMap fun i => (PRE_first_tail_x6_r0_body.fx0_20.get i).map (i, ·))
kernel_rfl PRE_first_tail_x6_r0_body.ff120 : PRE_first_tail_x6_r0_body.fx1_20 = Stage.setAll PRE_first_tail_x6_r0_body.fxC_20 (PRE_first_tail_x6_r0_body.cwS20.filterMap fun i => (PRE_first_tail_x6_r0_body.fx1_20.get i).map (i, ·))
kernel_rfl PRE_first_tail_x6_r0_body.ffck20 : freedLB PRE_first_tail_x6_r0_body.kappa20 PRE_first_tail_x6_r0_body.cx0_20.mlx PRE_first_tail_x6_r0_body.fx0_20 PRE_first_tail_x6_r0_body.fx1_20 PRE_first_tail_x6_r0_body.clo20 = true
kernel_rfl PRE_first_tail_x6_r0_body.fkf020 : PRE_first_tail_x6_r0_body.kr0_20.flags = Stage.setAll PRE_first_tail_x6_r0_body.krC_20.flags (PRE_first_tail_x6_r0_body.clo20.filterMap fun i => (PRE_first_tail_x6_r0_body.kr0_20.flags.get i).map (i, ·))
kernel_rfl PRE_first_tail_x6_r0_body.fkt020 : PRE_first_tail_x6_r0_body.kr0_20.targs = Stage.setAll PRE_first_tail_x6_r0_body.krC_20.targs (PRE_first_tail_x6_r0_body.clo20.filterMap fun i => (PRE_first_tail_x6_r0_body.kr0_20.targs.get i).map (i, ·))
kernel_rfl PRE_first_tail_x6_r0_body.fkf120 : PRE_first_tail_x6_r0_body.kr1_20.flags = Stage.setAll PRE_first_tail_x6_r0_body.krC_20.flags (PRE_first_tail_x6_r0_body.cwS20.filterMap fun i => (PRE_first_tail_x6_r0_body.kr1_20.flags.get i).map (i, ·))
kernel_rfl PRE_first_tail_x6_r0_body.fkt120 : PRE_first_tail_x6_r0_body.kr1_20.targs = Stage.setAll PRE_first_tail_x6_r0_body.krC_20.targs (PRE_first_tail_x6_r0_body.cwS20.filterMap fun i => (PRE_first_tail_x6_r0_body.kr1_20.targs.get i).map (i, ·))
kernel_rfl PRE_first_tail_x6_r0_body.fkck20 : krecLB PRE_first_tail_x6_r0_body.kappa20 910 PRE_first_tail_x6_r0_body.cx0_20.mlx PRE_first_tail_x6_r0_body.kr0_20 PRE_first_tail_x6_r0_body.kr1_20 PRE_first_tail_x6_r0_body.clo20 = true
kernel_rfl PRE_first_tail_x6_r0_body.fkn20 : Nat.ble 910 910 = true
-- the bridge and the pending traces' regions
kernel_rfl PRE_first_tail_x6_r0_body.cbridge20 : Host.Ts.Sim.Full.bridgeOf PRE_first_tail_x6_r0_body.s202.ffi = Host.Ts.Sim.Full.bridgeOf PRE_first_tail_x6_r0_body.s203.ffi
kernel_rfl PRE_first_tail_x6_r0_body.cpendR20 : pendRegB PRE_first_tail_x6_r0_body.kappa20 (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.s203.ffi).mlx = true
kernel_rfl PRE_first_tail_x6_r0_body.cpendLe20 : Nat.ble (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.s203.ffi).mlx.next (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.s202.ffi).mlx.next = true
/-- **The compaction's native shift**, given the call's bookkeeping, its relation's facts (the model's and the
observers') and the canonical closedness. -/
theorem PRE_first_tail_x6_r0_body.cshift20 (clean : Conv.NClean (⟨18589, 15685, 2690171, 910⟩ : Conv.Cnt) (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.s201.ffi).mlx) (hltC : ∀ h, PH (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.s201.ffi).mlx h → h < (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.s201.ffi).mlx.next) (nltC : ∀ i, PN (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.s201.ffi).mlx i → i < (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.s201.ffi).mlx.nnext) (itemsC : ∀ k v, (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.s201.ffi).mlx.items.get k = some v → PN (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.s201.ffi).mlx k) (tracedC : ∀ h o, (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.s201.ffi).mlx.objs.get h = some o → ∀ i ∈ objTraces o, i < PRE_first_tail_x6_r0_body.P20.NL) (cl : SSt (· < 910) PRE_first_tail_x6_r0_body.cx0_20.mlx)
    (hobjC : ∀ h, PRE_first_tail_x6_r0_body.fxC_20.get h = some () → ((Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.s201.ffi).mlx.objs.get h).isSome = true)
    (hfC : ∀ h, (PRE_first_tail_x6_r0_body.krC_20.flags.get h).isSome = true → ((Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.s201.ffi).mlx.objs.get h).isSome = true)
    (htC : ∀ h, (PRE_first_tail_x6_r0_body.krC_20.targs.get h).isSome = true → ((Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.s201.ffi).mlx.objs.get h).isSome = true)
    (hclC : ∀ h l, PRE_first_tail_x6_r0_body.krC_20.targs.get h = some l → Host.Ts.Sim.Full.STargs (· < (⟨18589, 15685, 2690171, 910⟩ : Conv.Cnt).n) l) :
    Conv.FullShiftQ PRE_first_tail_x6_r0_body.P20 910 PRE_first_tail_x6_r0_body.kappa20 PRE_first_tail_x6_r0_body.s203.ffi PRE_first_tail_x6_r0_body.s202.ffi :=
  ⟨PRE_first_tail_x6_r0_body.cnshift20 clean hltC nltC itemsC tracedC cl, PRE_first_tail_x6_r0_body.cqueue20, fun t ht => bSN_sound (List.all_eq_true.mp PRE_first_tail_x6_r0_body.ctokSupp20 t ht),
    PRE_first_tail_x6_r0_body.cbridge20,
    liveShift_foot (x0' := Host.Ts.Sim.Full.mlxOf PRE_first_tail_x6_r0_body.s203.ffi) (x1' := Host.Ts.Sim.Full.mlxOf PRE_first_tail_x6_r0_body.s202.ffi) (PRE_first_tail_x6_r0_body.cfoot20 clean hltC nltC itemsC tracedC cl) rfl PRE_first_tail_x6_r0_body.ofx0_20 PRE_first_tail_x6_r0_body.ofx1_20 hobjC PRE_first_tail_x6_r0_body.ff020 PRE_first_tail_x6_r0_body.ff120 PRE_first_tail_x6_r0_body.ffck20,
    kernShift_foot (x0' := Host.Ts.Sim.Full.mlxOf PRE_first_tail_x6_r0_body.s203.ffi) (x1' := Host.Ts.Sim.Full.mlxOf PRE_first_tail_x6_r0_body.s202.ffi) (PRE_first_tail_x6_r0_body.cfoot20 clean hltC nltC itemsC tracedC cl) rfl PRE_first_tail_x6_r0_body.okr0_20 PRE_first_tail_x6_r0_body.okr1_20 (Nat.le_of_ble_eq_true PRE_first_tail_x6_r0_body.fkn20) hfC htC hclC
      PRE_first_tail_x6_r0_body.fkf020 PRE_first_tail_x6_r0_body.fkt020 PRE_first_tail_x6_r0_body.fkf120 PRE_first_tail_x6_r0_body.fkt120 PRE_first_tail_x6_r0_body.fkck20,
    pendReg_of rfl PRE_first_tail_x6_r0_body.cnh020 PRE_first_tail_x6_r0_body.cnh120 (Nat.le_of_ble_eq_true PRE_first_tail_x6_r0_body.cpendLe20) PRE_first_tail_x6_r0_body.cpendR20⟩

end Host.Load.Run.Tpl
end

section -- st20/H0
set_option Elab.async false
namespace Host.Load.Run.Tpl
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
host_stream_state PRE_first_tail_x6_r0_body.st20 0
host_stream_state PRE_first_tail_x6_r0_body.st20 1
host_stream_state PRE_first_tail_x6_r0_body.st20 2
end Host.Load.Run.Tpl
end

section -- Site20
set_option Elab.async false
namespace Host.Load.Run.Tpl
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
open Host.Ts Host.Ts.Sim Host.Ts.Sim.Template

/-! Call site 20 of chain `PRE_first_tail_x6_r0_body`: `plan__g20__g21` (`plan`), the call state `PRE_first_tail_x6_r0_body.s201`, the merged state `PRE_first_tail_x6_r0_body.s202`,
the site template `PRE_first_tail_x6_r0_body.st20` (σ = `Map.id`, θ the identity at its own site), the canonical state `PRE_first_tail_x6_r0_body.s203`: the merge.
The footprint's facts are in `SiteF20`, the compaction's in `SiteC20`, `SiteK20`, `SiteNa20`, `SiteNb20`. -/

kernel_rfl PRE_first_tail_x6_r0_body.iso20 : PRE_first_tail_x6_r0_body.st20.s0 = { PRE_first_tail_x6_r0_body.s201 with stack := [] }
/-- The caller's frames at the call. -/
noncomputable def PRE_first_tail_x6_r0_body.rs20 : List Frame := PRE_first_tail_x6_r0_body.s201.stack
kernel_rfl PRE_first_tail_x6_r0_body.n0_20 : PRE_first_tail_x6_r0_body.S201.tab.length = 910
kernel_rfl PRE_first_tail_x6_r0_body.tab0_20 : PRE_first_tail_x6_r0_body.st20.S0.tab = PRE_first_tail_x6_r0_body.S201.tab

/-- The fresh variables of the stage's results. -/
def PRE_first_tail_x6_r0_body.ws20 : List Nat := [1358, 1359, 1360]
kernel_rfl PRE_first_tail_x6_r0_body.fresh20 : (PRE_first_tail_x6_r0_body.S201.tab.all fun e => PRE_first_tail_x6_r0_body.ws20.all fun v => e.noVar v) &&
    (PRE_first_tail_x6_r0_body.S201.oracle.all fun q => PRE_first_tail_x6_r0_body.ws20.all fun v => q.noVar v) = true
kernel_rfl PRE_first_tail_x6_r0_body.mergeTab20 : PRE_first_tail_x6_r0_body.S202.tab = PRE_first_tail_x6_r0_body.S201.tab ++ Conv.resTab PRE_first_tail_x6_r0_body.ws20
kernel_rfl PRE_first_tail_x6_r0_body.mergeLen20 : PRE_first_tail_x6_r0_body.st20.S2.tab.length - PRE_first_tail_x6_r0_body.st20.S0.tab.length = 3

-- The merged state: the instance's return state with the caller's frames (`PRE_first_tail_x6_r0_body.merged20`, `merged_relB`).
kernel_rfl PRE_first_tail_x6_r0_body.mheap20 : PRE_first_tail_x6_r0_body.s202.heap = PRE_first_tail_x6_r0_body.st20.s2.heap
kernel_rfl PRE_first_tail_x6_r0_body.mnext20 : PRE_first_tail_x6_r0_body.s202.next = PRE_first_tail_x6_r0_body.st20.s2.next
kernel_rfl PRE_first_tail_x6_r0_body.mctl20 : PRE_first_tail_x6_r0_body.s202.ctl = PRE_first_tail_x6_r0_body.st20.s2.ctl
kernel_rfl PRE_first_tail_x6_r0_body.mstack20 : PRE_first_tail_x6_r0_body.s202.stack = PRE_first_tail_x6_r0_body.st20.s2.stack ++ PRE_first_tail_x6_r0_body.s201.stack
kernel_rfl PRE_first_tail_x6_r0_body.mjobs20 : PRE_first_tail_x6_r0_body.s202.jobs = PRE_first_tail_x6_r0_body.st20.s2.jobs
kernel_rfl PRE_first_tail_x6_r0_body.mffi20 : PRE_first_tail_x6_r0_body.s202.ffi = PRE_first_tail_x6_r0_body.st20.s2.ffi
kernel_rfl PRE_first_tail_x6_r0_body.mtrace20 : PRE_first_tail_x6_r0_body.s202.trace = PRE_first_tail_x6_r0_body.st20.s2.trace
kernel_rfl PRE_first_tail_x6_r0_body.mstores20 : PRE_first_tail_x6_r0_body.s202.stores = PRE_first_tail_x6_r0_body.st20.s2.stores

end Host.Load.Run.Tpl
end

section -- SiteD20
set_option Elab.async false
namespace Host.Load.Run.Tpl
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
open Host.Ts Host.Ts.Sim Host.Ts.Sim.Template

/-! The canonical results at call site 20 of chain `PRE_first_tail_x6_r0_body`: their values in the instance's end table, the references past
the call's table, the canonical variables apart from the stage's. -/

kernel_rfl PRE_first_tail_x6_r0_body.cderived20 : PRE_first_tail_x6_r0_body.nr20.map (fun r => nth? PRE_first_tail_x6_r0_body.st20.S2.tab r) =
  []
kernel_rfl PRE_first_tail_x6_r0_body.cnrLo20 : PRE_first_tail_x6_r0_body.nr20.all (Nat.ble 910) = true
kernel_rfl PRE_first_tail_x6_r0_body.cwsDisj20 : PRE_first_tail_x6_r0_body.cws20.all (fun c => !PRE_first_tail_x6_r0_body.ws20.contains c) = true
/-- The compaction's substitution: the canonical variables to their merged values, the stage's other fresh variables
to `0` (`Conv.compactθZ`). -/
noncomputable def PRE_first_tail_x6_r0_body.cthetaZ20 : Nat → SymE := Conv.compactθZ PRE_first_tail_x6_r0_body.cws20 PRE_first_tail_x6_r0_body.crs20 PRE_first_tail_x6_r0_body.ws20

end Host.Load.Run.Tpl
end

section -- st20/Foot
set_option Elab.async false
namespace Host.Load.Run.Tpl
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
open Host.Ts Host.Ts.Sim Host.Ts.Sim.Stage Host.Ts.Sim.Template

/-! The footprint of stage `PRE_first_tail_x6_r0_body.st20`'s site template (`Conv.StageFoot`, `Conv.NFoot`): every entry of the return
state other than the written and fresh ones is the start's (kernel evaluation of the equalities). -/

/-- The written heap ranges below the start's counter. -/
def PRE_first_tail_x6_r0_body.st20.wrR : List (Nat × Nat) := []
/-- The written and fresh entries of the return state. -/
noncomputable def PRE_first_tail_x6_r0_body.st20.wrE : List (Nat × Host.Ts.HObj) :=
  rangesOf PRE_first_tail_x6_r0_body.st20.s2.heap PRE_first_tail_x6_r0_body.st20.wrR ++ freshOf PRE_first_tail_x6_r0_body.st20.s2.heap PRE_first_tail_x6_r0_body.st20.s0.next PRE_first_tail_x6_r0_body.st20.s2.next
noncomputable def PRE_first_tail_x6_r0_body.st20.wr : List Nat := PRE_first_tail_x6_r0_body.st20.wrE.map (·.1)

kernel_rfl PRE_first_tail_x6_r0_body.st20.heapFoot : PRE_first_tail_x6_r0_body.st20.s2.heap = setAll PRE_first_tail_x6_r0_body.st20.s0.heap PRE_first_tail_x6_r0_body.st20.wrE
kernel_rfl PRE_first_tail_x6_r0_body.st20.grows_check : Nat.ble PRE_first_tail_x6_r0_body.st20.s0.next PRE_first_tail_x6_r0_body.st20.s2.next = true
theorem PRE_first_tail_x6_r0_body.st20.grows : PRE_first_tail_x6_r0_body.st20.s0.next ≤ PRE_first_tail_x6_r0_body.st20.s2.next := Nat.le_of_ble_eq_true PRE_first_tail_x6_r0_body.st20.grows_check

/-- The written and fresh handles; the written readback items of old nodes. -/
def PRE_first_tail_x6_r0_body.st20.wh : List Nat := []
def PRE_first_tail_x6_r0_body.st20.wi : List Nat := []

kernel_rfl PRE_first_tail_x6_r0_body.st20.arrsFoot : (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.st20.s2.ffi).mlx.arrs = setAll (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.st20.s0.ffi).mlx.arrs (PRE_first_tail_x6_r0_body.st20.wh.filterMap fun h => ((Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.st20.s2.ffi).mlx.arrs.get h).map (h, ·))
kernel_rfl PRE_first_tail_x6_r0_body.st20.objsFoot : (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.st20.s2.ffi).mlx.objs = setAll (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.st20.s0.ffi).mlx.objs (PRE_first_tail_x6_r0_body.st20.wh.filterMap fun h => ((Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.st20.s2.ffi).mlx.objs.get h).map (h, ·))
kernel_rfl PRE_first_tail_x6_r0_body.st20.nodesFoot : (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.st20.s2.ffi).mlx.nodes = setAll (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.st20.s0.ffi).mlx.nodes (freshOf (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.st20.s2.ffi).mlx.nodes (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.st20.s0.ffi).mlx.nnext (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.st20.s2.ffi).mlx.nnext)
kernel_rfl PRE_first_tail_x6_r0_body.st20.itemsFoot : (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.st20.s2.ffi).mlx.items = setAll (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.st20.s0.ffi).mlx.items ((PRE_first_tail_x6_r0_body.st20.wi.filterMap fun i => ((Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.st20.s2.ffi).mlx.items.get i).map (i, ·)) ++
    freshOf (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.st20.s2.ffi).mlx.items (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.st20.s0.ffi).mlx.nnext (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.st20.s2.ffi).mlx.nnext)
kernel_rfl PRE_first_tail_x6_r0_body.st20.counters : (Nat.ble (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.st20.s0.ffi).mlx.next (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.st20.s2.ffi).mlx.next && Nat.ble (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.st20.s0.ffi).mlx.nnext (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.st20.s2.ffi).mlx.nnext) = true

end Host.Load.Run.Tpl
end

section -- SiteF20
set_option Elab.async false
namespace Host.Load.Run.Tpl
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
open Host.Ts Host.Ts.Sim Host.Ts.Sim.Template

/-! Call site 20 of chain `PRE_first_tail_x6_r0_body`: `Conv.site_merge`'s footprint facts. -/

kernel_rfl PRE_first_tail_x6_r0_body.wrNodupB20 : nodupT PRE_first_tail_x6_r0_body.st20.wr PTrie.nil = true
theorem PRE_first_tail_x6_r0_body.wrNodup20 : PRE_first_tail_x6_r0_body.st20.wr.Nodup := (nodupT_sound PRE_first_tail_x6_r0_body.wrNodupB20).2
kernel_rfl PRE_first_tail_x6_r0_body.wrBoundB20 : PRE_first_tail_x6_r0_body.st20.wr.all (fun b => Nat.blt (b / 4096) (4 ^ 31)) = true
theorem PRE_first_tail_x6_r0_body.wrBound20 : ∀ b ∈ PRE_first_tail_x6_r0_body.st20.wr, b / 4096 < 4 ^ 31 := fun b hb => Nat.blt_eq.mp (List.all_eq_true.mp PRE_first_tail_x6_r0_body.wrBoundB20 b hb)
noncomputable def PRE_first_tail_x6_r0_body.trFr20 := PRE_first_tail_x6_r0_body.st20.s2.trace.take 0
kernel_rfl PRE_first_tail_x6_r0_body.traceEq20 : PRE_first_tail_x6_r0_body.st20.s2.trace = PRE_first_tail_x6_r0_body.trFr20 ++ PRE_first_tail_x6_r0_body.st20.s0.trace
theorem PRE_first_tail_x6_r0_body.trace20 : ∃ fr, PRE_first_tail_x6_r0_body.st20.s2.trace = fr ++ PRE_first_tail_x6_r0_body.st20.s0.trace := ⟨_, PRE_first_tail_x6_r0_body.traceEq20⟩

-- the caller's wide frames at the instance's start (`Conv.isolateW`'s `W0` under `Map.id`) and their `WFix`
def PRE_first_tail_x6_r0_body.wide20 : List (Nat × WFrame) := [(4910, .memo [])]
kernel_rfl PRE_first_tail_x6_r0_body.wfixB20 : (PRE_first_tail_x6_r0_body.wide20.all fun p => wfixB Map.id (presentB PRE_first_tail_x6_r0_body.st20.s0) p.2) = true
theorem PRE_first_tail_x6_r0_body.wfix20 : ∀ p ∈ PRE_first_tail_x6_r0_body.wide20, WFix Map.id (Present PRE_first_tail_x6_r0_body.st20.s0) p.2 :=
  fun p hp => wfix_of (List.all_eq_true.mp PRE_first_tail_x6_r0_body.wfixB20 p hp)

end Host.Load.Run.Tpl
end

section -- SiteL20
set_option Elab.async false
namespace Host.Load.Run.Tpl
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
open Host.Ts Host.Ts.Sim Host.Ts.Sim.Template

/-! The call link's facts at call site 20 of chain `PRE_first_tail_x6_r0_body`: the instance's start server, its footprint (`Conv.StageFoot`), the
merged state `PRE_first_tail_x6_r0_body.s202`'s framed arrays as the chain start's extended (`arrExt_of`, `numRefs_of`). -/

kernel_rfl PRE_first_tail_x6_r0_body.srvO20 : PRE_first_tail_x6_r0_body.st20.S0.oracle = PRE_first_tail_x6_r0_body.st20.OR
kernel_rfl PRE_first_tail_x6_r0_body.wr0B20 : PRE_first_tail_x6_r0_body.st20.wr.all (fun b => !Nat.blt b PRE_first_tail_x6_r0_body.st20.s0.next || (PRE_first_tail_x6_r0_body.st20.s0.heap.get b).isSome) = true
theorem PRE_first_tail_x6_r0_body.stFoot20 : Conv.StageFoot PRE_first_tail_x6_r0_body.st20.wr PRE_first_tail_x6_r0_body.st20.s0 PRE_first_tail_x6_r0_body.st20.s2 :=
  stageFoot_of PRE_first_tail_x6_r0_body.st20.heapFoot PRE_first_tail_x6_r0_body.wrNodup20 PRE_first_tail_x6_r0_body.wrBound20 PRE_first_tail_x6_r0_body.wr0B20 PRE_first_tail_x6_r0_body.st20.grows

/-- **The relation at the merged state** from the relation at the merge (`Conv.site_merge`'s; `merged_relB`). -/
theorem PRE_first_tail_x6_r0_body.merged20 {FR : Map → Nat → PRE_first_tail_x6_r0_body.st20.F.S → PRE_first_tail_x6_r0_body.st20.F.S → Prop} {W : Nat → Option WFrame} {stk : List Frame} {M : Map}
    {ν : Nat → F64} {K : Host.Ts.Sim.Ctx} {S : SSrv} {t : St PRE_first_tail_x6_r0_body.st20.F.S} {C : CSrv} {n0 : Nat}
    (h : RelB PRE_first_tail_x6_r0_body.st20.F FR W stk M ν K (Conv.mergeSt Map.id (Map.id.res n0 n0) PRE_first_tail_x6_r0_body.rs20 PRE_first_tail_x6_r0_body.st20.wr PRE_first_tail_x6_r0_body.s201 PRE_first_tail_x6_r0_body.st20.s2 PRE_first_tail_x6_r0_body.st20.s0
      PRE_first_tail_x6_r0_body.st20.s2.ffi) S t C) : RelB PRE_first_tail_x6_r0_body.st20.F FR W stk M ν K PRE_first_tail_x6_r0_body.s202 S t C :=
  merged_relB PRE_first_tail_x6_r0_body.iso20 PRE_first_tail_x6_r0_body.stFoot20 PRE_first_tail_x6_r0_body.wrNodup20 PRE_first_tail_x6_r0_body.wrBound20 PRE_first_tail_x6_r0_body.trace20 PRE_first_tail_x6_r0_body.mheap20
    PRE_first_tail_x6_r0_body.mnext20 PRE_first_tail_x6_r0_body.mctl20 PRE_first_tail_x6_r0_body.mstack20 PRE_first_tail_x6_r0_body.mjobs20 PRE_first_tail_x6_r0_body.mffi20 PRE_first_tail_x6_r0_body.mtrace20 PRE_first_tail_x6_r0_body.mstores20 h

def PRE_first_tail_x6_r0_body.arrEl20_2665 : List Val := []
kernel_rfl PRE_first_tail_x6_r0_body.arrE20_2665 : arrOf PRE_first_tail_x6_r0_body.s202 2665 = arrOf PRE_first_tail_x6_r0_body.s0 2665 ++ PRE_first_tail_x6_r0_body.arrEl20_2665
kernel_rfl PRE_first_tail_x6_r0_body.arrA20_2665 : isArrB PRE_first_tail_x6_r0_body.s202 2665 = true
theorem PRE_first_tail_x6_r0_body.arr20_2665 : ∃ o, PRE_first_tail_x6_r0_body.s202.heap.get 2665 = some (.obj o) ∧ o.kind = .array (arrOf PRE_first_tail_x6_r0_body.s0 2665 ++ PRE_first_tail_x6_r0_body.arrEl20_2665) :=
  arrExt_of PRE_first_tail_x6_r0_body.arrE20_2665 PRE_first_tail_x6_r0_body.arrA20_2665
kernel_rfl PRE_first_tail_x6_r0_body.arrN20_2665 : numRefsB PRE_first_tail_x6_r0_body.S0.tab.length PRE_first_tail_x6_r0_body.arrEl20_2665 = true
theorem PRE_first_tail_x6_r0_body.arrR20_2665 : Prefill.NumRefs PRE_first_tail_x6_r0_body.S0.tab.length PRE_first_tail_x6_r0_body.arrEl20_2665 := numRefs_of PRE_first_tail_x6_r0_body.arrN20_2665

def PRE_first_tail_x6_r0_body.arrEl20_2673467 : List Val := []
kernel_rfl PRE_first_tail_x6_r0_body.arrE20_2673467 : arrOf PRE_first_tail_x6_r0_body.s202 2673467 = arrOf PRE_first_tail_x6_r0_body.s0 2673467 ++ PRE_first_tail_x6_r0_body.arrEl20_2673467
kernel_rfl PRE_first_tail_x6_r0_body.arrA20_2673467 : isArrB PRE_first_tail_x6_r0_body.s202 2673467 = true
theorem PRE_first_tail_x6_r0_body.arr20_2673467 : ∃ o, PRE_first_tail_x6_r0_body.s202.heap.get 2673467 = some (.obj o) ∧ o.kind = .array (arrOf PRE_first_tail_x6_r0_body.s0 2673467 ++ PRE_first_tail_x6_r0_body.arrEl20_2673467) :=
  arrExt_of PRE_first_tail_x6_r0_body.arrE20_2673467 PRE_first_tail_x6_r0_body.arrA20_2673467
kernel_rfl PRE_first_tail_x6_r0_body.arrN20_2673467 : numRefsB PRE_first_tail_x6_r0_body.S0.tab.length PRE_first_tail_x6_r0_body.arrEl20_2673467 = true
theorem PRE_first_tail_x6_r0_body.arrR20_2673467 : Prefill.NumRefs PRE_first_tail_x6_r0_body.S0.tab.length PRE_first_tail_x6_r0_body.arrEl20_2673467 := numRefs_of PRE_first_tail_x6_r0_body.arrN20_2673467

kernel_rfl PRE_first_tail_x6_r0_body.w4910k20 : isArrB PRE_first_tail_x6_r0_body.s202 4910 = false
theorem PRE_first_tail_x6_r0_body.keep20 (q : List Val) : Host.Ts.Sim.Prefill.KeepsAtW (framesP PRE_first_tail_x6_r0_body.s0 q) PRE_first_tail_x6_r0_body.s202 := by
  intro a pre pre' hx o es ho hk
  unfold framesP at hx
  simp only at hx
  cases h1 : Nat.beq a 2665
  · cases h2 : Nat.beq a 4910
    · rw [h1, h2] at hx; cases hx
    · have := Nat.eq_of_beq_eq_true h2; subst this
      rw [h1, h2] at hx; cases hx
      exact (notArr_of PRE_first_tail_x6_r0_body.w4910k20 ho hk).elim
  · have := Nat.eq_of_beq_eq_true h1; subst this
    rw [h1] at hx; cases hx
    obtain ⟨o', ho', hk'⟩ := PRE_first_tail_x6_r0_body.arr20_2665
    rw [ho] at ho'; cases ho'
    rw [hk'] at hk; cases hk
    simp [PRE_first_tail_x6_r0_body.arrEl20_2665]

end Host.Load.Run.Tpl
end

section -- SiteZ20
set_option Elab.async false
namespace Host.Load.Run.Tpl
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
open Host.Ts Host.Ts.Sim Host.Ts.Sim.Template

/-! The compaction's state shift at call site 20 of chain `PRE_first_tail_x6_r0_body` (`Conv.compact_shift`): the call `PRE_first_tail_x6_r0_body.s201`, the merged
state `PRE_first_tail_x6_r0_body.s202`, the canonical state `PRE_first_tail_x6_r0_body.s203`; its frames [2665,2673467,2673472,2673473] (kept arrays [2665,2673467]). -/

-- the map's places and counters
kernel_rfl PRE_first_tail_x6_r0_body.zpl20 : PRE_first_tail_x6_r0_body.pl20.all (Nat.ble PRE_first_tail_x6_r0_body.s201.next) = true
kernel_rfl PRE_first_tail_x6_r0_body.zplnd20 : nodupT PRE_first_tail_x6_r0_body.pl20 PTrie.nil = true
kernel_rfl PRE_first_tail_x6_r0_body.zn120 : Nat.ble PRE_first_tail_x6_r0_body.s201.next 2690182 = true
kernel_rfl PRE_first_tail_x6_r0_body.zfirst20 : Nat.ble aFirst PRE_first_tail_x6_r0_body.s201.next = true
kernel_rfl PRE_first_tail_x6_r0_body.zscn20 : PRE_first_tail_x6_r0_body.s203.next = PRE_first_tail_x6_r0_body.s201.next + PRE_first_tail_x6_r0_body.pl20.length
kernel_rfl PRE_first_tail_x6_r0_body.zsmn20 : PRE_first_tail_x6_r0_body.s202.next = 2690182
kernel_rfl PRE_first_tail_x6_r0_body.zgrow20 : Nat.ble PRE_first_tail_x6_r0_body.s203.next PRE_first_tail_x6_r0_body.s202.next = true
-- the tables
kernel_rfl PRE_first_tail_x6_r0_body.zfresh20 : PRE_first_tail_x6_r0_body.S201.tab.all (fun e => PRE_first_tail_x6_r0_body.cws20.all fun v => e.noVar v) = true
kernel_rfl PRE_first_tail_x6_r0_body.zcnd20 : nodupT PRE_first_tail_x6_r0_body.cws20 PTrie.nil = true
kernel_rfl PRE_first_tail_x6_r0_body.znrHi20 : PRE_first_tail_x6_r0_body.nr20.all (fun r => Nat.blt r PRE_first_tail_x6_r0_body.S202.tab.length) = true
-- the frames: every framed address below the call's counter; the kept arrays the chain start's, extended in the merged state
kernel_rfl PRE_first_tail_x6_r0_body.zfrlt20 : [2665, 2673467, 2673472, 2673473].all (fun a => Nat.blt a PRE_first_tail_x6_r0_body.s201.next) = true
kernel_rfl PRE_first_tail_x6_r0_body.zg20_2665 : PRE_first_tail_x6_r0_body.s203.heap.get 2665 = some (.obj (objOf PRE_first_tail_x6_r0_body.s203 2665))
kernel_rfl PRE_first_tail_x6_r0_body.zk20_2665 : (objOf PRE_first_tail_x6_r0_body.s203 2665).kind = .array (arrOf PRE_first_tail_x6_r0_body.s0 2665)
kernel_rfl PRE_first_tail_x6_r0_body.zm20_2665 : PRE_first_tail_x6_r0_body.s202.heap.get 2665 = some (.obj { PRE_first_tail_x6_r0_body.kappa20.obj (objOf PRE_first_tail_x6_r0_body.s203 2665) with
  kind := .array (arrOf PRE_first_tail_x6_r0_body.s0 2665 ++ (arrOf PRE_first_tail_x6_r0_body.s202 2665).drop (arrOf PRE_first_tail_x6_r0_body.s0 2665).length) })
kernel_rfl PRE_first_tail_x6_r0_body.zg20_2673467 : PRE_first_tail_x6_r0_body.s203.heap.get 2673467 = some (.obj (objOf PRE_first_tail_x6_r0_body.s203 2673467))
kernel_rfl PRE_first_tail_x6_r0_body.zk20_2673467 : (objOf PRE_first_tail_x6_r0_body.s203 2673467).kind = .array (arrOf PRE_first_tail_x6_r0_body.s0 2673467)
kernel_rfl PRE_first_tail_x6_r0_body.zm20_2673467 : PRE_first_tail_x6_r0_body.s202.heap.get 2673467 = some (.obj { PRE_first_tail_x6_r0_body.kappa20.obj (objOf PRE_first_tail_x6_r0_body.s203 2673467) with
  kind := .array (arrOf PRE_first_tail_x6_r0_body.s0 2673467 ++ (arrOf PRE_first_tail_x6_r0_body.s202 2673467).drop (arrOf PRE_first_tail_x6_r0_body.s0 2673467).length) })
kernel_rfl PRE_first_tail_x6_r0_body.zw20_4910 : (PRE_first_tail_x6_r0_body.s203.heap.get 4910).isSome = true
kernel_rfl PRE_first_tail_x6_r0_body.zw20_2673472 : (PRE_first_tail_x6_r0_body.s203.heap.get 2673472).isSome = true
kernel_rfl PRE_first_tail_x6_r0_body.zw20_2673473 : (PRE_first_tail_x6_r0_body.s203.heap.get 2673473).isSome = true
-- the heap: the changed list in range, holding the stage's written and fresh addresses; the canonical side's image
kernel_rfl PRE_first_tail_x6_r0_body.zclbd20 : PRE_first_tail_x6_r0_body.cl20.all (fun b => Nat.blt (b / 4096) (4 ^ 31)) = true
kernel_rfl PRE_first_tail_x6_r0_body.zwr20 : PRE_first_tail_x6_r0_body.st20.wr.all (fun b => !Nat.blt b PRE_first_tail_x6_r0_body.s201.next || PRE_first_tail_x6_r0_body.cl20.contains b) = true
def PRE_first_tail_x6_r0_body.zl20 : List Nat := PRE_first_tail_x6_r0_body.cl20.filter fun a => !(List.contains [2665, 2673467] a)
kernel_rfl PRE_first_tail_x6_r0_body.zimgE20 : PRE_first_tail_x6_r0_body.zl20.map (fun a => PRE_first_tail_x6_r0_body.s202.heap.get (PRE_first_tail_x6_r0_body.kappa20.a a)) = PRE_first_tail_x6_r0_body.zl20.map (fun a => (PRE_first_tail_x6_r0_body.s203.heap.get a).map PRE_first_tail_x6_r0_body.kappa20.hobj)
theorem PRE_first_tail_x6_r0_body.zimg20 : HeapImg PRE_first_tail_x6_r0_body.kappa20 PRE_first_tail_x6_r0_body.s203 PRE_first_tail_x6_r0_body.s202 PRE_first_tail_x6_r0_body.zl20 := PRE_first_tail_x6_r0_body.zimgE20
-- the roots and their supports
kernel_rfl PRE_first_tail_x6_r0_body.zctl20 : PRE_first_tail_x6_r0_body.s202.ctl = PRE_first_tail_x6_r0_body.kappa20.ctl PRE_first_tail_x6_r0_body.s203.ctl
kernel_rfl PRE_first_tail_x6_r0_body.zstack20 : PRE_first_tail_x6_r0_body.s202.stack = PRE_first_tail_x6_r0_body.s203.stack.map PRE_first_tail_x6_r0_body.kappa20.frame
kernel_rfl PRE_first_tail_x6_r0_body.zjobs20 : PRE_first_tail_x6_r0_body.s202.jobs = PRE_first_tail_x6_r0_body.s203.jobs.map PRE_first_tail_x6_r0_body.kappa20.job
kernel_rfl PRE_first_tail_x6_r0_body.zstores20 : PRE_first_tail_x6_r0_body.s202.stores = PRE_first_tail_x6_r0_body.kappa20.stores PRE_first_tail_x6_r0_body.s203.stores
kernel_rfl PRE_first_tail_x6_r0_body.zroots20 : checkRootsSupp PRE_first_tail_x6_r0_body.s203 910 = true
kernel_rfl PRE_first_tail_x6_r0_body.znC20 : PRE_first_tail_x6_r0_body.S201.tab.length + PRE_first_tail_x6_r0_body.cws20.length = 910
-- the map as `Conv.compact_shift` states it (the call's counters for the literals)
kernel_rfl PRE_first_tail_x6_r0_body.zkap20 : PRE_first_tail_x6_r0_body.kappa20 = Conv.Map.compact PRE_first_tail_x6_r0_body.s201.next 2690182 PRE_first_tail_x6_r0_body.S201.tab.length PRE_first_tail_x6_r0_body.pl20 (PRE_first_tail_x6_r0_body.nr20.map NumV.ref) PRE_first_tail_x6_r0_body.kd20.big
  PRE_first_tail_x6_r0_body.kd20.region PRE_first_tail_x6_r0_body.kd20.nodeF
-- the bridge inactive at the canonical state (`Conv.FullShiftQ.toX`; the merged state's bridge is the canonical's: cbridge)
theorem PRE_first_tail_x6_r0_body.zbin20 : (Host.Ts.Sim.Full.bridgeOf PRE_first_tail_x6_r0_body.s203.ffi).active = false := (Host.Load.Boot.replay_active Host.Load.Run.Prompt.P.oblog2818)
-- the JS bookkeeping's step (`Conv.JClean.step` over the changed list) and the canonical roots' bigint freedom
kernel_rfl PRE_first_tail_x6_r0_body.zjc20 : Conv.jcleanListB (⟨18589, 15685, 2690172, 910⟩ : Conv.Cnt) PRE_first_tail_x6_r0_body.s203 PRE_first_tail_x6_r0_body.cl20 = true
kernel_rfl PRE_first_tail_x6_r0_body.zrootsB20 : noBigRootsP (fun i => !Conv.oldBigB (⟨18589, 15685, 2690172, 910⟩ : Conv.Cnt) i) PRE_first_tail_x6_r0_body.s203.trace PRE_first_tail_x6_r0_body.s203 = true
kernel_rfl PRE_first_tail_x6_r0_body.zhm20 : Nat.ble (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.s0.ffi).mlx.nnext 15685 = true
theorem PRE_first_tail_x6_r0_body.cjcl20 (h : Conv.JClean (⟨18589, 15685, 2690171, 910⟩ : Conv.Cnt) PRE_first_tail_x6_r0_body.s201) : Conv.JClean (⟨18589, 15685, 2690172, 910⟩ : Conv.Cnt) PRE_first_tail_x6_r0_body.s203 :=
  Conv.JClean.step h (Conv.Cnt.le_of_leB PRE_first_tail_x6_r0_body.cle20)
    (Conv.heap_off_setAll PRE_first_tail_x6_r0_body.cheap20 fun a ha => Nat.blt_eq.mp (List.all_eq_true.mp PRE_first_tail_x6_r0_body.zclbd20 a ha)) PRE_first_tail_x6_r0_body.zjc20

end Host.Load.Run.Tpl
end

section -- st20/TypedLast
set_option Elab.async false
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
namespace Host.Load.Run.Tpl
open Host.Ts Host.Ts.Sim Host.Ts.Sim.Template

boot_rfl PRE_first_tail_x6_r0_body.st20.bodyLast from PRE_first_tail_x6_r0_body.st20.s1 to PRE_first_tail_x6_r0_body.st20.s2 :
  interpS (step PRE_first_tail_x6_r0_body.st20.F PRE_first_tail_x6_r0_body.st20.s1).run PRE_first_tail_x6_r0_body.st20.S1 = some (PRE_first_tail_x6_r0_body.st20.s2, PRE_first_tail_x6_r0_body.st20.S2)
kernel_rfl PRE_first_tail_x6_r0_body.st20.bodyHalt : isHalt PRE_first_tail_x6_r0_body.st20.s1.ctl = false
kernel_rfl PRE_first_tail_x6_r0_body.st20.bodyTopCheck : noBlockTop PRE_first_tail_x6_r0_body.st20.s2.stack = true

end Host.Load.Run.Tpl
end

section -- st20/TypedOk
set_option Elab.async false
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
namespace Host.Load.Run.Tpl
open Host.Ts Host.Ts.Sim Host.Ts.Sim.Template

noncomputable def PRE_first_tail_x6_r0_body.st20.bodyOkL (bytes : List Byte) (rows : Nat) : St PRE_first_tail_x6_r0_body.st20.F.S → SSrv → Bool :=
  okLocal (Host.Ts.Sim.Compose.VWFrames.bodyOk bytes rows)

noncomputable def PRE_first_tail_x6_r0_body.st20.bodyOkLN (bytes : List Byte) (rows : Nat) : St PRE_first_tail_x6_r0_body.st20.F.S → FSrv → Bool :=
  okLocalN (Host.Ts.Sim.Compose.VWFrames.bodyOkN bytes rows)

theorem PRE_first_tail_x6_r0_body.st20.bodyOkLN_ok (bytes : List Byte) (rows : Nat) (s : St PRE_first_tail_x6_r0_body.st20.F.S) (c : FSrv) (h : c.Wf) :
    PRE_first_tail_x6_r0_body.st20.bodyOkLN bytes rows s c = PRE_first_tail_x6_r0_body.st20.bodyOkL bytes rows s c.toS :=
  okLocalN_ok (Host.Ts.Sim.Compose.VWFrames.bodyOkN_ok bytes rows) s c h

kernel_rfl PRE_first_tail_x6_r0_body.st20.bodyAccepted0 :
  (fun (bytes : List Byte) (rows : Nat) => PRE_first_tail_x6_r0_body.st20.bodyOkL bytes rows PRE_first_tail_x6_r0_body.st20.s0 PRE_first_tail_x6_r0_body.st20.S0) = fun _ _ => true

kernel_rfl PRE_first_tail_x6_r0_body.st20.bodyAccepted1 :
  (fun (bytes : List Byte) (rows : Nat) => PRE_first_tail_x6_r0_body.st20.bodyOkL bytes rows PRE_first_tail_x6_r0_body.st20.s1 PRE_first_tail_x6_r0_body.st20.S1) = fun _ _ => true

end Host.Load.Run.Tpl
end

section -- st20/TypedK0
set_option Elab.async false
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
namespace Host.Load.Run.Tpl
open Host.Ts Host.Ts.Sim Host.Ts.Sim.Template

boot_rfl PRE_first_tail_x6_r0_body.st20.bodyK0F from PRE_first_tail_x6_r0_body.st20.s0 to PRE_first_tail_x6_r0_body.st20.s1 :
  (fun (bytes : List Byte) (rows : Nat) => runOkS PRE_first_tail_x6_r0_body.st20.F (PRE_first_tail_x6_r0_body.st20.bodyOkLN bytes rows)
    ((nth? PRE_first_tail_x6_r0_body.st20.ks 0).getD 0) PRE_first_tail_x6_r0_body.st20.s0 PRE_first_tail_x6_r0_body.st20.S0) = fun _ _ => some (PRE_first_tail_x6_r0_body.st20.s1, PRE_first_tail_x6_r0_body.st20.S1)
theorem PRE_first_tail_x6_r0_body.st20.bodyK0 :
  (fun (bytes : List Byte) (rows : Nat) => runOk PRE_first_tail_x6_r0_body.st20.F (PRE_first_tail_x6_r0_body.st20.bodyOkL bytes rows)
    ((nth? PRE_first_tail_x6_r0_body.st20.ks 0).getD 0) PRE_first_tail_x6_r0_body.st20.s0 PRE_first_tail_x6_r0_body.st20.S0) = fun _ _ => some (PRE_first_tail_x6_r0_body.st20.s1, PRE_first_tail_x6_r0_body.st20.S1) :=
  runOk_fun_of_runOkS PRE_first_tail_x6_r0_body.st20.bodyOkLN_ok PRE_first_tail_x6_r0_body.st20.bodyK0F
end Host.Load.Run.Tpl
end

section -- st20/TypedTpl
set_option Elab.async false
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
namespace Host.Load.Run.Tpl
open Host.Ts Host.Ts.Sim Host.Ts.Sim.Template

theorem PRE_first_tail_x6_r0_body.st20.bodyRun (bytes : List Byte) (rows : Nat) :
    runOk PRE_first_tail_x6_r0_body.st20.F (PRE_first_tail_x6_r0_body.st20.bodyOkL bytes rows) 98 PRE_first_tail_x6_r0_body.st20.s0 PRE_first_tail_x6_r0_body.st20.S0 = some (PRE_first_tail_x6_r0_body.st20.s1, PRE_first_tail_x6_r0_body.st20.S1) :=
  (congrFun (congrFun PRE_first_tail_x6_r0_body.st20.bodyK0 bytes) rows)

theorem PRE_first_tail_x6_r0_body.st20.bodyLocal (bytes : List Byte) (rows : Nat) : ∀ s S, PRE_first_tail_x6_r0_body.st20.bodyOkL bytes rows s S = true → Disp.localB s = true := okLocal_localB

noncomputable def PRE_first_tail_x6_r0_body.st20.bodyTpl (bytes : List Byte) (rows : Nat) : Host.Ts.Sim.Stage.StageTpl PRE_first_tail_x6_r0_body.st20.F (PRE_first_tail_x6_r0_body.st20.bodyOkL bytes rows) where
  s0 := PRE_first_tail_x6_r0_body.st20.s0
  S0 := PRE_first_tail_x6_r0_body.st20.S0
  s1 := PRE_first_tail_x6_r0_body.st20.s1
  S1 := PRE_first_tail_x6_r0_body.st20.S1
  s2 := PRE_first_tail_x6_r0_body.st20.s2
  S2 := PRE_first_tail_x6_r0_body.st20.S2
  n := 98
  ok0 := congrFun (congrFun PRE_first_tail_x6_r0_body.st20.bodyAccepted0 bytes) rows
  run := PRE_first_tail_x6_r0_body.st20.bodyRun bytes rows
  ok1 := congrFun (congrFun PRE_first_tail_x6_r0_body.st20.bodyAccepted1 bytes) rows
  halt := PRE_first_tail_x6_r0_body.st20.bodyHalt
  last := PRE_first_tail_x6_r0_body.st20.bodyLast
  top := noBlockTop_sound PRE_first_tail_x6_r0_body.st20.bodyTopCheck
end Host.Load.Run.Tpl
end

section -- SiteC21
set_option Elab.async false
namespace Host.Load.Run.Tpl
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
open Host.Ts Host.Ts.Sim Host.Ts.Sim.Template

/-! The compaction after the merge at call site 21 of chain `PRE_first_tail_x6_r0_body` (`Conv.compact`, `Conv.full_compactQ`): the canonical
state `PRE_first_tail_x6_r0_body.s219` (the stage's results at canonical places, its trace the call's) under `PRE_first_tail_x6_r0_body.kappa21` into the merged state
`PRE_first_tail_x6_r0_body.s218`. -/

def PRE_first_tail_x6_r0_body.pl21 : List Nat := [2692270, 2692106, 2692158, 2692271, 2692272, 2692108, 2692160, 2692269, 2692268, 2692267, 2692266, 2692260, 2692211, 2692262, 2692213]
def PRE_first_tail_x6_r0_body.nr21 : List Nat := [995, 996, 992, 998, 994, 1002, 1003, 1000, 1001]
/-- The native part of the compaction map (canonical → merged handles and nodes: its `big`, `region`, `nodeF`). -/
def PRE_first_tail_x6_r0_body.kd21 : RData :=
  ⟨2691923, 2692273, Stage.setAll PTrie.nil [(2691908, 2692270), (2691909, 2692106), (2691910, 2692158), (2691911, 2692271), (2691912, 2692272), (2691913, 2692108), (2691914, 2692160), (2691915, 2692269), (2691916, 2692268), (2691917, 2692267), (2691918, 2692266), (2691919, 2692260), (2691920, 2692211), (2691921, 2692262), (2691922, 2692213)], Stage.setAll PTrie.nil [(18629, 18631), (18630, 18632), (18631, 18634), (18632, 18633)],
   18633, 18635, 15719, 15719, Stage.setAll PTrie.nil [],
   Stage.setAll PTrie.nil [(987, .ref 995), (988, .ref 996), (989, .ref 992), (990, .ref 998), (991, .ref 994), (992, .ref 1002), (993, .ref 1003), (994, .ref 1000), (995, .ref 1001)]⟩
/-- **The compaction map.** -/
noncomputable def PRE_first_tail_x6_r0_body.kappa21 : Map :=
  Conv.Map.compact 2691908 2692273 987 PRE_first_tail_x6_r0_body.pl21 (PRE_first_tail_x6_r0_body.nr21.map NumV.ref) PRE_first_tail_x6_r0_body.kd21.big
    PRE_first_tail_x6_r0_body.kd21.region PRE_first_tail_x6_r0_body.kd21.nodeF
/-- The canonical result variables and their images, the merged state's entries (`Conv.compactθ`). -/
def PRE_first_tail_x6_r0_body.cws21 : List Nat := [1378, 1379, 1380, 1381, 1382, 1383, 1384, 1385, 1386]
noncomputable def PRE_first_tail_x6_r0_body.crs21 : List SymE := PRE_first_tail_x6_r0_body.nr21.map fun r => (nth? PRE_first_tail_x6_r0_body.S218.tab r).getD (.var 0)
noncomputable def PRE_first_tail_x6_r0_body.ctheta21 : Nat → SymE := Conv.compactθ PRE_first_tail_x6_r0_body.cws21 PRE_first_tail_x6_r0_body.crs21
/-- The call's entries the stage wrote (renamed in the canonical state with the results). -/
def PRE_first_tail_x6_r0_body.wrB21 : List Nat := [2665, 2672353, 2673467]

kernel_rfl PRE_first_tail_x6_r0_body.ctab21 : PRE_first_tail_x6_r0_body.S219.tab = PRE_first_tail_x6_r0_body.S217.tab ++ PRE_first_tail_x6_r0_body.cws21.map SymE.var
kernel_rfl PRE_first_tail_x6_r0_body.ctrace21 : PRE_first_tail_x6_r0_body.s219.trace = PRE_first_tail_x6_r0_body.s217.trace
kernel_rfl PRE_first_tail_x6_r0_body.cnext21 : PRE_first_tail_x6_r0_body.s219.next = 2691923
kernel_rfl PRE_first_tail_x6_r0_body.ccounters21 : ((Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.s219.ffi).mlx.next, (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.s219.ffi).mlx.nnext) = (18633, 15719)
-- the merged state's readback queue, carried to the canonical state (`Conv.FullShiftQ.tokens`, `tokSupp`)
kernel_rfl PRE_first_tail_x6_r0_body.cqueue21 : (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.s218.ffi).mlx.tokens = (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.s219.ffi).mlx.tokens.map PRE_first_tail_x6_r0_body.kappa21.nv
kernel_rfl PRE_first_tail_x6_r0_body.ctokSupp21 : (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.s219.ffi).mlx.tokens.all (bSN 996) = true
-- the written and the result entries carry no bigint of the canonical fresh band [next, E) and no fresh region
kernel_rfl PRE_first_tail_x6_r0_body.cclean21 : Conv.cleanListB 18633 131072 (fun r => Nat.ble 74532 r) PRE_first_tail_x6_r0_body.s219
    (PRE_first_tail_x6_r0_body.wrB21 ++ (List.range 15).map (2691908 + ·)) = true
kernel_rfl PRE_first_tail_x6_r0_body.cbigs21 : bigsOutB 18633 131072 (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.s219.ffi).mlx = true

end Host.Load.Run.Tpl
end

section -- SiteK21
set_option Elab.async false
namespace Host.Load.Run.Tpl
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
open Host.Ts Host.Ts.Sim Host.Ts.Sim.Template

/-! The canonical state's closedness from the call's (`Conv.closed_of_callB`, `Conv.sst_of_callB`): it keeps the call's entries
off the written and the result ones (`PRE_first_tail_x6_r0_body.cl21`; natively the written and result handles, the result nodes, the written
and result items), and those are checked. -/

def PRE_first_tail_x6_r0_body.cl21 : List Nat := [2665, 2672353, 2673467, 2691908, 2691909, 2691910, 2691911, 2691912, 2691913, 2691914, 2691915, 2691916, 2691917, 2691918, 2691919, 2691920, 2691921, 2691922]
def PRE_first_tail_x6_r0_body.clo21 : List Nat := [18629, 18630, 18631, 18632]
def PRE_first_tail_x6_r0_body.cln21 : List Nat := [15713, 15714, 15715, 15716, 15717, 15718]
def PRE_first_tail_x6_r0_body.cli21 : List Nat := [15713, 15714, 15715, 15716, 15717, 15718]
kernel_rfl PRE_first_tail_x6_r0_body.cheap21 : PRE_first_tail_x6_r0_body.s219.heap = Stage.setAll PRE_first_tail_x6_r0_body.s217.heap (PRE_first_tail_x6_r0_body.cl21.filterMap fun a => (PRE_first_tail_x6_r0_body.s219.heap.get a).map (a, ·))
kernel_rfl PRE_first_tail_x6_r0_body.cnextLe21 : Nat.ble PRE_first_tail_x6_r0_body.s217.next PRE_first_tail_x6_r0_body.s219.next = true
kernel_rfl PRE_first_tail_x6_r0_body.ckeepP21 : Conv.keptPresentB PRE_first_tail_x6_r0_body.s217 PRE_first_tail_x6_r0_body.s219 PRE_first_tail_x6_r0_body.cl21 = true
kernel_rfl PRE_first_tail_x6_r0_body.csupp21 : Conv.suppListB PRE_first_tail_x6_r0_body.s219 996 PRE_first_tail_x6_r0_body.cl21 = true
kernel_rfl PRE_first_tail_x6_r0_body.cbound21 : Conv.boundListB PRE_first_tail_x6_r0_body.s219 PRE_first_tail_x6_r0_body.cl21 = true
kernel_rfl PRE_first_tail_x6_r0_body.cnodesK21 : (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.s219.ffi).mlx.nodes = Stage.setAll (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.s217.ffi).mlx.nodes (PRE_first_tail_x6_r0_body.cln21.filterMap fun i => ((Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.s219.ffi).mlx.nodes.get i).map (i, ·))
kernel_rfl PRE_first_tail_x6_r0_body.cobjsK21 : (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.s219.ffi).mlx.objs = Stage.setAll (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.s217.ffi).mlx.objs (PRE_first_tail_x6_r0_body.clo21.filterMap fun i => ((Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.s219.ffi).mlx.objs.get i).map (i, ·))
kernel_rfl PRE_first_tail_x6_r0_body.citemsK21 : (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.s219.ffi).mlx.items = Stage.setAll (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.s217.ffi).mlx.items (PRE_first_tail_x6_r0_body.cli21.filterMap fun i => ((Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.s219.ffi).mlx.items.get i).map (i, ·))
kernel_rfl PRE_first_tail_x6_r0_body.csst21 : Conv.sstListB 996 (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.s219.ffi).mlx PRE_first_tail_x6_r0_body.cln21 PRE_first_tail_x6_r0_body.clo21 PRE_first_tail_x6_r0_body.cli21 = true

end Host.Load.Run.Tpl
end

section -- SiteCl21
set_option Elab.async false
namespace Host.Load.Run.Tpl
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
open Host.Ts Host.Ts.Sim Host.Ts.Sim.Template

kernel_rfl PRE_first_tail_x6_r0_body.ckA21 : (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.s219.ffi).mlx.arrs = Stage.setAll (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.s217.ffi).mlx.arrs (PRE_first_tail_x6_r0_body.clo21.filterMap fun i => ((Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.s219.ffi).mlx.arrs.get i).map (i, ·))
kernel_rfl PRE_first_tail_x6_r0_body.cbd21 : (PRE_first_tail_x6_r0_body.clo21 ++ PRE_first_tail_x6_r0_body.cln21 ++ PRE_first_tail_x6_r0_body.cli21).all (fun i => Nat.blt (i / 4096) (4 ^ 31)) = true
kernel_rfl PRE_first_tail_x6_r0_body.cle21 : Conv.Cnt.leB (⟨18629, 15713, 2691908, 987⟩ : Conv.Cnt) (⟨18633, 15719, 2691923, 996⟩ : Conv.Cnt) = true
kernel_rfl PRE_first_tail_x6_r0_body.cck21 : Conv.ncleanListB (⟨18633, 15719, 2691923, 996⟩ : Conv.Cnt) (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.s219.ffi).mlx PRE_first_tail_x6_r0_body.clo21 PRE_first_tail_x6_r0_body.cln21 PRE_first_tail_x6_r0_body.cli21 = true
theorem PRE_first_tail_x6_r0_body.cncl21 (h : Conv.NClean (⟨18629, 15713, 2691908, 987⟩ : Conv.Cnt) (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.s217.ffi).mlx) : Conv.NClean (⟨18633, 15719, 2691923, 996⟩ : Conv.Cnt) (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.s219.ffi).mlx :=
  Conv.NClean.stepKeep h PRE_first_tail_x6_r0_body.cle21 PRE_first_tail_x6_r0_body.ckA21 PRE_first_tail_x6_r0_body.cobjsK21 PRE_first_tail_x6_r0_body.cnodesK21 PRE_first_tail_x6_r0_body.citemsK21 PRE_first_tail_x6_r0_body.cbd21 PRE_first_tail_x6_r0_body.cck21

end Host.Load.Run.Tpl
end

section -- SiteS21
set_option Elab.async false
namespace Host.Load.Run.Tpl
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
open Host.Ts Host.Ts.Sim Host.Ts.Sim.Template

/-! The compaction's native shift at call site 21 from its footprint (`Conv.nshift_of_foot`), and the observers'
(`liveShift_foot`, `kernShift_foot`): `Conv.FullShiftQ` for `Conv.full_compactQ`, given the call's bookkeeping and its
relation's facts. -/

/-- The load parameters of the chain (band-free: its start's node counter as `NL` and `N0`). -/
def PRE_first_tail_x6_r0_body.Pc21 : LoadP := ⟨18151, 131072, 1099511627776, 15235, 15235, []⟩
/-- The site's band raised to the map's checked fixed-node prefix, including newly recorded closure traces. -/
def PRE_first_tail_x6_r0_body.P21 : LoadP := PRE_first_tail_x6_r0_body.Pc21.raise 15719
kernel_rfl PRE_first_tail_x6_r0_body.craise21 : Nat.ble PRE_first_tail_x6_r0_body.Pc21.N0 15719 = true
theorem PRE_first_tail_x6_r0_body.raised21 : Host.Ts.Sim.Full.Raised PRE_first_tail_x6_r0_body.Pc21 PRE_first_tail_x6_r0_body.P21 :=
  .inr ⟨15719, rfl, Nat.le_of_ble_eq_true PRE_first_tail_x6_r0_body.craise21, rfl⟩
noncomputable abbrev PRE_first_tail_x6_r0_body.cx0_21 : Host.Load.LSt := clearTokens (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.s219.ffi)
noncomputable abbrev PRE_first_tail_x6_r0_body.cx1_21 : Host.Load.LSt := clearTokens (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.s218.ffi)
def PRE_first_tail_x6_r0_body.khinv21 : PTrie Nat := Stage.setAll PTrie.nil [(18631, 18629), (18632, 18630), (18634, 18631), (18633, 18632)]
def PRE_first_tail_x6_r0_body.kninv21 : PTrie Nat := Stage.setAll PTrie.nil [(15713, 15713), (15714, 15714), (15715, 15715), (15716, 15716), (15717, 15717), (15718, 15718)]
/-- The stage's footprint: its written and fresh handles, fresh nodes, written and fresh items. -/
def PRE_first_tail_x6_r0_body.cwS21 : List Nat := [18629, 18630, 18631, 18632, 18633, 18634]
def PRE_first_tail_x6_r0_body.cnS21 : List Nat := List.range' 15713 6
def PRE_first_tail_x6_r0_body.ciS21 : List Nat := [] ++ List.range' 15713 6

-- the small checks (`MChecks`'s)
kernel_rfl PRE_first_tail_x6_r0_body.cnh021 : PRE_first_tail_x6_r0_body.kd21.nh0 = PRE_first_tail_x6_r0_body.cx0_21.mlx.next
kernel_rfl PRE_first_tail_x6_r0_body.cnh121 : PRE_first_tail_x6_r0_body.kd21.nh1 = PRE_first_tail_x6_r0_body.cx1_21.mlx.next
kernel_rfl PRE_first_tail_x6_r0_body.cnn021 : PRE_first_tail_x6_r0_body.kd21.nn0 = PRE_first_tail_x6_r0_body.cx0_21.mlx.nnext
kernel_rfl PRE_first_tail_x6_r0_body.cnn121 : PRE_first_tail_x6_r0_body.kd21.nn1 = PRE_first_tail_x6_r0_body.cx1_21.mlx.nnext
kernel_rfl PRE_first_tail_x6_r0_body.cplo21 : (Nat.blt 0 PRE_first_tail_x6_r0_body.P21.lo && Nat.ble PRE_first_tail_x6_r0_body.P21.lo PRE_first_tail_x6_r0_body.cx0_21.mlx.next && Nat.ble PRE_first_tail_x6_r0_body.P21.lo RData.bigHi && Nat.ble RData.bigHi PRE_first_tail_x6_r0_body.P21.E) = true
kernel_rfl PRE_first_tail_x6_r0_body.ccnt21 : (Nat.ble PRE_first_tail_x6_r0_body.cx0_21.mlx.next PRE_first_tail_x6_r0_body.cx1_21.mlx.next && Nat.ble PRE_first_tail_x6_r0_body.cx0_21.mlx.nnext PRE_first_tail_x6_r0_body.cx1_21.mlx.nnext) = true
kernel_rfl PRE_first_tail_x6_r0_body.cnband21 : (Nat.blt 0 PRE_first_tail_x6_r0_body.P21.NL && Nat.ble PRE_first_tail_x6_r0_body.P21.NL PRE_first_tail_x6_r0_body.P21.N0 && Nat.ble PRE_first_tail_x6_r0_body.P21.N0 PRE_first_tail_x6_r0_body.cx0_21.mlx.nnext) = true
kernel_rfl PRE_first_tail_x6_r0_body.chbelow21 : PRE_first_tail_x6_r0_body.kd21.checkHndBelow = true
kernel_rfl PRE_first_tail_x6_r0_body.chren21 : checkRenG PRE_first_tail_x6_r0_body.kd21.hnd PRE_first_tail_x6_r0_body.khinv21 (phB PRE_first_tail_x6_r0_body.cx0_21.mlx) = true
kernel_rfl PRE_first_tail_x6_r0_body.cband21 : PRE_first_tail_x6_r0_body.kd21.checkBand PRE_first_tail_x6_r0_body.P21.lo = true
kernel_rfl PRE_first_tail_x6_r0_body.cnh1pos21 : Nat.blt 0 PRE_first_tail_x6_r0_body.kd21.nh1 = true
kernel_rfl PRE_first_tail_x6_r0_body.cnren21 : checkRenG PRE_first_tail_x6_r0_body.kd21.node PRE_first_tail_x6_r0_body.kninv21 (pnB PRE_first_tail_x6_r0_body.cx0_21.mlx) = true
kernel_rfl PRE_first_tail_x6_r0_body.cnlow21 : (PTrie.keysA PRE_first_tail_x6_r0_body.kd21.node).all (fun j => Nat.ble PRE_first_tail_x6_r0_body.P21.NL j && Nat.blt (PRE_first_tail_x6_r0_body.kd21.nodeF j) PRE_first_tail_x6_r0_body.cx1_21.mlx.nnext) = true
kernel_rfl PRE_first_tail_x6_r0_body.cabs0a21 : PRE_first_tail_x6_r0_body.cx0_21.mlx.arrs.get 0 = none
kernel_rfl PRE_first_tail_x6_r0_body.cabs0b21 : PRE_first_tail_x6_r0_body.cx0_21.mlx.objs.get 0 = none
kernel_rfl PRE_first_tail_x6_r0_body.ctok121 : PRE_first_tail_x6_r0_body.cx1_21.mlx.tokens = []
kernel_rfl PRE_first_tail_x6_r0_body.cpend21 : PRE_first_tail_x6_r0_body.cx1_21.mlx.pending = PRE_first_tail_x6_r0_body.cx0_21.mlx.pending.map PRE_first_tail_x6_r0_body.kappa21.pend
kernel_rfl PRE_first_tail_x6_r0_body.cerrh21 : PRE_first_tail_x6_r0_body.cx1_21.mlx.errh = PRE_first_tail_x6_r0_body.cx0_21.mlx.errh.map PRE_first_tail_x6_r0_body.kappa21.arg
kernel_rfl PRE_first_tail_x6_r0_body.cfiles21 : PRE_first_tail_x6_r0_body.cx1_21.mlx.files = PRE_first_tail_x6_r0_body.cx0_21.mlx.files
kernel_rfl PRE_first_tail_x6_r0_body.carch21 : PRE_first_tail_x6_r0_body.cx1_21.mlx.arch = PRE_first_tail_x6_r0_body.cx0_21.mlx.arch
kernel_rfl PRE_first_tail_x6_r0_body.csizes21 : PRE_first_tail_x6_r0_body.cx1_21.mlx.deviceSizes = PRE_first_tail_x6_r0_body.cx0_21.mlx.deviceSizes
kernel_rfl PRE_first_tail_x6_r0_body.cwired21 : PRE_first_tail_x6_r0_body.cx1_21.mlx.wired = PRE_first_tail_x6_r0_body.cx0_21.mlx.wired
kernel_rfl PRE_first_tail_x6_r0_body.chost21 : PRE_first_tail_x6_r0_body.cx1_21.host = PRE_first_tail_x6_r0_body.cx0_21.host
-- the compaction map's addresses are `PRE_first_tail_x6_r0_body.kd21`'s
kernel_rfl PRE_first_tail_x6_r0_body.ckn021 : PRE_first_tail_x6_r0_body.kd21.n0 = 2691923
kernel_rfl PRE_first_tail_x6_r0_body.ckn121 : PRE_first_tail_x6_r0_body.kd21.n1 = 2692273
kernel_rfl PRE_first_tail_x6_r0_body.ckheap21 : (PTrie.keysA PRE_first_tail_x6_r0_body.kd21.heap).all (fun x => Nat.ble 2691908 x) = true
kernel_rfl PRE_first_tail_x6_r0_body.ckpl21 : (List.range 15).all (fun j => decide (PRE_first_tail_x6_r0_body.kd21.heap.get (2691908 + j) = nth? PRE_first_tail_x6_r0_body.pl21 j)) = true
-- the map fixes the call's names (`Conv.fixOld_compact`), the call's counters
kernel_rfl PRE_first_tail_x6_r0_body.fja21 : Nat.ble 2691908 2691908 = true
kernel_rfl PRE_first_tail_x6_r0_body.fn21 : Nat.ble 987 987 = true
kernel_rfl PRE_first_tail_x6_r0_body.fjaD21 : Nat.ble 2691908 PRE_first_tail_x6_r0_body.kd21.n0 = true
kernel_rfl PRE_first_tail_x6_r0_body.fxn21 : Nat.ble 18629 PRE_first_tail_x6_r0_body.kd21.nh0 = true
kernel_rfl PRE_first_tail_x6_r0_body.fnn21 : Nat.ble 15713 PRE_first_tail_x6_r0_body.kd21.nn0 = true
kernel_rfl PRE_first_tail_x6_r0_body.fxb21 : Nat.ble 18629 RData.bigHi = true
kernel_rfl PRE_first_tail_x6_r0_body.fheap21 : (PTrie.keysA PRE_first_tail_x6_r0_body.kd21.heap).all (Nat.ble (⟨18629, 15713, 2691908, 987⟩ : Conv.Cnt).ja) = true
kernel_rfl PRE_first_tail_x6_r0_body.fhnd21 : (PTrie.keysA PRE_first_tail_x6_r0_body.kd21.hnd).all (Nat.ble (⟨18629, 15713, 2691908, 987⟩ : Conv.Cnt).xn) = true
kernel_rfl PRE_first_tail_x6_r0_body.fnode21 : (PTrie.keysA PRE_first_tail_x6_r0_body.kd21.node).all (Nat.ble (⟨18629, 15713, 2691908, 987⟩ : Conv.Cnt).nn) = true
/-- The compaction map fixes the call's names. -/
theorem PRE_first_tail_x6_r0_body.cfix21 : Conv.FixOld (⟨18629, 15713, 2691908, 987⟩ : Conv.Cnt) PRE_first_tail_x6_r0_body.kappa21 :=
  Conv.fixOld_compact (Nat.le_of_ble_eq_true PRE_first_tail_x6_r0_body.fja21) (Nat.le_of_ble_eq_true PRE_first_tail_x6_r0_body.fn21) (Nat.le_of_ble_eq_true PRE_first_tail_x6_r0_body.fjaD21) (Nat.le_of_ble_eq_true PRE_first_tail_x6_r0_body.fxn21) (Nat.le_of_ble_eq_true PRE_first_tail_x6_r0_body.fnn21) (Nat.le_of_ble_eq_true PRE_first_tail_x6_r0_body.fxb21) PRE_first_tail_x6_r0_body.fheap21 PRE_first_tail_x6_r0_body.fhnd21 PRE_first_tail_x6_r0_body.fnode21
kernel_rfl PRE_first_tail_x6_r0_body.fcxn21 : (⟨18629, 15713, 2691908, 987⟩ : Conv.Cnt).xn = (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.s217.ffi).mlx.next
kernel_rfl PRE_first_tail_x6_r0_body.fcnn21 : (⟨18629, 15713, 2691908, 987⟩ : Conv.Cnt).nn = (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.s217.ffi).mlx.nnext
kernel_rfl PRE_first_tail_x6_r0_body.fle021 : (Nat.ble (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.s217.ffi).mlx.next PRE_first_tail_x6_r0_body.cx0_21.mlx.next && Nat.ble (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.s217.ffi).mlx.nnext PRE_first_tail_x6_r0_body.cx0_21.mlx.nnext && Nat.ble (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.s217.ffi).mlx.next RData.bigHi) = true
kernel_rfl PRE_first_tail_x6_r0_body.fnk21 : (PTrie.keysA PRE_first_tail_x6_r0_body.kd21.node).all (Nat.ble (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.s217.ffi).mlx.nnext) = true
-- the merged state keeps the call's entries off the stage's footprint
kernel_rfl PRE_first_tail_x6_r0_body.f1A21 : PRE_first_tail_x6_r0_body.cx1_21.mlx.arrs = Stage.setAll (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.s217.ffi).mlx.arrs (PRE_first_tail_x6_r0_body.cwS21.filterMap fun i => (PRE_first_tail_x6_r0_body.cx1_21.mlx.arrs.get i).map (i, ·))
kernel_rfl PRE_first_tail_x6_r0_body.f1O21 : PRE_first_tail_x6_r0_body.cx1_21.mlx.objs = Stage.setAll (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.s217.ffi).mlx.objs (PRE_first_tail_x6_r0_body.cwS21.filterMap fun i => (PRE_first_tail_x6_r0_body.cx1_21.mlx.objs.get i).map (i, ·))
kernel_rfl PRE_first_tail_x6_r0_body.f1N21 : PRE_first_tail_x6_r0_body.cx1_21.mlx.nodes = Stage.setAll (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.s217.ffi).mlx.nodes (PRE_first_tail_x6_r0_body.cnS21.filterMap fun i => (PRE_first_tail_x6_r0_body.cx1_21.mlx.nodes.get i).map (i, ·))
kernel_rfl PRE_first_tail_x6_r0_body.f1I21 : PRE_first_tail_x6_r0_body.cx1_21.mlx.items = Stage.setAll (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.s217.ffi).mlx.items (PRE_first_tail_x6_r0_body.ciS21.filterMap fun i => (PRE_first_tail_x6_r0_body.cx1_21.mlx.items.get i).map (i, ·))
kernel_rfl PRE_first_tail_x6_r0_body.fbd21 : (PRE_first_tail_x6_r0_body.clo21 ++ PRE_first_tail_x6_r0_body.cln21 ++ PRE_first_tail_x6_r0_body.cli21 ++ PRE_first_tail_x6_r0_body.cwS21 ++ PRE_first_tail_x6_r0_body.cnS21 ++ PRE_first_tail_x6_r0_body.ciS21).all (fun i => Nat.blt (i / 4096) (4 ^ 31)) = true
kernel_rfl PRE_first_tail_x6_r0_body.fincW21 : PRE_first_tail_x6_r0_body.cwS21.all (fun h => !Nat.blt h (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.s217.ffi).mlx.next || PRE_first_tail_x6_r0_body.clo21.contains h) = true
kernel_rfl PRE_first_tail_x6_r0_body.fincI21 : PRE_first_tail_x6_r0_body.ciS21.all (fun k => !Nat.blt k (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.s217.ffi).mlx.nnext || PRE_first_tail_x6_r0_body.cli21.contains k) = true
kernel_rfl PRE_first_tail_x6_r0_body.fincN21 : PRE_first_tail_x6_r0_body.cnS21.all (Nat.ble (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.s217.ffi).mlx.nnext) = true
kernel_rfl PRE_first_tail_x6_r0_body.flnF21 : PRE_first_tail_x6_r0_body.cln21.all (Nat.ble (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.s217.ffi).mlx.nnext) = true
-- the checks over the changed lists
kernel_rfl PRE_first_tail_x6_r0_body.fh21 : PRE_first_tail_x6_r0_body.clo21.all (handleOK PRE_first_tail_x6_r0_body.kappa21 PRE_first_tail_x6_r0_body.P21.lo PRE_first_tail_x6_r0_body.cx0_21.mlx PRE_first_tail_x6_r0_body.cx1_21.mlx) = true
kernel_rfl PRE_first_tail_x6_r0_body.fo21 : PRE_first_tail_x6_r0_body.clo21.map (fun h => PRE_first_tail_x6_r0_body.cx1_21.mlx.objs.get (PRE_first_tail_x6_r0_body.kappa21.handle h)) = PRE_first_tail_x6_r0_body.clo21.map (fun h => (PRE_first_tail_x6_r0_body.cx0_21.mlx.objs.get h).map PRE_first_tail_x6_r0_body.kappa21.nobj)
kernel_rfl PRE_first_tail_x6_r0_body.fok21 : PRE_first_tail_x6_r0_body.clo21.all (objOK PRE_first_tail_x6_r0_body.kappa21 PRE_first_tail_x6_r0_body.P21.NL PRE_first_tail_x6_r0_body.cx0_21.mlx) = true
kernel_rfl PRE_first_tail_x6_r0_body.fnd21 : PRE_first_tail_x6_r0_body.cln21.all (nodeOKF PRE_first_tail_x6_r0_body.kappa21 PRE_first_tail_x6_r0_body.P21 PRE_first_tail_x6_r0_body.cx0_21.mlx PRE_first_tail_x6_r0_body.cx1_21.mlx) = true
kernel_rfl PRE_first_tail_x6_r0_body.fp21 : ((PRE_first_tail_x6_r0_body.cln21.filter (fullB PRE_first_tail_x6_r0_body.P21))).map (fun i => (PRE_first_tail_x6_r0_body.cx1_21.mlx.nodes.get (PRE_first_tail_x6_r0_body.kappa21.node i)).map Host.Mlx.Ffi.Node.prim) =
  ((PRE_first_tail_x6_r0_body.cln21.filter (fullB PRE_first_tail_x6_r0_body.P21))).map (fun i => (PRE_first_tail_x6_r0_body.cx0_21.mlx.nodes.get i).map fun nd => PRE_first_tail_x6_r0_body.kappa21.prim nd.prim)
kernel_rfl PRE_first_tail_x6_r0_body.fnordI21 : incrB PRE_first_tail_x6_r0_body.kd21.nodeF (List.range' 15713 6) = true
kernel_rfl PRE_first_tail_x6_r0_body.fnordK21 : (PTrie.keysA PRE_first_tail_x6_r0_body.kd21.node).all (fun k => Nat.ble 15713 k && Nat.blt k 15719) = true
kernel_rfl PRE_first_tail_x6_r0_body.fnordL21 : (PRE_first_tail_x6_r0_body.cln21.filter (Nat.ble PRE_first_tail_x6_r0_body.P21.N0)).all (fun i => Nat.ble i (PRE_first_tail_x6_r0_body.kd21.nodeF i) && (Nat.blt i 15719 || Nat.ble PRE_first_tail_x6_r0_body.kd21.nn0 i)) = true
theorem PRE_first_tail_x6_r0_body.fnord21 : (PRE_first_tail_x6_r0_body.cln21.filter (Nat.ble PRE_first_tail_x6_r0_body.P21.N0)).all (fun i => Nat.ble i (PRE_first_tail_x6_r0_body.kd21.nodeF i) &&
    (PTrie.keysA PRE_first_tail_x6_r0_body.kd21.node).all fun j => !Nat.blt j i || Nat.blt (PRE_first_tail_x6_r0_body.kd21.nodeF j) (PRE_first_tail_x6_r0_body.kd21.nodeF i)) = true :=
  cnord_of PRE_first_tail_x6_r0_body.cnlow21 PRE_first_tail_x6_r0_body.cnn121 PRE_first_tail_x6_r0_body.fnordI21 PRE_first_tail_x6_r0_body.fnordK21 PRE_first_tail_x6_r0_body.fnordL21
kernel_rfl PRE_first_tail_x6_r0_body.fi21 : PRE_first_tail_x6_r0_body.cli21.all (pnB PRE_first_tail_x6_r0_body.cx0_21.mlx) = true
kernel_rfl PRE_first_tail_x6_r0_body.fii21 : PRE_first_tail_x6_r0_body.cli21.all (fun k => decide (PRE_first_tail_x6_r0_body.cx1_21.mlx.items.get (PRE_first_tail_x6_r0_body.kappa21.node k) = (PRE_first_tail_x6_r0_body.cx0_21.mlx.items.get k).map PRE_first_tail_x6_r0_body.kappa21.nv)) = true
/-- **The compaction's footprint.** -/
theorem PRE_first_tail_x6_r0_body.cfoot21 (clean : Conv.NClean (⟨18629, 15713, 2691908, 987⟩ : Conv.Cnt) (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.s217.ffi).mlx) (hltC : ∀ h, PH (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.s217.ffi).mlx h → h < (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.s217.ffi).mlx.next) (nltC : ∀ i, PN (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.s217.ffi).mlx i → i < (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.s217.ffi).mlx.nnext) (itemsC : ∀ k v, (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.s217.ffi).mlx.items.get k = some v → PN (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.s217.ffi).mlx k) (tracedC : ∀ h o, (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.s217.ffi).mlx.objs.get h = some o → ∀ i ∈ objTraces o, i < PRE_first_tail_x6_r0_body.P21.NL) (cl : SSt (· < 996) PRE_first_tail_x6_r0_body.cx0_21.mlx) :
    Conv.MFoot PRE_first_tail_x6_r0_body.P21 996 PRE_first_tail_x6_r0_body.kappa21 PRE_first_tail_x6_r0_body.kd21 PRE_first_tail_x6_r0_body.khinv21 PRE_first_tail_x6_r0_body.kninv21 (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.s217.ffi).mlx PRE_first_tail_x6_r0_body.cx0_21.mlx PRE_first_tail_x6_r0_body.cx1_21.mlx (⟨18629, 15713, 2691908, 987⟩ : Conv.Cnt) PRE_first_tail_x6_r0_body.clo21 PRE_first_tail_x6_r0_body.cln21 PRE_first_tail_x6_r0_body.cli21 PRE_first_tail_x6_r0_body.cwS21 PRE_first_tail_x6_r0_body.cnS21 PRE_first_tail_x6_r0_body.ciS21 :=
  ⟨rfl, rfl, rfl, PRE_first_tail_x6_r0_body.cnh021, PRE_first_tail_x6_r0_body.cnh121, PRE_first_tail_x6_r0_body.cnn021, PRE_first_tail_x6_r0_body.cnn121, PRE_first_tail_x6_r0_body.cplo21, PRE_first_tail_x6_r0_body.ccnt21, PRE_first_tail_x6_r0_body.cnband21, PRE_first_tail_x6_r0_body.chbelow21, PRE_first_tail_x6_r0_body.chren21, PRE_first_tail_x6_r0_body.cband21, PRE_first_tail_x6_r0_body.cnh1pos21, PRE_first_tail_x6_r0_body.cnren21, PRE_first_tail_x6_r0_body.cnlow21, PRE_first_tail_x6_r0_body.cabs0a21, PRE_first_tail_x6_r0_body.cabs0b21, PRE_first_tail_x6_r0_body.ctok121, PRE_first_tail_x6_r0_body.cpend21, PRE_first_tail_x6_r0_body.cerrh21, PRE_first_tail_x6_r0_body.cfiles21, PRE_first_tail_x6_r0_body.carch21, PRE_first_tail_x6_r0_body.csizes21, PRE_first_tail_x6_r0_body.cwired21, PRE_first_tail_x6_r0_body.cfix21, clean, PRE_first_tail_x6_r0_body.fcxn21, PRE_first_tail_x6_r0_body.fcnn21, hltC, nltC, itemsC, tracedC, cl, PRE_first_tail_x6_r0_body.fle021, PRE_first_tail_x6_r0_body.fnk21, PRE_first_tail_x6_r0_body.ckA21, PRE_first_tail_x6_r0_body.cobjsK21, PRE_first_tail_x6_r0_body.cnodesK21, PRE_first_tail_x6_r0_body.citemsK21, PRE_first_tail_x6_r0_body.f1A21, PRE_first_tail_x6_r0_body.f1O21, PRE_first_tail_x6_r0_body.f1N21, PRE_first_tail_x6_r0_body.f1I21, PRE_first_tail_x6_r0_body.fbd21, PRE_first_tail_x6_r0_body.fincW21, PRE_first_tail_x6_r0_body.fincI21, PRE_first_tail_x6_r0_body.fincN21, PRE_first_tail_x6_r0_body.flnF21, PRE_first_tail_x6_r0_body.fh21, PRE_first_tail_x6_r0_body.fo21, PRE_first_tail_x6_r0_body.fok21, PRE_first_tail_x6_r0_body.fnd21, PRE_first_tail_x6_r0_body.fp21, PRE_first_tail_x6_r0_body.fnord21, PRE_first_tail_x6_r0_body.fi21, PRE_first_tail_x6_r0_body.fii21⟩
theorem PRE_first_tail_x6_r0_body.cnshift21 (clean : Conv.NClean (⟨18629, 15713, 2691908, 987⟩ : Conv.Cnt) (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.s217.ffi).mlx) (hltC : ∀ h, PH (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.s217.ffi).mlx h → h < (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.s217.ffi).mlx.next) (nltC : ∀ i, PN (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.s217.ffi).mlx i → i < (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.s217.ffi).mlx.nnext) (itemsC : ∀ k v, (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.s217.ffi).mlx.items.get k = some v → PN (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.s217.ffi).mlx k) (tracedC : ∀ h o, (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.s217.ffi).mlx.objs.get h = some o → ∀ i ∈ objTraces o, i < PRE_first_tail_x6_r0_body.P21.NL) (cl : SSt (· < 996) PRE_first_tail_x6_r0_body.cx0_21.mlx) : NShift PRE_first_tail_x6_r0_body.P21 996 PRE_first_tail_x6_r0_body.kappa21 PRE_first_tail_x6_r0_body.cx0_21 PRE_first_tail_x6_r0_body.cx1_21 :=
  Conv.nshift_of_foot (PRE_first_tail_x6_r0_body.cfoot21 clean hltC nltC itemsC tracedC cl) PRE_first_tail_x6_r0_body.chost21 (compact_a_eq PRE_first_tail_x6_r0_body.ckn021 PRE_first_tail_x6_r0_body.ckn121 PRE_first_tail_x6_r0_body.ckheap21 PRE_first_tail_x6_r0_body.ckpl21)

-- the observers: the layers' states at the call, the canonical and the merged state, their footprints and checks
noncomputable def PRE_first_tail_x6_r0_body.fxC_21 : PTrie Unit := (Host.Ts.Sim.Full.freedOf PRE_first_tail_x6_r0_body.s217.ffi).getD PTrie.nil
noncomputable def PRE_first_tail_x6_r0_body.krC_21 : Host.Load.Layers.KRec := (Host.Ts.Sim.Full.krecOf PRE_first_tail_x6_r0_body.s217.ffi).getD Host.Load.Layers.KRec.empty
kernel_rfl PRE_first_tail_x6_r0_body.ofxC_21 : (Host.Ts.Sim.Full.freedOf PRE_first_tail_x6_r0_body.s217.ffi) = some PRE_first_tail_x6_r0_body.fxC_21
kernel_rfl PRE_first_tail_x6_r0_body.okrC_21 : (Host.Ts.Sim.Full.krecOf PRE_first_tail_x6_r0_body.s217.ffi) = some PRE_first_tail_x6_r0_body.krC_21
noncomputable def PRE_first_tail_x6_r0_body.fx0_21 : PTrie Unit := (Host.Ts.Sim.Full.freedOf PRE_first_tail_x6_r0_body.s219.ffi).getD PTrie.nil
noncomputable def PRE_first_tail_x6_r0_body.kr0_21 : Host.Load.Layers.KRec := (Host.Ts.Sim.Full.krecOf PRE_first_tail_x6_r0_body.s219.ffi).getD Host.Load.Layers.KRec.empty
kernel_rfl PRE_first_tail_x6_r0_body.ofx0_21 : (Host.Ts.Sim.Full.freedOf PRE_first_tail_x6_r0_body.s219.ffi) = some PRE_first_tail_x6_r0_body.fx0_21
kernel_rfl PRE_first_tail_x6_r0_body.okr0_21 : (Host.Ts.Sim.Full.krecOf PRE_first_tail_x6_r0_body.s219.ffi) = some PRE_first_tail_x6_r0_body.kr0_21
noncomputable def PRE_first_tail_x6_r0_body.fx1_21 : PTrie Unit := (Host.Ts.Sim.Full.freedOf PRE_first_tail_x6_r0_body.s218.ffi).getD PTrie.nil
noncomputable def PRE_first_tail_x6_r0_body.kr1_21 : Host.Load.Layers.KRec := (Host.Ts.Sim.Full.krecOf PRE_first_tail_x6_r0_body.s218.ffi).getD Host.Load.Layers.KRec.empty
kernel_rfl PRE_first_tail_x6_r0_body.ofx1_21 : (Host.Ts.Sim.Full.freedOf PRE_first_tail_x6_r0_body.s218.ffi) = some PRE_first_tail_x6_r0_body.fx1_21
kernel_rfl PRE_first_tail_x6_r0_body.okr1_21 : (Host.Ts.Sim.Full.krecOf PRE_first_tail_x6_r0_body.s218.ffi) = some PRE_first_tail_x6_r0_body.kr1_21
kernel_rfl PRE_first_tail_x6_r0_body.ff021 : PRE_first_tail_x6_r0_body.fx0_21 = Stage.setAll PRE_first_tail_x6_r0_body.fxC_21 (PRE_first_tail_x6_r0_body.clo21.filterMap fun i => (PRE_first_tail_x6_r0_body.fx0_21.get i).map (i, ·))
kernel_rfl PRE_first_tail_x6_r0_body.ff121 : PRE_first_tail_x6_r0_body.fx1_21 = Stage.setAll PRE_first_tail_x6_r0_body.fxC_21 (PRE_first_tail_x6_r0_body.cwS21.filterMap fun i => (PRE_first_tail_x6_r0_body.fx1_21.get i).map (i, ·))
kernel_rfl PRE_first_tail_x6_r0_body.ffck21 : freedLB PRE_first_tail_x6_r0_body.kappa21 PRE_first_tail_x6_r0_body.cx0_21.mlx PRE_first_tail_x6_r0_body.fx0_21 PRE_first_tail_x6_r0_body.fx1_21 PRE_first_tail_x6_r0_body.clo21 = true
kernel_rfl PRE_first_tail_x6_r0_body.fkf021 : PRE_first_tail_x6_r0_body.kr0_21.flags = Stage.setAll PRE_first_tail_x6_r0_body.krC_21.flags (PRE_first_tail_x6_r0_body.clo21.filterMap fun i => (PRE_first_tail_x6_r0_body.kr0_21.flags.get i).map (i, ·))
kernel_rfl PRE_first_tail_x6_r0_body.fkt021 : PRE_first_tail_x6_r0_body.kr0_21.targs = Stage.setAll PRE_first_tail_x6_r0_body.krC_21.targs (PRE_first_tail_x6_r0_body.clo21.filterMap fun i => (PRE_first_tail_x6_r0_body.kr0_21.targs.get i).map (i, ·))
kernel_rfl PRE_first_tail_x6_r0_body.fkf121 : PRE_first_tail_x6_r0_body.kr1_21.flags = Stage.setAll PRE_first_tail_x6_r0_body.krC_21.flags (PRE_first_tail_x6_r0_body.cwS21.filterMap fun i => (PRE_first_tail_x6_r0_body.kr1_21.flags.get i).map (i, ·))
kernel_rfl PRE_first_tail_x6_r0_body.fkt121 : PRE_first_tail_x6_r0_body.kr1_21.targs = Stage.setAll PRE_first_tail_x6_r0_body.krC_21.targs (PRE_first_tail_x6_r0_body.cwS21.filterMap fun i => (PRE_first_tail_x6_r0_body.kr1_21.targs.get i).map (i, ·))
kernel_rfl PRE_first_tail_x6_r0_body.fkck21 : krecLB PRE_first_tail_x6_r0_body.kappa21 996 PRE_first_tail_x6_r0_body.cx0_21.mlx PRE_first_tail_x6_r0_body.kr0_21 PRE_first_tail_x6_r0_body.kr1_21 PRE_first_tail_x6_r0_body.clo21 = true
kernel_rfl PRE_first_tail_x6_r0_body.fkn21 : Nat.ble 987 996 = true
-- the bridge and the pending traces' regions
kernel_rfl PRE_first_tail_x6_r0_body.cbridge21 : Host.Ts.Sim.Full.bridgeOf PRE_first_tail_x6_r0_body.s218.ffi = Host.Ts.Sim.Full.bridgeOf PRE_first_tail_x6_r0_body.s219.ffi
kernel_rfl PRE_first_tail_x6_r0_body.cpendR21 : pendRegB PRE_first_tail_x6_r0_body.kappa21 (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.s219.ffi).mlx = true
kernel_rfl PRE_first_tail_x6_r0_body.cpendLe21 : Nat.ble (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.s219.ffi).mlx.next (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.s218.ffi).mlx.next = true
/-- **The compaction's native shift**, given the call's bookkeeping, its relation's facts (the model's and the
observers') and the canonical closedness. -/
theorem PRE_first_tail_x6_r0_body.cshift21 (clean : Conv.NClean (⟨18629, 15713, 2691908, 987⟩ : Conv.Cnt) (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.s217.ffi).mlx) (hltC : ∀ h, PH (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.s217.ffi).mlx h → h < (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.s217.ffi).mlx.next) (nltC : ∀ i, PN (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.s217.ffi).mlx i → i < (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.s217.ffi).mlx.nnext) (itemsC : ∀ k v, (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.s217.ffi).mlx.items.get k = some v → PN (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.s217.ffi).mlx k) (tracedC : ∀ h o, (Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.s217.ffi).mlx.objs.get h = some o → ∀ i ∈ objTraces o, i < PRE_first_tail_x6_r0_body.P21.NL) (cl : SSt (· < 996) PRE_first_tail_x6_r0_body.cx0_21.mlx)
    (hobjC : ∀ h, PRE_first_tail_x6_r0_body.fxC_21.get h = some () → ((Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.s217.ffi).mlx.objs.get h).isSome = true)
    (hfC : ∀ h, (PRE_first_tail_x6_r0_body.krC_21.flags.get h).isSome = true → ((Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.s217.ffi).mlx.objs.get h).isSome = true)
    (htC : ∀ h, (PRE_first_tail_x6_r0_body.krC_21.targs.get h).isSome = true → ((Host.Load.Layers.toLoad PRE_first_tail_x6_r0_body.s217.ffi).mlx.objs.get h).isSome = true)
    (hclC : ∀ h l, PRE_first_tail_x6_r0_body.krC_21.targs.get h = some l → Host.Ts.Sim.Full.STargs (· < (⟨18629, 15713, 2691908, 987⟩ : Conv.Cnt).n) l) :
    Conv.FullShiftQ PRE_first_tail_x6_r0_body.P21 996 PRE_first_tail_x6_r0_body.kappa21 PRE_first_tail_x6_r0_body.s219.ffi PRE_first_tail_x6_r0_body.s218.ffi :=
  ⟨PRE_first_tail_x6_r0_body.cnshift21 clean hltC nltC itemsC tracedC cl, PRE_first_tail_x6_r0_body.cqueue21, fun t ht => bSN_sound (List.all_eq_true.mp PRE_first_tail_x6_r0_body.ctokSupp21 t ht),
    PRE_first_tail_x6_r0_body.cbridge21,
    liveShift_foot (x0' := Host.Ts.Sim.Full.mlxOf PRE_first_tail_x6_r0_body.s219.ffi) (x1' := Host.Ts.Sim.Full.mlxOf PRE_first_tail_x6_r0_body.s218.ffi) (PRE_first_tail_x6_r0_body.cfoot21 clean hltC nltC itemsC tracedC cl) rfl PRE_first_tail_x6_r0_body.ofx0_21 PRE_first_tail_x6_r0_body.ofx1_21 hobjC PRE_first_tail_x6_r0_body.ff021 PRE_first_tail_x6_r0_body.ff121 PRE_first_tail_x6_r0_body.ffck21,
    kernShift_foot (x0' := Host.Ts.Sim.Full.mlxOf PRE_first_tail_x6_r0_body.s219.ffi) (x1' := Host.Ts.Sim.Full.mlxOf PRE_first_tail_x6_r0_body.s218.ffi) (PRE_first_tail_x6_r0_body.cfoot21 clean hltC nltC itemsC tracedC cl) rfl PRE_first_tail_x6_r0_body.okr0_21 PRE_first_tail_x6_r0_body.okr1_21 (Nat.le_of_ble_eq_true PRE_first_tail_x6_r0_body.fkn21) hfC htC hclC
      PRE_first_tail_x6_r0_body.fkf021 PRE_first_tail_x6_r0_body.fkt021 PRE_first_tail_x6_r0_body.fkf121 PRE_first_tail_x6_r0_body.fkt121 PRE_first_tail_x6_r0_body.fkck21,
    pendReg_of rfl PRE_first_tail_x6_r0_body.cnh021 PRE_first_tail_x6_r0_body.cnh121 (Nat.le_of_ble_eq_true PRE_first_tail_x6_r0_body.cpendLe21) PRE_first_tail_x6_r0_body.cpendR21⟩

end Host.Load.Run.Tpl
end

section -- st21/H0
set_option Elab.async false
namespace Host.Load.Run.Tpl
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
host_stream_state PRE_first_tail_x6_r0_body.st21 0
host_stream_state PRE_first_tail_x6_r0_body.st21 1
host_stream_state PRE_first_tail_x6_r0_body.st21 2
host_stream_state PRE_first_tail_x6_r0_body.st21 3
end Host.Load.Run.Tpl
end

section -- Site21
set_option Elab.async false
namespace Host.Load.Run.Tpl
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
open Host.Ts Host.Ts.Sim Host.Ts.Sim.Template

/-! Call site 21 of chain `PRE_first_tail_x6_r0_body`: `kvW__g21__g22` (`appendWindow`), the call state `PRE_first_tail_x6_r0_body.s217`, the merged state `PRE_first_tail_x6_r0_body.s218`,
the site template `PRE_first_tail_x6_r0_body.st21` (σ = `Map.id`, θ the identity at its own site), the canonical state `PRE_first_tail_x6_r0_body.s219`: the merge.
The footprint's facts are in `SiteF21`, the compaction's in `SiteC21`, `SiteK21`, `SiteNa21`, `SiteNb21`. -/

kernel_rfl PRE_first_tail_x6_r0_body.iso21 : PRE_first_tail_x6_r0_body.st21.s0 = { PRE_first_tail_x6_r0_body.s217 with stack := [] }
/-- The caller's frames at the call. -/
noncomputable def PRE_first_tail_x6_r0_body.rs21 : List Frame := PRE_first_tail_x6_r0_body.s217.stack
kernel_rfl PRE_first_tail_x6_r0_body.n0_21 : PRE_first_tail_x6_r0_body.S217.tab.length = 987
kernel_rfl PRE_first_tail_x6_r0_body.tab0_21 : PRE_first_tail_x6_r0_body.st21.S0.tab = PRE_first_tail_x6_r0_body.S217.tab

/-- The fresh variables of the stage's results. -/
def PRE_first_tail_x6_r0_body.ws21 : List Nat := [1361, 1362, 1363, 1364, 1365, 1366, 1367, 1368, 1369, 1370, 1371, 1372, 1373, 1374, 1375, 1376, 1377]
kernel_rfl PRE_first_tail_x6_r0_body.fresh21 : (PRE_first_tail_x6_r0_body.S217.tab.all fun e => PRE_first_tail_x6_r0_body.ws21.all fun v => e.noVar v) &&
    (PRE_first_tail_x6_r0_body.S217.oracle.all fun q => PRE_first_tail_x6_r0_body.ws21.all fun v => q.noVar v) = true
kernel_rfl PRE_first_tail_x6_r0_body.mergeTab21 : PRE_first_tail_x6_r0_body.S218.tab = PRE_first_tail_x6_r0_body.S217.tab ++ Conv.resTab PRE_first_tail_x6_r0_body.ws21
kernel_rfl PRE_first_tail_x6_r0_body.mergeLen21 : PRE_first_tail_x6_r0_body.st21.S3.tab.length - PRE_first_tail_x6_r0_body.st21.S0.tab.length = 17

-- The merged state: the instance's return state with the caller's frames (`PRE_first_tail_x6_r0_body.merged21`, `merged_relB`).
kernel_rfl PRE_first_tail_x6_r0_body.mheap21 : PRE_first_tail_x6_r0_body.s218.heap = PRE_first_tail_x6_r0_body.st21.s3.heap
kernel_rfl PRE_first_tail_x6_r0_body.mnext21 : PRE_first_tail_x6_r0_body.s218.next = PRE_first_tail_x6_r0_body.st21.s3.next
kernel_rfl PRE_first_tail_x6_r0_body.mctl21 : PRE_first_tail_x6_r0_body.s218.ctl = PRE_first_tail_x6_r0_body.st21.s3.ctl
kernel_rfl PRE_first_tail_x6_r0_body.mstack21 : PRE_first_tail_x6_r0_body.s218.stack = PRE_first_tail_x6_r0_body.st21.s3.stack ++ PRE_first_tail_x6_r0_body.s217.stack
kernel_rfl PRE_first_tail_x6_r0_body.mjobs21 : PRE_first_tail_x6_r0_body.s218.jobs = PRE_first_tail_x6_r0_body.st21.s3.jobs
kernel_rfl PRE_first_tail_x6_r0_body.mffi21 : PRE_first_tail_x6_r0_body.s218.ffi = PRE_first_tail_x6_r0_body.st21.s3.ffi
kernel_rfl PRE_first_tail_x6_r0_body.mtrace21 : PRE_first_tail_x6_r0_body.s218.trace = PRE_first_tail_x6_r0_body.st21.s3.trace
kernel_rfl PRE_first_tail_x6_r0_body.mstores21 : PRE_first_tail_x6_r0_body.s218.stores = PRE_first_tail_x6_r0_body.st21.s3.stores

end Host.Load.Run.Tpl
end

section -- SiteD21
set_option Elab.async false
namespace Host.Load.Run.Tpl
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
open Host.Ts Host.Ts.Sim Host.Ts.Sim.Template

/-! The canonical results at call site 21 of chain `PRE_first_tail_x6_r0_body`: their values in the instance's end table, the references past
the call's table, the canonical variables apart from the stage's. -/

kernel_rfl PRE_first_tail_x6_r0_body.cderived21 : PRE_first_tail_x6_r0_body.nr21.map (fun r => nth? PRE_first_tail_x6_r0_body.st21.S3.tab r) =
  [some (SymE.bin .add (SymE.lit (F64.zero false)) (SymE.un .int32 (SymE.un .int32 (SymE.var 10)))),
   some (SymE.un .int32 (SymE.bin .add (SymE.lit (F64.zero false)) (SymE.un .int32 (SymE.un .int32 (SymE.var 10))))),
   some (SymE.un .int32 (SymE.bin .mul (SymE.un .floor (SymE.bin .div (SymE.bin .sub (SymE.bin .add (SymE.lit (F64.fin false 256 (0))) (SymE.un .int32 (SymE.un .int32 (SymE.var 10)))) (SymE.lit (F64.fin false 1 (0)))) (SymE.lit (F64.fin false 256 (0))))) (SymE.lit (F64.fin false 256 (0))))),
   some (SymE.un .int32 (SymE.bin .add (SymE.lit (F64.zero false)) (SymE.un .int32 (SymE.un .int32 (SymE.var 10))))),
   some (SymE.un .int32 (SymE.bin .mul (SymE.un .floor (SymE.bin .div (SymE.bin .sub (SymE.bin .add (SymE.lit (F64.fin false 256 (0))) (SymE.un .int32 (SymE.un .int32 (SymE.var 10)))) (SymE.lit (F64.fin false 1 (0)))) (SymE.lit (F64.fin false 256 (0))))) (SymE.lit (F64.fin false 256 (0))))),
   some (SymE.un .int32 (SymE.bin .add (SymE.lit (F64.zero false)) (SymE.un .int32 (SymE.un .int32 (SymE.var 10))))),
   some (SymE.bin .sub (SymE.un .int32 (SymE.bin .add (SymE.lit (F64.zero false)) (SymE.un .int32 (SymE.un .int32 (SymE.var 10))))) (SymE.lit (F64.zero false))),
   some (SymE.un .int32 (SymE.bin .add (SymE.lit (F64.zero false)) (SymE.un .int32 (SymE.un .int32 (SymE.var 10))))),
   some (SymE.bin .sub (SymE.un .int32 (SymE.bin .add (SymE.lit (F64.zero false)) (SymE.un .int32 (SymE.un .int32 (SymE.var 10))))) (SymE.lit (F64.zero false)))]
kernel_rfl PRE_first_tail_x6_r0_body.cnrLo21 : PRE_first_tail_x6_r0_body.nr21.all (Nat.ble 987) = true
kernel_rfl PRE_first_tail_x6_r0_body.cwsDisj21 : PRE_first_tail_x6_r0_body.cws21.all (fun c => !PRE_first_tail_x6_r0_body.ws21.contains c) = true
/-- The compaction's substitution: the canonical variables to their merged values, the stage's other fresh variables
to `0` (`Conv.compactθZ`). -/
noncomputable def PRE_first_tail_x6_r0_body.cthetaZ21 : Nat → SymE := Conv.compactθZ PRE_first_tail_x6_r0_body.cws21 PRE_first_tail_x6_r0_body.crs21 PRE_first_tail_x6_r0_body.ws21

end Host.Load.Run.Tpl
end
