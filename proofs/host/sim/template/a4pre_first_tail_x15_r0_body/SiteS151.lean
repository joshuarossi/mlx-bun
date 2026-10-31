import host.sim.template.a4pre_first_tail_x15_r0_body.SiteCl151
import host.sim.conv.CompactFull
import host.sim.template.FootGen
set_option Elab.async false
namespace Host.Load.Run.Tpl
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
open Host.Ts Host.Ts.Sim Host.Ts.Sim.Template

/-! The compaction's native shift at call site 151 from its footprint (`Conv.nshift_of_foot`), and the observers'
(`liveShift_foot`, `kernShift_foot`): `Conv.FullShiftQ` for `Conv.full_compactQ`, given the call's bookkeeping and its
relation's facts. -/

/-- The load parameters of the chain (band-free: its start's node counter as `NL` and `N0`). -/
def PRE_first_tail_x15_r0_body.Pc151 : LoadP := ⟨18151, 131072, 1099511627776, 15235, 15235, []⟩
/-- The site's band raised to the map's checked fixed-node prefix, including newly recorded closure traces. -/
def PRE_first_tail_x15_r0_body.P151 : LoadP := PRE_first_tail_x15_r0_body.Pc151.raise 18288
kernel_rfl PRE_first_tail_x15_r0_body.craise151 : Nat.ble PRE_first_tail_x15_r0_body.Pc151.N0 18288 = true
theorem PRE_first_tail_x15_r0_body.raised151 : Host.Ts.Sim.Full.Raised PRE_first_tail_x15_r0_body.Pc151 PRE_first_tail_x15_r0_body.P151 :=
  .inr ⟨18288, rfl, Nat.le_of_ble_eq_true PRE_first_tail_x15_r0_body.craise151, rfl⟩
noncomputable abbrev PRE_first_tail_x15_r0_body.cx0_151 : Host.Load.LSt := clearTokens (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1337.ffi)
noncomputable abbrev PRE_first_tail_x15_r0_body.cx1_151 : Host.Load.LSt := clearTokens (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1336.ffi)
def PRE_first_tail_x15_r0_body.khinv151 : PTrie Nat := Stage.setAll PTrie.nil []
def PRE_first_tail_x15_r0_body.kninv151 : PTrie Nat := Stage.setAll PTrie.nil []
/-- The stage's footprint: its written and fresh handles, fresh nodes, written and fresh items. -/
def PRE_first_tail_x15_r0_body.cwS151 : List Nat := []
def PRE_first_tail_x15_r0_body.cnS151 : List Nat := List.range' 18288 0
def PRE_first_tail_x15_r0_body.ciS151 : List Nat := [] ++ List.range' 18288 0

-- the small checks (`MChecks`'s)
kernel_rfl PRE_first_tail_x15_r0_body.cnh0151 : PRE_first_tail_x15_r0_body.kd151.nh0 = PRE_first_tail_x15_r0_body.cx0_151.mlx.next
kernel_rfl PRE_first_tail_x15_r0_body.cnh1151 : PRE_first_tail_x15_r0_body.kd151.nh1 = PRE_first_tail_x15_r0_body.cx1_151.mlx.next
kernel_rfl PRE_first_tail_x15_r0_body.cnn0151 : PRE_first_tail_x15_r0_body.kd151.nn0 = PRE_first_tail_x15_r0_body.cx0_151.mlx.nnext
kernel_rfl PRE_first_tail_x15_r0_body.cnn1151 : PRE_first_tail_x15_r0_body.kd151.nn1 = PRE_first_tail_x15_r0_body.cx1_151.mlx.nnext
kernel_rfl PRE_first_tail_x15_r0_body.cplo151 : (Nat.blt 0 PRE_first_tail_x15_r0_body.P151.lo && Nat.ble PRE_first_tail_x15_r0_body.P151.lo PRE_first_tail_x15_r0_body.cx0_151.mlx.next && Nat.ble PRE_first_tail_x15_r0_body.P151.lo RData.bigHi && Nat.ble RData.bigHi PRE_first_tail_x15_r0_body.P151.E) = true
kernel_rfl PRE_first_tail_x15_r0_body.ccnt151 : (Nat.ble PRE_first_tail_x15_r0_body.cx0_151.mlx.next PRE_first_tail_x15_r0_body.cx1_151.mlx.next && Nat.ble PRE_first_tail_x15_r0_body.cx0_151.mlx.nnext PRE_first_tail_x15_r0_body.cx1_151.mlx.nnext) = true
kernel_rfl PRE_first_tail_x15_r0_body.cnband151 : (Nat.blt 0 PRE_first_tail_x15_r0_body.P151.NL && Nat.ble PRE_first_tail_x15_r0_body.P151.NL PRE_first_tail_x15_r0_body.P151.N0 && Nat.ble PRE_first_tail_x15_r0_body.P151.N0 PRE_first_tail_x15_r0_body.cx0_151.mlx.nnext) = true
kernel_rfl PRE_first_tail_x15_r0_body.chbelow151 : PRE_first_tail_x15_r0_body.kd151.checkHndBelow = true
kernel_rfl PRE_first_tail_x15_r0_body.chren151 : checkRenG PRE_first_tail_x15_r0_body.kd151.hnd PRE_first_tail_x15_r0_body.khinv151 (phB PRE_first_tail_x15_r0_body.cx0_151.mlx) = true
kernel_rfl PRE_first_tail_x15_r0_body.cband151 : PRE_first_tail_x15_r0_body.kd151.checkBand PRE_first_tail_x15_r0_body.P151.lo = true
kernel_rfl PRE_first_tail_x15_r0_body.cnh1pos151 : Nat.blt 0 PRE_first_tail_x15_r0_body.kd151.nh1 = true
kernel_rfl PRE_first_tail_x15_r0_body.cnren151 : checkRenG PRE_first_tail_x15_r0_body.kd151.node PRE_first_tail_x15_r0_body.kninv151 (pnB PRE_first_tail_x15_r0_body.cx0_151.mlx) = true
kernel_rfl PRE_first_tail_x15_r0_body.cnlow151 : (PTrie.keysA PRE_first_tail_x15_r0_body.kd151.node).all (fun j => Nat.ble PRE_first_tail_x15_r0_body.P151.NL j && Nat.blt (PRE_first_tail_x15_r0_body.kd151.nodeF j) PRE_first_tail_x15_r0_body.cx1_151.mlx.nnext) = true
kernel_rfl PRE_first_tail_x15_r0_body.cabs0a151 : PRE_first_tail_x15_r0_body.cx0_151.mlx.arrs.get 0 = none
kernel_rfl PRE_first_tail_x15_r0_body.cabs0b151 : PRE_first_tail_x15_r0_body.cx0_151.mlx.objs.get 0 = none
kernel_rfl PRE_first_tail_x15_r0_body.ctok1151 : PRE_first_tail_x15_r0_body.cx1_151.mlx.tokens = []
kernel_rfl PRE_first_tail_x15_r0_body.cpend151 : PRE_first_tail_x15_r0_body.cx1_151.mlx.pending = PRE_first_tail_x15_r0_body.cx0_151.mlx.pending.map PRE_first_tail_x15_r0_body.kappa151.pend
kernel_rfl PRE_first_tail_x15_r0_body.cerrh151 : PRE_first_tail_x15_r0_body.cx1_151.mlx.errh = PRE_first_tail_x15_r0_body.cx0_151.mlx.errh.map PRE_first_tail_x15_r0_body.kappa151.arg
kernel_rfl PRE_first_tail_x15_r0_body.cfiles151 : PRE_first_tail_x15_r0_body.cx1_151.mlx.files = PRE_first_tail_x15_r0_body.cx0_151.mlx.files
kernel_rfl PRE_first_tail_x15_r0_body.carch151 : PRE_first_tail_x15_r0_body.cx1_151.mlx.arch = PRE_first_tail_x15_r0_body.cx0_151.mlx.arch
kernel_rfl PRE_first_tail_x15_r0_body.csizes151 : PRE_first_tail_x15_r0_body.cx1_151.mlx.deviceSizes = PRE_first_tail_x15_r0_body.cx0_151.mlx.deviceSizes
kernel_rfl PRE_first_tail_x15_r0_body.cwired151 : PRE_first_tail_x15_r0_body.cx1_151.mlx.wired = PRE_first_tail_x15_r0_body.cx0_151.mlx.wired
kernel_rfl PRE_first_tail_x15_r0_body.chost151 : PRE_first_tail_x15_r0_body.cx1_151.host = PRE_first_tail_x15_r0_body.cx0_151.host
-- the compaction map's addresses are `PRE_first_tail_x15_r0_body.kd151`'s
kernel_rfl PRE_first_tail_x15_r0_body.ckn0151 : PRE_first_tail_x15_r0_body.kd151.n0 = 2793475
kernel_rfl PRE_first_tail_x15_r0_body.ckn1151 : PRE_first_tail_x15_r0_body.kd151.n1 = 2793477
kernel_rfl PRE_first_tail_x15_r0_body.ckheap151 : (PTrie.keysA PRE_first_tail_x15_r0_body.kd151.heap).all (fun x => Nat.ble 2793475 x) = true
kernel_rfl PRE_first_tail_x15_r0_body.ckpl151 : (List.range 0).all (fun j => decide (PRE_first_tail_x15_r0_body.kd151.heap.get (2793475 + j) = nth? PRE_first_tail_x15_r0_body.pl151 j)) = true
-- the map fixes the call's names (`Conv.fixOld_compact`), the call's counters
kernel_rfl PRE_first_tail_x15_r0_body.fja151 : Nat.ble 2793475 2793475 = true
kernel_rfl PRE_first_tail_x15_r0_body.fn151 : Nat.ble 6536 6536 = true
kernel_rfl PRE_first_tail_x15_r0_body.fjaD151 : Nat.ble 2793475 PRE_first_tail_x15_r0_body.kd151.n0 = true
kernel_rfl PRE_first_tail_x15_r0_body.fxn151 : Nat.ble 21178 PRE_first_tail_x15_r0_body.kd151.nh0 = true
kernel_rfl PRE_first_tail_x15_r0_body.fnn151 : Nat.ble 18288 PRE_first_tail_x15_r0_body.kd151.nn0 = true
kernel_rfl PRE_first_tail_x15_r0_body.fxb151 : Nat.ble 21178 RData.bigHi = true
kernel_rfl PRE_first_tail_x15_r0_body.fheap151 : (PTrie.keysA PRE_first_tail_x15_r0_body.kd151.heap).all (Nat.ble (⟨21178, 18288, 2793475, 6536⟩ : Conv.Cnt).ja) = true
kernel_rfl PRE_first_tail_x15_r0_body.fhnd151 : (PTrie.keysA PRE_first_tail_x15_r0_body.kd151.hnd).all (Nat.ble (⟨21178, 18288, 2793475, 6536⟩ : Conv.Cnt).xn) = true
kernel_rfl PRE_first_tail_x15_r0_body.fnode151 : (PTrie.keysA PRE_first_tail_x15_r0_body.kd151.node).all (Nat.ble (⟨21178, 18288, 2793475, 6536⟩ : Conv.Cnt).nn) = true
/-- The compaction map fixes the call's names. -/
theorem PRE_first_tail_x15_r0_body.cfix151 : Conv.FixOld (⟨21178, 18288, 2793475, 6536⟩ : Conv.Cnt) PRE_first_tail_x15_r0_body.kappa151 :=
  Conv.fixOld_compact (Nat.le_of_ble_eq_true PRE_first_tail_x15_r0_body.fja151) (Nat.le_of_ble_eq_true PRE_first_tail_x15_r0_body.fn151) (Nat.le_of_ble_eq_true PRE_first_tail_x15_r0_body.fjaD151) (Nat.le_of_ble_eq_true PRE_first_tail_x15_r0_body.fxn151) (Nat.le_of_ble_eq_true PRE_first_tail_x15_r0_body.fnn151) (Nat.le_of_ble_eq_true PRE_first_tail_x15_r0_body.fxb151) PRE_first_tail_x15_r0_body.fheap151 PRE_first_tail_x15_r0_body.fhnd151 PRE_first_tail_x15_r0_body.fnode151
kernel_rfl PRE_first_tail_x15_r0_body.fcxn151 : (⟨21178, 18288, 2793475, 6536⟩ : Conv.Cnt).xn = (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1335.ffi).mlx.next
kernel_rfl PRE_first_tail_x15_r0_body.fcnn151 : (⟨21178, 18288, 2793475, 6536⟩ : Conv.Cnt).nn = (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1335.ffi).mlx.nnext
kernel_rfl PRE_first_tail_x15_r0_body.fle0151 : (Nat.ble (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1335.ffi).mlx.next PRE_first_tail_x15_r0_body.cx0_151.mlx.next && Nat.ble (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1335.ffi).mlx.nnext PRE_first_tail_x15_r0_body.cx0_151.mlx.nnext && Nat.ble (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1335.ffi).mlx.next RData.bigHi) = true
kernel_rfl PRE_first_tail_x15_r0_body.fnk151 : (PTrie.keysA PRE_first_tail_x15_r0_body.kd151.node).all (Nat.ble (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1335.ffi).mlx.nnext) = true
-- the merged state keeps the call's entries off the stage's footprint
kernel_rfl PRE_first_tail_x15_r0_body.f1A151 : PRE_first_tail_x15_r0_body.cx1_151.mlx.arrs = Stage.setAll (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1335.ffi).mlx.arrs (PRE_first_tail_x15_r0_body.cwS151.filterMap fun i => (PRE_first_tail_x15_r0_body.cx1_151.mlx.arrs.get i).map (i, ·))
kernel_rfl PRE_first_tail_x15_r0_body.f1O151 : PRE_first_tail_x15_r0_body.cx1_151.mlx.objs = Stage.setAll (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1335.ffi).mlx.objs (PRE_first_tail_x15_r0_body.cwS151.filterMap fun i => (PRE_first_tail_x15_r0_body.cx1_151.mlx.objs.get i).map (i, ·))
kernel_rfl PRE_first_tail_x15_r0_body.f1N151 : PRE_first_tail_x15_r0_body.cx1_151.mlx.nodes = Stage.setAll (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1335.ffi).mlx.nodes (PRE_first_tail_x15_r0_body.cnS151.filterMap fun i => (PRE_first_tail_x15_r0_body.cx1_151.mlx.nodes.get i).map (i, ·))
kernel_rfl PRE_first_tail_x15_r0_body.f1I151 : PRE_first_tail_x15_r0_body.cx1_151.mlx.items = Stage.setAll (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1335.ffi).mlx.items (PRE_first_tail_x15_r0_body.ciS151.filterMap fun i => (PRE_first_tail_x15_r0_body.cx1_151.mlx.items.get i).map (i, ·))
kernel_rfl PRE_first_tail_x15_r0_body.fbd151 : (PRE_first_tail_x15_r0_body.clo151 ++ PRE_first_tail_x15_r0_body.cln151 ++ PRE_first_tail_x15_r0_body.cli151 ++ PRE_first_tail_x15_r0_body.cwS151 ++ PRE_first_tail_x15_r0_body.cnS151 ++ PRE_first_tail_x15_r0_body.ciS151).all (fun i => Nat.blt (i / 4096) (4 ^ 31)) = true
kernel_rfl PRE_first_tail_x15_r0_body.fincW151 : PRE_first_tail_x15_r0_body.cwS151.all (fun h => !Nat.blt h (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1335.ffi).mlx.next || PRE_first_tail_x15_r0_body.clo151.contains h) = true
kernel_rfl PRE_first_tail_x15_r0_body.fincI151 : PRE_first_tail_x15_r0_body.ciS151.all (fun k => !Nat.blt k (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1335.ffi).mlx.nnext || PRE_first_tail_x15_r0_body.cli151.contains k) = true
kernel_rfl PRE_first_tail_x15_r0_body.fincN151 : PRE_first_tail_x15_r0_body.cnS151.all (Nat.ble (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1335.ffi).mlx.nnext) = true
kernel_rfl PRE_first_tail_x15_r0_body.flnF151 : PRE_first_tail_x15_r0_body.cln151.all (Nat.ble (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1335.ffi).mlx.nnext) = true
-- the checks over the changed lists
kernel_rfl PRE_first_tail_x15_r0_body.fh151 : PRE_first_tail_x15_r0_body.clo151.all (handleOK PRE_first_tail_x15_r0_body.kappa151 PRE_first_tail_x15_r0_body.P151.lo PRE_first_tail_x15_r0_body.cx0_151.mlx PRE_first_tail_x15_r0_body.cx1_151.mlx) = true
kernel_rfl PRE_first_tail_x15_r0_body.fo151 : PRE_first_tail_x15_r0_body.clo151.map (fun h => PRE_first_tail_x15_r0_body.cx1_151.mlx.objs.get (PRE_first_tail_x15_r0_body.kappa151.handle h)) = PRE_first_tail_x15_r0_body.clo151.map (fun h => (PRE_first_tail_x15_r0_body.cx0_151.mlx.objs.get h).map PRE_first_tail_x15_r0_body.kappa151.nobj)
kernel_rfl PRE_first_tail_x15_r0_body.fok151 : PRE_first_tail_x15_r0_body.clo151.all (objOK PRE_first_tail_x15_r0_body.kappa151 PRE_first_tail_x15_r0_body.P151.NL PRE_first_tail_x15_r0_body.cx0_151.mlx) = true
kernel_rfl PRE_first_tail_x15_r0_body.fnd151 : PRE_first_tail_x15_r0_body.cln151.all (nodeOKF PRE_first_tail_x15_r0_body.kappa151 PRE_first_tail_x15_r0_body.P151 PRE_first_tail_x15_r0_body.cx0_151.mlx PRE_first_tail_x15_r0_body.cx1_151.mlx) = true
kernel_rfl PRE_first_tail_x15_r0_body.fp151 : ((PRE_first_tail_x15_r0_body.cln151.filter (fullB PRE_first_tail_x15_r0_body.P151))).map (fun i => (PRE_first_tail_x15_r0_body.cx1_151.mlx.nodes.get (PRE_first_tail_x15_r0_body.kappa151.node i)).map Host.Mlx.Ffi.Node.prim) =
  ((PRE_first_tail_x15_r0_body.cln151.filter (fullB PRE_first_tail_x15_r0_body.P151))).map (fun i => (PRE_first_tail_x15_r0_body.cx0_151.mlx.nodes.get i).map fun nd => PRE_first_tail_x15_r0_body.kappa151.prim nd.prim)
kernel_rfl PRE_first_tail_x15_r0_body.fnordI151 : incrB PRE_first_tail_x15_r0_body.kd151.nodeF (List.range' 18288 0) = true
kernel_rfl PRE_first_tail_x15_r0_body.fnordK151 : (PTrie.keysA PRE_first_tail_x15_r0_body.kd151.node).all (fun k => Nat.ble 18288 k && Nat.blt k 18288) = true
kernel_rfl PRE_first_tail_x15_r0_body.fnordL151 : (PRE_first_tail_x15_r0_body.cln151.filter (Nat.ble PRE_first_tail_x15_r0_body.P151.N0)).all (fun i => Nat.ble i (PRE_first_tail_x15_r0_body.kd151.nodeF i) && (Nat.blt i 18288 || Nat.ble PRE_first_tail_x15_r0_body.kd151.nn0 i)) = true
theorem PRE_first_tail_x15_r0_body.fnord151 : (PRE_first_tail_x15_r0_body.cln151.filter (Nat.ble PRE_first_tail_x15_r0_body.P151.N0)).all (fun i => Nat.ble i (PRE_first_tail_x15_r0_body.kd151.nodeF i) &&
    (PTrie.keysA PRE_first_tail_x15_r0_body.kd151.node).all fun j => !Nat.blt j i || Nat.blt (PRE_first_tail_x15_r0_body.kd151.nodeF j) (PRE_first_tail_x15_r0_body.kd151.nodeF i)) = true :=
  cnord_of PRE_first_tail_x15_r0_body.cnlow151 PRE_first_tail_x15_r0_body.cnn1151 PRE_first_tail_x15_r0_body.fnordI151 PRE_first_tail_x15_r0_body.fnordK151 PRE_first_tail_x15_r0_body.fnordL151
kernel_rfl PRE_first_tail_x15_r0_body.fi151 : PRE_first_tail_x15_r0_body.cli151.all (pnB PRE_first_tail_x15_r0_body.cx0_151.mlx) = true
kernel_rfl PRE_first_tail_x15_r0_body.fii151 : PRE_first_tail_x15_r0_body.cli151.all (fun k => decide (PRE_first_tail_x15_r0_body.cx1_151.mlx.items.get (PRE_first_tail_x15_r0_body.kappa151.node k) = (PRE_first_tail_x15_r0_body.cx0_151.mlx.items.get k).map PRE_first_tail_x15_r0_body.kappa151.nv)) = true
/-- **The compaction's footprint.** -/
theorem PRE_first_tail_x15_r0_body.cfoot151 (clean : Conv.NClean (⟨21178, 18288, 2793475, 6536⟩ : Conv.Cnt) (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1335.ffi).mlx) (hltC : ∀ h, PH (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1335.ffi).mlx h → h < (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1335.ffi).mlx.next) (nltC : ∀ i, PN (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1335.ffi).mlx i → i < (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1335.ffi).mlx.nnext) (itemsC : ∀ k v, (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1335.ffi).mlx.items.get k = some v → PN (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1335.ffi).mlx k) (tracedC : ∀ h o, (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1335.ffi).mlx.objs.get h = some o → ∀ i ∈ objTraces o, i < PRE_first_tail_x15_r0_body.P151.NL) (cl : SSt (· < 6536) PRE_first_tail_x15_r0_body.cx0_151.mlx) :
    Conv.MFoot PRE_first_tail_x15_r0_body.P151 6536 PRE_first_tail_x15_r0_body.kappa151 PRE_first_tail_x15_r0_body.kd151 PRE_first_tail_x15_r0_body.khinv151 PRE_first_tail_x15_r0_body.kninv151 (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1335.ffi).mlx PRE_first_tail_x15_r0_body.cx0_151.mlx PRE_first_tail_x15_r0_body.cx1_151.mlx (⟨21178, 18288, 2793475, 6536⟩ : Conv.Cnt) PRE_first_tail_x15_r0_body.clo151 PRE_first_tail_x15_r0_body.cln151 PRE_first_tail_x15_r0_body.cli151 PRE_first_tail_x15_r0_body.cwS151 PRE_first_tail_x15_r0_body.cnS151 PRE_first_tail_x15_r0_body.ciS151 :=
  ⟨rfl, rfl, rfl, PRE_first_tail_x15_r0_body.cnh0151, PRE_first_tail_x15_r0_body.cnh1151, PRE_first_tail_x15_r0_body.cnn0151, PRE_first_tail_x15_r0_body.cnn1151, PRE_first_tail_x15_r0_body.cplo151, PRE_first_tail_x15_r0_body.ccnt151, PRE_first_tail_x15_r0_body.cnband151, PRE_first_tail_x15_r0_body.chbelow151, PRE_first_tail_x15_r0_body.chren151, PRE_first_tail_x15_r0_body.cband151, PRE_first_tail_x15_r0_body.cnh1pos151, PRE_first_tail_x15_r0_body.cnren151, PRE_first_tail_x15_r0_body.cnlow151, PRE_first_tail_x15_r0_body.cabs0a151, PRE_first_tail_x15_r0_body.cabs0b151, PRE_first_tail_x15_r0_body.ctok1151, PRE_first_tail_x15_r0_body.cpend151, PRE_first_tail_x15_r0_body.cerrh151, PRE_first_tail_x15_r0_body.cfiles151, PRE_first_tail_x15_r0_body.carch151, PRE_first_tail_x15_r0_body.csizes151, PRE_first_tail_x15_r0_body.cwired151, PRE_first_tail_x15_r0_body.cfix151, clean, PRE_first_tail_x15_r0_body.fcxn151, PRE_first_tail_x15_r0_body.fcnn151, hltC, nltC, itemsC, tracedC, cl, PRE_first_tail_x15_r0_body.fle0151, PRE_first_tail_x15_r0_body.fnk151, PRE_first_tail_x15_r0_body.ckA151, PRE_first_tail_x15_r0_body.cobjsK151, PRE_first_tail_x15_r0_body.cnodesK151, PRE_first_tail_x15_r0_body.citemsK151, PRE_first_tail_x15_r0_body.f1A151, PRE_first_tail_x15_r0_body.f1O151, PRE_first_tail_x15_r0_body.f1N151, PRE_first_tail_x15_r0_body.f1I151, PRE_first_tail_x15_r0_body.fbd151, PRE_first_tail_x15_r0_body.fincW151, PRE_first_tail_x15_r0_body.fincI151, PRE_first_tail_x15_r0_body.fincN151, PRE_first_tail_x15_r0_body.flnF151, PRE_first_tail_x15_r0_body.fh151, PRE_first_tail_x15_r0_body.fo151, PRE_first_tail_x15_r0_body.fok151, PRE_first_tail_x15_r0_body.fnd151, PRE_first_tail_x15_r0_body.fp151, PRE_first_tail_x15_r0_body.fnord151, PRE_first_tail_x15_r0_body.fi151, PRE_first_tail_x15_r0_body.fii151⟩
theorem PRE_first_tail_x15_r0_body.cnshift151 (clean : Conv.NClean (⟨21178, 18288, 2793475, 6536⟩ : Conv.Cnt) (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1335.ffi).mlx) (hltC : ∀ h, PH (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1335.ffi).mlx h → h < (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1335.ffi).mlx.next) (nltC : ∀ i, PN (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1335.ffi).mlx i → i < (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1335.ffi).mlx.nnext) (itemsC : ∀ k v, (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1335.ffi).mlx.items.get k = some v → PN (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1335.ffi).mlx k) (tracedC : ∀ h o, (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1335.ffi).mlx.objs.get h = some o → ∀ i ∈ objTraces o, i < PRE_first_tail_x15_r0_body.P151.NL) (cl : SSt (· < 6536) PRE_first_tail_x15_r0_body.cx0_151.mlx) : NShift PRE_first_tail_x15_r0_body.P151 6536 PRE_first_tail_x15_r0_body.kappa151 PRE_first_tail_x15_r0_body.cx0_151 PRE_first_tail_x15_r0_body.cx1_151 :=
  Conv.nshift_of_foot (PRE_first_tail_x15_r0_body.cfoot151 clean hltC nltC itemsC tracedC cl) PRE_first_tail_x15_r0_body.chost151 (compact_a_eq PRE_first_tail_x15_r0_body.ckn0151 PRE_first_tail_x15_r0_body.ckn1151 PRE_first_tail_x15_r0_body.ckheap151 PRE_first_tail_x15_r0_body.ckpl151)

-- the observers: the layers' states at the call, the canonical and the merged state, their footprints and checks
noncomputable def PRE_first_tail_x15_r0_body.fxC_151 : PTrie Unit := (Host.Ts.Sim.Full.freedOf PRE_first_tail_x15_r0_body.s1335.ffi).getD PTrie.nil
noncomputable def PRE_first_tail_x15_r0_body.krC_151 : Host.Load.Layers.KRec := (Host.Ts.Sim.Full.krecOf PRE_first_tail_x15_r0_body.s1335.ffi).getD Host.Load.Layers.KRec.empty
kernel_rfl PRE_first_tail_x15_r0_body.ofxC_151 : (Host.Ts.Sim.Full.freedOf PRE_first_tail_x15_r0_body.s1335.ffi) = some PRE_first_tail_x15_r0_body.fxC_151
kernel_rfl PRE_first_tail_x15_r0_body.okrC_151 : (Host.Ts.Sim.Full.krecOf PRE_first_tail_x15_r0_body.s1335.ffi) = some PRE_first_tail_x15_r0_body.krC_151
noncomputable def PRE_first_tail_x15_r0_body.fx0_151 : PTrie Unit := (Host.Ts.Sim.Full.freedOf PRE_first_tail_x15_r0_body.s1337.ffi).getD PTrie.nil
noncomputable def PRE_first_tail_x15_r0_body.kr0_151 : Host.Load.Layers.KRec := (Host.Ts.Sim.Full.krecOf PRE_first_tail_x15_r0_body.s1337.ffi).getD Host.Load.Layers.KRec.empty
kernel_rfl PRE_first_tail_x15_r0_body.ofx0_151 : (Host.Ts.Sim.Full.freedOf PRE_first_tail_x15_r0_body.s1337.ffi) = some PRE_first_tail_x15_r0_body.fx0_151
kernel_rfl PRE_first_tail_x15_r0_body.okr0_151 : (Host.Ts.Sim.Full.krecOf PRE_first_tail_x15_r0_body.s1337.ffi) = some PRE_first_tail_x15_r0_body.kr0_151
noncomputable def PRE_first_tail_x15_r0_body.fx1_151 : PTrie Unit := (Host.Ts.Sim.Full.freedOf PRE_first_tail_x15_r0_body.s1336.ffi).getD PTrie.nil
noncomputable def PRE_first_tail_x15_r0_body.kr1_151 : Host.Load.Layers.KRec := (Host.Ts.Sim.Full.krecOf PRE_first_tail_x15_r0_body.s1336.ffi).getD Host.Load.Layers.KRec.empty
kernel_rfl PRE_first_tail_x15_r0_body.ofx1_151 : (Host.Ts.Sim.Full.freedOf PRE_first_tail_x15_r0_body.s1336.ffi) = some PRE_first_tail_x15_r0_body.fx1_151
kernel_rfl PRE_first_tail_x15_r0_body.okr1_151 : (Host.Ts.Sim.Full.krecOf PRE_first_tail_x15_r0_body.s1336.ffi) = some PRE_first_tail_x15_r0_body.kr1_151
kernel_rfl PRE_first_tail_x15_r0_body.ff0151 : PRE_first_tail_x15_r0_body.fx0_151 = Stage.setAll PRE_first_tail_x15_r0_body.fxC_151 (PRE_first_tail_x15_r0_body.clo151.filterMap fun i => (PRE_first_tail_x15_r0_body.fx0_151.get i).map (i, ·))
kernel_rfl PRE_first_tail_x15_r0_body.ff1151 : PRE_first_tail_x15_r0_body.fx1_151 = Stage.setAll PRE_first_tail_x15_r0_body.fxC_151 (PRE_first_tail_x15_r0_body.cwS151.filterMap fun i => (PRE_first_tail_x15_r0_body.fx1_151.get i).map (i, ·))
kernel_rfl PRE_first_tail_x15_r0_body.ffck151 : freedLB PRE_first_tail_x15_r0_body.kappa151 PRE_first_tail_x15_r0_body.cx0_151.mlx PRE_first_tail_x15_r0_body.fx0_151 PRE_first_tail_x15_r0_body.fx1_151 PRE_first_tail_x15_r0_body.clo151 = true
kernel_rfl PRE_first_tail_x15_r0_body.fkf0151 : PRE_first_tail_x15_r0_body.kr0_151.flags = Stage.setAll PRE_first_tail_x15_r0_body.krC_151.flags (PRE_first_tail_x15_r0_body.clo151.filterMap fun i => (PRE_first_tail_x15_r0_body.kr0_151.flags.get i).map (i, ·))
kernel_rfl PRE_first_tail_x15_r0_body.fkt0151 : PRE_first_tail_x15_r0_body.kr0_151.targs = Stage.setAll PRE_first_tail_x15_r0_body.krC_151.targs (PRE_first_tail_x15_r0_body.clo151.filterMap fun i => (PRE_first_tail_x15_r0_body.kr0_151.targs.get i).map (i, ·))
kernel_rfl PRE_first_tail_x15_r0_body.fkf1151 : PRE_first_tail_x15_r0_body.kr1_151.flags = Stage.setAll PRE_first_tail_x15_r0_body.krC_151.flags (PRE_first_tail_x15_r0_body.cwS151.filterMap fun i => (PRE_first_tail_x15_r0_body.kr1_151.flags.get i).map (i, ·))
kernel_rfl PRE_first_tail_x15_r0_body.fkt1151 : PRE_first_tail_x15_r0_body.kr1_151.targs = Stage.setAll PRE_first_tail_x15_r0_body.krC_151.targs (PRE_first_tail_x15_r0_body.cwS151.filterMap fun i => (PRE_first_tail_x15_r0_body.kr1_151.targs.get i).map (i, ·))
kernel_rfl PRE_first_tail_x15_r0_body.fkck151 : krecLB PRE_first_tail_x15_r0_body.kappa151 6536 PRE_first_tail_x15_r0_body.cx0_151.mlx PRE_first_tail_x15_r0_body.kr0_151 PRE_first_tail_x15_r0_body.kr1_151 PRE_first_tail_x15_r0_body.clo151 = true
kernel_rfl PRE_first_tail_x15_r0_body.fkn151 : Nat.ble 6536 6536 = true
-- the bridge and the pending traces' regions
kernel_rfl PRE_first_tail_x15_r0_body.cbridge151 : Host.Ts.Sim.Full.bridgeOf PRE_first_tail_x15_r0_body.s1336.ffi = Host.Ts.Sim.Full.bridgeOf PRE_first_tail_x15_r0_body.s1337.ffi
kernel_rfl PRE_first_tail_x15_r0_body.cpendR151 : pendRegB PRE_first_tail_x15_r0_body.kappa151 (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1337.ffi).mlx = true
kernel_rfl PRE_first_tail_x15_r0_body.cpendLe151 : Nat.ble (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1337.ffi).mlx.next (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1336.ffi).mlx.next = true
/-- **The compaction's native shift**, given the call's bookkeeping, its relation's facts (the model's and the
observers') and the canonical closedness. -/
theorem PRE_first_tail_x15_r0_body.cshift151 (clean : Conv.NClean (⟨21178, 18288, 2793475, 6536⟩ : Conv.Cnt) (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1335.ffi).mlx) (hltC : ∀ h, PH (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1335.ffi).mlx h → h < (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1335.ffi).mlx.next) (nltC : ∀ i, PN (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1335.ffi).mlx i → i < (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1335.ffi).mlx.nnext) (itemsC : ∀ k v, (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1335.ffi).mlx.items.get k = some v → PN (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1335.ffi).mlx k) (tracedC : ∀ h o, (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1335.ffi).mlx.objs.get h = some o → ∀ i ∈ objTraces o, i < PRE_first_tail_x15_r0_body.P151.NL) (cl : SSt (· < 6536) PRE_first_tail_x15_r0_body.cx0_151.mlx)
    (hobjC : ∀ h, PRE_first_tail_x15_r0_body.fxC_151.get h = some () → ((Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1335.ffi).mlx.objs.get h).isSome = true)
    (hfC : ∀ h, (PRE_first_tail_x15_r0_body.krC_151.flags.get h).isSome = true → ((Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1335.ffi).mlx.objs.get h).isSome = true)
    (htC : ∀ h, (PRE_first_tail_x15_r0_body.krC_151.targs.get h).isSome = true → ((Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1335.ffi).mlx.objs.get h).isSome = true)
    (hclC : ∀ h l, PRE_first_tail_x15_r0_body.krC_151.targs.get h = some l → Host.Ts.Sim.Full.STargs (· < (⟨21178, 18288, 2793475, 6536⟩ : Conv.Cnt).n) l) :
    Conv.FullShiftQ PRE_first_tail_x15_r0_body.P151 6536 PRE_first_tail_x15_r0_body.kappa151 PRE_first_tail_x15_r0_body.s1337.ffi PRE_first_tail_x15_r0_body.s1336.ffi :=
  ⟨PRE_first_tail_x15_r0_body.cnshift151 clean hltC nltC itemsC tracedC cl, PRE_first_tail_x15_r0_body.cqueue151, fun t ht => bSN_sound (List.all_eq_true.mp PRE_first_tail_x15_r0_body.ctokSupp151 t ht),
    PRE_first_tail_x15_r0_body.cbridge151,
    liveShift_foot (x0' := Host.Ts.Sim.Full.mlxOf PRE_first_tail_x15_r0_body.s1337.ffi) (x1' := Host.Ts.Sim.Full.mlxOf PRE_first_tail_x15_r0_body.s1336.ffi) (PRE_first_tail_x15_r0_body.cfoot151 clean hltC nltC itemsC tracedC cl) rfl PRE_first_tail_x15_r0_body.ofx0_151 PRE_first_tail_x15_r0_body.ofx1_151 hobjC PRE_first_tail_x15_r0_body.ff0151 PRE_first_tail_x15_r0_body.ff1151 PRE_first_tail_x15_r0_body.ffck151,
    kernShift_foot (x0' := Host.Ts.Sim.Full.mlxOf PRE_first_tail_x15_r0_body.s1337.ffi) (x1' := Host.Ts.Sim.Full.mlxOf PRE_first_tail_x15_r0_body.s1336.ffi) (PRE_first_tail_x15_r0_body.cfoot151 clean hltC nltC itemsC tracedC cl) rfl PRE_first_tail_x15_r0_body.okr0_151 PRE_first_tail_x15_r0_body.okr1_151 (Nat.le_of_ble_eq_true PRE_first_tail_x15_r0_body.fkn151) hfC htC hclC
      PRE_first_tail_x15_r0_body.fkf0151 PRE_first_tail_x15_r0_body.fkt0151 PRE_first_tail_x15_r0_body.fkf1151 PRE_first_tail_x15_r0_body.fkt1151 PRE_first_tail_x15_r0_body.fkck151,
    pendReg_of rfl PRE_first_tail_x15_r0_body.cnh0151 PRE_first_tail_x15_r0_body.cnh1151 (Nat.le_of_ble_eq_true PRE_first_tail_x15_r0_body.cpendLe151) PRE_first_tail_x15_r0_body.cpendR151⟩

end Host.Load.Run.Tpl
