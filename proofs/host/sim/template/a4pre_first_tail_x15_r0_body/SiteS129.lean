import host.sim.template.a4pre_first_tail_x15_r0_body.SiteCl129
import host.sim.conv.CompactFull
import host.sim.template.FootGen
set_option Elab.async false
namespace Host.Load.Run.Tpl
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
open Host.Ts Host.Ts.Sim Host.Ts.Sim.Template

/-! The compaction's native shift at call site 129 from its footprint (`Conv.nshift_of_foot`), and the observers'
(`liveShift_foot`, `kernShift_foot`): `Conv.FullShiftQ` for `Conv.full_compactQ`, given the call's bookkeeping and its
relation's facts. -/

/-- The load parameters of the chain (band-free: its start's node counter as `NL` and `N0`). -/
def PRE_first_tail_x15_r0_body.Pc129 : LoadP := ⟨18151, 131072, 1099511627776, 15235, 15235, []⟩
/-- The site's band raised to the map's checked fixed-node prefix, including newly recorded closure traces. -/
def PRE_first_tail_x15_r0_body.P129 : LoadP := PRE_first_tail_x15_r0_body.Pc129.raise 17852
kernel_rfl PRE_first_tail_x15_r0_body.craise129 : Nat.ble PRE_first_tail_x15_r0_body.Pc129.N0 17852 = true
theorem PRE_first_tail_x15_r0_body.raised129 : Host.Ts.Sim.Full.Raised PRE_first_tail_x15_r0_body.Pc129 PRE_first_tail_x15_r0_body.P129 :=
  .inr ⟨17852, rfl, Nat.le_of_ble_eq_true PRE_first_tail_x15_r0_body.craise129, rfl⟩
noncomputable abbrev PRE_first_tail_x15_r0_body.cx0_129 : Host.Load.LSt := clearTokens (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1254.ffi)
noncomputable abbrev PRE_first_tail_x15_r0_body.cx1_129 : Host.Load.LSt := clearTokens (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1253.ffi)
def PRE_first_tail_x15_r0_body.khinv129 : PTrie Nat := Stage.setAll PTrie.nil [(20755, 20753), (20756, 20754), (20758, 20755), (20757, 20756)]
def PRE_first_tail_x15_r0_body.kninv129 : PTrie Nat := Stage.setAll PTrie.nil [(17846, 17846), (17847, 17847), (17848, 17848), (17849, 17849), (17850, 17850), (17851, 17851)]
/-- The stage's footprint: its written and fresh handles, fresh nodes, written and fresh items. -/
def PRE_first_tail_x15_r0_body.cwS129 : List Nat := [20753, 20754, 20755, 20756, 20757, 20758]
def PRE_first_tail_x15_r0_body.cnS129 : List Nat := List.range' 17846 6
def PRE_first_tail_x15_r0_body.ciS129 : List Nat := [] ++ List.range' 17846 6

-- the small checks (`MChecks`'s)
kernel_rfl PRE_first_tail_x15_r0_body.cnh0129 : PRE_first_tail_x15_r0_body.kd129.nh0 = PRE_first_tail_x15_r0_body.cx0_129.mlx.next
kernel_rfl PRE_first_tail_x15_r0_body.cnh1129 : PRE_first_tail_x15_r0_body.kd129.nh1 = PRE_first_tail_x15_r0_body.cx1_129.mlx.next
kernel_rfl PRE_first_tail_x15_r0_body.cnn0129 : PRE_first_tail_x15_r0_body.kd129.nn0 = PRE_first_tail_x15_r0_body.cx0_129.mlx.nnext
kernel_rfl PRE_first_tail_x15_r0_body.cnn1129 : PRE_first_tail_x15_r0_body.kd129.nn1 = PRE_first_tail_x15_r0_body.cx1_129.mlx.nnext
kernel_rfl PRE_first_tail_x15_r0_body.cplo129 : (Nat.blt 0 PRE_first_tail_x15_r0_body.P129.lo && Nat.ble PRE_first_tail_x15_r0_body.P129.lo PRE_first_tail_x15_r0_body.cx0_129.mlx.next && Nat.ble PRE_first_tail_x15_r0_body.P129.lo RData.bigHi && Nat.ble RData.bigHi PRE_first_tail_x15_r0_body.P129.E) = true
kernel_rfl PRE_first_tail_x15_r0_body.ccnt129 : (Nat.ble PRE_first_tail_x15_r0_body.cx0_129.mlx.next PRE_first_tail_x15_r0_body.cx1_129.mlx.next && Nat.ble PRE_first_tail_x15_r0_body.cx0_129.mlx.nnext PRE_first_tail_x15_r0_body.cx1_129.mlx.nnext) = true
kernel_rfl PRE_first_tail_x15_r0_body.cnband129 : (Nat.blt 0 PRE_first_tail_x15_r0_body.P129.NL && Nat.ble PRE_first_tail_x15_r0_body.P129.NL PRE_first_tail_x15_r0_body.P129.N0 && Nat.ble PRE_first_tail_x15_r0_body.P129.N0 PRE_first_tail_x15_r0_body.cx0_129.mlx.nnext) = true
kernel_rfl PRE_first_tail_x15_r0_body.chbelow129 : PRE_first_tail_x15_r0_body.kd129.checkHndBelow = true
kernel_rfl PRE_first_tail_x15_r0_body.chren129 : checkRenG PRE_first_tail_x15_r0_body.kd129.hnd PRE_first_tail_x15_r0_body.khinv129 (phB PRE_first_tail_x15_r0_body.cx0_129.mlx) = true
kernel_rfl PRE_first_tail_x15_r0_body.cband129 : PRE_first_tail_x15_r0_body.kd129.checkBand PRE_first_tail_x15_r0_body.P129.lo = true
kernel_rfl PRE_first_tail_x15_r0_body.cnh1pos129 : Nat.blt 0 PRE_first_tail_x15_r0_body.kd129.nh1 = true
kernel_rfl PRE_first_tail_x15_r0_body.cnren129 : checkRenG PRE_first_tail_x15_r0_body.kd129.node PRE_first_tail_x15_r0_body.kninv129 (pnB PRE_first_tail_x15_r0_body.cx0_129.mlx) = true
kernel_rfl PRE_first_tail_x15_r0_body.cnlow129 : (PTrie.keysA PRE_first_tail_x15_r0_body.kd129.node).all (fun j => Nat.ble PRE_first_tail_x15_r0_body.P129.NL j && Nat.blt (PRE_first_tail_x15_r0_body.kd129.nodeF j) PRE_first_tail_x15_r0_body.cx1_129.mlx.nnext) = true
kernel_rfl PRE_first_tail_x15_r0_body.cabs0a129 : PRE_first_tail_x15_r0_body.cx0_129.mlx.arrs.get 0 = none
kernel_rfl PRE_first_tail_x15_r0_body.cabs0b129 : PRE_first_tail_x15_r0_body.cx0_129.mlx.objs.get 0 = none
kernel_rfl PRE_first_tail_x15_r0_body.ctok1129 : PRE_first_tail_x15_r0_body.cx1_129.mlx.tokens = []
kernel_rfl PRE_first_tail_x15_r0_body.cpend129 : PRE_first_tail_x15_r0_body.cx1_129.mlx.pending = PRE_first_tail_x15_r0_body.cx0_129.mlx.pending.map PRE_first_tail_x15_r0_body.kappa129.pend
kernel_rfl PRE_first_tail_x15_r0_body.cerrh129 : PRE_first_tail_x15_r0_body.cx1_129.mlx.errh = PRE_first_tail_x15_r0_body.cx0_129.mlx.errh.map PRE_first_tail_x15_r0_body.kappa129.arg
kernel_rfl PRE_first_tail_x15_r0_body.cfiles129 : PRE_first_tail_x15_r0_body.cx1_129.mlx.files = PRE_first_tail_x15_r0_body.cx0_129.mlx.files
kernel_rfl PRE_first_tail_x15_r0_body.carch129 : PRE_first_tail_x15_r0_body.cx1_129.mlx.arch = PRE_first_tail_x15_r0_body.cx0_129.mlx.arch
kernel_rfl PRE_first_tail_x15_r0_body.csizes129 : PRE_first_tail_x15_r0_body.cx1_129.mlx.deviceSizes = PRE_first_tail_x15_r0_body.cx0_129.mlx.deviceSizes
kernel_rfl PRE_first_tail_x15_r0_body.cwired129 : PRE_first_tail_x15_r0_body.cx1_129.mlx.wired = PRE_first_tail_x15_r0_body.cx0_129.mlx.wired
kernel_rfl PRE_first_tail_x15_r0_body.chost129 : PRE_first_tail_x15_r0_body.cx1_129.host = PRE_first_tail_x15_r0_body.cx0_129.host
-- the compaction map's addresses are `PRE_first_tail_x15_r0_body.kd129`'s
kernel_rfl PRE_first_tail_x15_r0_body.ckn0129 : PRE_first_tail_x15_r0_body.kd129.n0 = 2776671
kernel_rfl PRE_first_tail_x15_r0_body.ckn1129 : PRE_first_tail_x15_r0_body.kd129.n1 = 2777021
kernel_rfl PRE_first_tail_x15_r0_body.ckheap129 : (PTrie.keysA PRE_first_tail_x15_r0_body.kd129.heap).all (fun x => Nat.ble 2776656 x) = true
kernel_rfl PRE_first_tail_x15_r0_body.ckpl129 : (List.range 15).all (fun j => decide (PRE_first_tail_x15_r0_body.kd129.heap.get (2776656 + j) = nth? PRE_first_tail_x15_r0_body.pl129 j)) = true
-- the map fixes the call's names (`Conv.fixOld_compact`), the call's counters
kernel_rfl PRE_first_tail_x15_r0_body.fja129 : Nat.ble 2776656 2776656 = true
kernel_rfl PRE_first_tail_x15_r0_body.fn129 : Nat.ble 5604 5604 = true
kernel_rfl PRE_first_tail_x15_r0_body.fjaD129 : Nat.ble 2776656 PRE_first_tail_x15_r0_body.kd129.n0 = true
kernel_rfl PRE_first_tail_x15_r0_body.fxn129 : Nat.ble 20753 PRE_first_tail_x15_r0_body.kd129.nh0 = true
kernel_rfl PRE_first_tail_x15_r0_body.fnn129 : Nat.ble 17846 PRE_first_tail_x15_r0_body.kd129.nn0 = true
kernel_rfl PRE_first_tail_x15_r0_body.fxb129 : Nat.ble 20753 RData.bigHi = true
kernel_rfl PRE_first_tail_x15_r0_body.fheap129 : (PTrie.keysA PRE_first_tail_x15_r0_body.kd129.heap).all (Nat.ble (⟨20753, 17846, 2776656, 5604⟩ : Conv.Cnt).ja) = true
kernel_rfl PRE_first_tail_x15_r0_body.fhnd129 : (PTrie.keysA PRE_first_tail_x15_r0_body.kd129.hnd).all (Nat.ble (⟨20753, 17846, 2776656, 5604⟩ : Conv.Cnt).xn) = true
kernel_rfl PRE_first_tail_x15_r0_body.fnode129 : (PTrie.keysA PRE_first_tail_x15_r0_body.kd129.node).all (Nat.ble (⟨20753, 17846, 2776656, 5604⟩ : Conv.Cnt).nn) = true
/-- The compaction map fixes the call's names. -/
theorem PRE_first_tail_x15_r0_body.cfix129 : Conv.FixOld (⟨20753, 17846, 2776656, 5604⟩ : Conv.Cnt) PRE_first_tail_x15_r0_body.kappa129 :=
  Conv.fixOld_compact (Nat.le_of_ble_eq_true PRE_first_tail_x15_r0_body.fja129) (Nat.le_of_ble_eq_true PRE_first_tail_x15_r0_body.fn129) (Nat.le_of_ble_eq_true PRE_first_tail_x15_r0_body.fjaD129) (Nat.le_of_ble_eq_true PRE_first_tail_x15_r0_body.fxn129) (Nat.le_of_ble_eq_true PRE_first_tail_x15_r0_body.fnn129) (Nat.le_of_ble_eq_true PRE_first_tail_x15_r0_body.fxb129) PRE_first_tail_x15_r0_body.fheap129 PRE_first_tail_x15_r0_body.fhnd129 PRE_first_tail_x15_r0_body.fnode129
kernel_rfl PRE_first_tail_x15_r0_body.fcxn129 : (⟨20753, 17846, 2776656, 5604⟩ : Conv.Cnt).xn = (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1252.ffi).mlx.next
kernel_rfl PRE_first_tail_x15_r0_body.fcnn129 : (⟨20753, 17846, 2776656, 5604⟩ : Conv.Cnt).nn = (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1252.ffi).mlx.nnext
kernel_rfl PRE_first_tail_x15_r0_body.fle0129 : (Nat.ble (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1252.ffi).mlx.next PRE_first_tail_x15_r0_body.cx0_129.mlx.next && Nat.ble (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1252.ffi).mlx.nnext PRE_first_tail_x15_r0_body.cx0_129.mlx.nnext && Nat.ble (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1252.ffi).mlx.next RData.bigHi) = true
kernel_rfl PRE_first_tail_x15_r0_body.fnk129 : (PTrie.keysA PRE_first_tail_x15_r0_body.kd129.node).all (Nat.ble (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1252.ffi).mlx.nnext) = true
-- the merged state keeps the call's entries off the stage's footprint
kernel_rfl PRE_first_tail_x15_r0_body.f1A129 : PRE_first_tail_x15_r0_body.cx1_129.mlx.arrs = Stage.setAll (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1252.ffi).mlx.arrs (PRE_first_tail_x15_r0_body.cwS129.filterMap fun i => (PRE_first_tail_x15_r0_body.cx1_129.mlx.arrs.get i).map (i, ·))
kernel_rfl PRE_first_tail_x15_r0_body.f1O129 : PRE_first_tail_x15_r0_body.cx1_129.mlx.objs = Stage.setAll (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1252.ffi).mlx.objs (PRE_first_tail_x15_r0_body.cwS129.filterMap fun i => (PRE_first_tail_x15_r0_body.cx1_129.mlx.objs.get i).map (i, ·))
kernel_rfl PRE_first_tail_x15_r0_body.f1N129 : PRE_first_tail_x15_r0_body.cx1_129.mlx.nodes = Stage.setAll (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1252.ffi).mlx.nodes (PRE_first_tail_x15_r0_body.cnS129.filterMap fun i => (PRE_first_tail_x15_r0_body.cx1_129.mlx.nodes.get i).map (i, ·))
kernel_rfl PRE_first_tail_x15_r0_body.f1I129 : PRE_first_tail_x15_r0_body.cx1_129.mlx.items = Stage.setAll (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1252.ffi).mlx.items (PRE_first_tail_x15_r0_body.ciS129.filterMap fun i => (PRE_first_tail_x15_r0_body.cx1_129.mlx.items.get i).map (i, ·))
kernel_rfl PRE_first_tail_x15_r0_body.fbd129 : (PRE_first_tail_x15_r0_body.clo129 ++ PRE_first_tail_x15_r0_body.cln129 ++ PRE_first_tail_x15_r0_body.cli129 ++ PRE_first_tail_x15_r0_body.cwS129 ++ PRE_first_tail_x15_r0_body.cnS129 ++ PRE_first_tail_x15_r0_body.ciS129).all (fun i => Nat.blt (i / 4096) (4 ^ 31)) = true
kernel_rfl PRE_first_tail_x15_r0_body.fincW129 : PRE_first_tail_x15_r0_body.cwS129.all (fun h => !Nat.blt h (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1252.ffi).mlx.next || PRE_first_tail_x15_r0_body.clo129.contains h) = true
kernel_rfl PRE_first_tail_x15_r0_body.fincI129 : PRE_first_tail_x15_r0_body.ciS129.all (fun k => !Nat.blt k (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1252.ffi).mlx.nnext || PRE_first_tail_x15_r0_body.cli129.contains k) = true
kernel_rfl PRE_first_tail_x15_r0_body.fincN129 : PRE_first_tail_x15_r0_body.cnS129.all (Nat.ble (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1252.ffi).mlx.nnext) = true
kernel_rfl PRE_first_tail_x15_r0_body.flnF129 : PRE_first_tail_x15_r0_body.cln129.all (Nat.ble (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1252.ffi).mlx.nnext) = true
-- the checks over the changed lists
kernel_rfl PRE_first_tail_x15_r0_body.fh129 : PRE_first_tail_x15_r0_body.clo129.all (handleOK PRE_first_tail_x15_r0_body.kappa129 PRE_first_tail_x15_r0_body.P129.lo PRE_first_tail_x15_r0_body.cx0_129.mlx PRE_first_tail_x15_r0_body.cx1_129.mlx) = true
kernel_rfl PRE_first_tail_x15_r0_body.fo129 : PRE_first_tail_x15_r0_body.clo129.map (fun h => PRE_first_tail_x15_r0_body.cx1_129.mlx.objs.get (PRE_first_tail_x15_r0_body.kappa129.handle h)) = PRE_first_tail_x15_r0_body.clo129.map (fun h => (PRE_first_tail_x15_r0_body.cx0_129.mlx.objs.get h).map PRE_first_tail_x15_r0_body.kappa129.nobj)
kernel_rfl PRE_first_tail_x15_r0_body.fok129 : PRE_first_tail_x15_r0_body.clo129.all (objOK PRE_first_tail_x15_r0_body.kappa129 PRE_first_tail_x15_r0_body.P129.NL PRE_first_tail_x15_r0_body.cx0_129.mlx) = true
kernel_rfl PRE_first_tail_x15_r0_body.fnd129 : PRE_first_tail_x15_r0_body.cln129.all (nodeOKF PRE_first_tail_x15_r0_body.kappa129 PRE_first_tail_x15_r0_body.P129 PRE_first_tail_x15_r0_body.cx0_129.mlx PRE_first_tail_x15_r0_body.cx1_129.mlx) = true
kernel_rfl PRE_first_tail_x15_r0_body.fp129 : ((PRE_first_tail_x15_r0_body.cln129.filter (fullB PRE_first_tail_x15_r0_body.P129))).map (fun i => (PRE_first_tail_x15_r0_body.cx1_129.mlx.nodes.get (PRE_first_tail_x15_r0_body.kappa129.node i)).map Host.Mlx.Ffi.Node.prim) =
  ((PRE_first_tail_x15_r0_body.cln129.filter (fullB PRE_first_tail_x15_r0_body.P129))).map (fun i => (PRE_first_tail_x15_r0_body.cx0_129.mlx.nodes.get i).map fun nd => PRE_first_tail_x15_r0_body.kappa129.prim nd.prim)
kernel_rfl PRE_first_tail_x15_r0_body.fnordI129 : incrB PRE_first_tail_x15_r0_body.kd129.nodeF (List.range' 17846 6) = true
kernel_rfl PRE_first_tail_x15_r0_body.fnordK129 : (PTrie.keysA PRE_first_tail_x15_r0_body.kd129.node).all (fun k => Nat.ble 17846 k && Nat.blt k 17852) = true
kernel_rfl PRE_first_tail_x15_r0_body.fnordL129 : (PRE_first_tail_x15_r0_body.cln129.filter (Nat.ble PRE_first_tail_x15_r0_body.P129.N0)).all (fun i => Nat.ble i (PRE_first_tail_x15_r0_body.kd129.nodeF i) && (Nat.blt i 17852 || Nat.ble PRE_first_tail_x15_r0_body.kd129.nn0 i)) = true
theorem PRE_first_tail_x15_r0_body.fnord129 : (PRE_first_tail_x15_r0_body.cln129.filter (Nat.ble PRE_first_tail_x15_r0_body.P129.N0)).all (fun i => Nat.ble i (PRE_first_tail_x15_r0_body.kd129.nodeF i) &&
    (PTrie.keysA PRE_first_tail_x15_r0_body.kd129.node).all fun j => !Nat.blt j i || Nat.blt (PRE_first_tail_x15_r0_body.kd129.nodeF j) (PRE_first_tail_x15_r0_body.kd129.nodeF i)) = true :=
  cnord_of PRE_first_tail_x15_r0_body.cnlow129 PRE_first_tail_x15_r0_body.cnn1129 PRE_first_tail_x15_r0_body.fnordI129 PRE_first_tail_x15_r0_body.fnordK129 PRE_first_tail_x15_r0_body.fnordL129
kernel_rfl PRE_first_tail_x15_r0_body.fi129 : PRE_first_tail_x15_r0_body.cli129.all (pnB PRE_first_tail_x15_r0_body.cx0_129.mlx) = true
kernel_rfl PRE_first_tail_x15_r0_body.fii129 : PRE_first_tail_x15_r0_body.cli129.all (fun k => decide (PRE_first_tail_x15_r0_body.cx1_129.mlx.items.get (PRE_first_tail_x15_r0_body.kappa129.node k) = (PRE_first_tail_x15_r0_body.cx0_129.mlx.items.get k).map PRE_first_tail_x15_r0_body.kappa129.nv)) = true
/-- **The compaction's footprint.** -/
theorem PRE_first_tail_x15_r0_body.cfoot129 (clean : Conv.NClean (⟨20753, 17846, 2776656, 5604⟩ : Conv.Cnt) (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1252.ffi).mlx) (hltC : ∀ h, PH (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1252.ffi).mlx h → h < (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1252.ffi).mlx.next) (nltC : ∀ i, PN (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1252.ffi).mlx i → i < (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1252.ffi).mlx.nnext) (itemsC : ∀ k v, (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1252.ffi).mlx.items.get k = some v → PN (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1252.ffi).mlx k) (tracedC : ∀ h o, (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1252.ffi).mlx.objs.get h = some o → ∀ i ∈ objTraces o, i < PRE_first_tail_x15_r0_body.P129.NL) (cl : SSt (· < 5613) PRE_first_tail_x15_r0_body.cx0_129.mlx) :
    Conv.MFoot PRE_first_tail_x15_r0_body.P129 5613 PRE_first_tail_x15_r0_body.kappa129 PRE_first_tail_x15_r0_body.kd129 PRE_first_tail_x15_r0_body.khinv129 PRE_first_tail_x15_r0_body.kninv129 (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1252.ffi).mlx PRE_first_tail_x15_r0_body.cx0_129.mlx PRE_first_tail_x15_r0_body.cx1_129.mlx (⟨20753, 17846, 2776656, 5604⟩ : Conv.Cnt) PRE_first_tail_x15_r0_body.clo129 PRE_first_tail_x15_r0_body.cln129 PRE_first_tail_x15_r0_body.cli129 PRE_first_tail_x15_r0_body.cwS129 PRE_first_tail_x15_r0_body.cnS129 PRE_first_tail_x15_r0_body.ciS129 :=
  ⟨rfl, rfl, rfl, PRE_first_tail_x15_r0_body.cnh0129, PRE_first_tail_x15_r0_body.cnh1129, PRE_first_tail_x15_r0_body.cnn0129, PRE_first_tail_x15_r0_body.cnn1129, PRE_first_tail_x15_r0_body.cplo129, PRE_first_tail_x15_r0_body.ccnt129, PRE_first_tail_x15_r0_body.cnband129, PRE_first_tail_x15_r0_body.chbelow129, PRE_first_tail_x15_r0_body.chren129, PRE_first_tail_x15_r0_body.cband129, PRE_first_tail_x15_r0_body.cnh1pos129, PRE_first_tail_x15_r0_body.cnren129, PRE_first_tail_x15_r0_body.cnlow129, PRE_first_tail_x15_r0_body.cabs0a129, PRE_first_tail_x15_r0_body.cabs0b129, PRE_first_tail_x15_r0_body.ctok1129, PRE_first_tail_x15_r0_body.cpend129, PRE_first_tail_x15_r0_body.cerrh129, PRE_first_tail_x15_r0_body.cfiles129, PRE_first_tail_x15_r0_body.carch129, PRE_first_tail_x15_r0_body.csizes129, PRE_first_tail_x15_r0_body.cwired129, PRE_first_tail_x15_r0_body.cfix129, clean, PRE_first_tail_x15_r0_body.fcxn129, PRE_first_tail_x15_r0_body.fcnn129, hltC, nltC, itemsC, tracedC, cl, PRE_first_tail_x15_r0_body.fle0129, PRE_first_tail_x15_r0_body.fnk129, PRE_first_tail_x15_r0_body.ckA129, PRE_first_tail_x15_r0_body.cobjsK129, PRE_first_tail_x15_r0_body.cnodesK129, PRE_first_tail_x15_r0_body.citemsK129, PRE_first_tail_x15_r0_body.f1A129, PRE_first_tail_x15_r0_body.f1O129, PRE_first_tail_x15_r0_body.f1N129, PRE_first_tail_x15_r0_body.f1I129, PRE_first_tail_x15_r0_body.fbd129, PRE_first_tail_x15_r0_body.fincW129, PRE_first_tail_x15_r0_body.fincI129, PRE_first_tail_x15_r0_body.fincN129, PRE_first_tail_x15_r0_body.flnF129, PRE_first_tail_x15_r0_body.fh129, PRE_first_tail_x15_r0_body.fo129, PRE_first_tail_x15_r0_body.fok129, PRE_first_tail_x15_r0_body.fnd129, PRE_first_tail_x15_r0_body.fp129, PRE_first_tail_x15_r0_body.fnord129, PRE_first_tail_x15_r0_body.fi129, PRE_first_tail_x15_r0_body.fii129⟩
theorem PRE_first_tail_x15_r0_body.cnshift129 (clean : Conv.NClean (⟨20753, 17846, 2776656, 5604⟩ : Conv.Cnt) (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1252.ffi).mlx) (hltC : ∀ h, PH (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1252.ffi).mlx h → h < (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1252.ffi).mlx.next) (nltC : ∀ i, PN (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1252.ffi).mlx i → i < (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1252.ffi).mlx.nnext) (itemsC : ∀ k v, (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1252.ffi).mlx.items.get k = some v → PN (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1252.ffi).mlx k) (tracedC : ∀ h o, (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1252.ffi).mlx.objs.get h = some o → ∀ i ∈ objTraces o, i < PRE_first_tail_x15_r0_body.P129.NL) (cl : SSt (· < 5613) PRE_first_tail_x15_r0_body.cx0_129.mlx) : NShift PRE_first_tail_x15_r0_body.P129 5613 PRE_first_tail_x15_r0_body.kappa129 PRE_first_tail_x15_r0_body.cx0_129 PRE_first_tail_x15_r0_body.cx1_129 :=
  Conv.nshift_of_foot (PRE_first_tail_x15_r0_body.cfoot129 clean hltC nltC itemsC tracedC cl) PRE_first_tail_x15_r0_body.chost129 (compact_a_eq PRE_first_tail_x15_r0_body.ckn0129 PRE_first_tail_x15_r0_body.ckn1129 PRE_first_tail_x15_r0_body.ckheap129 PRE_first_tail_x15_r0_body.ckpl129)

-- the observers: the layers' states at the call, the canonical and the merged state, their footprints and checks
noncomputable def PRE_first_tail_x15_r0_body.fxC_129 : PTrie Unit := (Host.Ts.Sim.Full.freedOf PRE_first_tail_x15_r0_body.s1252.ffi).getD PTrie.nil
noncomputable def PRE_first_tail_x15_r0_body.krC_129 : Host.Load.Layers.KRec := (Host.Ts.Sim.Full.krecOf PRE_first_tail_x15_r0_body.s1252.ffi).getD Host.Load.Layers.KRec.empty
kernel_rfl PRE_first_tail_x15_r0_body.ofxC_129 : (Host.Ts.Sim.Full.freedOf PRE_first_tail_x15_r0_body.s1252.ffi) = some PRE_first_tail_x15_r0_body.fxC_129
kernel_rfl PRE_first_tail_x15_r0_body.okrC_129 : (Host.Ts.Sim.Full.krecOf PRE_first_tail_x15_r0_body.s1252.ffi) = some PRE_first_tail_x15_r0_body.krC_129
noncomputable def PRE_first_tail_x15_r0_body.fx0_129 : PTrie Unit := (Host.Ts.Sim.Full.freedOf PRE_first_tail_x15_r0_body.s1254.ffi).getD PTrie.nil
noncomputable def PRE_first_tail_x15_r0_body.kr0_129 : Host.Load.Layers.KRec := (Host.Ts.Sim.Full.krecOf PRE_first_tail_x15_r0_body.s1254.ffi).getD Host.Load.Layers.KRec.empty
kernel_rfl PRE_first_tail_x15_r0_body.ofx0_129 : (Host.Ts.Sim.Full.freedOf PRE_first_tail_x15_r0_body.s1254.ffi) = some PRE_first_tail_x15_r0_body.fx0_129
kernel_rfl PRE_first_tail_x15_r0_body.okr0_129 : (Host.Ts.Sim.Full.krecOf PRE_first_tail_x15_r0_body.s1254.ffi) = some PRE_first_tail_x15_r0_body.kr0_129
noncomputable def PRE_first_tail_x15_r0_body.fx1_129 : PTrie Unit := (Host.Ts.Sim.Full.freedOf PRE_first_tail_x15_r0_body.s1253.ffi).getD PTrie.nil
noncomputable def PRE_first_tail_x15_r0_body.kr1_129 : Host.Load.Layers.KRec := (Host.Ts.Sim.Full.krecOf PRE_first_tail_x15_r0_body.s1253.ffi).getD Host.Load.Layers.KRec.empty
kernel_rfl PRE_first_tail_x15_r0_body.ofx1_129 : (Host.Ts.Sim.Full.freedOf PRE_first_tail_x15_r0_body.s1253.ffi) = some PRE_first_tail_x15_r0_body.fx1_129
kernel_rfl PRE_first_tail_x15_r0_body.okr1_129 : (Host.Ts.Sim.Full.krecOf PRE_first_tail_x15_r0_body.s1253.ffi) = some PRE_first_tail_x15_r0_body.kr1_129
kernel_rfl PRE_first_tail_x15_r0_body.ff0129 : PRE_first_tail_x15_r0_body.fx0_129 = Stage.setAll PRE_first_tail_x15_r0_body.fxC_129 (PRE_first_tail_x15_r0_body.clo129.filterMap fun i => (PRE_first_tail_x15_r0_body.fx0_129.get i).map (i, ·))
kernel_rfl PRE_first_tail_x15_r0_body.ff1129 : PRE_first_tail_x15_r0_body.fx1_129 = Stage.setAll PRE_first_tail_x15_r0_body.fxC_129 (PRE_first_tail_x15_r0_body.cwS129.filterMap fun i => (PRE_first_tail_x15_r0_body.fx1_129.get i).map (i, ·))
kernel_rfl PRE_first_tail_x15_r0_body.ffck129 : freedLB PRE_first_tail_x15_r0_body.kappa129 PRE_first_tail_x15_r0_body.cx0_129.mlx PRE_first_tail_x15_r0_body.fx0_129 PRE_first_tail_x15_r0_body.fx1_129 PRE_first_tail_x15_r0_body.clo129 = true
kernel_rfl PRE_first_tail_x15_r0_body.fkf0129 : PRE_first_tail_x15_r0_body.kr0_129.flags = Stage.setAll PRE_first_tail_x15_r0_body.krC_129.flags (PRE_first_tail_x15_r0_body.clo129.filterMap fun i => (PRE_first_tail_x15_r0_body.kr0_129.flags.get i).map (i, ·))
kernel_rfl PRE_first_tail_x15_r0_body.fkt0129 : PRE_first_tail_x15_r0_body.kr0_129.targs = Stage.setAll PRE_first_tail_x15_r0_body.krC_129.targs (PRE_first_tail_x15_r0_body.clo129.filterMap fun i => (PRE_first_tail_x15_r0_body.kr0_129.targs.get i).map (i, ·))
kernel_rfl PRE_first_tail_x15_r0_body.fkf1129 : PRE_first_tail_x15_r0_body.kr1_129.flags = Stage.setAll PRE_first_tail_x15_r0_body.krC_129.flags (PRE_first_tail_x15_r0_body.cwS129.filterMap fun i => (PRE_first_tail_x15_r0_body.kr1_129.flags.get i).map (i, ·))
kernel_rfl PRE_first_tail_x15_r0_body.fkt1129 : PRE_first_tail_x15_r0_body.kr1_129.targs = Stage.setAll PRE_first_tail_x15_r0_body.krC_129.targs (PRE_first_tail_x15_r0_body.cwS129.filterMap fun i => (PRE_first_tail_x15_r0_body.kr1_129.targs.get i).map (i, ·))
kernel_rfl PRE_first_tail_x15_r0_body.fkck129 : krecLB PRE_first_tail_x15_r0_body.kappa129 5613 PRE_first_tail_x15_r0_body.cx0_129.mlx PRE_first_tail_x15_r0_body.kr0_129 PRE_first_tail_x15_r0_body.kr1_129 PRE_first_tail_x15_r0_body.clo129 = true
kernel_rfl PRE_first_tail_x15_r0_body.fkn129 : Nat.ble 5604 5613 = true
-- the bridge and the pending traces' regions
kernel_rfl PRE_first_tail_x15_r0_body.cbridge129 : Host.Ts.Sim.Full.bridgeOf PRE_first_tail_x15_r0_body.s1253.ffi = Host.Ts.Sim.Full.bridgeOf PRE_first_tail_x15_r0_body.s1254.ffi
kernel_rfl PRE_first_tail_x15_r0_body.cpendR129 : pendRegB PRE_first_tail_x15_r0_body.kappa129 (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1254.ffi).mlx = true
kernel_rfl PRE_first_tail_x15_r0_body.cpendLe129 : Nat.ble (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1254.ffi).mlx.next (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1253.ffi).mlx.next = true
/-- **The compaction's native shift**, given the call's bookkeeping, its relation's facts (the model's and the
observers') and the canonical closedness. -/
theorem PRE_first_tail_x15_r0_body.cshift129 (clean : Conv.NClean (⟨20753, 17846, 2776656, 5604⟩ : Conv.Cnt) (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1252.ffi).mlx) (hltC : ∀ h, PH (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1252.ffi).mlx h → h < (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1252.ffi).mlx.next) (nltC : ∀ i, PN (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1252.ffi).mlx i → i < (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1252.ffi).mlx.nnext) (itemsC : ∀ k v, (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1252.ffi).mlx.items.get k = some v → PN (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1252.ffi).mlx k) (tracedC : ∀ h o, (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1252.ffi).mlx.objs.get h = some o → ∀ i ∈ objTraces o, i < PRE_first_tail_x15_r0_body.P129.NL) (cl : SSt (· < 5613) PRE_first_tail_x15_r0_body.cx0_129.mlx)
    (hobjC : ∀ h, PRE_first_tail_x15_r0_body.fxC_129.get h = some () → ((Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1252.ffi).mlx.objs.get h).isSome = true)
    (hfC : ∀ h, (PRE_first_tail_x15_r0_body.krC_129.flags.get h).isSome = true → ((Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1252.ffi).mlx.objs.get h).isSome = true)
    (htC : ∀ h, (PRE_first_tail_x15_r0_body.krC_129.targs.get h).isSome = true → ((Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1252.ffi).mlx.objs.get h).isSome = true)
    (hclC : ∀ h l, PRE_first_tail_x15_r0_body.krC_129.targs.get h = some l → Host.Ts.Sim.Full.STargs (· < (⟨20753, 17846, 2776656, 5604⟩ : Conv.Cnt).n) l) :
    Conv.FullShiftQ PRE_first_tail_x15_r0_body.P129 5613 PRE_first_tail_x15_r0_body.kappa129 PRE_first_tail_x15_r0_body.s1254.ffi PRE_first_tail_x15_r0_body.s1253.ffi :=
  ⟨PRE_first_tail_x15_r0_body.cnshift129 clean hltC nltC itemsC tracedC cl, PRE_first_tail_x15_r0_body.cqueue129, fun t ht => bSN_sound (List.all_eq_true.mp PRE_first_tail_x15_r0_body.ctokSupp129 t ht),
    PRE_first_tail_x15_r0_body.cbridge129,
    liveShift_foot (x0' := Host.Ts.Sim.Full.mlxOf PRE_first_tail_x15_r0_body.s1254.ffi) (x1' := Host.Ts.Sim.Full.mlxOf PRE_first_tail_x15_r0_body.s1253.ffi) (PRE_first_tail_x15_r0_body.cfoot129 clean hltC nltC itemsC tracedC cl) rfl PRE_first_tail_x15_r0_body.ofx0_129 PRE_first_tail_x15_r0_body.ofx1_129 hobjC PRE_first_tail_x15_r0_body.ff0129 PRE_first_tail_x15_r0_body.ff1129 PRE_first_tail_x15_r0_body.ffck129,
    kernShift_foot (x0' := Host.Ts.Sim.Full.mlxOf PRE_first_tail_x15_r0_body.s1254.ffi) (x1' := Host.Ts.Sim.Full.mlxOf PRE_first_tail_x15_r0_body.s1253.ffi) (PRE_first_tail_x15_r0_body.cfoot129 clean hltC nltC itemsC tracedC cl) rfl PRE_first_tail_x15_r0_body.okr0_129 PRE_first_tail_x15_r0_body.okr1_129 (Nat.le_of_ble_eq_true PRE_first_tail_x15_r0_body.fkn129) hfC htC hclC
      PRE_first_tail_x15_r0_body.fkf0129 PRE_first_tail_x15_r0_body.fkt0129 PRE_first_tail_x15_r0_body.fkf1129 PRE_first_tail_x15_r0_body.fkt1129 PRE_first_tail_x15_r0_body.fkck129,
    pendReg_of rfl PRE_first_tail_x15_r0_body.cnh0129 PRE_first_tail_x15_r0_body.cnh1129 (Nat.le_of_ble_eq_true PRE_first_tail_x15_r0_body.cpendLe129) PRE_first_tail_x15_r0_body.cpendR129⟩

end Host.Load.Run.Tpl
