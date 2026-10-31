import host.sim.template.a4pre_first_tail_x15_r0_body.SiteCl163
import host.sim.conv.CompactFull
import host.sim.template.FootGen
set_option Elab.async false
namespace Host.Load.Run.Tpl
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
open Host.Ts Host.Ts.Sim Host.Ts.Sim.Template

/-! The compaction's native shift at call site 163 from its footprint (`Conv.nshift_of_foot`), and the observers'
(`liveShift_foot`, `kernShift_foot`): `Conv.FullShiftQ` for `Conv.full_compactQ`, given the call's bookkeeping and its
relation's facts. -/

/-- The load parameters of the chain (band-free: its start's node counter as `NL` and `N0`). -/
def PRE_first_tail_x15_r0_body.Pc163 : LoadP := ⟨18151, 131072, 1099511627776, 15235, 15235, []⟩
/-- The site's band raised to the map's checked fixed-node prefix, including newly recorded closure traces. -/
def PRE_first_tail_x15_r0_body.P163 : LoadP := PRE_first_tail_x15_r0_body.Pc163.raise 18525
kernel_rfl PRE_first_tail_x15_r0_body.craise163 : Nat.ble PRE_first_tail_x15_r0_body.Pc163.N0 18525 = true
theorem PRE_first_tail_x15_r0_body.raised163 : Host.Ts.Sim.Full.Raised PRE_first_tail_x15_r0_body.Pc163 PRE_first_tail_x15_r0_body.P163 :=
  .inr ⟨18525, rfl, Nat.le_of_ble_eq_true PRE_first_tail_x15_r0_body.craise163, rfl⟩
noncomputable abbrev PRE_first_tail_x15_r0_body.cx0_163 : Host.Load.LSt := clearTokens (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1579.ffi)
noncomputable abbrev PRE_first_tail_x15_r0_body.cx1_163 : Host.Load.LSt := clearTokens (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1578.ffi)
def PRE_first_tail_x15_r0_body.khinv163 : PTrie Nat := Stage.setAll PTrie.nil []
def PRE_first_tail_x15_r0_body.kninv163 : PTrie Nat := Stage.setAll PTrie.nil []
/-- The stage's footprint: its written and fresh handles, fresh nodes, written and fresh items. -/
def PRE_first_tail_x15_r0_body.cwS163 : List Nat := []
def PRE_first_tail_x15_r0_body.cnS163 : List Nat := List.range' 18525 0
def PRE_first_tail_x15_r0_body.ciS163 : List Nat := [] ++ List.range' 18525 0

-- the small checks (`MChecks`'s)
kernel_rfl PRE_first_tail_x15_r0_body.cnh0163 : PRE_first_tail_x15_r0_body.kd163.nh0 = PRE_first_tail_x15_r0_body.cx0_163.mlx.next
kernel_rfl PRE_first_tail_x15_r0_body.cnh1163 : PRE_first_tail_x15_r0_body.kd163.nh1 = PRE_first_tail_x15_r0_body.cx1_163.mlx.next
kernel_rfl PRE_first_tail_x15_r0_body.cnn0163 : PRE_first_tail_x15_r0_body.kd163.nn0 = PRE_first_tail_x15_r0_body.cx0_163.mlx.nnext
kernel_rfl PRE_first_tail_x15_r0_body.cnn1163 : PRE_first_tail_x15_r0_body.kd163.nn1 = PRE_first_tail_x15_r0_body.cx1_163.mlx.nnext
kernel_rfl PRE_first_tail_x15_r0_body.cplo163 : (Nat.blt 0 PRE_first_tail_x15_r0_body.P163.lo && Nat.ble PRE_first_tail_x15_r0_body.P163.lo PRE_first_tail_x15_r0_body.cx0_163.mlx.next && Nat.ble PRE_first_tail_x15_r0_body.P163.lo RData.bigHi && Nat.ble RData.bigHi PRE_first_tail_x15_r0_body.P163.E) = true
kernel_rfl PRE_first_tail_x15_r0_body.ccnt163 : (Nat.ble PRE_first_tail_x15_r0_body.cx0_163.mlx.next PRE_first_tail_x15_r0_body.cx1_163.mlx.next && Nat.ble PRE_first_tail_x15_r0_body.cx0_163.mlx.nnext PRE_first_tail_x15_r0_body.cx1_163.mlx.nnext) = true
kernel_rfl PRE_first_tail_x15_r0_body.cnband163 : (Nat.blt 0 PRE_first_tail_x15_r0_body.P163.NL && Nat.ble PRE_first_tail_x15_r0_body.P163.NL PRE_first_tail_x15_r0_body.P163.N0 && Nat.ble PRE_first_tail_x15_r0_body.P163.N0 PRE_first_tail_x15_r0_body.cx0_163.mlx.nnext) = true
kernel_rfl PRE_first_tail_x15_r0_body.chbelow163 : PRE_first_tail_x15_r0_body.kd163.checkHndBelow = true
kernel_rfl PRE_first_tail_x15_r0_body.chren163 : checkRenG PRE_first_tail_x15_r0_body.kd163.hnd PRE_first_tail_x15_r0_body.khinv163 (phB PRE_first_tail_x15_r0_body.cx0_163.mlx) = true
kernel_rfl PRE_first_tail_x15_r0_body.cband163 : PRE_first_tail_x15_r0_body.kd163.checkBand PRE_first_tail_x15_r0_body.P163.lo = true
kernel_rfl PRE_first_tail_x15_r0_body.cnh1pos163 : Nat.blt 0 PRE_first_tail_x15_r0_body.kd163.nh1 = true
kernel_rfl PRE_first_tail_x15_r0_body.cnren163 : checkRenG PRE_first_tail_x15_r0_body.kd163.node PRE_first_tail_x15_r0_body.kninv163 (pnB PRE_first_tail_x15_r0_body.cx0_163.mlx) = true
kernel_rfl PRE_first_tail_x15_r0_body.cnlow163 : (PTrie.keysA PRE_first_tail_x15_r0_body.kd163.node).all (fun j => Nat.ble PRE_first_tail_x15_r0_body.P163.NL j && Nat.blt (PRE_first_tail_x15_r0_body.kd163.nodeF j) PRE_first_tail_x15_r0_body.cx1_163.mlx.nnext) = true
kernel_rfl PRE_first_tail_x15_r0_body.cabs0a163 : PRE_first_tail_x15_r0_body.cx0_163.mlx.arrs.get 0 = none
kernel_rfl PRE_first_tail_x15_r0_body.cabs0b163 : PRE_first_tail_x15_r0_body.cx0_163.mlx.objs.get 0 = none
kernel_rfl PRE_first_tail_x15_r0_body.ctok1163 : PRE_first_tail_x15_r0_body.cx1_163.mlx.tokens = []
kernel_rfl PRE_first_tail_x15_r0_body.cpend163 : PRE_first_tail_x15_r0_body.cx1_163.mlx.pending = PRE_first_tail_x15_r0_body.cx0_163.mlx.pending.map PRE_first_tail_x15_r0_body.kappa163.pend
kernel_rfl PRE_first_tail_x15_r0_body.cerrh163 : PRE_first_tail_x15_r0_body.cx1_163.mlx.errh = PRE_first_tail_x15_r0_body.cx0_163.mlx.errh.map PRE_first_tail_x15_r0_body.kappa163.arg
kernel_rfl PRE_first_tail_x15_r0_body.cfiles163 : PRE_first_tail_x15_r0_body.cx1_163.mlx.files = PRE_first_tail_x15_r0_body.cx0_163.mlx.files
kernel_rfl PRE_first_tail_x15_r0_body.carch163 : PRE_first_tail_x15_r0_body.cx1_163.mlx.arch = PRE_first_tail_x15_r0_body.cx0_163.mlx.arch
kernel_rfl PRE_first_tail_x15_r0_body.csizes163 : PRE_first_tail_x15_r0_body.cx1_163.mlx.deviceSizes = PRE_first_tail_x15_r0_body.cx0_163.mlx.deviceSizes
kernel_rfl PRE_first_tail_x15_r0_body.cwired163 : PRE_first_tail_x15_r0_body.cx1_163.mlx.wired = PRE_first_tail_x15_r0_body.cx0_163.mlx.wired
kernel_rfl PRE_first_tail_x15_r0_body.chost163 : PRE_first_tail_x15_r0_body.cx1_163.host = PRE_first_tail_x15_r0_body.cx0_163.host
-- the compaction map's addresses are `PRE_first_tail_x15_r0_body.kd163`'s
kernel_rfl PRE_first_tail_x15_r0_body.ckn0163 : PRE_first_tail_x15_r0_body.kd163.n0 = 2802887
kernel_rfl PRE_first_tail_x15_r0_body.ckn1163 : PRE_first_tail_x15_r0_body.kd163.n1 = 2802889
kernel_rfl PRE_first_tail_x15_r0_body.ckheap163 : (PTrie.keysA PRE_first_tail_x15_r0_body.kd163.heap).all (fun x => Nat.ble 2802887 x) = true
kernel_rfl PRE_first_tail_x15_r0_body.ckpl163 : (List.range 0).all (fun j => decide (PRE_first_tail_x15_r0_body.kd163.heap.get (2802887 + j) = nth? PRE_first_tail_x15_r0_body.pl163 j)) = true
-- the map fixes the call's names (`Conv.fixOld_compact`), the call's counters
kernel_rfl PRE_first_tail_x15_r0_body.fja163 : Nat.ble 2802887 2802887 = true
kernel_rfl PRE_first_tail_x15_r0_body.fn163 : Nat.ble 7049 7049 = true
kernel_rfl PRE_first_tail_x15_r0_body.fjaD163 : Nat.ble 2802887 PRE_first_tail_x15_r0_body.kd163.n0 = true
kernel_rfl PRE_first_tail_x15_r0_body.fxn163 : Nat.ble 21414 PRE_first_tail_x15_r0_body.kd163.nh0 = true
kernel_rfl PRE_first_tail_x15_r0_body.fnn163 : Nat.ble 18525 PRE_first_tail_x15_r0_body.kd163.nn0 = true
kernel_rfl PRE_first_tail_x15_r0_body.fxb163 : Nat.ble 21414 RData.bigHi = true
kernel_rfl PRE_first_tail_x15_r0_body.fheap163 : (PTrie.keysA PRE_first_tail_x15_r0_body.kd163.heap).all (Nat.ble (⟨21414, 18525, 2802887, 7049⟩ : Conv.Cnt).ja) = true
kernel_rfl PRE_first_tail_x15_r0_body.fhnd163 : (PTrie.keysA PRE_first_tail_x15_r0_body.kd163.hnd).all (Nat.ble (⟨21414, 18525, 2802887, 7049⟩ : Conv.Cnt).xn) = true
kernel_rfl PRE_first_tail_x15_r0_body.fnode163 : (PTrie.keysA PRE_first_tail_x15_r0_body.kd163.node).all (Nat.ble (⟨21414, 18525, 2802887, 7049⟩ : Conv.Cnt).nn) = true
/-- The compaction map fixes the call's names. -/
theorem PRE_first_tail_x15_r0_body.cfix163 : Conv.FixOld (⟨21414, 18525, 2802887, 7049⟩ : Conv.Cnt) PRE_first_tail_x15_r0_body.kappa163 :=
  Conv.fixOld_compact (Nat.le_of_ble_eq_true PRE_first_tail_x15_r0_body.fja163) (Nat.le_of_ble_eq_true PRE_first_tail_x15_r0_body.fn163) (Nat.le_of_ble_eq_true PRE_first_tail_x15_r0_body.fjaD163) (Nat.le_of_ble_eq_true PRE_first_tail_x15_r0_body.fxn163) (Nat.le_of_ble_eq_true PRE_first_tail_x15_r0_body.fnn163) (Nat.le_of_ble_eq_true PRE_first_tail_x15_r0_body.fxb163) PRE_first_tail_x15_r0_body.fheap163 PRE_first_tail_x15_r0_body.fhnd163 PRE_first_tail_x15_r0_body.fnode163
kernel_rfl PRE_first_tail_x15_r0_body.fcxn163 : (⟨21414, 18525, 2802887, 7049⟩ : Conv.Cnt).xn = (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1577.ffi).mlx.next
kernel_rfl PRE_first_tail_x15_r0_body.fcnn163 : (⟨21414, 18525, 2802887, 7049⟩ : Conv.Cnt).nn = (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1577.ffi).mlx.nnext
kernel_rfl PRE_first_tail_x15_r0_body.fle0163 : (Nat.ble (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1577.ffi).mlx.next PRE_first_tail_x15_r0_body.cx0_163.mlx.next && Nat.ble (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1577.ffi).mlx.nnext PRE_first_tail_x15_r0_body.cx0_163.mlx.nnext && Nat.ble (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1577.ffi).mlx.next RData.bigHi) = true
kernel_rfl PRE_first_tail_x15_r0_body.fnk163 : (PTrie.keysA PRE_first_tail_x15_r0_body.kd163.node).all (Nat.ble (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1577.ffi).mlx.nnext) = true
-- the merged state keeps the call's entries off the stage's footprint
kernel_rfl PRE_first_tail_x15_r0_body.f1A163 : PRE_first_tail_x15_r0_body.cx1_163.mlx.arrs = Stage.setAll (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1577.ffi).mlx.arrs (PRE_first_tail_x15_r0_body.cwS163.filterMap fun i => (PRE_first_tail_x15_r0_body.cx1_163.mlx.arrs.get i).map (i, ·))
kernel_rfl PRE_first_tail_x15_r0_body.f1O163 : PRE_first_tail_x15_r0_body.cx1_163.mlx.objs = Stage.setAll (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1577.ffi).mlx.objs (PRE_first_tail_x15_r0_body.cwS163.filterMap fun i => (PRE_first_tail_x15_r0_body.cx1_163.mlx.objs.get i).map (i, ·))
kernel_rfl PRE_first_tail_x15_r0_body.f1N163 : PRE_first_tail_x15_r0_body.cx1_163.mlx.nodes = Stage.setAll (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1577.ffi).mlx.nodes (PRE_first_tail_x15_r0_body.cnS163.filterMap fun i => (PRE_first_tail_x15_r0_body.cx1_163.mlx.nodes.get i).map (i, ·))
kernel_rfl PRE_first_tail_x15_r0_body.f1I163 : PRE_first_tail_x15_r0_body.cx1_163.mlx.items = Stage.setAll (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1577.ffi).mlx.items (PRE_first_tail_x15_r0_body.ciS163.filterMap fun i => (PRE_first_tail_x15_r0_body.cx1_163.mlx.items.get i).map (i, ·))
kernel_rfl PRE_first_tail_x15_r0_body.fbd163 : (PRE_first_tail_x15_r0_body.clo163 ++ PRE_first_tail_x15_r0_body.cln163 ++ PRE_first_tail_x15_r0_body.cli163 ++ PRE_first_tail_x15_r0_body.cwS163 ++ PRE_first_tail_x15_r0_body.cnS163 ++ PRE_first_tail_x15_r0_body.ciS163).all (fun i => Nat.blt (i / 4096) (4 ^ 31)) = true
kernel_rfl PRE_first_tail_x15_r0_body.fincW163 : PRE_first_tail_x15_r0_body.cwS163.all (fun h => !Nat.blt h (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1577.ffi).mlx.next || PRE_first_tail_x15_r0_body.clo163.contains h) = true
kernel_rfl PRE_first_tail_x15_r0_body.fincI163 : PRE_first_tail_x15_r0_body.ciS163.all (fun k => !Nat.blt k (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1577.ffi).mlx.nnext || PRE_first_tail_x15_r0_body.cli163.contains k) = true
kernel_rfl PRE_first_tail_x15_r0_body.fincN163 : PRE_first_tail_x15_r0_body.cnS163.all (Nat.ble (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1577.ffi).mlx.nnext) = true
kernel_rfl PRE_first_tail_x15_r0_body.flnF163 : PRE_first_tail_x15_r0_body.cln163.all (Nat.ble (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1577.ffi).mlx.nnext) = true
-- the checks over the changed lists
kernel_rfl PRE_first_tail_x15_r0_body.fh163 : PRE_first_tail_x15_r0_body.clo163.all (handleOK PRE_first_tail_x15_r0_body.kappa163 PRE_first_tail_x15_r0_body.P163.lo PRE_first_tail_x15_r0_body.cx0_163.mlx PRE_first_tail_x15_r0_body.cx1_163.mlx) = true
kernel_rfl PRE_first_tail_x15_r0_body.fo163 : PRE_first_tail_x15_r0_body.clo163.map (fun h => PRE_first_tail_x15_r0_body.cx1_163.mlx.objs.get (PRE_first_tail_x15_r0_body.kappa163.handle h)) = PRE_first_tail_x15_r0_body.clo163.map (fun h => (PRE_first_tail_x15_r0_body.cx0_163.mlx.objs.get h).map PRE_first_tail_x15_r0_body.kappa163.nobj)
kernel_rfl PRE_first_tail_x15_r0_body.fok163 : PRE_first_tail_x15_r0_body.clo163.all (objOK PRE_first_tail_x15_r0_body.kappa163 PRE_first_tail_x15_r0_body.P163.NL PRE_first_tail_x15_r0_body.cx0_163.mlx) = true
kernel_rfl PRE_first_tail_x15_r0_body.fnd163 : PRE_first_tail_x15_r0_body.cln163.all (nodeOKF PRE_first_tail_x15_r0_body.kappa163 PRE_first_tail_x15_r0_body.P163 PRE_first_tail_x15_r0_body.cx0_163.mlx PRE_first_tail_x15_r0_body.cx1_163.mlx) = true
kernel_rfl PRE_first_tail_x15_r0_body.fp163 : ((PRE_first_tail_x15_r0_body.cln163.filter (fullB PRE_first_tail_x15_r0_body.P163))).map (fun i => (PRE_first_tail_x15_r0_body.cx1_163.mlx.nodes.get (PRE_first_tail_x15_r0_body.kappa163.node i)).map Host.Mlx.Ffi.Node.prim) =
  ((PRE_first_tail_x15_r0_body.cln163.filter (fullB PRE_first_tail_x15_r0_body.P163))).map (fun i => (PRE_first_tail_x15_r0_body.cx0_163.mlx.nodes.get i).map fun nd => PRE_first_tail_x15_r0_body.kappa163.prim nd.prim)
kernel_rfl PRE_first_tail_x15_r0_body.fnordI163 : incrB PRE_first_tail_x15_r0_body.kd163.nodeF (List.range' 18525 0) = true
kernel_rfl PRE_first_tail_x15_r0_body.fnordK163 : (PTrie.keysA PRE_first_tail_x15_r0_body.kd163.node).all (fun k => Nat.ble 18525 k && Nat.blt k 18525) = true
kernel_rfl PRE_first_tail_x15_r0_body.fnordL163 : (PRE_first_tail_x15_r0_body.cln163.filter (Nat.ble PRE_first_tail_x15_r0_body.P163.N0)).all (fun i => Nat.ble i (PRE_first_tail_x15_r0_body.kd163.nodeF i) && (Nat.blt i 18525 || Nat.ble PRE_first_tail_x15_r0_body.kd163.nn0 i)) = true
theorem PRE_first_tail_x15_r0_body.fnord163 : (PRE_first_tail_x15_r0_body.cln163.filter (Nat.ble PRE_first_tail_x15_r0_body.P163.N0)).all (fun i => Nat.ble i (PRE_first_tail_x15_r0_body.kd163.nodeF i) &&
    (PTrie.keysA PRE_first_tail_x15_r0_body.kd163.node).all fun j => !Nat.blt j i || Nat.blt (PRE_first_tail_x15_r0_body.kd163.nodeF j) (PRE_first_tail_x15_r0_body.kd163.nodeF i)) = true :=
  cnord_of PRE_first_tail_x15_r0_body.cnlow163 PRE_first_tail_x15_r0_body.cnn1163 PRE_first_tail_x15_r0_body.fnordI163 PRE_first_tail_x15_r0_body.fnordK163 PRE_first_tail_x15_r0_body.fnordL163
kernel_rfl PRE_first_tail_x15_r0_body.fi163 : PRE_first_tail_x15_r0_body.cli163.all (pnB PRE_first_tail_x15_r0_body.cx0_163.mlx) = true
kernel_rfl PRE_first_tail_x15_r0_body.fii163 : PRE_first_tail_x15_r0_body.cli163.all (fun k => decide (PRE_first_tail_x15_r0_body.cx1_163.mlx.items.get (PRE_first_tail_x15_r0_body.kappa163.node k) = (PRE_first_tail_x15_r0_body.cx0_163.mlx.items.get k).map PRE_first_tail_x15_r0_body.kappa163.nv)) = true
/-- **The compaction's footprint.** -/
theorem PRE_first_tail_x15_r0_body.cfoot163 (clean : Conv.NClean (⟨21414, 18525, 2802887, 7049⟩ : Conv.Cnt) (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1577.ffi).mlx) (hltC : ∀ h, PH (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1577.ffi).mlx h → h < (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1577.ffi).mlx.next) (nltC : ∀ i, PN (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1577.ffi).mlx i → i < (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1577.ffi).mlx.nnext) (itemsC : ∀ k v, (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1577.ffi).mlx.items.get k = some v → PN (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1577.ffi).mlx k) (tracedC : ∀ h o, (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1577.ffi).mlx.objs.get h = some o → ∀ i ∈ objTraces o, i < PRE_first_tail_x15_r0_body.P163.NL) (cl : SSt (· < 7049) PRE_first_tail_x15_r0_body.cx0_163.mlx) :
    Conv.MFoot PRE_first_tail_x15_r0_body.P163 7049 PRE_first_tail_x15_r0_body.kappa163 PRE_first_tail_x15_r0_body.kd163 PRE_first_tail_x15_r0_body.khinv163 PRE_first_tail_x15_r0_body.kninv163 (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1577.ffi).mlx PRE_first_tail_x15_r0_body.cx0_163.mlx PRE_first_tail_x15_r0_body.cx1_163.mlx (⟨21414, 18525, 2802887, 7049⟩ : Conv.Cnt) PRE_first_tail_x15_r0_body.clo163 PRE_first_tail_x15_r0_body.cln163 PRE_first_tail_x15_r0_body.cli163 PRE_first_tail_x15_r0_body.cwS163 PRE_first_tail_x15_r0_body.cnS163 PRE_first_tail_x15_r0_body.ciS163 :=
  ⟨rfl, rfl, rfl, PRE_first_tail_x15_r0_body.cnh0163, PRE_first_tail_x15_r0_body.cnh1163, PRE_first_tail_x15_r0_body.cnn0163, PRE_first_tail_x15_r0_body.cnn1163, PRE_first_tail_x15_r0_body.cplo163, PRE_first_tail_x15_r0_body.ccnt163, PRE_first_tail_x15_r0_body.cnband163, PRE_first_tail_x15_r0_body.chbelow163, PRE_first_tail_x15_r0_body.chren163, PRE_first_tail_x15_r0_body.cband163, PRE_first_tail_x15_r0_body.cnh1pos163, PRE_first_tail_x15_r0_body.cnren163, PRE_first_tail_x15_r0_body.cnlow163, PRE_first_tail_x15_r0_body.cabs0a163, PRE_first_tail_x15_r0_body.cabs0b163, PRE_first_tail_x15_r0_body.ctok1163, PRE_first_tail_x15_r0_body.cpend163, PRE_first_tail_x15_r0_body.cerrh163, PRE_first_tail_x15_r0_body.cfiles163, PRE_first_tail_x15_r0_body.carch163, PRE_first_tail_x15_r0_body.csizes163, PRE_first_tail_x15_r0_body.cwired163, PRE_first_tail_x15_r0_body.cfix163, clean, PRE_first_tail_x15_r0_body.fcxn163, PRE_first_tail_x15_r0_body.fcnn163, hltC, nltC, itemsC, tracedC, cl, PRE_first_tail_x15_r0_body.fle0163, PRE_first_tail_x15_r0_body.fnk163, PRE_first_tail_x15_r0_body.ckA163, PRE_first_tail_x15_r0_body.cobjsK163, PRE_first_tail_x15_r0_body.cnodesK163, PRE_first_tail_x15_r0_body.citemsK163, PRE_first_tail_x15_r0_body.f1A163, PRE_first_tail_x15_r0_body.f1O163, PRE_first_tail_x15_r0_body.f1N163, PRE_first_tail_x15_r0_body.f1I163, PRE_first_tail_x15_r0_body.fbd163, PRE_first_tail_x15_r0_body.fincW163, PRE_first_tail_x15_r0_body.fincI163, PRE_first_tail_x15_r0_body.fincN163, PRE_first_tail_x15_r0_body.flnF163, PRE_first_tail_x15_r0_body.fh163, PRE_first_tail_x15_r0_body.fo163, PRE_first_tail_x15_r0_body.fok163, PRE_first_tail_x15_r0_body.fnd163, PRE_first_tail_x15_r0_body.fp163, PRE_first_tail_x15_r0_body.fnord163, PRE_first_tail_x15_r0_body.fi163, PRE_first_tail_x15_r0_body.fii163⟩
theorem PRE_first_tail_x15_r0_body.cnshift163 (clean : Conv.NClean (⟨21414, 18525, 2802887, 7049⟩ : Conv.Cnt) (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1577.ffi).mlx) (hltC : ∀ h, PH (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1577.ffi).mlx h → h < (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1577.ffi).mlx.next) (nltC : ∀ i, PN (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1577.ffi).mlx i → i < (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1577.ffi).mlx.nnext) (itemsC : ∀ k v, (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1577.ffi).mlx.items.get k = some v → PN (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1577.ffi).mlx k) (tracedC : ∀ h o, (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1577.ffi).mlx.objs.get h = some o → ∀ i ∈ objTraces o, i < PRE_first_tail_x15_r0_body.P163.NL) (cl : SSt (· < 7049) PRE_first_tail_x15_r0_body.cx0_163.mlx) : NShift PRE_first_tail_x15_r0_body.P163 7049 PRE_first_tail_x15_r0_body.kappa163 PRE_first_tail_x15_r0_body.cx0_163 PRE_first_tail_x15_r0_body.cx1_163 :=
  Conv.nshift_of_foot (PRE_first_tail_x15_r0_body.cfoot163 clean hltC nltC itemsC tracedC cl) PRE_first_tail_x15_r0_body.chost163 (compact_a_eq PRE_first_tail_x15_r0_body.ckn0163 PRE_first_tail_x15_r0_body.ckn1163 PRE_first_tail_x15_r0_body.ckheap163 PRE_first_tail_x15_r0_body.ckpl163)

-- the observers: the layers' states at the call, the canonical and the merged state, their footprints and checks
noncomputable def PRE_first_tail_x15_r0_body.fxC_163 : PTrie Unit := (Host.Ts.Sim.Full.freedOf PRE_first_tail_x15_r0_body.s1577.ffi).getD PTrie.nil
noncomputable def PRE_first_tail_x15_r0_body.krC_163 : Host.Load.Layers.KRec := (Host.Ts.Sim.Full.krecOf PRE_first_tail_x15_r0_body.s1577.ffi).getD Host.Load.Layers.KRec.empty
kernel_rfl PRE_first_tail_x15_r0_body.ofxC_163 : (Host.Ts.Sim.Full.freedOf PRE_first_tail_x15_r0_body.s1577.ffi) = some PRE_first_tail_x15_r0_body.fxC_163
kernel_rfl PRE_first_tail_x15_r0_body.okrC_163 : (Host.Ts.Sim.Full.krecOf PRE_first_tail_x15_r0_body.s1577.ffi) = some PRE_first_tail_x15_r0_body.krC_163
noncomputable def PRE_first_tail_x15_r0_body.fx0_163 : PTrie Unit := (Host.Ts.Sim.Full.freedOf PRE_first_tail_x15_r0_body.s1579.ffi).getD PTrie.nil
noncomputable def PRE_first_tail_x15_r0_body.kr0_163 : Host.Load.Layers.KRec := (Host.Ts.Sim.Full.krecOf PRE_first_tail_x15_r0_body.s1579.ffi).getD Host.Load.Layers.KRec.empty
kernel_rfl PRE_first_tail_x15_r0_body.ofx0_163 : (Host.Ts.Sim.Full.freedOf PRE_first_tail_x15_r0_body.s1579.ffi) = some PRE_first_tail_x15_r0_body.fx0_163
kernel_rfl PRE_first_tail_x15_r0_body.okr0_163 : (Host.Ts.Sim.Full.krecOf PRE_first_tail_x15_r0_body.s1579.ffi) = some PRE_first_tail_x15_r0_body.kr0_163
noncomputable def PRE_first_tail_x15_r0_body.fx1_163 : PTrie Unit := (Host.Ts.Sim.Full.freedOf PRE_first_tail_x15_r0_body.s1578.ffi).getD PTrie.nil
noncomputable def PRE_first_tail_x15_r0_body.kr1_163 : Host.Load.Layers.KRec := (Host.Ts.Sim.Full.krecOf PRE_first_tail_x15_r0_body.s1578.ffi).getD Host.Load.Layers.KRec.empty
kernel_rfl PRE_first_tail_x15_r0_body.ofx1_163 : (Host.Ts.Sim.Full.freedOf PRE_first_tail_x15_r0_body.s1578.ffi) = some PRE_first_tail_x15_r0_body.fx1_163
kernel_rfl PRE_first_tail_x15_r0_body.okr1_163 : (Host.Ts.Sim.Full.krecOf PRE_first_tail_x15_r0_body.s1578.ffi) = some PRE_first_tail_x15_r0_body.kr1_163
kernel_rfl PRE_first_tail_x15_r0_body.ff0163 : PRE_first_tail_x15_r0_body.fx0_163 = Stage.setAll PRE_first_tail_x15_r0_body.fxC_163 (PRE_first_tail_x15_r0_body.clo163.filterMap fun i => (PRE_first_tail_x15_r0_body.fx0_163.get i).map (i, ·))
kernel_rfl PRE_first_tail_x15_r0_body.ff1163 : PRE_first_tail_x15_r0_body.fx1_163 = Stage.setAll PRE_first_tail_x15_r0_body.fxC_163 (PRE_first_tail_x15_r0_body.cwS163.filterMap fun i => (PRE_first_tail_x15_r0_body.fx1_163.get i).map (i, ·))
kernel_rfl PRE_first_tail_x15_r0_body.ffck163 : freedLB PRE_first_tail_x15_r0_body.kappa163 PRE_first_tail_x15_r0_body.cx0_163.mlx PRE_first_tail_x15_r0_body.fx0_163 PRE_first_tail_x15_r0_body.fx1_163 PRE_first_tail_x15_r0_body.clo163 = true
kernel_rfl PRE_first_tail_x15_r0_body.fkf0163 : PRE_first_tail_x15_r0_body.kr0_163.flags = Stage.setAll PRE_first_tail_x15_r0_body.krC_163.flags (PRE_first_tail_x15_r0_body.clo163.filterMap fun i => (PRE_first_tail_x15_r0_body.kr0_163.flags.get i).map (i, ·))
kernel_rfl PRE_first_tail_x15_r0_body.fkt0163 : PRE_first_tail_x15_r0_body.kr0_163.targs = Stage.setAll PRE_first_tail_x15_r0_body.krC_163.targs (PRE_first_tail_x15_r0_body.clo163.filterMap fun i => (PRE_first_tail_x15_r0_body.kr0_163.targs.get i).map (i, ·))
kernel_rfl PRE_first_tail_x15_r0_body.fkf1163 : PRE_first_tail_x15_r0_body.kr1_163.flags = Stage.setAll PRE_first_tail_x15_r0_body.krC_163.flags (PRE_first_tail_x15_r0_body.cwS163.filterMap fun i => (PRE_first_tail_x15_r0_body.kr1_163.flags.get i).map (i, ·))
kernel_rfl PRE_first_tail_x15_r0_body.fkt1163 : PRE_first_tail_x15_r0_body.kr1_163.targs = Stage.setAll PRE_first_tail_x15_r0_body.krC_163.targs (PRE_first_tail_x15_r0_body.cwS163.filterMap fun i => (PRE_first_tail_x15_r0_body.kr1_163.targs.get i).map (i, ·))
kernel_rfl PRE_first_tail_x15_r0_body.fkck163 : krecLB PRE_first_tail_x15_r0_body.kappa163 7049 PRE_first_tail_x15_r0_body.cx0_163.mlx PRE_first_tail_x15_r0_body.kr0_163 PRE_first_tail_x15_r0_body.kr1_163 PRE_first_tail_x15_r0_body.clo163 = true
kernel_rfl PRE_first_tail_x15_r0_body.fkn163 : Nat.ble 7049 7049 = true
-- the bridge and the pending traces' regions
kernel_rfl PRE_first_tail_x15_r0_body.cbridge163 : Host.Ts.Sim.Full.bridgeOf PRE_first_tail_x15_r0_body.s1578.ffi = Host.Ts.Sim.Full.bridgeOf PRE_first_tail_x15_r0_body.s1579.ffi
kernel_rfl PRE_first_tail_x15_r0_body.cpendR163 : pendRegB PRE_first_tail_x15_r0_body.kappa163 (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1579.ffi).mlx = true
kernel_rfl PRE_first_tail_x15_r0_body.cpendLe163 : Nat.ble (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1579.ffi).mlx.next (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1578.ffi).mlx.next = true
/-- **The compaction's native shift**, given the call's bookkeeping, its relation's facts (the model's and the
observers') and the canonical closedness. -/
theorem PRE_first_tail_x15_r0_body.cshift163 (clean : Conv.NClean (⟨21414, 18525, 2802887, 7049⟩ : Conv.Cnt) (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1577.ffi).mlx) (hltC : ∀ h, PH (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1577.ffi).mlx h → h < (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1577.ffi).mlx.next) (nltC : ∀ i, PN (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1577.ffi).mlx i → i < (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1577.ffi).mlx.nnext) (itemsC : ∀ k v, (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1577.ffi).mlx.items.get k = some v → PN (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1577.ffi).mlx k) (tracedC : ∀ h o, (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1577.ffi).mlx.objs.get h = some o → ∀ i ∈ objTraces o, i < PRE_first_tail_x15_r0_body.P163.NL) (cl : SSt (· < 7049) PRE_first_tail_x15_r0_body.cx0_163.mlx)
    (hobjC : ∀ h, PRE_first_tail_x15_r0_body.fxC_163.get h = some () → ((Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1577.ffi).mlx.objs.get h).isSome = true)
    (hfC : ∀ h, (PRE_first_tail_x15_r0_body.krC_163.flags.get h).isSome = true → ((Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1577.ffi).mlx.objs.get h).isSome = true)
    (htC : ∀ h, (PRE_first_tail_x15_r0_body.krC_163.targs.get h).isSome = true → ((Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1577.ffi).mlx.objs.get h).isSome = true)
    (hclC : ∀ h l, PRE_first_tail_x15_r0_body.krC_163.targs.get h = some l → Host.Ts.Sim.Full.STargs (· < (⟨21414, 18525, 2802887, 7049⟩ : Conv.Cnt).n) l) :
    Conv.FullShiftQ PRE_first_tail_x15_r0_body.P163 7049 PRE_first_tail_x15_r0_body.kappa163 PRE_first_tail_x15_r0_body.s1579.ffi PRE_first_tail_x15_r0_body.s1578.ffi :=
  ⟨PRE_first_tail_x15_r0_body.cnshift163 clean hltC nltC itemsC tracedC cl, PRE_first_tail_x15_r0_body.cqueue163, fun t ht => bSN_sound (List.all_eq_true.mp PRE_first_tail_x15_r0_body.ctokSupp163 t ht),
    PRE_first_tail_x15_r0_body.cbridge163,
    liveShift_foot (x0' := Host.Ts.Sim.Full.mlxOf PRE_first_tail_x15_r0_body.s1579.ffi) (x1' := Host.Ts.Sim.Full.mlxOf PRE_first_tail_x15_r0_body.s1578.ffi) (PRE_first_tail_x15_r0_body.cfoot163 clean hltC nltC itemsC tracedC cl) rfl PRE_first_tail_x15_r0_body.ofx0_163 PRE_first_tail_x15_r0_body.ofx1_163 hobjC PRE_first_tail_x15_r0_body.ff0163 PRE_first_tail_x15_r0_body.ff1163 PRE_first_tail_x15_r0_body.ffck163,
    kernShift_foot (x0' := Host.Ts.Sim.Full.mlxOf PRE_first_tail_x15_r0_body.s1579.ffi) (x1' := Host.Ts.Sim.Full.mlxOf PRE_first_tail_x15_r0_body.s1578.ffi) (PRE_first_tail_x15_r0_body.cfoot163 clean hltC nltC itemsC tracedC cl) rfl PRE_first_tail_x15_r0_body.okr0_163 PRE_first_tail_x15_r0_body.okr1_163 (Nat.le_of_ble_eq_true PRE_first_tail_x15_r0_body.fkn163) hfC htC hclC
      PRE_first_tail_x15_r0_body.fkf0163 PRE_first_tail_x15_r0_body.fkt0163 PRE_first_tail_x15_r0_body.fkf1163 PRE_first_tail_x15_r0_body.fkt1163 PRE_first_tail_x15_r0_body.fkck163,
    pendReg_of rfl PRE_first_tail_x15_r0_body.cnh0163 PRE_first_tail_x15_r0_body.cnh1163 (Nat.le_of_ble_eq_true PRE_first_tail_x15_r0_body.cpendLe163) PRE_first_tail_x15_r0_body.cpendR163⟩

end Host.Load.Run.Tpl
