import host.sim.template.a4pre_first_tail_x15_r0_body.m.B19
import host.sim.conv.CompactFull
import host.sim.template.FootGen
import host.sim.template.a4pre_first_tail_x15_r0_body.States
import host.sim.template.a4pre_first_tail_x15_r0_body.m.B00
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

section -- SiteS43
set_option Elab.async false
namespace Host.Load.Run.Tpl
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
open Host.Ts Host.Ts.Sim Host.Ts.Sim.Template

/-! The compaction's native shift at call site 43 from its footprint (`Conv.nshift_of_foot`), and the observers'
(`liveShift_foot`, `kernShift_foot`): `Conv.FullShiftQ` for `Conv.full_compactQ`, given the call's bookkeeping and its
relation's facts. -/

/-- The load parameters of the chain (band-free: its start's node counter as `NL` and `N0`). -/
def PRE_first_tail_x15_r0_body.Pc43 : LoadP := ⟨18151, 131072, 1099511627776, 15235, 15235, []⟩
/-- The site's band raised to the map's checked fixed-node prefix, including newly recorded closure traces. -/
def PRE_first_tail_x15_r0_body.P43 : LoadP := PRE_first_tail_x15_r0_body.Pc43.raise 16155
kernel_rfl PRE_first_tail_x15_r0_body.craise43 : Nat.ble PRE_first_tail_x15_r0_body.Pc43.N0 16155 = true
theorem PRE_first_tail_x15_r0_body.raised43 : Host.Ts.Sim.Full.Raised PRE_first_tail_x15_r0_body.Pc43 PRE_first_tail_x15_r0_body.P43 :=
  .inr ⟨16155, rfl, Nat.le_of_ble_eq_true PRE_first_tail_x15_r0_body.craise43, rfl⟩
noncomputable abbrev PRE_first_tail_x15_r0_body.cx0_43 : Host.Load.LSt := clearTokens (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s429.ffi)
noncomputable abbrev PRE_first_tail_x15_r0_body.cx1_43 : Host.Load.LSt := clearTokens (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s428.ffi)
def PRE_first_tail_x15_r0_body.khinv43 : PTrie Nat := Stage.setAll PTrie.nil []
def PRE_first_tail_x15_r0_body.kninv43 : PTrie Nat := Stage.setAll PTrie.nil []
/-- The stage's footprint: its written and fresh handles, fresh nodes, written and fresh items. -/
def PRE_first_tail_x15_r0_body.cwS43 : List Nat := []
def PRE_first_tail_x15_r0_body.cnS43 : List Nat := List.range' 16155 0
def PRE_first_tail_x15_r0_body.ciS43 : List Nat := [] ++ List.range' 16155 0

-- the small checks (`MChecks`'s)
kernel_rfl PRE_first_tail_x15_r0_body.cnh043 : PRE_first_tail_x15_r0_body.kd43.nh0 = PRE_first_tail_x15_r0_body.cx0_43.mlx.next
kernel_rfl PRE_first_tail_x15_r0_body.cnh143 : PRE_first_tail_x15_r0_body.kd43.nh1 = PRE_first_tail_x15_r0_body.cx1_43.mlx.next
kernel_rfl PRE_first_tail_x15_r0_body.cnn043 : PRE_first_tail_x15_r0_body.kd43.nn0 = PRE_first_tail_x15_r0_body.cx0_43.mlx.nnext
kernel_rfl PRE_first_tail_x15_r0_body.cnn143 : PRE_first_tail_x15_r0_body.kd43.nn1 = PRE_first_tail_x15_r0_body.cx1_43.mlx.nnext
kernel_rfl PRE_first_tail_x15_r0_body.cplo43 : (Nat.blt 0 PRE_first_tail_x15_r0_body.P43.lo && Nat.ble PRE_first_tail_x15_r0_body.P43.lo PRE_first_tail_x15_r0_body.cx0_43.mlx.next && Nat.ble PRE_first_tail_x15_r0_body.P43.lo RData.bigHi && Nat.ble RData.bigHi PRE_first_tail_x15_r0_body.P43.E) = true
kernel_rfl PRE_first_tail_x15_r0_body.ccnt43 : (Nat.ble PRE_first_tail_x15_r0_body.cx0_43.mlx.next PRE_first_tail_x15_r0_body.cx1_43.mlx.next && Nat.ble PRE_first_tail_x15_r0_body.cx0_43.mlx.nnext PRE_first_tail_x15_r0_body.cx1_43.mlx.nnext) = true
kernel_rfl PRE_first_tail_x15_r0_body.cnband43 : (Nat.blt 0 PRE_first_tail_x15_r0_body.P43.NL && Nat.ble PRE_first_tail_x15_r0_body.P43.NL PRE_first_tail_x15_r0_body.P43.N0 && Nat.ble PRE_first_tail_x15_r0_body.P43.N0 PRE_first_tail_x15_r0_body.cx0_43.mlx.nnext) = true
kernel_rfl PRE_first_tail_x15_r0_body.chbelow43 : PRE_first_tail_x15_r0_body.kd43.checkHndBelow = true
kernel_rfl PRE_first_tail_x15_r0_body.chren43 : checkRenG PRE_first_tail_x15_r0_body.kd43.hnd PRE_first_tail_x15_r0_body.khinv43 (phB PRE_first_tail_x15_r0_body.cx0_43.mlx) = true
kernel_rfl PRE_first_tail_x15_r0_body.cband43 : PRE_first_tail_x15_r0_body.kd43.checkBand PRE_first_tail_x15_r0_body.P43.lo = true
kernel_rfl PRE_first_tail_x15_r0_body.cnh1pos43 : Nat.blt 0 PRE_first_tail_x15_r0_body.kd43.nh1 = true
kernel_rfl PRE_first_tail_x15_r0_body.cnren43 : checkRenG PRE_first_tail_x15_r0_body.kd43.node PRE_first_tail_x15_r0_body.kninv43 (pnB PRE_first_tail_x15_r0_body.cx0_43.mlx) = true
kernel_rfl PRE_first_tail_x15_r0_body.cnlow43 : (PTrie.keysA PRE_first_tail_x15_r0_body.kd43.node).all (fun j => Nat.ble PRE_first_tail_x15_r0_body.P43.NL j && Nat.blt (PRE_first_tail_x15_r0_body.kd43.nodeF j) PRE_first_tail_x15_r0_body.cx1_43.mlx.nnext) = true
kernel_rfl PRE_first_tail_x15_r0_body.cabs0a43 : PRE_first_tail_x15_r0_body.cx0_43.mlx.arrs.get 0 = none
kernel_rfl PRE_first_tail_x15_r0_body.cabs0b43 : PRE_first_tail_x15_r0_body.cx0_43.mlx.objs.get 0 = none
kernel_rfl PRE_first_tail_x15_r0_body.ctok143 : PRE_first_tail_x15_r0_body.cx1_43.mlx.tokens = []
kernel_rfl PRE_first_tail_x15_r0_body.cpend43 : PRE_first_tail_x15_r0_body.cx1_43.mlx.pending = PRE_first_tail_x15_r0_body.cx0_43.mlx.pending.map PRE_first_tail_x15_r0_body.kappa43.pend
kernel_rfl PRE_first_tail_x15_r0_body.cerrh43 : PRE_first_tail_x15_r0_body.cx1_43.mlx.errh = PRE_first_tail_x15_r0_body.cx0_43.mlx.errh.map PRE_first_tail_x15_r0_body.kappa43.arg
kernel_rfl PRE_first_tail_x15_r0_body.cfiles43 : PRE_first_tail_x15_r0_body.cx1_43.mlx.files = PRE_first_tail_x15_r0_body.cx0_43.mlx.files
kernel_rfl PRE_first_tail_x15_r0_body.carch43 : PRE_first_tail_x15_r0_body.cx1_43.mlx.arch = PRE_first_tail_x15_r0_body.cx0_43.mlx.arch
kernel_rfl PRE_first_tail_x15_r0_body.csizes43 : PRE_first_tail_x15_r0_body.cx1_43.mlx.deviceSizes = PRE_first_tail_x15_r0_body.cx0_43.mlx.deviceSizes
kernel_rfl PRE_first_tail_x15_r0_body.cwired43 : PRE_first_tail_x15_r0_body.cx1_43.mlx.wired = PRE_first_tail_x15_r0_body.cx0_43.mlx.wired
kernel_rfl PRE_first_tail_x15_r0_body.chost43 : PRE_first_tail_x15_r0_body.cx1_43.host = PRE_first_tail_x15_r0_body.cx0_43.host
-- the compaction map's addresses are `PRE_first_tail_x15_r0_body.kd43`'s
kernel_rfl PRE_first_tail_x15_r0_body.ckn043 : PRE_first_tail_x15_r0_body.kd43.n0 = 2708715
kernel_rfl PRE_first_tail_x15_r0_body.ckn143 : PRE_first_tail_x15_r0_body.kd43.n1 = 2708717
kernel_rfl PRE_first_tail_x15_r0_body.ckheap43 : (PTrie.keysA PRE_first_tail_x15_r0_body.kd43.heap).all (fun x => Nat.ble 2708715 x) = true
kernel_rfl PRE_first_tail_x15_r0_body.ckpl43 : (List.range 0).all (fun j => decide (PRE_first_tail_x15_r0_body.kd43.heap.get (2708715 + j) = nth? PRE_first_tail_x15_r0_body.pl43 j)) = true
-- the map fixes the call's names (`Conv.fixOld_compact`), the call's counters
kernel_rfl PRE_first_tail_x15_r0_body.fja43 : Nat.ble 2708715 2708715 = true
kernel_rfl PRE_first_tail_x15_r0_body.fn43 : Nat.ble 1919 1919 = true
kernel_rfl PRE_first_tail_x15_r0_body.fjaD43 : Nat.ble 2708715 PRE_first_tail_x15_r0_body.kd43.n0 = true
kernel_rfl PRE_first_tail_x15_r0_body.fxn43 : Nat.ble 19054 PRE_first_tail_x15_r0_body.kd43.nh0 = true
kernel_rfl PRE_first_tail_x15_r0_body.fnn43 : Nat.ble 16155 PRE_first_tail_x15_r0_body.kd43.nn0 = true
kernel_rfl PRE_first_tail_x15_r0_body.fxb43 : Nat.ble 19054 RData.bigHi = true
kernel_rfl PRE_first_tail_x15_r0_body.fheap43 : (PTrie.keysA PRE_first_tail_x15_r0_body.kd43.heap).all (Nat.ble (⟨19054, 16155, 2708715, 1919⟩ : Conv.Cnt).ja) = true
kernel_rfl PRE_first_tail_x15_r0_body.fhnd43 : (PTrie.keysA PRE_first_tail_x15_r0_body.kd43.hnd).all (Nat.ble (⟨19054, 16155, 2708715, 1919⟩ : Conv.Cnt).xn) = true
kernel_rfl PRE_first_tail_x15_r0_body.fnode43 : (PTrie.keysA PRE_first_tail_x15_r0_body.kd43.node).all (Nat.ble (⟨19054, 16155, 2708715, 1919⟩ : Conv.Cnt).nn) = true
/-- The compaction map fixes the call's names. -/
theorem PRE_first_tail_x15_r0_body.cfix43 : Conv.FixOld (⟨19054, 16155, 2708715, 1919⟩ : Conv.Cnt) PRE_first_tail_x15_r0_body.kappa43 :=
  Conv.fixOld_compact (Nat.le_of_ble_eq_true PRE_first_tail_x15_r0_body.fja43) (Nat.le_of_ble_eq_true PRE_first_tail_x15_r0_body.fn43) (Nat.le_of_ble_eq_true PRE_first_tail_x15_r0_body.fjaD43) (Nat.le_of_ble_eq_true PRE_first_tail_x15_r0_body.fxn43) (Nat.le_of_ble_eq_true PRE_first_tail_x15_r0_body.fnn43) (Nat.le_of_ble_eq_true PRE_first_tail_x15_r0_body.fxb43) PRE_first_tail_x15_r0_body.fheap43 PRE_first_tail_x15_r0_body.fhnd43 PRE_first_tail_x15_r0_body.fnode43
kernel_rfl PRE_first_tail_x15_r0_body.fcxn43 : (⟨19054, 16155, 2708715, 1919⟩ : Conv.Cnt).xn = (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s427.ffi).mlx.next
kernel_rfl PRE_first_tail_x15_r0_body.fcnn43 : (⟨19054, 16155, 2708715, 1919⟩ : Conv.Cnt).nn = (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s427.ffi).mlx.nnext
kernel_rfl PRE_first_tail_x15_r0_body.fle043 : (Nat.ble (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s427.ffi).mlx.next PRE_first_tail_x15_r0_body.cx0_43.mlx.next && Nat.ble (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s427.ffi).mlx.nnext PRE_first_tail_x15_r0_body.cx0_43.mlx.nnext && Nat.ble (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s427.ffi).mlx.next RData.bigHi) = true
kernel_rfl PRE_first_tail_x15_r0_body.fnk43 : (PTrie.keysA PRE_first_tail_x15_r0_body.kd43.node).all (Nat.ble (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s427.ffi).mlx.nnext) = true
-- the merged state keeps the call's entries off the stage's footprint
kernel_rfl PRE_first_tail_x15_r0_body.f1A43 : PRE_first_tail_x15_r0_body.cx1_43.mlx.arrs = Stage.setAll (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s427.ffi).mlx.arrs (PRE_first_tail_x15_r0_body.cwS43.filterMap fun i => (PRE_first_tail_x15_r0_body.cx1_43.mlx.arrs.get i).map (i, ·))
kernel_rfl PRE_first_tail_x15_r0_body.f1O43 : PRE_first_tail_x15_r0_body.cx1_43.mlx.objs = Stage.setAll (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s427.ffi).mlx.objs (PRE_first_tail_x15_r0_body.cwS43.filterMap fun i => (PRE_first_tail_x15_r0_body.cx1_43.mlx.objs.get i).map (i, ·))
kernel_rfl PRE_first_tail_x15_r0_body.f1N43 : PRE_first_tail_x15_r0_body.cx1_43.mlx.nodes = Stage.setAll (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s427.ffi).mlx.nodes (PRE_first_tail_x15_r0_body.cnS43.filterMap fun i => (PRE_first_tail_x15_r0_body.cx1_43.mlx.nodes.get i).map (i, ·))
kernel_rfl PRE_first_tail_x15_r0_body.f1I43 : PRE_first_tail_x15_r0_body.cx1_43.mlx.items = Stage.setAll (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s427.ffi).mlx.items (PRE_first_tail_x15_r0_body.ciS43.filterMap fun i => (PRE_first_tail_x15_r0_body.cx1_43.mlx.items.get i).map (i, ·))
kernel_rfl PRE_first_tail_x15_r0_body.fbd43 : (PRE_first_tail_x15_r0_body.clo43 ++ PRE_first_tail_x15_r0_body.cln43 ++ PRE_first_tail_x15_r0_body.cli43 ++ PRE_first_tail_x15_r0_body.cwS43 ++ PRE_first_tail_x15_r0_body.cnS43 ++ PRE_first_tail_x15_r0_body.ciS43).all (fun i => Nat.blt (i / 4096) (4 ^ 31)) = true
kernel_rfl PRE_first_tail_x15_r0_body.fincW43 : PRE_first_tail_x15_r0_body.cwS43.all (fun h => !Nat.blt h (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s427.ffi).mlx.next || PRE_first_tail_x15_r0_body.clo43.contains h) = true
kernel_rfl PRE_first_tail_x15_r0_body.fincI43 : PRE_first_tail_x15_r0_body.ciS43.all (fun k => !Nat.blt k (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s427.ffi).mlx.nnext || PRE_first_tail_x15_r0_body.cli43.contains k) = true
kernel_rfl PRE_first_tail_x15_r0_body.fincN43 : PRE_first_tail_x15_r0_body.cnS43.all (Nat.ble (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s427.ffi).mlx.nnext) = true
kernel_rfl PRE_first_tail_x15_r0_body.flnF43 : PRE_first_tail_x15_r0_body.cln43.all (Nat.ble (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s427.ffi).mlx.nnext) = true
-- the checks over the changed lists
kernel_rfl PRE_first_tail_x15_r0_body.fh43 : PRE_first_tail_x15_r0_body.clo43.all (handleOK PRE_first_tail_x15_r0_body.kappa43 PRE_first_tail_x15_r0_body.P43.lo PRE_first_tail_x15_r0_body.cx0_43.mlx PRE_first_tail_x15_r0_body.cx1_43.mlx) = true
kernel_rfl PRE_first_tail_x15_r0_body.fo43 : PRE_first_tail_x15_r0_body.clo43.map (fun h => PRE_first_tail_x15_r0_body.cx1_43.mlx.objs.get (PRE_first_tail_x15_r0_body.kappa43.handle h)) = PRE_first_tail_x15_r0_body.clo43.map (fun h => (PRE_first_tail_x15_r0_body.cx0_43.mlx.objs.get h).map PRE_first_tail_x15_r0_body.kappa43.nobj)
kernel_rfl PRE_first_tail_x15_r0_body.fok43 : PRE_first_tail_x15_r0_body.clo43.all (objOK PRE_first_tail_x15_r0_body.kappa43 PRE_first_tail_x15_r0_body.P43.NL PRE_first_tail_x15_r0_body.cx0_43.mlx) = true
kernel_rfl PRE_first_tail_x15_r0_body.fnd43 : PRE_first_tail_x15_r0_body.cln43.all (nodeOKF PRE_first_tail_x15_r0_body.kappa43 PRE_first_tail_x15_r0_body.P43 PRE_first_tail_x15_r0_body.cx0_43.mlx PRE_first_tail_x15_r0_body.cx1_43.mlx) = true
kernel_rfl PRE_first_tail_x15_r0_body.fp43 : ((PRE_first_tail_x15_r0_body.cln43.filter (fullB PRE_first_tail_x15_r0_body.P43))).map (fun i => (PRE_first_tail_x15_r0_body.cx1_43.mlx.nodes.get (PRE_first_tail_x15_r0_body.kappa43.node i)).map Host.Mlx.Ffi.Node.prim) =
  ((PRE_first_tail_x15_r0_body.cln43.filter (fullB PRE_first_tail_x15_r0_body.P43))).map (fun i => (PRE_first_tail_x15_r0_body.cx0_43.mlx.nodes.get i).map fun nd => PRE_first_tail_x15_r0_body.kappa43.prim nd.prim)
kernel_rfl PRE_first_tail_x15_r0_body.fnordI43 : incrB PRE_first_tail_x15_r0_body.kd43.nodeF (List.range' 16155 0) = true
kernel_rfl PRE_first_tail_x15_r0_body.fnordK43 : (PTrie.keysA PRE_first_tail_x15_r0_body.kd43.node).all (fun k => Nat.ble 16155 k && Nat.blt k 16155) = true
kernel_rfl PRE_first_tail_x15_r0_body.fnordL43 : (PRE_first_tail_x15_r0_body.cln43.filter (Nat.ble PRE_first_tail_x15_r0_body.P43.N0)).all (fun i => Nat.ble i (PRE_first_tail_x15_r0_body.kd43.nodeF i) && (Nat.blt i 16155 || Nat.ble PRE_first_tail_x15_r0_body.kd43.nn0 i)) = true
theorem PRE_first_tail_x15_r0_body.fnord43 : (PRE_first_tail_x15_r0_body.cln43.filter (Nat.ble PRE_first_tail_x15_r0_body.P43.N0)).all (fun i => Nat.ble i (PRE_first_tail_x15_r0_body.kd43.nodeF i) &&
    (PTrie.keysA PRE_first_tail_x15_r0_body.kd43.node).all fun j => !Nat.blt j i || Nat.blt (PRE_first_tail_x15_r0_body.kd43.nodeF j) (PRE_first_tail_x15_r0_body.kd43.nodeF i)) = true :=
  cnord_of PRE_first_tail_x15_r0_body.cnlow43 PRE_first_tail_x15_r0_body.cnn143 PRE_first_tail_x15_r0_body.fnordI43 PRE_first_tail_x15_r0_body.fnordK43 PRE_first_tail_x15_r0_body.fnordL43
kernel_rfl PRE_first_tail_x15_r0_body.fi43 : PRE_first_tail_x15_r0_body.cli43.all (pnB PRE_first_tail_x15_r0_body.cx0_43.mlx) = true
kernel_rfl PRE_first_tail_x15_r0_body.fii43 : PRE_first_tail_x15_r0_body.cli43.all (fun k => decide (PRE_first_tail_x15_r0_body.cx1_43.mlx.items.get (PRE_first_tail_x15_r0_body.kappa43.node k) = (PRE_first_tail_x15_r0_body.cx0_43.mlx.items.get k).map PRE_first_tail_x15_r0_body.kappa43.nv)) = true
/-- **The compaction's footprint.** -/
theorem PRE_first_tail_x15_r0_body.cfoot43 (clean : Conv.NClean (⟨19054, 16155, 2708715, 1919⟩ : Conv.Cnt) (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s427.ffi).mlx) (hltC : ∀ h, PH (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s427.ffi).mlx h → h < (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s427.ffi).mlx.next) (nltC : ∀ i, PN (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s427.ffi).mlx i → i < (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s427.ffi).mlx.nnext) (itemsC : ∀ k v, (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s427.ffi).mlx.items.get k = some v → PN (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s427.ffi).mlx k) (tracedC : ∀ h o, (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s427.ffi).mlx.objs.get h = some o → ∀ i ∈ objTraces o, i < PRE_first_tail_x15_r0_body.P43.NL) (cl : SSt (· < 1919) PRE_first_tail_x15_r0_body.cx0_43.mlx) :
    Conv.MFoot PRE_first_tail_x15_r0_body.P43 1919 PRE_first_tail_x15_r0_body.kappa43 PRE_first_tail_x15_r0_body.kd43 PRE_first_tail_x15_r0_body.khinv43 PRE_first_tail_x15_r0_body.kninv43 (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s427.ffi).mlx PRE_first_tail_x15_r0_body.cx0_43.mlx PRE_first_tail_x15_r0_body.cx1_43.mlx (⟨19054, 16155, 2708715, 1919⟩ : Conv.Cnt) PRE_first_tail_x15_r0_body.clo43 PRE_first_tail_x15_r0_body.cln43 PRE_first_tail_x15_r0_body.cli43 PRE_first_tail_x15_r0_body.cwS43 PRE_first_tail_x15_r0_body.cnS43 PRE_first_tail_x15_r0_body.ciS43 :=
  ⟨rfl, rfl, rfl, PRE_first_tail_x15_r0_body.cnh043, PRE_first_tail_x15_r0_body.cnh143, PRE_first_tail_x15_r0_body.cnn043, PRE_first_tail_x15_r0_body.cnn143, PRE_first_tail_x15_r0_body.cplo43, PRE_first_tail_x15_r0_body.ccnt43, PRE_first_tail_x15_r0_body.cnband43, PRE_first_tail_x15_r0_body.chbelow43, PRE_first_tail_x15_r0_body.chren43, PRE_first_tail_x15_r0_body.cband43, PRE_first_tail_x15_r0_body.cnh1pos43, PRE_first_tail_x15_r0_body.cnren43, PRE_first_tail_x15_r0_body.cnlow43, PRE_first_tail_x15_r0_body.cabs0a43, PRE_first_tail_x15_r0_body.cabs0b43, PRE_first_tail_x15_r0_body.ctok143, PRE_first_tail_x15_r0_body.cpend43, PRE_first_tail_x15_r0_body.cerrh43, PRE_first_tail_x15_r0_body.cfiles43, PRE_first_tail_x15_r0_body.carch43, PRE_first_tail_x15_r0_body.csizes43, PRE_first_tail_x15_r0_body.cwired43, PRE_first_tail_x15_r0_body.cfix43, clean, PRE_first_tail_x15_r0_body.fcxn43, PRE_first_tail_x15_r0_body.fcnn43, hltC, nltC, itemsC, tracedC, cl, PRE_first_tail_x15_r0_body.fle043, PRE_first_tail_x15_r0_body.fnk43, PRE_first_tail_x15_r0_body.ckA43, PRE_first_tail_x15_r0_body.cobjsK43, PRE_first_tail_x15_r0_body.cnodesK43, PRE_first_tail_x15_r0_body.citemsK43, PRE_first_tail_x15_r0_body.f1A43, PRE_first_tail_x15_r0_body.f1O43, PRE_first_tail_x15_r0_body.f1N43, PRE_first_tail_x15_r0_body.f1I43, PRE_first_tail_x15_r0_body.fbd43, PRE_first_tail_x15_r0_body.fincW43, PRE_first_tail_x15_r0_body.fincI43, PRE_first_tail_x15_r0_body.fincN43, PRE_first_tail_x15_r0_body.flnF43, PRE_first_tail_x15_r0_body.fh43, PRE_first_tail_x15_r0_body.fo43, PRE_first_tail_x15_r0_body.fok43, PRE_first_tail_x15_r0_body.fnd43, PRE_first_tail_x15_r0_body.fp43, PRE_first_tail_x15_r0_body.fnord43, PRE_first_tail_x15_r0_body.fi43, PRE_first_tail_x15_r0_body.fii43⟩
theorem PRE_first_tail_x15_r0_body.cnshift43 (clean : Conv.NClean (⟨19054, 16155, 2708715, 1919⟩ : Conv.Cnt) (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s427.ffi).mlx) (hltC : ∀ h, PH (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s427.ffi).mlx h → h < (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s427.ffi).mlx.next) (nltC : ∀ i, PN (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s427.ffi).mlx i → i < (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s427.ffi).mlx.nnext) (itemsC : ∀ k v, (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s427.ffi).mlx.items.get k = some v → PN (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s427.ffi).mlx k) (tracedC : ∀ h o, (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s427.ffi).mlx.objs.get h = some o → ∀ i ∈ objTraces o, i < PRE_first_tail_x15_r0_body.P43.NL) (cl : SSt (· < 1919) PRE_first_tail_x15_r0_body.cx0_43.mlx) : NShift PRE_first_tail_x15_r0_body.P43 1919 PRE_first_tail_x15_r0_body.kappa43 PRE_first_tail_x15_r0_body.cx0_43 PRE_first_tail_x15_r0_body.cx1_43 :=
  Conv.nshift_of_foot (PRE_first_tail_x15_r0_body.cfoot43 clean hltC nltC itemsC tracedC cl) PRE_first_tail_x15_r0_body.chost43 (compact_a_eq PRE_first_tail_x15_r0_body.ckn043 PRE_first_tail_x15_r0_body.ckn143 PRE_first_tail_x15_r0_body.ckheap43 PRE_first_tail_x15_r0_body.ckpl43)

-- the observers: the layers' states at the call, the canonical and the merged state, their footprints and checks
noncomputable def PRE_first_tail_x15_r0_body.fxC_43 : PTrie Unit := (Host.Ts.Sim.Full.freedOf PRE_first_tail_x15_r0_body.s427.ffi).getD PTrie.nil
noncomputable def PRE_first_tail_x15_r0_body.krC_43 : Host.Load.Layers.KRec := (Host.Ts.Sim.Full.krecOf PRE_first_tail_x15_r0_body.s427.ffi).getD Host.Load.Layers.KRec.empty
kernel_rfl PRE_first_tail_x15_r0_body.ofxC_43 : (Host.Ts.Sim.Full.freedOf PRE_first_tail_x15_r0_body.s427.ffi) = some PRE_first_tail_x15_r0_body.fxC_43
kernel_rfl PRE_first_tail_x15_r0_body.okrC_43 : (Host.Ts.Sim.Full.krecOf PRE_first_tail_x15_r0_body.s427.ffi) = some PRE_first_tail_x15_r0_body.krC_43
noncomputable def PRE_first_tail_x15_r0_body.fx0_43 : PTrie Unit := (Host.Ts.Sim.Full.freedOf PRE_first_tail_x15_r0_body.s429.ffi).getD PTrie.nil
noncomputable def PRE_first_tail_x15_r0_body.kr0_43 : Host.Load.Layers.KRec := (Host.Ts.Sim.Full.krecOf PRE_first_tail_x15_r0_body.s429.ffi).getD Host.Load.Layers.KRec.empty
kernel_rfl PRE_first_tail_x15_r0_body.ofx0_43 : (Host.Ts.Sim.Full.freedOf PRE_first_tail_x15_r0_body.s429.ffi) = some PRE_first_tail_x15_r0_body.fx0_43
kernel_rfl PRE_first_tail_x15_r0_body.okr0_43 : (Host.Ts.Sim.Full.krecOf PRE_first_tail_x15_r0_body.s429.ffi) = some PRE_first_tail_x15_r0_body.kr0_43
noncomputable def PRE_first_tail_x15_r0_body.fx1_43 : PTrie Unit := (Host.Ts.Sim.Full.freedOf PRE_first_tail_x15_r0_body.s428.ffi).getD PTrie.nil
noncomputable def PRE_first_tail_x15_r0_body.kr1_43 : Host.Load.Layers.KRec := (Host.Ts.Sim.Full.krecOf PRE_first_tail_x15_r0_body.s428.ffi).getD Host.Load.Layers.KRec.empty
kernel_rfl PRE_first_tail_x15_r0_body.ofx1_43 : (Host.Ts.Sim.Full.freedOf PRE_first_tail_x15_r0_body.s428.ffi) = some PRE_first_tail_x15_r0_body.fx1_43
kernel_rfl PRE_first_tail_x15_r0_body.okr1_43 : (Host.Ts.Sim.Full.krecOf PRE_first_tail_x15_r0_body.s428.ffi) = some PRE_first_tail_x15_r0_body.kr1_43
kernel_rfl PRE_first_tail_x15_r0_body.ff043 : PRE_first_tail_x15_r0_body.fx0_43 = Stage.setAll PRE_first_tail_x15_r0_body.fxC_43 (PRE_first_tail_x15_r0_body.clo43.filterMap fun i => (PRE_first_tail_x15_r0_body.fx0_43.get i).map (i, ·))
kernel_rfl PRE_first_tail_x15_r0_body.ff143 : PRE_first_tail_x15_r0_body.fx1_43 = Stage.setAll PRE_first_tail_x15_r0_body.fxC_43 (PRE_first_tail_x15_r0_body.cwS43.filterMap fun i => (PRE_first_tail_x15_r0_body.fx1_43.get i).map (i, ·))
kernel_rfl PRE_first_tail_x15_r0_body.ffck43 : freedLB PRE_first_tail_x15_r0_body.kappa43 PRE_first_tail_x15_r0_body.cx0_43.mlx PRE_first_tail_x15_r0_body.fx0_43 PRE_first_tail_x15_r0_body.fx1_43 PRE_first_tail_x15_r0_body.clo43 = true
kernel_rfl PRE_first_tail_x15_r0_body.fkf043 : PRE_first_tail_x15_r0_body.kr0_43.flags = Stage.setAll PRE_first_tail_x15_r0_body.krC_43.flags (PRE_first_tail_x15_r0_body.clo43.filterMap fun i => (PRE_first_tail_x15_r0_body.kr0_43.flags.get i).map (i, ·))
kernel_rfl PRE_first_tail_x15_r0_body.fkt043 : PRE_first_tail_x15_r0_body.kr0_43.targs = Stage.setAll PRE_first_tail_x15_r0_body.krC_43.targs (PRE_first_tail_x15_r0_body.clo43.filterMap fun i => (PRE_first_tail_x15_r0_body.kr0_43.targs.get i).map (i, ·))
kernel_rfl PRE_first_tail_x15_r0_body.fkf143 : PRE_first_tail_x15_r0_body.kr1_43.flags = Stage.setAll PRE_first_tail_x15_r0_body.krC_43.flags (PRE_first_tail_x15_r0_body.cwS43.filterMap fun i => (PRE_first_tail_x15_r0_body.kr1_43.flags.get i).map (i, ·))
kernel_rfl PRE_first_tail_x15_r0_body.fkt143 : PRE_first_tail_x15_r0_body.kr1_43.targs = Stage.setAll PRE_first_tail_x15_r0_body.krC_43.targs (PRE_first_tail_x15_r0_body.cwS43.filterMap fun i => (PRE_first_tail_x15_r0_body.kr1_43.targs.get i).map (i, ·))
kernel_rfl PRE_first_tail_x15_r0_body.fkck43 : krecLB PRE_first_tail_x15_r0_body.kappa43 1919 PRE_first_tail_x15_r0_body.cx0_43.mlx PRE_first_tail_x15_r0_body.kr0_43 PRE_first_tail_x15_r0_body.kr1_43 PRE_first_tail_x15_r0_body.clo43 = true
kernel_rfl PRE_first_tail_x15_r0_body.fkn43 : Nat.ble 1919 1919 = true
-- the bridge and the pending traces' regions
kernel_rfl PRE_first_tail_x15_r0_body.cbridge43 : Host.Ts.Sim.Full.bridgeOf PRE_first_tail_x15_r0_body.s428.ffi = Host.Ts.Sim.Full.bridgeOf PRE_first_tail_x15_r0_body.s429.ffi
kernel_rfl PRE_first_tail_x15_r0_body.cpendR43 : pendRegB PRE_first_tail_x15_r0_body.kappa43 (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s429.ffi).mlx = true
kernel_rfl PRE_first_tail_x15_r0_body.cpendLe43 : Nat.ble (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s429.ffi).mlx.next (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s428.ffi).mlx.next = true
/-- **The compaction's native shift**, given the call's bookkeeping, its relation's facts (the model's and the
observers') and the canonical closedness. -/
theorem PRE_first_tail_x15_r0_body.cshift43 (clean : Conv.NClean (⟨19054, 16155, 2708715, 1919⟩ : Conv.Cnt) (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s427.ffi).mlx) (hltC : ∀ h, PH (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s427.ffi).mlx h → h < (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s427.ffi).mlx.next) (nltC : ∀ i, PN (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s427.ffi).mlx i → i < (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s427.ffi).mlx.nnext) (itemsC : ∀ k v, (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s427.ffi).mlx.items.get k = some v → PN (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s427.ffi).mlx k) (tracedC : ∀ h o, (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s427.ffi).mlx.objs.get h = some o → ∀ i ∈ objTraces o, i < PRE_first_tail_x15_r0_body.P43.NL) (cl : SSt (· < 1919) PRE_first_tail_x15_r0_body.cx0_43.mlx)
    (hobjC : ∀ h, PRE_first_tail_x15_r0_body.fxC_43.get h = some () → ((Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s427.ffi).mlx.objs.get h).isSome = true)
    (hfC : ∀ h, (PRE_first_tail_x15_r0_body.krC_43.flags.get h).isSome = true → ((Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s427.ffi).mlx.objs.get h).isSome = true)
    (htC : ∀ h, (PRE_first_tail_x15_r0_body.krC_43.targs.get h).isSome = true → ((Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s427.ffi).mlx.objs.get h).isSome = true)
    (hclC : ∀ h l, PRE_first_tail_x15_r0_body.krC_43.targs.get h = some l → Host.Ts.Sim.Full.STargs (· < (⟨19054, 16155, 2708715, 1919⟩ : Conv.Cnt).n) l) :
    Conv.FullShiftQ PRE_first_tail_x15_r0_body.P43 1919 PRE_first_tail_x15_r0_body.kappa43 PRE_first_tail_x15_r0_body.s429.ffi PRE_first_tail_x15_r0_body.s428.ffi :=
  ⟨PRE_first_tail_x15_r0_body.cnshift43 clean hltC nltC itemsC tracedC cl, PRE_first_tail_x15_r0_body.cqueue43, fun t ht => bSN_sound (List.all_eq_true.mp PRE_first_tail_x15_r0_body.ctokSupp43 t ht),
    PRE_first_tail_x15_r0_body.cbridge43,
    liveShift_foot (x0' := Host.Ts.Sim.Full.mlxOf PRE_first_tail_x15_r0_body.s429.ffi) (x1' := Host.Ts.Sim.Full.mlxOf PRE_first_tail_x15_r0_body.s428.ffi) (PRE_first_tail_x15_r0_body.cfoot43 clean hltC nltC itemsC tracedC cl) rfl PRE_first_tail_x15_r0_body.ofx0_43 PRE_first_tail_x15_r0_body.ofx1_43 hobjC PRE_first_tail_x15_r0_body.ff043 PRE_first_tail_x15_r0_body.ff143 PRE_first_tail_x15_r0_body.ffck43,
    kernShift_foot (x0' := Host.Ts.Sim.Full.mlxOf PRE_first_tail_x15_r0_body.s429.ffi) (x1' := Host.Ts.Sim.Full.mlxOf PRE_first_tail_x15_r0_body.s428.ffi) (PRE_first_tail_x15_r0_body.cfoot43 clean hltC nltC itemsC tracedC cl) rfl PRE_first_tail_x15_r0_body.okr0_43 PRE_first_tail_x15_r0_body.okr1_43 (Nat.le_of_ble_eq_true PRE_first_tail_x15_r0_body.fkn43) hfC htC hclC
      PRE_first_tail_x15_r0_body.fkf043 PRE_first_tail_x15_r0_body.fkt043 PRE_first_tail_x15_r0_body.fkf143 PRE_first_tail_x15_r0_body.fkt143 PRE_first_tail_x15_r0_body.fkck43,
    pendReg_of rfl PRE_first_tail_x15_r0_body.cnh043 PRE_first_tail_x15_r0_body.cnh143 (Nat.le_of_ble_eq_true PRE_first_tail_x15_r0_body.cpendLe43) PRE_first_tail_x15_r0_body.cpendR43⟩

end Host.Load.Run.Tpl
end

section -- st43/H0
set_option Elab.async false
namespace Host.Load.Run.Tpl
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
host_stream_state PRE_first_tail_x15_r0_body.st43 0
host_stream_state PRE_first_tail_x15_r0_body.st43 1
host_stream_state PRE_first_tail_x15_r0_body.st43 2
end Host.Load.Run.Tpl
end

section -- Site43
set_option Elab.async false
namespace Host.Load.Run.Tpl
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
open Host.Ts Host.Ts.Sim Host.Ts.Sim.Template

/-! Call site 43 of chain `PRE_first_tail_x15_r0_body`: `rowBlocks__g43__g44` (`rowBlocks`), the call state `PRE_first_tail_x15_r0_body.s427`, the merged state `PRE_first_tail_x15_r0_body.s428`,
the site template `PRE_first_tail_x15_r0_body.st43` (σ = `Map.id`, θ the identity at its own site), the canonical state `PRE_first_tail_x15_r0_body.s429`: the merge.
The footprint's facts are in `SiteF43`, the compaction's in `SiteC43`, `SiteK43`, `SiteNa43`, `SiteNb43`. -/

kernel_rfl PRE_first_tail_x15_r0_body.iso43 : PRE_first_tail_x15_r0_body.st43.s0 = { PRE_first_tail_x15_r0_body.s427 with stack := [] }
/-- The caller's frames at the call. -/
noncomputable def PRE_first_tail_x15_r0_body.rs43 : List Frame := PRE_first_tail_x15_r0_body.s427.stack
kernel_rfl PRE_first_tail_x15_r0_body.n0_43 : PRE_first_tail_x15_r0_body.S427.tab.length = 1919
kernel_rfl PRE_first_tail_x15_r0_body.tab0_43 : PRE_first_tail_x15_r0_body.st43.S0.tab = PRE_first_tail_x15_r0_body.S427.tab

/-- The fresh variables of the stage's results. -/
def PRE_first_tail_x15_r0_body.ws43 : List Nat := [1754, 1755]
kernel_rfl PRE_first_tail_x15_r0_body.fresh43 : (PRE_first_tail_x15_r0_body.S427.tab.all fun e => PRE_first_tail_x15_r0_body.ws43.all fun v => e.noVar v) &&
    (PRE_first_tail_x15_r0_body.S427.oracle.all fun q => PRE_first_tail_x15_r0_body.ws43.all fun v => q.noVar v) = true
kernel_rfl PRE_first_tail_x15_r0_body.mergeTab43 : PRE_first_tail_x15_r0_body.S428.tab = PRE_first_tail_x15_r0_body.S427.tab ++ Conv.resTab PRE_first_tail_x15_r0_body.ws43
kernel_rfl PRE_first_tail_x15_r0_body.mergeLen43 : PRE_first_tail_x15_r0_body.st43.S2.tab.length - PRE_first_tail_x15_r0_body.st43.S0.tab.length = 2

-- The merged state: the instance's return state with the caller's frames (`PRE_first_tail_x15_r0_body.merged43`, `merged_relB`).
kernel_rfl PRE_first_tail_x15_r0_body.mheap43 : PRE_first_tail_x15_r0_body.s428.heap = PRE_first_tail_x15_r0_body.st43.s2.heap
kernel_rfl PRE_first_tail_x15_r0_body.mnext43 : PRE_first_tail_x15_r0_body.s428.next = PRE_first_tail_x15_r0_body.st43.s2.next
kernel_rfl PRE_first_tail_x15_r0_body.mctl43 : PRE_first_tail_x15_r0_body.s428.ctl = PRE_first_tail_x15_r0_body.st43.s2.ctl
kernel_rfl PRE_first_tail_x15_r0_body.mstack43 : PRE_first_tail_x15_r0_body.s428.stack = PRE_first_tail_x15_r0_body.st43.s2.stack ++ PRE_first_tail_x15_r0_body.s427.stack
kernel_rfl PRE_first_tail_x15_r0_body.mjobs43 : PRE_first_tail_x15_r0_body.s428.jobs = PRE_first_tail_x15_r0_body.st43.s2.jobs
kernel_rfl PRE_first_tail_x15_r0_body.mffi43 : PRE_first_tail_x15_r0_body.s428.ffi = PRE_first_tail_x15_r0_body.st43.s2.ffi
kernel_rfl PRE_first_tail_x15_r0_body.mtrace43 : PRE_first_tail_x15_r0_body.s428.trace = PRE_first_tail_x15_r0_body.st43.s2.trace
kernel_rfl PRE_first_tail_x15_r0_body.mstores43 : PRE_first_tail_x15_r0_body.s428.stores = PRE_first_tail_x15_r0_body.st43.s2.stores

end Host.Load.Run.Tpl
end

section -- SiteD43
set_option Elab.async false
namespace Host.Load.Run.Tpl
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
open Host.Ts Host.Ts.Sim Host.Ts.Sim.Template

/-! The canonical results at call site 43 of chain `PRE_first_tail_x15_r0_body`: their values in the instance's end table, the references past
the call's table, the canonical variables apart from the stage's. -/

kernel_rfl PRE_first_tail_x15_r0_body.cderived43 : PRE_first_tail_x15_r0_body.nr43.map (fun r => nth? PRE_first_tail_x15_r0_body.st43.S2.tab r) =
  []
kernel_rfl PRE_first_tail_x15_r0_body.cnrLo43 : PRE_first_tail_x15_r0_body.nr43.all (Nat.ble 1919) = true
kernel_rfl PRE_first_tail_x15_r0_body.cwsDisj43 : PRE_first_tail_x15_r0_body.cws43.all (fun c => !PRE_first_tail_x15_r0_body.ws43.contains c) = true
/-- The compaction's substitution: the canonical variables to their merged values, the stage's other fresh variables
to `0` (`Conv.compactθZ`). -/
noncomputable def PRE_first_tail_x15_r0_body.cthetaZ43 : Nat → SymE := Conv.compactθZ PRE_first_tail_x15_r0_body.cws43 PRE_first_tail_x15_r0_body.crs43 PRE_first_tail_x15_r0_body.ws43

end Host.Load.Run.Tpl
end

section -- st43/Foot
set_option Elab.async false
namespace Host.Load.Run.Tpl
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
open Host.Ts Host.Ts.Sim Host.Ts.Sim.Stage Host.Ts.Sim.Template

/-! The footprint of stage `PRE_first_tail_x15_r0_body.st43`'s site template (`Conv.StageFoot`, `Conv.NFoot`): every entry of the return
state other than the written and fresh ones is the start's (kernel evaluation of the equalities). -/

/-- The written heap ranges below the start's counter. -/
def PRE_first_tail_x15_r0_body.st43.wrR : List (Nat × Nat) := []
/-- The written and fresh entries of the return state. -/
noncomputable def PRE_first_tail_x15_r0_body.st43.wrE : List (Nat × Host.Ts.HObj) :=
  rangesOf PRE_first_tail_x15_r0_body.st43.s2.heap PRE_first_tail_x15_r0_body.st43.wrR ++ freshOf PRE_first_tail_x15_r0_body.st43.s2.heap PRE_first_tail_x15_r0_body.st43.s0.next PRE_first_tail_x15_r0_body.st43.s2.next
noncomputable def PRE_first_tail_x15_r0_body.st43.wr : List Nat := PRE_first_tail_x15_r0_body.st43.wrE.map (·.1)

kernel_rfl PRE_first_tail_x15_r0_body.st43.heapFoot : PRE_first_tail_x15_r0_body.st43.s2.heap = setAll PRE_first_tail_x15_r0_body.st43.s0.heap PRE_first_tail_x15_r0_body.st43.wrE
kernel_rfl PRE_first_tail_x15_r0_body.st43.grows_check : Nat.ble PRE_first_tail_x15_r0_body.st43.s0.next PRE_first_tail_x15_r0_body.st43.s2.next = true
theorem PRE_first_tail_x15_r0_body.st43.grows : PRE_first_tail_x15_r0_body.st43.s0.next ≤ PRE_first_tail_x15_r0_body.st43.s2.next := Nat.le_of_ble_eq_true PRE_first_tail_x15_r0_body.st43.grows_check

/-- The written and fresh handles; the written readback items of old nodes. -/
def PRE_first_tail_x15_r0_body.st43.wh : List Nat := []
def PRE_first_tail_x15_r0_body.st43.wi : List Nat := []

kernel_rfl PRE_first_tail_x15_r0_body.st43.arrsFoot : (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.st43.s2.ffi).mlx.arrs = setAll (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.st43.s0.ffi).mlx.arrs (PRE_first_tail_x15_r0_body.st43.wh.filterMap fun h => ((Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.st43.s2.ffi).mlx.arrs.get h).map (h, ·))
kernel_rfl PRE_first_tail_x15_r0_body.st43.objsFoot : (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.st43.s2.ffi).mlx.objs = setAll (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.st43.s0.ffi).mlx.objs (PRE_first_tail_x15_r0_body.st43.wh.filterMap fun h => ((Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.st43.s2.ffi).mlx.objs.get h).map (h, ·))
kernel_rfl PRE_first_tail_x15_r0_body.st43.nodesFoot : (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.st43.s2.ffi).mlx.nodes = setAll (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.st43.s0.ffi).mlx.nodes (freshOf (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.st43.s2.ffi).mlx.nodes (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.st43.s0.ffi).mlx.nnext (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.st43.s2.ffi).mlx.nnext)
kernel_rfl PRE_first_tail_x15_r0_body.st43.itemsFoot : (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.st43.s2.ffi).mlx.items = setAll (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.st43.s0.ffi).mlx.items ((PRE_first_tail_x15_r0_body.st43.wi.filterMap fun i => ((Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.st43.s2.ffi).mlx.items.get i).map (i, ·)) ++
    freshOf (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.st43.s2.ffi).mlx.items (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.st43.s0.ffi).mlx.nnext (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.st43.s2.ffi).mlx.nnext)
kernel_rfl PRE_first_tail_x15_r0_body.st43.counters : (Nat.ble (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.st43.s0.ffi).mlx.next (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.st43.s2.ffi).mlx.next && Nat.ble (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.st43.s0.ffi).mlx.nnext (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.st43.s2.ffi).mlx.nnext) = true

end Host.Load.Run.Tpl
end

section -- SiteF43
set_option Elab.async false
namespace Host.Load.Run.Tpl
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
open Host.Ts Host.Ts.Sim Host.Ts.Sim.Template

/-! Call site 43 of chain `PRE_first_tail_x15_r0_body`: `Conv.site_merge`'s footprint facts. -/

kernel_rfl PRE_first_tail_x15_r0_body.wrNodupB43 : nodupT PRE_first_tail_x15_r0_body.st43.wr PTrie.nil = true
theorem PRE_first_tail_x15_r0_body.wrNodup43 : PRE_first_tail_x15_r0_body.st43.wr.Nodup := (nodupT_sound PRE_first_tail_x15_r0_body.wrNodupB43).2
kernel_rfl PRE_first_tail_x15_r0_body.wrBoundB43 : PRE_first_tail_x15_r0_body.st43.wr.all (fun b => Nat.blt (b / 4096) (4 ^ 31)) = true
theorem PRE_first_tail_x15_r0_body.wrBound43 : ∀ b ∈ PRE_first_tail_x15_r0_body.st43.wr, b / 4096 < 4 ^ 31 := fun b hb => Nat.blt_eq.mp (List.all_eq_true.mp PRE_first_tail_x15_r0_body.wrBoundB43 b hb)
noncomputable def PRE_first_tail_x15_r0_body.trFr43 := PRE_first_tail_x15_r0_body.st43.s2.trace.take 0
kernel_rfl PRE_first_tail_x15_r0_body.traceEq43 : PRE_first_tail_x15_r0_body.st43.s2.trace = PRE_first_tail_x15_r0_body.trFr43 ++ PRE_first_tail_x15_r0_body.st43.s0.trace
theorem PRE_first_tail_x15_r0_body.trace43 : ∃ fr, PRE_first_tail_x15_r0_body.st43.s2.trace = fr ++ PRE_first_tail_x15_r0_body.st43.s0.trace := ⟨_, PRE_first_tail_x15_r0_body.traceEq43⟩

-- the caller's wide frames at the instance's start (`Conv.isolateW`'s `W0` under `Map.id`) and their `WFix`
def PRE_first_tail_x15_r0_body.wide43 : List (Nat × WFrame) := [(4910, .memo [])]
kernel_rfl PRE_first_tail_x15_r0_body.wfixB43 : (PRE_first_tail_x15_r0_body.wide43.all fun p => wfixB Map.id (presentB PRE_first_tail_x15_r0_body.st43.s0) p.2) = true
theorem PRE_first_tail_x15_r0_body.wfix43 : ∀ p ∈ PRE_first_tail_x15_r0_body.wide43, WFix Map.id (Present PRE_first_tail_x15_r0_body.st43.s0) p.2 :=
  fun p hp => wfix_of (List.all_eq_true.mp PRE_first_tail_x15_r0_body.wfixB43 p hp)

end Host.Load.Run.Tpl
end

section -- SiteL43
set_option Elab.async false
namespace Host.Load.Run.Tpl
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
open Host.Ts Host.Ts.Sim Host.Ts.Sim.Template

/-! The call link's facts at call site 43 of chain `PRE_first_tail_x15_r0_body`: the instance's start server, its footprint (`Conv.StageFoot`), the
merged state `PRE_first_tail_x15_r0_body.s428`'s framed arrays as the chain start's extended (`arrExt_of`, `numRefs_of`). -/

kernel_rfl PRE_first_tail_x15_r0_body.srvO43 : PRE_first_tail_x15_r0_body.st43.S0.oracle = PRE_first_tail_x15_r0_body.st43.OR
kernel_rfl PRE_first_tail_x15_r0_body.wr0B43 : PRE_first_tail_x15_r0_body.st43.wr.all (fun b => !Nat.blt b PRE_first_tail_x15_r0_body.st43.s0.next || (PRE_first_tail_x15_r0_body.st43.s0.heap.get b).isSome) = true
theorem PRE_first_tail_x15_r0_body.stFoot43 : Conv.StageFoot PRE_first_tail_x15_r0_body.st43.wr PRE_first_tail_x15_r0_body.st43.s0 PRE_first_tail_x15_r0_body.st43.s2 :=
  stageFoot_of PRE_first_tail_x15_r0_body.st43.heapFoot PRE_first_tail_x15_r0_body.wrNodup43 PRE_first_tail_x15_r0_body.wrBound43 PRE_first_tail_x15_r0_body.wr0B43 PRE_first_tail_x15_r0_body.st43.grows

/-- **The relation at the merged state** from the relation at the merge (`Conv.site_merge`'s; `merged_relB`). -/
theorem PRE_first_tail_x15_r0_body.merged43 {FR : Map → Nat → PRE_first_tail_x15_r0_body.st43.F.S → PRE_first_tail_x15_r0_body.st43.F.S → Prop} {W : Nat → Option WFrame} {stk : List Frame} {M : Map}
    {ν : Nat → F64} {K : Host.Ts.Sim.Ctx} {S : SSrv} {t : St PRE_first_tail_x15_r0_body.st43.F.S} {C : CSrv} {n0 : Nat}
    (h : RelB PRE_first_tail_x15_r0_body.st43.F FR W stk M ν K (Conv.mergeSt Map.id (Map.id.res n0 n0) PRE_first_tail_x15_r0_body.rs43 PRE_first_tail_x15_r0_body.st43.wr PRE_first_tail_x15_r0_body.s427 PRE_first_tail_x15_r0_body.st43.s2 PRE_first_tail_x15_r0_body.st43.s0
      PRE_first_tail_x15_r0_body.st43.s2.ffi) S t C) : RelB PRE_first_tail_x15_r0_body.st43.F FR W stk M ν K PRE_first_tail_x15_r0_body.s428 S t C :=
  merged_relB PRE_first_tail_x15_r0_body.iso43 PRE_first_tail_x15_r0_body.stFoot43 PRE_first_tail_x15_r0_body.wrNodup43 PRE_first_tail_x15_r0_body.wrBound43 PRE_first_tail_x15_r0_body.trace43 PRE_first_tail_x15_r0_body.mheap43
    PRE_first_tail_x15_r0_body.mnext43 PRE_first_tail_x15_r0_body.mctl43 PRE_first_tail_x15_r0_body.mstack43 PRE_first_tail_x15_r0_body.mjobs43 PRE_first_tail_x15_r0_body.mffi43 PRE_first_tail_x15_r0_body.mtrace43 PRE_first_tail_x15_r0_body.mstores43 h

def PRE_first_tail_x15_r0_body.arrEl43_2665 : List Val := []
kernel_rfl PRE_first_tail_x15_r0_body.arrE43_2665 : arrOf PRE_first_tail_x15_r0_body.s428 2665 = arrOf PRE_first_tail_x15_r0_body.s0 2665 ++ PRE_first_tail_x15_r0_body.arrEl43_2665
kernel_rfl PRE_first_tail_x15_r0_body.arrA43_2665 : isArrB PRE_first_tail_x15_r0_body.s428 2665 = true
theorem PRE_first_tail_x15_r0_body.arr43_2665 : ∃ o, PRE_first_tail_x15_r0_body.s428.heap.get 2665 = some (.obj o) ∧ o.kind = .array (arrOf PRE_first_tail_x15_r0_body.s0 2665 ++ PRE_first_tail_x15_r0_body.arrEl43_2665) :=
  arrExt_of PRE_first_tail_x15_r0_body.arrE43_2665 PRE_first_tail_x15_r0_body.arrA43_2665
kernel_rfl PRE_first_tail_x15_r0_body.arrN43_2665 : numRefsB PRE_first_tail_x15_r0_body.S0.tab.length PRE_first_tail_x15_r0_body.arrEl43_2665 = true
theorem PRE_first_tail_x15_r0_body.arrR43_2665 : Prefill.NumRefs PRE_first_tail_x15_r0_body.S0.tab.length PRE_first_tail_x15_r0_body.arrEl43_2665 := numRefs_of PRE_first_tail_x15_r0_body.arrN43_2665

def PRE_first_tail_x15_r0_body.arrEl43_2673467 : List Val := []
kernel_rfl PRE_first_tail_x15_r0_body.arrE43_2673467 : arrOf PRE_first_tail_x15_r0_body.s428 2673467 = arrOf PRE_first_tail_x15_r0_body.s0 2673467 ++ PRE_first_tail_x15_r0_body.arrEl43_2673467
kernel_rfl PRE_first_tail_x15_r0_body.arrA43_2673467 : isArrB PRE_first_tail_x15_r0_body.s428 2673467 = true
theorem PRE_first_tail_x15_r0_body.arr43_2673467 : ∃ o, PRE_first_tail_x15_r0_body.s428.heap.get 2673467 = some (.obj o) ∧ o.kind = .array (arrOf PRE_first_tail_x15_r0_body.s0 2673467 ++ PRE_first_tail_x15_r0_body.arrEl43_2673467) :=
  arrExt_of PRE_first_tail_x15_r0_body.arrE43_2673467 PRE_first_tail_x15_r0_body.arrA43_2673467
kernel_rfl PRE_first_tail_x15_r0_body.arrN43_2673467 : numRefsB PRE_first_tail_x15_r0_body.S0.tab.length PRE_first_tail_x15_r0_body.arrEl43_2673467 = true
theorem PRE_first_tail_x15_r0_body.arrR43_2673467 : Prefill.NumRefs PRE_first_tail_x15_r0_body.S0.tab.length PRE_first_tail_x15_r0_body.arrEl43_2673467 := numRefs_of PRE_first_tail_x15_r0_body.arrN43_2673467

kernel_rfl PRE_first_tail_x15_r0_body.w4910k43 : isArrB PRE_first_tail_x15_r0_body.s428 4910 = false
theorem PRE_first_tail_x15_r0_body.keep43 (q : List Val) : Host.Ts.Sim.Prefill.KeepsAtW (framesP PRE_first_tail_x15_r0_body.s0 q) PRE_first_tail_x15_r0_body.s428 := by
  intro a pre pre' hx o es ho hk
  unfold framesP at hx
  simp only at hx
  cases h1 : Nat.beq a 2665
  · cases h2 : Nat.beq a 4910
    · rw [h1, h2] at hx; cases hx
    · have := Nat.eq_of_beq_eq_true h2; subst this
      rw [h1, h2] at hx; cases hx
      exact (notArr_of PRE_first_tail_x15_r0_body.w4910k43 ho hk).elim
  · have := Nat.eq_of_beq_eq_true h1; subst this
    rw [h1] at hx; cases hx
    obtain ⟨o', ho', hk'⟩ := PRE_first_tail_x15_r0_body.arr43_2665
    rw [ho] at ho'; cases ho'
    rw [hk'] at hk; cases hk
    simp [PRE_first_tail_x15_r0_body.arrEl43_2665]

end Host.Load.Run.Tpl
end

section -- SiteZ43
set_option Elab.async false
namespace Host.Load.Run.Tpl
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
open Host.Ts Host.Ts.Sim Host.Ts.Sim.Template

/-! The compaction's state shift at call site 43 of chain `PRE_first_tail_x15_r0_body` (`Conv.compact_shift`): the call `PRE_first_tail_x15_r0_body.s427`, the merged
state `PRE_first_tail_x15_r0_body.s428`, the canonical state `PRE_first_tail_x15_r0_body.s429`; its frames [2665,2673467,2673472,2673473] (kept arrays [2665,2673467]). -/

-- the map's places and counters
kernel_rfl PRE_first_tail_x15_r0_body.zpl43 : PRE_first_tail_x15_r0_body.pl43.all (Nat.ble PRE_first_tail_x15_r0_body.s427.next) = true
kernel_rfl PRE_first_tail_x15_r0_body.zplnd43 : nodupT PRE_first_tail_x15_r0_body.pl43 PTrie.nil = true
kernel_rfl PRE_first_tail_x15_r0_body.zn143 : Nat.ble PRE_first_tail_x15_r0_body.s427.next 2708717 = true
kernel_rfl PRE_first_tail_x15_r0_body.zfirst43 : Nat.ble aFirst PRE_first_tail_x15_r0_body.s427.next = true
kernel_rfl PRE_first_tail_x15_r0_body.zscn43 : PRE_first_tail_x15_r0_body.s429.next = PRE_first_tail_x15_r0_body.s427.next + PRE_first_tail_x15_r0_body.pl43.length
kernel_rfl PRE_first_tail_x15_r0_body.zsmn43 : PRE_first_tail_x15_r0_body.s428.next = 2708717
kernel_rfl PRE_first_tail_x15_r0_body.zgrow43 : Nat.ble PRE_first_tail_x15_r0_body.s429.next PRE_first_tail_x15_r0_body.s428.next = true
-- the tables
kernel_rfl PRE_first_tail_x15_r0_body.zfresh43 : PRE_first_tail_x15_r0_body.S427.tab.all (fun e => PRE_first_tail_x15_r0_body.cws43.all fun v => e.noVar v) = true
kernel_rfl PRE_first_tail_x15_r0_body.zcnd43 : nodupT PRE_first_tail_x15_r0_body.cws43 PTrie.nil = true
kernel_rfl PRE_first_tail_x15_r0_body.znrHi43 : PRE_first_tail_x15_r0_body.nr43.all (fun r => Nat.blt r PRE_first_tail_x15_r0_body.S428.tab.length) = true
-- the frames: every framed address below the call's counter; the kept arrays the chain start's, extended in the merged state
kernel_rfl PRE_first_tail_x15_r0_body.zfrlt43 : [2665, 2673467, 2673472, 2673473].all (fun a => Nat.blt a PRE_first_tail_x15_r0_body.s427.next) = true
kernel_rfl PRE_first_tail_x15_r0_body.zg43_2665 : PRE_first_tail_x15_r0_body.s429.heap.get 2665 = some (.obj (objOf PRE_first_tail_x15_r0_body.s429 2665))
kernel_rfl PRE_first_tail_x15_r0_body.zk43_2665 : (objOf PRE_first_tail_x15_r0_body.s429 2665).kind = .array (arrOf PRE_first_tail_x15_r0_body.s0 2665)
kernel_rfl PRE_first_tail_x15_r0_body.zm43_2665 : PRE_first_tail_x15_r0_body.s428.heap.get 2665 = some (.obj { PRE_first_tail_x15_r0_body.kappa43.obj (objOf PRE_first_tail_x15_r0_body.s429 2665) with
  kind := .array (arrOf PRE_first_tail_x15_r0_body.s0 2665 ++ (arrOf PRE_first_tail_x15_r0_body.s428 2665).drop (arrOf PRE_first_tail_x15_r0_body.s0 2665).length) })
kernel_rfl PRE_first_tail_x15_r0_body.zg43_2673467 : PRE_first_tail_x15_r0_body.s429.heap.get 2673467 = some (.obj (objOf PRE_first_tail_x15_r0_body.s429 2673467))
kernel_rfl PRE_first_tail_x15_r0_body.zk43_2673467 : (objOf PRE_first_tail_x15_r0_body.s429 2673467).kind = .array (arrOf PRE_first_tail_x15_r0_body.s0 2673467)
kernel_rfl PRE_first_tail_x15_r0_body.zm43_2673467 : PRE_first_tail_x15_r0_body.s428.heap.get 2673467 = some (.obj { PRE_first_tail_x15_r0_body.kappa43.obj (objOf PRE_first_tail_x15_r0_body.s429 2673467) with
  kind := .array (arrOf PRE_first_tail_x15_r0_body.s0 2673467 ++ (arrOf PRE_first_tail_x15_r0_body.s428 2673467).drop (arrOf PRE_first_tail_x15_r0_body.s0 2673467).length) })
kernel_rfl PRE_first_tail_x15_r0_body.zw43_4910 : (PRE_first_tail_x15_r0_body.s429.heap.get 4910).isSome = true
kernel_rfl PRE_first_tail_x15_r0_body.zw43_2673472 : (PRE_first_tail_x15_r0_body.s429.heap.get 2673472).isSome = true
kernel_rfl PRE_first_tail_x15_r0_body.zw43_2673473 : (PRE_first_tail_x15_r0_body.s429.heap.get 2673473).isSome = true
-- the heap: the changed list in range, holding the stage's written and fresh addresses; the canonical side's image
kernel_rfl PRE_first_tail_x15_r0_body.zclbd43 : PRE_first_tail_x15_r0_body.cl43.all (fun b => Nat.blt (b / 4096) (4 ^ 31)) = true
kernel_rfl PRE_first_tail_x15_r0_body.zwr43 : PRE_first_tail_x15_r0_body.st43.wr.all (fun b => !Nat.blt b PRE_first_tail_x15_r0_body.s427.next || PRE_first_tail_x15_r0_body.cl43.contains b) = true
def PRE_first_tail_x15_r0_body.zl43 : List Nat := PRE_first_tail_x15_r0_body.cl43.filter fun a => !(List.contains [2665, 2673467] a)
kernel_rfl PRE_first_tail_x15_r0_body.zimgE43 : PRE_first_tail_x15_r0_body.zl43.map (fun a => PRE_first_tail_x15_r0_body.s428.heap.get (PRE_first_tail_x15_r0_body.kappa43.a a)) = PRE_first_tail_x15_r0_body.zl43.map (fun a => (PRE_first_tail_x15_r0_body.s429.heap.get a).map PRE_first_tail_x15_r0_body.kappa43.hobj)
theorem PRE_first_tail_x15_r0_body.zimg43 : HeapImg PRE_first_tail_x15_r0_body.kappa43 PRE_first_tail_x15_r0_body.s429 PRE_first_tail_x15_r0_body.s428 PRE_first_tail_x15_r0_body.zl43 := PRE_first_tail_x15_r0_body.zimgE43
-- the roots and their supports
kernel_rfl PRE_first_tail_x15_r0_body.zctl43 : PRE_first_tail_x15_r0_body.s428.ctl = PRE_first_tail_x15_r0_body.kappa43.ctl PRE_first_tail_x15_r0_body.s429.ctl
kernel_rfl PRE_first_tail_x15_r0_body.zstack43 : PRE_first_tail_x15_r0_body.s428.stack = PRE_first_tail_x15_r0_body.s429.stack.map PRE_first_tail_x15_r0_body.kappa43.frame
kernel_rfl PRE_first_tail_x15_r0_body.zjobs43 : PRE_first_tail_x15_r0_body.s428.jobs = PRE_first_tail_x15_r0_body.s429.jobs.map PRE_first_tail_x15_r0_body.kappa43.job
kernel_rfl PRE_first_tail_x15_r0_body.zstores43 : PRE_first_tail_x15_r0_body.s428.stores = PRE_first_tail_x15_r0_body.kappa43.stores PRE_first_tail_x15_r0_body.s429.stores
kernel_rfl PRE_first_tail_x15_r0_body.zroots43 : checkRootsSupp PRE_first_tail_x15_r0_body.s429 1919 = true
kernel_rfl PRE_first_tail_x15_r0_body.znC43 : PRE_first_tail_x15_r0_body.S427.tab.length + PRE_first_tail_x15_r0_body.cws43.length = 1919
-- the map as `Conv.compact_shift` states it (the call's counters for the literals)
kernel_rfl PRE_first_tail_x15_r0_body.zkap43 : PRE_first_tail_x15_r0_body.kappa43 = Conv.Map.compact PRE_first_tail_x15_r0_body.s427.next 2708717 PRE_first_tail_x15_r0_body.S427.tab.length PRE_first_tail_x15_r0_body.pl43 (PRE_first_tail_x15_r0_body.nr43.map NumV.ref) PRE_first_tail_x15_r0_body.kd43.big
  PRE_first_tail_x15_r0_body.kd43.region PRE_first_tail_x15_r0_body.kd43.nodeF
-- the bridge inactive at the canonical state (`Conv.FullShiftQ.toX`; the merged state's bridge is the canonical's: cbridge)
theorem PRE_first_tail_x15_r0_body.zbin43 : (Host.Ts.Sim.Full.bridgeOf PRE_first_tail_x15_r0_body.s429.ffi).active = false := (Host.Load.Boot.replay_active Host.Load.Run.Prompt.P.oblog2818)
-- the JS bookkeeping's step (`Conv.JClean.step` over the changed list) and the canonical roots' bigint freedom
kernel_rfl PRE_first_tail_x15_r0_body.zjc43 : Conv.jcleanListB (⟨19054, 16155, 2708715, 1919⟩ : Conv.Cnt) PRE_first_tail_x15_r0_body.s429 PRE_first_tail_x15_r0_body.cl43 = true
kernel_rfl PRE_first_tail_x15_r0_body.zrootsB43 : noBigRootsP (fun i => !Conv.oldBigB (⟨19054, 16155, 2708715, 1919⟩ : Conv.Cnt) i) PRE_first_tail_x15_r0_body.s429.trace PRE_first_tail_x15_r0_body.s429 = true
kernel_rfl PRE_first_tail_x15_r0_body.zhm43 : Nat.ble (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s0.ffi).mlx.nnext 16155 = true
theorem PRE_first_tail_x15_r0_body.cjcl43 (h : Conv.JClean (⟨19054, 16155, 2708715, 1919⟩ : Conv.Cnt) PRE_first_tail_x15_r0_body.s427) : Conv.JClean (⟨19054, 16155, 2708715, 1919⟩ : Conv.Cnt) PRE_first_tail_x15_r0_body.s429 :=
  Conv.JClean.step h (Conv.Cnt.le_of_leB PRE_first_tail_x15_r0_body.cle43)
    (Conv.heap_off_setAll PRE_first_tail_x15_r0_body.cheap43 fun a ha => Nat.blt_eq.mp (List.all_eq_true.mp PRE_first_tail_x15_r0_body.zclbd43 a ha)) PRE_first_tail_x15_r0_body.zjc43

end Host.Load.Run.Tpl
end

section -- st43/TypedLast
set_option Elab.async false
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
namespace Host.Load.Run.Tpl
open Host.Ts Host.Ts.Sim Host.Ts.Sim.Template

boot_rfl PRE_first_tail_x15_r0_body.st43.bodyLast from PRE_first_tail_x15_r0_body.st43.s1 to PRE_first_tail_x15_r0_body.st43.s2 :
  interpS (step PRE_first_tail_x15_r0_body.st43.F PRE_first_tail_x15_r0_body.st43.s1).run PRE_first_tail_x15_r0_body.st43.S1 = some (PRE_first_tail_x15_r0_body.st43.s2, PRE_first_tail_x15_r0_body.st43.S2)
kernel_rfl PRE_first_tail_x15_r0_body.st43.bodyHalt : isHalt PRE_first_tail_x15_r0_body.st43.s1.ctl = false
kernel_rfl PRE_first_tail_x15_r0_body.st43.bodyTopCheck : noBlockTop PRE_first_tail_x15_r0_body.st43.s2.stack = true

end Host.Load.Run.Tpl
end

section -- st43/TypedOk
set_option Elab.async false
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
namespace Host.Load.Run.Tpl
open Host.Ts Host.Ts.Sim Host.Ts.Sim.Template

noncomputable def PRE_first_tail_x15_r0_body.st43.bodyOkL (bytes : List Byte) (rows : Nat) : St PRE_first_tail_x15_r0_body.st43.F.S → SSrv → Bool :=
  okLocal (Host.Ts.Sim.Compose.VWFrames.bodyOk bytes rows)

noncomputable def PRE_first_tail_x15_r0_body.st43.bodyOkLN (bytes : List Byte) (rows : Nat) : St PRE_first_tail_x15_r0_body.st43.F.S → FSrv → Bool :=
  okLocalN (Host.Ts.Sim.Compose.VWFrames.bodyOkN bytes rows)

theorem PRE_first_tail_x15_r0_body.st43.bodyOkLN_ok (bytes : List Byte) (rows : Nat) (s : St PRE_first_tail_x15_r0_body.st43.F.S) (c : FSrv) (h : c.Wf) :
    PRE_first_tail_x15_r0_body.st43.bodyOkLN bytes rows s c = PRE_first_tail_x15_r0_body.st43.bodyOkL bytes rows s c.toS :=
  okLocalN_ok (Host.Ts.Sim.Compose.VWFrames.bodyOkN_ok bytes rows) s c h

kernel_rfl PRE_first_tail_x15_r0_body.st43.bodyAccepted0 :
  (fun (bytes : List Byte) (rows : Nat) => PRE_first_tail_x15_r0_body.st43.bodyOkL bytes rows PRE_first_tail_x15_r0_body.st43.s0 PRE_first_tail_x15_r0_body.st43.S0) = fun _ _ => true

kernel_rfl PRE_first_tail_x15_r0_body.st43.bodyAccepted1 :
  (fun (bytes : List Byte) (rows : Nat) => PRE_first_tail_x15_r0_body.st43.bodyOkL bytes rows PRE_first_tail_x15_r0_body.st43.s1 PRE_first_tail_x15_r0_body.st43.S1) = fun _ _ => true

end Host.Load.Run.Tpl
end

section -- st43/TypedK0
set_option Elab.async false
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
namespace Host.Load.Run.Tpl
open Host.Ts Host.Ts.Sim Host.Ts.Sim.Template

boot_rfl PRE_first_tail_x15_r0_body.st43.bodyK0F from PRE_first_tail_x15_r0_body.st43.s0 to PRE_first_tail_x15_r0_body.st43.s1 :
  (fun (bytes : List Byte) (rows : Nat) => runOkS PRE_first_tail_x15_r0_body.st43.F (PRE_first_tail_x15_r0_body.st43.bodyOkLN bytes rows)
    ((nth? PRE_first_tail_x15_r0_body.st43.ks 0).getD 0) PRE_first_tail_x15_r0_body.st43.s0 PRE_first_tail_x15_r0_body.st43.S0) = fun _ _ => some (PRE_first_tail_x15_r0_body.st43.s1, PRE_first_tail_x15_r0_body.st43.S1)
theorem PRE_first_tail_x15_r0_body.st43.bodyK0 :
  (fun (bytes : List Byte) (rows : Nat) => runOk PRE_first_tail_x15_r0_body.st43.F (PRE_first_tail_x15_r0_body.st43.bodyOkL bytes rows)
    ((nth? PRE_first_tail_x15_r0_body.st43.ks 0).getD 0) PRE_first_tail_x15_r0_body.st43.s0 PRE_first_tail_x15_r0_body.st43.S0) = fun _ _ => some (PRE_first_tail_x15_r0_body.st43.s1, PRE_first_tail_x15_r0_body.st43.S1) :=
  runOk_fun_of_runOkS PRE_first_tail_x15_r0_body.st43.bodyOkLN_ok PRE_first_tail_x15_r0_body.st43.bodyK0F
end Host.Load.Run.Tpl
end

section -- st43/TypedTpl
set_option Elab.async false
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
namespace Host.Load.Run.Tpl
open Host.Ts Host.Ts.Sim Host.Ts.Sim.Template

theorem PRE_first_tail_x15_r0_body.st43.bodyRun (bytes : List Byte) (rows : Nat) :
    runOk PRE_first_tail_x15_r0_body.st43.F (PRE_first_tail_x15_r0_body.st43.bodyOkL bytes rows) 27 PRE_first_tail_x15_r0_body.st43.s0 PRE_first_tail_x15_r0_body.st43.S0 = some (PRE_first_tail_x15_r0_body.st43.s1, PRE_first_tail_x15_r0_body.st43.S1) :=
  (congrFun (congrFun PRE_first_tail_x15_r0_body.st43.bodyK0 bytes) rows)

theorem PRE_first_tail_x15_r0_body.st43.bodyLocal (bytes : List Byte) (rows : Nat) : ∀ s S, PRE_first_tail_x15_r0_body.st43.bodyOkL bytes rows s S = true → Disp.localB s = true := okLocal_localB

noncomputable def PRE_first_tail_x15_r0_body.st43.bodyTpl (bytes : List Byte) (rows : Nat) : Host.Ts.Sim.Stage.StageTpl PRE_first_tail_x15_r0_body.st43.F (PRE_first_tail_x15_r0_body.st43.bodyOkL bytes rows) where
  s0 := PRE_first_tail_x15_r0_body.st43.s0
  S0 := PRE_first_tail_x15_r0_body.st43.S0
  s1 := PRE_first_tail_x15_r0_body.st43.s1
  S1 := PRE_first_tail_x15_r0_body.st43.S1
  s2 := PRE_first_tail_x15_r0_body.st43.s2
  S2 := PRE_first_tail_x15_r0_body.st43.S2
  n := 27
  ok0 := congrFun (congrFun PRE_first_tail_x15_r0_body.st43.bodyAccepted0 bytes) rows
  run := PRE_first_tail_x15_r0_body.st43.bodyRun bytes rows
  ok1 := congrFun (congrFun PRE_first_tail_x15_r0_body.st43.bodyAccepted1 bytes) rows
  halt := PRE_first_tail_x15_r0_body.st43.bodyHalt
  last := PRE_first_tail_x15_r0_body.st43.bodyLast
  top := noBlockTop_sound PRE_first_tail_x15_r0_body.st43.bodyTopCheck
end Host.Load.Run.Tpl
end

section -- SiteC44
set_option Elab.async false
namespace Host.Load.Run.Tpl
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
open Host.Ts Host.Ts.Sim Host.Ts.Sim.Template

/-! The compaction after the merge at call site 44 of chain `PRE_first_tail_x15_r0_body` (`Conv.compact`, `Conv.full_compactQ`): the canonical
state `PRE_first_tail_x15_r0_body.s433` (the stage's results at canonical places, its trace the call's) under `PRE_first_tail_x15_r0_body.kappa44` into the merged state
`PRE_first_tail_x15_r0_body.s432`. -/

def PRE_first_tail_x15_r0_body.pl44 : List Nat := [2709013]
def PRE_first_tail_x15_r0_body.nr44 : List Nat := []
/-- The native part of the compaction map (canonical → merged handles and nodes: its `big`, `region`, `nodeF`). -/
def PRE_first_tail_x15_r0_body.kd44 : RData :=
  ⟨2709004, 2709014, Stage.setAll PTrie.nil [(2709003, 2709013)], Stage.setAll PTrie.nil [],
   19061, 19061, 16159, 16159, Stage.setAll PTrie.nil [],
   Stage.setAll PTrie.nil []⟩
/-- **The compaction map.** -/
noncomputable def PRE_first_tail_x15_r0_body.kappa44 : Map :=
  Conv.Map.compact 2709003 2709014 1936 PRE_first_tail_x15_r0_body.pl44 (PRE_first_tail_x15_r0_body.nr44.map NumV.ref) PRE_first_tail_x15_r0_body.kd44.big
    PRE_first_tail_x15_r0_body.kd44.region PRE_first_tail_x15_r0_body.kd44.nodeF
/-- The canonical result variables and their images, the merged state's entries (`Conv.compactθ`). -/
def PRE_first_tail_x15_r0_body.cws44 : List Nat := []
noncomputable def PRE_first_tail_x15_r0_body.crs44 : List SymE := PRE_first_tail_x15_r0_body.nr44.map fun r => (nth? PRE_first_tail_x15_r0_body.S432.tab r).getD (.var 0)
noncomputable def PRE_first_tail_x15_r0_body.ctheta44 : Nat → SymE := Conv.compactθ PRE_first_tail_x15_r0_body.cws44 PRE_first_tail_x15_r0_body.crs44
/-- The call's entries the stage wrote (renamed in the canonical state with the results). -/
def PRE_first_tail_x15_r0_body.wrB44 : List Nat := [2665, 2673467]

kernel_rfl PRE_first_tail_x15_r0_body.ctab44 : PRE_first_tail_x15_r0_body.S433.tab = PRE_first_tail_x15_r0_body.S431.tab ++ PRE_first_tail_x15_r0_body.cws44.map SymE.var
kernel_rfl PRE_first_tail_x15_r0_body.ctrace44 : PRE_first_tail_x15_r0_body.s433.trace = PRE_first_tail_x15_r0_body.s431.trace
kernel_rfl PRE_first_tail_x15_r0_body.cnext44 : PRE_first_tail_x15_r0_body.s433.next = 2709004
kernel_rfl PRE_first_tail_x15_r0_body.ccounters44 : ((Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s433.ffi).mlx.next, (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s433.ffi).mlx.nnext) = (19061, 16159)
-- the merged state's readback queue, carried to the canonical state (`Conv.FullShiftQ.tokens`, `tokSupp`)
kernel_rfl PRE_first_tail_x15_r0_body.cqueue44 : (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s432.ffi).mlx.tokens = (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s433.ffi).mlx.tokens.map PRE_first_tail_x15_r0_body.kappa44.nv
kernel_rfl PRE_first_tail_x15_r0_body.ctokSupp44 : (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s433.ffi).mlx.tokens.all (bSN 1936) = true
-- the written and the result entries carry no bigint of the canonical fresh band [next, E) and no fresh region
kernel_rfl PRE_first_tail_x15_r0_body.cclean44 : Conv.cleanListB 19061 131072 (fun r => Nat.ble 76244 r) PRE_first_tail_x15_r0_body.s433
    (PRE_first_tail_x15_r0_body.wrB44 ++ (List.range 1).map (2709003 + ·)) = true
kernel_rfl PRE_first_tail_x15_r0_body.cbigs44 : bigsOutB 19061 131072 (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s433.ffi).mlx = true

end Host.Load.Run.Tpl
end

section -- SiteK44
set_option Elab.async false
namespace Host.Load.Run.Tpl
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
open Host.Ts Host.Ts.Sim Host.Ts.Sim.Template

/-! The canonical state's closedness from the call's (`Conv.closed_of_callB`, `Conv.sst_of_callB`): it keeps the call's entries
off the written and the result ones (`PRE_first_tail_x15_r0_body.cl44`; natively the written and result handles, the result nodes, the written
and result items), and those are checked. -/

def PRE_first_tail_x15_r0_body.cl44 : List Nat := [2665, 2673467, 2709003]
def PRE_first_tail_x15_r0_body.clo44 : List Nat := []
def PRE_first_tail_x15_r0_body.cln44 : List Nat := []
def PRE_first_tail_x15_r0_body.cli44 : List Nat := []
kernel_rfl PRE_first_tail_x15_r0_body.cheap44 : PRE_first_tail_x15_r0_body.s433.heap = Stage.setAll PRE_first_tail_x15_r0_body.s431.heap (PRE_first_tail_x15_r0_body.cl44.filterMap fun a => (PRE_first_tail_x15_r0_body.s433.heap.get a).map (a, ·))
kernel_rfl PRE_first_tail_x15_r0_body.cnextLe44 : Nat.ble PRE_first_tail_x15_r0_body.s431.next PRE_first_tail_x15_r0_body.s433.next = true
kernel_rfl PRE_first_tail_x15_r0_body.ckeepP44 : Conv.keptPresentB PRE_first_tail_x15_r0_body.s431 PRE_first_tail_x15_r0_body.s433 PRE_first_tail_x15_r0_body.cl44 = true
kernel_rfl PRE_first_tail_x15_r0_body.csupp44 : Conv.suppListB PRE_first_tail_x15_r0_body.s433 1936 PRE_first_tail_x15_r0_body.cl44 = true
kernel_rfl PRE_first_tail_x15_r0_body.cbound44 : Conv.boundListB PRE_first_tail_x15_r0_body.s433 PRE_first_tail_x15_r0_body.cl44 = true
kernel_rfl PRE_first_tail_x15_r0_body.cnodesK44 : (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s433.ffi).mlx.nodes = Stage.setAll (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s431.ffi).mlx.nodes (PRE_first_tail_x15_r0_body.cln44.filterMap fun i => ((Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s433.ffi).mlx.nodes.get i).map (i, ·))
kernel_rfl PRE_first_tail_x15_r0_body.cobjsK44 : (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s433.ffi).mlx.objs = Stage.setAll (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s431.ffi).mlx.objs (PRE_first_tail_x15_r0_body.clo44.filterMap fun i => ((Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s433.ffi).mlx.objs.get i).map (i, ·))
kernel_rfl PRE_first_tail_x15_r0_body.citemsK44 : (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s433.ffi).mlx.items = Stage.setAll (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s431.ffi).mlx.items (PRE_first_tail_x15_r0_body.cli44.filterMap fun i => ((Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s433.ffi).mlx.items.get i).map (i, ·))
kernel_rfl PRE_first_tail_x15_r0_body.csst44 : Conv.sstListB 1936 (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s433.ffi).mlx PRE_first_tail_x15_r0_body.cln44 PRE_first_tail_x15_r0_body.clo44 PRE_first_tail_x15_r0_body.cli44 = true

end Host.Load.Run.Tpl
end

section -- SiteCl44
set_option Elab.async false
namespace Host.Load.Run.Tpl
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
open Host.Ts Host.Ts.Sim Host.Ts.Sim.Template

kernel_rfl PRE_first_tail_x15_r0_body.ckA44 : (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s433.ffi).mlx.arrs = Stage.setAll (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s431.ffi).mlx.arrs (PRE_first_tail_x15_r0_body.clo44.filterMap fun i => ((Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s433.ffi).mlx.arrs.get i).map (i, ·))
kernel_rfl PRE_first_tail_x15_r0_body.cbd44 : (PRE_first_tail_x15_r0_body.clo44 ++ PRE_first_tail_x15_r0_body.cln44 ++ PRE_first_tail_x15_r0_body.cli44).all (fun i => Nat.blt (i / 4096) (4 ^ 31)) = true
kernel_rfl PRE_first_tail_x15_r0_body.cle44 : Conv.Cnt.leB (⟨19061, 16159, 2709003, 1936⟩ : Conv.Cnt) (⟨19061, 16159, 2709004, 1936⟩ : Conv.Cnt) = true
kernel_rfl PRE_first_tail_x15_r0_body.cck44 : Conv.ncleanListB (⟨19061, 16159, 2709004, 1936⟩ : Conv.Cnt) (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s433.ffi).mlx PRE_first_tail_x15_r0_body.clo44 PRE_first_tail_x15_r0_body.cln44 PRE_first_tail_x15_r0_body.cli44 = true
theorem PRE_first_tail_x15_r0_body.cncl44 (h : Conv.NClean (⟨19061, 16159, 2709003, 1936⟩ : Conv.Cnt) (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s431.ffi).mlx) : Conv.NClean (⟨19061, 16159, 2709004, 1936⟩ : Conv.Cnt) (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s433.ffi).mlx :=
  Conv.NClean.stepKeep h PRE_first_tail_x15_r0_body.cle44 PRE_first_tail_x15_r0_body.ckA44 PRE_first_tail_x15_r0_body.cobjsK44 PRE_first_tail_x15_r0_body.cnodesK44 PRE_first_tail_x15_r0_body.citemsK44 PRE_first_tail_x15_r0_body.cbd44 PRE_first_tail_x15_r0_body.cck44

end Host.Load.Run.Tpl
end

section -- SiteS44
set_option Elab.async false
namespace Host.Load.Run.Tpl
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
open Host.Ts Host.Ts.Sim Host.Ts.Sim.Template

/-! The compaction's native shift at call site 44 from its footprint (`Conv.nshift_of_foot`), and the observers'
(`liveShift_foot`, `kernShift_foot`): `Conv.FullShiftQ` for `Conv.full_compactQ`, given the call's bookkeeping and its
relation's facts. -/

/-- The load parameters of the chain (band-free: its start's node counter as `NL` and `N0`). -/
def PRE_first_tail_x15_r0_body.Pc44 : LoadP := ⟨18151, 131072, 1099511627776, 15235, 15235, []⟩
/-- The site's band raised to the map's checked fixed-node prefix, including newly recorded closure traces. -/
def PRE_first_tail_x15_r0_body.P44 : LoadP := PRE_first_tail_x15_r0_body.Pc44.raise 16159
kernel_rfl PRE_first_tail_x15_r0_body.craise44 : Nat.ble PRE_first_tail_x15_r0_body.Pc44.N0 16159 = true
theorem PRE_first_tail_x15_r0_body.raised44 : Host.Ts.Sim.Full.Raised PRE_first_tail_x15_r0_body.Pc44 PRE_first_tail_x15_r0_body.P44 :=
  .inr ⟨16159, rfl, Nat.le_of_ble_eq_true PRE_first_tail_x15_r0_body.craise44, rfl⟩
noncomputable abbrev PRE_first_tail_x15_r0_body.cx0_44 : Host.Load.LSt := clearTokens (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s433.ffi)
noncomputable abbrev PRE_first_tail_x15_r0_body.cx1_44 : Host.Load.LSt := clearTokens (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s432.ffi)
def PRE_first_tail_x15_r0_body.khinv44 : PTrie Nat := Stage.setAll PTrie.nil []
def PRE_first_tail_x15_r0_body.kninv44 : PTrie Nat := Stage.setAll PTrie.nil []
/-- The stage's footprint: its written and fresh handles, fresh nodes, written and fresh items. -/
def PRE_first_tail_x15_r0_body.cwS44 : List Nat := []
def PRE_first_tail_x15_r0_body.cnS44 : List Nat := List.range' 16159 0
def PRE_first_tail_x15_r0_body.ciS44 : List Nat := [] ++ List.range' 16159 0

-- the small checks (`MChecks`'s)
kernel_rfl PRE_first_tail_x15_r0_body.cnh044 : PRE_first_tail_x15_r0_body.kd44.nh0 = PRE_first_tail_x15_r0_body.cx0_44.mlx.next
kernel_rfl PRE_first_tail_x15_r0_body.cnh144 : PRE_first_tail_x15_r0_body.kd44.nh1 = PRE_first_tail_x15_r0_body.cx1_44.mlx.next
kernel_rfl PRE_first_tail_x15_r0_body.cnn044 : PRE_first_tail_x15_r0_body.kd44.nn0 = PRE_first_tail_x15_r0_body.cx0_44.mlx.nnext
kernel_rfl PRE_first_tail_x15_r0_body.cnn144 : PRE_first_tail_x15_r0_body.kd44.nn1 = PRE_first_tail_x15_r0_body.cx1_44.mlx.nnext
kernel_rfl PRE_first_tail_x15_r0_body.cplo44 : (Nat.blt 0 PRE_first_tail_x15_r0_body.P44.lo && Nat.ble PRE_first_tail_x15_r0_body.P44.lo PRE_first_tail_x15_r0_body.cx0_44.mlx.next && Nat.ble PRE_first_tail_x15_r0_body.P44.lo RData.bigHi && Nat.ble RData.bigHi PRE_first_tail_x15_r0_body.P44.E) = true
kernel_rfl PRE_first_tail_x15_r0_body.ccnt44 : (Nat.ble PRE_first_tail_x15_r0_body.cx0_44.mlx.next PRE_first_tail_x15_r0_body.cx1_44.mlx.next && Nat.ble PRE_first_tail_x15_r0_body.cx0_44.mlx.nnext PRE_first_tail_x15_r0_body.cx1_44.mlx.nnext) = true
kernel_rfl PRE_first_tail_x15_r0_body.cnband44 : (Nat.blt 0 PRE_first_tail_x15_r0_body.P44.NL && Nat.ble PRE_first_tail_x15_r0_body.P44.NL PRE_first_tail_x15_r0_body.P44.N0 && Nat.ble PRE_first_tail_x15_r0_body.P44.N0 PRE_first_tail_x15_r0_body.cx0_44.mlx.nnext) = true
kernel_rfl PRE_first_tail_x15_r0_body.chbelow44 : PRE_first_tail_x15_r0_body.kd44.checkHndBelow = true
kernel_rfl PRE_first_tail_x15_r0_body.chren44 : checkRenG PRE_first_tail_x15_r0_body.kd44.hnd PRE_first_tail_x15_r0_body.khinv44 (phB PRE_first_tail_x15_r0_body.cx0_44.mlx) = true
kernel_rfl PRE_first_tail_x15_r0_body.cband44 : PRE_first_tail_x15_r0_body.kd44.checkBand PRE_first_tail_x15_r0_body.P44.lo = true
kernel_rfl PRE_first_tail_x15_r0_body.cnh1pos44 : Nat.blt 0 PRE_first_tail_x15_r0_body.kd44.nh1 = true
kernel_rfl PRE_first_tail_x15_r0_body.cnren44 : checkRenG PRE_first_tail_x15_r0_body.kd44.node PRE_first_tail_x15_r0_body.kninv44 (pnB PRE_first_tail_x15_r0_body.cx0_44.mlx) = true
kernel_rfl PRE_first_tail_x15_r0_body.cnlow44 : (PTrie.keysA PRE_first_tail_x15_r0_body.kd44.node).all (fun j => Nat.ble PRE_first_tail_x15_r0_body.P44.NL j && Nat.blt (PRE_first_tail_x15_r0_body.kd44.nodeF j) PRE_first_tail_x15_r0_body.cx1_44.mlx.nnext) = true
kernel_rfl PRE_first_tail_x15_r0_body.cabs0a44 : PRE_first_tail_x15_r0_body.cx0_44.mlx.arrs.get 0 = none
kernel_rfl PRE_first_tail_x15_r0_body.cabs0b44 : PRE_first_tail_x15_r0_body.cx0_44.mlx.objs.get 0 = none
kernel_rfl PRE_first_tail_x15_r0_body.ctok144 : PRE_first_tail_x15_r0_body.cx1_44.mlx.tokens = []
kernel_rfl PRE_first_tail_x15_r0_body.cpend44 : PRE_first_tail_x15_r0_body.cx1_44.mlx.pending = PRE_first_tail_x15_r0_body.cx0_44.mlx.pending.map PRE_first_tail_x15_r0_body.kappa44.pend
kernel_rfl PRE_first_tail_x15_r0_body.cerrh44 : PRE_first_tail_x15_r0_body.cx1_44.mlx.errh = PRE_first_tail_x15_r0_body.cx0_44.mlx.errh.map PRE_first_tail_x15_r0_body.kappa44.arg
kernel_rfl PRE_first_tail_x15_r0_body.cfiles44 : PRE_first_tail_x15_r0_body.cx1_44.mlx.files = PRE_first_tail_x15_r0_body.cx0_44.mlx.files
kernel_rfl PRE_first_tail_x15_r0_body.carch44 : PRE_first_tail_x15_r0_body.cx1_44.mlx.arch = PRE_first_tail_x15_r0_body.cx0_44.mlx.arch
kernel_rfl PRE_first_tail_x15_r0_body.csizes44 : PRE_first_tail_x15_r0_body.cx1_44.mlx.deviceSizes = PRE_first_tail_x15_r0_body.cx0_44.mlx.deviceSizes
kernel_rfl PRE_first_tail_x15_r0_body.cwired44 : PRE_first_tail_x15_r0_body.cx1_44.mlx.wired = PRE_first_tail_x15_r0_body.cx0_44.mlx.wired
kernel_rfl PRE_first_tail_x15_r0_body.chost44 : PRE_first_tail_x15_r0_body.cx1_44.host = PRE_first_tail_x15_r0_body.cx0_44.host
-- the compaction map's addresses are `PRE_first_tail_x15_r0_body.kd44`'s
kernel_rfl PRE_first_tail_x15_r0_body.ckn044 : PRE_first_tail_x15_r0_body.kd44.n0 = 2709004
kernel_rfl PRE_first_tail_x15_r0_body.ckn144 : PRE_first_tail_x15_r0_body.kd44.n1 = 2709014
kernel_rfl PRE_first_tail_x15_r0_body.ckheap44 : (PTrie.keysA PRE_first_tail_x15_r0_body.kd44.heap).all (fun x => Nat.ble 2709003 x) = true
kernel_rfl PRE_first_tail_x15_r0_body.ckpl44 : (List.range 1).all (fun j => decide (PRE_first_tail_x15_r0_body.kd44.heap.get (2709003 + j) = nth? PRE_first_tail_x15_r0_body.pl44 j)) = true
-- the map fixes the call's names (`Conv.fixOld_compact`), the call's counters
kernel_rfl PRE_first_tail_x15_r0_body.fja44 : Nat.ble 2709003 2709003 = true
kernel_rfl PRE_first_tail_x15_r0_body.fn44 : Nat.ble 1936 1936 = true
kernel_rfl PRE_first_tail_x15_r0_body.fjaD44 : Nat.ble 2709003 PRE_first_tail_x15_r0_body.kd44.n0 = true
kernel_rfl PRE_first_tail_x15_r0_body.fxn44 : Nat.ble 19061 PRE_first_tail_x15_r0_body.kd44.nh0 = true
kernel_rfl PRE_first_tail_x15_r0_body.fnn44 : Nat.ble 16159 PRE_first_tail_x15_r0_body.kd44.nn0 = true
kernel_rfl PRE_first_tail_x15_r0_body.fxb44 : Nat.ble 19061 RData.bigHi = true
kernel_rfl PRE_first_tail_x15_r0_body.fheap44 : (PTrie.keysA PRE_first_tail_x15_r0_body.kd44.heap).all (Nat.ble (⟨19061, 16159, 2709003, 1936⟩ : Conv.Cnt).ja) = true
kernel_rfl PRE_first_tail_x15_r0_body.fhnd44 : (PTrie.keysA PRE_first_tail_x15_r0_body.kd44.hnd).all (Nat.ble (⟨19061, 16159, 2709003, 1936⟩ : Conv.Cnt).xn) = true
kernel_rfl PRE_first_tail_x15_r0_body.fnode44 : (PTrie.keysA PRE_first_tail_x15_r0_body.kd44.node).all (Nat.ble (⟨19061, 16159, 2709003, 1936⟩ : Conv.Cnt).nn) = true
/-- The compaction map fixes the call's names. -/
theorem PRE_first_tail_x15_r0_body.cfix44 : Conv.FixOld (⟨19061, 16159, 2709003, 1936⟩ : Conv.Cnt) PRE_first_tail_x15_r0_body.kappa44 :=
  Conv.fixOld_compact (Nat.le_of_ble_eq_true PRE_first_tail_x15_r0_body.fja44) (Nat.le_of_ble_eq_true PRE_first_tail_x15_r0_body.fn44) (Nat.le_of_ble_eq_true PRE_first_tail_x15_r0_body.fjaD44) (Nat.le_of_ble_eq_true PRE_first_tail_x15_r0_body.fxn44) (Nat.le_of_ble_eq_true PRE_first_tail_x15_r0_body.fnn44) (Nat.le_of_ble_eq_true PRE_first_tail_x15_r0_body.fxb44) PRE_first_tail_x15_r0_body.fheap44 PRE_first_tail_x15_r0_body.fhnd44 PRE_first_tail_x15_r0_body.fnode44
kernel_rfl PRE_first_tail_x15_r0_body.fcxn44 : (⟨19061, 16159, 2709003, 1936⟩ : Conv.Cnt).xn = (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s431.ffi).mlx.next
kernel_rfl PRE_first_tail_x15_r0_body.fcnn44 : (⟨19061, 16159, 2709003, 1936⟩ : Conv.Cnt).nn = (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s431.ffi).mlx.nnext
kernel_rfl PRE_first_tail_x15_r0_body.fle044 : (Nat.ble (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s431.ffi).mlx.next PRE_first_tail_x15_r0_body.cx0_44.mlx.next && Nat.ble (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s431.ffi).mlx.nnext PRE_first_tail_x15_r0_body.cx0_44.mlx.nnext && Nat.ble (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s431.ffi).mlx.next RData.bigHi) = true
kernel_rfl PRE_first_tail_x15_r0_body.fnk44 : (PTrie.keysA PRE_first_tail_x15_r0_body.kd44.node).all (Nat.ble (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s431.ffi).mlx.nnext) = true
-- the merged state keeps the call's entries off the stage's footprint
kernel_rfl PRE_first_tail_x15_r0_body.f1A44 : PRE_first_tail_x15_r0_body.cx1_44.mlx.arrs = Stage.setAll (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s431.ffi).mlx.arrs (PRE_first_tail_x15_r0_body.cwS44.filterMap fun i => (PRE_first_tail_x15_r0_body.cx1_44.mlx.arrs.get i).map (i, ·))
kernel_rfl PRE_first_tail_x15_r0_body.f1O44 : PRE_first_tail_x15_r0_body.cx1_44.mlx.objs = Stage.setAll (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s431.ffi).mlx.objs (PRE_first_tail_x15_r0_body.cwS44.filterMap fun i => (PRE_first_tail_x15_r0_body.cx1_44.mlx.objs.get i).map (i, ·))
kernel_rfl PRE_first_tail_x15_r0_body.f1N44 : PRE_first_tail_x15_r0_body.cx1_44.mlx.nodes = Stage.setAll (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s431.ffi).mlx.nodes (PRE_first_tail_x15_r0_body.cnS44.filterMap fun i => (PRE_first_tail_x15_r0_body.cx1_44.mlx.nodes.get i).map (i, ·))
kernel_rfl PRE_first_tail_x15_r0_body.f1I44 : PRE_first_tail_x15_r0_body.cx1_44.mlx.items = Stage.setAll (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s431.ffi).mlx.items (PRE_first_tail_x15_r0_body.ciS44.filterMap fun i => (PRE_first_tail_x15_r0_body.cx1_44.mlx.items.get i).map (i, ·))
kernel_rfl PRE_first_tail_x15_r0_body.fbd44 : (PRE_first_tail_x15_r0_body.clo44 ++ PRE_first_tail_x15_r0_body.cln44 ++ PRE_first_tail_x15_r0_body.cli44 ++ PRE_first_tail_x15_r0_body.cwS44 ++ PRE_first_tail_x15_r0_body.cnS44 ++ PRE_first_tail_x15_r0_body.ciS44).all (fun i => Nat.blt (i / 4096) (4 ^ 31)) = true
kernel_rfl PRE_first_tail_x15_r0_body.fincW44 : PRE_first_tail_x15_r0_body.cwS44.all (fun h => !Nat.blt h (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s431.ffi).mlx.next || PRE_first_tail_x15_r0_body.clo44.contains h) = true
kernel_rfl PRE_first_tail_x15_r0_body.fincI44 : PRE_first_tail_x15_r0_body.ciS44.all (fun k => !Nat.blt k (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s431.ffi).mlx.nnext || PRE_first_tail_x15_r0_body.cli44.contains k) = true
kernel_rfl PRE_first_tail_x15_r0_body.fincN44 : PRE_first_tail_x15_r0_body.cnS44.all (Nat.ble (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s431.ffi).mlx.nnext) = true
kernel_rfl PRE_first_tail_x15_r0_body.flnF44 : PRE_first_tail_x15_r0_body.cln44.all (Nat.ble (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s431.ffi).mlx.nnext) = true
-- the checks over the changed lists
kernel_rfl PRE_first_tail_x15_r0_body.fh44 : PRE_first_tail_x15_r0_body.clo44.all (handleOK PRE_first_tail_x15_r0_body.kappa44 PRE_first_tail_x15_r0_body.P44.lo PRE_first_tail_x15_r0_body.cx0_44.mlx PRE_first_tail_x15_r0_body.cx1_44.mlx) = true
kernel_rfl PRE_first_tail_x15_r0_body.fo44 : PRE_first_tail_x15_r0_body.clo44.map (fun h => PRE_first_tail_x15_r0_body.cx1_44.mlx.objs.get (PRE_first_tail_x15_r0_body.kappa44.handle h)) = PRE_first_tail_x15_r0_body.clo44.map (fun h => (PRE_first_tail_x15_r0_body.cx0_44.mlx.objs.get h).map PRE_first_tail_x15_r0_body.kappa44.nobj)
kernel_rfl PRE_first_tail_x15_r0_body.fok44 : PRE_first_tail_x15_r0_body.clo44.all (objOK PRE_first_tail_x15_r0_body.kappa44 PRE_first_tail_x15_r0_body.P44.NL PRE_first_tail_x15_r0_body.cx0_44.mlx) = true
kernel_rfl PRE_first_tail_x15_r0_body.fnd44 : PRE_first_tail_x15_r0_body.cln44.all (nodeOKF PRE_first_tail_x15_r0_body.kappa44 PRE_first_tail_x15_r0_body.P44 PRE_first_tail_x15_r0_body.cx0_44.mlx PRE_first_tail_x15_r0_body.cx1_44.mlx) = true
kernel_rfl PRE_first_tail_x15_r0_body.fp44 : ((PRE_first_tail_x15_r0_body.cln44.filter (fullB PRE_first_tail_x15_r0_body.P44))).map (fun i => (PRE_first_tail_x15_r0_body.cx1_44.mlx.nodes.get (PRE_first_tail_x15_r0_body.kappa44.node i)).map Host.Mlx.Ffi.Node.prim) =
  ((PRE_first_tail_x15_r0_body.cln44.filter (fullB PRE_first_tail_x15_r0_body.P44))).map (fun i => (PRE_first_tail_x15_r0_body.cx0_44.mlx.nodes.get i).map fun nd => PRE_first_tail_x15_r0_body.kappa44.prim nd.prim)
kernel_rfl PRE_first_tail_x15_r0_body.fnordI44 : incrB PRE_first_tail_x15_r0_body.kd44.nodeF (List.range' 16159 0) = true
kernel_rfl PRE_first_tail_x15_r0_body.fnordK44 : (PTrie.keysA PRE_first_tail_x15_r0_body.kd44.node).all (fun k => Nat.ble 16159 k && Nat.blt k 16159) = true
kernel_rfl PRE_first_tail_x15_r0_body.fnordL44 : (PRE_first_tail_x15_r0_body.cln44.filter (Nat.ble PRE_first_tail_x15_r0_body.P44.N0)).all (fun i => Nat.ble i (PRE_first_tail_x15_r0_body.kd44.nodeF i) && (Nat.blt i 16159 || Nat.ble PRE_first_tail_x15_r0_body.kd44.nn0 i)) = true
theorem PRE_first_tail_x15_r0_body.fnord44 : (PRE_first_tail_x15_r0_body.cln44.filter (Nat.ble PRE_first_tail_x15_r0_body.P44.N0)).all (fun i => Nat.ble i (PRE_first_tail_x15_r0_body.kd44.nodeF i) &&
    (PTrie.keysA PRE_first_tail_x15_r0_body.kd44.node).all fun j => !Nat.blt j i || Nat.blt (PRE_first_tail_x15_r0_body.kd44.nodeF j) (PRE_first_tail_x15_r0_body.kd44.nodeF i)) = true :=
  cnord_of PRE_first_tail_x15_r0_body.cnlow44 PRE_first_tail_x15_r0_body.cnn144 PRE_first_tail_x15_r0_body.fnordI44 PRE_first_tail_x15_r0_body.fnordK44 PRE_first_tail_x15_r0_body.fnordL44
kernel_rfl PRE_first_tail_x15_r0_body.fi44 : PRE_first_tail_x15_r0_body.cli44.all (pnB PRE_first_tail_x15_r0_body.cx0_44.mlx) = true
kernel_rfl PRE_first_tail_x15_r0_body.fii44 : PRE_first_tail_x15_r0_body.cli44.all (fun k => decide (PRE_first_tail_x15_r0_body.cx1_44.mlx.items.get (PRE_first_tail_x15_r0_body.kappa44.node k) = (PRE_first_tail_x15_r0_body.cx0_44.mlx.items.get k).map PRE_first_tail_x15_r0_body.kappa44.nv)) = true
/-- **The compaction's footprint.** -/
theorem PRE_first_tail_x15_r0_body.cfoot44 (clean : Conv.NClean (⟨19061, 16159, 2709003, 1936⟩ : Conv.Cnt) (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s431.ffi).mlx) (hltC : ∀ h, PH (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s431.ffi).mlx h → h < (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s431.ffi).mlx.next) (nltC : ∀ i, PN (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s431.ffi).mlx i → i < (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s431.ffi).mlx.nnext) (itemsC : ∀ k v, (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s431.ffi).mlx.items.get k = some v → PN (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s431.ffi).mlx k) (tracedC : ∀ h o, (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s431.ffi).mlx.objs.get h = some o → ∀ i ∈ objTraces o, i < PRE_first_tail_x15_r0_body.P44.NL) (cl : SSt (· < 1936) PRE_first_tail_x15_r0_body.cx0_44.mlx) :
    Conv.MFoot PRE_first_tail_x15_r0_body.P44 1936 PRE_first_tail_x15_r0_body.kappa44 PRE_first_tail_x15_r0_body.kd44 PRE_first_tail_x15_r0_body.khinv44 PRE_first_tail_x15_r0_body.kninv44 (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s431.ffi).mlx PRE_first_tail_x15_r0_body.cx0_44.mlx PRE_first_tail_x15_r0_body.cx1_44.mlx (⟨19061, 16159, 2709003, 1936⟩ : Conv.Cnt) PRE_first_tail_x15_r0_body.clo44 PRE_first_tail_x15_r0_body.cln44 PRE_first_tail_x15_r0_body.cli44 PRE_first_tail_x15_r0_body.cwS44 PRE_first_tail_x15_r0_body.cnS44 PRE_first_tail_x15_r0_body.ciS44 :=
  ⟨rfl, rfl, rfl, PRE_first_tail_x15_r0_body.cnh044, PRE_first_tail_x15_r0_body.cnh144, PRE_first_tail_x15_r0_body.cnn044, PRE_first_tail_x15_r0_body.cnn144, PRE_first_tail_x15_r0_body.cplo44, PRE_first_tail_x15_r0_body.ccnt44, PRE_first_tail_x15_r0_body.cnband44, PRE_first_tail_x15_r0_body.chbelow44, PRE_first_tail_x15_r0_body.chren44, PRE_first_tail_x15_r0_body.cband44, PRE_first_tail_x15_r0_body.cnh1pos44, PRE_first_tail_x15_r0_body.cnren44, PRE_first_tail_x15_r0_body.cnlow44, PRE_first_tail_x15_r0_body.cabs0a44, PRE_first_tail_x15_r0_body.cabs0b44, PRE_first_tail_x15_r0_body.ctok144, PRE_first_tail_x15_r0_body.cpend44, PRE_first_tail_x15_r0_body.cerrh44, PRE_first_tail_x15_r0_body.cfiles44, PRE_first_tail_x15_r0_body.carch44, PRE_first_tail_x15_r0_body.csizes44, PRE_first_tail_x15_r0_body.cwired44, PRE_first_tail_x15_r0_body.cfix44, clean, PRE_first_tail_x15_r0_body.fcxn44, PRE_first_tail_x15_r0_body.fcnn44, hltC, nltC, itemsC, tracedC, cl, PRE_first_tail_x15_r0_body.fle044, PRE_first_tail_x15_r0_body.fnk44, PRE_first_tail_x15_r0_body.ckA44, PRE_first_tail_x15_r0_body.cobjsK44, PRE_first_tail_x15_r0_body.cnodesK44, PRE_first_tail_x15_r0_body.citemsK44, PRE_first_tail_x15_r0_body.f1A44, PRE_first_tail_x15_r0_body.f1O44, PRE_first_tail_x15_r0_body.f1N44, PRE_first_tail_x15_r0_body.f1I44, PRE_first_tail_x15_r0_body.fbd44, PRE_first_tail_x15_r0_body.fincW44, PRE_first_tail_x15_r0_body.fincI44, PRE_first_tail_x15_r0_body.fincN44, PRE_first_tail_x15_r0_body.flnF44, PRE_first_tail_x15_r0_body.fh44, PRE_first_tail_x15_r0_body.fo44, PRE_first_tail_x15_r0_body.fok44, PRE_first_tail_x15_r0_body.fnd44, PRE_first_tail_x15_r0_body.fp44, PRE_first_tail_x15_r0_body.fnord44, PRE_first_tail_x15_r0_body.fi44, PRE_first_tail_x15_r0_body.fii44⟩
theorem PRE_first_tail_x15_r0_body.cnshift44 (clean : Conv.NClean (⟨19061, 16159, 2709003, 1936⟩ : Conv.Cnt) (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s431.ffi).mlx) (hltC : ∀ h, PH (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s431.ffi).mlx h → h < (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s431.ffi).mlx.next) (nltC : ∀ i, PN (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s431.ffi).mlx i → i < (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s431.ffi).mlx.nnext) (itemsC : ∀ k v, (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s431.ffi).mlx.items.get k = some v → PN (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s431.ffi).mlx k) (tracedC : ∀ h o, (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s431.ffi).mlx.objs.get h = some o → ∀ i ∈ objTraces o, i < PRE_first_tail_x15_r0_body.P44.NL) (cl : SSt (· < 1936) PRE_first_tail_x15_r0_body.cx0_44.mlx) : NShift PRE_first_tail_x15_r0_body.P44 1936 PRE_first_tail_x15_r0_body.kappa44 PRE_first_tail_x15_r0_body.cx0_44 PRE_first_tail_x15_r0_body.cx1_44 :=
  Conv.nshift_of_foot (PRE_first_tail_x15_r0_body.cfoot44 clean hltC nltC itemsC tracedC cl) PRE_first_tail_x15_r0_body.chost44 (compact_a_eq PRE_first_tail_x15_r0_body.ckn044 PRE_first_tail_x15_r0_body.ckn144 PRE_first_tail_x15_r0_body.ckheap44 PRE_first_tail_x15_r0_body.ckpl44)

-- the observers: the layers' states at the call, the canonical and the merged state, their footprints and checks
noncomputable def PRE_first_tail_x15_r0_body.fxC_44 : PTrie Unit := (Host.Ts.Sim.Full.freedOf PRE_first_tail_x15_r0_body.s431.ffi).getD PTrie.nil
noncomputable def PRE_first_tail_x15_r0_body.krC_44 : Host.Load.Layers.KRec := (Host.Ts.Sim.Full.krecOf PRE_first_tail_x15_r0_body.s431.ffi).getD Host.Load.Layers.KRec.empty
kernel_rfl PRE_first_tail_x15_r0_body.ofxC_44 : (Host.Ts.Sim.Full.freedOf PRE_first_tail_x15_r0_body.s431.ffi) = some PRE_first_tail_x15_r0_body.fxC_44
kernel_rfl PRE_first_tail_x15_r0_body.okrC_44 : (Host.Ts.Sim.Full.krecOf PRE_first_tail_x15_r0_body.s431.ffi) = some PRE_first_tail_x15_r0_body.krC_44
noncomputable def PRE_first_tail_x15_r0_body.fx0_44 : PTrie Unit := (Host.Ts.Sim.Full.freedOf PRE_first_tail_x15_r0_body.s433.ffi).getD PTrie.nil
noncomputable def PRE_first_tail_x15_r0_body.kr0_44 : Host.Load.Layers.KRec := (Host.Ts.Sim.Full.krecOf PRE_first_tail_x15_r0_body.s433.ffi).getD Host.Load.Layers.KRec.empty
kernel_rfl PRE_first_tail_x15_r0_body.ofx0_44 : (Host.Ts.Sim.Full.freedOf PRE_first_tail_x15_r0_body.s433.ffi) = some PRE_first_tail_x15_r0_body.fx0_44
kernel_rfl PRE_first_tail_x15_r0_body.okr0_44 : (Host.Ts.Sim.Full.krecOf PRE_first_tail_x15_r0_body.s433.ffi) = some PRE_first_tail_x15_r0_body.kr0_44
noncomputable def PRE_first_tail_x15_r0_body.fx1_44 : PTrie Unit := (Host.Ts.Sim.Full.freedOf PRE_first_tail_x15_r0_body.s432.ffi).getD PTrie.nil
noncomputable def PRE_first_tail_x15_r0_body.kr1_44 : Host.Load.Layers.KRec := (Host.Ts.Sim.Full.krecOf PRE_first_tail_x15_r0_body.s432.ffi).getD Host.Load.Layers.KRec.empty
kernel_rfl PRE_first_tail_x15_r0_body.ofx1_44 : (Host.Ts.Sim.Full.freedOf PRE_first_tail_x15_r0_body.s432.ffi) = some PRE_first_tail_x15_r0_body.fx1_44
kernel_rfl PRE_first_tail_x15_r0_body.okr1_44 : (Host.Ts.Sim.Full.krecOf PRE_first_tail_x15_r0_body.s432.ffi) = some PRE_first_tail_x15_r0_body.kr1_44
kernel_rfl PRE_first_tail_x15_r0_body.ff044 : PRE_first_tail_x15_r0_body.fx0_44 = Stage.setAll PRE_first_tail_x15_r0_body.fxC_44 (PRE_first_tail_x15_r0_body.clo44.filterMap fun i => (PRE_first_tail_x15_r0_body.fx0_44.get i).map (i, ·))
kernel_rfl PRE_first_tail_x15_r0_body.ff144 : PRE_first_tail_x15_r0_body.fx1_44 = Stage.setAll PRE_first_tail_x15_r0_body.fxC_44 (PRE_first_tail_x15_r0_body.cwS44.filterMap fun i => (PRE_first_tail_x15_r0_body.fx1_44.get i).map (i, ·))
kernel_rfl PRE_first_tail_x15_r0_body.ffck44 : freedLB PRE_first_tail_x15_r0_body.kappa44 PRE_first_tail_x15_r0_body.cx0_44.mlx PRE_first_tail_x15_r0_body.fx0_44 PRE_first_tail_x15_r0_body.fx1_44 PRE_first_tail_x15_r0_body.clo44 = true
kernel_rfl PRE_first_tail_x15_r0_body.fkf044 : PRE_first_tail_x15_r0_body.kr0_44.flags = Stage.setAll PRE_first_tail_x15_r0_body.krC_44.flags (PRE_first_tail_x15_r0_body.clo44.filterMap fun i => (PRE_first_tail_x15_r0_body.kr0_44.flags.get i).map (i, ·))
kernel_rfl PRE_first_tail_x15_r0_body.fkt044 : PRE_first_tail_x15_r0_body.kr0_44.targs = Stage.setAll PRE_first_tail_x15_r0_body.krC_44.targs (PRE_first_tail_x15_r0_body.clo44.filterMap fun i => (PRE_first_tail_x15_r0_body.kr0_44.targs.get i).map (i, ·))
kernel_rfl PRE_first_tail_x15_r0_body.fkf144 : PRE_first_tail_x15_r0_body.kr1_44.flags = Stage.setAll PRE_first_tail_x15_r0_body.krC_44.flags (PRE_first_tail_x15_r0_body.cwS44.filterMap fun i => (PRE_first_tail_x15_r0_body.kr1_44.flags.get i).map (i, ·))
kernel_rfl PRE_first_tail_x15_r0_body.fkt144 : PRE_first_tail_x15_r0_body.kr1_44.targs = Stage.setAll PRE_first_tail_x15_r0_body.krC_44.targs (PRE_first_tail_x15_r0_body.cwS44.filterMap fun i => (PRE_first_tail_x15_r0_body.kr1_44.targs.get i).map (i, ·))
kernel_rfl PRE_first_tail_x15_r0_body.fkck44 : krecLB PRE_first_tail_x15_r0_body.kappa44 1936 PRE_first_tail_x15_r0_body.cx0_44.mlx PRE_first_tail_x15_r0_body.kr0_44 PRE_first_tail_x15_r0_body.kr1_44 PRE_first_tail_x15_r0_body.clo44 = true
kernel_rfl PRE_first_tail_x15_r0_body.fkn44 : Nat.ble 1936 1936 = true
-- the bridge and the pending traces' regions
kernel_rfl PRE_first_tail_x15_r0_body.cbridge44 : Host.Ts.Sim.Full.bridgeOf PRE_first_tail_x15_r0_body.s432.ffi = Host.Ts.Sim.Full.bridgeOf PRE_first_tail_x15_r0_body.s433.ffi
kernel_rfl PRE_first_tail_x15_r0_body.cpendR44 : pendRegB PRE_first_tail_x15_r0_body.kappa44 (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s433.ffi).mlx = true
kernel_rfl PRE_first_tail_x15_r0_body.cpendLe44 : Nat.ble (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s433.ffi).mlx.next (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s432.ffi).mlx.next = true
/-- **The compaction's native shift**, given the call's bookkeeping, its relation's facts (the model's and the
observers') and the canonical closedness. -/
theorem PRE_first_tail_x15_r0_body.cshift44 (clean : Conv.NClean (⟨19061, 16159, 2709003, 1936⟩ : Conv.Cnt) (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s431.ffi).mlx) (hltC : ∀ h, PH (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s431.ffi).mlx h → h < (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s431.ffi).mlx.next) (nltC : ∀ i, PN (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s431.ffi).mlx i → i < (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s431.ffi).mlx.nnext) (itemsC : ∀ k v, (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s431.ffi).mlx.items.get k = some v → PN (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s431.ffi).mlx k) (tracedC : ∀ h o, (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s431.ffi).mlx.objs.get h = some o → ∀ i ∈ objTraces o, i < PRE_first_tail_x15_r0_body.P44.NL) (cl : SSt (· < 1936) PRE_first_tail_x15_r0_body.cx0_44.mlx)
    (hobjC : ∀ h, PRE_first_tail_x15_r0_body.fxC_44.get h = some () → ((Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s431.ffi).mlx.objs.get h).isSome = true)
    (hfC : ∀ h, (PRE_first_tail_x15_r0_body.krC_44.flags.get h).isSome = true → ((Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s431.ffi).mlx.objs.get h).isSome = true)
    (htC : ∀ h, (PRE_first_tail_x15_r0_body.krC_44.targs.get h).isSome = true → ((Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s431.ffi).mlx.objs.get h).isSome = true)
    (hclC : ∀ h l, PRE_first_tail_x15_r0_body.krC_44.targs.get h = some l → Host.Ts.Sim.Full.STargs (· < (⟨19061, 16159, 2709003, 1936⟩ : Conv.Cnt).n) l) :
    Conv.FullShiftQ PRE_first_tail_x15_r0_body.P44 1936 PRE_first_tail_x15_r0_body.kappa44 PRE_first_tail_x15_r0_body.s433.ffi PRE_first_tail_x15_r0_body.s432.ffi :=
  ⟨PRE_first_tail_x15_r0_body.cnshift44 clean hltC nltC itemsC tracedC cl, PRE_first_tail_x15_r0_body.cqueue44, fun t ht => bSN_sound (List.all_eq_true.mp PRE_first_tail_x15_r0_body.ctokSupp44 t ht),
    PRE_first_tail_x15_r0_body.cbridge44,
    liveShift_foot (x0' := Host.Ts.Sim.Full.mlxOf PRE_first_tail_x15_r0_body.s433.ffi) (x1' := Host.Ts.Sim.Full.mlxOf PRE_first_tail_x15_r0_body.s432.ffi) (PRE_first_tail_x15_r0_body.cfoot44 clean hltC nltC itemsC tracedC cl) rfl PRE_first_tail_x15_r0_body.ofx0_44 PRE_first_tail_x15_r0_body.ofx1_44 hobjC PRE_first_tail_x15_r0_body.ff044 PRE_first_tail_x15_r0_body.ff144 PRE_first_tail_x15_r0_body.ffck44,
    kernShift_foot (x0' := Host.Ts.Sim.Full.mlxOf PRE_first_tail_x15_r0_body.s433.ffi) (x1' := Host.Ts.Sim.Full.mlxOf PRE_first_tail_x15_r0_body.s432.ffi) (PRE_first_tail_x15_r0_body.cfoot44 clean hltC nltC itemsC tracedC cl) rfl PRE_first_tail_x15_r0_body.okr0_44 PRE_first_tail_x15_r0_body.okr1_44 (Nat.le_of_ble_eq_true PRE_first_tail_x15_r0_body.fkn44) hfC htC hclC
      PRE_first_tail_x15_r0_body.fkf044 PRE_first_tail_x15_r0_body.fkt044 PRE_first_tail_x15_r0_body.fkf144 PRE_first_tail_x15_r0_body.fkt144 PRE_first_tail_x15_r0_body.fkck44,
    pendReg_of rfl PRE_first_tail_x15_r0_body.cnh044 PRE_first_tail_x15_r0_body.cnh144 (Nat.le_of_ble_eq_true PRE_first_tail_x15_r0_body.cpendLe44) PRE_first_tail_x15_r0_body.cpendR44⟩

end Host.Load.Run.Tpl
end

section -- st44/H0
set_option Elab.async false
namespace Host.Load.Run.Tpl
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
host_stream_state PRE_first_tail_x15_r0_body.st44 0
host_stream_state PRE_first_tail_x15_r0_body.st44 1
host_stream_state PRE_first_tail_x15_r0_body.st44 2
end Host.Load.Run.Tpl
end

section -- Site44
set_option Elab.async false
namespace Host.Load.Run.Tpl
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
open Host.Ts Host.Ts.Sim Host.Ts.Sim.Template

/-! Call site 44 of chain `PRE_first_tail_x15_r0_body`: `plan__g44__g45` (`plan`), the call state `PRE_first_tail_x15_r0_body.s431`, the merged state `PRE_first_tail_x15_r0_body.s432`,
the site template `PRE_first_tail_x15_r0_body.st44` (σ = `Map.id`, θ the identity at its own site), the canonical state `PRE_first_tail_x15_r0_body.s433`: the merge.
The footprint's facts are in `SiteF44`, the compaction's in `SiteC44`, `SiteK44`, `SiteNa44`, `SiteNb44`. -/

kernel_rfl PRE_first_tail_x15_r0_body.iso44 : PRE_first_tail_x15_r0_body.st44.s0 = { PRE_first_tail_x15_r0_body.s431 with stack := [] }
/-- The caller's frames at the call. -/
noncomputable def PRE_first_tail_x15_r0_body.rs44 : List Frame := PRE_first_tail_x15_r0_body.s431.stack
kernel_rfl PRE_first_tail_x15_r0_body.n0_44 : PRE_first_tail_x15_r0_body.S431.tab.length = 1936
kernel_rfl PRE_first_tail_x15_r0_body.tab0_44 : PRE_first_tail_x15_r0_body.st44.S0.tab = PRE_first_tail_x15_r0_body.S431.tab

/-- The fresh variables of the stage's results. -/
def PRE_first_tail_x15_r0_body.ws44 : List Nat := [1756, 1757, 1758]
kernel_rfl PRE_first_tail_x15_r0_body.fresh44 : (PRE_first_tail_x15_r0_body.S431.tab.all fun e => PRE_first_tail_x15_r0_body.ws44.all fun v => e.noVar v) &&
    (PRE_first_tail_x15_r0_body.S431.oracle.all fun q => PRE_first_tail_x15_r0_body.ws44.all fun v => q.noVar v) = true
kernel_rfl PRE_first_tail_x15_r0_body.mergeTab44 : PRE_first_tail_x15_r0_body.S432.tab = PRE_first_tail_x15_r0_body.S431.tab ++ Conv.resTab PRE_first_tail_x15_r0_body.ws44
kernel_rfl PRE_first_tail_x15_r0_body.mergeLen44 : PRE_first_tail_x15_r0_body.st44.S2.tab.length - PRE_first_tail_x15_r0_body.st44.S0.tab.length = 3

-- The merged state: the instance's return state with the caller's frames (`PRE_first_tail_x15_r0_body.merged44`, `merged_relB`).
kernel_rfl PRE_first_tail_x15_r0_body.mheap44 : PRE_first_tail_x15_r0_body.s432.heap = PRE_first_tail_x15_r0_body.st44.s2.heap
kernel_rfl PRE_first_tail_x15_r0_body.mnext44 : PRE_first_tail_x15_r0_body.s432.next = PRE_first_tail_x15_r0_body.st44.s2.next
kernel_rfl PRE_first_tail_x15_r0_body.mctl44 : PRE_first_tail_x15_r0_body.s432.ctl = PRE_first_tail_x15_r0_body.st44.s2.ctl
kernel_rfl PRE_first_tail_x15_r0_body.mstack44 : PRE_first_tail_x15_r0_body.s432.stack = PRE_first_tail_x15_r0_body.st44.s2.stack ++ PRE_first_tail_x15_r0_body.s431.stack
kernel_rfl PRE_first_tail_x15_r0_body.mjobs44 : PRE_first_tail_x15_r0_body.s432.jobs = PRE_first_tail_x15_r0_body.st44.s2.jobs
kernel_rfl PRE_first_tail_x15_r0_body.mffi44 : PRE_first_tail_x15_r0_body.s432.ffi = PRE_first_tail_x15_r0_body.st44.s2.ffi
kernel_rfl PRE_first_tail_x15_r0_body.mtrace44 : PRE_first_tail_x15_r0_body.s432.trace = PRE_first_tail_x15_r0_body.st44.s2.trace
kernel_rfl PRE_first_tail_x15_r0_body.mstores44 : PRE_first_tail_x15_r0_body.s432.stores = PRE_first_tail_x15_r0_body.st44.s2.stores

end Host.Load.Run.Tpl
end

section -- SiteD44
set_option Elab.async false
namespace Host.Load.Run.Tpl
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
open Host.Ts Host.Ts.Sim Host.Ts.Sim.Template

/-! The canonical results at call site 44 of chain `PRE_first_tail_x15_r0_body`: their values in the instance's end table, the references past
the call's table, the canonical variables apart from the stage's. -/

kernel_rfl PRE_first_tail_x15_r0_body.cderived44 : PRE_first_tail_x15_r0_body.nr44.map (fun r => nth? PRE_first_tail_x15_r0_body.st44.S2.tab r) =
  []
kernel_rfl PRE_first_tail_x15_r0_body.cnrLo44 : PRE_first_tail_x15_r0_body.nr44.all (Nat.ble 1936) = true
kernel_rfl PRE_first_tail_x15_r0_body.cwsDisj44 : PRE_first_tail_x15_r0_body.cws44.all (fun c => !PRE_first_tail_x15_r0_body.ws44.contains c) = true
/-- The compaction's substitution: the canonical variables to their merged values, the stage's other fresh variables
to `0` (`Conv.compactθZ`). -/
noncomputable def PRE_first_tail_x15_r0_body.cthetaZ44 : Nat → SymE := Conv.compactθZ PRE_first_tail_x15_r0_body.cws44 PRE_first_tail_x15_r0_body.crs44 PRE_first_tail_x15_r0_body.ws44

end Host.Load.Run.Tpl
end

section -- st44/Foot
set_option Elab.async false
namespace Host.Load.Run.Tpl
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
open Host.Ts Host.Ts.Sim Host.Ts.Sim.Stage Host.Ts.Sim.Template

/-! The footprint of stage `PRE_first_tail_x15_r0_body.st44`'s site template (`Conv.StageFoot`, `Conv.NFoot`): every entry of the return
state other than the written and fresh ones is the start's (kernel evaluation of the equalities). -/

/-- The written heap ranges below the start's counter. -/
def PRE_first_tail_x15_r0_body.st44.wrR : List (Nat × Nat) := []
/-- The written and fresh entries of the return state. -/
noncomputable def PRE_first_tail_x15_r0_body.st44.wrE : List (Nat × Host.Ts.HObj) :=
  rangesOf PRE_first_tail_x15_r0_body.st44.s2.heap PRE_first_tail_x15_r0_body.st44.wrR ++ freshOf PRE_first_tail_x15_r0_body.st44.s2.heap PRE_first_tail_x15_r0_body.st44.s0.next PRE_first_tail_x15_r0_body.st44.s2.next
noncomputable def PRE_first_tail_x15_r0_body.st44.wr : List Nat := PRE_first_tail_x15_r0_body.st44.wrE.map (·.1)

kernel_rfl PRE_first_tail_x15_r0_body.st44.heapFoot : PRE_first_tail_x15_r0_body.st44.s2.heap = setAll PRE_first_tail_x15_r0_body.st44.s0.heap PRE_first_tail_x15_r0_body.st44.wrE
kernel_rfl PRE_first_tail_x15_r0_body.st44.grows_check : Nat.ble PRE_first_tail_x15_r0_body.st44.s0.next PRE_first_tail_x15_r0_body.st44.s2.next = true
theorem PRE_first_tail_x15_r0_body.st44.grows : PRE_first_tail_x15_r0_body.st44.s0.next ≤ PRE_first_tail_x15_r0_body.st44.s2.next := Nat.le_of_ble_eq_true PRE_first_tail_x15_r0_body.st44.grows_check

/-- The written and fresh handles; the written readback items of old nodes. -/
def PRE_first_tail_x15_r0_body.st44.wh : List Nat := []
def PRE_first_tail_x15_r0_body.st44.wi : List Nat := []

kernel_rfl PRE_first_tail_x15_r0_body.st44.arrsFoot : (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.st44.s2.ffi).mlx.arrs = setAll (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.st44.s0.ffi).mlx.arrs (PRE_first_tail_x15_r0_body.st44.wh.filterMap fun h => ((Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.st44.s2.ffi).mlx.arrs.get h).map (h, ·))
kernel_rfl PRE_first_tail_x15_r0_body.st44.objsFoot : (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.st44.s2.ffi).mlx.objs = setAll (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.st44.s0.ffi).mlx.objs (PRE_first_tail_x15_r0_body.st44.wh.filterMap fun h => ((Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.st44.s2.ffi).mlx.objs.get h).map (h, ·))
kernel_rfl PRE_first_tail_x15_r0_body.st44.nodesFoot : (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.st44.s2.ffi).mlx.nodes = setAll (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.st44.s0.ffi).mlx.nodes (freshOf (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.st44.s2.ffi).mlx.nodes (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.st44.s0.ffi).mlx.nnext (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.st44.s2.ffi).mlx.nnext)
kernel_rfl PRE_first_tail_x15_r0_body.st44.itemsFoot : (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.st44.s2.ffi).mlx.items = setAll (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.st44.s0.ffi).mlx.items ((PRE_first_tail_x15_r0_body.st44.wi.filterMap fun i => ((Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.st44.s2.ffi).mlx.items.get i).map (i, ·)) ++
    freshOf (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.st44.s2.ffi).mlx.items (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.st44.s0.ffi).mlx.nnext (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.st44.s2.ffi).mlx.nnext)
kernel_rfl PRE_first_tail_x15_r0_body.st44.counters : (Nat.ble (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.st44.s0.ffi).mlx.next (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.st44.s2.ffi).mlx.next && Nat.ble (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.st44.s0.ffi).mlx.nnext (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.st44.s2.ffi).mlx.nnext) = true

end Host.Load.Run.Tpl
end

section -- SiteF44
set_option Elab.async false
namespace Host.Load.Run.Tpl
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
open Host.Ts Host.Ts.Sim Host.Ts.Sim.Template

/-! Call site 44 of chain `PRE_first_tail_x15_r0_body`: `Conv.site_merge`'s footprint facts. -/

kernel_rfl PRE_first_tail_x15_r0_body.wrNodupB44 : nodupT PRE_first_tail_x15_r0_body.st44.wr PTrie.nil = true
theorem PRE_first_tail_x15_r0_body.wrNodup44 : PRE_first_tail_x15_r0_body.st44.wr.Nodup := (nodupT_sound PRE_first_tail_x15_r0_body.wrNodupB44).2
kernel_rfl PRE_first_tail_x15_r0_body.wrBoundB44 : PRE_first_tail_x15_r0_body.st44.wr.all (fun b => Nat.blt (b / 4096) (4 ^ 31)) = true
theorem PRE_first_tail_x15_r0_body.wrBound44 : ∀ b ∈ PRE_first_tail_x15_r0_body.st44.wr, b / 4096 < 4 ^ 31 := fun b hb => Nat.blt_eq.mp (List.all_eq_true.mp PRE_first_tail_x15_r0_body.wrBoundB44 b hb)
noncomputable def PRE_first_tail_x15_r0_body.trFr44 := PRE_first_tail_x15_r0_body.st44.s2.trace.take 0
kernel_rfl PRE_first_tail_x15_r0_body.traceEq44 : PRE_first_tail_x15_r0_body.st44.s2.trace = PRE_first_tail_x15_r0_body.trFr44 ++ PRE_first_tail_x15_r0_body.st44.s0.trace
theorem PRE_first_tail_x15_r0_body.trace44 : ∃ fr, PRE_first_tail_x15_r0_body.st44.s2.trace = fr ++ PRE_first_tail_x15_r0_body.st44.s0.trace := ⟨_, PRE_first_tail_x15_r0_body.traceEq44⟩

-- the caller's wide frames at the instance's start (`Conv.isolateW`'s `W0` under `Map.id`) and their `WFix`
def PRE_first_tail_x15_r0_body.wide44 : List (Nat × WFrame) := [(4910, .memo [])]
kernel_rfl PRE_first_tail_x15_r0_body.wfixB44 : (PRE_first_tail_x15_r0_body.wide44.all fun p => wfixB Map.id (presentB PRE_first_tail_x15_r0_body.st44.s0) p.2) = true
theorem PRE_first_tail_x15_r0_body.wfix44 : ∀ p ∈ PRE_first_tail_x15_r0_body.wide44, WFix Map.id (Present PRE_first_tail_x15_r0_body.st44.s0) p.2 :=
  fun p hp => wfix_of (List.all_eq_true.mp PRE_first_tail_x15_r0_body.wfixB44 p hp)

end Host.Load.Run.Tpl
end

section -- SiteL44
set_option Elab.async false
namespace Host.Load.Run.Tpl
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
open Host.Ts Host.Ts.Sim Host.Ts.Sim.Template

/-! The call link's facts at call site 44 of chain `PRE_first_tail_x15_r0_body`: the instance's start server, its footprint (`Conv.StageFoot`), the
merged state `PRE_first_tail_x15_r0_body.s432`'s framed arrays as the chain start's extended (`arrExt_of`, `numRefs_of`). -/

kernel_rfl PRE_first_tail_x15_r0_body.srvO44 : PRE_first_tail_x15_r0_body.st44.S0.oracle = PRE_first_tail_x15_r0_body.st44.OR
kernel_rfl PRE_first_tail_x15_r0_body.wr0B44 : PRE_first_tail_x15_r0_body.st44.wr.all (fun b => !Nat.blt b PRE_first_tail_x15_r0_body.st44.s0.next || (PRE_first_tail_x15_r0_body.st44.s0.heap.get b).isSome) = true
theorem PRE_first_tail_x15_r0_body.stFoot44 : Conv.StageFoot PRE_first_tail_x15_r0_body.st44.wr PRE_first_tail_x15_r0_body.st44.s0 PRE_first_tail_x15_r0_body.st44.s2 :=
  stageFoot_of PRE_first_tail_x15_r0_body.st44.heapFoot PRE_first_tail_x15_r0_body.wrNodup44 PRE_first_tail_x15_r0_body.wrBound44 PRE_first_tail_x15_r0_body.wr0B44 PRE_first_tail_x15_r0_body.st44.grows

/-- **The relation at the merged state** from the relation at the merge (`Conv.site_merge`'s; `merged_relB`). -/
theorem PRE_first_tail_x15_r0_body.merged44 {FR : Map → Nat → PRE_first_tail_x15_r0_body.st44.F.S → PRE_first_tail_x15_r0_body.st44.F.S → Prop} {W : Nat → Option WFrame} {stk : List Frame} {M : Map}
    {ν : Nat → F64} {K : Host.Ts.Sim.Ctx} {S : SSrv} {t : St PRE_first_tail_x15_r0_body.st44.F.S} {C : CSrv} {n0 : Nat}
    (h : RelB PRE_first_tail_x15_r0_body.st44.F FR W stk M ν K (Conv.mergeSt Map.id (Map.id.res n0 n0) PRE_first_tail_x15_r0_body.rs44 PRE_first_tail_x15_r0_body.st44.wr PRE_first_tail_x15_r0_body.s431 PRE_first_tail_x15_r0_body.st44.s2 PRE_first_tail_x15_r0_body.st44.s0
      PRE_first_tail_x15_r0_body.st44.s2.ffi) S t C) : RelB PRE_first_tail_x15_r0_body.st44.F FR W stk M ν K PRE_first_tail_x15_r0_body.s432 S t C :=
  merged_relB PRE_first_tail_x15_r0_body.iso44 PRE_first_tail_x15_r0_body.stFoot44 PRE_first_tail_x15_r0_body.wrNodup44 PRE_first_tail_x15_r0_body.wrBound44 PRE_first_tail_x15_r0_body.trace44 PRE_first_tail_x15_r0_body.mheap44
    PRE_first_tail_x15_r0_body.mnext44 PRE_first_tail_x15_r0_body.mctl44 PRE_first_tail_x15_r0_body.mstack44 PRE_first_tail_x15_r0_body.mjobs44 PRE_first_tail_x15_r0_body.mffi44 PRE_first_tail_x15_r0_body.mtrace44 PRE_first_tail_x15_r0_body.mstores44 h

def PRE_first_tail_x15_r0_body.arrEl44_2665 : List Val := []
kernel_rfl PRE_first_tail_x15_r0_body.arrE44_2665 : arrOf PRE_first_tail_x15_r0_body.s432 2665 = arrOf PRE_first_tail_x15_r0_body.s0 2665 ++ PRE_first_tail_x15_r0_body.arrEl44_2665
kernel_rfl PRE_first_tail_x15_r0_body.arrA44_2665 : isArrB PRE_first_tail_x15_r0_body.s432 2665 = true
theorem PRE_first_tail_x15_r0_body.arr44_2665 : ∃ o, PRE_first_tail_x15_r0_body.s432.heap.get 2665 = some (.obj o) ∧ o.kind = .array (arrOf PRE_first_tail_x15_r0_body.s0 2665 ++ PRE_first_tail_x15_r0_body.arrEl44_2665) :=
  arrExt_of PRE_first_tail_x15_r0_body.arrE44_2665 PRE_first_tail_x15_r0_body.arrA44_2665
kernel_rfl PRE_first_tail_x15_r0_body.arrN44_2665 : numRefsB PRE_first_tail_x15_r0_body.S0.tab.length PRE_first_tail_x15_r0_body.arrEl44_2665 = true
theorem PRE_first_tail_x15_r0_body.arrR44_2665 : Prefill.NumRefs PRE_first_tail_x15_r0_body.S0.tab.length PRE_first_tail_x15_r0_body.arrEl44_2665 := numRefs_of PRE_first_tail_x15_r0_body.arrN44_2665

def PRE_first_tail_x15_r0_body.arrEl44_2673467 : List Val := []
kernel_rfl PRE_first_tail_x15_r0_body.arrE44_2673467 : arrOf PRE_first_tail_x15_r0_body.s432 2673467 = arrOf PRE_first_tail_x15_r0_body.s0 2673467 ++ PRE_first_tail_x15_r0_body.arrEl44_2673467
kernel_rfl PRE_first_tail_x15_r0_body.arrA44_2673467 : isArrB PRE_first_tail_x15_r0_body.s432 2673467 = true
theorem PRE_first_tail_x15_r0_body.arr44_2673467 : ∃ o, PRE_first_tail_x15_r0_body.s432.heap.get 2673467 = some (.obj o) ∧ o.kind = .array (arrOf PRE_first_tail_x15_r0_body.s0 2673467 ++ PRE_first_tail_x15_r0_body.arrEl44_2673467) :=
  arrExt_of PRE_first_tail_x15_r0_body.arrE44_2673467 PRE_first_tail_x15_r0_body.arrA44_2673467
kernel_rfl PRE_first_tail_x15_r0_body.arrN44_2673467 : numRefsB PRE_first_tail_x15_r0_body.S0.tab.length PRE_first_tail_x15_r0_body.arrEl44_2673467 = true
theorem PRE_first_tail_x15_r0_body.arrR44_2673467 : Prefill.NumRefs PRE_first_tail_x15_r0_body.S0.tab.length PRE_first_tail_x15_r0_body.arrEl44_2673467 := numRefs_of PRE_first_tail_x15_r0_body.arrN44_2673467

kernel_rfl PRE_first_tail_x15_r0_body.w4910k44 : isArrB PRE_first_tail_x15_r0_body.s432 4910 = false
theorem PRE_first_tail_x15_r0_body.keep44 (q : List Val) : Host.Ts.Sim.Prefill.KeepsAtW (framesP PRE_first_tail_x15_r0_body.s0 q) PRE_first_tail_x15_r0_body.s432 := by
  intro a pre pre' hx o es ho hk
  unfold framesP at hx
  simp only at hx
  cases h1 : Nat.beq a 2665
  · cases h2 : Nat.beq a 4910
    · rw [h1, h2] at hx; cases hx
    · have := Nat.eq_of_beq_eq_true h2; subst this
      rw [h1, h2] at hx; cases hx
      exact (notArr_of PRE_first_tail_x15_r0_body.w4910k44 ho hk).elim
  · have := Nat.eq_of_beq_eq_true h1; subst this
    rw [h1] at hx; cases hx
    obtain ⟨o', ho', hk'⟩ := PRE_first_tail_x15_r0_body.arr44_2665
    rw [ho] at ho'; cases ho'
    rw [hk'] at hk; cases hk
    simp [PRE_first_tail_x15_r0_body.arrEl44_2665]

end Host.Load.Run.Tpl
end

section -- SiteZ44
set_option Elab.async false
namespace Host.Load.Run.Tpl
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
open Host.Ts Host.Ts.Sim Host.Ts.Sim.Template

/-! The compaction's state shift at call site 44 of chain `PRE_first_tail_x15_r0_body` (`Conv.compact_shift`): the call `PRE_first_tail_x15_r0_body.s431`, the merged
state `PRE_first_tail_x15_r0_body.s432`, the canonical state `PRE_first_tail_x15_r0_body.s433`; its frames [2665,2673467,2673472,2673473] (kept arrays [2665,2673467]). -/

-- the map's places and counters
kernel_rfl PRE_first_tail_x15_r0_body.zpl44 : PRE_first_tail_x15_r0_body.pl44.all (Nat.ble PRE_first_tail_x15_r0_body.s431.next) = true
kernel_rfl PRE_first_tail_x15_r0_body.zplnd44 : nodupT PRE_first_tail_x15_r0_body.pl44 PTrie.nil = true
kernel_rfl PRE_first_tail_x15_r0_body.zn144 : Nat.ble PRE_first_tail_x15_r0_body.s431.next 2709014 = true
kernel_rfl PRE_first_tail_x15_r0_body.zfirst44 : Nat.ble aFirst PRE_first_tail_x15_r0_body.s431.next = true
kernel_rfl PRE_first_tail_x15_r0_body.zscn44 : PRE_first_tail_x15_r0_body.s433.next = PRE_first_tail_x15_r0_body.s431.next + PRE_first_tail_x15_r0_body.pl44.length
kernel_rfl PRE_first_tail_x15_r0_body.zsmn44 : PRE_first_tail_x15_r0_body.s432.next = 2709014
kernel_rfl PRE_first_tail_x15_r0_body.zgrow44 : Nat.ble PRE_first_tail_x15_r0_body.s433.next PRE_first_tail_x15_r0_body.s432.next = true
-- the tables
kernel_rfl PRE_first_tail_x15_r0_body.zfresh44 : PRE_first_tail_x15_r0_body.S431.tab.all (fun e => PRE_first_tail_x15_r0_body.cws44.all fun v => e.noVar v) = true
kernel_rfl PRE_first_tail_x15_r0_body.zcnd44 : nodupT PRE_first_tail_x15_r0_body.cws44 PTrie.nil = true
kernel_rfl PRE_first_tail_x15_r0_body.znrHi44 : PRE_first_tail_x15_r0_body.nr44.all (fun r => Nat.blt r PRE_first_tail_x15_r0_body.S432.tab.length) = true
-- the frames: every framed address below the call's counter; the kept arrays the chain start's, extended in the merged state
kernel_rfl PRE_first_tail_x15_r0_body.zfrlt44 : [2665, 2673467, 2673472, 2673473].all (fun a => Nat.blt a PRE_first_tail_x15_r0_body.s431.next) = true
kernel_rfl PRE_first_tail_x15_r0_body.zg44_2665 : PRE_first_tail_x15_r0_body.s433.heap.get 2665 = some (.obj (objOf PRE_first_tail_x15_r0_body.s433 2665))
kernel_rfl PRE_first_tail_x15_r0_body.zk44_2665 : (objOf PRE_first_tail_x15_r0_body.s433 2665).kind = .array (arrOf PRE_first_tail_x15_r0_body.s0 2665)
kernel_rfl PRE_first_tail_x15_r0_body.zm44_2665 : PRE_first_tail_x15_r0_body.s432.heap.get 2665 = some (.obj { PRE_first_tail_x15_r0_body.kappa44.obj (objOf PRE_first_tail_x15_r0_body.s433 2665) with
  kind := .array (arrOf PRE_first_tail_x15_r0_body.s0 2665 ++ (arrOf PRE_first_tail_x15_r0_body.s432 2665).drop (arrOf PRE_first_tail_x15_r0_body.s0 2665).length) })
kernel_rfl PRE_first_tail_x15_r0_body.zg44_2673467 : PRE_first_tail_x15_r0_body.s433.heap.get 2673467 = some (.obj (objOf PRE_first_tail_x15_r0_body.s433 2673467))
kernel_rfl PRE_first_tail_x15_r0_body.zk44_2673467 : (objOf PRE_first_tail_x15_r0_body.s433 2673467).kind = .array (arrOf PRE_first_tail_x15_r0_body.s0 2673467)
kernel_rfl PRE_first_tail_x15_r0_body.zm44_2673467 : PRE_first_tail_x15_r0_body.s432.heap.get 2673467 = some (.obj { PRE_first_tail_x15_r0_body.kappa44.obj (objOf PRE_first_tail_x15_r0_body.s433 2673467) with
  kind := .array (arrOf PRE_first_tail_x15_r0_body.s0 2673467 ++ (arrOf PRE_first_tail_x15_r0_body.s432 2673467).drop (arrOf PRE_first_tail_x15_r0_body.s0 2673467).length) })
kernel_rfl PRE_first_tail_x15_r0_body.zw44_4910 : (PRE_first_tail_x15_r0_body.s433.heap.get 4910).isSome = true
kernel_rfl PRE_first_tail_x15_r0_body.zw44_2673472 : (PRE_first_tail_x15_r0_body.s433.heap.get 2673472).isSome = true
kernel_rfl PRE_first_tail_x15_r0_body.zw44_2673473 : (PRE_first_tail_x15_r0_body.s433.heap.get 2673473).isSome = true
-- the heap: the changed list in range, holding the stage's written and fresh addresses; the canonical side's image
kernel_rfl PRE_first_tail_x15_r0_body.zclbd44 : PRE_first_tail_x15_r0_body.cl44.all (fun b => Nat.blt (b / 4096) (4 ^ 31)) = true
kernel_rfl PRE_first_tail_x15_r0_body.zwr44 : PRE_first_tail_x15_r0_body.st44.wr.all (fun b => !Nat.blt b PRE_first_tail_x15_r0_body.s431.next || PRE_first_tail_x15_r0_body.cl44.contains b) = true
def PRE_first_tail_x15_r0_body.zl44 : List Nat := PRE_first_tail_x15_r0_body.cl44.filter fun a => !(List.contains [2665, 2673467] a)
kernel_rfl PRE_first_tail_x15_r0_body.zimgE44 : PRE_first_tail_x15_r0_body.zl44.map (fun a => PRE_first_tail_x15_r0_body.s432.heap.get (PRE_first_tail_x15_r0_body.kappa44.a a)) = PRE_first_tail_x15_r0_body.zl44.map (fun a => (PRE_first_tail_x15_r0_body.s433.heap.get a).map PRE_first_tail_x15_r0_body.kappa44.hobj)
theorem PRE_first_tail_x15_r0_body.zimg44 : HeapImg PRE_first_tail_x15_r0_body.kappa44 PRE_first_tail_x15_r0_body.s433 PRE_first_tail_x15_r0_body.s432 PRE_first_tail_x15_r0_body.zl44 := PRE_first_tail_x15_r0_body.zimgE44
-- the roots and their supports
kernel_rfl PRE_first_tail_x15_r0_body.zctl44 : PRE_first_tail_x15_r0_body.s432.ctl = PRE_first_tail_x15_r0_body.kappa44.ctl PRE_first_tail_x15_r0_body.s433.ctl
kernel_rfl PRE_first_tail_x15_r0_body.zstack44 : PRE_first_tail_x15_r0_body.s432.stack = PRE_first_tail_x15_r0_body.s433.stack.map PRE_first_tail_x15_r0_body.kappa44.frame
kernel_rfl PRE_first_tail_x15_r0_body.zjobs44 : PRE_first_tail_x15_r0_body.s432.jobs = PRE_first_tail_x15_r0_body.s433.jobs.map PRE_first_tail_x15_r0_body.kappa44.job
kernel_rfl PRE_first_tail_x15_r0_body.zstores44 : PRE_first_tail_x15_r0_body.s432.stores = PRE_first_tail_x15_r0_body.kappa44.stores PRE_first_tail_x15_r0_body.s433.stores
kernel_rfl PRE_first_tail_x15_r0_body.zroots44 : checkRootsSupp PRE_first_tail_x15_r0_body.s433 1936 = true
kernel_rfl PRE_first_tail_x15_r0_body.znC44 : PRE_first_tail_x15_r0_body.S431.tab.length + PRE_first_tail_x15_r0_body.cws44.length = 1936
-- the map as `Conv.compact_shift` states it (the call's counters for the literals)
kernel_rfl PRE_first_tail_x15_r0_body.zkap44 : PRE_first_tail_x15_r0_body.kappa44 = Conv.Map.compact PRE_first_tail_x15_r0_body.s431.next 2709014 PRE_first_tail_x15_r0_body.S431.tab.length PRE_first_tail_x15_r0_body.pl44 (PRE_first_tail_x15_r0_body.nr44.map NumV.ref) PRE_first_tail_x15_r0_body.kd44.big
  PRE_first_tail_x15_r0_body.kd44.region PRE_first_tail_x15_r0_body.kd44.nodeF
-- the bridge inactive at the canonical state (`Conv.FullShiftQ.toX`; the merged state's bridge is the canonical's: cbridge)
theorem PRE_first_tail_x15_r0_body.zbin44 : (Host.Ts.Sim.Full.bridgeOf PRE_first_tail_x15_r0_body.s433.ffi).active = false := (Host.Load.Boot.replay_active Host.Load.Run.Prompt.P.oblog2818)
-- the JS bookkeeping's step (`Conv.JClean.step` over the changed list) and the canonical roots' bigint freedom
kernel_rfl PRE_first_tail_x15_r0_body.zjc44 : Conv.jcleanListB (⟨19061, 16159, 2709004, 1936⟩ : Conv.Cnt) PRE_first_tail_x15_r0_body.s433 PRE_first_tail_x15_r0_body.cl44 = true
kernel_rfl PRE_first_tail_x15_r0_body.zrootsB44 : noBigRootsP (fun i => !Conv.oldBigB (⟨19061, 16159, 2709004, 1936⟩ : Conv.Cnt) i) PRE_first_tail_x15_r0_body.s433.trace PRE_first_tail_x15_r0_body.s433 = true
kernel_rfl PRE_first_tail_x15_r0_body.zhm44 : Nat.ble (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s0.ffi).mlx.nnext 16159 = true
theorem PRE_first_tail_x15_r0_body.cjcl44 (h : Conv.JClean (⟨19061, 16159, 2709003, 1936⟩ : Conv.Cnt) PRE_first_tail_x15_r0_body.s431) : Conv.JClean (⟨19061, 16159, 2709004, 1936⟩ : Conv.Cnt) PRE_first_tail_x15_r0_body.s433 :=
  Conv.JClean.step h (Conv.Cnt.le_of_leB PRE_first_tail_x15_r0_body.cle44)
    (Conv.heap_off_setAll PRE_first_tail_x15_r0_body.cheap44 fun a ha => Nat.blt_eq.mp (List.all_eq_true.mp PRE_first_tail_x15_r0_body.zclbd44 a ha)) PRE_first_tail_x15_r0_body.zjc44

end Host.Load.Run.Tpl
end

section -- st44/TypedLast
set_option Elab.async false
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
namespace Host.Load.Run.Tpl
open Host.Ts Host.Ts.Sim Host.Ts.Sim.Template

boot_rfl PRE_first_tail_x15_r0_body.st44.bodyLast from PRE_first_tail_x15_r0_body.st44.s1 to PRE_first_tail_x15_r0_body.st44.s2 :
  interpS (step PRE_first_tail_x15_r0_body.st44.F PRE_first_tail_x15_r0_body.st44.s1).run PRE_first_tail_x15_r0_body.st44.S1 = some (PRE_first_tail_x15_r0_body.st44.s2, PRE_first_tail_x15_r0_body.st44.S2)
kernel_rfl PRE_first_tail_x15_r0_body.st44.bodyHalt : isHalt PRE_first_tail_x15_r0_body.st44.s1.ctl = false
kernel_rfl PRE_first_tail_x15_r0_body.st44.bodyTopCheck : noBlockTop PRE_first_tail_x15_r0_body.st44.s2.stack = true

end Host.Load.Run.Tpl
end

section -- st44/TypedOk
set_option Elab.async false
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
namespace Host.Load.Run.Tpl
open Host.Ts Host.Ts.Sim Host.Ts.Sim.Template

noncomputable def PRE_first_tail_x15_r0_body.st44.bodyOkL (bytes : List Byte) (rows : Nat) : St PRE_first_tail_x15_r0_body.st44.F.S → SSrv → Bool :=
  okLocal (Host.Ts.Sim.Compose.VWFrames.bodyOk bytes rows)

noncomputable def PRE_first_tail_x15_r0_body.st44.bodyOkLN (bytes : List Byte) (rows : Nat) : St PRE_first_tail_x15_r0_body.st44.F.S → FSrv → Bool :=
  okLocalN (Host.Ts.Sim.Compose.VWFrames.bodyOkN bytes rows)

theorem PRE_first_tail_x15_r0_body.st44.bodyOkLN_ok (bytes : List Byte) (rows : Nat) (s : St PRE_first_tail_x15_r0_body.st44.F.S) (c : FSrv) (h : c.Wf) :
    PRE_first_tail_x15_r0_body.st44.bodyOkLN bytes rows s c = PRE_first_tail_x15_r0_body.st44.bodyOkL bytes rows s c.toS :=
  okLocalN_ok (Host.Ts.Sim.Compose.VWFrames.bodyOkN_ok bytes rows) s c h

kernel_rfl PRE_first_tail_x15_r0_body.st44.bodyAccepted0 :
  (fun (bytes : List Byte) (rows : Nat) => PRE_first_tail_x15_r0_body.st44.bodyOkL bytes rows PRE_first_tail_x15_r0_body.st44.s0 PRE_first_tail_x15_r0_body.st44.S0) = fun _ _ => true

kernel_rfl PRE_first_tail_x15_r0_body.st44.bodyAccepted1 :
  (fun (bytes : List Byte) (rows : Nat) => PRE_first_tail_x15_r0_body.st44.bodyOkL bytes rows PRE_first_tail_x15_r0_body.st44.s1 PRE_first_tail_x15_r0_body.st44.S1) = fun _ _ => true

end Host.Load.Run.Tpl
end

section -- st44/TypedK0
set_option Elab.async false
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
namespace Host.Load.Run.Tpl
open Host.Ts Host.Ts.Sim Host.Ts.Sim.Template

boot_rfl PRE_first_tail_x15_r0_body.st44.bodyK0F from PRE_first_tail_x15_r0_body.st44.s0 to PRE_first_tail_x15_r0_body.st44.s1 :
  (fun (bytes : List Byte) (rows : Nat) => runOkS PRE_first_tail_x15_r0_body.st44.F (PRE_first_tail_x15_r0_body.st44.bodyOkLN bytes rows)
    ((nth? PRE_first_tail_x15_r0_body.st44.ks 0).getD 0) PRE_first_tail_x15_r0_body.st44.s0 PRE_first_tail_x15_r0_body.st44.S0) = fun _ _ => some (PRE_first_tail_x15_r0_body.st44.s1, PRE_first_tail_x15_r0_body.st44.S1)
theorem PRE_first_tail_x15_r0_body.st44.bodyK0 :
  (fun (bytes : List Byte) (rows : Nat) => runOk PRE_first_tail_x15_r0_body.st44.F (PRE_first_tail_x15_r0_body.st44.bodyOkL bytes rows)
    ((nth? PRE_first_tail_x15_r0_body.st44.ks 0).getD 0) PRE_first_tail_x15_r0_body.st44.s0 PRE_first_tail_x15_r0_body.st44.S0) = fun _ _ => some (PRE_first_tail_x15_r0_body.st44.s1, PRE_first_tail_x15_r0_body.st44.S1) :=
  runOk_fun_of_runOkS PRE_first_tail_x15_r0_body.st44.bodyOkLN_ok PRE_first_tail_x15_r0_body.st44.bodyK0F
end Host.Load.Run.Tpl
end

section -- st44/TypedTpl
set_option Elab.async false
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
namespace Host.Load.Run.Tpl
open Host.Ts Host.Ts.Sim Host.Ts.Sim.Template

theorem PRE_first_tail_x15_r0_body.st44.bodyRun (bytes : List Byte) (rows : Nat) :
    runOk PRE_first_tail_x15_r0_body.st44.F (PRE_first_tail_x15_r0_body.st44.bodyOkL bytes rows) 98 PRE_first_tail_x15_r0_body.st44.s0 PRE_first_tail_x15_r0_body.st44.S0 = some (PRE_first_tail_x15_r0_body.st44.s1, PRE_first_tail_x15_r0_body.st44.S1) :=
  (congrFun (congrFun PRE_first_tail_x15_r0_body.st44.bodyK0 bytes) rows)

theorem PRE_first_tail_x15_r0_body.st44.bodyLocal (bytes : List Byte) (rows : Nat) : ∀ s S, PRE_first_tail_x15_r0_body.st44.bodyOkL bytes rows s S = true → Disp.localB s = true := okLocal_localB

noncomputable def PRE_first_tail_x15_r0_body.st44.bodyTpl (bytes : List Byte) (rows : Nat) : Host.Ts.Sim.Stage.StageTpl PRE_first_tail_x15_r0_body.st44.F (PRE_first_tail_x15_r0_body.st44.bodyOkL bytes rows) where
  s0 := PRE_first_tail_x15_r0_body.st44.s0
  S0 := PRE_first_tail_x15_r0_body.st44.S0
  s1 := PRE_first_tail_x15_r0_body.st44.s1
  S1 := PRE_first_tail_x15_r0_body.st44.S1
  s2 := PRE_first_tail_x15_r0_body.st44.s2
  S2 := PRE_first_tail_x15_r0_body.st44.S2
  n := 98
  ok0 := congrFun (congrFun PRE_first_tail_x15_r0_body.st44.bodyAccepted0 bytes) rows
  run := PRE_first_tail_x15_r0_body.st44.bodyRun bytes rows
  ok1 := congrFun (congrFun PRE_first_tail_x15_r0_body.st44.bodyAccepted1 bytes) rows
  halt := PRE_first_tail_x15_r0_body.st44.bodyHalt
  last := PRE_first_tail_x15_r0_body.st44.bodyLast
  top := noBlockTop_sound PRE_first_tail_x15_r0_body.st44.bodyTopCheck
end Host.Load.Run.Tpl
end

section -- SiteC45
set_option Elab.async false
namespace Host.Load.Run.Tpl
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
open Host.Ts Host.Ts.Sim Host.Ts.Sim.Template

/-! The compaction after the merge at call site 45 of chain `PRE_first_tail_x15_r0_body` (`Conv.compact`, `Conv.full_compactQ`): the canonical
state `PRE_first_tail_x15_r0_body.s449` (the stage's results at canonical places, its trace the call's) under `PRE_first_tail_x15_r0_body.kappa45` into the merged state
`PRE_first_tail_x15_r0_body.s448`. -/

def PRE_first_tail_x15_r0_body.pl45 : List Nat := [2711102, 2710938, 2710990, 2711103, 2711104, 2710940, 2710992, 2711101, 2711100, 2711099, 2711098, 2711092, 2711043, 2711094, 2711045]
def PRE_first_tail_x15_r0_body.nr45 : List Nat := [2021, 2022, 2018, 2024, 2020, 2028, 2029, 2026, 2027]
/-- The native part of the compaction map (canonical → merged handles and nodes: its `big`, `region`, `nodeF`). -/
def PRE_first_tail_x15_r0_body.kd45 : RData :=
  ⟨2710755, 2711105, Stage.setAll PTrie.nil [(2710740, 2711102), (2710741, 2710938), (2710742, 2710990), (2710743, 2711103), (2710744, 2711104), (2710745, 2710940), (2710746, 2710992), (2710747, 2711101), (2710748, 2711100), (2710749, 2711099), (2710750, 2711098), (2710751, 2711092), (2710752, 2711043), (2710753, 2711094), (2710754, 2711045)], Stage.setAll PTrie.nil [(19101, 19103), (19102, 19104), (19103, 19106), (19104, 19105)],
   19105, 19107, 16193, 16193, Stage.setAll PTrie.nil [],
   Stage.setAll PTrie.nil [(2013, .ref 2021), (2014, .ref 2022), (2015, .ref 2018), (2016, .ref 2024), (2017, .ref 2020), (2018, .ref 2028), (2019, .ref 2029), (2020, .ref 2026), (2021, .ref 2027)]⟩
/-- **The compaction map.** -/
noncomputable def PRE_first_tail_x15_r0_body.kappa45 : Map :=
  Conv.Map.compact 2710740 2711105 2013 PRE_first_tail_x15_r0_body.pl45 (PRE_first_tail_x15_r0_body.nr45.map NumV.ref) PRE_first_tail_x15_r0_body.kd45.big
    PRE_first_tail_x15_r0_body.kd45.region PRE_first_tail_x15_r0_body.kd45.nodeF
/-- The canonical result variables and their images, the merged state's entries (`Conv.compactθ`). -/
def PRE_first_tail_x15_r0_body.cws45 : List Nat := [1776, 1777, 1778, 1779, 1780, 1781, 1782, 1783, 1784]
noncomputable def PRE_first_tail_x15_r0_body.crs45 : List SymE := PRE_first_tail_x15_r0_body.nr45.map fun r => (nth? PRE_first_tail_x15_r0_body.S448.tab r).getD (.var 0)
noncomputable def PRE_first_tail_x15_r0_body.ctheta45 : Nat → SymE := Conv.compactθ PRE_first_tail_x15_r0_body.cws45 PRE_first_tail_x15_r0_body.crs45
/-- The call's entries the stage wrote (renamed in the canonical state with the results). -/
def PRE_first_tail_x15_r0_body.wrB45 : List Nat := [2665, 2672415, 2673467]

kernel_rfl PRE_first_tail_x15_r0_body.ctab45 : PRE_first_tail_x15_r0_body.S449.tab = PRE_first_tail_x15_r0_body.S447.tab ++ PRE_first_tail_x15_r0_body.cws45.map SymE.var
kernel_rfl PRE_first_tail_x15_r0_body.ctrace45 : PRE_first_tail_x15_r0_body.s449.trace = PRE_first_tail_x15_r0_body.s447.trace
kernel_rfl PRE_first_tail_x15_r0_body.cnext45 : PRE_first_tail_x15_r0_body.s449.next = 2710755
kernel_rfl PRE_first_tail_x15_r0_body.ccounters45 : ((Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s449.ffi).mlx.next, (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s449.ffi).mlx.nnext) = (19105, 16193)
-- the merged state's readback queue, carried to the canonical state (`Conv.FullShiftQ.tokens`, `tokSupp`)
kernel_rfl PRE_first_tail_x15_r0_body.cqueue45 : (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s448.ffi).mlx.tokens = (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s449.ffi).mlx.tokens.map PRE_first_tail_x15_r0_body.kappa45.nv
kernel_rfl PRE_first_tail_x15_r0_body.ctokSupp45 : (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s449.ffi).mlx.tokens.all (bSN 2022) = true
-- the written and the result entries carry no bigint of the canonical fresh band [next, E) and no fresh region
kernel_rfl PRE_first_tail_x15_r0_body.cclean45 : Conv.cleanListB 19105 131072 (fun r => Nat.ble 76420 r) PRE_first_tail_x15_r0_body.s449
    (PRE_first_tail_x15_r0_body.wrB45 ++ (List.range 15).map (2710740 + ·)) = true
kernel_rfl PRE_first_tail_x15_r0_body.cbigs45 : bigsOutB 19105 131072 (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s449.ffi).mlx = true

end Host.Load.Run.Tpl
end

section -- SiteK45
set_option Elab.async false
namespace Host.Load.Run.Tpl
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
open Host.Ts Host.Ts.Sim Host.Ts.Sim.Template

/-! The canonical state's closedness from the call's (`Conv.closed_of_callB`, `Conv.sst_of_callB`): it keeps the call's entries
off the written and the result ones (`PRE_first_tail_x15_r0_body.cl45`; natively the written and result handles, the result nodes, the written
and result items), and those are checked. -/

def PRE_first_tail_x15_r0_body.cl45 : List Nat := [2665, 2672415, 2673467, 2710740, 2710741, 2710742, 2710743, 2710744, 2710745, 2710746, 2710747, 2710748, 2710749, 2710750, 2710751, 2710752, 2710753, 2710754]
def PRE_first_tail_x15_r0_body.clo45 : List Nat := [19101, 19102, 19103, 19104]
def PRE_first_tail_x15_r0_body.cln45 : List Nat := [16187, 16188, 16189, 16190, 16191, 16192]
def PRE_first_tail_x15_r0_body.cli45 : List Nat := [16187, 16188, 16189, 16190, 16191, 16192]
kernel_rfl PRE_first_tail_x15_r0_body.cheap45 : PRE_first_tail_x15_r0_body.s449.heap = Stage.setAll PRE_first_tail_x15_r0_body.s447.heap (PRE_first_tail_x15_r0_body.cl45.filterMap fun a => (PRE_first_tail_x15_r0_body.s449.heap.get a).map (a, ·))
kernel_rfl PRE_first_tail_x15_r0_body.cnextLe45 : Nat.ble PRE_first_tail_x15_r0_body.s447.next PRE_first_tail_x15_r0_body.s449.next = true
kernel_rfl PRE_first_tail_x15_r0_body.ckeepP45 : Conv.keptPresentB PRE_first_tail_x15_r0_body.s447 PRE_first_tail_x15_r0_body.s449 PRE_first_tail_x15_r0_body.cl45 = true
kernel_rfl PRE_first_tail_x15_r0_body.csupp45 : Conv.suppListB PRE_first_tail_x15_r0_body.s449 2022 PRE_first_tail_x15_r0_body.cl45 = true
kernel_rfl PRE_first_tail_x15_r0_body.cbound45 : Conv.boundListB PRE_first_tail_x15_r0_body.s449 PRE_first_tail_x15_r0_body.cl45 = true
kernel_rfl PRE_first_tail_x15_r0_body.cnodesK45 : (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s449.ffi).mlx.nodes = Stage.setAll (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s447.ffi).mlx.nodes (PRE_first_tail_x15_r0_body.cln45.filterMap fun i => ((Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s449.ffi).mlx.nodes.get i).map (i, ·))
kernel_rfl PRE_first_tail_x15_r0_body.cobjsK45 : (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s449.ffi).mlx.objs = Stage.setAll (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s447.ffi).mlx.objs (PRE_first_tail_x15_r0_body.clo45.filterMap fun i => ((Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s449.ffi).mlx.objs.get i).map (i, ·))
kernel_rfl PRE_first_tail_x15_r0_body.citemsK45 : (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s449.ffi).mlx.items = Stage.setAll (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s447.ffi).mlx.items (PRE_first_tail_x15_r0_body.cli45.filterMap fun i => ((Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s449.ffi).mlx.items.get i).map (i, ·))
kernel_rfl PRE_first_tail_x15_r0_body.csst45 : Conv.sstListB 2022 (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s449.ffi).mlx PRE_first_tail_x15_r0_body.cln45 PRE_first_tail_x15_r0_body.clo45 PRE_first_tail_x15_r0_body.cli45 = true

end Host.Load.Run.Tpl
end

section -- SiteCl45
set_option Elab.async false
namespace Host.Load.Run.Tpl
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
open Host.Ts Host.Ts.Sim Host.Ts.Sim.Template

kernel_rfl PRE_first_tail_x15_r0_body.ckA45 : (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s449.ffi).mlx.arrs = Stage.setAll (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s447.ffi).mlx.arrs (PRE_first_tail_x15_r0_body.clo45.filterMap fun i => ((Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s449.ffi).mlx.arrs.get i).map (i, ·))
kernel_rfl PRE_first_tail_x15_r0_body.cbd45 : (PRE_first_tail_x15_r0_body.clo45 ++ PRE_first_tail_x15_r0_body.cln45 ++ PRE_first_tail_x15_r0_body.cli45).all (fun i => Nat.blt (i / 4096) (4 ^ 31)) = true
kernel_rfl PRE_first_tail_x15_r0_body.cle45 : Conv.Cnt.leB (⟨19101, 16187, 2710740, 2013⟩ : Conv.Cnt) (⟨19105, 16193, 2710755, 2022⟩ : Conv.Cnt) = true
kernel_rfl PRE_first_tail_x15_r0_body.cck45 : Conv.ncleanListB (⟨19105, 16193, 2710755, 2022⟩ : Conv.Cnt) (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s449.ffi).mlx PRE_first_tail_x15_r0_body.clo45 PRE_first_tail_x15_r0_body.cln45 PRE_first_tail_x15_r0_body.cli45 = true
theorem PRE_first_tail_x15_r0_body.cncl45 (h : Conv.NClean (⟨19101, 16187, 2710740, 2013⟩ : Conv.Cnt) (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s447.ffi).mlx) : Conv.NClean (⟨19105, 16193, 2710755, 2022⟩ : Conv.Cnt) (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s449.ffi).mlx :=
  Conv.NClean.stepKeep h PRE_first_tail_x15_r0_body.cle45 PRE_first_tail_x15_r0_body.ckA45 PRE_first_tail_x15_r0_body.cobjsK45 PRE_first_tail_x15_r0_body.cnodesK45 PRE_first_tail_x15_r0_body.citemsK45 PRE_first_tail_x15_r0_body.cbd45 PRE_first_tail_x15_r0_body.cck45

end Host.Load.Run.Tpl
end

section -- SiteS45
set_option Elab.async false
namespace Host.Load.Run.Tpl
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
open Host.Ts Host.Ts.Sim Host.Ts.Sim.Template

/-! The compaction's native shift at call site 45 from its footprint (`Conv.nshift_of_foot`), and the observers'
(`liveShift_foot`, `kernShift_foot`): `Conv.FullShiftQ` for `Conv.full_compactQ`, given the call's bookkeeping and its
relation's facts. -/

/-- The load parameters of the chain (band-free: its start's node counter as `NL` and `N0`). -/
def PRE_first_tail_x15_r0_body.Pc45 : LoadP := ⟨18151, 131072, 1099511627776, 15235, 15235, []⟩
/-- The site's band raised to the map's checked fixed-node prefix, including newly recorded closure traces. -/
def PRE_first_tail_x15_r0_body.P45 : LoadP := PRE_first_tail_x15_r0_body.Pc45.raise 16193
kernel_rfl PRE_first_tail_x15_r0_body.craise45 : Nat.ble PRE_first_tail_x15_r0_body.Pc45.N0 16193 = true
theorem PRE_first_tail_x15_r0_body.raised45 : Host.Ts.Sim.Full.Raised PRE_first_tail_x15_r0_body.Pc45 PRE_first_tail_x15_r0_body.P45 :=
  .inr ⟨16193, rfl, Nat.le_of_ble_eq_true PRE_first_tail_x15_r0_body.craise45, rfl⟩
noncomputable abbrev PRE_first_tail_x15_r0_body.cx0_45 : Host.Load.LSt := clearTokens (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s449.ffi)
noncomputable abbrev PRE_first_tail_x15_r0_body.cx1_45 : Host.Load.LSt := clearTokens (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s448.ffi)
def PRE_first_tail_x15_r0_body.khinv45 : PTrie Nat := Stage.setAll PTrie.nil [(19103, 19101), (19104, 19102), (19106, 19103), (19105, 19104)]
def PRE_first_tail_x15_r0_body.kninv45 : PTrie Nat := Stage.setAll PTrie.nil [(16187, 16187), (16188, 16188), (16189, 16189), (16190, 16190), (16191, 16191), (16192, 16192)]
/-- The stage's footprint: its written and fresh handles, fresh nodes, written and fresh items. -/
def PRE_first_tail_x15_r0_body.cwS45 : List Nat := [19101, 19102, 19103, 19104, 19105, 19106]
def PRE_first_tail_x15_r0_body.cnS45 : List Nat := List.range' 16187 6
def PRE_first_tail_x15_r0_body.ciS45 : List Nat := [] ++ List.range' 16187 6

-- the small checks (`MChecks`'s)
kernel_rfl PRE_first_tail_x15_r0_body.cnh045 : PRE_first_tail_x15_r0_body.kd45.nh0 = PRE_first_tail_x15_r0_body.cx0_45.mlx.next
kernel_rfl PRE_first_tail_x15_r0_body.cnh145 : PRE_first_tail_x15_r0_body.kd45.nh1 = PRE_first_tail_x15_r0_body.cx1_45.mlx.next
kernel_rfl PRE_first_tail_x15_r0_body.cnn045 : PRE_first_tail_x15_r0_body.kd45.nn0 = PRE_first_tail_x15_r0_body.cx0_45.mlx.nnext
kernel_rfl PRE_first_tail_x15_r0_body.cnn145 : PRE_first_tail_x15_r0_body.kd45.nn1 = PRE_first_tail_x15_r0_body.cx1_45.mlx.nnext
kernel_rfl PRE_first_tail_x15_r0_body.cplo45 : (Nat.blt 0 PRE_first_tail_x15_r0_body.P45.lo && Nat.ble PRE_first_tail_x15_r0_body.P45.lo PRE_first_tail_x15_r0_body.cx0_45.mlx.next && Nat.ble PRE_first_tail_x15_r0_body.P45.lo RData.bigHi && Nat.ble RData.bigHi PRE_first_tail_x15_r0_body.P45.E) = true
kernel_rfl PRE_first_tail_x15_r0_body.ccnt45 : (Nat.ble PRE_first_tail_x15_r0_body.cx0_45.mlx.next PRE_first_tail_x15_r0_body.cx1_45.mlx.next && Nat.ble PRE_first_tail_x15_r0_body.cx0_45.mlx.nnext PRE_first_tail_x15_r0_body.cx1_45.mlx.nnext) = true
kernel_rfl PRE_first_tail_x15_r0_body.cnband45 : (Nat.blt 0 PRE_first_tail_x15_r0_body.P45.NL && Nat.ble PRE_first_tail_x15_r0_body.P45.NL PRE_first_tail_x15_r0_body.P45.N0 && Nat.ble PRE_first_tail_x15_r0_body.P45.N0 PRE_first_tail_x15_r0_body.cx0_45.mlx.nnext) = true
kernel_rfl PRE_first_tail_x15_r0_body.chbelow45 : PRE_first_tail_x15_r0_body.kd45.checkHndBelow = true
kernel_rfl PRE_first_tail_x15_r0_body.chren45 : checkRenG PRE_first_tail_x15_r0_body.kd45.hnd PRE_first_tail_x15_r0_body.khinv45 (phB PRE_first_tail_x15_r0_body.cx0_45.mlx) = true
kernel_rfl PRE_first_tail_x15_r0_body.cband45 : PRE_first_tail_x15_r0_body.kd45.checkBand PRE_first_tail_x15_r0_body.P45.lo = true
kernel_rfl PRE_first_tail_x15_r0_body.cnh1pos45 : Nat.blt 0 PRE_first_tail_x15_r0_body.kd45.nh1 = true
kernel_rfl PRE_first_tail_x15_r0_body.cnren45 : checkRenG PRE_first_tail_x15_r0_body.kd45.node PRE_first_tail_x15_r0_body.kninv45 (pnB PRE_first_tail_x15_r0_body.cx0_45.mlx) = true
kernel_rfl PRE_first_tail_x15_r0_body.cnlow45 : (PTrie.keysA PRE_first_tail_x15_r0_body.kd45.node).all (fun j => Nat.ble PRE_first_tail_x15_r0_body.P45.NL j && Nat.blt (PRE_first_tail_x15_r0_body.kd45.nodeF j) PRE_first_tail_x15_r0_body.cx1_45.mlx.nnext) = true
kernel_rfl PRE_first_tail_x15_r0_body.cabs0a45 : PRE_first_tail_x15_r0_body.cx0_45.mlx.arrs.get 0 = none
kernel_rfl PRE_first_tail_x15_r0_body.cabs0b45 : PRE_first_tail_x15_r0_body.cx0_45.mlx.objs.get 0 = none
kernel_rfl PRE_first_tail_x15_r0_body.ctok145 : PRE_first_tail_x15_r0_body.cx1_45.mlx.tokens = []
kernel_rfl PRE_first_tail_x15_r0_body.cpend45 : PRE_first_tail_x15_r0_body.cx1_45.mlx.pending = PRE_first_tail_x15_r0_body.cx0_45.mlx.pending.map PRE_first_tail_x15_r0_body.kappa45.pend
kernel_rfl PRE_first_tail_x15_r0_body.cerrh45 : PRE_first_tail_x15_r0_body.cx1_45.mlx.errh = PRE_first_tail_x15_r0_body.cx0_45.mlx.errh.map PRE_first_tail_x15_r0_body.kappa45.arg
kernel_rfl PRE_first_tail_x15_r0_body.cfiles45 : PRE_first_tail_x15_r0_body.cx1_45.mlx.files = PRE_first_tail_x15_r0_body.cx0_45.mlx.files
kernel_rfl PRE_first_tail_x15_r0_body.carch45 : PRE_first_tail_x15_r0_body.cx1_45.mlx.arch = PRE_first_tail_x15_r0_body.cx0_45.mlx.arch
kernel_rfl PRE_first_tail_x15_r0_body.csizes45 : PRE_first_tail_x15_r0_body.cx1_45.mlx.deviceSizes = PRE_first_tail_x15_r0_body.cx0_45.mlx.deviceSizes
kernel_rfl PRE_first_tail_x15_r0_body.cwired45 : PRE_first_tail_x15_r0_body.cx1_45.mlx.wired = PRE_first_tail_x15_r0_body.cx0_45.mlx.wired
kernel_rfl PRE_first_tail_x15_r0_body.chost45 : PRE_first_tail_x15_r0_body.cx1_45.host = PRE_first_tail_x15_r0_body.cx0_45.host
-- the compaction map's addresses are `PRE_first_tail_x15_r0_body.kd45`'s
kernel_rfl PRE_first_tail_x15_r0_body.ckn045 : PRE_first_tail_x15_r0_body.kd45.n0 = 2710755
kernel_rfl PRE_first_tail_x15_r0_body.ckn145 : PRE_first_tail_x15_r0_body.kd45.n1 = 2711105
kernel_rfl PRE_first_tail_x15_r0_body.ckheap45 : (PTrie.keysA PRE_first_tail_x15_r0_body.kd45.heap).all (fun x => Nat.ble 2710740 x) = true
kernel_rfl PRE_first_tail_x15_r0_body.ckpl45 : (List.range 15).all (fun j => decide (PRE_first_tail_x15_r0_body.kd45.heap.get (2710740 + j) = nth? PRE_first_tail_x15_r0_body.pl45 j)) = true
-- the map fixes the call's names (`Conv.fixOld_compact`), the call's counters
kernel_rfl PRE_first_tail_x15_r0_body.fja45 : Nat.ble 2710740 2710740 = true
kernel_rfl PRE_first_tail_x15_r0_body.fn45 : Nat.ble 2013 2013 = true
kernel_rfl PRE_first_tail_x15_r0_body.fjaD45 : Nat.ble 2710740 PRE_first_tail_x15_r0_body.kd45.n0 = true
kernel_rfl PRE_first_tail_x15_r0_body.fxn45 : Nat.ble 19101 PRE_first_tail_x15_r0_body.kd45.nh0 = true
kernel_rfl PRE_first_tail_x15_r0_body.fnn45 : Nat.ble 16187 PRE_first_tail_x15_r0_body.kd45.nn0 = true
kernel_rfl PRE_first_tail_x15_r0_body.fxb45 : Nat.ble 19101 RData.bigHi = true
kernel_rfl PRE_first_tail_x15_r0_body.fheap45 : (PTrie.keysA PRE_first_tail_x15_r0_body.kd45.heap).all (Nat.ble (⟨19101, 16187, 2710740, 2013⟩ : Conv.Cnt).ja) = true
kernel_rfl PRE_first_tail_x15_r0_body.fhnd45 : (PTrie.keysA PRE_first_tail_x15_r0_body.kd45.hnd).all (Nat.ble (⟨19101, 16187, 2710740, 2013⟩ : Conv.Cnt).xn) = true
kernel_rfl PRE_first_tail_x15_r0_body.fnode45 : (PTrie.keysA PRE_first_tail_x15_r0_body.kd45.node).all (Nat.ble (⟨19101, 16187, 2710740, 2013⟩ : Conv.Cnt).nn) = true
/-- The compaction map fixes the call's names. -/
theorem PRE_first_tail_x15_r0_body.cfix45 : Conv.FixOld (⟨19101, 16187, 2710740, 2013⟩ : Conv.Cnt) PRE_first_tail_x15_r0_body.kappa45 :=
  Conv.fixOld_compact (Nat.le_of_ble_eq_true PRE_first_tail_x15_r0_body.fja45) (Nat.le_of_ble_eq_true PRE_first_tail_x15_r0_body.fn45) (Nat.le_of_ble_eq_true PRE_first_tail_x15_r0_body.fjaD45) (Nat.le_of_ble_eq_true PRE_first_tail_x15_r0_body.fxn45) (Nat.le_of_ble_eq_true PRE_first_tail_x15_r0_body.fnn45) (Nat.le_of_ble_eq_true PRE_first_tail_x15_r0_body.fxb45) PRE_first_tail_x15_r0_body.fheap45 PRE_first_tail_x15_r0_body.fhnd45 PRE_first_tail_x15_r0_body.fnode45
kernel_rfl PRE_first_tail_x15_r0_body.fcxn45 : (⟨19101, 16187, 2710740, 2013⟩ : Conv.Cnt).xn = (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s447.ffi).mlx.next
kernel_rfl PRE_first_tail_x15_r0_body.fcnn45 : (⟨19101, 16187, 2710740, 2013⟩ : Conv.Cnt).nn = (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s447.ffi).mlx.nnext
kernel_rfl PRE_first_tail_x15_r0_body.fle045 : (Nat.ble (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s447.ffi).mlx.next PRE_first_tail_x15_r0_body.cx0_45.mlx.next && Nat.ble (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s447.ffi).mlx.nnext PRE_first_tail_x15_r0_body.cx0_45.mlx.nnext && Nat.ble (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s447.ffi).mlx.next RData.bigHi) = true
kernel_rfl PRE_first_tail_x15_r0_body.fnk45 : (PTrie.keysA PRE_first_tail_x15_r0_body.kd45.node).all (Nat.ble (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s447.ffi).mlx.nnext) = true
-- the merged state keeps the call's entries off the stage's footprint
kernel_rfl PRE_first_tail_x15_r0_body.f1A45 : PRE_first_tail_x15_r0_body.cx1_45.mlx.arrs = Stage.setAll (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s447.ffi).mlx.arrs (PRE_first_tail_x15_r0_body.cwS45.filterMap fun i => (PRE_first_tail_x15_r0_body.cx1_45.mlx.arrs.get i).map (i, ·))
kernel_rfl PRE_first_tail_x15_r0_body.f1O45 : PRE_first_tail_x15_r0_body.cx1_45.mlx.objs = Stage.setAll (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s447.ffi).mlx.objs (PRE_first_tail_x15_r0_body.cwS45.filterMap fun i => (PRE_first_tail_x15_r0_body.cx1_45.mlx.objs.get i).map (i, ·))
kernel_rfl PRE_first_tail_x15_r0_body.f1N45 : PRE_first_tail_x15_r0_body.cx1_45.mlx.nodes = Stage.setAll (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s447.ffi).mlx.nodes (PRE_first_tail_x15_r0_body.cnS45.filterMap fun i => (PRE_first_tail_x15_r0_body.cx1_45.mlx.nodes.get i).map (i, ·))
kernel_rfl PRE_first_tail_x15_r0_body.f1I45 : PRE_first_tail_x15_r0_body.cx1_45.mlx.items = Stage.setAll (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s447.ffi).mlx.items (PRE_first_tail_x15_r0_body.ciS45.filterMap fun i => (PRE_first_tail_x15_r0_body.cx1_45.mlx.items.get i).map (i, ·))
kernel_rfl PRE_first_tail_x15_r0_body.fbd45 : (PRE_first_tail_x15_r0_body.clo45 ++ PRE_first_tail_x15_r0_body.cln45 ++ PRE_first_tail_x15_r0_body.cli45 ++ PRE_first_tail_x15_r0_body.cwS45 ++ PRE_first_tail_x15_r0_body.cnS45 ++ PRE_first_tail_x15_r0_body.ciS45).all (fun i => Nat.blt (i / 4096) (4 ^ 31)) = true
kernel_rfl PRE_first_tail_x15_r0_body.fincW45 : PRE_first_tail_x15_r0_body.cwS45.all (fun h => !Nat.blt h (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s447.ffi).mlx.next || PRE_first_tail_x15_r0_body.clo45.contains h) = true
kernel_rfl PRE_first_tail_x15_r0_body.fincI45 : PRE_first_tail_x15_r0_body.ciS45.all (fun k => !Nat.blt k (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s447.ffi).mlx.nnext || PRE_first_tail_x15_r0_body.cli45.contains k) = true
kernel_rfl PRE_first_tail_x15_r0_body.fincN45 : PRE_first_tail_x15_r0_body.cnS45.all (Nat.ble (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s447.ffi).mlx.nnext) = true
kernel_rfl PRE_first_tail_x15_r0_body.flnF45 : PRE_first_tail_x15_r0_body.cln45.all (Nat.ble (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s447.ffi).mlx.nnext) = true
-- the checks over the changed lists
kernel_rfl PRE_first_tail_x15_r0_body.fh45 : PRE_first_tail_x15_r0_body.clo45.all (handleOK PRE_first_tail_x15_r0_body.kappa45 PRE_first_tail_x15_r0_body.P45.lo PRE_first_tail_x15_r0_body.cx0_45.mlx PRE_first_tail_x15_r0_body.cx1_45.mlx) = true
kernel_rfl PRE_first_tail_x15_r0_body.fo45 : PRE_first_tail_x15_r0_body.clo45.map (fun h => PRE_first_tail_x15_r0_body.cx1_45.mlx.objs.get (PRE_first_tail_x15_r0_body.kappa45.handle h)) = PRE_first_tail_x15_r0_body.clo45.map (fun h => (PRE_first_tail_x15_r0_body.cx0_45.mlx.objs.get h).map PRE_first_tail_x15_r0_body.kappa45.nobj)
kernel_rfl PRE_first_tail_x15_r0_body.fok45 : PRE_first_tail_x15_r0_body.clo45.all (objOK PRE_first_tail_x15_r0_body.kappa45 PRE_first_tail_x15_r0_body.P45.NL PRE_first_tail_x15_r0_body.cx0_45.mlx) = true
kernel_rfl PRE_first_tail_x15_r0_body.fnd45 : PRE_first_tail_x15_r0_body.cln45.all (nodeOKF PRE_first_tail_x15_r0_body.kappa45 PRE_first_tail_x15_r0_body.P45 PRE_first_tail_x15_r0_body.cx0_45.mlx PRE_first_tail_x15_r0_body.cx1_45.mlx) = true
kernel_rfl PRE_first_tail_x15_r0_body.fp45 : ((PRE_first_tail_x15_r0_body.cln45.filter (fullB PRE_first_tail_x15_r0_body.P45))).map (fun i => (PRE_first_tail_x15_r0_body.cx1_45.mlx.nodes.get (PRE_first_tail_x15_r0_body.kappa45.node i)).map Host.Mlx.Ffi.Node.prim) =
  ((PRE_first_tail_x15_r0_body.cln45.filter (fullB PRE_first_tail_x15_r0_body.P45))).map (fun i => (PRE_first_tail_x15_r0_body.cx0_45.mlx.nodes.get i).map fun nd => PRE_first_tail_x15_r0_body.kappa45.prim nd.prim)
kernel_rfl PRE_first_tail_x15_r0_body.fnordI45 : incrB PRE_first_tail_x15_r0_body.kd45.nodeF (List.range' 16187 6) = true
kernel_rfl PRE_first_tail_x15_r0_body.fnordK45 : (PTrie.keysA PRE_first_tail_x15_r0_body.kd45.node).all (fun k => Nat.ble 16187 k && Nat.blt k 16193) = true
kernel_rfl PRE_first_tail_x15_r0_body.fnordL45 : (PRE_first_tail_x15_r0_body.cln45.filter (Nat.ble PRE_first_tail_x15_r0_body.P45.N0)).all (fun i => Nat.ble i (PRE_first_tail_x15_r0_body.kd45.nodeF i) && (Nat.blt i 16193 || Nat.ble PRE_first_tail_x15_r0_body.kd45.nn0 i)) = true
theorem PRE_first_tail_x15_r0_body.fnord45 : (PRE_first_tail_x15_r0_body.cln45.filter (Nat.ble PRE_first_tail_x15_r0_body.P45.N0)).all (fun i => Nat.ble i (PRE_first_tail_x15_r0_body.kd45.nodeF i) &&
    (PTrie.keysA PRE_first_tail_x15_r0_body.kd45.node).all fun j => !Nat.blt j i || Nat.blt (PRE_first_tail_x15_r0_body.kd45.nodeF j) (PRE_first_tail_x15_r0_body.kd45.nodeF i)) = true :=
  cnord_of PRE_first_tail_x15_r0_body.cnlow45 PRE_first_tail_x15_r0_body.cnn145 PRE_first_tail_x15_r0_body.fnordI45 PRE_first_tail_x15_r0_body.fnordK45 PRE_first_tail_x15_r0_body.fnordL45
kernel_rfl PRE_first_tail_x15_r0_body.fi45 : PRE_first_tail_x15_r0_body.cli45.all (pnB PRE_first_tail_x15_r0_body.cx0_45.mlx) = true
kernel_rfl PRE_first_tail_x15_r0_body.fii45 : PRE_first_tail_x15_r0_body.cli45.all (fun k => decide (PRE_first_tail_x15_r0_body.cx1_45.mlx.items.get (PRE_first_tail_x15_r0_body.kappa45.node k) = (PRE_first_tail_x15_r0_body.cx0_45.mlx.items.get k).map PRE_first_tail_x15_r0_body.kappa45.nv)) = true
/-- **The compaction's footprint.** -/
theorem PRE_first_tail_x15_r0_body.cfoot45 (clean : Conv.NClean (⟨19101, 16187, 2710740, 2013⟩ : Conv.Cnt) (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s447.ffi).mlx) (hltC : ∀ h, PH (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s447.ffi).mlx h → h < (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s447.ffi).mlx.next) (nltC : ∀ i, PN (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s447.ffi).mlx i → i < (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s447.ffi).mlx.nnext) (itemsC : ∀ k v, (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s447.ffi).mlx.items.get k = some v → PN (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s447.ffi).mlx k) (tracedC : ∀ h o, (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s447.ffi).mlx.objs.get h = some o → ∀ i ∈ objTraces o, i < PRE_first_tail_x15_r0_body.P45.NL) (cl : SSt (· < 2022) PRE_first_tail_x15_r0_body.cx0_45.mlx) :
    Conv.MFoot PRE_first_tail_x15_r0_body.P45 2022 PRE_first_tail_x15_r0_body.kappa45 PRE_first_tail_x15_r0_body.kd45 PRE_first_tail_x15_r0_body.khinv45 PRE_first_tail_x15_r0_body.kninv45 (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s447.ffi).mlx PRE_first_tail_x15_r0_body.cx0_45.mlx PRE_first_tail_x15_r0_body.cx1_45.mlx (⟨19101, 16187, 2710740, 2013⟩ : Conv.Cnt) PRE_first_tail_x15_r0_body.clo45 PRE_first_tail_x15_r0_body.cln45 PRE_first_tail_x15_r0_body.cli45 PRE_first_tail_x15_r0_body.cwS45 PRE_first_tail_x15_r0_body.cnS45 PRE_first_tail_x15_r0_body.ciS45 :=
  ⟨rfl, rfl, rfl, PRE_first_tail_x15_r0_body.cnh045, PRE_first_tail_x15_r0_body.cnh145, PRE_first_tail_x15_r0_body.cnn045, PRE_first_tail_x15_r0_body.cnn145, PRE_first_tail_x15_r0_body.cplo45, PRE_first_tail_x15_r0_body.ccnt45, PRE_first_tail_x15_r0_body.cnband45, PRE_first_tail_x15_r0_body.chbelow45, PRE_first_tail_x15_r0_body.chren45, PRE_first_tail_x15_r0_body.cband45, PRE_first_tail_x15_r0_body.cnh1pos45, PRE_first_tail_x15_r0_body.cnren45, PRE_first_tail_x15_r0_body.cnlow45, PRE_first_tail_x15_r0_body.cabs0a45, PRE_first_tail_x15_r0_body.cabs0b45, PRE_first_tail_x15_r0_body.ctok145, PRE_first_tail_x15_r0_body.cpend45, PRE_first_tail_x15_r0_body.cerrh45, PRE_first_tail_x15_r0_body.cfiles45, PRE_first_tail_x15_r0_body.carch45, PRE_first_tail_x15_r0_body.csizes45, PRE_first_tail_x15_r0_body.cwired45, PRE_first_tail_x15_r0_body.cfix45, clean, PRE_first_tail_x15_r0_body.fcxn45, PRE_first_tail_x15_r0_body.fcnn45, hltC, nltC, itemsC, tracedC, cl, PRE_first_tail_x15_r0_body.fle045, PRE_first_tail_x15_r0_body.fnk45, PRE_first_tail_x15_r0_body.ckA45, PRE_first_tail_x15_r0_body.cobjsK45, PRE_first_tail_x15_r0_body.cnodesK45, PRE_first_tail_x15_r0_body.citemsK45, PRE_first_tail_x15_r0_body.f1A45, PRE_first_tail_x15_r0_body.f1O45, PRE_first_tail_x15_r0_body.f1N45, PRE_first_tail_x15_r0_body.f1I45, PRE_first_tail_x15_r0_body.fbd45, PRE_first_tail_x15_r0_body.fincW45, PRE_first_tail_x15_r0_body.fincI45, PRE_first_tail_x15_r0_body.fincN45, PRE_first_tail_x15_r0_body.flnF45, PRE_first_tail_x15_r0_body.fh45, PRE_first_tail_x15_r0_body.fo45, PRE_first_tail_x15_r0_body.fok45, PRE_first_tail_x15_r0_body.fnd45, PRE_first_tail_x15_r0_body.fp45, PRE_first_tail_x15_r0_body.fnord45, PRE_first_tail_x15_r0_body.fi45, PRE_first_tail_x15_r0_body.fii45⟩
theorem PRE_first_tail_x15_r0_body.cnshift45 (clean : Conv.NClean (⟨19101, 16187, 2710740, 2013⟩ : Conv.Cnt) (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s447.ffi).mlx) (hltC : ∀ h, PH (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s447.ffi).mlx h → h < (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s447.ffi).mlx.next) (nltC : ∀ i, PN (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s447.ffi).mlx i → i < (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s447.ffi).mlx.nnext) (itemsC : ∀ k v, (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s447.ffi).mlx.items.get k = some v → PN (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s447.ffi).mlx k) (tracedC : ∀ h o, (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s447.ffi).mlx.objs.get h = some o → ∀ i ∈ objTraces o, i < PRE_first_tail_x15_r0_body.P45.NL) (cl : SSt (· < 2022) PRE_first_tail_x15_r0_body.cx0_45.mlx) : NShift PRE_first_tail_x15_r0_body.P45 2022 PRE_first_tail_x15_r0_body.kappa45 PRE_first_tail_x15_r0_body.cx0_45 PRE_first_tail_x15_r0_body.cx1_45 :=
  Conv.nshift_of_foot (PRE_first_tail_x15_r0_body.cfoot45 clean hltC nltC itemsC tracedC cl) PRE_first_tail_x15_r0_body.chost45 (compact_a_eq PRE_first_tail_x15_r0_body.ckn045 PRE_first_tail_x15_r0_body.ckn145 PRE_first_tail_x15_r0_body.ckheap45 PRE_first_tail_x15_r0_body.ckpl45)

-- the observers: the layers' states at the call, the canonical and the merged state, their footprints and checks
noncomputable def PRE_first_tail_x15_r0_body.fxC_45 : PTrie Unit := (Host.Ts.Sim.Full.freedOf PRE_first_tail_x15_r0_body.s447.ffi).getD PTrie.nil
noncomputable def PRE_first_tail_x15_r0_body.krC_45 : Host.Load.Layers.KRec := (Host.Ts.Sim.Full.krecOf PRE_first_tail_x15_r0_body.s447.ffi).getD Host.Load.Layers.KRec.empty
kernel_rfl PRE_first_tail_x15_r0_body.ofxC_45 : (Host.Ts.Sim.Full.freedOf PRE_first_tail_x15_r0_body.s447.ffi) = some PRE_first_tail_x15_r0_body.fxC_45
kernel_rfl PRE_first_tail_x15_r0_body.okrC_45 : (Host.Ts.Sim.Full.krecOf PRE_first_tail_x15_r0_body.s447.ffi) = some PRE_first_tail_x15_r0_body.krC_45
noncomputable def PRE_first_tail_x15_r0_body.fx0_45 : PTrie Unit := (Host.Ts.Sim.Full.freedOf PRE_first_tail_x15_r0_body.s449.ffi).getD PTrie.nil
noncomputable def PRE_first_tail_x15_r0_body.kr0_45 : Host.Load.Layers.KRec := (Host.Ts.Sim.Full.krecOf PRE_first_tail_x15_r0_body.s449.ffi).getD Host.Load.Layers.KRec.empty
kernel_rfl PRE_first_tail_x15_r0_body.ofx0_45 : (Host.Ts.Sim.Full.freedOf PRE_first_tail_x15_r0_body.s449.ffi) = some PRE_first_tail_x15_r0_body.fx0_45
kernel_rfl PRE_first_tail_x15_r0_body.okr0_45 : (Host.Ts.Sim.Full.krecOf PRE_first_tail_x15_r0_body.s449.ffi) = some PRE_first_tail_x15_r0_body.kr0_45
noncomputable def PRE_first_tail_x15_r0_body.fx1_45 : PTrie Unit := (Host.Ts.Sim.Full.freedOf PRE_first_tail_x15_r0_body.s448.ffi).getD PTrie.nil
noncomputable def PRE_first_tail_x15_r0_body.kr1_45 : Host.Load.Layers.KRec := (Host.Ts.Sim.Full.krecOf PRE_first_tail_x15_r0_body.s448.ffi).getD Host.Load.Layers.KRec.empty
kernel_rfl PRE_first_tail_x15_r0_body.ofx1_45 : (Host.Ts.Sim.Full.freedOf PRE_first_tail_x15_r0_body.s448.ffi) = some PRE_first_tail_x15_r0_body.fx1_45
kernel_rfl PRE_first_tail_x15_r0_body.okr1_45 : (Host.Ts.Sim.Full.krecOf PRE_first_tail_x15_r0_body.s448.ffi) = some PRE_first_tail_x15_r0_body.kr1_45
kernel_rfl PRE_first_tail_x15_r0_body.ff045 : PRE_first_tail_x15_r0_body.fx0_45 = Stage.setAll PRE_first_tail_x15_r0_body.fxC_45 (PRE_first_tail_x15_r0_body.clo45.filterMap fun i => (PRE_first_tail_x15_r0_body.fx0_45.get i).map (i, ·))
kernel_rfl PRE_first_tail_x15_r0_body.ff145 : PRE_first_tail_x15_r0_body.fx1_45 = Stage.setAll PRE_first_tail_x15_r0_body.fxC_45 (PRE_first_tail_x15_r0_body.cwS45.filterMap fun i => (PRE_first_tail_x15_r0_body.fx1_45.get i).map (i, ·))
kernel_rfl PRE_first_tail_x15_r0_body.ffck45 : freedLB PRE_first_tail_x15_r0_body.kappa45 PRE_first_tail_x15_r0_body.cx0_45.mlx PRE_first_tail_x15_r0_body.fx0_45 PRE_first_tail_x15_r0_body.fx1_45 PRE_first_tail_x15_r0_body.clo45 = true
kernel_rfl PRE_first_tail_x15_r0_body.fkf045 : PRE_first_tail_x15_r0_body.kr0_45.flags = Stage.setAll PRE_first_tail_x15_r0_body.krC_45.flags (PRE_first_tail_x15_r0_body.clo45.filterMap fun i => (PRE_first_tail_x15_r0_body.kr0_45.flags.get i).map (i, ·))
kernel_rfl PRE_first_tail_x15_r0_body.fkt045 : PRE_first_tail_x15_r0_body.kr0_45.targs = Stage.setAll PRE_first_tail_x15_r0_body.krC_45.targs (PRE_first_tail_x15_r0_body.clo45.filterMap fun i => (PRE_first_tail_x15_r0_body.kr0_45.targs.get i).map (i, ·))
kernel_rfl PRE_first_tail_x15_r0_body.fkf145 : PRE_first_tail_x15_r0_body.kr1_45.flags = Stage.setAll PRE_first_tail_x15_r0_body.krC_45.flags (PRE_first_tail_x15_r0_body.cwS45.filterMap fun i => (PRE_first_tail_x15_r0_body.kr1_45.flags.get i).map (i, ·))
kernel_rfl PRE_first_tail_x15_r0_body.fkt145 : PRE_first_tail_x15_r0_body.kr1_45.targs = Stage.setAll PRE_first_tail_x15_r0_body.krC_45.targs (PRE_first_tail_x15_r0_body.cwS45.filterMap fun i => (PRE_first_tail_x15_r0_body.kr1_45.targs.get i).map (i, ·))
kernel_rfl PRE_first_tail_x15_r0_body.fkck45 : krecLB PRE_first_tail_x15_r0_body.kappa45 2022 PRE_first_tail_x15_r0_body.cx0_45.mlx PRE_first_tail_x15_r0_body.kr0_45 PRE_first_tail_x15_r0_body.kr1_45 PRE_first_tail_x15_r0_body.clo45 = true
kernel_rfl PRE_first_tail_x15_r0_body.fkn45 : Nat.ble 2013 2022 = true
-- the bridge and the pending traces' regions
kernel_rfl PRE_first_tail_x15_r0_body.cbridge45 : Host.Ts.Sim.Full.bridgeOf PRE_first_tail_x15_r0_body.s448.ffi = Host.Ts.Sim.Full.bridgeOf PRE_first_tail_x15_r0_body.s449.ffi
kernel_rfl PRE_first_tail_x15_r0_body.cpendR45 : pendRegB PRE_first_tail_x15_r0_body.kappa45 (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s449.ffi).mlx = true
kernel_rfl PRE_first_tail_x15_r0_body.cpendLe45 : Nat.ble (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s449.ffi).mlx.next (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s448.ffi).mlx.next = true
/-- **The compaction's native shift**, given the call's bookkeeping, its relation's facts (the model's and the
observers') and the canonical closedness. -/
theorem PRE_first_tail_x15_r0_body.cshift45 (clean : Conv.NClean (⟨19101, 16187, 2710740, 2013⟩ : Conv.Cnt) (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s447.ffi).mlx) (hltC : ∀ h, PH (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s447.ffi).mlx h → h < (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s447.ffi).mlx.next) (nltC : ∀ i, PN (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s447.ffi).mlx i → i < (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s447.ffi).mlx.nnext) (itemsC : ∀ k v, (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s447.ffi).mlx.items.get k = some v → PN (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s447.ffi).mlx k) (tracedC : ∀ h o, (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s447.ffi).mlx.objs.get h = some o → ∀ i ∈ objTraces o, i < PRE_first_tail_x15_r0_body.P45.NL) (cl : SSt (· < 2022) PRE_first_tail_x15_r0_body.cx0_45.mlx)
    (hobjC : ∀ h, PRE_first_tail_x15_r0_body.fxC_45.get h = some () → ((Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s447.ffi).mlx.objs.get h).isSome = true)
    (hfC : ∀ h, (PRE_first_tail_x15_r0_body.krC_45.flags.get h).isSome = true → ((Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s447.ffi).mlx.objs.get h).isSome = true)
    (htC : ∀ h, (PRE_first_tail_x15_r0_body.krC_45.targs.get h).isSome = true → ((Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s447.ffi).mlx.objs.get h).isSome = true)
    (hclC : ∀ h l, PRE_first_tail_x15_r0_body.krC_45.targs.get h = some l → Host.Ts.Sim.Full.STargs (· < (⟨19101, 16187, 2710740, 2013⟩ : Conv.Cnt).n) l) :
    Conv.FullShiftQ PRE_first_tail_x15_r0_body.P45 2022 PRE_first_tail_x15_r0_body.kappa45 PRE_first_tail_x15_r0_body.s449.ffi PRE_first_tail_x15_r0_body.s448.ffi :=
  ⟨PRE_first_tail_x15_r0_body.cnshift45 clean hltC nltC itemsC tracedC cl, PRE_first_tail_x15_r0_body.cqueue45, fun t ht => bSN_sound (List.all_eq_true.mp PRE_first_tail_x15_r0_body.ctokSupp45 t ht),
    PRE_first_tail_x15_r0_body.cbridge45,
    liveShift_foot (x0' := Host.Ts.Sim.Full.mlxOf PRE_first_tail_x15_r0_body.s449.ffi) (x1' := Host.Ts.Sim.Full.mlxOf PRE_first_tail_x15_r0_body.s448.ffi) (PRE_first_tail_x15_r0_body.cfoot45 clean hltC nltC itemsC tracedC cl) rfl PRE_first_tail_x15_r0_body.ofx0_45 PRE_first_tail_x15_r0_body.ofx1_45 hobjC PRE_first_tail_x15_r0_body.ff045 PRE_first_tail_x15_r0_body.ff145 PRE_first_tail_x15_r0_body.ffck45,
    kernShift_foot (x0' := Host.Ts.Sim.Full.mlxOf PRE_first_tail_x15_r0_body.s449.ffi) (x1' := Host.Ts.Sim.Full.mlxOf PRE_first_tail_x15_r0_body.s448.ffi) (PRE_first_tail_x15_r0_body.cfoot45 clean hltC nltC itemsC tracedC cl) rfl PRE_first_tail_x15_r0_body.okr0_45 PRE_first_tail_x15_r0_body.okr1_45 (Nat.le_of_ble_eq_true PRE_first_tail_x15_r0_body.fkn45) hfC htC hclC
      PRE_first_tail_x15_r0_body.fkf045 PRE_first_tail_x15_r0_body.fkt045 PRE_first_tail_x15_r0_body.fkf145 PRE_first_tail_x15_r0_body.fkt145 PRE_first_tail_x15_r0_body.fkck45,
    pendReg_of rfl PRE_first_tail_x15_r0_body.cnh045 PRE_first_tail_x15_r0_body.cnh145 (Nat.le_of_ble_eq_true PRE_first_tail_x15_r0_body.cpendLe45) PRE_first_tail_x15_r0_body.cpendR45⟩

end Host.Load.Run.Tpl
end

section -- st45/H0
set_option Elab.async false
namespace Host.Load.Run.Tpl
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
host_stream_state PRE_first_tail_x15_r0_body.st45 0
host_stream_state PRE_first_tail_x15_r0_body.st45 1
host_stream_state PRE_first_tail_x15_r0_body.st45 2
host_stream_state PRE_first_tail_x15_r0_body.st45 3
end Host.Load.Run.Tpl
end

section -- Site45
set_option Elab.async false
namespace Host.Load.Run.Tpl
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
open Host.Ts Host.Ts.Sim Host.Ts.Sim.Template

/-! Call site 45 of chain `PRE_first_tail_x15_r0_body`: `kvW__g45__g46` (`appendWindow`), the call state `PRE_first_tail_x15_r0_body.s447`, the merged state `PRE_first_tail_x15_r0_body.s448`,
the site template `PRE_first_tail_x15_r0_body.st45` (σ = `Map.id`, θ the identity at its own site), the canonical state `PRE_first_tail_x15_r0_body.s449`: the merge.
The footprint's facts are in `SiteF45`, the compaction's in `SiteC45`, `SiteK45`, `SiteNa45`, `SiteNb45`. -/

kernel_rfl PRE_first_tail_x15_r0_body.iso45 : PRE_first_tail_x15_r0_body.st45.s0 = { PRE_first_tail_x15_r0_body.s447 with stack := [] }
/-- The caller's frames at the call. -/
noncomputable def PRE_first_tail_x15_r0_body.rs45 : List Frame := PRE_first_tail_x15_r0_body.s447.stack
kernel_rfl PRE_first_tail_x15_r0_body.n0_45 : PRE_first_tail_x15_r0_body.S447.tab.length = 2013
kernel_rfl PRE_first_tail_x15_r0_body.tab0_45 : PRE_first_tail_x15_r0_body.st45.S0.tab = PRE_first_tail_x15_r0_body.S447.tab

/-- The fresh variables of the stage's results. -/
def PRE_first_tail_x15_r0_body.ws45 : List Nat := [1759, 1760, 1761, 1762, 1763, 1764, 1765, 1766, 1767, 1768, 1769, 1770, 1771, 1772, 1773, 1774, 1775]
kernel_rfl PRE_first_tail_x15_r0_body.fresh45 : (PRE_first_tail_x15_r0_body.S447.tab.all fun e => PRE_first_tail_x15_r0_body.ws45.all fun v => e.noVar v) &&
    (PRE_first_tail_x15_r0_body.S447.oracle.all fun q => PRE_first_tail_x15_r0_body.ws45.all fun v => q.noVar v) = true
kernel_rfl PRE_first_tail_x15_r0_body.mergeTab45 : PRE_first_tail_x15_r0_body.S448.tab = PRE_first_tail_x15_r0_body.S447.tab ++ Conv.resTab PRE_first_tail_x15_r0_body.ws45
kernel_rfl PRE_first_tail_x15_r0_body.mergeLen45 : PRE_first_tail_x15_r0_body.st45.S3.tab.length - PRE_first_tail_x15_r0_body.st45.S0.tab.length = 17

-- The merged state: the instance's return state with the caller's frames (`PRE_first_tail_x15_r0_body.merged45`, `merged_relB`).
kernel_rfl PRE_first_tail_x15_r0_body.mheap45 : PRE_first_tail_x15_r0_body.s448.heap = PRE_first_tail_x15_r0_body.st45.s3.heap
kernel_rfl PRE_first_tail_x15_r0_body.mnext45 : PRE_first_tail_x15_r0_body.s448.next = PRE_first_tail_x15_r0_body.st45.s3.next
kernel_rfl PRE_first_tail_x15_r0_body.mctl45 : PRE_first_tail_x15_r0_body.s448.ctl = PRE_first_tail_x15_r0_body.st45.s3.ctl
kernel_rfl PRE_first_tail_x15_r0_body.mstack45 : PRE_first_tail_x15_r0_body.s448.stack = PRE_first_tail_x15_r0_body.st45.s3.stack ++ PRE_first_tail_x15_r0_body.s447.stack
kernel_rfl PRE_first_tail_x15_r0_body.mjobs45 : PRE_first_tail_x15_r0_body.s448.jobs = PRE_first_tail_x15_r0_body.st45.s3.jobs
kernel_rfl PRE_first_tail_x15_r0_body.mffi45 : PRE_first_tail_x15_r0_body.s448.ffi = PRE_first_tail_x15_r0_body.st45.s3.ffi
kernel_rfl PRE_first_tail_x15_r0_body.mtrace45 : PRE_first_tail_x15_r0_body.s448.trace = PRE_first_tail_x15_r0_body.st45.s3.trace
kernel_rfl PRE_first_tail_x15_r0_body.mstores45 : PRE_first_tail_x15_r0_body.s448.stores = PRE_first_tail_x15_r0_body.st45.s3.stores

end Host.Load.Run.Tpl
end

section -- SiteD45
set_option Elab.async false
namespace Host.Load.Run.Tpl
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
open Host.Ts Host.Ts.Sim Host.Ts.Sim.Template

/-! The canonical results at call site 45 of chain `PRE_first_tail_x15_r0_body`: their values in the instance's end table, the references past
the call's table, the canonical variables apart from the stage's. -/

kernel_rfl PRE_first_tail_x15_r0_body.cderived45 : PRE_first_tail_x15_r0_body.nr45.map (fun r => nth? PRE_first_tail_x15_r0_body.st45.S3.tab r) =
  [some (SymE.bin .add (SymE.lit (F64.zero false)) (SymE.un .int32 (SymE.un .int32 (SymE.var 10)))),
   some (SymE.un .int32 (SymE.bin .add (SymE.lit (F64.zero false)) (SymE.un .int32 (SymE.un .int32 (SymE.var 10))))),
   some (SymE.un .int32 (SymE.bin .mul (SymE.un .floor (SymE.bin .div (SymE.bin .sub (SymE.bin .add (SymE.lit (F64.fin false 256 (0))) (SymE.un .int32 (SymE.un .int32 (SymE.var 10)))) (SymE.lit (F64.fin false 1 (0)))) (SymE.lit (F64.fin false 256 (0))))) (SymE.lit (F64.fin false 256 (0))))),
   some (SymE.un .int32 (SymE.bin .add (SymE.lit (F64.zero false)) (SymE.un .int32 (SymE.un .int32 (SymE.var 10))))),
   some (SymE.un .int32 (SymE.bin .mul (SymE.un .floor (SymE.bin .div (SymE.bin .sub (SymE.bin .add (SymE.lit (F64.fin false 256 (0))) (SymE.un .int32 (SymE.un .int32 (SymE.var 10)))) (SymE.lit (F64.fin false 1 (0)))) (SymE.lit (F64.fin false 256 (0))))) (SymE.lit (F64.fin false 256 (0))))),
   some (SymE.un .int32 (SymE.bin .add (SymE.lit (F64.zero false)) (SymE.un .int32 (SymE.un .int32 (SymE.var 10))))),
   some (SymE.bin .sub (SymE.un .int32 (SymE.bin .add (SymE.lit (F64.zero false)) (SymE.un .int32 (SymE.un .int32 (SymE.var 10))))) (SymE.lit (F64.zero false))),
   some (SymE.un .int32 (SymE.bin .add (SymE.lit (F64.zero false)) (SymE.un .int32 (SymE.un .int32 (SymE.var 10))))),
   some (SymE.bin .sub (SymE.un .int32 (SymE.bin .add (SymE.lit (F64.zero false)) (SymE.un .int32 (SymE.un .int32 (SymE.var 10))))) (SymE.lit (F64.zero false)))]
kernel_rfl PRE_first_tail_x15_r0_body.cnrLo45 : PRE_first_tail_x15_r0_body.nr45.all (Nat.ble 2013) = true
kernel_rfl PRE_first_tail_x15_r0_body.cwsDisj45 : PRE_first_tail_x15_r0_body.cws45.all (fun c => !PRE_first_tail_x15_r0_body.ws45.contains c) = true
/-- The compaction's substitution: the canonical variables to their merged values, the stage's other fresh variables
to `0` (`Conv.compactθZ`). -/
noncomputable def PRE_first_tail_x15_r0_body.cthetaZ45 : Nat → SymE := Conv.compactθZ PRE_first_tail_x15_r0_body.cws45 PRE_first_tail_x15_r0_body.crs45 PRE_first_tail_x15_r0_body.ws45

end Host.Load.Run.Tpl
end

section -- st45/Foot
set_option Elab.async false
namespace Host.Load.Run.Tpl
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
open Host.Ts Host.Ts.Sim Host.Ts.Sim.Stage Host.Ts.Sim.Template

/-! The footprint of stage `PRE_first_tail_x15_r0_body.st45`'s site template (`Conv.StageFoot`, `Conv.NFoot`): every entry of the return
state other than the written and fresh ones is the start's (kernel evaluation of the equalities). -/

/-- The written heap ranges below the start's counter. -/
def PRE_first_tail_x15_r0_body.st45.wrR : List (Nat × Nat) := [(2672415, 2672416)]
/-- The written and fresh entries of the return state. -/
noncomputable def PRE_first_tail_x15_r0_body.st45.wrE : List (Nat × Host.Ts.HObj) :=
  rangesOf PRE_first_tail_x15_r0_body.st45.s3.heap PRE_first_tail_x15_r0_body.st45.wrR ++ freshOf PRE_first_tail_x15_r0_body.st45.s3.heap PRE_first_tail_x15_r0_body.st45.s0.next PRE_first_tail_x15_r0_body.st45.s3.next
noncomputable def PRE_first_tail_x15_r0_body.st45.wr : List Nat := PRE_first_tail_x15_r0_body.st45.wrE.map (·.1)

kernel_rfl PRE_first_tail_x15_r0_body.st45.heapFoot : PRE_first_tail_x15_r0_body.st45.s3.heap = setAll PRE_first_tail_x15_r0_body.st45.s0.heap PRE_first_tail_x15_r0_body.st45.wrE
kernel_rfl PRE_first_tail_x15_r0_body.st45.grows_check : Nat.ble PRE_first_tail_x15_r0_body.st45.s0.next PRE_first_tail_x15_r0_body.st45.s3.next = true
theorem PRE_first_tail_x15_r0_body.st45.grows : PRE_first_tail_x15_r0_body.st45.s0.next ≤ PRE_first_tail_x15_r0_body.st45.s3.next := Nat.le_of_ble_eq_true PRE_first_tail_x15_r0_body.st45.grows_check

/-- The written and fresh handles; the written readback items of old nodes. -/
def PRE_first_tail_x15_r0_body.st45.wh : List Nat := [19101, 19102, 19103, 19104, 19105, 19106]
def PRE_first_tail_x15_r0_body.st45.wi : List Nat := []

kernel_rfl PRE_first_tail_x15_r0_body.st45.arrsFoot : (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.st45.s3.ffi).mlx.arrs = setAll (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.st45.s0.ffi).mlx.arrs (PRE_first_tail_x15_r0_body.st45.wh.filterMap fun h => ((Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.st45.s3.ffi).mlx.arrs.get h).map (h, ·))
kernel_rfl PRE_first_tail_x15_r0_body.st45.objsFoot : (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.st45.s3.ffi).mlx.objs = setAll (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.st45.s0.ffi).mlx.objs (PRE_first_tail_x15_r0_body.st45.wh.filterMap fun h => ((Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.st45.s3.ffi).mlx.objs.get h).map (h, ·))
kernel_rfl PRE_first_tail_x15_r0_body.st45.nodesFoot : (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.st45.s3.ffi).mlx.nodes = setAll (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.st45.s0.ffi).mlx.nodes (freshOf (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.st45.s3.ffi).mlx.nodes (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.st45.s0.ffi).mlx.nnext (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.st45.s3.ffi).mlx.nnext)
kernel_rfl PRE_first_tail_x15_r0_body.st45.itemsFoot : (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.st45.s3.ffi).mlx.items = setAll (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.st45.s0.ffi).mlx.items ((PRE_first_tail_x15_r0_body.st45.wi.filterMap fun i => ((Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.st45.s3.ffi).mlx.items.get i).map (i, ·)) ++
    freshOf (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.st45.s3.ffi).mlx.items (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.st45.s0.ffi).mlx.nnext (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.st45.s3.ffi).mlx.nnext)
kernel_rfl PRE_first_tail_x15_r0_body.st45.counters : (Nat.ble (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.st45.s0.ffi).mlx.next (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.st45.s3.ffi).mlx.next && Nat.ble (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.st45.s0.ffi).mlx.nnext (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.st45.s3.ffi).mlx.nnext) = true

end Host.Load.Run.Tpl
end

section -- SiteF45
set_option Elab.async false
namespace Host.Load.Run.Tpl
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
open Host.Ts Host.Ts.Sim Host.Ts.Sim.Template

/-! Call site 45 of chain `PRE_first_tail_x15_r0_body`: `Conv.site_merge`'s footprint facts. -/

kernel_rfl PRE_first_tail_x15_r0_body.wrNodupB45 : nodupT PRE_first_tail_x15_r0_body.st45.wr PTrie.nil = true
theorem PRE_first_tail_x15_r0_body.wrNodup45 : PRE_first_tail_x15_r0_body.st45.wr.Nodup := (nodupT_sound PRE_first_tail_x15_r0_body.wrNodupB45).2
kernel_rfl PRE_first_tail_x15_r0_body.wrBoundB45 : PRE_first_tail_x15_r0_body.st45.wr.all (fun b => Nat.blt (b / 4096) (4 ^ 31)) = true
theorem PRE_first_tail_x15_r0_body.wrBound45 : ∀ b ∈ PRE_first_tail_x15_r0_body.st45.wr, b / 4096 < 4 ^ 31 := fun b hb => Nat.blt_eq.mp (List.all_eq_true.mp PRE_first_tail_x15_r0_body.wrBoundB45 b hb)
noncomputable def PRE_first_tail_x15_r0_body.trFr45 := PRE_first_tail_x15_r0_body.st45.s3.trace.take 26
kernel_rfl PRE_first_tail_x15_r0_body.traceEq45 : PRE_first_tail_x15_r0_body.st45.s3.trace = PRE_first_tail_x15_r0_body.trFr45 ++ PRE_first_tail_x15_r0_body.st45.s0.trace
theorem PRE_first_tail_x15_r0_body.trace45 : ∃ fr, PRE_first_tail_x15_r0_body.st45.s3.trace = fr ++ PRE_first_tail_x15_r0_body.st45.s0.trace := ⟨_, PRE_first_tail_x15_r0_body.traceEq45⟩

-- the caller's wide frames at the instance's start (`Conv.isolateW`'s `W0` under `Map.id`) and their `WFix`
def PRE_first_tail_x15_r0_body.wide45 : List (Nat × WFrame) := [(4910, .memo [])]
kernel_rfl PRE_first_tail_x15_r0_body.wfixB45 : (PRE_first_tail_x15_r0_body.wide45.all fun p => wfixB Map.id (presentB PRE_first_tail_x15_r0_body.st45.s0) p.2) = true
theorem PRE_first_tail_x15_r0_body.wfix45 : ∀ p ∈ PRE_first_tail_x15_r0_body.wide45, WFix Map.id (Present PRE_first_tail_x15_r0_body.st45.s0) p.2 :=
  fun p hp => wfix_of (List.all_eq_true.mp PRE_first_tail_x15_r0_body.wfixB45 p hp)

end Host.Load.Run.Tpl
end

section -- SiteL45
set_option Elab.async false
namespace Host.Load.Run.Tpl
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
open Host.Ts Host.Ts.Sim Host.Ts.Sim.Template

/-! The call link's facts at call site 45 of chain `PRE_first_tail_x15_r0_body`: the instance's start server, its footprint (`Conv.StageFoot`), the
merged state `PRE_first_tail_x15_r0_body.s448`'s framed arrays as the chain start's extended (`arrExt_of`, `numRefs_of`). -/

kernel_rfl PRE_first_tail_x15_r0_body.srvO45 : PRE_first_tail_x15_r0_body.st45.S0.oracle = PRE_first_tail_x15_r0_body.st45.OR
kernel_rfl PRE_first_tail_x15_r0_body.wr0B45 : PRE_first_tail_x15_r0_body.st45.wr.all (fun b => !Nat.blt b PRE_first_tail_x15_r0_body.st45.s0.next || (PRE_first_tail_x15_r0_body.st45.s0.heap.get b).isSome) = true
theorem PRE_first_tail_x15_r0_body.stFoot45 : Conv.StageFoot PRE_first_tail_x15_r0_body.st45.wr PRE_first_tail_x15_r0_body.st45.s0 PRE_first_tail_x15_r0_body.st45.s3 :=
  stageFoot_of PRE_first_tail_x15_r0_body.st45.heapFoot PRE_first_tail_x15_r0_body.wrNodup45 PRE_first_tail_x15_r0_body.wrBound45 PRE_first_tail_x15_r0_body.wr0B45 PRE_first_tail_x15_r0_body.st45.grows

/-- **The relation at the merged state** from the relation at the merge (`Conv.site_merge`'s; `merged_relB`). -/
theorem PRE_first_tail_x15_r0_body.merged45 {FR : Map → Nat → PRE_first_tail_x15_r0_body.st45.F.S → PRE_first_tail_x15_r0_body.st45.F.S → Prop} {W : Nat → Option WFrame} {stk : List Frame} {M : Map}
    {ν : Nat → F64} {K : Host.Ts.Sim.Ctx} {S : SSrv} {t : St PRE_first_tail_x15_r0_body.st45.F.S} {C : CSrv} {n0 : Nat}
    (h : RelB PRE_first_tail_x15_r0_body.st45.F FR W stk M ν K (Conv.mergeSt Map.id (Map.id.res n0 n0) PRE_first_tail_x15_r0_body.rs45 PRE_first_tail_x15_r0_body.st45.wr PRE_first_tail_x15_r0_body.s447 PRE_first_tail_x15_r0_body.st45.s3 PRE_first_tail_x15_r0_body.st45.s0
      PRE_first_tail_x15_r0_body.st45.s3.ffi) S t C) : RelB PRE_first_tail_x15_r0_body.st45.F FR W stk M ν K PRE_first_tail_x15_r0_body.s448 S t C :=
  merged_relB PRE_first_tail_x15_r0_body.iso45 PRE_first_tail_x15_r0_body.stFoot45 PRE_first_tail_x15_r0_body.wrNodup45 PRE_first_tail_x15_r0_body.wrBound45 PRE_first_tail_x15_r0_body.trace45 PRE_first_tail_x15_r0_body.mheap45
    PRE_first_tail_x15_r0_body.mnext45 PRE_first_tail_x15_r0_body.mctl45 PRE_first_tail_x15_r0_body.mstack45 PRE_first_tail_x15_r0_body.mjobs45 PRE_first_tail_x15_r0_body.mffi45 PRE_first_tail_x15_r0_body.mtrace45 PRE_first_tail_x15_r0_body.mstores45 h

def PRE_first_tail_x15_r0_body.arrEl45_2665 : List Val := []
kernel_rfl PRE_first_tail_x15_r0_body.arrE45_2665 : arrOf PRE_first_tail_x15_r0_body.s448 2665 = arrOf PRE_first_tail_x15_r0_body.s0 2665 ++ PRE_first_tail_x15_r0_body.arrEl45_2665
kernel_rfl PRE_first_tail_x15_r0_body.arrA45_2665 : isArrB PRE_first_tail_x15_r0_body.s448 2665 = true
theorem PRE_first_tail_x15_r0_body.arr45_2665 : ∃ o, PRE_first_tail_x15_r0_body.s448.heap.get 2665 = some (.obj o) ∧ o.kind = .array (arrOf PRE_first_tail_x15_r0_body.s0 2665 ++ PRE_first_tail_x15_r0_body.arrEl45_2665) :=
  arrExt_of PRE_first_tail_x15_r0_body.arrE45_2665 PRE_first_tail_x15_r0_body.arrA45_2665
kernel_rfl PRE_first_tail_x15_r0_body.arrN45_2665 : numRefsB PRE_first_tail_x15_r0_body.S0.tab.length PRE_first_tail_x15_r0_body.arrEl45_2665 = true
theorem PRE_first_tail_x15_r0_body.arrR45_2665 : Prefill.NumRefs PRE_first_tail_x15_r0_body.S0.tab.length PRE_first_tail_x15_r0_body.arrEl45_2665 := numRefs_of PRE_first_tail_x15_r0_body.arrN45_2665

def PRE_first_tail_x15_r0_body.arrEl45_2673467 : List Val := []
kernel_rfl PRE_first_tail_x15_r0_body.arrE45_2673467 : arrOf PRE_first_tail_x15_r0_body.s448 2673467 = arrOf PRE_first_tail_x15_r0_body.s0 2673467 ++ PRE_first_tail_x15_r0_body.arrEl45_2673467
kernel_rfl PRE_first_tail_x15_r0_body.arrA45_2673467 : isArrB PRE_first_tail_x15_r0_body.s448 2673467 = true
theorem PRE_first_tail_x15_r0_body.arr45_2673467 : ∃ o, PRE_first_tail_x15_r0_body.s448.heap.get 2673467 = some (.obj o) ∧ o.kind = .array (arrOf PRE_first_tail_x15_r0_body.s0 2673467 ++ PRE_first_tail_x15_r0_body.arrEl45_2673467) :=
  arrExt_of PRE_first_tail_x15_r0_body.arrE45_2673467 PRE_first_tail_x15_r0_body.arrA45_2673467
kernel_rfl PRE_first_tail_x15_r0_body.arrN45_2673467 : numRefsB PRE_first_tail_x15_r0_body.S0.tab.length PRE_first_tail_x15_r0_body.arrEl45_2673467 = true
theorem PRE_first_tail_x15_r0_body.arrR45_2673467 : Prefill.NumRefs PRE_first_tail_x15_r0_body.S0.tab.length PRE_first_tail_x15_r0_body.arrEl45_2673467 := numRefs_of PRE_first_tail_x15_r0_body.arrN45_2673467

kernel_rfl PRE_first_tail_x15_r0_body.w4910k45 : isArrB PRE_first_tail_x15_r0_body.s448 4910 = false
theorem PRE_first_tail_x15_r0_body.keep45 (q : List Val) : Host.Ts.Sim.Prefill.KeepsAtW (framesP PRE_first_tail_x15_r0_body.s0 q) PRE_first_tail_x15_r0_body.s448 := by
  intro a pre pre' hx o es ho hk
  unfold framesP at hx
  simp only at hx
  cases h1 : Nat.beq a 2665
  · cases h2 : Nat.beq a 4910
    · rw [h1, h2] at hx; cases hx
    · have := Nat.eq_of_beq_eq_true h2; subst this
      rw [h1, h2] at hx; cases hx
      exact (notArr_of PRE_first_tail_x15_r0_body.w4910k45 ho hk).elim
  · have := Nat.eq_of_beq_eq_true h1; subst this
    rw [h1] at hx; cases hx
    obtain ⟨o', ho', hk'⟩ := PRE_first_tail_x15_r0_body.arr45_2665
    rw [ho] at ho'; cases ho'
    rw [hk'] at hk; cases hk
    simp [PRE_first_tail_x15_r0_body.arrEl45_2665]

end Host.Load.Run.Tpl
end

section -- SiteZ45
set_option Elab.async false
namespace Host.Load.Run.Tpl
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
open Host.Ts Host.Ts.Sim Host.Ts.Sim.Template

/-! The compaction's state shift at call site 45 of chain `PRE_first_tail_x15_r0_body` (`Conv.compact_shift`): the call `PRE_first_tail_x15_r0_body.s447`, the merged
state `PRE_first_tail_x15_r0_body.s448`, the canonical state `PRE_first_tail_x15_r0_body.s449`; its frames [2665,2673467,2673472,2673473] (kept arrays [2665,2673467]). -/

-- the map's places and counters
kernel_rfl PRE_first_tail_x15_r0_body.zpl45 : PRE_first_tail_x15_r0_body.pl45.all (Nat.ble PRE_first_tail_x15_r0_body.s447.next) = true
kernel_rfl PRE_first_tail_x15_r0_body.zplnd45 : nodupT PRE_first_tail_x15_r0_body.pl45 PTrie.nil = true
kernel_rfl PRE_first_tail_x15_r0_body.zn145 : Nat.ble PRE_first_tail_x15_r0_body.s447.next 2711105 = true
kernel_rfl PRE_first_tail_x15_r0_body.zfirst45 : Nat.ble aFirst PRE_first_tail_x15_r0_body.s447.next = true
kernel_rfl PRE_first_tail_x15_r0_body.zscn45 : PRE_first_tail_x15_r0_body.s449.next = PRE_first_tail_x15_r0_body.s447.next + PRE_first_tail_x15_r0_body.pl45.length
kernel_rfl PRE_first_tail_x15_r0_body.zsmn45 : PRE_first_tail_x15_r0_body.s448.next = 2711105
kernel_rfl PRE_first_tail_x15_r0_body.zgrow45 : Nat.ble PRE_first_tail_x15_r0_body.s449.next PRE_first_tail_x15_r0_body.s448.next = true
-- the tables
kernel_rfl PRE_first_tail_x15_r0_body.zfresh45 : PRE_first_tail_x15_r0_body.S447.tab.all (fun e => PRE_first_tail_x15_r0_body.cws45.all fun v => e.noVar v) = true
kernel_rfl PRE_first_tail_x15_r0_body.zcnd45 : nodupT PRE_first_tail_x15_r0_body.cws45 PTrie.nil = true
kernel_rfl PRE_first_tail_x15_r0_body.znrHi45 : PRE_first_tail_x15_r0_body.nr45.all (fun r => Nat.blt r PRE_first_tail_x15_r0_body.S448.tab.length) = true
-- the frames: every framed address below the call's counter; the kept arrays the chain start's, extended in the merged state
kernel_rfl PRE_first_tail_x15_r0_body.zfrlt45 : [2665, 2673467, 2673472, 2673473].all (fun a => Nat.blt a PRE_first_tail_x15_r0_body.s447.next) = true
kernel_rfl PRE_first_tail_x15_r0_body.zg45_2665 : PRE_first_tail_x15_r0_body.s449.heap.get 2665 = some (.obj (objOf PRE_first_tail_x15_r0_body.s449 2665))
kernel_rfl PRE_first_tail_x15_r0_body.zk45_2665 : (objOf PRE_first_tail_x15_r0_body.s449 2665).kind = .array (arrOf PRE_first_tail_x15_r0_body.s0 2665)
kernel_rfl PRE_first_tail_x15_r0_body.zm45_2665 : PRE_first_tail_x15_r0_body.s448.heap.get 2665 = some (.obj { PRE_first_tail_x15_r0_body.kappa45.obj (objOf PRE_first_tail_x15_r0_body.s449 2665) with
  kind := .array (arrOf PRE_first_tail_x15_r0_body.s0 2665 ++ (arrOf PRE_first_tail_x15_r0_body.s448 2665).drop (arrOf PRE_first_tail_x15_r0_body.s0 2665).length) })
kernel_rfl PRE_first_tail_x15_r0_body.zg45_2673467 : PRE_first_tail_x15_r0_body.s449.heap.get 2673467 = some (.obj (objOf PRE_first_tail_x15_r0_body.s449 2673467))
kernel_rfl PRE_first_tail_x15_r0_body.zk45_2673467 : (objOf PRE_first_tail_x15_r0_body.s449 2673467).kind = .array (arrOf PRE_first_tail_x15_r0_body.s0 2673467)
kernel_rfl PRE_first_tail_x15_r0_body.zm45_2673467 : PRE_first_tail_x15_r0_body.s448.heap.get 2673467 = some (.obj { PRE_first_tail_x15_r0_body.kappa45.obj (objOf PRE_first_tail_x15_r0_body.s449 2673467) with
  kind := .array (arrOf PRE_first_tail_x15_r0_body.s0 2673467 ++ (arrOf PRE_first_tail_x15_r0_body.s448 2673467).drop (arrOf PRE_first_tail_x15_r0_body.s0 2673467).length) })
kernel_rfl PRE_first_tail_x15_r0_body.zw45_4910 : (PRE_first_tail_x15_r0_body.s449.heap.get 4910).isSome = true
kernel_rfl PRE_first_tail_x15_r0_body.zw45_2673472 : (PRE_first_tail_x15_r0_body.s449.heap.get 2673472).isSome = true
kernel_rfl PRE_first_tail_x15_r0_body.zw45_2673473 : (PRE_first_tail_x15_r0_body.s449.heap.get 2673473).isSome = true
-- the heap: the changed list in range, holding the stage's written and fresh addresses; the canonical side's image
kernel_rfl PRE_first_tail_x15_r0_body.zclbd45 : PRE_first_tail_x15_r0_body.cl45.all (fun b => Nat.blt (b / 4096) (4 ^ 31)) = true
kernel_rfl PRE_first_tail_x15_r0_body.zwr45 : PRE_first_tail_x15_r0_body.st45.wr.all (fun b => !Nat.blt b PRE_first_tail_x15_r0_body.s447.next || PRE_first_tail_x15_r0_body.cl45.contains b) = true
def PRE_first_tail_x15_r0_body.zl45 : List Nat := PRE_first_tail_x15_r0_body.cl45.filter fun a => !(List.contains [2665, 2673467] a)
kernel_rfl PRE_first_tail_x15_r0_body.zimgE45 : PRE_first_tail_x15_r0_body.zl45.map (fun a => PRE_first_tail_x15_r0_body.s448.heap.get (PRE_first_tail_x15_r0_body.kappa45.a a)) = PRE_first_tail_x15_r0_body.zl45.map (fun a => (PRE_first_tail_x15_r0_body.s449.heap.get a).map PRE_first_tail_x15_r0_body.kappa45.hobj)
theorem PRE_first_tail_x15_r0_body.zimg45 : HeapImg PRE_first_tail_x15_r0_body.kappa45 PRE_first_tail_x15_r0_body.s449 PRE_first_tail_x15_r0_body.s448 PRE_first_tail_x15_r0_body.zl45 := PRE_first_tail_x15_r0_body.zimgE45
-- the roots and their supports
kernel_rfl PRE_first_tail_x15_r0_body.zctl45 : PRE_first_tail_x15_r0_body.s448.ctl = PRE_first_tail_x15_r0_body.kappa45.ctl PRE_first_tail_x15_r0_body.s449.ctl
kernel_rfl PRE_first_tail_x15_r0_body.zstack45 : PRE_first_tail_x15_r0_body.s448.stack = PRE_first_tail_x15_r0_body.s449.stack.map PRE_first_tail_x15_r0_body.kappa45.frame
kernel_rfl PRE_first_tail_x15_r0_body.zjobs45 : PRE_first_tail_x15_r0_body.s448.jobs = PRE_first_tail_x15_r0_body.s449.jobs.map PRE_first_tail_x15_r0_body.kappa45.job
kernel_rfl PRE_first_tail_x15_r0_body.zstores45 : PRE_first_tail_x15_r0_body.s448.stores = PRE_first_tail_x15_r0_body.kappa45.stores PRE_first_tail_x15_r0_body.s449.stores
kernel_rfl PRE_first_tail_x15_r0_body.zroots45 : checkRootsSupp PRE_first_tail_x15_r0_body.s449 2022 = true
kernel_rfl PRE_first_tail_x15_r0_body.znC45 : PRE_first_tail_x15_r0_body.S447.tab.length + PRE_first_tail_x15_r0_body.cws45.length = 2022
-- the map as `Conv.compact_shift` states it (the call's counters for the literals)
kernel_rfl PRE_first_tail_x15_r0_body.zkap45 : PRE_first_tail_x15_r0_body.kappa45 = Conv.Map.compact PRE_first_tail_x15_r0_body.s447.next 2711105 PRE_first_tail_x15_r0_body.S447.tab.length PRE_first_tail_x15_r0_body.pl45 (PRE_first_tail_x15_r0_body.nr45.map NumV.ref) PRE_first_tail_x15_r0_body.kd45.big
  PRE_first_tail_x15_r0_body.kd45.region PRE_first_tail_x15_r0_body.kd45.nodeF
-- the bridge inactive at the canonical state (`Conv.FullShiftQ.toX`; the merged state's bridge is the canonical's: cbridge)
theorem PRE_first_tail_x15_r0_body.zbin45 : (Host.Ts.Sim.Full.bridgeOf PRE_first_tail_x15_r0_body.s449.ffi).active = false := (Host.Load.Boot.replay_active Host.Load.Run.Prompt.P.oblog2818)
-- the JS bookkeeping's step (`Conv.JClean.step` over the changed list) and the canonical roots' bigint freedom
kernel_rfl PRE_first_tail_x15_r0_body.zjc45 : Conv.jcleanListB (⟨19105, 16193, 2710755, 2022⟩ : Conv.Cnt) PRE_first_tail_x15_r0_body.s449 PRE_first_tail_x15_r0_body.cl45 = true
kernel_rfl PRE_first_tail_x15_r0_body.zrootsB45 : noBigRootsP (fun i => !Conv.oldBigB (⟨19105, 16193, 2710755, 2022⟩ : Conv.Cnt) i) PRE_first_tail_x15_r0_body.s449.trace PRE_first_tail_x15_r0_body.s449 = true
kernel_rfl PRE_first_tail_x15_r0_body.zhm45 : Nat.ble (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s0.ffi).mlx.nnext 16187 = true
theorem PRE_first_tail_x15_r0_body.cjcl45 (h : Conv.JClean (⟨19101, 16187, 2710740, 2013⟩ : Conv.Cnt) PRE_first_tail_x15_r0_body.s447) : Conv.JClean (⟨19105, 16193, 2710755, 2022⟩ : Conv.Cnt) PRE_first_tail_x15_r0_body.s449 :=
  Conv.JClean.step h (Conv.Cnt.le_of_leB PRE_first_tail_x15_r0_body.cle45)
    (Conv.heap_off_setAll PRE_first_tail_x15_r0_body.cheap45 fun a ha => Nat.blt_eq.mp (List.all_eq_true.mp PRE_first_tail_x15_r0_body.zclbd45 a ha)) PRE_first_tail_x15_r0_body.zjc45

end Host.Load.Run.Tpl
end

section -- st45/TypedLast
set_option Elab.async false
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
namespace Host.Load.Run.Tpl
open Host.Ts Host.Ts.Sim Host.Ts.Sim.Template

boot_rfl PRE_first_tail_x15_r0_body.st45.bodyLast from PRE_first_tail_x15_r0_body.st45.s2 to PRE_first_tail_x15_r0_body.st45.s3 :
  interpS (step PRE_first_tail_x15_r0_body.st45.F PRE_first_tail_x15_r0_body.st45.s2).run PRE_first_tail_x15_r0_body.st45.S2 = some (PRE_first_tail_x15_r0_body.st45.s3, PRE_first_tail_x15_r0_body.st45.S3)
kernel_rfl PRE_first_tail_x15_r0_body.st45.bodyHalt : isHalt PRE_first_tail_x15_r0_body.st45.s2.ctl = false
kernel_rfl PRE_first_tail_x15_r0_body.st45.bodyTopCheck : noBlockTop PRE_first_tail_x15_r0_body.st45.s3.stack = true

end Host.Load.Run.Tpl
end

section -- st45/TypedOk
set_option Elab.async false
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
namespace Host.Load.Run.Tpl
open Host.Ts Host.Ts.Sim Host.Ts.Sim.Template

noncomputable def PRE_first_tail_x15_r0_body.st45.bodyOkL (bytes : List Byte) (rows : Nat) : St PRE_first_tail_x15_r0_body.st45.F.S → SSrv → Bool :=
  okLocal (Host.Ts.Sim.Compose.VWFrames.bodyOk bytes rows)

noncomputable def PRE_first_tail_x15_r0_body.st45.bodyOkLN (bytes : List Byte) (rows : Nat) : St PRE_first_tail_x15_r0_body.st45.F.S → FSrv → Bool :=
  okLocalN (Host.Ts.Sim.Compose.VWFrames.bodyOkN bytes rows)

theorem PRE_first_tail_x15_r0_body.st45.bodyOkLN_ok (bytes : List Byte) (rows : Nat) (s : St PRE_first_tail_x15_r0_body.st45.F.S) (c : FSrv) (h : c.Wf) :
    PRE_first_tail_x15_r0_body.st45.bodyOkLN bytes rows s c = PRE_first_tail_x15_r0_body.st45.bodyOkL bytes rows s c.toS :=
  okLocalN_ok (Host.Ts.Sim.Compose.VWFrames.bodyOkN_ok bytes rows) s c h

kernel_rfl PRE_first_tail_x15_r0_body.st45.bodyAccepted0 :
  (fun (bytes : List Byte) (rows : Nat) => PRE_first_tail_x15_r0_body.st45.bodyOkL bytes rows PRE_first_tail_x15_r0_body.st45.s0 PRE_first_tail_x15_r0_body.st45.S0) = fun _ _ => true

kernel_rfl PRE_first_tail_x15_r0_body.st45.bodyAccepted1 :
  (fun (bytes : List Byte) (rows : Nat) => PRE_first_tail_x15_r0_body.st45.bodyOkL bytes rows PRE_first_tail_x15_r0_body.st45.s2 PRE_first_tail_x15_r0_body.st45.S2) = fun _ _ => true

end Host.Load.Run.Tpl
end

section -- st45/TypedK0
set_option Elab.async false
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
namespace Host.Load.Run.Tpl
open Host.Ts Host.Ts.Sim Host.Ts.Sim.Template

boot_rfl PRE_first_tail_x15_r0_body.st45.bodyK0F from PRE_first_tail_x15_r0_body.st45.s0 to PRE_first_tail_x15_r0_body.st45.s1 :
  (fun (bytes : List Byte) (rows : Nat) => runOkS PRE_first_tail_x15_r0_body.st45.F (PRE_first_tail_x15_r0_body.st45.bodyOkLN bytes rows)
    ((nth? PRE_first_tail_x15_r0_body.st45.ks 0).getD 0) PRE_first_tail_x15_r0_body.st45.s0 PRE_first_tail_x15_r0_body.st45.S0) = fun _ _ => some (PRE_first_tail_x15_r0_body.st45.s1, PRE_first_tail_x15_r0_body.st45.S1)
theorem PRE_first_tail_x15_r0_body.st45.bodyK0 :
  (fun (bytes : List Byte) (rows : Nat) => runOk PRE_first_tail_x15_r0_body.st45.F (PRE_first_tail_x15_r0_body.st45.bodyOkL bytes rows)
    ((nth? PRE_first_tail_x15_r0_body.st45.ks 0).getD 0) PRE_first_tail_x15_r0_body.st45.s0 PRE_first_tail_x15_r0_body.st45.S0) = fun _ _ => some (PRE_first_tail_x15_r0_body.st45.s1, PRE_first_tail_x15_r0_body.st45.S1) :=
  runOk_fun_of_runOkS PRE_first_tail_x15_r0_body.st45.bodyOkLN_ok PRE_first_tail_x15_r0_body.st45.bodyK0F
end Host.Load.Run.Tpl
end

section -- st45/TypedK1
set_option Elab.async false
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
namespace Host.Load.Run.Tpl
open Host.Ts Host.Ts.Sim Host.Ts.Sim.Template

boot_rfl PRE_first_tail_x15_r0_body.st45.bodyK1F from PRE_first_tail_x15_r0_body.st45.s1 to PRE_first_tail_x15_r0_body.st45.s2 :
  (fun (bytes : List Byte) (rows : Nat) => runOkS PRE_first_tail_x15_r0_body.st45.F (PRE_first_tail_x15_r0_body.st45.bodyOkLN bytes rows)
    ((nth? PRE_first_tail_x15_r0_body.st45.ks 1).getD 0) PRE_first_tail_x15_r0_body.st45.s1 PRE_first_tail_x15_r0_body.st45.S1) = fun _ _ => some (PRE_first_tail_x15_r0_body.st45.s2, PRE_first_tail_x15_r0_body.st45.S2)
theorem PRE_first_tail_x15_r0_body.st45.bodyK1 :
  (fun (bytes : List Byte) (rows : Nat) => runOk PRE_first_tail_x15_r0_body.st45.F (PRE_first_tail_x15_r0_body.st45.bodyOkL bytes rows)
    ((nth? PRE_first_tail_x15_r0_body.st45.ks 1).getD 0) PRE_first_tail_x15_r0_body.st45.s1 PRE_first_tail_x15_r0_body.st45.S1) = fun _ _ => some (PRE_first_tail_x15_r0_body.st45.s2, PRE_first_tail_x15_r0_body.st45.S2) :=
  runOk_fun_of_runOkS PRE_first_tail_x15_r0_body.st45.bodyOkLN_ok PRE_first_tail_x15_r0_body.st45.bodyK1F
end Host.Load.Run.Tpl
end

section -- st45/TypedTpl
set_option Elab.async false
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
namespace Host.Load.Run.Tpl
open Host.Ts Host.Ts.Sim Host.Ts.Sim.Template

theorem PRE_first_tail_x15_r0_body.st45.bodyRun (bytes : List Byte) (rows : Nat) :
    runOk PRE_first_tail_x15_r0_body.st45.F (PRE_first_tail_x15_r0_body.st45.bodyOkL bytes rows) 3452 PRE_first_tail_x15_r0_body.st45.s0 PRE_first_tail_x15_r0_body.st45.S0 = some (PRE_first_tail_x15_r0_body.st45.s2, PRE_first_tail_x15_r0_body.st45.S2) :=
  runOk_trans PRE_first_tail_x15_r0_body.st45.F (PRE_first_tail_x15_r0_body.st45.bodyOkL bytes rows) ((nth? PRE_first_tail_x15_r0_body.st45.ks 0).getD 0) ((nth? PRE_first_tail_x15_r0_body.st45.ks 1).getD 0) PRE_first_tail_x15_r0_body.st45.s0 PRE_first_tail_x15_r0_body.st45.s1 PRE_first_tail_x15_r0_body.st45.s2 PRE_first_tail_x15_r0_body.st45.S0 PRE_first_tail_x15_r0_body.st45.S1 PRE_first_tail_x15_r0_body.st45.S2 ((congrFun (congrFun PRE_first_tail_x15_r0_body.st45.bodyK0 bytes) rows)) (congrFun (congrFun PRE_first_tail_x15_r0_body.st45.bodyK1 bytes) rows)

theorem PRE_first_tail_x15_r0_body.st45.bodyLocal (bytes : List Byte) (rows : Nat) : ∀ s S, PRE_first_tail_x15_r0_body.st45.bodyOkL bytes rows s S = true → Disp.localB s = true := okLocal_localB

noncomputable def PRE_first_tail_x15_r0_body.st45.bodyTpl (bytes : List Byte) (rows : Nat) : Host.Ts.Sim.Stage.StageTpl PRE_first_tail_x15_r0_body.st45.F (PRE_first_tail_x15_r0_body.st45.bodyOkL bytes rows) where
  s0 := PRE_first_tail_x15_r0_body.st45.s0
  S0 := PRE_first_tail_x15_r0_body.st45.S0
  s1 := PRE_first_tail_x15_r0_body.st45.s2
  S1 := PRE_first_tail_x15_r0_body.st45.S2
  s2 := PRE_first_tail_x15_r0_body.st45.s3
  S2 := PRE_first_tail_x15_r0_body.st45.S3
  n := 3452
  ok0 := congrFun (congrFun PRE_first_tail_x15_r0_body.st45.bodyAccepted0 bytes) rows
  run := PRE_first_tail_x15_r0_body.st45.bodyRun bytes rows
  ok1 := congrFun (congrFun PRE_first_tail_x15_r0_body.st45.bodyAccepted1 bytes) rows
  halt := PRE_first_tail_x15_r0_body.st45.bodyHalt
  last := PRE_first_tail_x15_r0_body.st45.bodyLast
  top := noBlockTop_sound PRE_first_tail_x15_r0_body.st45.bodyTopCheck
end Host.Load.Run.Tpl
end

section -- SiteC46
set_option Elab.async false
namespace Host.Load.Run.Tpl
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
open Host.Ts Host.Ts.Sim Host.Ts.Sim.Template

/-! The compaction after the merge at call site 46 of chain `PRE_first_tail_x15_r0_body` (`Conv.compact`, `Conv.full_compactQ`): the canonical
state `PRE_first_tail_x15_r0_body.s457` (the stage's results at canonical places, its trace the call's) under `PRE_first_tail_x15_r0_body.kappa46` into the merged state
`PRE_first_tail_x15_r0_body.s456`. -/

def PRE_first_tail_x15_r0_body.pl46 : List Nat := []
def PRE_first_tail_x15_r0_body.nr46 : List Nat := []
/-- The native part of the compaction map (canonical → merged handles and nodes: its `big`, `region`, `nodeF`). -/
def PRE_first_tail_x15_r0_body.kd46 : RData :=
  ⟨2711337, 2711339, Stage.setAll PTrie.nil [], Stage.setAll PTrie.nil [],
   19118, 19118, 16203, 16203, Stage.setAll PTrie.nil [],
   Stage.setAll PTrie.nil []⟩
/-- **The compaction map.** -/
noncomputable def PRE_first_tail_x15_r0_body.kappa46 : Map :=
  Conv.Map.compact 2711337 2711339 2045 PRE_first_tail_x15_r0_body.pl46 (PRE_first_tail_x15_r0_body.nr46.map NumV.ref) PRE_first_tail_x15_r0_body.kd46.big
    PRE_first_tail_x15_r0_body.kd46.region PRE_first_tail_x15_r0_body.kd46.nodeF
/-- The canonical result variables and their images, the merged state's entries (`Conv.compactθ`). -/
def PRE_first_tail_x15_r0_body.cws46 : List Nat := []
noncomputable def PRE_first_tail_x15_r0_body.crs46 : List SymE := PRE_first_tail_x15_r0_body.nr46.map fun r => (nth? PRE_first_tail_x15_r0_body.S456.tab r).getD (.var 0)
noncomputable def PRE_first_tail_x15_r0_body.ctheta46 : Nat → SymE := Conv.compactθ PRE_first_tail_x15_r0_body.cws46 PRE_first_tail_x15_r0_body.crs46
/-- The call's entries the stage wrote (renamed in the canonical state with the results). -/
def PRE_first_tail_x15_r0_body.wrB46 : List Nat := [2665, 2673467]

kernel_rfl PRE_first_tail_x15_r0_body.ctab46 : PRE_first_tail_x15_r0_body.S457.tab = PRE_first_tail_x15_r0_body.S455.tab ++ PRE_first_tail_x15_r0_body.cws46.map SymE.var
kernel_rfl PRE_first_tail_x15_r0_body.ctrace46 : PRE_first_tail_x15_r0_body.s457.trace = PRE_first_tail_x15_r0_body.s455.trace
kernel_rfl PRE_first_tail_x15_r0_body.cnext46 : PRE_first_tail_x15_r0_body.s457.next = 2711337
kernel_rfl PRE_first_tail_x15_r0_body.ccounters46 : ((Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s457.ffi).mlx.next, (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s457.ffi).mlx.nnext) = (19118, 16203)
-- the merged state's readback queue, carried to the canonical state (`Conv.FullShiftQ.tokens`, `tokSupp`)
kernel_rfl PRE_first_tail_x15_r0_body.cqueue46 : (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s456.ffi).mlx.tokens = (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s457.ffi).mlx.tokens.map PRE_first_tail_x15_r0_body.kappa46.nv
kernel_rfl PRE_first_tail_x15_r0_body.ctokSupp46 : (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s457.ffi).mlx.tokens.all (bSN 2045) = true
-- the written and the result entries carry no bigint of the canonical fresh band [next, E) and no fresh region
kernel_rfl PRE_first_tail_x15_r0_body.cclean46 : Conv.cleanListB 19118 131072 (fun r => Nat.ble 76472 r) PRE_first_tail_x15_r0_body.s457
    (PRE_first_tail_x15_r0_body.wrB46 ++ (List.range 0).map (2711337 + ·)) = true
kernel_rfl PRE_first_tail_x15_r0_body.cbigs46 : bigsOutB 19118 131072 (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s457.ffi).mlx = true

end Host.Load.Run.Tpl
end

section -- SiteK46
set_option Elab.async false
namespace Host.Load.Run.Tpl
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
open Host.Ts Host.Ts.Sim Host.Ts.Sim.Template

/-! The canonical state's closedness from the call's (`Conv.closed_of_callB`, `Conv.sst_of_callB`): it keeps the call's entries
off the written and the result ones (`PRE_first_tail_x15_r0_body.cl46`; natively the written and result handles, the result nodes, the written
and result items), and those are checked. -/

def PRE_first_tail_x15_r0_body.cl46 : List Nat := [2665, 2673467]
def PRE_first_tail_x15_r0_body.clo46 : List Nat := []
def PRE_first_tail_x15_r0_body.cln46 : List Nat := []
def PRE_first_tail_x15_r0_body.cli46 : List Nat := []
kernel_rfl PRE_first_tail_x15_r0_body.cheap46 : PRE_first_tail_x15_r0_body.s457.heap = Stage.setAll PRE_first_tail_x15_r0_body.s455.heap (PRE_first_tail_x15_r0_body.cl46.filterMap fun a => (PRE_first_tail_x15_r0_body.s457.heap.get a).map (a, ·))
kernel_rfl PRE_first_tail_x15_r0_body.cnextLe46 : Nat.ble PRE_first_tail_x15_r0_body.s455.next PRE_first_tail_x15_r0_body.s457.next = true
kernel_rfl PRE_first_tail_x15_r0_body.ckeepP46 : Conv.keptPresentB PRE_first_tail_x15_r0_body.s455 PRE_first_tail_x15_r0_body.s457 PRE_first_tail_x15_r0_body.cl46 = true
kernel_rfl PRE_first_tail_x15_r0_body.csupp46 : Conv.suppListB PRE_first_tail_x15_r0_body.s457 2045 PRE_first_tail_x15_r0_body.cl46 = true
kernel_rfl PRE_first_tail_x15_r0_body.cbound46 : Conv.boundListB PRE_first_tail_x15_r0_body.s457 PRE_first_tail_x15_r0_body.cl46 = true
kernel_rfl PRE_first_tail_x15_r0_body.cnodesK46 : (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s457.ffi).mlx.nodes = Stage.setAll (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s455.ffi).mlx.nodes (PRE_first_tail_x15_r0_body.cln46.filterMap fun i => ((Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s457.ffi).mlx.nodes.get i).map (i, ·))
kernel_rfl PRE_first_tail_x15_r0_body.cobjsK46 : (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s457.ffi).mlx.objs = Stage.setAll (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s455.ffi).mlx.objs (PRE_first_tail_x15_r0_body.clo46.filterMap fun i => ((Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s457.ffi).mlx.objs.get i).map (i, ·))
kernel_rfl PRE_first_tail_x15_r0_body.citemsK46 : (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s457.ffi).mlx.items = Stage.setAll (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s455.ffi).mlx.items (PRE_first_tail_x15_r0_body.cli46.filterMap fun i => ((Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s457.ffi).mlx.items.get i).map (i, ·))
kernel_rfl PRE_first_tail_x15_r0_body.csst46 : Conv.sstListB 2045 (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s457.ffi).mlx PRE_first_tail_x15_r0_body.cln46 PRE_first_tail_x15_r0_body.clo46 PRE_first_tail_x15_r0_body.cli46 = true

end Host.Load.Run.Tpl
end

section -- SiteCl46
set_option Elab.async false
namespace Host.Load.Run.Tpl
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
open Host.Ts Host.Ts.Sim Host.Ts.Sim.Template

kernel_rfl PRE_first_tail_x15_r0_body.ckA46 : (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s457.ffi).mlx.arrs = Stage.setAll (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s455.ffi).mlx.arrs (PRE_first_tail_x15_r0_body.clo46.filterMap fun i => ((Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s457.ffi).mlx.arrs.get i).map (i, ·))
kernel_rfl PRE_first_tail_x15_r0_body.cbd46 : (PRE_first_tail_x15_r0_body.clo46 ++ PRE_first_tail_x15_r0_body.cln46 ++ PRE_first_tail_x15_r0_body.cli46).all (fun i => Nat.blt (i / 4096) (4 ^ 31)) = true
kernel_rfl PRE_first_tail_x15_r0_body.cle46 : Conv.Cnt.leB (⟨19118, 16203, 2711337, 2045⟩ : Conv.Cnt) (⟨19118, 16203, 2711337, 2045⟩ : Conv.Cnt) = true
kernel_rfl PRE_first_tail_x15_r0_body.cck46 : Conv.ncleanListB (⟨19118, 16203, 2711337, 2045⟩ : Conv.Cnt) (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s457.ffi).mlx PRE_first_tail_x15_r0_body.clo46 PRE_first_tail_x15_r0_body.cln46 PRE_first_tail_x15_r0_body.cli46 = true
theorem PRE_first_tail_x15_r0_body.cncl46 (h : Conv.NClean (⟨19118, 16203, 2711337, 2045⟩ : Conv.Cnt) (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s455.ffi).mlx) : Conv.NClean (⟨19118, 16203, 2711337, 2045⟩ : Conv.Cnt) (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s457.ffi).mlx :=
  Conv.NClean.stepKeep h PRE_first_tail_x15_r0_body.cle46 PRE_first_tail_x15_r0_body.ckA46 PRE_first_tail_x15_r0_body.cobjsK46 PRE_first_tail_x15_r0_body.cnodesK46 PRE_first_tail_x15_r0_body.citemsK46 PRE_first_tail_x15_r0_body.cbd46 PRE_first_tail_x15_r0_body.cck46

end Host.Load.Run.Tpl
end

section -- SiteS46
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
end

section -- st46/H0
set_option Elab.async false
namespace Host.Load.Run.Tpl
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
host_stream_state PRE_first_tail_x15_r0_body.st46 0
host_stream_state PRE_first_tail_x15_r0_body.st46 1
host_stream_state PRE_first_tail_x15_r0_body.st46 2
end Host.Load.Run.Tpl
end

section -- Site46
set_option Elab.async false
namespace Host.Load.Run.Tpl
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
open Host.Ts Host.Ts.Sim Host.Ts.Sim.Template

/-! Call site 46 of chain `PRE_first_tail_x15_r0_body`: `rowBlocks__g46__g47` (`rowBlocks`), the call state `PRE_first_tail_x15_r0_body.s455`, the merged state `PRE_first_tail_x15_r0_body.s456`,
the site template `PRE_first_tail_x15_r0_body.st46` (σ = `Map.id`, θ the identity at its own site), the canonical state `PRE_first_tail_x15_r0_body.s457`: the merge.
The footprint's facts are in `SiteF46`, the compaction's in `SiteC46`, `SiteK46`, `SiteNa46`, `SiteNb46`. -/

kernel_rfl PRE_first_tail_x15_r0_body.iso46 : PRE_first_tail_x15_r0_body.st46.s0 = { PRE_first_tail_x15_r0_body.s455 with stack := [] }
/-- The caller's frames at the call. -/
noncomputable def PRE_first_tail_x15_r0_body.rs46 : List Frame := PRE_first_tail_x15_r0_body.s455.stack
kernel_rfl PRE_first_tail_x15_r0_body.n0_46 : PRE_first_tail_x15_r0_body.S455.tab.length = 2045
kernel_rfl PRE_first_tail_x15_r0_body.tab0_46 : PRE_first_tail_x15_r0_body.st46.S0.tab = PRE_first_tail_x15_r0_body.S455.tab

/-- The fresh variables of the stage's results. -/
def PRE_first_tail_x15_r0_body.ws46 : List Nat := [1785, 1786]
kernel_rfl PRE_first_tail_x15_r0_body.fresh46 : (PRE_first_tail_x15_r0_body.S455.tab.all fun e => PRE_first_tail_x15_r0_body.ws46.all fun v => e.noVar v) &&
    (PRE_first_tail_x15_r0_body.S455.oracle.all fun q => PRE_first_tail_x15_r0_body.ws46.all fun v => q.noVar v) = true
kernel_rfl PRE_first_tail_x15_r0_body.mergeTab46 : PRE_first_tail_x15_r0_body.S456.tab = PRE_first_tail_x15_r0_body.S455.tab ++ Conv.resTab PRE_first_tail_x15_r0_body.ws46
kernel_rfl PRE_first_tail_x15_r0_body.mergeLen46 : PRE_first_tail_x15_r0_body.st46.S2.tab.length - PRE_first_tail_x15_r0_body.st46.S0.tab.length = 2

-- The merged state: the instance's return state with the caller's frames (`PRE_first_tail_x15_r0_body.merged46`, `merged_relB`).
kernel_rfl PRE_first_tail_x15_r0_body.mheap46 : PRE_first_tail_x15_r0_body.s456.heap = PRE_first_tail_x15_r0_body.st46.s2.heap
kernel_rfl PRE_first_tail_x15_r0_body.mnext46 : PRE_first_tail_x15_r0_body.s456.next = PRE_first_tail_x15_r0_body.st46.s2.next
kernel_rfl PRE_first_tail_x15_r0_body.mctl46 : PRE_first_tail_x15_r0_body.s456.ctl = PRE_first_tail_x15_r0_body.st46.s2.ctl
kernel_rfl PRE_first_tail_x15_r0_body.mstack46 : PRE_first_tail_x15_r0_body.s456.stack = PRE_first_tail_x15_r0_body.st46.s2.stack ++ PRE_first_tail_x15_r0_body.s455.stack
kernel_rfl PRE_first_tail_x15_r0_body.mjobs46 : PRE_first_tail_x15_r0_body.s456.jobs = PRE_first_tail_x15_r0_body.st46.s2.jobs
kernel_rfl PRE_first_tail_x15_r0_body.mffi46 : PRE_first_tail_x15_r0_body.s456.ffi = PRE_first_tail_x15_r0_body.st46.s2.ffi
kernel_rfl PRE_first_tail_x15_r0_body.mtrace46 : PRE_first_tail_x15_r0_body.s456.trace = PRE_first_tail_x15_r0_body.st46.s2.trace
kernel_rfl PRE_first_tail_x15_r0_body.mstores46 : PRE_first_tail_x15_r0_body.s456.stores = PRE_first_tail_x15_r0_body.st46.s2.stores

end Host.Load.Run.Tpl
end

section -- SiteD46
set_option Elab.async false
namespace Host.Load.Run.Tpl
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
open Host.Ts Host.Ts.Sim Host.Ts.Sim.Template

/-! The canonical results at call site 46 of chain `PRE_first_tail_x15_r0_body`: their values in the instance's end table, the references past
the call's table, the canonical variables apart from the stage's. -/

kernel_rfl PRE_first_tail_x15_r0_body.cderived46 : PRE_first_tail_x15_r0_body.nr46.map (fun r => nth? PRE_first_tail_x15_r0_body.st46.S2.tab r) =
  []
kernel_rfl PRE_first_tail_x15_r0_body.cnrLo46 : PRE_first_tail_x15_r0_body.nr46.all (Nat.ble 2045) = true
kernel_rfl PRE_first_tail_x15_r0_body.cwsDisj46 : PRE_first_tail_x15_r0_body.cws46.all (fun c => !PRE_first_tail_x15_r0_body.ws46.contains c) = true
/-- The compaction's substitution: the canonical variables to their merged values, the stage's other fresh variables
to `0` (`Conv.compactθZ`). -/
noncomputable def PRE_first_tail_x15_r0_body.cthetaZ46 : Nat → SymE := Conv.compactθZ PRE_first_tail_x15_r0_body.cws46 PRE_first_tail_x15_r0_body.crs46 PRE_first_tail_x15_r0_body.ws46

end Host.Load.Run.Tpl
end

section -- st46/Foot
set_option Elab.async false
namespace Host.Load.Run.Tpl
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
open Host.Ts Host.Ts.Sim Host.Ts.Sim.Stage Host.Ts.Sim.Template

/-! The footprint of stage `PRE_first_tail_x15_r0_body.st46`'s site template (`Conv.StageFoot`, `Conv.NFoot`): every entry of the return
state other than the written and fresh ones is the start's (kernel evaluation of the equalities). -/

/-- The written heap ranges below the start's counter. -/
def PRE_first_tail_x15_r0_body.st46.wrR : List (Nat × Nat) := []
/-- The written and fresh entries of the return state. -/
noncomputable def PRE_first_tail_x15_r0_body.st46.wrE : List (Nat × Host.Ts.HObj) :=
  rangesOf PRE_first_tail_x15_r0_body.st46.s2.heap PRE_first_tail_x15_r0_body.st46.wrR ++ freshOf PRE_first_tail_x15_r0_body.st46.s2.heap PRE_first_tail_x15_r0_body.st46.s0.next PRE_first_tail_x15_r0_body.st46.s2.next
noncomputable def PRE_first_tail_x15_r0_body.st46.wr : List Nat := PRE_first_tail_x15_r0_body.st46.wrE.map (·.1)

kernel_rfl PRE_first_tail_x15_r0_body.st46.heapFoot : PRE_first_tail_x15_r0_body.st46.s2.heap = setAll PRE_first_tail_x15_r0_body.st46.s0.heap PRE_first_tail_x15_r0_body.st46.wrE
kernel_rfl PRE_first_tail_x15_r0_body.st46.grows_check : Nat.ble PRE_first_tail_x15_r0_body.st46.s0.next PRE_first_tail_x15_r0_body.st46.s2.next = true
theorem PRE_first_tail_x15_r0_body.st46.grows : PRE_first_tail_x15_r0_body.st46.s0.next ≤ PRE_first_tail_x15_r0_body.st46.s2.next := Nat.le_of_ble_eq_true PRE_first_tail_x15_r0_body.st46.grows_check

/-- The written and fresh handles; the written readback items of old nodes. -/
def PRE_first_tail_x15_r0_body.st46.wh : List Nat := []
def PRE_first_tail_x15_r0_body.st46.wi : List Nat := []

kernel_rfl PRE_first_tail_x15_r0_body.st46.arrsFoot : (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.st46.s2.ffi).mlx.arrs = setAll (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.st46.s0.ffi).mlx.arrs (PRE_first_tail_x15_r0_body.st46.wh.filterMap fun h => ((Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.st46.s2.ffi).mlx.arrs.get h).map (h, ·))
kernel_rfl PRE_first_tail_x15_r0_body.st46.objsFoot : (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.st46.s2.ffi).mlx.objs = setAll (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.st46.s0.ffi).mlx.objs (PRE_first_tail_x15_r0_body.st46.wh.filterMap fun h => ((Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.st46.s2.ffi).mlx.objs.get h).map (h, ·))
kernel_rfl PRE_first_tail_x15_r0_body.st46.nodesFoot : (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.st46.s2.ffi).mlx.nodes = setAll (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.st46.s0.ffi).mlx.nodes (freshOf (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.st46.s2.ffi).mlx.nodes (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.st46.s0.ffi).mlx.nnext (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.st46.s2.ffi).mlx.nnext)
kernel_rfl PRE_first_tail_x15_r0_body.st46.itemsFoot : (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.st46.s2.ffi).mlx.items = setAll (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.st46.s0.ffi).mlx.items ((PRE_first_tail_x15_r0_body.st46.wi.filterMap fun i => ((Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.st46.s2.ffi).mlx.items.get i).map (i, ·)) ++
    freshOf (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.st46.s2.ffi).mlx.items (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.st46.s0.ffi).mlx.nnext (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.st46.s2.ffi).mlx.nnext)
kernel_rfl PRE_first_tail_x15_r0_body.st46.counters : (Nat.ble (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.st46.s0.ffi).mlx.next (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.st46.s2.ffi).mlx.next && Nat.ble (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.st46.s0.ffi).mlx.nnext (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.st46.s2.ffi).mlx.nnext) = true

end Host.Load.Run.Tpl
end

section -- SiteF46
set_option Elab.async false
namespace Host.Load.Run.Tpl
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
open Host.Ts Host.Ts.Sim Host.Ts.Sim.Template

/-! Call site 46 of chain `PRE_first_tail_x15_r0_body`: `Conv.site_merge`'s footprint facts. -/

kernel_rfl PRE_first_tail_x15_r0_body.wrNodupB46 : nodupT PRE_first_tail_x15_r0_body.st46.wr PTrie.nil = true
theorem PRE_first_tail_x15_r0_body.wrNodup46 : PRE_first_tail_x15_r0_body.st46.wr.Nodup := (nodupT_sound PRE_first_tail_x15_r0_body.wrNodupB46).2
kernel_rfl PRE_first_tail_x15_r0_body.wrBoundB46 : PRE_first_tail_x15_r0_body.st46.wr.all (fun b => Nat.blt (b / 4096) (4 ^ 31)) = true
theorem PRE_first_tail_x15_r0_body.wrBound46 : ∀ b ∈ PRE_first_tail_x15_r0_body.st46.wr, b / 4096 < 4 ^ 31 := fun b hb => Nat.blt_eq.mp (List.all_eq_true.mp PRE_first_tail_x15_r0_body.wrBoundB46 b hb)
noncomputable def PRE_first_tail_x15_r0_body.trFr46 := PRE_first_tail_x15_r0_body.st46.s2.trace.take 0
kernel_rfl PRE_first_tail_x15_r0_body.traceEq46 : PRE_first_tail_x15_r0_body.st46.s2.trace = PRE_first_tail_x15_r0_body.trFr46 ++ PRE_first_tail_x15_r0_body.st46.s0.trace
theorem PRE_first_tail_x15_r0_body.trace46 : ∃ fr, PRE_first_tail_x15_r0_body.st46.s2.trace = fr ++ PRE_first_tail_x15_r0_body.st46.s0.trace := ⟨_, PRE_first_tail_x15_r0_body.traceEq46⟩

-- the caller's wide frames at the instance's start (`Conv.isolateW`'s `W0` under `Map.id`) and their `WFix`
def PRE_first_tail_x15_r0_body.wide46 : List (Nat × WFrame) := [(4910, .memo [])]
kernel_rfl PRE_first_tail_x15_r0_body.wfixB46 : (PRE_first_tail_x15_r0_body.wide46.all fun p => wfixB Map.id (presentB PRE_first_tail_x15_r0_body.st46.s0) p.2) = true
theorem PRE_first_tail_x15_r0_body.wfix46 : ∀ p ∈ PRE_first_tail_x15_r0_body.wide46, WFix Map.id (Present PRE_first_tail_x15_r0_body.st46.s0) p.2 :=
  fun p hp => wfix_of (List.all_eq_true.mp PRE_first_tail_x15_r0_body.wfixB46 p hp)

end Host.Load.Run.Tpl
end

section -- SiteL46
set_option Elab.async false
namespace Host.Load.Run.Tpl
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
open Host.Ts Host.Ts.Sim Host.Ts.Sim.Template

/-! The call link's facts at call site 46 of chain `PRE_first_tail_x15_r0_body`: the instance's start server, its footprint (`Conv.StageFoot`), the
merged state `PRE_first_tail_x15_r0_body.s456`'s framed arrays as the chain start's extended (`arrExt_of`, `numRefs_of`). -/

kernel_rfl PRE_first_tail_x15_r0_body.srvO46 : PRE_first_tail_x15_r0_body.st46.S0.oracle = PRE_first_tail_x15_r0_body.st46.OR
kernel_rfl PRE_first_tail_x15_r0_body.wr0B46 : PRE_first_tail_x15_r0_body.st46.wr.all (fun b => !Nat.blt b PRE_first_tail_x15_r0_body.st46.s0.next || (PRE_first_tail_x15_r0_body.st46.s0.heap.get b).isSome) = true
theorem PRE_first_tail_x15_r0_body.stFoot46 : Conv.StageFoot PRE_first_tail_x15_r0_body.st46.wr PRE_first_tail_x15_r0_body.st46.s0 PRE_first_tail_x15_r0_body.st46.s2 :=
  stageFoot_of PRE_first_tail_x15_r0_body.st46.heapFoot PRE_first_tail_x15_r0_body.wrNodup46 PRE_first_tail_x15_r0_body.wrBound46 PRE_first_tail_x15_r0_body.wr0B46 PRE_first_tail_x15_r0_body.st46.grows

/-- **The relation at the merged state** from the relation at the merge (`Conv.site_merge`'s; `merged_relB`). -/
theorem PRE_first_tail_x15_r0_body.merged46 {FR : Map → Nat → PRE_first_tail_x15_r0_body.st46.F.S → PRE_first_tail_x15_r0_body.st46.F.S → Prop} {W : Nat → Option WFrame} {stk : List Frame} {M : Map}
    {ν : Nat → F64} {K : Host.Ts.Sim.Ctx} {S : SSrv} {t : St PRE_first_tail_x15_r0_body.st46.F.S} {C : CSrv} {n0 : Nat}
    (h : RelB PRE_first_tail_x15_r0_body.st46.F FR W stk M ν K (Conv.mergeSt Map.id (Map.id.res n0 n0) PRE_first_tail_x15_r0_body.rs46 PRE_first_tail_x15_r0_body.st46.wr PRE_first_tail_x15_r0_body.s455 PRE_first_tail_x15_r0_body.st46.s2 PRE_first_tail_x15_r0_body.st46.s0
      PRE_first_tail_x15_r0_body.st46.s2.ffi) S t C) : RelB PRE_first_tail_x15_r0_body.st46.F FR W stk M ν K PRE_first_tail_x15_r0_body.s456 S t C :=
  merged_relB PRE_first_tail_x15_r0_body.iso46 PRE_first_tail_x15_r0_body.stFoot46 PRE_first_tail_x15_r0_body.wrNodup46 PRE_first_tail_x15_r0_body.wrBound46 PRE_first_tail_x15_r0_body.trace46 PRE_first_tail_x15_r0_body.mheap46
    PRE_first_tail_x15_r0_body.mnext46 PRE_first_tail_x15_r0_body.mctl46 PRE_first_tail_x15_r0_body.mstack46 PRE_first_tail_x15_r0_body.mjobs46 PRE_first_tail_x15_r0_body.mffi46 PRE_first_tail_x15_r0_body.mtrace46 PRE_first_tail_x15_r0_body.mstores46 h

def PRE_first_tail_x15_r0_body.arrEl46_2665 : List Val := []
kernel_rfl PRE_first_tail_x15_r0_body.arrE46_2665 : arrOf PRE_first_tail_x15_r0_body.s456 2665 = arrOf PRE_first_tail_x15_r0_body.s0 2665 ++ PRE_first_tail_x15_r0_body.arrEl46_2665
kernel_rfl PRE_first_tail_x15_r0_body.arrA46_2665 : isArrB PRE_first_tail_x15_r0_body.s456 2665 = true
theorem PRE_first_tail_x15_r0_body.arr46_2665 : ∃ o, PRE_first_tail_x15_r0_body.s456.heap.get 2665 = some (.obj o) ∧ o.kind = .array (arrOf PRE_first_tail_x15_r0_body.s0 2665 ++ PRE_first_tail_x15_r0_body.arrEl46_2665) :=
  arrExt_of PRE_first_tail_x15_r0_body.arrE46_2665 PRE_first_tail_x15_r0_body.arrA46_2665
kernel_rfl PRE_first_tail_x15_r0_body.arrN46_2665 : numRefsB PRE_first_tail_x15_r0_body.S0.tab.length PRE_first_tail_x15_r0_body.arrEl46_2665 = true
theorem PRE_first_tail_x15_r0_body.arrR46_2665 : Prefill.NumRefs PRE_first_tail_x15_r0_body.S0.tab.length PRE_first_tail_x15_r0_body.arrEl46_2665 := numRefs_of PRE_first_tail_x15_r0_body.arrN46_2665

def PRE_first_tail_x15_r0_body.arrEl46_2673467 : List Val := []
kernel_rfl PRE_first_tail_x15_r0_body.arrE46_2673467 : arrOf PRE_first_tail_x15_r0_body.s456 2673467 = arrOf PRE_first_tail_x15_r0_body.s0 2673467 ++ PRE_first_tail_x15_r0_body.arrEl46_2673467
kernel_rfl PRE_first_tail_x15_r0_body.arrA46_2673467 : isArrB PRE_first_tail_x15_r0_body.s456 2673467 = true
theorem PRE_first_tail_x15_r0_body.arr46_2673467 : ∃ o, PRE_first_tail_x15_r0_body.s456.heap.get 2673467 = some (.obj o) ∧ o.kind = .array (arrOf PRE_first_tail_x15_r0_body.s0 2673467 ++ PRE_first_tail_x15_r0_body.arrEl46_2673467) :=
  arrExt_of PRE_first_tail_x15_r0_body.arrE46_2673467 PRE_first_tail_x15_r0_body.arrA46_2673467
kernel_rfl PRE_first_tail_x15_r0_body.arrN46_2673467 : numRefsB PRE_first_tail_x15_r0_body.S0.tab.length PRE_first_tail_x15_r0_body.arrEl46_2673467 = true
theorem PRE_first_tail_x15_r0_body.arrR46_2673467 : Prefill.NumRefs PRE_first_tail_x15_r0_body.S0.tab.length PRE_first_tail_x15_r0_body.arrEl46_2673467 := numRefs_of PRE_first_tail_x15_r0_body.arrN46_2673467

kernel_rfl PRE_first_tail_x15_r0_body.w4910k46 : isArrB PRE_first_tail_x15_r0_body.s456 4910 = false
theorem PRE_first_tail_x15_r0_body.keep46 (q : List Val) : Host.Ts.Sim.Prefill.KeepsAtW (framesP PRE_first_tail_x15_r0_body.s0 q) PRE_first_tail_x15_r0_body.s456 := by
  intro a pre pre' hx o es ho hk
  unfold framesP at hx
  simp only at hx
  cases h1 : Nat.beq a 2665
  · cases h2 : Nat.beq a 4910
    · rw [h1, h2] at hx; cases hx
    · have := Nat.eq_of_beq_eq_true h2; subst this
      rw [h1, h2] at hx; cases hx
      exact (notArr_of PRE_first_tail_x15_r0_body.w4910k46 ho hk).elim
  · have := Nat.eq_of_beq_eq_true h1; subst this
    rw [h1] at hx; cases hx
    obtain ⟨o', ho', hk'⟩ := PRE_first_tail_x15_r0_body.arr46_2665
    rw [ho] at ho'; cases ho'
    rw [hk'] at hk; cases hk
    simp [PRE_first_tail_x15_r0_body.arrEl46_2665]

end Host.Load.Run.Tpl
end

section -- SiteZ46
set_option Elab.async false
namespace Host.Load.Run.Tpl
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
open Host.Ts Host.Ts.Sim Host.Ts.Sim.Template

/-! The compaction's state shift at call site 46 of chain `PRE_first_tail_x15_r0_body` (`Conv.compact_shift`): the call `PRE_first_tail_x15_r0_body.s455`, the merged
state `PRE_first_tail_x15_r0_body.s456`, the canonical state `PRE_first_tail_x15_r0_body.s457`; its frames [2665,2673467,2673472,2673473] (kept arrays [2665,2673467]). -/

-- the map's places and counters
kernel_rfl PRE_first_tail_x15_r0_body.zpl46 : PRE_first_tail_x15_r0_body.pl46.all (Nat.ble PRE_first_tail_x15_r0_body.s455.next) = true
kernel_rfl PRE_first_tail_x15_r0_body.zplnd46 : nodupT PRE_first_tail_x15_r0_body.pl46 PTrie.nil = true
kernel_rfl PRE_first_tail_x15_r0_body.zn146 : Nat.ble PRE_first_tail_x15_r0_body.s455.next 2711339 = true
kernel_rfl PRE_first_tail_x15_r0_body.zfirst46 : Nat.ble aFirst PRE_first_tail_x15_r0_body.s455.next = true
kernel_rfl PRE_first_tail_x15_r0_body.zscn46 : PRE_first_tail_x15_r0_body.s457.next = PRE_first_tail_x15_r0_body.s455.next + PRE_first_tail_x15_r0_body.pl46.length
kernel_rfl PRE_first_tail_x15_r0_body.zsmn46 : PRE_first_tail_x15_r0_body.s456.next = 2711339
kernel_rfl PRE_first_tail_x15_r0_body.zgrow46 : Nat.ble PRE_first_tail_x15_r0_body.s457.next PRE_first_tail_x15_r0_body.s456.next = true
-- the tables
kernel_rfl PRE_first_tail_x15_r0_body.zfresh46 : PRE_first_tail_x15_r0_body.S455.tab.all (fun e => PRE_first_tail_x15_r0_body.cws46.all fun v => e.noVar v) = true
kernel_rfl PRE_first_tail_x15_r0_body.zcnd46 : nodupT PRE_first_tail_x15_r0_body.cws46 PTrie.nil = true
kernel_rfl PRE_first_tail_x15_r0_body.znrHi46 : PRE_first_tail_x15_r0_body.nr46.all (fun r => Nat.blt r PRE_first_tail_x15_r0_body.S456.tab.length) = true
-- the frames: every framed address below the call's counter; the kept arrays the chain start's, extended in the merged state
kernel_rfl PRE_first_tail_x15_r0_body.zfrlt46 : [2665, 2673467, 2673472, 2673473].all (fun a => Nat.blt a PRE_first_tail_x15_r0_body.s455.next) = true
kernel_rfl PRE_first_tail_x15_r0_body.zg46_2665 : PRE_first_tail_x15_r0_body.s457.heap.get 2665 = some (.obj (objOf PRE_first_tail_x15_r0_body.s457 2665))
kernel_rfl PRE_first_tail_x15_r0_body.zk46_2665 : (objOf PRE_first_tail_x15_r0_body.s457 2665).kind = .array (arrOf PRE_first_tail_x15_r0_body.s0 2665)
kernel_rfl PRE_first_tail_x15_r0_body.zm46_2665 : PRE_first_tail_x15_r0_body.s456.heap.get 2665 = some (.obj { PRE_first_tail_x15_r0_body.kappa46.obj (objOf PRE_first_tail_x15_r0_body.s457 2665) with
  kind := .array (arrOf PRE_first_tail_x15_r0_body.s0 2665 ++ (arrOf PRE_first_tail_x15_r0_body.s456 2665).drop (arrOf PRE_first_tail_x15_r0_body.s0 2665).length) })
kernel_rfl PRE_first_tail_x15_r0_body.zg46_2673467 : PRE_first_tail_x15_r0_body.s457.heap.get 2673467 = some (.obj (objOf PRE_first_tail_x15_r0_body.s457 2673467))
kernel_rfl PRE_first_tail_x15_r0_body.zk46_2673467 : (objOf PRE_first_tail_x15_r0_body.s457 2673467).kind = .array (arrOf PRE_first_tail_x15_r0_body.s0 2673467)
kernel_rfl PRE_first_tail_x15_r0_body.zm46_2673467 : PRE_first_tail_x15_r0_body.s456.heap.get 2673467 = some (.obj { PRE_first_tail_x15_r0_body.kappa46.obj (objOf PRE_first_tail_x15_r0_body.s457 2673467) with
  kind := .array (arrOf PRE_first_tail_x15_r0_body.s0 2673467 ++ (arrOf PRE_first_tail_x15_r0_body.s456 2673467).drop (arrOf PRE_first_tail_x15_r0_body.s0 2673467).length) })
kernel_rfl PRE_first_tail_x15_r0_body.zw46_4910 : (PRE_first_tail_x15_r0_body.s457.heap.get 4910).isSome = true
kernel_rfl PRE_first_tail_x15_r0_body.zw46_2673472 : (PRE_first_tail_x15_r0_body.s457.heap.get 2673472).isSome = true
kernel_rfl PRE_first_tail_x15_r0_body.zw46_2673473 : (PRE_first_tail_x15_r0_body.s457.heap.get 2673473).isSome = true
-- the heap: the changed list in range, holding the stage's written and fresh addresses; the canonical side's image
kernel_rfl PRE_first_tail_x15_r0_body.zclbd46 : PRE_first_tail_x15_r0_body.cl46.all (fun b => Nat.blt (b / 4096) (4 ^ 31)) = true
kernel_rfl PRE_first_tail_x15_r0_body.zwr46 : PRE_first_tail_x15_r0_body.st46.wr.all (fun b => !Nat.blt b PRE_first_tail_x15_r0_body.s455.next || PRE_first_tail_x15_r0_body.cl46.contains b) = true
def PRE_first_tail_x15_r0_body.zl46 : List Nat := PRE_first_tail_x15_r0_body.cl46.filter fun a => !(List.contains [2665, 2673467] a)
kernel_rfl PRE_first_tail_x15_r0_body.zimgE46 : PRE_first_tail_x15_r0_body.zl46.map (fun a => PRE_first_tail_x15_r0_body.s456.heap.get (PRE_first_tail_x15_r0_body.kappa46.a a)) = PRE_first_tail_x15_r0_body.zl46.map (fun a => (PRE_first_tail_x15_r0_body.s457.heap.get a).map PRE_first_tail_x15_r0_body.kappa46.hobj)
theorem PRE_first_tail_x15_r0_body.zimg46 : HeapImg PRE_first_tail_x15_r0_body.kappa46 PRE_first_tail_x15_r0_body.s457 PRE_first_tail_x15_r0_body.s456 PRE_first_tail_x15_r0_body.zl46 := PRE_first_tail_x15_r0_body.zimgE46
-- the roots and their supports
kernel_rfl PRE_first_tail_x15_r0_body.zctl46 : PRE_first_tail_x15_r0_body.s456.ctl = PRE_first_tail_x15_r0_body.kappa46.ctl PRE_first_tail_x15_r0_body.s457.ctl
kernel_rfl PRE_first_tail_x15_r0_body.zstack46 : PRE_first_tail_x15_r0_body.s456.stack = PRE_first_tail_x15_r0_body.s457.stack.map PRE_first_tail_x15_r0_body.kappa46.frame
kernel_rfl PRE_first_tail_x15_r0_body.zjobs46 : PRE_first_tail_x15_r0_body.s456.jobs = PRE_first_tail_x15_r0_body.s457.jobs.map PRE_first_tail_x15_r0_body.kappa46.job
kernel_rfl PRE_first_tail_x15_r0_body.zstores46 : PRE_first_tail_x15_r0_body.s456.stores = PRE_first_tail_x15_r0_body.kappa46.stores PRE_first_tail_x15_r0_body.s457.stores
kernel_rfl PRE_first_tail_x15_r0_body.zroots46 : checkRootsSupp PRE_first_tail_x15_r0_body.s457 2045 = true
kernel_rfl PRE_first_tail_x15_r0_body.znC46 : PRE_first_tail_x15_r0_body.S455.tab.length + PRE_first_tail_x15_r0_body.cws46.length = 2045
-- the map as `Conv.compact_shift` states it (the call's counters for the literals)
kernel_rfl PRE_first_tail_x15_r0_body.zkap46 : PRE_first_tail_x15_r0_body.kappa46 = Conv.Map.compact PRE_first_tail_x15_r0_body.s455.next 2711339 PRE_first_tail_x15_r0_body.S455.tab.length PRE_first_tail_x15_r0_body.pl46 (PRE_first_tail_x15_r0_body.nr46.map NumV.ref) PRE_first_tail_x15_r0_body.kd46.big
  PRE_first_tail_x15_r0_body.kd46.region PRE_first_tail_x15_r0_body.kd46.nodeF
-- the bridge inactive at the canonical state (`Conv.FullShiftQ.toX`; the merged state's bridge is the canonical's: cbridge)
theorem PRE_first_tail_x15_r0_body.zbin46 : (Host.Ts.Sim.Full.bridgeOf PRE_first_tail_x15_r0_body.s457.ffi).active = false := (Host.Load.Boot.replay_active Host.Load.Run.Prompt.P.oblog2818)
-- the JS bookkeeping's step (`Conv.JClean.step` over the changed list) and the canonical roots' bigint freedom
kernel_rfl PRE_first_tail_x15_r0_body.zjc46 : Conv.jcleanListB (⟨19118, 16203, 2711337, 2045⟩ : Conv.Cnt) PRE_first_tail_x15_r0_body.s457 PRE_first_tail_x15_r0_body.cl46 = true
kernel_rfl PRE_first_tail_x15_r0_body.zrootsB46 : noBigRootsP (fun i => !Conv.oldBigB (⟨19118, 16203, 2711337, 2045⟩ : Conv.Cnt) i) PRE_first_tail_x15_r0_body.s457.trace PRE_first_tail_x15_r0_body.s457 = true
kernel_rfl PRE_first_tail_x15_r0_body.zhm46 : Nat.ble (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s0.ffi).mlx.nnext 16203 = true
theorem PRE_first_tail_x15_r0_body.cjcl46 (h : Conv.JClean (⟨19118, 16203, 2711337, 2045⟩ : Conv.Cnt) PRE_first_tail_x15_r0_body.s455) : Conv.JClean (⟨19118, 16203, 2711337, 2045⟩ : Conv.Cnt) PRE_first_tail_x15_r0_body.s457 :=
  Conv.JClean.step h (Conv.Cnt.le_of_leB PRE_first_tail_x15_r0_body.cle46)
    (Conv.heap_off_setAll PRE_first_tail_x15_r0_body.cheap46 fun a ha => Nat.blt_eq.mp (List.all_eq_true.mp PRE_first_tail_x15_r0_body.zclbd46 a ha)) PRE_first_tail_x15_r0_body.zjc46

end Host.Load.Run.Tpl
end

section -- st46/TypedLast
set_option Elab.async false
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
namespace Host.Load.Run.Tpl
open Host.Ts Host.Ts.Sim Host.Ts.Sim.Template

boot_rfl PRE_first_tail_x15_r0_body.st46.bodyLast from PRE_first_tail_x15_r0_body.st46.s1 to PRE_first_tail_x15_r0_body.st46.s2 :
  interpS (step PRE_first_tail_x15_r0_body.st46.F PRE_first_tail_x15_r0_body.st46.s1).run PRE_first_tail_x15_r0_body.st46.S1 = some (PRE_first_tail_x15_r0_body.st46.s2, PRE_first_tail_x15_r0_body.st46.S2)
kernel_rfl PRE_first_tail_x15_r0_body.st46.bodyHalt : isHalt PRE_first_tail_x15_r0_body.st46.s1.ctl = false
kernel_rfl PRE_first_tail_x15_r0_body.st46.bodyTopCheck : noBlockTop PRE_first_tail_x15_r0_body.st46.s2.stack = true

end Host.Load.Run.Tpl
end

section -- st46/TypedOk
set_option Elab.async false
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
namespace Host.Load.Run.Tpl
open Host.Ts Host.Ts.Sim Host.Ts.Sim.Template

noncomputable def PRE_first_tail_x15_r0_body.st46.bodyOkL (bytes : List Byte) (rows : Nat) : St PRE_first_tail_x15_r0_body.st46.F.S → SSrv → Bool :=
  okLocal (Host.Ts.Sim.Compose.VWFrames.bodyOk bytes rows)

noncomputable def PRE_first_tail_x15_r0_body.st46.bodyOkLN (bytes : List Byte) (rows : Nat) : St PRE_first_tail_x15_r0_body.st46.F.S → FSrv → Bool :=
  okLocalN (Host.Ts.Sim.Compose.VWFrames.bodyOkN bytes rows)

theorem PRE_first_tail_x15_r0_body.st46.bodyOkLN_ok (bytes : List Byte) (rows : Nat) (s : St PRE_first_tail_x15_r0_body.st46.F.S) (c : FSrv) (h : c.Wf) :
    PRE_first_tail_x15_r0_body.st46.bodyOkLN bytes rows s c = PRE_first_tail_x15_r0_body.st46.bodyOkL bytes rows s c.toS :=
  okLocalN_ok (Host.Ts.Sim.Compose.VWFrames.bodyOkN_ok bytes rows) s c h

kernel_rfl PRE_first_tail_x15_r0_body.st46.bodyAccepted0 :
  (fun (bytes : List Byte) (rows : Nat) => PRE_first_tail_x15_r0_body.st46.bodyOkL bytes rows PRE_first_tail_x15_r0_body.st46.s0 PRE_first_tail_x15_r0_body.st46.S0) = fun _ _ => true

kernel_rfl PRE_first_tail_x15_r0_body.st46.bodyAccepted1 :
  (fun (bytes : List Byte) (rows : Nat) => PRE_first_tail_x15_r0_body.st46.bodyOkL bytes rows PRE_first_tail_x15_r0_body.st46.s1 PRE_first_tail_x15_r0_body.st46.S1) = fun _ _ => true

end Host.Load.Run.Tpl
end

section -- st46/TypedK0
set_option Elab.async false
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
namespace Host.Load.Run.Tpl
open Host.Ts Host.Ts.Sim Host.Ts.Sim.Template

boot_rfl PRE_first_tail_x15_r0_body.st46.bodyK0F from PRE_first_tail_x15_r0_body.st46.s0 to PRE_first_tail_x15_r0_body.st46.s1 :
  (fun (bytes : List Byte) (rows : Nat) => runOkS PRE_first_tail_x15_r0_body.st46.F (PRE_first_tail_x15_r0_body.st46.bodyOkLN bytes rows)
    ((nth? PRE_first_tail_x15_r0_body.st46.ks 0).getD 0) PRE_first_tail_x15_r0_body.st46.s0 PRE_first_tail_x15_r0_body.st46.S0) = fun _ _ => some (PRE_first_tail_x15_r0_body.st46.s1, PRE_first_tail_x15_r0_body.st46.S1)
theorem PRE_first_tail_x15_r0_body.st46.bodyK0 :
  (fun (bytes : List Byte) (rows : Nat) => runOk PRE_first_tail_x15_r0_body.st46.F (PRE_first_tail_x15_r0_body.st46.bodyOkL bytes rows)
    ((nth? PRE_first_tail_x15_r0_body.st46.ks 0).getD 0) PRE_first_tail_x15_r0_body.st46.s0 PRE_first_tail_x15_r0_body.st46.S0) = fun _ _ => some (PRE_first_tail_x15_r0_body.st46.s1, PRE_first_tail_x15_r0_body.st46.S1) :=
  runOk_fun_of_runOkS PRE_first_tail_x15_r0_body.st46.bodyOkLN_ok PRE_first_tail_x15_r0_body.st46.bodyK0F
end Host.Load.Run.Tpl
end

section -- st46/TypedTpl
set_option Elab.async false
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
namespace Host.Load.Run.Tpl
open Host.Ts Host.Ts.Sim Host.Ts.Sim.Template

theorem PRE_first_tail_x15_r0_body.st46.bodyRun (bytes : List Byte) (rows : Nat) :
    runOk PRE_first_tail_x15_r0_body.st46.F (PRE_first_tail_x15_r0_body.st46.bodyOkL bytes rows) 27 PRE_first_tail_x15_r0_body.st46.s0 PRE_first_tail_x15_r0_body.st46.S0 = some (PRE_first_tail_x15_r0_body.st46.s1, PRE_first_tail_x15_r0_body.st46.S1) :=
  (congrFun (congrFun PRE_first_tail_x15_r0_body.st46.bodyK0 bytes) rows)

theorem PRE_first_tail_x15_r0_body.st46.bodyLocal (bytes : List Byte) (rows : Nat) : ∀ s S, PRE_first_tail_x15_r0_body.st46.bodyOkL bytes rows s S = true → Disp.localB s = true := okLocal_localB

noncomputable def PRE_first_tail_x15_r0_body.st46.bodyTpl (bytes : List Byte) (rows : Nat) : Host.Ts.Sim.Stage.StageTpl PRE_first_tail_x15_r0_body.st46.F (PRE_first_tail_x15_r0_body.st46.bodyOkL bytes rows) where
  s0 := PRE_first_tail_x15_r0_body.st46.s0
  S0 := PRE_first_tail_x15_r0_body.st46.S0
  s1 := PRE_first_tail_x15_r0_body.st46.s1
  S1 := PRE_first_tail_x15_r0_body.st46.S1
  s2 := PRE_first_tail_x15_r0_body.st46.s2
  S2 := PRE_first_tail_x15_r0_body.st46.S2
  n := 27
  ok0 := congrFun (congrFun PRE_first_tail_x15_r0_body.st46.bodyAccepted0 bytes) rows
  run := PRE_first_tail_x15_r0_body.st46.bodyRun bytes rows
  ok1 := congrFun (congrFun PRE_first_tail_x15_r0_body.st46.bodyAccepted1 bytes) rows
  halt := PRE_first_tail_x15_r0_body.st46.bodyHalt
  last := PRE_first_tail_x15_r0_body.st46.bodyLast
  top := noBlockTop_sound PRE_first_tail_x15_r0_body.st46.bodyTopCheck
end Host.Load.Run.Tpl
end

section -- SiteC47
set_option Elab.async false
namespace Host.Load.Run.Tpl
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
open Host.Ts Host.Ts.Sim Host.Ts.Sim.Template

/-! The compaction after the merge at call site 47 of chain `PRE_first_tail_x15_r0_body` (`Conv.compact`, `Conv.full_compactQ`): the canonical
state `PRE_first_tail_x15_r0_body.s461` (the stage's results at canonical places, its trace the call's) under `PRE_first_tail_x15_r0_body.kappa47` into the merged state
`PRE_first_tail_x15_r0_body.s460`. -/

def PRE_first_tail_x15_r0_body.pl47 : List Nat := [2711644]
def PRE_first_tail_x15_r0_body.nr47 : List Nat := []
/-- The native part of the compaction map (canonical → merged handles and nodes: its `big`, `region`, `nodeF`). -/
def PRE_first_tail_x15_r0_body.kd47 : RData :=
  ⟨2711626, 2711645, Stage.setAll PTrie.nil [(2711625, 2711644)], Stage.setAll PTrie.nil [],
   19125, 19125, 16207, 16207, Stage.setAll PTrie.nil [],
   Stage.setAll PTrie.nil []⟩
/-- **The compaction map.** -/
noncomputable def PRE_first_tail_x15_r0_body.kappa47 : Map :=
  Conv.Map.compact 2711625 2711645 2062 PRE_first_tail_x15_r0_body.pl47 (PRE_first_tail_x15_r0_body.nr47.map NumV.ref) PRE_first_tail_x15_r0_body.kd47.big
    PRE_first_tail_x15_r0_body.kd47.region PRE_first_tail_x15_r0_body.kd47.nodeF
/-- The canonical result variables and their images, the merged state's entries (`Conv.compactθ`). -/
def PRE_first_tail_x15_r0_body.cws47 : List Nat := []
noncomputable def PRE_first_tail_x15_r0_body.crs47 : List SymE := PRE_first_tail_x15_r0_body.nr47.map fun r => (nth? PRE_first_tail_x15_r0_body.S460.tab r).getD (.var 0)
noncomputable def PRE_first_tail_x15_r0_body.ctheta47 : Nat → SymE := Conv.compactθ PRE_first_tail_x15_r0_body.cws47 PRE_first_tail_x15_r0_body.crs47
/-- The call's entries the stage wrote (renamed in the canonical state with the results). -/
def PRE_first_tail_x15_r0_body.wrB47 : List Nat := [2665, 2673467]

kernel_rfl PRE_first_tail_x15_r0_body.ctab47 : PRE_first_tail_x15_r0_body.S461.tab = PRE_first_tail_x15_r0_body.S459.tab ++ PRE_first_tail_x15_r0_body.cws47.map SymE.var
kernel_rfl PRE_first_tail_x15_r0_body.ctrace47 : PRE_first_tail_x15_r0_body.s461.trace = PRE_first_tail_x15_r0_body.s459.trace
kernel_rfl PRE_first_tail_x15_r0_body.cnext47 : PRE_first_tail_x15_r0_body.s461.next = 2711626
kernel_rfl PRE_first_tail_x15_r0_body.ccounters47 : ((Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s461.ffi).mlx.next, (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s461.ffi).mlx.nnext) = (19125, 16207)
-- the merged state's readback queue, carried to the canonical state (`Conv.FullShiftQ.tokens`, `tokSupp`)
kernel_rfl PRE_first_tail_x15_r0_body.cqueue47 : (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s460.ffi).mlx.tokens = (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s461.ffi).mlx.tokens.map PRE_first_tail_x15_r0_body.kappa47.nv
kernel_rfl PRE_first_tail_x15_r0_body.ctokSupp47 : (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s461.ffi).mlx.tokens.all (bSN 2062) = true
-- the written and the result entries carry no bigint of the canonical fresh band [next, E) and no fresh region
kernel_rfl PRE_first_tail_x15_r0_body.cclean47 : Conv.cleanListB 19125 131072 (fun r => Nat.ble 76500 r) PRE_first_tail_x15_r0_body.s461
    (PRE_first_tail_x15_r0_body.wrB47 ++ (List.range 1).map (2711625 + ·)) = true
kernel_rfl PRE_first_tail_x15_r0_body.cbigs47 : bigsOutB 19125 131072 (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s461.ffi).mlx = true

end Host.Load.Run.Tpl
end

section -- SiteK47
set_option Elab.async false
namespace Host.Load.Run.Tpl
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
open Host.Ts Host.Ts.Sim Host.Ts.Sim.Template

/-! The canonical state's closedness from the call's (`Conv.closed_of_callB`, `Conv.sst_of_callB`): it keeps the call's entries
off the written and the result ones (`PRE_first_tail_x15_r0_body.cl47`; natively the written and result handles, the result nodes, the written
and result items), and those are checked. -/

def PRE_first_tail_x15_r0_body.cl47 : List Nat := [2665, 2673467, 2711625]
def PRE_first_tail_x15_r0_body.clo47 : List Nat := []
def PRE_first_tail_x15_r0_body.cln47 : List Nat := []
def PRE_first_tail_x15_r0_body.cli47 : List Nat := []
kernel_rfl PRE_first_tail_x15_r0_body.cheap47 : PRE_first_tail_x15_r0_body.s461.heap = Stage.setAll PRE_first_tail_x15_r0_body.s459.heap (PRE_first_tail_x15_r0_body.cl47.filterMap fun a => (PRE_first_tail_x15_r0_body.s461.heap.get a).map (a, ·))
kernel_rfl PRE_first_tail_x15_r0_body.cnextLe47 : Nat.ble PRE_first_tail_x15_r0_body.s459.next PRE_first_tail_x15_r0_body.s461.next = true
kernel_rfl PRE_first_tail_x15_r0_body.ckeepP47 : Conv.keptPresentB PRE_first_tail_x15_r0_body.s459 PRE_first_tail_x15_r0_body.s461 PRE_first_tail_x15_r0_body.cl47 = true
kernel_rfl PRE_first_tail_x15_r0_body.csupp47 : Conv.suppListB PRE_first_tail_x15_r0_body.s461 2062 PRE_first_tail_x15_r0_body.cl47 = true
kernel_rfl PRE_first_tail_x15_r0_body.cbound47 : Conv.boundListB PRE_first_tail_x15_r0_body.s461 PRE_first_tail_x15_r0_body.cl47 = true
kernel_rfl PRE_first_tail_x15_r0_body.cnodesK47 : (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s461.ffi).mlx.nodes = Stage.setAll (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s459.ffi).mlx.nodes (PRE_first_tail_x15_r0_body.cln47.filterMap fun i => ((Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s461.ffi).mlx.nodes.get i).map (i, ·))
kernel_rfl PRE_first_tail_x15_r0_body.cobjsK47 : (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s461.ffi).mlx.objs = Stage.setAll (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s459.ffi).mlx.objs (PRE_first_tail_x15_r0_body.clo47.filterMap fun i => ((Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s461.ffi).mlx.objs.get i).map (i, ·))
kernel_rfl PRE_first_tail_x15_r0_body.citemsK47 : (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s461.ffi).mlx.items = Stage.setAll (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s459.ffi).mlx.items (PRE_first_tail_x15_r0_body.cli47.filterMap fun i => ((Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s461.ffi).mlx.items.get i).map (i, ·))
kernel_rfl PRE_first_tail_x15_r0_body.csst47 : Conv.sstListB 2062 (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s461.ffi).mlx PRE_first_tail_x15_r0_body.cln47 PRE_first_tail_x15_r0_body.clo47 PRE_first_tail_x15_r0_body.cli47 = true

end Host.Load.Run.Tpl
end

section -- SiteCl47
set_option Elab.async false
namespace Host.Load.Run.Tpl
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
open Host.Ts Host.Ts.Sim Host.Ts.Sim.Template

kernel_rfl PRE_first_tail_x15_r0_body.ckA47 : (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s461.ffi).mlx.arrs = Stage.setAll (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s459.ffi).mlx.arrs (PRE_first_tail_x15_r0_body.clo47.filterMap fun i => ((Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s461.ffi).mlx.arrs.get i).map (i, ·))
kernel_rfl PRE_first_tail_x15_r0_body.cbd47 : (PRE_first_tail_x15_r0_body.clo47 ++ PRE_first_tail_x15_r0_body.cln47 ++ PRE_first_tail_x15_r0_body.cli47).all (fun i => Nat.blt (i / 4096) (4 ^ 31)) = true
kernel_rfl PRE_first_tail_x15_r0_body.cle47 : Conv.Cnt.leB (⟨19125, 16207, 2711625, 2062⟩ : Conv.Cnt) (⟨19125, 16207, 2711626, 2062⟩ : Conv.Cnt) = true
kernel_rfl PRE_first_tail_x15_r0_body.cck47 : Conv.ncleanListB (⟨19125, 16207, 2711626, 2062⟩ : Conv.Cnt) (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s461.ffi).mlx PRE_first_tail_x15_r0_body.clo47 PRE_first_tail_x15_r0_body.cln47 PRE_first_tail_x15_r0_body.cli47 = true
theorem PRE_first_tail_x15_r0_body.cncl47 (h : Conv.NClean (⟨19125, 16207, 2711625, 2062⟩ : Conv.Cnt) (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s459.ffi).mlx) : Conv.NClean (⟨19125, 16207, 2711626, 2062⟩ : Conv.Cnt) (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s461.ffi).mlx :=
  Conv.NClean.stepKeep h PRE_first_tail_x15_r0_body.cle47 PRE_first_tail_x15_r0_body.ckA47 PRE_first_tail_x15_r0_body.cobjsK47 PRE_first_tail_x15_r0_body.cnodesK47 PRE_first_tail_x15_r0_body.citemsK47 PRE_first_tail_x15_r0_body.cbd47 PRE_first_tail_x15_r0_body.cck47

end Host.Load.Run.Tpl
end

section -- SiteS47
set_option Elab.async false
namespace Host.Load.Run.Tpl
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
open Host.Ts Host.Ts.Sim Host.Ts.Sim.Template

/-! The compaction's native shift at call site 47 from its footprint (`Conv.nshift_of_foot`), and the observers'
(`liveShift_foot`, `kernShift_foot`): `Conv.FullShiftQ` for `Conv.full_compactQ`, given the call's bookkeeping and its
relation's facts. -/

/-- The load parameters of the chain (band-free: its start's node counter as `NL` and `N0`). -/
def PRE_first_tail_x15_r0_body.Pc47 : LoadP := ⟨18151, 131072, 1099511627776, 15235, 15235, []⟩
/-- The site's band raised to the map's checked fixed-node prefix, including newly recorded closure traces. -/
def PRE_first_tail_x15_r0_body.P47 : LoadP := PRE_first_tail_x15_r0_body.Pc47.raise 16207
kernel_rfl PRE_first_tail_x15_r0_body.craise47 : Nat.ble PRE_first_tail_x15_r0_body.Pc47.N0 16207 = true
theorem PRE_first_tail_x15_r0_body.raised47 : Host.Ts.Sim.Full.Raised PRE_first_tail_x15_r0_body.Pc47 PRE_first_tail_x15_r0_body.P47 :=
  .inr ⟨16207, rfl, Nat.le_of_ble_eq_true PRE_first_tail_x15_r0_body.craise47, rfl⟩
noncomputable abbrev PRE_first_tail_x15_r0_body.cx0_47 : Host.Load.LSt := clearTokens (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s461.ffi)
noncomputable abbrev PRE_first_tail_x15_r0_body.cx1_47 : Host.Load.LSt := clearTokens (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s460.ffi)
def PRE_first_tail_x15_r0_body.khinv47 : PTrie Nat := Stage.setAll PTrie.nil []
def PRE_first_tail_x15_r0_body.kninv47 : PTrie Nat := Stage.setAll PTrie.nil []
/-- The stage's footprint: its written and fresh handles, fresh nodes, written and fresh items. -/
def PRE_first_tail_x15_r0_body.cwS47 : List Nat := []
def PRE_first_tail_x15_r0_body.cnS47 : List Nat := List.range' 16207 0
def PRE_first_tail_x15_r0_body.ciS47 : List Nat := [] ++ List.range' 16207 0

-- the small checks (`MChecks`'s)
kernel_rfl PRE_first_tail_x15_r0_body.cnh047 : PRE_first_tail_x15_r0_body.kd47.nh0 = PRE_first_tail_x15_r0_body.cx0_47.mlx.next
kernel_rfl PRE_first_tail_x15_r0_body.cnh147 : PRE_first_tail_x15_r0_body.kd47.nh1 = PRE_first_tail_x15_r0_body.cx1_47.mlx.next
kernel_rfl PRE_first_tail_x15_r0_body.cnn047 : PRE_first_tail_x15_r0_body.kd47.nn0 = PRE_first_tail_x15_r0_body.cx0_47.mlx.nnext
kernel_rfl PRE_first_tail_x15_r0_body.cnn147 : PRE_first_tail_x15_r0_body.kd47.nn1 = PRE_first_tail_x15_r0_body.cx1_47.mlx.nnext
kernel_rfl PRE_first_tail_x15_r0_body.cplo47 : (Nat.blt 0 PRE_first_tail_x15_r0_body.P47.lo && Nat.ble PRE_first_tail_x15_r0_body.P47.lo PRE_first_tail_x15_r0_body.cx0_47.mlx.next && Nat.ble PRE_first_tail_x15_r0_body.P47.lo RData.bigHi && Nat.ble RData.bigHi PRE_first_tail_x15_r0_body.P47.E) = true
kernel_rfl PRE_first_tail_x15_r0_body.ccnt47 : (Nat.ble PRE_first_tail_x15_r0_body.cx0_47.mlx.next PRE_first_tail_x15_r0_body.cx1_47.mlx.next && Nat.ble PRE_first_tail_x15_r0_body.cx0_47.mlx.nnext PRE_first_tail_x15_r0_body.cx1_47.mlx.nnext) = true
kernel_rfl PRE_first_tail_x15_r0_body.cnband47 : (Nat.blt 0 PRE_first_tail_x15_r0_body.P47.NL && Nat.ble PRE_first_tail_x15_r0_body.P47.NL PRE_first_tail_x15_r0_body.P47.N0 && Nat.ble PRE_first_tail_x15_r0_body.P47.N0 PRE_first_tail_x15_r0_body.cx0_47.mlx.nnext) = true
kernel_rfl PRE_first_tail_x15_r0_body.chbelow47 : PRE_first_tail_x15_r0_body.kd47.checkHndBelow = true
kernel_rfl PRE_first_tail_x15_r0_body.chren47 : checkRenG PRE_first_tail_x15_r0_body.kd47.hnd PRE_first_tail_x15_r0_body.khinv47 (phB PRE_first_tail_x15_r0_body.cx0_47.mlx) = true
kernel_rfl PRE_first_tail_x15_r0_body.cband47 : PRE_first_tail_x15_r0_body.kd47.checkBand PRE_first_tail_x15_r0_body.P47.lo = true
kernel_rfl PRE_first_tail_x15_r0_body.cnh1pos47 : Nat.blt 0 PRE_first_tail_x15_r0_body.kd47.nh1 = true
kernel_rfl PRE_first_tail_x15_r0_body.cnren47 : checkRenG PRE_first_tail_x15_r0_body.kd47.node PRE_first_tail_x15_r0_body.kninv47 (pnB PRE_first_tail_x15_r0_body.cx0_47.mlx) = true
kernel_rfl PRE_first_tail_x15_r0_body.cnlow47 : (PTrie.keysA PRE_first_tail_x15_r0_body.kd47.node).all (fun j => Nat.ble PRE_first_tail_x15_r0_body.P47.NL j && Nat.blt (PRE_first_tail_x15_r0_body.kd47.nodeF j) PRE_first_tail_x15_r0_body.cx1_47.mlx.nnext) = true
kernel_rfl PRE_first_tail_x15_r0_body.cabs0a47 : PRE_first_tail_x15_r0_body.cx0_47.mlx.arrs.get 0 = none
kernel_rfl PRE_first_tail_x15_r0_body.cabs0b47 : PRE_first_tail_x15_r0_body.cx0_47.mlx.objs.get 0 = none
kernel_rfl PRE_first_tail_x15_r0_body.ctok147 : PRE_first_tail_x15_r0_body.cx1_47.mlx.tokens = []
kernel_rfl PRE_first_tail_x15_r0_body.cpend47 : PRE_first_tail_x15_r0_body.cx1_47.mlx.pending = PRE_first_tail_x15_r0_body.cx0_47.mlx.pending.map PRE_first_tail_x15_r0_body.kappa47.pend
kernel_rfl PRE_first_tail_x15_r0_body.cerrh47 : PRE_first_tail_x15_r0_body.cx1_47.mlx.errh = PRE_first_tail_x15_r0_body.cx0_47.mlx.errh.map PRE_first_tail_x15_r0_body.kappa47.arg
kernel_rfl PRE_first_tail_x15_r0_body.cfiles47 : PRE_first_tail_x15_r0_body.cx1_47.mlx.files = PRE_first_tail_x15_r0_body.cx0_47.mlx.files
kernel_rfl PRE_first_tail_x15_r0_body.carch47 : PRE_first_tail_x15_r0_body.cx1_47.mlx.arch = PRE_first_tail_x15_r0_body.cx0_47.mlx.arch
kernel_rfl PRE_first_tail_x15_r0_body.csizes47 : PRE_first_tail_x15_r0_body.cx1_47.mlx.deviceSizes = PRE_first_tail_x15_r0_body.cx0_47.mlx.deviceSizes
kernel_rfl PRE_first_tail_x15_r0_body.cwired47 : PRE_first_tail_x15_r0_body.cx1_47.mlx.wired = PRE_first_tail_x15_r0_body.cx0_47.mlx.wired
kernel_rfl PRE_first_tail_x15_r0_body.chost47 : PRE_first_tail_x15_r0_body.cx1_47.host = PRE_first_tail_x15_r0_body.cx0_47.host
-- the compaction map's addresses are `PRE_first_tail_x15_r0_body.kd47`'s
kernel_rfl PRE_first_tail_x15_r0_body.ckn047 : PRE_first_tail_x15_r0_body.kd47.n0 = 2711626
kernel_rfl PRE_first_tail_x15_r0_body.ckn147 : PRE_first_tail_x15_r0_body.kd47.n1 = 2711645
kernel_rfl PRE_first_tail_x15_r0_body.ckheap47 : (PTrie.keysA PRE_first_tail_x15_r0_body.kd47.heap).all (fun x => Nat.ble 2711625 x) = true
kernel_rfl PRE_first_tail_x15_r0_body.ckpl47 : (List.range 1).all (fun j => decide (PRE_first_tail_x15_r0_body.kd47.heap.get (2711625 + j) = nth? PRE_first_tail_x15_r0_body.pl47 j)) = true
-- the map fixes the call's names (`Conv.fixOld_compact`), the call's counters
kernel_rfl PRE_first_tail_x15_r0_body.fja47 : Nat.ble 2711625 2711625 = true
kernel_rfl PRE_first_tail_x15_r0_body.fn47 : Nat.ble 2062 2062 = true
kernel_rfl PRE_first_tail_x15_r0_body.fjaD47 : Nat.ble 2711625 PRE_first_tail_x15_r0_body.kd47.n0 = true
kernel_rfl PRE_first_tail_x15_r0_body.fxn47 : Nat.ble 19125 PRE_first_tail_x15_r0_body.kd47.nh0 = true
kernel_rfl PRE_first_tail_x15_r0_body.fnn47 : Nat.ble 16207 PRE_first_tail_x15_r0_body.kd47.nn0 = true
kernel_rfl PRE_first_tail_x15_r0_body.fxb47 : Nat.ble 19125 RData.bigHi = true
kernel_rfl PRE_first_tail_x15_r0_body.fheap47 : (PTrie.keysA PRE_first_tail_x15_r0_body.kd47.heap).all (Nat.ble (⟨19125, 16207, 2711625, 2062⟩ : Conv.Cnt).ja) = true
kernel_rfl PRE_first_tail_x15_r0_body.fhnd47 : (PTrie.keysA PRE_first_tail_x15_r0_body.kd47.hnd).all (Nat.ble (⟨19125, 16207, 2711625, 2062⟩ : Conv.Cnt).xn) = true
kernel_rfl PRE_first_tail_x15_r0_body.fnode47 : (PTrie.keysA PRE_first_tail_x15_r0_body.kd47.node).all (Nat.ble (⟨19125, 16207, 2711625, 2062⟩ : Conv.Cnt).nn) = true
/-- The compaction map fixes the call's names. -/
theorem PRE_first_tail_x15_r0_body.cfix47 : Conv.FixOld (⟨19125, 16207, 2711625, 2062⟩ : Conv.Cnt) PRE_first_tail_x15_r0_body.kappa47 :=
  Conv.fixOld_compact (Nat.le_of_ble_eq_true PRE_first_tail_x15_r0_body.fja47) (Nat.le_of_ble_eq_true PRE_first_tail_x15_r0_body.fn47) (Nat.le_of_ble_eq_true PRE_first_tail_x15_r0_body.fjaD47) (Nat.le_of_ble_eq_true PRE_first_tail_x15_r0_body.fxn47) (Nat.le_of_ble_eq_true PRE_first_tail_x15_r0_body.fnn47) (Nat.le_of_ble_eq_true PRE_first_tail_x15_r0_body.fxb47) PRE_first_tail_x15_r0_body.fheap47 PRE_first_tail_x15_r0_body.fhnd47 PRE_first_tail_x15_r0_body.fnode47
kernel_rfl PRE_first_tail_x15_r0_body.fcxn47 : (⟨19125, 16207, 2711625, 2062⟩ : Conv.Cnt).xn = (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s459.ffi).mlx.next
kernel_rfl PRE_first_tail_x15_r0_body.fcnn47 : (⟨19125, 16207, 2711625, 2062⟩ : Conv.Cnt).nn = (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s459.ffi).mlx.nnext
kernel_rfl PRE_first_tail_x15_r0_body.fle047 : (Nat.ble (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s459.ffi).mlx.next PRE_first_tail_x15_r0_body.cx0_47.mlx.next && Nat.ble (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s459.ffi).mlx.nnext PRE_first_tail_x15_r0_body.cx0_47.mlx.nnext && Nat.ble (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s459.ffi).mlx.next RData.bigHi) = true
kernel_rfl PRE_first_tail_x15_r0_body.fnk47 : (PTrie.keysA PRE_first_tail_x15_r0_body.kd47.node).all (Nat.ble (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s459.ffi).mlx.nnext) = true
-- the merged state keeps the call's entries off the stage's footprint
kernel_rfl PRE_first_tail_x15_r0_body.f1A47 : PRE_first_tail_x15_r0_body.cx1_47.mlx.arrs = Stage.setAll (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s459.ffi).mlx.arrs (PRE_first_tail_x15_r0_body.cwS47.filterMap fun i => (PRE_first_tail_x15_r0_body.cx1_47.mlx.arrs.get i).map (i, ·))
kernel_rfl PRE_first_tail_x15_r0_body.f1O47 : PRE_first_tail_x15_r0_body.cx1_47.mlx.objs = Stage.setAll (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s459.ffi).mlx.objs (PRE_first_tail_x15_r0_body.cwS47.filterMap fun i => (PRE_first_tail_x15_r0_body.cx1_47.mlx.objs.get i).map (i, ·))
kernel_rfl PRE_first_tail_x15_r0_body.f1N47 : PRE_first_tail_x15_r0_body.cx1_47.mlx.nodes = Stage.setAll (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s459.ffi).mlx.nodes (PRE_first_tail_x15_r0_body.cnS47.filterMap fun i => (PRE_first_tail_x15_r0_body.cx1_47.mlx.nodes.get i).map (i, ·))
kernel_rfl PRE_first_tail_x15_r0_body.f1I47 : PRE_first_tail_x15_r0_body.cx1_47.mlx.items = Stage.setAll (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s459.ffi).mlx.items (PRE_first_tail_x15_r0_body.ciS47.filterMap fun i => (PRE_first_tail_x15_r0_body.cx1_47.mlx.items.get i).map (i, ·))
kernel_rfl PRE_first_tail_x15_r0_body.fbd47 : (PRE_first_tail_x15_r0_body.clo47 ++ PRE_first_tail_x15_r0_body.cln47 ++ PRE_first_tail_x15_r0_body.cli47 ++ PRE_first_tail_x15_r0_body.cwS47 ++ PRE_first_tail_x15_r0_body.cnS47 ++ PRE_first_tail_x15_r0_body.ciS47).all (fun i => Nat.blt (i / 4096) (4 ^ 31)) = true
kernel_rfl PRE_first_tail_x15_r0_body.fincW47 : PRE_first_tail_x15_r0_body.cwS47.all (fun h => !Nat.blt h (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s459.ffi).mlx.next || PRE_first_tail_x15_r0_body.clo47.contains h) = true
kernel_rfl PRE_first_tail_x15_r0_body.fincI47 : PRE_first_tail_x15_r0_body.ciS47.all (fun k => !Nat.blt k (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s459.ffi).mlx.nnext || PRE_first_tail_x15_r0_body.cli47.contains k) = true
kernel_rfl PRE_first_tail_x15_r0_body.fincN47 : PRE_first_tail_x15_r0_body.cnS47.all (Nat.ble (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s459.ffi).mlx.nnext) = true
kernel_rfl PRE_first_tail_x15_r0_body.flnF47 : PRE_first_tail_x15_r0_body.cln47.all (Nat.ble (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s459.ffi).mlx.nnext) = true
-- the checks over the changed lists
kernel_rfl PRE_first_tail_x15_r0_body.fh47 : PRE_first_tail_x15_r0_body.clo47.all (handleOK PRE_first_tail_x15_r0_body.kappa47 PRE_first_tail_x15_r0_body.P47.lo PRE_first_tail_x15_r0_body.cx0_47.mlx PRE_first_tail_x15_r0_body.cx1_47.mlx) = true
kernel_rfl PRE_first_tail_x15_r0_body.fo47 : PRE_first_tail_x15_r0_body.clo47.map (fun h => PRE_first_tail_x15_r0_body.cx1_47.mlx.objs.get (PRE_first_tail_x15_r0_body.kappa47.handle h)) = PRE_first_tail_x15_r0_body.clo47.map (fun h => (PRE_first_tail_x15_r0_body.cx0_47.mlx.objs.get h).map PRE_first_tail_x15_r0_body.kappa47.nobj)
kernel_rfl PRE_first_tail_x15_r0_body.fok47 : PRE_first_tail_x15_r0_body.clo47.all (objOK PRE_first_tail_x15_r0_body.kappa47 PRE_first_tail_x15_r0_body.P47.NL PRE_first_tail_x15_r0_body.cx0_47.mlx) = true
kernel_rfl PRE_first_tail_x15_r0_body.fnd47 : PRE_first_tail_x15_r0_body.cln47.all (nodeOKF PRE_first_tail_x15_r0_body.kappa47 PRE_first_tail_x15_r0_body.P47 PRE_first_tail_x15_r0_body.cx0_47.mlx PRE_first_tail_x15_r0_body.cx1_47.mlx) = true
kernel_rfl PRE_first_tail_x15_r0_body.fp47 : ((PRE_first_tail_x15_r0_body.cln47.filter (fullB PRE_first_tail_x15_r0_body.P47))).map (fun i => (PRE_first_tail_x15_r0_body.cx1_47.mlx.nodes.get (PRE_first_tail_x15_r0_body.kappa47.node i)).map Host.Mlx.Ffi.Node.prim) =
  ((PRE_first_tail_x15_r0_body.cln47.filter (fullB PRE_first_tail_x15_r0_body.P47))).map (fun i => (PRE_first_tail_x15_r0_body.cx0_47.mlx.nodes.get i).map fun nd => PRE_first_tail_x15_r0_body.kappa47.prim nd.prim)
kernel_rfl PRE_first_tail_x15_r0_body.fnordI47 : incrB PRE_first_tail_x15_r0_body.kd47.nodeF (List.range' 16207 0) = true
kernel_rfl PRE_first_tail_x15_r0_body.fnordK47 : (PTrie.keysA PRE_first_tail_x15_r0_body.kd47.node).all (fun k => Nat.ble 16207 k && Nat.blt k 16207) = true
kernel_rfl PRE_first_tail_x15_r0_body.fnordL47 : (PRE_first_tail_x15_r0_body.cln47.filter (Nat.ble PRE_first_tail_x15_r0_body.P47.N0)).all (fun i => Nat.ble i (PRE_first_tail_x15_r0_body.kd47.nodeF i) && (Nat.blt i 16207 || Nat.ble PRE_first_tail_x15_r0_body.kd47.nn0 i)) = true
theorem PRE_first_tail_x15_r0_body.fnord47 : (PRE_first_tail_x15_r0_body.cln47.filter (Nat.ble PRE_first_tail_x15_r0_body.P47.N0)).all (fun i => Nat.ble i (PRE_first_tail_x15_r0_body.kd47.nodeF i) &&
    (PTrie.keysA PRE_first_tail_x15_r0_body.kd47.node).all fun j => !Nat.blt j i || Nat.blt (PRE_first_tail_x15_r0_body.kd47.nodeF j) (PRE_first_tail_x15_r0_body.kd47.nodeF i)) = true :=
  cnord_of PRE_first_tail_x15_r0_body.cnlow47 PRE_first_tail_x15_r0_body.cnn147 PRE_first_tail_x15_r0_body.fnordI47 PRE_first_tail_x15_r0_body.fnordK47 PRE_first_tail_x15_r0_body.fnordL47
kernel_rfl PRE_first_tail_x15_r0_body.fi47 : PRE_first_tail_x15_r0_body.cli47.all (pnB PRE_first_tail_x15_r0_body.cx0_47.mlx) = true
kernel_rfl PRE_first_tail_x15_r0_body.fii47 : PRE_first_tail_x15_r0_body.cli47.all (fun k => decide (PRE_first_tail_x15_r0_body.cx1_47.mlx.items.get (PRE_first_tail_x15_r0_body.kappa47.node k) = (PRE_first_tail_x15_r0_body.cx0_47.mlx.items.get k).map PRE_first_tail_x15_r0_body.kappa47.nv)) = true
/-- **The compaction's footprint.** -/
theorem PRE_first_tail_x15_r0_body.cfoot47 (clean : Conv.NClean (⟨19125, 16207, 2711625, 2062⟩ : Conv.Cnt) (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s459.ffi).mlx) (hltC : ∀ h, PH (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s459.ffi).mlx h → h < (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s459.ffi).mlx.next) (nltC : ∀ i, PN (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s459.ffi).mlx i → i < (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s459.ffi).mlx.nnext) (itemsC : ∀ k v, (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s459.ffi).mlx.items.get k = some v → PN (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s459.ffi).mlx k) (tracedC : ∀ h o, (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s459.ffi).mlx.objs.get h = some o → ∀ i ∈ objTraces o, i < PRE_first_tail_x15_r0_body.P47.NL) (cl : SSt (· < 2062) PRE_first_tail_x15_r0_body.cx0_47.mlx) :
    Conv.MFoot PRE_first_tail_x15_r0_body.P47 2062 PRE_first_tail_x15_r0_body.kappa47 PRE_first_tail_x15_r0_body.kd47 PRE_first_tail_x15_r0_body.khinv47 PRE_first_tail_x15_r0_body.kninv47 (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s459.ffi).mlx PRE_first_tail_x15_r0_body.cx0_47.mlx PRE_first_tail_x15_r0_body.cx1_47.mlx (⟨19125, 16207, 2711625, 2062⟩ : Conv.Cnt) PRE_first_tail_x15_r0_body.clo47 PRE_first_tail_x15_r0_body.cln47 PRE_first_tail_x15_r0_body.cli47 PRE_first_tail_x15_r0_body.cwS47 PRE_first_tail_x15_r0_body.cnS47 PRE_first_tail_x15_r0_body.ciS47 :=
  ⟨rfl, rfl, rfl, PRE_first_tail_x15_r0_body.cnh047, PRE_first_tail_x15_r0_body.cnh147, PRE_first_tail_x15_r0_body.cnn047, PRE_first_tail_x15_r0_body.cnn147, PRE_first_tail_x15_r0_body.cplo47, PRE_first_tail_x15_r0_body.ccnt47, PRE_first_tail_x15_r0_body.cnband47, PRE_first_tail_x15_r0_body.chbelow47, PRE_first_tail_x15_r0_body.chren47, PRE_first_tail_x15_r0_body.cband47, PRE_first_tail_x15_r0_body.cnh1pos47, PRE_first_tail_x15_r0_body.cnren47, PRE_first_tail_x15_r0_body.cnlow47, PRE_first_tail_x15_r0_body.cabs0a47, PRE_first_tail_x15_r0_body.cabs0b47, PRE_first_tail_x15_r0_body.ctok147, PRE_first_tail_x15_r0_body.cpend47, PRE_first_tail_x15_r0_body.cerrh47, PRE_first_tail_x15_r0_body.cfiles47, PRE_first_tail_x15_r0_body.carch47, PRE_first_tail_x15_r0_body.csizes47, PRE_first_tail_x15_r0_body.cwired47, PRE_first_tail_x15_r0_body.cfix47, clean, PRE_first_tail_x15_r0_body.fcxn47, PRE_first_tail_x15_r0_body.fcnn47, hltC, nltC, itemsC, tracedC, cl, PRE_first_tail_x15_r0_body.fle047, PRE_first_tail_x15_r0_body.fnk47, PRE_first_tail_x15_r0_body.ckA47, PRE_first_tail_x15_r0_body.cobjsK47, PRE_first_tail_x15_r0_body.cnodesK47, PRE_first_tail_x15_r0_body.citemsK47, PRE_first_tail_x15_r0_body.f1A47, PRE_first_tail_x15_r0_body.f1O47, PRE_first_tail_x15_r0_body.f1N47, PRE_first_tail_x15_r0_body.f1I47, PRE_first_tail_x15_r0_body.fbd47, PRE_first_tail_x15_r0_body.fincW47, PRE_first_tail_x15_r0_body.fincI47, PRE_first_tail_x15_r0_body.fincN47, PRE_first_tail_x15_r0_body.flnF47, PRE_first_tail_x15_r0_body.fh47, PRE_first_tail_x15_r0_body.fo47, PRE_first_tail_x15_r0_body.fok47, PRE_first_tail_x15_r0_body.fnd47, PRE_first_tail_x15_r0_body.fp47, PRE_first_tail_x15_r0_body.fnord47, PRE_first_tail_x15_r0_body.fi47, PRE_first_tail_x15_r0_body.fii47⟩
theorem PRE_first_tail_x15_r0_body.cnshift47 (clean : Conv.NClean (⟨19125, 16207, 2711625, 2062⟩ : Conv.Cnt) (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s459.ffi).mlx) (hltC : ∀ h, PH (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s459.ffi).mlx h → h < (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s459.ffi).mlx.next) (nltC : ∀ i, PN (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s459.ffi).mlx i → i < (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s459.ffi).mlx.nnext) (itemsC : ∀ k v, (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s459.ffi).mlx.items.get k = some v → PN (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s459.ffi).mlx k) (tracedC : ∀ h o, (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s459.ffi).mlx.objs.get h = some o → ∀ i ∈ objTraces o, i < PRE_first_tail_x15_r0_body.P47.NL) (cl : SSt (· < 2062) PRE_first_tail_x15_r0_body.cx0_47.mlx) : NShift PRE_first_tail_x15_r0_body.P47 2062 PRE_first_tail_x15_r0_body.kappa47 PRE_first_tail_x15_r0_body.cx0_47 PRE_first_tail_x15_r0_body.cx1_47 :=
  Conv.nshift_of_foot (PRE_first_tail_x15_r0_body.cfoot47 clean hltC nltC itemsC tracedC cl) PRE_first_tail_x15_r0_body.chost47 (compact_a_eq PRE_first_tail_x15_r0_body.ckn047 PRE_first_tail_x15_r0_body.ckn147 PRE_first_tail_x15_r0_body.ckheap47 PRE_first_tail_x15_r0_body.ckpl47)

-- the observers: the layers' states at the call, the canonical and the merged state, their footprints and checks
noncomputable def PRE_first_tail_x15_r0_body.fxC_47 : PTrie Unit := (Host.Ts.Sim.Full.freedOf PRE_first_tail_x15_r0_body.s459.ffi).getD PTrie.nil
noncomputable def PRE_first_tail_x15_r0_body.krC_47 : Host.Load.Layers.KRec := (Host.Ts.Sim.Full.krecOf PRE_first_tail_x15_r0_body.s459.ffi).getD Host.Load.Layers.KRec.empty
kernel_rfl PRE_first_tail_x15_r0_body.ofxC_47 : (Host.Ts.Sim.Full.freedOf PRE_first_tail_x15_r0_body.s459.ffi) = some PRE_first_tail_x15_r0_body.fxC_47
kernel_rfl PRE_first_tail_x15_r0_body.okrC_47 : (Host.Ts.Sim.Full.krecOf PRE_first_tail_x15_r0_body.s459.ffi) = some PRE_first_tail_x15_r0_body.krC_47
noncomputable def PRE_first_tail_x15_r0_body.fx0_47 : PTrie Unit := (Host.Ts.Sim.Full.freedOf PRE_first_tail_x15_r0_body.s461.ffi).getD PTrie.nil
noncomputable def PRE_first_tail_x15_r0_body.kr0_47 : Host.Load.Layers.KRec := (Host.Ts.Sim.Full.krecOf PRE_first_tail_x15_r0_body.s461.ffi).getD Host.Load.Layers.KRec.empty
kernel_rfl PRE_first_tail_x15_r0_body.ofx0_47 : (Host.Ts.Sim.Full.freedOf PRE_first_tail_x15_r0_body.s461.ffi) = some PRE_first_tail_x15_r0_body.fx0_47
kernel_rfl PRE_first_tail_x15_r0_body.okr0_47 : (Host.Ts.Sim.Full.krecOf PRE_first_tail_x15_r0_body.s461.ffi) = some PRE_first_tail_x15_r0_body.kr0_47
noncomputable def PRE_first_tail_x15_r0_body.fx1_47 : PTrie Unit := (Host.Ts.Sim.Full.freedOf PRE_first_tail_x15_r0_body.s460.ffi).getD PTrie.nil
noncomputable def PRE_first_tail_x15_r0_body.kr1_47 : Host.Load.Layers.KRec := (Host.Ts.Sim.Full.krecOf PRE_first_tail_x15_r0_body.s460.ffi).getD Host.Load.Layers.KRec.empty
kernel_rfl PRE_first_tail_x15_r0_body.ofx1_47 : (Host.Ts.Sim.Full.freedOf PRE_first_tail_x15_r0_body.s460.ffi) = some PRE_first_tail_x15_r0_body.fx1_47
kernel_rfl PRE_first_tail_x15_r0_body.okr1_47 : (Host.Ts.Sim.Full.krecOf PRE_first_tail_x15_r0_body.s460.ffi) = some PRE_first_tail_x15_r0_body.kr1_47
kernel_rfl PRE_first_tail_x15_r0_body.ff047 : PRE_first_tail_x15_r0_body.fx0_47 = Stage.setAll PRE_first_tail_x15_r0_body.fxC_47 (PRE_first_tail_x15_r0_body.clo47.filterMap fun i => (PRE_first_tail_x15_r0_body.fx0_47.get i).map (i, ·))
kernel_rfl PRE_first_tail_x15_r0_body.ff147 : PRE_first_tail_x15_r0_body.fx1_47 = Stage.setAll PRE_first_tail_x15_r0_body.fxC_47 (PRE_first_tail_x15_r0_body.cwS47.filterMap fun i => (PRE_first_tail_x15_r0_body.fx1_47.get i).map (i, ·))
kernel_rfl PRE_first_tail_x15_r0_body.ffck47 : freedLB PRE_first_tail_x15_r0_body.kappa47 PRE_first_tail_x15_r0_body.cx0_47.mlx PRE_first_tail_x15_r0_body.fx0_47 PRE_first_tail_x15_r0_body.fx1_47 PRE_first_tail_x15_r0_body.clo47 = true
kernel_rfl PRE_first_tail_x15_r0_body.fkf047 : PRE_first_tail_x15_r0_body.kr0_47.flags = Stage.setAll PRE_first_tail_x15_r0_body.krC_47.flags (PRE_first_tail_x15_r0_body.clo47.filterMap fun i => (PRE_first_tail_x15_r0_body.kr0_47.flags.get i).map (i, ·))
kernel_rfl PRE_first_tail_x15_r0_body.fkt047 : PRE_first_tail_x15_r0_body.kr0_47.targs = Stage.setAll PRE_first_tail_x15_r0_body.krC_47.targs (PRE_first_tail_x15_r0_body.clo47.filterMap fun i => (PRE_first_tail_x15_r0_body.kr0_47.targs.get i).map (i, ·))
kernel_rfl PRE_first_tail_x15_r0_body.fkf147 : PRE_first_tail_x15_r0_body.kr1_47.flags = Stage.setAll PRE_first_tail_x15_r0_body.krC_47.flags (PRE_first_tail_x15_r0_body.cwS47.filterMap fun i => (PRE_first_tail_x15_r0_body.kr1_47.flags.get i).map (i, ·))
kernel_rfl PRE_first_tail_x15_r0_body.fkt147 : PRE_first_tail_x15_r0_body.kr1_47.targs = Stage.setAll PRE_first_tail_x15_r0_body.krC_47.targs (PRE_first_tail_x15_r0_body.cwS47.filterMap fun i => (PRE_first_tail_x15_r0_body.kr1_47.targs.get i).map (i, ·))
kernel_rfl PRE_first_tail_x15_r0_body.fkck47 : krecLB PRE_first_tail_x15_r0_body.kappa47 2062 PRE_first_tail_x15_r0_body.cx0_47.mlx PRE_first_tail_x15_r0_body.kr0_47 PRE_first_tail_x15_r0_body.kr1_47 PRE_first_tail_x15_r0_body.clo47 = true
kernel_rfl PRE_first_tail_x15_r0_body.fkn47 : Nat.ble 2062 2062 = true
-- the bridge and the pending traces' regions
kernel_rfl PRE_first_tail_x15_r0_body.cbridge47 : Host.Ts.Sim.Full.bridgeOf PRE_first_tail_x15_r0_body.s460.ffi = Host.Ts.Sim.Full.bridgeOf PRE_first_tail_x15_r0_body.s461.ffi
kernel_rfl PRE_first_tail_x15_r0_body.cpendR47 : pendRegB PRE_first_tail_x15_r0_body.kappa47 (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s461.ffi).mlx = true
kernel_rfl PRE_first_tail_x15_r0_body.cpendLe47 : Nat.ble (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s461.ffi).mlx.next (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s460.ffi).mlx.next = true
/-- **The compaction's native shift**, given the call's bookkeeping, its relation's facts (the model's and the
observers') and the canonical closedness. -/
theorem PRE_first_tail_x15_r0_body.cshift47 (clean : Conv.NClean (⟨19125, 16207, 2711625, 2062⟩ : Conv.Cnt) (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s459.ffi).mlx) (hltC : ∀ h, PH (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s459.ffi).mlx h → h < (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s459.ffi).mlx.next) (nltC : ∀ i, PN (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s459.ffi).mlx i → i < (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s459.ffi).mlx.nnext) (itemsC : ∀ k v, (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s459.ffi).mlx.items.get k = some v → PN (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s459.ffi).mlx k) (tracedC : ∀ h o, (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s459.ffi).mlx.objs.get h = some o → ∀ i ∈ objTraces o, i < PRE_first_tail_x15_r0_body.P47.NL) (cl : SSt (· < 2062) PRE_first_tail_x15_r0_body.cx0_47.mlx)
    (hobjC : ∀ h, PRE_first_tail_x15_r0_body.fxC_47.get h = some () → ((Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s459.ffi).mlx.objs.get h).isSome = true)
    (hfC : ∀ h, (PRE_first_tail_x15_r0_body.krC_47.flags.get h).isSome = true → ((Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s459.ffi).mlx.objs.get h).isSome = true)
    (htC : ∀ h, (PRE_first_tail_x15_r0_body.krC_47.targs.get h).isSome = true → ((Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s459.ffi).mlx.objs.get h).isSome = true)
    (hclC : ∀ h l, PRE_first_tail_x15_r0_body.krC_47.targs.get h = some l → Host.Ts.Sim.Full.STargs (· < (⟨19125, 16207, 2711625, 2062⟩ : Conv.Cnt).n) l) :
    Conv.FullShiftQ PRE_first_tail_x15_r0_body.P47 2062 PRE_first_tail_x15_r0_body.kappa47 PRE_first_tail_x15_r0_body.s461.ffi PRE_first_tail_x15_r0_body.s460.ffi :=
  ⟨PRE_first_tail_x15_r0_body.cnshift47 clean hltC nltC itemsC tracedC cl, PRE_first_tail_x15_r0_body.cqueue47, fun t ht => bSN_sound (List.all_eq_true.mp PRE_first_tail_x15_r0_body.ctokSupp47 t ht),
    PRE_first_tail_x15_r0_body.cbridge47,
    liveShift_foot (x0' := Host.Ts.Sim.Full.mlxOf PRE_first_tail_x15_r0_body.s461.ffi) (x1' := Host.Ts.Sim.Full.mlxOf PRE_first_tail_x15_r0_body.s460.ffi) (PRE_first_tail_x15_r0_body.cfoot47 clean hltC nltC itemsC tracedC cl) rfl PRE_first_tail_x15_r0_body.ofx0_47 PRE_first_tail_x15_r0_body.ofx1_47 hobjC PRE_first_tail_x15_r0_body.ff047 PRE_first_tail_x15_r0_body.ff147 PRE_first_tail_x15_r0_body.ffck47,
    kernShift_foot (x0' := Host.Ts.Sim.Full.mlxOf PRE_first_tail_x15_r0_body.s461.ffi) (x1' := Host.Ts.Sim.Full.mlxOf PRE_first_tail_x15_r0_body.s460.ffi) (PRE_first_tail_x15_r0_body.cfoot47 clean hltC nltC itemsC tracedC cl) rfl PRE_first_tail_x15_r0_body.okr0_47 PRE_first_tail_x15_r0_body.okr1_47 (Nat.le_of_ble_eq_true PRE_first_tail_x15_r0_body.fkn47) hfC htC hclC
      PRE_first_tail_x15_r0_body.fkf047 PRE_first_tail_x15_r0_body.fkt047 PRE_first_tail_x15_r0_body.fkf147 PRE_first_tail_x15_r0_body.fkt147 PRE_first_tail_x15_r0_body.fkck47,
    pendReg_of rfl PRE_first_tail_x15_r0_body.cnh047 PRE_first_tail_x15_r0_body.cnh147 (Nat.le_of_ble_eq_true PRE_first_tail_x15_r0_body.cpendLe47) PRE_first_tail_x15_r0_body.cpendR47⟩

end Host.Load.Run.Tpl
end

section -- st47/H0
set_option Elab.async false
namespace Host.Load.Run.Tpl
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
host_stream_state PRE_first_tail_x15_r0_body.st47 0
host_stream_state PRE_first_tail_x15_r0_body.st47 1
host_stream_state PRE_first_tail_x15_r0_body.st47 2
end Host.Load.Run.Tpl
end

section -- Site47
set_option Elab.async false
namespace Host.Load.Run.Tpl
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
open Host.Ts Host.Ts.Sim Host.Ts.Sim.Template

/-! Call site 47 of chain `PRE_first_tail_x15_r0_body`: `plan__g47__g48` (`plan`), the call state `PRE_first_tail_x15_r0_body.s459`, the merged state `PRE_first_tail_x15_r0_body.s460`,
the site template `PRE_first_tail_x15_r0_body.st47` (σ = `Map.id`, θ the identity at its own site), the canonical state `PRE_first_tail_x15_r0_body.s461`: the merge.
The footprint's facts are in `SiteF47`, the compaction's in `SiteC47`, `SiteK47`, `SiteNa47`, `SiteNb47`. -/

kernel_rfl PRE_first_tail_x15_r0_body.iso47 : PRE_first_tail_x15_r0_body.st47.s0 = { PRE_first_tail_x15_r0_body.s459 with stack := [] }
/-- The caller's frames at the call. -/
noncomputable def PRE_first_tail_x15_r0_body.rs47 : List Frame := PRE_first_tail_x15_r0_body.s459.stack
kernel_rfl PRE_first_tail_x15_r0_body.n0_47 : PRE_first_tail_x15_r0_body.S459.tab.length = 2062
kernel_rfl PRE_first_tail_x15_r0_body.tab0_47 : PRE_first_tail_x15_r0_body.st47.S0.tab = PRE_first_tail_x15_r0_body.S459.tab

/-- The fresh variables of the stage's results. -/
def PRE_first_tail_x15_r0_body.ws47 : List Nat := [1787, 1788, 1789, 1790, 1791, 1792, 1793, 1794, 1795]
kernel_rfl PRE_first_tail_x15_r0_body.fresh47 : (PRE_first_tail_x15_r0_body.S459.tab.all fun e => PRE_first_tail_x15_r0_body.ws47.all fun v => e.noVar v) &&
    (PRE_first_tail_x15_r0_body.S459.oracle.all fun q => PRE_first_tail_x15_r0_body.ws47.all fun v => q.noVar v) = true
kernel_rfl PRE_first_tail_x15_r0_body.mergeTab47 : PRE_first_tail_x15_r0_body.S460.tab = PRE_first_tail_x15_r0_body.S459.tab ++ Conv.resTab PRE_first_tail_x15_r0_body.ws47
kernel_rfl PRE_first_tail_x15_r0_body.mergeLen47 : PRE_first_tail_x15_r0_body.st47.S2.tab.length - PRE_first_tail_x15_r0_body.st47.S0.tab.length = 9

-- The merged state: the instance's return state with the caller's frames (`PRE_first_tail_x15_r0_body.merged47`, `merged_relB`).
kernel_rfl PRE_first_tail_x15_r0_body.mheap47 : PRE_first_tail_x15_r0_body.s460.heap = PRE_first_tail_x15_r0_body.st47.s2.heap
kernel_rfl PRE_first_tail_x15_r0_body.mnext47 : PRE_first_tail_x15_r0_body.s460.next = PRE_first_tail_x15_r0_body.st47.s2.next
kernel_rfl PRE_first_tail_x15_r0_body.mctl47 : PRE_first_tail_x15_r0_body.s460.ctl = PRE_first_tail_x15_r0_body.st47.s2.ctl
kernel_rfl PRE_first_tail_x15_r0_body.mstack47 : PRE_first_tail_x15_r0_body.s460.stack = PRE_first_tail_x15_r0_body.st47.s2.stack ++ PRE_first_tail_x15_r0_body.s459.stack
kernel_rfl PRE_first_tail_x15_r0_body.mjobs47 : PRE_first_tail_x15_r0_body.s460.jobs = PRE_first_tail_x15_r0_body.st47.s2.jobs
kernel_rfl PRE_first_tail_x15_r0_body.mffi47 : PRE_first_tail_x15_r0_body.s460.ffi = PRE_first_tail_x15_r0_body.st47.s2.ffi
kernel_rfl PRE_first_tail_x15_r0_body.mtrace47 : PRE_first_tail_x15_r0_body.s460.trace = PRE_first_tail_x15_r0_body.st47.s2.trace
kernel_rfl PRE_first_tail_x15_r0_body.mstores47 : PRE_first_tail_x15_r0_body.s460.stores = PRE_first_tail_x15_r0_body.st47.s2.stores

end Host.Load.Run.Tpl
end

section -- SiteD47
set_option Elab.async false
namespace Host.Load.Run.Tpl
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
open Host.Ts Host.Ts.Sim Host.Ts.Sim.Template

/-! The canonical results at call site 47 of chain `PRE_first_tail_x15_r0_body`: their values in the instance's end table, the references past
the call's table, the canonical variables apart from the stage's. -/

kernel_rfl PRE_first_tail_x15_r0_body.cderived47 : PRE_first_tail_x15_r0_body.nr47.map (fun r => nth? PRE_first_tail_x15_r0_body.st47.S2.tab r) =
  []
kernel_rfl PRE_first_tail_x15_r0_body.cnrLo47 : PRE_first_tail_x15_r0_body.nr47.all (Nat.ble 2062) = true
kernel_rfl PRE_first_tail_x15_r0_body.cwsDisj47 : PRE_first_tail_x15_r0_body.cws47.all (fun c => !PRE_first_tail_x15_r0_body.ws47.contains c) = true
/-- The compaction's substitution: the canonical variables to their merged values, the stage's other fresh variables
to `0` (`Conv.compactθZ`). -/
noncomputable def PRE_first_tail_x15_r0_body.cthetaZ47 : Nat → SymE := Conv.compactθZ PRE_first_tail_x15_r0_body.cws47 PRE_first_tail_x15_r0_body.crs47 PRE_first_tail_x15_r0_body.ws47

end Host.Load.Run.Tpl
end

section -- st47/Foot
set_option Elab.async false
namespace Host.Load.Run.Tpl
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
open Host.Ts Host.Ts.Sim Host.Ts.Sim.Stage Host.Ts.Sim.Template

/-! The footprint of stage `PRE_first_tail_x15_r0_body.st47`'s site template (`Conv.StageFoot`, `Conv.NFoot`): every entry of the return
state other than the written and fresh ones is the start's (kernel evaluation of the equalities). -/

/-- The written heap ranges below the start's counter. -/
def PRE_first_tail_x15_r0_body.st47.wrR : List (Nat × Nat) := []
/-- The written and fresh entries of the return state. -/
noncomputable def PRE_first_tail_x15_r0_body.st47.wrE : List (Nat × Host.Ts.HObj) :=
  rangesOf PRE_first_tail_x15_r0_body.st47.s2.heap PRE_first_tail_x15_r0_body.st47.wrR ++ freshOf PRE_first_tail_x15_r0_body.st47.s2.heap PRE_first_tail_x15_r0_body.st47.s0.next PRE_first_tail_x15_r0_body.st47.s2.next
noncomputable def PRE_first_tail_x15_r0_body.st47.wr : List Nat := PRE_first_tail_x15_r0_body.st47.wrE.map (·.1)

kernel_rfl PRE_first_tail_x15_r0_body.st47.heapFoot : PRE_first_tail_x15_r0_body.st47.s2.heap = setAll PRE_first_tail_x15_r0_body.st47.s0.heap PRE_first_tail_x15_r0_body.st47.wrE
kernel_rfl PRE_first_tail_x15_r0_body.st47.grows_check : Nat.ble PRE_first_tail_x15_r0_body.st47.s0.next PRE_first_tail_x15_r0_body.st47.s2.next = true
theorem PRE_first_tail_x15_r0_body.st47.grows : PRE_first_tail_x15_r0_body.st47.s0.next ≤ PRE_first_tail_x15_r0_body.st47.s2.next := Nat.le_of_ble_eq_true PRE_first_tail_x15_r0_body.st47.grows_check

/-- The written and fresh handles; the written readback items of old nodes. -/
def PRE_first_tail_x15_r0_body.st47.wh : List Nat := []
def PRE_first_tail_x15_r0_body.st47.wi : List Nat := []

kernel_rfl PRE_first_tail_x15_r0_body.st47.arrsFoot : (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.st47.s2.ffi).mlx.arrs = setAll (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.st47.s0.ffi).mlx.arrs (PRE_first_tail_x15_r0_body.st47.wh.filterMap fun h => ((Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.st47.s2.ffi).mlx.arrs.get h).map (h, ·))
kernel_rfl PRE_first_tail_x15_r0_body.st47.objsFoot : (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.st47.s2.ffi).mlx.objs = setAll (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.st47.s0.ffi).mlx.objs (PRE_first_tail_x15_r0_body.st47.wh.filterMap fun h => ((Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.st47.s2.ffi).mlx.objs.get h).map (h, ·))
kernel_rfl PRE_first_tail_x15_r0_body.st47.nodesFoot : (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.st47.s2.ffi).mlx.nodes = setAll (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.st47.s0.ffi).mlx.nodes (freshOf (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.st47.s2.ffi).mlx.nodes (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.st47.s0.ffi).mlx.nnext (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.st47.s2.ffi).mlx.nnext)
kernel_rfl PRE_first_tail_x15_r0_body.st47.itemsFoot : (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.st47.s2.ffi).mlx.items = setAll (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.st47.s0.ffi).mlx.items ((PRE_first_tail_x15_r0_body.st47.wi.filterMap fun i => ((Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.st47.s2.ffi).mlx.items.get i).map (i, ·)) ++
    freshOf (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.st47.s2.ffi).mlx.items (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.st47.s0.ffi).mlx.nnext (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.st47.s2.ffi).mlx.nnext)
kernel_rfl PRE_first_tail_x15_r0_body.st47.counters : (Nat.ble (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.st47.s0.ffi).mlx.next (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.st47.s2.ffi).mlx.next && Nat.ble (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.st47.s0.ffi).mlx.nnext (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.st47.s2.ffi).mlx.nnext) = true

end Host.Load.Run.Tpl
end

section -- SiteF47
set_option Elab.async false
namespace Host.Load.Run.Tpl
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
open Host.Ts Host.Ts.Sim Host.Ts.Sim.Template

/-! Call site 47 of chain `PRE_first_tail_x15_r0_body`: `Conv.site_merge`'s footprint facts. -/

kernel_rfl PRE_first_tail_x15_r0_body.wrNodupB47 : nodupT PRE_first_tail_x15_r0_body.st47.wr PTrie.nil = true
theorem PRE_first_tail_x15_r0_body.wrNodup47 : PRE_first_tail_x15_r0_body.st47.wr.Nodup := (nodupT_sound PRE_first_tail_x15_r0_body.wrNodupB47).2
kernel_rfl PRE_first_tail_x15_r0_body.wrBoundB47 : PRE_first_tail_x15_r0_body.st47.wr.all (fun b => Nat.blt (b / 4096) (4 ^ 31)) = true
theorem PRE_first_tail_x15_r0_body.wrBound47 : ∀ b ∈ PRE_first_tail_x15_r0_body.st47.wr, b / 4096 < 4 ^ 31 := fun b hb => Nat.blt_eq.mp (List.all_eq_true.mp PRE_first_tail_x15_r0_body.wrBoundB47 b hb)
noncomputable def PRE_first_tail_x15_r0_body.trFr47 := PRE_first_tail_x15_r0_body.st47.s2.trace.take 0
kernel_rfl PRE_first_tail_x15_r0_body.traceEq47 : PRE_first_tail_x15_r0_body.st47.s2.trace = PRE_first_tail_x15_r0_body.trFr47 ++ PRE_first_tail_x15_r0_body.st47.s0.trace
theorem PRE_first_tail_x15_r0_body.trace47 : ∃ fr, PRE_first_tail_x15_r0_body.st47.s2.trace = fr ++ PRE_first_tail_x15_r0_body.st47.s0.trace := ⟨_, PRE_first_tail_x15_r0_body.traceEq47⟩

-- the caller's wide frames at the instance's start (`Conv.isolateW`'s `W0` under `Map.id`) and their `WFix`
def PRE_first_tail_x15_r0_body.wide47 : List (Nat × WFrame) := [(4910, .memo [])]
kernel_rfl PRE_first_tail_x15_r0_body.wfixB47 : (PRE_first_tail_x15_r0_body.wide47.all fun p => wfixB Map.id (presentB PRE_first_tail_x15_r0_body.st47.s0) p.2) = true
theorem PRE_first_tail_x15_r0_body.wfix47 : ∀ p ∈ PRE_first_tail_x15_r0_body.wide47, WFix Map.id (Present PRE_first_tail_x15_r0_body.st47.s0) p.2 :=
  fun p hp => wfix_of (List.all_eq_true.mp PRE_first_tail_x15_r0_body.wfixB47 p hp)

end Host.Load.Run.Tpl
end

section -- SiteL47
set_option Elab.async false
namespace Host.Load.Run.Tpl
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
open Host.Ts Host.Ts.Sim Host.Ts.Sim.Template

/-! The call link's facts at call site 47 of chain `PRE_first_tail_x15_r0_body`: the instance's start server, its footprint (`Conv.StageFoot`), the
merged state `PRE_first_tail_x15_r0_body.s460`'s framed arrays as the chain start's extended (`arrExt_of`, `numRefs_of`). -/

kernel_rfl PRE_first_tail_x15_r0_body.srvO47 : PRE_first_tail_x15_r0_body.st47.S0.oracle = PRE_first_tail_x15_r0_body.st47.OR
kernel_rfl PRE_first_tail_x15_r0_body.wr0B47 : PRE_first_tail_x15_r0_body.st47.wr.all (fun b => !Nat.blt b PRE_first_tail_x15_r0_body.st47.s0.next || (PRE_first_tail_x15_r0_body.st47.s0.heap.get b).isSome) = true
theorem PRE_first_tail_x15_r0_body.stFoot47 : Conv.StageFoot PRE_first_tail_x15_r0_body.st47.wr PRE_first_tail_x15_r0_body.st47.s0 PRE_first_tail_x15_r0_body.st47.s2 :=
  stageFoot_of PRE_first_tail_x15_r0_body.st47.heapFoot PRE_first_tail_x15_r0_body.wrNodup47 PRE_first_tail_x15_r0_body.wrBound47 PRE_first_tail_x15_r0_body.wr0B47 PRE_first_tail_x15_r0_body.st47.grows

/-- **The relation at the merged state** from the relation at the merge (`Conv.site_merge`'s; `merged_relB`). -/
theorem PRE_first_tail_x15_r0_body.merged47 {FR : Map → Nat → PRE_first_tail_x15_r0_body.st47.F.S → PRE_first_tail_x15_r0_body.st47.F.S → Prop} {W : Nat → Option WFrame} {stk : List Frame} {M : Map}
    {ν : Nat → F64} {K : Host.Ts.Sim.Ctx} {S : SSrv} {t : St PRE_first_tail_x15_r0_body.st47.F.S} {C : CSrv} {n0 : Nat}
    (h : RelB PRE_first_tail_x15_r0_body.st47.F FR W stk M ν K (Conv.mergeSt Map.id (Map.id.res n0 n0) PRE_first_tail_x15_r0_body.rs47 PRE_first_tail_x15_r0_body.st47.wr PRE_first_tail_x15_r0_body.s459 PRE_first_tail_x15_r0_body.st47.s2 PRE_first_tail_x15_r0_body.st47.s0
      PRE_first_tail_x15_r0_body.st47.s2.ffi) S t C) : RelB PRE_first_tail_x15_r0_body.st47.F FR W stk M ν K PRE_first_tail_x15_r0_body.s460 S t C :=
  merged_relB PRE_first_tail_x15_r0_body.iso47 PRE_first_tail_x15_r0_body.stFoot47 PRE_first_tail_x15_r0_body.wrNodup47 PRE_first_tail_x15_r0_body.wrBound47 PRE_first_tail_x15_r0_body.trace47 PRE_first_tail_x15_r0_body.mheap47
    PRE_first_tail_x15_r0_body.mnext47 PRE_first_tail_x15_r0_body.mctl47 PRE_first_tail_x15_r0_body.mstack47 PRE_first_tail_x15_r0_body.mjobs47 PRE_first_tail_x15_r0_body.mffi47 PRE_first_tail_x15_r0_body.mtrace47 PRE_first_tail_x15_r0_body.mstores47 h

def PRE_first_tail_x15_r0_body.arrEl47_2665 : List Val := []
kernel_rfl PRE_first_tail_x15_r0_body.arrE47_2665 : arrOf PRE_first_tail_x15_r0_body.s460 2665 = arrOf PRE_first_tail_x15_r0_body.s0 2665 ++ PRE_first_tail_x15_r0_body.arrEl47_2665
kernel_rfl PRE_first_tail_x15_r0_body.arrA47_2665 : isArrB PRE_first_tail_x15_r0_body.s460 2665 = true
theorem PRE_first_tail_x15_r0_body.arr47_2665 : ∃ o, PRE_first_tail_x15_r0_body.s460.heap.get 2665 = some (.obj o) ∧ o.kind = .array (arrOf PRE_first_tail_x15_r0_body.s0 2665 ++ PRE_first_tail_x15_r0_body.arrEl47_2665) :=
  arrExt_of PRE_first_tail_x15_r0_body.arrE47_2665 PRE_first_tail_x15_r0_body.arrA47_2665
kernel_rfl PRE_first_tail_x15_r0_body.arrN47_2665 : numRefsB PRE_first_tail_x15_r0_body.S0.tab.length PRE_first_tail_x15_r0_body.arrEl47_2665 = true
theorem PRE_first_tail_x15_r0_body.arrR47_2665 : Prefill.NumRefs PRE_first_tail_x15_r0_body.S0.tab.length PRE_first_tail_x15_r0_body.arrEl47_2665 := numRefs_of PRE_first_tail_x15_r0_body.arrN47_2665

def PRE_first_tail_x15_r0_body.arrEl47_2673467 : List Val := []
kernel_rfl PRE_first_tail_x15_r0_body.arrE47_2673467 : arrOf PRE_first_tail_x15_r0_body.s460 2673467 = arrOf PRE_first_tail_x15_r0_body.s0 2673467 ++ PRE_first_tail_x15_r0_body.arrEl47_2673467
kernel_rfl PRE_first_tail_x15_r0_body.arrA47_2673467 : isArrB PRE_first_tail_x15_r0_body.s460 2673467 = true
theorem PRE_first_tail_x15_r0_body.arr47_2673467 : ∃ o, PRE_first_tail_x15_r0_body.s460.heap.get 2673467 = some (.obj o) ∧ o.kind = .array (arrOf PRE_first_tail_x15_r0_body.s0 2673467 ++ PRE_first_tail_x15_r0_body.arrEl47_2673467) :=
  arrExt_of PRE_first_tail_x15_r0_body.arrE47_2673467 PRE_first_tail_x15_r0_body.arrA47_2673467
kernel_rfl PRE_first_tail_x15_r0_body.arrN47_2673467 : numRefsB PRE_first_tail_x15_r0_body.S0.tab.length PRE_first_tail_x15_r0_body.arrEl47_2673467 = true
theorem PRE_first_tail_x15_r0_body.arrR47_2673467 : Prefill.NumRefs PRE_first_tail_x15_r0_body.S0.tab.length PRE_first_tail_x15_r0_body.arrEl47_2673467 := numRefs_of PRE_first_tail_x15_r0_body.arrN47_2673467

kernel_rfl PRE_first_tail_x15_r0_body.w4910k47 : isArrB PRE_first_tail_x15_r0_body.s460 4910 = false
theorem PRE_first_tail_x15_r0_body.keep47 (q : List Val) : Host.Ts.Sim.Prefill.KeepsAtW (framesP PRE_first_tail_x15_r0_body.s0 q) PRE_first_tail_x15_r0_body.s460 := by
  intro a pre pre' hx o es ho hk
  unfold framesP at hx
  simp only at hx
  cases h1 : Nat.beq a 2665
  · cases h2 : Nat.beq a 4910
    · rw [h1, h2] at hx; cases hx
    · have := Nat.eq_of_beq_eq_true h2; subst this
      rw [h1, h2] at hx; cases hx
      exact (notArr_of PRE_first_tail_x15_r0_body.w4910k47 ho hk).elim
  · have := Nat.eq_of_beq_eq_true h1; subst this
    rw [h1] at hx; cases hx
    obtain ⟨o', ho', hk'⟩ := PRE_first_tail_x15_r0_body.arr47_2665
    rw [ho] at ho'; cases ho'
    rw [hk'] at hk; cases hk
    simp [PRE_first_tail_x15_r0_body.arrEl47_2665]

end Host.Load.Run.Tpl
end

section -- SiteZ47
set_option Elab.async false
namespace Host.Load.Run.Tpl
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
open Host.Ts Host.Ts.Sim Host.Ts.Sim.Template

/-! The compaction's state shift at call site 47 of chain `PRE_first_tail_x15_r0_body` (`Conv.compact_shift`): the call `PRE_first_tail_x15_r0_body.s459`, the merged
state `PRE_first_tail_x15_r0_body.s460`, the canonical state `PRE_first_tail_x15_r0_body.s461`; its frames [2665,2673467,2673472,2673473] (kept arrays [2665,2673467]). -/

-- the map's places and counters
kernel_rfl PRE_first_tail_x15_r0_body.zpl47 : PRE_first_tail_x15_r0_body.pl47.all (Nat.ble PRE_first_tail_x15_r0_body.s459.next) = true
kernel_rfl PRE_first_tail_x15_r0_body.zplnd47 : nodupT PRE_first_tail_x15_r0_body.pl47 PTrie.nil = true
kernel_rfl PRE_first_tail_x15_r0_body.zn147 : Nat.ble PRE_first_tail_x15_r0_body.s459.next 2711645 = true
kernel_rfl PRE_first_tail_x15_r0_body.zfirst47 : Nat.ble aFirst PRE_first_tail_x15_r0_body.s459.next = true
kernel_rfl PRE_first_tail_x15_r0_body.zscn47 : PRE_first_tail_x15_r0_body.s461.next = PRE_first_tail_x15_r0_body.s459.next + PRE_first_tail_x15_r0_body.pl47.length
kernel_rfl PRE_first_tail_x15_r0_body.zsmn47 : PRE_first_tail_x15_r0_body.s460.next = 2711645
kernel_rfl PRE_first_tail_x15_r0_body.zgrow47 : Nat.ble PRE_first_tail_x15_r0_body.s461.next PRE_first_tail_x15_r0_body.s460.next = true
-- the tables
kernel_rfl PRE_first_tail_x15_r0_body.zfresh47 : PRE_first_tail_x15_r0_body.S459.tab.all (fun e => PRE_first_tail_x15_r0_body.cws47.all fun v => e.noVar v) = true
kernel_rfl PRE_first_tail_x15_r0_body.zcnd47 : nodupT PRE_first_tail_x15_r0_body.cws47 PTrie.nil = true
kernel_rfl PRE_first_tail_x15_r0_body.znrHi47 : PRE_first_tail_x15_r0_body.nr47.all (fun r => Nat.blt r PRE_first_tail_x15_r0_body.S460.tab.length) = true
-- the frames: every framed address below the call's counter; the kept arrays the chain start's, extended in the merged state
kernel_rfl PRE_first_tail_x15_r0_body.zfrlt47 : [2665, 2673467, 2673472, 2673473].all (fun a => Nat.blt a PRE_first_tail_x15_r0_body.s459.next) = true
kernel_rfl PRE_first_tail_x15_r0_body.zg47_2665 : PRE_first_tail_x15_r0_body.s461.heap.get 2665 = some (.obj (objOf PRE_first_tail_x15_r0_body.s461 2665))
kernel_rfl PRE_first_tail_x15_r0_body.zk47_2665 : (objOf PRE_first_tail_x15_r0_body.s461 2665).kind = .array (arrOf PRE_first_tail_x15_r0_body.s0 2665)
kernel_rfl PRE_first_tail_x15_r0_body.zm47_2665 : PRE_first_tail_x15_r0_body.s460.heap.get 2665 = some (.obj { PRE_first_tail_x15_r0_body.kappa47.obj (objOf PRE_first_tail_x15_r0_body.s461 2665) with
  kind := .array (arrOf PRE_first_tail_x15_r0_body.s0 2665 ++ (arrOf PRE_first_tail_x15_r0_body.s460 2665).drop (arrOf PRE_first_tail_x15_r0_body.s0 2665).length) })
kernel_rfl PRE_first_tail_x15_r0_body.zg47_2673467 : PRE_first_tail_x15_r0_body.s461.heap.get 2673467 = some (.obj (objOf PRE_first_tail_x15_r0_body.s461 2673467))
kernel_rfl PRE_first_tail_x15_r0_body.zk47_2673467 : (objOf PRE_first_tail_x15_r0_body.s461 2673467).kind = .array (arrOf PRE_first_tail_x15_r0_body.s0 2673467)
kernel_rfl PRE_first_tail_x15_r0_body.zm47_2673467 : PRE_first_tail_x15_r0_body.s460.heap.get 2673467 = some (.obj { PRE_first_tail_x15_r0_body.kappa47.obj (objOf PRE_first_tail_x15_r0_body.s461 2673467) with
  kind := .array (arrOf PRE_first_tail_x15_r0_body.s0 2673467 ++ (arrOf PRE_first_tail_x15_r0_body.s460 2673467).drop (arrOf PRE_first_tail_x15_r0_body.s0 2673467).length) })
kernel_rfl PRE_first_tail_x15_r0_body.zw47_4910 : (PRE_first_tail_x15_r0_body.s461.heap.get 4910).isSome = true
kernel_rfl PRE_first_tail_x15_r0_body.zw47_2673472 : (PRE_first_tail_x15_r0_body.s461.heap.get 2673472).isSome = true
kernel_rfl PRE_first_tail_x15_r0_body.zw47_2673473 : (PRE_first_tail_x15_r0_body.s461.heap.get 2673473).isSome = true
-- the heap: the changed list in range, holding the stage's written and fresh addresses; the canonical side's image
kernel_rfl PRE_first_tail_x15_r0_body.zclbd47 : PRE_first_tail_x15_r0_body.cl47.all (fun b => Nat.blt (b / 4096) (4 ^ 31)) = true
kernel_rfl PRE_first_tail_x15_r0_body.zwr47 : PRE_first_tail_x15_r0_body.st47.wr.all (fun b => !Nat.blt b PRE_first_tail_x15_r0_body.s459.next || PRE_first_tail_x15_r0_body.cl47.contains b) = true
def PRE_first_tail_x15_r0_body.zl47 : List Nat := PRE_first_tail_x15_r0_body.cl47.filter fun a => !(List.contains [2665, 2673467] a)
kernel_rfl PRE_first_tail_x15_r0_body.zimgE47 : PRE_first_tail_x15_r0_body.zl47.map (fun a => PRE_first_tail_x15_r0_body.s460.heap.get (PRE_first_tail_x15_r0_body.kappa47.a a)) = PRE_first_tail_x15_r0_body.zl47.map (fun a => (PRE_first_tail_x15_r0_body.s461.heap.get a).map PRE_first_tail_x15_r0_body.kappa47.hobj)
theorem PRE_first_tail_x15_r0_body.zimg47 : HeapImg PRE_first_tail_x15_r0_body.kappa47 PRE_first_tail_x15_r0_body.s461 PRE_first_tail_x15_r0_body.s460 PRE_first_tail_x15_r0_body.zl47 := PRE_first_tail_x15_r0_body.zimgE47
-- the roots and their supports
kernel_rfl PRE_first_tail_x15_r0_body.zctl47 : PRE_first_tail_x15_r0_body.s460.ctl = PRE_first_tail_x15_r0_body.kappa47.ctl PRE_first_tail_x15_r0_body.s461.ctl
kernel_rfl PRE_first_tail_x15_r0_body.zstack47 : PRE_first_tail_x15_r0_body.s460.stack = PRE_first_tail_x15_r0_body.s461.stack.map PRE_first_tail_x15_r0_body.kappa47.frame
kernel_rfl PRE_first_tail_x15_r0_body.zjobs47 : PRE_first_tail_x15_r0_body.s460.jobs = PRE_first_tail_x15_r0_body.s461.jobs.map PRE_first_tail_x15_r0_body.kappa47.job
kernel_rfl PRE_first_tail_x15_r0_body.zstores47 : PRE_first_tail_x15_r0_body.s460.stores = PRE_first_tail_x15_r0_body.kappa47.stores PRE_first_tail_x15_r0_body.s461.stores
kernel_rfl PRE_first_tail_x15_r0_body.zroots47 : checkRootsSupp PRE_first_tail_x15_r0_body.s461 2062 = true
kernel_rfl PRE_first_tail_x15_r0_body.znC47 : PRE_first_tail_x15_r0_body.S459.tab.length + PRE_first_tail_x15_r0_body.cws47.length = 2062
-- the map as `Conv.compact_shift` states it (the call's counters for the literals)
kernel_rfl PRE_first_tail_x15_r0_body.zkap47 : PRE_first_tail_x15_r0_body.kappa47 = Conv.Map.compact PRE_first_tail_x15_r0_body.s459.next 2711645 PRE_first_tail_x15_r0_body.S459.tab.length PRE_first_tail_x15_r0_body.pl47 (PRE_first_tail_x15_r0_body.nr47.map NumV.ref) PRE_first_tail_x15_r0_body.kd47.big
  PRE_first_tail_x15_r0_body.kd47.region PRE_first_tail_x15_r0_body.kd47.nodeF
-- the bridge inactive at the canonical state (`Conv.FullShiftQ.toX`; the merged state's bridge is the canonical's: cbridge)
theorem PRE_first_tail_x15_r0_body.zbin47 : (Host.Ts.Sim.Full.bridgeOf PRE_first_tail_x15_r0_body.s461.ffi).active = false := (Host.Load.Boot.replay_active Host.Load.Run.Prompt.P.oblog2818)
-- the JS bookkeeping's step (`Conv.JClean.step` over the changed list) and the canonical roots' bigint freedom
kernel_rfl PRE_first_tail_x15_r0_body.zjc47 : Conv.jcleanListB (⟨19125, 16207, 2711626, 2062⟩ : Conv.Cnt) PRE_first_tail_x15_r0_body.s461 PRE_first_tail_x15_r0_body.cl47 = true
kernel_rfl PRE_first_tail_x15_r0_body.zrootsB47 : noBigRootsP (fun i => !Conv.oldBigB (⟨19125, 16207, 2711626, 2062⟩ : Conv.Cnt) i) PRE_first_tail_x15_r0_body.s461.trace PRE_first_tail_x15_r0_body.s461 = true
kernel_rfl PRE_first_tail_x15_r0_body.zhm47 : Nat.ble (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s0.ffi).mlx.nnext 16207 = true
theorem PRE_first_tail_x15_r0_body.cjcl47 (h : Conv.JClean (⟨19125, 16207, 2711625, 2062⟩ : Conv.Cnt) PRE_first_tail_x15_r0_body.s459) : Conv.JClean (⟨19125, 16207, 2711626, 2062⟩ : Conv.Cnt) PRE_first_tail_x15_r0_body.s461 :=
  Conv.JClean.step h (Conv.Cnt.le_of_leB PRE_first_tail_x15_r0_body.cle47)
    (Conv.heap_off_setAll PRE_first_tail_x15_r0_body.cheap47 fun a ha => Nat.blt_eq.mp (List.all_eq_true.mp PRE_first_tail_x15_r0_body.zclbd47 a ha)) PRE_first_tail_x15_r0_body.zjc47

end Host.Load.Run.Tpl
end

section -- st47/TypedLast
set_option Elab.async false
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
namespace Host.Load.Run.Tpl
open Host.Ts Host.Ts.Sim Host.Ts.Sim.Template

boot_rfl PRE_first_tail_x15_r0_body.st47.bodyLast from PRE_first_tail_x15_r0_body.st47.s1 to PRE_first_tail_x15_r0_body.st47.s2 :
  interpS (step PRE_first_tail_x15_r0_body.st47.F PRE_first_tail_x15_r0_body.st47.s1).run PRE_first_tail_x15_r0_body.st47.S1 = some (PRE_first_tail_x15_r0_body.st47.s2, PRE_first_tail_x15_r0_body.st47.S2)
kernel_rfl PRE_first_tail_x15_r0_body.st47.bodyHalt : isHalt PRE_first_tail_x15_r0_body.st47.s1.ctl = false
kernel_rfl PRE_first_tail_x15_r0_body.st47.bodyTopCheck : noBlockTop PRE_first_tail_x15_r0_body.st47.s2.stack = true

end Host.Load.Run.Tpl
end

section -- st47/TypedOk
set_option Elab.async false
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
namespace Host.Load.Run.Tpl
open Host.Ts Host.Ts.Sim Host.Ts.Sim.Template

noncomputable def PRE_first_tail_x15_r0_body.st47.bodyOkL (bytes : List Byte) (rows : Nat) : St PRE_first_tail_x15_r0_body.st47.F.S → SSrv → Bool :=
  okLocal (Host.Ts.Sim.Compose.VWFrames.bodyOk bytes rows)

noncomputable def PRE_first_tail_x15_r0_body.st47.bodyOkLN (bytes : List Byte) (rows : Nat) : St PRE_first_tail_x15_r0_body.st47.F.S → FSrv → Bool :=
  okLocalN (Host.Ts.Sim.Compose.VWFrames.bodyOkN bytes rows)

theorem PRE_first_tail_x15_r0_body.st47.bodyOkLN_ok (bytes : List Byte) (rows : Nat) (s : St PRE_first_tail_x15_r0_body.st47.F.S) (c : FSrv) (h : c.Wf) :
    PRE_first_tail_x15_r0_body.st47.bodyOkLN bytes rows s c = PRE_first_tail_x15_r0_body.st47.bodyOkL bytes rows s c.toS :=
  okLocalN_ok (Host.Ts.Sim.Compose.VWFrames.bodyOkN_ok bytes rows) s c h

kernel_rfl PRE_first_tail_x15_r0_body.st47.bodyAccepted0 :
  (fun (bytes : List Byte) (rows : Nat) => PRE_first_tail_x15_r0_body.st47.bodyOkL bytes rows PRE_first_tail_x15_r0_body.st47.s0 PRE_first_tail_x15_r0_body.st47.S0) = fun _ _ => true

kernel_rfl PRE_first_tail_x15_r0_body.st47.bodyAccepted1 :
  (fun (bytes : List Byte) (rows : Nat) => PRE_first_tail_x15_r0_body.st47.bodyOkL bytes rows PRE_first_tail_x15_r0_body.st47.s1 PRE_first_tail_x15_r0_body.st47.S1) = fun _ _ => true

end Host.Load.Run.Tpl
end

section -- st47/TypedK0
set_option Elab.async false
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
namespace Host.Load.Run.Tpl
open Host.Ts Host.Ts.Sim Host.Ts.Sim.Template

boot_rfl PRE_first_tail_x15_r0_body.st47.bodyK0F from PRE_first_tail_x15_r0_body.st47.s0 to PRE_first_tail_x15_r0_body.st47.s1 :
  (fun (bytes : List Byte) (rows : Nat) => runOkS PRE_first_tail_x15_r0_body.st47.F (PRE_first_tail_x15_r0_body.st47.bodyOkLN bytes rows)
    ((nth? PRE_first_tail_x15_r0_body.st47.ks 0).getD 0) PRE_first_tail_x15_r0_body.st47.s0 PRE_first_tail_x15_r0_body.st47.S0) = fun _ _ => some (PRE_first_tail_x15_r0_body.st47.s1, PRE_first_tail_x15_r0_body.st47.S1)
theorem PRE_first_tail_x15_r0_body.st47.bodyK0 :
  (fun (bytes : List Byte) (rows : Nat) => runOk PRE_first_tail_x15_r0_body.st47.F (PRE_first_tail_x15_r0_body.st47.bodyOkL bytes rows)
    ((nth? PRE_first_tail_x15_r0_body.st47.ks 0).getD 0) PRE_first_tail_x15_r0_body.st47.s0 PRE_first_tail_x15_r0_body.st47.S0) = fun _ _ => some (PRE_first_tail_x15_r0_body.st47.s1, PRE_first_tail_x15_r0_body.st47.S1) :=
  runOk_fun_of_runOkS PRE_first_tail_x15_r0_body.st47.bodyOkLN_ok PRE_first_tail_x15_r0_body.st47.bodyK0F
end Host.Load.Run.Tpl
end

section -- st47/TypedTpl
set_option Elab.async false
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
namespace Host.Load.Run.Tpl
open Host.Ts Host.Ts.Sim Host.Ts.Sim.Template

theorem PRE_first_tail_x15_r0_body.st47.bodyRun (bytes : List Byte) (rows : Nat) :
    runOk PRE_first_tail_x15_r0_body.st47.F (PRE_first_tail_x15_r0_body.st47.bodyOkL bytes rows) 206 PRE_first_tail_x15_r0_body.st47.s0 PRE_first_tail_x15_r0_body.st47.S0 = some (PRE_first_tail_x15_r0_body.st47.s1, PRE_first_tail_x15_r0_body.st47.S1) :=
  (congrFun (congrFun PRE_first_tail_x15_r0_body.st47.bodyK0 bytes) rows)

theorem PRE_first_tail_x15_r0_body.st47.bodyLocal (bytes : List Byte) (rows : Nat) : ∀ s S, PRE_first_tail_x15_r0_body.st47.bodyOkL bytes rows s S = true → Disp.localB s = true := okLocal_localB

noncomputable def PRE_first_tail_x15_r0_body.st47.bodyTpl (bytes : List Byte) (rows : Nat) : Host.Ts.Sim.Stage.StageTpl PRE_first_tail_x15_r0_body.st47.F (PRE_first_tail_x15_r0_body.st47.bodyOkL bytes rows) where
  s0 := PRE_first_tail_x15_r0_body.st47.s0
  S0 := PRE_first_tail_x15_r0_body.st47.S0
  s1 := PRE_first_tail_x15_r0_body.st47.s1
  S1 := PRE_first_tail_x15_r0_body.st47.S1
  s2 := PRE_first_tail_x15_r0_body.st47.s2
  S2 := PRE_first_tail_x15_r0_body.st47.S2
  n := 206
  ok0 := congrFun (congrFun PRE_first_tail_x15_r0_body.st47.bodyAccepted0 bytes) rows
  run := PRE_first_tail_x15_r0_body.st47.bodyRun bytes rows
  ok1 := congrFun (congrFun PRE_first_tail_x15_r0_body.st47.bodyAccepted1 bytes) rows
  halt := PRE_first_tail_x15_r0_body.st47.bodyHalt
  last := PRE_first_tail_x15_r0_body.st47.bodyLast
  top := noBlockTop_sound PRE_first_tail_x15_r0_body.st47.bodyTopCheck
end Host.Load.Run.Tpl
end

section -- SiteC48
set_option Elab.async false
namespace Host.Load.Run.Tpl
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
open Host.Ts Host.Ts.Sim Host.Ts.Sim.Template

/-! The compaction after the merge at call site 48 of chain `PRE_first_tail_x15_r0_body` (`Conv.compact`, `Conv.full_compactQ`): the canonical
state `PRE_first_tail_x15_r0_body.s478` (the stage's results at canonical places, its trace the call's) under `PRE_first_tail_x15_r0_body.kappa48` into the merged state
`PRE_first_tail_x15_r0_body.s477`. -/

def PRE_first_tail_x15_r0_body.pl48 : List Nat := [2714235, 2713410, 2714241, 2714237, 2713412, 2714243]
def PRE_first_tail_x15_r0_body.nr48 : List Nat := [2165, 2164, 2140, 2148, 2153, 2158, 2163, 2137, 2138, 2139, 2146, 2147, 2135, 2142, 2143, 2144, 2145, 2141]
/-- The native part of the compaction map (canonical → merged handles and nodes: its `big`, `region`, `nodeF`). -/
def PRE_first_tail_x15_r0_body.kd48 : RData :=
  ⟨2713129, 2714278, Stage.setAll PTrie.nil [(2713123, 2714235), (2713124, 2713410), (2713125, 2714241), (2713126, 2714237), (2713127, 2713412), (2713128, 2714243)], Stage.setAll PTrie.nil [(19160, 19186), (19161, 19164), (19162, 19187)],
   19163, 19188, 16253, 16253, Stage.setAll PTrie.nil [],
   Stage.setAll PTrie.nil [(2135, .ref 2165), (2136, .ref 2164), (2137, .ref 2140), (2138, .ref 2148), (2139, .ref 2153), (2140, .ref 2158), (2141, .ref 2163), (2142, .ref 2137), (2143, .ref 2138), (2144, .ref 2139), (2145, .ref 2146), (2146, .ref 2147), (2147, .ref 2135), (2148, .ref 2142), (2149, .ref 2143), (2150, .ref 2144), (2151, .ref 2145), (2152, .ref 2141)]⟩
/-- **The compaction map.** -/
noncomputable def PRE_first_tail_x15_r0_body.kappa48 : Map :=
  Conv.Map.compact 2713123 2714278 2135 PRE_first_tail_x15_r0_body.pl48 (PRE_first_tail_x15_r0_body.nr48.map NumV.ref) PRE_first_tail_x15_r0_body.kd48.big
    PRE_first_tail_x15_r0_body.kd48.region PRE_first_tail_x15_r0_body.kd48.nodeF
/-- The canonical result variables and their images, the merged state's entries (`Conv.compactθ`). -/
def PRE_first_tail_x15_r0_body.cws48 : List Nat := [1827, 1828, 1829, 1830, 1831, 1832, 1833, 1834, 1835, 1836, 1837, 1838, 1839, 1840, 1841, 1842, 1843, 1844]
noncomputable def PRE_first_tail_x15_r0_body.crs48 : List SymE := PRE_first_tail_x15_r0_body.nr48.map fun r => (nth? PRE_first_tail_x15_r0_body.S477.tab r).getD (.var 0)
noncomputable def PRE_first_tail_x15_r0_body.ctheta48 : Nat → SymE := Conv.compactθ PRE_first_tail_x15_r0_body.cws48 PRE_first_tail_x15_r0_body.crs48
/-- The call's entries the stage wrote (renamed in the canonical state with the results). -/
def PRE_first_tail_x15_r0_body.wrB48 : List Nat := [2665, 2672424, 2673467, 2712297, 2712842, 2713098]

kernel_rfl PRE_first_tail_x15_r0_body.ctab48 : PRE_first_tail_x15_r0_body.S478.tab = PRE_first_tail_x15_r0_body.S476.tab ++ PRE_first_tail_x15_r0_body.cws48.map SymE.var
kernel_rfl PRE_first_tail_x15_r0_body.ctrace48 : PRE_first_tail_x15_r0_body.s478.trace = PRE_first_tail_x15_r0_body.s476.trace
kernel_rfl PRE_first_tail_x15_r0_body.cnext48 : PRE_first_tail_x15_r0_body.s478.next = 2713129
kernel_rfl PRE_first_tail_x15_r0_body.ccounters48 : ((Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s478.ffi).mlx.next, (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s478.ffi).mlx.nnext) = (19163, 16253)
-- the merged state's readback queue, carried to the canonical state (`Conv.FullShiftQ.tokens`, `tokSupp`)
kernel_rfl PRE_first_tail_x15_r0_body.cqueue48 : (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s477.ffi).mlx.tokens = (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s478.ffi).mlx.tokens.map PRE_first_tail_x15_r0_body.kappa48.nv
kernel_rfl PRE_first_tail_x15_r0_body.ctokSupp48 : (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s478.ffi).mlx.tokens.all (bSN 2153) = true
-- the written and the result entries carry no bigint of the canonical fresh band [next, E) and no fresh region
kernel_rfl PRE_first_tail_x15_r0_body.cclean48 : Conv.cleanListB 19163 131072 (fun r => Nat.ble 76652 r) PRE_first_tail_x15_r0_body.s478
    (PRE_first_tail_x15_r0_body.wrB48 ++ (List.range 6).map (2713123 + ·)) = true
kernel_rfl PRE_first_tail_x15_r0_body.cbigs48 : bigsOutB 19163 131072 (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s478.ffi).mlx = true

end Host.Load.Run.Tpl
end

section -- SiteK48
set_option Elab.async false
namespace Host.Load.Run.Tpl
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
open Host.Ts Host.Ts.Sim Host.Ts.Sim.Template

/-! The canonical state's closedness from the call's (`Conv.closed_of_callB`, `Conv.sst_of_callB`): it keeps the call's entries
off the written and the result ones (`PRE_first_tail_x15_r0_body.cl48`; natively the written and result handles, the result nodes, the written
and result items), and those are checked. -/

def PRE_first_tail_x15_r0_body.cl48 : List Nat := [2665, 2672424, 2673467, 2712297, 2712842, 2713098, 2713123, 2713124, 2713125, 2713126, 2713127, 2713128]
def PRE_first_tail_x15_r0_body.clo48 : List Nat := [19140, 19153, 19159, 19160, 19161, 19162]
def PRE_first_tail_x15_r0_body.cln48 : List Nat := [16226, 16227, 16228, 16229, 16230, 16231, 16232, 16233, 16234, 16235, 16236, 16237, 16238, 16239, 16240, 16241, 16242, 16243, 16244, 16245, 16246, 16247, 16248, 16249, 16250, 16251, 16252]
def PRE_first_tail_x15_r0_body.cli48 : List Nat := [16226, 16227, 16228, 16229, 16230, 16231, 16232, 16233, 16234, 16235, 16236, 16237, 16238, 16239, 16240, 16241, 16242, 16243, 16244, 16245, 16246, 16247, 16248, 16249, 16250, 16251, 16252]
kernel_rfl PRE_first_tail_x15_r0_body.cheap48 : PRE_first_tail_x15_r0_body.s478.heap = Stage.setAll PRE_first_tail_x15_r0_body.s476.heap (PRE_first_tail_x15_r0_body.cl48.filterMap fun a => (PRE_first_tail_x15_r0_body.s478.heap.get a).map (a, ·))
kernel_rfl PRE_first_tail_x15_r0_body.cnextLe48 : Nat.ble PRE_first_tail_x15_r0_body.s476.next PRE_first_tail_x15_r0_body.s478.next = true
kernel_rfl PRE_first_tail_x15_r0_body.ckeepP48 : Conv.keptPresentB PRE_first_tail_x15_r0_body.s476 PRE_first_tail_x15_r0_body.s478 PRE_first_tail_x15_r0_body.cl48 = true
kernel_rfl PRE_first_tail_x15_r0_body.csupp48 : Conv.suppListB PRE_first_tail_x15_r0_body.s478 2153 PRE_first_tail_x15_r0_body.cl48 = true
kernel_rfl PRE_first_tail_x15_r0_body.cbound48 : Conv.boundListB PRE_first_tail_x15_r0_body.s478 PRE_first_tail_x15_r0_body.cl48 = true
kernel_rfl PRE_first_tail_x15_r0_body.cnodesK48 : (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s478.ffi).mlx.nodes = Stage.setAll (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s476.ffi).mlx.nodes (PRE_first_tail_x15_r0_body.cln48.filterMap fun i => ((Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s478.ffi).mlx.nodes.get i).map (i, ·))
kernel_rfl PRE_first_tail_x15_r0_body.cobjsK48 : (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s478.ffi).mlx.objs = Stage.setAll (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s476.ffi).mlx.objs (PRE_first_tail_x15_r0_body.clo48.filterMap fun i => ((Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s478.ffi).mlx.objs.get i).map (i, ·))
kernel_rfl PRE_first_tail_x15_r0_body.citemsK48 : (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s478.ffi).mlx.items = Stage.setAll (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s476.ffi).mlx.items (PRE_first_tail_x15_r0_body.cli48.filterMap fun i => ((Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s478.ffi).mlx.items.get i).map (i, ·))
kernel_rfl PRE_first_tail_x15_r0_body.csst48 : Conv.sstListB 2153 (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s478.ffi).mlx PRE_first_tail_x15_r0_body.cln48 PRE_first_tail_x15_r0_body.clo48 PRE_first_tail_x15_r0_body.cli48 = true

end Host.Load.Run.Tpl
end

section -- SiteCl48
set_option Elab.async false
namespace Host.Load.Run.Tpl
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
open Host.Ts Host.Ts.Sim Host.Ts.Sim.Template

kernel_rfl PRE_first_tail_x15_r0_body.ckA48 : (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s478.ffi).mlx.arrs = Stage.setAll (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s476.ffi).mlx.arrs (PRE_first_tail_x15_r0_body.clo48.filterMap fun i => ((Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s478.ffi).mlx.arrs.get i).map (i, ·))
kernel_rfl PRE_first_tail_x15_r0_body.cbd48 : (PRE_first_tail_x15_r0_body.clo48 ++ PRE_first_tail_x15_r0_body.cln48 ++ PRE_first_tail_x15_r0_body.cli48).all (fun i => Nat.blt (i / 4096) (4 ^ 31)) = true
kernel_rfl PRE_first_tail_x15_r0_body.cle48 : Conv.Cnt.leB (⟨19160, 16226, 2713123, 2135⟩ : Conv.Cnt) (⟨19163, 16253, 2713129, 2153⟩ : Conv.Cnt) = true
kernel_rfl PRE_first_tail_x15_r0_body.cck48 : Conv.ncleanListB (⟨19163, 16253, 2713129, 2153⟩ : Conv.Cnt) (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s478.ffi).mlx PRE_first_tail_x15_r0_body.clo48 PRE_first_tail_x15_r0_body.cln48 PRE_first_tail_x15_r0_body.cli48 = true
theorem PRE_first_tail_x15_r0_body.cncl48 (h : Conv.NClean (⟨19160, 16226, 2713123, 2135⟩ : Conv.Cnt) (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s476.ffi).mlx) : Conv.NClean (⟨19163, 16253, 2713129, 2153⟩ : Conv.Cnt) (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s478.ffi).mlx :=
  Conv.NClean.stepKeep h PRE_first_tail_x15_r0_body.cle48 PRE_first_tail_x15_r0_body.ckA48 PRE_first_tail_x15_r0_body.cobjsK48 PRE_first_tail_x15_r0_body.cnodesK48 PRE_first_tail_x15_r0_body.citemsK48 PRE_first_tail_x15_r0_body.cbd48 PRE_first_tail_x15_r0_body.cck48

end Host.Load.Run.Tpl
end

section -- SiteS48
set_option Elab.async false
namespace Host.Load.Run.Tpl
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
open Host.Ts Host.Ts.Sim Host.Ts.Sim.Template

/-! The compaction's native shift at call site 48 from its footprint (`Conv.nshift_of_foot`), and the observers'
(`liveShift_foot`, `kernShift_foot`): `Conv.FullShiftQ` for `Conv.full_compactQ`, given the call's bookkeeping and its
relation's facts. -/

/-- The load parameters of the chain (band-free: its start's node counter as `NL` and `N0`). -/
def PRE_first_tail_x15_r0_body.Pc48 : LoadP := ⟨18151, 131072, 1099511627776, 15235, 15235, []⟩
/-- The site's band raised to the map's checked fixed-node prefix, including newly recorded closure traces. -/
def PRE_first_tail_x15_r0_body.P48 : LoadP := PRE_first_tail_x15_r0_body.Pc48.raise 16253
kernel_rfl PRE_first_tail_x15_r0_body.craise48 : Nat.ble PRE_first_tail_x15_r0_body.Pc48.N0 16253 = true
theorem PRE_first_tail_x15_r0_body.raised48 : Host.Ts.Sim.Full.Raised PRE_first_tail_x15_r0_body.Pc48 PRE_first_tail_x15_r0_body.P48 :=
  .inr ⟨16253, rfl, Nat.le_of_ble_eq_true PRE_first_tail_x15_r0_body.craise48, rfl⟩
noncomputable abbrev PRE_first_tail_x15_r0_body.cx0_48 : Host.Load.LSt := clearTokens (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s478.ffi)
noncomputable abbrev PRE_first_tail_x15_r0_body.cx1_48 : Host.Load.LSt := clearTokens (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s477.ffi)
def PRE_first_tail_x15_r0_body.khinv48 : PTrie Nat := Stage.setAll PTrie.nil [(19186, 19160), (19164, 19161), (19187, 19162)]
def PRE_first_tail_x15_r0_body.kninv48 : PTrie Nat := Stage.setAll PTrie.nil [(16226, 16226), (16227, 16227), (16228, 16228), (16229, 16229), (16230, 16230), (16231, 16231), (16232, 16232), (16233, 16233), (16234, 16234), (16235, 16235), (16236, 16236), (16237, 16237), (16238, 16238), (16239, 16239), (16240, 16240), (16241, 16241), (16242, 16242), (16243, 16243), (16244, 16244), (16245, 16245), (16246, 16246), (16247, 16247), (16248, 16248), (16249, 16249), (16250, 16250), (16251, 16251), (16252, 16252)]
/-- The stage's footprint: its written and fresh handles, fresh nodes, written and fresh items. -/
def PRE_first_tail_x15_r0_body.cwS48 : List Nat := [19140, 19153, 19159, 19160, 19161, 19162, 19163, 19164, 19165, 19166, 19167, 19168, 19169, 19170, 19171, 19172, 19173, 19174, 19175, 19176, 19177, 19178, 19179, 19180, 19181, 19182, 19183, 19184, 19185, 19186, 19187]
def PRE_first_tail_x15_r0_body.cnS48 : List Nat := List.range' 16226 27
def PRE_first_tail_x15_r0_body.ciS48 : List Nat := [] ++ List.range' 16226 27

-- the small checks (`MChecks`'s)
kernel_rfl PRE_first_tail_x15_r0_body.cnh048 : PRE_first_tail_x15_r0_body.kd48.nh0 = PRE_first_tail_x15_r0_body.cx0_48.mlx.next
kernel_rfl PRE_first_tail_x15_r0_body.cnh148 : PRE_first_tail_x15_r0_body.kd48.nh1 = PRE_first_tail_x15_r0_body.cx1_48.mlx.next
kernel_rfl PRE_first_tail_x15_r0_body.cnn048 : PRE_first_tail_x15_r0_body.kd48.nn0 = PRE_first_tail_x15_r0_body.cx0_48.mlx.nnext
kernel_rfl PRE_first_tail_x15_r0_body.cnn148 : PRE_first_tail_x15_r0_body.kd48.nn1 = PRE_first_tail_x15_r0_body.cx1_48.mlx.nnext
kernel_rfl PRE_first_tail_x15_r0_body.cplo48 : (Nat.blt 0 PRE_first_tail_x15_r0_body.P48.lo && Nat.ble PRE_first_tail_x15_r0_body.P48.lo PRE_first_tail_x15_r0_body.cx0_48.mlx.next && Nat.ble PRE_first_tail_x15_r0_body.P48.lo RData.bigHi && Nat.ble RData.bigHi PRE_first_tail_x15_r0_body.P48.E) = true
kernel_rfl PRE_first_tail_x15_r0_body.ccnt48 : (Nat.ble PRE_first_tail_x15_r0_body.cx0_48.mlx.next PRE_first_tail_x15_r0_body.cx1_48.mlx.next && Nat.ble PRE_first_tail_x15_r0_body.cx0_48.mlx.nnext PRE_first_tail_x15_r0_body.cx1_48.mlx.nnext) = true
kernel_rfl PRE_first_tail_x15_r0_body.cnband48 : (Nat.blt 0 PRE_first_tail_x15_r0_body.P48.NL && Nat.ble PRE_first_tail_x15_r0_body.P48.NL PRE_first_tail_x15_r0_body.P48.N0 && Nat.ble PRE_first_tail_x15_r0_body.P48.N0 PRE_first_tail_x15_r0_body.cx0_48.mlx.nnext) = true
kernel_rfl PRE_first_tail_x15_r0_body.chbelow48 : PRE_first_tail_x15_r0_body.kd48.checkHndBelow = true
kernel_rfl PRE_first_tail_x15_r0_body.chren48 : checkRenG PRE_first_tail_x15_r0_body.kd48.hnd PRE_first_tail_x15_r0_body.khinv48 (phB PRE_first_tail_x15_r0_body.cx0_48.mlx) = true
kernel_rfl PRE_first_tail_x15_r0_body.cband48 : PRE_first_tail_x15_r0_body.kd48.checkBand PRE_first_tail_x15_r0_body.P48.lo = true
kernel_rfl PRE_first_tail_x15_r0_body.cnh1pos48 : Nat.blt 0 PRE_first_tail_x15_r0_body.kd48.nh1 = true
kernel_rfl PRE_first_tail_x15_r0_body.cnren48 : checkRenG PRE_first_tail_x15_r0_body.kd48.node PRE_first_tail_x15_r0_body.kninv48 (pnB PRE_first_tail_x15_r0_body.cx0_48.mlx) = true
kernel_rfl PRE_first_tail_x15_r0_body.cnlow48 : (PTrie.keysA PRE_first_tail_x15_r0_body.kd48.node).all (fun j => Nat.ble PRE_first_tail_x15_r0_body.P48.NL j && Nat.blt (PRE_first_tail_x15_r0_body.kd48.nodeF j) PRE_first_tail_x15_r0_body.cx1_48.mlx.nnext) = true
kernel_rfl PRE_first_tail_x15_r0_body.cabs0a48 : PRE_first_tail_x15_r0_body.cx0_48.mlx.arrs.get 0 = none
kernel_rfl PRE_first_tail_x15_r0_body.cabs0b48 : PRE_first_tail_x15_r0_body.cx0_48.mlx.objs.get 0 = none
kernel_rfl PRE_first_tail_x15_r0_body.ctok148 : PRE_first_tail_x15_r0_body.cx1_48.mlx.tokens = []
kernel_rfl PRE_first_tail_x15_r0_body.cpend48 : PRE_first_tail_x15_r0_body.cx1_48.mlx.pending = PRE_first_tail_x15_r0_body.cx0_48.mlx.pending.map PRE_first_tail_x15_r0_body.kappa48.pend
kernel_rfl PRE_first_tail_x15_r0_body.cerrh48 : PRE_first_tail_x15_r0_body.cx1_48.mlx.errh = PRE_first_tail_x15_r0_body.cx0_48.mlx.errh.map PRE_first_tail_x15_r0_body.kappa48.arg
kernel_rfl PRE_first_tail_x15_r0_body.cfiles48 : PRE_first_tail_x15_r0_body.cx1_48.mlx.files = PRE_first_tail_x15_r0_body.cx0_48.mlx.files
kernel_rfl PRE_first_tail_x15_r0_body.carch48 : PRE_first_tail_x15_r0_body.cx1_48.mlx.arch = PRE_first_tail_x15_r0_body.cx0_48.mlx.arch
kernel_rfl PRE_first_tail_x15_r0_body.csizes48 : PRE_first_tail_x15_r0_body.cx1_48.mlx.deviceSizes = PRE_first_tail_x15_r0_body.cx0_48.mlx.deviceSizes
kernel_rfl PRE_first_tail_x15_r0_body.cwired48 : PRE_first_tail_x15_r0_body.cx1_48.mlx.wired = PRE_first_tail_x15_r0_body.cx0_48.mlx.wired
kernel_rfl PRE_first_tail_x15_r0_body.chost48 : PRE_first_tail_x15_r0_body.cx1_48.host = PRE_first_tail_x15_r0_body.cx0_48.host
-- the compaction map's addresses are `PRE_first_tail_x15_r0_body.kd48`'s
kernel_rfl PRE_first_tail_x15_r0_body.ckn048 : PRE_first_tail_x15_r0_body.kd48.n0 = 2713129
kernel_rfl PRE_first_tail_x15_r0_body.ckn148 : PRE_first_tail_x15_r0_body.kd48.n1 = 2714278
kernel_rfl PRE_first_tail_x15_r0_body.ckheap48 : (PTrie.keysA PRE_first_tail_x15_r0_body.kd48.heap).all (fun x => Nat.ble 2713123 x) = true
kernel_rfl PRE_first_tail_x15_r0_body.ckpl48 : (List.range 6).all (fun j => decide (PRE_first_tail_x15_r0_body.kd48.heap.get (2713123 + j) = nth? PRE_first_tail_x15_r0_body.pl48 j)) = true
-- the map fixes the call's names (`Conv.fixOld_compact`), the call's counters
kernel_rfl PRE_first_tail_x15_r0_body.fja48 : Nat.ble 2713123 2713123 = true
kernel_rfl PRE_first_tail_x15_r0_body.fn48 : Nat.ble 2135 2135 = true
kernel_rfl PRE_first_tail_x15_r0_body.fjaD48 : Nat.ble 2713123 PRE_first_tail_x15_r0_body.kd48.n0 = true
kernel_rfl PRE_first_tail_x15_r0_body.fxn48 : Nat.ble 19160 PRE_first_tail_x15_r0_body.kd48.nh0 = true
kernel_rfl PRE_first_tail_x15_r0_body.fnn48 : Nat.ble 16226 PRE_first_tail_x15_r0_body.kd48.nn0 = true
kernel_rfl PRE_first_tail_x15_r0_body.fxb48 : Nat.ble 19160 RData.bigHi = true
kernel_rfl PRE_first_tail_x15_r0_body.fheap48 : (PTrie.keysA PRE_first_tail_x15_r0_body.kd48.heap).all (Nat.ble (⟨19160, 16226, 2713123, 2135⟩ : Conv.Cnt).ja) = true
kernel_rfl PRE_first_tail_x15_r0_body.fhnd48 : (PTrie.keysA PRE_first_tail_x15_r0_body.kd48.hnd).all (Nat.ble (⟨19160, 16226, 2713123, 2135⟩ : Conv.Cnt).xn) = true
kernel_rfl PRE_first_tail_x15_r0_body.fnode48 : (PTrie.keysA PRE_first_tail_x15_r0_body.kd48.node).all (Nat.ble (⟨19160, 16226, 2713123, 2135⟩ : Conv.Cnt).nn) = true
/-- The compaction map fixes the call's names. -/
theorem PRE_first_tail_x15_r0_body.cfix48 : Conv.FixOld (⟨19160, 16226, 2713123, 2135⟩ : Conv.Cnt) PRE_first_tail_x15_r0_body.kappa48 :=
  Conv.fixOld_compact (Nat.le_of_ble_eq_true PRE_first_tail_x15_r0_body.fja48) (Nat.le_of_ble_eq_true PRE_first_tail_x15_r0_body.fn48) (Nat.le_of_ble_eq_true PRE_first_tail_x15_r0_body.fjaD48) (Nat.le_of_ble_eq_true PRE_first_tail_x15_r0_body.fxn48) (Nat.le_of_ble_eq_true PRE_first_tail_x15_r0_body.fnn48) (Nat.le_of_ble_eq_true PRE_first_tail_x15_r0_body.fxb48) PRE_first_tail_x15_r0_body.fheap48 PRE_first_tail_x15_r0_body.fhnd48 PRE_first_tail_x15_r0_body.fnode48
kernel_rfl PRE_first_tail_x15_r0_body.fcxn48 : (⟨19160, 16226, 2713123, 2135⟩ : Conv.Cnt).xn = (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s476.ffi).mlx.next
kernel_rfl PRE_first_tail_x15_r0_body.fcnn48 : (⟨19160, 16226, 2713123, 2135⟩ : Conv.Cnt).nn = (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s476.ffi).mlx.nnext
kernel_rfl PRE_first_tail_x15_r0_body.fle048 : (Nat.ble (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s476.ffi).mlx.next PRE_first_tail_x15_r0_body.cx0_48.mlx.next && Nat.ble (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s476.ffi).mlx.nnext PRE_first_tail_x15_r0_body.cx0_48.mlx.nnext && Nat.ble (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s476.ffi).mlx.next RData.bigHi) = true
kernel_rfl PRE_first_tail_x15_r0_body.fnk48 : (PTrie.keysA PRE_first_tail_x15_r0_body.kd48.node).all (Nat.ble (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s476.ffi).mlx.nnext) = true
-- the merged state keeps the call's entries off the stage's footprint
kernel_rfl PRE_first_tail_x15_r0_body.f1A48 : PRE_first_tail_x15_r0_body.cx1_48.mlx.arrs = Stage.setAll (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s476.ffi).mlx.arrs (PRE_first_tail_x15_r0_body.cwS48.filterMap fun i => (PRE_first_tail_x15_r0_body.cx1_48.mlx.arrs.get i).map (i, ·))
kernel_rfl PRE_first_tail_x15_r0_body.f1O48 : PRE_first_tail_x15_r0_body.cx1_48.mlx.objs = Stage.setAll (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s476.ffi).mlx.objs (PRE_first_tail_x15_r0_body.cwS48.filterMap fun i => (PRE_first_tail_x15_r0_body.cx1_48.mlx.objs.get i).map (i, ·))
kernel_rfl PRE_first_tail_x15_r0_body.f1N48 : PRE_first_tail_x15_r0_body.cx1_48.mlx.nodes = Stage.setAll (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s476.ffi).mlx.nodes (PRE_first_tail_x15_r0_body.cnS48.filterMap fun i => (PRE_first_tail_x15_r0_body.cx1_48.mlx.nodes.get i).map (i, ·))
kernel_rfl PRE_first_tail_x15_r0_body.f1I48 : PRE_first_tail_x15_r0_body.cx1_48.mlx.items = Stage.setAll (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s476.ffi).mlx.items (PRE_first_tail_x15_r0_body.ciS48.filterMap fun i => (PRE_first_tail_x15_r0_body.cx1_48.mlx.items.get i).map (i, ·))
kernel_rfl PRE_first_tail_x15_r0_body.fbd48 : (PRE_first_tail_x15_r0_body.clo48 ++ PRE_first_tail_x15_r0_body.cln48 ++ PRE_first_tail_x15_r0_body.cli48 ++ PRE_first_tail_x15_r0_body.cwS48 ++ PRE_first_tail_x15_r0_body.cnS48 ++ PRE_first_tail_x15_r0_body.ciS48).all (fun i => Nat.blt (i / 4096) (4 ^ 31)) = true
kernel_rfl PRE_first_tail_x15_r0_body.fincW48 : PRE_first_tail_x15_r0_body.cwS48.all (fun h => !Nat.blt h (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s476.ffi).mlx.next || PRE_first_tail_x15_r0_body.clo48.contains h) = true
kernel_rfl PRE_first_tail_x15_r0_body.fincI48 : PRE_first_tail_x15_r0_body.ciS48.all (fun k => !Nat.blt k (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s476.ffi).mlx.nnext || PRE_first_tail_x15_r0_body.cli48.contains k) = true
kernel_rfl PRE_first_tail_x15_r0_body.fincN48 : PRE_first_tail_x15_r0_body.cnS48.all (Nat.ble (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s476.ffi).mlx.nnext) = true
kernel_rfl PRE_first_tail_x15_r0_body.flnF48 : PRE_first_tail_x15_r0_body.cln48.all (Nat.ble (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s476.ffi).mlx.nnext) = true
-- the checks over the changed lists
kernel_rfl PRE_first_tail_x15_r0_body.fh48 : PRE_first_tail_x15_r0_body.clo48.all (handleOK PRE_first_tail_x15_r0_body.kappa48 PRE_first_tail_x15_r0_body.P48.lo PRE_first_tail_x15_r0_body.cx0_48.mlx PRE_first_tail_x15_r0_body.cx1_48.mlx) = true
kernel_rfl PRE_first_tail_x15_r0_body.fo48 : PRE_first_tail_x15_r0_body.clo48.map (fun h => PRE_first_tail_x15_r0_body.cx1_48.mlx.objs.get (PRE_first_tail_x15_r0_body.kappa48.handle h)) = PRE_first_tail_x15_r0_body.clo48.map (fun h => (PRE_first_tail_x15_r0_body.cx0_48.mlx.objs.get h).map PRE_first_tail_x15_r0_body.kappa48.nobj)
kernel_rfl PRE_first_tail_x15_r0_body.fok48 : PRE_first_tail_x15_r0_body.clo48.all (objOK PRE_first_tail_x15_r0_body.kappa48 PRE_first_tail_x15_r0_body.P48.NL PRE_first_tail_x15_r0_body.cx0_48.mlx) = true
kernel_rfl PRE_first_tail_x15_r0_body.fnd48 : PRE_first_tail_x15_r0_body.cln48.all (nodeOKF PRE_first_tail_x15_r0_body.kappa48 PRE_first_tail_x15_r0_body.P48 PRE_first_tail_x15_r0_body.cx0_48.mlx PRE_first_tail_x15_r0_body.cx1_48.mlx) = true
kernel_rfl PRE_first_tail_x15_r0_body.fp48 : ((PRE_first_tail_x15_r0_body.cln48.filter (fullB PRE_first_tail_x15_r0_body.P48))).map (fun i => (PRE_first_tail_x15_r0_body.cx1_48.mlx.nodes.get (PRE_first_tail_x15_r0_body.kappa48.node i)).map Host.Mlx.Ffi.Node.prim) =
  ((PRE_first_tail_x15_r0_body.cln48.filter (fullB PRE_first_tail_x15_r0_body.P48))).map (fun i => (PRE_first_tail_x15_r0_body.cx0_48.mlx.nodes.get i).map fun nd => PRE_first_tail_x15_r0_body.kappa48.prim nd.prim)
kernel_rfl PRE_first_tail_x15_r0_body.fnordI48 : incrB PRE_first_tail_x15_r0_body.kd48.nodeF (List.range' 16226 27) = true
kernel_rfl PRE_first_tail_x15_r0_body.fnordK48 : (PTrie.keysA PRE_first_tail_x15_r0_body.kd48.node).all (fun k => Nat.ble 16226 k && Nat.blt k 16253) = true
kernel_rfl PRE_first_tail_x15_r0_body.fnordL48 : (PRE_first_tail_x15_r0_body.cln48.filter (Nat.ble PRE_first_tail_x15_r0_body.P48.N0)).all (fun i => Nat.ble i (PRE_first_tail_x15_r0_body.kd48.nodeF i) && (Nat.blt i 16253 || Nat.ble PRE_first_tail_x15_r0_body.kd48.nn0 i)) = true
theorem PRE_first_tail_x15_r0_body.fnord48 : (PRE_first_tail_x15_r0_body.cln48.filter (Nat.ble PRE_first_tail_x15_r0_body.P48.N0)).all (fun i => Nat.ble i (PRE_first_tail_x15_r0_body.kd48.nodeF i) &&
    (PTrie.keysA PRE_first_tail_x15_r0_body.kd48.node).all fun j => !Nat.blt j i || Nat.blt (PRE_first_tail_x15_r0_body.kd48.nodeF j) (PRE_first_tail_x15_r0_body.kd48.nodeF i)) = true :=
  cnord_of PRE_first_tail_x15_r0_body.cnlow48 PRE_first_tail_x15_r0_body.cnn148 PRE_first_tail_x15_r0_body.fnordI48 PRE_first_tail_x15_r0_body.fnordK48 PRE_first_tail_x15_r0_body.fnordL48
kernel_rfl PRE_first_tail_x15_r0_body.fi48 : PRE_first_tail_x15_r0_body.cli48.all (pnB PRE_first_tail_x15_r0_body.cx0_48.mlx) = true
kernel_rfl PRE_first_tail_x15_r0_body.fii48 : PRE_first_tail_x15_r0_body.cli48.all (fun k => decide (PRE_first_tail_x15_r0_body.cx1_48.mlx.items.get (PRE_first_tail_x15_r0_body.kappa48.node k) = (PRE_first_tail_x15_r0_body.cx0_48.mlx.items.get k).map PRE_first_tail_x15_r0_body.kappa48.nv)) = true
/-- **The compaction's footprint.** -/
theorem PRE_first_tail_x15_r0_body.cfoot48 (clean : Conv.NClean (⟨19160, 16226, 2713123, 2135⟩ : Conv.Cnt) (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s476.ffi).mlx) (hltC : ∀ h, PH (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s476.ffi).mlx h → h < (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s476.ffi).mlx.next) (nltC : ∀ i, PN (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s476.ffi).mlx i → i < (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s476.ffi).mlx.nnext) (itemsC : ∀ k v, (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s476.ffi).mlx.items.get k = some v → PN (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s476.ffi).mlx k) (tracedC : ∀ h o, (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s476.ffi).mlx.objs.get h = some o → ∀ i ∈ objTraces o, i < PRE_first_tail_x15_r0_body.P48.NL) (cl : SSt (· < 2153) PRE_first_tail_x15_r0_body.cx0_48.mlx) :
    Conv.MFoot PRE_first_tail_x15_r0_body.P48 2153 PRE_first_tail_x15_r0_body.kappa48 PRE_first_tail_x15_r0_body.kd48 PRE_first_tail_x15_r0_body.khinv48 PRE_first_tail_x15_r0_body.kninv48 (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s476.ffi).mlx PRE_first_tail_x15_r0_body.cx0_48.mlx PRE_first_tail_x15_r0_body.cx1_48.mlx (⟨19160, 16226, 2713123, 2135⟩ : Conv.Cnt) PRE_first_tail_x15_r0_body.clo48 PRE_first_tail_x15_r0_body.cln48 PRE_first_tail_x15_r0_body.cli48 PRE_first_tail_x15_r0_body.cwS48 PRE_first_tail_x15_r0_body.cnS48 PRE_first_tail_x15_r0_body.ciS48 :=
  ⟨rfl, rfl, rfl, PRE_first_tail_x15_r0_body.cnh048, PRE_first_tail_x15_r0_body.cnh148, PRE_first_tail_x15_r0_body.cnn048, PRE_first_tail_x15_r0_body.cnn148, PRE_first_tail_x15_r0_body.cplo48, PRE_first_tail_x15_r0_body.ccnt48, PRE_first_tail_x15_r0_body.cnband48, PRE_first_tail_x15_r0_body.chbelow48, PRE_first_tail_x15_r0_body.chren48, PRE_first_tail_x15_r0_body.cband48, PRE_first_tail_x15_r0_body.cnh1pos48, PRE_first_tail_x15_r0_body.cnren48, PRE_first_tail_x15_r0_body.cnlow48, PRE_first_tail_x15_r0_body.cabs0a48, PRE_first_tail_x15_r0_body.cabs0b48, PRE_first_tail_x15_r0_body.ctok148, PRE_first_tail_x15_r0_body.cpend48, PRE_first_tail_x15_r0_body.cerrh48, PRE_first_tail_x15_r0_body.cfiles48, PRE_first_tail_x15_r0_body.carch48, PRE_first_tail_x15_r0_body.csizes48, PRE_first_tail_x15_r0_body.cwired48, PRE_first_tail_x15_r0_body.cfix48, clean, PRE_first_tail_x15_r0_body.fcxn48, PRE_first_tail_x15_r0_body.fcnn48, hltC, nltC, itemsC, tracedC, cl, PRE_first_tail_x15_r0_body.fle048, PRE_first_tail_x15_r0_body.fnk48, PRE_first_tail_x15_r0_body.ckA48, PRE_first_tail_x15_r0_body.cobjsK48, PRE_first_tail_x15_r0_body.cnodesK48, PRE_first_tail_x15_r0_body.citemsK48, PRE_first_tail_x15_r0_body.f1A48, PRE_first_tail_x15_r0_body.f1O48, PRE_first_tail_x15_r0_body.f1N48, PRE_first_tail_x15_r0_body.f1I48, PRE_first_tail_x15_r0_body.fbd48, PRE_first_tail_x15_r0_body.fincW48, PRE_first_tail_x15_r0_body.fincI48, PRE_first_tail_x15_r0_body.fincN48, PRE_first_tail_x15_r0_body.flnF48, PRE_first_tail_x15_r0_body.fh48, PRE_first_tail_x15_r0_body.fo48, PRE_first_tail_x15_r0_body.fok48, PRE_first_tail_x15_r0_body.fnd48, PRE_first_tail_x15_r0_body.fp48, PRE_first_tail_x15_r0_body.fnord48, PRE_first_tail_x15_r0_body.fi48, PRE_first_tail_x15_r0_body.fii48⟩
theorem PRE_first_tail_x15_r0_body.cnshift48 (clean : Conv.NClean (⟨19160, 16226, 2713123, 2135⟩ : Conv.Cnt) (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s476.ffi).mlx) (hltC : ∀ h, PH (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s476.ffi).mlx h → h < (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s476.ffi).mlx.next) (nltC : ∀ i, PN (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s476.ffi).mlx i → i < (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s476.ffi).mlx.nnext) (itemsC : ∀ k v, (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s476.ffi).mlx.items.get k = some v → PN (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s476.ffi).mlx k) (tracedC : ∀ h o, (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s476.ffi).mlx.objs.get h = some o → ∀ i ∈ objTraces o, i < PRE_first_tail_x15_r0_body.P48.NL) (cl : SSt (· < 2153) PRE_first_tail_x15_r0_body.cx0_48.mlx) : NShift PRE_first_tail_x15_r0_body.P48 2153 PRE_first_tail_x15_r0_body.kappa48 PRE_first_tail_x15_r0_body.cx0_48 PRE_first_tail_x15_r0_body.cx1_48 :=
  Conv.nshift_of_foot (PRE_first_tail_x15_r0_body.cfoot48 clean hltC nltC itemsC tracedC cl) PRE_first_tail_x15_r0_body.chost48 (compact_a_eq PRE_first_tail_x15_r0_body.ckn048 PRE_first_tail_x15_r0_body.ckn148 PRE_first_tail_x15_r0_body.ckheap48 PRE_first_tail_x15_r0_body.ckpl48)

-- the observers: the layers' states at the call, the canonical and the merged state, their footprints and checks
noncomputable def PRE_first_tail_x15_r0_body.fxC_48 : PTrie Unit := (Host.Ts.Sim.Full.freedOf PRE_first_tail_x15_r0_body.s476.ffi).getD PTrie.nil
noncomputable def PRE_first_tail_x15_r0_body.krC_48 : Host.Load.Layers.KRec := (Host.Ts.Sim.Full.krecOf PRE_first_tail_x15_r0_body.s476.ffi).getD Host.Load.Layers.KRec.empty
kernel_rfl PRE_first_tail_x15_r0_body.ofxC_48 : (Host.Ts.Sim.Full.freedOf PRE_first_tail_x15_r0_body.s476.ffi) = some PRE_first_tail_x15_r0_body.fxC_48
kernel_rfl PRE_first_tail_x15_r0_body.okrC_48 : (Host.Ts.Sim.Full.krecOf PRE_first_tail_x15_r0_body.s476.ffi) = some PRE_first_tail_x15_r0_body.krC_48
noncomputable def PRE_first_tail_x15_r0_body.fx0_48 : PTrie Unit := (Host.Ts.Sim.Full.freedOf PRE_first_tail_x15_r0_body.s478.ffi).getD PTrie.nil
noncomputable def PRE_first_tail_x15_r0_body.kr0_48 : Host.Load.Layers.KRec := (Host.Ts.Sim.Full.krecOf PRE_first_tail_x15_r0_body.s478.ffi).getD Host.Load.Layers.KRec.empty
kernel_rfl PRE_first_tail_x15_r0_body.ofx0_48 : (Host.Ts.Sim.Full.freedOf PRE_first_tail_x15_r0_body.s478.ffi) = some PRE_first_tail_x15_r0_body.fx0_48
kernel_rfl PRE_first_tail_x15_r0_body.okr0_48 : (Host.Ts.Sim.Full.krecOf PRE_first_tail_x15_r0_body.s478.ffi) = some PRE_first_tail_x15_r0_body.kr0_48
noncomputable def PRE_first_tail_x15_r0_body.fx1_48 : PTrie Unit := (Host.Ts.Sim.Full.freedOf PRE_first_tail_x15_r0_body.s477.ffi).getD PTrie.nil
noncomputable def PRE_first_tail_x15_r0_body.kr1_48 : Host.Load.Layers.KRec := (Host.Ts.Sim.Full.krecOf PRE_first_tail_x15_r0_body.s477.ffi).getD Host.Load.Layers.KRec.empty
kernel_rfl PRE_first_tail_x15_r0_body.ofx1_48 : (Host.Ts.Sim.Full.freedOf PRE_first_tail_x15_r0_body.s477.ffi) = some PRE_first_tail_x15_r0_body.fx1_48
kernel_rfl PRE_first_tail_x15_r0_body.okr1_48 : (Host.Ts.Sim.Full.krecOf PRE_first_tail_x15_r0_body.s477.ffi) = some PRE_first_tail_x15_r0_body.kr1_48
kernel_rfl PRE_first_tail_x15_r0_body.ff048 : PRE_first_tail_x15_r0_body.fx0_48 = Stage.setAll PRE_first_tail_x15_r0_body.fxC_48 (PRE_first_tail_x15_r0_body.clo48.filterMap fun i => (PRE_first_tail_x15_r0_body.fx0_48.get i).map (i, ·))
kernel_rfl PRE_first_tail_x15_r0_body.ff148 : PRE_first_tail_x15_r0_body.fx1_48 = Stage.setAll PRE_first_tail_x15_r0_body.fxC_48 (PRE_first_tail_x15_r0_body.cwS48.filterMap fun i => (PRE_first_tail_x15_r0_body.fx1_48.get i).map (i, ·))
kernel_rfl PRE_first_tail_x15_r0_body.ffck48 : freedLB PRE_first_tail_x15_r0_body.kappa48 PRE_first_tail_x15_r0_body.cx0_48.mlx PRE_first_tail_x15_r0_body.fx0_48 PRE_first_tail_x15_r0_body.fx1_48 PRE_first_tail_x15_r0_body.clo48 = true
kernel_rfl PRE_first_tail_x15_r0_body.fkf048 : PRE_first_tail_x15_r0_body.kr0_48.flags = Stage.setAll PRE_first_tail_x15_r0_body.krC_48.flags (PRE_first_tail_x15_r0_body.clo48.filterMap fun i => (PRE_first_tail_x15_r0_body.kr0_48.flags.get i).map (i, ·))
kernel_rfl PRE_first_tail_x15_r0_body.fkt048 : PRE_first_tail_x15_r0_body.kr0_48.targs = Stage.setAll PRE_first_tail_x15_r0_body.krC_48.targs (PRE_first_tail_x15_r0_body.clo48.filterMap fun i => (PRE_first_tail_x15_r0_body.kr0_48.targs.get i).map (i, ·))
kernel_rfl PRE_first_tail_x15_r0_body.fkf148 : PRE_first_tail_x15_r0_body.kr1_48.flags = Stage.setAll PRE_first_tail_x15_r0_body.krC_48.flags (PRE_first_tail_x15_r0_body.cwS48.filterMap fun i => (PRE_first_tail_x15_r0_body.kr1_48.flags.get i).map (i, ·))
kernel_rfl PRE_first_tail_x15_r0_body.fkt148 : PRE_first_tail_x15_r0_body.kr1_48.targs = Stage.setAll PRE_first_tail_x15_r0_body.krC_48.targs (PRE_first_tail_x15_r0_body.cwS48.filterMap fun i => (PRE_first_tail_x15_r0_body.kr1_48.targs.get i).map (i, ·))
kernel_rfl PRE_first_tail_x15_r0_body.fkck48 : krecLB PRE_first_tail_x15_r0_body.kappa48 2153 PRE_first_tail_x15_r0_body.cx0_48.mlx PRE_first_tail_x15_r0_body.kr0_48 PRE_first_tail_x15_r0_body.kr1_48 PRE_first_tail_x15_r0_body.clo48 = true
kernel_rfl PRE_first_tail_x15_r0_body.fkn48 : Nat.ble 2135 2153 = true
-- the bridge and the pending traces' regions
kernel_rfl PRE_first_tail_x15_r0_body.cbridge48 : Host.Ts.Sim.Full.bridgeOf PRE_first_tail_x15_r0_body.s477.ffi = Host.Ts.Sim.Full.bridgeOf PRE_first_tail_x15_r0_body.s478.ffi
kernel_rfl PRE_first_tail_x15_r0_body.cpendR48 : pendRegB PRE_first_tail_x15_r0_body.kappa48 (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s478.ffi).mlx = true
kernel_rfl PRE_first_tail_x15_r0_body.cpendLe48 : Nat.ble (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s478.ffi).mlx.next (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s477.ffi).mlx.next = true
/-- **The compaction's native shift**, given the call's bookkeeping, its relation's facts (the model's and the
observers') and the canonical closedness. -/
theorem PRE_first_tail_x15_r0_body.cshift48 (clean : Conv.NClean (⟨19160, 16226, 2713123, 2135⟩ : Conv.Cnt) (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s476.ffi).mlx) (hltC : ∀ h, PH (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s476.ffi).mlx h → h < (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s476.ffi).mlx.next) (nltC : ∀ i, PN (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s476.ffi).mlx i → i < (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s476.ffi).mlx.nnext) (itemsC : ∀ k v, (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s476.ffi).mlx.items.get k = some v → PN (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s476.ffi).mlx k) (tracedC : ∀ h o, (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s476.ffi).mlx.objs.get h = some o → ∀ i ∈ objTraces o, i < PRE_first_tail_x15_r0_body.P48.NL) (cl : SSt (· < 2153) PRE_first_tail_x15_r0_body.cx0_48.mlx)
    (hobjC : ∀ h, PRE_first_tail_x15_r0_body.fxC_48.get h = some () → ((Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s476.ffi).mlx.objs.get h).isSome = true)
    (hfC : ∀ h, (PRE_first_tail_x15_r0_body.krC_48.flags.get h).isSome = true → ((Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s476.ffi).mlx.objs.get h).isSome = true)
    (htC : ∀ h, (PRE_first_tail_x15_r0_body.krC_48.targs.get h).isSome = true → ((Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s476.ffi).mlx.objs.get h).isSome = true)
    (hclC : ∀ h l, PRE_first_tail_x15_r0_body.krC_48.targs.get h = some l → Host.Ts.Sim.Full.STargs (· < (⟨19160, 16226, 2713123, 2135⟩ : Conv.Cnt).n) l) :
    Conv.FullShiftQ PRE_first_tail_x15_r0_body.P48 2153 PRE_first_tail_x15_r0_body.kappa48 PRE_first_tail_x15_r0_body.s478.ffi PRE_first_tail_x15_r0_body.s477.ffi :=
  ⟨PRE_first_tail_x15_r0_body.cnshift48 clean hltC nltC itemsC tracedC cl, PRE_first_tail_x15_r0_body.cqueue48, fun t ht => bSN_sound (List.all_eq_true.mp PRE_first_tail_x15_r0_body.ctokSupp48 t ht),
    PRE_first_tail_x15_r0_body.cbridge48,
    liveShift_foot (x0' := Host.Ts.Sim.Full.mlxOf PRE_first_tail_x15_r0_body.s478.ffi) (x1' := Host.Ts.Sim.Full.mlxOf PRE_first_tail_x15_r0_body.s477.ffi) (PRE_first_tail_x15_r0_body.cfoot48 clean hltC nltC itemsC tracedC cl) rfl PRE_first_tail_x15_r0_body.ofx0_48 PRE_first_tail_x15_r0_body.ofx1_48 hobjC PRE_first_tail_x15_r0_body.ff048 PRE_first_tail_x15_r0_body.ff148 PRE_first_tail_x15_r0_body.ffck48,
    kernShift_foot (x0' := Host.Ts.Sim.Full.mlxOf PRE_first_tail_x15_r0_body.s478.ffi) (x1' := Host.Ts.Sim.Full.mlxOf PRE_first_tail_x15_r0_body.s477.ffi) (PRE_first_tail_x15_r0_body.cfoot48 clean hltC nltC itemsC tracedC cl) rfl PRE_first_tail_x15_r0_body.okr0_48 PRE_first_tail_x15_r0_body.okr1_48 (Nat.le_of_ble_eq_true PRE_first_tail_x15_r0_body.fkn48) hfC htC hclC
      PRE_first_tail_x15_r0_body.fkf048 PRE_first_tail_x15_r0_body.fkt048 PRE_first_tail_x15_r0_body.fkf148 PRE_first_tail_x15_r0_body.fkt148 PRE_first_tail_x15_r0_body.fkck48,
    pendReg_of rfl PRE_first_tail_x15_r0_body.cnh048 PRE_first_tail_x15_r0_body.cnh148 (Nat.le_of_ble_eq_true PRE_first_tail_x15_r0_body.cpendLe48) PRE_first_tail_x15_r0_body.cpendR48⟩

end Host.Load.Run.Tpl
end

section -- st48/H0
set_option Elab.async false
namespace Host.Load.Run.Tpl
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
host_stream_state PRE_first_tail_x15_r0_body.st48 0
host_stream_state PRE_first_tail_x15_r0_body.st48 1
host_stream_state PRE_first_tail_x15_r0_body.st48 2
host_stream_state PRE_first_tail_x15_r0_body.st48 3
host_stream_state PRE_first_tail_x15_r0_body.st48 4
host_stream_state PRE_first_tail_x15_r0_body.st48 5
end Host.Load.Run.Tpl
end

section -- Site48
set_option Elab.async false
namespace Host.Load.Run.Tpl
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
open Host.Ts Host.Ts.Sim Host.Ts.Sim.Template

/-! Call site 48 of chain `PRE_first_tail_x15_r0_body`: `ssmW__g48__g49` (`recurWindow`), the call state `PRE_first_tail_x15_r0_body.s476`, the merged state `PRE_first_tail_x15_r0_body.s477`,
the site template `PRE_first_tail_x15_r0_body.st48` (σ = `Map.id`, θ the identity at its own site), the canonical state `PRE_first_tail_x15_r0_body.s478`: the merge.
The footprint's facts are in `SiteF48`, the compaction's in `SiteC48`, `SiteK48`, `SiteNa48`, `SiteNb48`. -/

kernel_rfl PRE_first_tail_x15_r0_body.iso48 : PRE_first_tail_x15_r0_body.st48.s0 = { PRE_first_tail_x15_r0_body.s476 with stack := [] }
/-- The caller's frames at the call. -/
noncomputable def PRE_first_tail_x15_r0_body.rs48 : List Frame := PRE_first_tail_x15_r0_body.s476.stack
kernel_rfl PRE_first_tail_x15_r0_body.n0_48 : PRE_first_tail_x15_r0_body.S476.tab.length = 2135
kernel_rfl PRE_first_tail_x15_r0_body.tab0_48 : PRE_first_tail_x15_r0_body.st48.S0.tab = PRE_first_tail_x15_r0_body.S476.tab

/-- The fresh variables of the stage's results. -/
def PRE_first_tail_x15_r0_body.ws48 : List Nat := [1796, 1797, 1798, 1799, 1800, 1801, 1802, 1803, 1804, 1805, 1806, 1807, 1808, 1809, 1810, 1811, 1812, 1813, 1814, 1815, 1816, 1817, 1818, 1819, 1820, 1821, 1822, 1823, 1824, 1825, 1826]
kernel_rfl PRE_first_tail_x15_r0_body.fresh48 : (PRE_first_tail_x15_r0_body.S476.tab.all fun e => PRE_first_tail_x15_r0_body.ws48.all fun v => e.noVar v) &&
    (PRE_first_tail_x15_r0_body.S476.oracle.all fun q => PRE_first_tail_x15_r0_body.ws48.all fun v => q.noVar v) = true
kernel_rfl PRE_first_tail_x15_r0_body.mergeTab48 : PRE_first_tail_x15_r0_body.S477.tab = PRE_first_tail_x15_r0_body.S476.tab ++ Conv.resTab PRE_first_tail_x15_r0_body.ws48
kernel_rfl PRE_first_tail_x15_r0_body.mergeLen48 : PRE_first_tail_x15_r0_body.st48.S5.tab.length - PRE_first_tail_x15_r0_body.st48.S0.tab.length = 31

-- The merged state: the instance's return state with the caller's frames (`PRE_first_tail_x15_r0_body.merged48`, `merged_relB`).
kernel_rfl PRE_first_tail_x15_r0_body.mheap48 : PRE_first_tail_x15_r0_body.s477.heap = PRE_first_tail_x15_r0_body.st48.s5.heap
kernel_rfl PRE_first_tail_x15_r0_body.mnext48 : PRE_first_tail_x15_r0_body.s477.next = PRE_first_tail_x15_r0_body.st48.s5.next
kernel_rfl PRE_first_tail_x15_r0_body.mctl48 : PRE_first_tail_x15_r0_body.s477.ctl = PRE_first_tail_x15_r0_body.st48.s5.ctl
kernel_rfl PRE_first_tail_x15_r0_body.mstack48 : PRE_first_tail_x15_r0_body.s477.stack = PRE_first_tail_x15_r0_body.st48.s5.stack ++ PRE_first_tail_x15_r0_body.s476.stack
kernel_rfl PRE_first_tail_x15_r0_body.mjobs48 : PRE_first_tail_x15_r0_body.s477.jobs = PRE_first_tail_x15_r0_body.st48.s5.jobs
kernel_rfl PRE_first_tail_x15_r0_body.mffi48 : PRE_first_tail_x15_r0_body.s477.ffi = PRE_first_tail_x15_r0_body.st48.s5.ffi
kernel_rfl PRE_first_tail_x15_r0_body.mtrace48 : PRE_first_tail_x15_r0_body.s477.trace = PRE_first_tail_x15_r0_body.st48.s5.trace
kernel_rfl PRE_first_tail_x15_r0_body.mstores48 : PRE_first_tail_x15_r0_body.s477.stores = PRE_first_tail_x15_r0_body.st48.s5.stores

end Host.Load.Run.Tpl
end

section -- SiteD48
set_option Elab.async false
namespace Host.Load.Run.Tpl
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
open Host.Ts Host.Ts.Sim Host.Ts.Sim.Template

/-! The canonical results at call site 48 of chain `PRE_first_tail_x15_r0_body`: their values in the instance's end table, the references past
the call's table, the canonical variables apart from the stage's. -/

kernel_rfl PRE_first_tail_x15_r0_body.cderived48 : PRE_first_tail_x15_r0_body.nr48.map (fun r => nth? PRE_first_tail_x15_r0_body.st48.S5.tab r) =
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
kernel_rfl PRE_first_tail_x15_r0_body.cnrLo48 : PRE_first_tail_x15_r0_body.nr48.all (Nat.ble 2135) = true
kernel_rfl PRE_first_tail_x15_r0_body.cwsDisj48 : PRE_first_tail_x15_r0_body.cws48.all (fun c => !PRE_first_tail_x15_r0_body.ws48.contains c) = true
/-- The compaction's substitution: the canonical variables to their merged values, the stage's other fresh variables
to `0` (`Conv.compactθZ`). -/
noncomputable def PRE_first_tail_x15_r0_body.cthetaZ48 : Nat → SymE := Conv.compactθZ PRE_first_tail_x15_r0_body.cws48 PRE_first_tail_x15_r0_body.crs48 PRE_first_tail_x15_r0_body.ws48

end Host.Load.Run.Tpl
end

section -- st48/Foot
set_option Elab.async false
namespace Host.Load.Run.Tpl
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
open Host.Ts Host.Ts.Sim Host.Ts.Sim.Stage Host.Ts.Sim.Template

/-! The footprint of stage `PRE_first_tail_x15_r0_body.st48`'s site template (`Conv.StageFoot`, `Conv.NFoot`): every entry of the return
state other than the written and fresh ones is the start's (kernel evaluation of the equalities). -/

/-- The written heap ranges below the start's counter. -/
def PRE_first_tail_x15_r0_body.st48.wrR : List (Nat × Nat) := [(2672424, 2672425), (2712297, 2712298), (2712842, 2712843), (2713098, 2713099)]
/-- The written and fresh entries of the return state. -/
noncomputable def PRE_first_tail_x15_r0_body.st48.wrE : List (Nat × Host.Ts.HObj) :=
  rangesOf PRE_first_tail_x15_r0_body.st48.s5.heap PRE_first_tail_x15_r0_body.st48.wrR ++ freshOf PRE_first_tail_x15_r0_body.st48.s5.heap PRE_first_tail_x15_r0_body.st48.s0.next PRE_first_tail_x15_r0_body.st48.s5.next
noncomputable def PRE_first_tail_x15_r0_body.st48.wr : List Nat := PRE_first_tail_x15_r0_body.st48.wrE.map (·.1)

kernel_rfl PRE_first_tail_x15_r0_body.st48.heapFoot : PRE_first_tail_x15_r0_body.st48.s5.heap = setAll PRE_first_tail_x15_r0_body.st48.s0.heap PRE_first_tail_x15_r0_body.st48.wrE
kernel_rfl PRE_first_tail_x15_r0_body.st48.grows_check : Nat.ble PRE_first_tail_x15_r0_body.st48.s0.next PRE_first_tail_x15_r0_body.st48.s5.next = true
theorem PRE_first_tail_x15_r0_body.st48.grows : PRE_first_tail_x15_r0_body.st48.s0.next ≤ PRE_first_tail_x15_r0_body.st48.s5.next := Nat.le_of_ble_eq_true PRE_first_tail_x15_r0_body.st48.grows_check

/-- The written and fresh handles; the written readback items of old nodes. -/
def PRE_first_tail_x15_r0_body.st48.wh : List Nat := [19140, 19153, 19159, 19160, 19161, 19162, 19163, 19164, 19165, 19166, 19167, 19168, 19169, 19170, 19171, 19172, 19173, 19174, 19175, 19176, 19177, 19178, 19179, 19180, 19181, 19182, 19183, 19184, 19185, 19186, 19187]
def PRE_first_tail_x15_r0_body.st48.wi : List Nat := []

kernel_rfl PRE_first_tail_x15_r0_body.st48.arrsFoot : (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.st48.s5.ffi).mlx.arrs = setAll (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.st48.s0.ffi).mlx.arrs (PRE_first_tail_x15_r0_body.st48.wh.filterMap fun h => ((Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.st48.s5.ffi).mlx.arrs.get h).map (h, ·))
kernel_rfl PRE_first_tail_x15_r0_body.st48.objsFoot : (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.st48.s5.ffi).mlx.objs = setAll (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.st48.s0.ffi).mlx.objs (PRE_first_tail_x15_r0_body.st48.wh.filterMap fun h => ((Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.st48.s5.ffi).mlx.objs.get h).map (h, ·))
kernel_rfl PRE_first_tail_x15_r0_body.st48.nodesFoot : (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.st48.s5.ffi).mlx.nodes = setAll (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.st48.s0.ffi).mlx.nodes (freshOf (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.st48.s5.ffi).mlx.nodes (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.st48.s0.ffi).mlx.nnext (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.st48.s5.ffi).mlx.nnext)
kernel_rfl PRE_first_tail_x15_r0_body.st48.itemsFoot : (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.st48.s5.ffi).mlx.items = setAll (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.st48.s0.ffi).mlx.items ((PRE_first_tail_x15_r0_body.st48.wi.filterMap fun i => ((Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.st48.s5.ffi).mlx.items.get i).map (i, ·)) ++
    freshOf (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.st48.s5.ffi).mlx.items (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.st48.s0.ffi).mlx.nnext (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.st48.s5.ffi).mlx.nnext)
kernel_rfl PRE_first_tail_x15_r0_body.st48.counters : (Nat.ble (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.st48.s0.ffi).mlx.next (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.st48.s5.ffi).mlx.next && Nat.ble (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.st48.s0.ffi).mlx.nnext (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.st48.s5.ffi).mlx.nnext) = true

end Host.Load.Run.Tpl
end

section -- SiteF48
set_option Elab.async false
namespace Host.Load.Run.Tpl
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
open Host.Ts Host.Ts.Sim Host.Ts.Sim.Template

/-! Call site 48 of chain `PRE_first_tail_x15_r0_body`: `Conv.site_merge`'s footprint facts. -/

kernel_rfl PRE_first_tail_x15_r0_body.wrNodupB48 : nodupT PRE_first_tail_x15_r0_body.st48.wr PTrie.nil = true
theorem PRE_first_tail_x15_r0_body.wrNodup48 : PRE_first_tail_x15_r0_body.st48.wr.Nodup := (nodupT_sound PRE_first_tail_x15_r0_body.wrNodupB48).2
kernel_rfl PRE_first_tail_x15_r0_body.wrBoundB48 : PRE_first_tail_x15_r0_body.st48.wr.all (fun b => Nat.blt (b / 4096) (4 ^ 31)) = true
theorem PRE_first_tail_x15_r0_body.wrBound48 : ∀ b ∈ PRE_first_tail_x15_r0_body.st48.wr, b / 4096 < 4 ^ 31 := fun b hb => Nat.blt_eq.mp (List.all_eq_true.mp PRE_first_tail_x15_r0_body.wrBoundB48 b hb)
noncomputable def PRE_first_tail_x15_r0_body.trFr48 := PRE_first_tail_x15_r0_body.st48.s5.trace.take 120
kernel_rfl PRE_first_tail_x15_r0_body.traceEq48 : PRE_first_tail_x15_r0_body.st48.s5.trace = PRE_first_tail_x15_r0_body.trFr48 ++ PRE_first_tail_x15_r0_body.st48.s0.trace
theorem PRE_first_tail_x15_r0_body.trace48 : ∃ fr, PRE_first_tail_x15_r0_body.st48.s5.trace = fr ++ PRE_first_tail_x15_r0_body.st48.s0.trace := ⟨_, PRE_first_tail_x15_r0_body.traceEq48⟩

-- the caller's wide frames at the instance's start (`Conv.isolateW`'s `W0` under `Map.id`) and their `WFix`
def PRE_first_tail_x15_r0_body.wide48 : List (Nat × WFrame) := [(4910, .memo [])]
kernel_rfl PRE_first_tail_x15_r0_body.wfixB48 : (PRE_first_tail_x15_r0_body.wide48.all fun p => wfixB Map.id (presentB PRE_first_tail_x15_r0_body.st48.s0) p.2) = true
theorem PRE_first_tail_x15_r0_body.wfix48 : ∀ p ∈ PRE_first_tail_x15_r0_body.wide48, WFix Map.id (Present PRE_first_tail_x15_r0_body.st48.s0) p.2 :=
  fun p hp => wfix_of (List.all_eq_true.mp PRE_first_tail_x15_r0_body.wfixB48 p hp)

end Host.Load.Run.Tpl
end

section -- SiteL48
set_option Elab.async false
namespace Host.Load.Run.Tpl
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
open Host.Ts Host.Ts.Sim Host.Ts.Sim.Template

/-! The call link's facts at call site 48 of chain `PRE_first_tail_x15_r0_body`: the instance's start server, its footprint (`Conv.StageFoot`), the
merged state `PRE_first_tail_x15_r0_body.s477`'s framed arrays as the chain start's extended (`arrExt_of`, `numRefs_of`). -/

kernel_rfl PRE_first_tail_x15_r0_body.srvO48 : PRE_first_tail_x15_r0_body.st48.S0.oracle = PRE_first_tail_x15_r0_body.st48.OR
kernel_rfl PRE_first_tail_x15_r0_body.wr0B48 : PRE_first_tail_x15_r0_body.st48.wr.all (fun b => !Nat.blt b PRE_first_tail_x15_r0_body.st48.s0.next || (PRE_first_tail_x15_r0_body.st48.s0.heap.get b).isSome) = true
theorem PRE_first_tail_x15_r0_body.stFoot48 : Conv.StageFoot PRE_first_tail_x15_r0_body.st48.wr PRE_first_tail_x15_r0_body.st48.s0 PRE_first_tail_x15_r0_body.st48.s5 :=
  stageFoot_of PRE_first_tail_x15_r0_body.st48.heapFoot PRE_first_tail_x15_r0_body.wrNodup48 PRE_first_tail_x15_r0_body.wrBound48 PRE_first_tail_x15_r0_body.wr0B48 PRE_first_tail_x15_r0_body.st48.grows

/-- **The relation at the merged state** from the relation at the merge (`Conv.site_merge`'s; `merged_relB`). -/
theorem PRE_first_tail_x15_r0_body.merged48 {FR : Map → Nat → PRE_first_tail_x15_r0_body.st48.F.S → PRE_first_tail_x15_r0_body.st48.F.S → Prop} {W : Nat → Option WFrame} {stk : List Frame} {M : Map}
    {ν : Nat → F64} {K : Host.Ts.Sim.Ctx} {S : SSrv} {t : St PRE_first_tail_x15_r0_body.st48.F.S} {C : CSrv} {n0 : Nat}
    (h : RelB PRE_first_tail_x15_r0_body.st48.F FR W stk M ν K (Conv.mergeSt Map.id (Map.id.res n0 n0) PRE_first_tail_x15_r0_body.rs48 PRE_first_tail_x15_r0_body.st48.wr PRE_first_tail_x15_r0_body.s476 PRE_first_tail_x15_r0_body.st48.s5 PRE_first_tail_x15_r0_body.st48.s0
      PRE_first_tail_x15_r0_body.st48.s5.ffi) S t C) : RelB PRE_first_tail_x15_r0_body.st48.F FR W stk M ν K PRE_first_tail_x15_r0_body.s477 S t C :=
  merged_relB PRE_first_tail_x15_r0_body.iso48 PRE_first_tail_x15_r0_body.stFoot48 PRE_first_tail_x15_r0_body.wrNodup48 PRE_first_tail_x15_r0_body.wrBound48 PRE_first_tail_x15_r0_body.trace48 PRE_first_tail_x15_r0_body.mheap48
    PRE_first_tail_x15_r0_body.mnext48 PRE_first_tail_x15_r0_body.mctl48 PRE_first_tail_x15_r0_body.mstack48 PRE_first_tail_x15_r0_body.mjobs48 PRE_first_tail_x15_r0_body.mffi48 PRE_first_tail_x15_r0_body.mtrace48 PRE_first_tail_x15_r0_body.mstores48 h

def PRE_first_tail_x15_r0_body.arrEl48_2665 : List Val := []
kernel_rfl PRE_first_tail_x15_r0_body.arrE48_2665 : arrOf PRE_first_tail_x15_r0_body.s477 2665 = arrOf PRE_first_tail_x15_r0_body.s0 2665 ++ PRE_first_tail_x15_r0_body.arrEl48_2665
kernel_rfl PRE_first_tail_x15_r0_body.arrA48_2665 : isArrB PRE_first_tail_x15_r0_body.s477 2665 = true
theorem PRE_first_tail_x15_r0_body.arr48_2665 : ∃ o, PRE_first_tail_x15_r0_body.s477.heap.get 2665 = some (.obj o) ∧ o.kind = .array (arrOf PRE_first_tail_x15_r0_body.s0 2665 ++ PRE_first_tail_x15_r0_body.arrEl48_2665) :=
  arrExt_of PRE_first_tail_x15_r0_body.arrE48_2665 PRE_first_tail_x15_r0_body.arrA48_2665
kernel_rfl PRE_first_tail_x15_r0_body.arrN48_2665 : numRefsB PRE_first_tail_x15_r0_body.S0.tab.length PRE_first_tail_x15_r0_body.arrEl48_2665 = true
theorem PRE_first_tail_x15_r0_body.arrR48_2665 : Prefill.NumRefs PRE_first_tail_x15_r0_body.S0.tab.length PRE_first_tail_x15_r0_body.arrEl48_2665 := numRefs_of PRE_first_tail_x15_r0_body.arrN48_2665

def PRE_first_tail_x15_r0_body.arrEl48_2673467 : List Val := []
kernel_rfl PRE_first_tail_x15_r0_body.arrE48_2673467 : arrOf PRE_first_tail_x15_r0_body.s477 2673467 = arrOf PRE_first_tail_x15_r0_body.s0 2673467 ++ PRE_first_tail_x15_r0_body.arrEl48_2673467
kernel_rfl PRE_first_tail_x15_r0_body.arrA48_2673467 : isArrB PRE_first_tail_x15_r0_body.s477 2673467 = true
theorem PRE_first_tail_x15_r0_body.arr48_2673467 : ∃ o, PRE_first_tail_x15_r0_body.s477.heap.get 2673467 = some (.obj o) ∧ o.kind = .array (arrOf PRE_first_tail_x15_r0_body.s0 2673467 ++ PRE_first_tail_x15_r0_body.arrEl48_2673467) :=
  arrExt_of PRE_first_tail_x15_r0_body.arrE48_2673467 PRE_first_tail_x15_r0_body.arrA48_2673467
kernel_rfl PRE_first_tail_x15_r0_body.arrN48_2673467 : numRefsB PRE_first_tail_x15_r0_body.S0.tab.length PRE_first_tail_x15_r0_body.arrEl48_2673467 = true
theorem PRE_first_tail_x15_r0_body.arrR48_2673467 : Prefill.NumRefs PRE_first_tail_x15_r0_body.S0.tab.length PRE_first_tail_x15_r0_body.arrEl48_2673467 := numRefs_of PRE_first_tail_x15_r0_body.arrN48_2673467

kernel_rfl PRE_first_tail_x15_r0_body.w4910k48 : isArrB PRE_first_tail_x15_r0_body.s477 4910 = false
theorem PRE_first_tail_x15_r0_body.keep48 (q : List Val) : Host.Ts.Sim.Prefill.KeepsAtW (framesP PRE_first_tail_x15_r0_body.s0 q) PRE_first_tail_x15_r0_body.s477 := by
  intro a pre pre' hx o es ho hk
  unfold framesP at hx
  simp only at hx
  cases h1 : Nat.beq a 2665
  · cases h2 : Nat.beq a 4910
    · rw [h1, h2] at hx; cases hx
    · have := Nat.eq_of_beq_eq_true h2; subst this
      rw [h1, h2] at hx; cases hx
      exact (notArr_of PRE_first_tail_x15_r0_body.w4910k48 ho hk).elim
  · have := Nat.eq_of_beq_eq_true h1; subst this
    rw [h1] at hx; cases hx
    obtain ⟨o', ho', hk'⟩ := PRE_first_tail_x15_r0_body.arr48_2665
    rw [ho] at ho'; cases ho'
    rw [hk'] at hk; cases hk
    simp [PRE_first_tail_x15_r0_body.arrEl48_2665]

end Host.Load.Run.Tpl
end

section -- SiteZ48
set_option Elab.async false
namespace Host.Load.Run.Tpl
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
open Host.Ts Host.Ts.Sim Host.Ts.Sim.Template

/-! The compaction's state shift at call site 48 of chain `PRE_first_tail_x15_r0_body` (`Conv.compact_shift`): the call `PRE_first_tail_x15_r0_body.s476`, the merged
state `PRE_first_tail_x15_r0_body.s477`, the canonical state `PRE_first_tail_x15_r0_body.s478`; its frames [2665,2673467,2673472,2673473] (kept arrays [2665,2673467]). -/

-- the map's places and counters
kernel_rfl PRE_first_tail_x15_r0_body.zpl48 : PRE_first_tail_x15_r0_body.pl48.all (Nat.ble PRE_first_tail_x15_r0_body.s476.next) = true
kernel_rfl PRE_first_tail_x15_r0_body.zplnd48 : nodupT PRE_first_tail_x15_r0_body.pl48 PTrie.nil = true
kernel_rfl PRE_first_tail_x15_r0_body.zn148 : Nat.ble PRE_first_tail_x15_r0_body.s476.next 2714278 = true
kernel_rfl PRE_first_tail_x15_r0_body.zfirst48 : Nat.ble aFirst PRE_first_tail_x15_r0_body.s476.next = true
kernel_rfl PRE_first_tail_x15_r0_body.zscn48 : PRE_first_tail_x15_r0_body.s478.next = PRE_first_tail_x15_r0_body.s476.next + PRE_first_tail_x15_r0_body.pl48.length
kernel_rfl PRE_first_tail_x15_r0_body.zsmn48 : PRE_first_tail_x15_r0_body.s477.next = 2714278
kernel_rfl PRE_first_tail_x15_r0_body.zgrow48 : Nat.ble PRE_first_tail_x15_r0_body.s478.next PRE_first_tail_x15_r0_body.s477.next = true
-- the tables
kernel_rfl PRE_first_tail_x15_r0_body.zfresh48 : PRE_first_tail_x15_r0_body.S476.tab.all (fun e => PRE_first_tail_x15_r0_body.cws48.all fun v => e.noVar v) = true
kernel_rfl PRE_first_tail_x15_r0_body.zcnd48 : nodupT PRE_first_tail_x15_r0_body.cws48 PTrie.nil = true
kernel_rfl PRE_first_tail_x15_r0_body.znrHi48 : PRE_first_tail_x15_r0_body.nr48.all (fun r => Nat.blt r PRE_first_tail_x15_r0_body.S477.tab.length) = true
-- the frames: every framed address below the call's counter; the kept arrays the chain start's, extended in the merged state
kernel_rfl PRE_first_tail_x15_r0_body.zfrlt48 : [2665, 2673467, 2673472, 2673473].all (fun a => Nat.blt a PRE_first_tail_x15_r0_body.s476.next) = true
kernel_rfl PRE_first_tail_x15_r0_body.zg48_2665 : PRE_first_tail_x15_r0_body.s478.heap.get 2665 = some (.obj (objOf PRE_first_tail_x15_r0_body.s478 2665))
kernel_rfl PRE_first_tail_x15_r0_body.zk48_2665 : (objOf PRE_first_tail_x15_r0_body.s478 2665).kind = .array (arrOf PRE_first_tail_x15_r0_body.s0 2665)
kernel_rfl PRE_first_tail_x15_r0_body.zm48_2665 : PRE_first_tail_x15_r0_body.s477.heap.get 2665 = some (.obj { PRE_first_tail_x15_r0_body.kappa48.obj (objOf PRE_first_tail_x15_r0_body.s478 2665) with
  kind := .array (arrOf PRE_first_tail_x15_r0_body.s0 2665 ++ (arrOf PRE_first_tail_x15_r0_body.s477 2665).drop (arrOf PRE_first_tail_x15_r0_body.s0 2665).length) })
kernel_rfl PRE_first_tail_x15_r0_body.zg48_2673467 : PRE_first_tail_x15_r0_body.s478.heap.get 2673467 = some (.obj (objOf PRE_first_tail_x15_r0_body.s478 2673467))
kernel_rfl PRE_first_tail_x15_r0_body.zk48_2673467 : (objOf PRE_first_tail_x15_r0_body.s478 2673467).kind = .array (arrOf PRE_first_tail_x15_r0_body.s0 2673467)
kernel_rfl PRE_first_tail_x15_r0_body.zm48_2673467 : PRE_first_tail_x15_r0_body.s477.heap.get 2673467 = some (.obj { PRE_first_tail_x15_r0_body.kappa48.obj (objOf PRE_first_tail_x15_r0_body.s478 2673467) with
  kind := .array (arrOf PRE_first_tail_x15_r0_body.s0 2673467 ++ (arrOf PRE_first_tail_x15_r0_body.s477 2673467).drop (arrOf PRE_first_tail_x15_r0_body.s0 2673467).length) })
kernel_rfl PRE_first_tail_x15_r0_body.zw48_4910 : (PRE_first_tail_x15_r0_body.s478.heap.get 4910).isSome = true
kernel_rfl PRE_first_tail_x15_r0_body.zw48_2673472 : (PRE_first_tail_x15_r0_body.s478.heap.get 2673472).isSome = true
kernel_rfl PRE_first_tail_x15_r0_body.zw48_2673473 : (PRE_first_tail_x15_r0_body.s478.heap.get 2673473).isSome = true
-- the heap: the changed list in range, holding the stage's written and fresh addresses; the canonical side's image
kernel_rfl PRE_first_tail_x15_r0_body.zclbd48 : PRE_first_tail_x15_r0_body.cl48.all (fun b => Nat.blt (b / 4096) (4 ^ 31)) = true
kernel_rfl PRE_first_tail_x15_r0_body.zwr48 : PRE_first_tail_x15_r0_body.st48.wr.all (fun b => !Nat.blt b PRE_first_tail_x15_r0_body.s476.next || PRE_first_tail_x15_r0_body.cl48.contains b) = true
def PRE_first_tail_x15_r0_body.zl48 : List Nat := PRE_first_tail_x15_r0_body.cl48.filter fun a => !(List.contains [2665, 2673467] a)
kernel_rfl PRE_first_tail_x15_r0_body.zimgE48 : PRE_first_tail_x15_r0_body.zl48.map (fun a => PRE_first_tail_x15_r0_body.s477.heap.get (PRE_first_tail_x15_r0_body.kappa48.a a)) = PRE_first_tail_x15_r0_body.zl48.map (fun a => (PRE_first_tail_x15_r0_body.s478.heap.get a).map PRE_first_tail_x15_r0_body.kappa48.hobj)
theorem PRE_first_tail_x15_r0_body.zimg48 : HeapImg PRE_first_tail_x15_r0_body.kappa48 PRE_first_tail_x15_r0_body.s478 PRE_first_tail_x15_r0_body.s477 PRE_first_tail_x15_r0_body.zl48 := PRE_first_tail_x15_r0_body.zimgE48
-- the roots and their supports
kernel_rfl PRE_first_tail_x15_r0_body.zctl48 : PRE_first_tail_x15_r0_body.s477.ctl = PRE_first_tail_x15_r0_body.kappa48.ctl PRE_first_tail_x15_r0_body.s478.ctl
kernel_rfl PRE_first_tail_x15_r0_body.zstack48 : PRE_first_tail_x15_r0_body.s477.stack = PRE_first_tail_x15_r0_body.s478.stack.map PRE_first_tail_x15_r0_body.kappa48.frame
kernel_rfl PRE_first_tail_x15_r0_body.zjobs48 : PRE_first_tail_x15_r0_body.s477.jobs = PRE_first_tail_x15_r0_body.s478.jobs.map PRE_first_tail_x15_r0_body.kappa48.job
kernel_rfl PRE_first_tail_x15_r0_body.zstores48 : PRE_first_tail_x15_r0_body.s477.stores = PRE_first_tail_x15_r0_body.kappa48.stores PRE_first_tail_x15_r0_body.s478.stores
kernel_rfl PRE_first_tail_x15_r0_body.zroots48 : checkRootsSupp PRE_first_tail_x15_r0_body.s478 2153 = true
kernel_rfl PRE_first_tail_x15_r0_body.znC48 : PRE_first_tail_x15_r0_body.S476.tab.length + PRE_first_tail_x15_r0_body.cws48.length = 2153
-- the map as `Conv.compact_shift` states it (the call's counters for the literals)
kernel_rfl PRE_first_tail_x15_r0_body.zkap48 : PRE_first_tail_x15_r0_body.kappa48 = Conv.Map.compact PRE_first_tail_x15_r0_body.s476.next 2714278 PRE_first_tail_x15_r0_body.S476.tab.length PRE_first_tail_x15_r0_body.pl48 (PRE_first_tail_x15_r0_body.nr48.map NumV.ref) PRE_first_tail_x15_r0_body.kd48.big
  PRE_first_tail_x15_r0_body.kd48.region PRE_first_tail_x15_r0_body.kd48.nodeF
-- the bridge inactive at the canonical state (`Conv.FullShiftQ.toX`; the merged state's bridge is the canonical's: cbridge)
theorem PRE_first_tail_x15_r0_body.zbin48 : (Host.Ts.Sim.Full.bridgeOf PRE_first_tail_x15_r0_body.s478.ffi).active = false := (Host.Load.Boot.replay_active Host.Load.Run.Prompt.P.oblog2818)
-- the JS bookkeeping's step (`Conv.JClean.step` over the changed list) and the canonical roots' bigint freedom
kernel_rfl PRE_first_tail_x15_r0_body.zjc48 : Conv.jcleanListB (⟨19163, 16253, 2713129, 2153⟩ : Conv.Cnt) PRE_first_tail_x15_r0_body.s478 PRE_first_tail_x15_r0_body.cl48 = true
kernel_rfl PRE_first_tail_x15_r0_body.zrootsB48 : noBigRootsP (fun i => !Conv.oldBigB (⟨19163, 16253, 2713129, 2153⟩ : Conv.Cnt) i) PRE_first_tail_x15_r0_body.s478.trace PRE_first_tail_x15_r0_body.s478 = true
kernel_rfl PRE_first_tail_x15_r0_body.zhm48 : Nat.ble (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s0.ffi).mlx.nnext 16226 = true
theorem PRE_first_tail_x15_r0_body.cjcl48 (h : Conv.JClean (⟨19160, 16226, 2713123, 2135⟩ : Conv.Cnt) PRE_first_tail_x15_r0_body.s476) : Conv.JClean (⟨19163, 16253, 2713129, 2153⟩ : Conv.Cnt) PRE_first_tail_x15_r0_body.s478 :=
  Conv.JClean.step h (Conv.Cnt.le_of_leB PRE_first_tail_x15_r0_body.cle48)
    (Conv.heap_off_setAll PRE_first_tail_x15_r0_body.cheap48 fun a ha => Nat.blt_eq.mp (List.all_eq_true.mp PRE_first_tail_x15_r0_body.zclbd48 a ha)) PRE_first_tail_x15_r0_body.zjc48

end Host.Load.Run.Tpl
end

section -- st48/TypedLast
set_option Elab.async false
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
namespace Host.Load.Run.Tpl
open Host.Ts Host.Ts.Sim Host.Ts.Sim.Template

boot_rfl PRE_first_tail_x15_r0_body.st48.bodyLast from PRE_first_tail_x15_r0_body.st48.s4 to PRE_first_tail_x15_r0_body.st48.s5 :
  interpS (step PRE_first_tail_x15_r0_body.st48.F PRE_first_tail_x15_r0_body.st48.s4).run PRE_first_tail_x15_r0_body.st48.S4 = some (PRE_first_tail_x15_r0_body.st48.s5, PRE_first_tail_x15_r0_body.st48.S5)
kernel_rfl PRE_first_tail_x15_r0_body.st48.bodyHalt : isHalt PRE_first_tail_x15_r0_body.st48.s4.ctl = false
kernel_rfl PRE_first_tail_x15_r0_body.st48.bodyTopCheck : noBlockTop PRE_first_tail_x15_r0_body.st48.s5.stack = true

end Host.Load.Run.Tpl
end

section -- st48/TypedOk
set_option Elab.async false
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
namespace Host.Load.Run.Tpl
open Host.Ts Host.Ts.Sim Host.Ts.Sim.Template

noncomputable def PRE_first_tail_x15_r0_body.st48.bodyOkL (bytes : List Byte) (rows : Nat) : St PRE_first_tail_x15_r0_body.st48.F.S → SSrv → Bool :=
  okLocal (Host.Ts.Sim.Compose.VWFrames.bodyOk bytes rows)

noncomputable def PRE_first_tail_x15_r0_body.st48.bodyOkLN (bytes : List Byte) (rows : Nat) : St PRE_first_tail_x15_r0_body.st48.F.S → FSrv → Bool :=
  okLocalN (Host.Ts.Sim.Compose.VWFrames.bodyOkN bytes rows)

theorem PRE_first_tail_x15_r0_body.st48.bodyOkLN_ok (bytes : List Byte) (rows : Nat) (s : St PRE_first_tail_x15_r0_body.st48.F.S) (c : FSrv) (h : c.Wf) :
    PRE_first_tail_x15_r0_body.st48.bodyOkLN bytes rows s c = PRE_first_tail_x15_r0_body.st48.bodyOkL bytes rows s c.toS :=
  okLocalN_ok (Host.Ts.Sim.Compose.VWFrames.bodyOkN_ok bytes rows) s c h

kernel_rfl PRE_first_tail_x15_r0_body.st48.bodyAccepted0 :
  (fun (bytes : List Byte) (rows : Nat) => PRE_first_tail_x15_r0_body.st48.bodyOkL bytes rows PRE_first_tail_x15_r0_body.st48.s0 PRE_first_tail_x15_r0_body.st48.S0) = fun _ _ => true

kernel_rfl PRE_first_tail_x15_r0_body.st48.bodyAccepted1 :
  (fun (bytes : List Byte) (rows : Nat) => PRE_first_tail_x15_r0_body.st48.bodyOkL bytes rows PRE_first_tail_x15_r0_body.st48.s4 PRE_first_tail_x15_r0_body.st48.S4) = fun _ _ => true

end Host.Load.Run.Tpl
end

section -- st48/TypedK0
set_option Elab.async false
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
namespace Host.Load.Run.Tpl
open Host.Ts Host.Ts.Sim Host.Ts.Sim.Template

boot_rfl PRE_first_tail_x15_r0_body.st48.bodyK0F from PRE_first_tail_x15_r0_body.st48.s0 to PRE_first_tail_x15_r0_body.st48.s1 :
  (fun (bytes : List Byte) (rows : Nat) => runOkS PRE_first_tail_x15_r0_body.st48.F (PRE_first_tail_x15_r0_body.st48.bodyOkLN bytes rows)
    ((nth? PRE_first_tail_x15_r0_body.st48.ks 0).getD 0) PRE_first_tail_x15_r0_body.st48.s0 PRE_first_tail_x15_r0_body.st48.S0) = fun _ _ => some (PRE_first_tail_x15_r0_body.st48.s1, PRE_first_tail_x15_r0_body.st48.S1)
theorem PRE_first_tail_x15_r0_body.st48.bodyK0 :
  (fun (bytes : List Byte) (rows : Nat) => runOk PRE_first_tail_x15_r0_body.st48.F (PRE_first_tail_x15_r0_body.st48.bodyOkL bytes rows)
    ((nth? PRE_first_tail_x15_r0_body.st48.ks 0).getD 0) PRE_first_tail_x15_r0_body.st48.s0 PRE_first_tail_x15_r0_body.st48.S0) = fun _ _ => some (PRE_first_tail_x15_r0_body.st48.s1, PRE_first_tail_x15_r0_body.st48.S1) :=
  runOk_fun_of_runOkS PRE_first_tail_x15_r0_body.st48.bodyOkLN_ok PRE_first_tail_x15_r0_body.st48.bodyK0F
end Host.Load.Run.Tpl
end

section -- st48/TypedK1
set_option Elab.async false
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
namespace Host.Load.Run.Tpl
open Host.Ts Host.Ts.Sim Host.Ts.Sim.Template

boot_rfl PRE_first_tail_x15_r0_body.st48.bodyK1F from PRE_first_tail_x15_r0_body.st48.s1 to PRE_first_tail_x15_r0_body.st48.s2 :
  (fun (bytes : List Byte) (rows : Nat) => runOkS PRE_first_tail_x15_r0_body.st48.F (PRE_first_tail_x15_r0_body.st48.bodyOkLN bytes rows)
    ((nth? PRE_first_tail_x15_r0_body.st48.ks 1).getD 0) PRE_first_tail_x15_r0_body.st48.s1 PRE_first_tail_x15_r0_body.st48.S1) = fun _ _ => some (PRE_first_tail_x15_r0_body.st48.s2, PRE_first_tail_x15_r0_body.st48.S2)
theorem PRE_first_tail_x15_r0_body.st48.bodyK1 :
  (fun (bytes : List Byte) (rows : Nat) => runOk PRE_first_tail_x15_r0_body.st48.F (PRE_first_tail_x15_r0_body.st48.bodyOkL bytes rows)
    ((nth? PRE_first_tail_x15_r0_body.st48.ks 1).getD 0) PRE_first_tail_x15_r0_body.st48.s1 PRE_first_tail_x15_r0_body.st48.S1) = fun _ _ => some (PRE_first_tail_x15_r0_body.st48.s2, PRE_first_tail_x15_r0_body.st48.S2) :=
  runOk_fun_of_runOkS PRE_first_tail_x15_r0_body.st48.bodyOkLN_ok PRE_first_tail_x15_r0_body.st48.bodyK1F
end Host.Load.Run.Tpl
end

section -- st48/TypedK2
set_option Elab.async false
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
namespace Host.Load.Run.Tpl
open Host.Ts Host.Ts.Sim Host.Ts.Sim.Template

boot_rfl PRE_first_tail_x15_r0_body.st48.bodyK2F from PRE_first_tail_x15_r0_body.st48.s2 to PRE_first_tail_x15_r0_body.st48.s3 :
  (fun (bytes : List Byte) (rows : Nat) => runOkS PRE_first_tail_x15_r0_body.st48.F (PRE_first_tail_x15_r0_body.st48.bodyOkLN bytes rows)
    ((nth? PRE_first_tail_x15_r0_body.st48.ks 2).getD 0) PRE_first_tail_x15_r0_body.st48.s2 PRE_first_tail_x15_r0_body.st48.S2) = fun _ _ => some (PRE_first_tail_x15_r0_body.st48.s3, PRE_first_tail_x15_r0_body.st48.S3)
theorem PRE_first_tail_x15_r0_body.st48.bodyK2 :
  (fun (bytes : List Byte) (rows : Nat) => runOk PRE_first_tail_x15_r0_body.st48.F (PRE_first_tail_x15_r0_body.st48.bodyOkL bytes rows)
    ((nth? PRE_first_tail_x15_r0_body.st48.ks 2).getD 0) PRE_first_tail_x15_r0_body.st48.s2 PRE_first_tail_x15_r0_body.st48.S2) = fun _ _ => some (PRE_first_tail_x15_r0_body.st48.s3, PRE_first_tail_x15_r0_body.st48.S3) :=
  runOk_fun_of_runOkS PRE_first_tail_x15_r0_body.st48.bodyOkLN_ok PRE_first_tail_x15_r0_body.st48.bodyK2F
end Host.Load.Run.Tpl
end

section -- st48/TypedK3
set_option Elab.async false
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
namespace Host.Load.Run.Tpl
open Host.Ts Host.Ts.Sim Host.Ts.Sim.Template

boot_rfl PRE_first_tail_x15_r0_body.st48.bodyK3F from PRE_first_tail_x15_r0_body.st48.s3 to PRE_first_tail_x15_r0_body.st48.s4 :
  (fun (bytes : List Byte) (rows : Nat) => runOkS PRE_first_tail_x15_r0_body.st48.F (PRE_first_tail_x15_r0_body.st48.bodyOkLN bytes rows)
    ((nth? PRE_first_tail_x15_r0_body.st48.ks 3).getD 0) PRE_first_tail_x15_r0_body.st48.s3 PRE_first_tail_x15_r0_body.st48.S3) = fun _ _ => some (PRE_first_tail_x15_r0_body.st48.s4, PRE_first_tail_x15_r0_body.st48.S4)
theorem PRE_first_tail_x15_r0_body.st48.bodyK3 :
  (fun (bytes : List Byte) (rows : Nat) => runOk PRE_first_tail_x15_r0_body.st48.F (PRE_first_tail_x15_r0_body.st48.bodyOkL bytes rows)
    ((nth? PRE_first_tail_x15_r0_body.st48.ks 3).getD 0) PRE_first_tail_x15_r0_body.st48.s3 PRE_first_tail_x15_r0_body.st48.S3) = fun _ _ => some (PRE_first_tail_x15_r0_body.st48.s4, PRE_first_tail_x15_r0_body.st48.S4) :=
  runOk_fun_of_runOkS PRE_first_tail_x15_r0_body.st48.bodyOkLN_ok PRE_first_tail_x15_r0_body.st48.bodyK3F
end Host.Load.Run.Tpl
end

section -- st48/TypedTpl
set_option Elab.async false
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
namespace Host.Load.Run.Tpl
open Host.Ts Host.Ts.Sim Host.Ts.Sim.Template

theorem PRE_first_tail_x15_r0_body.st48.bodyRun (bytes : List Byte) (rows : Nat) :
    runOk PRE_first_tail_x15_r0_body.st48.F (PRE_first_tail_x15_r0_body.st48.bodyOkL bytes rows) 11334 PRE_first_tail_x15_r0_body.st48.s0 PRE_first_tail_x15_r0_body.st48.S0 = some (PRE_first_tail_x15_r0_body.st48.s4, PRE_first_tail_x15_r0_body.st48.S4) :=
  runOk_trans PRE_first_tail_x15_r0_body.st48.F (PRE_first_tail_x15_r0_body.st48.bodyOkL bytes rows) ((((nth? PRE_first_tail_x15_r0_body.st48.ks 0).getD 0) + ((nth? PRE_first_tail_x15_r0_body.st48.ks 1).getD 0)) + ((nth? PRE_first_tail_x15_r0_body.st48.ks 2).getD 0)) ((nth? PRE_first_tail_x15_r0_body.st48.ks 3).getD 0) PRE_first_tail_x15_r0_body.st48.s0 PRE_first_tail_x15_r0_body.st48.s3 PRE_first_tail_x15_r0_body.st48.s4 PRE_first_tail_x15_r0_body.st48.S0 PRE_first_tail_x15_r0_body.st48.S3 PRE_first_tail_x15_r0_body.st48.S4 (runOk_trans PRE_first_tail_x15_r0_body.st48.F (PRE_first_tail_x15_r0_body.st48.bodyOkL bytes rows) (((nth? PRE_first_tail_x15_r0_body.st48.ks 0).getD 0) + ((nth? PRE_first_tail_x15_r0_body.st48.ks 1).getD 0)) ((nth? PRE_first_tail_x15_r0_body.st48.ks 2).getD 0) PRE_first_tail_x15_r0_body.st48.s0 PRE_first_tail_x15_r0_body.st48.s2 PRE_first_tail_x15_r0_body.st48.s3 PRE_first_tail_x15_r0_body.st48.S0 PRE_first_tail_x15_r0_body.st48.S2 PRE_first_tail_x15_r0_body.st48.S3 (runOk_trans PRE_first_tail_x15_r0_body.st48.F (PRE_first_tail_x15_r0_body.st48.bodyOkL bytes rows) ((nth? PRE_first_tail_x15_r0_body.st48.ks 0).getD 0) ((nth? PRE_first_tail_x15_r0_body.st48.ks 1).getD 0) PRE_first_tail_x15_r0_body.st48.s0 PRE_first_tail_x15_r0_body.st48.s1 PRE_first_tail_x15_r0_body.st48.s2 PRE_first_tail_x15_r0_body.st48.S0 PRE_first_tail_x15_r0_body.st48.S1 PRE_first_tail_x15_r0_body.st48.S2 ((congrFun (congrFun PRE_first_tail_x15_r0_body.st48.bodyK0 bytes) rows)) (congrFun (congrFun PRE_first_tail_x15_r0_body.st48.bodyK1 bytes) rows)) (congrFun (congrFun PRE_first_tail_x15_r0_body.st48.bodyK2 bytes) rows)) (congrFun (congrFun PRE_first_tail_x15_r0_body.st48.bodyK3 bytes) rows)

theorem PRE_first_tail_x15_r0_body.st48.bodyLocal (bytes : List Byte) (rows : Nat) : ∀ s S, PRE_first_tail_x15_r0_body.st48.bodyOkL bytes rows s S = true → Disp.localB s = true := okLocal_localB

noncomputable def PRE_first_tail_x15_r0_body.st48.bodyTpl (bytes : List Byte) (rows : Nat) : Host.Ts.Sim.Stage.StageTpl PRE_first_tail_x15_r0_body.st48.F (PRE_first_tail_x15_r0_body.st48.bodyOkL bytes rows) where
  s0 := PRE_first_tail_x15_r0_body.st48.s0
  S0 := PRE_first_tail_x15_r0_body.st48.S0
  s1 := PRE_first_tail_x15_r0_body.st48.s4
  S1 := PRE_first_tail_x15_r0_body.st48.S4
  s2 := PRE_first_tail_x15_r0_body.st48.s5
  S2 := PRE_first_tail_x15_r0_body.st48.S5
  n := 11334
  ok0 := congrFun (congrFun PRE_first_tail_x15_r0_body.st48.bodyAccepted0 bytes) rows
  run := PRE_first_tail_x15_r0_body.st48.bodyRun bytes rows
  ok1 := congrFun (congrFun PRE_first_tail_x15_r0_body.st48.bodyAccepted1 bytes) rows
  halt := PRE_first_tail_x15_r0_body.st48.bodyHalt
  last := PRE_first_tail_x15_r0_body.st48.bodyLast
  top := noBlockTop_sound PRE_first_tail_x15_r0_body.st48.bodyTopCheck
end Host.Load.Run.Tpl
end

section -- SiteC49
set_option Elab.async false
namespace Host.Load.Run.Tpl
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
open Host.Ts Host.Ts.Sim Host.Ts.Sim.Template

/-! The compaction after the merge at call site 49 of chain `PRE_first_tail_x15_r0_body` (`Conv.compact`, `Conv.full_compactQ`): the canonical
state `PRE_first_tail_x15_r0_body.s486` (the stage's results at canonical places, its trace the call's) under `PRE_first_tail_x15_r0_body.kappa49` into the merged state
`PRE_first_tail_x15_r0_body.s485`. -/

def PRE_first_tail_x15_r0_body.pl49 : List Nat := []
def PRE_first_tail_x15_r0_body.nr49 : List Nat := []
/-- The native part of the compaction map (canonical → merged handles and nodes: its `big`, `region`, `nodeF`). -/
def PRE_first_tail_x15_r0_body.kd49 : RData :=
  ⟨2713619, 2713621, Stage.setAll PTrie.nil [], Stage.setAll PTrie.nil [],
   19176, 19176, 16266, 16266, Stage.setAll PTrie.nil [],
   Stage.setAll PTrie.nil []⟩
/-- **The compaction map.** -/
noncomputable def PRE_first_tail_x15_r0_body.kappa49 : Map :=
  Conv.Map.compact 2713619 2713621 2174 PRE_first_tail_x15_r0_body.pl49 (PRE_first_tail_x15_r0_body.nr49.map NumV.ref) PRE_first_tail_x15_r0_body.kd49.big
    PRE_first_tail_x15_r0_body.kd49.region PRE_first_tail_x15_r0_body.kd49.nodeF
/-- The canonical result variables and their images, the merged state's entries (`Conv.compactθ`). -/
def PRE_first_tail_x15_r0_body.cws49 : List Nat := []
noncomputable def PRE_first_tail_x15_r0_body.crs49 : List SymE := PRE_first_tail_x15_r0_body.nr49.map fun r => (nth? PRE_first_tail_x15_r0_body.S485.tab r).getD (.var 0)
noncomputable def PRE_first_tail_x15_r0_body.ctheta49 : Nat → SymE := Conv.compactθ PRE_first_tail_x15_r0_body.cws49 PRE_first_tail_x15_r0_body.crs49
/-- The call's entries the stage wrote (renamed in the canonical state with the results). -/
def PRE_first_tail_x15_r0_body.wrB49 : List Nat := [2665, 2673467]

kernel_rfl PRE_first_tail_x15_r0_body.ctab49 : PRE_first_tail_x15_r0_body.S486.tab = PRE_first_tail_x15_r0_body.S484.tab ++ PRE_first_tail_x15_r0_body.cws49.map SymE.var
kernel_rfl PRE_first_tail_x15_r0_body.ctrace49 : PRE_first_tail_x15_r0_body.s486.trace = PRE_first_tail_x15_r0_body.s484.trace
kernel_rfl PRE_first_tail_x15_r0_body.cnext49 : PRE_first_tail_x15_r0_body.s486.next = 2713619
kernel_rfl PRE_first_tail_x15_r0_body.ccounters49 : ((Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s486.ffi).mlx.next, (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s486.ffi).mlx.nnext) = (19176, 16266)
-- the merged state's readback queue, carried to the canonical state (`Conv.FullShiftQ.tokens`, `tokSupp`)
kernel_rfl PRE_first_tail_x15_r0_body.cqueue49 : (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s485.ffi).mlx.tokens = (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s486.ffi).mlx.tokens.map PRE_first_tail_x15_r0_body.kappa49.nv
kernel_rfl PRE_first_tail_x15_r0_body.ctokSupp49 : (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s486.ffi).mlx.tokens.all (bSN 2174) = true
-- the written and the result entries carry no bigint of the canonical fresh band [next, E) and no fresh region
kernel_rfl PRE_first_tail_x15_r0_body.cclean49 : Conv.cleanListB 19176 131072 (fun r => Nat.ble 76704 r) PRE_first_tail_x15_r0_body.s486
    (PRE_first_tail_x15_r0_body.wrB49 ++ (List.range 0).map (2713619 + ·)) = true
kernel_rfl PRE_first_tail_x15_r0_body.cbigs49 : bigsOutB 19176 131072 (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s486.ffi).mlx = true

end Host.Load.Run.Tpl
end

section -- SiteK49
set_option Elab.async false
namespace Host.Load.Run.Tpl
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
open Host.Ts Host.Ts.Sim Host.Ts.Sim.Template

/-! The canonical state's closedness from the call's (`Conv.closed_of_callB`, `Conv.sst_of_callB`): it keeps the call's entries
off the written and the result ones (`PRE_first_tail_x15_r0_body.cl49`; natively the written and result handles, the result nodes, the written
and result items), and those are checked. -/

def PRE_first_tail_x15_r0_body.cl49 : List Nat := [2665, 2673467]
def PRE_first_tail_x15_r0_body.clo49 : List Nat := []
def PRE_first_tail_x15_r0_body.cln49 : List Nat := []
def PRE_first_tail_x15_r0_body.cli49 : List Nat := []
kernel_rfl PRE_first_tail_x15_r0_body.cheap49 : PRE_first_tail_x15_r0_body.s486.heap = Stage.setAll PRE_first_tail_x15_r0_body.s484.heap (PRE_first_tail_x15_r0_body.cl49.filterMap fun a => (PRE_first_tail_x15_r0_body.s486.heap.get a).map (a, ·))
kernel_rfl PRE_first_tail_x15_r0_body.cnextLe49 : Nat.ble PRE_first_tail_x15_r0_body.s484.next PRE_first_tail_x15_r0_body.s486.next = true
kernel_rfl PRE_first_tail_x15_r0_body.ckeepP49 : Conv.keptPresentB PRE_first_tail_x15_r0_body.s484 PRE_first_tail_x15_r0_body.s486 PRE_first_tail_x15_r0_body.cl49 = true
kernel_rfl PRE_first_tail_x15_r0_body.csupp49 : Conv.suppListB PRE_first_tail_x15_r0_body.s486 2174 PRE_first_tail_x15_r0_body.cl49 = true
kernel_rfl PRE_first_tail_x15_r0_body.cbound49 : Conv.boundListB PRE_first_tail_x15_r0_body.s486 PRE_first_tail_x15_r0_body.cl49 = true
kernel_rfl PRE_first_tail_x15_r0_body.cnodesK49 : (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s486.ffi).mlx.nodes = Stage.setAll (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s484.ffi).mlx.nodes (PRE_first_tail_x15_r0_body.cln49.filterMap fun i => ((Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s486.ffi).mlx.nodes.get i).map (i, ·))
kernel_rfl PRE_first_tail_x15_r0_body.cobjsK49 : (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s486.ffi).mlx.objs = Stage.setAll (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s484.ffi).mlx.objs (PRE_first_tail_x15_r0_body.clo49.filterMap fun i => ((Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s486.ffi).mlx.objs.get i).map (i, ·))
kernel_rfl PRE_first_tail_x15_r0_body.citemsK49 : (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s486.ffi).mlx.items = Stage.setAll (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s484.ffi).mlx.items (PRE_first_tail_x15_r0_body.cli49.filterMap fun i => ((Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s486.ffi).mlx.items.get i).map (i, ·))
kernel_rfl PRE_first_tail_x15_r0_body.csst49 : Conv.sstListB 2174 (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s486.ffi).mlx PRE_first_tail_x15_r0_body.cln49 PRE_first_tail_x15_r0_body.clo49 PRE_first_tail_x15_r0_body.cli49 = true

end Host.Load.Run.Tpl
end

section -- SiteCl49
set_option Elab.async false
namespace Host.Load.Run.Tpl
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
open Host.Ts Host.Ts.Sim Host.Ts.Sim.Template

kernel_rfl PRE_first_tail_x15_r0_body.ckA49 : (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s486.ffi).mlx.arrs = Stage.setAll (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s484.ffi).mlx.arrs (PRE_first_tail_x15_r0_body.clo49.filterMap fun i => ((Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s486.ffi).mlx.arrs.get i).map (i, ·))
kernel_rfl PRE_first_tail_x15_r0_body.cbd49 : (PRE_first_tail_x15_r0_body.clo49 ++ PRE_first_tail_x15_r0_body.cln49 ++ PRE_first_tail_x15_r0_body.cli49).all (fun i => Nat.blt (i / 4096) (4 ^ 31)) = true
kernel_rfl PRE_first_tail_x15_r0_body.cle49 : Conv.Cnt.leB (⟨19176, 16266, 2713619, 2174⟩ : Conv.Cnt) (⟨19176, 16266, 2713619, 2174⟩ : Conv.Cnt) = true
kernel_rfl PRE_first_tail_x15_r0_body.cck49 : Conv.ncleanListB (⟨19176, 16266, 2713619, 2174⟩ : Conv.Cnt) (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s486.ffi).mlx PRE_first_tail_x15_r0_body.clo49 PRE_first_tail_x15_r0_body.cln49 PRE_first_tail_x15_r0_body.cli49 = true
theorem PRE_first_tail_x15_r0_body.cncl49 (h : Conv.NClean (⟨19176, 16266, 2713619, 2174⟩ : Conv.Cnt) (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s484.ffi).mlx) : Conv.NClean (⟨19176, 16266, 2713619, 2174⟩ : Conv.Cnt) (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s486.ffi).mlx :=
  Conv.NClean.stepKeep h PRE_first_tail_x15_r0_body.cle49 PRE_first_tail_x15_r0_body.ckA49 PRE_first_tail_x15_r0_body.cobjsK49 PRE_first_tail_x15_r0_body.cnodesK49 PRE_first_tail_x15_r0_body.citemsK49 PRE_first_tail_x15_r0_body.cbd49 PRE_first_tail_x15_r0_body.cck49

end Host.Load.Run.Tpl
end

section -- SiteS49
set_option Elab.async false
namespace Host.Load.Run.Tpl
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
open Host.Ts Host.Ts.Sim Host.Ts.Sim.Template

/-! The compaction's native shift at call site 49 from its footprint (`Conv.nshift_of_foot`), and the observers'
(`liveShift_foot`, `kernShift_foot`): `Conv.FullShiftQ` for `Conv.full_compactQ`, given the call's bookkeeping and its
relation's facts. -/

/-- The load parameters of the chain (band-free: its start's node counter as `NL` and `N0`). -/
def PRE_first_tail_x15_r0_body.Pc49 : LoadP := ⟨18151, 131072, 1099511627776, 15235, 15235, []⟩
/-- The site's band raised to the map's checked fixed-node prefix, including newly recorded closure traces. -/
def PRE_first_tail_x15_r0_body.P49 : LoadP := PRE_first_tail_x15_r0_body.Pc49.raise 16266
kernel_rfl PRE_first_tail_x15_r0_body.craise49 : Nat.ble PRE_first_tail_x15_r0_body.Pc49.N0 16266 = true
theorem PRE_first_tail_x15_r0_body.raised49 : Host.Ts.Sim.Full.Raised PRE_first_tail_x15_r0_body.Pc49 PRE_first_tail_x15_r0_body.P49 :=
  .inr ⟨16266, rfl, Nat.le_of_ble_eq_true PRE_first_tail_x15_r0_body.craise49, rfl⟩
noncomputable abbrev PRE_first_tail_x15_r0_body.cx0_49 : Host.Load.LSt := clearTokens (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s486.ffi)
noncomputable abbrev PRE_first_tail_x15_r0_body.cx1_49 : Host.Load.LSt := clearTokens (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s485.ffi)
def PRE_first_tail_x15_r0_body.khinv49 : PTrie Nat := Stage.setAll PTrie.nil []
def PRE_first_tail_x15_r0_body.kninv49 : PTrie Nat := Stage.setAll PTrie.nil []
/-- The stage's footprint: its written and fresh handles, fresh nodes, written and fresh items. -/
def PRE_first_tail_x15_r0_body.cwS49 : List Nat := []
def PRE_first_tail_x15_r0_body.cnS49 : List Nat := List.range' 16266 0
def PRE_first_tail_x15_r0_body.ciS49 : List Nat := [] ++ List.range' 16266 0

-- the small checks (`MChecks`'s)
kernel_rfl PRE_first_tail_x15_r0_body.cnh049 : PRE_first_tail_x15_r0_body.kd49.nh0 = PRE_first_tail_x15_r0_body.cx0_49.mlx.next
kernel_rfl PRE_first_tail_x15_r0_body.cnh149 : PRE_first_tail_x15_r0_body.kd49.nh1 = PRE_first_tail_x15_r0_body.cx1_49.mlx.next
kernel_rfl PRE_first_tail_x15_r0_body.cnn049 : PRE_first_tail_x15_r0_body.kd49.nn0 = PRE_first_tail_x15_r0_body.cx0_49.mlx.nnext
kernel_rfl PRE_first_tail_x15_r0_body.cnn149 : PRE_first_tail_x15_r0_body.kd49.nn1 = PRE_first_tail_x15_r0_body.cx1_49.mlx.nnext
kernel_rfl PRE_first_tail_x15_r0_body.cplo49 : (Nat.blt 0 PRE_first_tail_x15_r0_body.P49.lo && Nat.ble PRE_first_tail_x15_r0_body.P49.lo PRE_first_tail_x15_r0_body.cx0_49.mlx.next && Nat.ble PRE_first_tail_x15_r0_body.P49.lo RData.bigHi && Nat.ble RData.bigHi PRE_first_tail_x15_r0_body.P49.E) = true
kernel_rfl PRE_first_tail_x15_r0_body.ccnt49 : (Nat.ble PRE_first_tail_x15_r0_body.cx0_49.mlx.next PRE_first_tail_x15_r0_body.cx1_49.mlx.next && Nat.ble PRE_first_tail_x15_r0_body.cx0_49.mlx.nnext PRE_first_tail_x15_r0_body.cx1_49.mlx.nnext) = true
kernel_rfl PRE_first_tail_x15_r0_body.cnband49 : (Nat.blt 0 PRE_first_tail_x15_r0_body.P49.NL && Nat.ble PRE_first_tail_x15_r0_body.P49.NL PRE_first_tail_x15_r0_body.P49.N0 && Nat.ble PRE_first_tail_x15_r0_body.P49.N0 PRE_first_tail_x15_r0_body.cx0_49.mlx.nnext) = true
kernel_rfl PRE_first_tail_x15_r0_body.chbelow49 : PRE_first_tail_x15_r0_body.kd49.checkHndBelow = true
kernel_rfl PRE_first_tail_x15_r0_body.chren49 : checkRenG PRE_first_tail_x15_r0_body.kd49.hnd PRE_first_tail_x15_r0_body.khinv49 (phB PRE_first_tail_x15_r0_body.cx0_49.mlx) = true
kernel_rfl PRE_first_tail_x15_r0_body.cband49 : PRE_first_tail_x15_r0_body.kd49.checkBand PRE_first_tail_x15_r0_body.P49.lo = true
kernel_rfl PRE_first_tail_x15_r0_body.cnh1pos49 : Nat.blt 0 PRE_first_tail_x15_r0_body.kd49.nh1 = true
kernel_rfl PRE_first_tail_x15_r0_body.cnren49 : checkRenG PRE_first_tail_x15_r0_body.kd49.node PRE_first_tail_x15_r0_body.kninv49 (pnB PRE_first_tail_x15_r0_body.cx0_49.mlx) = true
kernel_rfl PRE_first_tail_x15_r0_body.cnlow49 : (PTrie.keysA PRE_first_tail_x15_r0_body.kd49.node).all (fun j => Nat.ble PRE_first_tail_x15_r0_body.P49.NL j && Nat.blt (PRE_first_tail_x15_r0_body.kd49.nodeF j) PRE_first_tail_x15_r0_body.cx1_49.mlx.nnext) = true
kernel_rfl PRE_first_tail_x15_r0_body.cabs0a49 : PRE_first_tail_x15_r0_body.cx0_49.mlx.arrs.get 0 = none
kernel_rfl PRE_first_tail_x15_r0_body.cabs0b49 : PRE_first_tail_x15_r0_body.cx0_49.mlx.objs.get 0 = none
kernel_rfl PRE_first_tail_x15_r0_body.ctok149 : PRE_first_tail_x15_r0_body.cx1_49.mlx.tokens = []
kernel_rfl PRE_first_tail_x15_r0_body.cpend49 : PRE_first_tail_x15_r0_body.cx1_49.mlx.pending = PRE_first_tail_x15_r0_body.cx0_49.mlx.pending.map PRE_first_tail_x15_r0_body.kappa49.pend
kernel_rfl PRE_first_tail_x15_r0_body.cerrh49 : PRE_first_tail_x15_r0_body.cx1_49.mlx.errh = PRE_first_tail_x15_r0_body.cx0_49.mlx.errh.map PRE_first_tail_x15_r0_body.kappa49.arg
kernel_rfl PRE_first_tail_x15_r0_body.cfiles49 : PRE_first_tail_x15_r0_body.cx1_49.mlx.files = PRE_first_tail_x15_r0_body.cx0_49.mlx.files
kernel_rfl PRE_first_tail_x15_r0_body.carch49 : PRE_first_tail_x15_r0_body.cx1_49.mlx.arch = PRE_first_tail_x15_r0_body.cx0_49.mlx.arch
kernel_rfl PRE_first_tail_x15_r0_body.csizes49 : PRE_first_tail_x15_r0_body.cx1_49.mlx.deviceSizes = PRE_first_tail_x15_r0_body.cx0_49.mlx.deviceSizes
kernel_rfl PRE_first_tail_x15_r0_body.cwired49 : PRE_first_tail_x15_r0_body.cx1_49.mlx.wired = PRE_first_tail_x15_r0_body.cx0_49.mlx.wired
kernel_rfl PRE_first_tail_x15_r0_body.chost49 : PRE_first_tail_x15_r0_body.cx1_49.host = PRE_first_tail_x15_r0_body.cx0_49.host
-- the compaction map's addresses are `PRE_first_tail_x15_r0_body.kd49`'s
kernel_rfl PRE_first_tail_x15_r0_body.ckn049 : PRE_first_tail_x15_r0_body.kd49.n0 = 2713619
kernel_rfl PRE_first_tail_x15_r0_body.ckn149 : PRE_first_tail_x15_r0_body.kd49.n1 = 2713621
kernel_rfl PRE_first_tail_x15_r0_body.ckheap49 : (PTrie.keysA PRE_first_tail_x15_r0_body.kd49.heap).all (fun x => Nat.ble 2713619 x) = true
kernel_rfl PRE_first_tail_x15_r0_body.ckpl49 : (List.range 0).all (fun j => decide (PRE_first_tail_x15_r0_body.kd49.heap.get (2713619 + j) = nth? PRE_first_tail_x15_r0_body.pl49 j)) = true
-- the map fixes the call's names (`Conv.fixOld_compact`), the call's counters
kernel_rfl PRE_first_tail_x15_r0_body.fja49 : Nat.ble 2713619 2713619 = true
kernel_rfl PRE_first_tail_x15_r0_body.fn49 : Nat.ble 2174 2174 = true
kernel_rfl PRE_first_tail_x15_r0_body.fjaD49 : Nat.ble 2713619 PRE_first_tail_x15_r0_body.kd49.n0 = true
kernel_rfl PRE_first_tail_x15_r0_body.fxn49 : Nat.ble 19176 PRE_first_tail_x15_r0_body.kd49.nh0 = true
kernel_rfl PRE_first_tail_x15_r0_body.fnn49 : Nat.ble 16266 PRE_first_tail_x15_r0_body.kd49.nn0 = true
kernel_rfl PRE_first_tail_x15_r0_body.fxb49 : Nat.ble 19176 RData.bigHi = true
kernel_rfl PRE_first_tail_x15_r0_body.fheap49 : (PTrie.keysA PRE_first_tail_x15_r0_body.kd49.heap).all (Nat.ble (⟨19176, 16266, 2713619, 2174⟩ : Conv.Cnt).ja) = true
kernel_rfl PRE_first_tail_x15_r0_body.fhnd49 : (PTrie.keysA PRE_first_tail_x15_r0_body.kd49.hnd).all (Nat.ble (⟨19176, 16266, 2713619, 2174⟩ : Conv.Cnt).xn) = true
kernel_rfl PRE_first_tail_x15_r0_body.fnode49 : (PTrie.keysA PRE_first_tail_x15_r0_body.kd49.node).all (Nat.ble (⟨19176, 16266, 2713619, 2174⟩ : Conv.Cnt).nn) = true
/-- The compaction map fixes the call's names. -/
theorem PRE_first_tail_x15_r0_body.cfix49 : Conv.FixOld (⟨19176, 16266, 2713619, 2174⟩ : Conv.Cnt) PRE_first_tail_x15_r0_body.kappa49 :=
  Conv.fixOld_compact (Nat.le_of_ble_eq_true PRE_first_tail_x15_r0_body.fja49) (Nat.le_of_ble_eq_true PRE_first_tail_x15_r0_body.fn49) (Nat.le_of_ble_eq_true PRE_first_tail_x15_r0_body.fjaD49) (Nat.le_of_ble_eq_true PRE_first_tail_x15_r0_body.fxn49) (Nat.le_of_ble_eq_true PRE_first_tail_x15_r0_body.fnn49) (Nat.le_of_ble_eq_true PRE_first_tail_x15_r0_body.fxb49) PRE_first_tail_x15_r0_body.fheap49 PRE_first_tail_x15_r0_body.fhnd49 PRE_first_tail_x15_r0_body.fnode49
kernel_rfl PRE_first_tail_x15_r0_body.fcxn49 : (⟨19176, 16266, 2713619, 2174⟩ : Conv.Cnt).xn = (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s484.ffi).mlx.next
kernel_rfl PRE_first_tail_x15_r0_body.fcnn49 : (⟨19176, 16266, 2713619, 2174⟩ : Conv.Cnt).nn = (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s484.ffi).mlx.nnext
kernel_rfl PRE_first_tail_x15_r0_body.fle049 : (Nat.ble (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s484.ffi).mlx.next PRE_first_tail_x15_r0_body.cx0_49.mlx.next && Nat.ble (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s484.ffi).mlx.nnext PRE_first_tail_x15_r0_body.cx0_49.mlx.nnext && Nat.ble (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s484.ffi).mlx.next RData.bigHi) = true
kernel_rfl PRE_first_tail_x15_r0_body.fnk49 : (PTrie.keysA PRE_first_tail_x15_r0_body.kd49.node).all (Nat.ble (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s484.ffi).mlx.nnext) = true
-- the merged state keeps the call's entries off the stage's footprint
kernel_rfl PRE_first_tail_x15_r0_body.f1A49 : PRE_first_tail_x15_r0_body.cx1_49.mlx.arrs = Stage.setAll (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s484.ffi).mlx.arrs (PRE_first_tail_x15_r0_body.cwS49.filterMap fun i => (PRE_first_tail_x15_r0_body.cx1_49.mlx.arrs.get i).map (i, ·))
kernel_rfl PRE_first_tail_x15_r0_body.f1O49 : PRE_first_tail_x15_r0_body.cx1_49.mlx.objs = Stage.setAll (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s484.ffi).mlx.objs (PRE_first_tail_x15_r0_body.cwS49.filterMap fun i => (PRE_first_tail_x15_r0_body.cx1_49.mlx.objs.get i).map (i, ·))
kernel_rfl PRE_first_tail_x15_r0_body.f1N49 : PRE_first_tail_x15_r0_body.cx1_49.mlx.nodes = Stage.setAll (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s484.ffi).mlx.nodes (PRE_first_tail_x15_r0_body.cnS49.filterMap fun i => (PRE_first_tail_x15_r0_body.cx1_49.mlx.nodes.get i).map (i, ·))
kernel_rfl PRE_first_tail_x15_r0_body.f1I49 : PRE_first_tail_x15_r0_body.cx1_49.mlx.items = Stage.setAll (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s484.ffi).mlx.items (PRE_first_tail_x15_r0_body.ciS49.filterMap fun i => (PRE_first_tail_x15_r0_body.cx1_49.mlx.items.get i).map (i, ·))
kernel_rfl PRE_first_tail_x15_r0_body.fbd49 : (PRE_first_tail_x15_r0_body.clo49 ++ PRE_first_tail_x15_r0_body.cln49 ++ PRE_first_tail_x15_r0_body.cli49 ++ PRE_first_tail_x15_r0_body.cwS49 ++ PRE_first_tail_x15_r0_body.cnS49 ++ PRE_first_tail_x15_r0_body.ciS49).all (fun i => Nat.blt (i / 4096) (4 ^ 31)) = true
kernel_rfl PRE_first_tail_x15_r0_body.fincW49 : PRE_first_tail_x15_r0_body.cwS49.all (fun h => !Nat.blt h (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s484.ffi).mlx.next || PRE_first_tail_x15_r0_body.clo49.contains h) = true
kernel_rfl PRE_first_tail_x15_r0_body.fincI49 : PRE_first_tail_x15_r0_body.ciS49.all (fun k => !Nat.blt k (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s484.ffi).mlx.nnext || PRE_first_tail_x15_r0_body.cli49.contains k) = true
kernel_rfl PRE_first_tail_x15_r0_body.fincN49 : PRE_first_tail_x15_r0_body.cnS49.all (Nat.ble (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s484.ffi).mlx.nnext) = true
kernel_rfl PRE_first_tail_x15_r0_body.flnF49 : PRE_first_tail_x15_r0_body.cln49.all (Nat.ble (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s484.ffi).mlx.nnext) = true
-- the checks over the changed lists
kernel_rfl PRE_first_tail_x15_r0_body.fh49 : PRE_first_tail_x15_r0_body.clo49.all (handleOK PRE_first_tail_x15_r0_body.kappa49 PRE_first_tail_x15_r0_body.P49.lo PRE_first_tail_x15_r0_body.cx0_49.mlx PRE_first_tail_x15_r0_body.cx1_49.mlx) = true
kernel_rfl PRE_first_tail_x15_r0_body.fo49 : PRE_first_tail_x15_r0_body.clo49.map (fun h => PRE_first_tail_x15_r0_body.cx1_49.mlx.objs.get (PRE_first_tail_x15_r0_body.kappa49.handle h)) = PRE_first_tail_x15_r0_body.clo49.map (fun h => (PRE_first_tail_x15_r0_body.cx0_49.mlx.objs.get h).map PRE_first_tail_x15_r0_body.kappa49.nobj)
kernel_rfl PRE_first_tail_x15_r0_body.fok49 : PRE_first_tail_x15_r0_body.clo49.all (objOK PRE_first_tail_x15_r0_body.kappa49 PRE_first_tail_x15_r0_body.P49.NL PRE_first_tail_x15_r0_body.cx0_49.mlx) = true
kernel_rfl PRE_first_tail_x15_r0_body.fnd49 : PRE_first_tail_x15_r0_body.cln49.all (nodeOKF PRE_first_tail_x15_r0_body.kappa49 PRE_first_tail_x15_r0_body.P49 PRE_first_tail_x15_r0_body.cx0_49.mlx PRE_first_tail_x15_r0_body.cx1_49.mlx) = true
kernel_rfl PRE_first_tail_x15_r0_body.fp49 : ((PRE_first_tail_x15_r0_body.cln49.filter (fullB PRE_first_tail_x15_r0_body.P49))).map (fun i => (PRE_first_tail_x15_r0_body.cx1_49.mlx.nodes.get (PRE_first_tail_x15_r0_body.kappa49.node i)).map Host.Mlx.Ffi.Node.prim) =
  ((PRE_first_tail_x15_r0_body.cln49.filter (fullB PRE_first_tail_x15_r0_body.P49))).map (fun i => (PRE_first_tail_x15_r0_body.cx0_49.mlx.nodes.get i).map fun nd => PRE_first_tail_x15_r0_body.kappa49.prim nd.prim)
kernel_rfl PRE_first_tail_x15_r0_body.fnordI49 : incrB PRE_first_tail_x15_r0_body.kd49.nodeF (List.range' 16266 0) = true
kernel_rfl PRE_first_tail_x15_r0_body.fnordK49 : (PTrie.keysA PRE_first_tail_x15_r0_body.kd49.node).all (fun k => Nat.ble 16266 k && Nat.blt k 16266) = true
kernel_rfl PRE_first_tail_x15_r0_body.fnordL49 : (PRE_first_tail_x15_r0_body.cln49.filter (Nat.ble PRE_first_tail_x15_r0_body.P49.N0)).all (fun i => Nat.ble i (PRE_first_tail_x15_r0_body.kd49.nodeF i) && (Nat.blt i 16266 || Nat.ble PRE_first_tail_x15_r0_body.kd49.nn0 i)) = true
theorem PRE_first_tail_x15_r0_body.fnord49 : (PRE_first_tail_x15_r0_body.cln49.filter (Nat.ble PRE_first_tail_x15_r0_body.P49.N0)).all (fun i => Nat.ble i (PRE_first_tail_x15_r0_body.kd49.nodeF i) &&
    (PTrie.keysA PRE_first_tail_x15_r0_body.kd49.node).all fun j => !Nat.blt j i || Nat.blt (PRE_first_tail_x15_r0_body.kd49.nodeF j) (PRE_first_tail_x15_r0_body.kd49.nodeF i)) = true :=
  cnord_of PRE_first_tail_x15_r0_body.cnlow49 PRE_first_tail_x15_r0_body.cnn149 PRE_first_tail_x15_r0_body.fnordI49 PRE_first_tail_x15_r0_body.fnordK49 PRE_first_tail_x15_r0_body.fnordL49
kernel_rfl PRE_first_tail_x15_r0_body.fi49 : PRE_first_tail_x15_r0_body.cli49.all (pnB PRE_first_tail_x15_r0_body.cx0_49.mlx) = true
kernel_rfl PRE_first_tail_x15_r0_body.fii49 : PRE_first_tail_x15_r0_body.cli49.all (fun k => decide (PRE_first_tail_x15_r0_body.cx1_49.mlx.items.get (PRE_first_tail_x15_r0_body.kappa49.node k) = (PRE_first_tail_x15_r0_body.cx0_49.mlx.items.get k).map PRE_first_tail_x15_r0_body.kappa49.nv)) = true
/-- **The compaction's footprint.** -/
theorem PRE_first_tail_x15_r0_body.cfoot49 (clean : Conv.NClean (⟨19176, 16266, 2713619, 2174⟩ : Conv.Cnt) (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s484.ffi).mlx) (hltC : ∀ h, PH (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s484.ffi).mlx h → h < (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s484.ffi).mlx.next) (nltC : ∀ i, PN (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s484.ffi).mlx i → i < (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s484.ffi).mlx.nnext) (itemsC : ∀ k v, (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s484.ffi).mlx.items.get k = some v → PN (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s484.ffi).mlx k) (tracedC : ∀ h o, (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s484.ffi).mlx.objs.get h = some o → ∀ i ∈ objTraces o, i < PRE_first_tail_x15_r0_body.P49.NL) (cl : SSt (· < 2174) PRE_first_tail_x15_r0_body.cx0_49.mlx) :
    Conv.MFoot PRE_first_tail_x15_r0_body.P49 2174 PRE_first_tail_x15_r0_body.kappa49 PRE_first_tail_x15_r0_body.kd49 PRE_first_tail_x15_r0_body.khinv49 PRE_first_tail_x15_r0_body.kninv49 (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s484.ffi).mlx PRE_first_tail_x15_r0_body.cx0_49.mlx PRE_first_tail_x15_r0_body.cx1_49.mlx (⟨19176, 16266, 2713619, 2174⟩ : Conv.Cnt) PRE_first_tail_x15_r0_body.clo49 PRE_first_tail_x15_r0_body.cln49 PRE_first_tail_x15_r0_body.cli49 PRE_first_tail_x15_r0_body.cwS49 PRE_first_tail_x15_r0_body.cnS49 PRE_first_tail_x15_r0_body.ciS49 :=
  ⟨rfl, rfl, rfl, PRE_first_tail_x15_r0_body.cnh049, PRE_first_tail_x15_r0_body.cnh149, PRE_first_tail_x15_r0_body.cnn049, PRE_first_tail_x15_r0_body.cnn149, PRE_first_tail_x15_r0_body.cplo49, PRE_first_tail_x15_r0_body.ccnt49, PRE_first_tail_x15_r0_body.cnband49, PRE_first_tail_x15_r0_body.chbelow49, PRE_first_tail_x15_r0_body.chren49, PRE_first_tail_x15_r0_body.cband49, PRE_first_tail_x15_r0_body.cnh1pos49, PRE_first_tail_x15_r0_body.cnren49, PRE_first_tail_x15_r0_body.cnlow49, PRE_first_tail_x15_r0_body.cabs0a49, PRE_first_tail_x15_r0_body.cabs0b49, PRE_first_tail_x15_r0_body.ctok149, PRE_first_tail_x15_r0_body.cpend49, PRE_first_tail_x15_r0_body.cerrh49, PRE_first_tail_x15_r0_body.cfiles49, PRE_first_tail_x15_r0_body.carch49, PRE_first_tail_x15_r0_body.csizes49, PRE_first_tail_x15_r0_body.cwired49, PRE_first_tail_x15_r0_body.cfix49, clean, PRE_first_tail_x15_r0_body.fcxn49, PRE_first_tail_x15_r0_body.fcnn49, hltC, nltC, itemsC, tracedC, cl, PRE_first_tail_x15_r0_body.fle049, PRE_first_tail_x15_r0_body.fnk49, PRE_first_tail_x15_r0_body.ckA49, PRE_first_tail_x15_r0_body.cobjsK49, PRE_first_tail_x15_r0_body.cnodesK49, PRE_first_tail_x15_r0_body.citemsK49, PRE_first_tail_x15_r0_body.f1A49, PRE_first_tail_x15_r0_body.f1O49, PRE_first_tail_x15_r0_body.f1N49, PRE_first_tail_x15_r0_body.f1I49, PRE_first_tail_x15_r0_body.fbd49, PRE_first_tail_x15_r0_body.fincW49, PRE_first_tail_x15_r0_body.fincI49, PRE_first_tail_x15_r0_body.fincN49, PRE_first_tail_x15_r0_body.flnF49, PRE_first_tail_x15_r0_body.fh49, PRE_first_tail_x15_r0_body.fo49, PRE_first_tail_x15_r0_body.fok49, PRE_first_tail_x15_r0_body.fnd49, PRE_first_tail_x15_r0_body.fp49, PRE_first_tail_x15_r0_body.fnord49, PRE_first_tail_x15_r0_body.fi49, PRE_first_tail_x15_r0_body.fii49⟩
theorem PRE_first_tail_x15_r0_body.cnshift49 (clean : Conv.NClean (⟨19176, 16266, 2713619, 2174⟩ : Conv.Cnt) (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s484.ffi).mlx) (hltC : ∀ h, PH (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s484.ffi).mlx h → h < (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s484.ffi).mlx.next) (nltC : ∀ i, PN (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s484.ffi).mlx i → i < (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s484.ffi).mlx.nnext) (itemsC : ∀ k v, (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s484.ffi).mlx.items.get k = some v → PN (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s484.ffi).mlx k) (tracedC : ∀ h o, (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s484.ffi).mlx.objs.get h = some o → ∀ i ∈ objTraces o, i < PRE_first_tail_x15_r0_body.P49.NL) (cl : SSt (· < 2174) PRE_first_tail_x15_r0_body.cx0_49.mlx) : NShift PRE_first_tail_x15_r0_body.P49 2174 PRE_first_tail_x15_r0_body.kappa49 PRE_first_tail_x15_r0_body.cx0_49 PRE_first_tail_x15_r0_body.cx1_49 :=
  Conv.nshift_of_foot (PRE_first_tail_x15_r0_body.cfoot49 clean hltC nltC itemsC tracedC cl) PRE_first_tail_x15_r0_body.chost49 (compact_a_eq PRE_first_tail_x15_r0_body.ckn049 PRE_first_tail_x15_r0_body.ckn149 PRE_first_tail_x15_r0_body.ckheap49 PRE_first_tail_x15_r0_body.ckpl49)

-- the observers: the layers' states at the call, the canonical and the merged state, their footprints and checks
noncomputable def PRE_first_tail_x15_r0_body.fxC_49 : PTrie Unit := (Host.Ts.Sim.Full.freedOf PRE_first_tail_x15_r0_body.s484.ffi).getD PTrie.nil
noncomputable def PRE_first_tail_x15_r0_body.krC_49 : Host.Load.Layers.KRec := (Host.Ts.Sim.Full.krecOf PRE_first_tail_x15_r0_body.s484.ffi).getD Host.Load.Layers.KRec.empty
kernel_rfl PRE_first_tail_x15_r0_body.ofxC_49 : (Host.Ts.Sim.Full.freedOf PRE_first_tail_x15_r0_body.s484.ffi) = some PRE_first_tail_x15_r0_body.fxC_49
kernel_rfl PRE_first_tail_x15_r0_body.okrC_49 : (Host.Ts.Sim.Full.krecOf PRE_first_tail_x15_r0_body.s484.ffi) = some PRE_first_tail_x15_r0_body.krC_49
noncomputable def PRE_first_tail_x15_r0_body.fx0_49 : PTrie Unit := (Host.Ts.Sim.Full.freedOf PRE_first_tail_x15_r0_body.s486.ffi).getD PTrie.nil
noncomputable def PRE_first_tail_x15_r0_body.kr0_49 : Host.Load.Layers.KRec := (Host.Ts.Sim.Full.krecOf PRE_first_tail_x15_r0_body.s486.ffi).getD Host.Load.Layers.KRec.empty
kernel_rfl PRE_first_tail_x15_r0_body.ofx0_49 : (Host.Ts.Sim.Full.freedOf PRE_first_tail_x15_r0_body.s486.ffi) = some PRE_first_tail_x15_r0_body.fx0_49
kernel_rfl PRE_first_tail_x15_r0_body.okr0_49 : (Host.Ts.Sim.Full.krecOf PRE_first_tail_x15_r0_body.s486.ffi) = some PRE_first_tail_x15_r0_body.kr0_49
noncomputable def PRE_first_tail_x15_r0_body.fx1_49 : PTrie Unit := (Host.Ts.Sim.Full.freedOf PRE_first_tail_x15_r0_body.s485.ffi).getD PTrie.nil
noncomputable def PRE_first_tail_x15_r0_body.kr1_49 : Host.Load.Layers.KRec := (Host.Ts.Sim.Full.krecOf PRE_first_tail_x15_r0_body.s485.ffi).getD Host.Load.Layers.KRec.empty
kernel_rfl PRE_first_tail_x15_r0_body.ofx1_49 : (Host.Ts.Sim.Full.freedOf PRE_first_tail_x15_r0_body.s485.ffi) = some PRE_first_tail_x15_r0_body.fx1_49
kernel_rfl PRE_first_tail_x15_r0_body.okr1_49 : (Host.Ts.Sim.Full.krecOf PRE_first_tail_x15_r0_body.s485.ffi) = some PRE_first_tail_x15_r0_body.kr1_49
kernel_rfl PRE_first_tail_x15_r0_body.ff049 : PRE_first_tail_x15_r0_body.fx0_49 = Stage.setAll PRE_first_tail_x15_r0_body.fxC_49 (PRE_first_tail_x15_r0_body.clo49.filterMap fun i => (PRE_first_tail_x15_r0_body.fx0_49.get i).map (i, ·))
kernel_rfl PRE_first_tail_x15_r0_body.ff149 : PRE_first_tail_x15_r0_body.fx1_49 = Stage.setAll PRE_first_tail_x15_r0_body.fxC_49 (PRE_first_tail_x15_r0_body.cwS49.filterMap fun i => (PRE_first_tail_x15_r0_body.fx1_49.get i).map (i, ·))
kernel_rfl PRE_first_tail_x15_r0_body.ffck49 : freedLB PRE_first_tail_x15_r0_body.kappa49 PRE_first_tail_x15_r0_body.cx0_49.mlx PRE_first_tail_x15_r0_body.fx0_49 PRE_first_tail_x15_r0_body.fx1_49 PRE_first_tail_x15_r0_body.clo49 = true
kernel_rfl PRE_first_tail_x15_r0_body.fkf049 : PRE_first_tail_x15_r0_body.kr0_49.flags = Stage.setAll PRE_first_tail_x15_r0_body.krC_49.flags (PRE_first_tail_x15_r0_body.clo49.filterMap fun i => (PRE_first_tail_x15_r0_body.kr0_49.flags.get i).map (i, ·))
kernel_rfl PRE_first_tail_x15_r0_body.fkt049 : PRE_first_tail_x15_r0_body.kr0_49.targs = Stage.setAll PRE_first_tail_x15_r0_body.krC_49.targs (PRE_first_tail_x15_r0_body.clo49.filterMap fun i => (PRE_first_tail_x15_r0_body.kr0_49.targs.get i).map (i, ·))
kernel_rfl PRE_first_tail_x15_r0_body.fkf149 : PRE_first_tail_x15_r0_body.kr1_49.flags = Stage.setAll PRE_first_tail_x15_r0_body.krC_49.flags (PRE_first_tail_x15_r0_body.cwS49.filterMap fun i => (PRE_first_tail_x15_r0_body.kr1_49.flags.get i).map (i, ·))
kernel_rfl PRE_first_tail_x15_r0_body.fkt149 : PRE_first_tail_x15_r0_body.kr1_49.targs = Stage.setAll PRE_first_tail_x15_r0_body.krC_49.targs (PRE_first_tail_x15_r0_body.cwS49.filterMap fun i => (PRE_first_tail_x15_r0_body.kr1_49.targs.get i).map (i, ·))
kernel_rfl PRE_first_tail_x15_r0_body.fkck49 : krecLB PRE_first_tail_x15_r0_body.kappa49 2174 PRE_first_tail_x15_r0_body.cx0_49.mlx PRE_first_tail_x15_r0_body.kr0_49 PRE_first_tail_x15_r0_body.kr1_49 PRE_first_tail_x15_r0_body.clo49 = true
kernel_rfl PRE_first_tail_x15_r0_body.fkn49 : Nat.ble 2174 2174 = true
-- the bridge and the pending traces' regions
kernel_rfl PRE_first_tail_x15_r0_body.cbridge49 : Host.Ts.Sim.Full.bridgeOf PRE_first_tail_x15_r0_body.s485.ffi = Host.Ts.Sim.Full.bridgeOf PRE_first_tail_x15_r0_body.s486.ffi
kernel_rfl PRE_first_tail_x15_r0_body.cpendR49 : pendRegB PRE_first_tail_x15_r0_body.kappa49 (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s486.ffi).mlx = true
kernel_rfl PRE_first_tail_x15_r0_body.cpendLe49 : Nat.ble (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s486.ffi).mlx.next (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s485.ffi).mlx.next = true
/-- **The compaction's native shift**, given the call's bookkeeping, its relation's facts (the model's and the
observers') and the canonical closedness. -/
theorem PRE_first_tail_x15_r0_body.cshift49 (clean : Conv.NClean (⟨19176, 16266, 2713619, 2174⟩ : Conv.Cnt) (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s484.ffi).mlx) (hltC : ∀ h, PH (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s484.ffi).mlx h → h < (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s484.ffi).mlx.next) (nltC : ∀ i, PN (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s484.ffi).mlx i → i < (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s484.ffi).mlx.nnext) (itemsC : ∀ k v, (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s484.ffi).mlx.items.get k = some v → PN (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s484.ffi).mlx k) (tracedC : ∀ h o, (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s484.ffi).mlx.objs.get h = some o → ∀ i ∈ objTraces o, i < PRE_first_tail_x15_r0_body.P49.NL) (cl : SSt (· < 2174) PRE_first_tail_x15_r0_body.cx0_49.mlx)
    (hobjC : ∀ h, PRE_first_tail_x15_r0_body.fxC_49.get h = some () → ((Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s484.ffi).mlx.objs.get h).isSome = true)
    (hfC : ∀ h, (PRE_first_tail_x15_r0_body.krC_49.flags.get h).isSome = true → ((Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s484.ffi).mlx.objs.get h).isSome = true)
    (htC : ∀ h, (PRE_first_tail_x15_r0_body.krC_49.targs.get h).isSome = true → ((Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s484.ffi).mlx.objs.get h).isSome = true)
    (hclC : ∀ h l, PRE_first_tail_x15_r0_body.krC_49.targs.get h = some l → Host.Ts.Sim.Full.STargs (· < (⟨19176, 16266, 2713619, 2174⟩ : Conv.Cnt).n) l) :
    Conv.FullShiftQ PRE_first_tail_x15_r0_body.P49 2174 PRE_first_tail_x15_r0_body.kappa49 PRE_first_tail_x15_r0_body.s486.ffi PRE_first_tail_x15_r0_body.s485.ffi :=
  ⟨PRE_first_tail_x15_r0_body.cnshift49 clean hltC nltC itemsC tracedC cl, PRE_first_tail_x15_r0_body.cqueue49, fun t ht => bSN_sound (List.all_eq_true.mp PRE_first_tail_x15_r0_body.ctokSupp49 t ht),
    PRE_first_tail_x15_r0_body.cbridge49,
    liveShift_foot (x0' := Host.Ts.Sim.Full.mlxOf PRE_first_tail_x15_r0_body.s486.ffi) (x1' := Host.Ts.Sim.Full.mlxOf PRE_first_tail_x15_r0_body.s485.ffi) (PRE_first_tail_x15_r0_body.cfoot49 clean hltC nltC itemsC tracedC cl) rfl PRE_first_tail_x15_r0_body.ofx0_49 PRE_first_tail_x15_r0_body.ofx1_49 hobjC PRE_first_tail_x15_r0_body.ff049 PRE_first_tail_x15_r0_body.ff149 PRE_first_tail_x15_r0_body.ffck49,
    kernShift_foot (x0' := Host.Ts.Sim.Full.mlxOf PRE_first_tail_x15_r0_body.s486.ffi) (x1' := Host.Ts.Sim.Full.mlxOf PRE_first_tail_x15_r0_body.s485.ffi) (PRE_first_tail_x15_r0_body.cfoot49 clean hltC nltC itemsC tracedC cl) rfl PRE_first_tail_x15_r0_body.okr0_49 PRE_first_tail_x15_r0_body.okr1_49 (Nat.le_of_ble_eq_true PRE_first_tail_x15_r0_body.fkn49) hfC htC hclC
      PRE_first_tail_x15_r0_body.fkf049 PRE_first_tail_x15_r0_body.fkt049 PRE_first_tail_x15_r0_body.fkf149 PRE_first_tail_x15_r0_body.fkt149 PRE_first_tail_x15_r0_body.fkck49,
    pendReg_of rfl PRE_first_tail_x15_r0_body.cnh049 PRE_first_tail_x15_r0_body.cnh149 (Nat.le_of_ble_eq_true PRE_first_tail_x15_r0_body.cpendLe49) PRE_first_tail_x15_r0_body.cpendR49⟩

end Host.Load.Run.Tpl
end

section -- st49/H0
set_option Elab.async false
namespace Host.Load.Run.Tpl
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
host_stream_state PRE_first_tail_x15_r0_body.st49 0
host_stream_state PRE_first_tail_x15_r0_body.st49 1
host_stream_state PRE_first_tail_x15_r0_body.st49 2
end Host.Load.Run.Tpl
end

section -- Site49
set_option Elab.async false
namespace Host.Load.Run.Tpl
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
open Host.Ts Host.Ts.Sim Host.Ts.Sim.Template

/-! Call site 49 of chain `PRE_first_tail_x15_r0_body`: `rowBlocks__g49__g50` (`rowBlocks`), the call state `PRE_first_tail_x15_r0_body.s484`, the merged state `PRE_first_tail_x15_r0_body.s485`,
the site template `PRE_first_tail_x15_r0_body.st49` (σ = `Map.id`, θ the identity at its own site), the canonical state `PRE_first_tail_x15_r0_body.s486`: the merge.
The footprint's facts are in `SiteF49`, the compaction's in `SiteC49`, `SiteK49`, `SiteNa49`, `SiteNb49`. -/

kernel_rfl PRE_first_tail_x15_r0_body.iso49 : PRE_first_tail_x15_r0_body.st49.s0 = { PRE_first_tail_x15_r0_body.s484 with stack := [] }
/-- The caller's frames at the call. -/
noncomputable def PRE_first_tail_x15_r0_body.rs49 : List Frame := PRE_first_tail_x15_r0_body.s484.stack
kernel_rfl PRE_first_tail_x15_r0_body.n0_49 : PRE_first_tail_x15_r0_body.S484.tab.length = 2174
kernel_rfl PRE_first_tail_x15_r0_body.tab0_49 : PRE_first_tail_x15_r0_body.st49.S0.tab = PRE_first_tail_x15_r0_body.S484.tab

/-- The fresh variables of the stage's results. -/
def PRE_first_tail_x15_r0_body.ws49 : List Nat := [1845, 1846]
kernel_rfl PRE_first_tail_x15_r0_body.fresh49 : (PRE_first_tail_x15_r0_body.S484.tab.all fun e => PRE_first_tail_x15_r0_body.ws49.all fun v => e.noVar v) &&
    (PRE_first_tail_x15_r0_body.S484.oracle.all fun q => PRE_first_tail_x15_r0_body.ws49.all fun v => q.noVar v) = true
kernel_rfl PRE_first_tail_x15_r0_body.mergeTab49 : PRE_first_tail_x15_r0_body.S485.tab = PRE_first_tail_x15_r0_body.S484.tab ++ Conv.resTab PRE_first_tail_x15_r0_body.ws49
kernel_rfl PRE_first_tail_x15_r0_body.mergeLen49 : PRE_first_tail_x15_r0_body.st49.S2.tab.length - PRE_first_tail_x15_r0_body.st49.S0.tab.length = 2

-- The merged state: the instance's return state with the caller's frames (`PRE_first_tail_x15_r0_body.merged49`, `merged_relB`).
kernel_rfl PRE_first_tail_x15_r0_body.mheap49 : PRE_first_tail_x15_r0_body.s485.heap = PRE_first_tail_x15_r0_body.st49.s2.heap
kernel_rfl PRE_first_tail_x15_r0_body.mnext49 : PRE_first_tail_x15_r0_body.s485.next = PRE_first_tail_x15_r0_body.st49.s2.next
kernel_rfl PRE_first_tail_x15_r0_body.mctl49 : PRE_first_tail_x15_r0_body.s485.ctl = PRE_first_tail_x15_r0_body.st49.s2.ctl
kernel_rfl PRE_first_tail_x15_r0_body.mstack49 : PRE_first_tail_x15_r0_body.s485.stack = PRE_first_tail_x15_r0_body.st49.s2.stack ++ PRE_first_tail_x15_r0_body.s484.stack
kernel_rfl PRE_first_tail_x15_r0_body.mjobs49 : PRE_first_tail_x15_r0_body.s485.jobs = PRE_first_tail_x15_r0_body.st49.s2.jobs
kernel_rfl PRE_first_tail_x15_r0_body.mffi49 : PRE_first_tail_x15_r0_body.s485.ffi = PRE_first_tail_x15_r0_body.st49.s2.ffi
kernel_rfl PRE_first_tail_x15_r0_body.mtrace49 : PRE_first_tail_x15_r0_body.s485.trace = PRE_first_tail_x15_r0_body.st49.s2.trace
kernel_rfl PRE_first_tail_x15_r0_body.mstores49 : PRE_first_tail_x15_r0_body.s485.stores = PRE_first_tail_x15_r0_body.st49.s2.stores

end Host.Load.Run.Tpl
end

section -- SiteD49
set_option Elab.async false
namespace Host.Load.Run.Tpl
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
open Host.Ts Host.Ts.Sim Host.Ts.Sim.Template

/-! The canonical results at call site 49 of chain `PRE_first_tail_x15_r0_body`: their values in the instance's end table, the references past
the call's table, the canonical variables apart from the stage's. -/

kernel_rfl PRE_first_tail_x15_r0_body.cderived49 : PRE_first_tail_x15_r0_body.nr49.map (fun r => nth? PRE_first_tail_x15_r0_body.st49.S2.tab r) =
  []
kernel_rfl PRE_first_tail_x15_r0_body.cnrLo49 : PRE_first_tail_x15_r0_body.nr49.all (Nat.ble 2174) = true
kernel_rfl PRE_first_tail_x15_r0_body.cwsDisj49 : PRE_first_tail_x15_r0_body.cws49.all (fun c => !PRE_first_tail_x15_r0_body.ws49.contains c) = true
/-- The compaction's substitution: the canonical variables to their merged values, the stage's other fresh variables
to `0` (`Conv.compactθZ`). -/
noncomputable def PRE_first_tail_x15_r0_body.cthetaZ49 : Nat → SymE := Conv.compactθZ PRE_first_tail_x15_r0_body.cws49 PRE_first_tail_x15_r0_body.crs49 PRE_first_tail_x15_r0_body.ws49

end Host.Load.Run.Tpl
end

section -- st49/Foot
set_option Elab.async false
namespace Host.Load.Run.Tpl
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
open Host.Ts Host.Ts.Sim Host.Ts.Sim.Stage Host.Ts.Sim.Template

/-! The footprint of stage `PRE_first_tail_x15_r0_body.st49`'s site template (`Conv.StageFoot`, `Conv.NFoot`): every entry of the return
state other than the written and fresh ones is the start's (kernel evaluation of the equalities). -/

/-- The written heap ranges below the start's counter. -/
def PRE_first_tail_x15_r0_body.st49.wrR : List (Nat × Nat) := []
/-- The written and fresh entries of the return state. -/
noncomputable def PRE_first_tail_x15_r0_body.st49.wrE : List (Nat × Host.Ts.HObj) :=
  rangesOf PRE_first_tail_x15_r0_body.st49.s2.heap PRE_first_tail_x15_r0_body.st49.wrR ++ freshOf PRE_first_tail_x15_r0_body.st49.s2.heap PRE_first_tail_x15_r0_body.st49.s0.next PRE_first_tail_x15_r0_body.st49.s2.next
noncomputable def PRE_first_tail_x15_r0_body.st49.wr : List Nat := PRE_first_tail_x15_r0_body.st49.wrE.map (·.1)

kernel_rfl PRE_first_tail_x15_r0_body.st49.heapFoot : PRE_first_tail_x15_r0_body.st49.s2.heap = setAll PRE_first_tail_x15_r0_body.st49.s0.heap PRE_first_tail_x15_r0_body.st49.wrE
kernel_rfl PRE_first_tail_x15_r0_body.st49.grows_check : Nat.ble PRE_first_tail_x15_r0_body.st49.s0.next PRE_first_tail_x15_r0_body.st49.s2.next = true
theorem PRE_first_tail_x15_r0_body.st49.grows : PRE_first_tail_x15_r0_body.st49.s0.next ≤ PRE_first_tail_x15_r0_body.st49.s2.next := Nat.le_of_ble_eq_true PRE_first_tail_x15_r0_body.st49.grows_check

/-- The written and fresh handles; the written readback items of old nodes. -/
def PRE_first_tail_x15_r0_body.st49.wh : List Nat := []
def PRE_first_tail_x15_r0_body.st49.wi : List Nat := []

kernel_rfl PRE_first_tail_x15_r0_body.st49.arrsFoot : (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.st49.s2.ffi).mlx.arrs = setAll (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.st49.s0.ffi).mlx.arrs (PRE_first_tail_x15_r0_body.st49.wh.filterMap fun h => ((Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.st49.s2.ffi).mlx.arrs.get h).map (h, ·))
kernel_rfl PRE_first_tail_x15_r0_body.st49.objsFoot : (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.st49.s2.ffi).mlx.objs = setAll (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.st49.s0.ffi).mlx.objs (PRE_first_tail_x15_r0_body.st49.wh.filterMap fun h => ((Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.st49.s2.ffi).mlx.objs.get h).map (h, ·))
kernel_rfl PRE_first_tail_x15_r0_body.st49.nodesFoot : (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.st49.s2.ffi).mlx.nodes = setAll (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.st49.s0.ffi).mlx.nodes (freshOf (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.st49.s2.ffi).mlx.nodes (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.st49.s0.ffi).mlx.nnext (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.st49.s2.ffi).mlx.nnext)
kernel_rfl PRE_first_tail_x15_r0_body.st49.itemsFoot : (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.st49.s2.ffi).mlx.items = setAll (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.st49.s0.ffi).mlx.items ((PRE_first_tail_x15_r0_body.st49.wi.filterMap fun i => ((Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.st49.s2.ffi).mlx.items.get i).map (i, ·)) ++
    freshOf (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.st49.s2.ffi).mlx.items (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.st49.s0.ffi).mlx.nnext (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.st49.s2.ffi).mlx.nnext)
kernel_rfl PRE_first_tail_x15_r0_body.st49.counters : (Nat.ble (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.st49.s0.ffi).mlx.next (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.st49.s2.ffi).mlx.next && Nat.ble (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.st49.s0.ffi).mlx.nnext (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.st49.s2.ffi).mlx.nnext) = true

end Host.Load.Run.Tpl
end

section -- SiteF49
set_option Elab.async false
namespace Host.Load.Run.Tpl
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
open Host.Ts Host.Ts.Sim Host.Ts.Sim.Template

/-! Call site 49 of chain `PRE_first_tail_x15_r0_body`: `Conv.site_merge`'s footprint facts. -/

kernel_rfl PRE_first_tail_x15_r0_body.wrNodupB49 : nodupT PRE_first_tail_x15_r0_body.st49.wr PTrie.nil = true
theorem PRE_first_tail_x15_r0_body.wrNodup49 : PRE_first_tail_x15_r0_body.st49.wr.Nodup := (nodupT_sound PRE_first_tail_x15_r0_body.wrNodupB49).2
kernel_rfl PRE_first_tail_x15_r0_body.wrBoundB49 : PRE_first_tail_x15_r0_body.st49.wr.all (fun b => Nat.blt (b / 4096) (4 ^ 31)) = true
theorem PRE_first_tail_x15_r0_body.wrBound49 : ∀ b ∈ PRE_first_tail_x15_r0_body.st49.wr, b / 4096 < 4 ^ 31 := fun b hb => Nat.blt_eq.mp (List.all_eq_true.mp PRE_first_tail_x15_r0_body.wrBoundB49 b hb)
noncomputable def PRE_first_tail_x15_r0_body.trFr49 := PRE_first_tail_x15_r0_body.st49.s2.trace.take 0
kernel_rfl PRE_first_tail_x15_r0_body.traceEq49 : PRE_first_tail_x15_r0_body.st49.s2.trace = PRE_first_tail_x15_r0_body.trFr49 ++ PRE_first_tail_x15_r0_body.st49.s0.trace
theorem PRE_first_tail_x15_r0_body.trace49 : ∃ fr, PRE_first_tail_x15_r0_body.st49.s2.trace = fr ++ PRE_first_tail_x15_r0_body.st49.s0.trace := ⟨_, PRE_first_tail_x15_r0_body.traceEq49⟩

-- the caller's wide frames at the instance's start (`Conv.isolateW`'s `W0` under `Map.id`) and their `WFix`
def PRE_first_tail_x15_r0_body.wide49 : List (Nat × WFrame) := [(4910, .memo [])]
kernel_rfl PRE_first_tail_x15_r0_body.wfixB49 : (PRE_first_tail_x15_r0_body.wide49.all fun p => wfixB Map.id (presentB PRE_first_tail_x15_r0_body.st49.s0) p.2) = true
theorem PRE_first_tail_x15_r0_body.wfix49 : ∀ p ∈ PRE_first_tail_x15_r0_body.wide49, WFix Map.id (Present PRE_first_tail_x15_r0_body.st49.s0) p.2 :=
  fun p hp => wfix_of (List.all_eq_true.mp PRE_first_tail_x15_r0_body.wfixB49 p hp)

end Host.Load.Run.Tpl
end

section -- SiteL49
set_option Elab.async false
namespace Host.Load.Run.Tpl
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
open Host.Ts Host.Ts.Sim Host.Ts.Sim.Template

/-! The call link's facts at call site 49 of chain `PRE_first_tail_x15_r0_body`: the instance's start server, its footprint (`Conv.StageFoot`), the
merged state `PRE_first_tail_x15_r0_body.s485`'s framed arrays as the chain start's extended (`arrExt_of`, `numRefs_of`). -/

kernel_rfl PRE_first_tail_x15_r0_body.srvO49 : PRE_first_tail_x15_r0_body.st49.S0.oracle = PRE_first_tail_x15_r0_body.st49.OR
kernel_rfl PRE_first_tail_x15_r0_body.wr0B49 : PRE_first_tail_x15_r0_body.st49.wr.all (fun b => !Nat.blt b PRE_first_tail_x15_r0_body.st49.s0.next || (PRE_first_tail_x15_r0_body.st49.s0.heap.get b).isSome) = true
theorem PRE_first_tail_x15_r0_body.stFoot49 : Conv.StageFoot PRE_first_tail_x15_r0_body.st49.wr PRE_first_tail_x15_r0_body.st49.s0 PRE_first_tail_x15_r0_body.st49.s2 :=
  stageFoot_of PRE_first_tail_x15_r0_body.st49.heapFoot PRE_first_tail_x15_r0_body.wrNodup49 PRE_first_tail_x15_r0_body.wrBound49 PRE_first_tail_x15_r0_body.wr0B49 PRE_first_tail_x15_r0_body.st49.grows

/-- **The relation at the merged state** from the relation at the merge (`Conv.site_merge`'s; `merged_relB`). -/
theorem PRE_first_tail_x15_r0_body.merged49 {FR : Map → Nat → PRE_first_tail_x15_r0_body.st49.F.S → PRE_first_tail_x15_r0_body.st49.F.S → Prop} {W : Nat → Option WFrame} {stk : List Frame} {M : Map}
    {ν : Nat → F64} {K : Host.Ts.Sim.Ctx} {S : SSrv} {t : St PRE_first_tail_x15_r0_body.st49.F.S} {C : CSrv} {n0 : Nat}
    (h : RelB PRE_first_tail_x15_r0_body.st49.F FR W stk M ν K (Conv.mergeSt Map.id (Map.id.res n0 n0) PRE_first_tail_x15_r0_body.rs49 PRE_first_tail_x15_r0_body.st49.wr PRE_first_tail_x15_r0_body.s484 PRE_first_tail_x15_r0_body.st49.s2 PRE_first_tail_x15_r0_body.st49.s0
      PRE_first_tail_x15_r0_body.st49.s2.ffi) S t C) : RelB PRE_first_tail_x15_r0_body.st49.F FR W stk M ν K PRE_first_tail_x15_r0_body.s485 S t C :=
  merged_relB PRE_first_tail_x15_r0_body.iso49 PRE_first_tail_x15_r0_body.stFoot49 PRE_first_tail_x15_r0_body.wrNodup49 PRE_first_tail_x15_r0_body.wrBound49 PRE_first_tail_x15_r0_body.trace49 PRE_first_tail_x15_r0_body.mheap49
    PRE_first_tail_x15_r0_body.mnext49 PRE_first_tail_x15_r0_body.mctl49 PRE_first_tail_x15_r0_body.mstack49 PRE_first_tail_x15_r0_body.mjobs49 PRE_first_tail_x15_r0_body.mffi49 PRE_first_tail_x15_r0_body.mtrace49 PRE_first_tail_x15_r0_body.mstores49 h

def PRE_first_tail_x15_r0_body.arrEl49_2665 : List Val := []
kernel_rfl PRE_first_tail_x15_r0_body.arrE49_2665 : arrOf PRE_first_tail_x15_r0_body.s485 2665 = arrOf PRE_first_tail_x15_r0_body.s0 2665 ++ PRE_first_tail_x15_r0_body.arrEl49_2665
kernel_rfl PRE_first_tail_x15_r0_body.arrA49_2665 : isArrB PRE_first_tail_x15_r0_body.s485 2665 = true
theorem PRE_first_tail_x15_r0_body.arr49_2665 : ∃ o, PRE_first_tail_x15_r0_body.s485.heap.get 2665 = some (.obj o) ∧ o.kind = .array (arrOf PRE_first_tail_x15_r0_body.s0 2665 ++ PRE_first_tail_x15_r0_body.arrEl49_2665) :=
  arrExt_of PRE_first_tail_x15_r0_body.arrE49_2665 PRE_first_tail_x15_r0_body.arrA49_2665
kernel_rfl PRE_first_tail_x15_r0_body.arrN49_2665 : numRefsB PRE_first_tail_x15_r0_body.S0.tab.length PRE_first_tail_x15_r0_body.arrEl49_2665 = true
theorem PRE_first_tail_x15_r0_body.arrR49_2665 : Prefill.NumRefs PRE_first_tail_x15_r0_body.S0.tab.length PRE_first_tail_x15_r0_body.arrEl49_2665 := numRefs_of PRE_first_tail_x15_r0_body.arrN49_2665

def PRE_first_tail_x15_r0_body.arrEl49_2673467 : List Val := []
kernel_rfl PRE_first_tail_x15_r0_body.arrE49_2673467 : arrOf PRE_first_tail_x15_r0_body.s485 2673467 = arrOf PRE_first_tail_x15_r0_body.s0 2673467 ++ PRE_first_tail_x15_r0_body.arrEl49_2673467
kernel_rfl PRE_first_tail_x15_r0_body.arrA49_2673467 : isArrB PRE_first_tail_x15_r0_body.s485 2673467 = true
theorem PRE_first_tail_x15_r0_body.arr49_2673467 : ∃ o, PRE_first_tail_x15_r0_body.s485.heap.get 2673467 = some (.obj o) ∧ o.kind = .array (arrOf PRE_first_tail_x15_r0_body.s0 2673467 ++ PRE_first_tail_x15_r0_body.arrEl49_2673467) :=
  arrExt_of PRE_first_tail_x15_r0_body.arrE49_2673467 PRE_first_tail_x15_r0_body.arrA49_2673467
kernel_rfl PRE_first_tail_x15_r0_body.arrN49_2673467 : numRefsB PRE_first_tail_x15_r0_body.S0.tab.length PRE_first_tail_x15_r0_body.arrEl49_2673467 = true
theorem PRE_first_tail_x15_r0_body.arrR49_2673467 : Prefill.NumRefs PRE_first_tail_x15_r0_body.S0.tab.length PRE_first_tail_x15_r0_body.arrEl49_2673467 := numRefs_of PRE_first_tail_x15_r0_body.arrN49_2673467

kernel_rfl PRE_first_tail_x15_r0_body.w4910k49 : isArrB PRE_first_tail_x15_r0_body.s485 4910 = false
theorem PRE_first_tail_x15_r0_body.keep49 (q : List Val) : Host.Ts.Sim.Prefill.KeepsAtW (framesP PRE_first_tail_x15_r0_body.s0 q) PRE_first_tail_x15_r0_body.s485 := by
  intro a pre pre' hx o es ho hk
  unfold framesP at hx
  simp only at hx
  cases h1 : Nat.beq a 2665
  · cases h2 : Nat.beq a 4910
    · rw [h1, h2] at hx; cases hx
    · have := Nat.eq_of_beq_eq_true h2; subst this
      rw [h1, h2] at hx; cases hx
      exact (notArr_of PRE_first_tail_x15_r0_body.w4910k49 ho hk).elim
  · have := Nat.eq_of_beq_eq_true h1; subst this
    rw [h1] at hx; cases hx
    obtain ⟨o', ho', hk'⟩ := PRE_first_tail_x15_r0_body.arr49_2665
    rw [ho] at ho'; cases ho'
    rw [hk'] at hk; cases hk
    simp [PRE_first_tail_x15_r0_body.arrEl49_2665]

end Host.Load.Run.Tpl
end

section -- SiteZ49
set_option Elab.async false
namespace Host.Load.Run.Tpl
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
open Host.Ts Host.Ts.Sim Host.Ts.Sim.Template

/-! The compaction's state shift at call site 49 of chain `PRE_first_tail_x15_r0_body` (`Conv.compact_shift`): the call `PRE_first_tail_x15_r0_body.s484`, the merged
state `PRE_first_tail_x15_r0_body.s485`, the canonical state `PRE_first_tail_x15_r0_body.s486`; its frames [2665,2673467,2673472,2673473] (kept arrays [2665,2673467]). -/

-- the map's places and counters
kernel_rfl PRE_first_tail_x15_r0_body.zpl49 : PRE_first_tail_x15_r0_body.pl49.all (Nat.ble PRE_first_tail_x15_r0_body.s484.next) = true
kernel_rfl PRE_first_tail_x15_r0_body.zplnd49 : nodupT PRE_first_tail_x15_r0_body.pl49 PTrie.nil = true
kernel_rfl PRE_first_tail_x15_r0_body.zn149 : Nat.ble PRE_first_tail_x15_r0_body.s484.next 2713621 = true
kernel_rfl PRE_first_tail_x15_r0_body.zfirst49 : Nat.ble aFirst PRE_first_tail_x15_r0_body.s484.next = true
kernel_rfl PRE_first_tail_x15_r0_body.zscn49 : PRE_first_tail_x15_r0_body.s486.next = PRE_first_tail_x15_r0_body.s484.next + PRE_first_tail_x15_r0_body.pl49.length
kernel_rfl PRE_first_tail_x15_r0_body.zsmn49 : PRE_first_tail_x15_r0_body.s485.next = 2713621
kernel_rfl PRE_first_tail_x15_r0_body.zgrow49 : Nat.ble PRE_first_tail_x15_r0_body.s486.next PRE_first_tail_x15_r0_body.s485.next = true
-- the tables
kernel_rfl PRE_first_tail_x15_r0_body.zfresh49 : PRE_first_tail_x15_r0_body.S484.tab.all (fun e => PRE_first_tail_x15_r0_body.cws49.all fun v => e.noVar v) = true
kernel_rfl PRE_first_tail_x15_r0_body.zcnd49 : nodupT PRE_first_tail_x15_r0_body.cws49 PTrie.nil = true
kernel_rfl PRE_first_tail_x15_r0_body.znrHi49 : PRE_first_tail_x15_r0_body.nr49.all (fun r => Nat.blt r PRE_first_tail_x15_r0_body.S485.tab.length) = true
-- the frames: every framed address below the call's counter; the kept arrays the chain start's, extended in the merged state
kernel_rfl PRE_first_tail_x15_r0_body.zfrlt49 : [2665, 2673467, 2673472, 2673473].all (fun a => Nat.blt a PRE_first_tail_x15_r0_body.s484.next) = true
kernel_rfl PRE_first_tail_x15_r0_body.zg49_2665 : PRE_first_tail_x15_r0_body.s486.heap.get 2665 = some (.obj (objOf PRE_first_tail_x15_r0_body.s486 2665))
kernel_rfl PRE_first_tail_x15_r0_body.zk49_2665 : (objOf PRE_first_tail_x15_r0_body.s486 2665).kind = .array (arrOf PRE_first_tail_x15_r0_body.s0 2665)
kernel_rfl PRE_first_tail_x15_r0_body.zm49_2665 : PRE_first_tail_x15_r0_body.s485.heap.get 2665 = some (.obj { PRE_first_tail_x15_r0_body.kappa49.obj (objOf PRE_first_tail_x15_r0_body.s486 2665) with
  kind := .array (arrOf PRE_first_tail_x15_r0_body.s0 2665 ++ (arrOf PRE_first_tail_x15_r0_body.s485 2665).drop (arrOf PRE_first_tail_x15_r0_body.s0 2665).length) })
kernel_rfl PRE_first_tail_x15_r0_body.zg49_2673467 : PRE_first_tail_x15_r0_body.s486.heap.get 2673467 = some (.obj (objOf PRE_first_tail_x15_r0_body.s486 2673467))
kernel_rfl PRE_first_tail_x15_r0_body.zk49_2673467 : (objOf PRE_first_tail_x15_r0_body.s486 2673467).kind = .array (arrOf PRE_first_tail_x15_r0_body.s0 2673467)
kernel_rfl PRE_first_tail_x15_r0_body.zm49_2673467 : PRE_first_tail_x15_r0_body.s485.heap.get 2673467 = some (.obj { PRE_first_tail_x15_r0_body.kappa49.obj (objOf PRE_first_tail_x15_r0_body.s486 2673467) with
  kind := .array (arrOf PRE_first_tail_x15_r0_body.s0 2673467 ++ (arrOf PRE_first_tail_x15_r0_body.s485 2673467).drop (arrOf PRE_first_tail_x15_r0_body.s0 2673467).length) })
kernel_rfl PRE_first_tail_x15_r0_body.zw49_4910 : (PRE_first_tail_x15_r0_body.s486.heap.get 4910).isSome = true
kernel_rfl PRE_first_tail_x15_r0_body.zw49_2673472 : (PRE_first_tail_x15_r0_body.s486.heap.get 2673472).isSome = true
kernel_rfl PRE_first_tail_x15_r0_body.zw49_2673473 : (PRE_first_tail_x15_r0_body.s486.heap.get 2673473).isSome = true
-- the heap: the changed list in range, holding the stage's written and fresh addresses; the canonical side's image
kernel_rfl PRE_first_tail_x15_r0_body.zclbd49 : PRE_first_tail_x15_r0_body.cl49.all (fun b => Nat.blt (b / 4096) (4 ^ 31)) = true
kernel_rfl PRE_first_tail_x15_r0_body.zwr49 : PRE_first_tail_x15_r0_body.st49.wr.all (fun b => !Nat.blt b PRE_first_tail_x15_r0_body.s484.next || PRE_first_tail_x15_r0_body.cl49.contains b) = true
def PRE_first_tail_x15_r0_body.zl49 : List Nat := PRE_first_tail_x15_r0_body.cl49.filter fun a => !(List.contains [2665, 2673467] a)
kernel_rfl PRE_first_tail_x15_r0_body.zimgE49 : PRE_first_tail_x15_r0_body.zl49.map (fun a => PRE_first_tail_x15_r0_body.s485.heap.get (PRE_first_tail_x15_r0_body.kappa49.a a)) = PRE_first_tail_x15_r0_body.zl49.map (fun a => (PRE_first_tail_x15_r0_body.s486.heap.get a).map PRE_first_tail_x15_r0_body.kappa49.hobj)
theorem PRE_first_tail_x15_r0_body.zimg49 : HeapImg PRE_first_tail_x15_r0_body.kappa49 PRE_first_tail_x15_r0_body.s486 PRE_first_tail_x15_r0_body.s485 PRE_first_tail_x15_r0_body.zl49 := PRE_first_tail_x15_r0_body.zimgE49
-- the roots and their supports
kernel_rfl PRE_first_tail_x15_r0_body.zctl49 : PRE_first_tail_x15_r0_body.s485.ctl = PRE_first_tail_x15_r0_body.kappa49.ctl PRE_first_tail_x15_r0_body.s486.ctl
kernel_rfl PRE_first_tail_x15_r0_body.zstack49 : PRE_first_tail_x15_r0_body.s485.stack = PRE_first_tail_x15_r0_body.s486.stack.map PRE_first_tail_x15_r0_body.kappa49.frame
kernel_rfl PRE_first_tail_x15_r0_body.zjobs49 : PRE_first_tail_x15_r0_body.s485.jobs = PRE_first_tail_x15_r0_body.s486.jobs.map PRE_first_tail_x15_r0_body.kappa49.job
kernel_rfl PRE_first_tail_x15_r0_body.zstores49 : PRE_first_tail_x15_r0_body.s485.stores = PRE_first_tail_x15_r0_body.kappa49.stores PRE_first_tail_x15_r0_body.s486.stores
kernel_rfl PRE_first_tail_x15_r0_body.zroots49 : checkRootsSupp PRE_first_tail_x15_r0_body.s486 2174 = true
kernel_rfl PRE_first_tail_x15_r0_body.znC49 : PRE_first_tail_x15_r0_body.S484.tab.length + PRE_first_tail_x15_r0_body.cws49.length = 2174
-- the map as `Conv.compact_shift` states it (the call's counters for the literals)
kernel_rfl PRE_first_tail_x15_r0_body.zkap49 : PRE_first_tail_x15_r0_body.kappa49 = Conv.Map.compact PRE_first_tail_x15_r0_body.s484.next 2713621 PRE_first_tail_x15_r0_body.S484.tab.length PRE_first_tail_x15_r0_body.pl49 (PRE_first_tail_x15_r0_body.nr49.map NumV.ref) PRE_first_tail_x15_r0_body.kd49.big
  PRE_first_tail_x15_r0_body.kd49.region PRE_first_tail_x15_r0_body.kd49.nodeF
-- the bridge inactive at the canonical state (`Conv.FullShiftQ.toX`; the merged state's bridge is the canonical's: cbridge)
theorem PRE_first_tail_x15_r0_body.zbin49 : (Host.Ts.Sim.Full.bridgeOf PRE_first_tail_x15_r0_body.s486.ffi).active = false := (Host.Load.Boot.replay_active Host.Load.Run.Prompt.P.oblog2818)
-- the JS bookkeeping's step (`Conv.JClean.step` over the changed list) and the canonical roots' bigint freedom
kernel_rfl PRE_first_tail_x15_r0_body.zjc49 : Conv.jcleanListB (⟨19176, 16266, 2713619, 2174⟩ : Conv.Cnt) PRE_first_tail_x15_r0_body.s486 PRE_first_tail_x15_r0_body.cl49 = true
kernel_rfl PRE_first_tail_x15_r0_body.zrootsB49 : noBigRootsP (fun i => !Conv.oldBigB (⟨19176, 16266, 2713619, 2174⟩ : Conv.Cnt) i) PRE_first_tail_x15_r0_body.s486.trace PRE_first_tail_x15_r0_body.s486 = true
kernel_rfl PRE_first_tail_x15_r0_body.zhm49 : Nat.ble (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s0.ffi).mlx.nnext 16266 = true
theorem PRE_first_tail_x15_r0_body.cjcl49 (h : Conv.JClean (⟨19176, 16266, 2713619, 2174⟩ : Conv.Cnt) PRE_first_tail_x15_r0_body.s484) : Conv.JClean (⟨19176, 16266, 2713619, 2174⟩ : Conv.Cnt) PRE_first_tail_x15_r0_body.s486 :=
  Conv.JClean.step h (Conv.Cnt.le_of_leB PRE_first_tail_x15_r0_body.cle49)
    (Conv.heap_off_setAll PRE_first_tail_x15_r0_body.cheap49 fun a ha => Nat.blt_eq.mp (List.all_eq_true.mp PRE_first_tail_x15_r0_body.zclbd49 a ha)) PRE_first_tail_x15_r0_body.zjc49

end Host.Load.Run.Tpl
end

section -- st49/TypedLast
set_option Elab.async false
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
namespace Host.Load.Run.Tpl
open Host.Ts Host.Ts.Sim Host.Ts.Sim.Template

boot_rfl PRE_first_tail_x15_r0_body.st49.bodyLast from PRE_first_tail_x15_r0_body.st49.s1 to PRE_first_tail_x15_r0_body.st49.s2 :
  interpS (step PRE_first_tail_x15_r0_body.st49.F PRE_first_tail_x15_r0_body.st49.s1).run PRE_first_tail_x15_r0_body.st49.S1 = some (PRE_first_tail_x15_r0_body.st49.s2, PRE_first_tail_x15_r0_body.st49.S2)
kernel_rfl PRE_first_tail_x15_r0_body.st49.bodyHalt : isHalt PRE_first_tail_x15_r0_body.st49.s1.ctl = false
kernel_rfl PRE_first_tail_x15_r0_body.st49.bodyTopCheck : noBlockTop PRE_first_tail_x15_r0_body.st49.s2.stack = true

end Host.Load.Run.Tpl
end

section -- st49/TypedOk
set_option Elab.async false
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
namespace Host.Load.Run.Tpl
open Host.Ts Host.Ts.Sim Host.Ts.Sim.Template

noncomputable def PRE_first_tail_x15_r0_body.st49.bodyOkL (bytes : List Byte) (rows : Nat) : St PRE_first_tail_x15_r0_body.st49.F.S → SSrv → Bool :=
  okLocal (Host.Ts.Sim.Compose.VWFrames.bodyOk bytes rows)

noncomputable def PRE_first_tail_x15_r0_body.st49.bodyOkLN (bytes : List Byte) (rows : Nat) : St PRE_first_tail_x15_r0_body.st49.F.S → FSrv → Bool :=
  okLocalN (Host.Ts.Sim.Compose.VWFrames.bodyOkN bytes rows)

theorem PRE_first_tail_x15_r0_body.st49.bodyOkLN_ok (bytes : List Byte) (rows : Nat) (s : St PRE_first_tail_x15_r0_body.st49.F.S) (c : FSrv) (h : c.Wf) :
    PRE_first_tail_x15_r0_body.st49.bodyOkLN bytes rows s c = PRE_first_tail_x15_r0_body.st49.bodyOkL bytes rows s c.toS :=
  okLocalN_ok (Host.Ts.Sim.Compose.VWFrames.bodyOkN_ok bytes rows) s c h

kernel_rfl PRE_first_tail_x15_r0_body.st49.bodyAccepted0 :
  (fun (bytes : List Byte) (rows : Nat) => PRE_first_tail_x15_r0_body.st49.bodyOkL bytes rows PRE_first_tail_x15_r0_body.st49.s0 PRE_first_tail_x15_r0_body.st49.S0) = fun _ _ => true

kernel_rfl PRE_first_tail_x15_r0_body.st49.bodyAccepted1 :
  (fun (bytes : List Byte) (rows : Nat) => PRE_first_tail_x15_r0_body.st49.bodyOkL bytes rows PRE_first_tail_x15_r0_body.st49.s1 PRE_first_tail_x15_r0_body.st49.S1) = fun _ _ => true

end Host.Load.Run.Tpl
end

section -- st49/TypedK0
set_option Elab.async false
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
namespace Host.Load.Run.Tpl
open Host.Ts Host.Ts.Sim Host.Ts.Sim.Template

boot_rfl PRE_first_tail_x15_r0_body.st49.bodyK0F from PRE_first_tail_x15_r0_body.st49.s0 to PRE_first_tail_x15_r0_body.st49.s1 :
  (fun (bytes : List Byte) (rows : Nat) => runOkS PRE_first_tail_x15_r0_body.st49.F (PRE_first_tail_x15_r0_body.st49.bodyOkLN bytes rows)
    ((nth? PRE_first_tail_x15_r0_body.st49.ks 0).getD 0) PRE_first_tail_x15_r0_body.st49.s0 PRE_first_tail_x15_r0_body.st49.S0) = fun _ _ => some (PRE_first_tail_x15_r0_body.st49.s1, PRE_first_tail_x15_r0_body.st49.S1)
theorem PRE_first_tail_x15_r0_body.st49.bodyK0 :
  (fun (bytes : List Byte) (rows : Nat) => runOk PRE_first_tail_x15_r0_body.st49.F (PRE_first_tail_x15_r0_body.st49.bodyOkL bytes rows)
    ((nth? PRE_first_tail_x15_r0_body.st49.ks 0).getD 0) PRE_first_tail_x15_r0_body.st49.s0 PRE_first_tail_x15_r0_body.st49.S0) = fun _ _ => some (PRE_first_tail_x15_r0_body.st49.s1, PRE_first_tail_x15_r0_body.st49.S1) :=
  runOk_fun_of_runOkS PRE_first_tail_x15_r0_body.st49.bodyOkLN_ok PRE_first_tail_x15_r0_body.st49.bodyK0F
end Host.Load.Run.Tpl
end

section -- st49/TypedTpl
set_option Elab.async false
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
namespace Host.Load.Run.Tpl
open Host.Ts Host.Ts.Sim Host.Ts.Sim.Template

theorem PRE_first_tail_x15_r0_body.st49.bodyRun (bytes : List Byte) (rows : Nat) :
    runOk PRE_first_tail_x15_r0_body.st49.F (PRE_first_tail_x15_r0_body.st49.bodyOkL bytes rows) 27 PRE_first_tail_x15_r0_body.st49.s0 PRE_first_tail_x15_r0_body.st49.S0 = some (PRE_first_tail_x15_r0_body.st49.s1, PRE_first_tail_x15_r0_body.st49.S1) :=
  (congrFun (congrFun PRE_first_tail_x15_r0_body.st49.bodyK0 bytes) rows)

theorem PRE_first_tail_x15_r0_body.st49.bodyLocal (bytes : List Byte) (rows : Nat) : ∀ s S, PRE_first_tail_x15_r0_body.st49.bodyOkL bytes rows s S = true → Disp.localB s = true := okLocal_localB

noncomputable def PRE_first_tail_x15_r0_body.st49.bodyTpl (bytes : List Byte) (rows : Nat) : Host.Ts.Sim.Stage.StageTpl PRE_first_tail_x15_r0_body.st49.F (PRE_first_tail_x15_r0_body.st49.bodyOkL bytes rows) where
  s0 := PRE_first_tail_x15_r0_body.st49.s0
  S0 := PRE_first_tail_x15_r0_body.st49.S0
  s1 := PRE_first_tail_x15_r0_body.st49.s1
  S1 := PRE_first_tail_x15_r0_body.st49.S1
  s2 := PRE_first_tail_x15_r0_body.st49.s2
  S2 := PRE_first_tail_x15_r0_body.st49.S2
  n := 27
  ok0 := congrFun (congrFun PRE_first_tail_x15_r0_body.st49.bodyAccepted0 bytes) rows
  run := PRE_first_tail_x15_r0_body.st49.bodyRun bytes rows
  ok1 := congrFun (congrFun PRE_first_tail_x15_r0_body.st49.bodyAccepted1 bytes) rows
  halt := PRE_first_tail_x15_r0_body.st49.bodyHalt
  last := PRE_first_tail_x15_r0_body.st49.bodyLast
  top := noBlockTop_sound PRE_first_tail_x15_r0_body.st49.bodyTopCheck
end Host.Load.Run.Tpl
end

section -- SiteC50
set_option Elab.async false
namespace Host.Load.Run.Tpl
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
open Host.Ts Host.Ts.Sim Host.Ts.Sim.Template

/-! The compaction after the merge at call site 50 of chain `PRE_first_tail_x15_r0_body` (`Conv.compact`, `Conv.full_compactQ`): the canonical
state `PRE_first_tail_x15_r0_body.s490` (the stage's results at canonical places, its trace the call's) under `PRE_first_tail_x15_r0_body.kappa50` into the merged state
`PRE_first_tail_x15_r0_body.s489`. -/

def PRE_first_tail_x15_r0_body.pl50 : List Nat := [2713926]
def PRE_first_tail_x15_r0_body.nr50 : List Nat := []
/-- The native part of the compaction map (canonical → merged handles and nodes: its `big`, `region`, `nodeF`). -/
def PRE_first_tail_x15_r0_body.kd50 : RData :=
  ⟨2713908, 2713927, Stage.setAll PTrie.nil [(2713907, 2713926)], Stage.setAll PTrie.nil [],
   19183, 19183, 16270, 16270, Stage.setAll PTrie.nil [],
   Stage.setAll PTrie.nil []⟩
/-- **The compaction map.** -/
noncomputable def PRE_first_tail_x15_r0_body.kappa50 : Map :=
  Conv.Map.compact 2713907 2713927 2191 PRE_first_tail_x15_r0_body.pl50 (PRE_first_tail_x15_r0_body.nr50.map NumV.ref) PRE_first_tail_x15_r0_body.kd50.big
    PRE_first_tail_x15_r0_body.kd50.region PRE_first_tail_x15_r0_body.kd50.nodeF
/-- The canonical result variables and their images, the merged state's entries (`Conv.compactθ`). -/
def PRE_first_tail_x15_r0_body.cws50 : List Nat := []
noncomputable def PRE_first_tail_x15_r0_body.crs50 : List SymE := PRE_first_tail_x15_r0_body.nr50.map fun r => (nth? PRE_first_tail_x15_r0_body.S489.tab r).getD (.var 0)
noncomputable def PRE_first_tail_x15_r0_body.ctheta50 : Nat → SymE := Conv.compactθ PRE_first_tail_x15_r0_body.cws50 PRE_first_tail_x15_r0_body.crs50
/-- The call's entries the stage wrote (renamed in the canonical state with the results). -/
def PRE_first_tail_x15_r0_body.wrB50 : List Nat := [2665, 2673467]

kernel_rfl PRE_first_tail_x15_r0_body.ctab50 : PRE_first_tail_x15_r0_body.S490.tab = PRE_first_tail_x15_r0_body.S488.tab ++ PRE_first_tail_x15_r0_body.cws50.map SymE.var
kernel_rfl PRE_first_tail_x15_r0_body.ctrace50 : PRE_first_tail_x15_r0_body.s490.trace = PRE_first_tail_x15_r0_body.s488.trace
kernel_rfl PRE_first_tail_x15_r0_body.cnext50 : PRE_first_tail_x15_r0_body.s490.next = 2713908
kernel_rfl PRE_first_tail_x15_r0_body.ccounters50 : ((Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s490.ffi).mlx.next, (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s490.ffi).mlx.nnext) = (19183, 16270)
-- the merged state's readback queue, carried to the canonical state (`Conv.FullShiftQ.tokens`, `tokSupp`)
kernel_rfl PRE_first_tail_x15_r0_body.cqueue50 : (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s489.ffi).mlx.tokens = (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s490.ffi).mlx.tokens.map PRE_first_tail_x15_r0_body.kappa50.nv
kernel_rfl PRE_first_tail_x15_r0_body.ctokSupp50 : (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s490.ffi).mlx.tokens.all (bSN 2191) = true
-- the written and the result entries carry no bigint of the canonical fresh band [next, E) and no fresh region
kernel_rfl PRE_first_tail_x15_r0_body.cclean50 : Conv.cleanListB 19183 131072 (fun r => Nat.ble 76732 r) PRE_first_tail_x15_r0_body.s490
    (PRE_first_tail_x15_r0_body.wrB50 ++ (List.range 1).map (2713907 + ·)) = true
kernel_rfl PRE_first_tail_x15_r0_body.cbigs50 : bigsOutB 19183 131072 (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s490.ffi).mlx = true

end Host.Load.Run.Tpl
end

section -- SiteK50
set_option Elab.async false
namespace Host.Load.Run.Tpl
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
open Host.Ts Host.Ts.Sim Host.Ts.Sim.Template

/-! The canonical state's closedness from the call's (`Conv.closed_of_callB`, `Conv.sst_of_callB`): it keeps the call's entries
off the written and the result ones (`PRE_first_tail_x15_r0_body.cl50`; natively the written and result handles, the result nodes, the written
and result items), and those are checked. -/

def PRE_first_tail_x15_r0_body.cl50 : List Nat := [2665, 2673467, 2713907]
def PRE_first_tail_x15_r0_body.clo50 : List Nat := []
def PRE_first_tail_x15_r0_body.cln50 : List Nat := []
def PRE_first_tail_x15_r0_body.cli50 : List Nat := []
kernel_rfl PRE_first_tail_x15_r0_body.cheap50 : PRE_first_tail_x15_r0_body.s490.heap = Stage.setAll PRE_first_tail_x15_r0_body.s488.heap (PRE_first_tail_x15_r0_body.cl50.filterMap fun a => (PRE_first_tail_x15_r0_body.s490.heap.get a).map (a, ·))
kernel_rfl PRE_first_tail_x15_r0_body.cnextLe50 : Nat.ble PRE_first_tail_x15_r0_body.s488.next PRE_first_tail_x15_r0_body.s490.next = true
kernel_rfl PRE_first_tail_x15_r0_body.ckeepP50 : Conv.keptPresentB PRE_first_tail_x15_r0_body.s488 PRE_first_tail_x15_r0_body.s490 PRE_first_tail_x15_r0_body.cl50 = true
kernel_rfl PRE_first_tail_x15_r0_body.csupp50 : Conv.suppListB PRE_first_tail_x15_r0_body.s490 2191 PRE_first_tail_x15_r0_body.cl50 = true
kernel_rfl PRE_first_tail_x15_r0_body.cbound50 : Conv.boundListB PRE_first_tail_x15_r0_body.s490 PRE_first_tail_x15_r0_body.cl50 = true
kernel_rfl PRE_first_tail_x15_r0_body.cnodesK50 : (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s490.ffi).mlx.nodes = Stage.setAll (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s488.ffi).mlx.nodes (PRE_first_tail_x15_r0_body.cln50.filterMap fun i => ((Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s490.ffi).mlx.nodes.get i).map (i, ·))
kernel_rfl PRE_first_tail_x15_r0_body.cobjsK50 : (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s490.ffi).mlx.objs = Stage.setAll (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s488.ffi).mlx.objs (PRE_first_tail_x15_r0_body.clo50.filterMap fun i => ((Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s490.ffi).mlx.objs.get i).map (i, ·))
kernel_rfl PRE_first_tail_x15_r0_body.citemsK50 : (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s490.ffi).mlx.items = Stage.setAll (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s488.ffi).mlx.items (PRE_first_tail_x15_r0_body.cli50.filterMap fun i => ((Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s490.ffi).mlx.items.get i).map (i, ·))
kernel_rfl PRE_first_tail_x15_r0_body.csst50 : Conv.sstListB 2191 (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s490.ffi).mlx PRE_first_tail_x15_r0_body.cln50 PRE_first_tail_x15_r0_body.clo50 PRE_first_tail_x15_r0_body.cli50 = true

end Host.Load.Run.Tpl
end

section -- SiteCl50
set_option Elab.async false
namespace Host.Load.Run.Tpl
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
open Host.Ts Host.Ts.Sim Host.Ts.Sim.Template

kernel_rfl PRE_first_tail_x15_r0_body.ckA50 : (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s490.ffi).mlx.arrs = Stage.setAll (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s488.ffi).mlx.arrs (PRE_first_tail_x15_r0_body.clo50.filterMap fun i => ((Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s490.ffi).mlx.arrs.get i).map (i, ·))
kernel_rfl PRE_first_tail_x15_r0_body.cbd50 : (PRE_first_tail_x15_r0_body.clo50 ++ PRE_first_tail_x15_r0_body.cln50 ++ PRE_first_tail_x15_r0_body.cli50).all (fun i => Nat.blt (i / 4096) (4 ^ 31)) = true
kernel_rfl PRE_first_tail_x15_r0_body.cle50 : Conv.Cnt.leB (⟨19183, 16270, 2713907, 2191⟩ : Conv.Cnt) (⟨19183, 16270, 2713908, 2191⟩ : Conv.Cnt) = true
kernel_rfl PRE_first_tail_x15_r0_body.cck50 : Conv.ncleanListB (⟨19183, 16270, 2713908, 2191⟩ : Conv.Cnt) (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s490.ffi).mlx PRE_first_tail_x15_r0_body.clo50 PRE_first_tail_x15_r0_body.cln50 PRE_first_tail_x15_r0_body.cli50 = true
theorem PRE_first_tail_x15_r0_body.cncl50 (h : Conv.NClean (⟨19183, 16270, 2713907, 2191⟩ : Conv.Cnt) (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s488.ffi).mlx) : Conv.NClean (⟨19183, 16270, 2713908, 2191⟩ : Conv.Cnt) (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s490.ffi).mlx :=
  Conv.NClean.stepKeep h PRE_first_tail_x15_r0_body.cle50 PRE_first_tail_x15_r0_body.ckA50 PRE_first_tail_x15_r0_body.cobjsK50 PRE_first_tail_x15_r0_body.cnodesK50 PRE_first_tail_x15_r0_body.citemsK50 PRE_first_tail_x15_r0_body.cbd50 PRE_first_tail_x15_r0_body.cck50

end Host.Load.Run.Tpl
end

section -- SiteS50
set_option Elab.async false
namespace Host.Load.Run.Tpl
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
open Host.Ts Host.Ts.Sim Host.Ts.Sim.Template

/-! The compaction's native shift at call site 50 from its footprint (`Conv.nshift_of_foot`), and the observers'
(`liveShift_foot`, `kernShift_foot`): `Conv.FullShiftQ` for `Conv.full_compactQ`, given the call's bookkeeping and its
relation's facts. -/

/-- The load parameters of the chain (band-free: its start's node counter as `NL` and `N0`). -/
def PRE_first_tail_x15_r0_body.Pc50 : LoadP := ⟨18151, 131072, 1099511627776, 15235, 15235, []⟩
/-- The site's band raised to the map's checked fixed-node prefix, including newly recorded closure traces. -/
def PRE_first_tail_x15_r0_body.P50 : LoadP := PRE_first_tail_x15_r0_body.Pc50.raise 16270
kernel_rfl PRE_first_tail_x15_r0_body.craise50 : Nat.ble PRE_first_tail_x15_r0_body.Pc50.N0 16270 = true
theorem PRE_first_tail_x15_r0_body.raised50 : Host.Ts.Sim.Full.Raised PRE_first_tail_x15_r0_body.Pc50 PRE_first_tail_x15_r0_body.P50 :=
  .inr ⟨16270, rfl, Nat.le_of_ble_eq_true PRE_first_tail_x15_r0_body.craise50, rfl⟩
noncomputable abbrev PRE_first_tail_x15_r0_body.cx0_50 : Host.Load.LSt := clearTokens (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s490.ffi)
noncomputable abbrev PRE_first_tail_x15_r0_body.cx1_50 : Host.Load.LSt := clearTokens (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s489.ffi)
def PRE_first_tail_x15_r0_body.khinv50 : PTrie Nat := Stage.setAll PTrie.nil []
def PRE_first_tail_x15_r0_body.kninv50 : PTrie Nat := Stage.setAll PTrie.nil []
/-- The stage's footprint: its written and fresh handles, fresh nodes, written and fresh items. -/
def PRE_first_tail_x15_r0_body.cwS50 : List Nat := []
def PRE_first_tail_x15_r0_body.cnS50 : List Nat := List.range' 16270 0
def PRE_first_tail_x15_r0_body.ciS50 : List Nat := [] ++ List.range' 16270 0

-- the small checks (`MChecks`'s)
kernel_rfl PRE_first_tail_x15_r0_body.cnh050 : PRE_first_tail_x15_r0_body.kd50.nh0 = PRE_first_tail_x15_r0_body.cx0_50.mlx.next
kernel_rfl PRE_first_tail_x15_r0_body.cnh150 : PRE_first_tail_x15_r0_body.kd50.nh1 = PRE_first_tail_x15_r0_body.cx1_50.mlx.next
kernel_rfl PRE_first_tail_x15_r0_body.cnn050 : PRE_first_tail_x15_r0_body.kd50.nn0 = PRE_first_tail_x15_r0_body.cx0_50.mlx.nnext
kernel_rfl PRE_first_tail_x15_r0_body.cnn150 : PRE_first_tail_x15_r0_body.kd50.nn1 = PRE_first_tail_x15_r0_body.cx1_50.mlx.nnext
kernel_rfl PRE_first_tail_x15_r0_body.cplo50 : (Nat.blt 0 PRE_first_tail_x15_r0_body.P50.lo && Nat.ble PRE_first_tail_x15_r0_body.P50.lo PRE_first_tail_x15_r0_body.cx0_50.mlx.next && Nat.ble PRE_first_tail_x15_r0_body.P50.lo RData.bigHi && Nat.ble RData.bigHi PRE_first_tail_x15_r0_body.P50.E) = true
kernel_rfl PRE_first_tail_x15_r0_body.ccnt50 : (Nat.ble PRE_first_tail_x15_r0_body.cx0_50.mlx.next PRE_first_tail_x15_r0_body.cx1_50.mlx.next && Nat.ble PRE_first_tail_x15_r0_body.cx0_50.mlx.nnext PRE_first_tail_x15_r0_body.cx1_50.mlx.nnext) = true
kernel_rfl PRE_first_tail_x15_r0_body.cnband50 : (Nat.blt 0 PRE_first_tail_x15_r0_body.P50.NL && Nat.ble PRE_first_tail_x15_r0_body.P50.NL PRE_first_tail_x15_r0_body.P50.N0 && Nat.ble PRE_first_tail_x15_r0_body.P50.N0 PRE_first_tail_x15_r0_body.cx0_50.mlx.nnext) = true
kernel_rfl PRE_first_tail_x15_r0_body.chbelow50 : PRE_first_tail_x15_r0_body.kd50.checkHndBelow = true
kernel_rfl PRE_first_tail_x15_r0_body.chren50 : checkRenG PRE_first_tail_x15_r0_body.kd50.hnd PRE_first_tail_x15_r0_body.khinv50 (phB PRE_first_tail_x15_r0_body.cx0_50.mlx) = true
kernel_rfl PRE_first_tail_x15_r0_body.cband50 : PRE_first_tail_x15_r0_body.kd50.checkBand PRE_first_tail_x15_r0_body.P50.lo = true
kernel_rfl PRE_first_tail_x15_r0_body.cnh1pos50 : Nat.blt 0 PRE_first_tail_x15_r0_body.kd50.nh1 = true
kernel_rfl PRE_first_tail_x15_r0_body.cnren50 : checkRenG PRE_first_tail_x15_r0_body.kd50.node PRE_first_tail_x15_r0_body.kninv50 (pnB PRE_first_tail_x15_r0_body.cx0_50.mlx) = true
kernel_rfl PRE_first_tail_x15_r0_body.cnlow50 : (PTrie.keysA PRE_first_tail_x15_r0_body.kd50.node).all (fun j => Nat.ble PRE_first_tail_x15_r0_body.P50.NL j && Nat.blt (PRE_first_tail_x15_r0_body.kd50.nodeF j) PRE_first_tail_x15_r0_body.cx1_50.mlx.nnext) = true
kernel_rfl PRE_first_tail_x15_r0_body.cabs0a50 : PRE_first_tail_x15_r0_body.cx0_50.mlx.arrs.get 0 = none
kernel_rfl PRE_first_tail_x15_r0_body.cabs0b50 : PRE_first_tail_x15_r0_body.cx0_50.mlx.objs.get 0 = none
kernel_rfl PRE_first_tail_x15_r0_body.ctok150 : PRE_first_tail_x15_r0_body.cx1_50.mlx.tokens = []
kernel_rfl PRE_first_tail_x15_r0_body.cpend50 : PRE_first_tail_x15_r0_body.cx1_50.mlx.pending = PRE_first_tail_x15_r0_body.cx0_50.mlx.pending.map PRE_first_tail_x15_r0_body.kappa50.pend
kernel_rfl PRE_first_tail_x15_r0_body.cerrh50 : PRE_first_tail_x15_r0_body.cx1_50.mlx.errh = PRE_first_tail_x15_r0_body.cx0_50.mlx.errh.map PRE_first_tail_x15_r0_body.kappa50.arg
kernel_rfl PRE_first_tail_x15_r0_body.cfiles50 : PRE_first_tail_x15_r0_body.cx1_50.mlx.files = PRE_first_tail_x15_r0_body.cx0_50.mlx.files
kernel_rfl PRE_first_tail_x15_r0_body.carch50 : PRE_first_tail_x15_r0_body.cx1_50.mlx.arch = PRE_first_tail_x15_r0_body.cx0_50.mlx.arch
kernel_rfl PRE_first_tail_x15_r0_body.csizes50 : PRE_first_tail_x15_r0_body.cx1_50.mlx.deviceSizes = PRE_first_tail_x15_r0_body.cx0_50.mlx.deviceSizes
kernel_rfl PRE_first_tail_x15_r0_body.cwired50 : PRE_first_tail_x15_r0_body.cx1_50.mlx.wired = PRE_first_tail_x15_r0_body.cx0_50.mlx.wired
kernel_rfl PRE_first_tail_x15_r0_body.chost50 : PRE_first_tail_x15_r0_body.cx1_50.host = PRE_first_tail_x15_r0_body.cx0_50.host
-- the compaction map's addresses are `PRE_first_tail_x15_r0_body.kd50`'s
kernel_rfl PRE_first_tail_x15_r0_body.ckn050 : PRE_first_tail_x15_r0_body.kd50.n0 = 2713908
kernel_rfl PRE_first_tail_x15_r0_body.ckn150 : PRE_first_tail_x15_r0_body.kd50.n1 = 2713927
kernel_rfl PRE_first_tail_x15_r0_body.ckheap50 : (PTrie.keysA PRE_first_tail_x15_r0_body.kd50.heap).all (fun x => Nat.ble 2713907 x) = true
kernel_rfl PRE_first_tail_x15_r0_body.ckpl50 : (List.range 1).all (fun j => decide (PRE_first_tail_x15_r0_body.kd50.heap.get (2713907 + j) = nth? PRE_first_tail_x15_r0_body.pl50 j)) = true
-- the map fixes the call's names (`Conv.fixOld_compact`), the call's counters
kernel_rfl PRE_first_tail_x15_r0_body.fja50 : Nat.ble 2713907 2713907 = true
kernel_rfl PRE_first_tail_x15_r0_body.fn50 : Nat.ble 2191 2191 = true
kernel_rfl PRE_first_tail_x15_r0_body.fjaD50 : Nat.ble 2713907 PRE_first_tail_x15_r0_body.kd50.n0 = true
kernel_rfl PRE_first_tail_x15_r0_body.fxn50 : Nat.ble 19183 PRE_first_tail_x15_r0_body.kd50.nh0 = true
kernel_rfl PRE_first_tail_x15_r0_body.fnn50 : Nat.ble 16270 PRE_first_tail_x15_r0_body.kd50.nn0 = true
kernel_rfl PRE_first_tail_x15_r0_body.fxb50 : Nat.ble 19183 RData.bigHi = true
kernel_rfl PRE_first_tail_x15_r0_body.fheap50 : (PTrie.keysA PRE_first_tail_x15_r0_body.kd50.heap).all (Nat.ble (⟨19183, 16270, 2713907, 2191⟩ : Conv.Cnt).ja) = true
kernel_rfl PRE_first_tail_x15_r0_body.fhnd50 : (PTrie.keysA PRE_first_tail_x15_r0_body.kd50.hnd).all (Nat.ble (⟨19183, 16270, 2713907, 2191⟩ : Conv.Cnt).xn) = true
kernel_rfl PRE_first_tail_x15_r0_body.fnode50 : (PTrie.keysA PRE_first_tail_x15_r0_body.kd50.node).all (Nat.ble (⟨19183, 16270, 2713907, 2191⟩ : Conv.Cnt).nn) = true
/-- The compaction map fixes the call's names. -/
theorem PRE_first_tail_x15_r0_body.cfix50 : Conv.FixOld (⟨19183, 16270, 2713907, 2191⟩ : Conv.Cnt) PRE_first_tail_x15_r0_body.kappa50 :=
  Conv.fixOld_compact (Nat.le_of_ble_eq_true PRE_first_tail_x15_r0_body.fja50) (Nat.le_of_ble_eq_true PRE_first_tail_x15_r0_body.fn50) (Nat.le_of_ble_eq_true PRE_first_tail_x15_r0_body.fjaD50) (Nat.le_of_ble_eq_true PRE_first_tail_x15_r0_body.fxn50) (Nat.le_of_ble_eq_true PRE_first_tail_x15_r0_body.fnn50) (Nat.le_of_ble_eq_true PRE_first_tail_x15_r0_body.fxb50) PRE_first_tail_x15_r0_body.fheap50 PRE_first_tail_x15_r0_body.fhnd50 PRE_first_tail_x15_r0_body.fnode50
kernel_rfl PRE_first_tail_x15_r0_body.fcxn50 : (⟨19183, 16270, 2713907, 2191⟩ : Conv.Cnt).xn = (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s488.ffi).mlx.next
kernel_rfl PRE_first_tail_x15_r0_body.fcnn50 : (⟨19183, 16270, 2713907, 2191⟩ : Conv.Cnt).nn = (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s488.ffi).mlx.nnext
kernel_rfl PRE_first_tail_x15_r0_body.fle050 : (Nat.ble (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s488.ffi).mlx.next PRE_first_tail_x15_r0_body.cx0_50.mlx.next && Nat.ble (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s488.ffi).mlx.nnext PRE_first_tail_x15_r0_body.cx0_50.mlx.nnext && Nat.ble (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s488.ffi).mlx.next RData.bigHi) = true
kernel_rfl PRE_first_tail_x15_r0_body.fnk50 : (PTrie.keysA PRE_first_tail_x15_r0_body.kd50.node).all (Nat.ble (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s488.ffi).mlx.nnext) = true
-- the merged state keeps the call's entries off the stage's footprint
kernel_rfl PRE_first_tail_x15_r0_body.f1A50 : PRE_first_tail_x15_r0_body.cx1_50.mlx.arrs = Stage.setAll (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s488.ffi).mlx.arrs (PRE_first_tail_x15_r0_body.cwS50.filterMap fun i => (PRE_first_tail_x15_r0_body.cx1_50.mlx.arrs.get i).map (i, ·))
kernel_rfl PRE_first_tail_x15_r0_body.f1O50 : PRE_first_tail_x15_r0_body.cx1_50.mlx.objs = Stage.setAll (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s488.ffi).mlx.objs (PRE_first_tail_x15_r0_body.cwS50.filterMap fun i => (PRE_first_tail_x15_r0_body.cx1_50.mlx.objs.get i).map (i, ·))
kernel_rfl PRE_first_tail_x15_r0_body.f1N50 : PRE_first_tail_x15_r0_body.cx1_50.mlx.nodes = Stage.setAll (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s488.ffi).mlx.nodes (PRE_first_tail_x15_r0_body.cnS50.filterMap fun i => (PRE_first_tail_x15_r0_body.cx1_50.mlx.nodes.get i).map (i, ·))
kernel_rfl PRE_first_tail_x15_r0_body.f1I50 : PRE_first_tail_x15_r0_body.cx1_50.mlx.items = Stage.setAll (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s488.ffi).mlx.items (PRE_first_tail_x15_r0_body.ciS50.filterMap fun i => (PRE_first_tail_x15_r0_body.cx1_50.mlx.items.get i).map (i, ·))
kernel_rfl PRE_first_tail_x15_r0_body.fbd50 : (PRE_first_tail_x15_r0_body.clo50 ++ PRE_first_tail_x15_r0_body.cln50 ++ PRE_first_tail_x15_r0_body.cli50 ++ PRE_first_tail_x15_r0_body.cwS50 ++ PRE_first_tail_x15_r0_body.cnS50 ++ PRE_first_tail_x15_r0_body.ciS50).all (fun i => Nat.blt (i / 4096) (4 ^ 31)) = true
kernel_rfl PRE_first_tail_x15_r0_body.fincW50 : PRE_first_tail_x15_r0_body.cwS50.all (fun h => !Nat.blt h (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s488.ffi).mlx.next || PRE_first_tail_x15_r0_body.clo50.contains h) = true
kernel_rfl PRE_first_tail_x15_r0_body.fincI50 : PRE_first_tail_x15_r0_body.ciS50.all (fun k => !Nat.blt k (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s488.ffi).mlx.nnext || PRE_first_tail_x15_r0_body.cli50.contains k) = true
kernel_rfl PRE_first_tail_x15_r0_body.fincN50 : PRE_first_tail_x15_r0_body.cnS50.all (Nat.ble (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s488.ffi).mlx.nnext) = true
kernel_rfl PRE_first_tail_x15_r0_body.flnF50 : PRE_first_tail_x15_r0_body.cln50.all (Nat.ble (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s488.ffi).mlx.nnext) = true
-- the checks over the changed lists
kernel_rfl PRE_first_tail_x15_r0_body.fh50 : PRE_first_tail_x15_r0_body.clo50.all (handleOK PRE_first_tail_x15_r0_body.kappa50 PRE_first_tail_x15_r0_body.P50.lo PRE_first_tail_x15_r0_body.cx0_50.mlx PRE_first_tail_x15_r0_body.cx1_50.mlx) = true
kernel_rfl PRE_first_tail_x15_r0_body.fo50 : PRE_first_tail_x15_r0_body.clo50.map (fun h => PRE_first_tail_x15_r0_body.cx1_50.mlx.objs.get (PRE_first_tail_x15_r0_body.kappa50.handle h)) = PRE_first_tail_x15_r0_body.clo50.map (fun h => (PRE_first_tail_x15_r0_body.cx0_50.mlx.objs.get h).map PRE_first_tail_x15_r0_body.kappa50.nobj)
kernel_rfl PRE_first_tail_x15_r0_body.fok50 : PRE_first_tail_x15_r0_body.clo50.all (objOK PRE_first_tail_x15_r0_body.kappa50 PRE_first_tail_x15_r0_body.P50.NL PRE_first_tail_x15_r0_body.cx0_50.mlx) = true
kernel_rfl PRE_first_tail_x15_r0_body.fnd50 : PRE_first_tail_x15_r0_body.cln50.all (nodeOKF PRE_first_tail_x15_r0_body.kappa50 PRE_first_tail_x15_r0_body.P50 PRE_first_tail_x15_r0_body.cx0_50.mlx PRE_first_tail_x15_r0_body.cx1_50.mlx) = true
kernel_rfl PRE_first_tail_x15_r0_body.fp50 : ((PRE_first_tail_x15_r0_body.cln50.filter (fullB PRE_first_tail_x15_r0_body.P50))).map (fun i => (PRE_first_tail_x15_r0_body.cx1_50.mlx.nodes.get (PRE_first_tail_x15_r0_body.kappa50.node i)).map Host.Mlx.Ffi.Node.prim) =
  ((PRE_first_tail_x15_r0_body.cln50.filter (fullB PRE_first_tail_x15_r0_body.P50))).map (fun i => (PRE_first_tail_x15_r0_body.cx0_50.mlx.nodes.get i).map fun nd => PRE_first_tail_x15_r0_body.kappa50.prim nd.prim)
kernel_rfl PRE_first_tail_x15_r0_body.fnordI50 : incrB PRE_first_tail_x15_r0_body.kd50.nodeF (List.range' 16270 0) = true
kernel_rfl PRE_first_tail_x15_r0_body.fnordK50 : (PTrie.keysA PRE_first_tail_x15_r0_body.kd50.node).all (fun k => Nat.ble 16270 k && Nat.blt k 16270) = true
kernel_rfl PRE_first_tail_x15_r0_body.fnordL50 : (PRE_first_tail_x15_r0_body.cln50.filter (Nat.ble PRE_first_tail_x15_r0_body.P50.N0)).all (fun i => Nat.ble i (PRE_first_tail_x15_r0_body.kd50.nodeF i) && (Nat.blt i 16270 || Nat.ble PRE_first_tail_x15_r0_body.kd50.nn0 i)) = true
theorem PRE_first_tail_x15_r0_body.fnord50 : (PRE_first_tail_x15_r0_body.cln50.filter (Nat.ble PRE_first_tail_x15_r0_body.P50.N0)).all (fun i => Nat.ble i (PRE_first_tail_x15_r0_body.kd50.nodeF i) &&
    (PTrie.keysA PRE_first_tail_x15_r0_body.kd50.node).all fun j => !Nat.blt j i || Nat.blt (PRE_first_tail_x15_r0_body.kd50.nodeF j) (PRE_first_tail_x15_r0_body.kd50.nodeF i)) = true :=
  cnord_of PRE_first_tail_x15_r0_body.cnlow50 PRE_first_tail_x15_r0_body.cnn150 PRE_first_tail_x15_r0_body.fnordI50 PRE_first_tail_x15_r0_body.fnordK50 PRE_first_tail_x15_r0_body.fnordL50
kernel_rfl PRE_first_tail_x15_r0_body.fi50 : PRE_first_tail_x15_r0_body.cli50.all (pnB PRE_first_tail_x15_r0_body.cx0_50.mlx) = true
kernel_rfl PRE_first_tail_x15_r0_body.fii50 : PRE_first_tail_x15_r0_body.cli50.all (fun k => decide (PRE_first_tail_x15_r0_body.cx1_50.mlx.items.get (PRE_first_tail_x15_r0_body.kappa50.node k) = (PRE_first_tail_x15_r0_body.cx0_50.mlx.items.get k).map PRE_first_tail_x15_r0_body.kappa50.nv)) = true
/-- **The compaction's footprint.** -/
theorem PRE_first_tail_x15_r0_body.cfoot50 (clean : Conv.NClean (⟨19183, 16270, 2713907, 2191⟩ : Conv.Cnt) (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s488.ffi).mlx) (hltC : ∀ h, PH (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s488.ffi).mlx h → h < (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s488.ffi).mlx.next) (nltC : ∀ i, PN (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s488.ffi).mlx i → i < (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s488.ffi).mlx.nnext) (itemsC : ∀ k v, (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s488.ffi).mlx.items.get k = some v → PN (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s488.ffi).mlx k) (tracedC : ∀ h o, (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s488.ffi).mlx.objs.get h = some o → ∀ i ∈ objTraces o, i < PRE_first_tail_x15_r0_body.P50.NL) (cl : SSt (· < 2191) PRE_first_tail_x15_r0_body.cx0_50.mlx) :
    Conv.MFoot PRE_first_tail_x15_r0_body.P50 2191 PRE_first_tail_x15_r0_body.kappa50 PRE_first_tail_x15_r0_body.kd50 PRE_first_tail_x15_r0_body.khinv50 PRE_first_tail_x15_r0_body.kninv50 (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s488.ffi).mlx PRE_first_tail_x15_r0_body.cx0_50.mlx PRE_first_tail_x15_r0_body.cx1_50.mlx (⟨19183, 16270, 2713907, 2191⟩ : Conv.Cnt) PRE_first_tail_x15_r0_body.clo50 PRE_first_tail_x15_r0_body.cln50 PRE_first_tail_x15_r0_body.cli50 PRE_first_tail_x15_r0_body.cwS50 PRE_first_tail_x15_r0_body.cnS50 PRE_first_tail_x15_r0_body.ciS50 :=
  ⟨rfl, rfl, rfl, PRE_first_tail_x15_r0_body.cnh050, PRE_first_tail_x15_r0_body.cnh150, PRE_first_tail_x15_r0_body.cnn050, PRE_first_tail_x15_r0_body.cnn150, PRE_first_tail_x15_r0_body.cplo50, PRE_first_tail_x15_r0_body.ccnt50, PRE_first_tail_x15_r0_body.cnband50, PRE_first_tail_x15_r0_body.chbelow50, PRE_first_tail_x15_r0_body.chren50, PRE_first_tail_x15_r0_body.cband50, PRE_first_tail_x15_r0_body.cnh1pos50, PRE_first_tail_x15_r0_body.cnren50, PRE_first_tail_x15_r0_body.cnlow50, PRE_first_tail_x15_r0_body.cabs0a50, PRE_first_tail_x15_r0_body.cabs0b50, PRE_first_tail_x15_r0_body.ctok150, PRE_first_tail_x15_r0_body.cpend50, PRE_first_tail_x15_r0_body.cerrh50, PRE_first_tail_x15_r0_body.cfiles50, PRE_first_tail_x15_r0_body.carch50, PRE_first_tail_x15_r0_body.csizes50, PRE_first_tail_x15_r0_body.cwired50, PRE_first_tail_x15_r0_body.cfix50, clean, PRE_first_tail_x15_r0_body.fcxn50, PRE_first_tail_x15_r0_body.fcnn50, hltC, nltC, itemsC, tracedC, cl, PRE_first_tail_x15_r0_body.fle050, PRE_first_tail_x15_r0_body.fnk50, PRE_first_tail_x15_r0_body.ckA50, PRE_first_tail_x15_r0_body.cobjsK50, PRE_first_tail_x15_r0_body.cnodesK50, PRE_first_tail_x15_r0_body.citemsK50, PRE_first_tail_x15_r0_body.f1A50, PRE_first_tail_x15_r0_body.f1O50, PRE_first_tail_x15_r0_body.f1N50, PRE_first_tail_x15_r0_body.f1I50, PRE_first_tail_x15_r0_body.fbd50, PRE_first_tail_x15_r0_body.fincW50, PRE_first_tail_x15_r0_body.fincI50, PRE_first_tail_x15_r0_body.fincN50, PRE_first_tail_x15_r0_body.flnF50, PRE_first_tail_x15_r0_body.fh50, PRE_first_tail_x15_r0_body.fo50, PRE_first_tail_x15_r0_body.fok50, PRE_first_tail_x15_r0_body.fnd50, PRE_first_tail_x15_r0_body.fp50, PRE_first_tail_x15_r0_body.fnord50, PRE_first_tail_x15_r0_body.fi50, PRE_first_tail_x15_r0_body.fii50⟩
theorem PRE_first_tail_x15_r0_body.cnshift50 (clean : Conv.NClean (⟨19183, 16270, 2713907, 2191⟩ : Conv.Cnt) (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s488.ffi).mlx) (hltC : ∀ h, PH (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s488.ffi).mlx h → h < (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s488.ffi).mlx.next) (nltC : ∀ i, PN (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s488.ffi).mlx i → i < (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s488.ffi).mlx.nnext) (itemsC : ∀ k v, (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s488.ffi).mlx.items.get k = some v → PN (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s488.ffi).mlx k) (tracedC : ∀ h o, (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s488.ffi).mlx.objs.get h = some o → ∀ i ∈ objTraces o, i < PRE_first_tail_x15_r0_body.P50.NL) (cl : SSt (· < 2191) PRE_first_tail_x15_r0_body.cx0_50.mlx) : NShift PRE_first_tail_x15_r0_body.P50 2191 PRE_first_tail_x15_r0_body.kappa50 PRE_first_tail_x15_r0_body.cx0_50 PRE_first_tail_x15_r0_body.cx1_50 :=
  Conv.nshift_of_foot (PRE_first_tail_x15_r0_body.cfoot50 clean hltC nltC itemsC tracedC cl) PRE_first_tail_x15_r0_body.chost50 (compact_a_eq PRE_first_tail_x15_r0_body.ckn050 PRE_first_tail_x15_r0_body.ckn150 PRE_first_tail_x15_r0_body.ckheap50 PRE_first_tail_x15_r0_body.ckpl50)

-- the observers: the layers' states at the call, the canonical and the merged state, their footprints and checks
noncomputable def PRE_first_tail_x15_r0_body.fxC_50 : PTrie Unit := (Host.Ts.Sim.Full.freedOf PRE_first_tail_x15_r0_body.s488.ffi).getD PTrie.nil
noncomputable def PRE_first_tail_x15_r0_body.krC_50 : Host.Load.Layers.KRec := (Host.Ts.Sim.Full.krecOf PRE_first_tail_x15_r0_body.s488.ffi).getD Host.Load.Layers.KRec.empty
kernel_rfl PRE_first_tail_x15_r0_body.ofxC_50 : (Host.Ts.Sim.Full.freedOf PRE_first_tail_x15_r0_body.s488.ffi) = some PRE_first_tail_x15_r0_body.fxC_50
kernel_rfl PRE_first_tail_x15_r0_body.okrC_50 : (Host.Ts.Sim.Full.krecOf PRE_first_tail_x15_r0_body.s488.ffi) = some PRE_first_tail_x15_r0_body.krC_50
noncomputable def PRE_first_tail_x15_r0_body.fx0_50 : PTrie Unit := (Host.Ts.Sim.Full.freedOf PRE_first_tail_x15_r0_body.s490.ffi).getD PTrie.nil
noncomputable def PRE_first_tail_x15_r0_body.kr0_50 : Host.Load.Layers.KRec := (Host.Ts.Sim.Full.krecOf PRE_first_tail_x15_r0_body.s490.ffi).getD Host.Load.Layers.KRec.empty
kernel_rfl PRE_first_tail_x15_r0_body.ofx0_50 : (Host.Ts.Sim.Full.freedOf PRE_first_tail_x15_r0_body.s490.ffi) = some PRE_first_tail_x15_r0_body.fx0_50
kernel_rfl PRE_first_tail_x15_r0_body.okr0_50 : (Host.Ts.Sim.Full.krecOf PRE_first_tail_x15_r0_body.s490.ffi) = some PRE_first_tail_x15_r0_body.kr0_50
noncomputable def PRE_first_tail_x15_r0_body.fx1_50 : PTrie Unit := (Host.Ts.Sim.Full.freedOf PRE_first_tail_x15_r0_body.s489.ffi).getD PTrie.nil
noncomputable def PRE_first_tail_x15_r0_body.kr1_50 : Host.Load.Layers.KRec := (Host.Ts.Sim.Full.krecOf PRE_first_tail_x15_r0_body.s489.ffi).getD Host.Load.Layers.KRec.empty
kernel_rfl PRE_first_tail_x15_r0_body.ofx1_50 : (Host.Ts.Sim.Full.freedOf PRE_first_tail_x15_r0_body.s489.ffi) = some PRE_first_tail_x15_r0_body.fx1_50
kernel_rfl PRE_first_tail_x15_r0_body.okr1_50 : (Host.Ts.Sim.Full.krecOf PRE_first_tail_x15_r0_body.s489.ffi) = some PRE_first_tail_x15_r0_body.kr1_50
kernel_rfl PRE_first_tail_x15_r0_body.ff050 : PRE_first_tail_x15_r0_body.fx0_50 = Stage.setAll PRE_first_tail_x15_r0_body.fxC_50 (PRE_first_tail_x15_r0_body.clo50.filterMap fun i => (PRE_first_tail_x15_r0_body.fx0_50.get i).map (i, ·))
kernel_rfl PRE_first_tail_x15_r0_body.ff150 : PRE_first_tail_x15_r0_body.fx1_50 = Stage.setAll PRE_first_tail_x15_r0_body.fxC_50 (PRE_first_tail_x15_r0_body.cwS50.filterMap fun i => (PRE_first_tail_x15_r0_body.fx1_50.get i).map (i, ·))
kernel_rfl PRE_first_tail_x15_r0_body.ffck50 : freedLB PRE_first_tail_x15_r0_body.kappa50 PRE_first_tail_x15_r0_body.cx0_50.mlx PRE_first_tail_x15_r0_body.fx0_50 PRE_first_tail_x15_r0_body.fx1_50 PRE_first_tail_x15_r0_body.clo50 = true
kernel_rfl PRE_first_tail_x15_r0_body.fkf050 : PRE_first_tail_x15_r0_body.kr0_50.flags = Stage.setAll PRE_first_tail_x15_r0_body.krC_50.flags (PRE_first_tail_x15_r0_body.clo50.filterMap fun i => (PRE_first_tail_x15_r0_body.kr0_50.flags.get i).map (i, ·))
kernel_rfl PRE_first_tail_x15_r0_body.fkt050 : PRE_first_tail_x15_r0_body.kr0_50.targs = Stage.setAll PRE_first_tail_x15_r0_body.krC_50.targs (PRE_first_tail_x15_r0_body.clo50.filterMap fun i => (PRE_first_tail_x15_r0_body.kr0_50.targs.get i).map (i, ·))
kernel_rfl PRE_first_tail_x15_r0_body.fkf150 : PRE_first_tail_x15_r0_body.kr1_50.flags = Stage.setAll PRE_first_tail_x15_r0_body.krC_50.flags (PRE_first_tail_x15_r0_body.cwS50.filterMap fun i => (PRE_first_tail_x15_r0_body.kr1_50.flags.get i).map (i, ·))
kernel_rfl PRE_first_tail_x15_r0_body.fkt150 : PRE_first_tail_x15_r0_body.kr1_50.targs = Stage.setAll PRE_first_tail_x15_r0_body.krC_50.targs (PRE_first_tail_x15_r0_body.cwS50.filterMap fun i => (PRE_first_tail_x15_r0_body.kr1_50.targs.get i).map (i, ·))
kernel_rfl PRE_first_tail_x15_r0_body.fkck50 : krecLB PRE_first_tail_x15_r0_body.kappa50 2191 PRE_first_tail_x15_r0_body.cx0_50.mlx PRE_first_tail_x15_r0_body.kr0_50 PRE_first_tail_x15_r0_body.kr1_50 PRE_first_tail_x15_r0_body.clo50 = true
kernel_rfl PRE_first_tail_x15_r0_body.fkn50 : Nat.ble 2191 2191 = true
-- the bridge and the pending traces' regions
kernel_rfl PRE_first_tail_x15_r0_body.cbridge50 : Host.Ts.Sim.Full.bridgeOf PRE_first_tail_x15_r0_body.s489.ffi = Host.Ts.Sim.Full.bridgeOf PRE_first_tail_x15_r0_body.s490.ffi
kernel_rfl PRE_first_tail_x15_r0_body.cpendR50 : pendRegB PRE_first_tail_x15_r0_body.kappa50 (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s490.ffi).mlx = true
kernel_rfl PRE_first_tail_x15_r0_body.cpendLe50 : Nat.ble (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s490.ffi).mlx.next (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s489.ffi).mlx.next = true
/-- **The compaction's native shift**, given the call's bookkeeping, its relation's facts (the model's and the
observers') and the canonical closedness. -/
theorem PRE_first_tail_x15_r0_body.cshift50 (clean : Conv.NClean (⟨19183, 16270, 2713907, 2191⟩ : Conv.Cnt) (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s488.ffi).mlx) (hltC : ∀ h, PH (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s488.ffi).mlx h → h < (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s488.ffi).mlx.next) (nltC : ∀ i, PN (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s488.ffi).mlx i → i < (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s488.ffi).mlx.nnext) (itemsC : ∀ k v, (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s488.ffi).mlx.items.get k = some v → PN (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s488.ffi).mlx k) (tracedC : ∀ h o, (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s488.ffi).mlx.objs.get h = some o → ∀ i ∈ objTraces o, i < PRE_first_tail_x15_r0_body.P50.NL) (cl : SSt (· < 2191) PRE_first_tail_x15_r0_body.cx0_50.mlx)
    (hobjC : ∀ h, PRE_first_tail_x15_r0_body.fxC_50.get h = some () → ((Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s488.ffi).mlx.objs.get h).isSome = true)
    (hfC : ∀ h, (PRE_first_tail_x15_r0_body.krC_50.flags.get h).isSome = true → ((Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s488.ffi).mlx.objs.get h).isSome = true)
    (htC : ∀ h, (PRE_first_tail_x15_r0_body.krC_50.targs.get h).isSome = true → ((Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s488.ffi).mlx.objs.get h).isSome = true)
    (hclC : ∀ h l, PRE_first_tail_x15_r0_body.krC_50.targs.get h = some l → Host.Ts.Sim.Full.STargs (· < (⟨19183, 16270, 2713907, 2191⟩ : Conv.Cnt).n) l) :
    Conv.FullShiftQ PRE_first_tail_x15_r0_body.P50 2191 PRE_first_tail_x15_r0_body.kappa50 PRE_first_tail_x15_r0_body.s490.ffi PRE_first_tail_x15_r0_body.s489.ffi :=
  ⟨PRE_first_tail_x15_r0_body.cnshift50 clean hltC nltC itemsC tracedC cl, PRE_first_tail_x15_r0_body.cqueue50, fun t ht => bSN_sound (List.all_eq_true.mp PRE_first_tail_x15_r0_body.ctokSupp50 t ht),
    PRE_first_tail_x15_r0_body.cbridge50,
    liveShift_foot (x0' := Host.Ts.Sim.Full.mlxOf PRE_first_tail_x15_r0_body.s490.ffi) (x1' := Host.Ts.Sim.Full.mlxOf PRE_first_tail_x15_r0_body.s489.ffi) (PRE_first_tail_x15_r0_body.cfoot50 clean hltC nltC itemsC tracedC cl) rfl PRE_first_tail_x15_r0_body.ofx0_50 PRE_first_tail_x15_r0_body.ofx1_50 hobjC PRE_first_tail_x15_r0_body.ff050 PRE_first_tail_x15_r0_body.ff150 PRE_first_tail_x15_r0_body.ffck50,
    kernShift_foot (x0' := Host.Ts.Sim.Full.mlxOf PRE_first_tail_x15_r0_body.s490.ffi) (x1' := Host.Ts.Sim.Full.mlxOf PRE_first_tail_x15_r0_body.s489.ffi) (PRE_first_tail_x15_r0_body.cfoot50 clean hltC nltC itemsC tracedC cl) rfl PRE_first_tail_x15_r0_body.okr0_50 PRE_first_tail_x15_r0_body.okr1_50 (Nat.le_of_ble_eq_true PRE_first_tail_x15_r0_body.fkn50) hfC htC hclC
      PRE_first_tail_x15_r0_body.fkf050 PRE_first_tail_x15_r0_body.fkt050 PRE_first_tail_x15_r0_body.fkf150 PRE_first_tail_x15_r0_body.fkt150 PRE_first_tail_x15_r0_body.fkck50,
    pendReg_of rfl PRE_first_tail_x15_r0_body.cnh050 PRE_first_tail_x15_r0_body.cnh150 (Nat.le_of_ble_eq_true PRE_first_tail_x15_r0_body.cpendLe50) PRE_first_tail_x15_r0_body.cpendR50⟩

end Host.Load.Run.Tpl
end

section -- st50/H0
set_option Elab.async false
namespace Host.Load.Run.Tpl
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
host_stream_state PRE_first_tail_x15_r0_body.st50 0
host_stream_state PRE_first_tail_x15_r0_body.st50 1
host_stream_state PRE_first_tail_x15_r0_body.st50 2
end Host.Load.Run.Tpl
end

section -- Site50
set_option Elab.async false
namespace Host.Load.Run.Tpl
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
open Host.Ts Host.Ts.Sim Host.Ts.Sim.Template

/-! Call site 50 of chain `PRE_first_tail_x15_r0_body`: `plan__g50__g51` (`plan`), the call state `PRE_first_tail_x15_r0_body.s488`, the merged state `PRE_first_tail_x15_r0_body.s489`,
the site template `PRE_first_tail_x15_r0_body.st50` (σ = `Map.id`, θ the identity at its own site), the canonical state `PRE_first_tail_x15_r0_body.s490`: the merge.
The footprint's facts are in `SiteF50`, the compaction's in `SiteC50`, `SiteK50`, `SiteNa50`, `SiteNb50`. -/

kernel_rfl PRE_first_tail_x15_r0_body.iso50 : PRE_first_tail_x15_r0_body.st50.s0 = { PRE_first_tail_x15_r0_body.s488 with stack := [] }
/-- The caller's frames at the call. -/
noncomputable def PRE_first_tail_x15_r0_body.rs50 : List Frame := PRE_first_tail_x15_r0_body.s488.stack
kernel_rfl PRE_first_tail_x15_r0_body.n0_50 : PRE_first_tail_x15_r0_body.S488.tab.length = 2191
kernel_rfl PRE_first_tail_x15_r0_body.tab0_50 : PRE_first_tail_x15_r0_body.st50.S0.tab = PRE_first_tail_x15_r0_body.S488.tab

/-- The fresh variables of the stage's results. -/
def PRE_first_tail_x15_r0_body.ws50 : List Nat := [1847, 1848, 1849, 1850, 1851, 1852, 1853, 1854, 1855]
kernel_rfl PRE_first_tail_x15_r0_body.fresh50 : (PRE_first_tail_x15_r0_body.S488.tab.all fun e => PRE_first_tail_x15_r0_body.ws50.all fun v => e.noVar v) &&
    (PRE_first_tail_x15_r0_body.S488.oracle.all fun q => PRE_first_tail_x15_r0_body.ws50.all fun v => q.noVar v) = true
kernel_rfl PRE_first_tail_x15_r0_body.mergeTab50 : PRE_first_tail_x15_r0_body.S489.tab = PRE_first_tail_x15_r0_body.S488.tab ++ Conv.resTab PRE_first_tail_x15_r0_body.ws50
kernel_rfl PRE_first_tail_x15_r0_body.mergeLen50 : PRE_first_tail_x15_r0_body.st50.S2.tab.length - PRE_first_tail_x15_r0_body.st50.S0.tab.length = 9

-- The merged state: the instance's return state with the caller's frames (`PRE_first_tail_x15_r0_body.merged50`, `merged_relB`).
kernel_rfl PRE_first_tail_x15_r0_body.mheap50 : PRE_first_tail_x15_r0_body.s489.heap = PRE_first_tail_x15_r0_body.st50.s2.heap
kernel_rfl PRE_first_tail_x15_r0_body.mnext50 : PRE_first_tail_x15_r0_body.s489.next = PRE_first_tail_x15_r0_body.st50.s2.next
kernel_rfl PRE_first_tail_x15_r0_body.mctl50 : PRE_first_tail_x15_r0_body.s489.ctl = PRE_first_tail_x15_r0_body.st50.s2.ctl
kernel_rfl PRE_first_tail_x15_r0_body.mstack50 : PRE_first_tail_x15_r0_body.s489.stack = PRE_first_tail_x15_r0_body.st50.s2.stack ++ PRE_first_tail_x15_r0_body.s488.stack
kernel_rfl PRE_first_tail_x15_r0_body.mjobs50 : PRE_first_tail_x15_r0_body.s489.jobs = PRE_first_tail_x15_r0_body.st50.s2.jobs
kernel_rfl PRE_first_tail_x15_r0_body.mffi50 : PRE_first_tail_x15_r0_body.s489.ffi = PRE_first_tail_x15_r0_body.st50.s2.ffi
kernel_rfl PRE_first_tail_x15_r0_body.mtrace50 : PRE_first_tail_x15_r0_body.s489.trace = PRE_first_tail_x15_r0_body.st50.s2.trace
kernel_rfl PRE_first_tail_x15_r0_body.mstores50 : PRE_first_tail_x15_r0_body.s489.stores = PRE_first_tail_x15_r0_body.st50.s2.stores

end Host.Load.Run.Tpl
end

section -- SiteD50
set_option Elab.async false
namespace Host.Load.Run.Tpl
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
open Host.Ts Host.Ts.Sim Host.Ts.Sim.Template

/-! The canonical results at call site 50 of chain `PRE_first_tail_x15_r0_body`: their values in the instance's end table, the references past
the call's table, the canonical variables apart from the stage's. -/

kernel_rfl PRE_first_tail_x15_r0_body.cderived50 : PRE_first_tail_x15_r0_body.nr50.map (fun r => nth? PRE_first_tail_x15_r0_body.st50.S2.tab r) =
  []
kernel_rfl PRE_first_tail_x15_r0_body.cnrLo50 : PRE_first_tail_x15_r0_body.nr50.all (Nat.ble 2191) = true
kernel_rfl PRE_first_tail_x15_r0_body.cwsDisj50 : PRE_first_tail_x15_r0_body.cws50.all (fun c => !PRE_first_tail_x15_r0_body.ws50.contains c) = true
/-- The compaction's substitution: the canonical variables to their merged values, the stage's other fresh variables
to `0` (`Conv.compactθZ`). -/
noncomputable def PRE_first_tail_x15_r0_body.cthetaZ50 : Nat → SymE := Conv.compactθZ PRE_first_tail_x15_r0_body.cws50 PRE_first_tail_x15_r0_body.crs50 PRE_first_tail_x15_r0_body.ws50

end Host.Load.Run.Tpl
end

section -- st50/Foot
set_option Elab.async false
namespace Host.Load.Run.Tpl
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
open Host.Ts Host.Ts.Sim Host.Ts.Sim.Stage Host.Ts.Sim.Template

/-! The footprint of stage `PRE_first_tail_x15_r0_body.st50`'s site template (`Conv.StageFoot`, `Conv.NFoot`): every entry of the return
state other than the written and fresh ones is the start's (kernel evaluation of the equalities). -/

/-- The written heap ranges below the start's counter. -/
def PRE_first_tail_x15_r0_body.st50.wrR : List (Nat × Nat) := []
/-- The written and fresh entries of the return state. -/
noncomputable def PRE_first_tail_x15_r0_body.st50.wrE : List (Nat × Host.Ts.HObj) :=
  rangesOf PRE_first_tail_x15_r0_body.st50.s2.heap PRE_first_tail_x15_r0_body.st50.wrR ++ freshOf PRE_first_tail_x15_r0_body.st50.s2.heap PRE_first_tail_x15_r0_body.st50.s0.next PRE_first_tail_x15_r0_body.st50.s2.next
noncomputable def PRE_first_tail_x15_r0_body.st50.wr : List Nat := PRE_first_tail_x15_r0_body.st50.wrE.map (·.1)

kernel_rfl PRE_first_tail_x15_r0_body.st50.heapFoot : PRE_first_tail_x15_r0_body.st50.s2.heap = setAll PRE_first_tail_x15_r0_body.st50.s0.heap PRE_first_tail_x15_r0_body.st50.wrE
kernel_rfl PRE_first_tail_x15_r0_body.st50.grows_check : Nat.ble PRE_first_tail_x15_r0_body.st50.s0.next PRE_first_tail_x15_r0_body.st50.s2.next = true
theorem PRE_first_tail_x15_r0_body.st50.grows : PRE_first_tail_x15_r0_body.st50.s0.next ≤ PRE_first_tail_x15_r0_body.st50.s2.next := Nat.le_of_ble_eq_true PRE_first_tail_x15_r0_body.st50.grows_check

/-- The written and fresh handles; the written readback items of old nodes. -/
def PRE_first_tail_x15_r0_body.st50.wh : List Nat := []
def PRE_first_tail_x15_r0_body.st50.wi : List Nat := []

kernel_rfl PRE_first_tail_x15_r0_body.st50.arrsFoot : (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.st50.s2.ffi).mlx.arrs = setAll (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.st50.s0.ffi).mlx.arrs (PRE_first_tail_x15_r0_body.st50.wh.filterMap fun h => ((Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.st50.s2.ffi).mlx.arrs.get h).map (h, ·))
kernel_rfl PRE_first_tail_x15_r0_body.st50.objsFoot : (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.st50.s2.ffi).mlx.objs = setAll (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.st50.s0.ffi).mlx.objs (PRE_first_tail_x15_r0_body.st50.wh.filterMap fun h => ((Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.st50.s2.ffi).mlx.objs.get h).map (h, ·))
kernel_rfl PRE_first_tail_x15_r0_body.st50.nodesFoot : (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.st50.s2.ffi).mlx.nodes = setAll (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.st50.s0.ffi).mlx.nodes (freshOf (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.st50.s2.ffi).mlx.nodes (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.st50.s0.ffi).mlx.nnext (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.st50.s2.ffi).mlx.nnext)
kernel_rfl PRE_first_tail_x15_r0_body.st50.itemsFoot : (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.st50.s2.ffi).mlx.items = setAll (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.st50.s0.ffi).mlx.items ((PRE_first_tail_x15_r0_body.st50.wi.filterMap fun i => ((Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.st50.s2.ffi).mlx.items.get i).map (i, ·)) ++
    freshOf (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.st50.s2.ffi).mlx.items (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.st50.s0.ffi).mlx.nnext (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.st50.s2.ffi).mlx.nnext)
kernel_rfl PRE_first_tail_x15_r0_body.st50.counters : (Nat.ble (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.st50.s0.ffi).mlx.next (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.st50.s2.ffi).mlx.next && Nat.ble (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.st50.s0.ffi).mlx.nnext (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.st50.s2.ffi).mlx.nnext) = true

end Host.Load.Run.Tpl
end

section -- SiteF50
set_option Elab.async false
namespace Host.Load.Run.Tpl
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
open Host.Ts Host.Ts.Sim Host.Ts.Sim.Template

/-! Call site 50 of chain `PRE_first_tail_x15_r0_body`: `Conv.site_merge`'s footprint facts. -/

kernel_rfl PRE_first_tail_x15_r0_body.wrNodupB50 : nodupT PRE_first_tail_x15_r0_body.st50.wr PTrie.nil = true
theorem PRE_first_tail_x15_r0_body.wrNodup50 : PRE_first_tail_x15_r0_body.st50.wr.Nodup := (nodupT_sound PRE_first_tail_x15_r0_body.wrNodupB50).2
kernel_rfl PRE_first_tail_x15_r0_body.wrBoundB50 : PRE_first_tail_x15_r0_body.st50.wr.all (fun b => Nat.blt (b / 4096) (4 ^ 31)) = true
theorem PRE_first_tail_x15_r0_body.wrBound50 : ∀ b ∈ PRE_first_tail_x15_r0_body.st50.wr, b / 4096 < 4 ^ 31 := fun b hb => Nat.blt_eq.mp (List.all_eq_true.mp PRE_first_tail_x15_r0_body.wrBoundB50 b hb)
noncomputable def PRE_first_tail_x15_r0_body.trFr50 := PRE_first_tail_x15_r0_body.st50.s2.trace.take 0
kernel_rfl PRE_first_tail_x15_r0_body.traceEq50 : PRE_first_tail_x15_r0_body.st50.s2.trace = PRE_first_tail_x15_r0_body.trFr50 ++ PRE_first_tail_x15_r0_body.st50.s0.trace
theorem PRE_first_tail_x15_r0_body.trace50 : ∃ fr, PRE_first_tail_x15_r0_body.st50.s2.trace = fr ++ PRE_first_tail_x15_r0_body.st50.s0.trace := ⟨_, PRE_first_tail_x15_r0_body.traceEq50⟩

-- the caller's wide frames at the instance's start (`Conv.isolateW`'s `W0` under `Map.id`) and their `WFix`
def PRE_first_tail_x15_r0_body.wide50 : List (Nat × WFrame) := [(4910, .memo [])]
kernel_rfl PRE_first_tail_x15_r0_body.wfixB50 : (PRE_first_tail_x15_r0_body.wide50.all fun p => wfixB Map.id (presentB PRE_first_tail_x15_r0_body.st50.s0) p.2) = true
theorem PRE_first_tail_x15_r0_body.wfix50 : ∀ p ∈ PRE_first_tail_x15_r0_body.wide50, WFix Map.id (Present PRE_first_tail_x15_r0_body.st50.s0) p.2 :=
  fun p hp => wfix_of (List.all_eq_true.mp PRE_first_tail_x15_r0_body.wfixB50 p hp)

end Host.Load.Run.Tpl
end

section -- SiteL50
set_option Elab.async false
namespace Host.Load.Run.Tpl
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
open Host.Ts Host.Ts.Sim Host.Ts.Sim.Template

/-! The call link's facts at call site 50 of chain `PRE_first_tail_x15_r0_body`: the instance's start server, its footprint (`Conv.StageFoot`), the
merged state `PRE_first_tail_x15_r0_body.s489`'s framed arrays as the chain start's extended (`arrExt_of`, `numRefs_of`). -/

kernel_rfl PRE_first_tail_x15_r0_body.srvO50 : PRE_first_tail_x15_r0_body.st50.S0.oracle = PRE_first_tail_x15_r0_body.st50.OR
kernel_rfl PRE_first_tail_x15_r0_body.wr0B50 : PRE_first_tail_x15_r0_body.st50.wr.all (fun b => !Nat.blt b PRE_first_tail_x15_r0_body.st50.s0.next || (PRE_first_tail_x15_r0_body.st50.s0.heap.get b).isSome) = true
theorem PRE_first_tail_x15_r0_body.stFoot50 : Conv.StageFoot PRE_first_tail_x15_r0_body.st50.wr PRE_first_tail_x15_r0_body.st50.s0 PRE_first_tail_x15_r0_body.st50.s2 :=
  stageFoot_of PRE_first_tail_x15_r0_body.st50.heapFoot PRE_first_tail_x15_r0_body.wrNodup50 PRE_first_tail_x15_r0_body.wrBound50 PRE_first_tail_x15_r0_body.wr0B50 PRE_first_tail_x15_r0_body.st50.grows

/-- **The relation at the merged state** from the relation at the merge (`Conv.site_merge`'s; `merged_relB`). -/
theorem PRE_first_tail_x15_r0_body.merged50 {FR : Map → Nat → PRE_first_tail_x15_r0_body.st50.F.S → PRE_first_tail_x15_r0_body.st50.F.S → Prop} {W : Nat → Option WFrame} {stk : List Frame} {M : Map}
    {ν : Nat → F64} {K : Host.Ts.Sim.Ctx} {S : SSrv} {t : St PRE_first_tail_x15_r0_body.st50.F.S} {C : CSrv} {n0 : Nat}
    (h : RelB PRE_first_tail_x15_r0_body.st50.F FR W stk M ν K (Conv.mergeSt Map.id (Map.id.res n0 n0) PRE_first_tail_x15_r0_body.rs50 PRE_first_tail_x15_r0_body.st50.wr PRE_first_tail_x15_r0_body.s488 PRE_first_tail_x15_r0_body.st50.s2 PRE_first_tail_x15_r0_body.st50.s0
      PRE_first_tail_x15_r0_body.st50.s2.ffi) S t C) : RelB PRE_first_tail_x15_r0_body.st50.F FR W stk M ν K PRE_first_tail_x15_r0_body.s489 S t C :=
  merged_relB PRE_first_tail_x15_r0_body.iso50 PRE_first_tail_x15_r0_body.stFoot50 PRE_first_tail_x15_r0_body.wrNodup50 PRE_first_tail_x15_r0_body.wrBound50 PRE_first_tail_x15_r0_body.trace50 PRE_first_tail_x15_r0_body.mheap50
    PRE_first_tail_x15_r0_body.mnext50 PRE_first_tail_x15_r0_body.mctl50 PRE_first_tail_x15_r0_body.mstack50 PRE_first_tail_x15_r0_body.mjobs50 PRE_first_tail_x15_r0_body.mffi50 PRE_first_tail_x15_r0_body.mtrace50 PRE_first_tail_x15_r0_body.mstores50 h

def PRE_first_tail_x15_r0_body.arrEl50_2665 : List Val := []
kernel_rfl PRE_first_tail_x15_r0_body.arrE50_2665 : arrOf PRE_first_tail_x15_r0_body.s489 2665 = arrOf PRE_first_tail_x15_r0_body.s0 2665 ++ PRE_first_tail_x15_r0_body.arrEl50_2665
kernel_rfl PRE_first_tail_x15_r0_body.arrA50_2665 : isArrB PRE_first_tail_x15_r0_body.s489 2665 = true
theorem PRE_first_tail_x15_r0_body.arr50_2665 : ∃ o, PRE_first_tail_x15_r0_body.s489.heap.get 2665 = some (.obj o) ∧ o.kind = .array (arrOf PRE_first_tail_x15_r0_body.s0 2665 ++ PRE_first_tail_x15_r0_body.arrEl50_2665) :=
  arrExt_of PRE_first_tail_x15_r0_body.arrE50_2665 PRE_first_tail_x15_r0_body.arrA50_2665
kernel_rfl PRE_first_tail_x15_r0_body.arrN50_2665 : numRefsB PRE_first_tail_x15_r0_body.S0.tab.length PRE_first_tail_x15_r0_body.arrEl50_2665 = true
theorem PRE_first_tail_x15_r0_body.arrR50_2665 : Prefill.NumRefs PRE_first_tail_x15_r0_body.S0.tab.length PRE_first_tail_x15_r0_body.arrEl50_2665 := numRefs_of PRE_first_tail_x15_r0_body.arrN50_2665

def PRE_first_tail_x15_r0_body.arrEl50_2673467 : List Val := []
kernel_rfl PRE_first_tail_x15_r0_body.arrE50_2673467 : arrOf PRE_first_tail_x15_r0_body.s489 2673467 = arrOf PRE_first_tail_x15_r0_body.s0 2673467 ++ PRE_first_tail_x15_r0_body.arrEl50_2673467
kernel_rfl PRE_first_tail_x15_r0_body.arrA50_2673467 : isArrB PRE_first_tail_x15_r0_body.s489 2673467 = true
theorem PRE_first_tail_x15_r0_body.arr50_2673467 : ∃ o, PRE_first_tail_x15_r0_body.s489.heap.get 2673467 = some (.obj o) ∧ o.kind = .array (arrOf PRE_first_tail_x15_r0_body.s0 2673467 ++ PRE_first_tail_x15_r0_body.arrEl50_2673467) :=
  arrExt_of PRE_first_tail_x15_r0_body.arrE50_2673467 PRE_first_tail_x15_r0_body.arrA50_2673467
kernel_rfl PRE_first_tail_x15_r0_body.arrN50_2673467 : numRefsB PRE_first_tail_x15_r0_body.S0.tab.length PRE_first_tail_x15_r0_body.arrEl50_2673467 = true
theorem PRE_first_tail_x15_r0_body.arrR50_2673467 : Prefill.NumRefs PRE_first_tail_x15_r0_body.S0.tab.length PRE_first_tail_x15_r0_body.arrEl50_2673467 := numRefs_of PRE_first_tail_x15_r0_body.arrN50_2673467

kernel_rfl PRE_first_tail_x15_r0_body.w4910k50 : isArrB PRE_first_tail_x15_r0_body.s489 4910 = false
theorem PRE_first_tail_x15_r0_body.keep50 (q : List Val) : Host.Ts.Sim.Prefill.KeepsAtW (framesP PRE_first_tail_x15_r0_body.s0 q) PRE_first_tail_x15_r0_body.s489 := by
  intro a pre pre' hx o es ho hk
  unfold framesP at hx
  simp only at hx
  cases h1 : Nat.beq a 2665
  · cases h2 : Nat.beq a 4910
    · rw [h1, h2] at hx; cases hx
    · have := Nat.eq_of_beq_eq_true h2; subst this
      rw [h1, h2] at hx; cases hx
      exact (notArr_of PRE_first_tail_x15_r0_body.w4910k50 ho hk).elim
  · have := Nat.eq_of_beq_eq_true h1; subst this
    rw [h1] at hx; cases hx
    obtain ⟨o', ho', hk'⟩ := PRE_first_tail_x15_r0_body.arr50_2665
    rw [ho] at ho'; cases ho'
    rw [hk'] at hk; cases hk
    simp [PRE_first_tail_x15_r0_body.arrEl50_2665]

end Host.Load.Run.Tpl
end

section -- SiteZ50
set_option Elab.async false
namespace Host.Load.Run.Tpl
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
open Host.Ts Host.Ts.Sim Host.Ts.Sim.Template

/-! The compaction's state shift at call site 50 of chain `PRE_first_tail_x15_r0_body` (`Conv.compact_shift`): the call `PRE_first_tail_x15_r0_body.s488`, the merged
state `PRE_first_tail_x15_r0_body.s489`, the canonical state `PRE_first_tail_x15_r0_body.s490`; its frames [2665,2673467,2673472,2673473] (kept arrays [2665,2673467]). -/

-- the map's places and counters
kernel_rfl PRE_first_tail_x15_r0_body.zpl50 : PRE_first_tail_x15_r0_body.pl50.all (Nat.ble PRE_first_tail_x15_r0_body.s488.next) = true
kernel_rfl PRE_first_tail_x15_r0_body.zplnd50 : nodupT PRE_first_tail_x15_r0_body.pl50 PTrie.nil = true
kernel_rfl PRE_first_tail_x15_r0_body.zn150 : Nat.ble PRE_first_tail_x15_r0_body.s488.next 2713927 = true
kernel_rfl PRE_first_tail_x15_r0_body.zfirst50 : Nat.ble aFirst PRE_first_tail_x15_r0_body.s488.next = true
kernel_rfl PRE_first_tail_x15_r0_body.zscn50 : PRE_first_tail_x15_r0_body.s490.next = PRE_first_tail_x15_r0_body.s488.next + PRE_first_tail_x15_r0_body.pl50.length
kernel_rfl PRE_first_tail_x15_r0_body.zsmn50 : PRE_first_tail_x15_r0_body.s489.next = 2713927
kernel_rfl PRE_first_tail_x15_r0_body.zgrow50 : Nat.ble PRE_first_tail_x15_r0_body.s490.next PRE_first_tail_x15_r0_body.s489.next = true
-- the tables
kernel_rfl PRE_first_tail_x15_r0_body.zfresh50 : PRE_first_tail_x15_r0_body.S488.tab.all (fun e => PRE_first_tail_x15_r0_body.cws50.all fun v => e.noVar v) = true
kernel_rfl PRE_first_tail_x15_r0_body.zcnd50 : nodupT PRE_first_tail_x15_r0_body.cws50 PTrie.nil = true
kernel_rfl PRE_first_tail_x15_r0_body.znrHi50 : PRE_first_tail_x15_r0_body.nr50.all (fun r => Nat.blt r PRE_first_tail_x15_r0_body.S489.tab.length) = true
-- the frames: every framed address below the call's counter; the kept arrays the chain start's, extended in the merged state
kernel_rfl PRE_first_tail_x15_r0_body.zfrlt50 : [2665, 2673467, 2673472, 2673473].all (fun a => Nat.blt a PRE_first_tail_x15_r0_body.s488.next) = true
kernel_rfl PRE_first_tail_x15_r0_body.zg50_2665 : PRE_first_tail_x15_r0_body.s490.heap.get 2665 = some (.obj (objOf PRE_first_tail_x15_r0_body.s490 2665))
kernel_rfl PRE_first_tail_x15_r0_body.zk50_2665 : (objOf PRE_first_tail_x15_r0_body.s490 2665).kind = .array (arrOf PRE_first_tail_x15_r0_body.s0 2665)
kernel_rfl PRE_first_tail_x15_r0_body.zm50_2665 : PRE_first_tail_x15_r0_body.s489.heap.get 2665 = some (.obj { PRE_first_tail_x15_r0_body.kappa50.obj (objOf PRE_first_tail_x15_r0_body.s490 2665) with
  kind := .array (arrOf PRE_first_tail_x15_r0_body.s0 2665 ++ (arrOf PRE_first_tail_x15_r0_body.s489 2665).drop (arrOf PRE_first_tail_x15_r0_body.s0 2665).length) })
kernel_rfl PRE_first_tail_x15_r0_body.zg50_2673467 : PRE_first_tail_x15_r0_body.s490.heap.get 2673467 = some (.obj (objOf PRE_first_tail_x15_r0_body.s490 2673467))
kernel_rfl PRE_first_tail_x15_r0_body.zk50_2673467 : (objOf PRE_first_tail_x15_r0_body.s490 2673467).kind = .array (arrOf PRE_first_tail_x15_r0_body.s0 2673467)
kernel_rfl PRE_first_tail_x15_r0_body.zm50_2673467 : PRE_first_tail_x15_r0_body.s489.heap.get 2673467 = some (.obj { PRE_first_tail_x15_r0_body.kappa50.obj (objOf PRE_first_tail_x15_r0_body.s490 2673467) with
  kind := .array (arrOf PRE_first_tail_x15_r0_body.s0 2673467 ++ (arrOf PRE_first_tail_x15_r0_body.s489 2673467).drop (arrOf PRE_first_tail_x15_r0_body.s0 2673467).length) })
kernel_rfl PRE_first_tail_x15_r0_body.zw50_4910 : (PRE_first_tail_x15_r0_body.s490.heap.get 4910).isSome = true
kernel_rfl PRE_first_tail_x15_r0_body.zw50_2673472 : (PRE_first_tail_x15_r0_body.s490.heap.get 2673472).isSome = true
kernel_rfl PRE_first_tail_x15_r0_body.zw50_2673473 : (PRE_first_tail_x15_r0_body.s490.heap.get 2673473).isSome = true
-- the heap: the changed list in range, holding the stage's written and fresh addresses; the canonical side's image
kernel_rfl PRE_first_tail_x15_r0_body.zclbd50 : PRE_first_tail_x15_r0_body.cl50.all (fun b => Nat.blt (b / 4096) (4 ^ 31)) = true
kernel_rfl PRE_first_tail_x15_r0_body.zwr50 : PRE_first_tail_x15_r0_body.st50.wr.all (fun b => !Nat.blt b PRE_first_tail_x15_r0_body.s488.next || PRE_first_tail_x15_r0_body.cl50.contains b) = true
def PRE_first_tail_x15_r0_body.zl50 : List Nat := PRE_first_tail_x15_r0_body.cl50.filter fun a => !(List.contains [2665, 2673467] a)
kernel_rfl PRE_first_tail_x15_r0_body.zimgE50 : PRE_first_tail_x15_r0_body.zl50.map (fun a => PRE_first_tail_x15_r0_body.s489.heap.get (PRE_first_tail_x15_r0_body.kappa50.a a)) = PRE_first_tail_x15_r0_body.zl50.map (fun a => (PRE_first_tail_x15_r0_body.s490.heap.get a).map PRE_first_tail_x15_r0_body.kappa50.hobj)
theorem PRE_first_tail_x15_r0_body.zimg50 : HeapImg PRE_first_tail_x15_r0_body.kappa50 PRE_first_tail_x15_r0_body.s490 PRE_first_tail_x15_r0_body.s489 PRE_first_tail_x15_r0_body.zl50 := PRE_first_tail_x15_r0_body.zimgE50
-- the roots and their supports
kernel_rfl PRE_first_tail_x15_r0_body.zctl50 : PRE_first_tail_x15_r0_body.s489.ctl = PRE_first_tail_x15_r0_body.kappa50.ctl PRE_first_tail_x15_r0_body.s490.ctl
kernel_rfl PRE_first_tail_x15_r0_body.zstack50 : PRE_first_tail_x15_r0_body.s489.stack = PRE_first_tail_x15_r0_body.s490.stack.map PRE_first_tail_x15_r0_body.kappa50.frame
kernel_rfl PRE_first_tail_x15_r0_body.zjobs50 : PRE_first_tail_x15_r0_body.s489.jobs = PRE_first_tail_x15_r0_body.s490.jobs.map PRE_first_tail_x15_r0_body.kappa50.job
kernel_rfl PRE_first_tail_x15_r0_body.zstores50 : PRE_first_tail_x15_r0_body.s489.stores = PRE_first_tail_x15_r0_body.kappa50.stores PRE_first_tail_x15_r0_body.s490.stores
kernel_rfl PRE_first_tail_x15_r0_body.zroots50 : checkRootsSupp PRE_first_tail_x15_r0_body.s490 2191 = true
kernel_rfl PRE_first_tail_x15_r0_body.znC50 : PRE_first_tail_x15_r0_body.S488.tab.length + PRE_first_tail_x15_r0_body.cws50.length = 2191
-- the map as `Conv.compact_shift` states it (the call's counters for the literals)
kernel_rfl PRE_first_tail_x15_r0_body.zkap50 : PRE_first_tail_x15_r0_body.kappa50 = Conv.Map.compact PRE_first_tail_x15_r0_body.s488.next 2713927 PRE_first_tail_x15_r0_body.S488.tab.length PRE_first_tail_x15_r0_body.pl50 (PRE_first_tail_x15_r0_body.nr50.map NumV.ref) PRE_first_tail_x15_r0_body.kd50.big
  PRE_first_tail_x15_r0_body.kd50.region PRE_first_tail_x15_r0_body.kd50.nodeF
-- the bridge inactive at the canonical state (`Conv.FullShiftQ.toX`; the merged state's bridge is the canonical's: cbridge)
theorem PRE_first_tail_x15_r0_body.zbin50 : (Host.Ts.Sim.Full.bridgeOf PRE_first_tail_x15_r0_body.s490.ffi).active = false := (Host.Load.Boot.replay_active Host.Load.Run.Prompt.P.oblog2818)
-- the JS bookkeeping's step (`Conv.JClean.step` over the changed list) and the canonical roots' bigint freedom
kernel_rfl PRE_first_tail_x15_r0_body.zjc50 : Conv.jcleanListB (⟨19183, 16270, 2713908, 2191⟩ : Conv.Cnt) PRE_first_tail_x15_r0_body.s490 PRE_first_tail_x15_r0_body.cl50 = true
kernel_rfl PRE_first_tail_x15_r0_body.zrootsB50 : noBigRootsP (fun i => !Conv.oldBigB (⟨19183, 16270, 2713908, 2191⟩ : Conv.Cnt) i) PRE_first_tail_x15_r0_body.s490.trace PRE_first_tail_x15_r0_body.s490 = true
kernel_rfl PRE_first_tail_x15_r0_body.zhm50 : Nat.ble (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s0.ffi).mlx.nnext 16270 = true
theorem PRE_first_tail_x15_r0_body.cjcl50 (h : Conv.JClean (⟨19183, 16270, 2713907, 2191⟩ : Conv.Cnt) PRE_first_tail_x15_r0_body.s488) : Conv.JClean (⟨19183, 16270, 2713908, 2191⟩ : Conv.Cnt) PRE_first_tail_x15_r0_body.s490 :=
  Conv.JClean.step h (Conv.Cnt.le_of_leB PRE_first_tail_x15_r0_body.cle50)
    (Conv.heap_off_setAll PRE_first_tail_x15_r0_body.cheap50 fun a ha => Nat.blt_eq.mp (List.all_eq_true.mp PRE_first_tail_x15_r0_body.zclbd50 a ha)) PRE_first_tail_x15_r0_body.zjc50

end Host.Load.Run.Tpl
end

section -- st50/TypedLast
set_option Elab.async false
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
namespace Host.Load.Run.Tpl
open Host.Ts Host.Ts.Sim Host.Ts.Sim.Template

boot_rfl PRE_first_tail_x15_r0_body.st50.bodyLast from PRE_first_tail_x15_r0_body.st50.s1 to PRE_first_tail_x15_r0_body.st50.s2 :
  interpS (step PRE_first_tail_x15_r0_body.st50.F PRE_first_tail_x15_r0_body.st50.s1).run PRE_first_tail_x15_r0_body.st50.S1 = some (PRE_first_tail_x15_r0_body.st50.s2, PRE_first_tail_x15_r0_body.st50.S2)
kernel_rfl PRE_first_tail_x15_r0_body.st50.bodyHalt : isHalt PRE_first_tail_x15_r0_body.st50.s1.ctl = false
kernel_rfl PRE_first_tail_x15_r0_body.st50.bodyTopCheck : noBlockTop PRE_first_tail_x15_r0_body.st50.s2.stack = true

end Host.Load.Run.Tpl
end

section -- st50/TypedOk
set_option Elab.async false
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
namespace Host.Load.Run.Tpl
open Host.Ts Host.Ts.Sim Host.Ts.Sim.Template

noncomputable def PRE_first_tail_x15_r0_body.st50.bodyOkL (bytes : List Byte) (rows : Nat) : St PRE_first_tail_x15_r0_body.st50.F.S → SSrv → Bool :=
  okLocal (Host.Ts.Sim.Compose.VWFrames.bodyOk bytes rows)

noncomputable def PRE_first_tail_x15_r0_body.st50.bodyOkLN (bytes : List Byte) (rows : Nat) : St PRE_first_tail_x15_r0_body.st50.F.S → FSrv → Bool :=
  okLocalN (Host.Ts.Sim.Compose.VWFrames.bodyOkN bytes rows)

theorem PRE_first_tail_x15_r0_body.st50.bodyOkLN_ok (bytes : List Byte) (rows : Nat) (s : St PRE_first_tail_x15_r0_body.st50.F.S) (c : FSrv) (h : c.Wf) :
    PRE_first_tail_x15_r0_body.st50.bodyOkLN bytes rows s c = PRE_first_tail_x15_r0_body.st50.bodyOkL bytes rows s c.toS :=
  okLocalN_ok (Host.Ts.Sim.Compose.VWFrames.bodyOkN_ok bytes rows) s c h

kernel_rfl PRE_first_tail_x15_r0_body.st50.bodyAccepted0 :
  (fun (bytes : List Byte) (rows : Nat) => PRE_first_tail_x15_r0_body.st50.bodyOkL bytes rows PRE_first_tail_x15_r0_body.st50.s0 PRE_first_tail_x15_r0_body.st50.S0) = fun _ _ => true

kernel_rfl PRE_first_tail_x15_r0_body.st50.bodyAccepted1 :
  (fun (bytes : List Byte) (rows : Nat) => PRE_first_tail_x15_r0_body.st50.bodyOkL bytes rows PRE_first_tail_x15_r0_body.st50.s1 PRE_first_tail_x15_r0_body.st50.S1) = fun _ _ => true

end Host.Load.Run.Tpl
end

section -- st50/TypedK0
set_option Elab.async false
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
namespace Host.Load.Run.Tpl
open Host.Ts Host.Ts.Sim Host.Ts.Sim.Template

boot_rfl PRE_first_tail_x15_r0_body.st50.bodyK0F from PRE_first_tail_x15_r0_body.st50.s0 to PRE_first_tail_x15_r0_body.st50.s1 :
  (fun (bytes : List Byte) (rows : Nat) => runOkS PRE_first_tail_x15_r0_body.st50.F (PRE_first_tail_x15_r0_body.st50.bodyOkLN bytes rows)
    ((nth? PRE_first_tail_x15_r0_body.st50.ks 0).getD 0) PRE_first_tail_x15_r0_body.st50.s0 PRE_first_tail_x15_r0_body.st50.S0) = fun _ _ => some (PRE_first_tail_x15_r0_body.st50.s1, PRE_first_tail_x15_r0_body.st50.S1)
theorem PRE_first_tail_x15_r0_body.st50.bodyK0 :
  (fun (bytes : List Byte) (rows : Nat) => runOk PRE_first_tail_x15_r0_body.st50.F (PRE_first_tail_x15_r0_body.st50.bodyOkL bytes rows)
    ((nth? PRE_first_tail_x15_r0_body.st50.ks 0).getD 0) PRE_first_tail_x15_r0_body.st50.s0 PRE_first_tail_x15_r0_body.st50.S0) = fun _ _ => some (PRE_first_tail_x15_r0_body.st50.s1, PRE_first_tail_x15_r0_body.st50.S1) :=
  runOk_fun_of_runOkS PRE_first_tail_x15_r0_body.st50.bodyOkLN_ok PRE_first_tail_x15_r0_body.st50.bodyK0F
end Host.Load.Run.Tpl
end

section -- st50/TypedTpl
set_option Elab.async false
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
namespace Host.Load.Run.Tpl
open Host.Ts Host.Ts.Sim Host.Ts.Sim.Template

theorem PRE_first_tail_x15_r0_body.st50.bodyRun (bytes : List Byte) (rows : Nat) :
    runOk PRE_first_tail_x15_r0_body.st50.F (PRE_first_tail_x15_r0_body.st50.bodyOkL bytes rows) 206 PRE_first_tail_x15_r0_body.st50.s0 PRE_first_tail_x15_r0_body.st50.S0 = some (PRE_first_tail_x15_r0_body.st50.s1, PRE_first_tail_x15_r0_body.st50.S1) :=
  (congrFun (congrFun PRE_first_tail_x15_r0_body.st50.bodyK0 bytes) rows)

theorem PRE_first_tail_x15_r0_body.st50.bodyLocal (bytes : List Byte) (rows : Nat) : ∀ s S, PRE_first_tail_x15_r0_body.st50.bodyOkL bytes rows s S = true → Disp.localB s = true := okLocal_localB

noncomputable def PRE_first_tail_x15_r0_body.st50.bodyTpl (bytes : List Byte) (rows : Nat) : Host.Ts.Sim.Stage.StageTpl PRE_first_tail_x15_r0_body.st50.F (PRE_first_tail_x15_r0_body.st50.bodyOkL bytes rows) where
  s0 := PRE_first_tail_x15_r0_body.st50.s0
  S0 := PRE_first_tail_x15_r0_body.st50.S0
  s1 := PRE_first_tail_x15_r0_body.st50.s1
  S1 := PRE_first_tail_x15_r0_body.st50.S1
  s2 := PRE_first_tail_x15_r0_body.st50.s2
  S2 := PRE_first_tail_x15_r0_body.st50.S2
  n := 206
  ok0 := congrFun (congrFun PRE_first_tail_x15_r0_body.st50.bodyAccepted0 bytes) rows
  run := PRE_first_tail_x15_r0_body.st50.bodyRun bytes rows
  ok1 := congrFun (congrFun PRE_first_tail_x15_r0_body.st50.bodyAccepted1 bytes) rows
  halt := PRE_first_tail_x15_r0_body.st50.bodyHalt
  last := PRE_first_tail_x15_r0_body.st50.bodyLast
  top := noBlockTop_sound PRE_first_tail_x15_r0_body.st50.bodyTopCheck
end Host.Load.Run.Tpl
end

section -- SiteC51
set_option Elab.async false
namespace Host.Load.Run.Tpl
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
open Host.Ts Host.Ts.Sim Host.Ts.Sim.Template

/-! The compaction after the merge at call site 51 of chain `PRE_first_tail_x15_r0_body` (`Conv.compact`, `Conv.full_compactQ`): the canonical
state `PRE_first_tail_x15_r0_body.s507` (the stage's results at canonical places, its trace the call's) under `PRE_first_tail_x15_r0_body.kappa51` into the merged state
`PRE_first_tail_x15_r0_body.s506`. -/

def PRE_first_tail_x15_r0_body.pl51 : List Nat := [2716495, 2715670, 2716501, 2716497, 2715672, 2716503]
def PRE_first_tail_x15_r0_body.nr51 : List Nat := [2294, 2293, 2269, 2277, 2282, 2287, 2292, 2266, 2267, 2268, 2275, 2276, 2264, 2271, 2272, 2273, 2274, 2270]
/-- The native part of the compaction map (canonical → merged handles and nodes: its `big`, `region`, `nodeF`). -/
def PRE_first_tail_x15_r0_body.kd51 : RData :=
  ⟨2715389, 2716538, Stage.setAll PTrie.nil [(2715383, 2716495), (2715384, 2715670), (2715385, 2716501), (2715386, 2716497), (2715387, 2715672), (2715388, 2716503)], Stage.setAll PTrie.nil [(19217, 19243), (19218, 19221), (19219, 19244)],
   19220, 19245, 16316, 16316, Stage.setAll PTrie.nil [],
   Stage.setAll PTrie.nil [(2264, .ref 2294), (2265, .ref 2293), (2266, .ref 2269), (2267, .ref 2277), (2268, .ref 2282), (2269, .ref 2287), (2270, .ref 2292), (2271, .ref 2266), (2272, .ref 2267), (2273, .ref 2268), (2274, .ref 2275), (2275, .ref 2276), (2276, .ref 2264), (2277, .ref 2271), (2278, .ref 2272), (2279, .ref 2273), (2280, .ref 2274), (2281, .ref 2270)]⟩
/-- **The compaction map.** -/
noncomputable def PRE_first_tail_x15_r0_body.kappa51 : Map :=
  Conv.Map.compact 2715383 2716538 2264 PRE_first_tail_x15_r0_body.pl51 (PRE_first_tail_x15_r0_body.nr51.map NumV.ref) PRE_first_tail_x15_r0_body.kd51.big
    PRE_first_tail_x15_r0_body.kd51.region PRE_first_tail_x15_r0_body.kd51.nodeF
/-- The canonical result variables and their images, the merged state's entries (`Conv.compactθ`). -/
def PRE_first_tail_x15_r0_body.cws51 : List Nat := [1887, 1888, 1889, 1890, 1891, 1892, 1893, 1894, 1895, 1896, 1897, 1898, 1899, 1900, 1901, 1902, 1903, 1904]
noncomputable def PRE_first_tail_x15_r0_body.crs51 : List SymE := PRE_first_tail_x15_r0_body.nr51.map fun r => (nth? PRE_first_tail_x15_r0_body.S506.tab r).getD (.var 0)
noncomputable def PRE_first_tail_x15_r0_body.ctheta51 : Nat → SymE := Conv.compactθ PRE_first_tail_x15_r0_body.cws51 PRE_first_tail_x15_r0_body.crs51
/-- The call's entries the stage wrote (renamed in the canonical state with the results). -/
def PRE_first_tail_x15_r0_body.wrB51 : List Nat := [2665, 2672429, 2673467, 2714557, 2715102, 2715358]

kernel_rfl PRE_first_tail_x15_r0_body.ctab51 : PRE_first_tail_x15_r0_body.S507.tab = PRE_first_tail_x15_r0_body.S505.tab ++ PRE_first_tail_x15_r0_body.cws51.map SymE.var
kernel_rfl PRE_first_tail_x15_r0_body.ctrace51 : PRE_first_tail_x15_r0_body.s507.trace = PRE_first_tail_x15_r0_body.s505.trace
kernel_rfl PRE_first_tail_x15_r0_body.cnext51 : PRE_first_tail_x15_r0_body.s507.next = 2715389
kernel_rfl PRE_first_tail_x15_r0_body.ccounters51 : ((Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s507.ffi).mlx.next, (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s507.ffi).mlx.nnext) = (19220, 16316)
-- the merged state's readback queue, carried to the canonical state (`Conv.FullShiftQ.tokens`, `tokSupp`)
kernel_rfl PRE_first_tail_x15_r0_body.cqueue51 : (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s506.ffi).mlx.tokens = (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s507.ffi).mlx.tokens.map PRE_first_tail_x15_r0_body.kappa51.nv
kernel_rfl PRE_first_tail_x15_r0_body.ctokSupp51 : (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s507.ffi).mlx.tokens.all (bSN 2282) = true
-- the written and the result entries carry no bigint of the canonical fresh band [next, E) and no fresh region
kernel_rfl PRE_first_tail_x15_r0_body.cclean51 : Conv.cleanListB 19220 131072 (fun r => Nat.ble 76880 r) PRE_first_tail_x15_r0_body.s507
    (PRE_first_tail_x15_r0_body.wrB51 ++ (List.range 6).map (2715383 + ·)) = true
kernel_rfl PRE_first_tail_x15_r0_body.cbigs51 : bigsOutB 19220 131072 (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s507.ffi).mlx = true

end Host.Load.Run.Tpl
end

section -- SiteK51
set_option Elab.async false
namespace Host.Load.Run.Tpl
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
open Host.Ts Host.Ts.Sim Host.Ts.Sim.Template

/-! The canonical state's closedness from the call's (`Conv.closed_of_callB`, `Conv.sst_of_callB`): it keeps the call's entries
off the written and the result ones (`PRE_first_tail_x15_r0_body.cl51`; natively the written and result handles, the result nodes, the written
and result items), and those are checked. -/

def PRE_first_tail_x15_r0_body.cl51 : List Nat := [2665, 2672429, 2673467, 2714557, 2715102, 2715358, 2715383, 2715384, 2715385, 2715386, 2715387, 2715388]
def PRE_first_tail_x15_r0_body.clo51 : List Nat := [19197, 19210, 19216, 19217, 19218, 19219]
def PRE_first_tail_x15_r0_body.cln51 : List Nat := [16289, 16290, 16291, 16292, 16293, 16294, 16295, 16296, 16297, 16298, 16299, 16300, 16301, 16302, 16303, 16304, 16305, 16306, 16307, 16308, 16309, 16310, 16311, 16312, 16313, 16314, 16315]
def PRE_first_tail_x15_r0_body.cli51 : List Nat := [16289, 16290, 16291, 16292, 16293, 16294, 16295, 16296, 16297, 16298, 16299, 16300, 16301, 16302, 16303, 16304, 16305, 16306, 16307, 16308, 16309, 16310, 16311, 16312, 16313, 16314, 16315]
kernel_rfl PRE_first_tail_x15_r0_body.cheap51 : PRE_first_tail_x15_r0_body.s507.heap = Stage.setAll PRE_first_tail_x15_r0_body.s505.heap (PRE_first_tail_x15_r0_body.cl51.filterMap fun a => (PRE_first_tail_x15_r0_body.s507.heap.get a).map (a, ·))
kernel_rfl PRE_first_tail_x15_r0_body.cnextLe51 : Nat.ble PRE_first_tail_x15_r0_body.s505.next PRE_first_tail_x15_r0_body.s507.next = true
kernel_rfl PRE_first_tail_x15_r0_body.ckeepP51 : Conv.keptPresentB PRE_first_tail_x15_r0_body.s505 PRE_first_tail_x15_r0_body.s507 PRE_first_tail_x15_r0_body.cl51 = true
kernel_rfl PRE_first_tail_x15_r0_body.csupp51 : Conv.suppListB PRE_first_tail_x15_r0_body.s507 2282 PRE_first_tail_x15_r0_body.cl51 = true
kernel_rfl PRE_first_tail_x15_r0_body.cbound51 : Conv.boundListB PRE_first_tail_x15_r0_body.s507 PRE_first_tail_x15_r0_body.cl51 = true
kernel_rfl PRE_first_tail_x15_r0_body.cnodesK51 : (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s507.ffi).mlx.nodes = Stage.setAll (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s505.ffi).mlx.nodes (PRE_first_tail_x15_r0_body.cln51.filterMap fun i => ((Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s507.ffi).mlx.nodes.get i).map (i, ·))
kernel_rfl PRE_first_tail_x15_r0_body.cobjsK51 : (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s507.ffi).mlx.objs = Stage.setAll (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s505.ffi).mlx.objs (PRE_first_tail_x15_r0_body.clo51.filterMap fun i => ((Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s507.ffi).mlx.objs.get i).map (i, ·))
kernel_rfl PRE_first_tail_x15_r0_body.citemsK51 : (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s507.ffi).mlx.items = Stage.setAll (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s505.ffi).mlx.items (PRE_first_tail_x15_r0_body.cli51.filterMap fun i => ((Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s507.ffi).mlx.items.get i).map (i, ·))
kernel_rfl PRE_first_tail_x15_r0_body.csst51 : Conv.sstListB 2282 (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s507.ffi).mlx PRE_first_tail_x15_r0_body.cln51 PRE_first_tail_x15_r0_body.clo51 PRE_first_tail_x15_r0_body.cli51 = true

end Host.Load.Run.Tpl
end

section -- SiteCl51
set_option Elab.async false
namespace Host.Load.Run.Tpl
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
open Host.Ts Host.Ts.Sim Host.Ts.Sim.Template

kernel_rfl PRE_first_tail_x15_r0_body.ckA51 : (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s507.ffi).mlx.arrs = Stage.setAll (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s505.ffi).mlx.arrs (PRE_first_tail_x15_r0_body.clo51.filterMap fun i => ((Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s507.ffi).mlx.arrs.get i).map (i, ·))
kernel_rfl PRE_first_tail_x15_r0_body.cbd51 : (PRE_first_tail_x15_r0_body.clo51 ++ PRE_first_tail_x15_r0_body.cln51 ++ PRE_first_tail_x15_r0_body.cli51).all (fun i => Nat.blt (i / 4096) (4 ^ 31)) = true
kernel_rfl PRE_first_tail_x15_r0_body.cle51 : Conv.Cnt.leB (⟨19217, 16289, 2715383, 2264⟩ : Conv.Cnt) (⟨19220, 16316, 2715389, 2282⟩ : Conv.Cnt) = true
kernel_rfl PRE_first_tail_x15_r0_body.cck51 : Conv.ncleanListB (⟨19220, 16316, 2715389, 2282⟩ : Conv.Cnt) (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s507.ffi).mlx PRE_first_tail_x15_r0_body.clo51 PRE_first_tail_x15_r0_body.cln51 PRE_first_tail_x15_r0_body.cli51 = true
theorem PRE_first_tail_x15_r0_body.cncl51 (h : Conv.NClean (⟨19217, 16289, 2715383, 2264⟩ : Conv.Cnt) (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s505.ffi).mlx) : Conv.NClean (⟨19220, 16316, 2715389, 2282⟩ : Conv.Cnt) (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s507.ffi).mlx :=
  Conv.NClean.stepKeep h PRE_first_tail_x15_r0_body.cle51 PRE_first_tail_x15_r0_body.ckA51 PRE_first_tail_x15_r0_body.cobjsK51 PRE_first_tail_x15_r0_body.cnodesK51 PRE_first_tail_x15_r0_body.citemsK51 PRE_first_tail_x15_r0_body.cbd51 PRE_first_tail_x15_r0_body.cck51

end Host.Load.Run.Tpl
end

section -- SiteS51
set_option Elab.async false
namespace Host.Load.Run.Tpl
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
open Host.Ts Host.Ts.Sim Host.Ts.Sim.Template

/-! The compaction's native shift at call site 51 from its footprint (`Conv.nshift_of_foot`), and the observers'
(`liveShift_foot`, `kernShift_foot`): `Conv.FullShiftQ` for `Conv.full_compactQ`, given the call's bookkeeping and its
relation's facts. -/

/-- The load parameters of the chain (band-free: its start's node counter as `NL` and `N0`). -/
def PRE_first_tail_x15_r0_body.Pc51 : LoadP := ⟨18151, 131072, 1099511627776, 15235, 15235, []⟩
/-- The site's band raised to the map's checked fixed-node prefix, including newly recorded closure traces. -/
def PRE_first_tail_x15_r0_body.P51 : LoadP := PRE_first_tail_x15_r0_body.Pc51.raise 16316
kernel_rfl PRE_first_tail_x15_r0_body.craise51 : Nat.ble PRE_first_tail_x15_r0_body.Pc51.N0 16316 = true
theorem PRE_first_tail_x15_r0_body.raised51 : Host.Ts.Sim.Full.Raised PRE_first_tail_x15_r0_body.Pc51 PRE_first_tail_x15_r0_body.P51 :=
  .inr ⟨16316, rfl, Nat.le_of_ble_eq_true PRE_first_tail_x15_r0_body.craise51, rfl⟩
noncomputable abbrev PRE_first_tail_x15_r0_body.cx0_51 : Host.Load.LSt := clearTokens (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s507.ffi)
noncomputable abbrev PRE_first_tail_x15_r0_body.cx1_51 : Host.Load.LSt := clearTokens (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s506.ffi)
def PRE_first_tail_x15_r0_body.khinv51 : PTrie Nat := Stage.setAll PTrie.nil [(19243, 19217), (19221, 19218), (19244, 19219)]
def PRE_first_tail_x15_r0_body.kninv51 : PTrie Nat := Stage.setAll PTrie.nil [(16289, 16289), (16290, 16290), (16291, 16291), (16292, 16292), (16293, 16293), (16294, 16294), (16295, 16295), (16296, 16296), (16297, 16297), (16298, 16298), (16299, 16299), (16300, 16300), (16301, 16301), (16302, 16302), (16303, 16303), (16304, 16304), (16305, 16305), (16306, 16306), (16307, 16307), (16308, 16308), (16309, 16309), (16310, 16310), (16311, 16311), (16312, 16312), (16313, 16313), (16314, 16314), (16315, 16315)]
/-- The stage's footprint: its written and fresh handles, fresh nodes, written and fresh items. -/
def PRE_first_tail_x15_r0_body.cwS51 : List Nat := [19197, 19210, 19216, 19217, 19218, 19219, 19220, 19221, 19222, 19223, 19224, 19225, 19226, 19227, 19228, 19229, 19230, 19231, 19232, 19233, 19234, 19235, 19236, 19237, 19238, 19239, 19240, 19241, 19242, 19243, 19244]
def PRE_first_tail_x15_r0_body.cnS51 : List Nat := List.range' 16289 27
def PRE_first_tail_x15_r0_body.ciS51 : List Nat := [] ++ List.range' 16289 27

-- the small checks (`MChecks`'s)
kernel_rfl PRE_first_tail_x15_r0_body.cnh051 : PRE_first_tail_x15_r0_body.kd51.nh0 = PRE_first_tail_x15_r0_body.cx0_51.mlx.next
kernel_rfl PRE_first_tail_x15_r0_body.cnh151 : PRE_first_tail_x15_r0_body.kd51.nh1 = PRE_first_tail_x15_r0_body.cx1_51.mlx.next
kernel_rfl PRE_first_tail_x15_r0_body.cnn051 : PRE_first_tail_x15_r0_body.kd51.nn0 = PRE_first_tail_x15_r0_body.cx0_51.mlx.nnext
kernel_rfl PRE_first_tail_x15_r0_body.cnn151 : PRE_first_tail_x15_r0_body.kd51.nn1 = PRE_first_tail_x15_r0_body.cx1_51.mlx.nnext
kernel_rfl PRE_first_tail_x15_r0_body.cplo51 : (Nat.blt 0 PRE_first_tail_x15_r0_body.P51.lo && Nat.ble PRE_first_tail_x15_r0_body.P51.lo PRE_first_tail_x15_r0_body.cx0_51.mlx.next && Nat.ble PRE_first_tail_x15_r0_body.P51.lo RData.bigHi && Nat.ble RData.bigHi PRE_first_tail_x15_r0_body.P51.E) = true
kernel_rfl PRE_first_tail_x15_r0_body.ccnt51 : (Nat.ble PRE_first_tail_x15_r0_body.cx0_51.mlx.next PRE_first_tail_x15_r0_body.cx1_51.mlx.next && Nat.ble PRE_first_tail_x15_r0_body.cx0_51.mlx.nnext PRE_first_tail_x15_r0_body.cx1_51.mlx.nnext) = true
kernel_rfl PRE_first_tail_x15_r0_body.cnband51 : (Nat.blt 0 PRE_first_tail_x15_r0_body.P51.NL && Nat.ble PRE_first_tail_x15_r0_body.P51.NL PRE_first_tail_x15_r0_body.P51.N0 && Nat.ble PRE_first_tail_x15_r0_body.P51.N0 PRE_first_tail_x15_r0_body.cx0_51.mlx.nnext) = true
kernel_rfl PRE_first_tail_x15_r0_body.chbelow51 : PRE_first_tail_x15_r0_body.kd51.checkHndBelow = true
kernel_rfl PRE_first_tail_x15_r0_body.chren51 : checkRenG PRE_first_tail_x15_r0_body.kd51.hnd PRE_first_tail_x15_r0_body.khinv51 (phB PRE_first_tail_x15_r0_body.cx0_51.mlx) = true
kernel_rfl PRE_first_tail_x15_r0_body.cband51 : PRE_first_tail_x15_r0_body.kd51.checkBand PRE_first_tail_x15_r0_body.P51.lo = true
kernel_rfl PRE_first_tail_x15_r0_body.cnh1pos51 : Nat.blt 0 PRE_first_tail_x15_r0_body.kd51.nh1 = true
kernel_rfl PRE_first_tail_x15_r0_body.cnren51 : checkRenG PRE_first_tail_x15_r0_body.kd51.node PRE_first_tail_x15_r0_body.kninv51 (pnB PRE_first_tail_x15_r0_body.cx0_51.mlx) = true
kernel_rfl PRE_first_tail_x15_r0_body.cnlow51 : (PTrie.keysA PRE_first_tail_x15_r0_body.kd51.node).all (fun j => Nat.ble PRE_first_tail_x15_r0_body.P51.NL j && Nat.blt (PRE_first_tail_x15_r0_body.kd51.nodeF j) PRE_first_tail_x15_r0_body.cx1_51.mlx.nnext) = true
kernel_rfl PRE_first_tail_x15_r0_body.cabs0a51 : PRE_first_tail_x15_r0_body.cx0_51.mlx.arrs.get 0 = none
kernel_rfl PRE_first_tail_x15_r0_body.cabs0b51 : PRE_first_tail_x15_r0_body.cx0_51.mlx.objs.get 0 = none
kernel_rfl PRE_first_tail_x15_r0_body.ctok151 : PRE_first_tail_x15_r0_body.cx1_51.mlx.tokens = []
kernel_rfl PRE_first_tail_x15_r0_body.cpend51 : PRE_first_tail_x15_r0_body.cx1_51.mlx.pending = PRE_first_tail_x15_r0_body.cx0_51.mlx.pending.map PRE_first_tail_x15_r0_body.kappa51.pend
kernel_rfl PRE_first_tail_x15_r0_body.cerrh51 : PRE_first_tail_x15_r0_body.cx1_51.mlx.errh = PRE_first_tail_x15_r0_body.cx0_51.mlx.errh.map PRE_first_tail_x15_r0_body.kappa51.arg
kernel_rfl PRE_first_tail_x15_r0_body.cfiles51 : PRE_first_tail_x15_r0_body.cx1_51.mlx.files = PRE_first_tail_x15_r0_body.cx0_51.mlx.files
kernel_rfl PRE_first_tail_x15_r0_body.carch51 : PRE_first_tail_x15_r0_body.cx1_51.mlx.arch = PRE_first_tail_x15_r0_body.cx0_51.mlx.arch
kernel_rfl PRE_first_tail_x15_r0_body.csizes51 : PRE_first_tail_x15_r0_body.cx1_51.mlx.deviceSizes = PRE_first_tail_x15_r0_body.cx0_51.mlx.deviceSizes
kernel_rfl PRE_first_tail_x15_r0_body.cwired51 : PRE_first_tail_x15_r0_body.cx1_51.mlx.wired = PRE_first_tail_x15_r0_body.cx0_51.mlx.wired
kernel_rfl PRE_first_tail_x15_r0_body.chost51 : PRE_first_tail_x15_r0_body.cx1_51.host = PRE_first_tail_x15_r0_body.cx0_51.host
-- the compaction map's addresses are `PRE_first_tail_x15_r0_body.kd51`'s
kernel_rfl PRE_first_tail_x15_r0_body.ckn051 : PRE_first_tail_x15_r0_body.kd51.n0 = 2715389
kernel_rfl PRE_first_tail_x15_r0_body.ckn151 : PRE_first_tail_x15_r0_body.kd51.n1 = 2716538
kernel_rfl PRE_first_tail_x15_r0_body.ckheap51 : (PTrie.keysA PRE_first_tail_x15_r0_body.kd51.heap).all (fun x => Nat.ble 2715383 x) = true
kernel_rfl PRE_first_tail_x15_r0_body.ckpl51 : (List.range 6).all (fun j => decide (PRE_first_tail_x15_r0_body.kd51.heap.get (2715383 + j) = nth? PRE_first_tail_x15_r0_body.pl51 j)) = true
-- the map fixes the call's names (`Conv.fixOld_compact`), the call's counters
kernel_rfl PRE_first_tail_x15_r0_body.fja51 : Nat.ble 2715383 2715383 = true
kernel_rfl PRE_first_tail_x15_r0_body.fn51 : Nat.ble 2264 2264 = true
kernel_rfl PRE_first_tail_x15_r0_body.fjaD51 : Nat.ble 2715383 PRE_first_tail_x15_r0_body.kd51.n0 = true
kernel_rfl PRE_first_tail_x15_r0_body.fxn51 : Nat.ble 19217 PRE_first_tail_x15_r0_body.kd51.nh0 = true
kernel_rfl PRE_first_tail_x15_r0_body.fnn51 : Nat.ble 16289 PRE_first_tail_x15_r0_body.kd51.nn0 = true
kernel_rfl PRE_first_tail_x15_r0_body.fxb51 : Nat.ble 19217 RData.bigHi = true
kernel_rfl PRE_first_tail_x15_r0_body.fheap51 : (PTrie.keysA PRE_first_tail_x15_r0_body.kd51.heap).all (Nat.ble (⟨19217, 16289, 2715383, 2264⟩ : Conv.Cnt).ja) = true
kernel_rfl PRE_first_tail_x15_r0_body.fhnd51 : (PTrie.keysA PRE_first_tail_x15_r0_body.kd51.hnd).all (Nat.ble (⟨19217, 16289, 2715383, 2264⟩ : Conv.Cnt).xn) = true
kernel_rfl PRE_first_tail_x15_r0_body.fnode51 : (PTrie.keysA PRE_first_tail_x15_r0_body.kd51.node).all (Nat.ble (⟨19217, 16289, 2715383, 2264⟩ : Conv.Cnt).nn) = true
/-- The compaction map fixes the call's names. -/
theorem PRE_first_tail_x15_r0_body.cfix51 : Conv.FixOld (⟨19217, 16289, 2715383, 2264⟩ : Conv.Cnt) PRE_first_tail_x15_r0_body.kappa51 :=
  Conv.fixOld_compact (Nat.le_of_ble_eq_true PRE_first_tail_x15_r0_body.fja51) (Nat.le_of_ble_eq_true PRE_first_tail_x15_r0_body.fn51) (Nat.le_of_ble_eq_true PRE_first_tail_x15_r0_body.fjaD51) (Nat.le_of_ble_eq_true PRE_first_tail_x15_r0_body.fxn51) (Nat.le_of_ble_eq_true PRE_first_tail_x15_r0_body.fnn51) (Nat.le_of_ble_eq_true PRE_first_tail_x15_r0_body.fxb51) PRE_first_tail_x15_r0_body.fheap51 PRE_first_tail_x15_r0_body.fhnd51 PRE_first_tail_x15_r0_body.fnode51
kernel_rfl PRE_first_tail_x15_r0_body.fcxn51 : (⟨19217, 16289, 2715383, 2264⟩ : Conv.Cnt).xn = (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s505.ffi).mlx.next
kernel_rfl PRE_first_tail_x15_r0_body.fcnn51 : (⟨19217, 16289, 2715383, 2264⟩ : Conv.Cnt).nn = (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s505.ffi).mlx.nnext
kernel_rfl PRE_first_tail_x15_r0_body.fle051 : (Nat.ble (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s505.ffi).mlx.next PRE_first_tail_x15_r0_body.cx0_51.mlx.next && Nat.ble (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s505.ffi).mlx.nnext PRE_first_tail_x15_r0_body.cx0_51.mlx.nnext && Nat.ble (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s505.ffi).mlx.next RData.bigHi) = true
kernel_rfl PRE_first_tail_x15_r0_body.fnk51 : (PTrie.keysA PRE_first_tail_x15_r0_body.kd51.node).all (Nat.ble (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s505.ffi).mlx.nnext) = true
-- the merged state keeps the call's entries off the stage's footprint
kernel_rfl PRE_first_tail_x15_r0_body.f1A51 : PRE_first_tail_x15_r0_body.cx1_51.mlx.arrs = Stage.setAll (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s505.ffi).mlx.arrs (PRE_first_tail_x15_r0_body.cwS51.filterMap fun i => (PRE_first_tail_x15_r0_body.cx1_51.mlx.arrs.get i).map (i, ·))
kernel_rfl PRE_first_tail_x15_r0_body.f1O51 : PRE_first_tail_x15_r0_body.cx1_51.mlx.objs = Stage.setAll (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s505.ffi).mlx.objs (PRE_first_tail_x15_r0_body.cwS51.filterMap fun i => (PRE_first_tail_x15_r0_body.cx1_51.mlx.objs.get i).map (i, ·))
kernel_rfl PRE_first_tail_x15_r0_body.f1N51 : PRE_first_tail_x15_r0_body.cx1_51.mlx.nodes = Stage.setAll (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s505.ffi).mlx.nodes (PRE_first_tail_x15_r0_body.cnS51.filterMap fun i => (PRE_first_tail_x15_r0_body.cx1_51.mlx.nodes.get i).map (i, ·))
kernel_rfl PRE_first_tail_x15_r0_body.f1I51 : PRE_first_tail_x15_r0_body.cx1_51.mlx.items = Stage.setAll (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s505.ffi).mlx.items (PRE_first_tail_x15_r0_body.ciS51.filterMap fun i => (PRE_first_tail_x15_r0_body.cx1_51.mlx.items.get i).map (i, ·))
kernel_rfl PRE_first_tail_x15_r0_body.fbd51 : (PRE_first_tail_x15_r0_body.clo51 ++ PRE_first_tail_x15_r0_body.cln51 ++ PRE_first_tail_x15_r0_body.cli51 ++ PRE_first_tail_x15_r0_body.cwS51 ++ PRE_first_tail_x15_r0_body.cnS51 ++ PRE_first_tail_x15_r0_body.ciS51).all (fun i => Nat.blt (i / 4096) (4 ^ 31)) = true
kernel_rfl PRE_first_tail_x15_r0_body.fincW51 : PRE_first_tail_x15_r0_body.cwS51.all (fun h => !Nat.blt h (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s505.ffi).mlx.next || PRE_first_tail_x15_r0_body.clo51.contains h) = true
kernel_rfl PRE_first_tail_x15_r0_body.fincI51 : PRE_first_tail_x15_r0_body.ciS51.all (fun k => !Nat.blt k (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s505.ffi).mlx.nnext || PRE_first_tail_x15_r0_body.cli51.contains k) = true
kernel_rfl PRE_first_tail_x15_r0_body.fincN51 : PRE_first_tail_x15_r0_body.cnS51.all (Nat.ble (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s505.ffi).mlx.nnext) = true
kernel_rfl PRE_first_tail_x15_r0_body.flnF51 : PRE_first_tail_x15_r0_body.cln51.all (Nat.ble (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s505.ffi).mlx.nnext) = true
-- the checks over the changed lists
kernel_rfl PRE_first_tail_x15_r0_body.fh51 : PRE_first_tail_x15_r0_body.clo51.all (handleOK PRE_first_tail_x15_r0_body.kappa51 PRE_first_tail_x15_r0_body.P51.lo PRE_first_tail_x15_r0_body.cx0_51.mlx PRE_first_tail_x15_r0_body.cx1_51.mlx) = true
kernel_rfl PRE_first_tail_x15_r0_body.fo51 : PRE_first_tail_x15_r0_body.clo51.map (fun h => PRE_first_tail_x15_r0_body.cx1_51.mlx.objs.get (PRE_first_tail_x15_r0_body.kappa51.handle h)) = PRE_first_tail_x15_r0_body.clo51.map (fun h => (PRE_first_tail_x15_r0_body.cx0_51.mlx.objs.get h).map PRE_first_tail_x15_r0_body.kappa51.nobj)
kernel_rfl PRE_first_tail_x15_r0_body.fok51 : PRE_first_tail_x15_r0_body.clo51.all (objOK PRE_first_tail_x15_r0_body.kappa51 PRE_first_tail_x15_r0_body.P51.NL PRE_first_tail_x15_r0_body.cx0_51.mlx) = true
kernel_rfl PRE_first_tail_x15_r0_body.fnd51 : PRE_first_tail_x15_r0_body.cln51.all (nodeOKF PRE_first_tail_x15_r0_body.kappa51 PRE_first_tail_x15_r0_body.P51 PRE_first_tail_x15_r0_body.cx0_51.mlx PRE_first_tail_x15_r0_body.cx1_51.mlx) = true
kernel_rfl PRE_first_tail_x15_r0_body.fp51 : ((PRE_first_tail_x15_r0_body.cln51.filter (fullB PRE_first_tail_x15_r0_body.P51))).map (fun i => (PRE_first_tail_x15_r0_body.cx1_51.mlx.nodes.get (PRE_first_tail_x15_r0_body.kappa51.node i)).map Host.Mlx.Ffi.Node.prim) =
  ((PRE_first_tail_x15_r0_body.cln51.filter (fullB PRE_first_tail_x15_r0_body.P51))).map (fun i => (PRE_first_tail_x15_r0_body.cx0_51.mlx.nodes.get i).map fun nd => PRE_first_tail_x15_r0_body.kappa51.prim nd.prim)
kernel_rfl PRE_first_tail_x15_r0_body.fnordI51 : incrB PRE_first_tail_x15_r0_body.kd51.nodeF (List.range' 16289 27) = true
kernel_rfl PRE_first_tail_x15_r0_body.fnordK51 : (PTrie.keysA PRE_first_tail_x15_r0_body.kd51.node).all (fun k => Nat.ble 16289 k && Nat.blt k 16316) = true
kernel_rfl PRE_first_tail_x15_r0_body.fnordL51 : (PRE_first_tail_x15_r0_body.cln51.filter (Nat.ble PRE_first_tail_x15_r0_body.P51.N0)).all (fun i => Nat.ble i (PRE_first_tail_x15_r0_body.kd51.nodeF i) && (Nat.blt i 16316 || Nat.ble PRE_first_tail_x15_r0_body.kd51.nn0 i)) = true
theorem PRE_first_tail_x15_r0_body.fnord51 : (PRE_first_tail_x15_r0_body.cln51.filter (Nat.ble PRE_first_tail_x15_r0_body.P51.N0)).all (fun i => Nat.ble i (PRE_first_tail_x15_r0_body.kd51.nodeF i) &&
    (PTrie.keysA PRE_first_tail_x15_r0_body.kd51.node).all fun j => !Nat.blt j i || Nat.blt (PRE_first_tail_x15_r0_body.kd51.nodeF j) (PRE_first_tail_x15_r0_body.kd51.nodeF i)) = true :=
  cnord_of PRE_first_tail_x15_r0_body.cnlow51 PRE_first_tail_x15_r0_body.cnn151 PRE_first_tail_x15_r0_body.fnordI51 PRE_first_tail_x15_r0_body.fnordK51 PRE_first_tail_x15_r0_body.fnordL51
kernel_rfl PRE_first_tail_x15_r0_body.fi51 : PRE_first_tail_x15_r0_body.cli51.all (pnB PRE_first_tail_x15_r0_body.cx0_51.mlx) = true
kernel_rfl PRE_first_tail_x15_r0_body.fii51 : PRE_first_tail_x15_r0_body.cli51.all (fun k => decide (PRE_first_tail_x15_r0_body.cx1_51.mlx.items.get (PRE_first_tail_x15_r0_body.kappa51.node k) = (PRE_first_tail_x15_r0_body.cx0_51.mlx.items.get k).map PRE_first_tail_x15_r0_body.kappa51.nv)) = true
/-- **The compaction's footprint.** -/
theorem PRE_first_tail_x15_r0_body.cfoot51 (clean : Conv.NClean (⟨19217, 16289, 2715383, 2264⟩ : Conv.Cnt) (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s505.ffi).mlx) (hltC : ∀ h, PH (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s505.ffi).mlx h → h < (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s505.ffi).mlx.next) (nltC : ∀ i, PN (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s505.ffi).mlx i → i < (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s505.ffi).mlx.nnext) (itemsC : ∀ k v, (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s505.ffi).mlx.items.get k = some v → PN (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s505.ffi).mlx k) (tracedC : ∀ h o, (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s505.ffi).mlx.objs.get h = some o → ∀ i ∈ objTraces o, i < PRE_first_tail_x15_r0_body.P51.NL) (cl : SSt (· < 2282) PRE_first_tail_x15_r0_body.cx0_51.mlx) :
    Conv.MFoot PRE_first_tail_x15_r0_body.P51 2282 PRE_first_tail_x15_r0_body.kappa51 PRE_first_tail_x15_r0_body.kd51 PRE_first_tail_x15_r0_body.khinv51 PRE_first_tail_x15_r0_body.kninv51 (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s505.ffi).mlx PRE_first_tail_x15_r0_body.cx0_51.mlx PRE_first_tail_x15_r0_body.cx1_51.mlx (⟨19217, 16289, 2715383, 2264⟩ : Conv.Cnt) PRE_first_tail_x15_r0_body.clo51 PRE_first_tail_x15_r0_body.cln51 PRE_first_tail_x15_r0_body.cli51 PRE_first_tail_x15_r0_body.cwS51 PRE_first_tail_x15_r0_body.cnS51 PRE_first_tail_x15_r0_body.ciS51 :=
  ⟨rfl, rfl, rfl, PRE_first_tail_x15_r0_body.cnh051, PRE_first_tail_x15_r0_body.cnh151, PRE_first_tail_x15_r0_body.cnn051, PRE_first_tail_x15_r0_body.cnn151, PRE_first_tail_x15_r0_body.cplo51, PRE_first_tail_x15_r0_body.ccnt51, PRE_first_tail_x15_r0_body.cnband51, PRE_first_tail_x15_r0_body.chbelow51, PRE_first_tail_x15_r0_body.chren51, PRE_first_tail_x15_r0_body.cband51, PRE_first_tail_x15_r0_body.cnh1pos51, PRE_first_tail_x15_r0_body.cnren51, PRE_first_tail_x15_r0_body.cnlow51, PRE_first_tail_x15_r0_body.cabs0a51, PRE_first_tail_x15_r0_body.cabs0b51, PRE_first_tail_x15_r0_body.ctok151, PRE_first_tail_x15_r0_body.cpend51, PRE_first_tail_x15_r0_body.cerrh51, PRE_first_tail_x15_r0_body.cfiles51, PRE_first_tail_x15_r0_body.carch51, PRE_first_tail_x15_r0_body.csizes51, PRE_first_tail_x15_r0_body.cwired51, PRE_first_tail_x15_r0_body.cfix51, clean, PRE_first_tail_x15_r0_body.fcxn51, PRE_first_tail_x15_r0_body.fcnn51, hltC, nltC, itemsC, tracedC, cl, PRE_first_tail_x15_r0_body.fle051, PRE_first_tail_x15_r0_body.fnk51, PRE_first_tail_x15_r0_body.ckA51, PRE_first_tail_x15_r0_body.cobjsK51, PRE_first_tail_x15_r0_body.cnodesK51, PRE_first_tail_x15_r0_body.citemsK51, PRE_first_tail_x15_r0_body.f1A51, PRE_first_tail_x15_r0_body.f1O51, PRE_first_tail_x15_r0_body.f1N51, PRE_first_tail_x15_r0_body.f1I51, PRE_first_tail_x15_r0_body.fbd51, PRE_first_tail_x15_r0_body.fincW51, PRE_first_tail_x15_r0_body.fincI51, PRE_first_tail_x15_r0_body.fincN51, PRE_first_tail_x15_r0_body.flnF51, PRE_first_tail_x15_r0_body.fh51, PRE_first_tail_x15_r0_body.fo51, PRE_first_tail_x15_r0_body.fok51, PRE_first_tail_x15_r0_body.fnd51, PRE_first_tail_x15_r0_body.fp51, PRE_first_tail_x15_r0_body.fnord51, PRE_first_tail_x15_r0_body.fi51, PRE_first_tail_x15_r0_body.fii51⟩
theorem PRE_first_tail_x15_r0_body.cnshift51 (clean : Conv.NClean (⟨19217, 16289, 2715383, 2264⟩ : Conv.Cnt) (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s505.ffi).mlx) (hltC : ∀ h, PH (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s505.ffi).mlx h → h < (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s505.ffi).mlx.next) (nltC : ∀ i, PN (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s505.ffi).mlx i → i < (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s505.ffi).mlx.nnext) (itemsC : ∀ k v, (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s505.ffi).mlx.items.get k = some v → PN (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s505.ffi).mlx k) (tracedC : ∀ h o, (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s505.ffi).mlx.objs.get h = some o → ∀ i ∈ objTraces o, i < PRE_first_tail_x15_r0_body.P51.NL) (cl : SSt (· < 2282) PRE_first_tail_x15_r0_body.cx0_51.mlx) : NShift PRE_first_tail_x15_r0_body.P51 2282 PRE_first_tail_x15_r0_body.kappa51 PRE_first_tail_x15_r0_body.cx0_51 PRE_first_tail_x15_r0_body.cx1_51 :=
  Conv.nshift_of_foot (PRE_first_tail_x15_r0_body.cfoot51 clean hltC nltC itemsC tracedC cl) PRE_first_tail_x15_r0_body.chost51 (compact_a_eq PRE_first_tail_x15_r0_body.ckn051 PRE_first_tail_x15_r0_body.ckn151 PRE_first_tail_x15_r0_body.ckheap51 PRE_first_tail_x15_r0_body.ckpl51)

-- the observers: the layers' states at the call, the canonical and the merged state, their footprints and checks
noncomputable def PRE_first_tail_x15_r0_body.fxC_51 : PTrie Unit := (Host.Ts.Sim.Full.freedOf PRE_first_tail_x15_r0_body.s505.ffi).getD PTrie.nil
noncomputable def PRE_first_tail_x15_r0_body.krC_51 : Host.Load.Layers.KRec := (Host.Ts.Sim.Full.krecOf PRE_first_tail_x15_r0_body.s505.ffi).getD Host.Load.Layers.KRec.empty
kernel_rfl PRE_first_tail_x15_r0_body.ofxC_51 : (Host.Ts.Sim.Full.freedOf PRE_first_tail_x15_r0_body.s505.ffi) = some PRE_first_tail_x15_r0_body.fxC_51
kernel_rfl PRE_first_tail_x15_r0_body.okrC_51 : (Host.Ts.Sim.Full.krecOf PRE_first_tail_x15_r0_body.s505.ffi) = some PRE_first_tail_x15_r0_body.krC_51
noncomputable def PRE_first_tail_x15_r0_body.fx0_51 : PTrie Unit := (Host.Ts.Sim.Full.freedOf PRE_first_tail_x15_r0_body.s507.ffi).getD PTrie.nil
noncomputable def PRE_first_tail_x15_r0_body.kr0_51 : Host.Load.Layers.KRec := (Host.Ts.Sim.Full.krecOf PRE_first_tail_x15_r0_body.s507.ffi).getD Host.Load.Layers.KRec.empty
kernel_rfl PRE_first_tail_x15_r0_body.ofx0_51 : (Host.Ts.Sim.Full.freedOf PRE_first_tail_x15_r0_body.s507.ffi) = some PRE_first_tail_x15_r0_body.fx0_51
kernel_rfl PRE_first_tail_x15_r0_body.okr0_51 : (Host.Ts.Sim.Full.krecOf PRE_first_tail_x15_r0_body.s507.ffi) = some PRE_first_tail_x15_r0_body.kr0_51
noncomputable def PRE_first_tail_x15_r0_body.fx1_51 : PTrie Unit := (Host.Ts.Sim.Full.freedOf PRE_first_tail_x15_r0_body.s506.ffi).getD PTrie.nil
noncomputable def PRE_first_tail_x15_r0_body.kr1_51 : Host.Load.Layers.KRec := (Host.Ts.Sim.Full.krecOf PRE_first_tail_x15_r0_body.s506.ffi).getD Host.Load.Layers.KRec.empty
kernel_rfl PRE_first_tail_x15_r0_body.ofx1_51 : (Host.Ts.Sim.Full.freedOf PRE_first_tail_x15_r0_body.s506.ffi) = some PRE_first_tail_x15_r0_body.fx1_51
kernel_rfl PRE_first_tail_x15_r0_body.okr1_51 : (Host.Ts.Sim.Full.krecOf PRE_first_tail_x15_r0_body.s506.ffi) = some PRE_first_tail_x15_r0_body.kr1_51
kernel_rfl PRE_first_tail_x15_r0_body.ff051 : PRE_first_tail_x15_r0_body.fx0_51 = Stage.setAll PRE_first_tail_x15_r0_body.fxC_51 (PRE_first_tail_x15_r0_body.clo51.filterMap fun i => (PRE_first_tail_x15_r0_body.fx0_51.get i).map (i, ·))
kernel_rfl PRE_first_tail_x15_r0_body.ff151 : PRE_first_tail_x15_r0_body.fx1_51 = Stage.setAll PRE_first_tail_x15_r0_body.fxC_51 (PRE_first_tail_x15_r0_body.cwS51.filterMap fun i => (PRE_first_tail_x15_r0_body.fx1_51.get i).map (i, ·))
kernel_rfl PRE_first_tail_x15_r0_body.ffck51 : freedLB PRE_first_tail_x15_r0_body.kappa51 PRE_first_tail_x15_r0_body.cx0_51.mlx PRE_first_tail_x15_r0_body.fx0_51 PRE_first_tail_x15_r0_body.fx1_51 PRE_first_tail_x15_r0_body.clo51 = true
kernel_rfl PRE_first_tail_x15_r0_body.fkf051 : PRE_first_tail_x15_r0_body.kr0_51.flags = Stage.setAll PRE_first_tail_x15_r0_body.krC_51.flags (PRE_first_tail_x15_r0_body.clo51.filterMap fun i => (PRE_first_tail_x15_r0_body.kr0_51.flags.get i).map (i, ·))
kernel_rfl PRE_first_tail_x15_r0_body.fkt051 : PRE_first_tail_x15_r0_body.kr0_51.targs = Stage.setAll PRE_first_tail_x15_r0_body.krC_51.targs (PRE_first_tail_x15_r0_body.clo51.filterMap fun i => (PRE_first_tail_x15_r0_body.kr0_51.targs.get i).map (i, ·))
kernel_rfl PRE_first_tail_x15_r0_body.fkf151 : PRE_first_tail_x15_r0_body.kr1_51.flags = Stage.setAll PRE_first_tail_x15_r0_body.krC_51.flags (PRE_first_tail_x15_r0_body.cwS51.filterMap fun i => (PRE_first_tail_x15_r0_body.kr1_51.flags.get i).map (i, ·))
kernel_rfl PRE_first_tail_x15_r0_body.fkt151 : PRE_first_tail_x15_r0_body.kr1_51.targs = Stage.setAll PRE_first_tail_x15_r0_body.krC_51.targs (PRE_first_tail_x15_r0_body.cwS51.filterMap fun i => (PRE_first_tail_x15_r0_body.kr1_51.targs.get i).map (i, ·))
kernel_rfl PRE_first_tail_x15_r0_body.fkck51 : krecLB PRE_first_tail_x15_r0_body.kappa51 2282 PRE_first_tail_x15_r0_body.cx0_51.mlx PRE_first_tail_x15_r0_body.kr0_51 PRE_first_tail_x15_r0_body.kr1_51 PRE_first_tail_x15_r0_body.clo51 = true
kernel_rfl PRE_first_tail_x15_r0_body.fkn51 : Nat.ble 2264 2282 = true
-- the bridge and the pending traces' regions
kernel_rfl PRE_first_tail_x15_r0_body.cbridge51 : Host.Ts.Sim.Full.bridgeOf PRE_first_tail_x15_r0_body.s506.ffi = Host.Ts.Sim.Full.bridgeOf PRE_first_tail_x15_r0_body.s507.ffi
kernel_rfl PRE_first_tail_x15_r0_body.cpendR51 : pendRegB PRE_first_tail_x15_r0_body.kappa51 (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s507.ffi).mlx = true
kernel_rfl PRE_first_tail_x15_r0_body.cpendLe51 : Nat.ble (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s507.ffi).mlx.next (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s506.ffi).mlx.next = true
/-- **The compaction's native shift**, given the call's bookkeeping, its relation's facts (the model's and the
observers') and the canonical closedness. -/
theorem PRE_first_tail_x15_r0_body.cshift51 (clean : Conv.NClean (⟨19217, 16289, 2715383, 2264⟩ : Conv.Cnt) (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s505.ffi).mlx) (hltC : ∀ h, PH (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s505.ffi).mlx h → h < (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s505.ffi).mlx.next) (nltC : ∀ i, PN (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s505.ffi).mlx i → i < (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s505.ffi).mlx.nnext) (itemsC : ∀ k v, (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s505.ffi).mlx.items.get k = some v → PN (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s505.ffi).mlx k) (tracedC : ∀ h o, (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s505.ffi).mlx.objs.get h = some o → ∀ i ∈ objTraces o, i < PRE_first_tail_x15_r0_body.P51.NL) (cl : SSt (· < 2282) PRE_first_tail_x15_r0_body.cx0_51.mlx)
    (hobjC : ∀ h, PRE_first_tail_x15_r0_body.fxC_51.get h = some () → ((Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s505.ffi).mlx.objs.get h).isSome = true)
    (hfC : ∀ h, (PRE_first_tail_x15_r0_body.krC_51.flags.get h).isSome = true → ((Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s505.ffi).mlx.objs.get h).isSome = true)
    (htC : ∀ h, (PRE_first_tail_x15_r0_body.krC_51.targs.get h).isSome = true → ((Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s505.ffi).mlx.objs.get h).isSome = true)
    (hclC : ∀ h l, PRE_first_tail_x15_r0_body.krC_51.targs.get h = some l → Host.Ts.Sim.Full.STargs (· < (⟨19217, 16289, 2715383, 2264⟩ : Conv.Cnt).n) l) :
    Conv.FullShiftQ PRE_first_tail_x15_r0_body.P51 2282 PRE_first_tail_x15_r0_body.kappa51 PRE_first_tail_x15_r0_body.s507.ffi PRE_first_tail_x15_r0_body.s506.ffi :=
  ⟨PRE_first_tail_x15_r0_body.cnshift51 clean hltC nltC itemsC tracedC cl, PRE_first_tail_x15_r0_body.cqueue51, fun t ht => bSN_sound (List.all_eq_true.mp PRE_first_tail_x15_r0_body.ctokSupp51 t ht),
    PRE_first_tail_x15_r0_body.cbridge51,
    liveShift_foot (x0' := Host.Ts.Sim.Full.mlxOf PRE_first_tail_x15_r0_body.s507.ffi) (x1' := Host.Ts.Sim.Full.mlxOf PRE_first_tail_x15_r0_body.s506.ffi) (PRE_first_tail_x15_r0_body.cfoot51 clean hltC nltC itemsC tracedC cl) rfl PRE_first_tail_x15_r0_body.ofx0_51 PRE_first_tail_x15_r0_body.ofx1_51 hobjC PRE_first_tail_x15_r0_body.ff051 PRE_first_tail_x15_r0_body.ff151 PRE_first_tail_x15_r0_body.ffck51,
    kernShift_foot (x0' := Host.Ts.Sim.Full.mlxOf PRE_first_tail_x15_r0_body.s507.ffi) (x1' := Host.Ts.Sim.Full.mlxOf PRE_first_tail_x15_r0_body.s506.ffi) (PRE_first_tail_x15_r0_body.cfoot51 clean hltC nltC itemsC tracedC cl) rfl PRE_first_tail_x15_r0_body.okr0_51 PRE_first_tail_x15_r0_body.okr1_51 (Nat.le_of_ble_eq_true PRE_first_tail_x15_r0_body.fkn51) hfC htC hclC
      PRE_first_tail_x15_r0_body.fkf051 PRE_first_tail_x15_r0_body.fkt051 PRE_first_tail_x15_r0_body.fkf151 PRE_first_tail_x15_r0_body.fkt151 PRE_first_tail_x15_r0_body.fkck51,
    pendReg_of rfl PRE_first_tail_x15_r0_body.cnh051 PRE_first_tail_x15_r0_body.cnh151 (Nat.le_of_ble_eq_true PRE_first_tail_x15_r0_body.cpendLe51) PRE_first_tail_x15_r0_body.cpendR51⟩

end Host.Load.Run.Tpl
end

section -- st51/H0
set_option Elab.async false
namespace Host.Load.Run.Tpl
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
host_stream_state PRE_first_tail_x15_r0_body.st51 0
host_stream_state PRE_first_tail_x15_r0_body.st51 1
host_stream_state PRE_first_tail_x15_r0_body.st51 2
host_stream_state PRE_first_tail_x15_r0_body.st51 3
host_stream_state PRE_first_tail_x15_r0_body.st51 4
host_stream_state PRE_first_tail_x15_r0_body.st51 5
end Host.Load.Run.Tpl
end

section -- Site51
set_option Elab.async false
namespace Host.Load.Run.Tpl
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
open Host.Ts Host.Ts.Sim Host.Ts.Sim.Template

/-! Call site 51 of chain `PRE_first_tail_x15_r0_body`: `ssmW__g51__g52` (`recurWindow`), the call state `PRE_first_tail_x15_r0_body.s505`, the merged state `PRE_first_tail_x15_r0_body.s506`,
the site template `PRE_first_tail_x15_r0_body.st51` (σ = `Map.id`, θ the identity at its own site), the canonical state `PRE_first_tail_x15_r0_body.s507`: the merge.
The footprint's facts are in `SiteF51`, the compaction's in `SiteC51`, `SiteK51`, `SiteNa51`, `SiteNb51`. -/

kernel_rfl PRE_first_tail_x15_r0_body.iso51 : PRE_first_tail_x15_r0_body.st51.s0 = { PRE_first_tail_x15_r0_body.s505 with stack := [] }
/-- The caller's frames at the call. -/
noncomputable def PRE_first_tail_x15_r0_body.rs51 : List Frame := PRE_first_tail_x15_r0_body.s505.stack
kernel_rfl PRE_first_tail_x15_r0_body.n0_51 : PRE_first_tail_x15_r0_body.S505.tab.length = 2264
kernel_rfl PRE_first_tail_x15_r0_body.tab0_51 : PRE_first_tail_x15_r0_body.st51.S0.tab = PRE_first_tail_x15_r0_body.S505.tab

/-- The fresh variables of the stage's results. -/
def PRE_first_tail_x15_r0_body.ws51 : List Nat := [1856, 1857, 1858, 1859, 1860, 1861, 1862, 1863, 1864, 1865, 1866, 1867, 1868, 1869, 1870, 1871, 1872, 1873, 1874, 1875, 1876, 1877, 1878, 1879, 1880, 1881, 1882, 1883, 1884, 1885, 1886]
kernel_rfl PRE_first_tail_x15_r0_body.fresh51 : (PRE_first_tail_x15_r0_body.S505.tab.all fun e => PRE_first_tail_x15_r0_body.ws51.all fun v => e.noVar v) &&
    (PRE_first_tail_x15_r0_body.S505.oracle.all fun q => PRE_first_tail_x15_r0_body.ws51.all fun v => q.noVar v) = true
kernel_rfl PRE_first_tail_x15_r0_body.mergeTab51 : PRE_first_tail_x15_r0_body.S506.tab = PRE_first_tail_x15_r0_body.S505.tab ++ Conv.resTab PRE_first_tail_x15_r0_body.ws51
kernel_rfl PRE_first_tail_x15_r0_body.mergeLen51 : PRE_first_tail_x15_r0_body.st51.S5.tab.length - PRE_first_tail_x15_r0_body.st51.S0.tab.length = 31

-- The merged state: the instance's return state with the caller's frames (`PRE_first_tail_x15_r0_body.merged51`, `merged_relB`).
kernel_rfl PRE_first_tail_x15_r0_body.mheap51 : PRE_first_tail_x15_r0_body.s506.heap = PRE_first_tail_x15_r0_body.st51.s5.heap
kernel_rfl PRE_first_tail_x15_r0_body.mnext51 : PRE_first_tail_x15_r0_body.s506.next = PRE_first_tail_x15_r0_body.st51.s5.next
kernel_rfl PRE_first_tail_x15_r0_body.mctl51 : PRE_first_tail_x15_r0_body.s506.ctl = PRE_first_tail_x15_r0_body.st51.s5.ctl
kernel_rfl PRE_first_tail_x15_r0_body.mstack51 : PRE_first_tail_x15_r0_body.s506.stack = PRE_first_tail_x15_r0_body.st51.s5.stack ++ PRE_first_tail_x15_r0_body.s505.stack
kernel_rfl PRE_first_tail_x15_r0_body.mjobs51 : PRE_first_tail_x15_r0_body.s506.jobs = PRE_first_tail_x15_r0_body.st51.s5.jobs
kernel_rfl PRE_first_tail_x15_r0_body.mffi51 : PRE_first_tail_x15_r0_body.s506.ffi = PRE_first_tail_x15_r0_body.st51.s5.ffi
kernel_rfl PRE_first_tail_x15_r0_body.mtrace51 : PRE_first_tail_x15_r0_body.s506.trace = PRE_first_tail_x15_r0_body.st51.s5.trace
kernel_rfl PRE_first_tail_x15_r0_body.mstores51 : PRE_first_tail_x15_r0_body.s506.stores = PRE_first_tail_x15_r0_body.st51.s5.stores

end Host.Load.Run.Tpl
end

section -- SiteD51
set_option Elab.async false
namespace Host.Load.Run.Tpl
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
open Host.Ts Host.Ts.Sim Host.Ts.Sim.Template

/-! The canonical results at call site 51 of chain `PRE_first_tail_x15_r0_body`: their values in the instance's end table, the references past
the call's table, the canonical variables apart from the stage's. -/

kernel_rfl PRE_first_tail_x15_r0_body.cderived51 : PRE_first_tail_x15_r0_body.nr51.map (fun r => nth? PRE_first_tail_x15_r0_body.st51.S5.tab r) =
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
kernel_rfl PRE_first_tail_x15_r0_body.cnrLo51 : PRE_first_tail_x15_r0_body.nr51.all (Nat.ble 2264) = true
kernel_rfl PRE_first_tail_x15_r0_body.cwsDisj51 : PRE_first_tail_x15_r0_body.cws51.all (fun c => !PRE_first_tail_x15_r0_body.ws51.contains c) = true
/-- The compaction's substitution: the canonical variables to their merged values, the stage's other fresh variables
to `0` (`Conv.compactθZ`). -/
noncomputable def PRE_first_tail_x15_r0_body.cthetaZ51 : Nat → SymE := Conv.compactθZ PRE_first_tail_x15_r0_body.cws51 PRE_first_tail_x15_r0_body.crs51 PRE_first_tail_x15_r0_body.ws51

end Host.Load.Run.Tpl
end

section -- st51/Foot
set_option Elab.async false
namespace Host.Load.Run.Tpl
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
open Host.Ts Host.Ts.Sim Host.Ts.Sim.Stage Host.Ts.Sim.Template

/-! The footprint of stage `PRE_first_tail_x15_r0_body.st51`'s site template (`Conv.StageFoot`, `Conv.NFoot`): every entry of the return
state other than the written and fresh ones is the start's (kernel evaluation of the equalities). -/

/-- The written heap ranges below the start's counter. -/
def PRE_first_tail_x15_r0_body.st51.wrR : List (Nat × Nat) := [(2672429, 2672430), (2714557, 2714558), (2715102, 2715103), (2715358, 2715359)]
/-- The written and fresh entries of the return state. -/
noncomputable def PRE_first_tail_x15_r0_body.st51.wrE : List (Nat × Host.Ts.HObj) :=
  rangesOf PRE_first_tail_x15_r0_body.st51.s5.heap PRE_first_tail_x15_r0_body.st51.wrR ++ freshOf PRE_first_tail_x15_r0_body.st51.s5.heap PRE_first_tail_x15_r0_body.st51.s0.next PRE_first_tail_x15_r0_body.st51.s5.next
noncomputable def PRE_first_tail_x15_r0_body.st51.wr : List Nat := PRE_first_tail_x15_r0_body.st51.wrE.map (·.1)

kernel_rfl PRE_first_tail_x15_r0_body.st51.heapFoot : PRE_first_tail_x15_r0_body.st51.s5.heap = setAll PRE_first_tail_x15_r0_body.st51.s0.heap PRE_first_tail_x15_r0_body.st51.wrE
kernel_rfl PRE_first_tail_x15_r0_body.st51.grows_check : Nat.ble PRE_first_tail_x15_r0_body.st51.s0.next PRE_first_tail_x15_r0_body.st51.s5.next = true
theorem PRE_first_tail_x15_r0_body.st51.grows : PRE_first_tail_x15_r0_body.st51.s0.next ≤ PRE_first_tail_x15_r0_body.st51.s5.next := Nat.le_of_ble_eq_true PRE_first_tail_x15_r0_body.st51.grows_check

/-- The written and fresh handles; the written readback items of old nodes. -/
def PRE_first_tail_x15_r0_body.st51.wh : List Nat := [19197, 19210, 19216, 19217, 19218, 19219, 19220, 19221, 19222, 19223, 19224, 19225, 19226, 19227, 19228, 19229, 19230, 19231, 19232, 19233, 19234, 19235, 19236, 19237, 19238, 19239, 19240, 19241, 19242, 19243, 19244]
def PRE_first_tail_x15_r0_body.st51.wi : List Nat := []

kernel_rfl PRE_first_tail_x15_r0_body.st51.arrsFoot : (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.st51.s5.ffi).mlx.arrs = setAll (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.st51.s0.ffi).mlx.arrs (PRE_first_tail_x15_r0_body.st51.wh.filterMap fun h => ((Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.st51.s5.ffi).mlx.arrs.get h).map (h, ·))
kernel_rfl PRE_first_tail_x15_r0_body.st51.objsFoot : (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.st51.s5.ffi).mlx.objs = setAll (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.st51.s0.ffi).mlx.objs (PRE_first_tail_x15_r0_body.st51.wh.filterMap fun h => ((Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.st51.s5.ffi).mlx.objs.get h).map (h, ·))
kernel_rfl PRE_first_tail_x15_r0_body.st51.nodesFoot : (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.st51.s5.ffi).mlx.nodes = setAll (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.st51.s0.ffi).mlx.nodes (freshOf (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.st51.s5.ffi).mlx.nodes (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.st51.s0.ffi).mlx.nnext (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.st51.s5.ffi).mlx.nnext)
kernel_rfl PRE_first_tail_x15_r0_body.st51.itemsFoot : (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.st51.s5.ffi).mlx.items = setAll (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.st51.s0.ffi).mlx.items ((PRE_first_tail_x15_r0_body.st51.wi.filterMap fun i => ((Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.st51.s5.ffi).mlx.items.get i).map (i, ·)) ++
    freshOf (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.st51.s5.ffi).mlx.items (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.st51.s0.ffi).mlx.nnext (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.st51.s5.ffi).mlx.nnext)
kernel_rfl PRE_first_tail_x15_r0_body.st51.counters : (Nat.ble (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.st51.s0.ffi).mlx.next (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.st51.s5.ffi).mlx.next && Nat.ble (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.st51.s0.ffi).mlx.nnext (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.st51.s5.ffi).mlx.nnext) = true

end Host.Load.Run.Tpl
end

section -- SiteF51
set_option Elab.async false
namespace Host.Load.Run.Tpl
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
open Host.Ts Host.Ts.Sim Host.Ts.Sim.Template

/-! Call site 51 of chain `PRE_first_tail_x15_r0_body`: `Conv.site_merge`'s footprint facts. -/

kernel_rfl PRE_first_tail_x15_r0_body.wrNodupB51 : nodupT PRE_first_tail_x15_r0_body.st51.wr PTrie.nil = true
theorem PRE_first_tail_x15_r0_body.wrNodup51 : PRE_first_tail_x15_r0_body.st51.wr.Nodup := (nodupT_sound PRE_first_tail_x15_r0_body.wrNodupB51).2
kernel_rfl PRE_first_tail_x15_r0_body.wrBoundB51 : PRE_first_tail_x15_r0_body.st51.wr.all (fun b => Nat.blt (b / 4096) (4 ^ 31)) = true
theorem PRE_first_tail_x15_r0_body.wrBound51 : ∀ b ∈ PRE_first_tail_x15_r0_body.st51.wr, b / 4096 < 4 ^ 31 := fun b hb => Nat.blt_eq.mp (List.all_eq_true.mp PRE_first_tail_x15_r0_body.wrBoundB51 b hb)
noncomputable def PRE_first_tail_x15_r0_body.trFr51 := PRE_first_tail_x15_r0_body.st51.s5.trace.take 120
kernel_rfl PRE_first_tail_x15_r0_body.traceEq51 : PRE_first_tail_x15_r0_body.st51.s5.trace = PRE_first_tail_x15_r0_body.trFr51 ++ PRE_first_tail_x15_r0_body.st51.s0.trace
theorem PRE_first_tail_x15_r0_body.trace51 : ∃ fr, PRE_first_tail_x15_r0_body.st51.s5.trace = fr ++ PRE_first_tail_x15_r0_body.st51.s0.trace := ⟨_, PRE_first_tail_x15_r0_body.traceEq51⟩

-- the caller's wide frames at the instance's start (`Conv.isolateW`'s `W0` under `Map.id`) and their `WFix`
def PRE_first_tail_x15_r0_body.wide51 : List (Nat × WFrame) := [(4910, .memo [])]
kernel_rfl PRE_first_tail_x15_r0_body.wfixB51 : (PRE_first_tail_x15_r0_body.wide51.all fun p => wfixB Map.id (presentB PRE_first_tail_x15_r0_body.st51.s0) p.2) = true
theorem PRE_first_tail_x15_r0_body.wfix51 : ∀ p ∈ PRE_first_tail_x15_r0_body.wide51, WFix Map.id (Present PRE_first_tail_x15_r0_body.st51.s0) p.2 :=
  fun p hp => wfix_of (List.all_eq_true.mp PRE_first_tail_x15_r0_body.wfixB51 p hp)

end Host.Load.Run.Tpl
end

section -- SiteL51
set_option Elab.async false
namespace Host.Load.Run.Tpl
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
open Host.Ts Host.Ts.Sim Host.Ts.Sim.Template

/-! The call link's facts at call site 51 of chain `PRE_first_tail_x15_r0_body`: the instance's start server, its footprint (`Conv.StageFoot`), the
merged state `PRE_first_tail_x15_r0_body.s506`'s framed arrays as the chain start's extended (`arrExt_of`, `numRefs_of`). -/

kernel_rfl PRE_first_tail_x15_r0_body.srvO51 : PRE_first_tail_x15_r0_body.st51.S0.oracle = PRE_first_tail_x15_r0_body.st51.OR
kernel_rfl PRE_first_tail_x15_r0_body.wr0B51 : PRE_first_tail_x15_r0_body.st51.wr.all (fun b => !Nat.blt b PRE_first_tail_x15_r0_body.st51.s0.next || (PRE_first_tail_x15_r0_body.st51.s0.heap.get b).isSome) = true
theorem PRE_first_tail_x15_r0_body.stFoot51 : Conv.StageFoot PRE_first_tail_x15_r0_body.st51.wr PRE_first_tail_x15_r0_body.st51.s0 PRE_first_tail_x15_r0_body.st51.s5 :=
  stageFoot_of PRE_first_tail_x15_r0_body.st51.heapFoot PRE_first_tail_x15_r0_body.wrNodup51 PRE_first_tail_x15_r0_body.wrBound51 PRE_first_tail_x15_r0_body.wr0B51 PRE_first_tail_x15_r0_body.st51.grows

/-- **The relation at the merged state** from the relation at the merge (`Conv.site_merge`'s; `merged_relB`). -/
theorem PRE_first_tail_x15_r0_body.merged51 {FR : Map → Nat → PRE_first_tail_x15_r0_body.st51.F.S → PRE_first_tail_x15_r0_body.st51.F.S → Prop} {W : Nat → Option WFrame} {stk : List Frame} {M : Map}
    {ν : Nat → F64} {K : Host.Ts.Sim.Ctx} {S : SSrv} {t : St PRE_first_tail_x15_r0_body.st51.F.S} {C : CSrv} {n0 : Nat}
    (h : RelB PRE_first_tail_x15_r0_body.st51.F FR W stk M ν K (Conv.mergeSt Map.id (Map.id.res n0 n0) PRE_first_tail_x15_r0_body.rs51 PRE_first_tail_x15_r0_body.st51.wr PRE_first_tail_x15_r0_body.s505 PRE_first_tail_x15_r0_body.st51.s5 PRE_first_tail_x15_r0_body.st51.s0
      PRE_first_tail_x15_r0_body.st51.s5.ffi) S t C) : RelB PRE_first_tail_x15_r0_body.st51.F FR W stk M ν K PRE_first_tail_x15_r0_body.s506 S t C :=
  merged_relB PRE_first_tail_x15_r0_body.iso51 PRE_first_tail_x15_r0_body.stFoot51 PRE_first_tail_x15_r0_body.wrNodup51 PRE_first_tail_x15_r0_body.wrBound51 PRE_first_tail_x15_r0_body.trace51 PRE_first_tail_x15_r0_body.mheap51
    PRE_first_tail_x15_r0_body.mnext51 PRE_first_tail_x15_r0_body.mctl51 PRE_first_tail_x15_r0_body.mstack51 PRE_first_tail_x15_r0_body.mjobs51 PRE_first_tail_x15_r0_body.mffi51 PRE_first_tail_x15_r0_body.mtrace51 PRE_first_tail_x15_r0_body.mstores51 h

def PRE_first_tail_x15_r0_body.arrEl51_2665 : List Val := []
kernel_rfl PRE_first_tail_x15_r0_body.arrE51_2665 : arrOf PRE_first_tail_x15_r0_body.s506 2665 = arrOf PRE_first_tail_x15_r0_body.s0 2665 ++ PRE_first_tail_x15_r0_body.arrEl51_2665
kernel_rfl PRE_first_tail_x15_r0_body.arrA51_2665 : isArrB PRE_first_tail_x15_r0_body.s506 2665 = true
theorem PRE_first_tail_x15_r0_body.arr51_2665 : ∃ o, PRE_first_tail_x15_r0_body.s506.heap.get 2665 = some (.obj o) ∧ o.kind = .array (arrOf PRE_first_tail_x15_r0_body.s0 2665 ++ PRE_first_tail_x15_r0_body.arrEl51_2665) :=
  arrExt_of PRE_first_tail_x15_r0_body.arrE51_2665 PRE_first_tail_x15_r0_body.arrA51_2665
kernel_rfl PRE_first_tail_x15_r0_body.arrN51_2665 : numRefsB PRE_first_tail_x15_r0_body.S0.tab.length PRE_first_tail_x15_r0_body.arrEl51_2665 = true
theorem PRE_first_tail_x15_r0_body.arrR51_2665 : Prefill.NumRefs PRE_first_tail_x15_r0_body.S0.tab.length PRE_first_tail_x15_r0_body.arrEl51_2665 := numRefs_of PRE_first_tail_x15_r0_body.arrN51_2665

def PRE_first_tail_x15_r0_body.arrEl51_2673467 : List Val := []
kernel_rfl PRE_first_tail_x15_r0_body.arrE51_2673467 : arrOf PRE_first_tail_x15_r0_body.s506 2673467 = arrOf PRE_first_tail_x15_r0_body.s0 2673467 ++ PRE_first_tail_x15_r0_body.arrEl51_2673467
kernel_rfl PRE_first_tail_x15_r0_body.arrA51_2673467 : isArrB PRE_first_tail_x15_r0_body.s506 2673467 = true
theorem PRE_first_tail_x15_r0_body.arr51_2673467 : ∃ o, PRE_first_tail_x15_r0_body.s506.heap.get 2673467 = some (.obj o) ∧ o.kind = .array (arrOf PRE_first_tail_x15_r0_body.s0 2673467 ++ PRE_first_tail_x15_r0_body.arrEl51_2673467) :=
  arrExt_of PRE_first_tail_x15_r0_body.arrE51_2673467 PRE_first_tail_x15_r0_body.arrA51_2673467
kernel_rfl PRE_first_tail_x15_r0_body.arrN51_2673467 : numRefsB PRE_first_tail_x15_r0_body.S0.tab.length PRE_first_tail_x15_r0_body.arrEl51_2673467 = true
theorem PRE_first_tail_x15_r0_body.arrR51_2673467 : Prefill.NumRefs PRE_first_tail_x15_r0_body.S0.tab.length PRE_first_tail_x15_r0_body.arrEl51_2673467 := numRefs_of PRE_first_tail_x15_r0_body.arrN51_2673467

kernel_rfl PRE_first_tail_x15_r0_body.w4910k51 : isArrB PRE_first_tail_x15_r0_body.s506 4910 = false
theorem PRE_first_tail_x15_r0_body.keep51 (q : List Val) : Host.Ts.Sim.Prefill.KeepsAtW (framesP PRE_first_tail_x15_r0_body.s0 q) PRE_first_tail_x15_r0_body.s506 := by
  intro a pre pre' hx o es ho hk
  unfold framesP at hx
  simp only at hx
  cases h1 : Nat.beq a 2665
  · cases h2 : Nat.beq a 4910
    · rw [h1, h2] at hx; cases hx
    · have := Nat.eq_of_beq_eq_true h2; subst this
      rw [h1, h2] at hx; cases hx
      exact (notArr_of PRE_first_tail_x15_r0_body.w4910k51 ho hk).elim
  · have := Nat.eq_of_beq_eq_true h1; subst this
    rw [h1] at hx; cases hx
    obtain ⟨o', ho', hk'⟩ := PRE_first_tail_x15_r0_body.arr51_2665
    rw [ho] at ho'; cases ho'
    rw [hk'] at hk; cases hk
    simp [PRE_first_tail_x15_r0_body.arrEl51_2665]

end Host.Load.Run.Tpl
end

section -- SiteZ51
set_option Elab.async false
namespace Host.Load.Run.Tpl
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
open Host.Ts Host.Ts.Sim Host.Ts.Sim.Template

/-! The compaction's state shift at call site 51 of chain `PRE_first_tail_x15_r0_body` (`Conv.compact_shift`): the call `PRE_first_tail_x15_r0_body.s505`, the merged
state `PRE_first_tail_x15_r0_body.s506`, the canonical state `PRE_first_tail_x15_r0_body.s507`; its frames [2665,2673467,2673472,2673473] (kept arrays [2665,2673467]). -/

-- the map's places and counters
kernel_rfl PRE_first_tail_x15_r0_body.zpl51 : PRE_first_tail_x15_r0_body.pl51.all (Nat.ble PRE_first_tail_x15_r0_body.s505.next) = true
kernel_rfl PRE_first_tail_x15_r0_body.zplnd51 : nodupT PRE_first_tail_x15_r0_body.pl51 PTrie.nil = true
kernel_rfl PRE_first_tail_x15_r0_body.zn151 : Nat.ble PRE_first_tail_x15_r0_body.s505.next 2716538 = true
kernel_rfl PRE_first_tail_x15_r0_body.zfirst51 : Nat.ble aFirst PRE_first_tail_x15_r0_body.s505.next = true
kernel_rfl PRE_first_tail_x15_r0_body.zscn51 : PRE_first_tail_x15_r0_body.s507.next = PRE_first_tail_x15_r0_body.s505.next + PRE_first_tail_x15_r0_body.pl51.length
kernel_rfl PRE_first_tail_x15_r0_body.zsmn51 : PRE_first_tail_x15_r0_body.s506.next = 2716538
kernel_rfl PRE_first_tail_x15_r0_body.zgrow51 : Nat.ble PRE_first_tail_x15_r0_body.s507.next PRE_first_tail_x15_r0_body.s506.next = true
-- the tables
kernel_rfl PRE_first_tail_x15_r0_body.zfresh51 : PRE_first_tail_x15_r0_body.S505.tab.all (fun e => PRE_first_tail_x15_r0_body.cws51.all fun v => e.noVar v) = true
kernel_rfl PRE_first_tail_x15_r0_body.zcnd51 : nodupT PRE_first_tail_x15_r0_body.cws51 PTrie.nil = true
kernel_rfl PRE_first_tail_x15_r0_body.znrHi51 : PRE_first_tail_x15_r0_body.nr51.all (fun r => Nat.blt r PRE_first_tail_x15_r0_body.S506.tab.length) = true
-- the frames: every framed address below the call's counter; the kept arrays the chain start's, extended in the merged state
kernel_rfl PRE_first_tail_x15_r0_body.zfrlt51 : [2665, 2673467, 2673472, 2673473].all (fun a => Nat.blt a PRE_first_tail_x15_r0_body.s505.next) = true
kernel_rfl PRE_first_tail_x15_r0_body.zg51_2665 : PRE_first_tail_x15_r0_body.s507.heap.get 2665 = some (.obj (objOf PRE_first_tail_x15_r0_body.s507 2665))
kernel_rfl PRE_first_tail_x15_r0_body.zk51_2665 : (objOf PRE_first_tail_x15_r0_body.s507 2665).kind = .array (arrOf PRE_first_tail_x15_r0_body.s0 2665)
kernel_rfl PRE_first_tail_x15_r0_body.zm51_2665 : PRE_first_tail_x15_r0_body.s506.heap.get 2665 = some (.obj { PRE_first_tail_x15_r0_body.kappa51.obj (objOf PRE_first_tail_x15_r0_body.s507 2665) with
  kind := .array (arrOf PRE_first_tail_x15_r0_body.s0 2665 ++ (arrOf PRE_first_tail_x15_r0_body.s506 2665).drop (arrOf PRE_first_tail_x15_r0_body.s0 2665).length) })
kernel_rfl PRE_first_tail_x15_r0_body.zg51_2673467 : PRE_first_tail_x15_r0_body.s507.heap.get 2673467 = some (.obj (objOf PRE_first_tail_x15_r0_body.s507 2673467))
kernel_rfl PRE_first_tail_x15_r0_body.zk51_2673467 : (objOf PRE_first_tail_x15_r0_body.s507 2673467).kind = .array (arrOf PRE_first_tail_x15_r0_body.s0 2673467)
kernel_rfl PRE_first_tail_x15_r0_body.zm51_2673467 : PRE_first_tail_x15_r0_body.s506.heap.get 2673467 = some (.obj { PRE_first_tail_x15_r0_body.kappa51.obj (objOf PRE_first_tail_x15_r0_body.s507 2673467) with
  kind := .array (arrOf PRE_first_tail_x15_r0_body.s0 2673467 ++ (arrOf PRE_first_tail_x15_r0_body.s506 2673467).drop (arrOf PRE_first_tail_x15_r0_body.s0 2673467).length) })
kernel_rfl PRE_first_tail_x15_r0_body.zw51_4910 : (PRE_first_tail_x15_r0_body.s507.heap.get 4910).isSome = true
kernel_rfl PRE_first_tail_x15_r0_body.zw51_2673472 : (PRE_first_tail_x15_r0_body.s507.heap.get 2673472).isSome = true
kernel_rfl PRE_first_tail_x15_r0_body.zw51_2673473 : (PRE_first_tail_x15_r0_body.s507.heap.get 2673473).isSome = true
-- the heap: the changed list in range, holding the stage's written and fresh addresses; the canonical side's image
kernel_rfl PRE_first_tail_x15_r0_body.zclbd51 : PRE_first_tail_x15_r0_body.cl51.all (fun b => Nat.blt (b / 4096) (4 ^ 31)) = true
kernel_rfl PRE_first_tail_x15_r0_body.zwr51 : PRE_first_tail_x15_r0_body.st51.wr.all (fun b => !Nat.blt b PRE_first_tail_x15_r0_body.s505.next || PRE_first_tail_x15_r0_body.cl51.contains b) = true
def PRE_first_tail_x15_r0_body.zl51 : List Nat := PRE_first_tail_x15_r0_body.cl51.filter fun a => !(List.contains [2665, 2673467] a)
kernel_rfl PRE_first_tail_x15_r0_body.zimgE51 : PRE_first_tail_x15_r0_body.zl51.map (fun a => PRE_first_tail_x15_r0_body.s506.heap.get (PRE_first_tail_x15_r0_body.kappa51.a a)) = PRE_first_tail_x15_r0_body.zl51.map (fun a => (PRE_first_tail_x15_r0_body.s507.heap.get a).map PRE_first_tail_x15_r0_body.kappa51.hobj)
theorem PRE_first_tail_x15_r0_body.zimg51 : HeapImg PRE_first_tail_x15_r0_body.kappa51 PRE_first_tail_x15_r0_body.s507 PRE_first_tail_x15_r0_body.s506 PRE_first_tail_x15_r0_body.zl51 := PRE_first_tail_x15_r0_body.zimgE51
-- the roots and their supports
kernel_rfl PRE_first_tail_x15_r0_body.zctl51 : PRE_first_tail_x15_r0_body.s506.ctl = PRE_first_tail_x15_r0_body.kappa51.ctl PRE_first_tail_x15_r0_body.s507.ctl
kernel_rfl PRE_first_tail_x15_r0_body.zstack51 : PRE_first_tail_x15_r0_body.s506.stack = PRE_first_tail_x15_r0_body.s507.stack.map PRE_first_tail_x15_r0_body.kappa51.frame
kernel_rfl PRE_first_tail_x15_r0_body.zjobs51 : PRE_first_tail_x15_r0_body.s506.jobs = PRE_first_tail_x15_r0_body.s507.jobs.map PRE_first_tail_x15_r0_body.kappa51.job
kernel_rfl PRE_first_tail_x15_r0_body.zstores51 : PRE_first_tail_x15_r0_body.s506.stores = PRE_first_tail_x15_r0_body.kappa51.stores PRE_first_tail_x15_r0_body.s507.stores
kernel_rfl PRE_first_tail_x15_r0_body.zroots51 : checkRootsSupp PRE_first_tail_x15_r0_body.s507 2282 = true
kernel_rfl PRE_first_tail_x15_r0_body.znC51 : PRE_first_tail_x15_r0_body.S505.tab.length + PRE_first_tail_x15_r0_body.cws51.length = 2282
-- the map as `Conv.compact_shift` states it (the call's counters for the literals)
kernel_rfl PRE_first_tail_x15_r0_body.zkap51 : PRE_first_tail_x15_r0_body.kappa51 = Conv.Map.compact PRE_first_tail_x15_r0_body.s505.next 2716538 PRE_first_tail_x15_r0_body.S505.tab.length PRE_first_tail_x15_r0_body.pl51 (PRE_first_tail_x15_r0_body.nr51.map NumV.ref) PRE_first_tail_x15_r0_body.kd51.big
  PRE_first_tail_x15_r0_body.kd51.region PRE_first_tail_x15_r0_body.kd51.nodeF
-- the bridge inactive at the canonical state (`Conv.FullShiftQ.toX`; the merged state's bridge is the canonical's: cbridge)
theorem PRE_first_tail_x15_r0_body.zbin51 : (Host.Ts.Sim.Full.bridgeOf PRE_first_tail_x15_r0_body.s507.ffi).active = false := (Host.Load.Boot.replay_active Host.Load.Run.Prompt.P.oblog2818)
-- the JS bookkeeping's step (`Conv.JClean.step` over the changed list) and the canonical roots' bigint freedom
kernel_rfl PRE_first_tail_x15_r0_body.zjc51 : Conv.jcleanListB (⟨19220, 16316, 2715389, 2282⟩ : Conv.Cnt) PRE_first_tail_x15_r0_body.s507 PRE_first_tail_x15_r0_body.cl51 = true
kernel_rfl PRE_first_tail_x15_r0_body.zrootsB51 : noBigRootsP (fun i => !Conv.oldBigB (⟨19220, 16316, 2715389, 2282⟩ : Conv.Cnt) i) PRE_first_tail_x15_r0_body.s507.trace PRE_first_tail_x15_r0_body.s507 = true
kernel_rfl PRE_first_tail_x15_r0_body.zhm51 : Nat.ble (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s0.ffi).mlx.nnext 16289 = true
theorem PRE_first_tail_x15_r0_body.cjcl51 (h : Conv.JClean (⟨19217, 16289, 2715383, 2264⟩ : Conv.Cnt) PRE_first_tail_x15_r0_body.s505) : Conv.JClean (⟨19220, 16316, 2715389, 2282⟩ : Conv.Cnt) PRE_first_tail_x15_r0_body.s507 :=
  Conv.JClean.step h (Conv.Cnt.le_of_leB PRE_first_tail_x15_r0_body.cle51)
    (Conv.heap_off_setAll PRE_first_tail_x15_r0_body.cheap51 fun a ha => Nat.blt_eq.mp (List.all_eq_true.mp PRE_first_tail_x15_r0_body.zclbd51 a ha)) PRE_first_tail_x15_r0_body.zjc51

end Host.Load.Run.Tpl
end

section -- st51/TypedLast
set_option Elab.async false
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
namespace Host.Load.Run.Tpl
open Host.Ts Host.Ts.Sim Host.Ts.Sim.Template

boot_rfl PRE_first_tail_x15_r0_body.st51.bodyLast from PRE_first_tail_x15_r0_body.st51.s4 to PRE_first_tail_x15_r0_body.st51.s5 :
  interpS (step PRE_first_tail_x15_r0_body.st51.F PRE_first_tail_x15_r0_body.st51.s4).run PRE_first_tail_x15_r0_body.st51.S4 = some (PRE_first_tail_x15_r0_body.st51.s5, PRE_first_tail_x15_r0_body.st51.S5)
kernel_rfl PRE_first_tail_x15_r0_body.st51.bodyHalt : isHalt PRE_first_tail_x15_r0_body.st51.s4.ctl = false
kernel_rfl PRE_first_tail_x15_r0_body.st51.bodyTopCheck : noBlockTop PRE_first_tail_x15_r0_body.st51.s5.stack = true

end Host.Load.Run.Tpl
end

section -- st51/TypedOk
set_option Elab.async false
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
namespace Host.Load.Run.Tpl
open Host.Ts Host.Ts.Sim Host.Ts.Sim.Template

noncomputable def PRE_first_tail_x15_r0_body.st51.bodyOkL (bytes : List Byte) (rows : Nat) : St PRE_first_tail_x15_r0_body.st51.F.S → SSrv → Bool :=
  okLocal (Host.Ts.Sim.Compose.VWFrames.bodyOk bytes rows)

noncomputable def PRE_first_tail_x15_r0_body.st51.bodyOkLN (bytes : List Byte) (rows : Nat) : St PRE_first_tail_x15_r0_body.st51.F.S → FSrv → Bool :=
  okLocalN (Host.Ts.Sim.Compose.VWFrames.bodyOkN bytes rows)

theorem PRE_first_tail_x15_r0_body.st51.bodyOkLN_ok (bytes : List Byte) (rows : Nat) (s : St PRE_first_tail_x15_r0_body.st51.F.S) (c : FSrv) (h : c.Wf) :
    PRE_first_tail_x15_r0_body.st51.bodyOkLN bytes rows s c = PRE_first_tail_x15_r0_body.st51.bodyOkL bytes rows s c.toS :=
  okLocalN_ok (Host.Ts.Sim.Compose.VWFrames.bodyOkN_ok bytes rows) s c h

kernel_rfl PRE_first_tail_x15_r0_body.st51.bodyAccepted0 :
  (fun (bytes : List Byte) (rows : Nat) => PRE_first_tail_x15_r0_body.st51.bodyOkL bytes rows PRE_first_tail_x15_r0_body.st51.s0 PRE_first_tail_x15_r0_body.st51.S0) = fun _ _ => true

kernel_rfl PRE_first_tail_x15_r0_body.st51.bodyAccepted1 :
  (fun (bytes : List Byte) (rows : Nat) => PRE_first_tail_x15_r0_body.st51.bodyOkL bytes rows PRE_first_tail_x15_r0_body.st51.s4 PRE_first_tail_x15_r0_body.st51.S4) = fun _ _ => true

end Host.Load.Run.Tpl
end

section -- st51/TypedK0
set_option Elab.async false
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
namespace Host.Load.Run.Tpl
open Host.Ts Host.Ts.Sim Host.Ts.Sim.Template

boot_rfl PRE_first_tail_x15_r0_body.st51.bodyK0F from PRE_first_tail_x15_r0_body.st51.s0 to PRE_first_tail_x15_r0_body.st51.s1 :
  (fun (bytes : List Byte) (rows : Nat) => runOkS PRE_first_tail_x15_r0_body.st51.F (PRE_first_tail_x15_r0_body.st51.bodyOkLN bytes rows)
    ((nth? PRE_first_tail_x15_r0_body.st51.ks 0).getD 0) PRE_first_tail_x15_r0_body.st51.s0 PRE_first_tail_x15_r0_body.st51.S0) = fun _ _ => some (PRE_first_tail_x15_r0_body.st51.s1, PRE_first_tail_x15_r0_body.st51.S1)
theorem PRE_first_tail_x15_r0_body.st51.bodyK0 :
  (fun (bytes : List Byte) (rows : Nat) => runOk PRE_first_tail_x15_r0_body.st51.F (PRE_first_tail_x15_r0_body.st51.bodyOkL bytes rows)
    ((nth? PRE_first_tail_x15_r0_body.st51.ks 0).getD 0) PRE_first_tail_x15_r0_body.st51.s0 PRE_first_tail_x15_r0_body.st51.S0) = fun _ _ => some (PRE_first_tail_x15_r0_body.st51.s1, PRE_first_tail_x15_r0_body.st51.S1) :=
  runOk_fun_of_runOkS PRE_first_tail_x15_r0_body.st51.bodyOkLN_ok PRE_first_tail_x15_r0_body.st51.bodyK0F
end Host.Load.Run.Tpl
end

section -- st51/TypedK1
set_option Elab.async false
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
namespace Host.Load.Run.Tpl
open Host.Ts Host.Ts.Sim Host.Ts.Sim.Template

boot_rfl PRE_first_tail_x15_r0_body.st51.bodyK1F from PRE_first_tail_x15_r0_body.st51.s1 to PRE_first_tail_x15_r0_body.st51.s2 :
  (fun (bytes : List Byte) (rows : Nat) => runOkS PRE_first_tail_x15_r0_body.st51.F (PRE_first_tail_x15_r0_body.st51.bodyOkLN bytes rows)
    ((nth? PRE_first_tail_x15_r0_body.st51.ks 1).getD 0) PRE_first_tail_x15_r0_body.st51.s1 PRE_first_tail_x15_r0_body.st51.S1) = fun _ _ => some (PRE_first_tail_x15_r0_body.st51.s2, PRE_first_tail_x15_r0_body.st51.S2)
theorem PRE_first_tail_x15_r0_body.st51.bodyK1 :
  (fun (bytes : List Byte) (rows : Nat) => runOk PRE_first_tail_x15_r0_body.st51.F (PRE_first_tail_x15_r0_body.st51.bodyOkL bytes rows)
    ((nth? PRE_first_tail_x15_r0_body.st51.ks 1).getD 0) PRE_first_tail_x15_r0_body.st51.s1 PRE_first_tail_x15_r0_body.st51.S1) = fun _ _ => some (PRE_first_tail_x15_r0_body.st51.s2, PRE_first_tail_x15_r0_body.st51.S2) :=
  runOk_fun_of_runOkS PRE_first_tail_x15_r0_body.st51.bodyOkLN_ok PRE_first_tail_x15_r0_body.st51.bodyK1F
end Host.Load.Run.Tpl
end

section -- st51/TypedK2
set_option Elab.async false
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
namespace Host.Load.Run.Tpl
open Host.Ts Host.Ts.Sim Host.Ts.Sim.Template

boot_rfl PRE_first_tail_x15_r0_body.st51.bodyK2F from PRE_first_tail_x15_r0_body.st51.s2 to PRE_first_tail_x15_r0_body.st51.s3 :
  (fun (bytes : List Byte) (rows : Nat) => runOkS PRE_first_tail_x15_r0_body.st51.F (PRE_first_tail_x15_r0_body.st51.bodyOkLN bytes rows)
    ((nth? PRE_first_tail_x15_r0_body.st51.ks 2).getD 0) PRE_first_tail_x15_r0_body.st51.s2 PRE_first_tail_x15_r0_body.st51.S2) = fun _ _ => some (PRE_first_tail_x15_r0_body.st51.s3, PRE_first_tail_x15_r0_body.st51.S3)
theorem PRE_first_tail_x15_r0_body.st51.bodyK2 :
  (fun (bytes : List Byte) (rows : Nat) => runOk PRE_first_tail_x15_r0_body.st51.F (PRE_first_tail_x15_r0_body.st51.bodyOkL bytes rows)
    ((nth? PRE_first_tail_x15_r0_body.st51.ks 2).getD 0) PRE_first_tail_x15_r0_body.st51.s2 PRE_first_tail_x15_r0_body.st51.S2) = fun _ _ => some (PRE_first_tail_x15_r0_body.st51.s3, PRE_first_tail_x15_r0_body.st51.S3) :=
  runOk_fun_of_runOkS PRE_first_tail_x15_r0_body.st51.bodyOkLN_ok PRE_first_tail_x15_r0_body.st51.bodyK2F
end Host.Load.Run.Tpl
end

section -- st51/TypedK3
set_option Elab.async false
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
namespace Host.Load.Run.Tpl
open Host.Ts Host.Ts.Sim Host.Ts.Sim.Template

boot_rfl PRE_first_tail_x15_r0_body.st51.bodyK3F from PRE_first_tail_x15_r0_body.st51.s3 to PRE_first_tail_x15_r0_body.st51.s4 :
  (fun (bytes : List Byte) (rows : Nat) => runOkS PRE_first_tail_x15_r0_body.st51.F (PRE_first_tail_x15_r0_body.st51.bodyOkLN bytes rows)
    ((nth? PRE_first_tail_x15_r0_body.st51.ks 3).getD 0) PRE_first_tail_x15_r0_body.st51.s3 PRE_first_tail_x15_r0_body.st51.S3) = fun _ _ => some (PRE_first_tail_x15_r0_body.st51.s4, PRE_first_tail_x15_r0_body.st51.S4)
theorem PRE_first_tail_x15_r0_body.st51.bodyK3 :
  (fun (bytes : List Byte) (rows : Nat) => runOk PRE_first_tail_x15_r0_body.st51.F (PRE_first_tail_x15_r0_body.st51.bodyOkL bytes rows)
    ((nth? PRE_first_tail_x15_r0_body.st51.ks 3).getD 0) PRE_first_tail_x15_r0_body.st51.s3 PRE_first_tail_x15_r0_body.st51.S3) = fun _ _ => some (PRE_first_tail_x15_r0_body.st51.s4, PRE_first_tail_x15_r0_body.st51.S4) :=
  runOk_fun_of_runOkS PRE_first_tail_x15_r0_body.st51.bodyOkLN_ok PRE_first_tail_x15_r0_body.st51.bodyK3F
end Host.Load.Run.Tpl
end

section -- st51/TypedTpl
set_option Elab.async false
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
namespace Host.Load.Run.Tpl
open Host.Ts Host.Ts.Sim Host.Ts.Sim.Template

theorem PRE_first_tail_x15_r0_body.st51.bodyRun (bytes : List Byte) (rows : Nat) :
    runOk PRE_first_tail_x15_r0_body.st51.F (PRE_first_tail_x15_r0_body.st51.bodyOkL bytes rows) 11334 PRE_first_tail_x15_r0_body.st51.s0 PRE_first_tail_x15_r0_body.st51.S0 = some (PRE_first_tail_x15_r0_body.st51.s4, PRE_first_tail_x15_r0_body.st51.S4) :=
  runOk_trans PRE_first_tail_x15_r0_body.st51.F (PRE_first_tail_x15_r0_body.st51.bodyOkL bytes rows) ((((nth? PRE_first_tail_x15_r0_body.st51.ks 0).getD 0) + ((nth? PRE_first_tail_x15_r0_body.st51.ks 1).getD 0)) + ((nth? PRE_first_tail_x15_r0_body.st51.ks 2).getD 0)) ((nth? PRE_first_tail_x15_r0_body.st51.ks 3).getD 0) PRE_first_tail_x15_r0_body.st51.s0 PRE_first_tail_x15_r0_body.st51.s3 PRE_first_tail_x15_r0_body.st51.s4 PRE_first_tail_x15_r0_body.st51.S0 PRE_first_tail_x15_r0_body.st51.S3 PRE_first_tail_x15_r0_body.st51.S4 (runOk_trans PRE_first_tail_x15_r0_body.st51.F (PRE_first_tail_x15_r0_body.st51.bodyOkL bytes rows) (((nth? PRE_first_tail_x15_r0_body.st51.ks 0).getD 0) + ((nth? PRE_first_tail_x15_r0_body.st51.ks 1).getD 0)) ((nth? PRE_first_tail_x15_r0_body.st51.ks 2).getD 0) PRE_first_tail_x15_r0_body.st51.s0 PRE_first_tail_x15_r0_body.st51.s2 PRE_first_tail_x15_r0_body.st51.s3 PRE_first_tail_x15_r0_body.st51.S0 PRE_first_tail_x15_r0_body.st51.S2 PRE_first_tail_x15_r0_body.st51.S3 (runOk_trans PRE_first_tail_x15_r0_body.st51.F (PRE_first_tail_x15_r0_body.st51.bodyOkL bytes rows) ((nth? PRE_first_tail_x15_r0_body.st51.ks 0).getD 0) ((nth? PRE_first_tail_x15_r0_body.st51.ks 1).getD 0) PRE_first_tail_x15_r0_body.st51.s0 PRE_first_tail_x15_r0_body.st51.s1 PRE_first_tail_x15_r0_body.st51.s2 PRE_first_tail_x15_r0_body.st51.S0 PRE_first_tail_x15_r0_body.st51.S1 PRE_first_tail_x15_r0_body.st51.S2 ((congrFun (congrFun PRE_first_tail_x15_r0_body.st51.bodyK0 bytes) rows)) (congrFun (congrFun PRE_first_tail_x15_r0_body.st51.bodyK1 bytes) rows)) (congrFun (congrFun PRE_first_tail_x15_r0_body.st51.bodyK2 bytes) rows)) (congrFun (congrFun PRE_first_tail_x15_r0_body.st51.bodyK3 bytes) rows)

theorem PRE_first_tail_x15_r0_body.st51.bodyLocal (bytes : List Byte) (rows : Nat) : ∀ s S, PRE_first_tail_x15_r0_body.st51.bodyOkL bytes rows s S = true → Disp.localB s = true := okLocal_localB

noncomputable def PRE_first_tail_x15_r0_body.st51.bodyTpl (bytes : List Byte) (rows : Nat) : Host.Ts.Sim.Stage.StageTpl PRE_first_tail_x15_r0_body.st51.F (PRE_first_tail_x15_r0_body.st51.bodyOkL bytes rows) where
  s0 := PRE_first_tail_x15_r0_body.st51.s0
  S0 := PRE_first_tail_x15_r0_body.st51.S0
  s1 := PRE_first_tail_x15_r0_body.st51.s4
  S1 := PRE_first_tail_x15_r0_body.st51.S4
  s2 := PRE_first_tail_x15_r0_body.st51.s5
  S2 := PRE_first_tail_x15_r0_body.st51.S5
  n := 11334
  ok0 := congrFun (congrFun PRE_first_tail_x15_r0_body.st51.bodyAccepted0 bytes) rows
  run := PRE_first_tail_x15_r0_body.st51.bodyRun bytes rows
  ok1 := congrFun (congrFun PRE_first_tail_x15_r0_body.st51.bodyAccepted1 bytes) rows
  halt := PRE_first_tail_x15_r0_body.st51.bodyHalt
  last := PRE_first_tail_x15_r0_body.st51.bodyLast
  top := noBlockTop_sound PRE_first_tail_x15_r0_body.st51.bodyTopCheck
end Host.Load.Run.Tpl
end

section -- SiteC52
set_option Elab.async false
namespace Host.Load.Run.Tpl
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
open Host.Ts Host.Ts.Sim Host.Ts.Sim.Template

/-! The compaction after the merge at call site 52 of chain `PRE_first_tail_x15_r0_body` (`Conv.compact`, `Conv.full_compactQ`): the canonical
state `PRE_first_tail_x15_r0_body.s515` (the stage's results at canonical places, its trace the call's) under `PRE_first_tail_x15_r0_body.kappa52` into the merged state
`PRE_first_tail_x15_r0_body.s514`. -/

def PRE_first_tail_x15_r0_body.pl52 : List Nat := []
def PRE_first_tail_x15_r0_body.nr52 : List Nat := []
/-- The native part of the compaction map (canonical → merged handles and nodes: its `big`, `region`, `nodeF`). -/
def PRE_first_tail_x15_r0_body.kd52 : RData :=
  ⟨2715879, 2715881, Stage.setAll PTrie.nil [], Stage.setAll PTrie.nil [],
   19233, 19233, 16329, 16329, Stage.setAll PTrie.nil [],
   Stage.setAll PTrie.nil []⟩
/-- **The compaction map.** -/
noncomputable def PRE_first_tail_x15_r0_body.kappa52 : Map :=
  Conv.Map.compact 2715879 2715881 2303 PRE_first_tail_x15_r0_body.pl52 (PRE_first_tail_x15_r0_body.nr52.map NumV.ref) PRE_first_tail_x15_r0_body.kd52.big
    PRE_first_tail_x15_r0_body.kd52.region PRE_first_tail_x15_r0_body.kd52.nodeF
/-- The canonical result variables and their images, the merged state's entries (`Conv.compactθ`). -/
def PRE_first_tail_x15_r0_body.cws52 : List Nat := []
noncomputable def PRE_first_tail_x15_r0_body.crs52 : List SymE := PRE_first_tail_x15_r0_body.nr52.map fun r => (nth? PRE_first_tail_x15_r0_body.S514.tab r).getD (.var 0)
noncomputable def PRE_first_tail_x15_r0_body.ctheta52 : Nat → SymE := Conv.compactθ PRE_first_tail_x15_r0_body.cws52 PRE_first_tail_x15_r0_body.crs52
/-- The call's entries the stage wrote (renamed in the canonical state with the results). -/
def PRE_first_tail_x15_r0_body.wrB52 : List Nat := [2665, 2673467]

kernel_rfl PRE_first_tail_x15_r0_body.ctab52 : PRE_first_tail_x15_r0_body.S515.tab = PRE_first_tail_x15_r0_body.S513.tab ++ PRE_first_tail_x15_r0_body.cws52.map SymE.var
kernel_rfl PRE_first_tail_x15_r0_body.ctrace52 : PRE_first_tail_x15_r0_body.s515.trace = PRE_first_tail_x15_r0_body.s513.trace
kernel_rfl PRE_first_tail_x15_r0_body.cnext52 : PRE_first_tail_x15_r0_body.s515.next = 2715879
kernel_rfl PRE_first_tail_x15_r0_body.ccounters52 : ((Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s515.ffi).mlx.next, (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s515.ffi).mlx.nnext) = (19233, 16329)
-- the merged state's readback queue, carried to the canonical state (`Conv.FullShiftQ.tokens`, `tokSupp`)
kernel_rfl PRE_first_tail_x15_r0_body.cqueue52 : (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s514.ffi).mlx.tokens = (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s515.ffi).mlx.tokens.map PRE_first_tail_x15_r0_body.kappa52.nv
kernel_rfl PRE_first_tail_x15_r0_body.ctokSupp52 : (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s515.ffi).mlx.tokens.all (bSN 2303) = true
-- the written and the result entries carry no bigint of the canonical fresh band [next, E) and no fresh region
kernel_rfl PRE_first_tail_x15_r0_body.cclean52 : Conv.cleanListB 19233 131072 (fun r => Nat.ble 76932 r) PRE_first_tail_x15_r0_body.s515
    (PRE_first_tail_x15_r0_body.wrB52 ++ (List.range 0).map (2715879 + ·)) = true
kernel_rfl PRE_first_tail_x15_r0_body.cbigs52 : bigsOutB 19233 131072 (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s515.ffi).mlx = true

end Host.Load.Run.Tpl
end

section -- SiteK52
set_option Elab.async false
namespace Host.Load.Run.Tpl
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
open Host.Ts Host.Ts.Sim Host.Ts.Sim.Template

/-! The canonical state's closedness from the call's (`Conv.closed_of_callB`, `Conv.sst_of_callB`): it keeps the call's entries
off the written and the result ones (`PRE_first_tail_x15_r0_body.cl52`; natively the written and result handles, the result nodes, the written
and result items), and those are checked. -/

def PRE_first_tail_x15_r0_body.cl52 : List Nat := [2665, 2673467]
def PRE_first_tail_x15_r0_body.clo52 : List Nat := []
def PRE_first_tail_x15_r0_body.cln52 : List Nat := []
def PRE_first_tail_x15_r0_body.cli52 : List Nat := []
kernel_rfl PRE_first_tail_x15_r0_body.cheap52 : PRE_first_tail_x15_r0_body.s515.heap = Stage.setAll PRE_first_tail_x15_r0_body.s513.heap (PRE_first_tail_x15_r0_body.cl52.filterMap fun a => (PRE_first_tail_x15_r0_body.s515.heap.get a).map (a, ·))
kernel_rfl PRE_first_tail_x15_r0_body.cnextLe52 : Nat.ble PRE_first_tail_x15_r0_body.s513.next PRE_first_tail_x15_r0_body.s515.next = true
kernel_rfl PRE_first_tail_x15_r0_body.ckeepP52 : Conv.keptPresentB PRE_first_tail_x15_r0_body.s513 PRE_first_tail_x15_r0_body.s515 PRE_first_tail_x15_r0_body.cl52 = true
kernel_rfl PRE_first_tail_x15_r0_body.csupp52 : Conv.suppListB PRE_first_tail_x15_r0_body.s515 2303 PRE_first_tail_x15_r0_body.cl52 = true
kernel_rfl PRE_first_tail_x15_r0_body.cbound52 : Conv.boundListB PRE_first_tail_x15_r0_body.s515 PRE_first_tail_x15_r0_body.cl52 = true
kernel_rfl PRE_first_tail_x15_r0_body.cnodesK52 : (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s515.ffi).mlx.nodes = Stage.setAll (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s513.ffi).mlx.nodes (PRE_first_tail_x15_r0_body.cln52.filterMap fun i => ((Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s515.ffi).mlx.nodes.get i).map (i, ·))
kernel_rfl PRE_first_tail_x15_r0_body.cobjsK52 : (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s515.ffi).mlx.objs = Stage.setAll (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s513.ffi).mlx.objs (PRE_first_tail_x15_r0_body.clo52.filterMap fun i => ((Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s515.ffi).mlx.objs.get i).map (i, ·))
kernel_rfl PRE_first_tail_x15_r0_body.citemsK52 : (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s515.ffi).mlx.items = Stage.setAll (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s513.ffi).mlx.items (PRE_first_tail_x15_r0_body.cli52.filterMap fun i => ((Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s515.ffi).mlx.items.get i).map (i, ·))
kernel_rfl PRE_first_tail_x15_r0_body.csst52 : Conv.sstListB 2303 (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s515.ffi).mlx PRE_first_tail_x15_r0_body.cln52 PRE_first_tail_x15_r0_body.clo52 PRE_first_tail_x15_r0_body.cli52 = true

end Host.Load.Run.Tpl
end

section -- SiteCl52
set_option Elab.async false
namespace Host.Load.Run.Tpl
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
open Host.Ts Host.Ts.Sim Host.Ts.Sim.Template

kernel_rfl PRE_first_tail_x15_r0_body.ckA52 : (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s515.ffi).mlx.arrs = Stage.setAll (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s513.ffi).mlx.arrs (PRE_first_tail_x15_r0_body.clo52.filterMap fun i => ((Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s515.ffi).mlx.arrs.get i).map (i, ·))
kernel_rfl PRE_first_tail_x15_r0_body.cbd52 : (PRE_first_tail_x15_r0_body.clo52 ++ PRE_first_tail_x15_r0_body.cln52 ++ PRE_first_tail_x15_r0_body.cli52).all (fun i => Nat.blt (i / 4096) (4 ^ 31)) = true
kernel_rfl PRE_first_tail_x15_r0_body.cle52 : Conv.Cnt.leB (⟨19233, 16329, 2715879, 2303⟩ : Conv.Cnt) (⟨19233, 16329, 2715879, 2303⟩ : Conv.Cnt) = true
kernel_rfl PRE_first_tail_x15_r0_body.cck52 : Conv.ncleanListB (⟨19233, 16329, 2715879, 2303⟩ : Conv.Cnt) (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s515.ffi).mlx PRE_first_tail_x15_r0_body.clo52 PRE_first_tail_x15_r0_body.cln52 PRE_first_tail_x15_r0_body.cli52 = true
theorem PRE_first_tail_x15_r0_body.cncl52 (h : Conv.NClean (⟨19233, 16329, 2715879, 2303⟩ : Conv.Cnt) (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s513.ffi).mlx) : Conv.NClean (⟨19233, 16329, 2715879, 2303⟩ : Conv.Cnt) (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s515.ffi).mlx :=
  Conv.NClean.stepKeep h PRE_first_tail_x15_r0_body.cle52 PRE_first_tail_x15_r0_body.ckA52 PRE_first_tail_x15_r0_body.cobjsK52 PRE_first_tail_x15_r0_body.cnodesK52 PRE_first_tail_x15_r0_body.citemsK52 PRE_first_tail_x15_r0_body.cbd52 PRE_first_tail_x15_r0_body.cck52

end Host.Load.Run.Tpl
end

section -- SiteS52
set_option Elab.async false
namespace Host.Load.Run.Tpl
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
open Host.Ts Host.Ts.Sim Host.Ts.Sim.Template

/-! The compaction's native shift at call site 52 from its footprint (`Conv.nshift_of_foot`), and the observers'
(`liveShift_foot`, `kernShift_foot`): `Conv.FullShiftQ` for `Conv.full_compactQ`, given the call's bookkeeping and its
relation's facts. -/

/-- The load parameters of the chain (band-free: its start's node counter as `NL` and `N0`). -/
def PRE_first_tail_x15_r0_body.Pc52 : LoadP := ⟨18151, 131072, 1099511627776, 15235, 15235, []⟩
/-- The site's band raised to the map's checked fixed-node prefix, including newly recorded closure traces. -/
def PRE_first_tail_x15_r0_body.P52 : LoadP := PRE_first_tail_x15_r0_body.Pc52.raise 16329
kernel_rfl PRE_first_tail_x15_r0_body.craise52 : Nat.ble PRE_first_tail_x15_r0_body.Pc52.N0 16329 = true
theorem PRE_first_tail_x15_r0_body.raised52 : Host.Ts.Sim.Full.Raised PRE_first_tail_x15_r0_body.Pc52 PRE_first_tail_x15_r0_body.P52 :=
  .inr ⟨16329, rfl, Nat.le_of_ble_eq_true PRE_first_tail_x15_r0_body.craise52, rfl⟩
noncomputable abbrev PRE_first_tail_x15_r0_body.cx0_52 : Host.Load.LSt := clearTokens (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s515.ffi)
noncomputable abbrev PRE_first_tail_x15_r0_body.cx1_52 : Host.Load.LSt := clearTokens (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s514.ffi)
def PRE_first_tail_x15_r0_body.khinv52 : PTrie Nat := Stage.setAll PTrie.nil []
def PRE_first_tail_x15_r0_body.kninv52 : PTrie Nat := Stage.setAll PTrie.nil []
/-- The stage's footprint: its written and fresh handles, fresh nodes, written and fresh items. -/
def PRE_first_tail_x15_r0_body.cwS52 : List Nat := []
def PRE_first_tail_x15_r0_body.cnS52 : List Nat := List.range' 16329 0
def PRE_first_tail_x15_r0_body.ciS52 : List Nat := [] ++ List.range' 16329 0

-- the small checks (`MChecks`'s)
kernel_rfl PRE_first_tail_x15_r0_body.cnh052 : PRE_first_tail_x15_r0_body.kd52.nh0 = PRE_first_tail_x15_r0_body.cx0_52.mlx.next
kernel_rfl PRE_first_tail_x15_r0_body.cnh152 : PRE_first_tail_x15_r0_body.kd52.nh1 = PRE_first_tail_x15_r0_body.cx1_52.mlx.next
kernel_rfl PRE_first_tail_x15_r0_body.cnn052 : PRE_first_tail_x15_r0_body.kd52.nn0 = PRE_first_tail_x15_r0_body.cx0_52.mlx.nnext
kernel_rfl PRE_first_tail_x15_r0_body.cnn152 : PRE_first_tail_x15_r0_body.kd52.nn1 = PRE_first_tail_x15_r0_body.cx1_52.mlx.nnext
kernel_rfl PRE_first_tail_x15_r0_body.cplo52 : (Nat.blt 0 PRE_first_tail_x15_r0_body.P52.lo && Nat.ble PRE_first_tail_x15_r0_body.P52.lo PRE_first_tail_x15_r0_body.cx0_52.mlx.next && Nat.ble PRE_first_tail_x15_r0_body.P52.lo RData.bigHi && Nat.ble RData.bigHi PRE_first_tail_x15_r0_body.P52.E) = true
kernel_rfl PRE_first_tail_x15_r0_body.ccnt52 : (Nat.ble PRE_first_tail_x15_r0_body.cx0_52.mlx.next PRE_first_tail_x15_r0_body.cx1_52.mlx.next && Nat.ble PRE_first_tail_x15_r0_body.cx0_52.mlx.nnext PRE_first_tail_x15_r0_body.cx1_52.mlx.nnext) = true
kernel_rfl PRE_first_tail_x15_r0_body.cnband52 : (Nat.blt 0 PRE_first_tail_x15_r0_body.P52.NL && Nat.ble PRE_first_tail_x15_r0_body.P52.NL PRE_first_tail_x15_r0_body.P52.N0 && Nat.ble PRE_first_tail_x15_r0_body.P52.N0 PRE_first_tail_x15_r0_body.cx0_52.mlx.nnext) = true
kernel_rfl PRE_first_tail_x15_r0_body.chbelow52 : PRE_first_tail_x15_r0_body.kd52.checkHndBelow = true
kernel_rfl PRE_first_tail_x15_r0_body.chren52 : checkRenG PRE_first_tail_x15_r0_body.kd52.hnd PRE_first_tail_x15_r0_body.khinv52 (phB PRE_first_tail_x15_r0_body.cx0_52.mlx) = true
kernel_rfl PRE_first_tail_x15_r0_body.cband52 : PRE_first_tail_x15_r0_body.kd52.checkBand PRE_first_tail_x15_r0_body.P52.lo = true
kernel_rfl PRE_first_tail_x15_r0_body.cnh1pos52 : Nat.blt 0 PRE_first_tail_x15_r0_body.kd52.nh1 = true
kernel_rfl PRE_first_tail_x15_r0_body.cnren52 : checkRenG PRE_first_tail_x15_r0_body.kd52.node PRE_first_tail_x15_r0_body.kninv52 (pnB PRE_first_tail_x15_r0_body.cx0_52.mlx) = true
kernel_rfl PRE_first_tail_x15_r0_body.cnlow52 : (PTrie.keysA PRE_first_tail_x15_r0_body.kd52.node).all (fun j => Nat.ble PRE_first_tail_x15_r0_body.P52.NL j && Nat.blt (PRE_first_tail_x15_r0_body.kd52.nodeF j) PRE_first_tail_x15_r0_body.cx1_52.mlx.nnext) = true
kernel_rfl PRE_first_tail_x15_r0_body.cabs0a52 : PRE_first_tail_x15_r0_body.cx0_52.mlx.arrs.get 0 = none
kernel_rfl PRE_first_tail_x15_r0_body.cabs0b52 : PRE_first_tail_x15_r0_body.cx0_52.mlx.objs.get 0 = none
kernel_rfl PRE_first_tail_x15_r0_body.ctok152 : PRE_first_tail_x15_r0_body.cx1_52.mlx.tokens = []
kernel_rfl PRE_first_tail_x15_r0_body.cpend52 : PRE_first_tail_x15_r0_body.cx1_52.mlx.pending = PRE_first_tail_x15_r0_body.cx0_52.mlx.pending.map PRE_first_tail_x15_r0_body.kappa52.pend
kernel_rfl PRE_first_tail_x15_r0_body.cerrh52 : PRE_first_tail_x15_r0_body.cx1_52.mlx.errh = PRE_first_tail_x15_r0_body.cx0_52.mlx.errh.map PRE_first_tail_x15_r0_body.kappa52.arg
kernel_rfl PRE_first_tail_x15_r0_body.cfiles52 : PRE_first_tail_x15_r0_body.cx1_52.mlx.files = PRE_first_tail_x15_r0_body.cx0_52.mlx.files
kernel_rfl PRE_first_tail_x15_r0_body.carch52 : PRE_first_tail_x15_r0_body.cx1_52.mlx.arch = PRE_first_tail_x15_r0_body.cx0_52.mlx.arch
kernel_rfl PRE_first_tail_x15_r0_body.csizes52 : PRE_first_tail_x15_r0_body.cx1_52.mlx.deviceSizes = PRE_first_tail_x15_r0_body.cx0_52.mlx.deviceSizes
kernel_rfl PRE_first_tail_x15_r0_body.cwired52 : PRE_first_tail_x15_r0_body.cx1_52.mlx.wired = PRE_first_tail_x15_r0_body.cx0_52.mlx.wired
kernel_rfl PRE_first_tail_x15_r0_body.chost52 : PRE_first_tail_x15_r0_body.cx1_52.host = PRE_first_tail_x15_r0_body.cx0_52.host
-- the compaction map's addresses are `PRE_first_tail_x15_r0_body.kd52`'s
kernel_rfl PRE_first_tail_x15_r0_body.ckn052 : PRE_first_tail_x15_r0_body.kd52.n0 = 2715879
kernel_rfl PRE_first_tail_x15_r0_body.ckn152 : PRE_first_tail_x15_r0_body.kd52.n1 = 2715881
kernel_rfl PRE_first_tail_x15_r0_body.ckheap52 : (PTrie.keysA PRE_first_tail_x15_r0_body.kd52.heap).all (fun x => Nat.ble 2715879 x) = true
kernel_rfl PRE_first_tail_x15_r0_body.ckpl52 : (List.range 0).all (fun j => decide (PRE_first_tail_x15_r0_body.kd52.heap.get (2715879 + j) = nth? PRE_first_tail_x15_r0_body.pl52 j)) = true
-- the map fixes the call's names (`Conv.fixOld_compact`), the call's counters
kernel_rfl PRE_first_tail_x15_r0_body.fja52 : Nat.ble 2715879 2715879 = true
kernel_rfl PRE_first_tail_x15_r0_body.fn52 : Nat.ble 2303 2303 = true
kernel_rfl PRE_first_tail_x15_r0_body.fjaD52 : Nat.ble 2715879 PRE_first_tail_x15_r0_body.kd52.n0 = true
kernel_rfl PRE_first_tail_x15_r0_body.fxn52 : Nat.ble 19233 PRE_first_tail_x15_r0_body.kd52.nh0 = true
kernel_rfl PRE_first_tail_x15_r0_body.fnn52 : Nat.ble 16329 PRE_first_tail_x15_r0_body.kd52.nn0 = true
kernel_rfl PRE_first_tail_x15_r0_body.fxb52 : Nat.ble 19233 RData.bigHi = true
kernel_rfl PRE_first_tail_x15_r0_body.fheap52 : (PTrie.keysA PRE_first_tail_x15_r0_body.kd52.heap).all (Nat.ble (⟨19233, 16329, 2715879, 2303⟩ : Conv.Cnt).ja) = true
kernel_rfl PRE_first_tail_x15_r0_body.fhnd52 : (PTrie.keysA PRE_first_tail_x15_r0_body.kd52.hnd).all (Nat.ble (⟨19233, 16329, 2715879, 2303⟩ : Conv.Cnt).xn) = true
kernel_rfl PRE_first_tail_x15_r0_body.fnode52 : (PTrie.keysA PRE_first_tail_x15_r0_body.kd52.node).all (Nat.ble (⟨19233, 16329, 2715879, 2303⟩ : Conv.Cnt).nn) = true
/-- The compaction map fixes the call's names. -/
theorem PRE_first_tail_x15_r0_body.cfix52 : Conv.FixOld (⟨19233, 16329, 2715879, 2303⟩ : Conv.Cnt) PRE_first_tail_x15_r0_body.kappa52 :=
  Conv.fixOld_compact (Nat.le_of_ble_eq_true PRE_first_tail_x15_r0_body.fja52) (Nat.le_of_ble_eq_true PRE_first_tail_x15_r0_body.fn52) (Nat.le_of_ble_eq_true PRE_first_tail_x15_r0_body.fjaD52) (Nat.le_of_ble_eq_true PRE_first_tail_x15_r0_body.fxn52) (Nat.le_of_ble_eq_true PRE_first_tail_x15_r0_body.fnn52) (Nat.le_of_ble_eq_true PRE_first_tail_x15_r0_body.fxb52) PRE_first_tail_x15_r0_body.fheap52 PRE_first_tail_x15_r0_body.fhnd52 PRE_first_tail_x15_r0_body.fnode52
kernel_rfl PRE_first_tail_x15_r0_body.fcxn52 : (⟨19233, 16329, 2715879, 2303⟩ : Conv.Cnt).xn = (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s513.ffi).mlx.next
kernel_rfl PRE_first_tail_x15_r0_body.fcnn52 : (⟨19233, 16329, 2715879, 2303⟩ : Conv.Cnt).nn = (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s513.ffi).mlx.nnext
kernel_rfl PRE_first_tail_x15_r0_body.fle052 : (Nat.ble (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s513.ffi).mlx.next PRE_first_tail_x15_r0_body.cx0_52.mlx.next && Nat.ble (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s513.ffi).mlx.nnext PRE_first_tail_x15_r0_body.cx0_52.mlx.nnext && Nat.ble (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s513.ffi).mlx.next RData.bigHi) = true
kernel_rfl PRE_first_tail_x15_r0_body.fnk52 : (PTrie.keysA PRE_first_tail_x15_r0_body.kd52.node).all (Nat.ble (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s513.ffi).mlx.nnext) = true
-- the merged state keeps the call's entries off the stage's footprint
kernel_rfl PRE_first_tail_x15_r0_body.f1A52 : PRE_first_tail_x15_r0_body.cx1_52.mlx.arrs = Stage.setAll (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s513.ffi).mlx.arrs (PRE_first_tail_x15_r0_body.cwS52.filterMap fun i => (PRE_first_tail_x15_r0_body.cx1_52.mlx.arrs.get i).map (i, ·))
kernel_rfl PRE_first_tail_x15_r0_body.f1O52 : PRE_first_tail_x15_r0_body.cx1_52.mlx.objs = Stage.setAll (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s513.ffi).mlx.objs (PRE_first_tail_x15_r0_body.cwS52.filterMap fun i => (PRE_first_tail_x15_r0_body.cx1_52.mlx.objs.get i).map (i, ·))
kernel_rfl PRE_first_tail_x15_r0_body.f1N52 : PRE_first_tail_x15_r0_body.cx1_52.mlx.nodes = Stage.setAll (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s513.ffi).mlx.nodes (PRE_first_tail_x15_r0_body.cnS52.filterMap fun i => (PRE_first_tail_x15_r0_body.cx1_52.mlx.nodes.get i).map (i, ·))
kernel_rfl PRE_first_tail_x15_r0_body.f1I52 : PRE_first_tail_x15_r0_body.cx1_52.mlx.items = Stage.setAll (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s513.ffi).mlx.items (PRE_first_tail_x15_r0_body.ciS52.filterMap fun i => (PRE_first_tail_x15_r0_body.cx1_52.mlx.items.get i).map (i, ·))
kernel_rfl PRE_first_tail_x15_r0_body.fbd52 : (PRE_first_tail_x15_r0_body.clo52 ++ PRE_first_tail_x15_r0_body.cln52 ++ PRE_first_tail_x15_r0_body.cli52 ++ PRE_first_tail_x15_r0_body.cwS52 ++ PRE_first_tail_x15_r0_body.cnS52 ++ PRE_first_tail_x15_r0_body.ciS52).all (fun i => Nat.blt (i / 4096) (4 ^ 31)) = true
kernel_rfl PRE_first_tail_x15_r0_body.fincW52 : PRE_first_tail_x15_r0_body.cwS52.all (fun h => !Nat.blt h (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s513.ffi).mlx.next || PRE_first_tail_x15_r0_body.clo52.contains h) = true
kernel_rfl PRE_first_tail_x15_r0_body.fincI52 : PRE_first_tail_x15_r0_body.ciS52.all (fun k => !Nat.blt k (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s513.ffi).mlx.nnext || PRE_first_tail_x15_r0_body.cli52.contains k) = true
kernel_rfl PRE_first_tail_x15_r0_body.fincN52 : PRE_first_tail_x15_r0_body.cnS52.all (Nat.ble (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s513.ffi).mlx.nnext) = true
kernel_rfl PRE_first_tail_x15_r0_body.flnF52 : PRE_first_tail_x15_r0_body.cln52.all (Nat.ble (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s513.ffi).mlx.nnext) = true
-- the checks over the changed lists
kernel_rfl PRE_first_tail_x15_r0_body.fh52 : PRE_first_tail_x15_r0_body.clo52.all (handleOK PRE_first_tail_x15_r0_body.kappa52 PRE_first_tail_x15_r0_body.P52.lo PRE_first_tail_x15_r0_body.cx0_52.mlx PRE_first_tail_x15_r0_body.cx1_52.mlx) = true
kernel_rfl PRE_first_tail_x15_r0_body.fo52 : PRE_first_tail_x15_r0_body.clo52.map (fun h => PRE_first_tail_x15_r0_body.cx1_52.mlx.objs.get (PRE_first_tail_x15_r0_body.kappa52.handle h)) = PRE_first_tail_x15_r0_body.clo52.map (fun h => (PRE_first_tail_x15_r0_body.cx0_52.mlx.objs.get h).map PRE_first_tail_x15_r0_body.kappa52.nobj)
kernel_rfl PRE_first_tail_x15_r0_body.fok52 : PRE_first_tail_x15_r0_body.clo52.all (objOK PRE_first_tail_x15_r0_body.kappa52 PRE_first_tail_x15_r0_body.P52.NL PRE_first_tail_x15_r0_body.cx0_52.mlx) = true
kernel_rfl PRE_first_tail_x15_r0_body.fnd52 : PRE_first_tail_x15_r0_body.cln52.all (nodeOKF PRE_first_tail_x15_r0_body.kappa52 PRE_first_tail_x15_r0_body.P52 PRE_first_tail_x15_r0_body.cx0_52.mlx PRE_first_tail_x15_r0_body.cx1_52.mlx) = true
kernel_rfl PRE_first_tail_x15_r0_body.fp52 : ((PRE_first_tail_x15_r0_body.cln52.filter (fullB PRE_first_tail_x15_r0_body.P52))).map (fun i => (PRE_first_tail_x15_r0_body.cx1_52.mlx.nodes.get (PRE_first_tail_x15_r0_body.kappa52.node i)).map Host.Mlx.Ffi.Node.prim) =
  ((PRE_first_tail_x15_r0_body.cln52.filter (fullB PRE_first_tail_x15_r0_body.P52))).map (fun i => (PRE_first_tail_x15_r0_body.cx0_52.mlx.nodes.get i).map fun nd => PRE_first_tail_x15_r0_body.kappa52.prim nd.prim)
kernel_rfl PRE_first_tail_x15_r0_body.fnordI52 : incrB PRE_first_tail_x15_r0_body.kd52.nodeF (List.range' 16329 0) = true
kernel_rfl PRE_first_tail_x15_r0_body.fnordK52 : (PTrie.keysA PRE_first_tail_x15_r0_body.kd52.node).all (fun k => Nat.ble 16329 k && Nat.blt k 16329) = true
kernel_rfl PRE_first_tail_x15_r0_body.fnordL52 : (PRE_first_tail_x15_r0_body.cln52.filter (Nat.ble PRE_first_tail_x15_r0_body.P52.N0)).all (fun i => Nat.ble i (PRE_first_tail_x15_r0_body.kd52.nodeF i) && (Nat.blt i 16329 || Nat.ble PRE_first_tail_x15_r0_body.kd52.nn0 i)) = true
theorem PRE_first_tail_x15_r0_body.fnord52 : (PRE_first_tail_x15_r0_body.cln52.filter (Nat.ble PRE_first_tail_x15_r0_body.P52.N0)).all (fun i => Nat.ble i (PRE_first_tail_x15_r0_body.kd52.nodeF i) &&
    (PTrie.keysA PRE_first_tail_x15_r0_body.kd52.node).all fun j => !Nat.blt j i || Nat.blt (PRE_first_tail_x15_r0_body.kd52.nodeF j) (PRE_first_tail_x15_r0_body.kd52.nodeF i)) = true :=
  cnord_of PRE_first_tail_x15_r0_body.cnlow52 PRE_first_tail_x15_r0_body.cnn152 PRE_first_tail_x15_r0_body.fnordI52 PRE_first_tail_x15_r0_body.fnordK52 PRE_first_tail_x15_r0_body.fnordL52
kernel_rfl PRE_first_tail_x15_r0_body.fi52 : PRE_first_tail_x15_r0_body.cli52.all (pnB PRE_first_tail_x15_r0_body.cx0_52.mlx) = true
kernel_rfl PRE_first_tail_x15_r0_body.fii52 : PRE_first_tail_x15_r0_body.cli52.all (fun k => decide (PRE_first_tail_x15_r0_body.cx1_52.mlx.items.get (PRE_first_tail_x15_r0_body.kappa52.node k) = (PRE_first_tail_x15_r0_body.cx0_52.mlx.items.get k).map PRE_first_tail_x15_r0_body.kappa52.nv)) = true
/-- **The compaction's footprint.** -/
theorem PRE_first_tail_x15_r0_body.cfoot52 (clean : Conv.NClean (⟨19233, 16329, 2715879, 2303⟩ : Conv.Cnt) (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s513.ffi).mlx) (hltC : ∀ h, PH (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s513.ffi).mlx h → h < (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s513.ffi).mlx.next) (nltC : ∀ i, PN (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s513.ffi).mlx i → i < (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s513.ffi).mlx.nnext) (itemsC : ∀ k v, (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s513.ffi).mlx.items.get k = some v → PN (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s513.ffi).mlx k) (tracedC : ∀ h o, (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s513.ffi).mlx.objs.get h = some o → ∀ i ∈ objTraces o, i < PRE_first_tail_x15_r0_body.P52.NL) (cl : SSt (· < 2303) PRE_first_tail_x15_r0_body.cx0_52.mlx) :
    Conv.MFoot PRE_first_tail_x15_r0_body.P52 2303 PRE_first_tail_x15_r0_body.kappa52 PRE_first_tail_x15_r0_body.kd52 PRE_first_tail_x15_r0_body.khinv52 PRE_first_tail_x15_r0_body.kninv52 (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s513.ffi).mlx PRE_first_tail_x15_r0_body.cx0_52.mlx PRE_first_tail_x15_r0_body.cx1_52.mlx (⟨19233, 16329, 2715879, 2303⟩ : Conv.Cnt) PRE_first_tail_x15_r0_body.clo52 PRE_first_tail_x15_r0_body.cln52 PRE_first_tail_x15_r0_body.cli52 PRE_first_tail_x15_r0_body.cwS52 PRE_first_tail_x15_r0_body.cnS52 PRE_first_tail_x15_r0_body.ciS52 :=
  ⟨rfl, rfl, rfl, PRE_first_tail_x15_r0_body.cnh052, PRE_first_tail_x15_r0_body.cnh152, PRE_first_tail_x15_r0_body.cnn052, PRE_first_tail_x15_r0_body.cnn152, PRE_first_tail_x15_r0_body.cplo52, PRE_first_tail_x15_r0_body.ccnt52, PRE_first_tail_x15_r0_body.cnband52, PRE_first_tail_x15_r0_body.chbelow52, PRE_first_tail_x15_r0_body.chren52, PRE_first_tail_x15_r0_body.cband52, PRE_first_tail_x15_r0_body.cnh1pos52, PRE_first_tail_x15_r0_body.cnren52, PRE_first_tail_x15_r0_body.cnlow52, PRE_first_tail_x15_r0_body.cabs0a52, PRE_first_tail_x15_r0_body.cabs0b52, PRE_first_tail_x15_r0_body.ctok152, PRE_first_tail_x15_r0_body.cpend52, PRE_first_tail_x15_r0_body.cerrh52, PRE_first_tail_x15_r0_body.cfiles52, PRE_first_tail_x15_r0_body.carch52, PRE_first_tail_x15_r0_body.csizes52, PRE_first_tail_x15_r0_body.cwired52, PRE_first_tail_x15_r0_body.cfix52, clean, PRE_first_tail_x15_r0_body.fcxn52, PRE_first_tail_x15_r0_body.fcnn52, hltC, nltC, itemsC, tracedC, cl, PRE_first_tail_x15_r0_body.fle052, PRE_first_tail_x15_r0_body.fnk52, PRE_first_tail_x15_r0_body.ckA52, PRE_first_tail_x15_r0_body.cobjsK52, PRE_first_tail_x15_r0_body.cnodesK52, PRE_first_tail_x15_r0_body.citemsK52, PRE_first_tail_x15_r0_body.f1A52, PRE_first_tail_x15_r0_body.f1O52, PRE_first_tail_x15_r0_body.f1N52, PRE_first_tail_x15_r0_body.f1I52, PRE_first_tail_x15_r0_body.fbd52, PRE_first_tail_x15_r0_body.fincW52, PRE_first_tail_x15_r0_body.fincI52, PRE_first_tail_x15_r0_body.fincN52, PRE_first_tail_x15_r0_body.flnF52, PRE_first_tail_x15_r0_body.fh52, PRE_first_tail_x15_r0_body.fo52, PRE_first_tail_x15_r0_body.fok52, PRE_first_tail_x15_r0_body.fnd52, PRE_first_tail_x15_r0_body.fp52, PRE_first_tail_x15_r0_body.fnord52, PRE_first_tail_x15_r0_body.fi52, PRE_first_tail_x15_r0_body.fii52⟩
theorem PRE_first_tail_x15_r0_body.cnshift52 (clean : Conv.NClean (⟨19233, 16329, 2715879, 2303⟩ : Conv.Cnt) (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s513.ffi).mlx) (hltC : ∀ h, PH (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s513.ffi).mlx h → h < (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s513.ffi).mlx.next) (nltC : ∀ i, PN (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s513.ffi).mlx i → i < (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s513.ffi).mlx.nnext) (itemsC : ∀ k v, (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s513.ffi).mlx.items.get k = some v → PN (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s513.ffi).mlx k) (tracedC : ∀ h o, (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s513.ffi).mlx.objs.get h = some o → ∀ i ∈ objTraces o, i < PRE_first_tail_x15_r0_body.P52.NL) (cl : SSt (· < 2303) PRE_first_tail_x15_r0_body.cx0_52.mlx) : NShift PRE_first_tail_x15_r0_body.P52 2303 PRE_first_tail_x15_r0_body.kappa52 PRE_first_tail_x15_r0_body.cx0_52 PRE_first_tail_x15_r0_body.cx1_52 :=
  Conv.nshift_of_foot (PRE_first_tail_x15_r0_body.cfoot52 clean hltC nltC itemsC tracedC cl) PRE_first_tail_x15_r0_body.chost52 (compact_a_eq PRE_first_tail_x15_r0_body.ckn052 PRE_first_tail_x15_r0_body.ckn152 PRE_first_tail_x15_r0_body.ckheap52 PRE_first_tail_x15_r0_body.ckpl52)

-- the observers: the layers' states at the call, the canonical and the merged state, their footprints and checks
noncomputable def PRE_first_tail_x15_r0_body.fxC_52 : PTrie Unit := (Host.Ts.Sim.Full.freedOf PRE_first_tail_x15_r0_body.s513.ffi).getD PTrie.nil
noncomputable def PRE_first_tail_x15_r0_body.krC_52 : Host.Load.Layers.KRec := (Host.Ts.Sim.Full.krecOf PRE_first_tail_x15_r0_body.s513.ffi).getD Host.Load.Layers.KRec.empty
kernel_rfl PRE_first_tail_x15_r0_body.ofxC_52 : (Host.Ts.Sim.Full.freedOf PRE_first_tail_x15_r0_body.s513.ffi) = some PRE_first_tail_x15_r0_body.fxC_52
kernel_rfl PRE_first_tail_x15_r0_body.okrC_52 : (Host.Ts.Sim.Full.krecOf PRE_first_tail_x15_r0_body.s513.ffi) = some PRE_first_tail_x15_r0_body.krC_52
noncomputable def PRE_first_tail_x15_r0_body.fx0_52 : PTrie Unit := (Host.Ts.Sim.Full.freedOf PRE_first_tail_x15_r0_body.s515.ffi).getD PTrie.nil
noncomputable def PRE_first_tail_x15_r0_body.kr0_52 : Host.Load.Layers.KRec := (Host.Ts.Sim.Full.krecOf PRE_first_tail_x15_r0_body.s515.ffi).getD Host.Load.Layers.KRec.empty
kernel_rfl PRE_first_tail_x15_r0_body.ofx0_52 : (Host.Ts.Sim.Full.freedOf PRE_first_tail_x15_r0_body.s515.ffi) = some PRE_first_tail_x15_r0_body.fx0_52
kernel_rfl PRE_first_tail_x15_r0_body.okr0_52 : (Host.Ts.Sim.Full.krecOf PRE_first_tail_x15_r0_body.s515.ffi) = some PRE_first_tail_x15_r0_body.kr0_52
noncomputable def PRE_first_tail_x15_r0_body.fx1_52 : PTrie Unit := (Host.Ts.Sim.Full.freedOf PRE_first_tail_x15_r0_body.s514.ffi).getD PTrie.nil
noncomputable def PRE_first_tail_x15_r0_body.kr1_52 : Host.Load.Layers.KRec := (Host.Ts.Sim.Full.krecOf PRE_first_tail_x15_r0_body.s514.ffi).getD Host.Load.Layers.KRec.empty
kernel_rfl PRE_first_tail_x15_r0_body.ofx1_52 : (Host.Ts.Sim.Full.freedOf PRE_first_tail_x15_r0_body.s514.ffi) = some PRE_first_tail_x15_r0_body.fx1_52
kernel_rfl PRE_first_tail_x15_r0_body.okr1_52 : (Host.Ts.Sim.Full.krecOf PRE_first_tail_x15_r0_body.s514.ffi) = some PRE_first_tail_x15_r0_body.kr1_52
kernel_rfl PRE_first_tail_x15_r0_body.ff052 : PRE_first_tail_x15_r0_body.fx0_52 = Stage.setAll PRE_first_tail_x15_r0_body.fxC_52 (PRE_first_tail_x15_r0_body.clo52.filterMap fun i => (PRE_first_tail_x15_r0_body.fx0_52.get i).map (i, ·))
kernel_rfl PRE_first_tail_x15_r0_body.ff152 : PRE_first_tail_x15_r0_body.fx1_52 = Stage.setAll PRE_first_tail_x15_r0_body.fxC_52 (PRE_first_tail_x15_r0_body.cwS52.filterMap fun i => (PRE_first_tail_x15_r0_body.fx1_52.get i).map (i, ·))
kernel_rfl PRE_first_tail_x15_r0_body.ffck52 : freedLB PRE_first_tail_x15_r0_body.kappa52 PRE_first_tail_x15_r0_body.cx0_52.mlx PRE_first_tail_x15_r0_body.fx0_52 PRE_first_tail_x15_r0_body.fx1_52 PRE_first_tail_x15_r0_body.clo52 = true
kernel_rfl PRE_first_tail_x15_r0_body.fkf052 : PRE_first_tail_x15_r0_body.kr0_52.flags = Stage.setAll PRE_first_tail_x15_r0_body.krC_52.flags (PRE_first_tail_x15_r0_body.clo52.filterMap fun i => (PRE_first_tail_x15_r0_body.kr0_52.flags.get i).map (i, ·))
kernel_rfl PRE_first_tail_x15_r0_body.fkt052 : PRE_first_tail_x15_r0_body.kr0_52.targs = Stage.setAll PRE_first_tail_x15_r0_body.krC_52.targs (PRE_first_tail_x15_r0_body.clo52.filterMap fun i => (PRE_first_tail_x15_r0_body.kr0_52.targs.get i).map (i, ·))
kernel_rfl PRE_first_tail_x15_r0_body.fkf152 : PRE_first_tail_x15_r0_body.kr1_52.flags = Stage.setAll PRE_first_tail_x15_r0_body.krC_52.flags (PRE_first_tail_x15_r0_body.cwS52.filterMap fun i => (PRE_first_tail_x15_r0_body.kr1_52.flags.get i).map (i, ·))
kernel_rfl PRE_first_tail_x15_r0_body.fkt152 : PRE_first_tail_x15_r0_body.kr1_52.targs = Stage.setAll PRE_first_tail_x15_r0_body.krC_52.targs (PRE_first_tail_x15_r0_body.cwS52.filterMap fun i => (PRE_first_tail_x15_r0_body.kr1_52.targs.get i).map (i, ·))
kernel_rfl PRE_first_tail_x15_r0_body.fkck52 : krecLB PRE_first_tail_x15_r0_body.kappa52 2303 PRE_first_tail_x15_r0_body.cx0_52.mlx PRE_first_tail_x15_r0_body.kr0_52 PRE_first_tail_x15_r0_body.kr1_52 PRE_first_tail_x15_r0_body.clo52 = true
kernel_rfl PRE_first_tail_x15_r0_body.fkn52 : Nat.ble 2303 2303 = true
-- the bridge and the pending traces' regions
kernel_rfl PRE_first_tail_x15_r0_body.cbridge52 : Host.Ts.Sim.Full.bridgeOf PRE_first_tail_x15_r0_body.s514.ffi = Host.Ts.Sim.Full.bridgeOf PRE_first_tail_x15_r0_body.s515.ffi
kernel_rfl PRE_first_tail_x15_r0_body.cpendR52 : pendRegB PRE_first_tail_x15_r0_body.kappa52 (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s515.ffi).mlx = true
kernel_rfl PRE_first_tail_x15_r0_body.cpendLe52 : Nat.ble (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s515.ffi).mlx.next (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s514.ffi).mlx.next = true
/-- **The compaction's native shift**, given the call's bookkeeping, its relation's facts (the model's and the
observers') and the canonical closedness. -/
theorem PRE_first_tail_x15_r0_body.cshift52 (clean : Conv.NClean (⟨19233, 16329, 2715879, 2303⟩ : Conv.Cnt) (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s513.ffi).mlx) (hltC : ∀ h, PH (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s513.ffi).mlx h → h < (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s513.ffi).mlx.next) (nltC : ∀ i, PN (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s513.ffi).mlx i → i < (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s513.ffi).mlx.nnext) (itemsC : ∀ k v, (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s513.ffi).mlx.items.get k = some v → PN (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s513.ffi).mlx k) (tracedC : ∀ h o, (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s513.ffi).mlx.objs.get h = some o → ∀ i ∈ objTraces o, i < PRE_first_tail_x15_r0_body.P52.NL) (cl : SSt (· < 2303) PRE_first_tail_x15_r0_body.cx0_52.mlx)
    (hobjC : ∀ h, PRE_first_tail_x15_r0_body.fxC_52.get h = some () → ((Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s513.ffi).mlx.objs.get h).isSome = true)
    (hfC : ∀ h, (PRE_first_tail_x15_r0_body.krC_52.flags.get h).isSome = true → ((Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s513.ffi).mlx.objs.get h).isSome = true)
    (htC : ∀ h, (PRE_first_tail_x15_r0_body.krC_52.targs.get h).isSome = true → ((Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s513.ffi).mlx.objs.get h).isSome = true)
    (hclC : ∀ h l, PRE_first_tail_x15_r0_body.krC_52.targs.get h = some l → Host.Ts.Sim.Full.STargs (· < (⟨19233, 16329, 2715879, 2303⟩ : Conv.Cnt).n) l) :
    Conv.FullShiftQ PRE_first_tail_x15_r0_body.P52 2303 PRE_first_tail_x15_r0_body.kappa52 PRE_first_tail_x15_r0_body.s515.ffi PRE_first_tail_x15_r0_body.s514.ffi :=
  ⟨PRE_first_tail_x15_r0_body.cnshift52 clean hltC nltC itemsC tracedC cl, PRE_first_tail_x15_r0_body.cqueue52, fun t ht => bSN_sound (List.all_eq_true.mp PRE_first_tail_x15_r0_body.ctokSupp52 t ht),
    PRE_first_tail_x15_r0_body.cbridge52,
    liveShift_foot (x0' := Host.Ts.Sim.Full.mlxOf PRE_first_tail_x15_r0_body.s515.ffi) (x1' := Host.Ts.Sim.Full.mlxOf PRE_first_tail_x15_r0_body.s514.ffi) (PRE_first_tail_x15_r0_body.cfoot52 clean hltC nltC itemsC tracedC cl) rfl PRE_first_tail_x15_r0_body.ofx0_52 PRE_first_tail_x15_r0_body.ofx1_52 hobjC PRE_first_tail_x15_r0_body.ff052 PRE_first_tail_x15_r0_body.ff152 PRE_first_tail_x15_r0_body.ffck52,
    kernShift_foot (x0' := Host.Ts.Sim.Full.mlxOf PRE_first_tail_x15_r0_body.s515.ffi) (x1' := Host.Ts.Sim.Full.mlxOf PRE_first_tail_x15_r0_body.s514.ffi) (PRE_first_tail_x15_r0_body.cfoot52 clean hltC nltC itemsC tracedC cl) rfl PRE_first_tail_x15_r0_body.okr0_52 PRE_first_tail_x15_r0_body.okr1_52 (Nat.le_of_ble_eq_true PRE_first_tail_x15_r0_body.fkn52) hfC htC hclC
      PRE_first_tail_x15_r0_body.fkf052 PRE_first_tail_x15_r0_body.fkt052 PRE_first_tail_x15_r0_body.fkf152 PRE_first_tail_x15_r0_body.fkt152 PRE_first_tail_x15_r0_body.fkck52,
    pendReg_of rfl PRE_first_tail_x15_r0_body.cnh052 PRE_first_tail_x15_r0_body.cnh152 (Nat.le_of_ble_eq_true PRE_first_tail_x15_r0_body.cpendLe52) PRE_first_tail_x15_r0_body.cpendR52⟩

end Host.Load.Run.Tpl
end

section -- st52/H0
set_option Elab.async false
namespace Host.Load.Run.Tpl
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
host_stream_state PRE_first_tail_x15_r0_body.st52 0
host_stream_state PRE_first_tail_x15_r0_body.st52 1
host_stream_state PRE_first_tail_x15_r0_body.st52 2
end Host.Load.Run.Tpl
end

section -- Site52
set_option Elab.async false
namespace Host.Load.Run.Tpl
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
open Host.Ts Host.Ts.Sim Host.Ts.Sim.Template

/-! Call site 52 of chain `PRE_first_tail_x15_r0_body`: `rowBlocks__g52__g53` (`rowBlocks`), the call state `PRE_first_tail_x15_r0_body.s513`, the merged state `PRE_first_tail_x15_r0_body.s514`,
the site template `PRE_first_tail_x15_r0_body.st52` (σ = `Map.id`, θ the identity at its own site), the canonical state `PRE_first_tail_x15_r0_body.s515`: the merge.
The footprint's facts are in `SiteF52`, the compaction's in `SiteC52`, `SiteK52`, `SiteNa52`, `SiteNb52`. -/

kernel_rfl PRE_first_tail_x15_r0_body.iso52 : PRE_first_tail_x15_r0_body.st52.s0 = { PRE_first_tail_x15_r0_body.s513 with stack := [] }
/-- The caller's frames at the call. -/
noncomputable def PRE_first_tail_x15_r0_body.rs52 : List Frame := PRE_first_tail_x15_r0_body.s513.stack
kernel_rfl PRE_first_tail_x15_r0_body.n0_52 : PRE_first_tail_x15_r0_body.S513.tab.length = 2303
kernel_rfl PRE_first_tail_x15_r0_body.tab0_52 : PRE_first_tail_x15_r0_body.st52.S0.tab = PRE_first_tail_x15_r0_body.S513.tab

/-- The fresh variables of the stage's results. -/
def PRE_first_tail_x15_r0_body.ws52 : List Nat := [1905, 1906]
kernel_rfl PRE_first_tail_x15_r0_body.fresh52 : (PRE_first_tail_x15_r0_body.S513.tab.all fun e => PRE_first_tail_x15_r0_body.ws52.all fun v => e.noVar v) &&
    (PRE_first_tail_x15_r0_body.S513.oracle.all fun q => PRE_first_tail_x15_r0_body.ws52.all fun v => q.noVar v) = true
kernel_rfl PRE_first_tail_x15_r0_body.mergeTab52 : PRE_first_tail_x15_r0_body.S514.tab = PRE_first_tail_x15_r0_body.S513.tab ++ Conv.resTab PRE_first_tail_x15_r0_body.ws52
kernel_rfl PRE_first_tail_x15_r0_body.mergeLen52 : PRE_first_tail_x15_r0_body.st52.S2.tab.length - PRE_first_tail_x15_r0_body.st52.S0.tab.length = 2

-- The merged state: the instance's return state with the caller's frames (`PRE_first_tail_x15_r0_body.merged52`, `merged_relB`).
kernel_rfl PRE_first_tail_x15_r0_body.mheap52 : PRE_first_tail_x15_r0_body.s514.heap = PRE_first_tail_x15_r0_body.st52.s2.heap
kernel_rfl PRE_first_tail_x15_r0_body.mnext52 : PRE_first_tail_x15_r0_body.s514.next = PRE_first_tail_x15_r0_body.st52.s2.next
kernel_rfl PRE_first_tail_x15_r0_body.mctl52 : PRE_first_tail_x15_r0_body.s514.ctl = PRE_first_tail_x15_r0_body.st52.s2.ctl
kernel_rfl PRE_first_tail_x15_r0_body.mstack52 : PRE_first_tail_x15_r0_body.s514.stack = PRE_first_tail_x15_r0_body.st52.s2.stack ++ PRE_first_tail_x15_r0_body.s513.stack
kernel_rfl PRE_first_tail_x15_r0_body.mjobs52 : PRE_first_tail_x15_r0_body.s514.jobs = PRE_first_tail_x15_r0_body.st52.s2.jobs
kernel_rfl PRE_first_tail_x15_r0_body.mffi52 : PRE_first_tail_x15_r0_body.s514.ffi = PRE_first_tail_x15_r0_body.st52.s2.ffi
kernel_rfl PRE_first_tail_x15_r0_body.mtrace52 : PRE_first_tail_x15_r0_body.s514.trace = PRE_first_tail_x15_r0_body.st52.s2.trace
kernel_rfl PRE_first_tail_x15_r0_body.mstores52 : PRE_first_tail_x15_r0_body.s514.stores = PRE_first_tail_x15_r0_body.st52.s2.stores

end Host.Load.Run.Tpl
end

section -- SiteD52
set_option Elab.async false
namespace Host.Load.Run.Tpl
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
open Host.Ts Host.Ts.Sim Host.Ts.Sim.Template

/-! The canonical results at call site 52 of chain `PRE_first_tail_x15_r0_body`: their values in the instance's end table, the references past
the call's table, the canonical variables apart from the stage's. -/

kernel_rfl PRE_first_tail_x15_r0_body.cderived52 : PRE_first_tail_x15_r0_body.nr52.map (fun r => nth? PRE_first_tail_x15_r0_body.st52.S2.tab r) =
  []
kernel_rfl PRE_first_tail_x15_r0_body.cnrLo52 : PRE_first_tail_x15_r0_body.nr52.all (Nat.ble 2303) = true
kernel_rfl PRE_first_tail_x15_r0_body.cwsDisj52 : PRE_first_tail_x15_r0_body.cws52.all (fun c => !PRE_first_tail_x15_r0_body.ws52.contains c) = true
/-- The compaction's substitution: the canonical variables to their merged values, the stage's other fresh variables
to `0` (`Conv.compactθZ`). -/
noncomputable def PRE_first_tail_x15_r0_body.cthetaZ52 : Nat → SymE := Conv.compactθZ PRE_first_tail_x15_r0_body.cws52 PRE_first_tail_x15_r0_body.crs52 PRE_first_tail_x15_r0_body.ws52

end Host.Load.Run.Tpl
end

section -- st52/Foot
set_option Elab.async false
namespace Host.Load.Run.Tpl
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
open Host.Ts Host.Ts.Sim Host.Ts.Sim.Stage Host.Ts.Sim.Template

/-! The footprint of stage `PRE_first_tail_x15_r0_body.st52`'s site template (`Conv.StageFoot`, `Conv.NFoot`): every entry of the return
state other than the written and fresh ones is the start's (kernel evaluation of the equalities). -/

/-- The written heap ranges below the start's counter. -/
def PRE_first_tail_x15_r0_body.st52.wrR : List (Nat × Nat) := []
/-- The written and fresh entries of the return state. -/
noncomputable def PRE_first_tail_x15_r0_body.st52.wrE : List (Nat × Host.Ts.HObj) :=
  rangesOf PRE_first_tail_x15_r0_body.st52.s2.heap PRE_first_tail_x15_r0_body.st52.wrR ++ freshOf PRE_first_tail_x15_r0_body.st52.s2.heap PRE_first_tail_x15_r0_body.st52.s0.next PRE_first_tail_x15_r0_body.st52.s2.next
noncomputable def PRE_first_tail_x15_r0_body.st52.wr : List Nat := PRE_first_tail_x15_r0_body.st52.wrE.map (·.1)

kernel_rfl PRE_first_tail_x15_r0_body.st52.heapFoot : PRE_first_tail_x15_r0_body.st52.s2.heap = setAll PRE_first_tail_x15_r0_body.st52.s0.heap PRE_first_tail_x15_r0_body.st52.wrE
kernel_rfl PRE_first_tail_x15_r0_body.st52.grows_check : Nat.ble PRE_first_tail_x15_r0_body.st52.s0.next PRE_first_tail_x15_r0_body.st52.s2.next = true
theorem PRE_first_tail_x15_r0_body.st52.grows : PRE_first_tail_x15_r0_body.st52.s0.next ≤ PRE_first_tail_x15_r0_body.st52.s2.next := Nat.le_of_ble_eq_true PRE_first_tail_x15_r0_body.st52.grows_check

/-- The written and fresh handles; the written readback items of old nodes. -/
def PRE_first_tail_x15_r0_body.st52.wh : List Nat := []
def PRE_first_tail_x15_r0_body.st52.wi : List Nat := []

kernel_rfl PRE_first_tail_x15_r0_body.st52.arrsFoot : (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.st52.s2.ffi).mlx.arrs = setAll (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.st52.s0.ffi).mlx.arrs (PRE_first_tail_x15_r0_body.st52.wh.filterMap fun h => ((Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.st52.s2.ffi).mlx.arrs.get h).map (h, ·))
kernel_rfl PRE_first_tail_x15_r0_body.st52.objsFoot : (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.st52.s2.ffi).mlx.objs = setAll (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.st52.s0.ffi).mlx.objs (PRE_first_tail_x15_r0_body.st52.wh.filterMap fun h => ((Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.st52.s2.ffi).mlx.objs.get h).map (h, ·))
kernel_rfl PRE_first_tail_x15_r0_body.st52.nodesFoot : (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.st52.s2.ffi).mlx.nodes = setAll (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.st52.s0.ffi).mlx.nodes (freshOf (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.st52.s2.ffi).mlx.nodes (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.st52.s0.ffi).mlx.nnext (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.st52.s2.ffi).mlx.nnext)
kernel_rfl PRE_first_tail_x15_r0_body.st52.itemsFoot : (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.st52.s2.ffi).mlx.items = setAll (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.st52.s0.ffi).mlx.items ((PRE_first_tail_x15_r0_body.st52.wi.filterMap fun i => ((Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.st52.s2.ffi).mlx.items.get i).map (i, ·)) ++
    freshOf (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.st52.s2.ffi).mlx.items (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.st52.s0.ffi).mlx.nnext (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.st52.s2.ffi).mlx.nnext)
kernel_rfl PRE_first_tail_x15_r0_body.st52.counters : (Nat.ble (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.st52.s0.ffi).mlx.next (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.st52.s2.ffi).mlx.next && Nat.ble (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.st52.s0.ffi).mlx.nnext (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.st52.s2.ffi).mlx.nnext) = true

end Host.Load.Run.Tpl
end

section -- SiteF52
set_option Elab.async false
namespace Host.Load.Run.Tpl
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
open Host.Ts Host.Ts.Sim Host.Ts.Sim.Template

/-! Call site 52 of chain `PRE_first_tail_x15_r0_body`: `Conv.site_merge`'s footprint facts. -/

kernel_rfl PRE_first_tail_x15_r0_body.wrNodupB52 : nodupT PRE_first_tail_x15_r0_body.st52.wr PTrie.nil = true
theorem PRE_first_tail_x15_r0_body.wrNodup52 : PRE_first_tail_x15_r0_body.st52.wr.Nodup := (nodupT_sound PRE_first_tail_x15_r0_body.wrNodupB52).2
kernel_rfl PRE_first_tail_x15_r0_body.wrBoundB52 : PRE_first_tail_x15_r0_body.st52.wr.all (fun b => Nat.blt (b / 4096) (4 ^ 31)) = true
theorem PRE_first_tail_x15_r0_body.wrBound52 : ∀ b ∈ PRE_first_tail_x15_r0_body.st52.wr, b / 4096 < 4 ^ 31 := fun b hb => Nat.blt_eq.mp (List.all_eq_true.mp PRE_first_tail_x15_r0_body.wrBoundB52 b hb)
noncomputable def PRE_first_tail_x15_r0_body.trFr52 := PRE_first_tail_x15_r0_body.st52.s2.trace.take 0
kernel_rfl PRE_first_tail_x15_r0_body.traceEq52 : PRE_first_tail_x15_r0_body.st52.s2.trace = PRE_first_tail_x15_r0_body.trFr52 ++ PRE_first_tail_x15_r0_body.st52.s0.trace
theorem PRE_first_tail_x15_r0_body.trace52 : ∃ fr, PRE_first_tail_x15_r0_body.st52.s2.trace = fr ++ PRE_first_tail_x15_r0_body.st52.s0.trace := ⟨_, PRE_first_tail_x15_r0_body.traceEq52⟩

-- the caller's wide frames at the instance's start (`Conv.isolateW`'s `W0` under `Map.id`) and their `WFix`
def PRE_first_tail_x15_r0_body.wide52 : List (Nat × WFrame) := [(4910, .memo [])]
kernel_rfl PRE_first_tail_x15_r0_body.wfixB52 : (PRE_first_tail_x15_r0_body.wide52.all fun p => wfixB Map.id (presentB PRE_first_tail_x15_r0_body.st52.s0) p.2) = true
theorem PRE_first_tail_x15_r0_body.wfix52 : ∀ p ∈ PRE_first_tail_x15_r0_body.wide52, WFix Map.id (Present PRE_first_tail_x15_r0_body.st52.s0) p.2 :=
  fun p hp => wfix_of (List.all_eq_true.mp PRE_first_tail_x15_r0_body.wfixB52 p hp)

end Host.Load.Run.Tpl
end

section -- SiteL52
set_option Elab.async false
namespace Host.Load.Run.Tpl
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
open Host.Ts Host.Ts.Sim Host.Ts.Sim.Template

/-! The call link's facts at call site 52 of chain `PRE_first_tail_x15_r0_body`: the instance's start server, its footprint (`Conv.StageFoot`), the
merged state `PRE_first_tail_x15_r0_body.s514`'s framed arrays as the chain start's extended (`arrExt_of`, `numRefs_of`). -/

kernel_rfl PRE_first_tail_x15_r0_body.srvO52 : PRE_first_tail_x15_r0_body.st52.S0.oracle = PRE_first_tail_x15_r0_body.st52.OR
kernel_rfl PRE_first_tail_x15_r0_body.wr0B52 : PRE_first_tail_x15_r0_body.st52.wr.all (fun b => !Nat.blt b PRE_first_tail_x15_r0_body.st52.s0.next || (PRE_first_tail_x15_r0_body.st52.s0.heap.get b).isSome) = true
theorem PRE_first_tail_x15_r0_body.stFoot52 : Conv.StageFoot PRE_first_tail_x15_r0_body.st52.wr PRE_first_tail_x15_r0_body.st52.s0 PRE_first_tail_x15_r0_body.st52.s2 :=
  stageFoot_of PRE_first_tail_x15_r0_body.st52.heapFoot PRE_first_tail_x15_r0_body.wrNodup52 PRE_first_tail_x15_r0_body.wrBound52 PRE_first_tail_x15_r0_body.wr0B52 PRE_first_tail_x15_r0_body.st52.grows

/-- **The relation at the merged state** from the relation at the merge (`Conv.site_merge`'s; `merged_relB`). -/
theorem PRE_first_tail_x15_r0_body.merged52 {FR : Map → Nat → PRE_first_tail_x15_r0_body.st52.F.S → PRE_first_tail_x15_r0_body.st52.F.S → Prop} {W : Nat → Option WFrame} {stk : List Frame} {M : Map}
    {ν : Nat → F64} {K : Host.Ts.Sim.Ctx} {S : SSrv} {t : St PRE_first_tail_x15_r0_body.st52.F.S} {C : CSrv} {n0 : Nat}
    (h : RelB PRE_first_tail_x15_r0_body.st52.F FR W stk M ν K (Conv.mergeSt Map.id (Map.id.res n0 n0) PRE_first_tail_x15_r0_body.rs52 PRE_first_tail_x15_r0_body.st52.wr PRE_first_tail_x15_r0_body.s513 PRE_first_tail_x15_r0_body.st52.s2 PRE_first_tail_x15_r0_body.st52.s0
      PRE_first_tail_x15_r0_body.st52.s2.ffi) S t C) : RelB PRE_first_tail_x15_r0_body.st52.F FR W stk M ν K PRE_first_tail_x15_r0_body.s514 S t C :=
  merged_relB PRE_first_tail_x15_r0_body.iso52 PRE_first_tail_x15_r0_body.stFoot52 PRE_first_tail_x15_r0_body.wrNodup52 PRE_first_tail_x15_r0_body.wrBound52 PRE_first_tail_x15_r0_body.trace52 PRE_first_tail_x15_r0_body.mheap52
    PRE_first_tail_x15_r0_body.mnext52 PRE_first_tail_x15_r0_body.mctl52 PRE_first_tail_x15_r0_body.mstack52 PRE_first_tail_x15_r0_body.mjobs52 PRE_first_tail_x15_r0_body.mffi52 PRE_first_tail_x15_r0_body.mtrace52 PRE_first_tail_x15_r0_body.mstores52 h

def PRE_first_tail_x15_r0_body.arrEl52_2665 : List Val := []
kernel_rfl PRE_first_tail_x15_r0_body.arrE52_2665 : arrOf PRE_first_tail_x15_r0_body.s514 2665 = arrOf PRE_first_tail_x15_r0_body.s0 2665 ++ PRE_first_tail_x15_r0_body.arrEl52_2665
kernel_rfl PRE_first_tail_x15_r0_body.arrA52_2665 : isArrB PRE_first_tail_x15_r0_body.s514 2665 = true
theorem PRE_first_tail_x15_r0_body.arr52_2665 : ∃ o, PRE_first_tail_x15_r0_body.s514.heap.get 2665 = some (.obj o) ∧ o.kind = .array (arrOf PRE_first_tail_x15_r0_body.s0 2665 ++ PRE_first_tail_x15_r0_body.arrEl52_2665) :=
  arrExt_of PRE_first_tail_x15_r0_body.arrE52_2665 PRE_first_tail_x15_r0_body.arrA52_2665
kernel_rfl PRE_first_tail_x15_r0_body.arrN52_2665 : numRefsB PRE_first_tail_x15_r0_body.S0.tab.length PRE_first_tail_x15_r0_body.arrEl52_2665 = true
theorem PRE_first_tail_x15_r0_body.arrR52_2665 : Prefill.NumRefs PRE_first_tail_x15_r0_body.S0.tab.length PRE_first_tail_x15_r0_body.arrEl52_2665 := numRefs_of PRE_first_tail_x15_r0_body.arrN52_2665

def PRE_first_tail_x15_r0_body.arrEl52_2673467 : List Val := []
kernel_rfl PRE_first_tail_x15_r0_body.arrE52_2673467 : arrOf PRE_first_tail_x15_r0_body.s514 2673467 = arrOf PRE_first_tail_x15_r0_body.s0 2673467 ++ PRE_first_tail_x15_r0_body.arrEl52_2673467
kernel_rfl PRE_first_tail_x15_r0_body.arrA52_2673467 : isArrB PRE_first_tail_x15_r0_body.s514 2673467 = true
theorem PRE_first_tail_x15_r0_body.arr52_2673467 : ∃ o, PRE_first_tail_x15_r0_body.s514.heap.get 2673467 = some (.obj o) ∧ o.kind = .array (arrOf PRE_first_tail_x15_r0_body.s0 2673467 ++ PRE_first_tail_x15_r0_body.arrEl52_2673467) :=
  arrExt_of PRE_first_tail_x15_r0_body.arrE52_2673467 PRE_first_tail_x15_r0_body.arrA52_2673467
kernel_rfl PRE_first_tail_x15_r0_body.arrN52_2673467 : numRefsB PRE_first_tail_x15_r0_body.S0.tab.length PRE_first_tail_x15_r0_body.arrEl52_2673467 = true
theorem PRE_first_tail_x15_r0_body.arrR52_2673467 : Prefill.NumRefs PRE_first_tail_x15_r0_body.S0.tab.length PRE_first_tail_x15_r0_body.arrEl52_2673467 := numRefs_of PRE_first_tail_x15_r0_body.arrN52_2673467

kernel_rfl PRE_first_tail_x15_r0_body.w4910k52 : isArrB PRE_first_tail_x15_r0_body.s514 4910 = false
theorem PRE_first_tail_x15_r0_body.keep52 (q : List Val) : Host.Ts.Sim.Prefill.KeepsAtW (framesP PRE_first_tail_x15_r0_body.s0 q) PRE_first_tail_x15_r0_body.s514 := by
  intro a pre pre' hx o es ho hk
  unfold framesP at hx
  simp only at hx
  cases h1 : Nat.beq a 2665
  · cases h2 : Nat.beq a 4910
    · rw [h1, h2] at hx; cases hx
    · have := Nat.eq_of_beq_eq_true h2; subst this
      rw [h1, h2] at hx; cases hx
      exact (notArr_of PRE_first_tail_x15_r0_body.w4910k52 ho hk).elim
  · have := Nat.eq_of_beq_eq_true h1; subst this
    rw [h1] at hx; cases hx
    obtain ⟨o', ho', hk'⟩ := PRE_first_tail_x15_r0_body.arr52_2665
    rw [ho] at ho'; cases ho'
    rw [hk'] at hk; cases hk
    simp [PRE_first_tail_x15_r0_body.arrEl52_2665]

end Host.Load.Run.Tpl
end

section -- SiteZ52
set_option Elab.async false
namespace Host.Load.Run.Tpl
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
open Host.Ts Host.Ts.Sim Host.Ts.Sim.Template

/-! The compaction's state shift at call site 52 of chain `PRE_first_tail_x15_r0_body` (`Conv.compact_shift`): the call `PRE_first_tail_x15_r0_body.s513`, the merged
state `PRE_first_tail_x15_r0_body.s514`, the canonical state `PRE_first_tail_x15_r0_body.s515`; its frames [2665,2673467,2673472,2673473] (kept arrays [2665,2673467]). -/

-- the map's places and counters
kernel_rfl PRE_first_tail_x15_r0_body.zpl52 : PRE_first_tail_x15_r0_body.pl52.all (Nat.ble PRE_first_tail_x15_r0_body.s513.next) = true
kernel_rfl PRE_first_tail_x15_r0_body.zplnd52 : nodupT PRE_first_tail_x15_r0_body.pl52 PTrie.nil = true
kernel_rfl PRE_first_tail_x15_r0_body.zn152 : Nat.ble PRE_first_tail_x15_r0_body.s513.next 2715881 = true
kernel_rfl PRE_first_tail_x15_r0_body.zfirst52 : Nat.ble aFirst PRE_first_tail_x15_r0_body.s513.next = true
kernel_rfl PRE_first_tail_x15_r0_body.zscn52 : PRE_first_tail_x15_r0_body.s515.next = PRE_first_tail_x15_r0_body.s513.next + PRE_first_tail_x15_r0_body.pl52.length
kernel_rfl PRE_first_tail_x15_r0_body.zsmn52 : PRE_first_tail_x15_r0_body.s514.next = 2715881
kernel_rfl PRE_first_tail_x15_r0_body.zgrow52 : Nat.ble PRE_first_tail_x15_r0_body.s515.next PRE_first_tail_x15_r0_body.s514.next = true
-- the tables
kernel_rfl PRE_first_tail_x15_r0_body.zfresh52 : PRE_first_tail_x15_r0_body.S513.tab.all (fun e => PRE_first_tail_x15_r0_body.cws52.all fun v => e.noVar v) = true
kernel_rfl PRE_first_tail_x15_r0_body.zcnd52 : nodupT PRE_first_tail_x15_r0_body.cws52 PTrie.nil = true
kernel_rfl PRE_first_tail_x15_r0_body.znrHi52 : PRE_first_tail_x15_r0_body.nr52.all (fun r => Nat.blt r PRE_first_tail_x15_r0_body.S514.tab.length) = true
-- the frames: every framed address below the call's counter; the kept arrays the chain start's, extended in the merged state
kernel_rfl PRE_first_tail_x15_r0_body.zfrlt52 : [2665, 2673467, 2673472, 2673473].all (fun a => Nat.blt a PRE_first_tail_x15_r0_body.s513.next) = true
kernel_rfl PRE_first_tail_x15_r0_body.zg52_2665 : PRE_first_tail_x15_r0_body.s515.heap.get 2665 = some (.obj (objOf PRE_first_tail_x15_r0_body.s515 2665))
kernel_rfl PRE_first_tail_x15_r0_body.zk52_2665 : (objOf PRE_first_tail_x15_r0_body.s515 2665).kind = .array (arrOf PRE_first_tail_x15_r0_body.s0 2665)
kernel_rfl PRE_first_tail_x15_r0_body.zm52_2665 : PRE_first_tail_x15_r0_body.s514.heap.get 2665 = some (.obj { PRE_first_tail_x15_r0_body.kappa52.obj (objOf PRE_first_tail_x15_r0_body.s515 2665) with
  kind := .array (arrOf PRE_first_tail_x15_r0_body.s0 2665 ++ (arrOf PRE_first_tail_x15_r0_body.s514 2665).drop (arrOf PRE_first_tail_x15_r0_body.s0 2665).length) })
kernel_rfl PRE_first_tail_x15_r0_body.zg52_2673467 : PRE_first_tail_x15_r0_body.s515.heap.get 2673467 = some (.obj (objOf PRE_first_tail_x15_r0_body.s515 2673467))
kernel_rfl PRE_first_tail_x15_r0_body.zk52_2673467 : (objOf PRE_first_tail_x15_r0_body.s515 2673467).kind = .array (arrOf PRE_first_tail_x15_r0_body.s0 2673467)
kernel_rfl PRE_first_tail_x15_r0_body.zm52_2673467 : PRE_first_tail_x15_r0_body.s514.heap.get 2673467 = some (.obj { PRE_first_tail_x15_r0_body.kappa52.obj (objOf PRE_first_tail_x15_r0_body.s515 2673467) with
  kind := .array (arrOf PRE_first_tail_x15_r0_body.s0 2673467 ++ (arrOf PRE_first_tail_x15_r0_body.s514 2673467).drop (arrOf PRE_first_tail_x15_r0_body.s0 2673467).length) })
kernel_rfl PRE_first_tail_x15_r0_body.zw52_4910 : (PRE_first_tail_x15_r0_body.s515.heap.get 4910).isSome = true
kernel_rfl PRE_first_tail_x15_r0_body.zw52_2673472 : (PRE_first_tail_x15_r0_body.s515.heap.get 2673472).isSome = true
kernel_rfl PRE_first_tail_x15_r0_body.zw52_2673473 : (PRE_first_tail_x15_r0_body.s515.heap.get 2673473).isSome = true
-- the heap: the changed list in range, holding the stage's written and fresh addresses; the canonical side's image
kernel_rfl PRE_first_tail_x15_r0_body.zclbd52 : PRE_first_tail_x15_r0_body.cl52.all (fun b => Nat.blt (b / 4096) (4 ^ 31)) = true
kernel_rfl PRE_first_tail_x15_r0_body.zwr52 : PRE_first_tail_x15_r0_body.st52.wr.all (fun b => !Nat.blt b PRE_first_tail_x15_r0_body.s513.next || PRE_first_tail_x15_r0_body.cl52.contains b) = true
def PRE_first_tail_x15_r0_body.zl52 : List Nat := PRE_first_tail_x15_r0_body.cl52.filter fun a => !(List.contains [2665, 2673467] a)
kernel_rfl PRE_first_tail_x15_r0_body.zimgE52 : PRE_first_tail_x15_r0_body.zl52.map (fun a => PRE_first_tail_x15_r0_body.s514.heap.get (PRE_first_tail_x15_r0_body.kappa52.a a)) = PRE_first_tail_x15_r0_body.zl52.map (fun a => (PRE_first_tail_x15_r0_body.s515.heap.get a).map PRE_first_tail_x15_r0_body.kappa52.hobj)
theorem PRE_first_tail_x15_r0_body.zimg52 : HeapImg PRE_first_tail_x15_r0_body.kappa52 PRE_first_tail_x15_r0_body.s515 PRE_first_tail_x15_r0_body.s514 PRE_first_tail_x15_r0_body.zl52 := PRE_first_tail_x15_r0_body.zimgE52
-- the roots and their supports
kernel_rfl PRE_first_tail_x15_r0_body.zctl52 : PRE_first_tail_x15_r0_body.s514.ctl = PRE_first_tail_x15_r0_body.kappa52.ctl PRE_first_tail_x15_r0_body.s515.ctl
kernel_rfl PRE_first_tail_x15_r0_body.zstack52 : PRE_first_tail_x15_r0_body.s514.stack = PRE_first_tail_x15_r0_body.s515.stack.map PRE_first_tail_x15_r0_body.kappa52.frame
kernel_rfl PRE_first_tail_x15_r0_body.zjobs52 : PRE_first_tail_x15_r0_body.s514.jobs = PRE_first_tail_x15_r0_body.s515.jobs.map PRE_first_tail_x15_r0_body.kappa52.job
kernel_rfl PRE_first_tail_x15_r0_body.zstores52 : PRE_first_tail_x15_r0_body.s514.stores = PRE_first_tail_x15_r0_body.kappa52.stores PRE_first_tail_x15_r0_body.s515.stores
kernel_rfl PRE_first_tail_x15_r0_body.zroots52 : checkRootsSupp PRE_first_tail_x15_r0_body.s515 2303 = true
kernel_rfl PRE_first_tail_x15_r0_body.znC52 : PRE_first_tail_x15_r0_body.S513.tab.length + PRE_first_tail_x15_r0_body.cws52.length = 2303
-- the map as `Conv.compact_shift` states it (the call's counters for the literals)
kernel_rfl PRE_first_tail_x15_r0_body.zkap52 : PRE_first_tail_x15_r0_body.kappa52 = Conv.Map.compact PRE_first_tail_x15_r0_body.s513.next 2715881 PRE_first_tail_x15_r0_body.S513.tab.length PRE_first_tail_x15_r0_body.pl52 (PRE_first_tail_x15_r0_body.nr52.map NumV.ref) PRE_first_tail_x15_r0_body.kd52.big
  PRE_first_tail_x15_r0_body.kd52.region PRE_first_tail_x15_r0_body.kd52.nodeF
-- the bridge inactive at the canonical state (`Conv.FullShiftQ.toX`; the merged state's bridge is the canonical's: cbridge)
theorem PRE_first_tail_x15_r0_body.zbin52 : (Host.Ts.Sim.Full.bridgeOf PRE_first_tail_x15_r0_body.s515.ffi).active = false := (Host.Load.Boot.replay_active Host.Load.Run.Prompt.P.oblog2818)
-- the JS bookkeeping's step (`Conv.JClean.step` over the changed list) and the canonical roots' bigint freedom
kernel_rfl PRE_first_tail_x15_r0_body.zjc52 : Conv.jcleanListB (⟨19233, 16329, 2715879, 2303⟩ : Conv.Cnt) PRE_first_tail_x15_r0_body.s515 PRE_first_tail_x15_r0_body.cl52 = true
kernel_rfl PRE_first_tail_x15_r0_body.zrootsB52 : noBigRootsP (fun i => !Conv.oldBigB (⟨19233, 16329, 2715879, 2303⟩ : Conv.Cnt) i) PRE_first_tail_x15_r0_body.s515.trace PRE_first_tail_x15_r0_body.s515 = true
kernel_rfl PRE_first_tail_x15_r0_body.zhm52 : Nat.ble (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s0.ffi).mlx.nnext 16329 = true
theorem PRE_first_tail_x15_r0_body.cjcl52 (h : Conv.JClean (⟨19233, 16329, 2715879, 2303⟩ : Conv.Cnt) PRE_first_tail_x15_r0_body.s513) : Conv.JClean (⟨19233, 16329, 2715879, 2303⟩ : Conv.Cnt) PRE_first_tail_x15_r0_body.s515 :=
  Conv.JClean.step h (Conv.Cnt.le_of_leB PRE_first_tail_x15_r0_body.cle52)
    (Conv.heap_off_setAll PRE_first_tail_x15_r0_body.cheap52 fun a ha => Nat.blt_eq.mp (List.all_eq_true.mp PRE_first_tail_x15_r0_body.zclbd52 a ha)) PRE_first_tail_x15_r0_body.zjc52

end Host.Load.Run.Tpl
end

section -- st52/TypedLast
set_option Elab.async false
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
namespace Host.Load.Run.Tpl
open Host.Ts Host.Ts.Sim Host.Ts.Sim.Template

boot_rfl PRE_first_tail_x15_r0_body.st52.bodyLast from PRE_first_tail_x15_r0_body.st52.s1 to PRE_first_tail_x15_r0_body.st52.s2 :
  interpS (step PRE_first_tail_x15_r0_body.st52.F PRE_first_tail_x15_r0_body.st52.s1).run PRE_first_tail_x15_r0_body.st52.S1 = some (PRE_first_tail_x15_r0_body.st52.s2, PRE_first_tail_x15_r0_body.st52.S2)
kernel_rfl PRE_first_tail_x15_r0_body.st52.bodyHalt : isHalt PRE_first_tail_x15_r0_body.st52.s1.ctl = false
kernel_rfl PRE_first_tail_x15_r0_body.st52.bodyTopCheck : noBlockTop PRE_first_tail_x15_r0_body.st52.s2.stack = true

end Host.Load.Run.Tpl
end

section -- st52/TypedOk
set_option Elab.async false
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
namespace Host.Load.Run.Tpl
open Host.Ts Host.Ts.Sim Host.Ts.Sim.Template

noncomputable def PRE_first_tail_x15_r0_body.st52.bodyOkL (bytes : List Byte) (rows : Nat) : St PRE_first_tail_x15_r0_body.st52.F.S → SSrv → Bool :=
  okLocal (Host.Ts.Sim.Compose.VWFrames.bodyOk bytes rows)

noncomputable def PRE_first_tail_x15_r0_body.st52.bodyOkLN (bytes : List Byte) (rows : Nat) : St PRE_first_tail_x15_r0_body.st52.F.S → FSrv → Bool :=
  okLocalN (Host.Ts.Sim.Compose.VWFrames.bodyOkN bytes rows)

theorem PRE_first_tail_x15_r0_body.st52.bodyOkLN_ok (bytes : List Byte) (rows : Nat) (s : St PRE_first_tail_x15_r0_body.st52.F.S) (c : FSrv) (h : c.Wf) :
    PRE_first_tail_x15_r0_body.st52.bodyOkLN bytes rows s c = PRE_first_tail_x15_r0_body.st52.bodyOkL bytes rows s c.toS :=
  okLocalN_ok (Host.Ts.Sim.Compose.VWFrames.bodyOkN_ok bytes rows) s c h

kernel_rfl PRE_first_tail_x15_r0_body.st52.bodyAccepted0 :
  (fun (bytes : List Byte) (rows : Nat) => PRE_first_tail_x15_r0_body.st52.bodyOkL bytes rows PRE_first_tail_x15_r0_body.st52.s0 PRE_first_tail_x15_r0_body.st52.S0) = fun _ _ => true

kernel_rfl PRE_first_tail_x15_r0_body.st52.bodyAccepted1 :
  (fun (bytes : List Byte) (rows : Nat) => PRE_first_tail_x15_r0_body.st52.bodyOkL bytes rows PRE_first_tail_x15_r0_body.st52.s1 PRE_first_tail_x15_r0_body.st52.S1) = fun _ _ => true

end Host.Load.Run.Tpl
end

section -- st52/TypedK0
set_option Elab.async false
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
namespace Host.Load.Run.Tpl
open Host.Ts Host.Ts.Sim Host.Ts.Sim.Template

boot_rfl PRE_first_tail_x15_r0_body.st52.bodyK0F from PRE_first_tail_x15_r0_body.st52.s0 to PRE_first_tail_x15_r0_body.st52.s1 :
  (fun (bytes : List Byte) (rows : Nat) => runOkS PRE_first_tail_x15_r0_body.st52.F (PRE_first_tail_x15_r0_body.st52.bodyOkLN bytes rows)
    ((nth? PRE_first_tail_x15_r0_body.st52.ks 0).getD 0) PRE_first_tail_x15_r0_body.st52.s0 PRE_first_tail_x15_r0_body.st52.S0) = fun _ _ => some (PRE_first_tail_x15_r0_body.st52.s1, PRE_first_tail_x15_r0_body.st52.S1)
theorem PRE_first_tail_x15_r0_body.st52.bodyK0 :
  (fun (bytes : List Byte) (rows : Nat) => runOk PRE_first_tail_x15_r0_body.st52.F (PRE_first_tail_x15_r0_body.st52.bodyOkL bytes rows)
    ((nth? PRE_first_tail_x15_r0_body.st52.ks 0).getD 0) PRE_first_tail_x15_r0_body.st52.s0 PRE_first_tail_x15_r0_body.st52.S0) = fun _ _ => some (PRE_first_tail_x15_r0_body.st52.s1, PRE_first_tail_x15_r0_body.st52.S1) :=
  runOk_fun_of_runOkS PRE_first_tail_x15_r0_body.st52.bodyOkLN_ok PRE_first_tail_x15_r0_body.st52.bodyK0F
end Host.Load.Run.Tpl
end

section -- st52/TypedTpl
set_option Elab.async false
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
namespace Host.Load.Run.Tpl
open Host.Ts Host.Ts.Sim Host.Ts.Sim.Template

theorem PRE_first_tail_x15_r0_body.st52.bodyRun (bytes : List Byte) (rows : Nat) :
    runOk PRE_first_tail_x15_r0_body.st52.F (PRE_first_tail_x15_r0_body.st52.bodyOkL bytes rows) 27 PRE_first_tail_x15_r0_body.st52.s0 PRE_first_tail_x15_r0_body.st52.S0 = some (PRE_first_tail_x15_r0_body.st52.s1, PRE_first_tail_x15_r0_body.st52.S1) :=
  (congrFun (congrFun PRE_first_tail_x15_r0_body.st52.bodyK0 bytes) rows)

theorem PRE_first_tail_x15_r0_body.st52.bodyLocal (bytes : List Byte) (rows : Nat) : ∀ s S, PRE_first_tail_x15_r0_body.st52.bodyOkL bytes rows s S = true → Disp.localB s = true := okLocal_localB

noncomputable def PRE_first_tail_x15_r0_body.st52.bodyTpl (bytes : List Byte) (rows : Nat) : Host.Ts.Sim.Stage.StageTpl PRE_first_tail_x15_r0_body.st52.F (PRE_first_tail_x15_r0_body.st52.bodyOkL bytes rows) where
  s0 := PRE_first_tail_x15_r0_body.st52.s0
  S0 := PRE_first_tail_x15_r0_body.st52.S0
  s1 := PRE_first_tail_x15_r0_body.st52.s1
  S1 := PRE_first_tail_x15_r0_body.st52.S1
  s2 := PRE_first_tail_x15_r0_body.st52.s2
  S2 := PRE_first_tail_x15_r0_body.st52.S2
  n := 27
  ok0 := congrFun (congrFun PRE_first_tail_x15_r0_body.st52.bodyAccepted0 bytes) rows
  run := PRE_first_tail_x15_r0_body.st52.bodyRun bytes rows
  ok1 := congrFun (congrFun PRE_first_tail_x15_r0_body.st52.bodyAccepted1 bytes) rows
  halt := PRE_first_tail_x15_r0_body.st52.bodyHalt
  last := PRE_first_tail_x15_r0_body.st52.bodyLast
  top := noBlockTop_sound PRE_first_tail_x15_r0_body.st52.bodyTopCheck
end Host.Load.Run.Tpl
end

section -- SiteC53
set_option Elab.async false
namespace Host.Load.Run.Tpl
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
open Host.Ts Host.Ts.Sim Host.Ts.Sim.Template

/-! The compaction after the merge at call site 53 of chain `PRE_first_tail_x15_r0_body` (`Conv.compact`, `Conv.full_compactQ`): the canonical
state `PRE_first_tail_x15_r0_body.s519` (the stage's results at canonical places, its trace the call's) under `PRE_first_tail_x15_r0_body.kappa53` into the merged state
`PRE_first_tail_x15_r0_body.s518`. -/

def PRE_first_tail_x15_r0_body.pl53 : List Nat := [2716186]
def PRE_first_tail_x15_r0_body.nr53 : List Nat := []
/-- The native part of the compaction map (canonical → merged handles and nodes: its `big`, `region`, `nodeF`). -/
def PRE_first_tail_x15_r0_body.kd53 : RData :=
  ⟨2716168, 2716187, Stage.setAll PTrie.nil [(2716167, 2716186)], Stage.setAll PTrie.nil [],
   19240, 19240, 16333, 16333, Stage.setAll PTrie.nil [],
   Stage.setAll PTrie.nil []⟩
/-- **The compaction map.** -/
noncomputable def PRE_first_tail_x15_r0_body.kappa53 : Map :=
  Conv.Map.compact 2716167 2716187 2320 PRE_first_tail_x15_r0_body.pl53 (PRE_first_tail_x15_r0_body.nr53.map NumV.ref) PRE_first_tail_x15_r0_body.kd53.big
    PRE_first_tail_x15_r0_body.kd53.region PRE_first_tail_x15_r0_body.kd53.nodeF
/-- The canonical result variables and their images, the merged state's entries (`Conv.compactθ`). -/
def PRE_first_tail_x15_r0_body.cws53 : List Nat := []
noncomputable def PRE_first_tail_x15_r0_body.crs53 : List SymE := PRE_first_tail_x15_r0_body.nr53.map fun r => (nth? PRE_first_tail_x15_r0_body.S518.tab r).getD (.var 0)
noncomputable def PRE_first_tail_x15_r0_body.ctheta53 : Nat → SymE := Conv.compactθ PRE_first_tail_x15_r0_body.cws53 PRE_first_tail_x15_r0_body.crs53
/-- The call's entries the stage wrote (renamed in the canonical state with the results). -/
def PRE_first_tail_x15_r0_body.wrB53 : List Nat := [2665, 2673467]

kernel_rfl PRE_first_tail_x15_r0_body.ctab53 : PRE_first_tail_x15_r0_body.S519.tab = PRE_first_tail_x15_r0_body.S517.tab ++ PRE_first_tail_x15_r0_body.cws53.map SymE.var
kernel_rfl PRE_first_tail_x15_r0_body.ctrace53 : PRE_first_tail_x15_r0_body.s519.trace = PRE_first_tail_x15_r0_body.s517.trace
kernel_rfl PRE_first_tail_x15_r0_body.cnext53 : PRE_first_tail_x15_r0_body.s519.next = 2716168
kernel_rfl PRE_first_tail_x15_r0_body.ccounters53 : ((Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s519.ffi).mlx.next, (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s519.ffi).mlx.nnext) = (19240, 16333)
-- the merged state's readback queue, carried to the canonical state (`Conv.FullShiftQ.tokens`, `tokSupp`)
kernel_rfl PRE_first_tail_x15_r0_body.cqueue53 : (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s518.ffi).mlx.tokens = (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s519.ffi).mlx.tokens.map PRE_first_tail_x15_r0_body.kappa53.nv
kernel_rfl PRE_first_tail_x15_r0_body.ctokSupp53 : (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s519.ffi).mlx.tokens.all (bSN 2320) = true
-- the written and the result entries carry no bigint of the canonical fresh band [next, E) and no fresh region
kernel_rfl PRE_first_tail_x15_r0_body.cclean53 : Conv.cleanListB 19240 131072 (fun r => Nat.ble 76960 r) PRE_first_tail_x15_r0_body.s519
    (PRE_first_tail_x15_r0_body.wrB53 ++ (List.range 1).map (2716167 + ·)) = true
kernel_rfl PRE_first_tail_x15_r0_body.cbigs53 : bigsOutB 19240 131072 (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s519.ffi).mlx = true

end Host.Load.Run.Tpl
end

section -- SiteK53
set_option Elab.async false
namespace Host.Load.Run.Tpl
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
open Host.Ts Host.Ts.Sim Host.Ts.Sim.Template

/-! The canonical state's closedness from the call's (`Conv.closed_of_callB`, `Conv.sst_of_callB`): it keeps the call's entries
off the written and the result ones (`PRE_first_tail_x15_r0_body.cl53`; natively the written and result handles, the result nodes, the written
and result items), and those are checked. -/

def PRE_first_tail_x15_r0_body.cl53 : List Nat := [2665, 2673467, 2716167]
def PRE_first_tail_x15_r0_body.clo53 : List Nat := []
def PRE_first_tail_x15_r0_body.cln53 : List Nat := []
def PRE_first_tail_x15_r0_body.cli53 : List Nat := []
kernel_rfl PRE_first_tail_x15_r0_body.cheap53 : PRE_first_tail_x15_r0_body.s519.heap = Stage.setAll PRE_first_tail_x15_r0_body.s517.heap (PRE_first_tail_x15_r0_body.cl53.filterMap fun a => (PRE_first_tail_x15_r0_body.s519.heap.get a).map (a, ·))
kernel_rfl PRE_first_tail_x15_r0_body.cnextLe53 : Nat.ble PRE_first_tail_x15_r0_body.s517.next PRE_first_tail_x15_r0_body.s519.next = true
kernel_rfl PRE_first_tail_x15_r0_body.ckeepP53 : Conv.keptPresentB PRE_first_tail_x15_r0_body.s517 PRE_first_tail_x15_r0_body.s519 PRE_first_tail_x15_r0_body.cl53 = true
kernel_rfl PRE_first_tail_x15_r0_body.csupp53 : Conv.suppListB PRE_first_tail_x15_r0_body.s519 2320 PRE_first_tail_x15_r0_body.cl53 = true
kernel_rfl PRE_first_tail_x15_r0_body.cbound53 : Conv.boundListB PRE_first_tail_x15_r0_body.s519 PRE_first_tail_x15_r0_body.cl53 = true
kernel_rfl PRE_first_tail_x15_r0_body.cnodesK53 : (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s519.ffi).mlx.nodes = Stage.setAll (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s517.ffi).mlx.nodes (PRE_first_tail_x15_r0_body.cln53.filterMap fun i => ((Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s519.ffi).mlx.nodes.get i).map (i, ·))
kernel_rfl PRE_first_tail_x15_r0_body.cobjsK53 : (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s519.ffi).mlx.objs = Stage.setAll (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s517.ffi).mlx.objs (PRE_first_tail_x15_r0_body.clo53.filterMap fun i => ((Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s519.ffi).mlx.objs.get i).map (i, ·))
kernel_rfl PRE_first_tail_x15_r0_body.citemsK53 : (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s519.ffi).mlx.items = Stage.setAll (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s517.ffi).mlx.items (PRE_first_tail_x15_r0_body.cli53.filterMap fun i => ((Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s519.ffi).mlx.items.get i).map (i, ·))
kernel_rfl PRE_first_tail_x15_r0_body.csst53 : Conv.sstListB 2320 (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s519.ffi).mlx PRE_first_tail_x15_r0_body.cln53 PRE_first_tail_x15_r0_body.clo53 PRE_first_tail_x15_r0_body.cli53 = true

end Host.Load.Run.Tpl
end

section -- SiteCl53
set_option Elab.async false
namespace Host.Load.Run.Tpl
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
open Host.Ts Host.Ts.Sim Host.Ts.Sim.Template

kernel_rfl PRE_first_tail_x15_r0_body.ckA53 : (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s519.ffi).mlx.arrs = Stage.setAll (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s517.ffi).mlx.arrs (PRE_first_tail_x15_r0_body.clo53.filterMap fun i => ((Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s519.ffi).mlx.arrs.get i).map (i, ·))
kernel_rfl PRE_first_tail_x15_r0_body.cbd53 : (PRE_first_tail_x15_r0_body.clo53 ++ PRE_first_tail_x15_r0_body.cln53 ++ PRE_first_tail_x15_r0_body.cli53).all (fun i => Nat.blt (i / 4096) (4 ^ 31)) = true
kernel_rfl PRE_first_tail_x15_r0_body.cle53 : Conv.Cnt.leB (⟨19240, 16333, 2716167, 2320⟩ : Conv.Cnt) (⟨19240, 16333, 2716168, 2320⟩ : Conv.Cnt) = true
kernel_rfl PRE_first_tail_x15_r0_body.cck53 : Conv.ncleanListB (⟨19240, 16333, 2716168, 2320⟩ : Conv.Cnt) (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s519.ffi).mlx PRE_first_tail_x15_r0_body.clo53 PRE_first_tail_x15_r0_body.cln53 PRE_first_tail_x15_r0_body.cli53 = true
theorem PRE_first_tail_x15_r0_body.cncl53 (h : Conv.NClean (⟨19240, 16333, 2716167, 2320⟩ : Conv.Cnt) (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s517.ffi).mlx) : Conv.NClean (⟨19240, 16333, 2716168, 2320⟩ : Conv.Cnt) (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s519.ffi).mlx :=
  Conv.NClean.stepKeep h PRE_first_tail_x15_r0_body.cle53 PRE_first_tail_x15_r0_body.ckA53 PRE_first_tail_x15_r0_body.cobjsK53 PRE_first_tail_x15_r0_body.cnodesK53 PRE_first_tail_x15_r0_body.citemsK53 PRE_first_tail_x15_r0_body.cbd53 PRE_first_tail_x15_r0_body.cck53

end Host.Load.Run.Tpl
end

section -- SiteS53
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
noncomputable abbrev PRE_first_tail_x15_r0_body.cx0_53 : Host.Load.LSt := clearTokens (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s519.ffi)
noncomputable abbrev PRE_first_tail_x15_r0_body.cx1_53 : Host.Load.LSt := clearTokens (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s518.ffi)
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
kernel_rfl PRE_first_tail_x15_r0_body.fcxn53 : (⟨19240, 16333, 2716167, 2320⟩ : Conv.Cnt).xn = (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s517.ffi).mlx.next
kernel_rfl PRE_first_tail_x15_r0_body.fcnn53 : (⟨19240, 16333, 2716167, 2320⟩ : Conv.Cnt).nn = (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s517.ffi).mlx.nnext
kernel_rfl PRE_first_tail_x15_r0_body.fle053 : (Nat.ble (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s517.ffi).mlx.next PRE_first_tail_x15_r0_body.cx0_53.mlx.next && Nat.ble (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s517.ffi).mlx.nnext PRE_first_tail_x15_r0_body.cx0_53.mlx.nnext && Nat.ble (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s517.ffi).mlx.next RData.bigHi) = true
kernel_rfl PRE_first_tail_x15_r0_body.fnk53 : (PTrie.keysA PRE_first_tail_x15_r0_body.kd53.node).all (Nat.ble (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s517.ffi).mlx.nnext) = true
-- the merged state keeps the call's entries off the stage's footprint
kernel_rfl PRE_first_tail_x15_r0_body.f1A53 : PRE_first_tail_x15_r0_body.cx1_53.mlx.arrs = Stage.setAll (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s517.ffi).mlx.arrs (PRE_first_tail_x15_r0_body.cwS53.filterMap fun i => (PRE_first_tail_x15_r0_body.cx1_53.mlx.arrs.get i).map (i, ·))
kernel_rfl PRE_first_tail_x15_r0_body.f1O53 : PRE_first_tail_x15_r0_body.cx1_53.mlx.objs = Stage.setAll (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s517.ffi).mlx.objs (PRE_first_tail_x15_r0_body.cwS53.filterMap fun i => (PRE_first_tail_x15_r0_body.cx1_53.mlx.objs.get i).map (i, ·))
kernel_rfl PRE_first_tail_x15_r0_body.f1N53 : PRE_first_tail_x15_r0_body.cx1_53.mlx.nodes = Stage.setAll (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s517.ffi).mlx.nodes (PRE_first_tail_x15_r0_body.cnS53.filterMap fun i => (PRE_first_tail_x15_r0_body.cx1_53.mlx.nodes.get i).map (i, ·))
kernel_rfl PRE_first_tail_x15_r0_body.f1I53 : PRE_first_tail_x15_r0_body.cx1_53.mlx.items = Stage.setAll (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s517.ffi).mlx.items (PRE_first_tail_x15_r0_body.ciS53.filterMap fun i => (PRE_first_tail_x15_r0_body.cx1_53.mlx.items.get i).map (i, ·))
kernel_rfl PRE_first_tail_x15_r0_body.fbd53 : (PRE_first_tail_x15_r0_body.clo53 ++ PRE_first_tail_x15_r0_body.cln53 ++ PRE_first_tail_x15_r0_body.cli53 ++ PRE_first_tail_x15_r0_body.cwS53 ++ PRE_first_tail_x15_r0_body.cnS53 ++ PRE_first_tail_x15_r0_body.ciS53).all (fun i => Nat.blt (i / 4096) (4 ^ 31)) = true
kernel_rfl PRE_first_tail_x15_r0_body.fincW53 : PRE_first_tail_x15_r0_body.cwS53.all (fun h => !Nat.blt h (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s517.ffi).mlx.next || PRE_first_tail_x15_r0_body.clo53.contains h) = true
kernel_rfl PRE_first_tail_x15_r0_body.fincI53 : PRE_first_tail_x15_r0_body.ciS53.all (fun k => !Nat.blt k (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s517.ffi).mlx.nnext || PRE_first_tail_x15_r0_body.cli53.contains k) = true
kernel_rfl PRE_first_tail_x15_r0_body.fincN53 : PRE_first_tail_x15_r0_body.cnS53.all (Nat.ble (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s517.ffi).mlx.nnext) = true
kernel_rfl PRE_first_tail_x15_r0_body.flnF53 : PRE_first_tail_x15_r0_body.cln53.all (Nat.ble (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s517.ffi).mlx.nnext) = true
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
theorem PRE_first_tail_x15_r0_body.cfoot53 (clean : Conv.NClean (⟨19240, 16333, 2716167, 2320⟩ : Conv.Cnt) (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s517.ffi).mlx) (hltC : ∀ h, PH (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s517.ffi).mlx h → h < (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s517.ffi).mlx.next) (nltC : ∀ i, PN (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s517.ffi).mlx i → i < (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s517.ffi).mlx.nnext) (itemsC : ∀ k v, (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s517.ffi).mlx.items.get k = some v → PN (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s517.ffi).mlx k) (tracedC : ∀ h o, (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s517.ffi).mlx.objs.get h = some o → ∀ i ∈ objTraces o, i < PRE_first_tail_x15_r0_body.P53.NL) (cl : SSt (· < 2320) PRE_first_tail_x15_r0_body.cx0_53.mlx) :
    Conv.MFoot PRE_first_tail_x15_r0_body.P53 2320 PRE_first_tail_x15_r0_body.kappa53 PRE_first_tail_x15_r0_body.kd53 PRE_first_tail_x15_r0_body.khinv53 PRE_first_tail_x15_r0_body.kninv53 (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s517.ffi).mlx PRE_first_tail_x15_r0_body.cx0_53.mlx PRE_first_tail_x15_r0_body.cx1_53.mlx (⟨19240, 16333, 2716167, 2320⟩ : Conv.Cnt) PRE_first_tail_x15_r0_body.clo53 PRE_first_tail_x15_r0_body.cln53 PRE_first_tail_x15_r0_body.cli53 PRE_first_tail_x15_r0_body.cwS53 PRE_first_tail_x15_r0_body.cnS53 PRE_first_tail_x15_r0_body.ciS53 :=
  ⟨rfl, rfl, rfl, PRE_first_tail_x15_r0_body.cnh053, PRE_first_tail_x15_r0_body.cnh153, PRE_first_tail_x15_r0_body.cnn053, PRE_first_tail_x15_r0_body.cnn153, PRE_first_tail_x15_r0_body.cplo53, PRE_first_tail_x15_r0_body.ccnt53, PRE_first_tail_x15_r0_body.cnband53, PRE_first_tail_x15_r0_body.chbelow53, PRE_first_tail_x15_r0_body.chren53, PRE_first_tail_x15_r0_body.cband53, PRE_first_tail_x15_r0_body.cnh1pos53, PRE_first_tail_x15_r0_body.cnren53, PRE_first_tail_x15_r0_body.cnlow53, PRE_first_tail_x15_r0_body.cabs0a53, PRE_first_tail_x15_r0_body.cabs0b53, PRE_first_tail_x15_r0_body.ctok153, PRE_first_tail_x15_r0_body.cpend53, PRE_first_tail_x15_r0_body.cerrh53, PRE_first_tail_x15_r0_body.cfiles53, PRE_first_tail_x15_r0_body.carch53, PRE_first_tail_x15_r0_body.csizes53, PRE_first_tail_x15_r0_body.cwired53, PRE_first_tail_x15_r0_body.cfix53, clean, PRE_first_tail_x15_r0_body.fcxn53, PRE_first_tail_x15_r0_body.fcnn53, hltC, nltC, itemsC, tracedC, cl, PRE_first_tail_x15_r0_body.fle053, PRE_first_tail_x15_r0_body.fnk53, PRE_first_tail_x15_r0_body.ckA53, PRE_first_tail_x15_r0_body.cobjsK53, PRE_first_tail_x15_r0_body.cnodesK53, PRE_first_tail_x15_r0_body.citemsK53, PRE_first_tail_x15_r0_body.f1A53, PRE_first_tail_x15_r0_body.f1O53, PRE_first_tail_x15_r0_body.f1N53, PRE_first_tail_x15_r0_body.f1I53, PRE_first_tail_x15_r0_body.fbd53, PRE_first_tail_x15_r0_body.fincW53, PRE_first_tail_x15_r0_body.fincI53, PRE_first_tail_x15_r0_body.fincN53, PRE_first_tail_x15_r0_body.flnF53, PRE_first_tail_x15_r0_body.fh53, PRE_first_tail_x15_r0_body.fo53, PRE_first_tail_x15_r0_body.fok53, PRE_first_tail_x15_r0_body.fnd53, PRE_first_tail_x15_r0_body.fp53, PRE_first_tail_x15_r0_body.fnord53, PRE_first_tail_x15_r0_body.fi53, PRE_first_tail_x15_r0_body.fii53⟩
theorem PRE_first_tail_x15_r0_body.cnshift53 (clean : Conv.NClean (⟨19240, 16333, 2716167, 2320⟩ : Conv.Cnt) (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s517.ffi).mlx) (hltC : ∀ h, PH (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s517.ffi).mlx h → h < (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s517.ffi).mlx.next) (nltC : ∀ i, PN (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s517.ffi).mlx i → i < (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s517.ffi).mlx.nnext) (itemsC : ∀ k v, (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s517.ffi).mlx.items.get k = some v → PN (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s517.ffi).mlx k) (tracedC : ∀ h o, (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s517.ffi).mlx.objs.get h = some o → ∀ i ∈ objTraces o, i < PRE_first_tail_x15_r0_body.P53.NL) (cl : SSt (· < 2320) PRE_first_tail_x15_r0_body.cx0_53.mlx) : NShift PRE_first_tail_x15_r0_body.P53 2320 PRE_first_tail_x15_r0_body.kappa53 PRE_first_tail_x15_r0_body.cx0_53 PRE_first_tail_x15_r0_body.cx1_53 :=
  Conv.nshift_of_foot (PRE_first_tail_x15_r0_body.cfoot53 clean hltC nltC itemsC tracedC cl) PRE_first_tail_x15_r0_body.chost53 (compact_a_eq PRE_first_tail_x15_r0_body.ckn053 PRE_first_tail_x15_r0_body.ckn153 PRE_first_tail_x15_r0_body.ckheap53 PRE_first_tail_x15_r0_body.ckpl53)

-- the observers: the layers' states at the call, the canonical and the merged state, their footprints and checks
noncomputable def PRE_first_tail_x15_r0_body.fxC_53 : PTrie Unit := (Host.Ts.Sim.Full.freedOf PRE_first_tail_x15_r0_body.s517.ffi).getD PTrie.nil
noncomputable def PRE_first_tail_x15_r0_body.krC_53 : Host.Load.Layers.KRec := (Host.Ts.Sim.Full.krecOf PRE_first_tail_x15_r0_body.s517.ffi).getD Host.Load.Layers.KRec.empty
kernel_rfl PRE_first_tail_x15_r0_body.ofxC_53 : (Host.Ts.Sim.Full.freedOf PRE_first_tail_x15_r0_body.s517.ffi) = some PRE_first_tail_x15_r0_body.fxC_53
kernel_rfl PRE_first_tail_x15_r0_body.okrC_53 : (Host.Ts.Sim.Full.krecOf PRE_first_tail_x15_r0_body.s517.ffi) = some PRE_first_tail_x15_r0_body.krC_53
noncomputable def PRE_first_tail_x15_r0_body.fx0_53 : PTrie Unit := (Host.Ts.Sim.Full.freedOf PRE_first_tail_x15_r0_body.s519.ffi).getD PTrie.nil
noncomputable def PRE_first_tail_x15_r0_body.kr0_53 : Host.Load.Layers.KRec := (Host.Ts.Sim.Full.krecOf PRE_first_tail_x15_r0_body.s519.ffi).getD Host.Load.Layers.KRec.empty
kernel_rfl PRE_first_tail_x15_r0_body.ofx0_53 : (Host.Ts.Sim.Full.freedOf PRE_first_tail_x15_r0_body.s519.ffi) = some PRE_first_tail_x15_r0_body.fx0_53
kernel_rfl PRE_first_tail_x15_r0_body.okr0_53 : (Host.Ts.Sim.Full.krecOf PRE_first_tail_x15_r0_body.s519.ffi) = some PRE_first_tail_x15_r0_body.kr0_53
noncomputable def PRE_first_tail_x15_r0_body.fx1_53 : PTrie Unit := (Host.Ts.Sim.Full.freedOf PRE_first_tail_x15_r0_body.s518.ffi).getD PTrie.nil
noncomputable def PRE_first_tail_x15_r0_body.kr1_53 : Host.Load.Layers.KRec := (Host.Ts.Sim.Full.krecOf PRE_first_tail_x15_r0_body.s518.ffi).getD Host.Load.Layers.KRec.empty
kernel_rfl PRE_first_tail_x15_r0_body.ofx1_53 : (Host.Ts.Sim.Full.freedOf PRE_first_tail_x15_r0_body.s518.ffi) = some PRE_first_tail_x15_r0_body.fx1_53
kernel_rfl PRE_first_tail_x15_r0_body.okr1_53 : (Host.Ts.Sim.Full.krecOf PRE_first_tail_x15_r0_body.s518.ffi) = some PRE_first_tail_x15_r0_body.kr1_53
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
kernel_rfl PRE_first_tail_x15_r0_body.cbridge53 : Host.Ts.Sim.Full.bridgeOf PRE_first_tail_x15_r0_body.s518.ffi = Host.Ts.Sim.Full.bridgeOf PRE_first_tail_x15_r0_body.s519.ffi
kernel_rfl PRE_first_tail_x15_r0_body.cpendR53 : pendRegB PRE_first_tail_x15_r0_body.kappa53 (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s519.ffi).mlx = true
kernel_rfl PRE_first_tail_x15_r0_body.cpendLe53 : Nat.ble (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s519.ffi).mlx.next (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s518.ffi).mlx.next = true
/-- **The compaction's native shift**, given the call's bookkeeping, its relation's facts (the model's and the
observers') and the canonical closedness. -/
theorem PRE_first_tail_x15_r0_body.cshift53 (clean : Conv.NClean (⟨19240, 16333, 2716167, 2320⟩ : Conv.Cnt) (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s517.ffi).mlx) (hltC : ∀ h, PH (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s517.ffi).mlx h → h < (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s517.ffi).mlx.next) (nltC : ∀ i, PN (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s517.ffi).mlx i → i < (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s517.ffi).mlx.nnext) (itemsC : ∀ k v, (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s517.ffi).mlx.items.get k = some v → PN (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s517.ffi).mlx k) (tracedC : ∀ h o, (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s517.ffi).mlx.objs.get h = some o → ∀ i ∈ objTraces o, i < PRE_first_tail_x15_r0_body.P53.NL) (cl : SSt (· < 2320) PRE_first_tail_x15_r0_body.cx0_53.mlx)
    (hobjC : ∀ h, PRE_first_tail_x15_r0_body.fxC_53.get h = some () → ((Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s517.ffi).mlx.objs.get h).isSome = true)
    (hfC : ∀ h, (PRE_first_tail_x15_r0_body.krC_53.flags.get h).isSome = true → ((Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s517.ffi).mlx.objs.get h).isSome = true)
    (htC : ∀ h, (PRE_first_tail_x15_r0_body.krC_53.targs.get h).isSome = true → ((Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s517.ffi).mlx.objs.get h).isSome = true)
    (hclC : ∀ h l, PRE_first_tail_x15_r0_body.krC_53.targs.get h = some l → Host.Ts.Sim.Full.STargs (· < (⟨19240, 16333, 2716167, 2320⟩ : Conv.Cnt).n) l) :
    Conv.FullShiftQ PRE_first_tail_x15_r0_body.P53 2320 PRE_first_tail_x15_r0_body.kappa53 PRE_first_tail_x15_r0_body.s519.ffi PRE_first_tail_x15_r0_body.s518.ffi :=
  ⟨PRE_first_tail_x15_r0_body.cnshift53 clean hltC nltC itemsC tracedC cl, PRE_first_tail_x15_r0_body.cqueue53, fun t ht => bSN_sound (List.all_eq_true.mp PRE_first_tail_x15_r0_body.ctokSupp53 t ht),
    PRE_first_tail_x15_r0_body.cbridge53,
    liveShift_foot (x0' := Host.Ts.Sim.Full.mlxOf PRE_first_tail_x15_r0_body.s519.ffi) (x1' := Host.Ts.Sim.Full.mlxOf PRE_first_tail_x15_r0_body.s518.ffi) (PRE_first_tail_x15_r0_body.cfoot53 clean hltC nltC itemsC tracedC cl) rfl PRE_first_tail_x15_r0_body.ofx0_53 PRE_first_tail_x15_r0_body.ofx1_53 hobjC PRE_first_tail_x15_r0_body.ff053 PRE_first_tail_x15_r0_body.ff153 PRE_first_tail_x15_r0_body.ffck53,
    kernShift_foot (x0' := Host.Ts.Sim.Full.mlxOf PRE_first_tail_x15_r0_body.s519.ffi) (x1' := Host.Ts.Sim.Full.mlxOf PRE_first_tail_x15_r0_body.s518.ffi) (PRE_first_tail_x15_r0_body.cfoot53 clean hltC nltC itemsC tracedC cl) rfl PRE_first_tail_x15_r0_body.okr0_53 PRE_first_tail_x15_r0_body.okr1_53 (Nat.le_of_ble_eq_true PRE_first_tail_x15_r0_body.fkn53) hfC htC hclC
      PRE_first_tail_x15_r0_body.fkf053 PRE_first_tail_x15_r0_body.fkt053 PRE_first_tail_x15_r0_body.fkf153 PRE_first_tail_x15_r0_body.fkt153 PRE_first_tail_x15_r0_body.fkck53,
    pendReg_of rfl PRE_first_tail_x15_r0_body.cnh053 PRE_first_tail_x15_r0_body.cnh153 (Nat.le_of_ble_eq_true PRE_first_tail_x15_r0_body.cpendLe53) PRE_first_tail_x15_r0_body.cpendR53⟩

end Host.Load.Run.Tpl
end

section -- st53/H0
set_option Elab.async false
namespace Host.Load.Run.Tpl
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
host_stream_state PRE_first_tail_x15_r0_body.st53 0
host_stream_state PRE_first_tail_x15_r0_body.st53 1
host_stream_state PRE_first_tail_x15_r0_body.st53 2
end Host.Load.Run.Tpl
end

section -- Site53
set_option Elab.async false
namespace Host.Load.Run.Tpl
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
open Host.Ts Host.Ts.Sim Host.Ts.Sim.Template

/-! Call site 53 of chain `PRE_first_tail_x15_r0_body`: `plan__g53__g54` (`plan`), the call state `PRE_first_tail_x15_r0_body.s517`, the merged state `PRE_first_tail_x15_r0_body.s518`,
the site template `PRE_first_tail_x15_r0_body.st53` (σ = `Map.id`, θ the identity at its own site), the canonical state `PRE_first_tail_x15_r0_body.s519`: the merge.
The footprint's facts are in `SiteF53`, the compaction's in `SiteC53`, `SiteK53`, `SiteNa53`, `SiteNb53`. -/

kernel_rfl PRE_first_tail_x15_r0_body.iso53 : PRE_first_tail_x15_r0_body.st53.s0 = { PRE_first_tail_x15_r0_body.s517 with stack := [] }
/-- The caller's frames at the call. -/
noncomputable def PRE_first_tail_x15_r0_body.rs53 : List Frame := PRE_first_tail_x15_r0_body.s517.stack
kernel_rfl PRE_first_tail_x15_r0_body.n0_53 : PRE_first_tail_x15_r0_body.S517.tab.length = 2320
kernel_rfl PRE_first_tail_x15_r0_body.tab0_53 : PRE_first_tail_x15_r0_body.st53.S0.tab = PRE_first_tail_x15_r0_body.S517.tab

/-- The fresh variables of the stage's results. -/
def PRE_first_tail_x15_r0_body.ws53 : List Nat := [1907, 1908, 1909, 1910, 1911, 1912, 1913, 1914, 1915]
kernel_rfl PRE_first_tail_x15_r0_body.fresh53 : (PRE_first_tail_x15_r0_body.S517.tab.all fun e => PRE_first_tail_x15_r0_body.ws53.all fun v => e.noVar v) &&
    (PRE_first_tail_x15_r0_body.S517.oracle.all fun q => PRE_first_tail_x15_r0_body.ws53.all fun v => q.noVar v) = true
kernel_rfl PRE_first_tail_x15_r0_body.mergeTab53 : PRE_first_tail_x15_r0_body.S518.tab = PRE_first_tail_x15_r0_body.S517.tab ++ Conv.resTab PRE_first_tail_x15_r0_body.ws53
kernel_rfl PRE_first_tail_x15_r0_body.mergeLen53 : PRE_first_tail_x15_r0_body.st53.S2.tab.length - PRE_first_tail_x15_r0_body.st53.S0.tab.length = 9

-- The merged state: the instance's return state with the caller's frames (`PRE_first_tail_x15_r0_body.merged53`, `merged_relB`).
kernel_rfl PRE_first_tail_x15_r0_body.mheap53 : PRE_first_tail_x15_r0_body.s518.heap = PRE_first_tail_x15_r0_body.st53.s2.heap
kernel_rfl PRE_first_tail_x15_r0_body.mnext53 : PRE_first_tail_x15_r0_body.s518.next = PRE_first_tail_x15_r0_body.st53.s2.next
kernel_rfl PRE_first_tail_x15_r0_body.mctl53 : PRE_first_tail_x15_r0_body.s518.ctl = PRE_first_tail_x15_r0_body.st53.s2.ctl
kernel_rfl PRE_first_tail_x15_r0_body.mstack53 : PRE_first_tail_x15_r0_body.s518.stack = PRE_first_tail_x15_r0_body.st53.s2.stack ++ PRE_first_tail_x15_r0_body.s517.stack
kernel_rfl PRE_first_tail_x15_r0_body.mjobs53 : PRE_first_tail_x15_r0_body.s518.jobs = PRE_first_tail_x15_r0_body.st53.s2.jobs
kernel_rfl PRE_first_tail_x15_r0_body.mffi53 : PRE_first_tail_x15_r0_body.s518.ffi = PRE_first_tail_x15_r0_body.st53.s2.ffi
kernel_rfl PRE_first_tail_x15_r0_body.mtrace53 : PRE_first_tail_x15_r0_body.s518.trace = PRE_first_tail_x15_r0_body.st53.s2.trace
kernel_rfl PRE_first_tail_x15_r0_body.mstores53 : PRE_first_tail_x15_r0_body.s518.stores = PRE_first_tail_x15_r0_body.st53.s2.stores

end Host.Load.Run.Tpl
end

section -- SiteD53
set_option Elab.async false
namespace Host.Load.Run.Tpl
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
open Host.Ts Host.Ts.Sim Host.Ts.Sim.Template

/-! The canonical results at call site 53 of chain `PRE_first_tail_x15_r0_body`: their values in the instance's end table, the references past
the call's table, the canonical variables apart from the stage's. -/

kernel_rfl PRE_first_tail_x15_r0_body.cderived53 : PRE_first_tail_x15_r0_body.nr53.map (fun r => nth? PRE_first_tail_x15_r0_body.st53.S2.tab r) =
  []
kernel_rfl PRE_first_tail_x15_r0_body.cnrLo53 : PRE_first_tail_x15_r0_body.nr53.all (Nat.ble 2320) = true
kernel_rfl PRE_first_tail_x15_r0_body.cwsDisj53 : PRE_first_tail_x15_r0_body.cws53.all (fun c => !PRE_first_tail_x15_r0_body.ws53.contains c) = true
/-- The compaction's substitution: the canonical variables to their merged values, the stage's other fresh variables
to `0` (`Conv.compactθZ`). -/
noncomputable def PRE_first_tail_x15_r0_body.cthetaZ53 : Nat → SymE := Conv.compactθZ PRE_first_tail_x15_r0_body.cws53 PRE_first_tail_x15_r0_body.crs53 PRE_first_tail_x15_r0_body.ws53

end Host.Load.Run.Tpl
end

section -- st53/Foot
set_option Elab.async false
namespace Host.Load.Run.Tpl
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
open Host.Ts Host.Ts.Sim Host.Ts.Sim.Stage Host.Ts.Sim.Template

/-! The footprint of stage `PRE_first_tail_x15_r0_body.st53`'s site template (`Conv.StageFoot`, `Conv.NFoot`): every entry of the return
state other than the written and fresh ones is the start's (kernel evaluation of the equalities). -/

/-- The written heap ranges below the start's counter. -/
def PRE_first_tail_x15_r0_body.st53.wrR : List (Nat × Nat) := []
/-- The written and fresh entries of the return state. -/
noncomputable def PRE_first_tail_x15_r0_body.st53.wrE : List (Nat × Host.Ts.HObj) :=
  rangesOf PRE_first_tail_x15_r0_body.st53.s2.heap PRE_first_tail_x15_r0_body.st53.wrR ++ freshOf PRE_first_tail_x15_r0_body.st53.s2.heap PRE_first_tail_x15_r0_body.st53.s0.next PRE_first_tail_x15_r0_body.st53.s2.next
noncomputable def PRE_first_tail_x15_r0_body.st53.wr : List Nat := PRE_first_tail_x15_r0_body.st53.wrE.map (·.1)

kernel_rfl PRE_first_tail_x15_r0_body.st53.heapFoot : PRE_first_tail_x15_r0_body.st53.s2.heap = setAll PRE_first_tail_x15_r0_body.st53.s0.heap PRE_first_tail_x15_r0_body.st53.wrE
kernel_rfl PRE_first_tail_x15_r0_body.st53.grows_check : Nat.ble PRE_first_tail_x15_r0_body.st53.s0.next PRE_first_tail_x15_r0_body.st53.s2.next = true
theorem PRE_first_tail_x15_r0_body.st53.grows : PRE_first_tail_x15_r0_body.st53.s0.next ≤ PRE_first_tail_x15_r0_body.st53.s2.next := Nat.le_of_ble_eq_true PRE_first_tail_x15_r0_body.st53.grows_check

/-- The written and fresh handles; the written readback items of old nodes. -/
def PRE_first_tail_x15_r0_body.st53.wh : List Nat := []
def PRE_first_tail_x15_r0_body.st53.wi : List Nat := []

kernel_rfl PRE_first_tail_x15_r0_body.st53.arrsFoot : (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.st53.s2.ffi).mlx.arrs = setAll (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.st53.s0.ffi).mlx.arrs (PRE_first_tail_x15_r0_body.st53.wh.filterMap fun h => ((Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.st53.s2.ffi).mlx.arrs.get h).map (h, ·))
kernel_rfl PRE_first_tail_x15_r0_body.st53.objsFoot : (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.st53.s2.ffi).mlx.objs = setAll (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.st53.s0.ffi).mlx.objs (PRE_first_tail_x15_r0_body.st53.wh.filterMap fun h => ((Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.st53.s2.ffi).mlx.objs.get h).map (h, ·))
kernel_rfl PRE_first_tail_x15_r0_body.st53.nodesFoot : (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.st53.s2.ffi).mlx.nodes = setAll (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.st53.s0.ffi).mlx.nodes (freshOf (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.st53.s2.ffi).mlx.nodes (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.st53.s0.ffi).mlx.nnext (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.st53.s2.ffi).mlx.nnext)
kernel_rfl PRE_first_tail_x15_r0_body.st53.itemsFoot : (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.st53.s2.ffi).mlx.items = setAll (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.st53.s0.ffi).mlx.items ((PRE_first_tail_x15_r0_body.st53.wi.filterMap fun i => ((Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.st53.s2.ffi).mlx.items.get i).map (i, ·)) ++
    freshOf (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.st53.s2.ffi).mlx.items (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.st53.s0.ffi).mlx.nnext (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.st53.s2.ffi).mlx.nnext)
kernel_rfl PRE_first_tail_x15_r0_body.st53.counters : (Nat.ble (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.st53.s0.ffi).mlx.next (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.st53.s2.ffi).mlx.next && Nat.ble (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.st53.s0.ffi).mlx.nnext (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.st53.s2.ffi).mlx.nnext) = true

end Host.Load.Run.Tpl
end

section -- SiteF53
set_option Elab.async false
namespace Host.Load.Run.Tpl
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
open Host.Ts Host.Ts.Sim Host.Ts.Sim.Template

/-! Call site 53 of chain `PRE_first_tail_x15_r0_body`: `Conv.site_merge`'s footprint facts. -/

kernel_rfl PRE_first_tail_x15_r0_body.wrNodupB53 : nodupT PRE_first_tail_x15_r0_body.st53.wr PTrie.nil = true
theorem PRE_first_tail_x15_r0_body.wrNodup53 : PRE_first_tail_x15_r0_body.st53.wr.Nodup := (nodupT_sound PRE_first_tail_x15_r0_body.wrNodupB53).2
kernel_rfl PRE_first_tail_x15_r0_body.wrBoundB53 : PRE_first_tail_x15_r0_body.st53.wr.all (fun b => Nat.blt (b / 4096) (4 ^ 31)) = true
theorem PRE_first_tail_x15_r0_body.wrBound53 : ∀ b ∈ PRE_first_tail_x15_r0_body.st53.wr, b / 4096 < 4 ^ 31 := fun b hb => Nat.blt_eq.mp (List.all_eq_true.mp PRE_first_tail_x15_r0_body.wrBoundB53 b hb)
noncomputable def PRE_first_tail_x15_r0_body.trFr53 := PRE_first_tail_x15_r0_body.st53.s2.trace.take 0
kernel_rfl PRE_first_tail_x15_r0_body.traceEq53 : PRE_first_tail_x15_r0_body.st53.s2.trace = PRE_first_tail_x15_r0_body.trFr53 ++ PRE_first_tail_x15_r0_body.st53.s0.trace
theorem PRE_first_tail_x15_r0_body.trace53 : ∃ fr, PRE_first_tail_x15_r0_body.st53.s2.trace = fr ++ PRE_first_tail_x15_r0_body.st53.s0.trace := ⟨_, PRE_first_tail_x15_r0_body.traceEq53⟩

-- the caller's wide frames at the instance's start (`Conv.isolateW`'s `W0` under `Map.id`) and their `WFix`
def PRE_first_tail_x15_r0_body.wide53 : List (Nat × WFrame) := [(4910, .memo [])]
kernel_rfl PRE_first_tail_x15_r0_body.wfixB53 : (PRE_first_tail_x15_r0_body.wide53.all fun p => wfixB Map.id (presentB PRE_first_tail_x15_r0_body.st53.s0) p.2) = true
theorem PRE_first_tail_x15_r0_body.wfix53 : ∀ p ∈ PRE_first_tail_x15_r0_body.wide53, WFix Map.id (Present PRE_first_tail_x15_r0_body.st53.s0) p.2 :=
  fun p hp => wfix_of (List.all_eq_true.mp PRE_first_tail_x15_r0_body.wfixB53 p hp)

end Host.Load.Run.Tpl
end

section -- SiteL53
set_option Elab.async false
namespace Host.Load.Run.Tpl
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
open Host.Ts Host.Ts.Sim Host.Ts.Sim.Template

/-! The call link's facts at call site 53 of chain `PRE_first_tail_x15_r0_body`: the instance's start server, its footprint (`Conv.StageFoot`), the
merged state `PRE_first_tail_x15_r0_body.s518`'s framed arrays as the chain start's extended (`arrExt_of`, `numRefs_of`). -/

kernel_rfl PRE_first_tail_x15_r0_body.srvO53 : PRE_first_tail_x15_r0_body.st53.S0.oracle = PRE_first_tail_x15_r0_body.st53.OR
kernel_rfl PRE_first_tail_x15_r0_body.wr0B53 : PRE_first_tail_x15_r0_body.st53.wr.all (fun b => !Nat.blt b PRE_first_tail_x15_r0_body.st53.s0.next || (PRE_first_tail_x15_r0_body.st53.s0.heap.get b).isSome) = true
theorem PRE_first_tail_x15_r0_body.stFoot53 : Conv.StageFoot PRE_first_tail_x15_r0_body.st53.wr PRE_first_tail_x15_r0_body.st53.s0 PRE_first_tail_x15_r0_body.st53.s2 :=
  stageFoot_of PRE_first_tail_x15_r0_body.st53.heapFoot PRE_first_tail_x15_r0_body.wrNodup53 PRE_first_tail_x15_r0_body.wrBound53 PRE_first_tail_x15_r0_body.wr0B53 PRE_first_tail_x15_r0_body.st53.grows

/-- **The relation at the merged state** from the relation at the merge (`Conv.site_merge`'s; `merged_relB`). -/
theorem PRE_first_tail_x15_r0_body.merged53 {FR : Map → Nat → PRE_first_tail_x15_r0_body.st53.F.S → PRE_first_tail_x15_r0_body.st53.F.S → Prop} {W : Nat → Option WFrame} {stk : List Frame} {M : Map}
    {ν : Nat → F64} {K : Host.Ts.Sim.Ctx} {S : SSrv} {t : St PRE_first_tail_x15_r0_body.st53.F.S} {C : CSrv} {n0 : Nat}
    (h : RelB PRE_first_tail_x15_r0_body.st53.F FR W stk M ν K (Conv.mergeSt Map.id (Map.id.res n0 n0) PRE_first_tail_x15_r0_body.rs53 PRE_first_tail_x15_r0_body.st53.wr PRE_first_tail_x15_r0_body.s517 PRE_first_tail_x15_r0_body.st53.s2 PRE_first_tail_x15_r0_body.st53.s0
      PRE_first_tail_x15_r0_body.st53.s2.ffi) S t C) : RelB PRE_first_tail_x15_r0_body.st53.F FR W stk M ν K PRE_first_tail_x15_r0_body.s518 S t C :=
  merged_relB PRE_first_tail_x15_r0_body.iso53 PRE_first_tail_x15_r0_body.stFoot53 PRE_first_tail_x15_r0_body.wrNodup53 PRE_first_tail_x15_r0_body.wrBound53 PRE_first_tail_x15_r0_body.trace53 PRE_first_tail_x15_r0_body.mheap53
    PRE_first_tail_x15_r0_body.mnext53 PRE_first_tail_x15_r0_body.mctl53 PRE_first_tail_x15_r0_body.mstack53 PRE_first_tail_x15_r0_body.mjobs53 PRE_first_tail_x15_r0_body.mffi53 PRE_first_tail_x15_r0_body.mtrace53 PRE_first_tail_x15_r0_body.mstores53 h

def PRE_first_tail_x15_r0_body.arrEl53_2665 : List Val := []
kernel_rfl PRE_first_tail_x15_r0_body.arrE53_2665 : arrOf PRE_first_tail_x15_r0_body.s518 2665 = arrOf PRE_first_tail_x15_r0_body.s0 2665 ++ PRE_first_tail_x15_r0_body.arrEl53_2665
kernel_rfl PRE_first_tail_x15_r0_body.arrA53_2665 : isArrB PRE_first_tail_x15_r0_body.s518 2665 = true
theorem PRE_first_tail_x15_r0_body.arr53_2665 : ∃ o, PRE_first_tail_x15_r0_body.s518.heap.get 2665 = some (.obj o) ∧ o.kind = .array (arrOf PRE_first_tail_x15_r0_body.s0 2665 ++ PRE_first_tail_x15_r0_body.arrEl53_2665) :=
  arrExt_of PRE_first_tail_x15_r0_body.arrE53_2665 PRE_first_tail_x15_r0_body.arrA53_2665
kernel_rfl PRE_first_tail_x15_r0_body.arrN53_2665 : numRefsB PRE_first_tail_x15_r0_body.S0.tab.length PRE_first_tail_x15_r0_body.arrEl53_2665 = true
theorem PRE_first_tail_x15_r0_body.arrR53_2665 : Prefill.NumRefs PRE_first_tail_x15_r0_body.S0.tab.length PRE_first_tail_x15_r0_body.arrEl53_2665 := numRefs_of PRE_first_tail_x15_r0_body.arrN53_2665

def PRE_first_tail_x15_r0_body.arrEl53_2673467 : List Val := []
kernel_rfl PRE_first_tail_x15_r0_body.arrE53_2673467 : arrOf PRE_first_tail_x15_r0_body.s518 2673467 = arrOf PRE_first_tail_x15_r0_body.s0 2673467 ++ PRE_first_tail_x15_r0_body.arrEl53_2673467
kernel_rfl PRE_first_tail_x15_r0_body.arrA53_2673467 : isArrB PRE_first_tail_x15_r0_body.s518 2673467 = true
theorem PRE_first_tail_x15_r0_body.arr53_2673467 : ∃ o, PRE_first_tail_x15_r0_body.s518.heap.get 2673467 = some (.obj o) ∧ o.kind = .array (arrOf PRE_first_tail_x15_r0_body.s0 2673467 ++ PRE_first_tail_x15_r0_body.arrEl53_2673467) :=
  arrExt_of PRE_first_tail_x15_r0_body.arrE53_2673467 PRE_first_tail_x15_r0_body.arrA53_2673467
kernel_rfl PRE_first_tail_x15_r0_body.arrN53_2673467 : numRefsB PRE_first_tail_x15_r0_body.S0.tab.length PRE_first_tail_x15_r0_body.arrEl53_2673467 = true
theorem PRE_first_tail_x15_r0_body.arrR53_2673467 : Prefill.NumRefs PRE_first_tail_x15_r0_body.S0.tab.length PRE_first_tail_x15_r0_body.arrEl53_2673467 := numRefs_of PRE_first_tail_x15_r0_body.arrN53_2673467

kernel_rfl PRE_first_tail_x15_r0_body.w4910k53 : isArrB PRE_first_tail_x15_r0_body.s518 4910 = false
theorem PRE_first_tail_x15_r0_body.keep53 (q : List Val) : Host.Ts.Sim.Prefill.KeepsAtW (framesP PRE_first_tail_x15_r0_body.s0 q) PRE_first_tail_x15_r0_body.s518 := by
  intro a pre pre' hx o es ho hk
  unfold framesP at hx
  simp only at hx
  cases h1 : Nat.beq a 2665
  · cases h2 : Nat.beq a 4910
    · rw [h1, h2] at hx; cases hx
    · have := Nat.eq_of_beq_eq_true h2; subst this
      rw [h1, h2] at hx; cases hx
      exact (notArr_of PRE_first_tail_x15_r0_body.w4910k53 ho hk).elim
  · have := Nat.eq_of_beq_eq_true h1; subst this
    rw [h1] at hx; cases hx
    obtain ⟨o', ho', hk'⟩ := PRE_first_tail_x15_r0_body.arr53_2665
    rw [ho] at ho'; cases ho'
    rw [hk'] at hk; cases hk
    simp [PRE_first_tail_x15_r0_body.arrEl53_2665]

end Host.Load.Run.Tpl
end

section -- SiteZ53
set_option Elab.async false
namespace Host.Load.Run.Tpl
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
open Host.Ts Host.Ts.Sim Host.Ts.Sim.Template

/-! The compaction's state shift at call site 53 of chain `PRE_first_tail_x15_r0_body` (`Conv.compact_shift`): the call `PRE_first_tail_x15_r0_body.s517`, the merged
state `PRE_first_tail_x15_r0_body.s518`, the canonical state `PRE_first_tail_x15_r0_body.s519`; its frames [2665,2673467,2673472,2673473] (kept arrays [2665,2673467]). -/

-- the map's places and counters
kernel_rfl PRE_first_tail_x15_r0_body.zpl53 : PRE_first_tail_x15_r0_body.pl53.all (Nat.ble PRE_first_tail_x15_r0_body.s517.next) = true
kernel_rfl PRE_first_tail_x15_r0_body.zplnd53 : nodupT PRE_first_tail_x15_r0_body.pl53 PTrie.nil = true
kernel_rfl PRE_first_tail_x15_r0_body.zn153 : Nat.ble PRE_first_tail_x15_r0_body.s517.next 2716187 = true
kernel_rfl PRE_first_tail_x15_r0_body.zfirst53 : Nat.ble aFirst PRE_first_tail_x15_r0_body.s517.next = true
kernel_rfl PRE_first_tail_x15_r0_body.zscn53 : PRE_first_tail_x15_r0_body.s519.next = PRE_first_tail_x15_r0_body.s517.next + PRE_first_tail_x15_r0_body.pl53.length
kernel_rfl PRE_first_tail_x15_r0_body.zsmn53 : PRE_first_tail_x15_r0_body.s518.next = 2716187
kernel_rfl PRE_first_tail_x15_r0_body.zgrow53 : Nat.ble PRE_first_tail_x15_r0_body.s519.next PRE_first_tail_x15_r0_body.s518.next = true
-- the tables
kernel_rfl PRE_first_tail_x15_r0_body.zfresh53 : PRE_first_tail_x15_r0_body.S517.tab.all (fun e => PRE_first_tail_x15_r0_body.cws53.all fun v => e.noVar v) = true
kernel_rfl PRE_first_tail_x15_r0_body.zcnd53 : nodupT PRE_first_tail_x15_r0_body.cws53 PTrie.nil = true
kernel_rfl PRE_first_tail_x15_r0_body.znrHi53 : PRE_first_tail_x15_r0_body.nr53.all (fun r => Nat.blt r PRE_first_tail_x15_r0_body.S518.tab.length) = true
-- the frames: every framed address below the call's counter; the kept arrays the chain start's, extended in the merged state
kernel_rfl PRE_first_tail_x15_r0_body.zfrlt53 : [2665, 2673467, 2673472, 2673473].all (fun a => Nat.blt a PRE_first_tail_x15_r0_body.s517.next) = true
kernel_rfl PRE_first_tail_x15_r0_body.zg53_2665 : PRE_first_tail_x15_r0_body.s519.heap.get 2665 = some (.obj (objOf PRE_first_tail_x15_r0_body.s519 2665))
kernel_rfl PRE_first_tail_x15_r0_body.zk53_2665 : (objOf PRE_first_tail_x15_r0_body.s519 2665).kind = .array (arrOf PRE_first_tail_x15_r0_body.s0 2665)
kernel_rfl PRE_first_tail_x15_r0_body.zm53_2665 : PRE_first_tail_x15_r0_body.s518.heap.get 2665 = some (.obj { PRE_first_tail_x15_r0_body.kappa53.obj (objOf PRE_first_tail_x15_r0_body.s519 2665) with
  kind := .array (arrOf PRE_first_tail_x15_r0_body.s0 2665 ++ (arrOf PRE_first_tail_x15_r0_body.s518 2665).drop (arrOf PRE_first_tail_x15_r0_body.s0 2665).length) })
kernel_rfl PRE_first_tail_x15_r0_body.zg53_2673467 : PRE_first_tail_x15_r0_body.s519.heap.get 2673467 = some (.obj (objOf PRE_first_tail_x15_r0_body.s519 2673467))
kernel_rfl PRE_first_tail_x15_r0_body.zk53_2673467 : (objOf PRE_first_tail_x15_r0_body.s519 2673467).kind = .array (arrOf PRE_first_tail_x15_r0_body.s0 2673467)
kernel_rfl PRE_first_tail_x15_r0_body.zm53_2673467 : PRE_first_tail_x15_r0_body.s518.heap.get 2673467 = some (.obj { PRE_first_tail_x15_r0_body.kappa53.obj (objOf PRE_first_tail_x15_r0_body.s519 2673467) with
  kind := .array (arrOf PRE_first_tail_x15_r0_body.s0 2673467 ++ (arrOf PRE_first_tail_x15_r0_body.s518 2673467).drop (arrOf PRE_first_tail_x15_r0_body.s0 2673467).length) })
kernel_rfl PRE_first_tail_x15_r0_body.zw53_4910 : (PRE_first_tail_x15_r0_body.s519.heap.get 4910).isSome = true
kernel_rfl PRE_first_tail_x15_r0_body.zw53_2673472 : (PRE_first_tail_x15_r0_body.s519.heap.get 2673472).isSome = true
kernel_rfl PRE_first_tail_x15_r0_body.zw53_2673473 : (PRE_first_tail_x15_r0_body.s519.heap.get 2673473).isSome = true
-- the heap: the changed list in range, holding the stage's written and fresh addresses; the canonical side's image
kernel_rfl PRE_first_tail_x15_r0_body.zclbd53 : PRE_first_tail_x15_r0_body.cl53.all (fun b => Nat.blt (b / 4096) (4 ^ 31)) = true
kernel_rfl PRE_first_tail_x15_r0_body.zwr53 : PRE_first_tail_x15_r0_body.st53.wr.all (fun b => !Nat.blt b PRE_first_tail_x15_r0_body.s517.next || PRE_first_tail_x15_r0_body.cl53.contains b) = true
def PRE_first_tail_x15_r0_body.zl53 : List Nat := PRE_first_tail_x15_r0_body.cl53.filter fun a => !(List.contains [2665, 2673467] a)
kernel_rfl PRE_first_tail_x15_r0_body.zimgE53 : PRE_first_tail_x15_r0_body.zl53.map (fun a => PRE_first_tail_x15_r0_body.s518.heap.get (PRE_first_tail_x15_r0_body.kappa53.a a)) = PRE_first_tail_x15_r0_body.zl53.map (fun a => (PRE_first_tail_x15_r0_body.s519.heap.get a).map PRE_first_tail_x15_r0_body.kappa53.hobj)
theorem PRE_first_tail_x15_r0_body.zimg53 : HeapImg PRE_first_tail_x15_r0_body.kappa53 PRE_first_tail_x15_r0_body.s519 PRE_first_tail_x15_r0_body.s518 PRE_first_tail_x15_r0_body.zl53 := PRE_first_tail_x15_r0_body.zimgE53
-- the roots and their supports
kernel_rfl PRE_first_tail_x15_r0_body.zctl53 : PRE_first_tail_x15_r0_body.s518.ctl = PRE_first_tail_x15_r0_body.kappa53.ctl PRE_first_tail_x15_r0_body.s519.ctl
kernel_rfl PRE_first_tail_x15_r0_body.zstack53 : PRE_first_tail_x15_r0_body.s518.stack = PRE_first_tail_x15_r0_body.s519.stack.map PRE_first_tail_x15_r0_body.kappa53.frame
kernel_rfl PRE_first_tail_x15_r0_body.zjobs53 : PRE_first_tail_x15_r0_body.s518.jobs = PRE_first_tail_x15_r0_body.s519.jobs.map PRE_first_tail_x15_r0_body.kappa53.job
kernel_rfl PRE_first_tail_x15_r0_body.zstores53 : PRE_first_tail_x15_r0_body.s518.stores = PRE_first_tail_x15_r0_body.kappa53.stores PRE_first_tail_x15_r0_body.s519.stores
kernel_rfl PRE_first_tail_x15_r0_body.zroots53 : checkRootsSupp PRE_first_tail_x15_r0_body.s519 2320 = true
kernel_rfl PRE_first_tail_x15_r0_body.znC53 : PRE_first_tail_x15_r0_body.S517.tab.length + PRE_first_tail_x15_r0_body.cws53.length = 2320
-- the map as `Conv.compact_shift` states it (the call's counters for the literals)
kernel_rfl PRE_first_tail_x15_r0_body.zkap53 : PRE_first_tail_x15_r0_body.kappa53 = Conv.Map.compact PRE_first_tail_x15_r0_body.s517.next 2716187 PRE_first_tail_x15_r0_body.S517.tab.length PRE_first_tail_x15_r0_body.pl53 (PRE_first_tail_x15_r0_body.nr53.map NumV.ref) PRE_first_tail_x15_r0_body.kd53.big
  PRE_first_tail_x15_r0_body.kd53.region PRE_first_tail_x15_r0_body.kd53.nodeF
-- the bridge inactive at the canonical state (`Conv.FullShiftQ.toX`; the merged state's bridge is the canonical's: cbridge)
theorem PRE_first_tail_x15_r0_body.zbin53 : (Host.Ts.Sim.Full.bridgeOf PRE_first_tail_x15_r0_body.s519.ffi).active = false := (Host.Load.Boot.replay_active Host.Load.Run.Prompt.P.oblog2818)
-- the JS bookkeeping's step (`Conv.JClean.step` over the changed list) and the canonical roots' bigint freedom
kernel_rfl PRE_first_tail_x15_r0_body.zjc53 : Conv.jcleanListB (⟨19240, 16333, 2716168, 2320⟩ : Conv.Cnt) PRE_first_tail_x15_r0_body.s519 PRE_first_tail_x15_r0_body.cl53 = true
kernel_rfl PRE_first_tail_x15_r0_body.zrootsB53 : noBigRootsP (fun i => !Conv.oldBigB (⟨19240, 16333, 2716168, 2320⟩ : Conv.Cnt) i) PRE_first_tail_x15_r0_body.s519.trace PRE_first_tail_x15_r0_body.s519 = true
kernel_rfl PRE_first_tail_x15_r0_body.zhm53 : Nat.ble (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s0.ffi).mlx.nnext 16333 = true
theorem PRE_first_tail_x15_r0_body.cjcl53 (h : Conv.JClean (⟨19240, 16333, 2716167, 2320⟩ : Conv.Cnt) PRE_first_tail_x15_r0_body.s517) : Conv.JClean (⟨19240, 16333, 2716168, 2320⟩ : Conv.Cnt) PRE_first_tail_x15_r0_body.s519 :=
  Conv.JClean.step h (Conv.Cnt.le_of_leB PRE_first_tail_x15_r0_body.cle53)
    (Conv.heap_off_setAll PRE_first_tail_x15_r0_body.cheap53 fun a ha => Nat.blt_eq.mp (List.all_eq_true.mp PRE_first_tail_x15_r0_body.zclbd53 a ha)) PRE_first_tail_x15_r0_body.zjc53

end Host.Load.Run.Tpl
end

section -- st53/TypedLast
set_option Elab.async false
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
namespace Host.Load.Run.Tpl
open Host.Ts Host.Ts.Sim Host.Ts.Sim.Template

boot_rfl PRE_first_tail_x15_r0_body.st53.bodyLast from PRE_first_tail_x15_r0_body.st53.s1 to PRE_first_tail_x15_r0_body.st53.s2 :
  interpS (step PRE_first_tail_x15_r0_body.st53.F PRE_first_tail_x15_r0_body.st53.s1).run PRE_first_tail_x15_r0_body.st53.S1 = some (PRE_first_tail_x15_r0_body.st53.s2, PRE_first_tail_x15_r0_body.st53.S2)
kernel_rfl PRE_first_tail_x15_r0_body.st53.bodyHalt : isHalt PRE_first_tail_x15_r0_body.st53.s1.ctl = false
kernel_rfl PRE_first_tail_x15_r0_body.st53.bodyTopCheck : noBlockTop PRE_first_tail_x15_r0_body.st53.s2.stack = true

end Host.Load.Run.Tpl
end

section -- st53/TypedOk
set_option Elab.async false
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
namespace Host.Load.Run.Tpl
open Host.Ts Host.Ts.Sim Host.Ts.Sim.Template

noncomputable def PRE_first_tail_x15_r0_body.st53.bodyOkL (bytes : List Byte) (rows : Nat) : St PRE_first_tail_x15_r0_body.st53.F.S → SSrv → Bool :=
  okLocal (Host.Ts.Sim.Compose.VWFrames.bodyOk bytes rows)

noncomputable def PRE_first_tail_x15_r0_body.st53.bodyOkLN (bytes : List Byte) (rows : Nat) : St PRE_first_tail_x15_r0_body.st53.F.S → FSrv → Bool :=
  okLocalN (Host.Ts.Sim.Compose.VWFrames.bodyOkN bytes rows)

theorem PRE_first_tail_x15_r0_body.st53.bodyOkLN_ok (bytes : List Byte) (rows : Nat) (s : St PRE_first_tail_x15_r0_body.st53.F.S) (c : FSrv) (h : c.Wf) :
    PRE_first_tail_x15_r0_body.st53.bodyOkLN bytes rows s c = PRE_first_tail_x15_r0_body.st53.bodyOkL bytes rows s c.toS :=
  okLocalN_ok (Host.Ts.Sim.Compose.VWFrames.bodyOkN_ok bytes rows) s c h

kernel_rfl PRE_first_tail_x15_r0_body.st53.bodyAccepted0 :
  (fun (bytes : List Byte) (rows : Nat) => PRE_first_tail_x15_r0_body.st53.bodyOkL bytes rows PRE_first_tail_x15_r0_body.st53.s0 PRE_first_tail_x15_r0_body.st53.S0) = fun _ _ => true

kernel_rfl PRE_first_tail_x15_r0_body.st53.bodyAccepted1 :
  (fun (bytes : List Byte) (rows : Nat) => PRE_first_tail_x15_r0_body.st53.bodyOkL bytes rows PRE_first_tail_x15_r0_body.st53.s1 PRE_first_tail_x15_r0_body.st53.S1) = fun _ _ => true

end Host.Load.Run.Tpl
end

section -- st53/TypedK0
set_option Elab.async false
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
namespace Host.Load.Run.Tpl
open Host.Ts Host.Ts.Sim Host.Ts.Sim.Template

boot_rfl PRE_first_tail_x15_r0_body.st53.bodyK0F from PRE_first_tail_x15_r0_body.st53.s0 to PRE_first_tail_x15_r0_body.st53.s1 :
  (fun (bytes : List Byte) (rows : Nat) => runOkS PRE_first_tail_x15_r0_body.st53.F (PRE_first_tail_x15_r0_body.st53.bodyOkLN bytes rows)
    ((nth? PRE_first_tail_x15_r0_body.st53.ks 0).getD 0) PRE_first_tail_x15_r0_body.st53.s0 PRE_first_tail_x15_r0_body.st53.S0) = fun _ _ => some (PRE_first_tail_x15_r0_body.st53.s1, PRE_first_tail_x15_r0_body.st53.S1)
theorem PRE_first_tail_x15_r0_body.st53.bodyK0 :
  (fun (bytes : List Byte) (rows : Nat) => runOk PRE_first_tail_x15_r0_body.st53.F (PRE_first_tail_x15_r0_body.st53.bodyOkL bytes rows)
    ((nth? PRE_first_tail_x15_r0_body.st53.ks 0).getD 0) PRE_first_tail_x15_r0_body.st53.s0 PRE_first_tail_x15_r0_body.st53.S0) = fun _ _ => some (PRE_first_tail_x15_r0_body.st53.s1, PRE_first_tail_x15_r0_body.st53.S1) :=
  runOk_fun_of_runOkS PRE_first_tail_x15_r0_body.st53.bodyOkLN_ok PRE_first_tail_x15_r0_body.st53.bodyK0F
end Host.Load.Run.Tpl
end

section -- st53/TypedTpl
set_option Elab.async false
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
namespace Host.Load.Run.Tpl
open Host.Ts Host.Ts.Sim Host.Ts.Sim.Template

theorem PRE_first_tail_x15_r0_body.st53.bodyRun (bytes : List Byte) (rows : Nat) :
    runOk PRE_first_tail_x15_r0_body.st53.F (PRE_first_tail_x15_r0_body.st53.bodyOkL bytes rows) 206 PRE_first_tail_x15_r0_body.st53.s0 PRE_first_tail_x15_r0_body.st53.S0 = some (PRE_first_tail_x15_r0_body.st53.s1, PRE_first_tail_x15_r0_body.st53.S1) :=
  (congrFun (congrFun PRE_first_tail_x15_r0_body.st53.bodyK0 bytes) rows)

theorem PRE_first_tail_x15_r0_body.st53.bodyLocal (bytes : List Byte) (rows : Nat) : ∀ s S, PRE_first_tail_x15_r0_body.st53.bodyOkL bytes rows s S = true → Disp.localB s = true := okLocal_localB

noncomputable def PRE_first_tail_x15_r0_body.st53.bodyTpl (bytes : List Byte) (rows : Nat) : Host.Ts.Sim.Stage.StageTpl PRE_first_tail_x15_r0_body.st53.F (PRE_first_tail_x15_r0_body.st53.bodyOkL bytes rows) where
  s0 := PRE_first_tail_x15_r0_body.st53.s0
  S0 := PRE_first_tail_x15_r0_body.st53.S0
  s1 := PRE_first_tail_x15_r0_body.st53.s1
  S1 := PRE_first_tail_x15_r0_body.st53.S1
  s2 := PRE_first_tail_x15_r0_body.st53.s2
  S2 := PRE_first_tail_x15_r0_body.st53.S2
  n := 206
  ok0 := congrFun (congrFun PRE_first_tail_x15_r0_body.st53.bodyAccepted0 bytes) rows
  run := PRE_first_tail_x15_r0_body.st53.bodyRun bytes rows
  ok1 := congrFun (congrFun PRE_first_tail_x15_r0_body.st53.bodyAccepted1 bytes) rows
  halt := PRE_first_tail_x15_r0_body.st53.bodyHalt
  last := PRE_first_tail_x15_r0_body.st53.bodyLast
  top := noBlockTop_sound PRE_first_tail_x15_r0_body.st53.bodyTopCheck
end Host.Load.Run.Tpl
end

section -- SiteC54
set_option Elab.async false
namespace Host.Load.Run.Tpl
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
open Host.Ts Host.Ts.Sim Host.Ts.Sim.Template

/-! The compaction after the merge at call site 54 of chain `PRE_first_tail_x15_r0_body` (`Conv.compact`, `Conv.full_compactQ`): the canonical
state `PRE_first_tail_x15_r0_body.s536` (the stage's results at canonical places, its trace the call's) under `PRE_first_tail_x15_r0_body.kappa54` into the merged state
`PRE_first_tail_x15_r0_body.s535`. -/

def PRE_first_tail_x15_r0_body.pl54 : List Nat := [2718755, 2717930, 2718761, 2718757, 2717932, 2718763]
def PRE_first_tail_x15_r0_body.nr54 : List Nat := [2423, 2422, 2398, 2406, 2411, 2416, 2421, 2395, 2396, 2397, 2404, 2405, 2393, 2400, 2401, 2402, 2403, 2399]
/-- The native part of the compaction map (canonical → merged handles and nodes: its `big`, `region`, `nodeF`). -/
def PRE_first_tail_x15_r0_body.kd54 : RData :=
  ⟨2717649, 2718798, Stage.setAll PTrie.nil [(2717643, 2718755), (2717644, 2717930), (2717645, 2718761), (2717646, 2718757), (2717647, 2717932), (2717648, 2718763)], Stage.setAll PTrie.nil [(19274, 19300), (19275, 19278), (19276, 19301)],
   19277, 19302, 16379, 16379, Stage.setAll PTrie.nil [],
   Stage.setAll PTrie.nil [(2393, .ref 2423), (2394, .ref 2422), (2395, .ref 2398), (2396, .ref 2406), (2397, .ref 2411), (2398, .ref 2416), (2399, .ref 2421), (2400, .ref 2395), (2401, .ref 2396), (2402, .ref 2397), (2403, .ref 2404), (2404, .ref 2405), (2405, .ref 2393), (2406, .ref 2400), (2407, .ref 2401), (2408, .ref 2402), (2409, .ref 2403), (2410, .ref 2399)]⟩
/-- **The compaction map.** -/
noncomputable def PRE_first_tail_x15_r0_body.kappa54 : Map :=
  Conv.Map.compact 2717643 2718798 2393 PRE_first_tail_x15_r0_body.pl54 (PRE_first_tail_x15_r0_body.nr54.map NumV.ref) PRE_first_tail_x15_r0_body.kd54.big
    PRE_first_tail_x15_r0_body.kd54.region PRE_first_tail_x15_r0_body.kd54.nodeF
/-- The canonical result variables and their images, the merged state's entries (`Conv.compactθ`). -/
def PRE_first_tail_x15_r0_body.cws54 : List Nat := [1947, 1948, 1949, 1950, 1951, 1952, 1953, 1954, 1955, 1956, 1957, 1958, 1959, 1960, 1961, 1962, 1963, 1964]
noncomputable def PRE_first_tail_x15_r0_body.crs54 : List SymE := PRE_first_tail_x15_r0_body.nr54.map fun r => (nth? PRE_first_tail_x15_r0_body.S535.tab r).getD (.var 0)
noncomputable def PRE_first_tail_x15_r0_body.ctheta54 : Nat → SymE := Conv.compactθ PRE_first_tail_x15_r0_body.cws54 PRE_first_tail_x15_r0_body.crs54
/-- The call's entries the stage wrote (renamed in the canonical state with the results). -/
def PRE_first_tail_x15_r0_body.wrB54 : List Nat := [2665, 2672434, 2673467, 2716817, 2717362, 2717618]

kernel_rfl PRE_first_tail_x15_r0_body.ctab54 : PRE_first_tail_x15_r0_body.S536.tab = PRE_first_tail_x15_r0_body.S534.tab ++ PRE_first_tail_x15_r0_body.cws54.map SymE.var
kernel_rfl PRE_first_tail_x15_r0_body.ctrace54 : PRE_first_tail_x15_r0_body.s536.trace = PRE_first_tail_x15_r0_body.s534.trace
kernel_rfl PRE_first_tail_x15_r0_body.cnext54 : PRE_first_tail_x15_r0_body.s536.next = 2717649
kernel_rfl PRE_first_tail_x15_r0_body.ccounters54 : ((Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s536.ffi).mlx.next, (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s536.ffi).mlx.nnext) = (19277, 16379)
-- the merged state's readback queue, carried to the canonical state (`Conv.FullShiftQ.tokens`, `tokSupp`)
kernel_rfl PRE_first_tail_x15_r0_body.cqueue54 : (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s535.ffi).mlx.tokens = (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s536.ffi).mlx.tokens.map PRE_first_tail_x15_r0_body.kappa54.nv
kernel_rfl PRE_first_tail_x15_r0_body.ctokSupp54 : (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s536.ffi).mlx.tokens.all (bSN 2411) = true
-- the written and the result entries carry no bigint of the canonical fresh band [next, E) and no fresh region
kernel_rfl PRE_first_tail_x15_r0_body.cclean54 : Conv.cleanListB 19277 131072 (fun r => Nat.ble 77108 r) PRE_first_tail_x15_r0_body.s536
    (PRE_first_tail_x15_r0_body.wrB54 ++ (List.range 6).map (2717643 + ·)) = true
kernel_rfl PRE_first_tail_x15_r0_body.cbigs54 : bigsOutB 19277 131072 (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s536.ffi).mlx = true

end Host.Load.Run.Tpl
end

section -- SiteK54
set_option Elab.async false
namespace Host.Load.Run.Tpl
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
open Host.Ts Host.Ts.Sim Host.Ts.Sim.Template

/-! The canonical state's closedness from the call's (`Conv.closed_of_callB`, `Conv.sst_of_callB`): it keeps the call's entries
off the written and the result ones (`PRE_first_tail_x15_r0_body.cl54`; natively the written and result handles, the result nodes, the written
and result items), and those are checked. -/

def PRE_first_tail_x15_r0_body.cl54 : List Nat := [2665, 2672434, 2673467, 2716817, 2717362, 2717618, 2717643, 2717644, 2717645, 2717646, 2717647, 2717648]
def PRE_first_tail_x15_r0_body.clo54 : List Nat := [19254, 19267, 19273, 19274, 19275, 19276]
def PRE_first_tail_x15_r0_body.cln54 : List Nat := [16352, 16353, 16354, 16355, 16356, 16357, 16358, 16359, 16360, 16361, 16362, 16363, 16364, 16365, 16366, 16367, 16368, 16369, 16370, 16371, 16372, 16373, 16374, 16375, 16376, 16377, 16378]
def PRE_first_tail_x15_r0_body.cli54 : List Nat := [16352, 16353, 16354, 16355, 16356, 16357, 16358, 16359, 16360, 16361, 16362, 16363, 16364, 16365, 16366, 16367, 16368, 16369, 16370, 16371, 16372, 16373, 16374, 16375, 16376, 16377, 16378]
kernel_rfl PRE_first_tail_x15_r0_body.cheap54 : PRE_first_tail_x15_r0_body.s536.heap = Stage.setAll PRE_first_tail_x15_r0_body.s534.heap (PRE_first_tail_x15_r0_body.cl54.filterMap fun a => (PRE_first_tail_x15_r0_body.s536.heap.get a).map (a, ·))
kernel_rfl PRE_first_tail_x15_r0_body.cnextLe54 : Nat.ble PRE_first_tail_x15_r0_body.s534.next PRE_first_tail_x15_r0_body.s536.next = true
kernel_rfl PRE_first_tail_x15_r0_body.ckeepP54 : Conv.keptPresentB PRE_first_tail_x15_r0_body.s534 PRE_first_tail_x15_r0_body.s536 PRE_first_tail_x15_r0_body.cl54 = true
kernel_rfl PRE_first_tail_x15_r0_body.csupp54 : Conv.suppListB PRE_first_tail_x15_r0_body.s536 2411 PRE_first_tail_x15_r0_body.cl54 = true
kernel_rfl PRE_first_tail_x15_r0_body.cbound54 : Conv.boundListB PRE_first_tail_x15_r0_body.s536 PRE_first_tail_x15_r0_body.cl54 = true
kernel_rfl PRE_first_tail_x15_r0_body.cnodesK54 : (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s536.ffi).mlx.nodes = Stage.setAll (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s534.ffi).mlx.nodes (PRE_first_tail_x15_r0_body.cln54.filterMap fun i => ((Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s536.ffi).mlx.nodes.get i).map (i, ·))
kernel_rfl PRE_first_tail_x15_r0_body.cobjsK54 : (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s536.ffi).mlx.objs = Stage.setAll (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s534.ffi).mlx.objs (PRE_first_tail_x15_r0_body.clo54.filterMap fun i => ((Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s536.ffi).mlx.objs.get i).map (i, ·))
kernel_rfl PRE_first_tail_x15_r0_body.citemsK54 : (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s536.ffi).mlx.items = Stage.setAll (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s534.ffi).mlx.items (PRE_first_tail_x15_r0_body.cli54.filterMap fun i => ((Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s536.ffi).mlx.items.get i).map (i, ·))
kernel_rfl PRE_first_tail_x15_r0_body.csst54 : Conv.sstListB 2411 (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s536.ffi).mlx PRE_first_tail_x15_r0_body.cln54 PRE_first_tail_x15_r0_body.clo54 PRE_first_tail_x15_r0_body.cli54 = true

end Host.Load.Run.Tpl
end

section -- SiteCl54
set_option Elab.async false
namespace Host.Load.Run.Tpl
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
open Host.Ts Host.Ts.Sim Host.Ts.Sim.Template

kernel_rfl PRE_first_tail_x15_r0_body.ckA54 : (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s536.ffi).mlx.arrs = Stage.setAll (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s534.ffi).mlx.arrs (PRE_first_tail_x15_r0_body.clo54.filterMap fun i => ((Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s536.ffi).mlx.arrs.get i).map (i, ·))
kernel_rfl PRE_first_tail_x15_r0_body.cbd54 : (PRE_first_tail_x15_r0_body.clo54 ++ PRE_first_tail_x15_r0_body.cln54 ++ PRE_first_tail_x15_r0_body.cli54).all (fun i => Nat.blt (i / 4096) (4 ^ 31)) = true
kernel_rfl PRE_first_tail_x15_r0_body.cle54 : Conv.Cnt.leB (⟨19274, 16352, 2717643, 2393⟩ : Conv.Cnt) (⟨19277, 16379, 2717649, 2411⟩ : Conv.Cnt) = true
kernel_rfl PRE_first_tail_x15_r0_body.cck54 : Conv.ncleanListB (⟨19277, 16379, 2717649, 2411⟩ : Conv.Cnt) (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s536.ffi).mlx PRE_first_tail_x15_r0_body.clo54 PRE_first_tail_x15_r0_body.cln54 PRE_first_tail_x15_r0_body.cli54 = true
theorem PRE_first_tail_x15_r0_body.cncl54 (h : Conv.NClean (⟨19274, 16352, 2717643, 2393⟩ : Conv.Cnt) (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s534.ffi).mlx) : Conv.NClean (⟨19277, 16379, 2717649, 2411⟩ : Conv.Cnt) (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s536.ffi).mlx :=
  Conv.NClean.stepKeep h PRE_first_tail_x15_r0_body.cle54 PRE_first_tail_x15_r0_body.ckA54 PRE_first_tail_x15_r0_body.cobjsK54 PRE_first_tail_x15_r0_body.cnodesK54 PRE_first_tail_x15_r0_body.citemsK54 PRE_first_tail_x15_r0_body.cbd54 PRE_first_tail_x15_r0_body.cck54

end Host.Load.Run.Tpl
end

section -- SiteS54
set_option Elab.async false
namespace Host.Load.Run.Tpl
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
open Host.Ts Host.Ts.Sim Host.Ts.Sim.Template

/-! The compaction's native shift at call site 54 from its footprint (`Conv.nshift_of_foot`), and the observers'
(`liveShift_foot`, `kernShift_foot`): `Conv.FullShiftQ` for `Conv.full_compactQ`, given the call's bookkeeping and its
relation's facts. -/

/-- The load parameters of the chain (band-free: its start's node counter as `NL` and `N0`). -/
def PRE_first_tail_x15_r0_body.Pc54 : LoadP := ⟨18151, 131072, 1099511627776, 15235, 15235, []⟩
/-- The site's band raised to the map's checked fixed-node prefix, including newly recorded closure traces. -/
def PRE_first_tail_x15_r0_body.P54 : LoadP := PRE_first_tail_x15_r0_body.Pc54.raise 16379
kernel_rfl PRE_first_tail_x15_r0_body.craise54 : Nat.ble PRE_first_tail_x15_r0_body.Pc54.N0 16379 = true
theorem PRE_first_tail_x15_r0_body.raised54 : Host.Ts.Sim.Full.Raised PRE_first_tail_x15_r0_body.Pc54 PRE_first_tail_x15_r0_body.P54 :=
  .inr ⟨16379, rfl, Nat.le_of_ble_eq_true PRE_first_tail_x15_r0_body.craise54, rfl⟩
noncomputable abbrev PRE_first_tail_x15_r0_body.cx0_54 : Host.Load.LSt := clearTokens (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s536.ffi)
noncomputable abbrev PRE_first_tail_x15_r0_body.cx1_54 : Host.Load.LSt := clearTokens (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s535.ffi)
def PRE_first_tail_x15_r0_body.khinv54 : PTrie Nat := Stage.setAll PTrie.nil [(19300, 19274), (19278, 19275), (19301, 19276)]
def PRE_first_tail_x15_r0_body.kninv54 : PTrie Nat := Stage.setAll PTrie.nil [(16352, 16352), (16353, 16353), (16354, 16354), (16355, 16355), (16356, 16356), (16357, 16357), (16358, 16358), (16359, 16359), (16360, 16360), (16361, 16361), (16362, 16362), (16363, 16363), (16364, 16364), (16365, 16365), (16366, 16366), (16367, 16367), (16368, 16368), (16369, 16369), (16370, 16370), (16371, 16371), (16372, 16372), (16373, 16373), (16374, 16374), (16375, 16375), (16376, 16376), (16377, 16377), (16378, 16378)]
/-- The stage's footprint: its written and fresh handles, fresh nodes, written and fresh items. -/
def PRE_first_tail_x15_r0_body.cwS54 : List Nat := [19254, 19267, 19273, 19274, 19275, 19276, 19277, 19278, 19279, 19280, 19281, 19282, 19283, 19284, 19285, 19286, 19287, 19288, 19289, 19290, 19291, 19292, 19293, 19294, 19295, 19296, 19297, 19298, 19299, 19300, 19301]
def PRE_first_tail_x15_r0_body.cnS54 : List Nat := List.range' 16352 27
def PRE_first_tail_x15_r0_body.ciS54 : List Nat := [] ++ List.range' 16352 27

-- the small checks (`MChecks`'s)
kernel_rfl PRE_first_tail_x15_r0_body.cnh054 : PRE_first_tail_x15_r0_body.kd54.nh0 = PRE_first_tail_x15_r0_body.cx0_54.mlx.next
kernel_rfl PRE_first_tail_x15_r0_body.cnh154 : PRE_first_tail_x15_r0_body.kd54.nh1 = PRE_first_tail_x15_r0_body.cx1_54.mlx.next
kernel_rfl PRE_first_tail_x15_r0_body.cnn054 : PRE_first_tail_x15_r0_body.kd54.nn0 = PRE_first_tail_x15_r0_body.cx0_54.mlx.nnext
kernel_rfl PRE_first_tail_x15_r0_body.cnn154 : PRE_first_tail_x15_r0_body.kd54.nn1 = PRE_first_tail_x15_r0_body.cx1_54.mlx.nnext
kernel_rfl PRE_first_tail_x15_r0_body.cplo54 : (Nat.blt 0 PRE_first_tail_x15_r0_body.P54.lo && Nat.ble PRE_first_tail_x15_r0_body.P54.lo PRE_first_tail_x15_r0_body.cx0_54.mlx.next && Nat.ble PRE_first_tail_x15_r0_body.P54.lo RData.bigHi && Nat.ble RData.bigHi PRE_first_tail_x15_r0_body.P54.E) = true
kernel_rfl PRE_first_tail_x15_r0_body.ccnt54 : (Nat.ble PRE_first_tail_x15_r0_body.cx0_54.mlx.next PRE_first_tail_x15_r0_body.cx1_54.mlx.next && Nat.ble PRE_first_tail_x15_r0_body.cx0_54.mlx.nnext PRE_first_tail_x15_r0_body.cx1_54.mlx.nnext) = true
kernel_rfl PRE_first_tail_x15_r0_body.cnband54 : (Nat.blt 0 PRE_first_tail_x15_r0_body.P54.NL && Nat.ble PRE_first_tail_x15_r0_body.P54.NL PRE_first_tail_x15_r0_body.P54.N0 && Nat.ble PRE_first_tail_x15_r0_body.P54.N0 PRE_first_tail_x15_r0_body.cx0_54.mlx.nnext) = true
kernel_rfl PRE_first_tail_x15_r0_body.chbelow54 : PRE_first_tail_x15_r0_body.kd54.checkHndBelow = true
kernel_rfl PRE_first_tail_x15_r0_body.chren54 : checkRenG PRE_first_tail_x15_r0_body.kd54.hnd PRE_first_tail_x15_r0_body.khinv54 (phB PRE_first_tail_x15_r0_body.cx0_54.mlx) = true
kernel_rfl PRE_first_tail_x15_r0_body.cband54 : PRE_first_tail_x15_r0_body.kd54.checkBand PRE_first_tail_x15_r0_body.P54.lo = true
kernel_rfl PRE_first_tail_x15_r0_body.cnh1pos54 : Nat.blt 0 PRE_first_tail_x15_r0_body.kd54.nh1 = true
kernel_rfl PRE_first_tail_x15_r0_body.cnren54 : checkRenG PRE_first_tail_x15_r0_body.kd54.node PRE_first_tail_x15_r0_body.kninv54 (pnB PRE_first_tail_x15_r0_body.cx0_54.mlx) = true
kernel_rfl PRE_first_tail_x15_r0_body.cnlow54 : (PTrie.keysA PRE_first_tail_x15_r0_body.kd54.node).all (fun j => Nat.ble PRE_first_tail_x15_r0_body.P54.NL j && Nat.blt (PRE_first_tail_x15_r0_body.kd54.nodeF j) PRE_first_tail_x15_r0_body.cx1_54.mlx.nnext) = true
kernel_rfl PRE_first_tail_x15_r0_body.cabs0a54 : PRE_first_tail_x15_r0_body.cx0_54.mlx.arrs.get 0 = none
kernel_rfl PRE_first_tail_x15_r0_body.cabs0b54 : PRE_first_tail_x15_r0_body.cx0_54.mlx.objs.get 0 = none
kernel_rfl PRE_first_tail_x15_r0_body.ctok154 : PRE_first_tail_x15_r0_body.cx1_54.mlx.tokens = []
kernel_rfl PRE_first_tail_x15_r0_body.cpend54 : PRE_first_tail_x15_r0_body.cx1_54.mlx.pending = PRE_first_tail_x15_r0_body.cx0_54.mlx.pending.map PRE_first_tail_x15_r0_body.kappa54.pend
kernel_rfl PRE_first_tail_x15_r0_body.cerrh54 : PRE_first_tail_x15_r0_body.cx1_54.mlx.errh = PRE_first_tail_x15_r0_body.cx0_54.mlx.errh.map PRE_first_tail_x15_r0_body.kappa54.arg
kernel_rfl PRE_first_tail_x15_r0_body.cfiles54 : PRE_first_tail_x15_r0_body.cx1_54.mlx.files = PRE_first_tail_x15_r0_body.cx0_54.mlx.files
kernel_rfl PRE_first_tail_x15_r0_body.carch54 : PRE_first_tail_x15_r0_body.cx1_54.mlx.arch = PRE_first_tail_x15_r0_body.cx0_54.mlx.arch
kernel_rfl PRE_first_tail_x15_r0_body.csizes54 : PRE_first_tail_x15_r0_body.cx1_54.mlx.deviceSizes = PRE_first_tail_x15_r0_body.cx0_54.mlx.deviceSizes
kernel_rfl PRE_first_tail_x15_r0_body.cwired54 : PRE_first_tail_x15_r0_body.cx1_54.mlx.wired = PRE_first_tail_x15_r0_body.cx0_54.mlx.wired
kernel_rfl PRE_first_tail_x15_r0_body.chost54 : PRE_first_tail_x15_r0_body.cx1_54.host = PRE_first_tail_x15_r0_body.cx0_54.host
-- the compaction map's addresses are `PRE_first_tail_x15_r0_body.kd54`'s
kernel_rfl PRE_first_tail_x15_r0_body.ckn054 : PRE_first_tail_x15_r0_body.kd54.n0 = 2717649
kernel_rfl PRE_first_tail_x15_r0_body.ckn154 : PRE_first_tail_x15_r0_body.kd54.n1 = 2718798
kernel_rfl PRE_first_tail_x15_r0_body.ckheap54 : (PTrie.keysA PRE_first_tail_x15_r0_body.kd54.heap).all (fun x => Nat.ble 2717643 x) = true
kernel_rfl PRE_first_tail_x15_r0_body.ckpl54 : (List.range 6).all (fun j => decide (PRE_first_tail_x15_r0_body.kd54.heap.get (2717643 + j) = nth? PRE_first_tail_x15_r0_body.pl54 j)) = true
-- the map fixes the call's names (`Conv.fixOld_compact`), the call's counters
kernel_rfl PRE_first_tail_x15_r0_body.fja54 : Nat.ble 2717643 2717643 = true
kernel_rfl PRE_first_tail_x15_r0_body.fn54 : Nat.ble 2393 2393 = true
kernel_rfl PRE_first_tail_x15_r0_body.fjaD54 : Nat.ble 2717643 PRE_first_tail_x15_r0_body.kd54.n0 = true
kernel_rfl PRE_first_tail_x15_r0_body.fxn54 : Nat.ble 19274 PRE_first_tail_x15_r0_body.kd54.nh0 = true
kernel_rfl PRE_first_tail_x15_r0_body.fnn54 : Nat.ble 16352 PRE_first_tail_x15_r0_body.kd54.nn0 = true
kernel_rfl PRE_first_tail_x15_r0_body.fxb54 : Nat.ble 19274 RData.bigHi = true
kernel_rfl PRE_first_tail_x15_r0_body.fheap54 : (PTrie.keysA PRE_first_tail_x15_r0_body.kd54.heap).all (Nat.ble (⟨19274, 16352, 2717643, 2393⟩ : Conv.Cnt).ja) = true
kernel_rfl PRE_first_tail_x15_r0_body.fhnd54 : (PTrie.keysA PRE_first_tail_x15_r0_body.kd54.hnd).all (Nat.ble (⟨19274, 16352, 2717643, 2393⟩ : Conv.Cnt).xn) = true
kernel_rfl PRE_first_tail_x15_r0_body.fnode54 : (PTrie.keysA PRE_first_tail_x15_r0_body.kd54.node).all (Nat.ble (⟨19274, 16352, 2717643, 2393⟩ : Conv.Cnt).nn) = true
/-- The compaction map fixes the call's names. -/
theorem PRE_first_tail_x15_r0_body.cfix54 : Conv.FixOld (⟨19274, 16352, 2717643, 2393⟩ : Conv.Cnt) PRE_first_tail_x15_r0_body.kappa54 :=
  Conv.fixOld_compact (Nat.le_of_ble_eq_true PRE_first_tail_x15_r0_body.fja54) (Nat.le_of_ble_eq_true PRE_first_tail_x15_r0_body.fn54) (Nat.le_of_ble_eq_true PRE_first_tail_x15_r0_body.fjaD54) (Nat.le_of_ble_eq_true PRE_first_tail_x15_r0_body.fxn54) (Nat.le_of_ble_eq_true PRE_first_tail_x15_r0_body.fnn54) (Nat.le_of_ble_eq_true PRE_first_tail_x15_r0_body.fxb54) PRE_first_tail_x15_r0_body.fheap54 PRE_first_tail_x15_r0_body.fhnd54 PRE_first_tail_x15_r0_body.fnode54
kernel_rfl PRE_first_tail_x15_r0_body.fcxn54 : (⟨19274, 16352, 2717643, 2393⟩ : Conv.Cnt).xn = (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s534.ffi).mlx.next
kernel_rfl PRE_first_tail_x15_r0_body.fcnn54 : (⟨19274, 16352, 2717643, 2393⟩ : Conv.Cnt).nn = (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s534.ffi).mlx.nnext
kernel_rfl PRE_first_tail_x15_r0_body.fle054 : (Nat.ble (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s534.ffi).mlx.next PRE_first_tail_x15_r0_body.cx0_54.mlx.next && Nat.ble (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s534.ffi).mlx.nnext PRE_first_tail_x15_r0_body.cx0_54.mlx.nnext && Nat.ble (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s534.ffi).mlx.next RData.bigHi) = true
kernel_rfl PRE_first_tail_x15_r0_body.fnk54 : (PTrie.keysA PRE_first_tail_x15_r0_body.kd54.node).all (Nat.ble (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s534.ffi).mlx.nnext) = true
-- the merged state keeps the call's entries off the stage's footprint
kernel_rfl PRE_first_tail_x15_r0_body.f1A54 : PRE_first_tail_x15_r0_body.cx1_54.mlx.arrs = Stage.setAll (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s534.ffi).mlx.arrs (PRE_first_tail_x15_r0_body.cwS54.filterMap fun i => (PRE_first_tail_x15_r0_body.cx1_54.mlx.arrs.get i).map (i, ·))
kernel_rfl PRE_first_tail_x15_r0_body.f1O54 : PRE_first_tail_x15_r0_body.cx1_54.mlx.objs = Stage.setAll (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s534.ffi).mlx.objs (PRE_first_tail_x15_r0_body.cwS54.filterMap fun i => (PRE_first_tail_x15_r0_body.cx1_54.mlx.objs.get i).map (i, ·))
kernel_rfl PRE_first_tail_x15_r0_body.f1N54 : PRE_first_tail_x15_r0_body.cx1_54.mlx.nodes = Stage.setAll (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s534.ffi).mlx.nodes (PRE_first_tail_x15_r0_body.cnS54.filterMap fun i => (PRE_first_tail_x15_r0_body.cx1_54.mlx.nodes.get i).map (i, ·))
kernel_rfl PRE_first_tail_x15_r0_body.f1I54 : PRE_first_tail_x15_r0_body.cx1_54.mlx.items = Stage.setAll (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s534.ffi).mlx.items (PRE_first_tail_x15_r0_body.ciS54.filterMap fun i => (PRE_first_tail_x15_r0_body.cx1_54.mlx.items.get i).map (i, ·))
kernel_rfl PRE_first_tail_x15_r0_body.fbd54 : (PRE_first_tail_x15_r0_body.clo54 ++ PRE_first_tail_x15_r0_body.cln54 ++ PRE_first_tail_x15_r0_body.cli54 ++ PRE_first_tail_x15_r0_body.cwS54 ++ PRE_first_tail_x15_r0_body.cnS54 ++ PRE_first_tail_x15_r0_body.ciS54).all (fun i => Nat.blt (i / 4096) (4 ^ 31)) = true
kernel_rfl PRE_first_tail_x15_r0_body.fincW54 : PRE_first_tail_x15_r0_body.cwS54.all (fun h => !Nat.blt h (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s534.ffi).mlx.next || PRE_first_tail_x15_r0_body.clo54.contains h) = true
kernel_rfl PRE_first_tail_x15_r0_body.fincI54 : PRE_first_tail_x15_r0_body.ciS54.all (fun k => !Nat.blt k (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s534.ffi).mlx.nnext || PRE_first_tail_x15_r0_body.cli54.contains k) = true
kernel_rfl PRE_first_tail_x15_r0_body.fincN54 : PRE_first_tail_x15_r0_body.cnS54.all (Nat.ble (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s534.ffi).mlx.nnext) = true
kernel_rfl PRE_first_tail_x15_r0_body.flnF54 : PRE_first_tail_x15_r0_body.cln54.all (Nat.ble (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s534.ffi).mlx.nnext) = true
-- the checks over the changed lists
kernel_rfl PRE_first_tail_x15_r0_body.fh54 : PRE_first_tail_x15_r0_body.clo54.all (handleOK PRE_first_tail_x15_r0_body.kappa54 PRE_first_tail_x15_r0_body.P54.lo PRE_first_tail_x15_r0_body.cx0_54.mlx PRE_first_tail_x15_r0_body.cx1_54.mlx) = true
kernel_rfl PRE_first_tail_x15_r0_body.fo54 : PRE_first_tail_x15_r0_body.clo54.map (fun h => PRE_first_tail_x15_r0_body.cx1_54.mlx.objs.get (PRE_first_tail_x15_r0_body.kappa54.handle h)) = PRE_first_tail_x15_r0_body.clo54.map (fun h => (PRE_first_tail_x15_r0_body.cx0_54.mlx.objs.get h).map PRE_first_tail_x15_r0_body.kappa54.nobj)
kernel_rfl PRE_first_tail_x15_r0_body.fok54 : PRE_first_tail_x15_r0_body.clo54.all (objOK PRE_first_tail_x15_r0_body.kappa54 PRE_first_tail_x15_r0_body.P54.NL PRE_first_tail_x15_r0_body.cx0_54.mlx) = true
kernel_rfl PRE_first_tail_x15_r0_body.fnd54 : PRE_first_tail_x15_r0_body.cln54.all (nodeOKF PRE_first_tail_x15_r0_body.kappa54 PRE_first_tail_x15_r0_body.P54 PRE_first_tail_x15_r0_body.cx0_54.mlx PRE_first_tail_x15_r0_body.cx1_54.mlx) = true
kernel_rfl PRE_first_tail_x15_r0_body.fp54 : ((PRE_first_tail_x15_r0_body.cln54.filter (fullB PRE_first_tail_x15_r0_body.P54))).map (fun i => (PRE_first_tail_x15_r0_body.cx1_54.mlx.nodes.get (PRE_first_tail_x15_r0_body.kappa54.node i)).map Host.Mlx.Ffi.Node.prim) =
  ((PRE_first_tail_x15_r0_body.cln54.filter (fullB PRE_first_tail_x15_r0_body.P54))).map (fun i => (PRE_first_tail_x15_r0_body.cx0_54.mlx.nodes.get i).map fun nd => PRE_first_tail_x15_r0_body.kappa54.prim nd.prim)
kernel_rfl PRE_first_tail_x15_r0_body.fnordI54 : incrB PRE_first_tail_x15_r0_body.kd54.nodeF (List.range' 16352 27) = true
kernel_rfl PRE_first_tail_x15_r0_body.fnordK54 : (PTrie.keysA PRE_first_tail_x15_r0_body.kd54.node).all (fun k => Nat.ble 16352 k && Nat.blt k 16379) = true
kernel_rfl PRE_first_tail_x15_r0_body.fnordL54 : (PRE_first_tail_x15_r0_body.cln54.filter (Nat.ble PRE_first_tail_x15_r0_body.P54.N0)).all (fun i => Nat.ble i (PRE_first_tail_x15_r0_body.kd54.nodeF i) && (Nat.blt i 16379 || Nat.ble PRE_first_tail_x15_r0_body.kd54.nn0 i)) = true
theorem PRE_first_tail_x15_r0_body.fnord54 : (PRE_first_tail_x15_r0_body.cln54.filter (Nat.ble PRE_first_tail_x15_r0_body.P54.N0)).all (fun i => Nat.ble i (PRE_first_tail_x15_r0_body.kd54.nodeF i) &&
    (PTrie.keysA PRE_first_tail_x15_r0_body.kd54.node).all fun j => !Nat.blt j i || Nat.blt (PRE_first_tail_x15_r0_body.kd54.nodeF j) (PRE_first_tail_x15_r0_body.kd54.nodeF i)) = true :=
  cnord_of PRE_first_tail_x15_r0_body.cnlow54 PRE_first_tail_x15_r0_body.cnn154 PRE_first_tail_x15_r0_body.fnordI54 PRE_first_tail_x15_r0_body.fnordK54 PRE_first_tail_x15_r0_body.fnordL54
kernel_rfl PRE_first_tail_x15_r0_body.fi54 : PRE_first_tail_x15_r0_body.cli54.all (pnB PRE_first_tail_x15_r0_body.cx0_54.mlx) = true
kernel_rfl PRE_first_tail_x15_r0_body.fii54 : PRE_first_tail_x15_r0_body.cli54.all (fun k => decide (PRE_first_tail_x15_r0_body.cx1_54.mlx.items.get (PRE_first_tail_x15_r0_body.kappa54.node k) = (PRE_first_tail_x15_r0_body.cx0_54.mlx.items.get k).map PRE_first_tail_x15_r0_body.kappa54.nv)) = true
/-- **The compaction's footprint.** -/
theorem PRE_first_tail_x15_r0_body.cfoot54 (clean : Conv.NClean (⟨19274, 16352, 2717643, 2393⟩ : Conv.Cnt) (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s534.ffi).mlx) (hltC : ∀ h, PH (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s534.ffi).mlx h → h < (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s534.ffi).mlx.next) (nltC : ∀ i, PN (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s534.ffi).mlx i → i < (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s534.ffi).mlx.nnext) (itemsC : ∀ k v, (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s534.ffi).mlx.items.get k = some v → PN (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s534.ffi).mlx k) (tracedC : ∀ h o, (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s534.ffi).mlx.objs.get h = some o → ∀ i ∈ objTraces o, i < PRE_first_tail_x15_r0_body.P54.NL) (cl : SSt (· < 2411) PRE_first_tail_x15_r0_body.cx0_54.mlx) :
    Conv.MFoot PRE_first_tail_x15_r0_body.P54 2411 PRE_first_tail_x15_r0_body.kappa54 PRE_first_tail_x15_r0_body.kd54 PRE_first_tail_x15_r0_body.khinv54 PRE_first_tail_x15_r0_body.kninv54 (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s534.ffi).mlx PRE_first_tail_x15_r0_body.cx0_54.mlx PRE_first_tail_x15_r0_body.cx1_54.mlx (⟨19274, 16352, 2717643, 2393⟩ : Conv.Cnt) PRE_first_tail_x15_r0_body.clo54 PRE_first_tail_x15_r0_body.cln54 PRE_first_tail_x15_r0_body.cli54 PRE_first_tail_x15_r0_body.cwS54 PRE_first_tail_x15_r0_body.cnS54 PRE_first_tail_x15_r0_body.ciS54 :=
  ⟨rfl, rfl, rfl, PRE_first_tail_x15_r0_body.cnh054, PRE_first_tail_x15_r0_body.cnh154, PRE_first_tail_x15_r0_body.cnn054, PRE_first_tail_x15_r0_body.cnn154, PRE_first_tail_x15_r0_body.cplo54, PRE_first_tail_x15_r0_body.ccnt54, PRE_first_tail_x15_r0_body.cnband54, PRE_first_tail_x15_r0_body.chbelow54, PRE_first_tail_x15_r0_body.chren54, PRE_first_tail_x15_r0_body.cband54, PRE_first_tail_x15_r0_body.cnh1pos54, PRE_first_tail_x15_r0_body.cnren54, PRE_first_tail_x15_r0_body.cnlow54, PRE_first_tail_x15_r0_body.cabs0a54, PRE_first_tail_x15_r0_body.cabs0b54, PRE_first_tail_x15_r0_body.ctok154, PRE_first_tail_x15_r0_body.cpend54, PRE_first_tail_x15_r0_body.cerrh54, PRE_first_tail_x15_r0_body.cfiles54, PRE_first_tail_x15_r0_body.carch54, PRE_first_tail_x15_r0_body.csizes54, PRE_first_tail_x15_r0_body.cwired54, PRE_first_tail_x15_r0_body.cfix54, clean, PRE_first_tail_x15_r0_body.fcxn54, PRE_first_tail_x15_r0_body.fcnn54, hltC, nltC, itemsC, tracedC, cl, PRE_first_tail_x15_r0_body.fle054, PRE_first_tail_x15_r0_body.fnk54, PRE_first_tail_x15_r0_body.ckA54, PRE_first_tail_x15_r0_body.cobjsK54, PRE_first_tail_x15_r0_body.cnodesK54, PRE_first_tail_x15_r0_body.citemsK54, PRE_first_tail_x15_r0_body.f1A54, PRE_first_tail_x15_r0_body.f1O54, PRE_first_tail_x15_r0_body.f1N54, PRE_first_tail_x15_r0_body.f1I54, PRE_first_tail_x15_r0_body.fbd54, PRE_first_tail_x15_r0_body.fincW54, PRE_first_tail_x15_r0_body.fincI54, PRE_first_tail_x15_r0_body.fincN54, PRE_first_tail_x15_r0_body.flnF54, PRE_first_tail_x15_r0_body.fh54, PRE_first_tail_x15_r0_body.fo54, PRE_first_tail_x15_r0_body.fok54, PRE_first_tail_x15_r0_body.fnd54, PRE_first_tail_x15_r0_body.fp54, PRE_first_tail_x15_r0_body.fnord54, PRE_first_tail_x15_r0_body.fi54, PRE_first_tail_x15_r0_body.fii54⟩
theorem PRE_first_tail_x15_r0_body.cnshift54 (clean : Conv.NClean (⟨19274, 16352, 2717643, 2393⟩ : Conv.Cnt) (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s534.ffi).mlx) (hltC : ∀ h, PH (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s534.ffi).mlx h → h < (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s534.ffi).mlx.next) (nltC : ∀ i, PN (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s534.ffi).mlx i → i < (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s534.ffi).mlx.nnext) (itemsC : ∀ k v, (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s534.ffi).mlx.items.get k = some v → PN (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s534.ffi).mlx k) (tracedC : ∀ h o, (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s534.ffi).mlx.objs.get h = some o → ∀ i ∈ objTraces o, i < PRE_first_tail_x15_r0_body.P54.NL) (cl : SSt (· < 2411) PRE_first_tail_x15_r0_body.cx0_54.mlx) : NShift PRE_first_tail_x15_r0_body.P54 2411 PRE_first_tail_x15_r0_body.kappa54 PRE_first_tail_x15_r0_body.cx0_54 PRE_first_tail_x15_r0_body.cx1_54 :=
  Conv.nshift_of_foot (PRE_first_tail_x15_r0_body.cfoot54 clean hltC nltC itemsC tracedC cl) PRE_first_tail_x15_r0_body.chost54 (compact_a_eq PRE_first_tail_x15_r0_body.ckn054 PRE_first_tail_x15_r0_body.ckn154 PRE_first_tail_x15_r0_body.ckheap54 PRE_first_tail_x15_r0_body.ckpl54)

-- the observers: the layers' states at the call, the canonical and the merged state, their footprints and checks
noncomputable def PRE_first_tail_x15_r0_body.fxC_54 : PTrie Unit := (Host.Ts.Sim.Full.freedOf PRE_first_tail_x15_r0_body.s534.ffi).getD PTrie.nil
noncomputable def PRE_first_tail_x15_r0_body.krC_54 : Host.Load.Layers.KRec := (Host.Ts.Sim.Full.krecOf PRE_first_tail_x15_r0_body.s534.ffi).getD Host.Load.Layers.KRec.empty
kernel_rfl PRE_first_tail_x15_r0_body.ofxC_54 : (Host.Ts.Sim.Full.freedOf PRE_first_tail_x15_r0_body.s534.ffi) = some PRE_first_tail_x15_r0_body.fxC_54
kernel_rfl PRE_first_tail_x15_r0_body.okrC_54 : (Host.Ts.Sim.Full.krecOf PRE_first_tail_x15_r0_body.s534.ffi) = some PRE_first_tail_x15_r0_body.krC_54
noncomputable def PRE_first_tail_x15_r0_body.fx0_54 : PTrie Unit := (Host.Ts.Sim.Full.freedOf PRE_first_tail_x15_r0_body.s536.ffi).getD PTrie.nil
noncomputable def PRE_first_tail_x15_r0_body.kr0_54 : Host.Load.Layers.KRec := (Host.Ts.Sim.Full.krecOf PRE_first_tail_x15_r0_body.s536.ffi).getD Host.Load.Layers.KRec.empty
kernel_rfl PRE_first_tail_x15_r0_body.ofx0_54 : (Host.Ts.Sim.Full.freedOf PRE_first_tail_x15_r0_body.s536.ffi) = some PRE_first_tail_x15_r0_body.fx0_54
kernel_rfl PRE_first_tail_x15_r0_body.okr0_54 : (Host.Ts.Sim.Full.krecOf PRE_first_tail_x15_r0_body.s536.ffi) = some PRE_first_tail_x15_r0_body.kr0_54
noncomputable def PRE_first_tail_x15_r0_body.fx1_54 : PTrie Unit := (Host.Ts.Sim.Full.freedOf PRE_first_tail_x15_r0_body.s535.ffi).getD PTrie.nil
noncomputable def PRE_first_tail_x15_r0_body.kr1_54 : Host.Load.Layers.KRec := (Host.Ts.Sim.Full.krecOf PRE_first_tail_x15_r0_body.s535.ffi).getD Host.Load.Layers.KRec.empty
kernel_rfl PRE_first_tail_x15_r0_body.ofx1_54 : (Host.Ts.Sim.Full.freedOf PRE_first_tail_x15_r0_body.s535.ffi) = some PRE_first_tail_x15_r0_body.fx1_54
kernel_rfl PRE_first_tail_x15_r0_body.okr1_54 : (Host.Ts.Sim.Full.krecOf PRE_first_tail_x15_r0_body.s535.ffi) = some PRE_first_tail_x15_r0_body.kr1_54
kernel_rfl PRE_first_tail_x15_r0_body.ff054 : PRE_first_tail_x15_r0_body.fx0_54 = Stage.setAll PRE_first_tail_x15_r0_body.fxC_54 (PRE_first_tail_x15_r0_body.clo54.filterMap fun i => (PRE_first_tail_x15_r0_body.fx0_54.get i).map (i, ·))
kernel_rfl PRE_first_tail_x15_r0_body.ff154 : PRE_first_tail_x15_r0_body.fx1_54 = Stage.setAll PRE_first_tail_x15_r0_body.fxC_54 (PRE_first_tail_x15_r0_body.cwS54.filterMap fun i => (PRE_first_tail_x15_r0_body.fx1_54.get i).map (i, ·))
kernel_rfl PRE_first_tail_x15_r0_body.ffck54 : freedLB PRE_first_tail_x15_r0_body.kappa54 PRE_first_tail_x15_r0_body.cx0_54.mlx PRE_first_tail_x15_r0_body.fx0_54 PRE_first_tail_x15_r0_body.fx1_54 PRE_first_tail_x15_r0_body.clo54 = true
kernel_rfl PRE_first_tail_x15_r0_body.fkf054 : PRE_first_tail_x15_r0_body.kr0_54.flags = Stage.setAll PRE_first_tail_x15_r0_body.krC_54.flags (PRE_first_tail_x15_r0_body.clo54.filterMap fun i => (PRE_first_tail_x15_r0_body.kr0_54.flags.get i).map (i, ·))
kernel_rfl PRE_first_tail_x15_r0_body.fkt054 : PRE_first_tail_x15_r0_body.kr0_54.targs = Stage.setAll PRE_first_tail_x15_r0_body.krC_54.targs (PRE_first_tail_x15_r0_body.clo54.filterMap fun i => (PRE_first_tail_x15_r0_body.kr0_54.targs.get i).map (i, ·))
kernel_rfl PRE_first_tail_x15_r0_body.fkf154 : PRE_first_tail_x15_r0_body.kr1_54.flags = Stage.setAll PRE_first_tail_x15_r0_body.krC_54.flags (PRE_first_tail_x15_r0_body.cwS54.filterMap fun i => (PRE_first_tail_x15_r0_body.kr1_54.flags.get i).map (i, ·))
kernel_rfl PRE_first_tail_x15_r0_body.fkt154 : PRE_first_tail_x15_r0_body.kr1_54.targs = Stage.setAll PRE_first_tail_x15_r0_body.krC_54.targs (PRE_first_tail_x15_r0_body.cwS54.filterMap fun i => (PRE_first_tail_x15_r0_body.kr1_54.targs.get i).map (i, ·))
kernel_rfl PRE_first_tail_x15_r0_body.fkck54 : krecLB PRE_first_tail_x15_r0_body.kappa54 2411 PRE_first_tail_x15_r0_body.cx0_54.mlx PRE_first_tail_x15_r0_body.kr0_54 PRE_first_tail_x15_r0_body.kr1_54 PRE_first_tail_x15_r0_body.clo54 = true
kernel_rfl PRE_first_tail_x15_r0_body.fkn54 : Nat.ble 2393 2411 = true
-- the bridge and the pending traces' regions
kernel_rfl PRE_first_tail_x15_r0_body.cbridge54 : Host.Ts.Sim.Full.bridgeOf PRE_first_tail_x15_r0_body.s535.ffi = Host.Ts.Sim.Full.bridgeOf PRE_first_tail_x15_r0_body.s536.ffi
kernel_rfl PRE_first_tail_x15_r0_body.cpendR54 : pendRegB PRE_first_tail_x15_r0_body.kappa54 (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s536.ffi).mlx = true
kernel_rfl PRE_first_tail_x15_r0_body.cpendLe54 : Nat.ble (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s536.ffi).mlx.next (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s535.ffi).mlx.next = true
/-- **The compaction's native shift**, given the call's bookkeeping, its relation's facts (the model's and the
observers') and the canonical closedness. -/
theorem PRE_first_tail_x15_r0_body.cshift54 (clean : Conv.NClean (⟨19274, 16352, 2717643, 2393⟩ : Conv.Cnt) (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s534.ffi).mlx) (hltC : ∀ h, PH (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s534.ffi).mlx h → h < (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s534.ffi).mlx.next) (nltC : ∀ i, PN (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s534.ffi).mlx i → i < (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s534.ffi).mlx.nnext) (itemsC : ∀ k v, (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s534.ffi).mlx.items.get k = some v → PN (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s534.ffi).mlx k) (tracedC : ∀ h o, (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s534.ffi).mlx.objs.get h = some o → ∀ i ∈ objTraces o, i < PRE_first_tail_x15_r0_body.P54.NL) (cl : SSt (· < 2411) PRE_first_tail_x15_r0_body.cx0_54.mlx)
    (hobjC : ∀ h, PRE_first_tail_x15_r0_body.fxC_54.get h = some () → ((Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s534.ffi).mlx.objs.get h).isSome = true)
    (hfC : ∀ h, (PRE_first_tail_x15_r0_body.krC_54.flags.get h).isSome = true → ((Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s534.ffi).mlx.objs.get h).isSome = true)
    (htC : ∀ h, (PRE_first_tail_x15_r0_body.krC_54.targs.get h).isSome = true → ((Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s534.ffi).mlx.objs.get h).isSome = true)
    (hclC : ∀ h l, PRE_first_tail_x15_r0_body.krC_54.targs.get h = some l → Host.Ts.Sim.Full.STargs (· < (⟨19274, 16352, 2717643, 2393⟩ : Conv.Cnt).n) l) :
    Conv.FullShiftQ PRE_first_tail_x15_r0_body.P54 2411 PRE_first_tail_x15_r0_body.kappa54 PRE_first_tail_x15_r0_body.s536.ffi PRE_first_tail_x15_r0_body.s535.ffi :=
  ⟨PRE_first_tail_x15_r0_body.cnshift54 clean hltC nltC itemsC tracedC cl, PRE_first_tail_x15_r0_body.cqueue54, fun t ht => bSN_sound (List.all_eq_true.mp PRE_first_tail_x15_r0_body.ctokSupp54 t ht),
    PRE_first_tail_x15_r0_body.cbridge54,
    liveShift_foot (x0' := Host.Ts.Sim.Full.mlxOf PRE_first_tail_x15_r0_body.s536.ffi) (x1' := Host.Ts.Sim.Full.mlxOf PRE_first_tail_x15_r0_body.s535.ffi) (PRE_first_tail_x15_r0_body.cfoot54 clean hltC nltC itemsC tracedC cl) rfl PRE_first_tail_x15_r0_body.ofx0_54 PRE_first_tail_x15_r0_body.ofx1_54 hobjC PRE_first_tail_x15_r0_body.ff054 PRE_first_tail_x15_r0_body.ff154 PRE_first_tail_x15_r0_body.ffck54,
    kernShift_foot (x0' := Host.Ts.Sim.Full.mlxOf PRE_first_tail_x15_r0_body.s536.ffi) (x1' := Host.Ts.Sim.Full.mlxOf PRE_first_tail_x15_r0_body.s535.ffi) (PRE_first_tail_x15_r0_body.cfoot54 clean hltC nltC itemsC tracedC cl) rfl PRE_first_tail_x15_r0_body.okr0_54 PRE_first_tail_x15_r0_body.okr1_54 (Nat.le_of_ble_eq_true PRE_first_tail_x15_r0_body.fkn54) hfC htC hclC
      PRE_first_tail_x15_r0_body.fkf054 PRE_first_tail_x15_r0_body.fkt054 PRE_first_tail_x15_r0_body.fkf154 PRE_first_tail_x15_r0_body.fkt154 PRE_first_tail_x15_r0_body.fkck54,
    pendReg_of rfl PRE_first_tail_x15_r0_body.cnh054 PRE_first_tail_x15_r0_body.cnh154 (Nat.le_of_ble_eq_true PRE_first_tail_x15_r0_body.cpendLe54) PRE_first_tail_x15_r0_body.cpendR54⟩

end Host.Load.Run.Tpl
end

section -- st54/H0
set_option Elab.async false
namespace Host.Load.Run.Tpl
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
host_stream_state PRE_first_tail_x15_r0_body.st54 0
host_stream_state PRE_first_tail_x15_r0_body.st54 1
host_stream_state PRE_first_tail_x15_r0_body.st54 2
host_stream_state PRE_first_tail_x15_r0_body.st54 3
host_stream_state PRE_first_tail_x15_r0_body.st54 4
host_stream_state PRE_first_tail_x15_r0_body.st54 5
end Host.Load.Run.Tpl
end

section -- Site54
set_option Elab.async false
namespace Host.Load.Run.Tpl
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
open Host.Ts Host.Ts.Sim Host.Ts.Sim.Template

/-! Call site 54 of chain `PRE_first_tail_x15_r0_body`: `ssmW__g54__g55` (`recurWindow`), the call state `PRE_first_tail_x15_r0_body.s534`, the merged state `PRE_first_tail_x15_r0_body.s535`,
the site template `PRE_first_tail_x15_r0_body.st54` (σ = `Map.id`, θ the identity at its own site), the canonical state `PRE_first_tail_x15_r0_body.s536`: the merge.
The footprint's facts are in `SiteF54`, the compaction's in `SiteC54`, `SiteK54`, `SiteNa54`, `SiteNb54`. -/

kernel_rfl PRE_first_tail_x15_r0_body.iso54 : PRE_first_tail_x15_r0_body.st54.s0 = { PRE_first_tail_x15_r0_body.s534 with stack := [] }
/-- The caller's frames at the call. -/
noncomputable def PRE_first_tail_x15_r0_body.rs54 : List Frame := PRE_first_tail_x15_r0_body.s534.stack
kernel_rfl PRE_first_tail_x15_r0_body.n0_54 : PRE_first_tail_x15_r0_body.S534.tab.length = 2393
kernel_rfl PRE_first_tail_x15_r0_body.tab0_54 : PRE_first_tail_x15_r0_body.st54.S0.tab = PRE_first_tail_x15_r0_body.S534.tab

/-- The fresh variables of the stage's results. -/
def PRE_first_tail_x15_r0_body.ws54 : List Nat := [1916, 1917, 1918, 1919, 1920, 1921, 1922, 1923, 1924, 1925, 1926, 1927, 1928, 1929, 1930, 1931, 1932, 1933, 1934, 1935, 1936, 1937, 1938, 1939, 1940, 1941, 1942, 1943, 1944, 1945, 1946]
kernel_rfl PRE_first_tail_x15_r0_body.fresh54 : (PRE_first_tail_x15_r0_body.S534.tab.all fun e => PRE_first_tail_x15_r0_body.ws54.all fun v => e.noVar v) &&
    (PRE_first_tail_x15_r0_body.S534.oracle.all fun q => PRE_first_tail_x15_r0_body.ws54.all fun v => q.noVar v) = true
kernel_rfl PRE_first_tail_x15_r0_body.mergeTab54 : PRE_first_tail_x15_r0_body.S535.tab = PRE_first_tail_x15_r0_body.S534.tab ++ Conv.resTab PRE_first_tail_x15_r0_body.ws54
kernel_rfl PRE_first_tail_x15_r0_body.mergeLen54 : PRE_first_tail_x15_r0_body.st54.S5.tab.length - PRE_first_tail_x15_r0_body.st54.S0.tab.length = 31

-- The merged state: the instance's return state with the caller's frames (`PRE_first_tail_x15_r0_body.merged54`, `merged_relB`).
kernel_rfl PRE_first_tail_x15_r0_body.mheap54 : PRE_first_tail_x15_r0_body.s535.heap = PRE_first_tail_x15_r0_body.st54.s5.heap
kernel_rfl PRE_first_tail_x15_r0_body.mnext54 : PRE_first_tail_x15_r0_body.s535.next = PRE_first_tail_x15_r0_body.st54.s5.next
kernel_rfl PRE_first_tail_x15_r0_body.mctl54 : PRE_first_tail_x15_r0_body.s535.ctl = PRE_first_tail_x15_r0_body.st54.s5.ctl
kernel_rfl PRE_first_tail_x15_r0_body.mstack54 : PRE_first_tail_x15_r0_body.s535.stack = PRE_first_tail_x15_r0_body.st54.s5.stack ++ PRE_first_tail_x15_r0_body.s534.stack
kernel_rfl PRE_first_tail_x15_r0_body.mjobs54 : PRE_first_tail_x15_r0_body.s535.jobs = PRE_first_tail_x15_r0_body.st54.s5.jobs
kernel_rfl PRE_first_tail_x15_r0_body.mffi54 : PRE_first_tail_x15_r0_body.s535.ffi = PRE_first_tail_x15_r0_body.st54.s5.ffi
kernel_rfl PRE_first_tail_x15_r0_body.mtrace54 : PRE_first_tail_x15_r0_body.s535.trace = PRE_first_tail_x15_r0_body.st54.s5.trace
kernel_rfl PRE_first_tail_x15_r0_body.mstores54 : PRE_first_tail_x15_r0_body.s535.stores = PRE_first_tail_x15_r0_body.st54.s5.stores

end Host.Load.Run.Tpl
end

section -- SiteD54
set_option Elab.async false
namespace Host.Load.Run.Tpl
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
open Host.Ts Host.Ts.Sim Host.Ts.Sim.Template

/-! The canonical results at call site 54 of chain `PRE_first_tail_x15_r0_body`: their values in the instance's end table, the references past
the call's table, the canonical variables apart from the stage's. -/

kernel_rfl PRE_first_tail_x15_r0_body.cderived54 : PRE_first_tail_x15_r0_body.nr54.map (fun r => nth? PRE_first_tail_x15_r0_body.st54.S5.tab r) =
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
kernel_rfl PRE_first_tail_x15_r0_body.cnrLo54 : PRE_first_tail_x15_r0_body.nr54.all (Nat.ble 2393) = true
kernel_rfl PRE_first_tail_x15_r0_body.cwsDisj54 : PRE_first_tail_x15_r0_body.cws54.all (fun c => !PRE_first_tail_x15_r0_body.ws54.contains c) = true
/-- The compaction's substitution: the canonical variables to their merged values, the stage's other fresh variables
to `0` (`Conv.compactθZ`). -/
noncomputable def PRE_first_tail_x15_r0_body.cthetaZ54 : Nat → SymE := Conv.compactθZ PRE_first_tail_x15_r0_body.cws54 PRE_first_tail_x15_r0_body.crs54 PRE_first_tail_x15_r0_body.ws54

end Host.Load.Run.Tpl
end

section -- st54/Foot
set_option Elab.async false
namespace Host.Load.Run.Tpl
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
open Host.Ts Host.Ts.Sim Host.Ts.Sim.Stage Host.Ts.Sim.Template

/-! The footprint of stage `PRE_first_tail_x15_r0_body.st54`'s site template (`Conv.StageFoot`, `Conv.NFoot`): every entry of the return
state other than the written and fresh ones is the start's (kernel evaluation of the equalities). -/

/-- The written heap ranges below the start's counter. -/
def PRE_first_tail_x15_r0_body.st54.wrR : List (Nat × Nat) := [(2672434, 2672435), (2716817, 2716818), (2717362, 2717363), (2717618, 2717619)]
/-- The written and fresh entries of the return state. -/
noncomputable def PRE_first_tail_x15_r0_body.st54.wrE : List (Nat × Host.Ts.HObj) :=
  rangesOf PRE_first_tail_x15_r0_body.st54.s5.heap PRE_first_tail_x15_r0_body.st54.wrR ++ freshOf PRE_first_tail_x15_r0_body.st54.s5.heap PRE_first_tail_x15_r0_body.st54.s0.next PRE_first_tail_x15_r0_body.st54.s5.next
noncomputable def PRE_first_tail_x15_r0_body.st54.wr : List Nat := PRE_first_tail_x15_r0_body.st54.wrE.map (·.1)

kernel_rfl PRE_first_tail_x15_r0_body.st54.heapFoot : PRE_first_tail_x15_r0_body.st54.s5.heap = setAll PRE_first_tail_x15_r0_body.st54.s0.heap PRE_first_tail_x15_r0_body.st54.wrE
kernel_rfl PRE_first_tail_x15_r0_body.st54.grows_check : Nat.ble PRE_first_tail_x15_r0_body.st54.s0.next PRE_first_tail_x15_r0_body.st54.s5.next = true
theorem PRE_first_tail_x15_r0_body.st54.grows : PRE_first_tail_x15_r0_body.st54.s0.next ≤ PRE_first_tail_x15_r0_body.st54.s5.next := Nat.le_of_ble_eq_true PRE_first_tail_x15_r0_body.st54.grows_check

/-- The written and fresh handles; the written readback items of old nodes. -/
def PRE_first_tail_x15_r0_body.st54.wh : List Nat := [19254, 19267, 19273, 19274, 19275, 19276, 19277, 19278, 19279, 19280, 19281, 19282, 19283, 19284, 19285, 19286, 19287, 19288, 19289, 19290, 19291, 19292, 19293, 19294, 19295, 19296, 19297, 19298, 19299, 19300, 19301]
def PRE_first_tail_x15_r0_body.st54.wi : List Nat := []

kernel_rfl PRE_first_tail_x15_r0_body.st54.arrsFoot : (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.st54.s5.ffi).mlx.arrs = setAll (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.st54.s0.ffi).mlx.arrs (PRE_first_tail_x15_r0_body.st54.wh.filterMap fun h => ((Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.st54.s5.ffi).mlx.arrs.get h).map (h, ·))
kernel_rfl PRE_first_tail_x15_r0_body.st54.objsFoot : (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.st54.s5.ffi).mlx.objs = setAll (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.st54.s0.ffi).mlx.objs (PRE_first_tail_x15_r0_body.st54.wh.filterMap fun h => ((Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.st54.s5.ffi).mlx.objs.get h).map (h, ·))
kernel_rfl PRE_first_tail_x15_r0_body.st54.nodesFoot : (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.st54.s5.ffi).mlx.nodes = setAll (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.st54.s0.ffi).mlx.nodes (freshOf (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.st54.s5.ffi).mlx.nodes (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.st54.s0.ffi).mlx.nnext (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.st54.s5.ffi).mlx.nnext)
kernel_rfl PRE_first_tail_x15_r0_body.st54.itemsFoot : (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.st54.s5.ffi).mlx.items = setAll (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.st54.s0.ffi).mlx.items ((PRE_first_tail_x15_r0_body.st54.wi.filterMap fun i => ((Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.st54.s5.ffi).mlx.items.get i).map (i, ·)) ++
    freshOf (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.st54.s5.ffi).mlx.items (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.st54.s0.ffi).mlx.nnext (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.st54.s5.ffi).mlx.nnext)
kernel_rfl PRE_first_tail_x15_r0_body.st54.counters : (Nat.ble (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.st54.s0.ffi).mlx.next (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.st54.s5.ffi).mlx.next && Nat.ble (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.st54.s0.ffi).mlx.nnext (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.st54.s5.ffi).mlx.nnext) = true

end Host.Load.Run.Tpl
end

section -- SiteF54
set_option Elab.async false
namespace Host.Load.Run.Tpl
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
open Host.Ts Host.Ts.Sim Host.Ts.Sim.Template

/-! Call site 54 of chain `PRE_first_tail_x15_r0_body`: `Conv.site_merge`'s footprint facts. -/

kernel_rfl PRE_first_tail_x15_r0_body.wrNodupB54 : nodupT PRE_first_tail_x15_r0_body.st54.wr PTrie.nil = true
theorem PRE_first_tail_x15_r0_body.wrNodup54 : PRE_first_tail_x15_r0_body.st54.wr.Nodup := (nodupT_sound PRE_first_tail_x15_r0_body.wrNodupB54).2
kernel_rfl PRE_first_tail_x15_r0_body.wrBoundB54 : PRE_first_tail_x15_r0_body.st54.wr.all (fun b => Nat.blt (b / 4096) (4 ^ 31)) = true
theorem PRE_first_tail_x15_r0_body.wrBound54 : ∀ b ∈ PRE_first_tail_x15_r0_body.st54.wr, b / 4096 < 4 ^ 31 := fun b hb => Nat.blt_eq.mp (List.all_eq_true.mp PRE_first_tail_x15_r0_body.wrBoundB54 b hb)
noncomputable def PRE_first_tail_x15_r0_body.trFr54 := PRE_first_tail_x15_r0_body.st54.s5.trace.take 120
kernel_rfl PRE_first_tail_x15_r0_body.traceEq54 : PRE_first_tail_x15_r0_body.st54.s5.trace = PRE_first_tail_x15_r0_body.trFr54 ++ PRE_first_tail_x15_r0_body.st54.s0.trace
theorem PRE_first_tail_x15_r0_body.trace54 : ∃ fr, PRE_first_tail_x15_r0_body.st54.s5.trace = fr ++ PRE_first_tail_x15_r0_body.st54.s0.trace := ⟨_, PRE_first_tail_x15_r0_body.traceEq54⟩

-- the caller's wide frames at the instance's start (`Conv.isolateW`'s `W0` under `Map.id`) and their `WFix`
def PRE_first_tail_x15_r0_body.wide54 : List (Nat × WFrame) := [(4910, .memo [])]
kernel_rfl PRE_first_tail_x15_r0_body.wfixB54 : (PRE_first_tail_x15_r0_body.wide54.all fun p => wfixB Map.id (presentB PRE_first_tail_x15_r0_body.st54.s0) p.2) = true
theorem PRE_first_tail_x15_r0_body.wfix54 : ∀ p ∈ PRE_first_tail_x15_r0_body.wide54, WFix Map.id (Present PRE_first_tail_x15_r0_body.st54.s0) p.2 :=
  fun p hp => wfix_of (List.all_eq_true.mp PRE_first_tail_x15_r0_body.wfixB54 p hp)

end Host.Load.Run.Tpl
end

section -- SiteL54
set_option Elab.async false
namespace Host.Load.Run.Tpl
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
open Host.Ts Host.Ts.Sim Host.Ts.Sim.Template

/-! The call link's facts at call site 54 of chain `PRE_first_tail_x15_r0_body`: the instance's start server, its footprint (`Conv.StageFoot`), the
merged state `PRE_first_tail_x15_r0_body.s535`'s framed arrays as the chain start's extended (`arrExt_of`, `numRefs_of`). -/

kernel_rfl PRE_first_tail_x15_r0_body.srvO54 : PRE_first_tail_x15_r0_body.st54.S0.oracle = PRE_first_tail_x15_r0_body.st54.OR
kernel_rfl PRE_first_tail_x15_r0_body.wr0B54 : PRE_first_tail_x15_r0_body.st54.wr.all (fun b => !Nat.blt b PRE_first_tail_x15_r0_body.st54.s0.next || (PRE_first_tail_x15_r0_body.st54.s0.heap.get b).isSome) = true
theorem PRE_first_tail_x15_r0_body.stFoot54 : Conv.StageFoot PRE_first_tail_x15_r0_body.st54.wr PRE_first_tail_x15_r0_body.st54.s0 PRE_first_tail_x15_r0_body.st54.s5 :=
  stageFoot_of PRE_first_tail_x15_r0_body.st54.heapFoot PRE_first_tail_x15_r0_body.wrNodup54 PRE_first_tail_x15_r0_body.wrBound54 PRE_first_tail_x15_r0_body.wr0B54 PRE_first_tail_x15_r0_body.st54.grows

/-- **The relation at the merged state** from the relation at the merge (`Conv.site_merge`'s; `merged_relB`). -/
theorem PRE_first_tail_x15_r0_body.merged54 {FR : Map → Nat → PRE_first_tail_x15_r0_body.st54.F.S → PRE_first_tail_x15_r0_body.st54.F.S → Prop} {W : Nat → Option WFrame} {stk : List Frame} {M : Map}
    {ν : Nat → F64} {K : Host.Ts.Sim.Ctx} {S : SSrv} {t : St PRE_first_tail_x15_r0_body.st54.F.S} {C : CSrv} {n0 : Nat}
    (h : RelB PRE_first_tail_x15_r0_body.st54.F FR W stk M ν K (Conv.mergeSt Map.id (Map.id.res n0 n0) PRE_first_tail_x15_r0_body.rs54 PRE_first_tail_x15_r0_body.st54.wr PRE_first_tail_x15_r0_body.s534 PRE_first_tail_x15_r0_body.st54.s5 PRE_first_tail_x15_r0_body.st54.s0
      PRE_first_tail_x15_r0_body.st54.s5.ffi) S t C) : RelB PRE_first_tail_x15_r0_body.st54.F FR W stk M ν K PRE_first_tail_x15_r0_body.s535 S t C :=
  merged_relB PRE_first_tail_x15_r0_body.iso54 PRE_first_tail_x15_r0_body.stFoot54 PRE_first_tail_x15_r0_body.wrNodup54 PRE_first_tail_x15_r0_body.wrBound54 PRE_first_tail_x15_r0_body.trace54 PRE_first_tail_x15_r0_body.mheap54
    PRE_first_tail_x15_r0_body.mnext54 PRE_first_tail_x15_r0_body.mctl54 PRE_first_tail_x15_r0_body.mstack54 PRE_first_tail_x15_r0_body.mjobs54 PRE_first_tail_x15_r0_body.mffi54 PRE_first_tail_x15_r0_body.mtrace54 PRE_first_tail_x15_r0_body.mstores54 h

def PRE_first_tail_x15_r0_body.arrEl54_2665 : List Val := []
kernel_rfl PRE_first_tail_x15_r0_body.arrE54_2665 : arrOf PRE_first_tail_x15_r0_body.s535 2665 = arrOf PRE_first_tail_x15_r0_body.s0 2665 ++ PRE_first_tail_x15_r0_body.arrEl54_2665
kernel_rfl PRE_first_tail_x15_r0_body.arrA54_2665 : isArrB PRE_first_tail_x15_r0_body.s535 2665 = true
theorem PRE_first_tail_x15_r0_body.arr54_2665 : ∃ o, PRE_first_tail_x15_r0_body.s535.heap.get 2665 = some (.obj o) ∧ o.kind = .array (arrOf PRE_first_tail_x15_r0_body.s0 2665 ++ PRE_first_tail_x15_r0_body.arrEl54_2665) :=
  arrExt_of PRE_first_tail_x15_r0_body.arrE54_2665 PRE_first_tail_x15_r0_body.arrA54_2665
kernel_rfl PRE_first_tail_x15_r0_body.arrN54_2665 : numRefsB PRE_first_tail_x15_r0_body.S0.tab.length PRE_first_tail_x15_r0_body.arrEl54_2665 = true
theorem PRE_first_tail_x15_r0_body.arrR54_2665 : Prefill.NumRefs PRE_first_tail_x15_r0_body.S0.tab.length PRE_first_tail_x15_r0_body.arrEl54_2665 := numRefs_of PRE_first_tail_x15_r0_body.arrN54_2665

def PRE_first_tail_x15_r0_body.arrEl54_2673467 : List Val := []
kernel_rfl PRE_first_tail_x15_r0_body.arrE54_2673467 : arrOf PRE_first_tail_x15_r0_body.s535 2673467 = arrOf PRE_first_tail_x15_r0_body.s0 2673467 ++ PRE_first_tail_x15_r0_body.arrEl54_2673467
kernel_rfl PRE_first_tail_x15_r0_body.arrA54_2673467 : isArrB PRE_first_tail_x15_r0_body.s535 2673467 = true
theorem PRE_first_tail_x15_r0_body.arr54_2673467 : ∃ o, PRE_first_tail_x15_r0_body.s535.heap.get 2673467 = some (.obj o) ∧ o.kind = .array (arrOf PRE_first_tail_x15_r0_body.s0 2673467 ++ PRE_first_tail_x15_r0_body.arrEl54_2673467) :=
  arrExt_of PRE_first_tail_x15_r0_body.arrE54_2673467 PRE_first_tail_x15_r0_body.arrA54_2673467
kernel_rfl PRE_first_tail_x15_r0_body.arrN54_2673467 : numRefsB PRE_first_tail_x15_r0_body.S0.tab.length PRE_first_tail_x15_r0_body.arrEl54_2673467 = true
theorem PRE_first_tail_x15_r0_body.arrR54_2673467 : Prefill.NumRefs PRE_first_tail_x15_r0_body.S0.tab.length PRE_first_tail_x15_r0_body.arrEl54_2673467 := numRefs_of PRE_first_tail_x15_r0_body.arrN54_2673467

kernel_rfl PRE_first_tail_x15_r0_body.w4910k54 : isArrB PRE_first_tail_x15_r0_body.s535 4910 = false
theorem PRE_first_tail_x15_r0_body.keep54 (q : List Val) : Host.Ts.Sim.Prefill.KeepsAtW (framesP PRE_first_tail_x15_r0_body.s0 q) PRE_first_tail_x15_r0_body.s535 := by
  intro a pre pre' hx o es ho hk
  unfold framesP at hx
  simp only at hx
  cases h1 : Nat.beq a 2665
  · cases h2 : Nat.beq a 4910
    · rw [h1, h2] at hx; cases hx
    · have := Nat.eq_of_beq_eq_true h2; subst this
      rw [h1, h2] at hx; cases hx
      exact (notArr_of PRE_first_tail_x15_r0_body.w4910k54 ho hk).elim
  · have := Nat.eq_of_beq_eq_true h1; subst this
    rw [h1] at hx; cases hx
    obtain ⟨o', ho', hk'⟩ := PRE_first_tail_x15_r0_body.arr54_2665
    rw [ho] at ho'; cases ho'
    rw [hk'] at hk; cases hk
    simp [PRE_first_tail_x15_r0_body.arrEl54_2665]

end Host.Load.Run.Tpl
end

section -- SiteZ54
set_option Elab.async false
namespace Host.Load.Run.Tpl
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
open Host.Ts Host.Ts.Sim Host.Ts.Sim.Template

/-! The compaction's state shift at call site 54 of chain `PRE_first_tail_x15_r0_body` (`Conv.compact_shift`): the call `PRE_first_tail_x15_r0_body.s534`, the merged
state `PRE_first_tail_x15_r0_body.s535`, the canonical state `PRE_first_tail_x15_r0_body.s536`; its frames [2665,2673467,2673472,2673473] (kept arrays [2665,2673467]). -/

-- the map's places and counters
kernel_rfl PRE_first_tail_x15_r0_body.zpl54 : PRE_first_tail_x15_r0_body.pl54.all (Nat.ble PRE_first_tail_x15_r0_body.s534.next) = true
kernel_rfl PRE_first_tail_x15_r0_body.zplnd54 : nodupT PRE_first_tail_x15_r0_body.pl54 PTrie.nil = true
kernel_rfl PRE_first_tail_x15_r0_body.zn154 : Nat.ble PRE_first_tail_x15_r0_body.s534.next 2718798 = true
kernel_rfl PRE_first_tail_x15_r0_body.zfirst54 : Nat.ble aFirst PRE_first_tail_x15_r0_body.s534.next = true
kernel_rfl PRE_first_tail_x15_r0_body.zscn54 : PRE_first_tail_x15_r0_body.s536.next = PRE_first_tail_x15_r0_body.s534.next + PRE_first_tail_x15_r0_body.pl54.length
kernel_rfl PRE_first_tail_x15_r0_body.zsmn54 : PRE_first_tail_x15_r0_body.s535.next = 2718798
kernel_rfl PRE_first_tail_x15_r0_body.zgrow54 : Nat.ble PRE_first_tail_x15_r0_body.s536.next PRE_first_tail_x15_r0_body.s535.next = true
-- the tables
kernel_rfl PRE_first_tail_x15_r0_body.zfresh54 : PRE_first_tail_x15_r0_body.S534.tab.all (fun e => PRE_first_tail_x15_r0_body.cws54.all fun v => e.noVar v) = true
kernel_rfl PRE_first_tail_x15_r0_body.zcnd54 : nodupT PRE_first_tail_x15_r0_body.cws54 PTrie.nil = true
kernel_rfl PRE_first_tail_x15_r0_body.znrHi54 : PRE_first_tail_x15_r0_body.nr54.all (fun r => Nat.blt r PRE_first_tail_x15_r0_body.S535.tab.length) = true
-- the frames: every framed address below the call's counter; the kept arrays the chain start's, extended in the merged state
kernel_rfl PRE_first_tail_x15_r0_body.zfrlt54 : [2665, 2673467, 2673472, 2673473].all (fun a => Nat.blt a PRE_first_tail_x15_r0_body.s534.next) = true
kernel_rfl PRE_first_tail_x15_r0_body.zg54_2665 : PRE_first_tail_x15_r0_body.s536.heap.get 2665 = some (.obj (objOf PRE_first_tail_x15_r0_body.s536 2665))
kernel_rfl PRE_first_tail_x15_r0_body.zk54_2665 : (objOf PRE_first_tail_x15_r0_body.s536 2665).kind = .array (arrOf PRE_first_tail_x15_r0_body.s0 2665)
kernel_rfl PRE_first_tail_x15_r0_body.zm54_2665 : PRE_first_tail_x15_r0_body.s535.heap.get 2665 = some (.obj { PRE_first_tail_x15_r0_body.kappa54.obj (objOf PRE_first_tail_x15_r0_body.s536 2665) with
  kind := .array (arrOf PRE_first_tail_x15_r0_body.s0 2665 ++ (arrOf PRE_first_tail_x15_r0_body.s535 2665).drop (arrOf PRE_first_tail_x15_r0_body.s0 2665).length) })
kernel_rfl PRE_first_tail_x15_r0_body.zg54_2673467 : PRE_first_tail_x15_r0_body.s536.heap.get 2673467 = some (.obj (objOf PRE_first_tail_x15_r0_body.s536 2673467))
kernel_rfl PRE_first_tail_x15_r0_body.zk54_2673467 : (objOf PRE_first_tail_x15_r0_body.s536 2673467).kind = .array (arrOf PRE_first_tail_x15_r0_body.s0 2673467)
kernel_rfl PRE_first_tail_x15_r0_body.zm54_2673467 : PRE_first_tail_x15_r0_body.s535.heap.get 2673467 = some (.obj { PRE_first_tail_x15_r0_body.kappa54.obj (objOf PRE_first_tail_x15_r0_body.s536 2673467) with
  kind := .array (arrOf PRE_first_tail_x15_r0_body.s0 2673467 ++ (arrOf PRE_first_tail_x15_r0_body.s535 2673467).drop (arrOf PRE_first_tail_x15_r0_body.s0 2673467).length) })
kernel_rfl PRE_first_tail_x15_r0_body.zw54_4910 : (PRE_first_tail_x15_r0_body.s536.heap.get 4910).isSome = true
kernel_rfl PRE_first_tail_x15_r0_body.zw54_2673472 : (PRE_first_tail_x15_r0_body.s536.heap.get 2673472).isSome = true
kernel_rfl PRE_first_tail_x15_r0_body.zw54_2673473 : (PRE_first_tail_x15_r0_body.s536.heap.get 2673473).isSome = true
-- the heap: the changed list in range, holding the stage's written and fresh addresses; the canonical side's image
kernel_rfl PRE_first_tail_x15_r0_body.zclbd54 : PRE_first_tail_x15_r0_body.cl54.all (fun b => Nat.blt (b / 4096) (4 ^ 31)) = true
kernel_rfl PRE_first_tail_x15_r0_body.zwr54 : PRE_first_tail_x15_r0_body.st54.wr.all (fun b => !Nat.blt b PRE_first_tail_x15_r0_body.s534.next || PRE_first_tail_x15_r0_body.cl54.contains b) = true
def PRE_first_tail_x15_r0_body.zl54 : List Nat := PRE_first_tail_x15_r0_body.cl54.filter fun a => !(List.contains [2665, 2673467] a)
kernel_rfl PRE_first_tail_x15_r0_body.zimgE54 : PRE_first_tail_x15_r0_body.zl54.map (fun a => PRE_first_tail_x15_r0_body.s535.heap.get (PRE_first_tail_x15_r0_body.kappa54.a a)) = PRE_first_tail_x15_r0_body.zl54.map (fun a => (PRE_first_tail_x15_r0_body.s536.heap.get a).map PRE_first_tail_x15_r0_body.kappa54.hobj)
theorem PRE_first_tail_x15_r0_body.zimg54 : HeapImg PRE_first_tail_x15_r0_body.kappa54 PRE_first_tail_x15_r0_body.s536 PRE_first_tail_x15_r0_body.s535 PRE_first_tail_x15_r0_body.zl54 := PRE_first_tail_x15_r0_body.zimgE54
-- the roots and their supports
kernel_rfl PRE_first_tail_x15_r0_body.zctl54 : PRE_first_tail_x15_r0_body.s535.ctl = PRE_first_tail_x15_r0_body.kappa54.ctl PRE_first_tail_x15_r0_body.s536.ctl
kernel_rfl PRE_first_tail_x15_r0_body.zstack54 : PRE_first_tail_x15_r0_body.s535.stack = PRE_first_tail_x15_r0_body.s536.stack.map PRE_first_tail_x15_r0_body.kappa54.frame
kernel_rfl PRE_first_tail_x15_r0_body.zjobs54 : PRE_first_tail_x15_r0_body.s535.jobs = PRE_first_tail_x15_r0_body.s536.jobs.map PRE_first_tail_x15_r0_body.kappa54.job
kernel_rfl PRE_first_tail_x15_r0_body.zstores54 : PRE_first_tail_x15_r0_body.s535.stores = PRE_first_tail_x15_r0_body.kappa54.stores PRE_first_tail_x15_r0_body.s536.stores
kernel_rfl PRE_first_tail_x15_r0_body.zroots54 : checkRootsSupp PRE_first_tail_x15_r0_body.s536 2411 = true
kernel_rfl PRE_first_tail_x15_r0_body.znC54 : PRE_first_tail_x15_r0_body.S534.tab.length + PRE_first_tail_x15_r0_body.cws54.length = 2411
-- the map as `Conv.compact_shift` states it (the call's counters for the literals)
kernel_rfl PRE_first_tail_x15_r0_body.zkap54 : PRE_first_tail_x15_r0_body.kappa54 = Conv.Map.compact PRE_first_tail_x15_r0_body.s534.next 2718798 PRE_first_tail_x15_r0_body.S534.tab.length PRE_first_tail_x15_r0_body.pl54 (PRE_first_tail_x15_r0_body.nr54.map NumV.ref) PRE_first_tail_x15_r0_body.kd54.big
  PRE_first_tail_x15_r0_body.kd54.region PRE_first_tail_x15_r0_body.kd54.nodeF
-- the bridge inactive at the canonical state (`Conv.FullShiftQ.toX`; the merged state's bridge is the canonical's: cbridge)
theorem PRE_first_tail_x15_r0_body.zbin54 : (Host.Ts.Sim.Full.bridgeOf PRE_first_tail_x15_r0_body.s536.ffi).active = false := (Host.Load.Boot.replay_active Host.Load.Run.Prompt.P.oblog2818)
-- the JS bookkeeping's step (`Conv.JClean.step` over the changed list) and the canonical roots' bigint freedom
kernel_rfl PRE_first_tail_x15_r0_body.zjc54 : Conv.jcleanListB (⟨19277, 16379, 2717649, 2411⟩ : Conv.Cnt) PRE_first_tail_x15_r0_body.s536 PRE_first_tail_x15_r0_body.cl54 = true
kernel_rfl PRE_first_tail_x15_r0_body.zrootsB54 : noBigRootsP (fun i => !Conv.oldBigB (⟨19277, 16379, 2717649, 2411⟩ : Conv.Cnt) i) PRE_first_tail_x15_r0_body.s536.trace PRE_first_tail_x15_r0_body.s536 = true
kernel_rfl PRE_first_tail_x15_r0_body.zhm54 : Nat.ble (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s0.ffi).mlx.nnext 16352 = true
theorem PRE_first_tail_x15_r0_body.cjcl54 (h : Conv.JClean (⟨19274, 16352, 2717643, 2393⟩ : Conv.Cnt) PRE_first_tail_x15_r0_body.s534) : Conv.JClean (⟨19277, 16379, 2717649, 2411⟩ : Conv.Cnt) PRE_first_tail_x15_r0_body.s536 :=
  Conv.JClean.step h (Conv.Cnt.le_of_leB PRE_first_tail_x15_r0_body.cle54)
    (Conv.heap_off_setAll PRE_first_tail_x15_r0_body.cheap54 fun a ha => Nat.blt_eq.mp (List.all_eq_true.mp PRE_first_tail_x15_r0_body.zclbd54 a ha)) PRE_first_tail_x15_r0_body.zjc54

end Host.Load.Run.Tpl
end

section -- st54/TypedLast
set_option Elab.async false
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
namespace Host.Load.Run.Tpl
open Host.Ts Host.Ts.Sim Host.Ts.Sim.Template

boot_rfl PRE_first_tail_x15_r0_body.st54.bodyLast from PRE_first_tail_x15_r0_body.st54.s4 to PRE_first_tail_x15_r0_body.st54.s5 :
  interpS (step PRE_first_tail_x15_r0_body.st54.F PRE_first_tail_x15_r0_body.st54.s4).run PRE_first_tail_x15_r0_body.st54.S4 = some (PRE_first_tail_x15_r0_body.st54.s5, PRE_first_tail_x15_r0_body.st54.S5)
kernel_rfl PRE_first_tail_x15_r0_body.st54.bodyHalt : isHalt PRE_first_tail_x15_r0_body.st54.s4.ctl = false
kernel_rfl PRE_first_tail_x15_r0_body.st54.bodyTopCheck : noBlockTop PRE_first_tail_x15_r0_body.st54.s5.stack = true

end Host.Load.Run.Tpl
end

section -- st54/TypedOk
set_option Elab.async false
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
namespace Host.Load.Run.Tpl
open Host.Ts Host.Ts.Sim Host.Ts.Sim.Template

noncomputable def PRE_first_tail_x15_r0_body.st54.bodyOkL (bytes : List Byte) (rows : Nat) : St PRE_first_tail_x15_r0_body.st54.F.S → SSrv → Bool :=
  okLocal (Host.Ts.Sim.Compose.VWFrames.bodyOk bytes rows)

noncomputable def PRE_first_tail_x15_r0_body.st54.bodyOkLN (bytes : List Byte) (rows : Nat) : St PRE_first_tail_x15_r0_body.st54.F.S → FSrv → Bool :=
  okLocalN (Host.Ts.Sim.Compose.VWFrames.bodyOkN bytes rows)

theorem PRE_first_tail_x15_r0_body.st54.bodyOkLN_ok (bytes : List Byte) (rows : Nat) (s : St PRE_first_tail_x15_r0_body.st54.F.S) (c : FSrv) (h : c.Wf) :
    PRE_first_tail_x15_r0_body.st54.bodyOkLN bytes rows s c = PRE_first_tail_x15_r0_body.st54.bodyOkL bytes rows s c.toS :=
  okLocalN_ok (Host.Ts.Sim.Compose.VWFrames.bodyOkN_ok bytes rows) s c h

kernel_rfl PRE_first_tail_x15_r0_body.st54.bodyAccepted0 :
  (fun (bytes : List Byte) (rows : Nat) => PRE_first_tail_x15_r0_body.st54.bodyOkL bytes rows PRE_first_tail_x15_r0_body.st54.s0 PRE_first_tail_x15_r0_body.st54.S0) = fun _ _ => true

kernel_rfl PRE_first_tail_x15_r0_body.st54.bodyAccepted1 :
  (fun (bytes : List Byte) (rows : Nat) => PRE_first_tail_x15_r0_body.st54.bodyOkL bytes rows PRE_first_tail_x15_r0_body.st54.s4 PRE_first_tail_x15_r0_body.st54.S4) = fun _ _ => true

end Host.Load.Run.Tpl
end

section -- st54/TypedK0
set_option Elab.async false
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
namespace Host.Load.Run.Tpl
open Host.Ts Host.Ts.Sim Host.Ts.Sim.Template

boot_rfl PRE_first_tail_x15_r0_body.st54.bodyK0F from PRE_first_tail_x15_r0_body.st54.s0 to PRE_first_tail_x15_r0_body.st54.s1 :
  (fun (bytes : List Byte) (rows : Nat) => runOkS PRE_first_tail_x15_r0_body.st54.F (PRE_first_tail_x15_r0_body.st54.bodyOkLN bytes rows)
    ((nth? PRE_first_tail_x15_r0_body.st54.ks 0).getD 0) PRE_first_tail_x15_r0_body.st54.s0 PRE_first_tail_x15_r0_body.st54.S0) = fun _ _ => some (PRE_first_tail_x15_r0_body.st54.s1, PRE_first_tail_x15_r0_body.st54.S1)
theorem PRE_first_tail_x15_r0_body.st54.bodyK0 :
  (fun (bytes : List Byte) (rows : Nat) => runOk PRE_first_tail_x15_r0_body.st54.F (PRE_first_tail_x15_r0_body.st54.bodyOkL bytes rows)
    ((nth? PRE_first_tail_x15_r0_body.st54.ks 0).getD 0) PRE_first_tail_x15_r0_body.st54.s0 PRE_first_tail_x15_r0_body.st54.S0) = fun _ _ => some (PRE_first_tail_x15_r0_body.st54.s1, PRE_first_tail_x15_r0_body.st54.S1) :=
  runOk_fun_of_runOkS PRE_first_tail_x15_r0_body.st54.bodyOkLN_ok PRE_first_tail_x15_r0_body.st54.bodyK0F
end Host.Load.Run.Tpl
end
