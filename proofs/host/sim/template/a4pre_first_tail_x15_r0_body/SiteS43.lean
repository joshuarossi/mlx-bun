import host.sim.template.a4pre_first_tail_x15_r0_body.SiteCl43
import host.sim.conv.CompactFull
import host.sim.template.FootGen
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
