import host.sim.template.a4pre_first_tail_x15_r0_body.SiteCl145
import host.sim.conv.CompactFull
import host.sim.template.FootGen
set_option Elab.async false
namespace Host.Load.Run.Tpl
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
open Host.Ts Host.Ts.Sim Host.Ts.Sim.Template

/-! The compaction's native shift at call site 145 from its footprint (`Conv.nshift_of_foot`), and the observers'
(`liveShift_foot`, `kernShift_foot`): `Conv.FullShiftQ` for `Conv.full_compactQ`, given the call's bookkeeping and its
relation's facts. -/

/-- The load parameters of the chain (band-free: its start's node counter as `NL` and `N0`). -/
def PRE_first_tail_x15_r0_body.Pc145 : LoadP := ⟨18151, 131072, 1099511627776, 15235, 15235, []⟩
/-- The site's band raised to the map's checked fixed-node prefix, including newly recorded closure traces. -/
def PRE_first_tail_x15_r0_body.P145 : LoadP := PRE_first_tail_x15_r0_body.Pc145.raise 18162
kernel_rfl PRE_first_tail_x15_r0_body.craise145 : Nat.ble PRE_first_tail_x15_r0_body.Pc145.N0 18162 = true
theorem PRE_first_tail_x15_r0_body.raised145 : Host.Ts.Sim.Full.Raised PRE_first_tail_x15_r0_body.Pc145 PRE_first_tail_x15_r0_body.P145 :=
  .inr ⟨18162, rfl, Nat.le_of_ble_eq_true PRE_first_tail_x15_r0_body.craise145, rfl⟩
noncomputable abbrev PRE_first_tail_x15_r0_body.cx0_145 : Host.Load.LSt := clearTokens (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1283.ffi)
noncomputable abbrev PRE_first_tail_x15_r0_body.cx1_145 : Host.Load.LSt := clearTokens (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1282.ffi)
def PRE_first_tail_x15_r0_body.khinv145 : PTrie Nat := Stage.setAll PTrie.nil []
def PRE_first_tail_x15_r0_body.kninv145 : PTrie Nat := Stage.setAll PTrie.nil []
/-- The stage's footprint: its written and fresh handles, fresh nodes, written and fresh items. -/
def PRE_first_tail_x15_r0_body.cwS145 : List Nat := []
def PRE_first_tail_x15_r0_body.cnS145 : List Nat := List.range' 18162 0
def PRE_first_tail_x15_r0_body.ciS145 : List Nat := [] ++ List.range' 18162 0

-- the small checks (`MChecks`'s)
kernel_rfl PRE_first_tail_x15_r0_body.cnh0145 : PRE_first_tail_x15_r0_body.kd145.nh0 = PRE_first_tail_x15_r0_body.cx0_145.mlx.next
kernel_rfl PRE_first_tail_x15_r0_body.cnh1145 : PRE_first_tail_x15_r0_body.kd145.nh1 = PRE_first_tail_x15_r0_body.cx1_145.mlx.next
kernel_rfl PRE_first_tail_x15_r0_body.cnn0145 : PRE_first_tail_x15_r0_body.kd145.nn0 = PRE_first_tail_x15_r0_body.cx0_145.mlx.nnext
kernel_rfl PRE_first_tail_x15_r0_body.cnn1145 : PRE_first_tail_x15_r0_body.kd145.nn1 = PRE_first_tail_x15_r0_body.cx1_145.mlx.nnext
kernel_rfl PRE_first_tail_x15_r0_body.cplo145 : (Nat.blt 0 PRE_first_tail_x15_r0_body.P145.lo && Nat.ble PRE_first_tail_x15_r0_body.P145.lo PRE_first_tail_x15_r0_body.cx0_145.mlx.next && Nat.ble PRE_first_tail_x15_r0_body.P145.lo RData.bigHi && Nat.ble RData.bigHi PRE_first_tail_x15_r0_body.P145.E) = true
kernel_rfl PRE_first_tail_x15_r0_body.ccnt145 : (Nat.ble PRE_first_tail_x15_r0_body.cx0_145.mlx.next PRE_first_tail_x15_r0_body.cx1_145.mlx.next && Nat.ble PRE_first_tail_x15_r0_body.cx0_145.mlx.nnext PRE_first_tail_x15_r0_body.cx1_145.mlx.nnext) = true
kernel_rfl PRE_first_tail_x15_r0_body.cnband145 : (Nat.blt 0 PRE_first_tail_x15_r0_body.P145.NL && Nat.ble PRE_first_tail_x15_r0_body.P145.NL PRE_first_tail_x15_r0_body.P145.N0 && Nat.ble PRE_first_tail_x15_r0_body.P145.N0 PRE_first_tail_x15_r0_body.cx0_145.mlx.nnext) = true
kernel_rfl PRE_first_tail_x15_r0_body.chbelow145 : PRE_first_tail_x15_r0_body.kd145.checkHndBelow = true
kernel_rfl PRE_first_tail_x15_r0_body.chren145 : checkRenG PRE_first_tail_x15_r0_body.kd145.hnd PRE_first_tail_x15_r0_body.khinv145 (phB PRE_first_tail_x15_r0_body.cx0_145.mlx) = true
kernel_rfl PRE_first_tail_x15_r0_body.cband145 : PRE_first_tail_x15_r0_body.kd145.checkBand PRE_first_tail_x15_r0_body.P145.lo = true
kernel_rfl PRE_first_tail_x15_r0_body.cnh1pos145 : Nat.blt 0 PRE_first_tail_x15_r0_body.kd145.nh1 = true
kernel_rfl PRE_first_tail_x15_r0_body.cnren145 : checkRenG PRE_first_tail_x15_r0_body.kd145.node PRE_first_tail_x15_r0_body.kninv145 (pnB PRE_first_tail_x15_r0_body.cx0_145.mlx) = true
kernel_rfl PRE_first_tail_x15_r0_body.cnlow145 : (PTrie.keysA PRE_first_tail_x15_r0_body.kd145.node).all (fun j => Nat.ble PRE_first_tail_x15_r0_body.P145.NL j && Nat.blt (PRE_first_tail_x15_r0_body.kd145.nodeF j) PRE_first_tail_x15_r0_body.cx1_145.mlx.nnext) = true
kernel_rfl PRE_first_tail_x15_r0_body.cabs0a145 : PRE_first_tail_x15_r0_body.cx0_145.mlx.arrs.get 0 = none
kernel_rfl PRE_first_tail_x15_r0_body.cabs0b145 : PRE_first_tail_x15_r0_body.cx0_145.mlx.objs.get 0 = none
kernel_rfl PRE_first_tail_x15_r0_body.ctok1145 : PRE_first_tail_x15_r0_body.cx1_145.mlx.tokens = []
kernel_rfl PRE_first_tail_x15_r0_body.cpend145 : PRE_first_tail_x15_r0_body.cx1_145.mlx.pending = PRE_first_tail_x15_r0_body.cx0_145.mlx.pending.map PRE_first_tail_x15_r0_body.kappa145.pend
kernel_rfl PRE_first_tail_x15_r0_body.cerrh145 : PRE_first_tail_x15_r0_body.cx1_145.mlx.errh = PRE_first_tail_x15_r0_body.cx0_145.mlx.errh.map PRE_first_tail_x15_r0_body.kappa145.arg
kernel_rfl PRE_first_tail_x15_r0_body.cfiles145 : PRE_first_tail_x15_r0_body.cx1_145.mlx.files = PRE_first_tail_x15_r0_body.cx0_145.mlx.files
kernel_rfl PRE_first_tail_x15_r0_body.carch145 : PRE_first_tail_x15_r0_body.cx1_145.mlx.arch = PRE_first_tail_x15_r0_body.cx0_145.mlx.arch
kernel_rfl PRE_first_tail_x15_r0_body.csizes145 : PRE_first_tail_x15_r0_body.cx1_145.mlx.deviceSizes = PRE_first_tail_x15_r0_body.cx0_145.mlx.deviceSizes
kernel_rfl PRE_first_tail_x15_r0_body.cwired145 : PRE_first_tail_x15_r0_body.cx1_145.mlx.wired = PRE_first_tail_x15_r0_body.cx0_145.mlx.wired
kernel_rfl PRE_first_tail_x15_r0_body.chost145 : PRE_first_tail_x15_r0_body.cx1_145.host = PRE_first_tail_x15_r0_body.cx0_145.host
-- the compaction map's addresses are `PRE_first_tail_x15_r0_body.kd145`'s
kernel_rfl PRE_first_tail_x15_r0_body.ckn0145 : PRE_first_tail_x15_r0_body.kd145.n0 = 2788955
kernel_rfl PRE_first_tail_x15_r0_body.ckn1145 : PRE_first_tail_x15_r0_body.kd145.n1 = 2788957
kernel_rfl PRE_first_tail_x15_r0_body.ckheap145 : (PTrie.keysA PRE_first_tail_x15_r0_body.kd145.heap).all (fun x => Nat.ble 2788955 x) = true
kernel_rfl PRE_first_tail_x15_r0_body.ckpl145 : (List.range 0).all (fun j => decide (PRE_first_tail_x15_r0_body.kd145.heap.get (2788955 + j) = nth? PRE_first_tail_x15_r0_body.pl145 j)) = true
-- the map fixes the call's names (`Conv.fixOld_compact`), the call's counters
kernel_rfl PRE_first_tail_x15_r0_body.fja145 : Nat.ble 2788955 2788955 = true
kernel_rfl PRE_first_tail_x15_r0_body.fn145 : Nat.ble 6278 6278 = true
kernel_rfl PRE_first_tail_x15_r0_body.fjaD145 : Nat.ble 2788955 PRE_first_tail_x15_r0_body.kd145.n0 = true
kernel_rfl PRE_first_tail_x15_r0_body.fxn145 : Nat.ble 21064 PRE_first_tail_x15_r0_body.kd145.nh0 = true
kernel_rfl PRE_first_tail_x15_r0_body.fnn145 : Nat.ble 18162 PRE_first_tail_x15_r0_body.kd145.nn0 = true
kernel_rfl PRE_first_tail_x15_r0_body.fxb145 : Nat.ble 21064 RData.bigHi = true
kernel_rfl PRE_first_tail_x15_r0_body.fheap145 : (PTrie.keysA PRE_first_tail_x15_r0_body.kd145.heap).all (Nat.ble (⟨21064, 18162, 2788955, 6278⟩ : Conv.Cnt).ja) = true
kernel_rfl PRE_first_tail_x15_r0_body.fhnd145 : (PTrie.keysA PRE_first_tail_x15_r0_body.kd145.hnd).all (Nat.ble (⟨21064, 18162, 2788955, 6278⟩ : Conv.Cnt).xn) = true
kernel_rfl PRE_first_tail_x15_r0_body.fnode145 : (PTrie.keysA PRE_first_tail_x15_r0_body.kd145.node).all (Nat.ble (⟨21064, 18162, 2788955, 6278⟩ : Conv.Cnt).nn) = true
/-- The compaction map fixes the call's names. -/
theorem PRE_first_tail_x15_r0_body.cfix145 : Conv.FixOld (⟨21064, 18162, 2788955, 6278⟩ : Conv.Cnt) PRE_first_tail_x15_r0_body.kappa145 :=
  Conv.fixOld_compact (Nat.le_of_ble_eq_true PRE_first_tail_x15_r0_body.fja145) (Nat.le_of_ble_eq_true PRE_first_tail_x15_r0_body.fn145) (Nat.le_of_ble_eq_true PRE_first_tail_x15_r0_body.fjaD145) (Nat.le_of_ble_eq_true PRE_first_tail_x15_r0_body.fxn145) (Nat.le_of_ble_eq_true PRE_first_tail_x15_r0_body.fnn145) (Nat.le_of_ble_eq_true PRE_first_tail_x15_r0_body.fxb145) PRE_first_tail_x15_r0_body.fheap145 PRE_first_tail_x15_r0_body.fhnd145 PRE_first_tail_x15_r0_body.fnode145
kernel_rfl PRE_first_tail_x15_r0_body.fcxn145 : (⟨21064, 18162, 2788955, 6278⟩ : Conv.Cnt).xn = (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1281.ffi).mlx.next
kernel_rfl PRE_first_tail_x15_r0_body.fcnn145 : (⟨21064, 18162, 2788955, 6278⟩ : Conv.Cnt).nn = (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1281.ffi).mlx.nnext
kernel_rfl PRE_first_tail_x15_r0_body.fle0145 : (Nat.ble (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1281.ffi).mlx.next PRE_first_tail_x15_r0_body.cx0_145.mlx.next && Nat.ble (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1281.ffi).mlx.nnext PRE_first_tail_x15_r0_body.cx0_145.mlx.nnext && Nat.ble (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1281.ffi).mlx.next RData.bigHi) = true
kernel_rfl PRE_first_tail_x15_r0_body.fnk145 : (PTrie.keysA PRE_first_tail_x15_r0_body.kd145.node).all (Nat.ble (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1281.ffi).mlx.nnext) = true
-- the merged state keeps the call's entries off the stage's footprint
kernel_rfl PRE_first_tail_x15_r0_body.f1A145 : PRE_first_tail_x15_r0_body.cx1_145.mlx.arrs = Stage.setAll (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1281.ffi).mlx.arrs (PRE_first_tail_x15_r0_body.cwS145.filterMap fun i => (PRE_first_tail_x15_r0_body.cx1_145.mlx.arrs.get i).map (i, ·))
kernel_rfl PRE_first_tail_x15_r0_body.f1O145 : PRE_first_tail_x15_r0_body.cx1_145.mlx.objs = Stage.setAll (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1281.ffi).mlx.objs (PRE_first_tail_x15_r0_body.cwS145.filterMap fun i => (PRE_first_tail_x15_r0_body.cx1_145.mlx.objs.get i).map (i, ·))
kernel_rfl PRE_first_tail_x15_r0_body.f1N145 : PRE_first_tail_x15_r0_body.cx1_145.mlx.nodes = Stage.setAll (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1281.ffi).mlx.nodes (PRE_first_tail_x15_r0_body.cnS145.filterMap fun i => (PRE_first_tail_x15_r0_body.cx1_145.mlx.nodes.get i).map (i, ·))
kernel_rfl PRE_first_tail_x15_r0_body.f1I145 : PRE_first_tail_x15_r0_body.cx1_145.mlx.items = Stage.setAll (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1281.ffi).mlx.items (PRE_first_tail_x15_r0_body.ciS145.filterMap fun i => (PRE_first_tail_x15_r0_body.cx1_145.mlx.items.get i).map (i, ·))
kernel_rfl PRE_first_tail_x15_r0_body.fbd145 : (PRE_first_tail_x15_r0_body.clo145 ++ PRE_first_tail_x15_r0_body.cln145 ++ PRE_first_tail_x15_r0_body.cli145 ++ PRE_first_tail_x15_r0_body.cwS145 ++ PRE_first_tail_x15_r0_body.cnS145 ++ PRE_first_tail_x15_r0_body.ciS145).all (fun i => Nat.blt (i / 4096) (4 ^ 31)) = true
kernel_rfl PRE_first_tail_x15_r0_body.fincW145 : PRE_first_tail_x15_r0_body.cwS145.all (fun h => !Nat.blt h (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1281.ffi).mlx.next || PRE_first_tail_x15_r0_body.clo145.contains h) = true
kernel_rfl PRE_first_tail_x15_r0_body.fincI145 : PRE_first_tail_x15_r0_body.ciS145.all (fun k => !Nat.blt k (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1281.ffi).mlx.nnext || PRE_first_tail_x15_r0_body.cli145.contains k) = true
kernel_rfl PRE_first_tail_x15_r0_body.fincN145 : PRE_first_tail_x15_r0_body.cnS145.all (Nat.ble (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1281.ffi).mlx.nnext) = true
kernel_rfl PRE_first_tail_x15_r0_body.flnF145 : PRE_first_tail_x15_r0_body.cln145.all (Nat.ble (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1281.ffi).mlx.nnext) = true
-- the checks over the changed lists
kernel_rfl PRE_first_tail_x15_r0_body.fh145 : PRE_first_tail_x15_r0_body.clo145.all (handleOK PRE_first_tail_x15_r0_body.kappa145 PRE_first_tail_x15_r0_body.P145.lo PRE_first_tail_x15_r0_body.cx0_145.mlx PRE_first_tail_x15_r0_body.cx1_145.mlx) = true
kernel_rfl PRE_first_tail_x15_r0_body.fo145 : PRE_first_tail_x15_r0_body.clo145.map (fun h => PRE_first_tail_x15_r0_body.cx1_145.mlx.objs.get (PRE_first_tail_x15_r0_body.kappa145.handle h)) = PRE_first_tail_x15_r0_body.clo145.map (fun h => (PRE_first_tail_x15_r0_body.cx0_145.mlx.objs.get h).map PRE_first_tail_x15_r0_body.kappa145.nobj)
kernel_rfl PRE_first_tail_x15_r0_body.fok145 : PRE_first_tail_x15_r0_body.clo145.all (objOK PRE_first_tail_x15_r0_body.kappa145 PRE_first_tail_x15_r0_body.P145.NL PRE_first_tail_x15_r0_body.cx0_145.mlx) = true
kernel_rfl PRE_first_tail_x15_r0_body.fnd145 : PRE_first_tail_x15_r0_body.cln145.all (nodeOKF PRE_first_tail_x15_r0_body.kappa145 PRE_first_tail_x15_r0_body.P145 PRE_first_tail_x15_r0_body.cx0_145.mlx PRE_first_tail_x15_r0_body.cx1_145.mlx) = true
kernel_rfl PRE_first_tail_x15_r0_body.fp145 : ((PRE_first_tail_x15_r0_body.cln145.filter (fullB PRE_first_tail_x15_r0_body.P145))).map (fun i => (PRE_first_tail_x15_r0_body.cx1_145.mlx.nodes.get (PRE_first_tail_x15_r0_body.kappa145.node i)).map Host.Mlx.Ffi.Node.prim) =
  ((PRE_first_tail_x15_r0_body.cln145.filter (fullB PRE_first_tail_x15_r0_body.P145))).map (fun i => (PRE_first_tail_x15_r0_body.cx0_145.mlx.nodes.get i).map fun nd => PRE_first_tail_x15_r0_body.kappa145.prim nd.prim)
kernel_rfl PRE_first_tail_x15_r0_body.fnordI145 : incrB PRE_first_tail_x15_r0_body.kd145.nodeF (List.range' 18162 0) = true
kernel_rfl PRE_first_tail_x15_r0_body.fnordK145 : (PTrie.keysA PRE_first_tail_x15_r0_body.kd145.node).all (fun k => Nat.ble 18162 k && Nat.blt k 18162) = true
kernel_rfl PRE_first_tail_x15_r0_body.fnordL145 : (PRE_first_tail_x15_r0_body.cln145.filter (Nat.ble PRE_first_tail_x15_r0_body.P145.N0)).all (fun i => Nat.ble i (PRE_first_tail_x15_r0_body.kd145.nodeF i) && (Nat.blt i 18162 || Nat.ble PRE_first_tail_x15_r0_body.kd145.nn0 i)) = true
theorem PRE_first_tail_x15_r0_body.fnord145 : (PRE_first_tail_x15_r0_body.cln145.filter (Nat.ble PRE_first_tail_x15_r0_body.P145.N0)).all (fun i => Nat.ble i (PRE_first_tail_x15_r0_body.kd145.nodeF i) &&
    (PTrie.keysA PRE_first_tail_x15_r0_body.kd145.node).all fun j => !Nat.blt j i || Nat.blt (PRE_first_tail_x15_r0_body.kd145.nodeF j) (PRE_first_tail_x15_r0_body.kd145.nodeF i)) = true :=
  cnord_of PRE_first_tail_x15_r0_body.cnlow145 PRE_first_tail_x15_r0_body.cnn1145 PRE_first_tail_x15_r0_body.fnordI145 PRE_first_tail_x15_r0_body.fnordK145 PRE_first_tail_x15_r0_body.fnordL145
kernel_rfl PRE_first_tail_x15_r0_body.fi145 : PRE_first_tail_x15_r0_body.cli145.all (pnB PRE_first_tail_x15_r0_body.cx0_145.mlx) = true
kernel_rfl PRE_first_tail_x15_r0_body.fii145 : PRE_first_tail_x15_r0_body.cli145.all (fun k => decide (PRE_first_tail_x15_r0_body.cx1_145.mlx.items.get (PRE_first_tail_x15_r0_body.kappa145.node k) = (PRE_first_tail_x15_r0_body.cx0_145.mlx.items.get k).map PRE_first_tail_x15_r0_body.kappa145.nv)) = true
/-- **The compaction's footprint.** -/
theorem PRE_first_tail_x15_r0_body.cfoot145 (clean : Conv.NClean (⟨21064, 18162, 2788955, 6278⟩ : Conv.Cnt) (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1281.ffi).mlx) (hltC : ∀ h, PH (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1281.ffi).mlx h → h < (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1281.ffi).mlx.next) (nltC : ∀ i, PN (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1281.ffi).mlx i → i < (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1281.ffi).mlx.nnext) (itemsC : ∀ k v, (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1281.ffi).mlx.items.get k = some v → PN (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1281.ffi).mlx k) (tracedC : ∀ h o, (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1281.ffi).mlx.objs.get h = some o → ∀ i ∈ objTraces o, i < PRE_first_tail_x15_r0_body.P145.NL) (cl : SSt (· < 6278) PRE_first_tail_x15_r0_body.cx0_145.mlx) :
    Conv.MFoot PRE_first_tail_x15_r0_body.P145 6278 PRE_first_tail_x15_r0_body.kappa145 PRE_first_tail_x15_r0_body.kd145 PRE_first_tail_x15_r0_body.khinv145 PRE_first_tail_x15_r0_body.kninv145 (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1281.ffi).mlx PRE_first_tail_x15_r0_body.cx0_145.mlx PRE_first_tail_x15_r0_body.cx1_145.mlx (⟨21064, 18162, 2788955, 6278⟩ : Conv.Cnt) PRE_first_tail_x15_r0_body.clo145 PRE_first_tail_x15_r0_body.cln145 PRE_first_tail_x15_r0_body.cli145 PRE_first_tail_x15_r0_body.cwS145 PRE_first_tail_x15_r0_body.cnS145 PRE_first_tail_x15_r0_body.ciS145 :=
  ⟨rfl, rfl, rfl, PRE_first_tail_x15_r0_body.cnh0145, PRE_first_tail_x15_r0_body.cnh1145, PRE_first_tail_x15_r0_body.cnn0145, PRE_first_tail_x15_r0_body.cnn1145, PRE_first_tail_x15_r0_body.cplo145, PRE_first_tail_x15_r0_body.ccnt145, PRE_first_tail_x15_r0_body.cnband145, PRE_first_tail_x15_r0_body.chbelow145, PRE_first_tail_x15_r0_body.chren145, PRE_first_tail_x15_r0_body.cband145, PRE_first_tail_x15_r0_body.cnh1pos145, PRE_first_tail_x15_r0_body.cnren145, PRE_first_tail_x15_r0_body.cnlow145, PRE_first_tail_x15_r0_body.cabs0a145, PRE_first_tail_x15_r0_body.cabs0b145, PRE_first_tail_x15_r0_body.ctok1145, PRE_first_tail_x15_r0_body.cpend145, PRE_first_tail_x15_r0_body.cerrh145, PRE_first_tail_x15_r0_body.cfiles145, PRE_first_tail_x15_r0_body.carch145, PRE_first_tail_x15_r0_body.csizes145, PRE_first_tail_x15_r0_body.cwired145, PRE_first_tail_x15_r0_body.cfix145, clean, PRE_first_tail_x15_r0_body.fcxn145, PRE_first_tail_x15_r0_body.fcnn145, hltC, nltC, itemsC, tracedC, cl, PRE_first_tail_x15_r0_body.fle0145, PRE_first_tail_x15_r0_body.fnk145, PRE_first_tail_x15_r0_body.ckA145, PRE_first_tail_x15_r0_body.cobjsK145, PRE_first_tail_x15_r0_body.cnodesK145, PRE_first_tail_x15_r0_body.citemsK145, PRE_first_tail_x15_r0_body.f1A145, PRE_first_tail_x15_r0_body.f1O145, PRE_first_tail_x15_r0_body.f1N145, PRE_first_tail_x15_r0_body.f1I145, PRE_first_tail_x15_r0_body.fbd145, PRE_first_tail_x15_r0_body.fincW145, PRE_first_tail_x15_r0_body.fincI145, PRE_first_tail_x15_r0_body.fincN145, PRE_first_tail_x15_r0_body.flnF145, PRE_first_tail_x15_r0_body.fh145, PRE_first_tail_x15_r0_body.fo145, PRE_first_tail_x15_r0_body.fok145, PRE_first_tail_x15_r0_body.fnd145, PRE_first_tail_x15_r0_body.fp145, PRE_first_tail_x15_r0_body.fnord145, PRE_first_tail_x15_r0_body.fi145, PRE_first_tail_x15_r0_body.fii145⟩
theorem PRE_first_tail_x15_r0_body.cnshift145 (clean : Conv.NClean (⟨21064, 18162, 2788955, 6278⟩ : Conv.Cnt) (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1281.ffi).mlx) (hltC : ∀ h, PH (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1281.ffi).mlx h → h < (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1281.ffi).mlx.next) (nltC : ∀ i, PN (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1281.ffi).mlx i → i < (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1281.ffi).mlx.nnext) (itemsC : ∀ k v, (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1281.ffi).mlx.items.get k = some v → PN (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1281.ffi).mlx k) (tracedC : ∀ h o, (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1281.ffi).mlx.objs.get h = some o → ∀ i ∈ objTraces o, i < PRE_first_tail_x15_r0_body.P145.NL) (cl : SSt (· < 6278) PRE_first_tail_x15_r0_body.cx0_145.mlx) : NShift PRE_first_tail_x15_r0_body.P145 6278 PRE_first_tail_x15_r0_body.kappa145 PRE_first_tail_x15_r0_body.cx0_145 PRE_first_tail_x15_r0_body.cx1_145 :=
  Conv.nshift_of_foot (PRE_first_tail_x15_r0_body.cfoot145 clean hltC nltC itemsC tracedC cl) PRE_first_tail_x15_r0_body.chost145 (compact_a_eq PRE_first_tail_x15_r0_body.ckn0145 PRE_first_tail_x15_r0_body.ckn1145 PRE_first_tail_x15_r0_body.ckheap145 PRE_first_tail_x15_r0_body.ckpl145)

-- the observers: the layers' states at the call, the canonical and the merged state, their footprints and checks
noncomputable def PRE_first_tail_x15_r0_body.fxC_145 : PTrie Unit := (Host.Ts.Sim.Full.freedOf PRE_first_tail_x15_r0_body.s1281.ffi).getD PTrie.nil
noncomputable def PRE_first_tail_x15_r0_body.krC_145 : Host.Load.Layers.KRec := (Host.Ts.Sim.Full.krecOf PRE_first_tail_x15_r0_body.s1281.ffi).getD Host.Load.Layers.KRec.empty
kernel_rfl PRE_first_tail_x15_r0_body.ofxC_145 : (Host.Ts.Sim.Full.freedOf PRE_first_tail_x15_r0_body.s1281.ffi) = some PRE_first_tail_x15_r0_body.fxC_145
kernel_rfl PRE_first_tail_x15_r0_body.okrC_145 : (Host.Ts.Sim.Full.krecOf PRE_first_tail_x15_r0_body.s1281.ffi) = some PRE_first_tail_x15_r0_body.krC_145
noncomputable def PRE_first_tail_x15_r0_body.fx0_145 : PTrie Unit := (Host.Ts.Sim.Full.freedOf PRE_first_tail_x15_r0_body.s1283.ffi).getD PTrie.nil
noncomputable def PRE_first_tail_x15_r0_body.kr0_145 : Host.Load.Layers.KRec := (Host.Ts.Sim.Full.krecOf PRE_first_tail_x15_r0_body.s1283.ffi).getD Host.Load.Layers.KRec.empty
kernel_rfl PRE_first_tail_x15_r0_body.ofx0_145 : (Host.Ts.Sim.Full.freedOf PRE_first_tail_x15_r0_body.s1283.ffi) = some PRE_first_tail_x15_r0_body.fx0_145
kernel_rfl PRE_first_tail_x15_r0_body.okr0_145 : (Host.Ts.Sim.Full.krecOf PRE_first_tail_x15_r0_body.s1283.ffi) = some PRE_first_tail_x15_r0_body.kr0_145
noncomputable def PRE_first_tail_x15_r0_body.fx1_145 : PTrie Unit := (Host.Ts.Sim.Full.freedOf PRE_first_tail_x15_r0_body.s1282.ffi).getD PTrie.nil
noncomputable def PRE_first_tail_x15_r0_body.kr1_145 : Host.Load.Layers.KRec := (Host.Ts.Sim.Full.krecOf PRE_first_tail_x15_r0_body.s1282.ffi).getD Host.Load.Layers.KRec.empty
kernel_rfl PRE_first_tail_x15_r0_body.ofx1_145 : (Host.Ts.Sim.Full.freedOf PRE_first_tail_x15_r0_body.s1282.ffi) = some PRE_first_tail_x15_r0_body.fx1_145
kernel_rfl PRE_first_tail_x15_r0_body.okr1_145 : (Host.Ts.Sim.Full.krecOf PRE_first_tail_x15_r0_body.s1282.ffi) = some PRE_first_tail_x15_r0_body.kr1_145
kernel_rfl PRE_first_tail_x15_r0_body.ff0145 : PRE_first_tail_x15_r0_body.fx0_145 = Stage.setAll PRE_first_tail_x15_r0_body.fxC_145 (PRE_first_tail_x15_r0_body.clo145.filterMap fun i => (PRE_first_tail_x15_r0_body.fx0_145.get i).map (i, ·))
kernel_rfl PRE_first_tail_x15_r0_body.ff1145 : PRE_first_tail_x15_r0_body.fx1_145 = Stage.setAll PRE_first_tail_x15_r0_body.fxC_145 (PRE_first_tail_x15_r0_body.cwS145.filterMap fun i => (PRE_first_tail_x15_r0_body.fx1_145.get i).map (i, ·))
kernel_rfl PRE_first_tail_x15_r0_body.ffck145 : freedLB PRE_first_tail_x15_r0_body.kappa145 PRE_first_tail_x15_r0_body.cx0_145.mlx PRE_first_tail_x15_r0_body.fx0_145 PRE_first_tail_x15_r0_body.fx1_145 PRE_first_tail_x15_r0_body.clo145 = true
kernel_rfl PRE_first_tail_x15_r0_body.fkf0145 : PRE_first_tail_x15_r0_body.kr0_145.flags = Stage.setAll PRE_first_tail_x15_r0_body.krC_145.flags (PRE_first_tail_x15_r0_body.clo145.filterMap fun i => (PRE_first_tail_x15_r0_body.kr0_145.flags.get i).map (i, ·))
kernel_rfl PRE_first_tail_x15_r0_body.fkt0145 : PRE_first_tail_x15_r0_body.kr0_145.targs = Stage.setAll PRE_first_tail_x15_r0_body.krC_145.targs (PRE_first_tail_x15_r0_body.clo145.filterMap fun i => (PRE_first_tail_x15_r0_body.kr0_145.targs.get i).map (i, ·))
kernel_rfl PRE_first_tail_x15_r0_body.fkf1145 : PRE_first_tail_x15_r0_body.kr1_145.flags = Stage.setAll PRE_first_tail_x15_r0_body.krC_145.flags (PRE_first_tail_x15_r0_body.cwS145.filterMap fun i => (PRE_first_tail_x15_r0_body.kr1_145.flags.get i).map (i, ·))
kernel_rfl PRE_first_tail_x15_r0_body.fkt1145 : PRE_first_tail_x15_r0_body.kr1_145.targs = Stage.setAll PRE_first_tail_x15_r0_body.krC_145.targs (PRE_first_tail_x15_r0_body.cwS145.filterMap fun i => (PRE_first_tail_x15_r0_body.kr1_145.targs.get i).map (i, ·))
kernel_rfl PRE_first_tail_x15_r0_body.fkck145 : krecLB PRE_first_tail_x15_r0_body.kappa145 6278 PRE_first_tail_x15_r0_body.cx0_145.mlx PRE_first_tail_x15_r0_body.kr0_145 PRE_first_tail_x15_r0_body.kr1_145 PRE_first_tail_x15_r0_body.clo145 = true
kernel_rfl PRE_first_tail_x15_r0_body.fkn145 : Nat.ble 6278 6278 = true
-- the bridge and the pending traces' regions
kernel_rfl PRE_first_tail_x15_r0_body.cbridge145 : Host.Ts.Sim.Full.bridgeOf PRE_first_tail_x15_r0_body.s1282.ffi = Host.Ts.Sim.Full.bridgeOf PRE_first_tail_x15_r0_body.s1283.ffi
kernel_rfl PRE_first_tail_x15_r0_body.cpendR145 : pendRegB PRE_first_tail_x15_r0_body.kappa145 (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1283.ffi).mlx = true
kernel_rfl PRE_first_tail_x15_r0_body.cpendLe145 : Nat.ble (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1283.ffi).mlx.next (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1282.ffi).mlx.next = true
/-- **The compaction's native shift**, given the call's bookkeeping, its relation's facts (the model's and the
observers') and the canonical closedness. -/
theorem PRE_first_tail_x15_r0_body.cshift145 (clean : Conv.NClean (⟨21064, 18162, 2788955, 6278⟩ : Conv.Cnt) (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1281.ffi).mlx) (hltC : ∀ h, PH (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1281.ffi).mlx h → h < (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1281.ffi).mlx.next) (nltC : ∀ i, PN (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1281.ffi).mlx i → i < (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1281.ffi).mlx.nnext) (itemsC : ∀ k v, (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1281.ffi).mlx.items.get k = some v → PN (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1281.ffi).mlx k) (tracedC : ∀ h o, (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1281.ffi).mlx.objs.get h = some o → ∀ i ∈ objTraces o, i < PRE_first_tail_x15_r0_body.P145.NL) (cl : SSt (· < 6278) PRE_first_tail_x15_r0_body.cx0_145.mlx)
    (hobjC : ∀ h, PRE_first_tail_x15_r0_body.fxC_145.get h = some () → ((Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1281.ffi).mlx.objs.get h).isSome = true)
    (hfC : ∀ h, (PRE_first_tail_x15_r0_body.krC_145.flags.get h).isSome = true → ((Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1281.ffi).mlx.objs.get h).isSome = true)
    (htC : ∀ h, (PRE_first_tail_x15_r0_body.krC_145.targs.get h).isSome = true → ((Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1281.ffi).mlx.objs.get h).isSome = true)
    (hclC : ∀ h l, PRE_first_tail_x15_r0_body.krC_145.targs.get h = some l → Host.Ts.Sim.Full.STargs (· < (⟨21064, 18162, 2788955, 6278⟩ : Conv.Cnt).n) l) :
    Conv.FullShiftQ PRE_first_tail_x15_r0_body.P145 6278 PRE_first_tail_x15_r0_body.kappa145 PRE_first_tail_x15_r0_body.s1283.ffi PRE_first_tail_x15_r0_body.s1282.ffi :=
  ⟨PRE_first_tail_x15_r0_body.cnshift145 clean hltC nltC itemsC tracedC cl, PRE_first_tail_x15_r0_body.cqueue145, fun t ht => bSN_sound (List.all_eq_true.mp PRE_first_tail_x15_r0_body.ctokSupp145 t ht),
    PRE_first_tail_x15_r0_body.cbridge145,
    liveShift_foot (x0' := Host.Ts.Sim.Full.mlxOf PRE_first_tail_x15_r0_body.s1283.ffi) (x1' := Host.Ts.Sim.Full.mlxOf PRE_first_tail_x15_r0_body.s1282.ffi) (PRE_first_tail_x15_r0_body.cfoot145 clean hltC nltC itemsC tracedC cl) rfl PRE_first_tail_x15_r0_body.ofx0_145 PRE_first_tail_x15_r0_body.ofx1_145 hobjC PRE_first_tail_x15_r0_body.ff0145 PRE_first_tail_x15_r0_body.ff1145 PRE_first_tail_x15_r0_body.ffck145,
    kernShift_foot (x0' := Host.Ts.Sim.Full.mlxOf PRE_first_tail_x15_r0_body.s1283.ffi) (x1' := Host.Ts.Sim.Full.mlxOf PRE_first_tail_x15_r0_body.s1282.ffi) (PRE_first_tail_x15_r0_body.cfoot145 clean hltC nltC itemsC tracedC cl) rfl PRE_first_tail_x15_r0_body.okr0_145 PRE_first_tail_x15_r0_body.okr1_145 (Nat.le_of_ble_eq_true PRE_first_tail_x15_r0_body.fkn145) hfC htC hclC
      PRE_first_tail_x15_r0_body.fkf0145 PRE_first_tail_x15_r0_body.fkt0145 PRE_first_tail_x15_r0_body.fkf1145 PRE_first_tail_x15_r0_body.fkt1145 PRE_first_tail_x15_r0_body.fkck145,
    pendReg_of rfl PRE_first_tail_x15_r0_body.cnh0145 PRE_first_tail_x15_r0_body.cnh1145 (Nat.le_of_ble_eq_true PRE_first_tail_x15_r0_body.cpendLe145) PRE_first_tail_x15_r0_body.cpendR145⟩

end Host.Load.Run.Tpl
